// -----------------------------------------------------------------------
// <copyright file="RoutineParameter.cs" company="Ascribe Ltd.">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
//
//  This class represents the RoutineParameter table.  
//
//  Only supports reading from table.
//  
//  Used to load in routine parameter information. 
//  This is used to determine how parameters for routines are to be supplier
//
//  Usage:
//  RoutineParameter routine = RoutineParameter();
//  routine.LoadByReportID(routineID);
//      
//  Modification History:
//  12Jan15 XN  Written
//  08May15 XN  Update RoutineParameterRow for changes in BaseRow (change field from static to instance for error handling improvements)
// -----------------------------------------------------------------------

namespace ascribe.pharmacy.icwdatalayer
{
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>Represents a record in the RoutineParameter table</summary>
    public class RoutineParameterRow : BaseRow
    {
        /// <summary>Gets RoutineParameterID Field</summary>
        public int RoutineParameterID
        {
            get { return this.FieldToInt(this.RawRow["RoutineParameterID"]).Value; }
        }

        /// <summary>Gets or sets RoutineID Field</summary>
        public int RoutineID
        {
            get { return this.FieldToInt(this.RawRow["RoutineID"]).Value; }
            set { this.RawRow["RoutineID"] = this.FieldToInt(value);      }
        }

        /// <summary>Gets or sets RoutineID_Lookup Field</summary>
        public int? RoutineIDLookup
        {
            get { return this.FieldToInt(this.RawRow["RoutineID_Lookup"]);    }
            set { this.RawRow["RoutineID_Lookup"] = this.FieldToInt(value);   }
        }

        /// <summary>Gets or sets Description Field</summary>
        public string Description
        {
            get { return this.FieldToStr(this.RawRow["Description"]);  }
            set { this.RawRow["Description"] = this.StrToField(value); }
        }

        /// <summary>Gets or sets DefaultValue Field</summary>
        public string DefaultValue
        {
            get { return this.FieldToStr(this.RawRow["DefaultValue"]);  }
            set { this.RawRow["Description"] = this.StrToField(value); }
        }

        /// <summary>
        /// Returns the suggested value for the parameter
        /// If parameter is SiteID    will return SessionInfo.SiteID
        /// If parameter is SessionID or CurrentSessionID will return SessionInfo.SessionID
        /// else returns default value
        /// </summary>
        /// <returns>Returns suggested value</returns>
        public object GetDefaultValue()
        {
            switch (this.Description.ToLower())
            {
            case "siteid": return SessionInfo.SiteID.ToString();
            case "currentsessionid": 
            case "sessionid": return SessionInfo.SessionID.ToString();
            default: return  this.DefaultValue;
            }
        }
    }

    /// <summary>Provides column information about the RoutineParameter table</summary>
    public class RoutineParameterColumnInfo : BaseColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="RoutineParameterColumnInfo"/> class.</summary>
        public RoutineParameterColumnInfo() : base("RoutineParameter") { }

        /// <summary>Gets description field length</summary>
        public int DescriptionLength
        {
            get { return FindColumnByName("Description").Length; }
        }

        /// <summary>Gets DefaultValue field length</summary>
        public int DefaultValueLength
        {
            get { return FindColumnByName("DefaultValue").Length; }
        }
    }

    /// <summary>Represent the RoutineParameter table</summary>
    public class RoutineParameter : BaseTable2<RoutineParameterRow, RoutineParameterColumnInfo>
    {
        /// <summary>Initializes a new instance of the <see cref="RoutineParameter"/> class.</summary>
        public RoutineParameter() : base("RoutineParameter") { }

        /// <summary>Load report by routine ID</summary>
        /// <param name="routineID">Report ID</param>
        public void LoadByRoutinetID(int routineID)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("RoutineID", routineID);
            this.LoadBySP("pRoutineParameterByRoutineID", parameters);
        }
    }

}
