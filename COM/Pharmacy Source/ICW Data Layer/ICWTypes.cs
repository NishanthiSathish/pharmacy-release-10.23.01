//===========================================================================
//
//					            ICWTypes.cs
//
//  Provides access to ICWTypes types table.
//
//  Normaly only used to get the note type ID from description.
//
//  SupplyRequest does not have a TableID field so this will be null
//
//	Modification History:
//	07Jul11 XN  Created
//  20Nov11 XN  Improved by adding GetTypeByDescription, and GetTypeByTableID
//              methods (returning Description, and TableID rather than just RequestTypeID)
//  23Jan11 XN  Added methods GetTypeByRequestTypeID, GetRowsID
//  24Jan11 XN  Added support for SupplyRequest type
//  09Mar12 XN  Added support for Response type
//  17Dec12 XN  Added support for PrescriptionCreationType 51136
//  09Aug13 XN  Added support for AliasGroup 24653
//  01Oct13 XN  Added support for EIE LogType 74592
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.basedatalayer;
using System.Data;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>ICW system data types (like Note, etc)</summary>
    public enum ICWType
    { 
        Note,
        Product,
        Request,
        SupplyRequest,
        Response, 
        PrescriptionCreationType,
        AliasGroup,
        /// <summary>read from LogType table</summary>
        EIELogType
    }

    /// <summary>ICW types info</summary>
    public struct ICWTypeData
    {
        /// <summary>PK for type e.g. NoteTypeID, RequestTypeID, SupplyRequestTypeID</summary>
        public int ID;

        public string Description;

        /// <summary>Will be 0 for SupplyRequestTypes</summary>
        public int? TableID;  
    }

    /// <summary>Provides access to ICWTypes types tables.</summary>
    public class ICWTypes
    {
        /// <summary>Returns the icw type data, for a type description</summary>
        /// <param name="type">ICW type of interest</param>
        /// <param name="descritpion">type description</param>
        /// <returns>type data (or null if not present)</returns>
        public static ICWTypeData? GetTypeByDescription(ICWType type, string description)
        {
            GenericTable genericTable = GetType(type);
            BaseRow      row          = genericTable.FirstOrDefault(t => t.RawRow["Description"].ToString().EqualsNoCaseTrimEnd(description));
            return (row == null) ? (ICWTypeData?)null : GenericTableToICWType(type, row.RawRow);
        }

        /// <summary>Returns the icw type data, for a table</summary>
        /// <param name="type">ICW type of interest</param>
        /// <param name="tableID">Table ID </param>
        /// <returns>type data (or null if not present)</returns>
        public static ICWTypeData? GetTypeByTableID(ICWType type, int tableID)
        {
            if (type == ICWType.SupplyRequest)
                throw new ApplicationException ("SupplyRequestType does not have table IDs");

            string tableIDStr = tableID.ToString();
            GenericTable genericTable = GetType(type);
            BaseRow      row          = genericTable.FirstOrDefault(t => t.RawRow["TableID"].ToString() == tableIDStr);
            return (row == null) ? (ICWTypeData?)null : GenericTableToICWType(type, row.RawRow);
        }

        /// <summary>Returns the icw type data by the types ID</summary>
        /// <param name="type">ICW type of interest</param>
        /// <param name="ID">Data type ID </param>
        /// <returns>type data (or null if not present)</returns>
        public  static ICWTypeData? GetTypeByRequestTypeID(ICWType type, int ID)
        {
            GenericTable genericTable = GetType(type);
            BaseRow      row          = genericTable.FirstOrDefault(t => GetRowsID(type, t.RawRow) == ID);
            return (row == null) ? (ICWTypeData?)null : GenericTableToICWType(type, row.RawRow);
        }

        /// <summary>
        /// Returns apporiate PK value from the row depending on type
        ///     If ICWType.Note                     returns NoteTypeID value
        ///     If ICWType.Product                  returns ProductTypeID value
        ///     If ICWType.Request                  returns RequestTypeID value
        ///     If ICWType.SupplyRequestType        returns SupplyRequestTypeID value
        ///     If ICWType.Response                 returns ResponseTypeID value
        ///     IF ICWType.PrescriptionCreationType returns PrescriptionCreationTypeID value
        ///     IF ICWType.AliasGroup               returns AliasGroupID value
        ///     If ICWType.EIELogType               returns LogTypeID value
        /// </summary>
        /// <param name="type">ICWTypeData row relates to</param>
        /// <param name="row">Generic row</param>
        /// <returns>PK value (else returns null)</returns>
        private static int? GetRowsID(ICWType type, DataRow row)
        {
            switch (type)
            {
            case ICWType.Note                     : return int.Parse(row["NoteTypeID"].ToString()   );
            case ICWType.Product                  : return int.Parse(row["ProductTypeID"].ToString());
            case ICWType.Request                  : return int.Parse(row["RequestTypeID"].ToString());
            case ICWType.SupplyRequest            : return int.Parse(row["SupplyRequestTypeID"].ToString());
            case ICWType.Response                 : return int.Parse(row["ResponseTypeID"].ToString());
            case ICWType.PrescriptionCreationType : return int.Parse(row["PrescriptionCreationTypeID"].ToString());
            case ICWType.AliasGroup               : return int.Parse(row["AliasGroupID"].ToString());
            case ICWType.EIELogType               : return int.Parse(row["LogTypeID"].ToString());
            }

            return null;
        }

        /// <summary>
        /// Converts the generic row to an ICWTypeData.
        /// ICWTypeData.ID          - row[PK depends on type]
        /// ICWTypeData.Description - row["Description"]
        /// ICWTypeData.TableID     - row["TableID"]
        /// </summary>
        /// <param name="type">ICWTypeData row relates to</param>
        /// <param name="row">Generic row</param>
        /// <returns>ICWTypeData for the row</returns>
        private static ICWTypeData GenericTableToICWType(ICWType type, DataRow row)
        {
            ICWTypeData typeData = new ICWTypeData();

            typeData.ID          = GetRowsID(type, row).Value;
            typeData.Description = row["Description"].ToString();
            
            typeData.TableID = null;
            if (row.Table.Columns.Contains("TableID"))
                typeData.TableID = int.Parse(row["TableID"].ToString());

            return typeData;
        }

        /// <summary>
        /// Returns genric table info for the data type
        /// Either read from database, or from cache
        /// ICWType.Note                    - Read from NoteType                    table (using pNoteTypeListXML)
        /// ICWType.Product                 - Read from ProductType                 table (using pProductTypeAll)
        /// ICWType.Request                 - Read from RequestType                 table (using pRequestTypeListXML)
        /// ICWType.SupplyRequest           - Read from SupplyRequest               table (using pSupplyRequestTypeXML)
        /// ICWType.Response                - Read from ResponseType                table (using pResponseTypeAll)
        /// ICWType.PrescriptionCreationType- Read from PrescriptionCreationTypeID  table (using pPrescriptionCreationTypeAll)
        /// ICWType.AliasGroup              - Read from AliasGroupID                table {using pAliasGroupListXML)
        /// ICWType.EIELogType              - Read from LogTypeID                   table {using pLogTypeListXML)
        /// </summary>
        /// <param name="type">ICWTypeData row relates to</param>
        /// <returns>Generic table from NoteType, ProductType, or RequestType table</returns>
        private static GenericTable GetType(ICWType type)
        {
            switch (type)
            {
                case ICWType.Note                       : return GetType("pNoteTypeListXML",            "NoteType",                 "NoteTypeID",                true );
                case ICWType.Product                    : return GetType("pProductTypeAll",             "ProductType",              "ProductTypeID",             false);
                case ICWType.Request                    : return GetType("pRequestTypeListXML",         "RequestType",              "RequestTypeID",             true );
                case ICWType.SupplyRequest              : return GetType("pSupplyRequestTypeListXML",   "SupplyRequestType",        "SupplyRequestTypeID",       true );
                case ICWType.Response                   : return GetType("pResponseTypeAll",            "ResponseType",             "ResponseTypeID",            false);
                case ICWType.PrescriptionCreationType   : return GetType("pPrescriptionCreationTypeAll","PrescriptionCreationType", "PrescriptionCreationTypeID",false);
                case ICWType.AliasGroup                 : return GetType("pAliasGroupListXML",          "AliasGroup",               "AliasGroupID",              true );
                case ICWType.EIELogType                 : return GetType("pLogTypeListXML",             "LogType",                  "LogTypeID",                 true );
            }

            throw new ApplicationException("Unsupported ICWType " + type.ToString());
        }

        /// <summary>Returns generic table read from sp, or reads it from cache</summary>
        /// <param name="sp">SP to use the get all the tables data normally p{TableName}ListXML</param>
        /// <param name="tableName">Name of the table being read</param>
        /// <param name="pkFieldName">PK field name</param>
        /// <param name="xmlSP">If the sp returns data in XML format</param>
        /// <returns>Generic table containing data returned by sp</returns>
        private static GenericTable GetType(string sp, string tableName, string pkFieldName, bool xmlSP)
        {
            string cacheName = string.Format("{0}.GetType.{1}", typeof(ICWTypes).FullName, tableName);

            // Try to load the map from the cache
            GenericTable types = (PharmacyDataCache.GetFromCache(cacheName) as GenericTable);
            if (types == null)
            {
                // If not present load using generic table class
                types = new GenericTable(tableName, pkFieldName);
                if (xmlSP)
                    types.LoadByXMLSP(sp);
                else
                    types.LoadBySP(sp);

                PharmacyDataCache.SaveToCache(cacheName, types);
            }

            return types;
        }
    }
}
