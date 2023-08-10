//===========================================================================
//
//							PCTPatient.cs
//
//  This class is a data layer representation of the PCT Patient
//  settings.
//
//  SP for this object should return all fields from the PCTPatient table, 
//
//	Modification History:
//	09Nov11 AJK  Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.pharmacydatalayer
{
    public class PCTPatientRow : BaseRow
    {

        /// <summary>
        /// Primary key, read only
        /// </summary>
        public int PCTPatientID
        {
            get { return FieldToInt(RawRow["PCTPatientID"]).Value; }
            set { RawRow["PCTPatientID"] = IntToField(value); }
        }

        /// <summary>
        /// EntityID of the patient
        /// </summary>
        public int EntityID
        {
            get { return FieldToInt(RawRow["EntityID"]).Value; }
            set { RawRow["EntityID"] = IntToField(value); }
        }

        /// <summary>
        /// High use health card number
        /// </summary>
        public string HUHCNo
        {
            get { return FieldToStr(RawRow["HUHCNo"],false,string.Empty); }
            set { RawRow["HUHCNo"] = StrToField(value); }
        }

        /// <summary>
        /// Expiry date for the high use health card
        /// </summary>
        public DateTime? HUHCExpiry
        {
            get { return FieldToDateTime(RawRow["HUHCExpiry"]); }
            set { RawRow["HUHCExpiry"] = DateTimeToField(value); }
        }

        /// <summary>
        /// Indicates whether the patient has a community service card
        /// </summary>
        public bool CSC
        {
            get { return FieldToBoolean(RawRow["CSC"]).Value; }
            set { RawRow["CSC"] = BooleanToField(value); }
        }

        /// <summary>
        /// The expiry date for the community service card
        /// </summary>
        public DateTime? CSCExpiry
        {
            get { return FieldToDateTime(RawRow["CSCExpiry"]); }
            set { RawRow["CSCExpiry"] = DateTimeToField(value); }
        }

        /// <summary>
        /// Indicates if the patient is a permanant resident of Hokianga
        /// </summary>
        public bool PermResHokianga
        {
            get { return FieldToBoolean(RawRow["PermResHokianga"]).Value; }
            set { RawRow["PermResHokianga"] = BooleanToField(value); }
        }

        /// <summary>
        /// Indicates if the patient is registered with a primary health organisation
        /// </summary>
        public bool PHORegistered
        {
            get { return FieldToBoolean(RawRow["PHORegistered"]).Value; }
            set { RawRow["PHORegistered"] = BooleanToField(value); }
        }
    }

    public class PCTPatientBaseColumnInfo : BaseColumnInfo
    {
        public PCTPatientBaseColumnInfo() : base("PCTPatient") { }
    }

    public class PCTPatient : BaseTable<PCTPatientRow, PCTPatientBaseColumnInfo>
    {
        public PCTPatient()
            : base("PCTPatient", "PCTPatientID")
        {
            UpdateSP = "pPCTPatientUpdate";
        }

        public void LoadByEntityID(int entityID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "EntityID", entityID);
            LoadRecordSetStream("pPCTPatientByEntityID", parameters);
        }
    }
}
