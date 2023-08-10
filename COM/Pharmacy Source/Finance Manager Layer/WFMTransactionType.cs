//===========================================================================
//
//							   WFMTransactionType.cs
//
//	Provides functions for writing to the WFMTransactionType table
//  Used by finance manager
//
//  Holds list of WOrderlog, or WTranslog kinds with description.
//  Used to provide a more descriptive info about a kind rather than singe letter code.
//
//  Supports reading, inserting, and updating.
//  
//	Modification History:
//	23Apr13 XN  Written 53147
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.financemanagerlayer
{
    /// <summary>Represents a row in the WFMTransactionType table</summary>
    public class WFMTransactionTypeRow : BaseRow
    {
        public int WFMTransactionTypeID
        {
            get { return (int)FieldToInt(RawRow["WFMTransactionTypeID"]); }
        }

        public PharmacyLogType PharmacyLog
        {
            get { return FieldToEnumByDBCode<PharmacyLogType>(RawRow["PharmacyLog"]);  }
            set { RawRow["PharmacyLog"] = EnumToFieldByDBCode<PharmacyLogType>(value); }
        }

        public string Kind
        {
            get { return FieldToStr(RawRow["Kind"], true, string.Empty); }
            set { RawRow["Kind"] = StrToField(value, true);              }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"], true, string.Empty); }
            set { RawRow["Description"] = StrToField(value, true);              }
        }

        /// <summary>Returns {Kind} - {Description}</summary>
        public override string ToString()
        {
 	        return string.Format("{0} - {1}", Kind, Description);
        }
    }

    /// <summary>Provides column information about the WFMTransactionType table</summary>
    public class WFMTransactionTypeColumnInfo : BaseColumnInfo
    {
        public WFMTransactionTypeColumnInfo() : base("WFMTransactionType") { }

        public int DescriptionLength { get { return base.FindColumnByName("Description").Length; } }
        public int KindLength        { get { return base.FindColumnByName("Kind").Length;        } }
    }


    /// <summary>Represent the WFMTransactionType table</summary>
    public class WFMTransactionType : BaseTable2<WFMTransactionTypeRow, WFMTransactionTypeColumnInfo>
    {
        /// <summary>Constructor</summary>
        public WFMTransactionType() : base("WFMTransactionType") { }


        /// <summary>Load all FM Log types</summary>
        public void LoadAll()
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            LoadBySP("pWFMTransactionTypeAll", parameters);
        }

        /// <summary>Loads the transaction type by logTypeID</summary>
        public void LoadByID(int transactionTypeID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("WFMTransactionTypeID", transactionTypeID));
            LoadBySP("pWFMTransactionTypeByID", parameters);
        }

        /// <summary>Loads all the transaction types, for a specific log</summary>
        /// <param name="logType">Orderlog, or translog</param>
        public void LoadByPharmacyLogType(PharmacyLogType logType)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@PharmacyLog", EnumDBCodeAttribute.EnumToDBCode(logType)));
            LoadBySP("pWFMTransactionTypeByPharmacyLogType", parameters);
        }

        /// <summary>Returns transaction type by transactionTypeID, or null if does not exist</summary>
        public static WFMTransactionTypeRow GetByID(int transactionTypeID)
        {
            WFMTransactionType logType = new WFMTransactionType();
            logType.LoadByID(transactionTypeID);
            return logType.FirstOrDefault();
        }
    }
}
