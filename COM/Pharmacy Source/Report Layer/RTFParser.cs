//===========================================================================
//
//						            RTFParser.cs
//
//  Used to parse rtf text with xml (as replacement to the vb6 RTF parser)
//
//  It will do a direct string replacement for any rtf elements in the 
//  format [sCode], with XML attribute <Heap ... sCode='SUP1' ... />
//
//  It also performs the the old vb6 opertions like 
//      [27] with Escape char
//      [80x ] or [80x32] with 80 spaces
//      [40x-] with 40 dashes
//
//  To escape bracket use [[ and ]]
//
//  Will also automatically parse rtf tag names
//      [hospname1]
//      [hospname2]
//      [hospname3]
//      [SiteNumber]
//      [UserID]
//      [UserName]
//      [today]
//      [TimeNow]
//      [terminal]
//  
//  Usage
//  strnig rtf = File.ReadAllText("C:\SupplierInterfaceFile.rtf");
//  RTFParser parser = new RTFParser(rtf);
//
//  WSupplier2Row supplier = WSupplier2.GetBySiteIDAndCode(15, "SUPP1");
//  string xml = XMLHeap.SupplierInfo( supplier );
//
//  parser.ParseXML(xml);
//  File.WriteAllText("C:\SupplierRTF.rtf", parser.ToString() );
//  
//	Modification History:
//	05Nov14 XN  Written 43318
//  14Apr16 XN  ParseXML decoded the xml name so handles things like tCost\100 123082
//  26Apr16 XN  Made Parse case insensitive, added standard parse chars to ToString 123082
//  02Aug16 XN  159413 Added parsing of the extra RTF chars from the config
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Xml;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.reportlayer
{
    /// <summary>Used to parse rtf text with xml (as replacement to the vb6 RTF parser)</summary>
    public class RTFParser
    {
        #region Member Variables
        /// <summary>Non preintable character used to represent [[ escape character</summary>
        private static readonly char escapeOpenBraceHidenChar = (char)0x01;        

        /// <summary>Non preintable character used to represent [[ escape character</summary>
        private static readonly char escapeCloseBraceHidenChar = (char)0x02;        

        /// <summary>RTF file string</summary>
        private StringBuilder rtf = new StringBuilder();
        #endregion

        #region Public Methods
        public void Read(string rtftext)
        {
            rtf.Length = 0;
            rtf.Append(rtftext);
            rtf.Replace("[[", escapeOpenBraceHidenChar.ToString() );
            rtf.Replace("]]", escapeCloseBraceHidenChar.ToString());
        }

        /// <summary>Parse the XML</summary>
        public void ParseXML(string xml)
        {
            // Setup string as XML fragment
            XmlReaderSettings settings = new XmlReaderSettings();
            settings.ConformanceLevel = ConformanceLevel.Fragment;

            // Read xml string
            using (XmlReader reader = XmlReader.Create(new StringReader(xml), settings))
            {
                if (reader.Read() && reader.HasAttributes)  // Read heap attribute
                {
                    while (reader.MoveToNextAttribute())
                        Parse(XmlConvert.DecodeName(reader.Name), reader.Value);
                        //Parse(reader.Name, reader.Value);  14Apr16 XN so handles things like tCost\100 123082
                }
            }
        }

        /// <summary>
        /// Parse the tag name, and value (tagName is case insensitive)
        /// 26Apr16 XN 123082 made tagName case insensitive
        /// </summary>
        public void Parse(string tagName, string value)
        {
            tagName = "[" + tagName + "]";

            // Find the first tagName is in the string
            string temp = rtf.ToString();   
            int startPos = temp.IndexOf(tagName, 0, StringComparison.InvariantCultureIgnoreCase);

            while (startPos != -1)
            {
                // Find the end tag
                int endPos = temp.IndexOf("]", startPos);

                temp = null;

                // Replace the tag with the value
                rtf.Remove(startPos, endPos - startPos + 1); 
                if (!string.IsNullOrWhiteSpace(value))
                    rtf.Insert(startPos, value);

                // Find the next tag name
                temp = rtf.ToString();  // this is believed to be fast as StringBuilder.ToString just returns a pointer
                startPos = temp.IndexOf(tagName, 0, StringComparison.InvariantCultureIgnoreCase);
            }
        }
        
        /// <summary>Returned the parsed RTF file as a string</summary>
        public override string ToString()
        {
            this.ParseStandardItems();

            StringBuilder temp = new StringBuilder(rtf.ToString());
            ParseCtrlChars(temp);

            temp.Replace(escapeOpenBraceHidenChar.ToString(), "[");
            temp.Replace(escapeCloseBraceHidenChar.ToString(),"]");
            return temp.ToString();
        }
        #endregion 

        #region Private Methods
        /// <summary>
        /// Will perform operations like replace 
        ///     [27] with Escape char
        ///     [80x ] or [80x32] with 80 spaces
        ///     [40x-] with 40 dashes
        /// Replacement for CoreLog.bas ParseCtrlChars
        ///     
        /// Note: will not handle [40x[dash]] as 40 dashes
        /// 02Aug16 XN 159413 Added parsing of the extra RTF chars from the config
        /// </summary>
        private void ParseCtrlChars(StringBuilder temp)
        {
            int pos = -1;

            int siteID = SessionInfo.HasSite ? SessionInfo.SiteID : Database.ExecuteSQLScalar<int>("SELECT MIN(SiteID) FROM WConfiguration WHERE Section='RTF' AND Category='D|PRINTER'");

            // Added parsing of the extra RTF chars from the config 02Aug16 XN  159413
            GenericTable2 config = new GenericTable2();
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("@SiteID", siteID);
            config.LoadBySQL("SELECT [Key], Value FROM WConfiguration WHERE Section='RTF' AND Category='D|PRINTER' AND SiteID=@SiteID", parameters);
            
            Dictionary<string,string> rftConfigDictonary = new Dictionary<string,string>(config.Count);

            foreach(var c in config)
            {
                var value = c.RawRow["Value"].ToString();
                int startPos     = value.StartsWith("\"") ? 1 : 0;
                int endPosOffset = value.EndsWith  ("\"") ? 1 : 0;
                rftConfigDictonary[c.RawRow["Key"].ToString().ToUpper()] = value.Substring(startPos, value.Length - startPos - endPosOffset);
            }

            do
            {
                // Find start index
                int startIndex = -1;
                for (pos++; pos < temp.Length; pos++)
                {
                    if (temp[pos] == '[')
                    {
                        startIndex = pos;
                        break;
                    }
                }

                // Find end index
                int endIndex = -1;
                for (pos++; pos < temp.Length; pos++)
                {
                    if (temp[pos] == ']')
                    {
                        endIndex = pos;
                        break;
                    }
                }

                int count = endIndex - startIndex;
                if (startIndex >= 0 && endIndex >= 0 && (count < 1000))
                {
                    // Get the stuff in the middle of [ ]
                    char[] m = new char[count - 1];
                    temp.CopyTo(startIndex + 1, m, 0, count - 1);
                    var str = (new string(m));
                    int repeats = 1;
                    string charVal = null;

                    if (!rftConfigDictonary.TryGetValue(str.ToUpper(), out charVal))
                    {
                        // Split around [...x...] when doing multiples
                        string[] dif = str.Split(new [] { 'X', 'x'}, 2);
                        int val;

                        if (dif.Length == 1)
                        {
                            // not multiples so doing something like [27] 
                            if ( int.TryParse(dif[0], out val) && val >= 0 && val <= 255 )
                                charVal = Char.ConvertFromUtf32(val);
                        }
                        else 
                        {
                            // Get repeats
                            if ( int.TryParse(dif[0], out repeats) && repeats > 0 && repeats <= 32767 )
                            {
                                // convert value [<number of chars>x<char>] or [<number of chars>x<ASCII value>]
                                if ( int.TryParse(dif[1], out val) )
                                    charVal = Char.ConvertFromUtf32(val);
                                else
                                    charVal = dif[1];
                            }
                        }
                    }

                    // if all okay now replace
                    if (charVal != null)
                    {
                        temp.Remove(startIndex, count + 1);
                        for (int c = 0; c < repeats; c++)
                            temp.Insert(startIndex, charVal);
                    }

                    pos = startIndex;
                }
            } while (pos < temp.Length);
        }
        
        /// <summary>
        /// Parses the standard print tags names
        ///     [hospname1]
        ///     [hospname2]
        ///     [hospname3]
        ///     [SiteNumber]
        ///     [UserID]
        ///     [UserName]
        ///     [today]
        ///     [TimeNow]
        ///     [terminal]
        /// 26Apr16 XN Added 123082
        /// </summary>
        private void ParseStandardItems()
        {
            DateTime now = DateTime.Now;

            if (SessionInfo.HasSite)
            {
                HospitalDetails hospitalDetails = new HospitalDetails();
                hospitalDetails.LoadBySiteID(SessionInfo.SiteID);

                this.Parse("hospname1", hospitalDetails.FullName);          // Full name
                this.Parse("hospname2", hospitalDetails.AccountName);       // Account Name
                this.Parse("hospname3", hospitalDetails.AbbreviatedName);   // Abbreviated Name
                this.Parse("SiteNumber", SessionInfo.SiteNumber.ToString("000"));
            }

            this.Parse("UserID",   SessionInfo.UserInitials);
            //this.Parse("UserName", SessionInfo.Username    );     Used full name 18May16 XN 123082
            this.Parse("UserName", SessionInfo.GetUserFullname());
            this.Parse("today",    now.ToPharmacyDateString());
            this.Parse("TimeNow",  now.ToPharmacyTimeString());
            this.Parse("terminal", SessionInfo.Terminal.SafeSubstring(0, 15));
        }
        #endregion 
    }
}
