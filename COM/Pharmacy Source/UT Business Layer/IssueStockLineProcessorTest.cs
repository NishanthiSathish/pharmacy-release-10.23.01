using ascribe.pharmacy.businesslayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using ascribe.pharmacy.icwdatalayer;
using System.Collections.Generic;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;

namespace Unit_Test_Business_Layer
{
    
    
    /// <summary>
    ///This is a test class for IssueStockLineProcessorTest and is intended
    ///to contain all IssueStockLineProcessorTest Unit Tests
    ///</summary>
    [TestClass()]
    public class IssueStockLineProcessorTest
    {
        private static int      SiteIdA                         = 19;
        private static string   NsvCodeA                        = "ADE685C";
        private static int      ProductStockIdA                 = 66343; 
        private static int      RequestIdDispensingA;
        private static int      RequestIdPrescriptionA;
        private static int      EpisodeIdA;              
        private static decimal  OriginalStockLevelInIssueUnitsA = 500M;
        private static decimal  OriginalCostA                   = 59M;
        private static decimal  OriginalLossesGains             = 0M;
        

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
        //[ClassInitialize()]
        //public static void MyClassInitialize(TestContext testContext)
        //{
        //}
        //
        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}

        // Use TestInitialize to run code before running each test
        [TestInitialize()]
        public void MyTestInitialize()
        {
            Database.ExecuteSQLNonQuery("UPDATE ProductStock SET lossesgains='0', cost='59', stocklvl='500'  WHERE ProductStockID={0}", ProductStockIdA);
            RequestIdDispensingA   = Database.ExecuteSQLScalar<int>("SELECT TOP 1 RequestID FROM WLabel ORDER BY RequestID desc");
            RequestIdPrescriptionA = Database.ExecuteSQLScalar<int>("SELECT TOP 1 RequestID FROM Prescription ORDER BY RequestID desc");
            EpisodeIdA             = Database.ExecuteSQLScalar<int>("SELECT TOP 1 EpisodeID FROM Episode ORDER BY EpisodeID desc");
        }
        
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //
        #endregion


        /// <summary></summary>
        [TestMethod()]
        public void IssueStockLineProcessorConstructorTest()
        {
            //IssueStockLine line = new IssueStockLine();
            //var product = WProduct.GetByProductAndSiteID(NsvCodeA, SiteIdA);

            //line.IssueType              = IssueType.DispenseInPatient;
            //line.QuantityInIssueUnits   = -10;
            //line.CostCentreCode         = "WARD1";
            //line.CostExVat              = (line.QuantityInIssueUnits * product.AverageCostExVatPerPack) / product.ConversionFactorPackToIssueUnits;
            //line.DirectionCode          = "Test");
            //line.LabelType              = WTranslogType.Discharge;
            //line.NSVCode                = NsvCodeA;
            //line.PrescriptionNumType    = PrescriptionNumType.PrescriptionNum;
            //line.RequestIdDispensing    = RequestIdDispensingA;
            //line.RequestIdPrescription  = RequestIdPrescriptionA;

            //using (IssueStockLineProcessor processor = new IssueStockLineProcessor())
            //{
            //    processor.Lock(SiteIdA, new[] { line });
            //    processor.Update(SiteIdA, EpisodeIdA, new[] { line });
            //}

            //product = WProduct.GetByProductAndSiteID(NsvCodeA, SiteIdA);
            //Assert.AreEqual(OriginalStockLevelInIssueUnitsA, product.StockLevelInIssueUnits, "Stock level should have been decremented");
        }
    }
}
