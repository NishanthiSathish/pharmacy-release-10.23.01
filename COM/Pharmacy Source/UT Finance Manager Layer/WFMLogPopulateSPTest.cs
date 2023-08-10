using System;
using System.Configuration;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.basedatalayer;
using System.Data.SqlClient;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.financemanagerlayer;

namespace UT_Finance_Manager_Layer
{
    /// <summary>
    /// Unit tests sp pWFMLogCachePopulate which is effectivly the finance manager engine.
    /// The sp is used to populate the WFMLogCache tables from WOrderlog and WTranslog
    /// </summary>
    [TestClass]
    public class WFMLogPopulateSPTest
    {
        private static int SessionID;            // both relate to rows in the session table

        const int SiteIDA = 15; // both relate to rows in the site table
        const int SiteIDB = 19;

        private static readonly string OrderNumber = "91919";

        private static readonly string NSVCodeA = "ADE996B";

        private static readonly string SupCodeA = "AA010";

        private static readonly string WardCodeA = "A2";

        public WFMLogPopulateSPTest()
        {
        }

        private TestContext testContextInstance;

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext
        {
            get
            {
                return testContextInstance;
            }
            set
            {
                testContextInstance = value;
            }
        }

        #region Additional test attributes
        //
        // You can use the following additional attributes as you write your tests:
        //
        // Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext) 
        { 
           SessionID = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC", new List<SqlParameter>());

           // Initalise the SessionInfo class
           SessionInfo.InitialiseSessionAndSiteID(SessionID, SiteIDA);

           // update session
           Database.ExecuteSQLNonQuery("UPDATE Session SET Disconnected=0, DateCreated=GETDATE(), DateLastUsed=GETDATE() WHERE SessionID={0}",  SessionID);
        }
        
        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        //
        // Use TestInitialize to run code before running each test 
        [TestInitialize()]
        public void MyTestInitialize() 
        { 
            // Check have cleaned up
            MyTestCleanup();

            // Add in dummy (so can add dummy FM logs entries)
            WFMRule rules = new WFMRule();
            WFMRuleRow rule = rules.Add();
            rule.Code = 0;
            rule.Description = string.Empty;
            rule.Kind = string.Empty;
            rule.PharmacyLog = PharmacyLogType.Unknown;
            rule.CostFieldRequired = false;
            rule.StockFieldSelector = string.Empty;
            rule.CostMultiply = "1";
            rule.StockMultiply = "1";
            rule.AccountCode_Credit = 0;
            rule.AccountCode_Debit = 0;
            rules.Save();

            // Add dummy row for WOrderlog to prevent tests running on all WOrderlog items
            int orderlogID = Database.ExecuteSQLScalar<int>("SELECT MAX(WorderLogID) FROM WorderLog");
            Database.ExecuteSQLNonQuery("INSERT INTO WFMLogCache (WLogID, PharmacyLog, RuleCode, AccountCode_Debit,AccountCode_Credit, Qty, CostExVat, CostIncVat, VatCost, [NSVCode], LocationID_Site, OrderNum, SupCode, WardCode, [LogDateTime]) VALUES ({0}, 'O', '{1}', '', '', 0, 0, 0, 0, '', '', '', '', '', '1 Jan 1990')", orderlogID, rule.Code);

            // Add dummy row for WTranslog to prevent tests running on all WFMTranslog items
            int translogID = Database.ExecuteSQLScalar<int>("SELECT MAX(WTransLogID) FROM WTransLog");
            Database.ExecuteSQLNonQuery("INSERT INTO WFMLogCache (WLogID, PharmacyLog, RuleCode, AccountCode_Debit,AccountCode_Credit, Qty, CostExVat, CostIncVat, VatCost, [NSVCode], LocationID_Site, OrderNum, SupCode, WardCode, [LogDateTime]) VALUES ({0}, 'T', '{1}', '', '', 0, 0, 0, 0, '', '', '', '', '', '1 Jan 1990')", translogID, rule.Code);
        }

        //
        // Use TestCleanup to run code after each test has run
        [TestCleanup()]
        public void MyTestCleanup() 
        {
            Database.ExecuteSQLNonQuery("DELETE WFMLogCache");
            Database.ExecuteSQLNonQuery("DELETE WOrderlog WHERE OrderNum='{0}'", OrderNumber);            
            Database.ExecuteSQLNonQuery("DELETE WFMRule");
        }        
        #endregion

        [TestMethod]
        [Description("Test pWFMLogCachePopulate can update form WOrderlog on a simple rule")]
        public void TestUpdatesFromOrderLog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code        = 1010;
            rules[0].Description = "Test";
            rules[0].PharmacyLog = PharmacyLogType.Orderlog;
            rules[0].Kind        = "R"; // Receipt
            rules[0].AccountCode_Credit = 210;
            rules[0].AccountCode_Debit  = 310;
            rules[0].CostFieldRequired = true;
            rules[0].StockFieldSelector= "QtyRec";
            rules[0].CostMultiply = "1";
            rules[0].StockMultiply = "1";

            rules.Add();
            rules[1].Code        = 1012;
            rules[1].Description = "Test";
            rules[1].PharmacyLog = PharmacyLogType.Orderlog;
            rules[1].Kind        = "T"; // Invoice
            rules[1].AccountCode_Credit = 211;
            rules[1].AccountCode_Debit  = 311;
            rules[1].CostFieldRequired = true;
            rules[1].StockFieldSelector= "QtyRec";
            rules[1].CostMultiply = "1";
            rules[1].StockMultiply = "1";
            rules.Save();

            // Add test orderlog data
            int IDa = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, SupCodeA);

            int IDb = AddOrderlogRow(WOrderLogType.ReconciliationTransaction, SiteIDA, NSVCodeA, SupCodeA);
            int IDc = AddOrderlogRow(WOrderLogType.ReconciliationTransaction, SiteIDA, NSVCodeA, SupCodeA);

            // Add row that does not have a rule
            int IDd = AddOrderlogRow(WOrderLogType.Ordered, SiteIDA, NSVCodeA, SupCodeA);

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Orderlog));

            // Check correct rows are added
            AssertCachedOrderlogRowDoNotExists(rules[0], IDa);
            AssertCachedOrderlogRowDoNotExists(rules[1], IDb, IDc);
            AssertWFMLogCacheRowCountNotEqualTo(3);
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate can update from WOrderlog based on different NSVCode, and Supplier code")]
        public void TestUpdatesOrderLogFileterdByNSVCodeSupCode()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code        = 1010;
            rules[0].Description = "Test";
            rules[0].PharmacyLog = PharmacyLogType.Orderlog;
            rules[0].Kind        = "R"; // Receipt
            rules[0].NSVCode     = NSVCodeA;
            rules[0].SupCode     = SupCodeA;
            rules[0].AccountCode_Credit = 210;
            rules[0].AccountCode_Debit  = 310;
            rules[0].CostFieldRequired = true;
            rules[0].StockFieldSelector= "QtyRec";
            rules[0].CostMultiply = "1";
            rules[0].StockMultiply = "1";
            rules.Save();

            // Add test orderlog data

            // Add dummy data
            int IDa = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, "SUPTE");
            int IDb = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, "NSVCODE", SupCodeA);

            // Actual rows with rules
            int IDc = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, SupCodeA);
            int IDd = AddOrderlogRow(WOrderLogType.Receipt, SiteIDB, NSVCodeA, SupCodeA);

            // Add dummy data
            int IDe = AddOrderlogRow(WOrderLogType.Receipt, SiteIDB, "NSVCODE", "SUPTE");

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Orderlog));

            // Check correct rows added
            AssertCachedOrderlogRowDoNotExists(rules[0], IDc, IDd);
            AssertWFMLogCacheRowCountNotEqualTo(2);
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate can update from WOrderlog based on different LabelType")]
        public void TestUpdatesOrderLogFileterdByLabelType()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code        = 1010;
            rules[0].Description = "Test";
            rules[0].PharmacyLog = PharmacyLogType.Orderlog;
            rules[0].Kind        = "R"; // Receipt
            rules[0].NSVCode     = NSVCodeA;
            rules[0].SupCode     = string.Empty;
            rules[0].SupplierType= SupplierType.External;
            rules[0].AccountCode_Credit = 210;
            rules[0].AccountCode_Debit  = 310;
            rules[0].CostFieldRequired = true;
            rules[0].StockFieldSelector= "QtyRec";
            rules[0].CostMultiply = "1";
            rules[0].StockMultiply = "1";
            rules.Save();

            // Add test orderlog data
            string supcodeExternal = Database.ExecuteSQLScalar<string>("SELECT TOP 1 Code FROM WSupplier WHERE SupplierType='{0}' AND SiteID={1}", EnumDBCodeAttribute.EnumToDBCode(SupplierType.External), SiteIDA);
            if (string.IsNullOrEmpty(supcodeExternal))
                Assert.Inconclusive("DB contains no extiernal suppliers");
            string supcodeWard = Database.ExecuteSQLScalar<string>("SELECT TOP 1 Code FROM WSupplier WHERE SupplierType='{0}' AND SiteID={1}", EnumDBCodeAttribute.EnumToDBCode(SupplierType.Ward), SiteIDA);
            if (string.IsNullOrEmpty(supcodeWard))
                Assert.Inconclusive("DB contains no ward suppliers");

            // Actual row with rules
            int IDa = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, supcodeExternal);
            // Add dummy data
            int IDb = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, supcodeWard);

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Orderlog));

            // Check correct rows added
            AssertCachedOrderlogRowDoNotExists(rules[0], IDa);
            AssertWFMLogCacheRowCountNotEqualTo(1);
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate does not use rules marked as deleted")]
        public void TestIgnoresDeleteRuleForOrderLog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code        = 1010;
            rules[0].Description = "Test";
            rules[0].PharmacyLog = PharmacyLogType.Orderlog;
            rules[0].Kind        = "R"; // Receipt
            rules[0].AccountCode_Credit = 210;
            rules[0].AccountCode_Debit  = 310;
            rules[0].CostFieldRequired = true;
            rules[0].StockFieldSelector= "QtyRec";
            rules[0].CostMultiply = "1";
            rules[0].StockMultiply = "1";

            rules.Add();
            rules[1].Code        = 1012;
            rules[1].Description = "Test";
            rules[1].PharmacyLog = PharmacyLogType.Orderlog;
            rules[1].Kind        = "T"; // Invoice
            rules[1].AccountCode_Credit = 211;
            rules[1].AccountCode_Debit  = 311;
            rules[1].RawRow["_Deleted"] = true;
            rules[1].CostFieldRequired = true;
            rules[1].StockFieldSelector= "QtyRec";
            rules[1].CostMultiply = "1";
            rules[1].StockMultiply = "1";
            rules.Save();

            // Add test orderlog data
            int IDa = AddOrderlogRow(WOrderLogType.ReconciliationTransaction, SiteIDA, NSVCodeA, SupCodeA); // Won't be logged
            int IDb = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, SupCodeA);
            int IDc = AddOrderlogRow(WOrderLogType.ReconciliationTransaction, SiteIDA, NSVCodeA, SupCodeA); // Won't be logged

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Orderlog));

            // Check correct rows added
            AssertCachedOrderlogRowDoNotExists(rules[0], IDb);
            AssertWFMLogCacheRowCountNotEqualTo(1);
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate runs rules in correct order NSVCode, SupCode for WOrderlog")]
        public void TestRulesRunInCorrectOrderForWOrderlog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code        = 1001;
            rules[0].Description = "Test";
            rules[0].PharmacyLog = PharmacyLogType.Orderlog;
            rules[0].Kind        = "R"; // Receipt
            rules[0].SupCode     = SupCodeA;
            rules[0].NSVCode     = NSVCodeA;
            rules[0].AccountCode_Credit = 111;
            rules[0].AccountCode_Debit  = 110;
            rules[0].CostFieldRequired = true;
            rules[0].StockFieldSelector= "QtyRec";
            rules[0].CostMultiply = "1";
            rules[0].StockMultiply = "1";

            rules.Add();    // Rule should not run as next rule added will replace it
            rules[1].Code        = 1002;
            rules[1].Description = "Test";
            rules[1].PharmacyLog = PharmacyLogType.Orderlog;
            rules[1].Kind        = "R"; // Receipt
            rules[1].SupCode     = SupCodeA;
            rules[1].AccountCode_Credit = 222;
            rules[1].AccountCode_Debit  = 220;
            rules[1].CostFieldRequired = true;
            rules[1].StockFieldSelector= "QtyRec";
            rules[1].CostMultiply = "1";
            rules[1].StockMultiply = "1";

            rules.Add();
            rules[2].Code        = 1003;
            rules[2].Description = "Test";
            rules[2].PharmacyLog = PharmacyLogType.Orderlog;
            rules[2].Kind        = "R"; // Receipt
            rules[2].AccountCode_Credit = 333;
            rules[2].AccountCode_Debit  = 330;
            rules[2].CostFieldRequired = true;
            rules[2].StockFieldSelector= "QtyRec";
            rules[2].CostMultiply = "1";
            rules[2].StockMultiply = "1";
            rules.Save();

            // Add test orderlog data
            int IDa = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA,  SupCodeA);  // Fired by 1st rule
            int IDb = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, "NSVCODE", SupCodeA);  // Fired by 2nd rule
            int IDc = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA,  SupCodeA);  // Fired by 1st rule
            int IDd = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, "TTTTTTT", "DFEEF" );  // Fired by 3nd rule
            int IDe = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, "NSVCODE", SupCodeA);  // Fired by 2nd rule

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Orderlog));

            // Check correct rows added
            AssertCachedOrderlogRowDoNotExists(rules[0], IDa, IDc);
            AssertCachedOrderlogRowDoNotExists(rules[1], IDb, IDe);
            AssertCachedOrderlogRowDoNotExists(rules[2], IDd);
            AssertWFMLogCacheRowCountNotEqualTo(5);
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate filters based on +ve or -ve cost")]
        public void TestFiletersByPositiveOrNegativeCostFromOrderlog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code                = 1010;
            rules[0].Description         = "Test";
            rules[0].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[0].Kind                = "R"; // Receipt
            rules[0].AccountCode_Credit  = 210;
            rules[0].AccountCode_Debit   = 310;
            rules[0].CostFieldRequired   = true; 
            rules[0].StockFieldSelector  = "QtyRec";
            rules[0].CostMultiply = "1";
            rules[0].StockMultiply = "1";
            rules[0].FilterOnCostPosNeg  = WFMPositiveNegative.Positive;

            rules.Add();
            rules[1].Code                = 1030;
            rules[1].Description         = "Test";
            rules[1].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[1].Kind                = "R"; // Receipt
            rules[1].AccountCode_Credit  = 230;
            rules[1].AccountCode_Debit   = 330;
            rules[1].CostFieldRequired   = true;
            rules[1].StockFieldSelector= "QtyRec";
            rules[1].CostMultiply = "1";
            rules[1].StockMultiply = "1";
            rules[1].FilterOnCostPosNeg  = WFMPositiveNegative.Negative;
            rules.Save();

            // Add test orderlog data
            int IDa = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET Cost=5.0 WHERE WOrderlogID=" + IDa.ToString());
            int IDc = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET Cost=-5.0 WHERE WOrderlogID=" + IDc.ToString());

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Orderlog));

            // Check correct rows added
            AssertCachedOrderlogRowDoNotExists(rules[0], IDa);
            AssertCachedOrderlogRowDoNotExists(rules[1], IDc);
        }


        [TestMethod]
        [Description("Test pWFMLogCachePopulate filters based on +ve or -ve stock")]
        public void TestFiletersByPositiveOrNegativeStockFromOrderlog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code                = 1010;
            rules[0].Description         = "Test";
            rules[0].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[0].Kind                = "R"; // Receipt
            rules[0].AccountCode_Credit  = 210;
            rules[0].AccountCode_Debit   = 310;
            rules[0].CostFieldRequired   = true; 
            rules[0].StockFieldSelector  = "QtyOrd";
            rules[0].CostMultiply = "1";
            rules[0].StockMultiply = "1";
            rules[0].FilterOnStockPosNeg = WFMPositiveNegative.Negative;

            rules.Add();
            rules[1].Code                = 1020;
            rules[1].Description         = "Test";
            rules[1].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[1].Kind                = "R"; // Receipt
            rules[1].AccountCode_Credit  = 220;
            rules[1].AccountCode_Debit   = 320;
            rules[1].CostFieldRequired   = true;
            rules[1].StockFieldSelector  = "QtyOrd";
            rules[1].CostMultiply = "1";
            rules[1].StockMultiply = "1";
            rules[1].FilterOnStockPosNeg = WFMPositiveNegative.Positive;
            rules.Save();

            // Add test orderlog data
            int IDa = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET QtyOrd=-5.0, CostExVat=0.0 WHERE WOrderlogID=" + IDa.ToString());
            int IDb = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET QtyOrd=5.0, CostExVat=0.0 WHERE WOrderlogID="  + IDb.ToString());

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Orderlog));

            // Check correct rows added
            AssertCachedOrderlogRowDoNotExists(rules[0], IDa);
            AssertCachedOrderlogRowDoNotExists(rules[1], IDb);
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate for WOrderlog cost field selection")]
        public void TestUpdatesOrderLogByCostFieldSelection()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code                = 1010;
            rules[0].Description         = "Test";
            rules[0].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[0].Kind                = "R"; // Receipt
            rules[0].AccountCode_Credit  = 210;
            rules[0].AccountCode_Debit   = 310;
            rules[0].CostFieldRequired   = true; 
            rules[0].StockFieldSelector= "QtyRec";
            rules[0].CostMultiply = "1";
            rules[0].StockMultiply = "1";

            rules.Add();
            rules[1].Code                = 1030;
            rules[1].Description         = "Test";
            rules[1].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[1].Kind                = "T"; // Invoice
            rules[1].AccountCode_Credit  = 220;
            rules[1].AccountCode_Debit   = 320;
            rules[1].CostFieldRequired   = false;
            rules[1].StockFieldSelector= "QtyRec";
            rules[1].CostMultiply = "1";
            rules[1].StockMultiply = "1";
            rules.Save();

            // Add test orderlog data
            int IDa = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET Cost=5.0, CostExVat=2.0, VatCost=3, ConvFact=10, QtyRec=1 WHERE WOrderlogID=" + IDa.ToString());
            int IDb = AddOrderlogRow(WOrderLogType.ReconciliationTransaction, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET Cost=8.0, CostExVat=4.0, VatCost=3, ConvFact=10, QtyRec=1 WHERE WOrderlogID=" + IDb.ToString());

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Orderlog));

            // Check correct values have been set WFMLogCachePopulate
            double costExVat  = Database.ExecuteSQLScalar<double>("SELECT CostExVat  FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDa);
            double costIncVat = Database.ExecuteSQLScalar<double>("SELECT CostIncVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDa);
            double vatCost    = Database.ExecuteSQLScalar<double>("SELECT VatCost    FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDa);
            Assert.AreEqual(costExVat,  2.0, "Has not selected cost ex vat");
            Assert.AreEqual(costIncVat, 5.0, "Has not selected cost ex vat");
            Assert.AreEqual(vatCost,    3.0, "Has not selected cost ex vat");
            double? costExVatNull  = Database.ExecuteSQLScalar<double?>("SELECT CostExVat  FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDb);
            double? costIncVatNull = Database.ExecuteSQLScalar<double?>("SELECT CostIncVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDb);
            double? vatCostNull    = Database.ExecuteSQLScalar<double?>("SELECT VatCost    FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDb);
            Assert.IsNull(costExVatNull,  "Cost field should not be set");
            Assert.IsNull(costIncVatNull, "Cost field should not be set");
            Assert.IsNull(vatCostNull,    "Cost field should not be set");
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate for WOrderlog stock field selection")]
        public void TestUpdatesOrderLogByStockFieldSelection()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code                = 1010;
            rules[0].Description         = "Test";
            rules[0].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[0].Kind                = "R"; // Receipt
            rules[0].AccountCode_Credit  = 210;
            rules[0].AccountCode_Debit   = 310;
            rules[0].CostFieldRequired   = true; 
            rules[0].StockFieldSelector  = "QtyRec";
            rules[0].CostMultiply = "1";
            rules[0].StockMultiply = "1";

            rules.Add();
            rules[1].Code                = 1020;
            rules[1].Description         = "Test";
            rules[1].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[1].Kind                = "E"; // Issue return
            rules[1].AccountCode_Credit  = 220;
            rules[1].AccountCode_Debit   = 320;
            rules[1].CostFieldRequired   = true;
            rules[1].StockFieldSelector  = "QtyOrd";
            rules[1].CostMultiply = "1";
            rules[1].StockMultiply = "1";

            rules.Add();
            rules[2].Code                = 1030;
            rules[2].Description         = "Test";
            rules[2].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[2].Kind                = "S"; // Stock Adjust
            rules[2].AccountCode_Credit  = 220;
            rules[2].AccountCode_Debit   = 320;
            rules[2].CostFieldRequired   = true;
            rules[2].StockFieldSelector  = null;
            rules[2].CostMultiply = "1";
            rules[2].StockMultiply = "1";
            rules.Save();

            // Add test orderlog data
            int IDa = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET QtyRec=5.0, QtyOrd=2.0, ConvFact=2 WHERE WOrderlogID=" + IDa.ToString());
            int IDb = AddOrderlogRow(WOrderLogType.IssuedReturn, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET QtyRec=5.0, QtyOrd=2.0, ConvFact=2 WHERE WOrderlogID=" + IDb.ToString());
            int IDc = AddOrderlogRow(WOrderLogType.AdjustStockLevel, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET QtyRec=5.0, QtyOrd=2.0, ConvFact=2 WHERE WOrderlogID=" + IDc.ToString());

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Orderlog));

            // Check correct values have been set WFMLogCachePopulate
            double qtyRec = Database.ExecuteSQLScalar<double>  ("SELECT Qty FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDa);
            Assert.AreEqual(5.0, qtyRec, "Has not selected QtyRec");
            double qtyOrd = Database.ExecuteSQLScalar<double>  ("SELECT Qty FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDb);
            Assert.AreEqual(2.0, qtyOrd, "Has not selected QtyOrd");
            double? qtynull= Database.ExecuteSQLScalar<double?>("SELECT Qty FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDc);
            Assert.IsNull(qtynull, "Has not set quantity to null");
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate can update form WOrderlog with multiplier")]
        public void TestCostAndStockMultiplierForOrderlog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code                = 1010;
            rules[0].Description         = "Test";
            rules[0].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[0].Kind                = "R"; // Receipt
            rules[0].AccountCode_Credit  = 210;
            rules[0].AccountCode_Debit   = 310;
            rules[0].CostFieldRequired   = true; 
            rules[0].StockFieldSelector= "QtyRec";
            rules[0].CostMultiply       = "QtyRec";
            rules[0].StockMultiply      = "ConvFact";
            rules.Save();

            // Setup rules
            rules.Add();
            rules[1].Code                = 1010;
            rules[1].Description         = "Test";
            rules[1].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[1].Kind                = "T"; // Invoice
            rules[1].AccountCode_Credit  = 210;
            rules[1].AccountCode_Debit   = 310;
            rules[1].CostFieldRequired   = true; 
            rules[1].StockFieldSelector= "QtyRec";
            rules[1].CostMultiply       = "-QtyRec";
            rules[1].StockMultiply      = "-ConvFact";
            rules.Save();

            // Setup rules
            rules.Add();
            rules[2].Code                = 1010;
            rules[2].Description         = "Test";
            rules[2].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[2].Kind                = "E"; 
            rules[2].AccountCode_Credit  = 210;
            rules[2].AccountCode_Debit   = 310;
            rules[2].CostFieldRequired   = true; 
            rules[2].StockFieldSelector= "QtyRec";
            rules[2].CostMultiply       = "QtyOrd";
            rules[2].StockMultiply      = "1";
            rules.Save();

            // Setup rules
            rules.Add();
            rules[3].Code                = 1010;
            rules[3].Description         = "Test";
            rules[3].PharmacyLog         = PharmacyLogType.Orderlog;
            rules[3].Kind                = "B";
            rules[3].AccountCode_Credit  = 210;
            rules[3].AccountCode_Debit   = 310;
            rules[3].CostFieldRequired   = true; 
            rules[3].StockFieldSelector= "QtyRec";
            rules[3].CostMultiply       = "-QtyOrd";
            rules[3].StockMultiply      = "-1";
            rules.Save();

            // Add test orderlog data
            int IDa = AddOrderlogRow(WOrderLogType.Receipt, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET Cost=6.0, CostExVat=5.0, QtyRec=2.0, ConvFact=10 WHERE WOrderlogID=" + IDa.ToString());
            int IDb = AddOrderlogRow(WOrderLogType.ReconciliationTransaction, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET Cost=6.0, CostExVat=5.0, QtyRec=2.0, ConvFact=10 WHERE WOrderlogID=" + IDb.ToString());
            int IDc = AddOrderlogRow(WOrderLogType.IssuedReturn, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET Cost=6.0, CostExVat=5.0, QtyRec=2.0, QtyOrd=3.0, ConvFact=10 WHERE WOrderlogID=" + IDc.ToString());
            int IDd = AddOrderlogRow(WOrderLogType.ReconciliationBalance, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WOrderlog SET Cost=6.0, CostExVat=5.0, QtyRec=2.0, QtyOrd=3.0, ConvFact=10 WHERE WOrderlogID=" + IDd.ToString());

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Orderlog));

            // Check correct values have been set WFMLogCachePopulate
            double costExVat = Database.ExecuteSQLScalar<double>("SELECT CostExVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDa);
            Assert.AreEqual(5.0 * 2,  costExVat, "Has not multiplied CostExVat");
            double cost = Database.ExecuteSQLScalar<double>("SELECT CostIncVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDa);
            Assert.AreEqual(6.0 * 2,  cost, "Has not multiplied Cost");
            double qty  = Database.ExecuteSQLScalar<double>("SELECT Qty  FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDa);
            Assert.AreEqual(2.0 * 10, qty,  "Has not multiplied Qty");

            costExVat = Database.ExecuteSQLScalar<double>("SELECT CostExVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDb);
            Assert.AreEqual(-5.0 * 2, costExVat, "Has not multiplied CostExVat");
            cost = Database.ExecuteSQLScalar<double>("SELECT CostIncVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDb);
            Assert.AreEqual(-6.0 * 2, cost, "Has not multiplied Cost");
            qty  = Database.ExecuteSQLScalar<double>("SELECT Qty  FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDb);
            Assert.AreEqual(-2.0 * 10, qty, "Has not multiplied Qty");

            costExVat = Database.ExecuteSQLScalar<double>("SELECT CostExVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDc);
            Assert.AreEqual(5.0 * 3, costExVat, "Has not multiplied CostExVat");
            cost = Database.ExecuteSQLScalar<double>("SELECT CostIncVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDc);
            Assert.AreEqual(6.0 * 3, cost, "Has not multiplied Cost");
            qty  = Database.ExecuteSQLScalar<double>("SELECT Qty  FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDc);
            Assert.AreEqual(2, qty, "Has not multiplied Qty");

            costExVat = Database.ExecuteSQLScalar<double>("SELECT CostExVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDd);
            Assert.AreEqual(-5.0 * 3, costExVat, "Has not multiplied CostExVat");
            cost = Database.ExecuteSQLScalar<double>("SELECT CostIncVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDd);
            Assert.AreEqual(-6.0 * 3, cost, "Has not multiplied Cost");
            qty  = Database.ExecuteSQLScalar<double>("SELECT Qty  FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='O'", IDd);
            Assert.AreEqual(-2, qty, "Has not multiplied Qty");
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate can update form WTranslog on a simple rule")]
        public void TestUpdatesFromTransLog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code        = 1010;
            rules[0].Description = "Test";
            rules[0].PharmacyLog = PharmacyLogType.Translog;
            rules[0].Kind        = "W"; // WardStock
            rules[0].AccountCode_Credit = 210;
            rules[0].AccountCode_Debit  = 310;
            rules[0].CostFieldRequired = true;
            rules[0].StockFieldSelector= "Qty";
            rules[0].CostMultiply        = "1";
            rules[0].StockMultiply       = "1";

            rules.Add();
            rules[1].Code        = 1012;
            rules[1].Description = "Test";
            rules[1].PharmacyLog = PharmacyLogType.Translog;
            rules[1].Kind        = "I"; // Inpatient
            rules[1].AccountCode_Credit = 211;
            rules[1].AccountCode_Debit  = 311;
            rules[1].CostFieldRequired = true;
            rules[1].StockFieldSelector= "Qty";
            rules[1].CostMultiply        = "1";
            rules[1].StockMultiply       = "1";
            rules.Save();

            // Add test translog data
            int IDa = AddTranslogRow(WTranslogType.WardStock, "A", SiteIDA, NSVCodeA, WardCodeA);

            int IDb = AddTranslogRow(WTranslogType.Inpatient, "D", SiteIDA, NSVCodeA, WardCodeA);
            int IDc = AddTranslogRow(WTranslogType.Inpatient, "D", SiteIDA, NSVCodeA, WardCodeA);

            // Add direct order code (does not have rule)
            int IDd = AddTranslogRow(WTranslogType.Outpatient, "D", SiteIDA, NSVCodeA, WardCodeA);

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Translog));

            // Check correct rows added
            AssertCachedTranslogRowDoNotExists(rules[0], IDa);
            AssertCachedTranslogRowDoNotExists(rules[1], IDb, IDc);
            AssertWFMLogCacheRowCountNotEqualTo(3);
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate can update WTranslog based on different LabelType, NSVCode, and Ward code")]
        public void TestUpdatesTransLogFileterdByLabelTypeNSVCodeWardCode()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code        = 1010;
            rules[0].Description = "Test";
            rules[0].PharmacyLog = PharmacyLogType.Translog;
            rules[0].Kind        = "W"; // WardStock
            rules[0].LabelType   = "Z";
            rules[0].NSVCode     = NSVCodeA;
            rules[0].WardCode    = WardCodeA;
            rules[0].AccountCode_Credit = 210;
            rules[0].AccountCode_Debit  = 310;
            rules[0].CostFieldRequired = true;
            rules[0].StockFieldSelector= "Qty";
            rules[0].CostMultiply        = "1";
            rules[0].StockMultiply       = "1";
            rules.Save();

            // Add test translog data

            // Add dummy data
            int IDa = AddTranslogRow(WTranslogType.WardStock, "Z", SiteIDA, NSVCodeA, "WARD"    );
            int IDb = AddTranslogRow(WTranslogType.WardStock, "Z", SiteIDA, "NSVCODE", WardCodeA);
            int IDc = AddTranslogRow(WTranslogType.WardStock, "A", SiteIDA, NSVCodeA,  WardCodeA);

            // Actual rows with rules
            int IDd = AddTranslogRow(WTranslogType.WardStock, "Z", SiteIDA, NSVCodeA, WardCodeA);
            int IDe = AddTranslogRow(WTranslogType.WardStock, "Z", SiteIDB, NSVCodeA, WardCodeA);

            // Add dummy data
            int IDf = AddTranslogRow(WTranslogType.Inpatient, "Z", SiteIDA, NSVCodeA, WardCodeA);

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Translog));

            // Check correct rows added
            AssertCachedTranslogRowDoNotExists(rules[0], IDd, IDe);
            AssertWFMLogCacheRowCountNotEqualTo(2);
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate does not use rules marked as deleted")]
        public void TestIgnoresDeleteRuleForTransLog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code        = 1010;
            rules[0].Description = "Test";
            rules[0].PharmacyLog = PharmacyLogType.Translog;
            rules[0].Kind        = "W"; // WardStock
            rules[0].AccountCode_Credit = 210;
            rules[0].AccountCode_Debit  = 310;
            rules[0].CostFieldRequired = true;
            rules[0].StockFieldSelector= "Qty";
            rules[0].CostMultiply        = "1";
            rules[0].StockMultiply       = "1";

            rules.Add();
            rules[1].Code        = 1012;
            rules[1].Description = "Test";
            rules[1].PharmacyLog = PharmacyLogType.Translog;
            rules[1].Kind        = "I"; // Inpatient
            rules[1].AccountCode_Credit = 211;
            rules[1].AccountCode_Debit  = 311;
            rules[1].RawRow["_Deleted"] = true;
            rules[1].CostFieldRequired = true;
            rules[1].StockFieldSelector= "Qty";
            rules[1].CostMultiply        = "1";
            rules[1].StockMultiply       = "1";
            rules.Save();

            // Add test translog data
            int IDa = AddTranslogRow(WTranslogType.WardStock, "A", SiteIDA, NSVCodeA, WardCodeA);

            int IDb = AddTranslogRow(WTranslogType.Inpatient, "D", SiteIDA, NSVCodeA, WardCodeA);
            int IDc = AddTranslogRow(WTranslogType.Inpatient, "D", SiteIDA, NSVCodeA, WardCodeA);

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Translog));

            // Check correct rows added
            AssertCachedTranslogRowDoNotExists(rules[0], IDa);
            AssertWFMLogCacheRowCountNotEqualTo(1);
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate runs rules in correct order NSVCode, WardCode, LabelType for WTranslog")]
        public void TestRulesRunInCorrectOrderForWTranslog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code        = 1001;
            rules[0].Description = "Test";
            rules[0].PharmacyLog = PharmacyLogType.Translog;
            rules[0].Kind        = "W"; // WardStock
            rules[0].LabelType   = "K";
            rules[0].WardCode    = WardCodeA;
            rules[0].NSVCode     = NSVCodeA;
            rules[0].AccountCode_Credit = 111;
            rules[0].AccountCode_Debit  = 110;
            rules[0].CostFieldRequired = true;
            rules[0].StockFieldSelector= "Qty";
            rules[0].CostMultiply        = "1";
            rules[0].StockMultiply       = "1";

            rules.Add();    // Rule should not run as next rule added will replace it
            rules[1].Code        = 1002;
            rules[1].Description = "Test";
            rules[1].PharmacyLog = PharmacyLogType.Translog;
            rules[1].Kind        = "W"; // WardStock
            rules[1].LabelType   = "K";
            rules[1].WardCode    = WardCodeA;
            rules[1].AccountCode_Credit = 333;
            rules[1].AccountCode_Debit  = 330;
            rules[1].CostFieldRequired = true;
            rules[1].StockFieldSelector= "Qty";
            rules[1].CostMultiply        = "1";
            rules[1].StockMultiply       = "1";

            rules.Add();
            rules[2].Code        = 1003;
            rules[2].Description = "Test";
            rules[2].PharmacyLog = PharmacyLogType.Translog;
            rules[2].Kind        = "W"; // WardStock
            rules[2].LabelType   = "K";
            rules[2].AccountCode_Credit = 222;
            rules[2].AccountCode_Debit  = 220;
            rules[2].CostFieldRequired = true;
            rules[2].StockFieldSelector= "Qty";
            rules[2].CostMultiply        = "1";
            rules[2].StockMultiply       = "1";

            rules.Add();
            rules[3].Code        = 1004;
            rules[3].Description = "Test";
            rules[3].PharmacyLog = PharmacyLogType.Translog;
            rules[3].Kind        = "W"; // WardStock
            rules[3].AccountCode_Credit = 444;
            rules[3].AccountCode_Debit  = 440;
            rules[3].CostFieldRequired = true;
            rules[3].StockFieldSelector= "Qty";
            rules[3].CostMultiply        = "1";
            rules[3].StockMultiply       = "1";
            rules.Save();

            // Add test translog data
            int IDa = AddTranslogRow(WTranslogType.WardStock, "K", SiteIDA, NSVCodeA,   WardCodeA);    // 1st Rule
            int IDb = AddTranslogRow(WTranslogType.WardStock, "K", SiteIDA, "NSVCODE",  WardCodeA);    // 2nd Rule
            int IDc = AddTranslogRow(WTranslogType.WardStock, "K", SiteIDA, "NSVCODE",  "Ward");  // 3rd Rule  
            int IDd = AddTranslogRow(WTranslogType.WardStock, "A", SiteIDA, "NSVCODE",  "Ward");  // 4th Rule
            int IDe = AddTranslogRow(WTranslogType.WardStock, "K", SiteIDA, NSVCodeA,   WardCodeA);    // 1st Rule

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate '{0}'", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Translog));

            // Check correct rows added
            AssertCachedTranslogRowDoNotExists(rules[0], IDa, IDe);
            AssertCachedTranslogRowDoNotExists(rules[1], IDb);
            AssertCachedTranslogRowDoNotExists(rules[2], IDc);
            AssertCachedTranslogRowDoNotExists(rules[3], IDd);
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate filters based on +ve or -ve cost")]
        public void TestFiletersByPositiveOrNegativeCostFromTranslog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code                = 1010;
            rules[0].Description         = "Test";
            rules[0].PharmacyLog         = PharmacyLogType.Translog;
            rules[0].Kind                = "I";
            rules[0].AccountCode_Credit  = 210;
            rules[0].AccountCode_Debit   = 310;
            rules[0].CostFieldRequired   = true; 
            rules[0].StockFieldSelector  = "Qty";
            rules[0].CostMultiply        = "1";
            rules[0].StockMultiply       = "1";
            rules[0].FilterOnCostPosNeg  = WFMPositiveNegative.Positive;

            rules.Add();
            rules[1].Code                = 1030;
            rules[1].Description         = "Test";
            rules[1].PharmacyLog         = PharmacyLogType.Translog;
            rules[1].Kind                = "I";
            rules[1].AccountCode_Credit  = 230;
            rules[1].AccountCode_Debit   = 330;
            rules[1].CostFieldRequired   = true;
            rules[1].StockFieldSelector  = "Qty";
            rules[1].CostMultiply        = "1";
            rules[1].StockMultiply       = "1";
            rules[1].FilterOnCostPosNeg  = WFMPositiveNegative.Negative;
            rules.Save();

            // Add test orderlog data
            int IDa = AddTranslogRow(WTranslogType.Inpatient, string.Empty, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET Cost=5.0 WHERE WTranslogID=" + IDa.ToString());
            int IDb = AddTranslogRow(WTranslogType.Inpatient, string.Empty, SiteIDA, NSVCodeA, SupCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET Cost=-5.0 WHERE WTranslogID=" + IDb.ToString());

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Translog));

            // Check correct rows added to WFMOrderlog
            AssertCachedTranslogRowDoNotExists(rules[0], IDa);
            AssertCachedTranslogRowDoNotExists(rules[1], IDb);
        }


        [TestMethod]
        [Description("Test pWFMLogCachePopulate filters based on +ve or -ve stock from WTranlogs")]
        public void TestFiletersByPositiveOrNegativeStockFromTranslog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code                = 1010;
            rules[0].Description         = "Test";
            rules[0].PharmacyLog         = PharmacyLogType.Translog;
            rules[0].Kind                = "I"; // In-Patient
            rules[0].AccountCode_Credit  = 210;
            rules[0].AccountCode_Debit   = 310;
            rules[0].CostFieldRequired   = true; 
            rules[0].StockFieldSelector  = "Qty";
            rules[0].CostMultiply        = "1";
            rules[0].StockMultiply       = "1";
            rules[0].FilterOnStockPosNeg = WFMPositiveNegative.Positive;

            rules.Add();
            rules[1].Code                = 1030;
            rules[1].Description         = "Test";
            rules[1].PharmacyLog         = PharmacyLogType.Translog;
            rules[1].Kind                = "I"; // In-Patient
            rules[1].AccountCode_Credit  = 230;
            rules[1].AccountCode_Debit   = 330;
            rules[1].CostFieldRequired   = true;
            rules[1].StockFieldSelector  = "Qty";
            rules[1].CostMultiply        = "1";
            rules[1].StockMultiply       = "1";
            rules[1].FilterOnStockPosNeg = WFMPositiveNegative.Negative;

            rules.Save();

            // Add test orderlog data
            int IDa = AddTranslogRow(WTranslogType.Inpatient, string.Empty, SiteIDA, NSVCodeA, WardCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET Qty=5.0 WHERE WTranslogID=" + IDa.ToString());
            int IDb = AddTranslogRow(WTranslogType.Inpatient, string.Empty, SiteIDA, NSVCodeA, WardCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET Qty=5.0 WHERE WTranslogID="  + IDb.ToString());
            int IDc = AddTranslogRow(WTranslogType.Inpatient, string.Empty, SiteIDA, NSVCodeA, WardCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET Qty=-5.0 WHERE WTranslogID=" + IDc.ToString());
            int IDd = AddTranslogRow(WTranslogType.Inpatient, string.Empty, SiteIDA, NSVCodeA, WardCodeA);
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET Qty=-5.0 WHERE WTranslogID="  + IDd.ToString());

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Translog));

            // Check correct rows added
            AssertCachedTranslogRowDoNotExists(rules[0], IDa, IDb);
            AssertCachedTranslogRowDoNotExists(rules[1], IDc, IDd);
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate for WTranslog cost field selection")]
        public void TestUpdatesTransLogByCostFieldSelection()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code                = 1010;
            rules[0].Description         = "Test";
            rules[0].PharmacyLog         = PharmacyLogType.Translog;
            rules[0].Kind                = "I";
            rules[0].AccountCode_Credit  = 210;
            rules[0].AccountCode_Debit   = 310;
            rules[0].CostFieldRequired   = true; 
            rules[0].StockFieldSelector  = "Qty";
            rules[0].CostMultiply        = "1";
            rules[0].StockMultiply       = "1";

            rules.Add();
            rules[1].Code                = 1020;
            rules[1].Description         = "Test";
            rules[1].PharmacyLog         = PharmacyLogType.Translog;
            rules[1].Kind                = "D";
            rules[1].AccountCode_Credit  = 220;
            rules[1].AccountCode_Debit   = 320;
            rules[1].CostFieldRequired   = false;
            rules[1].StockFieldSelector  = "Qty";
            rules[1].CostMultiply        = "1";
            rules[1].StockMultiply       = "1";
            rules.Save();

            // Add test translog data
            int IDa = AddTranslogRow(WTranslogType.Inpatient, string.Empty, SiteIDA, NSVCodeA, string.Empty);
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET Cost=5.0, CostExTax=2.0, TaxCost=3, ConvFact=10 WHERE WTranslogID=" + IDa.ToString());
            int IDb = AddTranslogRow(WTranslogType.Discharge, string.Empty, SiteIDA, NSVCodeA, string.Empty);
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET Cost=5.0, CostExTax=2.0, TaxCost=3, ConvFact=10 WHERE WTranslogID=" + IDb.ToString());

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Translog));

            // Check correct values have been set WFMLogCachePopulate
            double costExVat  = Database.ExecuteSQLScalar<double>("SELECT CostExVat  FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDa);
            double costIncVat = Database.ExecuteSQLScalar<double>("SELECT CostIncVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDa);
            double vatCost    = Database.ExecuteSQLScalar<double>("SELECT VatCost    FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDa);
            Assert.AreEqual(costIncVat, 5.0, "Has not updated correct cost");
            Assert.AreEqual(costExVat,  2.0, "Has not updated correct cost");
            Assert.AreEqual(vatCost,    3.0, "Has not updated correct cost");
            double? costExVatNull  = Database.ExecuteSQLScalar<double?>("SELECT CostExVat  FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDb);
            double? costIncVatNull = Database.ExecuteSQLScalar<double?>("SELECT CostIncVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDb);
            double? vatCostNull    = Database.ExecuteSQLScalar<double?>("SELECT VatCost    FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDb);
            Assert.IsNull(costExVatNull,  "Has not set cost to null");
            Assert.IsNull(costIncVatNull, "Has not set cost to null");
            Assert.IsNull(vatCostNull,    "Has not set cost to null");
        }

        [TestMethod]
        [Description("Test pWFMLogCachePopulate can update form WTranslog with multiplier")]
        public void TestCostAndStockMultiplierForTranslog()
        {
            // Setup rules
            WFMRule rules = new WFMRule();
            rules.Add();
            rules[0].Code                = 1010;
            rules[0].Description         = "Test";
            rules[0].PharmacyLog         = PharmacyLogType.Translog;
            rules[0].Kind                = "I";
            rules[0].AccountCode_Credit  = 210;
            rules[0].AccountCode_Debit   = 310;
            rules[0].CostFieldRequired   = true; 
            rules[0].StockFieldSelector  = "Qty";
            rules[0].CostMultiply        = "Qty";
            rules[0].StockMultiply       = "ConvFact";
            rules.Save();

            rules.Add();
            rules[1].Code                = 1010;
            rules[1].Description         = "Test";
            rules[1].PharmacyLog         = PharmacyLogType.Translog;
            rules[1].Kind                = "O";
            rules[1].AccountCode_Credit  = 210;
            rules[1].AccountCode_Debit   = 310;
            rules[1].CostFieldRequired   = true; 
            rules[1].StockFieldSelector  = "Qty";
            rules[1].CostMultiply        = "-Qty";
            rules[1].StockMultiply       = "-ConvFact";
            rules.Save();

            rules.Add();
            rules[2].Code                = 1010;
            rules[2].Description         = "Test";
            rules[2].PharmacyLog         = PharmacyLogType.Translog;
            rules[2].Kind                = "D";
            rules[2].AccountCode_Credit  = 210;
            rules[2].AccountCode_Debit   = 310;
            rules[2].CostFieldRequired   = true; 
            rules[2].StockFieldSelector  = "Qty";
            rules[2].CostMultiply        = "-1";
            rules[2].StockMultiply       = "-1";
            rules.Save();

            // Add test Translog data
            int IDa = AddTranslogRow(WTranslogType.Inpatient, string.Empty, SiteIDA, NSVCodeA, string.Empty);
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET Cost=2.0, CostExTax=5.0, Qty=2.0, ConvFact=10 WHERE WTranslogID=" + IDa.ToString());
            int IDb = AddTranslogRow(WTranslogType.Outpatient, string.Empty, SiteIDA, NSVCodeA, string.Empty);
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET Cost=2.0, CostExTax=5.0, Qty=2.0, ConvFact=10 WHERE WTranslogID=" + IDb.ToString());
            int IDc = AddTranslogRow(WTranslogType.Discharge, string.Empty, SiteIDA, NSVCodeA, string.Empty);
            Database.ExecuteSQLNonQuery("UPDATE WTranslog SET Cost=2.0, CostExTax=5.0, Qty=2.0, ConvFact=10 WHERE WTranslogID=" + IDc.ToString());

            // Run test
            Database.ExecuteSQLNonQuery("Exec pWFMLogCachePopulate {0}", EnumDBCodeAttribute.EnumToDBCode(PharmacyLogType.Translog));

            // Check correct values have been set WFMLogCachePopulate
            double costExVat = Database.ExecuteSQLScalar<double>("SELECT CostExVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDa);
            Assert.AreEqual(costExVat, 10.0,  "Has not multiplied CostExVat");
            double cost = Database.ExecuteSQLScalar<double>("SELECT CostIncVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDa);
            Assert.AreEqual(cost, 4.0, "Has not multiplied Cost");
            double qty  = Database.ExecuteSQLScalar<double>("SELECT Qty  FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDa);
            Assert.AreEqual(qty,  20.0, "Has not multiplied Qty");

            costExVat = Database.ExecuteSQLScalar<double>("SELECT CostExVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDb);
            Assert.AreEqual(costExVat, -10.0,  "Has not multiplied CostExVat");
            cost = Database.ExecuteSQLScalar<double>("SELECT CostIncVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDb);
            Assert.AreEqual(cost, -4.0, "Has not multiplied Cost");
            qty  = Database.ExecuteSQLScalar<double>("SELECT Qty  FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDb);
            Assert.AreEqual(qty,  -20.0, "Has not multiplied Qty");

            costExVat = Database.ExecuteSQLScalar<double>("SELECT CostExVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDc);
            Assert.AreEqual(costExVat, -5.0,  "Has not multiplied CostExVat");
            cost = Database.ExecuteSQLScalar<double>("SELECT CostIncVat FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDc);
            Assert.AreEqual(cost, -2.0, "Has not multiplied Cost");
            qty  = Database.ExecuteSQLScalar<double>("SELECT Qty  FROM WFMLogCache WHERE WLogID={0} AND PharmacyLog='T'", IDc);
            Assert.AreEqual(qty,  -2.0, "Has not multiplied Qty");
        }

        /// <summary>Checks that all the expected WOrderlog id have been added to the WFMLogCache by the specified rule</summary>
        private void AssertCachedOrderlogRowDoNotExists(WFMRuleRow rule, params int[] expectedOrderLogIds)
        {
            // Get all the orderlog id added to WFMLogCache by the rule
            IEnumerable<int> actualOrderLogIds = Database.ExecuteSQLSingleField<int>("SELECT WLogID FROM WFMLogCache WHERE PharmacyLog='O' AND RuleCode='{0}' AND AccountCode_Debit='{1}' AND AccountCode_Credit='{2}'", 
                                                                                      rule.Code, 
                                                                                      rule.AccountCode_Debit, 
                                                                                      rule.AccountCode_Credit);

            // Check that WFMLogCache has correct number of rows for the rule
            Assert.AreEqual(expectedOrderLogIds.Count(), actualOrderLogIds.Count(), string.Format("Expected {0} WFMLogCache rows but actually have {1}", expectedOrderLogIds.Count(), actualOrderLogIds.Count()));

            // Check that WFMLogCache links to correct Worderlog row
            IEnumerable<int> missingIds = expectedOrderLogIds.Where(e => !actualOrderLogIds.Contains(e));
            foreach (int missingID in missingIds)
                Assert.Fail(string.Format("Expected log ID {0} missing from list", missingID));
        }

        /// <summary>Checks that all the expected WTranslog id have been added to the WFMLogCache by the specified rule</summary>
        private void AssertCachedTranslogRowDoNotExists(WFMRuleRow rule, params int[] expectedTransLogIds)
        {
            // Get all the orderlog id added to WFMLogCache by the rule
            IEnumerable<int> actualTransLogIds = Database.ExecuteSQLSingleField<int>("SELECT WLogID FROM WFMLogCache WHERE PharmacyLog='T' AND RuleCode='{0}' AND AccountCode_Debit='{1}' AND AccountCode_Credit='{2}'", 
                                                                                      rule.Code, 
                                                                                      rule.AccountCode_Debit, 
                                                                                      rule.AccountCode_Credit);

            // Check that WFMLogCache has correct number of rows for the rule
            Assert.AreEqual(expectedTransLogIds.Count(), actualTransLogIds.Count(), string.Format("Expected {0} WFMLogCache rows but actually have {1}", expectedTransLogIds.Count(), actualTransLogIds.Count()));

            // Check that WFMLogCache links to correct WTranslog row
            IEnumerable<int> missingIds = expectedTransLogIds.Where(e => !actualTransLogIds.Contains(e));
            foreach (int missingID in missingIds)
                Assert.Fail(string.Format("Expected log ID {0} missing from list", missingID));
        }

        /// <summary>
        /// Checks that WFMLogCache contains the expected number of rows
        /// (normally there is 1 more row added by MyTestInitialze this will be ignored from the count)
        /// </summary>
        private void AssertWFMLogCacheRowCountNotEqualTo(int expectedCount)
        {
            int actualCount = Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM WFMLogCache WHERE RuleCode<>'0000'");    // RuleCode 0000 is a dummy one add in at start of all tests
            Assert.AreEqual(expectedCount, actualCount);
        }

        /// <summary>Adds a row to WOrderlog</summary>
        /// <returns>Newly add orderlog ID</returns>
        public int AddOrderlogRow(WOrderLogType kind, int siteID, string NSVCode, string supCode)
        {
            WOrderlog orderlog = new WOrderlog();
            WOrderlogRow orderlogRow = orderlog.Add();
            orderlogRow.Kind             = kind;
            orderlogRow.OrderNumber      = OrderNumber;
            orderlogRow.NSVCode          = NSVCode;
            //orderlogRow.ConversionFactor = 10;
            //orderlogRow.IssueUnits       = "amp";
            //orderlogRow.DateTimeOrd      = DateTime.Now.AddDays(-5).ToStartOfDay();
            //orderlogRow.DateTimeRec      = DateTime.Now.ToStartOfDay();
            //orderlogRow.QuantityOrdered  = 5; 
            //orderlogRow.QuantityReceived = 2;
            //orderlogRow.VatRate          = 1.175M;
            //orderlogRow.VatCode          = 1;
            orderlogRow.SupplierCode     = supCode;
            orderlogRow.SiteID           = siteID;
            orderlogRow.SiteNumber       = 0;
            //orderlogRow.StockLevel       = 50;
            //orderlogRow.StockValue       = 1.51;
            //orderlogRow.DateOrdered      = DateTime.Now.AddDays(-5).ToStartOfDay();
            //orderlogRow.DateReceived     = DateTime.Now.ToStartOfDay();
            //orderlogRow.CostIncVat       = 1.22M;
            //orderlogRow.CostExVat        = 1.02M;
            //orderlogRow.VatCost          = 0.2M;
            orderlog.Save();

            return orderlogRow.WOrderLogID;
        }

        /// <summary>Adds a row to WTranslog</summary>
        /// <returns>Newly add translog ID</returns>
        public int AddTranslogRow(WTranslogType kind, string labelType, int siteID, string NSVCode, string wardCode)
        {
            WTranslog translog = new WTranslog();
            WTranslogRow translogRow = translog.Add();
            translogRow.Kind             = kind;
            translogRow.RawRow["LabelType"]= labelType;
            translogRow.SiteID           = siteID;
            translogRow.SiteNumber       = 0;
            translogRow.NSVCode          = NSVCode;
            translogRow.WardCode         = wardCode;
            translogRow.EpisodeID        = 0;
            translog.Save();

            return translogRow.WTranslogID;
        }
    }
}
