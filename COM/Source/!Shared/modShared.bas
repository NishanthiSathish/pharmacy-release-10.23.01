Attribute VB_Name = "modShared"
Option Explicit

Private Const MODULE_NAME As String = "modShared" ' Name of this source file, used in error handling

Public Const BR_NO_RULES_BROKEN As String = vbNullString ' A vbNullString equates to no broken rules
Public Const SECURITY_SESSION_ID As Long = -&H7AFE ' SessionID used ONLY by the security system for LoginUser and ChangeUserPassword. Provides extremely limited access to 3 SPs in the system i.e. pUserLogin, pUserChangePassword, pSettingXML

' Handlable native SQL error numbers
Private Const SQL_ERROR_REFERENTIAL_INTEGRITY = 547
Private Const SQL_ERROR_UNIQUE_COLUMN = 2627
Private Const SQL_ERROR_COLUMNREFCONSTRAINT = -96383                                                              '30Apr04 AE  Re-added erSQLColumReferenceConstraint

Private Const NUMERIC_MASK = "0.00"                'Mask used to format decimals for display.

' An enumeration of all developer-defined BrokenRule messages
Public Enum enuPolicy
   MetaDataAdministrationPolicy
   MetaDataReadPolicy
End Enum

' An enumeration of all developer-defined custom error messages
Public Enum LibErrorEnum
   erLoadXMLFailed = vbObjectError + 100000
   erBrokenRuleNotFound = vbObjectError + 100001
   erConnectionStringUndefined = vbObjectError + 100002
   erCOMPlusNotInTransaction = vbObjectError + 100003
   erInvalidSessionID = vbObjectError + 100004
   erTableIDMissing = vbObjectError + 10005
   erNullNotAllowed = vbObjectError + 10006
   erRoutineNotFound = vbObjectError + 10007
   erApplicationMenuItemLinked = vbObjectError + 10008
   erPermissionDenied = vbObjectError + 10009
   erOCSGridNodeDuplication = vbObjectError + 10010
   erOCSCreateScheduleFail = vbObjectError + 10011
   erVirtualRowBit = vbObjectError + 10012
   erVirtualRowDateTime = vbObjectError + 10013
   erUpdateRowNotFound = vbObjectError + 10014
   erUnknownDateFormat = vbObjectError + 10015
   erInputStringExceedsWidth = vbObjectError + 10016
   erRebuildAttemptReapeat = vbObjectError + 10017
   
   erDSSCannotConvertBetweenUnitTypes = vbObjectError + 10100                                                     '10Sep03 AE  Added
   erDSSRoutineFail = vbObjectError + 10100                                                                       '04Nov03 AE  Added
   erDssInvalidComparison = vbObjectError + 10101                                                                 '13Nov03 AE  Added
   errDssScheduleInvalid = vbObjectError + 10102
   erMissingTypeDefinition = vbObjectError + 10201                                                                '28Jun04 AE  Added.  Indicates a missing request, response, or note type
   erOCSCannotAttachNoteToType = vbObjectError + 10301                                                            '10Sep04 AE  Added.  An attempt to attach a note to something we don't support attached notes on

   ' Keep these at the end
   erSQLReferentialIntegrity = vbObjectError + 100000 + SQL_ERROR_REFERENTIAL_INTEGRITY
   erSQLColumReferenceConstraint = vbObjectError + 100000 + SQL_ERROR_COLUMNREFCONSTRAINT                         '30Apr04 AE  Re-added.  Had got lost in one of the modShared sharing failiures
   erSQLUniqueColumn = vbObjectError + 100000 + SQL_ERROR_UNIQUE_COLUMN

End Enum

Declare Function GetUserName& Lib "advapi32.dll" Alias "GetUserNameA" (ByVal lpBuffer As String, nSize As Long)

' Used to store the vb Err object data
Public Type udtErrorState
   Description As String
   HelpContext As String
   HelpFile As String
   Number As Long
   Source As String
   LastDllError As Long
End Type

'-----------------------------------------------------------------------------------
' Project Name:   All
'
' Item:           modShared
'
' Purpose:        Static subs and functions that are not contained in classes
'
' Configuration Record
' Version         Author       Date     Change No.
' 1.0             Peter Hughes 4Sep02   Ported from v9 ICW with extensive modification
'
' @ Copyright ASC Computer Systems 2002
'
'Revision History
' 4Sep2002 PH Created
'----------------------------------------------------------------------------------
'
'   Provides simple wrappers to improve error tracing.
'
'Public Sub CaptureErrorState(ErrorState_OUT As udtErrorState, strProcedureName As String, Optional strParameterValues As String, _
'                             Optional strExtraInfo As String, cn As ADODB.Connection)
'  -Use inside your 'capture all' error handler to store the state of the error object, along
'   with any useful extra info you specify, so that it can be raised later.
'
'Public Sub BubbleOnError(ErrorState_OUT as udtErrorState)
'
'  -Use during your cleanup code to pass on any untrapped errors that occured earlier in your code.
'  ***NOTE: All calls to BubbleOnError _must_ be preceded by an On Error Goto 0 statement,
'           otherwise an error will cause an infinite loop between BubbleOnError and the
'           error handler.
'
'
'Sub MyProcedure(strMyParameter as String)
'
'Dim ErrorState as udtErrorState
'
'  On Error Goto Errorhandler
'     '
'     '
'     Code
'     '
'     '
'Cleanup:
'   '----- clean up code goes here
'
'   on error goto 0
'   BubbleOnError ErrorStateOUT
'
'   Exit Sub
'
'ErrorHandler:
'   CaptureErrorState(ErrorState, strProcedureName As String, [strParameterValues As String], [strExtraInfo As String], [cn As ADODB.Connection])
'   Resume Cleanup
'
'End Sub
'
'
'Be aware that this process stores information in the Err object. Thus as the error is passed
'back up, you must avoid using any statements which clear the Err object (eg On Error statements).
'
'--------------------------------------------------------------------------------------

Public Sub RaiseError( _
                        ByVal lngErrorNumber As LibErrorEnum, _
                        Optional ByVal strExtraInfo As String _
                     )
'-----------------------------------------------------------------
' Purpose:  This sub is used as a replacement for the vb command err.raise
'           In the rare cases where you wish to raise your own errors,
'           this the the command to use!
'           Error numbers are defined in the enum LibErrorEnum, just above
'           this sub. If you wish to raise and error that is not listed,
'           then simply add it to the enum above, and define it's description
'           in the case statements below.
'
' Inputs:   lngErrorNumber - an error number contained in the LibErrorEnum
'           strExtraInfo   - additional error info about the error
'
' Outputs:  None
'
' Return :  None
'
' Revision History
' 4Sep02 PH Created
'
'------------------------------------------------------------------------'
   Dim strDescription As String
   
   Select Case lngErrorNumber
      Case erLoadXMLFailed
         strDescription = ".loadXML(): Unable to load XML string"
      Case erBrokenRuleNotFound
         strDescription = "BrokenRule not found"
      Case erConnectionStringUndefined
         strDescription = "No connection string specified in the COM+ constructor string. Ensure you have registered TRNRTL DLL in COM+, enabled object construction, and specified database connection string."
      Case erCOMPlusNotInTransaction
         strDescription = "No transaction set for method that requires a transaction. Check COM+ components are registered in COM+. Check that the VB MTSTransactionMode properties on the calling classes are set RequiresTransaction. Classes that do any database writing, or call any other class that do database writing, MUST be set to RequiresTransaction. Classes that only read from the database, MUST be set to UsesTransaction providing they do not call any methods that perform database writes."
      Case erInvalidSessionID
         strDescription = "This session is no longer valid; one possible cause is someone has logged on elsewhere using this user name. (Invalid SessionID passed to the transport layer)."
      Case erRebuildAttemptReapeat
         strDescription = "Stored procedure rebuild attempted multiple times; aborting.  (The rebuild should only be attempted once; this error is to prevent the possibility of becomming stuck in a loop)."
      Case erTableIDMissing
         strDescription = "GetDynamicParameters : TableID is a required attribute of the passed XML document"
      Case erNullNotAllowed
         strDescription = "GetDynamicParameters : Missing attribute. The field in this table cannot be null"
      Case erRoutineNotFound
         strDescription = "Routine not found. The routine table is missing a record that it expects to exist."
      Case erApplicationMenuItemLinked
         strDescription = "Save error: one or more menuitems may still be linked to an application. Please remove any links first."
      Case erVirtualRowBit
         strDescription = "XML Bit columns passed to Virtual Row methods may only contain a 0 or a 1"
      Case erVirtualRowDateTime
         strDescription = "XML DateTime columns passed to Virtual Row methods must be in ISO8601 format e.g. ccyy-mm-ddThh:nn:ss"
      Case erUnknownDateFormat
         strDescription = "Unknown date/time format passed to transport layer. Date/Times must be either VB Date objects, ISO8601 format strings (ccyy-mm-ddThh:nn:ss), or 5 character 24-hour time strings (hh:nn)"
      
      Case erInputStringExceedsWidth
         strDescription = "Text length exceeds parameters size."

      Case erOCSGridNodeDuplication
         strDescription = "FormatForOCSGrid: OCSGridNodeDuplication. Duplicate node exists."
      Case erOCSCreateScheduleFail
         strDescription = "Call to PutSchedule failed; save cannot be completed."
      Case erUpdateRowNotFound
         strDescription = "Attempt to update a row using a primary key that cannot be found."
      Case erMissingTypeDefinition
         strDescription = "The database is missing a Request, Response, or Note type definintion.  The program cannot continue until this type is configured."
      Case erOCSCannotAttachNoteToType
         strDescription = "Invalid AttachToType parameter specified. Notes can only be attached to PendingItems, Requests, or Responses."
      
      Case Else
         strDescription = "Error constant has no matching description in modShared.RaiseError"
   End Select
   
   strDescription = strDescription & " " & strExtraInfo
   
   Err.Raise lngErrorNumber, "RaiseError", strDescription
End Sub

Public Function CaptureErrorState( _
                                    ByRef ErrorState_OUT As udtErrorState, _
                                    ByVal strModuleName As String, _
                                    ByVal strProcedureName As String, _
                                    Optional ByVal strParameterValues As String = vbNullString, _
                                    Optional ByVal strExtraInfo As String = vbNullString, _
                                    Optional ByVal cn As Object = Nothing _
                                 ) _
                                 As String
   
'-----------------------------------------------------------------
' Purpose:  Used in each subroutine's ErrorHandler block to capture the state of
'           the VB Err object so that it can be use later by BubbleOnError.
'
'           The extra parameters allow the develop to include useful extra info that
'           will help to locate and debug any errors that occur in a production environment.
'
'           The Err.Source property of the Vb Error object is used to store additional information
'
' Inputs:   ErrorState              - udt used to store the state of the VB Err object
'           strModuleName        - Name of calling module
'           strProcedureName     - Name of calling procedure
'           [strParameterValues] - Caller routine's input paramter values
'           [strExtraInfo]       - Addition info that may prove useful for debugging
'           [cn]                 - ADO Connection object, used to examine any ADO Errors that may exist
'
'
' Outputs: None
'
' Return :  None
'
' Revision History
' 4Sep02 PH Created
' 24Jun05 AE  Removed some of the duplication and noise from the source field to make error reporting easier for users.
'------------------------------------------------------------------------'
Dim adoError As Object
Dim strUserContext As String * 200
Dim astrConnection() As String
Dim astrField() As String
Dim intCount As Integer
   
   ' Save current state of VB Err object into ErrorState udt, so it can be re-created in later instances up the callstate
   With ErrorState_OUT
      .Number = Err.Number
      .Description = Err.Description
      .HelpContext = Err.HelpContext
      .HelpFile = Err.HelpFile
      .Source = Err.Source
      .LastDllError = Err.LastDllError
   End With
   
   ' Check that this is the first occurance of CaptureErrorState being being called for the current error condition
   If InStr(ErrorState_OUT.Source, "Callstack:") = 0 Then
      ' This is the first occurance, so proceed
      
      ' If ErrorStateOUT.Number is 0 at this stage then error information has been lost somehow
      If ErrorState_OUT.Number = 0 Then
         ErrorState_OUT.Description = "Error details lost"
      End If
      
      ' See if the error is a handlable SQL error, and if so replace err.number with our own error number
      If Not (cn Is Nothing) Then
         If cn.Errors.Count > 0 Then
            Select Case cn.Errors(0).NativeError
               Case SQL_ERROR_REFERENTIAL_INTEGRITY:
                  ErrorState_OUT.Number = erSQLReferentialIntegrity
               Case SQL_ERROR_UNIQUE_COLUMN:
                  ErrorState_OUT.Number = erSQLUniqueColumn
            End Select
         End If
      End If
      
      ' Get UserContext
      GetUserName strUserContext, Len(strUserContext)
      
      ' Add extra error information to ErrorState_OUT.Source property in XML format                                                    '24Jun05 AE  Removed duplication & noise
      ErrorState_OUT.Source = _
                                   "Occured at:   " & Format(Now, "yyyy/mm/dd hh:nn:ss") & vbCr _
                                 & "Exe:          " & App.Path & "\" & App.EXEName & vbCr _
                                 & "Version:      " & App.Major & "." & App.Minor & "." & App.Revision & vbCr _
                                 & "LastDLLError: " & ErrorState_OUT.LastDllError & vbCr _
                                 & "ThreadID:     " & App.ThreadID & vbCr _
                                 & "UserContext:  " & Left$(strUserContext, InStr(strUserContext, ChrW$(0)) - 1) & vbCr
'
'      ErrorState_OUT.Source = _
'                                   "Occured:      " & Format(Now, "yyyy/mm/dd hh:nn:ss") & vbCr _
'                                 & "Number:       " & ErrorState_OUT.Number & vbCr _
'                                 & "Source:       " & ErrorState_OUT.Source & vbCr _
'                                 & "EXEName:      " & App.EXEName & vbCr _
'                                 & "Path:         " & App.Path & vbCr _
'                                 & "Version:      " & App.Major & "." & App.Minor & "." & App.Revision & vbCr _
'                                 & "HelpContext:  " & ErrorState_OUT.HelpContext & vbCr _
'                                 & "HelpFile:     " & ErrorState_OUT.HelpFile & vbCr _
'                                 & "LastDLLError: " & ErrorState_OUT.LastDllError & vbCr _
'                                 & "ThreadID:     " & App.ThreadID & vbCr _
'                                 & "UserContext:  " & Left$(strUserContext, InStr(strUserContext, ChrW$(0)) - 1) & vbCr

      ' If an ADODB.Connection has been passed in, then add it and any ADO errors to the XML
      If (Not cn Is Nothing) Then
         ErrorState_OUT.Source = ErrorState_OUT.Source & vbCr & "ConnectionString:"
         
         'Return the connection string, but blank out the password field
         astrConnection = Split(cn.ConnectionString, ";")
         For intCount = 0 To UBound(astrConnection) - 1
            astrField = Split(astrConnection(intCount), "=")
            Select Case LCase(astrField(0))
               Case "pwd", "password", "uid", "username"
                  'Blank the password and username fields
                  astrField(1) = "******"
                  
            End Select
            
            ErrorState_OUT.Source = ErrorState_OUT.Source & astrField(0) & "=" & astrField(1) & ";"
            
         Next
         
         
'         ErrorState_OUT.Source = ErrorState_OUT.Source & vbCr & "ConnectionString:" & cn.ConnectionString & vbCr
         
         
         
         ErrorState_OUT.Source = ErrorState_OUT.Source & vbCr & "ADO Errors:" & vbCr
         For Each adoError In cn.Errors
            ErrorState_OUT.Source = ErrorState_OUT.Source & vbCr _
                                    & "Description: " & adoError.Description & vbCr _
                                    & "NativeError: " & adoError.NativeError & vbCr _
                                    & "SQLState:    " & adoError.SQLState & vbCr                                                             '24Jun05 AE  Removed duplication & noise
'            ErrorState_OUT.Source = ErrorState_OUT.Source & vbCr _
'                                    & "Description: " & adoError.Description & vbCr _
'                                    & "HelpContext: " & adoError.HelpContext & vbCr _
'                                    & "HelpFile:    " & adoError.HelpFile & vbCr _
'                                    & "NativeError: " & adoError.NativeError & vbCr _
'                                    & "Number:      " & adoError.Number & vbCr _
'                                    & "Source:      " & adoError.Source & vbCr _
'                                    & "SQLState:    " & adoError.SQLState & vbCr
                                    
         Next adoError
      End If
      
      ' Record error in Windows event log.
      App.LogEvent ErrorState_OUT.Source & vbCr & "Procedure: " & vbCr & "  " & strModuleName & "." & strProcedureName & "(" & strParameterValues & ")" & vbCrLf & "    ExtraInfo: " & strExtraInfo, vbLogEventTypeError
      
      ' Add callstack entry into ErrorState_OUT.Source string
      ErrorState_OUT.Source = ErrorState_OUT.Source & vbCr & "Callstack:" & vbCr
      
   End If
   
   ErrorState_OUT.Source = ErrorState_OUT.Source & "  " & strModuleName & "." & strProcedureName & "(" & strParameterValues & ")"
   If Erl <> 0 Then
      ErrorState_OUT.Source = ErrorState_OUT.Source & "  Line: " & Erl
   End If
   ErrorState_OUT.Source = ErrorState_OUT.Source & vbCrLf
   
   ' Add extra info, if included
   If strExtraInfo <> vbNullString Then
      ErrorState_OUT.Source = ErrorState_OUT.Source & "    ExtraInfo: " & strExtraInfo & vbCrLf
   End If

   ' Restore/update VB Error object with additional info ErrorState udt
   With Err
      .Number = ErrorState_OUT.Number
      .Description = ErrorState_OUT.Description
      .HelpContext = ErrorState_OUT.HelpContext
      .HelpFile = ErrorState_OUT.HelpFile
      .Source = ErrorState_OUT.Source
   End With
   
End Function



Public Sub BubbleOnError( _
                             ByRef ErrorState_OUT As udtErrorState _
                        )
'-----------------------------------------------------------------
' Purpose:  This sub should exist as the last executed line at the bottom of
'           every routine that uses  error handling. It will always be called
'           but if no error condition has been raised then it will simply return
'           control back to the calling code immediately.
'
'           Providing an error condition exists, then it restores the state of the
'           VB Err object from the values previously captured in the ErrorState udt
'           by its sister function CaptureErrorState. It will then bubble the error
'           one level futher up the callstack by using an Err.Raise call.
'
' Inputs:   ErrorState - udt used to retieve the state of the VB Err object which
'           should have been captured in the ErrorHandler section of the calling
'           routine with CaptureErrorState
'
' Outputs:  None
'
' Return :  None
'
' Revision History
' 4Sep02 PH Created
'
'------------------------------------------------------------------------'

                        
   ' Do nothing if there is no error condition present
   If ErrorState_OUT.Number <> 0 Then
      
      ' Record the current VB Error object state in the ErrorState udt
      With ErrorState_OUT
         Err.Description = .Description
         Err.HelpContext = .HelpContext
         Err.HelpFile = .HelpFile
         Err.Number = .Number
         Err.Source = .Source
      End With
      
      ' Bubble the error one level up the callstack
      Err.Raise Err.Number, Err.Source, Err.Description, Err.HelpFile, Err.HelpContext
      
   End If

End Sub

Public Function IsHandlableError(ByRef ErrorState_OUT As udtErrorState) As Boolean
'------------------------------------------------------------------------
' Purpose:  Returns true if the error number is an error that we would rather handle as a broken rule
'
' Inputs:   ErrorState
'
' Outputs:  None
'
' Return : true, if err number is one we can handle, false if not
'
' Revision History
' 18Jan03 PH Created
' 30Apr04 AE  Added erSQLColumnReferenceConstraint
'------------------------------------------------------------------------
   Select Case ErrorState_OUT.Number
      Case erSQLReferentialIntegrity, erSQLColumReferenceConstraint, erSQLUniqueColumn, erUpdateRowNotFound
         IsHandlableError = True
   End Select
End Function

Public Function ConvertErrorToBrokenRulesXML(ByRef ErrorState_OUT As udtErrorState) As String
'------------------------------------------------------------------------
' Purpose:  Returns the BrokenRulesXML version of a handlable error,
'           then clears the current error condition to prevent bubbling
'
' Inputs:   ErrorState
'
' Outputs:  None
'
' Return :  BrokenRulesXML
'
' Revision History
' 18Jan03 PH Created
' 16Apr03 PH Changed the Case Else clause to return the err.number and err.description,
'            rather than the previous "Error Unknown" message
' 30Apr04 AE Re-Added erSQLColumReferenceConstraint
' 29Jun04 AE Enhanced the SQLReferentialIntegrety message; the previous attempt at a "catch all"
'            message was often misleading and never actually helped solve the problem.
'------------------------------------------------------------------------
Dim strTemp As String
   
   Select Case ErrorState_OUT.Number
      Case erSQLReferentialIntegrity, erSQLColumReferenceConstraint
         strTemp = ErrorState_OUT.Description & vbCr & vbCr _
                 & "If you are attempting to DELETE a record, this means that the record is being referenced by other records in the " _
                 & "system; these records will have to be removed first." & vbCr & vbCr _
                 & "if you are attempting to ADD a record, this means that the record is incomplete; ensure that all fields are given " _
                 & "a value, and try again."
         ConvertErrorToBrokenRulesXML = FormatBrokenRulesXML(FormatBrokenRuleXML("SQL_REFERENTIAL_INTEGRITY", strTemp))
         
      Case erSQLUniqueColumn:
         ConvertErrorToBrokenRulesXML = FormatBrokenRulesXML(FormatBrokenRuleXML("SQL_UNIQUE_COLUMN", "This record cannot be saved because it would create a duplicate of an already existing record. Try changing the ID or description of this record, before attempting to commit it again."))
         
      Case erUpdateRowNotFound
         ConvertErrorToBrokenRulesXML = FormatBrokenRulesXML(FormatBrokenRuleXML("SQL_UPDATE_ROW_NOT_FOUND", "This item has been removed or modified by somebody else while you were editing it. The item, or list of items, you were working on will need to refreshed/reloaded to ensure you have the latest version of this data."))
         
' 21Jul05 PH Removed when RepairDB was diabled
         
'      Case SQL_ERROR_PROCEDURE_MISSING, SQL_ERROR_PARAMETER_COUNT_MISMATCH
'      'Same number is raised for these, usefully.
'         ConvertErrorToBrokenRulesXML = FormatBrokenRulesXML(FormatBrokenRuleXML("SQL_PROCEDURE_MISSING_OR_INVALID", _
'                                        "The stored procedure for the requested operation is either missing, or has the wrong number of parameters.  The procedure must " _
'                                       & "be rebuilt correctly before you can continue."))
'
'      Case SQL_ERROR_PARAMETER_TYPE_MISMATCH
'         ConvertErrorToBrokenRulesXML = FormatBrokenRulesXML(FormatBrokenRuleXML("SQL_PROCEDURE_INVALID", _
'                                        "The stored procedure for the requested operation has one or more parameters which are of the wrong type. " _
'                                        & "The procedure must be rebuilt correctly before you can continue."))
         
      Case Else
         ConvertErrorToBrokenRulesXML = FormatBrokenRulesXML(FormatBrokenRuleXML(CStr(ErrorState_OUT.Number), ErrorState_OUT.Description))
   End Select
   ' Conversion of error to BrokenRulesXML complete,
   ' now clear the ErrorState to prevent bubbling
   ErrorState_OUT.Number = 0
End Function

Public Function XMLEscape( _
                           ByVal strSource As String _
                         ) _
                         As String
'------------------------------------------------------------------------
' Purpose:  Takes a source string and returns the source string with
'           any illegal XML characters replaced with their XML Escape
'            Character equivilants
'
' Inputs:   strSource - Source string that require converting to XML format
'
' Outputs:  None
'
' Return :  Result of the source string converted to XML format
'
' Revision History
' 4Sep02 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "XMLEscape"
Dim ErrorState As udtErrorState

   On Error GoTo ErrorHandler
   
   strSource = Replace(strSource, "&", "&amp;")
   strSource = Replace(strSource, """", "&quot;")
   strSource = Replace(strSource, "'", "&apos;")
   strSource = Replace(strSource, "<", "&lt;")
   strSource = Replace(strSource, ">", "&gt;")
   XMLEscape = strSource

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME
   Resume Cleanup
End Function

Public Function XMLUnEscape( _
                           ByVal strSource As String _
                         ) _
                         As String
'------------------------------------------------------------------------
' Purpose:  Takes a source string and returns the source string with
'           any illegal XML escape characters replaced with their XML
'           iilegal character equivilants
'
' Inputs:   strSource - Source string that require converting from XML format
'
' Outputs:  None
'
' Return :  Result of the source string converted from XML format
'
' Revision History
' 23Jul12 AJK Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "XMLUnEscape"
Dim ErrorState As udtErrorState

   On Error GoTo ErrorHandler
   
   strSource = Replace(strSource, "&amp;", "&")
   strSource = Replace(strSource, "&quot;", """")
   strSource = Replace(strSource, "&apos;", "'")
   strSource = Replace(strSource, "&lt;", "<")
   strSource = Replace(strSource, "&gt;", ">")
   XMLUnEscape = strSource

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME
   Resume Cleanup
End Function


' The functions below FormatBrokenRuleXML, FormatBrokenRulesXML
' provide facilities for constructing correctly-formatted XML BrokenRules & UserMessage structure
' BrokenRules is a XML string structure used return from middle-tier business function,
' a list of business rules that have been broken

Public Function FormatBrokenRuleXML( _
                                       ByVal strRuleCode As String, _
                                       ByVal strRuleText As String, _
                                       Optional ByVal strExtraAttributes As String = vbNullString _
                                   ) _
                                   As String
'------------------------------------------------------------------------
' Purpose:  Takes a BrokenRuleCode and description, and formats them as XML
'
' Inputs:   strRuleCode - Textual code of the broken rule, as stored in the database Setting table
'           strRuleText - Corresponding text description of the code, again form the database Setting table
'           strExtra    - Extra attribute that might be useful in handling broken rule conditions e.g. FieldName associated with the broken rule
'
' Outputs:  None
'
' Return : <Rule Code="a broken rule code" Text="texual message broken rule message for the corresponding code" />
'
' Revision History
' 03Oct02 PH  Created
' 03Apr03 AE  Now escape the text to ensure we have a valid XML String; parameter strings
'             from the transport layer etc contain xml themselves and so must be escaped.
' 28Oct03 AE  Removed escape from the ExtraAttributes parameter, as we need to retain " and ' characters
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "FormatBrokenRuleXML"
Dim ErrorState As udtErrorState

   On Error GoTo ErrorHandler
   
   FormatBrokenRuleXML = "<Rule Code=""" & strRuleCode & """ Text=""" & XMLEscape(strRuleText) & """ " & strExtraAttributes & "/>"

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME
   Resume Cleanup
End Function

Public Function FormatBrokenRulesXML( _
                                       ByVal strBrokenRules_XML As String _
                                    ) _
                                    As String
'------------------------------------------------------------------------
' Purpose:  Takes BrokenRuleCode(s) XML strings constructed by the FormatBrokenRuleXML function
'           and puts <BrokenRules> .... </BrokenRules> tags around them
'
' Inputs:   strBrokenRules_XML - BrokenRuleCode(s) XML string(s) constructed by the FormatBrokenRuleXML function
'
' Outputs:  None
'
' Return : <BrokenRules> ..some broken rule XML strings.. </BrokenRules>
'
' Revision History
' 03Oct02 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "FormatBrokenRulesXML"
Dim ErrorState As udtErrorState

   On Error GoTo ErrorHandler
   
   FormatBrokenRulesXML = "<BrokenRules>" & strBrokenRules_XML & "</BrokenRules>"

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME
   Resume Cleanup
End Function

Public Function RulesBroken(ByVal BrokenRules_XML As String) As Boolean
'------------------------------------------------------------------------
' Purpose:  Returns True if BrokenRules_XML contains a BrokenRules XML structure
'
' Inputs:   BrokenRules_XML   -  BrokenRules XML structure
'
' Outputs:  None
'
' Return :  True is rules are broken, otherwise False
'
' Revision History
' 20Mar03 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "RulesBroken"
Dim ErrorState As udtErrorState
   
   On Error GoTo ErrorHandler
   
   RulesBroken = (InStr(BrokenRules_XML, "<BrokenRules") > 0)

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME, BrokenRules_XML
   Resume Cleanup
End Function

Public Function NoRulesBroken(ByVal BrokenRules_XML As String) As Boolean
'------------------------------------------------------------------------
' Purpose:  Returns True if BrokenRules_XML DOES NOT contain a BrokenRules XML structure
'
' Inputs:   BrokenRules_XML   -  BrokenRules XML structure
'
' Outputs:  None
'
' Return :  True is rules are broken, otherwise False
'
' Revision History
' 20Mar03 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "NoRulesBroken"
Dim ErrorState As udtErrorState
   
   On Error GoTo ErrorHandler
   
   NoRulesBroken = (InStr(BrokenRules_XML, "<BrokenRules") = 0)

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME, BrokenRules_XML
   Resume Cleanup
End Function

Public Function RemoveSubString( _
                                    ByVal strSource As String, _
                                    ByVal lngStart As Long, _
                                    ByVal lngEnd As Long _
                               ) As String
'------------------------------------------------------------------------
' Purpose:  Returns the string with the specified portion removed
'
' Inputs:   strSource   -  String that is to have a section removed from
'           lngStart    -  Position of first character to be removed
'           lngEnd      -  Position of last character to be removed
'
' Outputs:  None
'
' Return :  Resulting string
'
' Revision History
' 7Feb03 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "RemoveSubString"
Dim ErrorState As udtErrorState
   
   On Error GoTo ErrorHandler
   
   RemoveSubString = Left$(strSource, lngStart - 1) & Mid$(strSource, lngEnd + 1)

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME
   Resume Cleanup
End Function

Function TDate2DateTime(ByVal strTDate As String) As Date
'------------------------------------------------------------------------
' Purpose:  Takes a SQL "TDate" and convert
'           it to a VB Date variable.
'
' Inputs:   A string value containing a date that has been generated
'           by SQL "FOR XML AUTO".
'
' Outputs:  None
'
' Return :  Date
'
' Revision History
' 6Jun03 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "TDate2DateTime"
Dim ErrorState As udtErrorState
   
   On Error GoTo ErrorHandler
   
   TDate2DateTime = DateSerial(CLng(Left(strTDate, 4)), CLng(Mid(strTDate, 6, 2)), CLng(Mid(strTDate, 9, 2))) + TimeSerial(CLng(Mid(strTDate, 12, 2)), CLng(Mid(strTDate, 15, 2)), CLng(Mid(strTDate, 18, 2)))

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME, strTDate
   Resume Cleanup
End Function



Public Function Date2ddmmccyy(VBDate)

'29Nov06 AE  Added, copied from Generic.vb
   
   If Not IsNull(VBDate) Then
      If Not IsEmpty(VBDate) Then
         Date2ddmmccyy = PadL(Day(VBDate), 2, "0") _
                        & "/" _
                        & PadL(Month(VBDate), 2, "0") _
                        & "/" _
                        & PadL(Year(VBDate), 4, "0")
      End If
   End If
End Function


Function PadL(Source, Length, Char)
   PadL = Right(String(Length, Char) & Source, Length)
End Function
Function TDate2Date(ByVal strTDate As String) As Date
'------------------------------------------------------------------------
' Purpose:  Takes a SQL "TDate" and converts it to a VB Date variable,
'           stripping away any time element.
'
' Inputs:   A string value containing a date that has been generated
'           by SQL "FOR XML AUTO".
'
' Outputs:  None
'
' Return :  Date
'
' Revision History
' 6Jun03 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "TDate2Date"
Dim ErrorState As udtErrorState
   
   On Error GoTo ErrorHandler
   
   TDate2Date = DateSerial(CLng(Left(strTDate, 4)), CLng(Mid(strTDate, 6, 2)), CLng(Mid(strTDate, 9, 2)))

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME, strTDate
   Resume Cleanup
End Function

Function TDate2Time(ByVal strTDate As String) As Date
'------------------------------------------------------------------------
' Purpose:  Takes a SQL "TDate" and converts it to a VB Date variable,
'           stripping away any date element.
'
' Inputs:   A string value containing a date that has been generated
'           by SQL "FOR XML AUTO".
'
' Outputs:  None
'
' Return :  Date
'
' Revision History
' 6Jun03 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "TDate2Time"
Dim ErrorState As udtErrorState
   
   On Error GoTo ErrorHandler
   
   TDate2Time = TimeSerial(CLng(Mid(strTDate, 12, 2)), CLng(Mid(strTDate, 15, 2)), CLng(Mid(strTDate, 18, 2)))

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME, strTDate
   Resume Cleanup
End Function

Function Date2TDate(ByVal Value As Date) As String
'------------------------------------------------------------------------
' Purpose:  Takes a VB Date and returns its TDate string equivelant
'
' Inputs:   A Vb Date
'
' Outputs:  None
'
' Return :  TDate string
'
' Revision History
' 10Mar04 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "TDate2Time"
Dim ErrorState As udtErrorState
   
   On Error GoTo ErrorHandler
   
   Date2TDate = Format$(Year(Value), "0000") _
               & "-" & Format$(Month(Value), "00") _
               & "-" & Format$(Day(Value), "00") _
               & "T" _
               & Format$(Hour(Value), "00") _
               & ":" _
               & Format$(Minute(Value), "00") _
               & ":" _
               & Format$(Second(Value), "00")

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME, Value
   Resume Cleanup
End Function

Public Sub List2TreeXML( _
                           ByRef xmldocList As MSXML2.DOMDocument, _
                           ByVal strNodeName As String, _
                           ByVal strPrimaryAttributeName As String, _
                           ByVal strParentAttributeName As String _
                       )
'------------------------------------------------------------------------
' Purpose:  Take a list of xml Nodes with attributes, and converts it to a
'           hierachical tree structure.
'           Expects each node to have a PrimaryKey attribute, along with a Parent
'           attribute whose value contains the PrimaryKey of the node that is it's
'           Parent.
'
' Inputs:   xmldocList
'                    <MyNodes>
'                       <MyNode MyPrimarKeyID="123" MyParentID="0" AnAttrib="abc" AnotherAttrib="def" />
'                       <MyNode MyPrimarKeyID="456" MyParentID="123" AnAttrib="abc" AnotherAttrib="def" />
'                       .
'                       .
'                    </MyNodes>
'
'           xmldocList                 XML DOM to be Treeified
'           strNodeName                Only node with this name will be treeified
'           strPrimaryAttributeName    Name of attribute that contains the PrimaryKey of the node
'           strParentAttributeName     Name of attribute that contains the foreign key that is the primary key of this node's parent node
'
' Outputs:  the xmldocList directly
'
' Return :
'
' Revision History
' 20Jun03 PH  Created
' 11Jan05 AE  Rewrote algorithm.  Previous version was sometimes prone to infinite looping, since it was changing the
'             make up of the node list during the loop.  Now recalculates the node list every time a change is made to it.
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "List2TreeXML"
Dim ErrorState As udtErrorState
Dim xmlnodelist As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMElement
Dim xmlnodeParent As MSXML2.IXMLDOMElement
Dim xmlCurrentParent As MSXML2.IXMLDOMElement
Dim blnChanged As Boolean

   On Error GoTo ErrorHandler
   
   Do
      blnChanged = False
      Set xmlnodelist = xmldocList.selectNodes("//" & strNodeName)
      For Each xmlnode In xmlnodelist
         'Find the node which is supposed to be the parent of this node
         Set xmlnodeParent = xmldocList.selectSingleNode("//" & strNodeName & "[@" & strPrimaryAttributeName & "=""" & xmlnode.getAttribute(strParentAttributeName) & """]")
         Set xmlCurrentParent = xmlnode.parentNode
         
         If Not (xmlnodeParent Is Nothing) Then
         'We have a parent somewhere in the xml...
            If (xmlnode.getAttribute(strParentAttributeName) <> xmlCurrentParent.getAttribute(strPrimaryAttributeName)) Or IsNull(xmlCurrentParent.getAttribute(strPrimaryAttributeName)) Then
            '...and the node isn't under that parent, so move it
               xmlnodeParent.appendChild xmlnode
               blnChanged = True
            End If
         End If
         
         'If we've changed anything, go back to the begining and recalculate the node list.
         If blnChanged Then Exit For
         
      Next
   
   Loop Until Not blnChanged


'   Set xmlNodeList = xmldocList.selectNodes("//" & strNodeName)
'   For Each xmlnode In xmlNodeList
'      Set xmlnodeParent = xmldocList.selectSingleNode("//" & strNodeName & "[@" & strPrimaryAttributeName & "=""" & xmlnode.getAttribute(strParentAttributeName) & """]")
'      If Not (xmlnodeParent Is Nothing) Then
'         If Not (xmlnode Is xmlnodeParent) Then
'            xmlnodeParent.appendChild xmlnode.parentNode.removeChild(xmlnode)
'         End If
'      End If
'   Next xmlnode
'   Set xmlNodeList = Nothing


Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Sub

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME
   Resume Cleanup
End Sub

Public Sub SortXML( _
                      ByRef xmlDoc As MSXML2.DOMDocument, _
                      strXPath As String, _
                      strSortByAttributeNameList As String _
                  )
'------------------------------------------------------------------------
' Purpose:  Take an XML DOM and perform a BubbleSort on the nodes that
'           are siblings of the first node found by the supplied xpath
'           expression. Order by the comma-separated list of named attributes.
'
'           WARNING - This is a temporary Bubble Sort, and should be replaced with
'                     a more effective sorting algorithm before release.
'
' Inputs:   xmldoc
'                    <MyNodes>
'                       <MyNode MyPrimarKeyID="123" MyParentID="0" AnAttrib="abc" AnotherAttrib="def" />
'                       <MyNode MyPrimarKeyID="456" MyParentID="123" AnAttrib="abc" AnotherAttrib="def" />
'                       .
'                       .
'                    </MyNodes>
'
'           strNodeName                Only node with this name will be treeified
'           strPrimaryAttributeName    Name of attribute that contains the PrimaryKey of the node
'           strSortByAttributeNameList Comma separated list of Attribute names to sort by
'
' Outputs:  the xmldocList directly
'
' Return :
'
' Revision History
' 20Jun03 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "SortXML"
Dim ErrorState As udtErrorState
Dim xmlnodeCurrent As MSXML2.IXMLDOMElement
Dim xmlnodeNext As MSXML2.IXMLDOMElement
Dim blnSwap As Boolean
Dim lngAttribLBound As Long
Dim lngAttribUBound As Long
Dim lngAttribIndex As Long
Dim lngNodeCount As Long
Dim lngNodeOuterIndex As Long
Dim lngNodeInnerIndex As Long
Dim arrSortByAttributeNameList() As String

   On Error GoTo ErrorHandler
   
   arrSortByAttributeNameList = Split(strSortByAttributeNameList, ",")
   
   lngAttribLBound = LBound(arrSortByAttributeNameList)
   lngAttribUBound = UBound(arrSortByAttributeNameList)
   
   ' Count the number of nodes to be sorted
   Set xmlnodeCurrent = xmlDoc.selectSingleNode(strXPath)
   If Not (xmlnodeCurrent Is Nothing) Then
   
      lngNodeCount = 1
      Do While Not (xmlnodeCurrent.nextSibling Is Nothing)
         lngNodeCount = lngNodeCount + 1
         Set xmlnodeCurrent = xmlnodeCurrent.nextSibling
      Loop
      
      If lngNodeCount >= 2 Then
      
         lngNodeCount = lngNodeCount - 2
      
         For lngNodeOuterIndex = lngNodeCount To 1 Step -1
         
            ' Find the new first node
            Set xmlnodeCurrent = xmlDoc.selectSingleNode(strXPath)
            
            For lngNodeInnerIndex = 0 To lngNodeOuterIndex
               
               Set xmlnodeNext = xmlnodeCurrent.nextSibling
               
               blnSwap = False
               For lngAttribIndex = lngAttribLBound To lngAttribUBound
                  If xmlnodeCurrent.getAttribute(arrSortByAttributeNameList(lngAttribIndex)) < xmlnodeNext.getAttribute(arrSortByAttributeNameList(lngAttribIndex)) Then
                     blnSwap = False
                     Exit For
                  ElseIf xmlnodeCurrent.getAttribute(arrSortByAttributeNameList(lngAttribIndex)) > xmlnodeNext.getAttribute(arrSortByAttributeNameList(lngAttribIndex)) Then
                     blnSwap = True
                     Exit For
                  End If
               Next lngAttribIndex
               
               If blnSwap Then
                  xmlnodeCurrent.parentNode.insertBefore xmlnodeNext, xmlnodeCurrent
               Else
                  Set xmlnodeCurrent = xmlnodeCurrent.nextSibling
               End If
            
            Next lngNodeInnerIndex
            
         Next lngNodeOuterIndex
   
      End If
   
   End If
      
Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Sub

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME
   Resume Cleanup
End Sub

Public Function XMLAttributeIsNull(AttributeValue As Variant) As Boolean

'----------------------------------------------------------------------------------
'
' Purpose:
'   XML which is passed up from client script may have missing attributes,
'   attributes which are empty, or attributes set to have the javascript value
'   null which is coerced to the string "null".
'   This simple wrapper replaces IsNull for checking attributes, and returns
'   true if:
'     Condition:                                Example                                               Example XML
'     ----------------------------------------------------------------------------------------------------------------------
'     IsNull(AttributeValue) is true            XMLAttributeIsNull(xmlNode.getAttribute("B")          <Node A="1" />
'     AttributeValue is an empty string         XMLAttributeIsNull(xmlNode.getAttribute("A")          <Node A="" B="2" />
'     AttributeValue is the string "null"       XMLAttributeIsNull(xmlNode.getAttribute("A")          <Node A="null" B="2" />
'
' Inputs:
'   AttributeValue: Variant passed from getAttribute() or getNamedItem().value
'
' Outputs:
'   True if the item is null as specified above
'
' Modification History:
'  04Jul03 AE  Written
'
'----------------------------------------------------------------------------------

'General
Dim blnIsNull As Boolean

   blnIsNull = False
   
   If IsNull(AttributeValue) Then
      blnIsNull = True
   Else
   
      If AttributeValue = "" Then
         blnIsNull = True
      Else
         If LCase(CStr(AttributeValue)) = "null" Then blnIsNull = True
      End If
   End If

   XMLAttributeIsNull = blnIsNull
 

End Function

Public Sub XMLExtendedCharEscape(ByRef strXML_INOUT)

'----------------------------------------------------------------------------------
'
' Purpose:
'  escapes extended characters which the DOM can't deal with (such as "µ").
'
' Modification History:
'  19Sep03  AE  Written
'
'----------------------------------------------------------------------------------

   strXML_INOUT = Replace(strXML_INOUT, "µ", "/" & Asc("µ"))
   strXML_INOUT = Replace(strXML_INOUT, "²", "/" & Asc("²"))
      '
      '

End Sub

Public Function MaskMatch(strSource As String, strMask As String) As Boolean
'------------------------------------------------------------------------------------
' Purpose   :  Returns true if string matches mask
'
' Inputs    :  strSource
'              strMask
'
' Outputs   :  None
'
' Return    :  true if source string matches mask
'
' Revision History
'
' 10Mar04 PH - Updated
'------------------------------------------------------------------------------------
Const SUB_NAME = "CharIsNumeric"
Dim ErrorState As udtErrorState
Dim lngPos As Long
               
   On Error GoTo ErrorHandler
   
   MaskMatch = True

   For lngPos = 1 To Len(strMask)
      Select Case Mid$(strMask, lngPos, 1)
         Case "9"
            If (Mid$(strSource, lngPos, 1) < "0" Or Mid$(strSource, lngPos, 1) > "9") Then
               MaskMatch = False
               Exit For
            End If
         Case "A"
            If (UCase(Mid$(strSource, lngPos, 1)) < "A" Or UCase(Mid$(strSource, lngPos, 1)) > "Z") Then
               MaskMatch = False
               Exit For
            End If
      End Select
   Next lngPos

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME
   Resume Cleanup
End Function

Public Function FormatNumeric(ByRef NumberString_IN As String) As String

'Format's a number (passed as a string) into a standard
'form; that is:
'
'  Whole numbers are formatted with no decimal point.
'  decimals are formatted to 2 dec places.
'
'  Deals only with strings because this is for display only.  Rounding/Formatting
'  should always be done as the last step before display.
'
'Modification History
'  04Nov03 AE  Written.  I expect this to be expanded in future.
'  26Nov03 TH  Altered to format the number for a decimal, not just the blank string

Dim strReturn As String

   If Val(NumberString_IN) = CInt(NumberString_IN) Then
   'A whole number, leave as it is.
      strReturn = NumberString_IN
   
   Else
   'A decimal
      'strReturn = Format$(strReturn, NUMERIC_MASK)                    '26Nov03 TH Altered (#71549)
      strReturn = CStr(Val(Format$(NumberString_IN, NUMERIC_MASK)))    '  "      '28Nov03 TH Added quickly for demo to remove trailing zeroes
   End If
   
   FormatNumeric = strReturn
End Function
Public Function XMLElementsDiffer( _
                                      ByRef xmlnode1 As MSXML2.IXMLDOMElement _
                                    , ByRef xmlnode2 As MSXML2.IXMLDOMElement _
                                 )
'------------------------------------------------------------------------
' Purpose: Iterates through all the nodes in an XML element and returns true if they differ
'
' Inputs:
'
' Outputs:  None
'
' Return :  Date
'
' Revision History
' 20Nov03 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "XMLElementsDiffer"
Dim ErrorState As udtErrorState
Dim xmlattrib As MSXML2.IXMLDOMAttribute
Dim xmlnode As MSXML2.IXMLDOMAttribute

   XMLElementsDiffer = False
   For Each xmlattrib In xmlnode1.Attributes
      If IsNull(xmlnode2.getAttribute(xmlattrib.Name)) Then
         XMLElementsDiffer = True
         Exit For
      Else
         If xmlnode2.getAttribute(xmlattrib.Name) <> xmlattrib.Value Then
            XMLElementsDiffer = True
            Exit For
         End If
      End If
   Next xmlattrib

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME
   Resume Cleanup
End Function

Public Function UboundX(ByRef AnyArray As Variant) As Integer

'As ubound, but without the horrible "raise an error if the array is empty" behaviour.
'An empty array returns Ubound = -1
'
'  07Jun04 AE  Written
   
   UboundX = -1
   On Error Resume Next
   UboundX = UBound(AnyArray)
   On Error GoTo 0

End Function

Function Encode(ByVal strSource As String) As String
'-----------------------------------------------------------------------------
'                   encode variable length binary string
'
'                       lngIndex n      lngIndex n+1
'  character    B  66  01000010     01000010
'  AND          &HAA   10101010     01010101   &H55
'  masked char  (1)    00000010     01000000
'
'  random char         11011101     11011101
'  AND          &H55   01010101     10101010   &HAA
'  masked char  (2)    01011101     10001000
'  masked char  (1)    00000010     01000000
'  OR                  01011111     11001000
'  answer                95  _       200  È
'
'30Jun94 CKJ Mod to increase variability - right shift the first lngIndex
'30Oct94 CKJ Written. Returns an encoded hex string
'15Sep04 PH Ported to v9.2
'-----------------------------------------------------------------------------

Dim lngSourceLength As Long
Dim lngIndex As Long
Dim intCharacter As Integer

   lngSourceLength = Len(strSource)
   If lngSourceLength > 0 Then
      Randomize Timer
      For lngIndex = 1 To lngSourceLength
         intCharacter = Asc(Mid$(strSource, lngIndex))
         Encode = Encode & Right$("0" & Hex$(((intCharacter \ 2) And &H55) Or ((Rnd * 256) And &HAA)), 2) _
                         & Right$("0" & Hex$((intCharacter And &H55) Or ((Rnd * 256) And &HAA)), 2)
      Next lngIndex
   End If

End Function

Function Decode(ByVal strSource As String) As String
'-----------------------------------------------------------------------------
'                   decode variable length binary string
'
'  lngIndex n              0*0*0*0*     AND 10101010  &HAA
'  lngIndex n+1            *1*0*0*1     AND 01010101  &H55
'  answer       A  65  01000001     OR
'
'30Oct94 CKJ Written. Returns a decoded hex string
'15Sep04 PH Ported to v9.2
'-----------------------------------------------------------------------------
Dim lngSourceLength As Long
Dim lngIndex As Long

   lngSourceLength = Len(strSource)
   If lngSourceLength > 0 Then
      For lngIndex = 1 To lngSourceLength Step 4
         Decode = Decode & Chr$((((Val("&h" & Mid$(strSource, lngIndex, 2)) * 2) Mod 256) And &HAA) Or (Val("&h" & Mid$(strSource, lngIndex + 2, 2)) And &H55))
      Next
   End If

End Function

Sub XMLCopyAttributes( _
                         ByRef xmlelementSource As MSXML2.IXMLDOMElement _
                       , ByRef xmlelementTarget As MSXML2.IXMLDOMElement _
                     )
'-----------------------------------------------------------------------------
'
' Copies all attributes from source node to target node
'
'07Dec04 PH Created
'-----------------------------------------------------------------------------
Const SUB_NAME As String = "XMLCopyAttributes"
Dim ErrorState As udtErrorState
   On Error GoTo ErrorHandler

Dim xmlattrib As MSXML2.IXMLDOMAttribute

   For Each xmlattrib In xmlelementSource.Attributes
      xmlelementTarget.setAttribute xmlattrib.nodeName, xmlattrib.nodeValue
   Next xmlattrib

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Sub

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME
   Resume Cleanup
End Sub

Function CLngX(Value As Variant) As Long
'-----------------------------------------------------------------------------
' Convert a value to a long. Return zero if any error occurs.
'19Sep05 PH Created
'-----------------------------------------------------------------------------
   On Error GoTo ReturnZero
   CLngX = CLng(Value)
   Exit Function
ReturnZero:
   CLngX = 0
End Function

Function XMLBoolean(Value As Boolean) As Integer
'-----------------------------------------------------------------------------
' To be used when representing boolean values in XML attributes. True is returned as 1, False as 0
'19Sep05 PH Created
'-----------------------------------------------------------------------------
Const SUB_NAME As String = "XMLBoolean"
Dim ErrorState As udtErrorState
   On Error GoTo ErrorHandler
   
   If Value Then
      XMLBoolean = 1
   Else
      XMLBoolean = 0
   End If
   
Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, MODULE_NAME, SUB_NAME
   Resume Cleanup
End Function

