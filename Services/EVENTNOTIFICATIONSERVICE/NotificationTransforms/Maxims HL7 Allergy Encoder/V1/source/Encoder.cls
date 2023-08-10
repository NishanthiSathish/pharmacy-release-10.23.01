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
' Purpose: This DLL takes an ICW Trigger as XML and reads the relevent ICW
'          tables to find the patient, episode and allergy information. It
'          then packages up the information in an HL7 V2.4 A08 message ready
'          for tranmission to the System C Medway system.
'
' Modification History:
'  13Sep04 EAC  Written
'
'----------------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Const CLASS_NAME = "Encoder"

Private msIENRTL10AppID As String
Private msICWRTL10AppID As String
Private msOCSRTL10AppID As String
Private msINFRTL10AppId As String
Private Function BuildA60(ByVal strInstanceName As String, _
                          ByRef objAllergies As MSXML2.DOMDocument, _
                          ByRef objEpisode As MSXML2.DOMDocument, _
                          ByRef strMessage As String) As String
'----------------------------------------------------------------------------------
'
' Purpose: This function builds the A08 message using the data from the Allergy
'          and Episode DOMs.
'
' Inputs:
'     objAllergies   :  The Allergy information in a DOM
'     objEpisode     :  The episode and patient information in a DOM
'
' Outputs:
'     strMessage     :  The HL7 A60 message
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  22Feb07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "BuildA60"

Dim objA60 As [Maxims HL7 Allergy Message Definition].MsgADTA60
Dim objEp As MSXML2.IXMLDOMNode
Dim objNode As MSXML2.IXMLDOMNode
Dim objReaction As MSXML2.IXMLDOMNode
Dim objReactions As MSXML2.IXMLDOMNodeList

Dim udtError As udtErrorState
                                                    
Dim strBrokenRules As String
Dim strNoteCreatedDt As String
Dim strDOB As String
Dim strExtraInfo As String
Dim strReceivingApp As String
Dim strReceivingFac As String
Dim strSendingApp As String
Dim strSendingFac As String
Dim strMedwayEpisodeIdAliasGroup As String
Dim strMedwayIdAliasGroup As String
Dim strStatusCode As String
Dim strTemp As String
   
   On Error GoTo ErrorHandler

   ReadConfig strInstanceName, _
              strSendingApp, _
              strSendingFac, _
              strReceivingApp, _
              strReceivingFac, _
              strMedwayIdAliasGroup, _
              strMedwayEpisodeIdAliasGroup

              
   strExtraInfo = "Creating object '[Maxims HL7 Allergy Message Definition].MsgADTA60'"
   Set objA60 = New [Maxims HL7 Allergy Message Definition].MsgADTA60
   With objA60
      With .MSH
         strExtraInfo = "Setting the MSH element fields"
         .SendingApplication.SetEncodedValue strSendingApp
         .SendingFacility.SetEncodedValue strSendingFac
         .ReceivingApplication.SetEncodedValue strReceivingApp
         .ReceivingFacility.SetEncodedValue strReceivingFac
         With .DateTimeOfMessage.Time
            .Day.Value = Day(Now)
            .Month.Value = Month(Now)
            .Year.Value = Year(Now)
            .Hours.Value = Hour(Now)
            .Minutes.Value = Minute(Now)
            .Seconds.Value = Second(Now)
         End With
         .MessageType.MessageType.Value = "ADT"
         .MessageType.TriggerEvent.Value = "A60"
         strExtraInfo = "Calling GetNextMessageID"
         .MessageControlID.Value = GetNextMessageID()
         .ProcessingID.ProcessingID.Value = "P"
         .VersionID.VersionID.Value = "2.4"
      End With
      
      With .EVN
         .EventTypeCode.Value = "A60"
         With .RecordedDateTime.Time
            strNoteCreatedDt = objAllergies.selectSingleNode("root/Allergy/@AllergyCreatedDate").Text
            
            strExtraInfo = "Setting the EVN element fields"
            .Day.Value = Mid$(strNoteCreatedDt, 9, 2)
            .Month.Value = Mid$(strNoteCreatedDt, 6, 2)
            .Year.Value = Left$(strNoteCreatedDt, 4)
            .Hours.Value = Mid$(strNoteCreatedDt, 12, 2)
            .Minutes.Value = Mid$(strNoteCreatedDt, 15, 2)
            .Seconds.Value = Mid$(strNoteCreatedDt, 18, 2)
         End With
      End With
            
      strExtraInfo = objEpisode.xml
      Set objEp = objEpisode.documentElement.selectSingleNode("Episode")
      
      If objEp Is Nothing Then
         Err.Raise vbObjectError + 1, SUB_NAME, "The Episode was not read correctly."
      Else
         With .PID
            .PatientIdentifierList.Append
            With .PatientIdentifierList(0)
               Set objNode = objEp.selectSingleNode("Entity/Aliases/Alias[@AliasGroup='" & strMedwayIdAliasGroup & "']")
               If Not objNode Is Nothing Then
                  .IDNumber.Value = objNode.Text
               Else
                  Set objNode = objEp.selectSingleNode("EpisodeData/attribute[@name='CaseNo']/@value")
                  If Not objNode Is Nothing Then
                     .IDNumber.Value = objNode.Text
                  End If
               End If
               .IdentifierTypeCode.Value = "CR"
            End With
            
            .PatientName.Append
            With .PatientName(0)
               .FamilyName.Surname.Value = objEp.selectSingleNode("Entity/EntityData/attribute[@name='Surname']/@value").Text
               .GivenName.Value = objEp.selectSingleNode("Entity/EntityData/attribute[@name='Forename']/@value").Text
               Set objNode = objEp.selectSingleNode("Entity/EntityData/attribute[@name='Initials']/@value")
               If Not objNode Is Nothing Then .MiddleInitialOrName.Value = objNode.Text
               Set objNode = objEp.selectSingleNode("Entity/EntityData/attribute[@name='Title']/@value")
               If Not objNode Is Nothing Then .prefix.Value = objNode.Text
            End With
            
            strDOB = objEp.selectSingleNode("Entity/EntityData/attribute[@name='DOB']/@value").Text
            With .DateTimeOfBirth.Time
               .Day.Value = Mid$(strDOB, 9, 2)
               .Month.Value = Mid$(strDOB, 6, 2)
               .Year.Value = Left$(strDOB, 4)
            End With
            
            strTemp = objEp.selectSingleNode("Entity/EntityData/attribute[@name='GenderID']/@value").Text
            .Sex.Value = MapGender(strTemp)
            
         End With
         
         With .PV1
            strTemp = objEp.selectSingleNode("EpisodeData/attribute[@name='StatusID']/@value").Text
            .PatientClass.Value = MapPatientTypes(strTemp)
            
            Set objNode = objEp.selectSingleNode("Aliases/Alias[@AliasGroup='" & strMedwayEpisodeIdAliasGroup & "']")
            If Not objNode Is Nothing Then
               strTemp = objNode.Text
            Else
               strTemp = objEp.Attributes.getNamedItem("EpisodeId").Text
            End If
            .VisitNumber.IDNumber.Value = strTemp
         End With
      End If
            
      Set objReactions = objAllergies.selectNodes("//AllergyReaction")
      
      For Each objReaction In objReactions
            .IAM.Append
            With .IAM(.IAM.Count - 1)
               .AllergenTypeCode.Text.Value = "MED"
               .AllergenCode.Text.Value = objAllergies.selectSingleNode("root/Allergy/@AllergyDescription").Text
               .SensitivityToCausativeAgentCode.Identifier.Value = objReaction.Attributes.getNamedItem("AllergyReactionDetail").Text
               .AllergyUniqueIdentifier.EntityIdentifier.Value = objAllergies.selectSingleNode("root/Allergy/@NoteID").Text
               .ActionReason.Value = ""
               .RelationshipToPatientCode.Identifier.Value = ""
               .AlertDeviceCode.Identifier.Value = ""
               
               'If (.AllergyReactionCode.Count = 0) Then
               If (objReaction.Attributes.getNamedItem("ReactionActive").Text = "0") Then
                  strStatusCode = "I"
               Else
                  strStatusCode = "C"
               End If
               
               .AllergyClinicalStatusCode.Identifier.Value = strStatusCode
               
               .ReportedBy.GivenName.Value = objAllergies.selectSingleNode("root/Allergy/@AllergyCreatedUser").Text
            End With
      Next
      
      strExtraInfo = "Reading the HL7 message"
      strMessage = .GetEncodedValue()
      
   End With

Cleanup:

   On Error Resume Next
   Set objA60 = Nothing
   Set objEp = Nothing
   Set objNode = Nothing
   Set objReaction = Nothing
   Set objReactions = Nothing
   
   On Error GoTo 0
   BuildA60 = strBrokenRules
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
                          
End Function

Private Function FindEpisodeID(ByVal lngSessionID As Long, _
                               ByVal lngNoteID As Long, _
                               ByRef lngEpisodeID As Long) As String
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
'  06Dec04 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "FindEpisodeID"

Const SP_NAME = "pEpisodeNoteXML"
Const trnDataTypeInt = 2

Dim objNote As MSXML2.DOMDocument
Dim objTRN As Object 'TRNRTL10.Transport

Dim udtError As udtErrorState

Dim strParameterXML As String
Dim strReturn As String
                          
   On Error GoTo ErrorHandler

   Set objTRN = CreateObject(msINFRTL10AppId & ".TransportProxy")
   strParameterXML = objTRN.CreateInputParameterXML("NoteID", _
                                                    trnDataTypeInt, _
                                                    4, _
                                                    lngNoteID)
   strReturn = objTRN.ExecuteSelectStreamSP(lngSessionID, _
                                            SP_NAME, _
                                            strParameterXML)
   Set objTRN = Nothing
   
   If NoRulesBroken(strReturn) Then _
         strReturn = LoadXML(strReturn, _
                             objNote)
   
   If NoRulesBroken(strReturn) Then _
         lngEpisodeID = CLng(objNote.documentElement.Attributes.getNamedItem("EpisodeID").Text)
   
Cleanup:

   On Error Resume Next
   Set objTRN = Nothing
   Set objNote = Nothing
   
   On Error GoTo 0
   FindEpisodeID = strReturn
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Private Function GetNextMessageID() As String
'----------------------------------------------------------------------------------
'
' Purpose: This function reads the ProcessID from a HL7MSGID.DAT and returns it
'          as a string
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  13Sep04 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetNextMessageID"

Dim udtError As udtErrorState

Dim objReadPtr As Object

Dim lngMsgID As Long

Dim strExtraInfo As String
Dim strPointerFile As String

   On Error GoTo ErrorHandler

   strPointerFile = App.Path & "\hl7msgid.dat"
   
   'Generate a unique message identifier
   strExtraInfo = "Creating object 'ASCReadPointerV1.ReadPointer'"
   Set objReadPtr = CreateObject("ASCReadPointerV1.ReadPointer")
   
   strExtraInfo = "Reading from pointer file '" & strPointerFile & "'"
   objReadPtr.GetPointer strPointerFile, lngMsgID, -1
   
   strExtraInfo = vbNullString
   Set objReadPtr = Nothing

   GetNextMessageID = Format$(lngMsgID)
   
   If lngMsgID > 99999999 Then
   
      'Generate a unique message identifier
      strExtraInfo = "Creating object 'ASCReadPointerV1.ReadPointer'"
      Set objReadPtr = CreateObject("ASCReadPointerV1.ReadPointer")
      
      strExtraInfo = "Write a zero pointer to file '" & strPointerFile & "'"
      objReadPtr.GetPointer strPointerFile, 0, 2
      
      strExtraInfo = vbNullString
      Set objReadPtr = Nothing
   End If
   
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
   
End Function


Private Function LoadXML(ByVal strXML As String, _
                         ByRef objDom As MSXML2.DOMDocument) As String
'----------------------------------------------------------------------------------
'
' Purpose: Loads the XML string into a DOM object.
'
' Inputs:
'     strXML      :  The XML string
'     objDOM      :  The DOM object that the XML string is to be loaded into
'
' Outputs:
'     objDOM      :  The DOM object with the XML string loaded
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  13Sep04 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "LoadXML"

Dim udtError As udtErrorState
                         
Dim strBrokenRules As String

   On Error GoTo ErrorHandler

   If objDom Is Nothing Then _
         Set objDom = New MSXML2.DOMDocument
         
   With objDom
      .preserveWhiteSpace = True
      .LoadXML (strXML)
   End With

Cleanup:

   On Error GoTo 0
   LoadXML = strBrokenRules
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                         
End Function

Private Function MapGender(ByVal strGenderID As String) As String
'----------------------------------------------------------------------------------
'
' Purpose: To map the icw gender codes to the HL7 gender codes
'
' Inputs:
'     strGenderID    :  The ascribe gender id
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  14Oct04 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "MapGender"

Dim udtError As udtErrorState



   On Error GoTo ErrorHandler
   
   Select Case strGenderID
      Case "0"
         MapGender = "U"
      Case "1"
         MapGender = "M"
      Case "2"
         MapGender = "F"
      Case "3"
         MapGender = "U"
      Case Else
         MapGender = "U"
   End Select
   

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function



Private Function MapPatientTypes(ByVal strPatientTypeID As String) As String
'----------------------------------------------------------------------------------
'
' Purpose: Maps the ICW PatientType codes to the HL7 defined codes
'
' Inputs:
'     strPatientTypeID     :  ICW PatientTypeID
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  14Oct04 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "MapPatientTypes"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   Select Case strPatientTypeID
      Case "1"
         MapPatientTypes = "I"
      Case "2"
         MapPatientTypes = "O"
      Case Else
         MapPatientTypes = "U"
   End Select

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Private Function ReadAllergies(ByVal lngSessionID As Long, _
                               ByVal lngEpisodeID As Long, _
                               ByRef objAllergy As MSXML2.DOMDocument) As String
'----------------------------------------------------------------------------------
'
' Purpose: Given an EpisodeID, this function reads the Allergies with reactions
'          recorded against the episode from the ICW database and returns them
'          in a XML DOM.
'
' Inputs:
'     lngSessionID         :  Standard sessionid
'     lngEpisodeID         :  The database ID of the allergy in the Note table
'
' Outputs:
'     objAllergy           :  The DOM containing the Allergy data
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  13Sep04 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ReadAllergies"

Dim udtError As udtErrorState
                                                          
Dim strBrokenRules As String

Dim objAllergyRead As Object 'OCSRTL10.AllergyRead

Dim strExtraInfo As String
Dim strXML As String


   On Error GoTo ErrorHandler

   strExtraInfo = "Creating object '" & msOCSRTL10AppID & ".AllergyRead'"
   Set objAllergyRead = CreateObject(msOCSRTL10AppID & ".AllergyRead")
   
   strExtraInfo = "Calling OCSRTL10.AllergyRead.AllerygWithReactionByEpisodeXML"
   strXML = objAllergyRead.AllergyWithReactionByEpisodeXML(lngSessionID, _
                                                           lngEpisodeID, _
                                                           True)
   strExtraInfo = ""
   Set objAllergyRead = Nothing
   
   If RulesBroken(strXML) Then
      strBrokenRules = strXML
   Else
      strBrokenRules = LoadXML(strXML, _
                               objAllergy)
   End If
   
Cleanup:

   On Error Resume Next
   Set objAllergyRead = Nothing
   
   On Error GoTo 0
   ReadAllergies = strBrokenRules
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
                             
End Function
Private Function ReadConfig(ByVal strInstanceName As String, _
                            ByRef strSendingApp As String, _
                            ByRef strSendingFac As String, _
                            ByRef strReceivingApp As String, _
                            ByRef strReceivingFac As String, _
                            ByRef strMaximsIdAliasGroup As String, _
                            ByRef strMaximsEpisodeIdAliasGroup As String) As String
'----------------------------------------------------------------------------------
'
' Purpose: This function reads configuration information from the registry
'
' Inputs:
'
' Outputs:
'     strSendingApp                 :  the sending appication name (e.g. ascribe icw)
'     strSendingFac                 :  the sending facility name (e.g. Christies)
'     strReceivingApp               :  the receiving application name (e.g. Maxims)
'     strReceivingFac               :  the receiving facility name (e.g. Christies)
'     strMaximsIdAliasGroup         :  the name of the AliasGroup that holds the Maxims Patient Id
'     strMaximsEpisodeIdAliasGroup  :  the name of the AliasGroup that holds the Maxims Episode Id
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  13Sep04 EAC  Written
'
'----------------------------------------------------------------------------------

Const MAXIMS_EPISODEID_ALIASGROUP_REGISTRY_KEY = "Maxims_EpisodeID_AliasGroup"
Const MAXIMSID_ALIASGROUP_REGISTRY_KEY = "MaximsID_AliasGroup"
Const RECEIVING_APP_REGISTRY_KEY = "ReceivingApp"
Const RECEIVING_FAC_REGISTRY_KEY = "ReceivingFac"
Const REGISTRY_APP = "AllergyMsg"
Const REGISTRY_ASCRIBE = "ASCribe"
Const REGISTRY_PATH = "\HKEY_LOCAL_MACHINE\SOFTWARE"
Const REGISTRY_PROJECT = "MaximsIntegration"
Const SENDING_APP_REGISTRY_KEY = "SendingApp"
Const SENDING_FAC_REGISTRY_KEY = "SendingFac"
Const SUB_NAME = "ReadConfig"

Const ICWRTL10_APPID_REGISTRY_KEY = "ICWRTL10AppID"
Const IENRTL10_APPID_REGISTRY_KEY = "IENRTL10AppID"
Const OCSRTL10_APPID_REGISTRY_KEY = "OCSRTL10AppID"
Const INFRTL10_APPID_REGISTRY_KEY = "INFRTL10AppID"

Dim udtError As udtErrorState
                       
Dim objReg As regobj.Registry
Dim objKey As regobj.RegKey

Dim strBrokenRules As String

   On Error GoTo ErrorHandler

   Set objReg = New regobj.Registry
   Set objKey = objReg.RegKeyFromString(REGISTRY_PATH)
   
   On Error Resume Next

   objKey.SubKeys.Add (REGISTRY_ASCRIBE)
   Set objKey = objKey.SubKeys.Item(REGISTRY_ASCRIBE)
   
   objKey.SubKeys.Add REGISTRY_PROJECT
   Set objKey = objKey.SubKeys.Item(REGISTRY_PROJECT)
   
   objKey.SubKeys.Add REGISTRY_APP
   Set objKey = objKey.SubKeys.Item(REGISTRY_APP)
   
   With objKey
      .Values.Add SENDING_APP_REGISTRY_KEY, "", regobj.RegValueType.rvString
      .Values.Add SENDING_FAC_REGISTRY_KEY, "", regobj.RegValueType.rvString
      .Values.Add RECEIVING_APP_REGISTRY_KEY, "", regobj.RegValueType.rvString
      .Values.Add RECEIVING_FAC_REGISTRY_KEY, "", regobj.RegValueType.rvString
      .Values.Add MAXIMSID_ALIASGROUP_REGISTRY_KEY, "", regobj.RegValueType.rvString
      .Values.Add MAXIMS_EPISODEID_ALIASGROUP_REGISTRY_KEY, "", regobj.RegValueType.rvString
      
      strMaximsEpisodeIdAliasGroup = .Values.Item(MAXIMS_EPISODEID_ALIASGROUP_REGISTRY_KEY).Value
      strMaximsIdAliasGroup = .Values.Item(MAXIMSID_ALIASGROUP_REGISTRY_KEY).Value
      strSendingApp = .Values.Item(SENDING_APP_REGISTRY_KEY).Value
      strSendingFac = .Values.Item(SENDING_FAC_REGISTRY_KEY).Value
      strReceivingApp = .Values.Item(RECEIVING_APP_REGISTRY_KEY).Value
      strReceivingFac = .Values.Item(RECEIVING_FAC_REGISTRY_KEY).Value
   End With
   
   objKey.SubKeys.Add strInstanceName
   Set objKey = objKey.SubKeys.Item(strInstanceName)
   
   With objKey
      .Values.Add ICWRTL10_APPID_REGISTRY_KEY, "", regobj.RegValueType.rvString
      .Values.Add IENRTL10_APPID_REGISTRY_KEY, "", regobj.RegValueType.rvString
      .Values.Add OCSRTL10_APPID_REGISTRY_KEY, "", regobj.RegValueType.rvString
      .Values.Add INFRTL10_APPID_REGISTRY_KEY, "", regobj.RegValueType.rvString
   
      msICWRTL10AppID = .Values.Item(ICWRTL10_APPID_REGISTRY_KEY).Value
      msIENRTL10AppID = .Values.Item(IENRTL10_APPID_REGISTRY_KEY).Value
      msOCSRTL10AppID = .Values.Item(OCSRTL10_APPID_REGISTRY_KEY).Value
      msINFRTL10AppId = .Values.Item(INFRTL10_APPID_REGISTRY_KEY).Value
   End With

Cleanup:

   On Error GoTo 0
   ReadConfig = strBrokenRules
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
                       
End Function
Private Function ReadEpisode(ByVal lngSessionID As Long, _
                             ByVal lngEpisodeID As String, _
                             ByRef objEpisode As MSXML2.DOMDocument) As String
'----------------------------------------------------------------------------------
'
' Purpose: Reads the patient details from the ICW database and returns them to the
'          calling routine in an XML DOM.
'
' Inputs:
'     lngSessionID          :  Standard sessionid
'     lngEpisodeID          :  the database ID of the patient
'
' Outputs:
'     objEpisode            :  the XML DOM containing the patient information
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  13Sep04 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ReadEpisode"

Dim udtError As udtErrorState

Dim objIEN As Object 'IENRTL10.EpisodeRead
Dim objNode As MSXML2.IXMLDOMNode

Dim strBrokenRules As String
Dim strExtraInfo As String
Dim strXML As String


   On Error GoTo ErrorHandler

   strExtraInfo = "Creating object '" & msIENRTL10AppID & ".EpisodeRead'"
   Set objIEN = CreateObject(msIENRTL10AppID & ".EpisodeRead")
   
   strExtraInfo = "Calling IENRTL10.EpisodeRead.EpisodeXML"
   strXML = objIEN.EpisodeXML(lngSessionID, _
                             "<Parameters><Parameter name=""episodeXml"">" & _
                             "&lt;Episodes&gt;&lt;Episode EpisodeId=&quot;" & Format$(lngEpisodeID) & _
                             "&quot; EpisodeType=&quot;Clinical&quot; Type=&quot;Episode&quot; " & _
                             "TypeId=&quot;&quot;&gt;&lt;/Episode&gt;&lt;/Episodes&gt;" & _
                             "</Parameter></Parameters>")
   
   strExtraInfo = vbNullString
   Set objIEN = Nothing
   
   strBrokenRules = LoadXML(strXML, _
                            objEpisode)
      
   If NoRulesBroken(strBrokenRules) Then
      Set objNode = objEpisode.documentElement.selectSingleNode("Success[@Name='episodeXml']")
      If Not objNode Is Nothing Then
         strXML = objNode.Text
         strXML = XMLUnEscape(strXML)
         strBrokenRules = LoadXML(strXML, _
                                  objEpisode)
      Else
         Set objNode = objEpisode.documentElement.selectSingleNode("Error")
         strBrokenRules = FormatBrokenRulesXML(FormatBrokenRuleXML(objNode.Attributes.getNamedItem("Code").Text, objNode.selectSingleNode("Description").Text))
      End If
   End If
   
Cleanup:

   On Error Resume Next
   Set objIEN = Nothing
   
   On Error GoTo 0
   ReadEpisode = strBrokenRules
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
   
End Function
Private Function ReadNote(ByVal lngSessionID As Long, _
                          ByVal lngNoteID As Long, _
                          ByRef objNote As MSXML2.DOMDocument) As String
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
'  06Dec04 EAC  Written
'
'----------------------------------------------------------------------------------
Const SP_NAME = "pNoteXML"
Const SUB_NAME = "ReadNote"
Const trnDataTypeInt = 2

Dim objTRN As Object 'TRNRTL10.Transport

Dim udtError As udtErrorState

Dim strExtraInfo As String
Dim strParameterXML As String
Dim strReturn As String
                          
   On Error GoTo ErrorHandler

   strExtraInfo = "Creating object '" & msINFRTL10AppId & ".TransportProxy'"
   Set objTRN = CreateObject(msINFRTL10AppId & ".TransportProxy")
   strParameterXML = objTRN.CreateInputParameterXML("NoteID", _
                                                    trnDataTypeInt, _
                                                    4, _
                                                    lngNoteID)
   strReturn = objTRN.ExecuteSelectStreamSP(lngSessionID, _
                                            SP_NAME, _
                                            strParameterXML)
   Set objTRN = Nothing
   
   If NoRulesBroken(strReturn) Then _
         strReturn = LoadXML(strReturn, _
                              objNote)
Cleanup:

   On Error Resume Next
   Set objTRN = Nothing
   
   On Error GoTo 0
   ReadNote = strReturn
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup

End Function

Private Function TranslateAllergyReaction(ByVal lngSessionID As Long, _
                                          ByVal strInstanceName As String, _
                                          ByVal objAllergyReaction As MSXML2.IXMLDOMNode, _
                                          ByRef strMessage As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lnglngSessionID        :  Standard lngSessionID
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  06Dec04 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "TranslateAllergyReaction"

Dim udtError As udtErrorState

Dim objNode As MSXML2.IXMLDOMNode
Dim objAllergies As MSXML2.DOMDocument
Dim objEpisode As MSXML2.DOMDocument

Dim lngEpisodeID As Long

Dim strBrokenRules As String

   On Error GoTo ErrorHandler
      
   Set objNode = objAllergyReaction.Attributes.getNamedItem("EpisodeID")
   
   If (objNode Is Nothing) Then
      Err.Raise vbObjectError + 2, SUB_NAME, "Could not find 'EpisodeID' in the AllergyReaction XML"
   Else
      'read the episode id to which the allergy relates
      lngEpisodeID = CLng(objNode.Text)
   End If
   
   'read the Episode and Patient that the allergy record relates to
   strBrokenRules = ReadEpisode(lngSessionID, _
                                lngEpisodeID, _
                                objEpisode)
   
   If NoRulesBroken(strBrokenRules) Then
      'read the Allergy linked to the AllergyReaction note
      strBrokenRules = ReadAllergies(lngSessionID, _
                                     CLng(lngEpisodeID), _
                                     objAllergies)
   End If
   
   
   If NoRulesBroken(strBrokenRules) Then _
         strBrokenRules = BuildA60(strInstanceName, _
                                   objAllergies, _
                                   objEpisode, _
                                   strMessage)
                            
   If NoRulesBroken(strBrokenRules) Then _
         strMessage = AddMLLPControlCharacters(strMessage)

Cleanup:

   On Error Resume Next
   
   Set objAllergies = Nothing
   Set objEpisode = Nothing
   
   TranslateAllergyReaction = strBrokenRules
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Private Function TranslateNoteCancellation(ByVal lngSessionID As Long, _
                                           ByVal strInstanceName As String, _
                                           ByRef objCancelation As MSXML2.IXMLDOMNode, _
                                           ByRef strMessage As String) As String
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
'  06Dec04 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "TranslateNoteCancellation"

Dim udtError As udtErrorState

Dim objAllergies As MSXML2.DOMDocument
Dim objEpisode As MSXML2.DOMDocument
Dim objICWRTL10 As Object 'ICWRTL10.TableRead
Dim objNote As MSXML2.DOMDocument
Dim objTable As MSXML2.DOMDocument

Dim boolProcess As Boolean

Dim lngEpisodeID As Long
Dim lngNoteID As Long
Dim lngTableID As Long

Dim strReturn As String

   On Error GoTo ErrorHandler

   boolProcess = False
   
   lngNoteID = CLng(objCancelation.Attributes.getNamedItem("NoteID_Cancelled").Text)
   
   strReturn = ReadNote(lngSessionID, _
                        lngNoteID, _
                        objNote)

   If NoRulesBroken(strReturn) Then
      lngTableID = CLng(objNote.documentElement.Attributes.getNamedItem("TableID").Text)
   
      Set objICWRTL10 = CreateObject(msICWRTL10AppID & ".TableRead")
      strReturn = objICWRTL10.GetDescription(lngSessionID, lngTableID)
      Set objICWRTL10 = Nothing
   End If
   
   If NoRulesBroken(strReturn) Then
      If strReturn = "AllergyReaction" Then _
            boolProcess = True
   End If
   
   If NoRulesBroken(strReturn) And boolProcess Then
      'find the EpisodeId using the NoteID and the EpisodeNote table
      strReturn = FindEpisodeID(lngSessionID, _
                                lngNoteID, _
                                lngEpisodeID)
                                
      'read the Episode and Patient that the allergy record relates to
      If NoRulesBroken(strReturn) Then
         strReturn = ReadEpisode(lngSessionID, _
                                 lngEpisodeID, _
                                 objEpisode)
      End If
      
      If NoRulesBroken(strReturn) Then
         'read the Allergy linked to the AllergyReaction note
         strReturn = ReadAllergies(lngSessionID, _
                                   lngEpisodeID, _
                                   objAllergies)
      End If
      
      
      If NoRulesBroken(strReturn) Then _
            strReturn = BuildA60(strInstanceName, _
                                 objAllergies, _
                                 objEpisode, _
                                 strMessage)
                               
      If NoRulesBroken(strReturn) Then _
            strMessage = AddMLLPControlCharacters(strMessage)
   End If
   
Cleanup:

   On Error Resume Next
   Set objAllergies = Nothing
   Set objEpisode = Nothing
   Set objICWRTL10 = Nothing
   Set objNote = Nothing
   Set objTable = Nothing
   
   On Error GoTo 0
   TranslateNoteCancellation = strReturn
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function XMLUnEscape( _
                           ByVal strSource As String _
                         ) _
                         As String
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
Const SUB_NAME As String = "XMLUnEscape"
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
'  13Sep04 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "Translate"

Dim udtError As udtErrorState
                          
Dim objAudit As MSXML2.DOMDocument
Dim objNode As MSXML2.IXMLDOMNode
                          
Dim strBrokenRules As String

Dim strMessage As String

   On Error GoTo ErrorHandler

   ReadConfig InstanceName, "", "", "", "", "", ""
   
   'Load the Trigger XML into a DOM object
   strBrokenRules = LoadXML(AuditLogXML, _
                            objAudit)
                            
   If NoRulesBroken(strBrokenRules) Then
      'read the Allergy from the AuditLog
      strBrokenRules = LoadXML(objAudit.documentElement.Attributes.getNamedItem("DataXML").Text, _
                               objNode)
   End If
   
   If NoRulesBroken(strBrokenRules) Then
      Select Case LCase(objNode.firstChild.nodeName)
         Case "allergyreaction"
            strBrokenRules = TranslateAllergyReaction(SessionID, _
                                                      InstanceName, _
                                                      objNode.firstChild, _
                                                      strMessage)
         Case "notecancellation"
            strBrokenRules = TranslateNoteCancellation(SessionID, _
                                                       InstanceName, _
                                                       objNode.firstChild, _
                                                       strMessage)
         Case Else
            strBrokenRules = FormatBrokenRulesXML(FormatBrokenRuleXML("INVALID_AUDITLOG_ENTRY", _
                                                                      "Cannot process an auditlog row of type - " & _
                                                                      objNode.firstChild.nodeName))
      End Select
   End If
   
   
   If NoRulesBroken(strBrokenRules) Then Message = "<Files><File>" & strMessage & "</File></Files>"
   
Cleanup:

   On Error Resume Next
   Set objAudit = Nothing
   Set objNode = Nothing
   
   
   On Error GoTo 0
   Translate = strBrokenRules
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , AuditLogXML
   Resume Cleanup
   
End Function
