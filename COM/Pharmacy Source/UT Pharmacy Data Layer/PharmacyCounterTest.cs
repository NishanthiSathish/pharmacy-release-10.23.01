//===========================================================================
//
//							      Pharmacycounter.cs
//
//  Holds tests for the PharmacyCounter class.
//
//  Test should be run from within Visual Studio.  
//
//	Modification History:
//	18Jan10 XN  Written
//===========================================================================
using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.pharmacydatalayer;
using System.Configuration;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;

namespace UT_Pharmacy_Data_Layer
{
    /// <summary>
    ///This is a test class for PharmacyCounterTest and is intended
    ///to contain all PharmacyCounterTest Unit Tests
    /// </summary>
    [TestClass]
    public class PharmacyCounterTest
    {
        string[] expectedYearCharStr = new [] { "Q" /*2016*/, "R" /*2017*/, "S" /*2018*/, "T" /*2019*/, "U" /*2020*/, "V" /*2021*/, "W" /*2022*/, "X" /*2023*/, "Y" /*2024*/, "Z", "a", "b", "c", "d", "e", "f", "g" };

        public PharmacyCounterTest()
        {
            //
            // TODO: Add constructor logic here
            //
        }

        static private int SessionID;           
            
        static private int siteID;                          // site Id

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
        //
        // Use ClassInitialize to run code before running the first test in the class

        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext) 
        { 
            Configuration conf = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            ConnectionStringsSection connectionStrSect = conf.ConnectionStrings;

            // Get a sesssion ID (any will do)
            SessionID = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC");
            siteID    = Database.ExecuteSQLScalar<int>("SELECT TOP 1 LocationID FROM [Site] ORDER BY SiteNumber");
        }

        //
        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        //
        // Use TestInitialize to run code before running each test 
        [TestInitialize()]
        public void MyTestInitialize() 
        { 
            // Initalise the SessionInfo class
            SessionInfo.InitialiseSessionAndSiteID(SessionID, siteID);        
        }
        
        // Use TestCleanup to run code after each test has run
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        //
        #endregion

        [TestMethod]
        [Description("Test tha PharmacyCounter.GetNextCount returns the next count")]
        public void TestIncrementsTheCount()
        {           
            PharmacyCounter counters;

            // Setup dummy conters
            CreateCounters("TestIncrementsTheCount", "Test", "A", 1);
            counters = CreateCounters("TestIncrementsTheCount", "Test", "B", 45);
            CreateCounters("TestIncrementsTheCount", "Test", "C", 1);

            // check the counter increments correctly
            int nextCount = PharmacyCounter.GetNextCount(siteID, "TestIncrementsTheCount", "Test", "B");
            Assert.AreEqual(46, nextCount, "Failed to increament the count");
        }

        [TestMethod]
        [Description("Test tha PharmacyCounter.GetNextCount does not reset if PharmacyCounterResetType set to None")]
        public void TestDoesNotResetIfResetTypeIsNone()
        {           
            PharmacyCounter counters;

            // Setup dummy counters
            CreateCounters("TestIncrementsTheCount", "Test", "A", 1);
            counters = CreateCounters("TestIncrementsTheCount", "Test", "B", 45);
            CreateCounters("TestIncrementsTheCount", "Test", "C", 1);

            // Set the updateDateTime to previous day, set ResetDateTime to prevous hour
            counters[0].UpdateDateTime = DateTime.Now.AddDays(-1);
            counters[0].ResetDateTime  = DateTime.Now.AddHours(-1);
            counters.Save();

            // check the counter increments correctly
            int nextCount = PharmacyCounter.GetNextCount(siteID, "TestIncrementsTheCount", "Test", "B");
            Assert.AreEqual(46, nextCount, "Failed to increament the count");
        }

        [TestMethod]
        [Description("Test tha PharmacyCounter.GetNextCount does not reset if PharmacyCounterResetType set to Daily")]
        public void TestResetIfResetTypeIsDaily()
        {           
            PharmacyCounter counters;

            // Setup dummy counters
            CreateCounters("TestIncrementsTheCount", "Test", "A", 1);
            counters = CreateCounters("TestIncrementsTheCount", "Test", "B", 45);
            CreateCounters("TestIncrementsTheCount", "Test", "C", 1);

            // Setup to reset daily, and set last update to previous day
            counters[0].ResetType      = PharmacyCounterResetType.Daily;
            counters[0].UpdateDateTime = DateTime.Now.AddDays(-1);
            counters.Save();

            // check the counter resets
            int nextCount = PharmacyCounter.GetNextCount(siteID, "TestIncrementsTheCount", "Test", "B");
            Assert.AreEqual(1, nextCount, "Failed to reset the count");

            // Check the counter increments correctly
            nextCount = PharmacyCounter.GetNextCount(siteID, "TestIncrementsTheCount", "Test", "B");
            Assert.AreEqual(2, nextCount, "Failed to increament the count");
        }

        [TestMethod]
        [Description("Test tha PharmacyCounter.GetNextCount does not reset if PharmacyCounterResetType set to ByDate")]
        public void TestResetIfResetTypeIsByDate()
        {           
            PharmacyCounter counters;

            // Setup dummy counters
            CreateCounters("TestIncrementsTheCount", "Test", "A", 1);
            counters = CreateCounters("TestIncrementsTheCount", "Test", "B", 45);
            CreateCounters("TestIncrementsTheCount", "Test", "C", 1);

            // Setup to reset by date, and set last update to previous hour, and reset time to previous half hour
            counters[0].ResetType      = PharmacyCounterResetType.ByDate;
            counters[0].UpdateDateTime = DateTime.Now.AddHours(-1.0);
            counters[0].ResetDateTime  = DateTime.Now.AddHours(-0.5);
            counters.Save();

            // check the counter resets
            int nextCount = PharmacyCounter.GetNextCount(siteID, "TestIncrementsTheCount", "Test", "B");
            Assert.AreEqual(1, nextCount, "Failed to reset the count");

            // Check the counter increments correctly
            nextCount = PharmacyCounter.GetNextCount(siteID, "TestIncrementsTheCount", "Test", "B");
            Assert.AreEqual(2, nextCount, "Failed to increament the count");
        }

        [TestMethod]
        [Description("Test tha PharmacyCounter.GetNextCount formats the count correctly")]
        public void TestFormattingOfCount()
        {           
            int expectedResult;
            DateTime now;

            // Basic testing
            TestFormatString(45, null,                            46);
            TestFormatString(45, string.Empty,                    46);
            TestFormatString(45, "{Count}",                       46);
            TestFormatString(45, "{Count:000}",                   46);
            TestFormatString(45, "10{Count:000}",                 10046);

            // Test with date
            now = DateTime.Now;
            expectedResult = (int.Parse(now.ToString("yyMMdd")) * 1000) + 46;
            TestFormatString(45, "{DateTime:yyMMdd}{Count:000}",  expectedResult);
           
            now = DateTime.Now;
            expectedResult = int.Parse(now.ToString("yyMMddhhmm"));
            TestFormatString(45, "{DateTime:yyMMddhhmm}",  expectedResult);
        }

        [TestMethod]
        [Description("Test the YearChar format string")]
        public void TestYearCharFormatString()
        {
            var counter = CreateCounters("TestYearChar", "Test", "Test", 45);
            counter[0].FormatString = "{YearChar}";
            counter.Save();
            
            Assert.AreEqual(expectedYearCharStr[DateTime.Now.Year - 2016], PharmacyCounter.GetNextCountStr(siteID, "TestYearChar", "Test", "Test"));
        }

        [TestMethod]
        [Description("Test a typical manufacturing format string")]
        public void TestManufacturignCounter()
        {
            var counter = CreateCounters("TestYearChar", "Test", "Test", 45);
            counter[0].FormatString = "M{YearChar}{DateTime:MMdd}{Count:000}";
            counter.Save();

            var now = DateTime.Now;
            
            string expected = "M" + expectedYearCharStr[now.Year - 2016] + now.ToString("MMdd") + "046";
            Assert.AreEqual(expected, PharmacyCounter.GetNextCountStr(siteID, "TestYearChar", "Test", "Test"));
            
            expected = "M" + expectedYearCharStr[now.Year - 2016] + now.ToString("MMdd") + "047";
            Assert.AreEqual(expected, PharmacyCounter.GetNextCountStr(siteID, "TestYearChar", "Test", "Test"));
        }

        [TestMethod]
        [Description("Test a typical manufacturing format string wraps correctly")]
        public void TestManufacturignCounterTestWrap()
        {
            var counter = CreateCounters("TestYearChar", "Test", "Test", 998);
            counter[0].FormatString = "M{YearChar}{DateTime:MMdd}{Count:000}";
            counter.Save();

            var now = DateTime.Now;
            
            string expected = "M" + expectedYearCharStr[now.Year - 2016] + now.ToString("MMdd") + "999";
            Assert.AreEqual(expected, PharmacyCounter.GetNextCountStr(siteID, "TestYearChar", "Test", "Test"));
            
            expected = "M" + expectedYearCharStr[now.Year - 2016] + now.ToString("MMdd") + "1000";
            Assert.AreEqual(expected, PharmacyCounter.GetNextCountStr(siteID, "TestYearChar", "Test", "Test"));
        }

        /// <summary>Test that the FormatString</summary>
        /// <param name="initalCount">Inital number count</param>
        /// <param name="formatString">format string to set</param>
        /// <param name="expectedResult">expected result</param>
        public void TestFormatString(int initalCount, string formatString, int expectedResult)
        {
            PharmacyCounter counters;

            // Setup dummy counters
            CreateCounters("TestIncrementsTheCount", "Test", "A", 1);
            counters = CreateCounters("TestIncrementsTheCount", "Test", "B", initalCount);
            CreateCounters("TestIncrementsTheCount", "Test", "C", 1);

            // Setup the format string
            counters[0].FormatString = formatString;
            counters.Save();

            // check the counter resets
            int nextCount = PharmacyCounter.GetNextCount(siteID, "TestIncrementsTheCount", "Test", "B");
            Assert.AreEqual(expectedResult, nextCount, "Failed to format count correctly");
        }

        /// <summary>Insert or updates a database counter value</summary>
        /// <param name="system">System</param>
        /// <param name="section">Section</param>
        /// <param name="key">Key</param>
        /// <param name="count">Counter value to set to</param>
        /// <returns>PharmacyCounter table with inserted or updated row</returns>
        public PharmacyCounter CreateCounters(string system, string section, string key, int count)
        {
            PharmacyCounter counters = new PharmacyCounter(RowLocking.Enabled);

            // Load in existing counter
            counters.LoadBySiteSystemSetionAndKey(siteID, system, section, key);
            if (!counters.Any())
            {
                // Counter does not exist so add
                counters.Add();
                counters[0].SiteID               = siteID;
                counters[0].System               = system;
                counters[0].Section              = section;
                counters[0].Key                  = key;
                counters[0].RawRow["SessionLock"]= 0;
            }

            // Update the existing counter
            counters[0].FormatString   = string.Empty;
            counters[0].LastCount      = count;
            counters[0].UpdateDateTime = DateTime.Now;
            counters[0].ResetType      = PharmacyCounterResetType.None;
            counters[0].ResetDateTime  = null;

            // Save
            counters.Save();
            counters.UnlockRows();

            return counters;
        }
    }
}
