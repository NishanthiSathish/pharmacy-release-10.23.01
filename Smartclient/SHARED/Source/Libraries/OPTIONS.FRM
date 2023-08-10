VERSION 5.00
Begin VB.Form frmOption 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   ClientHeight    =   2400
   ClientLeft      =   3270
   ClientTop       =   1710
   ClientWidth     =   3270
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
   Icon            =   "OPTIONS.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   2400
   ScaleWidth      =   3270
   Begin VB.Timer MhTimer1 
      Enabled         =   0   'False
      Left            =   0
      Top             =   1920
   End
   Begin VB.Frame Frame3D1 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      ForeColor       =   &H00000000&
      Height          =   1875
      Left            =   45
      TabIndex        =   2
      Top             =   -60
      Width           =   3180
      Begin VB.OptionButton Option1 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
         Caption         =   "Option1"
         Enabled         =   0   'False
         ForeColor       =   &H80000008&
         Height          =   255
         Index           =   0
         Left            =   180
         TabIndex        =   4
         Top             =   240
         Visible         =   0   'False
         Width           =   2655
      End
      Begin VB.CheckBox chk3D1 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
         Enabled         =   0   'False
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
         Height          =   255
         Index           =   0
         Left            =   240
         TabIndex        =   3
         Top             =   240
         Visible         =   0   'False
         Width           =   2655
      End
   End
   Begin VB.CommandButton cmdCancel 
      Appearance      =   0  'Flat
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   1800
      Style           =   1  'Graphical
      TabIndex        =   1
      Top             =   1935
      Width           =   975
   End
   Begin VB.CommandButton cmdOK 
      Appearance      =   0  'Flat
      Caption         =   "&OK"
      Default         =   -1  'True
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   540
      Style           =   1  'Graphical
      TabIndex        =   0
      Top             =   1935
      Width           =   975
   End
   Begin VB.Label lblPrompt 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H80000005&
      BackStyle       =   0  'Transparent
      Caption         =   "        "
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
      Left            =   120
      TabIndex        =   5
      Top             =   120
      Width           =   360
   End
   Begin VB.Menu mnuOpt 
      Caption         =   "&File"
      Begin VB.Menu mnuSet 
         Caption         =   "&Select All"
         Enabled         =   0   'False
         Index           =   1
      End
      Begin VB.Menu mnuSet 
         Caption         =   "&Clear All"
         Index           =   2
      End
      Begin VB.Menu mnuSep 
         Caption         =   "-"
      End
      Begin VB.Menu mnuExit 
         Caption         =   "E&xit"
      End
   End
   Begin VB.Menu mnuHelpHdr 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelp 
         Caption         =   "&Contents                             F1"
         Index           =   0
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "&Search for Help on..."
         Index           =   1
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "&How to use Help"
         Index           =   2
      End
      Begin VB.Menu mnuSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuAbout 
         Caption         =   "&About"
      End
   End
End
Attribute VB_Name = "frmOption"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-------------------------------------------------------------------------------------
'                      OPTIONS form
'
'14Aug96 CKJ Written.
'            Provides a self sizing form with up to 20 or so check boxes.
'            Limit is determined basically by screen size.
'            Do not use this form directly, use procs in GUIbits;
'               frmOptionSet        to clear & fill the form
'               frmOptionShow       to show & return results
'
' 2Oct96 CKJ Added Radio Buttons
'            For usage see above procs in GUIbits
'15Jul98 CKJ Added menu, allows set/clear all check boxes, plus help etc
'            Item with focus is bold, others non bold
'            Now works for up to 129 controls
'04Jun04 CKJ 32bit
'-------------------------------------------------------------------------------------

Option Explicit
DefInt A-Z

Private Sub chk3D1_GotFocus(index As Integer)

   chk3D1(index).FontBold = True

End Sub

Private Sub chk3D1_LostFocus(index As Integer)

   chk3D1(index).FontBold = False

End Sub

Private Sub cmdCancel_Click()
Dim i As Integer

   On Error Resume Next
   For i = 1 To Val(cmdOK.Tag)
      chk3D1(i).Value = False
      Option1(i).Value = False
   Next
   On Error GoTo 0
   Hide

End Sub

Private Sub cmdOK_Click()

   Me.Tag = "1"
   Hide

End Sub

Private Sub Form_Activate()
Dim i%

   On Error Resume Next
   chk3D1(1).SetFocus
   For i = 1 To Val(cmdOK.Tag)
      If Option1(i).Value Then
            Option1(i).SetFocus
            Exit For
         End If
   Next
   On Error GoTo 0
   TimeoutOn MHTimer1

End Sub

Private Sub Form_Deactivate()
   
   TimeoutOff MHTimer1

End Sub

Private Sub Form_Load()

   SetChrome Me
   
End Sub

Private Sub Form_MouseMove(button As Integer, Shift As Integer, X As Single, Y As Single)

   TimeoutOn MHTimer1

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then      ' not via prog
         Cancel = True
         cmdCancel_Click
      End If

End Sub

Private Sub Frame3D1_MouseMove(button As Integer, Shift As Integer, X As Single, Y As Single)

   TimeoutOn MHTimer1

End Sub

Private Sub MhTimer1_Timer()

   If TimedOut() Then cmdCancel_Click

End Sub

Private Sub mnuAbout_Click()

   ShowAboutBox "EMIS Health"

End Sub

Private Sub mnuExit_Click()

   cmdCancel_Click

End Sub

Private Sub mnuHelp_Click(index As Integer)

   Select Case index
      Case 0: Help Me.hwnd, 0
      Case 1: HelpSearch Me.hwnd
      Case 2: HelpGet Me.hwnd, HELP_HELPONHELP, 0
      End Select

End Sub

Private Sub mnuSet_Click(index As Integer)

Dim i%

   On Error Resume Next
   For i = 1 To Val(cmdOK.Tag)
      chk3D1(i).Value = (index = 1)                'clear or set check box
      If index = 2 Then Option1(i).Value = False   'clear radio button
   Next
   On Error GoTo 0

End Sub

Private Sub Option1_GotFocus(index As Integer)

   Option1(index).FontBold = True
   Option1(index).ZOrder

End Sub

Private Sub Option1_LostFocus(index As Integer)

   Option1(index).FontBold = False

End Sub

