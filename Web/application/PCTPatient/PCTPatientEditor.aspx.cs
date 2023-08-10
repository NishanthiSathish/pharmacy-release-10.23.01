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
using ascribe.pharmacy.pharmacydatalayer;

// 20Mar12 AJK Changed references to PharmacyPatientInfo from RDispPatientInfo
public partial class application_PCTPatient_PCTPatientEditor : System.Web.UI.Page
{
    int _SessionID = -1;
    int _EntityID;
    bool _PageIsValid;
    
    protected void Page_Load(object sender, EventArgs e)
    {
        _SessionID = int.Parse(Request.QueryString["SessionID"]);
        int siteID = 0;
        if (int.TryParse(Request.QueryString["SiteID"], out siteID))
            SessionInfo.InitialiseSessionAndSiteID(_SessionID, int.Parse(Request.QueryString["SiteID"]));
        else
            SessionInfo.InitialiseSession(_SessionID);
        _EntityID = int.Parse(Request.QueryString["EntityID"]);

        txtHUHCNo.Attributes.Add("onkeyup", "txtHUHCNo_KeyUp();");
        optCSC.Attributes.Add("onclick", "optCSC_Click();");
        optPRH.Attributes.Add("onclick", "optPRH_Click();");
        optNoConc.Attributes.Add("onclick", "optNoConc_Click();");
        txtHUHCExp.Attributes["readonly"] = "readonly";
        txtCSCExp.Attributes["readonly"] = "readonly";


        if (!this.IsPostBack)
        {
            PCTPatientLine patient = new PCTPatientLine();
            using (PCTPatientProcessor processor = new PCTPatientProcessor())
            {
                patient = processor.LoadByEntityID(_EntityID);
            }
            hdnEntityID.Value = _EntityID.ToString();
            txtHUHCNo.Text = patient.HUHCNo == null ? "" : patient.HUHCNo;
            txtHUHCExp.Text = patient.HUHCExp == null ? "" : string.Format("{0:dd/MM/yyyy}", patient.HUHCExp);
            optCSC.Checked = patient.CSC == true ? true : false;
            txtCSCExp.Text = patient.CSCExp == null ? "" : string.Format("{0:dd/MM/yyyy}", patient.CSCExp);
            optPRH.Checked = patient.PermResHokianga == true ? true : false;
            chkPHO.Checked = patient.PHORegistered == true ? true : false;
            optNoConc.Checked = optCSC.Checked || optPRH.Checked ? false : true;
            //if (txtHUHCNo.Text.Length == 0)
            //{
            //    txtHUHCNo.Attributes["readonly"] = "readyonly";
            //}
            //if (txtCSCExp.Text.Length == 0)
            //{
            //    txtCSCExp.Attributes["readonly"] = "readyonly";
            //}
            using (PharmacyPatientInfo dbPatient = new PharmacyPatientInfo())
            {
                dbPatient.LoadByEntityID(_EntityID);
                txtNHINo.Text = dbPatient[0].NHINumber == null ? "" : dbPatient[0].NHINumber;
                if (txtNHINo.Text.Length > 0 && !(dbPatient[0].NHINumberIsValid == null ? false : Convert.ToBoolean(dbPatient[0].NHINumberIsValid)))
                {
                    lblNHIValid.Visible = true;
                }
            }
        }
    }

    protected void btnCancel_Click(object sender, EventArgs e)
    {
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "closeForm", "window.close();", true);
    }

    protected bool ValidatePage()
    {
        if (optCSC.Checked)
        {
            System.Globalization.CultureInfo culture = new System.Globalization.CultureInfo("en-GB");
            DateTime cscExp;
            if (txtCSCExp.Text.Length == 0)
            {
                //ValidatorCSCExp.ErrorMessage = "Required";
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "saveFailed", "alert('CSC Expiry Date is a required field.');", true); // Display failed message
                return false;
            }
            else if (!DateTime.TryParse(txtCSCExp.Text, culture, System.Globalization.DateTimeStyles.None, out cscExp))
            {
                //ValidatorCSCExp.ErrorMessage = "Invalid date format";
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "saveFailed", "alert('CSC Expiry Date is invalid.');", true); // Display failed message
                return false;
            }
        }
        if (txtHUHCNo.Text.Length > 0)
        {
            System.Globalization.CultureInfo culture = new System.Globalization.CultureInfo("en-GB");
            DateTime huhcExp;
            if (txtHUHCExp.Text.Length == 0)
            {
                //ValidatorHUHCExp.ErrorMessage = "Required";
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "saveFailed", "alert('HUHC Expiry Date is a required field.');", true); // Display failed message
                return false;
            }
            else if (!DateTime.TryParse(txtHUHCExp.Text, culture, System.Globalization.DateTimeStyles.None, out huhcExp))
            {
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "saveFailed", "alert('HUHC Expiry Date is invalid.');", true); // Display failed message
                //ValidatorHUHCExp.ErrorMessage = "Invalid date format";
                return false;
            }
        }
        return true;
    }

    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (ValidatePage())
        {
            System.Globalization.CultureInfo culture = new System.Globalization.CultureInfo("en-GB");
            using (PCTPatientProcessor processor = new PCTPatientProcessor())
            {
                PCTPatientLine patient = new PCTPatientLine();
                patient.EntityID = int.Parse(hdnEntityID.Value);
                patient.CSC = optCSC.Checked;
                patient.CSCExp = patient.CSC ? (DateTime?)Convert.ToDateTime(txtCSCExp.Text, culture) : null;
                patient.HUHCExp = txtHUHCNo.Text.Length > 0 ? (DateTime?)Convert.ToDateTime(txtHUHCExp.Text, culture) : null;
                patient.HUHCNo = txtHUHCNo.Text;
                patient.PermResHokianga = optPRH.Checked;
                patient.PHORegistered = chkPHO.Checked;
                processor.Update(patient);
            }
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Close_Window2", "window.returnValue='cancel';self.close();", true); // Close the current window
        }
    }
}
