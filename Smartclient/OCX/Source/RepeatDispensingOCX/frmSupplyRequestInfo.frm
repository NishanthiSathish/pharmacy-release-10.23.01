VERSION 5.00
Begin VB.Form frmSupplyRequestInfo 
   Caption         =   "Supply Request Information"
   ClientHeight    =   9225
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   7140
   Icon            =   "frmSupplyRequestInfo.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   9225
   ScaleWidth      =   7140
   StartUpPosition =   3  'Windows Default
   Begin VB.TextBox Text2 
      Height          =   285
      Left            =   1080
      TabIndex        =   13
      Text            =   "Text2"
      Top             =   11160
      Width           =   150
   End
   Begin VB.TextBox Text1 
      Height          =   285
      Left            =   600
      TabIndex        =   11
      Top             =   11040
      Width           =   255
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      Height          =   495
      Left            =   5520
      TabIndex        =   1
      Top             =   8400
      Width           =   1335
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&OK"
      Height          =   495
      Left            =   3840
      TabIndex        =   2
      Top             =   8400
      Width           =   1455
   End
   Begin VB.TextBox txtComplianceStartDate 
      Height          =   405
      Left            =   2280
      MaxLength       =   30
      TabIndex        =   9
      Top             =   6480
      Visible         =   0   'False
      Width           =   2535
   End
   Begin VB.ComboBox cmbComplianceType 
      Height          =   315
      Left            =   2280
      Style           =   2  'Dropdown List
      TabIndex        =   8
      Top             =   5880
      Visible         =   0   'False
      Width           =   2535
   End
   Begin VB.CheckBox chkCompliance 
      Caption         =   "&Compliance Aid"
      Height          =   375
      Left            =   360
      TabIndex        =   7
      Top             =   8400
      Visible         =   0   'False
      Width           =   1815
   End
   Begin VB.ComboBox cmbDeliveryMethod 
      Height          =   315
      Left            =   2280
      Style           =   2  'Dropdown List
      TabIndex        =   6
      Top             =   5160
      Width           =   2535
   End
   Begin VB.TextBox txtAdditionalInfo 
      Height          =   375
      Left            =   2280
      MaxLength       =   30
      TabIndex        =   3
      Top             =   3840
      Width           =   4575
   End
   Begin VB.CheckBox chkUrgent 
      Height          =   495
      Left            =   2280
      TabIndex        =   5
      Top             =   4440
      Width           =   1815
   End
   Begin VB.Frame Frame1 
      Caption         =   "Repeat Batch Information"
      Height          =   2895
      Left            =   120
      TabIndex        =   0
      Top             =   360
      Width           =   6855
      Begin VB.Label lblSlots 
         Height          =   255
         Left            =   1920
         TabIndex        =   22
         Top             =   2400
         Width           =   4815
      End
      Begin VB.Label lblEndDate 
         Height          =   255
         Left            =   1920
         TabIndex        =   21
         Top             =   2040
         Width           =   4815
      End
      Begin VB.Label lblStartdate 
         Height          =   255
         Left            =   1920
         TabIndex        =   20
         Top             =   1680
         Width           =   4815
      End
      Begin VB.Label lblslotsdesc 
         Caption         =   "Slots :"
         Height          =   375
         Left            =   240
         TabIndex        =   19
         Top             =   2400
         Width           =   1455
      End
      Begin VB.Label lblenddatedesc 
         Caption         =   "End date and slot :"
         Height          =   255
         Left            =   240
         TabIndex        =   18
         Top             =   2040
         Width           =   1335
      End
      Begin VB.Label lblstartdatedesc 
         Caption         =   "Start date and slot :"
         Height          =   255
         Left            =   240
         TabIndex        =   17
         Top             =   1680
         Width           =   1575
      End
      Begin VB.Label lblbLocation 
         Height          =   255
         Left            =   1320
         TabIndex        =   16
         Top             =   1200
         Width           =   3135
      End
      Begin VB.Label Label1 
         Caption         =   "Location :"
         Height          =   255
         Left            =   240
         TabIndex        =   15
         Top             =   1200
         Width           =   855
      End
      Begin VB.Label lblDesc 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   495
         Left            =   240
         TabIndex        =   14
         Top             =   480
         Width           =   6375
         WordWrap        =   -1  'True
      End
   End
   Begin VB.Label lblTime 
      BackColor       =   &H80000005&
      BorderStyle     =   1  'Fixed Single
      Height          =   375
      Left            =   4560
      TabIndex        =   29
      Top             =   7560
      Width           =   1095
   End
   Begin VB.Label lblDate 
      BackColor       =   &H80000005&
      BorderStyle     =   1  'Fixed Single
      Height          =   375
      Left            =   2280
      TabIndex        =   28
      Top             =   7560
      Width           =   1575
   End
   Begin VB.Label lblPriority 
      Caption         =   "&Priority"
      Height          =   375
      Left            =   240
      TabIndex        =   4
      Top             =   4560
      Width           =   1575
   End
   Begin VB.Label lblComplianceAidType 
      Caption         =   "Compliance Aid Type"
      Height          =   375
      Left            =   240
      TabIndex        =   27
      Top             =   5955
      Visible         =   0   'False
      Width           =   2175
   End
   Begin VB.Label lblComplianceStartDate 
      Caption         =   "Compliance Aid Start Date"
      Height          =   255
      Left            =   240
      TabIndex        =   26
      Top             =   6600
      Visible         =   0   'False
      Width           =   2175
   End
   Begin VB.Label Label8 
      Caption         =   "Delivery Method"
      Height          =   375
      Left            =   240
      TabIndex        =   25
      Top             =   5160
      Width           =   1695
   End
   Begin VB.Label lbltimeover 
      Caption         =   "&Time"
      Height          =   255
      Left            =   4560
      TabIndex        =   12
      Top             =   7200
      Width           =   615
   End
   Begin VB.Label lbldateover 
      Caption         =   "&Date"
      Height          =   255
      Left            =   2280
      TabIndex        =   10
      Top             =   7200
      Width           =   975
   End
   Begin VB.Label Label5 
      Caption         =   "Additional Information"
      Height          =   375
      Left            =   240
      TabIndex        =   24
      Top             =   3960
      Width           =   1575
   End
   Begin VB.Label lblReq 
      Caption         =   "Required By "
      Height          =   375
      Left            =   360
      TabIndex        =   23
      Top             =   7680
      Width           =   1695
   End
End
Attribute VB_Name = "frmSupplyRequestInfo"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub chkCompliance_Click()
   If chkCompliance.Value = 1 Then
      Me.txtComplianceStartDate.Visible = True
      Me.lblComplianceAidType.Visible = True
      Me.lblComplianceStartDate.Visible = True
      Me.cmbComplianceType.Visible = True
   Else
      Me.txtComplianceStartDate.Visible = False
      Me.lblComplianceAidType.Visible = False
      Me.lblComplianceStartDate.Visible = False
      Me.cmbComplianceType.Visible = False
   End If
End Sub

Private Sub CmdCancel_Click()
   frmSupplyRequestInfo.Tag = "CANCEL"
   Me.Hide
End Sub

Private Sub cmdOK_Click()
   'Validation
   frmSupplyRequestInfo.Tag = "OK"
   Me.Hide
End Sub

Private Sub Form_Load()
   SetChrome Me
   CentreForm Me
   
End Sub

Private Sub lblDate_Click()
Dim strAns As String
Dim strWorkingdate As String
Dim strbatchexpiry As String
Dim valid As Integer

   strAns = lblDate.Caption
   'IssueGrid.SetFocus
   If cmdOK.Enabled Then
      On Error Resume Next
      cmdOK.SetFocus
      On Error GoTo 0
   Else
      On Error Resume Next
      cmdCancel.SetFocus
      On Error GoTo 0
   End If
   Do
      inputwin "Supply request information", "Enter DATE when required", strAns, k
      If k.escd Then k.escd = False: Exit Sub    '24Feb99 SF added
      parsedate strAns, strWorkingdate, "8", valid
      If strWorkingdate <> strAns Then valid = False: strAns = strWorkingdate
      If valid Then
         If CDate(strAns) < CDate(Format$(Now, "dd/mm/yyyy")) Then
            popmessagecr "", "Required date cannot be in the past"
            strAns = lblDate.Caption
            valid = False
         End If
      End If
   Loop Until valid
   lblDate.Caption = strAns
End Sub

Private Sub lbldateover_Click()

   lblDate_Click

End Sub

Private Sub lblTime_Click()
Dim strAns As String
Dim strWorkingTime As String
Dim strbatchexpiry As String
Dim valid As Integer

   strAns = lblTime.Caption
   'IssueGrid.SetFocus
   If cmdOK.Enabled Then
      On Error Resume Next
      cmdOK.SetFocus
      On Error GoTo 0
   Else
      On Error Resume Next
      cmdCancel.SetFocus
      On Error GoTo 0
   End If
   Do
      inputwin "Supply request information", "Enter TIME when required", strAns, k
      If k.escd Then k.escd = False: Exit Sub     '24Feb99 SF added
      parsetime strAns, strWorkingTime, "1", valid
      If strWorkingTime <> strAns Then valid = False: strAns = strWorkingTime
   Loop Until valid
   lblTime.Caption = strAns

End Sub

Private Sub lbltimeover_Click()

   lblTime_Click

End Sub
Private Sub Text1_GotFocus()
   
    lblDate_Click
  
End Sub
Private Sub Text2_GotFocus()
   lblTime_Click
End Sub
