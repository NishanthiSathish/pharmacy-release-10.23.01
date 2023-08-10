//===========================================================================
//
//							      BaseTable2Test.cs
//
//  Holds tests for the BaseTable2 class.
//
//	Modification History:
//	19Dec13 XN  Written
//===========================================================================
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.basedatalayer;
using System.Configuration;
using ascribe.pharmacy.shared;
using System.Data.SqlClient;
using System.Data;
using ascribe.pharmacy.pharmacydatalayer;

namespace Unit_Test_Base_Data_Layer
{
    /// <summary>
    /// Summary description for BaseTable2Test
    /// </summary>
    [TestClass]
    public class BaseTable2Test
    {
        // Used to test the BaseTable2 functions, as need to specifiy table in the BaseColumnInfo class
        private class BaseTable2TestColumnInfo : BaseColumnInfo
        {
            public BaseTable2TestColumnInfo() : base("BaseTable2Test") { }
        }

        // Used to test the BaseTable2TestInherited functions, as need to specifiy table in the BaseColumnInfo class
        private class BaseTable2TestInheritedColumnInfo : BaseColumnInfo
        {
            public BaseTable2TestInheritedColumnInfo() : base("BaseTable2TestInherited") { }
        }

        static int SessionID;           // both relate to rows in the session table
        static int OtherUserSessionID;
        
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
        
        //Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void ClassInitialize(TestContext testContext)
        {
            Configuration conf = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            ConnectionStringsSection connectionStrSect = conf.ConnectionStrings;

            string connectionStr = connectionStrSect.ConnectionStrings["TRNRTL10.My.MySettings.ConnectionString"].ConnectionString;
            linqdb = new TestDBDataContext(connectionStr);

            // Get a sesssion ID (any will do)
            SessionID          = linqdb.ExecuteQuery<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC").First();
            OtherUserSessionID = linqdb.ExecuteQuery<int>("SELECT TOP 1 SessionID FROM Session WHERE SessionID<>{0} ORDER BY SessionID DESC", SessionID).First();

            // Update the session DataLastUsed value
            linqdb.ExecuteCommand("UPDATE Session SET DateLastUsed={0} WHERE SessionID in ({1}, {2})", DateTime.Now, SessionID, OtherUserSessionID);
        
            // Create the temp table
            linqdb.ExecuteCommand("Exec pDrop 'BaseTable2Test'");
            linqdb.ExecuteCommand("CREATE TABLE BaseTable2Test ( BaseTable2TestID int PRIMARY KEY NOT NULL, Description varchar(100) NOT NULL, Description2 varchar(100) NULL, SessionLock int NULL, _Deleted bit NOT NULL DEFAULT(0))");
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTable2TestAll'");
            linqdb.ExecuteCommand("create procedure [pBaseTable2TestAll] ( @CurrentSessionID int ) as begin SELECT * FROM BaseTable2Test WHERE NOT(Description Like 'Do not load') end");

            // Create inherited tables
            linqdb.ExecuteCommand("Exec pDrop 'BaseTable2TestBase'");
            linqdb.ExecuteCommand("CREATE TABLE BaseTable2TestBase ( BaseTable2TestBaseID int PRIMARY KEY NOT NULL, Description varchar(100) NOT NULL)");
            linqdb.ExecuteCommand("Exec pDrop 'BaseTable2TestInherited'");
            linqdb.ExecuteCommand("CREATE TABLE BaseTable2TestInherited ( BaseTable2TestBaseID int PRIMARY KEY NOT NULL, Description2 varchar(100) NOT NULL)");

            linqdb.ExecuteCommand("Exec pDrop 'pBaseTable2TestInheritedAll'");
            linqdb.ExecuteCommand("create procedure [pBaseTable2TestInheritedAll] as begin SELECT * FROM BaseTable2TestBase base JOIN BaseTable2TestInherited inher ON base.BaseTable2TestBaseID =  inher.BaseTable2TestBaseID WHERE NOT(base.Description Like 'Do not load') end");
        }
        
        //Use ClassCleanup to run code after all tests in a class have run
        [ClassCleanup()]
        public static void MyClassCleanup()
        {
            // Remove the temp table
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTable2TestAll'");
            linqdb.ExecuteCommand("Exec pDrop 'BaseTable2Test'");
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTable2TestInheritedAll'");
            linqdb.ExecuteCommand("Exec pDrop 'BaseTable2TestInherited'");
            linqdb.ExecuteCommand("Exec pDrop 'BaseTable2TestBase'");
            linqdb.ExecuteCommand("DELETE FROM SessionAttribute WHERE Attribute Like '%Soft Lock%'");
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
            // Determine directory the test are being run in.
            string assemblyFile = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string assemblyDir = System.IO.Path.GetDirectoryName(assemblyFile);

            // Resets the database
            linqdb.ExecuteCommand("DELETE FROM BaseTable2Test");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2Test (BaseTable2TestID, Description) VALUES (1, 'System')");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2Test (BaseTable2TestID, Description) VALUES (2, 'Stuff')");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2Test (BaseTable2TestID, Description) VALUES (3, 'Stuff2')");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2Test (BaseTable2TestID, Description) VALUES (4, 'Do not load')");

            linqdb.ExecuteCommand("DELETE FROM BaseTable2TestInherited");
            linqdb.ExecuteCommand("DELETE FROM BaseTable2TestBase");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2TestBase (BaseTable2TestBaseID, Description) VALUES (1, 'System')");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2TestBase (BaseTable2TestBaseID, Description) VALUES (2, 'Stuff')");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2TestBase (BaseTable2TestBaseID, Description) VALUES (3, 'Stuff2')");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2TestBase (BaseTable2TestBaseID, Description) VALUES (4, 'Do not load')");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2TestInherited (BaseTable2TestBaseID, Description2) VALUES (1, 'System')");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2TestInherited (BaseTable2TestBaseID, Description2) VALUES (2, 'Stuff')");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2TestInherited (BaseTable2TestBaseID, Description2) VALUES (3, 'Stuff2')");
            linqdb.ExecuteCommand("INSERT INTO BaseTable2TestInherited (BaseTable2TestBaseID, Description2) VALUES (4, 'Do not load')");

            linqdb.ExecuteCommand("DELETE FROM SessionAttribute WHERE Attribute Like '%Soft Lock%'");


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
        [Description("Test hard locking records (BaseTable2)")]
        public void RecordHardLockTest()
        {
            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });
            
            // Check results
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Test db record has had it's SessionLock updated
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTableResult = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTableResult.EnabledRowLocking = true;
            testTableResult.RowLockingOption = LockingOption.HardLock;
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj2 = new PrivateObject(testTableResult);
            obj2.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            int lockCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test WHERE SessionLock = {0}", SessionID).First();
            Assert.AreEqual(testTableResult.Count, lockCount, "Has not locked all rows");

            // Test no other records have been locked
            int otherLockCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test WHERE SessionLock <> {0} AND SessionLock IS NOT NULL", SessionID).First();
            Assert.IsFalse(otherLockCount > 0, "Locked rows that should not be locked");

            // Test nothing is soft lockete
            AssertNoRecordsAreSoftLocked(SessionID);
        }

        [TestMethod()]
        [Description("Test soft locking records (BaseTable2)")]
        public void RecordSoftLockTest()
        {
            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.SoftLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Check results
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Test db record has had it's SessionLock updated
            foreach (var row in testTable)
            {
                string sql = string.Format("SELECT COUNT(*) FROM SessionAttribute WHERE SessionID = {0} AND Attribute = 'BaseTable2Test Soft Lock {1}'", SessionID, row.RawRow["BaseTable2TestID"]);
                if (linqdb.ExecuteQuery<int>(sql).First() != 1)
                    Assert.Fail("Have not locked row " + row.RawRow["BaseTable2TestID"].ToString());
            }

            // Test nothing is soft lockete
            AssertNoRecordsAreHardLocked(SessionID);
        }

        [TestMethod()]
        [Description("Test hard locking single record fails as record already locked  (BaseTable2)")]
        [ExpectedException(typeof(HardLockException))]
        public void SingleRecordHardLockFailureTest()
        {
            // Setup lock on row
            linqdb.ExecuteCommand("UPDATE BaseTable2Test SET SessionLock={0} WHERE BaseTable2TestID = 2", OtherUserSessionID);

            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });
        }


        [TestMethod()]
        [Description("Test soft locking single record fails as record already locked  (BaseTable2)")]
        [ExpectedException(typeof(SoftLockException))]
        public void SingleRecordSoftLockFailureTest()
        {
            // Setup lock on row
            linqdb.ExecuteCommand("INSERT INTO SessionAttribute (SessionID, Attribute, [Value]) VALUES ({0}, {1}, '')", OtherUserSessionID, "BaseTable2Test Soft Lock 2");

            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.SoftLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });
        }

        [TestMethod()]
        [Description("Test hard locking updates local SessionLock field in data set. (BaseTable2)")]
        public void DoesHardLockUpdatesLocalDataSetTest()
        {
            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            if (testTable.Count != 3)
                Assert.Inconclusive("Failed to load correct number of records.");

            // Test record have had their local SessionLock updated
            foreach (BaseRow row in testTable)
                Assert.AreEqual(Convert.ToInt32(row.RawRow["SessionLock"]), SessionID, "Failed to update SessionLock field.");
        }

        [TestMethod()]
        [Description("Test clearing hard record lock using the UnlockRows method (BaseTable2)")]
        public void UnlockTestForHardLockUsingUnlockRowsMethod()
        {
            // Setup lock on a few other rows
            linqdb.ExecuteCommand("UPDATE BaseTable2Test SET SessionLock={0} WHERE Description Like 'Do not load'", OtherUserSessionID);

            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            testTable.UnlockRows();

            // Check results
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Test db record has had it's SessionLock updated
            AssertNoRecordsAreHardLocked(SessionID);
        }

        [TestMethod()]
        [Description("Test clearing soft record lock using the UnlockRows method (BaseTable2)")]
        public void UnlockTestForSoftLockUsingUnlockRowsMethod()
        {
            // Setup lock on a few other rows
            linqdb.ExecuteCommand("INSERT INTO SessionAttribute (SessionID, Attribute, [Value]) VALUES ({0}, {1}, '')", OtherUserSessionID, "BaseTable2Test Soft Lock 4");

            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            testTable.RowLockingOption = LockingOption.SoftLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            testTable.UnlockRows();

            // Check results
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Test db record has had it's SessionLock updated
            AssertNoRecordsAreSoftLocked(SessionID);
        }

        [TestMethod()]
        [Description("Test clearing hard record lock using the BaseTable2.Dispose method.")]
        public void UnlockTestForHardLockUsingDisposeMethod()
        {
            // Setup lock on a few other rows
            linqdb.ExecuteCommand("UPDATE BaseTable2Test SET SessionLock={0} WHERE Description Like 'Do not load'", OtherUserSessionID);

            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Check results
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Test db record has had it's SessionLock updated
            testTable.Dispose();
            AssertNoRecordsAreHardLocked(SessionID);
        }

        [TestMethod()]
        [Description("Test clearing soft record lock using the BaseTable2.Dispose method.")]
        public void UnlockTestForSoftLockUsingDisposeMethod()
        {
            // Setup lock on a few other rows
            linqdb.ExecuteCommand("INSERT INTO SessionAttribute (SessionID, Attribute, [Value]) VALUES ({0}, {1}, '')", OtherUserSessionID, "BaseTable2Test Soft Lock 2");

            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Check results
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Test db record has had it's SessionLock updated
            testTable.Dispose();
            AssertNoRecordsAreSoftLocked(SessionID);
        }

        [TestMethod()]
        [Description("Test BaseTable.CreateEmpty loads the database schema (BaseTable2)")]
        public void TestCreateEmptyLoadsDBSchema()
        {
            string columnName;
            DataColumn column;

            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //table.EnabledRowLocking = true;
            table.RowLockingOption = LockingOption.HardLock;

            PrivateObject obj = new PrivateObject(table);
            obj.Invoke("CreateEmpty");

            // Check results
            Assert.IsNotNull(table.Table, "Failed to create new dataset table.");

            Assert.AreEqual(5, table.Table.Columns.Count, "Failed to create correct number of columns for table ");

            columnName = "BaseTable2TestID";
            column = table.Table.Columns[columnName];
            Assert.IsNotNull(column, "Failed to create dataset column {0}.", columnName);
            Assert.AreEqual(typeof(int), column.DataType, "Failed to set correct type for column {0}.", columnName);

            columnName = "Description";
            column = table.Table.Columns[columnName];
            Assert.IsNotNull(column, "Failed to create dataset column {0}.", columnName);
            Assert.AreEqual(typeof(string), column.DataType, "Failed to set correct type for column {0}.", columnName);

            columnName = "Description2";
            column = table.Table.Columns[columnName];
            Assert.IsNotNull(column, "Failed to create dataset column {0}.", columnName);
            Assert.AreEqual(typeof(string), column.DataType, "Failed to set correct type for column {0}.", columnName);

            columnName = "SessionLock";
            column = table.Table.Columns[columnName];
            Assert.IsNotNull(column, "Failed to create dataset column {0}.", columnName);
            Assert.AreEqual(typeof(int), column.DataType, "Failed to set correct type for column {0}.", columnName);

            columnName = "_Deleted";
            column = table.Table.Columns[columnName];
            Assert.IsNotNull(column, "Failed to create dataset column {0}.", columnName);
            Assert.AreEqual(typeof(bool), column.DataType, "Failed to set correct type for column {0}.", columnName);
        }

        [TestMethod()]
        [Description("Test BaseTable2.CreateEmpty clears all existing data.")]
        public void TestCreateEmptyClearsExistingData()
        {
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //table.EnabledRowLocking = true;
            table.RowLockingOption = LockingOption.HardLock;
            table.Add();

            if (table.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            PrivateObject obj = new PrivateObject(table);
            obj.Invoke("CreateEmpty");

            Assert.AreEqual(0, table.Count, "Failed to remove existing rows when BaseTable2.CreateEmpty is called.");
        }

        [TestMethod()]
        [Description("Test BaseTable2.Clear clears all existing data.")]
        public void TestClearClearsExistingData()
        {
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            testTable.Clear();

            Assert.AreEqual(0, testTable.Count, "Failed to remove existing rows when BaseTable2.Clear is called.");
        }

        [TestMethod()]
        [Description("Test updating an existing row.")]
        public void TestUpdating()
        {
            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            testTable[0].RawRow["Description"] = "Hi";
            testTable.Save();

            // Test results
            BaseTable2<BaseRow, BaseColumnInfo> testTableResult = new BaseTable2<BaseRow, BaseColumnInfo>("BaseTable2Test");
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj2 = new PrivateObject(testTableResult);
            obj2.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            Assert.AreEqual("Hi", testTable[0].RawRow["Description"], "Failed to update BaseTable2Test.Description");
        }

        [TestMethod()]
        [Description("Test deleteing row from the database (BaseTable2)")]
        public void TestDeleteingRows()
        {
            // Load existing rows
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            int tablerowcount = testTable.Count;

            // Get info on rows in the database
            int dbrowcount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test").First();

            // Delete a row
            int deletedID = (int)testTable[0].RawRow["BaseTable2TestID"];
            testTable.Remove(testTable[0]);

            // Test the row has been moved to the delete table
            Assert.AreEqual(tablerowcount - 1, testTable.Count, "Failed to move the selected row from the list.");
            Assert.IsTrue(testTable.FirstOrDefault(r => (int)r.RawRow["BaseTable2TestID"] == deletedID) == null, "Failed to remove correct item for the list.");
            Assert.AreEqual(1, testTable.DeletedItemsTable.Rows.Count, "Failed to move delted row to the delete tables");

            // Save deletes
            testTable.Save();

            // check rows were deleted from the database
            int newCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test").First();
            Assert.AreEqual(dbrowcount - 1, newCount, "Failed to delte selected row from the database");
            Assert.IsTrue(linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test WHERE BaseTable2TestID={0}", deletedID).First() == 0, "Failed to delte correct row from the database");
        }

        [TestMethod()]
        [Description("Test deleteing row from the database for inherited tables (BaseTable2)")]
        public void TestDeleteingRowsInheritedTable()
        {
            // Load existing rows
            BaseTable2<BaseRow, BaseTable2TestInheritedColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestInheritedColumnInfo>("BaseTable2TestInherited", "BaseTable2TestBase");
            
            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestInheritedAll", new List<SqlParameter>() });

            int tablerowcount = testTable.Count;

            // Get info on rows in the database
            int dbrowcountInherited = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2TestInherited").First();
            int dbrowcountBase = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2TestBase").First();

            // Delete a row
            int[] deletedIDs = new int[2];
            deletedIDs[0] = (int)testTable[0].RawRow["BaseTable2TestBaseID"];
            testTable.Remove(testTable[0]);
            deletedIDs[0] = (int)testTable[0].RawRow["BaseTable2TestBaseID"];
            testTable.Remove(testTable[0]);

            // Test the row has been moved to the delete table
            Assert.AreEqual(tablerowcount - 2, testTable.Count, "Failed to move the selected row from the list.");
            Assert.IsFalse(testTable.Any(r => deletedIDs.Contains((int)r.RawRow["BaseTable2TestBaseID"])), "Failed to remove correct item for the list.");
            Assert.AreEqual(2, testTable.DeletedItemsTable.Rows.Count, "Failed to move delted row to the delete tables");

            // Save deletes
            testTable.Save();

            // check rows were deleted from the database
            int newCountInherited = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2TestInherited").First();
            int newCountBase = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2TestBase").First();
            Assert.AreEqual(dbrowcountInherited - 2, newCountInherited, "Failed to delte selected row from the database");
            Assert.AreEqual(dbrowcountBase - 2, newCountBase, "Failed to delte selected row from the database");
            Assert.IsTrue(linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2TestInherited WHERE BaseTable2TestBaseID={0}", deletedIDs[0]).First() == 0, "Failed to delte correct row from the database");
            Assert.IsTrue(linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2TestBase      WHERE BaseTable2TestBaseID={0}", deletedIDs[0]).First() == 0, "Failed to delte correct row from the database");
        }

        [TestMethod()]
        [Description("Test calling DirectDelete to delete row from database (BaseTable2)")]
        public void TestDirectDeleteRows()
        {
            // Get info on rows in the database
            int dbrowcount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test").First();

            // Get pk of row to delete
            int deletedID = linqdb.ExecuteQuery<int>("SELECT TOP 1 BaseTable2TestID FROM BaseTable2Test").First();

            // Delete the row
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.HardLock;
            testTable.DirectDelete(deletedID, false);

            // check rows were deleted from the database
            int newCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test").First();
            Assert.AreEqual(dbrowcount - 1, newCount, "Failed to delte selected row from the database");
            Assert.IsTrue(linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test WHERE BaseTable2TestID={0}", deletedID).First() == 0, "Failed to delte correct row from the database");
        }

        [TestMethod()]
        [Description("Test logically deleteing row from the database (BaseTable2)")]
        public void TestLogicallyDeleteingRows()
        {
            // Load existing rows
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");

            PrivateObject obj = new PrivateObject(testTable);
            obj.SetProperty("UseLogicalDelete", true);

            testTable.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            int tablerowcount = testTable.Count;

            // Get info on rows in the database
            int dbrowcount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test").First();

            // Delete a row
            int deletedID = (int)testTable[0].RawRow["BaseTable2TestID"];
            testTable.Remove(testTable[0]);

            // Test the row has been logically deled
            Assert.AreEqual(tablerowcount - 1, testTable.Count, "Failed to move the selected row from the list.");
            Assert.IsTrue(testTable.FirstOrDefault(r => (int)r.RawRow["BaseTable2TestID"] == deletedID) == null, "Failed to remove correct item for the list.");
            Assert.AreEqual(1, testTable.DeletedItemsTable.Rows.Count, "Failed to move deleted row to the delete tables");

            // Save deletes
            testTable.Save();

            // check rows were deleted from the database
            int newCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test").First();
            Assert.AreEqual(dbrowcount, newCount, "Row has been actualy rather than logically deleted.");
            Assert.IsTrue(linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test WHERE BaseTable2TestID={0} AND _Deleted=1", deletedID).First() == 1, "Failed to delte correct row from the database");
        }

        [TestMethod()]
        [Description("Test calling RemoveAll with no predicate (BaseTable2)")]
        public void TestRemoveAllNoPredicate()
        {
            // Load in some rows
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //table.EnabledRowLocking = true;
            table.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(table);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Get count of all the rows in the list
            int count = table.Count;

            // check there are enough rows to test with
            if (count < 2)
                Assert.Inconclusive("Can't test RemoveAll if there are less than 2 rows loaded.");

            // Remove all the rows
            table.RemoveAll();

            // Test items have been moved to the delete table
            Assert.AreEqual(0, table.Count, "Failed to remove all row from the table object");
            Assert.AreEqual(count, table.DeletedItemsTable.Rows.Count, "Failed to move all items to the delete table.");
        }


        [TestMethod()]
        [Description("Test calling RemoveAll with a predicate (BaseTable2)")]
        public void TestRemoveAllWithAPredicate()
        {
            // Load in some rows
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //table.EnabledRowLocking = true;
            table.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(table);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Get count of all the rows in the list
            int count = table.Count;

            // check there are enough rows to test with
            if (count < 2)
                Assert.Inconclusive("Can't test RemoveAll if there are less than 2 rows loaded.");

            // Remove all the rows under certain conditions
            table.RemoveAll(i => i.RawRow["Description"].ToString().StartsWith("Stuff"));

            // Test items have been moved to the delete table
            Assert.AreEqual(count - 2, table.Count, "Failed to remove all conditional rows from the table object");
            Assert.AreEqual(2, table.DeletedItemsTable.Rows.Count, "Failed to move all conditional rows to the delete table object");
        }


        [TestMethod()]
        [Description("Test calling RemoveAll via a list (BaseTable2)")]
        public void TestRemoveAllViaAlist()
        {
            // Load in some rows
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //table.EnabledRowLocking = true;
            table.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(table);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Get count of all the rows in the list
            int count = table.Count;

            // check there are enough rows to test with
            if (count < 2)
                Assert.Inconclusive("Can't test RemoveAll if there are less than 2 rows loaded.");

            // Remove all the rows under certain conditions
            IEnumerable<BaseRow> itemToRemove = table.Where(i => i.RawRow["Description"].ToString().StartsWith("Stuff")).ToList();
            int itemsToDeleteCount = itemToRemove.Count();
            table.RemoveAll(itemToRemove);

            // Test items have been moved to the delete table
            Assert.AreEqual(count - itemsToDeleteCount, table.Count, "Failed to remove all conditional rows from the table object");
            Assert.AreEqual(itemsToDeleteCount, table.DeletedItemsTable.Rows.Count, "Failed to move all conditional rows to the delete table object");
        }


        [TestMethod()]
        [Description("Test calling RemoveAt (BaseTable2)")]
        public void TestRemoveAt()
        {
            int indexToDelete = 1;

            // Load in some rows
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //table.EnabledRowLocking = true;
            table.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(table);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Get count of all the rows in the list
            int count = table.Count;

            // Get id of item to delete
            int deletedlID = (int)table[indexToDelete].RawRow["BaseTable2TestID"];

            // Delete the item
            table.RemoveAt(indexToDelete);

            // Test items have been moved to the delete table
            Assert.AreEqual(count - 1, table.Count, "Failed to remove row from the table object");
            Assert.AreEqual(1, table.DeletedItemsTable.Rows.Count, "Failed to move row to the delete table object");
            Assert.AreEqual(deletedlID, (int)table.DeletedItemsTable.Rows[0]["BaseTable2TestID", DataRowVersion.Original], "Failed to delete correct row.");
        }


        [TestMethod()]
        [Description("Test calling RemoveRange (BaseTable2)")]
        public void TestRemoveRange()
        {
            // Load in some rows
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //table.EnabledRowLocking = true;
            table.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(table);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Get count of all the rows in the list
            int count = table.Count;

            // Get id of row to delete
            int deletedID1 = (int)table[1].RawRow["BaseTable2TestID"];
            int deletedID2 = (int)table[2].RawRow["BaseTable2TestID"];

            // Remove 2 items at the end of the list
            table.RemoveRange(1, 2);

            // Test items have been moved to the delete table
            Assert.AreEqual(count - 2, table.Count, "Failed to remove rows from the table object");
            Assert.AreEqual(2, table.DeletedItemsTable.Rows.Count, "Failed to move rows to the delete table object");
            Assert.AreEqual(deletedID1, (int)table.DeletedItemsTable.Rows[0]["BaseTable2TestID", DataRowVersion.Original], "Failed to delete correct row.");
            Assert.AreEqual(deletedID2, (int)table.DeletedItemsTable.Rows[1]["BaseTable2TestID", DataRowVersion.Original], "Failed to delete correct row.");
        }


        [TestMethod()]
        [Description("Test calling Remove for item that has been inserted, causes the row to be completed deleted (BaseTable2)")]
        public void TestRemoveInsertedRow()
        {
            // Get number of item in the list
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //table.EnabledRowLocking = true;
            table.RowLockingOption = LockingOption.HardLock;

            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(table);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            int count = table.Count;

            // Insert a row
            BaseRow insertedRow = table.Add();
            table.Remove(insertedRow);
            table.Save();

            Assert.AreEqual(count, table.Count, "Failed to remove correct");
            Assert.AreEqual(0, table.DeletedItemsTable.Rows.Count, "Has moved inserted row to the delete table when it should not.");
        }

        [TestMethod()]
        [Description("Test that update only updates altered fields (BaseTable2)")]
        public void OnlyUpdatesAlteredFields()
        {
            List<SqlParameter> parameters;

            // Load in some rows (table 1)
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table1 = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(table1);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Alter the content of row in table
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table2 = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj2 = new PrivateObject(table2);
            obj2.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            table2.First().RawRow["Description2"] = "Hi";
            table2.Save();

            // Alter contents for table 1
            table1.First().RawRow["Description"] = "Freddy";
            table1.Save();

            // Reload and check
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            Assert.AreEqual("Freddy", table1.First().RawRow["Description"], "Has not saved table 1 changes");
            Assert.AreEqual("Hi", table1.First().RawRow["Description2"], "Has overwritten changes made by other users");
        }

        [TestMethod()]
        [Description("Test ConflictOption.CompareAllSearchableValues won't overwrite other user's changes (BaseTable2)")]
        [ExpectedException(typeof(DBConcurrencyException))]
        public void WontOverwriteOtherUserChanges()
        {
            List<SqlParameter> parameters;

            // Load in some rows (table 1)
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table1 = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(table1);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Alter the content of row in table
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table2 = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj2 = new PrivateObject(table2);
            obj2.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            table2.First().RawRow["Description"] = "Hi";
            table2.Save();

            // Alter contents for table 1
            table1.ConflictOption = ConflictOption.CompareAllSearchableValues;
            table1.First().RawRow["Description"] = "Freddy";
            table1.Save();
        }

        [TestMethod()]
        [Description("Test ConflictOption.CompareAllSearchableValues will allow updates if different fields have been changed (BaseTable2)")]
        public void AllowsUpdatesIfDifferentFieldsHaveChanged()
        {
            List<SqlParameter> parameters;

            // Load in some rows (table 1)
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table1 = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(table1);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Alter the content of row in table
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> table2 = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj2 = new PrivateObject(table2);
            obj2.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            table2.First().RawRow["Description2"] = "Hi";
            table2.Save();

            // Alter contents for table 1
            table1.ConflictOption = ConflictOption.CompareAllSearchableValues;
            table1.First().RawRow["Description"] = "Freddy";
            table1.Save();

            // Reload and check
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            Assert.AreEqual("Freddy", table1.First().RawRow["Description"], "Has not saved table 1 changes");
            Assert.AreEqual("Hi", table1.First().RawRow["Description2"], "Has overwritten changes made by other users");
        }

        [TestMethod()]
        [Description("Test hard locking with append (BaseTable2)")]
        public void HardLockingAppendedRows()
        {
            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Check results
            int originalCount = testTable.Count;
            if (originalCount == 0)
                Assert.Inconclusive("Failed to load any records");

            // Check new load method sets all rows to correct state
            foreach (var row in testTable)
                Assert.AreEqual(DataRowState.Unchanged, row.RawRow.RowState);

            obj.Invoke("LoadBySQL", new object[] { true, "SELECT * FROM BaseTable2Test WHERE BaseTable2TestID=4" });

            if (originalCount + 1 != testTable.Count)
                Assert.Inconclusive("Failed to append record");

            int lockCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test WHERE SessionLock = {0}", SessionID).First();
            Assert.AreEqual(testTable.Count, lockCount, "Has not locked all rows");

            // Check new load method sets all rows to correct state
            foreach (var row in testTable)
                Assert.AreEqual(DataRowState.Unchanged, row.RawRow.RowState);
        }

        [TestMethod()]
        [Description("Test soft locking with append (BaseTable2)")]
        public void SoftLockingAppendedRows()
        {
            // Test
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            //testTable.EnabledRowLocking = true;
            testTable.RowLockingOption = LockingOption.SoftLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Check results
            int originalCount = testTable.Count;
            if (originalCount == 0)
                Assert.Inconclusive("Failed to load any records");

            // Check new load method sets all rows to correct state (not really important for soft lock)
            foreach (var row in testTable)
                Assert.AreEqual(DataRowState.Unchanged, row.RawRow.RowState);

            obj.Invoke("LoadBySQL", new object[] { true, "SELECT * FROM BaseTable2Test WHERE BaseTable2TestID=4" });

            if (originalCount + 1 != testTable.Count)
                Assert.Inconclusive("Failed to append record");

            int lockCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test").First();
            Assert.AreEqual(testTable.Count, lockCount, "Has not locked all rows");

            // Check new load method sets all rows to correct state (not really important for soft lock)
            foreach (var row in testTable)
                Assert.AreEqual(DataRowState.Unchanged, row.RawRow.RowState);
        }

        [TestMethod()]
        [Description("Changing from a soft to a hard lock")]
        public void TestChangingFromSoftToHardLock()
        {
            // Load and soft lock data
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            testTable.RowLockingOption = LockingOption.SoftLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // test loading of any records
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Change to hard lock and reload
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));
            testTable.RowLockingOption = LockingOption.HardLock;

            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Check there are no soft locks
            AssertNoRecordsAreSoftLocked(SessionID);

            // Check there is a hard locks
            int count = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test WHERE SessionLock={0}", SessionID).First();
            Assert.AreEqual(testTable.Count, count, "Has not hard locked all rows");
        }

        [TestMethod()]
        [Description("Changing from a hard to a soft lock")]
        public void TestChangingFromHardToSoftLock()
        {
            // Load and soft lock data
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            testTable.RowLockingOption = LockingOption.HardLock;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // test loading of any records
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Change to hard lock and reload
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));
            testTable.RowLockingOption = LockingOption.SoftLock;

            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            // Check there are no soft locks
            AssertNoRecordsAreHardLocked(SessionID);

            // Check there is a hard locks
            int count = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM SessionAttribute WHERE SessionID={0} AND Attribute Like {1}", SessionID, "BaseTable2Test Soft Lock %").First();
            Assert.AreEqual(testTable.Count, count, "Has not hard locked all rows");
        }

        [TestMethod()]
        [Description("Test reading and writing tabel to XML")]
        public void ReadingAndWritingToXML()
        {
            // Load and soft lock data
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            testTable.RowLockingOption = LockingOption.SoftLock;
            testTable.ConflictOption = ConflictOption.CompareAllSearchableValues;
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            testTable.RemoveAt(0); // test handles delete table correctly

            // Write xml
            string xml = testTable.WriteXml();

            // Read xml to new object
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable2 = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            testTable2.ReadXml(xml);

            PrivateObject obj2 = new PrivateObject(testTable2);
            LockResults lr = (LockResults)obj.GetField("lockResults");
            LockResults lr2 = (LockResults)obj2.GetField("lockResults");

            Assert.AreEqual(testTable.RowLockingOption, testTable2.RowLockingOption, "Fails to store row locking to xml");
            Assert.AreEqual(testTable.ConflictOption, testTable2.ConflictOption, "Fails to store conflict option to xml");
            Assert.AreEqual(lr.GetType().Name, lr2.GetType().Name, "Fails to store lock results type to xml");
            Assert.AreEqual(lr.TableName, lr2.TableName, "Fails to store lock results table name to xml");
            Assert.AreEqual(testTable.Table.Rows.Count, testTable2.Table.Rows.Count, "Test that table has same number of rows");
            Assert.AreEqual(testTable.DeletedItemsTable.Rows.Count, testTable2.DeletedItemsTable.Rows.Count, "Test that table has same number of deleted rows");
        }

        [TestMethod()]
        [Description("Test PreventUnlockOnDispose flag")]
        public void TestPreventUnlockOnDispose()
        {
            BaseTable2<BaseRow, BaseTable2TestColumnInfo> testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            List<SqlParameter> parameters;
            int actualCount;
            int expectedCount;

            Assert.IsFalse(testTable.PreventUnlockOnDispose, "Should default to unlocking on dispose being enabled");

            // Test if PreventPreventUnlockOnDispose = false unlocks rows on dispose for soft lock
            testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));
            testTable.RowLockingOption = LockingOption.SoftLock;
            testTable.PreventUnlockOnDispose = false;

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            testTable.Dispose();
            AssertNoRecordsAreSoftLocked(SessionID);

            // Test if PreventPreventUnlockOnDispose = false unlocks rows on dispose for hard lock
            testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));
            testTable.RowLockingOption = LockingOption.HardLock;
            testTable.PreventUnlockOnDispose = false;

            obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            testTable.Dispose();
            AssertNoRecordsAreHardLocked(SessionID);

            // Test if PreventPreventUnlockOnDispose = true unlocks rows on dispose for soft lock
            testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));
            testTable.RowLockingOption = LockingOption.SoftLock;
            testTable.PreventUnlockOnDispose = true;

            obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            expectedCount = testTable.Count;
            testTable.Dispose();
            actualCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM SessionAttribute WHERE SessionID={0} AND Attribute Like 'BaseTable2Test Soft Lock %'", SessionID).First();
            Assert.AreEqual(expectedCount, actualCount, "Has removed lock on dispose when it should not have.");

            // Test if PreventPreventUnlockOnDispose = true unlocks rows on dispose for hard lock
            testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));
            testTable.RowLockingOption = LockingOption.HardLock;
            testTable.PreventUnlockOnDispose = true;

            obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            expectedCount = testTable.Count;
            testTable.Dispose();
            actualCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test WHERE SessionLock={0}", SessionID).First();
            Assert.AreEqual(expectedCount, actualCount, "Has removed lock on dispose when it should not have.");
        }

        [TestMethod()]
        [Description("Test Sort by Asc")]
        public void TestSortAsc()
        {
            var testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            testTable.Sort("Description ASC");

            Assert.AreEqual("Stuff", testTable[0].RawRow["Description"].ToString());
            Assert.AreEqual("Stuff2", testTable[1].RawRow["Description"].ToString());
            Assert.AreEqual("System", testTable[2].RawRow["Description"].ToString());
        }

        [TestMethod()]
        [Description("Test Sort by Desc")]
        public void TestSortDesc()
        {
            var testTable = new BaseTable2<BaseRow, BaseTable2TestColumnInfo>("BaseTable2Test");
            var parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("CurrentSessionID", SessionID));

            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("LoadBySP", new object[] { "pBaseTable2TestAll", parameters });

            testTable.Sort("Description Desc");

            Assert.AreEqual("System", testTable[0].RawRow["Description"].ToString());
            Assert.AreEqual("Stuff2", testTable[1].RawRow["Description"].ToString());
            Assert.AreEqual("Stuff", testTable[2].RawRow["Description"].ToString());
        }

        /// <summary>
        /// Asserts if any product stock records are hard locked 
        /// (has SessiionLock field set to specified session ID)
        /// </summary>
        /// <param name="SessionID">Session ID to test for</param>
        private void AssertNoRecordsAreHardLocked(int SessionID)
        {
            int lockRowCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTable2Test WHERE SessionLock={0}", SessionID).First();
            Assert.IsTrue(lockRowCount == 0, "Locked rows that should not be locked");
        }

        /// <summary>
        /// Asserts if any product stock records are soft locked 
        /// (has SessiionLock field set to specified session ID)
        /// </summary>
        /// <param name="SessionID">Session ID to test for</param>
        private void AssertNoRecordsAreSoftLocked(int SessionID)
        {
            int lockRowCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM SessionAttribute WHERE SessionID={0} AND Attribute Like 'BaseTable2Test Soft Lock %'", SessionID).First();
            Assert.IsTrue(lockRowCount == 0, "Locked rows that should not be locked");
        }
    }
}
