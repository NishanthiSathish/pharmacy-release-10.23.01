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
    ///This is a test class for WRequisTest and is intended
    ///to contain all WRequisTest Unit Tests
    ///</summary>
    [TestClass()]
    public class WRequisTest
    {
        private static int SessionID;            // both relate to rows in the session table

        private const int OrderNum = 59;
        private const int WRequisID = 22;

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
        [Description("Test inserting a WRequis using random values.")]
        public void InsertWRequis()
        {
            var columnInfo = WRequis.GetColumnInfo();

            int initialWRequisCount = Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM WRequis");

            WRequis requis = new WRequis();
            WRequisRow requisRow = requis.Add();
            requisRow.NumPrefix               = Utils.RndStr(columnInfo.tableInfo.FindByName("NumPrefix").Length);
            requisRow.ToFollow                = Utils.RndStr(columnInfo.tableInfo.FindByName("ToFollow" ).Length);
            requisRow.Urgency                 = Utils.RndEnum<OrderUrgencyType>();
            requisRow.IssueUnits              = Utils.RndStr(columnInfo.tableInfo.FindByName("IssueUnits").Length);
            requisRow.Stocked                 = Utils.RndStr(columnInfo.tableInfo.FindByName("Stocked").Length);
            requisRow.Description             = Utils.RndStr(columnInfo.tableInfo.FindByName("Description").Length);
            requisRow.CustOrdNo               = Utils.RndStr(columnInfo.tableInfo.FindByName("CustOrdNo").Length);
            requisRow.SupplierType            = Utils.RndEnum<SupplierType>();
            requisRow.NSVCode                 = Utils.RndStr(columnInfo.tableInfo.FindByName("Code").Length);
            requisRow.Status                  = Utils.RndEnum<OrderStatusType>();
            requisRow.OrderNumber             = 0;
            requisRow.SiteID                  = SiteIDA;
            requisRow.DateTimeOrdered         = Utils.RndDateTime();
            requisRow.DateTimeReceived        = Utils.RndDateTime();
            requisRow.Location                = Utils.RndStr(columnInfo.tableInfo.FindByName("LocCode").Length);
            requisRow.SupplierCode            = Database.ExecuteSQLScalar<string>("SELECT TOP 1 Code FROM WSupplier WHERE SiteID=" + SiteIDA.ToString());
            requisRow.PickNumber              = Utils.RndNum<int>(0, 99);
            requisRow.InternalMethod          = Utils.RndEnum<OrderInternalMethodType>();
            requisRow.PFlag                   = Utils.RndStr(columnInfo.tableInfo.FindByName("PFlag").Length);
            requisRow.VATRatePct              = Utils.RndStr(columnInfo.tableInfo.FindByName("VATRatePct").Length);
            requisRow.VATInclusive            = Utils.RndStr(columnInfo.tableInfo.FindByName("VatInclusive").Length);
            requisRow.VATCode                 = Utils.RndNum<int>(0, 9);
            requisRow.QuantityOrderedInPacks  = Utils.RndNum<decimal>(0, 99);
            //requisRow.ReceivedInPacks         = Utils.RndNum<decimal>(0, 99);
            requisRow.InternalSiteNo          = Utils.RndStr(columnInfo.tableInfo.FindByName("InternalSiteNo").Length);
            requisRow.ShelfPrinted            = Utils.RndStr(columnInfo.tableInfo.FindByName("ShelfPrinted").Length);
            requisRow.CreatedUser             = Utils.RndStr(columnInfo.CreatedUserLength);
            requisRow.InDispute               = Utils.RndBool();
            requisRow.InDisputeUser           = Utils.RndStr(columnInfo.tableInfo.FindByName("InDisputeUser").Length);
            requisRow.InvoiceDate             = Utils.RndDateTime();
            //requisRow.InvoiceNumber           = Utils.RndStr(columnInfo.tableInfo.FindByName("InvNum").Length);
            requisRow.RequisitionNumber       = Utils.RndStr(columnInfo.tableInfo.FindByName("RequisitionNum").Length);
            requis.Save();

            WRequis requisNew = new WRequis();
            requisNew.LoadByID(requisRow.WRequisID);

            int newWRequisCount = Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM WRequis");

            Database.ExecuteSQLNonQuery("DELETE FROM WRequis WHERE WRequisID={0}", requisRow.WRequisID);

            Assert.AreEqual(initialWRequisCount + 1, newWRequisCount, "Insert has not added row to WReconil table");
            Utils.AssertAreEqual(requis[0], requisNew[0]);
        }

        [TestMethod]
        [Description("Test inserting a WRequis using null.")]
        public void InsertWRequisWithNulls()
        {
            var columnInfo = WRequis.GetColumnInfo();

            int initialWRequisCount = Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM WRequis");

            WRequis requis = new WRequis();
            WRequisRow requisRow = requis.Add();
            requisRow.NumPrefix               = null;
            requisRow.ToFollow                = null;
            requisRow.Urgency                 = Utils.RndEnum<OrderUrgencyType>();
            requisRow.IssueUnits              = null;
            requisRow.Stocked                 = null;
            requisRow.Description             = null;
            requisRow.CustOrdNo               = null;
            requisRow.SupplierType            = Utils.RndEnum<SupplierType>();
            requisRow.NSVCode                 = null;
            requisRow.Status                  = Utils.RndEnum<OrderStatusType>();
            requisRow.OrderNumber             = 0;
            requisRow.SiteID                  = SiteIDA;
            requisRow.DateTimeOrdered         = null;
            requisRow.DateTimeReceived        = null;
            requisRow.Location                = null;
            requisRow.SupplierCode            = Database.ExecuteSQLScalar<string>("SELECT TOP 1 Code FROM WSupplier WHERE SiteID=" + SiteIDA.ToString());
            requisRow.PickNumber              = Utils.RndNum<int>(0, 99);
            requisRow.InternalMethod          = Utils.RndEnum<OrderInternalMethodType>();
            requisRow.PFlag                   = null;
            requisRow.VATRatePct              = null;
            requisRow.VATInclusive            = null;
            requisRow.VATCode                 = null;
            requisRow.QuantityOrderedInPacks  = null;
            //requisRow.ReceivedInPacks         = Utils.RndNum<decimal>(0, 99);
            requisRow.InternalSiteNo          = null;
            requisRow.ShelfPrinted            = null;
            requisRow.CreatedUser             = null;
            requisRow.InDispute               = null;
            requisRow.InDisputeUser           = null;
            requisRow.InvoiceDate             = null;
            //requisRow.InvoiceNumber           = Utils.RndStr(columnInfo.tableInfo.FindByName("InvNum").Length);
            requisRow.RequisitionNumber       = null;
            requis.Save();

            WRequis requisNew = new WRequis();
            requisNew.LoadByID(requisRow.WRequisID);

            int newWRequisCount = Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM WRequis");

            Database.ExecuteSQLNonQuery("DELETE FROM WRequis WHERE WRequisID={0}", requisRow.WRequisID);

            Assert.AreEqual(initialWRequisCount + 1, newWRequisCount, "Insert has not added row to WReconil table");
            Utils.AssertAreEqual(requis[0], requisNew[0]);
        }
    }
}
