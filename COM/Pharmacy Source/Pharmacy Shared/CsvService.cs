using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Data;


namespace CsvService
{
    /// <summary>
    /// Class to store one CSV row
    /// </summary>
    public class CsvRow : List<string>
    {
        public string LineText { get; set; }
    }

    public static class CSVHelper
    {
        public static DataTable CSVStreamToStructuredDataTable(Stream stream, DataTable dt)
        {
            using (CsvFileReader reader = new CsvFileReader(stream))
            {
                CsvRow row = new CsvRow();
                while (reader.ReadRow(row))
                {
                    DataRow dataRow = dt.NewRow();
                    for (int i = 0; i < dt.Columns.Count; i++)
                    {
                        if (!string.IsNullOrEmpty(row[i]))
                        {
                            switch (dt.Columns[i].DataType.Name)
                            {
                                case "Byte":
                                    dataRow[i] = Convert.ToByte(row[i]);
                                    break;
                                case "Int16":
                                    dataRow[i] = Convert.ToInt16(row[i]);
                                    break;
                                case "Int32":
                                    dataRow[i] = Convert.ToInt32(row[i]);
                                    break;
                                case "Int":
                                case "Int64":
                                    dataRow[i] = Convert.ToInt64(row[i]);
                                    break;
                                case "Decimal":
                                    dataRow[i] = Convert.ToDecimal(row[i]);
                                    break;
                                case "Double":
                                    dataRow[i] = Convert.ToDouble(row[i]);
                                    break;
                                case "Boolean":
                                    if (row[i] == "1")
                                        dataRow[i] = true;
                                    else if (row[i] == "0")
                                        dataRow[i] = false;
                                    else
                                        dataRow[i] = Convert.ToBoolean(row[i]);
                                    break;
                                case "Char":
                                    dataRow[i] = Convert.ToChar(row[i]);
                                    break;
                                case "DateTime":
                                    dataRow[i] = Convert.ToDateTime(row[i]);
                                    break;
                                case "String":
                                    dataRow[i] = row[i];
                                    break;
                                default:
                                    throw new ApplicationException(string.Format("Unsupported type for CSVStreamToStructuredDataTable (type name {0}).", dt.Columns[i].DataType.Name));
                            }
                        }
                    }
                    dt.Rows.Add(dataRow);
                }
            }
            return dt;
        }
    }

    /// <summary>
    /// Class to read data from a CSV file
    /// </summary>
    public class CsvFileReader : StreamReader
    {
        public CsvFileReader(Stream stream)
            : base(stream)
        {
        }

        public CsvFileReader(string filename)
            : base(filename)
        {
        }

        /// <summary>
        /// Reads a row of data from a CSV file
        /// </summary>
        /// <param name="row"></param>
        /// <returns></returns>
        public bool ReadRow(CsvRow row)
        {
            row.LineText = ReadLine();
            if (String.IsNullOrEmpty(row.LineText))
                return false;

            int pos = 0;
            int rows = 0;

            while (pos < row.LineText.Length)
            {
                string value;

                // Special handling for quoted field
                if (row.LineText[pos] == '"')
                {
                    // Skip initial quote
                    pos++;

                    // Parse quoted value
                    int start = pos;
                    while (pos < row.LineText.Length)
                    {
                        // Test for quote character
                        if (row.LineText[pos] == '"')
                        {
                            // Found one
                            pos++;

                            // If two quotes together, keep one
                            // Otherwise, indicates end of value
                            if (pos >= row.LineText.Length || row.LineText[pos] != '"')
                            {
                                pos--;
                                break;
                            }
                        }
                        pos++;
                    }
                    value = row.LineText.Substring(start, pos - start);
                    value = value.Replace("\"\"", "\"");
                }
                else
                {
                    // Parse unquoted value
                    int start = pos;
                    while (pos < row.LineText.Length && row.LineText[pos] != ',')
                        pos++;
                    value = row.LineText.Substring(start, pos - start);
                }

                // Add field to list
                if (rows < row.Count)
                    row[rows] = value;
                else
                    row.Add(value);
                rows++;

                // Eat up to and including next comma
                while (pos < row.LineText.Length && row.LineText[pos] != ',')
                    pos++;
                if (pos < row.LineText.Length)
                    pos++;
            }
            // Delete any unused items
            while (row.Count > rows)
                row.RemoveAt(rows);

            // Return true if any columns read
            return (row.Count > 0);
        }
    }
}

