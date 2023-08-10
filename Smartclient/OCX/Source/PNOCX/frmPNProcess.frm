VERSION 5.00
Begin VB.Form frmPNProcess 
   Caption         =   "Parenteral Nutrition"
   ClientHeight    =   5640
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   9495
   Icon            =   "frmPNProcess.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   5640
   ScaleWidth      =   9495
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame fraWarnings 
      Caption         =   "Warnings"
      Height          =   2295
      Left            =   240
      TabIndex        =   3
      Top             =   1800
      Visible         =   0   'False
      Width           =   9015
      Begin VB.TextBox txtWarnings 
         Height          =   1695
         Left            =   240
         Locked          =   -1  'True
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   4
         Top             =   360
         Width           =   8535
      End
   End
   Begin VB.CommandButton cmdCancel 
      Caption         =   "&Cancel"
      Height          =   615
      Left            =   360
      TabIndex        =   2
      Top             =   4440
      Visible         =   0   'False
      Width           =   1935
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   615
      Left            =   3840
      TabIndex        =   1
      Top             =   4680
      Visible         =   0   'False
      Width           =   1935
   End
   Begin VB.Label lblRpt 
      Alignment       =   2  'Center
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3735
      Left            =   240
      TabIndex        =   0
      Top             =   720
      Width           =   8895
   End
End
Attribute VB_Name = "frmPNProcess"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim blnActivated As Boolean



Private Sub CmdCancel_Click()
    SetCancelRequested True
End Sub

Private Sub cmdOK_Click()
   Unload Me
End Sub

Private Sub Form_Activate()
   
   MinimizeAllApplication   'AS - MM-10837 10.22 - another application in focus when printing in pharmacy
   If Not blnActivated Then
      blnActivated = True
      Me.lblRpt.Caption = "Processing ..."
      ProcessPN Me
      Me.lblRpt.Caption = strPNOutputMessage
      cmdOK.Visible = True
   End If
   
End Sub

Private Sub Form_Initialize()
 '   ProcessRepeatBatch Me
End Sub

Private Sub Form_Load()
   SetChrome Me
   CentreForm Me
   

  
   
   'Unload Me

End Sub
