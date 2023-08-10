//===========================================================================
//
//						        FMAddStockAccountSheet.aspx
//
//  Allows user to select start, end, and sites to used to create a balance sheet
//
//  Page will return the data in a JSONified WFMStockAccountSheetSettings structure
//  This is also saved to settings cache (so remembers users last chosen settings)
//
//  Call the page with the follow parameters
//  SessionID - ICW session ID
//  
//  Usage:
//  FMAddStockAccountSheet.aspx?SessionID=123
//
//	Modification History:
//	15May13 XN  Written (27038) 
//===========================================================================
using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;
using System.Collections.Generic;

public partial class application_FinanceManagerStockAccountSheet_FMAddStockAccountSheet : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        int sessionID  = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        // As ICW control need to set cancel button manually
        btnCancel.Attributes.Add("onclick", "window.close(); return false;");

        if (!this.IsPostBack)
        {
            // Get previous settings from cache if present
            WFMStockAccountSheetSettings? settings = null;
            string settingStr = PharmacyDataCache.GetFromDBSession("FMAddStockAccountSettings");
            if (!string.IsNullOrEmpty(settingStr))
                settings = JsonConvert.DeserializeObject<WFMStockAccountSheetSettings>(settingStr);

            // Check enough data to create a balance sheet
            DateTime? earliestDataDate = WFMDailyStockLevel.GetEarliestValidDate();
            if (earliestDataDate == null || earliestDataDate > DateTime.Now)
            {
                mbInvalidData.Visible = true;
                return;
            }

            // Set default date range
            // Normally form earliest valid date in WFMDailyStockLevel or min of 1 month ago
            // to end of last valid date in WFMDailyStockLevel
            // Or from previous settings
            if (settings == null)
            {
                dtStartDate.Value = DateTimeExtensions.Max(DateTime.Now.AddMonths(-1).ToStartOfDay(), earliestDataDate.Value);  // Either earliest valid date or 1 month
                dtEndDate.Value   = WFMDailyStockLevel.GetLastDate().ToStartOfDay();                                            // End of valid dates
            }
            else
            {
                dtStartDate.Value = settings.Value.startDate;   // From previous settings
                dtEndDate.Value   = settings.Value.endDate;
            }
            if (WFMSettings.General.TestingUpdateTimeMode)
                dtEndDate.Value = DateTime.Now.AddDays(1).ToStartOfDay(); // for testing always set end date to now

            // Get site settings
            IEnumerable<int> allowedSites           = WFMSettings.General.AllowedSites.OrderBy(s => s);
            IEnumerable<int> sitesSelectedByDefault = WFMSettings.General.SiteNumbersSelectedByDefault;
                
            // Setup site list
            List<Site> siteList = (new SiteProcessor()).LoadAll(true);
            foreach(var siteNumber in allowedSites)
            {
                Site site = siteList.FirstOrDefault(s => s.Number == siteNumber);
                if (site != null)
                {
                    ListItem li = new ListItem(site.ToString(), site.Number.ToString());
                    if (settings != null) 
                        li.Selected = settings.Value.siteNumbers.Contains(site.Number);
                    else
                        li.Selected = sitesSelectedByDefault.Contains(site.Number);
                    cblSites.Items.Add(li);
                }
            }
        }
    }

    /// <summary>
    /// Called when ok button is clicked
    /// Validate the form.
    /// Returns selected values as JSONified WFMStockAccountSheetSettings
    /// </summary>
    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        if (Validate())
        {
            WFMStockAccountSheetSettings settings = new WFMStockAccountSheetSettings();
            settings.sheetID     = Guid.NewGuid();
            settings.startDate   = DateTimeExtensions.Min(dtStartDate.Value.Value, dtEndDate.Value.Value);
            settings.endDate     = DateTimeExtensions.Max(dtStartDate.Value.Value, dtEndDate.Value.Value);
            settings.siteNumbers = cblSites.Items.Cast<ListItem>().Where(s => s.Selected).Select(s => int.Parse(s.Value)).ToList();

            if (WFMSettings.General.TestingMode)
                settings.endDate = settings.endDate.AddSeconds(59); // Add end of minute

            // Convert setting to JSON string
            string json = JsonConvert.SerializeObject(settings);

            // Save to DB
            PharmacyDataCache.SaveToDBSession("FMAddStockAccountSettings", json);

            // Return to client
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseForm", string.Format("window.returnValue='{0}'; window.close();", json), true);
        }
    }
    
    /// <summary>
    /// Called when check all button is clicked
    /// Checks all sites in list
    /// </summary>
    protected void btnCheckAll_OnClick(object sender, EventArgs e)
    {
        foreach (var site in cblSites.Items.Cast<ListItem>())
            site.Selected = true;
    }

    /// <summary>
    /// Called when uncheck all button is clicked
    /// Unchecks all sites in list
    /// </summary>
    protected void btnUncheckAll_OnClick(object sender, EventArgs e)
    {
        foreach (var site in cblSites.Items.Cast<ListItem>())
            site.Selected = false;
    }

    /// <summary>
    /// Called when warning message box ok button is clicked 
    /// Closes the from
    /// </summary>
    protected void btnMessageBox_OkClick(object sender, EventArgs e)
    {
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "closeFrom", "window.close();", true);
    }

    /// <summary>Validates the from</summary>
    /// <returns>If all data is valid</returns>
    protected bool Validate()
    {
        bool ok = true;
        string error;
        
        DateTime startDate = WFMDailyStockLevel.GetEarliestValidDate().Value;
        DateTime endDate   = WFMSettings.General.TestingUpdateTimeMode ? DateTime.Now.AddDays(1).ToEndOfDay() : DateTimeExtensions.Max(startDate, WFMDailyStockLevel.GetLastDate().Value).ToEndOfDay();

        // Start Date
        if (!Validation.ValidateDateTime(dtStartDate, "Start date", true, startDate, endDate, out error))
            ok = false;
        dtStartDate.ErrorMessage = error;

        // End Date
        if (!Validation.ValidateDateTime(dtEndDate, "End date", true, startDate, endDate, out error))
            ok = false;
        dtEndDate.ErrorMessage = error;
    
        // Check 1 site is selected from the list
        if (!this.cblSites.Items.Cast<ListItem>().Where(s => s.Selected).Any())
        {
            lbSiteError.Text = "Select a site from the list";
            ok = false;
        }
        else
            lbSiteError.Text = string.Empty;

        return ok;
    }
}