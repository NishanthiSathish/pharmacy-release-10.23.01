
// --------------------------------------------------------------------------------------------------------------------
// <copyright file="SSRSLocalReport.cs" company="Ascribe Ltd.">
//   Copyright (c) Ascribe Ltd. All rights reserved.
// </copyright>
// <summary>
//  This class provides helper methods for populating an SSRS rdlc (local report), 
//  and is normally used by SSRSReport.aspx to populate a report to display.
//
//  Unlike normal SSRS reports rdlc reports are not automaticallly populated with
//  with data when loaded. Instead they have to be manualy populated.
//  The report will have a number of datasets, and this class allows them to be 
//  populated by a single SP (match an sps ds to a report ds is done via match column names)
//
//  When loading reports the class will first look for path defined by setting
//  System: Pharmacy
//  Section: SSRS
//  Key: SharedPath
//  If the setting does not exist it then it look in <webfolder>\Reports
//
//  Customisation of reports
//  ------------------------
//  Normally you only get a default report provided for the whole trust, 
//  to create a customised report that does not get overwritten on the next upgrade 
//  create a new {Report Name}.custom.rdlc report (this will take presidence over the default {Report Name}.rdlc)
//  It is also possible to create site specific reports (saving report as {Report Name}.{site number}.rdlc)
//  these take presidence over default {Report Name}.rdlc, and customer {Report Name}.custom.rdlc reports
//
//  Default Details
//  ---------------
//  Method LoadDefaultDetails is used to set default report parameters
//      HospitalFullName
//      HospitalAccountName
//      HospitalAbbreviatedName
//      UserInitials
//      UserName
//  
//  Usage
//  SSRSLocalReport report = new SSRSLocalReport(reportViewer, "Ward Stock List\Report1.rdlc", 19);    
//
//  Populate report datasets
//  List<SqlParameter> parameters = new List<SqlParameter>();
//  parameters.Add("WWardProductListID", 34);
//  report.AddSPResults("pPharmacyReportWardProductList", parameters);
//
//  Set parameter values
//  report.AddParameter("SiteNumber", "503");
//      
//  Modification History:
//  12Jan14 XN  87515 Created
// </summary>
// --------------------------------------------------------------------------------------------------------------------
namespace ascribe.pharmacy.reportlayer
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Data.SqlClient;
    using System.IO;
    using System.Linq;
    using System.Xml;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;
    using Microsoft.Reporting.WebForms;

    /// <summary>Help class for SSRS local reports (rdlc reports)</summary>
    public class SSRSLocalReport
    {
        /// <summary>Initializes a new instance of the <see cref="SSRSLocalReport"/> class.</summary>
        /// <param name="viewer">Report viewer to load the report into</param>
        /// <param name="reportName">Name of report including sub-path (Ward Stock List\Report1.rdlc)</param>
        /// <param name="siteNumber">Optional site number (so can load site specific reports)</param>
        public SSRSLocalReport(ReportViewer viewer, string reportName, int? siteNumber)
        {            
            this.Viewer                        = viewer;
            this.Viewer.LocalReport.ReportPath = GetReportPath(reportName, siteNumber);
        }
        
        #region Properties
        /// <summary>Gets path of the report</summary>
        public string ReportPath 
        {
            get
            {
                return this.Viewer.LocalReport.ReportPath;
            }
        }

        /// <summary>Gets report view control passed in </summary>
        public ReportViewer Viewer { get; private set; }
        #endregion

        #region Public Methods
        /// <summary>Load default information like hospital name, user details, and sets the parameters in the report</summary>
        public void LoadDefaultDetails()
        {
            var reportParameters = new HashSet<string>( this.Viewer.LocalReport.GetParameters().Select(p => p.Name) );

            // Set hospital name details
            if (SessionInfo.HasSite)
            {
                HospitalDetails details = new HospitalDetails();
                details.LoadBySiteID(SessionInfo.SiteID);

                if (reportParameters.Contains("HospitalFullName"))
                {
                    this.AddParameter("HospitalFullName", details.FullName);
                }

                if (reportParameters.Contains("HospitalAccountName"))
                {
                    this.AddParameter("HospitalAccountName", details.AccountName);
                }

                if (reportParameters.Contains("HospitalAbbreviatedName"))
                {
                    this.AddParameter("HospitalAbbreviatedName", details.AbbreviatedName);
                }

                if (reportParameters.Contains("SiteNumber"))
                {
                    this.AddParameter("SiteNumber", SessionInfo.SiteNumber.ToString("000"));
                }
            }

            // Set user details
            if (reportParameters.Contains("UserInitials"))
            {
                this.AddParameter("UserInitials", SessionInfo.UserInitials);
            }

            if (reportParameters.Contains("UserName"))
            {
                this.AddParameter("UserName", SessionInfo.Username);
            }
        }

        /// <summary>
        /// Adds all the report data (dataset data) from the SP
        /// The SP can return multiple tables (these are matched to the report table by match column names)
        /// </summary>
        /// <param name="sp">Name for the sp to run</param>
        /// <param name="parameters">Parameters for SP</param>
        /// <exception cref="ApplicationException">If can't match report datatable with datatable from sp</exception>
        public void LoadDataBySP(string sp, IEnumerable<SqlParameter> parameters)
        {
            DataSet dataSet = new DataSet();

            using (SqlDataAdapter dataAdapter = new SqlDataAdapter(sp, Database.ConnectionString))
            {
                // Works better if constraints are not enforced
                dataSet.EnforceConstraints = false;

                // Add parameters to adapter
                dataAdapter.SelectCommand.CommandType = CommandType.StoredProcedure;
                if (parameters != null)
                {
                    dataAdapter.SelectCommand.Parameters.AddRange(parameters.ToArray());
                }

                // Fill dataset
                dataAdapter.Fill(dataSet);
            }

            // Load the report into XML to get list DataSet tables, and their column names (stored in dictionary)
            Dictionary<string,HashSet<string>> tableNameToColumnList = new Dictionary<string, HashSet<string>>();

            XmlDocument doc = new XmlDocument();
            doc.Load(this.ReportPath);

            XmlElement datasetsNode = doc.DocumentElement.ChildNodes.OfType<XmlElement>().First(x => x.Name == "DataSets");
            IEnumerable<XmlElement> datasetNodes = datasetsNode.ChildNodes.OfType<XmlElement>().Where(x => x.Name == "DataSet");

            foreach (XmlNode dsNode in datasetNodes)
            {
                var element = dsNode.ChildNodes.OfType<XmlElement>().Desendants(x => x.ChildNodes.OfType<XmlElement>());
                var columnNames = from x in dsNode.ChildNodes.OfType<XmlElement>().Desendants(x => x.ChildNodes.OfType<XmlElement>())
                                  where x.Name == "DataField"
                                  select x.InnerText;
                tableNameToColumnList.Add( dsNode.Attributes["Name"].Value, new HashSet<string>(columnNames) );
            }

            // Match dataset tables from sp with ones in report (on column name)
            // Can then populate the correct data table in the report
            foreach (DataTable table in dataSet.Tables)
            {
                // Get column names for the sp data table
                var columnNames = table.Columns.Cast<DataColumn>().Select(c => c.ColumnName);

                // Get report table with the highest matching set of column names
                var dataSourceName  = (from name in tableNameToColumnList
                                       let matchColumnCount = columnNames.Count(n => name.Value.Contains(n))
                                       orderby matchColumnCount descending
                                       select new 
                                                  {
                                                      Name              = name.Key, 
                                                      MatchColumnCount  = matchColumnCount
                                                  }).First();

                if (dataSourceName.MatchColumnCount == 0)
                {
                    // Error if there is no match
                    string errorMsg = string.Format("SP {0} returns a data table that does not match any data set in the report (match done by column name)", sp);
                    throw new ApplicationException(errorMsg);
                }
                else
                {
                    // Populate report with the data table
                    this.Viewer.LocalReport.DataSources.Add(new ReportDataSource(dataSourceName.Name, table));
                }
            }
        }

        /// <summary>Add parameter to the report (used to populate report parameters)</summary>
        /// <param name="name">Parameter name</param>
        /// <param name="value">Parameter value</param>
        public void AddParameter(string name, string value)
        {
            this.Viewer.LocalReport.SetParameters(new ReportParameter(name, value));
        }

        /// <summary>Add parameter to the report (used to populate report parameters)</summary>
        /// <param name="name">Parameter name</param>
        /// <param name="formatter">Parameter value formatter</param>
        /// /// <param name="param">Parameter value</param>
        public void AddParameter(string name, string formatter, params object[] param)
        {
            this.AddParameter(name, string.Format(formatter, param));
        }
        #endregion

        #region Private Methods
        /// <summary>
        /// Returns report full path
        /// Either from setting 
        ///     System  : Pharmacy
        ///     Section : SSRS
        ///     Key     : SharedPath
        /// Will test if there are the following reports
        ///      {Report Name}.{site number}.rdlc
        ///      {Report Name}.custom.rdlc
        ///      {Report Name}.rdlc
        /// </summary>
        /// <param name="reportName">Name of the report (with sub-path)</param>
        /// <param name="siteNumber">Optional site number (to load site specific report)</param>
        /// <returns>Report path</returns>
        protected static string GetReportPath(string reportName, int? siteNumber)
        {
            // Setting for the report
            string reportPath = Database.ExecuteSQLScalar<string>("SELECT [Value] FROM Setting WHERE [Key]='SharedPath' AND [Section]='SSRS' AND [System]='Pharmacy'");
            if (string.IsNullOrEmpty(reportPath))
            {
                reportPath = AppDomain.CurrentDomain.BaseDirectory + @"\Reports";
            }

            // check for correct path separators
            if (!reportPath.TrimEnd().EndsWith("\\"))
            {
                reportPath += '\\';
            }

            if (reportName.Length > 0 && reportName[0] == '\\')
            {
                reportName = reportName.Remove(0, 1);                
            }

            string reportFullName;
            string extension = Path.GetExtension(reportName);

            // First try site custom report {Report Name}.584.rdlc
            if (siteNumber != null)
            {
                reportFullName = reportPath + Path.ChangeExtension(reportName, siteNumber.Value.ToString("000") + "." + extension);
                if (File.Exists(reportFullName))
                {
                    return reportFullName;
                }
            }

            // Then try global custom report {Report Name}.custom.rdlc
            reportFullName = reportPath + Path.ChangeExtension(reportName, "custom." + extension);
            if (File.Exists(reportFullName))
            {
                return reportFullName;
            }

            // Then try standard report {Report Name}.rdlc
            reportFullName = reportPath + reportName;
            if (File.Exists(reportFullName))
            {
                return reportFullName;
            }

            // Report does not exits
            throw new ApplicationException("Reports folder does not contain report '" + reportFullName + "'");
        }
        #endregion
    }
}
