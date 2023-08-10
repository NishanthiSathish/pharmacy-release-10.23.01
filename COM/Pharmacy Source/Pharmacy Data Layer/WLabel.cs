//===========================================================================
//
//							    WLabel.cs
//
//  Provides access to WLabel view.
//
//  WLabel view provides a collection of data for a label/dispensing.
//
//  Seems to be more of a RepeatDispensingPrescriptionLinkDispensing class, 
//  with a few WLabel fields linked in so may need to be sorted at some point.
//
//  But basicaly all sp return WLabel fields with the following linked in fields
//  [RepeatDispensingPrescriptionLinkDispensing].[PrescriptionID] as RequestID_Prescription
//  [RepeatDispensingPrescriptionLinkDispensing].[Quantity]       as RepeatDispensingQuantity
//  The only exception is LoadByRequestID which does not include the linked fields
//
//	Modification History:
//	15May09 AJK Written
//  12Apr12 AJK Added new fields
//  18Feb13 XN  Added field LastSavedDateTime (replaces LastDate) 40210
//  07May13 XN  63510 Repeat Disping error if PSO is null 
//  15Aug13 TH  70134 New fields added for DoC Repeat Dispensing
//  20May15 XN  Added GetByRequestID
//  26Apr16 XN  123082 Added Direction, and IsExtraLabel fields, and ToXmlHeap method
//  04May16 XN  123082 moved to BaseTable2
//  06May16 XN  123082 Added FinalVolume, InfusionTime, NodIssued, RxNodIssued, BatchNumber
//  02Aug16 XN  159413 Allowed to set SiteID, Text, removed writing rxDescriptionRaw as appear on aMM worksheet when should not
//===========================================================================
namespace ascribe.pharmacy.pharmacydatalayer
{
    using System;
    using System.Collections.Generic;
    using System.Data.SqlClient;
    using System.Linq;
    using System.Text;
    using System.Xml;
    using ascribe.pharmacy.basedatalayer;
    using ascribe.pharmacy.reportlayer;
    using ascribe.pharmacy.shared;

    /// <summary>
    /// Represents a row in the WLabel table
    /// </summary>
    public class WLabelRow : BaseRow
    {
        public int          RequestID                   { get { return (int)FieldToInt(RawRow["RequestID"]);                            } }
        public string       SisCode                     { get { return FieldToStr(RawRow["SisCode"]);                                   } }
        public int?         ContainerSize               { get { return FieldToInt(RawRow["ContainerSize"]);                             } }
        public string       IssType                     { get { return FieldToStr(RawRow["IssType"]);                                   } }
        public bool         ManualQuantity              { get { return (bool)FieldToBoolean(RawRow["ManualQuantity"]);                  } }
        public bool         PRN                         { get { return (bool)FieldToBoolean(RawRow["PRN"]);                             } }
        public bool         PatientsOwn                 { get { return (bool)FieldToBoolean(RawRow["PatientsOwn"]);                     } }
        public string       RepeatUnits                 { get { return FieldToStr(RawRow["RepeatUnits"]);                               } }
        public bool?        Day1Mon                     { get { return FieldToBoolean(RawRow["Day1Mon"]);                               } }
        public bool?        Day2Tue                     { get { return FieldToBoolean(RawRow["Day2Tue"]);                               } }
        public bool?        Day3Wed                     { get { return FieldToBoolean(RawRow["Day3Wed"]);                               } }
        public bool?        Day4Thu                     { get { return FieldToBoolean(RawRow["Day4Thu"]);                               } }
        public bool?        Day5Fri                     { get { return FieldToBoolean(RawRow["Day5Fri"]);                               } }
        public bool?        Day6Sat                     { get { return FieldToBoolean(RawRow["Day6Sat"]);                               } }
        public bool?        Day7Sun                     { get { return FieldToBoolean(RawRow["Day7Sun"]);                               } }
        public double       Dose1                       { get { return (double)FieldToDouble(RawRow["Dose1"]);                          } }
        public double       Dose2                       { get { return (double)FieldToDouble(RawRow["Dose2"]);                          } }
        public double       Dose3                       { get { return (double)FieldToDouble(RawRow["Dose3"]);                          } }
        public double       Dose4                       { get { return (double)FieldToDouble(RawRow["Dose4"]);                          } }
        public double       Dose5                       { get { return (double)FieldToDouble(RawRow["Dose5"]);                          } }
        public double       Dose6                       { get { return (double)FieldToDouble(RawRow["Dose6"]);                          } }
        public string       Times1                      { get { return FieldToStr(RawRow["Times1"]);                                    } }
        public string       Times2                      { get { return FieldToStr(RawRow["Times2"]);                                    } }
        public string       Times3                      { get { return FieldToStr(RawRow["Times3"]);                                    } }
        public string       Times4                      { get { return FieldToStr(RawRow["Times4"]);                                    } }
        public string       Times5                      { get { return FieldToStr(RawRow["Times5"]);                                    } }
        public string       Times6                      { get { return FieldToStr(RawRow["Times6"]);                                    } }
        public int          RequestID_Prescription      { get { return FieldToInt(RawRow["RequestID_Prescription"]).Value;              } }
        public double?      RepeatDispensingQuantity { get { return (double)FieldToDouble(RawRow["RepeatDispensingQuantity"]); } }
        
        public int SiteID 
        { 
            get { return FieldToInt(RawRow["SiteID"]).Value; }
            set { RawRow["SiteID"] = IntToField(value);      }  // 02Aug16 XN  159413 Added to allow printing label on AMM worksheet
        }
        
        public string Text                        
        { 
            get { return FieldToStr(RawRow["Text"], true);                      } 
            set { RawRow["Text"] = StrToField(value, emptyStrAsNullVal: false); }   // 02Aug16 XN  159413 Added to allow printing label on AMM worksheet
        }

        public string       Direction                   { get { return FieldToStr(RawRow["DrDirection"], trimString: true, nullVal: string.Empty); } }
        public string       WardCode                    { get { return FieldToStr(RawRow["WardCode"], true);                            } } // 12Apr12 AJK 31015 Added
        public string       ConsCode                    { get { return FieldToStr(RawRow["ConsCode"], true);                            } } // 12Apr12 AJK 31015 Added
        public bool?        PSO                         { get { return FieldToBoolean(RawRow["PSO"]);                                   } } // 7May13 XN 63510 Repeat Disping error if PSO is null (as did (bool)FieldToBoolean(RawRow["PSO"]) 13Mar13 TH  58703 
        public int?         RepeatTotal                 { get { return FieldToInt(RawRow["RepeatTotal"]);                         } } // 12Aug13 TH Added     
        public int?         RepeatRemaining             { get { return FieldToInt(RawRow["RepeatRemaining"]);                     } } // 12Aug13 TH Added 
        public DateTime?    PrescriptionExpiry          { get { return FieldToDateTime(RawRow["PrescriptionExpiry"]);                   } } // 12Aug13 TH Added 
        public bool         IsExtraLabel                { get { return FieldToBoolean(RawRow["ExtraLabel"]) ?? false;                   } }
        
        public decimal? LastQty 
        { 
            get { return FieldToDecimal(RawRow["LastQty"]);     } 
            set { RawRow["LastQty"] = DecimalToField(value);    } 
        }

        public DateTime? LastDate 
        { 
            get { return FieldStrDateToDateTime(RawRow["LastDate"], DateType.DDMMYYYY);                 } 
            set { RawRow["LastDate"] = DateTimeToFieldStrDate(value, string.Empty, DateType.DDMMYYYY);  } 
        }

        public double FinalVolume
        { 
            get { return FieldToDouble(RawRow["FinalVolume"]) ?? 0; }
            set { RawRow["FinalVolume"] = DoubleToField(value);     }
        }

        public int InfusionTime
        {
            get { return FieldToInt(RawRow["InfusionTime"]) ?? 0; }
            set { RawRow["InfusionTime"] = IntToField(value);     }
        }

        public string DispID 
        { 
            get { return FieldToStr(RawRow["DispID"], true); } 
            set { RawRow["DispID"] = StrToField(value);      }
        }

        public double NodIssued
        {
            get { return FieldToDouble(RawRow["NodIssued"]) ?? 0.0; } 
            set { RawRow["NodIssued"] = DoubleToField(value);       }
        }

        public double RxNodIssued
        {
            get { return FieldToDouble(RawRow["RxNodIssued"]) ?? 0.0; } 
            set { RawRow["RxNodIssued"] = DoubleToField(value);       }
        }

        /// <summary>NOT a batchnumber but more a count of number of times row is updated</summary>
        public int BatchNumber
        {
            get { return FieldToInt(RawRow["BatchNumber"]) ?? 0; } 
            set { RawRow["BatchNumber"] = IntToField(value);     }
        }

        public DateTime? LastSavedDateTime
        { 
            get { return FieldToDateTime(RawRow["LastSavedDateTime"]);  } 
            set { RawRow["LastSavedDateTime"] = DateTimeToField(value); }
        }

        /// <summary>
        /// db field [PrescriptionId]
        /// When saving will save to both PrescriptionId and BasePrescriptionId as they are the same
        /// </summary>
        public int PrescriptionNumber 
        {
            get { return FieldToInt(this.RawRow["PrescriptionId"]) ?? 0; }
            set 
            {
                this.RawRow["PrescriptionId"]     = IntToField(value);
                this.RawRow["BasePrescriptionId"] = IntToField(value);
            }
        }

        /// <summary>
        /// Converts patient data to xml heap
        /// Replacement for vb6 function FillHeapLabelText (but also need Episode.ToXmlHeap())
        /// 26Apr16 XN 123082
        /// </summary>
        /// <returns>Xml heap string</returns>
        public string ToXmlHeap()
        {
            int linesOfText = this.IsExtraLabel ? 15 : 5;
            string tempStr;
            double? tempDbl;

            // Setup xml writer 
            var settings  = new XmlWriterSettings();
            settings.OmitXmlDeclaration = true;
            settings.Indent             = true;
            settings.NewLineOnAttributes= true;
            settings.ConformanceLevel   = ConformanceLevel.Fragment;

            // Create data
            StringBuilder xml = new StringBuilder();
            using (XmlWriter xmlWriter = XmlWriter.Create(xml, settings))
            {
                xmlWriter.WriteStartElement("Heap");

                string description = this.Text.Split('\n').Take(linesOfText).ToCSVString(" ");
                //xmlWriter.WriteAttributeString("rxDescriptionRaw", description);  02Aug16 XN  159413 removed writing rxDescriptionRaw as appear on aMM worksheet when should not
                xmlWriter.WriteAttributeString("rxDescriptionRaw", string.Empty);
                xmlWriter.WriteAttributeString("lbldescraw", description);

                string direction = this.Direction.Split('\n').Take(linesOfText).ToCSVString(" ");
                xmlWriter.WriteAttributeString("rxDirectionsRaw", direction);

                for (int n = 1; n <= 9; n++)
                {
                    string section = "rxDescriptionSized" + n;
                    if (WConfiguration.Load<string>(this.SiteID, "D|TERMINAL", section, "StdLblFontName", null, true) != null)
                    {
                        int   desiredLines = WConfiguration.Load<int>  (this.SiteID, "D|TERMINAL", section, "StdLblDescriptionLines",   1, true);
                        float fontSize     = WConfiguration.Load<float>(this.SiteID, "D|TERMINAL", section, "StdLblFontSize",         12f, true);
                        xmlWriter.WriteAttributeString("rxDescriptionSized", string.Format("{{\fs{0} {1}}}", fontSize, this.FormatNonStandardLabel(description, section, desiredLines)));
                    }

                    section = "rxDirectionsSized" + n;
                    if (WConfiguration.Load<string>(this.SiteID, "D|TERMINAL", section, "StdLblFontName", null, true) != null)
                    {
                        int   desiredLines = WConfiguration.Load<int>  (this.SiteID, "D|TERMINAL", section, "StdLblDirectionLines",   1, true);
                        float fontSize     = WConfiguration.Load<float>(this.SiteID, "D|TERMINAL", section, "StdLblFontSize",       12f, true);
                        xmlWriter.WriteAttributeString("rxDirectionsSized", string.Format("{{\fs{0} {1}}}", fontSize, this.FormatNonStandardLabel(direction, section, desiredLines)));
                    }
                }
                xmlWriter.WriteEndElement();

                xmlWriter.Flush();
                xmlWriter.Close();
            }

            return xml.ToString();
        }

        /// <summary>
        /// Replacement for vb6 function FormatTextNonStd amd FormatLabelNonStd
        /// Parses and shrinks the label text to fit
        /// 26Apr16 XN 123082
        /// </summary>
        /// <param name="text">Label text</param>
        /// <param name="section">WConfigration section to use</param>
        /// <param name="maxLines">Max number of lines</param>
        /// <returns>Returns label text</returns>
        private string FormatNonStandardLabel(string text, string section, int maxLines)
        {
            const int fontCount = 9;
            var lineBreak = new string[] { "\r\n" };
            string fontName = WConfiguration.LoadAndCache<string>(this.SiteID, "D|TERMINAL", section, "StdLblFontName", "Courier New", false);
            int widthInTwips = WConfiguration.LoadAndCache<int>(this.SiteID, "D|TERMINAL", section, "StdLblWidthTwips", 2880, false);
            float fontSize;
            int maxChars;
            int lineCount = 0;

            // Convert CR, LF or CRLF to CRLF
            // Convert CRCR, LFLF, or CRLFCRLF to CRLFCRLF
            text = text.Replace("\r\n", "\x0\x1").Replace("\n", "\x0").Replace("\r", "\x0").Replace("\x0\x1", "\r\n").Replace("\x0", "\r\n");

            lineCount = text.Split(lineBreak, StringSplitOptions.None).Length;

            // Progressively reduce font size
            for (int fontNumber = 1; fontNumber < fontCount && lineCount > maxLines; fontNumber++)
            {
                fontSize = WConfiguration.LoadAndCache<float>(this.SiteID, "D|TERMINAL", section, "StdLblFontSize" + fontNumber, 9.75f, false);
                maxChars = WConfiguration.LoadAndCache<int>  (this.SiteID, "D|TERMINAL", section, "StdLblMaxChars" + fontNumber,    36, false);
                RTFUtils.FitTextToRectangle(ref text, lineBreak[0], fontName, fontSize, widthInTwips, maxChars);
                lineCount = text.Split(lineBreak, StringSplitOptions.None).Length;
            }

            if (lineCount > maxLines)
            {
                // Failed to fit them in so remove all line feeds & retry
                text = text.Replace("\r\n", " ");

                // Progressively reduce font size
                for (int fontNumber = 1; fontNumber < fontCount && lineCount > maxLines; fontNumber++)
                {
                    fontSize = WConfiguration.LoadAndCache<float>(this.SiteID, "D|TERMINAL", section, "StdLblFontSize" + fontNumber, 9.75f, false);
                    maxChars = WConfiguration.LoadAndCache<int>  (this.SiteID, "D|TERMINAL", section, "StdLblMaxChars" + fontNumber,    36, false);
                    RTFUtils.FitTextToRectangle(ref text, lineBreak[0], fontName, fontSize, widthInTwips, maxChars);
                    lineCount = text.Split(lineBreak, StringSplitOptions.None).Length;
                }
            }

            return text;
        }
    }

    /// <summary>
    /// Provides column information for WLabel
    /// </summary>
    public class WLabelColumnInfo : BaseColumnInfo
    {
        public WLabelColumnInfo() : base("WLabel") { }

        public int DispIDLength { get { return this.FindColumnByName("DispID").Length; } }
    }

    /// <summary>
    /// Represents the WLabel table
    /// </summary>
    public class WLabel : BaseTable2<WLabelRow, WLabelColumnInfo>
    {
        /// <summary>Constructor</summary>
        public WLabel() : base("WLabel") { }

        public void LoadUncancelledByRequestID(int requestID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("RequestID",        requestID);
            this.LoadBySP("pWLabelUncancelledByRequestID", parameters);
        }

        /// <summary>
        /// Loads the label information for all repeat dispensings by episode and site
        /// </summary>
        /// <param name="episodeID"></param>
        /// <param name="siteID"></param>
        public void LoadRepeatDispensingsByEpisodeID(int episodeID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("EpisodeID",        episodeID);
            this.LoadBySP("pRepeatDispensingsByEpisodeID", parameters);
        }

        public void LoadRepeatDispensingByDispensingID(int dispensingID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("DispensingID",     dispensingID);
            this.LoadBySP("pRepeatDispensingByDispensingID", parameters);
        }

        /// <summary>
        /// Load only items from WLabel table by request ID (should only be 1).
        /// The sp does not link in any repeat dispensing fields and will return null.
        /// </summary>
        /// <param name="requestID">request ID of the WLabel</param>
        public void LoadByRequestID(int requestID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add("CurrentSessionID", SessionInfo.SessionID);
            parameters.Add("RequestID",        requestID);
            this.LoadBySP("pWLabelByRequestID", parameters);
        }

        /// <summary>Returns first WLabel row with the specified ID (or null) XN 20May15</summary>
        /// <param name="requestID">Request ID</param>
        /// <returns>WLabel row or null</returns>
        public static WLabelRow GetByRequestID(int requestID)
        {
            WLabel label = new WLabel();
            label.LoadByRequestID(requestID);
            return label.FirstOrDefault();
        }
    }
}
