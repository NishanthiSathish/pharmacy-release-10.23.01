using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.icwdatalayer
{
    public class TextDocument_NonMandatoryRow : NoteRow
    {
        public int NoteID
        {
            get { return FieldToInt(RawRow["NoteID"]).Value; }
        }

        public string Detail
        {
            get { return FieldToStr(RawRow["Detail"], false, string.Empty); }
            set { RawRow["Detail"] = StrToField(value, false);              }
        }
    }

    public class TextDocument_NonMandatoryColumnInfo : NoteColumnInfo
    {
        public TextDocument_NonMandatoryColumnInfo() : base("Request") { }

        public TextDocument_NonMandatoryColumnInfo(string inheritiedTableName) : base(inheritiedTableName) { }

        public int DetailLength { get { return FindColumnByName("Detail").Length; } }
    }

    public class TextDocument_NonMandatory<T, C> : Note<T, C>
        where T : TextDocument_NonMandatoryRow, new()
        where C : TextDocument_NonMandatoryColumnInfo, new()
    {
        /// <summary>Constructor</summary>
        /// <param name="tableName">Name of db table class is associated with</param>
        /// <param name="pkcolumnName">Name of db PK column for table</param>
        /// <param name="noteTypeName">Name of the associated note type (must be registered in ICW NoteType table)</param>
        public TextDocument_NonMandatory(string tableName, string pkcolumnName, string noteTypeName) : base(tableName, pkcolumnName, noteTypeName) { }
    }
}
