//==============================================================================================
//
//      					        AddNewCode.aspx.cs
//
//  Allows user to enter new code value.
//  This is validated agains WLookup to see if it exists (user can add if does not exist on all sites)
//
//  The page expexct the following parameters
//  SessionID           - session ID
//  AscribeSiteNumber   - Main ascribe site number for the desktop (not the site being edited)
//  EditableSiteNumbers - CSV list of other sites the user can edit (for adding only)
//  EditingSiteNumber   - Site number of site being edited added
//
//	Modification History:
//	23Apr14 XN  Written
//==============================================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacyReferenceData_AddNewCode : System.Web.UI.Page
{
    #region Variables
    /// <summary>ID of site being edited</summary>
    protected int editingSiteID;

    /// <summary>Context being edited</summary>
    protected WLookupContextType wlookupContextType;

    /// <summary>List sites being edited in desktop (only for add mode)</summary>
    protected IEnumerable<int> editableSites;
    #endregion

    #region Event handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(Request, Response);

        // Load parameters
        editableSites       = (Request["EditableSiteNumbers"] ?? string.Empty).ParseCSV<int>(",", true);
        wlookupContextType  = ConvertExtensions.ChangeType<WLookupContextType>(Request["WLookupContextType"]);

        if (string.IsNullOrEmpty(Request["EditingSiteNumber"]))
            editingSiteID = SessionInfo.SiteID;
        else
            editingSiteID = Sites.GetSiteIDByNumber(int.Parse(Request["EditingSiteNumber"]));

        if (this.IsPostBack)
            this.LoadAscribeCoreControlsToViewState();  // Load manually cached ascribe core controls extra data
        else
        {
            Populate();
            Page.Header.DataBind();
            this.SaveAscribeCoreControlsToViewState();  // Save manually cached ascribe core controls extra data
        }

    }

    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        if (Validate())
            this.ClosePage(tbCode.RawValue.ToUpper());
    }
    
    /// <summary>
    /// Called when messag box "Exists on Other sites" Ok button is clicked
    /// Save data and closes page
    /// </summary>
    protected void mbExistsOnOtherSites_OnOkClicked(object sender, EventArgs e)
    {
        this.ClosePage(tbCode.RawValue.ToUpper());
    }
    #endregion

    #region Private Methods
    /// <summary>Populate the page data</summary>
    private void Populate()
    {
        WLookupColumnInfo columInfo = WLookup.GetColumnInfo();
        
        // Set page title
        switch (wlookupContextType)
        {
        case WLookupContextType.Warning:     this.Title += "Warning";               break;
        case WLookupContextType.Instruction: this.Title += "Instruction";           break;
        case WLookupContextType.UserMsg:     this.Title += "Drug Message Code";     break;
        case WLookupContextType.FFLabels:    this.Title += "Free Format Label";     break;
        case WLookupContextType.Reason:      this.Title += "Finance reason code";   break;
        default: this.Title += " " + wlookupContextType.ToString();                 break;
        }

        // Set code
        tbCode.MaxCharacters = columInfo.GetCodeLength(wlookupContextType);

        // set cancel event
        btnCancel.Attributes["onclick"] = "window.close();";
    }

    /// <summary>Validates the data</summary>
    private bool Validate()
    {
        WLookupColumnInfo columInfo = WLookup.GetColumnInfo();
        string error = string.Empty;
        bool   OK    = true;

        // Code
        if (!Validation.ValidateText(tbCode, string.Empty, typeof(string), true, columInfo.GetCodeLength(wlookupContextType), out error))
            OK = false; 
        else
        {
            Sites sites = new Sites();
            sites.LoadAll(true);

            WLookup lookup = new WLookup();
            lookup.LoadByCodeContextAndCountryCode(tbCode.RawValue, wlookupContextType, true, PharmacyCultureInfo.CountryCode);

            var siteAlreadyExistsOn = sites.FindSiteNumberByID(lookup.Select(s => s.SiteID)).Distinct().ToList();
                
            if (siteAlreadyExistsOn.Count == sites.Count)
            {
                // Check if already exists in the main desktop (for one of the other sites)
                error = "Already exists for all sites";
                OK = false;
            }
            else if (siteAlreadyExistsOn.Any())
            {
                // Notify user that it will be saved to all sites (except the sites that already have code and don't exist in the desktop)
                mbExistsOnOtherSites.Visible    = true;
                divExistsOnOtherSites.InnerHtml = siteAlreadyExistsOn.Select(s => s.ToString("000")).ToCSVString("<br />");
                OK = false;
            }
        }
        tbCode.ErrorMessage = error;

        return OK;
    }
    #endregion
}