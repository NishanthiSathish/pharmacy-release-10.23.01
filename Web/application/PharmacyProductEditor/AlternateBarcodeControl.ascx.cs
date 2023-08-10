//===========================================================================
//
//					      AlternateBarcodeControl.aspx.cs
//  
//  Allows users to add or remove alternate barcodes.
//
//  These are saved to SiteProductDataAlais as alias group AlternativeBarcode.
//  Unlike other alias there maybe many alternate barcodes per a SiteProductData row
//  
//  The control supports the IQuesScrlControl interface for easy plug into 
//  Pharmacy Product Editor.  
//
//  Control relies on QuesScrl.js
//    
//	Modification History:
//  29Jan14	XN 82431 Created
//  30Jul15 XN 124288 Got it to mark page dirty when updated
//  18Jul16 XN 126634 Added supplort for supplier edi barcode
//  10Oct16 XN 164388 Show all profiles that use the EDI barcode, and update warning
//  31Jan18 DR 203755 Alternative Barcode from Pharmacy product editor wording
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;
using _Shared;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;
using System.Web.UI;
using Newtonsoft.Json;

public partial class application_PharmacyProductEditor_AlternateBarcodeControl : System.Web.UI.UserControl, IQSViewControl
{
    #region Private Variables
    /// <summary>Use QSProcessor to get the processor</summary>
    private WProductQSProcessor qsprocessor;
    #endregion

    #region Private Properties
    /// <summary>Gets access to the QSProcessor (cached on page)</summary>
    private WProductQSProcessor QSProcessor
    {
        get 
        { 
            if (qsprocessor == null)
                qsprocessor = QSBaseProcessor.Create(hfQSProcessor.Value) as WProductQSProcessor;
            return qsprocessor;  
        }
        set 
        { 
            qsprocessor = value;
            hfQSProcessor.Value = qsprocessor.WriteXml();
        }
    }
    
    /// <summary>Cached list of alternate barcodes 18Jul16 XN 126634</summary>
    private IEnumerable<string> AlternateBarcodes
    {
        get { return this.hfAlternateBarcodes.Value.ParseCSV<string>(",", ignoreErrors: false); }
        set { this.hfAlternateBarcodes.Value = value.ToCSVString(",");                          }
    }
    
    /// <summary>Cached list of supplier profiles 18Jul16 XN 126634</summary>
    private WSupplierProfile SupplierProfiles
    {
        get 
        {
            var supplierProfile = new WSupplierProfile();
            supplierProfile.ReadXml(this.hfSupplierProfiles.Value); 
            return supplierProfile; 
        }
        set { this.hfSupplierProfiles.Value = value.WriteXml();                       }
    }
    #endregion

    #region Public Methods
    /// <summary>Initialise the control</summary>
    public void Initalise(string NSVCode)
    {
        WProduct products = new WProduct();
        products.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);

        WSupplierProfile supplierProfile = new WSupplierProfile();
        //supplierProfile.LoadBySiteIDAndNSVCode(SessionInfo.SiteID, NSVCode); 10Oct16 XN 164388 
        supplierProfile.LoadByNSVCode(NSVCode);
        this.SupplierProfiles = supplierProfile;

        this.QSProcessor = new WProductQSProcessor(products, new [] { SessionInfo.SiteID });

        spPrimaryBarcode.InnerText = products.First().Barcode;
        //PopulateAlternateBarcodes(products.First().GetAlternativeBarcode().Distinct(), supplierProfile.Select(s => s.EdiBarcode).Distinct());  10Oct16 XN 164388 
        PopulateAlternateBarcodes(products.First().GetAlternativeBarcode().Distinct());

        this.tbBarcode.Text = string.Empty;
    }
    #endregion

    #region Event Handlers
    protected void Page_PreRender(object sender, EventArgs e)
    {
        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];

        // Deal with __postBack events
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args) && this.GetAllControlsByType<Control>().Any(up => up.ClientID == target))
            argParams = args.Split(new char[] { ':' });

        switch (argParams[0])
        {
        case "Save": 
            SaveData(); 
            break;
        }

        // Ensure that the list is repopulated as data is not cached
        if (this.abcGrid.ColumnCount == 0)
            PopulateAlternateBarcodes(this.AlternateBarcodes);
        // PopulateAlternateBarcodes(this.AlternateBarcodes, this.SupplierEdiBarcodes); 10Oct16 XN 164388 

        // Ensure row in the list is selected
        hfSuppressClearError.Value = "1";   // when user changes barcode it clears the error, so bit of issue on post back so suppress this 10Oct16 XN 164388 
        int selectedIndex = Math.Max(abcGrid.FindIndexByAttrbiuteValue("Barcode", this.hfSelectedBarcode.Value), 0);
        abcGrid.SelectRow(selectedIndex);

        this.tbBarcode.Attributes["onfocus"] = "this.select();";
        ScriptManager.RegisterStartupScript(this, this.GetType(), "focus", string.Format("$('#{0}').focus();", tbBarcode.ClientID), true); 
    }

    /// <summary>
    /// Called when add button is clicked
    /// Adds the currently entered backcode to list of alternate barcodes
    /// </summary>
    protected void btnAdd_OnClick(object sender, EventArgs e)
    {
        var    barcodes   = this.AlternateBarcodes.ToList();
        string newBarcode = tbBarcode.Text.Trim();
        string error;

        // Validate
        if (!this.QSProcessor.ValidateAlternateBarcode(tbBarcode, string.Empty, out error))
        {
            lbError.Text = error;
            return;
        }
        
        // Add new one        
        barcodes.Add(newBarcode);

        // Repopulate list (and selected newly added one)
        //PopulateAlternateBarcodes(barcodes, this.SupplierEdiBarcodes); 10Oct16 XN 164388 
        PopulateAlternateBarcodes(barcodes);

        // Clear barcode textbox
        tbBarcode.Text          = string.Empty;
        hfSelectedBarcode.Value = newBarcode;
        ScriptManager.RegisterStartupScript(this, this.GetType(), "setDrity", "setIsPageDirty();", true); // 30Jul15 XN 124288 Got it to mark page dirty when updated
    }
    
    /// <summary>
    /// Called when delete button is clicked
    /// Deletes currently selected row from the list
    /// </summary>
    protected void btnDelete_OnClick(object sender, EventArgs e)
    {
        var alternateBarcodes = this.AlternateBarcodes.ToList();
        var barcode           = this.hfSelectedBarcode.Value;
        var siteID            = SessionInfo.SiteID;

        if (string.IsNullOrEmpty(barcode))
            return;

        if (this.SupplierProfiles.Any(s => s.EdiBarcode == barcode))
        {
            // If barcode is used as edi barcode then error
            // Get all the suppliers profiles for this Edi barcode,
            // Add display in CSV list with tooltip of name 
            // bit more difficult as need to filter out duplicate suppliers will still provide supplier name for either current or other site 10Oct16 XN 164388
            var suppliers = from sp in this.SupplierProfiles
                            where sp.EdiBarcode == barcode && !string.IsNullOrWhiteSpace(sp.EdiBarcode)
                            group sp by sp.SupplierCode into supplierCodeGroup
                            orderby supplierCodeGroup.Key
                            let SupCode = supplierCodeGroup.Key
                            let SupName = supplierCodeGroup.OrderByDescending(c => c.SiteID == siteID).First().SupplierName
                            let SupSites= supplierCodeGroup.Select(c => Site2.GetSiteNumberByID(c.SiteID).ToString("000")).OrderBy(c => c).ToCSVString(",")
                            select string.Format("{0} - {1} (Site: {2})", SupCode, SupName, SupSites);
            lbError.Text = "In use by " + suppliers.ToCSVString(", ");
        }
        else if (alternateBarcodes.Contains(barcode))
        {
            // Remove barcodes
            alternateBarcodes.Remove(barcode);
            //PopulateAlternateBarcodes(alternateBarcodes, this.SupplierEdiBarcodes);  10Oct16 XN 164388
            PopulateAlternateBarcodes(alternateBarcodes);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "setDrity", "setIsPageDirty();", true); // 30Jul15 XN 124288 Got it to mark page dirty when updated
        }
        else
            lbError.Text = "Select item from the list";
    }
    #endregion 

    #region IQSViewControl Members
    /// <summary>Validates the current values (validation success is reported by event Validated)</summary>
    public void Validate()
    {
        if (Validated != null)
            Validated();
    }

    /// <summary>Event fired when data has been validated successfully</summary>
    public event ValidatedEventHandler Validated;
    
    /// <summary>Saves the current values in the web control to quesScrl (success is report by event Saved)</summary>
    public void Save()
    {
        this.DisplayDifferences();
    }
    
    /// <summary>Event fired when data has been saved to db</summary>
    public event SavedEventHandler Saved;

    /// <summary>Suppresses builing of the conrol</summary>
    public bool SuppressControlCreation { get; set; }
    #endregion

    #region Private Methods
    /// <summary>Populate list of alternate barcodes (will order the list)</summary>
    private void PopulateAlternateBarcodes(IEnumerable<string> barcodes)
    // private void PopulateAlternateBarcodes(IEnumerable<string> barcodes, IEnumerable<string> supplierEdiBarcodes) 10Oct16 XN 164388
    {
        var siteID = SessionInfo.SiteID;

        abcGrid.AddColumn("Barcode",  50, PharmacyGridControl.ColumnType.Text, PharmacyGridControl.AlignmentType.Center);
        abcGrid.AddColumn("Supplier", 50, PharmacyGridControl.ColumnType.Text, PharmacyGridControl.AlignmentType.Center);
        abcGrid.ColumnXMLEscaped(1, false);     //10Oct16 XN 164388
        abcGrid.ColumnAllowTextWrap(1, true);   //10Oct16 XN 164388

        foreach(var b in barcodes.OrderBy(b => b))
        {
            abcGrid.AddRow();
            abcGrid.AddRowAttribute("Barcode", b);
            abcGrid.SetCell(0, b);

            // Get all the suppliers profiles for this Edi barcode,
            // Add display in CSV list with tooltip of name 
            // bit more difficult as need to filter out duplicate suppliers will still provide supplier name for either current or other site 10Oct16 XN 164388
            var suppliers = from sp in this.SupplierProfiles
                            where sp.EdiBarcode == b && !string.IsNullOrWhiteSpace(sp.EdiBarcode)
                            group sp by sp.SupplierCode into supplierCodeGroup
                            orderby supplierCodeGroup.Key
                            let SupCode = supplierCodeGroup.Key
                            let SupDesc = supplierCodeGroup.OrderByDescending(c => c.SiteID == siteID).First().SupplierName
                            select string.Format("<span title='{0}'>{1}</span>", SupDesc.XMLEscape(), SupCode.XMLEscape());
            abcGrid.SetCell(1, suppliers.ToCSVString(", "));
        }

        this.AlternateBarcodes= barcodes;
        this.SupplierProfiles = SupplierProfiles;
    }

    /// <summary>Displays differences</summary>
    private void DisplayDifferences()
    {
        // Get new and existing barcodes
        IEnumerable<string> original = this.QSProcessor.Products.First().GetAlternativeBarcode().OrderBy(s => s);
        IEnumerable<string> newValues= this.AlternateBarcodes.OrderBy(s => s).ToList();

        // If difference then display
        // After use clicks yes to the message will post back to Save (which is caught in Page_PreRender which does the actual save)
        if (!original.SequenceEqual(newValues))
        {
            string msg = string.Format("<div style='max-height:600px;overflow-y:scroll;overflow-x:hidden;'>" + 
                                            "<table cellspacing='10' width='400px' >" +
                                            "<tr><td><b>Description</b></td><td><b>Was</b></td><td><b>Now</b></td></tr>" +
                                            "<tr><td>Alternative Barcodes</td><td>{0}</td><td>{1}</td></tr>" +
                                            "</table>" +
                                       "</div><br /><p>OK to save the changes?</p>", original.ToCSVString("<br />"), newValues.ToCSVString("<br />"));
            string script = string.Format("confirmEnh(\"{0}\", true, function() {{ __doPostBack('{1}', 'Save') }}, undefined, '450px');", msg, upABC.ClientID);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
        }
        else
            ScriptManager.RegisterStartupScript(this, this.GetType(), "clearDrity", "clearIsPageDirty();", true);
    }    

    /// <summary>Saves alternate barcodes to Alias table</summary>
    public void SaveData()
    {
        var product           = (QSProcessor as WProductQSProcessor).Products.First();
        int siteProductDataID = product.SiteProductDataID;
        var oldBarcodes       = product.GetAlternativeBarcode().Distinct().OrderBy(s => s).ToList();
        var barcodes          = this.AlternateBarcodes.Distinct().OrderBy(s => s).ToList();
        WPharmacyLog log      = new WPharmacyLog();
        SiteProductData siteProductData = new SiteProductData();

        // Added updates to the log 126363 XN 14Aug15
        if (!oldBarcodes.SequenceEqual(barcodes))
        {
            log.BeginRow(WPharmacyLogType.LabUtils, product.NSVCode);
            log[0].SiteID = null;
            
            var itemAdded = barcodes.Where(b => !oldBarcodes.Contains(b)).ToList();
            if (itemAdded.Any())
            {
                log.AppendLineDetail("Added alternate barcode(s):");
                itemAdded.ForEach(l => log.AppendLineDetail(l));
            }

            var itemDeleted = oldBarcodes.Where(b => !barcodes.Contains(b)).ToList();
            if (itemDeleted.Any())
            {
                log.AppendLineDetail("Deleted alternate barcode(s):");
                itemDeleted.ForEach(l => log.AppendLineDetail(l));
            }

            log.EndRow();
        }

        using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
        {
            //SiteProductData.RemoveAllAliasByAliasGroup(siteProductDataID, "AlternativeBarcode");
            //SiteProductData.AddAlias(siteProductDataID, "AlternativeBarcode", barcodes.ToArray(), true);
            siteProductData.RemoveAllAliasByAliasGroup(siteProductDataID, "AlternativeBarcode");
            siteProductData.AddAlias(siteProductDataID, "AlternativeBarcode", barcodes.ToArray(), true);
            log.Save();
            trans.Commit();
        }

        if (Saved != null)
            Saved();
    }
    #endregion
}