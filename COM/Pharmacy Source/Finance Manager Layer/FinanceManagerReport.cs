//===========================================================================
//
//						    FinanceManagerReport.cs
//
//  This class holds all business logic help generate FM reports to display all
//  from the Stock Account, Account, and GRNI sheets
//
//  The xml data for the report is stored in session attribute PharmacyGeneralReportAttribute.
//  The XML data is in form
//      <FMPrintData>
//          <Title title="..." />
//          <Setting Line1="..." Line2="..." Line2="..." ... Drug="..." />
//          <Info hospname="..." today="..." />
//          <Data Table="..." />
//          <Warnings Message="..." />
//      </FMPrintData>
//
//  Colour
//  ------
//  As the reports normally has colour the class will do it's best to match it 
//  to an HEdit 16 colour value, however this does not always give the best result.
//  So it is possible to assign a web colour value to a HEdit colour using ColourMapInfo
//  and the method AddColourMaps
//  This maps a web colour to a HEdit colour table index (see ConvertToHEditColorIndex
//  for index values), and a HEdit shading value normaly in %.
//  e.g. The following means whenever RGB R:86 G:86 B:82 is received by the report it
//  will use the colour table index 14 with shading of 80%
//      colourMapInfo.webColor          = Color.FromArgb(86, 86, 82);
//      colourMapInfo.colorTableIndex   = 14;
//      colourMapInfo.shadingPercentage = 80;
//  
//  Report Data
//  -----------
//  As well as title and settings the reports have room for a table this is encoded
//  by the from MarshalRows in ICW_FinanceManager.js, and is the converted into an
//  RTF table using GenerateRTFTable
//
//  Usage:
//  List<FinanceManagerReport.ColourMapInfo> colorMap = new List<FinanceManagerReport.ColourMapInfo>();
//  colorMap.Add(new FinanceManagerReport.ColourMapInfo(){ webColor=Color.FromArgb(86, 86, 82), colorTableIndex=14 /* Teal */, shadingPercentage=100}); 
//
//  FinanceManagerReport report = new FinanceManagerReport(title, hospitalName, setting, drug, grid, warning);
//  report.AddColourMaps(colorMap);
//  report.Save();
//      
//	Modification History:
//	27Sep13 XN  Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Web.UI.WebControls;
using System.Xml;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.financemanagerlayer
{
    public class FinanceManagerReport
    {
        #region Data Types
        /// <summary>Used to map a web colour to a HEdit colour table index, and shading</summary>
        public struct ColourMapInfo
        {
            /// <summary>Colour from the web page</summary>
            public Color webColor;
            
            /// <summary>RTF colour table index</summary>
            public int colorTableIndex;

            /// <summary>Sadeing value as Percentage</summary>
            public int shadingPercentage;
        }
        #endregion

        #region Constants
        /// <summary>Number of Twips in a mm</summary>
        protected const double TwipsPermm = 56.6929134;

        /// <summary>RTF cell spacing in Twips</summary>
        protected const int CellSpacingInTwips = 50;

        /// <summary>Margin between left side of page and table</summary>
        protected const int LeftMarginInTwips = 250;

        /// <summary>Margin between right side of page and table</summary>
        protected const int RightMarginInTwips = 1000;

        /// <summary>Height of the page in mm (default is A4 at 297mm)</summary>
        protected const int PageHeightInmm = 297;

        /// <summary>Width of the page in mm (default is A4 at 210mm)</summary>
        protected const int PageWidthInmm = 210;

        /// <summary>Number of rows allowed on first page</summary>
        protected const int NumberOfRowsOnFirstPage = 25;

        /// <summary>Number of rows allowed on other pages (excluding headers)</summary>
        protected const int NumberOfRowsOnPage = 30;
        #endregion

        #region Member Variables
        /// <summary>Page orientation default is Landscpae</summary>
        private PageOrientation pageOrientation = PageOrientation.Landscape;

        /// <summary>colour map</summary>
        private List<ColourMapInfo> colourMap = new List<ColourMapInfo>();

        // Data passed in
        private string title;
        private string hospitalName;
        private string settingInfo;
        private string drug;
        private string reportData;
        private string warning;
        #endregion

        #region Public Methods
        /// <param name="title">Report title</param>
        /// <param name="hospitalName">Report hopsital name</param>
        /// <param name="settingInfo">cr separated list of settings displayed under the title</param>
        /// <param name="drug">Drug name (used by stock account report)</param>
        /// <param name="reportData">Report table (encoded)</param>
        /// <param name="warning">Warning message</param>
        public FinanceManagerReport(string title, string hospitalName, string settingInfo, string drug, string reportData, string warning)
        {
            this.title          = title;
            this.hospitalName   = hospitalName;
            this.settingInfo    = settingInfo;
            this.drug           = drug;
            this.reportData     = reportData;
            this.warning        = warning;
        }

        /// <summary>Saves the report xml to session attribute PharmacyGeneralReportAttribute</summary>
        public void Save()
        {
            DateTime now = DateTime.Now;

            // Setup xml writer 
            XmlWriterSettings settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("FMPrintData");

                // Report title
                xmlWriter.WriteStartElement("Title");
                xmlWriter.WriteAttributeString("title", title.Trim());
                xmlWriter.WriteEndElement();

                // Setting
                xmlWriter.WriteStartElement("Setting");
                string[] settingLines = settingInfo.Split(new [] {"\r"}, StringSplitOptions.RemoveEmptyEntries);
                for(int l = 0; l < settingLines.Length; l++)
                    xmlWriter.WriteAttributeString("Line" + (l + 1).ToString(), settingLines[l]);
                xmlWriter.WriteAttributeString("Drug", drug);
                xmlWriter.WriteEndElement();

                // Hospital name
                xmlWriter.WriteStartElement("Info");
                xmlWriter.WriteAttributeString("hospname", hospitalName);
                xmlWriter.WriteAttributeString("today", now.ToPharmacyDateString());
                xmlWriter.WriteEndElement();

                // Grid data (including filter if specified)
                xmlWriter.WriteStartElement("Data");
                xmlWriter.WriteAttributeString("Table", GenerateRTFTable(reportData));
                xmlWriter.WriteEndElement();

                // Warnings at bottom
                xmlWriter.WriteStartElement("Warnings");
                xmlWriter.WriteAttributeString("Message", warning.Replace("\n", " "));
                xmlWriter.WriteEndElement();

                xmlWriter.WriteEndElement();

                xmlWriter.Close();
            }

            // Save
            PharmacyDataCache.SaveToDBSession("PharmacyGeneralReportAttribute", xml.ToString());
        }
        
        /// <summary>Adds colours to the colour map</summary>
        public void AddColourMaps(IEnumerable<ColourMapInfo> colourMap)
        {
            this.colourMap.AddRange(colourMap);
        }
        #endregion

        #region Private Methods
        /// <summary>
        /// Encoded form of a table created using MarshalRows in ICW_FinanceManager.js
        /// This will be in the form
        ///     {h - header row\d - data row for row 1}rs
        ///     {width of cell 1 in pixels}fs
        ///     {text alignment of cell 1}fs
        ///     {i -italic and\or b - bold of cell 1}fs
        ///     {border left width of cell 1}fs
        ///     {border left colour of cell 1}fs
        ///     {border right width of cell 1}fs
        ///     {border right colour of cell 1}fs
        ///     {background colour of cell 1}fs
        ///     {font colour of cell 1}fs
        ///     {cell 1 text}fsrs
        ///     - repeats cell data for rows
        ///     - repeats row data separated by cr
        ///     
        /// fs - Field Separator char=31   
        /// rs - Record Separator char=30    
        /// cs - Record Separator char=13    
        /// </summary>
        /// <returns>RTF of table</returns>
        private string GenerateRTFTable(string reportData)
        {
            WebColorConverter webColorConverter = new WebColorConverter();
            StringBuilder rtf           = new StringBuilder();
            StringBuilder rtfHeaderRows = new StringBuilder();
            StringBuilder rtfColoumns   = new StringBuilder();
            StringBuilder rtfCells      = new StringBuilder();
            char[] recordSeparator = new char[] { '\x1E' };
            char[] fieldSeparator  = new char[] { '\x1F' };
            int rowsOnCurrentPage = 0;
            int pageCount = 0;
            double widthAsPercentage;

            // Calcualte page width in twips
            int pageWidthInmm = pageOrientation == PageOrientation.Portrait ? PageWidthInmm : PageHeightInmm;
            double usablePageWidthInTwips = (TwipsPermm * pageWidthInmm) - (LeftMarginInTwips + RightMarginInTwips + CellSpacingInTwips);

            // Get rows
            string[] rows = reportData.Split(new [] {"\x1E\r"}, StringSplitOptions.RemoveEmptyEntries);

            // get table total width in pixels (for top row get all records, and the first field is the cell width in pixels
            int tableTotalWidthInPixels = 0;
            foreach(string s in rows[0].Split(recordSeparator).Skip(1))
            {
                string[] fields = s.Split(fieldSeparator, 10);
                tableTotalWidthInPixels += int.Parse(fields[0]);
                tableTotalWidthInPixels += int.Parse(fields[3].Replace("px", string.Empty)) / 2;
                tableTotalWidthInPixels += int.Parse(fields[5].Replace("px", string.Empty)) / 2;
            }

            // Add each row to rtf
            for (int r = 0; r < rows.Length; r++)
            {
                rtfColoumns.Clear();
                rtfCells.Clear();

                // Get row type header\data
                string[] rowInfo = rows[r].Split(recordSeparator, 2);         
                if (rowInfo.Length != 2)
                    continue;
                if (rowInfo[0] != "h" && rtfHeaderRows.Length == 0)
                    rtfHeaderRows.Append(rtf);

                // If reached max rows for page add page break
                // Done up here rather than end to prevent having blank pages
                if ((pageCount == 0 && rowsOnCurrentPage > NumberOfRowsOnFirstPage) || rowsOnCurrentPage > NumberOfRowsOnPage)
                {
                    rtf.Append(@"\page");
                    rtf.Append(rtfHeaderRows);

                    rowsOnCurrentPage = 0;
                    pageCount++;
                }
    
                // Add new row setting cell spacing (trgaph) and left margin (trleft)
                int posInTwips = LeftMarginInTwips;
                rtf.AppendFormat(@"\trowd\trgaph{0}\trleft{1}", CellSpacingInTwips, posInTwips);    

                string[] cells = rowInfo[1].Split(recordSeparator);
                for (int c = 0; c < cells.Length; c++)
                {
                    string[] fields = cells[c].Split(fieldSeparator, 10);

                    int             widthInPixel            = int.Parse(fields[0]);
                    string          alignment               = fields[1];
                    bool            italic                  = fields[2].Contains('i');
                    bool            bold                    = fields[2].Contains('b');
                    int             borderLeftWidthInPixel  = int.Parse(fields[3].Replace("px", string.Empty));
                    ColourMapInfo?  borderLeftColour        = GetRTFColor ( (Color)webColorConverter.ConvertFromString(fields[4]) );
                    int             borderRightWidthInPixel = int.Parse(fields[5].Replace("px", string.Empty));
                    ColourMapInfo?  borderRightColour       = GetRTFColor ( (Color)webColorConverter.ConvertFromString(fields[6]) );
                    ColourMapInfo?  backgroundColour        = GetRTFColor ( (Color)webColorConverter.ConvertFromString(fields[7]) );
                    ColourMapInfo?  forgroundColour         = GetRTFColor ( (Color)webColorConverter.ConvertFromString(fields[8]) );

                    // Create left border
                    if (borderLeftWidthInPixel > 0)
                    {
                        widthAsPercentage = (double)borderLeftWidthInPixel / (double)tableTotalWidthInPixels;
                        posInTwips += (int)(usablePageWidthInTwips * widthAsPercentage / 2.0);
                        rtfColoumns.AppendFormat(@"\clcfpat{0}\clshdng{1}\cellx{2}",(int)borderLeftColour.Value.colorTableIndex, (int)(borderLeftColour.Value.shadingPercentage * 100f), posInTwips);
                        rtfCells.Append(@"{{ }}\intbl\cell");
                    }

                    // Add cell background shading
                    if (backgroundColour != null)
                        rtfColoumns.AppendFormat(@"\clcfpat{0}\clshdng{1}",(int)backgroundColour.Value.colorTableIndex, (int)(backgroundColour.Value.shadingPercentage * 100f));
                    
                    // Calcaulte and set cell position in twips
                    widthAsPercentage = (double)widthInPixel / (double)tableTotalWidthInPixels;
                    posInTwips += (int)(usablePageWidthInTwips * widthAsPercentage);
                    rtfColoumns.AppendFormat(@"\cellx{0}", posInTwips); 

                    // Set cell alignment
                    switch(alignment.ToLower())
                    {
                    case "center": rtfCells.Append(@"\qc"); break;
                    case "right":  rtfCells.Append(@"\qr"); break;
                    default:       rtfCells.Append(@"\ql"); break;
                    }

                    // Add formatting
                    rtfCells.Append(@"{");

                    if (italic)
                        rtfCells.Append(@"\i");
                    if (bold)
                        rtfCells.Append(@"\b");
                    if (forgroundColour != null)
                        rtfCells.AppendFormat(@"\cf{0}", (int)forgroundColour.Value.colorTableIndex);

                    // Add cell data
                    string data = fields[9].Replace("&nbsp;", " ").Replace("<BR />", " ").Replace(@"\", @"\\").TrimEnd();
                    rtfCells.AppendFormat(@" {0}}}\intbl\cell", data);
                
                    // Create right border
                    if (borderRightWidthInPixel > 0)
                    {
                        widthAsPercentage = (double)borderRightWidthInPixel / (double)tableTotalWidthInPixels;
                        posInTwips += (int)(usablePageWidthInTwips * widthAsPercentage / 2.0);
                        rtfColoumns.AppendFormat(@"\clcfpat{0}\clshdng{1}\cellx{2}",(int)borderRightColour.Value.colorTableIndex, (int)(borderRightColour.Value.shadingPercentage * 100f), posInTwips);
                        rtfCells.Append(@"{{ }}\intbl\cell");
                    }
                }


                rtfCells.Append(@"\row");

                // As have to do column width and shading at start the other info
                // build up test for column info, and cells then apped in correct order to rtf doc
                rtf.Append(rtfColoumns);
                rtf.Append(rtfCells);

                rowsOnCurrentPage++;
            }

            return rtf.ToString();
        }

        /// <summary>Gets the colour map value for the web color</summary>
        private ColourMapInfo? GetRTFColor(Color? color)
        {
            if (color == null)
                return null;

            ColourMapInfo match;
            var matches = this.colourMap.Where(c => c.webColor.R == color.Value.R && 
                                                    c.webColor.G == color.Value.G && 
                                                    c.webColor.B == color.Value.B );
            if (matches.Any())
                match = matches.First();
            else
            {
                match = ConvertToHEditColorIndex(color.Value);
                this.colourMap.Add(match);
            }

            return match; 
        }

        /// <summary>
        /// Converts a color to a HEdit color index, and shading
        /// HEdit color index is the index into the HEdit RTF color table
        /// The shading can only be applied to background colours and is a % from 0 to 100 
        /// </summary>
        /// <param name="color">Color to convert</param>
        public static ColourMapInfo ConvertToHEditColorIndex(Color color)
        {
            System.Diagnostics.Debug.WriteLine(color.ToString());            

            // HEdit colours
            Color[] colors = new [] { Color.FromArgb(   0,   0,   0),   // 0
                                      Color.FromArgb(   0,   0, 255),   // 1
                                      Color.FromArgb(   0, 255, 255),   // 2
                                      Color.FromArgb(   0, 255,   0),   // 3
                                      Color.FromArgb( 255,   0, 255),   // 4
                                      Color.FromArgb( 255,   0,   0),   // 5
                                      Color.FromArgb( 255, 255,   0),   // 6
                                      Color.FromArgb( 255, 255, 255),   // 7
                                      Color.FromArgb(   0,   0, 127),   // 8
                                      Color.FromArgb(   0, 127, 127),   // 9
                                      Color.FromArgb(   0, 127,   0),   // 10
                                      Color.FromArgb( 127,   0, 127),   // 11
                                      Color.FromArgb( 127,   0,   0),   // 12
                                      Color.FromArgb( 127, 127,   0),   // 13
                                      Color.FromArgb( 127, 127, 127),   // 14
                                      Color.FromArgb( 192, 192, 192) }; // 15

            ColourMapInfo heditColor = new ColourMapInfo();
            heditColor.webColor = color;

            double minDiff  = double.MaxValue;
            float colorHue         = color.GetHue();
            float colorSaturation  = color.GetSaturation();
            float colorBrightness  = color.GetBrightness();

            // Find the closest match colour
            for (int c = 0; c < colors.Length; c++)
            {
                double diff = Math.Pow(colors[c].GetHue()       - colorHue,        2) + 
                              Math.Pow(colors[c].GetSaturation()- colorSaturation, 2) + 
                              Math.Pow(colors[c].GetBrightness()- colorBrightness, 2);
                if (diff < minDiff)
                {
                    minDiff                    = diff;
                    heditColor.colorTableIndex = c;
                }
            }


            // Find best shading to apply to the colour to get even better match
            Color bestColour = colors[heditColor.colorTableIndex];
            for (int a = 0; a < 100; a++)
            {                
                Color temp = Color.FromArgb(bestColour.R + ((255 - bestColour.R) * (100 - a) / 100), 
                                            bestColour.G + ((255 - bestColour.G) * (100 - a) / 100), 
                                            bestColour.B + ((255 - bestColour.B) * (100 - a) / 100));
                double diff = Math.Pow(temp.GetHue() - colorHue, 2) + Math.Pow(temp.GetSaturation() - colorSaturation, 2) + Math.Pow(temp.GetBrightness() - colorBrightness, 2);
                if (diff < minDiff)
                {
                    minDiff                      = diff;
                    heditColor.shadingPercentage = a;
                }
            }

            return heditColor;
        }
        #endregion
    }
}
