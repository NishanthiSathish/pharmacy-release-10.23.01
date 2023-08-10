// -----------------------------------------------------------------------
// <copyright file="AMMReportError.cs" company="Emis Health Plc">
//      Copyright Emis Health Plc
// </copyright>
// <summary>
// This class represents the AMMReportError table.  
//
// Only supports reading, updating, and inserting from table.
//
// Classes are derived from AttachedNote, Note.
// Also need to link in AMMReportErrorReason
//      AMMReportErrorReason.Code        as AMMReportErrorReasonCode
//      AMMReportErrorReason.Description as AMMReportErrorReasonDescription
//
// Modification History:
// 02Jul15 XN Created 39882
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.manufacturinglayer
{
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;

    /// <summary>AMMReportError table row</summary>
    public class AMMReportErrorRow : AttachedNoteRow
    {
        /// <summary>Gets or sets the error reason ID</summary>
        public int AMMReprtErrorReasonId
        {
            get { return FieldToInt(this.RawRow["AMMReportErrorReasonID"]).Value; }
            set { this.RawRow["AMMReportErrorReasonID"] = IntToField(value);      } 
        }

        /// <summary>Gets the AMMReportErrorReason.Code</summary>
        public string AMMReportErrorReasonCode { get { return FieldToStr(this.RawRow["AMMReportErrorReasonCode"]); } }

        /// <summary>Gets the AMMReportErrorReason.Description</summary>
        public string AMMReportErrorReasonDescription { get { return FieldToStr(this.RawRow["AMMReportErrorReasonDescription"]); } }

        /// <summary>Gets or sets the comment</summary>
        public string Comments
        {
            get { return FieldToStr(this.RawRow["Comments"]);  }
            set { this.RawRow["Comments"] = StrToField(value); } 
        }
    }

    /// <summary>AMMReportError table info</summary>
    public class AMMReportErrorColumnInfo: AttachedNoteColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="AMMReportErrorColumnInfo"/> class.</summary>
        public AMMReportErrorColumnInfo() : base("AMMReportError") { }

        /// <summary>Gets the length of the comments</summary>
        public int CommentsLength { get { return  this.FindColumnByName("Comments").Length; } }
    }

    /// <summary>AMMReportError table</summary>
    public class AMMReportError : Note<AMMReportErrorRow, AMMReportErrorColumnInfo>
    {
        /// <summary>Initializes a new instance of the <see cref="AMMReportError"/> class</summary>
        public AMMReportError() : base("AMMReportError", "NoteID", "AMM Report Error") { }

        /// <summary>Add new error</summary>
        /// <param name="AMMReprtErrorReasonId">Reason id</param>
        /// <param name="comments">Comments value</param>
        public void Add(int AMMReprtErrorReasonId, string comments)
        {
            var newRow = base.Add();
            newRow.Enabled = true;
            newRow.AMMReprtErrorReasonId = AMMReprtErrorReasonId;
            newRow.Comments = comments;
        }
    }
}
