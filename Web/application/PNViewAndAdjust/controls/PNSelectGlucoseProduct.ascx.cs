//===========================================================================
//
//					  	    PNSelectGlucoseProduct.aspx.cs
//
//  Control used in the PN set volume or calories wizard to allow selection 
//  of glucose product (or diluent)
//  Used separate control rather than re-using PNSelectProduct, as requires
//  lots of extra validation.
//
//	Modification History:
//	15Nov11 XN  Written
//  21Mar13 XN  Added no glucode or water mix (optional) option to list (59607)
//  26Mar13 XN  Update to no glucose or water mix option to standard reg list (59607)
//===========================================================================
using System.Collections.Generic;
using System.Text;
using System.Web.UI;
using System.Linq;
using ascribe.pharmacy.parenteralnutritionlayer;
using System;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.shared;
using System.Collections;

public partial class application_PNViewAndAdjust_controls_PNSelectGlucoseProduct : System.Web.UI.UserControl, IPNWizardCtrl
{
    /// <summary>Inialise list of glucose products</summary>
    /// <param name="selectedIngredient">Currently selected option in the wizard (volume or calories)</param>
    /// <param name="totalValue">Total value of the ingredeitn entered by the user</param>
    /// <param name="processor">Regimen processor</param>
    /// <param name="info">Regimen info</param>
    /// <param name="useCachedProcessorCopy">Used the cached copy of the the processor for validation (rather than standard one passed in) normal used when adding standard regimen</param>
    /// <param name="includeNoMixOption">If the no mix option is shown (bottom of list)</param>
    public void Initalise(PNIngredientRow selectedIngredient, double totalValue, PNProcessor processor, PNViewAndAdjustInfo info, bool useCachedProcessorCopy)
    {
        Initalise(selectedIngredient, totalValue, processor, info, useCachedProcessorCopy, false);
    }
    public void Initalise(PNIngredientRow selectedIngredient, double totalValue, PNProcessor processor, PNViewAndAdjustInfo info, bool useCachedProcessorCopy, bool includeNoMixOption)
    {
        PNProduct products = PNProduct.GetInstance();
        PNProductRow diluentProduct = products.FindByPNCode(processor.DiluentPNCode);

        hfSelectedIngredient.Value      = selectedIngredient.DBName;
        hfTotalValue.Value              = totalValue.ToString();
        hfUseCachedProcessorCopy.Value  = useCachedProcessorCopy.ToYesNoString();
        hfIncludeNoMixOption.Value      = includeNoMixOption.ToYesNoString();

        cbMixing.Text    = "Mix with " + diluentProduct.ToString();
        cbMixing.ToolTip = string.Format("Select to mix with {0} (Alt+M)", diluentProduct.ToString());

        double? requiredVolume   = (selectedIngredient.DBName == PNIngDBNames.Volume  ) ? totalValue : (double?)null;
        double? requiredCalories = (selectedIngredient.DBName == PNIngDBNames.Calories) || (selectedIngredient.DBName == PNIngDBNames.Glucose) ? totalValue : (double?)null;
        double glucoseConcentraion = processor.CalculateRequiredGlucoseConcentration(requiredVolume, requiredCalories, processor.DiluentPNCode);

        StringBuilder caption = new StringBuilder();
        caption.AppendFormat("To give final volume requires a {0}% concentration of glucose solution<br />", glucoseConcentraion.ToPNString());
        caption.AppendFormat("Choose a product, and select if mixing with {0}", diluentProduct); 
        lbCaption.Text = caption.ToString();

        // Set grid columns
        gridSelectGlucoseProduct.AddColumn("Product", 95, PharmacyGridControl.ColumnType.Text);
        gridSelectGlucoseProduct.SortableColumns = true;

        // Populate gird with glucose products
        IEnumerable<PNProductRow> glucoseProducts = products.FindByInUse().FindByAgeRange(info.ageRange).FindByOnlyContainGlucose().OrderBySortIndex();
        foreach (PNProductRow product in glucoseProducts)
        {
            gridSelectGlucoseProduct.AddRow();
            gridSelectGlucoseProduct.AddRowAttribute("PNCode", product.PNCode);
            gridSelectGlucoseProduct.SetCell(0, product.ToString());
        }

        if (includeNoMixOption)
        {
            gridSelectGlucoseProduct.AddRow();
            gridSelectGlucoseProduct.AddRowAttribute("PNCode", "---");
            gridSelectGlucoseProduct.SetCell(0, "<Accept standard regimen without alterating glucose products>");
        }


        // Select currently selected item, or first row, by default
        int selectedIndex = gridSelectGlucoseProduct.FindIndexByAttrbiuteValue("PNCode", hfSelectedProductPNCode.Value);
        if (selectedIndex == -1)
            selectedIndex = 0;
        if (gridSelectGlucoseProduct.RowCount > 0)
        {
            string script = string.Format("selectRow('{0}', {1}); $('#{0}').focus();", gridSelectGlucoseProduct.ID, selectedIndex);
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "InitProductGrid", script, true);
        }
    }

    /// <summary>Returns the selected PN product</summary>
    /// <returns>Selected PN product</returns>
    public PNProductRow GetSelectedProduct()
    {
        return PNProduct.GetInstance().FindByPNCode(hfSelectedProductPNCode.Value);
    }

    /// <summary>If user has opted to mix with water</summary>
    public bool Mixing
    {
        get { return cbMixing.Checked; }
    }

    #region IPNWizardCtrl Members
    public void Initalise() 
    { 
        hfSelectedProductPNCode.Value = string.Empty;
        hfSelectedIngredient.Value    = string.Empty;
        hfTotalValue.Value            = string.Empty;
        hfRequestedNoMixing.Value     = string.Empty;
        hfUseCachedProcessorCopy.Value= string.Empty;
        hfIncludeNoMixOption.Value    = string.Empty;
        lbValidationError.Text        = string.Empty;
        cbMixing.Checked              = false;
    }

    public int? RequiredHeight { get { return 450; } }

    public void Focus() { /* Done in init */ }

    /// <summary>
    /// Validates the selected product
    /// Checks glucose cocentration won't be too high or low
    /// If the change in glucose is greater than 2% asks user if they want to mix with water
    /// </summary>
    /// <returns>If valid</returns>
    public bool Validate(PNProcessor processor, PNViewAndAdjustInfo info) 
    {
        // Clear last error
        lbValidationError.Text = string.Empty;

        // Use the cached copy of the regimen if that was requested in the initalise function
        bool useCachedProcessorCopy = !string.IsNullOrEmpty(hfUseCachedProcessorCopy.Value) && BoolExtensions.PharmacyParse(hfUseCachedProcessorCopy.Value);
        if (useCachedProcessorCopy)
            processor = PNProcessor.GetFromCache(processor.Regimen.RequestID, true);

        PNProductRow diluentProduct  = PNProduct.GetInstance().FindByPNCode(processor.DiluentPNCode);
        PNProductRow selectedProduct = this.GetSelectedProduct();

        // If returns no selected product then user selected no mix option so all okay
        bool includeNoMixOption = BoolExtensions.PharmacyParse(hfIncludeNoMixOption.Value);
        //if (selectedProduct == null && includeNoMixOption)
        //    return true;

        PNIngredientRow selectedIngredient = PNIngredient.GetInstance().FindByDBName(hfSelectedIngredient.Value);
        double totalValue = double.Parse(hfTotalValue.Value);
        
        double? requiredVolume   = (selectedIngredient.DBName == PNIngDBNames.Volume  ) ? totalValue : (double?)null;
        double? requiredCalories = (selectedIngredient.DBName == PNIngDBNames.Calories) || (selectedIngredient.DBName == PNIngDBNames.Glucose) ? totalValue : (double?)null;
        double glucoseConcentraion = processor.CalculateRequiredGlucoseConcentration(requiredVolume, requiredCalories, processor.DiluentPNCode);

        // Get info on if user has requested not not mix after calling askUserAboutLargeGlucoseChanges, and page posted back
        bool requestedNoMixing = false;
        BoolExtensions.TryPharmacyParse(hfRequestedNoMixing.Value, out requestedNoMixing);

        if (this.Mixing && selectedProduct != null)
        {
            double diluentGlucoseConcentration = diluentProduct.CalculateIngredientValue(PNIngDBNames.Glucose, 1.0) * 100;
            if (glucoseConcentraion < diluentGlucoseConcentration)
            {
                Initalise(selectedIngredient, totalValue, processor, info, useCachedProcessorCopy, includeNoMixOption);
                lbValidationError.Text = "Mixing less than " + diluentGlucoseConcentration.ToPNString() + "% is not possible";
                return false;
            }

            double selectedProductConcentration = selectedProduct.CalculateIngredientValue(PNIngDBNames.Glucose, 1.0) * 100;
            if (selectedProductConcentration < glucoseConcentraion)
            {
                Initalise(selectedIngredient, totalValue, processor, info, useCachedProcessorCopy, includeNoMixOption);
                lbValidationError.Text = "Concentration too low";
                return false;
            }
        }
        else if (!requestedNoMixing)
        {
            // If not mixing then ensure the glucose level will not change by more than 2%
            // If it is greater the 2%, then moves to complete stage to notify the user of the issue

            // Take copy of regimen and determine how the changes will affect it
            PNProcessor newProcessor = (PNProcessor)processor.Clone();

            double currentVolumeInml = processor.CalculateTotal(PNIngDBNames.Volume);
            double glucoseRequired, glucoseAfter;
            if (selectedIngredient.DBName == PNIngDBNames.Volume && selectedProduct == null)
            {
                glucoseAfter = processor.CalculateTotal(PNIngDBNames.Glucose);
                newProcessor.ScaleBy((totalValue * 100.0)/ currentVolumeInml);
                glucoseRequired = newProcessor.CalculateTotal(PNIngDBNames.Glucose);
            }
            else if (selectedIngredient.DBName == PNIngDBNames.Volume && selectedProduct != null)
            {
                glucoseRequired = processor.CalculateTotal(PNIngDBNames.Glucose);
                newProcessor.AdjustVolume(false, selectedProduct.PNCode, totalValue, info);
                glucoseAfter = newProcessor.CalculateTotal(PNIngDBNames.Glucose);
            }
            else
            {
                var glucoseOnlyProducts = PNProduct.GetInstance().FindByOnlyContainGlucose().Select(p => p.PNCode).ToList();
                double caloriesFromOtherProducts = processor.RegimenItems.Where(p => !glucoseOnlyProducts.Contains(p.PNCode)).CalculateTotal(PNIngDBNames.Calories);
                double glucoseFromOtherProducts  = processor.RegimenItems.Where(p => !glucoseOnlyProducts.Contains(p.PNCode)).CalculateTotal(PNIngDBNames.Glucose );
                glucoseRequired = ((totalValue - caloriesFromOtherProducts) / processor.kcalPerGramGlucose) + glucoseFromOtherProducts;

                newProcessor.AdjustCalories(false, selectedProduct.PNCode, totalValue, info);
                glucoseAfter = newProcessor.CalculateTotal(PNIngDBNames.Glucose);
            }

            // Determine the glucose percentage difference
            double percentageDiff = Math.Abs((((glucoseAfter - glucoseRequired) / glucoseRequired) * 100));
            UnitRow glucoseUnits = PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Glucose).GetUnit();
            UnitRow volumeUnits  = PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Volume ).GetUnit();

            StringBuilder error = new StringBuilder();

            // Not mixing with glucose so add volume difference to message
            if (selectedProduct == null)
            {
                double volumeDiff = Math.Abs(requiredVolume.Value - currentVolumeInml);
                if (volumeDiff.To3SigFigish() > 0)  // If greater than 1ml then notify user of volume difference
                {
                    error.AppendFormat("Volume delivered will be {0} {1} ({2} {1}/kg)<br />", currentVolumeInml.ToPNString(), volumeUnits.Abbreviation, (currentVolumeInml / processor.Prescription.DosingWeightInkg).ToPNString());
                    error.AppendFormat("instead of {0} {1} ({2} {1}/kg)<br /><br />", requiredVolume.Value.ToPNString(), volumeUnits.Abbreviation, (requiredVolume.Value / processor.Prescription.DosingWeightInkg).ToPNString());
                }

                double glucosePercentageCurrent   = newProcessor.CalculateGlucosePercenrtage(PNProductType.Aqueous) ?? 0;
                double glucosePercentageRequested = (glucosePercentageCurrent * currentVolumeInml) / requiredVolume.Value;
                double glucosePercentageDiff      = Math.Abs(glucosePercentageCurrent - glucosePercentageRequested);
                if (glucosePercentageDiff.To3SigFigish() > 0)
                    error.AppendFormat("Glucose concentration will be {0}%<br />instead of {1}% (aqueous part only)", glucosePercentageCurrent.ToPNString(), glucosePercentageRequested.ToPNString());

                string script = string.Format("warnUserAboutGlucoseChanges('{0}');", error.ToString());
                ScriptManager.RegisterStartupScript(this, this.GetType(), "WarnGlucoseChanges", script, true);

                Initalise(selectedIngredient, totalValue, processor, info, useCachedProcessorCopy, includeNoMixOption);
                return false;
            }
            else if (percentageDiff.To3SigFigish() > 2)  // If greater than 2% then notify user
            {
                // Create error
                error.AppendFormat("If {0} is used alone then {1}{2} of ", selectedProduct, glucoseAfter.ToPNString(), glucoseUnits.Abbreviation);
                error.AppendFormat("glucose will be supplied instead of {0}{1}.<br />", glucoseRequired.ToPNString(), glucoseUnits.Abbreviation);
                error.AppendFormat("This is {0}% {1} than requested.<br /><br />", percentageDiff.ToPNString(), (glucoseAfter > glucoseRequired) ? "higher" : "lower");
                error.AppendFormat("Would you like to mix with {0} for the exact concentration?", PNProduct.GetInstance().FindByPNCode(processor.DiluentPNCode).Description);
            
                // Call java script method 
                string script = string.Format("askUserAboutLargeGlucoseChanges('{0}');", error.ToString());
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AskIfMixing", script, true);

                Initalise(selectedIngredient, totalValue, processor, info, useCachedProcessorCopy, includeNoMixOption);
                return false;
            }
        }

        return true;     
    }
    #endregion 
}
