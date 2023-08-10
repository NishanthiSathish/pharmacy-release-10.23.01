// <copyright file="SSRSReport.aspx.cs" company="Ascribe Ltd">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
//  Allows displaying of an SSRS report
// 
//  Currently the page only supports local (rdlc reports), and not full SSRS reports.
//
//  See Report Layer\SSRSLocalReport.cs for details of resolving full report path
//  and how to generate custom reports (or site specific reports)
// 
//  The sp used to populate the report must exist in the Routine table, and any parameters must live in the 
//  RoutineParameter table. Each parameter must either have a lookup or default value (defined in RoutineParameter), 
//  parameters named SiteID or SessionID are automatically converted to correct value. 
//  The page will display the appropriate lookups to the user. 
//  It's possible to pass in parameters to the sp on the URL as CSV list separated by : (escape , and : by double escape text)
//      e.g. Params=CurrentSessionID:{0},LocationID_Site:{1},Context:'instruction.{2:000}',,'instruction.{2:000}.dss'
//
//  The page will display the appropriate looks to the user. If the user cancels a lookup (cancels report creation)
//  the page will call client method ssrsreport_cancelledcreation
//  If is possible to pass params to the SP from the url by setting URL parameter Params :)
//
//	There is a bug with the ReportViewer 10 control that means it can't print from a modal dialog
//  you get error "An error occurred trying to get the current window". 
//  Either set URL parameter ShowPrintButton=Yes or make the page embedded. 
//           
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Pharmacy site
//  SiteID              - 
//  ReportFile          - Report file name (including sub folder)
//  SP                  - Name of the SP to call to populate the report
//  AutoPrint           - (optional) If the report is automatically be printed off when displayed. Default No
//  Params              - (optional) CSV list of parameters to pass to the sp          
//                        e.g. CurrentSessionID:123,ArbText:Test text,ArbTextGroupID:2
//                        (Note strings are not require to be in quotes)
//  ShowPrintButton		- If to show the print button
//  Title               - Title to show at top of page (when modal popup)
//  
//  Modification History:
//  17Jul13 XN  Written 24653
//  18May15 XN  117528 Added ability to pass optional set of parameters to pass to the SP
//              Also increased size of from
//  03Jul15 XN  Added Params url
//  23May16 XN  Added ShowPrintButton parameter 153789
//  26Jul16 XN  Client side change to prevent it continually printing when auto print is enabled 157124
//              Client side change to prevent the right scroll bar continually resizing causing application to lock 157124
// </summary>
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;

using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;

/// <summary>Allows displaying of an SSRS report</summary>
public partial class application_pharmacysharedscripts_SSRSReport : System.Web.UI.Page
{
    #region Member variables
    /// <summary>List of parameters</summary>
    private List<SqlParameter> parametersLoadedSoFar = new List<SqlParameter>();

    /// <summary>report file name (if local rdlc ssrs report)</summary>
    private string reportName;

    /// <summary>SP to use to populate the report (if local rdlc ssrs report)</summary>
    private string sp;

    /// <summary>indicating whether report is auto printed</summary>
    private bool autoPrint;

    /// <summary>if page is embedded in report</summary>
    protected bool embeddedMode;

    /// <summary>Title to display at top of modal window</summary>
    protected string title;
    #endregion

    #region Event Handlers
    /// <summary>Load page</summary>
    /// <param name="sender">Sender object</param>
    /// <param name="e">Event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        // Get Desktop parameters
        this.reportName     = this.Request["ReportFile"];
        this.sp             = this.Request["SP"];
        this.title          = this.Request["Title"] ?? "Report";
        this.autoPrint      = BoolExtensions.PharmacyParseOrNull(this.Request["AutoPrint"]) ?? false;
        this.embeddedMode   = BoolExtensions.PharmacyParseOrNull(this.Request["EmbeddedMode"]) ?? false;
		this.reportViewer.ShowPrintButton = BoolExtensions.PharmacyParseOrNull(this.Request["ShowPrintButton"]) ?? true; // 23May16 XN Added 153789      

        // Get parameters loaded so far for the SP to run to fill the report
        this.LoadParametersLoadedSoFar();

        if (!this.IsPostBack)
        {
            // Check that SP exists  108772 19Jan XN and display friendly error
            if (!Database.CheckSPExist(this.sp))
            {
                Response.Redirect("~\\application\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=SP " + this.sp + " does not exist in the DB.");            
                return;
            }

            // Extra parameters e.g. CurrentSessionID:454,Description:Some Text
            // : and , chars are double escaped
            // 18May15 XN 117528
            var paramList = (Request["Params"] ?? string.Empty).Replace(",,", "\0x01").Replace("::", "\0x02").Split(new [] { ',' }, StringSplitOptions.RemoveEmptyEntries);
            foreach(var p in paramList)
            {
                var nameValuePair = p.Split(':');    // Escape ::
                if (nameValuePair.Count() != 2)
                {
                    throw new ApplicationException("Params statement must consist of CSV list of parameters with name:value format e.g. CurrentSessionID:234,Description=Some Text Here,...\nError with parameter " + p + "\nNote that : and , are double escaped");
                }

                for (int c = 0; c < nameValuePair.Count(); c++) 
                {
                    nameValuePair[c] = nameValuePair[c].Replace("\0x02", ":").Replace("\0x01", ","); // Un Escape :: and ,,
                }

                this.parametersLoadedSoFar.Add(nameValuePair[0], nameValuePair[1]);
            }
            
            // get next report sp parameter (if none load the report)
            if (!this.GetNextParameter())
            {
                this.LocalReport();                    
            }
        }

        string args = Request["__EVENTARGUMENT"];

        // Deal with __postBack events
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args))
        {
            argParams = args.Split(new char[] { ':' });
        }

        switch (argParams[0])
        {
        case "ParameterValue":
            {
            // New lookup parameter has been returned so save
            string parameterName = argParams[1];
            string parameterValue= argParams[2];
            this.parametersLoadedSoFar.Add(parameterName, parameterValue);
            
            // get next report sp parameter (if none load the report)
            if (!this.GetNextParameter())
            {
                this.LocalReport();                    
            }
            }
            break;
        }

        this.SaveParametersLoadedSoFar();
    }
    #endregion

    #region Private Methods
    /// <summary>Load the local ssrs report</summary>
    private void LocalReport()
    {
        try
        {
            // Create the SSRS report helper
            SSRSLocalReport report = new SSRSLocalReport(reportViewer, this.reportName, SessionInfo.SiteNumber);

            // Load the report data
            report.LoadDefaultDetails();
            report.LoadDataBySP(this.sp, this.parametersLoadedSoFar);

            // If required auto print the report
            if (this.autoPrint)
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AutoPrint", "autoPrint();", true);
            }
        }
        catch (ApplicationException ex)
        {
            // 108772 19Jan XN and display friendly error
            Response.Redirect("DesktopError.aspx?ErrorMessage=" + ex.Message);            
        }
    }

    /// <summary>
    /// Adds the next parameter for the sp into parametersLoadedSoFar
    /// If the parameter is a lookup will call client side LookupParameter, else displays input box
    /// </summary>
    /// <returns>Returns false if needs to display lookup, else true if all parameters for SP have been loaded</returns>
    private bool GetNextParameter()
    {
        // convert each parameter an add to parametersLoadedSoFar
        var parameter = this.GetRoutineParameters();
        foreach (var p in parameter)
        {
            if (!this.parametersLoadedSoFar.Any(l => l.ParameterName.EqualsNoCaseTrimEnd(p.Description)))
            {
                if (p.RoutineIDLookup != null)
                {
                    // If look then lookup sp paramerets in string {param name 1}:{param value 1},{param name 2}:{param value 2},
                    RoutineParameter lookupParameter = new RoutineParameter();
                    lookupParameter.LoadByRoutinetID(p.RoutineIDLookup.Value);
                    string loopParamStr = lookupParameter.Select(lp => lp.Description + ":" + lp.GetDefaultValue()).ToCSVString(",");

                    // Get lookup routine name, and call client side LookupParameter
                    RoutineRow lookupRoutine = Routine.GetByID(p.RoutineIDLookup.Value);
                    string script = string.Format("LookupParameter('{0}', '{1}', '{2}');", p.Description, lookupRoutine.Name, loopParamStr);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "LookupParameter", script, true);

                    return true;
                }
                else if (p.Description.EqualsNoCase("SiteID") || p.Description.EqualsNoCase("SessionID") || p.Description.EqualsNoCase("CurrentSessionID"))
                {
                    this.parametersLoadedSoFar.Add(p.Description, p.GetDefaultValue());
                }
                else
                {
                    string script = string.Format("EnterParameter('{0}', true);", p.Description);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "EnterParameter", script, true);

                    return true;
                }
            }
        }

        return false;
    }

    /// <summary>
    /// Reads the routine parameters from the RoutineParameter table 
    /// 3Jul15 XN added
    /// </summary>
    /// <returns>List of routine parameters</returns>
    private RoutineParameter GetRoutineParameters()
    {
        // Get the routine parameters
        RoutineRow routine = Routine.GetByName(this.sp);
        if (routine == null)
        {
            throw new ApplicationException(string.Format("SP '{0}' missing from the routine table.", this.sp));
        }

        RoutineParameter parameter = new RoutineParameter();
        parameter.LoadByRoutinetID(routine.RoutineID);
        return parameter;
    }

    /// <summary>Load sp parameters converted so far from hfParametersLoadedSoFar into parametersLoadedSoFar</summary>
    private void LoadParametersLoadedSoFar()
    {
        this.parametersLoadedSoFar = new List<SqlParameter>();
        foreach (var param in hfParametersLoadedSoFar.Value.Split(new [] {','}, StringSplitOptions.RemoveEmptyEntries))
        {
            var nameValue = param.Split(':');
            this.parametersLoadedSoFar.Add(nameValue[0], nameValue[1]);
        }
    }

    /// <summary>Save sp parameters converted so far from parametersLoadedSoFar into hfParametersLoadedSoFar</summary>
    private void SaveParametersLoadedSoFar()
    {
        hfParametersLoadedSoFar.Value = this.parametersLoadedSoFar.Select(p => p.ParameterName + ":" + p.Value).ToCSVString(",");
    }
    #endregion
}
