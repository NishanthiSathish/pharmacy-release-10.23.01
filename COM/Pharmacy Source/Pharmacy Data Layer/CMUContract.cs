//===========================================================================
//
//							CMUContract.cs
//
//  This class is a data layer representation of the CMU Contract File
//
//	Modification History:
//	28Jun13 AJK  Written
//  28Nov16 XN   Knock on effects to change in BaseTable2.WriteToAudtiLog 147104
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
using System.Data.SqlClient;
using System.Data;

namespace ascribe.pharmacy.pharmacydatalayer
{

    /// <summary>
    /// Represents a row in the PharmacyCMUContractFile table
    /// </summary>
    public class CMUContractRow : BaseRow
    {
        /// <summary>
        /// The CMUContractFileID primary key
        /// </summary>
        public int PharmacyCMUContractID
        {
            get { return FieldToInt(RawRow["PharmacyCMUContractID"]).Value; }
        }

        /// <summary>
        /// The SessionID tied to the data import
        /// </summary>
        public int SessionID
        {
            get { return FieldToInt(RawRow["SessionID"]).Value; }
            set { RawRow["SessionID"] = IntToField(value); }
        }

        /// <summary>
        /// CMU generic drug description
        /// </summary>
        public string GenericDescription
        {
            get { return FieldToStr(RawRow["GenericDescription"], true, string.Empty); }
            set { RawRow["GenericDescription"] = StrToField(value, true); }
        }

        /// <summary>
        /// CMU Packsize
        /// </summary>
        public string PackSize
        {
            get { return FieldToStr(RawRow["PackSize"], true, string.Empty); }
            set { RawRow["PackSize"] = StrToField(value, true); }
        }

        /// <summary>
        /// CMU NPCCode
        /// </summary>
        public string NPCCode
        {
            get { return FieldToStr(RawRow["NPCCode"], true, string.Empty); }
            set { RawRow["NPCCode"] = StrToField(value, true); }
        }

        /// <summary>
        /// CMU SupplierCode
        /// </summary>
        public string SupplierCode
        {
            get { return FieldToStr(RawRow["SupplierCode"], true, string.Empty); }
            set { RawRow["SupplierCode"] = StrToField(value, true); }
        }

        /// <summary>
        /// CMU DistributorCodes
        /// </summary>
        public string DistributorCodes
        {
            get { return FieldToStr(RawRow["DistributorCodes"], true, string.Empty); }
            set { RawRow["DistributorCodes"] = StrToField(value, true); }
        }

        /// <summary>
        /// CMU ContractCode
        /// </summary>
        public string ContractCode
        {
            get { return FieldToStr(RawRow["ContractCode"], true, string.Empty); }
            set { RawRow["ContractCode"] = StrToField(value, true); }
        }

        /// <summary>
        /// CMU Price
        /// </summary>
        public Decimal? PriceInPounds
        {
            get { return FieldToDecimal(RawRow["Price"]); }
            set { RawRow["Price"] = DecimalToField(value); }
        }

        /// <summary>
        /// The record status start date
        /// </summary>
        public DateTime? RecordStatusStartDate
        {
            get { return FieldToDateTime(RawRow["RecordStatusStartDate"]); }
            set { RawRow["RecordStatusStartDate"] = DateTimeToField(value); }
        }

        /// <summary>
        /// The record status end date
        /// </summary>
        public DateTime? RecordStatusEndDate
        {
            get { return FieldToDateTime(RawRow["RecordStatusEndDate"]); }
            set { RawRow["RecordStatusEndDate"] = DateTimeToField(value); }
        }

        /// <summary>
        /// CMU BrandName
        /// </summary>
        public string BrandName
        {
            get { return FieldToStr(RawRow["BrandName"], true, string.Empty); }
            set { RawRow["BrandName"] = StrToField(value, true); }
        }

        /// <summary>
        /// CMU LeadTime
        /// </summary>
        public string LeadTime
        {
            get { return FieldToStr(RawRow["LeadTime"], true, string.Empty); }
            set { RawRow["LeadTime"] = StrToField(value, true); }
        }

        /// <summary>
        /// CMU Minimum total order value
        /// </summary>
        public string MinTotalOrderValue
        {
            get { return FieldToStr(RawRow["MinTotalOrderValue"], true, string.Empty); }
            set { RawRow["MinTotalOrderValue"] = StrToField(value, true); }
        }

        /// <summary>Formats the MinTotalOrderValue to format like £ 10.00 </summary>
        public string MinTotalOrderValueFormattedString()
        {
            StringBuilder str = new StringBuilder();
            string currencySymbol = PharmacyCultureInfo.CurrencySymbol;
            if (!this.MinTotalOrderValue.Contains(currencySymbol))
                str.Append(currencySymbol + " ");
            str.Append(this.MinTotalOrderValue);
            if (!this.MinTotalOrderValue.Contains("."))
                str.Append(".00");
            return str.ToString();
        }

        /// <summary>CMU Min order quantity</summary>
        public string MinOrderQuantity
        {
            get { return FieldToStr(RawRow["MinOrderQuantity"], true, string.Empty); }
            set { RawRow["MinOrderQuantity"] = StrToField(value, true); }
        }

        /// <summary>
        /// CMU Delivery information including charge
        /// </summary>
        public string DeliveryInformation
        {
            get { return FieldToStr(RawRow["DeliveryInformation"], true, string.Empty); }
            set { RawRow["DeliveryInformation"] = StrToField(value, true); }
        }

        /// <summary>
        /// CMU FreeText
        /// </summary>
        public string FreeText
        {
            get { return FieldToStr(RawRow["FreeText"], true, string.Empty); }
            set { RawRow["FreeText"] = StrToField(value, true); }
        }

        /// <summary>
        /// CMU FreeText2
        /// </summary>
        public string FreeText2
        {
            get { return FieldToStr(RawRow["FreeText2"], true, string.Empty); }
            set { RawRow["FreeText2"] = StrToField(value, true); }
        }

        /// <summary>
        /// Direct ordering flag
        /// </summary>
        public bool? DirectFlag
        {
            get { return FieldToBoolean(RawRow["DirectFlag"], (bool?)false); }
            set { RawRow["DirectFlag"] = BooleanToField(value, true, false, false); }
        }

        /// <summary>
        /// Indicates eOrdering can be used
        /// </summary>
        public bool? eOrdering
        {
            get { return FieldToBoolean(RawRow["eOrdering"], (bool?)false); }
            set { RawRow["eOrdering"] = BooleanToField(value, true, false, false); }
        }

        /// <summary>
        /// Indicatesm eInvoicing can be used
        /// </summary>
        public bool? eInvoicing
        {
            get { return FieldToBoolean(RawRow["eInvoicing"], (bool?)false); }
            set { RawRow["eInvoicing"] = BooleanToField(value, true, false, false); }
        }

        /// <summary>
        /// Global trade item number
        /// </summary>
        public string GTIN
        {
            get { return FieldToStr(RawRow["GTIN"], true, string.Empty); }
            set { RawRow["GTIN"] = StrToField(value, true); }
        }

        /// <summary>
        /// Distributor ordering flag
        /// </summary>
        public bool? OFlag
        {
            get { return FieldToBoolean(RawRow["OFlag"], (bool?)false); }
            set { RawRow["OFlag"] = BooleanToField(value, true, false, false); }
        }

        /// <summary>
        /// String representation of where ot order the product from
        /// </summary>
        public string OrderFrom
        {
            get
            {
                string ret = string.Empty;
                if ((bool)FieldToBoolean(RawRow["DirectFlag"], (bool?)false))
                {
                    ret = "Direct (" + FieldToStr(RawRow["SupplierCode"], true, string.Empty) + ")";
                }
                if ((bool)FieldToBoolean(RawRow["OFlag"], (bool?)false))
                {
                    if (!string.IsNullOrEmpty(ret))
                    {
                        ret += " OR ";
                    }
                    ret += "Distributor (" + FieldToStr(RawRow["DistributorCodes"], true, string.Empty) + ")";
                }
                return ret;
            }
        }
    }

    /// <summary>
    /// Column information for the PharmacyCMUContract table
    /// </summary>
    public class CMUContractColumnInfo : BaseColumnInfo
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public CMUContractColumnInfo() : base("PharmacyCMUContract") { }

        /// <summary>
        /// The maximum length for the GenericDescription field
        /// </summary>
        public int GenericDescriptionLength { get { return base.FindColumnByName("GenericDescription").Length; } }

        /// <summary>
        /// The maximum length for the PackSize field
        /// </summary>
        public int PackSizeLength { get { return base.FindColumnByName("PackSize").Length; } }

        /// <summary>
        /// The maximum length for the NPCCode field
        /// </summary>
        public int NPCCodeLength { get { return base.FindColumnByName("NPCCode").Length; } }

        /// <summary>
        /// The maximum length for the SupplierCode field
        /// </summary>
        public int SupplierCodeLength { get { return base.FindColumnByName("SupplierCode").Length; } }

        /// <summary>
        /// The maximum length for the DistributorCodes field
        /// </summary>
        public int DistributorCodesLength { get { return base.FindColumnByName("DistributorCodes").Length; } }

        /// <summary>
        /// The maximum length for the ContractCode field
        /// </summary>
        public int ContractCodeLength { get { return base.FindColumnByName("ContractCode").Length; } }

        /// <summary>
        /// The maximum length for the BrandName field
        /// </summary>
        public int BrandNameLength { get { return base.FindColumnByName("BrandName").Length; } }

        /// <summary>
        /// The maximum length for the LeadTime field
        /// </summary>
        public int LeadTimeLength { get { return base.FindColumnByName("LeadTime").Length; } }

        /// <summary>
        /// The maximum length for the MinTotalOrderValue field
        /// </summary>
        public int MinTotalOrderValueLength { get { return base.FindColumnByName("MinTotalOrderValue").Length; } }

        /// <summary>
        /// The maximum length for the MinOrderQuantity field
        /// </summary>
        public int MinOrderQuantityLength { get { return base.FindColumnByName("MinOrderQuantity").Length; } }

        /// <summary>
        /// The maximum length for the DeliveryInformation field
        /// </summary>
        public int DeliveryInformationLength { get { return base.FindColumnByName("DeliveryInformation").Length; } }

        /// <summary>
        /// The maximum length for the FreeText field
        /// </summary>
        public int FreeTextLength { get { return base.FindColumnByName("FreeText").Length; } }

        /// <summary>
        /// The maximum length for the FreeText2 field
        /// </summary>
        public int FreeText2Length { get { return base.FindColumnByName("FreeText2").Length; } }

        /// <summary>
        /// The maximum length for the GTIN field
        /// </summary>
        public int GTINLength { get { return base.FindColumnByName("GTIN").Length; } }
    }

    /// <summary>
    /// Represents the CMUContract table
    /// </summary>
    public class CMUContract : BaseTable2<CMUContractRow, CMUContractColumnInfo>
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public CMUContract() : base("PharmacyCMUContract") 
        {
            //this.writeToAudtiLog = false;  28Nov16 XN Knock on effects to change in BaseTable2.WriteToAudtiLog 147104 // ICW does not seem to log this table
            this.WriteToAudtiLog = false;
        }

        /// <summary>
        /// Load mechanism by PharmacyCMUContractID
        /// </summary>
        /// <param name="contractID">PharmacyCMUContractID of the required record to be loaded</param>
        public void LoadByID(int contractID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@PharmacyCMUContractID", contractID));
            LoadBySP("pPharmacyCMUContractByPharmacyCMUContractID", parameters);
        }

        /// <summary>
        /// Load mechanism by SessionID
        /// </summary>
        public void LoadByCurrentSessionID()
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));
            LoadBySP("pPharmacyCMUContractBySessionID", parameters);
        }

        public static void DeleteByCurrentSessionID()
        {
            Database.ExecuteSQLNonQuery("DELETE FROM PharmacyCMUContract WHERE SessionID={0}", SessionInfo.SessionID);
        }

        /// <summary>Load mechanism by PharmacyCMUContractID (else returns null)</summary>
        public static CMUContractRow GetByID(int pharmacyCMUContractID)
        {
            CMUContract cmuContract = new CMUContract();
            cmuContract.LoadByID(pharmacyCMUContractID);
            return cmuContract.FirstOrDefault();
        }
    }
}
