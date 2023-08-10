//===========================================================================
//
//							      DisplayLogRows.ascx.cs
//
//  Provides a basic reusable pharmacy log viewer control. 
//  The control only displays rows from Worderlog, WTranslog or WPharmacyLog, but 
//  does NOT provide a UI for the user to change the search criteria.
//  (through search criteria has to be passed into the control) 
//
//  The page provides a replacement for vb6 LogView.bas (method NewUserLogViewer)
//
//  To just display a list of log rows from another page use DisplayLogRows.aspx
//
//  When defining search criteria (via structures GeneralSearchCriteria, 
//  OrderlogSearchCritera, TranslogSearchCritera, PharmacyLogSearchCriteria, and CombinedSearchCritera).
//  You don't need to provide all criteria but must provide at least
//      GeneralSearchCriteria.fromDate
//      GeneralSearchCriteria.toDate
//      GeneralSearchCriteria.moneyDisplayType
//
//  The Initialise methods allow passing in the order or trans log columns to be 
//  displayed in the grid. For details on how to define these see PharmacyGridControl
//
//  CombinedSearchCritera only searchses WTranslog, and WOrderlog but NOT WPharmcyLog
//  
//  To be able to use the control you will need to include the PharmacyLogViewer.css,  
//  PharmacyGridControl.js, and jquery-1.3.2.js, files in your html page.
//
//  To position and size the control use server side method MaxHeigh, and client side 
//  method resizeLog (see DisplayLogRows.aspx)
// 
//  Usage:
//  in your html add
//  <%@ Register src="../PharmacyLogViewer/DisplayLogRows.ascx.ascx" tagname="LogView" tagprefix="uc1" %>
//  :
//  <script type="text/javascript" src="../sharedscripts/jquery-1.3.2.js"></script>
//  <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"></script>
//  :
//  <link href="../PharmacyLogViewer/style/PharmacyLogViewer.css" rel="stylesheet" type="text/css" />
//  :
//  <uc1:LogView ID="logView" runat="server" />
//  :
//  <body onload="resizeLog();">
//
//  The in your page load code 
//  DisplayLogRows.LogViewerGeneralCritera generalCritera = new DisplayLogRows.LogViewerGeneralCritera();
//  generalCritera.pharmacyLog = PharmacyLogType.Orderlog
//  generalCritera.fromDate    = DateTime.Min;
//  generalCritera.toDate      = DateTime.Now;
//  generalCritera.siteNumbers = new [] { 503 };
//  generalCritera.NSVCode     = "DUV503K";
//  generalCritera.moneyDisplayType = MoneyDisplayType.Show;
//
//  DisplayLogRows.LogViewerOrderLogCritera orderlogCritera = new DisplayLogRows.LogViewerOrderLogCritera();
//  orderlogCritera.orderNumber = "3232";
//  
//  logView.Initalise(generalCritera, orderlogCritera, null);
//
//	Modification History:
//  05Jul13 XN  Written 27252
//  09Jun14 XN  Added display of WPharmacyLog 
//  28Aug14 XN  Converted PharmacyLogSearchCriteria to multi log types, and thread critera 88922
//  21Jan15 XN  Removed the MaxHeight  as found better way of doing it, and 
//              Added full product description 108627
//  23Feb15 XN  Updated to use new WPharmacyLogType
//  08May15 XN  Update for changes in BaseRow (change field from static to instance for error handling improvements)
//  24Aug16 XN  added TranslogSearchCriteria.prescritionNumber 161234 
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using System.Collections;

public partial class PharmacyDisplayLogRows : System.Web.UI.UserControl
{
    #region Constants
    //                                                   Display Name      Width       Field to display         Format String     Column    Column
    //                                                                       %                                                     Type     Aligment
    /// <summary>Columns to display when reading from translog (as defined in vb6 method NewUserLogViewer)</summary>
    private static readonly string NewTranslogColumns = "{CaseNumber}       |7|{CaseNumber}                    |                  |Text     |Right  ," +
                                                        "{NHNumber}         |8|{NHNumber}                      |                  |Text     |Right  ," +
                                                        "NSV code           |4|NSVCode                         |                  |Text     |Left   ," +
                                                        "Quantity           |6|{Qty}                           |{0:0.###} {1}     |Number   |Right  ," +
                                                        "Pack               |3|ConversionFactorPackToIssueUnits|({0})             |Number   |Right  ," +
                                                        "User               |3|UserInitials                    |                  |Text     |Left   ," +
                                                        "Date and Time      |8|DateTime                        |PharmacyDateTime  |DateTime |Right  ," +
                                                        "{Cost}             |6|{Cost}                          |                  |Number   |Right  ," +
                                                        "Ward               |4|WardCode                        |                  |Text     |Left   ," +
                                                        "Cons               |4|ConsultantCode                  |                  |Text     |Left   ," +
                                                        "Pat                |2|KindRaw                         |                  |Text     |Center ," +
                                                        "Lbl                |2|LabelType                       |                  |Text     |Center ," +
                                                        "Site               |2|SiteNumber                      |{0:000}           |Number   |Center ," +
                                                        "Terminal           |7|Terminal                        |                  |Text     |Left   ," +
                                                        "Stock Lvl          |6|StockLevel                      |{0:0.##}          |Number   |Right  ," +
                                                        "{BatchNumber}      |6|BatchNumber                     |                  |Text     |Left   ," +
                                                        "{CustomerOrderNo}  |6|CustomerOrderNumber             |                  |Text     |Left   ," +
                                                        "Description        | |ProductDescription              |                  |Text     |Left   ";

    /// <summary>Columns to display when reading from orderlog (as defined in vb6 method NewUserLogViewer)</summary>
    private static readonly string NewOrderlogColumns = "OrdNum             | 6|OrderNumber                    |                  |Text     |Left   ," +
                                                        "NSV code           | 5|NSVCode                        |                  |Text     |Left   ," +
                                                        "Date and Time Ord  |10|DateTimeOrd                    |PharmacyDateTime  |DateTime |Right  ," +
                                                        "Quantity Ord       | 7|QuantityOrdered                |                  |Number   |Right  ," +
                                                        "Date and Time Rec  |10|DateTimeRec                    |PharmacyDateTime  |DateTime |Right  ," +
                                                        "Quantity Rec       | 7|QuantityReceived               |                  |Number   |Right  ," +
                                                        "User               | 4|UserInitials                   |                  |Text     |Right  ," +
                                                        "{Cost}             | 7|{cost}                         |                  |Number   |Right  ," +
                                                        "Type               | 3|KindRaw                        |                  |Text     |Center ," +
                                                        "Supplier           | 5|SupplierCode                   |                  |Text     |Center ," +
                                                        "Site               | 2|SiteNumber                     |{0:000}           |Number   |Center ," +
                                                        "Other              |10|InvoiceNumber                  |                  |Text     |Left   ," +
                                                        "Stock Lvl          | 6|{stocklvl}                     |{0:0.##}          |Number   |Right  ," +
                                                        "Description        |  |ProductDescription             |                  |Text     |Left";

    /// <summary>Columns to display when reading from order and trans log (as defined in vb6 method NewUserLogViewer)</summary>
    private static readonly string NewCombinedlogColumns = 
                                                        "Log                | 4|logtype                        |                  |Text     |Left   ," +
                                                        "NSV code           | 5|siscode                        |                  |Text     |Left   ," +
                                                        "Description        |  |{ProductDescription_Combined}  |                  |Text     |Left   ," +
                                                        "Date and Time      | 8|{DateTime_Combined}            |                  |DateTime |Right  ," +
                                                        "Quantity           | 8|{Qty}                          |                  |Number   |Right  ," +
                                                        "User               | 4|dispid                         |                  |Text     |Right  ," +
                                                        "{Cost}             | 7|{cost}                         |                  |Number   |Right  ," +
                                                        "Type               | 3|Kind                           |                  |Text     |Center ," +
                                                        "Site               | 3|Site                           |                  |Number   |Center ," +
                                                        "Stock Lvl          | 6|{stocklvl}                     |{0:0.##}          |Number   |Right  ," +
                                                        "Terminal           | 9|Terminal                       |                  |Text     |Left";

    /// <summary>Columns to display when reading from pharmacylog</summary>
    private static readonly string NewPharmacylogColumns =
                                                        "Date               |10|DateTime                       |                  |DateTime |Right,"+
                                                        "Site               | 6|SiteNumber                     |                  |Number   |Center,"+
                                                        "Initials           | 8|Initials                       |                  |Text     |Left,"+
                                                        "NSV Code           |12|NSVCode                        |                  |Text     |Center,"+
                                                        "Description        |  |Detail                         |                  |Text     |Left";


    /// <summary>Columns to display when displaying a grouped log (as defined in vb6 method NewUserLogViewer)</summary>
    private static readonly string GroupedlogColumns =  "NSV code           |10|NSVCode                        |                  |Text     |Left   ," +  
                                                        "Quantity           |10|{Qty}                          |                  |Number   |Right  ," +
                                                        "Product Description|  |ProductDescription             |                  |Text     |Left";                                                        
    #endregion

    #region Public Data Types
    /// <summary>General search criteria</summary>
    public struct GeneralSearchCriteria
    {
        /// <summary>Pharmacy log the search is to be done in (PharmacyLogType.Unkown for combined)</summary>
        public PharmacyLogType   pharmacyLog;
        
        /// <summary>
        /// Search from date (inclusive)
        /// In WOrderlog searches [DateOrd] for kind Q otherwise [DateRec]
        /// In WTranslog searches [Date] db field
        /// </summary>
        public DateTime fromDate;
        
        /// <summary>
        /// Search to date (inclusive)
        /// In WOrderlog searches [DateOrd] for kind Q otherwise [DateRec]
        /// In WTranslog searches [Date] db field
        /// </summary>
        public DateTime toDate;

        /// <summary>
        /// if date range should be use logdatetime, and not standard datetime (default is false) 
        /// When using LogDateTime, the time parts of fromDate, and toDate will be active
        /// Not supported by PharmacyLog
        /// </summary>
        public bool useLogDateTime;

        /// <summary>
        /// List of site numbers to search for
        /// Searches DB field [SiteID] (class converts them from site number to siteID)
        /// </summary>
        public IEnumerable<int>  siteNumbers;

        /// <summary>Searches DB field [siscode]</summary>
        public string NSVCode;

        /// <summary>If too group the results by drug</summary>
        public bool groupBy;

        /// <summary>Searches DB field [Terminal]</summary>
        public string terminal;

        /// <summary>Searches for user initials in DB field [DispID]</summary>
        public string userInitials;

        /// <summary>If to display monetary value from the log</summary>
        public MoneyDisplayType  moneyDisplayType;
    }

    /// <summary>Translog specific search criteria</summary>
    public struct TranslogSearchCriteria
    {
        /// <summary>Searches db field [caseno]</summary>
        public string caseNumber;

        /// <summary>Searches db field [Ward]</summary>
        public string wardCode;

        /// <summary>Searches db field [LabelType]</summary>
        public char labelType;

        /// <summary>Searches db field [Kind]</summary>
        public string[] kinds;

        /// <summary>Searches db field [NHNumber]</summary>
        public string NHSNumber;

        /// <summary>Searches db field [Specialty]</summary>
        public string speciality;

        /// <summary>Searches db field [Batchnum]</summary>
        public string batchNumber;

        /// <summary>Searches for consultant initials in db field [Consultant]</summary>
        public string consultantInitials;

        /// <summary>Searches db field [PrescriptionNum] 24Aug16 XN 161234 added</summary>
        public string[] prescritionNumber;
    }

    /// <summary>Orderlog specific search criteria</summary>
    public struct OrderlogSearchCriteria
    {
        /// <summary>Search supplier code db field [supcode]</summary>
        public string supCode;

        /// <summary>Searches db field [Kind]</summary>
        public char kind;

        /// <summary>Searches db field [reasonCode]</summary>
        public string reasonCode;

        /// <summary>Searches db field [OrderNum]</summary>
        public string orderNumber;

        /// <summary>Searches db field [InvNum]</summary>
        public string invoiceNumber;

        /// <summary>Searches db field [Batchnum]</summary>
        public string batchNumber;
    }

    /// <summary>Search criteria when searching both orderlog and translog</summary>
    public struct CombinedLogSearchCriteria
    {
        /// <summary>Searches db field [Batchnum]</summary>
        public string batchNumber;
    }
    
    /// <summary>Search criteria when searching WPharmacyLog</summary>
    public struct PharmacyLogSearchCriteria
    {
        /// <summary>Log file types (e.g. labutils)</summary>
        public WPharmacyLogType logType;
        // public string[] logType; 23Feb15 XN use new WPharmacyLogType
        // public string logType XN 28Aug14 88922 allowed mulit log type

        /// <summary>Thread to be loaded XN 28Aug14 88922</summary>
        public int? thread;
    }
    #endregion

    #region Private Data Types
    /// <summary>WConfiguration settings for the LogViewer</summary>
    private static class LogViewSettings
    {
        public static int  MaxRows              { get { return WConfiguration.Load<int> (SessionInfo.SiteID, "D|Siteinfo", "LogViewer", "Maxrows",            2000, false); } }
        public static bool DisplayBatchNumber   { get { return WConfiguration.Load<bool>(SessionInfo.SiteID, "D|Winord",   "LogViewer", "Displaybatchnumber", true, false); } }
    }

    /// <summary>Class used to hold grouped drug row data</summary>
    private class GroupedDrugRow
    {
        public PharmacyLogType PharmacyLog          { get; set; }
        public string          NSVCode              { get; set; }
        public int             ConversionFactor     { get; set; }
        public string          ProductDescription   { get; set; }
        public decimal         Quantity             { get; set; }
        public string          IssueUnits           { get; set; }
    }
    #endregion

    #region Member Variables
    private PharmacyLogType pharmacyLog;
    private List<PharmacyGridControl.ColumnLayoutHelper> columnLayouts = new List<PharmacyGridControl.ColumnLayoutHelper>();
    private StringBuilder criteria        = new StringBuilder();
    private StringBuilder productCriteria = new StringBuilder();    // 21Jan15 XN 108627
    private StringBuilder displayCriteria = new StringBuilder();
    private MoneyDisplayType moneyDisplayType;
    #endregion

    #region Public Properties
    /// <summary>Number of rows returned by the search (must call initialise first)</summary>
    public int RowCount
    {
        get { return logGrid.RowCount; }
    }
    #endregion

    #region Public Methods
    /// <summary>Search's for and displays rows from WOrderlog</summary>
    /// <param name="generalCriteria">General search criteria</param>
    /// <param name="orderlogCriteria">Orderlog specific search criteria</param>
    /// <param name="columnFormat">Orderlog columns to display (see pharmacy grid control), or null for default columns</param>
    public void Initalise(GeneralSearchCriteria generalCriteria, OrderlogSearchCriteria orderlogCriteria, string columnFormat)
    {
        // In v9 version group by only worked on (R type) so should check this
        if (generalCriteria.groupBy && (orderlogCriteria.kind != 'R' && orderlogCriteria.kind != '\0'))
            throw new ApplicationException("Orderlog group by option only works with kind R (or if no kind specified)");

        this.moneyDisplayType = generalCriteria.moneyDisplayType;
        this.pharmacyLog      = generalCriteria.pharmacyLog;

        // Create search criteria
        criteria.Append(" WHERE ");
        AddDateCriteria(PharmacyLogType.Orderlog, generalCriteria);
        AddSiteCriteria("WOrderlog", "SiteID", generalCriteria.siteNumbers);
        AddCriteria("WOrderlog", "siscode",     "NSVCode",      generalCriteria.NSVCode         );
        AddCriteria("WOrderlog", "Reasoncode",  "Reason",       orderlogCriteria.reasonCode     );
        AddCriteria("WOrderlog", "DispID",      "UserID",       generalCriteria.userInitials    );
        AddCriteria("WOrderlog", "supcode",     "Supplier",     orderlogCriteria.supCode        );
        AddCriteria("WOrderlog", "InvNum",      "InvoiceNum",   orderlogCriteria.invoiceNumber  );
        AddCriteria("WOrderlog", "Batchnum",    "BatchNumber",  orderlogCriteria.batchNumber    );
        AddCriteria("WOrderlog", "Kind",        "Kind",         orderlogCriteria.kind           );
        AddCriteria("WOrderlog", "OrderNum",    "OrderNum",     orderlogCriteria.orderNumber    );
        AddCriteria("WOrderlog", "Terminal",    "Terminal",     generalCriteria.terminal        );

        // Load rows from db
        WOrderlog orderlog = new WOrderlog();
        orderlog.LoadByCriteria(this.criteria.ToString(), LogViewSettings.MaxRows);

        // Setup search display criteria text 
        SetDisplaySearchCriteria(generalCriteria, this.displayCriteria.ToString(), this.productCriteria.ToString(), orderlog.Count);    // 21Jan15 XN 108627 added productCriteria

        // If required group data
        // both grouped or ungroubed are assigned to rows which is then passed to the grid
        IEnumerable rows;
        if (generalCriteria.groupBy)
        {
            Dictionary<string,GroupedDrugRow> groupedRows = new Dictionary<string,GroupedDrugRow>();
            foreach (WOrderlogRow row in orderlog.Where(r => r.Kind == WOrderLogType.Receipt))
                AddRowToGroup(groupedRows, PharmacyLogType.Orderlog, row.NSVCode, (int)(row.ConversionFactor ?? 0m), row.IssueUnits, row.ProductDescription, row.QuantityReceived ?? 0m);
            rows = groupedRows.Values.OrderBy(r => r.NSVCode);
        }
        else
            rows = orderlog;

        // Populate table
        SetupColumns(columnFormat, generalCriteria.groupBy ? GroupedlogColumns : NewOrderlogColumns);
        foreach (object row in rows)
        {
            try
            {
                logGrid.AddRow(row, columnLayouts, FieldConvterFunction);
            }
            catch (Exception ex)
            {
                logGrid.SetCell(logGrid.ColumnCount - 1, ex.Message);
            }
        }
    }

    /// <summary>Searches for and displays rows from WTranslog</summary>
    /// <param name="generalCriteria">General search criteria</param>
    /// <param name="translogCriteria">Translog specific search criteria</param>
    /// <param name="columnFormat">Translog columns to display (see pharmacy grid control), or null for default columns</param>
    public void Initalise(GeneralSearchCriteria generalCriteria, TranslogSearchCriteria translogCriteria, string columnFormat)
    {
        this.moneyDisplayType = generalCriteria.moneyDisplayType;
        this.pharmacyLog      = generalCriteria.pharmacyLog;

        // Create search criteria
        criteria.Append(" WHERE ");
        AddDateCriteria(PharmacyLogType.Translog, generalCriteria);
        AddSiteCriteria("WTranslog", "SiteID", generalCriteria.siteNumbers);
        AddCriteria("WTranslog", "siscode",         "NSVCode",                                  generalCriteria.NSVCode             );
        AddCriteria("WTranslog", "caseno",          "Caseno",                                   translogCriteria.caseNumber         );
        AddCriteria("WTranslog", "DispID",          "UserID",                                   generalCriteria.userInitials        );
        AddCriteria("WTranslog", "Ward",            "Ward",                                     translogCriteria.wardCode           );
        AddCriteria("WTranslog", "Consultant",      "Consultant",                               translogCriteria.consultantInitials );
        AddCriteria("WTranslog", "Specialty",       "Specialty",                                translogCriteria.speciality         );
        AddCriteria("WTranslog", "Batchnum",        "BatchNumber",                              translogCriteria.batchNumber        );
        AddCriteria("WTranslog", "PrescriptionNum", "PrescriptionNum",                          translogCriteria.prescritionNumber  );  // 24Aug16 XN 161234  added
        AddCriteria("WTranslog", "Kind",            "Kind",                                     translogCriteria.kinds              );
        AddCriteria("WTranslog", "LabelType",       "Labeltype",                                translogCriteria.labelType          );
        AddCriteria("WTranslog", "Terminal",        "Terminal",                                 generalCriteria.terminal            );
        AddCriteria("WTranslog", "NHNumber",        PharmacyCultureInfo.NHSNumberDisplayName,   translogCriteria.NHSNumber          );

        // Load rows from db
        WTranslog translog = new WTranslog();
        translog.LoadByCriteria(criteria.ToString(), LogViewSettings.MaxRows);

        // Setup search display criteria text  
        SetDisplaySearchCriteria(generalCriteria, this.displayCriteria.ToString(), this.productCriteria.ToString(), translog.Count);    // 21Jan15 XN 108627 added productCriteria

        // If required group data
        // both grouped or ungrouped are assigned to rows which is then passed to the grid
        IEnumerable rows;
        if (generalCriteria.groupBy)
        {
            Dictionary<string,GroupedDrugRow> groupedRows = new Dictionary<string,GroupedDrugRow>();
            foreach (WTranslogRow row in translog)
                AddRowToGroup(groupedRows, PharmacyLogType.Translog, row.NSVCode, row.ConversionFactorPackToIssueUnits, row.IssueUnits, row.ProductDescription, row.QuantityInIssueUnits);
            rows = groupedRows.Values.OrderBy(r => r.NSVCode);
        }
        else
            rows = translog.Where(r => r.DateTime >= generalCriteria.fromDate && r.DateTime <= generalCriteria.toDate);

        // Populate grid
        SetupColumns(columnFormat, generalCriteria.groupBy ? GroupedlogColumns : NewTranslogColumns);
        foreach (object row in rows)
        {
            try
            {
                logGrid.AddRow(row, columnLayouts, FieldConvterFunction);
            }
            catch (Exception ex)
            {
                logGrid.SetCell(logGrid.ColumnCount - 1, ex.Message);
            }
        }
    }

    /// <summary>Searches for and displays rows from WOrderlog and WTranslog</summary>
    /// <param name="generalCriteria">General search criteria</param>
    /// <param name="combinedlogSettings">Combined search criteria</param>
    /// <param name="columnFormat">Columns to display (see pharmacy grid control), or null for default columns</param>
    public void Initalise(GeneralSearchCriteria generalSettings, CombinedLogSearchCriteria combinedlogSettings, string columnFormat)
    {
        // V9 did not allow group by with a combined logged (but would just tell user there was too much data)
        if (generalSettings.groupBy)
            throw new ApplicationException("Group by not supported for combined log viewer display.");

        this.moneyDisplayType = generalSettings.moneyDisplayType;
        this.pharmacyLog      = generalSettings.pharmacyLog;

        // Create search criteria
        AddSiteCriteria("Wlog", "SiteID", generalSettings.siteNumbers);
        AddCriteria("Wlog", "siscode",     "NSVCode",      generalSettings.NSVCode         );
        AddCriteria("Wlog", "DispID",      "UserID",       generalSettings.userInitials    );
        AddCriteria("Wlog", "Batchnum",    "BatchNumber",  combinedlogSettings.batchNumber );
        AddCriteria("Wlog", "Terminal",    "Terminal",     generalSettings.terminal        );
        string whereClause = this.criteria.ToString();

        // Create orderlog search criteria
        this.criteria.Length = 0;
        AddDateCriteria(PharmacyLogType.Orderlog, generalSettings);
        string orderlogCriteria = string.Format("WHERE {0} {1}", criteria, whereClause.Replace("Wlog", "WOrderlog"));

        // Create translog search criteria
        this.criteria.Length = 0;
        AddDateCriteria(PharmacyLogType.Translog, generalSettings);
        string translogCriteria = string.Format("WHERE {0} {1}", criteria, whereClause.Replace("Wlog", "WTranslog"));

        // Load rows from db
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.Add(new SqlParameter("@SessionID",    SessionInfo.SessionID   ));
        parameters.Add(new SqlParameter("@WtranslogSQL", translogCriteria        ));
        parameters.Add(new SqlParameter("@WorderlogSQL", orderlogCriteria        ));
        parameters.Add(new SqlParameter("@MaximumRows",  LogViewSettings.MaxRows ));
        GenericTable2 genericTable = new GenericTable2();
        genericTable.LoadBySP("pWCombinedLogsbyCriteriaNEW", parameters); 

        // Setup search display criteria text
        SetDisplaySearchCriteria(generalSettings, this.displayCriteria.ToString(), this.productCriteria.ToString(), genericTable.Count);    // 21Jan15 XN 108627 added productCriteria

        // Populate grid
        SetupColumns(columnFormat, NewCombinedlogColumns);
        foreach (BaseRow row in genericTable)
        {
            try
            {
                logGrid.AddRow(row, columnLayouts, FieldConvterFunction);
            }
            catch (Exception ex)
            {
                logGrid.SetCell(logGrid.ColumnCount - 1, ex.Message);
            }
        }
    }

    /// <summary>Search's for and displays rows from WPharmacyLog</summary>
    /// <param name="generalCriteria">General search criteria</param>
    /// <param name="pharmacyLogCriteria">Pharmacy specific search criteria</param>
    /// <param name="columnFormat">WPharmacyLog columns to display (see pharmacy grid control), or null for default columns</param>
    public void Initalise(GeneralSearchCriteria generalCriteria, PharmacyLogSearchCriteria pharmacyLogCriteria, string columnFormat)
    {
        // Does not support group by 
        if (generalCriteria.groupBy)
            throw new ApplicationException("Orderlog group by option does not work with pharmacy log");
        if (generalCriteria.useLogDateTime)
            throw new ApplicationException("Orderlog, Translog use log datetime option does not work with pharmacy log");

        this.moneyDisplayType = generalCriteria.moneyDisplayType;
        this.pharmacyLog      = generalCriteria.pharmacyLog;

        // Create search criteria
        criteria.Append(" WHERE ");
        AddDateCriteria(PharmacyLogType.PharmacyLog, generalCriteria);
        AddSiteCriteria("WPharmacylog", "SiteID", generalCriteria.siteNumbers);
        //AddCriteria("WPharmacylog", "Description", "Log type", pharmacyLogCriteria.logType ); 23Feb15 XN Use new WPharmacyLogType
        AddCriteria("WPharmacylog", "WPharmacyLogTypeID", EnumViaDBLookupAttribute.ToLookupID(pharmacyLogCriteria.logType), "Log type", pharmacyLogCriteria.logType.ToString());
        AddCriteria("WPharmacylog", "Thread",      "Thread",   pharmacyLogCriteria.thread  );   // XN 28Aug14 88922 Added
        AddCriteria("WPharmacylog", "NSVCode",     "NSVCode",  generalCriteria.NSVCode     );
        AddCriteria("WPharmacylog", "Terminal",    "Terminal", generalCriteria.terminal    );
        AddCriteria("[Person]",     "Initials",    "UserID",   generalCriteria.userInitials);

        // Load rows from db
        WPharmacyLog pharmacylog = new WPharmacyLog();
        pharmacylog.LoadByCriteria(this.criteria.ToString(), LogViewSettings.MaxRows);

        // Setup search display criteria text
        SetDisplaySearchCriteria(generalCriteria, this.displayCriteria.ToString(), this.productCriteria.ToString(), pharmacylog.Count); // 21Jan15 XN 108627 added productCriteria

        // Setup columns
        SetupColumns(columnFormat, NewPharmacylogColumns);
        if (columnLayouts.Any(c => c.FieldName.EqualsNoCase("Detail")))
        {
            int indexOf = columnLayouts.IndexOf(columnLayouts.First(c => c.FieldName.EqualsNoCase("Detail")));
            logGrid.ColumnXMLEscaped(indexOf, false);
        }

        // Populate grid
        foreach (WPharmacyLogRow row in pharmacylog)
        {
            row.Detail = row.Detail.Replace("\n", "<br />");
            logGrid.AddRow(row, columnLayouts, FieldConvterFunction);
        }
    }
    #endregion

    #region Private Methods
    /// <summary>Takes the column format string, and creates the column headers for the grid</summary>
    /// <param name="columnFormat">User defined column format</param>
    /// <param name="defaultColumnFormat">Default column format to use if defaultColumnFormat is null</param>
    private void SetupColumns(string columnFormat, string defaultColumnFormat)
    {
        // Convert string to header structure
        if (string.IsNullOrEmpty(columnFormat))
            columnFormat = defaultColumnFormat;
        columnLayouts = PharmacyGridControl.ParseColumnSetup(columnFormat);

        // Sort out headers that need extra parsing
        foreach (PharmacyGridControl.ColumnLayoutHelper header in columnLayouts)
        {
            switch (header.Header.Trim().ToLower())
            {
            case "{nhnumber}": 
                bool displayNHSValid = WConfiguration.LoadAndCache<bool> (SessionInfo.SiteID, "D|Winord", "LogViewer",     "DisplayNHValid", true,   false);
                string NHSValidHeader = displayNHSValid ? WConfiguration.LoadAndCache<string>(SessionInfo.SiteID, "D|Winord", "LogViewer", "NHValidHeader",  " (Valid)", false) : string.Empty;
                header.Header = PharmacyCultureInfo.NHSNumberDisplayName + NHSValidHeader;          
                break;

            case "{casenumber}":
                header.Header = PharmacyCultureInfo.CaseNumberDisplayName;
                break;

            case "{cost}":
                header.Header = string.Format("Cost ({0})", PharmacyCultureInfo.CurrencyHundredths);
                break;

            case "{costexvat}":
                header.Header = string.Format("CostExVat ({0})", PharmacyCultureInfo.CurrencyHundredths);
                break;

            case "{vatcost}":
                header.Header = string.Format("Vat ({0})", PharmacyCultureInfo.CurrencyHundredths);
                break;

            case "{stockvalue}":
                header.Header = string.Format("Stock Value ({0})", PharmacyCultureInfo.CurrencyHundredths);
                break;

            case "{customerorderno}":
                bool displayPickingTicketNo = WConfiguration.LoadAndCache<string>(SessionInfo.SiteID, "D|Winord", "PickingTicket", "TranslogEntry",  "N",    false).EqualsNoCaseTrimEnd("PICKTICKNO");
                bool displayCustomerOrderNo = WConfiguration.LoadAndCache<bool>  (SessionInfo.SiteID, "D|Winord", "defaults",      "PromptCustOrdNo", false, false);
                if (displayPickingTicketNo)
                    header.Header = "Pick Tic No";
                else if (displayCustomerOrderNo)
                    header.Header = "Cust Ord No";
                else
                    header.Header = null;
                break;

            case "{batchnumber}":
                bool displayBatchNumber = WConfiguration.LoadAndCache<bool>(SessionInfo.SiteID, "D|Winord", "LogViewer", "Displaybatchnumber", true, false);
                header.Header = displayBatchNumber ? "Batch Number" : null;
                break;
            }
        }

        // Remove columns no longer needed
        columnLayouts.RemoveAll(c => c.Header == null);

        // Setup columns
        logGrid.AddColumns(columnLayouts);

        // Set column without width (so expanded to max width) 
        // to allow text wrapping as probably the drug description
        int maxSizeCol = columnLayouts.FindIndex(c => c.Width == null);
        if (maxSizeCol >= 0)
            logGrid.ColumnAllowTextWrap(maxSizeCol, true);
    }

    /// <summary>
    /// Passed to PharmacyGridControl to handle fields that need special conversion
    /// </summary>
    /// <param name="row">Row being converted</param>
    /// <param name="fieldName">Name of field to convert</param>
    /// <param name="fieldFormat">Format string for field (can be empty)</param>
    /// <returns>Value to display inn grid cell</returns>
    private string FieldConvterFunction(object row, string fieldName, string fieldFormat)
    {
        WTranslogRow    translogRow     = (row as WTranslogRow);
        WOrderlogRow    orderlogRow     = (row as WOrderlogRow);
        GroupedDrugRow  groupedDrugRow  = (row as GroupedDrugRow);
        BaseRow         baseRow         = (row as BaseRow);

        switch (fieldName.Trim().ToLower())
        {
        case "{casenumber}": 
            if (!string.IsNullOrEmpty(translogRow.CaseNumber))
                return translogRow.CaseNumber;
            else if (translogRow.PatientID != null)
                return string.Format("({0))", translogRow.PatientID);
            break;

        case "{nhnumber}":
            string NHSNumber = translogRow.NHNumber;
            bool displayNHSValid = WConfiguration.LoadAndCache<bool> (SessionInfo.SiteID, "D|Winord", "LogViewer", "DisplayNHValid", true, false);
            if (displayNHSValid && translogRow.NHNumberValid != null)
            {
                if (translogRow.NHNumberValid.Value)
                    NHSNumber += WConfiguration.LoadAndCache<string>(SessionInfo.SiteID, "D|Winord", "LogViewer", "NHValidLine",   " (Y)", false); 
                else
                    NHSNumber += WConfiguration.LoadAndCache<string>(SessionInfo.SiteID, "D|Winord", "LogViewer", "NHInValidLine", " (N)", false);
            }
            return NHSNumber;

        case "{qty}":
            if (translogRow != null)
                return string.Format(fieldFormat, translogRow.QuantityInIssueUnits, translogRow.IssueUnits);
            else if (groupedDrugRow != null && groupedDrugRow.PharmacyLog == PharmacyLogType.Translog)
            {
                if (groupedDrugRow.Quantity % groupedDrugRow.ConversionFactor == 0)
                    return string.Format("{0:0.###} x {1} {2}", groupedDrugRow.Quantity / groupedDrugRow.ConversionFactor, groupedDrugRow.ConversionFactor, groupedDrugRow.IssueUnits);
                else
                    return string.Format("{0:0.###} {1}", groupedDrugRow.Quantity, groupedDrugRow.IssueUnits);
            }
            else if (groupedDrugRow != null && groupedDrugRow.PharmacyLog == PharmacyLogType.Orderlog)
            {
                if (groupedDrugRow.Quantity == ((int)groupedDrugRow.Quantity))
                    return string.Format("{0:0.###} x {1} {2}", groupedDrugRow.Quantity, groupedDrugRow.ConversionFactor, groupedDrugRow.IssueUnits);
                else
                    return string.Format("{0:0.###} {1}", groupedDrugRow.Quantity * groupedDrugRow.ConversionFactor, groupedDrugRow.IssueUnits);
            }
            else
            {   
                string logType = (string)baseRow.RawRow["logtype"];
                if (logType.EqualsNoCaseTrimEnd("trans"))
                    return string.Format("{0} {1}", baseRow.RawRow["qty"], baseRow.RawRow["IssueUnits"]);
                else
                    return string.Format("{0} * {1} {2}", baseRow.RawRow["qty"], baseRow.RawRow["convfact"], baseRow.RawRow["IssueUnits"]);
            }

        case "{cost}":
            if (this.moneyDisplayType == MoneyDisplayType.Hide)
                return "*****";
            else if (this.moneyDisplayType == MoneyDisplayType.HideWithLeadingSpace)
                return " ****";
            else
                return (string)baseRow.RawRow["cost"];

        case "{costexvat}":
            if (this.moneyDisplayType == MoneyDisplayType.Hide)
                return "*****";
            else if (this.moneyDisplayType == MoneyDisplayType.HideWithLeadingSpace)
                return " ****";
            else
            {
                if (baseRow.RawRow.Table.Columns.Contains("CostExVat"))
                    return (string)baseRow.RawRow["CostExVat"];
                else if (baseRow.RawRow.Table.Columns.Contains("CostExTax"))
                    return (string)baseRow.RawRow["CostExTax"];
            }
            break;

        case "{vatcost}":
            if (this.moneyDisplayType == MoneyDisplayType.Hide)
                return "*****";
            else if (this.moneyDisplayType == MoneyDisplayType.HideWithLeadingSpace)
                return " ****";
            else
            {
                if (baseRow.RawRow.Table.Columns.Contains("VatCost"))
                    return (string)baseRow.RawRow["VatCost"];
                else if (baseRow.RawRow.Table.Columns.Contains("TaxCost"))
                    return (string)baseRow.RawRow["TaxCost"];
            }
            break;

        case "{stocklvl}":
            if (orderlogRow != null && orderlogRow.ConversionFactor != null && orderlogRow.ConversionFactor > 0 && orderlogRow.StockLevel != null)
                return string.Format(fieldFormat, (orderlogRow.StockLevel.Value / orderlogRow.ConversionFactor));
            else if (translogRow != null && translogRow.ConversionFactorPackToIssueUnits > 0 && translogRow.StockLevel != null)
                return string.Format(fieldFormat, (translogRow.StockLevel.Value / translogRow.ConversionFactorPackToIssueUnits));
            else if (baseRow.RawRow.Table.Columns.Contains("stocklvl"))
                return baseRow.RawRow["stocklvl"].ToString();
            return "0";

        case "{productdescription_combined}":
            if (baseRow.RawRow.Table.Columns.Contains("Description") && baseRow.RawRow["Description"] != DBNull.Value)
            {
                return baseRow.RawRow["Description"].ToString().TrimEnd().Replace('!', ' '); 
            }
            else
            {
                return string.Empty;
            }
            
            break;

        case "{datetime_combined}":
            string dateTimeStr = (string)baseRow.RawRow["datetime"];
            DateTime? dateTime     = new BaseRow().FieldStrDateToDateTime(dateTimeStr.SafeSubstring(0, 8), BaseRow.DateType.YYYYMMDD);
            TimeSpan? timeReceived = new BaseRow().FieldStrTimeToTimeSpan(dateTimeStr.SafeSubstring(8, 6));     
            if (dateTime != null && timeReceived != null)
                return (dateTime.Value + timeReceived.Value).ToPharmacyDateTimeString();
            else if (dateTime != null)
                return dateTime.Value.ToPharmacyDateString();
            break;
        }

        return string.Empty;
    }

    /// <summary>Form shows the search criteria used</summary>
    /// <param name="generalSettings">General search criteria used</param>
    /// <param name="displayCriteria">Detailed search criteria</param>
    /// <param name="productCriteria">Product search criteria 21Jan15 XN 108627</param>
    /// <param name="rowCount">Number of rows displayed in the gird</param>
    private void SetDisplaySearchCriteria(GeneralSearchCriteria generalSettings, string displayCriteria, string productCriteria, int rowCount)
    {   
        // Show\hide grouping message
        trGroupByMsgTranslog.Visible = generalSettings.groupBy && generalSettings.pharmacyLog == PharmacyLogType.Translog;
        trGroupByMsgOrderlog.Visible = generalSettings.groupBy && generalSettings.pharmacyLog == PharmacyLogType.Orderlog;

        // Convert from date
        string fromDate = string.Empty;
        if (generalSettings.fromDate == DateTimeExtensions.MinDBValue)
            fromDate = "(start)";
        else if (generalSettings.useLogDateTime)
            fromDate = generalSettings.fromDate.ToPharmacyDateTimeString();
        else
            fromDate = generalSettings.fromDate.ToPharmacyDateString();
        
        // Convert to date
        string toDate = string.Empty;
        if (generalSettings.toDate == DateTimeExtensions.MaxDBValue)
            toDate = "(end)";
        else if (generalSettings.useLogDateTime)
            toDate = generalSettings.toDate.ToPharmacyDateTimeString();
        else
            toDate = generalSettings.toDate.ToPharmacyDateString();

        // Set control labels
        switch (generalSettings.pharmacyLog)
        {
        case PharmacyLogType.PharmacyLog:   lbLogFile.Text = "Pharmacy logs"; break;
        case PharmacyLogType.Orderlog:      lbLogFile.Text = "Orderlog";      break;
        case PharmacyLogType.Translog:      lbLogFile.Text = "Translog";      break;
        case PharmacyLogType.Unknown :      lbLogFile.Text = "Combined logs"; break;
        }
        
        lbDate.Text          = string.Format("{0} to {1} {2}", fromDate, toDate, generalSettings.useLogDateTime ? "(using LogDateTime)" : string.Empty);
        trProductRow.Visible = !string.IsNullOrEmpty(productCriteria);  // 21Jan15 XN 108627
        lbProduct.Text       = productCriteria;                         // 21Jan15 XN 108627
        lbSearchFor.Text     = displayCriteria;
        lbSiteCode.Text      = generalSettings.siteNumbers.Any() ? generalSettings.siteNumbers.Select(s => s.ToString("000")).ToCSVString(",") : "<All>".XMLEscape();

        // Enabled Max Row label warning if needed
        if (rowCount == LogViewSettings.MaxRows)
        {
            lbReachedMaxRowCount.Text = string.Format(lbReachedMaxRowCount.Text, LogViewSettings.MaxRows);
            lbReachedMaxRowCount.Visible = true;
        }
    }

    /// <summary>
    /// Add row to current group rows.
    /// If row does not exist it is added to groupedRows, otherwise the quantity is added to the existing value
    /// </summary>
    /// <param name="groupedRows">Current list of grouped rows</param>
    /// <param name="pharmacyLog">Pharmacy Log</param>
    /// <param name="NSVCode">NSV code</param>
    /// <param name="conversionFactor">Conversion factor</param>
    /// <param name="issueUnits">Issue units</param>
    /// <param name="productDescription">Drug description</param>
    /// <param name="quantity">Quantity</param>
    private void AddRowToGroup(Dictionary<string,GroupedDrugRow> groupedRows, PharmacyLogType pharmacyLog, string NSVCode, int conversionFactor, string issueUnits, string productDescription, decimal quantity)
    {
        GroupedDrugRow drugDetails;
        if (!groupedRows.TryGetValue(NSVCode, out drugDetails))
        {
            drugDetails = new GroupedDrugRow();
            drugDetails.PharmacyLog         = pharmacyLog;
            drugDetails.NSVCode             = NSVCode;
            drugDetails.ConversionFactor    = conversionFactor;
            drugDetails.ProductDescription  = productDescription;
            drugDetails.Quantity            = 0m;
            drugDetails.IssueUnits          = issueUnits;

            groupedRows.Add(NSVCode, drugDetails);
        }
        drugDetails.Quantity += quantity;
    }

    /// <summary>
    /// Adds SQL search string for date to this.criteria
    /// For orderlog uses (((DateOrd >= fromDate AND kind <> 'Q') AND (DateOrd <= toDate AND kind <> 'Q')) OR (DateRec >= fromDate AND DateRec <= toDate))
    /// For translog uses [Date] >= fromDate AND [Date]  <= toDate
    /// 
    /// If dates include times also adds time filter to log string
    /// </summary>
    private void AddDateCriteria(PharmacyLogType pharmacyLog, GeneralSearchCriteria generalCriteria)
    {
        if (generalCriteria.useLogDateTime)
        {
            DateTime from = DateTimeExtensions.Max(generalCriteria.fromDate, DateTimeExtensions.MinDBValue);
            DateTime to   = DateTimeExtensions.Min(generalCriteria.toDate,   DateTimeExtensions.MaxDBValue);
            criteria.AppendFormat(" [LogDateTime] BETWEEN '{0:dd MMM yyyy HH:mm:ss:fff}' AND '{1:dd MMM yyyy HH:mm:ss:fff}'", from, to); 
        }
        else
        {
            switch (pharmacyLog)
            {
            case PharmacyLogType.Translog: 
                criteria.AppendFormat(" [Date] >= {0:yyyyMMdd} AND [Date]  <= {1:yyyyMMdd}", generalCriteria.fromDate, generalCriteria.toDate); 
                break; 
            case PharmacyLogType.Orderlog: 
                criteria.AppendFormat(" (((DateOrd >= {0:yyyyMMdd} AND kind <> 'Q') AND (DateOrd <= {1:yyyyMMdd} AND kind <> 'Q')) OR (DateRec >= {0:yyyyMMdd} AND DateRec <= {1:yyyyMMdd}))", generalCriteria.fromDate, generalCriteria.toDate); 
                break; 
            case PharmacyLogType.PharmacyLog:
                criteria.AppendFormat(" [DateTime] >= '{0:yyyy-MM-dd}' AND [DateTime] <= '{1:yyyy-MM-dd}'", generalCriteria.fromDate, generalCriteria.toDate); 
                break; 
            case PharmacyLogType.Unknown:  
                throw new NotSupportedException("DisplayLogRows.apsx method CreateCriteria does not support PharmacyLogType.Unknown."); 
            }
        }
    }

    /// <summary>Adds sql search string to for sites to this.critera</summary>
    private void AddSiteCriteria(string tableName, string dbFieldName, IEnumerable<int> siteNumbers)
    {
        if (siteNumbers.Count() == 1)
            criteria.AppendFormat(" AND {0}.{1}={2}", tableName, dbFieldName, siteNumbers.Select(n => Sites.GetSiteIDByNumber(n)).First());                    
        else if (siteNumbers.Count() > 1)
        {
            Sites sites = new Sites();
            sites.LoadAll();
            var siteIDs = siteNumbers.Select(n => sites.FindBySiteNumber(n).SiteID);
            criteria.AppendFormat(" AND {0}.{1} in ({2})", tableName, dbFieldName, siteIDs.ToCSVString(","));                    
        }
    }

    /// <summary>
    /// Adds SQL search string for field value to this.criteria as AND tableName.[dbfieldName]='fieldValue'
    /// Also adds search condition to this.displayCriteria as displayFieldName = fieldValue
    /// (if dbFieldName is NSVCode then condition is added to productCriteria instead)
    /// Replaces all ', and ; values in fieldValue with empty string 
    /// </summary>
    /// <param name="tableName">Worderlog or WTranslog</param>
    /// <param name="dbFieldName">DB field name to search on e.g. siscode</param>
    /// <param name="displayFieldName">Name display on controls search criteria (displayed to user) e.g. NSVCode</param>
    /// <param name="fieldValue">Field value to search for</param>
    private void AddCriteria(string tableName, string dbFieldName, string displayFieldName, string fieldValue)
    {
        if (!string.IsNullOrEmpty(fieldValue))
        {
            fieldValue = fieldValue.Replace("'", string.Empty).Replace(";", string.Empty);
            this.criteria.AppendFormat(" AND {0}.[{1}]='{2}'", tableName, dbFieldName, fieldValue);
            
            // Add field to display criteria (or product criteria for NSVCode 21Jan15 XN 108627)  
            if (dbFieldName.EqualsNoCaseTrimEnd("NSVCode") || dbFieldName.EqualsNoCaseTrimEnd("siscode"))
            {
                WProduct products = new WProduct();
                products.LoadByNSVCode(fieldValue);
                var product = products.FindBySiteID(SessionInfo.SiteID) == null ? products.First() : products.FindBySiteID(SessionInfo.SiteID).FirstOrDefault();
                if (product != null)
                {
                    this.productCriteria.Append(" - " + product.ToString());
                }
            }
            else
            {
                this.displayCriteria.AppendFormat("{0} = {1},", displayFieldName, fieldValue);
            }
        }
    }

    /// <summary>
    /// Adds SQL search string for field value to this.criteria as AND tableName.[dbfieldName]='fieldValue'
    /// Also adds search condition to this.displayCriteria as displayFieldName = fieldValue
    /// 
    /// Won't add if fieldValue is null, ', or ; values
    /// </summary>
    /// <param name="tableName">Worderlog or WTranslog</param>
    /// <param name="dbFieldName">DB field name to search on e.g. siscode</param>
    /// <param name="displayFieldName">Name display on controls search criteria (displayed to user) e.g. NSVCode</param>
    /// <param name="fieldValue">Field value to search for</param>
    private void AddCriteria(string tableName, string dbFieldName, string displayFieldName, char fieldValue)
    {
        if (fieldValue != '\0' && fieldValue != '\'' && fieldValue != ';')
        {
            criteria.AppendFormat(" AND {0}.[{1}]='{2}'", tableName, dbFieldName, fieldValue);
            displayCriteria.AppendFormat("{0} = {1},", displayFieldName, fieldValue);
        }
    }

    /// <summary>
    /// Adds SQL search string for field value to this.criteria as AND tableName.[dbfieldName] in ('fieldValue1', 'fieldValue2')
    /// Also adds search condition to this.displayCriteria as displayFieldName = fieldValue1, fieldValue2
    /// 
    /// Replaces all ', and ; values in fieldValue with empty string
    /// XN 28Aug14 88922
    /// </summary>
    /// <param name="tableName">Worderlog or WTranslog</param>
    /// <param name="dbFieldName">DB field name to search on e.g. siscode</param>
    /// <param name="displayFieldName">Name display on controls search criteria (displayed to user) e.g. NSVCode</param>
    /// <param name="fieldValues">Field values to search for</param>
    private void AddCriteria(string tableName, string dbFieldName, string displayFieldName, string[] fieldValues)
    {
        if (fieldValues != null && fieldValues.Any())
        {
            //System.Web.HttpRuntime.AppDomainAppVirtualPath
            for (int c = 0; c < fieldValues.Length; c++)
                fieldValues[c] = fieldValues[c].Replace("'", String.Empty).Replace(";", String.Empty);

            criteria.AppendFormat(" AND {0}.[{1}] in (", tableName, dbFieldName);
            criteria.AppendFormat("'" + fieldValues.ToCSVString("','") + "'");
            criteria.AppendFormat(")");
            displayCriteria.AppendFormat("{0} = {1},", displayFieldName, fieldValues.ToCSVString(", "));
        }
    }

    /// <summary>
    /// Adds SQL search string for field value to this.criteria as AND tableName.[dbfieldName]={int}
    /// Also adds search condition to this.displayCriteria as displayFieldName = fieldValue
    /// 
    /// Won't add if fieldValue is null
    /// XN 28Aug14 88922
    /// </summary>
    /// <param name="tableName">Worderlog or WTranslog</param>
    /// <param name="dbFieldName">DB field name to search on e.g. siscode</param>
    /// <param name="displayFieldName">Name display on controls search criteria (displayed to user) e.g. NSVCode</param>
    /// <param name="fieldValue">Field value to search for</param>
    private void AddCriteria(string tableName, string dbFieldName, string displayFieldName, int? fieldValue)
    {
        if (fieldValue != null)
        {
            criteria.AppendFormat(" AND {0}.[{1}]={2}", tableName, dbFieldName, fieldValue);
            displayCriteria.AppendFormat("{0} = {1},", displayFieldName, fieldValue);
        }
    }
    
    /// <summary>
    /// Adds SQL search string for field value to this.criteria as AND tableName.[dbfieldName]={int}
    /// Also adds search condition to this.displayCriteria as displayFieldName = displayFieldValue
    /// Won't add if to either item if the value is null
    /// 23Feb15 XN added new WPharmacyLogType
    /// </summary>
    /// <param name="tableName">Worderlog or WTranslog</param>
    /// <param name="dbFieldName">DB field name to search on e.g. siscode</param>
    /// <param name="dbFieldValue">DB field value to search for</param>
    /// <param name="displayFieldName">Name display on controls search criteria (displayed to user) e.g. NSVCode</param>
    /// <param name="displayFieldValue">Display field value to search for</param>
    public void AddCriteria(string tableName, string dbFieldName, object dbFieldValue, string displayFieldName, string displayFieldValue)
    {
        if (dbFieldValue != null)
        {
            criteria.AppendFormat(" AND {0}.[{1}]={2}", tableName, dbFieldName, dbFieldValue is string ? "'" + dbFieldName + "'" : dbFieldValue);
        }

        if (displayFieldValue != null)
        {
            displayCriteria.AppendFormat("{0} = {1},", displayFieldName, displayFieldValue);
        }
    }
    #endregion
}

