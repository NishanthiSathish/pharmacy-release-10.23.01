using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.Linq;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Unit_Test_Business_Layer
{
    /// <summary>
    /// Summary description for OrderLineTests
    /// </summary>
    [TestClass]
    public class RequistionLineTests
    {
        private static int SessionID;            // both relate to rows in the session table
        private static int OtherUserSessionID;

        const int ProductID  = 113983;

        const int SiteIDA = 15; // both relate to rows in the site table
        const int SiteIDB = 19;

        static private TestDBDataContext linqdb;
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
        
        // Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext)
        {
            Configuration conf = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            ConnectionStringsSection connectionStrSect = conf.ConnectionStrings;

            string connectionStr = connectionStrSect.ConnectionStrings["TRNRTL10.My.MySettings.ConnectionString"].ConnectionString;
            linqdb = new TestDBDataContext(connectionStr);

            // Get a sesssion ID (any will do)
            SessionID          = linqdb.ExecuteQuery<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC").First();
            OtherUserSessionID = linqdb.ExecuteQuery<int>("SELECT TOP 1 SessionID FROM Session WHERE SessionID<>{0} ORDER BY SessionID DESC", SessionID).First();
        }
        
        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        
        /// <summary>
        /// Called before each test is run. 
        /// Resets the database
        /// Setup a mock HttpContext
        /// Initalise the SessionInfo class
        /// </summary>
        [TestInitialize()]
        public void MyTestInitialize()
        {
            // Determine which directory the files have been published to
            string assemblyFile = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string assemblyDir = System.IO.Path.GetDirectoryName(assemblyFile);

            PrivateType type = new PrivateType(typeof(PharmacyDataCache));
            type.InvokeStatic("ClearCaches");

            // Initalise the SessionInfo class
            SessionInfo.InitialiseSessionAndSiteID(SessionID, SiteIDA);

            // update session
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("DateToSet", DateTime.Now));
            parameters.Add(new SqlParameter("SessionID", SessionID));
            Database.ExecuteSQLNonQuery("UPDATE Session SET Disconnected=0, DateCreated=@DateToSet, DateLastUsed=@DateToSet WHERE SessionID=@SessionID", parameters);

            // Reset any settings
            WConfiguration config = new WConfiguration();
            config.LoadBySiteCategorySectionAndKey(SiteIDA, "d|WorkingDefaults", "", "PrintInPacks");
            config[0].Value = "0";
            config.Save();
        }
        
        // Use TestCleanup to run code after each test has run
        [TestCleanup()]
        public void MyTestCleanup() 
        { 
            // Reset any settings
            WConfiguration config = new WConfiguration();
            config.LoadBySiteCategorySectionAndKey(SiteIDA, "d|WorkingDefaults", "", "PrintInPacks");
            config[0].Value = "0";
            config.Save();
        }        
        #endregion

        [TestMethod]
        [Description("Test that RequisitionLine outstanding, and received, fields are converted to pack correctly (if print in packs is false).")]
        public void IsOutstandingAndReceivedConvertedToPacksWhenPrintInPacksIsFalse()
        {
            const string NSVCode = "ADE223A";
            const int    siteID  = SiteIDA;

            int dssMasterSiteID = linqdb.DSSMasterSiteLinkSites.First(i => i.SiteID == siteID).DSSMasterSiteID.Value;

            // Set print in packs to false.
            WConfiguration config = new WConfiguration();
            config.LoadBySiteCategorySectionAndKey(siteID, "d|WorkingDefaults", "", "PrintInPacks");
            config[0].Value = "0";
            config.Save();

            int convFact = linqdb.wProducts.First(p => (p.siscode == NSVCode) && (p.DSSMasterSiteID == dssMasterSiteID)).convfact.Value;

            WRequis processor = new WRequis();
            processor.LoadBySiteIDNSVCodeAndFromDate(SiteIDA, NSVCode, null);
            WRequisRow line = processor[0];

            // get raw outstanding and recieved data from database
            WRequi requis = linqdb.WRequis.First(r => r.WRequisID == line.WRequisID);

            // Test requisition line for ward supplier (should convert from issue units to packs)
            processor[0].RawRow["SupplierType"] = EnumDBCodeAttribute.EnumToDBCode(SupplierType.Ward);
            Assert.AreEqual(decimal.Parse(requis.Outstanding) / convFact, line.OutstandingInPacks, "Failed to convert db outstanding to packs for 'W' type supplier");
            Assert.AreEqual(decimal.Parse(requis.Received)    / convFact, line.ReceivedInPacks,    "Failed to convert db received to packs for 'W' type supplier");

            // Test requisition line for L supplier (should convert from issue units to packs)
            processor[0].RawRow["SupplierType"] = EnumDBCodeAttribute.EnumToDBCode(SupplierType.List);
            Assert.AreEqual(decimal.Parse(requis.Outstanding) / convFact, line.OutstandingInPacks, "Failed to convert db outstanding to packs for 'L' type supplier");
            Assert.AreEqual(decimal.Parse(requis.Received)    / convFact, line.ReceivedInPacks,    "Failed to convert db received to packs for 'L' type supplier");

            // Test requisition line for normal supplier (should not convert to packs)
            processor[0].RawRow["SupplierType"] = EnumDBCodeAttribute.EnumToDBCode(SupplierType.Stores);
            Assert.AreEqual(decimal.Parse(requis.Outstanding), line.OutstandingInPacks, "Has altered outstanding value when already in packs for 'S' type supplier");
            Assert.AreEqual(decimal.Parse(requis.Received),    line.ReceivedInPacks,    "Has altered received value when already in packs for 'S' type supplier");
        }

        [TestMethod]
        [Description("Test that RequisitionLine outstanding, and received, fields are converted to pack correctly (if print in packs is true).")]
        public void IsOutstandingAndReceivedConvertedToPacksWhenPrintInPacksIsTrue()
        {
            const string NSVCode = "ADE223A";
            const int    siteID  = SiteIDA;

            int dssMasterSiteID = linqdb.DSSMasterSiteLinkSites.First(i => i.SiteID == siteID).DSSMasterSiteID.Value;

            // Set print in packs to true.
            WConfiguration config = new WConfiguration();
            config.LoadBySiteCategorySectionAndKey(siteID, "d|WorkingDefaults", "", "PrintInPacks");
            config[0].Value = "-1";
            config.Save();

            int convFact = linqdb.wProducts.First(p => (p.siscode == NSVCode) && (p.DSSMasterSiteID == dssMasterSiteID)).convfact.Value;

            WRequis processor = new WRequis();
            processor.LoadBySiteIDNSVCodeAndFromDate(SiteIDA, NSVCode, null);
            WRequisRow line = processor[0];

            // get raw outstanding and recieved data from database
            WRequi requis = linqdb.WRequis.First(r => r.WRequisID == line.WRequisID);

            // Test requisition line for ward supplier (should already be in packs)
            processor[0].RawRow["SupplierType"] = EnumDBCodeAttribute.EnumToDBCode(SupplierType.Ward);
            Assert.AreEqual(decimal.Parse(requis.Outstanding), line.OutstandingInPacks, "Has altered outstanding value when already in packs for 'W' type supplier");
            Assert.AreEqual(decimal.Parse(requis.Received)   , line.ReceivedInPacks,    "Has altered received value when already in packs for 'W' type supplier");

            // Test requisition line for L supplier (should already be in packs)
            processor[0].RawRow["SupplierType"] = EnumDBCodeAttribute.EnumToDBCode(SupplierType.List);
            Assert.AreEqual(decimal.Parse(requis.Outstanding), line.OutstandingInPacks, "Has altered outstanding value when already in packs for 'L' type supplier");;
            Assert.AreEqual(decimal.Parse(requis.Received)   , line.ReceivedInPacks,    "Has altered received value when already in packs for 'L' type supplier");

            // Test requisition line for normal supplier (should not convert to packs)
            processor[0].RawRow["SupplierType"] = EnumDBCodeAttribute.EnumToDBCode(SupplierType.Stores);
            Assert.AreEqual(decimal.Parse(requis.Outstanding), line.OutstandingInPacks, "Has altered outstanding value when already in packs for 'S' type supplier");
            Assert.AreEqual(decimal.Parse(requis.Received), line.ReceivedInPacks,       "Has altered received value when already in packs for 'S' type supplier");
        }

        [TestMethod]
        [Description("Test that RequisitionLine saves outstanding, and received, as issue units (if print in packs is false).")]
        public void IsOutstandingAndReceivedConvertedToIssueUnitsWhenPrintInPacksIsFalse()
        {
            const string NSVCode = "ADE223A";
            const int    siteID  = SiteIDA;

            // Set print in packs to false.
            WConfiguration config = new WConfiguration();
            config.LoadBySiteCategorySectionAndKey(siteID, "d|WorkingDefaults", "", "PrintInPacks");
            config[0].Value = "0";
            config.Save();

            int dssMasterSiteID = linqdb.DSSMasterSiteLinkSites.First(i => i.SiteID == siteID).DSSMasterSiteID.Value;
            int convFact = linqdb.wProducts.First(p => (p.siscode == NSVCode) && (p.DSSMasterSiteID == dssMasterSiteID)).convfact.Value;

            WRequis processor = new WRequis();
            WRequisRow line = processor.Add();
            line.SiteID = siteID;
            line.RawRow.Table.Columns.Add("SiteProductData_Convfact", typeof(int));
            line.RawRow["SiteProductData_Convfact"] = convFact;
            line.NSVCode = NSVCode;

            // Test requisition line for W supplier (should convert from packs to issue units)
            line.SupplierType = SupplierType.Ward;
            line.OutstandingInPacks = 10;
            line.ReceivedInPacks    = 20;
            processor.Save();

            WRequi requis = linqdb.WRequis.First(p => p.WRequisID == line.WRequisID);
            linqdb.Refresh(RefreshMode.OverwriteCurrentValues, requis);

            Assert.AreEqual(decimal.Parse(requis.Outstanding) / convFact, 10, "Failed to convert db outstanding to issue units for 'W' type supplier");
            Assert.AreEqual(decimal.Parse(requis.Received)    / convFact, 20, "Failed to convert db received to issue units for 'W' type supplier");

            // Test requisition line for L supplier (should convert from packs to issue units)
            line = processor.Add();
            line.SiteID = siteID;
            line.SupplierType = SupplierType.List;
            line.RawRow["SiteProductData_Convfact"] = convFact;
            line.OutstandingInPacks = 10;
            line.ReceivedInPacks    = 20;
            line.NSVCode = NSVCode;
            processor.Save();

            requis = linqdb.WRequis.First(p => p.WRequisID == line.WRequisID);

            Assert.AreEqual(decimal.Parse(requis.Outstanding) / convFact, 10, "Failed to convert db outstanding to issue units for 'W' type supplier");
            Assert.AreEqual(decimal.Parse(requis.Received)    / convFact, 20, "Failed to convert db received to issue units for 'W' type supplier");

            // Test requisition line for S supplier (should not convert from packs to issue units)
            line = processor.Add();
            line.SiteID = siteID;
            line.SupplierType = SupplierType.Stores;
            line.RawRow["SiteProductData_Convfact"] = convFact;
            line.OutstandingInPacks = 10;
            line.ReceivedInPacks    = 20;
            line.NSVCode = NSVCode;
            processor.Save();

            requis = linqdb.WRequis.First(p => p.WRequisID == line.WRequisID);

            Assert.AreEqual(decimal.Parse(requis.Outstanding), 10, "Should not convert db outstanding to issue units for 'S' type supplier");
            Assert.AreEqual(decimal.Parse(requis.Received),    20, "Should not convert db received to issue units for 'S' type supplier");
        }

        [TestMethod]
        [Description("Test that RequisitionLine does not saves outstanding, and received, as issue units (if print in packs is true).")]
        public void IsOutstandingAndReceivedConvertedToPackssWhenPrintInPacksIsTrue()
        {
            const string NSVCode = "ADE223A";
            const int    siteID  = SiteIDA;

            // Set print in packs to true.
            WConfiguration config = new WConfiguration();
            config.LoadBySiteCategorySectionAndKey(siteID, "d|WorkingDefaults", "", "PrintInPacks");
            config[0].Value = "-1";
            config.Save();

            int dssMasterSiteID = linqdb.DSSMasterSiteLinkSites.First(i => i.SiteID == siteID).DSSMasterSiteID.Value;
            int convFact = linqdb.wProducts.First(p => (p.siscode == NSVCode) && (p.DSSMasterSiteID == dssMasterSiteID)).convfact.Value;

            WRequis processor = new WRequis();

            // Test requisition line for W supplier (should not convert from packs to issue units)
            WRequisRow line = processor.Add();
            line.SiteID = siteID;
            line.SupplierType = SupplierType.Ward;
            line.OutstandingInPacks = 10;
            line.ReceivedInPacks    = 20;
            line.NSVCode = NSVCode;
            processor.Save();

            WRequi requis = linqdb.WRequis.First(p => p.WRequisID == line.WRequisID);
            linqdb.Refresh(RefreshMode.OverwriteCurrentValues, requis);

            Assert.AreEqual(decimal.Parse(requis.Outstanding), 10, "Should not convert db outstanding to issue units for 'W' type supplier as PrintInPacks is true");
            Assert.AreEqual(decimal.Parse(requis.Received),    20, "Should not convert db received to issue units for 'W' type supplier as PrintInPacks is true");

            // Test requisition line for L supplier (should convert from packs to issue units)
            line = processor.Add();
            line.SiteID = siteID;
            line.SupplierType = SupplierType.List;
            line.OutstandingInPacks = 10;
            line.ReceivedInPacks    = 20;
            line.NSVCode = NSVCode;
            processor.Save();

            linqdb.Refresh(RefreshMode.OverwriteCurrentValues, requis);

            Assert.AreEqual(decimal.Parse(requis.Outstanding), 10, "Should not convert db outstanding to issue units for 'W' type supplier as PrintInPacks is true");
            Assert.AreEqual(decimal.Parse(requis.Received),    20, "Should not convert db received to issue units for 'W' type supplier as PrintInPacks is true");

            // Test requisition line for S supplier (should not convert from packs to issue units)
            line = processor.Add();
            line.SiteID = siteID;
            line.SupplierType = SupplierType.Stores;
            line.OutstandingInPacks = 10;
            line.ReceivedInPacks    = 20;
            line.NSVCode = NSVCode;
            processor.Save();

            linqdb.Refresh(RefreshMode.OverwriteCurrentValues, requis);

            Assert.AreEqual(decimal.Parse(requis.Outstanding), 10, "Should not convert db outstanding to issue units for 'S' type supplier as PrintInPacks is true");
            Assert.AreEqual(decimal.Parse(requis.Received),    20, "Should not convert db received to issue units for 'S' type supplier as PrintInPacks is true");
        }

        [TestMethod]
        [Description("Checks OutstandingInPacksToWholePackString and ReceivedInPacksToWholePackString works correctly when PrintInPacks is true")]
        public void DoesInPacksToWholePackStringWorksWhenPrintInPacksIsTrue()
        {
            const string NSVCode = "ADE223A";
            const int    siteID  = SiteIDA;

            // Set print in packs to true.
            WConfiguration config = new WConfiguration();
            config.LoadBySiteCategorySectionAndKey(siteID, "d|WorkingDefaults", "", "PrintInPacks");
            config[0].Value = "-1";
            config.Save();

            // Setup RequisitionLine
            WRequis processor = new WRequis();
            WRequisRow line = processor.Add();
            line.RawRow.Table.Columns.Add("SiteProductData_Convfact", typeof(int));
            line.RawRow["SiteProductData_Convfact"] = 3;    // Set the converfactor

            line.SiteID = siteID;
            line.NSVCode = NSVCode;

            line.SupplierType = SupplierType.Ward;
            line.OutstandingInPacks = 100;
            line.ReceivedInPacks = 100;
            Assert.AreEqual("100 x 3", line.OutstandingInPacksToWholePackString());     
            Assert.AreEqual("100 x 3", line.ReceivedInPacksToWholePackString());     

            line.SupplierType = SupplierType.List;
            line.OutstandingInPacks = 100;
            line.ReceivedInPacks = 100;
            Assert.AreEqual("100 x 3", line.OutstandingInPacksToWholePackString());     
            Assert.AreEqual("100 x 3", line.ReceivedInPacksToWholePackString());     

            line.SupplierType = SupplierType.Stores;
            line.OutstandingInPacks = 100;
            line.ReceivedInPacks = 100;
            Assert.AreEqual("100 x 3", line.OutstandingInPacksToWholePackString());     
            Assert.AreEqual("100 x 3", line.ReceivedInPacksToWholePackString());     
        }

        [TestMethod]
        [Description("Checks OutstandingInPacksToWholePackString and ReceivedInPacksToWholePackString works correctly when PrintInPacks is false")]
        public void DoesInPacksToWholePackStringWhenPrintInPacksIsFalse()
        {
            const string NSVCode = "ADE223A";
            const int    siteID  = SiteIDA;

            // Set print in packs to true.
            WConfiguration config = new WConfiguration();
            config.LoadBySiteCategorySectionAndKey(siteID, "d|WorkingDefaults", "", "PrintInPacks");
            config[0].Value = "0";
            config.Save();

            // Setup RequisitionLine
            WRequis processor = new WRequis();
            WRequisRow line = processor.Add();
            line.RawRow.Table.Columns.Add("SiteProductData_Convfact", typeof(int));
            line.RawRow["SiteProductData_Convfact"] = 3;    // Set the converfactor

            line.SiteID = siteID;
            line.NSVCode = NSVCode;

            line.SupplierType = SupplierType.Stores;
            line.SupplierCode = "3A";
            line.OutstandingInPacks = 100;
            line.ReceivedInPacks = 100;
            Assert.AreEqual("100 x 3", line.OutstandingInPacksToWholePackString());     
            Assert.AreEqual("100 x 3", line.ReceivedInPacksToWholePackString());     

            line.SupplierType = SupplierType.Ward;
            line.SupplierCode = "3AW";
            line.OutstandingInPacks = 100;
            line.ReceivedInPacks = 100;
            Assert.AreEqual("300", line.OutstandingInPacksToWholePackString());     
            Assert.AreEqual("300", line.ReceivedInPacksToWholePackString());     

            line.SupplierType = SupplierType.List;
            line.SupplierCode = "3AL";
            line.OutstandingInPacks = 100;
            line.ReceivedInPacks = 100;
            Assert.AreEqual("300", line.OutstandingInPacksToWholePackString());     
            Assert.AreEqual("300", line.ReceivedInPacksToWholePackString());     
        }
    }
}
