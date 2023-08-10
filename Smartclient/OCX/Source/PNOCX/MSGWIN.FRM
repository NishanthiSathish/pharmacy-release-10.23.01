VERSION 5.00
Begin VB.Form frmMsgWin 
   Appearance      =   0  'Flat
   BackColor       =   &H80000005&
   ClientHeight    =   1200
   ClientLeft      =   1095
   ClientTop       =   1485
   ClientWidth     =   4455
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   Icon            =   "MSGWIN.frx":0000
   LinkTopic       =   "Form1"
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1200
   ScaleWidth      =   4455
   Begin VB.CheckBox ChkBox 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      Caption         =   "ChkBox"
      Enabled         =   0   'False
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   270
      TabIndex        =   4
      Top             =   1275
      Visible         =   0   'False
      Width           =   2430
   End
   Begin VB.PictureBox MhTimer1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   420
      Left            =   3180
      ScaleHeight     =   390
      ScaleWidth      =   390
      TabIndex        =   5
      Top             =   240
      Width           =   420
   End
   Begin VB.CommandButton cmdBtn 
      Appearance      =   0  'Flat
      Caption         =   "&No"
      Default         =   -1  'True
      Height          =   375
      Index           =   2
      Left            =   1800
      TabIndex        =   1
      Top             =   720
      Width           =   855
   End
   Begin VB.CommandButton cmdBtn 
      Appearance      =   0  'Flat
      Caption         =   "&Yes"
      Height          =   375
      Index           =   1
      Left            =   720
      TabIndex        =   0
      Top             =   720
      Width           =   855
   End
   Begin VB.CommandButton cmdBtn 
      Appearance      =   0  'Flat
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   375
      Index           =   0
      Left            =   2880
      TabIndex        =   2
      Top             =   720
      Width           =   855
   End
   Begin VB.Image img1 
      Appearance      =   0  'Flat
      Enabled         =   0   'False
      Height          =   480
      Index           =   4
      Left            =   2520
      Picture         =   "MSGWIN.frx":030A
      Top             =   240
      Visible         =   0   'False
      Width           =   480
   End
   Begin VB.Image img1 
      Appearance      =   0  'Flat
      Enabled         =   0   'False
      Height          =   480
      Index           =   3
      Left            =   1800
      Picture         =   "MSGWIN.frx":0614
      Top             =   240
      Visible         =   0   'False
      Width           =   480
   End
   Begin VB.Image img1 
      Appearance      =   0  'Flat
      Enabled         =   0   'False
      Height          =   480
      Index           =   2
      Left            =   1200
      Picture         =   "MSGWIN.frx":091E
      Top             =   240
      Visible         =   0   'False
      Width           =   480
   End
   Begin VB.Image img1 
      Appearance      =   0  'Flat
      Enabled         =   0   'False
      Height          =   480
      Index           =   1
      Left            =   540
      Picture         =   "MSGWIN.frx":0C28
      Top             =   240
      Visible         =   0   'False
      Width           =   480
   End
   Begin VB.Label lblbox 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   195
      Left            =   240
      TabIndex        =   3
      Top             =   240
      Width           =   75
   End
End
Attribute VB_Name = "frmMsgWin"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'05Feb96 CKJ Written
'            Generic replacement for MsgBox, with language support
'            - latter needs replacing from DOS version
'12Sep96 CKJ Added k.norefresh
'            Set focus to button if its highlighted letter is pressed
'            without the Alt key
'13Sep96 CKJ AutoSizing now accounts for icons
' 5Mar97 CKJ Added timeout
'02Jun00 AE  Added check box for use with new Wrapper AskWinChk
Option Explicit
DefInt A-Z

Dim ticks As Single

Private Sub cmdBtn_Click(Index As Integer)

   TimeoutOn MhTimer1
   If Timer > ticks Then
         Me.Tag = Index
         Me.Hide
         If Not k.norefresh Then ScreenRefresh  '12Sep96 CKJ Added
      End If

End Sub

Private Sub CmdBtn_Keypress(Index As Integer, KeyAscii As Integer)
'12Sep96 CKJ Allow letter without Alt to preset the choice
Dim i%

   TimeoutOn MhTimer1
   For i% = 0 To 2
      If InStr(UCase$(cmdBtn(i).Caption), UCase$("&" & Chr$(KeyAscii))) Then
            KeyAscii = 0
            cmdBtn(i).SetFocus
         End If
   Next

End Sub

Private Sub Form_Activate()
Dim i%

   TimeoutOn MhTimer1
   For i = 0 To 2
      If cmdBtn(i).default = True Then
            On Error Resume Next   '16Nov98   ASC/EAC to stop an illega; function call when activate fires with another modal form displaying. The activate DOES refire when other mnodal form unloads
            cmdBtn(i).SetFocus
            On Error GoTo 0        '  "
            Exit For
         End If
   Next

End Sub

Private Sub Form_Deactivate()

   TimeoutOff MhTimer1

End Sub

Private Sub Form_Load()

   ticks = Timer + 0.2

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then  'all exit methods except Unload from code
         Cancel = True      'prevent unload
         Me.Tag = 0         'cancel button
         Me.Hide
         If Not k.norefresh Then ScreenRefresh  '12Sep96 CKJ Added
      End If

End Sub

Private Sub lblbox_Change()
'Resize form, & move text box, OK & exit buttons
'Default form height = 1605, width 4455
Dim HtOffset As Integer, i As Integer

   TimeoutOn MhTimer1
   Me.Height = lblbox.Height + 1410
   HtOffset = Me.Height - 1605 ' current height less default height
   If HtOffset < 0 Then HtOffset = 0

   For i = 0 To 2
      cmdBtn(i).Top = 720 + HtOffset
   Next
   
   If lblbox.Left + lblbox.Width + 240 > 4455 Then
         Me.Width = lblbox.Left + lblbox.Width + 240
      Else
         Me.Width = 4455
      End If

End Sub

Private Sub MhTimer1_Timer()

   If TimedOut() Then
         Me.Tag = 0         'cancel button
         Me.Hide
      End If

End Sub

