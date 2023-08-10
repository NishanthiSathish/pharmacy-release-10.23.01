//===========================================================================
//
//						        FMAddGRNISheet.aspx
//
//  Allows user to select up to date, and sites, to used to create a GRNI
//
//  Page will return the data in a JSONified FMAddGrniSettings structure
//  This is also saved to settings cache (so remembers users last chosen settings)
//
//  Call the page with the follow parameters
//  SessionID - ICW session ID
//  
//  Usage:
//  FMAddGRNISheet.aspx?SessionID=123
//
//	Modification History:
//	15May13 XN  Written (27252) 
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

public partial class application_FinanceManager_FMAddGRNISheet : System.Web.UI.Page
{
    /// <summary>Name used to store setting to DB Session cache</summary>
    private static readonly string SettingCacheName = "FMAddGrniSettings";

    protected void Page_Load(object sender, EventArgs e)
    {
        int sessionID  = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(sessionID);

        // As ICW control need to set cancel button manually
        btnCancel.Attributes.Add("onclick", "window.close(); return false;");

        if (!this.IsPostBack)
        {
            // Get previous settings from cache if present
            WFMGrniSettings? settings = null;
            string settingStr = PharmacyDataCache.GetFromDBSession(SettingCacheName);
            if (!string.IsNullOrEmpty(settingStr))
                settings = JsonConvert.DeserializeObject<WFMGrniSettings>(settingStr);

            // Check enough data to create a balance sheet
            DateTime? earliestDataDate = WFMLogCache.GetLatestDate();
            if (earliestDataDate == null || earliestDataDate > DateTime.Now)
            {
                mbInvalidData.Visible = true;
                return;
            }

            // Initialise upto date field
            // If test mode the always to current date time
            // if no previous setting then set to previous day
            // otherwise use previous settings
            if (WFMSettings.General.TestingMode)
                dtUpToDate.Value = DateTime.Now;
            else if (settings == null)
                dtUpToDate.Value = DateTime.Now.AddDays(-1);
            else
                dtUpToDate.Value = settings.Value.upToDate;

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
    /// Called when ok button is clicked
    /// Validate the form.
    /// Returns selected values as JSONified WFMStockAccountSheetSettings
    /// </summary>
    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        if (Validate())
        {
            WFMGrniSettings settings = new WFMGrniSettings();
            settings.sheetID     = Guid.NewGuid();
            settings.upToDate    = dtUpToDate.Value.Value.ToEndOfDay();
            settings.siteNumbers = cblSites.Items.Cast<ListItem>().Where(s => s.Selected).Select(s => int.Parse(s.Value)).ToList();

            // Convert setting to JSON string
            string json = JsonConvert.SerializeObject(settings);

            // Save to DB
            PharmacyDataCache.SaveToDBSession(SettingCacheName, json);

            // Return to client
            ScriptManager.RegisterStartupScript(this, this.GetType(), "CloseForm", string.Format("window.returnValue='{0}'; window.close();", json), true);
        }
    }

    /// <summary>
    /// Called when warning message box ok button is clicked 
    /// Closes the from
    /// </summary>
    protected void mbInvalidData_OkClick(object sender, EventArgs e)
    {
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "closeFrom", "window.close();", true);
    }

    /// <summary>Validates the from</summary>
    /// <returns>If all data is valid</returns>
    protected bool Validate()
    {
        bool ok = true;
        string error;
        
        DateTime startDate = DateTimeExtensions.Max(WFMLogCache.GetEarliestDate().Value, WFMSettings.GrniSheet.OpeningBalanceDate);
        DateTime endDate   = WFMSettings.General.TestingMode ? DateTime.Now.ToEndOfDay() : DateTime.Now.AddDays(-1).ToEndOfDay();

        // Up to date
        if (!Validation.ValidateDateTime(dtUpToDate, "Start date", true, startDate, endDate, out error))
            ok = false;
        dtUpToDate.ErrorMessage = error;

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
