//==============================================================================================
//
//      					    ReferenceDataEditor.aspx.cs
//
//  Data editor for pharamcy reference data desktop.
//  Allows adding or editing of Wlookup data (site specific WLookup only NOT dss lookups)
//  Adding still expects the new WLookup code to be passed in as user cannot enter this
//
//  When adding will add the code to all sites in the DB (not just the selected site).
//  For language specific updats will use country code for the AscribeSiteNumber (not the EditingSiteNumber)
//
//  Though blank codes are not allowed they can be in the db 
//  If user tries to edit an item with a blank code the code will be updated with !_ (mimicks what vb6 does)
//  Adding using !_ will cause issues (but not a common issue)
//
//  The Value field of the WLookup data can vary in size, and textbox style (single or multi line) depending on context
//
//  The value field does not allow " these are conveterd to ' (only added as this is what vb6 version does)
//
//  The page expexct the following parameters
//  SessionID           - session ID
//  AscribeSiteNumber   - Main ascribe site number for the desktop (not the site being edited)
//  AddMode             - if adding or editing
//  Code                - Code to edit (required even if adding)
//  EditableSiteNumbers - CSV list of other sites the user can edit (for adding only)
//  EditingSiteNumber   - Site number of site being edited added
//
//	Modification History:
//	23Apr14 XN  Written
//  23Feb15 XN  Moved heaps from report dll, to row classes
//  01Jun16 XN  154372 changed printing to use AscribePrintJob
//==============================================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.reportlayer;
using Ascribe.Core.Controls;
using System.Web.UI.WebControls;
using System.IO;

public partial class application_PharmacyReferenceData_ReferenceDataEditor : System.Web.UI.Page
{
    #region Constants
    private const int MaxLinesInValueBox = 30;
    #endregion

    #region Variables
    /// <summary>If in add mode (else edit mode)</summary>
    protected bool addMode;

    /// <summary>Code being edited (null for add mode)</summary>
    protected string code;
    
    /// <summary>ID of site being edited</summary>
    protected int editingSiteID;

    /// <summary>Context being edited</summary>
    protected WLookupContextType wlookupContextType;

    /// <summary>List sites being edited in desktop (only for add mode)</summary>
    protected IEnumerable<int> editableSites;

    /// <summary>Height of from depends on context</summary>
    protected int height;

    /// <summary>If read-only mode</summary>
    protected bool readOnly;
    
    /// <summary>Application path to for the icw client (used by the print job) 01Jun16 XN  154372 added</summary>
    protected string applicationPath;
    #endregion

    #region Event handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(Request, Response);

        // Load parameters
        addMode             = BoolExtensions.PharmacyParse(Request["AddMode"]);
        code                = Request["Code"];
        editableSites       = (Request["EditableSiteNumbers"] ?? string.Empty).ParseCSV<int>(",", true);
        wlookupContextType  = ConvertExtensions.ChangeType<WLookupContextType>(Request["WLookupContextType"]);
        readOnly            = BoolExtensions.PharmacyParse(Request["ReadOnly"] ?? "Y");
        applicationPath     = Request["ApplicationPath"];   // 01Jun16 XN  154372 added

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
        {
            this.Save();
            this.ClosePage(tbCode.RawValue);
        }
    }

    protected void btnPrint_OnClick(object sender, EventArgs e)
    {
        PharmacyRTFReportRow pharmacyRTFReport = PharmacyRTFReport.GetByNameAndSiteID("FFLABEL", SessionInfo.SiteID);
        var rtf = "";
        if (pharmacyRTFReport != null)
            rtf = pharmacyRTFReport.Report;

        if (!string.IsNullOrEmpty(rtf))
        {
            hfRTF.Value = rtf;
            mbPrintNumberOfLabels.Visible = true;
        }
        else
        {
            throw new ApplicationException("Missing free format label RTF");
        }
    }

    /// <summary>
    /// Called when print number of label ok button is clicked
    /// Will parse and print the report
    /// 01Jun16 XN 154372 Updated to use the AscribePrintJob
    /// </summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void mbPrintNumberOfLabels_OnOkClicked(object sender, EventArgs e)
    {
        if (string.IsNullOrWhiteSpace(this.applicationPath))
            throw new ApplicationException("Desktop parameter ApplicationPath not set.");   // 01Jun16 XN  154372 added

        string error;
        if (Validation.ValidateText(numNumberOrLabels, string.Empty, typeof(int), true, 1, 999, out error))
        {
            WLookup lookup = new WLookup();
            lookup.Add();
            lookup[0].Code = tbCode.RawValue;
            lookup[0].Value= GetValueTextBoxRawValue();

            // Parse the report XML
            RTFParser parser = new RTFParser();
            parser.Read(hfRTF.Value);
            parser.ParseXML(lookup[0].ToXMLHeap());

            hfRTF.Value = parser.ToString();

            string script = string.Format("print({0}, {1}, JavaStringUnescape('{2}'), {3});", SessionInfo.SessionID, SessionInfo.SiteID, this.applicationPath.JavaStringEscape("'"), numNumberOrLabels.Value);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Print", script, true); 
        }
        numNumberOrLabels.ErrorMessage = error;
    }
    #endregion

    #region Private Methods
    /// <summary>Populate the page data</summary>
    private void Populate()
    {
        WLookupColumnInfo columInfo = WLookup.GetColumnInfo();
        
        // load the exist value
        WLookup wlookup = new WLookup();
        if (!addMode)
            wlookup.LoadByCodeSiteContextAndCountryCode(code, editingSiteID, wlookupContextType, true, PharmacyCultureInfo.CountryCode);

        // Set page title
        this.Title = addMode ? "Adding " : "Editing ";
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
        tbCode.Value         = string.IsNullOrEmpty(code) ? "!_" : code;    // Replace blank with !_ is so mimick vb6

        // if need ruler
        divRuler.Visible = (this.wlookupContextType == WLookupContextType.Warning) || (this.wlookupContextType == WLookupContextType.FFLabels);

        // Set value
        int rows = Math.Min(columInfo.GetValueMaxNumberOfLines(wlookupContextType), MaxLinesInValueBox);
        if (rows == 1)
        {
            tbValueShort.Visible         = true;
            tbValueShort.MaxCharacters   = columInfo.GetValueLength(wlookupContextType);             // does not seem to do anything but filled in anyway
            tbValueShort.Value           = wlookup.Select(c => c.Value).FirstOrDefault();
            tbValueShort.Value           = tbValueShort.Value.Replace("\r\r", "\r");  // Oddity with DSS data as seems to have \r\r\n entry which causes issues
            tbValueShort.ReadOnly        = readOnly;
            container.ControlToFocusId   = tbValueShort.ID;
        }
        else
        {
            tbValueLong.Visible         = true;
            tbValueLong.MaxCharacters   = columInfo.GetValueLength(wlookupContextType);             // does not seem to do anything but filled in anyway
            tbValueLong.Rows            = Math.Min(columInfo.GetValueMaxNumberOfLines(wlookupContextType), MaxLinesInValueBox);
            tbValueLong.Value           = wlookup.Select(c => c.Value).FirstOrDefault();
            tbValueLong.Value           = tbValueLong.Value.Replace("\r\r", "\r");  // Oddity with DSS data as seems to have \r\r\n entry which causes issues
            tbValueLong.ReadOnly        = readOnly;

            frmMain.CaptionZoneWidthPc      = 16;
            frmMain.ControlZoneWidthPc      = readOnly ? 84 : 71;
            frmMain.MandatoryZoneWidthPc    = readOnly ?  0 :  2;
            frmMain.ErrorMessageZoneWidthPc = readOnly ?  0 : 11;
            frmMain.RadioButtonZoneWidthPc  = 0;

            container.ControlToFocusId  = tbValueLong.ID;
        }
        this.height = 180 + rows * 15;  // basic height + rows * lines per row

        this.lbLocalCodeWarning.Visible = WLookup.IsDSSMaintained(wlookupContextType) && WLookup.IfDSSExists(editingSiteID, code, wlookupContextType, PharmacyCultureInfo.CountryCode);

        // set cancel event
        btnCancel.Visible = !readOnly;
        if (readOnly)
            btnOK.Attributes["onclick"]     = "window.close();";
        else
            btnCancel.Attributes["onclick"] = "window.close();";
    }

    /// <summary>Validates the data</summary>
    private bool Validate()
    {
        WLookupColumnInfo columInfo = WLookup.GetColumnInfo();
        string error = string.Empty;
        bool   OK    = true;

        // Value
        if (!Validation.ValidateText(GetValueTextBox(), string.Empty, typeof(string), true, columInfo.GetValueLength(wlookupContextType), out error))
            OK = false;
        else if (GetValueTextBoxRawValue().Count(c => c == '\n') >= columInfo.GetValueMaxNumberOfLines(wlookupContextType))
        {
            // Excedded max number of lines
            error = "Limited to " + columInfo.GetValueMaxNumberOfLines(wlookupContextType).ToString() + " lines";
            OK = false;
        }
        else if (GetValueTextBoxRawValue().Any(c => c == '"'))
        {
            // Can't have (") though these are changed to ' when user types value
            error = "Cannot use \" character";
            OK = false;
        }
        GetValueTextBox().ErrorMessage = error;

        return OK;
    }

    /// <summary>Saves to the DB</summary>
    private void Save()
    {
        WLookup wlookup = new WLookup();

        if (addMode)
        {
            // In add mode add to all sites

            // Load existing (so don't add twice)
            wlookup.LoadByCodeContextAndCountryCode(tbCode.RawValue, wlookupContextType, null, PharmacyCultureInfo.CountryCode);

            // get list of site IDs
            Sites sites = new Sites();
            sites.LoadAll(true);
            
            foreach (var siteID in sites.Select(s => s.SiteID))
            {
                WLookupRow row = wlookup.FirstOrDefault(l => l.SiteID == siteID);
                if (row == null)
                {
                    row = wlookup.Add();
                    row.SiteID           = siteID;
                    row.WLookupContextID = WLookup.GetWLookupContextID(wlookupContextType, false, PharmacyCultureInfo.CountryCode);
                    row.Code             = tbCode.RawValue.ToUpper();
                    row.InUse            = true;
                    row.Value            = GetValueTextBoxRawValue();
                }
                else if (row.InUse == false)
                {
                    row.InUse = true;
                    row.Value = GetValueTextBoxRawValue();
                }
            }
        }
        else
        {
            // Edit mode so load and edit (or add if not present)
            wlookup.LoadByCodeSiteContextAndCountryCode(code, editingSiteID, wlookupContextType, null, PharmacyCultureInfo.CountryCode);
            if (!wlookup.Any())
            {
                wlookup.Add();
                wlookup[0].Code             = code;
                wlookup[0].SiteID           = editingSiteID;
                wlookup[0].WLookupContextID = WLookup.GetWLookupContextID(wlookupContextType, false, PharmacyCultureInfo.CountryCode);
                wlookup[0].Code             = tbCode.RawValue.ToUpper();
            }
            wlookup[0].InUse = true;
            wlookup[0].Code  = tbCode.RawValue; // May of updated if changed blank to !_ (mimick vb6)
            wlookup[0].Value = GetValueTextBoxRawValue();
        }

        // And save
        wlookup.Save();
    }

    private ControlBase GetValueTextBox()
    {
        return tbValueShort.Visible ? (tbValueShort as ControlBase) : (tbValueLong as ControlBase);
    }

    private string GetValueTextBoxRawValue()
    {
        return tbValueShort.Visible ? tbValueShort.RawValue : tbValueLong.RawValue;
    }
    #endregion
}