//===========================================================================
//
//							EnumViaDBLookupAttributeTest.cs
//
//  Holds tests for the EnumViaDBLookupAttribute class.
//
//  Test should be run from within Visual Studio.  
//
//	Modification History:
//	03Jun09 XN  Written
//===========================================================================
using System;
using System.Configuration;
using System.Linq;
using ascribe.pharmacy.shared;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UT_Pharmacy_Shared
{
    /// <summary>
    /// Summary description for UnitTest1
    /// </summary>
    [TestClass]
    public class EnumViaDBLookupAttributeTest
    {
        // Used to test the EnumViaDBLookupAttribute functions
        // The enumerated type relates to the database table EnumLookupTest.
        [EnumViaDBLookupAttribute(TableName = "EnumLookupTest", PKColumn = "EnumLookupTestID", DescriptionColumn = "ADescription")]
        private enum TestEnum
        {
            Stuff,
            OtherStuff,

            [EnumDBDescription("Some stuff different to others")]
            SomeStuffDiffToOthers,

            [EnumDBDescription("Anti stuff")]
            DarkMatter,

            InvalidEnum,    // This value is purposely not supported by the database table
        };

        // Used to test the EnumViaDBLookupAttribute functions
        // The enumerated type purposely does not support the EnumViaDBLookupAttribute
        private enum InvalidEnum
        {
            Stuff,
            OtherStuff,
        }

        // DB ids for the enum from the EnumLookupTest
        const int TestEnumStuffID                 = 1;
        const int TestEnumOtherStuffID            = 3;
        const int TestEnumSomeStuffDiffToOthersID = 4;
        const int TestEnumDarkMatterID            = 6; 

        static private TestDBDataContext linqdb;
        static private int SessionID;
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

        // Use ClassInitialize to run code before running the first test in the class
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext)
        {
            Configuration conf = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            ConnectionStringsSection connectionStrSect = conf.ConnectionStrings;

            string connectionStr = connectionStrSect.ConnectionStrings["TRNRTL10.My.MySettings.ConnectionString"].ConnectionString;
            linqdb = new TestDBDataContext(connectionStr);

            // Create the EnumLookupTest table used by test in this calss
            linqdb.ExecuteCommand("Exec pDrop 'EnumLookupTest'");
            linqdb.ExecuteCommand("CREATE TABLE EnumLookupTest ( EnumLookupTestID int PRIMARY KEY NOT NULL, ADescription varchar(100) NOT NULL)");

            linqdb.ExecuteCommand("INSERT INTO EnumLookupTest (EnumLookupTestID, ADescription) VALUES (1, 'Stuff')");
            linqdb.ExecuteCommand("INSERT INTO EnumLookupTest (EnumLookupTestID, ADescription) VALUES (3, 'OtherStuff')");
            linqdb.ExecuteCommand("INSERT INTO EnumLookupTest (EnumLookupTestID, ADescription) VALUES (4, 'Some stuff different to others')");
            linqdb.ExecuteCommand("INSERT INTO EnumLookupTest (EnumLookupTestID, ADescription) VALUES (5, 'Test A')");
            linqdb.ExecuteCommand("INSERT INTO EnumLookupTest (EnumLookupTestID, ADescription) VALUES (6, 'Anti stuff')");

            // Get a sesssion ID (any will do)
            SessionID = linqdb.ExecuteQuery<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC").First();
        }

        // Use ClassCleanup to run code after all tests in a class have run
        [ClassCleanup()]
        public static void MyClassCleanup() 
        { 
            linqdb.ExecuteCommand("Exec pDrop 'EnumLookupTest'");
        }

        /// <summary>
        /// Called before each test is run. 
        /// Resets the database
        /// Setup a mock HttpContext
        /// Initalise the SessionInfo class
        /// </summary>
        [TestInitialize()]
        public void MyTestInitialize()
        {
            // Determine directory the test are being run in.
            string assemblyFile = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string assemblyDir = System.IO.Path.GetDirectoryName(assemblyFile);

            // Initalise the SessionInfo class
            SessionInfo.InitialiseSession(SessionID);
        }

        // Use TestCleanup to run code after each test has run
        // [TestCleanup()]
        // public void MyTestCleanup() { }
        //
        #endregion

        [TestMethod()]
        [Description("Tests if the EnumViaDBLookupAttribute.ToLookupID functions works.")]
        public void DoesToLookupIDMethodWork()
        {
            Assert.AreEqual(TestEnumStuffID,                 EnumViaDBLookupAttribute.ToLookupID<TestEnum>(TestEnum.Stuff));
            Assert.AreEqual(TestEnumOtherStuffID,            EnumViaDBLookupAttribute.ToLookupID<TestEnum>(TestEnum.OtherStuff));
            Assert.AreEqual(TestEnumSomeStuffDiffToOthersID, EnumViaDBLookupAttribute.ToLookupID<TestEnum>(TestEnum.SomeStuffDiffToOthers));
            Assert.AreEqual(TestEnumDarkMatterID,            EnumViaDBLookupAttribute.ToLookupID<TestEnum>(TestEnum.DarkMatter));
        }

        [TestMethod()]
        [Description("Tests if EnumViaDBLookupAttribute.ToLookupID errors if enum does not support EnumViaDBLook.")]
        [ExpectedException(typeof(ApplicationException))]
        public void DoesToLookupIDErrorIfEnumDoesNotSupportEnumViaDBLook()
        {
            EnumViaDBLookupAttribute.ToLookupID<InvalidEnum>(InvalidEnum.Stuff);
        }

        [TestMethod()]
        [Description("Test for EnumViaDBLookupAttribute.ToLookupID when enum value does not have related row.")]
        [ExpectedException(typeof(ApplicationException))]
        public void DoesToLookupIDErrorIfEnumValueDoesNotExistInDB()
        {
            EnumViaDBLookupAttribute.ToLookupID<TestEnum>(TestEnum.InvalidEnum);
        }

        [TestMethod()]
        [Description("Test for EnumViaDBLookupAttribute.ToEnum works for ids.")]
        public void DoesToEnumWorkForIDs()
        {
            Assert.AreEqual(TestEnum.Stuff,                 EnumViaDBLookupAttribute.ToEnum<TestEnum>(TestEnumStuffID));
            Assert.AreEqual(TestEnum.OtherStuff,            EnumViaDBLookupAttribute.ToEnum<TestEnum>(TestEnumOtherStuffID));
            Assert.AreEqual(TestEnum.SomeStuffDiffToOthers, EnumViaDBLookupAttribute.ToEnum<TestEnum>(TestEnumSomeStuffDiffToOthersID));
            Assert.AreEqual(TestEnum.DarkMatter,            EnumViaDBLookupAttribute.ToEnum<TestEnum>(TestEnumDarkMatterID));
        }

        [TestMethod()]
        [Description("Test for EnumViaDBLookupAttribute.ToEnum when id does not relate to enum value.")]
        [ExpectedException(typeof(ApplicationException))]
        public void DoesToEnumErrorIfGivenInvalidID()
        {
            EnumViaDBLookupAttribute.ToEnum<TestEnum>(88);
        }








        [TestMethod()]
        [Description("Tests if the EnumViaDBLookupAttribute.ToLookupDescription functions works.")]
        public void DoesToLookupDescriptionMethodWork()
        {

            Assert.AreEqual("Stuff",                          EnumViaDBLookupAttribute.ToLookupDescription<TestEnum>(TestEnum.Stuff));
            Assert.AreEqual("OtherStuff",                     EnumViaDBLookupAttribute.ToLookupDescription<TestEnum>(TestEnum.OtherStuff));
            Assert.AreEqual("Some stuff different to others", EnumViaDBLookupAttribute.ToLookupDescription<TestEnum>(TestEnum.SomeStuffDiffToOthers));
            Assert.AreEqual("Anti stuff",                     EnumViaDBLookupAttribute.ToLookupDescription<TestEnum>(TestEnum.DarkMatter));
        }

        [TestMethod()]
        [Description("Tests if EnumViaDBLookupAttribute.ToLookupDescription errors if enum does not support EnumViaDBLook.")]
        [ExpectedException(typeof(ApplicationException))]
        public void DoesToLookupDescriptionErrorIfEnumDoesNotSupportEnumViaDBLook()
        {
            EnumViaDBLookupAttribute.ToLookupDescription<InvalidEnum>(InvalidEnum.Stuff);
        }

        [TestMethod()]
        [Description("Test for EnumViaDBLookupAttribute.ToEnum works for descriptions.")]
        public void DoesToEnumWorkForDescriptions()
        {
            Assert.AreEqual(TestEnum.Stuff,                 EnumViaDBLookupAttribute.ToEnum<TestEnum>("Stuff"));
            Assert.AreEqual(TestEnum.OtherStuff,            EnumViaDBLookupAttribute.ToEnum<TestEnum>("OtherStuff"));
            Assert.AreEqual(TestEnum.SomeStuffDiffToOthers, EnumViaDBLookupAttribute.ToEnum<TestEnum>("Some stuff different to others"));
            Assert.AreEqual(TestEnum.DarkMatter,            EnumViaDBLookupAttribute.ToEnum<TestEnum>("Anti stuff"));                     
        }

        [TestMethod()]
        [Description("Test EnumViaDBLookupAttribute.ToEnum is case insensitive.")]
        public void IsToEnumCaseInsensitive()
        {
            Assert.AreEqual(TestEnum.OtherStuff,            EnumViaDBLookupAttribute.ToEnum<TestEnum>("OtHeRsTuFf"));
            Assert.AreEqual(TestEnum.SomeStuffDiffToOthers, EnumViaDBLookupAttribute.ToEnum<TestEnum>("sOmE sTuFf DiFfErEnT tO oThErS"));
        }

        [TestMethod()]
        [Description("Test for EnumViaDBLookupAttribute.ToEnum when description does not relate to enum value.")]
        [ExpectedException(typeof(ApplicationException))]
        public void DoesToEnumErrorIfGivenInvalidDescription()
        {
            EnumViaDBLookupAttribute.ToEnum<TestEnum>("fdhsfklsdh");
        }

    }
}
