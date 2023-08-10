//===========================================================================
//
//							      HistoricalInfo.cs
//
//  Used to get historical information form WOrderlog, and WTranslog.
//
//	Modification History:
//	22Jul09 XN  Written
//  02Jun11 XN  F0118610 Item enquiry screen need to show EDI orders in the 
//              historical order list
//  19Aug14 XN  Prevent crash if log date is in the future
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.pharmacydatalayer;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>Monthly totals business object</summary>
    public class MonthlyTotals : IBusinessObject
    {
        /// <summary>Month and year the total is for</summary>
        public DateTime monthYear               { get; set; }

        /// <summary>WOrderlog.QtyOrd total for the month</summary>
        public decimal  quantityOrderedInPacks  { get; set; }  

        /// <summary>WOrderlog.QtyRec total for the month</summary>
        public decimal  quantityReceivedInPacks { get; set; }

        /// <summary>WTrandlog.Qty total for the month</summary>
        public decimal  quantityIssuedInPacks   { get; set; }

        public MonthlyTotals (DateTime monthYear)
	    {
            this.monthYear              = monthYear;
            this.quantityIssuedInPacks  = 0m;
            this.quantityOrderedInPacks = 0m;
            this.quantityReceivedInPacks= 0m;
    	}
    }

    /// <summary>Monthly totals business object info</summary>
    public class MonthlyTotalsObjectInfo : IBusinessObjectInfo
    {
        public static int QuantityOrderedInPacksLength  { get { return WOrderlog.GetColumnInfo().QuantityOrderedLength;  } }
        public static int QuantityReceivedInPacksLength { get { return WOrderlog.GetColumnInfo().QuantityReceivedLength; } }
        public static int QuantityIssuedInPacksLength   { get { return WTranslog.GetColumnInfo().QuantityIssuedLength;   } }
    }

    /// <summary>Monthly totals business info processor</summary>
    public class HistoricalInfoProcessor : BusinessProcess
    {
        /// <summary>
        /// Load monthly ordered, received, and issued, totals for a site's product from a specific date.
        /// Ordered  items loaded from WOrderlog.QtyOrd for all D type records
        /// Received items loaded from WOrderlog.QtyRec for all R type records
        /// Issued   items loaded from WTranslog.Qty
        /// </summary>
        /// <param name="siteID">site Id</param>
        /// <param name="NSVCode">Product nsv code</param>
        /// <param name="fromDate">Earliest date to retrive log rows from</param>
        /// <returns>List of all product monthly totals from fromDate</returns>
        public List<MonthlyTotals> LoadMonthlyTotalsBySiteIDNSVCodeAndFrom (int siteID, string NSVCode, DateTime fromDate)
        {
            SortedList<DateTime,MonthlyTotals> list = new SortedList<DateTime,MonthlyTotals>();
            List<WOrderlogMonthlyTotals> orderlogTotal;
            List<WTranslogMonthlyTotals> translogTotal;

            // Initalise the monthly totals to 0 from the specified date.
            DateTime now = DateTime.Now;
            DateTime monthYear = new DateTime( fromDate.Year, fromDate.Month, 1 );
            while (monthYear < now)
            {
                list.Add(monthYear, new MonthlyTotals(monthYear));
                monthYear = monthYear.AddMonths(1);
            }

            // Get monthly order totals 
            orderlogTotal = WOrderlog.GetMonthlyQuantityOrdered(siteID, NSVCode, fromDate, WOrderLogType.Ordered, WOrderLogType.OrderedViaEDI, WOrderLogType.OrderedInternal);
            foreach(WOrderlogMonthlyTotals totals in orderlogTotal)
            {
                //if (totals.QuantityOrderedInPacks.HasValue)   94287 XN Prevent crash if date is in the future
                if (totals.QuantityOrderedInPacks.HasValue && list.ContainsKey(totals.MonthYear))
                    list[totals.MonthYear].quantityOrderedInPacks = totals.QuantityOrderedInPacks.Value;
            }

            // Get monthly receipt totals
            orderlogTotal = WOrderlog.GetMonthlyQuantityReceived(siteID, NSVCode, fromDate, WOrderLogType.Receipt);
            foreach(WOrderlogMonthlyTotals totals in orderlogTotal)
            {
                //if (totals.QuantityReceivedInPacks.HasValue)   94287 XN Prevent crash if date is in the future
                if (totals.QuantityReceivedInPacks.HasValue && list.ContainsKey(totals.MonthYear))
                    list[totals.MonthYear].quantityReceivedInPacks = totals.QuantityReceivedInPacks.Value;
            }

            // Get monthly issued totals
            translogTotal = WTranslog.GetMonthlyTotalsExcludingTypes(siteID, NSVCode, fromDate, WTranslogType.WardStock);
            foreach(WTranslogMonthlyTotals totals in translogTotal)
            {
                //if (totals.QuantityInPacks.HasValue)   94287 XN Prevent crash if date is in the future
                if (totals.QuantityInPacks.HasValue && list.ContainsKey(totals.MonthYear))
                    list[totals.MonthYear].quantityIssuedInPacks = totals.QuantityInPacks.Value;
            }

            return list.Values.ToList();
        }
    }
}
