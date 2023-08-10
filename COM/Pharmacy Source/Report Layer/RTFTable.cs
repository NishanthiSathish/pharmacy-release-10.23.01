//===========================================================================
//
//						    RTFTable.cs
//
//  This class is used to generate an RTF table to be used in a report.
//
//  Basic layout of the RTF table generated is as follows:
//  \fs<n>                              - Font size
//  {\rtf1\ansi\deff0                   - start of table
//  \row\trowd\trgaph<n>\trleft<n>      - start of 1st row (column headers)
//  \cellx<column 1 right pos>          - Set width of 1st cell
//  \cellx<column 2 right pos>          - Set width of 2nd cell
//  :
//  \b\ul\qc<header1>\intbl\cell\b0\ul0 - column 1 header in bold, underlined, and centred
//  \b\ul\qc<header2>\intbl\cell\b0\ul0 - column 2 header in bold, underlined, and centred
//  :
//  \row\trowd\trgaph<n>\trleft<n>      - start of 2nd row (first row of table data)
//  \cellx<column 1 right pos>          - Set width of 1st cell
//  \cellx<column 2 right pos>          - Set width of 2nd cell
//  :
//  \ql<row 0 cell 0 text>              - Set row 0 cell 0 text (left aligned)
//  \ql<row 0 cell 1 text>              - Set row 0 cell 1 text (left aligned)
//  :
//
//  Once you have created the table using the class methods call Close, 
//  and then ToString to get the table text.
//
//  After the first call to NewRow, changes to margins, columns, or page sizes will not
//  be reflected in the report
//
//  NOTE: Due to various issues with page size and Twips the table position on the page
//  seems a bit suspect, but is good enough for the current set of reports.
//
//  PharmacyGridControl
//  -------------------
//  The class also has a static helper method ConvertPharmacyGrid to use the output from 
//  PharmacyGridControl client side MarshalRows method to convert the grid to an RTF table.
//
//  RTF Format References
//  ---------------------
//  http://www.pindari.com/rtf1.html
//  http://www.pindari.com/rtf3.html
//  http://www.biblioscape.com/rtf15_spec.htm#Heading42
//
//  Usage:
//  To create and RTF Report
//  RTFTable table = new RTFTable();
//  table.AddColumn("Col 1", 15, RTFTable.AlignmentType.Left);
//  table.AddColumn("Col 2", 15, RTFTable.AlignmentType.Center);
//  table.AddColumn("Col 3", 15, RTFTable.AlignmentType.Right);
//  table.NewRow();
//  table.AddCell("Some text");
//  table.AddCell("Some more text");
//  table.AddCell("Even more text");
//  table.NewRow();
//  table.AddCell("Some text");
//  table.AddCell("Some more text");
//  table.AddCell("Even more text");
//  table.Close();
//
//  string rtf = table.ToString();
//      
//	Modification History:
//	28Dec12 XN  Written
//  04Jan12 XN  Updates to allow ReportPrintForm.StartNewSection to have useWholeRow option
//              Removed ColumnInfo.widthInTwips as needs to calculate on fly
//  23Apr13 XN  Unescape data sent by xml so printed correctly 53147 
//  26Apr13 XN  53699 XML unescaped headers
//  09May14 XN  88858 Added formatting of a cell
//  09Jul14 XN  38034 Update WriteColumnHeaders so only format header if present 
//                    (to get around bold underline issue for ward stock list)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.reportlayer
{
    /// <summary>Used to generate an RTF table to be used in a report</summary>
    public class RTFTable
    {
        #region Data Types
        /// <summary>Info about a column</summary>
        public class ColumnInfo
        {
            public string        text;
            public int           widthInPercentage;
            public AlignmentType alignment;
            public bool          italic;

            public ColumnInfo Clone()
            {
                return (ColumnInfo)base.MemberwiseClone();
            }
        }

        /// <summary>Determines how a cells content can be aligned</summary>
        public enum AlignmentType
        {
            Left,
            Right,
            Center,
        };

        /// <summary>Orientation of the page</summary>
        public enum Orientation
        {
            Landscape,
            Portrait
        }
        #endregion

        #region Constants
        /// <summary>Number of Twips in a mm</summary>
        protected const double TwipsPermm = 56.6929134;

        /// <summary>RTF cell spacing in Twips</summary>
        protected const int cellSpacingInTwips = 50;
        #endregion

        #region Member Variables
        /// <summary>String to hold the table</summary>
        protected StringBuilder rtf = new StringBuilder();

        /// <summary>If already added the column header (set in first call to NewRow)</summary>
        protected bool writenColumnHeaders = false;

        /// <summary>Index of the current column being added (used NewRow and AddCell)</summary>
        protected int currentColumn = 0;
        #endregion

        #region Public Properties
        /// <summary>Margin between left side of page and table (default 250)</summary>
        public int LeftMarginInTwips { get; set; }

        /// <summary>Margin between right side of page and table (default 1000)</summary>
        public int RightMarginInTwips { get; set; }

        /// <summary>Height of the page in mm (default is A4 at 297mm)</summary>
        public int PageHeightInmm { get; protected set; }

        /// <summary>Width of the page in mm (default is A4 at 210mm)</summary>
        public int PageWidthInmm { get; protected set; }

        /// <summary>Page orientation default is Portrait</summary>
        public Orientation PageOrientation { get; protected set; }

        /// <summary>Table font size (default 20)</summary>
        public int FontSize { get; protected set; }

        /// <summary>Report column</summary>
        public List<ColumnInfo> Columns { get; private set; }
        #endregion

        #region Constructor
        public RTFTable() 
        { 
            this.Columns           = new List<ColumnInfo>();
            this.LeftMarginInTwips = 250;
            this.RightMarginInTwips= 1000;
            this.PageHeightInmm    = 297;
            this.PageWidthInmm     = 210;
            this.PageOrientation    = Orientation.Portrait;
            this.FontSize          = 20;
        }
        #endregion

        #region Public Methods
        /// <summary>Adds a new column to the report</summary>
        /// <param name="text">Column header</param>
        /// <param name="widthInPercentage">Column width as % of page width (minus margins)</param>
        /// <param name="alignment">Column text alignment</param>
        public void AddColumn(string text, int widthInPercentage, AlignmentType alignment)
        {
            Columns.Add(new ColumnInfo() { text = text, widthInPercentage = widthInPercentage, alignment = alignment });
        }

        /// <summary>Start a new row on the page</summary>
        public void NewRow()
        {
            // If not added column headers then do this now
            if (!this.writenColumnHeaders)
            {
                WriteColumnHeaders();
                this.writenColumnHeaders = true;
            }

            // Write start of new row to the report
            int posInTwips = LeftMarginInTwips;
            rtf.AppendFormat(@"\row\trowd\trgaph{0}\trleft{1}", cellSpacingInTwips, posInTwips);    // Add new row setting cell spacing (trgaph) and left margin (trleft)
            foreach (ColumnInfo col in Columns)
            {
                posInTwips += this.CalculatePercentageWidthToTwips(col.widthInPercentage);
                rtf.AppendFormat(@"\cellx{0}", posInTwips); // Add position of the right border of each column
            }

            // reset current column count
            currentColumn = 0;
        }

        /// <summary>
        /// Adds a new cell to the current row
        /// 09May14 XN  88858 Added frommating of a cell
        /// </summary>
        /// <param name="value">Cell text</param>
        /// <param name="alignment">Alignment type for table</param>
        /// <param name="italic">If font is italic</param>
        /// <param name="fontColourIndex">Set font colour index</param>
        public void AddCell(string value, AlignmentType? alignment = null, bool? italic = null, int? fontColourIndex = null)
        {
            if (this.Columns.Count <= this.currentColumn)
                throw new ApplicationException("Exceeded maximum number of columns (call RTFTable.NewRow to start a new row)");

            // Get column info
            ColumnInfo column = this.Columns[this.currentColumn];

            // Set cell alignment
            switch(alignment ?? column.alignment)
            {
            case AlignmentType.Center: rtf.Append(@"\qc"); break;
            case AlignmentType.Right:  rtf.Append(@"\qr"); break;
            default: rtf.Append(@"\ql"); break;
            }

            // Add formatting
            if (italic ?? column.italic)
                rtf.Append(@"\i");
            if (fontColourIndex != null)
                rtf.Append(@"\cf" + fontColourIndex.ToString());

            // Add cell data
            rtf.AppendFormat(@"{{{0}}}\intbl\cell", value.RTFEscape());

            // clear formatting
            if (italic ?? column.italic)
                rtf.Append(@"\i0");
            if (fontColourIndex != null)
                rtf.Append(@"\cf0");

            // Update column index
            currentColumn++;
        }

        /// <summary>Call to end creating the report</summary>
        public void Close()
        {
            rtf.Append(@"\row}");
        }

        /// <summary>Return the RTF report string</summary>
        public override string ToString()
        {
 	        return rtf.ToString();
        }
        #endregion

        #region Public Static Methods
        /// <summary>
        /// Used to convert an PharmacyGridControl into an RTFTable.
        /// Use the PharmacyGridControl's MarshalRows client side method to get the data from the grid
        /// Then pass it to this method to convert to an RTF table.
        /// </summary>
        /// <param name="grid">Pharmacy grid data returned from client side method PharmacyGridControl.MarshalRows</param>
        /// <returns>PharmacyGridControl as RTF Table</returns>
        public static string ConvertPharmacyGrid(string grid)
        {
            RTFTable rtfTable = new RTFTable();

            // Split the table into rows (row separated by \x1E\r)
            string[] rows = grid.Split(new [] {"\x1E\r"}, StringSplitOptions.None);
            int rowCount = rows.Count();

            // Extract the table header
            string[] cols = rows[0].Split('\x1E');
            foreach(var col in cols)
            {
                // Table header cells have Header{us}WidthInPercentage{us}Alignment
                string[] fields = col.Split('\x1F');

                // Extract table header data
                string header = fields[0];
                int widthInPercentage = int.Parse(fields[1]);
                RTFTable.AlignmentType alignment;
                switch (fields[2].ToLower())
                {
                    case "center": alignment = RTFTable.AlignmentType.Center; break;
                    case "right":  alignment = RTFTable.AlignmentType.Right;  break;  
                    default:       alignment = RTFTable.AlignmentType.Left;   break;  
                }

                // Add column to report
                rtfTable.AddColumn(header.XMLUnescape(), widthInPercentage, alignment);
            }

            // Add cells to report
            for (int r = 1; r < rowCount; r++)
            {
                rtfTable.NewRow();
                foreach (string cell in rows[r].Split('\x1E'))
                    rtfTable.AddCell(cell.XMLUnescape());
            }

            rtfTable.Close();
            return rtfTable.ToString();
        }
        #endregion

        #region Private Methods
        /// <summary>Write column headers to the report</summary>
        private void WriteColumnHeaders()
        {
            // Ensure only written once
            this.writenColumnHeaders = true;

            // Set table font size
            rtf.AppendFormat(@"\fs{0}", this.FontSize);

            // Start of table
            rtf.Append(@"{\rtf1\ansi\deff0");

            // Start of header row
            NewRow();

            // Write column headers (bold, underlined, centre)
            if ( Columns.Any(c => !string.IsNullOrEmpty(c.text)) )  // 38034 XN 9Jul14 Only write bold if there is a header to write (bit of work around as can't find how to stop rest of table being bold and underlines so for Ward stock search and replace does report looks odd)
                rtf.Append(@"\b\ul");
            foreach (ColumnInfo col in Columns)
                rtf.AppendFormat(@"\qc{{{0}}}\intbl\cell", col.text.RTFEscape());
            rtf.Append(@"\b0\ul0");
        }

        /// <summary>Convert percentage of page width to Twips (minus margins)</summary>
        /// <param name="widthInPercentate">% of page</param>
        /// <returns>Column width in twips</returns>
        private int CalculatePercentageWidthToTwips(int widthInPercentate)
        {
            int pageWidthInmm             = (this.PageOrientation == Orientation.Portrait) ? this.PageWidthInmm : this.PageHeightInmm;
            double usablePageWidthInTwips = (TwipsPermm * pageWidthInmm) - (this.LeftMarginInTwips + this.RightMarginInTwips + cellSpacingInTwips);
            double colWidthInTwips        = (usablePageWidthInTwips * widthInPercentate) / 100.0;
            return (int)colWidthInTwips;
        }
        #endregion
    }
}
