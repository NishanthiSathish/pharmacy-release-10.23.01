//===========================================================================
//
//							RDispSupplyPattern.cs
//
//  This class is a data layer representation of the Repeat Dispensing Supply
//  Patterns.
//
//	Modification History:
//	20May09 AJK  Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.pharmacydatalayer
{
    /// <summary>
    /// Represents a row in the repeat dispensing supply pattern table
    /// </summary>
    public class RepeatDispensingSupplyPatternRow : BaseRow
    {
        /// <summary>
        /// ID and primary key of the supply pattern row. Read only.
        /// </summary>
        public int SupplyPatternID
        {
            get { return FieldToInt(RawRow["SupplyPatternID"]).Value; }
        }

        /// <summary>
        /// Description of the supply pattern
        /// </summary>
        public string Description
        {
            get { return FieldToStr(RawRow["Description"]); }
            set { RawRow["Description"] = StrToField(value); }
        }

        /// <summary>
        /// Number of days in the pattern cycle
        /// </summary>
        public int Days
        {
            get { return FieldToInt(RawRow["Days"]).Value; }
            set { RawRow["Days"] = IntToField(value); }
        }
        
        /// <summary>
        /// Denotes if the supply pattern is the default
        /// </summary>
        public bool? IsDefault
        {
            get { return FieldToBoolean(RawRow["IsDefault"]); }
            set { RawRow["IsDefault"] = BooleanToField(value); }
        }

        public int SplitDays
        {
            get { return (int)FieldToInt(RawRow["SplitDays"]); }
            set { RawRow["SplitDays"] = IntToField(value); }
        }

    }

    /// <summary>
    /// Provides column information for the RepeatDispensingSupplyPatterns table
    /// </summary>
    public class RepeatDispensingSupplyPatternBaseColumnInfo : BaseColumnInfo
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public RepeatDispensingSupplyPatternBaseColumnInfo() : base("RepeatDispensingSupplyPatterns") { }

        /// <summary>
        /// Maximum length of the Description field
        /// </summary>
        public int DescriptionLength { get { return tableInfo.GetFieldLength("Description"); } }
    }

    /// <summary>
    /// Represents the RepeatDispensingSupplyPattern table
    /// </summary>
    public class RepeatDispensingSupplyPattern : BaseTable<RepeatDispensingSupplyPatternRow, RepeatDispensingSupplyPatternBaseColumnInfo>
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public RepeatDispensingSupplyPattern() : base("RepeatDispensingSupplyPatterns", "SupplyPatternID")
        {
            UpdateSP = "pRepeatDispensingSupplyPatternsUpdate";
        }

        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="rowLocking">Enable locking of loaded rows</param>
        public RepeatDispensingSupplyPattern(RowLocking rowLocking) : base("RepeatDispensingSupplyPatterns", "SupplyPatternID", rowLocking)
        {
            UpdateSP = "pRepeatDispensingSupplyPatternsUpdate";
        }

        /// <summary>
        /// Loads a suuply pattern based on the SupplyPatternID
        /// </summary>
        /// <param name="supplyPatternID">SupplyPatternID of the requested pattern</param>
        public void LoadBySupplyPatternID(int supplyPatternID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "SupplyPatternID", supplyPatternID);
            LoadRecordSetStream("pRepeatDispensingSupplyPatternsBySupplyPatternID", parameters);
        }

        /// <summary>
        /// Loads all supply patterns
        /// </summary>
        public void LoadAll()
        {
            StringBuilder parameters = new StringBuilder();
            LoadRecordSetStream("pRepeatDispensingSupplyPatterns", parameters);
        }

        public void LoadActive()
        {
            StringBuilder parameters = new StringBuilder();
            LoadRecordSetStream("pRepeatDispensingActiveSupplyPatterns", parameters);
        }


    }
}
