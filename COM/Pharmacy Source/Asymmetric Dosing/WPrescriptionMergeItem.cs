//===========================================================================
//
//							  WPrescriptionMergeItem.cs
//
//  Provides access to WPrescriptionMergeItem table.
//
//  WPrescriptionMergeItem table holds information about asymmetric linked prescriptions.
//  A single asymmetric linked prescription will have a number of WPrescriptionMergeItem 
//  items linked to a single WPrescriptionMerge request
//
//  Only supports reading, and inserting.
//
//	Modification History:
//	05Jul11 XN Written (F0041502)
//  15Jul11 XN Added IndexOrder to WPrescriptMergeItem table
//===========================================================================
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.asymmetricdosing
{
    /// <summary>Represents a row in the WPrescriptionMergeItem table</summary>
    public class WPrescriptionMergeItemRow : BaseRow
    {
        public int WPrescriptionMergeItem
        {
            get { return FieldToInt(RawRow["WPrescriptionMergeItem"]).Value;  }
        }

        public int RequestID_Prescription
        {
            get { return FieldToInt(RawRow["RequestID_Prescription"]).Value;  }
            set { RawRow["RequestID_Prescription"] = IntToField(value); }
        }

        public int RequestID_WPrescriptionMerge
        {
            get { return FieldToInt(RawRow["RequestID_WPrescriptionMerge"]).Value;  }
            set { RawRow["RequestID_WPrescriptionMerge"] = IntToField(value);       }
        }

        public int IndexOrder
        {
            get { return FieldToInt(RawRow["IndexOrder"]).Value;  }
            set { RawRow["IndexOrder"] = IntToField(value); }
        }

        public bool Active
        {
            get { return FieldToBoolean(RawRow["Active"]).Value;  }
            set { RawRow["Active"] = BooleanToField(value);       }
        }
    }

    /// <summary>Provides column information about the WPrescriptionMergeItem table</summary>
    public class WPrescriptionMergeItemColumnInfo : BaseColumnInfo
    {
        public WPrescriptionMergeItemColumnInfo() : base("WPrescriptionMergeItem") { }
    }

    /// <summary>Represent the WPrescriptionMergeItem table</summary>
    public class WPrescriptionMergeItem : BaseTable<WPrescriptionMergeItemRow, WPrescriptionMergeItemColumnInfo>
    {
        public WPrescriptionMergeItem() : base("WPrescriptionMergeItem", "WPrescriptionMergeItemID") { }

        /// <summary>Returns true if prescription request is in an active merged prescription</summary>
        /// <param name="requestID">Prescription request</param>
        /// <returns>If prescription is in an active merged prescription</returns>
        public static bool IsMergedPrescription(int requestID)
        {
            StringBuilder parameters = new StringBuilder();
            WPrescriptionMergeItem table = new WPrescriptionMergeItem();

            table.AddInputParam(parameters, "RequestID_Prescription", requestID);
            return (table.ExecuteScalar("pWPrescriptionMergeItemIDByRequestIDAndActive", parameters) > 0);
        }

        /// <summary>Will set Active flag for all WPrescriptionMergeItem's with specified RequestID to 0</summary>
        /// <param name="requestID_WPrescriptionMerge">Request to deactivate</param>
        public static void Deativate(int requestID_WPrescriptionMerge) 
        { 
            StringBuilder parameters = new StringBuilder();

            WPrescriptionMergeItem item = new WPrescriptionMergeItem();
            item.AddInputParam(parameters, "RequestID_WPrescriptionMerge", requestID_WPrescriptionMerge);

            item.ExecuteScalar("pWPrescriptionMergeItemDeactivate", parameters);
        }
    }
}
