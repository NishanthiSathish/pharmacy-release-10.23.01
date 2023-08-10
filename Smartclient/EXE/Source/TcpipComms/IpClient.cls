VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IpClient"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
Option Explicit
DefInt A-Z
'----------------------------------------------------------------------------------
'
' Purpose: This is the class exposed to the calling application. It provides the
'          TCPIP communication properties and events.
'
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------
Const CLASS_NAME = "mfrmClient"

Private Const BASIC_TOOLTIP_TEXT = "ascribe TCPIP Communication Client"

Private WithEvents mfrmMain As frmTcpipComms
Attribute mfrmMain.VB_VarHelpID = -1

'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Connected[(arg1, arg2, ... , argn)]
Public Event Connected(ByVal Status As Integer, ByVal Description As String)
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent DataIn[(arg1, arg2, ... , argn)]
Public Event DataIn(ByVal Data As String, ByVal EOL As Boolean)
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Disconnected[(arg1, arg2, ... , argn)]
Public Event Disconnected(ByVal Status As Integer, ByVal Description As String)
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Error[(arg1, arg2, ... , argn)]
Public Event Error(ByVal ErrorCode As Integer, ByVal Description As String)
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent ReadyToSend[(arg1, arg2, ... , argn)]
Public Event ReadyToSend()








Private Sub SetToolTipText()
'----------------------------------------------------------------------------------
'
' Purpose: This subroutine sets the text to be used as the tooltip for the icon in
'          the notification area.
'
' Inputs:      None
'
' Outputs:     None
'
'
' Modification History:
'  10Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "SetToolTipText"

Dim udtError As udtErrorState

Dim strTip As String

   On Error GoTo ErrorHandler

   strTip = BASIC_TOOLTIP_TEXT
   
   With mfrmMain.mfrmClient.IPPort
      If Len(.RemoteHost) > 0 Then
         strTip = strTip & " - Host: " & Trim$(.RemoteHost)
         
         If (.RemotePort > 0) Then
            strTip = strTip & " Port: " & Format$(.RemotePort)
         End If
      End If
   End With
   
   ModifySysTrayToolTip strTip
   

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Public Property Get WinsockStatus() As String
'----------------------------------------------------------------------------------
'
' Purpose: Reads the status of the Winsock stack used by the IP Port control.
'
' Inputs:
'
' Outputs: A string containing status text from the Winsock Stack.
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "WinsockStatus"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   WinsockStatus = mfrmMain.mfrmClient.IPPort.WinsockStatus

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property






Public Property Get WinsockLoaded() As Boolean
'----------------------------------------------------------------------------------
'
' Purpose: Reads if the IP Port control has loaded the Winsock Stack.
'
' Inputs:
'
' Outputs: a boolean value - TRUE if the Winsock Stack is loaded
'                          - FALSE if the Winsock stack is not loaded
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "WinsockLoaded"

Dim udtError As udtErrorState



   On Error GoTo ErrorHandler

   WinsockLoaded = mfrmMain.mfrmClient.IPPort.WinsockLoaded

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Property



Public Property Let RemotePort(ByVal vData As Integer)
'----------------------------------------------------------------------------------
'
' Purpose: Sets the port number that will be used when connecting to the remote host.
'
' Inputs:
'     vData    :  The port number as an integer
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "RemotePort"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   mfrmMain.mfrmClient.IPPort.RemotePort = vData

   SetToolTipText

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property


Public Property Get RemotePort() As Integer
'----------------------------------------------------------------------------------
'
' Purpose: Reads the defined port number to be used when connecting to the remote host.
'
' Inputs:
'
' Outputs: An remote host port number as an integer.
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "RemotePort"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   RemotePort = mfrmMain.mfrmClient.IPPort.RemotePort

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property



Public Property Let RemoteHost(ByVal vData As String)
'----------------------------------------------------------------------------------
'
' Purpose: Sets the IP address or DNS name of the remote machine that a connection
'          will be attempted. If a DNS name is provided, the IP Port control will
'          attempt to resolve the name to an IP address prior to connecting.
'
' Inputs:
'     vData    :  the IP Address or DNS name of the remote machine
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "RemoteHost"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   mfrmMain.mfrmClient.IPPort.RemoteHost = vData
   
   SetToolTipText

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property


Public Property Get RemoteHost() As String
'----------------------------------------------------------------------------------
'
' Purpose: Reads the currently defined IP Address of the host that the IP Port is/will
'          connect to.
'
' Inputs:
'
' Outputs: A string identifying the IP Address of the remote machine.
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "RemoteHost"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   RemoteHost = mfrmMain.mfrmClient.IPPort.RemoteHost

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property



Public Property Let OutBufferSize(ByVal vData As Long)
'----------------------------------------------------------------------------------
'
' Purpose: Sets the length of the output buffer in the IP Port control
'
' Inputs:
'     vData    :  The new length of the output buffer
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "OutBufferSize"

Dim udtError As udtErrorState



   On Error GoTo ErrorHandler

   mfrmMain.mfrmClient.IPPort.OutBufferSize = vData

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property


Public Property Get OutBufferSize() As Long
'----------------------------------------------------------------------------------
'
' Purpose: Reads the current length of the output buffer of the IP Port control.
'
' Inputs:
'
' Outputs: Returns a long integer for the length of the output buffer.
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "OutBufferSize"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   OutBufferSize = mfrmMain.mfrmClient.IPPort.OutBufferSize

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property



Public Property Let MaxLineLength(ByVal vData As Long)
'----------------------------------------------------------------------------------
'
' Purpose: This property sets the number of characters that will be read from the
'          incoming data stream prior to an EOL sequence being found. Once the number
'          of characters has been reached with no EOL sequence being found, the DataIn
'          event will be fired with the EOL set to false.
'
' Inputs:
'     vData    :  A long integer specifying the number of characters to read.
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "MaxLineLength"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   mfrmMain.mfrmClient.IPPort.MaxLineLength = vData

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property


Public Property Get MaxLineLength() As Long
'----------------------------------------------------------------------------------
'
' Purpose: Reads the currently defined maximum line length defined on the IP Port
'          control. The maximum line length determines the number of characters that
'          will be read from the input buffer prior to an EOL sequence being encountered.
'
' Inputs:
'
' Outputs: A long integer defining the number of characters to be read.
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "MaxLineLength"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   MaxLineLength = mfrmMain.mfrmClient.IPPort.MaxLineLength

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property



Public Property Let Linger(ByVal vData As Boolean)
'----------------------------------------------------------------------------------
'
' Purpose: Enables or disables the Linger functionality of the IP Port control.
'
' Inputs:
'     vData    :  A boolean value - TRUE to enable the Linger functionality
'                                 - FALSE to disable the Linger functionality
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "Linger"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   mfrmMain.mfrmClient.IPPort.Linger = vData

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property


Public Property Get Linger() As Boolean
'----------------------------------------------------------------------------------
'
' Purpose: Reads the current setting for the Linger functionality of the IP Port control.
'
' Inputs:
'
' Outputs: A boolean value - TRUE if the Linger functionality is enabled
'                          - FALSE if the Linger functionality is disabled
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "Linger"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   Linger = mfrmMain.mfrmClient.IPPort.Linger

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property



Public Property Let KeepAlive(ByVal vData As Boolean)
'----------------------------------------------------------------------------------
'
' Purpose: Sets the KeepAlive functionality of the IP Port control
'
' Inputs:
'     vData    :  A boolean value - TRUE to activate the KeepAlive functionality
'                                 - FALSE to deactivate the KeepAlive functionality
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "KeepAlive"

Dim udtError As udtErrorState



   On Error GoTo ErrorHandler

   mfrmMain.mfrmClient.IPPort.KeepAlive = vData

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Property


Public Property Get KeepAlive() As Boolean
'----------------------------------------------------------------------------------
'
' Purpose: Reads the current setting for the KeepAlive functionality of the IP Port control.
'
' Inputs:
'
' Outputs:  Returns a Boolean value - FALSE if the KeepAlive functionality is not set
'                                   - TRUE if the KeepAlive functionality is set
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "KeepAlive"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   KeepAlive = mfrmMain.mfrmClient.IPPort.KeepAlive

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property



Public Property Let EOL(ByVal vData As String)
'----------------------------------------------------------------------------------
'
' Purpose: Sets the EOL sequence of the IP Port control
'
' Inputs:
'     vData    :  the string to be used as the EOL sequence
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "EOL"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler

   mfrmMain.mfrmClient.IPPort.EOL = vData

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property


Public Property Get EOL() As String
'----------------------------------------------------------------------------------
'
' Purpose: Reads the currently defined EOL sequence from the IP Port control
'
' Inputs:
'
' Outputs: The currently defined EOL sequence as a string
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "EOL"

Dim udtError As udtErrorState



   On Error GoTo ErrorHandler

   EOL = mfrmMain.mfrmClient.IPPort.EOL

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property



Public Property Let DataToSend(ByVal vData As String)
'----------------------------------------------------------------------------------
'
' Purpose: DataToSend is used to pass some data across the IP connection to the
'          remote host
'
' Inputs:
'     vData        :  the data to be transmitted
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "DataToSend"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler

   mfrmMain.mfrmLog.AddEntry "Sending data : '" & vData & "'"
   
   mfrmMain.mfrmClient.IPPort.DataToSend = vData

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Property






Public Property Let Connected(ByVal vData As Boolean)
'----------------------------------------------------------------------------------
'
' Purpose: Instructs the IP Port to connect or disconnect from an IP host
'
' Inputs:
'     vData        :  A boolean value - TRUE instructs the IP Port to attempt connection
'                                       to the IP host identified by the RemoteHost and
'                                       RemotePort properties.
'                                     - FALSE instructs the IP Port to disconnect from
'                                       the IP host it is currently connected to.
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "Connected"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler

   With mfrmMain.mfrmClient.IPPort
      If (vData) Then
         mfrmMain.mfrmLog.AddEntry "Connecting to host on " & .RemoteHost & " port " & Format$(RemotePort)
      Else
         mfrmMain.mfrmLog.AddEntry "Disconnecting from host on " & .RemoteHost & " port " & Format$(RemotePort)
      End If
      
      .Connected = vData
   End With
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property


Public Property Get Connected() As Boolean
'----------------------------------------------------------------------------------
'
' Purpose: Reads if the IP Port control is connected to an IP host
'
' Inputs:
'
' Outputs:
'           Boolean - TRUE if IP Port is connected to an IP Host
'                   - FALSE if the IP Port is not connected to an IP Host
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "Connected"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler

    Connected = mfrmMain.mfrmClient.IPPort.Connected

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property



Public Property Let AcceptData(ByVal vData As Boolean)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     vData        :  Boolean value - TRUE ip port to accept data
'                                   - FALSE ip port not accept data
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "AcceptData"

Dim udtError As udtErrorState



   On Error GoTo ErrorHandler

   mfrmMain.mfrmLog.AddEntry "Accepting data = " & IIf(vData, "True", "False")
   
   mfrmMain.mfrmClient.IPPort.AcceptData = vData

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Property


Public Property Get AcceptData() As Boolean
'----------------------------------------------------------------------------------
'
' Purpose:  Reads whether or not the IP Port control is currently accepting data
'
' Inputs:   None
'
' Outputs:  Boolean - TRUE if accepting data
'                   - FALSE if not accepting data
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "AcceptData"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   AcceptData = mfrmMain.mfrmClient.IPPort.AcceptData

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Property

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Property



Private Sub Class_Initialize()

   On Error Resume Next
   
   Set mfrmMain = New frmTcpipComms
   
   ShowIconInSysTray mfrmMain, BASIC_TOOLTIP_TEXT
   
   On Error GoTo 0
   
End Sub


Private Sub Class_Terminate()

   On Error Resume Next
   
   RemoveIconFromSysTray

   Unload mfrmMain
   
   Set mfrmMain = Nothing
   
   On Error GoTo 0
   
End Sub




Private Sub mfrmMain_Connected(ByVal Status As Integer, ByVal Description As String)
'----------------------------------------------------------------------------------
'
' Purpose: Raises a socket connected event to the calling application. The event occurs
'          on success or failure of a connection attempt to a remote host.
'
' Inputs:
'     Status      :  Zero if successfully connected, a non-zero number indicating the
'                    error number if the connection failed.
'     Description :  Blank if successfully connected, otherwise the error description.
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "mfrmMain_Connected"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler
   
   RaiseEvent Connected(Status, Description)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub


Private Sub mfrmMain_DataIn(ByVal Data As String, ByVal EOL As Boolean)
'----------------------------------------------------------------------------------
'
' Purpose: Alerts the calling application when we have received data from the remote
'          host.
'
' Inputs:
'     Text     :  The data received from the remote host
'     EOL      :  A boolean indicating if the EOL sequence was received with data.
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "mfrmMain_DataIn"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler
   
   RaiseEvent DataIn(Data, EOL)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub


Private Sub mfrmMain_Disconnected(ByVal Status As Integer, ByVal Description As String)
'----------------------------------------------------------------------------------
'
' Purpose: Raises a socket disconnected event to the calling application. The event occurs
'          on success or failure of a disconnection attempt or when the remote host drops
'          the connection independantly of the client.
'
' Inputs:
'     Status      :  Zero if successfully connected, a non-zero number indicating the
'                    error number if the connection failed.
'     Description :  Blank if successfully connected, otherwise the error description.
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "mfrmMain_Disconnected"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler

   RaiseEvent Disconnected(Status, Description)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub


Private Sub mfrmMain_Error(ByVal ErrorCode As Integer, ByVal Description As String)
'----------------------------------------------------------------------------------
'
' Purpose: Notifies the calling application when an error has occurred when using the
'          IP Port control to manage the TCPIP communications.
'
' Inputs:
'     ErrorCode      :  The error number as an integer
'     Description    :  The error description as a text string
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "mfrmMain_Error"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler
      
   RaiseEvent Error(ErrorCode, Description)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub


Private Sub mfrmMain_ReadyToSend()
'----------------------------------------------------------------------------------
'
' Purpose: Notifies the calling application that the IP Port is ready to resume
'          transmitting data to the remote host.
'
' Inputs:
'
' Outputs:
'
' Modification History:
'  05Jan07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "mfrmMain_ReadyToSend"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler
   
   RaiseEvent ReadyToSend

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub


