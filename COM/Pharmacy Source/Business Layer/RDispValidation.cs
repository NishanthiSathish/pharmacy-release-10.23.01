//===========================================================================
//
//							RDispValidation.cs
//
//  This is a validation class for validating various repeat dispensing
//  objects
//
//	Modification History:
//	20May09 AJK  Written
//  28May09 XN   Changed StockLvl, and ReOrderLevel, to StockLevelInIssueUnits, 
//               and ReOrderLevelInIssueUnits
//  29May09 XN   Made the inuse flag boolean
//  17May11 XN   Removed BagLabels, and added RepeatDispensingTemplateID F0057909 
//  20Mar12 AJK  Changed references to PharmacyPatientInfo from RDispPatientInfo
//  04Apr12 AJK  30998  Widespread changes to almost all functions to allow combined action batch validation
//  10Apr12 AJK  Added LocationID and LocationDescription to XML output
//  13Apr12 AJK  31212 ValidateDispensing: Check for supply requests, which always results in an exception
//  17Jul12 AJK  38690 ValidatePatient: Added EpisodeID of active (if not lifetime) episode
//  13Aug12 AJK  41186 ValidateDispensing: Added new parameter includeADM. Added logic to exclude ADM items.
//                     ValidatePatient: Refined param comments. Added ADM param setting to calls to ValidateDispensing. Fixed ADMflag bug where batch info wasn't being passed through correctly.
//  18Sep12 AJK  44221 GetPackerName: Changed from null to empty string
//  15Aug13 TH   70134 Mods to support Doc repeat cycles
//  18Aug13 TH   70134 Added new fields to output XML for ocx
//  22Aug13 TH   70134 Changes to Validation (allow skip of patient settings on main validation runs)
//  28Oct13 TH   Revert part of previous mod (13Aug12) as this broke none JVM Packers (TFS 76409)
//  01Nov13 XN   Knock on changes as removed Product class from buisness layer
//  17Feb14 TH   Allow new Robot switch setting to swap to none robot validation checks for some things (e.g. PRN flag) (TFS 84113)
//  06Jan15 XN   Ignore expired prescritpions when processing batch (105787)
//  25Feb15 TH   Reversed above - now done in DB as at this level it broke the expected xml for the ocx (TFS 111756)
//  18Jun15 XN   Prescription.LoadMergeItemsByRequestID has been removed so required update to ValidateDispensing  39882
//===========================================================================
namespace ascribe.pharmacy.businesslayer
{
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Xml;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

    /// <summary>
    /// Validation process class for validating various repeat dispensing objects
    /// </summary>
    public class RepeatDispensingValidation : BusinessProcess
    {
        private StringBuilder _validationErrorsXML = new StringBuilder();

        /// <summary>
        /// Hierarchical XML document in string form to represent the errors
        /// returned by the validation. Read only.
        /// </summary>
        public string ValidationErrorsXML
        { get { return _validationErrorsXML.ToString(); } }

        /// <summary>
        /// Clears the validation error list and XML
        /// </summary>
        public void Clear()
        {
            ValidationErrors.Clear();
            _validationErrorsXML.Length = 0;
            hasExceptions = false;
            packerSection = null;
        }

        private bool hasExceptions = false;  

        private int? packerSection;
        private string packerLocationCode;
        private string ignore;
        private string information;
        private string robotIgnore;
        private string robotSwitch;
        private string robotInformation;
        private bool combined;
        private string ignore2;
        private string information2;
        private string robotIgnore2;
        private string robotInformation2;
        private string manualEntryQuantityTypes;
        private string lastLabelType;
        private string[] timeBandsStart = new string[4];
        private bool includeManual = true;

        /// <summary>
        /// Validates a repeat dispensing for linking purposes. This will validate patient details also.
        /// </summary>
        /// <param name="requestID">RequestID for the dispensing to be validated</param>
        /// <param name="quantity">Quantity for repeat dispensing</param>
        /// <param name="useADM">Indicates whether to use a robot for this dispensing</param>
       
        /// <returns>Success</returns>
        public bool ValidateDispensingForLinking(int requestID, double quantity, bool useADM, int? RepeatTotal, int? RepeatRemaining, DateTime? PrescriptionExpiry)
        {
            

            bool returnVal = true;
            WLabel dispensing = new WLabel();
            dispensing.LoadUncancelledByRequestID(requestID);
            if (dispensing.Count == 0)
            {
                ValidationErrors.Add(new ValidationError(this, "RequestID", "", "", string.Format("Dispensing for uncancelled prescription not found (RequestID={0})", requestID), true, 170));
                returnVal = false;
            }
            else if (dispensing.Count > 1)
            {
                ValidationErrors.Add(new ValidationError(this, "RequestID", "", "", string.Format("More than one dispensing found (RequestID={0})", requestID), true, 171));
                returnVal = false;
            }
            else
            {
                int siteID = dispensing[0].SiteID;
                // Create XML writer and set options
                XmlWriterSettings xmlSettings = new XmlWriterSettings();
                xmlSettings.OmitXmlDeclaration = true;
                xmlSettings.NewLineHandling = NewLineHandling.Entitize;
                xmlSettings.Indent = true;
                XmlWriter xmlWriter = XmlWriter.Create(_validationErrorsXML, xmlSettings);
                xmlWriter.WriteStartElement("xmlData");
                
                // Validation configuration for robot settings
                ValidateConfig(xmlWriter, siteID, "Linking");
                using (PharmacyPatientInfo patient = new PharmacyPatientInfo())
                {
                    patient.LoadByRequestID(requestID);
                    //if (patient.Count == 0 && !skipPatient)
                    if (patient.Count == 0 )
                    {
                        ValidationErrors.Add(new ValidationError(this, "RequestID", "", "", string.Format("Patient not found (RequestID={0})", requestID), true, 170));
                        returnVal = false;
                   
                    }
                    else if (patient.Count > 1)
                    {
                        ValidationErrors.Add(new ValidationError(this, "RequestID", "", "", string.Format("More than one patient found (RequestID={0})", requestID), true, 171));
                        returnVal = false;
                    }
                    else
                    {
                        // Validate the patient for an unlinked dispensing
                        //ValidatePatient(patient[0].EntityID, siteID, xmlWriter, requestID, 1, quantity, useADM, RepeatTotal, RepeatRemaining, PrescriptionExpiry);  //09Sep13 TH Removed skipPatient param
                        //ValidatePatient(patient[0].EntityID, siteID, xmlWriter, requestID, 1, quantity, useADM, RepeatTotal, RepeatRemaining, PrescriptionExpiry, false);  //6Jan14 XN Added filtering out of expired prescriptions  //09Sep13 TH Removed skipPatient param
                        ValidatePatient(patient[0].EntityID, siteID, xmlWriter, requestID, 1, quantity, useADM, RepeatTotal, RepeatRemaining, PrescriptionExpiry); //25Feb15 TH removed para
                        returnVal = !hasExceptions;
                    }
                }
                xmlWriter.WriteEndElement();
                xmlWriter.Close();
            }
            return returnVal;
        }
              
        
        /// <summary>
        /// Validates the requested dispensing for repeat dispensing
        /// </summary>
        /// <param name="RequestID">RequestID for the requested dispensing</param>
        /// <param name="siteID">SiteID for the requested dispensing</param>
        /// <param name="xmlWriter">XmlWriter for writing to the ValidationErrorsXML property</param>
        /// <param name="ADM">Indicates if the site has a robot and the patient and dispensing is marked for ADM dispensing</param>
        /// <param name="entityID">EntityID of the patient, used for error message output</param>
        /// <param name="totalSupplyDays">The total days supply for the dispensing (taken from patient settings supply length multiplied by the batch factor)</param>
        /// <param name="linked">Indicates if the dispensing is linked for repeat dispensing already</param>
        /// <param name="rdQuantity">Value of the quantity entered for repeat dispensing link</param>
        /// <param name="includeADM">Indicates if items that can be dispensed via a robot should be included in the manually dispensed batch</param>
        /// <param name="RepeatTotal">Indicates Total number of repeat cycles allowed</param>
        /// <param name="RepeatRemaining">Indicates number of repeats remaining</param>
        /// <param name="PrescriptionExpiry">Indicates Expiry date of prescription for repeat dispensing</param>
        /// <param name="SkipPatient">Dotn Validate anythin to do with Patient Settings</param>
        //private void ValidateDispensing(int RequestID, int siteID, XmlWriter xmlWriter, bool ADM, int entityID, int totalSupplyDays, bool linked, double? rdQuantity, bool? inUse, bool includeADM, int? RepeatTotal, int? RepeatRemaining, DateTime? PrescriptionExpiry, bool skipPatient, bool ignoreExpiredItems)
        private void ValidateDispensing(int RequestID, int siteID, XmlWriter xmlWriter, bool ADM, int entityID, int totalSupplyDays, bool linked, double? rdQuantity, bool? inUse, bool includeADM, int? RepeatTotal, int? RepeatRemaining, DateTime? PrescriptionExpiry, bool skipPatient) //25Feb15 TH Removed param (TFS 111756)
        {
            //Check to see if we don't want robot items, we don't want a dispensing row
            bool skipItem = false;
            // 13Aug12 AJK 41186 Added several changes to handle ADM exclusion
            if (!includeManual || !includeADM ) // If we should be excluding manual or ADM items
            {
                WLabel tempDispensing = new WLabel();
                tempDispensing.LoadUncancelledByRequestID(RequestID);
                if (tempDispensing.Count == 1)
                {
                    string tempNsvCode = tempDispensing[0].SisCode;
                    WProduct tempDrug = new WProduct();
                    tempDrug.LoadByProductAndSiteID(tempNsvCode, siteID);
                    if (tempDrug.Count == 1)
                    {
                        if (!includeManual && (!ADM || packerLocationCode.ToUpper() != tempDrug[0].Location.ToUpper()))
                        {
                            //Item is not ADM (set by site, patient and dispensing) or the drug is not in the packer AND excluding manual items has been requested
                            skipItem = true;
                        }
                        if (!includeADM && ADM && packerLocationCode.ToUpper() == tempDrug[0].Location.ToUpper())
                        {
                            //Item is ADM (set by site, patient and dispensing), the drug is in the packer and excluding ADM items has been requeted
                            skipItem = true;
                        }
                    }
                }
            }

            if (!includeADM) ADM = false; //Override setting the ADM flag to false here as we never want any ADM items if we've requested exclusion
                    
            if (!skipItem)
            {
                xmlWriter.WriteStartElement("Dispensing");
                xmlWriter.WriteAttributeString("RequestID", RequestID.ToString());
                xmlWriter.WriteAttributeString("SiteID", siteID.ToString());
                WLabel dispensing = new WLabel();
                if (linked)
                {
                    dispensing.LoadRepeatDispensingByDispensingID(RequestID);
                }
                else
                {
                    dispensing.LoadUncancelledByRequestID(RequestID);
                }
                if (dispensing.Count == 0)
                {
                    if (!IgnoreRule("170", false))
                        AddValidationError(xmlWriter, "RequestID and SiteID", "Dispensing not found", RuleIsException("170", false), RepeatDispensingPatientProcessor.PatientDetailsString(entityID) + " (" + string.Format("SiteID={0}, RequestID={1}", siteID, RequestID) + ")", 170);
                }
                else if (dispensing.Count > 1)
                {
                    if (!IgnoreRule("171", false))
                        AddValidationError(xmlWriter, "RequestID and SiteID", "More than one dispensing found", RuleIsException("171", false), RepeatDispensingPatientProcessor.PatientDetailsString(entityID) + string.Format("SiteID={0}, RequestID={1}", siteID, RequestID) + ")", 171);
                }
                else
                {
                    int prescriptionID;
                    double repeatDispensingQuantity;
                    int repeattotal;
                    int repeatremaining;
                    DateTime? prescriptionexpiry;
                    if (linked)
                    {
                        prescriptionID = dispensing[0].RequestID_Prescription;
                        repeatDispensingQuantity = dispensing[0].RepeatDispensingQuantity.Value;
                        repeattotal = dispensing[0].RepeatTotal.Value;
                        repeatremaining = dispensing[0].RepeatRemaining.Value;
                        //prescriptionexpiry = dispensing[0].PrescriptionExpiry.Value;
                        prescriptionexpiry = dispensing[0].PrescriptionExpiry.HasValue ? dispensing[0].PrescriptionExpiry.Value : (DateTime?)null;

                    }
                    else
                    {
                        // Dispensing is not currently linked so obtain prescription ID from request table
                        Request request = new Request();
                        request.LoadByRequestID(RequestID);
                        prescriptionID = request[0].RequestID_Parent;
                        repeatDispensingQuantity = rdQuantity.HasValue ? rdQuantity.Value : 0;
                        repeattotal = RepeatTotal.HasValue ? RepeatTotal.Value : 0;
                        repeatremaining = RepeatRemaining.HasValue ? RepeatRemaining.Value : 0;
                        prescriptionexpiry = PrescriptionExpiry.HasValue ? PrescriptionExpiry.Value : DateTime.Now.AddDays(7);
                    }
                    xmlWriter.WriteAttributeString("PrescriptionID", prescriptionID.ToString());
                    xmlWriter.WriteAttributeString("RepeatDispensingQuantity", repeatDispensingQuantity.ToString());
                    xmlWriter.WriteAttributeString("RepeatTotal", repeattotal.ToString());
                    xmlWriter.WriteAttributeString("RepeatRemaining", repeatremaining.ToString());
                    xmlWriter.WriteAttributeString("PrescriptionExpiry", prescriptionexpiry.ToPharmacyDateString());
                           
                    if (inUse.HasValue) xmlWriter.WriteAttributeString("InUse", inUse.ToString());
                    Prescription prescription = new Prescription();
                    prescription.LoadByRequestID(prescriptionID);
                    if (prescription.Count == 0)
                    {
                        if (!IgnoreRule("190", false))
                            AddValidationError(xmlWriter, "PrescriptionID", "No valid prescription found", RuleIsException("190", false), RepeatDispensingPatientProcessor.PatientDetailsString(entityID) + string.Format("PrescriptionID={0}", prescriptionID) + ")", 190);
                    }
                    else if (prescription.Count > 1)
                    {
                        if (!IgnoreRule("191", false))
                            AddValidationError(xmlWriter, "PrescriptionID", "More than one prescription found", RuleIsException("191", false), RepeatDispensingPatientProcessor.PatientDetailsString(entityID) + string.Format("PrescriptionID={0}", prescriptionID) + ")", 191);
                    }
                    else
                    {
                        // 13Apr12 AJK 31212 Check for supply requests, which always results in an exception
                        if (AttachedNote.GetAttachedNoteCountByType(prescriptionID, WConfigurationController.LoadASetting(siteID, "D|RptDisp", "MedsManagement", "NoteType", "eMMSupply", false, typeof(string)).ToString()) > 0)
                        {
                            AddValidationError(xmlWriter, "Prescription", "Prescription already has a supply request", true, RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID));
                        }
                        else
                        {
                            // Check if the Rx is merged and has children with supply requests
                            var merged = Database.ExecuteSQLSingleField<int>("SELECT RequestID_Prescription FROM [WPrescriptionMergeItem] WHERE [RequestID_WPrescriptionMerge]={0}", prescriptionID);
                            foreach (int mergedItemRequestId in merged)
                            {
                                if (AttachedNote.GetAttachedNoteCountByType(mergedItemRequestId, WConfigurationController.LoadASetting(siteID, "D|RptDisp", "MedsManagement", "NoteType", "eMMSupply", false, typeof(string)).ToString()) > 0)
                                {
                                    AddValidationError(xmlWriter, "Prescription", "Prescription already has a supply request", true, RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, mergedItemRequestId));
                                }
                            }
                        }
                        
                        if (ascribe.pharmacy.asymmetricdosing.WPrescriptionMergeItem.IsMergedPrescription(prescriptionID))
                        {
                            AddValidationError(xmlWriter, "PrescriptionID", "Repeat dispensing of linked prescriptions not permitted", true, RepeatDispensingPatientProcessor.PatientDetailsString(entityID) + string.Format("PrescriptionID={0}", prescriptionID) + ")", 193);
                        }
                        if (!IgnoreRule("192", false) && prescription[0].StopDate < DateTime.Today.AddDays(totalSupplyDays))
                        {
                            //if (ignoreExpiredItems)  //25Feb15 TH Removed (TFS 111756)
                            //    skipItem = true;  //6Jan14 XN Added filtering out of expired prescriptions 105787
                            //else
                                AddValidationError(xmlWriter, "StopDate", "Prescription stop date is before the end of the supply period", RuleIsException("192", false), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID), 192);
                        }
                        if (dispensing[0].SisCode == null || dispensing[0].SisCode == "")
                        {
                            if (!IgnoreRule("100", false))
                                AddValidationError(xmlWriter, "SisCode", "Free formal label", RuleIsException("100", false), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 100);
                        }
                        
                        else //if (!skipItem)     // else 6Jan14 XN Added filtering out of expired prescriptions 105787 //25Feb15 TH Removed skipitem condition (TFS 111756)
                        {
                            bool quantityRequired = false;
                            string quantityRequiredReason = "";
                            if (!IgnoreRule("103", false))
                            {
                                if (dispensing[0].IssType == "P")
                                    AddValidationError(xmlWriter, "IssType", "PN issue type not permitted", RuleIsException("103", false), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 103);
                                if (dispensing[0].IssType == "C")
                                    AddValidationError(xmlWriter, "IssType", "Civas issue type not permitted", RuleIsException("103", false), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 103);
                            }
                            if (!IgnoreRule("101", false))
                            {
                                using (WConfiguration config = new WConfiguration())
                                {
                                    config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "LabelTypes");
                                    if (config.Count == 0 || !config[0].Value.Contains(dispensing[0].IssType))
                                    {
                                        AddValidationError(xmlWriter, "IssType", "Issue type not configured for repeat dispensing", RuleIsException("101", false), string.Format("IssueType = {0}, SiteNumber = {1}, {2}", dispensing[0].IssType, SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 101);
                                    }
                                }
                            }
                            //20Mar13 TH Added PSO Validation check (TFS 58703)
                            if (!IgnoreRule("105", false))
                            {
                                if (dispensing[0].PSO == true)
                                    AddValidationError(xmlWriter, "PSO", "PSO issue not permitted", RuleIsException("105", false), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 105);
                            }

                            //12Aug13 TH Added DoC Validate
                            //Is the Prescription Out of date
                            if (!IgnoreRule("106", false))
                            {
                                //if (dispensing[0].PrescriptionExpiry >= dispensing[0].RepeatRemaining) //.AddDays(1)
                                if ((DateTime.Now > prescriptionexpiry) )
                                    AddValidationError(xmlWriter, "Repeats", "Prescription has expired", RuleIsException("106", false), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 106);
                            }

                            //12Aug13 TH Added DoC Validate
                            //Are there any repeats left
                            if (!IgnoreRule("107", false))
                            {
                                if ((repeattotal > 0) & (repeatremaining == 0))
                                    AddValidationError(xmlWriter, "Repeats", "There are no repeats left", RuleIsException("107", false), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 107);
                            }

                            //15Aug13 TH Added DoC Validate
                            //Are there too many repeats left
                            if (!IgnoreRule("108", false))
                            {
                                if (repeatremaining > repeattotal)
                                    AddValidationError(xmlWriter, "Repeats", "There are too many repeats remaining", RuleIsException("108", false), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 108);
                            }

                            

                            //End of non robot checks, do drug now
                            string nsvCode = dispensing[0].SisCode;
                            bool robotDrug = false;
                            // tempIgnore and tempInformation are to be set to non robot checks, which can be overwritten later if a robot check is required
                            //string tempIgnore = ignore;
                            //string tempInformation = information;
                            xmlWriter.WriteStartElement("Drug");
                            xmlWriter.WriteAttributeString("NSVCode", nsvCode);
                            xmlWriter.WriteAttributeString("SiteID", siteID.ToString());
                            WProduct drug = new WProduct();
                            drug.LoadByProductAndSiteID(nsvCode, siteID);

                            if (drug.Count == 0)
                            {
                                if (!IgnoreRule("102", false))
                                    AddValidationError(xmlWriter, "NSVCode and SiteID", "Drug not found", RuleIsException("102", false), string.Format("SiteID={0}, NSVCode={1}", siteID, nsvCode), 102);
                            }
                            else if (drug.Count > 1)
                            {
                                if (!IgnoreRule("116", false))
                                    AddValidationError(xmlWriter, "NSVCode and SiteID", "More than one drug found", RuleIsException("116", false), string.Format("SiteID={0}, NSVCode={1}", siteID, nsvCode), 116);
                            }
                            else
                            {
                                if (!IgnoreRule("111", false) && !drug[0].InUse)
                                    AddValidationError(xmlWriter, "InUse", "Drug out of use", RuleIsException("111", false), string.Format("SiteNumber = {0}, Product = {1}, NSVCode = {2}", SiteProcessor.GetNumberBySiteID(siteID), WProduct.ProductDetails(nsvCode, siteID), nsvCode), 111);
                                if (!IgnoreRule("112", false) && drug[0].IsStoresOnly)
                                    AddValidationError(xmlWriter, "InUse", "Drug is stores only", RuleIsException("112", false), string.Format("SiteNumber = {0}, Product = {1}, NSVCode = {2}", SiteProcessor.GetNumberBySiteID(siteID), WProduct.ProductDetails(nsvCode, siteID), nsvCode), 112);
                                if (ADM)
                                {
                                    // Site has a robot packer, patient is set to be dispensed by ADM
                                    if (packerLocationCode.ToUpper() != drug[0].Location.ToUpper())
                                    {
                                        if (!IgnoreRule("110", false))
                                            AddValidationError(xmlWriter, "LocationCode", "Not a robot item", RuleIsException("110", false), string.Format("SiteNumber = {0}, Product = {1}, NSVCode = {2}", SiteProcessor.GetNumberBySiteID(siteID), WProduct.ProductDetails(nsvCode, siteID), nsvCode), 110);
                                    }
                                    else
                                    {
                                        // Drug is for robot dispensing as is site and patient, so all remaining drug and dispensing checks are now robot specific
                                        robotDrug = true;
                                        //tempIgnore = robotIgnore;
                                        //tempInformation = robotInformation;
                                    }
                                }

                                //17Feb14 TH Here we check if this is valid for a robot run, if not it may be valid for none -robot run, so we switch
                                //Prior to none robot validation checks (TFS 84113)
                                //Switch from robot to none robot if not robotable - we dont warn here, just switch ?

                                if (robotDrug == true)
                                {
                                    if (dispensing[0].ManualQuantity == true)
                                    {
                                        if (SwitchRobot("120"))
                                        {
                                            robotDrug = false;
                                        }
                                    }
                                    if (dispensing[0].PRN == true)
                                    {
                                        if (SwitchRobot("121"))
                                        {
                                            robotDrug = false;
                                        }
                                    }
                                    if (SwitchRobot("122") && dispensing[0].PatientsOwn == true)
                                    {
                                        robotDrug = false;
                                    }
                                    if (dispensing[0].RepeatUnits != "day")
                                    {
                                        if (SwitchRobot("130"))
                                        {
                                            robotDrug = false;
                                        }
                                    }
                                    if (dispensing[0].Day1Mon != true || dispensing[0].Day2Tue != true || dispensing[0].Day3Wed != true || dispensing[0].Day4Thu != true || dispensing[0].Day5Fri != true || dispensing[0].Day6Sat != true || dispensing[0].Day7Sun != true)
                                    {
                                        if (SwitchRobot("131"))
                                        {
                                            robotDrug = false;
                                        }
                                    }
                                    if (dispensing[0].Dose1 > 0)
                                    {
                                        if (SwitchRobot("133") &&
                                            ((dispensing[0].Dose2 > 0 && dispensing[0].Dose2 != dispensing[0].Dose1) ||
                                            (dispensing[0].Dose3 > 0 && dispensing[0].Dose3 != dispensing[0].Dose1) ||
                                            (dispensing[0].Dose4 > 0 && dispensing[0].Dose4 != dispensing[0].Dose1) ||
                                            (dispensing[0].Dose5 > 0 && dispensing[0].Dose5 != dispensing[0].Dose1) ||
                                            (dispensing[0].Dose6 > 0 && dispensing[0].Dose6 != dispensing[0].Dose1)))
                                        {
                                            robotDrug = false;
                                        }
                                        if (SwitchRobot("134"))
                                        {
                                            int doseCount = 1;
                                            if (dispensing[0].Dose2 > 0) doseCount++;
                                            if (dispensing[0].Dose3 > 0) doseCount++;
                                            if (dispensing[0].Dose4 > 0) doseCount++;
                                            if (dispensing[0].Dose5 > 0) doseCount++;
                                            if (dispensing[0].Dose6 > 0) doseCount++;
                                            if (doseCount > 4)
                                            {
                                            robotDrug = false;
                                            }
                                        }
                                        bool hasFractions = false;
                                        if (CheckFractionalDose(dispensing[0].Dose1, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 1) == true) hasFractions = true;
                                        if (CheckFractionalDose(dispensing[0].Dose2, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 2) == true) hasFractions = true;
                                        if (CheckFractionalDose(dispensing[0].Dose3, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 3) == true) hasFractions = true;
                                        if (CheckFractionalDose(dispensing[0].Dose4, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 4) == true) hasFractions = true;
                                        if (CheckFractionalDose(dispensing[0].Dose5, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 5) == true) hasFractions = true;
                                        if (CheckFractionalDose(dispensing[0].Dose6, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 6) == true) hasFractions = true;
                                        if (SwitchRobot("144") && hasFractions == true && dispensing[0].Dose1 > 1)
                                        {
                                            robotDrug = false;
                                        }
                                    }
                                }

                                // Start drug checks which may be robot specific
                                if (dispensing[0].Dose1 <= 0)
                                {
                                    if (!IgnoreRule("132",robotDrug))
                                    {
                                        AddValidationError(xmlWriter, "Dose", "Dose is zero", RuleIsException("132",robotDrug), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 132);
                                    }
                                    quantityRequired = true;
                                    quantityRequiredReason = "Dose is zero (" + (!robotDrug ? "non-" : "") + "robot item)";
                                }
                                if (!IgnoreRule("113",robotDrug) && drug[0].StockLevelInIssueUnits == 0m)
                                    AddValidationError(xmlWriter, "StockLvl", "Drug has zero stock level", RuleIsException("113",robotDrug), string.Format("SiteNumber = {0}, Product = {1}, NSVCode = {2}", SiteProcessor.GetNumberBySiteID(siteID), WProduct.ProductDetails(nsvCode, siteID), nsvCode), 113);
                                if (!IgnoreRule("114",robotDrug) && drug[0].StockLevelInIssueUnits < 0m)
                                    AddValidationError(xmlWriter, "StockLvl", "Drug has negative stock level", RuleIsException("114", robotDrug), string.Format("SiteNumber = {0}, Product = {1}, NSVCode = {2}", SiteProcessor.GetNumberBySiteID(siteID), WProduct.ProductDetails(nsvCode, siteID), nsvCode), 114);
                                if (!IgnoreRule("115", robotDrug) && drug[0].StockLevelInIssueUnits < drug[0].ReorderLevelInIssueUnits)
                                    AddValidationError(xmlWriter, "StockLvl", "Drug has low stock", RuleIsException("115", robotDrug), string.Format("SiteNumber = {0}, Product = {1}, StockLvl = {2}, NSVCode = {3}", SiteProcessor.GetNumberBySiteID(siteID), WProduct.ProductDetails(nsvCode, siteID), drug[0].StockLevelInIssueUnits, nsvCode), 115);

                                // Is manual entry quantity type check
                                string drugType = drug[0].PrintformV + drug[0].DPSForm;
                                string[] types = manualEntryQuantityTypes.Split(',');
                                foreach (string type in types)
                                {
                                    if (type == drugType)
                                    {
                                        quantityRequired = true;
                                        quantityRequiredReason = "Drug ExpandedIssueUnit is manual entry quantity type (" + (!robotDrug ? "non-" : "") + "robot item)";
                                        if (!IgnoreRule("117",robotDrug))
                                        {
                                            AddValidationError(xmlWriter, "ExpandedIssueUnit", "Drug ExpandedIssueUnit is manual entry quantity type", RuleIsException("117",robotDrug), string.Format("SiteNumber = {0}, Product = {1}), NSVCode = {2}", SiteProcessor.GetNumberBySiteID(siteID), WProduct.ProductDetails(nsvCode, siteID), nsvCode), 117);
                                        }
                                    }
                                }
                            }
                            xmlWriter.WriteEndElement();
                            xmlWriter.WriteStartElement("RobotItem");
                            xmlWriter.WriteAttributeString("Value", robotDrug ? "1" : "0");
                            xmlWriter.WriteEndElement();
                            //End drug checks

                            // Begin dispensing checks which may be robot specific
                            if (dispensing[0].ManualQuantity == true)
                            {
                                if (!IgnoreRule("120",robotDrug))
                                {
                                    AddValidationError(xmlWriter, "ManualQuantity", "Label has manual issue quantity", RuleIsException("120",robotDrug), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 120);
                                }
                                quantityRequired = true;
                                quantityRequiredReason = "Label has manual issue quantity (" + (!robotDrug ? "non-" : "") + "robot item)";
                            }
                            if (dispensing[0].PRN == true)
                            {
                                if (!IgnoreRule("121",robotDrug))
                                {
                                    AddValidationError(xmlWriter, "PRN", "Label has PRN flag set", RuleIsException("121",robotDrug), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 121);
                                }
                                quantityRequired = true;
                                quantityRequiredReason = "Label has PRN flag set (" + (!robotDrug ? "non-" : "") + "robot item)";
                            }
                            if (!IgnoreRule("122", robotDrug) && dispensing[0].PatientsOwn == true)
                            {
                                AddValidationError(xmlWriter, "PatientsOwn", "Label is patients own stock", RuleIsException("122", robotDrug), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 122);
                            }
                            if (dispensing[0].RepeatUnits != "day")
                            {
                                if (!IgnoreRule("130", robotDrug))
                                {
                                    AddValidationError(xmlWriter, "RepeatUnits", "Non daily dose", RuleIsException("130", robotDrug), string.Format("SiteNumber = {0},  {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 130);
                                }
                                quantityRequired = true;
                                quantityRequiredReason = "Non daily dose - repeat units (" + (!robotDrug ? "non-" : "") + "robot item)";
                            }
                            if (dispensing[0].Day1Mon != true || dispensing[0].Day2Tue != true || dispensing[0].Day3Wed != true || dispensing[0].Day4Thu != true || dispensing[0].Day5Fri != true || dispensing[0].Day6Sat != true || dispensing[0].Day7Sun != true)
                            {
                                if (!IgnoreRule("131", robotDrug))
                                {
                                    AddValidationError(xmlWriter, "Days", "Non daily dose", RuleIsException("131", robotDrug), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 131);
                                }
                                quantityRequired = true;
                                quantityRequiredReason = "Non daily dose - day flags (" + (!robotDrug ? "non-" : "") + "robot item)";
                            }
                            if (!IgnoreRule("104", robotDrug) && quantityRequired && repeatDispensingQuantity <= 0)
                                AddValidationError(xmlWriter, "RepeatDispensingQuantity", "Repeat dispensing quantity not set" + (string.IsNullOrEmpty(quantityRequiredReason) ? "" : ": " + quantityRequiredReason), RuleIsException("104", robotDrug), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 104);
                            if (dispensing[0].Dose1 > 0)
                            {
                                if (!IgnoreRule("133", robotDrug) &&
                                    ((dispensing[0].Dose2 > 0 && dispensing[0].Dose2 != dispensing[0].Dose1) ||
                                    (dispensing[0].Dose3 > 0 && dispensing[0].Dose3 != dispensing[0].Dose1) ||
                                    (dispensing[0].Dose4 > 0 && dispensing[0].Dose4 != dispensing[0].Dose1) ||
                                    (dispensing[0].Dose5 > 0 && dispensing[0].Dose5 != dispensing[0].Dose1) ||
                                    (dispensing[0].Dose6 > 0 && dispensing[0].Dose6 != dispensing[0].Dose1)))
                                    AddValidationError(xmlWriter, "Dose", "Unequal dosing", RuleIsException("133", robotDrug), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 133);

                                if (!IgnoreRule("134",robotDrug))
                                {
                                    int doseCount = 1;
                                    if (dispensing[0].Dose2 > 0) doseCount++;
                                    if (dispensing[0].Dose3 > 0) doseCount++;
                                    if (dispensing[0].Dose4 > 0) doseCount++;
                                    if (dispensing[0].Dose5 > 0) doseCount++;
                                    if (dispensing[0].Dose6 > 0) doseCount++;
                                    if (doseCount > 4)
                                        AddValidationError(xmlWriter, "Dose", "Too many doses", RuleIsException("134",robotDrug), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 134);
                                }

                                bool hasFractions = false;
                                if (CheckFractionalDose(dispensing[0].Dose1, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 1) == true) hasFractions = true;
                                if (CheckFractionalDose(dispensing[0].Dose2, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 2) == true) hasFractions = true;
                                if (CheckFractionalDose(dispensing[0].Dose3, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 3) == true) hasFractions = true;
                                if (CheckFractionalDose(dispensing[0].Dose4, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 4) == true) hasFractions = true;
                                if (CheckFractionalDose(dispensing[0].Dose5, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 5) == true) hasFractions = true;
                                if (CheckFractionalDose(dispensing[0].Dose6, RequestID, siteID, xmlWriter, robotDrug, entityID, prescriptionID, 6) == true) hasFractions = true;
                                if (!IgnoreRule("144",robotDrug) && hasFractions == true && dispensing[0].Dose1 > 1)
                                    AddValidationError(xmlWriter, "Dose", "Combination of whole and part tablets", RuleIsException("144",robotDrug), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 144);


                                if (robotDrug && !IgnoreRule("135", robotDrug))
                                {
                                    // Only to be checked for robot items, never for non robot
                                    string[] scriptTimes = new string[6];
                                    scriptTimes[0] = dispensing[0].Times1;
                                    scriptTimes[1] = dispensing[0].Times2;
                                    scriptTimes[2] = dispensing[0].Times3;
                                    scriptTimes[3] = dispensing[0].Times4;
                                    scriptTimes[4] = dispensing[0].Times5;
                                    scriptTimes[5] = dispensing[0].Times6;
                                    if (!MapTimesToTimeSlots(scriptTimes, timeBandsStart))
                                    {
                                        AddValidationError(xmlWriter, "Times", "Mapping times to slots failed", RuleIsException("135",robotDrug), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 135);
                                    }
                                }
                            }
                        }
                    }
                }
                xmlWriter.WriteEndElement();
            }
        }

        /// <summary>
        /// Checks if the dose has a fractional part
        /// </summary>
        /// <param name="dose">The dose to be checked</param>
        /// <param name="RequestID">The RequestID of the dispensing</param>
        /// <param name="siteID">The SiteID of the dispensing</param>
        /// <param name="xmlWriter">XmlWriter for writing to the ValidationErrorsXML property</param>
        /// <param name="robotItem">Indicates if it is a robot item</param>
        /// <param name="entityID">The entity ID of the patient to be used for error message display</param>
        /// <param name="prescriptionID">The requestID of the prescription to be used for error message display</param>
        /// <returns>Indicates if the dose contains a fractional element</returns>
        private bool CheckFractionalDose(double dose, int RequestID, int siteID, XmlWriter xmlWriter, bool robotItem, int entityID, int prescriptionID, int slot)
        {
            bool hasFraction = false;
            double fraction = dose - Math.Floor(dose); // Remove who parts from dose
            if (fraction >= 0 && fraction <= 0.0000003) // Whole
                {}//Whole
            else if(fraction >= 0.2499997 && fraction <= 0.2500003) // Quarter
            {
                if (!IgnoreRule("141", robotItem))
                    AddValidationError(xmlWriter, "Dose", "Quarter dose", RuleIsException("141", robotItem), string.Format("Slot = {0}, SiteNumber = {1}, {2}", slot.ToString(), SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 141);
                hasFraction = true;
            }
            else if (fraction >= 0.4999997 && fraction <= 0.5000003) // Half
            {
                if (!IgnoreRule("142", robotItem))
                    AddValidationError(xmlWriter, "Dose", "Half dose", RuleIsException("142", robotItem), string.Format("Slot = {0}, SiteNumber = {1}, {2}", slot.ToString(), SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 142);
                hasFraction = true;
            }
            else if (fraction >= 0.7499997 && fraction <= 0.7500003) // Three quarter
            {
                if (!IgnoreRule("143", robotItem))
                    AddValidationError(xmlWriter, "Dose", "Three quarter dose", RuleIsException("143", robotItem), string.Format("Slot = {0}, SiteNumber = {1}, {2}", slot.ToString(), SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 143);
                hasFraction = true;
            }
            else if (fraction >= 0.9999997 && fraction <= 1) // Whole
            { } //Whole
            else // Other fraction
            {
                if (!IgnoreRule("140", robotItem))
                    AddValidationError(xmlWriter, "Dose", "Fractional dose", RuleIsException("140", robotItem), string.Format("Slot = {0}, SiteNumber = {1}, {2}", slot.ToString(), SiteProcessor.GetNumberBySiteID(siteID), RepeatDispensingPatientProcessor.PatientAndPrescriptionDetails(entityID, prescriptionID)), 140);
                hasFraction = true;
            }
            return hasFraction;
        }

        /// <summary>
        /// Maps the dipensing times to the slot times and validates
        /// </summary>
        /// <param name="scriptTimes">The dose times from the dispensing</param>
        /// <param name="timeBandStart">The time bands from config</param>
        /// <returns>Success</returns>
        private bool MapTimesToTimeSlots(string[] scriptTimes, string[] timeBandStart)
        {
            int[] slotMap = new int[6];
            string[] times = new string[6];
            //timeBandStart = new string[4];
            int[] bandStart = new int[4];
            int timesUsed = 0;
            int loop;
            string temp;
            int[] bands = new int[4];
            int band;

            // Do 6 times (maximum doses)
            for (loop = 0; loop <= 5; loop++)
            {
                slotMap[loop] = 0;
                temp = scriptTimes[loop].Trim();
                if (temp != "")
                {
                    // Slot used
                    timesUsed++;
                    Regex rx = new Regex(@"^([0-1]\d|2[0-3]):?[0-5]\d$");
                    MatchCollection matches = rx.Matches(temp);
                    if (matches.Count > 0)
                    {
                        // Time is valid, remove :
                        temp.Replace(":", "");
                        times[timesUsed - 1] = temp;
                    }
                    else
                    {
                        // Invalid time format detected
                        return false;
                    }
                }
            }
            switch (timesUsed)
            {
                case 1:
                case 2:
                case 3:
                case 4:
                    // 1-4 slots used
                    for (band = 0; band <= 3; band++)
                    {
                        bandStart[band] = int.Parse(timeBandStart[band]);
                        if (band > 1 && bandStart[band] <= bandStart[band - 1])
                            // Time slots from config are not in ascending order
                            return false;
                    }
                    for (loop = 1; loop <= timesUsed; loop++)
                    {
                        // For each used time slot
                        int time = int.Parse(times[loop - 1]);
                        if (loop > 1)
                        {
                            if (time <= int.Parse(times[loop - 2]))
                                // Times from dispensing not in ascending order
                                return false;
                        }
                        if (time >= bandStart[3])
                            band = 4;
                        else if (time >= bandStart[2])
                            band = 3;
                        else if (time >= bandStart[1])
                            band = 2;
                        else
                            band = 1;
                        bands[band -1]++;
                    }
                    for (band = 0; band <= 3; band++)
                    {
                        if (bands[band] > 1)
                            // More than one dose in a single time slot
                            return false;
                    }
                    // Success
                    return true;
                default:
                    // Time slots used is < 1 or > 4
                    return false;
            }
        }

        /// <summary>
        /// Checks to see if the rule should be an exception or not
        /// </summary>
        /// <param name="errorNumber">The error number to be checked</param>
        /// <param name="robot">Indicates if a robot check is required</param>
        /// <returns>If the rule should be flagged as an exception</returns>
        private bool RuleIsException(string errorNumber, bool robot)
        {
            bool ret = false;
            if (robot)
            {
                if (((combined) && (!robotIgnore.Contains(errorNumber) && !robotIgnore2.Contains(errorNumber) && !robotInformation.Contains(errorNumber) && !robotInformation2.Contains(errorNumber)))
                    || (!(robotIgnore.Contains(errorNumber)) && !(robotInformation.Contains(errorNumber))))
                        ret = true;
            }
            else
            {
                if (((combined) && (!ignore.Contains(errorNumber) && !ignore2.Contains(errorNumber) && !information.Contains(errorNumber) && !information2.Contains(errorNumber)))
                    || (!(ignore.Contains(errorNumber)) && !(information.Contains(errorNumber))))
                       ret = true;
            }
            return ret;
        }

        /// <summary>
        /// Checks to see if a rule should be ignored, based on the errorNumber and if the stage is combined
        /// </summary>
        /// <param name="errorNumber">The error number of the rule to be checked</param>
        /// <param name="robot">Indicates if a robot check is required</param>
        /// <returns>If the rule should be ignored</returns>
        private bool IgnoreRule(string errorNumber, bool robot)
        {
            bool ret = false;
            if (robot)
            {
                if (((combined) && (!(!robotIgnore.Contains(errorNumber) && !robotIgnore2.Contains(errorNumber) && !robotInformation.Contains(errorNumber) && !robotInformation2.Contains(errorNumber)) && !((!robotIgnore.Contains(errorNumber) && !robotIgnore2.Contains(errorNumber)))))
                    || (robotIgnore.Contains(errorNumber)))
                        ret = true;
            }
            else
            {
                if (((combined) && (!(!ignore.Contains(errorNumber) && !ignore2.Contains(errorNumber) && !information.Contains(errorNumber) && !information2.Contains(errorNumber)) && !((!ignore.Contains(errorNumber) && !ignore2.Contains(errorNumber)))))
                    || (ignore.Contains(errorNumber)))
                        ret = true;
            }
            return ret;
        }

        //17Feb14 TH Added (TFS 84113)
        /// <summary>
        /// Checks to see if a rule should be used to switch an item from robotable, based on the errorNumber.
        /// </summary>
        /// <param name="errorNumber">The error number of the switch rule to be checked</param>
        /// <returns>If the switch should be ignored</returns>
        private bool SwitchRobot(string errorNumber)
        {
            bool ret = false;
            {
                if (robotSwitch.Contains(errorNumber))
                {
                    ret = true;
                }
            }
            return ret;
        }


        /// <summary>
        /// Validates the requested patient for repeat dispensing
        /// </summary>
        /// <param name="entityID">EntityID of the patient</param>
        /// <param name="siteID">SiteID passed to child object validation</param>
        /// <param name="xmlWriter">XmlWriter for writing to the ValidationErrorsXML property</param>
        /// <param name="requestID">Optional request ID ofr validating a single dispensing for the patient, used for validating a potential linking. Set to null to check all linked dispensings.</param>
        /// <param name="factor">Batch multiplication factor</param>
        /// <param name="quantity">Quantity for repeat dispensing</param>
        /// <param name="useADM">Indidcates whether this is a robot batch (which may include manual dispensings) or a manual batch (which can no longer include items which would have been robot dispensed), or in the case of linking validation if it should be validated as a robot item</param>
        /// <param name="RepeatTotal">Indicates Total number of repeat cycles allowed</param>
        /// <param name="RepeatRemaining">Indicates number of repeats remaining</param>
        /// <param name="PrescriptionExpiry">Indicates Expiry date of prescription for repeat dispensing</param>
        //private void ValidatePatient(int entityID, int siteID, XmlWriter xmlWriter, int? requestID, int factor, double? quantity, bool useADM, int? RepeatTotal, int? RepeatRemaining, DateTime? PrescriptionExpiry, bool ignoreExpiredItems)
        private void ValidatePatient(int entityID, int siteID, XmlWriter xmlWriter, int? requestID, int factor, double? quantity, bool useADM, int? RepeatTotal, int? RepeatRemaining, DateTime? PrescriptionExpiry)  //25Feb15 TH Removed param (TFS 111756)
        {
            //AddValidationError(xmlWriter, "Repeats", "Prescription YYYYYY has expired", RuleIsException("106", false), string.Format("SiteNumber = {0}, {1}", SiteProcessor.GetNumberBySiteID(siteID), ""), 106);
            

            //if (skipPatient)
            //{
            //     if (requestID.HasValue)
            //    {
            //        // Load and validate single unlinked dispensing
            //        using (WLabel dispensing = new WLabel())
            //        {
            //            bool _useADM;
            //            _useADM = false;
            //            
            //            dispensing.LoadUncancelledByRequestID(requestID.Value);
            //            ValidateDispensing(dispensing[0].RequestID, siteID, xmlWriter, _useADM, entityID, 0, false, quantity, null, true, RepeatTotal, RepeatRemaining, PrescriptionExpiry, skipPatient);
            //        }
            //    }
            //    
            //                         
            //}
            //else
            //{
                
                lastLabelType = null;

                // Load patient object
                PharmacyPatientInfo patient = new PharmacyPatientInfo();
                patient.LoadByEntityID(entityID);
                if (patient.Count == 0)
                {
                    xmlWriter.WriteStartElement("Patient");
                    xmlWriter.WriteAttributeString("EntityID", entityID.ToString());
                    if (!IgnoreRule("160", false))
                        AddValidationError(xmlWriter, "Patient", "Patient not found", RuleIsException("160", false), string.Format("EntityID={0}", entityID), 160);
                    xmlWriter.WriteEndElement();

                }
                else if (patient.Count > 1)
                {
                    xmlWriter.WriteStartElement("Patient");
                    xmlWriter.WriteAttributeString("EntityID", entityID.ToString());
                    if (!IgnoreRule("161", false))
                        AddValidationError(xmlWriter, "Patient", "More than one patient found", RuleIsException("161", false), string.Format("EntityID={0}", entityID), 161);
                    xmlWriter.WriteEndElement();
                }
                else
                {
                    // Load patient settings
                    RepeatDispensingPatient rdPatient = new RepeatDispensingPatient();
                    rdPatient.LoadByEntityID(entityID);
                    if (rdPatient.Count == 0)
                    {
                        xmlWriter.WriteStartElement("Patient");
                        xmlWriter.WriteAttributeString("EntityID", entityID.ToString());
                        if (!IgnoreRule("162", false))
                            AddValidationError(xmlWriter, "Patient Settings", "No repeat dispensing patient settings found for patient", RuleIsException("162", false), RepeatDispensingPatientProcessor.PatientDetailsString(entityID), 162);
                        xmlWriter.WriteEndElement();
                    }
                    else if (rdPatient.Count > 1)
                    {
                        xmlWriter.WriteStartElement("Patient");
                        xmlWriter.WriteAttributeString("EntityID", entityID.ToString());
                        if (!IgnoreRule("163", false))
                            AddValidationError(xmlWriter, "Patient Settings", "Multiple patient settings found for patient", RuleIsException("163", false), RepeatDispensingPatientProcessor.PatientDetailsString(entityID), 163);
                        xmlWriter.WriteEndElement();
                    }
                    else if ((rdPatient[0].InUse.HasValue && (bool)rdPatient[0].InUse) || requestID.HasValue)
                    {
                        xmlWriter.WriteStartElement("Patient");
                        xmlWriter.WriteAttributeString("EntityID", entityID.ToString());
                        xmlWriter.WriteAttributeString("SupplyLength", rdPatient[0].SupplyDays.ToString());
                        xmlWriter.WriteAttributeString("InUse", rdPatient[0].InUse.ToString());
                        xmlWriter.WriteAttributeString("EpisodeID", rdPatient[0].EpisodeID.ToString()); // 17Jul12 AJK 38690 Added EpisodeID of active (if not lifetime) episode
                        if (rdPatient[0].SupplyPattern.HasValue)
                        {
                            // Load supply pattern
                            RepeatDispensingSupplyPattern rdSupplyPattern = new RepeatDispensingSupplyPattern();
                            rdSupplyPattern.LoadBySupplyPatternID(EnumViaDBLookupAttribute.ToLookupID<SupplyPattern>(rdPatient[0].SupplyPattern.Value));
                            xmlWriter.WriteAttributeString("SupplyPatternDays", rdSupplyPattern[0].Days.ToString());
                            xmlWriter.WriteAttributeString("SupplyPatternSplitDays", rdSupplyPattern[0].SplitDays.ToString());
                        }
                        if (rdPatient[0].InUse != true)
                        {
                            if (!IgnoreRule("164", false))
                                AddValidationError(xmlWriter, "InUse", "Repeat dispensing patient settings not marked for use", RuleIsException("164", false), RepeatDispensingPatientProcessor.PatientDetailsString(entityID), 164);
                        }

                        // Load all patient episodes
                        Episode episodes = new Episode();
                        episodes.LoadByEntityID(entityID);
                        if (episodes.Count == 0)
                        {
                            if (!IgnoreRule("165", false))
                                AddValidationError(xmlWriter, "Episode", "No episodes found for patient", RuleIsException("165", false), RepeatDispensingPatientProcessor.PatientDetailsString(entityID), 165);
                        }
                        else
                        {
                            if (requestID.HasValue)
                            {
                                // Load and validate single unlinked dispensing
                                using (WLabel dispensing = new WLabel())
                                {
                                    bool _useADM;
                                    if (patient[0].ADM.HasValue && patient[0].ADM.Value == true && packerSection.HasValue && useADM)
                                    {
                                        _useADM = true;
                                    }
                                    else
                                    {
                                        _useADM = false;
                                    }
                                    dispensing.LoadUncancelledByRequestID(requestID.Value);
                                    //ValidateDispensing(dispensing[0].RequestID, siteID, xmlWriter, _useADM, entityID, factor * rdPatient[0].SupplyDays.Value, false, quantity, null, true, RepeatTotal, RepeatRemaining, PrescriptionExpiry,false);   06Jan15 XN 105787 Ignore prescriptions that have expired 
                                    //ValidateDispensing(dispensing[0].RequestID, siteID, xmlWriter, _useADM, entityID, factor * rdPatient[0].SupplyDays.Value, false, quantity, null, true, RepeatTotal, RepeatRemaining, PrescriptionExpiry,false, ignoreExpiredItems);
                                    ValidateDispensing(dispensing[0].RequestID, siteID, xmlWriter, _useADM, entityID, factor * rdPatient[0].SupplyDays.Value, false, quantity, null, true, RepeatTotal, RepeatRemaining, PrescriptionExpiry,false);  //25Feb15 TH Removed param (TFS 111756)
                                }
                            }
                            else
                            {
                                // Load all linked repeat dispensings for patient
                                foreach (EpisodeRow episodeRow in episodes)
                                {
                                    if (!IgnoreRule("166", false) && episodeRow.EpisodeID_Parent == 0 && episodeRow.EndDate.HasValue)
                                    {
                                        AddValidationError(xmlWriter, "Episode", "Patient is no longer alive", RuleIsException("166", false), RepeatDispensingPatientProcessor.PatientDetailsString(entityID), 166);
                                    }
                                    WLabel dispensings = new WLabel();
                                    dispensings.LoadRepeatDispensingsByEpisodeID(episodeRow.EpisodeID);

                                    foreach (WLabelRow dispensing in dispensings)
                                    {
                                        if (!IgnoreRule("168", false) && lastLabelType != null && lastLabelType != dispensing.IssType)
                                        {
                                            AddValidationError(xmlWriter, "Dispensings", "Patient has a mixture of dispensings", RuleIsException("168", false), RepeatDispensingPatientProcessor.PatientDetailsString(entityID), 168);
                                        }
                                        lastLabelType = dispensing.IssType;
                                        bool _useADM = true;
                                        bool inUse;
                                        using (RdRxLinkDispensingProcessor processor = new RdRxLinkDispensingProcessor())
                                        {
                                            RDRxLinkDispensingLine linkline = new RDRxLinkDispensingLine();
                                            linkline = processor.LoadByDispensingID(dispensing.RequestID);
                                            //if (GetPackerName(false) == "JVADTPS") _useADM = linkline.JVM;
                                        
					//if (GetPackerName(false) == "JVADTPS" && linkline.JVM) // 13Aug12 AJK 41186 If batch is marked to use robot and the packer is a JVM and the linkline is set to use the JVM
                                        //    _useADM = true;
                                        //else
                                        //    _useADM = false;

					if (GetPackerName(false) == "JVADTPS") _useADM = linkline.JVM; //28Oct13 TH Removed above block and reverted to original line. This mod broke none JVM Pakers (TFS 76409)

                                            inUse = linkline.InUse;
                                        }
                                        // 13Aug12 AJK 41186 Added the useADM to pass through the batch indicator only, in order to filter out robotable items if it's turned off
                                        //ValidateDispensing(dispensing.RequestID, siteID, xmlWriter, _useADM && patient[0].ADM.HasValue && packerSection.HasValue ? (bool)patient[0].ADM : false, entityID, factor * rdPatient[0].SupplyDays.Value, true, quantity, inUse, useADM, RepeatTotal, RepeatRemaining, PrescriptionExpiry,false);    06Jan15 XN 105787 Ignore prescriptions that have expired
                                        //ValidateDispensing(dispensing.RequestID, siteID, xmlWriter, _useADM && patient[0].ADM.HasValue && packerSection.HasValue ? (bool)patient[0].ADM : false, entityID, factor * rdPatient[0].SupplyDays.Value, true, quantity, inUse, useADM, RepeatTotal, RepeatRemaining, PrescriptionExpiry,false,ignoreExpiredItems);
                                        ValidateDispensing(dispensing.RequestID, siteID, xmlWriter, _useADM && patient[0].ADM.HasValue && packerSection.HasValue ? (bool)patient[0].ADM : false, entityID, factor * rdPatient[0].SupplyDays.Value, true, quantity, inUse, useADM, RepeatTotal, RepeatRemaining, PrescriptionExpiry,false); //25Feb15 TH (TFS 111756)
                                    }
                                }
                            }
                        }
                        xmlWriter.WriteEndElement();
                    }
                }
            //}
        }

        private void RemoveOrphanedElements()
        {
            XmlDocument doc = new XmlDocument();
            doc.LoadXml(_validationErrorsXML.ToString());
            XmlNode batchNode = doc.SelectSingleNode("//Batch");
            List<XmlNode> patients = doc.SelectNodes("//Patient").Cast<XmlNode>().ToList();
            foreach(XmlNode patient in patients )
            {
                if (patient.SelectNodes("Dispensing").Count == 0 && patient.SelectNodes("ValidationError[@Exception='1']").Count == 0)
                    batchNode.RemoveChild(patient);
            }
            if (batchNode.ChildNodes.Count == 0)
            {
                //Batch is now empty
                ValidationErrors.Add(new ValidationError(this, "Batch", "ForGUI", "", "Batch contains no patients. This is either because all patients/dispensings have been marked out of use and/or because you have selected to remove manually dispensed items.",true));
                XmlElement error = doc.CreateElement("ValidationError");
                XmlAttribute className = doc.CreateAttribute("ClassName");
                className.Value = this.GetType().FullName;
                XmlAttribute propertyName = doc.CreateAttribute("PropertyName");
                propertyName.Value = "Batch";
                XmlAttribute keyName = doc.CreateAttribute("KeyName");
                keyName.Value = "ForGUI";
                XmlAttribute keyValue = doc.CreateAttribute("KeyValue");
                keyValue.Value = "";
                XmlAttribute errorMessage = doc.CreateAttribute("ErrorMessage");
                errorMessage.Value = "Batch contains no patients. This is either because all patients/dispensings have been marked out of use and/or because you have selected to remove manually dispensed items.";
                XmlAttribute exception = doc.CreateAttribute("Exception");
                exception.Value = "1";
                hasExceptions = true;
                error.Attributes.Append(className);
                error.Attributes.Append(propertyName);
                error.Attributes.Append(keyName);
                error.Attributes.Append(keyValue);
                error.Attributes.Append(errorMessage);
                error.Attributes.Append(exception);
                batchNode.AppendChild(error);
            }
            _validationErrorsXML.Length = 0;
            _validationErrorsXML.Append(doc.InnerXml);
        }

        /// <summary>
        /// Validates the batch for repeat dispensing
        /// </summary>
        /// <param name="batchID">The BatchID for the requested batch</param>
        /// <param name="siteID">The SiteID used to identify child objects</param>
        /// <param name="status">Status of the batch to be validated</param>
        /// <returns>Success</returns>
        public bool ValidateBatch(int batchID, int siteID, BatchStatus status)
        {
            bool batchUseRobot = true;
            XmlWriterSettings xmlSettings = new XmlWriterSettings();
            xmlSettings.OmitXmlDeclaration = true;
            xmlSettings.NewLineHandling = NewLineHandling.Entitize;
            xmlSettings.Indent = true;
            XmlWriter xmlWriter = XmlWriter.Create(_validationErrorsXML, xmlSettings);
            xmlWriter.WriteStartElement("xmlData");
            xmlWriter.WriteStartElement("Batch");
            xmlWriter.WriteAttributeString("BatchID", batchID.ToString());

            RepeatDispensingBatch batch = new RepeatDispensingBatch();
            batch.LoadByBatchID(batchID);
            if (batch.Count == 0)
            {
                AddValidationError(xmlWriter, "Batch", "Batch not found", true, string.Format("BatchID={0}", batchID), 150);
            }
            else if (batch.Count > 1)
            {
                AddValidationError(xmlWriter, "Batch", "More than one batch found", true, string.Format("BatchID={0}", batchID), 151);
            }
            else
            {
                xmlWriter.WriteAttributeString("Factor", batch[0].Factor.ToString());
                xmlWriter.WriteAttributeString("BagLabels", batch[0].BagLabelsPerPatient.ToString());
                xmlWriter.WriteAttributeString("Description", batch[0].Description.ToString());
                xmlWriter.WriteAttributeString("LocationID", batch[0].LocationID.ToString());
                xmlWriter.WriteAttributeString("LocationDescription", batch[0].LocationDescription != null ? batch[0].LocationDescription.ToString() : "");
                xmlWriter.WriteAttributeString("StartDate", batch[0].StartDate.HasValue ? string.Format("{0:s}", batch[0].StartDate) : "");
                xmlWriter.WriteAttributeString("StartSlot", batch[0].StartSlot.ToString());
                xmlWriter.WriteAttributeString("TotalSlots", batch[0].TotalSlots.ToString());
                xmlWriter.WriteAttributeString("Breakfast", batch[0].Breakfast.ToString());
                xmlWriter.WriteAttributeString("Lunch", batch[0].Lunch.ToString());
                xmlWriter.WriteAttributeString("Tea", batch[0].Tea.ToString());
                xmlWriter.WriteAttributeString("Night", batch[0].Night.ToString());
                if (batch[0].SortByDate.HasValue && batch[0].SortByDate == true) xmlWriter.WriteAttributeString("SortByDate", "1");
                if (batch[0].IncludeManual.HasValue && batch[0].IncludeManual == false) includeManual = false;
                if (GetPackerName(false) == "JVADTPS" && !batch[0].StartDate.HasValue) batchUseRobot = false;
                string stage = "";
                switch (status)
                {
                    case BatchStatus.New:
                        stage = "Labelling";
                        break;
                    case BatchStatus.Labelled:
                        stage = "Issuing";
                        break;
                    case BatchStatus.Combined:
                        stage = "Combined";
                        combined = true;
                        break;
                }

                ValidateConfig(xmlWriter, siteID, stage);

                //bool ignoreExpiredPrescriptions = WConfiguration.Load<bool>(siteID, "D|PATMED", "RepeatDispensing", "skipExpiredPrescriptions", true, false);   // 06Jan15 XN 105787 Ignore prescriptions that have expired //25Feb15 TH Removed (TFS 111756)

                PharmacyPatientInfo batchPatients = new PharmacyPatientInfo();
                batchPatients.LoadInUseByBatchID(batchID);
                foreach (RDispPatientInfoRow patient in batchPatients)
                {
                    //ValidatePatient(patient.EntityID, siteID, xmlWriter, null, batch[0].Factor, null, batchUseRobot, null, null, null) 09Sep13 TH removed skipPatient
                    //ValidatePatient(patient.EntityID, siteID, xmlWriter, null, batch[0].Factor, null, batchUseRobot, null, null, null, ignoreExpiredPrescriptions); // 06Jan15 XN 105787 Ignore prescriptions that have expired  09Sep13 TH removed skipPatient
                    ValidatePatient(patient.EntityID, siteID, xmlWriter, null, batch[0].Factor, null, batchUseRobot, null, null, null); //25feb15 TH Removed param (TFS 111756)
                }
            } 

            xmlWriter.WriteEndElement();
            xmlWriter.WriteEndElement();
            xmlWriter.Close();
            RemoveOrphanedElements();
            return !hasExceptions;
        }

        /// <summary>
        /// Gets the name (identifier) of the packer robot found in configuration
        /// </summary>
        /// <param name="validate">Requires validation</param>
        /// <returns>The name of the robot, null if errors detected or robot not found</returns>
        public string GetPackerName(bool validate)
        {
            string packerName = string.Empty; // 18Sep12 AJK 44221 Changed from null to empty string
            XmlWriter xmlWriter = null;
            if (validate)
            {
                XmlWriterSettings xmlSettings = new XmlWriterSettings();
                xmlSettings.OmitXmlDeclaration = true;
                xmlSettings.NewLineHandling = NewLineHandling.Entitize;
                xmlSettings.Indent = true;
                xmlWriter = XmlWriter.Create(_validationErrorsXML, xmlSettings);
                xmlWriter.WriteStartElement("xmlData");
            }
            packerSection = null;
            using (Sites sites = new Sites())
            {
                using (WConfiguration config = new WConfiguration())
                {
                    sites.LoadAll();
                    for (int i = 0; i < sites.Count; i++)
                    {
                        config.LoadBySiteCategorySectionAndKey(sites[i].SiteID, "D|MECHDISP", "", "PackerSection");
                        if (config.Count == 1)
                        {
                            packerSection = int.Parse(config[0].Value);
                            config.Clear();
                            config.LoadBySiteCategorySectionAndKey(sites[i].SiteID, "D|MECHDISP", packerSection.ToString(), "Identifier");
                            if (config.Count == 1)
                            {
                                if (packerName == string.Empty) // 18Sep12 AJK 44221 Changed from null to empty string
                                {
                                    packerName = config[0].Value;
                                }
                                else if (packerName != config[0].Value && validate)
                                {
                                    AddValidationError(xmlWriter, "Config", "More than one packer robot of different types detected", true, string.Format("Packer Robot 1 = {0}, Packer Robot 2 = {1}", packerName, config[0].Value), 181);
                                }
                            }
                        }
                    }
                }
            }
            if (validate)
            {
                xmlWriter.WriteEndElement();
                xmlWriter.Close();
                if (ValidationErrors.Count > 0)
                    packerName = null;
            }

            return packerName;
        }
        
        /// <summary>
        /// Gets the name (identifier) of the packer robot found in configuration
        /// </summary>
        /// <returns>The name of the robot, null if errors detected or robot not found</returns>
        public string GetPackerName()
        {
            return GetPackerName(true);
        }

        /// <summary>
        /// Returns DisplayName, or empty string if not present
        /// This should not be here is shold probably be in it's own config class with other settings from this section.
        /// </summary>
        /// <param name="siteID">optional site ID (if not supplied locates a site dispensing)</param>
        /// <returns>Packer display name</returns>
        public static string GetPackerDisplayName(int? siteID)
        {
            string displayName = string.Empty;

            // Get list of sites (can be single one)
            List<int> siteIDs;
            if (siteID.HasValue)
            {
                siteIDs = new List<int>();
                siteIDs.Add(siteID.Value);
            }
            else
            {
                Sites sites = new Sites();
                sites.LoadAll();
                siteIDs = sites.Select(s => s.SiteID).ToList();
            }

            WConfiguration config = new WConfiguration();
            for (int i = 0; i < siteIDs.Count; i++)
            {
                // get packer section (skip if not present for site)
                config.LoadBySiteCategorySectionAndKey(siteIDs[i], "D|MECHDISP", string.Empty, "PackerSection");
                if (config.Any())
                {
                    string packerSection = config[0].Value;

                    // Get display name
                    config.LoadBySiteCategorySectionAndKey(siteIDs[i], "D|MECHDISP", packerSection, "DisplayName");
                    if (config.Any())
                    {
                        // Error if not same
                        if (config[0].Value == displayName)
                            return string.Empty;

                        displayName = config[0].Value;
                    }
                }
            }

            return displayName;
        }

        /// <summary>
        /// Gets all necessary config settings and validates the exist as expected
        /// </summary>
        /// <param name="xmlWriter">XMLWriter object for writing ValidaionErrorsXML</param>
        /// <param name="siteID">ID for the site where the settings are to be validated</param>
        /// <param name="stage">String to represent the stage to be appended to config key name</param>
        private void ValidateConfig(XmlWriter xmlWriter, int siteID, string stage)
        {
            using (WConfiguration config = new WConfiguration())
            {
                if (combined)
                {
                    // Get list of error codes to be ignored for this stage
                    config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationIgnoresLabelling");
                    if (config.Count == 1)
                        ignore = config[0].Value;
                    else
                        ignore = "";
                    config.Clear();
                    config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationIgnoresIssuing");
                    if (config.Count == 1)
                        ignore2 = config[0].Value;
                    else
                        ignore2 = "";
                    config.Clear();

                    // Get list of error codes to be marked as informaiton only for this stage
                    config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationInformationLabelling");
                    if (config.Count == 1)
                        information = config[0].Value;
                    else
                        information = "";
                    config.Clear();
                    config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationInformationIssuing");
                    if (config.Count == 1)
                        information2 = config[0].Value;
                    else
                        information2 = "";
                    config.Clear();
                }
                else
                {
                    // Get list of error codes to be ignored for this stage
                    config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationIgnores" + stage);
                    if (config.Count == 1)
                        ignore = config[0].Value;
                    else
                        ignore = "";
                    config.Clear();

                    // Get list of error codes to be marked as informaiton only for this stage
                    config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationInformation" + stage);
                    if (config.Count == 1)
                        information = config[0].Value;
                    else
                        information = "";
                    config.Clear();
                }
                
                // Check for a packer section
                config.LoadBySiteCategorySectionAndKey(siteID, "D|MECHDISP", "", "PackerSection");
                if (config.Count == 1)
                {
                    packerSection = int.Parse(config[0].Value);
                    config.Clear();
                    config.LoadBySiteCategorySectionAndKey(siteID, "D|MECHDISP", packerSection.ToString(), "LocationCode");
                    if (config.Count == 1)
                    {
                        packerLocationCode = config[0].Value;
                    }
                    else
                    {
                        AddValidationError(xmlWriter, "Config", "No location code found for robot", true, string.Format("SiteNumber = {0}, PackerSection = {1}", SiteProcessor.GetNumberBySiteID(siteID), packerSection), 180);
                        packerSection = null;
                    }
                }

                config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "", "QuantityManualEntryTypes");
                if (config.Count == 1)
                {
                    manualEntryQuantityTypes = config[0].Value;
                }
                else
                {
                    AddValidationError(xmlWriter, "Config", "No configuration record found for manual entry quantity types", true, string.Format("SiteNumber  ={0}", SiteProcessor.GetNumberBySiteID(siteID)), 180);
                }

                if (packerSection.HasValue) // If site has a robot
                {
                    //18Feb14 TH Moved from below after initial testing (TFS 84113)
                    // Get list of error codes to be switched for this stage for robot items (ie robot items to become normal items
                    config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationSwitchRobot");
                    if (config.Count == 1)
                        robotSwitch = config[0].Value;
                    else
                        robotSwitch = "";
                    config.Clear();
                    
                    if (combined)
                    {
                        // Get list of error codes to be ignored for this stage for robot items
                        config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationIgnoresLabellingRobot");
                        if (config.Count == 1)
                            robotIgnore = config[0].Value;
                        else
                            robotIgnore = "";
                        config.Clear();
                        // Get list of error codes to be marked as informaiton only for this stage for robot items
                        config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationInformationLabellingRobot");
                        if (config.Count == 1)
                            robotInformation = config[0].Value;
                        else
                            robotInformation = "";
                        config.Clear();
                        // Get list of error codes to be ignored for this stage for robot items
                        config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationIgnoresIssuingRobot");
                        if (config.Count == 1)
                            robotIgnore2 = config[0].Value;
                        else
                            robotIgnore2 = "";
                        config.Clear();
                        // Get list of error codes to be marked as informaiton only for this stage for robot items
                        config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationInformationIssuingRobot");
                        if (config.Count == 1)
                            robotInformation2 = config[0].Value;
                        else
                            robotInformation2 = "";
                        config.Clear();
                    }
                    else
                    {
                        // Get list of error codes to be ignored for this stage for robot items
                        config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationIgnores" + stage + "Robot");
                        if (config.Count == 1)
                            robotIgnore = config[0].Value;
                        else
                            robotIgnore = "";
                        config.Clear();
                        // Get list of error codes to be marked as informaiton only for this stage for robot items
                        config.LoadBySiteCategorySectionAndKey(siteID, "D|PATMED", "RepeatDispensing", "ValidationInformation" + stage + "Robot");
                        if (config.Count == 1)
                            robotInformation = config[0].Value;
                        else
                            robotInformation = "";
                        config.Clear();
                    }

                    int result;
                    config.LoadBySiteCategorySectionAndKey(siteID, "D|MECHDISP", packerSection.ToString(), "DoseSlot1");
                    if (config.Count == 1 && config[0].Value.Length >= 4 && int.TryParse(config[0].Value.Substring(0, 4), out result))
                    {
                        timeBandsStart[0] = config[0].Value.Substring(0, 4);
                        config.Clear();
                        config.LoadBySiteCategorySectionAndKey(siteID, "D|MECHDISP", packerSection.ToString(), "DoseSlot2");
                        if (config.Count == 1 && config[0].Value.Length >= 4 && int.TryParse(config[0].Value.Substring(0, 4), out result))
                        {
                            timeBandsStart[1] = config[0].Value.Substring(0, 4);
                            config.Clear();
                            config.LoadBySiteCategorySectionAndKey(siteID, "D|MECHDISP", packerSection.ToString(), "DoseSlot3");
                            if (config.Count == 1 && config[0].Value.Length >= 4 && int.TryParse(config[0].Value.Substring(0, 4), out result))
                            {
                                timeBandsStart[2] = config[0].Value.Substring(0, 4);
                                config.Clear();
                                config.LoadBySiteCategorySectionAndKey(siteID, "D|MECHDISP", packerSection.ToString(), "DoseSlot4");
                                if (config.Count == 1 && config[0].Value.Length >= 4 && int.TryParse(config[0].Value.Substring(0, 4), out result))
                                {
                                    timeBandsStart[3] = config[0].Value.Substring(0, 4);
                                }
                                else
                                {
                                    AddValidationError(xmlWriter, "Config", "No configuration record found for robot DoseSlot4", true, string.Format("SiteNumber  ={0}, PackerSection = {1}", SiteProcessor.GetNumberBySiteID(siteID), packerSection), 180);
                                    packerSection = null;
                                }
                            }
                            else
                            {
                                AddValidationError(xmlWriter, "Config", "No configuration record found for robot DoseSlot3", true, string.Format("SiteNumber = {0}, PackerSection = {1}", SiteProcessor.GetNumberBySiteID(siteID), packerSection), 180);
                                packerSection = null;
                            }
                        }
                        else
                        {
                            AddValidationError(xmlWriter, "Config", "No configuration record found for robot DoseSlot2", true, string.Format("SiteNumber = {0}, PackerSection = {1}", SiteProcessor.GetNumberBySiteID(siteID), packerSection), 180);
                            packerSection = null;
                        }
                    }
                    else
                    {
                        AddValidationError(xmlWriter, "Config", "No configuration record found for robot DoseSlot1", true, string.Format("SiteNumber = {0}, PackerSection = {1}", SiteProcessor.GetNumberBySiteID(siteID), packerSection), 180);
                        packerSection = null;
                    }
                }
            }
        }

        /// <summary>
        /// Adds a validation error to the ValidationErrors list and writes to ValidationErrorsXML
        /// </summary>
        /// <param name="xmlWriter">XmlWriter for writing to the ValidationErrorsXML property</param>
        /// <param name="propertyName">The property raising the validation error</param>
        /// <param name="errorMessage">The error message to be written</param>
        private void AddValidationError(XmlWriter xmlWriter, string propertyName, string errorMessage, bool isException, string objectIdentifier)
        {
            ValidationErrors.Add(new ValidationError(this, propertyName, "ForGUI", objectIdentifier, errorMessage, isException));
            xmlWriter.WriteStartElement("ValidationError");
            xmlWriter.WriteAttributeString("ClassName", this.GetType().FullName);
            xmlWriter.WriteAttributeString("PropertyName", propertyName);
            xmlWriter.WriteAttributeString("KeyName", "ForGUI");
            xmlWriter.WriteAttributeString("KeyValue", objectIdentifier);
            xmlWriter.WriteAttributeString("ErrorMessage", errorMessage);
            if (isException)
            {
                xmlWriter.WriteAttributeString("Exception", "1");
                hasExceptions = true;
            }
            xmlWriter.WriteEndElement();
        }

        /// <summary>
        /// Adds a validation error to the ValidationErrors list and writes to ValidationErrorsXML
        /// </summary>
        /// <param name="xmlWriter">XmlWriter for writing to the ValidationErrorsXML property</param>
        /// <param name="propertyName">The property raising the validation error</param>
        /// <param name="errorMessage">The error message to be written</param>
        /// <param name="errorCode">The error code</param>
        private void AddValidationError(XmlWriter xmlWriter, string propertyName, string errorMessage, bool isException, string objectIdentifier, int errorCode)
        {
            ValidationErrors.Add(new ValidationError(this, propertyName, "ForGUI", objectIdentifier, errorMessage, isException, errorCode));
            xmlWriter.WriteStartElement("ValidationError");
            xmlWriter.WriteAttributeString("ClassName", this.GetType().FullName);
            xmlWriter.WriteAttributeString("PropertyName", propertyName);
            xmlWriter.WriteAttributeString("KeyName", "ForGUI");
            xmlWriter.WriteAttributeString("KeyValue", objectIdentifier);
            xmlWriter.WriteAttributeString("ErrorMessage", errorMessage);
            if (isException)
            {
                xmlWriter.WriteAttributeString("Exception", "1");
                hasExceptions = true;
            }
            xmlWriter.WriteAttributeString("ErrorCode", errorCode.ToString());
            xmlWriter.WriteEndElement();
        }


    }
}
