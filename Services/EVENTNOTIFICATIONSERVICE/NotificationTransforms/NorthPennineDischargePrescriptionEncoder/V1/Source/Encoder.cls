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
Private Function DetermineOutputParameters(ByVal lngSessionID As Long, _
                                           ByVal strInstanceName As String, _
                                           ByRef objParentLocationID As MSXML2.IXMLDOMNode, _
                                           ByRef strDirectory As String, _
                                           ByRef strFileExtn As String, _
                                           ByRef strDbConn As String, _
                                           ByRef strClientDirectory As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     strInstanceName      :  The name of the instance
'     objParentLocationID  :  An DOM node object containing the ParentLocationID
'
' Outputs:
'     strDirectory         :  The directory to which the file will be written (i.e. local directory path)
'     strFileExtn          :  The file extension of the file to be generated.
'     strDbConn            :  The connection string to the required V86RxInterface database
'     strClientDirectory   :  The UNC path that allows the V86RxInterface client to access the files in the
'                             directory that they are created in.
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  04Jan06 EAC  Written
'  25May07 EAC  Modified to read the V86RxInterface connection string and client UNC
'               path to the files to allow bypass of XMLFileToDb.
'----------------------------------------------------------------------------------

Const SUB_NAME = "DetermineOutputParameters"

Dim udtError As udtErrorState
                                           
Dim strKeyname As String
Dim strPatientLocationID As String
Dim strReturn As String

   On Error GoTo ErrorHandler

   strPatientLocationID = vbNullString
   
   If Not objParentLocationID Is Nothing Then
      If Len(objParentLocationID.Text) > 0 Then strPatientLocationID = objParentLocationID.Text
   End If


   If strPatientLocationID = vbNullString Then
      strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML(Format$(vbObjectError + 1), "Failed to identify a valid Parent LocationID from the order."))
   End If
   
   If NoRulesBroken(strReturn) Then
      strKeyname = strPatientLocationID & "OutputDirectory"
      strReturn = GetICWSetting(lngSessionID, _
                                strInstanceName, _
                                strKeyname, _
                                strDirectory)
   End If

   If NoRulesBroken(strReturn) Then
      strKeyname = strPatientLocationID & "FileExtension"
      strReturn = GetICWSetting(lngSessionID, _
                                strInstanceName, _
                                strKeyname, _
                                strFileExtn)
   End If

'25May07 EAC
   If NoRulesBroken(strReturn) Then
      strKeyname = strPatientLocationID & "ConnectionString"
      strReturn = GetICWSetting(lngSessionID, _
                                strInstanceName, _
                                strKeyname, _
                                strDbConn)
   End If
   
   If NoRulesBroken(strReturn) Then
      strKeyname = strPatientLocationID & "ClientDirectoryPath"
      strReturn = GetICWSetting(lngSessionID, _
                                strInstanceName, _
                                strKeyname, _
                                strClientDirectory)
   End If
'---
   
Cleanup:

   On Error Resume Next
   DetermineOutputParameters = strReturn
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Private Function GetICWSetting(ByVal lngSessionID As Long, _
                               ByVal strInstanceName As String, _
                               ByVal strKeyname As String, _
                               ByRef strSetting As String) As String
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
'  04Jan06 EAC  Written
'
'----------------------------------------------------------------------------------
Const SP_NAME = "pSetting"
Const SUB_NAME = "GetICWSetting"
Const SYSTEM_NAME = "NthPennineDischargeRxEncoderV1"

Const trnDataTypeVarChar = 0

Dim objINF As Object

Dim udtError As udtErrorState
                               
Dim strExtraInfo As String
Dim strParameterXML As String
Dim strReturn As String


   On Error GoTo ErrorHandler

   strExtraInfo = "Creating object '" & mstrINFRTLAppID & ".TransportProxyRead'"
   Set objINF = CreateObject(mstrINFRTLAppID & ".TransportProxyRead")

   With objINF
      strParameterXML = .CreateInputParameterXML("System", trnDataTypeVarChar, 50, SYSTEM_NAME) & _
                        .CreateInputParameterXML("Section", trnDataTypeVarChar, 50, strInstanceName) & _
                        .CreateInputParameterXML("Key", trnDataTypeVarChar, 50, strKeyname)
                        
      strSetting = .ExecuteSelectStreamSP(lngSessionID, _
                                          SP_NAME, _
                                          strParameterXML)
   End With
   
   If NoRulesBroken(strSetting) Then
      If Len(strSetting) = 0 Then
         strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML(vbObjectError + 2, _
                                                              "No entry found in the Settings table for System = '" & _
                                                              SYSTEM_NAME & "', Section = '" & strInstanceName & "', Key = '" & _
                                                              strKeyname & "'"))
                                                            
      End If
   End If
   
Cleanup:

   On Error Resume Next
   Set objINF = Nothing
   
   GetICWSetting = strReturn
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function
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
   
   
   Set objINF = CreateObject(mstrINFRTLAppID & ".TransportProxyRead")
   
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
      Set objINF = CreateObject(mstrINFRTLAppID & ".TransportProxyRead")
      
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
Private Function ReadDischargeMeds(ByVal lngSessionID As Long, _
                                   ByVal lngEpisodeID As Long, _
                                   ByRef objMedList As MSXML2.IXMLDOMNodeList) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     lngEpisodeID         :  The Episode ID to which the Discharge Meds are attached
'
' Outputs:
'     objMedsList          :  An XML node list containing XML for each of the discharge meds
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Jul05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SP_NAME = "pNorthPennineDischargeMedsXML"
Const SUB_NAME = "ReadDischargeMeds"

Dim udtError As udtErrorState
                                
Dim objDOM As MSXML2.DOMDocument
Dim objINF As Object

Dim strExtraInfo As String
Dim strParameterXML As String
Dim strReturn As String

   On Error GoTo ErrorHandler

   strExtraInfo = "Creating object " & mstrINFRTLAppID & ".TransportProxyRead"
   Set objINF = CreateObject(mstrINFRTLAppID & ".TransportProxyRead")
   
   With objINF
      strExtraInfo = "Creating the ScheduleTemplateID parameter"
      strParameterXML = .CreateInputParameterXML("EpisodeID", _
                                                 trnDataTypeInt, _
                                                 4, _
                                                 lngEpisodeID)
      strExtraInfo = "Calling " & SP_NAME
      strReturn = .ExecuteSelectStreamSP(lngSessionID, _
                                         SP_NAME, _
                                         strParameterXML)
   End With
   
   Set objINF = Nothing
   
   If NoRulesBroken(strReturn) Then
      If Len(strReturn) > 0 Then
         Set objDOM = New MSXML2.DOMDocument
         With objDOM
            If .loadXML("<Root>" & strReturn & "</Root>") Then
               Set objMedList = objDOM.documentElement.selectNodes("//Request")
            End If
         End With
      End If
   End If

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Private Function ReadDischargeSummary(ByVal lngSessionID As Long, _
                                      ByVal lngRequestID As Long, _
                                      ByVal lngTableID As Long, _
                                      ByRef lngEpisodeID As Long) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'     lngRequestID        :  The Discharge Summary request id
'     lngTableID          :  The id of the table which holds the Discharge Summary data
'
' Outputs:
'     lngEpisodeID        :  A the EpisodeID from the Discharge Summary
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  07Jul05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ReadDischargeSummary"

Dim udtError As udtErrorState

Dim objDOM As MSXML2.DOMDocument
Dim objOCSItemRead As Object

Dim strExtraInfo As String
Dim strReturn As String

   On Error GoTo ErrorHandler

   strExtraInfo = "Creating object '" & mstrOCSRTLAppID & ".OrderCommsItemRead'"
   Set objOCSItemRead = CreateObject(mstrOCSRTLAppID & ".OrderCommsItemRead")
      
   strReturn = objOCSItemRead.GetXML(lngSessionID, _
                                    lngTableID, _
                                    lngRequestID)
                                  
   Set objOCSItemRead = Nothing
   
   If NoRulesBroken(strReturn) Then
      
      If objDOM Is Nothing Then
         strExtraInfo = "Creating the Rx DOM object"
         Set objDOM = New MSXML2.DOMDocument
      End If
      
      With objDOM
         .preserveWhiteSpace = True
         strExtraInfo = "Loading the Discharge Summary XML into a DOM"
         .loadXML strReturn
   
         strExtraInfo = "Reading the EpisodeID from the Discharge Summary DOM"
         lngEpisodeID = CLng(.documentElement.selectSingleNode("attribute[@name='EpisodeID']").Attributes.getNamedItem("value").Text)
   
      End With
   End If

   ReadDischargeSummary = strReturn
   
Cleanup:

   On Error Resume Next
   Set objDOM = Nothing
   Set objOCSItemRead = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
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
                             
Dim objAttribute As MSXML2.IXMLDOMElement
Dim objEpisodeRead As Object 'IENRTL10.EpisodeRead
Dim objNode As MSXML2.IXMLDOMNode
Dim objTemp As MSXML2.DOMDocument

Dim strEpisodeXml As String
Dim strExtraInfo As String
Dim strParameterXML As String
Dim strReturn As String


   On Error GoTo ErrorHandler

   strParameterXML = "<Parameters><Parameter name=""episodeXml"">" & _
                     XMLEscape("<Episodes><Episode Type=""Episode"" EpisodeType=""Clinical"" EpisodeId=""" & Format$(lngEpisodeID) & """/></Episodes>") & _
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
         
         'add a PatientType attribute element set to Inpatient
         Set objAttribute = objEpisodeDOM.createElement("attribute")
         With objAttribute
            .setAttribute "name", "PatientType"
            .setAttribute "value", "D"
         End With
         
         Set objNode = .documentElement.selectSingleNode("Episode/Entity/EntityData")
         objNode.appendChild objAttribute
      End With
   End If

Cleanup:

   On Error Resume Next
   Set objAttribute = Nothing
   Set objEpisodeRead = Nothing
   Set objNode = Nothing
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
'  04Jan06 EAC  Modified to use INFRTL10 rather than TRNRTL10
'----------------------------------------------------------------------------------

Const SUB_NAME = "ReadObjectNames"

Dim udtError As udtErrorState

Dim objReg As RegObj.Registry

Dim objKey As RegObj.RegKey

Dim strExtraInfo As String
Dim strKeyname As String

   On Error GoTo ErrorHandler

   If Not mboolConfigRead Then
      
      strExtraInfo = "Creating object 'RegObj.Registry'"
      Set objReg = New RegObj.Registry
      
      strKeyname = "\HKEY_LOCAL_MACHINE\SOFTWARE\ascribe\ICWEventNotifier\V1\" & strInstanceName
      
      strExtraInfo = "Reading from registry key '" & strKeyname & "'"
      Set objKey = objReg.RegKeyFromString(strKeyname)
   
      strExtraInfo = "Reading INFRTL10 application name."
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
Private Function SaveMessageToDb(ByVal InstanceName As String, _
                                 ByVal DbConn As String, _
                                 ByVal FileName As String, _
                                 ByVal ClientDirPath As String, _
                                 ByVal RxXML As MSXML2.DOMDocument) As String
'----------------------------------------------------------------------------------
'
' Purpose: The subroutine writes the prescription XML directly into the V86RxInterface
'          V2 application database as identified by the DbConn parameter.
'
' Inputs:
'     InstanceName      :  The name of the instance that instaniated the dll
'     DbConn            :  The connection string to the V86RxInterface V2 database
'     FileName          :  The name of the XML file containing the prescription XML
'     ClientDirPath     :  The UNC Path that the client will use to access the XML file
'     RxXML             :  The prescription XML in a DOM object
'
' Outputs:
'
'     Returns any errors as <BrokenRules/> XML string
'
' Modification History:
'  25May07 EAC  Written
'----------------------------------------------------------------------------------
Const SUB_NAME = "SaveMessaageToDb"

Dim udtError As udtErrorState
                            
Dim adoConn As ADODB.Connection
Dim adoCmd As ADODB.Command

Dim oElement As IXMLDOMElement
    
Dim lngRowsAffected As Long

Dim sCaseNumber     As String
Dim sName           As String
Dim vDateOfBirth    As Variant
Dim sGender         As String
Dim sWard           As String
Dim sConsultant     As String
Dim sStartDate      As String
Dim sDescription    As String
Dim vRequestDate    As Variant
Dim sExternalRxID   As String
Dim sPrescriptionAction As String
Dim sLabelType As String

Dim strClientFilePath As String
Dim strExtraInfo As String
Dim strReturn As String

   On Error GoTo ErrorHandler

   strReturn = ""
   
   strClientFilePath = ClientDirPath
   
   If Right$(strClientFilePath, 1) <> "\" Then strClientFilePath = strClientFilePath & "\"
   
   strClientFilePath = strClientFilePath & FileName
   
   strExtraInfo = "Reading the parameter values from the XML..."
   Set oElement = RxXML.selectSingleNode("Requests/Request/Episode/Entity")

   sCaseNumber = GetXmlValue("Aliases/Alias[@AliasGroup='CaseNumber']", oElement)
   
   vDateOfBirth = Left$(GetXmlValue("EntityData/attribute[@name='DOB']/@value", oElement), 16)
   
   If (Len(vDateOfBirth) = 0) Or (Left$(vDateOfBirth, 1) = "0") Then
      vDateOfBirth = Null
   Else
      vDateOfBirth = Replace(vDateOfBirth, "T", " ")
   End If
   
   sName = GetXmlValue("EntityData/attribute[@name='Description']/@value", oElement)
   
   Set oElement = RxXML.selectSingleNode("Requests/Request/Episode/Locations/Location/LocationData")
   
   sWard = GetXmlValue("attribute[@name='Description']/@value", oElement)
   
   Set oElement = RxXML.selectSingleNode("Requests/Request/Episode/ResponsibleEpisodeEntities/ResponsibleEpisodeEntity/Entity/Aliases")
   
   sConsultant = GetXmlValue("Alias[@AliasGroup='WConsultantCodes']", oElement)
   
   Set oElement = RxXML.selectSingleNode("Requests/Request/RequestData")
   
   sStartDate = Left$(GetXmlValue("attribute[@name='StartDate']/@value", oElement), 16)
   
   If (Len(sStartDate) > 0) Then
      sStartDate = Replace(sStartDate, "T", " ")
   End If
   
   sDescription = GetXmlValue("attribute[@name='Description']/@value", oElement)
   vRequestDate = Left$(GetXmlValue("attribute[@name='RequestDate']/@value", oElement), 16)
   
   If (Len(vRequestDate) = 0) Then
      vRequestDate = Null
   Else
      vRequestDate = Replace(vRequestDate, "T", " ")
   End If
   
   sExternalRxID = GetXmlValue("attribute[@name='ExternalPrescriptionID']/@value", oElement)
   sPrescriptionAction = GetXmlValue("attribute[@name='PrescriptionAction']/@value", oElement)
   sLabelType = GetXmlValue("attribute[@name='LabelIssueType']/@value", oElement)
   
   If sCaseNumber <> "" And sName <> "" And sStartDate <> "" Then
   
      strExtraInfo = "Creating object 'ADODB.Connection'"
      Set adoConn = New ADODB.Connection
      
      strExtraInfo = "Opening connection to database"
      With adoConn
         .ConnectionString = DbConn
         .Open
      End With
      
      strExtraInfo = "Creating object 'ADODB.Command'"
      Set adoCmd = New ADODB.Command
      
      With adoCmd
         strExtraInfo = "Setting the command ActiveConnection..."
         Set .ActiveConnection = adoConn
         .CommandType = adCmdStoredProc
                  
         If (UCase$(sPrescriptionAction) = "ORDER CANCELLED") Or (UCase$(sPrescriptionAction) = "CANCEL") Then
            .CommandText = "pPrescribedItemCancel"
            
            strExtraInfo = "Creating the stored procedure parameters..."
            .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, 1)
            .Parameters.Append .CreateParameter("ExternalRXID", adInteger, adParamInput, 4, CLng(sExternalRxID))
            
            strExtraInfo = "Calling stored procedure 'pPrescribedItemCancel'"
            .Execute lngRowsAffected
            
            If (lngRowsAffected = 0) Then
               sPrescriptionAction = "CREATE"
            End If
         End If
         
         If (UCase$(sPrescriptionAction) = "CREATE") Then
            .CommandText = "pPrescribedItemInsert"
            
            strExtraInfo = "Creating the stored procedure parameters..."
            .Parameters.Append .CreateParameter("SessionID", adInteger, adParamInput, 4, 1)
            .Parameters.Append .CreateParameter("CaseNumber", adVarChar, adParamInput, 128, sCaseNumber)
            .Parameters.Append .CreateParameter("Name", adVarChar, adParamInput, 128, sName)
            .Parameters.Append .CreateParameter("DateOfBirth", adDate, adParamInput, 16, vDateOfBirth)
            .Parameters.Append .CreateParameter("Gender", adChar, adParamInput, 1, sGender)
            .Parameters.Append .CreateParameter("Ward", adVarChar, adParamInput, 4, sWard)
            .Parameters.Append .CreateParameter("Consultant", adVarChar, adParamInput, 4, sConsultant)
            .Parameters.Append .CreateParameter("StartDate", adDate, adParamInput, 16, sStartDate)
            .Parameters.Append .CreateParameter("Description", adVarChar, adParamInput, 256, sDescription)
            .Parameters.Append .CreateParameter("RequestDate", adDate, adParamInput, 16, vRequestDate)
            .Parameters.Append .CreateParameter("Cancelled", adDate, adParamInput, 4, Null)
            .Parameters.Append .CreateParameter("ExternalRxID", adVarChar, adParamInput, 128, sExternalRxID)
            .Parameters.Append .CreateParameter("FileName", adVarChar, adParamInput, 512, strClientFilePath)
            .Parameters.Append .CreateParameter("DispensedDate", adDate, adParamInput, 16, Null)
            .Parameters.Append .CreateParameter("DispensingUserID", adChar, adParamInput, 3, Null)
            .Parameters.Append .CreateParameter("DeletedDate", adDate, adParamInput, 16, Null)
            .Parameters.Append .CreateParameter("DeletedUserID", adChar, adParamInput, 3, Null)
            .Parameters.Append .CreateParameter("LabelType", adChar, adParamInput, 1, sLabelType)
            .Parameters.Append .CreateParameter("PrescribedItemID", adInteger, adParamOutput, 4)
            
            strExtraInfo = "calling stored procedure 'pPrescribedItemInsert'"
            .Execute lngRowsAffected
         End If
      End With
   Else
      strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML(Format$(vbObjectError + 4), "Not enough data provided to create the entry in the V86RxInterface database."))
   End If
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
   
End Function

Private Function GetXmlValue(ByVal strXPath As String, _
                             ByRef objStartElmnt As MSXML2.IXMLDOMElement) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     strXpath    :  The XPath query of the value to be read
'     objStartElmnt      :  The DOM object to which the XPath query will be applied
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  27Mar06 EAC  Written
'
'----------------------------------------------------------------------------------
Const SUB_NAME = "GetXmlValue"

Dim udtError As udtErrorState

Dim objNode As MSXML2.IXMLDOMNode


   On Error GoTo ErrorHandler
   
   GetXmlValue = vbNullString
   
   If Not objStartElmnt Is Nothing Then
      Set objNode = objStartElmnt.selectSingleNode(strXPath)
      
      If Not objNode Is Nothing Then
         GetXmlValue = objNode.Text
      End If
   End If

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Private Function UpdateDoseUnit(ByVal lngSessionID As Long, _
                                ByRef objAttribute As MSXML2.IXMLDOMElement) As String
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
'  13Dec05 EAC  Written - moved from ReadRx
'
'----------------------------------------------------------------------------------
Const SP_NAME = "pUnitXML"
Const SUB_NAME = "UpdateDoseUnit"

Dim objDOM As MSXML2.DOMDocument
Dim objINF As Object
Dim objText As MSXML2.IXMLDOMNode

Dim udtError As udtErrorState
                                      
Dim lngUnitID As Long

Dim strExtraInfo As String
Dim strParamXML As String
Dim strReturn As String



   On Error GoTo ErrorHandler

   
   lngUnitID = Val(objAttribute.Attributes.getNamedItem("value").Text)

   strExtraInfo = "Creating object " & mstrINFRTLAppID & ".TransportProxyRead"
   Set objINF = CreateObject(mstrINFRTLAppID & ".TransportProxyRead")
   
   With objINF
      strExtraInfo = "Creating the UnitID parameter"
      strParamXML = .CreateInputParameterXML("UnitID", _
                                             trnDataTypeInt, _
                                             4, _
                                             lngUnitID)
      strExtraInfo = "Calling " & SP_NAME
      strReturn = .ExecuteSelectStreamSP(lngSessionID, _
                                         SP_NAME, _
                                         strParamXML)
   End With
   
   Set objINF = Nothing
   
   strExtraInfo = "Reading the values from the Unit record"
   
   If NoRulesBroken(strReturn) Then
      If Len(strReturn) > 0 Then
         Set objDOM = New MSXML2.DOMDocument
         With objDOM
            If .loadXML(strReturn) Then
               If Not .documentElement Is Nothing Then
                  With .documentElement.Attributes
                     If objAttribute.Attributes.getNamedItem("text") Is Nothing Then
                        Set objText = objDOM.createNode(NODE_ATTRIBUTE, "text", "")
                        objText.Text = .getNamedItem("Abbreviation").Text
                        objAttribute.Attributes.setNamedItem objText
                     Else
                     objAttribute.Attributes.getNamedItem("text").Text = .getNamedItem("Abbreviation").Text
                     End If
                  End With
               End If
            End If
         End With
      End If
   End If
   
   UpdateDoseUnit = strReturn

Cleanup:

   On Error Resume Next
   Set objDOM = Nothing
   Set objINF = Nothing
   Set objText = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup

End Function

Private Function UpdateAdministrationSchedule(ByVal lngSessionID As Long, _
                                              ByVal lngScheduleID As Long, _
                                              ByRef objAttribute As MSXML2.IXMLDOMElement) As String
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
'  13Dec05 EAC  Written - moved from ReadRx
'
'----------------------------------------------------------------------------------
Const SP_NAME = "pScheduleTemplateAliasByScheduleID"
Const SUB_NAME = "UpdateAdministrationSchedule"

Dim objDOM As MSXML2.DOMDocument
Dim objINF As Object

Dim udtError As udtErrorState
                                      
Dim strExtraInfo As String
Dim strParamXML As String
Dim strReturn As String
Dim strText As String
Dim strValue As String

   On Error GoTo ErrorHandler

   strExtraInfo = "Creating object " & mstrINFRTLAppID & ".TransportProxyRead"
   Set objINF = CreateObject(mstrINFRTLAppID & ".TransportProxyRead")
   
   With objINF
      strExtraInfo = "Creating the ScheduleTemplateID parameter"
      strParamXML = .CreateInputParameterXML("ScheduleTemplateID", _
                                             trnDataTypeInt, _
                                             4, _
                                             lngScheduleID)
      strExtraInfo = "Calling " & SP_NAME
      strReturn = .ExecuteSelectStreamSP(lngSessionID, _
                                         SP_NAME, _
                                         strParamXML)
   End With
   
   Set objINF = Nothing
   
   strExtraInfo = "Reading the values from the schedule"
   
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
            
         End With
      End If
   End If
   
   UpdateAdministrationSchedule = strReturn

Cleanup:

   On Error Resume Next
   Set objDOM = Nothing
   Set objINF = Nothing

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup

End Function

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

Const SUB_NAME = "ReadRx"

Dim udtError As udtErrorState

Dim objNode As MSXML2.IXMLDOMNode
Dim objOCSItemRead As Object 'OCSRTL10.OrderCommsItemRead
Dim objScheduleAttribute As MSXML2.IXMLDOMElement

Dim lngScheduleID As Long

Dim strExtraInfo As String
Dim strReturn As String



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
                  
         strExtraInfo = "Transforming the V92 Rx to V92 SOAP structure"
         strReturn = TransformXmlUsingXslFromFileIntoObject(objRxDOM.XML, _
                                                            App.Path & "\NorthPennineDischargeRxTransform.xslt", _
                                                            objRxDOM)
      End With
   End If

   If NoRulesBroken(strReturn) Then
      'read the V8 direction code using the ScheduleID_Administration attribute
      With objRxDOM.documentElement
         lngScheduleID = CLng(.selectSingleNode("Request/RequestData/attribute[@name='ScheduleID_Administration']/@value").Text)
      End With
         
      strReturn = UpdateAdministrationSchedule(lngSessionID, _
                                               lngScheduleID, _
                                               objScheduleAttribute)
   End If
   
   If NoRulesBroken(strReturn) Then
      If Not objScheduleAttribute Is Nothing Then
         objRxDOM.documentElement.selectSingleNode("Request/RequestData").appendChild objScheduleAttribute
      End If
      
      With objRxDOM.documentElement
         Set objNode = .selectSingleNode("Request/RequestData/attribute[@name='UnitID_Dose']")
      End With
      
      If Not objNode Is Nothing Then
         strReturn = UpdateDoseUnit(lngSessionID, _
                                    objNode)
      End If
      
   End If
      
Cleanup:

   Set objOCSItemRead = Nothing
   Set objScheduleAttribute = Nothing
   
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


Public Function Translate(ByVal SessionId As Long, _
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
'  04Jan06 EAC  Modified to write the files to different directorys depending on the hospital
'               the discharge is being ordered from
'  25May07 EAC  Modified to write the data directly to the V86RxInterface database.
'----------------------------------------------------------------------------------

Const SUB_NAME = "Translate"

Dim udtError As udtErrorState
                                                    
Dim objAuditLogDOM As MSXML2.DOMDocument
Dim objEpisodeDOM As MSXML2.DOMDocument
Dim objFile As MSXML2.IXMLDOMNode
Dim objMed As MSXML2.IXMLDOMNode
Dim objMedList As MSXML2.IXMLDOMNodeList
Dim objRxDOM As MSXML2.DOMDocument

Dim strExtraInfo As String

Dim lngAttachedNoteID As Long
Dim lngDischargeSummaryRequestID As Long
Dim lngEpisodeID As Long
Dim lngTableID As Long
Dim lngRxID As Long

Dim strClientDir As String
Dim strDbConn As String
Dim strDirectory As String
Dim strFileExtn As String
Dim strFileName As String
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
         
      strExtraInfo = "Reading the PrimaryKey attribute from the DOM documentelement."
      lngAttachedNoteID = CLng(.documentElement.Attributes.getNamedItem("PrimaryKey").Text)
   End With

   strExtraInfo = "Finding the StandardPrescription RequestID from the AttachedNoteID"
   strReturn = ReadAttachedNoteLinkTable(SessionId, _
                                         lngAttachedNoteID, _
                                         lngDischargeSummaryRequestID, _
                                         lngTableID)
   
   If NoRulesBroken(strReturn) Then
      strExtraInfo = "Reading the Discharge Summary Request to extract the EpisodeID"
      strReturn = ReadDischargeSummary(SessionId, _
                                       lngDischargeSummaryRequestID, _
                                       lngTableID, _
                                       lngEpisodeID)

   End If
   
   If NoRulesBroken(strReturn) Then
      strExtraInfo = "Calling ReadEpisode..."
      strReturn = ReadEpisode(SessionId, _
                              lngEpisodeID, _
                              objEpisodeDOM)
   End If
   
   If NoRulesBroken(strReturn) Then
      strExtraInfo = "Reading the Discharge medication for EpisodeID " & Format$(lngEpisodeID)
      strReturn = ReadDischargeMeds(SessionId, _
                                    lngEpisodeID, _
                                    objMedList)
   End If
      
   If NoRulesBroken(strReturn) Then
      If Not objMedList Is Nothing Then
         For Each objMed In objMedList
         
            lngRxID = Val(objMed.Attributes.getNamedItem("RequestID").Text)
            lngTableID = Val(objMed.Attributes.getNamedItem("TableID").Text)
            
            strExtraInfo = "Calling ReadRx..."
            strReturn = ReadRx(SessionId, _
                               lngTableID, _
                               lngRxID, _
                               lngEpisodeID, _
                               objRxDOM)
                  
            If NoRulesBroken(strReturn) Then
               strExtraInfo = "Calling UpdateEpisode..."
               UpdateEpisode objRxDOM, _
                             objEpisodeDOM
            End If
            
            If NoRulesBroken(strReturn) Then
               strExtraInfo = "Determining the output parameters from the ordering hospital location id..."
' 25May07 EAC
               strReturn = DetermineOutputParameters(SessionId, _
                                                     InstanceName, _
                                                     objRxDOM.selectSingleNode("Requests/Request/Episode/Locations/Location[@Type='ward']/LocationData/attribute[@name='LocationID_Parent']/@value"), _
                                                     strDirectory, _
                                                     strFileExtn, _
                                                     strDbConn, _
                                                     strClientDir)
'---
            End If
            
            If RulesBroken(strReturn) Then
               Exit For
            Else
' 25May07 EAC
               strExtraInfo = "Calling SaveMessageToFile..."
               SaveMessageToFile InstanceName, _
                                 strDirectory, _
                                 strFileExtn, _
                                 objRxDOM.XML, _
                                 strFileName

               strExtraInfo = "Calling SaveMessageToDb..."
               strReturn = SaveMessageToDb(InstanceName, _
                                           strDbConn, _
                                           strFileName, _
                                           strClientDir, _
                                           objRxDOM)
'---
            End If
         Next
      End If
   End If
   
Cleanup:

   'set the message returned to the ICW Event Notifier so that it doesn't try to write the files as well!
   Message = "<Files><File></File></Files>"
   
   Set objAuditLogDOM = Nothing
   Set objEpisodeDOM = Nothing
   Set objFile = Nothing
   Set objMed = Nothing
   Set objMedList = Nothing
   Set objRxDOM = Nothing
   
   Translate = strReturn
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup

End Function

Private Sub UpdateEpisode(ByRef objRxDOM As MSXML2.DOMDocument, _
                          ByVal objEpisodeDOM As MSXML2.DOMDocument)
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

   Set objNewEpisodeNode = objEpisodeDOM.documentElement.firstChild.cloneNode(True)
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



