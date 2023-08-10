using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UT_Pharmacy_Data_Layer
{
    
    
    /// <summary>
    ///This is a test class for ProductStockTest and is intended
    ///to contain all ProductStockTest Unit Tests
    ///</summary>
    [TestClass()]
    public class ProductStockTest
    {
        private static int SessionID;            // both relate to rows in the session table

        private static readonly string NSVCode = "ADE572A";

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
        [Description("Test updating a product stock (without lock).")]
        public void UpdateProductStock()
        {
            Random rnd = new Random();
            decimal nextVal = (decimal)Math.Round((rnd.NextDouble() - 0.5) * 100, 3);

            ProductStock productStock = new ProductStock();
            productStock.LoadBySiteIDAndNSVCode(NSVCode, SiteIDA);
            
            productStock[0].StockLevelInIssueUnits  += nextVal;
            productStock[0].AverageCostExVatPerPack += nextVal;
            productStock.Save();

            ProductStock productStockNew = new ProductStock();
            productStockNew.LoadBySiteIDAndNSVCode(NSVCode, SiteIDA);

            Utils.AssertAreEqual(productStock[0], productStockNew[0]);
        }
    }
}
