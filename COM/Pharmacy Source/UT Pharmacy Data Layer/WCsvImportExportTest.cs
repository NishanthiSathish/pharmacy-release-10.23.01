using ascribe.pharmacy.pharmacydatalayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;
using System.Text;
using System.IO;
using System.Linq;

namespace UT_Pharmacy_Data_Layer
{
    
    
    /// <summary>
    ///This is a test class for WCsvImportExportTest and is intended
    ///to contain all WCsvImportExportTest Unit Tests
    ///</summary>
    [TestClass()]
    public class WCsvImportExportTest
    {
        private static int SessionID;           // both relate to rows in the session table
        private static int routineIdImport;
        private static int routineIdExport;
        private static string FileName;

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

            if (Database.IfTableExists("CsvImportExpotrTest"))
                Database.ExecuteSQLNonQuery("DROP TABLE CsvImportExpotrTest");

            // Create the table to import to
            string sql = "CREATE TABLE [CsvImportExpotrTest]" +
                         "(" +
                             "CsvImportExpotrTestID int IDENTITY(1,1) NOT NULL CONSTRAINT [PK_CsvImportExpotrTest] PRIMARY KEY CLUSTERED (CsvImportExpotrTestID ASC)," +
                             "Description varchar(10) NULL," + 
                             "TestInt1 int NOT NULL,"        + 
                             "TestInt2 int NULL,"            + 
                             "TestDateTime datetime NULL"   + 
                         ")";
            Database.ExecuteSQLNonQuery(sql);

            // Export sp TestDateTime comes before TestInt1
            Database.ExecuteSQLNonQuery("Exec pDrop pCsvImportExpotrTestExport");
            sql = "create procedure [pCsvImportExpotrTestExport]" +
                  "as " + 
                  "begin " + 
                  "   SELECT Description, TestDateTime, TestInt1, TestInt2 FROM CsvImportExpotrTest ORDER BY CsvImportExpotrTestID " + 
                  "end";
            Database.ExecuteSQLNonQuery(sql);
            Database.ExecuteSQLNonQuery("Exec pRoutineSave 'pCsvImportExpotrTestExport', 'Stored procedure', 'CsvImportExpotrTestExport'");
            WCsvImportExportTest.routineIdExport = Database.ExecuteSQLScalar<int>("SELECT RoutineID FROM Routine WHERE Description='CsvImportExpotrTestExport'");


            // Import sp add 1 to TestInt1 and TestInt2
            Database.ExecuteSQLNonQuery("Exec pDrop pCsvImportExpotrTestInsert");
            sql = "create procedure [pCsvImportExpotrTestInsert]" +
	              "(" + 
                  "     @Description varchar(10)" + 
                  ",	@TestInt1 int" + 
                  ",	@TestInt2 int" + 
                  ",	@TestDateTime dateTime" + 
                  ")" + 
                  "as " + 
                  "begin " + 
                  "   INSERT INTO CsvImportExpotrTest (Description, TestInt1, TestInt2, TestDateTime) VALUES (@Description, @TestInt1 + 1, @TestInt2 + 1, @TestDateTime) " + 
                  "end";
            Database.ExecuteSQLNonQuery(sql);
            Database.ExecuteSQLNonQuery("Exec pRoutineSave 'pCsvImportExpotrTestInsert', 'Stored procedure', 'CsvImportExpotrTestInsert'");
            WCsvImportExportTest.routineIdImport = Database.ExecuteSQLScalar<int>("SELECT RoutineID FROM Routine WHERE Description='CsvImportExpotrTestInsert'");

            FileName = Path.Combine(Path.GetTempPath(), Path.GetRandomFileName());
        }
        
        //Use ClassCleanup to run code after all tests in a class have run
        [ClassCleanup()]
        public static void MyClassCleanup()
        {
            Database.ExecuteSQLNonQuery("DROP CONSTRAINT PK_CsvImportExpotrTest");
            Database.ExecuteSQLNonQuery("DROP TABLE CsvImportExpotrTest");
        }
        
        //Use TestInitialize to run code before running each test
        [TestInitialize()]
        public void MyTestInitialize()
        {
            Database.ExecuteSQLNonQuery("DELETE FROM CsvImportExpotrTest");
            Database.ExecuteSQLNonQuery("DELETE FROM WCsvImportExport WHERE DataTypeName='CsvImportExpotrTest'");
        }
        
        //Use TestCleanup to run code after each test has run
        [TestCleanup()]
        public void MyTestCleanup()
        {
        }
        #endregion

        [Description("Test basic import direct to table")]
        [TestMethod()]
        public void TestBasicImportDirectToTable()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, false);
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");

            Assert.AreEqual(2,   Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            Assert.AreEqual(1,   Database.ExecuteSQLScalar<int>("SELECT TestInt1 FROM CsvImportExpotrTest WHERE Description='Test me 1'"), "Failed to import correct data");
            Assert.AreEqual(4,   Database.ExecuteSQLScalar<int>("SELECT TestInt2 FROM CsvImportExpotrTest WHERE Description='Test me 2'"), "Failed to import correct data");
            
            var actualTime = Database.ExecuteSQLScalar<DateTime>("SELECT TestDateTime FROM CsvImportExpotrTest WHERE Description='Test me 2'");
            Assert.IsTrue((now - actualTime).TotalSeconds < 1.0, "Failed to import date time");
        }

        [Description("Test invalid text file")]
        [TestMethod()]
        public void TestInvalidTextFile()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendLine("Hello there");
            str.AppendLine("This is another test");
            str.AppendLine("Of an invalid file");
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, false);
            Assert.IsFalse(importExport[0].ValidateCsv(false, FileName, errors), "Failed to spot invalid file");
            Assert.IsTrue(errors.Count > 0, "Failed to record error message");
        }

        [Description("Test binary file")]
        [TestMethod()]
        public void TestInvalidBinaryFile()
        {
            DateTime now = DateTime.Now;
            
            byte[] file = new byte[256];
            for (int b = 0; b < 256; b++)
                file[b] = (byte)b;
            File.WriteAllBytes(FileName, file);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, false);
            Assert.IsFalse(importExport[0].ValidateCsv(false, FileName, errors), "Failed to spot invalid file");
            Assert.IsFalse(errors.Count == 0, "Failed to record error message");
        }

        [Description("Test import when header missing direct to table")]
        [TestMethod()]
        public void TestImportWhenHeaderMissingDirectToTable()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, false);

            // Will error
            Assert.IsFalse(importExport[0].ValidateCsv(true, FileName, errors), "Not erroring due to missing header row");
            Assert.IsFalse(errors.Count == 0, "No erroring due to missing header row");
        }

        [Description("Test import when with header (in matching column order) direct to table")]
        [TestMethod()]
        public void TestImportWithHeaderInMatchingOrderDirectToTable()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendLine("\"Description\",\"TestInt1\",\"TestInt2\",\"TestDateTime\"");
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, true);
            Assert.IsTrue(importExport[0].ValidateCsv(true, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(true, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
        }

        [Description("Test import when with header (in non matching column order) direct to table")]
        [TestMethod()]
        public void TestImportWithHeaderInNonMatchingOrderDirectToTable()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendLine("\"TestDateTime\",\"Description\",\"TestInt1\",\"TestInt2\"");
            str.AppendFormat("{0:yyyy-MM-dd HH:mm:ss},\"Test me 1\",1,2\n", now);
            str.AppendFormat("{0:yyyy-MM-dd HH:mm:ss},\"Test me 2\",3,4\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, true);
            Assert.IsTrue(importExport[0].ValidateCsv(true, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(true, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            var actualTime = Database.ExecuteSQLScalar<DateTime>("SELECT TestDateTime FROM CsvImportExpotrTest WHERE Description='Test me 2'");
            Assert.IsTrue((now - actualTime).TotalSeconds < 1.0, "Failed to import date time");
        }

        [Description("Test import when with header with odd chars (in non matching column order) direct to table")]
        [TestMethod()]
        public void TestImportWithHeaderOddCharsInNonMatchingOrderDirectToTable()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendLine("\"Test Date Time\",\"<Description>\",\"TestInt1@\",\"#TestInt2\"");
            str.AppendFormat("{0:yyyy-MM-dd HH:mm:ss},\"Test me 1\",1,2\n", now);
            str.AppendFormat("{0:yyyy-MM-dd HH:mm:ss},\"Test me 2\",3,4\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, true);
            Assert.IsTrue(importExport[0].ValidateCsv(true, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(true, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            var actualTime = Database.ExecuteSQLScalar<DateTime>("SELECT TestDateTime FROM CsvImportExpotrTest WHERE Description='Test me 2'");
            Assert.IsTrue((now - actualTime).TotalSeconds < 1.0, "Failed to import date time");
        }

        [Description("Test import when int column is null direct to table")]
        [TestMethod()]
        public void TestImportWhenIntColumnNullDirectToTable()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, false);
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            Assert.IsNull(Database.ExecuteSQLScalar<int?>("SELECT TestInt2 FROM CsvImportExpotrTest WHERE Description='Test me 2'"), "Failed to save null value");
        }

        [Description("Test import when DateTime column is null direct to table")]
        [TestMethod()]
        public void TestImportWhenDateTimeColumnNullDirectToTable()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,\n");
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, false);
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            Assert.IsNull(Database.ExecuteSQLScalar<DateTime?>("SELECT TestDateTime FROM CsvImportExpotrTest WHERE Description='Test me 2'"), "Failed to save null value");
        }

        [Description("Test import when string column is null direct to table")]
        [TestMethod()]
        public void TestImportWhenStringColumnNullDirectToTable()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat(",3,4,{0:yyyy-MM-dd HH:mm:ss}\n",              now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, false);
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            Assert.IsNull(Database.ExecuteSQLScalar<string>("SELECT Description  FROM CsvImportExpotrTest WHERE Description IS NULL"), "Failed to save null value");
        }

        [Description("Test import when string column is null (using specific null string) direct to table")]
        [TestMethod()]
        public void TestImportWhenStringColumnNullBySettingDirectToTable()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat(",1,2,{0:yyyy-MM-dd HH:mm:ss}\n",      now);
            str.AppendFormat("null,3,4,{0:yyyy-MM-dd HH:mm:ss}\n",  now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, false);
            importExport[0].NullValueForString = "null";
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            Assert.AreEqual("",Database.ExecuteSQLScalar<string>("SELECT Description FROM CsvImportExpotrTest WHERE TestInt1=1"), "Failed to save empty string");
            Assert.IsNull(Database.ExecuteSQLScalar<string>("SELECT Description FROM CsvImportExpotrTest WHERE TestInt1=3"), "Failed to save null value");
        }

        [Description("Test IfDeleteAllExistingData setting is true direct to table")]
        [TestMethod()]
        public void Test_IfDeleteAllExistingData_Is_True_DirectToTable()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, false);
            importExport[0].IfDeleteAllExistingData = true;

            // Load in data
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");

            // Load in data again
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");

            // Should only be two rows
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Has not deleted all data");
        }

        [Description("Test IfDeleteAllExistingData setting is false direct to table")]
        [TestMethod()]
        public void Test_IfDeleteAllExistingData_Is_False_DirectToTable()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(null, null, false);
            importExport[0].IfDeleteAllExistingData = false;

            // Load in data
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");

            // Load in data again
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");

            // Should only be 4 rows
            Assert.AreEqual(4, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Has deleted all data when should not");
        }

        [Description("Test basic import via routine")]
        [TestMethod()]
        public void TestBasicImportViaRoutine()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(WCsvImportExportTest.routineIdImport, null, false);
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");

            Assert.AreEqual(2,   Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            Assert.AreEqual(2,   Database.ExecuteSQLScalar<int>("SELECT TestInt1 FROM CsvImportExpotrTest WHERE Description='Test me 1'"), "Failed to import correct data");
            Assert.AreEqual(5,   Database.ExecuteSQLScalar<int>("SELECT TestInt2 FROM CsvImportExpotrTest WHERE Description='Test me 2'"), "Failed to import correct data");
            
            var actualTime = Database.ExecuteSQLScalar<DateTime>("SELECT TestDateTime FROM CsvImportExpotrTest WHERE Description='Test me 2'");
            Assert.IsTrue((now - actualTime).TotalSeconds < 1.0, "Failed to import date time");
        }

        [Description("Test import when header missing import via routine")]
        [TestMethod()]
        public void TestImportWhenHeaderMissingViaRoutine()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(WCsvImportExportTest.routineIdImport, null, false);

            // Will error
            Assert.IsFalse(importExport[0].ValidateCsv(true, FileName, errors), "Not erroring due to missing header row");
            Assert.IsFalse(errors.Count == 0, "No erroring due to missing header row");
        }

        [Description("Test import when with header (in matching column order) import via routine")]
        [TestMethod()]
        public void TestImportWithHeaderInMatchingOrderViaRoutine()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendLine("\"Description\",\"TestInt1\",\"TestInt2\",\"TestDateTime\"");
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(WCsvImportExportTest.routineIdImport, null, true);

            Assert.IsTrue(importExport[0].ValidateCsv(true, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(true, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
        }

        [Description("Test import when with header (in non matching column order) via routine")]
        [TestMethod()]
        public void TestImportWithHeaderInNonMatchingOrderViaRoutine()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendLine("\"TestDateTime\",\"Description\",\"TestInt1\",\"TestInt2\"");
            str.AppendFormat("{0:yyyy-MM-dd HH:mm:ss},\"Test me 1\",1,2\n", now);
            str.AppendFormat("{0:yyyy-MM-dd HH:mm:ss},\"Test me 2\",3,4\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(WCsvImportExportTest.routineIdImport, null, true);

            Assert.IsTrue(importExport[0].ValidateCsv(true, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(true, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            var actualTime = Database.ExecuteSQLScalar<DateTime>("SELECT TestDateTime FROM CsvImportExpotrTest WHERE Description='Test me 2'");
            Assert.IsTrue((now - actualTime).TotalSeconds < 1.0, "Failed to import date time");
        }

        [Description("Test import when with header with odd chars (in non matching column order) via routine")]
        [TestMethod()]
        public void TestImportWithHeaderOddCharsInNonMatchingOrderViaRoutine()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendLine("\"Test Date Time\",\"[Description]\",\"TestInt1@\",\"#TestInt2\"");
            str.AppendFormat("{0:yyyy-MM-dd HH:mm:ss},\"Test me 1\",1,2\n", now);
            str.AppendFormat("{0:yyyy-MM-dd HH:mm:ss},\"Test me 2\",3,4\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(WCsvImportExportTest.routineIdImport, null, true);

            Assert.IsTrue(importExport[0].ValidateCsv(true, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(true, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            var actualTime = Database.ExecuteSQLScalar<DateTime>("SELECT TestDateTime FROM CsvImportExpotrTest WHERE Description='Test me 2'");
            Assert.IsTrue((now - actualTime).TotalSeconds < 1.0, "Failed to import date time");
        }

        [Description("Test import when int column is null via routine")]
        [TestMethod()]
        public void TestImportWhenIntColumnNullViaRoutine()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(WCsvImportExportTest.routineIdImport, null, false);

            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            Assert.AreEqual(4, Database.ExecuteSQLScalar<int>("SELECT TestInt1 FROM CsvImportExpotrTest WHERE Description='Test me 2'"), "Failed to import via routine");
            Assert.IsNull(Database.ExecuteSQLScalar<int?>("SELECT TestInt2 FROM CsvImportExpotrTest WHERE Description='Test me 2'"), "Failed to save null value");
        }

        [Description("Test import when DateTime column is null via routine")]
        [TestMethod()]
        public void TestImportWhenDateTimeColumnNullViaRoutine()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,\n");
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(WCsvImportExportTest.routineIdImport, null, false);

            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            Assert.AreEqual(4, Database.ExecuteSQLScalar<int>("SELECT TestInt1 FROM CsvImportExpotrTest WHERE Description='Test me 2'"), "Failed to import via routine");
            Assert.IsNull(Database.ExecuteSQLScalar<DateTime?>("SELECT TestDateTime FROM CsvImportExpotrTest WHERE Description='Test me 2'"), "Failed to save null value");
        }

        [Description("Test import when string column is null via routine")]
        [TestMethod()]
        public void TestImportWhenStringColumnNullViaRoutine()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat(",3,4,{0:yyyy-MM-dd HH:mm:ss}\n",              now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(WCsvImportExportTest.routineIdImport, null, false, false);

            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");
                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            Assert.AreEqual(4, Database.ExecuteSQLScalar<int>("SELECT TestInt1 FROM CsvImportExpotrTest WHERE Description = ''"), "Failed to import via routine");
            Assert.IsNull(Database.ExecuteSQLScalar<string>("SELECT Description  FROM CsvImportExpotrTest WHERE Description IS NULL"), "Failed to save null value");
        }

        [Description("Test import when string column is null (using specific null string) direct to table via routine")]
        [TestMethod()]
        public void TestImportWhenStringColumnNullBySettingViaRoutine()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat(",1,2,{0:yyyy-MM-dd HH:mm:ss}\n",      now);
            str.AppendFormat("null,3,4,{0:yyyy-MM-dd HH:mm:ss}\n",  now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(WCsvImportExportTest.routineIdImport, null, false);
            importExport[0].NullValueForString = "null";

            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");

            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");
        
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Failed to import all lines");
            Assert.AreEqual("",Database.ExecuteSQLScalar<string>("SELECT Description FROM CsvImportExpotrTest WHERE TestInt1=2"), "Failed to save empty string");
            Assert.AreEqual("",Database.ExecuteSQLScalar<string>("SELECT Description FROM CsvImportExpotrTest WHERE TestInt1=4"), "Failed to save null value");
        }

        [Description("Test IfDeleteAllExistingData setting is true direct to table via routine")]
        [TestMethod()]
        public void Test_IfDeleteAllExistingData_Is_True_ViaRoutine()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(WCsvImportExportTest.routineIdImport, null, false);
            importExport[0].IfDeleteAllExistingData = true;

            // Load in data
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");

            // Load in data again
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");

            // Should only be two rows
            Assert.AreEqual(2, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Has not deleted all data");
            Assert.AreEqual(4, Database.ExecuteSQLScalar<int>("SELECT TestInt1 FROM CsvImportExpotrTest WHERE Description='Test me 2'"), "Failed to import via routine");
        }

        [Description("Test IfDeleteAllExistingData setting is false via routine")]
        [TestMethod()]
        public void Test_IfDeleteAllExistingData_Is_False_ViaRoutine()
        {
            DateTime now = DateTime.Now;
            StringBuilder str = new StringBuilder();
            str.AppendFormat("\"Test me 1\",1,2,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            str.AppendFormat("\"Test me 2\",3,4,{0:yyyy-MM-dd HH:mm:ss}\n", now);
            File.WriteAllText(FileName, str.ToString(), Encoding.Unicode);

            ErrorWarningList errors = new ErrorWarningList();
            WCsvImportExport importExport = CreateWCsvImportExportLine(WCsvImportExportTest.routineIdImport, null, false);
            importExport[0].IfDeleteAllExistingData = false;

            // Load in data
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");

            // Load in data again
            Assert.IsTrue(importExport[0].ValidateCsv(false, FileName, errors), "Errored validating");                
            errors = importExport[0].ParseFromCsv(false, FileName);
            Assert.IsTrue(errors.Count == 0, "Errored saving");

            // Should only be 4 rows
            Assert.AreEqual(4, Database.ExecuteSQLScalar<int>("SELECT COUNT(1) FROM CsvImportExpotrTest"), "Has deleted all data when should not");
            Assert.AreEqual(4, Database.ExecuteSQLScalar<int>("SELECT TestInt1 FROM CsvImportExpotrTest WHERE Description='Test me 2'"), "Failed to import via routine");
        }

        [Description("Test IfHeaderRowExport is false via direct from DB")]
        [TestMethod()]
        public void Test_IfHeaderRowExport_Is_False_DirectToTable()
        {
            DateTime now = DateTime.Now;
            PopulateCsvImportExpotrTestTableRow("Row1", 1, 2, now);
            PopulateCsvImportExpotrTestTableRow("Row2", 3, 4, now);

            var export = CreateWCsvImportExportLine(null, null, false)[0];
            var lines = export.ConvertToCsv().Split(new [] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries);

            Assert.AreEqual(2, lines.Length, "Number of lines is incorrect");
            Assert.IsTrue(lines[0].StartsWith("\"Row1\""), "Failed to extract correct row");
            Assert.IsTrue(lines[1].StartsWith("\"Row2\""), "Failed to extract correct row");
        }

        [Description("Test IfHeaderRowExport is true via direct from DB")]
        [TestMethod()]
        public void Test_IfHeaderRowExport_Is_True_DirectToTable()
        {
            DateTime now = DateTime.Now;
            PopulateCsvImportExpotrTestTableRow("Row1", 1, 2, now);
            PopulateCsvImportExpotrTestTableRow("Row2", 3, 4, now);

            var export = CreateWCsvImportExportLine(null, null, true)[0];
            var lines = export.ConvertToCsv().Split(new [] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries);

            Assert.AreEqual(3, lines.Length, "Number of lines is incorrect");
            Assert.AreEqual("\"Description\",\"TestInt1\",\"TestInt2\",\"TestDateTime\"", lines[0], "Failed to extract header row");
            Assert.IsTrue(lines[1].StartsWith("\"Row1\""), "Failed to extract correct row");
            Assert.IsTrue(lines[2].StartsWith("\"Row2\""), "Failed to extract correct row");
        }

        [Description("Test IfHeaderRowExport is true via routine")]
        [TestMethod()]
        public void Test_IfHeaderRowExport_Is_True_ViaRoutine()
        {
            DateTime now = DateTime.Now;
            PopulateCsvImportExpotrTestTableRow("Row1", 1, 2, now);
            PopulateCsvImportExpotrTestTableRow("Row2", 3, 4, now);

            var export = CreateWCsvImportExportLine(null, WCsvImportExportTest.routineIdExport, true)[0];
            var lines = export.ConvertToCsv().Split(new [] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries);

            Assert.AreEqual(3, lines.Length, "Number of lines is incorrect");
            Assert.AreEqual("\"Description\",\"TestDateTime\",\"TestInt1\",\"TestInt2\"", lines[0], "Failed to extract header row");
            Assert.IsTrue(lines[1].StartsWith("\"Row1\""), "Failed to extract correct row");
            Assert.IsTrue(lines[2].StartsWith("\"Row2\""), "Failed to extract correct row");
        }

        private WCsvImportExport CreateWCsvImportExportLine(int? importRoutineId, int? exportRoutineId, bool ifHeaderRow, bool ignoreEmptyRowsOnImport = true)
        {
            WCsvImportExport importExport = new WCsvImportExport();
            importExport.Add();
            importExport[0].DataTypeName                = "CsvImportExpotrTest";
            importExport[0].Description                 = "For testing";
            importExport[0].RawRow["DefaultFileName"]   = "CsvImportExpotrTest.csv";
            importExport[0].IfDeleteAllExistingData     = true;
            importExport[0].IfHeaderRowExport           = ifHeaderRow;
            importExport[0].NullValueForString          = string.Empty;
            importExport[0].RoutineIdExport             = exportRoutineId;
            importExport[0].RoutineIdImport             = importRoutineId;
            importExport[0].IgnoreEmptyRowsOnImport     = ignoreEmptyRowsOnImport;
            importExport.Save();
            return importExport;
        }

        private void PopulateCsvImportExpotrTestTableRow(string description, int testInt1, int testInt2, DateTime testDateTime)
        {
            GenericTable2 table = new GenericTable2("CsvImportExpotrTest");
            var row = table.Add();
            row.RawRow["Description"] = description;
            row.RawRow["TestInt1"]    = testInt1;
            row.RawRow["TestInt2"]    = testInt2;
            row.RawRow["TestDateTime"]= testDateTime;
            table.Save();
        }
    }
}
