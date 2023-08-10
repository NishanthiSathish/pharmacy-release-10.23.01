// --------------------------------------------------------------------------------------------------------------------
// <copyright file="TitleLineEditor.aspx.cs" company="Ascribe Ltd">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
//  Allows adding\editing of title line
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
//
//  The page will return the  ward stock list controller as json string, else return undefined if user cancelled
//      
//  Modification History:
//  11Feb15 XN  Created
//  01Apr15 XN  Unescaped control parameter 115152 (else page will not display in HTAless mode) 
// </summary>
// --------------------------------------------------------------------------------------------------------------------

using System;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.wardstocklistlayer;

/// <summary>The application_ stock list editor_ title line editor.</summary>
public partial class application_StockListEditor_TitleLineEditor : System.Web.UI.Page
{
    /// <summary>JSON WardStockListController class as string</summary>
    private string controllerStr;

    /// <summary>If adding</summary>
    private bool addMode;   
 
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
    }

    /// <summary>Called when cancel button is clicked (closed the page)</summary>
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
        WardStockListController controller = WardStockListController.Create(this.controllerStr);
        WWardProductListLineColumnInfo columnInfo = WWardProductListLine.GetColumnInfo();
        WWardProductListLineRow row = this.addMode ? (new WWardProductListLine()).Add() : controller.GetSelectedLine();

        if (this.addMode)
        {
            frmMain.Caption = "Add section header";
        }
        else
        {
            frmMain.Caption = "Edit section header";
        }

        tbTitle.MaxCharacters = columnInfo.DescriptionLength;
        tbTitle.Value         = row.Description;
        tbTitle.Focus();
    }

    /// <summary>Validate the control</summary>
    /// <returns>If data is valid</returns>
    private bool Validate()
    {
        WWardProductListLineColumnInfo columnInfo = WWardProductListLine.GetColumnInfo();
        bool ok = true;
        string error;

        // Title
        if (!Validation.ValidateText(this.tbTitle, string.Empty, typeof(string), tbTitle.Mandatory, columnInfo.DescriptionLength, out error))
        {
            ok = false;
        }
        
        tbTitle.ErrorMessage = error;

        return ok;
    }

    /// <summary>Save page data</summary>
    private void Save()
    {
        WardStockListController controller = WardStockListController.Create(this.controllerStr);

        // Create temporary line (easy for the add mode, so can use the controller to do the proper add or update
        WWardProductListLine lines = new WWardProductListLine();        
        WWardProductListLineRow row = lines.Add();
        if (!this.addMode)
        {
            row.CopyFrom(controller.GetSelectedLine());
        }

        // Fill in data
        row.Description = tbTitle.RawValue;

        // Perform the add or update
        if (this.addMode)
        {
            controller.AddLines(lines, null, ref this.aboveOrBelow);
        }
        else 
        {
            controller.UpdateLine(row, null);
        }

        // Cache and return
        this.ClosePage(controller.SaveToCache());
    }
}