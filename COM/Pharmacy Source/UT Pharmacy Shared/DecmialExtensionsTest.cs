using System;
using System.Configuration;
using System.Linq;
using ascribe.pharmacy.shared;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UT_Pharmacy_Shared
{
    /// <summary>
    /// Summary description for DecmialExtensionsTest
    /// </summary>
    [TestClass]
    public class DecmialExtensionsTest
    {
        private static int SessionID;
        private const  int SiteID    = 22;

        private static TestDBDataContext linqdb;
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
 
        //Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext) 
        { 
            Configuration conf = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            ConnectionStringsSection connectionStrSect = conf.ConnectionStrings;

            string connectionStr = connectionStrSect.ConnectionStrings["TRNRTL10.My.MySettings.ConnectionString"].ConnectionString;
            linqdb = new TestDBDataContext(connectionStr);

            // Get a sesssion ID (any will do)
            SessionID = linqdb.ExecuteQuery<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC").First();
        }

        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        
        // Use TestInitialize to run code before running each test 
        [TestInitialize()]
        public void MyTestInitialize() 
        { 
            // Determine directory the test are being run in.
            string assemblyFile = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string assemblyDir = System.IO.Path.GetDirectoryName(assemblyFile);

            // Setup a mock HttpContext
            SimulatedHttpRequest.SetHttpContextWithSimulatedRequest("http://localhost/TestApp", "test app", assemblyDir);

            // Initaluise the session info
            SessionInfo.InitialiseSessionAndSiteID( SessionID, SiteID );

            // Set currency symbol to '£' (if present)
            // if not present then leave as default to '£'
            wConfiguration currentcySymbol = (from p in linqdb.wConfigurations
                                             where (p.SiteID   == SiteID)           &&
                                                   (p.Category == "A|COUNTRY.044")  &&
                                                   (p.Section  == "")               &&
                                                   (p.Key      == "SymbolUnit")     
                                             select p).FirstOrDefault();
            if (currentcySymbol != null)
                currentcySymbol.Value = "£";
            linqdb.SubmitChanges();
        }
        
        // Use TestCleanup to run code after each test has run
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        //
        #endregion

        [TestMethod()]
        [Description("Test decimal fixed length string conversion.")]
        public void TestDecimalFixedLengthStringConvert()
        {
            Assert.AreEqual("456.3",          (456.3m).ToString(6),             "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("456.3",          (456.3m).ToString(8),             "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("456.34",         (456.3443m).ToString(6),          "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("456.35",         (456.3450m).ToString(6),          "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("456.35",         (456.3453m).ToString(6),          "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("456.35",         (456.3463m).ToString(6),          "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("-456.3",         (-456.3443m).ToString(6),         "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("-456.4",         (-456.3543m).ToString(6),         "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("-456.4",         (-456.3643m).ToString(6),         "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("-456.5",         (-456.5000m).ToString(6),         "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("5E+006",         (4563443m).ToString(6),           "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("",               ((decimal?)null).ToString(6),     "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("3.04",           (3.0448m).ToString(4),            "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("3.05",           (3.0450m).ToString(4),            "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("3.05",           (3.0452m).ToString(4),            "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("-3.04",          (-3.0448m).ToString(5),           "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("-3.05",          (-3.0450m).ToString(5),           "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("-3.04",          (-3.0350m).ToString(5),           "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("-3.05",          (-3.0452m).ToString(5),           "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("500",            (500m).ToString(5),               "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("5000",           (5000m).ToString(5),              "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("50000",          (50000m).ToString(50),            "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("500000000000000",(500000000000000m).ToString(50),  "Failed to convert to decimal to fixed length string");
            Assert.AreEqual("1000",           (1000m).ToString(4),              "Failed to convert to decimal to fixed length string"); // Add for issue with product editor
            Assert.AreEqual("10000",          (10000m).ToString(5),             "Failed to convert to decimal to fixed length string"); // Add for issue with product editor
        }

        [TestMethod()]
        [Description("Test decimal fixed length string conversion asserts for impossible conversion.")]
        [ExpectedException(typeof(ApplicationException))]
        public void TestDecimalFixedLengthStringConvertAsserts()
        {
            (4563443m).ToString(4);
        }

        [TestMethod]
        [Description("Test Decimal.ToMoneyString correctly converts values to money stings")]
        public void DoesToMoneyStringConvertCorrectly()
        {
            Assert.AreEqual("£ 100000.00",  (10000000.0m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 10.25",      (1024.856m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 10.24",      (1024.495m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 10.00",      (1000.495m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 10.00",      (1000m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 0.03",       (2.6m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 0.03",       (2.5m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 0.02",       (2.49m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 0.02",       (2.4m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 0.02",       (2m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 0.01",       (0.5m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 0.00",       (0.49m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 0.00",       (0m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 0.00",       (-0.49m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -0.01",      (-0.5m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -0.02",      (-2m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -0.02",      (-2.4m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -0.02",      (-2.49m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -0.03",      (-2.5m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -0.03",      (-2.6m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -10.00",     (-1000.495m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -10.00",     (-1000m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -10.24",     (-1024.495m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -10.25",     (-1024.5m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -10.25",     (-1024.856m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -100000.00", (-10000000.0m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 477.50",     (47749.5m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 477.50",     (47750.0m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ 477.51",     (47750.5m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -477.50",    (-47749.5m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -477.50",    (-47750.0m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("£ -477.51",    (-47750.5m).ToMoneyString(MoneyDisplayType.Show));
        }

        [TestMethod]
        [Description("Test Decimal.ToMoneyString works correctly for null decimals")]
        public void DoesToMoneyStringConvertCopeWithNullValues()
        {
            decimal? value = null;
            Assert.AreEqual("", value.ToMoneyString(MoneyDisplayType.Show));
        }

        [TestMethod]
        [Description("Test Decimal.ToMoneyString hides money value with ' ****' when MoneyDisplayType.HideWithLeadingSpace is specified")]
        public void DoesToMoneyStringHideMoneyValueWithLeadingSpaceWhenRequested()
        {
            Assert.AreEqual("£ ****", (10000000.0m).ToMoneyString   (MoneyDisplayType.HideWithLeadingSpace));
            Assert.AreEqual("£ ****", (1024.495m).ToMoneyString     (MoneyDisplayType.HideWithLeadingSpace));
            Assert.AreEqual("£ ****", (2.49m).ToMoneyString         (MoneyDisplayType.HideWithLeadingSpace));
            Assert.AreEqual("£ ****", (0m).ToMoneyString            (MoneyDisplayType.HideWithLeadingSpace));
            Assert.AreEqual("£ ****", (-2.49m).ToMoneyString        (MoneyDisplayType.HideWithLeadingSpace));
            Assert.AreEqual("£ ****", (-1024.495m).ToMoneyString    (MoneyDisplayType.HideWithLeadingSpace));
            Assert.AreEqual("£ ****", (-10000000.0m).ToMoneyString  (MoneyDisplayType.HideWithLeadingSpace));
        }

        [TestMethod]
        [Description("Test Decimal.ToMoneyString displays ' ****' when MoneyDisplayType.HideWithLeadingSpace is specified, and value is null")]
        public void DoesToMoneyStringHideMoneyValueWithLeadingSpaceWithNullValue()
        {
            decimal? value = null;
            Assert.AreEqual("£ ****", value.ToMoneyString(MoneyDisplayType.HideWithLeadingSpace));
        }

        [TestMethod]
        [Description("Test Decimal.ToMoneyString hides money value with '*****' when MoneyDisplayType.Hide is specified")]
        public void DoesToMoneyStringHideMoneyValueWhenRequested()
        {
            Assert.AreEqual("£*****", (10000000.0m).ToMoneyString   (MoneyDisplayType.Hide));
            Assert.AreEqual("£*****", (1024.495m).ToMoneyString     (MoneyDisplayType.Hide));
            Assert.AreEqual("£*****", (2.49m).ToMoneyString         (MoneyDisplayType.Hide));
            Assert.AreEqual("£*****", (0m).ToMoneyString            (MoneyDisplayType.Hide));
            Assert.AreEqual("£*****", (-2.49m).ToMoneyString        (MoneyDisplayType.Hide));
            Assert.AreEqual("£*****", (-1024.495m).ToMoneyString    (MoneyDisplayType.Hide));
            Assert.AreEqual("£*****", (-10000000.0m).ToMoneyString  (MoneyDisplayType.Hide));
        }

        [TestMethod]
        [Description("Test Decimal.ToMoneyString displays '*****' when MoneyDisplayType.Hide is specified, and value is null")]
        public void DoesToMoneyStringHideMoneyValueWhenRequestedWithNullValue()
        {
            decimal? value = null;
            Assert.AreEqual("£*****", value.ToMoneyString(MoneyDisplayType.Hide));
        }

        [TestMethod]
        [Description("Test Decimal.ToMoneyString displays currency symbol read form PharmacyCultureInfo.")]
        public void DoesToMoneyStringDisplayCorrectCurrencySymbol()
        {
            // Set up slightly different currecny symbol
            wConfiguration configurationRow = (from p in linqdb.wConfigurations
                                              where (p.SiteID   == SiteID)           &&
                                                    (p.Category == "A|COUNTRY.044")  &&
                                                    (p.Section  == "")               &&
                                                    (p.Key      == "SymbolUnit")     
                                              select p).FirstOrDefault();
            if (configurationRow == null)
            {
                configurationRow         = new wConfiguration();
                configurationRow.SiteID  = SiteID; 
                configurationRow.Category= "A|COUNTRY.044";
                configurationRow.Section = "";
                configurationRow.Key     = "SymbolUnit";

                linqdb.wConfigurations.InsertOnSubmit(configurationRow);
            }
            configurationRow.Value = "$";
            linqdb.SubmitChanges();

            Assert.AreEqual("$ 2.00", (200m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("$ 0.00", (0m).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("$*****", (200m).ToMoneyString(MoneyDisplayType.Hide));
            Assert.AreEqual("$ ****", (200m).ToMoneyString(MoneyDisplayType.HideWithLeadingSpace));
            Assert.AreEqual("",       ((decimal?)null).ToMoneyString(MoneyDisplayType.Show));
            Assert.AreEqual("$*****", ((decimal?)null).ToMoneyString(MoneyDisplayType.Hide));
            Assert.AreEqual("$ ****", ((decimal?)null).ToMoneyString(MoneyDisplayType.HideWithLeadingSpace));
        }

        [TestMethod]
        [Description("Test Decimal.ToWholePackString correctly convert value to strings.")]
        public void DoesToWholePackStrinDisplayCorrectConvert()
        {
            Assert.AreEqual("1 x 3",        (1m).ToWholePackString          (3,     true));
            Assert.AreEqual("100 x 1",      (100m).ToWholePackString        (1,     true));
            Assert.AreEqual("1",            (0.33333333m).ToWholePackString (3,     true));
            Assert.AreEqual("60",           (3.3332999m).ToWholePackString  (18,    true));
            Assert.AreEqual("1000 x 1000",  (1000m).ToWholePackString       (1000,  true));
            Assert.AreEqual("80",           (0.32m).ToWholePackString       (250,   true));
            Assert.AreEqual("20",           (0.4m).ToWholePackString        (50,    true));
            Assert.AreEqual("5",            (0.5m).ToWholePackString        (10,    true));
            Assert.AreEqual("9212",         (95.958333m).ToWholePackString  (96,    true));
            Assert.AreEqual("20",           (0.2439024m).ToWholePackString  (82,    true));
            Assert.AreEqual("0.25",         (0.25m).ToWholePackString       (1,     true));
            Assert.AreEqual("3.25",         (3.25m).ToWholePackString       (1,     true));
            Assert.AreEqual("6.5",          (3.25m).ToWholePackString       (2,     true));
            Assert.AreEqual("20",           (0.402m).ToWholePackString      (50,    true));
            Assert.AreEqual("3",            (1m).ToWholePackString          (3,     false));
            Assert.AreEqual("100",          (100m).ToWholePackString        (1,     false));
            Assert.AreEqual("1",            (0.33333333m).ToWholePackString (3,     false));
            Assert.AreEqual("60",           (3.3332999m).ToWholePackString  (18,    false));
        }

        [TestMethod]
        [Description("Test Decimal.ToWholePackString converts nulls to empty string.")]
        public void DoesToWholePackStringHandleNulls()
        {
            Assert.AreEqual("", ((decimal?)null).ToWholePackString(3, true));
        }

        [TestMethod()]
        [Description("A test for To7Sf7Dp")]
        public void TestTo7Sf7Dp()
        {
            Assert.AreEqual(0.0M,         0.0M.To7Sf7Dp());
            Assert.AreEqual(1.23457M,     1.234567M.To7Sf7Dp());
            Assert.AreEqual(-1.23457M,   -1.234567M.To7Sf7Dp());
            Assert.AreEqual(1.23456M,     1.23456M.To7Sf7Dp());
            Assert.AreEqual(0M,           1.23E-07M.To7Sf7Dp());

            Assert.AreEqual(0.123457M,    0.123456789M.To7Sf7Dp());
            Assert.AreEqual(0.0123457M,   0.0123456789M.To7Sf7Dp());
            Assert.AreEqual(0.0012346M,   0.00123456789M.To7Sf7Dp());
            Assert.AreEqual(0.0001235M,   0.000123456789M.To7Sf7Dp());
            Assert.AreEqual(-0.0001235M,   -0.000123456789M.To7Sf7Dp());
            Assert.AreEqual(0.0000123M,   0.0000123456789M.To7Sf7Dp());

            Assert.AreEqual(123456800M,  123456789.123456789M.To7Sf7Dp());
            Assert.AreEqual(-123456800M,  -123456789.123456789M.To7Sf7Dp());
            Assert.AreEqual(12345680M,   12345678.123456789M.To7Sf7Dp());
            Assert.AreEqual(1234567M,    1234567.123456789M.To7Sf7Dp());
            Assert.AreEqual(123456M,     123456.123456789M.To7Sf7Dp());
            Assert.AreEqual(12345.1M,    12345.123456789M.To7Sf7Dp());
            Assert.AreEqual(1234.12M,    1234.123456789M.To7Sf7Dp());

            Assert.AreEqual(0.0000012M, 0.00000123M.To7Sf7Dp());
            Assert.AreEqual(0.0001230M, 0.000123M.To7Sf7Dp());
            Assert.AreEqual(1234567M,   1234567.1234567M.To7Sf7Dp());
            Assert.AreEqual(123456M, 123456.1234567M.To7Sf7Dp());
            Assert.AreEqual(-12345.1M, -12345.1234567M.To7Sf7Dp());
            Assert.AreEqual(1234.12M, 1234.1234567M.To7Sf7Dp());
            Assert.AreEqual(123.124M, 123.1234567M.To7Sf7Dp());
            Assert.AreEqual(12.1235M, 12.123456789M.To7Sf7Dp());
            Assert.AreEqual(1.12346M, 1.123456789M.To7Sf7Dp());
            Assert.AreEqual(0.123457M, 0.1234567M.To7Sf7Dp());
            Assert.AreEqual(0.123456M, 0.123456M.To7Sf7Dp());
            Assert.AreEqual(0.12345M, 0.12345M.To7Sf7Dp());
            Assert.AreEqual(0.1234M, 0.1234M.To7Sf7Dp());
            Assert.AreEqual(0.123M, 0.123M.To7Sf7Dp());
            Assert.AreEqual(0.12M, 0.12M.To7Sf7Dp());
            Assert.AreEqual(0.1M, 0.1M.To7Sf7Dp());

            Assert.AreEqual(0.0M, 0.00000001M.To7Sf7Dp());
            Assert.AreEqual(0.0M, 0.0000001M.To7Sf7Dp());
            Assert.AreEqual(0.000001M, 0.000001M.To7Sf7Dp());
            Assert.AreEqual(0.00001M, 0.00001M.To7Sf7Dp());
            Assert.AreEqual(0.0001M, 0.0001M.To7Sf7Dp());
            Assert.AreEqual(0.001M, 0.001M.To7Sf7Dp());
            Assert.AreEqual(0.01M, 0.01M.To7Sf7Dp());
            Assert.AreEqual(0.1M, 0.1M.To7Sf7Dp());
            Assert.AreEqual(1M, 1.0M.To7Sf7Dp());
            Assert.AreEqual(10M, 10.0M.To7Sf7Dp());
            Assert.AreEqual(100M, 100.0M.To7Sf7Dp());
            Assert.AreEqual(1000M, 1000.0M.To7Sf7Dp());
            Assert.AreEqual(10000M, 10000.0M.To7Sf7Dp());
            Assert.AreEqual(100000M, 100000.0M.To7Sf7Dp());
            Assert.AreEqual(1000000M, 1000000.0M.To7Sf7Dp());
            Assert.AreEqual(10000000M, 10000000.0M.To7Sf7Dp());
            Assert.AreEqual(100000000M, 100000000.0M.To7Sf7Dp());

            Assert.AreEqual(0.0M, -0.00000001M.To7Sf7Dp());
            Assert.AreEqual(0.0M, -0.0000001M.To7Sf7Dp());
            Assert.AreEqual(-0.000001M, -0.000001M.To7Sf7Dp());
            Assert.AreEqual(-0.00001M, -0.00001M.To7Sf7Dp());
            Assert.AreEqual(-0.0001M, -0.0001M.To7Sf7Dp());
            Assert.AreEqual(-0.001M, -0.001M.To7Sf7Dp());
            Assert.AreEqual(-0.01M, -0.01M.To7Sf7Dp());
            Assert.AreEqual(-0.1M, -0.1M.To7Sf7Dp());
            Assert.AreEqual(-1M, -1.0M.To7Sf7Dp());
            Assert.AreEqual(-10M, -10.0M.To7Sf7Dp());
            Assert.AreEqual(-100M, -100.0M.To7Sf7Dp());
            Assert.AreEqual(-1000M, -1000.0M.To7Sf7Dp());
            Assert.AreEqual(-10000M, -10000.0M.To7Sf7Dp());
            Assert.AreEqual(-100000M, -100000.0M.To7Sf7Dp());
            Assert.AreEqual(-1000000M, -1000000.0M.To7Sf7Dp());
            Assert.AreEqual(-10000000M, -10000000.0M.To7Sf7Dp());
            Assert.AreEqual(-100000000M, -100000000.0M.To7Sf7Dp());
        }
    }
}
