// -----------------------------------------------------------------------
// <copyright file="aMMShift.cs" company="Emis Health">
//      Copyright Emis Health Plc
// </copyright>
// <summary>
// This class represents the AMMShift table.  
//
// Only supports reading, updating, and inserting from table.
//
// The table supports logical deletes
//
// Modification History:
// 02Jul15 XN Created 39882
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.manufacturinglayer
{
    using System;
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.Dynamic;
    using System.Linq;
    using System.Text;

    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>AMMShift table row</summary>
    public class aMMShiftRow : BaseRow
    {
        /// <summary>Gets the PK</summary>
        public int AMMShiftID
        {
            get { return FieldToInt(this.RawRow["AMMShiftID"]).Value; }
        }

        /// <summary>Gets or sets the description</summary>
        public string Description
        {
            get { return FieldToStr(this.RawRow["Description"], true);  }
            set { this.RawRow["Description"] = value;                   }
        }

        /// <summary>Site that the shifts are for</summary>
        public int SiteID
        {
            get { return FieldToInt(this.RawRow["SiteID"]).Value;   }
            set { this.RawRow["SiteID"] = IntToField((int)value);   }
        }

        /// <summary>Gets or sets the start time of the shift</summary>
        public TimeSpan StartTime
        {
            get { return new TimeSpan(0, FieldToInt(this.RawRow["startTimeInMins"]).Value, 0); }
            set { this.RawRow["startTimeInMins"] = IntToField((int)value.TotalMinutes);        }
        }

        /// <summary>Gets or sets the end time of the shift</summary>
        public TimeSpan EndTime
        {
            get { return new TimeSpan(0, FieldToInt(this.RawRow["endTimeInMins"]).Value, 0); }
            set { this.RawRow["endTimeInMins"] = IntToField((int)value.TotalMinutes);        }
        }

        public DateTime CalculateEndDateForDay(DateTime date)
        {
            return StartTime < EndTime ? date.ToStartOfDay() + EndTime : date.ToStartOfDay().AddDays(1) + EndTime;
        }

        /// <summary>Gets or sets number of items the shift can manufacture</summary>
        public int SlotsAvailable
        {
            get { return FieldToInt(this.RawRow["SlotsAvailable"]).Value;   }
            set { this.RawRow["SlotsAvailable"] = IntToField((int)value);   }
        }

        /// <summary>Gets or sets a value indicating whether shifts operates on Sunday</summary>
        public bool Sunday
        {
            get { return FieldToBoolean(this.RawRow["Sunday"]).Value; }
            set { this.RawRow["Sunday"] = BooleanToField(value);      }
        }

        /// <summary>Gets or sets a value indicating whether shifts operates on Monday</summary>
        public bool Monday
        {
            get { return FieldToBoolean(this.RawRow["Monday"]).Value; }
            set { this.RawRow["Monday"] = BooleanToField(value);      }
        }

        /// <summary>Gets or sets a value indicating whether shifts operates on Tuesday</summary>
        public bool Tuesday
        {
            get { return FieldToBoolean(this.RawRow["Tuesday"]).Value; }
            set { this.RawRow["Tuesday"] = BooleanToField(value);      }
        }

        /// <summary>Gets or sets a value indicating whether shifts operates on Wednesday</summary>
        public bool Wednesday
        {
            get { return FieldToBoolean(this.RawRow["Wednesday"]).Value; }
            set { this.RawRow["Wednesday"] = BooleanToField(value);      }
        }

        /// <summary>Gets or sets a value indicating whether shifts operates on Thursday</summary>
        public bool Thursday
        {
            get { return FieldToBoolean(this.RawRow["Thursday"]).Value; }
            set { this.RawRow["Thursday"] = BooleanToField(value);      }
        }

        /// <summary>Gets or sets a value indicating whether shifts operates on Friday</summary>
        public bool Friday
        {
            get { return FieldToBoolean(this.RawRow["Friday"]).Value; }
            set { this.RawRow["Friday"] = BooleanToField(value);      }
        }

        /// <summary>Gets or sets a value indicating whether shifts operates on Saturday</summary>
        public bool Saturday
        {
            get { return FieldToBoolean(this.RawRow["Saturday"]).Value; }
            set { this.RawRow["Saturday"] = BooleanToField(value);      }
        }

        /// <summary>Gets or sets a value indicating whether shifts has been deleted</summary>
        public bool Deleted
        {
            get { return FieldToBoolean(this.RawRow["_Deleted"]).Value; }
            set { this.RawRow["_Deleted"] = BooleanToField(value);      }
        }

        /// <summary>Returns if shift is enabled for this day in the weel</summary>
        /// <param name="dayOfWeek">day of week to test</param>
        /// <returns>If enabled</returns>
        public bool EnabledForDay(DayOfWeek dayOfWeek)
        {
            switch (dayOfWeek)
            {
            case DayOfWeek.Sunday:   return this.Sunday;
            case DayOfWeek.Monday:   return this.Monday;
            case DayOfWeek.Tuesday:  return this.Tuesday;
            case DayOfWeek.Wednesday:return this.Wednesday;
            case DayOfWeek.Thursday: return this.Thursday;
            case DayOfWeek.Friday:   return this.Friday;
            case DayOfWeek.Saturday: return this.Saturday;
            }

            return false;
        }

        /// <summary>
        /// Calculates manufacture start time of the shift for this day
        ///     date + start time of shift
        /// </summary>
        /// <param name="date">Date of shift</param>
        /// <returns>manufacture start time of the shift for this day</returns>
        public DateTime CalculateManufactureDate(DateTime date)
        {
            return date.ToStartOfDay() + this.StartTime;
        }

        /// <summary>Returns description of shift</summary>
        /// <returns>The <see cref="string"/></returns>
        public override string ToString()
        {
            return this.Description;
        }

        /// <summary>Returns detailed string of the shift
        /// e.g. Night Shift 20:00 to 07:00 Mon to Fri
        /// </summary>
        /// <returns>detailed string of the shift</returns>
        public string ToDetailString()
        {
            // Main detials
            StringBuilder str = new StringBuilder();
            str.AppendFormat("{0} {1} to {2}", this.Description, this.StartTime.ToString(@"hh\:mm"), this.EndTime.ToString(@"hh\:mm"));

            // Add days that this will occur
            DayOfWeek last = DayOfWeek.Saturday;
            for (DayOfWeek current = DayOfWeek.Sunday; current <= DayOfWeek.Saturday; current++)
            {
                // find day shift occurs on
                if (!this.EnabledForDay(current))
                {
                    continue;
                }

                // Add day to string
                str.Append(" ");
                str.Append(current.ToString().Substring(0, 3));
                last = current;

                // Check if we have a run of days
                for (current++; this.EnabledForDay(current); current++) 
                {
                }

                // if run then save as run
                if (last != current - 1)
                {
                    str.Append(" to ");
                    str.Append((current - 1).ToString().Substring(0, 3));
                }

                str.Append(",");
            }

            // Remove last comment
            if (str.Length > 0 && str[str.Length - 1] == ',')
            {
                str.Remove(str.Length - 1, 1);
            }

            return str.ToString();
        }
    }

    /// <summary>AMMShift table column info</summary>
    public class aMMShiftColumnInfo: BaseColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="aMMShiftColumnInfo"/> class.</summary>
        public aMMShiftColumnInfo() : base("aMMShift") { }

        /// <summary>Gets length of description field</summary>
        public int DescriptionLength { get { return this.FindColumnByName("Description").Length; } }
    }

    /// <summary>AMMShift table</summary>
    public class aMMShift : BaseTable2<aMMShiftRow,aMMShiftColumnInfo>
    {
        /// <summary>Initializes a new instance of the <see cref="aMMShift"/> class.</summary>
        public aMMShift() : base("aMMShift") { }

        /// <summary>Load all (for current site)</summary>
        public void LoadAll()
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SiteID", SessionInfo.SiteID);
            this.LoadBySP("pAMMShiftAll", parameters);
        }

        /// <summary>Load shift by ID</summary>
        /// <param name="aMMShiftId">Returns shift by Id</param>
        public void LoadById(int aMMShiftId)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("aMMShiftId", aMMShiftId);
            this.LoadBySP("pAMMShiftLoadByID", parameters);
        }

        /// <summary>
        /// Given a time and number of shifts will return end time of that shift
        /// Returns null if there are no shifts
        /// (note method is recursive)
        /// </summary>
        /// <param name="startDateTime">Starting time</param>
        /// <param name="shiftCount">Number of shits to iterate over</param>
        /// <returns>End time of the nth shift</returns>
        public static DateTime? CalculateTimeToEndOfNthShift(DateTime startDateTime, int shiftCount)
        {
            // Load all active shifts
            aMMShift shifts = new aMMShift();
            shifts.LoadAll();
            if (!shifts.Any())
                return null;

            DateTime currentDate = startDateTime.ToStartOfDay().AddDays(-1);
            
            while (shiftCount >= 0)
            {
                var eligableShifts = (from s in shifts.FindByDayOfWeek(currentDate.DayOfWeek)
                                      let endDateTime = s.CalculateEndDateForDay(currentDate)
                                      where startDateTime < endDateTime
                                      orderby endDateTime
                                      select endDateTime).ToList();
                
                if (shiftCount >= eligableShifts.Count)
                {
                    shiftCount -= eligableShifts.Count;
                    currentDate = currentDate.AddDays(1);
                }
                else
                    return eligableShifts.Skip(shiftCount).First();
            }

            return null;
        }

        /// <summary>Returns all active (non deleted) shifts</summary>
        /// <returns>Returns all shifts</returns>
        public static aMMShift GetAll()
        {
            aMMShift shift = new aMMShift();
            shift.LoadAll();
            return shift;
        }

        /// <summary>Returns the shift by Id</summary>
        /// <param name="aMMShiftId">shift Id</param>
        /// <returns>shift by Id</returns>
        public static aMMShiftRow GetById(int aMMShiftId)
        {
            aMMShift shift = new aMMShift();
            shift.LoadById(aMMShiftId);
            return shift.FirstOrDefault();
        }
    }

    /// <summary>Extension methods for IEnumeration{aMMShiftRow}</summary>
    public static class aMMShiftRowEnumerationExtension
    {
        /// <summary>Returns all shift on this day of week (will remove deleted items)</summary>
        /// <param name="list">shift list</param>
        /// <param name="day">Day of week</param>
        /// <returns>All shift for this day of week</returns>
        public static IEnumerable<aMMShiftRow> FindByDayOfWeek(this IEnumerable<aMMShiftRow> list, DayOfWeek day)
        {
            switch (day)
            {
            case DayOfWeek.Sunday:   return list.Where(d => d.Sunday    && !d.Deleted);
            case DayOfWeek.Monday:   return list.Where(d => d.Monday    && !d.Deleted);
            case DayOfWeek.Tuesday:  return list.Where(d => d.Tuesday   && !d.Deleted);
            case DayOfWeek.Wednesday:return list.Where(d => d.Wednesday && !d.Deleted);
            case DayOfWeek.Thursday: return list.Where(d => d.Thursday  && !d.Deleted);
            case DayOfWeek.Friday:   return list.Where(d => d.Friday    && !d.Deleted);
            case DayOfWeek.Saturday: return list.Where(d => d.Saturday  && !d.Deleted);
            default: return new List<aMMShiftRow>();
            }
        }

        /// <summary>
        /// Find first shift that occurs after dateTime for the
        /// Method will filter to correct day of week.
        /// So if no shifts on that day will then return null
        /// </summary>
        /// <param name="list">shift list</param>
        /// <param name="dateTime">Start point</param>
        /// <returns>Shift that returns after dateTime</returns>
        public static aMMShiftRow FindShiftForTime(this IEnumerable<aMMShiftRow> list, DateTime dateTime)
        {
            return list.FindByDayOfWeek(dateTime.DayOfWeek).Where(dt => dt.EndTime > dateTime.TimeOfDay).OrderBy(dt => dt.StartTime).FirstOrDefault();
        }
    }
}
