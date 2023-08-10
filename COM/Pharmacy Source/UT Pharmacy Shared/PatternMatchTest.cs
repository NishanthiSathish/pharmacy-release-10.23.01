using ascribe.pharmacy.shared;
using Microsoft.VisualStudio.TestTools.UnitTesting;
namespace UT_Pharmacy_Shared
{
    
    
    /// <summary>
    ///This is a test class for PatternMatchTest and is intended
    ///to contain all PatternMatchTest Unit Tests
    ///</summary>
    [TestClass()]
    public class PatternMatchTest
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
        [Description("Test PatternMatch.Validate dealing with spaces at end of value, and pattern string")]
        public void PatternMatch_Validate_TestSpacesAtEnd()
        {
            Assert.IsTrue   (PatternMatch.Validate("FSDJS", "ABABA"     ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS", "ABABAA"    ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS", "ABABAB"    ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS", "ABABABB"   ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS", "ABABABBB"  ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS", "ABAB "     ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS", "ABAB  "    ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS", "ABAB   "   ));
            Assert.IsTrue   (PatternMatch.Validate("FSDJS", "ABABA "    ));
            Assert.IsTrue   (PatternMatch.Validate("FSDJS", "ABABA  "   ));
            Assert.IsTrue   (PatternMatch.Validate("FSDJS", "ABABA   "  ));

            Assert.IsFalse  (PatternMatch.Validate("FSDJS ", "ABABA"     ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS ", "ABABAA"    ));
            Assert.IsTrue   (PatternMatch.Validate("FSDJS ", "ABABAB"    ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS ", "ABABABB"   ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS ", "ABABABBB"  ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS ", "ABAB "     ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS ", "ABAB  "    ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS ", "ABAB   "   ));
            Assert.IsTrue   (PatternMatch.Validate("FSDJS ", "ABABA "    ));
            Assert.IsTrue   (PatternMatch.Validate("FSDJS ", "ABABA  "   ));
            Assert.IsTrue   (PatternMatch.Validate("FSDJS ", "ABABA   "  ));

            Assert.IsFalse  (PatternMatch.Validate("FSDJS  ", "ABABA"     ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS  ", "ABABAA"    ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS  ", "ABABAB"    ));
            Assert.IsTrue   (PatternMatch.Validate("FSDJS  ", "ABABABB"   ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS  ", "ABABABBB"  ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS  ", "ABAB "     ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS  ", "ABAB  "    ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS  ", "ABAB   "   ));
            Assert.IsFalse  (PatternMatch.Validate("FSDJS  ", "ABABA "    ));
            Assert.IsTrue   (PatternMatch.Validate("FSDJS  ", "ABABA  "   ));
            Assert.IsTrue   (PatternMatch.Validate("FSDJS  ", "ABABA   "  ));
        }

        [TestMethod()]
        [Description("Test PatternMatch.Validate with empty strings")]
        public void PatternMatch_Validate_EmptyStrings()
        {
            Assert.IsTrue (PatternMatch.Validate("FSDJS",      string.Empty ));
            Assert.IsFalse(PatternMatch.Validate(string.Empty, "ABABA"      ));
            Assert.IsTrue (PatternMatch.Validate(string.Empty, " "          ));
            Assert.IsTrue (PatternMatch.Validate(string.Empty, "  "         ));
            Assert.IsTrue (PatternMatch.Validate(string.Empty, string.Empty ));
        }

        [TestMethod()]
        [Description("Test PatternMatch.Validate with null values")]
        public void PatternMatch_Validate_NullValues()
        {
            Assert.IsTrue (PatternMatch.Validate("FSDJS", null ));
            Assert.IsFalse(PatternMatch.Validate(null, "ABABA" ));
            Assert.IsTrue (PatternMatch.Validate(null, " "     ));
            Assert.IsTrue (PatternMatch.Validate(null, "  "    ));
            Assert.IsTrue (PatternMatch.Validate(null, null    ));
        }

        [TestMethod()]
        [Description("Test PatternMatch.Validate with * pattern")]
        public void PatternMatch_Validate_Pattern_Star()
        {
            Assert.IsTrue (PatternMatch.Validate("A", "*"));
            Assert.IsTrue (PatternMatch.Validate("F", "*"));
            Assert.IsTrue (PatternMatch.Validate("Z", "*"));
            Assert.IsTrue (PatternMatch.Validate("a", "*"));
            Assert.IsTrue (PatternMatch.Validate("f", "*"));
            Assert.IsTrue (PatternMatch.Validate("z", "*"));
            Assert.IsTrue (PatternMatch.Validate("0", "*"));
            Assert.IsTrue (PatternMatch.Validate("6", "*"));
            Assert.IsTrue (PatternMatch.Validate("9", "*"));
            Assert.IsTrue (PatternMatch.Validate("$", "*"));
            Assert.IsTrue (PatternMatch.Validate(".", "*"));
            Assert.IsTrue (PatternMatch.Validate(" ", "*"));
        }

        [TestMethod()]
        [Description("Test PatternMatch.Validate with A pattern")]
        public void PatternMatch_Validate_Pattern_A()
        {
            Assert.IsTrue (PatternMatch.Validate("A", "A"));
            Assert.IsTrue (PatternMatch.Validate("F", "A"));
            Assert.IsTrue (PatternMatch.Validate("Z", "A"));
            Assert.IsTrue (PatternMatch.Validate("a", "A"));
            Assert.IsTrue (PatternMatch.Validate("f", "A"));
            Assert.IsTrue (PatternMatch.Validate("z", "A"));
            Assert.IsFalse(PatternMatch.Validate("0", "A"));
            Assert.IsFalse(PatternMatch.Validate("6", "A"));
            Assert.IsFalse(PatternMatch.Validate("9", "A"));
            Assert.IsFalse(PatternMatch.Validate("$", "A"));
            Assert.IsFalse(PatternMatch.Validate(".", "A"));
            Assert.IsFalse(PatternMatch.Validate(" ", "A"));
        }

        [TestMethod()]
        [Description("Test PatternMatch.Validate with B pattern")]
        public void PatternMatch_Validate_Pattern_B()
        {
            Assert.IsTrue (PatternMatch.Validate("A", "B"));
            Assert.IsTrue (PatternMatch.Validate("F", "B"));
            Assert.IsTrue (PatternMatch.Validate("Z", "B"));
            Assert.IsTrue (PatternMatch.Validate("a", "B"));
            Assert.IsTrue (PatternMatch.Validate("f", "B"));
            Assert.IsTrue (PatternMatch.Validate("z", "B"));
            Assert.IsFalse(PatternMatch.Validate("0", "B"));
            Assert.IsFalse(PatternMatch.Validate("6", "B"));
            Assert.IsFalse(PatternMatch.Validate("9", "B"));
            Assert.IsFalse(PatternMatch.Validate("$", "B"));
            Assert.IsFalse(PatternMatch.Validate(".", "B"));
            Assert.IsTrue (PatternMatch.Validate(" ", "B"));
        }

        [TestMethod()]
        [Description("Test PatternMatch.Validate with X pattern")]
        public void PatternMatch_Validate_Pattern_X()
        {
            Assert.IsTrue (PatternMatch.Validate("A", "X"));
            Assert.IsTrue (PatternMatch.Validate("F", "X"));
            Assert.IsTrue (PatternMatch.Validate("Z", "X"));
            Assert.IsTrue (PatternMatch.Validate("a", "X"));
            Assert.IsTrue (PatternMatch.Validate("f", "X"));
            Assert.IsTrue (PatternMatch.Validate("z", "X"));
            Assert.IsTrue (PatternMatch.Validate("0", "X"));
            Assert.IsTrue (PatternMatch.Validate("6", "X"));
            Assert.IsTrue (PatternMatch.Validate("9", "X"));
            Assert.IsFalse(PatternMatch.Validate("$", "X"));
            Assert.IsFalse(PatternMatch.Validate(".", "X"));
            Assert.IsFalse(PatternMatch.Validate(" ", "X"));
        }

        [TestMethod()]
        [Description("Test PatternMatch.Validate with 9 pattern")]
        public void PatternMatch_Validate_Pattern_9()
        {
            Assert.IsFalse(PatternMatch.Validate("A", "9"));
            Assert.IsFalse(PatternMatch.Validate("F", "9"));
            Assert.IsFalse(PatternMatch.Validate("Z", "9"));
            Assert.IsFalse(PatternMatch.Validate("a", "9"));
            Assert.IsFalse(PatternMatch.Validate("f", "9"));
            Assert.IsFalse(PatternMatch.Validate("z", "9"));
            Assert.IsTrue (PatternMatch.Validate("0", "9"));
            Assert.IsTrue (PatternMatch.Validate("6", "9"));
            Assert.IsTrue (PatternMatch.Validate("9", "9"));
            Assert.IsFalse(PatternMatch.Validate("$", "9"));
            Assert.IsFalse(PatternMatch.Validate(".", "9"));
            Assert.IsFalse(PatternMatch.Validate(" ", "9"));
        }

        [TestMethod()]
        [Description("Test PatternMatch.Validate with 0 pattern")]
        public void PatternMatch_Validate_Pattern_0()
        {
            Assert.IsFalse(PatternMatch.Validate("A", "0"));
            Assert.IsFalse(PatternMatch.Validate("F", "0"));
            Assert.IsFalse(PatternMatch.Validate("Z", "0"));
            Assert.IsFalse(PatternMatch.Validate("a", "0"));
            Assert.IsFalse(PatternMatch.Validate("f", "0"));
            Assert.IsFalse(PatternMatch.Validate("z", "0"));
            Assert.IsTrue (PatternMatch.Validate("0", "0"));
            Assert.IsTrue (PatternMatch.Validate("6", "0"));
            Assert.IsTrue (PatternMatch.Validate("9", "0"));
            Assert.IsFalse(PatternMatch.Validate("$", "0"));
            Assert.IsTrue (PatternMatch.Validate(".", "0"));
            Assert.IsFalse(PatternMatch.Validate(" ", "0"));
        }

        [TestMethod()]
        [Description("Test PatternMatch.Validate with . pattern")]
        public void PatternMatch_Validate_Pattern_Dot()
        {
            Assert.IsFalse(PatternMatch.Validate("A", "."));
            Assert.IsFalse(PatternMatch.Validate("F", "."));
            Assert.IsFalse(PatternMatch.Validate("Z", "."));
            Assert.IsFalse(PatternMatch.Validate("a", "."));
            Assert.IsFalse(PatternMatch.Validate("f", "."));
            Assert.IsFalse(PatternMatch.Validate("z", "."));
            Assert.IsFalse(PatternMatch.Validate("0", "."));
            Assert.IsFalse(PatternMatch.Validate("6", "."));
            Assert.IsFalse(PatternMatch.Validate("9", "."));
            Assert.IsFalse(PatternMatch.Validate("$", "."));
            Assert.IsTrue (PatternMatch.Validate(".", "."));
            Assert.IsFalse(PatternMatch.Validate(" ", "."));
        }

        [TestMethod()]
        [Description("Test PatternMatch.Validate with space pattern")]
        public void PatternMatch_Validate_Pattern_Space()
        {
            Assert.IsFalse(PatternMatch.Validate("A", " "));
            Assert.IsFalse(PatternMatch.Validate("F", " "));
            Assert.IsFalse(PatternMatch.Validate("Z", " "));
            Assert.IsFalse(PatternMatch.Validate("a", " "));
            Assert.IsFalse(PatternMatch.Validate("f", " "));
            Assert.IsFalse(PatternMatch.Validate("z", " "));
            Assert.IsFalse(PatternMatch.Validate("0", " "));
            Assert.IsFalse(PatternMatch.Validate("6", " "));
            Assert.IsFalse(PatternMatch.Validate("9", " "));
            Assert.IsFalse(PatternMatch.Validate("$", " "));
            Assert.IsFalse(PatternMatch.Validate(".", " "));
            Assert.IsTrue (PatternMatch.Validate(" ", " "));
        }
    }
}
