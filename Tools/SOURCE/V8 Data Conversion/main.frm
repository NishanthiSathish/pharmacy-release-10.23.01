VERSION 5.00
Begin VB.Form frmMain 
   Caption         =   "Version 8 Data Conversion Tool V"
   ClientHeight    =   10125
   ClientLeft      =   135
   ClientTop       =   195
   ClientWidth     =   15975
   Icon            =   "main.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   10125
   ScaleWidth      =   15975
   StartUpPosition =   2  'CenterScreen
   Begin VB.Frame FraImport 
      Caption         =   "Import/Export Options"
      Height          =   9975
      Left            =   5160
      TabIndex        =   61
      Top             =   120
      Width           =   5175
      Begin VB.CheckBox chkopts 
         Caption         =   "&Import ROQ/ROL CSV export templates"
         Height          =   195
         Index           =   43
         Left            =   240
         TabIndex        =   75
         Top             =   6480
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Background Pictures (from existing settings/share)"
         Height          =   195
         Index           =   42
         Left            =   240
         TabIndex        =   74
         Top             =   6000
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Escape Issue  (file dispdata\Escissue.log)"
         Height          =   195
         Index           =   41
         Left            =   240
         TabIndex        =   73
         Top             =   5160
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Reconcil  (file ascroot\Reconcil.log)"
         Height          =   195
         Index           =   40
         Left            =   240
         TabIndex        =   72
         Top             =   4800
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&PNEdit     (file dispdata\PNEdit.log)"
         Height          =   195
         Index           =   39
         Left            =   240
         TabIndex        =   71
         Top             =   4440
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "Import License file Settings"
         Height          =   195
         Index           =   38
         Left            =   240
         TabIndex        =   70
         Top             =   3960
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "Import PIL files from dispdata"
         Height          =   195
         Index           =   37
         Left            =   240
         TabIndex        =   69
         Top             =   3360
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "Import RTF files from dispdata"
         Height          =   195
         Index           =   36
         Left            =   240
         TabIndex        =   68
         Top             =   3000
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Crystal - eHub Exceptions Report"
         Height          =   195
         Index           =   35
         Left            =   240
         TabIndex        =   67
         Top             =   2280
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Crystal - eTrading Exceptions Report"
         Height          =   195
         Index           =   34
         Left            =   240
         TabIndex        =   66
         Top             =   1920
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Crystal - Stock Take Stock Difference Report"
         Height          =   195
         Index           =   33
         Left            =   240
         TabIndex        =   65
         Top             =   1560
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Crystal - Stock Take List in Packs Report"
         Height          =   195
         Index           =   32
         Left            =   240
         TabIndex        =   64
         Top             =   1200
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Crystal - Stock Take List Report"
         Height          =   195
         Index           =   31
         Left            =   240
         TabIndex        =   63
         Top             =   840
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Crystal - Expired Batches Report"
         Height          =   195
         Index           =   30
         Left            =   240
         TabIndex        =   62
         Top             =   480
         Width           =   4095
      End
   End
   Begin VB.CheckBox chkopts 
      Caption         =   "&GainLoss     (file dispdata\gainloss.log)"
      Height          =   195
      Index           =   28
      Left            =   360
      TabIndex        =   59
      Top             =   7200
      Width           =   4095
   End
   Begin VB.CheckBox chkopts 
      Caption         =   "&Batch Stock Level"
      Height          =   195
      Index           =   25
      Left            =   360
      TabIndex        =   25
      Top             =   6480
      Width           =   4095
   End
   Begin VB.CheckBox chkopts 
      Caption         =   "&LabUtils     (file ascroot\labutils.log)"
      Height          =   195
      Index           =   23
      Left            =   360
      TabIndex        =   26
      Top             =   6720
      Width           =   4095
   End
   Begin VB.TextBox txtPNRuleNumber 
      Enabled         =   0   'False
      Height          =   285
      Left            =   3720
      MaxLength       =   8
      TabIndex        =   32
      ToolTipText     =   "To convert single PN rule enter rule number. Leave blank to convert all rules."
      Top             =   8640
      Width           =   975
   End
   Begin VB.Frame fraOptions 
      Caption         =   "Conversion Options"
      Height          =   9975
      Left            =   120
      TabIndex        =   0
      Top             =   120
      Width           =   4845
      Begin VB.CheckBox chkopts 
         Caption         =   "&Negative      (file dispdata\negative.log)"
         Height          =   195
         Index           =   29
         Left            =   240
         TabIndex        =   60
         Top             =   7320
         Width           =   4095
      End
      Begin VB.OptionButton optConv 
         Caption         =   "TPN Conversion"
         Height          =   195
         Index           =   3
         Left            =   240
         TabIndex        =   30
         Top             =   960
         Width           =   3225
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Patient Information Leaflets"
         Height          =   195
         Index           =   27
         Left            =   240
         TabIndex        =   27
         Top             =   6840
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Report - Patient Invoice"
         Height          =   195
         Index           =   26
         Left            =   240
         TabIndex        =   29
         Top             =   7920
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Report - Free Format Label"
         Height          =   195
         Index           =   24
         Left            =   240
         TabIndex        =   28
         Top             =   7680
         Width           =   4095
      End
      Begin VB.TextBox txtPNProductCode 
         Enabled         =   0   'False
         Height          =   285
         Left            =   3600
         MaxLength       =   8
         TabIndex        =   34
         ToolTipText     =   "To convert single PN product enter PN Code. Leave blank to convert all products."
         Top             =   8880
         Width           =   975
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&TPN Prescription Pro-formas (InUse only)"
         Height          =   195
         Index           =   22
         Left            =   240
         TabIndex        =   36
         Top             =   9360
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&TPN Standard Regimens (InUse only)"
         Height          =   195
         Index           =   21
         Left            =   240
         TabIndex        =   35
         Top             =   9120
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&TPN Rules"
         Height          =   195
         Index           =   20
         Left            =   240
         TabIndex        =   33
         Tag             =   "PNRuleNumber"
         Top             =   8880
         Width           =   2055
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&TPN Default Values"
         Height          =   195
         Index           =   18
         Left            =   240
         TabIndex        =   31
         Top             =   8280
         Width           =   4095
      End
      Begin VB.OptionButton optPatientSelection 
         Caption         =   "Only Patients with Prescriptions"
         Height          =   195
         Index           =   1
         Left            =   720
         TabIndex        =   13
         Top             =   3480
         Width           =   3135
      End
      Begin VB.OptionButton optPatientSelection 
         Caption         =   "All Patients"
         Height          =   195
         Index           =   0
         Left            =   720
         TabIndex        =   12
         Top             =   3240
         Value           =   -1  'True
         Width           =   3135
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Mediate Databases"
         Height          =   195
         Index           =   16
         Left            =   240
         TabIndex        =   23
         Top             =   5880
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Consultant Specialty Links"
         Height          =   195
         Index           =   15
         Left            =   240
         TabIndex        =   22
         Top             =   5625
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "Stock La&bels"
         Height          =   195
         Index           =   14
         Left            =   240
         TabIndex        =   21
         Top             =   5370
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Specialties"
         Height          =   195
         Index           =   13
         Left            =   240
         TabIndex        =   20
         Top             =   5130
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Direction Codes"
         Height          =   195
         Index           =   12
         Left            =   240
         TabIndex        =   19
         Top             =   4890
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "Supplier Pro&files"
         Height          =   195
         Index           =   11
         Left            =   240
         TabIndex        =   18
         Top             =   4650
         Width           =   4185
      End
      Begin VB.OptionButton optConv 
         Caption         =   "Rx Logs"
         Height          =   195
         Index           =   4
         Left            =   240
         TabIndex        =   4
         Top             =   1200
         Width           =   3225
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Ward Stock "
         Height          =   195
         Index           =   10
         Left            =   240
         TabIndex        =   17
         Top             =   4410
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Orders, Requests && Reconciliations"
         Height          =   195
         Index           =   9
         Left            =   240
         TabIndex        =   16
         Top             =   4170
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Rx Logs"
         Height          =   195
         Index           =   8
         Left            =   240
         TabIndex        =   15
         Top             =   3930
         Width           =   4185
      End
      Begin VB.OptionButton optConv 
         Caption         =   "Stores && Dispensary &Conversion"
         Height          =   195
         Index           =   2
         Left            =   240
         TabIndex        =   3
         Top             =   720
         Width           =   3225
      End
      Begin VB.OptionButton optConv 
         Caption         =   "&Dispensary Conversion"
         Height          =   195
         Index           =   1
         Left            =   240
         TabIndex        =   2
         Top             =   510
         Width           =   3225
      End
      Begin VB.OptionButton optConv 
         Caption         =   "&Stores Conversion"
         Height          =   195
         Index           =   0
         Left            =   240
         TabIndex        =   1
         Top             =   270
         Width           =   3225
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Labels (excluding Rx Logs)"
         Height          =   195
         Index           =   7
         Left            =   240
         TabIndex        =   14
         Top             =   3690
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Patients (including episodes)"
         Height          =   195
         Index           =   6
         Left            =   240
         TabIndex        =   11
         Top             =   2985
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Stores Default Values"
         Height          =   195
         Index           =   5
         Left            =   240
         TabIndex        =   10
         Top             =   2730
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&GPs"
         Height          =   195
         Index           =   4
         Left            =   240
         TabIndex        =   9
         Top             =   2475
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Ward Specialty Links"
         Height          =   195
         Index           =   3
         Left            =   240
         TabIndex        =   8
         Top             =   2220
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Consultants"
         Height          =   195
         Index           =   2
         Left            =   240
         TabIndex        =   7
         Top             =   1980
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Supplier file (including Wards && Clinics)"
         Height          =   195
         Index           =   1
         Left            =   240
         TabIndex        =   6
         Top             =   1725
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "Config&uration Files (ini, dat, 044)"
         Height          =   195
         Index           =   0
         Left            =   240
         TabIndex        =   5
         Top             =   1470
         Width           =   4185
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&Formula Databases"
         Height          =   195
         Index           =   17
         Left            =   240
         TabIndex        =   24
         Top             =   6120
         Width           =   4095
      End
      Begin VB.CheckBox chkopts 
         Caption         =   "&TPN Products"
         Height          =   195
         Index           =   19
         Left            =   240
         TabIndex        =   37
         Tag             =   "PNProductCode"
         Top             =   8520
         Width           =   1815
      End
      Begin VB.Label lbPNRuleNumber 
         Caption         =   "PN Rule Number:"
         Enabled         =   0   'False
         Height          =   255
         Left            =   2280
         TabIndex        =   39
         Top             =   8880
         Width           =   1335
      End
      Begin VB.Label lbPNProductCode 
         Caption         =   "PN Product Code:"
         Enabled         =   0   'False
         Height          =   255
         Left            =   2280
         TabIndex        =   38
         Top             =   8520
         Width           =   1335
      End
   End
   Begin VB.Frame fraICWOpts 
      Caption         =   "ICW Options"
      Height          =   9975
      Left            =   10440
      TabIndex        =   40
      Top             =   120
      Width           =   5385
      Begin VB.TextBox txtDispSiteNos 
         Height          =   315
         Left            =   2280
         TabIndex        =   50
         ToolTipText     =   "eg  123,124,125,126"
         Top             =   2325
         Width           =   2685
      End
      Begin VB.TextBox txtPatSiteNos 
         Height          =   315
         Left            =   2280
         TabIndex        =   52
         ToolTipText     =   "eg  123,124,125,126"
         Top             =   2700
         Width           =   2685
      End
      Begin VB.DriveListBox drvData 
         Height          =   315
         Left            =   2280
         TabIndex        =   54
         Top             =   3075
         Width           =   2685
      End
      Begin VB.CommandButton cmdConvert 
         Caption         =   "Con&vert"
         Height          =   405
         Left            =   1935
         TabIndex        =   55
         Top             =   3675
         Width           =   1605
      End
      Begin VB.TextBox txtUser 
         Height          =   315
         Left            =   2280
         TabIndex        =   46
         Text            =   "icwsys"
         Top             =   1170
         Width           =   2685
      End
      Begin VB.TextBox txtDBName 
         Height          =   315
         Left            =   2280
         TabIndex        =   44
         Top             =   735
         Width           =   2685
      End
      Begin VB.TextBox txtICWDBPwd 
         Height          =   315
         IMEMode         =   3  'DISABLE
         Left            =   2280
         PasswordChar    =   "*"
         TabIndex        =   48
         Top             =   1590
         Width           =   2685
      End
      Begin VB.TextBox txtICWDBServer 
         Height          =   315
         Left            =   2280
         TabIndex        =   42
         Top             =   315
         Width           =   2685
      End
      Begin VB.Label lblVersion 
         Height          =   5295
         Left            =   120
         TabIndex        =   58
         Top             =   4320
         Width           =   5175
      End
      Begin VB.Label lblDispSiteNos 
         AutoSize        =   -1  'True
         Caption         =   "&Dispdata Site Numbers"
         Height          =   195
         Left            =   255
         TabIndex        =   49
         Top             =   2385
         Width           =   1620
      End
      Begin VB.Label lblPatSiteNos 
         AutoSize        =   -1  'True
         Caption         =   "&Patdata Site Numbers"
         Height          =   195
         Left            =   255
         TabIndex        =   51
         Top             =   2760
         Width           =   1545
      End
      Begin VB.Label lblDataDrive 
         AutoSize        =   -1  'True
         Caption         =   "&Data Drive"
         Height          =   195
         Left            =   255
         TabIndex        =   53
         Top             =   3135
         Width           =   765
      End
      Begin VB.Label lblICWUser 
         AutoSize        =   -1  'True
         Caption         =   "DB &User"
         Height          =   195
         Left            =   255
         TabIndex        =   45
         Top             =   1230
         Width           =   600
      End
      Begin VB.Label lblDBName 
         AutoSize        =   -1  'True
         Caption         =   "DB &Name"
         Height          =   195
         Left            =   255
         TabIndex        =   43
         Top             =   795
         Width           =   690
      End
      Begin VB.Label lblICWDBPwd 
         AutoSize        =   -1  'True
         Caption         =   "DB Pass&word"
         Height          =   195
         Left            =   255
         TabIndex        =   47
         Top             =   1650
         Width           =   960
      End
      Begin VB.Label lblDBServer 
         AutoSize        =   -1  'True
         Caption         =   "&ICW DB Server"
         Height          =   195
         Left            =   255
         TabIndex        =   41
         Top             =   375
         Width           =   1095
      End
   End
   Begin VB.FileListBox flstRxLogs 
      Height          =   480
      Left            =   1440
      Pattern         =   "rx????"
      TabIndex        =   56
      Top             =   9840
      Width           =   1455
   End
   Begin VB.PictureBox timerProgressOLD 
      Enabled         =   0   'False
      Height          =   420
      Left            =   540
      ScaleHeight     =   360
      ScaleWidth      =   360
      TabIndex        =   57
      Top             =   9840
      Width           =   420
   End
   Begin VB.Timer timerProgress 
      Enabled         =   0   'False
      Left            =   3480
      Top             =   9840
   End
End
Attribute VB_Name = "frmMain"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'----------------------------------------------------------------------------------
'
' Purpose:
'
'
' Modification History:
'  10Feb05 EAC Written
'  29Nov07 CKJ Raised from 1.2.0.0 to V1.3.0.0
'              Patient notes increased from 1024 byte varchar to 8000 byte longvarchar (SQL Text, Jet Memo)
'              Notes field trimmed of leading & trailing whitespace, embedded runs of crlf reduced to two max
'              Label added to screen to show user what has been changed in this version
'              Trapped error reading blank registry strings
'  30Nov07 CKJ Changed from Text back to varchar(8000) due to error on casting
'  18Mar09 EAC F0048514: Add option to only convert patient with prescriptions
'  13Jul10 EAC F0090667 Correct conversion of the quantity fields.
'  24Jan11 EAC F0049923 Updated Data Conversion program to work with .NET version of the ICW
'  14Mar11 EAC F0049923 - Transformed connection string details to work with Windows7 and Server 2008 machines.
'  04Nov11 CKJ PN defaults, products & rules added. Password not written to registry.
'  07Nov11 CKJ Parse out password from log entry.
'  22Nov11 CKJ Merged XN mod: connect to DB directly instead of via .Net wrapper or COM+
'  30Jan13 XN  54164: CreateCategory: Removed sql script PN_UpdateConfigForTest.sql and hardcoded
'              conversion of A|TPNW.044 to A|PNW.044 and D|TPNSETUP to D|PNSETUP
'  31Jan13 XN  ReadAppSettings: Tended to throw up error first time run on a machine as reg settings
'              don't exist so supressed error.
'  15Jul13 XN  35617 cmdConvert_Click: Added handling of single PN product, or rule
'              35617 Form_Load:        Added handling of single PN product, or rule
'              35617 chkopts_Click:    Added handling of single PN product, or rule
'  4Aug13  XN  71349 Skip updating WDirtection, WConfiguration, WLookup if eixsting row's DSS flag is set
'  22May14 XN  88857 Added Free Format Reports
'              81731 splitout WBatchStockLevel from wFormula conversion
'              88863 moved patient invoice into the DB
'  30May14 XN  92190 Added TPN Conversion radio button
'  07Apr16 XN  123082 Added Negative and GainLoss logs
'  11Nov16 TH  Added Crystal conversion stuff (TFS 157972)
'  06Dec16 TH cmdConvert_Click: New RTF mods for Hosted Pharmacy (TFS 157969)
'  12Jan17 TH cmdConvert_Click: Conversion for Pharmacy PILS (TFS 157969)
'  12Jan17 TH cmdConvert_Click: New License file mods for Hosted Pharmacy (TFS 156988)
'  13Apr17 TH cmdConvert_Click: Added EscIssue Import
'  16May17 TH cmdConvert_Click: ROQROL CSV Template import (TFS 174881)
'----------------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Private Const CLASS_NAME = "frmV8DatConv"
Private Const COM_SECRTL10_WRAPPER_PROGID = "IcwSecrtl10.ComWrapper"

Private Const ICW_USER_NAME = "IcwUserName"
Private Const ICW_PASSWORD = "IcwPassword"
Private Const ICW_SEC_APPID = "Secrtl10AppId"
Private Const ICW_TRN_APPID = "Trnrtl10AppId"

Private Const ICW_DB_SERVER = "IcwDBServer"
Private Const ICW_DB_NAME = "IcwDBName"
Private Const ICW_DB_USER = "IcwDBUser"
Private Const ICW_DB_PWD = "IcwDBPWD"
'F0049923 Start
Private Const ICW_TYPE = "IcwType"
Private Const DISPDATAS = "DispdataSiteNumbers"
Private Const PATDATAS = "PatdataSiteNumbers"
Private Const DATA_DRIVE = "DataDrive"
'F0049923 End

Private Const V8_DATCONV_REG_KEY = "Software\ascribe\V8DatConv"

Private mboolIgnoreClicks As Boolean

Public UpdateProgress As Boolean

Private Sub CreateAppRegistryEntries()
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "CreateAppRegistryEntries"

Dim udtError As udtErrorState



   On Error GoTo ErrorHandler

   If Not CheckRegistryKey(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY) Then
        Call CreateRegistryKey(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY)
      Call SaveAppSettings
   End If

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   If Err.Number = 1001 Then
      Err.Clear
      Resume Next
   Else
      CaptureErrorState udtError, CLASS_NAME, SUB_NAME
      Resume Cleanup
   End If
   
End Sub

'Private Function DotNetLogInToICW(ByRef lngSessionID As Long, ByRef strDbConnString As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'
' Outputs:
'     lngSessionID         :  Standard sessionid
'     strDbConnString      :  Connection string for the ICW database from the web.config file
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  24Jan11 EAC  Written
'  14Mar11 EAC  F0049923 - Transformed connection string details to work with Windows7 and Server 2008 machines.
'
'----------------------------------------------------------------------------------
'
'Const LOCATION_ID = 0
'Const SUB_NAME = "DotNetLogIntoICW"
'
'Dim udtError As udtErrorState
'
'Dim objSec As Object 'IcwSecrtl10.ComWrapper
'
'Dim strReturn As String
'
'
'   On Error GoTo ErrorHandler
'
'   lngSessionID = -1
'   MsgBox ("Creating object")
'   Set objSec = CreateObject(COM_SECRTL10_WRAPPER_PROGID)
'   If objSec Is Nothing Then MsgBox ("Failed to create object")
'   MsgBox ("Created object")
'
'   MsgBox ("Loging in")
'   lngSessionID = objSec.Login(txtSecAppID.Text, _
'                               txtICWUser.Text, _
'                               txtICWPwd.Text, _
'                               LOCATION_ID, _
'                               True, _
'                               False)
'   If (lngSessionID <= 0) Then MsgBox ("Failed to loging in")
'   MsgBox ("logged in")
'
'   MsgBox ("Getting connection string")
'   strDbConnString = "provider=sqloledb;" & objSec.GetConnectionString(txtSecAppID.Text)
'   MsgBox (strDbConnString)
'
'   Set objSec = Nothing
'
'   strDbConnString = Replace(strDbConnString, "Data Source", "server")
'   strDbConnString = Replace(strDbConnString, "Initial Catalog", "database")
'   strDbConnString = Replace(strDbConnString, "User ID", "uid")
'   strDbConnString = Replace(strDbConnString, "Password", "pwd")
'   strDbConnString = Replace(strDbConnString, "Integrated Security=False;", "")
'   MsgBox (strDbConnString)
'
'
'Cleanup:
'
'   On Error Resume Next
'
'   Set objSec = Nothing
'
'   DotNetLogInToICW = strReturn
'
'   On Error GoTo 0
'
'   BubbleOnError udtError
'
'Exit Function
'
'ErrorHandler:
'
   'CaptureErrorState udtError, CLASS_NAME, SUB_NAME
'
'   strReturn = ConvertErrorToBrokenRulesXML(udtError)
'
'   Resume Cleanup
'
'
'End Function

'Private Function FindTransportLayerConnectionString(ByRef strDbConnString As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Feb05 EAC  Written
'
'----------------------------------------------------------------------------------
'
'Const SUB_NAME = "FindTransportLayerConnectionString"
'
'Dim udtError As udtErrorState
'
'Dim objApplications As COMAdmin.COMAdminCatalogCollection
'Dim objApplication As COMAdmin.COMAdminCatalogObject
'Dim objCatalog As COMAdmin.COMAdminCatalog
'Dim objComponent As COMAdmin.COMAdminCatalogObject
'Dim objComponents As COMAdmin.COMAdminCatalogCollection
'
'Dim boolFound As Boolean
'
'   On Error GoTo ErrorHandler
'
'   boolFound = False
'
'   Set objCatalog = New COMAdmin.COMAdminCatalog
'   Set objApplications = objCatalog.GetCollection("Applications")
'   objApplications.Populate
'
'   For Each objApplication In objApplications
'      Set objComponents = objApplications.GetCollection("Components", objApplication.Key)
'      objComponents.Populate
'
'      For Each objComponent In objComponents
'         If LCase(objComponent.name) = LCase(txtTrnAppID.Text & ".Transport") Then
'            boolFound = True
'            strDbConnString = objComponent.value("ConstructorString")
'            Exit For
'         End If
'      Next
'
'      If boolFound Then Exit For
'   Next
'
'Cleanup:
'
'   On Error Resume Next
'   Set objApplication = Nothing
'   Set objApplications = Nothing
'   Set objCatalog = Nothing
'   Set objComponent = Nothing
'   Set objComponents = Nothing
'
'   On Error GoTo 0
'   BubbleOnError udtError
'
'Exit Function
'
'ErrorHandler:
'
'   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
'   Resume Cleanup
'End Function



'Private Function LogIntoICW(ByRef lngSessionID As Long) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'
' Outputs:
'     lngSessionID        :  Standard sessionid
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Feb05 EAC  Written
'
'----------------------------------------------------------------------------------
'
'Const LOCATION_ID = 0
'Const SUB_NAME = "LogIntoICW"
'
'Dim udtError As udtErrorState
'
'Dim objDOM As MSXML2.DOMDocument
'Dim objSec As Object 'SECRTL10.Security
'
'Dim strReturn As String
'
'
'   On Error GoTo ErrorHandler
'
'   lngSessionID = -1
'
'   Set objSec = CreateObject(txtSecAppID.Text & ".Security")
'   strReturn = objSec.LoginUser(txtICWUser.Text, _
'                                txtICWPwd.Text, _
'                                LOCATION_ID, _
'                                True)
'   Set objSec = Nothing
'
'
'   If NoRulesBroken(strReturn) Then
'      Set objDOM = New MSXML2.DOMDocument
'      With objDOM
'         .loadXML strReturn
'         lngSessionID = CLng(.documentElement.Attributes.getNamedItem("SessionID").Text)
'         strReturn = vbNullString
'      End With
'   End If
'
'
'Cleanup:
'
'   On Error Resume Next
'
'   Set objSec = Nothing
'   Set objDOM = Nothing
'
'   LogIntoICW = strReturn
'
'   On Error GoTo 0
'   BubbleOnError udtError
'
'Exit Function
'
'ErrorHandler:
'
'   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
'   Resume Cleanup
'
'End Function

'Private Sub LogOutOfICW(ByVal lngSessionID As Long)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Feb05 EAC  Written
'
'----------------------------------------------------------------------------------
'
'Const SUB_NAME = "LogOutOfICW"
'
'Dim udtError As udtErrorState
'
'Dim objSec As Object 'SECRTL10.Security
'
'Dim strReturn As String
'
'   On Error GoTo ErrorHandler
'
'   If lngSessionID <> -1 Then
'      If (cmbICWType.ListIndex = 1) Then
'         Set objSec = CreateObject(txtSecAppID & ".Security")
'         strReturn = objSec.LogoutUser(lngSessionID)
'      Else
'         Set objSec = CreateObject(COM_SECRTL10_WRAPPER_PROGID)
'         strReturn = objSec.Logout(txtSecAppID.Text, lngSessionID)
'      End If
'   End If
'
'Cleanup:
'
'   On Error Resume Next
'   Set objSec = Nothing
'
'   On Error GoTo 0
'   BubbleOnError udtError
'
'Exit Sub
'
'ErrorHandler:
'
'   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
'   Resume Cleanup
'
'End Sub


Private Sub ReadAppSettings()
'----------------------------------------------------------------------------------
'
' Purpose: Reads the application settings and sets the relevant text boxes in fraICW
'
' Inputs:
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Feb05 EAC  Written
'  24Jan11 EAC  Added ICW Type and other settings
'  02Nov11 CKJ  removed password
'  04Nov11 CKJ  Blank patdata/dispdata causes error - added space & rtrim
'  31Jan13 XN   Tended to throw up error first time run on a machine as reg settings
'               don't exist so supressed error.
'----------------------------------------------------------------------------------

Const SUB_NAME = "ReadAppSettings"

Dim udtError As udtErrorState

Dim strDataDrive As String

   'On Error GoTo ErrorHandler 31Jan13 XN Suppressed errors that occur on first startup
   On Error Resume Next

'   txtICWUser.Text = GetRegistryValue(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_USER_NAME)
'   txtICWPwd.Text = ""        '02Nov11 CKJ was  GetRegistryValue(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_PASSWORD)
'   txtSecAppID.Text = GetRegistryValue(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_SEC_APPID)
'   txtTrnAppID.Text = GetRegistryValue(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_TRN_APPID)
   'F0049923
'   cmbICWType.ListIndex = CInt(GetRegistryValue(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_TYPE))
   txtICWDBServer.Text = RTrim$(GetRegistryValue(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_DB_SERVER))
   txtDBName.Text = RTrim$(GetRegistryValue(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_DB_NAME))
   txtUser.Text = RTrim$(GetRegistryValue(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_DB_USER))
   
   txtDispSiteNos.Text = RTrim$(GetRegistryValue(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, DISPDATAS))
   txtPatSiteNos.Text = RTrim$(GetRegistryValue(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, PATDATAS))
   strDataDrive = GetRegistryValue(HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, DATA_DRIVE)
   
   If Len(strDataDrive) > 0 Then
      drvData.Drive = strDataDrive
   End If
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

' 31Jan13 XN Suppressed errors that occur on first startup
'Exit Sub

'ErrorHandler:
'
'   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
'   Resume Cleanup
   
End Sub

Private Sub SaveAppSettings()
'----------------------------------------------------------------------------------
'
' Purpose: Save the ICW option frame settings to the registry
'
' Inputs:
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Feb05 EAC  Written
'  24Jan11 EAC  Added ICW Type and other settings
'  02Nov11 CKJ  removed password
'  04Nov11 CKJ  Blank patdata/dispdata causes error - added space & rtrim
'----------------------------------------------------------------------------------

Const SUB_NAME = "SaveSettings"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler
   
    SetRegistryValue HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_DB_SERVER, txtICWDBServer.Text
    SetRegistryValue HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_DB_NAME, txtDBName.Text
    SetRegistryValue HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_DB_USER, txtUser.Text

'   SetRegistryValue HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_USER_NAME, txtICWUser.Text
   SetRegistryValue HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_PASSWORD, ""              '02Nov11 CKJ was txtICWPwd.Text
'   SetRegistryValue HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_SEC_APPID, txtSecAppID.Text
'   SetRegistryValue HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_TRN_APPID, txtTrnAppID.Text
   'F0049923
'   SetRegistryValue HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, ICW_TYPE, Format$(cmbICWType.ListIndex)
   SetRegistryValue HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, DISPDATAS, txtDispSiteNos.Text & " "
   SetRegistryValue HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, PATDATAS, txtPatSiteNos.Text & " "
   SetRegistryValue HKEY_LOCAL_MACHINE, V8_DATCONV_REG_KEY, DATA_DRIVE, drvData.Drive

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub

Private Sub ShowNotSupported()
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  18Apr05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ShowNotSupported"

Dim udtError As udtErrorState



   On Error GoTo ErrorHandler


   MsgBox "This functionality is not supported in this release of the V8 Conversion program.", vbCritical + vbOKOnly
   

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub

Public Sub StartProgressTimer()
'----------------------------------------------------------------------------------
'
' Purpose: Starts the ProgressTimer and clears the UpdateProgress flag
'
' Inputs:
'
' Outputs:
'
' Modification History:
'  02Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "StartProgressTimer"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   UpdateProgress = False
   
   timerProgress.Interval = 1000
   
   timerProgress.Enabled = True

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub


'Private Sub cmbICWType_Click()
'
'   If (cmbICWType.ListIndex = 0) Then
'      lblSecAppID.Caption = "IIS Virtual Directory Name"
'      lblTrnAppID.Visible = False
'      txtTrnAppID.Visible = False
'   Else
'      lblSecAppID.Caption = "Security Object AppID"
'      lblTrnAppID.Visible = True
'      txtTrnAppID.Visible = True
'   End If
'
'End Sub

'Private Sub chkopts_Click(index As Integer)
'
'   If Not mboolIgnoreClicks Then
'      If index = 8 Then optConv(3).value = True
'   End If
'
'End Sub

Private Sub cmdConvert_Click()
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Feb05 EAC  Written
'  08Feb10 EAC  F0075670 - Changed site number checking so that a patdata number is
'                          required, to prevent subscript of range error when processing the configuration data.
'  15Jul13 XN   35617    - Added handling of single PN product, or rule
'  13Apr17 TH   Added EscIssue Import
'----------------------------------------------------------------------------------

Const SUB_NAME = "cmdConvert_Click"

Dim udtError As udtErrorState

Dim lngLocationID_Parent As Long
Dim lngSessionID As Long

Dim astrDispdataSiteNumbers() As String
Dim astrPatdataSiteNumbers() As String

Dim strDataDrive As String
Dim strDbConnString As String
Dim strReturn As String

   On Error GoTo ErrorHandler
   
   Screen.MousePointer = vbHourglass
      
   SaveAppSettings
   
   lngSessionID = 0
'   If (cmbICWType.ListIndex = 1) Then
'      strReturn = LogIntoICW(lngSessionID)
'
'      If NoRulesBroken(strReturn) Then
'         strReturn = FindTransportLayerConnectionString(strDbConnString)
'      End If
'   Else
'      strReturn = DotNetLogInToICW(lngSessionID, strDbConnString)
'   End If

    strDbConnString = "provider=sqloledb;" & _
                      "server=" & txtICWDBServer.Text & ";" & _
                      "database=" & txtDBName.Text & ";" & _
                      "uid=" & txtUser.Text & ";" & _
                      "Pwd=" & txtICWDBPwd.Text & ";"

'   strDbConnString = "provider=sqloledb;" & objSec.GetConnectionString(txtSecAppID.Text)
'   MsgBox (strDbConnString)
'
'   Set objSec = Nothing
'
'   strDbConnString = Replace(strDbConnString, "Data Source", "server")
'   strDbConnString = Replace(strDbConnString, "Initial Catalog", "database")
'   strDbConnString = Replace(strDbConnString, "User ID", "uid")
'   strDbConnString = Replace(strDbConnString, "Password", "pwd")
'   strDbConnString = Replace(strDbConnString, "Integrated Security=False;", "")
   'strReturn = CreateICWConnectionString()
   
   If NoRulesBroken(strReturn) Then
      If chkopts(1).value = vbChecked Then
         strReturn = frmHospital.GetWardParentLocationID(lngSessionID, _
                                                         strDbConnString, _
                                                         lngLocationID_Parent)
      End If
   End If
   
   If NoRulesBroken(strReturn) Then
      
      astrDispdataSiteNumbers = Split(txtDispSiteNos.Text, ",")
      astrPatdataSiteNumbers = Split(txtPatSiteNos.Text, ",")
      strDataDrive = Left$(drvData.Drive, 2)
   
      If (Len(txtDispSiteNos) = 0) And (Len(txtPatSiteNos.Text) = 0) Then _
            strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML("NO_SITE_NOS_PROVIDED", _
                                                                 "Please supply at least one dispdata or one patdata site number."))
                                                                 
'      If (UBound(astrPatdataSiteNumbers) <> UBound(astrDispdataSiteNumbers)) Then _
'            strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML("SITE_NOS_DONT_MATCH", _
'                                                                 "Please supply an equal number of dispdata and patdata site numbers. You may need to repeat the patdata site number e.g. dispdata numbers = '2,3,4' and patdata numbers = '2,2,2'"))
   End If
   
   If NoRulesBroken(strReturn) Then
      strReturn = InstallMetadata(lngSessionID, _
                                  strDbConnString)
   End If
   
   If NoRulesBroken(strReturn) Then
      strReturn = AddSiteNumbers(lngSessionID, _
                                 strDbConnString, _
                                 astrDispdataSiteNumbers, _
                                 astrPatdataSiteNumbers)
   End If
   
   ' If only sending single PN row check user has entered PN Product Code or PN Rule number
   ' 15Jul13 XN TFS 35617
   If gOnlyOnePNRow = True And chkopts(19).value = vbChecked And txtPNProductCode = "" Then
        strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML("ONLY_ALLOWED_SINGLE_PN_PRODUCT", "Enter a PN Product Code."))
   End If
   If gOnlyOnePNRow = True And chkopts(20).value = vbChecked And txtPNRuleNumber = "" Then
        strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML("ONLY_ALLOWED_SINGLE_PN_RULE", "Enter a PN Rule Number."))
   End If

   If NoRulesBroken(strReturn) Then
      If chkopts(0).value = vbChecked Then strReturn = ConvertConfigurationFiles(lngSessionID, _
                                                                                 astrDispdataSiteNumbers, _
                                                                                 astrPatdataSiteNumbers, _
                                                                                 strDataDrive, _
                                                                                 strDbConnString)
                                                                                 
      If chkopts(1).value = vbChecked Then strReturn = ConvertSuppliers(lngSessionID, _
                                                                        astrDispdataSiteNumbers, _
                                                                        strDataDrive, _
                                                                        strDbConnString, _
                                                                        lngLocationID_Parent)
                                                                 
      If chkopts(2).value = vbChecked Then strReturn = ConvertConsultants(lngSessionID, _
                                                                          astrDispdataSiteNumbers, _
                                                                          strDataDrive, _
                                                                          strDbConnString)
                                                                          
      If chkopts(12).value = vbChecked Then strReturn = ConvertDirections(lngSessionID, _
                                                                          astrDispdataSiteNumbers, _
                                                                          strDataDrive, _
                                                                          strDbConnString)
                                                                          
      If chkopts(13).value = vbChecked Then strReturn = ConvertSpecialties(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           strDbConnString)
                                                                          
      If chkopts(3).value = vbChecked Then strReturn = ConvertWardSpecialtyLinks(lngSessionID, _
                                                                                 astrDispdataSiteNumbers, _
                                                                                 strDataDrive, _
                                                                                 strDbConnString)
                                                                                 
      If chkopts(15).value = vbChecked Then strReturn = ConvertConsultantSpecialtyLinks(lngSessionID, _
                                                                                        astrDispdataSiteNumbers, _
                                                                                        strDataDrive, _
                                                                                        strDbConnString)
                                                                                        
      If chkopts(4).value = vbChecked Then strReturn = ConvertGPs(lngSessionID, _
                                                                   astrDispdataSiteNumbers, _
                                                                   strDataDrive, _
                                                                   strDbConnString)
                                                                   
      If chkopts(5).value = vbChecked Then strReturn = ConvertStoresDefaults(lngSessionID, _
                                                                             astrDispdataSiteNumbers, _
                                                                             strDataDrive, _
                                                                             strDbConnString)
                                                                             
      If chkopts(6).value = vbChecked Then strReturn = ConvertPatients(lngSessionID, _
                                                                       astrPatdataSiteNumbers, _
                                                                       strDataDrive, _
                                                                       strDbConnString)
                                                                       
      If chkopts(9).value = vbChecked Then strReturn = ConvertStoresFiles(lngSessionID, _
                                                                          astrDispdataSiteNumbers, _
                                                                          strDataDrive, _
                                                                          strDbConnString)
      
      If chkopts(10).value = vbChecked Then strReturn = ConvertWardStockDbs(lngSessionID, _
                                                                            astrDispdataSiteNumbers, _
                                                                            strDataDrive, _
                                                                            strDbConnString)
      
      If chkopts(11).value = vbChecked Then strReturn = ConvertSupplierProfiles(lngSessionID, _
                                                                               astrDispdataSiteNumbers, _
                                                                               strDataDrive, _
                                                                               strDbConnString)
                                                                                                                                                               
      If chkopts(14).value = vbChecked Then strReturn = ConvertStockLabels(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           strDbConnString)
      
      If chkopts(16).value = vbChecked Then strReturn = ConvertMediateDbs(lngSessionID, _
                                                                          astrDispdataSiteNumbers, _
                                                                          strDataDrive, _
                                                                          strDbConnString)
                                                                          
      If chkopts(17).value = vbChecked Then strReturn = ConvertFormulaDbs(lngSessionID, _
                                                                          astrDispdataSiteNumbers, _
                                                                          strDataDrive, _
                                                                          strDbConnString)
                                                                          
      ' 81731 XN 22May14 Split WBatchStockLevel from WFormula conversion
      If chkopts(25).value = vbChecked Then strReturn = ConvertBatchStockLevels(lngSessionID, _
                                                                                astrDispdataSiteNumbers, _
                                                                                strDataDrive, _
                                                                                strDbConnString)
                                                                                                                                                    
      If chkopts(7).value = vbChecked Then strReturn = ConvertLabels(lngSessionID, _
                                                                     astrPatdataSiteNumbers, _
                                                                     strDataDrive, _
                                                                     strDbConnString)
                                                                     
      If chkopts(8).value = vbChecked Then strReturn = ConvertRxLogs(lngSessionID, _
                                                                     astrPatdataSiteNumbers, _
                                                                     strDataDrive, _
                                                                     strDbConnString)
                                                                     
      '04Nov11 CKJ TPN added
      If chkopts(18).value = vbChecked Then strReturn = ConvertTPNdefaults(lngSessionID, _
                                                                     astrDispdataSiteNumbers, _
                                                                     strDataDrive, _
                                                                     strDbConnString)
                                                                     
      If chkopts(19).value = vbChecked Then strReturn = ConvertTPNproductDBs(lngSessionID, _
                                                                     astrDispdataSiteNumbers, _
                                                                     strDataDrive, _
                                                                     strDbConnString, _
                                                                     txtPNProductCode.Text)  ' 15Jul13 XN TFS 35617
                                                                     
      If chkopts(20).value = vbChecked Then strReturn = ConvertTPNruleDBs(lngSessionID, _
                                                                     astrDispdataSiteNumbers, _
                                                                     strDataDrive, _
                                                                     strDbConnString, _
                                                                     txtPNRuleNumber.Text)   ' 15Jul13 XN TFS 35617
                                                                     
      If chkopts(21).value = vbChecked Then strReturn = ConvertTPNStdRegDBs(lngSessionID, _
                                                                     astrDispdataSiteNumbers, _
                                                                     strDataDrive, _
                                                                     strDbConnString)         'TPN std regimens
      
      If chkopts(22).value = vbChecked Then strReturn = ConvertTPNRxProformaDBs(lngSessionID, _
                                                                     astrDispdataSiteNumbers, _
                                                                     strDataDrive, _
                                                                     strDbConnString)         'TPN prescription pro-formas
                                                                     
      If chkopts(23).value = vbChecked Then strReturn = ConvertPharmacyLogs(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "labutils", _
                                                                           strDbConnString)    'Labutils
                                                                           
      If chkopts(24).value = vbChecked Then strReturn = ConvertReports(lngSessionID, _
                                                                      astrDispdataSiteNumbers, _
                                                                      strDataDrive, _
                                                                      "FFLabel.RTF", _
                                                                      "Pharmacy Free Format Label", _
                                                                      "PharmacyGeneralReport", _
                                                                      False, _
                                                                      strDbConnString)  ' Reports Free Format Label
                                                                      
      ' 88863 XN 22May14 Added conversion of Patient Invoice report

      If chkopts(26).value = vbChecked Then strReturn = ConvertReports(lngSessionID, _
                                                                       astrDispdataSiteNumbers, _
                                                                       strDataDrive, _
                                                                       "INVOICE.RTF", _
                                                                       "Pharmacy Patient Invoice", _
                                                                       "PharmacyGeneralReport", _
                                                                       True, _
                                                                       strDbConnString)  ' Reports Patient Invoice
      
          '  07Apr16 XN  123082 Added Negative and GainLoss logs
      If chkopts(28).value = vbChecked Then strReturn = ConvertPharmacyLogs(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "GainLoss", _
                                                                           strDbConnString)    'GainLoss
      
      If chkopts(29).value = vbChecked Then strReturn = ConvertPharmacyLogs(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "Negative", _
                                                                           strDbConnString)    'Negative
                                                                           
      '11Nov16 TH Crystal stuff (TFS 157972)
      If chkopts(30).value = vbChecked Then strReturn = ConvertCrystalReports(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "ExpBatch.rpt", _
                                                                           True, _
                                                                           strDbConnString)    'Expired Batch Report
                                                                           
      If chkopts(31).value = vbChecked Then strReturn = ConvertCrystalReports(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "MstkList.rpt", _
                                                                           True, _
                                                                           strDbConnString)    'Stock Take List Report
                                                                           
      If chkopts(32).value = vbChecked Then strReturn = ConvertCrystalReports(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "MstListP.rpt", _
                                                                           True, _
                                                                           strDbConnString)    'Stock Take List in Packs Report
                                                                           
      If chkopts(33).value = vbChecked Then strReturn = ConvertCrystalReports(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "StckDiff.rpt", _
                                                                           True, _
                                                                           strDbConnString)    'Stock Take Stock Difference
                                                                           
      If chkopts(34).value = vbChecked Then strReturn = ConvertCrystalReports(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "aahexcpt.rpt", _
                                                                           True, _
                                                                           strDbConnString)    'AAH/EDI Exception Report
                                                                           
      If chkopts(35).value = vbChecked Then strReturn = ConvertCrystalReports(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "HubExcpt.rpt.rpt", _
                                                                           True, _
                                                                           strDbConnString)    'eHub Eception Report
                                                                           
      
      '06Dec16 TH New RTF mods for Hosted Pharmacy (TFS 157969)
      If chkopts(36).value = vbChecked Then strReturn = ConvertPharmacyRTFReports(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           True, _
                                                                           strDbConnString)    'RTF Templates
                                                                           
      '12Jan17 TH Conversion for Pharmacy PILS (TFS 157969)
      If chkopts(37).value = vbChecked Then strReturn = ConvertPharmacyPILs(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           True, _
                                                                           strDbConnString)    'RTF Templates for PIL
      
      '12Jan17 TH New License file mods for Hosted Pharmacy (TFS 156988)
      If chkopts(38).value = vbChecked Then strReturn = ConvertLicenseFile(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           strDbConnString)    'License file settings for EDI
                                                                           
      If chkopts(39).value = vbChecked Then strReturn = ConvertPharmacyLogs(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "PNEdit", _
                                                                           strDbConnString)    'PNEdit
                                                                           
      If chkopts(40).value = vbChecked Then strReturn = ConvertPharmacyLogs(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "Reconcil", _
                                                                           strDbConnString)    'Reconcil
                                                                           
      '13Apr17 TH Added after code review
      If chkopts(41).value = vbChecked Then strReturn = ConvertPharmacyLogs(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           "escissue", _
                                                                           strDbConnString)    'EscIssue
                                                                           
''      If chkopts(41).value = vbChecked Then strReturn = ConvertPharmacyLogs(lngSessionID, _
''                                                                           astrDispdataSiteNumbers, _
''                                                                           strDataDrive, _
''                                                                           "Editors", _
''                                                                           strDbConnString)    'Editors

      '16May17 TH Main Background picture upload conversion (TFS 174888)
      If chkopts(42).value = vbChecked Then strReturn = ConvertPharmacyBackground(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           strDbConnString)    'Pictures from settings

''      16May17 TH Background picture upload '28May17 TH Should now be done from within software only
''      If chkopts(43).value = vbChecked Then strReturn = ConvertPharmacyBackground(lngSessionID, _
''                                                                           astrDispdataSiteNumbers, _
''                                                                           strDataDrive, _
''                                                                           "escissue", _
''                                                                           strDbConnString)    'EscIssue
                                                                           
      '16May17 TH ROQROL CSV Template import (TFS 174881)
      If chkopts(43).value = vbChecked Then strReturn = ConvertPharmacyROQROLTemplates(lngSessionID, _
                                                                           astrDispdataSiteNumbers, _
                                                                           strDataDrive, _
                                                                           strDbConnString)
                                                                           
   End If

Cleanup:

   On Error Resume Next
   'LogOutOfICW lngSessionID
   
   Screen.MousePointer = vbNormal
   
   If RulesBroken(strReturn) Then
      MsgBox strReturn
   Else
      MsgBox "Finished"
   End If
   
   On Error GoTo 0


Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   strReturn = ConvertErrorToBrokenRulesXML(udtError)
   Resume Cleanup

End Sub

Private Sub cmdCrystalImport_Click()
'11Nov16 TH Written.
'To be used to import Crysat .rpt files from the designated Dispdata into the designated Database
'As BLOB Objects. These can the be accessed from the DB rather than a local file share


End Sub

Private Sub Form_Load()

Const SUB_NAME = "Form_Load()"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler
   
   CreateAppRegistryEntries
   
   ReadAppSettings
   
   If InStr(1, UCase$(Command$), "/DEBUG") Then gDebug = True
   If InStr(1, UCase$(Command$), "/DSS") Then gDSS = True                              ' 15Jul13 XN TFS 35617 DSS command line mode (allows DSS to convert single PN Product, or rule)
   If InStr(1, UCase$(Command$), "/ONLYONEPNITEM") Then gOnlyOnePNRow = True And gDSS  ' 15Jul13 XN TFS 35617 OnlyOnePNItem forces uses to enter a single PN Product, or rule, so can't accidently convert all item.
   
   lblVersion.Caption = "29Nov07 Patient conversion allows Notes up to 8000 bytes long"      '29Nov07 CKJ Raised to V1.3.0
   
   '18Mar09 EAC F0048514: Add option to only convert patient with prescriptions
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "18Mar09 F0048514: Add option to only convert patient with prescriptions."
   
   '08Feb10 EAC F0075670: Various fixes.
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "08Feb10 F0075670: Various fixes."
   
   '13Jul10 EAC  F0090667 Correct conversion of the quantity fields.
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "13Jul10 F0090667: Correct conversion of the WFormula quantities."
   
   '24Jan11 EAC F0049923
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "24Jan11 F0049923: Make compatible with .NET versions of the ICW."
   
   'cmbICWType.ListIndex = 0
   
   '01Nov11 CKJ Added TPN. Raised version from 1.6 to 1.6.1
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "04Nov11 Added TPN and removed password retention"
   
   '25Aug12 TH  Major overhaul. Raised version from 1.6 to 1.7.1
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "25Aug12 TFS 38307 Consolidated app and removed dependencies - move into standard builder"
   
   '30Jan13 XN  54164 Removed sql script PN_UpdateConfigForTest.sql and hardcoded conversion of A|TPNW.044 to A|PNW.044 and D|TPNSETUP to D|PNSETUP
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "30Jan13 TFS 54164 Removed sql script PN_UpdateConfigForTest.sql and hardcoded conversion of A|TPNW.044 to A|PNW.044 and D|TPNSETUP to D|PNSETUP. Also suppressed reg error on first start-up."
   
   ' Ability to convert single PN Product, or Rule (for DSS use only) 15Jul13 XN 35617
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "15Jul13 TFS 35617 Ability to convert single PN Product, or Rule (for DSS use only)."
   
   ' Skip updating WDirtection, WConfiguration, WLookup if eixsting row's DSS flag is set 14Aug13 XN 71349
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "14Aug13 71349 Skip updating WDirtection, WConfiguration, WLookup if eixsting row's DSS flag is set"
   
   ' Added conversion of labutils 19Feb14 XN 56701
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "19Feb14 56701 Conversion of labutils to WPharmacyLog"
   
   ' Added conversion of FFLabelReport 22May14 XN 88857
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "22May14 88857 Convertsion of FFLabel reports"
   
   ' Added TPN Conversion radio button
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "30May14 Added TPN Conversion radio button"
   
   ' Removed protein from PN
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "9Sep14 Removed protein from PN"
   
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "12Nov14 103883 Update convertion of supplier, and ward tock to new tables WSupplier2, WCustomer, WWardProductList, and WWardProductListLine"
      
   
   ' Added TPN Conversion radio button
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "11Nov14 53175 Invalid length error ExtraSupplerData"
            
   ' Added Negative and GainLoss log
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "07Apr16 123082 Added Negative and GainLoss log"
   
   ' Added RTF/Crystal/license conversion for Hosted
   lblVersion.Caption = lblVersion.Caption + vbCrLf + "01Jan17 152189 Added RTF/Crystal/license conversion"
   
   ' Only show PN product code, and rule number text boxes if in DSS mode 15Jul13 XN 35617
   lbPNProductCode.Visible = gDSS
   lbPNRuleNumber.Visible = gDSS
   txtPNProductCode.Visible = gDSS
   txtPNRuleNumber.Visible = gDSS
   
   '02Nov11 CKJ Now uses app version instead of hand edited caption property
   Me.Caption = Me.Caption & App.Major & "." & App.Minor & "." & App.Revision
   
   On Error GoTo 0
   
Exit Sub

ErrorHandler:
   
   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   
   MsgBox ConvertErrorToBrokenRulesXML(udtError), vbOKOnly, "Error"
   
   Resume Next
   
End Sub

Private Sub Form_Unload(Cancel As Integer)

   On Error Resume Next
   
   Unload frmHospital
   
   Unload frmProgress
   
   On Error GoTo 0
   
End Sub


Private Sub optConv_Click(index As Integer)

Dim lngLoop As Long

   mboolIgnoreClicks = True
   
   If index <> 2 Then
      For lngLoop = chkopts.LBound To chkopts.UBound
         chkopts(lngLoop).value = vbUnchecked
      Next
   End If
   
   Select Case index
      Case 0   'Stores
         chkopts(0).value = vbChecked
         chkopts(1).value = vbChecked
         chkopts(5).value = vbChecked
         chkopts(9).value = vbChecked
         chkopts(10).value = vbChecked
         chkopts(11).value = vbChecked
         chkopts(14).value = vbChecked
         chkopts(16).value = vbChecked
      Case 1   'Dispensary
         chkopts(0).value = vbChecked
         chkopts(1).value = vbChecked
         chkopts(2).value = vbChecked
         chkopts(3).value = vbChecked
         chkopts(4).value = vbChecked
         chkopts(6).value = vbChecked
         chkopts(7).value = vbChecked
         chkopts(12).value = vbChecked
         chkopts(13).value = vbChecked
         chkopts(15).value = vbChecked
         For lngLoop = 17 To 22                 '18-22 TPN
            chkopts(lngLoop).value = vbChecked
         Next
         chkopts(24).value = vbChecked
         chkopts(25).value = vbChecked
         chkopts(26).value = vbChecked
      Case 2   'Stores & Dispensary
         For lngLoop = chkopts.LBound To chkopts.UBound
            chkopts(lngLoop).value = vbChecked
         Next
         chkopts(8).value = vbUnchecked
      Case 3 ' TPN XN 20/05/2014    92190
         chkopts(0).value = vbChecked
         chkopts(18).value = vbChecked
         chkopts(19).value = vbChecked
         chkopts(20).value = vbChecked
         chkopts(21).value = vbChecked
         chkopts(22).value = vbChecked
      Case 4   'Rx Logs
         chkopts(8).value = vbChecked
   End Select
   
   mboolIgnoreClicks = False
   
End Sub


Private Sub chkopts_Click(index As Integer)
'----------------------------------------------------------------------------------
'
' Purpose: Called when user checks one of the data conversion options
'          If item is TPN Product, or TPN Rule, and in DSS mode then enable PN Product
'          Code,and Rule number text boxes (allows dss to convert single rules and products)
'
' Inputs:
'
' Outputs:
'
'
' Modification History:
'  15Jul13 XN  Written (TFS 35617)
'
'----------------------------------------------------------------------------------
    Dim tagName As String
        
    Select Case LCase$(chkopts(index).Tag)
    Case "pnproductcode" ' PN Product Code
        If gDSS Then
            txtPNProductCode.Enabled = (chkopts(index).value = vbChecked)
            lbPNProductCode.Enabled = (chkopts(index).value = vbChecked)
        End If
    Case "pnrulenumber" ' PN Rule Number
        If gDSS Then
            txtPNRuleNumber.Enabled = (chkopts(index).value = vbChecked)
            lbPNRuleNumber.Enabled = (chkopts(index).value = vbChecked)
        End If
    End Select
End Sub


Private Sub timerProgress_Timer()
'----------------------------------------------------------------------------------
'
' Purpose: Stops the timer and sets the UpdateProgress flag
'
' Inputs:
'
' Outputs:
'
'
' Modification History:
'  02Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "timerProgress_Timer"

Dim udtError As udtErrorState
   


   On Error GoTo ErrorHandler

   'stop the timer
   timerProgress.Enabled = False
   
   'set the UpdateProgress flag
   UpdateProgress = True

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub
