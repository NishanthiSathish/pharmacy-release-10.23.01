using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.icwdatalayer
{
    public class SupplyRequestRow : EpisodeOrderRow
    {
        public int SupplyRequestTypeID
        {
            get { return FieldToInt(RawRow["SupplyRequestTypeID"]).Value; }
            set { RawRow["SupplyRequestTypeID"] = IntToField(value); }
        }
        
        public int ProductID_Mapped
        {
            get { return FieldToInt(RawRow["ProductID_Mapped"]).Value; }
            set { RawRow["ProductID_Mapped"] = IntToField(value); }
        }

        public bool IsVirtualProduct
        {
            get { return FieldToBoolean(RawRow["IsVirtualProduct"]).Value; }
            set { RawRow["IsVirtualProduct"] = BooleanToField(value); }
        }

        public decimal? QuantityRequested
        {
            get { return FieldToDecimal(RawRow["QuantityRequested"]); }
            set { RawRow["QuantityRequested"] = DecimalToField(value); }
        }

        public int? FormID_Quantity
        {
            get { return FieldToInt(RawRow["FormID_Quantity"]); }
            set { RawRow["FormID_Quantity"] = IntToField(value); }
        }

        public int? UnitID_Quantity
        {
            get { return FieldToInt(RawRow["UnitID_Quantity"]); }
            set { RawRow["UnitID_Quantity"] = IntToField(value); }
        }

        public int? PackageID_Quantity
        {
            get { return FieldToInt(RawRow["PackageID_Quantity"]); }
            set { RawRow["PackageID_Quantity"] = IntToField(value); }
        }

        public int? DaysRequested
        {
            get { return FieldToInt(RawRow["DaysRequested"]); }
            set { RawRow["DaysRequested"] = IntToField(value); }
        }
    }

    public class SupplyRequestColumnInfo : EpisodeOrderColumnInfo
    {
        public SupplyRequestColumnInfo() : base("SupplyRequest") { }

        public SupplyRequestColumnInfo(string inheritiedTableName) : base(inheritiedTableName) { }
    }

    public class SupplyRequestBaseTable<T, C> : BaseTable2<T, C>
        where T : SupplyRequestRow, new()
        where C : SupplyRequestColumnInfo, new()
    {
        public SupplyRequestBaseTable(string tableName, params string[] inhertiedTableNames) : base(tableName, inhertiedTableNames) { }

        #region Protected Methods
        /// <summary>Get the Supply Request by description</summary>
        protected virtual ICWTypeData GetSupplyRequestType()
        {
            ICWTypeData? requestType = ICWTypes.GetTypeByDescription(ICWType.SupplyRequest, "Supply Request");
            if (requestType == null)
                throw new ApplicationException("'Supply Request' type info is not in RequestType table.");
            return requestType.Value;
        }
        #endregion
    }
}
