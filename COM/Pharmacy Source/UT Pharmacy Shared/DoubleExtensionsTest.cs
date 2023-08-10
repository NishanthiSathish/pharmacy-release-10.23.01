using ascribe.pharmacy.shared;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace UT_Pharmacy_Shared
{
    
    
    /// <summary>
    ///This is a test class for DoubleExtensionsTest and is intended
    ///to contain all DoubleExtensionsTest Unit Tests
    ///</summary>
    [TestClass()]
    public class DoubleExtensionsTest
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


        [TestMethod()]
        [Description("A test for To7Sf7Dp")]
        public void TestTo7Sf7Dp()
        {
            Assert.AreEqual(0.0,         0.0.To7Sf7Dp());
            Assert.AreEqual(1.23457,     1.234567.To7Sf7Dp());
            Assert.AreEqual(-1.23457,   -1.234567.To7Sf7Dp());
            Assert.AreEqual(1.23456,     1.23456.To7Sf7Dp());
            Assert.AreEqual(0,           (1.23E-07).To7Sf7Dp());

            Assert.AreEqual(0.123457,    0.123456789.To7Sf7Dp());
            Assert.AreEqual(0.0123457,   0.0123456789.To7Sf7Dp());
            Assert.AreEqual(0.0012346,   0.00123456789.To7Sf7Dp());
            Assert.AreEqual(0.0001235,   0.000123456789.To7Sf7Dp());
            Assert.AreEqual(-0.0001235,   -0.000123456789.To7Sf7Dp());
            Assert.AreEqual(0.0000123,   0.0000123456789.To7Sf7Dp());

            Assert.AreEqual(123456800,  123456789.123456789.To7Sf7Dp());
            Assert.AreEqual(-123456800,  -123456789.123456789.To7Sf7Dp());
            Assert.AreEqual(12345680,   12345678.123456789.To7Sf7Dp());
            Assert.AreEqual(1234567,    1234567.123456789.To7Sf7Dp());
            Assert.AreEqual(123456,     123456.123456789.To7Sf7Dp());
            Assert.AreEqual(12345.1,    12345.123456789.To7Sf7Dp());
            Assert.AreEqual(1234.12,    1234.123456789.To7Sf7Dp());

            Assert.AreEqual(0.0000012, 0.00000123.To7Sf7Dp());
            Assert.AreEqual(0.0001230, 0.000123.To7Sf7Dp());
            Assert.AreEqual(1234567,   1234567.1234567.To7Sf7Dp());
            Assert.AreEqual(123456, 123456.1234567.To7Sf7Dp());
            Assert.AreEqual(-12345.1, -12345.1234567.To7Sf7Dp());
            Assert.AreEqual(1234.12, 1234.1234567.To7Sf7Dp());
            Assert.AreEqual(123.124, 123.1234567.To7Sf7Dp());
            Assert.AreEqual(12.1235, 12.123456789.To7Sf7Dp());
            Assert.AreEqual(1.12346, 1.123456789.To7Sf7Dp());
            Assert.AreEqual(0.123457, 0.1234567.To7Sf7Dp());
            Assert.AreEqual(0.123456, 0.123456.To7Sf7Dp());
            Assert.AreEqual(0.12345, 0.12345.To7Sf7Dp());
            Assert.AreEqual(0.1234, 0.1234.To7Sf7Dp());
            Assert.AreEqual(0.123, 0.123.To7Sf7Dp());
            Assert.AreEqual(0.12, 0.12.To7Sf7Dp());
            Assert.AreEqual(0.1, 0.1.To7Sf7Dp());

            Assert.AreEqual(0.0, 0.00000001.To7Sf7Dp());
            Assert.AreEqual(0.0, 0.0000001.To7Sf7Dp());
            Assert.AreEqual(0.000001, 0.000001.To7Sf7Dp());
            Assert.AreEqual(0.00001, 0.00001.To7Sf7Dp());
            Assert.AreEqual(0.0001, 0.0001.To7Sf7Dp());
            Assert.AreEqual(0.001, 0.001.To7Sf7Dp());
            Assert.AreEqual(0.01, 0.01.To7Sf7Dp());
            Assert.AreEqual(0.1, 0.1.To7Sf7Dp());
            Assert.AreEqual(1, 1.0.To7Sf7Dp());
            Assert.AreEqual(10, 10.0.To7Sf7Dp());
            Assert.AreEqual(100, 100.0.To7Sf7Dp());
            Assert.AreEqual(1000, 1000.0.To7Sf7Dp());
            Assert.AreEqual(10000, 10000.0.To7Sf7Dp());
            Assert.AreEqual(100000, 100000.0.To7Sf7Dp());
            Assert.AreEqual(1000000, 1000000.0.To7Sf7Dp());
            Assert.AreEqual(10000000, 10000000.0.To7Sf7Dp());
            Assert.AreEqual(100000000, 100000000.0.To7Sf7Dp());

            Assert.AreEqual(-0.0, -0.00000001.To7Sf7Dp());
            Assert.AreEqual(-0.0, -0.0000001.To7Sf7Dp());
            Assert.AreEqual(-0.000001, -0.000001.To7Sf7Dp());
            Assert.AreEqual(-0.00001, -0.00001.To7Sf7Dp());
            Assert.AreEqual(-0.0001, -0.0001.To7Sf7Dp());
            Assert.AreEqual(-0.001, -0.001.To7Sf7Dp());
            Assert.AreEqual(-0.01, -0.01.To7Sf7Dp());
            Assert.AreEqual(-0.1, -0.1.To7Sf7Dp());
            Assert.AreEqual(-1, -1.0.To7Sf7Dp());
            Assert.AreEqual(-10, -10.0.To7Sf7Dp());
            Assert.AreEqual(-100, -100.0.To7Sf7Dp());
            Assert.AreEqual(-1000, -1000.0.To7Sf7Dp());
            Assert.AreEqual(-10000, -10000.0.To7Sf7Dp());
            Assert.AreEqual(-100000, -100000.0.To7Sf7Dp());
            Assert.AreEqual(-1000000, -1000000.0.To7Sf7Dp());
            Assert.AreEqual(-10000000, -10000000.0.To7Sf7Dp());
            Assert.AreEqual(-100000000, -100000000.0.To7Sf7Dp());
        }
    }
}
