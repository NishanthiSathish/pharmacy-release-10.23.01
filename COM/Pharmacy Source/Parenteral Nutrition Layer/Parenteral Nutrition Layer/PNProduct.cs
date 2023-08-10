//===========================================================================
//
//							       PNProduct.cs
//
//  Provides access to PNProduct table (hold the PN product info). 
//  Products are saved by site
//
//  Unlike other tables the you do not create an instance of PNProduct, instead
//  you do PNProduct.GetInstance(), which will return a cached list of all the 
//  PN products in the database.
//
//  To ensure that the products are reloaded call PNProduct.GetInstance(true)
//  Or set the flag in the WConfigruation file 
//  Category: D|PN
//  Section: PNProducts
//  Key: Reload
//  that ensures the products are reloaded on next PNProduct.GetInstance() call.
//
//  There is also a class PNProductEnumerableExtensions to provide extension 
//  methods to IEnumerable{PNProductRow} used to find loaded items.
//
//  Only supports reading, inserting, and updating.
//  Uses conflict option CompareAllSearchableValues
//
//	Modification History:
//	20Oct11 XN Written
//  21Dec12 AJk Added StockLookup
//  12Sep14 XN  95647 Override base class Add to set BaxaMMIg as 0
//  26Oct15 XN  Added LoadByPNCode converted GetBySiteIDAndPNCode to FirstOrDefault 106278
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
using System;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    /// <summary>If product is Aqueous or Lipid</summary>
    public enum PNProductType
    {
        [EnumDBCode("A")]
        Aqueous,

        [EnumDBCode("L")]
        Lipid,

        /// <summary>Not an actual type but used by other parts of the system</summary>
        [EnumDBCode("C")]
        Combined,
    }

    /// <summary>Represents a row in the PNProduct table</summary>
    public class PNProductRow : BaseRow
    {
        #region General
        public int PNProductID
        {
            get { return (int)FieldToInt(RawRow["PNProductID"]); }
        }

        public int LocationID_Site
        {
            get { return FieldToInt(RawRow["LocationID_Site"]).Value; }
            set { RawRow["LocationID_Site"] = IntToField(value);      }
        }

        public bool InUse
        {
            get { return FieldToBoolean(RawRow["InUse"]).Value; }
            set { RawRow["InUse"] = BooleanToField(value);      }
        }

        public bool ForPaediatric
        {
            get { return FieldToBoolean(RawRow["ForPaed"]).Value; }
            set { RawRow["ForPaed"] = BooleanToField(value);      }
        }

        public bool ForAdult
        {
            get { return FieldToBoolean(RawRow["ForAdult"]).Value; }
            set { RawRow["ForAdult"] = BooleanToField(value);      }
        }

        public int SortIndex
        {
            get { return FieldToInt(RawRow["SortIndex"]).Value;  }
            set { RawRow["SortIndex"] = IntToField(value);       }
        }

        public string PNCode
        {
            get { return FieldToStr(RawRow["PNCode"], true, string.Empty); }
            set { RawRow["PNCode"] = StrToField(value, false);             }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"]);  }
            set { RawRow["Description"] = StrToField(value); }
        }

        public PNProductType AqueousOrLipid
        {
            get { return FieldToEnumByDBCode<PNProductType>(RawRow["AqueousOrLipid"]);  }
            set { RawRow["AqueousOrLipid"] = EnumToFieldByDBCode<PNProductType>(value); }
        }

        public string StockLookup
        {
            get { return FieldToStr(RawRow["StockLookup"]);  }
            set { RawRow["StockLookup"] = StrToField(value); }
        }
        #endregion

        #region Details
        public int PreMix
        {
            get { return FieldToInt(RawRow["PreMix"]).Value;  }
            set { RawRow["PreMix"] = IntToField(value);       }
        }

        /// <summary>Note: When not set in editor will be 0</summary>
        public double MaxmlTotal
        {
            get { return FieldToDouble(RawRow["MaxmlTotal"]).Value;  }
            set { RawRow["MaxmlTotal"] = DoubleToField(value);       }
        }

        /// <summary>Note: When not set in editor will be 0</summary>
        public double MaxmlPerKg
        {
            get { return FieldToDouble(RawRow["MaxmlPerKg"]).Value;  }
            set { RawRow["MaxmlPerKg"] = DoubleToField(value);       }
        }

        public bool SharePacks
        {
            get { return FieldToBoolean(RawRow["SharePacks"]).Value;  }
            set { RawRow["SharePacks"] = BooleanToField(value);       }
        }

        public string BaxaMMIg
        {
            get { return FieldToStr(RawRow["BaxaMMIg"]);  }
            set { RawRow["BaxaMMIg"] = StrToField(value); }
        }

        /// <summary>Note: When not set in editor will be 0 (EXCEPT FOR WATER WATI000 WHICH IS 0)</summary>
        public double mOsmperml
        {
            get { return FieldToDouble(RawRow["mOsmperml"]).Value;  }
            set { RawRow["mOsmperml"] = DoubleToField(value);       }
        }

        /// <summary>Note: When not set in editor will be 0</summary>
        public double gH2Operml
        {
            get { return FieldToDouble(RawRow["gH2Operml"]).Value;  }
            set { RawRow["gH2Operml"] = DoubleToField(value);       }
        }

        /// <summary>Note: When not set in editor will be 0</summary>
        public double SpGrav
        {
            get { return FieldToDouble(RawRow["SpGrav"]).Value;  }
            set { RawRow["SpGrav"] = DoubleToField(value);       }
        }
        #endregion

        #region Modified data
        /// <summary>Date field was last modified</summary>
        public DateTime? LastModifiedDate
        {
            get { return FieldToDateTime(RawRow["LastModDate"]);  }
            set { RawRow["LastModDate"] = DateTimeToField(value); }
        }

        /// <summary>
        /// Initials of user who last modified the record
        /// ASC if from ascribe DSS.
        /// </summary>
        public string LastModifiedUserInitials
        {
            get { return FieldToStr(RawRow["LastModUser"]);    }
            set { RawRow["LastModUser"] = StrToField(value);   }
        }

        /// <summary>
        /// Terminal of user who last modified the record
        /// Unknown if from ascribe DSS.
        /// </summary>
        public string LastModifiedTerminal
        {
            get { return FieldToStr(RawRow["LastModTerm"]);    }
            set { RawRow["LastModTerm"] = StrToField(value);   }
        }

        /// <summary>Info provided by ascribe DSS of an update</summary>
        public string DSSInfo
        {
            get { return FieldToStr(RawRow["Info"]);    }
            set { RawRow["Info"] = StrToField(value);   }
        }
        #endregion

        #region Ingredients
        /// <summary>
        /// Container volume in ml.
        /// All ingredients for the product are calculated based on this volume.
        /// </summary>
        public double ContainerVolumeInml
        {
            get { return FieldToDouble(RawRow["ContainerVol_ml"]).Value;  }
            set { RawRow["ContainerVol_ml"] = DoubleToField(value);       }
        }
        
        /// <summary>Gets an ingredient value</summary>
        /// <param name="dbName">DB name of the ingredient</param>
        public double? GetIngredient(string dbName)
        {
            return FieldToDouble(RawRow[dbName]);
        }

        /// <summary>Sets an ingredient value</summary>
        /// <param name="dbName">DB name of the ingredient</param>
        /// <param name="value">Value to set</param>
        public void SetIngredient(string dbName, double? value)
        {
            RawRow[dbName] = DoubleToField(value);
        }
        #endregion

        #region Calculation Methods
        /// <summary>
        /// Caculates ingredient value for a given product volume. 
        ///     product ingredient value * (volume / product container volume)  
        /// </summary>
        /// <param name="ingredientDBName">Ingredient value to calcualte</param>
        /// <param name="volumeInml">Product volume</param>
        /// <returns>ingredient value</returns>
        public double CalculateIngredientValue(string ingredientDBName, double volumeInml)
        {
            if (ingredientDBName == PNIngDBNames.Volume)
                return volumeInml;
            else if (ingredientDBName == PNIngDBNames.OrganicPhosphate)
            {
                // To calcaulte orgain phosphate need to calculate total, and inorganic, and take one from other
                double phosphateTotal     = this.CalculateIngredientValue(PNIngDBNames.Phosphate,          volumeInml);
                double inorganicPhosphate = this.CalculateIngredientValue(PNIngDBNames.InorganicPhosphate, volumeInml);
                return phosphateTotal - inorganicPhosphate;
            }
            else
                return (this.GetIngredient(ingredientDBName) ?? 0.0) * (volumeInml / this.ContainerVolumeInml);
        }

        /// <summary>
        /// Caculates value of all ingredients in the list, for a given product volume. 
        /// </summary>
        /// <param name="ingredientDBNames">Ingredient values to calcualte</param>
        /// <param name="volumeInml">Product volume</param>
        /// <returns>ingredient values (same order as ingredientDBNames)</returns>
        public IEnumerable<double> CalculateIngredientValues(IEnumerable<string> ingredientDBNames, double volumeInml)
        {
            foreach (string ingDBName in ingredientDBNames)
                yield return CalculateIngredientValue(ingDBName, volumeInml);
        }

        /// <summary>
        /// Caculates required product volume, needed to provide the specified volume
        /// Returns null if the product does not contain this ingredient
        /// (unlike CalculateIngredientValue the method can't handle organic phosphate)
        /// </summary>
        /// <param name="ingredientDBName">Ingredient value to calcualte</param>
        /// <param name="ingredientValue">Ingredient value</param>
        /// <returns>required volume</returns>
        public double? CalculateVolume(string ingredientDBName, double ingredientValue)
        {
            // Special case for volume, just return value passed in as will be the save
            if (ingredientDBName == PNIngDBNames.Volume)
                return ingredientValue;

            // Get the produt value
            double? productIngValue = this.GetIngredient(ingredientDBName);
            if (!productIngValue.HasValue || productIngValue.Value.IsZero())
                return null;

            // Calculate the volume of the product
            return (ingredientValue / productIngValue.Value) * this.ContainerVolumeInml;
        }

        public bool LimitToMaxmlTotal(ref double? volume)
        {
            bool limited = false;

            if (this.MaxmlTotal > 0.0 && volume.HasValue && volume.Value > this.MaxmlTotal)
            {
                volume  = this.MaxmlTotal;
                limited = true;
            }

            return limited;
        }

        public bool LimitToMaxmlPerKg(ref double? volume, double dosingWeightInkg)
        {
            bool limited = false;

            if (this.MaxmlPerKg > 0.0 && volume.HasValue && (volume.Value / dosingWeightInkg) > this.MaxmlPerKg)
            {
                volume  = this.MaxmlPerKg *  dosingWeightInkg;
                limited = true;
            }

            return limited;
        }
        #endregion

        public override string ToString()
        {
            return Description;
        }
    }

    /// <summary>Provides column information about the PNProduct table</summary>
    public class PNProductColumnInfo : BaseColumnInfo
    {
        public PNProductColumnInfo() : base("PNProduct") { }

        public int PNCodeLength                 { get { return base.FindColumnByName("PNCode").Length;      } }
        public int DescriptionLength            { get { return base.FindColumnByName("Description").Length; } }
        public int StockLookupLength            { get { return base.FindColumnByName("StockLookup").Length; } }
        public int BaxaMMIgLength               { get { return base.FindColumnByName("BaxaMMIg").Length;    } }
        public int LastModifieUserInitialsLength{ get { return base.FindColumnByName("LastModUser").Length; } }
        public int LastModifiedTerminalLength   { get { return base.FindColumnByName("LastModTerm").Length; } }   
    }

    /// <summary>Represent the PNProduct table</summary>
    public class PNProduct : BaseTable2<PNProductRow, PNProductColumnInfo>
    {
        /// <summary>Constructor</summary>
        public PNProduct() : base("PNProduct")
        {
            this.ConflictOption = System.Data.ConflictOption.CompareAllSearchableValues;
        }

        /// <summary>
        /// Override base class to set defaults 
        ///     BaxaMMIg = 0
        /// 12Sep14 XN 95647
        /// </summary>
        public override PNProductRow Add()
        {
            PNProductRow newRow = base.Add();
            newRow.BaxaMMIg = "0";
            return newRow;
        }

        /// <summary>Load all PN products by site ID (unsorted)</summary>
        /// <param name="siteID">Site ID</param>
        public void LoadBySite(int siteID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID", siteID));
            LoadBySP("pPNProductBySite", parameters);
        }

        /// <summary>Load PN product by ID</summary>
        /// <param name="pnProductID">PN product ID</param>
        public void LoadByID(int pnProductID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@PNProductID", pnProductID));
            LoadBySP("pPNProductByID", parameters);
        }

        /// <summary>Load PN product by description (case insenitive)</summary>
        /// <param name="siteID">Current site ID</param>
        /// <param name="description">Description to load by</param>
        public void LoadBySiteIDAndDescription(int siteID, string description)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID",      siteID));
            parameters.Add(new SqlParameter("@Description", description));
            LoadBySP("pPNProductBySiteIDAndDescription", parameters);
        }

        /// <summary>Load PN product by sort index</summary>
        /// <param name="siteID">Current site ID</param>
        /// <param name="sortIndex">sort index to load by</param>
        public void LoadBySiteIDAndSortIndex(int siteID, int sortIndex)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID",    siteID));
            parameters.Add(new SqlParameter("@SortIndex", sortIndex));
            LoadBySP("pPNProductBySiteIDAndSortIndex", parameters);
        }

        /// <summary>Load PN product by PNCode</summary>
        /// <param name="siteID">Current site ID</param>
        /// <param name="PNCode">PNCode to load by</param>
        public void LoadBySiteIDAndPNCode(int siteID, string PNCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@SiteID", siteID));
            parameters.Add(new SqlParameter("@PNCode", PNCode));
            LoadBySP("pPNProductBySiteIDAndPNCode", parameters);
        }

        /// <summary>Load by PN Code for all sites 26Oct15 XN 106278</summary>
        /// <param name="PNCode">PN code to look for</param>
        public void LoadByPNCode(string PNCode)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@PNCode", PNCode));
            LoadBySP("pPNProductByPNCode", parameters);
        }

        /// <summary>Get PN product by PNCode</summary>
        /// <param name="siteID">Current site ID</param>
        /// <param name="PNCode">product PNCode</param>
        public static PNProductRow GetBySiteIDAndPNCode(int siteID, string PNCode)
        {
            PNProduct product = new PNProduct();
            product.LoadBySiteIDAndPNCode(siteID, PNCode);
            //return product.First();   XN 28Oct15 106278
            return product.FirstOrDefault();
        }

        /// <summary>Returns all the PN products (either loads from db, or from the web cache)</summary>
        /// <param name="forceReload">force reload of cahced data from db (default is false)</param>
        public static PNProduct GetInstance(bool forceReload)
        {
            string cachedName = "PN.PNProducts." + SessionInfo.SiteID;

            PNProduct products = (PNProduct)PharmacyDataCache.GetFromCache(cachedName);
            if ((products == null) || forceReload)
            {
                // Reload product
                products = new PNProduct();
                products.LoadBySite(SessionInfo.SiteID);

                // Save tp web cache
                PharmacyDataCache.RemoveFromCache(cachedName);
                PharmacyDataCache.SaveToCache(cachedName, products);

                // Save to PN log
                PNLog.WriteToLog(SessionInfo.SiteID, "Loaded PN product from DB to web cache");
            }

            return products;
        }
        public static PNProduct GetInstance()
        {
            return GetInstance(false);
        }
    }

    /// <summary>Provides extension methods to IEnumerable{PNProductRow} class</summary>
    public static class PNProductEnumerableExtensions
    {
        /// <summary>
        /// Returns first product, that has matching PNCode, ignores case
        /// Null if no match
        /// </summary>
        public static PNProductRow FindByPNCode(this IEnumerable<PNProductRow> products, string pnCode)
        {
            return products.FirstOrDefault(p => p.PNCode.EqualsNoCaseTrimEnd(pnCode));
        }

        /// <summary>
        /// Returns first product, that has matching PNProductID
        /// Null if no match
        /// </summary>
        public static PNProductRow FindByPNProductID(this IEnumerable<PNProductRow> products, int PNProductID)
        {
            return products.FirstOrDefault(p => p.PNProductID == PNProductID);
        }

        /// <summary>Returns all products, that contain that ingredient.</summary>
        public static IEnumerable<PNProductRow> FindByIngredient(this IEnumerable<PNProductRow> products, string dbName)
        {
            return products.Where(p => (dbName == PNIngDBNames.Volume) || !(p.GetIngredient(dbName) ?? 0.0).IsZero());
        }

        /// <summary>Returns all products for this age range.</summary>
        /// <param name="ageRange">Age range to filter by</param>
        public static IEnumerable<PNProductRow> FindByAgeRange(this IEnumerable<PNProductRow> products, AgeRangeType ageRange)
        {
            // Get products by age range
            if (ageRange == AgeRangeType.Adult)
                return products.Where(p => p.ForAdult);
            else
                return products.Where(p => p.ForPaediatric);
        }

        /// <summary>Returns all products in use</summary>
        public static IEnumerable<PNProductRow> FindByInUse(this IEnumerable<PNProductRow> products)
        {
            return products.Where(p => p.InUse);
        }

        /// <summary>Returns first item with specified site id</summary>
        /// <param name="products">List of products</param>
        /// <param name="siteId">site id</param>
        /// <returns>First item with site id or null</returns>
        public static PNProductRow FindFirstBySiteId(this IEnumerable<PNProductRow> products, int siteId)
        {
            return products.FirstOrDefault(p => p.LocationID_Site == siteId);
        }

        /// <summary>Returns all products that only contain glucose ingredients</summary>
        public static IEnumerable<PNProductRow> FindByOnlyContainGlucose(this IEnumerable<PNProductRow> products)
        {
            List<string> IngDBNames = PNIngredient.GetInstance().FindByForPNProduct(false).Select(p => p.DBName).ToList();
            IngDBNames.Remove(PNIngDBNames.Glucose );
            IngDBNames.Remove(PNIngDBNames.Calories);

            foreach (PNProductRow product in products)
            {
                if ((product.GetIngredient(PNIngDBNames.Glucose) > 0) && IngDBNames.All(i => (product.GetIngredient(i) ?? 0).IsZero()))
                    yield return product;
            }
        }

        /// <summary>Returns all the products that are not in the PNCodes list</summary>
        /// <param name="products">List of products</param>
        /// <param name="PNCodes">List of PNCodes to ignore</param>
        public static IEnumerable<PNProductRow> RemoveByPNCode(this IEnumerable<PNProductRow> products, IEnumerable<string> PNCodes)
        {
            HashSet<string> pnCodeHashSet = new HashSet<string>(PNCodes);
            return products.Where(p => !pnCodeHashSet.Contains(p.PNCode));
        }

        /// <summary>Orders items in list by ascending SortIndex</summary>
        public static IOrderedEnumerable<PNProductRow> OrderBySortIndex(this IEnumerable<PNProductRow> products)
        {
            return products.OrderBy(p => p.SortIndex);
        }
    }
}
