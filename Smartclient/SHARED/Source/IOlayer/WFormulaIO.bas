Attribute VB_Name = "WFormulaIO"
Option Explicit
DefInt A-Z
Private Const OBJNAME As String = PROJECT & "WFormulaIO."

Public Function WLayoutUpdate(ByVal lngWLayoutID As Long, _
                              ByVal LocationID_Site As Long, _
                              ByVal lngPatientsPerSheet As Long, _
                              ByVal strLayout As String, _
                              ByVal strLineText As String, _
                              ByVal strIngLineText As String, _
                              ByVal strPrescription As String, _
                              ByVal strName As String, _
                              ByVal strStatus As String, _
                              ByVal lngLayoutVersion As Long, _
                              ByVal EntityID_Drafted As Long, _
                              ByVal EntityID_Approved As Long, _
                              ByVal DateDrafted As Date, _
                              ByVal DateApproved As Date) As Long
Dim strParams As String
Dim lngOK As Long
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "WLayoutUpdate"

   On Error GoTo ErrorHandler

   strParams = gTransport.CreateInputParameterXML("WLayoutID", trnDataTypeint, 4, lngWLayoutID) & _
               gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("PatientsPerSheet", trnDataTypeint, 4, lngPatientsPerSheet) & _
               gTransport.CreateInputParameterXML("Layout", trnDataTypeVarChar, 50, strLayout) & _
               gTransport.CreateInputParameterXML("LineText", trnDataTypeVarChar, 1024, strLineText) & _
               gTransport.CreateInputParameterXML("IngLineText", trnDataTypeVarChar, 1024, strIngLineText) & _
               gTransport.CreateInputParameterXML("Prescription", trnDataTypeVarChar, 5000, strPrescription) & _
               gTransport.CreateInputParameterXML("Name", trnDataTypeVarChar, 10, strName) & _
               gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, strStatus) & _
               gTransport.CreateInputParameterXML("EntityID_Drafted", trnDataTypeint, 4, EntityID_Drafted) & _
               gTransport.CreateInputParameterXML("EntityID_Approved", trnDataTypeint, 4, EntityID_Approved) & _
               gTransport.CreateInputParameterXML("DateDrafted", trnDataTypeDateTime, 8, DateDrafted) & _
               gTransport.CreateInputParameterXML("DateApproved", trnDataTypeDateTime, 8, DateApproved) & _
               gTransport.CreateInputParameterXML("Version", trnDataTypeint, 4, lngLayoutVersion)
   lngOK = gTransport.ExecuteUpdateSP(g_SessionID, "WLayout", strParams)
   
   
Cleanup:
   On Error Resume Next
   WLayoutUpdate = lngOK
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   On Error GoTo 0
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
End Function
Public Function WFormulaLabelUpdate(ByVal lngWFormulaID, ByVal strLabel As String) As Long
'07Aug06 Extend label field to 5000
'26Aug09 TH Now pass in user to record that someone has been altering the draft

Dim strParams As String
Dim lngOK As Long
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "WFormulaLabelUpdate"

   On Error GoTo ErrorHandler

   strParams = gTransport.CreateInputParameterXML("WLayoutID", trnDataTypeint, 4, lngWFormulaID) & _
               gTransport.CreateInputParameterXML("Label", trnDataTypeVarChar, 5000, strLabel) & _
               gTransport.CreateInputParameterXML("User", trnDataTypeVarChar, 1024, gEntityID_User)
               
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFormulaUpdateLabelByWFormulaID", strParams)
   
Cleanup:
   On Error Resume Next
   WFormulaLabelUpdate = lngOK
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   On Error GoTo 0
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
End Function
Public Function WFormulaMethodUpdate(ByVal lngWFormulaID, ByVal strMethod As String) As Long
'26Aug09 TH Now pass in user to record that someone has been altering the draft
Dim strParams As String
Dim lngOK As Long
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "WFormulaMethodUpdate"

   On Error GoTo ErrorHandler

   strParams = gTransport.CreateInputParameterXML("WLayoutID", trnDataTypeint, 4, lngWFormulaID) & _
               gTransport.CreateInputParameterXML("Method", trnDataTypeVarChar, 1024, strMethod) & _
               gTransport.CreateInputParameterXML("User", trnDataTypeVarChar, 1024, gEntityID_User)
               
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFormulaUpdateMethodByWFormulaID", strParams)
   
Cleanup:
   On Error Resume Next
   WFormulaMethodUpdate = lngOK
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   On Error GoTo 0
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
End Function

Public Function WLayoutLineTextUpdate(ByVal lngWLayoutID, ByVal strLineText As String) As Long
'26Aug09 TH Now pass in user to record that someone has been altering the draft

Dim strParams As String
Dim lngOK As Long
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "WLayoutLineTextUpdate"

   On Error GoTo ErrorHandler

   strParams = gTransport.CreateInputParameterXML("WLayoutID", trnDataTypeint, 4, lngWLayoutID) & _
               gTransport.CreateInputParameterXML("LineText", trnDataTypeVarChar, 1024, strLineText) & _
               gTransport.CreateInputParameterXML("User", trnDataTypeVarChar, 1024, gEntityID_User)
               
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWLayoutUpdateLineTextByWLayoutID", strParams)
   
Cleanup:
   On Error Resume Next
   WLayoutLineTextUpdate = lngOK
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   On Error GoTo 0
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
End Function
Public Function WLayoutIngLineTextUpdate(ByVal lngWLayoutID, ByVal strIngLineText As String) As Long
'26Aug09 TH Now pass in user to record that someone has been altering the draft

Dim strParams As String
Dim lngOK As Long
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "WLayoutIngLineTextUpdate"

   On Error GoTo ErrorHandler

   strParams = gTransport.CreateInputParameterXML("WLayoutID", trnDataTypeint, 4, lngWLayoutID) & _
               gTransport.CreateInputParameterXML("LineText", trnDataTypeVarChar, 1024, strIngLineText) & _
               gTransport.CreateInputParameterXML("User", trnDataTypeVarChar, 1024, gEntityID_User)
               
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWLayoutUpdateIngLineTextByWLayoutID", strParams)
   
Cleanup:
   On Error Resume Next
   WLayoutIngLineTextUpdate = lngOK
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   On Error GoTo 0
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
End Function

Public Function WLayoutArchive(ByVal strName As String) As Long
'26Aug09 TH Now pass in user to record that someone has been altering the draft
Dim strParams As String
Dim lngOK As Long
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "WLayoutArchive"

   On Error GoTo ErrorHandler

   strParams = gTransport.CreateInputParameterXML("strName", trnDataTypeVarChar, 50, strName) & _
               gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite)
               
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWLayoutUpdateforArchive", strParams)
   
Cleanup:
   On Error Resume Next
   WLayoutArchive = lngOK
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   On Error GoTo 0
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
End Function

Public Function WLayoutApprove(ByVal strName As String) As Long
'26Aug09 TH Now pass in user to record that someone has been altering the draft
Dim strParams As String
Dim lngOK As Long
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "WLayoutApprove"

   On Error GoTo ErrorHandler

   strParams = gTransport.CreateInputParameterXML("strName", trnDataTypeVarChar, 50, strName) & _
               gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
               
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWLayoutUpdateforApproved", strParams)
   
Cleanup:
   On Error Resume Next
   WLayoutApprove = lngOK
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   On Error GoTo 0
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
End Function

Public Function WLayoutUpdateDraft(ByVal strName As String) As Long
'26Aug09 TH Now pass in user to record that someone has been altering the draft
'17Mar10 TH Changed to use the correct sp (F0080601)
Dim strParams As String
Dim lngOK As Long
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "WLayoutUpdateDraft"

   On Error GoTo ErrorHandler

   strParams = gTransport.CreateInputParameterXML("strName", trnDataTypeVarChar, 50, strName) & _
               gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
               
   'lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWLayoutUpdateforApproved", strParams)
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWLayoutUpdateforDraft", strParams)  '17Mar10 TH Changed to use the correct sp (F0080601)
   
   
Cleanup:
   On Error Resume Next
   
   WLayoutUpdateDraft = lngOK
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   On Error GoTo 0
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
End Function

Public Function WFormulaUpdateDraft(ByVal WFormulaID As Integer) As Long
'26Aug09 TH Now pass in user to record that someone has been altering the draft
Dim strParams As String
Dim lngOK As Long
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "WFormulaUpdateDraft"

   On Error GoTo ErrorHandler

   strParams = gTransport.CreateInputParameterXML("WFormulaID", trnDataTypeint, 50, WFormulaID) & _
               gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("EntityID", trnDataTypeint, 4, gEntityID_User)
               
   lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWFormulaUpdateforApproved", strParams)
   
Cleanup:
   On Error Resume Next
   WFormulaUpdateDraft = lngOK
   On Error GoTo 0
   If ErrNumber Then Err.Raise ErrNumber, OBJNAME & ErrSource, ErrDescription
Exit Function

ErrorHandler:
   On Error GoTo 0
   ErrNumber = Err.Number
   ErrDescription = Err.Description
Resume Cleanup
End Function

