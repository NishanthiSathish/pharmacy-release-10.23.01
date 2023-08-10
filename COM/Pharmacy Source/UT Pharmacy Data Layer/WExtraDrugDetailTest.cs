// -----------------------------------------------------------------------
// <copyright file="WExtraDrugDetailTest.cs" company="Ascribe">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

namespace UT_Pharmacy_Data_Layer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using ascribe.pharmacy.pharmacydatalayer;
    using ascribe.pharmacy.shared;
    using ascribe.pharmacy.basedatalayer;
    using Microsoft.VisualStudio.TestTools.UnitTesting;

    [TestClass()]
    public class WExtraDrugDetailTest
    {
        private static int sessionId;            // both relate to rows in the session table

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
            // Get session ID (any will do)
            sessionId = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC");
            SessionInfo.InitialiseSession(sessionId);
        }
        #endregion

        [TestMethod]
        [Description("Test WExtraDrugDetail.FindLastByActiveOrExpired")]
        public void WExtraDrugDetail_FindLastByActiveOrExpired_Test()
        {
            DateTime today = DateTime.Today;
            WExtraDrugDetail detail = new WExtraDrugDetail();            

            detail.Clear();
            AddWExtraDrugDetail(detail, 1, today.AddDays(-5), today.AddDays(-3)); // Expired
            AddWExtraDrugDetail(detail, 2, today.AddDays(-2), today.AddDays(2));  // Active
            AddWExtraDrugDetail(detail, 3, null,              null);              // Due
            Assert.AreEqual(2, detail.FindLastByActiveOrExpired().WExtraDrugDetailID);

            detail.Clear();
            AddWExtraDrugDetail(detail, 1, today.AddDays(-5), today.AddDays(-3)); // Expired
            AddWExtraDrugDetail(detail, 2, today.AddDays(-2), null);              // Active
            AddWExtraDrugDetail(detail, 3, null,              null);              // Due
            Assert.AreEqual(2, detail.FindLastByActiveOrExpired().WExtraDrugDetailID);

            detail.Clear();
            AddWExtraDrugDetail(detail, 1, today.AddDays(-5), today.AddDays(-3)); // Expired
            AddWExtraDrugDetail(detail, 2, today.AddDays(-4), today.AddDays(-1)); // Expired Latest
            AddWExtraDrugDetail(detail, 3, null,              null);              // Due
            Assert.AreEqual(2, detail.FindLastByActiveOrExpired().WExtraDrugDetailID);

            detail.Clear();
            AddWExtraDrugDetail(detail, 1, today.AddDays(-8), today.AddDays(-3)); // Expired
            AddWExtraDrugDetail(detail, 2, today.AddDays(-7), today.AddDays(-5)); // Expired Latest
            AddWExtraDrugDetail(detail, 3, null,              null);              // Due
            Assert.AreEqual(2, detail.FindLastByActiveOrExpired().WExtraDrugDetailID);
        }

        private void AddWExtraDrugDetail(WExtraDrugDetail detail, int id, DateTime? dateUpdated_ByOvernighJob, DateTime? stopDate)
        {
            var newRow = detail.Add();
            detail.Table.Columns[detail.GetPKColumnName()].ReadOnly = false;
            newRow.RawRow["WExtraDrugDetailID"] = id;
            detail.Table.Columns[detail.GetPKColumnName()].ReadOnly = true;
            newRow.DateUpdated_ByOvernighJob    = dateUpdated_ByOvernighJob;
            newRow.StopDate                     = stopDate;
        }
    }
}
