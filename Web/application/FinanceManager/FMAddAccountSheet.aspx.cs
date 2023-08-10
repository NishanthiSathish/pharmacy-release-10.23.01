//===========================================================================
//
//						        FMAddAccountSheet.aspx
//
//  Allows user to select account code, start, end, and sites to used to create a sheet
//
//  Page will return the data in a JSONified WFMAccountSheetSettings structure
//  This is also saved to settings cache (so remembers users last chosen settings)
//
//  Call the page with the follow parameters
//  SessionID   - ICW session ID
//  
//  Usage:
//  FMAddAccountSheet.aspx?SessionID=123
//
//	Modification History:
//	15May13 XN  Written (73326) 
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;

public partial class application_FinanceManagerStockAccountSheet_FMAddAccountSheet : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        int sessionID  = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        // As ICW control need to set item manually
        btnCancel.Attributes.Add("onclick", "window.close(); return false;");

        if (!this.IsPostBack)
        {
            // Get previous settings from cache if present
            WFMAccountSheetSettings? settings = null;
            string settingStr = PharmacyDataCache.GetFromDBSession("FMAddAccountSettings");
            if (!string.IsNullOrEmpty(settingStr))
                settings = JsonConvert.DeserializeObject<WFMAccountSheetSettings>(settingStr);

            // Add account codes
            WFMAccountCode accountCodes = new WFMAccountCode();
            accountCodes.LoadAll();
            foreach (var accountCode in accountCodes.OrderBy(a => a.Code))
                lsAccountCode.Items.Add(new ListItem(accountCode.ToStringWithFormatting(false), accountCode.Code.ToString()));
            if (settings != null)
                lsAccountCode.SelectedIndex = lsAccountCode.Items.IndexOf(lsAccountCode.Items.FindByValue(settings.Value.accountCode.ToString()));

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
                dtEndDate.Value   = WFMDailyStockLevel.GetLastDate().ToEndOfDay();                                              // End of valid dates
            }
            else
            {
                dtStartDate.Value = settings.Value.startDate;   // From previous settings
                dtEndDate.Value   = settings.Value.endDate;
            }

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
    /// Returns selected values as JSONified WFMAccountSheetSettings
    /// </summary>
    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        if (Validate())
        {
            WFMAccountSheetSettings settings = new WFMAccountSheetSettings();
            settings.sheetID     = Guid.NewGuid();
            settings.accountCode = int.Parse(lsAccountCode.SelectedValue);
            settings.startDate   = DateTimeExtensions.Min(dtStartDate.Value.Value, dtEndDate.Value.Value);
            settings.endDate     = DateTimeExtensions.Max(dtStartDate.Value.Value, dtEndDate.Value.Value);
            settings.siteNumbers = cblSites.Items.Cast<ListItem>().Where(s => s.Selected).Select(s => int.Parse(s.Value)).ToList();

            if (WFMSettings.General.TestingMode)
                settings.endDate = settings.endDate.AddSeconds(59); // Add end of minute

            // Convert setting to JSON string
            string json = JsonConvert.SerializeObject(settings);

            // Save to DB
            PharmacyDataCache.SaveToDBSession("FMAddAccountSettings", json);

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
        DateTime endDate   = WFMSettings.General.TestingMode ? DateTime.Now : DateTimeExtensions.Max(startDate, WFMDailyStockLevel.GetLastDate().Value).ToEndOfDay();

        // Account code
        if (!Validation.ValidateList(lsAccountCode, "Account Code", true, out error))
            ok = false;
        lsAccountCode.ErrorMessage = error;

        // Start Date
        if (!Validation.ValidateDateTime(dtStartDate, "Start date", true, startDate, endDate, out error))
            ok = false;
        dtStartDate.ErrorMessage = error;

        // End Date
        if (!Validation.ValidateDateTime(dtEndDate, "End date", true, startDate, endDate, out error))
            ok = false;
        dtEndDate.ErrorMessage = error;

        // Check date range is not too large        
        if (ok)
        {
            int dateRangeLimitInMonths = WFMSettings.AccountSheet.DateRangeLimitInMonths;
            DateTime minDate = DateTimeExtensions.Min(dtStartDate.Value.Value, dtEndDate.Value.Value).ToStartOfDay();
            DateTime maxDate = DateTimeExtensions.Max(dtStartDate.Value.Value, dtEndDate.Value.Value).ToStartOfDay();
            if (maxDate > minDate.AddMonths(dateRangeLimitInMonths))
            {
                ok = false;
                dtEndDate.ErrorMessage = string.Format("Limited to {0} months ({1}) from start date", dateRangeLimitInMonths, minDate.AddMonths(dateRangeLimitInMonths).ToPharmacyDateString());
            }
        }
    
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