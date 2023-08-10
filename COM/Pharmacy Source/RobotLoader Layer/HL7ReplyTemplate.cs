//===========================================================================
//
//							    HL7ReplyTemplate.cs
//  
//  Holds a HL7 message template used to create a hl7 messages 
//  See HL7Decoder.cs for more information
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
    /// <summary>Used to create a HL7 Message from a tempalte</summary>
    internal class HL7ReplyTemplate
    {
        #region Constant
        /// <summary>Special data tag used to place current date and time in the message in HL7 format</summary>
        private const string HL7DateTimeDataTag = "HL7DataTime";
        #endregion

        #region Data Memebers
        /// <summary>Template stored in this class</summary>
        private string template;
        #endregion

        #region Public Properties
        /// <summary>Template name</summary>
        public string Name { get; private set; }        
        #endregion

        #region Public methods
		/// <summary>
        /// Initalise the template
        /// </summary>
        /// <param name="name">template name</param>
        /// <param name="template">HL7 message Template</param>
        public void Initalise(string name, string template)
        {
            this.Name     = name;
            this.template = template;
        }

        /// <summary>Creates the HL7 message reply from the template</summary>
        /// <param name="reservedChars">Used to set the HL7 reserved character structure the template uses (set from the header)</param>
        /// <param name="mapper">Contains mapping of data tags to sequence values</param>
        /// <returns>HL7 message</returns>
        public string GenerateReply(HL7ReservedChars reservedChars, Dictionary<string, string> mapper)
        {
            // Replace template escape specific charaters with non printable characters
            string templateHiddenEscapedChars = reservedChars.ReplaceEscapedTagWithHiddenTag(template, true);

            // Substitute in the mapping data
            StringBuilder message = new StringBuilder(templateHiddenEscapedChars);
            foreach (string key in mapper.Keys)
            {
                if (HL7DateTimeDataTag == key)
                    message.Replace("[" + key + "]", DateTime.Now.ToString("yyyyMMddHHmmss"));    // If HL7 date time tag the substitue with actual date and time
                else
                    message.Replace("[" + key + "]", reservedChars.ReplaceActualTagWithEscapedTag(mapper[key], false));
            }

            string decodedMessage = message.ToString();

            // Replace non printable characters with template escaped specific tags
            decodedMessage = reservedChars.ReplaceHiddenTagWithEscapedTag(decodedMessage, false);

            // Replace template specific escaped tags with actual tags
            decodedMessage = reservedChars.ReplaceHiddenTagWithActualTag (decodedMessage, true, true);
            return decodedMessage;
        } 
	    #endregion    
    }
}
