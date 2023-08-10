using ascribe.pharmacy.shared;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace UT_Pharmacy_Shared
{
    using System.Collections.Generic;

    /// <summary>
    ///This is a test class for BarcodeTest and is intended
    ///to contain all BarcodeTest Unit Tests
    ///</summary>
    [TestClass()]
    public class BarcodeTest
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

        // 3 x EAN/GTIN-8, 3 x EAN/GTIN-12, 5 x EAN/GTIN-13 and 5 x GTIN-14
        private readonly String[] _barcodes =
            {
                "7279771", "1234567", "0657172",
                "65656622277", "72896800177", "01234567891",
                "123456789011", "555999888333", "658367314670", "727977111670", "838479783830",
                "6565662599001", "1234567890111", "0123456789012", "1019997773331", "1773800017709"
            };
        // Check digits generated using the above data at https://www.gs1.org/services/check-digit-calculator
        private readonly String[] _checkdigits = 
            {
                "6", "0", "6",
                "8", "7", "2",
                "1", "1", "0", "5", "8",
                "0" ,"8", "8", "2", "4"
            };

        private readonly String[] _invalidBarcodes =
            {
                "", "1", "12", "123", "1234", "12345", "123456", "1234567", "123456789", "1234567890", "12345678901",
                "123A5678", "1234567A9012" ,"1A34567890123", "123456789012A4", "1234567890123A"
            };

        [TestMethod()]
        [Description("Test check digit calculator")]
        public void TestCheckDigitCalculation()
        {
            for (int i = 0; i < _barcodes.Length; i++)
            {
                String checkDigit = Barcode.CalculateGTINCheckDigit(_barcodes[i]);
                Assert.AreEqual(_checkdigits[i], checkDigit, "Failed to correctly generate check digit for " + _barcodes[i].Length + ". Generated " + checkDigit + " should have been " + _checkdigits[i]);
            }
        }

        [TestMethod()]
        [Description("EAN/GTIN Barcode validation with validation of check digit")]
        public void ValidateBarcodeTestWithCheckDigitValidation()
        {
            ValidateBarcodeTest(true);
        }

        [TestMethod()]
        [Description("EAN/GTIN Barcode validation without validation of check digit")]
        public void ValidateBarcodeTestWithoutCheckDigitValidation()
        {
            ValidateBarcodeTest(false);
        }

        private void ValidateBarcodeTest(bool validateCheckDigit)
        {
            // Validate a list of known valid barcodes
            for (int i = 0; i < _barcodes.Length; i++)
            {
                String errorMsg = string.Empty;
                String barcode = _barcodes[i] + _checkdigits[i];

                bool isValid = Barcode.ValidateGTINBarcode(barcode, validateCheckDigit, out errorMsg);
                Assert.AreEqual(
                    true,
                    isValid, 
                    String.Format(
                        "Failed to validate barcode with check{0} digit validation for {1}. Error is '{2}'", 
                            validateCheckDigit ? "" : "out", 
                            barcode, 
                            errorMsg));

                // Mangle the check digit by adding 1 to make the check digit invalid
                barcode = _barcodes[i] + ((int.Parse(_checkdigits[i]) + 1) % 10).ToString();
                isValid = Barcode.ValidateGTINBarcode(barcode, validateCheckDigit, out errorMsg);
                Assert.AreEqual(
                    !validateCheckDigit,
                    isValid,
                    String.Format(
                        "Failed to validate barcode with check{0} digit validation for {1}. Error is '{2}'",
                            validateCheckDigit ? "" : "out",
                            barcode,
                            errorMsg));
            }

            // Validate a list of known invalid barcodes
            for (int i = 0; i < _invalidBarcodes.Length; i++)
            {
                String errorMsg = string.Empty;
                String barcode = _invalidBarcodes[i];

                bool isValid = Barcode.ValidateGTINBarcode(barcode, true, out errorMsg);

                Assert.AreEqual(
                    String.IsNullOrEmpty(barcode),
                    isValid,
                    String.Format(
                        "Failed to validate barcode (with check digit validation) for {0}. Error is '{1}'",
                            barcode,
                            errorMsg));
            }
        }

        /// <summary>A test for Read2DBarcode</summary>
        [TestMethod()]
        [Description("A test for ReadBarcode")]
        public void ReadBarcodeTest()
        {
            this.DoesItDecodeWholeMessageCorrectly("012890107902171110N2012004]1d1715043021J2DVGNBFG557", true, "28901079021711", new DateTime(2015, 4,  30), "N2012004");
            this.DoesItDecodeWholeMessageCorrectly("01034531200000111719112510ABCD1234",               true, "3453120000011", new DateTime(2019, 11, 25), "ABCD1234");

            this.DoesItDecodeWholeMessageCorrectly("012890107903191810DNS012003]1d1715033121S7D2NLYGWUEG", true, "28901079031918", new DateTime(2015, 3, 31), "DNS012003");
            this.DoesItDecodeWholeMessageCorrectly("012890107901755410E6222113]1d111207011717063021WH45NNXUPQRU", true, "28901079017554", new DateTime(2017, 6, 30), "E6222113");
            this.DoesItDecodeWholeMessageCorrectly("012890107903190110DNR012002]1d17150331217N7PMD82HJ2A", true, "28901079031901", new DateTime(2015, 3, 31), "DNR012002");
            this.DoesItDecodeWholeMessageCorrectly("012890107901750910E6162166]1d111209011717083121JH5R6PXU4UY3", true, "28901079017509", new DateTime(2017, 08, 31), "E6162166");
            this.DoesItDecodeWholeMessageCorrectly("012890107900891010CBU012021]1d1715043021RVPQY6QDA9WV", true, "28901079008910", new DateTime(2015, 4, 30), "CBU012021");
            this.DoesItDecodeWholeMessageCorrectly("010950400005911817141120107654321D2]1d110987654d3218200http://www.gs1.org/demo/", false, "9504000059118", new DateTime(2014,11,20), "7654321D2");
            this.DoesItDecodeWholeMessageCorrectly("5000483111175", true, "5000483111175", null, null);
            this.DoesItDecodeWholeMessageCorrectly("012890107900788310BYB012048]1d1715073121DELW8AGZSUUU", true, "28901079007883", new DateTime(2015, 07, 31), "BYB012048"); 
            this.DoesItDecodeWholeMessageCorrectly("012890107900275810AUC112003]1d1715063021PV56GX3DK5KF", true, "28901079002758", new DateTime(2015, 06, 30), "AUC112003");
            this.DoesItDecodeWholeMessageCorrectly("012890107900472110BDS022028]1d17150731219PU9LG9ZYA66", true, "28901079004721", new DateTime(2015, 07, 31), "BDS022028");
            this.DoesItDecodeWholeMessageCorrectly("5014602300982", true, "5014602300982", null, null);
        }

        /// <summary>Test if it decocdes the whole message correctly</summary>
        /// <param name="template">Sequence template</param>
        /// <param name="message">Sequence message</param>
        /// <param name="result">Expected result</param>
        /// <param name="mappings">Expected mapping</param>
        public void DoesItDecodeWholeMessageCorrectly(string message, bool expectedResult, string expectedGtin, DateTime? expectedExpiryDate, string expectedBatchNumber)
        {
            Dictionary<string,string> mappedData = new Dictionary<string,string>();
            string actualGtin, actualBatchNumber;
            DateTime? actualExpiryDate;
            string error;

            var actualResult = Barcode.ReadBarcode(message, out actualGtin, out actualExpiryDate, out actualBatchNumber, out error);

            Assert.AreEqual(expectedResult,     actualResult,        "Failed to correctly validate sequence: " + error);
            Assert.AreEqual(expectedGtin,       actualGtin,          "Failed to correctly decode GTIN");
            Assert.AreEqual(actualExpiryDate,   expectedExpiryDate,  "Failed to correctly decode ExpiryDate");
            Assert.AreEqual(actualBatchNumber,  expectedBatchNumber, "Failed to correctly decode BatchNumber");
        }
    }
}
