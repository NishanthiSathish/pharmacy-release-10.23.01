VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Config"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Description = "Holds the configuration information for this instance of the ICW Message Processor."
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit
DefInt A-Z

Private Const CLASS_NAME = "Config."

'registry key name constants
Private Const KEY_APP_NAME = "ICWEventNotifier"
Private Const KEY_ASCRIBE = "ASCribe"
Private Const KEY_BASE = "\HKEY_LOCAL_MACHINE\SOFTWARE"
Private Const SLASH = "\"
Private Const KEY_VERSION = "V1"

'registry Field Name constants
Private Const PROCESSING_MODE = "ProcessingMode"
Private Const PROCESSING_INTERVAL = "ProcessingInterval"
Private Const TRANSFORMATION_DLL_APP_ID = "TransformDllAppId"
Private Const LOGIN_NAME = "LoginName"
Private Const LOGIN_PWD = "LoginPwd"
Private Const LOGIN_LOCATION = "LoginLocation"
Private Const OUTPUT_DIRECTORY = "OutputDirectory"
Private Const OUTPUT_FILE_EXTN = "OutputFileExtn"
Private Const INF_APP_ID = "InfAppId"
Private Const LOGGING = "LoggingMode"

'public variables
Public Enum ProcessingMode
    Manual = 1
    Automatic = 2
End Enum

Public Enum Status
    Stopped = 2
    Waiting = 3
    Running = 1
End Enum

Private mboolRegistryBuilt As Boolean

'local variable(s) to hold property value(s)
Private mstrInstanceName As String 'local copy
Private mstrSystemTrayToolTipText As String 'local copy
Private menumMsgProcessing As ProcessingMode 'local copy
Private mlngProcessingInterval As Long 'local copy
Private menumProcessorState As Status 'local copy
Private mboolShowMessages As Boolean 'local copy
Private mvarLastMessageProcessed As Variant 'local copy
Private mvarLastErrorOccurred As Variant 'local copy
Private mstrTransformationDllAppID As String 'local copy
Private mlngSessionId As Long 'local copy
Private mstrLoginName As String 'local copy
Private mstrLoginPwd As String 'local copy
Private mboolLoggedIn As Boolean 'local copy
Private mstrLoginLocation As String 'local copy
Private mstrOutputDirectory As String 'local copy
Private mstrOutputFileExtn As String 'local copy
Private mstrINFAppID As String
Private mboolLoggingOn As Boolean
Public Property Let LoginLocation(ByVal vData As String)
'used when assigning a value to the property, on the left side of an assignment.
'Syntax: X.LoginLocation = 5
    mstrLoginLocation = vData
End Property


Public Property Get LoginLocation() As String
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.LoginLocation
    LoginLocation = mstrLoginLocation
End Property





Public Property Get LoggedIn() As Boolean
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.LoggedIn
    LoggedIn = mboolLoggedIn
End Property



Public Property Let LoginPwd(ByVal vData As String)
'used when assigning a value to the property, on the left side of an assignment.
'Syntax: X.LoginPwd = 5
    mstrLoginPwd = vData
End Property


Public Property Get LoginPwd() As String
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.LoginPwd
    LoginPwd = mstrLoginPwd
End Property



Public Property Let LoginName(ByVal vData As String)
'used when assigning a value to the property, on the left side of an assignment.
'Syntax: X.LoginName = 5
    mstrLoginName = vData
End Property


Public Property Get LoginName() As String
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.LoginName
    LoginName = mstrLoginName
End Property

Public Property Get OutputDirectory() As String

   OutputDirectory = mstrOutputDirectory
   
End Property

Public Property Let OutputDirectory(ByVal sData As String)

   mstrOutputDirectory = sData
   
End Property

Public Property Get OutputFileExtension() As String

   OutputFileExtension = mstrOutputFileExtn
   
End Property

Public Property Let OutputFileExtension(ByVal sData As String)

   mstrOutputFileExtn = sData
   
End Property

Public Property Get SessionId() As Long
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.SessionId
    SessionId = mlngSessionId
End Property

Public Property Let TransformationDllAppID(ByVal vData As String)
'used when assigning a value to the property, on the left side of an assignment.
'Syntax: X.TransformationDllAppID = 5
    mstrTransformationDllAppID = vData
End Property


Public Property Get TransformationDllAppID() As String
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.TransformationDllAppID
    TransformationDllAppID = mstrTransformationDllAppID
End Property


Public Property Let LastErrorOccurred(ByVal vData As Variant)
'used when assigning a value to the property, on the left side of an assignment.
'Syntax: X.LastErrorOccurred = 5
    mvarLastErrorOccurred = vData
End Property

Public Property Get LastErrorOccurred() As Variant
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.LastErrorOccurred
    LastErrorOccurred = mvarLastErrorOccurred
End Property

Public Property Let LastMessageProcessed(ByVal vData As Variant)
'used when assigning a value to the property, on the left side of an assignment.
'Syntax: X.LastMessageProcessed = 5
    mvarLastMessageProcessed = vData
End Property

Public Property Get LastMessageProcessed() As Variant
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.LastMessageProcessed
    LastMessageProcessed = mvarLastMessageProcessed
End Property

Public Property Let ShowMessages(ByVal Data As Boolean)
'used when assigning a value to the property, on the left side of an assignment.
'Syntax: X.ShowMessages = 5
    mboolShowMessages = Data
End Property

Public Property Get ShowMessages() As Boolean
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.ShowMessages
    ShowMessages = mboolShowMessages
End Property

Public Property Let ProcessorState(ByVal vData As Status)
'used when assigning a value to the property, on the left side of an assignment.
'Syntax: X.ProcessorState = 5
    menumProcessorState = vData
End Property

Public Property Get ProcessorState() As Status
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.ProcessorState
    ProcessorState = menumProcessorState
End Property

Public Property Let ProcessingInterval(ByVal vData As Long)
'used when assigning a value to the property, on the left side of an assignment.
'Syntax: X.ProcessingInterval = 5
    mlngProcessingInterval = vData
End Property


Public Property Get ProcessingInterval() As Long
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.ProcessingInterval
    ProcessingInterval = mlngProcessingInterval
End Property



Public Property Let MsgProcessing(ByVal vData As ProcessingMode)
'used when assigning a value to the property, on the left side of an assignment.
'Syntax: X.MsgProcessing = 5
    menumMsgProcessing = vData
End Property


Public Property Get MsgProcessing() As ProcessingMode
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.MsgProcessing
    MsgProcessing = menumMsgProcessing
End Property

Public Sub SaveConfig()

Const SUB_NAME = "SaveConfig"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
   
   BuildRegistryPath
   
   WriteRegistry
   
Cleanup:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Public Sub LoadConfig(ByVal sInstanceName As String)

Const SUB_NAME = "LoadConfig"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler
   
   If UCase$(sInstanceName) <> mstrInstanceName Then
         mstrInstanceName = UCase$(sInstanceName)
         mstrSystemTrayToolTipText = "ascribe ICW Event Notifier V1 : InstanceName=" & mstrInstanceName
         
         mboolRegistryBuilt = False
         BuildRegistryPath
         
         ReadRegistry
      End If
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError
   
Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub WriteRegistry()

Const SUB_NAME = "WriteRegistry"

Dim uError As udtErrorState
Dim oReg As RegObj.Registry
Dim oKey As RegObj.RegKey

   On Error GoTo ErrorHandler
      
   Set oReg = CreateObject("RegObj.Registry")
   Set oKey = oReg.RegKeyFromString(KEY_BASE & SLASH & _
                                    KEY_ASCRIBE & SLASH & _
                                    KEY_APP_NAME & SLASH & _
                                    KEY_VERSION & SLASH & _
                                    mstrInstanceName)
   
   oKey.Values(LOGIN_NAME).Value = encodehex(mstrLoginName)
   oKey.Values(LOGIN_PWD).Value = encodehex(mstrLoginPwd)
   oKey.Values(LOGIN_LOCATION).Value = encodehex(mstrLoginLocation)
   
   oKey.Values(PROCESSING_MODE).Value = menumMsgProcessing
   oKey.Values(PROCESSING_INTERVAL).Value = mlngProcessingInterval
   oKey.Values(TRANSFORMATION_DLL_APP_ID).Value = mstrTransformationDllAppID
   oKey.Values(OUTPUT_DIRECTORY).Value = mstrOutputDirectory
   oKey.Values(OUTPUT_FILE_EXTN).Value = mstrOutputFileExtn
   oKey.Values(INF_APP_ID).Value = mstrINFAppID
   oKey.Values(LOGGING).Value = Abs(mboolLoggingOn)
   
Cleanup:

   On Error GoTo 0
   If Not oKey Is Nothing Then Set oKey = Nothing
   If Not oReg Is Nothing Then Set oReg = Nothing
   
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Public Sub Logout()

Const ERROR_TAG = "Error"

Const SUB_NAME = "Logout"

Dim uError As udtErrorState

Dim objDOM As MSXML2.DOMDocument
Dim objParams As Scripting.Dictionary
Dim objPAS As Object

Dim strExtraInfo As String
Dim strReturn As String

   On Error GoTo ErrorHandler
         
   strExtraInfo = "Creating the " & mstrINFAppID & ".SecurityProxy object"
   Set objPAS = CreateObject(mstrINFAppID & ".SecurityProxy")

   'call the logout method
   strExtraInfo = "Calling LogoutUser method with SessionID = '" & Format$(mlngSessionId) & "'"
   strReturn = objPAS.LogoutUser(mlngSessionId)
   
   Set objPAS = Nothing
   
   strExtraInfo = "Processing the returned login XML"
   
   LoadXML "<Root>" & strReturn & "</Root>", objDOM
   If objDOM.documentElement.childNodes.length > 0 Then
         Err.Raise vbObjectError + 1003, _
                   SUB_NAME, _
                   objDOM.documentElement.firstChild.Attributes.getNamedItem("Code").Text & _
                   " - " & _
                   objDOM.documentElement.firstChild.Attributes.getNamedItem("Text").Text
      End If
               
Cleanup:

   On Error Resume Next
   
   Set objPAS = Nothing
   Set objParams = Nothing
   Set objDOM = Nothing
   
   mlngSessionId = -1
   mboolLoggedIn = False
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME, , strExtraInfo & " - Returned XML = '" & strReturn & "'"
   Resume Cleanup
   
End Sub


Public Sub Login()

Const ERROR_TAG = "BrokenRules"

Const SUB_NAME = "Login"

Dim uError As udtErrorState

Dim objDOM As MSXML2.DOMDocument
Dim objParams As Scripting.Dictionary
Dim objPAS As Object

Dim strExtraInfo As String
Dim strParameterXML As String
Dim strReturn As String

   On Error GoTo ErrorHandler
   mboolLoggedIn = False
      
   strExtraInfo = "Creating the " & mstrINFAppID & ".SecurityProxy object."
   Set objPAS = CreateObject(mstrINFAppID & ".SecurityProxy")

   'call the login method
   strExtraInfo = "Calling Login method with parameterXML = '" & strParameterXML & "'"
   strReturn = objPAS.LoginUser(mstrLoginName, mstrLoginPwd, 0, False)
   Set objPAS = Nothing
   
   strExtraInfo = "Processing the returned login XML"
   
   LoadXML strReturn, objDOM
   If objDOM.documentElement.nodeName = ERROR_TAG Then
         Err.Raise vbObjectError + 1003, _
                   SUB_NAME, _
                   objDOM.documentElement.firstChild.Attributes.getNamedItem("Code").Text & _
                   " - " & _
                   objDOM.documentElement.firstChild.Attributes.getNamedItem("Text").Text
      Else
         mlngSessionId = Val(objDOM.documentElement.Attributes.getNamedItem("SessionID").Text)
         mboolLoggedIn = True
      End If
               
Cleanup:

   On Error Resume Next
   Set objPAS = Nothing
   Set objParams = Nothing
   Set objDOM = Nothing
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME, , strExtraInfo & " - Returned XML = '" & strReturn & "'"
   Resume Cleanup
   
End Sub

Private Sub ReadRegistry()

Const SUB_NAME = "ReadRegistry"

Dim uError As udtErrorState
Dim oReg As RegObj.Registry
Dim oKey As RegObj.RegKey

   On Error GoTo ErrorHandler
      
   Set oReg = CreateObject("RegObj.Registry")
   Set oKey = oReg.RegKeyFromString(KEY_BASE & SLASH & _
                                    KEY_ASCRIBE & SLASH & _
                                    KEY_APP_NAME & SLASH & _
                                    KEY_VERSION & SLASH & _
                                    mstrInstanceName)
   
   mstrLoginName = decodehex(oKey.Values(LOGIN_NAME).Value)
   mstrLoginPwd = decodehex(oKey.Values(LOGIN_PWD).Value)
   mstrLoginLocation = decodehex(oKey.Values(LOGIN_LOCATION).Value)
   
   menumMsgProcessing = oKey.Values(PROCESSING_MODE).Value
   mlngProcessingInterval = oKey.Values(PROCESSING_INTERVAL).Value
   mstrTransformationDllAppID = oKey.Values(TRANSFORMATION_DLL_APP_ID).Value
   mstrOutputDirectory = oKey.Values(OUTPUT_DIRECTORY).Value
   mstrOutputFileExtn = oKey.Values(OUTPUT_FILE_EXTN).Value
   
   mstrINFAppID = oKey.Values(INF_APP_ID).Value
   
   mboolLoggingOn = (oKey.Values(LOGGING).Value <> 0)
   
Cleanup:

   On Error GoTo 0
   If Not oKey Is Nothing Then Set oKey = Nothing
   If Not oReg Is Nothing Then Set oReg = Nothing
   
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub BuildRegistryPath()

Dim oReg As RegObj.Registry
Dim oKey As RegObj.RegKey
Dim sRegKey As String


   If mboolRegistryBuilt Then Exit Sub
   
   Set oReg = CreateObject("RegObj.Registry")
   
   On Error Resume Next
   
   sRegKey = KEY_BASE
   Set oKey = oReg.RegKeyFromString(sRegKey)
   oKey.SubKeys.Add KEY_ASCRIBE
   
   sRegKey = sRegKey & SLASH & KEY_ASCRIBE
   Set oKey = oReg.RegKeyFromString(sRegKey)
   oKey.SubKeys.Add KEY_APP_NAME
   
   sRegKey = sRegKey & SLASH & KEY_APP_NAME
   Set oKey = oReg.RegKeyFromString(sRegKey)
   oKey.SubKeys.Add KEY_VERSION
   
   sRegKey = sRegKey & SLASH & KEY_VERSION
   Set oKey = oReg.RegKeyFromString(sRegKey)
   oKey.SubKeys.Add mstrInstanceName
   
   sRegKey = sRegKey & SLASH & mstrInstanceName
   Set oKey = oReg.RegKeyFromString(sRegKey)
   
   'add required parameters as values of the key
   oKey.Values.Add LOGIN_NAME, vbNullString, rvString
   oKey.Values.Add LOGIN_PWD, vbNullString, rvString
   oKey.Values.Add LOGIN_LOCATION, vbNullString, rvString
   
   oKey.Values.Add PROCESSING_INTERVAL, 10, rvLong
   oKey.Values.Add PROCESSING_MODE, ProcessingMode.Manual, rvLong
   oKey.Values.Add TRANSFORMATION_DLL_APP_ID, vbNullString, rvString
   oKey.Values.Add OUTPUT_DIRECTORY, vbNullString, rvString
   oKey.Values.Add OUTPUT_FILE_EXTN, vbNullString, rvString
   oKey.Values.Add INF_APP_ID, vbNullString, rvString
   
   oKey.Values.Add LOGGING, 0, rvLong
   
   If Not oKey Is Nothing Then Set oKey = Nothing
   If Not oReg Is Nothing Then Set oReg = Nothing
   
   mboolRegistryBuilt = True
   
   On Error GoTo 0
   
End Sub

Public Property Get SystemTrayToolTipText() As String
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.SystemTrayToolTipText
    SystemTrayToolTipText = mstrSystemTrayToolTipText
End Property

Public Property Get InstanceName() As String
Attribute InstanceName.VB_UserMemId = 0
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.InstanceName
    InstanceName = mstrInstanceName
End Property







Public Property Get LoggingOn() As Boolean

   LoggingOn = mboolLoggingOn
   
End Property

Public Property Let LoggingOn(ByVal NewValue As Boolean)

   mboolLoggingOn = NewValue

End Property

Public Property Get INFAppId() As String

   INFAppId = mstrINFAppID

End Property

Public Property Let INFAppId(ByVal strValue As String)

   mstrINFAppID = strValue
   
End Property
