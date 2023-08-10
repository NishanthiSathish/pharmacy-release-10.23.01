//=====================================================================================
//
//							PharmacyActiveDataConnections.cs
//
//  This class is a data layer representation of the Pharmacy Active Data Connections
//
//	Modification History:
//	17Jul12 AJK  Written
//=====================================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{

    /// <summary>
    /// Represents a row in the PharmacyActiveDataConnections table
    /// </summary>
    public class PharmacyActiveDataConnectionsRow : BaseRow
    {
        /// <summary>
        /// Primary key
        /// </summary>
        public int PharmacyActiveDataConnectionsID
        {
            get { return FieldToInt(RawRow["PharmacyActiveDataConnectionsID"]).Value; }
        }

        /// <summary>
        /// The session ID for the connection
        /// </summary>
        public int SessionID
        {
            get { return FieldToInt(RawRow["SessionID"]).Value; }
            set { RawRow["SessionID"] = IntToField(value); }
        }

        /// <summary>
        /// The single use token used in the initial handshake process
        /// </summary>
        public string URLToken
        {
            get { return FieldToStr(RawRow["URLToken"]); }
            set { RawRow["URLToken"] = StrToField(value); }
        }

        /// <summary>
        /// The symetric key used for encryption
        /// </summary>
        public string Key
        {
            get { return FieldToStr(RawRow["Key"]); }
            set { RawRow["Key"] = StrToField(value); }
        }

        /// <summary>
        /// The data the connectin was created
        /// </summary>
        public DateTime Created
        {
            get { return FieldToDateTime(RawRow["Created"]).Value; }
            set { RawRow["Created"] = DateTimeToField(value); }
        }

        /// <summary>
        /// The entity id used to create the connection
        /// </summary>
        public int CreatedByEntityID
        {
            get { return FieldToInt(RawRow["CreatedByEntityID"]).Value; }
            set { RawRow["CreatedByEntityID"] = IntToField(value); }
        }

        /// <summary>
        /// The last time the connection was used
        /// </summary>
        public DateTime LastUsed
        {
            get { return FieldToDateTime(RawRow["LastUsed"]).Value; }
            set { RawRow["LastUsed"] = DateTimeToField(value); }
        }
    }

    /// <summary>
    /// Column information for the PharmacyActiveDataConnections table
    /// </summary>
    public class PharmacyActiveDataConnectionsColumnInfo : BaseColumnInfo
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public PharmacyActiveDataConnectionsColumnInfo() : base("PharmacyActiveDataConnections") { }
    }

    /// <summary>
    /// Represents the PharmacyActiveDataConnections table
    /// </summary>
    public class PharmacyActiveDataConnections : BaseTable<PharmacyActiveDataConnectionsRow, PharmacyActiveDataConnectionsColumnInfo>
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public PharmacyActiveDataConnections()
            : base("PharmacyActiveDataConnections", "PharmacyActiveDataConnectionsID")
        {
            UpdateSP = "pPharmacyActiveDataConnectionsUpdate";
        }

        /// <summary>
        /// Constructor with rowlocking option
        /// </summary>
        /// <param name="rowLocking">Lock rows</param>
        public PharmacyActiveDataConnections(RowLocking rowLocking)
            : base("PharmacyActiveDataConnections", "PharmacyActiveDataConnectionsID", rowLocking)
        {
            UpdateSP = "pPharmacyActiveDataConnectionsUpdate";
        }

        /// <summary>
        /// Loads a PharmacyActiveDataConnections by SessionID and URLToken
        /// </summary>
        /// <param name="sessionID">The session ID used to create the session</param>
        /// <param name="urlToken">The URL token used to create the session</param>
        public void LoadBySessionIDAndURLToken(int sessionID, string urlToken)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "SessionID", sessionID);
            AddInputParam(parameters, "URLToken", urlToken);
            LoadRecordSetStream("pPharmacyActiveDataConnectionsBySessionIDAndURLToken", parameters);
        }

        /// <summary>
        /// Loads a PharmacyActiveDataConnections by PK
        /// </summary>
        /// <param name="pharmacyActiveDataConnectionsID">The primary key</param>
        public void LoadByPharmacyActiveDataConnectionsID(int pharmacyActiveDataConnectionsID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "PharmacyActiveDataConnectionsID", pharmacyActiveDataConnectionsID);
            LoadRecordSetStream("pPharmacyActiveDataConnectionsByPharmacyActiveDataConnectionsID", parameters);
        }
    }
}
