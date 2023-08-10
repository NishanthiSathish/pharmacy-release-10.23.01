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
using ascribe.pharmacy.businesslayer;
using System.Collections.Generic;
using ascribe.pharmacy.shared;
using Telerik.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using System.IO;
using System.Text;
using ascribe.pharmacy.robotloading;

// 29Mar12 AJK  30742 PopulateComboOpenClaims, PopulateComboSubmittedClaims: Reset page index on any function which loads a new dataset.
//              30743 PopulateComboSubmittedClaims, CustomEditMode & ButtonUpdate: Reset edit mode whenever a data switch happens.
//              30744 SetButtonState, CheckAndRebind, RadGrid1_EditCommand, DisableButtons, CustomEditMode & ButtonUpdate: Lock all buttons when entering edit mode. Ensure buttons are at correct state whenever edit mode exits. Also ensured that a mesasge is displayed if ever an action is selected with no item.
// 03Apr12 AJK  31119 RadGrid1_NeedDataSource: Removed debug line
// 12Apr12 AJK  31851 RADGrid1_PreRender: Removed old iterator and replaced it with new to ensure that table cells are never emtpy and grid lines are always drawn
// 18Apr12 AJK        RADGrid1_PreRender: Small change to empty cell rendering
// 30Jul15 XN   124027 Fixed issue where claim form is returning unique transaction ID instead of unique prescription ID
//         XN   111596 Change Resubmit button to Resend
//         XN   111182 Changed when resubmitting claim category should be an I not an R (R types are not used anymore)

public partial class application_PCT_ClaimTransactionScreen_ICW_PCT_ClaimTransactionScreen : System.Web.UI.Page
{

    DateTime? _start = null;
    DateTime? _end = null;
    int _SiteID;

    protected void Page_Load(object sender, EventArgs e)
    {
        int _SessionID;
        int _SiteNumber;
        _SessionID = int.Parse(Request.QueryString["SessionID"]);
        _SiteNumber = int.Parse(Request.QueryString["SiteNumber"]);
        SessionInfo.InitialiseSession(_SessionID);
        _SiteID = Sites.GetSiteIDByNumber(_SiteNumber);
        if (!IsPostBack)
        {
            rcboFiles.Enabled = false;
            using (WConfiguration config = new WConfiguration())
            {
                string supAddress;
                config.LoadBySiteCategorySectionAndKey(_SiteID, "D|WORKINGDEFAULTS", "", "SLANumber");
                if (config.Count > 0)
                {
                    rtxtSLANumber.Text = config[0].Value;
                }
                config.Clear();
                config.LoadBySiteCategorySectionAndKey(_SiteID, "D|WORKINGDEFAULTS", "", "ownname");
                if (config.Count > 0)
                {
                    using (WSupplier supplier = new WSupplier())
                    {
                        supplier.LoadByCodeAndSiteID(config[0].Value, _SiteID);
                        if (supplier.Count > 0)
                        {
                            supAddress = supplier[0].ContractAddress.Trim();
                            supAddress = supAddress.Replace(",", Environment.NewLine);
                            rtxtHospital.Text = supAddress;
                        }
                    }
                }
            }
            optOpenClaims.Checked = true;
            if (rcboFiles.Enabled == false) rcboFiles.Enabled = true;
            PopulateComboOpenClaims();
        }
        else
        {
            //if (optOpenClaims.Checked && rcboFiles.SelectedValue.Length > 0)
            //{
            //    _start = GetClaimStartDate(Convert.ToDateTime(rcboFiles.SelectedValue));
            //    _end = GetClaimEndDate(Convert.ToDateTime(rcboFiles.SelectedValue));
            //    RadGrid1.Rebind();
            //}
            switch (hdnFunction.Value)
            {
                case "SubmitClaimFile":
                    hdnFunction.Value = "";
                    CreateClaimFile();
                    break;
            }
        }
    }

    protected void PopulateComboOpenClaims()
    {
        RadGrid1.CurrentPageIndex = 0; // 29Mar12 AJK 30742 Reset page index
        _start = null;
        _end = null;
        rcboFiles.Items.Clear();
        RadGrid1.Columns[0].Visible = true;
        //RadGrid1.Rebind();
        //DateTime? oldestClaim = null;
        //using (PCTClaimTransaction claim = new PCTClaimTransaction())
        //{
        //    claim.GetAllOpenClaimsAndSiteID(_SiteID);
        //    if (claim.Count > 0)
        //    {
        //        oldestClaim = claim[0].ServiceDate;
        //    }
        //}
        //DateTime today = DateTime.Now;
        using (PCTClaimFileProcessor processor = new PCTClaimFileProcessor())
        {
            //RadComboBoxItem blankItem = new RadComboBoxItem();
            //blankItem.Text = "";
            //blankItem.Value = "";
            //rcboFiles.Items.Add(blankItem);
            List<PCTClaimFileLine> claimFiles = processor.LoadAllOpen(_SiteID);
            int currentClaimPeriodIndex = -1;
            foreach (PCTClaimFileLine claim in claimFiles)
            {
                DateTime start = PCTClaimFileProcessor.GetClaimStartDate(claim.ClaimDate);
                RadComboBoxItem item = new RadComboBoxItem();
                item.Text = string.Format("{0:dd MMM yyyy}", start) + " - " + string.Format("{0:dd MMM yyyy}", claim.ClaimDate) + "   OPEN";
                item.Value = claim.PCTClaimFileID.ToString();
                rcboFiles.Items.Add(item);
                if (PCTClaimFileProcessor.GetClaimEndDate(DateTime.Today) == claim.ClaimDate)
                    currentClaimPeriodIndex = rcboFiles.Items.Count - 1;
            }
            //if (currentClaimPeriodIndex == 0)
            //{
            //    PCTClaimFileLine currentFile = processor.GetPCTClaimFileByClaimDate(PCTClaimFileProcessor.GetClaimEndDate(DateTime.Today), _SiteID);
            //    RadComboBoxItem item = new RadComboBoxItem();
            //    item.Text = string.Format("{0:dd MMM yyyy}", PCTClaimFileProcessor.GetClaimStartDate(currentFile.ClaimDate)) + " - " + string.Format("{0:dd MMM yyyy}", currentFile.ClaimDate) + "   OPEN";
            //    item.Value = currentFile.PCTClaimFileID.ToString();
            //    rcboFiles.Items.Add(item);
            //    currentClaimPeriodIndex = rcboFiles.Items.Count - 1;
            //}
            if (currentClaimPeriodIndex > -1)
                rcboFiles.SelectedIndex = currentClaimPeriodIndex;
            RadGrid1.MasterTableView.ClearEditItems(); 
            CheckAndRebind();
            btnCredit.Enabled = false;
            btnResend.Enabled = false;  // btnResubmit.Enabled = false; 30Jul15 XN 111596 rename resend button
            btnHold.Enabled = true;
            hdnEditMode.Value = "";
        }
    }



    protected void RadGrid1_NeedDataSource(object sender, Telerik.Web.UI.GridNeedDataSourceEventArgs e)
    {
        int numberOfLines = 0;
        double totalClaimValue = 0;
        double recalcClaimValue = 0;
        DateTime? lastScheduleDate = null;

        //if ((optOpenClaims.Checked && _start.HasValue && _end.HasValue) || (optSubmittedClaims.Checked && rcboFiles.SelectedIndex > 1))
        if (rcboFiles.SelectedIndex > -1)
        {
            using (PCTClaimFileProcessor fileProcessor = new PCTClaimFileProcessor())
            {
                PCTClaimFileLine file = fileProcessor.LoadByPCTClaimFileID(int.Parse(rcboFiles.SelectedValue));
                rdatClaimDate.SelectedDate = file.ClaimDate;
                if (optSubmittedClaims.Checked)
                    rdatFileDate.SelectedDate = file.Generated;
                else
                    rdatFileDate.SelectedDate = null;
            }
            
            using (PCTClaimTransactionProcessor processor = new PCTClaimTransactionProcessor())
            {
                List<PCTClaimTransactionLine> claims = new List<PCTClaimTransactionLine>();
                //if (optOpenClaims.Checked)
                //    claims = processor.LoadByServiceDateRangeAndSiteID(_start.Value, _end.Value, _SiteID);
                //else
                    claims = processor.LoadByPCTClaimFileID(int.Parse(rcboFiles.SelectedValue));

                RadGrid1.DataSource = claims;

                hdnHasHeld.Value = "false";
                foreach (PCTClaimTransactionLine claim in claims)
                {
                    if (!(claim.Removed.HasValue && (bool)claim.Removed))
                    {
                        numberOfLines++;
                        // 15May13 AJK 64301 Corrections for total calculation to correctly handle credits
                        if (claim.Credit.HasValue && claim.Credit == true)
                        {
                            totalClaimValue -= claim.ClaimAmount.HasValue ? (double)claim.ClaimAmount : 0;
                        }
                        else
                        {
                            totalClaimValue += claim.ClaimAmount.HasValue ? (double)claim.ClaimAmount : 0; //claim has been removed prior to submission
                        }
                    }
                    if (!((claim.ErrorResubmit.HasValue && (bool)claim.ErrorResubmit) || (claim.Removed.HasValue && (bool)claim.Removed) || (claim.RemovedSubmitted.HasValue && (bool)claim.RemovedSubmitted)))
                    {
                        // 15May13 AJK 64301 Corrections for total calculation to correctly handle credits
                        if (claim.Credit.HasValue && claim.Credit == true)
                        {
                            recalcClaimValue -= claim.ClaimAmount.HasValue ? (double)claim.ClaimAmount : 0; //Claim has been resubmitted or removed
                        }
                        else
                        {
                            recalcClaimValue += claim.ClaimAmount.HasValue ? (double)claim.ClaimAmount : 0; //Claim has been resubmitted or removed
                        }
                    }
                    if (claim.ScheduleDate.HasValue && (!lastScheduleDate.HasValue || claim.ScheduleDate > lastScheduleDate))
                        lastScheduleDate = claim.ScheduleDate.Value;
                    if (claim.OnHold.HasValue && (bool)claim.OnHold)
                        hdnHasHeld.Value = "true";
                }
            }
        }
        else
        {
            RadGrid1.DataSource = new string[]{};

        }
        rtxtNumberOfLines.Text = numberOfLines.ToString();
        rntxtTotalClaimValue.Value = totalClaimValue / 100;
        //rntxtTotalClaimValue.Value = 888888.88; // 03Apr12 AJK 31119 Removed debug line
        rntxtRecalculatedClaimValue.Value = recalcClaimValue / 100;
        rdatScheduleDate.SelectedDate = lastScheduleDate;

    }
    protected void RadGrid1_ItemDataBound(object sender, Telerik.Web.UI.GridItemEventArgs e)
    {
        if (e.Item is GridPagerItem)
        {
            GridPagerItem pager = (GridPagerItem)e.Item;
            Label lbl = (Label)pager.FindControl("ChangePageSizeLabel");
            lbl.Visible = false;

            RadComboBox combo = (RadComboBox)pager.FindControl("PageSizeComboBox");
            combo.Visible = false;
        }  
        else if (e.Item is GridEditFormItem && e.Item.IsInEditMode)
        {
            // Added to disable controls on the form from setting 21Aug15 XN 126577
            GridEditFormItem editItem = e.Item as GridEditFormItem;
            var dataIndexes = WConfiguration.Load<string>(this._SiteID, "D|PATBILL", "PCT", "PCTClaimFormDisabledFields", string.Empty, false).ParseCSV<int>(",", ignoreErrors: true);
            var form = editItem.FindControl(GridEditFormItem.EditFormUserControlID) as application_PCT_ClaimTransactionScreen_PCTClaimItemEditForm;
            form.DisableControls(dataIndexes);
        }
    }
    protected void optOpenClaims_CheckedChanged(object sender, EventArgs e)
    {
        if (rcboFiles.Enabled == false) rcboFiles.Enabled = true;
        if (optOpenClaims.Checked)
        {
            PopulateComboOpenClaims();
        }
    }
    protected void optSubmittedClaims_CheckedChanged(object sender, EventArgs e)
    {
        if (rcboFiles.Enabled == false) rcboFiles.Enabled = true;
        if (optSubmittedClaims.Checked)
        {
            PopulateComboSubmittedClaims();
        }
    }

    private void PopulateComboSubmittedClaims()
    {
        RadGrid1.CurrentPageIndex = 0; // 29Mar12 AJK 30742 Reset page index
        _start = null;
        _end = null;
        rcboFiles.Items.Clear();
        RadGrid1.Columns[0].Visible = false;
        //RadComboBoxItem blankItem = new RadComboBoxItem();
        //blankItem.Text = "";
        //blankItem.Value = "";
        //rcboFiles.Items.Add(blankItem);
        using (PCTClaimFileProcessor processor = new PCTClaimFileProcessor())
        {
            List<PCTClaimFileLine> claimFiles = new List<PCTClaimFileLine>();
            claimFiles = processor.LoadAllSubmitted(_SiteID);
            foreach (PCTClaimFileLine file in claimFiles)
            {
                RadComboBoxItem item = new RadComboBoxItem();
                item.Text = "ClaimFileID " + string.Format("{0:000000}", file.FileID) + " Submitted";
                item.Value = file.PCTClaimFileID.ToString();
                rcboFiles.Items.Add(item);
            }
        }
        rdatClaimDate.SelectedDate = null;
        btnCredit.Enabled = true;
        btnResend.Enabled = true;   // btnResubmit.Enabled = true; 30Jul15 XN 111596 rename resend button
        btnHold.Enabled = false;
        RadGrid1.MasterTableView.ClearEditItems(); // 29Mar12 AJK 30743 Clear all edit mode items
        hdnEditMode.Value = "";
        // 29Mar12 AJK 30744 Changed to full check so buttons get reset correctly.
        CheckAndRebind();
        //RadGrid1.Rebind();
        // 30744 END
    }

    protected void rcboFiles_SelectedIndexChanged(object sender, RadComboBoxSelectedIndexChangedEventArgs e)
    {
        RadGrid1.MasterTableView.ClearEditItems();
        hdnEditMode.Value = "";
        RadGrid1.CurrentPageIndex = 0;
        CheckAndRebind();
    }

    /// <summary>
    /// Sets all form buttons to their correct state
    /// </summary>
    private void SetButtonState()
    {
        // 29Mar12 AJK 30744 Added
        if (rcboFiles.SelectedValue.Length > 0)
        {
            btnRemove.Enabled = true;   
            if (optOpenClaims.Checked)
            {
                btnCredit.Enabled = false;
                btnResend.Enabled = false;  // btnResubmit.Enabled = false; 30Jul15 XN 111596 rename resend button
                btnHold.Enabled = true;
                if (rcboFiles.SelectedIndex == 0)
                {
                    PCTClaimFileLine claimFile = new PCTClaimFileLine();
                    using (PCTClaimFileProcessor processor = new PCTClaimFileProcessor())
                    {
                        claimFile = processor.LoadByPCTClaimFileID(int.Parse(rcboFiles.SelectedValue));
                    }
                    if (claimFile.ClaimDate < DateTime.Today)
                        btnSubmitClaim.Disabled = false;
                    else
                        btnSubmitClaim.Disabled = true;
                }
                else
                {
                    btnSubmitClaim.Disabled = true;
                }
            }
            else
            {
                btnCredit.Enabled = true;
                btnResend.Enabled = true;   // btnResubmit.Enabled = true; 30Jul15 XN 111596 rename resend button
                btnHold.Enabled = false; 
                btnSubmitClaim.Disabled = true;
            }
        }
        else
            btnSubmitClaim.Disabled = true;
    }

    protected void CheckAndRebind()
    {
        // 29Mar12 AJK 30744 Removed a lot of logic and wrapped it in new function, SetButtonState.
        SetButtonState();
        if (rcboFiles.SelectedValue.Length > 0)
        {
            if (optOpenClaims.Checked)
            {
                RadGrid1.Rebind();
            }
            else
            {
                _start = null;
                _end = null;
                rdatClaimDate.SelectedDate = null;
                RadGrid1.Rebind();
            }
        }
    }

    protected void rbtnSubmitClaim_Click(object sender, EventArgs e)
    {
        CreateClaimFile();
    }

    protected void CreateClaimFile()
    {
        //Get data
        //int numberOfLines = 0;
        DateTime? lastScheduleDate = null;
        string fileName = "";
        string outputFolder = "";
        hdnHasHeld.Value = "false";
        //_start = PCTClaimFileProcessor.GetClaimStartDate(Convert.ToDateTime(rcboFiles.SelectedValue));
        //_end = PCTClaimFileProcessor.GetClaimEndDate(Convert.ToDateTime(rcboFiles.SelectedValue));
        //if (_start.HasValue && _end.HasValue)
        //{
        using (PCTClaimTransactionProcessor processor = new PCTClaimTransactionProcessor())
        {
            //List<PCTClaimTransactionLine> claims = processor.LoadByServiceDateRangeAndSiteID(_start.Value, _end.Value, _SiteID);
            List<PCTClaimTransactionLine> claims = processor.LoadByPCTClaimFileID(int.Parse(rcboFiles.SelectedValue));
            foreach (PCTClaimTransactionLine claim in claims)
            {
                //numberOfLines++;
                //move on hold items here and reload collection
                if (claim.OnHold.HasValue && (bool)claim.OnHold)
                {
                    //Move the claim to the next open claim period, create total copy
                    PCTClaimTransactionLine newClaim = processor.CreateCopy(claim);
                    using (PCTClaimFileProcessor fileProcessor = new PCTClaimFileProcessor())
                    {
                        PCTClaimFileLine file = fileProcessor.GetOldestOpenClaimFile(_SiteID, true);
                        newClaim.PCTClaimFileID = file.PCTClaimFileID;
                    }
                    claim.SupersededDate = DateTime.Today;
                    claim.SupersededByEntityID = SessionInfo.EntityID;
                    processor.Update(claim);
                    processor.Update(newClaim);
                }

                if (!(claim.Removed.HasValue && (bool)claim.Removed) && claim.ScheduleDate.HasValue && (!lastScheduleDate.HasValue || claim.ScheduleDate > lastScheduleDate))
                    lastScheduleDate = claim.ScheduleDate.Value;
            }
            claims = processor.LoadByPCTClaimFileID(int.Parse(rcboFiles.SelectedValue)); //Reload
            outputFolder = (string)WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "PCTClaimFileOutputFolder", "", false, typeof(string));
            if (!Directory.Exists(outputFolder))
            {
                throw new ApplicationException(string.Format("PCT Claim File Output Folder does not exist (PCTClaimFileOutputFolder={0})", outputFolder));
            }
            else
            {
                using (PCTClaimFileProcessor fileProcessor = new PCTClaimFileProcessor())
                {
                    FileStream fs;
                    StreamWriter sw;
                    if (!outputFolder.EndsWith("\\"))
                        outputFolder += "\\";
                    PCTClaimFileLine claimFile = new PCTClaimFileLine();
                    int fileID = PharmacyCounter.GetNextCount(_SiteID, "PCT", "ClaimFile", "FileID");
                    fileName += WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "ServiceProvide", "20", false, typeof(string)).ToString();
                    fileName += string.Format("{0:000000}", fileID);
                    fileName += ".";
                    fileName += WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "FileNameSuffix", "DHB", false, typeof(string)).ToString();
                    if (File.Exists(outputFolder + fileName))
                    {
                        string msg = string.Format("File already exists in output folder ({0}). Next time a file submission is created the next file ID in the sequence will be used. No claims have been updated at this time.", outputFolder + fileName);
                        throw new ApplicationException(msg);
                    }
                    claimFile = fileProcessor.LoadByPCTClaimFileID(int.Parse(rcboFiles.SelectedValue));
                    //claimFile.ClaimDate = _end.Value;
                    claimFile.DataSpecificationRelease = WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "DataSpecificationRelease", "100", false, typeof(string)).ToString();
                    claimFile.Generated = DateTime.Now;
                    claimFile.ScheduleDate = lastScheduleDate;
                    claimFile.SLANumber = rtxtSLANumber.Text;
                    claimFile.System = WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "SystemName", "ASCRIBE", false, typeof(string)).ToString();
                    claimFile.SystemVersion = WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "SystemVersion", "10", false, typeof(string)).ToString();
                    claimFile.FileID = fileID;
                    
                    fs = new FileStream(outputFolder + fileName, FileMode.CreateNew, FileAccess.Write);
                    sw = new StreamWriter(fs);

                    StringBuilder sb = new StringBuilder();
                    //Write header
                    //Record type
                    sb.Append(FormatCharString(WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "ServiceProvide", "20", false, typeof(string)).ToString() + WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "DataSpecificationRelease", "100", false, typeof(string)).ToString()));
                    //Sequence No
                    sb.Append(",1");
                    //FileID
                    sb.Append("," + FormatCharString(string.Format("{0:00000000}", fileID)));
                    //SLA Number
                    sb.Append("," + FormatCharString(rtxtSLANumber.Text));
                    //File date
                    sb.Append("," + FormatDateString(claimFile.Generated));
                    //Blanks
                    sb.Append(",,,");
                    //System
                    sb.Append("," + FormatCharString(claimFile.System));
                    //System Version
                    sb.Append("," + FormatCharString(claimFile.SystemVersion));
                    //Schedule Date
                    sb.Append("," + FormatDateString(claimFile.ScheduleDate));
                    //Claim Date
                    sb.Append("," + FormatDateString(claimFile.ClaimDate));
                    //End Line
                    sb.Append("\r\n");

                    //Loop transactions
                    int counter = 1;
                    int totalClaimValue = 0;
                    foreach (PCTClaimTransactionLine claim in claims)
                    {
                        if (!(claim.Removed.HasValue && (bool)claim.Removed)) //do not include removed items
                        {
                            counter++;
                            if (claim.ClaimAmount.HasValue)
                                totalClaimValue += claim.ClaimAmount.Value;
                            //Record Type
                            sb.Append(FormatCharString(WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "DetailRecordType", "05", false, typeof(string)).ToString()));
                            //Sequence No
                            sb.Append("," + FormatNumberString(counter));
                            //Unique Transaction Number
                            sb.Append("," + FormatNumberString(claim.UniqueTransactionNumber));
                            //Transaction Category
                            if (claim.Credit.HasValue && (bool)claim.Credit)
                                sb.Append("," + FormatCharString("C")); //Credit
                            //else if (claim.Resubmission.HasValue && (bool)claim.Resubmission) XN 30Jul15 111182 Should always return an I type even for resends
                            //    sb.Append("," + FormatCharString("R")); //Resubmission
                            else
                                sb.Append("," + FormatCharString("I")); //Standard
                            //Component Number
                            sb.Append("," + FormatNumberString(claim.ComponentNumber));
                            //Total Component Number
                            sb.Append("," + FormatNumberString(claim.TotalComponentNumber));
                            //Blank field x 2
                            sb.Append(",,");
                            //Prescriber ID
                            sb.Append("," + FormatCharString(claim.PrescriberID));
                            //Health Professional Group Code
                            sb.Append("," + FormatCharString(claim.HealthProfessionalGroupCode));
                            //3 blank fields
                            sb.Append(",,,");
                            //SpecialistID
                            sb.Append("," + FormatCharString(claim.SpecialistID));
                            //Date of endorsement
                            sb.Append("," + FormatDateString(claim.EndorsementDate));
                            //Prescriber Flag
                            sb.Append("," + FormatCharString(claim.PrescriberFlag));
                            //Oncology Patient Grouping
                            sb.Append("," + claim.PCTOncologyPatientGrouping);
                            // NHI
                            sb.Append("," + FormatCharString(claim.NHI));
                            //Patient Category
                            sb.Append("," + FormatCharString(claim.PCTPatientCategory));
                            //CSC or PHO Status Flag
                            sb.Append("," + FormatCharString(claim.CSCorPHOStatusFlag));
                            //2 BLanks
                            sb.Append(",,");
                            //HUHC Status Flag
                            sb.Append("," + FormatCharString(claim.HUHCStatusFlag));
                            //4 Blanks
                            sb.Append(",,,,");
                            //Special Authority Number
                            sb.Append("," + claim.SpecialAuthorityNumber);
                            //8 blanks
                            sb.Append(",,,,,,,,");
                            //Dose
                            sb.Append("," + FormatNumberString(claim.Dose.Value, 6, 4));
                            //Daily Dose
                            sb.Append("," + FormatNumberString(claim.DailyDose.Value, 6, 4));
                            //1 blank
                            sb.Append(",");
                            //Prescription Flag
                            sb.Append("," + FormatCharString(claim.PrescriptionFlag));
                            //Dose Flag
                            sb.Append("," + FormatCharString(claim.DoseFlag));
                            //PrescriptionID
                            sb.Append("," + claim.PrescriptionID);  // sb.Append("," + FormatNumberString(claim.UniqueTransactionNumber)); 30Jul15 XN 124027 return the correct field
                            //Prescription ID Suffix
                            sb.Append("," + claim.PrescriptionSuffix);
                            //Date of service
                            sb.Append("," + FormatDateString(claim.ServiceDate));
                            //Claim Code
                            sb.Append("," + FormatNumberString(claim.ClaimCode));
                            //Code Standard
                            sb.Append("," + FormatCharString(WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "PharmacodeCodeStandard", "P", false, typeof(string)).ToString()));
                            //1 blank
                            sb.Append(",");
                            //Quantity Claimed
                            sb.Append("," + FormatNumberString(claim.QuantityClaimed, 6, 4));
                            //1 Blank
                            sb.Append(",");
                            //Pack Unit of Measure
                            sb.Append("," + FormatCharString(claim.PackUnitOfMeasure));
                            //5 blanks
                            sb.Append(",,,,,");
                            //Order Type
                            sb.Append("," + FormatNumberString((int)WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "OncologyMedicineOrderType", "7", false, typeof(int))));
                            //1 blank
                            sb.Append(",");
                            //Claim Amount
                            sb.Append("," + FormatNumberString(claim.ClaimAmount));
                            //CBS Subsidy
                            sb.Append("," + FormatNumberString(claim.CBSSubsidy));
                            //CBS Packsize
                            sb.Append("," + FormatNumberString(claim.CBSPacksize, 6, 4));
                            //Funder
                            sb.Append("," + FormatCharString(claim.Funder));
                            //3 blanks
                            sb.Append(",,,");
                            //Form Number
                            sb.Append("," + claim.FormNumber);
                            //End line
                            sb.Append("\r\n");
                        }
                    }
                    //Trailer record
                    //Record Type
                    sb.Append(FormatCharString(WConfigurationController.LoadASetting(_SiteID, "D|Patbill", "PCT", "TrailerRecordType", "09", false, typeof(string)).ToString()));
                    //Sequence Number
                    counter++;
                    sb.Append("," + FormatNumberString(counter));
                    //Number of Lines
                    sb.Append("," + FormatNumberString(counter));
                    //Total Claim Value
                    sb.Append("," + FormatNumberString(totalClaimValue));
                    //1 blank
                    sb.Append(",");
                    
                    //Write and close file
                    sw.WriteLine(sb.ToString());
                    sw.Flush();
                    fs.Flush();
                    fs.Close();

                    //Update objects and mark as sent
                    foreach (PCTClaimTransactionLine claim in claims)
                    {
                        if (!(claim.Removed.HasValue && (bool)claim.Removed))
                        {
                            PCTClaimTransactionLine newClaim = processor.CreateCopy(claim);
                            //newClaim.Category = claim.Category;
                            //newClaim.CBSPacksize = claim.CBSPacksize;
                            //newClaim.ClaimAmount = claim.ClaimAmount;
                            //newClaim.ClaimCode = claim.ClaimCode;
                            //newClaim.ComponentNumber = claim.ComponentNumber;
                            //newClaim.CSCorPHOStatusFlag = claim.CSCorPHOStatusFlag;
                            //newClaim.DailyDose = claim.DailyDose;
                            //newClaim.Dose = claim.Dose;
                            //newClaim.DoseFlag = claim.DoseFlag;
                            //newClaim.EndorsementDate = claim.EndorsementDate;
                            //newClaim.FormNumber = claim.FormNumber;
                            //newClaim.Funder = claim.Funder;
                            //newClaim.HealthProfessionalGroupCode = claim.HealthProfessionalGroupCode;
                            //newClaim.HUHCStatusFlag = claim.HUHCStatusFlag;
                            //newClaim.NHI = claim.NHI;
                            //newClaim.PackUnitOfMeasure = claim.PackUnitOfMeasure;
                            //newClaim.PCTOncologyPatientGrouping = claim.PCTOncologyPatientGrouping;
                            //newClaim.PCTPatientCategory = claim.PCTPatientCategory;
                            //newClaim.PrescriberFlag = claim.PrescriberFlag;
                            //newClaim.PrescriberID = claim.PrescriberID;
                            //newClaim.PrescriptionFlag = claim.PrescriptionFlag;
                            //newClaim.PrescriptionID = claim.PrescriptionID;
                            //newClaim.QuantityClaimed = claim.QuantityClaimed;
                            //newClaim.ServiceDate = claim.ServiceDate;
                            //newClaim.SpecialAuthorityNumber = claim.SpecialAuthorityNumber;
                            //newClaim.SpecialistID = claim.SpecialistID;
                            //newClaim.TotalComponentNumber = claim.TotalComponentNumber;
                            //newClaim.ParentID = claim.ParentID.HasValue ? claim.ParentID : claim.PCTClaimTransactionID;
                            //newClaim.ScheduleDate = claim.ScheduleDate;
                            //newClaim.RequestID_Dispensing = claim.RequestID_Dispensing;
                            //newClaim.RequestID_Prescription = claim.RequestID_Prescription;
                            //newClaim.ScheduleDate = claim.ScheduleDate;
                            //newClaim.UniqueTransactionNumber = claim.UniqueTransactionNumber;
                            //newClaim.PrescriptionSuffix = claim.PrescriptionSuffix;
                            //newClaim.PCTClaimFileID = claimFile.PCTClaimFileID;
                            //newClaim.PrescriptionSuffix = claim.PrescriptionSuffix;
                            //newClaim.OnHold = claim.OnHold;
                            //newClaim.Modified = claim.Modified;
                            //newClaim.Resubmission = claim.Resubmission;
                            //newClaim.Credit = claim.Credit;
                            //newClaim.ErrorCredit = claim.ErrorCredit;
                            //newClaim.ErrorResubmit = claim.ErrorResubmit;
                            //newClaim.Removed = claim.Removed;
                            //newClaim.RemovedSubmitted = claim.RemovedSubmitted;
                            newClaim.PCTTransactionStatusID = PCTClaimTransaction.GetTransactionStatusIDByCode("S"); //Set status
                            processor.Update(newClaim);
                            claim.SupersededDate = DateTime.Now;
                            claim.SupersededByEntityID = SessionInfo.EntityID;
                            processor.Update(claim);
                        }
                    }
                    fileProcessor.Update(claimFile);
                }

                //RadWindowManager1.RadAlert(string.Format("File created: {0}", outputFolder + fileName), 330, 100, "File created", ""); 30Jul15 Fixed problem with '\' in filename
                RadWindowManager1.RadAlert(string.Format("File created: {0}", outputFolder + fileName).Replace("\\", "\\\\"), 330, 100, "File created", "");
                PopulateComboOpenClaims();
            }
        }
        //}
    }

    protected void RadGrid1_EditCommand(object sender, GridCommandEventArgs e)
    {
        CheckAndRebind();
        DisableButtons(); // 29Mar12 AJK 30744 Added
    }

    /// <summary>
    /// Disables all form buttons
    /// </summary>
    protected void DisableButtons()
    {
        // 29Mar12 AJK 30744 Added
        btnCredit.Enabled = false;
        btnResend.Enabled = false;  // btnResubmit.Enabled = false; 30Jul15 XN 111596 rename resend button
        btnHold.Enabled = false;
        btnSubmitClaim.Disabled = true;
        btnRemove.Enabled = false;  
    }

    protected void RadGrid1_UpdateCommand(object sender, GridCommandEventArgs e)
    {
        //e.Canceled = true;
        GridEditableItem editItem = (GridEditableItem)e.Item;
        //string newvalue = ((TextBox)editItem["PrescriberID"].Controls[0]).Text;
        //RadWindowManager1.RadAlert("The value has been changed to " + newvalue, 330, 100, "Value changed!", "alertCallBackFn");
        UpdateGridItem(editItem);
        CheckAndRebind();
    }

    protected void UpdateGridItem(GridEditableItem item)
    {
        using (PCTClaimTransactionProcessor processor = new PCTClaimTransactionProcessor())
        {
            PCTClaimTransactionLine oldClaim = processor.LoadByPCTClaimTransactionID((int)item.GetDataKeyValue("PCTClaimTransactionID"));
            PCTClaimTransactionLine newClaim = processor.CreateCopy(oldClaim);
            UserControl uc = (UserControl)item.FindControl(GridEditFormItem.EditFormUserControlID);
            newClaim.Category = string.IsNullOrEmpty((uc.FindControl("rtxtCategory") as RadTextBox).Text) ? null : (uc.FindControl("rtxtCategory") as RadTextBox).Text;
            newClaim.CBSPacksize = (decimal?)(uc.FindControl("rntbCBSPacksize") as RadNumericTextBox).Value;
            newClaim.CBSSubsidy = (int?)(uc.FindControl("rntbCBSSubsidy") as RadNumericTextBox).Value;
            newClaim.ClaimAmount = (int?)(uc.FindControl("rntbClaimAmount") as RadNumericTextBox).Value;
            newClaim.ClaimCode = (int?)(uc.FindControl("rntbClaimCode") as RadNumericTextBox).Value;
            newClaim.ComponentNumber = (int?)(uc.FindControl("tntbComponentNumber") as RadNumericTextBox).Value;
            newClaim.CSCorPHOStatusFlag = string.IsNullOrEmpty((uc.FindControl("rtxtCSCorPHO") as RadTextBox).Text) ? null : (uc.FindControl("rtxtCSCorPHO") as RadTextBox).Text;
            newClaim.DailyDose = (decimal?)(uc.FindControl("rntbDailyDose") as RadNumericTextBox).Value;
            newClaim.Dose = (decimal?)(uc.FindControl("rntbDose") as RadNumericTextBox).Value;
            newClaim.DoseFlag = (bool?)(uc.FindControl("chkDoseFlag") as CheckBox).Checked;
            newClaim.EndorsementDate = (uc.FindControl("rdatEndorsement") as RadDatePicker).SelectedDate;
            newClaim.FormNumber = string.IsNullOrEmpty((uc.FindControl("rtxtFormNumber") as RadTextBox).Text) ? null : (uc.FindControl("rtxtFormNumber") as RadTextBox).Text;
            newClaim.Funder = string.IsNullOrEmpty((uc.FindControl("rtxtFunder") as RadTextBox).Text) ? null : (uc.FindControl("rtxtFunder") as RadTextBox).Text;
            newClaim.HealthProfessionalGroupCode = string.IsNullOrEmpty((uc.FindControl("rtxtHPGC") as RadTextBox).Text) ? null : (uc.FindControl("rtxtHPGC") as RadTextBox).Text;
            newClaim.HUHCStatusFlag = (bool?)(uc.FindControl("chkHUHC") as CheckBox).Checked;
            newClaim.NHI = string.IsNullOrEmpty((uc.FindControl("rtxtNHINumber") as RadTextBox).Text) ? null : (uc.FindControl("rtxtNHINumber") as RadTextBox).Text;
            newClaim.PackUnitOfMeasure = string.IsNullOrEmpty((uc.FindControl("rtxtPUoM") as RadTextBox).Text) ? null : (uc.FindControl("rtxtPUoM") as RadTextBox).Text;
            newClaim.PCTOncologyPatientGrouping = string.IsNullOrEmpty((uc.FindControl("rtxtOncologyPatientGroup") as RadTextBox).Text) ? null : (uc.FindControl("rtxtOncologyPatientGroup") as RadTextBox).Text;
            newClaim.PCTPatientCategory = string.IsNullOrEmpty((uc.FindControl("rtxtPatientCategory") as RadTextBox).Text) ? null : (uc.FindControl("rtxtPatientCategory") as RadTextBox).Text;
            newClaim.PrescriberFlag = string.IsNullOrEmpty((uc.FindControl("rtxtFlag") as RadTextBox).Text) ? null : (uc.FindControl("rtxtFlag") as RadTextBox).Text;
            newClaim.PrescriberID = string.IsNullOrEmpty((uc.FindControl("rtxtPrescriberID") as RadTextBox).Text) ? null : (uc.FindControl("rtxtPrescriberID") as RadTextBox).Text;
            newClaim.PrescriptionFlag = (bool?)(uc.FindControl("chkPrescriptionFlag") as CheckBox).Checked;
            newClaim.PrescriptionID = string.IsNullOrEmpty((uc.FindControl("rtxtPrescriptionID") as RadTextBox).Text) ? null : (uc.FindControl("rtxtPrescriptionID") as RadTextBox).Text;
            newClaim.QuantityClaimed = (decimal?)(uc.FindControl("rntbQuantityClaimed") as RadNumericTextBox).Value;
            newClaim.ServiceDate = (uc.FindControl("rdatService") as RadDatePicker).SelectedDate;
            newClaim.SpecialAuthorityNumber = string.IsNullOrEmpty((uc.FindControl("rtxtSpecialAuth") as RadTextBox).Text) ? null : (uc.FindControl("rtxtSpecialAuth") as RadTextBox).Text;
            newClaim.SpecialistID = string.IsNullOrEmpty((uc.FindControl("ttxtSpecialistID") as RadTextBox).Text) ? null : (uc.FindControl("ttxtSpecialistID") as RadTextBox).Text;
            newClaim.TotalComponentNumber = (int?)(uc.FindControl("tntbTotalComponent") as RadNumericTextBox).Value;
            newClaim.ParentID = oldClaim.ParentID.HasValue ? oldClaim.ParentID : oldClaim.PCTClaimTransactionID;
            newClaim.PrescriptionSuffix = string.IsNullOrEmpty((uc.FindControl("rtxtPrescriptionSuffix") as RadTextBox).Text) ? null : (uc.FindControl("rtxtPrescriptionSuffix") as RadTextBox).Text;
            newClaim.PCTTransactionStatusID = PCTClaimTransaction.GetTransactionStatusIDByCode("C"); //Set status
            newClaim.Modified = true;

            PCTClaimFileLine claimFile = new PCTClaimFileLine();
            switch (hdnEditMode.Value)
            {
                case "credit":
                    newClaim.Credit = true;
                    newClaim.Category = "C"; // 15May13 AJK 64300 Correctly set claim category for UI
                    using (PCTClaimFileProcessor fileProcessor = new PCTClaimFileProcessor())
                    {
                        claimFile = fileProcessor.GetOldestOpenClaimFile(_SiteID, false);
                    }
                    newClaim.PCTClaimFileID = claimFile.PCTClaimFileID; //Re-assign to next available open claim file
                    newClaim.ParentID = null; //Remove credit claim from the the thread, start a new one
                    //PCTClaimTransactionLine newErrorCreditClaim = processor.LoadByPCTClaimTransactionID((int)item.GetDataKeyValue("PCTClaimTransactionID"));
                    PCTClaimTransactionLine newErrorCreditClaim = processor.CreateCopy(oldClaim);
                    newErrorCreditClaim.ParentID = oldClaim.ParentID.HasValue ? oldClaim.ParentID : oldClaim.PCTClaimTransactionID;
                    newErrorCreditClaim.ErrorCredit = true;
                    processor.Update(newErrorCreditClaim);
                    break;
                case "resend":  // "resubmit":  30Jul15 XN 111596 rename resend button
                    newClaim.Resubmission = true;
                    newClaim.Category = "I"; // changed from "R" to "I" 30Jul15 XN resubmit  // 15May13 AJK 64300 Correctly set claim category for UI
                    using (PCTClaimFileProcessor fileProcessor = new PCTClaimFileProcessor())
                    {
                        claimFile = fileProcessor.GetOldestOpenClaimFile(_SiteID, false);
                    }
                    newClaim.PCTClaimFileID = claimFile.PCTClaimFileID; //Re-assign to next available open claim file
                    newClaim.ParentID = null; //Remove credit claim from the the thread, start a new one
                    //PCTClaimTransactionLine newErrorResubmitClaim = processor.LoadByPCTClaimTransactionID((int)item.GetDataKeyValue("PCTClaimTransactionID"));
                    PCTClaimTransactionLine newErrorResubmitClaim = processor.CreateCopy(oldClaim);
                    newErrorResubmitClaim.ParentID = oldClaim.ParentID.HasValue ? oldClaim.ParentID : oldClaim.PCTClaimTransactionID;
                    newErrorResubmitClaim.ErrorResubmit = true;
                    processor.Update(newErrorResubmitClaim);
                    break;
                default:
                    
                    break;
            }
            oldClaim.SupersededDate = DateTime.Now;
            oldClaim.SupersededByEntityID = SessionInfo.EntityID;
            processor.Update(newClaim);
            processor.Update(oldClaim);
            hdnEditMode.Value = "";
        }
    }

    protected void RadGrid1_SortCommand(object sender, GridSortCommandEventArgs e)
    {
        CheckAndRebind();
    }
    protected void RadGrid1_PageIndexChanged(object sender, GridPageChangedEventArgs e)
    {
        CheckAndRebind();
    }
    protected void RadGrid1_CancelCommand(object sender, GridCommandEventArgs e)
    {
        hdnEditMode.Value = "";
        CheckAndRebind();
    }
    protected void RadGrid1_PreRender(object sender, EventArgs e)
    {
        foreach (GridDataItem dataItem in RadGrid1.Items)
        {
            // 12Apr12 AJK 31851 Removed
            //foreach (GridColumn col in RadGrid1.Columns)
            //{
            //    if (dataItem[col.UniqueName].Text.Trim() == string.Empty)
            //    {
            //        dataItem[col.UniqueName].Text = "&nbsp;";
            //    }
            //}
            if (dataItem["Status"].Text.Contains("H") || dataItem["Status"].Text.Contains("Q") || dataItem["Status"].Text.Contains("E") || dataItem["Status"].Text.Contains("X"))
            {
                dataItem["EditCommandColumn"].Text = "";
            }
        }
        // 12Apr12 AJK 31851 Added new iterator to ensure that table cells are never emtpy and grid lines are always drawn
        foreach (GridItem item in (sender as RadGrid).MasterTableView.Items)
        {
            foreach (TableCell cell in item.Cells)
            {
                string newValue = cell.Text.Trim();
                if (newValue.Length >= 13 && newValue.Substring(0, 6) == "<nobr>" && newValue.Substring(newValue.Length - 7, 7) == "</nobr>")
                {
                    newValue = newValue.Substring(6, newValue.Length - 13).Trim();
                }
                if (String.IsNullOrEmpty(newValue))
                {
                    cell.Text = "&nbsp;";
                }
            }
        }
    }

    protected string FormatDateString(DateTime? date)
    {
        if (date.HasValue)
        {
            string ret;
            ret = string.Format("{0:00}", date.Value.Day);
            ret += string.Format("{0:00}", date.Value.Month);
            ret += string.Format("{0:0000}", date.Value.Year);
            return ret;
        }
        else
            return "";
    }

    protected string FormatCharString(bool? value)
    {
        string ret = "";
        if (value.HasValue)
        {
            if (value.Value)
                ret = "\"Y\"";
            else
                ret = "\"N\"";
        }
        else
        {
            ret = "\"\"";
        }
        return ret;
    }

    protected string FormatNumberString(int? value)
    {
        if (value.HasValue)
            return string.Format("{0:0;0}", value);
        else
            return "";
    }

    protected string FormatNumberString(decimal? value, int whole, int decimals)
    {
        if (value.HasValue)
        {
            string ret;
            string wholeFormat = new string('0', whole);
            string decimalFormat = new string('0', decimals);
            ret = string.Format("{0:" + wholeFormat + ";" + wholeFormat + "}", Math.Floor(value.Value));
            decimal justDecs = value.Value - Math.Floor(value.Value);
            justDecs = justDecs * (decimal)Math.Pow(10, decimals);
            justDecs = Math.Round(justDecs, 0, MidpointRounding.AwayFromZero);
            ret += string.Format("{0:" + decimalFormat + ";" + decimalFormat + "}", justDecs);
            return ret;
        }
        else
            return "";
    }

    protected string FormatCharString(string value)
    {
        if (value != null)
            return "\"" + value.Replace(",", "") + "\"";
        else
        {
            return "\"\"";
        }
    }

    protected void btnCredit_Click(object sender, EventArgs e)
    {
        CustomEditMode("credit");
    }
    protected void btnResend_Click(object sender, EventArgs e)
    {
        CustomEditMode("resend"); // change resubmit to resend 30Jul15 XN 111596
    }

    protected void CustomEditMode(string mode)
    {
        int updated = 0; // 29Mar12 AJK 30744 Added
        RadGrid1.MasterTableView.ClearEditItems(); // 29Mar12 AJK 30743 Clear edit items
        foreach (GridDataItem item in RadGrid1.Items)
        {
            if (item.Selected == true)
            {
                updated++;
                using (PCTClaimTransactionProcessor processor = new PCTClaimTransactionProcessor())
                {
                    PCTClaimTransactionLine claim = processor.LoadByPCTClaimTransactionID(int.Parse(item.GetDataKeyValue("PCTClaimTransactionID").ToString()));
                    if ((claim.ErrorCredit.HasValue && (bool)claim.ErrorCredit) || (claim.ErrorResubmit.HasValue && (bool)claim.ErrorResubmit) || (claim.OnHold.HasValue && (bool)claim.OnHold) || (claim.Removed.HasValue && (bool)claim.Removed) || (claim.RemovedSubmitted.HasValue && (bool)claim.RemovedSubmitted))
                    {
                        string action = "";
                        switch (mode)
                        {
                            case "credit":
                                action = "raise a credit for this claim line";
                                break;
                            case "resend":  // change resubmit to resend 30Jul15 XN 111596
                                action = "resend this claim line";
                                break;
                        }
                        RadWindowManager1.RadAlert("You cannot " + action, 300, 300, "Error", "");
                    }
                    else
                    {
                        hdnEditMode.Value = mode;
                        item.Edit = true;
                        CheckAndRebind();
                    }
                }
            }
        }
        if (updated == 0)  // 29Mar12 AJK 30744 Added check to display message if nothing was changed due to no items being selected
        {
            RadWindowManager1.RadAlert("No item selected", 300, 100, "Error", "");
        }
    }

    protected void ButtonUpdate(string mode)
    {
        int updated = 0; // 29Mar12 AJK 30744 Added
        RadGrid1.MasterTableView.ClearEditItems(); // 29Mar12 AJK 30743 Clear edit items
        foreach (GridDataItem item in RadGrid1.Items)
        {
            if (item.Selected)
            {
                updated++;
                using (PCTClaimTransactionProcessor processor = new PCTClaimTransactionProcessor())
                {
                    PCTClaimTransactionLine claim = processor.LoadByPCTClaimTransactionID(int.Parse(item.GetDataKeyValue("PCTClaimTransactionID").ToString()));

                    if (mode == "remove" && ((claim.ErrorCredit.HasValue && (bool)claim.ErrorCredit) || (claim.ErrorResubmit.HasValue && (bool)claim.ErrorResubmit) || (claim.OnHold.HasValue && (bool)claim.OnHold) || (claim.Removed.HasValue && (bool)claim.Removed) || (claim.RemovedSubmitted.HasValue && (bool)claim.RemovedSubmitted)))
                    {
                        RadWindowManager1.RadAlert("You cannot remove this claim line", 300, 300, "Error", "");
                    }
                    else if (mode == "hold" && ((claim.ErrorCredit.HasValue && (bool)claim.ErrorCredit) || (claim.ErrorResubmit.HasValue && (bool)claim.ErrorResubmit) || (claim.Removed.HasValue && (bool)claim.Removed) || (claim.RemovedSubmitted.HasValue && (bool)claim.RemovedSubmitted)))
                    {
                        RadWindowManager1.RadAlert("You cannot place this item on hold", 300, 300, "Error", "");
                    }
                    else
                    {
                        //PCTClaimTransactionLine newClaim = new PCTClaimTransactionLine();
                        PCTClaimTransactionLine newClaim = processor.CreateCopy(claim);
                        //newClaim.Category = claim.Category;
                        //newClaim.CBSPacksize = claim.CBSPacksize;
                        //newClaim.CBSSubsidy = claim.CBSSubsidy;
                        //newClaim.ClaimAmount = claim.ClaimAmount;
                        //newClaim.ClaimCode = claim.ClaimCode;
                        //newClaim.ComponentNumber = claim.ComponentNumber;
                        //newClaim.Credit = claim.Credit;
                        //newClaim.CSCorPHOStatusFlag = claim.CSCorPHOStatusFlag;
                        //newClaim.DailyDose = claim.DailyDose;
                        //newClaim.Dose = claim.Dose;
                        //newClaim.DoseFlag = claim.DoseFlag;
                        //newClaim.EndorsementDate = claim.EndorsementDate;
                        //newClaim.FormNumber = claim.FormNumber;
                        //newClaim.Funder = claim.Funder;
                        //newClaim.HealthProfessionalGroupCode = claim.HealthProfessionalGroupCode;
                        //newClaim.HUHCStatusFlag = claim.HUHCStatusFlag;
                        //newClaim.Modified = claim.Modified;
                        //newClaim.NHI = claim.NHI;
                        //newClaim.PackUnitOfMeasure = claim.PackUnitOfMeasure;
                        newClaim.ParentID = claim.ParentID.HasValue ? claim.ParentID : claim.PCTClaimTransactionID;
                        //newClaim.PCTClaimFileID = claim.PCTClaimFileID;
                        //newClaim.PCTOncologyPatientGrouping = claim.PCTOncologyPatientGrouping;
                        //newClaim.PCTPatientCategory = claim.PCTPatientCategory;
                        //newClaim.PCTTransactionStatusID = claim.PCTTransactionStatusID;
                        //newClaim.PrescriberFlag = claim.PrescriberFlag;
                        //newClaim.PrescriberID = claim.PrescriberID;
                        //newClaim.PrescriptionFlag = claim.PrescriptionFlag;
                        //newClaim.PrescriptionID = claim.PrescriptionID;
                        //newClaim.PrescriptionSuffix = claim.PrescriptionSuffix;
                        //newClaim.QuantityClaimed = claim.QuantityClaimed;
                        //newClaim.RequestID_Dispensing = claim.RequestID_Dispensing;
                        //newClaim.RequestID_Prescription = claim.RequestID_Prescription;
                        //newClaim.Resubmission = claim.Resubmission;
                        //newClaim.ScheduleDate = claim.ScheduleDate;
                        //newClaim.ServiceDate = claim.ServiceDate;
                        //newClaim.SpecialAuthorityNumber = claim.SpecialAuthorityNumber;
                        //newClaim.SpecialistID = claim.SpecialistID;
                        //newClaim.Status = claim.Status;
                        //newClaim.TotalComponentNumber = claim.TotalComponentNumber;
                        //newClaim.UniqueTransactionNumber = claim.UniqueTransactionNumber;
                        claim.SupersededDate = DateTime.Now;
                        claim.SupersededByEntityID = SessionInfo.EntityID;
                        switch (mode)
                        {
                            case "remove":
                                if (optOpenClaims.Checked)
                                {
                                    newClaim.Removed = true;
                                    newClaim.RemovedSubmitted = false;
                                }
                                else
                                {
                                    newClaim.Removed = claim.Removed;
                                    newClaim.RemovedSubmitted = true;
                                }
                                newClaim.OnHold = claim.OnHold;
                                break;
                            case "hold":
                                newClaim.Removed = claim.Removed;
                                newClaim.RemovedSubmitted = claim.RemovedSubmitted;
                                if (claim.OnHold.HasValue && (bool)claim.OnHold)
                                    newClaim.OnHold = false;
                                else
                                    newClaim.OnHold = true;
                                break;
                        }
                        processor.Update(claim);
                        processor.Update(newClaim);
                        CheckAndRebind();
                    }
                }
            }
        }
        if (updated == 0)  // 29Mar12 AJK 30744 Added check to display message if nothing was changed due to no items being selected
        {
            RadWindowManager1.RadAlert("No item selected", 300, 100, "Error", "");        
        }

    }

    protected void btnRemove_Click(object sender, EventArgs e)
    {
        ButtonUpdate("remove");
    }
    protected void btnHold_Click(object sender, EventArgs e)
    {
        ButtonUpdate("hold");
    }
}
