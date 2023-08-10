//===========================================================================
//
//						 ICW_FinanceManager.aspx.cs
//
//  Basically only displays a panel, with add & remove buttons, and tabs along top.
//  Used to manage display of sheets
//
//  Add sheet
//  ---------
//  The process flow of adding a new Grni sheet when user clicks add sheet
//      btnAddGrniSheet_OnClick         - java event fired when add sheet button is clicked
//          FMAddGrniSheet.aspx         - form display to allow user to set new sheet parameters (returns WFMStockAccountSheetSettings, or WFMGrniSettings to client side)
//              CreateGrniSheet         - Server web method called by client to create new sheet (returns WFMBalanceSheetData)
//                  FMGrniSheet.Create  - called to create sheet (render HTML is extracted and passed client side in WFMBalanceSheetData)
//                      AddSheet        - client method that takes WFMBalanceSheetData to display sheet
//
//  Call the page with the follow parameters
//  SessionID - ICW session ID
//  
//  Usage:
//  ICW_FinanceManager.aspx?SessionID=123
//
//	Modification History:
//	15May13 XN  Written (27038) 
//  16Sep13 XN  Added CreateAccountSheet, and SaveLogViewerSearchCriteria for
//              for account sheet 73326  
//  07Jan14 XN  Prevented crash if drag and drop tabs 81141
//  09Jan14 XN  Added SaveLogViewerSearchCriteria
//  27Oct14 XN  Added Export to CSV button 84572
//===========================================================================
using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.Services;
using System.Web.UI;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;
using System.Xml;
using ascribe.pharmacy.reportlayer;
using System.Collections.Generic;
using ascribe.pharmacy.pharmacydatalayer;

public partial class application_FinanceManager_ICW_FinanceManager : System.Web.UI.Page
{
    #region Data Types
    /// <summary>used to store data set too client side</summary>
    public struct WFMBalanceSheetData
    {
        public Guid     uniqueID;
        public string   name;
        public string   sheetData;
    }
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        int sessionID  = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        if (!this.IsPostBack)
        {
            btnUpdateData.Visible = WFMSettings.General.TestingMode;

            spanAddStockAccountSheet.Visible = WFMSettings.General.ShowAddStockAccountSheet;
            spanAddAccountSheet.Visible      = WFMSettings.General.ShowAddAccountSheet;
            spanAddGRNISheet.Visible         = WFMSettings.General.ShowAddGRNISheet;
        }
    }

    /// <summary>Only really used by testing will update WFMLogCache, and WFMDailyStockLevel with latest results</summary>
    protected void btnUpdateData_OnClick(object sender, EventArgs e)
    {
        Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate 'O'");
        Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate 'T'");
        Database.ExecuteSQLNonQuery("Exec pWFMDailyStockLevelUpdate");
        ScriptManager.RegisterStartupScript(this, this.GetType(), "UpdateData", "alert('Cached data has been updated.');", true);
    }
    #endregion

    #region Web Methods
    /// <summary>
    /// Create stock balance sheet using WFMAccountSheetSettings
    /// Will render the control HTML to a string and send back to client via (WFMSheetData)
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="settings">sheet creation settings</param>
    /// <returns>Returns extra info and HTML string of enquiry sheet</returns>
    [WebMethod]
    public static WFMBalanceSheetData CreateStockAccountSheet(int sessionID, WFMStockAccountSheetSettings settings)
    {
        // The balance sheet requires a £ symbol read from WConfiguration, 
        // and as page does not have a site us the first in list
        SessionInfo.InitialiseSessionAndSiteNumber(sessionID, settings.siteNumbers.First());

        // Create the control
        Page page = new Page();
        application_FinanceManager_controls_FMStockAccountSheet balanceSheet = (page.LoadControl("application/FinanceManager/controls/FMStockAccountSheet.ascx") as application_FinanceManager_controls_FMStockAccountSheet);
        balanceSheet.Create(settings, true);

        // Get the control to write itself.
        StringBuilder html = new StringBuilder();
        using (StringWriter sw = new StringWriter(html))
        {
            using (HtmlTextWriter writter = new HtmlTextWriter(sw))
                balanceSheet.RenderControl(writter);
        }

        // Fill in the sheet return data
        WFMBalanceSheetData sheetData = new WFMBalanceSheetData();
        sheetData.uniqueID  = settings.sheetID;
        sheetData.name      = string.Format("Stock {0} - {1}", settings.startDate.ToPharmacyDateString(), settings.endDate.ToPharmacyDateString());
        sheetData.sheetData = html.ToString().Replace("\r\n", string.Empty).XMLEscape(false);

        return sheetData;
    }

    /// <summary>
    /// Create account Enquiry using WFMAccountSheetSettings
    /// Will render the control HTML to a string and send back to client via (WFMSheetData)
    /// 16Sep13 XN  73326  
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="settings">sheet creation settings</param>
    /// <returns>Returns extra info and HTML string of account Enquiry</returns>
    [WebMethod]
    public static WFMBalanceSheetData CreateAccountSheet(int sessionID, WFMAccountSheetSettings settings)
    {
        // The balance sheet requires a £ symbol read from WConfiguration, 
        // and as page does not have a site us the first in list
        SessionInfo.InitialiseSessionAndSiteNumber(sessionID, settings.siteNumbers.First());

        // Create the control
        Page page = new Page();
        application_FinanceManager_Controls_FMAccountSheet balanceSheet = (page.LoadControl("application/FinanceManager/controls/FMAccountSheet.ascx") as application_FinanceManager_Controls_FMAccountSheet);
        balanceSheet.Create(settings);

        // Get the control to write itself.
        StringBuilder html = new StringBuilder();
        using (StringWriter sw = new StringWriter(html))
        {
            using (HtmlTextWriter writter = new HtmlTextWriter(sw))
                balanceSheet.RenderControl(writter);
        }

        // Fill in the sheet return data
        WFMBalanceSheetData sheetData = new WFMBalanceSheetData();
        sheetData.uniqueID  = settings.sheetID;
        sheetData.name      = string.Format("Account {0} - {1}", settings.startDate.ToPharmacyDateTimeString(), settings.endDate.ToPharmacyDateTimeString());
        sheetData.sheetData = html.ToString().Replace("\r\n", string.Empty).XMLEscape(false);

        return sheetData;
    }

    /// <summary>
    /// Create GRNI Report using FMGRrniSheet
    /// Will render the control HTML to a string and send back to client via (WFMSheetData)
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="settings">sheet creation settings</param>
    /// <returns>Returns extra info and HTML string of account Enquiry</returns>
    [WebMethod]
    public static WFMBalanceSheetData CreateGrniSheet(int sessionID, WFMGrniSettings settings)
    {
        // The balance sheet requires a £ symbol read from WConfiguration, 
        // and as page does not have a site us the first in list
        SessionInfo.InitialiseSessionAndSiteNumber(sessionID, settings.siteNumbers.First());

        // Create the control
        Page page = new Page();
        application_FinanceManager_controls_FMGrniSheet sheet = (page.LoadControl("application/FinanceManager/controls/FMGrniSheet.ascx") as application_FinanceManager_controls_FMGrniSheet);
        sheet.Create(settings);

        // Get the control to write itself.
        StringBuilder html = new StringBuilder();
        using (StringWriter sw = new StringWriter(html))
        {
            using (HtmlTextWriter writter = new HtmlTextWriter(sw))
                sheet.RenderControl(writter);
        }

        // Fill in the sheet return data
        WFMBalanceSheetData sheetData = new WFMBalanceSheetData();
        sheetData.uniqueID  = settings.sheetID;
        sheetData.name      = string.Format("GRNI up to {0}", settings.upToDate.ToPharmacyDateString());
        sheetData.sheetData = html.ToString().Replace("\r\n", string.Empty).XMLEscape(false);

        return sheetData;
    }


    /// <summary>
    /// Saves the data need to print off report (list of displayed item) to session attribute PharmacyGeneralReportAttribute.
    /// Returns the name of the report to print 'Pharmacy General Report {Site number}' (relates to report in RichTextDocument table.
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="title">Current page title</param>
    /// <param name="grid">Current grid data returned by MarshalRows client side method</param>
    /// <returns>report to print</returns>
    [WebMethod]
    public static string SaveReportForPrinting(int sessionID, string title, string hospitalName, string setting, string drug, string grid, string warning, string reportName)
    {
        SessionInfo.InitialiseSession(sessionID);

        FinanceManagerReport report = new FinanceManagerReport(title, hospitalName, setting, drug, grid, warning);
        report.AddColourMaps(application_FinanceManager_Controls_FMAccountSheet.GetColourMapping        ());
        report.AddColourMaps(application_FinanceManager_controls_FMGrniSheet.GetColourMapping           ());
        report.AddColourMaps(application_FinanceManager_controls_FMStockAccountSheet.GetColourMapping   ());
        report.Save();

        if (!OrderReport.IfReportExists(reportName))
            throw new ApplicationException(string.Format("Report not found '{0}'", reportName));

        return reportName;
    }

    /// <summary>Saves search criteria for pharmacy log viewer to db session</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="settings">Stock balance sheet settings</param>
    [WebMethod]
    public static void SaveLogViewerSearchCriteria(int sessionID, WFMStockAccountSheetSettings settings)
    {
        SessionInfo.InitialiseSession(sessionID);

        // Set log viewer search criteria
        PharmacyDisplayLogRows.GeneralSearchCriteria generalSettings = new PharmacyDisplayLogRows.GeneralSearchCriteria();
        generalSettings.pharmacyLog     = PharmacyLogType.PharmacyLog;
        generalSettings.fromDate        = DateTimeExtensions.MinDBValue;
        generalSettings.toDate          = DateTimeExtensions.MaxDBValue;
        generalSettings.useLogDateTime  = false;
        generalSettings.siteNumbers     = new int[0];
        generalSettings.NSVCode         = settings.NSVCode;
        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.GeneralSearchCriteria",  JsonConvert.SerializeObject(generalSettings) );

        PharmacyDisplayLogRows.PharmacyLogSearchCriteria pharmacyLogSearchCriteria = new PharmacyDisplayLogRows.PharmacyLogSearchCriteria();
        //pharmacyLogSearchCriteria.logType = "labutils"; XN 28Aug14 88922 allowed to specify mulitple log types
        //pharmacyLogSearchCriteria.logType = new [] { "labutils" };    23Feb15 XN Got to use new WPharmacyLogType
        pharmacyLogSearchCriteria.logType = WPharmacyLogType.LabUtils;
        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.LogSearchCriteria", JsonConvert.SerializeObject(pharmacyLogSearchCriteria) ); 
    }

    /// <summary>
    /// Called from GRNI Report client after row is double clicked.
    /// Saves search criteria for pharmacy log viewer to db session
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="settings">GRNI sheet settings</param>
    /// <param name="siteNumber">site number for drug row</param>
    /// <param name="supCode">Supplier code for row</param>
    /// <param name="NSVCode">Drug to display</param>
    /// <param name="orderNumber">Order number to display</param>
    [WebMethod]
    public static void SaveGRNILogViewerSearchCriteria(int sessionID, WFMGrniSettings settings, int siteNumber, string supCode, string NSVCode, string orderNumber)
    {
        SessionInfo.InitialiseSession(sessionID);

        PharmacyDisplayLogRows.GeneralSearchCriteria generalSettings = new PharmacyDisplayLogRows.GeneralSearchCriteria();
        generalSettings.pharmacyLog     = PharmacyLogType.Orderlog;
        generalSettings.fromDate        = DateTime.MinValue;
        generalSettings.toDate          = settings.upToDate.ToEndOfDay();
        generalSettings.useLogDateTime  = true;
        generalSettings.siteNumbers     = new [] { siteNumber };
        generalSettings.NSVCode         = NSVCode;
        generalSettings.moneyDisplayType= MoneyDisplayType.Show;

        PharmacyDisplayLogRows.OrderlogSearchCriteria ordelogSettings = new PharmacyDisplayLogRows.OrderlogSearchCriteria();
        ordelogSettings.orderNumber = orderNumber.ToString();
        ordelogSettings.supCode     = supCode;

        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.GeneralSearchCriteria",  JsonConvert.SerializeObject(generalSettings) );
        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.LogSearchCriteria",      JsonConvert.SerializeObject(ordelogSettings) );
        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.Columns",                WFMSettings.GrniSheet.LogViewerColumns       );
    }

    /// <summary>
    /// Called from Account Enquiry client after row is double clicked.
    /// Saves search criteria for pharmacy log viewer to db session
    /// 16Sep13 XN  73326  
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="settings">Account Enquiry settings</param>
    /// <param name="siteNumber">site number for drug row</param>
    /// <param name="NSVCode">Drug to display</param>
    [WebMethod]
    public static void SaveAccountLogViewerSearchCriteria(int sessionID, WFMAccountSheetSettings settings, int siteNumber, string NSVCode)
    {
        SessionInfo.InitialiseSession(sessionID);

        PharmacyDisplayLogRows.GeneralSearchCriteria generalSettings = new PharmacyDisplayLogRows.GeneralSearchCriteria();
        generalSettings.pharmacyLog     = PharmacyLogType.Unknown;
        generalSettings.fromDate        = settings.startDate;
        generalSettings.toDate          = settings.endDate;
        generalSettings.useLogDateTime  = true;
        generalSettings.siteNumbers     = new [] { siteNumber };
        generalSettings.NSVCode         = NSVCode;
        generalSettings.moneyDisplayType= MoneyDisplayType.Show;

        PharmacyDisplayLogRows.CombinedLogSearchCriteria combinedlogSettings = new PharmacyDisplayLogRows.CombinedLogSearchCriteria();

        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.GeneralSearchCriteria",  JsonConvert.SerializeObject(generalSettings)      );
        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.LogSearchCriteria",      JsonConvert.SerializeObject(combinedlogSettings)  );
        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.Columns",                WFMSettings.AccountSheet.LogViewerColumns         );
    }
    #endregion
}
