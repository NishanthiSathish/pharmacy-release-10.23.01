//=======================================================================================
//
//							PharmacyActiveDataConnections.cs
//
//  This class holds all business logic for handling a Pharmacy Active Data Connection
//  object.
//
//	Modification History:
//	17Jul12 AJK Written
//=======================================================================================
using System;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using System.Collections.Generic;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>
    /// Represents a Pharmacy Active Data Connection
    /// </summary>
    public class PharmacyActiveDataConnectionsLine : IBusinessObject
    {
        public int PharmacyActiveDataConnectionsID { get; internal set; }
        public int SessionID { get; set; }
        public string URLToken { get; set; }
        public string Key { get; set; }
        public DateTime Created { get; set; }
        public int CreatedByEntityID { get; set; }
        public DateTime LastUsed { get; set; }
    }

    /// <summary>
    /// Processes harmacy Active Data Connection
    /// </summary>
    public class PharmacyActiveDataConnectionsProcessor : BusinessProcess
    {
        /// <summary>
        /// Updates a Pharmacy Active Data Connection object
        /// </summary>
        /// <param name="connection">PharmacyActiveDataConnectionsLine object to update</param>
        public void Update(PharmacyActiveDataConnectionsLine connection)
        {
            using (PharmacyActiveDataConnections dbConnection = new PharmacyActiveDataConnections())
            {
                if (connection.PharmacyActiveDataConnectionsID == 0)
                {
                    dbConnection.Add();
                }
                else
                {
                    dbConnection.LoadByPharmacyActiveDataConnectionsID(connection.PharmacyActiveDataConnectionsID);
                }
                dbConnection[0].Created = connection.Created;
                dbConnection[0].CreatedByEntityID = connection.CreatedByEntityID;
                dbConnection[0].Key = connection.Key;
                dbConnection[0].LastUsed = connection.LastUsed;
                dbConnection[0].SessionID = connection.SessionID;
                dbConnection[0].URLToken = connection.URLToken;
                dbConnection.Save();
                connection.PharmacyActiveDataConnectionsID = dbConnection[0].PharmacyActiveDataConnectionsID;
            }
        }

        /// <summary>
        /// Loads a PharmacyActiveDataConnections object by the primary key
        /// </summary>
        /// <param name="pharmacyActiveDataConnectionsID">The primary key</param>
        /// <returns>A PharmacyActiveDataConnectionsLine object</returns>
        public PharmacyActiveDataConnectionsLine LoadByPharmacyActiveDataConnectionsID(int pharmacyActiveDataConnectionsID)
        {
            using (PharmacyActiveDataConnections dbConnection = new PharmacyActiveDataConnections())
            {
                dbConnection.LoadByPharmacyActiveDataConnectionsID(pharmacyActiveDataConnectionsID);
                if (dbConnection.Count == 0)
                    throw new ApplicationException(string.Format("PharmacyActiveDataConnection not found (PharmacyActiveDataConnectionsID={0})", pharmacyActiveDataConnectionsID));
                return FillData(dbConnection[0]);
            }
        }

        /// <summary>
        /// Loads a PharmacyActiveDataConnections object by the primary key
        /// </summary>
        /// <param name="sessionID">The sessionID used to create the connection</param>
        /// <param name="urlToken">The URLToken used to create the connection</param>
        /// <returns>A PharmacyActiveDataConnectionsLine object</returns>
        public PharmacyActiveDataConnectionsLine LoadBySessionIDAndURLToken(int sessionID, string urlToken)
        {
            using (PharmacyActiveDataConnections dbConnection = new PharmacyActiveDataConnections())
            {
                dbConnection.LoadBySessionIDAndURLToken(sessionID,urlToken);
                if (dbConnection.Count == 0)
                    throw new ApplicationException(string.Format("PharmacyActiveDataConnection not found (SessionID={0}, URLToken={1})", sessionID, urlToken));
                return FillData(dbConnection[0]);
            }
        }

        /// <summary>
        /// Fills the PharmacyActiveDataConnectionsLine object with the database object data
        /// </summary>
        /// <param name="dbConnectionsRow">The database object to use to populate</param>
        /// <returns>The filled PharmacyActiveDataConnectionsLine object</returns>
        private PharmacyActiveDataConnectionsLine FillData(PharmacyActiveDataConnectionsRow dbConnectionsRow)
        {
            PharmacyActiveDataConnectionsLine connection = new PharmacyActiveDataConnectionsLine();
            connection.Created = dbConnectionsRow.Created;
            connection.CreatedByEntityID = dbConnectionsRow.CreatedByEntityID;
            connection.Key = dbConnectionsRow.Key;
            connection.LastUsed = dbConnectionsRow.LastUsed;
            connection.PharmacyActiveDataConnectionsID = dbConnectionsRow.PharmacyActiveDataConnectionsID;
            connection.SessionID = dbConnectionsRow.SessionID;
            connection.URLToken = dbConnectionsRow.URLToken;
            return connection;
        }


    }
}
