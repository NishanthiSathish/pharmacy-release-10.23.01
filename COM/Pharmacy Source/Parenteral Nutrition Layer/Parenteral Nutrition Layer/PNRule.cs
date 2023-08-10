//===========================================================================
//
//							       PNRule.cs
//
//  Provides access to PNRule table (hold the PN rules info). 
//  Rules are saved by site
//
//  Unlike other tables the you do not create an instance of PNRule, instead
//  you do PNRule.GetInstance(), which will return a cached list of all the 
//  PN rules in the database.
//
//  To ensure that the rules are reloaded call PNRule.GetInstance(true).
//  Or set the flag in the WConfigruation file 
//  Category: D|PN
//  Section: PNRules
//  Key: Reload
//  that ensures the rules are reloaded on next PNRule.GetInstance() call.
//
//  Only supports reading, inserting, and updating.
//  Uses conflict option CompareAllSearchableValues
//
//	Modification History:
//	28Oct11 XN Written
//  30Oct15 XN Added LoadByRuleNumber and FindFirstBySiteId 106278
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using System.Data.SqlClient;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    public enum RuleType
    {
        /// <summary>Ingredient supplied by product rule type</summary>
        [EnumDBCode("0")]
        IngredientByProduct,

        /// <summary>Prescription proforma rule type</summary>
        [EnumDBCode("1")]
        PrescriptionProforma,

        /// <summary>Regimen validation rule type</summary>
        [EnumDBCode("4")]
        RegimenValidation,
    }

    /// <summary>Represents a row in the PNRule table</summary>
    public class PNRuleRow : BaseRow
    {
        public int PNRuleID
        {
            get { return FieldToInt(RawRow["PNRuleID"]).Value; }
        }

        public int RuleNumber
        {
            get { return FieldToInt(RawRow["RuleNumber"]).Value; }
            set { RawRow["RuleNumber"] = IntToField(value);      }
        }

        public int LocationID_Site
        {
            get { return FieldToInt(RawRow["LocationID_Site"]).Value; }
            set { RawRow["LocationID_Site"] = IntToField(value);      }
        }

        #region General info
        public string Description
        {
            get { return FieldToStr(RawRow["Description"]);   }
            set { RawRow["Description"] = StrToField(value);  }
        }

        public RuleType RuleType
        {
            get { return FieldToEnumByDBCode<RuleType>(RawRow["RuleType"]);  }
            set { RawRow["RuleType"] = EnumToFieldByDBCode<RuleType>(value); }
        }

        public bool InUse
        {
            get { return FieldToBoolean(RawRow["InUse"]).Value; }
            set { RawRow["InUse"] = BooleanToField(value);      }
        }

        /// <summary>If true rule is for Paediatric, else for adult</summary>
        public bool PerKilo
        {
            get { return FieldToBoolean(RawRow["PerKilo"]).Value; }
            set { RawRow["PerKilo"] = BooleanToField(value);      }
        }
        #endregion

        #region Details
        public string RuleSQL
        {
            get { return FieldToStr(RawRow["RuleSQL"]);  }
            set { RawRow["RuleSQL"] = StrToField(value); }
        }

        public string Explanation
        {
            get { return FieldToStr(RawRow["Explanation"]);     }
            set { RawRow["Explanation"] = FieldToStr(value);    }
        }

        public bool Critical
        {
            get { return FieldToBoolean(RawRow["Critical"]).Value; }
            set { RawRow["Critical"] = BooleanToField(value);      }
        }
        #endregion

        #region Modified data
        /// <summary>Date field was last modified</summary>
        public DateTime? LastModifiedDate
        {
            get { return FieldToDateTime(RawRow["LastModDate"]);    }
            set { RawRow["LastModDate"] = DateTimeToField(value);   }
        }

        /// <summary>
        /// Initials of user who last modified the record
        /// ASC if from ascribe DSS.
        /// </summary>
        public string LastModifiedUserInitials
        {
            get { return FieldToStr(RawRow["LastModUser"]);     }
            set { RawRow["LastModUser"] = FieldToStr(value);    }
        }

        /// <summary>
        /// Terminal of user who last modified the record
        /// Unknown if from ascribe DSS.
        /// </summary>
        public string LastModifiedTerminal
        {
            get { return FieldToStr(RawRow["LastModTerm"]);     }
            set { RawRow["LastModTerm"] = StrToField(value);    }
        }

        /// <summary>Info provided by ascribe DSS of an update</summary>
        public string DSSInfo
        {
            get { return FieldToStr(RawRow["Info"]);    }
            set { RawRow["Info"] = StrToField(value);   }
        }
        #endregion

        #region Ingredient Rule info (for RuleType.IngredientByProduct only)
        public string PNCode
        {
            get { return FieldToStr(RawRow["PNCode"]);  }
            set { RawRow["PNCode"] = StrToField(value); }
        }

        public string Ingredient
        {
            get { return FieldToStr(RawRow["Ingredient"]);  }
            set { RawRow["Ingredient"] = StrToField(value); }
        }
        #endregion

        public override string ToString()
        {
            return Description;
        }
    }

    /// <summary>Provides column information about the PNRule table</summary>
    public class PNRuleColumnInfo : BaseColumnInfo
    {
        public PNRuleColumnInfo()                 : base("PNRule" ) { }
        public PNRuleColumnInfo(string tableName) : base(tableName) { }

        public int DescriptionLength                { get { return base.FindColumnByName("Description").Length;      } }
        //public int IngredientNameLength           { get { return base.FindColumnByName("IngredientName").Length;   } } // 22Feb12 AJK Removed for cleanup
        //public int IngredientActionLength         { get { return base.FindColumnByName("IngredientAction").Length; } } // 22Feb12 AJK Removed for cleanup
        public int IngredientLength                 { get { return base.FindColumnByName("Ingredient").Length;       } } // 22Feb12 AJK Added
        public int ExplanationLength                { get { return base.FindColumnByName("Explanation").Length;      } }
        public int LastModifiedUserInitialsLength   { get { return base.FindColumnByName("LastModUser").Length;      } }
        public int LastModifiedTerminalLength       { get { return base.FindColumnByName("LastModTerm").Length;      } }
    }

    /// <summary>Represent the PNRule table</summary>
    public class PNRule : BaseTable2<PNRuleRow, PNRuleColumnInfo>
    {
        public PNRule() : base("PNRule")
        {
            this.ConflictOption = System.Data.ConflictOption.CompareAllSearchableValues;
        }

        /// <summary>Load all PN rules by site ID</summary>
        /// <param name="siteID">Site ID</param>
        private void LoadBySite(int siteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID", siteID));
            LoadBySP("pPNRuleBySite", parameters);
        }

        /// <summary>Load PN rule by ID</summary>
        /// <param name="pnProductID">PN rule ID</param>
        public void LoadByID(int pnRuleID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@PNRuleID", pnRuleID));
            LoadBySP("pPNRuleByID", parameters);
        }

        /// <summary>Load PN rule by rule number (should only be on)</summary>
        /// <param name="siteID">Current site ID</param>
        /// <param name="ruleNumber">Rule number</param>
        public void LoadBySiteIDAndRuleNumber(int siteID, int ruleNumber)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID",     siteID));
            parameters.Add(new SqlParameter("@RuleNumber", ruleNumber));
            LoadBySP("pPNRuleBySiteIDAndRuleNumber", parameters);
        }

        /// <summary>Load PN rule by rule number (for all sites) 28Oct15 XN 106278</summary>
        /// <param name="ruleNumber">Rule number</param>
        public void LoadByRuleNumber(int ruleNumber)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@RuleNumber", ruleNumber));
            LoadBySP("pPNRuleByRuleNumber", parameters);
        }

        /// <summary>Load PN rules by type (unsorted)</summary>
        /// <param name="siteID">Current site ID</param>
        /// <param name="ruleType">Rule Type</param>
        public void LoadBySiteIDAndRuleType(int siteID, RuleType ruleType)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID",   siteID));
            parameters.Add(new SqlParameter("@RuleType", EnumDBCodeAttribute.EnumToDBCode(ruleType)));
            LoadBySP("pPNRuleBySiteIDAndRuleType", parameters);
        }

        /// <summary>Load PN rules by type (unsorted)</summary>
        /// <param name="siteID">Current site ID</param>
        /// <param name="ruleType">Rule Type</param>
        /// <param name="perKilo">Per kilo rules</param>
        public void LoadBySiteIDRuleTypeAndPerKilo(int siteID, RuleType ruleType, bool perKilo)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID",   siteID));
            parameters.Add(new SqlParameter("@RuleType", EnumDBCodeAttribute.EnumToDBCode(ruleType)));
            parameters.Add(new SqlParameter("@PerKilo",  perKilo));
            LoadBySP("pPNRuleBySiteIDRuleTypeAndPerKilo", parameters);
        }

        /// <summary>
        /// Returns next rule number in the sequence for specific rule type
        /// Only use the rules in the current instance.
        /// </summary>
        /// <param name="siteID">Current site ID</param>
        /// <param name="ruleType">Rule Type</param>
        public static int GetNextRuleNumberBySiteIDAndType(int siteID, RuleType ruleType)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID",   siteID));
            parameters.Add(new SqlParameter("@RuleType", EnumDBCodeAttribute.EnumToDBCode(ruleType)));

            object val = Database.ExecuteScalar<object>("pPNRuleGetMaxRuleNumberBySiteIDAndType", parameters);
            return (val == null) ? 1 : ((int)val) + 1;
        }

        /// <summary>Gets the rule with the specified rule number</summary>
        /// <param name="siteID">Current site ID</param>
        /// <param name="ruleNumber">Rule number</param>
        /// <returns>Rule with specified rule number</returns>
        public static PNRuleRow GetBySiteIDAndRuleNumber(int siteID, int ruleNumber)
        {
            PNRule rules = new PNRule();
            rules.LoadBySiteIDAndRuleNumber(siteID, ruleNumber);
            return rules.FirstOrDefault();
        }

        /// <summary>Gets rule with specified ID</summary>
        /// <param name="ruleID">Rule ID to load</param>
        /// <returns>rule ID</returns>
        public static PNRuleRow GetByID(int ruleID)
        {
            PNRule rules = new PNRule();
            rules.LoadByID(ruleID);
            return rules.FirstOrDefault();
        }
    }

    /// <summary>Provides extension methods to IEnumerable{PNRuleRow} class</summary>
    public static class PNRuleExtensions
    {
        /// <summary>Returns first rule by site number 26Oct15 XN 106278</summary>
        /// <typeparam name="T">PNRuleRow or PNRulePrescriptionProforma</typeparam>
        /// <param name="rules">Rules</param>
        /// <param name="siteId">site Id</param>
        /// <returns>First rule</returns>
        public static T FindFirstBySiteId<T>(this IEnumerable<T> rules, int siteId) where T : PNRuleRow, new()
        {
            return rules.FirstOrDefault(p => p.LocationID_Site == siteId);
        }
    }
}
