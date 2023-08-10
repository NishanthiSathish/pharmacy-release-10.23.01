//===========================================================================
//
//							    HL7ReplyTemplateTest.cs
//
//  Holds tests for the HL7ReplyTemplate class.
//
//  Test should be run from within Visual Studio.  
//
//	Modification History:
//	21Dec09 XN Written
//===========================================================================
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;
using ascribe.pharmacy.robotloading;

namespace UT_RobotLoading_Layer
{
    /// <summary>
    ///This is a test class for HL7ReplyTemplateTest and is intended
    ///to contain all HL7ReplyTemplateTest Unit Tests
    ///</summary>
    [TestClass()]
    public class HL7ReplyTemplateTest
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


        /// <summary>Test it generates a message correctly</summary>
        [TestMethod()]
        [Description("Test it generates a message correctly")]
        public void DoesItGenerateMessageCorrectly()
        {
            DoesItGenerateMessageCorrectly("ZIN|B||||32421|",                           "ZIN|B||||[OrderLoadingNumber]|",                   "OrderLoadingNumber", "32421");
            DoesItGenerateMessageCorrectly("ZIN|B|Some\\|Text|||32421|",                "ZIN|B|Some\\|Text|||[OrderLoadingNumber]|",        "OrderLoadingNumber", "32421");
            DoesItGenerateMessageCorrectly("ZIN|B|SomeText\\\\|||32421|",               "ZIN|B|SomeText\\\\|||[OrderLoadingNumber]|",       "OrderLoadingNumber", "32421");
            DoesItGenerateMessageCorrectly("ZIN|B|B|||32421^443432|",                   "ZIN|B|B|||[OrderLoadingNumber]^[Test]|",           "OrderLoadingNumber", "32421", "Test", "443432");
            DoesItGenerateMessageCorrectly("ZIN|B|[|]||32421^[443432|",                 "ZIN|B|\\[|\\]||[OrderLoadingNumber]^\\[[Test]|",   "OrderLoadingNumber", "32421", "Test", "443432");
            DoesItGenerateMessageCorrectly("ZIN|B|[|]||[OrderLoadingNumber]^[443432|",  "ZIN|B|\\[|\\]||[OrderLoadingNumber]^\\[[Test]|",   "Test",               "443432");
            DoesItGenerateMessageCorrectly("ZIN|B||||324\\^21|",                        "ZIN|B||||[OrderLoadingNumber]|",                   "OrderLoadingNumber", "324^21");
            DoesItGenerateMessageCorrectly("ZIN|B||||324\\\\\\^21|",                    "ZIN|B||||[OrderLoadingNumber]|",                   "OrderLoadingNumber", "324\\^21");
            DoesItGenerateMessageCorrectly("ZIN|B||||324[21|",                          "ZIN|B||||[OrderLoadingNumber]|",                   "OrderLoadingNumber", "324[21");
            DoesItGenerateMessageCorrectly("ZIN|B||||324\\\\[21|",                      "ZIN|B||||[OrderLoadingNumber]|",                   "OrderLoadingNumber", "324\\[21");
            DoesItGenerateMessageCorrectly("ZIN|B||||324]21|",                          "ZIN|B||||[OrderLoadingNumber]|",                   "OrderLoadingNumber", "324]21");
            DoesItGenerateMessageCorrectly("ZIN|B||||324\\\\]21|",                      "ZIN|B||||[OrderLoadingNumber]|",                   "OrderLoadingNumber", "324\\]21");
        }

        /// <summary>Test it generates a message correctly</summary>
        /// <param name="expected">Expected result</param>
        /// <param name="template">Expected template</param>
        /// <param name="mappings">Mapping to uses</param>
        public void DoesItGenerateMessageCorrectly(string expected, string template, params string[] mappings)
        {
            Dictionary<string, string> map = new Dictionary<string,string>();
            for (int c = 0; c < mappings.Length; c += 2)
                map.Add(mappings[c], mappings[c + 1]);

            HL7ReservedChars reserverChars = new HL7ReservedChars();
            HL7ReplyTemplate reply = new HL7ReplyTemplate();
            reply.Initalise("Test", template);
            string actual = reply.GenerateReply(reserverChars, map);

            Assert.AreEqual(expected, actual, "Failed to correctly generate message.");
        }
    }
}
