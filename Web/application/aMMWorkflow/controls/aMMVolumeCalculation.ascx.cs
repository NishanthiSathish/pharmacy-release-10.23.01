// -----------------------------------------------------------------------
// <copyright file="aMMVolumeCalculation.aspx.cs" company="Ascribe">
//      Copyright Ascribe Ltd  
// </copyright>
// <summary>
// Handles the AMM volume calculations in the new supply request wizard
//
// Allows user to select the volume type (fixed or drug+nominal), and 
// also to edit the fixed volume
//
// See aMMProcessor.CalculateVolume for more detail of the volume calculation
//
// Note the calculation screen will dynamically update as users makes a selection 
// this update is done by web method NewAmmSupplyRequestWizard.aspx/UpdateCalculation.
//
// When using this control you will also need to include script 
// aMMWorkflow/script/aMMVolumeCalculation.js
//
// Modification History:
// 19Jun15 XN Created 39882
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Web.UI;
using System.Web.UI.WebControls;

using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.manufacturinglayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using Unit = ascribe.pharmacy.icwdatalayer.Unit;

public partial class application_aMMWorkflow_controls_aMMVolumeCalculation : System.Web.UI.UserControl
{
    /// <summary>Gets selected volume type</summary>
    public aMMVolumeType VolumeType
    {
        get { return rbFixedVolume.Checked ? aMMVolumeType.Fixed : aMMVolumeType.DrugAndNominal; }
    }

    /// <summary>Gets selected volume infusion in ml</summary>
    public double VolumeOfInfusionInmL
    {
        get { return double.Parse(this.VolumeType == aMMVolumeType.Fixed ? tbFixedVolume.Text : tbDrugNominalVolume.Text); }
    }

    /// <summary>Gets the dose units</summary>
    public double Dose
    {
        get { return double.Parse(tdDrugDose.InnerText); }
    }

    /// <summary>Gets the dose unit string</summary>
    public string DoseUnitString
    {
        get { return tdDrugDoseUnits.InnerText; }
    }

    /// <summary>Pre render page</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">Event args</param>
    protected void Page_PreRender(object sender, EventArgs e)
    {
        string updateCalculationStr = string.Format("updateCalculation({0}, {1});", SessionInfo.SessionID, SessionInfo.SiteID);

        rbFixedVolume.InputAttributes.Add("VolumeType", aMMVolumeType.Fixed.ToString());
        rbFixedVolume.InputAttributes.Add("onclick", updateCalculationStr);
        rbDrugNominalVolume.InputAttributes.Add("VolumeType", aMMVolumeType.DrugAndNominal.ToString());
        rbDrugNominalVolume.InputAttributes.Add("onclick", updateCalculationStr);
        tbFixedVolume.Attributes.Add("onkeyup", updateCalculationStr);

        ScriptManager.RegisterStartupScript(this, this.GetType(), "PerformUpdate", updateCalculationStr, true);        
    }

    /// <summary>Initialise the control</summary>
    /// <param name="prescription">Selected prescription</param>
    /// <param name="drug">Selected drug</param>
    /// <param name="formula">Selected formula</param>
    public void Initalise(PrescriptionRow prescription, WProductRow drug, WFormulaRow formula)
    {
        hfNSVCode.Value = drug.NSVCode;

        // Get the units and drug dose
        string units;
        double drugDose;
        if (prescription.Dose == null)
        {
            // Doseless prescription so get dose and units from pharmacy drug 
            trPrescriptionDose.Visible = false;
            units    = Unit.GetByAbbreviation(drug.DosingUnits).Abbreviation;
            drugDose = drug.DosesPerIssueUnit.Value;
        }
        else
        {            
            UnitRow prescriptionUnits = Unit.GetByUnitID(prescription.UnitID_Dose.Value);
            UnitRow dosingUnits       = Unit.GetByAbbreviation(drug.DosingUnits);
            
            trPrescriptionDose.Visible = true;
            tdPrescriptionDose.InnerText      = prescription.Dose.Value.ToString("0.####");
            tdPrescriptionDoseUnits.InnerText = prescriptionUnits.Abbreviation;

            // Convert prescription units to dosing units
            units    = dosingUnits.Abbreviation;
            drugDose = Unit.Convert(prescription.Dose.Value, prescriptionUnits, dosingUnits).Value;
        }

        // Fill in drug details
        tdDrugDose.InnerText      = drugDose.ToString("0.####");
        tdDrugDoseUnits.InnerText = units;

        // Set fixed volume (not editable if fixed volume is greater than 0)
        tbFixedVolume.Text = drug.MaxInfusionRateInmL.ToString("0.####");
        if ((drug.MaxInfusionRateInmL ?? 0) > aMMProcessor.MinDose)
        {
            tbFixedVolume.ReadOnly  = (drug.MaxInfusionRateInmL ?? 0) > aMMProcessor.MinDose;
            tbFixedVolume.Attributes.Add("onselectstart", "return false;");
            tbFixedVolume.Attributes.Add("onmousedown",   "return false;");
            tbFixedVolume.BorderStyle = BorderStyle.None;
        }
        else
        {
            tbFixedVolume.Attributes.Add("onclick", "this.select();");
        }

        // Drug Nominal Volume is only a textbox so can maintain view state
        tbDrugNominalVolume.Attributes.Add("readonly", "readonly");
        tbDrugNominalVolume.Attributes.Add("onselectstart", "return false;");
        tbDrugNominalVolume.Attributes.Add("onmousedown",   "return false;");
        tbDrugNominalVolume.BorderStyle = BorderStyle.None;

        // Get standard rule and concentration values
        spanRuleMaxPercVolToAdd.InnerText = aMMSetting.NewDrugWizard.MaxPercentageOfVolume.ToString("0.####");
        tdMinConc.InnerText = drug.MinConcentrationInDoseUnitsPerml.ToString("0.####");
        tdMaxConc.InnerText = drug.MaxConcentrationInDoseUnitsPerml.ToString("0.####");

        // Set default volume type
        switch (aMMSetting.NewDrugWizard.DefaultVolumeType)
        {
        case aMMVolumeType.Fixed:
            rbFixedVolume.Checked = true;
            //if (tbFixedVolume.ReadOnly)
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "focus", "$('input[id$=rbFixedVolume]').focus();", true);
            //else
            //    ScriptManager.RegisterStartupScript(this, this.GetType(), "focus", "var tb = $('input[id$=tbFixedVolume]'); tb.focus(); tb.select();", true);
            break;

        case aMMVolumeType.DrugAndNominal: 
            rbDrugNominalVolume.Checked = true; 
            //ScriptManager.RegisterStartupScript(this, this.GetType(), "focus", "$('input[id$=rbDrugNominalVolume]').focus();", true);
            break;
        }
    }

    /// <summary>Validates user selection</summary>
    /// <returns>If validation passed</returns>
    public bool Validate()
    {
        string error = string.Empty;
        bool ok = BoolExtensions.PharmacyParse(hfValidCalculation.Value);

        // Check volume has been entered and is in range
        if (!Validation.ValidateText(this.tbFixedVolume, "Fixed Volume", typeof(double), true, 0, 10000, out error))
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ShowError", string.Format("$('td[id$=tdErrorMsg]').text('{0}')", error.JavaStringEscape()), true);
            ok = false;
        }

        return ok;
    }
}