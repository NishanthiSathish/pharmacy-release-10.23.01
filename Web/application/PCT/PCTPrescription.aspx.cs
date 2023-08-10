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
using ascribe.pharmacy;
using ascribe.pharmacy.pharmacydatalayer;
using ENTRTL10;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.businesslayer;
using System.Xml;
using System.Collections.Generic;
using Telerik.Web.UI;

// 20Mar12 AJK Changed references to PharmacyPatientInfo from RDispPatientInfo and Episode which moved assembly from PharmacyDataLayer to ICWDataLayer
public partial class application_PCT_PCTPrescription : System.Web.UI.Page
{
    protected void Page_Load(object sender, EventArgs e)
    {
        int _SessionID;
        _SessionID = int.Parse(Request.QueryString["SessionID"]);
        SessionInfo.InitialiseSession(_SessionID);
        ENTRTL10.EntityRead entityRead = new ENTRTL10.EntityRead();
        int entityID = entityRead.GetSelectedEntity(_SessionID);
        int episodeID = entityRead.CurrentEpisodeID(_SessionID);
        string method = Request.QueryString["Method"];
        if (!IsPostBack)
        {
            if (method == "LinkPCTPrescription")
            {
                using (PCTPrescriptionProcessor processor = new PCTPrescriptionProcessor())
                {
                    int pctPrescriptionID = int.Parse(Request.QueryString["PCTPrescriptionID"]);
                    int requestID_Prescription = int.Parse(Request.QueryString["RequestID_Prescription"]);
                    PCTPrescriptionLine rx = new PCTPrescriptionLine();
                    rx = processor.LoadByPCTPrescriptionID(pctPrescriptionID);
                    rx.RequestID_Prescription = requestID_Prescription;
                    processor.Update(rx);
                    ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "closeForm", "window.close();", true);
                }
            }
            else
            {
                using (ascribe.pharmacy.pharmacydatalayer.PharmacyPatientInfo dbPatient = new ascribe.pharmacy.pharmacydatalayer.PharmacyPatientInfo())
                {
                    dbPatient.LoadByEntityID(entityID);
                    if (dbPatient.Count == 0)
                        throw new ApplicationException(string.Format("Patient not found (entityID={0})", entityID));
                    else if (dbPatient[0].DOB == null)
                    {
                        //lblText.Text = "DOB is missing. ";
                        //lblNotificationText.Text = "DOB is missing.";
                        //RadNotification1.Show();
                        RadWindowManager1.RadAlert("DOB is missing.", 330, 100, "Unable to create PCT prescription", "alertCallBackFn");
                    }
                    else if (dbPatient[0].NHINumberIsValid != true)
                    {
                        //lblText.Text += "NHI Number is invalid. ";
                        //lblNotificationText.Text = "NHI Number is invalid.";
                        //RadNotification1.Show();
                        RadWindowManager1.RadAlert("NHI Number is invalid.", 330, 100, "Unable to create PCT prescription", "alertCallBackFn");
                    }
                    else
                    {
                        using (ConsultantProcessor consultantProcessor = new ConsultantProcessor())
                        {
                            RadComboBoxItem blank = new RadComboBoxItem("", "-1");
                            rcboSpecialist.Items.Add(blank);
                            RadComboBoxItem blank2 = new RadComboBoxItem("", "-1");
                            rcboConsultants.Items.Add(blank2);
                            List<ConsultantLine> consultants = consultantProcessor.LoadAllByAliasGroupDescription("MCNZNumber");
                            for (int i = 0; i < consultants.Count; i++)
                            {
                                RadComboBoxItem item = new RadComboBoxItem(consultants[i].FullName, consultants[i].EntityID.ToString());
                                rcboConsultants.Items.Add(item);
                                RadComboBoxItem item2 = new RadComboBoxItem(consultants[i].FullName, consultants[i].EntityID.ToString());
                                rcboSpecialist.Items.Add(item2);
                            }
                        }

                        // 16Jan13 XN 48747 Replace with loading up consultant directly as code below use pEpisodeSelect (which will be slow)
                        //using (ascribe.pharmacy.icwdatalayer.Episode episode = new ascribe.pharmacy.icwdatalayer.Episode())
                        //{
                        //    episode.LoadByEpisodeID(episodeID, 0);
                        //    if (episode.Count > 0 && episode[0].EntityID_Consultant.HasValue)
                        //    {
                        //        RadComboBoxItem item = new RadComboBoxItem();
                        //        item = rcboConsultants.FindItemByValue(episode[0].EntityID_Consultant.ToString());
                        //        if (item != null) item.Selected = true;
                        //    }
                        //}
                        using (ascribe.pharmacy.icwdatalayer.Consultant consultant = new ascribe.pharmacy.icwdatalayer.Consultant())
                        {
                            consultant.LoadByEpisode(episodeID);
                            if (consultant.Count > 0)
                            {
                                RadComboBoxItem item = new RadComboBoxItem();
                                item = rcboConsultants.FindItemByValue(consultant[0].EntityID.ToString());
                                if (item != null) item.Selected = true;
                            }
                        }
                        using (PCTOncologyPatientGrouping oncologyGroup = new PCTOncologyPatientGrouping())
                        {
                            RadComboBoxItem blank3 = new RadComboBoxItem("", "-1");
                            rcboOncology.Items.Add(blank3);
                            oncologyGroup.LoadAll();
                            for (int i = 0; i < oncologyGroup.Count; i++)
                            {
                                RadComboBoxItem item = new RadComboBoxItem(oncologyGroup[i].Description, oncologyGroup[i].PCTOncolologyPatientGroupingID.ToString());
                                rcboOncology.Items.Add(item);
                            }
                        }
                    }
                }
            }
        }
    }
    protected void rbtnOK_Click(object sender, EventArgs e)
    {
        if (Page.IsValid)
        {
            int PCTPrescriptionID = 0;
            using (PCTPrescriptionProcessor processor = new PCTPrescriptionProcessor())
            {
                PCTPrescriptionLine rx = new PCTPrescriptionLine();
                rx.EndorsementDate = rdatEndorsement.SelectedDate;
                rx.FullWastage = chkWastage.Checked;
                rx.PCTOncologyPatientGroupingID = int.Parse(rcboOncology.SelectedValue);
                rx.PrescriberEntityID = int.Parse(rcboConsultants.SelectedValue);
                rx.PrescriptionFormNumber = rtxtFormNumber.Text;
                rx.SpecialAuthorityNumber = rtxtSLANumber.Text.Trim().Length > 0 ? rtxtSLANumber.Text.Trim() : null;
                rx.SpecialistEndorserEntityID = int.Parse(rcboSpecialist.SelectedValue) > 0 ? int.Parse(rcboSpecialist.SelectedValue) : (int?)null;
                processor.Update(rx);
                PCTPrescriptionID = rx.PCTPrescriptionID;
            }
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "closeFormWithReturn", "window.returnValue = '" + PCTPrescriptionID + "';window.close();", true);
        }
    }
    protected void rvlPCTPrescriber_ServerValidate(object source, ServerValidateEventArgs args)
    {
        if (string.IsNullOrEmpty(rcboConsultants.Text.Trim()))
        {
            args.IsValid = false;
        }
        else
        {
            args.IsValid = true;
        }
    }
    protected void rvlOncology_ServerValidate(object source, ServerValidateEventArgs args)
    {
        if (string.IsNullOrEmpty(rcboOncology.Text.Trim()))
        {
            args.IsValid = false;
        }
        else
        {
            args.IsValid = true;
        }
    }
    protected void rvlFormNumber_ServerValidate(object source, ServerValidateEventArgs args)
    {
        int temp = 0;
        if (string.IsNullOrEmpty(rtxtFormNumber.Text.Trim()))
        {
            rvlFormNumber.ErrorMessage = "Required";
            args.IsValid = false;
        }
        else if (!int.TryParse(rtxtFormNumber.Text.Trim(), out temp))
        {
            rvlFormNumber.ErrorMessage = "Must be numeric";
            args.IsValid = false;
        }
        else
        {
            args.IsValid = true;
        }
    }
    protected void rvlEndorsementDate_ServerValidate(object source, ServerValidateEventArgs args)
    {
        if (!string.IsNullOrEmpty(rcboSpecialist.Text.Trim()) && !rdatEndorsement.SelectedDate.HasValue)
        {
            args.IsValid = false;
        }
        else
        {
            args.IsValid = true;
        }
    }
    protected void rvlSLANumber_ServerValidate(object source, ServerValidateEventArgs args)
    {
        long temp = 0;
        if (!string.IsNullOrEmpty(rtxtSLANumber.Text.Trim()) && !long.TryParse(rtxtSLANumber.Text.Trim(), out temp))
        {
            args.IsValid = false;
        }
        else
        {
            args.IsValid = true;
        }
    }
}
