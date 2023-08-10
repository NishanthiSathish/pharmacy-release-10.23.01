//===========================================================================
//
//							      BaseTableTest.cs
//
//  Holds tests for the BaseTable class.
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
using System.Data;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.shared;
using System.Data.Linq;
using System.Text;

namespace Unit_Test_Base_Data_Layer
{
    /// <summary>
    ///This is a test class for BaseTable and is intended
    ///to contain all BaseTable Unit Tests
    ///</summary>
    [TestClass()]
    public class BaseTableTest
    {
        // Used to test the BaseTable functions, as need to specifiy table in the BaseColumnInfo class
        private class BaseTableTestColumnInfo : BaseColumnInfo
        {
            public BaseTableTestColumnInfo() : base("BaseTableTest") { }
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
        
            // Create the temp table
            linqdb.ExecuteCommand("Exec pDrop 'BaseTableTest'");
            linqdb.ExecuteCommand("CREATE TABLE BaseTableTest ( BaseTableTestID int PRIMARY KEY NOT NULL, Description varchar(100) NOT NULL, SessionLock int NULL)");
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestAll'");
            linqdb.ExecuteCommand("create procedure [pBaseTableTestAll] ( @CurrentSessionID int ) as begin SELECT * FROM BaseTableTest WHERE NOT(Description Like 'Do not load') end");
        }
        
        //Use ClassCleanup to run code after all tests in a class have run
        [ClassCleanup()]
        public static void MyClassCleanup()
        {
            // Remove the temp table
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestAll'");
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
            // Determine directory the test are being run in.
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
            // Test
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTable.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());

            // Check results
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Test db record has had it's SessionLock updated
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTableResult = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTableResult.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());
            int lockCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTableTest WHERE SessionLock = {0}", SessionID).First();
            Assert.AreEqual(testTableResult.Count, lockCount, "Has not locked all rows");

            // Test no other records have been locked
            int otherLockCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTableTest WHERE SessionLock <> {0} AND SessionLock IS NOT NULL", SessionID).First();
            Assert.IsFalse(otherLockCount > 0, "Locked rows that should not be locked");
        }

        [TestMethod()]
        [Description("Test locking single record fails as record already locked.")]
        [ExpectedException(typeof(HardLockException))]
        public void SingleRecordLockFailureTest()
        {
            // Setup lock on row
            linqdb.ExecuteCommand("UPDATE BaseTableTest SET SessionLock={0} WHERE BaseTableTestID = 2", OtherUserSessionID);

            // Test
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTable.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());
        }

        [TestMethod()]
        [Description("Test locking updates local SessionLock field in data set.")]
        public void RecordLockUpdatesLocalDataSetTest()
        {
            // Test
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTable.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());

            if (testTable.Count != 3)
                Assert.Inconclusive("Failed to load correct number of records.");

            // Test record have had their local SessionLock updated
            foreach(BaseRow row in testTable)
                Assert.AreEqual(Convert.ToInt32(row.RawRow["SessionLock"]), SessionID, "Failed to update SessionLock field.");
        }

        [TestMethod()]
        [Description("Test clearing record lock using the UnlockRows method.")]
        public void UnlockTestUsingUnlockRowsMethod()
        {
            // Setup lock on a few other rows
            linqdb.ExecuteCommand("UPDATE BaseTableTest SET SessionLock={0} WHERE Description Like 'Do not load'", OtherUserSessionID);

            // Test
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTable.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());
            testTable.UnlockRows();

            // Check results
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Test db record has had it's SessionLock updated
            AssertNoRecordsAreLocked(SessionID);
        }

        [TestMethod()]
        [Description("Test clearing record lock using the BaseTable.Dispose method.")]
        public void UnlockTestUsingDisposeMethod()
        {
            // Setup lock on a few other rows
            linqdb.ExecuteCommand("UPDATE BaseTableTest SET SessionLock={0} WHERE Description Like 'Do not load'", OtherUserSessionID);

            // Test
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTable.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());
            testTable.Dispose();

            // Check results
            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            // Test db record has had it's SessionLock updated
            AssertNoRecordsAreLocked(SessionID);
        }

        [TestMethod()]
        [Description("Test BaseTable.CreateEmpty loads the database schema.")]
        public void TestCreateEmptyLoadsDBSchema()
        {
            string columnName;
            DataColumn column;

            // Test
            BaseTable<BaseRow, BaseTableTestColumnInfo> table = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);

            PrivateObject obj = new PrivateObject(table);
            obj.Invoke("CreateEmpty");

            // Check results
            Assert.IsNotNull(table.Table, "Failed to create new dataset table.");

            Assert.AreEqual(3, table.Table.Columns.Count, "Failed to create correct number of columns for table ");

            columnName = "BaseTableTestID";
            column = table.Table.Columns[columnName];
            Assert.IsNotNull(column, "Failed to create dataset column {0}.", columnName);
            Assert.AreEqual(typeof(int), column.DataType, "Failed to set correct type for column {0}.", columnName);

            columnName = "Description";
            column = table.Table.Columns[columnName];
            Assert.IsNotNull(column, "Failed to create dataset column {0}.", columnName);
            Assert.AreEqual(typeof(string), column.DataType, "Failed to set correct type for column {0}.", columnName);

            columnName = "SessionLock";
            column = table.Table.Columns[columnName];
            Assert.IsNotNull(column, "Failed to create dataset column {0}.", columnName);
            Assert.AreEqual(typeof(int), column.DataType, "Failed to set correct type for column {0}.", columnName);
        }

        [TestMethod()]
        [Description("Test BaseTable.CreateEmpty clears all existing data.")]
        public void TestCreateEmptyClearsExistingData()
        {
            BaseTable<BaseRow, BaseTableTestColumnInfo> table = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            table.Add();

            if (table.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            PrivateObject obj = new PrivateObject(table);
            obj.Invoke("CreateEmpty");

            Assert.AreEqual(0, table.Count, "Failed to remove existing rows when BaseTable.CreateEmpty is called.");
        }

        [TestMethod()]
        [Description("Test BaseTable.CreateEmpty throws ApplicationException for invalid table name.")]
        [ExpectedException(typeof(ApplicationException))]
        public void TestCreateEmptyErrorsForInvalidTableName()
        {
            BaseTable<ProductStockRow, BaseColumnInfo> testTable = new BaseTable<ProductStockRow,BaseColumnInfo>("ProductStok", "ProductStockID");
            PrivateObject obj = new PrivateObject(testTable);
            obj.Invoke("CreateEmpty");
        }

        [TestMethod()]
        [Description("Test BaseTable.Clear clears all existing data.")]
        public void TestClearClearsExistingData()
        {
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTable.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());

            if (testTable.Count == 0)
                Assert.Inconclusive("Failed to load any records");

            testTable.Clear();

            Assert.AreEqual(0, testTable.Count, "Failed to remove existing rows when BaseTable.Clear is called.");
        }

        [TestMethod()]
        [Description("Test updating an existing row.")]
        public void TestUpdating()
        {
            // Create the update sp
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestUpdate'");
            linqdb.ExecuteCommand("create procedure [pBaseTableTestUpdate] ( @CurrentSessionID int, @BaseTableTestID int, @Description varchar(100)) as begin UPDATE [BaseTableTest] SET [Description] = @Description WHERE [BaseTableTestID] = @BaseTableTestID END");

            // Test
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTable = new BaseTable<BaseRow,BaseTableTestColumnInfo>("BaseRowTest", "BaseRowTestID");
            testTable.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());

            PrivateObject obj = new PrivateObject(testTable);
            obj.SetProperty("UpdateSP", "pBaseTableTestUpdate");
            
            testTable[0].RawRow["Description"] = "Hi";
            testTable.Save();

            // Test results
            BaseTable<BaseRow, BaseColumnInfo> testTableResult = new BaseTable<BaseRow,BaseColumnInfo>("BaseRowTest", "BaseRowTestID");
            testTableResult.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());
            Assert.AreEqual("Hi", testTable[0].RawRow["Description"], "Failed to update BaseRowTest.Description");
        }

        [TestMethod()]
        [Description("Test updating an existing row with sp that does not include a SessionLocking field.")]
        public void TestUpdatingWithoutSessionLockField()
        {
            // Create the update sp
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestUpdate'");
            linqdb.ExecuteCommand("create procedure [pBaseTableTestUpdate] ( @CurrentSessionID int, @BaseTableTestID int, @Description varchar(100)) as begin UPDATE [BaseTableTest] SET [Description] = @Description WHERE [BaseTableTestID] = @BaseTableTestID END");

            // Load existing rows
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTable.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());
            testTable[0].RawRow["Description"] = "A Stuff";

            // Set the class to not include the session lock on update, and also select a non session locking table.
            PrivateObject obj = new PrivateObject(testTable);
            obj.SetProperty("UpdateSP", "pBaseTableTestUpdate");
            obj.SetProperty("IncludeSessionLockInUpdate", false);

            testTable.Save();

            // Test results
            BaseTable<BaseRow, BaseColumnInfo> testTableResult = new BaseTable<BaseRow, BaseColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTableResult.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());
            Assert.AreEqual("A Stuff", testTableResult[0].RawRow["Description"], "Failed to update ProductStock.Cost");

            // Tidy up db
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestUpdate'");
        }


        [TestMethod()]
        [Description("Test updating an existing row with sp that does include a SessionLocking field.")]
        public void TestUpdatingWithSessionLockField()
        {
            // Create the sp
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestUpdate'");
            linqdb.ExecuteCommand("create procedure [pBaseTableTestUpdate] ( @CurrentSessionID int, @BaseTableTestID int, @Description varchar(100), @SessionLock int) as begin UPDATE [BaseTableTest] SET [Description] = @Description, [SessionLock]=@SessionLock WHERE [BaseTableTestID] = @BaseTableTestID END");

            // Load existing rows
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTable.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());
            testTable[0].RawRow["Description"] = "A Stuff";

            // Set the class to not include the session lock on update, and also select a non session locking table.
            PrivateObject obj = new PrivateObject(testTable);
            obj.SetProperty("UpdateSP", "pBaseTableTestUpdate");
            obj.SetProperty("IncludeSessionLockInUpdate", true);

            testTable.Save();

            // Test results
            BaseTable<BaseRow, BaseColumnInfo> testTableResult = new BaseTable<BaseRow, BaseColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTableResult.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());
            Assert.AreEqual("A Stuff", testTableResult[0].RawRow["Description"], "Failed to update ProductStock.Cost");

            // Tidy up db
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestUpdate'");
        }


        [TestMethod()]
        [Description("Test deleteing row from the database.")]
        public void TestDeleteingRows()
        {
            // Create the delete sp
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestDelete'");
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestXML'");
            linqdb.ExecuteCommand("create procedure [pBaseTableTestDelete] ( @CurrentSessionID int, @BaseTableTestID int ) as begin DELETE FROM BaseTableTest WHERE BaseTableTestID=@BaseTableTestID end");
            linqdb.ExecuteCommand("create procedure pBaseTableTestXML(@CurrentSessionID int, @BaseTableTestID int) as begin SELECT * FROM BaseTableTest WHERE BaseTableTestID=@BaseTableTestID FOR XML AUTO end");

            // Load existing rows
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTable.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());
            int tablerowcount = testTable.Count;
            
            // Get info on rows in the database
            int dbrowcount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTableTest").First();

            // Delete a row
            int deletedID = (int)testTable[0].RawRow["BaseTableTestID"];
            testTable.Remove(testTable[0]);

            // Test the row has been moved to the delete table
            Assert.AreEqual(tablerowcount - 1, testTable.Count, "Failed to move the selected row from the list.");
            Assert.IsTrue(testTable.FindByID(deletedID) == null, "Failed to remove correct item for the list.");
            Assert.AreEqual(1, testTable.DeletedItemsTable.Rows.Count, "Failed to move delted row to the delete tables");

            // Save deletes
            testTable.Save();

            // check rows were deleted from the database
            int newCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTableTest").First();
            Assert.AreEqual(dbrowcount - 1, newCount, "Failed to delte selected row from the database");
            Assert.IsTrue(linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTableTest WHERE BaseTableTestID={0}", deletedID).First() == 0, "Failed to delte correct row from the database");

            // Tidy up db
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestDelete'");
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestXML'");
        }


        [TestMethod()]
        [Description("Test calling DirectDelete to delete row from database.")]
        public void TestDirectDeleteRows()
        {
            // Create the sp
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestDelete'");
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestXML'");
            linqdb.ExecuteCommand("create procedure [pBaseTableTestDelete] ( @CurrentSessionID int, @BaseTableTestID int ) as begin DELETE FROM BaseTableTest WHERE BaseTableTestID=@BaseTableTestID end");
            linqdb.ExecuteCommand("create procedure pBaseTableTestXML(@CurrentSessionID int, @BaseTableTestID int) as begin SELECT * FROM BaseTableTest WHERE BaseTableTestID=@BaseTableTestID FOR XML AUTO end");

            // Get info on rows in the database
            int dbrowcount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTableTest").First();

            // Get pk of row to delete
            int deletedID = linqdb.ExecuteQuery<int>("SELECT TOP 1 BaseTableTestID FROM BaseTableTest").First();

            // Delete the row
            BaseTable<BaseRow, BaseTableTestColumnInfo> testTable = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            testTable.DirectDelete(deletedID, false);

            // check rows were deleted from the database
            int newCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTableTest").First();
            Assert.AreEqual(dbrowcount - 1, newCount, "Failed to delte selected row from the database");
            Assert.IsTrue(linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTableTest WHERE BaseTableTestID={0}", deletedID).First() == 0, "Failed to delte correct row from the database");

            // Tidy up db
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestDelete'");
            linqdb.ExecuteCommand("Exec pDrop 'pBaseTableTestXML'");
        }


        [TestMethod()]
        [Description("Test calling RemoveAll with no predicate.")]
        public void TestRemoveAllNoPredicate()
        {
            // Load in some rows
            BaseTable<BaseRow, BaseTableTestColumnInfo> table = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            table.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());

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
        [Description("Test calling RemoveAll with a predicate.")]
        public void TestRemoveAllWithAPredicate()
        {
            // Load in some rows
            BaseTable<BaseRow, BaseTableTestColumnInfo> table = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            table.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());

            // Get count of all the rows in the list
            int count = table.Count;

            // check there are enough rows to test with
            if (count < 2)
                Assert.Inconclusive("Can't test RemoveAll if there are less than 2 rows loaded.");

            // Remove all the rows under certain conditions
            table.RemoveAll( i => i.RawRow["Description"].ToString().StartsWith("Stuff") );
            
            // Test items have been moved to the delete table
            Assert.AreEqual(count - 2, table.Count, "Failed to remove all conditional rows from the table object");
            Assert.AreEqual(2, table.DeletedItemsTable.Rows.Count, "Failed to move all conditional rows to the delete table object");
        }


        [TestMethod()]
        [Description("Test calling RemoveAll via a list.")]
        public void TestRemoveAllViaAlist()
        {
            // Load in some rows
            BaseTable<BaseRow, BaseTableTestColumnInfo> table = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            table.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());

            // Get count of all the rows in the list
            int count = table.Count;

            // check there are enough rows to test with
            if (count < 2)
                Assert.Inconclusive("Can't test RemoveAll if there are less than 2 rows loaded.");

            // Remove all the rows under certain conditions
            IEnumerable<BaseRow> itemToRemove = table.Where( i => i.RawRow["Description"].ToString().StartsWith("Stuff") ).ToList();
            int itemsToDeleteCount = itemToRemove.Count();
            table.RemoveAll(itemToRemove);
            
            // Test items have been moved to the delete table
            Assert.AreEqual(count - itemsToDeleteCount, table.Count, "Failed to remove all conditional rows from the table object");
            Assert.AreEqual(itemsToDeleteCount, table.DeletedItemsTable.Rows.Count, "Failed to move all conditional rows to the delete table object");
        }


        [TestMethod()]
        [Description("Test calling RemoveAt.")]
        public void TestRemoveAt()
        {
            int indexToDelete = 1;

            // Load in some rows
            BaseTable<BaseRow, BaseTableTestColumnInfo> table = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            table.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());

            // Get count of all the rows in the list
            int count = table.Count;

            // Get id of item to delete
            int deletedlID = (int)table[indexToDelete].RawRow["BaseTableTestID"];

            // Delete the item
            table.RemoveAt(indexToDelete);
            
            // Test items have been moved to the delete table
            Assert.AreEqual(count - 1, table.Count, "Failed to remove row from the table object");
            Assert.AreEqual(1, table.DeletedItemsTable.Rows.Count, "Failed to move row to the delete table object");
            Assert.AreEqual(deletedlID, (int)table.DeletedItemsTable.Rows[0]["BaseTableTestID"], "Failed to delete correct row.");
        }


        [TestMethod()]
        [Description("Test calling RemoveRange.")]
        public void TestRemoveRange()
        {
            // Load in some rows
            BaseTable<BaseRow, BaseTableTestColumnInfo> table = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            table.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());

            // Get count of all the rows in the list
            int count = table.Count;

            // Get id of row to delete
            int deletedID1 = (int)table[1].RawRow["BaseTableTestID"];
            int deletedID2 = (int)table[2].RawRow["BaseTableTestID"];

            // Remove 2 items at the end of the list
            table.RemoveRange(1, 2);
            
            // Test items have been moved to the delete table
            Assert.AreEqual(count - 2, table.Count, "Failed to remove rows from the table object");
            Assert.AreEqual(2, table.DeletedItemsTable.Rows.Count, "Failed to move rows to the delete table object");
            Assert.AreEqual(deletedID1, (int)table.DeletedItemsTable.Rows[0]["BaseTableTestID"], "Failed to delete correct row.");
            Assert.AreEqual(deletedID2, (int)table.DeletedItemsTable.Rows[1]["BaseTableTestID"], "Failed to delete correct row.");
        }


        [TestMethod()]
        [Description("Test calling Remove for item that has been inserted, causes the row to be completed deleted.")]
        public void TestRemoveInsertedRow()
        {
            // Get number of item in the list
            BaseTable<BaseRow, BaseTableTestColumnInfo> table = new BaseTable<BaseRow, BaseTableTestColumnInfo>("BaseTableTest", "BaseTableTestID", RowLocking.Enabled);
            table.LoadRecordSetStream("pBaseTableTestAll", new StringBuilder());
            int count = table.Count;

            // Insert a row
            BaseRow insertedRow = table.Add();
            table.Remove(insertedRow);
            table.Save();

            Assert.AreEqual(count, table.Count, "Failed to remove correct");
            Assert.AreEqual(0, table.DeletedItemsTable.Rows.Count, "Has moved inserted row to the delete table when it should not.");
        }

        /// <summary>
        /// Asserts if any product stock records are locked 
        /// (has SessiionLock field set to specified session ID)
        /// </summary>
        /// <param name="SessionID">Session ID to test for</param>
        private void AssertNoRecordsAreLocked(int SessionID)
        {
            int lockRowCount = linqdb.ExecuteQuery<int>("SELECT COUNT(*) FROM BaseTableTest WHERE SessionLock={0}", SessionID).First();
            Assert.IsTrue(lockRowCount == 0, "Locked rows that should not be locked");
        }
    }
}
