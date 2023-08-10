VERSION 5.00
Begin VB.Form SelDir 
   Appearance      =   0  'Flat
   BackColor       =   &H80000005&
   Caption         =   "Select Directory"
   ClientHeight    =   5025
   ClientLeft      =   2220
   ClientTop       =   1740
   ClientWidth     =   3570
   ClipControls    =   0   'False
   ControlBox      =   0   'False
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
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   5025
   ScaleWidth      =   3570
   Begin VB.Frame Frame1 
      Appearance      =   0  'Flat
      BackColor       =   &H80000005&
      ForeColor       =   &H80000008&
      Height          =   4875
      Left            =   60
      TabIndex        =   7
      Top             =   60
      Width           =   3435
      Begin VB.TextBox Text1 
         Appearance      =   0  'Flat
         Height          =   375
         Left            =   180
         TabIndex        =   1
         Top             =   480
         Width           =   3075
      End
      Begin VB.CommandButton Command1 
         Appearance      =   0  'Flat
         Cancel          =   -1  'True
         Caption         =   "&Cancel"
         Height          =   495
         Index           =   1
         Left            =   2040
         TabIndex        =   6
         Top             =   4140
         Width           =   975
      End
      Begin VB.CommandButton Command1 
         Appearance      =   0  'Flat
         Caption         =   "E&xit"
         Height          =   495
         Index           =   0
         Left            =   600
         TabIndex        =   5
         Top             =   4140
         Width           =   975
      End
      Begin VB.DriveListBox Drive1 
         Appearance      =   0  'Flat
         Height          =   315
         Left            =   180
         TabIndex        =   4
         Top             =   3540
         Width           =   3075
      End
      Begin VB.DirListBox Dir1 
         Appearance      =   0  'Flat
         Height          =   2280
         Left            =   180
         TabIndex        =   2
         Top             =   960
         Width           =   3075
      End
      Begin VB.Label Label2 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         Caption         =   "Dri&ve"
         ForeColor       =   &H80000008&
         Height          =   255
         Left            =   180
         TabIndex        =   3
         Top             =   3300
         Width           =   1455
      End
      Begin VB.Label Label1 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "&Directory"
         ForeColor       =   &H80000008&
         Height          =   195
         Left            =   180
         TabIndex        =   0
         Top             =   240
         Width           =   780
      End
   End
End
Attribute VB_Name = "SelDir"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
DefInt A-Z

'07Nov97 EAC make sure that the path is shown when form is first activated

Private Sub Command1_Click(index As Integer)

Dim direntries$, ans$
                    

   Select Case index
      Case 0
         direntries$ = Dir$(Text1.Text, 16)
         If Trim$(direntries$) <> "" Then
               SelDir.Tag = Text1.Text
            Else
               ans$ = ""
               askwin "Select Directory", "Path Not Found" & Chr$(13) & Chr$(13) & "Do you wish to create this directory?", ans$, k
               If ans$ = "Y" And k.escd = False Then
                     MkDir Text1.Text
                  Else
                     SelDir.Tag = ""
                  End If

            End If
      Case Else
         SelDir.Tag = ""
   End Select

   Me.Hide

End Sub

Private Sub Dir1_Change()

Dim posn
Dim Drive$


   posn = InStr(Dir1.Path, ":")
   If posn > 1 Then
         Drive$ = Mid$(Dir1.Path, posn - 1, 2)
         Drive1.Drive = Drive$
      End If
   Text1.Text = Dir1.Path

End Sub

Private Sub Dir1_KeyPress(Keyascii As Integer)

   Select Case Keyascii
      Case 13, 32
         Dir1.Path = Dir1.List(Dir1.ListIndex)
      Case Else
   End Select

End Sub

Private Sub Dir1_MouseUp(Button As Integer, Shift As Integer, x As Single, Y As Single)

   
   Dir1.Path = Dir1.List(Dir1.ListIndex)


End Sub

Private Sub Drive1_Change()

   On Error Resume Next
   Dir1.Path = Drive1.Drive
   On Error GoTo 0

End Sub

Private Sub Form_Activate()
'07Nov97 EAC make sure that the path is shown when form is first activated
'03Mar16 TH Cheap fix for drive that cannot be found (as per path check below) TFS 146490
'           As with unavailable path, this should then default to current drive and path.
'           THis will resolve issues with EDI and Hub

Dim Drive$
Dim posn%

   If Trim$(SelDir.Tag) <> "" Then
         posn = InStr(SelDir.Tag, ":")
         If posn > 1 Then
               Drive$ = Mid$(SelDir.Tag, posn - 1, 2)
               On Error Resume Next  '03Mar16 TH Cheap fix for drive that cannot be found (as per path check below) TFS 146490
               Drive1.Drive = Drive$
               On Error GoTo 0
            End If
         On Error Resume Next
         Dir1.Path = SelDir.Tag
         On Error GoTo 0
      Else
         Dir1.Path = CurDir$
      End If

   Text1.Text = Dir1.Path  '07Nov97 EAC make sure that the path is shown when form is first activated

End Sub

Private Sub Text1_KeyPress(Keyascii As Integer)


   Select Case Keyascii
      Case 13
         Command1_Click 0
      Case Else
   End Select

End Sub

