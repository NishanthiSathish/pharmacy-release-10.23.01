//===========================================================================
//
//							    PNRegimenProductVolume.cs
//
//  Provides access to PNRegimenProductVolume table (hold the PN Regimen products and items). 
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
    /// <summary>Represents a row in the PNRegimenProductVolume table</summary>
    internal class PNRegimenProductVolumeRow : BaseRow
    {
        public int PNRegimenProductVolumeID
        {
            get { return FieldToInt(RawRow["PNRegimenProductVolumeID"]).Value; }
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

        public double TotalVolumeIncOverage
        { 
            get { return FieldToDouble(RawRow["TotalVolumeIncOverage"]).Value;  }
            set { RawRow["TotalVolumeIncOverage"] = FieldToDouble(value);       }
        }
    }

    /// <summary>Provides column information about the PNRegimenProductVolume table</summary>
    internal class PNRegimenProductVolumeColumnInfo : BaseColumnInfo
    {
        public PNRegimenProductVolumeColumnInfo() : base("PNRegimenProductVolume") { }
    }

    /// <summary>Represents the PNRegimenProductVolume table</summary>
    internal class PNRegimenProductVolume : BaseTable2<PNRegimenProductVolumeRow, PNRegimenProductVolumeColumnInfo>
    {
        public PNRegimenProductVolume() : base("PNRegimenProductVolume") { }

        #region Public Methods
        public void LoadByRequestID(int requestID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@RequestID", requestID));
            LoadBySP("pPNRegimenProductVolumeByRequestID", parameters);
        }

        /// <summary>Returns first PNRegimenProductVolume with specified PNProductID (or null if it does not exists)</summary>
        public PNRegimenProductVolumeRow FindByPNProductID(int pnProductID)
        {
            return this.FirstOrDefault(p => p.PNProductID == pnProductID);
        }
        #endregion
    }
}
