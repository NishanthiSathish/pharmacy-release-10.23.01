using ascribe.pharmacy.pharmacydatalayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.basedatalayer;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.shared;

namespace UT_Pharmacy_Data_Layer
{
    
    
    /// <summary>
    ///This is a test class for WOrderTest and is intended
    ///to contain all WOrderTest Unit Tests
    ///</summary>
    [TestClass()]
    public class WOrderTest
    {
        private static int SessionID;            // both relate to rows in the session table

        private const int OrderNum = 59;

        private const int SiteIDA = 15;

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
        //You can use the following additional attributes as you write your tests:
        //
        //Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext)
        {
            Configuration conf = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            ConnectionStringsSection connectionStrSect = conf.ConnectionStrings;

            string connectionStr = connectionStrSect.ConnectionStrings["TRNRTL10.My.MySettings.ConnectionString"].ConnectionString;

            // Get sesssion ID (any will do)
            SessionID = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC");

            // Ensure settings are all okay
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("DateToSet", DateTime.Now));
            parameters.Add(new SqlParameter("SessionID", SessionID));
            Database.ExecuteSQLNonQuery("UPDATE Session SET Disconnected=0, DateCreated=@DateToSet, DateLastUsed=@DateToSet WHERE SessionID=@SessionID", parameters);
        }
        
        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}
        //
        //Use TestInitialize to run code before running each test
        [TestInitialize()]
        public void MyTestInitialize()
        {
            PrivateType type = new PrivateType(typeof(PharmacyDataCache));
            type.InvokeStatic("ClearCaches");

            // Initalise the SessionInfo class
            SessionInfo.InitialiseSessionAndSiteID(SessionID, SiteIDA);
        }
        
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion

        [TestMethod]
        [Description("Test updating a worder (without lock).")]
        public void UpdateWOrderWithoutLock()
        {
            WOrderColumnInfo columnInfo = WOrder.GetColumnInfo();

            WOrder orders = new WOrder();
            orders.LoadBySiteAndOrderNumber(SiteIDA, OrderNum, true);
            
            orders[0].ConversionFactor      = Utils.RndNum<decimal>(0, 100);
            orders[0].CostExVatPerPack      = Utils.RndNum<decimal>(-50, 50);
            orders[0].CreatedUser           = Utils.RndStr(columnInfo.CreatedUserLength);
            orders[0].CustOrdNo             = Utils.RndStr(columnInfo.tableInfo.FindByName("CustOrdNo").Length);
            orders[0].DateTimeOrdered       = Utils.RndDateTime();
            orders[0].DateTimeReceived      = Utils.RndDateTime();
            //orders[0].DeliveryNoteReference = Utils.RndStr(columnInfo.DeliveryNoteReferenceLength);
            orders[0].Description           = Utils.RndStr(columnInfo.tableInfo.FindByName("Description").Length);
            orders[0].InDispute             = Utils.RndBool();
            orders[0].InDisputeUser         = Utils.RndStr(columnInfo.tableInfo.FindByName("InDisputeUser").Length);
            orders[0].InternalMethod        = Utils.RndEnum<OrderInternalMethodType>();
            orders[0].InternalSiteNo        = Utils.RndStr(columnInfo.tableInfo.FindByName("InternalSiteNo").Length);
            orders[0].InvoiceDate           = Utils.RndDateTime();
            orders[0].InvoiceNumber         = Utils.RndStr(columnInfo.tableInfo.FindByName("InvNum").Length);
            orders[0].IssueUnits            = Utils.RndStr(columnInfo.tableInfo.FindByName("IssueUnits").Length);
            orders[0].Location              = Utils.RndStr(columnInfo.tableInfo.FindByName("LocCode").Length);
            orders[0].NumPrefix             = Utils.RndStr(columnInfo.tableInfo.FindByName("NumPrefix").Length);
            orders[0].OutstandingInPacks    = Utils.RndNum<decimal>(0, 99);
            orders[0].PFlag                 = Utils.RndStr(columnInfo.tableInfo.FindByName("PFlag").Length);
            orders[0].PickNumber            = Utils.RndNum<int>(0, 999);
            orders[0].QuantityOrderedInPacks= Utils.RndNum<decimal>(0, 99);
            orders[0].ReceivedInPacks       = Utils.RndNum<decimal>(0, 99);
            orders[0].ShelfPrinted          = Utils.RndStr(columnInfo.tableInfo.FindByName("ShelfPrinted").Length);
            orders[0].Status                = Utils.RndEnum<OrderStatusType>();
            orders[0].Stocked               = Utils.RndStr(columnInfo.tableInfo.FindByName("Stocked").Length);
            orders[0].SupplierType          = Utils.RndEnum<SupplierType>();
            orders[0].ToFollow              = Utils.RndStr(columnInfo.tableInfo.FindByName("ToFollow").Length);
            orders[0].Urgency               = Utils.RndEnum<OrderUrgencyType>();
            orders[0].VATAmount             = Utils.RndNum<decimal>(0, 99);
            orders[0].VATCode               = Utils.RndNum<int>(0, 9);
            orders[0].VATInclusive          = Utils.RndStr(columnInfo.tableInfo.FindByName("VatInclusive").Length);
            orders[0].VATRatePct            = Utils.RndStr(columnInfo.tableInfo.FindByName("VATRatePct").Length);
            orders.Save();

            WOrder ordersNew = new WOrder();
            ordersNew.LoadBySiteAndOrderNumber(SiteIDA, OrderNum, true);

            Utils.AssertAreEqual(orders[0], ordersNew[0]);
        }

        [TestMethod]
        [Description("Test updating a worder with null values.")]
        public void UpdateWOrderWithNulls()
        {
            WOrder orders = new WOrder();
            orders.LoadBySiteAndOrderNumber(SiteIDA, OrderNum, true);
            
            orders[0].ConversionFactor      = null;
            orders[0].CostExVatPerPack      = null;
            orders[0].CreatedUser           = null;
            orders[0].CustOrdNo             = null;
            orders[0].DateTimeOrdered       = null;
            orders[0].DateTimeReceived      = null;
            orders[0].DeliveryNoteReference = null;
            orders[0].Description           = null;
            orders[0].InDispute             = null;
            orders[0].InDisputeUser         = null;
            orders[0].InternalSiteNo        = null;
            orders[0].InvoiceDate           = null;
            orders[0].InvoiceNumber         = null;
            orders[0].IssueUnits            = null;
            orders[0].Location              = null;
            orders[0].NumPrefix             = null;
            orders[0].OutstandingInPacks    = null;
            orders[0].PFlag                 = null;
            orders[0].QuantityOrderedInPacks= null;
            orders[0].ReceivedInPacks       = null;
            orders[0].ShelfPrinted          = null;
            orders[0].Stocked               = null;
            orders[0].ToFollow              = null;
            orders[0].VATAmount             = null;
            orders[0].VATCode               = null;
            orders[0].VATInclusive          = null;
            orders[0].VATRatePct            = null;
            orders.Save();

            WOrder ordersNew = new WOrder();
            ordersNew.LoadBySiteAndOrderNumber(SiteIDA, OrderNum, true);

            Utils.AssertAreEqual(orders[0], ordersNew[0]);
        }

        [TestMethod]
        [Description("Test updating a worder (with lock).")]
        public void UpdateWOrderWithLock()
        {
            Random rnd = new Random();
            decimal nextVal = (decimal)Math.Round((rnd.NextDouble() - 0.5) * 100, 3);

            WOrder orders = new WOrder();
            orders.RowLockingOption = LockingOption.HardLock;
            orders.LoadBySiteAndOrderNumber(SiteIDA, OrderNum, false);
            
            orders[0].CostExVatPerPack  += nextVal;
            orders.Save();

            WOrder ordersNew = new WOrder();
            ordersNew.LoadBySiteAndOrderNumber(SiteIDA, OrderNum, false);

            Utils.AssertAreEqual(orders[0], ordersNew[0]);
        }
    }
}
