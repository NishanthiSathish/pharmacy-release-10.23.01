//===========================================================================
//
//							WSupplier.cs
//
//  This class represents the WSupplier table in the Pharmacy Data Layer.
//
//  Only supports reading
//
//  Usage:
//
//  WSupplier dbsupplier = new WSupplier();
//  dbsupplier.LoadByCodeAndSiteID(supplier.Code, siteID);
//  dbsupplier[0].Name = supplier.Name;
//  dbsupplier.Save();
//      
//	Modification History:
//	14Apr09 AK  Written
//  24Apr13 XN  Add methods LoadBySupplierID and GetBySearchText (53147)
//  17Jul13 XN  Changed from BaseTable to BaseTable2, added 
//              WSupplierRow.PSOSupplier and WSupplier.LoadBySiteIDAndSupplierTypes
//  24Jul13 XN  24653 Added LoadByWSupplierID and GetByWSupplierID
//  01Aug13 XN  24653 Added GetBySupCodeAndSite
//  04Jul14 XN  Replaced WSupplier with WCustomer, WSupplier2, and WWardProductList (so made WWardStockList Obsolete)
//	31Oct14 XN  Written 102842 Added ToNameString
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
    /// <summary>
    /// SupplierRow represents a single row in WSupplier and inherits from basedatalayer.BaseRow and contains all properties for all WSupplier fields which needs to be read/set
    /// </summary>
    [Obsolete("Uses WCustomerRow, WSupplier2Row, and WWardProductListRow instead")]
    public class WSupplierRow : BaseRow
    {
        public int? SupplierID
        {
            get { return FieldToInt(RawRow["WSupplierID"]); }
        }

        public string CostCentre
        {
            get { return FieldToStr(RawRow["CostCentre"], false, string.Empty);  }
            set { RawRow["CostCentre"] = StrToField(value); }
        }

        public string Name
        {
            get { return FieldToStr(RawRow["Name"], false, string.Empty); }
            set { RawRow["Name"] = StrToField(value ?? string.Empty); }
        }

        public string FullName
        {
            get { return FieldToStr(RawRow["FullName"], false, string.Empty); }
            set { RawRow["FullName"] = StrToField(value ?? string.Empty); }
        }

        public bool? InUse
        {
            get { return FieldToBoolean(RawRow["InUse"]); }
            set { RawRow["InUse"] = BooleanToField(value); }
        }

        public string Code
        {
            // get { return FieldToStr(RawRow["Code"], false, string.Empty); } 24653 17Jul13 XN
            get { return FieldToStr(RawRow["Code"], true, string.Empty); }
            set { RawRow["Code"] = StrToField(value); }
        }

        public string ContractAddress
        {
            get { return FieldToStr(RawRow["ContractAddress"], false, string.Empty); }
            set { RawRow["ContractAddress"] = StrToField(value); }
        }

        public string SupAddress
        {
            //get { return FieldToStr(RawRow["SupAddress"], false, string.Empty); } 24653 17Jul13 XN
            get { return FieldToStr(RawRow["SupAddress"], true, string.Empty); } 
            set { RawRow["SupAddress"] = StrToField(value); }
        }

        public string InvAddress
        {
            get { return FieldToStr(RawRow["InvAddress"], false, string.Empty); }
            set { RawRow["InvAddress"] = StrToField(value); }
        }

        public string ContTelNo
        {
            get { return FieldToStr(RawRow["ContTelNo"], false, string.Empty); }
            set { RawRow["ContTelNo"] = StrToField(value); }
        }

        public string SupTelNo
        {
            get { return FieldToStr(RawRow["SupTelNo"], false, string.Empty); }
            set { RawRow["SupTelNo"] = StrToField(value); }
        }

        public string InvTelNo
        {
            get { return FieldToStr(RawRow["InvTelNo"], false, string.Empty); }
            set { RawRow["InvTelNo"] = StrToField(value); }
        }

        public string DiscountDesc
        {
            get { return FieldToStr(RawRow["DiscountDesc"], false, string.Empty); }
            set { RawRow["DiscountDesc"] = StrToField(value); }
        }

        public string DiscountVal
        {
            get { return FieldToStr(RawRow["DiscountVal"], false, string.Empty); }
            set { RawRow["DiscountVal"] = StrToField(value); }
        }

        public SupplierMethod Method
        {
            get { return FieldToEnumByDBCode<SupplierMethod>(RawRow["Method"]); }
            set { RawRow["Method"] = EnumToFieldByDBCode(value); }
        }

        public string OrdMessage
        {
            get { return FieldToStr(RawRow["OrdMessage"], false, string.Empty); }
            set { RawRow["OrdMessage"] = StrToField(value); }
        }

        public string AvLeadTime
        {
            get { return FieldToStr(RawRow["AvLeadTime"], false, string.Empty); }
            set { RawRow["AvLeadTime"] = StrToField(value); }
        }

        public string ContFaxNo
        {
            get { return FieldToStr(RawRow["ContFaxNo"], false, string.Empty); }
            set { RawRow["ContFaxNo"] = StrToField(value); }
        }

        public string SupFaxNo
        {
            get { return FieldToStr(RawRow["SupFaxNo"], false, string.Empty); }
            set { RawRow["SupFaxNo"] = StrToField(value); }
        }

        public string InvFaxNo
        {
            get { return FieldToStr(RawRow["InvFaxNo"], false, string.Empty); }
            set { RawRow["InvFaxNo"] = StrToField(value); }
        }

        public string Ptn
        {
            get { return FieldToStr(RawRow["Ptn"], false, string.Empty); }
            set { RawRow["Ptn"] = StrToField(value); }
        }

        public string PSis
        {
            get { return FieldToStr(RawRow["PSis"], false, string.Empty); }
            set { RawRow["PSis"] = StrToField(value); }
        }

        public string DiscountBelow
        {
            get { return FieldToStr(RawRow["DiscountBelow"], false, string.Empty); }
            set { RawRow["DiscountBelow"] = StrToField(value); }
        }

        public string DiscountAbove
        {
            get { return FieldToStr(RawRow["DiscountAbove"], false, string.Empty); }
            set { RawRow["DiscountAbove"] = StrToField(value); }
        }

        public string ICode
        {
            get { return FieldToStr(RawRow["ICode"], false, string.Empty); }
            set { RawRow["ICode"] = StrToField(value); }
        }

        public string PrintDeliveryNote
        {
            get { return FieldToStr(RawRow["PrintDeliveryNote"], false, string.Empty); }
            set { RawRow["PrintDeliveryNote"] = StrToField(value); }
        }

        public string PrintPickTicket
        {
            get { return FieldToStr(RawRow["PrintPickTicket"], false, string.Empty); }
            set { RawRow["PrintPickTicket"] = StrToField(value); }
        }

        public SupplierType Type
        {
            get { return FieldToEnumByDBCode<SupplierType>(RawRow["SupplierType"]); }
            set { RawRow["SupplierType"] = EnumToFieldByDBCode<SupplierType>(value); }
        }

        public string OrderOutput
        {
            get { return FieldToStr(RawRow["OrderOutput"], false, string.Empty); }
            set { RawRow["OrderOutput"] = StrToField(value); }
        }

        public string ReceiveGoods
        {
            get { return FieldToStr(RawRow["ReceiveGoods"], false, string.Empty); }
            set { RawRow["ReceiveGoods"] = StrToField(value); }
        }

        public string TopupInterval
        {
            get { return FieldToStr(RawRow["TopupInterval"], false, string.Empty); }
            set { RawRow["TopupInterval"] = StrToField(value); }
        }

        public string AtcSupplied
        {
            get { return FieldToStr(RawRow["AtcSupplied"], false, string.Empty); }
            set { RawRow["AtcSupplied"] = StrToField(value); }
        }

        public string TopupDate
        {
            get { return FieldToStr(RawRow["TopupDate"], false, string.Empty); }
            set { RawRow["TopupDate"] = StrToField(value); }
        }

        public string WardCode
        {
            // get { return FieldToStr(RawRow["WardCode"], false, string.Empty); } 24653 17Jul13 XN
            get { return FieldToStr(RawRow["WardCode"], true, string.Empty); }
            set { RawRow["WardCode"] = StrToField(value); }
        }

        public string OnCost
        {
            get { return FieldToStr(RawRow["OnCost"], false, string.Empty); }
            set { RawRow["OnCost"] = StrToField(value); }
        }

        public string InPatientDirections
        {
            get { return FieldToStr(RawRow["InPatientDirections"], false, string.Empty); }
            set { RawRow["InPatientDirections"] = StrToField(value); }
        }

        public string AdHocDelNote
        {
            get { return FieldToStr(RawRow["AdHocDelNote"], false, string.Empty); }
            set { RawRow["AdHocDelNote"] = StrToField(value); }
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value; }
            set { RawRow["SiteID"] = IntToField(value); }
        }

        public double? MinimumOrderValue
        {
            get { return FieldToDouble(RawRow["MinimumOrderValue"]);}
            set { RawRow["MinimumOrderValue"] = DoubleToField(value); }   
        }

        /// <summary>Returns if PSO supplier (DB field code [PSO] 24653 17Jul13 XN</summary>
        public bool PSOSupplier
        {
            get { return FieldToBoolean(RawRow["PSO"], false).Value;}
            set { RawRow["PSO"] = BooleanToField(value);            }   
        }

        /// <summary>Returns the supplier code - name</summary>
        public override string ToString()
        {
            return string.Format("{0} - {1}", this.Code, this.Name);
        }

        /// <summary>
        /// Returns supplier name (and address)
        /// SupplierNameType.ShortAndLongName
        ///     Description
        /// SupplierNameType.FullName
        ///     FullName\Description, Address
        /// SupplierNameType.Short
        ///     Description, Address
        ///     
        /// 31Oct14 XN  102842
        /// </summary>
        public string ToNameString(SupplierNameType supplierNameDisplayType)
        {
            switch (supplierNameDisplayType)
            {
            case SupplierNameType.ShortAndLongName : 
                return this.Name;   // This is correct as long name is then normally displayed separatley (so could do with improvment)
            case SupplierNameType.FullName :
                string name =  StringExtensions.IsNullOrEmptyAfterTrim(this.FullName) ? this.Name : this.FullName;
                return this.AppendNameAddess(name, this.SupAddress); 
            default:             
                return this.AppendNameAddess(this.Name, this.SupAddress); 
            }
        }

        /// <summary>Append the name and the address (with comma inbetween)</summary>
        private string AppendNameAddess(string name, string address)
        {
            string result = string.Empty;
            if (!string.IsNullOrEmpty(name))
                result += name.TrimEnd(new [] { '.' });
            if (!string.IsNullOrEmpty(address))
                result += ", " + address;
            return result;
        }
    }

    /// <summary>
    /// Provides column information for WSupplier, such as maximum field lengths
    /// </summary>
    [Obsolete("Uses WCustomerColumnInfo, WSupplier2ColumnInfo, and WWardProductListColumnInfo instead")]
    public class WSupplierColumnInfo : BaseColumnInfo
    {
        public WSupplierColumnInfo() : base("WSupplier")
        {
        }
        public int AddressLength { get { return tableInfo.GetFieldLength("ContractAddress"); } }
        public int CostCentreLength { get { return tableInfo.GetFieldLength("CostCentre"); } }
        public int NameLength { get { return tableInfo.GetFieldLength("Name"); } }
        public int FullNameLength { get { return tableInfo.GetFieldLength("FullName"); } }
        public int TelLength { get { return tableInfo.GetFieldLength("ContTelNo"); } }
        public int CodeLength { get { return tableInfo.GetFieldLength("Code"); } }
    }

    /// <summary>
    /// Represents WSupplier table, includes contructor for setting non-standard insert/update SPs and all loading mechanisms
    /// </summary>
    // public class WSupplier : BaseTable<WSupplierRow, WSupplierColumnInfo> 24653 17Jul13 XN
    [Obsolete("Uses WCustomer, WSupplier2, and WWardProductList instead")]
    public class WSupplier : BaseTable2<WSupplierRow, WSupplierColumnInfo>
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public WSupplier() : base("WSupplier") { }

        /// <summary>
        /// Loading mechanism
        /// </summary>
        /// <param name="code">Code from WSupplier for requested supplier</param>
        /// <param name="siteID">SiteID from WSupplier for requested supplier</param>
        public void LoadByCodeAndSiteID(string code, int siteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));
            parameters.Add(new SqlParameter("@SiteID",           siteID               ));
            parameters.Add(new SqlParameter("@Code",             code                 ));
            LoadBySP("pWSupplierByCode", parameters);
        }

        /// <summary>Returns all suppliers by site and supplier types 24653 17Jul13 XN</summary>
        /// <param name="siteID">SiteID from WSupplier for requested supplier</param>
        /// <param name="supplierTypes">Supplier types (empty if any supplier type)</param>
        public void LoadBySiteIDAndSupplierTypes(int siteID, params SupplierType[] supplierTypes)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID",           siteID));
            parameters.Add(new SqlParameter("@SupplierType",     supplierTypes.Any() ? "'" + supplierTypes.Select(s => EnumDBCodeAttribute.EnumToDBCode(s)).ToCSVString("','") + "'" : string.Empty));
            LoadBySP("pWSupplierBySiteIDAndSupplierTypes", parameters);
        }

        /// <summary>Loads by WSupplierID 24Jul13 XN 24653</summary>
        public void LoadByWSupplierID(int wsupplierID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));
            parameters.Add(new SqlParameter("@SupplierID",       wsupplierID          ));
            LoadBySP("pWSupplierBySupplierID", parameters);
        }

        /// <summary>Loads all supplier with specified sup code</summary>
        public void LoadByCode(string supCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SupCode", supCode));
            LoadBySP("pWSupplierByCodeOnly", parameters);
        }

        /// <summary>Returns Wsupplier row with specified supplier ID (else null if does not exist) 24Jul13 XN 24653</summary>
        public static WSupplierRow GetByWSupplierID(int wsupplierID)
        {
            WSupplier supplier = new WSupplier();
            supplier.LoadByWSupplierID(wsupplierID);
            return supplier.FirstOrDefault();
        }

        /// <summary>Returns Wsupplier row with specified code and site (else null if does not exist) 01Aug13 XN 24653</summary>
        public static WSupplierRow GetBySupCodeAndSite(string code, int siteID)
        {
            WSupplier supplier = new WSupplier();
            supplier.LoadByCodeAndSiteID(code, siteID);
            return supplier.FirstOrDefault();
        }
    }
}

