//===========================================================================
//
//						           EditList.aspx.cs
//
//  Displays list of PN data that can be edited by double clicking on it.
//
//  Call the page with the follow parameters
//  SessionID                   - ICW session ID
//  SiteID                      - site ID
//  DataType                    - Data type to display (one of allproducts, ingredientbyproduct, regimenvalidation)
//  ReplicateToSiteNumbers      - Sites allowed to replicate to (optional)
//  SiteNumbersSelectedByDefault- Replicate to sites selected by default (optional)
//
//  When 
//  
//  Usage:
//  EditList.aspx?SessionID=123&SiteID=24&DataType=AllProducts
//
//	Modification History:
//	20Oct11 XN  Written
//  28Dec12 XN  Add Print button (51139)
//  11Mar13 XN  58517 Help testing if report does not exist
//  26Oct15 XN  106278 Updated to use standard InitialiseSessionAndSite method
//              and added multi site printing
//  25Nov15 XN  Allow adding a product from a DSS request 38321
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Services;
using System.Web.UI;
using System.Xml;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.parenteralnutritionlayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;
using Ascribe.Common;

public partial class application_PNSettings_EditList : System.Web.UI.Page
{
    protected int sessionID;
    protected int siteID;
    protected int siteNumber;
    protected string dataType;

    /// <summary>If add button is allowed</summary>
    protected bool allowAdding = false;

    /// <summary>If allowed to add from DSS request 25Nov15 XN 38321</summary>
    protected bool allowAddingFromDSSRequest = false;
    
    /// <summary>Column that contains main item description (used by filtering)</summary>
    protected int filterColumn = 0;

    /// <summary>List of sites that are allowed for replication 26Oc15 XN 106278</summary>
    private List<Site2Row> replicateToSites;

    /// <summary>If in multi site edit mode 26Oc15 XN 106278</summary>
    protected bool isMultiSiteEditMode;

    /// <summary>url to the dss on web site (used to allow users to select a drug def request 25Nov15 XN 38321)</summary>
    protected string dssOnWebSiteUrl = string.Empty;

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);
 
        this.sessionID  = SessionInfo.SessionID;
        this.siteID     = SessionInfo.SiteID;
        this.siteNumber = SessionInfo.SiteNumber;
        this.dataType   = Request["DataType"];

        this.replicateToSites    = Site2.Instance().FindBySiteNumber(this.Request["ReplicateToSiteNumbers"], true, CurrentSiteHandling.AtStart).ToList();
        this.isMultiSiteEditMode = this.replicateToSites.Count > 1;

        if (!Page.IsPostBack)
        {
            // Populate print to site 28Oct15 XN 106278
            this.PopulatePrintSiteList();

            // Write entering into this screen into audit log
            switch (dataType.ToLower())
            {
            case "allproducts":                 PNLog.WriteToLog(SessionInfo.SiteID, "User is viewing PN product list (in settings screen)");                    break;
            case "ingredientbyproduct":         PNLog.WriteToLog(SessionInfo.SiteID, "User is viewing ingredient by product list (in settings screen)");         break;
            case "regimenvalidation":           PNLog.WriteToLog(SessionInfo.SiteID, "User is viewing regimen validation rule list (in settings screen)");       break;
            case "standardpaediatricregimen":   PNLog.WriteToLog(SessionInfo.SiteID, "User is viewing standard (Paediatric) regimen list (in settings screen)"); break;
            case "standardadultregimen":        PNLog.WriteToLog(SessionInfo.SiteID, "User is viewing standard (Adult) regimen list (in settings screen)");      break;
            case "prescriptionproforma":        PNLog.WriteToLog(SessionInfo.SiteID, "User is viewing prescription proforma list (in settings screen)");         break;
            }
            
            InitGrid();
            PopulateGrid();
        }

        // Deal with __postBack events
        string target = Request["__EVENTTARGET"];
        string args   = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];
        int recordID;    

        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        switch (target)
        {
        case "upButtons" :
            // Update from buttons to refresh rows
            // args are in form Refresh|{PNProductID}
            if ((argParams.Count() > 1) && (argParams[0] == "Refresh") && int.TryParse(argParams[1], out recordID))
                RefreshRow(recordID);
            break;
        }
    }

    /// <summary>Refresh button is clicked</summary>
    protected void btnRefresh_OnClick(object sender, EventArgs e)
    {
        InitGrid();
        PopulateGrid();

        // Clear the filter box
        ScriptManager.RegisterStartupScript(this, this.GetType(), "refreshed", "$('#tbFilter').val('')", true);
    }

    /// <summary>Initialises the grid columns based on dataType</summary>
    protected void InitGrid()
    {
        switch (dataType.ToLower())
        {
        case "allproducts": 
            gridItemList.AddColumn("Description", 50);
            gridItemList.AddColumn("In Use",      10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Type",        10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("For Adult",   10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("For Paed",    10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Sort Index",  10, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right);
            gridItemList.ColumnAllowTextWrap (0, true);
            gridItemList.ColumnXMLEscaped    (0, false);
            gridItemList.EnableAlternateRowShading = true;
            gridItemList.SortableColumns           = true;
            gridItemList.EmptyGridMessage          = "No PN products have been installed for site " + siteNumber.ToString();

            allowAdding = PNSettings.PNProductEditor.AllowAdding;
            filterColumn = 0;
            
            // if running on DSS master db, then show the Add From Request button 25Nov15 XN 38321
            if (this.allowAdding && this.IsDSSMasterDB())
            {
                this.dssOnWebSiteUrl           = SettingsController.Load("DSS",	"DrugPublishing", "DSSWebSiteURL", string.Empty);
                this.allowAddingFromDSSRequest = !string.IsNullOrWhiteSpace(this.dssOnWebSiteUrl);
                if (!this.allowAddingFromDSSRequest)
                    ScriptManager.RegisterStartupScript(this, this.GetType(), "missingURL", "alertEnh('Invalid setting DSS.DrugPublishing.DSSWebSiteURL')", true);
            }
            break;

        case "ingredientbyproduct": 
            gridItemList.AddColumn("Rule Num.",   10, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right);
            gridItemList.AddColumn("Description", 60);
            gridItemList.AddColumn("In Use",      10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Per Kilo",    10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.ColumnAllowTextWrap(1, true);
            gridItemList.ColumnXMLEscaped   (1, false);
            gridItemList.EnableAlternateRowShading = true;
            gridItemList.SortableColumns           = true;
            gridItemList.EmptyGridMessage          = "No PN ingredient have been installed for site " + siteNumber.ToString();

            allowAdding = PNSettings.RuleEditor.GetAllowAdding(RuleType.IngredientByProduct);
            filterColumn = 1;
            break;

        case "standardpaediatricregimen":   
            gridItemList.AddColumn("Description", 80);
            gridItemList.AddColumn("In Use",      10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Per Kilo",    10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.ColumnAllowTextWrap (0, true);
            gridItemList.ColumnXMLEscaped    (0, false);
            gridItemList.EnableAlternateRowShading = true;
            gridItemList.SortableColumns           = true;
            gridItemList.EmptyGridMessage          = "No standard PN paediatric regimens have been installed for site " + siteNumber.ToString();

            allowAdding = PNSettings.PNStandardRegimen.AllowAdding;
            filterColumn = 0;
            break;

        case "standardadultregimen":
            gridItemList.AddColumn("Description", 80);
            gridItemList.AddColumn("In Use",      10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Per Kilo",    10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.ColumnAllowTextWrap (0, true);
            gridItemList.ColumnXMLEscaped    (0, false);
            gridItemList.EnableAlternateRowShading = true;
            gridItemList.SortableColumns           = true;
            gridItemList.EmptyGridMessage          = "No standard PN adult regimens have been installed for site " + siteNumber.ToString();

            allowAdding = PNSettings.PNStandardRegimen.AllowAdding;
            filterColumn = 0;
            break;

        case "prescriptionproforma":
            gridItemList.AddColumn("Rule Num.",   10, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right);
            gridItemList.AddColumn("Description", 70);
            gridItemList.AddColumn("In Use",      10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Per Kilo",    10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.ColumnAllowTextWrap (0, true);
            gridItemList.ColumnXMLEscaped    (0, false);
            gridItemList.EnableAlternateRowShading = true;
            gridItemList.SortableColumns           = true;
            gridItemList.EmptyGridMessage          = "No prescription proforma's have been installed for site " + siteNumber.ToString();

            allowAdding = PNSettings.PNStandardRegimen.AllowAdding;
            filterColumn = 0;
            break;

        case "regimenvalidation":
            gridItemList.AddColumn("Rule Num.",   10, PharmacyGridControl.ColumnType.Number, PharmacyGridControl.AlignmentType.Right);
            gridItemList.AddColumn("Description", 60);
            gridItemList.AddColumn("In Use",      10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.AddColumn("Per Kilo",    10, PharmacyGridControl.AlignmentType.Center);
            gridItemList.ColumnAllowTextWrap (1, true);
            gridItemList.ColumnXMLEscaped    (1, false);
            gridItemList.EnableAlternateRowShading = true;
            gridItemList.SortableColumns           = true;
            gridItemList.EmptyGridMessage          = "No PN regimen rules have been installed for site " + siteNumber.ToString();

            allowAdding = PNSettings.RuleEditor.GetAllowAdding(RuleType.RegimenValidation);
            filterColumn = 1;
            break;
        }
    }

    /// <summary>Adds all the data to the grid depending on dataType</summary>
    private void PopulateGrid()
    {
        switch (dataType.ToLower())
        {
        case "allproducts":
            {
                PNProduct products = new PNProduct();
                products.LoadBySite(SessionInfo.SiteID);
                foreach (PNProductRow p in products.OrderBy(p => p.SortIndex))
                    AddPNProduct(p);
            }
            break;

        case "ingredientbyproduct":
            {
                PNRule rules = new PNRule();
                rules.LoadBySiteIDAndRuleType(SessionInfo.SiteID, RuleType.IngredientByProduct);

                foreach (PNRuleRow r in rules.OrderBy(r => r.RuleNumber))
                    AddPNIngredientByProductRule(r);
            }
            break;

        case "standardpaediatricregimen":
            {
                PNStandardRegimen standardRegimen = new PNStandardRegimen();
                standardRegimen.LoadByPerKiloAndInUse(true, false);

                foreach (PNStandardRegimenRow r in standardRegimen.OrderBy(r => r.Description))
                    AddPNStandardRegimen(r);
            }
            break;

        case "standardadultregimen":
            {
                PNStandardRegimen standardRegimen = new PNStandardRegimen();
                standardRegimen.LoadByPerKiloAndInUse(false, false);

                foreach (PNStandardRegimenRow r in standardRegimen.OrderBy(r => r.Description))
                    AddPNStandardRegimen(r);
            }
            break;

        case "prescriptionproforma":
            {
                PNRulePrescriptionProforma proformas = new PNRulePrescriptionProforma();
                proformas.LoadBySite(SessionInfo.SiteID);

                foreach (PNRulePrescriptionProformaRow r in proformas.OrderBy(r => r.RuleNumber))
                    AddPNRulePrescriptionProformaRow(r);
            }
            break;

        case "regimenvalidation":
            {
                PNRule rules = new PNRule();
                rules.LoadBySiteIDAndRuleType(SessionInfo.SiteID, RuleType.RegimenValidation);

                foreach (PNRuleRow r in rules.OrderBy(r => r.RuleNumber))
                    AddPNRegimenValidationRule(r);
            }
            break;
        }
    }

    /// <summary>Refresh (or adds) single row in grid, by creating HTML, and sending it to client by calling javamethod UpdateGridRow</summary>
    /// <param name="recordID">Record to update</param>
    private void RefreshRow(int recordID)
    {
        PNRuleRow rule;
        PNStandardRegimenRow standardRegimen;
        PNRulePrescriptionProformaRow proforma;

        InitGrid();

        switch (dataType.ToLower())
        {
        case "allproducts":
            PNProduct products = new PNProduct();
            products.LoadByID(recordID);
            if (products.Any())
                AddPNProduct(products.First());
            break;

        case "ingredientbyproduct": 
            rule = PNRule.GetByID(recordID);
            if (rule != null)
                AddPNIngredientByProductRule(rule);
            break;

        case "standardpaediatricregimen":
            standardRegimen = PNStandardRegimen.GetByID(recordID);
            if (standardRegimen != null)
                AddPNStandardRegimen(standardRegimen);
            break;

        case "standardadultregimen":
            standardRegimen = PNStandardRegimen.GetByID(recordID);
            if (standardRegimen != null)
                AddPNStandardRegimen(standardRegimen);
            break;

        case "prescriptionproforma":
            proforma = PNRulePrescriptionProforma.GetByID(recordID);
            if (proforma != null)
                AddPNRulePrescriptionProformaRow(proforma);
            break;

        case "regimenvalidation":
            rule = PNRule.GetByID(recordID);
            if (rule != null)
                AddPNRegimenValidationRule(rule);
            break;
        }

        if (gridItemList.RowCount > 0)
        {
            string row = gridItemList.ExtractHTMLRows(0, 1)[0].Replace("\r\n", string.Empty);
            string script = string.Format("UpdateGridRow({0}, '{1}');", recordID, Generic.XMLEscape(row));
            ScriptManager.RegisterStartupScript(this, this.GetType(), "updategridrow", script, true);
        }
    }

    /// <summary>Adds a single PN product to the grid</summary>
    /// <param name="pnProduct">product to add</param>
    protected void AddPNProduct(PNProductRow pnProduct)
    {
        gridItemList.AddRow();
        gridItemList.AddRowAttribute("RecordID", pnProduct.PNProductID.ToString()); 
        gridItemList.SetCell(0, pnProduct.Description);
        gridItemList.SetCell(1, pnProduct.InUse.ToYesNoString());
        gridItemList.SetCell(2, pnProduct.AqueousOrLipid.ToString());
        gridItemList.SetCell(3, pnProduct.ForAdult.ToYesNoString());
        gridItemList.SetCell(4, pnProduct.ForPaediatric.ToYesNoString());
        gridItemList.SetCell(5, pnProduct.SortIndex.ToString());
    }

    /// <summary>Adds a PN ingredient supplied by product rule to the grid</summary>
    /// <param name="rule">rule to add</param>
    private void AddPNIngredientByProductRule(PNRuleRow rule)
    {
        gridItemList.AddRow();
        gridItemList.AddRowAttribute("RecordID", rule.PNRuleID.ToString()); 
        gridItemList.SetCell(0, rule.RuleNumber.ToString());
        gridItemList.SetCell(1, rule.Description);
        gridItemList.SetCell(2, rule.InUse.ToYesNoString());
        gridItemList.SetCell(3, rule.PerKilo.ToYesNoString());
    }

    /// <summary>Adds a PN standard regiment to the grid</summary>
    /// <param name="standardRegimen">regimen to add</param>
    private void AddPNStandardRegimen(PNStandardRegimenRow standardRegimen)
    {
        gridItemList.AddRow();
        gridItemList.AddRowAttribute("RecordID", standardRegimen.PNStandardRegimenID.ToString()); 
        gridItemList.SetCell(0, standardRegimen.ToString());
        gridItemList.SetCell(1, standardRegimen.InUse.ToYesNoString());
        gridItemList.SetCell(2, standardRegimen.PerKilo.ToYesNoString());
    }

    private void AddPNRulePrescriptionProformaRow(PNRulePrescriptionProformaRow proforma)
    {
        gridItemList.AddRow();
        gridItemList.AddRowAttribute("RecordID", proforma.PNRuleID.ToString()); 
        gridItemList.SetCell(0, proforma.RuleNumber.ToString());
        gridItemList.SetCell(1, proforma.Description);
        gridItemList.SetCell(2, proforma.InUse.ToYesNoString());
        gridItemList.SetCell(3, proforma.PerKilo.ToYesNoString());
    }

    /// <summary>Adds a PN regiment validation rule to the grid</summary>
    /// <param name="rule">rule to add</param>
    private void AddPNRegimenValidationRule(PNRuleRow rule)
    {
        gridItemList.AddRow();
        gridItemList.AddRowAttribute("RecordID", rule.PNRuleID.ToString()); 
        gridItemList.SetCell(0, rule.RuleNumber.ToString());
        gridItemList.SetCell(1, rule.Description);
        gridItemList.SetCell(2, rule.InUse.ToYesNoString());
        gridItemList.SetCell(3, rule.PerKilo.ToYesNoString());
    }

    /// <summary>
    /// Saves the data need to print off report (list of displayed item) to session attribute PharmacyGeneralReportAttribute.
    /// Returns the name of the report to print 'Pharmacy General Report {Site number}' (relates to report in RichTextDocument table.
    /// XN 29Dec12 (51139)
    /// </summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="siteNumber">Site Number</param>
    /// <param name="title">Current page title ('All Products', etc)</param>
    /// <param name="filter">Current filter applied to the data</param>
    /// <param name="grid">Current grid data returned by MarshalRows client side method</param>
    /// <returns>report to print</returns>
    [WebMethod]
    public static string SaveReportForPrinting(int sessionID, int siteNumber, string title, string filter, string grid)
    {
        SessionInfo.InitialiseSessionAndSiteNumber(sessionID, siteNumber);

        // Get site data
        SiteProcessor sites = new SiteProcessor();
        Site site = sites.LoadBySiteNumber(siteNumber);
        DateTime now = DateTime.Now;

        // Setup xml writer 
        XmlWriterSettings settings  = new XmlWriterSettings();
        settings.OmitXmlDeclaration = true;
        settings.ConformanceLevel   = ConformanceLevel.Fragment;

        // Create data
        StringBuilder xml = new StringBuilder();
        using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
        {
            xmlWriter.WriteStartElement("PNPrintData");

            // Report title
            xmlWriter.WriteStartElement("Title");
            xmlWriter.WriteAttributeString("title", title.Trim());
            xmlWriter.WriteEndElement();

            // Hospital name
            xmlWriter.WriteStartElement("Info");
            xmlWriter.WriteAttributeString("hospname1", site.FullName       );
            xmlWriter.WriteAttributeString("hospname2", site.AccountName    );
            xmlWriter.WriteAttributeString("hospname3", site.AbbreviatedName);

            // User info
            xmlWriter.WriteAttributeString("UserID",   SessionInfo.UserInitials);
            xmlWriter.WriteAttributeString("UserName", SessionInfo.Username    );
            xmlWriter.WriteAttributeString("today",    now.ToPharmacyDateString());
            xmlWriter.WriteAttributeString("TimeNow",  now.ToPharmacyTimeString());
            xmlWriter.WriteEndElement();

            // Grid data (including filter if specified)
            xmlWriter.WriteStartElement("Data");
            if (!string.IsNullOrEmpty(filter))
                xmlWriter.WriteAttributeString("InfoText", "List filtered by: " + filter);
            xmlWriter.WriteAttributeString("Table", RTFTable.ConvertPharmacyGrid(grid));
            xmlWriter.WriteEndElement();

            xmlWriter.WriteEndElement();

            xmlWriter.Close();
        }

        // Save
        GENRTL10.State state = new GENRTL10.State();
        state.SessionAttributeSet(sessionID, "PharmacyGeneralReportAttribute", xml.ToString());

        // Check report exist in db
        // XN 11Mar13 58517 Help testing if report does not exist
        string reportName = string.Format("Pharmacy General Report {0}", siteNumber);
        if (!OrderReport.IfReportExists(reportName))
            throw new ApplicationException(string.Format("Report not found '{0}'", reportName));

        // Return report name
        return reportName;
    }

    /// <summary>
    /// Populate the list of sites to print (for HK)
    /// 26Oct15 XN 106278
    /// </summary>
    private void PopulatePrintSiteList()
    {
        // Populate check list
        if (this.isMultiSiteEditMode)
        {
            gridSites.AddColumn("Site", 100);
            foreach (var site in this.replicateToSites)
            {
                gridSites.AddRow();
                gridSites.AddRowAttribute("SiteNumber", site.SiteNumber.ToString());
                gridSites.SetCell(0, site.ToString());
            }
        }
    }

    /// <summary>If this is the DSS master db 25Nov15 XN 38321</summary>
    private bool IsDSSMasterDB()
    {
        return (Site2.GetSiteNumberByID(SessionInfo.SiteID) == 0) && SettingsController.Load<bool>("Security", "Settings", "DSSMaster", false);
    }
}