//===========================================================================
//
//							       PNRegimen.cs
//
//  Provides access to PNRegimen table (hold the PN presription info by the pharmacist). 
//
//  Class is derived from EpisodeOrder (and then Request).
//
//  SP for this object should return all fields from EpisodeOrder, and Request, table.
//
//  Only supports reading, updating, and inserting.
//
//	Modification History:
//	19Dec11 XN Written
//  25Mar12 XN TFS29994 Removed PNRegimen.CreateName, and added
//                      PNRegimenRow.CreateName, PNRegimenRow.ExtractBaseName,
//                      and ModificationNumber, for more advanced name generation
//  20Feb13 XN 30734    Added UpdateTotalValues so regimen totals go to reporting db.
//  10Sep14 XN 95618    Update CreateName to use standard regimen name if supplied
//  18Sep14 XN 30679    When creating reg name changed from "for dosing weight of x kg" to "for x kg"
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    /// <summary>Represents a row in the PNRegimen table (inherites from EpisodeOrderRow)</summary>
    public class PNRegimenRow : EpisodeOrderRow
    {
        #region Constants
        private static readonly string ModificationFormatString = " (Modification {0})";
        #endregion


        #region General info
        public int LocationID_Site
        {
            get { return FieldToInt(RawRow["LocationID_Site"]).Value;   } 
            set { RawRow["LocationID_Site"] = IntToField(value);        } 
        }

        /// <summary>If the aqueous and lipid parts of the infusion are combined</summary>
        public bool IsCombined
        {
            get { return FieldToBoolean(RawRow["IsCombined"]).Value;  } 
            set { RawRow["IsCombined"] = BooleanToField(value);       } 
        }

        /// <summary>If regimen should go through central line only</summary>
        public bool CentralLineOnly
        {
            get { return FieldToBoolean(RawRow["CentralLineOnly"]).Value; } 
            set { RawRow["CentralLineOnly"] = BooleanToField(value);      } 
        }

        /// <summary>This is the prescriber's suggested hours for aqueous or combined part of the regimen</summary>
        public double InfusionHoursAqueousOrCombined
        {
            get { return FieldToDouble(RawRow["InfusionHoursAqueousOrCombined"]).Value;  } 
            set { RawRow["InfusionHoursAqueousOrCombined"] = DoubleToField(value);       } 
        }

        /// <summary>This is the prescriber's suggested hours for lipid part of the regimen</summary>
        public double InfusionHoursLipid
        {
            get { return FieldToDouble(RawRow["InfusionHoursLipid"]).Value; } 
            set { RawRow["InfusionHoursLipid"] = DoubleToField(value);      } 
        }

        /// <summary>This is the prescriber's suggested hours for lipid part of the regimen (not really used check that NumberOfSyringes is 0 for not supplied)</summary>
        public bool SupplyLipidSyringe
        {
            get { return FieldToBoolean(RawRow["SupplyLipidSyringe"]).Value; } 
            set { RawRow["SupplyLipidSyringe"] = BooleanToField(value);      } 
        }
        
        /// <summary>Returns number of syringes to use (0 if not using syringes)</summary>
        public int NumberOfSyringes
        {
            get { return FieldToInt(RawRow["NumberOfSyringes"]) ?? 0;  } 
            set { RawRow["NumberOfSyringes"] = IntToField(value);      } 
        }

        /// <summary>If a single bag is to be supplied over 48 hours rather than standard 24 hours (all values and calculations are still expressed as 24 Hours)</summary>
        public bool Supply48Hours
        {
            get { return FieldToBoolean(RawRow["Supply48Hours"]).Value; } 
            set { RawRow["Supply48Hours"] = BooleanToField(value);      } 
        }

        /// <summary>Amount of overage for an aqueous part or combined regimen</summary>
        public double? OverageAqueousOrCombined
        {
            get { return FieldToDouble(RawRow["OverageAqueousOrCombined"]);  } 
            set { RawRow["OverageAqueousOrCombined"] = DoubleToField(value); } 
        }

        /// <summary>Amount of overage for lipid part of regimen</summary>
        public double? OverageLipid
        {
            get { return FieldToDouble(RawRow["OverageLipid"]);  } 
            set { RawRow["OverageLipid"] = DoubleToField(value); } 
        }

        public int SessionLock
        {
            get { return FieldToInt(RawRow["SessionLock"]).Value;   } 
            set { RawRow["SessionLock"] = IntToField(value);        } 
        }

        public bool Cancelled
        {
            get { return FieldToBoolean(RawRow["Request Cancellation"], false).Value;   } 
            private set { RawRow["Request Cancellation"] = BooleanToField(value);       }   // Private as does not save to db
        }

        public bool PNAuthorised
        {
            get         { return FieldToBoolean(RawRow["PNAuthorised"], false).Value;   }
            private set { RawRow["PNAuthorised"] = BooleanToField(value);               }   // Private as does not save to db
        }

        public bool IsLocked
        {
            get { return this.SessionLock == SessionInfo.SessionID; }
        }

        public double SupplyMultiplier
        {
            get { return Supply48Hours ? 2.0 : 1.0; }
        }

        #endregion

        #region Ingredients
        /// <summary>Regimens suggested volume in ml.</summary>
        public double? VolumeInml
        {
            get { return FieldToDouble(RawRow["Volume_ml"]);  }
            set { RawRow["Volume_ml"] = DoubleToField(value); }
        }
        
        /// <summary>Gets regimens suggested ingredeint value</summary>
        public double? GetIngredient(string dbName)
        {
            return FieldToDouble(RawRow[dbName]);
        }

        /// <summary>Sets regimens suggested ingredeint value</summary>
        public void SetIngredient(string dbName, double? value)
        {
            RawRow[dbName] = DoubleToField(value);
        }
        #endregion

        #region Modified Info
        /// <summary>DB field LastModDate</summary>
        public DateTime LastModifiedDate
        {
            get { return FieldToDateTime(RawRow["LastModDate"]).Value;   } 
            set { RawRow["LastModDate"] = DateTimeToField(value);        } 
        }

        /// <summary>DB field LastModEntityID_User</summary>
        public int LastModifiedEntityID_User
        {
            get { return FieldToInt(RawRow["LastModEntityID_User"]).Value;   } 
            set { RawRow["LastModEntityID_User"] = IntToField(value);        } 
        }

        /// <summary>DB field LastModTerminal</summary>
        public int LastModifiedLocationID
        {
            get { return FieldToInt(RawRow["LastModTerminal"]).Value;   } 
            set { RawRow["LastModTerminal"] = IntToField(value);        } 
        }

        /// <summary>The modification number of the regimen, forms non-editable part of the name</summary>
        public int ModificationNumber
        {
            get { return FieldToInt(RawRow["ModificationNumber"]).Value;   } 
            set { RawRow["ModificationNumber"] = IntToField(value);        } 
        }
        #endregion

        #region Public Methods 
        /// <summary>
        /// Creates a new regimen name (modification name is not added if =1)
        ///     {baseName} (modification {modificationNumber})
        /// </summary>
        /// <param name="baseName">Base regimen name to start with</param>
        public void CreateName(string baseName)
        {
            string modificationSuffix = string.Empty;
            if (this.ModificationNumber > 0)
                modificationSuffix = string.Format(ModificationFormatString, this.ModificationNumber);

            // Should never happen but just to be save
            baseName.SafeSubstring(0, PNRegimen.GetColumnInfo().DescriptionLength - modificationSuffix.Length);

            // Return new name
            this.Description = baseName + modificationSuffix;
        }

        /// <summary>
        /// Creates the regimen name from the presciprtion
        ///     PN {proforma\std regimen name} {48 hour} for dosing weight of x kg (Modiciation x) 
        /// </summary>
        /// <param name="prescription">Prescription</param>
        /// <param name="standardRegimen">Standard regimen name if applying standard regimen 10Sep14 XN 95618</param>
        public void CreateName(PNPrescriptionRow prescription, PNStandardRegimenRow standardRegimen = null)
        {
            StringBuilder name = new StringBuilder("PN");

            // Add proforma, or standard regimen
            // Removes the Rx prefix from proforma's, and the Standard Regimen prefix
            // TFS29994 28Mar12 XN Updates to allow creation of regimen name to handle changes in regimen            
            //if (!StringExtensions.IsNullOrEmptyAfterTrim(prescription.RegimenName))
            //{
            //    name.Append(" ");
            //    if (prescription.RegimenName.StartsWith("Rx ", StringComparison.CurrentCultureIgnoreCase))
            //        name.Append(prescription.RegimenName.SafeSubstring(3, prescription.RegimenName.Length));
            //    else if (prescription.RegimenName.StartsWith("Standard Regimen ", StringComparison.CurrentCultureIgnoreCase))
            //        name.Append(prescription.RegimenName.SafeSubstring(17, prescription.RegimenName.Length));
            //    else
            //        name.Append(prescription.RegimenName);

            //    // Add if proforma has been edited
            //    if (prescription.Description.Contains("(edited)"))
            //        name.Append(" (edited)");
            //}
            string baseName = (standardRegimen == null) ? prescription.RegimenName : standardRegimen.RegimenName;   // 95618 0Sep14 XN Added handling of standard regimen name
            if (!StringExtensions.IsNullOrEmptyAfterTrim(baseName))
            {
                name.Append(" ");
                if (baseName.StartsWith("Rx ", StringComparison.CurrentCultureIgnoreCase))
                    name.Append(baseName.SafeSubstring(3, baseName.Length));
                else if (baseName.StartsWith("Standard Regimen ", StringComparison.CurrentCultureIgnoreCase))
                    name.Append(baseName.SafeSubstring(17, baseName.Length));
                else
                    name.Append(baseName);

                // Add if proforma has been edited
                if (prescription.Description.Contains("(edited)"))
                    name.Append(" (edited)");
            }

            // Add if 48 Hour bag
            if (this.Supply48Hours)
                name.Append(" 48 Hour bag");

            // Add dosing weight 
            if (PNSettings.ViewAndAdjust.SetRegimenNameToFullDosingWeightText)
                name.AppendFormat(" for dosing weight of {0:0.##} kg", prescription.DosingWeightInkg);
            else
                name.AppendFormat(" for {0:0.##} kg", prescription.DosingWeightInkg);   // 18Sep14 XN 30679 added optional short text option

            // Add if per kilo rules
            if (prescription.PerKiloRules)
                name.Append(" (per kilo prescription)");

            // Add modification number
            if (this.ModificationNumber > 0)
                name.AppendFormat(ModificationFormatString, this.ModificationNumber);

            this.Description = name.ToString();
        }

        /// <summary>
        /// Extracts base name of regimen. 
        /// Basically the Description with the (modification {modificationNumber}) removed
        /// </summary>
        /// <param name="regimen">Regimen to extract base name form</param>
        /// <returns>Regimen base name</returns>
        public string ExtractBaseName()
        {
            string modificationSuffix = string.Format(ModificationFormatString, this.ModificationNumber);
            string name = this.Description;

            if (name.EndsWith(modificationSuffix))
                name = name.Replace(modificationSuffix, string.Empty);

            return name;
        }

        /// <summary>
        /// Saves all PNRegimenItem to the PNRegimenProductVolume table against this PNRegimenItem (will replace existing data)
        /// Saves immediatly to the db.
        /// Will also update PN audit log.
        /// </summary>
        /// <param name="regimenItems">PN products and their volumes ot be saved</param>
        /// <param name="overage">Add product overage</param>
        public void SaveRegimenItems(IEnumerable<PNRegimenItem> regimenItems, IEnumerable<double> overage)
        {
            // Load in the existing list of products and volumes
            PNRegimenProductVolume dbregimenItems = new PNRegimenProductVolume();
            dbregimenItems.LoadByRequestID(this.RequestID);

            // Take copy of the data (for audit log)
            PNRegimenProductVolume dbregimenItemsTemp = new PNRegimenProductVolume();
            dbregimenItemsTemp.CopyFrom(dbregimenItems);

            PNProduct products = PNProduct.GetInstance();

            // Update or add rows
            for (int i = 0; i < regimenItems.Count(); i++)
            {
                PNRegimenItem item = regimenItems.ElementAt(i);
                int productID = products.FindByPNCode(item.PNCode).PNProductID;
                
                // Get existing row (or add a new one)
                PNRegimenProductVolumeRow dbitem = dbregimenItems.FindByPNProductID(productID);
                if (dbitem == null)
                    dbitem = dbregimenItems.Add();

                dbitem.RequestID             = this.RequestID;
                dbitem.PNProductID           = productID;
                dbitem.VolumeInml            = item.VolumneInml;
                dbitem.TotalVolumeIncOverage = overage.ElementAt(i).To3SigFigish();
            }

            // Remove any existing items not present in existing set of data
            // Done like this rather than just removing the excess items to prevent problems trying to save after deleteing and inserting causing unique constraint to error.
            for (int i = dbregimenItems.Count - 1; i >= 0; i--)
            {
                int    productID = dbregimenItems[i].PNProductID;
                string PNCode    = products.FindByPNProductID(productID).PNCode;

                if (regimenItems.FindByPNCode(PNCode) == null)
                    dbregimenItems.RemoveAt(i);
            }

            // Update audit log
            StringBuilder log = new StringBuilder();
            PNLog.CompareDataRows(log, dbregimenItemsTemp.Select(r => r.RawRow), dbregimenItems.Select(r => r.RawRow));
            if (log.Length == 0)
                log.Append("No products in regimen");
            PNLog.WriteToLog(SessionInfo.SiteID, this.EntityID_Owner, this.EpisodeID, null, null, this.RequestID, "Products saved for regimen '" + this.Description + "'\n" + log.ToString(), string.Empty);

            /// And save
            dbregimenItems.Save();
        }

        /// <summary>Reads PNRegimenItem from db from PNRegimenProductVolume table</summary>
        public IEnumerable<PNRegimenItem> GetRegimenItems()
        {
            // Get list of products
            PNProduct products = PNProduct.GetInstance();

            // Load PNRegimenProductVolume items 
            PNRegimenProductVolume items = new PNRegimenProductVolume();
            if (this.RawRow["RequestID"] != DBNull.Value)
                items.LoadByRequestID(this.RequestID);

            // Converts PNRegimenProductVolume to PNRegimenItem
            List<PNRegimenItem> newItems = new List<PNRegimenItem>();
            foreach (PNRegimenProductVolumeRow dbitem in items)
            {
                string pnCode = products.FindByPNProductID(dbitem.PNProductID).PNCode;
                PNRegimenItem item = new PNRegimenItem(pnCode, dbitem.VolumeInml);
                newItems.Add(item);
            }

            return newItems;
        }

        /// <summary>
        /// Sets PNRegimen.Total{Ingredient} and  PNRegimen.Total{Ingredient}PerKg DB field value. (30734)
        /// This total ingredient values for regimen, for for reporting db purposes
        /// </summary>
        public void UpdateTotalValues(IEnumerable<PNRegimenItem> regimenItems, double dosingWeightInkg)
        {
            DataColumnCollection columns = this.RawRow.Table.Columns;
            foreach (PNIngredientRow ing in PNIngredient.GetInstance().FindByForPNProduct(true))
            {
                double? totalIng = regimenItems.CalculateTotal(ing.DBName);
                if (columns.Contains("Total" + ing.DBName))
                    this.RawRow["Total" + ing.DBName] = DoubleToField(totalIng);
                if (columns.Contains("Total" + ing.DBName + "Perkg"))
                {
                    if (totalIng != null)
                        this.RawRow["Total" + ing.DBName + "Perkg"] = DoubleToField(totalIng / dosingWeightInkg);
                }
            }
        }

        /// <summary>Authorise the regimen</summary>
        public void Authorise()
        {
            SetStatus("PNAuthorised", true);

            // Set locally for completeness
            PNAuthorised = true;
        }

        /// <summary>Returns if regimen has a supply request</summary>
        public bool HasSupplyRequest()
        {
            if (this.RawRow.RowState == System.Data.DataRowState.Added)
                return false;

            return Database.ExecuteSQLScalar<int?>("SELECT TOP 1 rs.RequestID FROM RequestStatus rs JOIN PNSupplyRequest sr on rs.RequestID = sr.RequestID WHERE (Request__RequestID_Parent={0}) AND ([Request Cancellation]=0)", this.RequestID).HasValue;
        }

        public bool CanCancel(out string reason)
        {
            reason = string.Empty;
            return true;
        }

        /// <summary>
        /// Creates a copy for the PNRegimenRow
        /// if as new item then will 
        ///     clear the PK (so saves as new row)
        ///     Lock the row to this user
        ///     Clears the cancelled, and PNAuthroise statuses
        /// </summary>
        /// <param name="row">row to copy</param>
        /// <param name="asNew">If create row as new</param>
        public void CopyFrom(PNRegimenRow row, bool asNew)
        {
            base.CopyFrom(row);

            if (asNew)
            {
                // Force to add mode for regimen, and clear the PK
                this.RawRow.AcceptChanges();
                this.RawRow.SetAdded();
                this.RawRow.Table.Columns["RequestID"].ReadOnly = false;
                this.RawRow["RequestID"] = DBNull.Value;
                this.RawRow.Table.Columns["RequestID"].ReadOnly = true;

                this.SessionLock = SessionInfo.SessionID;
                this.Cancelled   = false;
                this.PNAuthorised= false;
                this.CreatedDate = DateTime.Now;
            }
        }
        #endregion
    }

    /// <summary>Provides column information about the PNRegimen table (inherites from EpisodeOrderColumnInfo)</summary>
    public class PNRegimenColumnInfo : EpisodeOrderColumnInfo
    {
        public PNRegimenColumnInfo() : base("PNRegimen") { }
    }

    /// <summary>Represents the PNRegimen table</summary>
    public class PNRegimen : RequestBaseTable<PNRegimenRow, PNRegimenColumnInfo>
    {
        public PNRegimen() : base("PNRegimen", "EpisodeOrder", "Request") { }

        #region Public Methods
        public void LoadByRequestID(int requestID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@RequestID", requestID));
            LoadBySP("pPNRegimenByRequestID", parameters);
        }

        public void LoadByPrescription(int requestID_Parent, bool includeCancelled)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@RequestID_Parent", requestID_Parent));
            parameters.Add(new SqlParameter("@IncludeCancelled", includeCancelled));
            LoadBySP("pPNRegimenByRequestID_Parent", parameters);
        }
        #endregion

        #region Protected Methods
        /// <summary>
        /// Override base class to add in columns
        ///     Request Cancellation
        ///     PNAuthorised
        /// </summary>
        protected override void CreateEmpty()
        {
            base.CreateEmpty();
            Table.Columns.Add("Request Cancellation", typeof(bool));
            Table.Columns.Add("PNAuthorised",         typeof(bool));
        }
        #endregion

        #region public static methods
        /// <summary>Returns number of regimens attached to parent prescription</summary>
        /// <param name="requestID_Parent">Parent prescription ID</param>
        public static int GetRegimenCount(int requestID_Parent)
        {
            return Database.ExecuteSQLScalar<int>("SELECT COUNT(*) FROM Request WHERE RequestID_Parent={0}", requestID_Parent);
        }
        #endregion
    }
}
