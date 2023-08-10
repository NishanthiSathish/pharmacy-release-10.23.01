//===========================================================================
//
//							    PNStandardRegimenPNCodeVolume.cs
//
//  Provides access to PNStandardRegimenPNCodeVolume table 
//  (hold the PN Regimen products and items). 
//
//  Only supports reading, updating, and inserting.
//
//	Modification History:
//	19Feb11 XN Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using System.Data.SqlClient;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    /// <summary>Represents a row in the PNStandardRegimenPNCodeVolume table</summary>
    internal class PNStandardRegimenPNCodeVolumeRow : BaseRow
    {
        public int PNStandardRegimenPNCodeVolumeID
        {
            get { return FieldToInt(RawRow["PNStandardRegimenPNCodeVolume"]).Value; }
        }

        public int PNStandardRegimenID 
        { 
            get { return FieldToInt(RawRow["PNStandardRegimenID"]).Value;  }
            set { RawRow["PNStandardRegimenID"] = FieldToInt(value);       }
        }

        public string PNCode
        { 
            get { return FieldToStr(RawRow["PNCode"], true, string.Empty);  }
            set { RawRow["PNCode"] = FieldToStr(value); }
        }

        public double Volume
        { 
            get { return FieldToDouble(RawRow["Volume"]).Value;  }
            set { RawRow["Volume"] = FieldToDouble(value);       }
        }
    }

    /// <summary>Provides column information about the PNStandardRegimenPNCodeVolume table</summary>
    internal class PNStandardRegimenPNCodeVolumeColumnInfo : BaseColumnInfo
    {
        public PNStandardRegimenPNCodeVolumeColumnInfo() : base("PNStandardRegimenPNCodeVolume") { }
    }

    /// <summary>Represents the PNStandardRegimenPNCodeVolume table</summary>
    internal class PNStandardRegimenPNCodeVolume : BaseTable2<PNStandardRegimenPNCodeVolumeRow, PNStandardRegimenPNCodeVolumeColumnInfo>
    {
        public PNStandardRegimenPNCodeVolume() : base("PNStandardRegimenPNCodeVolume") { }

        #region Public Methods
        public void LoadByPNStandardRegimenID(int requestID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@PNStandardRegimenID", requestID));
            LoadBySP("pPNStandardRegimenPNCodeVolumeByPNStandardRegimenID", parameters);
        }

        /// <summary>Returns first PNRegimenProductVolume with specified PNProductID (or null if it does not exists)</summary>
        public PNStandardRegimenPNCodeVolumeRow FindByPNCode(string PNCode)
        {
            return this.FirstOrDefault(p => p.PNCode == PNCode);
        }

        public static PNStandardRegimenPNCodeVolumeRow GetByID(int PNStandardRegimenID)
        {
            PNStandardRegimenPNCodeVolume standardRegimen = new PNStandardRegimenPNCodeVolume();
            standardRegimen.LoadByPNStandardRegimenID(PNStandardRegimenID);
            return standardRegimen.Any() ? standardRegimen[0] : null;
        }
        #endregion
    }
}
