//===========================================================================
//
//						    ReportPrintForm.cs
//
//  This class holds all business logic help generate reports to display all 
//  data in an editable form, or more correctly XML to pass to the print processor.
//
//  The report will take the layout:
//                    Title
//  Section  Description    >   Value
//           Description    >   Value
//           Description    >   Value
//           :
//
//  Section  Description    >   Value
//           Description    >   Value
//           Description    >   Value
//           :
//
//  Normally used for generating report to display all data in an editable form.
//  The xml data for the report is stored in session attribute PharmacyGeneralReportAttribute
//  and is expected to be used with standard report 'Pharmacy General Report {site number}'
//
//  Usage:
//
//  ReportPrintForm report = new ReportPrintForm();
//  report.Initalise("PN Product", 503);
//  report.StartNewSection("Detail");
//  report.AddValue(lbDescription, tbDescritpion);
//  report.AddValue(lbPNCode.Text, !tbPNCode.ReadOnly, tbPNCode.Text);
//  report.Save();
//
//  string reportName = report.GetReportName();
//  ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Print", string.Format("window.ICWWindow().document.frames['fraPrintProcessor'].PrintReport({0}, '{1}', 0, false, '');", this.sessionID, reportName), true);
//      
//	Modification History:
//	07Dec12 XN  Written
//  04Jan12 XN  Added StartNewSection useWholeRow option so can have long section names
//  11Nov14 XN  To prevent cirular reference remove namespace ascribe.pharmacy.businesslayer
//              Got Save to get the businesslayer data directly 43318
//  12Jan14 XN  Refactored to use HospitalDetails to get hospital name
//===========================================================================
using System;
using System.Collections.Generic;
using System.Text;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;
using System.Xml;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.reportlayer
{
    /// <summary>Used to generate report data for printing details in a form</summary>
    public class ReportPrintForm
    {
        #region Member variables
        /// <summary>Current section (after section is written variable is cleared)</summary>
        private string currentSection = string.Empty;

        /// <summary>Report title</summary>
        private string title;

        /// <summary>Site number of the report</summary>
        private int siteNumber;
        #endregion

        #region Public Properties
        /// <summary>
        /// Gets the RTF table used to display all the values.
        /// You can use this to change the report margins, or column info (like sizes) 
        /// But call Initialise first
        /// </summary>
        public RTFTable DataTable { get; private set; }
        #endregion

        #region Public Methods
        /// <summary>Initialise the report</summary>
        /// <param name="title">Report title</param>
        /// <param name="siteNumber">Site Number</param>
        public void Initialise(string title, int siteNumber)
        {
            this.title      = title;
            this.siteNumber = siteNumber;

            // Initialise the RTF table to hold all the values
            this.DataTable = new RTFTable();
            this.DataTable.LeftMarginInTwips  = 800;
            this.DataTable.RightMarginInTwips = 2000;
            this.DataTable.AddColumn(string.Empty, 15, RTFTable.AlignmentType.Left  );
            this.DataTable.Columns[0].italic = true;
            this.DataTable.AddColumn(string.Empty, 35, RTFTable.AlignmentType.Left  );
            this.DataTable.AddColumn(string.Empty, 10,  RTFTable.AlignmentType.Center);
            this.DataTable.AddColumn(string.Empty, 40, RTFTable.AlignmentType.Left );
        }

        /// <summary>Start of new section</summary>
        /// <param name="section">Section name</param>
        /// <param name="useWholeRow">If section should expand to whole row (for big section)</param>
        public void StartNewSection(string section, bool useWholeRow = false)
        {
            this.AddEmptyLine(); // spacer between sections

            if (useWholeRow)
            {
                // RTFTable does not currently have a row span option so temporarily replace existing 
                // columns with a single one at 100%

                // Take a copy of the columns
                List<RTFTable.ColumnInfo> originalColumns = new List<RTFTable.ColumnInfo>(this.DataTable.Columns);

                // Readd the first column but set it's width to 100%
                this.DataTable.Columns.Clear();
                this.DataTable.Columns.Add(originalColumns[0].Clone());
                this.DataTable.Columns[0].widthInPercentage = 100;

                // Write the row
                this.DataTable.NewRow();
                this.DataTable.AddCell(section);

                // Reset the original columns
                this.DataTable.Columns.Clear();
                this.DataTable.Columns.AddRange(originalColumns);

                this.currentSection = string.Empty;
            }
            else
            {
                this.currentSection = section;   // Done normal way so let AddNewRow set the current section
            }
        }

        /// <summary>Add empty line to the report</summary>
        public void AddEmptyLine()
        {
            this.AddValue(string.Empty, false, string.Empty);
        }

        /// <summary>Add a description and value to the report</summary>
        /// <param name="label">Label with the description</param>
        /// <param name="value">Textbox with value (and if not readonly the marked as editable)</param>
        public void AddValue(HtmlGenericControl label, TextBox value)
        {
            this.AddValue(label.InnerText, !value.ReadOnly, value.Text);
        }

        /// <summary>Add a description and value to the report</summary>
        /// <param name="label">Label with the description</param>
        /// <param name="value">Checkbox with value Yes\No on report (and if not readonly the marked as editable)</param>
        public void AddValue(HtmlGenericControl label, CheckBox value)
        {
            this.AddValue(label.InnerText, value.Enabled, value.Checked.ToYesNoString());
        }

        /// <summary>Add a description and value to the report</summary>
        /// <param name="label">Label with the description</param>
        /// <param name="value">Dropdown with selected value (and if not readonly the marked as editable)</param>
        public void AddValue(HtmlGenericControl label, DropDownList value)
        {
            this.AddValue(label.InnerText, value.Enabled, value.SelectedItem.Text);
        }

        /// <summary>Add a description and value to the report</summary>
        /// <param name="label">Label to give the description</param>
        /// <param name="editable">If item is editable (adds a > char to the report)</param>
        /// <param name="value">Value to add to the report</param>
        public void AddValue(string label, bool editable, string value)
        {
            this.DataTable.NewRow();
            this.DataTable.AddCell(this.currentSection);
            this.DataTable.AddCell(label);
            this.DataTable.AddCell(editable ? ">" : string.Empty);
            this.DataTable.AddCell(value);

            this.currentSection = string.Empty;
        }

        /// <summary>Saves the report xml to session attribute PharmacyGeneralReportAttribute</summary>
        public void Save()
        {
            DateTime now = DateTime.Now;

            // Get the string that has site Full name, account name, abbreviatedName 
            //string siteInfo = Database.ExecuteSQLScalar<string>("SELECT [Value] FROM WConfiguration WHERE [Key]='ASC' AND SiteID={0} AND Section='' AND Category='D|SITEINFO'", SessionInfo.SiteID);
            //if (siteInfo.StartsWith("\""))
            //    siteInfo = siteInfo.SafeSubstring(0, 1);
            //if (siteInfo.EndsWith("\""))
            //    siteInfo = siteInfo.SafeSubstring(siteInfo.Length - 1, 1);
            //string[] siteInfoItems = EncryptionAlgorithms.DecodeHex(siteInfo).Split('|'); Refactored to use common class HospitalDetails   12Jan14 XN  87515
            HospitalDetails hospitalDetails = new HospitalDetails();
            hospitalDetails.LoadBySiteID(SessionInfo.SiteID);

            StringBuilder xml = new StringBuilder();                              // XML used to create the data 

            // XML writer used to create the data 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;
            XmlWriter xmlWriter = XmlWriter.Create(xml, settings);

            // Add Title.title tag
            xmlWriter.WriteStartElement("Title");
            xmlWriter.WriteAttributeString("title", title);
            xmlWriter.WriteEndElement();

            // Add general print user tags
            xmlWriter.WriteStartElement("Info");
            //xmlWriter.WriteAttributeString("hospname1", (siteInfoItems.Length >= 3) ? siteInfoItems[2].Trim() : string.Empty);    // Full name         12Jan14 XN  87515
            //xmlWriter.WriteAttributeString("hospname2", (siteInfoItems.Length >= 4) ? siteInfoItems[3].Trim() : string.Empty);    // Account Name      12Jan14 XN  87515
            //xmlWriter.WriteAttributeString("hospname3", (siteInfoItems.Length >= 2) ? siteInfoItems[1].Trim() : string.Empty);    // Abbreviated Name  12Jan14 XN  87515
            xmlWriter.WriteAttributeString("hospname1", hospitalDetails.FullName);          // Full name
            xmlWriter.WriteAttributeString("hospname2", hospitalDetails.AccountName);       // Account Name
            xmlWriter.WriteAttributeString("hospname3", hospitalDetails.AbbreviatedName);   // Abbreviated Name
            xmlWriter.WriteAttributeString("SiteNumber", SessionInfo.SiteNumber.ToString("000"));

            xmlWriter.WriteAttributeString("UserID",   SessionInfo.UserInitials);
            xmlWriter.WriteAttributeString("UserName", SessionInfo.Username);
            xmlWriter.WriteAttributeString("today",    now.ToPharmacyDateString());
            xmlWriter.WriteAttributeString("TimeNow",  now.ToPharmacyTimeString());
            xmlWriter.WriteEndElement();

            // Add actual data from form
            this.DataTable.Close();
            xmlWriter.WriteStartElement("Data");
            xmlWriter.WriteAttributeString("InfoText", string.Empty);
            xmlWriter.WriteAttributeString("Table",    this.DataTable.ToString());
            xmlWriter.WriteEndElement();

            xmlWriter.Close();

            GENRTL10.State state = new GENRTL10.State();
            state.SessionAttributeSet(SessionInfo.SessionID, "PharmacyGeneralReportAttribute", xml.ToString());
        }

        /// <summary>Gets the report name to use to print the data 'Pharmacy General Report {site number)'</summary>
        /// <returns>Report name</returns>
        public string GetReportName()
        {
            return string.Format("Pharmacy General Report {0}", siteNumber);
        }
        #endregion
    }
}
