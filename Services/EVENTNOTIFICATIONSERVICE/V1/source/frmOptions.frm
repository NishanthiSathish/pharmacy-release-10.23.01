VERSION 5.00
Object = "{BDC217C8-ED16-11CD-956C-0000C04E4C0A}#1.1#0"; "tabctl32.ocx"
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "comdlg32.ocx"
Begin VB.Form frmOptions 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Caption"
   ClientHeight    =   3105
   ClientLeft      =   2760
   ClientTop       =   4035
   ClientWidth     =   6030
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3105
   ScaleWidth      =   6030
   ShowInTaskbar   =   0   'False
   Begin TabDlg.SSTab SSTab1 
      Height          =   2985
      Left            =   60
      TabIndex        =   0
      Top             =   60
      Width           =   5955
      _ExtentX        =   10504
      _ExtentY        =   5265
      _Version        =   393216
      Tabs            =   4
      TabsPerRow      =   4
      TabHeight       =   520
      TabCaption(0)   =   "Mode"
      TabPicture(0)   =   "frmOptions.frx":0000
      Tab(0).ControlEnabled=   -1  'True
      Tab(0).Control(0)=   "fraMode"
      Tab(0).Control(0).Enabled=   0   'False
      Tab(0).ControlCount=   1
      TabCaption(1)   =   "Login"
      TabPicture(1)   =   "frmOptions.frx":001C
      Tab(1).ControlEnabled=   0   'False
      Tab(1).Control(0)=   "fraLogin"
      Tab(1).ControlCount=   1
      TabCaption(2)   =   "Transform"
      TabPicture(2)   =   "frmOptions.frx":0038
      Tab(2).ControlEnabled=   0   'False
      Tab(2).Control(0)=   "fraTransform"
      Tab(2).ControlCount=   1
      TabCaption(3)   =   "COM"
      TabPicture(3)   =   "frmOptions.frx":0054
      Tab(3).ControlEnabled=   0   'False
      Tab(3).Control(0)=   "fraCOM"
      Tab(3).Control(0).Enabled=   0   'False
      Tab(3).ControlCount=   1
      Begin VB.Frame fraCOM 
         Height          =   2310
         Left            =   -74880
         TabIndex        =   22
         Top             =   450
         Width           =   5595
         Begin VB.TextBox txtINFRTL10 
            Height          =   285
            Left            =   1620
            TabIndex        =   24
            Top             =   690
            Width           =   3885
         End
         Begin VB.Label Label3 
            Alignment       =   1  'Right Justify
            AutoSize        =   -1  'True
            Caption         =   "&INFRTL10 App Id"
            Height          =   195
            Left            =   240
            TabIndex        =   23
            Top             =   750
            Width           =   1260
         End
      End
      Begin VB.Frame fraLogin 
         Height          =   2310
         Left            =   -74850
         TabIndex        =   6
         Top             =   450
         Width           =   5595
         Begin VB.TextBox txtLocation 
            Height          =   285
            Left            =   1935
            TabIndex        =   12
            Top             =   1620
            Width           =   2175
         End
         Begin VB.TextBox txtPassword 
            Height          =   285
            IMEMode         =   3  'DISABLE
            Left            =   1935
            PasswordChar    =   "*"
            TabIndex        =   10
            Top             =   1170
            Width           =   2175
         End
         Begin VB.TextBox txtUserName 
            Height          =   285
            Left            =   1935
            TabIndex        =   8
            Top             =   720
            Width           =   2175
         End
         Begin VB.Label lblLocation 
            Alignment       =   1  'Right Justify
            AutoSize        =   -1  'True
            Caption         =   "&Location"
            Height          =   195
            Left            =   1215
            TabIndex        =   11
            Top             =   1665
            Width           =   615
         End
         Begin VB.Label lblPassword 
            Alignment       =   1  'Right Justify
            AutoSize        =   -1  'True
            Caption         =   "&Password"
            Height          =   195
            Left            =   1140
            TabIndex        =   9
            Top             =   1200
            Width           =   690
         End
         Begin VB.Label lblUserName 
            Alignment       =   1  'Right Justify
            AutoSize        =   -1  'True
            Caption         =   "&User Name"
            Height          =   195
            Left            =   1035
            TabIndex        =   7
            Top             =   765
            Width           =   795
         End
      End
      Begin VB.Frame fraTransform 
         Height          =   2310
         Left            =   -74880
         TabIndex        =   13
         Top             =   510
         Width           =   5595
         Begin VB.CheckBox chkLoggingOn 
            Caption         =   "&Logging On"
            Height          =   285
            Left            =   1650
            TabIndex        =   21
            Top             =   1740
            Width           =   3315
         End
         Begin VB.TextBox txtXformAppId 
            Height          =   285
            Left            =   1620
            TabIndex        =   15
            Top             =   360
            Width           =   3885
         End
         Begin VB.TextBox txtOutputDir 
            Height          =   285
            Left            =   1620
            TabIndex        =   17
            Top             =   840
            Width           =   3885
         End
         Begin VB.TextBox txtExtn 
            Height          =   285
            Left            =   1620
            TabIndex        =   19
            Top             =   1320
            Width           =   1095
         End
         Begin VB.Label lblXformAppId 
            Alignment       =   1  'Right Justify
            AutoSize        =   -1  'True
            Caption         =   "Transform &App Id"
            Height          =   195
            Left            =   165
            TabIndex        =   14
            Top             =   420
            Width           =   1215
         End
         Begin VB.Label Label2 
            Alignment       =   1  'Right Justify
            AutoSize        =   -1  'True
            Caption         =   "Output &Directory"
            Height          =   195
            Left            =   165
            TabIndex        =   16
            Top             =   900
            Width           =   1155
         End
         Begin VB.Label lblExtn 
            Alignment       =   1  'Right Justify
            AutoSize        =   -1  'True
            Caption         =   "File &Extension"
            Height          =   195
            Left            =   330
            TabIndex        =   18
            Top             =   1365
            Width           =   975
         End
         Begin VB.Label Label1 
            Alignment       =   1  'Right Justify
            AutoSize        =   -1  'True
            Caption         =   "e.g. .XML, .TXT"
            Height          =   195
            Left            =   2790
            TabIndex        =   20
            Top             =   1380
            Width           =   1140
         End
      End
      Begin VB.Frame fraMode 
         Height          =   2310
         Left            =   210
         TabIndex        =   1
         Top             =   480
         Width           =   5595
         Begin VB.TextBox txtTimerInt 
            Height          =   285
            Left            =   2025
            TabIndex        =   5
            Top             =   1215
            Visible         =   0   'False
            Width           =   1680
         End
         Begin VB.OptionButton optMode 
            Caption         =   "&Automatic"
            Height          =   285
            Index           =   1
            Left            =   2115
            TabIndex        =   3
            Top             =   315
            Width           =   2805
         End
         Begin VB.OptionButton optMode 
            Caption         =   "&Manual"
            Height          =   285
            Index           =   0
            Left            =   450
            TabIndex        =   2
            Top             =   315
            Value           =   -1  'True
            Width           =   1185
         End
         Begin VB.Label lblTimerInt 
            AutoSize        =   -1  'True
            Caption         =   "Timer Interval (s)"
            Height          =   195
            Left            =   585
            TabIndex        =   4
            Top             =   1260
            Visible         =   0   'False
            Width           =   1170
         End
      End
   End
   Begin MSComDlg.CommonDialog dialogOutputDir 
      Left            =   6840
      Top             =   3420
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.Menu ConfigTop 
      Caption         =   "&Config"
      Begin VB.Menu mnuConfig 
         Caption         =   "&Save"
         Index           =   0
      End
      Begin VB.Menu mnuConfig 
         Caption         =   "-"
         Index           =   1
      End
      Begin VB.Menu mnuConfig 
         Caption         =   "E&xit without saving"
         Index           =   2
      End
   End
End
Attribute VB_Name = "frmOptions"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
DefInt A-Z

Private Const CLASS_NAME = "frmOptions."

Private mobjConfig As EventNotifierV1.Config
Private Sub FormToConfig()

Const SUB_NAME = CLASS_NAME & "FormToConfig"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
   
   With mobjConfig
      
      If optMode(0).Value = True Then .MsgProcessing = Manual
      If optMode(1).Value = True Then .MsgProcessing = Automatic
      
      .ProcessingInterval = Val(txtTimerInt.Text)
      
      .TransformationDllAppID = txtXformAppId.Text
      
      .LoginName = txtUserName.Text
      .LoginPwd = txtPassword.Text
      .LoginLocation = txtLocation.Text
      .OutputDirectory = txtOutputDir.Text
      .OutputFileExtension = txtExtn.Text
      .INFAppId = txtINFRTL10.Text
      
      .LoggingOn = (chkLoggingOn.Value = vbChecked)
      
   End With
   
Cleanup:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub


Private Sub ConfigToForm()

Const SUB_NAME = CLASS_NAME & "ConfigToForm"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
   
   With mobjConfig
      
      If .MsgProcessing = Automatic Then optMode(1).Value = True
      txtTimerInt.Text = Format$(.ProcessingInterval)
            
      txtXformAppId.Text = .TransformationDllAppID
      
      txtUserName.Text = .LoginName
      txtPassword.Text = .LoginPwd
      txtLocation.Text = .LoginLocation
      txtOutputDir.Text = .OutputDirectory
      txtExtn.Text = .OutputFileExtension
      txtINFRTL10.Text = .INFAppId
      
      If .LoggingOn Then
         chkLoggingOn.Value = vbChecked
      Else
         chkLoggingOn.Value = vbUnchecked
      End If
      
   End With
   
Cleanup:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Private Sub SelectText(ctlTxtBox As TextBox)

   On Error Resume Next
   
   ctlTxtBox.SelStart = 0
   ctlTxtBox.SelLength = Len(ctlTxtBox.Text)
   
   On Error GoTo 0
   
End Sub

Public Sub ShowConfig(ByRef objConfig As EventNotifierV1.Config)

Const SUB_NAME = CLASS_NAME & ".ShowConfig"

Dim uError As udtErrorState


   On Error GoTo ErrorHandler
   
   Set mobjConfig = objConfig
   
   ConfigToForm
   
   Me.Show vbModal
      
Cleanup:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

















Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode = vbFormControlMenu Then
         Cancel = True
         Me.Hide
      End If
      
End Sub


Private Sub Form_Unload(Cancel As Integer)

   Set mobjConfig = Nothing
   
End Sub


Private Sub mnuConfig_Click(Index As Integer)

Const SUB_NAME = CLASS_NAME & "mnuConfig_Click"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
   
   If Index = 0 Then
         FormToConfig
         mobjConfig.SaveConfig
      End If
      
Cleanup:

   Me.Hide

   On Error GoTo 0
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   frmEventNotifierV1.AddToStatusList CreateModuleErrorString(SUB_NAME, uError)
   Resume Cleanup
   
End Sub



Private Sub optMode_Click(Index As Integer)

Dim boolMSMQ As Boolean

   boolMSMQ = (Index = 1)
   
   lblTimerInt.Visible = boolMSMQ
   txtTimerInt.Visible = boolMSMQ
   
End Sub






Private Sub txtExtn_GotFocus()

   SelectText txtExtn
   
End Sub


Private Sub txtLocation_GotFocus()

   SelectText txtLocation
   
End Sub


Private Sub txtOutputDir_GotFocus()

   SelectText txtOutputDir
   
End Sub

Private Sub txtPassword_GotFocus()

   SelectText txtPassword
   
End Sub


Private Sub txtTimerInt_GotFocus()

   SelectText txtTimerInt
   
End Sub


Private Sub txtUserName_GotFocus()

   SelectText txtUserName
   
End Sub




Private Sub txtXformAppId_GotFocus()

   SelectText txtXformAppId
   
End Sub


