//===========================================================================
//
//							Consultant.cs
//
//  Provides access to Consultant table.
//
//  Class is derived from Person (and then from Entity)
//
//  SP for this object should return all fields from Person, and Entity tables, 
//  and a link to 
//      EntityAlias where AliasGroup is 'WConsultantCodes' as ConsultantCode
//
//  Only supports reading.
//
//	Modification History:
//	03Sep10 XN  Written (F0082255)
//  08Feb12 XN  Consultant now derives from BaseTable rather than Person
//  22Nov11 AJK Added Custom alias functionality
//  30Mar16 XN  Moved to BaseTable2, added GetByEpisodeId 123082
//===========================================================================
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Represents a record in the Consultant, Person, and Entity tables</summary>
    public class ConsultantRow : PersonRow
    {
        /// <summary>
        /// Consultant code
        /// From EntityAlias where AliasGroup is 'WConsultantCodes'
        /// </summary>
        public string Code
        {
            get { return FieldToStr(RawRow["ConsultantCode"]); }
        }

        /// <summary>
        /// Custom Alias
        /// Requested alias when loaded using LoadAllByAliasGroupDescription
        /// </summary>
        public string CustomAlias
        {
            get { return FieldToStr(RawRow["CustomAlias"]); }
        }
    }

    /// <summary>Provides column information about the Consultant, Person, and Entity tables</summary>
    public class ConsultantColumnInfo : PersonColumnInfo
    {
        public ConsultantColumnInfo() : base("Consultant") { }
    }

    /// <summary>Represent the Consultant, Person, and Entity table</summary>
    public class Consultant : BaseTable2<ConsultantRow, ConsultantColumnInfo>
    {
        public Consultant() : base("Consultant", "Person", "Entity") { }

        /// <summary>
        /// Loads consultant by consultant code 
        /// (matched through EntityAlias where AliasGroup is 'WConsultantCodes')
        /// </summary>
        /// <param name="code">consultant code</param>
        protected void LoadByConsultantCode(string code)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("Code",             code);
            this.LoadBySP("pConsultantByCode", parameters);
        }

        /// <summary>
        /// Loads consultants by alias group description
        /// (matched through EntityAlias where AliasGroup is 'WConsultantCodes')
        /// </summary>
        /// <param name="description">Alias group description</param>
        public void LoadAllByAliasGroupDescription(string description)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID",      SessionInfo.SessionID);
            parameters.Add("AliasGroupDescription", description);
            this.LoadBySP("pConsultantByAliasGroupDescription", parameters);
        }

        /// <summary>Loads consultant that is dealing with patient</summary>
        /// <param name="episodeID">Patient's episode ID</param>
        public void LoadByEpisode(int episodeID)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("EpisodeID",        episodeID);
            this.LoadBySP("pConsultantByEpisode", parameters);
        }

        /// <summary>
        /// Returns the consultant, with the specified consultant code 
        /// (matched through EntityAlias where AliasGroup is 'WConsultantCodes')
        /// Once read from the DB, row is cached for the request duration.
        /// </summary>
        /// <param name="code">consultant code</param>
        /// <returns>Consultant row, or null</returns>
        public static ConsultantRow GetByConsultnatCode(string code)
        {
            string cachedName = string.Format("{0}.GetByConsultnatCode({1})", typeof(Consultant).FullName, code);
            
            // Try read consultant info from request cache
            ConsultantRow row = PharmacyDataCache.GetFromContext(cachedName) as ConsultantRow;
            if (row == null)
            {
                // Consultant info does not exist in request cach so read from DB.
                Consultant consultant = new Consultant();
                consultant.LoadByConsultantCode(code);
                if (consultant.Any())
                    row = consultant[0];

                // Save to request cache
                PharmacyDataCache.SaveToContext(cachedName, row);
            }

            return row;
        }

        /// <summary>Returns the consultant for the episode else null 16Aor16 Xn 123082</summary>
        /// <param name="episodeId">Episode Id</param>
        /// <returns>Consultant for episode</returns>
        public static ConsultantRow GetByEpisodeId(int episodeId)
        {
            Consultant con = new Consultant();
            con.LoadByEpisode(episodeId);
            return con.FirstOrDefault();
        }
    }
}
