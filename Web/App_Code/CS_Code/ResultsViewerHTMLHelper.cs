using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Ascribe.ICW
{
    /// <summary>
    /// Summary description for ResultsViewerHTMLHelper
    /// </summary>
    public static class ResultsViewerHTMLHelper
    {
        private const int TAG_SP = 0;
        private const int TAG_IN = 1;
        private const int TAG_TI = 2;
        private const int TAG_SK = 3;

        /// <summary>
        /// Simple check to see if the result text contains HTML
        /// </summary>
        /// <param name="resultText">result text we will be checking</param>
        /// <returns>true if any of the html tags are found</returns>
        public static bool ResultContainsHTML(string resultText)
        {
            string[] arrayOfTags = new string[] { "<html>", "</html>", "<head>", "</head>", "<body>", "</body>", "</br>", "</u>" };

            return arrayOfTags.Any(resultText.ToLower().Contains);
        }

        /// <summary>
        /// Simple check to see if the result text contains special escape codes
        /// </summary>
        /// <param name="resultText">result text we will be cheking</param>
        /// <returns>true if any of the html tags are found</returns>
        public static bool ResultContainsEscapeCodes(string resultText)
        {
            string[] arrayOfEscapeCodes = new string[]
                                          {
                                              "\\H\\", "\\N\\", "\\.sp", "\\.br", "\\.fi", "\\.nf", "\\.in", "\\.ti",
                                              "\\.sk", "\\.ce", ".sp", ".br", ".fi", ".nf", ".in", ".ti", ".sk", ".ce"
                                          };

            return arrayOfEscapeCodes.Any(resultText.ToLower().Contains);
        }

        /// <summary>
        /// Takes a result string, usually in something like HL7 format and converts it into HTML
        /// </summary>
        /// <param name="resultText">The result text</param>
        /// <returns>Formatted html output</returns>
        public static string TranslateResultTextToHtml(string resultText)
        {
            resultText = ReplaceNonParameterisedTagInString_SP(resultText);

            resultText = ReplaceTagParameterInString(resultText, ".sp", true, TAG_SP);
            resultText = ReplaceTagParameterInString(resultText, ".sk", true, TAG_SK);
            resultText = ReplaceTagParameterInString(resultText, ".ti", true, TAG_TI);
            resultText = ReplaceTagParameterInString(resultText, ".in", true, TAG_IN);

            resultText = ReplaceTagInString_H(resultText);
            resultText = ReplaceTagInString_N(resultText);
            resultText = ReplaceTagInString_BR(resultText);

            resultText = ReplaceTagInString_NF(resultText);
            resultText = ReplaceTagInString_CE(resultText);

            return resultText;
        }

        /// <summary>
        /// Replace all occurances of \H\ with a html strong tag
        /// </summary>
        /// <param name="resultText">String we are replacing text in</param>
        /// <returns>Input string with any formatting replaced.</returns>
        public static string ReplaceTagInString_H(string resultText)
        {
            return resultText.Replace("\\H\\", "<strong>");
        }

        /// <summary>
        /// Replace all occurances of \N\ with a html closing strong tag
        /// </summary>
        /// <param name="resultText">String we are replacing text in</param>
        /// <returns>Input string with any formatting replaced.</returns>
        public static string ReplaceTagInString_N(string resultText)
        {
            return resultText.Replace("\\N\\", "</strong>");
        }

        /// <summary>
        /// Replace all occurances of either \.br\ or .br with a html break tag
        /// </summary>
        /// <param name="resultText">String we are replacing text in</param>
        /// <returns>Input string with any formatting replaced.</returns>
        public static string ReplaceTagInString_BR(string resultText)
        {
            return resultText.Replace("\\.br\\", "<br>").Replace(".br", "<br>");
        }

        /// <summary>
        /// Replace all occurances of the tags .ce or \\.ce\\ and replaces with center tags
        /// </summary>
        /// <param name="resultText">String we are replacing text in</param>
        /// <returns>Input string with any formatting replaced.</returns>
        public static string ReplaceTagInString_CE(string resultText)
        {
            int pos = 0;

            if (resultText.ToLower().Contains(".ce") || resultText.ToLower().Contains("\\.ce\\"))
            {
                do
                {
                    pos = resultText.ToLower().IndexOf("\\.ce\\", System.StringComparison.Ordinal);
                    if (pos > 0)
                    {
                        resultText = resultText.Remove(pos, 5);
                        resultText = resultText.Insert(pos, "<div align=\"center\">");

                        for (var i = pos; i < resultText.Length; i++)
                        {
                            if ((i + 1) <= resultText.Length && (resultText.Substring(i, 1) == "\n" || resultText.Substring(i, 1) == "\r"))
                            {
                                resultText = resultText.Insert(i, "</div>");
                                break;
                            }

                            if ((i + 4) <= resultText.Length && resultText.Substring(i, 4) == "<br>")
                            {
                                resultText = resultText.Insert(i, "</div>");
                                break;
                            }
                        }

                        resultText = resultText + "</div>";
                    }
                    else
                    {
                        break;
                    }
                } while (true);

                do
                {
                    pos = resultText.ToLower().IndexOf(".ce", System.StringComparison.Ordinal);
                    if (pos > 0)
                    {
                        resultText = resultText.Remove(pos, 3);
                        resultText = resultText.Insert(pos, "<div align=\"center\">");

                        for (var i = pos; i < resultText.Length; i++)
                        {
                            if ((i + 1) <= resultText.Length && (resultText.Substring(i, 1) == "\n" || resultText.Substring(i, 1) == "\r"))
                            {
                                resultText = resultText.Insert(i, "</div>");
                                break;
                            }

                            if ((i + 4) <= resultText.Length && resultText.Substring(i, 4) == "<br>")
                            {
                                resultText = resultText.Insert(i, "</div>");
                                break;
                            }
                        }

                        resultText = resultText + "</div>";
                    }
                    else
                    {
                        break;
                    }
                } while (true);
            }

            return resultText;
        }

        /// <summary>
        /// Replace all occurances of the tags .nf \\.nf\\ .fi \\.fi\\ and replaces with no word wrap divs
        /// </summary>
        /// <param name="resultText">String we are replacing text in</param>
        /// <returns>Input string with any formatting replaced.</returns>
        public static string ReplaceTagInString_NF(string resultText)
        {
            var closingTagExists = resultText.ToLower().Contains("\\.fi\\") || resultText.ToLower().Contains(".fi");

            if (!closingTagExists)
            {
                if (resultText.ToLower().Contains("\\.nf\\") || resultText.ToLower().Contains(".nf"))
                {
                    resultText = resultText.Replace("\\.nf\\", "<div style=\"white-space:nowrap;\">");
                    resultText = resultText.Replace(".nf", "<div style=\"white-space:nowrap;\">");
                    resultText = resultText + ("</div>");
                }
            }
            else
            {
                resultText = resultText.Replace("\\.nf\\", "<div style=\"white-space:nowrap;\">");
                resultText = resultText.Replace("\\.fi\\", "</div>");
                resultText = resultText.Replace(".nf", "<div style=\"white-space:nowrap;\">");
                resultText = resultText.Replace(".fi", "</div>");
            }

            return resultText;
        }

        /// <summary>
        /// Takes the provided input string and replaces the specified tag (inc escaped tag)
        /// </summary>
        /// <param name="inputString">String we will be working on</param>
        /// <param name="searchTag">The tag we are searching for</param>
        /// <param name="tagCanBeEscaped">Can this tag have an escaped version</param>
        /// <param name="tagOperation">What we will do when we find the tag</param>
        /// <returns>Our input string with any tags replaced.</returns>
        public static string ReplaceTagParameterInString(string inputString, string searchTag, bool tagCanBeEscaped, int tagOperation)
        {
            int tagValue;
            int pos;
            bool searchedForAlternateTag = false;

            do
            {
                if (tagCanBeEscaped == false || searchedForAlternateTag)
                {
                    pos = inputString.IndexOf(searchTag, System.StringComparison.Ordinal);
                }
                else
                {
                    pos = inputString.IndexOf("\\" + searchTag, System.StringComparison.Ordinal);
                }

                if (pos >= 0)
                {
                    int tagValueOpen = inputString.IndexOf("<", pos, System.StringComparison.Ordinal);
                    int tagValueClose = inputString.IndexOf(">", pos, System.StringComparison.Ordinal);
                    if (tagValueOpen + tagValueClose > 0)
                    {
                        tagValue = Convert.ToInt32(inputString.Substring(tagValueOpen + 1, (tagValueClose - tagValueOpen) - 1));
                    }
                    else
                    {
                        tagValue = 1;
                    }

                    switch (tagOperation)
                    {
                        case TAG_SP:
                            inputString = ReplaceTagInString_SP(tagCanBeEscaped, searchedForAlternateTag, inputString, tagValue, pos, tagValueClose);
                            break;

                        case TAG_IN:
                            inputString = ReplaceTagInString_IN(tagCanBeEscaped, searchedForAlternateTag, inputString, tagValue, pos, tagValueClose);
                            break;

                        case TAG_SK:
                            inputString = ReplaceTagInString_SK(tagCanBeEscaped, searchedForAlternateTag, inputString, tagValue, pos, tagValueClose);
                            break;

                        case TAG_TI:
                            inputString = ReplaceTagInString_TI(tagCanBeEscaped, searchedForAlternateTag, inputString, tagValue, pos, tagValueClose);
                            break;
                    }
                }
                else
                {
                    if (tagCanBeEscaped && searchedForAlternateTag == false)
                    {
                        searchedForAlternateTag = true;
                    }
                    else
                    {
                        break;
                    }
                }
            } while (true);

            return inputString;
        }

        /// <summary>
        /// Replaces all occurances of an SP tag that doesn't have a parameter value
        /// </summary>
        /// <param name="resultText">result text we will be checking</param>
        /// <returns>result text with the tag replaced.</returns>
        public static string ReplaceNonParameterisedTagInString_SP(string resultText)
        {
            bool containsEscapeCharacters = false;

            // replace all break tags that dont have parameters
            resultText = resultText.Replace("\\.sp\\", "<br>");

            for (var i = 0; i < resultText.Length; i++)
            {
                if (!resultText.Contains(".sp"))
                    break;

                if (resultText.Substring(i, 3) == ".sp")
                {
                    switch (resultText[i + 3])
                    {
                        case '\\':
                            if (resultText[i - 1] == '\\')
                            {
                                containsEscapeCharacters = true;
                                resultText = resultText.Remove(i - 1, i + 3);
                            }
                            else
                            {
                                resultText = resultText.Remove(i, i + 3);
                                resultText = resultText.Insert(i, "<br>");
                            }
                            break;
                        case '<':
                            {
                                int closeBracket = resultText.IndexOf('>', i);
                                int tagValue = Convert.ToInt32(resultText.Substring(i + 4, closeBracket - (i + 4)));

                                if (resultText[i - 1] == '\\')
                                {
                                    containsEscapeCharacters = true;
                                    resultText = resultText.Remove(i - 1, closeBracket + 2);
                                }
                                else
                                {
                                    resultText = resultText.Remove(i, closeBracket + 1);
                                }

                                for (var j = 0; j < tagValue; j++)
                                {
                                    resultText = containsEscapeCharacters ? resultText.Insert(i - 1, "<br>") : resultText.Insert(i, "<br>");
                                }
                            }
                            break;
                        default:
                            resultText = resultText.Remove(i, 3);
                            resultText = resultText.Insert(i, "<br>");
                            break;
                    }
                }
            }
            return resultText;
        }

        /// <summary>
        /// Replaces the special tag .sp or \\.sp\ with spaces according to the parameter after the tag
        /// </summary>
        /// <param name="tagCanBeEscaped">True if this tag is one that can be escaped</param>
        /// <param name="searchedForAlternateTag">Specifies that we are searching for the alternative tag</param>
        /// <param name="inputString">The string we are searching</param>
        /// <param name="tagValue">The value specified after the tag</param>
        /// <param name="pos">The position we are searching from</param>
        /// <param name="tagValueClose">The closing tag position</param>
        /// <returns>The input string with the tag replaced if any were found</returns>
        public static string ReplaceTagInString_SP(bool tagCanBeEscaped, bool searchedForAlternateTag, string inputString, int tagValue, int pos, int tagValueClose)
        {
            if (tagCanBeEscaped && searchedForAlternateTag == false)
            {
                inputString = inputString.Remove(pos, ((tagValueClose + 1) - pos) + "\\".Length);
            }
            else
            {
                inputString = inputString.Remove(pos, ((tagValueClose + 1) - pos));
            }

            if (tagValue == 1)
            {
                inputString = inputString.Insert(pos, "<br>");
            }
            else
            {
                for (int i = 0; i < tagValue; i++)
                {
                    inputString = inputString.Insert(pos, "<br>");
                }
            }

            return inputString;
        }

        /// <summary>
        /// Replaces the special tag .sk or \\.sk\ with spaces according to the parameter after the tag
        /// </summary>
        /// <param name="tagCanBeEscaped">True if this tag is one that can be escaped</param>
        /// <param name="searchedForAlternateTag">Specifies that we are searching for the alternative tag</param>
        /// <param name="inputString">The string we are searching</param>
        /// <param name="tagValue">The value specified after the tag</param>
        /// <param name="pos">The position we are searching from</param>
        /// <param name="tagValueClose">The closing tag position</param>
        /// <returns>The input string with the tag replaced if any were found</returns>
        public static string ReplaceTagInString_SK(bool tagCanBeEscaped, bool searchedForAlternateTag, string inputString, int tagValue, int pos, int tagValueClose)
        {
            if (tagCanBeEscaped && searchedForAlternateTag == false)
            {
                inputString = inputString.Remove(pos, ((tagValueClose + 1) - pos) + "\\".Length);
            }
            else
            {
                inputString = inputString.Remove(pos, ((tagValueClose + 1) - pos));
            }

            for (int i = 0; i < tagValue; i++)
            {
                inputString = inputString.Insert(pos, "&nbsp;");
            }

            return inputString;
        }

        /// <summary>
        /// Replaces the special tag .ti or \\.ti\ with spaces according to the parameter after the tag
        /// </summary>
        /// <param name="tagCanBeEscaped">True if this tag is one that can be escaped</param>
        /// <param name="searchedForAlternateTag">Specifies that we are searching for the alternative tag</param>
        /// <param name="inputString">The string we are searching</param>
        /// <param name="tagValue">The value specified after the tag</param>
        /// <param name="pos">The position we are searching from</param>
        /// <param name="tagValueClose">The closing tag position</param>
        /// <returns>The input string with the tag replaced if any were found</returns>
        public static string ReplaceTagInString_TI(bool tagCanBeEscaped, bool searchedForAlternateTag, string inputString, int tagValue, int pos, int tagValueClose)
        {
            if (tagCanBeEscaped && searchedForAlternateTag == false)
            {
                inputString = inputString.Remove(pos, ((tagValueClose + 1) - pos) + "\\".Length);
            }
            else
            {
                inputString = inputString.Remove(pos, ((tagValueClose + 1) - pos));
            }

            if (tagValue < 0)
                tagValue = (tagValue) * (-1);

            for (int i = 0; i < tagValue; i++)
            {
                inputString = inputString.Insert(pos, "&nbsp;");
            }

            return inputString;
        }

        /// <summary>
        /// Replaces the special tag .in or \\.in\\ with spaces according to the parameter after the tag
        /// </summary>
        /// <param name="tagCanBeEscaped">True if this tag is one that can be escaped</param>
        /// <param name="searchedForAlternateTag">Specifies that we are searching for the alternative tag</param>
        /// <param name="inputString">The string we are searching</param>
        /// <param name="tagValue">The value specified after the tag</param>
        /// <param name="pos">The position we are searching from</param>
        /// <param name="tagValueClose">The closing tag position</param>
        /// <returns>The input string with the tag replaced if any were found</returns>
        public static string ReplaceTagInString_IN(bool tagCanBeEscaped, bool searchedForAlternateTag, string inputString, int tagValue, int pos, int tagValueClose)
        {
            if (tagCanBeEscaped && searchedForAlternateTag == false)
            {
                inputString = inputString.Remove(pos, ((tagValueClose + 1) - pos) + "\\".Length);
            }
            else
            {
                inputString = inputString.Remove(pos, ((tagValueClose + 1) - pos));
            }

            if (tagValue < 0)
                tagValue = (tagValue) * (-1);

            for (int i = 0; i < tagValue; i++)
            {
                inputString = inputString.Insert(pos, "&nbsp;");
            }

            return inputString;
        }
    }
}