//===========================================================================
//
//							  WCustomerExtraData.cs
//
//  Provides access to WCustomerExtraData table (holds extra details about customers/wards)
//  This replaces the WExtraSupplierData table for WSupplier.SupplierType = 'W'
//
//  Only supports reading, updating, and inserting from table.
//  
//	Modification History:
//	27Jun14 XN  Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
using System.Data.SqlClient;

namespace ascribe.pharmacy.pharmacydatalayer
{
    public class WCustomerExtraDataRow : BaseRow
    {
        public int WCustomerID
        {
            get { return FieldToInt(RawRow["WCustomerID"]).Value; }
            set { RawRow["WCustomerID"] = IntToField(value);      }
        }

        public string Notes
        {
            get { return FieldToStr(RawRow["Notes"], true, string.Empty); }
            set { RawRow["Notes"] = StrToField(value);                     }
        }
    }

    public class WCustomerExtraDataColumnInfo : BaseColumnInfo
    {
        public WCustomerExtraDataColumnInfo() : base ("WCustomerExtraData") {  }

        public int NotesLength { get { return FindColumnByName("Notes").Length; } }
    }

    public class WCustomerExtraData : BaseTable2<WCustomerExtraDataRow, WCustomerExtraDataColumnInfo>
    {
        public WCustomerExtraData() : base ("WCustomerExtraData")  { }

        /// <summary>Load row by WCustomerID</summary>
        public void LoadByID(int WCustomerID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("WCustomerID", WCustomerID);
            LoadBySP("pWCustomerExtraDataByID", parameters);
        }

        public static WCustomerExtraDataRow GetByID(int WCustomerID)
        {
            WCustomerExtraData customers = new WCustomerExtraData();
            customers.LoadByID(WCustomerID);
            return customers.FirstOrDefault();
        }
    }
}
