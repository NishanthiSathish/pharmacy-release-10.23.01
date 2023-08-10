using ascribe.pharmacy.shared;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace UT_Pharmacy_Shared
{
    
    
    /// <summary>
    ///This is a test class for ConvertExtensionsTest and is intended
    ///to contain all ConvertExtensionsTest Unit Tests
    ///</summary>
    [TestClass()]
    public class ConvertExtensionsTest
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

        /// <summary>A test for FromMintues</summary>
        [TestMethod()]
        public void FromMintuesTest()
        {
            Assert.AreEqual("4M", ConvertExtensions.FromMintues(4));
            Assert.AreEqual("1H", ConvertExtensions.FromMintues(60));
            Assert.AreEqual("1D", ConvertExtensions.FromMintues(1440));
            Assert.AreEqual("1W", ConvertExtensions.FromMintues(10080));
            Assert.AreEqual("1Y", ConvertExtensions.FromMintues(525960));
            Assert.AreEqual("1H 1D", ConvertExtensions.FromMintues(1500));
            Assert.AreEqual("1M 1H 1D", ConvertExtensions.FromMintues(1501));
            Assert.AreEqual("1M 1Y", ConvertExtensions.FromMintues(525961));
        }
    }
}
