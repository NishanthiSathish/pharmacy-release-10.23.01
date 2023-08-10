//===========================================================================
//
//					           PNRegimenItem.cs
//
//  Class to represent products in the regimen (each product has a volume)
//
//  There is also an IEnumerable<PNRegimenItem> extension methods class to 
//  provide quick helper functions.
//
//	Modification History:
//	17Nov11 XN  Written
//  03Apr13 XN  Made PNRegimenItem compatible with DataContract
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;

namespace ascribe.pharmacy.parenteralnutritionlayer
{
    /// <summary>Represent products in the regimen (each product has a volume)</summary>
    [DataContract]
    public class PNRegimenItem : ICloneable
    {
        /// <summary>Product PN code</summary>
        [DataMember]
        public string PNCode  { get; internal set; }

        /// <summary>Product volume in regimen (in ml)</summary>
        [DataMember]
        public double VolumneInml { get; set; }

        /// <summary>If regimen values have been edited</summary>
        [DataMember]
        internal bool Edited { get; set; }

        public PNRegimenItem() {}

        public PNRegimenItem(string PNCode, double VolumneInml)
        {
            this.PNCode      = PNCode;
            this.VolumneInml = VolumneInml;
            this.Edited      = false;
        }

        /// <summary>Returns product the item relates (or null)</summary>
        public PNProductRow GetProduct()
        {
            return PNProduct.GetInstance().FindByPNCode(PNCode);
        }

        #region ICloneable Members
        public object Clone() { return this.MemberwiseClone(); }
        #endregion
    }

    /// <summary>IEnumerable{PNRegimenItem} extension methods class to provide quick helper functions</summary>
    public static class PNRegimenItemEnumerableExtensions
    {
        /// <summary>Returns the first PNRegimenItem with the PNCode or null if not present in list</summary>
        public static PNRegimenItem FindByPNCode(this IEnumerable<PNRegimenItem> items, string PNCode)
        {
            return items.FirstOrDefault(i => i.PNCode == PNCode);
        }

        /// <summary>Returns list of regimen items whose products only contains glucose</summary>
        public static IEnumerable<PNRegimenItem> FindByOnlyContainGlucose(this IEnumerable<PNRegimenItem> items)
        {
            IEnumerable<PNProductRow> productsContaingOnlyGlucose = PNProduct.GetInstance().FindByOnlyContainGlucose();
            HashSet<string>           pncodesContaingOnlyGlucose  = new HashSet<string>(productsContaingOnlyGlucose.Select(p => p.PNCode));
            return items.Where(i => pncodesContaingOnlyGlucose.Contains(i.PNCode));
        }

        public static IEnumerable<PNRegimenItem> FindByAqueousOrLipid(this IEnumerable<PNRegimenItem> items, PNProductType type)
        {
            PNProduct products = PNProduct.GetInstance();
            if (type == PNProductType.Combined)
                return items; 
            else
                return items.Where(i => products.FindByPNCode(i.PNCode).AqueousOrLipid == type);
        }

        /// <summary>Returns items that have (or have not) got SpvGrave value)</summary>
        /// <param name="hasSpGravValue">If to find ones that have or have not got sp grave value</param>
        public static IEnumerable<PNRegimenItem> FindBySpvGave(this IEnumerable<PNRegimenItem> items, bool hasSpGravValue)
        {
            if (hasSpGravValue)
                return items.Where(i => i.GetProduct().SpGrav > 0.0);
            else
                return items.Where(i => !(i.GetProduct().SpGrav > 0.0));
        }

        /// <summary>Orders list of items be sort index</summary>
        public static IOrderedEnumerable<PNRegimenItem> OrderBySortIndex(this IEnumerable<PNRegimenItem> items)
        {
            return items.OrderBy(i => i.GetProduct().SortIndex);
        }

        /// <summary>Caclculates the total ingredient value for item in the list</summary>
        /// <param name="items">Items to use to calculate</param>
        /// <param name="ingredientDBName">Ingredient to calculate for</param>
        /// <returns>Total of ingredient</returns>
        public static double CalculateTotal(this IEnumerable<PNRegimenItem> items, string ingredientDBName)
        {
            PNProduct product = PNProduct.GetInstance();
            return items.Sum(i => product.FindByPNCode(i.PNCode).CalculateIngredientValue(ingredientDBName, i.VolumneInml));
        }
    }
}
