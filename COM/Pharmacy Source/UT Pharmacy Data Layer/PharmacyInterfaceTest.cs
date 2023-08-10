using ascribe.pharmacy.pharmacydatalayer;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using System.Linq;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;
using System.IO;
using System.Reflection;
using ascribe.pharmacy.reportlayer;

namespace UT_Pharmacy_Data_Layer
{
    /// <summary>
    ///This is a test class for PharmacyInterfaceTest and is intended
    ///to contain all PharmacyInterfaceTest Unit Tests
    ///</summary>
    [TestClass()]
    public class PharmacyInterfaceTest
    {
        private static readonly string ExportFilePath       = @"C:\PharmacyInterfaceUnitTest\";
        private static readonly string FilePrefix           = "S";
        private static readonly string FileSuffix           = string.Empty;
        private static readonly string FileExtension        = ".xml";
        private static readonly string WFilePointerCategory = "D|SupInt";
        private static readonly string CoreStoreInnovDir    = @"\\BoltonDev\Data\Development\innov\";
        private const int SiteIDA = 15;

        private static readonly string rtfTestFileE = "E\n[sCode]\n[OutputRefNoPad]";
        private static readonly string rtfTestFileW = "W\n[sCode]\n[OutputRefNoPad]";
        private static readonly string rtfTestFileS = "S\n[sCode]\n[OutputRefNoPad]";
        private static readonly string rtfTestFile  = "Default\n[sCode]";

        private static readonly string rtfTestFileNameE = "UnitTestInterfaceE.rtf";
        private static readonly string rtfTestFileNameW = "UnitTestInterfaceW.rtf";
        private static readonly string rtfTestFileNameS = "UnitTestInterfaceS.rtf";
        private static readonly string rtfTestFileName  = "UnitTestInterface.rtf";

        private static readonly string rtfTranslogFileName = "UnitTestTranslog.rtf";
        private static readonly string TranslogFilePointer = @"dispdata\TransInt.dat";
        private static readonly string TranslogFilePrefix  = "T";
        private static readonly string TranslogFileSuffix  = string.Empty;

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
        // Use TestInitialize to run code before running each test 
        [ClassInitialize()]
        public static void MyClassInitialize(TestContext testContext)
        { 
            int sessionID = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SessionID FROM Session ORDER BY SessionID DESC");

            SessionInfo.InitialiseSessionAndSiteID(sessionID, SiteIDA);
             
            // Write the RTF to the network
            int siteNumber = Database.ExecuteSQLScalar<int>("SELECT TOP 1 SiteNumber FROM site WHERE LocationID=" + SiteIDA);
            string rtfPath = string.Format("{0}dispdata.{1:000}\\", CoreStoreInnovDir, siteNumber);
            File.WriteAllText(rtfPath + rtfTestFileNameE, rtfTestFileE);
            File.WriteAllText(rtfPath + rtfTestFileNameW, rtfTestFileW);
            File.WriteAllText(rtfPath + rtfTestFileNameS, rtfTestFileS);
            File.WriteAllText(rtfPath + rtfTestFileName,  rtfTestFile);
        }

        // Use TestInitialize to run code before running each test 
        [TestInitialize()]
        public void MyTestInitialize()
        {             
            Directory.CreateDirectory(ExportFilePath);

            DirectoryInfo dir = new DirectoryInfo(ExportFilePath);
            dir.GetFiles("*.*").ToList().ForEach(c => File.Delete(c.FullName));

            WConfiguration.Save(SiteIDA, "D|patmed", "GenericInterface", "SupplierInterface",      true,                false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "GenericInterface", "SupplierTypes",          "EWS",               false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "SupplierInterface", "RTFFileE",              rtfTestFileNameE,    false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "SupplierInterface", "RTFFileW",              rtfTestFileNameW,    false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "SupplierInterface", "RTFFileS",              rtfTestFileNameS,    false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "SupplierInterface", "RTFFile",               rtfTestFileName,     false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "SupplierInterface", "ExportFilePath",        ExportFilePath,      false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "SupplierInterface", "InterfacePointerFile",  WFilePointerCategory,false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "SupplierInterface", "FilePrefix",            FilePrefix,          false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "SupplierInterface", "Filesuffix",            FileSuffix,          false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "SupplierInterface", "OutputFileExtension",   FileExtension,       false);
            WConfiguration.Save(SiteIDA, "D|Siteinfo",string.Empty,       "DispdataDRV",           CoreStoreInnovDir,   false);

            WConfiguration.Save(SiteIDA, "D|GenInt", "TranslogInterface", "RTFFile",                rtfTranslogFileName,false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "TranslogInterface", "ExportFilePath",         ExportFilePath,     false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "TranslogInterface", "InterfacePointerFile",   TranslogFilePointer,false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "TranslogInterface", "FilePrefix",             TranslogFilePrefix, false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "TranslogInterface", "Filesuffix",             TranslogFileSuffix, false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "TranslogInterface", "OutputFileExtension",    FileExtension,      false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "Filebatching",      "BatchTotal",             "0",                false);
            WConfiguration.Save(SiteIDA, "D|GenInt", "Filebatching",      "UseFilebatching",        "N",                false);

            WFilePointer.Write(SiteIDA, WFilePointerCategory, 2);
            WFilePointer.Write(SiteIDA, TranslogFilePointer,  4);
         }

         // Use TestCleanup to run code after each test has run
         [TestCleanup()]
         public void MyTestCleanup() 
         {
             DirectoryInfo dir = new DirectoryInfo(ExportFilePath);
             dir.GetFiles("*.*").ToList().ForEach(c => File.Delete(c.FullName));
         }

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
        [Description("Test can ceate a basic suppler2 interface file")]
        public void TestCreateSupplier2File()
        {
            var supplier = CreateSupplerRow(SupplierType.Stores);

            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);

            Assert.IsTrue(obj.GetField("parser").ToString().Length > 0, "Failed to create report");
        }

        [TestMethod]
        [Description("Test does not create supplier2 file if D|patmed.GenericInterface.SupplierInterface is false")]
        public void TestDoesNotCreateSupplierFileOnSupplierInterfaceSetting()
        {
            var supplier = CreateSupplerRow(SupplierType.Stores);

            WConfiguration.Save(SiteIDA, "D|patmed", "GenericInterface", "SupplierInterface", false, false);

            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);

            Assert.IsFalse(obj.GetField("parser").ToString().Length > 0, "Report created when should not be");
        }

        [TestMethod]
        [Description("Test does not create supplier2 file if D|patmed.GenericInterface.SupplierTypes is not valid")]
        public void TestDoesNotCreateSupplluerFileOnSupplierTypesSetting()
        {
            var supplier = CreateSupplerRow(SupplierType.Stores);

            WConfiguration.Save(SiteIDA, "D|GenInt", "GenericInterface", "SupplierTypes", "EW", false);

            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);

            Assert.IsFalse(obj.GetField("parser").ToString().Length > 0, "Report created when should not be");
        }

        [TestMethod]
        [Description("Test errors if no RTFFile file on network")]
        [ExpectedException(typeof(ApplicationException))]
        public void TestErrorIfMissingRTFFile()
        {
            var supplier = CreateSupplerRow(SupplierType.External);
            WConfiguration.Save(SiteIDA, "D|GenInt", "SupplierInterface", "RTFFileE", "UnitTestInterfaceMissingFile.rtf",   false);
            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();
        }

        [TestMethod]
        [Description("Test if missing ExportPath")]
        [ExpectedException(typeof(ApplicationException))]
        public void TestErrorIfMissingExportPath()
        {
            var supplier = CreateSupplerRow(SupplierType.External);
            WConfiguration.Save(SiteIDA, "D|GenInt", "SupplierInterface", "ExportFilePath", string.Empty, false);
            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();
        }

        [TestMethod]
        [Description("Test if DispdataDRV does not contain trailing \\")]
        public void TestDispdataDRVMissingTrailingSlash()
        {
            var supplier = CreateSupplerRow(SupplierType.External);
            WConfiguration.Save(SiteIDA, "D|Siteinfo",string.Empty, "DispdataDRV", CoreStoreInnovDir.SafeSubstring(0, CoreStoreInnovDir.Length - 1),   false);

            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);

            Assert.IsTrue(obj.GetField("parser").ToString().Length > 0, "Failed to create report");
        }

        [TestMethod]
        [Description("Test selects correct supplier RTF report")]
        public void TestSelectsCorrectSupplierRTF()
        {
            PharmacyInterface interfaceFile = new PharmacyInterface();
            SupplierInterfaceSettings settings = null;
            var supplier = CreateSupplerRow(SupplierType.Stores);

            // Test for S type
            supplier.Type = SupplierType.Stores;
            settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);
            string fileContent = obj.GetField("parser").ToString();

            Assert.AreEqual("S", fileContent.SafeSubstring(0, 1), "Has not used the correct RTF file");

            // Test for E type
            supplier.Type = SupplierType.External;
            settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();

            fileContent = obj.GetField("parser").ToString();

            Assert.AreEqual("E", fileContent.SafeSubstring(0, 1), "Has not used the correct RTF file");

            // Test picks up default
            Database.ExecuteSQLNonQuery("DELETE FROM WConfiguration WHERE Category='D|GenInt' AND Section='SupplierInterface' AND [Key]='RTFFileE'");   // Remove E type rtf so picks up default
            supplier.Type = SupplierType.External;
            settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();

            fileContent = obj.GetField("parser").ToString();

            Assert.AreEqual("Default", fileContent.SafeSubstring(0, 7), "Has not used the correct RTF report");
        }

        [TestMethod]
        [Description("Test parses report")]
        public void TestParsesOutputFile()
        {
            var supplier = CreateSupplerRow(SupplierType.Stores);

            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);
            string fileContent    = obj.GetField("parser").ToString();
            Assert.IsTrue(fileContent.Contains(supplier.Code), "Has not parsed report");
        }

        [TestMethod]
        [Description("Test can create a basic customer interface file")]
        public void TestCreateCustomerFile()
        {
            var customer = CreateCustomerRow();

            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(customer.SiteID, SupplierType.Ward);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(customer.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);
            string fileContent = obj.GetField("parser").ToString();

            Assert.IsTrue(fileContent.Length > 0, "Failed to create report");
        }

        [TestMethod]
        [Description("Test does not create supplier file if D|patmed.GenericInterface.SupplierInterface is false (Customer interface still uses old SupplierInterface settings)")]
        public void TestDoesNotCreateCustomerFileOnInterfaceSetting()
        {
            var customer = CreateCustomerRow();

            WConfiguration.Save(SiteIDA, "D|patmed", "GenericInterface", "SupplierInterface", false, false);
            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(customer.SiteID, SupplierType.Ward);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(customer.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);
            string fileContent = obj.GetField("parser").ToString();

            Assert.IsTrue(fileContent.Length == 0, "Created when should not be");
        }

        [TestMethod]
        [Description("Test does not create customer file if D|patmed.GenericInterface.SupplierTypes is not valid (Customer interface still uses old SupplierInterface settings)")]
        public void TestDoesNotCreateCustomerFileOnSupplierTypesSetting()
        {
            var customer = CreateCustomerRow();

            WConfiguration.Save(SiteIDA, "D|GenInt", "GenericInterface", "SupplierTypes", "LES", false);
            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(customer.SiteID, SupplierType.Ward);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(customer.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);
            string fileContent = obj.GetField("parser").ToString();

            Assert.IsTrue(fileContent.Length == 0, "Created when should not be");
        }

        [TestMethod]
        [Description("Test selects correct customer RTF file")]
        public void TestSelectsCorrectCustomerRTFFile()
        {
            PharmacyInterface interfaceFile = new PharmacyInterface();
            SupplierInterfaceSettings settings = null;
            var customer = CreateCustomerRow();

            // Test for E type
            settings = new SupplierInterfaceSettings(customer.SiteID, SupplierType.Ward);
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(customer.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);
            string fileContent = obj.GetField("parser").ToString();

            Assert.AreEqual("W", fileContent.SafeSubstring(0, 1), "Has not used the correct RTF");

            // Test picks up default
            Database.ExecuteSQLNonQuery("DELETE FROM WConfiguration WHERE Category='D|GenInt' AND Section='SupplierInterface' AND [Key]='RTFFileW'");   // Remove E type rtf so picks up default
            settings = new SupplierInterfaceSettings(customer.SiteID, SupplierType.Ward);
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(customer.ToXMLHeap());
            interfaceFile.Save();

            Assert.AreEqual("Default", obj.GetField("parser").ToString().SafeSubstring(0, 7), "Has not used the correct RTF");
        }

        [TestMethod]
        [Description("Test can cerate a basic suppler2 interface for different site to current session site")]
        public void TestCreateSupplier2ForDifferentSite()
        {
            SessionInfo.InitialiseSessionAndSiteID( SessionInfo.SessionID, 19);
            var supplier = CreateSupplerRow(SupplierType.Stores);
            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);
            string fileContent = obj.GetField("parser").ToString();

            Assert.IsTrue(fileContent.Length > 0, "Failed to create report");
        }

        [TestMethod]
        [Description("Test can create a basic customer interface file for different site to current session site")]
        public void TestCreateCustomerFileForDifferentSite()
        {
            var customer = CreateCustomerRow();

            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(customer.SiteID, SupplierType.Ward);
            PharmacyInterface interfaceFile = new PharmacyInterface();
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(customer.ToXMLHeap());
            interfaceFile.Save();

            PrivateObject obj = new PrivateObject(interfaceFile);
            string fileContent = obj.GetField("parser").ToString();

            Assert.IsTrue(fileContent.Length > 0, "Failed to create report");
        }

        [TestMethod]
        [Description("Test parses OutputRefNoPad tag for Supplier")]
        public void TestParseOutputRefNoPadForSupplier()
        {
            var supplier = CreateSupplerRow(SupplierType.Stores);

            PharmacyInterface interfaceFile = new PharmacyInterface();
            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(supplier.SiteID, supplier.Type);
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(supplier.ToXMLHeap());
            interfaceFile.Save();

            int count = WFilePointer.Read(SiteIDA, WFilePointerCategory);

            PrivateObject obj = new PrivateObject(interfaceFile);
            string fileContent = obj.GetField("parser").ToString();

            Assert.IsTrue(fileContent.Contains(count.ToString()), "Has not parsed OutputRefNoPad tag");
        }

        [TestMethod]
        [Description("Test parses OutputRefNoPad tag for Customer")]
        public void TestParseOutputRefNoPadForCustomer()
        {
            var customer = CreateCustomerRow();

            PharmacyInterface interfaceFile = new PharmacyInterface();
            SupplierInterfaceSettings settings = new SupplierInterfaceSettings(customer.SiteID, SupplierType.Ward);
            interfaceFile.Initialise((IPharmacyInterfaceSettings)settings);
            interfaceFile.ParseXml(customer.ToXMLHeap());
            interfaceFile.Save();

            int count = WFilePointer.Read(SiteIDA, WFilePointerCategory);

            PrivateObject obj = new PrivateObject(interfaceFile);
            string fileContent = obj.GetField("parser").ToString();

            Assert.IsTrue(fileContent.Contains(count.ToString()), "Has not parsed OutputRefNoPad tag");
        }

        private WSupplier2Row CreateSupplerRow(SupplierType supplierType)
        {
            WSupplier2 supplier = new WSupplier2();
            var row = supplier.Add();
            row.SiteID= SiteIDA;
            row.Code  = "F4";
            row.Type  = supplierType;
            return row;
        }

        private WCustomerRow CreateCustomerRow()
        {
            WCustomer customer = new WCustomer();
            var row = customer.Add(); 
            row.SiteID = SiteIDA;
            row.Code   = "P4";
            return row;
        }

        private string GetParsedFile(PharmacyInterface interfaceFile)
        {
            var type = typeof(PharmacyInterface);
            var field = type.GetField("parser", BindingFlags.Instance | BindingFlags.NonPublic);
            var parser = field.GetValue(interfaceFile) as RTFParser;
            return parser.ToString();
        }
    }
}
