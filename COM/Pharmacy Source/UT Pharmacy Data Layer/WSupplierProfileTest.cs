using ascribe.pharmacy.pharmacydatalayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Data;
using System.Configuration;
using ascribe.pharmacy.basedatalayer;
using System.Data.SqlClient;
using System.Collections.Generic;
using System;
using ascribe.pharmacy.shared;

namespace UT_Pharmacy_Data_Layer
{
    
    
    /// <summary>
    ///This is a test class for WSupplierProfileTest and is intended
    ///to contain all WSupplierProfileTest Unit Tests
    ///</summary>
    [TestClass()]
    public class WSupplierProfileTest
    {
        private static int SessionID;            // both relate to rows in the session table

        private static readonly string SupCode    = "MA010";
        private static readonly string AltSupCode = "CPSD";
        private static readonly string NSVCode    = "ADE002A";
        private static readonly int    DrugID     = 456490;

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

            // Initialise the SessionInfo class
            SessionInfo.InitialiseSessionAndSiteID(SessionID, SiteIDA);   
     
            // Clear down last modified user, terminal, and date for the drug
            Database.ExecuteSQLNonQuery("UPDATE ProductStock SET modifieduser='', modifiedterminal='', modifieddate='01012001', modifiedtime='' WHERE DrugID={0}", DrugID);
        }
        
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion

        [TestMethod]
        [Description("Test updating a WSupplierProfile (without lock).")]
        public void UpdateWSupplierProfile()
        {
            Random rnd = new Random();
            decimal nextVal = (decimal)Math.Round((rnd.NextDouble() - 0.5) * 100, 3);

            WSupplierProfile supplierProfile = new WSupplierProfile();
            supplierProfile.LoadBySiteIDSupplierAndNSVCode(SiteIDA, SupCode, NSVCode);
            
            supplierProfile[0].LastReceivedPriceExVatPerPack  += nextVal;
            supplierProfile.Save();

            WSupplierProfile supplierProfileNew = new WSupplierProfile();
            supplierProfileNew.LoadBySiteIDSupplierAndNSVCode(SiteIDA, SupCode, NSVCode);

            Utils.AssertAreEqual(supplierProfile[0], supplierProfileNew[0]);

            // Load WProduct and check modified fields are not updated
            var p = WProduct.GetByProductAndSiteID(NSVCode, SiteIDA);
            Assert.AreEqual(string.Empty, p.ModifiedByUserInitials, "Has set modified state for edit drug (when it should not)");
            Assert.AreEqual(string.Empty, p.ModifiedOnTerminal,     "Has set modified state for edit drug (when it should not)");
            Assert.IsNull(p.ModifiedDate, "Has set modified state for edit drug (when it should not)");
        }

        [TestMethod]
        [Description("Test updating a WSupplierProfile updated the modified date\\time.")]
        public void Update_WSupplierProfile_Updates_ModDateTime()
        {
            Random rnd = new Random();
            decimal nextVal = (decimal)Math.Round((rnd.NextDouble() - 0.5) * 100, 3);
            DateTime testStartTime = DateTime.Now.AddSeconds(-1);

            // Load 
            WSupplierProfile supplierProfile = new WSupplierProfile();
            supplierProfile.LoadBySiteIDSupplierAndNSVCode(SiteIDA, SupCode, NSVCode);
            
            // Modify
            supplierProfile[0].LastReceivedPriceExVatPerPack  += nextVal;
            supplierProfile.Save(true, false);

            // Test WProduct
            var p = WProduct.GetByProductAndSiteID(NSVCode, SiteIDA);
            Assert.AreEqual(p.ModifiedByUserInitials, SessionInfo.UserInitials, "Has set modified state for edit drug that was not edited");
            Assert.AreEqual(p.ModifiedOnTerminal,     SessionInfo.Terminal, "Has set modified state for edit drug that was not edited");
            Assert.IsTrue(p.ModifiedDate >= testStartTime, "Has set modified state for edit drug that was not edited");
        }

        [TestMethod]
        [Description("Test updating alternate WSupplierProfile does not updated modified date\\time.")]
        public void Update_Alt_WSupplierProfile_DoesNot_Updates_ModDateTime()
        {
            Random rnd = new Random();
            decimal nextVal = (decimal)Math.Round((rnd.NextDouble() - 0.5) * 100, 3);

            // Load 
            WSupplierProfile supplierProfile = new WSupplierProfile();
            supplierProfile.LoadBySiteIDSupplierAndNSVCode(SiteIDA, AltSupCode, NSVCode);
            
            // Modify
            supplierProfile[0].LastReceivedPriceExVatPerPack  += nextVal;
            supplierProfile.Save(true, false);

            // Test WProduct
            var p = WProduct.GetByProductAndSiteID(NSVCode, SiteIDA);
            Assert.AreEqual(string.Empty, p.ModifiedByUserInitials, "Has set modified state for edit drug (when it should not)");
            Assert.AreEqual(string.Empty, p.ModifiedOnTerminal,     "Has set modified state for edit drug (when it should not)");
            Assert.IsNull(p.ModifiedDate, "Has set modified state for edit drug (when it should not)");
        }
    }
}
