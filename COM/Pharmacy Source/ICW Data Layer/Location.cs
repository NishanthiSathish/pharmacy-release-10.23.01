//===========================================================================
//
//							Location.cs
//
//  Provides access to Location table.
//
//  Classes are derived from BaseRow
//
//  Use Location to get an instance of the location class.
//
//  LocationBase was used for hierarchies but is now deprecated
//
//  Only supports reading.
//
//	Modification History:
//	03Sep10 XN  Written (F0082255)
//  07Feb12 XN  Moved ToString method from WardRow to LocationRow.
//              Changed Location to standard table class and base LocationBase class
//  23May12 XN  added LoadByLocationType (27038)
//===========================================================================
using System;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Represents a record in the Location table</summary>
    public class LocationRow : BaseRow
    {
        public int LocationID
        {
            get { return FieldToInt(RawRow["LocationID"]).Value; }
        }

        public string Detail
        {
            get { return FieldToStr(RawRow["Detail"]); }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"]); }
        }

        /// <summary>Returns full name of the ward (detail or description depending on what is filled in)</summary>
        public override string ToString()
        {
            if (string.IsNullOrEmpty(Detail) || Detail.EqualsNoCaseTrimEnd("N/A"))
                return Description;
            else
                return Detail;
        }
    }

    /// <summary>Provides column information about the Location table</summary>
    public class LocationColumnInfo : BaseColumnInfo
    {
        public LocationColumnInfo(string tableName) : base(tableName) { }

        public LocationColumnInfo() : base("Location") { }
    }

    /// <summary>Represent the Location table (used to allow people to inherit from)</summary>
    [Obsolete]
    public class LocationBase<T, C> : BaseTable<T, C>
        where T : LocationRow, new()
        where C : LocationColumnInfo, new()
    {
        public LocationBase(string tableName, string pkcolumnname) : base(tableName, pkcolumnname) { }
    }

    /// <summary>Represent the Location table</summary>
    public class Location : BaseTable<LocationRow, LocationColumnInfo>
    {
        public Location() : base("Location", "LocationID") { }

        /// <summary>Loads location by ID</summary>
        /// <param name="locationID">location by ID</param>
        public void LoadByLocationID(int locationID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "LocationID", locationID);
            LoadFromXMLString("pLocationXML", parameters);
        }

        /// <summary>
        /// Loads all locations with specified type
        /// 23May12 XN  27038
        /// </summary>
        /// <param name="locationType">Location type</param>
        public void LoadByLocationType(string locationType)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "LocationType", locationType);
            LoadFromXMLString("pLocationByType", parameters);
        }
    }
}
