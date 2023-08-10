//===========================================================================
//
//							Patient.cs
//
//  Provides readonly access to Patient table.
//
//  Class is derived from Person, then Entity
//
//  SP for this object should return all fields from the Person, and Entity tables 
//
//  Only supports reading.
//
//	Modification History:
//	20Dec11 XN  Written 
//  08Feb12 XN  Added method GetByEntityID
//  05Jul13 XN  Moved GetCaseNumberDisplayName, and GetNHSNumberDisplayName to 
//              PharmacyCultureInfo 27252
//  22Aug14 XN  Converted LoadByEntityID to non XML version as XML comes back different on some live servers
//  24Sep15 XN  Moved alias methods from SiteProductData to BaseTable2 77778
//  03Oct15 XN  Added LoadByEpisodeId, and GetByEpisodeId 133949
//  16Apr16 XN  Cached CaseNumber, and NHS Number, added ToXmlHeap, GetAgeString 123082
//===========================================================================
using System;
using System.Linq;
using System.Text;
using System.Xml;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Represents a record in the Patient, Person, and Entity tables</summary>
    public class PatientRow : PersonRow
    {
        public int        GenderID  { get { return FieldToInt (RawRow["GenderID"]).Value; } }
        public GenderType Gender    { get { return EnumViaDBLookupAttribute.ToEnum<GenderType>(GenderID); } }
        public DateTime?  DOB       { get { return (RawRow.Table.Columns.Contains("DOB") ? FieldToDateTime(RawRow["DOB" ]) : null); } } // DOB column may not exists if using XML load method

        /// <summary>
        /// Returns the patient's CaseNumber
        /// The value is original read from the db, and then cached with the row 16Apr16 XN 123082
        /// </summary>
        public string GetCaseNumber()
        {
            this.AddColumnIfNotExists("CaseNumber", typeof(string));

            if (this.RawRow["CaseNumber"] == DBNull.Value)
            {
                string sql = string.Format("Exec pGetPatientCaseNumber {0}, {1}", SessionInfo.SessionID, this.EntityID);
                this.RawRow["CaseNumber"] = Database.ExecuteSQLScalar<string>(sql);
            }

            return FieldToStr(this.RawRow["CaseNumber"], trimString: true, nullVal: string.Empty);
        }

        //  05Jul13 XN  Moved to PharmacyCultureInfo 27252
        ///// <summary>
        ///// Returns the patient's CaseNumber display name
        ///// This is the name that the hospital gives the case number (e.g. 'Hospital Number')
        ///// </summary>
        //public string GetCaseNumberDisplayName()
        //{
        //    string sql = string.Format("Exec pGetPatientCaseNumberDisplayName {0}", SessionInfo.SessionID);
        //    return Database.ExecuteSQLScalar<string>(sql);
        //}

        /// <summary>
        /// Returns the patient's NHS Number (with VALID or INVALID text after the number)
        /// The value is original read from the db, and then cached with the row 16Apr16 XN 123082
        /// </summary>
        public string GetNHSNumber()
        {
            this.AddColumnIfNotExists("NHSNumber", typeof(string));

            if (this.RawRow["NHSNumber"] == DBNull.Value)
            {
                string sql = string.Format("Exec pGetPatientNHSNumber {0}, {1}", SessionInfo.SessionID, this.EntityID);
                this.RawRow["NHSNumber"] = Database.ExecuteSQLScalar<string>(sql);
            }

            return FieldToStr(this.RawRow["NHSNumber"], trimString: true, nullVal: string.Empty);
        }

        //  05Jul13 XN  Moved to PharmacyCultureInfo 27252
        ///// <summary>
        ///// Returns the patient's NHS Number dsiplay name
        ///// Normaly for other contries (or even scotland) where they use something else rather than NHS Number
        ///// </summary>
        //public string GetNHSNumberDisplayName()
        //{
        //    string sql = string.Format("Exec pGetPatientNHSNumberDisplayName {0}", SessionInfo.SessionID);
        //    return Database.ExecuteSQLScalar<string>(sql);
        //}

        /// <summary>
        /// Converts patient data to xml heap
        /// Replacement for vb6 function FillHeapPatientInfo (but also need Episode.ToXmlHeap())
        /// 16Apr16 XN 123082
        /// </summary>
        /// <returns>Xml heap string</returns>
        public string ToXmlHeap()
        {
            string siteCondition = SessionInfo.HasSite ? string.Format("AND SiteID={0}", SessionInfo.SiteID) : string.Empty;
            string value;


            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");

                // Identifier
                xmlWriter.WriteAttributeString("pIntRecNo", this.EntityID.ToString());
                xmlWriter.WriteAttributeString("pCaseNo", this.GetCaseNumber());

                // Name 
                string name, shortname, forename, surname;
                BuildName(out name, out shortname, out forename, out surname);
                xmlWriter.WriteAttributeString("pTitle", this.Title);
                xmlWriter.WriteAttributeString("pForenameSurname", name);
                xmlWriter.WriteAttributeString("pInitialsSurname", shortname);
                xmlWriter.WriteAttributeString("pName", shortname);
                xmlWriter.WriteAttributeString("pfName", forename);
                xmlWriter.WriteAttributeString("psName", surname);
                xmlWriter.WriteAttributeString("pSurname", this.Surname);
                xmlWriter.WriteAttributeString("pForename", this.Forename);
                xmlWriter.WriteAttributeString("patientdetails", name + " " + this.GetCaseNumber());    // from formual.bas ParseFormulaData

                // gender
                switch (this.Gender)
                {
                case GenderType.Male:   xmlWriter.WriteAttributeString("pSex", "M"); break;
                case GenderType.Female: xmlWriter.WriteAttributeString("pSex", "F"); break;
                default: xmlWriter.WriteAttributeString("pSex", string.Empty); break;
                }

                // DOB
                xmlWriter.WriteAttributeString("pDOBRaw", this.DOB == null ? string.Empty : this.DOB.Value.ToString("ddMMyyyy"));
                xmlWriter.WriteAttributeString("pDOB",    this.DOB.ToPharmacyDateString());
                try
                {
                    string patientPrintHeapDobFormat = (Database.ExecuteSQLScalar<string>("SELECT Value FROM WConfiguration WHERE [Key]='PatientPrintHeapDOBFormat' " + siteCondition + " AND Section='' AND Category='D|patmed' ORDER BY SiteID") ?? "yyyyMMdd").Trim('"');
                    patientPrintHeapDobFormat = patientPrintHeapDobFormat.ToLower().Replace('c', 'y').Replace('m', 'M');
                    xmlWriter.WriteAttributeString("pDOBformatted", this.DOB == null ? string.Empty : this.DOB.Value.ToString(patientPrintHeapDobFormat));
                }
                catch (Exception)
                {
                    xmlWriter.WriteAttributeString("pDOBformatted", "DOB Error");
                }

                // Age
                string age = this.GetAgeString();
                xmlWriter.WriteAttributeString("pAge",        age);
                xmlWriter.WriteAttributeString("pAgeInYears", age.IndexOf("years") == -1 ? string.Empty : age.Split(new [] { "years" }, StringSplitOptions.None)[0].Trim());

                // NH number
                bool? isValid = null;
                string nhsNumber = this.GetNHSNumber();
                if (nhsNumber.ToUpper().Contains(" INVALID"))
                {
                    isValid = false;
                    nhsNumber = nhsNumber.Replace(" INVALID", string.Empty).Trim();
                }
                else if (nhsNumber.ToUpper().Contains("VALID"))
                {
                    isValid = true;
                    nhsNumber = nhsNumber.Replace(" VALID", string.Empty).Trim();
                }

                xmlWriter.WriteAttributeString("pNHnumber", nhsNumber);
                xmlWriter.WriteAttributeString("pNHnumValid", isValid == null ? string.Empty : isValid.ToString());

                try
                {
                    string displayNhsNumberOnPmrFormat = Database.ExecuteSQLScalar<string>("SELECT Value FROM WConfiguration WHERE [Key]='DisplayNHSNumberOnPMRFormat' " + siteCondition + " AND Section='' AND Category='D|patmed' ORDER BY SiteID").Trim('"');
                    xmlWriter.WriteAttributeString("pNHnumberFormatted", double.Parse(nhsNumber.Remove(c => c == ' ').Trim()).ToString(displayNhsNumberOnPmrFormat));
                }
                catch (Exception ex)
                {
                    xmlWriter.WriteAttributeString("pNHnumberFormatted", nhsNumber);
                }

                // Address
                AddressRow address = Address.GetByEntityAndType(this.EntityID, "Home");
                xmlWriter.WriteAttributeString("pAddress1", address == null ? string.Empty : (address.DoorNumber + " " + address.Building + " " + address.Street).Trim());
                xmlWriter.WriteAttributeString("pAddress2", address == null ? string.Empty : address.Town);
                xmlWriter.WriteAttributeString("pAddress3", address == null ? string.Empty : (address.LocalAuthority + " " + address.District).Trim());
                xmlWriter.WriteAttributeString("pAddress4", address == null ? string.Empty : (address.Province + " " + address.Country).Trim());
            
                xmlWriter.WriteAttributeString("pPostcode", address == null ? string.Empty : address.PostCode);
                xmlWriter.WriteEndElement();

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }

        /// <summary>
        /// Converts DOB to age to string 
        /// e.g.    5 years 2 months     
        ///         1 month 5 days
        /// VB6 replacement for WDATETIN.BAS agecalc
        /// 16Apr16 XN 123082
        /// </summary>
        /// <returns></returns>
        public string GetAgeString()
        {
            if (this.DOB == null)
            {
                return  string.Empty;
            }

            DateTime dt  = DateTime.Now.ToStartOfDay();
            DateTime dob = this.DOB.Value;
            string result = string.Empty;

            int days = dt.Day - dob.Day;
            if (days < 0)
            {
                dt = dt.AddMonths(-1);
                days += DateTime.DaysInMonth(dt.Year, dt.Month);
            }

            int months = dt.Month - dob.Month;
            if (months < 0)
            {
                dt = dt.AddYears(-1);
                months += 12;
            }

            int years = dt.Year - dob.Year;

            if (years > 0)
            {
                result = string.Format("{0} year{1} {2} month{3}", 
                                        years, 
                                        years > 1 ? "s" : string.Empty,
                                        months,
                                        months > 1 ? "s" : string.Empty);
            }
            else if (months > 2)
            {
                result = string.Format("{0} month{1} {2} day{3}",
                                        months, 
                                        months > 1 ? "s" : string.Empty,
                                        days,
                                        days > 1 ? "s" : string.Empty);
            }
            else
            {
                result = string.Format("{0} day{1}", days, days > 1 ? "s" : string.Empty);
            }

            return result;
        }

        /// <summary>
        /// Build up patients name using the standard pharmacy formating
        /// replacement for vb6 WIDENTSB.bas buildname
        /// 16Apr16 XN 123082
        /// </summary>
        /// <param name="name">Patient name formated</param>
        /// <param name="shortName">Patient initials and surname formated</param>
        /// <param name="forename">formatted forename</param>
        /// <param name="surname">formatted surname</param>
        /// <returns>Patient name</returns>
        private void BuildName(out string name, out string shortName, out string forename, out string surname)
        {
            string siteCondition = SessionInfo.HasSite ? string.Format("AND SiteID={0}", SessionInfo.SiteID) : string.Empty;
            string value; 

            // Get if surname, forename
            value = (Database.ExecuteSQLScalar<string>("SELECT Value FROM WConfiguration WHERE [Key]='SurnameForename' " + siteCondition + " AND Section='PID' AND Category='D|ASCRIBE' ORDER BY SiteID") ?? string.Empty).Trim('"');
            bool surenameForename = BoolExtensions.PharmacyParseOrNull(value) ?? false;

            // Get if commaSeparatedName
            value = (Database.ExecuteSQLScalar<string>("SELECT Value FROM WConfiguration WHERE [Key]='CommaSeparatedName' " + siteCondition + " AND Section='PID' AND Category='D|ASCRIBE' ORDER BY SiteID") ?? string.Empty).Trim('"');
            bool commaSeparatedName = BoolExtensions.PharmacyParseOrNull(value) ?? true;

            // Get if to set correct case
            value = (Database.ExecuteSQLScalar<string>("SELECT Value FROM WConfiguration WHERE [Key]='EnsureCasedLblNames' " + siteCondition + " AND Section='PID' AND Category='D|ASCRIBE' ORDER BY SiteID") ?? string.Empty).Trim('"');
            bool enusueCaseLblNames = BoolExtensions.PharmacyParseOrNull(value) ?? false;

            // Get casing rules
            value = (Database.ExecuteSQLScalar<string>("SELECT Value FROM WConfiguration WHERE [Key]='UpperCaseRule' " + siteCondition + " AND Section='PID' AND Category='D|ASCRIBE' ORDER BY SiteID") ?? string.Empty).Trim('"');
            bool upperCaseRule = BoolExtensions.PharmacyParseOrNull(value) ?? false;

            // Get "mc" rule
            value = (Database.ExecuteSQLScalar<string>("SELECT Value FROM WConfiguration WHERE [Key]='McRule' " + siteCondition + " AND Section='PID' AND Category='D|ASCRIBE' ORDER BY SiteID") ?? string.Empty).Trim('"');
            bool mcRule = BoolExtensions.PharmacyParseOrNull(value) ?? false;

            // get label name casing
            string LabelNameCasing = (Database.ExecuteSQLScalar<string>("SELECT Value FROM WConfiguration WHERE [Key]='LabelNameCasing' " + siteCondition + " AND Section='PID' AND Category='D|ASCRIBE' ORDER BY SiteID") ?? string.Empty).Trim('"');

            // Get initials of forename
            string initials = this.Forename.SafeSubstring(0, 1);
            int pos = this.Forename.IndexOf(' ');
            if (pos != -1)
            {
                initials += this.Forename.SafeSubstring(pos, 1);
            }

            if (upperCaseRule)
            {
                // New casing rule!!!!
                StringBuilder temp = new StringBuilder();
                bool uppercase = true;
                
                temp.Length = 0;
                foreach (var c in this.Forename.ToCharArray().ToList())
                {
                    temp.Append(uppercase ? Char.ToUpper(c) : Char.ToLower(c));
                    uppercase = !Char.IsUpper(c);
                }
                forename = temp.ToString();

                temp.Length = 0;
                foreach (var c in this.Surname.ToCharArray().ToList())
                {
                    temp.Append(uppercase ? Char.ToUpper(c) : Char.ToLower(c));
                    uppercase = !Char.IsUpper(c);
                }
                surname = temp.ToString();
            }
            else if (enusueCaseLblNames)
            {
                // Ensure first letters are upper case
                initials = initials.ToUpper();
                forename = this.Forename.ToLower().ToUpperFirstLetter();
                surname  = this.Surname.ToLower().ToUpperFirstLetter();
            }
            else
            {
                forename = this.Forename;
                surname  = this.Surname;                
            }

            // Apply the Mc rule
            if (mcRule)
            {                
                if (surname.StartsWith("mc", StringComparison.CurrentCultureIgnoreCase))
                {
                    surname = new StringBuilder(surname).Replace("mc", "Mc", 1).ToString();
                }

                // Secondary Mcs
                pos = surname.IndexOf(" mc", StringComparison.CurrentCultureIgnoreCase);
                if (pos > 3 && pos < 19)
                {
                    surname = new StringBuilder(surname).Replace(" mc", " Mc", 1).ToString();                        
                }

                pos = surname.IndexOf("-mc", StringComparison.CurrentCultureIgnoreCase);
                if (pos > 3 && pos < 19)
                {
                    surname = new StringBuilder(surname).Replace("-mc", " -Mc", 1).ToString();                        
                }
            }
            
            // If asking for shortname, then use initialise if total length is > 24
            string shortForename = ((forename + " " + surname).Trim().Length > 24) ? initials : forename;

            // apply casing rule
            switch (LabelNameCasing.ToLower())
            {
            case "lcfnamelcsname": break; // This is standard from the settings above.
            case "lcfnameucsname": 
                surname = surname.ToUpper();
                break;            
            case "ucfnameucsname":
                surname = surname.ToUpper();
                forename = forename.ToUpper();
                shortForename = shortForename.ToUpper();
                break;            
            case "ucfnamelcsname":
                forename = forename.ToUpper();
                shortForename = shortForename.ToUpper();
                break;  
            case "lcallfnameucsname":
                surname = surname.ToUpper();
                forename = forename.ToLower();
                shortForename = shortForename.ToLower();
                break;            
            case "lcallfnamelcsname":
                forename = forename.ToLower();
                shortForename = shortForename.ToLower();
                break;            
            case "lcfnamelcallsname":
                surname = surname.ToLower();
                break;            
            case "ucfnamelcallsname":
                forename = forename.ToUpper();
                surname = surname.ToLower();
                shortForename = shortForename.ToUpper();
                break;            
            case "lcallfnamelcallsname":
                forename = forename.ToLower();
                surname = surname.ToLower();
                shortForename = shortForename.ToLower();
                break;            
            }

            // set requested correct order
            string result;
            if (!surenameForename)
            {
                name = forename + " " + surname;
                shortName = shortForename + " " + surname;
            }
            else 
            {
                name      = String.IsNullOrEmpty(forename)      || !commaSeparatedName ? surname + forename      : surname + ", " + forename;
                shortName = String.IsNullOrEmpty(shortForename) || !commaSeparatedName ? surname + shortForename : surname + ", " + shortForename;
            }

            name = name.Trim();
            shortName = shortName.Trim();
        }
    }

    /// <summary>Column info class for Patient 24Sep15 XN 77778</summary>
    public class PatientColumnInfo : PersonColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="PatientColumnInfo"/> class.</summary>
        public PatientColumnInfo() : base("Patient") { }

        /// <summary>Initializes a new instance of the <see cref="PatientColumnInfo"/> class.</summary>
        /// <param name="inheritiedTableName">Parent table name</param>
        public PatientColumnInfo(string inheritiedTableName) : base(inheritiedTableName) { }
    }

    /// <summary>Represent the Patient, Person, and Entity table</summary>
    // public class Patient : BaseTable2<PatientRow, PatientColumnInfo> 24Sep15 XN 77778 added proper column info class
    public class Patient : BaseTable2<PatientRow, PatientColumnInfo>
    {
        /// <summary>Initializes a new instance of the <see cref="Patient"/> class.</summary>
        public Patient() : base("Patient", "Person", "Entity") { }
        // public Patient() : base("Patient") { }   24Sep15 XN 77778 added proper table list

        /// <summary>Loads the patient</summary>
        public void LoadByEntityID(int entityID, bool append = false)
        {
            //LoadFromXMLString("Exec pPatientXML @CurrentSessionID={0}, @EntityID={1}", SessionInfo.SessionID, entityID); 22Aug14 XN
            LoadBySQL(append, "Exec pPatientForPharmacy @CurrentSessionID={0}, @EntityID={1}", SessionInfo.SessionID, entityID);
        }

        /// <summary>Loads the patient 03Oct15 XN 133949</summary>
        public void LoadByEpisodeId(int episodeId)
        {
            LoadBySQL("Exec pPatientForPharmacyByEpisodeId @CurrentSessionID={0}, @EpisodeID={1}", SessionInfo.SessionID, episodeId);
        }

        /// <summary>Returns patient with specified id or null if invalid id</summary>
        public static PatientRow GetByEntityID(int entityID)
        {
            Patient patient = new Patient();
            patient.LoadByEntityID(entityID);
            return patient.Any() ? patient[0] : null;
        }
        
        /// <summary>Returns patient with specified id or null if invalid id 03Oct15 XN 133949</summary>
        /// <param name="episodeId">episode id</param>
        /// <returns>patient or null</returns>
        public static PatientRow GetByEpisodeId(int episodeId)
        {
            Patient patient = new Patient();
            patient.LoadByEpisodeId(episodeId);
            return patient.FirstOrDefault();
        }
    }
}
