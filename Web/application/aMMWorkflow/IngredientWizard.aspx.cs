// -----------------------------------------------------------------------
// <copyright file="IngredientWizard.aspx.cs" company="Emis Health">
//   Copyright (c) Emis Health plc. All rights reserved.
// </copyright>
// <summary>
//  Part of the Aseptic Manufacture Module allows adding ingredient to the 
//  supply request.
//
//  If required will ask the user to 
//      1. Select a product
//      2. Enter a quantity
//      3. Enter barcode, batch number, and expiry.
//
//  The flow of the wizard is not straightforward. If the ingredient has an nsvcode 
//  user will no need to select the product. If ingredient is fixed volume,
//  the wizard will skip enter quantity. Batch tracking is limited to depending 
//  on ingredient product settings. The quantity, and batch tracking sections 
//  are repeated for the currently selected ingredient until the required quantity 
//  is fulfilled.
//
//  Each ingredient is saved after the batch tracking stage. Any warnings about 
//  the quantity being issued, saved in the error section of the AMMSupplyRequestIngredient.ErrorMessage
//
//  The page expects the following URL parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - Site number
//  SiteId          
//  RequestID           - AMM Supply Request ID
// 
//  Modification History:
//  13Jul15 XN Created 39882
// </summary
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

using ascribe.pharmacy.manufacturinglayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

using Newtonsoft.Json;

public partial class application_aMMWorkflow_IngredientWizard : System.Web.UI.Page
{
    #region Data Types
    /// <summary>List of steps in the wizard</summary>
    protected enum WizardSteps
    {
        /// <summary>Select ingredient to use</summary>
        SelectIngredient,

        /// <summary>Enter quantity</summary>
        EnterQuantity,

        /// <summary>Batch Tracking</summary>
        BatchTracking
    }
    #endregion

    #region Member Variables
    /// <summary>AMM Processor</summary>
    private aMMProcessor processor;

    /// <summary>Steps so far for this ingredient</summary>
    private Stack<WizardSteps> steps = new Stack<WizardSteps>(); 
    #endregion

    #region Properties
    /// <summary>Current step in the wizard</summary>
    protected WizardSteps CurrentStep { get { return (WizardSteps)Enum.Parse(typeof(WizardSteps), hfCurrentStep.Value); } }

    /// <summary>Gets or sets the current ingredient index (in WFormula)</summary>
    protected int CurrentIngredientIndex
    {
        get { return hfCurrentIngredientIndex.Value<int>();      }
        set { hfCurrentIngredientIndex.Value = value.ToString(); }
    }
    
    /// <summary>Gets or sets a value indicating whether any changes have been saved so far</summary>
    protected bool IfSavedData
    {
        get { return this.hfIfSavedData.Value<bool>();     }
        set { this.hfIfSavedData.Value = value.ToString(); }
    }
    #endregion

    #region Event handlers
    /// <summary>Called on paged load</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">Event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        this.processor = aMMProcessor.Create(ConvertExtensions.ChangeType<int>(this.Request["RequestID"]));

        if (this.IsPostBack)
        {
            // read in list of steps
            this.steps.Clear();
            JsonConvert.DeserializeObject<WizardSteps[]>(hfSteps.Value).ToList().ForEach(this.steps.Push);            
        }
        else
        {
            // Set patient details
            this.patientBanner.Initalise(this.processor.SupplyRequest.EpisodeID);

            // Set prescription details
            var doseUnit = ascribe.pharmacy.icwdatalayer.Unit.GetByUnitID(this.processor.SupplyRequest.UnitIdDose);
            lbPhamacyProduct.Text= string.Format("{0} - {1}", this.processor.Product.NSVCode, this.processor.Product);
            lbBatchNumber.Text   = this.processor.SupplyRequest.BatchNumber;
            lbVolume.Text        = string.Format("{0} mL {1}", this.processor.SupplyRequest.VolumeOfInfusionInmL , this.processor.SupplyRequest.VolumeType);
            if (this.processor.SupplyRequest.QuantityRequested == 1)
                lbDose.Text =  string.Format("{0} {1}", this.processor.SupplyRequest.Dose, doseUnit);
            else
                lbDose.Text = string.Format("{0} x {1} {2}", this.processor.SupplyRequest.QuantityRequested, this.processor.SupplyRequest.Dose, doseUnit);
        
            // Start the wizard
            this.ResetNextIngredient();
            if (this.CurrentIngredientIndex == -1)
            {
                this.ClosePage(true.ToString());
            }
            else
            {
                this.btnNext_OnClick(this, null);
                this.ClearErrorMessages();
                this.steps.Push(this.CurrentStep);
            }                
        }
    }

    /// <summary>Pre render</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void Page_PreRender(object sender, EventArgs e)
    {
        // Store the new step
        this.hfSteps.Value  = JsonConvert.SerializeObject(this.steps.Reverse().ToArray());
        this.btnBack.Visible = this.steps.Count > 1;        
    }

    /// <summary>
    /// Called when next button is clicked
    /// Validates current stage in wizard, then moves to next stage is wizard
    /// </summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void btnNext_OnClick(object sender, EventArgs e)
    {
        // Clear existing errors
        this.ClearErrorMessages();

        // Validate current wizard step
        bool valid = true;
        switch(this.CurrentStep)
        {
        case WizardSteps.SelectIngredient: valid = this.ValidateSelectIngredient(); break;
        case WizardSteps.EnterQuantity:    valid = this.ValidateEnterQuantity();    break;
        case WizardSteps.BatchTracking:    valid = this.ValidateBatchTracking();    break;
        }

        // If valid move to next stage in wizard
        if (valid)
        {
            switch (this.CurrentStep)
            {
            case WizardSteps.SelectIngredient:
                this.PopulateEnterQuantity();
                this.SetStep(WizardSteps.EnterQuantity);

                // If selected ingredient is fixed volume then skip the amount to issue stage
                var ing = this.GetIngredient();
                if (ing != null && (ing.DosesPerIssueUnit ?? -1) > 0)
                {
                    // Removed setting the default issue value upon Andrew's and Nick's request 02Aug16 XN  159413
                    //var amountToIssue = this.processor.Formula.CalculateIngredientQty(this.CurrentIngredientIndex, this.processor.SupplyRequest.Dose, (double)this.processor.SupplyRequest.QuantityRequested, this.processor.Product) / (double)ing.DosesPerIssueUnit;
                    //tbAmountToIssue.Text = amountToIssue.ToString("0.####");
                    //this.btnNext_OnClick(this, null); 157212 1Jul16 XN
                }
                break;

            case WizardSteps.EnterQuantity:
                this.PopulateBatchTracking();
                this.SetStep(WizardSteps.BatchTracking);

                // Skip to next stage if no
                if (!ucBatchTracking.IfRequired)
                {
                    this.btnNext_OnClick(this, null);                    
                }
                break;

            case WizardSteps.BatchTracking:
                // Save current ingredients
                this.Save(this.GetAmountToIssue(), this.CurrentIngredientIndex, this.GetIngredient());

                // If finished issuing current ingredient then move to next (though might redo current if everything is not issued)
                this.ResetNextIngredient();
                if (this.CurrentIngredientIndex == -1)
                {
                    // Nothing left to select so close
                    this.ClosePage(this.IfSavedData.ToString());
                }
                else
                {
                    // Move to next stage
                    this.btnNext_OnClick(this, null);
                    this.ClearErrorMessages();
                }                
                break;
            }

            // If original method the store the current step
            if (sender != this)
            {
                this.steps.Push(this.CurrentStep);
            }
        }
    }

    /// <summary>
    /// Called when back button is clicked
    /// Move to the previous wizard step.
    /// </summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void btnBack_OnClick(object sender, EventArgs e)
    {
        // Clear existing errors
        this.ClearErrorMessages();

        this.steps.Pop();
        this.SetStep(this.steps.Peek());
        
        // Update page
        switch (this.CurrentStep)
        {
        case WizardSteps.BatchTracking:     this.PopulateBatchTracking();   break;
        case WizardSteps.EnterQuantity:     this.PopulateEnterQuantity();   break;
        case WizardSteps.SelectIngredient:  this.PopulateSelectIngredient();break;
        }
    }
    #endregion

    #region Select Ingredient Page
    /// <summary>Populate select ingredient page</summary>
    private void PopulateSelectIngredient()
    {
        hfSearchText.Value = this.processor.Formula.Code(this.CurrentIngredientIndex);
    }

    /// <summary>
    /// Validates the find ingredient page
    /// 1. Checks drug has been selected
    /// 2. Checks dosing units
    /// </summary>
    /// <returns>If validation passed</returns>
    private bool ValidateSelectIngredient()
    {
        string error;

        // Check drug is selected
        if (string.IsNullOrEmpty(this.hfNSVCode.Value))
        {
            errorMessage.Text = "Select a product from the list";
            return false;
        }

        // Check ingredient is in use
        var ingredient = this.GetIngredient();
        if (!ingredient.InUse)
        {
            errorMessage.Text = "Drug not in use";
            return false;
        }
        
        // Check ingredient has correct does per issue unit
        if (this.processor.Formula.IsDosingUnits && (ingredient.DosesPerIssueUnit ?? 0.0) < aMMProcessor.MinDose)
        {
            errorMessage.Text = "Doses per Issue contains invalid value.";
            return false;
        }

        // Test can calculate ingredient quantity for the product
        var supplyRequest = this.processor.SupplyRequest;
        if (this.processor.Formula.CalculateIngredientQty(this.CurrentIngredientIndex, supplyRequest.Dose, (double)supplyRequest.QuantityRequested.Value, this.processor.Product) == null)
        {
            errorMessage.Text = "Not valid for quantity calculation";
            return false;
        }

        return true;
    }
    
    /// <summary>Returns the selected ingredient from find drug screen</summary>
    /// <returns>Selected ingredient</returns>
    private WProductRow GetIngredient()
    {
        return this.processor.GetIngredientProduct(this.hfNSVCode.Value);
    }
    #endregion

    #region Enter Quantity Page
    /// <summary>Populate batch tracking stage</summary>
    private void PopulateEnterQuantity()
    {
        var ingIndex   = this.CurrentIngredientIndex;
        var ingredient = this.GetIngredient();

        // Calculate total amount issued for this ingredient (so far)
        var currentAmount = this.processor.SupplyRequestIngredients.Where(c => c.FormulaIndex == ingIndex).Sum(c => c.QtyInIssueUnits * this.processor.GetIngredientProduct(c.NSVCode).DosesPerIssueUnit);
        var totalToIssue  = this.processor.Formula.CalculateIngredientQty(ingIndex, this.processor.SupplyRequest.Dose, (double)this.processor.SupplyRequest.QuantityRequested, this.processor.Product);

        // Populate details
        hfEnterQuantityConfirm.Value = string.Empty;
        lbIngredient.Text    = ingredient.NSVCode + " - " + ingredient;
        lbTotalToIssue.Text  = totalToIssue.ToString("0.####") + " " + ingredient.DosingUnits;
        lbIssueUnits.Text    = ingredient.PrintformV;
        lbStillToIssue.Text  = (totalToIssue - currentAmount).ToString("0.####") + " " + ingredient.DosingUnits;

        tbAmountToIssue.Attributes.Add("onkeydown", "if (event.keyCode == 13) { $('#btnNext').click(); return false; }");
        tbAmountToIssue.Attributes.Add("onfocus",   "this.select();");  // 157212 1Jul16 XN

        ScriptManager.RegisterStartupScript(this, this.GetType(), "focus", "$('#tbAmountToIssue').focus();", true);
    }

    /// <summary>
    /// Validate the batch tracking stage
    /// 1. Check amount to issue is entered
    /// 2. Check stock level
    /// 3. Check entered quantity is valid (warning only)
    /// </summary>
    /// <returns>If valid</returns>
    private bool ValidateEnterQuantity()
    {
        bool valid = true;
        string error;

        var ingredient = this.GetIngredient();
        if (!Validation.ValidateText(tbAmountToIssue, string.Empty, typeof(double), true, 0.0001, 1000000, out error))
        {
            this.lbAmountToIssueError.Text = error;
            valid = false;
        }
        else if (!ingredient.ValidateStockLevel(this.GetAmountToIssue(), WTranslogType.Manufacturing, string.Empty, out error))
        {
            this.lbAmountToIssueError.Text = error;
            valid = false;
        }
        else if (string.IsNullOrEmpty(hfEnterQuantityConfirm.Value))
        {
            // Warn user if they accept then set hfBatchTrackingConfirm indicating user has agreed so this validation is not redone
            var warnings = ingredient.ValidateIssue(this.GetAmountToIssue(), "Issue qty");
            if (warnings.Any())
            {
                string script = string.Format("enterQuantityWarn(\"{0}<br />Do you want to continue?\", '{1}');", warnings.ToHtml().JavaStringEscape(), tbAmountToIssue.ClientID);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "warn", script, true);
                valid = false;
            }
        }

        return valid;
    }

    /// <summary>Gets the amount to issue value</summary>
    /// <returns>amount to issue</returns>
    private double GetAmountToIssue()
    {
        return double.Parse(this.tbAmountToIssue.Text);
    }
    #endregion

    #region Batch Tracking Page
    /// <summary>Populate the batch tracking control</summary>
    private void PopulateBatchTracking()
    {
        WProductRow ingredient = this.GetIngredient();
        ucBatchTracking.NSVCode           = ingredient.NSVCode;
        ucBatchTracking.BatchTracking     = ingredient.BatchTracking;
        ucBatchTracking.ShowExpiryDate    = aMMSetting.IngredientWizard.AlwaysAskExpiryDate;
        ucBatchTracking.ShowBatchTracking = aMMSetting.IngredientWizard.AlwaysAskBatchTracking;
        ucBatchTracking.Initalise();

        lbBatchTrackingProduct.Text = ingredient.NSVCode + " - " + ingredient;
    }
    
    /// <summary>Validates the batch tracking control</summary>
    /// <returns>Returns if batch data valid</returns>
    private bool ValidateBatchTracking()
    {
        if (!this.ucBatchTracking.IfRequired)
        {
            return true;
        }

        bool warnBarcode     = aMMSetting.IngredientWizard.WarnBarcodeError;
        bool warnBatchNumber = aMMSetting.IngredientWizard.WarnBatchNumber;
        bool warnExpiry      = aMMSetting.IngredientWizard.WarnExpiry;
        return ucBatchTracking.Validate(warnBarcode, warnBatchNumber, warnExpiry, this.GetAmountToIssue(), "$('#btnNext').click();");
    }

    /// <summary>Get batch number</summary>
    /// <returns>batch number</returns>
    private string GetBatchNumber()
    {
        return ucBatchTracking.BatchNumber;
    }

    /// <summary>Get expiry date</summary>
    /// <returns>expiry date</returns>
    private DateTime? GetExpiryDate()
    {
        return ucBatchTracking.ExpiryDate;
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
        case WizardSteps.SelectIngredient: multiView.SetActiveView(vSelectIngredient); break;
        case WizardSteps.EnterQuantity:    multiView.SetActiveView(vEnterQuantity   ); break;
        case WizardSteps.BatchTracking:    multiView.SetActiveView(vBatchTracking   ); break;
        }

        // Save step
        hfCurrentStep.Value = nextStep.ToString();
    }

    /// <summary>Save the ingredients</summary>
    /// <param name="qtyInIssueUnits">Quantity to issue</param>
    /// <param name="ingredeintIndex">WFormula ingredient index</param>
    /// <param name="ingredient">New ingredient</param>
    private void Save(double qtyInIssueUnits, int ingredeintIndex, WProductRow ingredient)
    {
        var newSupplyRequestIng                 = this.processor.SupplyRequestIngredients.Add();
        newSupplyRequestIng.RequestId           = this.processor.SupplyRequest.RequestID;
        newSupplyRequestIng.FormulaIndex        = ingredeintIndex;
        newSupplyRequestIng.NSVCode             = ingredient.NSVCode;
        newSupplyRequestIng.State               = aMMSupplyRequestIngredientState.Gathered;
        newSupplyRequestIng.QtyInIssueUnits     = qtyInIssueUnits;
        newSupplyRequestIng.AssembledByDate     = DateTime.Now;
        newSupplyRequestIng.AssembledByEntityId = SessionInfo.EntityID;
        newSupplyRequestIng.ErrorMessage        = ingredient.ValidateIssue(this.GetAmountToIssue(), string.Empty).Select(w => w.Message).ToCSVString(", ").SafeSubstring(0, aMMSupplyRequestIngredient.GetColumnInfo().ErrorMessageLength);
        newSupplyRequestIng.BatchNumber         = this.GetBatchNumber();
        newSupplyRequestIng.ExpiryDate          = this.GetExpiryDate();
        newSupplyRequestIng.SelfCheckReason     = string.Empty;

        this.processor.SupplyRequestIngredients.Save();
        //this.StillToIssue -= (newSupplyRequestIng.QtyInDoses * ingredient.DosesPerIssueUnit.Value);
        this.IfSavedData = true;

        this.ucBatchTracking.Clear();
    }

    /// <summary>Clear all error message fields</summary>
    private void ClearErrorMessages()
    {
        this.GetAllControlsByType<Label>().Where(c => c.CssClass.Contains("ErrorMessage")).ToList().ForEach(c => c.Text = "&nbsp;");
    }

    /// <summary>
    /// Sets up for the next ingredient
    /// Depends on ingredients assigned so far, and if total issued for ingredient is enough for the formula
    /// </summary>
    private void ResetNextIngredient()
    {
        // Get the next ingredient index
        int ingIndex = this.processor.FindNextUnselectedIngredient();

        // Reset steps
        this.steps.Clear();

        // Store values
        this.CurrentIngredientIndex = ingIndex; 
        if (ingIndex != -1)
        {
            var code = this.processor.Formula.Code(ingIndex);

            // clear all entered values
            hfNSVCode.Value = PatternMatch.Validate(code, PatternMatch.NSVCodePattern) ? code : string.Empty;
            tbAmountToIssue.Text = string.Empty;
            ucBatchTracking.Clear();

            // Populate ingredient stage
            this.PopulateSelectIngredient();
            this.SetStep(WizardSteps.SelectIngredient);
        }
    }
    #endregion
}