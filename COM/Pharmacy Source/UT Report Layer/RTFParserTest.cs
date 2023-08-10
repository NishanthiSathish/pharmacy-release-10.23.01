using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Xml;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.reportlayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;

namespace UT_Report_Layer
{
    /// <summary>
    /// Summary description for UnitTest1
    /// </summary>
    [TestClass]
    public class RTFParserTest
    {
        public RTFParserTest()
        {
            //
            // TODO: Add constructor logic here
            //
        }

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
        // Use ClassInitialize to run code before running the first test in the class
        
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext) 
        {
            // Get session ID (any will do)
            var sessionId = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC");
            SessionInfo.InitialiseSession(sessionId); 
        }

        //
        // Use ClassCleanup to run code after all tests in a class have run
        // [ClassCleanup()]
        // public static void MyClassCleanup() { }
        //
        // Use TestInitialize to run code before running each test 
        // [TestInitialize()]
        // public void MyTestInitialize() { }
        //
        // Use TestCleanup to run code after each test has run
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        //
        #endregion

        [TestMethod]
        [Description("Test RTFParser.ParseCtrlChars")]
        public void TestRTFParserParseCtrlChars()
        {
            Assert.AreEqual("dfsdfdfe343",                  TestParseCtrlChars("dfsdfdfe343"));         // No change
            Assert.AreEqual("dfsd[cerre]fdfe343",           TestParseCtrlChars("dfsd[cerre]fdfe343"));  // Not handled by ParseCtrlChars
            Assert.AreEqual("dfsd fdfe343",                 TestParseCtrlChars("dfsd[32]fdfe343"));     // standard space
            Assert.AreEqual("dfsd\rfdfe343",                TestParseCtrlChars("dfsd[13]fdfe343"));     // char
            Assert.AreEqual("dfsd[-13]fdfe343",             TestParseCtrlChars("dfsd[-13]fdfe343"));    // invalid char
            Assert.AreEqual("dfsd[256]fdfe343",             TestParseCtrlChars("dfsd[256]fdfe343"));    // invalid char
            Assert.AreEqual("dfsd fdfe343",                 TestParseCtrlChars("dfsd[1x32]fdfe343"));   // standard space once
            Assert.AreEqual("dfsd    fdfe343",              TestParseCtrlChars("dfsd[4x32]fdfe343"));   // standard space 4 times
            Assert.AreEqual("dfsd fdfe343",                 TestParseCtrlChars("dfsd[1x ]fdfe343"));    // standard space once
            Assert.AreEqual("dfsd    fdfe343",              TestParseCtrlChars("dfsd[4x ]fdfe343"));    // standard space 4 times
            Assert.AreEqual("dfsd----fdfe343",              TestParseCtrlChars("dfsd[4x-]fdfe343"));    // standard dash 4 times
            Assert.AreEqual("dfsdfredfredfredfredfdfe343",  TestParseCtrlChars("dfsd[4xfred]fdfe343")); // standard fred 4 times
            Assert.AreEqual(" fdfe343",                     TestParseCtrlChars("[32]fdfe343"));         // standard space
            Assert.AreEqual("fdfe343 ",                     TestParseCtrlChars("fdfe343[32]"));         // standard space
            Assert.AreEqual("fdfe ----343",                 TestParseCtrlChars("fdfe[32][4x-]343"));    // standard space
            Assert.AreEqual("fdfe---- 343",                 TestParseCtrlChars("fdfe[4x-][32]343"));    // standard space
        }

        [TestMethod]
        [Description("Test RTFParser.ParseXML")]
        public void TestRTFParserParseXML()
        {
            string rtfFile   = "dddw[sTest1][sTest2] ds dww [sTest4]";
            string xmlFile   = "<Heap sTest1=\"Test1Val\" sTest2=\"Test2Val\" sTest3=\"Test3Val\" sTest4=\"Test4Val\" sTest5=\"Test5Val\" sTest6=\"\" />";
            string expected  = "dddwTest1ValTest2Val ds dww Test4Val";

            RTFParser parser = new RTFParser();
            parser.Read(rtfFile);
            parser.ParseXML(xmlFile);

            Assert.AreEqual(expected, parser.ToString());
        }

        [TestMethod]
        [Description("Test RTFParser.ParseXML escapes [[ and ]]")]
        public void TestRTFParserParseXMLEscapesSqBarckerts()
        {
            string rtfFile   = "dddw[sTest1][[ [sTest2] ]] ds dww [sTest4]";
            string xmlFile   = "<Heap sTest1=\"Test1Val\" sTest2=\"Test2Val\" sTest3=\"Test3Val\" sTest4=\"Test4Val\" sTest5=\"Test5Val\" sTest6=\"\" />";
            string expected  = "dddwTest1Val[ Test2Val ] ds dww Test4Val";

            RTFParser parser = new RTFParser();
            parser.Read(rtfFile);
            parser.ParseXML(xmlFile);

            Assert.AreEqual(expected, parser.ToString());
        }

        [TestMethod]
        [Description("Test RTFParser.ParseXML is not case sensitive")]
        public void TestRTFParserParseXMLIsNotCaseSensitive()
        {
            string rtfFile   = "dddw[stest1][stest2] ds dww [stest4]";
            string xmlFile   = "<Heap sTest1=\"Test1Val\" sTest2=\"Test2Val\" sTest3=\"Test3Val\" sTest4=\"Test4Val\" sTest5=\"Test5Val\" sTest6=\"\" />";
            string expected  = "dddwTest1ValTest2Val ds dww Test4Val";

            RTFParser parser = new RTFParser();
            parser.Read(rtfFile);
            parser.ParseXML(xmlFile);

            Assert.AreEqual(expected, parser.ToString());
        }

        [TestMethod]
        [Description("Test RTFParser.ParseXML escapes attribute name with \\")]
        public void TestRTFParserParseXMLAttributeName()
        {
            string rtfFile   = "dddw [tCost/100] fred";
            string xmlFile   = "<Heap " + XmlConvert.EncodeName("tCost/100") + "=\"Test1Val\" />";
            string expected  = "dddw Test1Val fred";

            RTFParser parser = new RTFParser();
            parser.Read(rtfFile);
            parser.ParseXML(xmlFile);

            Assert.AreEqual(expected, parser.ToString());
        }

        [TestMethod]
        [Description("Test Parse is case insensitive")]
        public void TestParseIsCaseInsenative()
        {
            string rtfFile = "dddw [tcost/100] fred [tCost/100]bill[tCOST/100]";
            
            RTFParser parser = new RTFParser();
            parser.Read(rtfFile);
            parser.Parse("tCost/100", "test");

            Assert.AreEqual("dddw test fred testbilltest", parser.ToString());
        }

        [TestMethod]
        [Description("Test RTFParser.ParseCtrlChars for [cr]")]
        public void TestRTFParserParseCtrlCharsForCR()
        {
            Assert.AreEqual("dfsdf\\line dfe343", TestParseCtrlChars("dfsdf[cr]dfe343"));         // No change
        }

        /// <summary>Passs originalRTF through method RTFParser.ParseCtrlChars and returns result</summary>
        private string TestParseCtrlChars(string originalRTF)
        {
            RTFParser parser = new RTFParser();
            var type    = parser.GetType();
            var method  = type.GetMethod("ParseCtrlChars", BindingFlags.Instance | BindingFlags.NonPublic);
            if (method == null)
                throw new AssertInconclusiveException("Failed to find private method RTFParser.ParseCtrlChars");

            StringBuilder str = new StringBuilder(originalRTF);
            method.Invoke(parser, new [] { str });
            return str.ToString();
        }
    }
}
