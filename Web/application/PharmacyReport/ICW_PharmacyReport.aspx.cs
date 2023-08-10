// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ICW_PharmacyReport.aspx.cs" company="Ascribe Ltd.">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
// Desktop to allow a user to select, and view and number of SSRS local reports (rdlc)
//
// Most of the functionality for page is in client side.
// 
// Reports that can be selected are defined as desktop parameters (see SSRSReport.aspx.cs and Report Layer\SSRSLocalReport.cs for more detail)
// You will need to enter the 
//      report name - anything
//      report file - file name for the report including sub folder (normaly read from {web site folder}\Reports
//      report SP   - SP that used to populate the report (must exist in Routine table)
//  
// Desktop parameter for the page include
// AscribeSiteNumber - Site number
// AutoPrint         - If the report is printed as soon as it is created.
// ReportName1       - 1st report name
// ReportFile1       - 1st report file name
// ReportSP1         - 1st SP
// Possible to have up to 5 reports defined
// </summary>
// --------------------------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Web.UI;

using ascribe.pharmacy.shared;

/// <summary>Desktop to allow a user to select, and view and number of SSRS local reports (rdlc)</summary>
public partial class application_PharmacyReport_ICW_PharmacyReport : System.Web.UI.Page
{
    #region Constants
    /// <summary>Max number of allowed reports</summary>
    private const int MaxNumberOfReports = 15;
    #endregion

    #region Data Types
    /// <summary>
    /// Holds information about the reports defined in the desktop parameters
    /// Structure is converted to JSON array and acessed client side (so changes will require change to client)
    /// </summary>
    protected struct ReportInfo
    {
        /// <summary>Gets or sets index id of the report</summary>
        public int Index { get; set; }

        /// <summary>Gets or sets name of the report</summary>
        public string Name { get; set; }

        /// <summary>Gets or sets file name of the report</summary>
        public string File { get; set; }

        /// <summary>Gets or sets SP of the report</summary>
        public string SP { get; set; }
    }
    #endregion

    #region Properties
    /// <summary>Gets list of report defined as desktop parameters</summary>
    protected List<ReportInfo> ReportInfoList { get; private set;  }

    /// <summary>Gets a value indicating whether auto print desktop parameter selected</summary>
    protected  bool AutoPrint { get; private set;  }
    
    /// <summary>Gets a value indicating whether report selecter is display first time user opens dekstop</summary>
    protected  bool ShowReportSelectorOnLoad { get; private set;  }
    #endregion

    /// <summary>Load desktop</summary>
    /// <param name="sender">Sender object</param>
    /// <param name="e">Event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        this.AutoPrint                = BoolExtensions.PharmacyParseOrNull(this.Request["AutoPrint"])                ?? true;
        this.ShowReportSelectorOnLoad = BoolExtensions.PharmacyParseOrNull(this.Request["ShowReportSelectorOnLoad"]) ?? true;

        this.ReportInfoList = new List<ReportInfo>();
        for (int r = 1; r < MaxNumberOfReports; r++)
        {            
            ReportInfo info = new ReportInfo()
                                  {
                                      Index= r,
                                      Name = (this.Request["ReportName" + r] ?? string.Empty).Trim(),
                                      File = (this.Request["ReportFile" + r] ?? string.Empty).Trim(),
                                      SP   = (this.Request["ReportSP"   + r] ?? string.Empty).Trim()
                                  };
            if (!string.IsNullOrWhiteSpace(info.Name) || !string.IsNullOrWhiteSpace(info.File))
            {
                this.ReportInfoList.Add(info);
            }
        }

        if (!this.IsPostBack && this.ShowReportSelectorOnLoad)
        {
            // Call the add button on start up
            ScriptManager.RegisterStartupScript(this, this.GetType(), "add", "setTimeout(function() { $('#btnAddReport').click();}, 1000);", true);
        }
    }
}