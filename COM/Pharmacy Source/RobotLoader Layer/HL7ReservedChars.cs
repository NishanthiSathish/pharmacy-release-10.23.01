//===========================================================================
//
//							    HL7ReservedChars.cs
//  
//  Holds a HL7 reserved characters (like |, ^, \\) and template characters 
//  (like [, ]) and functions used to handled escaped characters
//
//  Usage:
//  HL7ReservedChars reservedChars = new HL7ReservedChars();
//  reservedChars.Extract(hl7message);
//
//  to replae all escaped HL7 (e.g. \|, and \^) amd escaped template (e.g. \[, and \]) 
//  with non printable characters
//  reservedChars.ReplaceEscapedTagWithHiddenTag(msg, true);
//
//  to replae all escaped HL7 (e.g. \|, and \^) with non printable characters
//  reservedChars.ReplaceEscapedTagWithHiddenTag(msg, false);
//
//  to replae all non printable characters (set using ReplaceEscapedTagWithHiddenTag) 
//  with escaped chars (e.g. \|, and \^)
//  reservedChars.ReplaceHiddenTagWithEscapedTag(msg, false);
//
//	Modification History:
//	21Dec09 XN Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ascribe.pharmacy.robotloading
{
    internal class HL7ReservedChars
    {
        #region Constants
        /// <summary>Non printable character used to represent | HL7 segments splitter</summary>
        public static readonly char segmentSplitterHidenChar = (char)0x01;

        /// <summary>Non printable character used to represent ^ HL7 sequences splitter</summary>
        public static readonly char sequenceSplitterHidenChar = (char)0x02;

        /// <summary>Non preintable character used to represent a HL7 escape character e.g. \</summary>
        public static readonly char escapeHidenChar = (char)0x05;        

        /// <summary>Non printable character used to represent start of a template data tag [</summary>
        public static readonly char startTagHidenChar = (char)0x03;

        /// <summary>Non printable character used to represent end of a template data tag [</summary>
        public static readonly char endTagHidenChar = (char)0x04;
        #endregion

        #region Data memebers
        /// <summary>HL7 message character used to represent segment splitter data</summary>
        public char segmentSplitter = '|';

        /// <summary>HL7 message character used to represent sequence splitter data</summary>
        public char sequenceSplitter = '^';

        /// <summary>HL7 message character used to represent sequence splitter data</summary>
        public char escapeChar = '\\';        
        #endregion

        /// <summary>Constructor</summary>
        public HL7ReservedChars() { }

        /// <summary>Constructor</summary>
        /// <param name="segmentSplitter">character used to represent HL7 segment splitter data normally '|'</param>
        /// <param name="sequenceSplitter">character used to represent HL7 sequence splitter data normally '^'</param>
        /// <param name="escapeChar">character used to represent HL7 escape character data normally '\\'</param>
        public HL7ReservedChars(char segmentSplitter, char sequenceSplitter, char escapeChar)
        {
            this.segmentSplitter  = segmentSplitter;
            this.sequenceSplitter = sequenceSplitter;
            this.escapeChar       = escapeChar;
        }

        /// <summary>
        /// Extract the segment, sequence, and escape, characters from the HL7 header
        /// throws exception if start of header is invalid
        /// </summary>
        /// <param name="header">HL7 header</param>
        public void Extract(string header)
        {
            // Test the HL7 header is vlaid
            int startPos = header.IndexOf("MSH");
            if (startPos == -1)
                throw new ApplicationException("Invalid header");
            if ((startPos + 8) >= header.Length)
                throw new ApplicationException("Invalid header");

            // Reads in the reseverd characters
            this.segmentSplitter  = header[startPos + 3];   // MSA|
            this.sequenceSplitter = header[startPos + 4];   // MSA|^
            this.escapeChar       = header[startPos + 6];   // MSA|^~\

            // extra bit of validation that final character is a segment splitter MSA|^~\&|
            if (this.segmentSplitter != header[startPos + 8])
                throw new ApplicationException("Invalid header");   
        }

        /// <summary>
        /// Replaces all non printables characters in the message with actual characters.
        /// The non printable chars must of been set using ReplaceEscapedTagWithHiddenTag
        /// So start of with message containting |Hello \|there| after calling 
        ///     ReplaceEscapedTagWithHiddenTag
        ///     ReplaceHiddenTagWithActualTag
        /// Message would reading |Hello |there|
        /// Method is normally used just to replace non printables template chars to actual chars
        /// </summary>
        /// <param name="str">HL7 message</param>
        /// <param name="includeTemplateChars">If to replace template specific chars (like [, or ])</param>
        /// <param name="includeMessageChars">If to replace non printable HL7 chars to actual chars like |, ^, and \\</param>
        /// <returns>str with non printables chars replaced with actual chars</returns>
        public string ReplaceHiddenTagWithActualTag(string str, bool includeTemplateChars, bool includeMessageChars)
        {
            StringBuilder temp = new StringBuilder(str);

            // Replace HL7 message chars
            if (includeMessageChars)
            {
                temp.Replace(HL7ReservedChars.escapeHidenChar, this.escapeChar);
                temp.Replace(HL7ReservedChars.segmentSplitterHidenChar, this.segmentSplitter);
                temp.Replace(HL7ReservedChars.sequenceSplitterHidenChar, this.sequenceSplitter);
            }

            // Replace tempalte chars
            if (includeTemplateChars)
            {
                temp.Replace(HL7ReservedChars.startTagHidenChar, '[');
                temp.Replace(HL7ReservedChars.endTagHidenChar, ']');
            }
            return temp.ToString();
        }

        /// <summary>
        /// Replaces escaped message characters with non printables characters.
        /// So start of with message containting |Hello \|there| after calling method
        /// Message would reading |Hello <char(1)>there|
        /// </summary>
        /// <param name="str">HL7 message</param>
        /// <param name="includeTemplateChars">If to replace template specific chars (like [, or ])</param>
        /// <returns>str with escaped message chars with non printables chars</returns>
        public string ReplaceEscapedTagWithHiddenTag(string str, bool includeTemplateChars)
        {
            StringBuilder temp = new StringBuilder(str);

            // Replace HL7 message chars
            temp.Replace(string.Format("{0}{1}", this.escapeChar, this.escapeChar),       HL7ReservedChars.escapeHidenChar.ToString());
            temp.Replace(string.Format("{0}{1}", this.escapeChar, this.segmentSplitter),  HL7ReservedChars.segmentSplitterHidenChar.ToString());
            temp.Replace(string.Format("{0}{1}", this.escapeChar, this.sequenceSplitter), HL7ReservedChars.sequenceSplitterHidenChar.ToString());

            // Replace tempalte chars
            if (includeTemplateChars)
            {
                temp.Replace(string.Format("{0}[", this.escapeChar), HL7ReservedChars.startTagHidenChar.ToString());
                temp.Replace(string.Format("{0}]", this.escapeChar), HL7ReservedChars.endTagHidenChar.ToString());
            }

            return temp.ToString();
        }

        /// <summary>
        /// Replaces all non printables characters in the message with escaped characters.
        /// The non printable chars must of been set using ReplaceEscapedTagWithHiddenTag
        /// So start of with message containting |Hello \|there| after calling 
        ///     ReplaceEscapedTagWithHiddenTag
        ///     ReplaceHiddenTagWithActualTag
        /// Message would reading |Hello \|there|
        /// </summary>
        /// <param name="str">HL7 message</param>
        /// <param name="includeTemplateChars">If to also replace template specific chars (like [, or ])</param>
        /// <returns>str with escaped message chars with non printables chars</returns>
        public string ReplaceHiddenTagWithEscapedTag(string str, bool includeTemplateChars)
        {
            StringBuilder temp = new StringBuilder(str);

            // Replace HL7 message chars
            temp.Replace(HL7ReservedChars.escapeHidenChar.ToString(), string.Format("{0}{1}", this.escapeChar, this.escapeChar));
            temp.Replace(HL7ReservedChars.segmentSplitterHidenChar.ToString(), string.Format("{0}{1}", this.escapeChar, this.segmentSplitter));
            temp.Replace(HL7ReservedChars.sequenceSplitterHidenChar.ToString(), string.Format("{0}{1}", this.escapeChar, this.sequenceSplitter));

            // Replace tempalte chars
            if (includeTemplateChars)
            {
                temp.Replace(HL7ReservedChars.startTagHidenChar.ToString(), string.Format("{0}[", this.escapeChar));
                temp.Replace(HL7ReservedChars.endTagHidenChar.ToString(),   string.Format("{0}]", this.escapeChar));
            }
            return temp.ToString();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="str"></param>
        /// <param name="includeTemplateChars"></param>
        /// <returns></returns>
        public string ReplaceActualTagWithEscapedTag(string str, bool includeTemplateChars)
        {
            StringBuilder temp = new StringBuilder(str);

            // Replace HL7 message chars
            temp.Replace(this.escapeChar.ToString(),      string.Format("{0}{1}", this.escapeChar, this.escapeChar));
            temp.Replace(this.segmentSplitter.ToString(), string.Format("{0}{1}", this.escapeChar, this.segmentSplitter));
            temp.Replace(this.sequenceSplitter.ToString(),string.Format("{0}{1}", this.escapeChar, this.sequenceSplitter));

            // Replace tempalte chars
            if (includeTemplateChars)
            {
                temp.Replace("[", string.Format("{0}[", this.escapeChar));
                temp.Replace("]", string.Format("{0}]", this.escapeChar));
            }
            return temp.ToString();
        }
    }
}
