//===========================================================================
//
//							Note.cs
//
//  Provides access to Note table.
//
//  Classes are derived from BaseRow
//
//  Currently it is not easy to create an instance of this class, it is more to be 
//  used by derived classes that inherit from the Note table.
//
//  Only supports reading.
//
//	Modification History:
//	03Sep10 XN  Written (F0082255)
//  02Apr14 XN  Added NoteRow.OriginID and default to 0 (mew column from ICW)
//  01Jul15 XN  Added NoteRow 39882
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;
using TRNRTL10;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Represents a record in the Note table</summary>
    public class NoteRow : BaseRow
    {
        public int NoteID
        {
            get { return FieldToInt(RawRow["NoteID"]).Value; }
        }

        public int NoteTypeID
        {
            get { return FieldToInt(RawRow["NoteTypeID"]).Value; }
            set { RawRow["NoteTypeID"] = IntToField(value);      }
        }

        public int TableID
        {
            get { return FieldToInt(RawRow["TableID"]).Value; }
            set { RawRow["TableID"] = IntToField(value);      }
        }

        public int EntityID
        {
            get { return FieldToInt(RawRow["EntityID"]).Value; }
            set { RawRow["EntityID"] = IntToField(value);      }
        }

        public int NoteID_Thread
        {
            get { return FieldToInt(RawRow["NoteID_Thread"]).Value; }
            set { RawRow["NoteID_Thread"] = IntToField(value);      }
        }

        public string Description
        {
            get { return FieldToStr(RawRow["Description"]);  }
            set { RawRow["Description"] = StrToField(value); }
        }

        public DateTime CreatedDate
        {
            get { return FieldToDateTime(RawRow["CreatedDate"]).Value;  }
            set { RawRow["CreatedDate"] = DateTimeToField(value);       }
        }

        // XN 2Apr14 New DB column from ICW
        public int OriginID
        {
            get { return FieldToInt(RawRow["OriginID"]).Value;  }
            set 
            { 
                if (this.RawRow.Table.Columns.Contains("OriginID")) // Can remove this table column test after 10.10 has been released
                    RawRow["OriginID"] = IntToField(value);       
            }
        }

        /// <summary>Gets the person who created the note 01Jul15 XN 39882</summary>
        /// <returns>Person who created the note</returns>
        public PersonRow GetPerson()
        {
            return Person.GetByEntityID(this.EntityID);
        }
    }

    /// <summary>Provides column information about the Note table</summary>
    public class NoteColumnInfo : BaseColumnInfo
    {
        public NoteColumnInfo(string tableName) : base(tableName) { }
    }

    /// <summary>Represent the Note table</summary>
    public class Note<T, C> : BaseTable<T, C>
        where T : NoteRow, new()
        where C : NoteColumnInfo, new()
    {
        #region Constructor
        /// <summary>
        /// Constructor
        /// </summary>
        /// <param name="tableName">Name of db table class is associated with</param>
        /// <param name="pkcolumnName">Name of db PK column for table</param>
        /// <param name="noteTypeName">Name of the associated note type (must be registered in ICW NoteType table)</param>
        public Note(string tableName, string pkcolumnName, string noteTypeName)
            : base(tableName, pkcolumnName)
        {
            NoteTypeName = noteTypeName;
        }        
        #endregion

        #region Public Methods
        /// <summary>Adds a new row, and sets default values.</summary>
        /// <returns>New row</returns>
        public override T Add()
        {
            T newRow = base.Add();

            // Set common defautls
            newRow.NoteTypeID = this.NoteTypeID;
            newRow.TableID = this.TableID;
            newRow.EntityID = SessionInfo.EntityID;
            newRow.NoteID_Thread = 0;
            newRow.Description = this.NoteTypeName;
            newRow.CreatedDate = DateTime.Now;
            newRow.OriginID = 0;    // XN 2Apr14 New DB column from ICW

            return newRow;
        }        
        #endregion

        #region Protected Properties
		/// <summary>NoteType for this note table</summary>
        protected string NoteTypeName { get; set; }

        /// <summary>NoteTypeID for this note table (read from ICW NoteType table)</summary>
        protected int NoteTypeID
        {
            get
            {
                string cacheName = string.Format("{0}.NoteTypeID", this.GetType().FullName);

                if (string.IsNullOrEmpty(NoteTypeName))
                    throw new ApplicationException("Note type not set.");

                // Try to load the map from the cache
                SortedDictionary<string, int> descriptionToNoteTypeIDs = (SortedDictionary<string, int>)PharmacyDataCache.GetFromCache(cacheName);
                if (descriptionToNoteTypeIDs == null)
                    descriptionToNoteTypeIDs = LoadNoteTypeInfo();

                // Extract the note type id from the dictionary
                int noteTypeID;
                if (!descriptionToNoteTypeIDs.TryGetValue(NoteTypeName.ToLower(), out noteTypeID))
                    throw new ApplicationException(string.Format("Invalid note type '{0}'", NoteTypeName));

                return noteTypeID;
            }
        }
        #endregion        
        
        #region Protected Methods
        /// <summary>
        /// Loads in the NoteType descriptions, and NoteTypeID from DB.
        /// Returns them as a sorted dictionary
        /// </summary>
        /// <returns>Note type description to NoteTypeID map</returns>
        protected SortedDictionary<string, int> LoadNoteTypeInfo()
        {
            Transport dblayer = new Transport();

            // Read the information from the databse.
            // The sp pPharmacyLookupTable return dataset of table "ID", and "Description" fields
            string parameters = string.Empty;
            parameters += dblayer.CreateInputParameterXML("TableName", Transport.trnDataTypeEnum.trnDataTypeVarChar, 15, "NoteType");
            parameters += dblayer.CreateInputParameterXML("PKColumn", Transport.trnDataTypeEnum.trnDataTypeVarChar, 15, "NoteTypeID");
            parameters += dblayer.CreateInputParameterXML("DescriptionColumn", Transport.trnDataTypeEnum.trnDataTypeVarChar, 15, "Description");

            DataSet ds = dblayer.ExecuteSelectSP(SessionInfo.SessionID, "pPharmacyLookupTable", parameters);

            // Move the data to a sorted list (description is set to lower case).
            SortedDictionary<string, int> descriptionToNoteTypeID = new SortedDictionary<string, int>();
            foreach (DataRow row in ds.Tables[0].Rows)
            {
                object ID = row["ID"];
                object description = row["Description"];

                if ((ID != DBNull.Value) && (description != DBNull.Value))
                    descriptionToNoteTypeID.Add(description.ToString().ToLower(), Convert.ToInt32(ID));
            }

            return descriptionToNoteTypeID;
        }        
        #endregion
    }
}
