//===========================================================================
//
//							    HL7DecoderTest.cs
//
//  Holds tests for the HL7Decoder class.
//
//  Test should be run from within Visual Studio.  
//
//	Modification History:
//	21Dec09 XN Written
//===========================================================================
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.robotloading;

namespace UT_RobotLoading_Layer
{
    /// <summary>
    ///This is a test class for HL7DecoderTest and is intended
    ///to contain all HL7DecoderTest Unit Tests
    ///</summary>
    [TestClass()]
    public class HL7DecoderTest
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


        /// <summary>Test can correctly decode a message</summary>
        [TestMethod()]
        [Description("Test can correctly decode a message")]
        public void CanDecodeMessage()
        {
            HL7Decoder target = new HL7Decoder(); 
            target.SetReceiverHeaderTemplate("MSH|^~\\&|ARX|ez|IT|bla|20010127100002|ax|RER|[MessageControlID]|P|2.3|||AL|AL|44||");
            target.AddReceiverTemplate("AskForNewDelivery",     "ZIN|B|||   |[OrderLoadingNumber]|");
            target.AddReceiverTemplate("RecieveNewDelivery",    "ZIN|B|||[Empty]|[OrderLoadingNumber]|");
            target.AddReceiverTemplate("WarnEndOfDelivery",     "ZIN|E|\\[|\\]||[OrderLoadingNumber]^\\[[Test]|");

            Dictionary<string,string> mapper = new Dictionary<string,string>();
            IEnumerable<string> messageNames = null;

            mapper.Clear();
            messageNames = target.DecodeMessage("MSH|^~\\&|ARX|ez|IT|bla|20010127100002|ax|RER|10|P|2.3|||AL|AL|44||\rZIN|B|B|||32421^443432|", mapper);
            Assert.AreEqual(1, messageNames.Count());
            Assert.AreEqual("RecieveNewDelivery", messageNames.First() , "Failed classify the message correctly");
            Assert.AreEqual("10", mapper["MessageControlID"]);
            Assert.AreEqual("32421^443432", mapper["OrderLoadingNumber"]);
            Assert.AreEqual(2, mapper.Count, "Decoded to many tags");

            mapper.Clear();
            messageNames = target.DecodeMessage("MSH|^~\\&|ARX|ez|IT|bla|20010127100002|ax|RER|10|P|2.3|||AL|AL|44||\rZIN|B|B||   |32421^443432|", mapper);
            Assert.AreEqual(1, messageNames.Count());
            Assert.AreEqual("AskForNewDelivery", messageNames.First(), "Failed classify the message correctly");
            Assert.AreEqual("10", mapper["MessageControlID"]);
            Assert.AreEqual("32421^443432", mapper["OrderLoadingNumber"]);
            Assert.AreEqual(2, mapper.Count, "Decoded to many tags");

            mapper.Clear();
            messageNames = target.DecodeMessage("MSH|^~\\&|ARX|ez|IT|bla|20010127100002|ax|RER|10|P|2.3|||AL|AL|44||\rZIN|E|[|]||32421^[443432|", mapper);
            Assert.AreEqual(1, messageNames.Count());
            Assert.AreEqual("WarnEndOfDelivery", messageNames.First(), "Failed classify the message correctly");
            Assert.AreEqual("10", mapper["MessageControlID"]);
            Assert.AreEqual("32421", mapper["OrderLoadingNumber"]);
            Assert.AreEqual("443432", mapper["Test"]);
            Assert.AreEqual(3, mapper.Count, "Decoded to many tags");

            mapper.Clear();
            messageNames = target.DecodeMessage("MSH|^~\\&|ARX|ez|IT|bla|20010127100002|ax|RER|10|P|2.3|||AL|AL|44||\rZIN||B|||32421^443432|", mapper);
            Assert.AreEqual(0, messageNames.Count(), "Failed to reject the message correctly");
            Assert.AreEqual(1, mapper.Count, "Should not of decoded too many tags (one tag from header)");
        }

        /// <summary>Can spot invalid header</summary>
        [TestMethod()]
        [Description("Can spot invalid header")]
        public void CanSpotInvalidHeader()
        {
            HL7Decoder target = new HL7Decoder(); 
            target.SetReceiverHeaderTemplate("MSH|^~\\&|ARX|ez|IT|bla|20010127100002|ax|RER|[MessageControlID]|P|2.3|||AL|AL|44||");
            target.AddReceiverTemplate("AskForNewDelivery",     "ZIN|B||||[OrderLoadingNumber]|");

            Dictionary<string,string> mapper = new Dictionary<string,string>();
            IEnumerable<string> messageNames = null;

            mapper.Clear();
            messageNames = target.DecodeMessage("MH|^~\\&|ARX|ez|IT|bla|20010127100002|ax|RER|10|P|2.3|||AL|AL|44||\rZIN|B|B|||32421^443432|", mapper);
            Assert.AreEqual(0, messageNames.Count(), "Failed to reject the message correctly");
            Assert.AreEqual(0, mapper.Count, "Should not of decoded too many tags");

            mapper.Clear();
            messageNames = target.DecodeMessage("MSH|^~\\&|AX|ez|IT|bla|20010127100002|ax|RER|10|P|2.3|||AL|AL|44||\rZIN|B|B|||32421^443432|", mapper);
            Assert.AreEqual(0, messageNames.Count(), "Failed to reject the message correctly");
            Assert.AreEqual(0, mapper.Count, "Should not of decoded too many tags");
        }

        /// <summary>Can handle different separator characters</summary>
        [TestMethod()]
        [Description("Can handle different separator characters")]
        public void CanHandleDiffSeparatirCharacters()
        {
            HL7Decoder target = new HL7Decoder(); 
            target.SetReceiverHeaderTemplate("MSH-+~/&-ARX-ez-IT-bla-20010127100002-ax-RER-[MessageControlID]-P-2.3---AL-AL-44--");
            target.AddReceiverTemplate("AskForNewDelivery",     "ZIN-B----[OrderLoadingNumber]+[Test]-");

            Dictionary<string,string> mapper = new Dictionary<string,string>();
            IEnumerable<string> messageNames = null;

            mapper.Clear();
            messageNames = target.DecodeMessage("MSH-+~/&-ARX-ez-IT-bla-20010127100002-ax-RER-10-P-2.3---AL-AL-44--\rZIN-B-B---32421+443/+432-", mapper);
            Assert.AreEqual(1, messageNames.Count());
            Assert.AreEqual("AskForNewDelivery", messageNames.First(), "Failed classify the message correctly");
            Assert.AreEqual("10", mapper["MessageControlID"]);
            Assert.AreEqual("32421", mapper["OrderLoadingNumber"]);
            Assert.AreEqual("443+432", mapper["Test"]);
            Assert.AreEqual(3, mapper.Count, "Decoded to many tags");

            mapper.Clear();
            messageNames = target.DecodeMessage("MSH-+~/&-ARX-ez-IT-bla-20010127100002-ax-RER-10-P-2.3---AL-AL-44--\rZIN--B---32421+443432-", mapper);
            Assert.AreEqual(0, messageNames.Count());
            Assert.AreEqual(1, mapper.Count, "Should not of decoded too many tags (one from header)");
        }

        /// <summary>Test it can create a reply message</summary>
        [TestMethod()]
        [Description("Test it can create a reply message")]
        public void CanItCreateAReplyMessage()
        {
            HL7Decoder target = new HL7Decoder(); 
            target.SetReplyHeaderTemplate("MSH|^~\\&|ARX|ez|IT|bla|20010127100002|ax|RER|[MessageControlID]|P|2.3|||AL|AL|44||");
            target.AddReplyTemplate("AskForNewDelivery1", "ZIN|B||||[OrderLoadingNumber]^[Test]|");
            target.AddReplyTemplate("AskForNewDelivery2", "ZIN|B|\\[MessageControlID\\]|||[OrderLoadingNumber]^[Test]|");

            Dictionary<string,string> mapper = new Dictionary<string,string>();
            mapper.Add ("MessageControlID", "10");
            mapper.Add ("OrderLoadingNumber", "32421");
            mapper.Add ("Test", "443+432");

            string actual = target.GenerateReply("AskForNewDelivery1", mapper);
            string expected = "MSH|^~\\&|ARX|ez|IT|bla|20010127100002|ax|RER|10|P|2.3|||AL|AL|44||\rZIN|B||||32421^443+432|\r";
            Assert.AreEqual(expected, actual, "Failed to crete reply message correctly");

            actual = target.GenerateReply("AskForNewDelivery2", mapper);
            expected = "MSH|^~\\&|ARX|ez|IT|bla|20010127100002|ax|RER|10|P|2.3|||AL|AL|44||\rZIN|B|[MessageControlID]|||32421^443+432|\r";
            Assert.AreEqual(expected, actual, "Failed to crete reply message correctly");
        }
    }
}
