//===========================================================================
//
//							    HL7ReceiverTemplate.cs
//  
//  Holds a HL7 message template used to decode hl7 messages 
//  See HL7Decoder.cs for more information
//
//	Modification History:
//	21Dec09 XN Written
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.robotloading
{
    /// <summary>Represents a hl7 tempalte</summary>
    internal class HL7ReceiverTemplate
    {
        #region Constant
        /// <summary>Data tag used to represent an empty sequense item</summary>
        private const string EmptyDataTag = "Empty";

        /// <summary>Used to test the condition statment for numbers</summary> 
        private static readonly char[] Numbers = new char[] { '1', '2', '3', '4', '5', '6', '7', '8', '9', '0' };

        #endregion

        #region Data Types
        /// <summary>Defines the type of a HL7 sequence template</summary>
	    private enum SequenceItemType
        {
            /// <summary>If sequence item is fixed data</summary>
            FixedData,

            /// <summary>If sequence item must be empty</summary>
            Empty,

            /// <summary>If sequence item is a data tag</summary>
            TagItem,

            /// <summary>If sequence item is a data tag with a condition</summary>
            TagItemWithCondition
        };

        /// <summary>Holds information about the items in a seuqnece</summary>
        private struct SequenceItem
        {
            /// <summary>Type of a HL7 sequence</summary>
            public SequenceItemType type;    

            /// <summary>either data tag name or fixed data text depeing on type</summary>
            public string data;

            /// <summary>condition for data tag</summary>
            public string condition;

            /// <summary>Value to compare the condition to</summary>
            public int value;

            /// <summary>Constructor</summary>
            /// <param name="type">HL7 sequence type</param>
            /// <param name="data">data tag name or fixed data text</param>
            public SequenceItem(SequenceItemType type, string data)
            {
                this.type      = type;
                this.data      = data;
                this.condition = string.Empty;
                this.value     = 0;
            }

            /// <summary>Constructor</summary>
            /// <param name="type">HL7 sequence type</param>
            /// <param name="data">data tag name or fixed data text</param>
            /// <param name="condition">Condition for data sequence length either '>', '>=', '=', '<=', '<'</param>
            /// <param name="value">Value to compare condtion data</param>
            public SequenceItem(SequenceItemType type, string data, string condition, int value)
            {
                this.type       = type;
                this.data       = data;
                this.condition  = condition;
                this.value      = value;
            }
        }; 
        #endregion

        #region Data Memebers
        /// <summary>List of sequence items in a template</summary>
        private List<List<SequenceItem>> sequenceList = new List<List<SequenceItem>>();        

        /// <summary>The template string</summary>
        private string template;
        #endregion

        #region Public Properties
        /// <summary>Template name</summary>
        public string Name { get; private set; }        
        #endregion

        #region Public Methods
        /// <summary>Initalises the structure with a template</summary>
        /// <param name="name">Tempalte name</param>
        /// <param name="template">HL7 tempalte</param>
        /// <param name="reservedChars">Used to set the HL7 reserved character structure the template used (set from the header)</param>
        public void Initalise(string name, string template, HL7ReservedChars reservedChars)
        {
            this.Name = name;
            this.template = template;

            // Replaced all escaped character with non readable chars
            string templateHiddenEscapedChars = reservedChars.ReplaceEscapedTagWithHiddenTag(template, true);

            // Break up the template into a sequence list
            sequenceList.Clear();
            foreach (string sequence in templateHiddenEscapedChars.Split(reservedChars.segmentSplitter))
                sequenceList.Add(DecodeSequence(sequence, reservedChars));
        }

        /// <summary>Try to parse the message using the template</summary>
        /// <param name="message">Message to parse</param>
        /// <param name="reservedChars">Used to set the HL7 reserved character structure the template used (set from the header)</param>
        /// <param name="mapper">Contains mapping of data tags to sequence values (even if message was not sucessfully mapped)</param>
        /// <returns>If message mapped correctly</returns>
        public bool TryParse(string message, HL7ReservedChars reservedChars, Dictionary<string, string> mapper)
        {
            // Replaced all escaped character with non readable chars
            string messageHiddenEscapedChars = reservedChars.ReplaceEscapedTagWithHiddenTag(message, true);

            // split message into sequence items
            string[] splitMessage = messageHiddenEscapedChars.Split(reservedChars.segmentSplitter);

            // If wrong length then end
            if (splitMessage.Length < sequenceList.Count)
                return false;

            // test each sequence item to ensure it matches
            for (int c = 0; c < sequenceList.Count; c++)
            {
                if (splitMessage.Length <= c)
                    return false;
                if (!TryParseSequence(c, splitMessage[c], reservedChars, mapper))
                    return false;
            }

            return true;
        }        
        #endregion

        #region Private Methods
		/// <summary>
        /// Converts the HL7 template sequence item into a number of SequenceItems
        /// There maybe more than one item returned if the sequence item contains 
        /// both fixed text and data tags
        /// </summary>
        /// <param name="templateSequence">Tempalte sequence</param>
        /// <param name="reservedChars">Used to set the HL7 reserved character structure the template used (set from the header)</param>
        /// <returns>SequenceItem maybe more than one item returned if the sequence item contains both fixed text and data tags</returns>
        private List<SequenceItem> DecodeSequence(string templateSequence, HL7ReservedChars reservedChars)
        {
            // Test there are not two data tags next to each other in the sequence as can't separate
            if (templateSequence.Contains("]["))
                throw new ApplicationException(string.Format("Template {0} can't have one tag preceding another without fixed characters in-between", Name));

            List<SequenceItem> sequenceItems = new List<SequenceItem>();

            // Split on data tag end
            string[] itemASplit = templateSequence.Split(']');
            for (int a = 0; a < itemASplit.Length; a++)
            {
                // Ignore empty items due to way split function works
                if (string.IsNullOrEmpty(itemASplit[a]))
                    continue;

                // Find start of data tag
                int tagStart = itemASplit[a].IndexOf('[');
                if (tagStart == -1)
                {
                    // Fixed length string but test not just closing tag with and opening tag
                    if ((a + 1) != itemASplit.Length)
                        throw new ApplicationException(string.Format("Template {0} contains a closing tag ] without an opening tag [", Name));

                    // as fixed length string set start of data tag to end of fixed length string (so effectivly it will be ignored)
                    tagStart = itemASplit[a].Length;
                }
                else if (itemASplit[a].IndexOf('[', tagStart + 1) != -1)    // Test it is not a opening tag without a closing tag
                    throw new ApplicationException(string.Format("Template {0} contains an opening tag [ without a closing tag ]", Name));

                // Get the fixed text part of the sequence, and the data tag part
                string fixedText = reservedChars.ReplaceHiddenTagWithActualTag(itemASplit[a].SafeSubstring(0, tagStart), true, false);
                string tagData   = itemASplit[a].SafeSubstring(tagStart + 1, itemASplit[a].Length - tagStart);

                if (tagData == EmptyDataTag)
                {
                    // Reserved empty data tag so check no other items, and then add new empty SequenceItem to list
                    if ((itemASplit.Length > 2) || !string.IsNullOrEmpty(itemASplit[1]))
                        throw new ApplicationException("A sequence with an [Empty] tag can't contain other items.");
                    sequenceItems.Add(new SequenceItem(SequenceItemType.Empty, string.Empty));
                }
                else
                {
                    // If fixed text item then add to sequence
                    if (!string.IsNullOrEmpty(fixedText))
                        sequenceItems.Add(new SequenceItem(SequenceItemType.FixedData, fixedText));

                    // If data tag item the add to sequence
                    if (!string.IsNullOrEmpty(tagData))
                    {
                        // Get condition statment (if present)
                        string[] splitTagData = tagData.Split(':');

                        if (splitTagData.Count() == 1)
                            sequenceItems.Add(new SequenceItem(SequenceItemType.TagItem, splitTagData[0])); // No condition so simple tag item
                        else if (splitTagData.Count() == 2)
                        {
                            // Split the conditino part into condition statment and number part
                            string condition = splitTagData[1];
                            int valueStart = condition.IndexOfAny(Numbers);
                            if (valueStart == -1)
                                throw new ApplicationException(string.Format("Invalid condition statment template {0} condition {1}.", Name, condition));

                            string conditionValueStr = condition.Substring(valueStart, condition.Length - valueStart);
                            string conditionType  = condition.Substring(0, valueStart);
                            int conditionValue;

                            // Validate the condition
                            if (!ValidateCondition(conditionType))
                                throw new ApplicationException(string.Format("Unsupported condition for template {0} condition '{1}'.", Name, conditionType));

                            // Validate the number part
                            if (!int.TryParse(conditionValueStr, out conditionValue))
                                throw new ApplicationException(string.Format("Condition for template {0} condition value '{1}' must have an integer data type.", Name, conditionValueStr));

                            // Add the tag item with a condition
                            sequenceItems.Add(new SequenceItem(SequenceItemType.TagItemWithCondition, splitTagData[0], conditionType, conditionValue));
                        }
                    }
                }
            }

            return sequenceItems;
        }

        /// <summary>Tries to parse message sequence item against the template</summary>
        /// <param name="sequenceIndex">Index into the sequence template</param>
        /// <param name="sequence">sequence item in the message</param>
        /// <param name="reservedChars">Used to set the HL7 reserved character structure the template used (set from the header)</param>
        /// <param name="mapper">Contains mapping of data tags to sequence values (even if message was not sucessfully mapped)</param>
        /// <returns>If sequence item parsed correctly</returns>
        private bool TryParseSequence(int sequenceIndex, string sequence, HL7ReservedChars reservedChars, Dictionary<string, string> mapper)
        {
            List<SequenceItem> sequenceItems = sequenceList[sequenceIndex]; // Get the template's sequence item to test againsts
            int pos = 0;    // Position in the message

            // Iterate through each item in the sequence tempalte
            for (int itemIndex = 0; itemIndex < sequenceItems.Count; itemIndex++)
            {
                switch (sequenceItems[itemIndex].type)
                {
                case SequenceItemType.FixedData:
                    // If fixed test it matches (and move iterate on by text length incase there is a data tag after the fixed text)
                    if (sequence.SafeSubstring(pos).StartsWith(sequenceItems[itemIndex].data))
                        pos = pos + sequenceItems[itemIndex].data.Length;
                    else
                        return false;
                    break;

                case SequenceItemType.Empty:
                    // Empty data tag so check it is empty then end
                    return (sequence == string.Empty);

                case SequenceItemType.TagItemWithCondition:
                case SequenceItemType.TagItem:
                    // Tag used to extract data from a message

                    // First get end position of the tag data either end of sequence
                    // or to the start of the next data tag
                    int endPos = sequence.Length;
                    if (sequenceItems.Count > (itemIndex + 1))
                    {
                        endPos = sequence.IndexOf(sequenceItems[itemIndex + 1].data, pos);
                        if (endPos == -1)
                            return false;
                    }

                    // Get the data tag name, and it's data from the message
                    string itemTagName = sequenceItems[itemIndex].data;
                    string itemTagData = reservedChars.ReplaceHiddenTagWithActualTag(sequence.SafeSubstring(pos, endPos - pos), true, true);                    

                    // If the tag item template has a condition then verify the condition
                    if ((sequenceItems[itemIndex].type == SequenceItemType.TagItemWithCondition) && 
                        !CheckCondition(itemTagData.Length, sequenceItems[itemIndex].condition, sequenceItems[itemIndex].value))
                        return false;

                    // Add data to the dictionary
                    mapper[itemTagName] = itemTagData;

                    // Move to the end of the data sequence
                    pos = pos + (endPos - pos);
                    break;
                }
            }

            return true;
        }

        /// <summary>Validates that the condition equality operator (e.g. =, ==, >)</summary>
        /// <param name="conditionType">condition equality operator</param>
        /// <returns>If valid condition</returns>
        private bool ValidateCondition(string conditionType)
        {
            switch (conditionType.Trim())
            {
            case "<" : return true;
            case "<=": return true;
            case "=" : return true;
            case "==": return true;
            case ">" : return true;
            case ">=": return true;
            }

            return false;
        }

        /// <summary>Checks if the condition is valid</summary>
        /// <param name="valueA">Left side of condition</param>
        /// <param name="condition">Condition to used (e.g. =, ==, >)</param>
        /// <param name="valueB">Right side of condition</param>
        /// <returns></returns>
        private bool CheckCondition(int valueA, string condition, int valueB)
        {
            switch (condition)
            {
            case "<" : return valueA <  valueB;
            case "<=": return valueA <= valueB;
            case "==":
            case "=" : return valueA ==  valueB;
            case ">" : return valueA >  valueB;
            case ">=": return valueA >= valueB;
            }

            return false;
        } 
	    #endregion    
    }
}
