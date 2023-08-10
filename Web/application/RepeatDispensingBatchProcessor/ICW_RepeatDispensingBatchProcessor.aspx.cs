using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI.HtmlControls;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.businesslayer;
using Ascribe.Common;

// ===================================================================================================
// Author: Aidan Kent (AJK)
// Created: 23feb09
// Description: Codebehind for RepeatDispensingBatches.aspx
// History: 16Sep11 AJK 14392 Changed css class for cells to match those in the batch creation screen
//          04Apr12 AJK 30997 Added btnProcessAll_Click and all btnProcess display settings
//          22May12 AJK 34760 btnBatches_Click, btnPatients_Click and Page_Load: Ensured that the desktop parameter for showing the combined button is passed around in the querystring where needed
//          23May12 AJK 34760 Added more of the same as the previous update            
//          29Sep15 TH  130427 possibly overlay the url scheme - this is if we are behind a LB with https endpoint inaccessible to us here  
// ===================================================================================================

public partial class application_RepeatDispensing_RepeatDispensingBatches : System.Web.UI.Page
{
    int _SessionID = -1;        // SessionID
    string _Type = "Batches";   // Record type to display, currently "Batches" (default) or "Patients"
    int _BatchID = -1;          // BatchID for currently selected batch
    int _RowID;
    //public int _Mode = -1;      // Mode to display, this represents the status ID of the batch. Currently 1 (New), 2 (Labelled), 3 (IssuedWithExceptions), 4 (Deleted) and 5 (Archived)
    public BatchStatus mode; 
    //List<RepeatDispensingPatient.Patient> selectedPatients = new List<RepeatDispensingPatient.Patient>();
    List<RepeatDispensingPatientLine> selectedPatients = new List<RepeatDispensingPatientLine>();
    //List<RepeatDispensingBatch.Batch> selectedBatches = new List<RepeatDispensingBatch.Batch>(); 
    List<RepeatDispensingBatchLine> selectedBatches = new List<RepeatDispensingBatchLine>();
    int _SiteID = -1;
    string _combined = "";
    string _showCombined = ""; // 22May12 AJK 34760 Previously unused to changed type and utilised
    bool Combined = false;
    
    
    protected void Page_Load(object sender, EventArgs e)
    {
        string strOCXURL;
        //RepeatDispensingBatch objRDBP = new RepeatDispensingBatch();
        _SessionID = int.Parse(Request.QueryString["SessionID"]);
        _SiteID = int.Parse(Request.QueryString["SiteID"]);
        SessionInfo.InitialiseSessionAndSiteID(_SessionID, _SiteID);
        //_Mode = int.Parse(Request.QueryString["Mode"]); 
        _combined = Request.QueryString["Combined"] == null ? "" : Request.QueryString["Combined"];
        mode = Request.QueryString["Mode"] == null ? BatchStatus.New : (BatchStatus)BatchCodeToStatus(Request.QueryString["Mode"]);
        _showCombined = Request.QueryString["ShowCombinedButton"] == null ? "" : Request.QueryString["ShowCombinedButton"]; // 22May12 AJK 34760 Added
        if (Request.QueryString["Combined"] == null || Request.QueryString["Combined"] == "" || Request.QueryString["Combined"] == "No")
        {
            Combined = false;
        }
        else
        {
            Combined = true;
            if (Request.QueryString["ShowCombinedButton"] != null && Request.QueryString["Combined"] == "Yes")
                btnProcessAll.Visible = true;
        }
        txtMode.Text = Combined ? "Combined" : Request.QueryString["Mode"];
        //_SiteID = int.Parse(ICW.ICWParameter("SiteID", "The Site ID", ""));

        _Type = Request.QueryString["Type"] == null ? "Batches" : Request.QueryString["Type"]; 
        txtType.Text = _Type; // Assign type to hidden textbox for clientside javascript calls
        txtSiteID.Text = _SiteID.ToString();
        txtSessionID.Text = _SessionID.ToString();

        // 05Oct15 TH possibly overlay the url scheme (TFS 130427)
        // 28May20 AS Added port number for web transport layer
        GENRTL10.SettingRead settingread = new GENRTL10.SettingRead();
        string URLScheme = settingread.GetValue(_SessionID, "Pharmacy", "WebConnection", "URLscheme", Request.Url.Scheme);
        int intPortNumber = settingread.GetPortNumber(_SessionID, "Pharmacy", "Database", "PortNoWebTransport");
        //string strOCXURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx" + "?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionId=" + _SessionID;
        if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
        {
             strOCXURL = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx" + "?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionId=" + _SessionID;
        }
        else
        {
             strOCXURL = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx" + "?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionId=" + _SessionID;
        }
        
        txtOCXURL.Text = strOCXURL;
        switch (_Type)
        {
            case "Batches": 
                if (IsPostBack) // Has to be from form button click, therefor row "should" be selected.
                {
                    bool tempresult = int.TryParse(Request.Form["txtRowID"], out _BatchID); // Attempt to get batch ID from submitted form and assign to _BatchID
                }
                else // Could be a fresh page, or could come from Patients type
                {
                    if(Request.QueryString["BatchID"] != null)
                    {
                        _BatchID = int.Parse(Request.QueryString["BatchID"]); // If querystring held a BatchID, assign it to _BatchID
                    }
                }
                if (_BatchID > 0) 
                {
                    txtRowID.Text = _BatchID.ToString(); // Assign the value to the hidden textbox so clientside javascript can read it
                }
                rpt_Default.HeaderTemplate = new batchTemplate(ListItemType.Header, Combined); 
                rpt_Default.ItemTemplate = new batchTemplate(ListItemType.Item, Combined);
                rpt_Default.FooterTemplate = new batchTemplate(ListItemType.Footer, Combined);
                //selectedBatches = objRDBP.BatchesByStatus(_SessionID, _Mode); // Get all selected batches for this Status
                using (RepeatDispensingBatchProcessor batchProcessor = new RepeatDispensingBatchProcessor())
                {
                    if (Combined)
                    {
                        selectedBatches = batchProcessor.LoadAllActive();
                    }
                    else
                    {
                        selectedBatches = batchProcessor.LoadByStatus(mode);
                    }
                }
                rpt_Default.DataSource = selectedBatches.ToArray();
                rpt_Default.DataBind();
                btnBatches.CssClass = "TabSelected";
                btnPatients.CssClass = "Tab";
                btnProcess.Visible = true;
                btnDelete.Visible = true;
                btnSettings.Visible = false;
                break;
            case "Patients":
                _BatchID = int.Parse(Request.QueryString["BatchID"]); // BatchID has to be present in querystring as the page can only be reached from batches type page

                //16Jun11 TH Added to retain batchID when messing on the patient screen.(F0120743)
                //if (_BatchID > 0)
                //{
                //    txtRowID.Text = _BatchID.ToString(); // Assign the value to the hidden textbox so clientside javascript can read it
                //}

                //if (!IsPostBack)
                //{
                rpt_Default.HeaderTemplate = new patientTemplate(ListItemType.Header);
                rpt_Default.ItemTemplate = new patientTemplate(ListItemType.Item);
                rpt_Default.FooterTemplate = new patientTemplate(ListItemType.Footer);
                //selectedPatients = objRDBP.LoadBatchPatients(_BatchID, _SessionID); // Load patients by BatchID
                using (RepeatDispensingPatientProcessor patientProcessor = new RepeatDispensingPatientProcessor())
                {
                    selectedPatients = patientProcessor.LoadByBatchID(_BatchID);
                }
                //selectedPatients = objRDBP.AvailablePatients();
                rpt_Default.DataSource = selectedPatients.ToArray();
                rpt_Default.DataBind();
                btnBatches.CssClass = "Tab";
                btnPatients.CssClass = "TabSelected";
                btnProcess.Visible = false;
                btnDelete.Visible = false;
                RepeatDispensingBatchLine batch = new RepeatDispensingBatchLine();
                using (RepeatDispensingBatchProcessor batchProcessor = new RepeatDispensingBatchProcessor())
                {
                    batch = batchProcessor.LoadByBatchID(_BatchID);
                }
                
                btnSettings.Visible = ((mode == BatchStatus.New && !Combined) || (Combined && batch.Status == BatchStatus.New)) ; // XN 8Jun10 F0079246 should only be active on first screen to prevent user printing out different label settings
                //}
                break;
        }

        if (Combined)
        {
            btnProcess.Visible = true;
            btnProcess.Text = "Process";
            btnMedSchedule.Visible = true;
            btnRequirementsRpt.Visible = true;
            btnDelete.Visible = true;
        }
        else
        {
            ToggleStatus(mode);
        }

        if (Request.QueryString["Action"] == "Delete")
        {
            _BatchID = Convert.ToInt32(Request.QueryString["BatchID"]);
            using (RepeatDispensingBatchProcessor processor = new RepeatDispensingBatchProcessor())
            {
                RepeatDispensingBatchLine batch = new RepeatDispensingBatchLine();
                batch = processor.LoadByBatchID(_BatchID);
                batch.Status = BatchStatus.Deleted;
                processor.Update(batch);
                Response.Redirect("ICW_RepeatDispensingBatchProcessor.aspx?SessionID=" + _SessionID + "&Type=" + _Type + "&Mode=" + BatchStatusToCode(mode) + "&SiteID=" + _SiteID + "&Combined=" + _combined + "&ShowCombinedButton=" + _showCombined);
            }
        }

    }
    protected void ToggleStatus(BatchStatus status)
    {
        switch (status)
        {
            case BatchStatus.New:
                btnProcess.Text = "Label"; // 04Apr12 AJK 30997 Changed from Labelling
                btnMedSchedule.Visible = (_Type == "Batches");
                btnRequirementsRpt.Visible = (_Type == "Batches");
                break;
            case BatchStatus.Labelled:
                btnProcess.Text = "Issue"; // 04Apr12 AJK 30997 Changed from Issuing
                btnMedSchedule.Visible = false;
                btnRequirementsRpt.Visible = (_Type == "Batches");
                break;
            case BatchStatus.Issued:
                btnProcess.Text = "Mark as complete";
                //btnDelete.Enabled = false;
                btnDelete.Visible = false;
                btnMedSchedule.Visible = false;
                btnRequirementsRpt.Visible = false;
                break;
        }
    }

    public class patientTemplate : ITemplate // Patient records template
    {
        ListItemType templateType;

        public patientTemplate(ListItemType type)
        {
            templateType = type;
        }

        public void InstantiateIn(System.Web.UI.Control container)
        {
            switch (templateType)
            {
                case ListItemType.Header: // Build table opening tag and header row, then add to container (repeater)
                    LiteralControl lc = new LiteralControl();
                    lc.Text = "<TABLE ID=\"tbl\" runat=server cellspacing=\"0\" style=\"width:expression(document.frames.frameElement.clientWidth - 20);\" CellPadding=2>";
                    lc.Text += "<col style=\"display:none\" >";
                    lc.Text += "<TR class=\"GridHeading\" style=\"top: expression(document.getElementById(&quot;tbl-container&quot;).scrollTop);position:relative;\" >";
                    lc.Text += "<TD width=\"0%\">EntityID</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Surname</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Forename</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">DOB</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Hospital No.</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">In Use</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Supply Days</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Template</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Automated Dispensing</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Supply Pattern</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Additional Info</TD>";
                    lc.Text += "</TR>";
                    container.Controls.Add(lc);
                    break;
                case ListItemType.Item: // Build record row and add to container
                    TableRow trI = new TableRow();
                    TableCell tcI = new TableCell();
                    TableCell tcI2 = new TableCell();
                    TableCell tcI3 = new TableCell();
                    TableCell tcI4 = new TableCell();
                    TableCell tcI5 = new TableCell();
                    TableCell tcI6 = new TableCell();
                    TableCell tcI7 = new TableCell();
                    TableCell tcI8 = new TableCell();
                    TableCell tcI9 = new TableCell();
                    TableCell tcI10 = new TableCell();
                    TableCell tcI11 = new TableCell();
                    trI.DataBinding += new EventHandler(TemplateControlTR_DataBinding); // Assign event to load data when repeater is databound
                    trI.Attributes["onclick"] = "grid_onclick()"; // Add javascript event
                    trI.Attributes["onkeydown"] = "grid_onkeydown()"; // Add javascript event
                    tcI.ID = "EntityID";
                    trI.Cells.Add(tcI);
                    trI.Cells.Add(tcI2);
                    trI.Cells.Add(tcI3);
                    trI.Cells.Add(tcI4);
                    trI.Cells.Add(tcI5);
                    trI.Cells.Add(tcI6);
                    trI.Cells.Add(tcI7);
                    trI.Cells.Add(tcI8);
                    trI.Cells.Add(tcI9);
                    trI.Cells.Add(tcI10);
                    trI.Cells.Add(tcI11);
                    container.Controls.Add(trI);
                    break;
                case ListItemType.Footer: // Close table tag
                    LiteralControl lc2 = new LiteralControl();
                    lc2.Text = "</TABLE>";
                    container.Controls.Add(lc2);
                    break;
            }
        }
        
        protected void TemplateControlTR_DataBinding(object sender, EventArgs e) // Called when a row's parent is databound, assigns data to controls
        {
            TableRow tr;
            tr = (TableRow)sender;
            RepeaterItem container = (RepeaterItem)tr.NamingContainer;
            tr.Cells[0].Text += DataBinder.Eval(container.DataItem, "EntityID").ToString();
            tr.Cells[1].Text += DataBinder.Eval(container.DataItem, "Surname").ToString();
            tr.Cells[2].Text += DataBinder.Eval(container.DataItem, "Forename") == null ? "" : DataBinder.Eval(container.DataItem, "Forename").ToString();
            tr.Cells[3].Text += ((DateTime?)DataBinder.Eval(container.DataItem, "DOB")).ToPharmacyDateString();
            tr.Cells[4].Text += DataBinder.Eval(container.DataItem, "HospitalNumber") == null ? "" : DataBinder.Eval(container.DataItem, "HospitalNumber").ToString();
            tr.Cells[5].Text += ((bool?)DataBinder.Eval(container.DataItem, "InUse")).ToYesNoString();
            tr.Cells[6].Text += DataBinder.Eval(container.DataItem, "SupplyDays") == null ? "" :  DataBinder.Eval(container.DataItem, "SupplyDays").ToString();
            tr.Cells[7].Text += DataBinder.Eval(container.DataItem, "RepeatDispensingBatchTemplateDescription").ToString();
            tr.Cells[8].Text += ((bool?)DataBinder.Eval(container.DataItem, "ADM")).ToYesNoString();
            tr.Cells[9].Text += DataBinder.Eval(container.DataItem, "SupplyPattern") == null ? "" : DataBinder.Eval(container.DataItem, "SupplyPattern").ToString();
            tr.Cells[10].Text += DataBinder.Eval(container.DataItem, "AdditionalInformation") == null ? "" : DataBinder.Eval(container.DataItem, "AdditionalInformation").ToString();
        }
    }

    public class batchTemplate : ITemplate // Batch records template
    {
        ListItemType templateType;
        bool Combined = false;

        public batchTemplate(ListItemType type, bool combined)
        {
            templateType = type;
            Combined = combined;
        }

        public void InstantiateIn(System.Web.UI.Control container)
        {
            switch (templateType)
            {
                case ListItemType.Header: // Build table opening tag and header row, then add to container (repeater)
                    LiteralControl lc = new LiteralControl();
                    lc.Text = "<TABLE ID=\"tbl\" runat=\"server\" cellspacing=\"0\" style=\"width:expression(document.frames.frameElement.clientWidth - 20);\" CellPadding=2>";
                    lc.Text += "<col style=\"display:none\">";

                    lc.Text += "<TR class=\"GridHeading\"  style=\"top: expression(document.getElementById(&quot;tbl-container&quot;).scrollTop);position:relative;\" >";
                    lc.Text += "<TD></TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Description</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Location</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">BagLabels</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Factor</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Start Date</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Start Slot</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">End Date</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">End Slot</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Breakfast</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Lunch</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Tea</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Night</TD>";
                    lc.Text += "<TD class=\"GridHeadingCell\">Sort By</TD>";
                    if (Combined) lc.Text += "<TD class=\"GridHeadingCell\">Status</TD>";
                    lc.Text += "</TR>";
                    container.Controls.Add(lc);
                    break;
                case ListItemType.Item: // Build record row and add to container
                    TableRow trI = new TableRow();
                    TableCell tcI = new TableCell();
                    TableCell tcI2 = new TableCell();
                    TableCell tcI3 = new TableCell();
                    TableCell tcI4 = new TableCell();
                    TableCell tcI5 = new TableCell();
                    TableCell tcI6 = new TableCell();
                    TableCell tcI7 = new TableCell();
                    TableCell tcI8 = new TableCell();
                    TableCell tcI9 = new TableCell();
                    TableCell tcI10 = new TableCell();
                    TableCell tcI11 = new TableCell();
                    TableCell tcI12 = new TableCell();
                    TableCell tcI13 = new TableCell();
                    TableCell tcI14 = new TableCell();
                    TableCell tcI15 = new TableCell();
                    trI.DataBinding += new EventHandler(TemplateControlTR_DataBinding); // Assign event to load data when repeater is databound
                    trI.Attributes["onclick"] = "grid_onclick()"; // Add javascript event
                    trI.Attributes["onkeydown"] = "grid_onkeydown()"; // Add javascript event
                    trI.ID = "dataRow";
                    tcI.ID = "BatchID";
                    trI.Cells.Add(tcI);
                    trI.Cells.Add(tcI2);
                    trI.Cells.Add(tcI3);
                    trI.Cells.Add(tcI4);
                    trI.Cells.Add(tcI5);
                    trI.Cells.Add(tcI6);
                    trI.Cells.Add(tcI7);
                    trI.Cells.Add(tcI8);
                    trI.Cells.Add(tcI9);
                    trI.Cells.Add(tcI10);
                    trI.Cells.Add(tcI11);
                    trI.Cells.Add(tcI12);
                    trI.Cells.Add(tcI13);
                    trI.Cells.Add(tcI14);
                    if (Combined) trI.Cells.Add(tcI15);
                    container.Controls.Add(trI);
                    break;
                case ListItemType.Footer: // Close table tag
                    LiteralControl lc2 = new LiteralControl();
                    lc2.Text = "</TABLE>";
                    container.Controls.Add(lc2);
                    break;
            }
        }

        protected void TemplateControlTR_DataBinding(object sender, EventArgs e) // Called when a row's parent is databound, assigns data to controls
        {
            TableRow tr;
            tr = (TableRow)sender;
            RepeaterItem container = (RepeaterItem)tr.NamingContainer;
            tr.Cells[0].Text += DataBinder.Eval(container.DataItem, "BatchID").ToString();
            tr.Cells[1].Text += DataBinder.Eval(container.DataItem, "Description").ToString();
            tr.Cells[2].Text += DataBinder.Eval(container.DataItem, "LocationDescription") == null ? "" : DataBinder.Eval(container.DataItem, "LocationDescription").ToString();
            tr.Cells[3].Text += DataBinder.Eval(container.DataItem, "BagLabelsPerPatient") == null ? "" : DataBinder.Eval(container.DataItem, "BagLabelsPerPatient").ToString();
            tr.Cells[4].Text += DataBinder.Eval(container.DataItem, "Factor").ToString();
            tr.Cells[5].Text += DataBinder.Eval(container.DataItem, "StartDate") == null ? "" : ((DateTime?)DataBinder.Eval(container.DataItem, "StartDate")).ToPharmacyDateString();
            tr.Cells[6].Text += DataBinder.Eval(container.DataItem, "StartSlot") == null ? "" : DataBinder.Eval(container.DataItem, "StartSlot").ToString() == "1" ? "Breakfast" : DataBinder.Eval(container.DataItem, "StartSlot").ToString() == "2" ? "Lunch" : DataBinder.Eval(container.DataItem, "StartSlot").ToString() == "3" ? "Tea" : DataBinder.Eval(container.DataItem, "StartSlot").ToString() == "4" ? "Night" : "";

            DateTime? endDate = null;
            string endSlotString = "";
            int endSlot = 0;

            if (DataBinder.Eval(container.DataItem, "StartDate") != null)
            {
                int totalSlots = (int)DataBinder.Eval(container.DataItem, "TotalSlots");
                int startSlot = (int)DataBinder.Eval(container.DataItem, "StartSlot");
                DateTime startDate = (DateTime)DataBinder.Eval(container.DataItem, "StartDate");
                int firstDaySlots = 5 - startSlot;
                int temp;
                temp = (int)DataBinder.Eval(container.DataItem, "StartSlot") + (int)DataBinder.Eval(container.DataItem, "TotalSlots") - 1;
                endSlot = temp % 4;
                if (endSlot == 0) endSlot = 4;
                switch (endSlot)
                {
                    case 1:
                        endSlotString = "Breakfast";
                        break;
                    case 2:
                        endSlotString = "Lunch";
                        break;
                    case 3:
                        endSlotString = "Tea";
                        break;
                    case 4:
                        endSlotString = "Night";
                        break;
                }
                if (totalSlots > firstDaySlots)
                {
                    int wholeDays = totalSlots - firstDaySlots - endSlot;
                    endDate = startDate.AddDays(1);
                    if (wholeDays > 0)
                    {
                        wholeDays = wholeDays / 4;
                        endDate = ((DateTime)endDate).AddDays(wholeDays);
                    }
                }
                else
                {
                    endDate = startDate;
                }
            }
            tr.Cells[7].Text += endDate == null ? "" : endDate.ToPharmacyDateString();
            tr.Cells[8].Text += endSlotString;
            tr.Cells[9].Text += DataBinder.Eval(container.DataItem, "Breakfast") == null ? "" : ((bool?)DataBinder.Eval(container.DataItem, "Breakfast")).ToYesNoString();
            tr.Cells[10].Text += DataBinder.Eval(container.DataItem, "Lunch") == null ? "" : ((bool?)DataBinder.Eval(container.DataItem, "Lunch")).ToYesNoString();
            tr.Cells[11].Text += DataBinder.Eval(container.DataItem, "Tea") == null ? "" : ((bool?)DataBinder.Eval(container.DataItem, "Tea")).ToYesNoString();
            tr.Cells[12].Text += DataBinder.Eval(container.DataItem, "Night") == null ? "" : ((bool?)DataBinder.Eval(container.DataItem, "Night")).ToYesNoString();
            tr.Cells[13].Text += DataBinder.Eval(container.DataItem, "SortByDate") == null ? "" : (bool?)DataBinder.Eval(container.DataItem, "SortByDate") == true ?  "Administration Slot" : "Patient Name";
            if (Combined) tr.Cells[14].Text += DataBinder.Eval(container.DataItem, "Status") == null ? "" : DataBinder.Eval(container.DataItem, "Status").ToString();
        }
    }

    private BatchStatus? BatchCodeToStatus(string batchCode)
    {
        switch (batchCode)
        {
            case "N": return BatchStatus.New;
            case "L": return BatchStatus.Labelled;
            case "I": return BatchStatus.Issued;
            case "D": return BatchStatus.Deleted;
            case "A": return BatchStatus.Archived;
            default: return null;
        }
    }

    private string BatchStatusToCode(BatchStatus batchStatus)
    {
        switch (batchStatus)
        {
            case BatchStatus.New: return "N";
            case BatchStatus.Labelled: return "L";
            case BatchStatus.Issued: return "I";
            case BatchStatus.Deleted: return "D";
            case BatchStatus.Archived: return "A";
            case BatchStatus.Combined: return "C";
            default: return null;
        }
    }

    protected void btnBatches_Click(object sender, EventArgs e) // Reload the page in for type Batches, retaining current selection
    {
        // 22May12 AJK 34760 Added ShowCombinedButton parameter
        Response.Redirect("ICW_RepeatDispensingBatchProcessor.aspx?SessionID=" + _SessionID + "&Type=Batches&BatchID=" + _BatchID + "&Mode=" + BatchStatusToCode(mode) + "&SiteID=" + _SiteID + "&Combined=" + _combined + "&ShowCombinedButton=" + _showCombined);
    }
    protected void btnPatients_Click(object sender, EventArgs e) // Reload the page for type Patients, using batch ID from hidden textbox
    {
        //bool result = int.TryParse(Request.Form["txtRowID"], out _BatchID); //19Jun11 TH No - This could be a patient if the form is reloading from itself !!! use the global variable
	
        
        if (_BatchID > 0)// If hidden textbox contained a batch ID
        {
            // 22May12 AJK 34760 Added ShowCombinedButton parameter
            Response.Redirect("ICW_RepeatDispensingBatchProcessor.aspx?SessionID=" + _SessionID + "&Type=Patients&BatchID=" + _BatchID + "&Mode=" + BatchStatusToCode(mode) + "&SiteID=" + _SiteID + "&Combined=" + _combined + "&ShowCombinedButton=" + _showCombined);
        }
        else
        {
            RegisterClientScriptBlock("noBatchSelected", "<SCRIPT>alert('No batch selected.');</SCRIPT>");
        }
    }
    protected void btnMedSchedule_Click(object sender, EventArgs e) // Process selected batch
    {
        bool result = int.TryParse(Request.Form["txtRowID"], out _BatchID);
        if (_BatchID > 0) // If hidden textbox contained a valid BatchID
        {
            //Response.Redirect("ICW_RepeatDispensingBatchProcessor.aspx?SessionID=" + _SessionID + "&Type=Batches&BatchID=" + _BatchID + "&Mode=S&SiteID=" + _SiteID);
            using (RepeatDispensingBatchProcessor processor = new RepeatDispensingBatchProcessor())
            {
                RepeatDispensingBatchLine batch = new RepeatDispensingBatchLine();
                batch = processor.LoadByBatchID(_BatchID);
                RepeatDispensingValidation validator = new RepeatDispensingValidation();

                //processor.ValidateForUpdate(batch);
                //switch (mode)
                //{
                //    case BatchStatus.New:
                //        //Decide what to do about validation errors here
                //        batch.Status = BatchStatus.Labelled;
                //        break;
                //    case BatchStatus.Labelled:
                //        //Decide what to do about validation errors here
                //        batch.Status = BatchStatus.Issued;
                //        break;
                //    case BatchStatus.Issued:
                //        //Decide what to do about validation errors here
                //        batch.Status = BatchStatus.Archived;
                //        break;
                //}
                if (validator.ValidateBatch(_BatchID, _SiteID, BatchStatus.Labelled))
                {
                    string ocxURL = "";

		    		// 29Sep15 TH possibly overlay the url scheme (TFS 130427)
		    		GENRTL10.SettingRead settingread = new GENRTL10.SettingRead();
                    string URLScheme = settingread.GetValue(_SessionID, "Pharmacy","WebConnection", "URLscheme", Request.Url.Scheme);
                    int intPortNumber = settingread.GetPortNumber(_SessionID, "Pharmacy", "Database", "PortNoWebTransport");

                    if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                    {
                        //string ocxURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                        ocxURL = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                    }
                    else
                    {
                        ocxURL = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                    }
                    xmlDataID.InnerHtml = validator.ValidationErrorsXML;

                    //xmlDataID.DocumentContent = validator.ValidationErrorsXML;
                    //ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "processBatch", "objRepeatDispense.ProcessBatch(" + _SessionID + "," + SiteProcessor.GetNumberBySiteID(_SiteID).ToString() + ",\"" + BatchStatusToCode(action) + "\", xmlData.XML , \"" + ocxURL + "\");document.getElementById(\"mainForm\").submit();", true);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "processBatch", "var myXML = document.getElementById('xmlDataID'); var ctrlRD = document.getElementById('objRepeatDispense'); ctrlRD.ProcessBatch(" + _SessionID + "," + SiteProcessor.GetNumberBySiteID(_SiteID).ToString() + ",\"" + "S" + "\", myXML.XMLDocument.xml , \"" + ocxURL + "\");document.getElementById(\"mainForm\").submit();RAISE_RefreshTables();", true);
                }
                else
                {
                    //Display errors somehow
                    //ValidationErrorList exceptions = validator.ValidationErrors;
                    //exceptions.AddRange((from exception in validator.ValidationErrors
                    //                                  where exception.Exception == true
                    //                                  select exception).ToList<ValidationError>());
                    //txtExceptionsXML.Text = validator.ValidationErrorsXML;
                    GENRTL10.State state = new GENRTL10.State();
                    state.SessionAttributeSet(_SessionID, "RepeatDispensingBatchValidationErrorXML", validator.ValidationErrorsXML);
                    RegisterClientScriptBlock("showErrorWindow", "<SCRIPT>window.showModalDialog(\"ValidationErrors.aspx?BatchID=" + _BatchID + "&SessionID=" + _SessionID + "&Description=" + batch.Description + "\",\"\",\"\");document.getElementById(\"mainForm\").submit();</SCRIPT>");
                }
            }
        }
        else
        {
            RegisterClientScriptBlock("noBatchSelected", "<SCRIPT>alert('No batch selected.');</SCRIPT>");
        }
    }
    protected void btnRequirementsRpt_Click(object sender, EventArgs e) // Process selected batch
    {
        bool result = int.TryParse(Request.Form["txtRowID"], out _BatchID);
        if (_BatchID > 0) // If hidden textbox contained a valid BatchID
        {
            //Response.Redirect("ICW_RepeatDispensingBatchProcessor.aspx?SessionID=" + _SessionID + "&Type=Batches&BatchID=" + _BatchID + "&Mode=S&SiteID=" + _SiteID);
            using (RepeatDispensingBatchProcessor processor = new RepeatDispensingBatchProcessor())
            {
                RepeatDispensingBatchLine batch = new RepeatDispensingBatchLine();
                batch = processor.LoadByBatchID(_BatchID);
                RepeatDispensingValidation validator = new RepeatDispensingValidation();

                if (validator.ValidateBatch(_BatchID, _SiteID, BatchStatus.Labelled))
                {
                    string ocxURL = "";
                    // 05Oct15 TH possibly overlay the url scheme (TFS 130427)
                    GENRTL10.SettingRead settingread = new GENRTL10.SettingRead();
                    string URLScheme = settingread.GetValue(_SessionID, "Pharmacy", "WebConnection", "URLscheme", Request.Url.Scheme);
                    int intPortNumber = settingread.GetPortNumber(_SessionID, "Pharmacy", "Database", "PortNoWebTransport");
                    if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                    {
                        //string ocxURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                        ocxURL = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                    }
                    else
                    {
                        ocxURL = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                    }
                    xmlDataID.InnerHtml = validator.ValidationErrorsXML;

                    //xmlDataID.DocumentContent = validator.ValidationErrorsXML;
                    //ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "processBatch", "objRepeatDispense.ProcessBatch(" + _SessionID + "," + SiteProcessor.GetNumberBySiteID(_SiteID).ToString() + ",\"" + BatchStatusToCode(action) + "\", xmlData.XML , \"" + ocxURL + "\");document.getElementById(\"mainForm\").submit();", true);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "processBatch", "var myXML = document.getElementById('xmlDataID'); var ctrlRD = document.getElementById('objRepeatDispense'); ctrlRD.ProcessBatch(" + _SessionID + "," + SiteProcessor.GetNumberBySiteID(_SiteID).ToString() + ",\"" + "R" + "\", myXML.XMLDocument.xml , \"" + ocxURL + "\");document.getElementById(\"mainForm\").submit();RAISE_RefreshTables();", true);
                }
                else
                {
                    //Display errors somehow
                    //ValidationErrorList exceptions = validator.ValidationErrors;
                    //exceptions.AddRange((from exception in validator.ValidationErrors
                    //                                  where exception.Exception == true
                    //                                  select exception).ToList<ValidationError>());
                    //txtExceptionsXML.Text = validator.ValidationErrorsXML;
                    GENRTL10.State state = new GENRTL10.State();
                    state.SessionAttributeSet(_SessionID, "RepeatDispensingBatchValidationErrorXML", validator.ValidationErrorsXML);
                    RegisterClientScriptBlock("showErrorWindow", "<SCRIPT>window.showModalDialog(\"ValidationErrors.aspx?BatchID=" + _BatchID + "&SessionID=" + _SessionID + "&Description=" + batch.Description + "\",\"\",\"\");document.getElementById(\"mainForm\").submit();</SCRIPT>");
                }
            }
        }
        else
        {
            RegisterClientScriptBlock("noBatchSelected", "<SCRIPT>alert('No batch selected.');</SCRIPT>");
        }
    }
    protected void btnProcess_Click(object sender, EventArgs e) // Process selected batch
    {
        bool result = int.TryParse(Request.Form["txtRowID"], out _BatchID);
        if (_BatchID > 0) // If hidden textbox contained a valid BatchID
        {
            using (RepeatDispensingBatchProcessor processor = new RepeatDispensingBatchProcessor())
            {
                RepeatDispensingBatchLine batch = new RepeatDispensingBatchLine();
                batch = processor.LoadByBatchID(_BatchID);
                RepeatDispensingValidation validator = new RepeatDispensingValidation();
                
                //processor.ValidateForUpdate(batch);
                //switch (mode)
                //{
                //    case BatchStatus.New:
                //        //Decide what to do about validation errors here
                //        batch.Status = BatchStatus.Labelled;
                //        break;
                //    case BatchStatus.Labelled:
                //        //Decide what to do about validation errors here
                //        batch.Status = BatchStatus.Issued;
                //        break;
                //    case BatchStatus.Issued:
                //        //Decide what to do about validation errors here
                //        batch.Status = BatchStatus.Archived;
                //        break;
                //}
                if (batch.Status == BatchStatus.Issued)
                {
                    batch.Status = BatchStatus.Archived;
                    processor.Update(batch);
                    Response.Redirect("ICW_RepeatDispensingBatchProcessor.aspx?SessionID=" + _SessionID + "&Type=Batches&Mode=" + BatchStatusToCode(mode) + "&SiteID=" + _SiteID + "&Combined=" + _combined + "&ShowCombinedButton=" + _showCombined);
                }
                else if (validator.ValidateBatch(_BatchID, _SiteID, batch.Status))
                {
                    BatchStatus action = new BatchStatus();
                    switch (batch.Status)
                    {
                        case BatchStatus.New:
                            action = BatchStatus.Labelled;
                            break;
                        case BatchStatus.Labelled:
                            action = BatchStatus.Issued;
                            break;
                        default:
                            break;
                    }

                    // 05Oct15 TH possibly overlay the url scheme (TFS 130427)
                    GENRTL10.SettingRead settingread = new GENRTL10.SettingRead();
                    string ocxURL = "";
                    string URLScheme = settingread.GetValue(_SessionID, "Pharmacy", "WebConnection", "URLscheme", Request.Url.Scheme);
                    int intPortNumber = settingread.GetPortNumber(_SessionID, "Pharmacy", "Database", "PortNoWebTransport");

                    if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                    {
                        //string ocxURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                        ocxURL = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                    }
                    else
                    {
                        ocxURL = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                    }
                    xmlDataID.InnerHtml = validator.ValidationErrorsXML;

                    //xmlDataID.DocumentContent = validator.ValidationErrorsXML;
                    //ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "processBatch", "objRepeatDispense.ProcessBatch(" + _SessionID + "," + SiteProcessor.GetNumberBySiteID(_SiteID).ToString() + ",\"" + BatchStatusToCode(action) + "\", xmlData.XML , \"" + ocxURL + "\");document.getElementById(\"mainForm\").submit();", true);
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "processBatch", "var myXML = document.getElementById('xmlDataID'); var ctrlRD = document.getElementById('objRepeatDispense'); ctrlRD.ProcessBatch(" + _SessionID + "," + SiteProcessor.GetNumberBySiteID(_SiteID).ToString() + ",\"" + BatchStatusToCode(action) + "\", myXML.XMLDocument.xml , \"" + ocxURL + "\");document.getElementById(\"mainForm\").submit();RAISE_RefreshTables();", true);

                    //Response.Redirect("ICW_RepeatDispensingBatchProcessor.aspx?SessionID=" + _SessionID + "&Type=" + _Type + "&Mode=" + BatchStatusToCode(mode) + "&SiteID=" + _SiteID);


                    //PROD OCX HERE
                    //Response.Redirect("ICW_RepeatDispensingBatchProcessor.aspx?SessionID=" + _SessionID + "&Type=" + _Type + "&Mode=" + BatchStatusToCode(mode) + "&SiteID=" + _SiteID);

                }
                else
                {
                    //Display errors somehow
                    //ValidationErrorList exceptions = validator.ValidationErrors;
                    //exceptions.AddRange((from exception in validator.ValidationErrors
                    //                                  where exception.Exception == true
                    //                                  select exception).ToList<ValidationError>());
                    //txtExceptionsXML.Text = validator.ValidationErrorsXML;
                    GENRTL10.State state = new GENRTL10.State();
                    state.SessionAttributeSet(_SessionID, "RepeatDispensingBatchValidationErrorXML", validator.ValidationErrorsXML);
                    RegisterClientScriptBlock("showErrorWindow", "<SCRIPT>window.showModalDialog(\"ValidationErrors.aspx?BatchID=" + _BatchID + "&SessionID=" + _SessionID + "&Description=" + batch.Description + "\",\"\",\"\");document.getElementById(\"mainForm\").submit();</SCRIPT>");
                }
            }
        }
        else
        {
            RegisterClientScriptBlock("noBatchSelected", "<SCRIPT>alert('No batch selected.');</SCRIPT>");
        }
    }

    protected void btnDelete_Click(object sender, EventArgs e) // Delete selected batch
    {
        bool result = int.TryParse(Request.Form["txtRowID"], out _BatchID);
        if (_BatchID > 0) // If hidden textbox contained a valid BatchID, update via middle tier and refresh page
        {
            string clientScript = "<SCRIPT>if (ICWConfirm('Are you sure you wish to delete this batch?', \"Yes,No\", \"Delete Batch\",\"dialogHeight:80px;dialogWidth:300px;resizable:yes;status:no;help:no;\") == \"Yes\" ) { var strURL = 'ICW_RepeatDispensingBatchProcessor.aspx?SessionID=";
            clientScript += _SessionID + "&Type=" + _Type + "&Mode=" + BatchStatusToCode(mode) + "&SiteID=" + _SiteID + "&Combined=" + _combined + "&ShowCombinedButton=" + _showCombined + "&Action=Delete&BatchID=" + _BatchID + "'; window.navigate(strURL);}</SCRIPT>";
            RegisterClientScriptBlock("deleteBatch", clientScript);
            //using (RepeatDispensingBatchProcessor processor = new RepeatDispensingBatchProcessor())
            //{
            //    RepeatDispensingBatchLine batch = new RepeatDispensingBatchLine();
            //    batch = processor.LoadByBatchID(_BatchID);
            //    batch.Status = BatchStatus.Deleted;
            //    processor.Update(batch);
            //    Response.Redirect("ICW_RepeatDispensingBatchProcessor.aspx?SessionID=" + _SessionID + "&Type=" + _Type + "&Mode=" + BatchStatusToCode(mode) + "&SiteID=" + _SiteID);
            //}
        }
        else
        {
            RegisterClientScriptBlock("noBatchSelected", "<SCRIPT>alert('No batch selected.');</SCRIPT>");
        }
    }
    protected void btnSettings_Click(object sender, EventArgs e)
    {
        int EntityID;
        bool result = int.TryParse(Request.Form["txtRowID"], out EntityID);
        if (EntityID > 0) // If hidden textbox contained a valid EntityID
        {
            RegisterClientScriptBlock("launchPatientSettings", "<SCRIPT>window.showModalDialog(\"../RepeatDispensing/RepeatDispensingModal.aspx?SiteID=" + _SiteID + "&SessionID=" + _SessionID + "&Combined=" + _combined + "&ShowCombinedButton=" + _showCombined + "&EntityID=" + EntityID + "\",\"\",\"\");document.getElementById(\"mainForm\").submit();</SCRIPT>");
            //Response.Redirect("RepeatDispensingModal.aspx?SessionID=" + _SessionID + "&Type=" + _Type + "&Mode=" + _Mode);"
        }
    }
    
    /// <summary>
    /// Process a selected batch for both labelling and issuing
    /// </summary>
    /// <param name="sender">The button calling the function</param>
    /// <param name="e">Event atguements</param>
    protected void btnProcessAll_Click(object sender, EventArgs e)
    {
        bool result = int.TryParse(Request.Form["txtRowID"], out _BatchID);
        if (_BatchID > 0) // If hidden textbox contained a valid BatchID
        {
            using (RepeatDispensingBatchProcessor processor = new RepeatDispensingBatchProcessor())
            {
                RepeatDispensingBatchLine batch = new RepeatDispensingBatchLine();
                batch = processor.LoadByBatchID(_BatchID);
                RepeatDispensingValidation validator = new RepeatDispensingValidation();

                if (validator.ValidateBatch(_BatchID, _SiteID, BatchStatus.Combined ))
                {
                    // 05Oct15 TH possibly overlay the url scheme (TFS 130427)
                    GENRTL10.SettingRead settingread = new GENRTL10.SettingRead();
                    string ocxURL = "";
                    string URLScheme = settingread.GetValue(_SessionID, "Pharmacy", "WebConnection", "URLscheme", Request.Url.Scheme);
                    int intPortNumber = settingread.GetPortNumber(_SessionID, "Pharmacy", "Database", "PortNoWebTransport");

                    if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                    {
                        //string ocxURL = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                        ocxURL = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                    }
                    else
                    {
                        ocxURL = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(_SessionID) + "&SessionID=" + _SessionID;
                    }
                    xmlDataID.InnerHtml = validator.ValidationErrorsXML;

                    ScriptManager.RegisterStartupScript(this, this.GetType(), "processBatch", "var myXML = document.getElementById('xmlDataID'); var ctrlRD = document.getElementById('objRepeatDispense'); ctrlRD.ProcessBatch(" + _SessionID + "," + SiteProcessor.GetNumberBySiteID(_SiteID).ToString() + ",\"" + BatchStatusToCode(BatchStatus.Combined) + "\", myXML.XMLDocument.xml , \"" + ocxURL + "\");document.getElementById(\"mainForm\").submit();RAISE_RefreshTables();", true);
                }
                else
                {
                    GENRTL10.State state = new GENRTL10.State();
                    state.SessionAttributeSet(_SessionID, "RepeatDispensingBatchValidationErrorXML", validator.ValidationErrorsXML);
                    RegisterClientScriptBlock("showErrorWindow", "<SCRIPT>window.showModalDialog(\"ValidationErrors.aspx?BatchID=" + _BatchID + "&SessionID=" + _SessionID + "&Description=" + batch.Description + "\",\"\",\"\");document.getElementById(\"mainForm\").submit();</SCRIPT>");
                }
            }
        }
        else
        {
            RegisterClientScriptBlock("noBatchSelected", "<SCRIPT>alert('No batch selected.');</SCRIPT>");
        }

    }
}
