//===========================================================================
//
//							      BaseRowTest.cs
//
//  Holds tests for the BaseRow class.
//
//  Test should be run from within Visual Studio.  
//
//	Modification History:
//	15Apr09 XN  Written
//===========================================================================
using System;
using System.Configuration;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Data;

namespace Unit_Test_Base_Data_Layer
{
    /// <summary>
    ///This is a test class for BaseRowTest and is intended
    ///to contain all BaseRowTest Unit Tests
    ///</summary>
    [TestClass()]
    public class BaseRowTest
    {
        #region EnumViaDBLookup test info
        // Used to test the EnumViaDBLookup functions
        // The enumerated type relates to the database table EnumLookupTest.
        [EnumViaDBLookup(TableName = "EnumLookupTest", PKColumn = "EnumLookupTestID", DescriptionColumn = "ADescription")]
        private enum TestEnum
        {
            Stuff,
            OtherStuff,

            [EnumDBDescription("Some stuff different to others")]
            SomeStuffDiffToOthers,

            [EnumDBDescription("Anti stuff")]
            DarkMatter,

            InvalidEnum,    // This value is purposely not supported by the database table
        };

        // Used to test the EnumViaDBLookup functions
        // The enumerated type purposely does not support the EnumViaDBLookup
        private enum InvalidEnum
        {
            Stuff,
            OtherStuff,
        }

        // DB ids for the enum from the EnumLookupTest
        const int TestEnumStuffID = 1;
        const int TestEnumOtherStuffID = 3;
        const int TestEnumSomeStuffDiffToOthersID = 4;
        const int TestEnumDarkMatterID = 6; 
        #endregion

        static int SessionID;  // Relates to row in session table

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
        public static void MyClassInitialize(TestContext testContext)
        {
            Configuration conf = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            ConnectionStringsSection connectionStrSect = conf.ConnectionStrings;

            string connectionStr = connectionStrSect.ConnectionStrings["TRNRTL10.My.MySettings.ConnectionString"].ConnectionString;
            linqdb = new TestDBDataContext(connectionStr);

            // Create the EnumLookupTest table used by test in this calss
            linqdb.ExecuteCommand("Exec pDrop 'EnumLookupTest'");
            linqdb.ExecuteCommand("CREATE TABLE EnumLookupTest ( EnumLookupTestID int PRIMARY KEY NOT NULL, ADescription varchar(100) NOT NULL)");

            linqdb.ExecuteCommand("INSERT INTO EnumLookupTest (EnumLookupTestID, ADescription) VALUES (1, 'Stuff')");
            linqdb.ExecuteCommand("INSERT INTO EnumLookupTest (EnumLookupTestID, ADescription) VALUES (3, 'OtherStuff')");
            linqdb.ExecuteCommand("INSERT INTO EnumLookupTest (EnumLookupTestID, ADescription) VALUES (4, 'Some stuff different to others')");
            linqdb.ExecuteCommand("INSERT INTO EnumLookupTest (EnumLookupTestID, ADescription) VALUES (5, 'Test A')");
            linqdb.ExecuteCommand("INSERT INTO EnumLookupTest (EnumLookupTestID, ADescription) VALUES (6, 'Anti stuff')");

            // Get a sesssion ID (any will do)
            SessionID = linqdb.ExecuteQuery<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC").First();
        }
        
        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}

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

            //// Setup a mock HttpContext
            //SimulatedHttpRequest.SetHttpContextWithSimulatedRequest("http://localhost/TestApp", "test app", assemblyDir);

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
        [Description("A test for BaseRow.EnumToFieldByDBCode.")]
        public void EnumToFieldByDBCodeTest()
        {
            Assert.AreEqual("3", new BaseRow().EnumToFieldByDBCode(OrderStatusType.WaitingToReceive));
            Assert.AreEqual("R", new BaseRow().EnumToFieldByDBCode(OrderStatusType.Completed));
            Assert.AreEqual("D", new BaseRow().EnumToFieldByDBCode(OrderStatusType.Deleted));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldToEnumByDBCode.")]
        public void FieldToEnumByDBCodeTest()
        {
            Assert.AreEqual(OrderStatusType.WaitingToReceive,    new BaseRow().FieldToEnumByDBCode<OrderStatusType>("3"));
            Assert.AreEqual(OrderStatusType.Completed,  new BaseRow().FieldToEnumByDBCode<OrderStatusType>("R"));
            Assert.AreEqual(OrderStatusType.Deleted,    new BaseRow().FieldToEnumByDBCode<OrderStatusType>("D"));
            Assert.AreEqual(OrderStatusType.Unknown,    new BaseRow().FieldToEnumByDBCode<OrderStatusType>("dsadwe"));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldToEnumByDBCode when field is null.")]
        public void FieldToEnumByDBCodeTestWhenFieldIsNull()
        {
            Assert.AreEqual(OrderStatusType.Unknown, new BaseRow().FieldToEnumByDBCode<OrderStatusType>(DBNull.Value));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldIntDateToDateTime in YYYYMMDD format.")]
        public void FieldIntDateToDateTimeInYYYYMMDDFormat()
        {
            Assert.AreEqual(new DateTime(2008, 12, 01), new BaseRow().FieldIntDateToDateTime(20081201, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(new DateTime(2008, 12, 31), new BaseRow().FieldIntDateToDateTime(20081231, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(new DateTime(1998, 01, 15), new BaseRow().FieldIntDateToDateTime(19980115, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(new DateTime(2008, 02, 14), new BaseRow().FieldIntDateToDateTime(20080214, BaseRow.DateType.YYYYMMDD));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldIntDateToDateTime in DDMMYYYY format.")]
        public void FieldIntDateToDateTimeInDDMMYYYYFormat()
        {
            Assert.AreEqual(new DateTime(2008, 12, 01), new BaseRow().FieldIntDateToDateTime(01122008, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(new DateTime(2008, 12, 31), new BaseRow().FieldIntDateToDateTime(31122008, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(new DateTime(1998, 01, 15), new BaseRow().FieldIntDateToDateTime(15011998, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(new DateTime(2008, 02, 14), new BaseRow().FieldIntDateToDateTime(14022008, BaseRow.DateType.DDMMYYYY));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldIntDateToDateTime in DD_MM_YYYY format.")]
        public void FieldIntDateToDateTimeInDD_MM_YYYYFormat()
        {
            Assert.AreEqual(new DateTime(2008, 12, 01), new BaseRow().FieldIntDateToDateTime("01/12/2008", BaseRow.DateType.DD_MM_YYYY));
            Assert.AreEqual(new DateTime(2008, 12, 31), new BaseRow().FieldIntDateToDateTime("31.12.2008", BaseRow.DateType.DD_MM_YYYY));
            Assert.AreEqual(new DateTime(1998, 01, 15), new BaseRow().FieldIntDateToDateTime("15 01 1998", BaseRow.DateType.DD_MM_YYYY));
            Assert.AreEqual(new DateTime(2008, 02, 14), new BaseRow().FieldIntDateToDateTime("14-02-2008", BaseRow.DateType.DD_MM_YYYY));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldIntDateToDateTime with null field.")]
        public void FieldIntDateToDateTimeTestWhenFieldIsNull()
        {
            BaseRow tempRow = new BaseRow();
            Assert.IsNull(tempRow.FieldIntDateToDateTime(DBNull.Value, BaseRow.DateType.YYYYMMDD));
            Assert.IsNull(tempRow.FieldIntDateToDateTime(DBNull.Value, BaseRow.DateType.DDMMYYYY));
            Assert.IsNull(tempRow.FieldIntDateToDateTime(DBNull.Value, BaseRow.DateType.DD_MM_YYYY));
            Assert.IsNull(tempRow.FieldIntDateToDateTime(0, BaseRow.DateType.YYYYMMDD));
            Assert.IsNull(tempRow.FieldIntDateToDateTime(0, BaseRow.DateType.DDMMYYYY));
            Assert.IsNull(tempRow.FieldIntDateToDateTime(0, BaseRow.DateType.DD_MM_YYYY));
            Assert.IsNull(tempRow.FieldIntDateToDateTime(string.Empty, BaseRow.DateType.YYYYMMDD));
            Assert.IsNull(tempRow.FieldIntDateToDateTime(string.Empty, BaseRow.DateType.DDMMYYYY));
            Assert.IsNull(tempRow.FieldIntDateToDateTime(string.Empty, BaseRow.DateType.DD_MM_YYYY));
            Assert.IsNull(tempRow.FieldIntDateToDateTime(" ", BaseRow.DateType.YYYYMMDD));
            Assert.IsNull(tempRow.FieldIntDateToDateTime(" ", BaseRow.DateType.DDMMYYYY));
            Assert.IsNull(tempRow.FieldIntDateToDateTime(" ", BaseRow.DateType.DD_MM_YYYY));
            Assert.IsNull(tempRow.FieldIntDateToDateTime("--------", BaseRow.DateType.YYYYMMDD));
            Assert.IsNull(tempRow.FieldIntDateToDateTime("--------", BaseRow.DateType.DDMMYYYY));
            Assert.IsNull(tempRow.FieldIntDateToDateTime("--------", BaseRow.DateType.DD_MM_YYYY));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DateTimeToFieldIntDate in YYYYMMDD format.")]
        public void DateTimeToFieldIntDateInYYYYMMDDFormat()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(20081201, tempRow.DateTimeToFieldIntDate(new DateTime(2008, 12, 01), null, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(20081231, tempRow.DateTimeToFieldIntDate(new DateTime(2008, 12, 31), null, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(19980115, tempRow.DateTimeToFieldIntDate(new DateTime(1998, 01, 15), null, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(20080214, tempRow.DateTimeToFieldIntDate(new DateTime(2008, 02, 14), null, BaseRow.DateType.YYYYMMDD));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DateTimeToFieldIntDate in DDMMYYYY format.")]
        public void DateTimeToFieldIntDateInDDMMYYYYFormat()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(01122008, tempRow.DateTimeToFieldIntDate(new DateTime(2008, 12, 01), null, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(31122008, tempRow.DateTimeToFieldIntDate(new DateTime(2008, 12, 31), null, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(15011998, tempRow.DateTimeToFieldIntDate(new DateTime(1998, 01, 15), null, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(14022008, tempRow.DateTimeToFieldIntDate(new DateTime(2008, 02, 14), null, BaseRow.DateType.DDMMYYYY));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DateTimeToFieldIntDate with null DateTime.")]
        public void DateTimeToFieldIntDateTestWhenFieldIsNull()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(DBNull.Value, tempRow.DateTimeToFieldIntDate(null, DBNull.Value, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(DBNull.Value, tempRow.DateTimeToFieldIntDate(null, DBNull.Value, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(0,  tempRow.DateTimeToFieldIntDate(null, 0, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(0,  tempRow.DateTimeToFieldIntDate(null, 0, BaseRow.DateType.DDMMYYYY));
        }

        [TestMethod()]
        [Description("Tests throws exception for BaseRow.DateTimeToFieldIntDate with DD_MM_YYYY format.")]
        [ExpectedException(typeof(InvalidOperationException))]
        public void DateTimeToFieldIntDateInDD_MM_YYYYFormat()
        {
            new BaseRow().DateTimeToFieldIntDate(new DateTime(2008, 12, 01), DBNull.Value, BaseRow.DateType.DD_MM_YYYY);
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldStrDateToDateTime in YYYYMMDD format.")]
        public void FieldStrDateToDateTimeInYYYYMMDDFormat()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(new DateTime(2008, 12, 01), tempRow.FieldStrDateToDateTime("20081201", BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(new DateTime(2008, 12, 31), tempRow.FieldStrDateToDateTime("20081231", BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(new DateTime(1998, 01, 15), tempRow.FieldStrDateToDateTime("19980115", BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(new DateTime(2008, 02, 14), tempRow.FieldStrDateToDateTime("20080214", BaseRow.DateType.YYYYMMDD));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldStrDateToDateTime in DDMMYYYY format.")]
        public void FieldStrDateToDateTimeInDDMMYYYYFormat()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(new DateTime(2008, 12, 01), tempRow.FieldStrDateToDateTime("01122008", BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(new DateTime(2008, 12, 31), tempRow.FieldStrDateToDateTime("31122008", BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(new DateTime(1998, 01, 15), tempRow.FieldStrDateToDateTime("15011998", BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(new DateTime(2008, 02, 14), tempRow.FieldStrDateToDateTime("14022008", BaseRow.DateType.DDMMYYYY));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldStrDateToDateTime in DD_MM_YYYY format.")]
        public void FieldStrDateToDateTimeInDD_MM_YYYYFormat()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(new DateTime(2008, 12, 01), tempRow.FieldStrDateToDateTime("01/12/2008", BaseRow.DateType.DD_MM_YYYY));
            Assert.AreEqual(new DateTime(2008, 12, 31), tempRow.FieldStrDateToDateTime("31_12_2008", BaseRow.DateType.DD_MM_YYYY));
            Assert.AreEqual(new DateTime(1998, 01, 15), tempRow.FieldStrDateToDateTime("15.01.1998", BaseRow.DateType.DD_MM_YYYY));
            Assert.AreEqual(new DateTime(2008, 02, 14), tempRow.FieldStrDateToDateTime("14-02-2008", BaseRow.DateType.DD_MM_YYYY));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldStrDateToDateTime with null field.")]
        public void FieldStrDateToDateTimeTestWhenFieldIsNull()
        {
            BaseRow tempRow = new BaseRow();
            Assert.IsNull(tempRow.FieldStrDateToDateTime(DBNull.Value, BaseRow.DateType.YYYYMMDD));
            Assert.IsNull(tempRow.FieldStrDateToDateTime(DBNull.Value, BaseRow.DateType.DDMMYYYY));
            Assert.IsNull(tempRow.FieldStrDateToDateTime(DBNull.Value, BaseRow.DateType.DD_MM_YYYY));
            Assert.IsNull(tempRow.FieldStrDateToDateTime(0, BaseRow.DateType.YYYYMMDD));
            Assert.IsNull(tempRow.FieldStrDateToDateTime(0, BaseRow.DateType.DDMMYYYY));
            Assert.IsNull(tempRow.FieldStrDateToDateTime(0, BaseRow.DateType.DD_MM_YYYY));
            Assert.IsNull(tempRow.FieldStrDateToDateTime("", BaseRow.DateType.YYYYMMDD));
            Assert.IsNull(tempRow.FieldStrDateToDateTime("", BaseRow.DateType.DDMMYYYY));
            Assert.IsNull(tempRow.FieldStrDateToDateTime("", BaseRow.DateType.DD_MM_YYYY));
            Assert.IsNull(tempRow.FieldStrDateToDateTime("  ", BaseRow.DateType.YYYYMMDD));
            Assert.IsNull(tempRow.FieldStrDateToDateTime("  ", BaseRow.DateType.DDMMYYYY));
            Assert.IsNull(tempRow.FieldStrDateToDateTime("  ", BaseRow.DateType.DD_MM_YYYY));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DateTimeToFieldStrDate in YYYYMMDD format.")]
        public void DateTimeToFieldStrDateInYYYYMMDDFormat()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual("20081201", tempRow.DateTimeToFieldStrDate(new DateTime(2008, 12, 01), null, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual("20081231", tempRow.DateTimeToFieldStrDate(new DateTime(2008, 12, 31), null, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual("19980115", tempRow.DateTimeToFieldStrDate(new DateTime(1998, 01, 15), null, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual("20080214", tempRow.DateTimeToFieldStrDate(new DateTime(2008, 02, 14), null, BaseRow.DateType.YYYYMMDD));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DateTimeToFieldStrDate in DDMMYYYY format.")]
        public void DateTimeToFieldStrDateInDDMMYYYYFormat()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual("01122008", tempRow.DateTimeToFieldStrDate(new DateTime(2008, 12, 01), null, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual("31122008", tempRow.DateTimeToFieldStrDate(new DateTime(2008, 12, 31), null, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual("15011998", tempRow.DateTimeToFieldStrDate(new DateTime(1998, 01, 15), null, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual("14022008", tempRow.DateTimeToFieldStrDate(new DateTime(2008, 02, 14), null, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual("09010001", tempRow.DateTimeToFieldStrDate(new DateTime(0001, 01, 09), null, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual("10010001", tempRow.DateTimeToFieldStrDate(new DateTime(0001, 01, 10), null, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual("09129999", tempRow.DateTimeToFieldStrDate(new DateTime(9999, 12, 09), null, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual("10129999", tempRow.DateTimeToFieldStrDate(new DateTime(9999, 12, 10), null, BaseRow.DateType.DDMMYYYY));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DateTimeToFieldStrDate in DD_MM_YYYY format.")]
        public void DateTimeToFieldStrDateInDD_MM_YYYYFormat()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual("01/12/2008", tempRow.DateTimeToFieldStrDate(new DateTime(2008, 12, 01), null, BaseRow.DateType.DD_MM_YYYY, '/'));
            Assert.AreEqual("31_12_2008", tempRow.DateTimeToFieldStrDate(new DateTime(2008, 12, 31), null, BaseRow.DateType.DD_MM_YYYY, '_'));
            Assert.AreEqual("15.01.1998", tempRow.DateTimeToFieldStrDate(new DateTime(1998, 01, 15), null, BaseRow.DateType.DD_MM_YYYY, '.'));
            Assert.AreEqual("14-02-2008", tempRow.DateTimeToFieldStrDate(new DateTime(2008, 02, 14), null, BaseRow.DateType.DD_MM_YYYY, '-'));
            Assert.AreEqual("09 01 0001", tempRow.DateTimeToFieldStrDate(new DateTime(0001, 01, 09), null, BaseRow.DateType.DD_MM_YYYY, ' '));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DateTimeToFieldStrDate with null DateTime.")]
        public void DateTimeToFieldStrDateTestWhenFieldIsNull()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(DBNull.Value, tempRow.DateTimeToFieldStrDate(null, DBNull.Value, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(DBNull.Value, tempRow.DateTimeToFieldStrDate(null, DBNull.Value, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(DBNull.Value, tempRow.DateTimeToFieldStrDate(null, DBNull.Value, BaseRow.DateType.DD_MM_YYYY));
            Assert.AreEqual("", tempRow.DateTimeToFieldStrDate(null, "", BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual("", tempRow.DateTimeToFieldStrDate(null, "", BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual("", tempRow.DateTimeToFieldStrDate(null, "", BaseRow.DateType.DD_MM_YYYY));
            Assert.AreEqual(0,  tempRow.DateTimeToFieldStrDate(null, 0, BaseRow.DateType.YYYYMMDD));
            Assert.AreEqual(0,  tempRow.DateTimeToFieldStrDate(null, 0, BaseRow.DateType.DDMMYYYY));
            Assert.AreEqual(0,  tempRow.DateTimeToFieldStrDate(null, 0, BaseRow.DateType.DD_MM_YYYY));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldStrTimeToTimeSpan.")]
        public void FieldStrTimeToTimeSpanTest()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(new TimeSpan(12, 54,  6), tempRow.FieldStrTimeToTimeSpan("125406"));
            Assert.AreEqual(new TimeSpan(14, 18, 28), tempRow.FieldStrTimeToTimeSpan("141828"));
            Assert.AreEqual(new TimeSpan(9,  39, 40), tempRow.FieldStrTimeToTimeSpan("093940"));
            Assert.AreEqual(new TimeSpan(17,  5, 20), tempRow.FieldStrTimeToTimeSpan("170520"));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldStrTimeToTimeSpan with null field.")]
        public void FieldStrTimeToTimeSpanTestWhenFieldIsNull()
        {
            BaseRow tempRow = new BaseRow();
            Assert.IsNull(tempRow.FieldStrTimeToTimeSpan(DBNull.Value));
            Assert.IsNull(tempRow.FieldStrTimeToTimeSpan(""));
            Assert.IsNull(tempRow.FieldStrTimeToTimeSpan("   "));
        }

        [TestMethod()]
        [Description("A test for BaseRow.TimeSpanToFieldStrTime.")]
        public void TimeSpanToFieldStrTimeTest()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual("125406", tempRow.TimeSpanToFieldStrTime(new TimeSpan(12, 54,  6)));
            Assert.AreEqual("141828", tempRow.TimeSpanToFieldStrTime(new TimeSpan(14, 18, 28)));
            Assert.AreEqual("093940", tempRow.TimeSpanToFieldStrTime(new TimeSpan(9,  39, 40)));
            Assert.AreEqual("170520", tempRow.TimeSpanToFieldStrTime(new TimeSpan(17,  5, 20)));
        }

        [TestMethod()]
        [Description("A test for BaseRow.TimeSpanToFieldStrTime with null field.")]
        public void TimeSpanToFieldStrTimeTestWhenTimeSpanIsNull()
        {
            Assert.AreEqual(DBNull.Value, new BaseRow().TimeSpanToFieldStrTime(null));
        }


        [TestMethod()]
        [Description("A test for BaseRow.DateTimeToFieldStrTime.")]
        public void DateTimeToFieldStrTimeTest()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual("125406", tempRow.DateTimeToFieldStrTime(new DateTime(2004, 1, 12, 12, 54,  6), false));
            Assert.AreEqual("141828", tempRow.DateTimeToFieldStrTime(new DateTime(2004, 1, 12, 14, 18, 28), false));
            Assert.AreEqual("093940", tempRow.DateTimeToFieldStrTime(new DateTime(2004, 1, 12, 9,  39, 40), false));
            Assert.AreEqual("170520", tempRow.DateTimeToFieldStrTime(new DateTime(2004, 1, 12, 17,  5, 20), false));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DateTimeToFieldStrTime with null field.")]
        public void DateTimeToFieldStrTimeTestWhenTimeSpanIsNull()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(DBNull.Value, tempRow.DateTimeToFieldStrTime(null, false));
            Assert.AreEqual("", tempRow.DateTimeToFieldStrTime(null, true));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldToStr when field is null.")]
        public void FieldToStrWhenFieldIsNull()
        {
            Assert.IsNull  (new BaseRow().FieldToStr(DBNull.Value));
            Assert.AreEqual("Empty", new BaseRow().FieldToStr(DBNull.Value, false, "Empty"));
        }

        [TestMethod()]
        [Description("A test for BaseRow.StrToField when string is null.")]
        public void StrToFieldWhenStrIsNull()
        {
            Assert.AreEqual(DBNull.Value, new BaseRow().StrToField(null));
            Assert.AreEqual(DBNull.Value, new BaseRow().StrToField("", true));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldToInt when field is null.")]
        public void FieldToIntWhenFieldIsNull()
        {
            Assert.IsNull(new BaseRow().FieldToInt(DBNull.Value));
        }

        [TestMethod()]
        [Description("A test for BaseRow.IntToField when int is null.")]
        public void IntToFieldWhenIntIsNull()
        {
            Assert.AreEqual(DBNull.Value, new BaseRow().IntToField(null));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldToShort when short is not null.")]
        public void FieldToShortTest()
        {
            Assert.AreEqual((short) 124,  new BaseRow().FieldToShort(124));
            Assert.AreEqual((short)-4432, new BaseRow().FieldToShort(-4432));
        }        

        [TestMethod()]
        [Description("A test for BaseRow.FieldToShort when field is null.")]
        public void FieldToShortWhenFieldIsNull()
        {
            Assert.IsNull(new BaseRow().FieldToShort(DBNull.Value));
        }

        [TestMethod()]
        [Description("Test BaseRow.FieldToShort throws exceptiuon if converts something that is too large for short.")]
        [ExpectedException(typeof(OverflowException))]
        public void FieldToShortWhenPassedAnInt()
        {
            new BaseRow().FieldToShort(0xFFFFF);
        }

        [TestMethod()]
        [Description("A test for BaseRow.ShortToField when short is not null.")]
        public void ShortToFieldTest()
        {
            Assert.AreEqual((short) 124,  new BaseRow().ShortToField(124));
            Assert.AreEqual((short)-4432, new BaseRow().ShortToField(-4432));
        }        

        [TestMethod()]
        [Description("A test for BaseRow.ShortToField when short is null.")]
        public void ShortToFieldWhenIntIsNull()
        {
            Assert.AreEqual(DBNull.Value, new BaseRow().ShortToField(null));
        }        

        [TestMethod()]
        [Description("A test for BaseRow.FieldToDateTime when field is null.")]
        public void FieldToDateTimeWhenFieldIsNull()
        {
            Assert.IsNull(new BaseRow().FieldToDateTime(DBNull.Value));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DateTimeToField when DateTime is null.")]
        public void DateTimeToFieldWhenDateTimeIsNull()
        {
            Assert.AreEqual(DBNull.Value, new BaseRow().DateTimeToField(null));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldToBoolean.")]
        public void FieldToBooleanTest()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(true,  tempRow.FieldToBoolean(true));
            Assert.AreEqual(true,  tempRow.FieldToBoolean("Y"));
            Assert.AreEqual(true,  tempRow.FieldToBoolean("y"));
            Assert.AreEqual(true,  tempRow.FieldToBoolean("YeS"));
            Assert.AreEqual(true,  tempRow.FieldToBoolean("1"));
            Assert.AreEqual(true,  tempRow.FieldToBoolean("TrUe"));
            Assert.AreEqual(false, tempRow.FieldToBoolean(false));
            Assert.AreEqual(false, tempRow.FieldToBoolean("nO"));
            Assert.AreEqual(false, tempRow.FieldToBoolean("0"));
            Assert.AreEqual(false, tempRow.FieldToBoolean("FalSe"));
            Assert.AreEqual(false, tempRow.FieldToBoolean("n"));
            Assert.AreEqual(false, tempRow.FieldToBoolean("N"));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldToBoolean when field is null.")]
        public void FieldToBooleanWhenFieldIsNull()
        {
            BaseRow tempRow = new BaseRow();
            Assert.IsNull(tempRow.FieldToBoolean(DBNull.Value));
            Assert.IsNull(tempRow.FieldToBoolean("dsdada"));
            Assert.AreEqual(true,  tempRow.FieldToBoolean(DBNull.Value, true));
            Assert.AreEqual(false, tempRow.FieldToBoolean(DBNull.Value, false));
        }

        [TestMethod()]
        [Description("A test for BaseRow.BooleanToField.")]
        public void BooleanToFieldTest()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(true,  tempRow.BooleanToField(true));
            Assert.AreEqual("1",   tempRow.BooleanToField(true, "1", "0"));
            Assert.AreEqual("YeS", tempRow.BooleanToField(true, "YeS", "nO"));
            Assert.AreEqual("Y",   tempRow.BooleanToField(true, "Y", "N"));
            Assert.AreEqual(false, tempRow.BooleanToField(false));
            Assert.AreEqual("0",   tempRow.BooleanToField(false, "1", "0"));
            Assert.AreEqual("nO",  tempRow.BooleanToField(false, "YeS", "nO"));
            Assert.AreEqual("N",   tempRow.BooleanToField(false, "Y", "N"));
        }

        [TestMethod()]
        [Description("A test for BaseRow.BooleanToField when Boolean is null.")]
        public void BooleanToFieldWhenBooleanIsNull()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(DBNull.Value, tempRow.BooleanToField(null));
            Assert.AreEqual(true,  tempRow.BooleanToField(null, true, false, true));
            Assert.AreEqual(false, tempRow.BooleanToField(null, true, false, false));
            Assert.AreEqual("Who knows", tempRow.BooleanToField(null, "Yes", "No", "Who knows"));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldToDouble when field is null.")]
        public void FieldToDoubleWhenFieldIsNull()
        {
            Assert.IsNull(new BaseRow().FieldToDouble(DBNull.Value));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DoubleToField when double is null.")]
        public void DoubleToFieldWhenDoubleIsNull()
        {
            Assert.AreEqual(DBNull.Value, new BaseRow().DoubleToField(null));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldToDecimal.")]
        public void FieldToDecimalTest()
        {
            Assert.AreEqual(10000000000m, new BaseRow().FieldToDecimal("1.0E+10"));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldToDecimal when field is null.")]
        public void FieldToDecimalWhenFieldIsNull()
        {
            Assert.IsNull(new BaseRow().FieldToDecimal(DBNull.Value));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DecimalToField when decimal is null.")]
        public void DecimalToFieldWhenDecimalIsNull()
        {
            Assert.AreEqual(DBNull.Value, new BaseRow().DecimalToField(null));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldStrToDecimal.")]
        public void FieldStrToDecimalTest()
        {
            Assert.AreEqual(10000000000m, new BaseRow().FieldStrToDecimal("1.0E+10"));
        }

        [TestMethod()]
        [Description("A test for BaseRow.FieldStrToDecimal when field is null.")]
        public void FieldStrToDecimalWhenFieldIsNull()
        {
            BaseRow tempRow = new BaseRow();
            Assert.IsNull(tempRow.FieldStrToDecimal(DBNull.Value));
            Assert.IsNull(tempRow.FieldStrToDecimal(""));
            Assert.IsNull(tempRow.FieldStrToDecimal("   "));
        }

        [TestMethod()]
        [Description("A test for BaseRow.DecimalToFieldStr when decimal is null.")]
        public void DecimalToFieldStrWhenDecimalIsNull()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(DBNull.Value, tempRow.DecimalToFieldStr(null, 6));
            Assert.AreEqual(DBNull.Value, tempRow.DecimalToFieldStr(null, 6, false));
            Assert.AreEqual("", tempRow.DecimalToFieldStr(null, 6, true));
        }

        [TestMethod()]
        [Description("Test for BaseRow.EnumToFieldViaDBLookup.")]
        public void EnumToFieldViaDBLookupTest()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(TestEnumStuffID,                 tempRow.EnumToFieldViaDBLookup<TestEnum>(TestEnum.Stuff));
            Assert.AreEqual(TestEnumOtherStuffID,            tempRow.EnumToFieldViaDBLookup<TestEnum>(TestEnum.OtherStuff));
            Assert.AreEqual(TestEnumSomeStuffDiffToOthersID, tempRow.EnumToFieldViaDBLookup<TestEnum>(TestEnum.SomeStuffDiffToOthers));
            Assert.AreEqual(TestEnumDarkMatterID,            tempRow.EnumToFieldViaDBLookup<TestEnum>(TestEnum.DarkMatter));
        }

        [TestMethod()]
        [Description("Test for BaseRow.EnumToFieldViaDBLookup when value is null.")]
        public void EnumToFieldViaDBLookupTestWhenValueNull()
        {
            Assert.AreEqual(DBNull.Value, new BaseRow().EnumToFieldViaDBLookup<TestEnum>(null));
        }

        [TestMethod()]
        [Description("Test for BaseRow.EnumToFieldViaDBLookup when enum does not support EnumViaDBLook.")]
        [ExpectedException(typeof(ApplicationException))]
        public void EnumToFieldViaDBLookupTestForInvalidEnum()
        {
            new BaseRow().EnumToFieldViaDBLookup<InvalidEnum>(InvalidEnum.Stuff);
        }

        [TestMethod()]
        [Description("Test for BaseRow.EnumToFieldViaDBLookup when enum value does not have related row.")]
        [ExpectedException(typeof(ApplicationException))]
        public void EnumToFieldViaDBLookupTestWhenNoRelatedDBRow()
        {
            new BaseRow().EnumToFieldViaDBLookup<TestEnum>(TestEnum.InvalidEnum);
        }

        [TestMethod()]
        [Description("Test for BaseRow.FieldToEnumViaDBLookup.")]
        public void FieldToEnumViaDBLookupTest()
        {
            BaseRow tempRow = new BaseRow();
            Assert.AreEqual(TestEnum.Stuff,                 tempRow.FieldToEnumViaDBLookup<TestEnum>(TestEnumStuffID));
            Assert.AreEqual(TestEnum.OtherStuff,            tempRow.FieldToEnumViaDBLookup<TestEnum>(TestEnumOtherStuffID));
            Assert.AreEqual(TestEnum.SomeStuffDiffToOthers, tempRow.FieldToEnumViaDBLookup<TestEnum>(TestEnumSomeStuffDiffToOthersID));
            Assert.AreEqual(TestEnum.DarkMatter,            tempRow.FieldToEnumViaDBLookup<TestEnum>(TestEnumDarkMatterID));
        }

        [TestMethod()]
        [Description("Test for BaseRow.FieldToEnumViaDBLookup when field is null.")]
        public void FieldToEnumViaDBLookupTestWhenFieldIsNull()
        {
            Assert.IsNull(new BaseRow().FieldToEnumViaDBLookup<TestEnum>(DBNull.Value));
        }

        [TestMethod()]
        [Description("Test for BaseRow.FieldToEnumViaDBLookup when field does not relate to enum value.")]
        [ExpectedException(typeof(ApplicationException))]
        public void FieldToEnumViaDBLookupTestWhenInvalidEnumField()
        {
            new BaseRow().FieldToEnumViaDBLookup<TestEnum>(88);
        }

        [TestMethod()]
        [Description("Test BaseRow.HasFieldChanged")]
        public void HasFieldChanged()
        {
            DataSet ds = new DataSet();
            ds.Tables.Add("Test");
            ds.Tables[0].Columns.Add("TestA", typeof(string));
            ds.Tables[0].Columns.Add("TestB", typeof(string));
            ds.Tables[0].Rows.Add(new object[] { "A", "B" });

            BaseRow row = new BaseRow();
            row.RawRow = ds.Tables[0].Rows[0];
            ds.AcceptChanges();

            // Test no changes columns if accepted changed
            Assert.IsFalse(row.HasFieldChanged("TestA"));
            Assert.IsFalse(row.HasFieldChanged("TestB"));

            // Test returns single changed column
            row.RawRow["TestA"] = "a";
            Assert.IsTrue(row.HasFieldChanged("TestA"));
            Assert.IsFalse(row.HasFieldChanged("TestB"));

            // Test returns both changed columns
            row.RawRow["TestB"] = "b";
            Assert.IsTrue(row.HasFieldChanged("TestA"));
            Assert.IsTrue(row.HasFieldChanged("TestB"));

            // Test returns nothing when all changed accepted
            ds.AcceptChanges();
            Assert.IsFalse(row.HasFieldChanged("TestA"));
            Assert.IsFalse(row.HasFieldChanged("TestB"));

            // Test returns nothing when changes are actually the same value
            row.RawRow["TestA"] = "a";
            row.RawRow["TestB"] = "b";
            Assert.IsFalse(row.HasFieldChanged("TestA"));
            Assert.IsFalse(row.HasFieldChanged("TestB"));

            // Test returns all columns if row added
            ds.Tables[0].Rows.Add(new object[] { "A", "B" });
            row.RawRow = ds.Tables[0].Rows[1];
            Assert.IsTrue(row.HasFieldChanged("TestA"));
            Assert.IsTrue(row.HasFieldChanged("TestB"));
        }

        [TestMethod()]
        [Description("Test BaseRow.GetChangedColumns")]
        public void GetChangedColumns()
        {
            DataSet ds = new DataSet();
            ds.Tables.Add("Test");
            ds.Tables[0].Columns.Add("TestA", typeof(string));
            ds.Tables[0].Columns.Add("TestB", typeof(string));
            ds.Tables[0].Rows.Add(new object[] { "A", "B" });

            BaseRow row = new BaseRow();
            row.RawRow = ds.Tables[0].Rows[0];
            ds.AcceptChanges();

            // Test no changes columns if accepted changed
            Assert.AreEqual(0, row.GetChangedColumns().Count());

            // Test returns single changed column
            row.RawRow["TestA"] = "a";
            Assert.AreEqual(1, row.GetChangedColumns().Count());
            Assert.AreEqual("TestA", row.GetChangedColumns().First().ColumnName);

            // Test returns both changed columns
            row.RawRow["TestB"] = "b";
            Assert.AreEqual(2, row.GetChangedColumns().Count());
            Assert.AreEqual("TestA", row.GetChangedColumns().First().ColumnName);
            Assert.AreEqual("TestB", row.GetChangedColumns().Last().ColumnName);

            // Test returns nothing when all changed accepted
            ds.AcceptChanges();
            Assert.AreEqual(0, row.GetChangedColumns().Count());

            // Test returns nothing when changes are actually the same value
            row.RawRow["TestA"] = "a";
            row.RawRow["TestB"] = "b";
            Assert.AreEqual(0, row.GetChangedColumns().Count());

            // Test returns all columns if row added
            ds.Tables[0].Rows.Add(new object[] { "A", "B" });
            row.RawRow = ds.Tables[0].Rows[1];
            Assert.AreEqual(2, row.GetChangedColumns().Count());
            Assert.AreEqual("TestA", row.GetChangedColumns().First().ColumnName);
            Assert.AreEqual("TestB", row.GetChangedColumns().Last().ColumnName);
        }

        [TestMethod()]
        [Description("Test BaseRow.HasDataChanged")]
        public void HasDataChanged()
        {
            DataSet ds = new DataSet();
            ds.Tables.Add("Test");
            ds.Tables[0].Columns.Add("TestA", typeof(string));
            ds.Tables[0].Columns.Add("TestB", typeof(string));
            ds.Tables[0].Rows.Add(new object[] { "A", "B" });

            BaseRow row = new BaseRow();
            row.RawRow = ds.Tables[0].Rows[0];
            ds.AcceptChanges();

            // Test no changes columns if accepted changed
            Assert.IsFalse(row.HasDataChanged());

            // Test returns true changed column
            row.RawRow["TestB"] = "a";
            Assert.IsTrue(row.HasDataChanged());

            // Test no changed when all changed accepted
            ds.AcceptChanges();
            Assert.IsFalse(row.HasDataChanged());

            // Test no changed when changes are actually the same value
            row.RawRow["TestB"] = "a";
            Assert.IsFalse(row.HasDataChanged());

            // Test returns true if row added
            ds.Tables[0].Rows.Add(new object[] { "A", "B" });
            row.RawRow = ds.Tables[0].Rows[1];
            Assert.IsTrue(row.HasDataChanged());
        }
    }
}
