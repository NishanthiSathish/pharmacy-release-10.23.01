Attribute VB_Name = "WEpisodeIO"
'05Nov04 CKJ Written
'21Sep09 PJC GetEpisodeToOCXHeap: Added the rs Episode to the print heap on configuration setting. (F0054530)
'19Jul10 XN  GetEpisodeToOCXHeap: F0123343 added siteID to pEpisodeSelect
'13May15 XN  Added IsEpisodeOnEMMWard 26726
'16Dec15 XN  IsEpisodeOnEMMWard: used sp rather the db function so works with web transport layer 138581
'27May16 XN  IsEpisodeOnEMMWard: 154416  changed EpisodeID to Long

Option Explicit
DefInt A-Z

Private Const OBJNAME As String = PROJECT & "WEpisodeIO."

''Function GetEpisodeDataXML(ByVal EpisodeID As Long, ByVal Parameter As String) As Variant
'''09May05 CKJ
''
''Dim str_XML As String
''Dim xmldoc As MSXML2.DOMDocument
''Dim xmlnode As MSXML2.IXMLDOMElement
''
''Dim lErrNo        As Long
''Dim sErrDesc      As String
''Dim strParameters As String
''
''   On Error GoTo ErrHandler
''
''   strParameters = gTransport.CreateInputParameterXML("EpisodeID", trnDataTypeint, 4, EpisodeID)
''   str_XML = gTransport.ExecuteSelectStreamSP(g_SessionID, "pEpisodeXML", strParameters)
''   Set xmldoc = New MSXML2.DOMDocument
''   xmldoc.loadXML str_XML
''   Set xmlnode = xmldoc.selectSingleNode("Episode")
''   GetEpisodeDataXML = xmlnode.getAttribute(Parameter)
''
''Cleanup:
''   On Error Resume Next
''   Set xmlnode = Nothing
''   Set xmldoc = Nothing
''   On Error GoTo 0
''   If lErrNo Then
''      Err.Raise lErrNo, OBJNAME & "GetEpisodeDataXML", sErrDesc
''   End If
''
''Exit Function
''
''ErrHandler:
''   lErrNo = Err.Number
''   sErrDesc = Err.Description
''   Resume Cleanup
''End Function


Function GetEpisodeDataItem(ByVal EpisodeID As Long, ByVal Parameter As String) As Variant
'09May05 CKJ

Dim rs As ADODB.Recordset

Dim lErrNo        As Long
Dim sErrDesc      As String
Dim strParameters As String

   On Error GoTo ErrHandler

   strParameters = gTransport.CreateInputParameterXML("EpisodeID", trnDataTypeint, 4, EpisodeID)
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pEpisodeSelect", strParameters)
   GetEpisodeDataItem = RtrimGetField(rs.Fields(Parameter))
   
Cleanup:
   On Error Resume Next
   Set rs = Nothing
   On Error GoTo 0
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & "GetEpisodeDataItem", sErrDesc
   End If
      
Exit Function

ErrHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   Resume Cleanup
End Function


Sub GetEpisodeToOCXHeap(ByVal EpisodeID As Long, ByVal SiteID as Long)
'09May05 CKJ
'21Sep09 PJC Added the rs Episode to the print heap on configuration setting. (F0054530)

Dim rs As ADODB.Recordset

Dim lErrNo        As Long
Dim sErrDesc      As String
Dim strParameters As String

   On Error GoTo ErrHandler

   strParameters = gTransport.CreateInputParameterXML("EpisodeID", trnDataTypeint, 4, EpisodeID) + _
   				   gTransport.CreateInputParameterXML("SiteID",    trnDataTypeint, 4, SiteID)   
   Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pEpisodeSelect", strParameters)
   If rs.RecordCount > 0 Then
      CastRecordsetToHeap rs, g_OCXheapID, False '03Mar14 TH Added param
      If TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "N", "PutEpisodeOnPrintHeap", 0)) Then   '21Sep09 PJC Added Episode RS to print heap. F0054530
         CastRecordsetToHeap rs, gPRNheapID, False '03Mar14 TH Added Param
      End If                                                                                    '     "        "
   End If
  
Cleanup:
   On Error Resume Next
   Set rs = Nothing
   On Error GoTo 0
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & "GetEpisodeToOCXHeap", sErrDesc
   End If
      
Exit Sub

ErrHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
   Resume Cleanup
End Sub


Function GetEpisodeFromRequest(ByVal RequestID As Long) As Long
'27May05 CKJ
'23Jun09 CKJ added val()

Dim str_XML As String
Dim xmldoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMElement

Dim lErrNo        As Long
Dim sErrDesc      As String
Dim strParameters As String

   On Error GoTo ErrHandler

   strParameters = gTransport.CreateInputParameterXML("RequestID", trnDataTypeint, 4, RequestID) & _
      gTransport.CreateOutputParameterXML("EpisodeID", trnDataTypeint, 4)
   str_XML = gTransport.ExecuteSelectOutputSP(g_SessionID, "pEpisodeOrderEpisode", strParameters)
   
   Set xmldoc = New MSXML2.DOMDocument
   xmldoc.loadXML str_XML
   Set xmlnode = xmldoc.selectSingleNode("//Parameters")
   GetEpisodeFromRequest = Val(xmlnode.getAttribute("EpisodeID"))   '23Jun09 CKJ added val()
      
Cleanup:
   On Error Resume Next
   Set xmlnode = Nothing
   Set xmldoc = Nothing
   On Error GoTo 0
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & "GetEpisodeFromRequest", sErrDesc
   End If
Exit Function
      
ErrHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup

End Function

'Function IsEpisodeOnEMMWard(ByVal EpisodeID) As Boolean
Function IsEpisodeOnEMMWard(ByVal EpisodeID AS Long) As Boolean
'13May15 XN  Added 26726
'16Dec15 XN  used sp rather the db function so works with web transport layer 138581
'27May16 XN  154416  changed EpisodeID to Long

Dim lErrNo        As Long
Dim sErrDesc      As String
Dim strParameters As String

   On Error GoTo ErrHandler

   strParameters = gTransport.CreateInputParameterXML("EpisodeID", trnDataTypeint, 4, EpisodeID)
   IsEpisodeOnEMMWard = gTransport.ExecuteSelectReturnSP(g_SessionID, "pPatientIsOneMMWard", strParameters)
      
Cleanup:
   On Error Resume Next
   On Error GoTo 0
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & "IsEpisodeOnEMMWard", sErrDesc
   End If
Exit Function
      
ErrHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup

End Function
