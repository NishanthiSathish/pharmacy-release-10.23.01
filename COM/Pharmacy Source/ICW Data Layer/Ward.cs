//===========================================================================
//
//							Ward.cs
//
//  Provides access to Ward table.
//
//  Class is derived from Location
//
//  SP for this object should return all fields from Location table 
//  and a link to (unless stated otherwise)
//      LocationAlias where AliasGroup is 'WWardCodes' as WardCode
//
//  Only supports reading.
//
//	Modification History:
//	03Sep10 XN  Written (F0082255)
//  07Feb12 XN  Changed due to updates to location (moved ToString to location)
//              Derives from LocationBase
//	23Apr13 XN  Added LoadByLocationID 53147
//  21Jul14 XN  Added OutOfUse, and GetByID 43318
//  02Sep14 XN  Added LoadAllWardCodeAndIfInUse and GetAllWardCodeAndIfInUse 88509
//  23Feb15 XN  Renamed LoadAllWardCodeAndIfInUse to LoadAll, and GetAllWardCodeAndIfInUse to GetAll 111888
//  08Jul15 XN  Added GetByEpisode 39882
//===========================================================================
using System;
using System.Linq;
using System.Text;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Represents a record in the Ward, Location tables</summary>
    public class WardRow : LocationRow
    {
        public string Code
        {
            get { return FieldToStr(RawRow["WardCode"]); }
        }

        public bool OutOfUse
        {
            get { return FieldToBoolean(RawRow["out_of_use"]) ?? false; }
        }
    }

    /// <summary>Provides column information about the Ward, Location tables</summary>
    public class WardColumnInfo : LocationColumnInfo
    {
        public WardColumnInfo() : base("Ward") { }
    }

    /// <summary>Represent the Ward, Location tables</summary>
    public class Ward : LocationBase<WardRow, WardColumnInfo>
    {
        public Ward() : base("Ward", "LocationID") { }

        /// <summary>
        /// Loads ward by ward code (might be more than 1)
        /// (matched through LocationAlias where AliasGroup is 'WWardCodes')
        /// </summary>
        /// <param name="code">ward code</param>
        protected void LoadByWardCode(string code)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "Code", code);
            LoadRecordSetStream("pWardByCode", parameters);
        }

        /// <summary>Loads ward that the patient is on</summary>
        /// <param name="episodeID">Patient episode ID</param>
        public void LoadByEpisode(int episodeID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "EpisodeID", episodeID);
            LoadRecordSetStream("pWardByEpisode", parameters);
        }

        /// <summary>Loads ward that the patient is on</summary>
        /// <param name="episodeID">location ID</param>
        public void LoadByLocationID(int locationID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "LocationID", locationID);
            LoadRecordSetStream("pWardByLocationID", parameters);
        }

        /// <summary>Load all wards returning only DISTINCT of WardCode and InUse flag 02Sep14 XN  88509</summary>
        private void LoadAll()
        {
            LoadRecordSetStream("pWardAllForPharmacy", new StringBuilder());
        }

        /// <summary>
        /// Returns the ward, with the specified ward code 
        /// (matched through LocationAlias where AliasGroup is 'WWardCodes')
        /// Once read from the DB, row is cached for the request duration.
        /// </summary>
        /// <param name="code">ward code</param>
        /// <returns>ward row, or null</returns>
        public static WardRow GetByWardCode(string code)
        {
            string cachedName = string.Format("{0}.GetByWardCode({1})", typeof(Ward).FullName, code);
            
            // Try read from request cache
            WardRow row = PharmacyDataCache.GetFromContext(cachedName) as WardRow;
            if (row == null)
            {
                // Info does not exist in request cache so read from DB.
                Ward Ward = new Ward();
                Ward.LoadByWardCode(code);
                if (Ward.Any())
                    row = Ward[0];

                // Save to request cache
                PharmacyDataCache.SaveToContext(cachedName, row);
            }

            return row;
        }

        /// <summary>Returns ward for the specified location ID (or null if does not exist)</summary>
        public static WardRow GetByID(int locationID)
        {
            Ward ward = new Ward();
            ward.LoadByLocationID(locationID);
            return ward.FirstOrDefault();
        }

        /// <summary>
        /// Returns all wards returning only DISTINCT of WardCode and InUse flag 
        /// Note: multiple ward may have the same ward code (so they might still be 2 entries in the list 1 for in-use ward and other for out of use wards)
        /// 02Sep14 XN  88509
        /// </summary>
        public static Ward GetAll()
        {
            Ward ward = new Ward();
            ward.LoadAll();
            return ward;
        }

        /// <summary>Returns the ward that the patient is on 08Jul15 XN 39882</summary>
        /// <param name="epsiodeId">patient episode</param>
        /// <returns>Ward or null</returns>
        public static WardRow GetByEpisode(int epsiodeId)
        {
            Ward ward = new Ward();
            ward.LoadByEpisode(epsiodeId);
            return ward.FirstOrDefault();
        }
    }
}
