VERSION 5.00
Begin VB.Form frmUpdateServiceView 
   Appearance      =   0  'Flat
   BackColor       =   &H80000004&
   Caption         =   "Update Stock View"
   ClientHeight    =   6975
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   14685
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   6975
   ScaleWidth      =   14685
   StartUpPosition =   3  'Windows Default
   Begin VB.CheckBox chkLocalCanUseSpoon 
      Height          =   495
      Left            =   7680
      TabIndex        =   36
      Top             =   4800
      Width           =   255
   End
   Begin VB.CheckBox chkAscribeCanUseSpoon 
      Enabled         =   0   'False
      Height          =   495
      Left            =   2880
      TabIndex        =   35
      Top             =   4800
      Width           =   255
   End
   Begin VB.CheckBox chkCanUseSpoon 
      Height          =   495
      Left            =   13320
      TabIndex        =   33
      Top             =   4800
      Width           =   255
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "Cancel"
      Height          =   375
      Left            =   13080
      TabIndex        =   17
      Top             =   6360
      Width           =   1215
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "OK"
      Default         =   -1  'True
      Height          =   375
      Left            =   11640
      TabIndex        =   16
      Top             =   6360
      Width           =   1215
   End
   Begin VB.CheckBox chkStoresDescription 
      Height          =   495
      Left            =   13320
      TabIndex        =   12
      Top             =   2880
      Width           =   255
   End
   Begin VB.CheckBox chkWarningCode 
      Height          =   495
      Left            =   13320
      TabIndex        =   13
      Top             =   3360
      Width           =   255
   End
   Begin VB.CheckBox chkSecondaryWarningCode 
      Height          =   495
      Left            =   13320
      TabIndex        =   14
      Top             =   3840
      Width           =   255
   End
   Begin VB.CheckBox chkInstructionCode 
      Height          =   495
      Left            =   13320
      TabIndex        =   15
      Top             =   4320
      Width           =   255
   End
   Begin VB.CheckBox chkDescription 
      Height          =   495
      Left            =   13320
      TabIndex        =   11
      Top             =   2400
      Width           =   255
   End
   Begin VB.TextBox txtLocalInstructionCode 
      Height          =   315
      Left            =   7680
      Locked          =   -1  'True
      TabIndex        =   10
      Top             =   4440
      Width           =   1455
   End
   Begin VB.TextBox txtLocalSecondaryWarningCode 
      Height          =   315
      Left            =   7680
      Locked          =   -1  'True
      TabIndex        =   9
      Top             =   3960
      Width           =   1455
   End
   Begin VB.TextBox txtLocalWarningCode 
      Height          =   315
      Left            =   7680
      Locked          =   -1  'True
      TabIndex        =   8
      Top             =   3480
      Width           =   1455
   End
   Begin VB.TextBox txtLocalStoresDescription 
      Height          =   315
      Left            =   7680
      TabIndex        =   7
      Top             =   3000
      Width           =   4575
   End
   Begin VB.TextBox txtLocalDescription 
      Height          =   315
      Left            =   7680
      TabIndex        =   6
      Top             =   2520
      Width           =   4575
   End
   Begin VB.TextBox txtAscribeInstructionCode 
      Height          =   315
      Left            =   2880
      Locked          =   -1  'True
      TabIndex        =   5
      Top             =   4440
      Width           =   1455
   End
   Begin VB.TextBox txtAscribeSecondaryWarningCode 
      Height          =   315
      Left            =   2880
      Locked          =   -1  'True
      TabIndex        =   4
      Top             =   3960
      Width           =   1455
   End
   Begin VB.TextBox txtAscribeWarningCode 
      Height          =   315
      Left            =   2880
      Locked          =   -1  'True
      TabIndex        =   3
      Top             =   3480
      Width           =   1455
   End
   Begin VB.TextBox txtAscribeStoresDescription 
      Height          =   315
      Left            =   2880
      Locked          =   -1  'True
      MaxLength       =   56
      TabIndex        =   2
      Top             =   3000
      Width           =   4575
   End
   Begin VB.TextBox txtAscribeDescription 
      Height          =   315
      Left            =   2880
      Locked          =   -1  'True
      MaxLength       =   56
      TabIndex        =   1
      Top             =   2520
      Width           =   4575
   End
   Begin VB.Label lblCanUseSpoon 
      Caption         =   "Can Use Spoon"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   480
      TabIndex        =   34
      Top             =   4920
      Width           =   2295
   End
   Begin VB.Label lblInstructions 
      Caption         =   $"UpdateServiceView.frx":0000
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   -1  'True
         Strikethrough   =   0   'False
      EndProperty
      Height          =   735
      Left            =   480
      TabIndex        =   32
      Top             =   5400
      Width           =   8655
   End
   Begin VB.Label lblShiftF1ForList 
      Caption         =   "Shift-F1 for list"
      Height          =   255
      Index           =   2
      Left            =   9960
      TabIndex        =   31
      Top             =   4440
      Width           =   1215
   End
   Begin VB.Label lblShiftF1ForList 
      Caption         =   "Shift-F1 for list"
      Height          =   255
      Index           =   1
      Left            =   9960
      TabIndex        =   30
      Top             =   3960
      Width           =   1215
   End
   Begin VB.Label lblShiftF1ForList 
      Caption         =   "Shift-F1 for list"
      Height          =   255
      Index           =   0
      Left            =   9960
      TabIndex        =   29
      Top             =   3480
      Width           =   1215
   End
   Begin VB.Label lblLockLocalVersion 
      Caption         =   "Lock Local Version"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   12600
      TabIndex        =   28
      Top             =   2040
      Width           =   1815
   End
   Begin VB.Label lblLocalVersion 
      Alignment       =   2  'Center
      Caption         =   "Local Version"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   7680
      TabIndex        =   27
      Top             =   2040
      Width           =   4575
   End
   Begin VB.Label lblAscribeVersion 
      Alignment       =   2  'Center
      Caption         =   "DSS Version"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   2880
      TabIndex        =   26
      Top             =   2040
      Width           =   4575
   End
   Begin VB.Label lblInstructionCode 
      Caption         =   "Instruction Code"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   480
      TabIndex        =   25
      Top             =   4440
      Width           =   2295
   End
   Begin VB.Label lblSecondaryWarningCode 
      Caption         =   "Secondary Warning Code"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   480
      TabIndex        =   24
      Top             =   3960
      Width           =   2295
   End
   Begin VB.Label lblWarningCode 
      Caption         =   "Warning Code"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   480
      TabIndex        =   23
      Top             =   3480
      Width           =   2295
   End
   Begin VB.Label lblStoresDescription 
      Caption         =   "Stores Description"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   480
      TabIndex        =   22
      Top             =   3000
      Width           =   2295
   End
   Begin VB.Label lblDescription 
      Caption         =   "Description"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   480
      TabIndex        =   21
      Top             =   2520
      Width           =   2295
   End
   Begin VB.Label lblLookupCode 
      Height          =   255
      Left            =   1800
      TabIndex        =   20
      Top             =   960
      Width           =   1815
   End
   Begin VB.Label lblLookupCodeLabel 
      Caption         =   "Lookup Code"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   480
      TabIndex        =   19
      Top             =   960
      Width           =   1215
   End
   Begin VB.Label lblNSVCode 
      Height          =   255
      Left            =   1800
      TabIndex        =   18
      Top             =   480
      Width           =   1815
   End
   Begin VB.Label lblNSVCodeLabel 
      Caption         =   "NSV Code"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   480
      TabIndex        =   0
      Top             =   480
      Width           =   1215
   End
End
Attribute VB_Name = "frmUpdateServiceView"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'22oct08 AK Created. To display site specific SiteProductData against the DSS Master version anda allow the local version to be edited
'           and then locked to prevent overwriting from the DSS Version. (F0018781)
'10May12 XN Added CanUseSpoon lock TFS33227
'           Save: Save CanUseSpoon, CanUseSpoon_Locked field values from ui to db TFS33227
'           Load: Load CanUseSpoon, CanUseSpoon_Locked field from db to ui        TFS33227

Option Explicit
DefBool A-Z

Private Sub cmdCancel_Click()
'22oct08 AK Process the click event of the cancel button to close the form without saving (F0018781)
    
   Unload Me

End Sub

Private Sub cmdOK_Click()
'22oct08 AK Process the click event of the OK button to save the form and unload if sucessful (F0018781)
    
   If Save = True Then
      Unload Me
   Else
      MsgBox "Errors encountered during save", vbCritical + vbOKOnly, "Save Error"
   End If
    
End Sub

Private Sub Form_Load()
'22oct08 AK Format the form with SetChrome and load the data (F0018781)
    
   SetChrome Me
   Load
    
End Sub

Private Function ValidateForm() As Boolean
'22oct08 AK Validate the data on the form to ensure a save will be processed correctly (F0018781)

   On Error GoTo ErrorHandler
   
   ValidateForm = False
   If Len(txtLocalDescription.text) > 56 Then
      MsgBox "The maximum length allowed for the description is 56 characters.", vbInformation, "Description - maximum length exceeded"
      txtLocalDescription.SetFocus
      Exit Function
   End If
   If Len(txtLocalStoresDescription.text) > 56 Then
      MsgBox "The maximum length allowed for the stores description is 56 characters.", vbInformation, "Stores Description - maximum length exceeded"
      txtLocalStoresDescription.SetFocus
      Exit Function
   End If
   ValidateForm = True
   
Cleanup:
   On Error GoTo 0
Exit Function
   
ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup

End Function

Private Function Save() As Boolean
'22oct08 AK Save the data on the form after calling a successful validate (F0018781)
'10May12 XN Save CanUseSpoon, CanUseSpoon_Locked field values from ui to db TFS33227
Dim strParams As String
Dim blnSuccess As Long

   On Error GoTo ErrorHandler
   Save = False
   If ValidateForm Then
      strParams = "" _
         & gTransport.CreateInputParameterXML("SiteProductDataID", trnDataTypeint, 4, d.SiteProductDataID) _
         & gTransport.CreateInputParameterXML("labeldescription", trnDataTypeVarChar, 56, txtLocalDescription.text) _
         & gTransport.CreateInputParameterXML("storesdescription", trnDataTypeVarChar, 56, txtLocalStoresDescription.text) _
         & gTransport.CreateInputParameterXML("warcode", trnDataTypeVarChar, 6, txtLocalWarningCode.text) _
         & gTransport.CreateInputParameterXML("warcode2", trnDataTypeVarChar, 6, txtLocalSecondaryWarningCode.text) _
         & gTransport.CreateInputParameterXML("inscode", trnDataTypeVarChar, 6, txtLocalInstructionCode.text) _
         & gTransport.CreateInputParameterXML("CanUseSpoon", trnDataTypeBit, 1, chkLocalCanUseSpoon.Value) _
         & gTransport.CreateInputParameterXML("warcode_Locked", trnDataTypeBit, 1, chkWarningCode.Value) _
         & gTransport.CreateInputParameterXML("warcode2_Locked", trnDataTypeBit, 1, chkSecondaryWarningCode.Value) _
         & gTransport.CreateInputParameterXML("inscode_Locked", trnDataTypeBit, 1, chkInstructionCode.Value) _
         & gTransport.CreateInputParameterXML("StoresDescription_Locked", trnDataTypeBit, 1, chkStoresDescription.Value) _
         & gTransport.CreateInputParameterXML("LabelDescription_Locked", trnDataTypeBit, 1, chkDescription.Value) _
         & gTransport.CreateInputParameterXML("CanUseSpoon_Locked", trnDataTypeBit, 1, chkCanUseSpoon.Value) _
         & gTransport.CreateInputParameterXML("labeldescriptionOriginal", trnDataTypeVarChar, 56, Trim(d.LabelDescription)) _
         & gTransport.CreateInputParameterXML("storesdescriptionOriginal", trnDataTypeVarChar, 56, Trim(d.storesdescription)) _
         & gTransport.CreateInputParameterXML("warcodeOriginal", trnDataTypeVarChar, 6, Trim(d.warcode)) _
         & gTransport.CreateInputParameterXML("warcode2Original", trnDataTypeVarChar, 6, Trim(d.warcode2))
      strParams = strParams _
         & gTransport.CreateInputParameterXML("inscodeOriginal", trnDataTypeVarChar, 6, Trim(d.inscode)) _
         & gTransport.CreateInputParameterXML("CanUseSpoonOriginal", trnDataTypeBit, 6, d.CanUseSpoon) _
         & gTransport.CreateInputParameterXML("warcode_LockedOriginal", trnDataTypeBit, 1, d.warcode_Locked) _
         & gTransport.CreateInputParameterXML("warcode2_LockedOriginal", trnDataTypeBit, 1, d.warcode2_Locked) _
         & gTransport.CreateInputParameterXML("inscode_LockedOriginal", trnDataTypeBit, 1, d.inscode_Locked) _
         & gTransport.CreateInputParameterXML("StoresDescription_LockedOriginal", trnDataTypeBit, 1, d.storesdescription_Locked) _
         & gTransport.CreateInputParameterXML("LabelDescription_LockedOriginal", trnDataTypeBit, 1, d.LabelDescription_Locked) _
         & gTransport.CreateInputParameterXML("CanUseSpoon_LockedOriginal", trnDataTypeBit, 1, d.CanUseSpoon_Locked)
      blnSuccess = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pSiteProductDataUpdateForLockableFields", strParams)
      
      If blnSuccess Then
         d.LabelDescription = txtLocalDescription.text   'd.Description = txtLocalDescription.text XN 4Jun15 98073 New local stores description
         d.storesdescription = txtLocalStoresDescription.text
         d.warcode = txtLocalWarningCode.text
         d.warcode2 = txtLocalSecondaryWarningCode.text
         d.inscode = txtLocalInstructionCode.text
         d.CanUseSpoon = chkLocalCanUseSpoon.Value              '10May12 XN Added CanUseSpoon lock field TFS33227
         d.warcode_Locked = chkWarningCode.Value
         d.warcode2_Locked = chkSecondaryWarningCode.Value
         d.inscode_Locked = chkInstructionCode.Value
         d.LabelDescription_Locked = chkDescription.Value		' d.Description_Locked = chkDescription.Value XN 4Jun15 98073 New local stores description
         d.storesdescription_Locked = chkStoresDescription.Value
         d.CanUseSpoon_Locked = chkCanUseSpoon.Value            '10May12 XN Added CanUseSpoon lock field TFS33227
         Save = True
      End If
   End If

Cleanup:
   On Error GoTo 0
Exit Function

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup

End Function

Private Sub Load()
'22oct08 AK Load the form data from the d object and close the form if any error arrises (F0018781)
'10May12 XN Load CanUseSpoon, CanUseSpoon_Locked field from db to ui        TFS33227
Dim strParams As String
Dim rsMaster As ADODB.Recordset
Dim intErrNumber As Integer
Dim strErrorDesc As String

   On Error GoTo ErrorHandler
   txtAscribeDescription.BackColor = &HFFE3D6
   txtAscribeStoresDescription.BackColor = &HFFE3D6
   txtAscribeWarningCode.BackColor = &HFFE3D6
   txtAscribeSecondaryWarningCode.BackColor = &HFFE3D6
   txtAscribeInstructionCode.BackColor = &HFFE3D6
   chkAscribeCanUseSpoon.BackColor = &HFFE3D6               '10May12 XN Added CanUseSpoon lock field TFS33227
   
   strParams = gTransport.CreateInputParameterXML("DrugID", trnDataTypeint, 4, d.DrugID)
   Set rsMaster = gTransport.ExecuteSelectSP(g_SessionID, "pGetMasterSiteProductDataByDrugID", strParams)
   If Not rsMaster.EOF = True Then
      txtAscribeDescription.text = GetField(rsMaster!labeldescription)
      txtAscribeStoresDescription.text = GetField(rsMaster!storesdescription)
      txtAscribeWarningCode.text = GetField(rsMaster!warcode)
      txtAscribeSecondaryWarningCode.text = GetField(rsMaster!warcode2)
      txtAscribeInstructionCode.text = GetField(rsMaster!inscode)
      If GetField(rsMaster!CanUseSpoon) = True Then chkAscribeCanUseSpoon.Value = vbChecked     '10May12 XN Added CanUseSpoon lock field TFS33227
   End If
   txtLocalDescription.text = Trim(d.LabelDescription)	' txtLocalDescription.text = Trim(d.Description) XN 4Jun15 98073 New local stores description
   txtLocalStoresDescription.text = Trim(d.storesdescription)
   txtLocalWarningCode.text = Trim(d.warcode)
   txtLocalSecondaryWarningCode.text = Trim(d.warcode2)
   txtLocalInstructionCode.text = Trim(d.inscode)
   If d.CanUseSpoon = True Then chkLocalCanUseSpoon.Value = vbChecked                           '10May12 XN Added CanUseSpoon lock field TFS33227
   If d.LabelDescription_Locked = True Then chkDescription.Value = vbChecked				' If d.Description_Locked = True Then chkDescription.Value = vbChecked XN 4Jun15 98073 New local stores description
   If d.storesdescription_Locked = True Then chkStoresDescription.Value = vbChecked
   If d.warcode_Locked = True Then chkWarningCode.Value = vbChecked
   If d.warcode2_Locked = True Then chkSecondaryWarningCode.Value = vbChecked
   If d.inscode_Locked = True Then chkInstructionCode.Value = vbChecked
   If d.CanUseSpoon_Locked = True Then chkCanUseSpoon.Value = vbChecked                         '10May12 XN Added CanUseSpoon lock field TFS33227
   lblNSVCode.Caption = Trim(d.SisCode)
   lblLookupCode.Caption = Trim(d.Code)

Cleanup:
   If Not rsMaster Is Nothing Then
      If rsMaster.State = adStateOpen Then rsMaster.Close
      Set rsMaster = Nothing
   End If
   If intErrNumber > 0 Then
      MsgBox strErrorDesc, vbCritical + vbOKOnly, CStr(intErrNumber)
      On Error GoTo 0
      Unload Me
   End If
Exit Sub

ErrorHandler:
   intErrNumber = Err.Number
   strErrorDesc = Err.Description
Resume Cleanup

End Sub


Private Sub txtLocalInstructionCode_KeyUp(KeyCode As Integer, Shift As Integer)
'22oct08 AK Capture a Shift-F1 to load instructions code selection list and return to the control (F0018781)
Dim strCode As String
Dim strExpn As String
Dim intEscaped As Integer

   On Error GoTo ErrorHandler
   
   If KeyCode = KEY_F1 And Shift = SHIFT_MASK Then
      ListInstructions strCode, strExpn, intEscaped
      If intEscaped <> 1 Then
      If strCode = Chr$(161) Then strCode = ""
      txtLocalInstructionCode.text = strCode
      End If
   End If

Cleanup:
   On Error GoTo 0
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup

End Sub

Private Sub txtLocalInstructionCode_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'23oct08 AK Load instruction code expansion into textbox tooltip (F0018781)
Dim strText As String

   On Error GoTo ErrorHandler

   If Len(txtLocalInstructionCode.text) > 0 Then
      GetInsCode txtLocalInstructionCode.text, strText
      txtLocalInstructionCode.ToolTipText = strText
   End If

Cleanup:
   On Error GoTo 0
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup

End Sub

Private Sub txtAscribeSecondaryWarningCode_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'23Oct08 AK Load warning code expansion into textbox tooltip (F0018781)
Dim strText As String

   On Error GoTo ErrorHandler

   If Len(txtAscribeSecondaryWarningCode.text) > 0 Then
      GetWarCode txtAscribeSecondaryWarningCode.text, strText
      txtAscribeSecondaryWarningCode.ToolTipText = strText
   End If

Cleanup:
   On Error GoTo 0
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup

End Sub

Private Sub txtAscribeInstructionCode_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'23Oct08 AK Load instruction code expansion into textbox tooltip (F0018781)
Dim strText As String

   On Error GoTo ErrorHandler

   If Len(txtAscribeInstructionCode.text) > 0 Then
      GetInsCode txtAscribeInstructionCode.text, strText
      txtAscribeInstructionCode.ToolTipText = strText
   End If

Cleanup:
   On Error GoTo 0
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup

End Sub

Private Sub txtLocalSecondaryWarningCode_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'23Oct08 AK Load warning code expansion into textbox tooltip (F0018781)
Dim strText As String

   On Error GoTo ErrorHandler

   If Len(txtLocalSecondaryWarningCode.text) > 0 Then
      GetWarCode txtLocalSecondaryWarningCode.text, strText
      txtLocalSecondaryWarningCode.ToolTipText = strText
   End If

Cleanup:
   On Error GoTo 0
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup

End Sub

Private Sub txtLocalWarningCode_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'23Oct08 AK Load warning code expansion into textbox tooltip (F0018781)
Dim strText As String

   On Error GoTo ErrorHandler

   If Len(txtLocalWarningCode.text) > 0 Then
      GetWarCode txtLocalWarningCode.text, strText
      txtLocalWarningCode.ToolTipText = strText
   End If

Cleanup:
   On Error GoTo 0
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup

End Sub

Private Sub txtAscribeWarningCode_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'23Oct08 AK Load warning code expansion into textbox tooltip (F0018781)
Dim strText As String

   On Error GoTo ErrorHandler

   If Len(txtAscribeWarningCode.text) > 0 Then
      GetWarCode txtAscribeWarningCode.text, strText
      txtAscribeWarningCode.ToolTipText = strText
   End If

Cleanup:
   On Error GoTo 0
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup

End Sub

Private Sub txtLocalWarningCode_KeyUp(KeyCode As Integer, Shift As Integer)
'22oct08 AKCapture a Shift-F1 to load warning code selection list and return to the control (F0018781)
Dim strCode As String
Dim strExpn As String
Dim intEscaped As Integer

   On Error GoTo ErrorHandler
   
   If KeyCode = KEY_F1 And Shift = SHIFT_MASK Then
      ListWarnings strCode, strExpn, intEscaped
      If intEscaped <> 1 Then
         If strCode = Chr$(161) Then strCode = ""
         txtLocalWarningCode.text = strCode
      End If
   End If

Cleanup:
   On Error GoTo 0
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup

End Sub

Private Sub txtLocalSecondaryWarningCode_KeyUp(KeyCode As Integer, Shift As Integer)
'22oct08 AK Capture a Shift-F1 to load warning code selection list and return to the control (F0018781)
Dim strCode As String
Dim strExpn As String
Dim intEscaped As Integer

   On Error GoTo ErrorHandler
   
   If KeyCode = KEY_F1 And Shift = SHIFT_MASK Then
      ListWarnings strCode, strExpn, intEscaped
      If intEscaped <> 1 Then
         If strCode = Chr$(161) Then strCode = ""
         txtLocalSecondaryWarningCode.text = strCode
      End If
   End If

Cleanup:
   On Error GoTo 0
Exit Sub

ErrorHandler:
   MsgBox Err.Description, vbCritical + vbOKOnly, CStr(Err.Number)
Resume Cleanup

End Sub



