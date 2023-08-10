//===========================================================================
//
//							       ScheduleTemplateBody.cs
//
//  Provides access to ScheduleTemplateBody table.
//  Plus linked in fields
//      DailyFrequencyRepeat_UnitID_Multiple_Unit - Unit.Multiple via DailyFrequencyRepeat_UnitID
//
//  Read only
//
//	Modification History:
//	12Jul09 XN  Created F0041502
//  06Mar15 XN  Upgraded to BaseTable2 and added method CalculateDailyTimeSlots
//===========================================================================
using System;
using System.Text;
using ascribe.pharmacy.basedatalayer;

namespace ascribe.pharmacy.icwdatalayer
{
    using System.Data.SqlClient;
    using System.Linq;
    using System.Net.Sockets;
    using System.Collections.Generic;

    using ascribe.pharmacy.shared;

    public class ScheduleTemplateBodyRow : BaseRow
    {
        /// <summary>Schedule template ID</summary>
        public int ScheduleTemplateID { get { return FieldToInt(RawRow["ScheduleTemplateID"]).Value; } }

        /// <summary>Schedule template body ID</summary>
        public int ScheduleTemplateBodyID { get { return FieldToInt(RawRow["ScheduleTemplateBodyID"]).Value; } } 

        /// <summary>Daily Frequency Repeat Count only valid if DailyFrequencyStartTime == 0</summary>
        public int DailyFrequencyRepeat_Count { get { return FieldToInt(RawRow["DailyFrequencyRepeat_Count"]).Value;  } }

        /// <summary>Daily Frequency Repeat Count in secs only valid if DailyFrequencyStartTime == 0</summary>
        public int DailyFrequencyRepeat_Count_InSeconds { get { return (int)(this.DailyFrequencyRepeat_Count * this.DailyFrequencyRepeat_UnitID_Multiple_Unit);  } }

        /// <summary>Daily frequency start time can be 0 for items like '4 times a day'</summary>
        public TimeSpan DailyFrequencyStartTime { get { return new TimeSpan(0, 0, FieldToInt(RawRow["DailyFrequencyStartTime"]).Value); } }

        /// <summary>Unit.Multiple to seconds for the Daily Frequency Repeat</summary>
        public double DailyFrequencyRepeat_UnitID_Multiple_Unit { get { return FieldToDouble(RawRow["DailyFrequencyRepeat_UnitID_Multiple_Unit"]).Value;  } }
    }

    public class ScheduleTemplateBodyColumnInfo : BaseColumnInfo
    {
        public ScheduleTemplateBodyColumnInfo() : base("ScheduleTemplateBody") { }
    }

    public class ScheduleTemplateBody : BaseTable2<ScheduleTemplateBodyRow, ScheduleTemplateBodyColumnInfo>
    {
        public ScheduleTemplateBody() : base("ScheduleTemplateBody") { }

        /// <summary>
        /// Number of daily time slots the a schedule template will use
        ///     e.g. if every 4 hours will return 6
        ///          4 times a day (at 8:00, 12:00: 17:00 21:00) will return 4
        /// Won't handle templates like 'with feeds' as templates in db is invalid
        /// </summary>
        /// <param name="scheduleTemplateID">Template ID</param>
        /// <returns>Number of slots</returns>
        public int CalculateDailyTimeSlots(int scheduleTemplateID)
        {
            var templates = this.Where(t => t.ScheduleTemplateID == scheduleTemplateID).ToList();
            int slots = 0;

            if (templates.Any() && templates[0].DailyFrequencyStartTime.Ticks == 0 && templates[0].DailyFrequencyRepeat_Count_InSeconds > 0)
            {
                // If DailyFrequencyStartTime=0 then use DailyFrequencyRepeat_Count to calculate number of slots per day
                // used for items like 'every 4 hours'
                slots = (24 * 60 * 60) / templates[0].DailyFrequencyRepeat_Count_InSeconds;
            }
            else if (templates.Any() && templates[0].DailyFrequencyStartTime.Ticks > 0)
            {
                // If there are DailyFrequencyStartTime values then return the count
                // used for times like  4 times a day (at 8:00, 12:00: 17:00 21:00)
                slots = templates.Count;
            }

            return slots;
        }

        /// <summary>Loads the ScheduleTemplateBody from a prescriptions schedule</summary>
        /// <param name="scheduleID">schedule id of the prescription</param>
        public void LoadByScheduleID(int scheduleID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("ScheduleID",      scheduleID);
            LoadBySP("pScheduleTemplateBodyByScheduleID", parameters);
        }
    }
}
