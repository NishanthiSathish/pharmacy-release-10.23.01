//===========================================================================
//
//							PCTClaimFile.cs
//
//  This class holds all business logic for handling a PCT claim file
//  object.
//
//	Modification History:
//	09Dec11 AK  Written
//===========================================================================
using System;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.pharmacydatalayer;
using System.Collections.Generic;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.businesslayer
{
    /// <summary>
    /// Represents a PCT Claim File
    /// </summary>
    public class PCTClaimFileLine : IBusinessObject
    {
        public int PCTClaimFileID { get; internal set; }
        public string DataSpecificationRelease { get; set; }
        public string SLANumber { get; set; }
        public DateTime? Generated { get; set; }
        public string System { get; set; }
        public string SystemVersion { get; set; }
        public DateTime? ScheduleDate { get; set; }
        public DateTime ClaimDate { get; set; }
        public int? FileID { get; set; }
    }

    /// <summary>
    /// Processes PCT Claim File
    /// </summary>
    public class PCTClaimFileProcessor : BusinessProcess
    {
        /// <summary>
        /// Updates a PCT Claim File object
        /// </summary>
        /// <param name="claimFile">PCTClaimFileLine object to update</param>
        public void Update(PCTClaimFileLine claimFile)
        {
            using (PCTClaimFile dbClaimFile = new PCTClaimFile())
            {
                if (claimFile.PCTClaimFileID == 0)
                {
                    dbClaimFile.Add();
                }
                else
                {
                    dbClaimFile.LoadByPCTClaimFileID(claimFile.PCTClaimFileID);
                }
                dbClaimFile[0].ClaimDate = claimFile.ClaimDate;
                dbClaimFile[0].DataSpecificationRelease = claimFile.DataSpecificationRelease;
                dbClaimFile[0].Generated = claimFile.Generated;
                dbClaimFile[0].ScheduleDate = claimFile.ScheduleDate;
                dbClaimFile[0].SLANumber = claimFile.SLANumber;
                dbClaimFile[0].System = claimFile.System;
                dbClaimFile[0].SystemVersion = claimFile.SystemVersion;
                dbClaimFile[0].FileID = claimFile.FileID;
                dbClaimFile.Save();
                claimFile.PCTClaimFileID = dbClaimFile[0].PCTClaimFileID;
            }
        }

        /// <summary>
        /// Validates a PCT Claim File object for update
        /// </summary>
        /// <param name="claimFile">PCTClaimFileLine object to be validated</param>
        public void ValidateForUpdate(PCTClaimFileLine claimFile)
        {
            string keyName = "PCTClaimFileID";
            string keyValue = claimFile.PCTClaimFileID.ToString();

            //if (string.IsNullOrEmpty(claimFile.DataSpecificationRelease))
            //{
            //    ValidationErrors.Add(new ValidationError(this, "DataSpecificationRelease", keyName, keyValue, ValidationError.PropertyNameTag + " is required", true));
            //}

            //if (string.IsNullOrEmpty(claimFile.SLANumber))
            //{
            //    ValidationErrors.Add(new ValidationError(this, "SLANumber", keyName, keyValue, ValidationError.PropertyNameTag + " is required", true));
            //}

            //if (claimFile.System == null)
            //{
            //    ValidationErrors.Add(new ValidationError(this, "System", keyName, keyValue, ValidationError.PropertyNameTag + " is required", true));
            //}

            //if (claimFile.SystemVersion == null)
            //{
            //    ValidationErrors.Add(new ValidationError(this, "SystemVersion", keyName, keyValue, ValidationError.PropertyNameTag + " is required", true));
            //}
        }

        /// <summary>
        /// Loads a PCT Claim File by PCTClaimFileID
        /// </summary>
        /// <param name="pctClaimFileID">The primary key of the record</param>
        /// <returns>A PCTClaimFileLine object</returns>
        public PCTClaimFileLine LoadByPCTClaimFileID(int pctClaimFileID)
        {
            using (PCTClaimFile dbClaimFile = new PCTClaimFile())
            {
                dbClaimFile.LoadByPCTClaimFileID(pctClaimFileID);
                if (dbClaimFile.Count == 0)
                    throw new ApplicationException(string.Format("PCTClaimFile not found (PCTClaimFileID={0})", pctClaimFileID));
                return FillData(dbClaimFile[0]);
            }
        }

        ///// <summary>
        ///// Loads all PCTClaimFiles
        ///// </summary>
        ///// <returns>A list of PCTClaimFile objects</returns>
        //public List<PCTClaimFileLine> LoadAll()
        //{
        //    using (PCTClaimFile dbClaimFile = new PCTClaimFile())
        //    {
        //        List<PCTClaimFileLine> files = new List<PCTClaimFileLine>();
        //        dbClaimFile.LoadAllClaimFiles();
        //        for (int i = 0; i < dbClaimFile.Count; i++)
        //        {
        //            files.Add(FillData(dbClaimFile[i]));
        //        }
        //        return files;                
        //    }
        //}

        /// <summary>
        /// Loads all open claim files for a given site
        /// </summary>
        /// <returns>List of open PCTClaimFile objects</returns>
        /// <param name="siteID">The SiteID for the required list of claim files</param>
        public List<PCTClaimFileLine> LoadAllOpen(int siteID)
        {
            using (PCTClaimFile dbClaimFile = new PCTClaimFile())
            {
                List<PCTClaimFileLine> files = new List<PCTClaimFileLine>();
                dbClaimFile.LoadAllOpenClaimFilesBySiteID(siteID);
                for (int i = 0; i < dbClaimFile.Count; i++)
                {
                    files.Add(FillData(dbClaimFile[i]));
                }
                return files;
            }
        }

        /// <summary>
        /// Loads all submitted claim files for a given site
        /// </summary>
        /// <returns>List of submitted PCTClaimFile objects</returns>
        /// <param name="siteID">The SiteID for the required list of claim files</param>
        public List<PCTClaimFileLine> LoadAllSubmitted(int siteID)
        {
            using (PCTClaimFile dbClaimFile = new PCTClaimFile())
            {
                List<PCTClaimFileLine> files = new List<PCTClaimFileLine>();
                dbClaimFile.LoadAllSubmuttedClaimFilesBySiteID(siteID);
                for (int i = 0; i < dbClaimFile.Count; i++)
                {
                    files.Add(FillData(dbClaimFile[i]));
                }
                return files;
            }
        }

        /// <summary>
        /// Returns a PCTClaimFile object for the requested end date. A record will be created if it does not already exists.
        /// </summary>
        /// <param name="date">The claim date which the claim file record is required for</param>
        /// <param name="siteID">The SiteID of the required claim file</param>
        /// <returns>A PCTClaimFile object</returns>
        public PCTClaimFileLine GetPCTClaimFileByClaimDate(DateTime date, int siteID)
        {
            PCTClaimFileLine claimFile = new PCTClaimFileLine();
            using (PCTClaimFile dbClaimFile = new PCTClaimFile())
            {
                dbClaimFile.LoadByClaimDate(date, siteID);
                if (dbClaimFile.Count == 0)
                {
                    dbClaimFile.Add();
                    dbClaimFile[0].ClaimDate = date;
                    dbClaimFile[0].SiteID = siteID;
                    dbClaimFile.Save();
                }
                claimFile = FillData(dbClaimFile[0]);
            }
            return claimFile;
        }

        /// <summary>
        /// Gets the oldest open claim file and creates one for the current claim period if none exist
        /// </summary>
        /// <param name="siteID">The SiteID for the requested claim file</param>
        /// <param name="submitting">Indicates that the oldest claim file is being submitted so we need the next one after</param>
        /// <returns>A claim file object</returns>
        public PCTClaimFileLine GetOldestOpenClaimFile(int siteID, bool submitting)
        {
            PCTClaimFileLine claimFile = new PCTClaimFileLine();
            using (PCTClaimFile dbClaimFile = new PCTClaimFile())
            {
                dbClaimFile.LoadAllOpenClaimFilesBySiteID(siteID);
                if (submitting)
                {
                    if (dbClaimFile.Count == 1)
                    {
                        dbClaimFile.Add();
                        dbClaimFile[1].ClaimDate = GetClaimEndDate(DateTime.Today);
                        dbClaimFile[1].SiteID = siteID;
                        dbClaimFile.Save();
                    }
                    claimFile = FillData(dbClaimFile[1]);
                }
                else
                {

                    if (dbClaimFile.Count == 0)
                    {
                        dbClaimFile.Add();
                        dbClaimFile[0].ClaimDate = GetClaimEndDate(DateTime.Today);
                        dbClaimFile[0].SiteID = siteID;
                        dbClaimFile.Save();
                    }
                    claimFile = FillData(dbClaimFile[0]);
                }
            }
            return claimFile;
        }

        /// <summary>
        /// Fills the PCTClaimFileLine object with the database object data
        /// </summary>
        /// <param name="dbClaimFileRow">The database object to use to populate</param>
        /// <returns>The filled PCTClaimFileLine object</returns>
        private PCTClaimFileLine FillData(PCTClaimFileRow dbClaimFileRow)
        {
            PCTClaimFileLine claimFile = new PCTClaimFileLine();
            claimFile.ClaimDate = dbClaimFileRow.ClaimDate;
            claimFile.DataSpecificationRelease = dbClaimFileRow.DataSpecificationRelease;
            claimFile.Generated = dbClaimFileRow.Generated;
            claimFile.PCTClaimFileID = dbClaimFileRow.PCTClaimFileID;
            claimFile.ScheduleDate = dbClaimFileRow.ScheduleDate;
            claimFile.SLANumber = dbClaimFileRow.SLANumber;
            claimFile.System = dbClaimFileRow.System;
            claimFile.SystemVersion = dbClaimFileRow.SystemVersion;
            claimFile.FileID = dbClaimFileRow.FileID;
            return claimFile;
        }

        /// <summary>
        /// Returns the start date of a claim period for the supplied date
        /// </summary>
        /// <param name="date">The claim date which the start date is required for</param>
        /// <returns>The start datetime of the claim period</returns>
        public static DateTime GetClaimStartDate(DateTime date)
        {
            DateTime returnDate = date.Date;
            if (returnDate.Day > 15)
            {
                //Make date 16th of the same month
                returnDate = returnDate.AddDays(0 - (returnDate.Day - 16));
            }
            else
            {
                //Make date 1st of the same month
                returnDate = returnDate.AddDays(0 - (returnDate.Day - 1));
            }
            //Reset time to 00:00:00
            returnDate = returnDate.AddHours(0 - returnDate.Hour);
            returnDate = returnDate.AddMinutes(0 - returnDate.Minute);
            returnDate = returnDate.AddSeconds(0 - returnDate.Second);
            return returnDate;
        }

        /// <summary>
        /// Returns the end data of a claim period for the supplied date
        /// </summary>
        /// <param name="date">The claim date the end date is required for</param>
        /// <returns>The end datetime of the claim period</returns>
        public static DateTime GetClaimEndDate(DateTime date)
        {
            DateTime returnDate = date.Date;
            if (returnDate.Day > 15)
            {
                //Goto last day of that month
                returnDate = returnDate.AddMonths(1);
                returnDate = returnDate.AddDays(0 - returnDate.Day);
            }
            else
            {
                //Make date 15th of that month
                returnDate = returnDate.AddDays(15 - returnDate.Day);
            }
            returnDate = returnDate.AddHours(23 - returnDate.Hour);
            returnDate = returnDate.AddMinutes(59 - returnDate.Minute);
            returnDate = returnDate.AddSeconds(59 - returnDate.Second);
            return returnDate;
        }
        
    }
}
