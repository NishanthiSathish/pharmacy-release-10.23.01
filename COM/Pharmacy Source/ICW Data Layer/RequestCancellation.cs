using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ascribe.pharmacy.icwdatalayer
{
    internal class RequestCancellationRow : TextDocument_NonMandatoryRow
    {
        public int RequestID
        {
            get { return FieldToInt(RawRow["RequestID"]).Value; }
            set { RawRow["RequestID"] = IntToField(value);      }
        }

        public int DiscontinuationReasonID
        {
            get { return FieldToInt(RawRow["DiscontinuationReasonID"]).Value; }
            set { RawRow["DiscontinuationReasonID"] = IntToField(value);      }
        }
    }

    /// <summary>Provides column information about the RequestCancellation table (and TextDocument_NonMandatory, Note tablse)</summary>
    internal class RequestCancellationColumnInfo : TextDocument_NonMandatoryColumnInfo
    {
        public RequestCancellationColumnInfo() : base("RequestCancellation") { }
    }

    /// <summary>Represent the RequestCancellation table</summary>
    internal class RequestCancellation : TextDocument_NonMandatory<RequestCancellationRow, RequestCancellationColumnInfo>
    {
        public RequestCancellation() : base("RequestCancellation", "NoteID", "Request Cancellation") { }
    }
}
