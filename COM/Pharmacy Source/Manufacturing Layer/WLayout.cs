// -----------------------------------------------------------------------
// <copyright file="WLayout.cs" company="Emis Health Plc">
// Copyright Emis Health Plc
// </copyright>
// <summary>
// Provides access to WLayout table.
//
// SPs for this object should return all fields from the WLayout table, and a 
// link to the following extra fields
//      Person.Initials  as Draft_Initials
//      Person.Initials  as Approved_Initials
//
// This is used in conjunction with WFormula to give the manufacturing worksheets
// to be used by a formula
//
// Modification History:
// 19Apr16 XN Created  
// </summary>
// -----------------------------------------------------------------------

namespace ascribe.pharmacy.manufacturinglayer
{
    using System;
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.IO;
    using System.Linq;
    using System.Text;
    using System.Xml;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.pharmacydatalayer;
    using ascribe.pharmacy.shared;

    /// <summary>Row in the WLayout table</summary>
    public class WLayoutRow : BaseRow
    {
        public int WLayoutID
        {
            get { return FieldToInt(RawRow["WLayoutID"]).Value; }
        }

        /// <summary>DB field LocationID_Site</summary>
        public int SiteId
        {
            get { return FieldToInt(RawRow["LocationID_Site"]).Value; }
            set { RawRow["LocationID_Site"] = IntToField(value);      }
        }

        public int PatientsPerSheet 
        {
            get { return FieldToInt(RawRow["PatientsPerSheet"]) ?? 1;   }
            set { RawRow["PatientsPerSheet"] = IntToField(value);       }
        }

        public string Layout 
        {
            get { return FieldToStr(RawRow["Layout"], trimString: true, nullVal: string.Empty ); }
            set { RawRow["Layout"] = StrToField(value, emptyStrAsNullVal: false);            	   }
        }

        public string LineText 
        {
            get { return FieldToStr(RawRow["LineText"], trimString: true, nullVal: string.Empty ); }
            set { RawRow["LineText"] = StrToField(value, emptyStrAsNullVal: false);            	   }
        }

        /// <summary>DB field IngLineText</summary>
        public string IngredientLineText 
        {
            get { return FieldToStr(RawRow["IngLineText"], trimString: true, nullVal: string.Empty ); }
            set { RawRow["IngLineText"] = StrToField(value, emptyStrAsNullVal: false);            	   }
        }

        public string Prescription 
        {
            get { return FieldToStr(RawRow["Prescription"], trimString: true, nullVal: string.Empty ); }
            set { RawRow["Prescription"] = StrToField(value, emptyStrAsNullVal: false);            	   }
        }

        public string Name 
        {
            get { return FieldToStr(RawRow["Name"], trimString: true, nullVal: string.Empty ); }
            set { RawRow["Name"] = StrToField(value, emptyStrAsNullVal: false);            	   }
        }

        /// <summary>formula state (DB field WManufacturingStatusID)</summary>
        public WManufacturingStatus Status
        {
            get { return FieldToEnumViaDBLookup<WManufacturingStatus>(this.RawRow["WManufacturingStatusID"]).Value; }
            set { this.RawRow["WManufacturingStatusID"] = EnumToFieldViaDBLookup<WManufacturingStatus>(value);      }
        }

        /// <summary>DB field EntityID_Drafted</summary>
        public int EntityIdDrafted
        {
            get { return FieldToInt(RawRow["EntityID_Drafted"]).Value; }
            set { RawRow["EntityID_Drafted"] = IntToField(value);      }
        }

        /// <summary>DB field EntityID_Approved</summary>
        public int EntityIdApproved
        {
            get { return FieldToInt(RawRow["EntityID_Approved"]).Value; }
            set { RawRow["EntityID_Approved"] = IntToField(value);      }
        }

        public DateTime? DateDrafted
        {
            get { return FieldToDateTime(RawRow["DateDrafted"]);  }
            set { RawRow["DateDrafted"] = DateTimeToField(value); }
        }

        public DateTime? DateApproved
        {
            get { return FieldToDateTime(RawRow["DateApproved"]);  }
            set { RawRow["DateApproved"] = DateTimeToField(value); }
        }

        /// <summary>data comes from db field Person.Initials</summary>
        public string DraftedInitials
        {
            get { return FieldToStr(this.RawRow["Draft_Initials"], trimString: true, nullVal: string.Empty); }
        }

        /// <summary>data comes from db field Person.Initials</summary>
        public string ApprovedInitials
        {
            get { return FieldToStr(this.RawRow["Approved_Initials"], trimString: true, nullVal: string.Empty); }
        }

        public int VersionNumber
        {
            get { return FieldToInt(RawRow["VersionNumber"]).Value; }
            set { RawRow["VersionNumber"] = IntToField(value);      }
        }


        /// <summary>
        /// Converts formula data to xml heap
        /// Replacement for vb6 function ParseFormulaData (but also need WLayout.ToXmlHeap())
        /// </summary>
        /// <returns>Xml heap string</returns>
        public string ToXmlHeap()
        {
            string siteCondition = SessionInfo.HasSite ? string.Format("AND SiteID={0}", SessionInfo.SiteID) : string.Empty;
            string tempStr;


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

                if (WConfiguration.LoadAndCache<bool>(this.SiteId, "D|patmed", string.Empty, "CIVAS2ndAuth", true, false))
                {
                    xmlWriter.WriteAttributeString("WorksheetVersion", this.VersionNumber.ToString());

                    xmlWriter.WriteAttributeString("WSavedby",    this.EntityIdDrafted  > 0 ? string.Format("Saved by {0} on {1}", this.DraftedInitials,  this.DateDrafted.ToPharmacyDateTimeString())  : string.Empty);
                    xmlWriter.WriteAttributeString("WApprovedby", this.EntityIdApproved > 0 ? string.Format("Approved by {0} on {1}", this.ApprovedInitials, this.DateApproved.ToPharmacyDateTimeString()) : string.Empty);
                }

                xmlWriter.WriteEndElement();

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }
    }

    /// <summary>Table info for WLayout table</summary>
    public class WLayoutColumnInfo : BaseColumnInfo
    {
        public WLayoutColumnInfo() : base("WLayout") { }

        public int LayoutLength              { get { return this.FindColumnByName("Layout").Length;       } }
        public int LineTextLength            { get { return this.FindColumnByName("LineText").Length;     } }
        public int IngredientLineTextLength  { get { return this.FindColumnByName("IngLineText").Length;  } }
        public int PrescriptionLength        { get { return this.FindColumnByName("Prescription").Length; } }
        public int NameLength                { get { return this.FindColumnByName("Name").Length;         } }
    }


    /// <summary>Represent the WLayout table</summary>
    public class WLayout : BaseTable2<WLayoutRow, WLayoutColumnInfo>
    {
        public WLayout() : base("WLayout") { }

        /// <summary>Loads approved layout by siteId, name, and approved</summary>
        /// <param name="siteId">site Id</param>
        /// <param name="name">layout name</param>
        void LoadBySiteNameAndApproved(int siteId, string name)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("LocationID_Site",  siteId);
            parameters.Add("Name",             name);
            this.LoadBySP("pWLayoutbySiteandName", parameters);
        }

        /// <summary>Returns first approved layout by site, and name</summary>
        /// <param name="siteId">site Id</param>
        /// <param name="name">layout name</param>
        /// <returns>layout row</returns>
        public static WLayoutRow GetBySiteNameAndApproved(int siteId, string name)
        {
            WLayout layout = new WLayout();
            layout.LoadBySiteNameAndApproved(siteId, name);
            return layout.FirstOrDefault();;
        }

        /// <summary>
        /// Returns the full path and file name of the workshhet
        ///     {dispdata drive}\WKSHEETS\{layout}
        /// </summary>
        /// <param name="siteId">site Id</param>
        /// <param name="name">layout name</param>
        /// <returns>layout row</returns>
        public static string GetFilenameBySiteNameAndApproved(int siteId, string name)
        {
            var layout = WLayout.GetBySiteNameAndApproved(siteId, name);
            return layout == null ? string.Empty : Path.Combine(SiteInfo.DispdataDRV(), "WKSHEETS", layout.Layout);
        }
    }

    /// <summary>WLayout enumeration extension methods</summary>
    public static class WLayoutEnumerable
    {
    }
}
