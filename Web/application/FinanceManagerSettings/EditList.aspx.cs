//===========================================================================
//
//						           EditList.aspx.cs
//
//  Displays list of finance manager settings that can be edited by double clicking on it.
//
//  Call the page with the follow parameters
//  SessionID   - ICW session ID
//  SiteID      - site ID
//  DataType    - Data type to display (one of transactiontypes, accountcodes, rules)
//
//  When 
//  
//  Usage:
//  EditList.aspx?SessionID=123&SiteID=24&DataType=transactiontypes
//
//	Modification History:
//  23Apr13 XN  Created 53147
//  22Jan14 XN  Added cloning button
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Services;
using System.Web.UI;
using System.Xml;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;
using Ascribe.Common;
using ascribe.pharmacy.pharmacydatalayer;

public partial class application_PNSettings_EditList : System.Web.UI.Page
{
    protected int sessionID;
    protected string dataType;
    protected Sites sites = new Sites();

    /// <summary>If add button is allowed</summary>
    protected bool allowAdding  = false;
    protected bool allowCloning = false;
    protected bool allowDeleting= false;
    
    /// <summary>Column that contains main item description (used by filtering)</summary>
    protected int filterColumn = -1;

    protected void Page_Load(object sender, EventArgs e)
    {
        sessionID  = int.Parse(Request["SessionID"]);
        dataType   = Request["DataType"];

        SessionInfo.InitialiseSession(sessionID);

        sites.LoadAll(true);

        if (!Page.IsPostBack)
        {
            InitGrid();
            PopulateGrid();
        }

        // Deal with __postBack events
        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];
        int recordID;    

        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        switch (target)
        {
        case "upButtons" :
            // Update from buttons to refresh rows
            // args are in form Refresh|{WFMRuleID}
            if ((argParams.Count() > 1) && (argParams[0] == "Refresh") && int.TryParse(argParams[1], out recordID))
                RefreshRow(recordID);
            else if ((argParams.Count() > 1) && (argParams[0] == "Delete") && int.TryParse(argParams[1], out recordID))
            {
                DeleteRow(recordID);
                RefreshRow(recordID);
            }
            break;
        }
    }

    /// <summary>Refresh button is clicked</summary>
    protected void btnRefresh_OnClick(object sender, EventArgs e)
    {
        InitGrid();
        PopulateGrid();

        // Clear the filter box
        ScriptManager.RegisterStartupScript(this, this.GetType(), "refreshed", "$('#tbFilter').val('')", true);
    }

    /// <summary>Initialises the grid columns based on dataType</summary>
    protected void InitGrid()
    {
        allowAdding  = false;
        allowCloning = false;
        allowDeleting= false;
        filterColumn = -1;

        switch (dataType.ToLower())
        {
        case "transactiontypes": 
            gridItemList.AddColumn("Kind",        10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Log",         10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Description", 75);
            gridItemList.ColumnAllowTextWrap (2, true);
            gridItemList.ColumnXMLEscaped    (2, false);
            gridItemList.EnableAlternateRowShading = true;
            gridItemList.SortableColumns           = true;
            gridItemList.EmptyGridMessage          = "No finance manager transaction types have been installed";
            break;

        case "accountcodes": 
            gridItemList.AddColumn("Code",        10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Description", 75);
            gridItemList.ColumnAllowTextWrap (1, true);
            gridItemList.ColumnXMLEscaped    (1, false);
            gridItemList.ColumnKeepWhiteSpace(1, true);
            gridItemList.EnableAlternateRowShading = false;
            gridItemList.SortableColumns           = true;
            gridItemList.EmptyGridMessage          = @"No finance manager account codes have been installed";
            allowAdding  = true;
            break;

        case "rules": 
            gridItemList.AddColumn("Code",                  7,  PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Description",          19,  PharmacyGridControl.AlignmentType.Left  );
            gridItemList.AddColumn("Log",                   7,  PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Kind",                  7,  PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Label/Supplier Type",  16,  PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("NSV Code",              7,  PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Ward/Supplier Code",   16,  PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Site",                  7,  PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Debit",                 7,  PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Credit",                7,  PharmacyGridControl.AlignmentType.Center);

            gridItemList.EnableAlternateRowShading = true;
            gridItemList.SortableColumns           = true;
            gridItemList.EmptyGridMessage          = "No finance manager rules have not been installed";

            allowAdding  = true;
            allowCloning = true;
            allowDeleting= true;
            break;
        }
    }

    /// <summary>Adds all the data to the grid depending on dataType</summary>
    private void PopulateGrid()
    {
        switch (dataType.ToLower())
        {
        case "transactiontypes":
            {
                WFMTransactionType logtypes = new WFMTransactionType();
                logtypes.LoadAll();
                foreach (var l in logtypes.OrderBy(p => p.Kind).OrderBy(p => p.PharmacyLog))
                    AddTransactionType(l);
            }
            break;

        case "accountcodes":
            {
                WFMAccountCode segment1Codes = new WFMAccountCode();
                segment1Codes.LoadAll();

                foreach (var c in segment1Codes.OrderBy(r => r.Code))
                    AddAccountCode(c);
            }
            break;

        case "rules": 
            {
                WFMRule rules = new WFMRule();
                rules.LoadAll();
                
                foreach(var r in rules)
                    AddRule(r);
            }
            break;
        }
    }

    /// <summary>Refresh (or adds) single row in grid, by creating HTML, and sending it to client by calling javamethod UpdateGridRow</summary>
    /// <param name="recordID">Record to update</param>
    private void RefreshRow(int recordID)
    {
        InitGrid();

        switch (dataType.ToLower())
        {
        case "transactiontypes": AddTransactionType(WFMTransactionType.GetByID(recordID));  break;
        case "accountcodes":     AddAccountCode(WFMAccountCode.GetByID(recordID));          break;
        case "rules":            AddRule(WFMRule.GetByID(recordID));                        break;
        }

        string row = (gridItemList.RowCount > 0) ? gridItemList.ExtractHTMLRows(0, 1)[0].Replace("\r\n", string.Empty) : string.Empty;
        string script = string.Format("UpdateGridRow({0}, '{1}');", recordID, Generic.XMLEscape(row));
        ScriptManager.RegisterStartupScript(this, this.GetType(), "updategridrow", script, true);
    }

    /// <summary>Adds a single log type to the grid</summary>
    /// <param name="pnProduct">product to add</param>
    protected void AddTransactionType(WFMTransactionTypeRow logType)
    {
        if (logType != null)
        {
            gridItemList.AddRow();
            gridItemList.AddRowAttribute("RecordID", logType.WFMTransactionTypeID.ToString()); 
            gridItemList.SetCell(0, logType.Kind);
            gridItemList.SetCell(1, logType.PharmacyLog.ToString());
            gridItemList.SetCell(2, logType.Description);
        }
    }

    /// <summary>Adds a Account Code to the grid</summary>
    /// <param name="code">code to add</param>
    private void AddAccountCode(WFMAccountCodeRow code)
    {
        if (code != null)
        {
            gridItemList.AddRow();
            if (code.AccountLevel == 0)
                gridItemList.SetRowBackgroundColour("#EAF7FF");
            gridItemList.AddRowAttribute("RecordID", code.WFMAccountCodeID.ToString()); 
            gridItemList.SetCell(0, code.Code.ToString());

            StringBuilder str = new StringBuilder();
            for(int i = code.AccountLevel; i > 0; i--)
                str.Append("   ");
            str.Append(code.DescriptionWithDisplayFormatting());
            gridItemList.SetCell(1, str.ToString());
        }
    }

    /// <summary>Adds a single rule to the grid</summary>
    /// <param name="rule">rule to add</param>
    protected void AddRule(WFMRuleRow rule)
    {
        if (rule != null)
        {
            gridItemList.AddRow();
            gridItemList.AddRowAttribute("RecordID", rule.WFMRuleID.ToString()); 

            gridItemList.SetCell( 0, rule.Code.ToString());
            gridItemList.SetCell( 1, rule.Description);
            gridItemList.SetCell( 2, rule.PharmacyLog.ToString());
            gridItemList.SetCell( 3, rule.Kind);
            gridItemList.SetCell( 4, (rule.PharmacyLog == PharmacyLogType.Orderlog) ? EnumDBCodeAttribute.EnumToDBCode(rule.SupplierType) : rule.LabelType);
            gridItemList.SetCell( 5, rule.NSVCode);
            gridItemList.SetCell( 6, (rule.PharmacyLog == PharmacyLogType.Orderlog) ? rule.SupCode : rule.WardCode);
            gridItemList.SetCell( 7, rule.LocationID_Site == null ? string.Empty : sites.FindByID(rule.LocationID_Site.Value).SiteNumber.ToString("000"));
            gridItemList.SetCell( 8, rule.AccountCode_Debit.ToString());
            gridItemList.SetCell( 9, rule.AccountCode_Credit.ToString());
        }
    }

    /// <summary>Deletes record from the DB</summary>
    /// <param name="recordID">Record to delete</param>
    protected void DeleteRow(int recordID)
    {
        if (dataType.EqualsNoCase("rules"))
        {
            WFMRule rule = new WFMRule();
            rule.LoadByID(recordID);
            if (rule != null)
            {
                rule.RemoveAt(0);

                if (!WFMSettings.General.RebuildLogs)
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "ShouldWeRebuild", "shouldWeRebuild();", true);
            }
            rule.Save();
        }
    }

    /// <summary>sets setting WFMSettings.General.RebuildLogs</summary>
    /// <param name="sessionID">Session ID</param>
    [WebMethod]
    public static void RequestLogRebuild(int sessionID)
    {
        WFMSettings.General.RebuildLogs = true;
    }

    /// <summary>
    /// Saves the data need to print off report (list of displayed item) to session attribute PharmacyGeneralReportAttribute.
    /// Returns the name of the report to print 'Pharmacy General Report {Site number}' (relates to report in RichTextDocument table.
    /// XN 29Dec12 (51139)
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="title">Current page title ('Rules', etc)</param>
    /// <param name="filter">Current filter applied to the data</param>
    /// <param name="grid">Current grid data returned by MarshalRows client side method</param>
    /// <returns>report to print</returns>
    [WebMethod]
    public static string SaveReportForPrinting(int sessionID, string title, string filter, string grid)
    {
        SessionInfo.InitialiseSession(sessionID);
        DateTime now = DateTime.Now;

        // Setup xml writer 
        XmlWriterSettings settings  = new XmlWriterSettings();
        settings.OmitXmlDeclaration = true;
        settings.ConformanceLevel   = ConformanceLevel.Fragment;

        // Create data
        StringBuilder xml = new StringBuilder();
        using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
        {
            xmlWriter.WriteStartElement("PNPrintData");

            // Report title
            xmlWriter.WriteStartElement("Title");
            xmlWriter.WriteAttributeString("title", title.Trim());
            xmlWriter.WriteEndElement();

            // Hospital name
            xmlWriter.WriteStartElement("Info");
            xmlWriter.WriteAttributeString("hospname1", string.Empty);
            xmlWriter.WriteAttributeString("hospname2", string.Empty);
            xmlWriter.WriteAttributeString("hospname3", string.Empty);

            // User info
            xmlWriter.WriteAttributeString("UserID",   SessionInfo.UserInitials);
            xmlWriter.WriteAttributeString("UserName", SessionInfo.Username    );
            xmlWriter.WriteAttributeString("today",    now.ToPharmacyDateString());
            xmlWriter.WriteAttributeString("TimeNow",  now.ToPharmacyTimeString());
            xmlWriter.WriteEndElement();

            // Grid data (including filter if specified)
            xmlWriter.WriteStartElement("Data");
            if (!string.IsNullOrEmpty(filter))
                xmlWriter.WriteAttributeString("InfoText", "List filtered by: " + filter);
            xmlWriter.WriteAttributeString("Table", RTFTable.ConvertPharmacyGrid(grid));
            xmlWriter.WriteEndElement();

            xmlWriter.WriteEndElement();

            xmlWriter.Close();
        }

        // Save
        GENRTL10.State state = new GENRTL10.State();
        state.SessionAttributeSet(sessionID, "PharmacyGeneralReportAttribute", xml.ToString());

        // Check report exist in db
        // (use % as don't have a site so bit of a hack)
        string reportNameSearch = "Pharmacy General Report %";
        string reportName       = OrderReport.SearchForReport(reportNameSearch).OrderBy(s => s).FirstOrDefault();
        if (string.IsNullOrEmpty(reportName))
            throw new ApplicationException(string.Format("Report not found '{0}'", reportNameSearch));

        // Return report name
        return reportName;
    }
}