VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Encoder"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'----------------------------------------------------------------------------------
'
' Purpose: This dll takes a prescription reference in an auditlog XML string and
'          returns the prescription as V92 SOAP Schema compliant XML.
'
'
' Modification History:
'  04Jan05 EAC  Written
'
'----------------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Const CLASS_NAME = "Encoder"

Private Const trnDataTypeInt = 2

Private Const APPID_DOM_OBJECT = "MSXML2.DOMDocument"

Private Const XML_INVALID_CODE = vbObjectError + 1004
Private Const XML_INVALID_DESC = "The provided XML string failed validation against the schema."


'Registry declares
Private mboolConfigRead As Boolean

Private mstrINFRTLAppID As String
Private mstrOCSRTLAppID As String
Private mstrIENRTLAppId As String
Private Function ReadAttachedNoteLinkTable(ByVal lngSessionID As Long, _
                                           ByVal lngAttachedNoteID As Long, _
                                           ByRef lngRxID As Long, _
                                           ByRef lngTableID As Long) As String
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
'  24Feb05 EAC  Written
'
'----------------------------------------------------------------------------------

Const REQUEST_SP_NAME = "pRequestLinkAttachedNoteXML"
Const SUB_NAME = "ReadAttachedNoteLinkTable"
Const TABLE_SP_NAME = "pRequestXML"

Dim udtError As udtErrorState
                                           
Dim objDOM As MSXML2.DOMDocument
Dim objINF As Object 'TRNRTL10.Transport

Dim strParamXML As String
Dim strReturn As String

   On Error GoTo ErrorHandler

   lngRxID = -1
   lngTableID = -1
   
   
   Set objINF = CreateObject(mstrINFRTLAppID & ".TransportProxy")
   
   strParamXML = objINF.CreateInputParameterXML("NoteID", _
                                                trnDataTypeInt, _
                                                4, _
                                                lngAttachedNoteID)
                                                
   strReturn = objINF.ExecuteSelectStreamSP(lngSessionID, _
                                            REQUEST_SP_NAME, _
                                            strParamXML)
   Set objINF = Nothing


   If NoRulesBroken(strReturn) Then
      If Len(strReturn) > 0 Then
         Set objDOM = New MSXML2.DOMDocument
         With objDOM
            If .loadXML(strReturn) Then
               lngRxID = CLng(.documentElement.Attributes.getNamedItem("RequestID").Text)
            End If
         End With
      End If
   End If
   
   If lngRxID = -1 Then
      Err.Raise vbObjectError + 2001, SUB_NAME, "Could not identify the prescription requestid from the attached note id."
   Else
      'Find the table id for the prescription
      Set objINF = CreateObject(mstrINFRTLAppID & ".TransportProxy")
      
      strParamXML = objINF.CreateInputParameterXML("RequestID", _
                                                   trnDataTypeInt, _
                                                   4, _
                                                   lngRxID)
                                                   
      strReturn = objINF.ExecuteSelectStreamSP(lngSessionID, _
                                               TABLE_SP_NAME, _
                                               strParamXML)
      Set objINF = Nothing
      
      If NoRulesBroken(strReturn) Then
         With objDOM
            If .loadXML(strReturn) Then
               lngTableID = CLng(.documentElement.Attributes.getNamedItem("TableID").Text)
            End If
         End With
      End If
      
      If lngTableID = -1 Then
         Err.Raise vbObjectError + 2002, SUB_NAME, "Could not identify the table that holds the prescription with requestid = '" & Format(lngRxID) & "'."
      End If
   End If
   
Cleanup:

   On Error Resume Next
   Set objDOM = Nothing
   Set objINF = Nothing
   
   ReadAttachedNoteLinkTable = strReturn
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function
Private Function ReadEpisode(ByVal lngSessionID As Long, _
                             ByVal lngEpisodeID As Long, _
                             ByRef objEpisodeDOM As MSXML2.DOMDocument) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     lngEpisodeID         :  The primary key of the episode we want to read
'
' Outputs:
'     objEpisodeDOM        :  A DOM object containing the episode in V92 SOAP format
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  04Jan05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ReadEpisode"

Dim udtError As udtErrorState
                             
Dim objEpisodeRead As Object 'IENRTL10.EpisodeRead
Dim objTemp As MSXML2.DOMDocument

Dim strEpisodeXml As String
Dim strExtraInfo As String
Dim strParameterXML As String
Dim strReturn As String


   On Error GoTo ErrorHandler

   strParameterXML = "<Parameters><Parameter name=""episodeXml"">" & _
                     XMLEscape("<Episodes><Episode Type=""Episode"" EpisodeType=""Aministration"" EpisodeId=""" & Format$(lngEpisodeID) & """/></Episodes>") & _
                     "</Parameter></Parameters>"
   
   strExtraInfo = "Creating object '" & mstrIENRTLAppId & ".EpisodeRead'"
   Set objEpisodeRead = CreateObject(mstrIENRTLAppId & ".EpisodeRead")
   
   strExtraInfo = "Calling EpisodeXML..."
   strReturn = objEpisodeRead.EpisodeXML(lngSessionID, _
                                         strParameterXML)
                                         
   Set objEpisodeRead = Nothing

   Set objTemp = New MSXML2.DOMDocument

   strExtraInfo = "Loading the returned episode XML into a DOM"
   With objTemp
      .preserveWhiteSpace = True
      .loadXML (strReturn)
   End With
   
   strExtraInfo = "Checking the returned episode XML is valid"
   strReturn = ConvertV92SoapReturn2BrokenRules(objTemp)
   
   If NoRulesBroken(strReturn) Then
            
      strEpisodeXml = objTemp.documentElement.selectSingleNode("Success[@Name='episodeXml']").Text
      strEpisodeXml = XMLUnEscape(strEpisodeXml)
      
      If objEpisodeDOM Is Nothing Then
         strExtraInfo = "Creating the Episode DOM object"
         Set objEpisodeDOM = New MSXML2.DOMDocument
      End If
      
      With objEpisodeDOM
         .preserveWhiteSpace = True
         .loadXML strEpisodeXml
      End With
   End If

Cleanup:

   Set objEpisodeRead = Nothing
   Set objTemp = Nothing
   
   ReadEpisode = strReturn
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                             
End Function

Private Function ConvertV92SoapReturn2BrokenRules(ByRef objDOM As MSXML2.DOMDocument) As String

Const SUB_NAME = "ConvertV92SoapReturn2BrokenRules"

Dim objNode As MSXML2.IXMLDOMNode

Dim uError As udtErrorState

Dim strBrokenRules As String

   On Error GoTo ErrorHandler
   
   If Not objDOM Is Nothing Then
      For Each objNode In objDOM.documentElement.childNodes
         With objNode
            If .nodeName = "Error" Then
               strBrokenRules = strBrokenRules & _
                     FormatBrokenRuleXML(.Attributes.getNamedItem("Code").Text, _
                                         .Text)
            End If
         End With
      Next
   End If
   
   If Len(strBrokenRules) > 0 Then _
         strBrokenRules = FormatBrokenRulesXML(strBrokenRules)
         
ExitPoint:
   
   Set objNode = Nothing
   
   ConvertV92SoapReturn2BrokenRules = strBrokenRules
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume ExitPoint

End Function
Private Sub ReadObjectNames(ByVal strInstanceName As String)
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
'  24Jan05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ReadObjectNames"

Dim udtError As udtErrorState

Dim objReg As RegObj.Registry

Dim objKey As RegObj.RegKey

Dim strExtraInfo As String
Dim strKeyName As String

   On Error GoTo ErrorHandler

   If Not mboolConfigRead Then
      
      strExtraInfo = "Creating object 'RegObj.Registry'"
      Set objReg = New RegObj.Registry
      
      strKeyName = "\HKEY_LOCAL_MACHINE\SOFTWARE\ascribe\ICWEventNotifier\V1\" & strInstanceName
      
      strExtraInfo = "Reading from registry key '" & strKeyName & "'"
      Set objKey = objReg.RegKeyFromString(strKeyName)
   
      strExtraInfo = "Reading TRNRTL10 application name."
      mstrINFRTLAppID = objKey.Values("InfAppId").Value
      
      strExtraInfo = "Reading IENRTL10 application name."
      mstrIENRTLAppId = objKey.Values("IenAppId").Value
      
      strExtraInfo = "Reading OCSRTL10 application name."
      mstrOCSRTLAppID = objKey.Values("OcsAppId").Value
      
      mboolConfigRead = True
   
   End If
   
Cleanup:

   On Error Resume Next
   
   Set objKey = Nothing
   Set objReg = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
   
End Sub
Private Function XMLUnEscape(ByVal strSource As String) As String
'------------------------------------------------------------------------
' Purpose:  Takes a source string and returns the source string with
'           any illegal XML characters replaced with their XML Escape
'            Character equivilants
'
' Inputs:   strSource - Source string that require converting to XML format
'
' Outputs:  None
'
' Return :  Result of the source string converted to XML format
'
' Revision History
' 4Sep02 PH Created
'
'------------------------------------------------------------------------
Const SUB_NAME As String = "XMLEscape"
Dim ErrorState As udtErrorState

   On Error GoTo ErrorHandler
   
   strSource = Replace(strSource, "&amp;", "&")
   strSource = Replace(strSource, "&quot;", """")
   strSource = Replace(strSource, "&apos;", "'")
   strSource = Replace(strSource, "&lt;", "<")
   strSource = Replace(strSource, "&gt;", ">")
   XMLUnEscape = strSource

Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Private Function ReadRx(ByVal lngSessionID As Long, _
                        ByVal lngTableID As Long, _
                        ByVal lngRxID As Long, _
                        ByRef lngEpisodeID As Long, _
                        ByRef objRxDOM As MSXML2.DOMDocument) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID      :  Standard sessionid
'     lngTableID        :  The table id of the prescription table
'     lngRxID           :  The primary key id of the prescription row in the
'                          prescription table
'
' Outputs:
'     lngEpisodeID      :  The id of the Episode that this prescription belongs to
'     objRxDOM          :  A DOM object containing the prescription XML
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  04Jan05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SP_NAME = "pScheduleTemplateAliasByScheduleID"
Const SUB_NAME = "ReadRx"

Dim udtError As udtErrorState

Dim objAttribute As MSXML2.IXMLDOMElement
Dim objDOM As MSXML2.DOMDocument
Dim objOCSItemRead As Object 'OCSRTL10.OrderCommsItemRead
Dim objINF As Object 'TRNRTL10.Transport

Dim lngScheduleID As Long
Dim strExtraInfo As String
Dim strParamXML As String
Dim strReturn As String
Dim strText As String
Dim strValue As String

   On Error GoTo ErrorHandler

   strExtraInfo = "Creating object '" & mstrOCSRTLAppID & ".OrderCommsItemRead'"
   Set objOCSItemRead = CreateObject(mstrOCSRTLAppID & ".OrderCommsItemRead")
      
   strReturn = objOCSItemRead.GetXML(lngSessionID, _
                                    lngTableID, _
                                    lngRxID)
                                  
   Set objOCSItemRead = Nothing
   
   If NoRulesBroken(strReturn) Then
      
      If objRxDOM Is Nothing Then
         strExtraInfo = "Creating the Rx DOM object"
         Set objRxDOM = New MSXML2.DOMDocument
      End If
      
      With objRxDOM
         .preserveWhiteSpace = True
         strExtraInfo = "Loading the database prescription XML into a DOM"
         .loadXML strReturn
         
         strExtraInfo = "Reading the EpisodeID from the Rx DOM"
         lngEpisodeID = CLng(.documentElement.selectSingleNode("attribute[@name='EpisodeID']").Attributes.getNamedItem("value").Text)
         
         strExtraInfo = "Transforming the V92 Rx to V92 SOAP structure"
         strReturn = TransformXmlUsingXslFromFileIntoObject(objRxDOM.XML, _
                                                            App.Path & "\v92RxTransform.xslt", _
                                                            objRxDOM)
      End With
   End If

   If NoRulesBroken(strReturn) Then
      'read the V8 direction code using the ScheduleID_Administration attribute
      With objRxDOM.documentElement
         lngScheduleID = CLng(.selectSingleNode("Request/RequestData/attribute[@name='ScheduleID_Administration']/@value").Text)
         
         Set objINF = CreateObject(mstrINFRTLAppID & ".TransportProxy")
         
         With objINF
            strParamXML = .CreateInputParameterXML("ScheduleTemplateID", _
                                                   trnDataTypeInt, _
                                                   4, _
                                                   lngScheduleID)
            strReturn = .ExecuteSelectStreamSP(lngSessionID, _
                                               SP_NAME, _
                                               strParamXML)
         End With
         
         Set objINF = Nothing
         
         If NoRulesBroken(strReturn) Then
            If Len(strReturn) > 0 Then
               Set objDOM = New MSXML2.DOMDocument
               With objDOM
                  If .loadXML(strReturn) Then
                     If Not .documentElement Is Nothing Then
                        With .documentElement.Attributes
                           strValue = .getNamedItem("Alias").Text
                           strText = .getNamedItem("Description").Text
                        End With
                     End If
                  End If
                  
                  Set objAttribute = objDOM.createElement("attribute")
                  objAttribute.setAttribute "name", "Dircode"
                  objAttribute.setAttribute "value", strValue
                  objAttribute.setAttribute "text", strText
                  
                  objRxDOM.documentElement.selectSingleNode("Request/RequestData").appendChild objAttribute
               End With
            End If
         End If
         
      End With
   End If
   
Cleanup:

   Set objAttribute = Nothing
   Set objDOM = Nothing
   Set objOCSItemRead = Nothing
   Set objINF = Nothing
   
   ReadRx = strReturn
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                        
End Function

Private Function TransformXmlUsingXslFromFileIntoObject(ByVal XML As String, _
                                                        ByVal XSLT_FileName As String, _
                                                        ByRef ReturnDOM As MSXML2.DOMDocument) As String
                             
Const SUB_NAME = ".TransformXmlUsingXslFromFile"

Dim objXML As MSXML2.DOMDocument
Dim objXSL As MSXML2.DOMDocument

Dim udtError As udtErrorState
                             
Dim strParseError As String
Dim strReturn As String


   On Error GoTo ErrorHandler
   
   'transform the XML using sqlentityaliaslist2entityaliases.xslt
   Set objXSL = New MSXML2.DOMDocument
   With objXSL
      '.preserveWhiteSpace = True
      .Load XSLT_FileName
      If .parseError.errorCode <> 0 Then
         'return an error - Xml not valid
         strParseError = GetDomParseError(.parseError)
         strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML(XML_INVALID_CODE, _
                                                              XML_INVALID_DESC & " _ " & _
                                                              strParseError))
      End If
   End With
   
   If NoRulesBroken(strReturn) Then
      Set objXML = New MSXML2.DOMDocument
      With objXML
         '.preserveWhiteSpace = True
         .loadXML XML
         If .parseError.errorCode = 0 Then
            If ReturnDOM Is Nothing Then Set ReturnDOM = CreateObject(APPID_DOM_OBJECT)
            .transformNodeToObject objXSL, ReturnDOM
         Else
            'return an error - Xml not valid
            strParseError = GetDomParseError(.parseError)
            strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML(XML_INVALID_CODE, _
                                                                 XML_INVALID_DESC & " - " & _
                                                                 strParseError))
         End If
      End With
   End If
                             
Cleanup:

   TransformXmlUsingXslFromFileIntoObject = strReturn
   
   Set objXSL = Nothing
   Set objXML = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
   
Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, "XSLT_FILE_NAME = '" & XSLT_FileName & "'"
   Resume Cleanup

End Function

Private Function GetDomParseError(ParseErr As MSXML2.IXMLDOMParseError) As String
'----------------------------------------------------------------------------------
'
' Purpose: Returns parse error from the Document Object Model to allow better debugging
'
'
' Inputs:
'     ParseErr:  MSXML parser error object
'
' Outputs:
'     Returns error information as XML attributes for inclusion in the BrokenRules
'
' Modification History:
'  01Apr2003 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetDomParseError"

Dim ErrorState As udtErrorState
Dim strReturn As String

   On Error GoTo ErrorHandler
   
   strReturn = vbNullString
   
   With ParseErr
      strReturn = "ParseErrorCode=""" & .errorCode & """ " & _
                "ParseErrorDescription=""" & .reason & " in line " & .Line & " at character " & .linepos & """ " & _
                "ParseErrorSourceText=""" & XMLEscape(.srcText) & """"
      'parse out the carriage returns in .line and .linepos
      strReturn = Replace(strReturn, vbCrLf, vbNullString)
   End With
   
   
ExitPoint:
   
   On Error Resume Next
   GetDomParseError = strReturn
   
   On Error GoTo 0
   BubbleOnError ErrorState
   
Exit Function

'-------------------------------Error Handling Block----------------------------------------

ErrorHandler:
   
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME
   Resume ExitPoint

End Function


Public Function Translate(ByVal SessionID As Long, _
                          ByVal InstanceName As String, _
                          ByVal AuditLogXML As String, _
                          ByRef Message As String) As String
'----------------------------------------------------------------------------------
'
' Purpose: The function is the top level function that interprets the TriggerXML and
'          then reads the ICW tables to fetch the data relevant to the trigger before
'          encoding the patient, episode and allergy information into a HL7 A08 message.
'
' Inputs:
'     SessionID         :  Standard sessionid
'     InstanceName      :  The name of the instance that instaniated the dll
'     AuditLogXML       :  The XML from the ICW Audit Log
'
' Outputs:
'     Message           :  The allergy information encoded as an HL7 A08 message
'
'     Returns any errors as <BrokenRules/> XML string
'
' Modification History:
'  04Jan05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "Translate"

Dim udtError As udtErrorState
                                                    
Dim objAuditLogDOM As MSXML2.DOMDocument
Dim objEpisodeDOM As MSXML2.DOMDocument
Dim objRxDOM As MSXML2.DOMDocument

Dim strExtraInfo As String

Dim lngAttachedNoteID As Long
Dim lngEpisodeID As Long
Dim lngTableID As Long
Dim lngRxID As Long

Dim strReturn As String

   On Error GoTo ErrorHandler

   strExtraInfo = "Reading object names from the registry"
   ReadObjectNames (InstanceName)
   
   strExtraInfo = "Creating a DOM object"
   Set objAuditLogDOM = New MSXML2.DOMDocument
   
   With objAuditLogDOM
      .preserveWhiteSpace = True
      strExtraInfo = "Loading Auditlog XML into the DOM"
      .loadXML AuditLogXML
         
'      strExtraInfo = "Reading the TableID attribute from the DOM documentelement"
'      lngTableID = CLng(.documentElement.Attributes.getNamedItem("TableID").Text)
      
      strExtraInfo = "Reading the PrimaryKey attribute from the DOM documentelement."
      lngAttachedNoteID = CLng(.documentElement.Attributes.getNamedItem("PrimaryKey").Text)
   End With

   strExtraInfo = "Finding the StandardPrescription RequestID from the AttachedNoteID"
   strReturn = ReadAttachedNoteLinkTable(SessionID, _
                                         lngAttachedNoteID, _
                                         lngRxID, _
                                         lngTableID)
   
   If NoRulesBroken(strReturn) Then
      strExtraInfo = "Calling ReadRx..."
      strReturn = ReadRx(SessionID, _
                         lngTableID, _
                         lngRxID, _
                         lngEpisodeID, _
                         objRxDOM)
   End If
   
   If NoRulesBroken(strReturn) Then
      strExtraInfo = "Calling ReadEpisode..."
      strReturn = ReadEpisode(SessionID, _
                              lngEpisodeID, _
                              objEpisodeDOM)
   End If
   
   If NoRulesBroken(strReturn) Then
      strExtraInfo = "Calling UpdateEpisode..."
      UpdateEpisode objRxDOM, _
                    objEpisodeDOM
   End If
   
   If NoRulesBroken(strReturn) Then _
         Message = "<Files><File>" & objRxDOM.XML & "</File></Files>"
         
Cleanup:

   Set objAuditLogDOM = Nothing
   Set objEpisodeDOM = Nothing
   Set objRxDOM = Nothing
   
   Translate = strReturn
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Private Sub UpdateEpisode(ByRef objRxDOM As MSXML2.DOMDocument, _
                          ByRef objEpisodeDOM As MSXML2.DOMDocument)
'----------------------------------------------------------------------------------
'
' Purpose: Updates the Episode tag in the Rx DOM with the episode XML read from
'          the database.
'
' Inputs:
'     objRxDOM       :  The Prescription XML in V92 SOAP compliant format
'     objEpisodeDOM  :  The Episode XML in V92 SOAP compliant format
'
' Outputs:
'     objRxDOM       :  The Prescription XML in V92 SOAP compliant format
'                       with the Episode XML updated
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  04Jan05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "UpdateEpisode"

Dim udtError As udtErrorState
                          
Dim objOldEpisodeNode As MSXML2.IXMLDOMNode
Dim objNewEpisodeNode As MSXML2.IXMLDOMNode

   On Error GoTo ErrorHandler

   Set objNewEpisodeNode = objEpisodeDOM.documentElement.firstChild
   Set objOldEpisodeNode = objRxDOM.documentElement.selectSingleNode("Request/Episode")
   
   objRxDOM.documentElement.childNodes(1).replaceChild objNewEpisodeNode, _
                                                    objRxDOM.documentElement.childNodes(1).childNodes(1)

Cleanup:

   Set objOldEpisodeNode = Nothing
   Set objNewEpisodeNode = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub



