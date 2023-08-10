// -----------------------------------------------------------------------
// <copyright file="Observation.cs" company="Emis Health">
//      Copyright Emis Health PLc
// </copyright>
// <summary>
// Provides access to the HAP Observation table
//  
// The class only supports reading
//
// Modification History:
// 19Jun15 XN Created 39882
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.icwdatalayer
{
    using System;
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.Linq;

    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>Observation row</summary>
    public class ObservationRow : BaseRow
    {
        /// <summary>Gets the observation value</summary>
        public double Value  { get { return FieldToDouble(this.RawRow["Value"]).Value; } }

        /// <summary>Gets the observation unit ID</summary>
        public int UnitId { get { return FieldToInt(this.RawRow["UnitID"]).Value; } }

        /// <summary>Returns if the observation has expired</summary>
        public bool Expired { get { return this.RawRow["ExpiryDateTime"] != DBNull.Value; } }
    }

    /// <summary>Observation table column info</summary>
    public class ObservationColumnInfo : BaseColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="ObservationColumnInfo"/> class.</summary>
        public ObservationColumnInfo() : base("Observation") {}        
    }

    /// <summary>Observation table</summary>
    public class Observation : BaseTable2<ObservationRow, ObservationColumnInfo>
    {
        /// <summary>Initializes a new instance of the <see cref="Observation"/> class.</summary>
        public Observation() : base("Observation") { }
     
        /// <summary>Loads the latest observation by episodeId and noteTypeId</summary>
        /// <param name="episodeId">episode ID</param>
        /// <param name="noteTypeId">Note Type ID</param>
        private void LoadLatestByEpisodeTypeAndActive(int episodeId, int noteTypeId)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("EpisodeID",  episodeId);
            parameters.Add("NoteTypeID", noteTypeId);
            this.LoadBySP("pObservationLatestByEpisodeTypeAndActive", parameters);
        }

        /// <summary>Returns the latest observation by episodeId and noteTypeId</summary>
        /// <param name="episodeId">episode ID</param>
        /// <param name="noteTypeId">Note Type ID</param>
        /// <returns>Returns the observation</returns>
        public static ObservationRow GetLatestByEpisodeTypeAndActive(int episodeId, int noteTypeId)
        {
            Observation observation = new Observation();
            observation.LoadLatestByEpisodeTypeAndActive(episodeId, noteTypeId);
            return observation.FirstOrDefault();
        }
    }
}
