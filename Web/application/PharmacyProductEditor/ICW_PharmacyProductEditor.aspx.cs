//==============================================================================================
//
//      					    ICW_PharmacyProductEditor.aspx.cs
//
//  ICW desktop for the pharamcy product editor. 
//  Allows editing a single site or multiple sites depending on the desktop editor
//
//  The class uses values from WConfiguration Category D|STKMAINT
//  All the data is read from WProduct
//
//  The page uses an embedded vb6 client site Pharmacy Product Editor for communicating to robots
//
//  The desktop has the following desktop parameters
//  AscribeSiteNumber           - Main ascribe site number for the desktop
//  EditableSiteNumbers         - CSV list of other sites the user can edit (default none) can use "All" for all sites
//  ViewIndexToDisplay          - Pharmacy WConfiguration view indexes to display
//  ActriveXControl             - If activeX control on page (used for send to robot) is enabled. Disable to get rid of active X error (default enabled)
//  ImportFromSiteNumbers       - Used by add wizard, and is a CSV list site numbers user is allowed to import from default is All
//  ShowAddFromMaster           }
//  ShowAddFromOther            }
//  ShowAddMP                   } - Controls add options avaiable to the user
//  ShowAddNMP                  }
//  ShowAddStoresOnly           }
//  ShowAddFromExisting         }
//  DebugMode                   - If in debug mode
//  ConfigurationEditor         - if allowed to edit desktop configuration (options are None,Desktop)
//
//	Modification History:
//	23Jan14 XN  Written
//  12Mar14 XN  Added ConfigurationEditor parameter
//  24Jun14 XN  Update SetPrimarySupplier to use new BaseTable2 locking 43318
//  11Nov14 XN  Updated btnPrintShelfLabel_OnClick after changes to XMLHeap 43318
//  18Nov14 XN  Indicate when items are saved  104369    
//  20Oct14 XN  SetView: On adding supplier profile copy product tradename to supplier tradename (100212)
//  17Jun15 XN  Remove possible duplication of sites from EditableSiteNumbers 117765
//  19Feb16 XN  Fix for shelf label printing (moved to SSRS report) 124812
//  24May16 XN  Replace the shelf edge label printing with on that uses the AscribePrintJob 124812
//  11Apr18 DR  Bug 209612 - Pharmacy Product Editor - Can edit Product Tradename field against a VMPP maintained by DSS when should not be able to
//==============================================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Xml;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacyProductEditor_ICW_PharmacyProductEditor : System.Web.UI.Page
{
    #region Data Types
    protected  enum ConfigurationEditorMode
    {
        None,
        Desktop
    }
    #endregion

    #region Variables
    protected List<int>    editableSiteNumbers;
    protected string       viewIndexesToDisplayStr;
    protected bool         debugMode;   // Should be set via desktop parameter but currently not set
    protected string       URLtoken;
    protected bool         isActiveXControlEnabled;
    protected ConfigurationEditorMode configurationEditor;
    protected string       applicationPath; // 24May16 124812 XN added
    #endregion

    #region Properties
    /// <summary>Currently selected view index</summary>
    protected int CurrentViewIndex
    {
        get { return int.Parse(hfViewIndex.Value);  }
        set { hfViewIndex.Value = value.ToString(); }
    }

    /// <summary>Currently selected NSV Code</summary>
    protected string NSVCode
    {
        get { return hfNSVCode.Value;  }
        set { hfNSVCode.Value = value; }
    }

    /// <summary>Currently selected Supplier code (for some options)</summary>
    protected string SupCode
    {
        get { return hfSupCode.Value;  }
        set { hfSupCode.Value = value; }
    }

    /// <summary>ProductStock soft locker object</summary>
    protected SoftLockResults ProductStockLocker
    {
        get
        {
            if (string.IsNullOrEmpty(hfProductStockLocker.Value))
                return new SoftLockResults("ProductStock");

            SoftLockResults productStockLocker = new SoftLockResults("ProductStock");

            // Setup string as XML fragment
            XmlReaderSettings settings = new XmlReaderSettings();
            settings.ConformanceLevel = ConformanceLevel.Fragment;

            // Read xml string
            using (XmlReader reader = XmlReader.Create(new StringReader(hfProductStockLocker.Value), settings))
                productStockLocker.ReadXml(reader);
            return productStockLocker;
        }
        set
        {
            // Setup to write xml fragment
            XmlWriterSettings settings = new XmlWriterSettings();
            settings.Indent             = false;
            settings.OmitXmlDeclaration = true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Write xml string
            StringBuilder str = new StringBuilder();
            using(XmlWriter writer = XmlWriter.Create(str, settings))
            {
                value.WriteXml(writer);
                writer.Flush();
                writer.Close();
            }

            hfProductStockLocker.Value = str.ToString();
        }
    }
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        //// Get list of editable sites 17Jun15 XN 117765 removed
        //if (Request["EditableSiteNumbers"].EqualsNoCaseTrimEnd("All"))
        //{
        //    Sites sites = new Sites();
        //    sites.LoadAll(true);
        //    editableSiteNumbers = sites.Select(s => s.SiteNumber).ToList();
        //}
        //else
        //    editableSiteNumbers = (Request["EditableSiteNumbers"] ?? string.Empty).ParseCSV<int>(",", true).ToList();

        ///// Add current Site to list
        //editableSiteNumbers.Remove(SessionInfo.SiteNumber      ); // Prevent duplicates
        //editableSiteNumbers.Insert(0,  SessionInfo.SiteNumber  );

        this.editableSiteNumbers= Site2.Instance().FindBySiteNumber(Request["EditableSiteNumbers"], true, CurrentSiteHandling.AtStart).Select(s => s.SiteNumber).ToList();  // 17Jun15 XN 117765
        viewIndexesToDisplayStr = Request["ViewIndexToDisplay"] ?? "All";
        isActiveXControlEnabled = string.IsNullOrEmpty(Request["ActiveXControl"]) || Request["ActiveXControl"].EqualsNoCaseTrimEnd("Enable");
        debugMode               = BoolExtensions.PharmacyParse(Request["DebugMode"] ?? "false");
        configurationEditor     = (ConfigurationEditorMode)Enum.Parse(typeof(ConfigurationEditorMode), Request["ConfigurationEditor"] ?? "None");
        applicationPath         = Request["ApplicationPath"] ?? string.Empty;  // 24May16 124812 XN added for printing shelf edge label

        if (this.IsPostBack)
        {
            // If doing update suppress building of view (else will create twice as many fields)
            string args = Request["__EVENTARGUMENT"];
            if (!string.IsNullOrEmpty(args) && args.StartsWith("Update:") && this.GetActiveQuesScrlControl() != null)
                this.GetActiveQuesScrlControl().SuppressControlCreation = true;
        }
        else
        {
            GENRTL10.SettingRead settingRead = new GENRTL10.SettingRead();
            string URLScheme = settingRead.GetValue(SessionInfo.SessionID, "Pharmacy", "WebConnection", "URLscheme", Request.Url.Scheme);
            int intPortNumber = settingRead.GetPortNumber(SessionInfo.SessionID, "Pharmacy", "Database", "PortNoWebTransport");

            if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
            {
                // URL token for embedded client side control
                //URLtoken = Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(SessionInfo.SessionID) + "&SessionId=" + SessionInfo.SessionID;
                URLtoken = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(SessionInfo.SessionID) + "&SessionId=" + SessionInfo.SessionID;
            }
            else
            {
                URLtoken = URLScheme + Uri.SchemeDelimiter + Request.Url.Host + ":" + intPortNumber + Request.ApplicationPath + "/integration/Pharmacy/GetEncryptedString.aspx?token=" + secrtl_c.TokenGenerator.GenerateToken(SessionInfo.SessionID) + "&SessionId=" + SessionInfo.SessionID;
            } 
            // Get the shelf edge label filename
            hfShelfEdgeLabelFliename.Value = Path.Combine(SiteInfo.DispdataDRV(), "shelflbl.rtf");;

            // Populate list of views
            PopulateViewList();
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        string args = Request["__EVENTARGUMENT"];

        // Deal with __postBack events
        string[] argParams = new string[] { string.Empty };
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' });

        switch (argParams[0])
        {
        case "Update":
            {
                // Update has been requested                 
                bool refresh   = BoolExtensions.PharmacyParse(argParams[1]);   // parameter 1 is if doing refresh, else complete page refresh
                bool justSaved = BoolExtensions.PharmacyParse(argParams[2]);   // If update is for an item that has been saved (in which case show Saved text)
                if (!string.IsNullOrEmpty(this.NSVCode))
                {
                    SetDrug(justSaved);
                    SetView(refresh  );
                }
            }
            break;

        case "SetPrimary":
            {
                // Set new primary supplier to this.SupCode
                SetPrimarySupplier();
                SetView(true);
            }
            break;

        case "DeleteSupplier":
            {
                // Deletes currently selected supplier set in this.SupCode
                DeleteSupplier();
                SetDrug(false);
                SetView(false);
            }
            break;
        }
    }

    /// <summary>
    /// Parses the shelf edge label (uses ShelfLbl.rtf)
    /// 24May16 124812 added XN 
    /// </summary>
    /// <param name="sessionId">Session id</param>
    /// <param name="siteId">Site id</param>
    /// <param name="NSVCode">Nsv code </param>
    /// <param name="rtf">RTF for the shelf edge label</param>
    /// <returns>parsed shelf edge label</returns>
    [WebMethod]
    public static string ParseShelfEdgeLabel(int sessionId, int siteId, string NSVCode, string rtf)
    {
        SessionInfo.InitialiseSessionAndSiteID(sessionId, siteId);

        // Get the product row
        WProductRow product = WProduct.GetByProductAndSiteID(NSVCode, SessionInfo.SiteID);

        //GetRTF from Name
        PharmacyRTFReportRow RTFReport = PharmacyRTFReport.GetByNameAndSiteID(rtf, SessionInfo.SiteID);

        // Parse the product XML
        RTFParser parser = new RTFParser();
        parser.Read(RTFReport.Report);
        parser.ParseXML(product.ToXMLHeap());

        return parser.ToString();
    }

    /// <summary>Called by client to clean up row locking</summary>
    /// <param name="sessionID">session ID</param>
    /// <param name="lockText">hfProductStockLocker data</param>
    [WebMethod]
    public static void CleanUp(int sessionID, string lockDataXML)
    {
        SessionInfo.InitialiseSession(sessionID);
        UnSoftLockRows(lockDataXML);
    }

    /// <summary>
    /// Called when user changes supplier in the contract editor
    /// Updates the page header
    /// </summary>
    /// <param name="NSVCode">Currently selected NSVCode in contract editor</param>
    /// <param name="supCode">Newly selected supplier code</param>
    protected void contractEditor_OnSupplierCodeUpdated(string NSVCode, string supCode)
    {
        SupCode = supCode;
        SetDrug(false);
    }

    /// <summary>
    /// Called when any of the controls have validate sucessfully
    /// Will call save on the control
    /// </summary>
    protected void control_OnValidated()
    {
        if (this.GetActiveQuesScrlControl() != null)
            this.GetActiveQuesScrlControl().Save();
    }

    /// <summary>
    /// Called when any of the controls have saved sucessfully
    /// Will cause refresh of data
    /// </summary>
    protected void control_OnSaved()
    {
        ScriptManager.RegisterStartupScript(this, this.GetType(), "Update", "clearIsPageDirty(); Update(true, true);", true);                       
    }

    /// <summary>
    /// Called when save button is clicked
    /// Validates the conrols data
    /// </summary>
    protected void btnSave_OnClick(object sender, EventArgs e)
    {
        if (this.GetActiveQuesScrlControl() != null)
            this.GetActiveQuesScrlControl().Validate();
    }
    #endregion

    #region Private Methods
    private IQSViewControl GetActiveQuesScrlControl()
    {
        return this.multiView.GetActiveView() == null ? null : this.multiView.GetActiveView().GetAllControlsByType<IQSViewControl>().FirstOrDefault();
    }

    /// <summary>Updates drug info</summary>
    /// <param name="showSaved">If to show save button</param>
    private void SetDrug(bool showSaved)
    {
        WProduct products = new WProduct();
        products.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);

        WProductRow product = products.FirstOrDefault();
        bool hasProductID = (product.ProductID ?? 0) > 0;

        lbDescription.InnerText     = product.ToString();
        lbPrescriptionTitle.Visible = hasProductID;
        lbPrescription.InnerText    = hasProductID ? Product.GetDescriptionByProductID(product.ProductID.Value) : string.Empty;
        lbTradename.InnerText       = product.GetTradename();
        
        if (string.IsNullOrEmpty(this.SupCode) || this.SupCode == product.SupplierCode)
            lbPackSize.InnerText = product.ReorderPackSizeAsFormattedString();
        else
        {
            WSupplierProfile profile = new WSupplierProfile();
            profile.LoadBySiteIDSupplierAndNSVCode(SessionInfo.SiteID, this.SupCode, NSVCode);
            if (!profile.Any())
                profile.Add();
            lbPackSize.InnerText = profile.First().ReorderPackSizeAsFormattedString(product.ConversionFactorPackToIssueUnits, product.PrintformV);
        }

        lbNSVCode.InnerText     = product.NSVCode;
        lbLookupCode.InnerText  = product.Code;
        lbSupCodeTitle.Visible  = !string.IsNullOrEmpty(this.SupCode);
        lbSupCode.InnerText     = this.SupCode;

        SiteProductDataRow masterProduct = SiteProductData.GetByDrugIDAndMasterSiteID(product.DrugID, 0);
        if (masterProduct != null)
            lbDSS.InnerText = string.IsNullOrEmpty(masterProduct.Tradename) ? "V" : "A";
        else
            lbDSS.InnerText = "No";

        lbStoresOnly.InnerText  = product.IsStoresOnly.ToYesNoString();

        saveIndicator.ShowSavedText(showSaved); // 18Nov14 XN  Indicate when items are saved  104369
        saveIndicator.Update();
    }

    /// <summary>Updates view info</summary>
    /// <param name="refresh">Refreshes that data</param>
    private void SetView(bool refresh)
    {
        bool isPageDirty = false;

        multiView.ActiveViewIndex = -1;
        notFoundOnSites.InnerHtml = string.Empty;
        btnSetPrimary.Visible     = false;
        btnDeleteSupplier.Visible = false;

        Sites sites = new Sites();
        sites.LoadAll();

        WProduct products = new WProduct();

        switch (this.CurrentViewIndex)
        {
        case WProductQSProcessor.VIEWINDEX_UPDATESERVICE:    // Update Service View
            multiView.ActiveViewIndex = 1;
            updateService.Initalise(this.NSVCode);

            notFoundOnSites.InnerHtml = "<span class='ErrorMessage'>Changes will affect all stockholdings</span>";

            // Lock rows (never prevents editing if lock fails)
            products.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);
            products.ConflictOption = ConflictOption.CompareAllSearchableValues;    // 86723 XN 20Mar13 Added soft lock
            SoftLockRows(products);
            break;

        case WProductQSProcessor.VIEWINDEX_GLOBAL_PRODUCT_FIELDS:  // Global Product Fields
            {
            products.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);
            products.ConflictOption = ConflictOption.CompareAllSearchableValues;    // 86723 XN 20Mar13 Added soft lock

            WProductQSProcessor productProcessor = new WProductQSProcessor(products, new[] { SessionInfo.SiteID });

            // If DSS maintained drug, and DSS on Web is enabled then disable extra fields
            editorControl.ForceReadOnly = productProcessor.GetDSSMaintainedDataIndex();

            multiView.ActiveViewIndex  = 0;
            editorControl.ShowHeaderRow= false;
            editorControl.Initalise(productProcessor, "D|STKMAINT", "Views", "Data", CurrentViewIndex, true);

            notFoundOnSites.InnerHtml = string.Format("<span class='titleLabel'>{0}</span><br /><span class='ErrorMessage'>Changes will affect all stockholdings</span>", editorControl.QSView.ViewDescription);

            // Lock rows (never prevents editing if lock fails)
            SoftLockRows(products);
            }
            break;

        case WProductQSProcessor.VIEWINDEX_ALTERNATE_BARCODES:  // Alternate Barcodes
            multiView.ActiveViewIndex = 2;
            alternateBarcodes.Initalise(NSVCode);
            
            // Lock rows (never prevents editing if lock fails)
            products.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);
            SoftLockRows(products);
            break;

        case WProductQSProcessor.VIEWINDEX_EDIT_SUPPLIERPROFILE:    // Edit Supplier Profile
            if (refresh)
            {
                bool addMode = false;

                // 20Oct14 XN 100212 Made bits below common
                products.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);
                WProductRow product = products.FirstOrDefault();

                WSupplierProfile supplierProfile = new WSupplierProfile();
                supplierProfile.LoadBySiteIDSupplierAndNSVCode(SessionInfo.SiteID, this.SupCode, NSVCode);
                supplierProfile.ConflictOption = ConflictOption.CompareAllSearchableValues;
                if (!supplierProfile.Any())
                {
                    WSupplierProfileRow supplierProfileRow = supplierProfile.Add();
                    supplierProfileRow.SupplierCode = this.SupCode;
                    supplierProfileRow.NSVCode      = this.NSVCode;
                    supplierProfileRow.SiteID       = SessionInfo.SiteID;
                    supplierProfileRow.LastReceivedPriceExVatPerPack = 0;
                    supplierProfileRow.ContractPrice= 0;
                    // supplierProfileRow.VATCode = WProduct.GetByProductAndSiteID(NSVCode, SessionInfo.SiteID).VATCode;  20Oct14 XN 100212
                    supplierProfileRow.VATCode      = (product == null) ? (int?)null : product.VATCode;
                    supplierProfileRow.SupplierTradename = (product == null) ?  string.Empty : product.Tradename;   // 20Oct14 XN 100212 Copy product tradename to supplier
                    addMode = true;
                    isPageDirty = true;
                }

                WSupplierProfileQSProcessor processor = new WSupplierProfileQSProcessor(supplierProfile, new [] { SessionInfo.SiteID });

                // Get if supplier is primary supplier
                //products.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID); 20Oct14 XN 100212 Moved above if
                //WProductRow product = products.FirstOrDefault();
                bool primarySupplier = (product != null && supplierProfile.Any() && product.SupplierCode.EqualsNoCaseTrimEnd(supplierProfile.First().SupplierCode));

                editorControl.ShowHeaderRow = false;
                multiView.ActiveViewIndex       = 0;

                // Update supplier buttons
                btnSetPrimary.Visible     = true;
                btnSetPrimary.Enabled     = !primarySupplier;
                btnDeleteSupplier.Visible = true;
                btnDeleteSupplier.Enabled = !primarySupplier;

                // Create the control
                editorControl.ForceReadOnly = processor.GetDSSMaintainedDataIndex();    // If DSS maintained drug, and DSS on Web is enabled then disable extra fields

                // if the global tradename is blank, allow editing of the supplier profile trade name.
                if (product != null && product.IsDSSMaintainedDrug() && string.IsNullOrWhiteSpace(product.Tradename))
                {
                    var colnames = editorControl.ForceReadOnly.ToList();
                    colnames.Remove(WSupplierProfileQSProcessor.DATAINDEX_TRADENAME);
                    editorControl.ForceReadOnly = colnames.ToArray();
                }

                editorControl.Initalise(processor, "D|SUPPROF", "Views", "Data", 1, !addMode);

                // Lock rows (never prevents editing if lock fails)
                SoftLockRows(products);
            }
            else
            {
                // Create the control
                string script = string.Format("SelectSupplierProfile({0}, '{1}', 'ES');", this.CurrentViewIndex, NSVCode);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "SelectSupplier", script, true);
            }
            break;

        case WProductQSProcessor.VIEWINDEX_EDIT_SUPPLIER_CONTRACT:
            if (refresh)
            {
                multiView.ActiveViewIndex = 3;
                contractEditor.Initalise(NSVCode, SupCode);

                // Lock rows (never prevents editing if lock fails)
                // Note that the manual contract editor still implements full locking
                products.LoadByProductAndSiteID(NSVCode, SessionInfo.SiteID);
                SoftLockRows(products);
            }
            else
            {
                string script = string.Format("SelectSupplierProfile({0}, '{1}', 'E');", CurrentViewIndex, NSVCode);
                ScriptManager.RegisterStartupScript(this, this.GetType(), "SelectSupplier", script, true);
            }
            break;

        case WProductQSProcessor.VIEWINDEX_SEND_TO_ROBOT:
            multiView.ActiveViewIndex = -1;
            {
                string script;
                if (this.isActiveXControlEnabled)
                    script = string.Format("$('#objPharmacyProductEditor')[0].SendToRobot({0}, '{1}');", SessionInfo.SessionID, NSVCode);
                else
                    script = string.Format("alert('Desktop parameter ActiveXControl=Disabled so this feature has been disabled.');");
                ScriptManager.RegisterStartupScript(this, this.GetType(), "SendToRobot", script, true);
            }
            break;

        default:
            {
            products.LoadByNSVCode(NSVCode);
            products.ConflictOption = ConflictOption.CompareAllSearchableValues;

            IEnumerable<int> siteIDs = new HashSet<int>(sites.FindSiteIDBySiteNumber(this.editableSiteNumbers));
            products.RemoveAll(p => !siteIDs.Contains(p.SiteID));
            products.DeletedItemsTable.AcceptChanges();

            WProductQSProcessor productProcessor = new WProductQSProcessor(products, siteIDs);

            // If DSS maintained drug, and DSS on Web is enabled then disable extra fields
            editorControl.ForceReadOnly = productProcessor.GetDSSMaintainedDataIndex();

            // Create the control
            multiView.ActiveViewIndex  = 0;
            editorControl.ShowHeaderRow= true;
            editorControl.Initalise(productProcessor, "D|STKMAINT", "Views", "Data", this.CurrentViewIndex, true);

            // Sort out invalid site numbers
            HashSet<int>     validSiteIDs   = new HashSet<int>(products.Select(p => p.SiteID));
            IEnumerable<int> invalidSiteIDs = siteIDs.Where(s => !validSiteIDs.Contains(s));
            if (invalidSiteIDs.Any())
                notFoundOnSites.InnerHtml = "<b>Not available on sites:</b> " + sites.FindSiteNumberByID(invalidSiteIDs).Select(s => s.ToString("000")).ToCSVString(", ");
            
            // Lock rows (never prevents editing if lock fails)
            SoftLockRows(products);
            }
            break;
        }

        ScriptManager.RegisterStartupScript(this, this.GetType(), "SetDirtyFlag", isPageDirty ? "setIsPageDirty();" : "clearIsPageDirty();", true);
    }

    /// <summary>Sets the currently selected supplier as primary</summary>
    private void SetPrimarySupplier()
    {
        // Check oif supplier profile exists (before setting as primary) this may occur in add mode
        if (WSupplierProfile.GetBySiteIDSupplierAndNSVCode(SessionInfo.SiteID, this.SupCode, this.NSVCode) == null)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", "alertEnh('Save changes before setting as primary.');", true);
            return;
        }

        // Set primary supplier
        try
        {
            using (ProductStock productStock = new ProductStock())
            {
                //  productStock.EnabledRowLocking = true;  // Need to lock  
                productStock.RowLockingOption = LockingOption.HardLock;     // Need to lock 24Jun14 43318 new locking method
                productStock.LoadBySiteIDAndNSVCode(this.NSVCode, SessionInfo.SiteID);
                if (productStock.Any())
                {
                    productStock.First().PrimarySupplierCode = this.SupCode;
                    productStock.First().UpdateModifiedDetails(DateTime.Now);   // 19May15 XN 117528 
                }
                
                productStock.Save(saveToPharmacyLog: true);
            }
        }
        catch (LockException ex)
        {
            string script = string.Format("alertEnh('Records in use by user \"{0}\" (EntityID: {1}).<br />Please try again in a few minutes?')", ex.GetLockerUsername(), ex.GetLockerEntityID());
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
        }
    }

    /// <summary>Deletes the currently selected supplier profile (should not be primary supplier)</summary>
    private void DeleteSupplier()
    {
        // Check that it is not the primary supplier
        ProductStock productStock = new ProductStock();
        productStock.LoadBySiteIDAndNSVCode(this.NSVCode, SessionInfo.SiteID);
        if (productStock.First().PrimarySupplierCode == this.SupCode)
        {
            string script = string.Format("alertEnh('Cannot delete primary supplier')", this.SupCode);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ErrorInfo", script, true);
        }

        // Load supplier profile and delete
        WSupplierProfile profile = new WSupplierProfile();
        profile.LoadBySiteIDSupplierAndNSVCode(SessionInfo.SiteID, this.SupCode, this.NSVCode);
        if (profile.Any())
            profile.RemoveAt(0);
        profile.Save(saveToPharmacyLog: true, updateModifiedDate:false);
        this.SupCode = string.Empty;
    }

    /// <summary>Builds up the list of views</summary>
    private void PopulateViewList()
    {
        WConfiguration config = new WConfiguration();
        config.LoadBySiteCategoryAndSection(SessionInfo.SiteID, "D|STKMAINT", "Views");

        int total = 0;
        var totalRow = config.FindByKey("Total");
        if (totalRow != null)
            int.TryParse(totalRow.Value, out total);

        IDictionary<int, string> viewIndexesToDisplay;
        if (viewIndexesToDisplayStr.EqualsNoCase("All"))
            viewIndexesToDisplay = WProductQSProcessor.GetProductEditorViews(true);
        else
            viewIndexesToDisplay = WProductQSProcessor.GetProductEditorViews(viewIndexesToDisplayStr.ParseCSV<int>(",", true));

        foreach (var viewIndex in viewIndexesToDisplay)
            AddViewItem(viewIndex.Value, viewIndex.Key);

        if (trViews.Controls.OfType<HtmlButton>().Any())
            trViews.Controls.OfType<HtmlButton>().First().Attributes["class"] = "ViewListSelected";
    }

    private void AddViewItem(string text, int key)
    {
        HtmlButton button = new HtmlButton();
        button.InnerText            = text;
        button.Attributes["key"]    = key.ToString();
        button.Attributes["onclick"]= "viewlist_onclick(this); return false;";
        trViews.Controls.Add(button);
    }

    /// <summary>Soft locks all items in products</summary>
    private void SoftLockRows(WProduct products)
    {
        UnSoftLockRows(hfProductStockLocker.Value);

        SoftLockResults productStockLocker = new SoftLockResults("ProductStock");
        try
        {
            productStockLocker.LockRows(products.Table);
        }
        catch (LockException ex)
        {
            string message = string.Format("Record is currently being edited by user \"{0}\" (EntityID: {1}).", ex.GetLockerUsername(), ex.GetLockerEntityID());
            ScriptManager.RegisterStartupScript(this, this.GetType(), "locked", "alertEnh('" + message + "');", true);
        }

        // Setup to write xml fragment
        this.ProductStockLocker = productStockLocker;
    }

    /// <summary>Unlocks all items in in the xml</summary>
    /// <param name="productStockLocker">XML data for SoftLocker</param>
    private static void UnSoftLockRows(string productStockLocker)
    {
        if (string.IsNullOrEmpty(productStockLocker))
            return;

        SoftLockResults stockLock = new SoftLockResults("ProductStock");

        // Setup string as XML fragment
        XmlReaderSettings settings = new XmlReaderSettings();
        settings.ConformanceLevel = ConformanceLevel.Fragment;

        // Read xml string
        using (XmlReader reader = XmlReader.Create(new StringReader(productStockLocker), settings))
            stockLock.ReadXml(reader);

        stockLock.UnlockRows();
    }
    #endregion
}
