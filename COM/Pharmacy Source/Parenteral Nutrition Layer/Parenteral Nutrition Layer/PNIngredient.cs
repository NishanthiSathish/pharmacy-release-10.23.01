//===========================================================================
//
//							    PNIngredient.cs
//
//  Provides access to PNIngredient table.
//
//  This list all the ingredients used by the PN module, including short name,
//  long name, and units.
//
//  The not all parts of the system use all ingredients in the table, and some 
//  items are purely derived by calculation (e.g. organic phosphate).
//
//  The DBName field is the one fix point to identify an ingredient and should be
//  used in conjunction with the PNIngDBName class to access a single ingredient.
//  It can also be used for items like access the ingredient value the PNProduct table
//  where the DBName is the same as the PNProduct column name.
//
//  Unlike other tables you do not create an instance of PNIngredient, instead
//  you do PNIngredient.GetInstance(), which will return a cached list of db table.
//  Use PNIngredient.GetInstance(true) to force a reload from the db.
//
//  There is also a class PNIngredientEnumerableExtensions to provide extension 
//  methods to IEnumerable{PNIngredientRow} used to find loaded items.
//
//  Only supports reading.
//
//	Modification History:
//	28Oct11 XN Written
//  20Apr12 XN TFS32337 marked PNIngCode.Vol as obsolete so can be removed later
//  15May12 XN Fix in Verify for changes made to casing in the DB.
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Reflection;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.icwdatalayer;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    /// <summary>Used to identify the ingredient to product rules (will be same as PNRule.Ingredient)</summary>
    public static class PNIngCode
    {
        public static readonly string Dil = "DIL";
        public static readonly string NaCl= "NACL";
        public static readonly string KCl = "KCL";
        public static readonly string KPO4= "KPO4";
        [Obsolete]public static readonly string Vol = "VOL";      // TFS32363 20Apr12 XN Needs to be removed as some point as not stored as ingredient to product rule
        public static readonly string N   = "N";
        public static readonly string Gluc= "GLUC";
        public static readonly string Fat = "FAT";
        public static readonly string Na  = "NA";
        public static readonly string K   = "K";
        public static readonly string Ca  = "CA";
        public static readonly string Mg  = "MG";
        public static readonly string Zn  = "ZN";
        public static readonly string PO4 = "PO4";
        public static readonly string Se  = "SE";
        public static readonly string Cu  = "CU";
        public static readonly string Vaqu= "VAQU";
        public static readonly string Vlip= "VLIP";
        public static readonly string Fe  = "FE";
    }

    /// <summary>Represents a row in the PNIngredient table</summary>
    public class PNIngredientRow : BaseRow
    {
        public int PNIngredientID
        {
            get { return (int)FieldToInt(RawRow["PNIngredientID"]); }
        }

        /// <summary>Ingredient long name (e.g. sodium)</summary>
        public string Description
        {
            get { return FieldToStr(RawRow["Description"], true, string.Empty); }
        }

        /// <summary>Ingredient long name (e.g. Na)</summary>
        public string ShortDescription
        {
            get { return FieldToStr(RawRow["ShortDescription"], true, string.Empty); }
        }

        /// <summary>Fixed identifier used to access an ingredient</summary>
        public string DBName
        {
            get { return FieldToStr(RawRow["DBName"], true, string.Empty); }
        }

        /// <summary>Ingredient units (long name) e.g. gram provides link into UnitID table</summary>
        public string UnitDescription
        {
            get { return FieldToStr(RawRow["Unit"], true, string.Empty); }
        }

        /// <summary>
        /// Gets the unit type from the ICW Unit table associatated with this ingredient.
        /// Data is cached on a request.
        /// </summary>
        public UnitRow GetUnit()
        {
            string cacheName = "pharmacy.PNIngredient.NameToUnitRowMap";
            UnitRow unitRow = null;

            // Try to get the unit map from the cache
            Dictionary<string, UnitRow> nameToUnitRowMap = (PharmacyDataCache.GetFromContext(cacheName) as Dictionary<string, UnitRow>);
            if (nameToUnitRowMap == null)
            {
                // Map does not exists in cache so load
                nameToUnitRowMap = new Dictionary<string,UnitRow>();
                PharmacyDataCache.SaveToContext(cacheName, nameToUnitRowMap);
            }

            // Try get unit associated with description
            if (!nameToUnitRowMap.TryGetValue(UnitDescription.ToLower(), out unitRow))
            {
                // Unit does not exists so load from db to map
                Unit unit = new Unit();
                unit.LoadByDescription(UnitDescription);
                unitRow = unit.FirstOrDefault();

                nameToUnitRowMap[UnitDescription.ToLower()] = unitRow;
            }

            return unitRow;
        }

        /// <summary>Ingrdient display order</summary>
        public int SortIndex
        {
            get { return FieldToInt(RawRow["SortIndex"]).Value; }
        }

        /// <summary>If ingrdient displayed on prescribing forms</summary>
        public bool ForPrescribing
        {
            get { return FieldToBoolean(RawRow["ForPrescribing"]).Value; }
        }

        /// <summary>If ingrdient displayed on view and adjust forms</summary>
        public bool ForViewAdjust
        {
            get { return FieldToBoolean(RawRow["ForViewAdjust"]).Value; }
        }

        /// <summary>Returns ingredient description</summary>
        public override string ToString()
        {
            return this.Description;
        }
    }

    /// <summary>Provides column information about the PNIngredient table</summary>
    public class PNIngredientColumnInfo : BaseColumnInfo
    {
        public PNIngredientColumnInfo() : base("PNIngredient") { }
    }

    /// <summary>Represent the PNIngredient table</summary>
    public class PNIngredient : BaseTable2<PNIngredientRow, PNIngredientColumnInfo>
    {
        /// <summary>Constructor</summary>
        private PNIngredient() : base("PNIngredient") { }


        /// <summary>Load all PN products ordered by SortIndex</summary>
        private void LoadAll()
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            LoadBySP("pPNIngredientAll", parameters);
        }

        /// <summary>
        /// Used to verify that correct number of ingredients exists in the system.
        /// The list of ingredients in the db, must match the list in PNIngDBNames 
        /// </summary>
        public void Verify()
        {
            Type pnIngDBNames = typeof(PNIngDBNames);
            FieldInfo[] Ings = pnIngDBNames.GetFields(BindingFlags.Static | BindingFlags.Public);

            if (Ings.Length < this.Count)
                throw new ApplicationException("There are more ingredients in the PNIngredient table than there should be.");
            else if (Ings.Length > this.Count)
                throw new ApplicationException("There are less ingredients in the PNIngredient table than there should be.");
            if (this.GroupBy(i => i.DBName).Any(i => i.Count() > 1))
                throw new ApplicationException("There are entries in the PNIngredient table that have duplicate DBName values.");
            else
            {
                foreach (FieldInfo f in Ings)
                {
                    string dbName = (string)f.GetValue(null);
                    if (!this.Any(i => i.DBName.EqualsNoCaseTrimEnd(dbName)))
                        throw new ApplicationException("There is no entry for " + dbName + " in the PNIngredient table (DBName field).");
                }
            }
        }

        /// <summary>Returns all the PN products (either loads from db, or from the web cache)</summary>
        /// <param name="forceReload">force reload of cahced data from db (default is false)</param>
        public static PNIngredient GetInstance(bool forceReload)
        {
            string cachedName = "PN.PNIngredient";

            PNIngredient ingredient  = (PNIngredient)PharmacyDataCache.GetFromCache(cachedName);
            if ((ingredient == null) || forceReload)
            {
                // Reload product
                ingredient = new PNIngredient();
                ingredient.LoadAll();
                ingredient.Verify();

                // Save tp web cache
                PharmacyDataCache.RemoveFromCache(cachedName);
                PharmacyDataCache.SaveToCache(cachedName, ingredient);

                // Save to PN log
                PNLog.WriteToLog(SessionInfo.SiteID, "Loaded PNIngredient from DB to web cache");
            }

            return ingredient;
        }
        public static PNIngredient GetInstance()
        {
            return GetInstance(false);
        }
    }

    /// <summary>Provides extension methods to IEnumerable{PNIngredientRow} class</summary>
    public static class PNIngredientEnumerableExtensions
    {
        /// <summary>Returns first ingredietn that has matching dbname, else null</summary>
        public static PNIngredientRow FindByDBName(this IEnumerable<PNIngredientRow> ingredients, string dbName)
        {
            return ingredients.FirstOrDefault(i => i.DBName == dbName);
        }

        /// <summary>
        /// Returns first ingredient, that has matching short description, ignores case
        /// Null if no match
        /// </summary>
        public static PNIngredientRow FindByShortDescription(this IEnumerable<PNIngredientRow> ingredients, string shortDescription)
        {
            return ingredients.FirstOrDefault(i => i.ShortDescription.EqualsNoCaseTrimEnd(shortDescription));
        }

        /// <summary>Returns all ingredients, related to ingredient in PN product table</summary>
        public static IEnumerable<PNIngredientRow> FindByForPNProduct(this IEnumerable<PNIngredientRow> ingredients, bool includeVolume)
        {
            PNProductColumnInfo columnInfo = PNProduct.GetColumnInfo();
            foreach (PNIngredientRow ing in ingredients)
            {
                if ((ing.DBName == PNIngDBNames.Volume) && includeVolume)
                    yield return ing;
                else if (columnInfo.FindColumnByName(ing.DBName) != null)
                    yield return ing;
            }
        }

        /// <summary>Returns all ingredients that the product contains</summary>
        public static IEnumerable<PNIngredientRow> FindByForPNProduct(this IEnumerable<PNIngredientRow> ingredients, PNProductRow product, bool includeVolume)
        {
            PNProductColumnInfo columnInfo = PNProduct.GetColumnInfo();
            foreach (PNIngredientRow ing in ingredients)
            {
                if ((ing.DBName == PNIngDBNames.Volume) && includeVolume)
                    yield return ing;
                else if ((columnInfo.FindColumnByName(ing.DBName) != null) && !(product.GetIngredient(ing.DBName) ?? 0.0).IsZero())
                    yield return ing;
            }
        }

        /// <summary>Returns all ingredients, to be displayed in view and adjust screen</summary>
        public static IEnumerable<PNIngredientRow> FindByForViewAdjust(this IEnumerable<PNIngredientRow> ingredients)
        {
            return ingredients.Where(i => i.ForViewAdjust);
        }

        /// <summary>Returns all phosphate ingredients</summary>
        public static IEnumerable<PNIngredientRow> FindByPO4(this IEnumerable<PNIngredientRow> ingredients)
        {
            return ingredients.Where(i => (i.DBName == PNIngDBNames.Phosphate) || (i.DBName == PNIngDBNames.OrganicPhosphate) || (i.DBName == PNIngDBNames.InorganicPhosphate));
        }

        /// <summary>Orders items in list by ascending SortIndex</summary>
        public static IOrderedEnumerable<PNIngredientRow> OrderBySortIndex(this IEnumerable<PNIngredientRow> ingredients)
        {
            return ingredients.OrderBy(p => p.SortIndex);
        }

    }
}
