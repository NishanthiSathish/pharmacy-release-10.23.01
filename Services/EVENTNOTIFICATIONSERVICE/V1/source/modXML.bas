Attribute VB_Name = "modXML"
Option Explicit
DefInt A-Z


Public Const CLOSE_ROOT_ELEMENT = "</Root>"
Public Const ROOT_ELEMENT = "<Root>"

Private Const APPID_DOM_OBJECT = "MSXML2.DOMDocument"
Private Const CLASS_NAME = "modXML"

Private Const XML_PARSE_FAILED_CODE = vbObjectError + 1006
Private Const XML_PARSE_FAILED_DESC = "The provided XML string failed to parse."
Public Function GetElementValue(ByRef objNode As MSXML2.IXMLDOMNode) As String

Const SUB_NAME = "GetElementValue"

Dim uError As udtErrorState


   On Error GoTo ErrorHandler
   
   GetElementValue = ""
   If Not objNode Is Nothing Then GetElementValue = objNode.Text
      
Cleanup:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Function
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

   On Error GoTo ErrorHandler
                                    
   LoadAndValidateXML = vbNullString
   
   'create a schema cache object
   Set objSchemaCache = CreateObject("MSXML2.XMLSchemaCache")
   
   'load the schema into the cache
   objSchemaCache.Add "", strSchemaFileName
   
   'create the DOM if necessary
   If objDOM Is Nothing Then Set objDOM = CreateObject("MSXML2.DomDocument")
   
   'assign the schemacache to the DOM
   Set objDOM.schemas = objSchemaCache
   
   With objDOM
      .validateOnParse = True
      'load the XML string into the DOM
      .LoadXML strXML
            
      If .parseError.errorCode <> 0 Then
         'return an error - Xml not valid
         LoadAndValidateXML = GetDomParseError(.parseError)
      End If
   End With
                                                                     
Cleanup:

   On Error Resume Next
   
   'remove the schema from the schema object
   objSchemaCache.Remove ""
   
   Set objSchemaCache = Nothing
   
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Function


ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME, , "strXML = '" & strXML & "'" & vbCr & " strSchemaFileName='" & strSchemaFileName & "'"
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

Dim uError As udtErrorState
Dim strReturn As String

   On Error GoTo ErrorHandler
   
   strReturn = vbNullString
   
   With ParseErr
      strReturn = "<ParseError Code=""" & .errorCode & """ " & _
                "Description=""" & .reason & " in line " & .Line & " at character " & .linepos & """>" & _
                XMLEscape(.srcText) & "</ParseError>"
      'parse out the carriage returns in .line and .linepos
      strReturn = Replace(strReturn, vbCrLf, vbNullString)
   End With
   
   
ExitPoint:
   
   On Error Resume Next
   GetDomParseError = strReturn
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Function

'-------------------------------Error Handling Block----------------------------------------

ErrorHandler:
   
   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume ExitPoint

End Function

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
                             
Const APPID_SCRIPTING_DICTIONARY = "Scripting.Dictionary"
Const SUB_NAME = "AddInputParameter"

Dim uErrorState As udtErrorState


   On Error GoTo ErrorHandler
   
   If Parameters Is Nothing Then Set Parameters = CreateObject(APPID_SCRIPTING_DICTIONARY)
   
   If Parameters.Exists(ParameterName) Then
      Parameters.Item(ParameterName) = ParameterValue
   Else
      Parameters.Add ParameterName, ParameterValue
   End If
                             
ExitPoint:

   On Error GoTo 0
   BubbleOnError uErrorState
   
Exit Sub

ErrorHandler:

   CaptureErrorState uErrorState, CLASS_NAME, SUB_NAME
   Resume ExitPoint
   
End Sub


Public Function ProcessParameters(ByRef objParams As Scripting.Dictionary) As String

Const SUB_NAME = "ProcessParameters"

Dim uError As udtErrorState

Dim lngLoop As Long

Dim strReturn As String


   On Error GoTo ErrorHandler
   strReturn = "<Parameters>"
   For lngLoop = 0 To objParams.Count - 1
      strReturn = strReturn & _
                  "<Parameter name=" & Chr(34) & objParams.Keys(lngLoop) & Chr(34) & ">" & _
                  XMLEscape(objParams.Items(lngLoop)) & _
                  "</Parameter>"
   Next
   strReturn = strReturn & "</Parameters>"
   
Cleanup:

   On Error GoTo 0
   ProcessParameters = strReturn
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
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



