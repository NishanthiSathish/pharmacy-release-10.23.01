using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.shared;

namespace UT_Pharmacy_Shared
{
    /// <summary>
    /// Summary description for DateTimeExtensionsTest
    /// </summary>
    [TestClass]
    public class DateTimeExtensionsTest
    {
        public DateTimeExtensionsTest()
        {
            //
            // TODO: Add constructor logic here
            //
        }

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
        // [ClassInitialize()]
        // public static void MyClassInitialize(TestContext testContext) { }
        //
        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        //
        // Use TestInitialize to run code before running each test 
        // [TestInitialize()]
        // public void MyTestInitialize() { }
        //
        // Use TestCleanup to run code after each test has run
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        //
        #endregion

        [TestMethod]
        [Description("Test datetime overlap method (including equal items).")]
        public void TestDateTimeOverlapIncludeEquals()
        {
            Assert.IsFalse(DateTimeExtensions.Overlap(DateTime.Parse("24 Jun 11 13:45"), DateTime.Parse("25 Jun 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), true), "Failed correctly spotting overlap state");
            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("24 Jun 11 13:45"), DateTime.Parse("27 Jun 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), true), "Failed correctly spotting overlap state");
            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("27 Jun 11 13:45"), DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), true), "Failed correctly spotting overlap state");
            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("27 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), true), "Failed correctly spotting overlap state");
            Assert.IsFalse(DateTimeExtensions.Overlap(DateTime.Parse("01 Jul 11 13:45"), DateTime.Parse("03 Jul 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), true), "Failed correctly spotting overlap state");
            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("24 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), true), "Failed correctly spotting overlap state");

            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("24 Jun 11 13:45"), DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), true), "Failed correctly spotting overlap state");
            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), DateTime.Parse("24 Jun 11 13:45"), DateTime.Parse("28 Jun 11 13:45"), true), "Failed correctly spotting overlap state");
            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), true), "Failed correctly spotting overlap state");
        }

        [TestMethod]
        [Description("Test datetime overlap method (excluding equal items).")]
        public void TestDateTimeOverlapExcludeEquals()
        {
            Assert.IsFalse(DateTimeExtensions.Overlap(DateTime.Parse("24 Jun 11 13:45"), DateTime.Parse("25 Jun 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), false), "Failed correctly spotting overlap state");
            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("24 Jun 11 13:45"), DateTime.Parse("27 Jun 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), false), "Failed correctly spotting overlap state");
            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("27 Jun 11 13:45"), DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), false), "Failed correctly spotting overlap state");
            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("27 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), false), "Failed correctly spotting overlap state");
            Assert.IsFalse(DateTimeExtensions.Overlap(DateTime.Parse("01 Jul 11 13:45"), DateTime.Parse("03 Jul 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), false), "Failed correctly spotting overlap state");
            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("24 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), DateTime.Parse("26 Jun 11 13:45"), DateTime.Parse("29 Jun 11 13:45"), false), "Failed correctly spotting overlap state");

            Assert.IsFalse(DateTimeExtensions.Overlap(DateTime.Parse("24 Jun 11 13:45"), DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), false), "Failed correctly spotting overlap state");
            Assert.IsFalse(DateTimeExtensions.Overlap(DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), DateTime.Parse("24 Jun 11 13:45"), DateTime.Parse("28 Jun 11 13:45"), false), "Failed correctly spotting overlap state");
            Assert.IsTrue (DateTimeExtensions.Overlap(DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), DateTime.Parse("28 Jun 11 13:45"), DateTime.Parse("30 Jun 11 13:45"), false), "Failed correctly spotting overlap state");
        }

        [TestMethod]
        [Description("Test DateTime.GetAgeStr.")]
        public void TestDateTimeGetAgeStr()
        {
            DateTime asOfDate = new DateTime(2016, 08, 09, 15, 44, 00);
            Assert.AreEqual("18m 0d", (new DateTime(2015, 2,  9)).GetAgeStr(asOfDate));
            Assert.AreEqual("17m 30d",(new DateTime(2015, 2, 10)).GetAgeStr(asOfDate));
            Assert.AreEqual("26w 0d", (new DateTime(2016, 2,  9)).GetAgeStr(asOfDate));
            Assert.AreEqual("8d",     (new DateTime(2016, 8,  1)).GetAgeStr(asOfDate));
            Assert.AreEqual("6y 0m",  (new DateTime(2010, 8,  1)).GetAgeStr(asOfDate));
            Assert.AreEqual("18y",    (new DateTime(1998, 8,  9)).GetAgeStr(asOfDate));
            Assert.AreEqual("21y",    (new DateTime(1995, 8,  1)).GetAgeStr(asOfDate));
            Assert.AreEqual("2y 0m",  (new DateTime(2014, 8,  9)).GetAgeStr(asOfDate));
            Assert.AreEqual("12m 0d", (new DateTime(2015, 8,  9)).GetAgeStr(asOfDate));
            Assert.AreEqual("4w 0d",  asOfDate.AddDays(-28).GetAgeStr(asOfDate));
        }
    }
}
