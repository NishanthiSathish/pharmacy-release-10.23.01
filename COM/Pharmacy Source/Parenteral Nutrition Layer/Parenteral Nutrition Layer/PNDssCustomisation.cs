//===========================================================================
//
//							     PNDssCustomisation.cs
//
//  Provides access to PNDssCustomisation table. 
//
//  This table holds customer specific variations of PN data (PNProduct or PNRule)
//  maintained by DSS.
//
//  Only supports reading, inserting, and updating.
//
//	Modification History:
//	09Mar12 XN Written
//  15May12 XN Updates for DSS on the Web  TFS32067 
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    public class PNDssCustomisationRow : BaseRow
    {
	    public int PNDssCustomisationID
        {
            get { return FieldToInt(RawRow["PNDssCustomisationID"]).Value; }
        }

        public Guid CustomerID
        {
            get { return FieldToGuid(RawRow["CustomerID"]).Value; }
            set { RawRow["CustomerID"] = GuidToField(value);      }
        }

        public int TableID
        {
            get { return FieldToInt(RawRow["TableID"]).Value; }
            set { RawRow["TableID"] = IntToField(value);      }
        }

        public int? PNProductID
        {
            get { return FieldToInt(RawRow["PNProductID"]);  }
            set { RawRow["PNProductID"] = IntToField(value); }
        }

        public int? PNRuleID
        {
            get { return FieldToInt(RawRow["PNRuleID"]);  }
            set { RawRow["PNRuleID"] = IntToField(value); }
        }

        public string ParameterName
        {
            get { return FieldToStr(RawRow["ParameterName"], true, string.Empty); }
            set { RawRow["ParameterName"] = StrToField(value);                    }
        }

        public string Value
        {
            get { return FieldToStr(RawRow["Value"], true, string.Empty); }
            set { RawRow["Value"] = StrToField(value);                    }
        }

        public DateTime LastModDate
        {
            get { return FieldToDateTime(RawRow["LastModDate"]).Value;  }
            set { RawRow["LastModDate"] = DateTimeToField(value);       }
        }

        public string LastModUser
        {
            get { return FieldToStr(RawRow["LastModUser"], true, string.Empty); }
            set { RawRow["LastModUser"] = StrToField(value);                    }
        }

        public string LastModTerm
        {
            get { return FieldToStr(RawRow["LastModTerm"], true, string.Empty); }
            set { RawRow["LastModTerm"] = StrToField(value);                    }
        }

        public string ExtraInfo
        {
            get { return FieldToStr(RawRow["ExtraInfo"], false, string.Empty); }
            set { RawRow["ExtraInfo"] = StrToField(value);                     }
        }

        public bool _Deleted    // TFS32067 15May12 XN
        {
            get { return FieldToBoolean(RawRow["_Deleted"], false).Value; }
            set { RawRow["_Deleted"] = BooleanToField(value);             }
        }
    }

    public class PNDssCustomisationColumnInfo : BaseColumnInfo
    {
        public PNDssCustomisationColumnInfo() : base("PNDssCustomisation") { }

        public int ParameterNameLength  { get { return base.FindColumnByName("ParameterName").Length; } }
        public int LastModUserLength    { get { return base.FindColumnByName("LastModUser").Length;   } }
        public int LastModTermLength    { get { return base.FindColumnByName("LastModTerm").Length;   } }
    }

    public class PNDssCustomisation : BaseTable2<PNDssCustomisationRow, PNDssCustomisationColumnInfo>
    {
        public PNDssCustomisation() : base("PNDssCustomisation") 
        { 
            this.ConflictOption = System.Data.ConflictOption.CompareAllSearchableValues;
        }

        /// <summary>Load PN Dss customisation by parameter name</summary>
        /// <param name="tableID">Table (normaly PNProduct of PNRule</param>
        /// <param name="pnProductID">PN Product ID</param>
        /// <param name="parameterName">Parameter name to load</param>
        /// <param name="includeDeleted">If to inlcude deleted items</param>
        public void LoadByTableIDPNProductIDAndParameterName(int tableID, int pnProductID, string parameterName, bool includeDeleted)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@TableID",       tableID     ));
            parameters.Add(new SqlParameter("@PNProductID",   pnProductID ));
            parameters.Add(new SqlParameter("@ParameterName", parameterName));
            parameters.Add(new SqlParameter("@IncludeDeleted",includeDeleted));
            LoadBySP("pPNDssCustomisationByTableIDPNProductIDAndParameterName", parameters);
        }

        /// <summary>Load PN Dss customisation by parameter name</summary>
        /// <param name="tableID">Table (normaly PNProduct of PNRule</param>
        /// <param name="pnRuleID">PN Rule ID</param>
        /// <param name="parameterName">Parameter name to load</param>
        /// <param name="includeDeleted">If to inlcude deleted items</param>
        public void LoadByTableIDPNRuleIDAndParameterName(int tableID, int pnRuleID, string parameterName, bool includeDeleted)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@TableID",       tableID     ));
            parameters.Add(new SqlParameter("@PNRuleID",      pnRuleID    ));
            parameters.Add(new SqlParameter("@ParameterName", parameterName));
            parameters.Add(new SqlParameter("@IncludeDeleted",includeDeleted));
            LoadBySP("pPNDssCustomisationByTableIDPNRuleIDAndParameterName", parameters);
        }
    }

    /// <summary>Provides extension methods to IEnumerable{PNDssCustomisationRow} class</summary>
    public static class PNDSSCustomisationExtensions
    {
        public static IEnumerable<PNDssCustomisationRow> FindByCustomerID(this IEnumerable<PNDssCustomisationRow> items, Guid customerID)
        {
            return items.Where(c => c.CustomerID == customerID);
        }
    }
}
