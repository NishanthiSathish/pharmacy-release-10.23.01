//===========================================================================
//
//							    HL7Decoder.cs
//
//  Provides a class to perform decoding HL7 messages using templates,
//  and also generates replies using templates.
// 
//  Templates define the structure of the expected HL7 message with each sequence 
//  item in the message denoted by a pair of || chars. Template sequence items 
//  can contain the following:
//  1. Text to denote expected text in message used to match a message to a template.
//  2. Data tags denoted by [TagName] used to extract data from the message.
//  3. [Empty] data tag does not extract data but used to denote the item should be
//     empty used to match a message to a template.
//  4. Data tag with condition [TagName:=10] used to denote the required length of 
//     data in the message, used to match a message to a template. 
//     Supported conditions:   [TagName:<Len] - item length must be less than Len
//                             [TagName:<=Len]- item length must be less than or equal to Len
//                             [TagName:=Len] - item length must equal to Len
//                             [TagName:==Len]- item length must equal to Len
//                             [TagName:>Len] - item length must be greater than Len
//                             [TagName:>=Len]- item length must be greater than or equal to Len
//
//  Reply templates define the default structure of the reply message with data tags
//  used to substitute data into the message. The only special condition is the [HL7DataTime]
//  tag which will always be decoded to the current date and time in yyyyMMddhhmmss format
//
//
//  Usage:
//  First initalise the decoder with receiver header, and templates
//  decoder.SetReceiverHeaderTemplate ("MSH|^~\&|||||[HL7DataTime]||ZIN|[MessageControlID]|P|2.3|||AL|AL|||");
//  decoder.AddReceiverTemplate ("AskNewDeliver", "ZIN|B|B|[Empty]||[LoadingNumber:>0]");
//  decoder.AddReceiverTemplate ("WarnEndOfDelivery", "ZIN|E|E|[Empty]||[LoadingNumber]");
//
//  Now used DecodeMessage to decode recieved HL7 messages
//  Dictionary<string, string> mapper = new Dictionary<string, string>();
//  IEnumerable<string> messageTypes = decoder.DecodeMessage("MSH|^~\\&|||||20091221142245||ZIN|56|P|2.3|||AL|AL|||\rZIN|B|B|||10132|||3r3de|\r", mapper);
//
//  Message types will contain one entry AskNewDeliver, and the mapper component
//  will contian 3 dictionary lookups 'HL7DataTime', 'MessageControlID', 'LoadingNumber'
//
//
//  For initalising the reply templates
//  decoder.SetReplyHeaderTemplate ("MSH|^~\&|RobotLoading||ARXInterface||[HL7DataTime]||ACK|[MessageControlID]|P|2.3|||AL|AL|44||");
//  decoder.AddReplyTemplate ("ReplyNewDeliveryValid", "MSA|AD|[MessageControlID]|||||");
//  decoder.AddReplyTemplate ("ReplyNewDeliveryInvalid", "MSA|AF|[MessageControlID]|[Error]||||");
//
//  So to send a invalid new delviery message
//  mapper["Error"] = "Invalid loading number";
//  string reply = decoder.GenerateReply("ReplyNewDeliveryInvalid", mapper);
//
//  reply string will be MSH|^~\&|RobotLoading||ARXInterface||20091221142345||ACK|56|P|2.3|||AL|AL|44||\rMSA|AF|56|Invalid loading number||||\r
//
//	Modification History:
//	21Dec09 XN Written
//	03Oct13 XN 74592 Upgrade of Pharamcy to .NET4 means robot loader does 
//             not work with the EIE which is still .NET2
//             Fixed by moving the robot loader reply component to the web site
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;

namespace ascribe.pharmacy.robotloading
{
    /// <summary>Used to decode HL7 methods</summary>
    public class HL7Decoder
    {
        #region Member Variables
        /// <summary>Reserved HL7 characters for receiving messages</summary>
        private HL7ReservedChars reservedReceiverChars = new HL7ReservedChars();

        /// <summary>Reserved HL7 characters for reply messages</summary>
        private HL7ReservedChars reservedReplyChars = new HL7ReservedChars();

        /// <summary>Template for receiver</summary>
        private HL7ReceiverTemplate receiverHeaderTemplate = null;

        /// <summary>Template for reply</summary>
        private HL7ReplyTemplate replyHeaderTemplate = null;

        /// <summary>Templates for receiver messages</summary>
        private List<HL7ReceiverTemplate> receiverTempaltes = new List<HL7ReceiverTemplate>();

        /// <summary>Templates for reply messages</summary>
        private List<HL7ReplyTemplate> replyTempaltes = new List<HL7ReplyTemplate>();        
        #endregion

        /// <summary>Set template for receiver header message</summary>
        /// <param name="template">HL7 header template</param>
        public void SetReceiverHeaderTemplate(string template)
        {
            reservedReceiverChars.Extract(template);

            receiverHeaderTemplate = new HL7ReceiverTemplate();
            receiverHeaderTemplate.Initalise("Header", template, reservedReceiverChars);
        }

        /// <summary>Add template for a HL7 message</summary>
        /// <param name="template">HL7 template</param>
        public void AddReceiverTemplate(string name, string template)
        {
            if (receiverHeaderTemplate == null)
                throw new ApplicationException("Need to set the receiver header template before adding message templates");
            if (string.IsNullOrEmpty(name))
                throw new ApplicationException("All template need a template name");

            HL7ReceiverTemplate receiver = new HL7ReceiverTemplate();
            receiver.Initalise(name, template, reservedReceiverChars);
            receiverTempaltes.Add(receiver);
        }

        /// <summary>
        /// Decodes the HL7 Messages return the templates the message matched with
        /// </summary>
        /// <param name="message">Message to decode</param>
        /// <param name="mapper">Message data tag dictionary, will be populated from the message</param>
        /// <returns>List of matched templates by name</returns>
        public IEnumerable<string> DecodeMessage(string message, Dictionary<string, string> mapper)
        {
            string[] splitMessage = message.Split('\r');
            if (splitMessage.Length == 1)
                splitMessage = message.Split('\n'); // 03Oct13 XN 74592 If message has come through the pharamcy web interface the /r are converted to /n

            // Two message sequences, and blank for last char(13) but this is option
            if ((splitMessage.Count() != 2) && (splitMessage.Count() != 3))
                return new List<string>();

            // Read in the reservec characters from the message
            HL7ReservedChars reservedChars = new HL7ReservedChars();
            try
            {
                reservedChars.Extract(message);
            }
            catch (ApplicationException)
            {
                return new List<string>();
            }

            // check the header matches up
            if (!receiverHeaderTemplate.TryParse(splitMessage[0], reservedChars, mapper))
                return new List<string>();

            // Validate each template against the message
            Dictionary<string, string> tempMapper = new Dictionary<string,string>();
            List<HL7ReceiverTemplate> matches = new List<HL7ReceiverTemplate>();
            foreach (HL7ReceiverTemplate template in receiverTempaltes)
            {
                tempMapper.Clear();

                if (template.TryParse(splitMessage[1], reservedChars, tempMapper))
                {
                    // Template matched so add to list
                    matches.Add(template);

                    // As template matched add all matched data keys to mapper
                    foreach (string key in tempMapper.Keys)
                        mapper[key] = tempMapper[key];
                }
            }

            return matches.Select(m => m.Name);
        }

        /// <summary>Set the replay message header template</summary>
        /// <param name="template">header template</param>
        public void SetReplyHeaderTemplate(string template)
        {
            reservedReplyChars.Extract(template);

            replyHeaderTemplate = new HL7ReplyTemplate();
            replyHeaderTemplate.Initalise("Header", template);
        }

        /// <summary>Add reply message template</summary>
        /// <param name="name">Template name</param>
        /// <param name="template">Template</param>
        public void AddReplyTemplate(string name, string template)
        {
            if (replyHeaderTemplate == null)
                throw new ApplicationException("Need to set the reply header template before adding message templates");
            if (string.IsNullOrEmpty(name))
                throw new ApplicationException("All template need a template name");

            HL7ReplyTemplate reply = new HL7ReplyTemplate();
            reply.Initalise(name, template);
            replyTempaltes.Add(reply);
        }

        /// <summary>Generates a reply message from a template</summary>
        /// <param name="name">Template name</param>
        /// <param name="mapper">Message data tag dictionary used to populate the reply template</param>
        /// <returns>formatted reply message with header</returns>
        public string GenerateReply(string name, Dictionary<string, string> mapper)
        {
            HL7ReplyTemplate template = replyTempaltes.FirstOrDefault(i => i.Name.Equals(name, StringComparison.CurrentCultureIgnoreCase));
            if (template == null)
                throw new ApplicationException(string.Format("Failed to find reply template '{0}'", name));

            return replyHeaderTemplate.GenerateReply(reservedReplyChars, mapper) + "\r" + template.GenerateReply(reservedReplyChars, mapper) + "\r";
        }
    }
}
