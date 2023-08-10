//===========================================================================
//
//							RobotLoadingMsgTemplate.cs
//
//  Provides access to RobotLoadingMsgTemplate table.
//
//  RobotLoadingMsgTemplate holds the HL7 receiver and reply message tables.
//  Used by the this module.
// 
//  Each robot will require a single ReceiverHeader, and number of Received 
//  message templated to decode the message received from the robot.
//  There will also need to be a single ReplyHeader, and number of Reply
//  message templates to send message back to the robot.
//
//  Only supports reading, and inserting
//
//	Modification History:
//	21Dec09 XN Written
//===========================================================================
using System.Text;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.robotloading
{
    /// <summary>Robot Loading message template type</summary>
    public enum  RobotLoaderMsgType
    {
        /// <summary>Template for message header received from robot (only allowed one per robot)</summary> 
        [EnumDBCode("ReceivedHeader")]
        ReceivedHeader,

        /// <summary>Template for message received from robot</summary> 
        [EnumDBCode("Received")]
        Received,

        /// <summary>Template for message reply header sent to robot (only allowed one per robot)</summary> 
        [EnumDBCode("ReplyHeader")]
        ReplyHeader,

        /// <summary>Template for message reply sent to robot</summary> 
        [EnumDBCode("Reply")]
        Reply,
    };

    /// <summary>Represent a row in the RobotLoaderMsgTemplate table</summary>
    public class RobotLoaderMsgTemplateRow : BaseRow
    {
        public int RobotLoaderMsgTemplateID 
        { 
            get { return FieldToInt(RawRow["RobotLoadingMsgTemplateID"]).Value; }
        }

        /// <summary>Name used to identify the robot that uses these messages</summary>
        public string RobotName
        {
            get { return FieldToStr(RawRow["RobotName"]);  }
            set { RawRow["RobotName"] = StrToField(value); }
        }

        /// <summary>template type</summary>
        public RobotLoaderMsgType MessageType 
        { 
            get { return FieldStrToEnum<RobotLoaderMsgType>(RawRow["MessageType"], true).Value; }
            set { RawRow["MessageType"] = EnumToFieldStr<RobotLoaderMsgType>(value);            }
        }

        /// <summary>Name of the template (should be unique for robot an message type)</summary>
        public string Name
        {
            get { return FieldToStr(RawRow["Name"]);  }
            set { RawRow["Name"] = StrToField(value); }
        }

        /// <summary>Message template</summary>
        public string MessageTemplate
        {
            get { return FieldToStr(RawRow["MessageTemplate"]);  }
            set { RawRow["MessageTemplate"] = StrToField(value); }
        }
    }

    /// <summary>Provides column information about the RobotLoaderMsgTemplate table</summary>
    public class RobotLoaderMsgTemplateColumnInfo : BaseColumnInfo
    {
        public RobotLoaderMsgTemplateColumnInfo() : base("RobotLoadingMsgTemplate") { }

        public int GetInterfaceNameLength    { get { return tableInfo.GetFieldLength("InterfaceName");   } }
        public int GetNameLength             { get { return tableInfo.GetFieldLength("Name");            } }
        public int GetMessageTemplateLength  { get { return tableInfo.GetFieldLength("MessageTemplate"); } }
    }

    /// <summary>Represent the RobotLoaderMsgTemplate table</summary>
    public class RobotLoaderMsgTemplate : BaseTable<RobotLoaderMsgTemplateRow, RobotLoaderMsgTemplateColumnInfo>
    {
        public RobotLoaderMsgTemplate() : base("RobotLoadingMsgTemplate", "RobotLoadingMsgTemplateID") { }

        /// <summary>Loads all the templates for a robot</summary>
        /// <param name="robotName">Robot name</param>
        public void LoadByRobotName(string robotName)
        {
            StringBuilder parameters = new StringBuilder();
            AddInputParam(parameters, "RobotName",   robotName);
            LoadRecordSetStream("pRobotLoadingMsgTemplateByRobotName", parameters);
        }
    }
}
