VERSION 5.00
Object = "{09956DCC-7A5B-42C5-9EFA-E90EE0123664}#1.0#0"; "DispensingCtl.ocx"
Begin VB.Form Testbed 
   BackColor       =   &H00B48246&
   Caption         =   "V93 Dispensing Testbed"
   ClientHeight    =   9870
   ClientLeft      =   60
   ClientTop       =   360
   ClientWidth     =   11850
   LinkTopic       =   "Form1"
   ScaleHeight     =   9870
   ScaleWidth      =   11850
   StartUpPosition =   3  'Windows Default
   Begin DispensingCtl.Dispense Dispense1 
      Height          =   3975
      Left            =   600
      TabIndex        =   18
      Top             =   1320
      Width           =   9615
      _ExtentX        =   16960
      _ExtentY        =   7011
   End
   Begin VB.CommandButton Command 
      Caption         =   "Send Data"
      Height          =   495
      Left            =   6240
      TabIndex        =   17
      Top             =   6960
      Width           =   1215
   End
   Begin VB.CommandButton Command1 
      BackColor       =   &H00FFE3D6&
      Caption         =   "Print Label"
      Height          =   375
      Left            =   3120
      Style           =   1  'Graphical
      TabIndex        =   2
      Top             =   8280
      Width           =   1695
   End
   Begin VB.CommandButton cmdStartup 
      BackColor       =   &H00FFE3D6&
      Caption         =   "&Connect"
      Height          =   375
      Left            =   600
      Style           =   1  'Graphical
      TabIndex        =   1
      Top             =   7560
      Width           =   1575
   End
   Begin VB.CommandButton cmdDoIt 
      BackColor       =   &H00FFE3D6&
      Caption         =   "&Refresh"
      Enabled         =   0   'False
      Height          =   375
      Left            =   3120
      Style           =   1  'Graphical
      TabIndex        =   0
      Top             =   7560
      Width           =   1695
   End
   Begin VB.TextBox txtDispensingID 
      Appearance      =   0  'Flat
      BorderStyle     =   0  'None
      Height          =   285
      Left            =   2640
      TabIndex        =   15
      Top             =   6600
      Width           =   1000
   End
   Begin VB.TextBox txtPrescriptionID 
      Appearance      =   0  'Flat
      BorderStyle     =   0  'None
      Height          =   285
      Left            =   2640
      TabIndex        =   13
      Top             =   6360
      Width           =   1000
   End
   Begin VB.TextBox txtSessionID 
      Appearance      =   0  'Flat
      BorderStyle     =   0  'None
      Height          =   285
      Left            =   2640
      TabIndex        =   11
      Top             =   6120
      Width           =   1000
   End
   Begin VB.TextBox txtSiteNumber 
      Appearance      =   0  'Flat
      BorderStyle     =   0  'None
      Height          =   285
      Left            =   2640
      TabIndex        =   9
      Top             =   5880
      Width           =   1000
   End
   Begin VB.Label lblDispensingID 
      BackColor       =   &H00FFE3D6&
      Caption         =   "  RequestID_Dispensing"
      Height          =   255
      Left            =   600
      TabIndex        =   14
      Top             =   6630
      Width           =   1935
   End
   Begin VB.Label lblPrescriptionID 
      BackColor       =   &H00FFE3D6&
      Caption         =   "  RequestID_Prescription"
      Height          =   255
      Left            =   600
      TabIndex        =   12
      Top             =   6375
      Width           =   1935
   End
   Begin VB.Label lblSessionID 
      BackColor       =   &H00FFE3D6&
      Caption         =   "  SessionID"
      Height          =   255
      Left            =   600
      TabIndex        =   10
      Top             =   6120
      Width           =   1935
   End
   Begin VB.Label lblStatus 
      BackStyle       =   0  'Transparent
      Height          =   255
      Left            =   5760
      TabIndex        =   7
      Top             =   7560
      Width           =   3375
   End
   Begin VB.Label Label1 
      Height          =   255
      Index           =   3
      Left            =   10200
      TabIndex        =   6
      Top             =   5280
      Width           =   255
   End
   Begin VB.Label Label1 
      Height          =   255
      Index           =   2
      Left            =   360
      TabIndex        =   5
      Top             =   5280
      Width           =   255
   End
   Begin VB.Label Label1 
      Height          =   255
      Index           =   1
      Left            =   360
      TabIndex        =   4
      Top             =   1080
      Width           =   255
   End
   Begin VB.Label Label1 
      Height          =   255
      Index           =   0
      Left            =   10200
      TabIndex        =   3
      Top             =   1080
      Width           =   255
   End
   Begin VB.Label lblSiteNumber 
      BackColor       =   &H00FFE3D6&
      Caption         =   "  Ascribe Site Number"
      Height          =   255
      Left            =   600
      TabIndex        =   8
      Top             =   5880
      Width           =   1935
   End
   Begin VB.Label lblFiller 
      BackColor       =   &H80000005&
      Height          =   1005
      Left            =   2520
      TabIndex        =   16
      Top             =   5880
      Width           =   255
   End
End
Attribute VB_Name = "Testbed"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Dim mAscribeSiteNumber As Long
Dim mSession As Integer '= 171 ' 2061
Dim mPrescriptionID As Long

'LocationID_Site 884
'SessionID 744
'RequestID_Prescription 478
'RequestID_Dispensing 498
'EpisodeID 11
'WPatientID 695

'RequestID_Prescription 14177
'RequestID_Dispensing 14179
'EpisodeID 11
'WPatientID 695

Private Sub cmdDoIt_Click()


Dim dummy As Boolean

End Sub

Private Sub cmdStartup_Click()
   
Dim success As Integer
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "Web page stand-in"

   On Error GoTo Errorhandler
   'success = Dispense1.SetConnection(Val(txtSessionID), Val(txtSiteNumber))
   
      
   'dummy = Dispense1.RefreshState(mSession, 302602, 0)
'   dummy = Dispense1.RefreshState(mSession, 0, 0)

'dummy = Dispense1.RefreshState(mSession, 302700, 0)

   'dummy = Dispense1.RefreshState(mSession, 482, 0)   '191  463  196)
'   dummy = Dispense1.RefreshState(mSession, 12618, 0)
'   dummy = Dispense1.RefreshState(mSession, 14177, 0)
'   dummy = Dispense1.RefreshState(mSession, 14455, 0)
'14688
'   dummy = Dispense1.RefreshState(mSession, 14724, 0)   '1g chloramphenical iv qds
   
   'dummy = Dispense1.RefreshState(mSession, 14729, 0)    '750mg chloramphenical im qds
 '  dummy = Dispense1.RefreshState(mSession, 14751, 0)    '250g  bd diclofenac tabs "dose too large" when labelinissueunits=0
 '  dummy = Dispense1.RefreshState(mSession, 14755, 0)    'rounding problem
   
    'dummy = Dispense1.RefreshState(mSession, 15089, 0)    'gtn patch 10 mg daily
 '   dummy = Dispense1.RefreshState(mSession, 15093, 0)    'chloramphenicol 1500mg qds intermittent IV infusion 2 days over 60-90 mins
 '   dummy = Dispense1.RefreshState(mSession, 15186, 0)    'beclomethasone inhaler 100 microgram
'-------------------
 '   dummy = Dispense1.RefreshState(mSession, 15278, 0)    'dornase neb/neb don't match mg
 '   dummy = Dispense1.RefreshState(mSession, 15294, 0)    '
 '    dummy = Dispense1.RefreshState(mSession, 15357, 0)    'acetazolamide
'ok     dummy = Dispense1.RefreshState(mSession, 15461, 0)


  '   dummy = Dispense1.RefreshState(mSession, 17446, 0)     'start time not valid
  '   dummy = Dispense1.RefreshState(mSession, 15948, 0)     '
 '     dummy = Dispense1.RefreshState(mSession, 17547, 0)    'intermittent infusion
 '     dummy = Dispense1.RefreshState(mSession, 17584, 0)    'continuous infusion
     
 '   dummy = Dispense1.RefreshState(mSession, 17521, 0)      'ointment
 '   dummy = Dispense1.RefreshState(mSession, 17529, 0)      'pulmicort
 '    dummy = Dispense1.RefreshState(mSession, 17531, 0)     'flu vaccine
 '    dummy = Dispense1.RefreshState(mSession, 17533, 0)     'NaCl 3% neb
 '    dummy = Dispense1.RefreshState(mSession, 17568, 0)     '
 '     dummy = Dispense1.RefreshState(mSession, 17549, 0)     'dopamine
 '     dummy = Dispense1.RefreshState(mSession, 17576, 0)     '

 '    dummy = Dispense1.RefreshState(mSession, 15366, 0)     'was 30s to get drug
 '   dummy = Dispense1.RefreshState(mSession, 17543, 0)     'div by zero on issue
 '    dummy = Dispense1.RefreshState(mSession, 17685, 0)     'stat dose tablet
 '    dummy = Dispense1.RefreshState(mSession, 17760, 0)     'should be on WSL

'============================ tameside testing
  ' dummy = Dispense1.RefreshState(mSession, 29, 0)

   'success = Dispense1.RefreshState(Val(4389), Val(503), Val(0), Val(0), "http://asc-akent/TL/integration/Pharmacy/GetEncryptedString.aspx?token=1434722737|88c564c03eb7da0be8e0c4a7f000489f&SessionId=4389")
   'Put back (finally) test bed as it should be - DOTN CHECK IN LOCAL STUFF HERE PLS - Selfish,selfish. Also added dummy param for label edit
   success = Dispense1.RefreshState(Val(txtSessionID.Text), Val(txtSiteNumber.Text), Val(txtPrescriptionID.Text), Val(txtDispensingID.Text), "", "", "")
      
   If Not success Then
      MsgBox "Not successful"
   End If
   
Cleanup:
   On Error Resume Next
   'Set  = Nothing
   On Error GoTo 0
   If ErrNumber Then
      'Err.Raise ErrNumber, ErrSource, ErrDescription
      MsgBox ErrDescription, vbCritical + vbOKOnly, ErrSource
   End If
Exit Sub

Errorhandler:
   ErrNumber = Err.Number
'   ErrSource = Err.Source
   ErrDescription = Err.Description
Resume Cleanup

End Sub

Private Sub Command_Click()
Dim objPharmacyData As PharmacyWebData.Transport

   Set objPharmacyData = New PharmacyWebData.Transport
End Sub

Private Sub Command1_Click()
    Dispense1.PrintLabel Val(30023), Val(3), 110435, True, True
End Sub

Private Sub Dispense1_RefreshView(ByVal PrescriptionID As Long, ByVal Status As Long)

'   MsgBox Status
   lblStatus.Caption = " Status: " & Format$(PrescriptionID) & Format$(Status)
   
End Sub

Private Sub Form_DblClick()

   Me.Tag = Not Val(Me.Tag)
   BackColor = IIf(Me.Tag, &HFFE3D6, &HB48246)
  
Exit Sub

Debug.Print Printers.Count

   Dim X As Printer
For Each X In Printers
   Debug.Print X.DriverName, X.Port, X.Orientation, X.TrackDefault, X.Zoom, X.DeviceName
'      ' Set printer as system default.
'      Set Printer = X
'      ' Stop looking for a printer.
'      Exit For
'   End If
Next
End Sub

Private Sub Form_Load()

   mAscribeSiteNumber = 2 '884
   
   mSession = 5321 '2061             '9-3-1_testing
'   mPrescriptionID = 15366     'was 30s to get drug
'   mPrescriptionID = 17543     'div by zero on issue
'   mPrescriptionID = 17685     'stat dose tablet
'   mPrescriptionID = 17760     'should be on WSL
'   mPrescriptionID = 17857     'spoons with dose multiplied
'   mPrescriptionID = 18103     'labstix - non medicinal
   mPrescriptionID = 110423 '18182#    'non medicinal - paracetamol
   
'   mSession = 171              '9-3-1_tameside_testing
'   mPrescriptionID = 29
   

   txtSiteNumber = Format$(mAscribeSiteNumber)
   txtSessionID.Text = Format$(mSession)
   txtPrescriptionID.Text = Format$(mPrescriptionID)
   txtDispensingID.Text = "0"
   
End Sub
