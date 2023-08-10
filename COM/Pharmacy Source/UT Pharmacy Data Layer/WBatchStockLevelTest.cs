using ascribe.pharmacy.pharmacydatalayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.basedatalayer;
using System.Data;
using System.Configuration;
using System.Data.SqlClient;
using System.Collections.Generic;
using ascribe.pharmacy.shared;
using System;

namespace UT_Pharmacy_Data_Layer
{
    
    
    /// <summary>
    ///This is a test class for WBatchStockLevelTest and is intended
    ///to contain all WBatchStockLevelTest Unit Tests
    ///</summary>
    [TestClass()]
    public class WBatchStockLevelTest
    {
        private static int SessionID;            // both relate to rows in the session table

        private static readonly string NSVCode      = "ADE572A";
        private static readonly string BatchNumber  = "FDDSD";

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

            Database.ExecuteSQLNonQuery("DELETE FROM WBatchStockLevel WHERE SiteID={0} AND NSVcode Like '{1}' AND Batchnumber Like '{2}'", SiteIDA, NSVCode, BatchNumber);
        }
        
        //Use TestCleanup to run code after each test has run
        [TestCleanup()]
        public void MyTestCleanup()
        {
        }
        #endregion

        [TestMethod]
        [Description("Test inserting a WBatchStockLevel using same settings a used in Receipt.")]
        public void InsertWBatchStockLevel()
        {
            int initialWReconcilCount = Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM WBatchStockLevel");

            WBatchStockLevel batchStockLevel = new WBatchStockLevel();
            WBatchStockLevelRow batchStockLevelRow = batchStockLevel.Add();
            batchStockLevelRow.BatchNumber    = BatchNumber;
            batchStockLevelRow.NSVCode        = NSVCode;
            batchStockLevelRow.SiteID         = SiteIDA;
            batchStockLevelRow.Description    = "UnitTest";
            batchStockLevelRow.ExpiryDate     = DateTime.Now.AddDays(4).ToStartOfDay();
            batchStockLevelRow.QuantityInPacks= 0;
            batchStockLevel.Save();

            WBatchStockLevel batchStockLevelNew = new WBatchStockLevel();
            batchStockLevelNew.LoadBySiteIDNSVCodeAndBatchNumber(SiteIDA, NSVCode, BatchNumber, false);

            Assert.AreEqual(initialWReconcilCount + 1, Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM WBatchStockLevel"), "Insert has not added row to WBatchStockLevel table");
            Utils.AssertAreEqual(batchStockLevel[0], batchStockLevelNew[0]);
        }

        [TestMethod]
        [Description("Test updating a WBatchStockLevel (without lock).")]
        public void UpdateWBatchStockLevel()
        {
            Random rnd = new Random();

            WBatchStockLevel batchStockLevel = new WBatchStockLevel();
            WBatchStockLevelRow batchStockLevelRow = batchStockLevel.Add();
            batchStockLevelRow.BatchNumber    = BatchNumber;
            batchStockLevelRow.NSVCode        = NSVCode;
            batchStockLevelRow.SiteID         = SiteIDA;
            batchStockLevelRow.Description    = "UnitTest";
            batchStockLevelRow.ExpiryDate     = DateTime.Now.AddDays(4).ToStartOfDay();
            batchStockLevelRow.QuantityInPacks= 0;
            batchStockLevel.Save();

            batchStockLevel.LoadBySiteIDNSVCodeAndBatchNumber(SiteIDA, NSVCode, BatchNumber, false);
            batchStockLevelRow.QuantityInPacks = rnd.Next(9999);
            batchStockLevel.Save();

            WBatchStockLevel batchStockLevelNew = new WBatchStockLevel();
            batchStockLevelNew.LoadBySiteIDNSVCodeAndBatchNumber(SiteIDA, NSVCode, BatchNumber, false);

            Utils.AssertAreEqual(batchStockLevel[0], batchStockLevelNew[0]);
        }
    }
}
