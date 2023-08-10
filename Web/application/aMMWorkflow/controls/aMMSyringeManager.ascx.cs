// --------------------------------------------------------------------------------------------------------------------
// <copyright file="aMMSyringeManager.ascx.cs" company="Ascribe Ltd">
//   Copyright Ascribe Ltd
// </copyright>
// <summary>
// Controls determining if to use Even or Full and part syringes
// Used byte the aMM new supply request wizard.
//
// Modification History:
// 19Jun15 XN Created 39882
// 15Aug16 XN 159843 Initialise requires product
// </summary>
// --------------------------------------------------------------------------------------------------------------------
using System.Web.UI;
using ascribe.pharmacy.manufacturinglayer;
using ascribe.pharmacy.pharmacydatalayer;

public partial class application_aMMWorkflow_controls_aMMSyringeManager : System.Web.UI.UserControl
{
    /// <summary>Gets selected fill type </summary>
    public aMMSyringeFillType Selected
    {
        get
        {
            if (rbEven.Checked)
            {
                return aMMSyringeFillType.EvenSplit;
            }
            else if (rbFullAndPart.Checked)
            {
                return aMMSyringeFillType.FullAndPart;
            }
            else
            {
                return aMMSyringeFillType.None;
            }
        }
    }

    /// <summary>Initialise the control</summary>
    /// <param name="dose">Dose being given</param>
    /// <param name="doseUnits">Dose units</param>
    /// <param name="volumeInmL">Volume being given</param>
    /// <param name="product">Product row 159843 15Aug16 XN</param>
    public void Initalise(double dose, string doseUnits, double volumeInmL, WProductRow product)
    {
        lbTotalPerDose.Text = string.Format("Total each dose: {0:0.####} {1} in {2:0.####} mL", dose, doseUnits, volumeInmL);

        int numberOfSyringes = aMMProcessor.CalculateNumberOfContainers(volumeInmL, product);
        
        // Calculate even syringe fill
        double evenDose, evenVolumeInmL;
        aMMProcessor.CalculateSyringeEvenSplit(dose, volumeInmL, out evenDose, out evenVolumeInmL, product);
        gridEven.AddColumn("Syringe", 20, PharmacyGridControl.AlignmentType.Center);
        gridEven.AddColumn("Dose in " + doseUnits, 40, PharmacyGridControl.AlignmentType.Right);
        gridEven.AddColumn("Volume in mL ", 40, PharmacyGridControl.AlignmentType.Right);
        for (int s = 0; s < numberOfSyringes; s++)
        {
            gridEven.AddRow();
            gridEven.SetCell(0, (s + 1).ToString());
            gridEven.SetCell(1, evenDose.ToString("0.####"));
            gridEven.SetCell(2, evenVolumeInmL.ToString("0.####"));
        }
        
        // Calculate full and part syringe fill
        double splitDose, splitVolumeInmL, finalDose, finalVolumeInmL;
        aMMProcessor.CalculateSyringeFullAndPart(dose, volumeInmL, out splitDose, out splitVolumeInmL, out finalDose, out finalVolumeInmL);
        gridFullAndPart.AddColumn("Syringe", 20, PharmacyGridControl.AlignmentType.Center);
        gridFullAndPart.AddColumn("Dose in " + doseUnits, 40, PharmacyGridControl.AlignmentType.Right);
        gridFullAndPart.AddColumn("Volume in mL ", 40, PharmacyGridControl.AlignmentType.Right);
        for (int s = 0; s < numberOfSyringes - 1; s++)
        {
            gridFullAndPart.AddRow();
            gridFullAndPart.SetCell(0, (s + 1).ToString());
            gridFullAndPart.SetCell(1, splitDose.ToString("0.####"));
            gridFullAndPart.SetCell(2, splitVolumeInmL.ToString("0.####"));
        }
        
        gridFullAndPart.AddRow();
        gridFullAndPart.SetCell(0, numberOfSyringes.ToString());
        gridFullAndPart.SetCell(1, finalDose.ToString("0.####"));
        gridFullAndPart.SetCell(2, finalVolumeInmL.ToString("0.####"));

        // Set radio button click events
        rbEven.InputAttributes.Add       ("onclick", "$('#divFullAndPart').visible(false); $('#divEven').visible(true);");
        rbFullAndPart.InputAttributes.Add("onclick", "$('#divEven').visible(false); $('#divFullAndPart').visible(true);");

        // Select default button
        switch (aMMSetting.NewDrugWizard.DefaultSyringeFillType)
        {
        case aMMSyringeFillType.EvenSplit: 
            ScriptManager.RegisterStartupScript(this, this.GetType(), "init", "$('#divEven').visible(true); $('input[id$=rbEven]').focus();", true);
            rbEven.Checked = true; 
            break;
        case aMMSyringeFillType.FullAndPart: 
            ScriptManager.RegisterStartupScript(this, this.GetType(), "init", "$('#divFullAndPart').visible(true); $('input[id$=rbFullAndPart]').focus();", true);
            rbFullAndPart.Checked = true; 
            break;
        }
    }

    /// <summary>Validates the control (always returns true)</summary>
    /// <returns>If control is valid</returns>
    public bool Validate()
    {
        return true;
    }
}