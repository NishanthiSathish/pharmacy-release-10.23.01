using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using Telerik.Web.UI;


// 28Mar12 30493 AJK Added validator event valDaysEven_ServerValidate along with variables for 48hr bag flag.
// 28Mar12 30669 AJK Changed validators to roll up some checks into a single message. 
// 28Mar12 30676 AJK Programmatically change labels if combined
// 28Mar12 30839 AJK Added check for 0 on all required numeric fields. Changed capitalisation on some labels.
// 19Apr12 32172 AJK Page_Load: 48hour bag check moved from prescription to regimen
// 25Sep15 77780 XN  SetPatientDetails Hong Kong specific mode to display Chinese name 
// 21Oct15 77772 XN  Added a default for the number of days required

public partial class application_PNSupplyRequest_PNSupplyRequest : System.Web.UI.Page
{
    int  _siteID;
    protected int _sessionID;
    int? _regimenID;
    int? pnSupplierRequestID;
    int  _rxID;
    int  _episodeID;
    bool _48hr; // 28Mar12 30493 AJK Added

    protected void Page_Load(object sender, EventArgs e)
    {
        int siteNumber = int.Parse(Request.QueryString["AscribeSiteNumber"]); 
        _sessionID = int.Parse(Request.QueryString["SessionID"]);

        if (!string.IsNullOrEmpty(Request["RequestID"]))
            this.pnSupplierRequestID = int.Parse(Request["RequestID"]);

        if (!string.IsNullOrEmpty(Request["RequestID_Parent"]))
            this._regimenID = int.Parse(Request["RequestID_Parent"]);

        if (!pnSupplierRequestID.HasValue && !_regimenID.HasValue)
            throw new ApplicationException("Need to set either RequestID, or RequestID_Parent as url parameters.");

        SessionInfo.InitialiseSessionAndSiteNumber(_sessionID, siteNumber);
        _siteID = SessionInfo.SiteID;
        if (!IsPostBack)
        {
            bool combined;
            bool adult;
            string defaultSection = "";
            rdpAdminStart.MinDate = DateTime.Now;
            rdpAdminStart.MaxDate = DateTime.Now.AddMonths(1);
            rdpPreparationDate.MinDate = DateTime.Now;
            rdpPreparationDate.MaxDate = DateTime.Now.AddMonths(1);

            PNSupplyRequest pnSupplierRequest = new PNSupplyRequest();
            if (pnSupplierRequestID.HasValue)
            {
                pnSupplierRequest.LoadByRequestID(pnSupplierRequestID.Value);
                this._regimenID = pnSupplierRequest[0].RequestID_Parent;
            }

            //Load PN Prescription
            using (PNRegimen pnRegimen = new PNRegimen())
            {
                pnRegimen.LoadByRequestID(_regimenID.Value);
                _episodeID = pnRegimen[0].EpisodeID;
                hdnEpisodeID.Value = _episodeID.ToString();
                combined = pnRegimen[0].IsCombined;
                hf48hr.Value = pnRegimen[0].Supply48Hours.ToString(); // 19Apr12 32172 AJK Added to regimen
                _48hr = pnRegimen[0].Supply48Hours; // 19Apr12 32172 AJK Added to regimen
                using (PNPrescrtiption pnRx = new PNPrescrtiption())
                {
                    _rxID = pnRegimen[0].RequestID_Parent;
                    hdnRxID.Value = _rxID.ToString();
                    pnRx.LoadByRequestID(_rxID);
                    adult = !pnRx[0].PerKiloRules;
                    lblWeight.Text = pnRx[0].DosingWeightInkg.ToString("0.##") + " kg"; // 28Mar12 30839 AJK Changed capitalisation
                    // 19Apr12 32172 AJK Removed from prescription
                    // 28Mar12 30493 AJK Added
                    //_48hr = pnRx[0].Supply48Hours;
                    //hf48hr.Value = _48hr.ToString();
                    // 30493 END
                    // 19Apr12 32172 END
                }
                lblRegimenDescription.Text = pnRegimen[0].Description;
                rtxtBatchNumber.Focus();
            }
            if (adult)
            {
                defaultSection = "AdultDefault";
            }
            else
            {
                defaultSection = "PaedDefault";
            }
            int counter = PharmacyCounter.GetNextCount(_siteID, "D|PN", "PNSupplyRequest", "BatchNumberCounter");
            string defaultBatchNo = "";
            bool canEditBatchNumber = (bool)WConfigurationController.LoadASetting(_siteID, "D|PN", defaultSection, "EditBatchNumber", "1", false, typeof(bool));
            rtxtBatchNumber.ReadOnly = !canEditBatchNumber;
            string yearFormat = (string)WConfigurationController.LoadASetting(_siteID, "D|PN", defaultSection, "BatchNumberYearFormat", "YY", false, typeof(string));
            string monthFormat = (string)WConfigurationController.LoadASetting(_siteID, "D|PN", defaultSection, "BatchNumberMonthFormat", "A", false, typeof(string));
            string seqFormat = (string)WConfigurationController.LoadASetting(_siteID, "D|PN", defaultSection, "BatchNumberSequenceFormat", "000", false, typeof(string));
            int aqueousCombinedExpDays = 0;
            int aqueousCombinedQtyReq = 0;
            if (combined)
            {
                aqueousCombinedExpDays = (int)WConfigurationController.LoadASetting(_siteID, "D|PN", defaultSection, "CombinedExpiryInDays", "4", false, typeof(int));
                aqueousCombinedQtyReq = (int)WConfigurationController.LoadASetting(_siteID, "D|PN", defaultSection, "CombinedNumberOfLabels", "2", false, typeof(int));
            }
            else
            {
                aqueousCombinedExpDays = (int)WConfigurationController.LoadASetting(_siteID, "D|PN", defaultSection, "AqueousExpiryInDays", "4", false, typeof(int));
                aqueousCombinedQtyReq = (int)WConfigurationController.LoadASetting(_siteID, "D|PN", defaultSection, "AqueousNumberOfLabels", "2", false, typeof(int));
            }
            int lipidExpDays = (int)WConfigurationController.LoadASetting(_siteID, "D|PN", defaultSection, "LipidExpiryInDays", "4", false, typeof(int));
            bool baxa = (bool)WConfigurationController.LoadASetting(_siteID, "D|PN", defaultSection, "BaxaCompounderInUse", "0", false, typeof(bool));
            int lipidQtyReq = (int)WConfigurationController.LoadASetting(_siteID, "D|PN", defaultSection, "LipidNumberOfLabels", "2", false, typeof(int));

            hfAqueousCombinedExpDays.Value = aqueousCombinedExpDays.ToString();
            hfLipidExpDays.Value           = lipidExpDays.ToString();

            rntxtAqueousCombinedLabelQty.Value = aqueousCombinedQtyReq;
            rntxtLipidLabelQty.Value = lipidQtyReq;

            switch (yearFormat)
            {
                case "A":
                    if (DateTime.Now.Year > 2000 && DateTime.Now.Year < 2027)
                    {
                        defaultBatchNo = ((char)(64 + DateTime.Now.Year - 2000)).ToString();
                    }
                    else
                    {
                        defaultBatchNo = DateTime.Now.Year.ToString().Substring(3, 1);
                    }
                    break;
                case "Y":
                    defaultBatchNo = DateTime.Now.Year.ToString().Substring(3, 1);
                    break;
                case "YY":
                    defaultBatchNo = DateTime.Now.Year.ToString().Substring(2, 2);
                    break;
                default:
                    defaultBatchNo = "Y";
                    RadWindowManager1.RadAlert("Incorrect setting for BatchNumberYearFormat in D|PN, please amend", 330, 100, "Incorrect Wconfiguration setting", "");
                    break;
            }
            switch (monthFormat)
            {
                case "A":
                    defaultBatchNo += ((char)(64 + DateTime.Now.Month)).ToString();
                    break;
                case "MM":
                    defaultBatchNo += string.Format("{0:00}", DateTime.Now.Month).ToString();
                    break;
                default:
                    defaultBatchNo += "M";
                    RadWindowManager1.RadAlert("Incorrect setting for BatchNumberMonthFormat in D|PN, please amend", 330, 100, "Incorrect Wconfiguration setting", "");
                    break;
            }
            defaultBatchNo += string.Format("{0:00}", DateTime.Now.Day).ToString();
            switch (seqFormat)
            {
                case "00":
                case "000":
                    defaultBatchNo += string.Format("{0:" + seqFormat + "}", counter);
                    break;
                default:
                    defaultBatchNo += "XXX";
                    RadWindowManager1.RadAlert("Incorrect setting for BatchNumberSequenceFormat in D|PN, please amend", 330, 100, "Incorrect Wconfiguration setting", "");
                    break;
            }
            rtxtBatchNumber.Text = defaultBatchNo;
            if (combined)
            {
                lblAqueousCombinedExpiry.Text = "Expiry Date";
                rowLipidExpDate.Visible = false;
                lblAqueousCombinedLabelQty.Text = "Label Quantity Required";
                rowLipidLabels.Visible = false;
                lblAqueousCombinedExpiry.Text = "Expiry"; // 28Mar12 30669 AJK Added 
                lblAqueousCombinedLabelQty.Text = "Number of Labels"; // 28Mar12 30669 AJK Added 
            }
            else
                rnLipidExpiryDays.Value = lipidExpDays;                    
            rdpPreparationDate.SelectedDate = DateTime.Now;
            rnAqueousCombinedExpiryDays.Value = aqueousCombinedExpDays;
            string baxaIncludeLipid = "";
            if (baxa)
            {
                rowBaxaCompounder.Visible = true;
                if (adult)
                {
                    if (combined)
                    {
                        baxaIncludeLipid = (string)(WConfigurationController.LoadASetting(_siteID, "D|PN", "BAXA", "AdultCombined", "?", false, typeof(string)));
                    }
                    else
                    {
                        baxaIncludeLipid = (string)(WConfigurationController.LoadASetting(_siteID, "D|PN", "BAXA", "AdultSeparate", "?", false, typeof(string)));
                    }
                }
                else
                {
                    if (combined)
                    {
                        baxaIncludeLipid = (string)(WConfigurationController.LoadASetting(_siteID, "D|PN", "BAXA", "PaedCombined", "?", false, typeof(string)));
                    }
                    else
                    {
                        baxaIncludeLipid = (string)(WConfigurationController.LoadASetting(_siteID, "D|PN", "BAXA", "PaedSeparate", "?", false, typeof(string)));
                    }
                }
                if (baxaIncludeLipid.Contains("?"))
                {
                    rowBaxaLipid.Visible = true;
                    if (baxaIncludeLipid.Contains("Y"))
                    {
                        chkBaxaIncludeLipid.Checked = true;
                    }
                }
                else
                {
                    rowBaxaLipid.Visible = false;
                }
            }
            else
            {
                rowBaxaCompounder.Visible = false;
                rowBaxaLipid.Visible = false;
            }
            
            rntxtDays.Text = PNSettings.PNSupplyRequest.NumberOfDaysRequired;   // 21Oct15 XN 77772

            if (pnSupplierRequest.Any())
            {
                // Disable all validators to prevent them from firing if view data is slightly out
                IEnumerable<Control> allControlsOnForm = this.Controls.OfType<Control>().Desendants(c => c.Controls.OfType<Control>());
                allControlsOnForm.OfType<BaseValidator>().ToList().ForEach(v => v.Enabled = false);

                //Ensure dates allow max range
                foreach (RadDatePicker d in allControlsOnForm.OfType<RadDatePicker>())
                {
                    d.MinDate = DateTime.MinValue;
                    d.MaxDate = DateTime.MaxValue;
                }

                PNSupplyRequestRow row = pnSupplierRequest[0];
                rtxtBatchNumber.Text                                        = row.BatchNumber;
                rtxtBatchNumber.ReadOnly                                    = true;
                rdpAdminStart.SelectedDate                                  = row.AdminStartDate;
                rdpAdminStart.DateInput.ReadOnly                            = true;
                rdpAdminStart.DatePopupButton.Visible                       = false;
                rdpPreparationDate.SelectedDate                             = row.PreperationDate;
                rdpPreparationDate.DateInput.ReadOnly                       = true;
                rdpPreparationDate.DatePopupButton.Visible                  = false;
                rnAqueousCombinedExpiryDays.Value                           = row.ExpiryDaysAqueousCombined;
                rnAqueousCombinedExpiryDays.ReadOnly                        = true;
                rnLipidExpiryDays.Value                                     = row.ExpiryDaysLipid;
                rnLipidExpiryDays.ReadOnly                                  = true;
                rntxtAqueousCombinedLabelQty.Value                          = row.NumberOfLabelsAminoCombined;
                rntxtAqueousCombinedLabelQty.ReadOnly                       = true;
                rntxtLipidLabelQty.Value                                    = row.NumberOfLabelsLipid;
                rntxtLipidLabelQty.ReadOnly                                 = true;
                rntxtDays.Value                                             = row.DaysRequested;
                rntxtDays.ReadOnly                                          = true;
                chkBaxaCompounder.Checked                                   = row.BaxaCompounder ?? false;
                chkBaxaCompounder.Enabled                                   = false;
                chkBaxaIncludeLipid.Checked                                 = row.BaxaIncludeLipid ?? false;
                chkBaxaIncludeLipid.Enabled                                 = false;
                btnCacnel.Visible                                           = false;
                lblCancelled.Visible                                        = row.Cancelled;
            }

            //Load patient details
            using (Patient patient = new Patient())
            {
                
                patient.LoadByEntityID(Episode.GetEntityID(_episodeID));
                lblName.Text = patient[0].Description;

                // Hong Kong specific mode to get and display patient Chinese name 25Sep15 XN 77780 
                if (Database.IfTableExists("EntityExtraInfo"))
                {
                    string localName = Database.ExecuteSQLScalar<string>("SELECT ChineseName FROM EntityExtraInfo WHERE EntityID={0}", patient[0].EntityID);
                    if (!string.IsNullOrEmpty(localName))
                    {
                        lblName.Text += " " + localName;
                    }
                }

                if (patient[0].DOB.HasValue)
                {
                    DateTime markerDate = DateTime.Today;
                    DateTime dob = (DateTime)patient[0].DOB;
                    int oldMonth = markerDate.Month;
                    while (oldMonth == markerDate.Month)
                    {
                        dob = dob.AddDays(-1);
                        markerDate = markerDate.AddDays(-1);
                    }
                    
                    int years = 0;
                    while (markerDate.CompareTo(dob) >= 0)
                    {
                        years++;
                        markerDate = markerDate.AddYears(-1);
                    }
                    markerDate = markerDate.AddYears(1);
                    years--;
                    lblAge.Text = years.ToString() + " years"; // 28Mar12 AJK 30839 Changed capitalisation
                    if (!adult)
                    {
                        int months = 0;
                        while (markerDate.CompareTo(dob) >= 0)
                        {
                            markerDate = markerDate.AddDays(-1);
                            if ((markerDate.CompareTo(dob) >= 0) && (oldMonth != markerDate.Month))
                            {
                                months++;
                                oldMonth = markerDate.Month;
                            }
                        }
                        lblAge.Text += " " + months.ToString() + " months";
                    }
                }
                //string caseNoDisplayName = PharmacyCultureInfo.CaseNumberDisplayName; 05Jul13 XN  27252
                string caseNoDisplayName = PharmacyCultureInfo.CaseNumberDisplayName;
                lblCaseNoLabel.Text = caseNoDisplayName;
                lblCaseNo.Text = patient[0].GetCaseNumber();
                //string nhsNumberDisplayName = PharmacyCultureInfo.NHSNumberDisplayName; 05Jul13 XN  27252
                string nhsNumberDisplayName = PharmacyCultureInfo.NHSNumberDisplayName;
                if (!nhsNumberDisplayName.EqualsNoCase(caseNoDisplayName))
                {
                    lblNHSNumberLabel.Text = nhsNumberDisplayName;
                    lblNHSNumber.Text = patient[0].GetNHSNumber();
                }
                else
                {
                    lblNHSNumber.Visible = false;
                    lblNHSNumberLabel.Visible = false;
                }
            }
        }
        else
        {
            _episodeID = int.Parse(hdnEpisodeID.Value);
            _rxID = int.Parse(hdnRxID.Value);
            _48hr = bool.Parse(hf48hr.Value); // 28Mar12 30493 AJK Added
        }
    }


    protected void btnOK_Click(object sender, EventArgs e)
    {
        if (pnSupplierRequestID.HasValue)
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Saved", "window.close();", true);
            return;
        }

        if (Page.IsValid)
        {
            using (PNSupplyRequest db = new PNSupplyRequest())
            {
                db.Add();
                db[0].AdminStartDate = rdpAdminStart.SelectedDate;
                db[0].PreperationDate = rdpPreparationDate.SelectedDate.Value;
                db[0].BatchNumber = rtxtBatchNumber.Text.Trim();
                db[0].BaxaCompounder = rowBaxaCompounder.Visible && chkBaxaCompounder.Checked;
                db[0].BaxaIncludeLipid = rowBaxaLipid.Visible && chkBaxaIncludeLipid.Checked;
                db[0].CreatedDate = DateTime.Now;
                db[0].DaysRequested = (int)rntxtDays.Value;
                db[0].Description = "PN Supply Request " + rtxtBatchNumber.Text.Trim();
                db[0].EntityID = SessionInfo.EntityID;
                db[0].ExpiryDaysAqueousCombined = (int)rnAqueousCombinedExpiryDays.Value.Value;
                db[0].ExpiryDaysLipid           = rnLipidExpiryDays.Value.HasValue ? (int)rnLipidExpiryDays.Value.Value : (int?)null;
                db[0].IsVirtualProduct = false;
                db[0].NumberOfLabelsAminoCombined = (int)rntxtAqueousCombinedLabelQty.Value;
                db[0].NumberOfLabelsLipid = rowLipidLabels.Visible ? (int)rntxtLipidLabelQty.Value : (int?)null;
                db[0].PackageID_Quantity = null;
                db[0].ProductID_Mapped = 0;
                using (PNPrescrtiption rx = new PNPrescrtiption())
                {
                    rx.LoadByRequestID(_rxID);
                    if (rx[0].Supply48Hours)
                    {
                        db[0].QuantityRequested = (int)rntxtDays.Value / 2;
                    }
                    else
                    {
                        db[0].QuantityRequested = (int)rntxtDays.Value;
                    }
                }
                db[0].RequestDate = rdpAdminStart.SelectedDate.HasValue ? rdpAdminStart.SelectedDate.Value : DateTime.Now;
                db[0].RequestID_Parent = _regimenID.Value;
                db[0].RequestTypeID = ICWTypes.GetTypeByDescription(ICWType.Request, "Supply Request").Value.ID;
                db[0].ScheduleID = 0;
                db[0].SupplyRequestTypeID = ICWTypes.GetTypeByDescription(ICWType.SupplyRequest, "ParenteralNutrition").Value.ID;
                db[0].TableID = (int)ICWTypes.GetTypeByDescription(ICWType.Request, "Supply Request").Value.TableID;
                db[0].UnitID_Quantity = null;
                db[0].EntityID_Owner = SessionInfo.EntityID;
                db[0].EpisodeID = _episodeID;
                db[0].OrderTemplateID = 0;
                db.Save();
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Saved", "window.returnValue=" + db[0].RequestID.ToString() + "; window.close();", true);
            }
        }
    }

    protected void valBatchNumber_ServerValidate(object source, ServerValidateEventArgs args)
    {
        if (rtxtBatchNumber.Text.Trim() == "")
        {
            valBatchNumber.ErrorMessage = "Required";
            args.IsValid = false;
        }
        else if (rtxtBatchNumber.Text.Trim().Length < 7)
        {
            valBatchNumber.ErrorMessage = "7 character minimum";
            args.IsValid = false;
        }
        else
        {
            args.IsValid = true;
        }
    }
    
    protected void valPreparationDate_ServerValidate(object source, ServerValidateEventArgs args)
    {
        args.IsValid = rdpPreparationDate.SelectedDate.HasValue;
    }

    protected void valPreparationDateRange_ServerValidate(object source, ServerValidateEventArgs args)
    {
        if (rdpAdminStart.SelectedDate.HasValue && rdpPreparationDate.SelectedDate.HasValue && rdpPreparationDate.SelectedDate > rdpAdminStart.SelectedDate)
            args.IsValid = false;
    }

    protected void valAqueousCombinedExpiry_ServerValidate(object source, ServerValidateEventArgs args)
    {
        if (!rnAqueousCombinedExpiryDays.Value.HasValue || rnAqueousCombinedExpiryDays.Value == 0) // 28Mar12 AJK 30839 Added check for 0
        {
            args.IsValid = false;
            valAqueousCombinedExpiry.ErrorMessage = "Required"; // 28Mar12 30669 AJK Set error message programmatically
        }
        else
        {
            if (rnAqueousCombinedExpiryDays.Value > 200) // If days exceeds max of 200
            {
                args.IsValid = false;
                valAqueousCombinedExpiry.ErrorMessage = "Exceeds maximum"; // 28Mar12 30669 AJK Set error message programmatically
            }
            else
            {
                args.IsValid = true;
            }
        }
    }
    
    protected void valAqueousCombinedExpiryRange_ServerValidate(object source, ServerValidateEventArgs args)
    {
        if (rdpAdminStart.SelectedDate.HasValue && rnAqueousCombinedExpiryDays.Value.HasValue && rdpPreparationDate.SelectedDate.HasValue &&
            rdpAdminStart.SelectedDate > rdpPreparationDate.SelectedDate.Value.AddDays(rnAqueousCombinedExpiryDays.Value.Value))
            args.IsValid = false;
    }

    protected void valLipidExpiry_ServerValidate(object source, ServerValidateEventArgs args)
    {
        if (!rnLipidExpiryDays.Value.HasValue || rnLipidExpiryDays.Value == 0) // 28Mar12 AJK 30839 Added check for 0
        {
            args.IsValid = false;
            valLipidExpiry.ErrorMessage = "Required"; // 28Mar12 30669 AJK Set error message programmatically
        }
        else
        {
            if (rnLipidExpiryDays.Value > 200) // If days exceeds max of 200
            {
                args.IsValid = false;
                valLipidExpiry.ErrorMessage = "Exceeds maximum"; // 28Mar12 30669 AJK Set error message programmatically
            }
            else
            {
                args.IsValid = true;
            }
        }
    }
    
    protected void valLipidExpiryRange_ServerValidate(object source, ServerValidateEventArgs args)
    {
        if (rdpAdminStart.SelectedDate.HasValue && rnLipidExpiryDays.Value.HasValue && rdpPreparationDate.SelectedDate.HasValue && 
            rdpAdminStart.SelectedDate > rdpPreparationDate.SelectedDate.Value.AddDays(rnLipidExpiryDays.Value.Value))
            args.IsValid = false;
    }

    protected void valAminoCombinedQuantity_ServerValidate(object source, ServerValidateEventArgs args)
    {
        //if (!rntxtAqueousCombinedLabelQty.Value.HasValue || rntxtAqueousCombinedLabelQty.Value == 0) // 28Mar12 AJK 30839 Added check for 0
        if (!rntxtAqueousCombinedLabelQty.Value.HasValue) // 22Jan14 XN 82490 Allowed 0 labels
        {
            args.IsValid = false;
            valAminoCombinedQuantity.ErrorMessage = "Required"; // 28Mar12 30669 AJK Set error message programmatically
        }
        else
        {
            if (rntxtAqueousCombinedLabelQty.Value > 4) // If days exceeds max of 4
            {
                args.IsValid = false;
                valAminoCombinedQuantity.ErrorMessage = "Exceeds maximum"; // 28Mar12 30669 AJK Set error message programmatically
            }
            else
            {
                args.IsValid = true;
            }
        }
    }
    
    protected void valLipidQuantity_ServerValidate(object source, ServerValidateEventArgs args)
    {
        //if (!rntxtLipidLabelQty.Value.HasValue || rntxtLipidLabelQty.Value == 0) // 28Mar12 AJK 30839 Added check for 0
        if (!rntxtLipidLabelQty.Value.HasValue) // 22Jan14 XN 82490 Allowed 0 labels
        {
            args.IsValid = false;
            valLipidQuantity.ErrorMessage = "Required"; // 28Mar12 30669 AJK Set error message programmatically
        }
        else
        {
            if (rntxtLipidLabelQty.Value > 4) // If days exceeds max of 4
            {
                args.IsValid = false;
                valLipidQuantity.ErrorMessage = "Exceeds maximum"; // 28Mar12 30669 AJK Set error message programmatically
            }
            else
            {
                args.IsValid = true;
            }
        }
    }
    
    protected void valDays_ServerValidate(object source, ServerValidateEventArgs args)
    {
        if (!rntxtDays.Value.HasValue || rntxtDays.Value == 0) // 28Mar12 AJK 30839 Added check for 0
        {
            args.IsValid = false;
            valDays.ErrorMessage = "Required"; // 28Mar12 30669 AJK Set error message programmatically
        }
        else
        {
            if (rntxtDays.Value > 31) // If days exceeds max of 31
            {
                args.IsValid = false;
                valDays.ErrorMessage = "Exceeds maximum"; // 28Mar12 30669 AJK Set error message programmatically
            }
            else
            {
                if (_48hr && rntxtDays.Value % 2 > 0) // Odd number and 48hr bag
                {
                    args.IsValid = false;
                    valDays.ErrorMessage = "Number of days must be even for 48 hour bags"; // 28Mar12 30669 AJK Set error message programmatically
                }
                else
                {
                    args.IsValid = true;
                }
            }
        }
    }

}
