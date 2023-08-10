VERSION 2.00
Begin Form Progress 
   AutoRedraw      =   -1  'True
   BackColor       =   &H00808080&
   BorderStyle     =   0  'None
   ClientHeight    =   1725
   ClientLeft      =   3990
   ClientTop       =   2205
   ClientWidth     =   4290
   ControlBox      =   0   'False
   FillStyle       =   0  'Solid
   ForeColor       =   &H00000000&
   Height          =   2130
   Left            =   3930
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1725
   ScaleWidth      =   4290
   Top             =   1860
   Width           =   4410
   Begin Frame FrmSortProgress 
      BackColor       =   &H8000000A&
      Height          =   1785
      Left            =   0
      TabIndex        =   1
      Top             =   -75
      Width           =   4275
      Begin Line Line2 
         BorderColor     =   &H00FFFFFF&
         X1              =   60
         X2              =   4200
         Y1              =   1080
         Y2              =   1080
      End
      Begin Line Line1 
         BorderColor     =   &H00808080&
         X1              =   60
         X2              =   4200
         Y1              =   1100
         Y2              =   1100
      End
      Begin Shape shpFrame 
         Height          =   315
         Index           =   1
         Left            =   540
         Top             =   1260
         Width           =   3195
      End
      Begin Label lblInfo 
         AutoSize        =   -1  'True
         BackStyle       =   0  'Transparent
         ForeColor       =   &H00000000&
         Height          =   195
         Left            =   120
         TabIndex        =   0
         Top             =   180
         Width           =   4005
         WordWrap        =   -1  'True
      End
      Begin Label PerCent 
         BackColor       =   &H8000000A&
         BackStyle       =   0  'Transparent
         Enabled         =   0   'False
         Height          =   315
         Left            =   120
         TabIndex        =   3
         Top             =   1260
         Visible         =   0   'False
         Width           =   315
      End
      Begin Shape shpBar 
         BackStyle       =   1  'Opaque
         DrawMode        =   7  'Xor Pen
         Height          =   315
         Index           =   1
         Left            =   540
         Top             =   1260
         Width           =   15
      End
      Begin Label lblResInfo 
         Alignment       =   2  'Center
         BackColor       =   &H8000000A&
         Caption         =   "0%"
         Height          =   195
         Index           =   1
         Left            =   585
         TabIndex        =   2
         Top             =   1305
         Width           =   3075
      End
   End
End
'---------------------------------------------------------------------
'             Progress Bar
'Written by CKJ
' To use, set Progress.lblInfo to the text required
' then do Progress.show 0
' and set Progress.PerCent to a numerical value as often as required
' When complete Unload Progress
'
'04Mar99 CFY Changed to use windows colours
'---------------------------------------------------------------------
Option Explicit
DefInt A-Z

Sub Form_Activate ()

   Me.Refresh

End Sub

Sub Form_Load ()

   HorizCentreForm Me

End Sub

Sub Form_Unload (Cancel As Integer)

    Me.Hide
    ScreenRefresh
            
End Sub

Sub lblInfo_Change ()
'25Jul98 ASC procedure added to make form self sizing if extra lines added

ReDim lines$(25)
Dim Numoflines, extra%
   deflines (Progress.lblInfo.Caption), lines$(), Chr$(13), 0, Numoflines
   If Numoflines > 3 Then
         extra = Progress.lblInfo.Height - 850
         Height = 2130 + extra
         FrmSortProgress.Height = 1785 + extra
         Line1.Y1 = 1080 + extra
         Line1.Y2 = 1080 + extra
         Line2.Y1 = 1100 + extra
         Line2.Y2 = 1100 + extra
         shpframe(1).Top = 1260 + extra
         Percent.Top = 1260 + extra
         LblResInfo(1).Top = 1320 + extra
         ShpBar(1).Top = 1260 + extra
      End If
End Sub

Sub PerCent_Change ()
   
Dim newVal%, i%
Static lastVal%

   On Error Resume Next
   newVal = Val(Percent)
   If newVal < 0 Then newVal = 0
   If newVal <> lastVal Or newVal = 0 Then
         If newVal > 100 Then newVal = 100
         i = 1
         LblResInfo(i).Caption = Format$(newVal) & "%"
         ShpBar(i).Width = shpframe(i).Width * newVal \ 100
         lastVal = newVal
      End If
   On Error GoTo 0

End Sub

