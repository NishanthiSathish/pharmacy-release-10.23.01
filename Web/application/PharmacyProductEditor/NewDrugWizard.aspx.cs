//==============================================================================================
//
//      					            NewDrugWizard.aspx.cs
//
//  Allows user to add a new pharmacy drug (via a wizard)
//
//  There are 6 different ways to add a pharmacy drug (if these are show is controlled by desktop parameters, and if dss on web is enabled)
//      Import from master      - Imports a drug from the master set of drugs to the local set
//                                New SiteProductData row with same DrugID, NSVCode, and ProductID, 
//                                new ProductStock, and new WSupplierProfile line
//      Import from other site  - Allows selection of drug from another site to be bought into this side
//                                Uses existing SiteProductData row with same DrugID, NSVCode, and ProductID, 
//                                new ProductStock, and new WSupplierProfile line
//      Via Medical Product     - Creates new pharamcy drug linked to MP item
//                                Has new SiteProductData row with own DrugID, NSVCode (ProductID = <NMP.ProductID>) 
//                                new ProductStock, and new WSupplierProfile line
//                                in VB6 user could select a AMPP but this has been removed (based on setting D|STKMAINT.AddWizardAMPPList.GenericGenericOnly)  
//                                and the user is given the Generic Generic line by default
//      Via Non-Medical Product - Creates new pharamcy drug linked to NMP item
//                                Has new SiteProductData row with own DrugID, NSVCode (ProductID = <NMP.ProductID>), 
//                                new ProductStock, and new WSupplierProfile line
//                                User is supposed to pick this from list of predefined templates (D|STKMAINT.AddWizardNMP.ProductNames)
//                                if this setting is empty the user can do a standard NMP template search
//      Stores Only             - Creates new pharamcy drug (not linked to MP or NMP)
//                                Has new SiteProductData row with own DrugID, NSVCode (ProductID = 0), 
//                                new ProductStock, and new WSupplierProfile line
//      Copy Existing           - Copies and exist product, and creates a completly new product from it
//                                Has new SiteProductData row with own DrugID, NSVCode (same ProductID), 
//                                new ProductStock, and new WSupplierProfile line
//
//  The desktop has the following desktop parameters
//  AscribeSiteNumber           - Main ascribe site number for the desktop
//  EditableSiteNumbers         - CSV list of other sites the user can add drug to (default none), use "All" for all sites
//  ShowAddFromMaster           }
//  ShowAddFromOther            }
//  ShowAddMP                   } - Controls add options avaiable to the user
//  ShowAddNMP                  }
//  ShowAddStoresOnly           }
//  ShowAddFromExisting         }
//  ImportFromSiteNumbers       - CSV list of sites the user can import from or "All" for all sites (default All)
//
//	Modification History:
//	20Feb14 XN  Written
//  03Mar14 XN  85353 Getting default to match v8
//  30Jun14 XN  94416 Updated Import From Master to make use of table DSSMasterSiteLinkSiteDrug to 
//              patch up mapping of drugs to correct master Drug, and forcing of NSVCode as readonly
//              Removed reference to DSS in copy from existing.
//  01Jul14 XN  Prevented adding duplicate drugs by disabling (hiding) next button on postback
//              Also when QuesScrl control fires validated or saved event prevented roundtrip to client
//  05Jul14 XN  Removed reference to table DSSMasterSiteLinkSiteDrug as not needed anymore.
//  20Oct14 XN  WizardImportFromMasterFile: On adding from master copy product tradename to supplier tradename (100212)
//  19Nov14 XN  104568 Alow to show more the 14 sites import from and to panels
//  17Jun15 XN  Remove possible duplication of sites from EditableSiteNumbers and ImportFromSiteNumbers 117765
//  24Sep15 XN  Updated WizardFromExisting as moved alias methods from SiteProductData to BaseTable2 77778
//  12Apr18 GB  209908 - Reset DM&D reference when copying from an existing product.
//==============================================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacyProductEditor_NewDrugWizard : System.Web.UI.Page
{
    #region Data Types
    /// <summary>List of steps in the wizard</summary>
    protected enum WizardSteps
    {
        /// <summary>First page list add type methods</summary>
        SelectAddMethodType,

        /// <summary>List sites user can import form</summary>
        SelectImportFromSite,

        /// <summary>Allows user to select pharmacy drug (uses standard PharmacyProductSearch)</summary>
        FindDrug,

        /// <summary>Allows user to select prescribing product</summary>
        FindProduct,

        /// <summary>Lists of standard NMP template user can select from (step depends on setting)</summary>
        NMPList,

        /// <summary>In wizard gives user option of creating new product, or adding from existing pharmacy product</summary>
        MedicalProductAddType,

        /// <summary>List all the AMPP under the product for the user to select from (step is normaly hidden by setting)</summary>
        AMPPList,

        /// <summary>List other sites the user can add the product to</summary>
        SelectImportToSites,

        /// <summary>Info panel to show general information</summary>
        HTMLInfoPanel,

        /// <summary>Displays product editor for user to fill in details (for current site only)</summary>
        DisplayEditor,

        /// <summary>Displays editor for multiple import to sites for user to fill in details (only display if user selects import to sites)</summary>
        EditMultipleSites,

        /// <summary>General message box (as part of wziard)</summary>
        Message
    }

    /// <summary>Add method type</summary>
    protected enum AddMethodType
    {
        ImportFromMasterFile= 0,
        ImportFromOtherSite = 1,
        MedicinalProduct    = 2,
        NonMedicinalProduct = 3,
        StoresOnlyProduct   = 4,
        FromExisting        = 5
    }

    /// <summary>Add type for medical product wizard</summary>
    protected enum MedicalProductAddType
    {
        AddNew,
        CreateFromExisting,
        //FromProduct
    }
    #endregion

    #region Constants
    private const int MaxSitesPerColumns = 20;  // 19Nov14 XN 104568 Alow to show more the 14 sites import from and to panels
    private const int MaxColumns         = 3;   // 19Nov14 XN 104568 Alow to show more the 14 sites import from and to panels
    #endregion

    #region Variables
    private List<int> editableSiteNumbers;
    private List<int> importFromSiteNumbers;
    private bool showAddFromMaster  = true;
    private bool showAddFromOther   = true;
    private bool showAddMP          = true;
    private bool showAddNMP         = true;
    private bool showAddStoresOnly  = true;
    private bool showAddFromExisting= true;

    /// <summary>Set to true when page is due to be closed 1Jul14 XN</summary>
    private bool finished = false;
    #endregion

    #region Properties
    /// <summary>Current step in the wizard</summary>
    protected WizardSteps CurrentStep { get { return (WizardSteps)Enum.Parse(typeof(WizardSteps), hfCurrentStep.Value); } }
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        Sites sites = new Sites();
        sites.LoadAll(true);

        // Get list of editable sites 17Jun15 XN 117765 removed
        //if (Request["EditableSiteNumbers"].EqualsNoCaseTrimEnd("All"))
        //    editableSiteNumbers = sites.Select(s => s.SiteNumber).ToList();
        //else
        //    editableSiteNumbers = (Request["EditableSiteNumbers"] ?? string.Empty).ParseCSV<int>(",", true).ToList();
        //editableSiteNumbers.Remove(SessionInfo.SiteNumber);     // Remove current site
        this.editableSiteNumbers = Site2.Instance().FindBySiteNumber(Request["EditableSiteNumbers"], true, CurrentSiteHandling.Remove).Select(s => s.SiteNumber).ToList();

        // Get list of import from sites 17Jun15 XN 117765 removed
        //string importFromSiteNumbersStr = Request["ImportFromSiteNumbers"] ?? string.Empty;
        //if (importFromSiteNumbersStr.EqualsNoCaseTrimEnd("All"))
        //    importFromSiteNumbers = sites.Select(s => s.SiteNumber).ToList();
        //else
        //    importFromSiteNumbers = importFromSiteNumbersStr.ParseCSV<int>(",", true).ToList();
        //importFromSiteNumbers.Remove(SessionInfo.SiteNumber);   // Remove current site
        this.importFromSiteNumbers = Site2.Instance().FindBySiteNumber(Request["ImportFromSiteNumbers"], true, CurrentSiteHandling.Remove).Select(s => s.SiteNumber).ToList();

        // Determine if the desktop parameter is displayed
        showAddMP          = Request["ShowAddMP"]          != "Hide";
        showAddNMP         = Request["ShowAddNMP"]         != "Hide";
        showAddStoresOnly  = Request["ShowAddStoresOnly"]  != "Hide";
        showAddFromMaster  = Request["ShowAddFromMaster"]  != "Hide";
        showAddFromOther   = Request["ShowAddFromOther"]   != "Hide";
        showAddFromExisting= Request["ShowAddFromExisting"]== "Show";   // Default to hidden

        if (!this.IsPostBack)
        {
            // Start the wizard
            PopulateSelectAddMethodType();
            SetStep(WizardSteps.SelectAddMethodType);

            // If no add options avaiable (filtered out by desktop parameters and DSS on web) then show error message 
            if (rblSelectAddMethod.Items.Count == 0)
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AddNotAllowed", "alertEnh('Option not available', function() { window.close() });", true);
        }
    }

    /// <summary>
    /// Called when the page load has completed
    /// User to set page title (based on add method)
    /// </summary>
    protected void Page_LoadComplete(object sender, EventArgs e)
    {
        // Ensure correct page title is set
        switch(this.GetSelectedAddMethodType())
        {
        case AddMethodType.MedicinalProduct:     this.Title = "Add New Medicinal Product";       break;
        case AddMethodType.NonMedicinalProduct:  this.Title = "Add New Non-Medicinal Product";   break;
        case AddMethodType.StoresOnlyProduct:    this.Title = "Add New Stores Only Product";     break;
        case AddMethodType.ImportFromMasterFile: this.Title = "Add New Product from DSS Master"; break;
        case AddMethodType.ImportFromOtherSite : this.Title = "Add New Product from Other Site"; break;
        case AddMethodType.FromExisting:         this.Title = "Add Duplicate From Existing";     break;
        }
    
        base.OnUnload(e);
    }

    /// <summary>
    /// Called when next button is clicked
    /// Validates current stage in wizard, then moves to next stage is wizard
    /// </summary>
    protected void btnNext_OnClick(object sender, EventArgs e)
    {
        // Validate current wizard step
        bool valid = true;
        switch(this.CurrentStep)
        {
        case WizardSteps.SelectAddMethodType:   valid = ValidateSelectAddMethodType();  break;
        case WizardSteps.SelectImportFromSite:  valid = ValidateSelectImportFromSite(); break;    
        case WizardSteps.FindDrug:              valid = ValidateFindDrug();             break;
        case WizardSteps.FindProduct:           valid = ValidateFindProduct();          break;
        case WizardSteps.NMPList:               valid = ValidateNMPList();              break;
        case WizardSteps.MedicalProductAddType: valid = ValidateMedicalProductAddType();break; 
        case WizardSteps.AMPPList:              valid = ValidateAMPPList();             break;
        case WizardSteps.HTMLInfoPanel:         valid = ValidateHTMLInfoPanel();        break;
        case WizardSteps.DisplayEditor:         valid = ValidateDisplayEditor();        break;
        case WizardSteps.SelectImportToSites:   valid = ValidateSelectImportToSites();  break;
        case WizardSteps.EditMultipleSites:     valid = ValidateEditMultipleSites();    break;
        case WizardSteps.Message:               valid = ValidateMessage();              break;
        }

        // If valid move to next stage in wizard
        if (valid)
        {
            switch(this.GetSelectedAddMethodType())
            {
            case AddMethodType.MedicinalProduct:     WizardMP();                   break;
            case AddMethodType.NonMedicinalProduct:  WizardNMP();                  break;
            case AddMethodType.StoresOnlyProduct:    WizardStoresOnlyProduct();    break;
            case AddMethodType.ImportFromMasterFile: WizardImportFromMasterFile(); break;
            case AddMethodType.ImportFromOtherSite : WizardImportFromOtherSite();  break;
            case AddMethodType.FromExisting:         WizardFromExisting();         break;
            }
        }

        // 1Jul14 XN prevent next button being redisplayed on final return to server (as closing the form)
        //           helps to prevent duplicate drug lines
        if (this.finished)
            btnNext.Style.Add(HtmlTextWriterStyle.Display, "none");
    }    
    #endregion

    #region Coordinate Wizard methods
    /// <summary>
    /// Coordinates import from master file wizard
    /// Steps are 
    ///     Find pharmacy drug
    ///     if drug in use
    ///         Displays error message
    ///     if HTML info to display
    ///         Display message
    ///     Display editor 
    ///     Select import to sites
    ///     if import from sites selected
    ///         Edit multiple sites
    /// </summary>
    private void WizardImportFromMasterFile()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectAddMethodType:
            PopulateFindDrug(SessionInfo.SiteID, true);
            SetStep(WizardSteps.FindDrug);
            break;        

        case WizardSteps.FindDrug:
            {
            string NSVCode = this.GetFoundDrugNSVCode();
            SiteProductDataRow masterSiteProductDataRow = SiteProductData.GetByNSVCodeAndMasterSiteID(NSVCode, 0);  
            SiteProductDataRow localSiteProductDataRow  = SiteProductData.GetByDrugIDAndSiteID(masterSiteProductDataRow.DrugID, SessionInfo.SiteID); 
            //int drugID = masterSiteProductDataRow.GetTrueLocalDrugID();   XN 4Jul14 94416 Removed reference to DSSMasterSiteLinkSiteDrug
            //SiteProductDataRow localSiteProductDataRow  = SiteProductData.GetByDrugIDAndSiteID(drugID, SessionInfo.SiteID);
            //this.hfHeaderSuffix.Value = string.Format("- {0} {1}", masterSiteProductDataRow, this.CheckIfProductHasTemplate(masterSiteProductDataRow.ProductID.Value));
            this.hfHeaderSuffix.Value = string.Format("- {0} {1}", masterSiteProductDataRow, this.CheckIfProductHasTemplate(masterSiteProductDataRow.ProductID));   // Fixed issue if ProductID is null will then error

            // Check for duplicate local row (same Drug ID)
            var duplicateProduct = WProduct.GetByDrugIDAndSiteID(masterSiteProductDataRow.DrugID, SessionInfo.SiteID); 
            //var duplicateProduct = WProduct.GetByDrugIDAndSiteID(drugID, SessionInfo.SiteID); XN 30Jun14 94416 Removed reference to DSSMasterSiteLinkSiteDrug
            if (duplicateProduct != null)
            {
                string msg    = string.Format("There is already a local stock line for this product {0} - {1}<br /><br />Do you want to edit the existing product?", duplicateProduct.NSVCode, duplicateProduct.ToString().JavaStringEscape());
                string script = string.Format("confirmEnh('{0}', true, function() {{ window.returnValue = '{1}'; window.close(); }});", msg, duplicateProduct.NSVCode);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AlreadyExists", script, true);
                return;
            }

            // Check for duplicate row (with same NSVCode)
            SiteProductDataRow duplicateSiteProductData = null;
            if (localSiteProductDataRow == null)
                duplicateSiteProductData = SiteProductData.GetBySiteIDAndNSVCode(SessionInfo.SiteID, masterSiteProductDataRow.NSVCode);
            if (duplicateSiteProductData != null && masterSiteProductDataRow.DrugID != duplicateSiteProductData.DrugID)
            {
                string msg = string.Format("NSV Code currently used by<br />{0}<br /><br />You can add the product, but will need to enter a new NSV Code", duplicateSiteProductData.ToString().JavaStringEscape());
                PopulateMessage(msg);
                SetStep(WizardSteps.Message);
                return;
            }

            string infoText = WConfiguration.Load(SessionInfo.SiteID, "D|STKMAINT", "AddWizardHTMLInfoPanel", "FromMaster", string.Empty, false);
            PopulateHTMLInfoPanel(infoText);
            SetStep(WizardSteps.HTMLInfoPanel);

            // If no info message set then skip to next stage (by calling this method again) 
            if (string.IsNullOrWhiteSpace(infoText))
                WizardImportFromMasterFile();
            }
            break;

        case WizardSteps.Message:
            {
            string infoText = WConfiguration.Load(SessionInfo.SiteID, "D|STKMAINT", "AddWizardHTMLInfoPanel", "FromMaster", string.Empty, false);
            PopulateHTMLInfoPanel(infoText);
            SetStep(WizardSteps.HTMLInfoPanel);

            // If no info message set then skip to next stage (by calling this method again) 
            if (string.IsNullOrWhiteSpace(infoText))
                WizardImportFromMasterFile();
            }
            break;

        case WizardSteps.HTMLInfoPanel:
            {
            SiteProductDataRow masterSiteProductData = SiteProductData.GetByNSVCodeAndMasterSiteID(this.GetFoundDrugNSVCode(), 0);
            SiteProductDataRow localSiteProductData  = SiteProductData.GetByDrugIDAndSiteID(masterSiteProductData.DrugID, SessionInfo.SiteID);   
            //int drugID = masterSiteProductData.GetTrueLocalDrugID();  XN 30Jun14 94416 Remove references to DSSMasterSiteLinkSiteDrug
            //SiteProductDataRow localSiteProductData  = SiteProductData.GetByDrugIDAndSiteID(drugID, SessionInfo.SiteID);
            List<int> readOnlyFields = new List<int>();
            List<int> forceEditable  = new List<int>(); // 86052 10Mar14 XN Ensure warning for NSVCode
                
            WProduct    product = new WProduct();
            WProductRow newProduct = product.Add();

            // Create new product (either from local or master)
            newProduct.CopyFrom(localSiteProductData ?? masterSiteProductData);
            InitWProduct(newProduct, false);
            newProduct.InUse = false;   // 85353 03Mar14 XN Getting default to match v8

            // 100212 20Oct14 XN  If copying from master, then need to copy tradename for SiteProductData to WSupplierProfile
            if (localSiteProductData == null)
                newProduct.SupplierTradename = newProduct.Tradename;

            // If duplicate NSVCode then clear (so user has to enter a new one)
            SiteProductDataRow duplicate = SiteProductData.GetBySiteIDAndNSVCode(SessionInfo.SiteID, newProduct.NSVCode);
            if (duplicate != null && duplicate.DrugID != masterSiteProductData.DrugID)    
            //if (duplicate != null && duplicate.DrugID != masterSiteProductData.DrugID && duplicate.DrugID != drugID)  XN 30Jun14 94416 Removed references to DSSMasterSiteLinkSiteDrug
            {
                newProduct.NSVCode = string.Empty;
                newProduct.Barcode = string.Empty;
            
                forceEditable.Add(WProductQSProcessor.DATAINDEX_NSVCODE);   // 86052 10Mar14 XN Ensure warning for NSVCode
            }
            //else
            //    readOnlyFields.Add(WProductQSProcessor.DATAINDEX_NSVCODE);    XN 30Jun14 94416 Done by configuration settings

            // Populate display editor
            PopulateDisplayEditor(WProductQSProcessor.VIEWINDEX_ADD_BY_IMPORT_FROM_MASTER, product, readOnlyFields, forceEditable);
            SetStep(WizardSteps.DisplayEditor);

            if (!this.editableSiteNumbers.Any())
                btnNext.Text = "Finish";
            }
            break;

        case WizardSteps.DisplayEditor:            
            if (this.editableSiteNumbers.Any())
            {
                // Show select import to sites page
                PopulateSelectImportToSites(this.GetDisplayEditorProduct().Products.First());
                SetStep(WizardSteps.SelectImportToSites);
            }
            else
            {
                // No sites to import to so skip to end
                SetStep(WizardSteps.EditMultipleSites);
                WizardImportFromMasterFile();
            }
            break;

        case WizardSteps.SelectImportToSites:
            // If user has selected sites to import to then display multi site editor 
            SetStep(WizardSteps.EditMultipleSites);
            if (this.GetSelectedImportToSiteIDs().Any())
            {
                WProduct products = ImportProductToSite(this.GetSelectedImportToSiteIDs());
                PopulateEditMultipleSites(WProductQSProcessor.VIEWINDEX_IMPORT_TO_SITES, products, this.GetSelectedImportToSiteIDs());
                btnNext.Text = "Finish";
            }
            else
                WizardImportFromMasterFile();   // No sites selcted so skip to end
            break;

        case WizardSteps.EditMultipleSites:
            if (this.GetSelectedImportToSiteIDs().Any())
            {
                UpdateBeforeSaving(this.editMultipleSites);
                this.editMultipleSites.Save();
            }
            UpdateBeforeSaving(this.editorControl);
            this.editorControl.Save();  // Save single and last so only get 1 Saved event
            break;
        }
    }

    /// <summary>
    /// Coordinates import from other site wizard
    /// Steps are 
    ///     Select site to import from
    ///     Select drug from site
    ///     if HTML info to display
    ///         Display message
    ///     Display editor 
    ///     Select import to sites
    ///     if import from sites selected
    ///         Edit multiple sites
    /// </summary>
    private void WizardImportFromOtherSite()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectAddMethodType: 
            PopulateSelectImportFromSite();
            SetStep(WizardSteps.SelectImportFromSite);
            break;

        case WizardSteps.SelectImportFromSite:
            PopulateFindDrug(this.GetSelectedImportFromSiteID(), false);
            SetStep(WizardSteps.FindDrug);
            break;

        case WizardSteps.FindDrug:
            {
            WProduct productFromOtherSite = new WProduct();
            productFromOtherSite.LoadByProductAndSiteID(this.GetFoundDrugNSVCode(), this.GetSelectedImportFromSiteID());
            this.hfHeaderSuffix.Value = string.Format("- {0} {1}", productFromOtherSite[0], this.CheckIfProductHasTemplate(productFromOtherSite[0].ProductID.Value));

            // Check for duplicate local row (same Drug ID)
            WProduct duplicateProduct = new WProduct();
            duplicateProduct.LoadByDrugIDAndSiteID(productFromOtherSite.First().DrugID, SessionInfo.SiteID);
            if (duplicateProduct.Any())
            {
                string msg    = string.Format("There is already a local stock line for this product {0} - {1}<br /><br />Do you want to edit the existing product?", duplicateProduct[0].NSVCode, duplicateProduct[0].ToString().JavaStringEscape());
                string script = string.Format("confirmEnh('{0}', true, function() {{ window.returnValue = '{1}'; window.close(); }});", msg, duplicateProduct[0].NSVCode);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AlreadyExists", script, true);
                return;
            }

            // Check for duplicate row (with same details)
            duplicateProduct.LoadByByCriteria(SessionInfo.SiteID, 
                                              productFromOtherSite[0].NSVCode, 
                                              productFromOtherSite[0].Barcode, 
                                              productFromOtherSite[0].LabelDescription, 
                                              productFromOtherSite[0].Code, 
                                              productFromOtherSite[0].LocalProductCode, 
                                              productFromOtherSite[0].Tradename, 
                                              productFromOtherSite[0].BNF);
            if (duplicateProduct.Any())
            {
                string msg    = string.Format("{0} already exists in the current site.<br /><br />Do you want to edit the existing product?", duplicateProduct[0].ToString().JavaStringEscape());
                string script = string.Format("confirmEnh('{0}', true, function() {{ window.returnValue = '{1}'; window.close(); }});", msg, duplicateProduct[0].NSVCode);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "AlreadyExists", script, true);
                return;
            }

            string infoText = WConfiguration.Load(SessionInfo.SiteID, "D|STKMAINT", "AddWizardHTMLInfoPanel", "FromOther", string.Empty, false);
            PopulateHTMLInfoPanel(infoText);
            SetStep(WizardSteps.HTMLInfoPanel);

            // If no info message set then skip to next stage (by calling this method again) 
            if (string.IsNullOrWhiteSpace(infoText))
                WizardImportFromOtherSite();
            }
            break;

        case WizardSteps.HTMLInfoPanel:
            {
            WProduct productFromOtherSite = new WProduct();
            productFromOtherSite.LoadByProductAndSiteID(this.GetFoundDrugNSVCode(), this.GetSelectedImportFromSiteID());

            // Create new product (copy from other site)
            WProduct    product = new WProduct();
            WProductRow newProduct = product.Add();
            newProduct.CopyFrom(productFromOtherSite.First());
            InitWProduct(newProduct, false);

            // Reset certain fields
//            newProduct.StockTakeStatus              = productFromOtherSite[0].StockTakeStatus;
            newProduct.EyeLabel                     = productFromOtherSite[0].EyeLabel;         // Prevents being null
            newProduct.PSOLabel                     = productFromOtherSite[0].PSOLabel;         // Prevents being null
            newProduct.ExpiryWarnDays               = productFromOtherSite[0].ExpiryWarnDays;
//            newProduct.LastReceivedPriceExVatPerPack= 0;  85353 03Mar14 XN Getting default to match v8
//            newProduct.ContractPrice                = 0;  85353 03Mar14 XN Getting default to match v8
            newProduct.LeadTimeInDays               = 0;
            newProduct.ReorderPackSize              = null;
            newProduct.OrderCycle                   = string.Empty; // 85353 03Mar14 XN Getting default to match v8

            // Populate display editor
            PopulateDisplayEditor(WProductQSProcessor.VIEWINDEX_ADD_BY_IMPORT_FROM_SITE, product);
            SetStep(WizardSteps.DisplayEditor);

            if (!this.editableSiteNumbers.Any())
                btnNext.Text = "Finish";
            }
            break;

        case WizardSteps.DisplayEditor:
            if (this.editableSiteNumbers.Any())
            {
                // Show select import to sites page
                PopulateSelectImportToSites(this.GetDisplayEditorProduct().Products.First());
                SetStep(WizardSteps.SelectImportToSites);
            }
            else
            {
                // No sites to import to so skip to end
                SetStep(WizardSteps.EditMultipleSites);
                WizardImportFromOtherSite();
            }
            break;

        case WizardSteps.SelectImportToSites:
            // If user has selected sites to import to then display multi site editor 
            SetStep(WizardSteps.EditMultipleSites);
            if (this.GetSelectedImportToSiteIDs().Any())
            {
                WProduct products = ImportProductToSite(this.GetSelectedImportToSiteIDs());
                PopulateEditMultipleSites(WProductQSProcessor.VIEWINDEX_IMPORT_TO_SITES, products, this.GetSelectedImportToSiteIDs());
                btnNext.Text = "Finish";
            }
            else
                WizardImportFromOtherSite();   // No sites selcted so skip to end
            break;

        case WizardSteps.EditMultipleSites:
            //foreach (var p in this.GetDisplayEditorProduct().Products)        85353 03Mar14 XN Getting default to match v8
            //    p.LastReceivedPriceExVatPerPack = p.AverageCostExVatPerPack;

            if (this.GetSelectedImportToSiteIDs().Any())
            {
                UpdateBeforeSaving(this.editMultipleSites);
                this.editMultipleSites.Save();
            }
            UpdateBeforeSaving(this.editorControl);
            this.editorControl.Save();  // Save single and last so only get 1 Saved event
            break;
        }
    }

    /// <summary>
    /// Coordinates add pharmacy drug linked to MP wizard
    /// Steps are 
    ///     Select prescribing TM
    ///     Select add or create from existing pharmacy product
    ///     if create from existing
    ///         Warn user
    ///     if setting D|STKMAINT.AddWizardAMPPList.GenericGenericOnly  is false
    ///         Select AMPP
    ///     if create from existing select above
    ///         Select pharmacy drug
    ///     if HTML info to display
    ///         Display message
    ///     Display editor 
    ///     Select import to sites
    ///     if import from sites selected
    ///         Edit multiple sites
    /// </summary>
    private void WizardMP()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectAddMethodType:
            // Setup find MP page
            PopulateFindProduct("Enter Therapeutic Moiety for New product", "pPRODUCT_MOIETIES_BY_NAME_NONXML2", "Description,99");
            SetStep(WizardSteps.FindProduct);
            break;

        case WizardSteps.FindProduct:
            {
            // Set MP product name on page header
            int productID = this.GetFindProductID();
            this.hfHeaderSuffix.Value = "- " + Product.GetDescriptionByProductID(productID) + " " + this.CheckIfProductHasTemplate(productID);

            // Move to add or create from existing option
            PopulateMedicalProductAddType();
            SetStep(WizardSteps.MedicalProductAddType);

            // If setting AddNew only is on then skip the select add type section (force to add new)
            // 26Mar14 XN 87197 force user to add new on MP add wizard
            if (WConfiguration.Load<bool>(SessionInfo.SiteID, "D|STKMAINT", "AddWizardMPAddType", "AddNewOnly", true, false))
            {
                rblMedicalProductAddType.SelectedIndex = 0;
                WizardMP();
            }
            }
            break;

        case WizardSteps.MedicalProductAddType:
            //if (this.GetSelectedMedicalProductAddType() == MedicalProductAddType.FromProduct)
            //{
            //    // Warn user about what they are doing (will post back to present step with hfConfirmedMsg set con confirm box outcome)
            //    string nsvcode = this.GetSelectedMedicalProductNSVCode();
            //    if (string.IsNullOrEmpty(hfConfirmedMsg.Value))
            //    {
            //        string msg = string.Format(@"This will edit the existing stock line {0}<br \>If you wish to Add an existing product definition for a new product line then press No and select the appropriate option from the list.<br /><br />To edit the existing stock line press Yes", nsvcode);
            //        msg = WConfiguration.Load<string>(SessionInfo.SiteID, "D|stkmaint", "Maintenance", "EditDrugfromMoietyMsg", msg, false);
            //        string script =  "confirmEnh(\"" + msg + "\"," +
            //                                     "true," +
            //                                     "function() { $('#hfConfirmedMsg').val('Y'); $('#btnNext').click(); }," + 
            //                                     "function() { $('#hfConfirmedMsg').val('N'); $('#btnNext').click(); });";
            //        ScriptManager.RegisterStartupScript(this, this.GetType(), "confirm", script, true);
            //    }
            //    else if (hfConfirmedMsg.Value == "Y")
            //        ScriptManager.RegisterStartupScript(this, this.GetType(), "close", string.Format("window.returnValue='{0}'; window.close()", nsvcode), true);
            //    else if (hfConfirmedMsg.Value == "N")
            //        hfConfirmedMsg.Value = string.Empty;
            //}
            //else
            //{
                SetStep(WizardSteps.AMPPList);
                hfConfirmedMsg.Value = string.Empty;

                if (WConfiguration.Load<bool>(SessionInfo.SiteID, "D|STKMAINT", "AddWizardAMPPList", "GenericGenericOnly", true, false))
                {
                    // Skiping AMPP selection so just select generic generic
                    hfAMPPProductID.Value = this.GetFindProductID().ToString();
                    WizardMP();
                }
                else
                    PopulateAMPPList();
            //}
            break;

        case WizardSteps.AMPPList:
            // This stage is not really need but could not get confirmation that it can be removed so switch it off on setting WConfiguration.D|STKMAINT.AddWizardAMPPList.GenericGenericOnly.
            {
            int productID = this.GetAMPPProductID();
            this.hfHeaderSuffix.Value = "- " + Product.GetDescriptionByProductID(productID) + " " + this.CheckIfProductHasTemplate(productID);

            if (this.GetSelectedMedicalProductAddType() == MedicalProductAddType.CreateFromExisting)
            {
                PopulateFindDrug(SessionInfo.SiteID, false);
                SetStep(WizardSteps.FindDrug);
            }
            else
            {
                string infoText = WConfiguration.Load(SessionInfo.SiteID, "D|STKMAINT", "AddWizardHTMLInfoPanel", "MP", string.Empty, false);
                PopulateHTMLInfoPanel(infoText);
                SetStep(WizardSteps.HTMLInfoPanel);

                if (string.IsNullOrWhiteSpace(infoText))
                    WizardMP();
            }
            }
            break;

        case WizardSteps.FindDrug:
            // Only get to this stage if selected create from existing product
            {
            string infoText = WConfiguration.Load(SessionInfo.SiteID, "D|STKMAINT", "AddWizardHTMLInfoPanel", "MP", string.Empty, false);
            PopulateHTMLInfoPanel(infoText);
            SetStep(WizardSteps.HTMLInfoPanel);

            // If no info message set then skip to next stage (by calling this method again) 
            if (string.IsNullOrWhiteSpace(infoText))
                WizardMP();
            }
            break;

        case WizardSteps.HTMLInfoPanel:
            {
            WProduct    product    = new WProduct();
            WProductRow newProduct = product.Add();

            // Create new product (either from exsting or creating new)
            if (!string.IsNullOrEmpty(this.GetFoundDrugNSVCode()))
            {
                WProduct existingPharmacyProduct = new WProduct();
                existingPharmacyProduct.LoadByProductAndSiteID(this.GetFoundDrugNSVCode(), SessionInfo.SiteID);
                newProduct.CopyFrom(existingPharmacyProduct.First());

                InitWProduct(newProduct, false);
            }
            else
                InitWProduct(newProduct, true);

            // Reset certain fields
            string description = Product.GetDescriptionByProductID(this.GetFindProductID());
            newProduct.SiteProductDataID = 0;
            newProduct.ProductID         = this.GetAMPPProductID();
            newProduct.DrugID            = WFilePointer.Increment(SessionInfo.SiteID, "A|DrugID");
            newProduct.LabelDescription  = description.SafeSubstring(0, WProduct.GetColumnInfo().LabelDescriptionLength );
            newProduct.StoresDescription = description.SafeSubstring(0, WProduct.GetColumnInfo().StoresDescriptionLength);
            newProduct.Barcode           = string.Empty;
            newProduct.NSVCode           = string.Empty;
            if (this.GetSelectedMedicalProductAddType() == MedicalProductAddType.CreateFromExisting)
                newProduct.InUse = false;   // 85353 03Mar14 XN Getting default to match v8

            var forceEditable = new [] { WProductQSProcessor.DATAINDEX_NSVCODE };   // 86052 10Mar14 XN Ensure warning for NSVCode

            // Populate display editor
            PopulateDisplayEditor(WProductQSProcessor.VIEWINDEX_ADD_FROM_MP, product, null, forceEditable);
            SetStep(WizardSteps.DisplayEditor);

            if (!this.editableSiteNumbers.Any())
                btnNext.Text = "Finish";
            }
            break;

        case WizardSteps.DisplayEditor:
            if (this.editableSiteNumbers.Any())
            {
                // Show select import to sites page
                PopulateSelectImportToSites(this.GetDisplayEditorProduct().Products.First());
                SetStep(WizardSteps.SelectImportToSites);
            }
            else
            {
                // No sites to import to so skip to end
                SetStep(WizardSteps.EditMultipleSites);
                WizardImportFromMasterFile();
            }
            break;

        case WizardSteps.SelectImportToSites:
            // If user has selected sites to import to then display multi site editor 
            SetStep(WizardSteps.EditMultipleSites);
            if (this.GetSelectedImportToSiteIDs().Any())
            {
                WProduct products = ImportProductToSite(this.GetSelectedImportToSiteIDs());
                PopulateEditMultipleSites(WProductQSProcessor.VIEWINDEX_IMPORT_TO_SITES, products, this.GetSelectedImportToSiteIDs());
                btnNext.Text = "Finish";
            }
            else
                WizardMP();     // No sites selcted so skip to end
            break;

        case WizardSteps.EditMultipleSites:
            if (this.GetSelectedImportToSiteIDs().Any())
            {
                UpdateBeforeSaving(this.editMultipleSites);
                this.editMultipleSites.Save();
            }
            UpdateBeforeSaving(this.editorControl);
            this.editorControl.Save();  // Save single and last so only get 1 Saved event
            break;
        }
    }

    /// <summary>
    /// Coordinates add pharmacy drug linked to NMP wizard
    /// Steps are 
    ///     if setting D|STKMAINT.AddWizardNMP.ProductNames is set
    ///         Show NMP template list 
    ///         If no template selected
    ///             Select prescribing NMP
    ///     else
    ///         Select prescribing NMP
    ///     if HTML info to display
    ///         Display message
    ///     Display editor 
    ///     Select import to sites
    ///     if import from sites selected
    ///         Edit multiple sites
    /// </summary>
    private void WizardNMP()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectAddMethodType:
            if (string.IsNullOrEmpty(WConfiguration.LoadAndCache<string>(SessionInfo.SiteID, "D|STKMAINT", "AddWizardNMP", "ProductNames", string.Empty, false)))
            {
                // No non medical products templates specified so all select from list
                PopulateFindProduct("Enter Description for Non-Medicinal Product", "pNMPPUnLinkedList2", "Description,99");
                SetStep(WizardSteps.FindProduct);
            }
            else
            {
                // Allow user to select Non-MP template from predefined list
                PopulateNMPList();
                SetStep(WizardSteps.NMPList);
            }
            break;

        case WizardSteps.NMPList:
            {
            int? productID = this.GetNMProductID();
            if (productID == null)
            {
                // no NMP selected from list so display find product 
                PopulateFindProduct("Enter Description for Non-Medicinal Product", "pNMPPUnLinkedList2", "Description,99");
                SetStep(WizardSteps.FindProduct);
            } 
            else
            {
                // Call this methos again so can skip past FindProduct
                hfProductID.Value = productID.ToString();
                SetStep(WizardSteps.FindProduct);
                WizardNMP();
            }
            }
            break;

        case WizardSteps.FindProduct:
            {
            // Set page header suffix
            int productID = this.GetFindProductID();
            this.hfHeaderSuffix.Value = "- " + Product.GetDescriptionByProductID(productID) + " " + this.CheckIfProductHasTemplate(productID);

            // HTML info panel
            string infoText = WConfiguration.Load(SessionInfo.SiteID, "D|STKMAINT", "AddWizardHTMLInfoPanel", "NMP", string.Empty, false);
            PopulateHTMLInfoPanel(infoText);
            SetStep(WizardSteps.HTMLInfoPanel);

            // If no info message set then skip to next stage (by calling this method again) 
            if (string.IsNullOrWhiteSpace(infoText))
                WizardNMP();
            }
            break;

        case WizardSteps.HTMLInfoPanel:
            {
            // Create new product
            WProduct    product    = new WProduct();
            WProductRow newProduct = product.Add();
            InitWProduct(newProduct, true);

            // Reset certain fields
            string description = Product.GetDescriptionByProductID(this.GetFindProductID());
            newProduct.ProductID                = this.GetFindProductID();
            newProduct.DrugID                   = WFilePointer.Increment(SessionInfo.SiteID, "A|DrugID");
            newProduct.LabelDescription         = description.SafeSubstring(0, WProduct.GetColumnInfo().LabelDescriptionLength);
            newProduct.StoresDescription        = description.SafeSubstring(0, WProduct.GetColumnInfo().StoresDescriptionLength);
            newProduct.ReorderLevelInIssueUnits = null;
            newProduct.ReorderPackSize          = null;

            // Populate display editor
            PopulateDisplayEditor(WProductQSProcessor.VIEWINDEX_ADD_FROM_NMP, product);
            SetStep(WizardSteps.DisplayEditor);

            if (!this.editableSiteNumbers.Any())
                btnNext.Text = "Finish";
            }
            break;

        case WizardSteps.DisplayEditor:
            if (this.editableSiteNumbers.Any())
            {
                // Show select import to sites page
                PopulateSelectImportToSites(GetDisplayEditorProduct().Products.First());
                SetStep(WizardSteps.SelectImportToSites);
            }
            else
            {
                // No sites to import to so skip to end
                SetStep(WizardSteps.EditMultipleSites);
                WizardImportFromMasterFile();
            }
            break;

        case WizardSteps.SelectImportToSites:
            // If user has selected sites to import to then display multi site editor 
            SetStep(WizardSteps.EditMultipleSites);
            if (this.GetSelectedImportToSiteIDs().Any())
            {
                WProduct products = ImportProductToSite(this.GetSelectedImportToSiteIDs());
                PopulateEditMultipleSites(WProductQSProcessor.VIEWINDEX_IMPORT_TO_SITES, products, this.GetSelectedImportToSiteIDs());
                btnNext.Text = "Finish";
            }
            else
                WizardNMP();   // No sites selcted so skip to end
            break;

        case WizardSteps.EditMultipleSites:
            if (this.GetSelectedImportToSiteIDs().Any())
            {
                UpdateBeforeSaving(this.editMultipleSites);
                this.editMultipleSites.Save();
            }
            UpdateBeforeSaving(this.editorControl);
            this.editorControl.Save();  // Save single and last so only get 1 Saved event
            break;
        }
    }

    /// <summary>
    /// Coordinates add stores only product wizard
    /// Steps are 
    ///     if HTML info to display
    ///         Display message
    ///     Display editor 
    ///     Select import to sites
    ///     if import from sites selected
    ///         Edit multiple sites
    /// </summary>
    private void WizardStoresOnlyProduct()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectAddMethodType: 
            // HTML info panel
            string infoText = WConfiguration.Load(SessionInfo.SiteID, "D|STKMAINT", "AddWizardHTMLInfoPanel", "StoresOnly", string.Empty, false);
            PopulateHTMLInfoPanel(infoText);
            SetStep(WizardSteps.HTMLInfoPanel);

            // If no info message set then skip to next stage (by calling this method again) 
            if (string.IsNullOrWhiteSpace(infoText))
                WizardStoresOnlyProduct();
            break;

        case WizardSteps.HTMLInfoPanel: 
            {
            // Create new product
            WProduct    product    = new WProduct();
            WProductRow newProduct = product.Add();
            InitWProduct(newProduct, true);

            // Reset certain fields
            newProduct.DrugID          = WFilePointer.Increment(SessionInfo.SiteID, "A|DrugID");
            newProduct.ReorderPackSize = null;

            // Populate display editor
            PopulateDisplayEditor(WProductQSProcessor.VIEWINDEX_ADD_STORES_ONLY, product);
            SetStep(WizardSteps.DisplayEditor);

            if (!this.editableSiteNumbers.Any())
                btnNext.Text = "Finish";
            }
            break;

        case WizardSteps.DisplayEditor:
            // Add description to page header
            this.hfHeaderSuffix.Value = " - " + this.GetDisplayEditorProduct().Products.First().LabelDescription;

            if (this.editableSiteNumbers.Any())
            {
                // Show select import to sites page
               PopulateSelectImportToSites(this.GetDisplayEditorProduct().Products.First());
                SetStep(WizardSteps.SelectImportToSites);
            }
            else
            {
                // No sites to import to so skip to end
                SetStep(WizardSteps.EditMultipleSites);
                WizardStoresOnlyProduct();
            }
            break;

        case WizardSteps.SelectImportToSites:
            // If user has selected sites to import to then display multi site editor 
            SetStep(WizardSteps.EditMultipleSites);
            if (this.GetSelectedImportToSiteIDs().Any())
            {
                WProduct products = ImportProductToSite(this.GetSelectedImportToSiteIDs());
                PopulateEditMultipleSites(WProductQSProcessor.VIEWINDEX_IMPORT_TO_SITES, products, this.GetSelectedImportToSiteIDs());
                btnNext.Text = "Finish";
            }
            else
                WizardStoresOnlyProduct();  // No sites selcted so skip to end
            break;

        case WizardSteps.EditMultipleSites:
            if (this.GetSelectedImportToSiteIDs().Any())
            {
                UpdateBeforeSaving(this.editMultipleSites);
                this.editMultipleSites.Save();
            }
            UpdateBeforeSaving(this.editorControl);
            this.editorControl.Save();  // Save single and last so only get 1 Saved event
            break;
        }
    }

    /// <summary>
    /// Coordinates copy existing product
    /// Steps are
    ///     Search for existing product (on current site)
    ///     if HTML info to display
    ///         Display message
    ///     Display editor 
    ///     Select import to sites
    ///     if import from sites selected
    ///         Edit multiple sites
    /// </summary>
    private void WizardFromExisting()
    {
        switch (this.CurrentStep)
        {
        case WizardSteps.SelectAddMethodType: 
            PopulateFindDrug(SessionInfo.SiteID, false);
            SetStep(WizardSteps.FindDrug);
            break;

        case WizardSteps.FindDrug:
            {
            // Add drug name to page suffix
            WProductRow product = WProduct.GetByProductAndSiteID(this.GetFoundDrugNSVCode(), SessionInfo.SiteID);
            this.hfHeaderSuffix.Value = string.Format("- {0} {1}", product, this.CheckIfProductHasTemplate(product.ProductID.Value));

            // HTML info panel
            string infoText = WConfiguration.Load(SessionInfo.SiteID, "D|STKMAINT", "AddWizardHTMLInfoPanel", "FromExisting", string.Empty, false);
            PopulateHTMLInfoPanel(infoText);
            SetStep(WizardSteps.HTMLInfoPanel);

            // If no info message set then skip to next stage (by calling this method again) 
            if (string.IsNullOrWhiteSpace(infoText))
                WizardImportFromOtherSite();
            }
            break;
        
        case WizardSteps.HTMLInfoPanel:
            {
            WProductRow existingProduct = WProduct.GetByProductAndSiteID(this.GetFoundDrugNSVCode(), SessionInfo.SiteID);

            // Create new product
            WProduct    product = new WProduct();
            WProductRow newProduct = product.Add();
            newProduct.CopyFrom(existingProduct);
            InitWProduct(newProduct, false);

            // Reset certain fields
            newProduct.NSVCode           = string.Empty;
            newProduct.Barcode           = string.Empty;
            newProduct.SiteProductDataID = 0;
            newProduct.DrugID            = WFilePointer.Increment(SessionInfo.SiteID, "A|DrugID");
            newProduct.SupplierCode      = existingProduct.SupplierCode;    // reset as will of been removed by InitWProduct
            newProduct.OrderCycle        = string.Empty;    // 85353 03Mar14 XN Getting default to match v8
            //newProduct.RawRow["DSS"]     = false;         XN 30Jum14 removed field
            newProduct.DMandDReference   = null;

            var forceEditable = new [] { WProductQSProcessor.DATAINDEX_NSVCODE };   // 86052 10Mar14 XN Ensure warning for NSVCode

            // Populate display editor
            PopulateDisplayEditor(WProductQSProcessor.VIEWINDEX_ADD_COPY_EXISTING, product, null, forceEditable);
            SetStep(WizardSteps.DisplayEditor);
            btnNext.Text = "Finish";
            }
            break;

        case WizardSteps.DisplayEditor:
            // Get copy of barcodes, so can copy to new product
            var barcodes = WProduct.GetByProductAndSiteID(this.GetFoundDrugNSVCode(), SessionInfo.SiteID).GetAlternativeBarcode();

            using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
            {
                UpdateBeforeSaving(this.editorControl);
                this.editorControl.Save();

                // Save alternate barcodes
                if (barcodes.Any())
                {
                    int siteProductDataID = (this.editorControl.QSProcessor as WProductQSProcessor).Products.First().SiteProductDataID;
                    //SiteProductData.RemoveAllAliasByAliasGroup(siteProductDataID, "AlternativeBarcode");          24Sep15 XN 77778
                    //SiteProductData.AddAlias(siteProductDataID, "AlternativeBarcode", barcodes.ToArray(), true);
                    SiteProductData siteProductData = new SiteProductData();
                    siteProductData.RemoveAllAliasByAliasGroup(siteProductDataID, "AlternativeBarcode");
                    siteProductData.AddAlias(siteProductDataID, "AlternativeBarcode", barcodes.ToArray(), true);
                }

                trans.Commit();
            }
            break;
        }
    }
    #endregion

    #region SelectAddMethodType page
    /// <summary>Populate SelectAddMethodType page</summary>
    private void PopulateSelectAddMethodType()
    {
        Sites sites = new Sites();
        sites.LoadAll(true);

        // Prevent adding via MP or NMP if DSS on web is on (can be overwritten by setting D|stkmaint.DSSLockDown.AllowAddProduct)
        bool dssLockDown = SettingsController.Load<bool>("System", "Reference", "DSSUpdateServiceInUse", false) && !WConfiguration.Load<bool>(SessionInfo.SiteID, "D|stkmaint", "DSSLockDown", "AllowAddProduct", false, false);

        if (!this.showAddFromOther || !sites.FindSiteIDBySiteNumber(this.importFromSiteNumbers).Any())
            rblSelectAddMethod.Items.Remove(rblSelectAddMethod.Items.FindByValue( ((int)AddMethodType.ImportFromOtherSite   ).ToString()) );
        if (!this.showAddFromMaster)
            rblSelectAddMethod.Items.Remove(rblSelectAddMethod.Items.FindByValue( ((int)AddMethodType.ImportFromMasterFile  ).ToString()) );
        if (!this.showAddStoresOnly)
            rblSelectAddMethod.Items.Remove(rblSelectAddMethod.Items.FindByValue( ((int)AddMethodType.StoresOnlyProduct     ).ToString()) );
        if (!this.showAddNMP || dssLockDown)
            rblSelectAddMethod.Items.Remove(rblSelectAddMethod.Items.FindByValue( ((int)AddMethodType.NonMedicinalProduct   ).ToString()) );
        if (!this.showAddMP || dssLockDown)
            rblSelectAddMethod.Items.Remove(rblSelectAddMethod.Items.FindByValue( ((int)AddMethodType.MedicinalProduct      ).ToString()) );
        if (!this.showAddFromExisting)
            rblSelectAddMethod.Items.Remove(rblSelectAddMethod.Items.FindByValue( ((int)AddMethodType.FromExisting          ).ToString()) );

        if (rblSelectAddMethod.Items.Count > 0)
            rblSelectAddMethod.Items[0].Selected = true;    // XN 16Apr14 ensure first item in list is selected
        rblSelectAddMethod.Focus();
    }

    /// <summary>Validates SelectAddMethodType page (always valid)</summary>
    private bool ValidateSelectAddMethodType()
    {
        return true;
    }

    /// <summary>Returns the selected add method type (from SelectAddMethodType page)</summary>
    private AddMethodType GetSelectedAddMethodType()
    {
        int value = string.IsNullOrEmpty(rblSelectAddMethod.Text) ? -1 : int.Parse(rblSelectAddMethod.Text);
        return (AddMethodType)value;
    }
    #endregion

    #region FindDrug page
    /// <summary>Populates the FindDrug (pharmacy drug) page</summary>
    /// <param name="siteID">Site ID</param>
    /// <param name="masterMode">If in master mode</param>
    private void PopulateFindDrug(int siteID, bool masterMode)
    {
        this.hfFindDrugExtraParams.Value= string.Format("&SiteID={0}&MasterMode={1}", siteID, masterMode);
    }

    /// <summary>
    /// Validates FindDrug page
    /// Checks if drug selected
    /// </summary>
    private bool ValidateFindDrug()
    {
        if (string.IsNullOrEmpty(hfNSVCode.Value))
        {
            errorMessage.InnerText = "Select a product from the list";
            return false;
        }

        return true;
    }

    /// <summary>Return the NSV Code of selected drug from FindDrug page</summary>
    private string GetFoundDrugNSVCode()
    {
        return hfNSVCode.Value;
    }
    #endregion

    #region FindProduct page
    /// <summary>Populates FindProduct (find prescribing product)</summary>
    /// <param name="info">Info to display on top of page</param>
    /// <param name="sp">SP to do the lookup</param>
    /// <param name="columns">Columns to display</param>
    private void PopulateFindProduct(string info, string sp, string columns)
    {
        this.hfFindProductParams.Value = "&Info="    + info;
        this.hfFindProductParams.Value +="&SP="      + sp;
        this.hfFindProductParams.Value +=string.Format("&Params=CurrentSessionID:{0},searchText:[searchText]", SessionInfo.SessionID);
        this.hfFindProductParams.Value += "&Columns=" + columns;
    }

    /// <summary>
    /// Validates FindProduct page 
    /// Checks if product is selected
    /// </summary>
    private bool ValidateFindProduct()
    {
        if (string.IsNullOrEmpty(hfProductID.Value))
        {
            errorMessage.InnerText = "Select a product from the list";
            return false;
        }

        return true;
    }

    /// <summary>Returns ProductID of selected product from FindProduct page</summary>
    private int GetFindProductID()
    {
        return int.Parse(hfProductID.Value);
    }
    #endregion

    #region NMPList page
    /// <summary>Populate NMPP page with list of NMPP product from D|STKMAINT.AddWizardNMP.ProductNames</summary>
    private void PopulateNMPList()
    {
        var npTemplatesStr = WConfiguration.LoadAndCache<string>(SessionInfo.SiteID, "D|STKMAINT", "AddWizardNMP", "ProductNames", string.Empty, false).ParseCSV<string>("|", false);
        rblNMPList.Items.AddRange(npTemplatesStr.Select(t => new ListItem(t.XMLEscape())).ToArray());
        rblNMPList.SelectedIndex = 0;
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "focus", "$('#rblNMPList [checked]').focus();", true);
    }

    /// <summary>Validates the NMPP list check item iss selected</summary>
    private bool ValidateNMPList()
    {
        if (rblNMPList.SelectedIndex == -1)
        {
            errorMessage.InnerText = "Select NP product from list";
            return false;
        }

        return true;
    }

    /// <summary>Returns selected NMPP product id (or null if it does not exist)</summary>
    private int? GetNMProductID()
    {
        //return Product.GetProductIDByDescritpion(rblNMPList.SelectedValue);   31Mar14 XN made search against NMPP product type 
        return Product.GetProductIDByDescritpion(rblNMPList.SelectedValue, "Non-Medicinal Packaged Product");
    }
    #endregion

    #region MedicalProductAddType page
    /// <summary>Populate the MedicalProductAddType page</summary>
    private void PopulateMedicalProductAddType()
    {
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "focus", "$('#rblMedicalProductAddType [checked]').focus();", true);
    }

    /// <summary>Validates MedicalProductAddType page (always returns true)</summary>
    private bool ValidateMedicalProductAddType()
    {
        return true;
    }

    /// <summary>Returns selected MedicalProductAddType from the MedicalProductAddType page</summary>
    private MedicalProductAddType GetSelectedMedicalProductAddType()
    {
        switch (rblMedicalProductAddType.SelectedIndex)
        {
        case 0:  return MedicalProductAddType.AddNew;
        default: return MedicalProductAddType.CreateFromExisting;
        //default:return MedicalProductAddType.FromProduct;
        }
    }

    ///// <summary>Returns the selected NSVCode from the MedicalProductAddType page</summary>
    //private string GetSelectedMedicalProductNSVCode()
    //{
    //    return rblMedicalProductAddType.SelectedValue;
    //}
    #endregion

    #region AMPPList page
    /// <summary>
    /// Populate AMPPList page (Not normally used as always use GENERIC GENERIC)
    /// Shows standard pharmacy search box for AMPP list
    /// </summary>
    private void PopulateAMPPList()
    {
        int productID_TM = this.GetFindProductID();
        this.hfAMPPListExtraParams.Value =  "&Info=Select Actual Medicinal Packaged Product";
        this.hfAMPPListExtraParams.Value += "&SP=pAMPPUnLinkedList";
        this.hfAMPPListExtraParams.Value += string.Format("&Params=CurrentSessionID:{0},ProductID_TM:{1}", SessionInfo.SessionID, productID_TM);
        this.hfAMPPListExtraParams.Value += "&Columns=Description,65,Manufacturer,35";
        this.hfAMPPListExtraParams.Value += string.Format("&ExtraLines={0},{1},GENERIC GENERIC", productID_TM, Product.GetDescriptionByProductID(productID_TM).JavaStringEscape());
    }

    /// <summary>Validates the AMPPList page</summary>
    private bool ValidateAMPPList()
    {
        if (string.IsNullOrEmpty(hfAMPPProductID.Value))
        {
            errorMessage.InnerText = "Select a AMPP from the list";
            return false;
        }

        List<SqlParameter> parameter = new List<SqlParameter>();
        parameter.Add(new SqlParameter("CurrentSessionID", SessionInfo.SessionID  ));
        parameter.Add(new SqlParameter("ProductID_TM",     this.GetFindProductID()));

        GenericTable2 ampps = new GenericTable2();
        ampps.LoadBySP("pAMPPUnLinkedList", parameter);

        int amppID = this.GetAMPPProductID();

        if (!ampps.Any(p => ((int)p.RawRow["ProductID"]) == amppID))
        {
            PopulateAMPPList();

            if (string.IsNullOrEmpty(hfAMPPConfirm.Value))
            {
                string script =  "confirmEnh(\"You are attempting to match against a Therapeutic Moiety.<br /><br />Are you certain that this is correct ?\"," +
                                                "true," +
                                                "function() { $('#hfAMPPConfirm').val('Y'); $('#btnNext').click(); }," + 
                                                "function() { $('#hfAMPPConfirm').val('N'); $('#btnNext').click(); });";
                ScriptManager.RegisterStartupScript(this, this.GetType(), "confirm", script, true);

                return false;
            }
            else if (hfAMPPConfirm.Value == "N")
            {
                hfAMPPConfirm.Value = string.Empty;
                return false;
            }
        }

        return true;
    }

    /// <summary>Returns selected AMPP product ID from AMPPList page</summary>
    private int GetAMPPProductID()
    {
        return int.Parse(hfAMPPProductID.Value);
    }
    #endregion

    #region HTMLInfoPanel page
    /// <summary>Populate the HTML info panel</summary>
    /// <param name="htmlInfoText">Text to display</param>
    private void PopulateHTMLInfoPanel(string htmlInfoText)
    {
        divHTMLInfoPanel.InnerHtml = htmlInfoText;
    }

    /// <summary>Validates HTML info panel (always returns true)</summary>
    private bool ValidateHTMLInfoPanel()
    {
        return true;
    }
    #endregion

    #region SelectImportFromSite page
    /// <summary>
    /// Populate SelectImportFromSite page
    /// Populates import site list from URL ImportFromSiteNumbers
    /// </summary>
    private void PopulateSelectImportFromSite()
    {
        if (rblSelectImportFromSite.Items.Count == 0)
        {
            SiteProcessor siteProcessor = new SiteProcessor(); 
            var sites = siteProcessor.LoadAll(true);

            // Add each site from importFromSiteNumbers
            foreach (var s in importFromSiteNumbers)
            {
                var site = sites.FirstOrDefault(c => c.Number == s);
                if (site != null)
                {
                    string name = string.Format("{0} - {1:000}", site.LocalHospitalAbbreviation, site.Number);
                    rblSelectImportFromSite.Items.Add(new ListItem(name, site.SiteID.ToString()));
                }
            }

            // Select first by default
            if (rblSelectImportFromSite.Items.Count > 0)
                rblSelectImportFromSite.SelectedIndex = 0;

            // If greater than 20 sites then add more columns
            // if more than 60 sites then show scroll bar
            // XN 19Nov14 104568 
            int columnCount = (rblSelectImportFromSite.Items.Count / MaxSitesPerColumns) + 1;
            if (columnCount > 1)
            {
                rblSelectImportFromSite.RepeatColumns = Math.Min(columnCount, MaxColumns);
                rblSelectImportFromSite.RepeatLayout  = RepeatLayout.Table;
                if ( columnCount > MaxColumns )
                    pnSelectImportFromSite.ScrollBars = ScrollBars.Vertical;
            }
        }

        // Ensure control has focus
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "focus", "$('#rblSelectImportFromSite [checked]').focus();", true);
    }

    /// <summary>Validates SelectImportFromSite page (always returns true)</summary>
    private bool ValidateSelectImportFromSite()
    {
        return true;
    }

    /// <summary>Returns selected import from site ID for SelectImportFromSite page</summary>
    private int GetSelectedImportFromSiteID()
    {
        return string.IsNullOrEmpty(rblSelectImportFromSite.SelectedValue) ? -1 : int.Parse(rblSelectImportFromSite.SelectedValue);
    }
    #endregion

    #region SelectImportToSites page
    /// <summary>Populate SelectImportToSites page</summary>
    /// <param name="newProduct">New product that is going to be added</param>
    private void PopulateSelectImportToSites(WProductRow newProduct)
    {
        // Load existing product for all sites
        WProduct existingProducts = new WProduct();
        if (newProduct.DrugID != 0)
            existingProducts.LoadAllSitesByDrugID(newProduct.DrugID, SessionInfo.SiteID);

        SiteProcessor siteProcessor = new SiteProcessor(); 
        var sites = siteProcessor.LoadAll(true)
                                        .Where(s => editableSiteNumbers.Contains(s.Number))
                                        .OrderBy(s => s.Number);

        // Get dss on web settings to determin if site allowed to add drug
        // Can not add if dss on web is on, and adding via MP, or NMP
        // this can be overwritten if site has D|stkmaint.DSSLockDown.AllowAddProduct set to true
        bool ifAddMethodIsDSSLockable = this.GetSelectedAddMethodType() == AddMethodType.MedicinalProduct || this.GetSelectedAddMethodType() == AddMethodType.NonMedicinalProduct;
        bool dssUpdateServiceInUse    = SettingsController.Load<bool>("System", "Reference", "DSSUpdateServiceInUse", false);  
        WConfiguration config = new WConfiguration();
        config.LoadByCategorySectionAndKey("D|stkmaint", "DSSLockDown", "AllowAddProduct");

        cblSelectImportToSites.Items.Clear();
        foreach (var s in sites)
        {
            // Determin if can't add due to dss locking or if exists
            bool dssOnWebLockedSite = ifAddMethodIsDSSLockable && dssUpdateServiceInUse && !config.Any(c => c.SiteID == s.SiteID && BoolExtensions.PharmacyParse(c.Value));
            bool exists             = existingProducts.Any(c => c.SiteID == s.SiteID);
                
            // Add the site (disable showing error if not in use)
            ListItem newSite = new ListItem();
            newSite.Value   = s.SiteID.ToString();
            newSite.Enabled = !(dssOnWebLockedSite || exists);
            newSite.Text    = string.Format("{0} - {1:000}", s.LocalHospitalAbbreviation, s.Number);
            if (dssOnWebLockedSite)
                newSite.Text += " <span class='ErrorMessage'>(add drugs via DSS on Web)</span>";
            else if (exists)
                newSite.Text += " <span class='ErrorMessage'>(already exists)</span>";

            cblSelectImportToSites.Items.Add(newSite);
        }

        // Select first item
        ListItem selectedItem = cblSelectImportToSites.Items.FindByValue(SessionInfo.SiteID.ToString());
        if (selectedItem != null && selectedItem.Enabled)
            selectedItem.Selected = true;

        // If greater than 20 sites then add more columns
        // if more than 60 sites then show scroll bar
        // XN 19Nov14 104568 
        int columnCount = (cblSelectImportToSites.Items.Count / MaxSitesPerColumns) + 1;
        if (columnCount > 1)
        {
            cblSelectImportToSites.RepeatColumns = Math.Min(columnCount, MaxColumns);
            cblSelectImportToSites.RepeatLayout  = RepeatLayout.Table;
            if ( columnCount > MaxColumns )
                pnSelectImportToSites.ScrollBars = ScrollBars.Vertical;
        }

        // Set focus
        cblSelectImportToSites.Focus();
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "focus", "$('#cblSelectImportToSites [checked]').focus();", true);
    }

    /// <summary>Validate SelectImportToSites page (always returns true)</summary>
    private bool ValidateSelectImportToSites()
    {
        return true;
    }

    /// <summary>Returns selected import to site numbers from SelectImportToSites page</summary>
    private IEnumerable<int> GetSelectedImportToSiteNumbers()
    {
        Sites sites = new Sites();
        sites.LoadAll(true);
        return sites.FindSiteNumberByID(GetSelectedImportToSiteIDs());
    }

    /// <summary>Returns selected import to site IDs from SelectImportToSites page</summary>
    private IEnumerable<int> GetSelectedImportToSiteIDs()
    {
        return cblSelectImportToSites.Items.Cast<ListItem>()
                                            .Where(s => s.Selected)
                                            .Select(s => int.Parse(s.Value));
    }
    #endregion

    #region DisplayEditor page
    /// <summary>Populates DisplayEditor page</summary>
    /// <param name="viewIndex">View index</param>
    /// <param name="products">Product to add</param>
    /// <param name="readOnlyFields">Extra fields forced to readonly (in addition to dss locked down fields)</param>
    /// <param name="forceEditable">Fields that should be editable (normal NSVCode)</param>
    private void PopulateDisplayEditor(int viewIndex, WProduct products, IEnumerable<int> readOnlyFields = null, IEnumerable<int> forceEditable = null)
    {
        // Ensure QuesScrl is initalised correctly
        ScriptManager.RegisterStartupScript(this, this.GetType(), "initDisplayEditor", "GPEUpdateLocalVariables(); divGPE_onResize(); $('[id^=\"editorControl\"]').focus();", true);

        // create processor
        WProductQSProcessor processor = new WProductQSProcessor(products, new [] { SessionInfo.SiteID });

        // Get DSS maintained field (and extra readonly fields))
        List<int> dssMaintainedFields = processor.GetDSSMaintainedDataIndex().ToList();
        if (readOnlyFields != null)
            dssMaintainedFields.AddRange(readOnlyFields);
        if (forceEditable != null)
            dssMaintainedFields.RemoveAll(d => forceEditable.Contains(d));  // 86052 10Mar14 XN Ensure warning for NSVCode

        // Initalise QuesScrl
        editorControl.ForceReadOnly = dssMaintainedFields.Distinct().ToArray();
        editorControl.Initalise(processor, "D|STKMAINT", "Views", "Data", viewIndex, false);
    }

    /// <summary>
    /// Validates DisplayEditor page
    /// Requires postback to perform full validation
    /// </summary>
    private bool ValidateDisplayEditor()
    {
        if (hfDisplayEditorValidated.Value == "1")
            return true;    // Validation has passed after postback so return true
        else
        {
            // Validate will display errors to user, and then postback with hfDisplayEditorValidated set to 1
            editorControl.Validate();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Resize", "GPEUpdateLocalVariables(); divGPE_onResize();", true);
            return false;
        }
    }

    /// <summary>
    /// Called when QuesScrl on DisplayEditor page is validated sucessfully
    /// Will set hfDisplayEditorValidated to 1 so when ValidateDisplayEditor is called will return that validation has passed
    /// </summary>
    protected void editorControl_OnValidated()
    {
        hfDisplayEditorValidated.Value = "1";
        //ScriptManager.RegisterStartupScript(this, this.GetType(), "Validated", "$('#btnNext').click()", true);    // 1Jul14 XN instead of doing postback call next button directly helps prevent adding duplicate drugs
        btnNext_OnClick(this, new EventArgs());
    }

    /// <summary>
    /// Called when QuesScrl on DisplayEditor page is has called saved data
    /// Will close page return new product NSVCode
    /// </summary>
    protected void editorControl_OnSaved()
    {
        WProductRow product = (editorControl.QSProcessor as WProductQSProcessor).Products.First();
        this.finished = true;       // 1Jul14 XN prevent next button being redisplayed on postback
        this.ClosePage(product.NSVCode);
    }

    /// <summary>Returns QuesScrl processor from DisplayEditor page</summary>
    private WProductQSProcessor GetDisplayEditorProduct()
    {
        return editorControl.QSProcessor as WProductQSProcessor;
    }
    #endregion

    #region Message page
    /// <summary>Populate Message page</summary>
    /// <param name="message">Message to display</param>
    private void PopulateMessage(string message)
    {
        spanMessage.InnerHtml = message;
    }

    /// <summary>Validate Message page (always returns true)</summary>
    private bool ValidateMessage()
    {
        return true;
    }
    #endregion

    #region EditMultipleSites page
    /// <summary>Populate EditMultipleSites page</summary>
    /// <param name="viewIndex">View index</param>
    /// <param name="products">Product to add</param>
    /// <param name="siteIDs">List of sites to display</param>
    private void PopulateEditMultipleSites(int viewIndex, WProduct products, IEnumerable<int> siteIDs)
    {
        // Ensure QuesScrl is initalised correctly
        ScriptManager.RegisterStartupScript(this, this.GetType(), "initDisplayEditor", "GPEUpdateLocalVariables(); divGPE_onResize(); $('[id^=\"editMultipleSites\"]').focus();", true);

        // create processor
        WProductQSProcessor processor = new WProductQSProcessor(products, siteIDs);

        // Initalise QuesScrl
        editMultipleSites.ForceReadOnly = processor.GetDSSMaintainedDataIndex();
        editMultipleSites.Initalise(processor, "D|STKMAINT", "Views", "Data", viewIndex, false);
    }

    /// <summary>
    /// Validates EditMultipleSites page
    /// Requires postback to perform full validation
    /// </summary>
    private bool ValidateEditMultipleSites()
    {
        if (hfEditMultipleSitesValidated.Value == "1")
            return true;    // Validation has passed after postback so return true
        else
        {
            // Validate will display errors to user, and then postback with hfEditMultipleSitesValidated set to 1
            editMultipleSites.Validate();
            ScriptManager.RegisterStartupScript(this, this.GetType(), "Resize", "GPEUpdateLocalVariables(); divGPE_onResize();", true);
            return false;
        }
    }

    /// <summary>
    /// Called when QuesScrl on EditMultipleSites page is validated sucessfully
    /// Will set hfEditMultipleSitesValidated to 1 so when ValidateEditMultipleSites is called will return that validation has passed
    /// </summary>
    protected void editMultipleSites_Validated()
    {
        hfEditMultipleSitesValidated.Value = "1";
        //ScriptManager.RegisterStartupScript(this, this.GetType(), "Validated", "$('#btnNext').click()", true);    // 1Jul14 XN instead of doing postback call next button directly helps prevent adding duplicate drugs
        btnNext_OnClick(this, new EventArgs());
    }
    #endregion

    #region Helper Methods
    /// <summary>
    /// Set the next step the wizard is moving to
    /// Also set the title prefix for the next step (depends on step type)
    /// </summary>
    /// <param name="nextStep">Step to move to</param>
    private void SetStep(WizardSteps nextStep)
    {
        string headerPrefix = string.Empty;

        switch (nextStep)
        {
        case WizardSteps.SelectAddMethodType:   headerPrefix = "Choose Product Type";             multiView.SetActiveView(vSelectAddMethodType);  break;
        case WizardSteps.SelectImportFromSite:  headerPrefix = "Select import from site";         multiView.SetActiveView(vSelectImportFromSite); break;
        case WizardSteps.FindDrug:
            switch (this.GetSelectedAddMethodType())
            {
            case AddMethodType.ImportFromMasterFile: headerPrefix = "Select Item"; break;
            case AddMethodType.ImportFromOtherSite:  headerPrefix = "Select item from " + (new SiteProcessor()).LoadBySiteID(GetSelectedImportFromSiteID()).LocalHospitalAbbreviation; break;
            case AddMethodType.MedicinalProduct:     headerPrefix = WConfiguration.Load<string>(SessionInfo.SiteID, "D|StkMaint", "Dialogue", "ProductCopy", "Select product to copy from", false); break;
            }
            multiView.SetActiveView(vFindDrug);
            break;
        case WizardSteps.FindProduct:                                                               multiView.SetActiveView(vFindProduct);          break;
        case WizardSteps.NMPList:               headerPrefix = "Select NMP";                        multiView.SetActiveView(vNMPList);              break;  
        case WizardSteps.MedicalProductAddType: headerPrefix = "Choose Operation";                  multiView.SetActiveView(vMedicalProductAddType);break;
        case WizardSteps.AMPPList:              headerPrefix = "Select AMPP";                       multiView.SetActiveView(vAMPPList);             break;
        case WizardSteps.HTMLInfoPanel:                                                             multiView.SetActiveView(vHTMLInfoPanel);        break;
        case WizardSteps.DisplayEditor:         headerPrefix = editorControl.QSView.ViewDescription;multiView.SetActiveView(vDisplayEditor);        break;
        case WizardSteps.SelectImportToSites:   headerPrefix = "Select other sites to import to";   multiView.SetActiveView(vSelectImportToSites);  break;
        case WizardSteps.EditMultipleSites:     headerPrefix = editorControl.QSView.ViewDescription;multiView.SetActiveView(vEditMultipleSites);    break;
        case WizardSteps.Message:               headerPrefix = "Info";                              multiView.SetActiveView(vMessage);              break;    
        }

        // Set page header
        spanHeader.InnerHtml = headerPrefix + " " + hfHeaderSuffix.Value;
        spanHeader.InnerHtml = spanHeader.InnerHtml.TrimStart(new [] { '-', ' ' });
        divHeader.Visible = !string.IsNullOrWhiteSpace(spanHeader.InnerHtml);

        // Save step
        hfCurrentStep.Value = nextStep.ToString();
    }

    /// <summary>
    /// Returns (no template available) if product does not have template
    /// otherwise returns empty string
    /// 
    /// 26Feb15 XN Fixed issue if ProductID is null will then error
    /// </summary>
    /// <param name="productID">Product ID</param>
    private string CheckIfProductHasTemplate(int? productID)
    {
        if (productID == null || !Product.HasTemplate(productID.Value))
            return "<span class='ErrorMessage'>(no template available)</span>";    
        return string.Empty;
    }

    /// <summary>Initalise product fields</summary>
    /// <param name="productRow">Fields to initalise</param>
    /// <param name="includeStockItems">If to initalise stock fields</param>
    private void InitWProduct(WProductRow productRow, bool includeStockItems)
    {
        DateTime now = DateTime.Now;
        productRow.SupplierCode             = string.Empty;
        productRow.WSupplierProfileID       = 0;
        productRow.ProductStockID           = 0;
        productRow.SiteID                   = SessionInfo.SiteID;
        productRow.DSSMasterSiteID          = Sites.GetDSSMasterSiteID(SessionInfo.SiteID);
        productRow.CreatedDate              = now;
        productRow.CreatedOnTerminal        = SessionInfo.Terminal.SafeSubstring    (0, WProduct.GetColumnInfo().CreatedOnTerminalLength    );
        productRow.CreatedByUserInitials    = SessionInfo.UserInitials.SafeSubstring(0, WProduct.GetColumnInfo().CreatedByUserInitialsLength);
        productRow.ModifiedDate             = now;
        productRow.ModifiedOnTerminal       = SessionInfo.Terminal.SafeSubstring    (0, WProduct.GetColumnInfo().ModifiedOnTerminalLength    );
        productRow.ModifiedByUserInitials   = SessionInfo.UserInitials.SafeSubstring(0, WProduct.GetColumnInfo().ModifiedByUserInitialsLength);
        productRow.OutstandingInIssueUnits  = 0;
        productRow.AlternateSupplierCode    = string.Empty;
        productRow.ContractNumber           = string.Empty;
        productRow.ContractPrice            = null;
        productRow.CycleLengthInDays        = 0;
        productRow.StartOfPeriod            = now;
        productRow.LastIssuedDate           = null;
        productRow.LastOrderedDate          = null;
        productRow.LastStockTakeDateTime    = null;
//        productRow.LeadTimeInDays           = 1;
        productRow.Location                 = string.Empty;
        productRow.Location2                = string.Empty;
        productRow.LossesGainExVat          = 0;
//        productRow.LastReceivedPriceExVatPerPack = 0;         85353 03Mar14 XN Getting default to match v8
        productRow.SupplierTradename        = string.Empty;
        productRow.SupplierReferenceNumber  = string.Empty;
        productRow.UseThisPeriodInIssueUnits= 0;
        productRow.IfLiveStockControl       = true;
        productRow.StockTakeStatus          = StockTakeStatusType.Waiting;
        productRow.RawRow["reorderqty"]     = DBNull.Value;
        productRow.ReorderLevelInIssueUnits = null;
        productRow.StockLevelInIssueUnits   = 0;    // 85353 03Mar14 XN Getting default to match v8

        //07Aug14 TH Reset Anual usage (TFS 95942)
        productRow.AnnualUsageInIssueUnits = 0;

        if (productRow.MinDailyDose == null)
            productRow.MinDailyDose = 0;
        if (productRow.MaxDailyDose == null)
            productRow.MaxDailyDose = 0;
        if (productRow.MinDoseFrequency == null)
            productRow.MinDoseFrequency = 0;
        if (productRow.MaxDoseFrequency == null)
            productRow.MaxDoseFrequency = 0;
        if (string.IsNullOrEmpty(productRow.WarningCode))
            productRow.WarningCode = string.Empty;  
        if (string.IsNullOrEmpty(productRow.WarningCode2))
            productRow.WarningCode2 = string.Empty;
        if (string.IsNullOrEmpty(productRow.DPSForm))
            productRow.DPSForm = string.Empty;
        if (string.IsNullOrEmpty(productRow.PASANPCCode))
            productRow.PASANPCCode = string.Empty;

        // Always auto generate barcode if not master or import
        // Auto generate barcode if not set
        if ((this.GetSelectedAddMethodType() != AddMethodType.ImportFromMasterFile &&
             this.GetSelectedAddMethodType() != AddMethodType.ImportFromOtherSite) ||
            string.IsNullOrEmpty(productRow.Barcode))
        {
            try
            {
                productRow.Barcode = Barcode.GenerateEANDrugBarcode(productRow.NSVCode);
            }
            catch (ApplicationException ex)
            {
                string msg = (string.Format("Unable to generate EAN Barcode from {0}\\n", productRow.NSVCode) + ex.Message).Replace("'", "\\'");
                string script = string.Format("alert('{0}');window.close();", msg);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "EAN Barcode Error", script, true); // and close the current window
            }
        }

        if (includeStockItems)
        {
            productRow.InUse                  = true;
            productRow.IsCytotoxic            = false;
            productRow.IsCIVAS                = false;
            productRow.FormularyType          = FormularyType.Yes;
            productRow.IsStocked              = true;
            productRow.VATCode                = 1;
            productRow.ReCalculateAtPeriodEnd = true;
//            productRow.ReOrderQuantityInPacks = 0;
//            productRow.StockLevelInIssueUnits = 0;
        }
    }

    /// <summary>
    /// Create and returns WProductRow for each site in list
    /// First save DisplayEditor QuesScrl data localy (not to db)
    /// Then creates and poplates new WProduct for each site in siteIDs with same values from DisplayEditor excluding
    ///     Supplier code
    ///     reorder level issue units
    ///     reorder qty
    ///     location
    ///     location 2
    /// </summary>
    private WProduct ImportProductToSite(IEnumerable<int> siteIDs)
    {
        editorControl.QSProcessor.Save(editorControl.QSView, false); // Little hack to force update of data (for the import to sites)
        WProduct currentProducts = (editorControl.QSProcessor as WProductQSProcessor).Products;

        WProductRow sourceProduct = currentProducts.FindBySiteID(SessionInfo.SiteID).First();
        
        WProduct newProduct = new WProduct();
        foreach (int siteID in siteIDs)
        {
            if (!currentProducts.FindBySiteID(siteID).Any())
            {
                WProductRow newProductRow = newProduct.Add();
                newProductRow.CopyFrom(sourceProduct);
                newProductRow.SiteID                   = siteID;
                newProductRow.SupplierCode             = string.Empty;
                newProductRow.ReorderLevelInIssueUnits = null;
                newProductRow.RawRow["reorderqty"]     = DBNull.Value;
                newProductRow.Location                 = string.Empty;
                newProductRow.Location2                = string.Empty;
            }
        }

        return newProduct;
    }
    
    /// <summary>
    /// Update the barcode (generated from NSVCode), and the last received price (sislistprice) fields, and Supplier Tradname, before save to db
    /// done here as these fields are (not editable or presnet in QuesScrl so not covered by validation) and dependant on other fields (that need to be filled in by user).
    /// </summary>
    /// <param name="quesScrlData"></param>
    private void UpdateBeforeSaving(QuesScrl quesScrlData)
    {
        QSDataInputItem     barcodeInput           = quesScrlData.QSView.FindByDataIndex(WProductQSProcessor.DATAINDEX_BARCODE          );
        QSDataInputItem     NSVCodeInput           = quesScrlData.QSView.FindByDataIndex(WProductQSProcessor.DATAINDEX_NSVCODE          );
        QSDataInputItem     lastReceivedPriceInput = quesScrlData.QSView.FindByDataIndex(WProductQSProcessor.DATAINDEX_LASTRECEIVEDPRICE);
        QSDataInputItem     costInput              = quesScrlData.QSView.FindByDataIndex(WProductQSProcessor.DATAINDEX_COST             );
        QSDataInputItem     tradenameInput         = quesScrlData.QSView.FindByDataIndex(WProductQSProcessor.DATAINDEX_TRADENAME        );
        WProductQSProcessor processor              = quesScrlData.QSProcessor as WProductQSProcessor;
        
        foreach(var p in processor.Products)
        {
            // If barcode not set then populate
            var barcode = barcodeInput != null ? barcodeInput.GetValueBySiteID(p.SiteID) : p.Barcode;
            var NSVCode = NSVCodeInput != null ? NSVCodeInput.GetValueBySiteID(p.SiteID) : p.NSVCode;
            if (string.IsNullOrEmpty(barcode) && !string.IsNullOrEmpty(NSVCode))
            {
                if (barcodeInput != null && barcodeInput.Enabled)   // Only saves if field is enables
                    barcodeInput.SetValueBySiteID(p.SiteID, Barcode.GenerateEANDrugBarcode(NSVCode));
                else 
                    p.Barcode = Barcode.GenerateEANDrugBarcode(NSVCode);
            }

            // Update Last received price to cost if not set
            var lastReceivedPrice = lastReceivedPriceInput != null ? lastReceivedPriceInput.GetValueBySiteID(p.SiteID) : p.LastReceivedPriceExVatPerPack.ToString();
            var cost              = costInput              != null ? costInput.GetValueBySiteID(p.SiteID)              : p.AverageCostExVatPerPack.ToString();
            if (string.IsNullOrEmpty(lastReceivedPrice) && !string.IsNullOrEmpty(cost) && double.Parse(cost) != 0)
            {
                if (lastReceivedPriceInput != null && lastReceivedPriceInput.Enabled)   // Only saves if field is enables
                    lastReceivedPriceInput.SetValueBySiteID(p.SiteID, cost);
                else
                    p.LastReceivedPriceExVatPerPack = decimal.Parse(cost);
            }

            // If Supplier Tradname the populate  28Oct14 XN  100212
            var tradename = tradenameInput != null ? tradenameInput.GetValueBySiteID(p.SiteID) : p.Tradename.ToString();
            if ( string.IsNullOrEmpty(p.SupplierTradename) && string.IsNullOrEmpty(tradename) )
                p.SupplierTradename = tradename;
        }
    }
    #endregion
}
