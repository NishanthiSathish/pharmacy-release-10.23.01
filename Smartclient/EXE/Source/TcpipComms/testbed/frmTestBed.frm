VERSION 5.00
Begin VB.Form frmTestBed 
   Caption         =   "Testbed"
   ClientHeight    =   10200
   ClientLeft      =   60
   ClientTop       =   450
   ClientWidth     =   8955
   LinkTopic       =   "Form1"
   ScaleHeight     =   10200
   ScaleWidth      =   8955
   StartUpPosition =   3  'Windows Default
   Begin VB.Frame Frame3 
      Caption         =   "Connection Panel"
      Height          =   1815
      Left            =   60
      TabIndex        =   5
      Top             =   30
      Width           =   8805
      Begin VB.CommandButton cmdDisconnect 
         Caption         =   "&Disconnect"
         Height          =   435
         Left            =   4560
         TabIndex        =   11
         Top             =   1080
         Width           =   1125
      End
      Begin VB.CommandButton cmdConnect 
         Caption         =   "&Connect"
         Height          =   435
         Left            =   2970
         TabIndex        =   10
         Top             =   1080
         Width           =   1125
      End
      Begin VB.TextBox txtPort 
         Height          =   315
         Left            =   2760
         TabIndex        =   8
         Top             =   600
         Width           =   5265
      End
      Begin VB.TextBox txtHost 
         Height          =   315
         Left            =   2760
         TabIndex        =   6
         Top             =   210
         Width           =   5265
      End
      Begin VB.Label lblPort 
         AutoSize        =   -1  'True
         Caption         =   "Host IP Address or Name"
         Height          =   195
         Left            =   840
         TabIndex        =   9
         Top             =   660
         Width           =   1785
      End
      Begin VB.Label lblhost 
         AutoSize        =   -1  'True
         Caption         =   "Host IP Address or Name"
         Height          =   195
         Left            =   840
         TabIndex        =   7
         Top             =   270
         Width           =   1785
      End
   End
   Begin VB.Frame Frame2 
      Caption         =   "To Send"
      Height          =   3825
      Left            =   60
      TabIndex        =   3
      Top             =   6330
      Width           =   8805
      Begin VB.TextBox txtReceived 
         Height          =   3375
         Left            =   150
         MultiLine       =   -1  'True
         ScrollBars      =   3  'Both
         TabIndex        =   4
         Top             =   300
         Width           =   8505
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "To Send"
      Height          =   4425
      Left            =   60
      TabIndex        =   0
      Top             =   1860
      Width           =   8805
      Begin VB.CommandButton cmdSend 
         Caption         =   "&Send"
         Height          =   435
         Left            =   3690
         TabIndex        =   2
         Top             =   3840
         Width           =   1125
      End
      Begin VB.TextBox txtSend 
         Height          =   3375
         Left            =   150
         MultiLine       =   -1  'True
         TabIndex        =   1
         Top             =   300
         Width           =   8505
      End
   End
End
Attribute VB_Name = "frmTestBed"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
DefInt A-Z


Private WithEvents mobjClient As ascribeTcpipComms.IpClient
Attribute mobjClient.VB_VarHelpID = -1

Private Sub cmdConnect_Click()

   With mobjClient
      .RemoteHost = txtHost.Text
      .RemotePort = Val(txtPort.Text)
      
      .Connected = True
   End With
   
End Sub


Private Sub cmdDisconnect_Click()

   With mobjClient
      If .Connected Then .Connected = False
   End With
   
End Sub


Private Sub cmdSend_Click()

   mobjClient.DataToSend = txtSend.Text
   
End Sub

Private Sub Form_Load()

   Set mobjClient = CreateObject("ascribeTcpipComms.IpClient")
   
End Sub


Private Sub Form_Unload(Cancel As Integer)

   Set mobjClient = Nothing
   
End Sub


Private Sub mobjClient_Connected(ByVal Status As Integer, ByVal Description As String)

Dim msg As String

   With mobjClient
      If (Status = 0) Then
         msg = "Connected to " & .RemoteHost & " port " & Format$(.RemotePort) & vbCrLf
      Else
         msg = "Failed to connect to " & .RemoteHost & " port " & Format$(.RemotePort) & vbCrLf & _
               "Status = " & Format$(Status) & vbCrLf & _
               "Description = " & Description & vbCrLf
      End If
   End With
   
   MsgBox msg, vbInformation
   
End Sub


Private Sub mobjClient_DataIn(ByVal Data As String, ByVal EOL As Boolean)

   txtReceived = txtReceived & Data & vbCrLf & "EOL = " & IIf(EOL, "True", "False") & vbCrLf
   
End Sub


Private Sub mobjClient_Disconnected(ByVal Status As Integer, ByVal Description As String)

   With mobjClient
      MsgBox "Disconnected from " & .RemoteHost & " port " & Format$(.RemotePort), vbInformation
   End With
   
End Sub


Private Sub mobjClient_Error(ByVal ErrorCode As Integer, ByVal Description As String)

   MsgBox "Error Number: " & Format$(ErrorCode) & vbCrLf & "Description: " & Description, vbCritical
   
End Sub


Private Sub mobjClient_ReadyToSend()

   MsgBox "ReadyToSend fired", vbInformation
   
End Sub


