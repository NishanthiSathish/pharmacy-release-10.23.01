// ======================================================================================================================
// Author: Aidan Kent (AJK)
// Description: Codebehind for RepeatDispensingLinking.aspx
//
//	Modification History:
//  01May11 TH   Added JVM Check - Currently only place holder until validation component can supply setting.
//  16Apr12 AJK  31239 Added new row to table rowUpdated with a label to display who updated the settings last and when
//  15aug13 TH   70134 Added new plumbing for new DoC rpt Disp fields
//  20May15 XN   Update code to remove the LabelProcessor class 
// ======================================================================================================================

using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.businesslayer;
//using ascribe.pharmacy.pharmacydatalayer;

public partial class application_RepeatDispensing_RepeatDispensingLinking : System.Web.UI.Page
{
    int _dispensingID;
    //int[] qtyRequired = new int[]{120,121,122,130,131};
    //bool _qtyMandatory;

    
    protected void Page_Load(object sender, EventArgs e)
    {
        int _sessionID = int.Parse(Request.QueryString["SessionID"]);
        SessionInfo.InitialiseSession(_sessionID);
        _dispensingID = int.Parse(Request.QueryString["DispensingID"]);
                
        if (!Page.IsPostBack)
        {
            // Remove to get rid of LabelProcessor 20May15 XN 
            //LabelProcessor labelProcessor = new LabelProcessor();
            //LabelObject label = labelProcessor.LoadByRequestID(_dispensingID);

            //lblPrescription.Text = label.GetPrescriptionsDescription();
            //lblLabel.Text        = label.Text;

            RequestRow dispensing  = ascribe.pharmacy.icwdatalayer.Request.GetByRequestID(_dispensingID);
            RequestRow prescription = null;
            if (dispensing != null)
                prescription = ascribe.pharmacy.icwdatalayer.Request.GetByRequestID(dispensing.RequestID_Parent);
            lblPrescription.Text = (prescription == null) ? string.Empty : prescription.Description;
            lblLabel.Text = WLabel.GetByRequestID(_dispensingID).Text;

            btnDelete.Enabled = false;

            //Need to get robot name here
            RepeatDispensingValidation RobotNameCheck = new RepeatDispensingValidation();
            string strRobot = RobotNameCheck.GetPackerName();
            //string strRobot = "JVADTPS";
            if (strRobot == "JVADTPS")
            {
                lblJVM.Visible = true;
                chkJVM.Visible = true;
                
            }
            //if 
            //btnSave.Enabled = false;
            using (RdRxLinkDispensingProcessor processor = new RdRxLinkDispensingProcessor())
            {
                //Here we need to work out whether we need to overlay the new fields labels
                string lblNumofRpts = SettingsController.Load("Pharmacy", "RepeatDispensing", "NumberofRepeatsLabel", "Number of Repeats");
                lblNumberOfRepeats.Text = lblNumofRpts;
                string lblRptsRemain = SettingsController.Load("Pharmacy", "RepeatDispensing", "RepeatsRemainingLabel", "Repeats Remaining");
                lblRepeatsRemaining.Text = lblRptsRemain;
                string lblRxExpired = SettingsController.Load("Pharmacy", "RepeatDispensing", "PrescriptionExpiryLabel", "Prescription Expiry date");
                lblRxExpiryDate.Text = lblRxExpired;
                
                RDRxLinkDispensingLine link = processor.LoadByDispensingID(_dispensingID);
                RepeatDispensingValidation validator = new RepeatDispensingValidation();
                if (link == null)
                {
                    link = new RDRxLinkDispensingLine();
                    chkInUse.Checked = true;
                    txtQuantity.Text = "";
                    btnDelete.Enabled = false;
                    string strExpiredDays = SettingsController.Load("Pharmacy", "RepeatDispensing", "PrescriptionExpiryDefaultDays", "0");
                    int intExpiredDays = int.TryParse(strExpiredDays, out intExpiredDays) ? intExpiredDays : 0;
                    if (intExpiredDays > 0)
                    {
                        txtExpDate.Text = DateTime.Now.AddDays(intExpiredDays).ToPharmacyDateString();
                    }
                    else
                    {
                        txtExpDate.Text = "";
                    }
                    txtRepeatsRemaining.Text = "";
                    txtNumberOfRepeats.Text = "";
                    //bool tempResult = validator.ValidateDispensingForLinking(_dispensingID, 0,true,null,null,null,false);
                    bool tempResult = validator.ValidateDispensingForLinking(_dispensingID, 0, true, null, null, null);  //09Sep13 TH Reverted
                    chkJVM.Checked = false;
                }
                else
                {
                    chkInUse.Checked = link.InUse;
                    txtQuantity.Text = link.Quantity == 0 ? "" : link.Quantity.ToString();
                    btnDelete.Enabled = true;
                    txtNumberOfRepeats.Text = link.RepeatTotal == 0 ? "" : link.RepeatTotal.ToString();
                    txtRepeatsRemaining.Text = link.RepeatRemaining == 0 ? "" : link.RepeatRemaining.ToString();
                    txtExpDate.Text = link.PrescriptionExpiry.HasValue ? link.PrescriptionExpiry.ToString() : "";
                    //bool tempResult = validator.ValidateDispensingForLinking(_dispensingID, link.Quantity, link.JVM, link.RepeatTotal, link.RepeatRemaining, link.PrescriptionExpiry, false);
                    bool tempResult = validator.ValidateDispensingForLinking(_dispensingID, link.Quantity, link.JVM, link.RepeatTotal, link.RepeatRemaining, link.PrescriptionExpiry); //09Sep13 TH Removed skipPatient
                    //chkJVM.Checked = link.JVM;
                    if (link.JVM)
                    {
                        chkJVM.Checked = true;
                        lblQuantity.Visible = false;
                        lblQtyWarning.Visible = false;
                        txtQuantity.Visible = false;
                        lblIssueUnits.Visible = false;
                        txtQuantity.Text = "";
                    }
                    //  16Apr12 AJK 31239 Display updated info
                    if (link.Updated.HasValue && !string.IsNullOrEmpty(link.UpdatedByDescription))
                    {
                        lblUpdated.Text = "Last edit by " + link.UpdatedByDescription + " on " + string.Format("{0:dd/MM/yyyy}", link.Updated) + " at " + string.Format("{0:HH:mm}", link.Updated);
                        rowUpdated.Visible = true;
                    }
                    txtNumberOfRepeats.Text = link.RepeatTotal == 0 ? "" : link.RepeatTotal.ToString();
                    txtRepeatsRemaining.Text = link.RepeatRemaining == 0 ? "" : link.RepeatRemaining.ToString();
                    txtExpDate.Text = link.PrescriptionExpiry == null ? "" : string.Format("{0:dd/MM/yyyy}", link.PrescriptionExpiry);
                    //01Sep13 TH TFS 72252
                    if (link.RepeatTotal > 0 && txtRepeatsRemaining.Text == "")
                    {
                        txtRepeatsRemaining.Text = "0";
                    }

                }
                
                //bool enableQuantity = false;
                //_qtyMandatory = false;
                lblErrors.Text = "";
                foreach (ValidationError error in validator.ValidationErrors)
                {
                    if (error.Exception)
                    {
                        lblErrors.Text += error.ErrorMessage + "<BR/>";
                    }
                    //if (qtyRequired.Contains(error.ErrorCode))
                    //{
                    //    //enableQuantity = true;
                    //    _qtyMandatory = false;
                    //}
                }

                //if (_qtyMandatory == false && RdRxLinkDispensingProcessor.IsManualEntryQuantityType(_dispensingID) == true)
                //    _qtyMandatory = true;
                //if (RdRxLinkDispensingProcessor.IsManualEntryQuantityType(_dispensingID) == true)
                //    _qtyMandatory = true;

                lblIssueUnits.Text = RdRxLinkDispensingProcessor.IssueUnits(_dispensingID);


                //if (_qtyMandatory)
                //{
                //    txtQuantity.Enabled = true;
                //    txtQuantity.CssClass = "Field";
                //}
                //else
                //{
                //    txtQuantity.Enabled = false;
                //    txtQuantity.CssClass = "FieldDisabled";
                //}
                
            }
        }
    }
  
    //protected void btnCancel_Click(object sender, EventArgs e)
    //{
    //    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Close_Window1", "window.returnValue='cancel';self.close();", true); // Close the current window
    //}

    protected void btnDelete_Click(object sender, EventArgs e)
    {
        RdRxLinkDispensingProcessor.Delete(_dispensingID);
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Close_Window2", "window.returnValue='cancel';self.close();", true); // Close the current window
    }
    protected void btnSave_Click(object sender, EventArgs e)
    {
        Page.Validate();
        if (Page.IsValid)
        {
            lblErrors.Text = "";
            //lblErrorHeadingDiv.Visible = true;
            RdRxLinkDispensingProcessor processor = new RdRxLinkDispensingProcessor();
            RDRxLinkDispensingLine link = processor.LoadByDispensingID(_dispensingID);
            if (link == null)
            {
                link = new RDRxLinkDispensingLine(); 
            }
            link.DispensingID = _dispensingID;
            link.InUse = chkInUse.Checked;
            link.JVM = chkJVM.Checked;
            double result;
            //link.Quantity = double.TryParse(txtQuantity.Text, out result) ? double.Parse(txtQuantity.Text) : 0;
            link.Quantity = double.TryParse(txtQuantity.Text, out result) ? result : 0;

            
            
            int repeatresult;
            link.RepeatTotal = int.TryParse(txtNumberOfRepeats.Text, out repeatresult) ? repeatresult : 0;

            link.RepeatRemaining = int.TryParse(txtRepeatsRemaining.Text, out repeatresult) ? repeatresult : 0;

            DateTime repeatDate;
            link.PrescriptionExpiry = DateTime.TryParse(txtExpDate.Text, out repeatDate) ? repeatDate : (DateTime?)null;

            //bool enableQuantity = false;

            if (processor.ValidateForUpdate(link))
            {
                // Delete any existing prescriptions linked to the dispensing
                int prescriptionID = RdRxLinkDispensingProcessor.PrescriptionIDByDispensingID(_dispensingID);
                //RdRxLinkDispensingProcessor.DeleteByPrescriptionID(prescriptionID);  //08Aug11 TH Removed to allow split dose.

                // Save the updated\new data
                processor.Update(link);

                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Close_Window3", "window.returnValue='cancel';self.close();", true); // Close the current window
            }
            else
            {
                foreach (ValidationError error in processor.ValidationErrors)
                {
                    if (error.Exception)
                    {
                        lblErrors.Text += error.ErrorMessage + "<BR/>";
                    }
                    //if (qtyRequired.Contains(error.ErrorCode))
                    //{
                    //    enableQuantity = true;
                    //}

                }
                //if (enableQuantity)
                //{
                //    txtQuantity.Enabled = true;
                //    txtQuantity.CssClass = "Field";
                //}
                //else
                //{
                //    txtQuantity.Enabled = false;
                //    txtQuantity.CssClass = "FieldDisabled";
                //}
            }
        }
    }
    protected void chkJVM_Change(object sender, EventArgs e)
    {
        
            if (chkJVM.Checked)
            {
                lblQuantity.Visible = false;
                lblQtyWarning.Visible = false;
                txtQuantity.Visible = false;
                lblIssueUnits.Visible = false;
                txtQuantity.Text = "";
            }
            else
            {
                lblQuantity.Visible = true;
                lblQtyWarning.Visible = true;
                txtQuantity.Visible = true;
                lblIssueUnits.Visible = true;
            }
       
    }
    protected void Validate(object sender, ServerValidateEventArgs args)
    {
        ValidatorQuantity.ErrorMessage = "";
        ValidatorNumberOfRepeats.ErrorMessage = "";
        ValidatorRepeatsRemaining.ErrorMessage = "";
        ValidatorRxExpiry.ErrorMessage = "";
        args.IsValid = true;
        double result;

        if (!chkJVM.Checked && (txtQuantity.Text.Length > 0))
        {
            if (double.TryParse(txtQuantity.Text, out result) == false)
            {
                ValidatorQuantity.ErrorMessage = "Quantity must be numeric";
                args.IsValid = false;
            }
            else if (Convert.ToDouble(txtQuantity.Text) <= 0 || Convert.ToDouble(txtQuantity.Text) > 9999)
            {
                ValidatorQuantity.ErrorMessage = "Quantity must be between 0 and 9999";
                args.IsValid = false;
            }
        }
        else if (!chkJVM.Checked && (RdRxLinkDispensingProcessor.IsManualEntryQuantityType(_dispensingID)))
        {
            ValidatorQuantity.ErrorMessage = "Quantity must be entered";
            args.IsValid = false;
        }

        if (rowRepeats.Visible == true)
        {
            if (txtNumberOfRepeats.Text.Length > 0)
            {
                if (double.TryParse(txtNumberOfRepeats.Text, out result) == false)
                {
                    ValidatorNumberOfRepeats.ErrorMessage = "Number of repeats must be numeric";
                    args.IsValid = false;
                }
                //else if (Convert.ToDouble(txtNumberOfRepeats.Text) <= 0 || Convert.ToDouble(txtNumberOfRepeats.Text) > 999)
                else if (Convert.ToDouble(txtNumberOfRepeats.Text) < 0 || Convert.ToDouble(txtNumberOfRepeats.Text) > 999) //TFS
                {
                    ValidatorNumberOfRepeats.ErrorMessage = "Number of repeats must be between 0 and 999";
                    args.IsValid = false;
                }
            }
            if (txtRepeatsRemaining.Text.Length > 0)
            {
                if (double.TryParse(txtRepeatsRemaining.Text, out result) == false)
                {
                    ValidatorRepeatsRemaining.ErrorMessage = "Repeats remaining must be numeric";
                    args.IsValid = false;
                }
                //else if (Convert.ToDouble(txtRepeatsRemaining.Text) <= 0 || Convert.ToDouble(txtRepeatsRemaining.Text) > 999)
                else if (Convert.ToDouble(txtRepeatsRemaining.Text) < 0 || Convert.ToDouble(txtRepeatsRemaining.Text) > 999)
                {
                    ValidatorRepeatsRemaining.ErrorMessage = "Repeats remaining must be between 0 and 999";
                    args.IsValid = false;
                }
            }
            if (txtExpDate.Text.Length > 0)
            {
                DateTime result2;
                if (DateTime.TryParse(txtExpDate.Text, out result2) == false)
                {
                    ValidatorRxExpiry.ErrorMessage = "Prescription expiry date must be a valid date format";
                    args.IsValid = false;
                }
            }
        }
    }
}
