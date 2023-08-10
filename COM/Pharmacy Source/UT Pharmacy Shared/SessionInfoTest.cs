using System;
using System.Configuration;
using System.Linq;
using System.Web;
using ascribe.pharmacy.shared;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace UT_Pharmacy_Shared
{
    using System.Runtime.InteropServices.ComTypes;

    /// <summary>
    ///This is a test class for SessionInfoTest and is intended
    ///to contain all SessionInfoTest Unit Tests
    ///</summary>
    [TestClass()]
    public class SessionInfoTest
    {
        private static int SessionID;               // relates to row in session table
        private static int InvalidSessionID = -15;

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
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext)
        {
            Configuration conf = ConfigurationManager.OpenExeConfiguration(ConfigurationUserLevel.None);
            ConnectionStringsSection connectionStrSect = conf.ConnectionStrings;

            string connectionStr = connectionStrSect.ConnectionStrings["TRNRTL10.My.MySettings.ConnectionString"].ConnectionString;
            TestDBDataContext linqdb = new TestDBDataContext(connectionStr);

            // Get a sesssion ID (any will do)
            SessionID = linqdb.ExecuteQuery<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC").First();
        }
        
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


        /// <summary>Test the validatiaon of valid SessionID<summary>
        [TestMethod()]
        [Description("Test the validatiaon of valid SessionID")]
        public void TestValidationOfValidSessionID()
        {
            // Determine directory the test are being run in.
            string assemblyFile = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string assemblyDir = System.IO.Path.GetDirectoryName(assemblyFile);

            // Setup a mock HttpContext
            SimulatedHttpRequest.SetHttpContextWithSimulatedRequest("http://localhost/TestApp", "test app", assemblyDir, "SessionID=" + SessionID.ToString() + "&AscribeSiteNumber=503");

            SessionInfo.InitialiseSession(SessionID);
            SessionInfo.InitialiseSessionAndSiteID(SessionID, 15);
            SessionInfo.InitialiseSessionAndSiteNumber(SessionID, 503);            
            SessionInfo.InitialiseSession(HttpContext.Current.Request);
            SessionInfo.InitialiseSessionAndSite(HttpContext.Current.Request, HttpContext.Current.Response);
        }

        /// <summary>Test the validatiaon of invalid SessionID<summary>
        [TestMethod()]
        [Description("Test the validatiaon of invalid SessionID")]
        [ExpectedException(typeof(ApplicationException))]
        public void TestValidationOfInvalidSessionID1()
        {
            SessionInfo.InitialiseSession(InvalidSessionID);
        }

        /// <summary>Test the validatiaon of invalid SessionID<summary>
        [TestMethod()]
        [Description("Test the validatiaon of invalid SessionID")]
        [ExpectedException(typeof(ApplicationException))]
        public void TestValidationOfInvalidSessionID2()
        {
            SessionInfo.InitialiseSessionAndSiteID(InvalidSessionID, 15);
        }

        /// <summary>Test the validatiaon of invalid SessionID<summary>
        [TestMethod()]
        [Description("Test the validatiaon of invalid SessionID")]
        [ExpectedException(typeof(ApplicationException))]
        public void TestValidationOfInvalidSessionID3()
        {
            SessionInfo.InitialiseSessionAndSiteNumber(InvalidSessionID, 503);
        }

        /// <summary>Test the validatiaon of invalid SessionID<summary>
        [TestMethod()]
        [Description("Test the validatiaon of invalid SessionID")]
        [ExpectedException(typeof(ApplicationException))]
        public void TestValidationOfInvalidSessionID4()
        {
            // Determine directory the test are being run in.
            string assemblyFile = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string assemblyDir = System.IO.Path.GetDirectoryName(assemblyFile);

            // Setup a mock HttpContext
            SimulatedHttpRequest.SetHttpContextWithSimulatedRequest("http://localhost/TestApp", "test app", assemblyDir, "SessionID=" + InvalidSessionID.ToString());

            SessionInfo.InitialiseSession(HttpContext.Current.Request);
        }

        /// <summary>Test the validatiaon of invalid SessionID<summary>
        [TestMethod()]
        [Description("Test the validatiaon of invalid SessionID")]
        [ExpectedException(typeof(ApplicationException))]
        public void TestValidationOfInvalidSessionID5()
        {
            // Determine directory the test are being run in.
            string assemblyFile = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string assemblyDir = System.IO.Path.GetDirectoryName(assemblyFile);

            // Setup a mock HttpContext
            SimulatedHttpRequest.SetHttpContextWithSimulatedRequest("http://localhost/TestApp", "test app", assemblyDir, "SessionID=" + InvalidSessionID.ToString() + "&AscribeSiteNumber=503");

            SessionInfo.InitialiseSessionAndSite(HttpContext.Current.Request, null);
        }

        [TestMethod()]
        [Description("Test reads old AscribeSiteNumber")]
        public void TestReadsOldAscribeSiteNumber()
        {
            // Determine directory the test are being run in.
            string assemblyFile = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string assemblyDir = System.IO.Path.GetDirectoryName(assemblyFile);

            SimulatedHttpRequest.SetHttpContextWithSimulatedRequest("http://localhost/TestApp", "test app", assemblyDir, "SessionID=" + SessionID + "&AscribeSiteNumber=427");
            SessionInfo.InitialiseSessionAndSite(HttpContext.Current.Request, null);    
            Assert.AreEqual(427, SessionInfo.SiteNumber);
        }

        [TestMethod()]
        [Description("Test reads SiteID")]
        public void TestReadsSiteID()
        {
            // Determine directory the test are being run in.
            string assemblyFile = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string assemblyDir = System.IO.Path.GetDirectoryName(assemblyFile);

            SimulatedHttpRequest.SetHttpContextWithSimulatedRequest("http://localhost/TestApp", "test app", assemblyDir, "SessionID=" + SessionID + "&SiteID=20");
            SessionInfo.InitialiseSessionAndSite(HttpContext.Current.Request, null);    
            Assert.AreEqual(20, SessionInfo.SiteID);
        }
    }
}
