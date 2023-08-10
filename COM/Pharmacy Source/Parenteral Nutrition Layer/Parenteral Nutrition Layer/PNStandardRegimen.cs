using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using System.Data.SqlClient;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.icwdatalayer;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    /// <summary>Represents a row in the PNStandardRegimen table</summary>
    public class PNStandardRegimenRow : BaseRow
    {
        public int PNStandardRegimenID
        {
            get { return FieldToInt(RawRow["PNStandardRegimenID"]).Value;   } 
        }
        
        public string RegimenName
        {
            get { return FieldToStr(RawRow["RegimenName"], false, string.Empty);  } 
            set { RawRow["RegimenName"] = StrToField(value, false);               } 
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"], false, string.Empty);  } 
            set { RawRow["Description"] = StrToField(value, false);               } 
        }

        public bool PerKilo
        {
            get { return FieldToBoolean(RawRow["PerKilo"]).Value;  } 
            set { RawRow["PerKilo"] = BooleanToField(value);       } 
        }

        public bool InUse
        {
            get { return FieldToBoolean(RawRow["InUse"]).Value; } 
            set { RawRow["InUse"] = BooleanToField(value);      } 
        }

        public string Information
        {
            get { return FieldToStr(RawRow["Information"], false, string.Empty);  } 
            set { RawRow["Information"] = StrToField(value, false);               } 
        }

        public DateTime LastModifiedDate
        {
            get { return FieldToDateTime(RawRow["LastModDate"]).Value;  } 
            set { RawRow["LastModDate"] = DateTimeToField(value);       } 
        }

        public int LastModifiedEntityID_User
        {
            get { return FieldToInt(RawRow["LastModEntityID_User"]).Value;  } 
            set { RawRow["LastModEntityID_User"] = IntToField(value);       } 
        }

        public int LastModifiedTerminal
        {
            get { return FieldToInt(RawRow["LastModTerminal"]).Value;  } 
            set { RawRow["LastModTerminal"] = IntToField(value);       } 
        }

        #region Public Methods
        /// <summary>
        /// Saves all PNRegimenItem to the PNStandardRegimenPNCodeVolume table against this PNRegimenItem (will replace existing data)
        /// Saves immediatly to the db.
        /// Will also update PN audit log.
        /// Note: if regimen is for pead then volume is in ml/kg
        /// </summary>
        /// <param name="regimenItems">PN products and their volumes ot be saved</param>
        public void SaveRegimenItems(IEnumerable<PNRegimenItem> regimenItems)
        {
            // Load in the existing list of products and volumes
            PNStandardRegimenPNCodeVolume dbregimenItems = new PNStandardRegimenPNCodeVolume();
            dbregimenItems.LoadByPNStandardRegimenID(this.PNStandardRegimenID);

            // Take copy of the data (for audit log)
            PNStandardRegimenPNCodeVolume dbregimenItemsTemp = new PNStandardRegimenPNCodeVolume();
            dbregimenItemsTemp.CopyFrom(dbregimenItems);

            //PNProduct products = PNProduct.GetInstance();

            // Update or add rows
            for (int i = 0; i < regimenItems.Count(); i++)
            {
                PNRegimenItem item = regimenItems.ElementAt(i);
                
                // Get existing row (or add a new one)
                PNStandardRegimenPNCodeVolumeRow dbitem = dbregimenItems.FindByPNCode(item.PNCode);
                if (dbitem == null)
                    dbitem = dbregimenItems.Add();

                dbitem.PNStandardRegimenID  = this.PNStandardRegimenID;
                dbitem.PNCode               = item.PNCode;
                dbitem.Volume               = item.VolumneInml;
            }

            // Remove any existing items not present in existing set of data
            // Done like this rather than just removing the excess items to prevent problems trying to save after deleteing and inserting causing unique constraint to error.
            for (int i = dbregimenItems.Count - 1; i >= 0; i--)
            {
                string PNCode = dbregimenItems[i].PNCode;

                if (regimenItems.FindByPNCode(PNCode) == null)
                    dbregimenItems.RemoveAt(i);
            }

            // Update audit log
            StringBuilder log = new StringBuilder();
            PNLog.CompareDataRows(log, dbregimenItemsTemp.Select(r => r.RawRow), dbregimenItems.Select(r => r.RawRow));
            if (log.Length == 0)
                log.Append("No products in std. regimen");
            PNLog.WriteToLog(null, null, null, null, null, null, "Products saved for std. regimen '" + log.ToString(), string.Empty);

            /// And save
            dbregimenItems.Save();
        }

        /// <summary>
        /// Reads PNRegimenItem from db from PNRegimenProductVolume table
        /// Note: if regimen is for pead then volume is in ml/kg
        /// </summary>
        /// <param name="validProducts">List of valid PNProducts (will be used to filter the list)</param>
        public IEnumerable<PNRegimenItem> GetRegimenItems()
        {
            // Load PNRegimenProductVolume items 
            PNStandardRegimenPNCodeVolume items = new PNStandardRegimenPNCodeVolume();
            items.LoadByPNStandardRegimenID(this.PNStandardRegimenID);

            // Converts PNRegimenProductVolume to PNRegimenItem
            List<PNRegimenItem> newItems = new List<PNRegimenItem>();
            foreach (PNStandardRegimenPNCodeVolumeRow dbitem in items)
            {
                PNRegimenItem item = new PNRegimenItem(dbitem.PNCode, dbitem.Volume);
                newItems.Add(item);
            }

            return newItems;
        }
        public IEnumerable<PNRegimenItem> GetRegimenItems(IEnumerable<PNProductRow> validProducts)
        {
            List<PNRegimenItem> regimenItems = this.GetRegimenItems().ToList();
            regimenItems.RemoveAll(r => validProducts.FindByPNCode(r.PNCode) == null);
            return regimenItems.ToList();
        }

        /// <summary>Returns user that last modified the regimen (or null if none)</summary>
        public PersonRow GetLastModifiedUser()
        {
            Person persons = new Person();
            persons.LoadByEntityID(this.LastModifiedEntityID_User);
            return persons == null ? null : persons[0];
        }

        public LocationRow GetLastModifiedTerminal()
        {
            Location locations = new Location();
            locations.LoadByLocationID(this.LastModifiedTerminal);
            return locations.Any() ? locations[0] : null;
        }

        public override string ToString()
        {
            return this.RegimenName + " " + this.Description;
        }
        #endregion
    }

    /// <summary>Provides column information about the PNStandardRegimen table</summary>
    public class PNStandardRegimenColumnInfo : BaseColumnInfo
    {
        public PNStandardRegimenColumnInfo() : base("PNStandardRegimen") { }

        public int RegimenNameLength { get { return base.FindColumnByName("RegimenName").Length; } }
        public int DescriptionLength { get { return base.FindColumnByName("Description").Length; } }
    }

    /// <summary>Represents the PNStandardRegimen table</summary>
    public class PNStandardRegimen : BaseTable2<PNStandardRegimenRow, PNStandardRegimenColumnInfo>
    {
        public PNStandardRegimen() : base("PNStandardRegimen") { }

        /// <summary>Load PN standard regimens that are in-use</summary>
        /// <param name="perKilo">If per kilo rules</param>
        public void LoadByPerKiloAndInUse( bool perKilo, bool inUseOnly)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@PerKilo",   perKilo  ));
            parameters.Add(new SqlParameter("@InUseOnly", inUseOnly));
            LoadBySP("pPNStandardRegimenByPerKiloAndInUse", parameters);
        }

        /// <summary>Load standard regimen by ID</summary>
        /// <param name="pnStandardRegimenID">standard regimen ID</param>
        public void LoadByID(int pnStandardRegimenID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@PNStandardRegimenID", pnStandardRegimenID));
            LoadBySP("pPNStandardRegimenByID", parameters);
        }

        /// <summary>Load PN product by regimen name (case insenitive)</summary>
        /// <param name="description">Regimen name to load by</param>
        public void LoadByRegimenName(string regimenName)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@RegimenName", regimenName));
            LoadBySP("pPNStandardRegimenByRegimenName", parameters);
        }

        /// <summary>Gets standard regimen with specified ID</summary>
        /// <param name="pnStandardRegimenID">Standard regimen ID to load</param>
        public static PNStandardRegimenRow GetByID(int pnStandardRegimenID)
        {
            PNStandardRegimen standardRegimen = new PNStandardRegimen();
            standardRegimen.LoadByID(pnStandardRegimenID);
            return standardRegimen.FirstOrDefault();
        }
    }
}
