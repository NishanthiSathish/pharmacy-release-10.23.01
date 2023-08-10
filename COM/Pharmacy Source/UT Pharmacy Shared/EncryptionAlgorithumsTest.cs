using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.shared;

namespace UT_Pharmacy_Shared
{
    /// <summary>
    /// Summary description for EncryptionAlgorithumsTest
    /// </summary>
    [TestClass]
    public class EncryptionAlgorithumsTest
    {
        const string ShortTestString          = "Hello world!";
        const string ShortEncryptedTestString = "0C68B06514C61CEE1FC518AA3177954DB970BCE6306E1029";
        const string LongTestString           = "the quick brown fox jumped over the lazy dog!\"£$%^&*()_+-={}[]:@~;'#<>?,./|\\'";
        const string LongEncryptedTestString  = "9AF63EC81A4D3082BAD9B87D3C41B3411FEB98AAB3C0995215CD3BF73D6EB0283BE6BFEF14DA98A0B54A187DBE4F18D21A6530C6982ABD65B1DEB0CD33D21A2818F63C4218EFB8A23CEE10EB35F89451BAAA386C9FCDB1C5B881B32059AB3824B82F0DDC1B861DA29C00B481257F178194A73637BFF33655055B067D15BA22C895D435B3BB27B3093CB61D94351DB68EBF24B58736DE0C5CB1A7";

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
        [Description("Test if the EncryptionAlgorithms.DecodeHex method decodes valid string correctly")]
        public void DoesDecodeHexWorkCorrectlyForValidStrings()
        {
            Assert.AreEqual(ShortTestString, EncryptionAlgorithms.DecodeHex(ShortEncryptedTestString));
            Assert.AreEqual(LongTestString,  EncryptionAlgorithms.DecodeHex(LongEncryptedTestString));
        }

        [TestMethod]
        [Description("Tests that EncryptionAlgorithms.DecodeHex can spot a string that has not been encoded.")]
        public void DoesDecodeHexSpotsInvalidStrings()
        {
            Assert.AreEqual(string.Empty, EncryptionAlgorithms.DecodeHex("Hello"));
        }

        [TestMethod]
        [Description(@"Tests that EncryptionAlgorithms.DecodeHex returns null\empty string when passed a null\empty string.")]
        public void CanDecodeHexHandleNullOrEmptyStrings()
        {
            Assert.AreEqual(string.Empty, EncryptionAlgorithms.DecodeHex(string.Empty));
            Assert.AreEqual(null,         EncryptionAlgorithms.DecodeHex(null));
        }

        [TestMethod]
        [Description("Test if the EncryptionAlgorithms.EncodeHex method encodes valid string correctly")]
        public void DoesEncodeHexWorkCorrectlyForValidStrings()
        {
            string encodedString;

            encodedString = EncryptionAlgorithms.EncodeHex(ShortTestString);
            Assert.AreEqual(ShortTestString.Length * 4, encodedString.Length, "Failed to create encrypted string of expected length");
            Assert.IsTrue(encodedString.ToUpper().ToCharArray().Any( i => (i >= '0' && i <= '9') || (i >= 'A' && i <= 'F')), "Faield to encrypt correctly");
            Assert.AreNotEqual(encodedString, ShortTestString);

            encodedString = EncryptionAlgorithms.EncodeHex(LongTestString);
            Assert.AreEqual(LongTestString.Length * 4, encodedString.Length, "Failed to create encrypted string of expected length");
            Assert.IsTrue(encodedString.ToUpper().ToCharArray().Any( i => (i >= '0' && i <= '9') || (i >= 'A' && i <= 'F')), "Faield to encrypt correctly");
            Assert.AreNotEqual(encodedString, LongTestString);
        }

        [TestMethod]
        [Description(@"Tests that EncryptionAlgorithms.EncodeHex returns null\empty string when passed a null\empty string.")]
        public void CanEncodeHexHandleNullOrEmptyStrings()
        {
            Assert.AreEqual(string.Empty, EncryptionAlgorithms.EncodeHex(string.Empty));
            Assert.AreEqual(null,         EncryptionAlgorithms.EncodeHex(null));
        }
    }
}
