//===========================================================================
//
//						     FMStockAccountDrillDown.aspx
//
//  When user clicks on a line in the stock balance sheet provides an expanded 
//  view of the WFMLogCache rows that make up that line.
//
//  There are 3 different modes that the form will be displayed in depending 
//  on the line clicked in the stock balance sheet.
//  
//  Summary Mode - when account or main section line is clicked in stock account
//                 sheet in summary view. This will display all WFMLogCache rows
//                 Read by stock sheet rule code for section, all child sections for main section. 
//                 Rows are grouped by site and supplier\ward then by drug, and
//                 show summed quantity, and cost of all transactions.
//
//  Drug specific mode - Same as summary mode except when stock balance sheet is
//                 displaying data for a specific drug 
//                 Rows are grouped by site and supplier, and show summed quantity, 
//                 and cost of all transactions.
//
//  Discrepancy mode - when discrepancy line is clicked on stock balance sheet
//                 Shows all drugs that have discrepancies, showing drug name
//                 and quantity or value discrepancy.
//                 Does not include cost inc vat as if the site has vat account code 
//                 the total down and across the table (for discrepancy) does not add up 
//
//  Before calling this form need to call web method FMStockAccountDrillDown.aspx/SaveFMSettings
//  to pass in the from parameters
//
//  Double clicking on a line in page table will display a pharmacy log view for the drug
//      row_OnDblClick                      - Javascript method that handle the double click
//          SaveDisplayLogSessionAttributes - Web method to save DisplayLogRows setting to db session 
//          DisplayLogRows.aspx             - Display log rows
//          
//
//  Call the page with the follow parameters
//  SessionID                    - ICW session ID
//  WFMStockAccountSheetLayoutID - account sheet layout id of line clicked in account  sheet
//  
//	Modification History:
//	15May13 XN  Written (27038) 
//  02Dec13 XN  Added VAT account codes 79631
//  07Jan14 XN  Rename to stock balance sheet 8136
//              Added Print button 81146
//              Right justified value column headers 81139
//              Summary view grouped by NSV code, not site and ward 81145
//              Summary view double click displays Stock Balance Sheet 81145
//  17Feb14 XN  If rule has vat account code then zero the tax (84852)
//              Swapped order of Ex Vat and Inc Vat columns
//  27Oct14 XN  Now save settings to context via SaveFMSettings web method to 
//              fix issue if settings struct is very big then can't pass in on query
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.Services;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.financemanagerlayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;

public partial class application_FinanceManager_FMStockAccountDrillDown : System.Web.UI.Page
{
    #region Constants
    // Width used for table columns
    private const int ColumnWidth_Site        = 50;
    private const int ColumnWidth_Description = 335;
    private const int ColumnWidth_WardSupplier= 50;
    private const int ColumnWidth_Quantity    = 125;
    private const int ColumnWidth_Cost        = 125;
    #endregion

    #region Member variables
    /// <summary>Stock balance sheet settings passed in on URL</summary>
    protected WFMStockAccountSheetSettings settings;

    /// <summary>If stock balance sheet is in summary view</summary>
    protected bool summaryPage;

    /// <summary>If displaying stock account discrepancies</summary>
    protected bool discrepancies;

    ///// <summary>session ID</summary>
    //protected int  sessionID; XN 27Oct14

    /// <summary>account sheet layout id of line clicked in account  sheet</summary>
    protected int  wfmStockAccountSheetLayoutID;
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        // XN 27Oct14 Now save settings to context via SaveFMSettings web method to fix issue if settings struct is very big then can't pass in on query
        //sessionID                   = int.Parse(Request["SessionID"]);
        //wfmStockAccountSheetLayoutID= int.Parse(Request["WFMStockAccountSheetLayoutID"]);        
        //settings                    = JsonConvert.DeserializeObject<WFMStockAccountSheetSettings>(Request["Settings"]);
        //SessionInfo.InitialiseSessionAndSiteNumber(sessionID, settings.siteNumbers.First());
                
        SessionInfo.InitialiseSession(Request);

        wfmStockAccountSheetLayoutID= int.Parse(Request["WFMStockAccountSheetLayoutID"]);        

        // Get the settings from the cache
        object obj = PharmacyDataCache.GetFromSession("WFMStockAccountSheetSettings");
        if (obj == null || !(obj is WFMStockAccountSheetSettings))
        {
            Response.Redirect("~\\application\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=Need to call FMStockAccountDrillDown.aspx/SaveFMSettings before calling the from.");
            return;
        }
        PharmacyDataCache.RemoveFromSession("WFMStockAccountSheetSettings");
        settings = (WFMStockAccountSheetSettings)obj;

        // reset the session info (so has site number)
        SessionInfo.InitialiseSessionAndSiteNumber(SessionInfo.SessionID, settings.siteNumbers.First());

        WFMStockAccountSheetLayout layout = new WFMStockAccountSheetLayout();
        layout.LoadAll();

        summaryPage     = string.IsNullOrEmpty(settings.NSVCode);
        discrepancies   = layout.FindByID(wfmStockAccountSheetLayoutID).SectionType == WFMStockAccountSheetSectionType.ClosingBalanceDiscrepancies;

        // Set form heading info
        lbHeading.InnerText     = layout.FindByID(wfmStockAccountSheetLayoutID).Description;
        lbSites.InnerText       = "Site Nos: " + settings.siteNumbers.Select(s => s.ToString("000")).ToCSVString(" ");
        lbDatePeriod.InnerText  = "Period " + settings.startDate.ToPharmacyDateTimeString() + " - " + settings.endDate.ToPharmacyDateTimeString();
        if (!summaryPage)
            lbDrug.InnerText = settings.NSVCode + " - " + WProduct.ProductDetails(settings.NSVCode);

        // Create page by type
        if (discrepancies)
        {
            // Setup page in Discrepancy mode
            CreateHeaderForDiscrepancies();
            CreateTableForDiscrepancies(layout.SelectMany(s => s.RuleCodes).ToList());
        }
        else if (summaryPage)
        {
            // Setup page in Summary mode
            var             ruleCodeToDisplay = layout.FindRuleCodeByIDAndChildren(wfmStockAccountSheetLayoutID).ToList();
            PharmacyLogType pharmacyLog       = layout.FindPharmacyLogTypeByIDAndChildren(wfmStockAccountSheetLayoutID);

            CreateHeaderForSummary(pharmacyLog);
            CreateTableForSummary(pharmacyLog, ruleCodeToDisplay);
        }
        else
        {
            // Setup page in Drug Specific mode
            var             ruleCodeToDisplay = layout.FindRuleCodeByIDAndChildren(wfmStockAccountSheetLayoutID).ToList();
            PharmacyLogType pharmacyLog       = layout.FindPharmacyLogTypeByIDAndChildren(wfmStockAccountSheetLayoutID);

            CreateHeaderForDrugSpecificSheet(pharmacyLog);
            CreateTableForDrugSpecificSheet(pharmacyLog, ruleCodeToDisplay.ToList());
        }
    }
    #endregion

    #region Web Methods
    /// <summary>Saves search criteria for pharmacy log viewer to db session</summary>
    /// <param name="sessionID">Session ID</param>
    /// <param name="settings">Stock balance sheet settings</param>
    /// <param name="wfmStockAccountSheetLayoutID">Stock balance sheet section drill down is for</param>
    /// <param name="siteNumbers">CSV list of sites drill down is for</param>
    /// <param name="WardSupCode">Ward or sup code log view is fo</param>
    /// <param name="NSVCode">Drug drill down is for</param>
    [WebMethod]
    public static void SaveLogViewerSearchCriteria(int sessionID, WFMStockAccountSheetSettings settings, int wfmStockAccountSheetLayoutID, string siteNumbers, string wardSupCode, string NSVCode)
    {
        SessionInfo.InitialiseSession(sessionID);

        // Get all sections (so can get pharmacy log type to display)
        WFMStockAccountSheetLayout layout = new WFMStockAccountSheetLayout();
        layout.LoadAll();

        PharmacyLogType pharmacyLog = layout.FindPharmacyLogTypeByIDAndChildren(wfmStockAccountSheetLayoutID);

        // Set log viewer search criteria
        PharmacyDisplayLogRows.GeneralSearchCriteria generalSettings = new PharmacyDisplayLogRows.GeneralSearchCriteria();
        generalSettings.pharmacyLog     = pharmacyLog;
        generalSettings.fromDate        = settings.startDate;
        generalSettings.toDate          = settings.endDate;
        generalSettings.useLogDateTime  = true;
        generalSettings.siteNumbers     = siteNumbers.Split(new char[] { ',' }).Select(s => int.Parse(s)).ToList();
        generalSettings.NSVCode         = NSVCode;
        generalSettings.moneyDisplayType= MoneyDisplayType.Show;

        // Save search criteria 
        PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.GeneralSearchCriteria",  JsonConvert.SerializeObject(generalSettings) );
        switch (pharmacyLog)
        {
        case PharmacyLogType.Orderlog: 
            PharmacyDisplayLogRows.OrderlogSearchCriteria orderlogSearchCriteria = new PharmacyDisplayLogRows.OrderlogSearchCriteria();
            orderlogSearchCriteria.supCode = wardSupCode;
            PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.LogSearchCriteria", JsonConvert.SerializeObject(orderlogSearchCriteria) ); 

            PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.Columns", WFMSettings.StockAccountSheet.OrderlogViewerColumns ); 
            break;
        case PharmacyLogType.Translog: 
            PharmacyDisplayLogRows.TranslogSearchCriteria translogSearchCriteria = new PharmacyDisplayLogRows.TranslogSearchCriteria();
            translogSearchCriteria.wardCode = wardSupCode;
            PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.LogSearchCriteria", JsonConvert.SerializeObject(translogSearchCriteria) ); 

            PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.Columns", WFMSettings.StockAccountSheet.TranslogViewerColumns ); 
            break;
        case PharmacyLogType.Unknown:  
            PharmacyDataCache.SaveToDBSession("Pharmacy.LogViewer.Columns", WFMSettings.StockAccountSheet.CombinedLogViewerColumns); 
            break;
        }
    }
    
    /// <summary>
    /// Saves the data need to print off report (list of displayed item) to session attribute PharmacyGeneralReportAttribute.
    /// </summary>
    [WebMethod]
    public static string SaveReportForPrinting(int sessionID, string title, string setting, string grid, string reportName)
    {
        SessionInfo.InitialiseSession(sessionID);

        List<FinanceManagerReport.ColourMapInfo> colorMap = new List<FinanceManagerReport.ColourMapInfo>();
        colorMap.Add(new FinanceManagerReport.ColourMapInfo(){ webColor=System.Drawing.Color.FromArgb(65,  127, 143), colorTableIndex=9  /*D. Grey*/,  shadingPercentage=100}); // Font colour
        colorMap.Add(new FinanceManagerReport.ColourMapInfo(){ webColor=System.Drawing.Color.FromArgb(86,   86,  82), colorTableIndex=14 /* Teal  */,  shadingPercentage=100}); // Font colour
        colorMap.Add(new FinanceManagerReport.ColourMapInfo(){ webColor=System.Drawing.Color.FromArgb(234, 234, 234), colorTableIndex=15 /* Silver*/,  shadingPercentage=35 }); // Light grey background (supplier volumns)
        colorMap.Add(new FinanceManagerReport.ColourMapInfo(){ webColor=System.Drawing.Color.FromArgb(220, 230, 251), colorTableIndex=9  /* Teal  */,  shadingPercentage=20 }); // header background

        FinanceManagerReport report = new FinanceManagerReport(title, string.Empty, setting, string.Empty, grid, string.Empty);
        report.AddColourMaps(colorMap);
        report.Save();

        if (!OrderReport.IfReportExists(reportName))
            throw new ApplicationException(string.Format("Report not found '{0}'", reportName));

        return reportName;
    }

    /// <summary>Used to save settings before lauching the form XN 27Oct14</summary>
    [WebMethod]
    public static void SaveFMSettings(int sessionID, WFMStockAccountSheetSettings settings)
    {
        SessionInfo.InitialiseSession(sessionID);
        PharmacyDataCache.SaveToSession("WFMStockAccountSheetSettings", settings);
    }
    #endregion

    #region Methods for Discrepancy mode
    /// <summary>Setup table headers for discrepancy mode</summary>
    private void CreateHeaderForDiscrepancies()
    {
        // Get columns to display
        var displayColumns = WFMSettings.StockAccountSheet.DisplayColumns;

        TableRow headerRow = new TableRow();
        headerRow.CssClass = "fm-drilldown-table-header0";
        headerRow.Attributes.Add("headerRow", "1");
        table.Rows.Add(headerRow);
        AddCell(headerRow, ColumnWidth_Description, 1, "Drug Description",      null, null);
        AddCell(headerRow, ColumnWidth_Quantity,    1, "Quantity Discrepancy",  null, "right");
        if (displayColumns.Contains(FMStockAccountSheetColumnType.IncVat))
            AddCell(headerRow, ColumnWidth_Cost,    1, "Value Discrepancy",     null, "right");
        if (displayColumns.Contains(FMStockAccountSheetColumnType.ExVat))
            AddCell(headerRow, ColumnWidth_Cost,    1, "Value Discrepancy",     null, "right");
        if (displayColumns.Contains(FMStockAccountSheetColumnType.Vat))
            AddCell(headerRow, ColumnWidth_Cost,    1, "Value Discrepancy",     null, "right");

        string VAT = PharmacyCultureInfo.SalesTaxName + "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;";
        headerRow = new TableRow();
        headerRow.CssClass = "fm-drilldown-table-header0";
        headerRow.Attributes.Add("headerRow", "1");
        table.Rows.Add(headerRow);
        AddCell(headerRow, ColumnWidth_Description, 1, "&nbsp;",                                    null, null);
        AddCell(headerRow, ColumnWidth_Quantity,    1, "(in issue units)&nbsp;&nbsp;&nbsp;&nbsp;",  null, "right");
        if (displayColumns.Contains(FMStockAccountSheetColumnType.IncVat))
            AddCell(headerRow, ColumnWidth_Cost,    1, "Inc. " + VAT,                               null, "right");
        if (displayColumns.Contains(FMStockAccountSheetColumnType.ExVat))
            AddCell(headerRow, ColumnWidth_Cost,    1, "Ex. "  + VAT,                               null, "right");
        if (displayColumns.Contains(FMStockAccountSheetColumnType.Vat))
            AddCell(headerRow, ColumnWidth_Cost,    1, VAT,                                         null, "right");
    }

    /// <summary>
    /// Populate table with list of drugs with discrepancies from stock balance sheet
    /// Shows drug name, stock quantity, and cost of discrepancy
    /// </summary>
    private void CreateTableForDiscrepancies(List<short> ruleCodes)
    {
        TableRow row;
        TableCell cell;
        double? value;
        string temp;

        // Initialise session with site number for get what '£' to display (first in list will do)
        SessionInfo.InitialiseSessionAndSiteNumber(SessionInfo.SessionID, settings.siteNumbers.First());

        short stockAccountCode = WFMSettings.StockAccountSheet.AccountCode;

        // Get list of all siteIDs that make up the stock balance sheet
        Sites sites = new Sites();
        sites.LoadAll(true);
        var siteIDs = settings.siteNumbers.Select(s => sites.FindBySiteNumber(s).SiteID).ToList();

        // Get columns to display
        var displayColumns = WFMSettings.StockAccountSheet.DisplayColumns;

        WFMRule rules = new WFMRule();
        rules.LoadAll();

        // Calculate discrepancies (varies a bit on loading)
        WFMLogCache logCache = new WFMLogCache();
        WFMDailyStockLevel openingBalance = new WFMDailyStockLevel();
        WFMDailyStockLevel closingBalance = new WFMDailyStockLevel();
        List<WFMDiscrepancy> discrepancies;
        if (summaryPage)
        {
            var sitesIDs = settings.siteNumbers.Select(s => sites.FindSiteIDBySiteNumber(s) ?? 0);
            logCache.LoadByDatesSitesRulesAccountNSVCodes(settings.startDate, settings.endDate, sitesIDs, ruleCodes, stockAccountCode, settings.discrepancesNSVCodes);
            openingBalance.LoadByDateSitesAndNSVCode(settings.startDate, siteIDs, null);
            closingBalance.LoadByDateSitesAndNSVCode(settings.endDate,   siteIDs, null);

            openingBalance.RemoveAll(b => !settings.discrepancesNSVCodes.Contains(b.NSVCode));
            closingBalance.RemoveAll(b => !settings.discrepancesNSVCodes.Contains(b.NSVCode));
        }
        else
        {
            var sitesIDs = settings.siteNumbers.Select(s => sites.FindSiteIDBySiteNumber(s) ?? 0);
            logCache.LoadByDatesSitesRulesAccountNSVCodes(settings.startDate, settings.endDate,  sitesIDs, ruleCodes, stockAccountCode, settings.NSVCode);
            openingBalance.LoadByDateSitesAndNSVCode(settings.startDate, siteIDs, settings.NSVCode);
            closingBalance.LoadByDateSitesAndNSVCode(settings.endDate,   siteIDs, settings.NSVCode);
        }

        // Get list of sites that can reclaim vat (has a vat account code set) (84499)
        IEnumerable<int> siteIDsThatReclaimVat;
        var rulesWithVatAccountCodes = rules.Where(r => ruleCodes.Contains(r.Code)).Where(r => r.AccountCode_Vat_Debit == stockAccountCode || r.AccountCode_Vat_Credit == stockAccountCode);
        if (rulesWithVatAccountCodes.Any(r => r.LocationID_Site == null))
            siteIDsThatReclaimVat = siteIDs;                                               // Vat account code applies to all sites so all sites must be able to reclaim vat
        else
            siteIDsThatReclaimVat = rulesWithVatAccountCodes.Select(r => r.LocationID_Site.Value).ToArray();  // Get sites that have vat account codes

        discrepancies = logCache.CalculateDiscrepancies(stockAccountCode, openingBalance, closingBalance, siteIDsThatReclaimVat);

        divNoTransactionsMsg.Visible = !discrepancies.Any();            

        foreach (var discrepancy in discrepancies)
        {
            row = new TableRow();
            row.Attributes.Add("ondblclick",  "row_OnDblClick(this);"               );
            row.Attributes.Add("SiteNumbers", settings.siteNumbers.ToCSVString(",") );
            row.Attributes.Add("NSVCode",     discrepancy.NSVCode                   );
            row.Attributes.Add("WardSupCode", " "                                   );
            table.Rows.Add(row);

            // Drug descriptions
            temp = string.Format("{0} - {1}", discrepancy.NSVCode, WProduct.ProductDetails(discrepancy.NSVCode));
            cell = AddCell(row, ColumnWidth_Description, 1, temp, null, null);

            // Quantity
            value = discrepancy.StockLevelInIssueUnits.RoundQuantity();
            temp = (value == null) ? "&nbsp;" : value.Value.ToString("0.###");
            cell = AddCell(row, ColumnWidth_Quantity, 1, temp, null, "right");

            // Inc Value
            if (displayColumns.Contains(FMStockAccountSheetColumnType.IncVat))
            {
                value = discrepancy.StockValueIncVat.RoundCost();
                temp = value.Value.ToMoneyString(MoneyDisplayType.Show) + "&nbsp;";
                cell = AddCell(row, ColumnWidth_Cost, 1, temp, string.Empty, "right");
            }

            // Ex Value
            if (displayColumns.Contains(FMStockAccountSheetColumnType.ExVat))
            {
                value = discrepancy.StockValueExVat.RoundCost();
                temp = value.Value.ToMoneyString(MoneyDisplayType.Show) + "&nbsp;";
                cell = AddCell(row, ColumnWidth_Cost, 1, temp, string.Empty, "right");
            }

            // Vat Value
            if (displayColumns.Contains(FMStockAccountSheetColumnType.Vat))
            {
                value = discrepancy.StockValueVat.RoundCost();
                temp = value.Value.ToMoneyString(MoneyDisplayType.Show) + "&nbsp;";
                cell = AddCell(row, ColumnWidth_Cost, 1, temp, string.Empty, "right");
            }
        }
    }
    #endregion

    #region Methods for Summary mode
    /// <summary>
    /// Setup table headers for summary mode
    /// Has two headers one for site supplier\ward
    /// Second header for drug
    /// </summary>
    private void CreateHeaderForSummary(PharmacyLogType pharmacyLog)
    {
        TableRow headerRow;

        // Add header for site and supplier\ward
        headerRow = new TableRow();
        headerRow.CssClass = "fm-drilldown-table-header0";
        headerRow.Attributes.Add("headerRow", "1");
        table.Rows.Add(headerRow);
        AddCell(headerRow, ColumnWidth_Description,     1, "Drug Description",                               "fm-drilldown-table-header0", null);
        AddCell(headerRow, ColumnWidth_Quantity,        1, "Quantity&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",         null,                         "right");
        AddCell(headerRow, ColumnWidth_Quantity,        1, "Value Inc. " + PharmacyCultureInfo.SalesTaxName, null,                         "right");
        AddCell(headerRow, ColumnWidth_Quantity,        1, "Value Ex. " + PharmacyCultureInfo.SalesTaxName,  null,                         "right");
        AddCell(headerRow, ColumnWidth_Quantity,        1, PharmacyCultureInfo.SalesTaxName,                 null,                         "right");


        // Add header for something
        headerRow = new TableRow();
        headerRow.CssClass = "fm-drilldown-table-header0";
        headerRow.Attributes.Add("headerRow", "1");
        table.Rows.Add(headerRow);
        AddCell(headerRow, ColumnWidth_Description,     1, "&nbsp",             "fm-drilldown-table-header0", null);
        AddCell(headerRow, ColumnWidth_Quantity,        1, "(in issue units)",  null,                         "right");
        AddCell(headerRow, ColumnWidth_Quantity,        1, "&nbsp",             null,                         "right");
        AddCell(headerRow, ColumnWidth_Quantity,        1, "&nbsp",             null,                         "right");
        AddCell(headerRow, ColumnWidth_Quantity,        1, "&nbsp",             null,                         "right");
    }

    /// <summary>
    /// Populate table for summary mode 
    /// Groups drugs by site and supplier\ward, then by drug
    /// </summary>
    private void CreateTableForSummary(PharmacyLogType pharmacyLog, List<short> ruleCodes)
    {
        TableRow row;
        TableCell cell;
        double? value;
        string temp;

        // Initialise session with site number for get what '£' to display (first in list will do)
        SessionInfo.InitialiseSessionAndSiteNumber(SessionInfo.SessionID, settings.siteNumbers.First());

        short stockAccountCode = WFMSettings.StockAccountSheet.AccountCode;

        // Load sites
        Sites sites = new Sites();
        sites.LoadAll();

        // Load in data to display
        WFMLogCache logCache = new WFMLogCache();
        logCache.LoadByDatesSitesRulesAccountNSVCodeWithDescriptions(settings.startDate, settings.endDate, settings.siteNumbers.Select(s => sites.FindSiteIDBySiteNumber(s) ?? 0), ruleCodes, WFMSettings.StockAccountSheet.AccountCode, null);

        divNoTransactionsMsg.Visible = !logCache.Any();            

        // Group by NSVCode (depending on log type)
        var query = (from d in logCache
                     group d by d.NSVCode into g
                     orderby g.Key
                     select g).ToList();

        foreach (var drugInfo in query)
        {

            // Add space row
            row = new TableRow();
            row.CssClass = "fm-drilldown-table-row";
            row.Attributes.Add("ondblclick",  "row_OnDblClick(this);");
            row.Attributes.Add("NSVCode",     drugInfo.Key);
            table.Rows.Add(row);

            // Drug Description
            temp = drugInfo.Key + " - " + drugInfo.First().DrugDescription;
            cell = AddCell(row, ColumnWidth_Description, 1, temp, string.Empty, null);

            // Quantity
            value = drugInfo.TotalQuantityInIssueUnits(stockAccountCode).RoundQuantity();
            temp = (value == null) ? "&nbsp;" : value.Value.ToString("0.###");
            cell = AddCell(row, ColumnWidth_Quantity, 1, temp, string.Empty, "right");

            // Value Inc Vat
            value = drugInfo.TotalCostIncVat(stockAccountCode).RoundCost();
            temp = value.Value.ToMoneyString(MoneyDisplayType.Show) + "&nbsp;";
            cell = AddCell(row, ColumnWidth_Cost, 1, temp, string.Empty, "right");

            // Value Ex Vat
            value = drugInfo.TotalCostExVat(stockAccountCode).RoundCost();
            temp = value.Value.ToMoneyString(MoneyDisplayType.Show) + "&nbsp;";
            cell = AddCell(row, ColumnWidth_Cost, 1, temp, string.Empty, "right");

            // Vat
            value = drugInfo.TotalVat(stockAccountCode).RoundCost();
            temp = value.Value.ToMoneyString(MoneyDisplayType.Show) + "&nbsp;";
            cell = AddCell(row, ColumnWidth_Cost, 1, temp, string.Empty, "right");
        }
    }
    #endregion

    #region Methods for Drug Sepcific mode
    /// <summary>Setup table headers for drug specific mode</summary>
    private void CreateHeaderForDrugSpecificSheet(PharmacyLogType pharmacyLog)
    {
        TableRow headerRow = new TableRow();
        headerRow.CssClass = "fm-drilldown-table-header0";
        headerRow.Attributes.Add("headerRow", "1");
        table.Rows.Add(headerRow);
        AddCell(headerRow, ColumnWidth_Site,        1, "Site #",                                                        null, null);
        AddCell(headerRow, ColumnWidth_Description, 1, pharmacyLog == PharmacyLogType.Orderlog ? "Supplier" : "Ward",   null, null);
        AddCell(headerRow, ColumnWidth_Quantity,    1, "Quantity&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",                        null, "right");
        AddCell(headerRow, ColumnWidth_Cost,        1, "Value Inc. " + PharmacyCultureInfo.SalesTaxName,                null, "right");
        AddCell(headerRow, ColumnWidth_Cost,        1, "Value Ex. " + PharmacyCultureInfo.SalesTaxName,                 null, "right");
        AddCell(headerRow, ColumnWidth_Cost,        1, PharmacyCultureInfo.SalesTaxName,                                null, "right");

        headerRow = new TableRow();
        headerRow.CssClass = "fm-drilldown-table-header0";
        headerRow.Attributes.Add("headerRow", "1");
        table.Rows.Add(headerRow);
        AddCell(headerRow, ColumnWidth_Site,        1, "&nbsp;",            null, null);
        AddCell(headerRow, ColumnWidth_Description, 1, "&nbsp;",            null, null);
        AddCell(headerRow, ColumnWidth_Quantity,    1, "(in issue units)",  null, "right");
        AddCell(headerRow, ColumnWidth_Cost,        1, "&nbsp;",            null, "right");
        AddCell(headerRow, ColumnWidth_Cost,        1, "&nbsp;",            null, "right");
        AddCell(headerRow, ColumnWidth_Cost,        1, "&nbsp;",            null, "right");
    }

    /// <summary>Populate table for drug specific mode</summary>
    private void CreateTableForDrugSpecificSheet(PharmacyLogType pharmacyLog, List<short> ruleCodes)
    {
        TableRow row;
        TableCell cell;
        double? value;
        string temp;

        // Initialise session with site number for get what '£' to display (first in list will do)
        SessionInfo.InitialiseSessionAndSiteNumber(SessionInfo.SessionID, settings.siteNumbers.First());

        short stockAccountCode = WFMSettings.StockAccountSheet.AccountCode;

        // Load sites
        Sites sites = new Sites();
        sites.LoadAll();

        // Load data to display
        WFMLogCache logCache = new WFMLogCache();
        logCache.LoadByDatesSitesRulesAccountNSVCodeWithDescriptions(settings.startDate, settings.endDate, settings.siteNumbers.Select(s => sites.FindSiteIDBySiteNumber(s) ?? 0), ruleCodes, WFMSettings.StockAccountSheet.AccountCode, settings.NSVCode);

        divNoTransactionsMsg.Visible = !logCache.Any();     

        // Group by site and supplier\Wardcode (depending on log type)
        var query = (from d in logCache
                     let SupWardCode = pharmacyLog == PharmacyLogType.Orderlog ? d.SupCode : d.WardCode
                     group d by new { d.LocationID_Site, SupWardCode } into g
                     orderby g.Key.LocationID_Site, g.Key.SupWardCode
                     select g).ToList();

        foreach (var logItem in query)
        {
            int?   siteNumber = sites.FindSiteNumberByID(logItem.Key.LocationID_Site ?? 0);
            string supWardCode= logItem.Key.SupWardCode;

            row = new TableRow();
            row.Attributes.Add("ondblclick",  "row_OnDblClick(this);");
            row.Attributes.Add("SiteNumbers", siteNumber == null ? settings.siteNumbers.ToCSVString(",") : siteNumber.ToString());
            row.Attributes.Add("WardSupCode", logItem.Key.SupWardCode);
            row.Attributes.Add("NSVCode",     settings.NSVCode);
            table.Rows.Add(row);

            // Site number
            temp = (siteNumber == null) ? "&nbsp;" : siteNumber.ToString();
            cell = AddCell(row, ColumnWidth_Site, 1, temp, "fm-drilldown-table-row", "center");
            cell.Style.Add(HtmlTextWriterStyle.FontStyle, "bold");

            // Supplier
            if (string.IsNullOrEmpty(supWardCode))
                temp = "&nbsp;";
            else if (pharmacyLog == PharmacyLogType.Orderlog)
                temp = logItem.First().SupplierName + " - " + supWardCode;
            else 
                temp = logItem.First().WardName + " - " + supWardCode;
            temp = temp.TrimStart().TrimStart(new [] { '-' });
            cell = AddCell(row, ColumnWidth_Description, 1, temp, "fm-drilldown-table-row", null);
            cell.Style.Add(HtmlTextWriterStyle.FontStyle, "bold");

            // Quantity
            value = logItem.TotalQuantityInIssueUnits(stockAccountCode).RoundQuantity();
            temp = (value == null) ? "&nbsp;" : value.Value.ToString("0.###");
            cell = AddCell(row, ColumnWidth_Quantity, 1, temp, string.Empty, "right");

            // Value Inc Vat
            value = logItem.TotalCostIncVat(stockAccountCode).RoundCost();
            temp = value.Value.ToMoneyString(MoneyDisplayType.Show) + "&nbsp;";
            cell = AddCell(row, ColumnWidth_Cost, 1, temp, string.Empty, "right");

            // Value Ex Vat
            value = logItem.TotalCostExVat(stockAccountCode).RoundCost();
            temp = value.Value.ToMoneyString(MoneyDisplayType.Show) + "&nbsp;";
            cell = AddCell(row, ColumnWidth_Cost, 1, temp, string.Empty, "right");

            // Vat
            value = logItem.TotalVat(stockAccountCode).RoundCost();
            temp = value.Value.ToMoneyString(MoneyDisplayType.Show) + "&nbsp;";
            cell = AddCell(row, ColumnWidth_Cost, 1, temp, string.Empty, "right");
        }
    }
    #endregion

    /// <summary>Creates new cell and adds it to the table row</summary>
    /// <param name="row">row to add cell to</param>
    /// <param name="widthInPixel">Cell width in pixel (null if not to set)</param>
    /// <param name="columnSpan">Col span for cell</param>
    /// <param name="text">Text to display in cell</param>
    /// <param name="cssClass">Css class for cell (null id not to set)</param>
    /// <param name="textAlign">Text alignment format for sell (null id not to set)</param>
    /// <returns>New Cell</returns>
    private TableCell AddCell(TableRow row, int? widthInPixel, int columnSpan, string text, string cssClass, string textAlign)
    {
        TableCell cell = new TableCell();
        cell.ColumnSpan = columnSpan;
        cell.Text       = text;
        row.Cells.Add(cell);

        if (widthInPixel != null)
            cell.Width = new Unit(widthInPixel.Value);
        if (!string.IsNullOrEmpty(cssClass))
            cell.CssClass = cssClass;
        if (!string.IsNullOrEmpty(textAlign))
            cell.Style.Add(HtmlTextWriterStyle.TextAlign, textAlign);

        return cell;
    }
}
