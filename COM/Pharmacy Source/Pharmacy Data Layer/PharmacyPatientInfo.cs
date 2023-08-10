//===========================================================================
//
//					        RDispPatientInfo.cs
//
//  This class is a read only view of the patient for repeat dispensing
//
//  SP for this object should return following fields from Entity table
//      EntityID
//      Description as FullName
//  following fiels from patient
//      DOB
//  following fiels from person
//      Forename    
//      Surname
//  all fiels from RepeatDispensingPatient
//  following fiels from RepeatDispensingBatchTemplate
//      RepeatDispensingBatchTemplate.Description AS RepeatDispensingTemplate_Description    
//
//	Modification History:
//	20May09 AJK  Written
//  15Mar11 TH   Added Additional Information for F0082043 - Repeat Dispensing schedule print 
//  17May11 XN   Removed BagLabels, and added RepeatDispensingTemplateID F0057909 
//  30May11 XN   
//  31Oct11 AJK  Added NHINumber 16226
//  20Dec11 XN   Renamed to RDispPatientInfo and made it a view
//  20Mar12 AJK  Changed references to PharmacyPatientInfo from RDispPatientInfo
//  16Apr12 AJK  31236 Added Updated, UpdatedBy and UpdatedByDescription fields
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>
    /// Represents a row in the patient object, read only
    /// </summary>
    public class RDispPatientInfoRow : BaseRow
    {   
        public  int             EntityID                                                { get { return FieldToInt(RawRow["EntityID"]).Value;                                                                        } }
        public  string          FullName                                                { get { return FieldToStr(RawRow["Fullname"]);                                                                              } }
        public  DateTime?       DOB                                                     { get { return FieldToDateTime(RawRow["DOB"]);                                                                              } }
        public  string          Forename                                                { get { return FieldToStr(RawRow["Forename"]);                                                                              } }
        public  string          Surname                                                 { get { return FieldToStr(RawRow["Surname"]);                                                                               } }
        public  int?            RepeatDispensingPatientID                               { get { return FieldToInt(RawRow["RepeatDispensingPatientID"]);                                                             } }
        public  int?            SupplyDays                                              { get { return FieldToInt(RawRow["SupplyDays"]);                                                                            } }
        public  int?            BagLabels                                               { get { return FieldToInt(RawRow["BagLabels"]);                                                                             } }
        public  bool?           ADM                                                     { get { return FieldToBoolean(RawRow["ADM"]);                                                                               } }
        public  bool?           InUse                                                   { get { return FieldToBoolean(RawRow["InUse"]);                                                                             } }
        public  SupplyPattern?  SupplyPattern                                           { get { return FieldToEnumViaDBLookup<SupplyPattern>(RawRow["SupplyPatternID"]);                                            } }
        public  string          HospitalNumber                                          { get { return FieldToStr(RawRow["Hospital_Number"]);                                                                       } }
        public  string          AdditionalInformation                                   { get { return FieldToStr(RawRow["AdditionalInformation"]);                                                                 } }
        public  int?            RepeatDispensingBatchTemplateID                         { get { return FieldToInt(RawRow["RepeatDispensingBatchTemplateID"]);                                                       } }    
        public  string          RepeatDispensingBatchTemplateDescription                { get { return FieldToStr(RawRow["RepeatDispensingBatchTemplate_Description"], false, string.Empty);                        } }
        public  bool?           Available                                               { get { return RawRow.Table.Columns.Contains("Available")          ? FieldToBoolean(RawRow["Available"], false) : null;     } }
        public  string          MatchedDescription                                      { get { return RawRow.Table.Columns.Contains("MatchedDescription") ? FieldToStr(RawRow["MatchedDescription"])   : null;     } }
        public  int?            EpisodeID                                               { get { return RawRow.Table.Columns.Contains("EpisodeID") ? FieldToInt(RawRow["EpisodeID"]) : 0;                            } }
        public  string          NHINumber                                               { get { return RawRow.Table.Columns.Contains("NHINumber") ? FieldToStr(RawRow["NHINumber"]) : null;                         } }
        public  bool?           NHINumberIsValid                                        { get { return FieldToBoolean(RawRow["NHINumberIsValid"]);                                                                  } }
        public  DateTime?       RepeatDispensingPatientSettingsUpdated                  { get { return FieldToDateTime(RawRow["Updated"]); } } // 16Apr12 AJK 31236 Added
        public  int?            RepeatDispensingPatientSettingsUpdatedBy                { get { return FieldToInt(RawRow["UpdatedBy"]); } } // 16Apr12 AJK 31236 Added
        public  string          RepeatDispensingPatientSettingsUpdatedByDescription     { get { return FieldToStr(RawRow["UpdatedBy_Description"], true, string.Empty); } } // 16Apr12 AJK 31236 Added
    }

    /// <summary>
    /// Represents the Patient table and some associated table data, read only
    /// </summary>
    public class PharmacyPatientInfo : BaseTable<RDispPatientInfoRow, BaseColumnInfo>
    {
        /// <summary>
        /// Loads the patient information for the requested entity
        /// </summary>
        /// <param name="entityID">EntityID of requested patient</param>
        public void LoadByEntityID(int entityID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "EntityID", entityID);
            LoadRecordSetStream("pPharmacyPatientByEntityID",parameters);
        }

        /// <summary>
        /// Loads patient information for all patients in the requested repeat dispensing batch
        /// </summary>
        /// <param name="batchID">RepeatDispensingBatch BatchID</param>
        public void LoadByBatchID(int batchID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "BatchID", batchID);
            LoadRecordSetStream("pPharmacyPatientByBatchID", parameters);
        }

        /// <summary>
        /// Loads a patient by one of their request id's
        /// </summary>
        /// <param name="requestID">Any requestID for the required patient</param>
        public void LoadByRequestID(int requestID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "RequestID", requestID);
            LoadRecordSetStream("pPharmacyPatientByRequestID", parameters);
        }

        /// <summary>
        /// Loads all patients available for a requested batch
        /// </summary>
        /// <param name="batchID">BatchID for patient availabilty check</param>
        public void LoadAvailable(int batchID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "BatchID", batchID);
            LoadRecordSetStream("pPharmacyPatientAvailableForBatchAndLocation", parameters);
        }

        /// <summary>
        /// Loads all patients for a requested batch as long as their marked as in use
        /// </summary>
        /// <param name="batchID">BatchID to select patients with</param>
        public void LoadInUseByBatchID(int batchID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "BatchID", batchID);
            LoadRecordSetStream("pPharmacyPatientInUseByBatchID", parameters);
        }
    }
}

