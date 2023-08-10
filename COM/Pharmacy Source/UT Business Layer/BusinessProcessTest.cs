//===========================================================================
//
//							    BusinessProcessTest.cs
//
//  Holds tests for the BusinessProcess class.
//
//  Test should be run from within Visual Studio.  
//
//	Modification History:
//	15Apr09 XN  Written
//  27Apr09 XN  Updated test for resent changes to locking.
//              Created instance of HttpContext on test initialisation, to 
//              allow the pharmacy data cache to work.
//===========================================================================
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.shared;
using System.Text;

namespace Unit_Test_Business_Layer
{
    [TestClass()]
    public class BusinessProcessTest
    {
        // Used to test the BusinessProcess functions, as need to specifiy table in the BaseColumnInfo class
        private class BaseTableTestColumnInfo : BaseColumnInfo
        {
            public BaseTableTestColumnInfo() : base("BaseTableTest") { }
        }

        private static int SessionID;            // both relate to rows in the session table
        private static int OtherUserSessionID;

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
        //You can use the following additional attributes as you write your tests:
        
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
        
            // Create the temp table
            linqdb.ExecuteCommand("Exec pDrop 'BaseTableTest'");
            linqdb.ExecuteCommand("CREATE TABLE BaseTableTest ( BaseTableTestID int PRIMARY KEY NOT NULL, Description varchar(100) NOT NULL, SessionLock int NULL)");
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestAll'");
            linqdb.ExecuteCommand("create procedure [pBaseTableTestAll] ( @CurrentSessionID int ) as begin SELECT * FROM BaseTableTest WHERE NOT(Description Like 'Do not load') end");
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestUpdate'");
            linqdb.ExecuteCommand("create procedure [pBaseTableTestUpdate] ( @CurrentSessionID int, @BaseTableTestID int, @Description varchar(100), @SessionLock int) as begin UPDATE [BaseTableTest] SET [Description] = @Description, [SessionLock]=@SessionLock WHERE [BaseTableTestID] = @BaseTableTestID END");
        }
        
        //Use ClassCleanup to run code after all tests in a class have run
        [ClassCleanup()]
        public static void MyClassCleanup()
        {
            // Remove the temp table
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestAll'");
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestUpdate'");
            linqdb.ExecuteCommand("Exec pDrop 'BaseTableTest'");
        }
        
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

            // Resets the database
            linqdb.ExecuteCommand("DELETE FROM BaseTableTest");
            linqdb.ExecuteCommand("INSERT INTO BaseTableTest (BaseTableTestID, Description) VALUES (1, 'System')");
            linqdb.ExecuteCommand("INSERT INTO BaseTableTest (BaseTableTestID, Description) VALUES (2, 'Stuff')");
            linqdb.ExecuteCommand("INSERT INTO BaseTableTest (BaseTableTestID, Description) VALUES (3, 'Stuff2')");
            linqdb.ExecuteCommand("INSERT INTO BaseTableTest (BaseTableTestID, Description) VALUES (4, 'Do not load')");

            // Initalise the SessionInfo class
            SessionInfo.InitialiseSession(SessionID);
        }
        
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion


        [TestMethod()]
        [Description("Test locking records.")]
        public void RecordLockTest()
        {
            // Load in records for locking
            var testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadRecordSetStream", new object[] { "pBaseTableTestAll", new StringBuilder() });

            // Test
            BusinessProcess processor = new BusinessProcess(); 

            PrivateObject obj2 = new PrivateObject(processor);
            obj2.Invoke("LockRows", new object[] { testTable.Table, testTable.TableName, testTable.PKColumnName });

            // Test db record has had it's SessionLock updated
            AssertRecordsAreLocked(SessionID, testTable);

            // Test no other records have been locked
            AssertRecordsAreNotLocked(SessionID, testTable);
        }

        [TestMethod()]
        [Description("Test locking updates local SessionLock field in data set.")]
        public void RecordLockUpdatesLocalDataSetTest()
        {
            // Load in records for locking
            var testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID");

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadRecordSetStream", new object[] { "pBaseTableTestAll", new StringBuilder() });

            if (testTable.Count != 3)
                Assert.Inconclusive("Failed to load correct number of records.");

            // Test
            BusinessProcess processor = new BusinessProcess();

            PrivateObject obj2 = new PrivateObject(processor);
            obj2.Invoke("LockRows", new object[] { testTable.Table, testTable.TableName, testTable.PKColumnName });

            // Test record have had their local SessionLock updated
            foreach (var row in testTable)
                Assert.AreEqual(Convert.ToInt32(row.RawRow["SessionLock"]), SessionID, "Failed to update SessionLock field.");
        }

        [TestMethod()]
        [Description("Test locking single record fails if record already locked.")]
        [ExpectedException(typeof(HardLockException))]
        public void SingleRecordLockFailureTest()
        {
            // Setup lock on row
            linqdb.ExecuteCommand("UPDATE BaseTableTest SET SessionLock={0} WHERE Description Like 'Stuff%'", OtherUserSessionID);

            // Load in records for locking
            var testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID");

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadRecordSetStream", new object[] { "pBaseTableTestAll", new StringBuilder() });

            // Test
            BusinessProcess processor = new BusinessProcess();

            PrivateObject obj2 = new PrivateObject(processor);
            obj2.Invoke("LockRows", new object[] { testTable.Table, testTable.TableName, testTable.PKColumnName });
        }

        [TestMethod()]
        [Description("Test clearing record lock using the UnlockRows method.")]
        public void UnlockTestUsingUnlockRowsMethod()
        {
            int otherSessionID = SessionID + 1;

            // Setup lock on a few other rows
            var countLockedRows = linqdb.ExecuteCommand("UPDATE BaseTableTest SET SessionLock={0} WHERE Description Like 'Do not load'", otherSessionID);

            // Load in records for locking
            var testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID");

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadRecordSetStream", new object[] { "pBaseTableTestAll", new StringBuilder() });

            // Test
            BusinessProcess processor = new BusinessProcess();
            PrivateObject obj2 = new PrivateObject(processor);
            obj2.Invoke("LockRows", new object[] { testTable.Table, testTable.TableName, testTable.PKColumnName });
            obj2.Invoke("UnlockRows");

            // Check results
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Test db record has had it's SessionLock updated
            AssertRecordsAreNotLocked(SessionID, testTable);

            // Check other rows were not unlocked            
            var currentlyLockedCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTableTest WHERE SessionLock={0}", otherSessionID).First();
            Assert.AreEqual(countLockedRows, currentlyLockedCount, "Has unlocked rows that the process did not initially lock.");
        }

        [TestMethod()]
        [Description("Test clearing record lock using the BaseTable.Dispose method.")]
        public void UnlockTestUsingDisposeMethod()
        {
            int otherSessionID = SessionID + 1;

            // Setup lock on a few other rows
            var countLockedRows = linqdb.ExecuteCommand("UPDATE BaseTableTest SET SessionLock={0} WHERE Description Like 'Do not load'", otherSessionID);

            // Load in records for locking
            var testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID");

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadRecordSetStream", new object[] { "pBaseTableTestAll", new StringBuilder() });

            // Test
            BusinessProcess processor = new BusinessProcess();
            PrivateObject obj2 = new PrivateObject(processor);
            obj2.Invoke("LockRows", new object[] { testTable.Table, testTable.TableName, testTable.PKColumnName });

            // Check results
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Test db record has had it's SessionLock updated
            AssertRecordsAreNotLocked(SessionID, testTable);

            // Check other rows were not unlocked            
            var currentlyLockedCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTableTest WHERE SessionLock={0}", otherSessionID).First();
            Assert.AreEqual(countLockedRows, currentlyLockedCount, "Has unlocked rows that the process did not initially lock.");
        }

        /// <summary>
        /// Asserts if a record does not have a lock (does not have it's 
        /// SessionLock field set to specified session ID).
        /// The test is performed against the actual db records.
        /// </summary>
        /// <param name="SessionID">Session ID to test for</param>
        /// <param name="records">Records to test (match to db records)</param>
        private void AssertRecordsAreLocked(int SessionID, IEnumerable<BaseRow> records)
        {
            var ids = records.Select(r => (int)r.RawRow["BaseTableTestID"]);
            var lockedRows = linqdb.ExecuteQuery<int>("SELECT BaseTableTestID FROM BaseTableTest WHERE SessionLock={0}", SessionID);
            Assert.IsTrue(lockedRows.All(b => ids.Contains(b)), "Failed to lock all rows");
        }

        /// <summary>
        /// Asserts if a record is locked (has SessionLock field set to specified session ID).
        /// The test is performed against the actual db records.
        /// </summary>
        /// <param name="SessionID">Session ID to test for</param>
        /// <param name="records">Records to test (match to db records)</param>
        private void AssertRecordsAreNotLocked(int SessionID, IEnumerable<BaseRow> records)
        {
            var ids = records.Select(r => (int)r.RawRow["BaseTableTestID"]);
            var lockedRows = linqdb.ExecuteQuery<int>("SELECT BaseTableTestID FROM BaseTableTest WHERE SessionLock={0}", SessionID);
            Assert.IsFalse(lockedRows.Any(b => !ids.Contains(b)), "Failed to lock all rows");
        }
    }
}
