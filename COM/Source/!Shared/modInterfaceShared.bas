Attribute VB_Name = "modInterfaceShared"
Option Explicit
DefInt A-Z


'public constant declarations
Public Const APPID_DOM_OBJECT = "MSXML2.DOMDocument"

Public Const APPID_TRANSPORT_PROXY = "INFRTL10.TransportProxy"
Public Const APPID_TRANSPORT_PROXY_READ = "INFRTL10.TransportProxyRead"
Public Const APPID_TRANSPORT_PROXY_SECURITY = "INFRTL10.SecurityProxy"

Public Const CLOSE_ROOT_ELEMENT = "</Root>"
Public Const ROOT_ELEMENT = "<Root>"

Public Const XSLT_DIRECTORY = "\Data\"

Public mobjCache As ICWMetaSystem.MetaDataSearch

'module constant declarations
Private Const APPID_SCRIPTING_DICTIONARY = "Scripting.Dictionary"

Private Const CLASS_NAME = "modInterfaceShared"

Private Const SCHEMA_FILENAME_PARAMETER = XSLT_DIRECTORY & "v92inputparameterschema.xml"

Private Const XSLT_SQLALIASITEM_TO_ALIASES = XSLT_DIRECTORY & "sqlaliasitem2aliases.xslt"

'module level error constants
Private Const MISSING_PARAMETER_CODE = vbObjectError + 1000

Private Const NO_PARAMETERS_DESC = "No parameters have been received for validation."
Private Const NO_PARAMETERS_CODE = vbObjectError + 1001

Private Const XML_INVALID_CODE = vbObjectError + 1004
Private Const XML_INVALID_DESC = "The provided XML string failed validation against the schema."

Private Const ALIASGROUP_UNDEFINED_CODE = vbObjectError + 1005
Private Const ALIASGROUP_UNDEFINED_DESC = "The provided AliasGroup is not defined on the system."

Private Const XML_PARSE_FAILED_CODE = vbObjectError + 1006
Private Const XML_PARSE_FAILED_DESC = "The provided XML string failed to parse."

Public Function ConvertV92SoapReturn2BrokenRules(ByRef objDOM As MSXML2.DOMDocument) As String

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

Public Function CreateInputParameterXML(ByVal sessionId As Long, _
                                        ByVal MetadataItemName As String, _
                                        ByVal Parameters As Scripting.Dictionary, _
                                        Optional ByVal Refresh As Boolean = False) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     SessionID         :  Standard sessionid
'     MetadataItemName  :  The name of the stored proc or table
'     Parameters        :  A dictionary of name value pairs that supply the values to
'                          be sent to the SelectStream transport proxy call
'     Refresh           :  Optional flag to force refresh of metadata in the
'                          ICWMetaSystem object
'
' Outputs:
'
'     returns the ParameterXML required by the SelectStream call as an XML string
'     or errors as <BrokenRules/> XML string
'
' Modification History:
'  10Aug05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "CreateInputParameterXML"

Dim udtError As udtErrorState
                                                 
Dim objProc As ICWMetaSystem.Procedure

   On Error GoTo ErrorHandler

   If mobjCache Is Nothing Then Set mobjCache = New ICWMetaSystem.MetaDataSearch
   Set objProc = mobjCache.InsertProcedure(sessionId, _
                                          MetadataItemName, _
                                          Refresh)
   
   CreateInputParameterXML = HashValuesIntoProcedure(objProc, _
                                                     Parameters)
   
Cleanup:

   On Error Resume Next
   Set objProc = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Public Function FindTableNameFromTableID(ByVal sessionId As Long, _
                                         ByVal TableID As Long) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     SessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  01Nov05 EAC  Written
'
'----------------------------------------------------------------------------------
Const SP_NAME = "pTableXML"
Const SUB_NAME = "FindTableNameFromTableID"

Dim udtError As udtErrorState
                                          
Dim objTransRead As INFRTL10.TransportProxyRead
Dim xmlDOM As MSXML2.DOMDocument
Dim xmlNode As MSXML2.IXMLDOMNode

Dim strParamXML As String
Dim strReturn As String


   On Error GoTo ErrorHandler

   Set objTransRead = CreateObject(APPID_TRANSPORT_PROXY_READ)
   With objTransRead
      strParamXML = .CreateInputParameterXML("TableID", trnDataTypeInt, 4, TableID)
      strReturn = .ExecuteSelectStreamSP(sessionId, _
                                         SP_NAME, _
                                         strParamXML)
   End With
   Set objTransRead = Nothing
   
   If NoRulesBroken(strReturn) Then
      strReturn = LoadXML(ROOT_ELEMENT & strReturn & CLOSE_ROOT_ELEMENT, _
                          xmlDOM)
   End If
   
   If NoRulesBroken(strReturn) Then
      Set xmlNode = xmlDOM.documentElement.selectSingleNode("Table[@TableID='" & CStr(TableID) & "']")
      If xmlNode Is Nothing Then
         strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML(TABLE_DESC_NOT_FOUND_CODE, _
                                                              TABLE_DESC_NOT_FOUND_DESC & CStr(TableID)))
      Else
         strReturn = xmlNode.Attributes.getNamedItem("Description").Text
      End If
   End If
   
Cleanup:

   On Error Resume Next
   Set objTransRead = Nothing
   Set xmlDOM = Nothing
   Set xmlNode = Nothing
   
   FindTableNameFromTableID = strReturn
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Public Function GetLocationIDFromTerminalAlias(ByVal sessionId As Long, _
                                               ByVal terminalAlias As String, _
                                               ByRef LocationID As Long) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     sessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  21Nov06 EAC  Written
'
'----------------------------------------------------------------------------------

Const ALIAS_GROUP_NAME = "TerminalName"

Const LOCATION_NOT_FOUND_NUM = vbObjectError + 33333
Const LOCATION_NOT_FOUND_TEXT = "A valid locationID could not be found from the Terminal alias."

Const SP_NAME = "pLocationAliasByAliasAndAliasGroupIDXML"
Const SUB_NAME = "GetLocationIDFromTerminalAlias"

Dim udtError As udtErrorState
                                               
Dim objINF As INFRTL10.TransportProxyRead
Dim xmlDoc As MSXML2.DOMDocument

Dim lngAliasGroupID As Long

Dim strExtraInfo As String
Dim strLocationID As String
Dim strParameterXml As String
Dim strReturn As String



   On Error GoTo ErrorHandler

   LocationID = -1
   
   strExtraInfo = "Calling FindAliasGroupID for alias group " & ALIAS_GROUP_NAME
   strReturn = FindAliasGroupId(sessionId, _
                                ALIAS_GROUP_NAME, _
                                lngAliasGroupID)
                                
   If NoRulesBroken(strReturn) Then
   
      strExtraInfo = "Creating object '" & APPID_TRANSPORT_PROXY_READ & "'"
      Set objINF = CreateObject(APPID_TRANSPORT_PROXY_READ)
      
      strExtraInfo = "Creating the stored procedure input parameters"
      strParameterXml = objINF.CreateInputParameterXML("Alias", trnDataTypeVarChar, 255, terminalAlias) & _
                        objINF.CreateInputParameterXML("AliasGroupID", trnDataTypeInt, 4, lngAliasGroupID)
                        
      strExtraInfo = "Calling the stored procedure '" & SP_NAME & "'"
      strReturn = objINF.ExecuteSelectStreamSP(sessionId, _
                                               SP_NAME, _
                                               strParameterXml)
                                               
      Set objINF = Nothing
   
   End If
   
   If NoRulesBroken(strReturn) Then
      strExtraInfo = "Loading the stored procedure XML into the DOM"
      strReturn = LoadXML(ROOT_ELEMENT & _
                           strReturn & _
                           CLOSE_ROOT_ELEMENT, _
                           xmlDoc)
   End If
   

   If NoRulesBroken(strReturn) Then
      If xmlDoc.documentElement.childNodes.length > 0 Then
      
         strExtraInfo = "Reading the locationID from the stored procedure XML"
         strLocationID = xmlDoc.documentElement.selectSingleNode("LocationAlias/@LocationID").Text
         
         strExtraInfo = "Converting the locationID from a string to an integer"
         LocationID = Val(strLocationID)
      End If
         
      If (LocationID = -1) Then
         strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML(LOCATION_NOT_FOUND_NUM, _
                                                              LOCATION_NOT_FOUND_TEXT, _
                                                              "TerminalAlias = '" & terminalAlias & "'"))
      End If
      
   End If
   
   
Cleanup:

   On Error Resume Next
   Set objINF = Nothing
   
   GetLocationIDFromTerminalAlias = strReturn
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup

End Function

Private Function SetDefaultValue(ByVal intDataType As ICWMetaSystem.enuDataType) As Variant

   Select Case intDataType
      Case enuDataType.trnDataTypeVarChar, _
           enuDataType.trnDataTypeChar, _
           enuDataType.trnDataTypeText
         SetDefaultValue = vbNullString
      Case enuDataType.trnDataTypeInt, _
           enuDataType.trnDataTypeFloat, _
           enuDataType.trnDataTypeBit
         SetDefaultValue = "0"
      Case enuDataType.trnDataTypeDateTime
         SetDefaultValue = Null
      Case enuDataType.trnDataTypeUniqueIdentifier
         SetDefaultValue = ""
      Case enuDataType.trnDataTypeBase64Binary
         SetDefaultValue = "0"
   End Select
   
End Function
Public Function CreateDeleteParameterXML(ByVal sessionId As Long, _
                                         ByVal MetadataItemName As String, _
                                         ByVal Parameters As Scripting.Dictionary, _
                                         Optional ByVal Refresh As Boolean = False) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     SessionID         :  Standard sessionid
'     MetadataItemName  :  The name of the stored proc or table
'     Parameters        :  A dictionary of name value pairs that supply the values to
'                          be sent to the SelectStream transport proxy call
'     Refresh           :  Optional flag to force refresh of metadata in the
'                          ICWMetaSystem object
'
' Outputs:
'
'     returns the ParameterXML required by the SelectStream call as an XML string
'     or errors as <BrokenRules/> XML string
'
' Modification History:
'  10Aug05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "CreateSelectStreamParameterXML"

Dim udtError As udtErrorState
                                                 
Dim objProc As ICWMetaSystem.Procedure

   On Error GoTo ErrorHandler

   If mobjCache Is Nothing Then Set mobjCache = New ICWMetaSystem.MetaDataSearch
   Set objProc = mobjCache.DeleteProcedure(sessionId, _
                                          MetadataItemName, _
                                          Refresh)
   
   CreateDeleteParameterXML = HashValuesIntoProcedure(objProc, _
                                                      Parameters)
   
Cleanup:

   On Error Resume Next
   Set objProc = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Public Function CreateUpdateParameterXML(ByVal sessionId As Long, _
                                         ByVal RowID As Long, _
                                         ByVal MetadataItemName As String, _
                                         ByVal Parameters As Scripting.Dictionary, _
                                         Optional ByVal Refresh As Boolean = False) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     SessionID         :  Standard sessionid
'     MetadataItemName  :  The name of the stored proc or table
'     Parameters        :  A dictionary of name value pairs that supply the values to
'                          be sent to the SelectStream transport proxy call
'     Refresh           :  Optional flag to force refresh of metadata in the
'                          ICWMetaSystem object
'
' Outputs:
'
'     returns the ParameterXML required by the SelectStream call as an XML string
'     or errors as <BrokenRules/> XML string
'
' Modification History:
'  10Aug05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "CreateUpdateParameterXML"

Dim udtError As udtErrorState
                                                 
Dim objProc As ICWMetaSystem.Procedure

   On Error GoTo ErrorHandler

   If mobjCache Is Nothing Then Set mobjCache = New ICWMetaSystem.MetaDataSearch
   
   Set objProc = mobjCache.UpdateProcedure(sessionId, _
                                          MetadataItemName, _
                                          Refresh)
   
   ReadExistingValues sessionId, _
                      RowID, _
                      MetadataItemName, _
                      objProc
   
   CreateUpdateParameterXML = HashValuesIntoProcedure(objProc, _
                                                      Parameters)
   
Cleanup:

   On Error Resume Next
   Set objProc = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Public Function CreateSelectStreamParameterXML(ByVal sessionId As Long, _
                                               ByVal MetadataItemName As String, _
                                               ByVal Parameters As Scripting.Dictionary, _
                                               Optional ByVal Refresh As Boolean = False) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     SessionID         :  Standard sessionid
'     MetadataItemName  :  The name of the stored proc or table
'     Parameters        :  A dictionary of name value pairs that supply the values to
'                          be sent to the SelectStream transport proxy call
'     Refresh           :  Optional flag to force refresh of metadata in the
'                          ICWMetaSystem object
'
' Outputs:
'
'     returns the ParameterXML required by the SelectStream call as an XML string
'     or errors as <BrokenRules/> XML string
'
' Modification History:
'  10Aug05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "CreateSelectStreamParameterXML"

Dim udtError As udtErrorState
                                                 
Dim objProc As ICWMetaSystem.Procedure

   On Error GoTo ErrorHandler

   If mobjCache Is Nothing Then Set mobjCache = New ICWMetaSystem.MetaDataSearch
   Set objProc = mobjCache.SelectProcedure(sessionId, _
                                          MetadataItemName, _
                                          Refresh)
   
   CreateSelectStreamParameterXML = HashValuesIntoProcedure(objProc, _
                                                            Parameters)
   
Cleanup:

   On Error Resume Next
   Set objProc = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Public Function Errored(ByVal V92ReturnXML As String) As Boolean
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     V92ReturnXML      :  The V92 Return XML string
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  13Jul05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "Errored"

Dim udtError As udtErrorState



   On Error GoTo ErrorHandler

   Errored = (InStr(1, V92ReturnXML, "<Error") > 0)

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Errored = True
   Resume Cleanup
   
End Function

Public Function GenerateParameterValues(ByRef objList As MSXML2.IXMLDOMNodeList) As Scripting.Dictionary
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     objList        :  A NodeList object containing the <attribute name="..." value="..."/> elements
'
' Outputs:
'     a dictionary object of the values keyed by the name
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  12Aug05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GenerateParameterValues"

Dim udtError As udtErrorState

Dim objNode As MSXML2.IXMLDOMNode
Dim objParams As Scripting.Dictionary

Dim boolInsertOnly As Boolean
Dim varValue As Variant

   On Error GoTo ErrorHandler

   For Each objNode In objList
      If objNode.Attributes.getNamedItem("value") Is Nothing Then
         varValue = Null
      Else
         varValue = objNode.Attributes.getNamedItem("value").Text
      End If
         
      boolInsertOnly = False
      If Not objNode.Attributes.getNamedItem("insertonly") Is Nothing Then
         If objNode.Attributes.getNamedItem("insertonly").Text = "1" Then boolInsertOnly = True
      End If
      
      AddINFParameter objNode.Attributes.getNamedItem("name").Text, _
                      varValue, _
                      boolInsertOnly, _
                      objParams
   Next

   Set GenerateParameterValues = objParams
   
Cleanup:

   On Error Resume Next
   Set objNode = Nothing
   Set objParams = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Private Function HashValuesIntoProcedure(ByVal objProcedure As ICWMetaSystem.Procedure, _
                                         ByVal objParameters As Scripting.Dictionary) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     objProcedure      :  The Procedure object containing the metadata structure
'     objParameters     :  The Dictionary object containing the values to be hashed
'                          on to the metadata structure
'
' Outputs:
'
'     returns the metadata XML as a string or errors as <BrokenRules/> XML string
'
' Modification History:
'  10Aug05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "HashValuesIntoProcedure"

Dim udtError As udtErrorState
                                         
Dim objParameter As ICWMetaSystem.Parameter
Dim objNewParam As clsParameter

Dim lngLoop As Long
Dim lngPoint As Long

   On Error GoTo ErrorHandler

   If Not objParameters Is Nothing Then
      For lngLoop = 1 To objProcedure.Parameters.Count
         Set objParameter = objProcedure.Parameters(lngLoop)
         If objParameters.Exists(objParameter.ParameterName) Then
            If Not IsEmpty(objParameters.Item(objParameter.ParameterName)) Then
               
               Set objNewParam = objParameters.Item(objParameter.ParameterName)
               
               If objNewParam.ValueForInsertOnly Then
                  If IsNull(objParameter.ParameterValue) Then objParameter.ParameterValue = objNewParam.value
               Else
                  If Len(objNewParam.value) > 0 Then
                     objParameter.ParameterValue = XMLEscape(objNewParam.value)
                  End If
               End If
               
               If IsNull(objNewParam.value) Then
                  objParameter.ParameterValue = Null
               End If
               
               If objParameter.ParameterType = trnDataTypeDateTime Then
                  If Not IsNull(objParameter.ParameterValue) Then
                     lngPoint = InStr(1, objParameter.ParameterValue, ".")
                     If lngPoint > 0 Then objParameter.ParameterValue = Left$(objParameter.ParameterValue, lngPoint - 1)
                     If Len(objParameter.ParameterValue) = 0 Then objParameter.ParameterValue = Null
                  End If
               End If
            End If
         Else
            If IsNull(objParameter.ParameterValue) Then
               objParameter.ParameterValue = SetDefaultValue(objParameter.ParameterType)
            End If
         End If
      Next
   End If
   
   HashValuesIntoProcedure = objProcedure.XML
   
Cleanup:

   On Error Resume Next
   Set objParameter = Nothing

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function

Public Function ParseAliasXML(ByVal ElementName As String, _
                              ByRef DOM As MSXML2.DOMDocument) As String
'----------------------------------------------------------------------------------
'
' Purpose: Processes an individual alias xml element
'
' Inputs:
'     ElementName  :  Toplevel element name for the return XML object
'     DOM          :  The SQL Alias element object
'
' Outputs:
'     The v9.2 SOAP API Alias element XML string

' Modification History:
'  01Dec2003 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ParseAliasXML"

Dim objReturn As MSXML2.DOMDocument
Dim objAlias As MSXML2.IXMLDOMNode
Dim objRootElement As MSXML2.IXMLDOMElement
Dim objTransformed As MSXML2.DOMDocument

Dim uError As udtErrorState

Dim strAllReturn As String
Dim strReturn As String

   On Error GoTo ErrorHandler
   
   'create a DOM to work with
   Set objReturn = CreateObject(APPID_DOM_OBJECT)
   
   'create the root level element using the ElementName variable
   'usually this will be EntityAlias or EpisodeAlias
   Set objRootElement = objReturn.createElement(ElementName)
   
   'Set the root level element to be the document element of the return DOM object
   Set objReturn.documentElement = objRootElement
   
   For Each objAlias In DOM.documentElement.childNodes
      'for each match to the key, transform the sql xml to SOAP API xml
      strReturn = TransformXmlUsingXslFromFileIntoObject(objAlias.XML, _
                                                         App.Path & XSLT_SQLALIASITEM_TO_ALIASES, _
                                                         objTransformed)
      
      If RulesBroken(strReturn) Then
         'We have broken rules, so add it to the return
         strAllReturn = strAllReturn & strReturn
      Else
         'transformed ok, so add the transformed XML as a child of the root element
         If Not objTransformed.documentElement Is Nothing Then _
               objReturn.documentElement.appendChild objTransformed.documentElement
      End If
   Next
   
   If NoRulesBroken(strAllReturn) Then _
         strAllReturn = objReturn.XML 'everything successful, so return the transformed XML
         
   ParseAliasXML = strAllReturn
   
Cleanup:
   
   Set objReturn = Nothing
   Set objAlias = Nothing
   Set objRootElement = Nothing
   Set objTransformed = Nothing
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function
'Public Function CreateReturnValueXML(ByVal NameValue As String, _
'                                     ByVal DataValue As String) As String
''----------------------------------------------------------------------------------
''
'' Purpose: Creates a <Success/> element and returns it as text
''
'' Inputs:
''     NameValue      :  The value assigned to the "name" attribute of the <Success/> element
''     DataValue      :  The value assigned to the text of the <Success/> element
''
'' Outputs:
''     The <Success/> element as a string
''
'' Modification History:
''  01Dec2003 EAC  Written
''
''----------------------------------------------------------------------------------
'Const SUB_NAME = "CreateReturnValueXML"
'
'Dim uError As udtErrorState
'
'   On Error GoTo ErrorHandler
'
'   CreateReturnValueXML = "<Success Name=" & Chr(34) & NameValue & Chr(34) & ">" & _
'                          XMLEscape(DataValue) & _
'                          "</Success>"
'
'Cleanup:
'
'   On Error GoTo 0
'   BubbleOnError uError
'
'Exit Function
'
'ErrorHandler:
'
'   CaptureErrorState uError, CLASS_NAME, SUB_NAME
'   Resume Cleanup
'
'End Function


Public Sub AddINFParameter(ByVal ParameterName As String, _
                           ByVal ParameterValue As Variant, _
                           ByVal InsertOnly As Boolean, _
                           ByRef Parameters As Scripting.Dictionary)
'----------------------------------------------------------------------------------
'
' Purpose: Adds an input parameter of a given name and value to a collection of
'          parameters for a database call.
'
' Inputs:
'     ParameterName  :  Name of the new input parameter
'     ParameterValue :  Value of the new input parameter
'     Parameters     :  The collection of input parameters that the new parameter
'                       will be added to
'
' Outputs:
'     Parameters     :  The collection of input parameters with the new parameter
'                       added
'
' Modification History:
'  10Aug05 EAC  Written
'
'----------------------------------------------------------------------------------
                             
Const SUB_NAME = "AddINFParameter"

Dim ErrorState As udtErrorState

Dim objParam As clsParameter

   On Error GoTo ErrorHandler
   
   If Parameters Is Nothing Then Set Parameters = CreateObject(APPID_SCRIPTING_DICTIONARY)
      
   If Parameters.Exists(ParameterName) Then
      Set objParam = Parameters.Item(ParameterName)
   Else
      Set objParam = New clsParameter
      objParam.name = ParameterName
   End If
      
   objParam.value = ParameterValue
   objParam.ValueForInsertOnly = InsertOnly
   
   If Parameters.Exists(ParameterName) Then
      Set Parameters.Item(ParameterName) = objParam
   Else
      Parameters.Add ParameterName, objParam
   End If
                             
ExitPoint:

   On Error GoTo 0
   BubbleOnError ErrorState
   
Exit Sub

ErrorHandler:

   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME
   Resume ExitPoint
   
End Sub

Public Sub AddInputParameter(ByVal ParameterName As String, _
                             ByVal ParameterValue As String, _
                             ByRef Parameters As Scripting.Dictionary)
'----------------------------------------------------------------------------------
'
' Purpose: Adds an input parameter of a given name and value to a collection of
'          input parameters.
'
' Inputs:
'     ParameterName  :  Name of the new input parameter
'     ParameterValue :  Value of the new input parameter
'     Parameters     :  The collection of input parameters that the new parameter
'                       will be added to
'
' Outputs:
'     Parameters     :  The collection of input parameters with the new parameter
'                       added
'
' Modification History:
'  12Jan2004 EAC  Written
'
'----------------------------------------------------------------------------------
                             
Const SUB_NAME = "AddInputParameter"

Dim ErrorState As udtErrorState


   On Error GoTo ErrorHandler
   
   If Parameters Is Nothing Then Set Parameters = CreateObject(APPID_SCRIPTING_DICTIONARY)
   
   If Parameters.Exists(ParameterName) Then
      Parameters.Item(ParameterName) = ParameterValue
   Else
      Parameters.Add ParameterName, ParameterValue
   End If
                             
ExitPoint:

   On Error GoTo 0
   BubbleOnError ErrorState
   
Exit Sub

ErrorHandler:

   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME
   Resume ExitPoint
   
End Sub

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


Public Function GetInputParameterXml(ByRef Parameters As Scripting.Dictionary) As String
'----------------------------------------------------------------------------------
'
' Purpose: Takes a collection of input parameters and parses them into the V9.2
'          Parameter schema XML.
'
' Inputs:
'     Parameters     :  The collection of input parameters
'
' Outputs:
'     Returns a XML string containing the input parameters
'
' Modification History:
'  12Jan2004 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "GetInputParameterXML"

Dim ErrorState As udtErrorState

Dim lngLoop As Long

Dim strReturn As String

   On Error GoTo ErrorHandler
      
   strReturn = "<Parameters>"
   
   If Parameters.Count > 0 Then
      For lngLoop = 0 To Parameters.Count - 1
         strReturn = strReturn & "<Parameter name=""" & Parameters.Keys(lngLoop) & """>" & _
                                 XMLEscape(Parameters.Items(lngLoop)) & _
                                 "</Parameter>"
      Next
   End If
   
   strReturn = strReturn & "</Parameters>"
   
   GetInputParameterXml = strReturn
   
ExitPoint:

   On Error GoTo 0
   BubbleOnError ErrorState
   
Exit Function

ErrorHandler:

   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME
   Resume ExitPoint
   
End Function

Public Sub ParseAliasList(ByRef objAliasList As MSXML2.IXMLDOMNodeList, _
                          ByRef objSearch As Scripting.Dictionary)
'----------------------------------------------------------------------------------
'
' Purpose: This function parses a Nodelist object of Alias elements into a Dictionary
'          object if they have a "SearchOrder" attribute defined in the Alias XML.
'          The Alias XML is reference from the Dictionary using the SearchOrder
' Inputs:
'     objAliasList   :  The list of Alias elements to be parsed
'
' Outputs:
'     objSearch      :  The dictionary object containing the Alias elements that
'                       had SearchOrder attributes
'
' Modification History:
'  01Dec2003 EAC  Written
'
'----------------------------------------------------------------------------------
Const SUB_NAME = "ParseAliasList"

Dim objNode As MSXML2.IXMLDOMNode

Dim uError As udtErrorState

Dim lngSearchOrder As Long

   On Error GoTo ErrorHandler
   
   'create a Dictionary object if needed
   If objSearch Is Nothing Then Set objSearch = CreateObject(APPID_SCRIPTING_DICTIONARY)
   
   'for each Alias element in the list
   For Each objNode In objAliasList
      'check to see if it has a SearchOrder attribute
      If Not objNode.Attributes.getNamedItem("SearchOrder") Is Nothing Then
         'if it does, read the SearchOrder attribute value
         lngSearchOrder = Val(objNode.Attributes.getNamedItem("SearchOrder").Text)
      Else
         lngSearchOrder = objSearch.Count + 1
      End If
      
      'if the SearchOrder is greater than zero
      If lngSearchOrder > 0 Then
         'check to see if it already exists in the Dictionary
         If objSearch.Exists(Format$(lngSearchOrder)) Then
            'does exist so update the dictionary item
            objSearch.Item(Format$(lngSearchOrder)) = objNode
         Else
            'does not exist, so add it to the dictionary item
            objSearch.Add Format$(lngSearchOrder), objNode
         End If
      End If
      
   Next
                           
Cleanup:

   Set objNode = Nothing
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub
   
ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Public Function PackageErrorAsReturnXML(ByRef uError As udtErrorState) As String
'----------------------------------------------------------------------------------
'
' Purpose: This function takes the user defined ErrorState type and
'          transforms it into the defined V9.2 Returns XML schema.
'          The function returns the reformatted type as a string.
'
' Inputs:
'     strBrokenRules    :  The XML string to be loaded into a DOM object
'
' Outputs:
'
'
' Modification History:
'  01Dec2003 EAC  Written
'
'----------------------------------------------------------------------------------

   On Error Resume Next
   
   PackageErrorAsReturnXML = "<Return><Error Code=""" & Format$(uError.Number) & _
                             """><Source><![CDATA[" & uError.Source & "]]></Source>" & _
                             "<Description><![CDATA[" & uError.Description & "]]></Description></Error></Return>"
   
   On Error GoTo 0
   
End Function
Public Sub PackageBrokenRulesAsReturnXML(ByVal BrokenRules As String, _
                                         ByRef objReturn As MSXML2.DOMDocument)
'----------------------------------------------------------------------------------
'
' Purpose: This function takes BrokenRules XML and transforms it into the defined V9.2
'          Returns XML schema. The function returns the reformatted XML as a string.
'
' Inputs:
'     strBrokenRules    :  The XML string to be loaded into a DOM object
'
' Outputs:
'
'
' Modification History:
'  01Dec2003 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "PackageBrokenRulesAsReturnXML"

Dim objCodeAttribute As MSXML2.IXMLDOMNode
Dim objDescriptionElement As MSXML2.IXMLDOMNode
Dim objDOM As MSXML2.DOMDocument
Dim objErrorElement As MSXML2.IXMLDOMNode
Dim objNode As MSXML2.IXMLDOMNode
Dim objSourceElement As MSXML2.IXMLDOMNode

Dim uErrorState As udtErrorState

Dim strExtraInfo As String
Dim strReturn As String
   
   
   On Error GoTo ErrorHandler
   
   If objReturn Is Nothing Then _
         LoadXML "<Return/>", objReturn
      
   
   'Load the BrokenRules into a DOM object
   strReturn = LoadXML(ROOT_ELEMENT & BrokenRules & CLOSE_ROOT_ELEMENT, objDOM)
   
   With objReturn
      If NoRulesBroken(strReturn) Then
         'for each BrokenRule
         For Each objNode In objDOM.documentElement.childNodes
            'Create a new Error element
            Set objCodeAttribute = .createNode(NODE_ATTRIBUTE, "Code", vbNullString)
            objCodeAttribute.Text = objNode.firstChild.Attributes.getNamedItem("Code").Text
            
            Set objSourceElement = .createNode(NODE_ELEMENT, "Source", vbNullString)
            
            Set objDescriptionElement = .createNode(NODE_ELEMENT, "Description", vbNullString)
            objDescriptionElement.Text = "<![CDATA[" & _
                                   objNode.firstChild.Attributes.getNamedItem("Text").Text & _
                                   "]]>"

            Set objErrorElement = .createNode(NODE_ELEMENT, "Error", vbNullString)
            
            objErrorElement.Attributes.setNamedItem objCodeAttribute
            objErrorElement.appendChild objSourceElement
            objErrorElement.appendChild objDescriptionElement
            
            .documentElement.appendChild objErrorElement
         Next
      Else
         'brokenrules XML was invalid, so return a default error
         Set objCodeAttribute = .createNode(NODE_ATTRIBUTE, "Code", vbNullString)
         objCodeAttribute.Text = Format$(vbObjectError + 2)
         
         Set objSourceElement = objReturn.createNode(NODE_ELEMENT, "Source", vbNullString)
         objSourceElement.Text = "<![CDATA[" & _
                                 BrokenRules & _
                                 "]]>"
         
         Set objDescriptionElement = .createNode(NODE_ELEMENT, "Description", vbNullString)
         objDescriptionElement.Text = "BrokenRules XML is invalid - cannot reformat to return via SOAP"
         
         Set objErrorElement = objReturn.createNode(NODE_ELEMENT, "Error", vbNullString)
         
         objErrorElement.Attributes.setNamedItem objCodeAttribute
         objErrorElement.appendChild objSourceElement
         objErrorElement.appendChild objDescriptionElement
         
         .documentElement.appendChild objErrorElement
         
      End If
   
   End With
   
Cleanup:

   Set objCodeAttribute = Nothing
   Set objDescriptionElement = Nothing
   Set objDOM = Nothing
   Set objErrorElement = Nothing
   Set objNode = Nothing
   Set objSourceElement = Nothing
   
   On Error GoTo 0
   BubbleOnError uErrorState
   
Exit Sub

ErrorHandler:

   CaptureErrorState uErrorState, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
   
End Sub

Public Function LoadAndValidateXML(ByVal strXML As String, _
                                   ByVal strSchemaFileName As String, _
                                   ByRef objDOM As MSXML2.DOMDocument) As String
'----------------------------------------------------------------------------------
'
' Purpose: This function loads a XML string into a DOM object, checks for
'          parsing errors and validates the XML against a defined XML schema
'
' Inputs:
'     strXML            :  The XML string to be loaded into a DOM object
'     strSchemaFileName :  The full name and path of the XML Schema file
'
' Outputs:
'     objDOM            :  The DOM object with the XML loaded
'
' Modification History:
'  01Dec2003 EAC  Written
'
'----------------------------------------------------------------------------------
Const SUB_NAME = "LoadAndValidateXML"

Dim objSchemaCache As MSXML2.XMLSchemaCache

Dim uError As udtErrorState

Dim strBrokenRules As String
Dim strParseError As String

   On Error GoTo ErrorHandler
                                    
   'create a schema cache object
   Set objSchemaCache = CreateObject("MSXML2.XMLSchemaCache")
   
   'load the schema into the cache
   objSchemaCache.Add "", strSchemaFileName
   
   'create the DOM if necessary
   If objDOM Is Nothing Then Set objDOM = CreateObject(APPID_DOM_OBJECT)
   
   'assign the schemacache to the DOM
   Set objDOM.schemas = objSchemaCache
   
   With objDOM
      .validateOnParse = True
      'load the XML string into the DOM
      .LoadXML strXML
            
      If .parseError.errorCode <> 0 Then
         'return an error - Xml not valid
         strParseError = GetDomParseError(.parseError)
         strBrokenRules = FormatBrokenRulesXML(FormatBrokenRuleXML(XML_INVALID_CODE, _
                                                                   XML_INVALID_DESC & " - " & _
                                                                   strParseError))
      End If
   End With
                                    
   'remove the schema from the schema object
   objSchemaCache.Remove ""
   
Cleanup:

   Set objSchemaCache = Nothing
   
   'return any broken rules
   LoadAndValidateXML = strBrokenRules
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Function


ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME, "strXML = '" & strXML & "'; strSchemaFileName='" & strSchemaFileName & "'"
   Resume Cleanup
   
End Function

Public Function LoadXML(ByVal strXML As String, _
                        ByRef objDOM As MSXML2.DOMDocument) As String
'----------------------------------------------------------------------------------
'
' Purpose: This function loads a XML string into a DOM object and checks for
'          parsing errors
'
' Inputs:
'     strXML   :  The XML string to be loaded into a DOM object
'
' Outputs:
'     objDOM   :  The DOM object with the XML loaded
'
' Modification History:
'  01Dec2003 EAC  Written
'
'----------------------------------------------------------------------------------
                                    
Const SUB_NAME = "LoadXML"

Dim uError As udtErrorState

Dim strBrokenRules As String
Dim strParseError As String

   On Error GoTo ErrorHandler
                                    
   'create the DOM if necessary
   If objDOM Is Nothing Then Set objDOM = CreateObject(APPID_DOM_OBJECT)
   
   With objDOM
      '.preserveWhiteSpace = True
      .LoadXML strXML
            
      If .parseError.errorCode <> 0 Then
         'return an error - Xml not valid
         strParseError = GetDomParseError(.parseError)
         strBrokenRules = FormatBrokenRulesXML(FormatBrokenRuleXML(XML_PARSE_FAILED_CODE, _
                                                                   XML_PARSE_FAILED_DESC & " - " & _
                                                                   strParseError))
      End If
   End With
                                    
Cleanup:

   'return any broken rules
   LoadXML = strBrokenRules
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Function


ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME, "strXML = '" & strXML & "'"
   Resume Cleanup
   
End Function


Public Sub ReadExistingValues(ByVal sessionId As Long, _
                              ByVal RowID As Long, _
                              ByVal TableName As String, _
                              ByRef Procedure As ICWMetaSystem.Procedure)
'----------------------------------------------------------------------------------
'
' Purpose: Reads the existing values from the database and merges them into the
'          Parameters object
'
' Inputs:
'     SessionID         :  Standard sessionid
'     RowID             :  The primary key of the data row
'     TableName         :  The name of the table containing the row
'
' Outputs:
'     Params            :  The Parameters object
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  12Sep05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ReadExistingValues"

Dim udtError As udtErrorState
                              
Dim objDOM As MSXML2.DOMDocument
Dim objNode As MSXML2.IXMLDOMNode
Dim objParam As ICWMetaSystem.Parameter
Dim objProxyRead As INFRTL10.TransportProxyRead

Dim lngLoop As Long
Dim lngPoint As Long

Dim strDate As String
Dim strParameterXml As String
Dim strReturn As String


   On Error GoTo ErrorHandler

   Set objProxyRead = CreateObject(APPID_TRANSPORT_PROXY_READ)
   strParameterXml = objProxyRead.CreateInputParameterXML("RowID", trnDataTypeInt, 4, RowID)
   strReturn = objProxyRead.ExecuteSelectStreamSP(sessionId, _
                                                  "p" & TableName & "XML", _
                                                  strParameterXml)
   Set objProxyRead = Nothing

   If NoRulesBroken(strReturn) Then strReturn = LoadXML(strReturn, objDOM)
   
   If NoRulesBroken(strReturn) Then
      For lngLoop = 1 To Procedure.Parameters.Count
         Set objParam = Procedure.Parameters.Item(lngLoop)
         Set objNode = objDOM.documentElement.selectSingleNode("@" & objParam.ParameterName)
         If Not objNode Is Nothing Then
            If objParam.ParameterType = trnDataTypeDateTime Then
               strDate = objNode.Text
               lngPoint = InStr(1, strDate, ".")
               If lngPoint > 0 Then strDate = Left$(strDate, lngPoint - 1)
               objParam.ParameterValue = strDate
            Else
               objParam.ParameterValue = XMLEscape(objNode.Text)
            End If
         End If
      Next
   End If
   
Cleanup:

   On Error Resume Next
   If Not objDOM Is Nothing Then Set objDOM = Nothing
   If Not objNode Is Nothing Then Set objNode = Nothing
   If Not objProxyRead Is Nothing Then Set objProxyRead = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub
Public Sub ReturnSuccess(ByVal ParameterName As String, _
                         ByVal ParameterValue As String, _
                         ByRef DocReturn As MSXML2.DOMDocument)

Const SUB_NAME = "ReturnSuccess"

Dim objDOM As MSXML2.DOMDocument
Dim objNameAttribute As MSXML2.IXMLDOMNode
Dim objSuccessElement As MSXML2.IXMLDOMNode

Dim uErrorState As udtErrorState

Dim strExtraInfo As String


   On Error GoTo ErrorHandler
   
   If DocReturn Is Nothing Then _
         LoadXML "<Return/>", DocReturn
   
   With DocReturn
      Set objNameAttribute = .createNode(NODE_ATTRIBUTE, "Name", vbNullString)
      objNameAttribute.Text = XMLEscape(ParameterName)
         
      Set objSuccessElement = .createNode(NODE_ELEMENT, "Success", vbNullString)
      objSuccessElement.Text = XMLEscape(ParameterValue)
      
      objSuccessElement.Attributes.setNamedItem objNameAttribute
      
      .documentElement.appendChild objSuccessElement
   End With
   
Cleanup:
   
   On Error GoTo 0
   
   Set objDOM = Nothing
   Set objNameAttribute = Nothing
   Set objSuccessElement = Nothing
   
   BubbleOnError uErrorState
   
Exit Sub

ErrorHandler:

   CaptureErrorState uErrorState, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
      
End Sub

Public Function XMLUnEscape(ByVal strSource As String) As String
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

Public Function ValidateParameters(ByRef Parameters As Scripting.Dictionary, _
                                   ByVal ParameterNames As String) As String
'----------------------------------------------------------------------------------
'
' Purpose: Given a list pipe delimited parameter names, this function ensures that
'          each parameter is found in the Parameters dictionary object. A broken rule
'          is returned for each parameter that is missing.
'
' Inputs:
'     Parameters     :  A dictionary object containing the parameters sent via SOAP
'     ParameterNames :  A pipe delimited string containing the required parameters
'
' Outputs:
'
'     Returns missing parameters as broken rules XML
'     Returns success as an empty string
'
' Modification History:
'  18Nov2003 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ValidateParameters"

Dim uErrorState As udtErrorState

Dim lngLoop As Long
Dim lngStart As Long
Dim lngStop As Long

Dim strBrokenRules As String
Dim astrParameters() As String


   On Error GoTo ErrorHandler
   
   If Parameters.Count = 0 Then strBrokenRules = FormatBrokenRulesXML(FormatBrokenRuleXML(NO_PARAMETERS_CODE, _
                                                                                          NO_PARAMETERS_DESC))
   
   If NoRulesBroken(strBrokenRules) Then
      
      astrParameters = Split(ParameterNames, "|")
            
      lngStart = LBound(astrParameters)
      lngStop = UBound(astrParameters)
      
      For lngLoop = lngStart To lngStop
         If Not Parameters.Exists(astrParameters(lngLoop)) Then
            strBrokenRules = strBrokenRules & FormatBrokenRuleXML(MISSING_PARAMETER_CODE, _
                                                                  "Required Parameter '" & astrParameters(lngLoop) & "' is missing from the received ParameterXML.")
         End If
      Next
      
      If Len(strBrokenRules) > 0 Then strBrokenRules = FormatBrokenRulesXML(strBrokenRules)
   End If
   
Cleanup:

   ValidateParameters = strBrokenRules
   
   On Error GoTo 0
   BubbleOnError uErrorState
   
Exit Function


ErrorHandler:

   CaptureErrorState uErrorState, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function ParseAliasNode(ByVal lngSessionID As Long, _
                               ByRef objAlias As MSXML2.IXMLDOMNode, _
                               ByRef lngAliasGroupID As Long, _
                               ByRef strAlias As String) As String
'----------------------------------------------------------------------------------
'
' Purpose: This function reads an Alias element object and returns the AliasGroupID
'          and the Alias text from the Alias XML.
' Inputs:
'     lngSessionID      :  The standard Session ID
'     objAlias          :  The Alias XML object
'
' Outputs:
'     lngAliasGroupID   :  The database ID of the AliasGroup from the Alias element
'     strAlias          :  The value of the Alias element
'
' Modification History:
'  01Dec2003 EAC  Written
'
'----------------------------------------------------------------------------------
Const SUB_NAME = "ParseAliasNode"

Dim uError As udtErrorState

Dim strAliasGroup As String
Dim strReturn As String


   On Error GoTo ErrorHandler
   
   strReturn = vbNullString
   'XML looks like <AliasGroup="xxxx" AliasGroupId="" SearchOrder="" AliasId="">Some alias description</Alias>
   'where the last three attributes are no mandatory
   
   strAlias = objAlias.Text
   
   If Not objAlias.Attributes.getNamedItem("AliasGroupID") Is Nothing Then _
         lngAliasGroupID = objAlias.Attributes.getNamedItem("AliasGroupId").Text
   
   If lngAliasGroupID = 0 Then
      'retrieve the AliasGroup text - this should always be present as it is mandatory in the schema
      strAliasGroup = objAlias.Attributes.getNamedItem("AliasGroup").Text
      
      'lookup the AliasGroupId using the AliasGroup
      strReturn = FindAliasGroupId(lngSessionID, strAliasGroup, lngAliasGroupID)
   End If
   
Cleanup:

   ParseAliasNode = strReturn
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Public Function FindAliasGroupId(ByVal sessionId As Long, _
                                 ByVal AliasGroup As String, _
                                 ByRef AliasGroupId As Long) As String
'----------------------------------------------------------------------------------
'
' Purpose: Given an AliasGroup, this function returns the database ID of the AlaisGroup
'
' Inputs:
'     SessionID      :  Standard Session ID
'     AliasGroup     :  The AliasGroup description for which an ID is to be found
'
' Outputs:
'     AliasGroupID   :  The database ID of the AliasGroup parameter
'
' Modification History:
'  01Dec2003 EAC  Written
'
'----------------------------------------------------------------------------------

Const SP_NAME = "pAliasGroupListByDescriptionXML"
Const SUB_NAME = "FindAliasGroupId"

Dim objDOM As MSXML2.DOMDocument
Dim objINFRead As INFRTL10.TransportProxyRead

Dim uError As udtErrorState

Dim strParameters As String
Dim strReturn As String
Dim strXML As String

   On Error GoTo ErrorHandler
   
   AliasGroupId = -1
   
   'create the transport layer object
   Set objINFRead = CreateObject(APPID_TRANSPORT_PROXY_READ)
   
   'add the required stored procedure parameters
   strParameters = objINFRead.CreateInputParameterXML("Description", trnDataTypeVarChar, 50, AliasGroup)
   
   'execute the stored procedure
   strXML = ROOT_ELEMENT & _
            objINFRead.ExecuteSelectStreamSP(sessionId, _
                                               SP_NAME, _
                                               strParameters) & _
            CLOSE_ROOT_ELEMENT
   
   'clear down the transport layer object
   Set objINFRead = Nothing
   
   'load the XML returned by the stored procedure into a DOM object
   strReturn = LoadXML(strXML, objDOM)
   
   If NoRulesBroken(strReturn) Then
      'check to see if a match was returned
      If objDOM.documentElement.firstChild Is Nothing Then
         'if no match returned then return a broken rule
         strReturn = FormatBrokenRulesXML(FormatBrokenRuleXML(ALIASGROUP_UNDEFINED_CODE, _
                                                              ALIASGROUP_UNDEFINED_DESC & _
                                                              " AliasGroup = '" & AliasGroup & "'"))
      Else
         'found a match, so return the AliasGroupId
         AliasGroupId = CLng(objDOM.documentElement.firstChild.Attributes.getNamedItem("AliasGroupID").Text)
      End If
   End If
                                 
Cleanup:

   Set objINFRead = Nothing
   Set objDOM = Nothing
   
   FindAliasGroupId = strReturn
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function


Public Function TransformXmlUsingXslFromFile(ByVal XML As String, _
                                             ByVal XSLT_FileName As String) As String
                             
Const SUB_NAME = ".TransformXmlUsingXslFromFile"

Dim objXML As MSXML2.DOMDocument

Dim udtError As udtErrorState
                             
Dim strReturn As String

   On Error GoTo ErrorHandler
   
   strReturn = TransformXmlUsingXslFromFileIntoObject(XML, XSLT_FileName, objXML)
   
   If NoRulesBroken(strReturn) Then strReturn = objXML.documentElement.XML

Cleanup:

   TransformXmlUsingXslFromFile = strReturn
   
   Set objXML = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError
   
Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function
Public Function TransformXmlUsingXslFromFileIntoObject(ByVal XML As String, _
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
   Set objXSL = CreateObject(APPID_DOM_OBJECT)
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
      Set objXML = CreateObject(APPID_DOM_OBJECT)
      With objXML
         '.preserveWhiteSpace = True
         .LoadXML XML
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

Public Function InterfaceLogin(ByVal ParameterXML As String) As String
                       
                       
Const SUB_NAME = "InterfaceLogin"

Const PARAM_USERNAME = "username"
Const PARAM_PASSWORD = "password"
Const PARAM_LOCATION = "location"
Const LOGIN_PARAMETERS = PARAM_LOCATION & "|" & PARAM_PASSWORD & "|" & PARAM_USERNAME

Dim objDOM As MSXML2.DOMDocument
Dim objParameters As Scripting.Dictionary
Dim objReturn As MSXML2.DOMDocument
Dim objSecurity As INFRTL10.SecurityProxy

Dim udtError As udtErrorState

Dim lngLocationID As Long

Dim strLocation As String
Dim strPassword As String
Dim strReturn As String
Dim strUserName As String

   On Error GoTo ErrorHandler
                      
   'return the EntityXML to be saved from the ParameterXML
   strReturn = ParseParameterXML(ParameterXML, objParameters)
   
   'check that we have the required parameters
   If NoRulesBroken(strReturn) Then strReturn = ValidateParameters(objParameters, LOGIN_PARAMETERS)
      
   If NoRulesBroken(strReturn) Then
      
      strUserName = objParameters.Item(PARAM_USERNAME)
      strPassword = objParameters.Item(PARAM_PASSWORD)
      strLocation = objParameters.Item(PARAM_LOCATION)
      
      'find the LocationID from the Location
      '!!**
      
   End If
   
   If NoRulesBroken(strReturn) Then
      Set objSecurity = CreateObject(APPID_TRANSPORT_PROXY_SECURITY)
      strReturn = objSecurity.LoginUser(strUserName, strPassword, lngLocationID, False)
      Set objSecurity = Nothing
   End If
      
   If NoRulesBroken(strReturn) Then
      strReturn = LoadXML(strReturn, objDOM)
   End If
   
   If RulesBroken(strReturn) Then
      PackageBrokenRulesAsReturnXML strReturn, objReturn
   Else
      ReturnSuccess "SessionID", objDOM.documentElement.Attributes.getNamedItem("SessionID").Text, objReturn
   End If
   
   InterfaceLogin = objReturn.XML
   
Cleanup:

   On Error GoTo 0
   Set objDOM = Nothing
   Set objParameters = Nothing
   Set objReturn = Nothing
   Set objSecurity = Nothing
      
   BubbleOnError udtError
   
Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Function InterfaceLogout(ByVal sessionId As Long) As String
'----------------------------------------------------------------------------------
'
' Purpose: Uses the security component to logout an interface session
'
' Inputs:
'     SessionID   :  Standard SessionID
'
' Outputs:
'
'
' Modification History:
'  10Dec2003 EAC  Written
'
'----------------------------------------------------------------------------------
                       
Const SUB_NAME = "InterfaceLogout"

Dim objReturn As MSXML2.DOMDocument
Dim objSecurity As INFRTL10.SecurityProxy

Dim udtError As udtErrorState

Dim strReturn As String


   On Error GoTo ErrorHandler
   
   Set objSecurity = CreateObject(APPID_TRANSPORT_PROXY_SECURITY)
   strReturn = objSecurity.LogoutUser(sessionId)
   Set objSecurity = Nothing
   
   If RulesBroken(strReturn) Then
      PackageBrokenRulesAsReturnXML strReturn, objReturn
   Else
      ReturnSuccess "Logout", Format$(sessionId), objReturn
   End If
   
   InterfaceLogout = objReturn.XML
   
Cleanup:

   On Error GoTo 0
   
   Set objReturn = Nothing
   Set objSecurity = Nothing
   
   BubbleOnError udtError
   
Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function
Public Function ParseParameterXML(ByVal ParameterXML As String, _
                                  ByRef Parameters As Scripting.Dictionary) As String
'----------------------------------------------------------------------------------
'
' Purpose: This function takes the ParameterXML string and validates it against the
'          schema. Each parameter is then parsed into a Dictionary object
' Inputs:
'     ParameterXML      :  The parameters as an XML string
'
' Outputs:
'     Parameters        :  The dictionary object containing the parsed parameters
'
' Modification History:
'  01Dec2003 EAC  Written
'
'----------------------------------------------------------------------------------
Const SUB_NAME = "ParseParameterXML"

Dim objDOM As MSXML2.DOMDocument
Dim objNode As MSXML2.IXMLDOMNode

Dim uError As udtErrorState

Dim strBrokenRules As String
Dim strParamName As String
Dim strParamValue As String

   On Error GoTo ErrorHandler
   
   'Load and validate the ParameterXML
   strBrokenRules = LoadAndValidateXML(ParameterXML, _
                                       App.Path & SCHEMA_FILENAME_PARAMETER, _
                                       objDOM)
   
   'If loaded ok
   If NoRulesBroken(strBrokenRules) Then
      
      If Parameters Is Nothing Then Set Parameters = CreateObject(APPID_SCRIPTING_DICTIONARY)
         
      For Each objNode In objDOM.documentElement.childNodes
         'for each parameter element read the name and parameter value
         strParamName = objNode.Attributes.getNamedItem("name").Text
         strParamValue = objNode.Text
         'if the parameter exists, update it else add it to the dictionary
         If Parameters.Exists(strParamName) Then
            Parameters.Item(strParamName) = strParamValue
         Else
            Parameters.Add strParamName, strParamValue
         End If
      Next
   End If
   
Cleanup:

   Set objDOM = Nothing
   
   ParseParameterXML = strBrokenRules
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

ErrorHandler:
                                   
   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function



