//===========================================================================
//
//							    HL7ReceiverTemplateTest.cs
//
//  Holds tests for the HL7ReceiverTemplate class.
//
//  Test should be run from within Visual Studio.  
//
//	Modification History:
//	21Dec09 XN Written
//===========================================================================
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;
using System.Linq;
using System;
using ascribe.pharmacy.robotloading;

namespace UT_RobotLoading_Layer
{
    /// <summary>
    ///This is a test class for HL7DecoderTest and is intended
    ///to contain all HL7DecoderTest Unit Tests
    ///</summary>
    [TestClass()]
    public class HL7ReceiverTemplateTest
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

        /// <summary>Test validating a sequence and extracting tag data</summary>
        [TestMethod()]
        [Description("Test validating a sequence and extracting tag data")]
        public void DoesItValidateASequenceAndExtractTagData()
        {
            DoesItValidateASequenceAndExtractTagData("[Barcode]",              "DKDSJKDS",            true, "Barcode", "DKDSJKDS"                    );
            DoesItValidateASequenceAndExtractTagData("[Barcode]",              "ICDSJKLDSJ",          true, "Barcode", "ICDSJKLDSJ"                  );
            DoesItValidateASequenceAndExtractTagData("[Barcode]",              "ICDSDS^dsdsds",       true, "Barcode", "ICDSDS^dsdsds"               );
            DoesItValidateASequenceAndExtractTagData("[Barcode]",              "ICDSDS^FDSD",         true, "Barcode", "ICDSDS^FDSD"                 );
            DoesItValidateASequenceAndExtractTagData("[Barcode]",              "ICDSDS^FDSDDSDS",     true, "Barcode", "ICDSDS^FDSDDSDS"             );
            DoesItValidateASequenceAndExtractTagData("[Barcode]",              "DSDS^FDSD",           true, "Barcode", "DSDS^FDSD"                   );
            DoesItValidateASequenceAndExtractTagData("[Barcode]",              "DSDS^FDSD",           true, "Barcode", "DSDS^FDSD"                   );

            DoesItValidateASequenceAndExtractTagData("IC[Barcode]",            "DKDSJKDS",            false                                          );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]",            "ICDSJKLDSJ",          true, "Barcode", "DSJKLDSJ"                    );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]",            "ICDSDS^dsdsds",       true, "Barcode", "DSDS^dsdsds"                 );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]",            "ICDSDS^FDSD",         true, "Barcode", "DSDS^FDSD"                   );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]",            "ICDSDS^FDSDDSDS",     true, "Barcode", "DSDS^FDSDDSDS"               );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]",            "DSDS^FDSD",           false                                          );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]",            "DSDS^FDSD",           false                                          );

            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]",      "DKDSJKDS",           false                                          );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]",      "ICDSJKLDSJ",         false                                          );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]",      "ICDSDS^dsdsds",      true, "Barcode", "DSDS", "Test", "dsdsds"      );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]",      "ICDSDS^FDSD",        true, "Barcode", "DSDS", "Test", "FDSD"        );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]",      "ICDSDS^FDSDDSDS",    true, "Barcode", "DSDS", "Test", "FDSDDSDS"    );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]",      "DSDS^FDSD",          false                                          );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]",      "DSDS^FDSD",          false                                          );

            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]DSDS",  "DKDSJKDS",           false                                          );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]DSDS",  "ICDSJKLDSJ",         false                                          );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]DSDS",  "ICDSDS^dsdsds",      false                                          );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]DSDS",  "ICDSDS^FDSD",        false                                          );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]DSDS",  "ICDSDS^FDSDDSDS",    true, "Barcode", "DSDS", "Test", "FDSD"        );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]DSDS",  "DSDS^FDSD",          false                                          );
            DoesItValidateASequenceAndExtractTagData("IC[Barcode]^[Test]DSDS",  "DSDS^FDSD",          false                                          );

            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]DSDS",    "DKDSJKDS",           false                                          );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]DSDS",    "ICDSJKLDSJ",         false                                          );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]DSDS",    "ICDSDS^dsdsds",      false                                          );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]DSDS",    "ICDSDS^FDSD",        false                                          );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]DSDS",    "ICDSDS^FDSDDSDS",    true, "Barcode", "ICDSDS", "Test", "FDSD"      );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]DSDS",    "DSDS^FDSD",          false                                          );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]DSDS",    "DSDS^FDSD",          false                                          );
        
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]",        "DKDSJKDS",           false                                          );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]",        "ICDSJKLDSJ",         false                                          );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]",        "ICDSDS^dsdsds",      true, "Barcode", "ICDSDS", "Test", "dsdsds"    );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]",        "ICDSDS^FDSD",        true, "Barcode", "ICDSDS", "Test", "FDSD"      );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]",        "ICDSDS^FDSDDSDS",    true, "Barcode", "ICDSDS", "Test", "FDSDDSDS"  );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]",        "DSDS^FDSD",          true, "Barcode", "DSDS", "Test", "FDSD"        );
            DoesItValidateASequenceAndExtractTagData("[Barcode]^[Test]",        "DSDS^FDSD",          true, "Barcode", "DSDS", "Test", "FDSD"        );
        }

        /// <summary>Test validating a sequence and extracting tag data</summary>
        /// <param name="template">Sequence template</param>
        /// <param name="message">Sequence message</param>
        /// <param name="result">Expected result</param>
        /// <param name="mappings">Expected mapping</param>
        public void DoesItValidateASequenceAndExtractTagData(string template, string message, bool result, params string[] mappings)
        {
            HL7ReservedChars reserverChars = new HL7ReservedChars();
            HL7ReceiverTemplate decoder = new HL7ReceiverTemplate();
            Dictionary<string,string> mappedData = new Dictionary<string,string>();

            decoder.Initalise("Test", template, reserverChars);

            PrivateObject obj = new PrivateObject(decoder);
            bool valid = (bool)obj.Invoke("TryParseSequence", new object[] { 0, message, reserverChars, mappedData });

            Assert.AreEqual(result, valid, "Failed to correctly validate sequence");

            for(int c = 0; c < mappings.Length; c += 2)
            {
                string mappingName  = mappings[c];
                string expectedValue= mappings[c + 1];
                string actualValue;

                if (!mappedData.TryGetValue(mappingName, out actualValue))
                    Assert.Fail(string.Format("Failed to read mapping item '{0}'", mappingName));

                Assert.AreEqual(expectedValue, actualValue, string.Format("Failed to correct read mappnig data for item '{0}'", mappingName));
            }
        }

        /// <summary>Test errors if opening [ tag without closing ] tag<summary>
        [TestMethod()]
        [Description("Test errors if opening [ tag without closing ] tag")]
        [ExpectedException(typeof(ApplicationException))]
        public void DoesItErrorIfClosingTagWithoutOpeningTag()
        {
            HL7ReceiverTemplate decoder = new HL7ReceiverTemplate();
            decoder.Initalise("Test", "[Ba[rcode]", new HL7ReservedChars());
        }

        /// <summary>Test errors if closing ] tag without opening [ tag<summary>
        [TestMethod()]
        [Description("Test errors if opening [ tag without closing ] tag")]
        [ExpectedException(typeof(ApplicationException))]
        public void DoesItErrorIfOpeningTagWithoutClosingTag()
        {
            HL7ReceiverTemplate decoder = new HL7ReceiverTemplate();
            decoder.Initalise("Test", "[Barc]ode]", new HL7ReservedChars());
        }

        /// <summary>Test can't have two tags without fixed strings inbetweeen<summary>
        [TestMethod()]
        [Description("Test can't have two tags without fixed strings inbetweeen")]
        [ExpectedException(typeof(ApplicationException))]
        public void DoesItErrorTwoTagsWithoutFixedStringsInBetwwen()
        {
            HL7ReceiverTemplate decoder = new HL7ReceiverTemplate();
            decoder.Initalise("Test", "DSDS[Barcode][Test]DWWsd", new HL7ReservedChars());
        }

        /// <summary>Test if it decocdes the whole message correctly</summary>
        [TestMethod()]
        [Description("Test if it decocdes the whole message correctly")]
        public void DoesItDecodeWholeMessageCorrectly()
        {
            DoesItDecodeWholeMessageCorrectly("ZIN|B||||[OrderLoadingNumber]|",                 "ZIN|B|B|||32421|",             true, "OrderLoadingNumber", "32421");
            DoesItDecodeWholeMessageCorrectly("ZIN|B||||[OrderLoadingNumber]|",                 "ZIN|B|B|||32421||DSDS||",      true, "OrderLoadingNumber", "32421");
            DoesItDecodeWholeMessageCorrectly("ZIN|B||||[OrderLoadingNumber]|",                 "ZIN|B|B||||",                  true, "OrderLoadingNumber", "");
            DoesItDecodeWholeMessageCorrectly("ZIN|B||||[OrderLoadingNumber]|",                 "ZIN|A||||32421|",              false);
            DoesItDecodeWholeMessageCorrectly("ZIN|B||||[OrderLoadingNumber]|",                 "ZAN|B|B|||32421|",             false);
            DoesItDecodeWholeMessageCorrectly("ZIN|B|Some\\|Text|||[OrderLoadingNumber]|",      "ZIN|B|Some\\|Text|||32421|",   true, "OrderLoadingNumber", "32421");
            DoesItDecodeWholeMessageCorrectly("ZIN|B|SomeText\\\\|||[OrderLoadingNumber]|",     "ZIN|B|SomeText\\\\|||32421|",  true, "OrderLoadingNumber", "32421");
            DoesItDecodeWholeMessageCorrectly("ZIN|B|SomeText\\\\|||[OrderLoadingNumber]|",     "ZIN|B|SomeText\\\\|||32421|",  true, "OrderLoadingNumber", "32421");
            DoesItDecodeWholeMessageCorrectly("ZIN|B|SomeText\\\\|||[OrderLoadingNumber]|",     "ZIN|B||||32421|",              false);
            DoesItDecodeWholeMessageCorrectly("ZIN|B||||[OrderLoadingNumber]^|",                "ZIN|B|B|||32421|",             false);
            DoesItDecodeWholeMessageCorrectly("ZIN|B||||[OrderLoadingNumber]^|",                "ZIN|B|B|||32421^443432|",      true, "OrderLoadingNumber", "32421");
            DoesItDecodeWholeMessageCorrectly("ZIN|B||||[OrderLoadingNumber]^44|",              "ZIN|B|B|||32421^443432|",      true, "OrderLoadingNumber", "32421");
            DoesItDecodeWholeMessageCorrectly("ZIN|B||||[OrderLoadingNumber]^[Test]|",          "ZIN|B|B|||32421^443432|",      true, "OrderLoadingNumber", "32421", "Test", "443432");
            DoesItDecodeWholeMessageCorrectly("ZIN|B|\\[|\\]||[OrderLoadingNumber]^\\[[Test]|", "ZIN|B|[|]||32421^[443432|",    true, "OrderLoadingNumber", "32421", "Test", "443432");
        }

        /// <summary>Test if it decocdes the whole message correctly</summary>
        /// <param name="template">Sequence template</param>
        /// <param name="message">Sequence message</param>
        /// <param name="result">Expected result</param>
        /// <param name="mappings">Expected mapping</param>
        public void DoesItDecodeWholeMessageCorrectly(string template, string message, bool result, params string[] mappings)
        {
            HL7ReservedChars reserverChars = new HL7ReservedChars();
            HL7ReceiverTemplate decoder = new HL7ReceiverTemplate();
            Dictionary<string,string> mappedData = new Dictionary<string,string>();

            decoder.Initalise("Test", template, reserverChars);
            bool valid = decoder.TryParse(message, reserverChars, mappedData);

            Assert.AreEqual(result, valid, "Failed to correctly validate sequence");

            for(int c = 0; c < mappings.Length; c += 2)
            {
                string mappingName  = mappings[c];
                string expectedValue= mappings[c + 1];
                string actualValue;

                if (!mappedData.TryGetValue(mappingName, out actualValue))
                    Assert.Fail(string.Format("Failed to read mapping item '{0}'", mappingName));

                Assert.AreEqual(expectedValue, actualValue, string.Format("Failed to correct read mappnig data for item '{0}'", mappingName));
            }
        }
    }
}
