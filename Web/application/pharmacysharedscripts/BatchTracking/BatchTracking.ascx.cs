// -----------------------------------------------------------------------
// <copyright file="BatchTracking.ascx.cs" company="Emis Health">
//   Copyright (c) Emis Health plc. All rights reserved.
// </copyright>
// <summary>
// Control to allow the user enter barcode, expiry, and batch number.
// The control will also allow you to scan in a GS1 data matrix barcode.
// The user can scan the 2D barcode in the main barcode box, and the 
// data will be parsed to the other boxes. Standard EAN-13 character 
// barcodes are also excepted, and the user will have to enter the other 
// batch\expiry info
//
// There are a number of properties to determine how the control behaves
// the main ones to set are
//    BatchTracking - determines the level of data required by the user
//                      0   - Control should not be displayed
//                      1-3 - Just asks for barcode (if user has alternate barcodes)
//                      4   - Asks for barcode (if user has alternate barcodes), batch number, expiry, will also validate with DB
//    NSVCode - nsvcode of the product to check (basically used to validate the barcode)
//
// There are also settings to also force batch number and expiry to be displayed   
//    ShowBatchTracking
//    ShowExpiryDate
//
// On validation apart from requiring the fields to be filled, any further validation
// like checking expiry, validation of batch number, can either be an error or a warning
//
// If the user has filled in all details, and presses enter the form will call client side method batchTrackingReady
//
// Usage
// HTML to add control to the page
// <%@ Register src="../pharmacysharedscripts/BatchTracking/BatchTracking.ascx" tagname="BatchTracking" tagprefix="uc" %>   
// :
// <uc:BatchTracking ID="ucBatchTracking" runat="server" />
//
// To have the control set to always require batch tracking
// Server side
// var product = WProduct.GetByProductAndSiteID("DUX074A", SessionInfo.SiteID);
// ucBatchTracking.BatchTracking = product.BatchTracking;
// ucBatchTracking.NSVCode = product.NSVCode;
// ucBatchTracking.ShowBatchTracking = true;
// ucBatchTracking.Initalise();
// :
// ucBatchTracking.Validate(warnBarcode:=true, warnBatchNumber:=true, warnExpiry:=false, 1, string.Empty);
// var batchNumber = ucBatchTracking.BatchNumber;
// 
//  Modification History:
//  13Jul15 XN Created 39882
//  22Aug16 XN Fixed issues handling cr, and fixed date control 160920
//  25Aug16 XN Fixed expiry date format issue 161049
//  26Aug16 XN Fixed issues 161234 
// </summary
// -----------------------------------------------------------------------
using System;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_pharmacysharedscripts_BatchTracking_BatchTracking : System.Web.UI.UserControl
{
    #region Properties
    /// <summary>Gets or sets the batch tracking level</summary>
    public BatchTrackingType BatchTracking
    {
        get { return hfBatchTracking.Value<BatchTrackingType>(); }
        set { hfBatchTracking.Value = value.ToString();          }
    }

    /// <summary>Gets or sets product NSVCode for batch tracking (used for validation</summary>
    public string NSVCode
    {
        get { return hfNSVCode.Value;  }
        set { hfNSVCode.Value = value; }
    }

    /// <summary>Gets or sets if to show batch tracking</summary>
    public bool? ShowBatchTracking
    {
        get { return hfShowBatchTracking.Value<bool?>();           }
        set { hfShowBatchTracking.Value = value.ToOneZeorString(); }
    }

    /// <summary>Gets or sets if to show expiry date</summary>
    public bool? ShowExpiryDate
    {
        get { return hfShowExpiryDate.Value<bool?>();           }
        set { hfShowExpiryDate.Value = value.ToOneZeorString(); }
    }

    /// <summary>Returns if batch tracking is required (must set other properties first and call Initialise first)</summary>
    public bool IfRequired
    {
        get { return this.BatchTracking == BatchTrackingType.OnReceiptWithExpiryAndConfirm || (this.ShowBatchTracking ?? false) || (this.ShowExpiryDate ?? false) || 
                     (this.BatchTracking >= BatchTrackingType.One && this.IfDrugHasAlternateBarcodes); }
    }

    /// <summary>Gets the batch number (entered by the user)</summary>
    public string BatchNumber
    {
        get { return tbBatchNumber.Text; }
    }

    /// <summary>Gets the expiry date (entered by the user)</summary>
    public DateTime? ExpiryDate
    {
        get { return DateTimeExtensions.PharmacyParse(dpExpiryDate.Text); }
    }
    
    /// <summary>If the drug has alternate barcodes (set in Initialise)</summary>
    private bool IfDrugHasAlternateBarcodes
    {
        get { return BoolExtensions.PharmacyParseOrNull(hfIfDrugHasAlternateBarcodes.Value) ?? false; }
    }
    #endregion

    #region Event Handler
    /// <summary>Called when pages is loaded</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        if (!this.IsPostBack)
        {
            hfConfirmed.Value = string.Empty;
        }

        // Ensure errors are cleared 22Aug16 XN 160920
        this.lbBarcodeError.Text     = string.Empty;
        this.lbBatchNumberError.Text = string.Empty;
        this.lbExpiryError.Text      = string.Empty;

        // Deal with __postBack events
        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];
        
        if (target == this.ClientID)
        {
            string[] argParams = new string[] { string.Empty };
            if (!string.IsNullOrEmpty(args))
                argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);
            string script = string.Empty;

            switch (argParams[0])
            {
            case "BarcodeEntered":      // Enter button pressed on barcode screen so need to decode
                string gtin, batchNumber, error;
                DateTime? expiryDate;
                if (Barcode.ReadBarcode(tbBarcode.Text, out gtin, out expiryDate, out batchNumber, out error))
                {
                    bool is2DBarcode = tbBarcode.Text != gtin;  // Get if 2D barcode (so update batch and expiry)

                    // Set barcode (as different for 2D)
                    if (gtin != null)
                    {
                        tbBarcode.Text = gtin;
                    }

                    // Set batch number
                    if (is2DBarcode)
                    {
                        tbBatchNumber.Text = batchNumber ?? string.Empty;
                    }

                    // Set expiry date
                    if (expiryDate != null)
                    {
                        dpExpiryDate.Text = expiryDate.ToPharmacyDateString();
                    }
                    else if (is2DBarcode)
                    {
                        dpExpiryDate.Text = "";
                    }
                    else
                    {
                        // try reading from DB if proper batch tracking
                        this.PopulateExpiry(); 
                    }
                    
                    if (is2DBarcode || !tbBatchNumber.Visible)
                        script = "if (typeof(batchTrackingReady) === 'function'){ batchTrackingReady(); }";
                    else
                        script = string.Format("$('#{0}').focus();", tbBatchNumber.ClientID);
                }
                else
                {
                    lbBarcodeError.Text = "Invalid";
                    script = string.Format("$('#{0}').focus();", tbBarcode.ClientID);
                }
                break;

            case "BatchNumberEntered":
                {
                // User pressed enter on batch tracking number so try reading expiry from DB
                this.PopulateExpiry();
                if (!dpExpiryDate.Visible)
                    script = "if (typeof(batchTrackingReady) === 'function') { batchTrackingReady(); }";
                else
                    script = string.Format("$('#{0}').focus();", dpExpiryDate.ClientID);
                }
                break;
            }

            if (!string.IsNullOrEmpty(script))
                ScriptManager.RegisterStartupScript(this, this.GetType(), "focus", "setTimeout(function() { " + script + "}, 100);", true);
        }
    }

    /// <summary>Pre render</summary>
    /// <param name="sender">The sender</param>
    /// <param name="e">The args</param>
    protected void Page_PreRender(object sender, EventArgs e)
    {
        // Setup barcode control
        tbBarcode.Attributes.Add("onkeydown", string.Format("if (event.keyCode==13) {{ __doPostBack('{0}','BarcodeEntered'); window.event.cancelBubble = true; return false; }};", this.ClientID));
        tbBarcode.Attributes.Add("onfocus", string.Format("$('#{0}').select();", tbBarcode.ClientID));

        // Setup batch number control
        tbBatchNumber.Attributes.Add("onkeydown", string.Format("if (event.keyCode==13) {{ __doPostBack('{0}','BatchNumberEntered'); window.event.cancelBubble = true; return false; }}", this.ClientID));
        tbBatchNumber.Attributes.Add("onfocus", string.Format("$('#{0}').select();", tbBatchNumber.ClientID));

        // Setup expiry control
        dpExpiryDate.Attributes.Add("onkeydown", "if (event.keyCode==13 && typeof(batchTrackingReady)==='function') { batchTrackingReady(); }");
        string script = string.Format("$('#{0}').datepicker({{ showOn:'both', buttonImage: '../../images/ocs/show-calendar.gif', buttonImageOnly: true, dateFormat: 'dd/mm/yy' }});", dpExpiryDate.ClientID);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "setexpiry", script, true);

        trBarcode.Visible = this.IfDrugHasAlternateBarcodes;

        // Set if batch number is visible
        if (this.ShowBatchTracking == null)
            trBatchNumber.Visible = (this.BatchTracking >= BatchTrackingType.OnReceiptWithExpiryAndConfirm);
        else
            trBatchNumber.Visible = this.ShowBatchTracking.Value;

        // Setup expiry control
        if (this.ShowExpiryDate == null)
            trExpiryDate.Visible = (this.BatchTracking >= BatchTrackingType.OnReceiptWithExpiryAndConfirm);
        else
            trExpiryDate.Visible = this.ShowExpiryDate.Value;
    }
    #endregion

    #region Public methods
    /// <summary>Initialise the control when first displayed</summary>
    public void Initalise()
    {
        // Set focus to first visible box
        string script = string.Format("setTimeout(function() {{ $('input[id^={0}]:visible').first().focus(); }}, 100);", this.ClientID);
        ScriptManager.RegisterStartupScript(this, this.GetType(), "setFocus", script, true);

        hfConfirmed.Value                  = string.Empty;
        hfIfDrugHasAlternateBarcodes.Value = SiteProductData.GetBySiteIDAndNSVCode(SessionInfo.SiteID, this.NSVCode).GetAlternativeBarcode().Any().ToOneZeorString();
    }

    /// <summary>
    /// Validate the control, validation can be error or warning depending on method inputs.
    /// Performs the following validation
    /// 1. Barcode is filled in (error)
    /// 2. Barcode is correct length 8, 13, 14 (error)
    /// 3. Barcode has matching DB drug (optional error or warning)
    /// 4. Expiry is filled in (error)
    /// 5. Expiry has not expired (optional error or warning)
    /// 6. Batch number is filled in (error)
    /// 7. Batch number if test it exists in DB (optional error or warning)
    /// 8. Batch number if read required number of packs (optional error or warning)
    /// </summary>
    /// <param name="warnBarcode">Warn if barcode not in db (else errors)</param>
    /// <param name="warnBatchNumber">Warn if batch number not in db or not enough packs (else errors)</param>
    /// <param name="warnExpiry">Warn if expired (else errors)</param>
    /// <param name="requiredQuantityInPacks">Required qty</param>
    /// <param name="clientPostBackOnWarning">javascript event to run if warning are displayed and user accepts (e.g. $('#btnNext').click();</param>
    /// <returns>If control is valid</returns>
    public bool Validate(bool warnBarcode, bool warnBatchNumber, bool warnExpiry, double? requiredQuantityInPacks, string clientPostBackOnWarning)
    {
        ErrorWarningList errors = new ErrorWarningList();
        Control focusOnMe = null;
        bool valid = true;
        string error;

        // Check barcode
        if (tbBarcode.Visible && !Validation.ValidateText(tbBarcode, string.Empty, typeof(string), true, out error))
        {
            // Not filled in
            lbBarcodeError.Text = error;
            focusOnMe = this.tbBarcode;
            valid = false;
        }
        else if (tbBarcode.Visible && !Barcode.ValidateGTINBarcode(tbBarcode.Text, false, out error))
        {
            // Not correct length?
            lbBarcodeError.Text = error;
            focusOnMe = this.tbBarcode;
            valid = false;
        }
        else if (tbBarcode.Visible)
        {
            // Not matching DB drug
            ProductSearchType searchType = ProductSearchType.Barcode;
            WProduct product = ProductSearch.DoSearch(tbBarcode.Text, ref searchType, false, SessionInfo.SiteID);

            // Optional error or warning
            if (!product.Any() || !product.Any(p => p.NSVCode.EqualsNoCaseTrimEnd(this.NSVCode)))
            {
                if (warnBarcode)
                    errors.AddWarning("Barcode not valid for drug");
                else
                {
                    lbBarcodeError.Text = "Barcode not valid for drug";
                    focusOnMe = this.tbBarcode;
                    valid = false;
                }
            }
        }

        // Check expiry date
        if (dpExpiryDate.Visible && !Validation.ValidateText(dpExpiryDate, string.Empty, typeof(DateTime), true, out error))
        {
            // Not filled in
            focusOnMe = focusOnMe ?? this.dpExpiryDate;
            lbExpiryError.Text = "Please enter";
            valid = false;
        }
        else if (dpExpiryDate.Visible && this.ExpiryDate < DateTime.Now)
        {
            // Has expired
            if (warnExpiry)
                errors.AddWarning("Has expired");
            else
            {
                lbExpiryError.Text = "Has expired";
                focusOnMe = focusOnMe ?? this.dpExpiryDate;
                valid = false;
            }
        }

        // Check batch tracking
        if (tbBatchNumber.Visible && !Validation.ValidateText(tbBatchNumber, string.Empty, typeof(string), true, out error))
        {
            // Not filled in
            focusOnMe = focusOnMe ?? this.tbBatchNumber;
            lbBatchNumberError.Text = error;
            valid = false;
        }
        else if (tbBatchNumber.Visible && this.BatchTracking == BatchTrackingType.OnReceiptWithExpiryAndConfirm)
        {
            // Check if exists in DB
            WBatchStockLevel batchStockLevel = new WBatchStockLevel();
            batchStockLevel.LoadBySiteIDNSVCodeAndBatchNumber(SessionInfo.SiteID, this.NSVCode, tbBatchNumber.Text, false);

            if (!batchStockLevel.Any())
                errors.AddWarning("Invalid batch number");
            else if (requiredQuantityInPacks != null && (batchStockLevel.Sum(r => r.QuantityInPacks) - requiredQuantityInPacks) < 0.0)
                errors.AddWarning("Not enough batch stock");
        }

        // If warning the show warning messages
        if (valid && BoolExtensions.PharmacyParseOrNull(hfConfirmed.Value) != true && errors.Any())
        {
            string script = string.Format("confirmEnh(\"{0}<br />Do you want to continue?\", false, function(){{ $('input[id$=hfConfirmed]').val('1'); {1} }});", errors.ToHtml(), clientPostBackOnWarning);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "confirmBatchTracking", script, true);
            valid = false;
        }

        // Set correct control to have focus
        if (focusOnMe != null)
        {
            string script = string.Format("setTimeout(function() {{ $('#{0}').focus(); }}, 110);", focusOnMe.ClientID);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "setFocus", script, true);
        }

        return valid;
    }

    /// <summary>Clears the settings in the control</summary>
    public void Clear()
    {
        this.lbBarcodeError.Text     = string.Empty;
        this.lbBatchNumberError.Text = string.Empty;
        this.lbExpiryError.Text      = string.Empty;
        this.tbBarcode.Text          = string.Empty;
        this.tbBatchNumber.Text      = string.Empty;
        this.dpExpiryDate.Text       = string.Empty;
    }
    #endregion

    #region Private Methods
    /// <summary>Populate expiry from value in batch stock level</summary>
    private void PopulateExpiry()
    {
        // If no batch tracking or not enabled for product then don't populate expiry
        if (string.IsNullOrEmpty(tbBatchNumber.Text) || this.BatchTracking != BatchTrackingType.OnReceiptWithExpiryAndConfirm)
        {
            return;            
        }

        // Read expiry
        WBatchStockLevel batchStockLevel = new WBatchStockLevel();
        batchStockLevel.LoadBySiteIDNSVCodeAndBatchNumber(SessionInfo.SiteID, this.NSVCode, tbBatchNumber.Text, false);

        // set expiry
        if (batchStockLevel.Any(r => r.ExpiryDate.HasValue))
        {
            dpExpiryDate.Text = batchStockLevel.Where(r => r.ExpiryDate.HasValue).Min(r => r.ExpiryDate.Value).ToPharmacyDateString();
        }
    }
    #endregion
}