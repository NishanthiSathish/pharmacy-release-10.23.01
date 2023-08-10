using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ascribe.pharmacy.icwdatalayer
{
    public class CancellationNoteRow : NoteRow
    {
        public int? DiscontinuationReasonID
        {
            get { return FieldToInt(RawRow["DiscontinuationReasonID"]);  }
            set { RawRow["DiscontinuationReasonID"] = IntToField(value); }
        }
    }

    /// <summary>Provides column information about the CancellationNote table (and Note tables)</summary>
    public class CancellationNoteColumnInfo : TextDocument_NonMandatoryColumnInfo
    {
        public CancellationNoteColumnInfo() : base("CancellationNote") { }
    }

    /// <summary>Represent the CancellationNote table</summary>
    public class CancellationNote : Note<CancellationNoteRow, CancellationNoteColumnInfo>
    {
        public CancellationNote() : base("CancellationNote", "NoteID", "Cancellation Note") { }
    }

}
