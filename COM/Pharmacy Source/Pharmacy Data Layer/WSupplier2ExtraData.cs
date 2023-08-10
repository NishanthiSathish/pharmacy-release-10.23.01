//===========================================================================
//
//							  WSupplier2ExtraDataExtraData.cs
//
//  Provides access to WSupplier2ExtraDataExtraData table (holds extra details about supplier)
//  This replaces the WExtraSupplierData table for WSupplier.SupplierType = 'E', 'S'
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
using System.Web.UI;

namespace ascribe.pharmacy.pharmacydatalayer
{
    public class WSupplier2ExtraDataRow : BaseRow
    {
        public int WSupplier2ID
        {
            get { return FieldToInt(RawRow["WSupplier2ID"]).Value; }
            set { RawRow["WSupplier2ID"] = IntToField(value);      }
        }

        public string Notes
        {
            get { return FieldToStr(RawRow["Notes"], false, string.Empty); }
            set { RawRow["Notes"] = StrToField(value);                     }
        }

        public string CurrentContractData
        {
            get { return FieldToStr(RawRow["CurrentContractData"], false, string.Empty); }
            set { RawRow["CurrentContractData"] = StrToField(value);                     }
        }

        public string NewContractData
        {
            get { return FieldToStr(RawRow["NewContractData"], false, string.Empty); }
            set { RawRow["NewContractData"] = StrToField(value);                     }
        }

        public DateTime? DateOfChange
        {
            get { return FieldStrDateToDateTime(RawRow["DateOfChange"], DateType.DD_MM_YYYY);                     }
            set { RawRow["DateOfChange"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DD_MM_YYYY, '/'); }
        }
    }

    public class WSupplier2ExtraDataColumnInfo : BaseColumnInfo
    {
        public WSupplier2ExtraDataColumnInfo() : base ("WSupplier2ExtraData") {  }

        public int CurrentContractDataLength{ get { return FindColumnByName("CurrentContractData").Length;  } }
        public int NewContractDataLength    { get { return FindColumnByName("NewContractData").Length;      } }
        public int NotesLength              { get { return FindColumnByName("Notes").Length;                } }
    }

    public class WSupplier2ExtraData : BaseTable2<WSupplier2ExtraDataRow, WSupplier2ExtraDataColumnInfo>
    {
        public WSupplier2ExtraData() : base ("WSupplier2ExtraData")  { }

        /// <summary>Load row by WSupplier2ExtraDataID</summary>
        public void LoadByID(int WSupplier2ID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("WSupplier2ID", WSupplier2ID);
            LoadBySP("pWSupplier2ExtraDataByID", parameters);
        }

        public static WSupplier2ExtraDataRow GetByID(int WSupplier2ID)
        {
            WSupplier2ExtraData sup = new WSupplier2ExtraData();
            sup.LoadByID(WSupplier2ID);
            return sup.FirstOrDefault();
        }
    }
}
