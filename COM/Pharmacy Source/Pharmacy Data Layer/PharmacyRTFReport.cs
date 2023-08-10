// -----------------------------------------------------------------------
// <copyright file="PharmacyRTFReport.cs" company="Emis Health Plc">
// Copyright Emis Health Plc
// </copyright>
// <summary>
// Provides access to PharmacyRTFReport table.
//
// You don't need to load tables directly from PharmacyRTFReport, just use 
// the static get method
//
// Usage
//
// To load the rtf
// rtf = PharmacyPharmacyRTFReport.GetRTFByNameandSiteID("DispLbl", 15);
//
// Modification History:
// 13Jun17 TH Created Written 174878

// </summary>
// -----------------------------------------------------------------------

namespace ascribe.pharmacy.pharmacydatalayer
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;
    using System.Data.SqlClient;
    using ascribe.pharmacy.reportlayer;


    /// <summary>Row in the PharmacyRTFReport table</summary>
    public class PharmacyRTFReportRow : BaseRow
    {
        public int PharmacyRTFReportID
        {
            get { return FieldToInt(RawRow["PharmacyRTFReportID"]).Value; }
        }

        public int LocationID_Site
        {
            get { return FieldToInt(RawRow["LocationID_Site"]).Value; }
            set { RawRow["LocationID_Site"] = IntToField(value); }
        }

        public string Name
        {
            get { return FieldToStr(RawRow["Name"], trimString: false, nullVal: string.Empty); }
            set { RawRow["Name"] = StrToField(value, emptyStrAsNullVal: true); }
        }

        public string Report
        {
            get { return FieldToStr(RawRow["Report"], trimString: false, nullVal: string.Empty); }
            set { RawRow["Report"] = StrToField(value, emptyStrAsNullVal: true); }
        }


        public DateTime Updated
        {
            get { return FieldToDateTime(RawRow["Updated"]).Value; }
            set { RawRow["Updated"] = DateTimeToField(value); }
        }
    }


    /// <summary>Table info for PharmacyRTFReport table</summary>
    public class PharmacyRTFReportColumnInfo : BaseColumnInfo
    {
        public PharmacyRTFReportColumnInfo() : base("PharmacyRTFReport") { }
        
    }


    /// <summary>Represent the PharmacyRTFReport table</summary>
    public class PharmacyRTFReport : BaseTable2<PharmacyRTFReportRow, PharmacyRTFReportColumnInfo>
    {
        public PharmacyRTFReport() : base("PharmacyRTFReport") { }

       

        /// <summary>
        /// Loads record from the PharmacyRTFReport table
        /// </summary>
        /// <param name="LocationID_site">SiteID</param>
        /// <param name="Name">Name of RTF Report</param>
       
        public void LoadRTFByNameandSiteID(string Name, int SiteID)
        {
             // Load the reprint
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("SessionID", SessionInfo.SessionID);
            parameters.Add("LocationID_Site", SiteID);
            parameters.Add("Name", Name);
            this.LoadBySP("pPharmacyRTFReportSelectbySiteandName", parameters);
           
        }

        /// <summary>Returns RTF by Name and site ID (returns null if no matches)</summary>
        public static PharmacyRTFReportRow GetByNameAndSiteID(string Name, int siteID)
        {
            PharmacyRTFReport RTFReport = new PharmacyRTFReport();
            RTFReport.LoadRTFByNameandSiteID(Name, siteID);
            return RTFReport.FirstOrDefault();
        }
 

    }


    /// <summary>PharmacyRTFReport enumeration extension methods</summary>
    public static class PharmacyRTFReportEnumerable
    {
    }

}
