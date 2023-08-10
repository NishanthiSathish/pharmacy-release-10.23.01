//===========================================================================
//
//						           Settings.aspx.cs
//
//  Displays a list of PN default settings.
//  These are read and written to the WCOnfiguration table.
//  The settings are divided into two modes, adult, and peadiatric 
//  same settings for both.
//
//  Call the page with the follow parameters
//  SessionID                   - ICW session ID
//  SiteID                      - site ID
//  DataType                    - Data type to display (one of adult, paediatric)
//  ReplicateToSiteNumbers      - Sites allowed to replicate to (optional)
//  SiteNumbersSelectedByDefault- Replicate to sites selected by default (optional)
//  
//  Usage:
//  Settings.aspx?SessionID=123&SiteID=24&DataType=Adult
//
//	Modification History:
//	20Oct11 XN  Written
//  28Jan14 XN  Moved client to jquery 1.6.4 due to changes in pharmacyscript.js
//  26Oct15 XN  106278 Made it a multi site editor
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;
using System.Text;
using System.Web.UI.WebControls;

public partial class application_PNSettings_Settings : System.Web.UI.Page
{
    #region Member Variables
    /// <summary>List of sites that are allowed for replication 26Oc15 XN 106278</summary>
    private List<Site2Row> replicateToSites;

    /// <summary>List of sites selected by default for replication 26Oc15 XN 106278</summary>
    private List<int> siteNumbersSelectedByDefault; 

    /// <summary>If in multi site edit mode 26Oc15 XN 106278</summary>
    private bool isMultiSiteEditMode;

    /// <summary>Form data type</summary>
    private AgeRangeType dataType;
    #endregion

    #region Event handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        // Read query string
        this.replicateToSites             = Site2.Instance().FindBySiteNumber(this.Request["ReplicateToSiteNumbers"], true, CurrentSiteHandling.AtStart).ToList();
        this.siteNumbersSelectedByDefault = replicateToSites.FindBySiteNumber(this.Request["SiteNumbersSelectedByDefault"], allowAll: true).Select(s => s.SiteNumber).ToList();
        this.isMultiSiteEditMode          = this.replicateToSites.Count > 1;
        switch (Request["DataType"].ToLower())
        {
        case "adult":       dataType = AgeRangeType.Adult;      break;
        case "paediatric":  dataType = AgeRangeType.Paediatric; break;
        default: throw new ApplicationException("Invalid data type");
        }

        if (!Page.IsPostBack)
        {
            // Update site lists (26Oc15 XN 106278)
            this.PopulateSiteList();
            this.UpdateReplicateToSiteList();

            // Write entering into this screen into audit log
            PNLog.WriteToLog(SessionInfo.SiteID, "User is viewing PN " + dataType + " default settings\n" + lbtSites.Text);

            // If first load then read in all the settings
            cbSeparateAminoAndFatLabels.Checked     = PNSettings.Defaults.GetSeparateAqueousAndLipidLabels(dataType);
            cbCalcDripRateMlPerHour.Checked         = PNSettings.Defaults.GetCalcDripRatemlPerHour(dataType);
            cbBaxaPump.Checked                      = PNSettings.Defaults.GetBaxaCompounderInUse(dataType);
            cbIssueEnabled.Checked                  = PNSettings.Defaults.GetIssueEnabled(dataType);
            cbReturnEnabled.Checked                 = PNSettings.Defaults.GetReturnEnabled(dataType);

            tbAqueousOverageVolume.Text             = PNSettings.Defaults.GetOverageVolumeInml          (dataType, PNProductType.Aqueous).ToString();
            tbAqueousExpiry.Text                    = PNSettings.Defaults.GetExpiryInDays               (dataType, PNProductType.Aqueous).ToString();
            tbAqueousNumberOfLabels.Text            = PNSettings.Defaults.GetNumberOfLabels             (dataType, PNProductType.Aqueous).ToString();
            tbAqueousInfusionDurationInHours.Text   = PNSettings.Defaults.GetInfusionDurationInHours    (dataType, PNProductType.Aqueous).ToString();
            tbLipidOverageVolume.Text               = PNSettings.Defaults.GetOverageVolumeInml          (dataType, PNProductType.Lipid  ).ToString();
            tbLipidExpiry.Text                      = PNSettings.Defaults.GetExpiryInDays               (dataType, PNProductType.Lipid  ).ToString();
            tbLipidNumberOfLabels.Text              = PNSettings.Defaults.GetNumberOfLabels             (dataType, PNProductType.Lipid  ).ToString();
            tbLipidInfusionDurationInHours.Text     = PNSettings.Defaults.GetInfusionDurationInHours    (dataType, PNProductType.Lipid  ).ToString();
            tbMixedOverageVolume.Text               = PNSettings.Defaults.GetOverageVolumeInml          (dataType, PNProductType.Combined  ).ToString();
            tbMixedExpiry.Text                      = PNSettings.Defaults.GetExpiryInDays               (dataType, PNProductType.Combined  ).ToString();
            tbMixedNumberOfLabels.Text              = PNSettings.Defaults.GetNumberOfLabels             (dataType, PNProductType.Combined  ).ToString();
            tbMixedInfusionDurationInHours.Text     = PNSettings.Defaults.GetInfusionDurationInHours    (dataType, PNProductType.Combined  ).ToString();

        }
    }

    /// <summary>PreRender used to handle event args so dynamic controls have time to be populated</summary>
    protected override void OnPreRender(EventArgs e)
    {
        // Deal with __postBack events
        string   args      = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        if (argParams.Length > 0)
        {
            switch (argParams[0])
            {
            case "PrintSite":
                // Print the data for the site
                int siteId = int.Parse(argParams[1]);
                this.Print(siteId);
                break;

            case "SelectedNewSites":    
                // When used selects new set of sites updates the site list
                UpdateReplicateToSiteList();

                // Update state to log
                PNLog.WriteToLog(SessionInfo.SiteID, "Updated PN " + dataType + " default settings replication state\n" + lbtSites.Text);
                break;

            case "Save":
                this.Save();
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Saved", "clearIsPageDirty();", true);
                break;
            }
        }
    }

    /// <summary>
    /// Called when the save button is clicked
    /// Validates, displays difference (in multi site mode), and saves a product
    /// 27Oct15 XN 106278 add display difference for multi site editor
    /// </summary>
    protected void btnSave_OnClick(object sender, EventArgs e)
    {
        if (this.Validate() && !this.DisplayDifferences())
        {
            this.Save();
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Saved", "clearIsPageDirty(); alert('Settings have been saved.');", true);
        }
    }
    
    /// <summary>
    /// Called when print button is clicked.
    /// Generates XML to use with the report, and saves it to the session attribute
    /// Uses report 'Pharmacy Print Form Report {sitenumber}'
    /// 27Oct15 XN 106278 If multi site editor then display popup box to allow selection of site
    /// </summary>
    protected void Print_Click(object sender, EventArgs e)
    {
        if (this.isMultiSiteEditMode)
        {
            // Populate site list
            gridSites.AddColumn("Site", 100);
            foreach (var site in this.replicateToSites)
            {
                gridSites.AddRow();
                gridSites.AddRowAttribute("SiteID", site.SiteID.ToString());
                gridSites.SetCell(0, site.ToString());
            }
            gridSites.SelectRow(0);

            // Display site list
            ScriptManager.RegisterStartupScript(this, this.GetType(), "showSitesToPrint", "showSitesToPrint();", true);
        }
        else
        {
            this.Print(SessionInfo.SiteID);
        }
    }
    #endregion

    #region Private Methods
    /// <summary>Validates the form data</summary>
    /// <returns>If the data is valid</returns>
    private bool Validate()
    {
        bool ok = true;
        string error = string.Empty;

        ok = ok && Validation.ValidateText(tbAqueousOverageVolume,           "Aqueous Overage Volume",      typeof(int), true, 0, 999, out error);
        ok = ok && Validation.ValidateText(tbLipidOverageVolume,             "Lipid Overage Volume",        typeof(int), true, 0, 999, out error);
        ok = ok && Validation.ValidateText(tbMixedOverageVolume,             "Mixed Overage Volume",        typeof(int), true, 0, 999, out error);
        ok = ok && Validation.ValidateText(tbAqueousExpiry,                  "Aqueous Expiry",              typeof(int), true, 0, 99,  out error);
        ok = ok && Validation.ValidateText(tbLipidExpiry,                    "Lipid Expiry",                typeof(int), true, 0, 99,  out error);
        ok = ok && Validation.ValidateText(tbMixedExpiry,                    "Mixed Expiry",                typeof(int), true, 0, 99,  out error);
        ok = ok && Validation.ValidateText(tbAqueousNumberOfLabels,          "Aqueous Number of Labels",    typeof(int), true, 0, 9,   out error);
        ok = ok && Validation.ValidateText(tbLipidNumberOfLabels,            "Lipid Number of Labels",      typeof(int), true, 0, 9,   out error);
        ok = ok && Validation.ValidateText(tbMixedNumberOfLabels,            "Mixed Number of Labels",      typeof(int), true, 0, 9,   out error);
        ok = ok && Validation.ValidateText(tbAqueousInfusionDurationInHours, "Aqueous Infusion Duration",   typeof(int), true, 0, 99,  out error);
        ok = ok && Validation.ValidateText(tbLipidInfusionDurationInHours,   "Lipid Infusion Duration",     typeof(int), true, 0, 99,  out error);
        ok = ok && Validation.ValidateText(tbMixedInfusionDurationInHours,   "Mixed Infusion Duration",     typeof(int), true, 0, 99,  out error);

        lbError.Text = string.IsNullOrEmpty(error) ? "&nbsp;" : error;

        return ok;
    }


    /// <summary>
    /// If multi site mode, and not adding, will display all the difference, and ask if the form should be saved
    /// 26Oct15 XN 106278
    /// </summary>
    /// <returns>If difference form is displayed</returns>
    private bool DisplayDifferences()
    {
        // If adding or not in multi site mode then returned
        if (!this.isMultiSiteEditMode)
        {
            return false;
        }

        QSDifferencesList differences = new QSDifferencesList();
        
        // Compare product values
        this.CompareValues(differences, s => PNSettings.Defaults.GetSeparateAqueousAndLipidLabels(dataType,                        s).ToYesNoString(), cbSeparateAminoAndFatLabels.Checked.ToYesNoString(), "Separate labels"           );
        this.CompareValues(differences, s => PNSettings.Defaults.GetCalcDripRatemlPerHour        (dataType,                        s).ToYesNoString(), cbCalcDripRateMlPerHour.Checked.ToYesNoString(),     "Drip rate as ml/hr"        );
        this.CompareValues(differences, s => PNSettings.Defaults.GetBaxaCompounderInUse          (dataType,                        s).ToYesNoString(), cbBaxaPump.Checked.ToYesNoString(),                  "Baxa Compounder"           );
        this.CompareValues(differences, s => PNSettings.Defaults.GetIssueEnabled                 (dataType,                        s).ToYesNoString(), cbIssueEnabled.Checked.ToYesNoString(),              "Allow issuing"             );
        this.CompareValues(differences, s => PNSettings.Defaults.GetReturnEnabled                (dataType,                        s).ToYesNoString(), cbReturnEnabled.Checked.ToYesNoString(),             "Allow returning"           );
        this.CompareValues(differences, s => PNSettings.Defaults.GetOverageVolumeInml            (dataType, PNProductType.Aqueous, s).ToString(),      tbAqueousOverageVolume.Text,                         "Aqueous Overage Volume"    );
        this.CompareValues(differences, s => PNSettings.Defaults.GetExpiryInDays                 (dataType, PNProductType.Aqueous, s).ToString(),      tbAqueousExpiry.Text,                                "Aqueous Expiry"            );
        this.CompareValues(differences, s => PNSettings.Defaults.GetNumberOfLabels               (dataType, PNProductType.Aqueous, s).ToString(),      tbAqueousNumberOfLabels.Text,                        "Aqueous Number of Labels"  );
        this.CompareValues(differences, s => PNSettings.Defaults.GetInfusionDurationInHours      (dataType, PNProductType.Aqueous, s).ToString(),      tbAqueousInfusionDurationInHours.Text,               "Aqueous Infusion Duration" );
        this.CompareValues(differences, s => PNSettings.Defaults.GetOverageVolumeInml            (dataType, PNProductType.Lipid,   s).ToString(),      tbLipidOverageVolume.Text,                           "Lipid Overage Volume"      );
        this.CompareValues(differences, s => PNSettings.Defaults.GetExpiryInDays                 (dataType, PNProductType.Lipid,   s).ToString(),      tbLipidExpiry.Text,                                  "Lipid Expiry"              );
        this.CompareValues(differences, s => PNSettings.Defaults.GetNumberOfLabels               (dataType, PNProductType.Lipid,   s).ToString(),      tbLipidNumberOfLabels.Text,                          "Lipid Number of Labels"    );
        this.CompareValues(differences, s => PNSettings.Defaults.GetInfusionDurationInHours      (dataType, PNProductType.Lipid,   s).ToString(),      tbLipidInfusionDurationInHours.Text,                 "Lipid Infusion Duration"   );
        this.CompareValues(differences, s => PNSettings.Defaults.GetOverageVolumeInml            (dataType, PNProductType.Combined,s).ToString(),      tbMixedOverageVolume.Text,                           "Mixed Overage Volume"      );
        this.CompareValues(differences, s => PNSettings.Defaults.GetExpiryInDays                 (dataType, PNProductType.Combined,s).ToString(),      tbMixedExpiry.Text,                                  "Mixed Expiry"              );
        this.CompareValues(differences, s => PNSettings.Defaults.GetNumberOfLabels               (dataType, PNProductType.Combined,s).ToString(),      tbMixedNumberOfLabels.Text,                          "Mixed Number of Labels"    );
        this.CompareValues(differences, s => PNSettings.Defaults.GetInfusionDurationInHours      (dataType, PNProductType.Combined,s).ToString(),      tbMixedInfusionDurationInHours.Text,                 "Mixed Infusion Duration"   );   
                                                                                                                                                       
        // Display any difference in a popup
        if (differences.Any())
        {
            string msg = string.Format("<div style='max-height:500px;overflow-y:scroll;overflow-x:hidden;'>{0}</div><br /><p>OK to save the changes?</p>", differences.ToHTML( Sites.GetDictonarySiteIDToNumber() ));
            string script = string.Format("confirmEnh(\"{0}\", true, function() {{ __doPostBack('{1}', 'Save') }}, undefined, '450px');", msg, upMain.ClientID);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
        }
        else
        {
            //string script = "confirmEnh(\"No changes have been made.<br /><br />Close the editor?\", true, function() {{ window.close(); }}, undefined, '450px');"; 155739 XN 14Jun16 made the error message better
            string script = "alertEnh(\"No changes have been made.\", undefined, '450px');";
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Info", script, true);
        }

        return true;
    }

    /// <summary>
    /// if was and now are different will add the item to differences
    /// Will only compare items that have been edited
    /// 26Oct15 XN 106278
    /// </summary>
    /// <param name="differences">List of differences</param>
    /// <param name="funcWas">function to get the existing values for each site</param>
    /// <param name="now">what the new value is</param>
    /// <param name="description">Control name</param>
    private void CompareValues(QSDifferencesList differences, Func<int,string> funcWas, string now, string description)
    {
        // If the item has been edited (different from what is in the DB)
        // Then log the difference, and check all other sites (if not different then don't compare other sites)
        if (funcWas.Invoke(SessionInfo.SiteID) != now)
        {
            // Check all sites
            foreach (var s in this.GetSelectedReplicateToSiteIds())
            {
                if (funcWas.Invoke(s) != now)
                {
                    differences.Add(s, description, now, funcWas.Invoke(s));
                }
            }
        }
    }

    /// <summary>
    /// Saves settings to the DB
    /// Also saves any changes made to the PN log
    /// 30Oct15 XN 106278 Update for muli site editor
    /// </summary>
    private void Save()
    {
        Dictionary<int,StringBuilder> auditLogPerSite = new Dictionary<int,StringBuilder>();
        bool orginalBool;
        bool newBool;
        int originalInt;
        int newInt;
        var selectedSiteIds = this.GetSelectedReplicateToSiteIds();

        // Create empty audit logs
        foreach (int s in selectedSiteIds)
        {
            auditLogPerSite[s] = new StringBuilder();
        }

        // Separate Amino And Fat Labels (save only if edited)
        orginalBool = PNSettings.Defaults.GetSeparateAqueousAndLipidLabels(this.dataType);
        newBool     = cbSeparateAminoAndFatLabels.Checked;
        if (orginalBool != newBool)
        {
            foreach (int s in selectedSiteIds)
            {
                orginalBool = PNSettings.Defaults.GetSeparateAqueousAndLipidLabels(this.dataType, s);
                if (orginalBool != newBool)
                {
                    auditLogPerSite[s].AppendFormat("Separate amino and lipid labels: from {0} to {1}\r\n", orginalBool.ToYesNoString(), newBool.ToYesNoString());
                    PNSettings.Defaults.SetSeparateAqueousAndLipidLabels(this.dataType, newBool, s);
                }
            }
        }

        // Calculate drip rate as ml/hr
        orginalBool = PNSettings.Defaults.GetCalcDripRatemlPerHour(this.dataType);
        newBool     = cbCalcDripRateMlPerHour.Checked;
        if (orginalBool != newBool)
        {
            foreach (int s in selectedSiteIds)
            {
                orginalBool = PNSettings.Defaults.GetCalcDripRatemlPerHour(this.dataType, s);
                if (orginalBool != newBool)
                {
                    auditLogPerSite[s].AppendFormat("Calculate drip rate as ml/hr : from {0} to {1}\r\n", orginalBool.ToYesNoString(), newBool.ToYesNoString());
                    PNSettings.Defaults.SetCalcDripRatemlPerHour(this.dataType, newBool, s);
                }
            }
        }

        // Issuing enabled
        orginalBool = PNSettings.Defaults.GetIssueEnabled(this.dataType);
        newBool     = cbIssueEnabled.Checked;
        if (orginalBool != newBool)
        {
            foreach (int s in selectedSiteIds)
            {
                orginalBool = PNSettings.Defaults.GetIssueEnabled(this.dataType, s);
                if (orginalBool != newBool)
                {
                    auditLogPerSite[s].AppendFormat("Issuing enabled: from {0} to {1}\r\n", orginalBool.ToYesNoString(), newBool.ToYesNoString());
                    PNSettings.Defaults.SetIssueEnabled(this.dataType, newBool, s);
                }
            }
        }

        // Returning enabled
        orginalBool = PNSettings.Defaults.GetReturnEnabled(this.dataType);
        newBool     = cbReturnEnabled.Checked;
        if (orginalBool != newBool)
        {
            foreach (int s in selectedSiteIds)
            {
                orginalBool = PNSettings.Defaults.GetReturnEnabled(this.dataType, s);
                if (orginalBool != newBool)
                {
                    auditLogPerSite[s].AppendFormat("Returning enabled: from {0} to {1}\r\n", orginalBool.ToYesNoString(), newBool.ToYesNoString());
                    PNSettings.Defaults.SetReturnEnabled(this.dataType, newBool, s);
                }
            }
        }

        // Baxa in use
        orginalBool = PNSettings.Defaults.GetBaxaCompounderInUse(this.dataType);
        newBool     = cbBaxaPump.Checked;
        if (orginalBool != newBool)
        {
            foreach (int s in selectedSiteIds)
            {
                orginalBool = PNSettings.Defaults.GetBaxaCompounderInUse(this.dataType, s);
                if (orginalBool != newBool)
                {
                    auditLogPerSite[s].AppendFormat("Baxa Compounder in use: from {0} to {1}\r\n", orginalBool.ToYesNoString(), newBool.ToYesNoString());
                    PNSettings.Defaults.SetBaxaCompounderInUse(this.dataType, newBool, s);
                }
            }
        }

        // Overage Volume (aqueous)
        originalInt = PNSettings.Defaults.GetOverageVolumeInml(this.dataType, PNProductType.Aqueous);
        newInt      = int.Parse(tbAqueousOverageVolume.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetOverageVolumeInml(this.dataType, PNProductType.Aqueous, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} overage volume (ml): from {2} to {3}\r\n", this.dataType, PNProductType.Aqueous, originalInt, newInt);
                    PNSettings.Defaults.SetOverageVolumeInml(this.dataType, PNProductType.Aqueous, newInt, s);
                }
            }
        }

        // Overage Volume (lipid)
        originalInt = PNSettings.Defaults.GetOverageVolumeInml(this.dataType, PNProductType.Lipid);
        newInt      = int.Parse(tbLipidOverageVolume.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetOverageVolumeInml(this.dataType, PNProductType.Lipid, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} overage volume (ml): from {2} to {3}\r\n", this.dataType, PNProductType.Lipid, originalInt, newInt);
                    PNSettings.Defaults.SetOverageVolumeInml(this.dataType, PNProductType.Lipid, newInt, s);
                }
            }
        }

        // Overage Volume (mixed)
        originalInt = PNSettings.Defaults.GetOverageVolumeInml(this.dataType, PNProductType.Combined);
        newInt      = int.Parse(tbMixedOverageVolume.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetOverageVolumeInml(this.dataType, PNProductType.Combined, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} overage volume (ml): from {2} to {3}\r\n", this.dataType, PNProductType.Combined, originalInt, newInt);
                    PNSettings.Defaults.SetOverageVolumeInml(this.dataType, PNProductType.Combined, newInt, s);
                }
            }
        }

        // Expiry in days (Aqueous)
        originalInt = PNSettings.Defaults.GetExpiryInDays(this.dataType, PNProductType.Aqueous);
        newInt      = int.Parse(tbAqueousExpiry.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetExpiryInDays(this.dataType, PNProductType.Aqueous, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} expiry in days: from {2} to {3}\r\n", this.dataType, PNProductType.Aqueous, originalInt, newInt);
                    PNSettings.Defaults.SetExpiryInDays(this.dataType, PNProductType.Aqueous, newInt, s);
                }
            }
        }

        // Expiry in days (Lipid)
        originalInt = PNSettings.Defaults.GetExpiryInDays(this.dataType, PNProductType.Lipid);
        newInt      = int.Parse(tbLipidExpiry.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetExpiryInDays(this.dataType, PNProductType.Lipid, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} expiry in days: from {2} to {3}\r\n", this.dataType, PNProductType.Lipid, originalInt, newInt);
                    PNSettings.Defaults.SetExpiryInDays(this.dataType, PNProductType.Lipid, newInt, s);
                }
            }
        }

        // Expiry in days (Mixed)
        originalInt = PNSettings.Defaults.GetExpiryInDays(this.dataType, PNProductType.Combined);
        newInt      = int.Parse(tbMixedExpiry.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetExpiryInDays(this.dataType, PNProductType.Combined, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} expiry in days: from {2} to {3}\r\n", this.dataType, PNProductType.Combined, originalInt, newInt);
                    PNSettings.Defaults.SetExpiryInDays(this.dataType, PNProductType.Combined, newInt, s);
                }
            }
        }

        // Number of labels (Aqueous)
        originalInt = PNSettings.Defaults.GetNumberOfLabels(this.dataType, PNProductType.Aqueous);
        newInt      = int.Parse(tbAqueousNumberOfLabels.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetNumberOfLabels(this.dataType, PNProductType.Aqueous, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} number of labels: from {2} to {3}\r\n", this.dataType, PNProductType.Aqueous, originalInt, newInt);
                    PNSettings.Defaults.SetNumberOfLabels(this.dataType, PNProductType.Aqueous, newInt, s);
                }
            }
        }

        // Number of labels (Lipid)
        originalInt = PNSettings.Defaults.GetNumberOfLabels(this.dataType, PNProductType.Lipid);
        newInt      = int.Parse(tbLipidNumberOfLabels.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetNumberOfLabels(this.dataType, PNProductType.Lipid, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} number of labels: from {2} to {3}\r\n", this.dataType, PNProductType.Lipid, originalInt, newInt);
                    PNSettings.Defaults.SetNumberOfLabels(this.dataType, PNProductType.Lipid, newInt, s);
                }
            }
        }

        // Number of labels (Mixed)
        originalInt = PNSettings.Defaults.GetNumberOfLabels(this.dataType, PNProductType.Combined);
        newInt      = int.Parse(tbMixedNumberOfLabels.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetNumberOfLabels(this.dataType, PNProductType.Combined, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} number of labels: from {2} to {3}\r\n", this.dataType, PNProductType.Combined, originalInt, newInt);
                    PNSettings.Defaults.SetNumberOfLabels(this.dataType, PNProductType.Combined, newInt, s);
                }
            }
        }

        // Duration of infusion (Aqueous)
        originalInt = PNSettings.Defaults.GetInfusionDurationInHours(this.dataType, PNProductType.Aqueous);
        newInt      = int.Parse(tbAqueousInfusionDurationInHours.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetInfusionDurationInHours(this.dataType, PNProductType.Aqueous, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} infusion duration: from {2} to {3}\r\n", this.dataType, PNProductType.Aqueous, originalInt, newInt);
                    PNSettings.Defaults.SetInfusionDurationInHours(this.dataType, PNProductType.Aqueous, newInt, s);
                }
            }
        }

        // Duration of infusion (Lipid)
        originalInt = PNSettings.Defaults.GetInfusionDurationInHours(this.dataType, PNProductType.Lipid);
        newInt      = int.Parse(tbLipidInfusionDurationInHours.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetInfusionDurationInHours(this.dataType, PNProductType.Lipid, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} infusion duration: from {2} to {3}\r\n", this.dataType, PNProductType.Lipid, originalInt, newInt);
                    PNSettings.Defaults.SetInfusionDurationInHours(this.dataType, PNProductType.Lipid, newInt, s);
                }
            }
        }

        // Duration of infusion (Mixed)
        originalInt = PNSettings.Defaults.GetInfusionDurationInHours(this.dataType, PNProductType.Combined);
        newInt      = int.Parse(tbMixedInfusionDurationInHours.Text);
        if (originalInt != newInt)
        {
            foreach (int s in selectedSiteIds)
            {
                originalInt = PNSettings.Defaults.GetInfusionDurationInHours(this.dataType, PNProductType.Combined, s);
                if (originalInt != newInt)
                {
                    auditLogPerSite[s].AppendFormat("{0} {1} infusion duration: from {2} to {3}\r\n", this.dataType, PNProductType.Combined, originalInt, newInt);
                    PNSettings.Defaults.SetInfusionDurationInHours(this.dataType, PNProductType.Combined, newInt, s);
                }
            }
        }

        // If any changes then write to log
        foreach(var al in auditLogPerSite)
        {
            StringBuilder auditLog = al.Value;
            if (auditLog.Length > 0)
            {
                auditLog.Insert(0, "The following changes were made to default settings\r\n");
                PNLog.WriteToLog(al.Key, auditLog.ToString());
            }
        }
    }
        
    /// <summary>
    /// Prints report for the site
    /// 27Oct15 XN 106278
    /// </summary>
    /// <param name="siteId">Site id</param>
    private void Print(int siteId)
    {
        ReportPrintForm report = new  ReportPrintForm();
        report.Initialise(string.Format("Emis Health PN {0} Defaults", dataType.ToString()), Site2.GetSiteNumberByID(siteId));

        // General section
        report.StartNewSection("General");
        report.AddValue(lbSeparateAminoAndFatLabels, cbSeparateAminoAndFatLabels );
        report.AddValue(lbCalcDripRateMlPerHour,     cbCalcDripRateMlPerHour     );
        report.AddValue(lbBaxaPump,                  cbBaxaPump                  );
        report.AddValue(lbIssueEnabled,              cbIssueEnabled              );
        report.AddValue(lbReturnEnabled,             cbReturnEnabled             );

        // Regimen Aqueous section
        report.StartNewSection("Regimen " + lbRegimenDefaultsAqueous.InnerText, true);
        report.AddValue(lbRegimenDefaultsOverage,           tbAqueousOverageVolume          );
        report.AddValue(lbRegimenDefaultsExpiry,            tbAqueousExpiry                 );
        report.AddValue(lbRegimenDefaultsNumberOfLabels,    tbAqueousNumberOfLabels         );
        report.AddValue(lbRegimenDefaultsInfusionDuration,  tbAqueousInfusionDurationInHours);

        // Regimen Lipid section
        report.StartNewSection("Regimen " + lbRegimenDefaultsLipid.InnerText, true);
        report.AddValue(lbRegimenDefaultsOverage,           tbLipidOverageVolume          );
        report.AddValue(lbRegimenDefaultsExpiry,            tbLipidExpiry                 );
        report.AddValue(lbRegimenDefaultsNumberOfLabels,    tbLipidNumberOfLabels         );
        report.AddValue(lbRegimenDefaultsInfusionDuration,  tbLipidInfusionDurationInHours);

        // Regimen Mixed section
        report.StartNewSection("Regimen " + lbRegimenDefaultsMixed.InnerText, true);
        report.AddValue(lbRegimenDefaultsOverage,           tbMixedOverageVolume          );
        report.AddValue(lbRegimenDefaultsExpiry,            tbMixedExpiry                 );
        report.AddValue(lbRegimenDefaultsNumberOfLabels,    tbMixedNumberOfLabels         );
        report.AddValue(lbRegimenDefaultsInfusionDuration,  tbMixedInfusionDurationInHours);

        // Save report xml to session attribute
        report.Save();

        // Register script to perform the print
        // XN 11Mar13 58517 Help testing if report does not exist
        string reportName = report.GetReportName();
        if (OrderReport.IfReportExists(reportName))
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", string.Format("window.opener.parent.ICWWindow().document.frames['fraPrintProcessor'].PrintReport({0}, '{1}', 0, false, '');", SessionInfo.SessionID, reportName), true);
        else
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", string.Format("alert(\"Report not found '{0}'\");", reportName), true);
    }

    /// <summary>
    /// Populate the list of sites check list (for HK)
    /// 26Oct15 XN 106278
    /// </summary>
    private void PopulateSiteList()
    {
        // Populate check list
        cblSites.Items.Clear();
        foreach (var s in this.replicateToSites)
        {
            if (s.SiteNumber != SessionInfo.SiteNumber)
            {
                ListItem li = new ListItem(s.ToString(), s.SiteID.ToString());
                li.Selected = this.siteNumbersSelectedByDefault.Contains(s.SiteNumber);
                cblSites.Items.Add(li);
            }
        }
    }

    /// <summary>
    /// Updates the replicate to sites message depending on sites selected
    /// 26Oct15 XN 106278
    /// </summary>
    private void UpdateReplicateToSiteList()
    {
        StringBuilder  sitesLabel = new StringBuilder();
        List<ListItem> checkBoxes = cblSites.Items.OfType<ListItem>().ToList();

        // If only no sites then don't show replicate text
        if (checkBoxes.Count == 0)
        {
            lbtSites.Visible = false;
            return;
        }

        // List sites being replicated to
        IEnumerable<string> siteNumbersSelected = checkBoxes.Where(li => li.Selected).Select(li => li.Text.Split(' ')[0]);
        if (siteNumbersSelected.Any())
        {
            sitesLabel.AppendFormat("Replicate to sites {0}<br />", siteNumbersSelected.ToCSVString(","));
        }
        else if (cblSites.Items.OfType<ListItem>().Any(c => c.Enabled))
        {
            sitesLabel.Append("No sites selected for replication<br />");
        }
        else
        {
            sitesLabel.Append("No sites available for replication<br />");
        }

        // List sites not replicated to
        IEnumerable<string> siteNumbersNotSelected = checkBoxes.Where(li => li.Enabled && !li.Selected).Select(li => li.Text.Split(' ')[0]);
        if (siteNumbersNotSelected.Any())
        {
            sitesLabel.AppendFormat("Will not replicate to sites {0}<br />", siteNumbersNotSelected.ToCSVString(","));
        }

        // Show sites that are not available for replication (not currently used but keep in just in-case)
        IEnumerable<string> siteNumbersNotAvailable = checkBoxes.Where(li => !li.Enabled).Select(li => li.Text.Split(' ')[0]);
        if (siteNumbersNotAvailable.Any())
        {
            sitesLabel.Append("Cannot replicate to sites " + siteNumbersNotAvailable.ToCSVString(", "));
        }
        lbtSites.Text = sitesLabel.ToString();
    }

    /// <summary>
    /// Returns list of site ids included for replication to
    /// Will always include the current site though it does not appear in the list
    /// 26Oct15 XN 106278
    /// </summary>
    /// <returns>Returns list of sites ids selected to replicate to plus current site</returns>
    private IEnumerable<int> GetSelectedReplicateToSiteIds()
    {
        List<int> results = new List<int>();
        results.Add(SessionInfo.SiteID);
        results.AddRange(cblSites.Items.Cast<ListItem>().Where(s => s.Selected).Select(s => int.Parse(s.Value)));
        return results;
    }
    #endregion
}
