//===========================================================================
//
//					  	     PNSelectProudct.aspx.cs
//
//  Control used in the PN add product wizard to allow selection of PN Product
//  Product are displayed in grid with Product name, and volume in regimen
//
//  Validation of control is done server side via java method PNSelectProduct_validation
//
//	Modification History:
//	15Nov11 XN  Written
//  23May12 XN  Prevented XML escape of product decription columns so can display '
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.parenteralnutritionlayer;

public partial class application_PNViewAndAdjust_controls_PNSelectProduct : System.Web.UI.UserControl, IPNWizardCtrl
{
    protected void Page_Load(object sender, EventArgs e) { }

    /// <summary>Inialise list of products</summary>
    /// <param name="products">list of products to display</param>
    /// <param name="regimenItems">Irems in the regimen</param>
    /// <param name="caption">Caption to display along top of page</param>
    /// <param name="multiplyVolumesFor48Hours">If values values display in list are to be double for 48Hr bag</param>
    public void Initalise(IEnumerable<PNProductRow> products, IEnumerable<PNRegimenItem> regimenItems, string caption, bool multiplyVolumesFor48Hours)
    {
        string volumeUnits = PNIngredient.GetInstance().FindByDBName(PNIngDBNames.Volume).GetUnit().Abbreviation;

        lbCaption.Text = caption;

        gridSelectProduct.AddColumn("Product", 65, PharmacyGridControl.ColumnType.Text);
        gridSelectProduct.ColumnXMLEscaped(0, false);   // 23May12 XN Fix to allow correct display of '
        if (multiplyVolumesFor48Hours)
            gridSelectProduct.AddColumn("Volume for 48Hrs",  35, PharmacyGridControl.ColumnType.Text);
        else
            gridSelectProduct.AddColumn("Volume for 24Hrs",  35, PharmacyGridControl.ColumnType.Text);
        gridSelectProduct.SortableColumns = true;

        foreach (PNProductRow product in products)
        {
            gridSelectProduct.AddRow();
            gridSelectProduct.AddRowAttribute("PNCode", product.PNCode);
            gridSelectProduct.SetCell(0, product.ToString());

            PNRegimenItem item = regimenItems.FindByPNCode(product.PNCode);
            if (item == null)
                gridSelectProduct.SetCell(1, string.Empty);
            else
            {
                double volume = item.VolumneInml;
                if (multiplyVolumesFor48Hours)
                    volume *= 2.0;
                gridSelectProduct.SetCell(1, volume.ToPNString() + " " + volumeUnits);
            }
        }

        // Select first row by default
        if (gridSelectProduct.RowCount > 0)
        {
            string script = string.Format("selectRow('{0}', 0);", gridSelectProduct.ID);
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "InitProductGrid", script, true);
        }
    }

    /// <summary>Returns the selected PN product</summary>
    /// <returns>Selected PN product</returns>
    public PNProductRow GetSelectedProduct()
    {
        return PNProduct.GetInstance().FindByPNCode(hfSelectedProductPNCode.Value);
    }

    public void SetSelectedProduct(PNProductRow product)
    {
        if (product != null)
            hfSelectedProductPNCode.Value = product.PNCode;
    }

    #region IPNWizardCtrl Members
    public void Initalise() 
    { 
        hfSelectedProductPNCode.Value = string.Empty;
    }

    public int? RequiredHeight { get { return 450; } }

    public void Focus() 
    {
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "PNSelectProductFocus", string.Format("$('#{0}').focus();", gridSelectProduct.ID), true);
    }

    public bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info) { return true; }
    #endregion 
}
