using ascribe.pharmacy.parenteralnutritionlayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
namespace UT_Parenteral_Nutrition_Layer
{
    
    
    /// <summary>
    ///This is a test class for PNDoubleExtensionTest and is intended
    ///to contain all PNDoubleExtensionTest Unit Tests
    ///</summary>
    [TestClass()]
    public class PNDoubleExtensionTest
    {


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


        /// <summary>
        ///A test for To3SigFigish
        ///</summary>
        [TestMethod()]
        public void To3SigFigishTest()
        {
            Assert.AreEqual(0.0,   0.0.To3SigFigish());
            Assert.AreEqual(0.0,   0.0001.To3SigFigish());
            Assert.AreEqual(0.0,   0.0004.To3SigFigish());
            Assert.AreEqual(0.0,   0.00044444444.To3SigFigish());

            Assert.AreEqual(0.0, 0.0004445.To3SigFigish());
            Assert.AreEqual(0.0, 0.000445.To3SigFigish());
            Assert.AreEqual(0.0, 0.00045.To3SigFigish());
            Assert.AreEqual(0.0, 0.0005.To3SigFigish());
            Assert.AreEqual(0.0, 0.00050001.To3SigFigish());
            Assert.AreEqual(0.0, 0.00055.To3SigFigish());
            Assert.AreEqual(0.0, 0.00144.To3SigFigish());
            Assert.AreEqual(0.0, 0.00145.To3SigFigish());
            Assert.AreEqual(0.0, 0.0015.To3SigFigish());
            Assert.AreEqual(0.0, 0.00155.To3SigFigish());

            Assert.AreEqual(0.0,    0.004445.To3SigFigish());
            Assert.AreEqual(0.0,    0.00445.To3SigFigish());
            Assert.AreEqual(0.0,    0.0045.To3SigFigish());
            Assert.AreEqual(0.01,   0.005.To3SigFigish());
            Assert.AreEqual(0.01,   0.0050001.To3SigFigish());
            Assert.AreEqual(0.01,   0.0055.To3SigFigish());
            Assert.AreEqual(0.01,   0.0144.To3SigFigish());
            Assert.AreEqual(0.01,   0.0145.To3SigFigish());
            Assert.AreEqual(0.02,   0.015.To3SigFigish());
            Assert.AreEqual(0.02,   0.0155.To3SigFigish());

            Assert.AreEqual(0.04,   0.04445.To3SigFigish());
            Assert.AreEqual(0.04,   0.0445.To3SigFigish());
            Assert.AreEqual(0.05,   0.045.To3SigFigish());
            Assert.AreEqual(0.05,   0.05.To3SigFigish());
            Assert.AreEqual(0.05,   0.050001.To3SigFigish());
            Assert.AreEqual(0.06,   0.055.To3SigFigish());
            Assert.AreEqual(0.14,   0.144.To3SigFigish());
            Assert.AreEqual(0.15,   0.145.To3SigFigish());
            Assert.AreEqual(0.15,   0.15.To3SigFigish());
            Assert.AreEqual(0.16,   0.155.To3SigFigish());

            Assert.AreEqual(0.44,   0.4444.To3SigFigish());
            Assert.AreEqual(0.44,   0.4445.To3SigFigish());
            Assert.AreEqual(0.45,   0.445.To3SigFigish());
            Assert.AreEqual(0.45,   0.45.To3SigFigish());
            Assert.AreEqual(0.5,    0.5.To3SigFigish());
            Assert.AreEqual(0.5,    0.50001.To3SigFigish());
            Assert.AreEqual(0.55,   0.55.To3SigFigish());
            Assert.AreEqual(1.44,   1.4444.To3SigFigish());
            Assert.AreEqual(1.44,   1.4445.To3SigFigish());
            Assert.AreEqual(1.5,    1.5.To3SigFigish());
            Assert.AreEqual(1.55,   1.545.To3SigFigish());

            Assert.AreEqual(4.44,   4.4444.To3SigFigish());
            Assert.AreEqual(4.44,   4.4445.To3SigFigish());
            Assert.AreEqual(4.45,   4.445.To3SigFigish());
            Assert.AreEqual(4.45,   4.45.To3SigFigish());
            Assert.AreEqual(5,      5.0.To3SigFigish());
            Assert.AreEqual(5,      5.0001.To3SigFigish());
            Assert.AreEqual(5.55,   5.55.To3SigFigish());
            Assert.AreEqual(5.55,   5.5545.To3SigFigish());
            Assert.AreEqual(5.56,   5.555.To3SigFigish());
            Assert.AreEqual(14.4,  14.4444.To3SigFigish());
            Assert.AreEqual(14.4,  14.4445.To3SigFigish());
            Assert.AreEqual(15.0,   15.0.To3SigFigish());
            Assert.AreEqual(1.54,   1.5445.To3SigFigish());
        }

        /// <summary>
        ///A test for To2SigFigString
        ///</summary>
        [TestMethod()]
        public void To2SigFigStringTest()
        {
            Assert.AreEqual(" 0.0", 0.0001.To2SigFigString());
            Assert.AreEqual(" 0.0", 0.025.To2SigFigString());
            Assert.AreEqual(" 0.1", 0.111.To2SigFigString());
            Assert.AreEqual(" 1.1", 1.111.To2SigFigString());
            Assert.AreEqual("11.1",11.111.To2SigFigString());
            Assert.AreEqual(" 111", 111.11.To2SigFigString());
            Assert.AreEqual("13.8", (330.0 / 24.0).To2SigFigString());
            Assert.AreEqual("111111", 111111.11.To2SigFigString());
            Assert.AreEqual(" 1.9", (45.0  / 24.0).To2SigFigString());
            Assert.AreEqual("   0", 0.0.To2SigFigString());
        }


        /// <summary>
        ///A test for To2SigFigString
        ///</summary>
        [TestMethod()]
        public void To3SigFigish2()
        {
            Assert.AreEqual(" 0.0", 0.0001.To3SigFigString());
            Assert.AreEqual("0.03", 0.025.To3SigFigString());
            Assert.AreEqual("0.11", 0.111.To3SigFigString());
            Assert.AreEqual("1.11", 1.111.To3SigFigString());
            Assert.AreEqual("11.1",11.111.To3SigFigString());
            Assert.AreEqual(" 111", 111.11.To3SigFigString());
            Assert.AreEqual("13.8", (330.0 / 24.0).To3SigFigString());
            Assert.AreEqual("111111", 111111.11.To3SigFigString());
            Assert.AreEqual("1.88", (45.0  / 24.0).To3SigFigString());
            Assert.AreEqual("   0", 0.0.To2SigFigString());
        }
    }
}
