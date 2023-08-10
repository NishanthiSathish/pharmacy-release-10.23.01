//===========================================================================
//
//						     FMStockAccountPopup.aspx
//
//  Popup form used to display the FMStockAccountSheet.ascx contol 
//  (will not display the stock balance sheet find, previous, next or summary buttons
//  (not currently but could be extended to show other reports in a popup)
//
//  Currently called from the Stock Balance Sheet Summary View drill down.
//
//  Before calling this form need to call web method FMStockAccountDrillDown.aspx/SaveFMSettings
//  to pass in the from parameters
//
//  Call the page with the follow parameters
//  SessionID    - ICW session ID
//  
//	Modification History:
//  07Jan14 XN  Created 81145
//  27Oct14 XN  Now save settings to context via SaveFMSettings web method to 
//              fix issue if settings struct is very big then can't pass in on query
//              Added Export To CSV button 84572
//===========================================================================
using System;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;

public partial class application_FinanceManager_FMStockAccountPopup : System.Web.UI.Page
{
    #region Member variables
    /// <summary>Session ID</summary>
    protected int sessionID;

    /// <summary>Stock balance sheet settings passed in on URL</summary>
    protected WFMStockAccountSheetSettings settings;
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        // XN 27Oct14 Now save settings to context via SaveFMSettings web method to fix issue if settings struct is very big then can't pass in on query
        //sessionID = int.Parse(Request["SessionID"]);
        //settings  = JsonConvert.DeserializeObject<WFMStockAccountSheetSettings>(this.Request["Setting"]);
        //SessionInfo.InitialiseSessionAndSiteNumber(sessionID, settings.siteNumbers.First());
        
        SessionInfo.InitialiseSession(Request);

        // Get the settings from the cache
        object obj = PharmacyDataCache.GetFromSession("WFMStockAccountSheetSettings");
        if (obj == null || !(obj is WFMStockAccountSheetSettings))
        {
            Response.Redirect("~\\application\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=Need to call FMStockAccountPopup.aspx/SaveFMSettings before calling the from.");
            return;
        }
        PharmacyDataCache.RemoveFromSession("WFMStockAccountSheetSettings");
        settings = (WFMStockAccountSheetSettings)obj;

        // reset the session info (so has site number)
        SessionInfo.InitialiseSessionAndSiteNumber(SessionInfo.SessionID, settings.siteNumbers.First());

        if (!this.IsPostBack)
        {
            // Create control
            stockAccountSheet.Create(settings, false);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Init", string.Format("stockAccountSheeMinimiseAllSections('{0}');", settings.sheetID), true);
        }
    }
    #endregion

    #region Web Methods
    /// <summary>
    /// Saves the data need to print off report (list of displayed item) to session attribute PharmacyGeneralReportAttribute.
    /// Returns the name of the report to print 'Pharmacy General Report {Site number}' (relates to report in RichTextDocument table.
    /// </summary>
    /// <returns>report to print</returns>
    [WebMethod]
    public static string SaveReportForPrinting(int sessionID, string title, string hospitalName, string setting, string drug, string grid, string warning, string reportName)
    {
        SessionInfo.InitialiseSession(sessionID);

        FinanceManagerReport report = new FinanceManagerReport(title, hospitalName, setting, drug, grid, warning);
        //report.AddColourMaps(application_FinanceManager_Controls_FMAccountSheet.GetColourMapping        ());
        //report.AddColourMaps(application_FinanceManager_controls_FMGrniSheet.GetColourMapping           ());
        report.AddColourMaps(application_FinanceManager_controls_FMStockAccountSheet.GetColourMapping   ());
        report.Save();

        if (!OrderReport.IfReportExists(reportName))
            throw new ApplicationException(string.Format("Report not found '{0}'", reportName));

        return reportName;
    }
    
    /// <summary>Used to save settings before lauching the form XN 27Oct14</summary>
    [WebMethod]
    public static void SaveFMSettings(int sessionID, WFMStockAccountSheetSettings settings)
    {
        SessionInfo.InitialiseSession(sessionID);
        PharmacyDataCache.SaveToSession("WFMStockAccountSheetSettings", settings);
    }
    #endregion
}