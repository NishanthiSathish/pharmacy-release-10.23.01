using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;
using System.Web.UI.HtmlControls;

public partial class application_PNViewAndAdjust_controls_PNVolumeAndWeights : System.Web.UI.UserControl
{
    private PNProcessor processor;
    private string volumeUnits, weightUnits;
    private bool showFullWeight;

    protected void Page_Load(object sender, EventArgs e) { }

    public void Update(PNProcessor processor, bool showFullWeight)
    {
        this.processor      = processor;
        this.showFullWeight = showFullWeight;

        ascribe.pharmacy.icwdatalayer.Unit units = new ascribe.pharmacy.icwdatalayer.Unit(); 
        units.LoadByDescription("gram");
        weightUnits = " " + units[0].Abbreviation;
        volumeUnits = " " + PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Volume).GetUnit().Abbreviation;

        bool isCombined = processor.Regimen.IsCombined;
        IEnumerable<PNRegimenItem> items;
        double aqueousOrCombinedVolumeWithOverageInml = 0.0, aqueousOrCombinedWeightWithOverageIng = 0.0;
        double lipidVolumeWithOverageInml = 0.0, lipidWeightWithOverageIng = 0.0;
        HtmlTableRow row;

        items = processor.RegimenItems.FindByAqueousOrLipid(isCombined ? PNProductType.Combined : PNProductType.Aqueous).OrderBy(i => i.GetProduct().SortIndex);
        PopulateTableWithProducts(items, out aqueousOrCombinedVolumeWithOverageInml, out aqueousOrCombinedWeightWithOverageIng);
        if (!isCombined)
        {
            row = AddRow();
            row.Attributes.Add("RowType", "total");
            row.Cells[0].InnerText = "Total " + PNProductType.Aqueous.ToString();

            if (showFullWeight)
                row.Cells[3].InnerText = aqueousOrCombinedVolumeWithOverageInml.ToPNFullString(true) + volumeUnits;
            else 
                row.Cells[3].InnerText = aqueousOrCombinedVolumeWithOverageInml.ToPNString() + volumeUnits;
            row.Cells[4].InnerText = aqueousOrCombinedWeightWithOverageIng.IsZero(4) ? "-----" : aqueousOrCombinedWeightWithOverageIng.To4SigFigString() + weightUnits;

            // add lipid product
            AddSpacerRow("10px");
            items = processor.RegimenItems.FindByAqueousOrLipid(PNProductType.Lipid).OrderBy(i => i.GetProduct().SortIndex);
            PopulateTableWithProducts(items, out lipidVolumeWithOverageInml, out lipidWeightWithOverageIng);

            row = AddRow();
            row.Attributes.Add("RowType", "total");
            row.Cells[0].InnerText = "Total " + PNProductType.Lipid.ToString();
            if (showFullWeight)
                row.Cells[3].InnerText = lipidVolumeWithOverageInml.ToPNFullString(false) + volumeUnits;
            else
                row.Cells[3].InnerText = lipidVolumeWithOverageInml.ToPNString() + volumeUnits;
            row.Cells[4].InnerText = lipidWeightWithOverageIng.IsZero(4) ? "-----" : lipidWeightWithOverageIng.To4SigFigString() + weightUnits;
        }

        // Display the total line
        bool missing = !processor.RegimenItems.All(i => i.GetProduct().SpGrav > 0.0);

        double totalVolumeWithOverage = aqueousOrCombinedVolumeWithOverageInml + lipidVolumeWithOverageInml;
        double totalWeightWithOverage = aqueousOrCombinedWeightWithOverageIng  + lipidWeightWithOverageIng;
        AddSpacerRow("10px");
        row = AddRow();
        row.Attributes.Add("RowType", "total");
        row.Cells[0].InnerHtml = missing ? "<img style=\"width: 15px; height: 15px;\" src=\"../../images/Developer/exclamation_yellow.gif\" />&nbsp;Approximate Total" : "Regimen Total";
        if (showFullWeight)
            row.Cells[3].InnerText = totalVolumeWithOverage.ToPNFullString(false) + volumeUnits;
        else
            row.Cells[3].InnerText = totalVolumeWithOverage.ToPNString() + volumeUnits;
        row.Cells[4].InnerText = totalWeightWithOverage.IsZero(4) ? "-----" : totalWeightWithOverage.To4SigFigString() + weightUnits;
    }

    private void PopulateTableWithProducts(IEnumerable<PNRegimenItem> items, out double totalVolumeWithOverageInml, out double totalWeightWithOverageIng)
    {
        double totalVolume = items.CalculateTotal(PNIngDBNames.Volume);
        if (processor.Regimen.Supply48Hours)
            totalVolume *= 2.0;

        totalVolumeWithOverageInml = 0.0;
        totalWeightWithOverageIng  = 0.0;

        foreach (PNRegimenItem i in items)
        {
            PNProductRow product = i.GetProduct();
            bool hasWeight = product.SpGrav > 0.0;

            double itemVolume = i.VolumneInml * processor.Regimen.SupplyMultiplier;

            HtmlTableRow row = AddRow();
            row.Cells[0].InnerText = product.Description;

            if (showFullWeight)
                row.Cells[1].InnerHtml = itemVolume.ToPNFullString(false) + volumeUnits;
            else
                row.Cells[1].InnerText = itemVolume.ToPNString() + volumeUnits;
            row.Cells[2].InnerText = hasWeight ? (itemVolume * product.SpGrav).To4SigFigString() + weightUnits : "-----";

            double volumeWithOverage = this.processor.CalculateProductOverage(i.PNCode, totalVolume) + itemVolume;  
            double weightWithOverage = hasWeight ? (volumeWithOverage * product.SpGrav) : 0.0;
            if (showFullWeight)
                row.Cells[3].InnerHtml = volumeWithOverage.ToPNFullString(false) + volumeUnits;
            else
                row.Cells[3].InnerText = volumeWithOverage.ToPNString() + volumeUnits;
            row.Cells[4].InnerText = hasWeight ? weightWithOverage.To4SigFigString() + weightUnits : "-----";

            totalVolumeWithOverageInml += volumeWithOverage;
            totalWeightWithOverageIng  += weightWithOverage;
        }
    }

    private HtmlTableRow AddRow()
    {
        HtmlTableRow row = new HtmlTableRow();
        tableVolumeAndWeights.Rows.Add(row);
        for (int c = 0; c < 5; c++)
        {
            HtmlTableCell cell = new HtmlTableCell();
            cell.InnerHtml = "&nbsp;";
            row.Cells.Add(cell);
        }
        row.Cells[0].Style.Add("text-align", "left");
        return row;
    }

    private void AddSpacerRow(string space)
    {
        HtmlTableRow row = new HtmlTableRow();
        tableVolumeAndWeights.Rows.Add(row);
        row.Style.Add("font-size", space);
        
        HtmlTableCell cell = new HtmlTableCell();
        cell.InnerHtml = "&nbsp;";
        row.Cells.Add(cell);
    }
}
