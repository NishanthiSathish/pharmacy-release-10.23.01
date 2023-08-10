// -----------------------------------------------------------------------
// <copyright file="PNRulePrescriptionProforma.cs" company="Emis Health">
//      Copyright Emis Health Plc
// </copyright>
// <summary>
// This class represents the PNRulePrescriptionProforma table.
//
// SP for this object should return all fields from the PNRulePrescriptionProforma, and PNRule tables 
//
// Only supports reading, updating, and inserting from table.
//
// The table supports logical deletes
//
// Modification History:
// 30Oct15 XN Added LoadByRuleNumber 106278
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using System.Data.SqlClient;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    public class PNRulePrescriptionProformaRow : PNRuleRow
    {
        #region Ingredients
        /// <summary>Gets prescriptions suggested ingredeint value</summary>
        public double? GetIngredient(string dbName) 
        { 
            return FieldToDouble(RawRow[dbName]);
        }

        /// <summary>Sets prescriptions suggested ingredient value</summary>
        public void SetIngredient(string dbName, double? value)
        {
            RawRow[dbName] = DoubleToField(value);
        }
        #endregion
    }

    /// <summary>Provides column information about the PNRule table</summary>
    public class PNRulePrescriptionProformaColumnInfo : PNRuleColumnInfo
    {
        public PNRulePrescriptionProformaColumnInfo() : base("PNRulePrescriptionProforma") { }
    }

    /// <summary>Represent the PNRulePrescriptionProforma table</summary>
    public class PNRulePrescriptionProforma : BaseTable2<PNRulePrescriptionProformaRow, PNRulePrescriptionProformaColumnInfo>
    {
        public PNRulePrescriptionProforma() : base("PNRulePrescriptionProforma", "PNRule")
        {
            this.ConflictOption = System.Data.ConflictOption.CompareAllSearchableValues;
        }

        /// <summary>Load all PN proforma by site ID</summary>
        /// <param name="siteID">Site ID</param>
        public void LoadBySite(int siteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID", siteID));
            LoadBySP("pPNRulePrescriptionProformaBySite", parameters);
        }

        /// <summary>Load PN proforma by ID</summary>
        /// <param name="pnProductID">PN rule ID</param>
        public void LoadByID(int pnRuleID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@PNRuleID", pnRuleID));
            LoadBySP("pPNRulePrescriptionProformaByID", parameters);
        }

        /// <summary>Load PN proforma by rule number (for all sites) 28Oct15 XN 106278</summary>
        /// <param name="ruleNumber">Rule number</param>
        public void LoadByRuleNumber(int ruleNumber)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@RuleNumber", ruleNumber));
            LoadBySP("pPNRulePrescriptionProformaByRuleNumber", parameters);
        }

        /// <summary>Gets proforma with specified ID</summary>
        /// <param name="ruleID">Rule ID to load</param>
        /// <returns>Proforma</returns>
        public static PNRulePrescriptionProformaRow GetByID(int ruleID)
        {
            PNRulePrescriptionProforma rules = new PNRulePrescriptionProforma();
            rules.LoadByID(ruleID);
            return rules.FirstOrDefault();
        }
    }
}
