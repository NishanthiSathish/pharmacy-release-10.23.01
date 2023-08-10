//===========================================================================
//
//							RDispSupplyPattern.cs
//
//  This class holds all business logic for handling repeat dispensing
//  supply patterb object.
//
//	Modification History:
//	02Jun09 AK  Written
//===========================================================================
using System;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using System.Collections.Generic;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>
    /// Represents a repeat dispensing supply pattern
    /// </summary>
    public class RepeatDispensingSupplyPatternLine : IBusinessObject
    {
        public int SupplyPatternID { get; set; }
        public string Description { get; set; }
        public int Days { get; set; }
        public bool IsDefault { get; set; }
        public int SplitDays { get; set; }
    }

    /// <summary>
    /// Processes repeat dispensing supply patterns
    /// </summary>
    public class RepeatDispensingSupplyPatternProcessor : BusinessProcess
    {
        /// <summary>
        /// Loads all repeat dispensing supply patterns
        /// </summary>
        /// <returns>List of RepeatDispensingSupplyPatternLine objects</returns>
        public List<RepeatDispensingSupplyPatternLine> LoadAll()
        {
            List<RepeatDispensingSupplyPatternLine> supplyPatternList = new List<RepeatDispensingSupplyPatternLine>();
            using (RepeatDispensingSupplyPattern dbSupplyPattern = new RepeatDispensingSupplyPattern())
            {
                dbSupplyPattern.LoadAll();
                for (int i = 0; i < dbSupplyPattern.Count; i++)
                {
                    supplyPatternList.Add(FillData(dbSupplyPattern[i]));
                }
            }
            return supplyPatternList;
        }

        /// <summary>
        /// Loads supply patterns where the specified supply length is divisible by the supply pattern days with no remainder
        /// </summary>
        /// <param name="supplyLength">The length of supply to divide by the supply pattern days</param>
        /// <returns>List of RepeatDispensingSupplyPatternLine objects</returns>
        public List<RepeatDispensingSupplyPatternLine> LoadBySupplyLength(int supplyLength)
        {
            List<RepeatDispensingSupplyPatternLine> supplyPatternList = new List<RepeatDispensingSupplyPatternLine>();
            using (RepeatDispensingSupplyPattern dbSupplyPattern = new RepeatDispensingSupplyPattern())
            {
                dbSupplyPattern.LoadActive();
                for (int i = 0; i < dbSupplyPattern.Count; i++)
                {
                    if (dbSupplyPattern[i].Days == 0 || supplyLength % dbSupplyPattern[i].Days == 0)
                    {
                        supplyPatternList.Add(FillData(dbSupplyPattern[i]));
                    }
                }
            }
            return supplyPatternList;
        }



        /// <summary>
        /// Copies data from the data layer object to a business layer object
        /// </summary>
        /// <param name="dbBatchRow">RepeatDispensingBatchRow object to source the data from</param>
        /// <returns>RepeatDispensingBatchLine business object filled with data</returns>
        private RepeatDispensingSupplyPatternLine FillData(RepeatDispensingSupplyPatternRow dbSupplyPatternRow)
        {
            RepeatDispensingSupplyPatternLine supplyPattern = new RepeatDispensingSupplyPatternLine();
            supplyPattern.Days = dbSupplyPatternRow.Days;
            supplyPattern.Description = dbSupplyPatternRow.Description;
            supplyPattern.IsDefault = dbSupplyPatternRow.IsDefault.HasValue ? (bool)dbSupplyPatternRow.IsDefault : false;
            supplyPattern.SupplyPatternID = dbSupplyPatternRow.SupplyPatternID;
            supplyPattern.SplitDays = dbSupplyPatternRow.SplitDays;
            return supplyPattern;
        }
    }
}
