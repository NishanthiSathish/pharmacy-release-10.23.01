// -----------------------------------------------------------------------
// <copyright file="AMMStateChangeNote.cs" company="Emis Health">
//      Emis Health Plc
// </copyright>
// <summary>
// This class represents the AMMStateChangeNote table.  
//
// Only supports reading, updating, and inserting from table.
//
// Classes are derived from Note.
//
// AMMStateChangeNote are created whenever the supply request moves to the new state
// So time the state was entered
//
// Modification History:
// 02Jul15 XN Created 39882
// 22Aug16 XN Added LoadByRequestID and IfAnyStageUndone 160920
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.manufacturinglayer
{
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.Linq;
    using System.Text;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.icwdatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>Row in the AMMStateChangeNote table</summary>
    public class AMMStateChangeNoteRow : NoteRow
    {
        /// <summary>Gets or sets the state note was raised for</summary>
        public aMMState? FromState
        {
            get { return FieldIntToEnum<aMMState>(this.RawRow["FromState"]);  }
            set { this.RawRow["FromState"] = EnumToFieldInt<aMMState>(value); }
        }

        /// <summary>Gets or sets the state note was raised for</summary>
        public aMMState ToState
        {
            get { return FieldIntToEnum<aMMState>(this.RawRow["ToState"]).Value; }
            set { this.RawRow["ToState"] = EnumToFieldInt<aMMState>(value);      }
        }
    }

    /// <summary>Column info for AMMStateChangeNote table</summary>
    public class AMMStateChangeNoteColumnInfo : NoteColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="AMMStateChangeNoteColumnInfo"/> class</summary>
        public AMMStateChangeNoteColumnInfo() : base("AMMStateChangeNote") { }
    }

    /// <summary>AMMStateChangeNote table</summary>
    public class AMMStateChangeNote : Note<AMMStateChangeNoteRow, AMMStateChangeNoteColumnInfo>
    {
        /// <summary>Initializes a new instance of the <see cref="AMMStateChangeNote"/> class</summary>
        public AMMStateChangeNote() : base("AMMStateChangeNote", "NoteID", "AMM State Change") {  }

        /// <summary>Adds new note for specific state (setting correct description)</summary>
        /// <param name="fromState">From state</param>
        /// <param name="toState">New state</param>
        public void Add(aMMState? fromState, aMMState toState)
        {
            var note = base.Add();
            note.FromState = fromState;
            note.ToState   = toState;

            if (fromState == null)
            {
                note.Description = string.Format("Setting to state {0}", aMMSetting.StateString(toState));
            }
            else if (toState >= fromState)
            {
                note.Description = string.Format("From state {0} to {1}", aMMSetting.StateString(fromState.Value), aMMSetting.StateString(toState));
            }
            else
            {
                note.Description = string.Format("Undone from state {0} to {1}", aMMSetting.StateString(fromState.Value), aMMSetting.StateString(toState));
            }
        }

        /// <summary>Loads the latest note (non cancelled) by request Id</summary>
        /// <param name="requestId">Related request Id</param>
        public void LoadLatestByRequestID(int requestId)
        {
            StringBuilder parameters = new StringBuilder();
            this.AddInputParam(parameters, "RequestID", requestId);
            this.LoadRecordSetStream("pAMMStateChangeNoteLatestByRequestID", parameters);
        }

        /// <summary>Loads the first note (non cancelled) by request Id after specific state</summary>
        /// <param name="requestId">Related request Id</param>
        /// <param name="afterState">After state</param>
        public void LoadFirstAfterStateForRequestId(int requestId, aMMState afterState)
        {
            StringBuilder parameters = new StringBuilder();
            this.AddInputParam(parameters, "RequestID", requestId);
            this.AddInputParam(parameters, "afterState",     (int)afterState);
            this.LoadRecordSetStream("pAMMStateChangeNoteByRequestIDAndAfterState", parameters);
        }

        /// <summary>Loads the all notes by request Id 22Aug16 XN 160920</summary>
        /// <param name="requestId">request Id</param>
        public void LoadByRequestID(int requestId)
        {
            StringBuilder parameters = new StringBuilder();
            this.AddInputParam(parameters, "RequestID", requestId);
            this.LoadRecordSetStream("pAMMStateChangeNoteByRequestID", parameters);
        }

        /// <summary>Gets latest note (non cancelled) by request Id</summary>
        /// <param name="requestId">Related request Id</param>
        /// <returns>latest note</returns>
        public static AMMStateChangeNoteRow GetLatestByRequestId(int requestId)
        {
            AMMStateChangeNote note = new AMMStateChangeNote();
            note.LoadLatestByRequestID(requestId);
            return note.FirstOrDefault();
        }

        /// <summary>Returns if any stage has been undone 22Aug16 XN 160920</summary>
        /// <returns></returns>
        public static bool IfAnyStageUndone(int requestId)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("RequestID", requestId);
            return Database.ExecuteSPReturnValue<bool>("pAMMStateChangeNoteIfAnyStageUndone", parameters);
        }
    }
}
