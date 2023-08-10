using System;
using System.Collections;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Web.UI.WebControls.WebParts;
using System.Xml.Linq;
using Ascribe.Common;
using System.Collections.Generic;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

// ======================================================================================================================
// Author: Aidan Kent (AJK)
// Created: 23feb09
// Description: Codebehind for RepeatDispensing.aspx
//
//	Modification History:
//  16Apr12 AJK  31236 Added new row to table rowUpdated with a label to display who updated the settings last and when
//  20Feb14 TH   84751 Added new method call to validate Repeat Patient row - For Rx linking button
//  21Oct14 TH   Added setting to suppress patient validation for rpt disp linking request (for DCS) (TFS 98593)
//  16Jan15 TH Merged mod from 10.10 (TFS 108566) : 21Oct14 TH   Added setting to suppress patient validation for rpt disp linking request (for DCS) (TFS 98593)
// ======================================================================================================================

public partial class application_RepeatDispensing_RepeatDispensing : System.Web.UI.Page
{
    int _SessionID = -1;
    int _EpisodeID = -1;
    int _EntityID;
    bool _PageIsValid;


    /// <summary>
    /// Handle page load event
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void Page_Load(object sender, EventArgs e)
    {
        _SessionID = int.Parse(Request.QueryString["SessionID"]);
        int siteID = 0;
        if (int.TryParse(Request.QueryString["SiteID"], out siteID))
            SessionInfo.InitialiseSessionAndSiteID(_SessionID, int.Parse(Request.QueryString["SiteID"]));
        else
            SessionInfo.InitialiseSession(_SessionID);

        bool result = int.TryParse(Request.QueryString["EntityID"], out _EntityID);
        if (!result)
        {
            _EpisodeID = int.Parse(Request.QueryString["EpisodeID"]);
            ENTRTL10.EpisodeRead objER = new ENTRTL10.EpisodeRead();
            //RepeatDispensingPatient.Patient patient = new RepeatDispensingPatient.Patient(); // Why is this needed?
            _EntityID = objER.EntityIDFromEpisode(_SessionID, _EpisodeID);
        }

        string method = Request.QueryString["Method"]; //20Feb14 TH Added

        if (!this.IsPostBack)
        {
            //RepeatDispensingPatient objRDP = new RepeatDispensingPatient();
            //RepeatDispensingPatient.Patient patient = objRDP.PatientByEntityID(_SessionID, _EntityID);
            RepeatDispensingPatientProcessor processor = new RepeatDispensingPatientProcessor();
            RepeatDispensingPatientLine patient = processor.LoadByEntityID(_EntityID);
            
            //20Feb14 TH Added new method call to validate Repeat Patient row (For Rx linking button , TFS 84751)
            if (method == "IsRepeatPatientSaved")
            {
                string IsRepeatPatientSaved = "0";
                if (patient.InUse.HasValue)
                {
		     IsRepeatPatientSaved = "1";
                }
		else
		{
                   //16Jan15 TH Merged mod from 10.10 (TFS 108566) : 21Oct14 TH Added setting to suppress this validation (for DCS) (TFS98593)
		   bool setting  = SettingsController.Load<bool>("Pharmacy", "RepeatDispensing", "SuppressRptLinkingPatientValidation", false);                   
		   if(setting)  
		   {
			IsRepeatPatientSaved = "1";
		   }
                }
                Response.Write(IsRepeatPatientSaved);
                Response.End();
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Close_Window2", "self.close();", true);
            }
            else
            {

                lblPatient.Text = string.Empty;
                if (!string.IsNullOrEmpty(patient.Forename))
                    lblPatient.Text += patient.Forename + " ";
                if (!string.IsNullOrEmpty(patient.Surname))
                    lblPatient.Text += patient.Surname + " ";
                if (patient.DOB.HasValue)
                    lblPatient.Text += "(" + patient.DOB.ToPharmacyDateString() + ")";
                if (!string.IsNullOrEmpty(patient.HospitalNumber))
                    lblPatient.Text += " " + patient.HospitalNumber;

                //  16Apr12 AJK 31236 Display updated info
                if (patient.Updated.HasValue && !string.IsNullOrEmpty(patient.UpdatedByDescription))
                {
                    lblUpdated.Text = "Last edit by " + patient.UpdatedByDescription + " on " + string.Format("{0:dd/MM/yyyy}", patient.Updated) + " at " + string.Format("{0:HH:mm}", patient.Updated);
                    rowUpdated.Visible = true;
                }

                // Set the length of supply, package by, and supplier pattern depending on robot setting
                RepeatDispensingValidation validation = new RepeatDispensingValidation();
                switch (validation.GetPackerName().ToUpper())
                {
                    case "JVADTPS":
                        lblLength.Text = "Manual length of supply";
                        rowADM.Visible = (bool)(WConfigurationController.LoadASetting(SessionInfo.SiteID, "D|PATMED", "RepeatDispensing", "ADMEnabled", "1", false, typeof(bool)));
                        lblADM.Text = "Package by " + RepeatDispensingValidation.GetPackerDisplayName((siteID == 0) ? (int?)null : siteID);
                        lblSupplyPattern.Text = "Manual supply pattern";
                        break;
                    case "MTS":
                        lblLength.Text = "Length of supply";
                        rowADM.Visible = (bool)(WConfigurationController.LoadASetting(SessionInfo.SiteID, "D|PATMED", "RepeatDispensing", "ADMEnabled", "1", false, typeof(bool)));
                        lblADM.Text = "Package by " + RepeatDispensingValidation.GetPackerDisplayName((siteID == 0) ? (int?)null : siteID);
                        lblSupplyPattern.Text = "Supply pattern";
                        break;
                    default:
                        rowADM.Visible = false;
                        break;
                }

                // Populate the template drop-down
                PopulateTemplates(patient.RepeatDispensingBatchTemplateID);

                //objRDP.PatientSettingsByEpisodeID(_SessionID, _EpisodeID); // Loads patient settings
                //if (objRDP.IsLoaded == true)
                if (patient.InUse.HasValue)
                {
                    // Assign values to controls

                    //txtLength.Text = objRDP.SupplyDays.ToString();
                    txtLength.Text = patient.SupplyDays.HasValue ? patient.SupplyDays.ToString() : "";
                    //chkInUse.Checked = objRDP.InUse;
                    chkInUse.Checked = patient.InUse.HasValue ? (bool)patient.InUse : false;
                    //chkADM.Checked = objRDP.ADM;
                    chkADM.Checked = patient.ADM.HasValue ? (bool)patient.ADM : false;
                    txtAdditionalInformation.Text = patient.AdditionalInformation;
                    UpdateSupplyPatternGUI(); // Refresh available supply patterns
                    if (patient.SupplyPattern.HasValue)
                    {
                        foreach (ListItem item in rblSupplyPattern.Items) // Find and select the saved supply pattern
                        {
                            //if (item.Value == objRDP.SupplyPatternID.ToString()) 
                            if (item.Value == EnumViaDBLookupAttribute.ToLookupID<SupplyPattern>(patient.SupplyPattern.Value).ToString())
                            {
                                item.Selected = true;
                                break;
                            }
                        }
                    }
                }
                else
                {
                    chkInUse.Checked = true;
                    btnDelete.Enabled = false;
                }
            }
        }

        // Deal with __postBack events
        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];

        switch (target)
        {
        case "UpdatePanel8" :
            // If requested delete the repeat dispensing settings
            if (args.EqualsNoCaseTrimEnd("Delete"))
                Delete();
            break;
        }
    }

    /// <summary>Populates the drop down list of templates</summary>
    /// <param name="selectedTemplateID">template ID to select</param>
    protected void PopulateTemplates(int? selectedTemplateID)
    {
        RepeatDispensingBatchTemplate templates = new RepeatDispensingBatchTemplate();
        templates.LoadAll();

        // Add blank template entry
        ddlTemplate.Items.Add(new ListItem(string.Empty, string.Empty));

        // Add other templates
        foreach (RepeatDispensingBatchTemplateRow t in templates.OrderBy(t => t.Description.ToLower()))
        {
            ListItem templateItem = new ListItem(t.Description, t.RepeatDispensingBatchTemplateID.ToString());
            ddlTemplate.Items.Add(templateItem);

            if (selectedTemplateID.HasValue && (t.RepeatDispensingBatchTemplateID == selectedTemplateID.Value))
            {
                templateItem.Selected = true;
                lblNotInUse.Visible   = !t.InUse;
            }
        }

        // If seletected item is not in the list
        if (selectedTemplateID.HasValue && (ddlTemplate.SelectedItem == null))
        {
            templates.LoadByRepeatDispensingBatchTemplateID(selectedTemplateID.Value);
            if (templates.Any())
            {
                ListItem templateItem = new ListItem(templates[0].Description, templates[0].RepeatDispensingBatchTemplateID.ToString());
                templateItem.Selected = true;
                ddlTemplate.Items.Add(templateItem);
                lblNotInUse.Visible = !templates[0].InUse;
            }
        }
    }

    /// <summary>
    /// Called when selected template index changes
    /// Will show or hide the 'not in use' label depending on the selected template state
    /// </summary>
    protected void ddlTemplate_SelectedIndexChanged(object sender, EventArgs e)
    {
        int? selectedTemplateID = null;
        if (!string.IsNullOrEmpty(ddlTemplate.SelectedValue))
            selectedTemplateID = int.Parse(ddlTemplate.SelectedValue);

        RepeatDispensingBatchTemplateRow template = null;
        if (selectedTemplateID.HasValue)
            template = RepeatDispensingBatchTemplate.GetByByRepeatDispensingBatchTemplateID(selectedTemplateID.Value);

        lblNotInUse.Visible = (template != null) && !template.InUse;
    }

    protected void btnOK_Click(object sender, EventArgs e)
    {
        Page.Validate(); // Validate page first
        if (Page.IsValid == true)
        {
            int value;
            //RepeatDispensingPatient objRDP = new RepeatDispensingPatient();
            //RepeatDispensingPatient.Patient patient = new RepeatDispensingPatient.Patient();
            RepeatDispensingPatientLine patient = new RepeatDispensingPatientLine();
            RepeatDispensingPatientProcessor processor = new RepeatDispensingPatientProcessor();
            //ENTRTL10.EpisodeRead objER = new ENTRTL10.EpisodeRead();
            // Assign values for saving
            patient.ADM = rowADM.Visible == true ? chkADM.Checked : false; //F0071513 Only save true value if checkbox is visible
            patient.EntityID = _EntityID;
            //patient.EpisodeID = _EpisodeID;
            patient.InUse = chkInUse.Checked;
            patient.SupplyDays = Convert.ToInt32(txtLength.Text);
            patient.SupplyPattern = ((rowSupplyPattern.Visible == true) && int.TryParse(rblSupplyPattern.SelectedValue, out value)) ? EnumViaDBLookupAttribute.ToEnum<SupplyPattern>(value) : (SupplyPattern?)null;
            patient.AdditionalInformation = txtAdditionalInformation.Text;

            if ((ddlTemplate.SelectedItem == null) || string.IsNullOrEmpty(ddlTemplate.SelectedItem.Value))
                patient.RepeatDispensingBatchTemplateID = null;
            else
                patient.RepeatDispensingBatchTemplateID = int.Parse(ddlTemplate.SelectedItem.Value);

            //patient.SupplyPatternID = ((rowSupplyPattern.Visible == true) && int.TryParse(rblSupplyPattern.SelectedValue, out value)) ? (int?)value : (int?)null;
            processor.Update(patient);
            //ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "saveSucceeded", "alert('Setting save succeeded.');self.close();", true); // Display success message
            //if (objRDP.SavePatientSettings(_SessionID, patient) == false) // Save patient settings
            //{
            //    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "saveFailed", "alert('Setting save failed.');", true); // Display failed message
            //}
            //else
            //{
            //    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "saveSucceeded", "alert('Setting save succeeded.');self.close();", true); // Display success message
            //}
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Close_Window2", "window.returnValue='cancel';self.close();", true); // Close the current window
        }
    }

    protected void Validate(object sender, ServerValidateEventArgs args)
    {
        RepeatDispensingPatientProcessor processor = new RepeatDispensingPatientProcessor();
        RepeatDispensingPatientLine patient = new RepeatDispensingPatientLine();
        int value;
        patient.ADM = rowADM.Visible == true ? chkADM.Checked : false;  //F0071513 Only save true value if checkbox is visible
        patient.EntityID = _EntityID;
        patient.InUse = chkInUse.Checked;
        patient.SupplyDays = int.TryParse(txtLength.Text, out value) ? (int?)value : (int?)null;
        patient.SupplyPattern = ((rowSupplyPattern.Visible == true) && int.TryParse(rblSupplyPattern.SelectedValue, out value)) ? EnumViaDBLookupAttribute.ToEnum<SupplyPattern>(value) : (SupplyPattern?)null;
        processor.ValidateForUpdate(patient);
        ValidatorLength.ErrorMessage = "";
        if (processor.ValidationErrors.Count > 0)
        {
            foreach (ValidationError error in processor.ValidationErrors)
            {
                if (error.PropertyName == "SupplyDays")
                    ValidatorLength.ErrorMessage = "<BR/>" + error.ErrorMessage.Replace(ValidationError.PropertyNameTag, "Length of supply");
                else
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "validationFailed", "alert('Validation failed - " + error.ErrorMessage.ToString() + "');self.close();", true); // Display success message
            }
            args.IsValid = false;
        }
        else
        {
            args.IsValid = true;
        }
    }

    //protected void btnCancel_Click(object sender, EventArgs e)
    //{
    //    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Close_Window", "window.returnValue='cancel';self.close();", true); // Close the current window
    //}

    protected void btnClear_Click(object sender, EventArgs e)
    {
        // Clear all controls
        txtLength.Text = "";
        chkADM.Checked = false;
        chkInUse.Checked = false;
        ddlTemplate.SelectedIndex = 0;
        lblNotInUse.Visible = false;
        txtAdditionalInformation.Text = string.Empty;
        UpdateSupplyPatternGUI();

        // Hide validators
        ValidatorLength.IsValid = true;
        ValidatorAdditionalInformation.IsValid = true;

    }

    /// <summary>Delete the RepeatDispensingPatient details (an closed the from)</summary>
    protected void Delete()
    {
        RepeatDispensingPatient patientRepeatDispensingSettings = new RepeatDispensingPatient();
        patientRepeatDispensingSettings.LoadByEntityID(_EntityID);
        if (patientRepeatDispensingSettings.Any())
            patientRepeatDispensingSettings.RemoveAt(0);
        patientRepeatDispensingSettings.Save();

        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "closeform", "window.close();", true);
    }

    //protected void ValidateADM(object sender, ServerValidateEventArgs args)
    //{
    //    // Validate ADM by checking logic in middle tier
    //    RepeatDispensingPatient objRDP = new RepeatDispensingPatient();
    //    string errorMessage = "";
    //    if (objRDP.ValidateADM(txtLength.Text, chkADM.Checked, ref errorMessage))
    //    {
    //        ValidatorADM.ErrorMessage = ""; // Clear validator error message
    //        args.IsValid = true;
    //    }
    //    else
    //    {
    //        ValidatorADM.ErrorMessage = "<BR/>" + errorMessage; // Assign validator error message
    //        args.IsValid = false;
    //    }
    //}

    //protected void ValidateLength(object sender, ServerValidateEventArgs args)
    //{
    //    // Validate length selection by checking logic in middle tier
    //    RepeatDispensingPatient objRDP = new RepeatDispensingPatient();
    //    string errorMessage = "";
    //    if (objRDP.ValidateLength(txtLength.Text, ref errorMessage))
    //    {
    //        ValidatorLength.ErrorMessage = ""; // Clear validator error message
    //        args.IsValid = true;
    //    }
    //    else
    //    {
    //        ValidatorLength.ErrorMessage = "<BR/>" + errorMessage; // Assign validator error message
    //        args.IsValid = false;
    //    }
    //}

    //protected void ValidateBagLabels(object sender, ServerValidateEventArgs args)
    //{
    //    // Validate bag labels selection by checking logic in middle tier
    //    RepeatDispensingPatient objRDP = new RepeatDispensingPatient();
    //    string errorMessage = "";
    //    if (objRDP.ValidateBagLabels(txtBagLabels.Text, ref errorMessage))
    //    {
    //        ValidatorBagLabels.ErrorMessage = ""; // Clear validator error message
    //        args.IsValid = true;
    //    }
    //    else
    //    {
    //        ValidatorBagLabels.ErrorMessage = "<BR/>" + errorMessage; // Assign validator error message
    //        args.IsValid = false;
    //    }
    //}


    protected void txtLength_TextChanged(object sender, EventArgs e)
    {
        Page.Validate();
        UpdateSupplyPatternGUI(); // Refresh supply pattern options
    }

    protected void chkADM_CheckedChanged(object sender, EventArgs e)
    {
        Page.Validate();
        UpdateSupplyPatternGUI(); // Refresh supply pattern options
    }


    protected void UpdateSupplyPatternGUI()
    {
        int length;
        if ((rowADM.Visible == false || !chkADM.Checked) && int.TryParse(txtLength.Text.ToString(), out length) && length > 0 && length < 100) // Ensure length of supply is numeric
        {
            //RepeatDispensingPatient objRDP = new RepeatDispensingPatient();
            //objRDP.LoadSupplyPatterns(_SessionID); // Load available supply patterns in middle tier
            //List<RepeatDispensingPatient.SupplyPattern> availablePatterns = objRDP.AvailablePatterns(_SessionID, length, chkADM.Checked); // Obtain available supply patterns based on ADM and length selection
            RepeatDispensingSupplyPatternProcessor processor = new RepeatDispensingSupplyPatternProcessor();
            List<RepeatDispensingSupplyPatternLine> supplyPatterns = new List<RepeatDispensingSupplyPatternLine>();
            supplyPatterns = processor.LoadBySupplyLength(length);
            //if (availablePatterns != null && availablePatterns.Count > 0) // IF there are available patterns
            if (supplyPatterns.Capacity > 0)
            {
                rowSupplyPattern.Visible = true; // Show supply pattern selection
                string tempSupply = "";
                if (rblSupplyPattern.SelectedIndex > -1) // If there is already an item selected
                {
                    tempSupply = rblSupplyPattern.SelectedValue; // Store selected index for reselection after the options have been rebuilt
                }
                else
                {
                    tempSupply = "-1";
                }
                rblSupplyPattern.Items.Clear(); // Remove all current options
                int selectedIndex = -1;
                foreach (RepeatDispensingSupplyPatternLine pattern in supplyPatterns)
                //foreach (RepeatDispensingPatient.SupplyPattern pattern in availablePatterns) // Iterate through available patterns
                {
                    rblSupplyPattern.Items.Add(new ListItem(pattern.Description, pattern.SupplyPatternID.ToString())); // Add item
                    if (selectedIndex == -1 && pattern.IsDefault == true) // If no option is currently selected and added option is default
                    {
                        selectedIndex = rblSupplyPattern.Items.Count - 1; // Mark index for selection
                    }
                    if (pattern.SupplyPatternID.ToString() == tempSupply) // If a previously selected option was stored for reselection and it matches newly added option
                    {
                        selectedIndex = rblSupplyPattern.Items.Count - 1; // Mark index for selection
                    }
                }
                rblSupplyPattern.Items[selectedIndex].Selected = true; // Select marked index
            }
            else
            {
                rowSupplyPattern.Visible = false; // Hide supply pattern selection
            }
        }
        else
        {
            rowSupplyPattern.Visible = false; // Hide supply pattern selection
        }
    }
}

