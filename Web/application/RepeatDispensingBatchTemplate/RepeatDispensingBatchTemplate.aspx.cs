// ======================================================================================================================
// Author: Aidan Kent (AJK)
// Description: Codebehind for RepeatDispensingLinking.aspx
//
//	Modification History:
//  17Apr12 AJK  31999 Changed logic in CheckManual to ensure that the manual box is never displayed if it's a JVM batch/template
//                     with Meds Management switched on 
//  18Apr12 AJK  31999 Added CheckManual call to first page load                   
//  18Sep12 AJK  44221 Page_Load: Check if there is a packer and it has a numeric, positive section
//  20Sep12 AJK  44416 SaveBatch: Added an extra check to ensure JVM box is visible before saving it's value
// ======================================================================================================================
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
using ascribe.pharmacy.shared;
using ascribe.pharmacy.businesslayer;
using System.Collections.Generic;
using ascribe.pharmacy.pharmacydatalayer;
using System.Web.Services;

// 02Apr12 AJK 30988 Numerous changes to support the UI rework of slot / length functionality

public partial class application_RepeatDispensingBatchTemplate_RepeatDispensingBatchTemplate : System.Web.UI.Page
{
    protected int _SessionID = -1;        // SessionID
    int _TemplateID = 0;
    RepeatDispensingBatchTemplateLine template = new RepeatDispensingBatchTemplateLine();
    string _mode;
    int _SiteID = -1;
    int _EntityID = 0;
    int _bagLabelsDefault = 1;


    protected void Page_Load(object sender, EventArgs e)
    {
        Page.Form.DefaultButton = btnCancel.UniqueID;
        _SessionID = int.Parse(Request.QueryString["SessionID"]);
        SessionInfo.InitialiseSession(_SessionID);

        // Set readonly here rather than using ASP.NET ReadOnly function,
        // so that client side updates are sent back with the form.
        txtLocation.Attributes["readonly"] = "readonly";
        txtFromDate.Attributes["readonly"] = "readonly";    
        txtTo.Attributes      ["readonly"] = "readonly";

        _mode = Request.QueryString["Mode"];
        hdnMode.Value = _mode;
        switch (_mode)
        {
            case "Template":
                rowBatchSlots.Visible = false;
                rowFactor.Visible = false;
                break;
            case "Batch":
                _SiteID = int.Parse(Request.QueryString["SiteID"]);
                chkInUse.Visible = false;
                lblInUse.Visible = false;
                btnSaveAs.Visible = false;
                rowDefaultStartTomorrow.Visible = false;
                rowDuration.Visible = false;
                rowTemplateBreakfast.Visible = false;
                rowTemplateLunch.Visible = false;
                rowTemplateNight.Visible = false;
                rowTemplateTea.Visible = false;
                chkBatchBreakfast.Attributes.Add("onclick", "chkBatchBreakfast_Click();");
                chkBatchLunch.Attributes.Add("onclick", "chkBatchLunch_Click();");
                chkBatchTea.Attributes.Add("onclick", "chkBatchTea_Click();");
                chkBatchNight.Attributes.Add("onclick", "chkBatchNight_Click();");
                chkFromBreakfast.Attributes.Add("onclick", "chkFromBreakfast_Click();");
                chkFromLunch.Attributes.Add("onclick", "chkFromLunch_Click();");
                chkFromNight.Attributes.Add("onclick", "chkFromNight_Click();");
                chkFromTea.Attributes.Add("onclick", "chkFromTea_Click();");
                chkToBreakfast.Attributes.Add("onclick", "chkToBreakfast_Click();");
                chkToLunch.Attributes.Add("onclick", "chkToLunch_Click();");
                chkToNight.Attributes.Add("onclick", "chkToNight_Click();");
                chkToTea.Attributes.Add("onclick", "chkToTea_Click();");
                txtBatchDays.Attributes.Add("onkeyup", "txtBatchDays_KeyUp();");
                btnSave.Text = "OK";  //13Jun11 TH (F0120249)

                break;
        }
        
        if (!IsPostBack)
        {
            // 02Apr12 AJK 30988 Added default set
            hdnFBV.Value = "visible";
            hdnFLV.Value = "visible";
            hdnFNV.Value = "visible";
            hdnFTV.Value = "visible";
            hdnTBV.Value = "visible";
            hdnTLV.Value = "visible";
            hdnTNV.Value = "visible";
            hdnTTV.Value = "visible";
            // 02Apr12 AJK 30988 END
            hdnTemplateID.Value = Request.QueryString["RepeatDispensingBatchTemplateID"];
            _TemplateID = int.Parse(hdnTemplateID.Value);
            if (Request.QueryString["EntityID"] != null && Request.QueryString["EntityID"].Length > 0)
                _EntityID = int.Parse(Request.QueryString["EntityID"]);

            using (RepeatDispensingValidation validator = new RepeatDispensingValidation())
            {
                if (validator.GetPackerName() == "JVADTPS")
                {
                    chkJVM.Checked = true;
                    divJVM.Visible = true;
                }
                else
                {
                    chkJVM.Checked = false;
                    divJVM.Visible = false;
                    chkJVM.Visible = false;
                    lblJVM.Visible = false;
                }
            }
            if (_TemplateID > 0)
            {
                //Load existing template
                using (RepeatDispensingBatchTemplateProcessor templateProcessor = new RepeatDispensingBatchTemplateProcessor())
                {
                    template = templateProcessor.LoadByTemplateID(_TemplateID);
                }
                txtDescription.Text = template.Description;
                chkSelectPatients.Checked = template.SelectPatientsByDefault ? true : false;
                hdnLocationID.Value = template.LocationID.ToString();
                txtLocation.Text = template.LocationDescription;
                txtBagLabels.Text = template.BagLabels.ToString();
                //chkInPatient.Checked = template.InPatient ? true : false;	 -- XN 09Jun11 F0119748 
                //chkOutPatient.Checked = template.OutPatient ? true : false;	 -- XN 09Jun11 F0119748 
                //chkDischarge.Checked = template.Discharge ? true : false;	 -- XN 09Jun11 F0119748 
                //chkLeave.Checked = template.Leave ? true : false;		 -- XN 09Jun11 F0119748 
                if (template.JVMSortByAdminSlot == true)
                {
                    optSortTime.Checked = true;
                }
                else
                {
                    optSortName.Checked = true;
                }
                chkJVM.Checked = template.JVM;
                if (chkJVM.Visible) divJVM.Visible = template.JVM;
                chkManual.Checked = Convert.ToBoolean(template.JVMIncludeManual);
                if (_mode == "Batch")
                {
                    if (template.LocationID > 0)
                    {
                        btnLocationLookup.Disabled = true;
                        btnClearLocation.Disabled = true;
                    }
                    txtDescription.Text += " " + string.Format("{0:yyyy-MM-dd}", DateTime.Now);
                    chkInUse.Visible = false;
                    lblInUse.Visible = false;
                    if (template.JVM)
                    {
                        if ((bool)template.JVMDefaultStartTomorrow)
                        {
                            txtFromDate.Text = string.Format("{0:dd/MM/yyyy}", DateTime.Now.AddDays(1));
                            //hdnOldStartDate.Value = txtFromDate.Text; // 02Apr12 AJK 30988 Removed
                            txtTo.Text = string.Format("{0:dd/MM/yyyy}", DateTime.Now.AddDays(Convert.ToDouble(template.JVMDuration)));
                        }
                        else
                        {
                            txtFromDate.Text = string.Format("{0:dd/MM/yyyy}", DateTime.Now);
                            //hdnOldStartDate.Value = txtFromDate.Text; // 02Apr12 AJK 30988 Removed
                            txtTo.Text = string.Format("{0:dd/MM/yyyy}", DateTime.Now.AddDays(Convert.ToDouble(template.JVMDuration) - 1));
                        }
                        txtBatchDays.Text = template.JVMDuration.ToString();
                        //hdnOldLength.Value = txtBatchDays.Text; // 02Apr12 AJK 30988 Removed
                        
                        //03Apr13 AJK 60503 Changed logic to set hdn values
                        if (Convert.ToBoolean(template.JVMBreakfast))
                        {
                            chkBatchBreakfast.Checked = true;
                        }
                        else
                        {
                            chkBatchBreakfast.Checked = false;
                            hdnFBV.Value = "hidden";
                            hdnTBV.Value = "hidden";
                        }

                        if (Convert.ToBoolean(template.JVMLunch))
                        {
                            chkBatchLunch.Checked = true;
                        }
                        else
                        {
                            chkBatchLunch.Checked = false;
                            hdnFLV.Value = "hidden";
                            hdnTLV.Value = "hidden";
                        }

                        if (Convert.ToBoolean(template.JVMTea))
                        {
                            chkBatchTea.Checked = true;
                        }
                        else
                        {
                            chkBatchTea.Checked = false;
                            hdnFTV.Value = "hidden";
                            hdnTTV.Value = "hidden";
                        }

                        if (Convert.ToBoolean(template.JVMNight))
                        {
                            chkBatchNight.Checked = true;
                        }
                        else
                        {
                            chkBatchNight.Checked = false;
                            hdnFNV.Value = "hidden";
                            hdnTNV.Value = "hidden";
                        }

                        //chkBatchBreakfast.Checked = Convert.ToBoolean(template.JVMBreakfast);
                        //chkBatchLunch.Checked = Convert.ToBoolean(template.JVMLunch);
                        //chkBatchTea.Checked = Convert.ToBoolean(template.JVMTea);
                        //chkBatchNight.Checked = Convert.ToBoolean(template.JVMNight);

                    }
                    else
                    {
                        //Set JVM fields to defaults
                        SetJVMDefaults();
                    }
                    
                                       
                }
                else if (_mode == "Template")
                {
                    chkInUse.Checked = template.InUse;
                    chkDefaultStartTomorrow.Checked = Convert.ToBoolean(template.JVMDefaultStartTomorrow);
                    txtDuration.Text = template.JVMDuration.ToString();
                    chkBreakfast.Checked = Convert.ToBoolean(template.JVMBreakfast);
                    chkLunch.Checked = Convert.ToBoolean(template.JVMLunch);
                    chkTea.Checked = Convert.ToBoolean(template.JVMTea);
                    chkNight.Checked = Convert.ToBoolean(template.JVMNight);
                }
                CheckManual();
            }
            else
            {
                using (WConfiguration config = new WConfiguration())
                {
                    config.LoadBySiteCategorySectionAndKey(_SiteID, "D|PATMED", "RepeatDispensing", "DefaultBatchBagLabels");
                    bool success = false;
                    if (config.Count > 0) success = int.TryParse(config[0].Value, out _bagLabelsDefault);
                    if (!success) _bagLabelsDefault = 1;
                }
                //txtBagLabels.Text = "0"; AJK 25Aug11
                txtBagLabels.Text = _bagLabelsDefault.ToString();

                //chkInPatient.Checked = true;		 -- XN 09Jun11 F0119748 
                //chkOutPatient.Checked = true		 -- XN 09Jun11 F0119748 		;
                //chkDischarge.Checked = true;		 -- XN 09Jun11 F0119748 	
                //chkLeave.Checked = true;		 -- XN 09Jun11 F0119748 
                chkManual.Checked = true;
                optSortName.Checked = true;
                chkSelectPatients.Checked = true;
                if (_mode == "Template")
                {
                    //New template
                    chkInUse.Checked = true;
                    chkDefaultStartTomorrow.Checked = true;
                    txtDuration.Text = "7";
                    chkBreakfast.Checked = true;
                    chkLunch.Checked = true;
                    chkTea.Checked = true;
                    chkNight.Checked = true;
                }
                else if (_mode == "Batch")
                {
                    btnLocationLookup.Disabled = true;
                    btnClearLocation.Disabled = true;
                    chkInUse.Visible = false;
                    lblInUse.Visible = false;
                    ENTRTL10.EntityRead entityRead = new ENTRTL10.EntityRead();
                    System.Xml.XmlDocument doc = new System.Xml.XmlDocument();
                    doc.LoadXml(entityRead.PatientDetailByEntityIDXML(_SessionID, _EntityID));
                    System.Xml.XmlNode patient;
                    patient = doc.SelectSingleNode("/root/Patient");
                    string DOB = "";
                    DOB = patient.Attributes["DOB"] == null ? "" : " " + string.Format("{0:dd/MM/yyyy}", Convert.ToDateTime(patient.Attributes["DOB"].Value));
                    txtDescription.Text = patient.Attributes["Surname"].Value + " " + patient.Attributes["Forename"].Value + DOB + " " + string.Format("{0:yyyy-MM-dd}",DateTime.Now);
                    SetJVMDefaults();
                }
            }
            //Load slot times
            if (_mode == "Batch")
            {
                using (WConfiguration config = new WConfiguration())
                {
                    int packerSection;
                    config.LoadBySiteCategorySectionAndKey(_SiteID, "D|MECHDISP", "", "PackerSection");
                    if (config.Count == 1 && int.TryParse(config[0].Value, out packerSection) && packerSection > 0) // 18Sep12 AJK 44221 Check if there is a packer and it has a numeric, positive section
                    {
//                        packerSection = int.Parse(config[0].Value);
                        config.LoadBySiteCategorySectionAndKey(_SiteID, "D|MECHDISP", packerSection.ToString(), "DoseSlot1");
                        hdnDoseSlot1.Value = config[0].Value.Substring(5, 2) + ":" + config[0].Value.Substring(7, 2);
                        config.LoadBySiteCategorySectionAndKey(_SiteID, "D|MECHDISP", packerSection.ToString(), "DoseSlot2");
                        hdnDoseSlot2.Value = config[0].Value.Substring(5, 2) + ":" + config[0].Value.Substring(7, 2);
                        config.LoadBySiteCategorySectionAndKey(_SiteID, "D|MECHDISP", packerSection.ToString(), "DoseSlot3");
                        hdnDoseSlot3.Value = config[0].Value.Substring(5, 2) + ":" + config[0].Value.Substring(7, 2);
                        config.LoadBySiteCategorySectionAndKey(_SiteID, "D|MECHDISP", packerSection.ToString(), "DoseSlot4");
                        hdnDoseSlot4.Value = config[0].Value.Substring(5, 2) + ":" + config[0].Value.Substring(7, 2);
                    }
                }
            }
            CheckManual(); // 18Apr12 AJK  31999 Added
        }
        else
        {
            _TemplateID = int.Parse(hdnTemplateID.Value);
            if (_TemplateID > 0 && _mode == "Template")
            {
                using (RepeatDispensingBatchTemplateProcessor templateProcessor = new RepeatDispensingBatchTemplateProcessor())
                {
                    template = templateProcessor.LoadByTemplateID(_TemplateID);
                }
            }
        }



        string target = Request["__EVENTTARGET"];
        string args = Request["__EVENTARGUMENT"];



        if (target.EqualsNoCase("upUpdatePanelForform"))
        {
            switch (args)
            {
            case "CheckManual":
                CheckManual();
                break;

             default:
                TrySave(true, args);
                break;
            }
        }
    }

    private void SetJVMDefaults()
    {
        txtFromDate.Text = string.Format("{0:dd/MM/yyyy}", DateTime.Now);
        //hdnOldStartDate.Value = txtFromDate.Text; // 02Apr12 AJK 30988 Removed
        txtBatchDays.Text = "7";
        //hdnOldLength.Value = txtBatchDays.Text; // 02Apr12 AJK 30988 Removed
        lblSlotsNumber.Text = "0";
        txtTo.Text = string.Format("{0:dd/MM/yyyy}", DateTime.Now.AddDays(6));
        chkBatchBreakfast.Checked = true;
        chkBatchLunch.Checked = true;
        chkBatchNight.Checked = true;
        chkBatchTea.Checked = true;
        chkFromBreakfast.Checked = true;
        chkFromLunch.Checked = true;
        chkFromNight.Checked = true;
        chkFromTea.Checked = true;
        chkToBreakfast.Checked = true;
        chkToLunch.Checked = true;
        chkToNight.Checked = true;
        chkToTea.Checked = true;

    }

    private bool FormHasChanged()
    {
        bool hasChanged = false;
        if (hdnLocationID.Value.Length > 0)
        {
            bool success = false;
            bool hasLocation;
            int bagLabels;
            int duration = 0;
            int locationID;
            hasLocation = int.TryParse(hdnLocationID.Value,out locationID);
            success = int.TryParse(txtBagLabels.Text,out bagLabels);
            if (success && chkJVM.Checked == true)
                success = int.TryParse(txtDuration.Text,out duration);

            if (!success || bagLabels != template.BagLabels || template.Description != txtDescription.Text || template.InUse != chkInUse.Checked || template.JVM != chkJVM.Checked
            	//|| template.InPatient != chkInPatient.Checked || template.OutPatient != chkOutPatient.Checked || template.Leave != chkLeave.Checked || template.Discharge != chkDischarge.Checked -- XN 09Jun11 F0119748 
                    || (template.JVM && (
                        (template.JVMBreakfast != chkBreakfast.Checked) ||
                        (template.JVMDefaultStartTomorrow != chkDefaultStartTomorrow.Checked) ||
                        (template.JVMDuration != duration) ||
                        (template.JVMIncludeManual != chkManual.Checked) ||
                        (template.JVMLunch != chkLunch.Checked) ||
                        (template.JVMNight != chkNight.Checked) ||
                        (template.JVMSortByAdminSlot != optSortTime.Checked) ||
                        (template.JVMTea != chkTea.Checked)
                        ))
                || template.LocationID.HasValue != hasLocation || (hasLocation && template.LocationID != locationID)
                || template.SelectPatientsByDefault != chkSelectPatients.Checked)
            {
                //failed
                hasChanged = true;
            }
            else
            {
                //passed
                hasChanged = false;
            }
        }
        else
        {
            //New
            if (chkInUse.Checked != true || txtBagLabels.Text != _bagLabelsDefault.ToString() || chkSelectPatients.Checked != true || chkJVM.Checked != false || chkDefaultStartTomorrow.Checked != true
            	//chkInPatient.Checked != true || chkOutPatient.Checked != true || chkDischarge.Checked != true|| chkLeave.Checked != true 							-- XN 09Jun11 F0119748 
                || txtDuration.Text != "7" || chkBreakfast.Checked != true || chkLunch.Checked != true || chkTea.Checked != true || chkNight.Checked != true
                || chkManual.Checked != true || optSortName.Checked != true)
            {
                hasChanged = true;
            }
        }
        return hasChanged;
    }

    protected void TrySave(bool overrideSave, string saveType)
    {
        if (!overrideSave)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "dosave", "if (ICWConfirm('This will overwrite an existing template of the same name, are you sure?', \"OK,Cancel\", \"Overwrite Template\",\"dialogHeight:80px;dialogWidth:300px;resizable:yes;status:no;help:no;\") == \"OK\") {__doPostBack('upUpdatePanelForform','" + saveType + "');}", true);
        }
        else
        {
            // Do save
            Save(true, saveType);
        }

    }

    protected void ValidateDescription(object sender, ServerValidateEventArgs args)
    {
        txtDescription.Text = txtDescription.Text.Trim();
        if (txtDescription.Text.Length == 0)
        {
            ValidatorDescription.ErrorMessage = "Required field";
            args.IsValid = false;
        }
        if ((_mode == "Template") && (txtDescription.Text.Length > 80))
        {
            ValidatorDescription.ErrorMessage = "Maximum length is 80 characters";
            args.IsValid = false;
        }
        if ((_mode == "Batch") && (txtDescription.Text.Length > 100))
        {
            ValidatorDescription.ErrorMessage = "Maximum length is 100 characters";
            args.IsValid = false;
        }
        if (_mode == "Batch")
        {
            RepeatDispensingBatch dbBatch = new RepeatDispensingBatch();
            dbBatch.LoadActiveByDescription(txtDescription.Text);
            if (dbBatch.Count > 0)
            {
                ValidatorDescription.ErrorMessage = "An active batch with this description already exists";
                args.IsValid = false;
            }
        }
    }

    protected void ValidateLocation(object sender, ServerValidateEventArgs args)
    {
        if (_mode == "Batch" && hdnLocationID.Value == "" && _TemplateID > 0 && RepeatDispensingPatient.CountByTemplate(_TemplateID) == 0)
        {
            ValidatorLocation.ErrorMessage = "There are no patients linked to this template so you must select a location";
            args.IsValid = false;
        }
    }

    /* -- XN 09Jun11 F0119748 
    protected void ValidateTypes(object sender, ServerValidateEventArgs args)
    {
        if (chkInPatient.Checked == false && chkOutPatient.Checked == false && chkDischarge.Checked == false && chkLeave.Checked == false)
        {
            ValidatorTypes.ErrorMessage = "Please select at least one type";
            args.IsValid = false;
        }
    }*/    
    protected void ValidateBagLabels(object sender, ServerValidateEventArgs args)
    {
        txtBagLabels.Text = txtBagLabels.Text.Trim();
        if (txtBagLabels.Text.Length == 0)
        {
            ValidatorBagLabels.ErrorMessage = "Required field";
            args.IsValid = false;
        }
        else
        {
            bool bagLabelsIsNumeric = false;
            int bagLabels = 0;
            bagLabelsIsNumeric = int.TryParse(txtBagLabels.Text, out bagLabels);
            if (!bagLabelsIsNumeric)
            {
                ValidatorBagLabels.ErrorMessage = "Numeric value required";
                args.IsValid = false;
            }
            else if (bagLabels < 0)
            {
                ValidatorBagLabels.ErrorMessage = "Positive value required";
                args.IsValid = false;
            }
            else if (bagLabels > 9)
            {
                ValidatorBagLabels.ErrorMessage = "Maximum number of bag labels is 9";
                args.IsValid = false;
            }
        }
    }

    protected void ValidateDuration(object sender, ServerValidateEventArgs args)
    {
        if (_mode == "Template" && chkJVM.Checked)
        {
            if (txtDuration.Text.Length == 0)
            {
                ValidatorDuration.ErrorMessage = "Required field";
                args.IsValid = false;
            }
            else
            {
                bool durationIsNumeric = false;
                int duration = 0;
                durationIsNumeric = int.TryParse(txtDuration.Text, out duration);
                if (!durationIsNumeric)
                {
                    ValidatorDuration.ErrorMessage = "Numeric value required";
                    args.IsValid = false;
                }
                else if (duration < 1)
                {
                    ValidatorDuration.ErrorMessage = "Positive value required";
                    args.IsValid = false;
                }
                else if (duration > 999)
                {
                    ValidatorDuration.ErrorMessage = "Maximum value 999";
                    args.IsValid = false;
                }
            }
        }
    }
    protected void ValidateSlots(object sender, ServerValidateEventArgs args)
    {
        if (_mode == "Template" && chkJVM.Checked)
        {
            if (chkBreakfast.Checked == false && chkLunch.Checked == false && chkTea.Checked == false && chkNight.Checked == false)
            {
                ValidatorSlots.ErrorMessage = "Please select at least one slot";
                args.IsValid = false;
            }
        }
    }


    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            if (_mode == "Template")
            {
                CheckDescAndSave("Save");
            }
            else if (_mode == "Batch")
            {
                SaveBatch();
            }
        }
    }
    
    protected void btnCancel_Click(object sender, EventArgs e)
    {
        //ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "closeForm", "window.close();", true);
        if (_mode == "Template" && FormHasChanged())
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "doCancel", "if (ICWConfirm('You will lose any changes, are you sure?', \"Yes,No\", \"Cancel\",\"dialogHeight:80px;dialogWidth:300px;resizable:yes;status:no;help:no;\") == \"Yes\") {window.close();}", true);
        }
        else
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "closeForm", "window.close();", true);
        }
    }

    protected void SaveBatch()
    {
        using (RepeatDispensingBatchProcessor processor = new RepeatDispensingBatchProcessor())
        {
            RepeatDispensingBatchLine batch = new RepeatDispensingBatchLine();
            batch.BagLabelsPerPatient = int.Parse(txtBagLabels.Text);
            batch.Description = txtDescription.Text;
            batch.Factor = int.Parse(ddlFactor.SelectedValue);
            batch.RepeatDispensingTemplateID = _TemplateID > 0 ? _TemplateID : (int?)null;
            batch.Status = BatchStatus.Incomplete;
            batch.LocationID = hdnLocationID.Value.Length > 0 && int.Parse(hdnLocationID.Value) > 0 ? int.Parse(hdnLocationID.Value) : (int?)null;
            if (chkJVM.Visible && chkJVM.Checked)
            {
                batch.Breakfast = chkBatchBreakfast.Checked;
                batch.Lunch = chkBatchLunch.Checked;
                batch.Night = chkBatchNight.Checked;
                batch.SortByDate = optSortTime.Checked ? true : false;
                batch.IncludeManual = chkManual.Checked;
                System.Globalization.CultureInfo culture = new System.Globalization.CultureInfo("en-GB");
                batch.StartDate = Convert.ToDateTime(txtFromDate.Text, culture);
                //03Apr13 AJK 60503 Changed value check
                batch.StartSlot = chkFromBreakfast.Checked && hdnFBV.Value == "visible" ? 1
                                    : (chkFromLunch.Checked && hdnFLV.Value == "visible" ? 2
                                    : (chkFromTea.Checked && hdnFTV.Value == "visible" ? 3
                                    : 4));
                batch.Tea = chkBatchTea.Checked;
                int endSlot = 0;
                endSlot = chkToNight.Checked && hdnTNV.Value == "visible" ? 4
                                    : (chkToTea.Checked && hdnTTV.Value == "visible" ? 3
                                    : (chkToLunch.Checked && hdnTLV.Value == "visible" ? 2
                                    : (chkToBreakfast.Checked && hdnTBV.Value == "visible" ? 1
                                    : 0)));
                int slots = 0;
                slots = 5 - (int)batch.StartSlot; //Slots in first day
                slots += endSlot; //Slots in last day
                DateTime endDate = Convert.ToDateTime(txtTo.Text, culture);
                TimeSpan ts = endDate - (DateTime)batch.StartDate;
                if (ts.Days > 0)
                {
                    slots += (4 * (ts.Days - 1));
                }
                batch.TotalSlots = slots;
            }
            processor.Update(batch);
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "closeForm", "window.returnValue='" + batch.BatchID.ToString() + "," + chkSelectPatients.Checked.ToString() + "';window.close();", true);
        }
    }

    protected void CheckDescAndSave(string saveType)
    {
        if (_mode == "Template")
        {
            //Check if description is in use
            List<RepeatDispensingBatchTemplateLine> templateList = new List<RepeatDispensingBatchTemplateLine>();
            using (RepeatDispensingBatchTemplateProcessor processor = new RepeatDispensingBatchTemplateProcessor())
            {
                templateList = processor.LoadByDescription(txtDescription.Text);
                if (templateList.Count == 1 && (saveType == "SaveAs" || (saveType == "Save" && templateList[0].RepeatDispensingBatchTemplateID.ToString() != hdnTemplateID.Value)))
                {
                    TrySave(false, saveType);
                }
                else
                {
                    Save(false, saveType);
                }
            }
        }
    }

    protected void btnSaveAs_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
            CheckDescAndSave("SaveAs");
    }

    protected void CheckManual()
    {
        // Only show the checkbox to include manual items if either it's a template (with all slot boxes checked) or it's a batch (with all slot boxes checked) 
        // where it is not a medicine management site or not a jvm batch/template
        if  (
                (
                    (_mode == "Template" && chkBreakfast.Checked && chkLunch.Checked && chkTea.Checked && chkNight.Checked) 
                    || 
                    (_mode == "Batch" && chkBatchBreakfast.Checked && chkBatchLunch.Checked && chkBatchNight.Checked && chkBatchTea.Checked)
                )
                && 
                (!(bool)WConfigurationController.LoadASetting(_SiteID,"D|RptDisp","","MedicineManagement","N",false,typeof(bool)) || !divJVM.Visible || !chkJVM.Checked)
            )
        {
            chkManual.Visible = true;
            lblIncludeManual.Visible = true;
        }
        else
        {
            chkManual.Visible = false;
            chkManual.Checked = false;
            lblIncludeManual.Visible = false;
        }
    }

    protected void chkSlot_CheckedChanged(object sender, EventArgs e)
    {
        CheckManual();
    }

    protected void Save(bool saveByDescription, string saveType)
    {
        using (RepeatDispensingBatchTemplateProcessor processor = new RepeatDispensingBatchTemplateProcessor())
        {
            RepeatDispensingBatchTemplateLine template = new RepeatDispensingBatchTemplateLine();
            if (saveByDescription)
            {
                //Load and overwrite the template of the same description
                List<RepeatDispensingBatchTemplateLine> templateList = new List<RepeatDispensingBatchTemplateLine>();
                templateList = processor.LoadByDescription(txtDescription.Text);
                template = templateList[0];
            }
            else
            {
                if (saveType == "Save")
                {
                    template.RepeatDispensingBatchTemplateID = _TemplateID;
                }
            }
            template.BagLabels = int.Parse(txtBagLabels.Text);
            template.Description = txtDescription.Text;
            template.Discharge = true; // = chkDischarge.Checked;	-- XN 09Jun11 F0119748 
            template.InPatient = true; // = chkInPatient.Checked;	-- XN 09Jun11 F0119748 	
            template.InUse = chkInUse.Checked;
            template.JVM = chkJVM.Checked;
            template.JVMBreakfast = chkBreakfast.Checked;
            template.JVMDefaultStartTomorrow = chkDefaultStartTomorrow.Checked;
            template.JVMDuration = int.Parse(txtDuration.Text);
            template.JVMIncludeManual = chkManual.Visible == true ? chkManual.Checked : false;
            template.JVMLunch = chkLunch.Checked;
            template.JVMNight = chkNight.Checked;
            template.JVMSortByAdminSlot = optSortTime.Checked;
            template.JVMTea = chkTea.Checked;
            template.Leave = true; //chkLeave.Checked;		-- XN 09Jun11 F0119748 
            int locationID;
            template.LocationID = int.TryParse(hdnLocationID.Value, out locationID) ? locationID : (int?)null;
            template.OutPatient = true; //chkOutPatient.Checked;	-- XN 09Jun11 F0119748 
            template.SelectPatientsByDefault = chkSelectPatients.Checked;
            processor.Update(template);
            //hdnTemplateID.Value = template.RepeatDispensingBatchTemplateID.ToString();
            // Temp
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "closeForm", "window.returnValue='" + template.RepeatDispensingBatchTemplateID.ToString() + "';window.close();", true);
        }
    }

    protected void chkJVM_CheckedChanged(object sender, EventArgs e)
    {
        if (divJVM.Visible != chkJVM.Checked)
        {
            divJVM.Visible = chkJVM.Checked;
        }
    }

    /// <summary>Get the ward name</summary>
    /// <param name="sessionId">Session Id</param>
    /// <param name="locationId">Location Id</param>
    /// <returns></returns>
    [WebMethod]
	public static string GetWardName(int sessionId, int locationId)
	{
        SessionInfo.InitialiseSession(sessionId);
        return ascribe.pharmacy.icwdatalayer.Ward.GetByID(locationId).Description;
	}
}
