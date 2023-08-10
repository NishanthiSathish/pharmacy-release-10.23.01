//===========================================================================
//
//							       EpisodeOrder.cs
//
//  Provides access to EpisodeOrder (and Request) tables.
//  
//  SP for this object should return all fields from the EpisodeOrder, and Request tables
//
//  Only supports reading.
//
//	Modification History:
//	14Aug13 XN  Written (70138)
//  17Jun15 XN  Added GetEpisodeIdByRequestId 39882
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using System.Data.SqlClient; 

namespace ascribe.pharmacy.icwdatalayer
{
    public class EpisodeOrderRow : RequestRow
    {
        public int EpisodeID       
        { 
            get { return FieldToInt(RawRow["EpisodeID"]).Value;     }
            set { RawRow["EpisodeID"] = IntToField(value);          }
        }

        public int EntityID_Owner  
        { 
            get { return FieldToInt(RawRow["EntityID_Owner"]).Value;  } 
            set { RawRow["EntityID_Owner"] = IntToField(value);       }
        }

        public int OrderTemplateID 
        { 
            get { return FieldToInt(RawRow["OrderTemplateID"]).Value; } 
            set { RawRow["OrderTemplateID"] = IntToField(value);      }
        }
    }

    public class EpisodeOrderColumnInfo : RequestColumnInfo
    {
        public EpisodeOrderColumnInfo() : base("EpisodeOrder") { }

        public EpisodeOrderColumnInfo(string inheritiedTableName) : base(inheritiedTableName) { }
    }

    public class EpisodeOrder : BaseTable2<EpisodeOrderRow, EpisodeOrderColumnInfo>
    {
        public EpisodeOrder() : base("EpisodeOrder", "Request") { } 

        /// <summary>
        /// Loads the episode from an alias (from EpisodeOrderAlias table)
        /// Asserts if alias does not exist
        /// </summary>
        public void LoadByAlias(string alias, string aliasGroup)
        {
            ICWTypeData? typeData = ICWTypes.GetTypeByDescription(ICWType.AliasGroup, aliasGroup);
            if (typeData == null)
                throw new ApplicationException("Invalid alias group '" + aliasGroup + "'");

            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@Alias",        alias              ));
            parameters.Add(new SqlParameter("@AliasGroupID", typeData.Value.ID  ));
            LoadBySP("pEpisodeOrderByAlias", parameters);
        }

        /// <summary>Get the episodeId for request</summary>
        /// <param name="requestId">Request Id</param>
        /// <returns>Episode Id</returns>
        public static int GetEpisodeIdByRequestId(int requestId)
        {
            return Database.ExecuteSQLScalar<int>("SELECT EpisodeID FROM EpisodeOrder WHERE RequestID={0}", requestId);
        }
    }
}
