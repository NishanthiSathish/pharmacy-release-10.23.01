using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UT_Manufacturing_Layer
{
    using ascribe.pharmacy.manufacturinglayer;
    using ascribe.pharmacy.pharmacydatalayer;
    using ascribe.pharmacy.shared;
    using ascribe.pharmacy.basedatalayer;
    using System.Reflection;
    using System.Data.SqlClient;
    using ascribe.pharmacy.icwdatalayer;

    [TestClass]
    public class aMMProcessorTest
    {
        private const int SiteIdA = 15;

        #region Additional test attributes
        //
        // You can use the following additional attributes as you write your tests:
        //
        
        // Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext)
        {
            PrivateType type = new PrivateType(typeof(PharmacyDataCache));
            type.InvokeStatic("ClearCaches");

            // Get session ID (any will do)
            var sessionId = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC");
            SessionInfo.InitialiseSessionAndSiteID(sessionId, SiteIdA);

            // Add container volume for syringes volume testing
            Database.ExecuteSQLNonQuery("DELETE FROM WConfiguration WHERE Category='D|CONTAINER'");                         
            Database.ExecuteSQLNonQuery("insert into WConfiguration (SiteID, Category, Section, [Key], Value, DSS) values ({0}, 'D|CONTAINER', '', '1', '\"V|VIAL|100|0|100\"', 0)", SiteIdA);
            Database.ExecuteSQLNonQuery("insert into WConfiguration (SiteID, Category, Section, [Key], Value, DSS) values ({0}, 'D|CONTAINER', '', '2', '\"S|SYRINGE|2|0|1.8\"', 0)", SiteIdA);
            Database.ExecuteSQLNonQuery("insert into WConfiguration (SiteID, Category, Section, [Key], Value, DSS) values ({0}, 'D|CONTAINER', '', '3', '\"S|SYRINGE|20|0|18\"', 0)", SiteIdA);
            Database.ExecuteSQLNonQuery("insert into WConfiguration (SiteID, Category, Section, [Key], Value, DSS) values ({0}, 'D|CONTAINER', '', '4', '\"S|SYRINGE|60|0|55\"', 0)", SiteIdA);
            Database.ExecuteSQLNonQuery("insert into WConfiguration (SiteID, Category, Section, [Key], Value, DSS) values ({0}, 'D|CONTAINER', '', 'Total', '\"4\"', 0)", SiteIdA);
        }
        
        // Use ClassCleanup to run code after all tests in a class have run
        [ClassCleanup()]
        public static void MyClassCleanup() 
        { 
            // Remove all container volumes
            Database.ExecuteSQLNonQuery("DELETE FROM WConfiguration WHERE Category='D|CONTAINER'");                         
        }

        // Use TestInitialize to run code before running each test 
        // [TestInitialize()]
        // public void MyTestInitialize() { }
        // 
        // Use TestCleanup to run code after each test has run
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        #endregion

        [TestMethod]
        [Description("Test CalculateVolume error if DisplacementVolumeInml, and ReconstitutionVolumeInml, are both null or 0")]
        public void Test_CalculateVolume_ErrorIfVolumeNotSet()
        {
            WProduct product = new WProduct();
            WProductRow p = product.Add();

            var result = aMMProcessor.CalculateVolume(10, aMMVolumeType.Fixed, 10, p);
            Assert.AreNotEqual(string.Empty, result.Error, "Does not report error if DisplacementVolumeInml, and ReconstitutionVolumeInml, are both null");

            p.DisplacementVolumeInml   = 0;
            p.ReconstitutionVolumeInml = 0;
            result = aMMProcessor.CalculateVolume(10, aMMVolumeType.Fixed, 10, p);
            Assert.AreNotEqual(string.Empty, result.Error, "Does not report error if DisplacementVolumeInml, and ReconstitutionVolumeInml, are both 0");

            p.DisplacementVolumeInml   = 20;
            p.ReconstitutionVolumeInml = 20;
            result = aMMProcessor.CalculateVolume(10, aMMVolumeType.Fixed, 10, p);
            Assert.AreNotEqual(string.Empty, result.Error, "Does not report error if DosesPerIssueUnit is 0");
        }

        [TestMethod]
        [Description("Test CalculateVolume for InitialDrugConcenrationPermL")]
        public void Test_CalculateVolume_InitialDrugConcenrationPermL()
        {
            WProduct product = new WProduct();
            WProductRow p = product.Add();

            // InitialDrugConcenrationPermL = DosesPerIssueUnit / (DisplacementVolumeInml + ReconstitutionVolumeInml)

            // Test 1 
            p.DosesPerIssueUnit        = 500;
            p.DisplacementVolumeInml   = 250;
            p.ReconstitutionVolumeInml = 0;
            var result = aMMProcessor.CalculateVolume(60, aMMVolumeType.Fixed, 10, p);
            Assert.AreEqual(2, result.InitialDrugConcenrationPermL, "Failed to calculate InitialDrugConcenrationPermL correctly");

            // Test 2
            p.DosesPerIssueUnit        = 250;
            p.DisplacementVolumeInml   = 0;
            p.ReconstitutionVolumeInml = 250;
            result = aMMProcessor.CalculateVolume(250, aMMVolumeType.Fixed, 10, p);
            Assert.AreEqual(1, result.InitialDrugConcenrationPermL, "Failed to calculate InitialDrugConcenrationPermL correctly");            
        }

        [TestMethod]
        [Description("Test CalculateVolume for InitialVolumeInmL")]
        public void Test_CalculateVolume_InitialVolumeInmL()
        {
            WProduct product = new WProduct();
            WProductRow p = product.Add();

            // InitialVolumeInmL = Dose / (DosesPerIssueUnit / (DisplacementVolumeInml + ReconstitutionVolumeInml))

            // Test 1 
            p.DosesPerIssueUnit        = 500;
            p.DisplacementVolumeInml   = 250;
            p.ReconstitutionVolumeInml = 0;
            var result = aMMProcessor.CalculateVolume(60, aMMVolumeType.Fixed, 10, p);
            Assert.AreEqual(30, result.InitialVolumeInmL, "Failed to calculate InitialDrugConcenrationPermL correctly");

            // Test 2
            p.DosesPerIssueUnit        = 250;
            p.DisplacementVolumeInml   = 0;
            p.ReconstitutionVolumeInml = 250;
            result = aMMProcessor.CalculateVolume(250, aMMVolumeType.Fixed, 10, p);
            Assert.AreEqual(250, result.InitialVolumeInmL, "Failed to calculate InitialDrugConcenrationPermL correctly");            
        }

        [TestMethod]
        [Description("Test CalculateVolume for DrugPlusNominalVolumeInmL")]
        public void Test_CalculateVolume_DrugPlusNominalVolumeInmL()
        {
            WProduct product = new WProduct();
            WProductRow p = product.Add();

            // InitialVolumeInmL = InitialVolumeInmL + Fixed Volume

            // Test 1 
            p.DosesPerIssueUnit        = 500;
            p.DisplacementVolumeInml   = 250;
            p.ReconstitutionVolumeInml = 0;
            var result = aMMProcessor.CalculateVolume(60, aMMVolumeType.Fixed, 250, p);
            Assert.AreEqual(275, result.DrugPlusNominalVolumeInmL, "Failed to calculate InitialDrugConcenrationPermL correctly");

            // Test 2
            p.DosesPerIssueUnit        = 250;
            p.DisplacementVolumeInml   = 0;
            p.ReconstitutionVolumeInml = 250;
            result = aMMProcessor.CalculateVolume(250, aMMVolumeType.DrugAndNominal, 250, p);
            Assert.AreEqual(275, result.DrugPlusNominalVolumeInmL, "Failed to calculate InitialDrugConcenrationPermL correctly");            
        }

        [TestMethod]
        [Description("Test CalculateVolume for SelectedVolumeInmL")]
        public void Test_CalculateVolume_SelectedVolumeInmL()
        {
            WProduct product = new WProduct();
            WProductRow p = product.Add();

            // Test 1 a
            p.DosesPerIssueUnit        = 500;
            p.DisplacementVolumeInml   = 250;
            p.ReconstitutionVolumeInml = 0;

            var result = aMMProcessor.CalculateVolume(60, aMMVolumeType.Fixed, 250, p);
            Assert.AreEqual(250, result.SelectedVolumeInmL, "Failed to calculate SelectedVolumeInmL correctly");

            result = aMMProcessor.CalculateVolume(60, aMMVolumeType.DrugAndNominal, 250, p);
            Assert.AreEqual(275, result.SelectedVolumeInmL, "Failed to calculate SelectedVolumeInmL correctly");

            // Test 2
            p.DosesPerIssueUnit        = 250;
            p.DisplacementVolumeInml   = 0;
            p.ReconstitutionVolumeInml = 250;

            result = aMMProcessor.CalculateVolume(250, aMMVolumeType.Fixed, 250, p);
            Assert.AreEqual(250, result.SelectedVolumeInmL, "Failed to calculate SelectedVolumeInmL correctly");            

            result = aMMProcessor.CalculateVolume(250, aMMVolumeType.DrugAndNominal, 250, p);
            Assert.AreEqual(275, result.SelectedVolumeInmL, "Failed to calculate SelectedVolumeInmL correctly");            
        }

        [TestMethod]
        [Description("Test CalculateVolume does not crash if dose is 0")]
        public void Test_CalculateVolume_ZeroDose()
        {
            WProduct product = new WProduct();
            WProductRow p = product.Add();
            p.DosesPerIssueUnit        = 500;
            p.DisplacementVolumeInml   = 250;
            p.ReconstitutionVolumeInml = 0;
            aMMProcessor.CalculateVolume(0, aMMVolumeType.Fixed, 250, p);
        }

        [TestMethod]
        [Description("Test CalculateVolume does not crash if fixed volume is 0")]
        public void Test_CalculateVolume_ZeroFixVolume()
        {
            WProduct product = new WProduct();
            WProductRow p = product.Add();
            p.DosesPerIssueUnit        = 500;
            p.DisplacementVolumeInml   = 250;
            p.ReconstitutionVolumeInml = 0;
            aMMProcessor.CalculateVolume(0, aMMVolumeType.Fixed, 0, p);
        }

        [TestMethod]
        [Description("Test CalculateNumberOfSyringes")]
        public void Test_CalculateNumberOfSyringes()
        {
            WProduct products = new WProduct();
            WProductRow product = products.Add();
            product.IVContainer = "S";

            // Uses the config setting D|container which has the largest volume for a syringe of 55mL
            Assert.AreEqual(1, aMMProcessor.CalculateNumberOfContainers(12.0, product), "Failed to calculate correct number of syringes");
            Assert.AreEqual(1, aMMProcessor.CalculateNumberOfContainers(55.0, product), "Failed to calculate correct number of syringes");
            Assert.AreEqual(2, aMMProcessor.CalculateNumberOfContainers(109.0,product), "Failed to calculate correct number of syringes");
            Assert.AreEqual(3, aMMProcessor.CalculateNumberOfContainers(165.0,product), "Failed to calculate correct number of syringes");
        }

        [TestMethod]
        [Description("Test CalculateSyringeEvenSplit")]
        public void Test_CalculateSyringeEvenSplit()
        {
            double dose, volume;

            WProduct products = new WProduct();
            WProductRow product = products.Add();
            product.IVContainer = "S";

            // Uses the config setting D|container which has the largest volume for a syringe of 55mL

            // Test single syringe
            aMMProcessor.CalculateSyringeEvenSplit(25, 12, out dose, out volume, product);
            Assert.AreEqual(25, dose,   "Failed to calculate the dose correctly");
            Assert.AreEqual(12, volume, "Failed to calculate the volume correctly");

            // Test 2 syringes
            aMMProcessor.CalculateSyringeEvenSplit(25, 109, out dose, out volume, product);
            Assert.AreEqual(12.5, dose,   "Failed to calculate the dose correctly");
            Assert.AreEqual(54.5, volume, "Failed to calculate the volume correctly");
        }

        [TestMethod]
        [Description("Test CalculateSyringeFullAndPart")]
        public void Test_CalculateSyringeFullAndPart()
        {
            double dose, volume, finalDose, finalVolume;

            // Uses the config setting D|container which has the largest volume for a syringe of 55mL

            // Test single syringe
            aMMProcessor.CalculateSyringeFullAndPart(25, 12, out dose, out volume, out finalDose, out finalVolume);
            Assert.AreEqual(25, dose,   "Failed to calculate the dose correctly");
            Assert.AreEqual(12, volume, "Failed to calculate the volume correctly");
            Assert.AreEqual(25, finalDose,   "Failed to calculate the final dose correctly");
            Assert.AreEqual(12, finalVolume, "Failed to calculate the final volume correctly");

            // Test 2 syringes
            aMMProcessor.CalculateSyringeFullAndPart(25, 109, out dose, out volume, out finalDose, out finalVolume);
            Assert.AreEqual(12.61, dose, 0.005, "Failed to calculate the dose correctly");
            Assert.AreEqual(55, volume, "Failed to calculate the volume correctly");
            Assert.AreEqual(12.39, finalDose, 0.005, "Failed to calculate the final dose correctly");
            Assert.AreEqual(54, finalVolume, "Failed to calculate the final volume correctly");

            // Test 3 full syringes
            aMMProcessor.CalculateSyringeFullAndPart(25, 165, out dose, out volume, out finalDose, out finalVolume);
            Assert.AreEqual(8.33, dose, 0.005, "Failed to calculate the dose correctly");
            Assert.AreEqual(55, volume, "Failed to calculate the volume correctly");
            Assert.AreEqual(8.33, finalDose, 0.005, "Failed to calculate the final dose correctly");
            Assert.AreEqual(55, finalVolume, "Failed to calculate the final volume correctly");
        }

        [TestMethod]
        [Description("Test calculation of the number of labels")]
        public void TestNumberOfLabels()
        {
            Assert.AreEqual(35, TestNumberOfLabels(2, 0, "1", "1", 3, 5));
            Assert.AreEqual(35, TestNumberOfLabels(2, 1, "1", "1", 3, 5));
            Assert.AreEqual(40, TestNumberOfLabels(2, 2, "1", "1", 3, 5));
            Assert.AreEqual(40, TestNumberOfLabels(2, 0, "2", "3", 3, 5));
            Assert.AreEqual(70, TestNumberOfLabels(0, 0, "2", "3", 3, 5));
            Assert.AreEqual(15, TestNumberOfLabels(0, 0, "0", "0", 3, 5));
            Assert.AreEqual(65, TestNumberOfLabels(2, 1, "1", "1", (decimal)5.5, 5));
            Assert.AreEqual(25, TestNumberOfLabels(0, 0, "2", "B", 3, 5));  // spareCIVASlabelsDose can be B!!!!
            Assert.AreEqual(15, TestNumberOfLabels(0, 0, "B", "B", 3, 5));
        }

        private static int TestNumberOfLabels(int numberOfLabels, int extraLabels, string spareCIVASlabelsBatch, string spareCIVASlabelsDose, decimal supplyRequestQty, int numberOfSyringes)
        {
            Type aMMProcessorType = typeof(aMMProcessor);
            var constructor = aMMProcessorType.GetConstructor(BindingFlags.NonPublic|BindingFlags.Instance, null, new Type[0], null);
            var processor = (constructor.Invoke(null) as aMMProcessor);

            WFormulaRow formula = (new WFormula()).Add();
            formula.ExtraLabels     = extraLabels;
            formula.NumberOfLabels  = numberOfLabels;
            var property = aMMProcessorType.GetProperty("Formula", BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
            property.SetValue(processor, formula, null);

            WConfiguration.Save(SiteIdA, "D|PATMED", string.Empty, "SpareCIVASlabelsBatch", spareCIVASlabelsBatch, false);
            WConfiguration.Save(SiteIdA, "D|PATMED", string.Empty, "SpareCIVASlabelsDose",  spareCIVASlabelsDose,  false);

            aMMSupplyRequest supplyRequest = new aMMSupplyRequest();
            supplyRequest.Add();
            supplyRequest[0].QuantityRequested= supplyRequestQty;
            supplyRequest[0].NumberOfSyringes = numberOfSyringes;
            var field = aMMProcessorType.GetField("supplyRequest", BindingFlags.Instance | BindingFlags.NonPublic);
            field.SetValue(processor, supplyRequest);

            return processor.CalculateNumberOfLabels();
        }

        [TestMethod]
        [Description("Test update of the expiry date")]
        public void TestUpdateExpiryDate()
        {
            TestUpdateExpiryDate("29/01/2016 15:50", "29/01/2016 15:00", 50, "29/01/2016 15:00", null, 50, true );      // calc from manufacture date + 50
            //TestUpdateExpiryDate("29/01/2016 15:50", "29/01/2016 15:00", 50, "29/01/2016 15:00", null, 50, false);      // calc from manufacture date + 50
            TestUpdateExpiryDate(null, null, null, "29/01/2016 15:00", null, 50, false);
            TestUpdateExpiryDate("29/01/2016 15:50", "29/01/2016 15:00", 50, "29/01/2016 15:00", null, 50, true , "29/02/2016 15:00", "29/02/2016 15:00");  // calc from manufacture date + 50
            //TestUpdateExpiryDate("29/01/2016 15:50", "29/01/2016 15:00", 50, "29/01/2016 15:00", null, 50, false, "29/02/2016 15:00", "29/02/2016 15:00");  // calc from manufacture date + 50
            TestUpdateExpiryDate(null, null, null, "29/01/2016 15:00", null, 50, false, "29/02/2016 15:00", "29/02/2016 15:00"); 
            TestUpdateExpiryDate("29/01/2016 15:35", "29/01/2016 15:00", 35, "29/01/2016 15:00", null, 50, true , "29/02/2016 15:00", "29/01/2016 15:35");  // ingredient expiry is lower so use that
            //TestUpdateExpiryDate("29/01/2016 15:35", "29/01/2016 15:00", 35, "29/01/2016 15:00", null, 50, false, "29/01/2016 15:35", "29/02/2016 15:00");  // ingredient expiry is lower so use that
            TestUpdateExpiryDate(null, null, null, "29/01/2016 15:00", null, 50, false, "29/01/2016 15:35", "29/02/2016 15:00");

            TestUpdateExpiryDate("29/01/2016 16:00", "29/01/2016 15:00", 60, "29/01/2016 15:00", "29/01/2016 16:00", 60, true );    // calc from manufacture date + 60
            TestUpdateExpiryDate("29/01/2016 17:00", "29/01/2016 16:00", 60, "29/01/2016 15:00", "29/01/2016 16:00", 60, false);    // calc from compounding date + 60
            TestUpdateExpiryDate("29/01/2016 16:00", "29/01/2016 15:00", 60, "29/01/2016 15:00", "29/01/2016 16:00", 60, true , "29/02/2016 15:00", "29/02/2016 15:00");    // calc from manufacture date + 60
            TestUpdateExpiryDate("29/01/2016 17:00", "29/01/2016 16:00", 60, "29/01/2016 15:00", "29/01/2016 16:00", 60, false, "29/02/2016 15:00", "29/02/2016 15:00");    // calc from compounding date + 60
            TestUpdateExpiryDate("29/01/2016 15:35", "29/01/2016 15:00", 35, "29/01/2016 15:00", "29/01/2016 16:00", 60, true , "29/02/2016 15:00", "29/01/2016 15:35");    // ingredient expiry is lower so use that
            TestUpdateExpiryDate("29/01/2016 15:35", "29/01/2016 16:00", -25,"29/01/2016 15:00", "29/01/2016 16:00", 60, false, "29/01/2016 15:35", "29/02/2016 15:00");    // ingredient expiry is lower so use that

            TestUpdateExpiryDate(null, null, null, null, null, 60, true);
            TestUpdateExpiryDate(null, null, null, null, null, 60, false);
            TestUpdateExpiryDate(null, null, null, null, null, 60, true, "29/02/2016 15:00", "29/02/2016 15:00");
            TestUpdateExpiryDate(null, null, null, null, null, 60, false,"29/02/2016 15:00", "29/02/2016 15:00");
        }

        private void TestUpdateExpiryDate(string expectedExpiryDateStr, 
                                          string expectedExpiryDateFromStr,
                                          int? expectedExpiryDurationInMintues,  
                                          string manufactureDateStr, 
                                          string compoundDateStr, 
                                          int drugExpiryTimeInMins, 
                                          bool expiryDateFromShiftStartDate,
                                          params string[] ingExpiryDateStr)
        {
            DateTime? expectedExpiryDate     = string.IsNullOrEmpty(expectedExpiryDateStr)     ? (DateTime?)null : DateTime.Parse(expectedExpiryDateStr);
            DateTime? expectedExpiryDateFrom = string.IsNullOrEmpty(expectedExpiryDateFromStr) ? (DateTime?)null : DateTime.Parse(expectedExpiryDateFromStr);
            DateTime? manufactureDate        = string.IsNullOrEmpty(manufactureDateStr)        ? (DateTime?)null : DateTime.Parse(manufactureDateStr);
            DateTime? compoundDate           = string.IsNullOrEmpty(compoundDateStr)           ? (DateTime?)null : DateTime.Parse(compoundDateStr);

            Type aMMProcessorType = typeof(aMMProcessor);
            var constructor = aMMProcessorType.GetConstructor(BindingFlags.NonPublic|BindingFlags.Instance, null, new Type[0], null);
            var processor = (constructor.Invoke(null) as aMMProcessor);

            aMMSupplyRequest supplyRequest = new aMMSupplyRequest();
            supplyRequest.Add();
            supplyRequest[0].ManufactureDate = manufactureDate;
            supplyRequest[0].CompoundingDate = compoundDate;
            supplyRequest[0].NSVCode = "ASD345S";
            supplyRequest[0].SiteID  = 19;
            supplyRequest[0].Description = string.Empty;
            supplyRequest[0].EpisodeID = 0;
            supplyRequest[0].WFormulaID = Database.ExecuteSQLScalar<int>("SELECT MAX(WFormulaID) FROM WFormula");
            supplyRequest[0].BatchNumber = string.Empty;
            supplyRequest[0].Dose = 0;
            supplyRequest[0].UnitIdDose = 0;
            supplyRequest[0].UnitID_Quantity = 0;
            supplyRequest[0].EpisodeType = EpisodeType.InPatient;
            var field = aMMProcessorType.GetField("supplyRequest", BindingFlags.Instance | BindingFlags.NonPublic);
            field.SetValue(processor, supplyRequest);

            WProduct products = new WProduct();
            products.Add();
            products[0].NSVCode = "ASD345S";
            products[0].SiteID  = 19;
            products[0].ExpiryTimeInMintues = drugExpiryTimeInMins;
            field = aMMProcessorType.GetField("products", BindingFlags.Instance | BindingFlags.NonPublic);
            field.SetValue(processor, products);

            aMMSupplyRequestIngredient ingredients = new aMMSupplyRequestIngredient();
            foreach (var dateStr in ingExpiryDateStr)
            {
                ingredients.Add();
                ingredients.Last().ExpiryDate = string.IsNullOrEmpty(dateStr) ? (DateTime?)null : DateTime.Parse(dateStr);
            }
            var property = aMMProcessorType.GetProperty("SupplyRequestIngredients", BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
            property.SetValue(processor, ingredients, null);

            WConfiguration.Save(SessionInfo.SiteID, "D|AMM", string.Empty, "ExpiryDateFromShiftStartDate", expiryDateFromShiftStartDate.ToYNString(), false);

            processor.UpdateSupplyRequestExpiry();

            Assert.AreEqual(expectedExpiryDate,              supplyRequest[0].ExpiryDate);
            Assert.AreEqual(expectedExpiryDateFrom,          supplyRequest[0].ExpiryFromDate);
            Assert.AreEqual(expectedExpiryDurationInMintues, processor.CalculateExpiryTimeInMintues());
        }
    }
}
