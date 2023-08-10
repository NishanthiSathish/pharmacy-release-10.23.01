using System;
//===========================================================================
//
//							        WFMRule.cs
//
//	Provides functions for writing to the WFMRule table
//  Used by finance manager
//
//  Used to assign account codes to either WOrderlog, or WTranslog, lines.
//  This is done by filter the lines by log type, label, ward\sup code, site, and NSV code.
//  Actual filtering bit is done by overnight job pWFMLogCachePopulate 'T' and pWFMLogCachePopulate 'O'
//  these places the converted data into WFMLogCache.
//
//  Supports reading, inserting, and updating.
//  
//	Modification History:
//	23Apr13 XN  Written 53147
//  30May13 XN  Replaced IgnoreStock with StockFieldSelector (65498)
//  17Sep13 XN  Converted WFMAccountCode.Code, WFMRule.Code from string to short
//  02Dec13 XN  Added VAT account codes 79631
//  08Jan14 XN  Add site to rule 81377
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.financemanagerlayer
{
    public enum WFMPositiveNegative
    {
        [EnumDBCode("")]
        Any,
        [EnumDBCode("+")]
        Positive,
        [EnumDBCode("-")]
        Negative,
    };

    /// <summary>Represents a row in the WFMRule table</summary>
    public class WFMRuleRow : BaseRow
    {
        public int WFMRuleID
        {
            get { return (int)FieldToInt(RawRow["WFMRuleID"]); }
        }

        public short Code
        {
            get { return FieldToShort(RawRow["Code"]).Value;    }
            set { RawRow["Code"] = ShortToField(value);         }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"], true, string.Empty); }
            set { RawRow["Description"] = StrToField(value);                    }
        }

        public PharmacyLogType PharmacyLog
        {
            get { return FieldToEnumByDBCode<PharmacyLogType>(RawRow["PharmacyLog"]);  }
            set { RawRow["PharmacyLog"] = EnumToFieldByDBCode<PharmacyLogType>(value); }
        }

        public string Kind
        {
            get { return FieldToStr(RawRow["Kind"], true, string.Empty); }
            set { RawRow["Kind"] = StrToField(value);                    }
        }

        public string LabelType
        {
            get { return FieldToStr(RawRow["LabelType"], true, string.Empty); }
            set { RawRow["LabelType"] = StrToField(value);                    }
        }

        // 08Jan14 XN 81377
        public int? LocationID_Site
        {
            get { return FieldToInt(RawRow["LocationID_Site"]);     }
            set { RawRow["LocationID_Site"] = IntToField(value);    }
        }

        public string NSVCode
        {
            get { return FieldToStr(RawRow["NSVCode"], true, string.Empty); }
            set { RawRow["NSVCode"] = StrToField(value);                    }
        }

        public string WardCode
        {
            get { return FieldToStr(RawRow["WardCode"], true, string.Empty); }
            set { RawRow["WardCode"] = StrToField(value);                    }
        }

        /// <summary>Required instead of using just SupCode incase we need the supplier name and so we don't need to store siteID</summary>
        public int? SupplierID
        {
            get { return FieldToInt(RawRow["WSupplierID"]);  }
            set { RawRow["WSupplierID"] = IntToField(value); }
        }

        public string SupCode
        {
            get { return FieldToStr(RawRow["SupCode"], true, string.Empty); }
            set { RawRow["SupCode"] = StrToField(value);                    }
        }

        public SupplierType SupplierType
        {
            get { return FieldToEnumByDBCode<SupplierType>(RawRow["SupplierType"]);  }
            set { RawRow["SupplierType"] = EnumToFieldByDBCode<SupplierType>(value); }
        }

        public WFMPositiveNegative FilterOnCostPosNeg
        {
            get { return FieldToEnumByDBCode<WFMPositiveNegative>(RawRow["FilterOnCostPosNeg"]);  }
            set { RawRow["FilterOnCostPosNeg"] = EnumToFieldByDBCode<WFMPositiveNegative>(value); }
        }

        public WFMPositiveNegative FilterOnStockPosNeg
        {
            get { return FieldToEnumByDBCode<WFMPositiveNegative>(RawRow["FilterOnStockPosNeg"]);  }
            set { RawRow["FilterOnStockPosNeg"] = EnumToFieldByDBCode<WFMPositiveNegative>(value); }
        }

        public string ExtraSQLFilter
        {
            get { return FieldToStr(RawRow["ExtraSQLFilter"], true, string.Empty); }
            set { RawRow["ExtraSQLFilter"] = StrToField(value);                    }
        }

        public short AccountCode_Debit
        {
            get { return FieldToShort(RawRow["AccountCode_Debit"]).Value; }
            set { RawRow["AccountCode_Debit"] = ShortToField(value);      }
        }

        public short AccountCode_Credit
        {
            get { return FieldToShort(RawRow["AccountCode_Credit"]).Value; }
            set { RawRow["AccountCode_Credit"] = ShortToField(value);      }
        }

        // XN 03Dec13 79631 Added
        public short? AccountCode_Vat_Debit
        {
            get { return FieldToShort(RawRow["AccountCode_Vat_Debit"]);     }
            set { RawRow["AccountCode_Vat_Debit"] = ShortToField(value);    }
        }

        // XN 03Dec13 79631 Added
        public short? AccountCode_Vat_Credit
        {
            get { return FieldToShort(RawRow["AccountCode_Vat_Credit"]);   }
            set { RawRow["AccountCode_Vat_Credit"] = ShortToField(value);  }
        }

        public bool CostFieldRequired
        {
            get { return FieldToBoolean(RawRow["CostFieldRequired"], true).Value; }
            set { RawRow["CostFieldRequired"] = BooleanToField(value);            }
        }

        public string StockFieldSelector    
        {
            get { return FieldToStr(RawRow["StockFieldSelector"], true); }
            set { RawRow["StockFieldSelector"] = FieldToStr(value);      }
        }

        public string CostMultiply
        {
            get { return FieldToStr(RawRow["CostMultiply"]);   }
            set { RawRow["CostMultiply"] = StrToField(value);  }
        }

        public string StockMultiply
        {
            get { return FieldToStr(RawRow["StockMultiply"]);  }
            set { RawRow["StockMultiply"] = StrToField(value); }
        }

        /// <summary>
        /// Returns drug description in form
        ///     {NSV Code} - Description
        /// </summary>
        public string GetNSVDescription()
        {
            string descritpion = this.NSVCode;
            if (!string.IsNullOrEmpty(this.NSVCode))
                descritpion += " - " + WProduct.ProductDetails(this.NSVCode);
            return descritpion;
        }

        /// <summary>
        /// Returns supplier description in form 
        ///     {Sup code} - Description
        /// </summary>
        public string GetSupplierDescription()
        {
            string description = this.SupCode;

            if (this.SupplierID != null)
            {
                WSupplier supplier = new WSupplier();
                supplier.LoadByWSupplierID(this.SupplierID.Value);
                if (supplier.Any() && supplier[0].Code.EqualsNoCaseTrimEnd(this.SupCode))
                    description += " - "  + supplier[0].FullName;
            }

            return description;
        }

        /// <summary>
        /// Returns ward description in form 
        ///     {Ward code} - Description
        /// </summary>
        public string GetWardDescription()
        {
            string description = this.WardCode;

            if (!string.IsNullOrEmpty(this.WardCode))
            {
                WardRow ward = Ward.GetByWardCode(this.WardCode);
                if (ward != null)
                    description += " - "  + ward.ToString();
            }

            return description;
        }

        /// <summary>Returns {Code} - {Description}</summary>
        public override string ToString()
        {
            return string.Format("{0} - {1}", this.Code, this.Description);
        }
    }

    /// <summary>Provides column information about the WFMRule table</summary>
    public class WFMRuleColumnInfo : BaseColumnInfo
    {
        public WFMRuleColumnInfo() : base("WFMRule") { }

        public int CodeLength                        { get { return 4;                                                              } }
        public int DescriptionLength                 { get { return base.FindColumnByName("Description").Length;                    } }
        public int KindLength                        { get { return base.FindColumnByName("Kind").Length;                           } }
        public int LabelTypeLength                   { get { return base.FindColumnByName("LabelType").Length;                      } }
        public int NSVCodeLength                     { get { return base.FindColumnByName("NSVCode").Length;                        } }
        public int WardCodeLength                    { get { return base.FindColumnByName("WardCode").Length;                       } }
        public int SupCodeLength                     { get { return base.FindColumnByName("SupCode").Length;                        } }
        public int ExtraSQLFilterLength              { get { return base.FindColumnByName("ExtraSQLFilter").Length;                 } }
        public int AccountCode_DebitCostExVatLength  { get { return base.FindColumnByName("AccountCode_DebitCostExVat").Length;     } }
        public int AccountCode_DebitVatCostLength    { get { return base.FindColumnByName("AccountCode_DebitVatCost").Length;       } }
        public int AccountCode_CreditCostExVatLength { get { return base.FindColumnByName("AccountCode_CreditCostExVat").Length;    } }
        public int AccountCode_CreditVatCostLength   { get { return base.FindColumnByName("AccountCode_CreditVatCost").Length;      } }
    }


    /// <summary>Represent the WFMRule table</summary>
    public class WFMRule : BaseTable2<WFMRuleRow, WFMRuleColumnInfo>
    {
        /// <summary>Constructor</summary>
        public WFMRule() : base("WFMRule") { }


        /// <summary>Load all FM rule</summary>
        public void LoadAll()
        {
            LoadBySP("pWFMRuleAll", new List<SqlParameter>());
        }

        /// <summary>Loads the rule by ruleID</summary>
        public void LoadByID(int ruleID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@WFMRuleID", ruleID));
            LoadBySP("pWFMRuleByID", parameters);
        }

        /// <summary>Loads the rule by code</summary>
        public void LoadByCode(short code)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@Code", code));
            LoadBySP("pWFMRuleByCode", parameters);
        }

        /// <summary>Returns all rules with the same matching parameters</summary>
        public void LoadByMatchingParameters(PharmacyLogType pharamcyLogType, string kind, string labelType, int? locationID_Site, SupplierType supplierType, string NSVCode, string wardCode, string supCode, WFMPositiveNegative filterOnCostPosNeg, WFMPositiveNegative filterOnStockPosNeg)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@PharmacyLog",         EnumDBCodeAttribute.EnumToDBCode(pharamcyLogType)));
            parameters.Add(new SqlParameter("@Kind",                kind));
            parameters.Add(new SqlParameter("@LabelType",           labelType));
            parameters.Add(new SqlParameter("@LocationID_Site",     (object)locationID_Site ?? DBNull.Value )); // 08Jan14 XN 81377
            parameters.Add(new SqlParameter("@NSVCode",             NSVCode));
            parameters.Add(new SqlParameter("@WardCode",            wardCode));
            parameters.Add(new SqlParameter("@SupCode",             supCode));
            parameters.Add(new SqlParameter("@SupplierType",        EnumDBCodeAttribute.EnumToDBCode(supplierType)));
            parameters.Add(new SqlParameter("@FilterOnCostPosNeg",  EnumDBCodeAttribute.EnumToDBCode(filterOnCostPosNeg)));
            parameters.Add(new SqlParameter("@FilterOnStockPosNeg", EnumDBCodeAttribute.EnumToDBCode(filterOnStockPosNeg)));
            LoadBySP("pWFMRuleByMatchingParameters", parameters);
        }

        /// <summary>Returns rule by ruleID, or null if does not exist</summary>
        public static WFMRuleRow GetByID(int ruleID)
        {
            WFMRule rule = new WFMRule();
            rule.LoadByID(ruleID);
            return rule.FirstOrDefault();
        }

        /// <summary>Returns rule by code, or null if does not exist</summary>
        public static WFMRuleRow GetByCode(short code)
        {
            WFMRule rule = new WFMRule();
            rule.LoadByCode(code);
            return rule.FirstOrDefault();
        }

        /// <summary>Returns true if the code does not already exist in the db table WFMRule</summary>
        /// <param name="code">Code to test</param>
        public static bool CheckCodeIsUnique(string code)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@Code", code));
            return Database.ExecuteSQLScalar<int?>("SELECT TOP 1 1 FROM WFMRule WHERE Code Like @Code", parameters) == null;
        }
    }
}
