//===========================================================================
//
//							       PNPrescription.cs
//
//  Provides access to PNPrescription table (hold the PN presription info requested by the prescriber). 
//
//  SP for this object should return all fields from PNPrescription plus
//      EpisodeOrder.EpisodeID
//      EpisodeOrder.EntityID_Owner
//      Request.RequestDate
//
//  Only supports reading.
//
//	Modification History:
//	19Dec11 XN Written
//  24Sep15 XN Fixed type in PNPrescritpionColumnInfo 77778
//===========================================================================
namespace ascribe.pharmacy.parenteralnutritionlayer
{
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;

    /// <summary>Represents a row in the PNPrescription table (inherites from PrescriptionRow)</summary>
    public class PNPrescriptionRow : BaseRow
    {
        #region General info
        public int RequestID { get { return FieldToInt(RawRow["RequestID"]).Value; } }

        public DateTime RequestDate { get { return FieldToDateTime(RawRow["RequestDate"]).Value; } }

        public string RegimenName { get { return FieldToStr(RawRow["RegimenName"], true, string.Empty); } }

        public string Description  { get { return FieldToStr(RawRow["Description"]); } }

        /// <summary>Prescriber</summary>
        public int EntityID_Owner {get { return FieldToInt(RawRow["EntityID_Owner"]).Value; } }

        public int EpisodeID { get { return FieldToInt(RawRow["EpisodeID"]).Value; } }

        public double DosingWeightInkg { get { return FieldToDouble(RawRow["DosingWeight_kg"]).Value; } }

        public bool PerKiloRules { get { return FieldToBoolean(RawRow["PerKiloRules"]).Value;  } }

        /// <summary>Gets the PerKiloRules value but as an AgeRangeType</summary>
        public AgeRangeType AgeRage { get { return PerKiloRules ? AgeRangeType.Paediatric : AgeRangeType.Adult; } }

        /// <summary>If the central line is required 58772 XN 13Mar13</summary>
        public bool CentralLineRequired { get { return FieldToBoolean(RawRow["CentralLineRequired"]).Value; } }

        /// <summary>If the patient has a central line present</summary>
        public bool CentralLinePresent { get { return FieldToBoolean(RawRow["CentralLinePresent"]).Value; } }

        /// <summary>If a single bag is to be supplied over 48 hours rather than standard 24 hours (all values and calculations are still expressed as 24 Hours)</summary>
        public bool Supply48Hours { get { return FieldToBoolean(RawRow["Supply48Hours"]).Value; } }

        /// <summary>If the aqueous and lipid parts of the infusion are combined</summary>
        public bool? IsCombined { get { return FieldToBoolean(RawRow["IsCombined"]);  } }

        ///// <summary>This is the prescriber's suggested hours for aqueous or combined part of the regimen</summary>
        //public double? InfusionHoursAqueousOrCombined { get { return FieldToDouble(RawRow["InfusionHoursAqueousOrCombined"]);  } }

        ///// <summary>This is the prescriber's suggested hours for lipid part of the regimen</summary>
        //public double? InfusionHoursLipid { get { return FieldToDouble(RawRow["InfusionHoursLipid"]);  } }
        #endregion

        #region Ingredients
        /// <summary>Prescriptions suggested volume in ml.</summary>
        public double? VolumeInml { get { return FieldToDouble(RawRow["Volume_ml"]);  } }
        
        /// <summary>Gets prescriptions suggested ingredeint value</summary>
        public double? GetIngredient(string dbName) 
        { 
            return FieldToDouble(RawRow[dbName]);
        }

        /// <summary>Sets prescriptions suggested ingredient value</summary>
        public void SetIngredient(string dbName, double? value)
        {
            RawRow[dbName] = DoubleToField(value);
        }
        #endregion

        #region prescription items
        /// <summary>Reads PNRegimenItem from db from PNPrescriptionProductVolume table</summary>
        public IEnumerable<PNRegimenItem> GetPrescriptionItems()
        {
            PNProduct products = new PNProduct();

            // Load PNRegimenProductVolume items 
            PNPrescriptionProductVolume items = new PNPrescriptionProductVolume();
            if (this.RawRow["RequestID"] != DBNull.Value)
                items.LoadByRequestID(this.RequestID);

            // Converts PNPrescriptionProductVolume to PNRegimenItem
            List<PNRegimenItem> newItems = new List<PNRegimenItem>();
            foreach (PNPrescriptionProductVolumeRow dbitem in items)
            {
                // Load drug individually as may not be on same site as where the prescription was raised.
                products.LoadByID(dbitem.PNProductID);
                if (products.Any())
                    newItems.Add(new PNRegimenItem(products[0].PNCode, dbitem.VolumeInml));
            }

            return newItems;
        }
        #endregion

        /// <summary>Returns the Prescription.Description_FreeTextDirection information (loaded from db)</summary>
        public string GetFreeTextDirection()
        {
            return Database.ExecuteSQLScalar<string>("SELECT ISNULL(Description_FreeTextDirection, '') FROM Prescription WHERE RequestID={0}", this.RequestID);
        }

        public string GetDispensingInstruction()
        {
            return Database.ExecuteSQLScalar<string>("SELECT Detail FROM DispensingInstruction di JOIN RequestLinkAttachedNote rlan ON di.NoteID=rlan.NoteID WHERE RequestID={0}", this.RequestID) ?? string.Empty;
        }

        public bool CanCancel(out string reason)
        {
            reason = string.Empty;
            return true;
        }
    }

    /// <summary>Provides column information about the PNPrescription table (inherits from EpisodeOrderColumnInfo)</summary>
    public class PNPrescritpionColumnInfo : BaseColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="PNPrescritpionColumnInfo"/> class.</summary>
        public PNPrescritpionColumnInfo() : base("PNPrescription") { }
        // public PNPrescritpionColumnInfo() : base("PNPrescritpion") { }  24Sep15 XN 77778 fixed typo
    }

    /// <summary>Represents the PNPrescrtiption table</summary>
    public class PNPrescrtiption : BaseTable2<PNPrescriptionRow, PNPrescritpionColumnInfo>
    {
        public PNPrescrtiption() : base("PNPrescription", "Prescription", "EpisodeOrder", "Request") { }

        #region Public Methods
        public void LoadByRequestID(int requestID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@RequestID", requestID));
            LoadBySP("pPNPrescriptionByRequestID", parameters);
        }

        public static PNPrescriptionRow GetByRequestID(int requestID)
        {
            PNPrescrtiption request = new PNPrescrtiption();
            request.LoadByRequestID(requestID);
            return request.Any() ? request[0] : null;
        }
        #endregion
    }
}
