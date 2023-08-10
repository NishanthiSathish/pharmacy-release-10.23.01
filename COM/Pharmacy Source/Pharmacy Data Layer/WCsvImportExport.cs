// -----------------------------------------------------------------------
// <copyright file="WCsvImportExport.cs" company="Emis Health Plc">
// Copyright Emis Health Plc
// </copyright>
//
// <summary>
// Provides set of functions that allow importing and export of data
// from the DB table to a CSV file.
//
// The process can happen direct to and from the table or via a sps.
// When importing directly to the table the class uses a bulk insert
//
// String fields are always surrounded by ""
// Date and time fields are in format yyyy-MM-dd HH:mm:ss, or yyyy-MM-dd
// null string fields will have the value defined by NullValueForString (without "")
//
// If a header row is included in the import file, the column order does not have to 
// match the table or sp column order (but names do)
//
// The class use Microsoft.VisualBasic.FileIO.TextFieldParser (Microsoft.VisualBasic.dll) to import the file. 
//
// Each row in the table requires a 
// DataTypeName             - table name
// RoutineIdImport          - optional sp to user for import (line at a time)
// RoutineIdExport          - optional sp to user for export
// NullValueForString       - value used if the field is a string field that is null
// IfDeleteAllExistingData  - If on import all existing data is deleted from the table.
//
// Usage:
// To export data
// var export = new WCsvImportExport.GetDataTypeName("WReportingDirectorate");
// File.WriteAllText("c:\\" + export.GetDefaultFilename(), export.ConvertToCsv());
//
// To import data
// ErrorWarningList errors = new ErrorWarningList();
// var import = new WCsvImportExport.GetDataTypeName("WReportingDirectorate");
// if (import.ValidateCsv(true, "c:\\" + import.GetDefaultFilename(), errors))
//    errors = import.ParseFromCsv(true, "c:\\" + import.GetDefaultFilename());
//
// Modification History:
// 28Nov16 XN  147104 Created 
// 09Mar17 XN  179332 Allow invalid chars on spreadsheet headers
// </summary>
// -----------------------------------------------------------------------
namespace ascribe.pharmacy.pharmacydatalayer
{
    using System;
    using System.Collections.Generic;
    using System.Data;
    using System.Data.SqlClient;
    using System.Globalization;
    using System.Linq;
    using System.Text;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.shared;
    using Microsoft.VisualBasic.FileIO;

    /// <summary>Row in the WCsvImportExport table</summary>
    public class WCsvImportExportRow : BaseRow
    {
        /// <summary>List of chars that are invalid for db headers 09Mar17 XN  179332</summary>
        private readonly string invalidDBHeaderNames = " !\"£$%^&*()_-+={[}]:;@'~#<,>.?/|\\¬`";

        public int WCsvImportExportID
        {
            get { return FieldToInt(RawRow["WCsvImportExportID"]).Value; }
        }

        /// <summary>Name of the table</summary>
        public string DataTypeName              
        { 
            get { return FieldToStr(RawRow["DataTypeName"], trimString: true, nullVal: string.Empty ); } 
            set { RawRow["DataTypeName"] = StrToField(value); }
        }

        /// <summary>General description</summary>
        public string Description
        { 
            get { return FieldToStr(RawRow["Description"], trimString: true, nullVal: string.Empty ); } 
            set { RawRow["Description"] = StrToField(value); }
        }

        /// <summary>Optional ID of the sp to do import</summary>
        public int? RoutineIdImport           
        { 
            get { return FieldToInt(RawRow["RoutineID_Import"]); } 
            set { RawRow["RoutineID_Import"] = IntToField(value); }
        }

        /// <summary>Optional ID of the sp to do export</summary>
        public int? RoutineIdExport           
        { 
            get { return FieldToInt(RawRow["RoutineID_Export"]);  } 
            set { RawRow["RoutineID_Export"] = IntToField(value); }
        }

        /// <summary>Default file name for the export (if not set will be the DataTypeName)</summary>
        private string DefaultFileName           
        { 
            get { return FieldToStr(RawRow["DefaultFileName"],  trimString: true, nullVal: string.Empty ); } 
            set { RawRow["DefaultFileName"] = StrToField(value); }
        }

        /// <summary>If export data should include a header row</summary>
        public bool IfHeaderRowExport 
        { 
            get { return FieldToBoolean(RawRow["IfHeaderRowExport"]) ?? true; } 
            set { RawRow["IfHeaderRowExport"] = BooleanToField(value);        }
        }

        /// <summary>Value to use if field is a string that is null</summary>
        public string NullValueForString
        { 
            get { return FieldToStr(RawRow["NullValueForString"]);  } 
            set { RawRow["NullValueForString"] = FieldToStr(value); }
        }

        /// <summary>If on import all data should be delete from the table</summary>
        public bool IfDeleteAllExistingData   
        { 
            get { return FieldToBoolean(RawRow["IfDeleteAllExistingData"]) ?? true; } 
            set { RawRow["IfDeleteAllExistingData"] = BooleanToField(value);        }
        }

        /// <summary>If to skip importing fields that are empty 09Mar17 XN  179332</summary>
        public bool IgnoreEmptyRowsOnImport
        {
            get { return FieldToBoolean(RawRow["IgnoreEmptyRowsOnImport"]) ?? true; } 
            set { RawRow["IgnoreEmptyRowsOnImport"] = BooleanToField(value);        }
        }

        /// <summary>Get default filename to use (either DefaultFileName or DataTypeName + csv)</summary>
        /// <returns></returns>
        public string GetDefaultFilename() { return string.IsNullOrWhiteSpace(this.DefaultFileName) ? this.DataTypeName + ".csv" : this.DefaultFileName; }

        /// <summary>Either runs the export sp or select all the data from the table, and converts it into a CSV string.</summary>
        /// <returns>Data as csv string</returns>
        public string ConvertToCsv()
        {
            StringBuilder dataStr = new StringBuilder();
            GenericTable2 data = new GenericTable2();

            // Run SP or extract all data from the table
            if (this.RoutineIdExport == null)
            {
                TableInfo tableInfo = GetDbTableInfo(this.RoutineIdExport);
                data.LoadBySQL("SELECT * FROM [" + this.DataTypeName + "]", new SqlParameter[0]);
                foreach (DataColumn c in data.Table.Columns.OfType<DataColumn>().ToArray())
                {
                    if (tableInfo.FindByName(c.ColumnName) == null)
                        data.Table.Columns.Remove(c.ColumnName);
                }
            }
            else
            {
                var routineName = Database.ExecuteSQLScalar<string>("SELECT Name FROM Routine WHERE RoutineID={0}", this.RoutineIdExport);
                List<SqlParameter> parameters = new List<SqlParameter>();
                data.LoadBySP(routineName, parameters);
            }

            // Add header row if requested
            if (this.IfHeaderRowExport)
                dataStr.AppendLine('"' + data.Table.Columns.Cast<DataColumn>().Select(c => c.ColumnName).ToCSVString("\",\"") + '"');

            // Write each row
            foreach(BaseRow row in data)
            {
                // Write each field
                foreach (var field in row.RawRow.ItemArray)
                {
                    if (field == DBNull.Value)
                        dataStr.Append((!(field is string) || this.NullValueForString == null) ? string.Empty : this.NullValueForString);
                    else if (field is string)
                        dataStr.AppendFormat("\"{0}\"", field.ToString().Replace("\"", "\"\""));
                    else if (field is DateTime)
                        dataStr.AppendFormat("{0:yyyy-MM-dd HH:mm:ss}", field);
                    else
                        dataStr.Append(field.ToString());
                    dataStr.Append(",");
                }

                // Remove final ,
                dataStr.Remove(dataStr.Length - 1, 1);
                dataStr.AppendLine();
            }

            // Remove final crlf
            dataStr.Remove(dataStr.Length - 1, 1);

            return dataStr.ToString();
        }

        /// <summary>
        /// Validates the CSV file before importing checking
        ///     If it is avalid CSV file
        ///     If header row then count and names match sp or table
        /// </summary>
        /// <param name="ifHasHeaders">If file has a header row</param>
        /// <param name="path">path to the file</param>
        /// <param name="errors">List off errors to append to </param>
        /// <returns>If all is okay</returns>
        public bool ValidateCsv(bool ifHasHeaders, string path, ErrorWarningList errors)
        {
            TableInfo tableInfo = this.GetDbTableInfo(this.RoutineIdImport); // Get table or sp parameter details

            // Parse the file
            using (TextFieldParser parser = new TextFieldParser(path, Encoding.ASCII, true))
            {
                parser.Delimiters               = new [] { "," };
                parser.HasFieldsEnclosedInQuotes= true;
                parser.TextFieldType            = FieldType.Delimited;

                string[] fileHeaderRow = parser.ReadFields();

                // Check file has data
                if (fileHeaderRow.Length == 0)
                {
                    errors.AddError("Invalid CSV file");
                    return false;
                }

                // Check field count
                if (fileHeaderRow.Count() != tableInfo.Count)
                {
                    errors.AddError("The header row in the file contains {0} columns this does not match the expected count of {1}.\n{2}", fileHeaderRow.Count(), tableInfo.Count(), tableInfo.Select(c => c.ColumnName).ToCSVString("\n"));
                    return false;
                }

                // Check header row fields match
                if (ifHasHeaders)
                {
                    string[] dbFieldNames = tableInfo.Select(t => t.ColumnName.Remove(c => invalidDBHeaderNames.Contains(c))).ToArray();
                    for (int f = 0; f < fileHeaderRow.Length; f++)
                    {
                        string fileHeader = fileHeaderRow[f].Remove(c => invalidDBHeaderNames.Contains(c));
                        if (dbFieldNames.ContainsNoCase(fileHeader) == false)
                        {
                            errors.AddError("Header row names and order are not as expected\nExpected: {0}\nReceived: {1}", tableInfo.Select(t => t.ColumnName).ToCSVString(", "), fileHeaderRow.ToCSVString(", "));
                            return false;
                        }
                    }
                }
            }

            return true;
        }

        /// <summary>Reads in the CSV file and saved to it to the db (see WCsvImportExport header for more info)</summary>
        /// <param name="ifHasHeaders">If file has a header row</param>
        /// <param name="path">path to the file</param>
        /// <returns>Errors that occured</returns>
        public ErrorWarningList ParseFromCsv(bool ifHasHeaders, string path)
        {
            DateTimeStyles dateTimeStyle = DateTimeStyles.AllowLeadingWhite | DateTimeStyles.AllowTrailingWhite | DateTimeStyles.AllowWhiteSpaces;
            string[] dateTimeFormats = { "yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd" };
            ErrorWarningList errors = new ErrorWarningList();
            var culture = CultureInfo.CurrentCulture;
            string[] fileHeaderRow = null;
            int lineCount = 0;

            // If routine import then get routine name
            string routineName = string.Empty;
            if (this.RoutineIdImport != null)
                routineName = Database.ExecuteSQLScalar<string>("SELECT Name FROM Routine WHERE RoutineID={0}", this.RoutineIdImport);

            // Read in file
            using (TextFieldParser parser = new TextFieldParser(path, Encoding.ASCII, true))
            {
                parser.Delimiters               = new [] { "," };
                parser.HasFieldsEnclosedInQuotes= true;
                parser.TextFieldType            = FieldType.Delimited;

                // Read header line if expected
                if (ifHasHeaders)
                    fileHeaderRow = parser.ReadFields();

                TableInfo tableInfo = GetDbTableInfo(this.RoutineIdImport);
                Type[]   dbFieldTypes       = tableInfo.Select(t => t.GetNETType()).ToArray();
                string[] dbFieldNames       = tableInfo.Select(t => t.ColumnName).ToArray();
                int[]    fileToDbFieldIndex = this.GetImportFileToDbIndex(fileHeaderRow, tableInfo);
                int[]    dbFieldLength      = tableInfo.Select(t => t.Length).ToArray();

                // Read each line of file
                GenericTable2 table = new GenericTable2(this.DataTypeName);
                List<List<SqlParameter>> parameters = new List<List<SqlParameter>>();
                while (!parser.EndOfData)
                {
                    lineCount++;
                    string[] fields = parser.ReadFields();
                    int nullOrEmptyFieldCount = 0;

                    // Check columns match expected count
                    if (fields.Length != fileToDbFieldIndex.Length)
                    {
                        errors.AddError("Line {0} has {1} fields when it should have {2} fields", lineCount, fields.Length, fileToDbFieldIndex.Length);
                        continue;
                    }

                    if (this.RoutineIdImport == null)
                        table.Add();
                    else
                        parameters.Add(new List<SqlParameter>());

                    // Read in fields
                    for (int f = 0; f < fields.Length; f++)
                    {
                        string fileField = fields[f];
                        int dbFieldIndex = fileToDbFieldIndex[f];
                        Type dbFieldType = dbFieldTypes[dbFieldIndex];
                        var dbName = dbFieldNames[dbFieldIndex];
                        var rowInfo = tableInfo[dbFieldIndex];
                        object dbField;
                        
                        if (dbFieldType.Name == "String" && fileField == (this.NullValueForString ?? string.Empty))
                        {
                            dbField = rowInfo.IsNullable ? (object)DBNull.Value : (object)string.Empty; // Handle null string
                            nullOrEmptyFieldCount++;
                        }
                        else if (dbFieldType.Name == "String" && fileField.Length > dbFieldLength[dbFieldIndex])
                        {
                            errors.AddError("Line {0} field {1}{2} length of string is too long for the db. DB field length is {0}", 
                                                lineCount, 
                                                f,
                                                fileHeaderRow == null ? string.Empty : " (" + fileHeaderRow[f] + ")",
                                                dbFieldLength[dbFieldIndex]);
                            continue;
                        }
                        else if (dbFieldType.Name != "String" && string.IsNullOrEmpty(fileField))
                        {
                            dbField = DBNull.Value; // Handle null string
                            nullOrEmptyFieldCount++;
                        }
                        else if (dbFieldType.Name == "DateTime")
                        {
                            // Read data time field
                            DateTime dbDateField;
                            if (DateTime.TryParseExact(fileField, dateTimeFormats, culture, dateTimeStyle, out dbDateField))
                                dbField = dbDateField;
                            else
                            {
                                errors.AddError("Line {0} field {1}{2} date\\time format is invalid should be in formats {3}", 
                                                    lineCount, 
                                                    f,
                                                    fileHeaderRow == null ? string.Empty : " (" + fileHeaderRow[f] + ")",
                                                    dateTimeFormats.ToCSVString(","));
                                continue;
                            }
                        }
                        else 
                        {
                            // Read other fields
                            try
                            {
                                dbField = ConvertExtensions.ChangeType(dbFieldType, fileField);
                            }
                            catch (Exception ex)
                            {
                                errors.AddError("Line {0} field {1}{2} failed to convert: error is {3}", 
                                                    lineCount, 
                                                    f,
                                                    fileHeaderRow == null ? string.Empty : " (" + fileHeaderRow[f] + ")",
                                                    ex.Message);
                                continue;
                            }
                        }

                        // Add row to table or parameter list
                        if (this.RoutineIdImport == null)
                            table[table.Count - 1].RawRow[dbName] = dbField;
                        else
                            parameters[parameters.Count - 1].Add(dbName, dbField);
                    }

                    // remove empty row if ignoring 09Mar17 XN 179332
                    if (this.IgnoreEmptyRowsOnImport && nullOrEmptyFieldCount == fields.Length)
                    {
                        if (this.RoutineIdImport == null)
                            table.RemoveAt(table.Count - 1);
                        else
                            parameters.RemoveAt(parameters.Count - 1);
                    }
                }

                // If nothing read the error!
                if (table.Count == 0 && parameters.Count == 0 && errors.Count == 0)
                    errors.AddError("No data to import");

                if (errors.Count == 0)
                {
                    // Delete existing rows if requested
                    try
                    {
                        if (this.IfDeleteAllExistingData)
                            Database.ExecuteSQLNonQuery("DELETE FROM [{0}]", this.DataTypeName);
                    }
                    catch (Exception ex)
                    {
                        errors.AddError("Failed deleting existing data: error is " + ex.Message);
                    }

                    // Either import via sp or bulk insert
                    try
                    {
                        if (this.RoutineIdImport == null)
                        {
                            table.WriteToAudtiLog = false;
                            table.SaveUsingBulkInsert();
                        }
                        else
                        {
                            foreach (var par in parameters)
                                Database.ExecuteSPNonQuery(routineName, par);
                        }
                    }
                    catch (Exception ex)
                    {
                        errors.AddError("Failed saving data: error is " + ex.GetAllMessaages().ToCSVString("\n"));
                    }
                }
            }

            return errors;
        }

        /// <summary>
        /// Returns table info for table this.DataTypeName if routineId is null, 
        /// or the input parameters of the routine (in TableInfo)
        /// </summary>
        /// <param name="routineId">Routine Id</param>
        /// <returns>Table info</returns>
        private TableInfo GetDbTableInfo(int? routineId)
        {
            TableInfo tableInfo = new TableInfo();

            if (routineId == null)
            {
                // Read direct from table
                tableInfo.LoadByTableName(this.DataTypeName);
                tableInfo.RemoveAll(t => TableInfo.ExcludedColumns.ContainsNoCase(t.ColumnName));
                tableInfo.RemoveAll(t => t.IsPK);
            }
            else
            {
                // When BaseTable2 calls CreateEmpty it expects a table name which is not possible for TableInfo
                // So fool it by calling LoadByTableName, and then clearing so have correct column structure
                tableInfo.LoadByTableName(this.DataTypeName);
                tableInfo.RemoveAll();

                GenericTable2 genTable = new GenericTable2();
                genTable.LoadBySQL(string.Format("SELECT Description as name, DataType as type, Length, 0 as pk, 0 as isnullable FROM RoutineParameter WHERE RoutineID={0} ORDER BY [Order]", routineId.Value), new SqlParameter[0]);
                genTable.ForEach(row => tableInfo.Add().CopyFrom(row));
            }

            return tableInfo;
        }

        /// <summary>Returns mapping of import file column to table or sp field (based on header row if no header row the direct 1 to 1 mapping)</summary>
        /// <param name="fileHeaderRow">Header row from file</param>
        /// <param name="tableInfo">Table info of sp or table from db</param>
        /// <returns>CSV file index to db index mapping</returns>
        private int[] GetImportFileToDbIndex(string[] fileHeaderRow, TableInfo tableInfo)
        {
            if (fileHeaderRow == null)
            {
                int[] indexes = new int[tableInfo.Count];
                for (int c = 0; c < tableInfo.Count; c++)
                    indexes[c] = c;
                return indexes;
            }
            else
            {
                var tableInfoRow = tableInfo.ToList();
                var fileHeaders  = fileHeaderRow.Select(r => r.Remove(i => invalidDBHeaderNames.Contains(i)));
                var columnHeaders= tableInfoRow.Select(r => r.ColumnName.Remove(i => invalidDBHeaderNames.Contains(i))).ToList();
                return fileHeaders.Select(f => columnHeaders.FindIndex(t => t.EqualsNoCase(f))).ToArray();
            }
        }
    }


    /// <summary>Table info for WCsvImportExport table</summary>
    public class WCsvImportExportColumnInfo : BaseColumnInfo
    {
        public WCsvImportExportColumnInfo() : base("WCsvImportExport") { }
    }


    /// <summary>Represent the WCsvImportExport table</summary>
    public class WCsvImportExport : BaseTable2<WCsvImportExportRow, WCsvImportExportColumnInfo>
    {
        public WCsvImportExport() : base("WCsvImportExport") { }

        /// <summary>Load row by DataTypeName</summary>
        public void LoadByDataTypeName(string dataTypeName)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("DataTypeName", dataTypeName);
            this.LoadBySP("pWCsvImportExportByDataTypeName", parameters);
        }

        /// <summary>Returns row by DataTypeName</summary>
        public static WCsvImportExportRow GetDataTypeName(string dataTypeName)
        {
            WCsvImportExport importExport = new WCsvImportExport();
            importExport.LoadByDataTypeName(dataTypeName);
            return importExport.FirstOrDefault();
        }
    }
}
