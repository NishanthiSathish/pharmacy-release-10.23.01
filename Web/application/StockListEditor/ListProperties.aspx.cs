// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ListProperties.aspx.cs" company="Ascribe Ltd">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
//  Allows editing of stock list properties. 
//
//  When saved the data will not be saved to the DB, but will be returned as XML
//       
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  AscribeSiteNumber   - (optional) Pharmacy site
//  SiteID              - (optional) Pharmacy site (if a site parameter is not supplied will display drop down list for user to choose)
//  controller          - JSON WardStockListController class
//  mode                - If add or edit
//  VisibleToWard       - If the visible to ward option is enabled by default
//
//  The page will return the WWardProductList class as XML, or undefined
//      
//  Modification History:
//  22Jun14 XN  Written 43318
//  22Jan15 XN  To prevent error messages reappearing during postback moved update ward, and clear option, client side 108208
//  01Apr15 XN  Unescaped control parameter 115152 (else page will not display in HTAless mode) 
// </summary>
// --------------------------------------------------------------------------------------------------------------------

using System;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.wardstocklistlayer;

public partial class application_StockListEditor_ListProperties : System.Web.UI.Page
{
    #region Member Variables
    /// <summary>Ward stock list being edited</summary>
    private WWardProductList wardProductList;

    /// <summary>If page is in add mode</summary>
    private bool addMode;
    #endregion

    #region Event Handlers
    /// <summary>Called when page loads</summary>
    /// <param name="sender">Who called</param>
    /// <param name="e">Event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        string controllerStr = (this.Request["controller"] ?? string.Empty).Replace(WardStockListController.UrlParameterEscapeChar, ".");   //  01Apr15 XN  Unescaped control parameter 115152 (else page will not display in HTAless mode)
        this.addMode         = Request["mode"].EqualsNoCase("add");

        // Get the ward stock list
        if (this.addMode || string.IsNullOrEmpty(controllerStr))
        {
            // Adding so create new stock list
            this.wardProductList = new WWardProductList();
            this.wardProductList.Add();

            // Get default ward state
            bool? visibleToWard = BoolExtensions.PharmacyParseOrNull(Request["VisibleToWard"]);
            if (visibleToWard != null)
            {
                this.wardProductList[0].VisibleToWard = visibleToWard.Value;
            }
        }
        else
        {
            // Load existing ward stock list
            this.wardProductList = WardStockListController.Create(controllerStr).WardStockList;
        }

        this.Title = this.addMode ? "New Stock List" : "Edit Stock List Properties";

        if (this.IsPostBack)
        {
            this.LoadAscribeCoreControlsToViewState(); // Load manually cached ascribe core controls extra data
        }
        else
        {
            this.Populate(this.wardProductList.First());
            this.SaveAscribeCoreControlsToViewState(); // Save manually cached ascribe core controls extra data
        }
    }

    /// <summary>Called before page render</summary>
    /// <param name="sender">Who called</param>
    /// <param name="e">Event args</param>
    protected void Page_PreRender(object sender, EventArgs e)
    {
        // Update control state of cbVisibleToLocation as changed client side as well and does not maintain view state
        // so done using style rather than visible property so always sent to client.
        cbVisibleToLocation.Style[HtmlTextWriterStyle.Display] = string.IsNullOrEmpty(hfWCustomerID.Value) ? "none" : string.Empty;
    }

    /// <summary>
    /// Called when OK button is clicked
    /// Validates the page, and saves and closes form
    /// </summary>
    /// <param name="sender">Who called</param>
    /// <param name="e">Event args</param>
    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        if (this.Validate())
        {
            this.Save();
            this.ClosePage(this.wardProductList.WriteXml());            
        }
    }

    /// <summary>
    /// Called when cancel button is clicked
    /// Close the form
    /// </summary>
    /// <param name="sender">Who called</param>
    /// <param name="e">Event args</param>
    protected void btnCancel_OnClick(object sender, EventArgs e)
    {
        this.ClosePage();
    }
    #endregion

    #region Private Methods
    /// <summary>Populate the page</summary>
    /// <param name="row">Ward stock list row</param>
    private void Populate(WWardProductListRow row)
    {
        WWardProductListColumnInfo columnInfo   = WWardProductList.GetColumnInfo();

        tbCode.MaxCharacters            = columnInfo.CodeLength;
        tbCode.Value                    = row.Code;
        tbCode.ReadOnly                 = !this.addMode;
        tbShortName.MaxCharacters       = columnInfo.DescriptionLength;
        tbShortName.Value               = row.Description;
        tbFullName.MaxCharacters        = columnInfo.FullNameLength;
        tbFullName.Value                = row.FullName;
        cbPrintPickingTicket.Checked    = row.PrintPickTicket;
        cbPrintDeliveryNote.Checked     = row.PrintDeliveryNote;
        cbInUse.Checked                 = row.InUse;
        cbOnlyAvailableToSite.Checked   = row.SiteID.HasValue;
        cbOnlyAvailableToSite.Caption   = string.Format(cbOnlyAvailableToSite.Caption, SessionInfo.SiteNumber);
        cbOnlyAvailableToSite.ReadOnly  = !this.addMode;
        cbVisibleToLocation.Checked     = row.VisibleToWard;

        txtLocationDescription.MaxCharacters = 500;
        txtLocationDescription.Controls.OfType<TextBox>().First().Attributes.Add("readonly", "readonly");
        txtLocationDescription.Attributes["onkeyup"] = "if (event.keyCode == 13) { btnLocation_OnClick(); }";

        WCustomerRow customer = (row.WCustomerID == null) ? null : WCustomer.GetByID(row.WCustomerID.Value);
        txtLocationDescription.Value = customer == null ? string.Empty : customer.ToString();
        hfWCustomerID.Value          = customer == null ? string.Empty : customer.WCustomerID.ToString();
        hfWCustomerCode.Value        = customer == null ? string.Empty : customer.Code;
        lblNotInUse.Visible          = customer != null && !customer.InUse;
    }

    /// <summary>Validates the page</summary>
    /// <returns>If valid</returns>
    private bool Validate()
    {
        bool ok = true;
        string error = string.Empty;
        WWardProductListColumnInfo columnInfo = WWardProductList.GetColumnInfo();

        int? listSiteID = cbOnlyAvailableToSite.Checked ? SessionInfo.SiteID : (int?)null;

        // Code
        if (this.addMode)
        {
            if (!Validation.ValidateText(this.tbCode, string.Empty, typeof(string), true, columnInfo.CodeLength, out error))
            {
                ok = false;
            }
            else if (WWardProductList.GetBySiteCodeAndInUse(listSiteID, tbCode.RawValue.ToUpper(), true) != null)
            {
                error = "Code already exists";
                ok = false;
            }
            else if (WWardProductList.GetBySiteCodeAndInUse(listSiteID, tbCode.RawValue.ToUpper(), false) != null)
            {
                error = "Code already exists (for an out of use list)";
                ok = false;
            }
            
            this.tbCode.ErrorMessage = error;
        }

        // Short name
        if (!Validation.ValidateText(this.tbShortName, string.Empty, typeof(string), true, columnInfo.DescriptionLength, out error))
        {
            ok = false;
        }
        
        this.tbShortName.ErrorMessage = error;

        // Full name
        if (!Validation.ValidateText(this.tbFullName, string.Empty, typeof(string), true, columnInfo.FullNameLength, out error))
        {
            ok = false;
        }
        
        this.tbFullName.ErrorMessage = error;

        return ok;
    }

    /// <summary>Save data to wardProductList</summary>
    private void Save()
    {
        WWardProductListRow row = this.wardProductList.First();

        if (this.addMode)
        {
            row.Code   = tbCode.RawValue.ToUpper();
            row.SiteID = cbOnlyAvailableToSite.Checked ? SessionInfo.SiteID : (int?)null;
        }
        
        row.Description         = tbShortName.RawValue;
        row.FullName            = tbFullName.RawValue;
        row.PrintPickTicket     = cbPrintPickingTicket.Checked;
        row.PrintDeliveryNote   = cbPrintDeliveryNote.Checked;
        row.WCustomerID         = string.IsNullOrWhiteSpace(hfWCustomerID.Value) ? (int?)null : int.Parse(hfWCustomerID.Value);
        row.VisibleToWard       = !string.IsNullOrWhiteSpace(hfWCustomerID.Value) && cbVisibleToLocation.Checked;
        row.InUse               = cbInUse.Checked;
    }
    #endregion
}