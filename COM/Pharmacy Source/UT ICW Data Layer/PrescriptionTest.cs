using System;
using System.Text;
using System.Collections.Generic;
using System.Linq;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace UT_ICW_Data_Layer
{
    using ascribe.pharmacy.shared;

    [TestClass]
    public class PrescriptionTest
    {
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
        [Description("Test PrescriptionStandard HasDoseRange method")]
        public void Test_PrescriptionStandard_HasDoseRange()
        {
            Prescription prescription = new Prescription();

            prescription.Add();
            prescription.Table.Rows[0]["RequestTypeID"] = ICWTypes.GetTypeByDescription(ICWType.Request, "Standard Prescription").Value.ID;
            prescription.Table.Columns.Add("Dose",    typeof(double));
            prescription.Table.Columns.Add("DoseLow", typeof(double));
            var row = prescription[0] as PrescriptionStandardRow;

            row.RawRow["Dose"   ] = 0.0;
            row.RawRow["DoseLow"] = DBNull.Value;
            Assert.IsFalse(row.HasDoseRange, "Invalid HasDoseRange when Dose is 0 and DoseLow is null");

            row.RawRow["Dose"   ] = 60.0;
            row.RawRow["DoseLow"] = DBNull.Value;
            Assert.IsFalse(row.HasDoseRange, "Invalid HasDoseRange when Dose > 0 and DoseLow is null");


            row.RawRow["Dose"   ] = 0.0;
            row.RawRow["DoseLow"] = 0;
            Assert.IsFalse(row.HasDoseRange, "Invalid HasDoseRange when Dose is 0 and DoseLow is 0");

            row.RawRow["Dose"   ] = 60.0;
            row.RawRow["DoseLow"] = 0;
            Assert.IsFalse(row.HasDoseRange, "Invalid HasDoseRange when Dose > 0 and DoseLow is 0");


            row.RawRow["Dose"   ] = 0.0;
            row.RawRow["DoseLow"] = 10;
            Assert.IsFalse(row.HasDoseRange, "Invalid HasDoseRange when Dose is 0 and DoseLow > 0");

            row.RawRow["Dose"   ] = 60.0;
            row.RawRow["DoseLow"] = 10;
            Assert.IsTrue(row.HasDoseRange, "Invalid HasDoseRange when Dose > 0 and DoseLow >60");
        }
    }
}
