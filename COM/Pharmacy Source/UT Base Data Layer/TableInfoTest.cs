using ascribe.pharmacy.basedatalayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Data.SqlClient;
using ascribe.pharmacy.shared;

namespace Unit_Test_Base_Data_Layer
{
    /// <summary>
    ///This is a test class for TableInfoTest and is intended
    ///to contain all TableInfoTest Unit Tests
    ///</summary>
    [TestClass()]
    public class TableInfoTest
    {
        private static int SessionID;           // both relate to rows in the session table

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
            SessionID = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC");
            SessionInfo.InitialiseSession(SessionID);
        }
        
        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}
        //
        //Use TestInitialize to run code before running each test
        //[TestInitialize()]
        //public void MyTestInitialize()
        //{
        //}
        //
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion


        [Description("Test loading in simple table info")]
        [TestMethod()]
        public void TestLoadByTableName()
        {
            TableInfo tableInfo = new TableInfo();
            tableInfo.LoadByTableName("WConfiguration");
            Assert.IsNotNull(tableInfo.FindByName("WConfigurationID"),              "Failed to load in table info");
            Assert.AreEqual("int", tableInfo.FindByName("WConfigurationID").Type,   "Failed to load type info");
            Assert.IsTrue (tableInfo.FindByName("WConfigurationID").IsPK,           "Failed to load pk info");
            Assert.IsFalse(tableInfo.FindByName("WConfigurationID").IsNullable,     "Failed to load nullable info");
        }

        [Description("Test loading in inherited table info")]
        [TestMethod()]
        public void TestLoadByTableNameAndHierarchy()
        {
            TableInfo tableInfo = new TableInfo();
            tableInfo.LoadByTableNameAndHierarchy("user");

            Assert.IsNotNull(tableInfo.FindByName("EntityID"),              "Failed to load in table info");
            Assert.AreEqual("int", tableInfo.FindByName("EntityID").Type,   "Failed to load type info");
            Assert.IsTrue(tableInfo.FindByName("EntityID").IsPK,            "Failed to load pk info");
            Assert.IsFalse(tableInfo.FindByName("EntityID").IsNullable,      "Failed to load nullable info");

            Assert.IsNotNull(tableInfo.FindByName("Username"),                "Failed to load inherited table info");
            Assert.AreEqual("varchar", tableInfo.FindByName("Username").Type, "Failed to load inherited type info");
            Assert.IsFalse(tableInfo.FindByName("Username").IsPK,             "Failed to load pk info");
            Assert.IsFalse(tableInfo.FindByName("Username").IsNullable,       "Failed to load nullable info");

            Assert.IsNotNull(tableInfo.FindByName("TableID"),                "Failed to load child table info");
        }

        [Description("Test the get GetTableID method")]
        [TestMethod()]
        public void TestGetTableID()
        {
            Assert.AreEqual(254, TableInfo.GetTableID("user"), "Failed to read the table ID");
        }

        [Description("Test the get GetTableName method")]
        [TestMethod()]
        public void TestGetTableName()
        {
            Assert.AreEqual("user", TableInfo.GetTableName(254).ToLower(), "Failed to read the table name");
        }
    }
}
