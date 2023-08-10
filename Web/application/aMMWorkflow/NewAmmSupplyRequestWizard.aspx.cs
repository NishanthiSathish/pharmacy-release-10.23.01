// -----------------------------------------------------------------------
// <copyright file="NewAmmSupplyRequestWizard.aspx.cs" company="Ascribe">
//      Copyright Ascribe Ltd  
// </copyright>
// <summary>
// Wizard for a new amm supply request 
//
// Will as user to
// 1. Select manufacturing drug
// 2. Ask user for the volume information
// 3. Ask user to enter the number of doses
// 4. Ask user to enter the number of syringes
//
// Parameters for the url are
// SessionID        - session ID
// SiteId           - Site ID
// RequestID_Parent - Request ID of the prescription
//
// Modification History:
// 18Jun15 XN Created 39882
// 15Aug16 XN 159843 Fixes
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.manufacturinglayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

using _Shared;

public partial class application_Manufacturing_NewAmmSupplyRequestWizard : System.Web.UI.Page
{
    #region Data Types
    /// <summary>List of steps in the wizard</summary>
    protected enum WizardSteps
    {
        /// <summary>Select drug to use</summary>
        FindDrug,

        /// <summary>Select volume to use, number of doses</summary>
        SelectDetails,

        /// <summary>Select syringe fill type</summary>
        SelectSyringeFullType,
    }
    #endregion

    #region Member Variables
    /// <summary>Parent prescription</summary>
    protected int requestIdParent;
    
    /// <summary>
    /// Selected product from find rug screen
    /// Cached as used a lot
    /// Should not call directly instead use GetFindDrugProduct
    /// </summary>
    private WProductRow selectedProduct = null;
    #endregion

    #region Properties
    /// <summary>Current step in the wizard</summary>
    protected WizardSteps CurrentStep { get { return (WizardSteps)Enum.Parse(typeof(WizardSteps), hfCurrentStep.Value); } }
    #endregion

    #region Event Handlers
    /// <summary>Called on paged load</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">Event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        this.requestIdParent = ConvertExtensions.ChangeType<int>(this.Request["RequestID_Parent"]);
       

        if (this.IsPostBack)
        {
            this.selectedProduct = string.IsNullOrEmpty(hfNSVCode.Value) ? null : WProduct.GetByProductAndSiteID(hfNSVCode.Value, SessionInfo.SiteID);
        }
        else
        {
            // Set patient details
            this.patientBanner.Initalise(EpisodeOrder.GetEpisodeIdByRequestId(this.requestIdParent));

            // Set prescription details
            PrescriptionRow prescription = Prescription.GetByRequestID(this.requestIdParent);
            this.lbPrescription.Text = prescription.Description;
            if (prescription.Dose == null)
                this.lbDose.Text = "None";
            else if (prescription.UnitID_Dose == null)
                this.lbDose.Text = prescription.Dose.ToString("0.##");
            else
                this.lbDose.Text = prescription.Dose.ToString("0.##") + " " + Unit.GetByUnitID(prescription.UnitID_Dose.Value);

            //// Validate the prescription
            //var errorWarningList = aMMProcessor.ValidatePrescription(Prescription.GetByRequestID(this.requestIdParent));
            //if (errorWarningList.Any())
            //{
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", string.Format("alert(\"{0}\"); window.close();", errorWarningList[0].Message), true);
            //}

            // Start the wizard
            this.PopulateFindDrug();
            this.SetStep(WizardSteps.FindDrug);
        }
    }

    //Default BatchNumber Field set to false
    public static bool EnableBatchNumber { get
             { return WConfiguration.Load<bool>(SessionInfo.SiteID, "D|BATCHNO", "SupplyRequest", "DisplayBatchNumber", false, false); }
    }
    

    /// <summary>
    /// Called when next button is clicked
    /// Validates current stage in wizard, then moves to next stage is wizard
    /// </summary>
    protected void btnNext_OnClick(object sender, EventArgs e)
    {
        // Clear existing errors
        errorMessage.Text           = "&nbsp;";
        errorMsgNumberOfDoses.Text  = "&nbsp;";
        errorMsgEpisodeTypes.Text   = "&nbsp;";
        errorMsgBatchNumber.Text    = "&nbsp;";
      
        //Display BatchNumber Check 
        if ((btnNext.Text != "Finish") && EnableBatchNumber)
        {
            DisplayBatchNumber.Visible = true;            
        }

        // Validate current wizard step
        bool valid = true;
        switch(this.CurrentStep)
        {
        case WizardSteps.FindDrug:              valid = this.ValidateFindDrug();                break;
        case WizardSteps.SelectDetails:         valid = this.ValidateDetails();                 break;
        case WizardSteps.SelectSyringeFullType: valid = this.ValidateSelectSyringeFillType();   break;
        }

        // If valid move to next stage in wizard
        if (valid)
        {
            var drug = this.GetFindDrugProduct();
            
            switch (this.CurrentStep)
            {
            case WizardSteps.FindDrug:
                this.lbPhamacyProductDescription.Visible = true;
                this.lbPhamacyProduct.Text = this.GetFindDrugProduct().ToString();
                this.PopulateDetails();
                this.SetStep(WizardSteps.SelectDetails);
                                
                // If not using multiple syringes then set finish button
                var prescription = Prescription.GetByRequestID(this.requestIdParent);
                var drugDose = prescription.Dose ?? drug.DosesPerIssueUnit; // Use estimated volume (as don't have user entered volume)
                if (!drug.IVContainer.EqualsNoCaseTrimEnd("S") || aMMProcessor.CalculateNumberOfContainers(drugDose ?? 0, drug) <= 1)
                {
                    btnNext.Text = "Finish";
                }
                break;        

            case WizardSteps.SelectDetails:
                {
                if (aMMProcessor.CalculateNumberOfContainers(this.GetSelectVolume(), drug) > 1)
                {
                    // If using multiple syringes then go to syringe fill type button
                    this.PopulateSelectSyringeFillType();
                    this.SetStep(WizardSteps.SelectSyringeFullType);
                    btnNext.Text = "Finish";
                }
                else
                {
                    // Not using multiple syringes so save
                    this.Save();
                }
                }
                break;

            case WizardSteps.SelectSyringeFullType:
                this.Save();
                break;        
            }
        }
    }    
    #endregion

    #region Find Drug Page
    /// <summary>Initialise the find drug page</summary>
    private void PopulateFindDrug()
    {
        hfNSVCode.Value = string.Empty;
    }

    /// <summary>
    /// Validates the find drug page
    /// 1. Checks drug has been selected
    /// 2. Check that the drug is valid for manufacturing
    /// </summary>
    /// <returns>If validation passed</returns>
    private bool ValidateFindDrug()
    {
        // Check drug is selected
        if (string.IsNullOrEmpty(hfNSVCode.Value))
        {
            errorMessage.Text = "Select a product from the list";
            return false;
        }
        
        // Validate the drug selection
        var errors = aMMProcessor.ValidateDrug(Prescription.GetByRequestID(this.requestIdParent), this.GetFindDrugProduct());
        if (errors.Any(e => e.Error))   // Check for error
        {
            errorMessage.Text = errors.First(e => e.Error).Message;
            return false;
        }
        else if (hfFindDrugConfirmWarnings.Value != "1" && errors.Any(e => !e.Error)) // Check for warning
        {            
            string script = string.Format("confirmEnh(\"{0}<br />Do you wish to create a new manufacturing request?\", true, function() {{ $('#hfFindDrugConfirmWarnings').val('1'); $('#btnNext').click(); }}, undefined, '450px')", errors.ToHtml());
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Warnings", script, true);
            return false;
        }

        return true;
    }

    /// <summary>Returns the selected formula from find drug screen</summary>
    /// <returns>Selected formula</returns>
    private WFormulaRow GetFindDrugFormula()
    {
        return WFormula.GetByNSVCodeSiteAndApproved(hfNSVCode.Value, SessionInfo.SiteID);
    }

    /// <summary>Returns the selected product from find drug screen</summary>
    /// <returns>Selected product</returns>
    private WProductRow GetFindDrugProduct()
    {
        return this.selectedProduct;
    }
    #endregion

    #region Select Volume Page
    /// <summary>
    /// Sets up episode select details (might be hidden)
    /// Initialise the select volume control, and number of doses
    /// </summary>
    private void PopulateDetails()
    {
        var episode = Episode.GetByEpisodeID(EpisodeOrder.GetEpisodeIdByRequestId(this.requestIdParent));

        // Initialise number of doses
        tbNumberOfDoses.Text = aMMSetting.NewDrugWizard.DefaultNumberOfDoses;
        tbNumberOfDoses.Attributes.Add("onkeydown", "if (event.keyCode==13) { $('#btnNext').focus(); $('#btnNext').click(); }");
        ScriptManager.RegisterStartupScript(this, this.GetType(), "focus", "var tb = $('input[id$=tbNumberOfDoses]'); tb.focus(); tb.select();", true);

        // Initialise volume control
        volumeCalculation.Initalise(Prescription.GetByRequestID(this.requestIdParent), this.GetFindDrugProduct(), this.GetFindDrugFormula());

        lblEpisodeMsg.Text = episode.EpisodeType == EpisodeType.LifetimeEpisode ? "Currently using the Lifetime Episode" : "Invalid episode type: " + episode.EpisodeTypeStr;

        // Populate the list with the episode types
        lbEpisodeTypes.Items.Add(new System.Web.UI.WebControls.ListItem() { Text="In-patient",  Value=EpisodeType.InPatient.ToString() });
        lbEpisodeTypes.Items.Add(new System.Web.UI.WebControls.ListItem() { Text="Out-patient", Value=EpisodeType.OutPatient.ToString()});
        lbEpisodeTypes.Items.Add(new System.Web.UI.WebControls.ListItem() { Text="Discharge",   Value=EpisodeType.Discharge.ToString() });
        lbEpisodeTypes.Items.Add(new System.Web.UI.WebControls.ListItem() { Text="Leave",       Value=EpisodeType.Leave.ToString()     });
        lbEpisodeTypes.Focus();
        
        // Checks if the users current episode exists in the list, in which case auto select
        lbEpisodeTypes.SelectedIndex = EnumExtensions.EnumIndexInListView(lbEpisodeTypes.Items, episode.EpisodeType);
        if (lbEpisodeTypes.SelectedIndex == -1)
            lbEpisodeTypes.SelectedIndex = 0;
        else
            pnSelectDetails.Visible = false;
    }

    /// <summary>Validates the details page</summary>
    /// <returns>If validation passed</returns>
    private bool ValidateDetails()
    {
        string error = string.Empty;
        
        // Validates the number of doses
        if (!Validation.ValidateText(this.tbNumberOfDoses, "Number of Doses", typeof(int), true, 1, double.MaxValue, out error))
        {
            errorMsgNumberOfDoses.Text = error;
            return false;   
        }

         // Validates the BatchNumber
        if (((this.DisplayBatchNumber.Visible == true) && !Validation.ValidateBatchNumber(this.tbBatchNumber, "Batch Number", true, out error)))  
        {
             errorMsgBatchNumber.Text = error;
             return false;
        }

        // Validate the volume calculation
        if (!volumeCalculation.Validate())
        {
            return false;
        }

        // If container is a syringe check the volume will not require, more than maximum number of syringes
        if (aMMProcessor.CalculateNumberOfContainers(this.GetSelectVolume(), this.GetFindDrugProduct()) >= aMMSetting.NewDrugWizard.MaxNumberOfSyringes)
        {
            string msg = string.Format("This volume requires more than {0} syringes.<br />Select a different volume, or a more appropriate method", aMMSetting.NewDrugWizard.MaxNumberOfSyringes - 1);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Error", "alertEnh('" + msg + "', undefined, '400px');", true);    
            return false;
        }

        // Validate episode types
        if (this.lbEpisodeTypes.SelectedIndex == -1)
        {
            this.errorMsgEpisodeTypes.Text = "Select an episode";
            return false;
        }

        return true;
    }

    /// <summary>Get selected episode</summary>
    /// <returns>Selected episode</returns>
    private EpisodeType GetSelectedEpisode()
    {
        return EnumExtensions.ListItemValueToEnum<EpisodeType>(this.lbEpisodeTypes.SelectedValue);
    }

    /// <summary>Gets the dose value</summary>
    /// <returns>Dose value</returns>
    private double GetDose()
    {
        return volumeCalculation.Dose;
    }

    private string GetDoseUnitString()
    {
        return volumeCalculation.DoseUnitString;   
    }

    /// <summary>Get the selected volume type</summary>
    /// <returns>volume type</returns>
    private aMMVolumeType GetSelectVolumeType()
    {
        return volumeCalculation.VolumeType;
    }
    
    /// <summary>Get the selected volume</summary>
    /// <returns>selected volume</returns>
    private double GetSelectVolume()
    {
        return volumeCalculation.VolumeOfInfusionInmL;
    }

    /// <summary>Return number of doses</summary>
    /// <returns>Number of doses</returns>
    private int GetNumberOfDoses()
    {
        return int.Parse(this.tbNumberOfDoses.Text);
    }
    #endregion

    #region Select Container
    private void PopulateSelectContainer(WFormulaRow formula)
    {
    }

    private bool ValidateSelectContainer()
    {
        return true;
    }

    private string GetSelectContainer()
    {
        return string.Empty;
    }
    #endregion

    #region Select Syringe Fill Type
    /// <summary>Populates the select syringe fill type</summary>
    private void PopulateSelectSyringeFillType()
    {
        WProductRow drug = this.GetFindDrugProduct();
        syringeManager.Initalise(this.GetDose(), this.GetDoseUnitString(), this.GetSelectVolume(), this.GetFindDrugProduct());
    }

    /// <summary>Validate the syringe fill type</summary>
    /// <returns>Returns the syringe fill type</returns>
    private bool ValidateSelectSyringeFillType()
    {
        return syringeManager.Validate();
    }

    /// <summary>Returns the selected syringe fill type</summary>
    /// <returns>Syringe fill type</returns>
    private aMMSyringeFillType GetSelectSyringeFillType()
    {
        var drug = this.GetFindDrugProduct();
        if (!drug.IVContainer.EqualsNoCaseTrimEnd("S"))
        {
            return aMMSyringeFillType.None;
        }
        
        if (aMMProcessor.CalculateNumberOfContainers(this.GetSelectVolume(), drug) == 1)
        {
            return aMMSyringeFillType.Single;
        }

        return syringeManager.Selected;
    }
    #endregion

    #region Web Method
    /// <summary>Called to update the selected volume calculation page when then user changes the volume</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteID">Site ID</param>
    /// <param name="dose">drug dose</param>
    /// <param name="volumeType">Selected volume type</param>
    /// <param name="fixedVolumeInmL">volume in ml</param>
    /// <param name="NSVCode">selected drug from find drug</param>
    /// <returns>aMM volume calculation results</returns>
    [WebMethod]
    public static aMMVolumeCalulcationResults UpdateCalculation(int sessionID, int siteID, double dose, aMMVolumeType volumeType, double? fixedVolumeInmL, string NSVCode)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionID, siteID);

        // Select product
        WProductRow product = WProduct.GetByProductAndSiteID(NSVCode, siteID);
        
        // Get results
        aMMVolumeCalulcationResults result;
        if (fixedVolumeInmL != null)
        {
            return aMMProcessor.CalculateVolume(dose, volumeType, fixedVolumeInmL.Value, product);
        }
        else
        {
            result = new aMMVolumeCalulcationResults { Error = "Enter valid fixed volume" };
        }

        return result;    
    }
    #endregion

    #region Helper Methods
    /// <summary>
    /// Set the next step the wizard is moving to
    /// Also set the title prefix for the next step (depends on step type)
    /// </summary>
    /// <param name="nextStep">Step to move to</param>
    private void SetStep(WizardSteps nextStep)
    {
        switch (nextStep)
        {
        case WizardSteps.FindDrug:              multiView.SetActiveView(vFindDrug             ); break;
        case WizardSteps.SelectDetails:         multiView.SetActiveView(vSelectDetails        ); break;
        case WizardSteps.SelectSyringeFullType: multiView.SetActiveView(vSelectSyringeFillType); break;
        }

        // Save step
        hfCurrentStep.Value = nextStep.ToString();
    }

    /// <summary>Save the sites to disk</summary>
    private void Save()
    {
        // Get details
        WFormulaRow formula = this.GetFindDrugFormula();
        WProductRow product = this.GetFindDrugProduct();
        
        UnitRow unitQty = Unit.GetByAbbreviation("qty");
        if (unitQty == null)
        {
            throw new ApplicationException("Missing unit type 'qty' from the DB");
        }

        // Create supply request
        aMMSupplyRequest supplyRequest = new aMMSupplyRequest();
        var newRow = supplyRequest.Add();

        // Fill in details
        newRow.EpisodeID           = EpisodeOrder.GetEpisodeIdByRequestId(this.requestIdParent);

        //Display BatchNumber Check
        if ((this.DisplayBatchNumber.Visible == true) && (!string.IsNullOrEmpty(tbBatchNumber.Text)))
        {
            newRow.BatchNumber = tbBatchNumber.Text;
        }
        else
        {
            newRow.BatchNumber = PharmacyCounter.GetNextCountStr(SessionInfo.SiteID, "D|BNM.V75", "Manufacturing", "BatchNumber");
        }
        newRow.WFormulaID          = formula.WFormulaID;
        newRow.NSVCode             = formula.NSVCode;
        newRow.ProductID_Mapped    = product.ProductID ?? 0;
        newRow.RequestDate         = DateTime.Now;
        newRow.RequestID_Parent    = this.requestIdParent;
        newRow.VolumeType          = this.GetSelectVolumeType();
        newRow.VolumeOfInfusionInmL= this.GetSelectVolume();
        newRow.QuantityRequested   = this.GetNumberOfDoses();
        newRow.UnitID_Quantity     = unitQty.UnitID;
        newRow.Dose                = this.GetDose();
        newRow.UnitIdDose          = Unit.GetByAbbreviation(this.GetDoseUnitString()).UnitID;
        newRow.EpisodeType         = this.GetSelectedEpisode();
        newRow.PrescriptionNumber  = WFilePointer.Increment(SiteInfo.PatientDataSiteId(), "P|RXID.DAT");
        newRow.Description         = string.Format("{0} - {1} {2:0.####}mL", product.NSVCode,  product.ToString(), newRow.VolumeOfInfusionInmL);

        double dosemg, volumemL, finalDosemg, finalVolumemL;
        newRow.SyringeFillType  = this.GetSelectSyringeFillType();
        newRow.NumberOfSyringes = aMMProcessor.CalculateNumberOfContainers(newRow.VolumeOfInfusionInmL.Value, product);
        switch (newRow.SyringeFillType)
        {
        case aMMSyringeFillType.EvenSplit:
            aMMProcessor.CalculateSyringeEvenSplit(newRow.Dose, newRow.VolumeOfInfusionInmL.Value, out dosemg, out volumemL, product);
            finalDosemg   = dosemg;
            finalVolumemL = volumemL;
            break;
        case aMMSyringeFillType.FullAndPart:
            aMMProcessor.CalculateSyringeFullAndPart(newRow.Dose, newRow.VolumeOfInfusionInmL.Value, out dosemg, out volumemL, out finalDosemg, out finalVolumemL);
            break;
        default:
            dosemg   = finalDosemg   = newRow.Dose;
            volumemL = finalVolumemL = newRow.VolumeOfInfusionInmL.Value;
            break;
        }

        newRow.SyringeDosemg       = dosemg;
        newRow.SyringeVolumemL     = volumemL;
        newRow.SyringeFinalDosemg  = finalDosemg;
        newRow.SyringeFinalVolumemL= finalVolumemL;

        AMMStateChangeNote stateChangeNote = new AMMStateChangeNote();
        stateChangeNote.Add(null, aMMState.WaitingScheduling);

        using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.InheritTransaction))
        {
            supplyRequest.Save();

            stateChangeNote.Save();
            newRow.LinkNote(stateChangeNote[0].NoteID);
            trans.Commit();
        }

        // And close
        this.ClosePage(newRow.RequestID.ToString());
    }
    #endregion
}