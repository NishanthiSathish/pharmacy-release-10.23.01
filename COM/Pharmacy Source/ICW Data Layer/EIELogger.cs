//===========================================================================
//
//					            EIELogger.cs
//
//  Provides helper functions to write to the EIE logger tables.
//  These include the 
//      ApplicationLog    
//      ApplicationError
//      MessageError
//  It provides a web replacment of the EIE logger class.
//
//  Usage
//  To write to the MessageError table
//  EIELogger logger = new EIELogger("RobotLoader");
//  logger.LogError(454, 2, ex, 0, string.Empty, messageID);
//
//	Modification History:
//  03Oct13 XN  Created 74592
//===========================================================================
using System;
using System.Diagnostics;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

namespace ascribe.pharmacy.icwdatalayer
{
    /// <summary>Web replacment for the Pharmacy EIE logger class</summary>
    public class EIELogger
    {
        private string instanceName;

        /// <summary>Constructor</summary>
        /// <param name="instanceName">EIE instance </param>
        public EIELogger(string instanceName)
        {
            this.instanceName = instanceName;
        }

        /// <summary>If the LogError method has been called</summary>
        public bool HasMessageErrored { get; private set; }

        /// <summary>Saves error message to the MessageError table</summary>
        /// <param name="sessionId">Session ID</param>
        /// <param name="interfaceComponentId">Component that raised the error</param>
        /// <param name="ex">Exception</param>
        /// <param name="errorGroupId">Error group</param>
        /// <param name="extraInfo">Extra error info</param>
        /// <param name="messageID">Message ID</param>
        public void LogError(int sessionId, int interfaceComponentId, Exception ex, int errorGroupId, string extraInfo, Guid messageID)
        {
            MessageError errorMessageTable = new MessageError();
            
            HasMessageErrored = true;

            try
            {
                // Get error type
                ICWTypeData? typeData = ICWTypes.GetTypeByDescription(ICWType.EIELogType, "Error");
                if (typeData == null)
                    throw new ApplicationException("Invalid EIE LogType 'Error'");

                // Create one line for each exception
                int tableID = errorMessageTable.GetTableID();;
                DateTime now = DateTime.Now;
                int parentID = 0;
                Exception except = ex;
                while (except != null)
                {
                    MessageErrorRow row = errorMessageTable.Add();
                    row.ApplicationLogID_parent = parentID;
                    row.Description             = except.Message;
                    row.ErrorGroupID            = errorGroupId;
                    row.ExtraInfo               = extraInfo;
                    row.InterfaceComponentID    = interfaceComponentId;
                    row.LogTypeID               = typeData.Value.ID;
                    row.MessageGuid             = messageID;
                    row.Occurred                = now;
                    row.Source                  = except.Source;
                    row.StackTrace              = except.StackTrace;
                    row.TableID                 = tableID;  
                    
                    except = except.InnerException;
                } 

                errorMessageTable.Save();
            }
            catch(Exception e)
            {
                AddApplicationLogEntry(ex);
                AddApplicationLogEntry(e);
            }
        }

        /// <summary>Saves error to the windows Application Log</summary>
        public void AddApplicationLogEntry(Exception ex)
        {
            EventLog ev = new EventLog("Application");
            ev.Log = "Application";

            try
            {
                Exception except = ex;
                string msg;
                while (except != null)
                {
                    string sourceName = "ascribeplc Interface - " + instanceName;

                    if (!EventLog.SourceExists(sourceName))
                        EventLog.CreateEventSource(sourceName, "Application"); 
                
                    msg = except.Message + "\r\n" + except.Source + "\r\n" + except.StackTrace;
                    msg = msg.SafeSubstring(0, 32767);

                    ev.Source = sourceName;
                    ev.WriteEntry(msg, EventLogEntryType.Error);
                    
                    except = except.InnerException;
                }
            }
            finally
            {
                ev.Dispose();
            }
        }
    }

    /// <summary>Represents row in the ApplicationLog table</summary>
    internal class ApplicationLogRow : BaseRow
    {
        public int      ApplicationLogID        { set { RawRow["ApplicationLogID"]        = IntToField(value);      } }
        public int      ApplicationLogID_parent { set { RawRow["ApplicationLogID_parent"] = IntToField(value);      } }
        public int      LogTypeID               { set { RawRow["LogTypeID"]               = IntToField(value);      } }
        public int      TableID                 { set { RawRow["TableID"]                 = IntToField(value);      } }
        public DateTime Occurred                { set { RawRow["Occurred"]                = DateTimeToField(value); } }
        public string   Source                  { set { RawRow["Source"]                  = StrToField(value);      } }
        public string   Description             { set { RawRow["Description"]             = StrToField(value);      } }
        public int      InterfaceComponentID    { set { RawRow["InterfaceComponentID"]    = IntToField(value);      } }
    }

    /// <summary>Represents row in the ApplicationError table</summary>
    internal class ApplicationErrorRow : ApplicationLogRow
    {
        public int    ErrorGroupID  { set { RawRow["ErrorGroupID"] = IntToField(value);  } }
        public string StackTrace    { set { RawRow["StackTrace"]   = StrToField(value);  } }
        public string ExtraInfo     { set { RawRow["ExtraInfo"]    = StrToField(value);  } }
    }

    /// <summary>Represents row in the MessageError table</summary>
    internal class MessageErrorRow : ApplicationErrorRow
    {
        public Guid MessageGuid { set { RawRow["MessageGuid"] = GuidToField(value); } }
    }

    internal class MessageErrorColumnInfo : BaseColumnInfo
    {
        public MessageErrorColumnInfo () : base("MessageError") {}
    }

    /// <summary>Represnets the MessageError table</summary>
    internal class MessageError : BaseTable2<MessageErrorRow, BaseColumnInfo>
    {
        public MessageError() : base("MessageError", "ApplicationError", "ApplicationLog") {}
    }
}
