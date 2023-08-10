using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;

namespace TextControlEditorPharmacyClient.FileHandling
{
    public class FontStyleMerger
    {
        /// <summary>
        /// Adding a font style to the top RTF and making corresponding chnages to existing RTFs
        /// </summary>
        /// <param name="RTFFile"></param>
        /// <returns></returns>
        public string MergeFontStyleinRTF(string RTFFile)
        {
            string modifiedString = RTFFile;
            var rtfSeparatorIndexes = Regex.Matches(RTFFile, @"\\rtf1\\").Cast<Match>().Select(m => m.Index)
              .ToList();
            if (rtfSeparatorIndexes.Count > 1)
            {
                rtfSeparatorIndexes[0] = 0;
                rtfSeparatorIndexes.Add(RTFFile.Length);
                List<string> separateRtfs = new List<string>();
                List<string> listDestStringRtfs = new List<string>();

                for (int i = 0; i < rtfSeparatorIndexes.Count - 1; i++)
                {
                    separateRtfs.Add(RTFFile.Substring(rtfSeparatorIndexes[i], rtfSeparatorIndexes[i + 1] - rtfSeparatorIndexes[i]));
                }

                var topRTF = separateRtfs[0];
                separateRtfs.RemoveAt(0);

                int fontNumber = FindLastFontNumber(topRTF);

                var topRtfFontLastPosition = Regex.Matches(topRTF, @";}}").Cast<Match>().Select(m => m.Index).FirstOrDefault() + 3;

                var topRtfFontSection = topRTF.Substring(0, topRtfFontLastPosition);
                var topRtfContentSection = topRTF.Substring(topRtfFontLastPosition, (topRTF.Length) - (topRtfFontLastPosition));
                var topFontRtfList = SegregateFonts(topRtfFontSection).ToList();

                if (topFontRtfList.Count > 0)
                {
                    List<string> contentRtfList = new List<string>();

                    foreach (var singleRtf in separateRtfs)
                    {
                        var fontSectionLastPosition = Regex.Matches(singleRtf, @";}}").Cast<Match>().Select(m => m.Index).FirstOrDefault() + 3;

                        var fontRtfSection = singleRtf.Substring(0, fontSectionLastPosition);
                        var contentRtfSection = singleRtf.Substring(fontSectionLastPosition, (singleRtf.Length) - (fontSectionLastPosition));

                        var contentFontRtfList = SegregateFonts(fontRtfSection).ToList();

                        var refinedCntFontRtfList = (from of1 in contentFontRtfList
                                                     where !topFontRtfList.Any(
                                                                       x => String.Equals(x, of1))
                                                     select of1).ToList();

                        for (int i = 0; i < refinedCntFontRtfList.Count; i++)
                        {
                            var contentStyleText = GetFontStyleText(refinedCntFontRtfList[i]);
                            var matchedStyleInTop = topFontRtfList.FirstOrDefault(x => x.Contains(contentStyleText));
                            if (String.IsNullOrEmpty(matchedStyleInTop))
                            {
                                var contentFontWithNumber = GetFontWithNumber(refinedCntFontRtfList[i]);
                                fontNumber++;
                                var newFontWithNumber = "\\f" + fontNumber.ToString() + "\\";
                                //string destRtfSection = string.Empty;
                                if (contentFontWithNumber != newFontWithNumber)
                                {
                                    if (contentRtfSection.Contains(newFontWithNumber) && fontRtfSection.Contains(newFontWithNumber))
                                    {
                                        var tempFontWithNo = newFontWithNumber.Insert(newFontWithNumber.LastIndexOf("\\"), "t");
                                        contentRtfSection = contentRtfSection.Replace(newFontWithNumber, tempFontWithNo);
                                        refinedCntFontRtfList = refinedCntFontRtfList.Select(s => s.Contains(newFontWithNumber) ? s.Replace(newFontWithNumber, tempFontWithNo) : s).ToList();
                                    }
                                    else if (fontRtfSection.Contains(newFontWithNumber))
                                    {
                                        var tempFontWithNo = newFontWithNumber.Insert(newFontWithNumber.LastIndexOf("\\"), "t");
                                        refinedCntFontRtfList = refinedCntFontRtfList.Select(s => s.Contains(newFontWithNumber) ? s.Replace(newFontWithNumber, tempFontWithNo) : s).ToList();
                                    }
                                    contentRtfSection = contentRtfSection.Replace(contentFontWithNumber, newFontWithNumber);

                                    var fontToInsert = refinedCntFontRtfList[i].Replace(contentFontWithNumber, newFontWithNumber).Replace("\r\n", string.Empty);
                                    topRtfFontSection = topRtfFontSection.Insert((topRtfFontSection.LastIndexOf("}")), "\r\n" + fontToInsert);
                                    topFontRtfList.Add(fontToInsert.Replace("\r\n", string.Empty));
                                }
                                else
                                {
                                    topRtfFontSection = topRtfFontSection.Insert((topRtfFontSection.LastIndexOf("}")), "\r\n" + refinedCntFontRtfList[i].Replace("\r\n", string.Empty));
                                    topFontRtfList.Add(refinedCntFontRtfList[i].Replace("\r\n", string.Empty));
                                }
                            }
                            else
                            {
                                var topfontWithNumber = GetFontWithNumber(matchedStyleInTop);
                                var contentFontWithNumber = GetFontWithNumber(refinedCntFontRtfList[i]);

                                if (contentRtfSection.Contains(topfontWithNumber) && fontRtfSection.Contains(topfontWithNumber))
                                {                                    
                                    var tempFontWithNo = topfontWithNumber.Insert(topfontWithNumber.LastIndexOf("\\"), "t");
                                    contentRtfSection = contentRtfSection.Replace(topfontWithNumber, tempFontWithNo);
                                    refinedCntFontRtfList = refinedCntFontRtfList.Select(s => s.Contains(topfontWithNumber) ? s.Replace(topfontWithNumber, tempFontWithNo) : s).ToList();                                    
                                }
                                else if (fontRtfSection.Contains(topfontWithNumber))
                                {
                                    var tempFontWithNo = topfontWithNumber.Insert(topfontWithNumber.LastIndexOf("\\"), "t");
                                    refinedCntFontRtfList = refinedCntFontRtfList.Select(s => s.Contains(topfontWithNumber) ? s.Replace(topfontWithNumber, tempFontWithNo) : s).ToList();
                                }

                                contentRtfSection = contentRtfSection.Replace(contentFontWithNumber, topfontWithNumber);
                            }
                        }
                        contentRtfList.Add(fontRtfSection + contentRtfSection);
                    }

                    listDestStringRtfs.Add(topRtfFontSection + topRtfContentSection);
                    listDestStringRtfs.AddRange(contentRtfList);
                    modifiedString = string.Join("", listDestStringRtfs);
                    var fontSizMatches = Regex.Matches(modifiedString, @"\\f\d+t");
                    foreach (Match match in fontSizMatches)
                    {
                        int fontNo = int.Parse(GetFontNumber(match.Value));
                        modifiedString = Regex.Replace(modifiedString, @"\\f\d+t", @"\f" + fontNo, RegexOptions.Multiline);
                    }
                }
            }
            return modifiedString;
        }

        /// <summary>
        /// Getting the font Number from the string
        /// </summary>
        /// <param name="matchvalue"></param>
        /// <returns></returns>
        private string GetFontNumber(string matchvalue)
        {
            string output = Regex.Match(matchvalue, @"\d+").Value;
            return output;
        }
        /// <summary>
        /// Getting the text string of Font style
        /// </summary>
        /// <param name="fontText"></param>
        /// <returns></returns>
        private string GetFontStyleText(string fontText)
        {
            var startIndex = fontText.IndexOf("}") + 1;
            var lastIndex = fontText.IndexOf(";");
            string fontValue = string.Empty;
            if ((lastIndex - startIndex) > 0)
            {
                fontValue = fontText.Substring(startIndex, (lastIndex - startIndex));
            }
            else
            {
                startIndex = Regex.Matches(fontText, @"{\\f\d+\\\w+\\fcharset\d+\\fprq\d+").Cast<Match>().Select(m => m.Index).FirstOrDefault();
                var length = Regex.Matches(fontText, @"{\\f\d+\\\w+\\fcharset\d+\\fprq\d+").Cast<Match>().Select(m => m.Length).FirstOrDefault();
                startIndex = startIndex + length;
                if ((lastIndex - startIndex) > 0)
                {
                    fontValue = fontText.Substring(startIndex, (fontText.IndexOf(";") - startIndex)).Trim();
                }
            }
            return fontValue;
        }
        
        /// <summary>
        /// Finding the last font number in the rtfFile
        /// </summary>
        /// <param name="rtfFile"></param>
        /// <returns></returns>
        private int FindLastFontNumber(string rtfFile)
        {
            int fontNumber;
            var fontIndex = Regex.Matches(rtfFile, @";}}").Cast<Match>().Select(m => m.Index).FirstOrDefault();
            var topRTFFontSection = rtfFile.Substring(0, fontIndex - 0);
            var lastFontIndexNumber = Regex.Matches(topRTFFontSection, @"\\f\d+\\").Cast<Match>().Select(m => m.Index).LastOrDefault();
            var topRTFLastFontSection = topRTFFontSection.Substring(lastFontIndexNumber + 2, topRTFFontSection.Length - (lastFontIndexNumber + 2));

            var intParsing = Int32.TryParse(topRTFLastFontSection.Substring(0, Regex.Matches(topRTFLastFontSection, @"\\").Cast<Match>().Select(m => m.Index).FirstOrDefault()), out fontNumber);
            return fontNumber;
        }

        /// <summary>
        /// COnverting a string of RTFs to List 
        /// </summary>
        /// <param name="rtfFile"></param>
        /// <returns></returns>
        private List<string> SegregateFonts(string rtfFile)
        {
            List<string> subRtfFonts = new List<string>();
            var rtfFontIndexes = Regex.Matches(rtfFile, @"{\\f\d+\\\w+\\fcharset\d+\\fprq\d+").Cast<Match>().Select(m => m.Index).ToList();
            if (rtfFontIndexes.Count > 0)
            {
                for (int i = 0; i < rtfFontIndexes.Count - 1; i++)
                {
                    subRtfFonts.Add(rtfFile.Substring(rtfFontIndexes[i], rtfFontIndexes[i + 1] - rtfFontIndexes[i]).Replace("\r\n", "").Trim());
                }
                var lastFontIndex = Regex.Matches(rtfFile, @";}}").Cast<Match>().Select(m => m.Index).FirstOrDefault() + 2;
                subRtfFonts.Add(rtfFile.Substring(rtfFontIndexes[rtfFontIndexes.Count - 1], lastFontIndex - rtfFontIndexes[rtfFontIndexes.Count - 1]).Trim());
                subRtfFonts.RemoveAll(x => x.Contains("Symbol"));
            }
            return subRtfFonts;
        }

        /// <summary>
        /// Getting the font style text along with number
        /// </summary>
        /// <param name="sourceString"></param>
        /// <returns></returns>
        private string GetFontWithNumber(string sourceString)
        {
            var ss1 = sourceString.Substring(2, sourceString.Length - 2);
            var fontWithNumber = "\\" + ss1.Substring(0, ss1.IndexOf("\\") + 1);
            return fontWithNumber;
        }
    
    }
}
