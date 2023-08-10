// -----------------------------------------------------------------------
// <copyright file="WFormula.cs" company="Ascribe">
//      Copyright Ascribe Ltd    
// </copyright>
// <summary>
// This class represents the WFormula table.  
//      Draft_Initials    comes from [Person] via EntityID_Drafted
//      Approved_Initials comes from [Person] via EntityID_Approved
//
// Modification History:
// 29May15 XN Created 39882
// 01Jun16 XN Removed Approved2 as does not exist in db 157114
// 02Aug16 XN 159413 Allowed setting NumberOfLabels, ExtraLabels for unit testing
// 25Aug16 XN 161234 Fixed issue with reading GetMethodFilename from worksheet folder
// </summary>
// -----------------------------------------------------------------------

namespace ascribe.pharmacy.manufacturinglayer
{
    using System;
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.Linq;

    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.pharmacydatalayer;
    using ascribe.pharmacy.shared;
    using System.Xml;
    using System.Text;
    using System.IO;
    
    /// <summary>State of the WFormual row</summary>
    [EnumViaDBLookup(TableName="WManufacturingStatus", PKColumn="WManufacturingStatusID", DescriptionColumn="Description")]
    public enum WManufacturingStatus
    {
        /// <summary>Draft stage</summary>
        Draft,

        /// <summary>Approved stage</summary>
        Approved,

        /// <summary>Archive stage</summary>
        Archive    
    }

    /// <summary>Civas ingredient type</summary>
    public enum CIVASIngredientType
    {
        /// <summary>Fixed volume ingredient</summary>
        [EnumDBCode("F", "X")]
        Fixed,

        /// <summary>Fixed batch</summary>
        [EnumDBCode("Z")]
        BatchFixed,

        /// <summary>To this volume</summary>
        [EnumDBCode("T")]
        To,

        /// <summary>Variable code</summary>
        [EnumDBCode("V", "Y")]
        Variable
    }

    /// <summary>WFormula table row</summary>
    public class WFormulaRow : BaseRow
    {
        /// <summary>Gets WFormulaID for table</summary>
        public int WFormulaID
        {
            get { return FieldToInt(this.RawRow["WFormulaID"]).Value; }
        }

        /// <summary>formula state (DB field WManufacturingStatusID)</summary>
        public WManufacturingStatus Status
        {
            get { return FieldToEnumViaDBLookup<WManufacturingStatus>(this.RawRow["WManufacturingStatusID"]) ?? WManufacturingStatus.Draft; }
        }

        /// <summary>Gets NSVCode for formula</summary>
        public string NSVCode
        {
            get { return FieldToStr(this.RawRow["NSVCode"], trimString: true, nullVal: string.Empty); }
        }

        /// <summary>DB field LocationID_Site</summary>
        public int SiteId
        {
            get { return FieldToInt(RawRow["LocationID_Site"]).Value; }
            set { RawRow["LocationID_Site"] = IntToField(value);      }
        }

        /// <summary>
        /// Gets code field (via 0 based index)
        /// Will either be NSVCode or partial code
        /// </summary>
        /// <param name="index">0 based index for the code</param>
        /// <returns>NSVCode or partial code</returns>
        public string Code(int index)
        {
            if (index < 0 || index >= WFormula.MaxIngredientCount)
            {
                throw new IndexOutOfRangeException("WFormula ingredient index should be 0 based max " + WFormula.MaxIngredientCount.ToString());
            }

            return FieldToStr(this.RawRow["Code" + (index + 1)], trimString: true, nullVal: string.Empty);
        }

        /// <summary>Gets qty field for ingredient</summary>
        /// <param name="index">0 based index for ingredient</param>
        /// <returns>qty for ingredient</returns>
        public double? Quantity(int index)
        {
            if (index < 0 || index >= WFormula.MaxIngredientCount)
            {
                throw new IndexOutOfRangeException("WFormula ingredient index should be 0 based max " + WFormula.MaxIngredientCount.ToString());
            }

            return FieldToDouble(this.RawRow["qty" + (index + 1)]);
        }

        /// <summary>Gets type field for ingredient</summary>
        /// <param name="index">0 based index for ingredient</param>
        /// <returns>type for ingredient</returns>
        public CIVASIngredientType IngredientType(int index)
        {
            if (index < 0 || index >= WFormula.MaxIngredientCount)
            {
                throw new IndexOutOfRangeException("WFormula ingredient index should be 0 based max " + WFormula.MaxIngredientCount.ToString());
            }

            return FieldToEnumByDBCode<CIVASIngredientType>(this.RawRow["type" + (index + 1)]);
        }

        /// <summary>Gets the layout names (index=0 is db field Layout index=1 is db field Layout2</summary>
        /// <returns>layouts from db</returns>
        public IEnumerable<string> Layout()
        {
            for (int i = 0; i < WFormula.MaxLayout; i++)
            {
                yield return FieldToStr(this.RawRow["Layout" + (i == 0 ? string.Empty : (i + 1).ToString())], trimString: true, nullVal: string.Empty);
            }
        }

        /// <summary>Returns the layout at the specified index or null if it does not exist</summary>
        /// <param name="index">0 based layout index</param>
        /// <returns>layout name</returns>
        public WLayoutRow GetLayout(int index)
        {
            string layout = this.Layout().ElementAt(index);
            return string.IsNullOrEmpty(layout) ? null : WLayout.GetBySiteNameAndApproved(this.SiteId, layout);
        }

        public string FinalLayout
        {
            get { return this.FieldToStr(this.RawRow["FinalLayout"]); }
        }

        /// <summary>
        /// Returns number of layouts are available for the formula
        /// This is count of Layout db fields that have a layout name (normally 1 or 2).
        /// </summary>
        /// <returns>Number of available layouts</returns>
        public int NumberOfLayoutsAvaiable()
        {
            return this.Layout().Count(l => !string.IsNullOrWhiteSpace(l));
        }

        /// <summary>
        /// Gets a value indicating whether formula is for DosingUnits (false if null)
        /// If true then this is patient specific manufacturing, false for batch
        /// </summary>
        public bool IsDosingUnits
        {
            get { return FieldToBoolean(this.RawRow["DosingUnits"], false).Value; }
        }

        /// <summary>
        /// Returns if formula is Patient Specific
        /// Identified by NSVCode being the patient identifier!!
        /// </summary>
        public bool IsPatientSpecificFormula()
        {
            return !PatternMatch.Validate(this.NSVCode, PatternMatch.NSVCodePattern);
        }

        /// <summary>
        /// Returns all ingredient NSVCodes (might be partial description) 
        /// Note index in the list does not match index of the ingredient in WFormula.
        /// </summary>
        /// <returns>ingredient NSVCodes</returns>
        public IEnumerable<string> GetIngredientNSVCodes()
        {
            List<string> nsvCodes = new List<string>();
            for (int i = 0; i < WFormula.MaxIngredientCount; i++)
            {
                string nsvcode = this.Code(i);
                if (!string.IsNullOrEmpty(nsvcode))
                {
                    nsvCodes.Add(nsvcode);
                }
            }

            return nsvCodes;
        }

        public string AuthorisedInitials
        {
            get { return FieldToStr(this.RawRow["Authorised"], trimString: true, nullVal: string.Empty); }
        }

        public DateTime? AuthorisedDate
        {
            get { return FieldToDateTime(this.RawRow["Authorised_Date"]); }
        }

        public int? DrafEntityId
        {
            get { return FieldToInt(this.RawRow["EntityID_Drafted"]); }
        }

        public string DraftInitials
        {
            get { return FieldToStr(this.RawRow["Draft_Initials"], trimString: true, nullVal: string.Empty); }
        }

        public DateTime? DraftDate
        {
            get { return FieldToDateTime(this.RawRow["DateDrafted"]); }
        }

        public int? ApprovedEntityId
        {
            get { return FieldToInt(this.RawRow["EntityID_Approved"]); }
        }

        public string ApprovedInitials
        {
            get { return FieldToStr(this.RawRow["Approved_Initials"], trimString: true, nullVal: string.Empty); }
        }

        public DateTime? ApprovedDate
        {
            get { return FieldToDateTime(this.RawRow["DateApproved"]); }
        }

        public string Label
        {
            get { return FieldToStr(this.RawRow["Label"], trimString: true, nullVal: string.Empty); }
        }

        public string Method
        {
            get { return FieldToStr(this.RawRow["Method"], trimString: true, nullVal: string.Empty); }
        }

        /// <summary>Returns the full path and name of the method file</summary>
        /// <returns>full path and name of method file</returns>
        public string GetMethodFilename()
        {
            //return string.IsNullOrEmpty(this.Method) ? string.Empty : Path.Combine(SiteInfo.DispdataDRV(), this.Method);        25Aug16 XN  161234   
            return string.IsNullOrEmpty(this.Method) ? string.Empty : Path.Combine(SiteInfo.DispdataDRV(), "WKSHEETS", this.Method);            
        }

        public int VersionNumber
        {
            get { return FieldToInt(this.RawRow["VersionNumber"]).Value; }
        }

        /// <summary>
        /// If product should go through the bond store
        /// Db field Bond_Issue
        /// </summary>
        public bool IfBondStore
        {
            get { return FieldToBoolean(this.RawRow["Bond_Issue"]) ?? false; }
            set { this.RawRow["Bond_Issue"] = BooleanToField(value);         }
        }

        /// <summary>
        /// Number of labels per a syringe
        /// DB field NumOfLabels
        /// </summary>
        public int NumberOfLabels
        {
            get { return FieldToInt(this.RawRow["NumOfLabels"]).Value; }
            set { this.RawRow["NumOfLabels"] = IntToField(value);      }    // 02Aug16 XN 159413 Need for unit testing
        }

        /// <summary>Number of extra labels to print</summary>
        public int ExtraLabels
        {
            get { return FieldToInt(this.RawRow["ExtraLabels"]).Value; }
            set { this.RawRow["ExtraLabels"] = IntToField(value);      }    // 02Aug16 XN 159413 Need for unit testing
        }

        /// <summary>
        /// Returns the required ingredient quantity given the supply quantity and dose
        /// product must have ConversionFactorPackToIssueUnits, and DosesPerIssueUnit greater than 0
        /// </summary>
        /// <param name="ingIndex">index of ingredient in formula</param>
        /// <param name="supplyQty">Manufactured product dose</param>
        /// <param name="numberOfDoses">Manufactured product number of doses</param>
        /// <param name="product">Manufactured product drug for this formula</param>
        /// <returns>required ingredient qty (in doses) (or null if error)</returns>
        public double? CalculateIngredientQty(int ingIndex, double supplyQty, double numberOfDoses, WProductRow product)
        {
            // Get ingredient quantity from formula
            var formulaQtyInDoses = this.Quantity(ingIndex);
            if (formulaQtyInDoses == null)
            {
                return null;
            }

            // Check product value
            if (product.ConversionFactorPackToIssueUnits <= 0 || (product.DosesPerIssueUnit ?? 0.0) <= 0)
            {
                return null;
            }

            // Convert to issue units
            supplyQty /= product.DosesPerIssueUnit.Value;
            double formulaQtyInIssueUnits = formulaQtyInDoses.Value / product.DosesPerIssueUnit.Value;

            // Calculate required qty
            double requiredQtyInIssueUnits;
            switch (this.IngredientType(ingIndex))
            {
            case CIVASIngredientType.Fixed:
                requiredQtyInIssueUnits = formulaQtyInIssueUnits * Math.Round(supplyQty + 0.999999);
                break;
            case CIVASIngredientType.BatchFixed:
            case CIVASIngredientType.To:
                requiredQtyInIssueUnits = formulaQtyInIssueUnits  * Math.Round((supplyQty / product.ConversionFactorPackToIssueUnits) + 0.999999);
                break;
            default:
                requiredQtyInIssueUnits = (formulaQtyInIssueUnits  * supplyQty) / product.ConversionFactorPackToIssueUnits;
                break;
            }

            // Round back to doses
            return Math.Round(requiredQtyInIssueUnits * product.DosesPerIssueUnit.Value, 7) * numberOfDoses;
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

                xmlWriter.WriteAttributeString("Authorised",     this.AuthorisedInitials);
                xmlWriter.WriteAttributeString("formulaversion", this.VersionNumber.ToString());

                if (WConfiguration.LoadAndCache<bool>(this.SiteId, "D|patmed", string.Empty, "CIVAS2ndAuth", true, false))
                {
                    xmlWriter.WriteAttributeString("FormulaVersion", this.VersionNumber.ToString());

                    if ((this.DrafEntityId ?? 0) > 0)
                        tempStr = string.Format("Saved by {0} on {1:dd/MM/yyyy hh:mm}", this.DraftInitials, this.DraftDate);
                    else
                        tempStr = string.Format("Saved by {0} on {1:dd/MM/yyyy hh:mm}", this.ApprovedInitials, this.ApprovedDate);
                    xmlWriter.WriteAttributeString("FSavedby", tempStr);

                    if ((this.ApprovedEntityId ?? 0) > 0)
                        tempStr = string.Format("Approved by {0} on {1:dd/MM/yyyy hh:mm}", this.ApprovedInitials, this.ApprovedDate);
                    else
                        tempStr = string.Empty;
                    xmlWriter.WriteAttributeString("FApprovedby", tempStr);
                }

                xmlWriter.WriteEndElement();

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }
    }

    /// <summary>WFormula table column info</summary>
    public class WFormulaColumnInfo: BaseColumnInfo
    {
        /// <summary>Initializes a new instance of the <see cref="WFormulaColumnInfo"/> class.</summary>
        public WFormulaColumnInfo () : base("WFormula") { }
    }

    /// <summary>WFormula table</summary>
    public class WFormula : BaseTable2<WFormulaRow,WFormulaColumnInfo>
    {
        /// <summary>Maximum number of ingredients</summary>
        public const int MaxIngredientCount = 15;

        /// <summary>Maximum number of layouts</summary>
        public const int MaxLayout = 2;

        /// <summary>Initializes a new instance of the <see cref="WFormula"/> class.</summary>
        public WFormula() : base("WFormula") { }

        /// <summary>Load WFormula line by ID</summary>
        /// <param name="id">WFormulaId of line</param>
        public void LoadByID(int id)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("WFormulaID",  id);
            this.LoadBySP("pWFormulaByWFormulaID", parameters);
        }

        /// <summary>Load WFormula by NSVCode, siteID and status</summary>
        /// <param name="NSVCode">NSVCode to load</param>
        /// <param name="siteID">Site ID</param>
        /// <param name="status">WManufacturingStatus status</param>
        public void LoadByNSVCodeSiteAndStatus(string NSVCode, int siteID, WManufacturingStatus status)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("NSVCode",                 NSVCode);
            parameters.Add("SiteID",                  siteID);
            parameters.Add("WManufacturingStatusID",  EnumViaDBLookupAttribute.ToLookupID(status));
            this.LoadBySP("pWFormulaByNSVCodeSiteAndStatus", parameters);
        }
    
        /// <summary>Returns NSVCode of all approved WFormula items (for site)</summary>
        /// <param name="siteID">Site ID</param>
        /// <returns>NSVCode of all approved WFormula for site</returns>
        public static IEnumerable<string> GetNSVCodeBySiteApproved(int siteID)
        {
            int wmanufacturingStatusId = EnumViaDBLookupAttribute.ToLookupID(WManufacturingStatus.Approved);
            return Database.ExecuteSQLSingleField<string>("SELECT DISTINCT NSVCode FROM WFormula WHERE LocationID_Site={0} AND WManufacturingStatusID={1}", siteID, wmanufacturingStatusId);
        }

        /// <summary>Returns first formula row by NSVCode, site ID, at approval status (or null if does not exist)</summary>
        /// <param name="NSVCode">NSVCode to load</param>
        /// <param name="siteID">Site ID</param>
        /// <returns>selected row or null if does not exist</returns>
        public static WFormulaRow GetByNSVCodeSiteAndApproved(string NSVCode, int siteID)
        {
            WFormula formula = new WFormula();
            formula.LoadByNSVCodeSiteAndStatus(NSVCode, siteID, WManufacturingStatus.Approved);
            return formula.FirstOrDefault();
        }

        /// <summary>Returns WFormula line by Id, or null if does not exist</summary>
        /// <param name="id">WFormula line id</param>
        /// <returns>selected row or null</returns>
        public static WFormulaRow GetById(int id)
        {
            WFormula formula = new WFormula();
            formula.LoadByID(id);
            return formula.FirstOrDefault();
        }
    }
}
