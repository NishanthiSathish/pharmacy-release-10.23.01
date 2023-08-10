//===========================================================================
//
//							PNBlackboard.cs
//
//  Provides access to PNBlackboard table, and functions to run the blackboard rules.
//
//  Use the PNProcessor class to run the rules agains the database
//
//	Modification History:
//	20Dec11 XN  Written 
//  20Apr12 XN  TFS32363 Added check to PNIngredientsToProducts method for
//              duplicate ingredients (prevents crash)           
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Data.SqlClient;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.icwdatalayer;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    /// <summary>Represents a row in PNBlackboard table</summary>
    internal class PNBlackboardRow : BaseRow
    {
        public int PNBlackboardID
        {
            get { return FieldToInt(RawRow["PNBlackboardID"]).Value; }
        }

        public int? AgeInDays
        {
            get { return FieldToInt(RawRow["AgeInDays"]).Value; }
            set { RawRow["AgeInDays"] = IntToField(value); }
        }

        public double? AgeInYears
        {
            get { return FieldToDouble(RawRow["AgeInYears"]).Value; }
            set { RawRow["AgeInYears"] = DoubleToField(value);      }
        }

        public string Sex
        {
            get { return FieldToStr(RawRow["Sex"]);     }
            set { RawRow["Sex"] = StrToField(value);    }
        }

        public double? WeightInkg
        {
            get { return FieldToDouble(RawRow["Weightkg"]).Value; }
            set { RawRow["Weightkg"] = DoubleToField(value);      }
        }

        public int? TPNtotdays
        {
            get { return FieldToInt(RawRow["TPNtotdays"]).Value; }
            set { RawRow["TPNtotdays"] = IntToField(value); }
        }

        public string InfuseCPE
        {
            get { return FieldToStr(RawRow["InfuseCPE"]);     }
            set { RawRow["InfuseCPE"] = StrToField(value);    }
        }

        public bool? Combined
        {
            get { return FieldToBoolean(RawRow["Combined"]);     }
            set { RawRow["Combined"] = BooleanToField(value);    }
        }

        public double? HrsAminoInf
        {
            get { return FieldToDouble(RawRow["HrsAminoInf"]).Value; }
            set { RawRow["HrsAminoInf"] = DoubleToField(value);      }
        }

        public double? HrsLipidInf
        {
            get { return FieldToDouble(RawRow["HrsLipidInf"]).Value; }
            set { RawRow["HrsLipidInf"] = DoubleToField(value);      }
        }

        public bool? RegimenSupply48Hours
        {
            get { return FieldToBoolean(RawRow["RegimenSupply48Hours"]).Value; }
            set { RawRow["RegimenSupply48Hours"] = BooleanToField(value);      }
        }

        public double? CalciumPhosphateSolubility
        {
            get { return FieldToDouble(RawRow["CalciumPhosphateSolubility"]).Value; }
            set { RawRow["CalciumPhosphateSolubility"] = DoubleToField(value);      }
        }

        public double? Osmolality
        {
            get { return FieldToDouble(RawRow["Osmolality"]).Value; }
            set { RawRow["Osmolality"] = DoubleToField(value);      }
        }

        public string PNCodes
        {
            get { return FieldToStr(RawRow["PNCodes"]);     }
            set { RawRow["PNCodes"] = StrToField(value);    }
        }

        /// <summary>
        /// Populates blackboard row's 
        ///     Sex
        ///     AgeInDays
        ///     AgeInYears
        /// </summary>
        /// <param name="blackboardRow">Blackboard row to populate</param>
        /// <param name="patient">patient</param>
        public void SetFromPatientInfo(PatientRow patient)
        {
            DateTime now = DateTime.Now;

            // Set gender
            switch (patient.Gender)
            {
            case GenderType.Male:   this.Sex = "M"; break;
            case GenderType.Female: this.Sex = "F"; break;
            default:                this.Sex = "U"; break;
            }

            // Set age
            if (patient.DOB.HasValue && (patient.DOB.Value <= now))
            {
                this.AgeInDays = (int)(DateTime.Now - patient.DOB.Value).TotalDays;
                this.AgeInYears = PNUtils.YearsDifference(patient.DOB.Value, now);
            }
        }

        /// <summary>
        /// Populate this row with regimen information
        ///     Infuse route (Centeral, Peripheral, Either)
        ///     Combined
        ///     Hours amino infusion
        ///     Hours lipid infusion
        ///     PN Codes
        ///     Regimen total values
        /// </summary>
        public void SetFromRegimen(PNRegimenRow regimen, IEnumerable<PNRegimenItem> items)
        {
            this.InfuseCPE              = regimen.CentralLineOnly ? "C" : "E";
            this.Combined               = regimen.IsCombined;
            this.HrsAminoInf            = regimen.InfusionHoursAqueousOrCombined;
            this.HrsLipidInf            = regimen.InfusionHoursLipid;
            this.RegimenSupply48Hours   = regimen.Supply48Hours;

            this.PNCodes = "," + items.Select(i => i.PNCode).ToCSVString(",") + ",";    // Need commas at start and end else rules will fail

            this.RawRow["RegimenVolume"]            = DoubleToField(items.CalculateTotal(PNIngDBNames.Volume            ));
            this.RawRow["RegimenCalories"]          = DoubleToField(items.CalculateTotal(PNIngDBNames.Calories          ));
            this.RawRow["RegimenNitrogen"]          = DoubleToField(items.CalculateTotal(PNIngDBNames.Nitrogen          ));
            this.RawRow["RegimenGlucose"]           = DoubleToField(items.CalculateTotal(PNIngDBNames.Glucose           ));
            this.RawRow["RegimenFat"]               = DoubleToField(items.CalculateTotal(PNIngDBNames.Fat               ));
            this.RawRow["RegimenSodium"]            = DoubleToField(items.CalculateTotal(PNIngDBNames.Sodium            ));
            this.RawRow["RegimenPotassium"]         = DoubleToField(items.CalculateTotal(PNIngDBNames.Potassium         ));
            this.RawRow["RegimenCalcium"]           = DoubleToField(items.CalculateTotal(PNIngDBNames.Calcium           ));
            this.RawRow["RegimenMagnesium"]         = DoubleToField(items.CalculateTotal(PNIngDBNames.Magnesium         ));
            this.RawRow["RegimenZinc"]              = DoubleToField(items.CalculateTotal(PNIngDBNames.Zinc              ));
            this.RawRow["RegimenPhosphate"]         = DoubleToField(items.CalculateTotal(PNIngDBNames.Phosphate         ));
            this.RawRow["RegimenChloride"]          = DoubleToField(items.CalculateTotal(PNIngDBNames.Chloride          ));
            this.RawRow["RegimenAcetate"]           = DoubleToField(items.CalculateTotal(PNIngDBNames.Acetate           ));
            this.RawRow["RegimenSelenium"]          = DoubleToField(items.CalculateTotal(PNIngDBNames.Selenium          ));
            this.RawRow["RegimenCopper"]            = DoubleToField(items.CalculateTotal(PNIngDBNames.Copper            ));
            this.RawRow["RegimenAqueousVolume"]     = DoubleToField(items.FindByAqueousOrLipid(PNProductType.Aqueous).CalculateTotal(PNIngDBNames.Volume));
            this.RawRow["RegimenLipidVolume"]       = DoubleToField(items.FindByAqueousOrLipid(PNProductType.Lipid  ).CalculateTotal(PNIngDBNames.Volume));
            this.RawRow["RegimenInorganicPhosphate"]= DoubleToField(items.CalculateTotal(PNIngDBNames.InorganicPhosphate));
            this.RawRow["RegimenIron"]              = DoubleToField(items.CalculateTotal(PNIngDBNames.Iron              ));
            this.RawRow["RegimenManganese"]         = DoubleToField(items.CalculateTotal(PNIngDBNames.Manganese         ));
        }

    }

    /// <summary>Provides column information about the PNBlackboard table</summary>
    internal class PNBlackboardColumnInfo : BaseColumnInfo
    {
        public PNBlackboardColumnInfo() : base("PNBlackboard") { }
    }

    /// <summary>Represents the PNBlackboard table</summary>
    internal class PNBlackboard : BaseTable2<PNBlackboardRow, PNBlackboardColumnInfo>
    {
        public PNBlackboard() : base("PNBlackboard") { }

        /// <summary>
        /// Calls sp pPNIngredientsToProducts to run the ingredient to product rules (RuleType 0) against the backboard row
        /// Returns map of ingredient (in upper case) to PNCode (note ingredient can be in form NaCl) 
        /// </summary>
        /// <param name="PNBlackboardID">Blackboard row to run against</param>
        /// <param name="perKilo">If to use perkilo rules</param>
        /// <param name="duplicateIngredients">List of duplicate ingredients</param>
        /// <returns>map of ingredient (in upper case) to PNCode (note ingredient can be in form NaCl)</returns>
        public static Dictionary<string,string> PNIngredientsToProducts(int PNBlackboardID, bool perKilo, ref List<string> duplicateIngredients)
        {
            DataSet ds = new DataSet();
            List<SqlParameter> parameters = new List<SqlParameter>();
            Dictionary<string,string> pnCodeToIngredient = new Dictionary<string,string>();

            using (SqlDataAdapter dataAdapter = new SqlDataAdapter("pPNIngredientsToProducts", Database.ConnectionString))
            {
                dataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

                // Set paraemeters
                parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));
                parameters.Add(new SqlParameter("@LocationID_site",  SessionInfo.SiteID   ));
                parameters.Add(new SqlParameter("@PNBlackboardID",   PNBlackboardID       ));
                parameters.Add(new SqlParameter("@perkilo",          perKilo              ));

                // Run
                dataAdapter.SelectCommand.Parameters.AddRange(parameters.ToArray());
                dataAdapter.Fill(ds, "Data");

                // Convert returned ds to ingredient to PNCode map
                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    // Get PNCode
                    string PNCode = null;
                    if (row["PNCode"] != DBNull.Value)
                        PNCode = (string)row["PNCode"];

                    // Get ingredient
                    string ingredient = null;
                    if (row["Ingredient"] != DBNull.Value)
                        ingredient = (string)row["Ingredient"];

                    // Add to map
                    if (!string.IsNullOrEmpty(PNCode) && !string.IsNullOrEmpty(ingredient))
                    {
                        // TFS32363 20Apr12 XN Prevent adding duplicate ingredient rules to map (prevents crash)
                        if (pnCodeToIngredient.ContainsKey(ingredient))
                        {
                            if (duplicateIngredients == null)
                                duplicateIngredients = new List<string>();
                            if (!duplicateIngredients.Contains(ingredient))
                                duplicateIngredients.Add(ingredient);
                        }
                        else
                            pnCodeToIngredient.Add(ingredient.ToUpper(), PNCode);
                    }
                }
            }
            
            return pnCodeToIngredient;
        }

        /// <summary>
        /// Calls sp pPNCheckRules to run the stabilyt and dose range check rules (RuleType 4) against the backboard row
        /// Returns list of rules that failed
        /// </summary>
        /// <param name="PNBlackboardID">Blackboard row to run against</param>
        /// <param name="perKilo">If to use perkilo rules</param>
        /// <returns>list of rules that failed</returns>
        public static IEnumerable<PNBrokenRule> PNCheckRules(int PNBlackboardID, bool perKilo)
        {
            DataSet ds = new DataSet();
            List<SqlParameter> parameters = new List<SqlParameter>();
            List<PNBrokenRule> brokenRules = new List<PNBrokenRule>();

            using (SqlDataAdapter dataAdapter = new SqlDataAdapter("pPNCheckRules", Database.ConnectionString))
            {
                dataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;

                // Set paraemeters
                parameters.Add(new SqlParameter("@CurrentSessionID", SessionInfo.SessionID));
                parameters.Add(new SqlParameter("@LocationID_site",  SessionInfo.SiteID   ));
                parameters.Add(new SqlParameter("@PNBlackboardID",   PNBlackboardID       ));
                parameters.Add(new SqlParameter("@RegimenValidation",true                 ));
                parameters.Add(new SqlParameter("@perkilo",          perKilo              ));

                // Run
                dataAdapter.SelectCommand.Parameters.AddRange(parameters.ToArray());
                dataAdapter.Fill(ds, "Data");

                // Convert returned ds to ingredient to PNCode map
                foreach (DataRow row in ds.Tables[0].Rows)
                {
                    PNBrokenRule rule = new PNBrokenRule();
                    rule.RuleNumber = (int   )row["RuleNumber" ];
                    rule.Type       = (bool  )row["Critical"   ] ? PNBrokenRuleType.Critical : PNBrokenRuleType.Warning;
                    rule.Description= (string)row["Description"];
                    rule.Explanation= (string)row["Explanation"];

                    brokenRules.Add(rule);
                }
            }
            
            return brokenRules;
        }
    }
}
