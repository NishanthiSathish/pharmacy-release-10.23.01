/* //Commented - MM-3989 (Required in Future version)

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Windows.Forms;

namespace TextControlEditorPharmacyClient.FileHandling
{
    public class UpdateColorforMergedRTF
    {
        /// <summary>
        /// Adding a color style to the top RTF and making corresponding chnages to existing RTFs
        /// </summary>
        /// <param name="RTFFile"></param>
        /// <returns></returns>
        public string MergeTableBackgroundColorStyleinRTF(string RTFFile)
        {
            int newColorIndex = 0;
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

                int colorNumber = FindLastColorNumber(topRTF);

                var topRtfColorLastPosition = Regex.Matches(topRTF, @"blue\d+").Cast<Match>().Select(m => m.Index).LastOrDefault() + 8;

                var topRtfColorSection = topRTF.Substring(0, topRtfColorLastPosition);
                var topRtfContentSection = topRTF.Substring(topRtfColorLastPosition, (topRTF.Length) - (topRtfColorLastPosition));
                var topColorRtfList = SegregateColors(topRtfColorSection).ToList();

                if (topColorRtfList.Count > 0)
                {
                    List<string> contentRtfList = new List<string>();
                    string updatedSingleRtf = "";
                    string rgxPattern = "";
                    foreach (var singleRtf in separateRtfs)
                    {
                        var colorSectionLastPosition = Regex.Matches(singleRtf, @"blue\d+").Cast<Match>().Select(m => m.Index).LastOrDefault() + 8;

                        var colorRtfSection = singleRtf.Substring(0, colorSectionLastPosition);
                        var contentRtfSection = singleRtf.Substring(colorSectionLastPosition, (singleRtf.Length) - (colorSectionLastPosition));

                        var contentColorRtfList = SegregateColors(colorRtfSection).ToList();

                        var refinedCntColorRtfList = (from of1 in contentColorRtfList
                                                      where !topColorRtfList.Any(
                                                                        x => String.Equals(x, of1))
                                                      select of1).ToList();

                        for (int i = 0; i < refinedCntColorRtfList.Count; i++)
                        {
                            var colorToInsert = refinedCntColorRtfList[i].Replace("\r\n", string.Empty);
                            topRtfColorSection = topRtfColorSection.Insert((topRtfColorSection.LastIndexOf(";") + 1), colorToInsert);
                            topColorRtfList.Add(colorToInsert.Replace("\r\n", string.Empty));
                        }

                        newColorIndex = newColorIndex + contentColorRtfList.Count - refinedCntColorRtfList.Count;

                        //Background color "clcbpatN"(Table)
                        if (singleRtf.Contains("clcbpat"))
                        {
                            rgxPattern = @"\\clcbpat\d+";
                            updatedSingleRtf = UpdateColorIndex(singleRtf, rgxPattern, topColorRtfList, contentColorRtfList); //Update table background color
                        }
                        else
                        {
                            updatedSingleRtf = singleRtf;
                        }

                        //Line color of the background pattern "clcfpat" (Table)
                        if (updatedSingleRtf.Contains("clcfpat"))
                        {
                            rgxPattern = @"\\clcfpat\d+";
                            updatedSingleRtf = UpdateColorIndex(updatedSingleRtf, rgxPattern, topColorRtfList, contentColorRtfList); //Update font color 
                        }

                        //Foreground Color "cfN" (Font) 
                        if (updatedSingleRtf.Contains(@"\cf"))
                        {
                            rgxPattern = @"\\cf\d+";
                            updatedSingleRtf = UpdateColorIndex(updatedSingleRtf, rgxPattern, topColorRtfList, contentColorRtfList); //Update font color 
                        }

                        //Associated foreground color "acfN" (Associated foreground color)
                        if (updatedSingleRtf.Contains("acf"))
                        {
                            rgxPattern = @"\\acf\d+";
                            updatedSingleRtf = UpdateColorIndex(updatedSingleRtf, rgxPattern, topColorRtfList, contentColorRtfList); //Update font color 
                        }

                        //Background color "cbN" (Font)
                        if (updatedSingleRtf.Contains(@"\cb"))
                        {
                            rgxPattern = @"\\cb\d+";
                            updatedSingleRtf = UpdateColorIndex(updatedSingleRtf, rgxPattern, topColorRtfList, contentColorRtfList); //Update font color 
                        }

                        //Color of the Background pattern "chcfpatN" (Character Borders and Shading) 
                        if (updatedSingleRtf.Contains("chcfpat"))
                        {
                            rgxPattern = @"\\chcfpat\d+";
                            updatedSingleRtf = UpdateColorIndex(updatedSingleRtf, rgxPattern, topColorRtfList, contentColorRtfList); //Update font color 
                        }

                        //Fill color pattern "chcbpatN" (Character Borders and Shading) 
                        if (updatedSingleRtf.Contains("chcbpat"))
                        {
                            rgxPattern = @"\\chcbpat\d+";
                            updatedSingleRtf = UpdateColorIndex(updatedSingleRtf, rgxPattern, topColorRtfList, contentColorRtfList); //Update font color 
                        }

                        //color fill "cfpatN"(Paragraph Shading)
                        if (updatedSingleRtf.Contains("cfpat"))
                        {
                            rgxPattern = @"\\cfpat\d+";
                            updatedSingleRtf = UpdateColorIndex(updatedSingleRtf, rgxPattern, topColorRtfList, contentColorRtfList); //Update font color 
                        }

                        //color fill background "cbpatN" (Paragraph Shading)
                        if (updatedSingleRtf.Contains("cbpat"))
                        {
                            rgxPattern = @"\\cbpat\d+";
                            updatedSingleRtf = UpdateColorIndex(updatedSingleRtf, rgxPattern, topColorRtfList, contentColorRtfList); //Update font color 
                        }

                        //Color pargarpgh border "brdrcfN" (Paragraph and Border)
                        if (updatedSingleRtf.Contains("brdrcf"))
                        {
                            rgxPattern = @"\\brdrcf\d+";
                            updatedSingleRtf = UpdateColorIndex(updatedSingleRtf, rgxPattern, topColorRtfList, contentColorRtfList); //Update font color 
                        }

                        //Forground color "pncfN" (Bullets and Numbering)
                        if (updatedSingleRtf.Contains("pncf"))
                        {
                            rgxPattern = @"\\pncf\d+";
                            updatedSingleRtf = UpdateColorIndex(updatedSingleRtf, rgxPattern, topColorRtfList, contentColorRtfList); //Update font color 
                        }

                        contentRtfList.Add(updatedSingleRtf);
                        updatedSingleRtf = "";
                    }

                    listDestStringRtfs.Add(topRtfColorSection + topRtfContentSection);
                    listDestStringRtfs.AddRange(contentRtfList);
                    for (var i = 1; i < listDestStringRtfs.Count; i++)
                    {
                        if (listDestStringRtfs[i].ToString().Contains("colortbl"))
                        {
                            int startColorTableIndex = Regex.Matches(listDestStringRtfs[i].ToString(), @"{\\colortbl;\\").Cast<Match>().Select(m => m.Index).FirstOrDefault() + 11;
                            int endColorTableIndex = listDestStringRtfs[i].ToString().IndexOf(@";}", startColorTableIndex) + 1;
                            var aStringBuilder = new StringBuilder(listDestStringRtfs[i].ToString());
                            aStringBuilder.Remove(startColorTableIndex, endColorTableIndex - startColorTableIndex);
                            aStringBuilder.Insert(startColorTableIndex, string.Join("", topColorRtfList));
                            listDestStringRtfs[i] = aStringBuilder.ToString();
                        }
                    }
                    modifiedString = string.Join("", listDestStringRtfs);
                }
            }
            return modifiedString;
        }

        /// <summary>
        /// Finding the last color number in the rtfFile
        /// </summary>
        /// <param name="rtfFile"></param>
        /// <returns></returns>
        private int FindLastColorNumber(string rtfFile)
        {
            int colorNumber;
            var colorIndex = Regex.Matches(rtfFile, @";}}").Cast<Match>().Select(m => m.Index).FirstOrDefault();
            var topRTFColorSection = rtfFile.Substring(0, colorIndex - 0);
            var lastColorIndexNumber = Regex.Matches(topRTFColorSection, @"\\clcbpat\d+\\").Cast<Match>().Select(m => m.Index).LastOrDefault();
            var topRTFLastColorSection = topRTFColorSection.Substring(lastColorIndexNumber + 2, topRTFColorSection.Length - (lastColorIndexNumber + 2));

            var intParsing = Int32.TryParse(topRTFLastColorSection.Substring(0, Regex.Matches(topRTFLastColorSection, @"\\").Cast<Match>().Select(m => m.Index).FirstOrDefault()), out colorNumber);
            return colorNumber;
        }

        /// <summary>
        /// COnverting a string of RTFs to List 
        /// </summary>
        /// <param name="rtfFile"></param>
        /// <returns></returns>
        private List<string> SegregateColors(string rtfFile)
        {
            List<string> subRtfColors = new List<string>();
            var rtfColorIndexes = Regex.Matches(rtfFile, @"\\red").Cast<Match>().Select(m => m.Index).ToList();
            if (rtfColorIndexes.Count > 0)
            {
                for (int i = 0; i < rtfColorIndexes.Count - 1; i++)
                {
                    subRtfColors.Add(rtfFile.Substring(rtfColorIndexes[i], rtfColorIndexes[i + 1] - rtfColorIndexes[i]).Replace("\r\n", "").Trim());
                }
                var lastColorIndex = Regex.Matches(rtfFile, @"blue\d+").Cast<Match>().Select(m => m.Index).LastOrDefault() + 8;

                string lastColorString = rtfFile.Substring(rtfColorIndexes[rtfColorIndexes.Count - 1], lastColorIndex - rtfColorIndexes[rtfColorIndexes.Count - 1]).Trim();
                var ind = Regex.Matches(lastColorString, @";").Cast<Match>().Select(m => m.Index).LastOrDefault() + 1;
                lastColorString = lastColorString.Substring(0, ind);
                subRtfColors.Add(lastColorString.Trim());
            }
            return subRtfColors;
        }


        /// <summary>
        /// Update new index value for colors
        /// </summary>
        /// <param name="rtfFile"></param>
        /// <param name="pattern"></param>
        /// <param name="topColorRtfList"></param>
        /// <param name="refinedCntColorRtfList"></param>
        /// <returns></returns>
        private string UpdateColorIndex(string rtfFile, string pattern, List<string> topColorRtfList, List<string> refinedCntColorRtfList)
        {
            string rtfToUpdate = rtfFile;
            string rgxPattern = pattern;
            int matchIndexValueToAdd = rgxPattern.Length - 4;
            int totalLengthofRtf = rtfToUpdate.Length;
            int len = rtfToUpdate.Length;
            List<int> rtfColorIndexes = Regex.Matches(rtfToUpdate, rgxPattern).Cast<Match>().Select(m => m.Index).ToList();
            if (rtfColorIndexes.Count > 0)
            {
                for (int i = 0; i < rtfColorIndexes.Count; i++)
                {
                    if (rtfToUpdate.Length > totalLengthofRtf)
                    {
                        for (int j = i; j < rtfColorIndexes.Count; j++)
                        {
                            int IndexValuetoIncrease = rtfColorIndexes[j];
                            IndexValuetoIncrease = IndexValuetoIncrease + 1;
                            rtfColorIndexes[j] = IndexValuetoIncrease;
                        }

                    }
                    string rgxPatternToGetColorIndex = @"\d+";
                    Regex rgx = new Regex(rgxPatternToGetColorIndex);

                    Match match = rgx.Match(rtfToUpdate, rtfColorIndexes[i]);
                    if (match.Success)
                    {
                        int oldColorIndex = Int32.Parse(match.Groups[0].Value);
                        if (oldColorIndex > 0 && oldColorIndex <= refinedCntColorRtfList.Count)
                        {
                            var matchingColor = refinedCntColorRtfList[oldColorIndex - 1];
                            var mainColorIndex = topColorRtfList.FindIndex(a => a == matchingColor) + 1;
                            if (oldColorIndex != mainColorIndex)
                            {
                                int newColrIndex = mainColorIndex;
                                var aStringBuilder = new StringBuilder(rtfToUpdate);
                                aStringBuilder.Remove(rtfColorIndexes[i] + matchIndexValueToAdd, match.Groups[0].Value.Length);
                                aStringBuilder.Insert(rtfColorIndexes[i] + matchIndexValueToAdd, newColrIndex);
                                rtfToUpdate = aStringBuilder.ToString();
                            }
                        }
                    }
                }
            }
            return rtfToUpdate;
        }
    }
}


*/