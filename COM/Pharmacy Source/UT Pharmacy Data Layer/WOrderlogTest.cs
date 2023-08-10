using ascribe.pharmacy.pharmacydatalayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.basedatalayer;
using System;
using System.Collections.Generic;
using System.Data;
using System.Configuration;
using System.Linq;
using System.Data.SqlClient;
using ascribe.pharmacy.shared;

namespace UT_Pharmacy_Data_Layer
{
    
    
    /// <summary>
    ///This is a test class for WOrderlogTest and is intended
    ///to contain all WOrderlogTest Unit Tests
    ///</summary>
    [TestClass()]
    public class WOrderlogTest
    {
        private static int SessionID;            // both relate to rows in the session table

        private const int OrderNumber   = 39;
        private const int SiteNumberA   = 15; 
        private static readonly string NSVCode = "ADE996B";
        private static readonly string SupCode = "AA010";

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
        [Description("Test inserting a WOrderlog using same settings a used in Receipt.")]
        public void InsertWOrderlog()
        {
            int initialWOrderlogCount = Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM WOrderlog");

            WOrderlog orderlog = new WOrderlog();
            WOrderlogRow orderlogRow = orderlog.Add();
            orderlogRow.Kind             = WOrderLogType.Receipt;
            orderlogRow.OrderNumber      = OrderNumber.ToString();
            orderlogRow.NSVCode          = NSVCode;
            orderlogRow.ConversionFactor = 10;
            orderlogRow.IssueUnits       = "amp";
            orderlogRow.DateTimeOrd      = DateTime.Now.AddDays(-5).ToStartOfDay();
            orderlogRow.DateTimeRec      = DateTime.Now.ToStartOfDay();
            orderlogRow.QuantityOrdered  = 5; 
            orderlogRow.QuantityReceived = 2;
            orderlogRow.VatRate          = 1.175M;
            orderlogRow.VatCode          = 1;
            orderlogRow.SupplierCode     = SupCode;
            orderlogRow.SiteID           = SiteIDA;
            orderlogRow.SiteNumber       = SiteNumberA;
            orderlogRow.StockLevel       = 50;
            orderlogRow.StockValue       = 1.51;
            orderlogRow.DateOrdered      = DateTime.Now.AddDays(-5).ToStartOfDay();
            orderlogRow.DateReceived     = DateTime.Now.ToStartOfDay();
            orderlogRow.CostIncVat       = 1.22M;
            orderlogRow.CostExVat        = 1.02M;
            orderlogRow.VatCost          = 0.2M;
            orderlog.Save();

            string sql = string.Format("SELECT * FROM WOrderlog WHERE WOrderlogID={0}", orderlogRow.RawRow["WOrderlogID"]);
            DataSet ds = new DataSet();
            SqlDataAdapter adapter = new SqlDataAdapter(sql, Database.ConnectionString);
            adapter.Fill(ds);
            WOrderlogRow orderlogNewRow = new WOrderlogRow();
            orderlogNewRow.RawRow = ds.Tables[0].Rows[0];

            int newWOrderlogCount = Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM WOrderlog");

            Database.ExecuteSQLNonQuery("DELETE FROM WOrderlog WHERE WOrderlogID={0}", orderlogRow.RawRow["WOrderlogID"]);

            Assert.AreEqual(initialWOrderlogCount + 1, newWOrderlogCount, "Insert has not added row to WOrderlog table");
            AssertAreEqual(orderlogRow, orderlogNewRow);
        }

        public static void AssertAreEqual(BaseRow expected, BaseRow actual)
        {
            string[] excludedDBColumns = { "_TableVersion", "SessionLock", "LogDateTime" };
 
            foreach (DataColumn col in expected.RawRow.Table.Columns)
            {
                string colName = col.ColumnName;
                if (!excludedDBColumns.Contains(colName))
                    Assert.AreEqual(expected.RawRow[colName].ToString(), actual.RawRow[colName].ToString(), string.Format("DB Column [{0}]", colName));
            }
        }
    }
}
