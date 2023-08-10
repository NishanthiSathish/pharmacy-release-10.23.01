//===========================================================================
//
//							    StringExtensions.cs
//
//  Provides helpful extension methods for strings.
//
//	Modification History:
//	21Dec09 XN  Written
//  05Aug10 XN  Added EqualsNoCase, EqualsNoCaseTrimEnd as useful when dealing
//              with pharmacy data.
//  22Mar11 XN  Add methods All, Remove, and Replace (F0092112)
//  04Jul11 XN  Made EqualsNoCase and EqualsNoCaseTrimEnd handle comparing 
//              null strings.
//  08Fab12 XN  Added functions FixedWidthPadRight, and IsEmptyOrNullAfterTrim
//  15Nov12 XN  Added method XMLEscape (TFS47487)
//  26Nov12 XN  Added method JavaStringEscape and made XMLEscape apostrophise 
//              optional (TFS47487)
//  23Apr13 XN  Corrected apos code in XMLEscape. Added method XMLUnescape 53147
//  09Jul13 XN  Updated SafeSubstring so prevent Exception if length is -ve
//  29Oct13 XN  Added FormatBNF
//  19Dec13 XN  78339 Added ParseCVS method#
//  26Nov14 XN  SafeSubstring if str is null then return null
//  09May14 XN  88858 Added quote escape to JavaStringEscpae method and new method RTFEscape
//  29May15 XN  Added repeat method
//  15Aug16 XN  update XMLEscape so returns null if value is null (preventing crash) 108889
//===========================================================================
using System;
using System.Collections.Generic;
using System.Text;

namespace ascribe.pharmacy.shared
{
    using System.Linq;

    /// <summary>Extension methods for the string class</summary>
    static public class StringExtensions
    {
        /// <summary>Performs a Substring function, that will not assert if length goes past end of string</summary>
        /// <param name="str">String to sub</param>
        /// <param name="startIndex">Start index</param>
        /// <param name="length">length</param>
        /// <returns>Sub string</returns>
        static public string SafeSubstring ( this string str, int startIndex, int length )
        {
            if (str == null)
                return null;    // 26Nov14 XN
            startIndex = Math.Min (str.Length, startIndex);
            length     = Math.Max (0, Math.Min (str.Length - startIndex, length));  // 09Jul13 XN prevent error if length is -ve
            return str.Substring (startIndex, length);
        }
        static public string SafeSubstring ( this string str, int startIndex )
        {
            if (str == null)
                return null;    // 26Nov14 XN
            startIndex = Math.Min (str.Length, startIndex);
            return str.Substring (startIndex, str.Length - startIndex);
        }

        /// <summary>Returns true if the strings are equal ignore case (CurrentCultureIgnoreCase)</summary>
        /// <param name="str">String to compare</param>
        /// <param name="value">String to compare with</param>
        /// <returns>If string equal ignore case</returns>
        static public bool EqualsNoCase(this string str, string value)
        {
            if ((str == null) && (value == null))
                return true;
            else if ((str == null) || (value == null))
                return false;    
            else
                return string.Equals(str, value, StringComparison.CurrentCultureIgnoreCase);
        }

        /// <summary>
        /// Returns true if the strings are equal ignore case (CurrentCultureIgnoreCase), 
        /// and trimming white spaces off end of string
        /// </summary>
        /// <param name="str">String to compare</param>
        /// <param name="value">String to compare with</param>
        /// <returns>If string equal ignore case</returns>
        static public bool EqualsNoCaseTrimEnd(this string str, string value)
        {
            if ((str == null) && (value == null))
                return true;
            else if ((str == null) || (value == null))
                return false;    
            else
                return string.Equals(str.TrimEnd(), value.TrimEnd(), StringComparison.CurrentCultureIgnoreCase);
        }

        /// <summary>Returns if all elements in the string fulfil the condition</summary>
        /// <param name="str">string to test</param>
        /// <param name="condition">Condition to test</param>
        /// <returns>If all chars fulfil condition</returns>
        static public bool All(this string str, Func<char, bool> condition)
        {
            for (int c = 0; c < str.Length; c++)
            {
                if (!condition.Invoke(str[c]))
                    return false;
            }

            return true;
        }

        /// <summary>Removes all characters that fulfil specified condition</summary>
        /// <param name="str">string to alter</param>
        /// <param name="condition">If condition returns true for char it will be removed</param>
        /// <returns>Updated string</returns>
        static public string Remove(this string str, Func<char, bool> condition)
        {
            StringBuilder strBuilder = new StringBuilder(str);

            for (int c = strBuilder.Length - 1; c >= 0; c--)
            {
                if (condition.Invoke(strBuilder[c]))
                    strBuilder.Remove(c, 1);
            }

            return strBuilder.ToString();
        }

        /// <summary>Replaces all characters that fulfil specified condition</summary>
        /// <param name="str">string to alter</param>
        /// <param name="condition">If condition returns true for char it will be replaced</param>
        /// <param name="newChar">Replacement character</param>
        /// <returns>Updated string</returns>
        static public string Replace(this string str, Func<char, bool> condition, char newChar)
        {
            StringBuilder strBuilder = new StringBuilder(str);
            for (int c = 0; c < strBuilder.Length; c++)
            {
                if (condition.Invoke(strBuilder[c]))
                    strBuilder[c] = newChar;
            }

            return strBuilder.ToString();
        }

        /// <summary>
        /// Either truncates the string to totalWidth (using SafeSubstring) 
        /// or left aligns the string chars padding to the right with the paddingChar
        /// </summary>
        /// <param name="str">Initial string</param>
        /// <param name="totalWidth">Total width of the final string</param>
        /// <param name="paddingChar">Padding char to fill the string (default is space)</param>
        static public string FixedWidthPadRight(this string str, int totalWidth, char paddingChar)
        {
            return str.SafeSubstring(0, totalWidth).PadRight(totalWidth, paddingChar);
        }
        static public string FixedWidthPadRight(this string str, int totalWidth)
        {
            return str.SafeSubstring(0, totalWidth).PadRight(totalWidth);
        }

        /// <summary>Returns true if string is null, or empty (after trim)</summary>
        /// <param name="str">String to check</param>
        /// <returns>If null or empty after trim</returns>
        static public bool IsNullOrEmptyAfterTrim(string str)
        {
            if (str == null)
                return true;
            else
                return string.IsNullOrEmpty(str.TrimEnd());
        }

        /// <summary>Makes sure the first char of the string is upper case</summary>
        static public string ToUpperFirstLetter(this string str)
        {
            if (!string.IsNullOrEmpty(str) && !Char.IsUpper(str[0]))
                return Char.ToUpper(str[0]) + str.SafeSubstring(1, str.Length - 1);
            else
                return str;
        }

        /// <summary>Parses CSV string 19Dec13 XN 78339</summary>
        /// <typeparam name="T">Type to convert string items to</typeparam>
        /// <param name="str">String to parse</param>
        /// <param name="csvChar">CSV character</param>
        /// <param name="ignoreErrors">IF convert errors are to be ignored</param>
        static public IEnumerable<T> ParseCSV<T>(this string str, string csvChar, bool ignoreErrors)
        {
            if (str == null)
                return null;

            List<T> results = new List<T>();
            if (str == string.Empty)
                return results;

            string[] splitItem = str.Split(new string[] { csvChar }, StringSplitOptions.None);
            foreach (var item in splitItem)
            {
                try
                {
                    results.Add(ConvertExtensions.ChangeType<T>(item));
                }
                catch (Exception ex)
                {
                    if (!ignoreErrors)
                        throw ex;
                }
            }

            return results;
        }

        /// <summary>
        /// XML escapes the string data
        ///     & - &amp;
        ///     " - &quot;
        ///     ' - &#39; - optional (don't do for html element text
        //      < - &lt;
        //      > - &gt;
        ///
        /// At some point need to check how effect speed of this method is
        /// currently better than string.replace, but could try char array, or regex
        /// </summary>
        /// <param name="escapseApostrophise">Optional if ' should be escaped (don't use for HTML element text but do for attributes)</param>
        static public string XMLEscape(this string value)
        {
            return XMLEscape(value, true);
        }
        static public string XMLEscape(this string value, bool escapeApostrophise)
        {
            if (value == null)  // 15Aug16 XN Prevents possible crash 108889
                return null;

            StringBuilder str = new StringBuilder(value);
            str.Replace("&",  "&amp;"  );
            str.Replace("\"", "&quot;" );
            if (escapeApostrophise)
                str.Replace("'",  "&#39;" );
            str.Replace("<",  "&lt;"   );
            str.Replace(">",  "&gt;"   );
            return str.ToString();
        }

        /// <summary>
        /// Unescapes XML string data. 
        /// For string escapted using XMLEscape
        /// (see XMLEscape for details)
        /// Note unescapes &apos; and &#39; as '
        /// </summary>
        static public string XMLUnescape(this string value)
        {
            StringBuilder str = new StringBuilder(value);
            str.Replace("&amp;", "&" );
            str.Replace("&quot;","\"");
            str.Replace("&apos;","'");
            str.Replace("&#39;", "'");
            str.Replace("&lt;",  "<");
            str.Replace("&gt;",  ">");
            str.Replace("&nbsp;"," ");
            return str.ToString();
        }

        /// <summary>
        /// Used to escape java script strings (created on server to be sent to client)
        /// in conjunction with client side method JavaStringUnescape in pharmacyscript.js
        /// Converts
        ///     \           - &slash;  (not any type of standard convention
        ///     new line    - \n
        ///     line feed   - \r
        ///     if quotesToEscape = ' then ' is replaced with \'
        ///     if quotesToEscape = " then " is replaced with \"
        ///     
        /// So if need to send alert message
        ///     Hello.
        ///     How are you.
        /// Then would do 
        ///     string msg = JavaStringEscape("Hello.\nHow are you.");
        ///     send to client "alert(JavaStringUnescape(" + msg + "));"
        /// </summary>
        static public string JavaStringEscape(this string value, string quotesToEscape = "")
        {
            StringBuilder str = new StringBuilder(value);
            str.Replace("\\", "&slash;" );
            str.Replace("\n", "\\n"     );
            str.Replace("\r", "\\r"     );
            switch (quotesToEscape) // 09May14 XN  88858 Add quote escape
            {
            case "'" : str.Replace("'",  "\\'" ); break;    
            case "\"": str.Replace("\"", "\\\""); break;
            }
            return str.ToString();
        }

        /// <summary>
        /// Used to escape RTF strings
        /// Converts
        ///     \   - \\
        ///     {   - \{
        ///     }   - \}
        /// </summary>
        static public string RTFEscape(this string value)
        {
            StringBuilder str = new StringBuilder(value);
            str.Replace(@"\", @"\\");
            str.Replace(@"{", @"\{");
            str.Replace(@"}", @"\}");
            return str.ToString();
        }

        /// <summary>
        /// Takes bnfcode as typed and parses on dots. Single digits become 0 prefixed.
        ///     1.2.3  => 01.02.03
        ///     1.12.3 => 01.12.03
        /// but longer entries remain untouched eg 123. 456.2 => 123.456.02
        /// </summary>
        static public string FormatBNF(string bnf)
        {
            string[] splitOnDots = bnf.Split(new char[] {','}, StringSplitOptions.RemoveEmptyEntries);
            StringBuilder bnfFormatted = new StringBuilder();
            
            for(int c = 0; c < splitOnDots.Length; c++)
            {
                string s = splitOnDots[c].Trim();
                if (s.Length == 1)
                {
                    bnfFormatted.Append("0" + s);
                    bnfFormatted.Append(".");
                }
                else if (s.Length > 1)
                {
                    bnfFormatted.Append(s);
                    bnfFormatted.Append(".");
                }   
            }

            if (bnfFormatted.Length > 0)
                bnfFormatted.Length = bnfFormatted.Length - 1;

            return bnfFormatted.ToString();
        }

        /// <summary>The repeat the string</summary>
        /// <param name="str">String name</param>
        /// <param name="count">Number of times to repeat</param>
        /// <returns>Repeated string <see cref="string"/></returns>
        public static string Repeat(this string str, int count)
        {
            return str == null ? null : string.Concat(Enumerable.Repeat(str, count));
        }

        /// <summary>
        /// Escapes invalid filename chars e.g. \/:*?&lt;&gt;>|¦.
        /// 26Apr16 XN 123082 Added
        /// </summary>
        /// <param name="str">filename</param>
        /// <param name="escapeChar">replace chars with this value (default is char will be removed)</param>
        /// <returns>escaped string</returns>
        public static string FilenameStringEscape(this string str, char? escapeChar = null)
        {
            var InvalidPathChars = new char[] { '\\', '/', ':', '*', '?', '"', '<', '>', '|', '¦', '.' };
            return escapeChar == null ? str.Remove(c => InvalidPathChars.Contains(c)) : str.Replace(c => InvalidPathChars.Contains(c), escapeChar.Value);
        }
    }
}
