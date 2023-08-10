VERSION 2.00
Begin Form SelDir 
   Caption         =   "Select Directory"
   ClientHeight    =   5025
   ClientLeft      =   2220
   ClientTop       =   1740
   ClientWidth     =   3570
   ClipControls    =   0   'False
   ControlBox      =   0   'False
   Height          =   5430
   Left            =   2160
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   5025
   ScaleWidth      =   3570
   Top             =   1395
   Width           =   3690
   Begin Frame Frame1 
      Height          =   4875
      Left            =   60
      TabIndex        =   7
      Top             =   60
      Width           =   3435
      Begin TextBox Text1 
         Height          =   375
         Left            =   180
         TabIndex        =   1
         Top             =   480
         Width           =   3075
      End
      Begin CommandButton Command1 
         Cancel          =   -1  'True
         Caption         =   "&Cancel"
         Height          =   495
         Index           =   1
         Left            =   2040
         TabIndex        =   6
         Top             =   4140
         Width           =   975
      End
      Begin CommandButton Command1 
         Caption         =   "E&xit"
         Height          =   495
         Index           =   0
         Left            =   600
         TabIndex        =   5
         Top             =   4140
         Width           =   975
      End
      Begin DriveListBox Drive1 
         Height          =   315
         Left            =   180
         TabIndex        =   4
         Top             =   3540
         Width           =   3075
      End
      Begin DirListBox Dir1 
         Height          =   2280
         Left            =   180
         TabIndex        =   2
         Top             =   960
         Width           =   3075
      End
      Begin Label Label2 
         Caption         =   "Dri&ve"
         Height          =   255
         Left            =   180
         TabIndex        =   3
         Top             =   3300
         Width           =   1455
      End
      Begin Label Label1 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         Caption         =   "&Directory"
         Height          =   195
         Left            =   180
         TabIndex        =   0
         Top             =   240
         Width           =   780
      End
   End
End
Option Explicit
DefInt A-Z

'07Nov97 EAC make sure that the path is shown when form is first activated

Sub Command1_Click (index As Integer)

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

Sub Dir1_Change ()

Dim posn
Dim Drive$


   posn = InStr(Dir1.Path, ":")
   If posn > 1 Then
         Drive$ = Mid$(Dir1.Path, posn - 1, 2)
         Drive1.Drive = Drive$
      End If
   Text1.Text = Dir1.Path

End Sub

Sub Dir1_KeyPress (KeyAscii As Integer)

   Select Case KeyAscii
      Case 13, 32
         Dir1.Path = Dir1.List(Dir1.ListIndex)
      Case Else
   End Select

End Sub

Sub Dir1_MouseUp (Button As Integer, Shift As Integer, X As Single, Y As Single)

   
   Dir1.Path = Dir1.List(Dir1.ListIndex)


End Sub

Sub Drive1_Change ()

   On Error Resume Next
   Dir1.Path = Drive1.Drive
   On Error GoTo 0

End Sub

Sub Form_Activate ()
'07Nov97 EAC make sure that the path is shown when form is first activated

Dim Drive$
Dim posn%

   If Trim$(SelDir.Tag) <> "" Then
         posn = InStr(SelDir.Tag, ":")
         If posn > 1 Then
               Drive$ = Mid$(SelDir.Tag, posn - 1, 2)
               Drive1.Drive = Drive$
            End If
         On Error Resume Next
         Dir1.Path = SelDir.Tag
         On Error GoTo 0
      Else
         Dir1.Path = CurDir$
      End If

   Text1.Text = Dir1.Path  '07Nov97 EAC make sure that the path is shown when form is first activated

End Sub

Sub Text1_KeyPress (KeyAscii As Integer)


   Select Case KeyAscii
      Case 13
         Command1_Click 0
      Case Else
   End Select

End Sub

