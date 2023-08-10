//===========================================================================
//
//							     Utils.cs
//
//	General untility functions for finanace manager.
//  
//	Modification History:
//	16Sept13 XN  Written 27038
//  09Jan13  XN  Added FMStockAccountSheetColumnType
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ascribe.pharmacy.financemanagerlayer
{
    /// <summary>Settings for stock account stock sheet<summary>
    public struct WFMStockAccountSheetSettings
    {
        public Guid         sheetID;
        public string       NSVCode;
        public DateTime     startDate;
        public DateTime     endDate;
        public List<int>    siteNumbers;
        public List<string> discrepancesNSVCodes;
    }

    /// <summary>Settings for account stock sheet<summary>
    public struct WFMAccountSheetSettings
    {
        public Guid         sheetID;
        public int          accountCode;
        public DateTime     startDate;
        public DateTime     endDate;
        public List<int>    siteNumbers;
    }

    /// <summary>Settings for GRNI</summary>
    public struct WFMGrniSettings
    {
        public Guid      sheetID;
        public DateTime  upToDate;
        public List<int> siteNumbers;
    }

    /// <summary>Stock Account sheet column types</summary>
    public enum FMStockAccountSheetColumnType
    {
        ExVat,
        IncVat,
        Vat
    }

    /// <summary>Double extension methods for use by FM</summary>
    public static class WFMDoubleExtension
    {
        /// <summary>Rounds decimal to 2DP</summary>
        public static double? RoundCost(this double? value)
        {
            return value == null ? (double?)null : value.Value.RoundCost();
        }
        public static double RoundCost(this double value)
        {
            return Math.Round(value, 0);
        }

        /// <summary>Rounds quantity to 3DP</summary>
        public static double? RoundQuantity(this double? value)
        {
            return value == null ? (double?)null : value.Value.RoundQuantity();
        }
        public static double RoundQuantity(this double value)
        {
            return Math.Round(value, 3);
        }
    }
}
