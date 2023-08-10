using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.icwdatalayer;
using System.Text;

public partial class application_PNViewAndAdjust_controls_SummaryView : System.Web.UI.UserControl
{
    private PNProcessor processor;

    protected void Page_Load(object sender, EventArgs e)
    {
        int? requestID_Regimen = null;
        if (!string.IsNullOrEmpty(this.hfRequestID.Value))
            requestID_Regimen = int.Parse(this.hfRequestID.Value);
        processor = PNProcessor.GetFromCache(requestID_Regimen, false);
    }

    public void Initalise(int? requestID_Regimen)
    {
        this.multiView.ActiveViewIndex      = 0;
        this.btnPrescriptionDetails.CssClass= "TabSelected";
        this.btnClinicalSummary.CssClass    = "Tab";
        this.btnRegimenSummary.CssClass     = "Tab";
        this.hfRequestID.Value              = requestID_Regimen.ToString();
        this.processor                      = PNProcessor.GetFromCache(requestID_Regimen, false);
        this.PrescriptionDetails();
        this.btnPrescriptionDetails.Focus();
    }

    protected void tab_OnClick(object sender, EventArgs e)
    {
        btnPrescriptionDetails.CssClass = "Tab";
        btnClinicalSummary.CssClass     = "Tab";
        btnRegimenSummary.CssClass      = "Tab";

        if (sender == btnPrescriptionDetails)
        {
            btnPrescriptionDetails.CssClass = "TabSelected";
            multiView.ActiveViewIndex       = 0;
            this.PrescriptionDetails();
        }
        else if (sender == btnClinicalSummary)
        {
            btnClinicalSummary.CssClass = "TabSelected";
            multiView.ActiveViewIndex   = 1;
            this.ClinicalDetails();
        }
        else if (sender == btnRegimenSummary)
        {
            btnRegimenSummary.CssClass = "TabSelected";
            multiView.ActiveViewIndex  = 2;
            this.RegimenSummary();
        }
    }

    private void PrescriptionDetails()
    {
        ascribe.pharmacy.icwdatalayer.Request requestPrescription = new Request();
        requestPrescription.LoadByRequestID(processor.Prescription.RequestID);

        Person lastModPerson = new Person();
        lastModPerson.LoadByEntityID(processor.Regimen.LastModifiedEntityID_User);

        Location lastModLocation = new Location();
        lastModLocation.LoadByLocationID(processor.Regimen.LastModifiedLocationID);

        lpPrescriptionDetails.SetColumns(1);
        lpPrescriptionDetails.AddLabel(0, "Prescription Name", processor.Prescription.Description);
        lpPrescriptionDetails.AddLabel(0, "Created Date",      requestPrescription[0].CreatedDate.ToPharmacyDateString());
        lpPrescriptionDetails.AddLabel(0, "Request Date",      processor.Prescription.RequestDate.ToPharmacyDateString());
        lpPrescriptionDetails.AddLabel(0, "Prescriber",        Person.GetByEntityID(processor.Prescription.EntityID_Owner).ToString());

        lpPrescriptionDetails.AddLabel(0, "&nbsp;", string.Empty);  // Spacer

        lpPrescriptionDetails.AddLabel(0, "Regimen Name",      processor.Regimen.Description);
        lpPrescriptionDetails.AddLabel(0, "Created Date",      processor.Regimen.CreatedDate.ToPharmacyDateString());
        lpPrescriptionDetails.AddLabel(0, "Request Date",      processor.Regimen.RequestDate.ToPharmacyDateString());
        lpPrescriptionDetails.AddLabel(0, "Authorised",        processor.Regimen.PNAuthorised.ToYesNoString());
        lpPrescriptionDetails.AddLabel(0, "Last Modified",     processor.Regimen.LastModifiedDate.ToPharmacyDateTimeString());
        lpPrescriptionDetails.AddLabel(0, "Last Modified By",  lastModPerson[0].ToString());
        lpPrescriptionDetails.AddLabel(0, "Last Modified Term",lastModLocation[0].ToString());
    }

    private void ClinicalDetails()
    {
        PNProduct products = PNProduct.GetInstance();

        lpClinicalSummary.SetColumns(1);
        lpClinicalSummary.SetColumnWidth(0, 100);

        lpClinicalSummary.AddLabel(0, "Patient Name",  processor.Patient.ToString());
        lpClinicalSummary.AddLabel(0, "Date of birth", processor.Patient.DOB.ToPharmacyDateString());
        //lpClinicalSummary.AddLabel(0, PharmacyCultureInfo.NHSNumberDisplayName,  processor.Patient.GetNHSNumber ());  05Jul13 XN  27252
        //lpClinicalSummary.AddLabel(0, PharmacyCultureInfo.CaseNumberDisplayName, processor.Patient.GetCaseNumber());
        lpClinicalSummary.AddLabel(0, PharmacyCultureInfo.NHSNumberDisplayName,  processor.Patient.GetNHSNumber ());
        lpClinicalSummary.AddLabel(0, PharmacyCultureInfo.CaseNumberDisplayName, processor.Patient.GetCaseNumber());

        lpClinicalSummary.AddLabel(0, "&nbsp;", string.Empty);  // Spacer

        lpClinicalSummary.AddLabel(0, "Dosing Weight", processor.Prescription.DosingWeightInkg.ToString("0.##") + " kg");
        lpClinicalSummary.AddLabel(0, "Status",        processor.Episode.EpisodeTypeStr);
        WardRow ward = processor.Episode.GetWard();
        lpClinicalSummary.AddLabel(0, "Ward", (ward != null) ? ward.Code + "  -  " + ward.ToString() : string.Empty);
        ConsultantRow consultant = processor.Episode.GetConsultant();
        lpClinicalSummary.AddLabel(0, "Consultant", (consultant != null) ? consultant.Code + "  -  " + consultant.Description : string.Empty);
        lpClinicalSummary.AddLabel(0, "Requested by", Person.GetByEntityID(processor.Prescription.EntityID_Owner).ToString());
        lpClinicalSummary.AddLabel(0, "&nbsp;", string.Empty);  // Spacer

        double calories = processor.CalculateTotal(PNIngDBNames.Calories);
        double nitrogen = processor.CalculateTotal(PNIngDBNames.Nitrogen);
        string nitrogenUnits = PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Nitrogen).GetUnit().Abbreviation;
        if (!nitrogen.IsZero(2))
            lpClinicalSummary.AddLabel(0, "Calories/gram nitrogen", string.Format("{0} non-protein Cals/{1} N", (int)(calories/nitrogen), nitrogenUnits));  // Converted to int inline with v8 code

        lpClinicalSummary.AddLabel(0, "Glucose concentration", processor.CalculateGlucosePercenrtageAsString());
        lpClinicalSummary.AddLabel(0, "Calorie ratio",         processor.CalculateCalorieRatio());

        lpClinicalSummary.AddLabel(0, "&nbsp;", string.Empty);  // Spacer

        double solubility = processor.CheckCaPO4Solubility();
        if (solubility > 1.0)
            lpClinicalSummary.AddLabel(0, "Ca PO4 solubility curve", string.Format("ABOVE critical value, Index = {0:#}%", solubility * 100));
        else if (solubility < 1.0 && solubility > 0.0)
            lpClinicalSummary.AddLabel(0, "Ca PO4 solubility curve", string.Format("below critical value, Index = {0:#}%", solubility * 100));
        else
            lpClinicalSummary.AddLabel(0, "Ca PO4 solubility curve", "not applicable");

        lpClinicalSummary.AddLabel(0, "&nbsp;", string.Empty);  // Spacer

        List<string> PNCodesMissed, PNCodesInvalidVol;
        double mOsmperkgH2O = processor.CalculateOsmolality(out PNCodesMissed, out PNCodesInvalidVol);
        string mOsmperkgH2OStr = "Not available";
        if (!mOsmperkgH2O.IsZero())
        {
            mOsmperkgH2OStr = mOsmperkgH2O.ToPNString() + " mOsmol/kg water (approx)<br />";
            if (PNCodesMissed.Any() || PNCodesInvalidVol.Any())
                mOsmperkgH2OStr += string.Format("Data incomplete for the following {0} products<br />", PNCodesMissed.Count + PNCodesInvalidVol.Count);
            if (PNCodesMissed.Any())
                mOsmperkgH2OStr += PNCodesMissed.Select    (p => "&nbsp;&nbsp;&nbsp;&nbsp;" + products.FindByPNCode(p).Description + " " + processor.RegimenItems.FindByPNCode(p).VolumneInml.ToPNString() + " ml").ToCSVString("<br />");
            if (PNCodesInvalidVol.Any())
                mOsmperkgH2OStr += PNCodesInvalidVol.Select(p => "&nbsp;&nbsp;&nbsp;&nbsp;" + products.FindByPNCode(p).Description + "  (Volume is not valid)").ToCSVString("<br />");
        }
        lpClinicalSummary.AddLabel(0, "Estimated Osmolality", mOsmperkgH2OStr);
        lpClinicalSummary.GetLabel(0, lpClinicalSummary.GetLabelCount(0) - 1).xmlEscape = false;
    }

    private void RegimenSummary()
    {
        // Get general data (some only used for separate regimen)
        double totalVolume = processor.RegimenItems.CalculateTotal(PNIngDBNames.Volume);
        IEnumerable<PNRegimenItem> aqueousProducts = processor.RegimenItems.FindByAqueousOrLipid(PNProductType.Aqueous).ToList();
        IEnumerable<PNRegimenItem> lipidProducts   = processor.RegimenItems.FindByAqueousOrLipid(PNProductType.Lipid  ).ToList();
        double aqueousVolume = aqueousProducts.CalculateTotal(PNIngDBNames.Volume);
        double lipidVolume   = lipidProducts.CalculateTotal  (PNIngDBNames.Volume);

        // Set regimen total
        if (processor.Regimen.IsCombined)
            lbRegimenSummaryTotals.InnerText = string.Format("Aqueous volume {0} ml, Lipid volume {1} ml", aqueousVolume.ToPNString(), lipidVolume.ToPNString());

        // Setup columns
        gcRegimenSummary.AddColumn("Name", processor.Regimen.IsCombined ? 40 : 36, PharmacyGridControl.ColumnType.Text);
        gcRegimenSummary.ColumnAllowTextWrap(0, true);
        gcRegimenSummary.AddColumn("Unit", 10, PharmacyGridControl.ColumnType.Text);
        gcRegimenSummary.AddColumn("Total",12, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right, PharmacyGridControl.AlignmentType.Right);
        if (processor.Regimen.IsCombined)
            gcRegimenSummary.AddColumn("/litre", 17, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right, PharmacyGridControl.AlignmentType.Right);
        else
        {
            gcRegimenSummary.AddColumn("/litre (aq)",  15, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right, PharmacyGridControl.AlignmentType.Right);
            gcRegimenSummary.AddColumn("/litre (lip)", 15, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right, PharmacyGridControl.AlignmentType.Right);
        }
        gcRegimenSummary.AddColumn("/Kilo", 12, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right, PharmacyGridControl.AlignmentType.Right);
        gcRegimenSummary.EnableAlternateRowShading = true;
        gcRegimenSummary.SortableColumns           = true;

        // Calculate volume total first as slightly differente
        PNIngredientRow volume = PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Volume);
        gcRegimenSummary.AddRow();
        string ingName  = volume.ToString();
        if (Char.IsLower(ingName[0]))
            ingName = Char.ToUpper(ingName[0]) + ingName.SafeSubstring(1, ingName.Length - 1); // upper case first letter
        gcRegimenSummary.SetCell(0, ingName);
        gcRegimenSummary.SetCell(1, volume.GetUnit().Abbreviation);
        gcRegimenSummary.SetCell(2, totalVolume.ToVDUString());
        gcRegimenSummary.SetCell(3, "-------");
        if (!processor.Regimen.IsCombined)
            gcRegimenSummary.SetCell(4, "-------");
        if (!processor.Prescription.DosingWeightInkg.IsZero())
            gcRegimenSummary.SetCell(gcRegimenSummary.ColumnCount - 1, (totalVolume / processor.Prescription.DosingWeightInkg).ToVDUString());

        // Calculate totals
        //IEnumerable<PNIngredientRow> ingredients = PNIngredient.GetInstance().FindByForPNProduct(false).Where(i => i.DBName != PNIngDBNames.Protein).OrderBySortIndex();  9Sep14 XN removed protien from PN 95647
        IEnumerable<PNIngredientRow> ingredients = PNIngredient.GetInstance().FindByForPNProduct(false).OrderBySortIndex();
        foreach (PNIngredientRow ing in ingredients)
        {
            double ingTotal = processor.RegimenItems.CalculateTotal(ing.DBName);
            ingName  = ing.ToString();
            if (Char.IsLower(ingName[0]))
                ingName = Char.ToUpper(ingName[0]) + ingName.SafeSubstring(1, ingName.Length - 1); // upper case first letter

            gcRegimenSummary.AddRow();
            gcRegimenSummary.SetCell(0, ingName);
            gcRegimenSummary.SetCell(1, ing.GetUnit().Abbreviation);
            gcRegimenSummary.SetCell(2, ingTotal.ToVDUString());

            if (processor.Regimen.IsCombined)
            {
                if (!totalVolume.IsZero())
                    gcRegimenSummary.SetCell(3, (1000.0 * ingTotal / totalVolume).ToVDUString());
            }
            else
            {
                if (!aqueousVolume.IsZero())
                    gcRegimenSummary.SetCell(3, (1000.0 * aqueousProducts.CalculateTotal(ing.DBName) / aqueousVolume).ToVDUString());
                if (!lipidVolume.IsZero())
                    gcRegimenSummary.SetCell(4, (1000.0 * lipidProducts.CalculateTotal(ing.DBName) / lipidVolume).ToVDUString());
            }

            gcRegimenSummary.SetCell(gcRegimenSummary.ColumnCount - 1, (ingTotal / processor.Prescription.DosingWeightInkg).ToVDUString());
        }
    }
}
