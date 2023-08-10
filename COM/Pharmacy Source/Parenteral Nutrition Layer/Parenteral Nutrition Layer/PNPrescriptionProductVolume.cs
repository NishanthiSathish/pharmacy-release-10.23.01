//===========================================================================
//
//							PNPrescriptionProductVolume.cs
//
//  Provides access to PNPrescriptionProductVolume table (hold the PN Regimen products and items). 
//
//  Class is derived from EpisodeOrder (and then Request).
//
//  SP for this object should return all fields from EpisodeOrder, and Request, table.
//
//  Only supports reading, updating, and inserting.
//
//	Modification History:
//	19Dec11 XN Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using System.Data.SqlClient;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    /// <summary>Represents a row in the PNPrescriptionProductVolume table</summary>
    internal class PNPrescriptionProductVolumeRow : BaseRow
    {
        public int PNPrescriptionProductVolumeID
        {
            get { return FieldToInt(RawRow["PNPrescriptionProductVolumeID"]).Value; }
        }

        public int RequestID 
        { 
            get { return FieldToInt(RawRow["RequestID"]).Value;  }
            set { RawRow["RequestID"] = FieldToInt(value);       }
        }

        public int PNProductID
        { 
            get { return FieldToInt(RawRow["PNProductID"]).Value;  }
            set { RawRow["PNProductID"] = FieldToInt(value);       }
        }

        public double VolumeInml
        { 
            get { return FieldToDouble(RawRow["Volume_mL"]).Value;  }
            set { RawRow["Volume_mL"] = FieldToDouble(value);       }
        }
    }

    /// <summary>Provides column information about the PNPrescriptionProductVolume table</summary>
    internal class PNPrescriptionProductVolumeColumnInfo : BaseColumnInfo
    {
        public PNPrescriptionProductVolumeColumnInfo() : base("PNPrescriptionProductVolume") { }
    }

    /// <summary>Represents the PNPrescriptionProductVolume table</summary>
    internal class PNPrescriptionProductVolume : BaseTable2<PNPrescriptionProductVolumeRow, PNPrescriptionProductVolumeColumnInfo>
    {
        public PNPrescriptionProductVolume() : base("PNPrescriptionProductVolume") { }

        #region Public Methods
        public void LoadByRequestID(int requestID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@RequestID", requestID));
            LoadBySP("pPNPrescriptionProductVolumeByRequestID", parameters);
        }

        /// <summary>Returns first PNPrescriptionProductVolume with specified PNProductID (or null if it does not exists)</summary>
        public PNPrescriptionProductVolumeRow FindByPNProductID(int pnProductID)
        {
            return this.FirstOrDefault(p => p.PNProductID == pnProductID);
        }
        #endregion
    }
}
