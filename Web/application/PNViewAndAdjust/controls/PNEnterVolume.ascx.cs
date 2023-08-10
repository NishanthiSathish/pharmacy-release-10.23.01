//===========================================================================
//
//					  	    PNEnterVolume.aspx.cs
//
//  Control used in the PN add product wizard to entry of volume, or ingredient value.
//
//  Depending on if page is used with AddProduct or SetVolumeOrCalrories wizard determines 
//  how contents of the page is validated.
//
//	Modification History:
//	15Nov11 XN  Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.icwdatalayer;
using System.Text;

public partial class application_PNViewAndAdjust_controls_PNEnterVolume : System.Web.UI.UserControl, IPNWizardCtrl
{
    protected void Page_Load(object sender, EventArgs e) { }

    /// <summary>Initalise control's for simple volume entry<summary>
    /// <param name="product">PN product</param>
    /// <param name="value">Value to set</param>
    /// <param name="mmolEntry">Entry type (only of text purposes)</param>
    public void Initalise(string caption, double? value)
    {        
        // Store relvent data in hidden fields
        hfWizardType.Value = "basic";
        
        // Populate caption and get default volume
        lbCaption.Text    = caption;
        lbValueError.Text = "&nbsp;";

        // Set value default value
        tbValue.Text = value.HasValue ? value.Value.ToPNString() : string.Empty;
        tbValue.Focus();

        if (!string.IsNullOrEmpty(tbValue.Text))
            tbOriginal.Text = string.Format(" (current value {0})", tbValue.Text);
    }

    /// <summary>Initalise control's for entry of value for an ingredient (for the add wizard)<summary>
    /// <param name="product">PN product</param>
    /// <param name="processor">PN processor</param>
    /// <param name="ingredient">Ingredient value to enter</param>
    /// <param name="mmolEntry">Entry type</param>
    public void Initalise(PNProductRow product, PNProcessor processor, PNIngredientRow ingredient, PNUtils.mmolEntryType mmolEntry, double dosingWeightInKg)
    {        
        double defaultValueTotal = 0.0;

        // Get the products value in the regimen (if it exists)
        PNRegimenItem existingItem = processor.RegimenItems.FindByPNCode(product.PNCode);

        // Store relvent data in hidden fields
        hfmmolEntryType.Value                   = mmolEntry.ToString();
        hfDosingWeightInKg.Value                = dosingWeightInKg.ToString();
        hfSelectedProductPNCode.Value           = product.PNCode;
        hfSelectedIngredient.Value              = ingredient.DBName;
        hfWizardType.Value                      = "addwizard";
        
        // Populate caption and get default volume
        if (ingredient.DBName == PNIngDBNames.Volume)
        {
            lbCaption.Text = string.Format("Enter volume required of {0} in {1}{2}", product, ingredient.GetUnit().Abbreviation, (mmolEntry == PNUtils.mmolEntryType.PerKg) ? "/kg" : string.Empty);
            defaultValueTotal = (existingItem == null) ? 0.0 : existingItem.VolumneInml;
        }
        else
        {
            if (mmolEntry == PNUtils.mmolEntryType.Total)
                lbCaption.Text = string.Format("Enter total {0} of {1} required<br />&nbsp;&nbsp;&nbsp;&nbsp;(by amending {2})", ingredient.GetUnit().Description, ingredient, product);
            else
                lbCaption.Text = string.Format("Enter {0}/kg of {1} required<br />&nbsp;&nbsp;&nbsp;&nbsp;(by amending {2})", ingredient.GetUnit().Description, ingredient, product);

            // calculate existing ingredient value in regimen if it exists
            double existingIngredientValue = 0.0;
            if (existingItem != null)
               existingIngredientValue = product.CalculateIngredientValue(ingredient.DBName, existingItem.VolumneInml);

            // Calculate total for the ingredeint, that is not provided by the selected product
            double totalForIngredient              = processor.CalculateTotals(new string[] { ingredient.DBName }).ElementAt(0);
            double totalNotProvidedByOtherProducts = totalForIngredient - existingIngredientValue;
    
            // Store the total not provided by other products for validation purposes
            hfTotalNotProvidedByOtherProducts.Value = totalNotProvidedByOtherProducts.ToString();

            defaultValueTotal = totalForIngredient;
        }

        lbValueError.Text = "&nbsp;";

        // Set value default value
        if (mmolEntry == PNUtils.mmolEntryType.PerKg)
            defaultValueTotal = defaultValueTotal  / dosingWeightInKg;
        tbValue.Text = defaultValueTotal.IsZero(2) ? string.Empty : defaultValueTotal.ToPNString();
        tbValue.Focus();

        if (!string.IsNullOrEmpty(tbValue.Text))
            tbOriginal.Text = string.Format(" (current value {0} {1}{2})", tbValue.Text, ingredient.GetUnit().Abbreviation, (mmolEntry == PNUtils.mmolEntryType.PerKg) ? "/kg" : string.Empty);
    }

    /// <summary>Initalise control's for entry of value (for the set volume or calories wizard)<summary>
    /// <param name="processor">PN processor</param>
    /// <param name="ingredient">Ingredient value to set</param>
    /// <param name="mmolEntry">Entry type</param>
    /// <param name="info">Regmimen info</param>
    public void Initalise(PNProcessor processor, PNIngredientRow ingredient, PNUtils.mmolEntryType mmolEntry, PNViewAndAdjustInfo info)
    {
        // Get list of all glucose items in regimen
        List<PNRegimenItem> itemsThatOnlyContainGlucose = processor.RegimenItems.FindByOnlyContainGlucose().ToList();
        
        // Add diluent item if present
        PNRegimenItem diluentItem = processor.RegimenItems.FindByPNCode(processor.DiluentPNCode);
        if (diluentItem != null)
            itemsThatOnlyContainGlucose.Add(diluentItem);

        // Calculte totals
        double totalGlucoseForGlucoseProduct    = itemsThatOnlyContainGlucose.Sum(i => i.GetProduct().CalculateIngredientValue(PNIngDBNames.Glucose, i.VolumneInml));
        double totalVolumeForGlucoseProductInml = itemsThatOnlyContainGlucose.Sum(i => i.GetProduct().CalculateIngredientValue(PNIngDBNames.Volume,  i.VolumneInml));
        double totalVolumeInml                  = processor.CalculateTotal(PNIngDBNames.Volume);
        double totalIng                         = processor.CalculateTotal(ingredient.DBName);

        // Store relvent data in hidden fields
        hfmmolEntryType.Value                   = mmolEntry.ToString();
        hfDosingWeightInKg.Value                = info.dosingWeightInKg.ToString();
        hfSelectedIngredient.Value              = ingredient.DBName;
        hfWizardType.Value                      = "setwizard";
        hfTotalGlucose.Value                    = totalGlucoseForGlucoseProduct.ToString();
        hfTotalGlucoseProductVolume.Value       = totalVolumeForGlucoseProductInml.ToString();
        hfTotalForIngredient.Value              = totalIng.ToString();

        // Build up caption (and get default value)
        StringBuilder caption = new StringBuilder();
        double? defaultValue;
        if (ingredient.DBName == PNIngDBNames.Glucose)
        {
            bool isCombined = processor.Regimen.IsCombined;
            defaultValue = processor.CalculateGlucosePercenrtage(isCombined ? PNProductType.Combined : PNProductType.Aqueous);
            //caption.AppendFormat("Glucose concentration of finished {0} infusion is {1} %", isCombined ? "aqueous " : string.Empty, defaultValue.Value.ToVDUIncludeZeroString()); TFS31255 2Apr12 XN fixed glucose by % message
            caption.AppendFormat("Glucose concentration of finished {0} infusion is {1} %", isCombined ? string.Empty : "aqueous ", defaultValue.Value.ToVDUIncludeZeroString());
            if (isCombined)
                caption.Append("<br />or higher depending upon the degree of dilution by lipid emulsion.");
            caption.Append("<br /><br />Enter concentration of glucose required as a percentage (w/v)");

            lbCaption.Text = caption.ToString();
            if (defaultValue.HasValue && !defaultValue.Value.IsZero())
                tbValue.Text = defaultValue.Value.ToPNString();

            if (!string.IsNullOrEmpty(tbValue.Text))
                tbOriginal.Text = string.Format(" (current value {0} %)", tbValue.Text);
        }
        else
        {
            caption.AppendFormat("Total {0} in feed = {1} {2}<br />", ingredient, totalIng.ToPNString(), ingredient.GetUnit().Abbreviation);
            caption.AppendFormat("{0} per kg        = {1} {2}/kg<br /><br />", ingredient, (totalIng / info.dosingWeightInKg).ToPNString(), ingredient.GetUnit().Abbreviation);
            if (mmolEntry == PNUtils.mmolEntryType.Total)
            {
                caption.AppendFormat("Enter total {0} required", ingredient);
                defaultValue = totalIng;
            }
            else
            {
                caption.AppendFormat("Enter {0} per kg required", ingredient);
                defaultValue = totalIng / info.dosingWeightInKg;
            }

            lbCaption.Text = caption.ToString();
            tbValue.Text   = defaultValue.Value.ToPNString();

            if (!string.IsNullOrEmpty(tbValue.Text))
                tbOriginal.Text = string.Format(" (current value {0} {1}{2})", tbValue.Text, ingredient.GetUnit().Description, (mmolEntry == PNUtils.mmolEntryType.PerKg) ? "/kg" : string.Empty);
        }
    }

    /// <summary>Initalise control's for entry of value (for the overage wizard)<summary>
    /// <param name="product">Selected overage product</param>
    /// <param name="processor">PN processor</param>
    public void Initalise(PNProductRow product, PNProcessor processor)
    {
        PNRegimenItem item = processor.RegimenItems.FindByPNCode(product.PNCode);

        hfWizardType.Value            = "overagewizard_containervolume";
        hfSelectedProductPNCode.Value = product.PNCode;

        StringBuilder caption = new StringBuilder();
        caption.AppendFormat("Product: {0} ({1} ml)<br /><br />", product, product.ContainerVolumeInml);
        caption.AppendFormat("Enter total volume (for {0}Hrs supply) of this product to be used in final regimen.<br />", processor.Regimen.Supply48Hours ? "48" : "24");
        caption.AppendFormat("This should be one or more whole containers and must be at least {0} ml.", item.VolumneInml.ToPNString());
        lbCaption.Text = caption.ToString();

        // If doing 48Hour bag double the volume
        double volumeInml = item.VolumneInml;
        if (processor.Regimen.Supply48Hours)
            volumeInml *= 2.0;

        // Determmine number of whole containers of product will be used
        double containers = volumeInml / product.ContainerVolumeInml;
        if (containers > Math.Floor(containers)) 
            containers++;

        // Convert to amount of product will be used
        tbValue.Text = (Math.Floor(containers) * product.ContainerVolumeInml).ToString();

        if (!string.IsNullOrEmpty(tbValue.Text))
            tbOriginal.Text = string.Format(" (current value {0} ml)", tbValue.Text);
    }

    /// <summary>Initalise control's for entry of final overage value (for the overage wizard)<summary>
    /// <param name="product">Selected overage product</param>
    /// <param name="overageInml">Calculated over volume to start with</param>
    /// <param name="processor">Regmimen info</param>
    public void Initalise(PNProductRow product, double overageInml, PNProcessor processor)
    {
        hfWizardType.Value            = "overagewizard_finalvalue";
        hfSelectedProductPNCode.Value = product.PNCode;
        string supplyPeriodHrs        = processor.Regimen.Supply48Hours ? "48" : "24";

        StringBuilder cpation = new StringBuilder();
        if (processor.Regimen.IsCombined)
            cpation.AppendFormat("Calculated combined overage in ml (for {0}Hrs supply) will be<br />", supplyPeriodHrs);
        else if (product.AqueousOrLipid == PNProductType.Aqueous)
            cpation.AppendFormat("Calculated aqueous overage in ml (for {0}Hrs supply) will be<br />", supplyPeriodHrs);
        else if (product.AqueousOrLipid == PNProductType.Lipid)
            cpation.AppendFormat("Calculated lipid overage in ml (for {0}Hrs supply) will be<br />", supplyPeriodHrs);
        cpation.Append("<br />");
        cpation.Append("Update value if needed:");

        lbCaption.Text = cpation.ToString();
        tbValue.Text   = overageInml.ToString();

        if (!string.IsNullOrEmpty(tbValue.Text))
            tbOriginal.Text = string.Format(" (current value {0} ml)", tbValue.Text);
    }

    /// <summary>Gets the value entered by user (as total calculated value if user entered per kg)</summary>
    public double GetTotalValue()
    {
        PNUtils.mmolEntryType mmolEntry = PNUtils.mmolEntryType.Total;
        if (!string.IsNullOrEmpty(hfmmolEntryType.Value))
            mmolEntry = (PNUtils.mmolEntryType)Enum.Parse(typeof(PNUtils.mmolEntryType), hfmmolEntryType.Value, true);

        double value = this.Value;
        double dosingWeightInKg = 0.0;
        double.TryParse(hfDosingWeightInKg.Value, out dosingWeightInKg);

        if (mmolEntry == PNUtils.mmolEntryType.PerKg)
            value *= dosingWeightInKg;

        return value;
    }

    /// <summary>
    /// Returns the total value when page is used as part of the set wizard 
    /// If ingredient was volume returns total volume
    /// If ingredient was calories or glucose returns total calories
    /// </summary>
    public double GetTotalValueForSetWizard(PNProcessor processor)
    {
        if (hfWizardType.Value != "setwizard")
            throw new ApplicationException("Only use GetTotalValueForSetWizard for set wizard.");

        if (hfSelectedIngredient.Value == PNIngDBNames.Volume)
            return this.GetTotalValue();
        else if (hfSelectedIngredient.Value == PNIngDBNames.Calories)
            return this.GetTotalValue();
        else if (hfSelectedIngredient.Value == PNIngDBNames.Glucose)
        {
            PNProductType type = processor.Regimen.IsCombined ? PNProductType.Combined : PNProductType.Aqueous;
            double? oldGlucoseCon = processor.CalculateGlucosePercenrtage(type);
            double  newGlucoseCon = this.GetTotalValue();
            double  oldVolume     = processor.RegimenItems.FindByAqueousOrLipid(type).CalculateTotal(PNIngDBNames.Volume);
            double  glucoseVal    = oldVolume * (newGlucoseCon - oldGlucoseCon.Value.To3SigFigish()) / 100.0;

            return processor.CalculateTotal(PNIngDBNames.Calories) + (glucoseVal * processor.kcalPerGramGlucose);
        }

        throw new ApplicationException("Invalid ingredient type only used for volume, calories, or glucose");
    }

    // Value entered by user
    public double Value { get { return double.Parse(tbValue.Text).To3SigFigish(); } }

    /// <summary>
    /// Returns required product volume in ml
    /// This is the value entered if user entered total volume, 
    /// else calculated value if user entered ingredient
    /// </summary>
    public double GetVolumeInml()
    {
        double value = GetTotalValue();

        if (hfSelectedIngredient.Value != PNIngDBNames.Volume)
        {
            value -= double.Parse(hfTotalNotProvidedByOtherProducts.Value);

            PNProductRow    product    = PNProduct.GetInstance   ().FindByPNCode (hfSelectedProductPNCode.Value);
            PNIngredientRow ingredient = PNIngredient.GetInstance().FindByDBName (hfSelectedIngredient.Value   );
            value = product.CalculateVolume(ingredient.DBName, value).Value;             
        }

        return value;
    }

    public string ErrorMessage
    {
        set { lbValueError.Text = value; }
    }

    #region IPNWizardCtrl Members
    public void Initalise()
    {
        lbCaption.Text                               = string.Empty;
 	    tbValue.Text                                 = string.Empty;
        tbOriginal.Text                              = string.Empty;
        lbValueError.Text                            = "&nbsp;";
        hfmmolEntryType.Value                        = PNUtils.mmolEntryType.Total.ToString();
        hfDosingWeightInKg.Value                     = string.Empty;
        hfSelectedProductPNCode.Value                = string.Empty;
        hfSelectedIngredient.Value                   = string.Empty;
        hfTotalNotProvidedByOtherProducts.Value      = string.Empty;
        hfWizardType.Value                           = string.Empty;
        hfTotalGlucose.Value                         = string.Empty;
        hfTotalGlucoseProductVolume.Value            = string.Empty;
        hfTotalForIngredient.Value                   = string.Empty;
    }

    public int? RequiredHeight { get { return null; } }

    public void Focus()
    {
        string script = string.Format("$('#{0}').focus(); $('#{0}')[0].select();", tbValue.ClientID);
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "PNEnterVolumeFocus", script, true);
    }

    public bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info) 
    {
        bool valid = false;

        // Validate depends on wizard type (which initialise method was called)
        switch (hfWizardType.Value)
        {
            case "basic":                           valid = ValidateForBasicEntry                  (regimenProcess, info); break;
            case "addwizard":                       valid = ValidateForAddWizard                   (regimenProcess, info); break;
            case "setwizard":                       valid = ValidateForSetWizard                   (regimenProcess, info); break;
            case "overagewizard_containervolume":   valid = ValidateForOverageWizardContainerVolume(regimenProcess, info); break;
            case "overagewizard_finalvalue":        valid = ValidateForOverageWizardFinalValue     (regimenProcess, info); break;
        }

        return valid;
    }
    #endregion

    #region Private Methods
    /// <summary>Validate method for simple entry</summary>
    /// <returns>If valide</returns>
    private bool ValidateForBasicEntry(PNProcessor regimenProcess, PNViewAndAdjustInfo info)
    {
        string error;
        if (!Validation.ValidateText(tbValue, string.Empty, typeof(double), true, 0.01, 9999, out error))
        {
            lbValueError.Text = error;
            return false;
        }

        return true;
    }

    /// <summary>Validate method for the add wizard</summary>
    /// <returns>If valid</returns>
    private bool ValidateForAddWizard(PNProcessor regimenProcess, PNViewAndAdjustInfo info)
    {
        string error;

        if (hfSelectedIngredient.Value == PNIngDBNames.Volume)
        {
            if (!Validation.ValidateText(tbValue, string.Empty, typeof(double), true, 0.01, 9999, out error))
            {
                lbValueError.Text = error;
                return false;
            }
        }
        else
        {
            // If user enters ingredient value 
            // ensure quantity entered is not less than, that already provided by the product (else get -ve volume)

            if (!Validation.ValidateText(tbValue, string.Empty, typeof(double), true, 0, 9999, out error))
            {
                lbValueError.Text = error;
                return false;
            }

            double value = GetTotalValue();

            // Get values cached in page
            string PNCode = hfSelectedProductPNCode.Value;
            string IngDBName = hfSelectedIngredient.Value;
            string totalNotProvidedByOtherProductsStr = hfTotalNotProvidedByOtherProducts.Value;
            double dosingWeightInKg = double.Parse(hfDosingWeightInKg.Value);
            double totalNotProvidedByOtherProducts = double.Parse(totalNotProvidedByOtherProductsStr);
            double totalPerKgNotProvidedByOtherProducts = totalNotProvidedByOtherProducts / dosingWeightInKg;

            // Get items selected in wizard
            PNProductRow product = PNProduct.GetInstance().FindByPNCode(PNCode);
            PNIngredientRow ingredient = PNIngredient.GetInstance().FindByDBName(IngDBName);
            UnitRow unit = ingredient.GetUnit();

            // Check volume is not zero
            if (value < totalNotProvidedByOtherProducts)
            {
                lbValueError.Text = string.Format("Cannot reduce {0} to {1} {2} by amending {3}.<br /><br />", ingredient.Description, value.ToPNString(), unit.Abbreviation, product.Description);
                lbValueError.Text += string.Format("Total from other products is {0} {1} which is equivalent to {2} {1}/kg", totalNotProvidedByOtherProductsStr, unit.Abbreviation, totalPerKgNotProvidedByOtherProducts.ToPNString());
                return false;
            }
            else if ((value - totalNotProvidedByOtherProducts).IsZero(2))   // Was commented back in to notify user if they enter an ingredient value that means volume is too small to add
            {
                lbValueError.Text = "Quantity required is provided by other ingredients";
                return false;
            }
        }

        return true;
    }

    /// <summary>Validate method for the add wizard</summary>
    /// <returns>If valid</returns>
    private bool ValidateForSetWizard(PNProcessor regimenProcess, PNViewAndAdjustInfo info)
    {
        string error;

        // Basic validation
        if (!Validation.ValidateText(tbValue, string.Empty, typeof(double), true, 0.01, 9999, out error))
        {
            lbValueError.Text = error;
            return false;
        }

        // Get the final required volume or calorie values
        PNIngredientRow ingredient = PNIngredient.GetInstance().FindByDBName(hfSelectedIngredient.Value);
        double? newVolume = null, newCalories = null;
        if (hfSelectedIngredient.Value == PNIngDBNames.Volume)
            newVolume  = this.GetTotalValueForSetWizard(regimenProcess);
        else if ((hfSelectedIngredient.Value == PNIngDBNames.Calories) || (hfSelectedIngredient.Value == PNIngDBNames.Glucose))
            newCalories= this.GetTotalValueForSetWizard(regimenProcess);

        // Check glucose concentration won't be too high or too low
        double glucoseConcentration = regimenProcess.CalculateRequiredGlucoseConcentration(newVolume, newCalories, regimenProcess.DiluentPNCode);
        if (glucoseConcentration > 100)
        {
            lbValueError.Text = "Impossible to give glucose requirements; over 100% would be required";
            return false;
        }
        else if (glucoseConcentration < 0)
        {
            lbValueError.Text = "Impossible to reduce glucose content below zero";
            return false;
        }
        else if (glucoseConcentration.IsZero(2))
        {
            lbValueError.Text = "No glucose is present in the regimen.<br />Cannot adjust volume and calorie content";
            return false;
        }

        return true;
    }

    /// <summary>
    /// Validate the container volume entry for the overage wizard.
    /// Just validates range (smaller than container volume of selected product)
    /// </summary>
    /// <returns>If valid</returns>
    private bool ValidateForOverageWizardContainerVolume(PNProcessor regimenProcess, PNViewAndAdjustInfo info)
    {
        string        PNCode = hfSelectedProductPNCode.Value;
        PNRegimenItem item   = regimenProcess.RegimenItems.FindByPNCode(PNCode);
        string        error;

        // Basic validation
        if (!Validation.ValidateText(tbValue, string.Empty, typeof(double), true, item.VolumneInml, 9999.0, out error))
        {
            lbValueError.Text = error;
            return false;
        }

        return true;
    }

    /// <summary>
    /// Validate the final overage value for the overage wizard.
    /// Just validates range ()
    /// </summary>
    /// <returns>If valid</returns>
    private bool ValidateForOverageWizardFinalValue(PNProcessor regimenProcess, PNViewAndAdjustInfo info)
    {
        string error;

        // Basic validation
        if (!Validation.ValidateText(tbValue, string.Empty, typeof(double), true, 1.0, 9999.0, out error))
        {
            lbValueError.Text = error;
            return false;
        }

        return true;
    }
    #endregion
}
