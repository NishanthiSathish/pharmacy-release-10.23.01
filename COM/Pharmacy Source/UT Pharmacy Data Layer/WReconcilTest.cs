using ascribe.pharmacy.pharmacydatalayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.basedatalayer;
using System.Data;
using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Collections.Generic;
using ascribe.pharmacy.shared;

namespace UT_Pharmacy_Data_Layer
{
    
    
    /// <summary>
    ///This is a test class for WReconcilTest and is intended
    ///to contain all WReconcilTest Unit Tests
    ///</summary>
    [TestClass()]
    public class WReconcilTest
    {
        private static int SessionID;            // both relate to rows in the session table

        private const int OrderNum = 59;
        private const int WReconcilID = 121;

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
        [Description("Test inserting a WReconcil using same settings a used in Receipt.")]
        public void InsertWReconcil()
        {
            WOrder orders = new WOrder();
            orders.LoadBySiteAndOrderNumber(SiteIDA, OrderNum, false);
            WOrderRow orderRow = orders[0];

            int initialWReconcilCount = Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM WReconcil");

            WReconcil reconcil = new WReconcil();
            WReconcilRow reconcilRow = reconcil.Add();
            reconcilRow.NumPrefix               = orderRow.NumPrefix;
            reconcilRow.ToFollow                = orderRow.ToFollow;
            reconcilRow.Urgency                 = orderRow.Urgency;
            reconcilRow.IssueUnits              = orderRow.IssueUnits;
            reconcilRow.Stocked                 = orderRow.Stocked;
            reconcilRow.Description             = orderRow.Description;
            reconcilRow.CustOrdNo               = orderRow.CustOrdNo;
            reconcilRow.SupplierType            = orderRow.SupplierType;
            reconcilRow.ConversionFactor        = orderRow.ConversionFactor;
            reconcilRow.NSVCode                 = orderRow.NSVCode;
            reconcilRow.Status                  = OrderStatusType.Received;
            reconcilRow.OrderNumber             = orderRow.OrderNumber;
            reconcilRow.SiteID                  = orderRow.SiteID;
            reconcilRow.DateTimeOrdered         = orderRow.DateTimeOrdered;
            reconcilRow.DateTimeReceived        = DateTime.Now;
            reconcilRow.Location                = string.Empty;
            reconcilRow.SupplierCode            = orderRow.SupplierCode;
            reconcilRow.PickNumber              = orderRow.PickNumber;
            reconcilRow.InternalMethod          = orderRow.InternalMethod;
            reconcilRow.PFlag                   = orderRow.PFlag;
            reconcilRow.VATAmount               = orderRow.VATAmount;
            reconcilRow.VATRatePct              = orderRow.VATRatePct;
            reconcilRow.VATInclusive            = orderRow.VATInclusive;
            reconcilRow.VATCode                 = orderRow.VATCode;
            reconcilRow.QuantityOrderedInPacks  = orderRow.QuantityOrderedInPacks;
            reconcilRow.InternalSiteNo          = orderRow.InternalSiteNo;
            reconcilRow.ShelfPrinted            = orderRow.ShelfPrinted;
            reconcilRow.CostExVatPerPack        = orderRow.CostExVatPerPack ?? 0;
            reconcil.Save();

            WReconcil reconcilNew = new WReconcil();
            reconcilNew.LoadByID(reconcilRow.WReconcilID);

            int newWReconcilCount = Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM WReconcil");

            Database.ExecuteSQLNonQuery("DELETE FROM WReconcil WHERE WReconcilID={0}", reconcilRow.WReconcilID);

            Assert.AreEqual(initialWReconcilCount + 1, newWReconcilCount, "Insert has not added row to WReconil table");
            Utils.AssertAreEqual(reconcil[0], reconcilNew[0]);
        }

        [TestMethod]
        [Description("Test updating a WReconcil (without lock).")]
        public void UpdateWReconcilWithoutLock()
        {
            var columnInfo = WReconcil.GetColumnInfo();

            WReconcil reconcil = new WReconcil();
            reconcil.LoadByID(WReconcilID);
            
            reconcil[0].ConversionFactor      = Utils.RndNum<decimal>(0, 100);
            reconcil[0].CostExVatPerPack      = Utils.RndNum<decimal>(-50, 50);
            reconcil[0].CreatedUser           = Utils.RndStr(columnInfo.CreatedUserLength);
            reconcil[0].CustOrdNo             = Utils.RndStr(columnInfo.tableInfo.FindByName("CustOrdNo").Length);
            reconcil[0].DateTimeOrdered       = Utils.RndDateTime();
            reconcil[0].DateTimeReceived      = Utils.RndDateTime();
            //orders[0].DeliveryNoteReference = Utils.RndStr(columnInfo.DeliveryNoteReferenceLength);
            reconcil[0].Description           = Utils.RndStr(columnInfo.tableInfo.FindByName("Description").Length);
            reconcil[0].InDispute             = Utils.RndBool();
            reconcil[0].InDisputeUser         = Utils.RndStr(columnInfo.tableInfo.FindByName("InDisputeUser").Length);
            reconcil[0].InternalMethod        = Utils.RndEnum<OrderInternalMethodType>();
            reconcil[0].InternalSiteNo        = Utils.RndStr(columnInfo.tableInfo.FindByName("InternalSiteNo").Length);
            reconcil[0].InvoiceDate           = Utils.RndDateTime();
            reconcil[0].InvoiceNumber         = Utils.RndStr(columnInfo.tableInfo.FindByName("InvNum").Length);
            reconcil[0].IssueUnits            = Utils.RndStr(columnInfo.tableInfo.FindByName("IssueUnits").Length);
            reconcil[0].Location              = Utils.RndStr(columnInfo.tableInfo.FindByName("LocCode").Length);
            reconcil[0].NumPrefix             = Utils.RndStr(columnInfo.tableInfo.FindByName("NumPrefix").Length);
            reconcil[0].OutstandingInPacks    = Utils.RndNum<decimal>(0, 99);
            reconcil[0].PFlag                 = Utils.RndStr(columnInfo.tableInfo.FindByName("PFlag").Length);
            reconcil[0].PickNumber            = Utils.RndNum<int>(0, 999);
            reconcil[0].QuantityOrderedInPacks= Utils.RndNum<decimal>(0, 99);
            reconcil[0].ReceivedInPacks       = Utils.RndNum<decimal>(0, 99);
            reconcil[0].ShelfPrinted          = Utils.RndStr(columnInfo.tableInfo.FindByName("ShelfPrinted").Length);
            reconcil[0].Status                = Utils.RndEnum<OrderStatusType>();
            reconcil[0].Stocked               = Utils.RndStr(columnInfo.tableInfo.FindByName("Stocked").Length);
            reconcil[0].SupplierType          = Utils.RndEnum<SupplierType>();
            reconcil[0].ToFollow              = Utils.RndStr(columnInfo.tableInfo.FindByName("ToFollow").Length);
            reconcil[0].Urgency               = Utils.RndEnum<OrderUrgencyType>();
            reconcil[0].VATAmount             = Utils.RndNum<decimal>(0, 99);
            reconcil[0].VATCode               = Utils.RndNum<int>(0, 9);
            reconcil[0].VATInclusive          = Utils.RndStr(columnInfo.tableInfo.FindByName("VatInclusive").Length);
            reconcil[0].VATRatePct            = Utils.RndStr(columnInfo.tableInfo.FindByName("VATRatePct").Length);
            reconcil[0].ReconcileDate         = Utils.RndDateTime();
            reconcil.Save();

            WReconcil reconcilNew = new WReconcil();
            reconcilNew.LoadByID(WReconcilID);

            Utils.AssertAreEqual(reconcil[0], reconcilNew[0]);
        }

        [TestMethod]
        [Description("Test updating a WReconcil null values.")]
        public void UpdateWReconcilWithNulls()
        {
            WOrderColumnInfo columnInfo = WOrder.GetColumnInfo();

            WReconcil reconcil = new WReconcil();
            reconcil.LoadByID(WReconcilID);
            
            reconcil[0].ConversionFactor      = null;
            reconcil[0].CostExVatPerPack      = null;
            reconcil[0].CreatedUser           = null;
            reconcil[0].CustOrdNo             = null;
            reconcil[0].DateTimeOrdered       = null;
            reconcil[0].DateTimeReceived      = null;
            reconcil[0].DeliveryNoteReference = null;
            reconcil[0].Description           = null;
            reconcil[0].InDispute             = null;
            reconcil[0].InDisputeUser         = null;
            reconcil[0].InternalSiteNo        = null;
            reconcil[0].InvoiceDate           = null;
            reconcil[0].InvoiceNumber         = null;
            reconcil[0].IssueUnits            = null;
            reconcil[0].Location              = null;
            reconcil[0].NumPrefix             = null;
            reconcil[0].OutstandingInPacks    = null;
            reconcil[0].PFlag                 = null;
            reconcil[0].QuantityOrderedInPacks= null;
            reconcil[0].ReceivedInPacks       = null;
            reconcil[0].ShelfPrinted          = null;
            reconcil[0].Stocked               = null;
            reconcil[0].ToFollow              = null;
            reconcil[0].VATAmount             = null;
            reconcil[0].VATCode               = null;
            reconcil[0].VATInclusive          = null;
            reconcil[0].VATRatePct            = null;
            reconcil[0].ReconcileDate       = null;
            reconcil.Save();

            WReconcil reconcilNew = new WReconcil();
            reconcilNew.LoadByID(WReconcilID);

            Utils.AssertAreEqual(reconcil[0], reconcilNew[0]);
        }

        [TestMethod]
        [Description("Test updating a WReconcil (with lock).")]
        public void UpdateWReconcilWithLock()
        {
            WReconcil reconcil = new WReconcil();
            reconcil.RowLockingOption = LockingOption.HardLock;
            reconcil.LoadByID(WReconcilID);
            
            reconcil[0].CostExVatPerPack = Utils.RndNum<decimal>(0, 100);
            reconcil.Save();

            WReconcil reconcilNew = new WReconcil();
            reconcilNew.LoadByID(WReconcilID);

            Utils.AssertAreEqual(reconcilNew[0], reconcilNew[0]);
        }
    }
}
