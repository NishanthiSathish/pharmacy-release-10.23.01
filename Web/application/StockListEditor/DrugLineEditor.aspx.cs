// --------------------------------------------------------------------------------------------------------------------
// <copyright file="DrugLineEditor.aspx.cs" company="Ascribe Ltd">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
//  Allows adding\editing of drug line
//
//  When saved the data will not be saved to the DB, instead the ward stock list controller will be returned (change save to cache)
//       
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - (optional) Pharmacy site
//  SiteID              - (optional) Pharmacy site (if a site parameter is not supplied will display drop down list for user to choose)
//  controller          - JSON WardStockListController class
//  AddMode             - true to add else will be edit mode
//  AboveOrBelow        - If in add mode, the if to add 'above' or 'below' currently selected line
//  NSVCode             - (optional) NSVCode of drug (when adding new one)
//
//  The page will return the  ward stock list controller as json string, else return undefined if user cancelled
//      
//  Modification History:
//  11Feb15 XN  Created
//  25Mar15 XN  114612 attempt to fix position of revert icons on initial resize
//  01Apr15 XN  Unescaped control parameter 115152 (else page will not display in HTAless mode) 
//  12Aug16 XN  160086 Validation check qty x pack size not too large for vb6 long value 
// </summary>
// --------------------------------------------------------------------------------------------------------------------

using System;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.wardstocklistlayer;

/// <summary>The application_StockListEditor_DrugLineEditor line editor.</summary>
public partial class application_StockListEditor_DrugLineEditor : System.Web.UI.Page
{
    /// <summary>JSON WardStockListController class as string</summary>
    private string controllerStr;

    /// <summary>If adding</summary>
    private bool addMode;    

    /// <summary>NSV code of drug to add</summary>
    private string NSVCode;
    
    /// <summary>If in add mode, the if to add 'above' or 'below' currently selected line</summary>
    private string aboveOrBelow;

    /// <summary>Load event handler</summary>
    /// <param name="sender">event send</param>
    /// <param name="e">event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        this.controllerStr = (this.Request["controller"] ?? string.Empty).Replace(WardStockListController.UrlParameterEscapeChar, "."); //  01Apr15 XN  Unescaped control parameter 115152 (else page will not display in HTAless mode)
        this.addMode       = this.Request["AddMode"].EqualsNoCaseTrimEnd("true");
        this.NSVCode       = this.Request["NSVCode"];
        this.aboveOrBelow  = this.Request["AboveOrBelow"];

        if (this.IsPostBack)
        {
            this.LoadAscribeCoreControlsToViewState(); // Load manually cached ascribe core controls extra data
        }
        else
        {
            this.Populate();
            this.SaveAscribeCoreControlsToViewState(); // Cache ascribe core controls extra data
        }

        // Added code into ready doc to try to fix position of revert icons on initial resize 25Mar15 XN 114612
        ScriptManager.RegisterStartupScript(this, this.GetType(), "resizeControl", "$(document).ready(function() { drugLineEditor_onresize(); });", true);
    }

    /// <summary>
    /// Called when the revert image is clicked
    /// Reverts the product description, or pack size
    /// </summary>
    /// <param name="sender">event send</param>
    /// <param name="e">event args</param>
    protected void imgRevert_OnClick(object sender, EventArgs e)
    {
        WProductRow product = WProduct.GetByProductAndSiteID(this.NSVCode, SessionInfo.SiteID);
        if (sender == this.imgRevertDescription)
        {
            this.tbDescription.Value = product.ToString();
        }
        else if (sender == this.imgRevertPackSize)
        {
            this.numPackSize.Value = product.ConversionFactorPackToIssueUnits;
        }
    }

    /// <summary>
    /// Called when cancel button is clicked 
    /// Closes the form
    /// </summary>
    /// <param name="sender">event send</param>
    /// <param name="e">event args</param>
    protected void btnCancel_OnClick(object sender, EventArgs e)
    {
        this.ClosePage();
    }

    /// <summary>
    /// Called when ok button is clicked
    /// Validates and saved the data
    /// </summary>
    /// <param name="sender">event send</param>
    /// <param name="e">event args</param>
    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        if (this.Validate())
        {
            this.Save();
        }
    }

    /// <summary>Populates the page</summary>
    private void Populate()
    {
        WardStockListController        controller = WardStockListController.Create(controllerStr);
        WWardProductListLineColumnInfo columnInfo = WWardProductListLine.GetColumnInfo();
        WProductRow                    product    = WProduct.GetByProductAndSiteID(this.NSVCode, SessionInfo.SiteID);
        WWardProductListLineRow        row        = addMode ? (new WWardProductListLine()).Add(product) : controller.GetSelectedLine();

        lbInfo.Text = this.NSVCode + " - " + product;
        tbDescription.Value        = row.ToString();
        tbDescription.MaxCharacters= columnInfo.DescriptionLength;

        numPackSize.MaxCharacters  = 5;
        numPackSize.Value          = row.GetConversionFactorPackToIssueUnits();
        numPackSize.Suffix         = string.Format("{0} ({1} {0})", product.PrintformV, product.ConversionFactorPackToIssueUnits);

        numQuantity.MaxCharacters  = 5;
        numQuantity.Value          = row.TopupLvl;

        bool DLOAllowed = Settings.AllowDLO && controller.WardStockList[0].PrintPickTicket;
        lDLOLabel.Caption = DLOAllowed ? "Label /DLO" : "Print Label";
        lDLOLabel.Items.Add(new ListItem("<None>",      PrintLabelType.NoLabel.ToString()));
        lDLOLabel.Items.Add(new ListItem("Print Label", PrintLabelType.PrintLabel.ToString()));
        if (DLOAllowed)
            lDLOLabel.Items.Add(new ListItem("DLO",  PrintLabelType.DLO.ToString()));
        lDLOLabel.SelectedIndex = EnumExtensions.EnumIndexInListView(lDLOLabel.Items, row.PrintLabel);

        tbComment.MaxCharacters= columnInfo.CommentLength;
        tbComment.Value = row.Comment;

        tbDescription.Focus();
    }

    /// <summary>Validate the control</summary>
    /// <returns>If data is valid</returns>
    private bool Validate()
    {
        WWardProductListLineColumnInfo columnInfo = WWardProductListLine.GetColumnInfo();
        bool ok = true;
        string error;

        if (!Validation.ValidateText(this.tbDescription, string.Empty, typeof(string), tbDescription.Mandatory, columnInfo.DescriptionLength, out error))
            ok = false;
        tbDescription.ErrorMessage = error;

        if (!Validation.ValidateText(this.numPackSize, string.Empty, typeof(string), numPackSize.Mandatory, columnInfo.PackSizeMin, columnInfo.PackSizeMax, out error))
            ok = false;
        numPackSize.ErrorMessage = error;

        if (!Validation.ValidateText(this.numQuantity, string.Empty, typeof(string), numQuantity.Mandatory, columnInfo.TopupLvlMin, columnInfo.TopupLvlMax, out error))
            ok = false;
        numQuantity.ErrorMessage = error;

        if (!Validation.ValidateText(this.tbComment, string.Empty, typeof(string), tbComment.Mandatory, columnInfo.CommentLength, out error))
            ok = false;
        tbComment.ErrorMessage = error;

        // Check qty x pack size not too large for vb6 long value  160086 XN 12Aug16
        if (ok && (this.numQuantity.Value * this.numPackSize.Value) > int.MaxValue)
        {
            numQuantity.ErrorMessage = "Qty x Pack size too large";
            ok = false;
        }

        return ok;
    }

    /// <summary>Save page data</summary>
    private void Save()
    {
        WardStockListController controller  = WardStockListController.Create(this.controllerStr);
        WProductRow             product     = WProduct.GetByProductAndSiteID(this.NSVCode, SessionInfo.SiteID);
        WWardProductListLine    lines       = new WWardProductListLine();

        WWardProductListLineRow row = lines.Add(product);
        if (!this.addMode)
        {
            row.CopyFrom(controller.GetSelectedLine());
        }

        row.Description                     = tbDescription.RawValue;
        row.ConversionFactorPackToIssueUnits= (int?)numPackSize.Value;  
        row.TopupLvl                        = (int)numQuantity.Value.Value;
        row.PrintLabel                      = (PrintLabelType)Enum.Parse(typeof(PrintLabelType), lDLOLabel.SelectedValue);
        row.Comment                         = tbComment.RawValue;

        if (this.addMode)
        {
            controller.AddLines(lines, new[] { product }, ref this.aboveOrBelow);
        }
        else
        {
            controller.UpdateLine(row, product);
        }

        this.ClosePage(controller.SaveToCache());
    }
}