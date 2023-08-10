using ascribe.pharmacy.manufacturinglayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace UT_Manufacturing_Layer
{
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>
    ///This is a test class for aMMShiftRowTest and is intended
    ///to contain all aMMShiftRowTest Unit Tests
    ///</summary>
    [TestClass()]
    public class aMMShiftTest
    {
        private const int SiteIdA = 15;

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
            var sessionId = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC");
            SessionInfo.InitialiseSessionAndSiteNumber(sessionId, SiteIdA);
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


        /// <summary>A test for ToDetailString</summary>
        [TestMethod()]
        public void aMMShiftRow_ToDetailStringTest()
        {
            aMMShiftRow shift = aMMShift.GetAll().Add();

            shift.Description = "Test";
            shift.StartTime = new TimeSpan( 9, 45, 0);
            shift.EndTime   = new TimeSpan(20, 30, 0);

            shift.Sunday = false;
            shift.Monday = true;
            shift.Tuesday = true;
            shift.Wednesday = true;
            shift.Thursday = true;
            shift.Friday = true;
            shift.Saturday = false;
            Assert.AreEqual("Test 09:45 to 20:30 Mon to Fri", shift.ToDetailString());

            shift.Sunday = true;
            shift.Monday = false;
            shift.Tuesday = true;
            shift.Wednesday = true;
            shift.Thursday = true;
            shift.Friday = false;
            shift.Saturday = true;
            Assert.AreEqual("Test 09:45 to 20:30 Sun, Tue to Thu, Sat", shift.ToDetailString());

            shift.Sunday = true;
            shift.Monday = false;
            shift.Tuesday = true;
            shift.Wednesday = false;
            shift.Thursday = true;
            shift.Friday = false;
            shift.Saturday = true;
            Assert.AreEqual("Test 09:45 to 20:30 Sun, Tue, Thu, Sat", shift.ToDetailString());
        }

        [TestMethod()]
        [Description("Test the aMMShiftRow.CalculateEndDateForDay method")]
        public void aMMShiftRow_CalculateEndDateForDay()
        {
            var shift = (new aMMShift()).Add();

            shift.StartTime = TimeSpan.Parse("1:00");
            shift.EndTime   = TimeSpan.Parse("14:30");
            Assert.AreEqual(DateTime.Parse("29/01/2015 14:30"), shift.CalculateEndDateForDay(DateTime.Parse("29/01/2015")));
            Assert.AreEqual(DateTime.Parse("31/01/2015 14:30"), shift.CalculateEndDateForDay(DateTime.Parse("31/01/2015 00:30")));
            Assert.AreEqual(DateTime.Parse("31/01/2015 14:30"), shift.CalculateEndDateForDay(DateTime.Parse("31/01/2015 15:30")));

            shift.StartTime = TimeSpan.Parse("18:00");
            shift.EndTime   = TimeSpan.Parse("04:30");
            Assert.AreEqual(DateTime.Parse("01/02/2015 04:30"), shift.CalculateEndDateForDay(DateTime.Parse("31/01/2015 15:30")));
        }
    }
}
