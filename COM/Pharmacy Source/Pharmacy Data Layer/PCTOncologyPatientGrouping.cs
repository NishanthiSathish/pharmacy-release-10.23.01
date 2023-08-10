//===========================================================================
//
//							PCTOncologyType.cs
//
//  This class is a read only class for representing patient episodes
//
//	Modification History:
//	23Nov11 AKK  Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>
    /// Represents a row in the Episode table
    /// </summary>
    public class PCTOncologyPatientGroupingRow : BaseRow
    {
        public int PCTOncolologyPatientGroupingID { get { return FieldToInt(RawRow["PCTOncologyPatientGroupingID"]).Value; } }
        public int Code { get { return FieldToInt(RawRow["Code"]).Value; } }
        public string Description { get { return FieldToStr(RawRow["Description"]); } }
    }

    /// <summary>
    /// Constructor
    /// </summary>
    public class PCTOncologyPatientGroupingColumnInfo : BaseColumnInfo
    {
        public PCTOncologyPatientGroupingColumnInfo() : base("PCTOncologyPatientGrouping") { }
    }

    /// <summary>
    /// Represents the PCTOncologyPatientGroup table
    /// </summary>
    public class PCTOncologyPatientGrouping : BaseTable<PCTOncologyPatientGroupingRow, PCTOncologyPatientGroupingColumnInfo>
    {
        public PCTOncologyPatientGrouping() : base("PCTOncologyPatientGrouping", "PCTOncologyPatientGroupingID") { }

        public void LoadAll()
        {
            StringBuilder parameters = new StringBuilder();
            LoadRecordSetStream("pPCTOncologyPatientGroupingAll", parameters);
        }

    }
}

