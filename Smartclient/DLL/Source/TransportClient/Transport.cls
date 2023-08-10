VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Transport"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'------------------------------------------------------------------------------------
'Project Name  :
'
' Item:        :  clsTransportClient
'
' Purpose      :  Provides the data transport layer between client components
'                 and database.
'              :  Provides methods to execute stored procedures
'              :  Returns native ado recordsets
'

'Revision History
'15Sep04 PW  Based on 9.2 COM+ transport layer
'18Oct04 PW  Added the GetRowLock function
'19Oct04 PW  Added the ExecuteUpdateCustomSP function
'06Jan04 PW  Added with events to connection declaration to enable the setting of querylock timeout when connection opens
'06Jan04 PW  Modified ValidateSessionID to call pharmacy specific stored proc to avoid locking within the transaction
'15Apr05 PW  Changed ExecuteSelectSP so it checks and returns the last recordset (rs.nextRecordset)
'04nov08 CKJ WriteAuditLog: Call to pAuditLogInsert replaced with pAuditLogInsertViaTransport
'        *** THIS WILL NEED REVIEWING if Pharmacy ever gets used with InterfaceRegister ***
'            See proc for detail                (F0037051, F0037016)
'17Nov15 DJH TFS 135193 - Ensure Custom Updates are written to the Audit Log.
'28May17 TH  XMLParamstoADO: Horrible frig to stop above frig damaging base64 encoded text (pictures) (TFS 174888)
'16Apr18 DR  Bug 209934 - Dispensing control client error in event log missing sp
'------------------------------------------------------------------------------------
Option Explicit
DefInt A-Z

'impliments ConnectComplete(pError As Error, adStatus As EventStatusEnum, pConnection As Connection)

Private Const CLASS_NAME As String = "Transport"
Private Const LOCKRETRYEXCEEDED = 2000
Private Const LOCKRETRYCOUNT = 10
' Data types supported by this transport layer
' If you have to add extra types, then keep the existing numbers as they are.
Public Enum trnDataTypeEnum
   trnDataTypeVarChar = 0
   trnDataTypeChar = 1
   trnDataTypeint = 2
   trnDataTypeText = 4
   trnDataTypeFloat = 7
   trnDataTypeBit = 9
   trnDataTypeDateTime = 10
   trnDataTypeUniqueIdentifier = 11
   trnDataTypeBase64Binary = 12
   trnDataTypeDecimal = 13
End Enum

Public Enum insInstallationType
   InstallationTypeUnknown = 0
   InstallationTypeLive = 1
   InstallationTypeTraining = 2
   InstallationTypeTesting = 3
End Enum

Private Enum AuditLogType
   AuditLogInsert = 1
   AuditLogUpdate = 2
   AuditLogDelete = 3
End Enum

'local variable(s) to hold property value(s)
Private WithEvents mADOConnection As ADODB.Connection      'local copy
Attribute mADOConnection.VB_VarHelpID = -1
'
Public Property Set Connection(ByVal objConnection As ADODB.Connection)
Attribute Connection.VB_Description = "Standard ADO Connection object"
'used when assigning an Object to the property, on the left side of a Set statement.
'Syntax: Set x.Connection = Form1
Dim adoError As ADODB.Error
    
   Set mADOConnection = objConnection
   mADOConnection.IsolationLevel = adXactReadCommitted
  'mADOConnection_ConnectComplete adoerror, adStatusOK, mADOConnection '24Oct05 TH Added '04Nov05 TH Removed for now
   
End Property

Public Property Get Connection() As ADODB.Connection
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.Connection

   Set Connection = mADOConnection
    
End Property
 
Public Function CreateInputParameterXML( _
                                           ByVal Name As String, _
                                           ByVal DataType As trnDataTypeEnum, _
                                           ByVal Length As Long, _
                                           ByVal Value As Variant _
                                       ) _
                                       As String
Attribute CreateInputParameterXML.VB_Description = "Builds an XML input parameter element, for use in the Execute methods"
'------------------------------------------------------------------------------------
' Purpose   :  Builds an XML input parameter element, for use in the Execute methods
'
' Inputs    :  Name     -  Name of the parameter
'              DataType -  The transport layer's datatype abstractions
'              Length   -  Length of the parameter (most useful for varchars)
'              Value    -  Value of the parameter
'
' Outputs   :  None
'
' Return    :  XML Input Parameter Element
'
' Revision History
'
' 03May02 RA - Created
' 18Jan03 PH - Updated
' 08Apr03 PH   Changed to use the XML DOM rather than String concatenation
' 11Jun03 AE   Added Data-type specific handling for DATE; this can be expanded to other data types if required
' 30Jul03 AE   Previous mod improved; DATE data type does NO validation and strips off the time part.
'              Unfortunately has to manually convert to XML's yyyy-mm-ddThh:mm format otherwise the DOM won't parse it.
' 09Mar04 PH   Changed to "presume" dd/mm/yyyy for ambiguous date strings, rather than using cdate()
' 10Jul04 PH   Now raises an error if textual date format isnt TDate
' 11Aug04 PH   Now accepts 5 character 99:99 format strings of where DateType is trnDataTypeDateTime as a time.
'------------------------------------------------------------------------------------

Const SUB_NAME As String = "CreateInputParameterXML"
Dim ErrorState As udtErrorState

Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMElement
Dim enmDataType As ADODB.DataTypeEnum
   
   On Error GoTo ErrorHandler
   
   Set xmlDoc = New MSXML2.DOMDocument
   
   Set xmlnode = xmlDoc.createElement("Parameter")
   
   enmDataType = AdoDataType(DataType)
   
   xmlDoc.appendChild xmlnode
   xmlnode.setAttribute "Name", Name
   xmlnode.setAttribute "DataType", enmDataType
   xmlnode.setAttribute "Direction", ADODB.adParamInput
   xmlnode.setAttribute "Length", Length
   
   ' "Null"s are represented by the absense of the "Value" attribute
   If Not IsNull(Value) Then
      
      Select Case enmDataType
         Case adDBDate
            ' A date parameter could come through in many different datatypes/formats
            ' Start by determining the variant's subtype
            Select Case VarType(Value)
               Case VbVarType.VBDate
                  ' If the variant subtype is a date, then convert it to a TDate string
                  xmlnode.setAttribute "Value", Date2TDate(Value)
               Case VbVarType.vbString
                  ' Examine the string to work out what format the date is in.
                  If Mid$(Value, 11, 1) = "T" Then
                     ' Date format is "TDate", so use it "as is"
                     xmlnode.setAttribute "Value", Value
                  ElseIf Len(Trim$(Value)) = 5 And Mid$(Trim$(Value), 3, 1) = ":" Then
                     ' Date value is a 5 character 24-hour time string
                     xmlnode.setAttribute "Value", Trim$(Value)
                  Else
                     RaiseError erUnknownDateFormat, Value
                  End If
               Case Else
                  RaiseError erUnknownDateFormat, Value
               End Select
            
''         Case adChar, adVarChar     'maybe also adLongVarChar adLongVarWChar ?
''            EscapeXML Value
''            xmlnode.setAttribute "Value", Value
            
         Case Else
            xmlnode.setAttribute "Value", Value
     
         End Select
   
   End If
   
   CreateInputParameterXML = xmlDoc.xml

Cleanup:
   Set xmlnode = Nothing
   Set xmlDoc = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, Name & ", " & DataType & ", " & Length & ", " & Value
 
   Resume Cleanup
End Function


Public Function CreateOutputParameterXML( _
                                           ByVal Name As String, _
                                           ByVal DataType As trnDataTypeEnum, _
                                           ByVal Length As Long _
                                       ) _
                                       As String
Attribute CreateOutputParameterXML.VB_Description = "Builds an XML output parameter element, for use in the Execute methods"
'------------------------------------------------------------------------------------
' Purpose   :  Builds an XML output parameter element, for use in the Execute methods
'
' Inputs    :  Name       -  Name of the parameter
'              DataType   -  SQL Datatype
'              Value      -  Value to pass
'
' Outputs   :  None
'
' Return    :  XML Output Parameter Element
'
' Revision History
'
' 03May02 RA - Created
' 18Jan03 PH - Updated
'------------------------------------------------------------------------------------
Const SUB_NAME = "CreateOutputParameterXML"
Dim ErrorState As udtErrorState

Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMElement

   On Error GoTo ErrorHandler
   
   Set xmlDoc = New MSXML2.DOMDocument
   
   Set xmlnode = xmlDoc.createElement("Parameter")
   
   xmlDoc.appendChild xmlnode
   xmlnode.setAttribute "Name", Name
   xmlnode.setAttribute "DataType", AdoDataType(DataType)
   xmlnode.setAttribute "Direction", ADODB.adParamOutput
   xmlnode.setAttribute "Length", Length
 
   CreateOutputParameterXML = xmlDoc.xml

Cleanup:
   Set xmlnode = Nothing
   Set xmlDoc = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, Name & ", " & DataType & ", " & Length
   
   Resume Cleanup
End Function

Public Function ExecuteSelectSP( _
                                   ByVal SessionID As Long, _
                                   ByVal ProcedureName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As ADODB.Recordset
'------------------------------------------------------------------------------------
' Purpose   :  Executes a stored procedure, and returns a recordset
'
' Inputs    :  SessionID      -  User's session id, used for security and audit logging
'              ProcedureName  -  name of SP to execute
'              Parameters_XML -  the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Recordset
'
' Revision History
'
' 15Sep04 PW - Created
' 15Apr05 PW - Added loop with rsNext to store adodb.recordset.nextrecordset if one exists
'------------------------------------------------------------------------------------

Const SUB_NAME As String = "ExecuteSelectSP"
Dim ErrorState As udtErrorState
   
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnodelist As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMElement
Dim adoCmd As ADODB.Command
Dim rs      As ADODB.Recordset

Dim rsnext  As ADODB.Recordset

   On Error GoTo ErrorHandler
   
   ' Check that we have a connection string in our constructor string
   ' SECURITY_SESSION_ID ispecial SessionID used by the security components prior to logging in and having a "proper" session id.
   ' The SECURITY_SESSION_ID bypasses the normal SessionID checks, and is therefore greatly restricted in the SPs it may call.
   If SessionID <> SECURITY_SESSION_ID Then
      ValidateSessionID SessionID
   Else
      ' The security system us using the special SECURITY_SESSION_ID to access the transport layer,
      ' because it doesnt have a session id yet, because the user hasnt logged in yet.
      ' The only SPs that can be called prior to having a proper session id are listed in
      ' the case statements below.
      Select Case ProcedureName
         Case "pUserLogin"
         Case "pSystemVersionXML"
         Case Else
            ValidateSessionID SessionID
      End Select
   End If
   
   ' Get the ADO connection and commabd objects ready for use
   Set adoCmd = CreateObject("ADODB.Command")

   ' Get connection string from COM+ constructor string, open and set the connection
   Set adoCmd.ActiveConnection = mADOConnection
   
   ' Set the default ADO properties
   adoCmd.CommandType = adCmdStoredProc
   adoCmd.CommandText = ProcedureName
   
   'SessionID is the first parameter to all stored procedures
   adoCmd.Parameters.Append adoCmd.CreateParameter("SessionID", adInteger, adParamInput, 4, SessionID)
   
   If Parameters_XML <> vbNullString Then

      ' Add Parameters tags around parameter list XML
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"
      
      ' Create an XML DOM
      Set xmlDoc = New MSXML2.DOMDocument
      
      'Load XML string into the DOM and if it works proceed
      If Not xmlDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      
      XMLParamsToADO xmlDoc, adoCmd, Nothing
   
   End If

   Set rs = New ADODB.Recordset
   rs.CursorLocation = adUseClient
   rs.LockType = adLockReadOnly
   rs.Open adoCmd
   
   Do
      Set rsnext = rs.NextRecordset
      If Not rsnext Is Nothing Then
         Set rs = rsnext
      End If
   Loop Until rsnext Is Nothing
   
   
   Set ExecuteSelectSP = rs

Cleanup:
   Set xmlDoc = Nothing
   Set xmlnodelist = Nothing
   Set xmlnode = Nothing
   Set adoCmd = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & ProcedureName & ", " & Parameters_XML, , mADOConnection
   Resume Cleanup
End Function

Public Function ExecuteSelectOutputSP( _
                                   ByVal SessionID As Long, _
                                   ByVal ProcedureName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As String
Attribute ExecuteSelectOutputSP.VB_Description = "Executes a stored procedure and the returns output parameters as XML"
'------------------------------------------------------------------------------------
' Purpose   :  Executes a stored procedure and the returns output parameters as XML
'
' Inputs    :  SessionID       -  User's session id, used for security and audit logging
'              Procedure       -  name of SP to execute
'              Parameters_XML  -  the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  XML Parameter List in the format
'                 <Parameters Param1="Value1" Param2="Value2" Param3="Value3" ></Parameters>
'
' Revision History
'
' 22Apr02 PH - Created
' 13Feb03 DB - Fixed a spacing problem between attributes in the XML string. Was coming out as
'              <Parameters Param1="Value1"Param2="Value3" ></Parameters>
'
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteSelectOutputSP"
Dim ErrorState As udtErrorState
   
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnodelist As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMElement
''Dim adoCn As adodb.Connection
Dim adoCmd As ADODB.Command

Dim strParam_XML As String
Dim lngParamCounter As Long
   
   On Error GoTo ErrorHandler
   
   '
   ' SECURITY_SESSION_ID is the special SessionID used by the security components prior to logging in and having a "proper" session id.
   ' The SECURITY_SESSION_ID bypasses the normal SessionID checks, and is therefore greatly restricted in the SPs it may call.
   If SessionID <> SECURITY_SESSION_ID Then
      ValidateSessionID SessionID
   Else
      ' The security system us using the special SECURITY_SESSION_ID to access the transport layer,
      ' because it doesnt have a session id yet, because the user hasnt logged in yet.
      ' The only SPs that can be called prior to having a proper session id are listed in
      ' the case statements below.
      Select Case ProcedureName
         Case "pSetting"
         Case "pUserChangePassword"
         Case Else
            ValidateSessionID SessionID
      End Select
   End If
   
   ' Get the ADO connection and command objects ready for use
''   Set adoCn = CreateObject("ADODB.Connection")
   Set adoCmd = CreateObject("ADODB.Command")
    
   ' Get connection string from COM+ constructor string, open and set the connection
''   adoCn.Open ConnectionString
''   Set adoCmd.ActiveConnection = adoCn
   Set adoCmd.ActiveConnection = mADOConnection

   ' Set the default ADO properties
   adoCmd.CommandType = adCmdStoredProc
   adoCmd.CommandText = ProcedureName
   
   'SessionID is the first parameter to all stored procedures
   adoCmd.Parameters.Append adoCmd.CreateParameter("SessionID", adInteger, adParamInput, 4, SessionID)
   
   If Parameters_XML <> vbNullString Then

      ' Add Parameters tags around parameter list XML
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"
      
      ' Create an XML DOM
      Set xmlDoc = New MSXML2.DOMDocument
      
      'Load XML string into the DOM and if it works proceed
      If Not xmlDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      
      XMLParamsToADO xmlDoc, adoCmd, Nothing

   End If

   ' Execute the command, and we will only be interested in the output parameters or return value.
   adoCmd.Execute , , adExecuteNoRecords
''   adoCn.Close
   
   ' Return the XML parameters
   strParam_XML = "<Parameters "
   For lngParamCounter = 0 To adoCmd.Parameters.Count - 1
      Select Case adoCmd.Parameters(lngParamCounter).Direction
         Case adParamOutput ', adParamReturnValue ' We will never use a stored procedure's return value
            
            strParam_XML = strParam_XML & adoCmd.Parameters(lngParamCounter).Name & "="""
         
            If IsNull(adoCmd.Parameters(lngParamCounter).Value) Then
            
               strParam_XML = strParam_XML & vbNullString
            
            Else
            
               Select Case adoCmd.Parameters(lngParamCounter).Type
                  
                  Case adBoolean
                     ' Force bit datatype to return 0 or 1, instead of true or false
                     If adoCmd.Parameters(lngParamCounter).Value = True Then
                        strParam_XML = strParam_XML & "1"
                     Else
                        strParam_XML = strParam_XML & "0"
                     End If
                  
                  Case adDate, adDBTimeStamp, adDBTime, adDBDate, adFileTime
                     ' Format to TSQL XML Date format i.e ccyy/mm/ddThh:mm:ss
                     strParam_XML = strParam_XML _
                        & Year(adoCmd.Parameters(lngParamCounter).Value) _
                        & "/" _
                        & Month(adoCmd.Parameters(lngParamCounter).Value) _
                        & "/" _
                        & Day(adoCmd.Parameters(lngParamCounter).Value) _
                        & "T" _
                        & Hour(adoCmd.Parameters(lngParamCounter).Value) _
                        & ":" _
                        & Minute(adoCmd.Parameters(lngParamCounter).Value) _
                        & ":" _
                        & Second(adoCmd.Parameters(lngParamCounter).Value)
                  
                  Case Else
                     strParam_XML = strParam_XML & CStr(adoCmd.Parameters(lngParamCounter).Value)
               
               End Select
               
            End If
               
            strParam_XML = strParam_XML & """ "

      End Select
   Next
   strParam_XML = strParam_XML & " />"
   
   ExecuteSelectOutputSP = strParam_XML

Cleanup:
   Set xmlDoc = Nothing
   Set xmlnodelist = Nothing
   Set xmlnode = Nothing
   Set adoCmd = Nothing
''   Set adoCn = Nothing
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & ProcedureName & ", " & Parameters_XML, , mADOConnection

   Resume Cleanup
End Function

Public Function ExecuteSelectReturnSP( _
                                   ByVal SessionID As Long, _
                                   ByVal ProcedureName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As Long
Attribute ExecuteSelectReturnSP.VB_Description = "Executes a stored procedure, returning it's ReturnValue as a Long"
'------------------------------------------------------------------------------------
' Purpose   :  Executes a stored procedure, returning it's ReturnValue as a Long
'
' Inputs    :  SessionID      - User's session id, used for security and audit logging
'              ProcedureName  - Name of procedure
'              Parameters_XML - the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
' 26Nov02 RA - Created
' 18Jan03 PH - Updated
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteSelectReturnSP"
Dim ErrorState As udtErrorState

Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnodelist As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMElement
''Dim adoCn As adodb.Connection
Dim adoCmd As ADODB.Command


   On Error GoTo ErrorHandler
   
    
   ' Check the SessionID exists in the Session table
   ValidateSessionID SessionID
   
   ' Get the ADO connection and commabd objects ready for use
''   Set adoCn = CreateObject("ADODB.Connection")
   Set adoCmd = CreateObject("ADODB.Command")
    
   ' Get connection string from COM+ constructor string, open and set the connection
''   adoCn.Open ConnectionString
''   Set adoCmd.ActiveConnection = adoCn
   Set adoCmd.ActiveConnection = mADOConnection
   
   ' Set the default ADO properties
   adoCmd.CommandType = adCmdStoredProc
   adoCmd.CommandText = ProcedureName
   
   'Add the return value parameter (this has to be done first and all SP's have one of these
   adoCmd.Parameters.Append adoCmd.CreateParameter("@Return", adInteger, adParamReturnValue)
     
   'SessionID is the first parameter to all stored procedures
   adoCmd.Parameters.Append adoCmd.CreateParameter("SessionID", adInteger, adParamInput, 4, SessionID)
   
   If Parameters_XML <> vbNullString Then

      ' Add Parameters tags around parameter list XML
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"
      
      ' Create an XML DOM
      Set xmlDoc = New MSXML2.DOMDocument
      
      'Load XML string into the DOM and if it works proceed
      If Not xmlDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      
      XMLParamsToADO xmlDoc, adoCmd, Nothing

   End If
       
   
   
   ' Execute the command, and we will only be interested in the output parameters or return value.
   adoCmd.Execute , , adExecuteNoRecords
''   adoCn.Close
   
   ' Return the XML parameters
   ExecuteSelectReturnSP = adoCmd.Parameters("@Return").Value


Cleanup:
   Set xmlDoc = Nothing
   Set xmlnodelist = Nothing
   Set xmlnode = Nothing
   Set adoCmd = Nothing
''   Set adoCn = Nothing
   
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
    
    CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & ProcedureName & ", " & Parameters_XML, , mADOConnection
    
    Resume Cleanup
End Function
Public Function ExecuteUpdateCustomSP( _
                                   ByVal SessionID As Long, _
                                   ByVal ProcedureName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As Long
'------------------------------------------------------------------------------------
' Purpose   :  Executes a custom stored procedure, returning it's ReturnValue as a Long
'
' Inputs    :  SessionID      - User's session id, used for security and audit logging
'              ProcedureName  - Name of procedure
'              Parameters_XML - the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
'
    ' 19Oct04 PW - Created
    ' 17Nov15 DJH - Add WriteToAuditLog

'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteUpdateCustomSP"

Dim ErrorState As udtErrorState

Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnodelist As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMElement

Dim adoCmd As ADODB.Command

   On Error GoTo ErrorHandler
   
    
   ' Check the SessionID exists in the Session table
   ValidateSessionID SessionID
   
   Set adoCmd = CreateObject("ADODB.Command")
    
   Set adoCmd.ActiveConnection = mADOConnection
   
   ' Set the default ADO properties
   adoCmd.CommandType = adCmdStoredProc
   adoCmd.CommandText = ProcedureName
   
   'Add the return value parameter (this has to be done first and all SP's have one of these
   adoCmd.Parameters.Append adoCmd.CreateParameter("@Return", adInteger, adParamReturnValue)
     
   'SessionID is the first parameter to all stored procedures
   adoCmd.Parameters.Append adoCmd.CreateParameter("SessionID", adInteger, adParamInput, 4, SessionID)
   
   If Parameters_XML <> vbNullString Then

      ' Add Parameters tags around parameter list XML
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"
      
      ' Create an XML DOM
      Set xmlDoc = New MSXML2.DOMDocument
      
      'Load XML string into the DOM and if it works proceed
      If Not xmlDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      
      XMLParamsToADO xmlDoc, adoCmd, Nothing

   End If
   
   ' Execute the command, and we will only be interested in the output parameters or return value.
    adoCmd.Execute , , adExecuteNoRecords

    ' Write Custom Update to the Audit Log. TFS 135193
    WriteAuditLog SessionID, AuditLogUpdate, ProcedureName, 0, Parameters_XML, 0

   
   ' Return the XML parameters
   ExecuteUpdateCustomSP = adoCmd.Parameters("@Return").Value


Cleanup:
   Set xmlDoc = Nothing
   Set xmlnodelist = Nothing
   Set xmlnode = Nothing
   Set adoCmd = Nothing

   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & ProcedureName & ", " & Parameters_XML, , mADOConnection
   Resume Cleanup
End Function


Private Sub FlattenXMLRow( _
                                 ByRef xmlnodeRoot As MSXML2.IXMLDOMElement _
                               , ByRef xmlnodeCurrent As MSXML2.IXMLDOMElement _
                           )
'------------------------------------------------------------------------------------
' Purpose   :  Move any attributes from all childnodes to the root node, then delete all child nodes. This is to handle text fields.
'
' Inputs    :  xmlnodeRoot - Root node to add attributes to
'              xmlnodelist - List of child nodes tp recursively traverse
'
' Revision History
'
' 22Apr02 PH - Created
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "FlattenXMLRow"
Dim ErrorState As udtErrorState
Dim xmlnode As MSXML2.IXMLDOMElement
Dim xmlAttribute As MSXML2.IXMLDOMAttribute

   On Error GoTo ErrorHandler
   
   ' Add the attribute to the root node
   For Each xmlnode In xmlnodeCurrent.childNodes
      For Each xmlAttribute In xmlnode.Attributes
         xmlnodeRoot.setAttributeNode xmlnode.removeAttributeNode(xmlAttribute)
      Next xmlAttribute
      FlattenXMLRow xmlnodeRoot, xmlnode
   Next xmlnode
   
   ' Delete all the child nodes, now that they have been processed
   Do While xmlnodeCurrent.childNodes.Length > 0
      xmlnodeCurrent.removeChild xmlnodeCurrent.firstChild
   Loop
   
Cleanup:
   Set xmlnode = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Sub

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub

Public Function ExecuteInsertSP( _
                                   ByVal SessionID As Long, _
                                   ByVal TableName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As Long
Attribute ExecuteInsertSP.VB_Description = "Executes the Insert stored procedure associated with TableName, to insert a record using values specified in Parameters_XML. ReturnValue is the new PrimaryKey."
'------------------------------------------------------------------------------------
' Purpose   :  Executes the Insert stored procedure associated with TableName,
'              to insert a record using values specified in Parameters_XML.
'              Parameter values are matched to columns by ordinal position, (not by name, as parameter names are ignored)
'              Parameters should not include the table's primary key.
'              The number of parameter's passed in should be one less than the number of columns in the table.
'              Return value is the Primary Key of the newly inserted record.
'
' Inputs    :  SessionID       - User's session id, used for security and audit logging
'              TableName       - Name of table
'              Parameters_XML  - The Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Returns the Last OUTPUT parameter of SP,
'              which will be the PrimaryKey of the newly inserted record.
'
' Revision History
'
' 22Apr02 RA - Created
' 18Jan03 PH - Updated
' 28Jul03 AE  Code to copy XML parameters into adoCmd now in XMLParamsToADO
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteInsertSP"
Dim ErrorState As udtErrorState
   
Dim xmlDoc As MSXML2.DOMDocument
''Dim adoCn As adodb.Connection
Dim adoCmd As ADODB.Command

Dim xmldocLog As MSXML2.DOMDocument
Dim xmlnodeLog As MSXML2.IXMLDOMElement

Dim lngPrimaryKey As Long

   On Error GoTo ErrorHandler
   
    
   ' Check the SessionID exists in the Session table
   ValidateSessionID SessionID
   
   ' Get the ADO connection and commabd objects ready for use
''   Set adoCn = CreateObject("ADODB.Connection")
   Set adoCmd = CreateObject("ADODB.Command")
    
   ' Get connection string from COM+ constructor string, open and set the connection
''   adoCn.Open ConnectionString
''   Set adoCmd.ActiveConnection = adoCn
   Set adoCmd.ActiveConnection = mADOConnection
   
   ' Set the default ADO properties
   adoCmd.CommandType = adCmdStoredProc
   adoCmd.CommandText = "[p" & TableName & "INSERT]"                                                                 '15Jan04 AE  Added [] to cope with names with spaces in
   
   'Add the return value parameter (this has to be done first and all SP's have one of these
   adoCmd.Parameters.Append adoCmd.CreateParameter("@Return", adInteger, adParamReturnValue)
     
   'SessionID is the first parameter to all stored procedures
   adoCmd.Parameters.Append adoCmd.CreateParameter("SessionID", adInteger, adParamInput, 4, SessionID)
   
   ' Create XML DOM to store the Log entry
   Set xmldocLog = New MSXML2.DOMDocument
   Set xmlnodeLog = xmldocLog.createElement(TableName)
   xmldocLog.appendChild xmlnodeLog
   
   If Parameters_XML <> vbNullString Then

      ' Add Parameters tags around parameter list XML
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"
      
      ' Create an XML DOM for the parameters
      Set xmlDoc = New MSXML2.DOMDocument
      'Load XML string into the DOM and if it works proceed
      If Not xmlDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      
      '28Jul03 AE  Code to copy XML parameters into adoCmd now in XMLParamsToADO
      '10Feb04 PH Extended to also build xml log document
      XMLParamsToADO xmlDoc, adoCmd, xmlnodeLog
      
   End If
   
   ' Last parameter is the primary key of the table.
   adoCmd.Parameters.Append adoCmd.CreateParameter("PrimaryKey", adInteger, adParamOutput, 4)
   
   ' Execute the command, and we will only be interested in the output parameters or return value.
   adoCmd.Execute , , adExecuteNoRecords
''   adoCn.Close
   
   ' Get primary key the the output parameter
   lngPrimaryKey = adoCmd.Parameters("PrimaryKey").Value
   
   ' Write insert to the audit log
   WriteAuditLog SessionID, AuditLogInsert, TableName, lngPrimaryKey, xmlnodeLog.xml

   ExecuteInsertSP = lngPrimaryKey

Cleanup:
   Set xmlnodeLog = Nothing
   Set xmldocLog = Nothing
   Set xmlDoc = Nothing
   Set adoCmd = Nothing
''   Set adoCn = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & TableName & ", " & Parameters_XML, , mADOConnection

   Resume Cleanup
End Function

Public Function ExecuteUpdateSP( _
                                   ByVal SessionID As Long, _
                                   ByVal TableName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As Long
'------------------------------------------------------------------------------------
' Purpose   :  Executes the Update stored procedure associated with TableName.
'              Parameters_XML will contain the new values in column order.
'              The first ordinal parameter must be the PrimaryKey of the row to update.
'              Return Value is a SQL Error number returned from the stored procedure.
'              A Return Value of zero indicates success.
'
' Inputs    :  SessionID      - User's session id, used for security and audit logging
'              TableName      - name of table
'              ParametersXML  - the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
' 22Apr02 RA - Created
' 18Jan03 PH - Updated
' 28Jul03 AE  Code to copy XML parameters into adoCmd now in XMLParamsToADO
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteUpdateSP"
Dim ErrorState As udtErrorState
   
'Objects
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnodelist As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMElement
''Dim adoCn As adodb.Connection
Dim adoCmd As ADODB.Command
Dim xmldocLog As MSXML2.DOMDocument
Dim xmlnodeLog As MSXML2.IXMLDOMElement
Dim lngPrimaryKey As Long
Dim lngRecordsAffected As Long

   On Error GoTo ErrorHandler
   
    
   ' Check the SessionID exists in the Session table
   ValidateSessionID SessionID
   
   ' Get the ADO connection and commabd objects ready for use
''   Set adoCn = CreateObject("ADODB.Connection")
   Set adoCmd = CreateObject("ADODB.Command")
    
   ' Get connection string from COM+ constructor string, open and set the connection
''   adoCn.Open ConnectionString
''   Set adoCmd.ActiveConnection = adoCn
   Set adoCmd.ActiveConnection = mADOConnection
   
   ' Set the default ADO properties
   adoCmd.CommandType = adCmdStoredProc
   adoCmd.CommandText = "[p" & TableName & "UPDATE]"                                            '15Jan04 AE  Added [] to cope with names with spaces in
   
   'Add the return value parameter (this has to be done first and all SP's have one of these
   adoCmd.Parameters.Append adoCmd.CreateParameter("@Return", adInteger, adParamReturnValue)
     
   ' SessionID is the first parameter to all stored procedures
   adoCmd.Parameters.Append adoCmd.CreateParameter("SessionID", adInteger, adParamInput, 4, SessionID)
   
   ' Create XML DOM to store the Log entry
   Set xmldocLog = New MSXML2.DOMDocument
   Set xmlnodeLog = xmldocLog.createElement(TableName)
   xmldocLog.appendChild xmlnodeLog
   
   If Parameters_XML <> vbNullString Then

      ' Add Parameters tags around parameter list XML
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"
      
      ' Create an XML DOM to process the parameters
      Set xmlDoc = New MSXML2.DOMDocument
      'Load XML string into the DOM and if it works proceed
      If Not xmlDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      
      '28Jul03 AE  Code to copy XML parameters into adoCmd now in XMLParamsToADO
      XMLParamsToADO xmlDoc, adoCmd, xmlnodeLog
      
   End If
         
   ' Read the primary key from the input parameters for later use in the audit log
   lngPrimaryKey = CLng(adoCmd.Parameters.Item(2).Value)
   
   ' Remove the primary key from the audit XML
   xmlnodeLog.removeAttributeNode xmlnodeLog.Attributes(0)
   
   ' Execute the command, and we will only be interested in the output parameters or return value.
   adoCmd.Execute lngRecordsAffected, , adExecuteNoRecords
''   adoCn.Close
   If lngRecordsAffected < 1 Then
      RaiseError erUpdateRowNotFound, "Table: " & TableName & " PK: " & lngPrimaryKey
   End If

   ' Write update to the audit log
   WriteAuditLog SessionID, AuditLogUpdate, TableName, lngPrimaryKey, xmlnodeLog.xml
   
   ' Return the XML parameters
   ExecuteUpdateSP = adoCmd.Parameters("@Return").Value

Cleanup:
   Set xmlnodeLog = Nothing
   Set xmldocLog = Nothing
   Set xmlDoc = Nothing
   Set xmlnodelist = Nothing
   Set xmlnode = Nothing
   Set adoCmd = Nothing
''   Set adoCn = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & TableName & ", " & Parameters_XML, , mADOConnection

   Resume Cleanup
End Function

Public Function ExecuteDeleteSP( _
                                   ByVal SessionID As Long, _
                                   ByVal TableName As String, _
                                   ByVal PrimaryKey As Long _
                               ) _
                               As Long
'------------------------------------------------------------------------------------
' Purpose   :  Executes the Delete stored procedure associated with TableName,
'              removing the record identified by PrimaryKey.
'              Return Value is a SQL Error number returned from the stored procedure.
'              A Return Value of zero indicates success.
'
' Inputs    :  SessionID  -  User's session id, used for security and audit logging
'              TableName  - name of table
'              PrimaryKey - Primary Key of record to delete
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
' 22Apr02 RA - Created
' 18Jan03 PH - Updated
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteDeleteSP"
Dim ErrorState As udtErrorState
   
''Dim adoCn As adodb.Connection
Dim adoCmd As ADODB.Command
   
Dim xmldocLog As MSXML2.DOMDocument
Dim xmlnodeLog As MSXML2.IXMLDOMElement

Dim lngRecordsAffected As Long

   On Error GoTo ErrorHandler
   
    
   ' Check the SessionID exists in the Session table
   ValidateSessionID SessionID
   
   ' Get the ADO connection and commabd objects ready for use
''   Set adoCn = CreateObject("ADODB.Connection")
   Set adoCmd = CreateObject("ADODB.Command")
    
   ' Get connection string from COM+ constructor string, open and set the connection
''   adoCn.Open ConnectionString
''   Set adoCmd.ActiveConnection = adoCn
   Set adoCmd.ActiveConnection = mADOConnection
   
   ' Set the default ADO properties
   adoCmd.CommandType = adCmdStoredProc
   adoCmd.CommandText = "[p" & TableName & "DELETE]"                                   '15Jan04 AE  Added [] to cope with names with spaces in
   
   'Add the return value parameter (this has to be done first and all SP's have one of these
   adoCmd.Parameters.Append adoCmd.CreateParameter("@Return", adInteger, adParamReturnValue)
     
   ' SessionID is the first parameter to all stored procedures
   adoCmd.Parameters.Append adoCmd.CreateParameter("SessionID", adInteger, adParamInput, 4, SessionID)
   
   ' 2nd parameter is the primary key of the table
   adoCmd.Parameters.Append adoCmd.CreateParameter("PrimaryKey", adInteger, adParamInput, 4, PrimaryKey)
   
   ' Execute the command, and we will only be interested in the output parameters or return value.
   adoCmd.Execute lngRecordsAffected, , adExecuteNoRecords
''   adoCn.Close
   
   ' Return the XML parameters
   ExecuteDeleteSP = adoCmd.Parameters("@Return").Value

   ' Log delete
   If lngRecordsAffected >= 1 Then
      WriteAuditLog SessionID, AuditLogDelete, TableName, PrimaryKey, ""
   Else
      WriteAuditLog SessionID, AuditLogDelete, TableName, PrimaryKey, "<error description=""Attempted to delete a row that didnt exist"" table=""" & TableName & """ pk=""" & PrimaryKey & """/>"
   End If

Cleanup:
   Set adoCmd = Nothing
''   Set adoCn = Nothing
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & TableName & ", " & PrimaryKey, , mADOConnection
   
   Resume Cleanup
End Function

Public Function ExecuteInsertLinkSP( _
                                        ByVal SessionID As Long, _
                                        ByVal TableName As String, _
                                        ByVal Parameters_XML As String _
                                    ) _
                                    As Long
Attribute ExecuteInsertLinkSP.VB_Description = "Executes the Insert Link stored procedure associated with the Link Table named TableName. Return Value is a SQL Error number returned from the stored procedure. A Return Value of zero indicates success."
'------------------------------------------------------------------------------------
' Purpose   :  Executes the Insert Link stored procedure associated with the Link Table named TableName.
'              Parameter values are matched to columns by ordinal position, (not by name, as parameter names are ignored)
'              Link tables only ever contain two columns: the primary keys of the two tables they join together,
'              therefore, there should only ever be two parameters in Parameters_XML.
'              Return Value is a SQL Error number returned from the stored procedure.
'              A Return Value of zero indicates success.
'
' Inputs    :  SessionID      -  User's session id, used for security and audit logging
'              TableName      - name of table
'              ParametersXML  - the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
' 25Nov02 PH - Created
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteInsertLinkSP"
Dim ErrorState As udtErrorState
   
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnodelist As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMElement
''Dim adoCn As adodb.Connection
Dim adoCmd As ADODB.Command
Dim xmldocLog As MSXML2.DOMDocument
Dim xmlnodeLog As MSXML2.IXMLDOMElement

   On Error GoTo ErrorHandler
   
   ' Check the SessionID exists in the Session table
   ValidateSessionID SessionID
   
   ' Get the ADO connection and commabd objects ready for use
''   Set adoCn = CreateObject("ADODB.Connection")
   Set adoCmd = CreateObject("ADODB.Command")
    
   ' Get connection string from COM+ constructor string, open and set the connection
''   adoCn.Open ConnectionString
''   Set adoCmd.ActiveConnection = adoCn
   Set adoCmd.ActiveConnection = mADOConnection
   
   ' Set the default ADO properties
   adoCmd.CommandType = adCmdStoredProc
   adoCmd.CommandText = "[p" & TableName & "INSERT]"                                         '15Jan04 AE  Added [] to cope with names with spaces in
   
   'Add the return value parameter (this has to be done first and all SP's have one of these
   adoCmd.Parameters.Append adoCmd.CreateParameter("@Return", adInteger, adParamReturnValue)
     
   'SessionID is the first parameter to all stored procedures
   adoCmd.Parameters.Append adoCmd.CreateParameter("SessionID", adInteger, adParamInput, 4, SessionID)
   
   ' Create XML DOM to store the Log entry
   Set xmldocLog = New MSXML2.DOMDocument
   Set xmlnodeLog = xmldocLog.createElement(TableName)
   xmldocLog.appendChild xmlnodeLog
   
   If Parameters_XML <> vbNullString Then

      ' Add Parameters tags around parameter list XML
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"
      
      ' Create an XML DOM
      Set xmlDoc = New MSXML2.DOMDocument
      'Load XML string into the DOM and if it works proceed
      If Not xmlDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If

      XMLParamsToADO xmlDoc, adoCmd, xmlnodeLog

   End If
   
   ' Execute the command, and we will only be interested in the output parameters or return value.
   adoCmd.Execute , , adExecuteNoRecords
''   adoCn.Close
   
   ' Write insert to the audit log
   WriteAuditLog SessionID, AuditLogInsert, TableName, 0, xmlnodeLog.xml

   ' Return the XML parameters
   ExecuteInsertLinkSP = adoCmd.Parameters("@Return").Value

Cleanup:
   Set xmlnodeLog = Nothing
   Set xmldocLog = Nothing
   Set xmlDoc = Nothing
   Set xmlnodelist = Nothing
   Set xmlnode = Nothing
   Set adoCmd = Nothing
''   Set adoCn = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & TableName & ", " & Parameters_XML, , mADOConnection

   Resume Cleanup
End Function

Public Function ExecuteDeleteLinkSP( _
                                        ByVal SessionID As Long, _
                                        ByVal TableName As String, _
                                        ByVal Parameters_XML As String _
                                    ) _
                                    As Long
Attribute ExecuteDeleteLinkSP.VB_Description = "Executes the Delete Link stored procedure associated with the Link Table named TableName. Return Value is a SQL Error number returned from the stored procedure. A Return Value of zero indicates success."
'------------------------------------------------------------------------------------
' Purpose   :  Executes the Delete Link stored procedure associated with the Link Table named TableName.
'              Parameter values are matched to columns by ordinal position, (not by name, as parameter names are ignored)
'              Link tables only ever contain two columns: the primary keys of the two tables they join together,
'              therefore, there should only ever be two parameters in Parameters_XML.
'              Return Value is a SQL Error number returned from the stored procedure.
'              A Return Value of zero indicates success.
'
' Inputs    :  SessionID      - User's session id, used for security and audit logging
'              TableName      - name of table
'              ParametersXML  - the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
' 25Nov02 PH - Created
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteDeleteLinkSP"
Dim ErrorState As udtErrorState
   
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnodelist As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMElement
''Dim adoCn As adodb.Connection
Dim adoCmd As ADODB.Command
Dim xmldocLog As MSXML2.DOMDocument
Dim xmlnodeLog As MSXML2.IXMLDOMElement
Dim lngRecordsAffected As Long

   On Error GoTo ErrorHandler
    
   ' Check the SessionID exists in the Session table
   ValidateSessionID SessionID
   
   ' Get the ADO connection and commabd objects ready for use
''   Set adoCn = CreateObject("ADODB.Connection")
   Set adoCmd = CreateObject("ADODB.Command")
    
   ' Get connection string from COM+ constructor string, open and set the connection
''   adoCn.Open ConnectionString
''   Set adoCmd.ActiveConnection = adoCn
   Set adoCmd.ActiveConnection = mADOConnection
   
   ' Set the default ADO properties
   adoCmd.CommandType = adCmdStoredProc
   adoCmd.CommandText = "[p" & TableName & "DELETE]"                                         '15Jan04 AE  Added [] to cope with names with spaces in
   
   'Add the return value parameter (this has to be done first and all SP's have one of these
   adoCmd.Parameters.Append adoCmd.CreateParameter("@Return", adInteger, adParamReturnValue)
     
   ' SessionID is the first parameter to all stored procedures
   adoCmd.Parameters.Append adoCmd.CreateParameter("SessionID", adInteger, adParamInput, 4, SessionID)
   
   ' Create XML DOM to store the Log entry
   Set xmldocLog = New MSXML2.DOMDocument
   Set xmlnodeLog = xmldocLog.createElement(TableName)
   xmldocLog.appendChild xmlnodeLog
   
   If Parameters_XML <> vbNullString Then

      ' Add Parameters tags around parameter list XML
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"
      
      ' Create an XML DOM
      Set xmlDoc = New MSXML2.DOMDocument
      
      'Load XML string into the DOM and if it works proceed
      If Not xmlDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      
      XMLParamsToADO xmlDoc, adoCmd, xmlnodeLog
      
   End If
   
   ' Execute the command, and we will only be interested in the output parameters or return value.
   adoCmd.Execute lngRecordsAffected, , adExecuteNoRecords
''   adoCn.Close
   
   ' Log delete
   If lngRecordsAffected >= 1 Then
      WriteAuditLog SessionID, AuditLogDelete, TableName, 0, xmlnodeLog.xml
   Else
      WriteAuditLog SessionID, AuditLogDelete, TableName, 0, "<error description=""Attempted to delete a row that didnt exist"" table=""" & TableName & """>" & Parameters_XML & "</error>"
   End If

   ' Return the XML parameters
   ExecuteDeleteLinkSP = adoCmd.Parameters("@Return").Value

Cleanup:
   Set xmlnodeLog = Nothing
   Set xmldocLog = Nothing
   Set xmlDoc = Nothing
   Set xmlnodelist = Nothing
   Set xmlnode = Nothing
   Set adoCmd = Nothing
''   Set adoCn = Nothing
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & TableName & ", " & Parameters_XML, , mADOConnection

   Resume Cleanup
End Function

Private Function AdoDataType( _
                                 ByVal enmDataType As trnDataTypeEnum _
                            ) _
                            As ADODB.DataTypeEnum
'------------------------------------------------------------------------------------
' Purpose   :  Converts local Enum to ADO enum
'
' Inputs    :  DataType As trnDataTypeEnum
'
' Outputs   :  None
'
' Return    :  Enum, datatype indicator
'
' Revision History
'
' 03May02 RA - Created
' 18Jan03 PH - Updated
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "AdoDataType"
Dim ErrorState As udtErrorState

   On Error GoTo ErrorHandler

   Select Case enmDataType
      Case trnDataTypeEnum.trnDataTypeChar:             AdoDataType = ADODB.DataTypeEnum.adChar
      Case trnDataTypeEnum.trnDataTypeFloat:            AdoDataType = ADODB.DataTypeEnum.adDouble
      Case trnDataTypeEnum.trnDataTypeint:              AdoDataType = ADODB.DataTypeEnum.adInteger
      Case trnDataTypeEnum.trnDataTypeText:             AdoDataType = ADODB.DataTypeEnum.adLongVarChar
      Case trnDataTypeEnum.trnDataTypeVarChar:          AdoDataType = ADODB.DataTypeEnum.adVarChar
      Case trnDataTypeEnum.trnDataTypeDateTime:         AdoDataType = ADODB.DataTypeEnum.adDBDate
      Case trnDataTypeEnum.trnDataTypeBit:              AdoDataType = ADODB.DataTypeEnum.adBoolean
      Case trnDataTypeEnum.trnDataTypeUniqueIdentifier: AdoDataType = ADODB.DataTypeEnum.adGUID
      Case trnDataTypeEnum.trnDataTypeBase64Binary:     AdoDataType = ADODB.DataTypeEnum.adBinary
      End Select

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState

Exit Function
ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, CStr(enmDataType)
   Resume Cleanup
End Function

Private Function SQLDataTypeToAdoDataType( _
                                               SQLType As String _
                                          ) _
                                          As ADODB.DataTypeEnum
'------------------------------------------------------------------------------------
' Purpose   :  Converts SQL DataType string to ADO enum
'
' Inputs    :  SQL DataType String
'
' Outputs   :  None
'
' Return    :  Enum, datatype indicator
'
' Revision History
'
' 21Oct03 PH - Created
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "SQLDataTypeToAdoDataType"
Dim ErrorState As udtErrorState

   On Error GoTo ErrorHandler

   Select Case SQLType
      Case "bit":              SQLDataTypeToAdoDataType = ADODB.DataTypeEnum.adBoolean
      Case "char":             SQLDataTypeToAdoDataType = ADODB.DataTypeEnum.adChar
      Case "datetime":         SQLDataTypeToAdoDataType = ADODB.DataTypeEnum.adDBDate
      Case "float":            SQLDataTypeToAdoDataType = ADODB.DataTypeEnum.adDouble
      Case "int":              SQLDataTypeToAdoDataType = ADODB.DataTypeEnum.adInteger
      Case "text":             SQLDataTypeToAdoDataType = ADODB.DataTypeEnum.adLongVarChar
      Case "tinyint":          SQLDataTypeToAdoDataType = ADODB.DataTypeEnum.adTinyInt
      Case "uniqueidentifier": SQLDataTypeToAdoDataType = ADODB.DataTypeEnum.adGUID
      Case "varchar":          SQLDataTypeToAdoDataType = ADODB.DataTypeEnum.adVarChar
      Case "image":            SQLDataTypeToAdoDataType = ADODB.DataTypeEnum.adBinary
      End Select

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState

Exit Function
ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SQLType
   Resume Cleanup
End Function

Private Function ValidateSessionID( _
                                    ByVal SessionID As Long _
                                  ) _
                                  As Boolean
'------------------------------------------------------------------------------------
' Purpose   :  Raises an error if the SessionID is invalid.
'           :  Check that all SessionIDs passed to the transport layer are valid active sessions
'           :  SessionID should be checked at the ASP page level along with Policies,
'           :  so this could potentially be removed for release code to improve performance,
'           :  however, having this check in will ensure that developers flow their SessionID info
'           :  correctly through the various application tiers.
'
' Inputs    :  SessionID
'
' Outputs   :  None
'
' Return    :  Boolean
'
' Revision History
'
' 13Jan03 PH - Created
' 06Jan04 PW - Changed to use pharmacy specific stored procedure to avoid locking.
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ValidateSessionID"
Dim ErrorState As udtErrorState
Dim blnReturn As Boolean
   
''Dim adoCn As adodb.Connection
Dim adoCmd As ADODB.Command

   On Error GoTo ErrorHandler
   
   ' Get the ADO connection and commabd objects ready for use
''   Set adoCn = CreateObject("ADODB.Connection")
   Set adoCmd = CreateObject("ADODB.Command")
    
   ' Get connection string from COM+ constructor string, open and set the connection
''   adoCn.Open ConnectionString
''   Set adoCmd.ActiveConnection = adoCn
   Set adoCmd.ActiveConnection = mADOConnection
   
   ' Set the default ADO properties
   adoCmd.CommandType = adCmdStoredProc
   adoCmd.CommandText = "pSessionExistsPharmacy"
        
   'Add the return value parameter (this has to be done first and all SP's have one of these
   adoCmd.Parameters.Append adoCmd.CreateParameter("@Return", adInteger, adParamReturnValue)
   
   'SessionID is the first parameter to all stored procedures
   adoCmd.Parameters.Append adoCmd.CreateParameter("SessionID", adInteger, adParamInput, 4, SessionID)
   
   ' Execute the command, and we will only be interested in the output parameters or return value.
   adoCmd.Execute , , adExecuteNoRecords
''   adoCn.Close
   
   ' Return the XML return value
   blnReturn = (adoCmd.Parameters("@Return").Value > 0)

   If Not blnReturn Then
      RaiseError erInvalidSessionID
   End If

Cleanup:
   Set adoCmd = Nothing
''   Set adoCn = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   ValidateSessionID = blnReturn

   Exit Function

ErrorHandler:
      
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID
   
   Resume Cleanup
End Function

Private Sub XMLParamsToADO(ByRef xmlDoc_IN As MSXML2.DOMDocument _
                           , ByRef adoCmd_INOUT As ADODB.Command _
                           , ByRef xmlnodeLog_INOUT As MSXML2.IXMLDOMElement _
                          )

'------------------------------------------------------------------------------------
' Purpose   :  Copy our proprietry xml parameter definitions into an ADODB.Command object's
'              parameters collection.
'
'
' Inputs    :  xmlDoc_IN:     XMLDocument containing a parameters document (from calls to CreateInputParameterXML)
'
' Outputs   :  adoCmd_INOUT:  ADODB command object. The parameters specified in xmlDoc_IN are added to its
'                             parameters collection
'
' Modification History:
'  28Jul03 AE  Created.  Code moved here from various procedures to centralise special case handling.
'  30Jul03 AE  Updated to hande further changes to CreateInputParameterXML
'  13Oct03 AE  For the various string data types, ensure that the string fits into the field;
'              otherwise, truncate it and add elipsis.  Without this, an ADO error occurrs.
'  15Oct03 PH  Helpfully (not), the XML DOM converts all CrLf characters to Lf, so
'              before we save we have to convert them back.
'  29Mar04 ATW #73575
'              ADO considers params of adVarChar length = 0 to be fine, but rather hates adLongVarChar (text) in this context
'              it also likes to know the actual length of text/ntext fields rather than their defined size (16 bytes, which is a pointer)
'  13Apr04 AE  True, but all of this is irrelevant if you forget to set varValue in the first place.  Fixed above mod.
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "XMLParamsToADO"
Dim ErrorState As udtErrorState
   
'Objects
Dim xmlnodelist As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMElement

'General
Dim varValue As Variant
Dim lngLength As Long
Dim strDebug As String

   On Error GoTo ErrorHandler

   ' Create a nodelist of parameter nodes
   Set xmlnodelist = xmlDoc_IN.selectNodes("//Parameter")
   
   'Fetch all the parameters from the command object's XML description
   For Each xmlnode In xmlnodelist
      lngLength = CLng(xmlnode.getAttribute("Length"))
      'Add parameters to the command object
      Select Case xmlnode.getAttribute("DataType")
         Case adDBDate                                                  '133 - dateTime
            'Special case; the XML dateTime format is in the form 'yyyy-mm-ddTHH:mm:ss', we need to remove the 'T'
            varValue = xmlnode.getAttribute("Value")
            If Not IsNull(varValue) Then
               If Len(varValue) = 5 Then
                  ' Time string
               Else
                  ' TDate string
                  varValue = Replace(CStr(varValue), "T", " ")
               End If
            End If
                        
         Case adVarChar, adVarWChar, adChar
            'Ensure that the string fits into the field; otherwise, truncate it and add elipsis
            varValue = xmlnode.getAttribute("Value")
            If Not IsNull(varValue) Then
               'Leave null parameters as Nulls; otherwise, check the length
               ' 15Oct03 PH Helpfully (not), the XML DOM converts all CrLf characters to Lf, so
               '            before we save we have to convert them back
               varValue = Replace$(CStr(varValue), vbLf, vbCrLf)
               
               varValue = Replace$(CStr(varValue), "###LineFeed###", vbLf) '28May17 TH Horrible frig to stop above frig damaging base64 encoded text (pictures) (TFS 174888)
               
               If Len(varValue) > lngLength Then
                  'Value is too long for the field, truncate it.
''                  varValue = Left$(CStr(varValue), Val(xmlnode.getAttribute("Length")) - 3) & "..."
                  '**V93** Transport layer does not have the right to shorten field and add ellipsis - this would be a UI function
                  '        However an error occurs if the data is too long, so simply truncate here
                  varValue = Left$(CStr(varValue), lngLength)
               End If
            End If
         
         '29Mar04 ATW #73575
         ' ADO considers params of adVarChar length = 0 to be fine, but rather hates adLongVarChar (text) in this context
         ' it also likes to know the actual length of text/ntext fields rather than their defined size (16 bytes, which is a pointer)
         '
         '13Apr04 AE  True, but all of this is irrelevant if you forget to set varValue in the first place.  Fixed above mod.
         '16Apr04 PH  Added extra checking zero length strings, as well as nulls
         Case adLongVarChar, adLongVarWChar
            varValue = xmlnode.getAttribute("Value")                                                                    '13Apr04 AE
            If IsNull(varValue) Then
               lngLength = 1
            Else
               lngLength = Len(varValue)
               If lngLength = 0 Then
                  lngLength = 1
               End If
            End If
         
         Case Else
            'Everything else should be fine
            varValue = xmlnode.getAttribute("Value")
      End Select
      
      If CLng(xmlnode.getAttribute("Direction")) = ADODB.adParamInput Then
         adoCmd_INOUT.Parameters.Append adoCmd_INOUT.CreateParameter( _
                                                            xmlnode.getAttribute("Name"), _
                                                            CLng(xmlnode.getAttribute("DataType")), _
                                                            ADODB.ParameterDirectionEnum.adParamInput, _
                                                            lngLength, _
                                                            varValue _
                                                        )
      Else
         adoCmd_INOUT.Parameters.Append adoCmd_INOUT.CreateParameter( _
                                                            xmlnode.getAttribute("Name"), _
                                                            CLng(xmlnode.getAttribute("DataType")), _
                                                            ADODB.ParameterDirectionEnum.adParamOutput, _
                                                            lngLength _
                                                        )
      End If

      If (Not xmlnodeLog_INOUT Is Nothing) And (Not IsNull(varValue)) Then
         xmlnodeLog_INOUT.setAttribute xmlnode.getAttribute("Name"), varValue
      End If

   Next xmlnode

Cleanup:
   Set xmlnode = Nothing
   Set xmlnodelist = Nothing
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Sub

ErrorHandler:
   'Return a bit more info if we can:
   If Not xmlnode Is Nothing Then strDebug = "xmlNode.xml: '" & xmlnode.xml & "'"
   
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, , strDebug
Resume Cleanup

End Sub

Private Sub WriteAuditLog( _
                           SessionID As Long, _
                           LogType As AuditLogType, _
                           TableName As String, _
                           PrimaryKey As Long, _
                           Data_XML As String, _
                           Optional TableID As Long = -1 _
                        )
    '------------------------------------------------------------------------------------
    ' Purpose   :  Log a database change
    '
    ' Inputs    :  SessionID - User's session id, used for security and audit logging
    '              LogType   - I:Insert, U:Update, D:Delete
    '              TableName - Name of table
    '              PrimaryKey- Unique identifier of table row
    '              Data_XML  - Standard SQL "FOR XML AUTO" format
    '                             e.g. <TableName ColumnName="" ... />
    '
    ' Revision History
    '
    ' 09Feb04 PH - Created
    ' 25May04 TH Added new input parameter - this is for link tables and is set to 0 here as
    '            we dont use these in the pharmacy world
    '04nov08 CKJ pAuditLogInsert uses sp_xml_preparedocument which fails with characters such as ® (r) symbol
    '            most notably when SQL2K is running on W2K3Server. Not only that, but sp_xml_preparedocument
    '            is automatically allocated one eigth of all RAM available to SQL Server and is therefore
    '            not freindly in a multi-user system when the AuditLog gets written to on every Insert or Update.
    '            (msdn.microsoft.com/en-us/library/aa260385(SQL.80).aspx)
    '            Now calls pAuditLogInsertViaTransport, which deferes the XML handling to
    '            the transport layer, allowing the same functionality as if done in SQL.
    '            However at this time Pharmacy is never involved with the InterfaceRegister
    '            table and never needs to parse the XML to decide if a row needs writing.
    '            Therefore this version passes Null and -1 to avoid InterfaceRegister calls.  (F0037051, F0037016)
    '        *** THIS WILL NEED REVIEWING if Pharmacy ever gets used with InterfaceRegister ***
    '17Nov15 DJH TFS 135193 - Added TableID optional parameter.
    '------------------------------------------------------------------------------------
    Const SUB_NAME As String = "WriteAuditLog"
    Dim ErrorState As udtErrorState

    Dim xmlDoc As MSXML2.DOMDocument
    Dim adoCmd As ADODB.Command
    Dim strAuditLogType As String
    Dim lngDataXMLLength As Long

    On Error GoTo ErrorHandler

    Select Case LogType
        Case AuditLogInsert: strAuditLogType = "I"
        Case AuditLogUpdate: strAuditLogType = "U"
        Case AuditLogDelete: strAuditLogType = "D"
    End Select

    lngDataXMLLength = Len(Data_XML)
    If lngDataXMLLength <= 1 Then
        lngDataXMLLength = 1
    End If

    ' Get the ADO command object ready for use
   Set adoCmd = CreateObject("ADODB.Command")

    ' Get connection string from COM+ constructor string, open and set the connection
   Set adoCmd.ActiveConnection = mADOConnection

    ' Set the default ADO properties
    adoCmd.CommandType = adCmdStoredProc
    'adoCmd.CommandText = "[pAuditLogInsert]"             '04nov08 CKJ pAuditLogInsert uses sp_xml_preparedocument
    adoCmd.CommandText = "[pAuditLogInsertViaTransport]"  '   "        this one doesn't

    'Create   procedure pAuditLogInsertViaTransport
    '   (     @CurrentSessionID int
    '      ,  @Table varchar(128)
    '      ,  @TableID int
    '      ,  @PrimaryKey int
    '      ,  @User varchar(128)
    '      ,  @EntityID_User int
    '      ,  @Terminal varchar(128)
    '      ,  @LocationID int
    '      ,  @LogType char(1)
    '      ,  @DataXML text
    '      ,  @PrimaryKeyB int
    '      ,  @ActivityID uniqueidentifier
    '      ,  @TypeID int
    '      ,  @TypeTable varchar(50)
    '   )

    'Create ADO parameters
   adoCmd.Parameters.Append adoCmd.CreateParameter("SessionID", adInteger, adParamInput, 4, SessionID)
   adoCmd.Parameters.Append adoCmd.CreateParameter("TableName", adVarChar, adParamInput, 128, TableName)

    'TFS 135193 - Send Table ID if supplied
    If IsMissing(TableID) Or TableID = -1 Then
        adoCmd.Parameters.Append adoCmd.CreateParameter("TableID", adInteger, adParamInput, 4, Null)
    Else
        adoCmd.Parameters.Append adoCmd.CreateParameter("TableID", adInteger, adParamInput, 4, TableID)
    End If

    adoCmd.Parameters.Append adoCmd.CreateParameter("PrimaryKey", adInteger, adParamInput, 4, PrimaryKey)
    adoCmd.Parameters.Append adoCmd.CreateParameter("User", adVarChar, adParamInput, 128, Null)
    adoCmd.Parameters.Append adoCmd.CreateParameter("EntityID_User", adInteger, adParamInput, 4, Null)
    adoCmd.Parameters.Append adoCmd.CreateParameter("Terminal", adVarChar, adParamInput, 128, Null)
    adoCmd.Parameters.Append adoCmd.CreateParameter("LocationID", adInteger, adParamInput, 4, Null)
    adoCmd.Parameters.Append adoCmd.CreateParameter("LogType", adChar, adParamInput, 1, strAuditLogType)
    adoCmd.Parameters.Append adoCmd.CreateParameter("DataXML", adLongVarChar, adParamInput, lngDataXMLLength, Data_XML)
    adoCmd.Parameters.Append adoCmd.CreateParameter("PrimaryKeyB", adInteger, adParamInput, 4, 0)  '25May04 TH Added
    adoCmd.Parameters.Append adoCmd.CreateParameter("RowThingy", adGUID, adParamInput, 4, Null)  '25May04 TH Added
    adoCmd.Parameters.Append adoCmd.CreateParameter("TypeID", adInteger, adParamInput, 4, -1)          '04nov08 CKJ added. *** REVIEW *** if InterfaceRegister is required (F0037051, F0037016)
    adoCmd.Parameters.Append adoCmd.CreateParameter("TypeTable", adVarChar, adParamInput, 4, Null)     '   "        *** REVIEW *** if InterfaceRegister is required

    ' Execute the command
    adoCmd.Execute , , adExecuteNoRecords


Cleanup:
   Set xmlDoc = Nothing
   Set adoCmd = Nothing

    On Error GoTo 0
   BubbleOnError ErrorState
    Exit Sub

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & LogType & ", " & TableName & ", " & PrimaryKey & ", " & Data_XML, , mADOConnection
    Resume Cleanup
End Sub

Public Function GetRowLock( _
                                   ByVal SessionID As Long, _
                                   ByVal TableName As String, _
                                   ByVal PrimaryKey As Long _
                               ) _
                               As Boolean

    '------------------------------------------------------------------------------------
    ' Purpose   :  Uses SQL to lock a ROW on a given table
    '
    ' Inputs    :  SessionID      -  User's session id, used for security and audit logging
    '              TableName      -  name of Table where locked ROW is required
    '              PrimaryKey     -  Numeric value
    '
    ' Outputs   :
    '
    ' Return    :  Boolean for Success
    '
    ' Revision History
    '
    ' 08Oct2004 PW - Created
    '------------------------------------------------------------------------------------

    Const SUB_NAME As String = "GetRowLock"
    Dim ErrorState As udtErrorState

    Dim adoCmd As ADODB.Command

    Dim strPKColumn As String
    Dim lngRecordsAffected As Long

    On Error GoTo ErrorHandler

    If ExecuteSelectReturnSP(SessionID, "pIsInTransaction", "") Then
        ' Get the ADO connection and commabd objects ready for use
      Set adoCmd = CreateObject("ADODB.Command") ''
      Set adoCmd.ActiveConnection = mADOConnection


        ' Set the default ADO properties
        adoCmd.CommandType = adCmdText

        strPKColumn = TableName & "ID"

        adoCmd.CommandText = " SELECT " & strPKColumn _
                          & " FROM  " & TableName & " WITH (UPDLOCK)" _
                          & " WHERE  " _
                          & strPKColumn & " = " & CStr(PrimaryKey)

      adoCmd.Execute
        GetRowLock = True

    Else
      Debug.Print "WARNING: UNABLE TO LOCK, NOT IN A TRANSACTION"
        GetRowLock = False
    End If

Cleanup:

   Set adoCmd = Nothing

    On Error GoTo 0
   BubbleOnError ErrorState

    Exit Function

ErrorHandler:
    If Err.Number = -2147217871 Then
        GetRowLock = False
    Else
        GetRowLock = False
      CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME _
                                , " TableName = " & TableName _
                              & ", PK = " & CStr(PrimaryKey)
    End If
    Resume Cleanup

End Function
Public Sub ADOSetConnectionTimeOut(ByVal lngLOCKRETRYEXCEEDED As Long)
    'This will be set at the start and remain for the whole session.
    ' The LOCKRETRYEXCEEDED is a value in milliseconds

    Dim ErrorState As udtErrorState

    On Error GoTo ErrorHandler


   mADOConnection.Execute "SET LOCK_TIMEOUT " & lngLOCKRETRYEXCEEDED
    mADOConnection.IsolationLevel = adXactReadCommitted


Cleanup:

    Exit Sub
ErrorHandler:

   CaptureErrorState ErrorState, CLASS_NAME, "mADOConnection_ConnectComplete"


    Resume Cleanup


End Sub

Public Function CheckSPExists(ByVal sp As String) As Boolean

    Dim ErrorState As udtErrorState
    Dim adoCmd As ADODB.Command
    Dim rs As ADODB.Recordset
    
    On Error GoTo ErrorHandler
    
    Set adoCmd = CreateObject("ADODB.Command")
    Set adoCmd.ActiveConnection = mADOConnection
    
    adoCmd.CommandType = adCmdText
    
    adoCmd.CommandText = " SELECT TOP 1 1 FROM sys.objects " _
                          & " WHERE type = 'P' AND name = '" & sp & "'"
                          
    Set rs = adoCmd.Execute
    
    If Not rs.EOF Then
        CheckSPExists = True
    Else
        CheckSPExists = False
    End If
    
Cleanup:
   Set adoCmd = Nothing
   On Error Resume Next
   rs.Close
   Set rs = Nothing
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CheckSPExists = False
   CaptureErrorState ErrorState, CLASS_NAME, "CheckSPExists", sp
   Resume Cleanup
End Function

Public Function IsInTransaction(ByVal SessionID As Long) As Boolean
    'Checks to see if there is a transaction open on the Global connection

    If ExecuteSelectReturnSP(SessionID, "pIsInTransaction", "") Then
        IsInTransaction = True
    Else
        IsInTransaction = False
    End If

End Function


Private Sub mADOConnection_ConnectComplete(ByVal pError As ADODB.Error, adStatus As ADODB.EventStatusEnum, ByVal pConnection As ADODB.Connection)
    'This will be set at the start and remain for the whole session.
    ' The LOCKRETRYEXCEEDED is a value in milliseconds

    Dim ErrorState As udtErrorState

    On Error GoTo ErrorHandler


   mADOConnection.Execute "SET LOCK_TIMEOUT " & LOCKRETRYEXCEEDED
    mADOConnection.IsolationLevel = adXactReadCommitted


Cleanup:

    Exit Sub
ErrorHandler:

   CaptureErrorState ErrorState, CLASS_NAME, "mADOConnection_ConnectComplete"


    Resume Cleanup


End Sub

