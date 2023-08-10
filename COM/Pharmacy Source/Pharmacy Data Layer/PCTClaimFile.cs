//===========================================================================
//
//							PCTClaimFile.cs
//
//  This class is a data layer representation of the PCT Claim File
//
//	Modification History:
//	05Dec11 AJK  Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.pharmacydatalayer
{

    /// <summary>
    /// Represents a row in the PCTClaimFileRow table
    /// </summary>
    public class PCTClaimFileRow : BaseRow
    {
        public int PCTClaimFileID
        {
            get { return FieldToInt(RawRow["PCTClaimFileID"]).Value; }
        }

        public string DataSpecificationRelease
        {
            get { return FieldToStr(RawRow["DataSpecificationRelease"]); }
            set { RawRow["DataSpecificationRelease"] = StrToField(value); }
        }

        public string SLANumber
        {
            get { return FieldToStr(RawRow["SLANumber"]); }
            set { RawRow["SLANumber"] = StrToField(value); }
        }

        public DateTime? Generated
        {
            get { return FieldToDateTime(RawRow["Generated"]); }
            set { RawRow["Generated"] = DateTimeToField(value); }
        }

        public string System
        {
            get { return FieldToStr(RawRow["System"]); }
            set { RawRow["System"] = StrToField(value); }
        }

        public string SystemVersion
        {
            get { return FieldToStr(RawRow["SystemVersion"]); }
            set { RawRow["SystemVersion"] = StrToField(value); }
        }
        
        public DateTime? ScheduleDate
        {
            get { return FieldToDateTime(RawRow["ScheduleDate"]); }
            set { RawRow["ScheduleDate"] = DateTimeToField(value); }
        }

        public DateTime ClaimDate
        {
            get { return FieldToDateTime(RawRow["ClaimDate"]).Value; }
            set { RawRow["ClaimDate"] = DateTimeToField(value); }
        }

        public int? FileID
        {
            get { return FieldToInt(RawRow["FileID"]); }
            set { RawRow["FileID"] = IntToField(value); }
        }

        public int SiteID
        {
            get { return FieldToInt(RawRow["SiteID"]).Value; }
            set { RawRow["SiteID"] = IntToField(value); }
        }
    }

    /// <summary>
    /// Column information for the PCTClaimFile table
    /// </summary>
    public class PCTClaimFileColumnInfo : BaseColumnInfo
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public PCTClaimFileColumnInfo() : base("PCTClaimFile") { }
    }

    /// <summary>
    /// Represents the PCTClaimFile table
    /// </summary>
    public class PCTClaimFile : BaseTable<PCTClaimFileRow, PCTClaimFileColumnInfo>
    {
        /// <summary>
        /// Constructor
        /// </summary>
        public PCTClaimFile()
            : base("PCTClaimFile", "PCTClaimFileID")
        {
            UpdateSP = "pPCTClaimFileUpdate";
        }

        /// <summary>
        /// Constructor with rowlocking option
        /// </summary>
        /// <param name="rowLocking">Lock rows</param>
        public PCTClaimFile(RowLocking rowLocking)
            : base("PCTClaimFile", "PCTClaimFileID", rowLocking)
        {
            UpdateSP = "pPCTClaimFileUpdate";
        }

        /// <summary>
        /// Load mechanism by PCTClaimFileID
        /// </summary>
        /// <param name="PCTClaimFileID">PCTClaimFileID of the required PCTClaimFile to be loaded</param>
        public void LoadByPCTClaimFileID(int PCTClaimFileID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "PCTClaimFileID", PCTClaimFileID);
            LoadRecordSetStream("pPCTClaimFileByPCTClaimFileID", parameters);
        }

        ///// <summary>
        ///// Loads all PCTClaimFiles
        ///// </summary>
        //public void LoadAllClaimFiles()
        //{
        //    StringBuilder parameters = new StringBuilder();
        //    LoadRecordSetStream("pPCTClaimFileAll", parameters);
        //}

        /// <summary>
        /// Loads all open claims files by SiteID
        /// </summary>
        /// <param name="siteID">The SiteID for the required list of claim files</param>
        public void LoadAllOpenClaimFilesBySiteID(int siteID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "SiteID", siteID);
            LoadRecordSetStream("pPCTClaimFileAllOpenBySiteID", parameters);
        }

        /// <summary>
        /// Loads all submitted claim files by SiteID
        /// </summary>
        /// <param name="siteID">The SiteID for the required list of claim files</param>
        public void LoadAllSubmuttedClaimFilesBySiteID(int siteID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "SiteID", siteID);
            LoadRecordSetStream("pPCTClaimFileAllSubmittedBySiteID", parameters);
        }

        /// <summary>
        /// Loads a PCTClaimFile by ClaimDate and SiteID
        /// </summary>
        /// <param name="date"></param>
        public void LoadByClaimDate(DateTime date, int siteID)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "ClaimDate", date);
            AddInputParam(parameters, "SiteID", siteID);
            LoadRecordSetStream("pPCTClaimFileByClaimDateAndSiteID", parameters);
        }
    }
}
