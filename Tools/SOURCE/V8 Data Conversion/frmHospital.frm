VERSION 5.00
Begin VB.Form frmHospital 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Select Ward Parent Location"
   ClientHeight    =   1230
   ClientLeft      =   2760
   ClientTop       =   3750
   ClientWidth     =   6030
   Icon            =   "frmHospital.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1230
   ScaleWidth      =   6030
   ShowInTaskbar   =   0   'False
   Begin VB.ComboBox cmbHospitals 
      Height          =   315
      Left            =   270
      TabIndex        =   2
      Text            =   "cmdHospitals"
      Top             =   180
      Width           =   4095
   End
   Begin VB.CommandButton CancelButton 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   4680
      TabIndex        =   1
      Top             =   600
      Width           =   1215
   End
   Begin VB.CommandButton OKButton 
      Caption         =   "OK"
      Height          =   375
      Left            =   4680
      TabIndex        =   0
      Top             =   120
      Width           =   1215
   End
End
Attribute VB_Name = "frmHospital"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
DefInt A-Z

'----------------------------------------------------------------------------------
'
' Purpose:
'
'
' Modification History:
'  17Jan06 EAC  Written
'
'----------------------------------------------------------------------------------
Const CLASS_NAME = "frmHospital"

Private mboolSelect As Boolean



Private Function GetLocations(ByVal lngSessionID As Long, _
                              ByVal strDbConn As String, _
                              ByVal lngLocationTypeID As Long) As String
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
'  17Jan06 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetLocationType"

Dim udtError As udtErrorState
                                     
Dim adoCmd As ADODB.Command
Dim adoConn As ADODB.Connection
Dim adoStm As ADODB.Stream


   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   Set adoStm = New ADODB.Stream
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pLocationListByTypeXML"
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationtypeid", adInteger, adParamInput, 4, lngLocationTypeID)
      
      .Properties("Output Stream").value = adoStm
      adoStm.open
      .Execute , , adExecuteStream
      adoConn.Close
   End With
   

   GetLocations = adoStm.ReadText

Cleanup:

   On Error Resume Next
   If Not adoStm Is Nothing Then
      adoStm.Close
      Set adoStm = Nothing
   End If
   
   If Not adoConn Is Nothing Then
      If adoConn.State = adStateOpen Then adoConn.Close
      Set adoConn = Nothing
   End If
   
   If Not adoCmd Is Nothing Then
      Set adoCmd.ActiveConnection = Nothing
      Set adoCmd = Nothing
   End If
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function
Private Function GetLocationType(ByVal lngSessionID As Long, _
                                 ByVal strDbConn As String) As Long
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
'  17Jan06 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetLocationType"

Dim udtError As udtErrorState
                                     
Dim adoCmd As ADODB.Command
Dim adoConn As ADODB.Connection


   On Error GoTo ErrorHandler

   Set adoConn = New ADODB.Connection
   adoConn.ConnectionString = strDbConn
   adoConn.open
   
   Set adoCmd = New ADODB.Command
   
   With adoCmd
      Set .ActiveConnection = adoConn
      .CommandType = adCmdStoredProc
      .CommandText = "pLocationTypeIDFromDescription"
      .Parameters.Append .CreateParameter("@Return", adInteger, adParamReturnValue)
      .Parameters.Append .CreateParameter("sessionid", adInteger, adParamInput, 4, lngSessionID)
      .Parameters.Append .CreateParameter("locationtype", adVarChar, adParamInput, 128, "System")
      
      .Execute , , adExecuteNoRecords
      adoConn.Close
   
      GetLocationType = .Parameters("@Return").value
   End With
   
Cleanup:

   On Error Resume Next
   If Not adoConn Is Nothing Then
      If adoConn.State = adStateOpen Then adoConn.Close
      Set adoConn = Nothing
   End If
   
   If Not adoCmd Is Nothing Then
      Set adoCmd.ActiveConnection = Nothing
      Set adoCmd = Nothing
   End If
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Public Function GetWardParentLocationID(ByVal lngSessionID As Long, _
                                        ByVal strDbConn As String, _
                                        ByRef lngLocationID_Parent As Long) As String
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
'  17Jan06 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetWardParentLocationID"

Dim udtError As udtErrorState
                                         
Dim strReturn As String


   On Error GoTo ErrorHandler

   strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML("", "No parent location selected for Supplier conversoion."))
   lngLocationID_Parent = -1
   
   LoadCombo lngSessionID, _
             strDbConn
   
   Screen.MousePointer = vbNormal
   
   Me.Show vbModal
   
   Screen.MousePointer = vbHourglass
   
   If mboolSelect Then
      If cmbHospitals.ListIndex > -1 Then
         lngLocationID_Parent = cmbHospitals.ItemData(cmbHospitals.ListIndex)
         strReturn = vbNullString
      End If
   End If

Cleanup:

   GetWardParentLocationID = strReturn
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Private Sub LoadCombo(ByVal lngSessionID As Long, _
                      ByVal strDbConn As String)
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
'  17Jan06 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "LoadCombo"

Dim udtError As udtErrorState

Dim objDOM As MSXML2.DOMDocument
Dim objNode As MSXML2.IXMLDOMNode

Dim lngLocationTypeID As Long

Dim strXML As String


   On Error GoTo ErrorHandler
   
   lngLocationTypeID = GetLocationType(lngSessionID, _
                                       strDbConn)
   
   If lngLocationTypeID > -1 Then
   
      cmbHospitals.Clear
      strXML = GetLocations(lngSessionID, _
                            strDbConn, _
                            lngLocationTypeID)
                            
      Set objDOM = New MSXML2.DOMDocument
      With objDOM
         .loadXML "<root>" & strXML & "</root>"
         
         For Each objNode In .documentElement.selectNodes("Location")
            cmbHospitals.AddItem objNode.Attributes.getNamedItem("Description").Text
            cmbHospitals.ItemData(cmbHospitals.ListCount - 1) = Val(objNode.Attributes.getNamedItem("LocationID").Text)
         Next
      End With
      
      If cmbHospitals.ListCount > 0 Then cmbHospitals.ListIndex = 0
   End If
   
Cleanup:

   On Error Resume Next
   
   Set objDOM = Nothing
   Set objNode = Nothing

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub


Private Sub CancelButton_Click()
   
   mboolSelect = False
   Me.Hide
   
End Sub

Private Sub OKButton_Click()

   mboolSelect = True
   Me.Hide
   
End Sub


