using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;
using System.Text;
using ascribe.pharmacy.shared;

public partial class application_PNViewAndAdjust_controls_PNSelectStandardRegimen : System.Web.UI.UserControl, IPNWizardCtrl
{
    protected void Page_Load(object sender, EventArgs e) { }

    public void Initalise(PNProcessor processor)
    {
        PNStandardRegimen standardRegimen = new PNStandardRegimen();
        standardRegimen.LoadByPerKiloAndInUse(processor.Prescription.PerKiloRules, true);

        gridSelectStandardRegimen.AddColumn("Description", 100);
        gridSelectStandardRegimen.ColumnAllowTextWrap(0, true);
        gridSelectStandardRegimen.ColumnXMLEscaped   (0, false);

        // Add auto populate option
        gridSelectStandardRegimen.AddRow();
        gridSelectStandardRegimen.SetCell(0, "&lt;Auto populate from regimen requirements&gt;");
        gridSelectStandardRegimen.AddRowAttribute("StandardRegimenID", string.Empty);

        // Add standard regimens
        foreach(PNStandardRegimenRow row in standardRegimen.OrderBy(i => i.RegimenName))
        {
            gridSelectStandardRegimen.AddRow();
            gridSelectStandardRegimen.SetCell(0, row.ToString());
            gridSelectStandardRegimen.AddRowAttribute("StandardRegimenID", row.PNStandardRegimenID.ToString());
        }

        // No standard regimens have been found
        gridSelectStandardRegimen.EmptyGridMessage          = "No standard regimens have been found";
        gridSelectStandardRegimen.EnableAlternateRowShading = true;

        // Clear previous selection
        hfSelectedStandardRegimenID.Value = string.Empty;
    }

    public PNStandardRegimenRow GetSelectedStandardRegimen()
    {
        PNStandardRegimenRow selectedStandardRegimen = null;

        if (!string.IsNullOrEmpty(hfSelectedStandardRegimenID.Value))
        {
            int standardRegimenID = int.Parse(hfSelectedStandardRegimenID.Value);
            selectedStandardRegimen = PNStandardRegimen.GetByID(standardRegimenID);
        }

        return selectedStandardRegimen;
    }

    #region IPNWizardCtrl Members
    public void Initalise()
    {
        hfSelectedStandardRegimenID.Value    = string.Empty;
        hfWarnedUsersAboutRegimenItems.Value = "N";
    }

    public int? RequiredHeight { get { return 450; } }

    public void Focus()
    {
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "SelectStandardRegimen", string.Format("$('#{0}').focus(); selectRow('{0}', 0);", gridSelectStandardRegimen.ID), true);
    }

    public bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info)
    {
        bool hasWarnedUsersAboutRegimenItems = BoolExtensions.PharmacyParse(hfWarnedUsersAboutRegimenItems.Value);
        bool OK = true;

        if (!hasWarnedUsersAboutRegimenItems && (GetSelectedStandardRegimen() != null))
        {
            StringBuilder msg = new StringBuilder();
            PNStandardRegimenRow stdRegimen = GetSelectedStandardRegimen();
            IEnumerable<PNRegimenItem> items = stdRegimen.GetRegimenItems();

            // Check for not in use items
            List<PNRegimenItem> outOfUseItems = items.Where(i => !i.GetProduct().InUse).ToList();
            if (outOfUseItems.Any())
            {
                msg.Append("Following items not in use<br />");
                outOfUseItems.ForEach(i => msg.AppendFormat("&nbsp;&nbsp;&nbsp;&nbsp;{0}<br />", i.GetProduct().Description));
                msg.Append("<br />");
            }

            // Check for items in age range
            HashSet<string> PNCodesForThisAgeRange = new HashSet<string>(PNProduct.GetInstance().FindByAgeRange(regimenProcess.Prescription.AgeRage).Select(i => i.PNCode));
            List<PNRegimenItem> invalidAgeRangeItems = items.Where(i => !PNCodesForThisAgeRange.Contains(i.PNCode)).ToList();
            if (invalidAgeRangeItems.Any())
            {
                msg.AppendFormat("Following items not suitable for {0}<br />", regimenProcess.Prescription.AgeRage);
                invalidAgeRangeItems.ForEach(i => msg.AppendFormat("&nbsp;&nbsp;&nbsp;&nbsp;{0}<br />", i.GetProduct().Description));
                msg.Append("<br />");
            }

            // Display error if needed
            if (msg.Length > 0)
            {
                msg.Append("These items will be removed from the regimen");

                hfWarnedUsersAboutRegimenItems.Value = "Y";
                string script = string.Format("warnAboutStandardRegimen('{0}');", msg.ToString().Replace("'", @"\'"));
                ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "warnAboutStandardRegimen", script, true);
                OK = false;
            }
        }

        return OK;
    }
    #endregion
}
