//===========================================================================
//
//							RDRxLinkDispensing.cs
//
//  This class holds all business logic for handling repeat dispensing
//  link table.
//
//	Modification History:
//	09Jul09 AK  Written
//  01May11 TH  Added JVM Flag in linking record
//  16Apr12 AJK 31239 Added Updated, UpdatedBy and UpdatedByDescription fields
//===========================================================================
using System;
using System.Collections.Generic;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using System.Collections.Generic;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.icwdatalayer;


namespace ascribe.pharmacy.businesslayer
{
    /// <summary>
    /// Business object representing a line in the RepeatDispensingPrescriptionLinkDispensing table
    /// </summary>
    public class RDRxLinkDispensingLine : IBusinessObject
    {
        public int          RDRxLinkDispensingID    { get; internal set; }
        public int          PrescriptionID          { get; set; }
        public int          DispensingID            { get; set; }
        public bool         InUse                   { get; set; }
        public double       Quantity                { get; set; }
        public bool         JVM                     { get; set; }
        public DateTime?    Updated                 { get; internal set; } // 16Apr12 AJK 31239 Added
        public int?         UpdatedBy               { get; set; }          // 16Apr12 AJK 31239 Added
        public string       UpdatedByDescription    { get; internal set; } // 16Apr12 AJK 31239 Added
        public int?         RepeatTotal             { get; set; }   // 12Aug13 TH Added
        public int?         RepeatRemaining         { get; set; }   // 12Aug13 TH Added
        public DateTime?    PrescriptionExpiry      { get; set; } // 12Aug13 TH Added
    }

    /// <summary>
    /// Business processor for RepeatDispensingPrescriptionLinkDispensing business objects
    /// </summary>
    public class RdRxLinkDispensingProcessor : BusinessProcess
    {
        /// <summary>
        /// Updates the specified RepeatDispensingPrescriptionLinkDispensing business object in database via the data layer
        /// </summary>
        /// <param name="link">The RepeatDispensingPrescriptionLinkDispensing to be updated</param>
        public void Update(RDRxLinkDispensingLine link)
        {
            using (RDRxLinkDispensing dbLink = new RDRxLinkDispensing(RowLocking.Enabled))
            {
                dbLink.LoadByRepeatDispensingPrescriptionLinkDispensingID(link.RDRxLinkDispensingID);
                if (dbLink.Count == 0)
                {
                    //No record currently exists, add a new object in the data layer and populate the prescription ID from the Request table
                    dbLink.Add();
                    Request request = new Request();
                    request.LoadByRequestID(link.DispensingID);
                    dbLink[0].PrescriptionID = request[0].RequestID_Parent;
                }

                dbLink[0].DispensingID = link.DispensingID;
                dbLink[0].InUse = link.InUse;
                dbLink[0].Quantity = link.Quantity;
                dbLink[0].JVM = link.JVM;
                dbLink[0].Updated = DateTime.Now; // 16Apr12 AJK 31239 Added
                dbLink[0].UpdatedBy = SessionInfo.EntityID; // 16Apr12 AJK 31239 Added
                dbLink[0].RepeatTotal = link.RepeatTotal; // 12Aug13 TH Added
                dbLink[0].RepeatRemaining = link.RepeatRemaining; // 12Aug13 TH Added
                dbLink[0].PrescriptionExpiry = link.PrescriptionExpiry; // 12Aug13 TH Added
                dbLink.Save();
            }
        }

        /// <summary>
        /// Validates the RepeatDispensingPrescriptionLinkDispensing business object to ensure it can be saved
        /// </summary>
        /// <param name="link">RepeatDispensingPrescriptionLinkDispensing to be validated</param>
        /// <returns>Success</returns>
        public bool ValidateForUpdate(RDRxLinkDispensingLine link)
        {
            string keyName = "RDRxLinkDispensingID";
            string keyValue = link.RDRxLinkDispensingID.ToString();
            bool valid = true;

            if (link.DispensingID == 0)
            {
                ValidationErrors.Add(new ValidationError(this, "DispensingID", keyName, keyValue, ValidationError.PropertyNameTag + " is required", true));
                valid = false;
            }
            else
            {
                //if (link.Quantity > 9999 || link.Quantity < 0)
                //{
                //    ValidationErrors.Add(new ValidationError(this, "Quantity", keyName, keyValue, ValidationError.PropertyNameTag + " must be between 0 and 9999", true));
                //    valid = false;
                //}
                using (RepeatDispensingValidation validator = new RepeatDispensingValidation())
                {
                    //Pass into main repeat dispensing validation routine
                    //This needs to be on a switch ??
                    //if (validator.ValidateDispensingForLinking(link.DispensingID, link.Quantity, link.JVM, link.RepeatTotal,link.RepeatRemaining, link.PrescriptionExpiry,false) == false)
                    if (validator.ValidateDispensingForLinking(link.DispensingID, link.Quantity, link.JVM, link.RepeatTotal, link.RepeatRemaining, link.PrescriptionExpiry) == false) //09Sep13 TH Reverted
                    //if (validator.ValidateDispensingWithoutPatient(link.DispensingID, link.Quantity, link.JVM, link.RepeatTotal, link.RepeatRemaining, link.PrescriptionExpiry) == false)
                            valid = false;
                    foreach (ValidationError error in validator.ValidationErrors)
                    {
                        ValidationErrors.Add(error);
                    }
                }
            }
            return valid;
        }

        /// <summary>
        /// Loads by requestID of the dispensing
        /// </summary>
        /// <param name="dispensingID">RequestID for the dispensing</param>
        /// <returns>RepeatDispensingPrescriptionLinkDispensing business object loaded</returns>
        public RDRxLinkDispensingLine LoadByDispensingID(int dispensingID)
        {
            RDRxLinkDispensing dbLink = new RDRxLinkDispensing();
            dbLink.LoadByDispensingID(dispensingID);
            if (dbLink.Count == 0)
                return null;
            RDRxLinkDispensingLine link = new RDRxLinkDispensingLine();
            link.DispensingID = dbLink[0].DispensingID;
            link.InUse = dbLink[0].InUse;
            link.PrescriptionID = dbLink[0].PrescriptionID;
            link.Quantity = dbLink[0].Quantity;
            link.RDRxLinkDispensingID = dbLink[0].RDRxLinkDispensingID;
            link.JVM = dbLink[0].JVM;
            link.Updated = dbLink[0].Updated; // 16Apr12 AJK 31239 Added
            link.UpdatedBy = dbLink[0].UpdatedBy; // 16Apr12 AJK 31239 Added
            link.UpdatedByDescription = dbLink[0].UpdatedByDescription; // 16Apr12 AJK 31239 Added
            link.RepeatTotal = dbLink[0].RepeatTotal;
            link.RepeatRemaining = dbLink[0].RepeatRemaining;
            link.PrescriptionExpiry = dbLink[0].PrescriptionExpiry;
            return link;    
        }

        public RDRxLinkDispensingLine LoadByPrescriptionID(int prescriptionID)
        {
            RDRxLinkDispensing dbLink = new RDRxLinkDispensing();
            dbLink.LoadByPrescriptionID(prescriptionID);
            if (dbLink.Count == 0)
                return null;
            RDRxLinkDispensingLine link = new RDRxLinkDispensingLine();
            link.DispensingID = dbLink[0].DispensingID;
            link.InUse = dbLink[0].InUse;
            link.PrescriptionID = dbLink[0].PrescriptionID;
            link.Quantity = dbLink[0].Quantity;
            link.RDRxLinkDispensingID = dbLink[0].RDRxLinkDispensingID;
            link.JVM = dbLink[0].JVM;
            link.Updated = dbLink[0].Updated; // 16Apr12 AJK 31239 Added
            link.UpdatedBy = dbLink[0].UpdatedBy; // 16Apr12 AJK 31239 Added
            link.UpdatedByDescription = dbLink[0].UpdatedByDescription; // 16Apr12 AJK 31239 Added
            link.RepeatTotal = dbLink[0].RepeatTotal;
            link.RepeatRemaining = dbLink[0].RepeatRemaining;
            link.PrescriptionExpiry = dbLink[0].PrescriptionExpiry;
            return link;
        }

        /// <summary>
        /// Static method to delete a RepeatDispensingPrescriptionLinkDispensing record
        /// </summary>
        /// <param name="dispensingID">RequestID for the dispensing to be deleting</param>
        public static void Delete(int dispensingID)
        {
            using (RDRxLinkDispensing link = new RDRxLinkDispensing(RowLocking.Enabled))
            {
                link.LoadByDispensingID(dispensingID);
                link.RemoveAll();
                link.Save();
            }
        }

        /// <summary>
        /// Deletes all RepeatDispensingLinkDispensing items by prescription ID
        /// </summary>
        /// <param name="prescriptionID">prescription ID to be deleted</param>
        public static void DeleteByPrescriptionID(int prescriptionID)
        {
            using (RDRxLinkDispensing link = new RDRxLinkDispensing(RowLocking.Enabled))
            {
                link.LoadByPrescriptionID(prescriptionID);
                link.RemoveAll();
                link.Save();
            }
        }

        public static int PrescriptionIDByDispensingID(int dispensingID)
        {
            using (Request request = new Request())
            {
                request.LoadByRequestID(dispensingID);
                return request[0].RequestID_Parent;
            }
        }

        public static bool IsManualEntryQuantityType(int dispensingID)
        {
            using (WLabel dispensing = new WLabel())
            {
                dispensing.LoadByRequestID(dispensingID);
                using (WProduct drug = new WProduct())
                {
                    drug.LoadByProductAndSiteID(dispensing[0].SisCode, dispensing[0].SiteID);
                    string drugType = drug[0].PrintformV + drug[0].DPSForm;
                    using (WConfiguration config = new WConfiguration())
                    {
                        config.LoadBySiteCategorySectionAndKey(dispensing[0].SiteID, "D|PATMED", "", "QuantityManualEntryTypes");
                        if (config.Count == 1)
                        {
                            string quantityManualEntryTypes = config[0].Value;
                            string[] types = quantityManualEntryTypes.Split(',');
                            foreach (string type in types)
                            {
                                if (type == drugType)
                                    return true;
                            }
                            return false;
                        }
                        else
                        {
                            return false;
                        }
                    }
                }
            }
        }

        public static string IssueUnits(int dispensingID)
        {
            using (WLabel dispensing = new WLabel())
            {
                dispensing.LoadByRequestID(dispensingID);
                using (WProduct drug = new WProduct())
                {
                    drug.LoadByProductAndSiteID(dispensing[0].SisCode, dispensing[0].SiteID);
                    return drug[0].PrintformV;
                }
            }
        }
       
    }

}
