VERSION 5.00
Begin VB.Form frmTestbed 
   Caption         =   "Form1"
   ClientHeight    =   4215
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   6165
   LinkTopic       =   "Form1"
   ScaleHeight     =   4215
   ScaleWidth      =   6165
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox txtSessionID 
      Height          =   315
      Left            =   1920
      TabIndex        =   1
      Text            =   "694"
      Top             =   90
      Width           =   2595
   End
   Begin VB.TextBox txtAuditLogID 
      Height          =   315
      Left            =   1920
      TabIndex        =   3
      Text            =   "106484"
      Top             =   480
      Width           =   2595
   End
   Begin VB.TextBox Text1 
      Height          =   2655
      Left            =   90
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   5
      Top             =   1470
      Width           =   6015
   End
   Begin VB.CommandButton Command1 
      Caption         =   "&process"
      Height          =   405
      Left            =   2340
      TabIndex        =   4
      Top             =   960
      Width           =   1305
   End
   Begin VB.Label Label2 
      AutoSize        =   -1  'True
      Caption         =   "Session ID"
      Height          =   195
      Left            =   840
      TabIndex        =   0
      Top             =   150
      Width           =   765
   End
   Begin VB.Label Label1 
      AutoSize        =   -1  'True
      Caption         =   "Audit Log ID"
      Height          =   195
      Left            =   840
      TabIndex        =   2
      Top             =   540
      Width           =   885
   End
End
Attribute VB_Name = "frmTestbed"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Private Sub Command1_Click()

Dim objEncoder As MaximsHL7AllergyEncoderV1.Encoder
Dim objAuditLog As GENRTL10.AuditLogRead

Dim lngAuditLogID As Long
Dim lngSessionID As Long

Dim strAuditLogXML As String
Dim strBrokenRules As String
Dim strReply As String


   On Error GoTo ErrorHandler
   
   lngAuditLogID = Val(txtAuditLogID.Text)
   lngSessionID = Val(txtSessionID.Text)
   
   If (lngAuditLogID > 0) Then
   
      Set objAuditLog = CreateObject("GENRTL10.AuditLogRead")
      strAuditLogXML = objAuditLog.Item(lngSessionID, lngAuditLogID)
      Set objAuditLog = Nothing
      
      Set objEncoder = New MaximsHL7AllergyEncoderV1.Encoder
      strBrokenRules = objEncoder.Translate(lngSessionID, "TEST", strAuditLogXML, strReply)
      Set objEncoder = Nothing
      
      If Len(strBrokenRules) > 0 Then strReply = strBrokenRules
   Else
      strReply = "Invalid Audit Log ID"
   End If
   
   Text1.Text = strReply
   
cleanup:

   On Error Resume Next
   Set objEncoder = Nothing
   Set objAuditLog = Nothing
   
   On Error GoTo 0
   
Exit Sub

ErrorHandler:

   MsgBox "Error : " & Err.Description & vbCrLf, vbCritical
   Resume cleanup
   
End Sub


