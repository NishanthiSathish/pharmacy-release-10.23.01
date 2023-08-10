using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.basedatalayer;

namespace UT_Pharmacy_Data_Layer
{
    using ascribe.pharmacy.pharmacydatalayer;
    using ascribe.pharmacy.shared;

    [TestClass]
    public class Site2Test
    {
        private static int SessionID;            // both relate to rows in the session table

        //Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext)
        {
            // Get session ID (any will do)
            SessionID = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC");
        }

        [TestMethod]
        [Description("Test the string version of FindBySiteNumber")]
        public void FindBySiteNumberTest()
        {
            SessionInfo.InitialiseSessionAndSiteNumber(SessionID, 430);

            var sites = Site2.Instance();

            AreEqual(new[] { 429, 427, 428 }, sites.FindBySiteNumber("429,427,428"),     "Not converted site numbers correctly");
            AreEqual(new[] { 429, 427, 428 }, sites.FindBySiteNumber("429,427,428,427"), "Does not remove duplicates");
            AreEqual(new[] { 429, 427, 428 }, sites.FindBySiteNumber("429,427,428,555"), "Does not remove invalid sites");
            AreEqual(new int[0], sites.FindBySiteNumber((string)null), "Can handle null");
            AreEqual(new int[0], sites.FindBySiteNumber(string.Empty), "Can handle null");

            AreEqual(new int[0], sites.FindBySiteNumber("All", allowAll: false), "Does skip all");
            AreEqual(new int[0], sites.FindBySiteNumber("All"), "Does not default to allowAll=false");
            AreEqual(new[] { 426, 427, 428, 429, 430 }, sites.FindBySiteNumber("All", allowAll: true), "Does not load all sites");
            AreEqual(new int[0], sites.FindBySiteNumber((string)null, allowAll: true), "Can handle null");
            AreEqual(new int[0], sites.FindBySiteNumber(string.Empty, allowAll: true), "Can handle null");

            AreEqual(new[] { 430, 429, 427, 428 },      sites.FindBySiteNumber("429,427,428",     allowAll: false, currentSite: CurrentSiteHandling.AtStart), "Does add current site to start");
            AreEqual(new[] { 430, 429, 427, 428 },      sites.FindBySiteNumber("429,427,428,430", allowAll: false, currentSite: CurrentSiteHandling.AtStart), "Does add current site to start");
            AreEqual(new[] { 430, 426, 427, 428, 429 }, sites.FindBySiteNumber("All",             allowAll: true,  currentSite: CurrentSiteHandling.AtStart), "Does add current site to start");
            AreEqual(new[] { 430 }, sites.FindBySiteNumber((string)null, allowAll: true, currentSite: CurrentSiteHandling.AtStart), "Can handle null");
            AreEqual(new[] { 430 }, sites.FindBySiteNumber(string.Empty, allowAll: true, currentSite: CurrentSiteHandling.AtStart), "Can handle null");

            AreEqual(new[] { 429, 427, 428 },      sites.FindBySiteNumber("429,430,427,428", allowAll: false, currentSite: CurrentSiteHandling.Remove), "Does not remove current site");
            AreEqual(new[] { 426, 427, 428, 429 }, sites.FindBySiteNumber("All",             allowAll: true,  currentSite: CurrentSiteHandling.Remove), "Does not remove current site");
            AreEqual(new[] { 429, 427, 428 },      sites.FindBySiteNumber("429,427,428",     allowAll: false, currentSite: CurrentSiteHandling.Remove), "Does not remove current site");
        }

        private static void AreEqual(IEnumerable<int> expectedSiteNumbers, IEnumerable<Site2Row> actual, string message)
        {
            if (expectedSiteNumbers.Count() != actual.Count())
                Assert.Fail(message);

            for (int c = 0; c < expectedSiteNumbers.Count(); c++)
            {
                if (expectedSiteNumbers.ElementAt(c) != actual.ElementAt(c).SiteNumber)
                    Assert.Fail(message);
            }
        }
    }
}
