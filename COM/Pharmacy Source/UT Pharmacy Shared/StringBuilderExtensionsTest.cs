using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.shared;

namespace UT_Pharmacy_Shared
{
    /// <summary>
    /// Summary description for StringBuilderExtensionsTest
    /// </summary>
    [TestClass]
    public class StringBuilderExtensionsTest
    {
        public StringBuilderExtensionsTest()
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
        // [ClassInitialize()]
        // public static void MyClassInitialize(TestContext testContext) { }
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
        [Description("Test the StringBuilder.ReplaceLast method")]
        public void TestStringBuilderReplaceLast()
        {
            Assert.AreEqual(new StringBuilder("A puppy grows to be a puppy. So there").ReplaceLast("puppy", "dog", 1).ToString(), "A puppy grows to be a dog. So there");
            Assert.AreEqual(new StringBuilder("A puppy grows to be a puppy. So there").ReplaceLast("puppy", "dog", 2).ToString(), "A dog grows to be a dog. So there");
            Assert.AreEqual(new StringBuilder("A puppy grows to be a puppy").ReplaceLast ("puppy", "dog", 1).ToString(), "A puppy grows to be a dog");
            Assert.AreEqual(new StringBuilder("puppy grows to be a puppy").ReplaceLast   ("puppy", "dog", 2).ToString(), "dog grows to be a dog");
            Assert.AreEqual(new StringBuilder("puppy grows to be a puppy.").ReplaceLast  ("puppy", "dog", 2).ToString(), "dog grows to be a dog.");
            Assert.AreEqual(new StringBuilder("puppy grows to be a puppy.").ReplaceLast  ("puppy", "dog", 3).ToString(), "dog grows to be a dog.");
            Assert.AreEqual(new StringBuilder("A kitten grows to be a cat").ReplaceLast  ("puppy", "dog", 1).ToString(), "A kitten grows to be a cat");
            Assert.AreEqual(new StringBuilder("A kitten grows to be a cat").ReplaceLast  ("puppy", "dog", 1).ToString(), "A kitten grows to be a cat");
        }

        [TestMethod]
        [Description("Test the StringBuilder.ReplaceNoCase method")]
        public void TestStringBuilderReplaceNoCase()
        {
            Assert.AreEqual("A dog grows to be a dog. So there",            new StringBuilder("A PuPpY grows to be a pUpPy. So there"       ).ReplaceNoCase("puppY", "dog").ToString());
            Assert.AreEqual("A puppy grows to be a puppy. So there",        new StringBuilder("A Dog grows to be a Dog. So there"           ).ReplaceNoCase("dog", "puppy").ToString());
            Assert.AreEqual("A  grows to be a . So there",                  new StringBuilder("A Dog grows to be a Dog. So there"           ).ReplaceNoCase("dog",  "").ToString());
            Assert.AreEqual("A puppy grows to be a puppy. So there puppy",  new StringBuilder("A Dog grows to be a Dog. So there doG"       ).ReplaceNoCase("dog", "puppy").ToString());
            Assert.AreEqual("A puppypuppy grows to be a puppy. So there",   new StringBuilder("A DogDog grows to be a Dog. So there"        ).ReplaceNoCase("dog", "puppy").ToString());
            Assert.AreEqual("A kitten grows to be a cat",                   new StringBuilder("A kitten grows to be a cat"                  ).ReplaceNoCase("puppy", "dog").ToString());
            Assert.AreEqual("A dogdog grows to be a dog. So there",         new StringBuilder("A puppypuppy grows to be a puppy. So there"  ).ReplaceNoCase("puppy", "dog").ToString());
            Assert.AreEqual("A dogpuppy grows to be a dogpuppy. So there",  new StringBuilder("A puppy grows to be a puppy. So there"       ).ReplaceNoCase("puppy", "dogpuppy").ToString());
        }
    }
}
