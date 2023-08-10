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
using System.Xml;
using ascribe.pharmacy.businesslayer;
using System.Collections.Generic;
using ascribe.pharmacy.pharmacydatalayer;

public partial class application_RepeatDispensing_ICW_RepeatDispensing : System.Web.UI.Page
{
    protected int _SessionID = -1;        // SessionID
    private int _TemplateID = -1;
    private int _EntityID = -1;
    private int _BatchID = -1;
    List<RepeatDispensingPatientLine> selectedPatients = new List<RepeatDispensingPatientLine>();

    /// <summary>Will auto select patients if they are InUse and Avaiable</summary>
    protected bool selectPatientsByDefault = false;    

    /// <summary>Will always select all patients in the list</summary>
    protected bool forceSelectPatientsByDefault = false;

    protected void Page_Load(object sender, EventArgs e)
    {
        _SessionID = int.Parse(Request.QueryString["SessionID"]);
        SessionInfo.InitialiseSession(_SessionID);
        txtTemplate.Attributes["readonly"] = "readonly";
        txtBatchDesc.Attributes["readonly"] = "readonly";
        if (!IsPostBack)
        {
            //First load
        }
        else
        {
            if (hdnBatchID.Value.Length > 0)
            {
                _BatchID = int.Parse(hdnBatchID.Value);
            }
        }

        string target = Request["__EVENTTARGET"];
        string args = Request["__EVENTARGUMENT"];
        
        Dictionary<string,string> argsNameToValue = new Dictionary<string,string>();
        if (!string.IsNullOrEmpty(args))
        {
            foreach (string item in args.Split(new char[] { ',' }, StringSplitOptions.RemoveEmptyEntries))
            {
                string[] keyValuePair = item.Split(new char[] {':'}, 2, StringSplitOptions.RemoveEmptyEntries);
                string name = keyValuePair[0];
                string key  = (keyValuePair.Length == 2) ? keyValuePair[1] : string.Empty;
        		
	    	    argsNameToValue.Add(name, key);
	        }
	    }
	
        int batchID;
        switch (target)
        {
            case "BatchCreated":
                //Load form with template stuff                
                if (argsNameToValue.ContainsKey("BatchID") && int.TryParse(argsNameToValue["BatchID"], out batchID))
                {
                    selectPatientsByDefault = false;
                    if (argsNameToValue.ContainsKey("SelectPatientsByDefault") && !string.IsNullOrEmpty(argsNameToValue["SelectPatientsByDefault"]))
                    	selectPatientsByDefault = BoolExtensions.PharmacyParse(argsNameToValue["SelectPatientsByDefault"]);
                    
                    using (RepeatDispensingBatchProcessor processor = new RepeatDispensingBatchProcessor())
                    {
                        RepeatDispensingBatchLine batch = new RepeatDispensingBatchLine();
                        batch = processor.LoadByBatchID(batchID);
                        txtBatchDesc.Text = batch.Description;
                    }
                    if (hdnEntityID.Value != "")
                    {
                        _EntityID = int.Parse(hdnEntityID.Value);
                        forceSelectPatientsByDefault = selectPatientsByDefault;
                    }
                    LoadPatientsFromBatch(batchID);
                    _BatchID = batchID;
                    hdnBatchID.Value = _BatchID.ToString();

                    // Setup details about the template
                    RepeatDispensingBatchTemplateRow template = null;
                    if (argsNameToValue.ContainsKey("TemplateID") && int.TryParse(argsNameToValue["TemplateID"], out _TemplateID) && (_TemplateID > 0))
                        template = RepeatDispensingBatchTemplate.GetByByRepeatDispensingBatchTemplateID(_TemplateID);

                    if (template != null)
                        txtTemplate.Text = template.ToString();
                    else
                        ClearTemplate();
                }
                break;
        }
    }

    protected void LoadPatientsFromBatch(int batchID)
    {
        using (RepeatDispensingPatientProcessor processor = new RepeatDispensingPatientProcessor())
        {
            if (_EntityID > 0)
            {
                List<RepeatDispensingPatientLine> patients = new List<RepeatDispensingPatientLine>();
                patients.Add(processor.LoadByEntityID(_EntityID));
                rptData.DataSource = patients;
            }
            else
            {
                // Get list of available patients
                IEnumerable<RepeatDispensingPatientLine> patients = processor.LoadAvailable(batchID);
                
                // limit list to a single patient, 
                // but need to ensure the row that is returned is one that is In Use, and is available
                patients = (from p in patients
                            group p by p.EntityID into gp
                            select (from single_p in gp
                                    orderby single_p.InUse     descending, 
                                            single_p.Available descending
                                    select single_p).First());

                // Resort final list by Available, MatchedDesc, In Use, Surename, Forname
                // Where Available and In Use items set to Yes are at to of list and nulls are at the bottom
                // 
                patients = patients.OrderBy(t => t.Forename).OrderBy(t => t.Surname).OrderByDescending(t => t.InUse).OrderByDescending(t => t.Available);
                rptData.DataSource = patients;
            }
        }
        rptData.DataBind();
    }

    protected void btnPatient_Click(object sender, EventArgs e)
    {
        ENTRTL10.EntityRead entityRead = new ENTRTL10.EntityRead();
        _EntityID = entityRead.GetSelectedEntity(_SessionID);
        XmlDocument doc = new XmlDocument();
        doc.LoadXml(entityRead.PatientDetailByEntityIDXML(_SessionID, _EntityID));
        XmlNode patient;
        patient = doc.SelectSingleNode("/root/Patient");
        if (patient != null)
        {
            //We have a patient, load the form
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "loadByPatient", "DisplayBatchEditor('0','" + patient.Attributes["EntityID"].Value + "')", true);
        }

    }
    protected void btnSave_Click(object sender, EventArgs e)
    {
        if (ValidateBatch())
        {
            using (RepeatDispensingBatchProcessor processor = new RepeatDispensingBatchProcessor())
            {
                RepeatDispensingBatchLine batch = processor.LoadByBatchID(_BatchID);
                batch.PatientList = selectedPatients;
                batch.Status = BatchStatus.New;
                processor.Update(batch);
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "batchSaved", "ICWConfirm('Batch saved.','OK', 'Batch Creation','dialogHeight:80px;dialogWidth:300px;resizable:yes;status:no;help:no;');", true);
                ClearForm();
            }
        }
        else
        {
            //No patients
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "validationFailed", "ICWConfirm('No patients selected.','OK', 'Batch Creation','dialogHeight:80px;dialogWidth:300px;resizable:yes;status:no;help:no;');", true);
        }
    }

    protected bool ValidateBatch()
    {
        bool result = false;
        selectedPatients.Clear();
        using (RepeatDispensingPatientProcessor patientProcessor = new RepeatDispensingPatientProcessor())
        {
            foreach (RepeaterItem rptItem in rptData.Items) // Iterate all items (patients) in the repeater control
            {
                CheckBox chk = (CheckBox)rptItem.FindControl("chkSelected"); // Capture the checkbox for the repeater item
                if (chk.Checked) // IF checkbox is checked, patient is selected
                {
                    Label entityID = (Label)rptItem.FindControl("EntityID"); // Get the EntityID Label from the repeater item
                    selectedPatients.Add(patientProcessor.LoadByEntityID(int.Parse(entityID.Text)));
                    result = true;
                }
            }
        }
        return result;
    }

    /// <summary>Clears the seleted template</summary>
    protected void ClearTemplate()
    {
        txtTemplate.Text = string.Empty;
        _TemplateID      = 1;
    }

    protected void ClearForm()
    {
        _BatchID = -1;
        hdnBatchID.Value = "";
        hdnEntityID.Value = "";
        _EntityID = -1;
        rptData.DataSource = null;
        rptData.DataBind();
        txtBatchDesc.Text = "";

        ClearTemplate();
    }
}
