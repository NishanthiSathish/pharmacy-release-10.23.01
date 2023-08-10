VERSION 5.00
Begin VB.Form frmShowMsg 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Dialog Caption"
   ClientHeight    =   7935
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   10710
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   7935
   ScaleWidth      =   10710
   ShowInTaskbar   =   0   'False
   Begin VB.CommandButton OKButton 
      Cancel          =   -1  'True
      Caption         =   "E&xit"
      Default         =   -1  'True
      Height          =   375
      Left            =   9210
      TabIndex        =   1
      Top             =   7350
      Width           =   1215
   End
   Begin VB.TextBox txtErrMsg 
      Height          =   7005
      Left            =   60
      Locked          =   -1  'True
      MultiLine       =   -1  'True
      ScrollBars      =   3  'Both
      TabIndex        =   0
      Top             =   90
      Width           =   10575
   End
End
Attribute VB_Name = "frmShowMsg"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
DefInt A-Z



Public Sub ShowMsg(ByVal sMsg As String)

   txtErrMsg.Text = sMsg
   Me.Show vbModeless
   
End Sub


Private Sub OKButton_Click()

   Unload Me
   
End Sub


