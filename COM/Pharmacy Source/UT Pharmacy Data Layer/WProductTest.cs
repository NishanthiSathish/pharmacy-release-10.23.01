// -----------------------------------------------------------------------
// <copyright file="WProductTest.cs" company="Ascribe">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

namespace UT_Pharmacy_Data_Layer
{
    using System;
    using System.Collections.Generic;
    using System.Configuration;
    using System.Linq;
    using System.Text;

    using ascribe.pharmacy.pharmacydatalayer;

    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>
    /// TODO: Update summary.
    /// </summary>
    [TestClass()]
    public class WProductTest
    {
        private static int SessionID;            // both relate to rows in the session table

        private static string NSVCode = "ADE274D";  // Existing NSV Code to update
        private static int DrugID = 547636;         // Drug ID for NSVCode=ADE274D

        // Sites where product exists NSVCode=ADE274D
        private static int SiteIDA = 15;
        private static int SiteIDB = 20;

        // Site where product does not exist
        private static int SiteIDC = 21;

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
        
        //Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext)
        {
            // Get session ID (any will do)
            SessionID = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC");
        }

        //
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

            // Initialise the SessionInfo class
            SessionInfo.InitialiseSessionAndSiteID(SessionID, SiteIDA);
            
            // Clear down last modified user, terminal, and date for the drug
            Database.ExecuteSQLNonQuery("UPDATE ProductStock SET modifieduser='', modifiedterminal='', modifieddate='01012001', modifiedtime='' WHERE DrugID={0}", DrugID);
            
            // Delete the drug from site C
            Database.ExecuteSQLNonQuery("DELETE WSupplierProfile WHERE NSVCode='{0}' AND LocationID_Site={1}", NSVCode, SiteIDC);
            Database.ExecuteSQLNonQuery("DELETE ProductStock WHERE DrugID={0} AND LocationID_Site={1}", DrugID, SiteIDC);
        }
        
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion

        [TestMethod]
        [Description("Test saving WProduct when update ProductStock updates the modified date.")]
        public void Saving_ProductStock_Updates_ModifiedDate()
        {
            DateTime testStartTime = DateTime.Now.AddSeconds(-1);

            // Load the drug line, and update a product stock field
            WProduct product = new WProduct();
            product.LoadByNSVCode(NSVCode);
            var p = product.FindBySiteID(SiteIDA).First();
            p.StockLevelInIssueUnits += 1;

            product.Save(true);
            
            // Reload the data
            product.LoadByNSVCode(NSVCode);

            // test row that should of changedp.
            p = product.FindBySiteID(SiteIDA).First();
            Assert.AreEqual(SessionInfo.UserInitials, p.ModifiedByUserInitials, "Has not set modified state for edit drug");
            Assert.AreEqual(SessionInfo.Terminal,     p.ModifiedOnTerminal,     "Has not set modified state for edit drug");
            Assert.IsTrue(p.ModifiedDate >= testStartTime, "Has not set modified state for edit drug");

            // test row that should not of changed
            p = product.FindBySiteID(SiteIDB).First();
            Assert.AreNotEqual(SessionInfo.UserInitials, p.ModifiedByUserInitials, "Has set modified state for edit drug that was not edited");
            Assert.AreNotEqual(SessionInfo.Terminal,     p.ModifiedOnTerminal,     "Has set modified state for edit drug that was not edited");
            Assert.IsFalse(p.ModifiedDate >= testStartTime, "Has set modified state for edit drug that was not edited");
        }

        [TestMethod]
        [Description("Test saving WProduct when update WSupplierProfile updates the modified date.")]
        public void Saving_WSupplierProfile_Updates_ModifiedDate()
        {
            DateTime testStartTime = DateTime.Now.AddSeconds(-1);

            // Load the drug line, and update a WSupplierProfile field
            WProduct product = new WProduct();
            product.LoadByNSVCode(NSVCode);
            var p = product.FindBySiteID(SiteIDA).First();
            p.SupplierReferenceNumber = Utils.RndStr(5);

            product.Save(true);
            
            // Reload the data
            product.LoadByNSVCode(NSVCode);

            // test row that should of changed
            p = product.FindBySiteID(SiteIDA).First();
            Assert.AreEqual(SessionInfo.UserInitials, p.ModifiedByUserInitials, "Has not set modified state for edit drug");
            Assert.AreEqual(SessionInfo.Terminal,     p.ModifiedOnTerminal,     "Has not set modified state for edit drug");
            Assert.IsTrue(p.ModifiedDate >= testStartTime, "Has not set modified state for edit drug");

            // test row that should not of changed
            p = product.FindBySiteID(SiteIDB).First();
            Assert.AreNotEqual(SessionInfo.UserInitials, p.ModifiedByUserInitials, "Has set modified state for edit drug that was not edited");
            Assert.AreNotEqual(SessionInfo.Terminal,     p.ModifiedOnTerminal,     "Has set modified state for edit drug that was not edited");
            Assert.IsFalse(p.ModifiedDate >= testStartTime, "Has set modified state for edit drug that was not edited");
        }

        [TestMethod]
        [Description("Test saving WProduct when update SiteProductData updates the modified date (for all sites).")]
        public void Saving_SiteProductData_Updates_ModifiedDate_All_Sites()
        {
            DateTime testStartTime = DateTime.Now.AddSeconds(-1);

            // Load the drug line, and update a SiteProductData field
            WProduct product = new WProduct();
            product.LoadByProductAndSiteID(NSVCode, SiteIDA);
            product[0].CanUseSpoon_Locked = !product[0].CanUseSpoon_Locked;
            product[0].SupplierReferenceNumber = Utils.RndStr(5);   // Check not effected by single update
            product.Save(true);
            
            // Reload the data
            product.LoadByNSVCode(NSVCode);

            // test all rows have changed
            foreach (var p in product)
            {
                Assert.AreEqual(SessionInfo.UserInitials, p.ModifiedByUserInitials, "Has not set modified state for edit drug");
                Assert.AreEqual(SessionInfo.Terminal,     p.ModifiedOnTerminal,     "Has not set modified state for edit drug");
                Assert.IsTrue(p.ModifiedDate >= testStartTime, "Has not set modified state for edit drug");                
            }
        }

        [TestMethod]
        [Description("Test adding WProduct (for existing SiteProductData) updates the modified date.")]
        public void Adding_ProductStock_Updates_ModifieidDate()
        {
            DateTime testStartTime = DateTime.Now.AddSeconds(-1);

            SiteProductData spd = new SiteProductData();
            spd.LoadBySiteIDAndNSVCode(SiteIDA, NSVCode);

            // Add the new WProduct line for site C
            WProduct product = new WProduct();
            var p = product.Add();
            p.CopyFrom(spd.First());
            p.SiteID = SiteIDC;

            // Set require fields
            p.IfLiveStockControl = false;   
            p.AverageCostExVatPerPack = 0;

            product.Save(true);

            // Reload the data
            product.LoadByNSVCode(NSVCode);

            // test row that should not of changed
            p = product.FindBySiteID(SiteIDA).First();
            Assert.AreNotEqual(SessionInfo.UserInitials, p.ModifiedByUserInitials, "Has set modified state for edit drug that was not edited");
            Assert.AreNotEqual(SessionInfo.Terminal,     p.ModifiedOnTerminal,     "Has set modified state for edit drug that was not edited");
            Assert.IsFalse(p.ModifiedDate >= testStartTime, "Has set modified state for edit drug that was not edited");

            // test row that should not of changed
            p = product.FindBySiteID(SiteIDB).First();
            Assert.AreNotEqual(SessionInfo.UserInitials, p.ModifiedByUserInitials, "Has set modified state for edit drug that was not edited");
            Assert.AreNotEqual(SessionInfo.Terminal,     p.ModifiedOnTerminal,     "Has set modified state for edit drug that was not edited");
            Assert.IsFalse(p.ModifiedDate >= testStartTime, "Has set modified state for edit drug that was not edited");

            // test row that should of changed
            p = product.FindBySiteID(SiteIDC).First();
            Assert.AreEqual(SessionInfo.UserInitials, p.ModifiedByUserInitials, "Has not set modified state for edit drug");
            Assert.AreEqual(SessionInfo.Terminal,     p.ModifiedOnTerminal,     "Has not set modified state for edit drug");
            Assert.IsTrue(p.ModifiedDate >= testStartTime, "Has not set modified state for edit drug");
        }

        [TestMethod]
        [Description("Test if updating fails does not update the modified date.")]
        public void If_Save_Fails_Does_Not_Update_ModifiedDate()
        {
            DateTime testStartTime = DateTime.Now.AddSeconds(-1);

            // Load the drug line, and set invalid Stores Description
            WProduct product = new WProduct();
            product.LoadByNSVCode(NSVCode);
            var p = product.FindBySiteID(SiteIDA).First();
            p.StoresDescription =
                "11111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111";

            // Save will fail
            try
            {
                product.Save(true);
            }
            catch (Exception) { }
            
            // Reload the data
            product.LoadByNSVCode(NSVCode);

            // test row that should not of changed
            p = product.FindBySiteID(SiteIDA).First();
            Assert.AreNotEqual(p.ModifiedByUserInitials, SessionInfo.UserInitials, "Has not set modified state for edit drug");
            Assert.AreNotEqual(p.ModifiedOnTerminal,     SessionInfo.Terminal, "Has not set modified state for edit drug");
            Assert.IsFalse(p.ModifiedDate >= testStartTime, "Has not set modified state for edit drug");

            // test row that should not of changed
            p = product.FindBySiteID(SiteIDB).First();
            Assert.AreNotEqual(p.ModifiedByUserInitials, SessionInfo.UserInitials, "Has set modified state for edit drug that was not edited");
            Assert.AreNotEqual(p.ModifiedOnTerminal,     SessionInfo.Terminal, "Has set modified state for edit drug that was not edited");
            Assert.IsFalse(p.ModifiedDate >= testStartTime, "Has set modified state for edit drug that was not edited");
        }

        [TestMethod]
        [Description("Test saving WProduct when no change does not update modified date.")]
        public void Saving_When_No_Change_On_ModifiedDate()
        {
            DateTime testStartTime = DateTime.Now.AddSeconds(-1);

            // Load the drug line but do not change anything
            WProduct product = new WProduct();
            product.LoadByNSVCode(NSVCode);

            product.Save(true);
            
            // Reload the data
            product.LoadByNSVCode(NSVCode);

            // test all rows have not had modified date set.
            foreach (var p in product)
            {
                Assert.AreEqual(string.Empty, p.ModifiedByUserInitials, "Has set modified state for edit drug (when it should not)");
                Assert.AreEqual(string.Empty, p.ModifiedOnTerminal,     "Has set modified state for edit drug (when it should not)");
                Assert.IsNull(p.ModifiedDate, "Has set modified state for edit drug (when it should not)");
            }
        }

        [TestMethod]
        [Description("Test normal saving of WProduct does not update modified date (for all sites).")]
        public void Normal_Saving_Does_Not_Updates_ModifiedDate()
        {
            DateTime testStartTime = DateTime.Now.AddSeconds(-1);

            // Load the drug line, and update a SiteProductData field
            WProduct product = new WProduct();
            product.LoadByProductAndSiteID(NSVCode, SiteIDA);
            product[0].CanUseSpoon_Locked = !product[0].CanUseSpoon_Locked;
            product[0].SupplierReferenceNumber = Utils.RndStr(5);   // Check not effected by single update
            product.Save(); // Normal save (will not update modified date)
            
            // Reload the data
            product.LoadByNSVCode(NSVCode);

            // test all rows have changed
            // test all rows have not had modified date set.
            foreach (var p in product)
            {
                Assert.AreEqual(string.Empty, p.ModifiedByUserInitials, "Has set modified state for edit drug (when it should not)");
                Assert.AreEqual(string.Empty, p.ModifiedOnTerminal,     "Has set modified state for edit drug (when it should not)");
                Assert.IsNull(p.ModifiedDate, "Has set modified state for edit drug (when it should not)");
            }
        }
    }
}
