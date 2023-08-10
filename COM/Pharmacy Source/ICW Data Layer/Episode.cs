//===========================================================================
//
//							Episode.cs
//
//  This class is a read only class for representing patient episodes
//
//	Modification History:
//	20May09 AKK  Written
//  03Sep10 XN   Added method GetEntityID (F0082255)
//  07Nov11 XN   Added method LoadByEpisodeID, and GetByEpisodeID, and moved 
//               to icwdatalayer
//  08Feb12 XN   Fixed problems converting EpisodeTypeID to enum EpisodeType
//  16Jan13 XN   Due to optimisation of pEpsiodeSelect removed EpisodeRow.EntityID_Consultant
//               and LoadByEpisodeID as should not be used here 48747
//  22Mar13 XN   43495 Added IsOneMMWard
//  29Mar16 XN   123082 Moved to basetable2 added GetSpecialty, and GetPaymentCategory
//  26Apr16 XN   123082 Added EnumDBCode to EpisodeType, cached Specialty, and PaymentCategory
//               Added ToXmlHeap
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web;
using System.Xml;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>
    /// Enumerator for the EpisodeType from the lookup table EpisodeType
    /// </summary>
    [EnumViaDBLookup(TableName = "EpisodeType", PKColumn = "EpisodeTypeID", DescriptionColumn = "Description")]
    public enum EpisodeType
    {
        [EnumDBCode("L")]
        LifetimeEpisode,

        [EnumDBCode("A")]
        Administration,

        [EnumDBCode("I")]
        [EnumDBDescription("In-patient")] 
        InPatient,

        [EnumDBCode("O")]
        [EnumDBDescription("Out-patient")] 
        OutPatient,

        [EnumDBCode("D")]
        Discharge,

        [EnumDBCode("L")]
        Leave,

        Spell
    }

    
    /// <summary>
    /// Represents a row in the Episode table
    /// </summary>
    public class EpisodeRow : BaseRow
    {
        public int EpisodeID { get { return FieldToInt(RawRow["EpisodeID"]).Value; } }
        public int EpisodeID_Parent { get { return FieldToInt(RawRow["EpisodeID_Parent"]).Value; } }
        public int StatusID { get { return FieldToInt(RawRow["StatusID"]).Value; } }
        public int EntityID { get { return FieldToInt(RawRow["EntityID"]).Value; } }
        public EpisodeType EpisodeType { get { return FieldToEnumViaDBLookup<EpisodeType>(RawRow["EpisodeTypeID"]).Value; } }
        public string EpisodeTypeStr { get { return FieldIntToLookupString(RawRow["EpisodeTypeID"], "EpisodeType", "EpisodeTypeID", "Description"); } }
        public string Description { get { return FieldToStr(RawRow["Description"]); } }
        public DateTime DateCreated { get { return FieldToDateTime(RawRow["DateCreated"]).Value; } }
        public DateTime StartDate { get { return FieldToDateTime(RawRow["StartDate"]).Value; } }
        public DateTime? EndDate { get { return FieldToDateTime(RawRow["EndDate"]); } }
        public string CaseNo { get { return FieldToStr(RawRow["CaseNo"]); } }
//        public int? EntityID_Consultant { get { return FieldToInt(RawRow["EntityID_Consultant"]); } }     // 16Jan13 XN  Removed due to optimisation of pEpsiodeSelect 48747

        /// <summary>Returns ward patient is on, or null if patient is not on a ward</summary>
        public WardRow GetWard()
        {
            Ward wards = new Ward();
            wards.LoadByEpisode(this.EpisodeID);
            return wards.FirstOrDefault();
        }

        /// <summary>Returns consultant dealing with patient, or null non assigned</summary>
        public ConsultantRow GetConsultant()
        {
            Consultant consultants = new Consultant();
            consultants.LoadByEpisode(this.EpisodeID);
            return consultants.FirstOrDefault();
        }

        /// <summary>
        /// Returns the episode's Specialty
        /// The value is original read from the db, and then cached with the row 29Mar16 XN 123082 
        /// </summary>
        /// <returns>Payment specialty</returns>
        public string GetSpecialty()
        {
            this.AddColumnIfNotExists("Specialty", typeof(string));

            if (this.RawRow["Specialty"] == DBNull.Value)
            {
                this.RawRow["Specialty"] = Database.ExecuteSQLScalar<string>("select icwsys.fSpecialtyByEpisodeID({0})", this.EpisodeID);
            }

            return FieldToStr(this.RawRow["Specialty"], trimString: true, nullVal: string.Empty);
        }

        /// <summary>
        /// Return the episode payment category
        /// The value is original read from the db, and then cached with the row 29Mar16 XN 123082 
        /// </summary>
        /// <returns>Payment category</returns>
        public string GetPaymentCategory()
        {
            this.AddColumnIfNotExists("PaymentCategory", typeof(string));

            if (this.RawRow["PaymentCategory"] == DBNull.Value)
            {
                this.RawRow["PaymentCategory"] = string.Format("Exec pGetPatientPaymentCategoryByEpisodeId {0}", this.EpisodeID);
            }

            return FieldToStr(this.RawRow["PaymentCategory"], trimString: true, nullVal: string.Empty);
        }

        /// <summary>
        /// Converts patient data to xml heap
        /// Replacement for vb6 function FillHeapPatientInfo (but also need Episode.ToXmlHeap())
        /// 29Mar16 XN 123082 Added
        /// </summary>
        /// <returns>Xml heap string</returns>
        public string ToXmlHeap()
        {
            string siteCondition = SessionInfo.HasSite ? string.Format("AND SiteID={0}", SessionInfo.SiteID) : string.Empty;
            string tempStr;
            double? tempDbl;

            // Setup xml writer 
            var settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("EpisodeID",        this.EpisodeID);
            parameters.Add("SiteID",           SessionInfo.SiteID);

            GenericTable2 episodeInfo = new GenericTable2();
            episodeInfo.LoadBySP("pEpisodeSelect", parameters);
            DataRow extraInfo = episodeInfo.First().RawRow;

            var ward = this.GetWard();
            var cons = this.GetConsultant();

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");
                tempStr = FieldToStr(extraInfo["EpisodeTypeCode"], trimString: true, nullVal: string.Empty);
                if ("IODL".Contains(tempStr.ToUpper()))
                    xmlWriter.WriteAttributeString("pStatus", tempStr);  // Only set if it is a valid type else will have been reselected at dispensing

                xmlWriter.WriteAttributeString("ward",                      FieldToStr(extraInfo["WardCode"],               trimString: true, nullVal: string.Empty)); // Used in manufacturing
                xmlWriter.WriteAttributeString("pWard",                     FieldToStr(extraInfo["WardCode"],               trimString: true, nullVal: string.Empty));
                xmlWriter.WriteAttributeString("pCons",                     FieldToStr(extraInfo["ConsultantCode"],         trimString: true, nullVal: string.Empty));
                xmlWriter.WriteAttributeString("pPatientPaymentCategory",   FieldToStr(extraInfo["PatientPaymentCategory"], trimString: true, nullVal: string.Empty));
                xmlWriter.WriteAttributeString("pWardExp",                  ward == null ? string.Empty : ward.Description);
                xmlWriter.WriteAttributeString("pConsExp",                  cons == null ? string.Empty : cons.Description);
                
                // Specialty
                string speciality = FieldToStr(extraInfo["Specialty"], trimString: true, nullVal: string.Empty);
                xmlWriter.WriteAttributeString("pSpeciality",       speciality);
                xmlWriter.WriteAttributeString("pSpecialty",        speciality);
                xmlWriter.WriteAttributeString("pEpisodeSpeciality",speciality);
                xmlWriter.WriteAttributeString("pEpisodeSpecialty", speciality);

                string specialityLookup = string.Empty;
                string editSpeciality   = (Database.ExecuteSQLScalar<string>("SELECT Value FROM WConfiguration WHERE [Key]='EditSpecialty' " + siteCondition + " AND Section='PID' AND Category='D|ASCribe' ORDER BY SiteID") ?? "0").Trim('"');
                if (BoolExtensions.PharmacyParseOrNull(editSpeciality) ?? false)
                {
                    specialityLookup = Database.ExecuteSQLScalar<string>("SELECT Value FROM WLookup l JOIN WLookupContext lc ON l.WLookupContextID = lc.WLookupContextID WHERE l.Code='{0}' AND l.siteID={1} AND lc.Context='speclty' AND l.InUse=1", speciality, SessionInfo.SiteID);
                    if (specialityLookup == null)
                        specialityLookup = (Database.ExecuteSQLScalar<int?>("SELECT TOP 1 1 FROM WLookup l JOIN WLookupContext lc ON l.WLookupContextID = lc.WLookupContextID WHERE l.siteID={0} AND lc.Context='speclty'", SessionInfo.SiteID) ?? 0) == 1 ? string.Empty : "<Invalid Code>";
                }
                xmlWriter.WriteAttributeString("pSpecialityExp",  specialityLookup);
                xmlWriter.WriteAttributeString("pSpecialtyExpHIL",HttpContext.Current.Server.UrlEncode(specialityLookup));

                // Height
                tempDbl = FieldToDouble(extraInfo["HeightM"]);
                xmlWriter.WriteAttributeString("pHeight",        tempDbl == null ? string.Empty : tempDbl.ToString("0.##"));
                xmlWriter.WriteAttributeString("pEpisodeHeight", tempDbl == null ? string.Empty : tempDbl.ToString("0.##"));
                if (tempDbl < 0)
                    tempDbl = null;
                else if (tempDbl < 10)
                    tempDbl = (2.54 * (12 * tempDbl));
                xmlWriter.WriteAttributeString("pHeightcm", tempDbl == null ? string.Empty : tempDbl.ToString("0.##"));

                // Weight
                tempDbl = FieldToDouble(extraInfo["WeightKg"]);
                xmlWriter.WriteAttributeString("pWeight",        tempDbl == null ? string.Empty : tempDbl.ToString("0.##"));
                xmlWriter.WriteAttributeString("pEpisodeWeight", tempDbl == null ? string.Empty : tempDbl.ToString("0.##"));

                // BSA
                xmlWriter.WriteAttributeString("pCalcSurfaceArea", FieldToStr(extraInfo["BSA"], trimString: true, nullVal: string.Empty));
                xmlWriter.WriteAttributeString("pSurfaceArea",     FieldToStr(extraInfo["BSA"], trimString: true, nullVal: string.Empty));

                // Question believe this is correct as not used in old world
                xmlWriter.WriteAttributeString("pGPexp",            string.Empty); 
                xmlWriter.WriteAttributeString("pEthnicOrigin",     string.Empty);
                xmlWriter.WriteAttributeString("pEthnicOriginExp",  string.Empty);
                xmlWriter.WriteAttributeString("pAliasSurname",     string.Empty);
                xmlWriter.WriteAttributeString("pAliasForename",    string.Empty);
                xmlWriter.WriteAttributeString("pFlag",             string.Empty);
                xmlWriter.WriteAttributeString("pEpisodePatFlag",   string.Empty);
                xmlWriter.WriteAttributeString("pCreatedDate",      string.Empty);
                xmlWriter.WriteAttributeString("pCreatedUserID",    string.Empty);
                xmlWriter.WriteAttributeString("pCreatedTerminal",  string.Empty);
                xmlWriter.WriteAttributeString("pUpdatedDate",      string.Empty);
                xmlWriter.WriteAttributeString("pUpdatedUserID",    string.Empty);
                xmlWriter.WriteAttributeString("pUpdatedTerminal",  string.Empty);
                xmlWriter.WriteAttributeString("pAllergy",          string.Empty);
                xmlWriter.WriteAttributeString("pDiagCodes",        string.Empty);
                xmlWriter.WriteAttributeString("pEpisodeClass",     string.Empty);
                xmlWriter.WriteAttributeString("pEpisodeNum",       string.Empty);
                xmlWriter.WriteAttributeString("pEpisodeActive",    string.Empty);
                xmlWriter.WriteAttributeString("pFacilityID",       string.Empty);
                xmlWriter.WriteAttributeString("pEpisodeWard",      string.Empty);
                xmlWriter.WriteAttributeString("pEpisodeRoom",      string.Empty);
                xmlWriter.WriteAttributeString("pEpisodeBed",       string.Empty);
                xmlWriter.WriteAttributeString("pAttendingDr",      string.Empty);
                xmlWriter.WriteAttributeString("pAdmitDate",        string.Empty);
                xmlWriter.WriteAttributeString("pAdmitTime",        string.Empty);
                xmlWriter.WriteAttributeString("pDischDate",        string.Empty);
                xmlWriter.WriteAttributeString("pDischTime",        string.Empty);
                xmlWriter.WriteAttributeString("pEpisodeCons",      string.Empty);
                xmlWriter.WriteAttributeString("pEpisodeStatus",    string.Empty);
                xmlWriter.WriteAttributeString("pEpisodeDiagCodes", string.Empty);
                xmlWriter.WriteEndElement();

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }
    }

    /// <summary>Represents the Episode table column info</summary>
    public class EpisodeColumnInfo : BaseColumnInfo
    {
        public EpisodeColumnInfo() : base("Episode") { }
    }

    /// <summary>Represents the Episode table</summary>
    public class Episode : BaseTable2<EpisodeRow, EpisodeColumnInfo>
    {
        public Episode() : base("Episode") { }

        /// <summary>
        /// Loads all episodes for the specified EntityID
        /// </summary>
        /// <param name="entityID">EntityID to be used to matched against episodes</param>
        public void LoadByEntityID(int entityID)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("EntityID",         entityID);
            LoadBySP("pEpisodeByEntityID", parameters);
        }

        /// <summary>Loads the specific episode</summary>
        public void LoadByEpisodeID(int episodeID, bool append = false)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("EpisodeID", episodeID);
            LoadBySP(append, "pEpisodeByEpisodeID", parameters);
        }

        /// <summary>
        /// Returns patients entity ID, given an episode ID
        /// </summary>
        /// <param name="episodeID">patients Episode ID</param>
        /// <returns>Entity ID</returns>
        static public int GetEntityID(int episodeID)
        {
            var parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("EpisodeID",        episodeID);
            return Database.ExecuteSPReturnValue<int>("pEntityIDFromEpisode", parameters);
        }

        /// <summary>Returns the selected episode (or null if episode does not exist</summary>
        static public EpisodeRow GetByEpisodeID(int episodeID)
        {
            Episode episode = new Episode();
            episode.LoadByEpisodeID(episodeID);
            return episode.Any() ? episode[0] : null; 
        }

        /// <summary>Returns if episode is on emm ward 22Mar13 XN 43495</summary>
        /// <param name="episodeID">Episode ID</param>
        /// <returns>If on emm ward</returns>
        static public bool IsOneMMWard(int episodeID)
        {
            return Database.ExecuteSQLScalar<int>("select icwsys.fPatientIsOneMMWard({0}, {1})", SessionInfo.SessionID, episodeID) == 1;
        }
    }
}

