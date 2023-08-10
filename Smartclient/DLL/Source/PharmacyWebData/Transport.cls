VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "Transport"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'------------------------------------------------------------------------------------
'Project Name  :
'
' Item:        :  Transport
'
' Purpose      :  Provides the data transport layer between client components
'              :  and database via the web server.
'              :  Provides methods to execute stored procedures
'              :  Returns native ado recordsets
'              :  Mainains the same interfaces as PharmacyData.Transport
'
'07Aug12 CKJ Web transport layer now links VB6 to .Net, not VB6 to ADO directly
'            As a result, the data type enum mapping is different.
'            AdoDataType() is not used now; DbType() is used instead.
'            As part of this mapping, it was noted that there are not direct
'            equivalents for Text (adLongVarChar) or Base64Binary. The latter
'            was mapped to adBinary which isn't really right since Base 64 is
'            pure text and may be long, ie adLongVarChar
'            Similarly, trnDataTypeDecimal is declared but not implemented.
'            UniqueIdentifier is declared, implemented but never used.
'            As it happens, none of these three are actually used in VB6 code
'            in the Smartclient. (The exception is MetaDataSearch which isn't
'            VB6, doesn't use this library & has it's own different enum anyway)
'            Therefore to prevent accidents, trnDataTypeText trnDataTypeBase64Binary
'            trnDataTypeUniqueIdentifier & trnDataTypeDecimal are declared deprecated
'            & have been removed. Re-implement & test before use if ever required.
'            Note that IsInTransaction is not supported as each call is independent.
'14Aug12 CKJ Added reference to Microsoft Scripting Runtime to support Dictionary object
'            Added mdParam handling to cache parameters
'20Aug12 CKJ Extended the mdParam handling to all SP types.
'19Sep12 CKJ DbTypeAnsiString was DbTypeString - caused problems web-side where 4000 < length <= 8000   (TFS44224)
'28Sep12 CKJ Tiny state engine to parse text in tables from html error page. Corrected trailing tag.    (TFS44224)
'05Oct12 CKJ ExecuteSelectSP: Load XML to RS using a stream which passes control characters 0x01-0x1F   (TFS44486)

'Mods wanted
'-----------
'   options for enhancements marked with 'aug12(Enh)'

Option Explicit
DefInt A-Z

Private Const CLASS_NAME As String = "Transport"

Dim mdParam As Dictionary

Public Enum trnDataTypeEnum
   trnDataTypeVarChar = 0
   trnDataTypeChar = 1
   trnDataTypeint = 2
   'trnDataTypeText = 4                '07Aug12 CKJ Deprecated, unused, removed
   trnDataTypeFloat = 7
   trnDataTypeBit = 9
   trnDataTypeDateTime = 10
   'trnDataTypeUniqueIdentifier = 11
   'trnDataTypeBase64Binary = 12       '07Aug12 CKJ Deprecated, unused, removed
   'trnDataTypeDecimal = 13            '07Aug12 CKJ Deprecated, unused, removed
End Enum

Public Enum DbTypeEnum                 '03Aug12 CKJ added from .Net Enum DbType
   DbTypeAnsiString = 0                'A variable-length stream of non-Unicode characters ranging between 1 and 8,000 characters.
   DbTypeBinary = 1                    'A variable-length stream of binary data ranging between 1 and 8,000 bytes.
   DbTypeByte = 2                      'An 8-bit unsigned integer ranging in value from 0 to 255.
   DbTypeBoolean = 3                   'A simple type representing Boolean values of true or false.
   DbTypeCurrency = 4                  'A currency value ranging from -2 63 (or -922,337,203,685,477.5808) to 2 63 -1 (or +922,337,203,685,477.5807) with an accuracy to a ten-thousandth of a currency unit.
   DbTypeDate = 5                      'A type representing a date value.
   DbTypeDateTime = 6                  'A type representing a date and time value.
   DbTypeDecimal = 7                   'A simple type representing values ranging from 1.0 x 10 -28 to approximately 7.9 x 10 28 with 28-29 significant digits.
   DbTypeDouble = 8                    'A floating point type representing values ranging from approximately 5.0 x 10 -324 to 1.7 x 10 308 with a precision of 15-16 digits.
   DbTypeGUID = 9                      'A globally unique identifier (or GUID).
   DbTypeInt16 = 10                    'An integral type representing signed 16-bit integers with values between -32768 and 32767.
   DbTypeInt32 = 11                    'An integral type representing signed 32-bit integers with values between -2147483648 and 2147483647.
   DbTypeInt64 = 12                    'An integral type representing signed 64-bit integers with values between -9223372036854775808 and 9223372036854775807.
   DbTypeObject = 13                   'A general type representing any reference or value type not explicitly represented by another DbType value.
   DbTypeSByte = 14                    'An integral type representing signed 8-bit integers with values between -128 and 127.
   DbTypeSingle = 15                   'A floating point type representing values ranging from approximately 1.5 x 10 -45 to 3.4 x 10 38 with a precision of 7 digits.
   DbTypeString = 16                   'A type representing Unicode character strings.
   DbTypeTime = 17                     'A type representing a SQL Server DateTime value. If you want to use a SQL Server time value, use Time.
   DbTypeUInt16 = 18                   'An integral type representing unsigned 16-bit integers with values between 0 and 65535.
   DbTypeUInt32 = 19                   'An integral type representing unsigned 32-bit integers with values between 0 and 4294967295.
   DbTypeUInt64 = 20                   'An integral type representing unsigned 64-bit integers with values between 0 and 18446744073709551615.
   DbTypeVarNumeric = 21               'A variable-length numeric value.
   DbTypeAnsiStringFixedLength = 22    'A fixed-length stream of non-Unicode characters.
   DbTypeStringFixedLength = 23        'A fixed-length string of Unicode characters.
   DbTypeXml = 25                      'A parsed representation of an XML document or fragment.
   DbTypeDateTime2 = 26                'Date and time data. Date value range is from January 1,1 AD through December 31, 9999 AD. Time value range is 00:00:00 through 23:59:59.9999999 with an accuracy of 100 nanoseconds.
   DbTypeDateTimeOffset = 27           'Date and time data with time zone awareness. Date value range is from January 1,1 AD through December 31, 9999 AD. Time value range is 00:00:00 through 23:59:59.9999999 with an accuracy of 100 nanoseconds. Time zone value range is -14:00 through +14:00.
End Enum

'Public Enum DotNetTypeCodeEnum  '03Aug12 CKJ added from .Net Public Enum TypeCode '07Aug12 CKJ Not required now but left for reference
'   DotNetTypeCodeEmpty = 0      'A null reference.
'   DotNetTypeCodeObject = 1     'A general type representing any reference or value type not explicitly represented by another TypeCode.
'   DotNetTypeCodeDBNull = 2     'A database null (column) value.
'   DotNetTypeCodeBoolean = 3    'A simple type representing Boolean values of true or false.
'   DotNetTypeCodeChar = 4       'An integral type representing unsigned 16-bit integers with values between 0 and 65535. The set of possible values for the System.TypeCode.Char type corresponds to the Unicode character set.
'   DotNetTypeCodeSByte = 5      'An integral type representing signed 8-bit integers with values between -128 and 127.
'   DotNetTypeCodeByte = 6       'An integral type representing unsigned 8-bit integers with values between 0 and 255.
'   DotNetTypeCodeInt16 = 7      'An integral type representing signed 16-bit integers with values between -32768 and 32767.
'   DotNetTypeCodeUInt16 = 8     'An integral type representing unsigned 16-bit integers with values between 0 and 65535.
'   DotNetTypeCodeInt32 = 9      'An integral type representing signed 32-bit integers with values between -2147483648 and 2147483647.
'   DotNetTypeCodeUInt32 = 10    'An integral type representing unsigned 32-bit integers with values between 0 and 4294967295.
'   DotNetTypeCodeInt64 = 11     'An integral type representing signed 64-bit integers with values between -9223372036854775808 and 9223372036854775807.
'   DotNetTypeCodeUInt64 = 12    'An integral type representing unsigned 64-bit integers with values between 0 and 18446744073709551615.
'   DotNetTypeCodeSingle = 13    'A floating point type representing values ranging from approximately 1.5 x 10 -45 to 3.4 x 10 38 with a precision of 7 digits.
'   DotNetTypeCodeDouble = 14    'A floating point type representing values ranging from approximately 5.0 x 10 -324 to 1.7 x 10 308 with a precision of 15-16 digits.
'   DotNetTypeCodeDecimal = 15   'A simple type representing values ranging from 1.0 x 10 -28 to approximately 7.9 x 10 28 with 28-29 significant digits.
'   DotNetTypeCodeDateTime = 16  'A type representing a date and time value.
'   DotNetTypeCodeString = 18    'A sealed class type representing Unicode character strings.
'End Enum

Public Enum insInstallationType
   InstallationTypeUnknown = 0
   InstallationTypeLive = 1
   InstallationTypeTraining = 2
   InstallationTypeTesting = 3
End Enum

Private mstrKey As String
Private mstrToken As String
Private mstrProxyURL As String
'Private mstrBlankTag As String '08Aug12 CKJ removed - not necessary
Private mblnWCF As Boolean
Private mstrWCFEndpoint As String
Private mobjWCF As Client
Private mbWCFConnectionOpen as Boolean

Public Property Let UnencryptedKey(ByVal strKey As String)
   mstrKey = strKey
End Property

Public Property Get UnencryptedKey() As String
   UnencryptedKey = ""
End Property

Public Property Let URLToken(ByVal strToken As String)
   mstrToken = strToken
End Property

Public Property Get URLToken() As String
   URLToken = ""   '08Aug12 CKJ was mstrToken, now write only
End Property

Public Property Let ProxyURL(ByVal strProxyURL As String)
   mstrProxyURL = strProxyURL
End Property

Public Property Get ProxyURL() As String
   ProxyURL = mstrProxyURL
End Property

'08Aug12 CKJ removed - not necessary
'Public Property Let BlankTag(ByVal strBlankTag As String)
'   mstrBlankTag = strBlankTag
'End Property
'
'Public Property Get BlankTag() As String
'   BlankTag = mstrBlankTag
'End Property

Private Sub Class_Initialize()
'14aug12 CKJ added

   Set mdParam = New Dictionary
   mdParam.CompareMode = TextCompare
   mbWCFConnectionOpen = False
   mblnWCF = True
End Sub

Private Sub OpenWCFConnection()
    
   If Not(mbWCFConnectionOpen) Then
	   mstrProxyURL = replace(mstrProxyURL, "PharmacyTransport.aspx", "WebDataService.svc")
      Set mobjWCF = New Client
      mobjWCF.Initialise mstrProxyURL, mstrToken
	  
	  mbWCFConnectionOpen = True
   EndIf

End Sub

Private Sub Class_Terminate()
'14aug12 CKJ added

   Set mdParam = Nothing
   
End Sub

'---------------------------------------------------------------------------------------
' Procedure : SendData
' Author    : AJK
' Date      : 23Jul12
' Purpose   : Encrypt, hex and send the request to the server
'             Dehex, decrpyt and sent back the response
'             Raises error if any step cannot be completed
'---------------------------------------------------------------------------------------
Public Function SendData(ByVal lngSessionID As Long, ByVal strData As String) As String
Dim objMSCAPI As clsMSCAPI
Dim blnRandom As Boolean
Dim strSalt As String
Dim strSaltHex As String
Dim strCypher As String
Dim strCypherHex As String
Dim posn As Long   '08Aug12 CKJ was Integer
Dim HttpRequest As WinHttpRequest
Dim strResponse As String
Dim strReturn As String
Dim strTag As String
Dim hourglass As Boolean
Dim msg As String
Dim posn1 As Integer
Dim reading As Integer

Const SUB_NAME As String = "SendData"
Const ErrorTag As String = "PharmacyWebDataExceptionRaisedByServer"
Dim ErrorState As udtErrorState

   On Error GoTo ErrorHandler

   strReturn = ""
   Set objMSCAPI = New clsMSCAPI
   blnRandom = objMSCAPI.GetRandomString(16, strSalt)

   If blnRandom Then
      objMSCAPI.Password = mstrKey & strSalt
      If objMSCAPI.Encrypt(strData) Then
         strCypher = objMSCAPI.OutputData
         strCypherHex = String$(Len(strCypher) * 2, vbNullChar)
         For posn = 1 To Len(strCypher)
            Mid$(strCypherHex, posn * 2 - 1, 2) = Right$("0" & Hex$(Asc(Mid$(strCypher, posn, 1))), 2)
         Next
         strSaltHex = String$(Len(strSalt) * 2, vbNullChar)
         For posn = 1 To Len(strSalt)
            Mid$(strSaltHex, posn * 2 - 1, 2) = Right$("0" & Hex$(Asc(Mid$(strSalt, posn, 1))), 2)
         Next
         
         hourglass = True
         Screen.MousePointer = vbHourglass
         Set HttpRequest = New WinHttpRequest            'aug12(Enh) Ideally would have progress bar or waiting popup
         HttpRequest.SetTimeouts 0, 60000, 30000, 120000 '20Aug12 CKJ retain defaults for resolve, connect & send but increase receive to 120 secs
         HttpRequest.Open "POST", mstrProxyURL, False
         HttpRequest.setRequestHeader "Content-Type", "application/x-www-form-urlencoded"
         HttpRequest.send "SessionID=" & CStr(lngSessionID) & "&Token=" & mstrToken & "&BLOB=" & strSaltHex & strCypherHex
         strResponse = HttpRequest.responseText
         Screen.MousePointer = vbDefault
         hourglass = False
         
         If Len(strResponse) > 1 Then
            If InStr(1, strResponse, "<html", 1) Then    '20Aug12 CKJ Broken rules may bubble up unencrypted as "<html ... >"
               strReturn = ""
               'Err.Raise -32767, "PharmacyWebData.SendData", "Your session is now invalid. Please log in again."   'don't display broken rules detail here '28Sep12 CKJ now use block below
               
               '28Sep12 CKJ Tiny state engine to parse text in tables out of html error page
               reading = 0                            '0' not reading, look only for '<td'
                                                      '1' reading paused inside '<td', set state 2 after next '>'
                                                      '2' reading until next '<' when '</td> sets state 0, else state 1
               msg = Space$(Len(strResponse))         'create buffer for message which cannot be larger than the original html
               posn1 = 1                              'position in msg to write the next output character
               For posn = 1 To Len(strResponse) - 4   'saves having to check length in state engine as we know it starts '<html'
                  Select Case reading
                     Case 0
                        If LCase$(Mid$(strResponse, posn, 3)) = "<td" Then reading = 1
                     Case 1
                        If Mid$(strResponse, posn, 1) = ">" Then reading = 2
                     Case 2
                        If LCase$(Mid$(strResponse, posn, 5)) = "</td>" Then  'add newline, stop reading
                           Mid$(msg, posn1, 2) = vbCrLf                       'strictly its 'tr' which signals newline
                           posn1 = posn1 + 2                                  'but for our purpose 'td' is adequate
                           reading = 0
                        ElseIf Mid$(strResponse, posn, 1) = "<" Then          'pause reading
                           reading = 1
                        Else
                           Mid$(msg, posn1) = Mid$(strResponse, posn, 1)      'keep reading
                           posn1 = posn1 + 1
                        End If
                     End Select
               Next
               msg = Replace(msg, "Error" & vbCrLf, "")                       'remove preamble
               msg = Replace(msg, "Stack Trace" & vbCrLf, "")
               'MsgBox RTrim$(msg)  for debug use only
               Err.Raise -32767, "PharmacyWebData.SendData", RTrim$(msg)      'return text of broken rules
               '-- end 28Sep12 --
               
            Else
               For posn = 1 To Len(strResponse) Step 2
                  '08Aug12 CKJ Changed floating division / to integer division \
                  Mid$(strResponse, (posn \ 2) + 1) = Chr$(Val("&H" & Mid$(strResponse, posn, 2)))
               Next
               strResponse = Left$(strResponse, Len(strResponse) / 2)
               objMSCAPI.Password = mstrKey & Left$(strResponse, 16)
               If objMSCAPI.Decrypt(Mid$(strResponse, 17)) Then
                  strReturn = objMSCAPI.OutputData
               End If
               
               '20Aug12 CKJ Check if decrypted data is a bubbled error
               strTag = "<" & ErrorTag & ">"
               If InStr(1, strReturn, strTag, 1) = 1 Then
                  'strResponse = Mid$(strReturn, Len(strTag) + 1)                               'strip off leading tag
                  strResponse = Replace(strResponse, "</" & ErrorTag & ">", "", 1, -1, vbTextCompare) 'strip off trailing tag  '28Sep12 CKJ corrected
                  strReturn = ""
                  'MsgBox "Server raised an error:" & vbCrLf & strResponse, vbCritical + vbOKOnly, "Ascribe Transport - SendData"
                  Err.Raise -32767, "PharmacyWebData.SendData", "Server raised an error: " & strResponse & " (" & ErrorTag & ")"
               End If
            End If
         End If
      End If
   End If

   SendData = strReturn

Cleanup:
   On Error GoTo 0
   If Not HttpRequest Is Nothing Then Set HttpRequest = Nothing
   If Not objMSCAPI Is Nothing Then Set objMSCAPI = Nothing
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   If hourglass Then
      Screen.MousePointer = vbDefault
      hourglass = False
   End If
   
   'aug12(Enh) Option for future enhancement, but as timeout is now 120secs we can let the error bubble up
  ' If Err.Number = -2147012894 Then    'timed out - maybe show msg then retry once here?
  '    Stop
  '    Resume
  ' Else
      CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, "PharmacyWebData: Unable to send data to server"
  ' End If
Resume Cleanup

End Function

'14Aug12 CKJ seems not to be needed
'Private Function XMLToADORecordset(strXML As String) As ADODB.Recordset
'Dim objRS As ADODB.Recordset
'Dim objRec As ADODB.Record
'Dim objDoc As MSXML2.DOMDocument
'
'   objRS.Save
'
'
'
'
'End Function
 
Public Function CreateInputParameterXML( _
                                           ByVal Name As String, _
                                           ByVal DataType As trnDataTypeEnum, _
                                           ByVal Length As Long, _
                                           ByVal Value As Variant _
                                       ) _
                                       As String
'------------------------------------------------------------------------------------
' Purpose   :  Builds an XML input parameter element, for use in the Execute methods
'
' Inputs    :  Name     -  Name of the parameter
'              DataType -  The transport layer's datatype abstractions
'              Length   -  Length of the parameter (most useful for varchars)
'              Value    -  Value of the parameter
'
' Outputs   :  None
'
' Return    :  XML Input Parameter Element
'
' Revision History
'
' 03May02 RA - Created
' 18Jan03 PH - Updated
' 08Apr03 PH   Changed to use the XML DOM rather than String concatenation
' 11Jun03 AE   Added Data-type specific handling for DATE; this can be expanded to other data types if required
' 30Jul03 AE   Previous mod improved; DATE data type does NO validation and strips off the time part.
'              Unfortunately has to manually convert to XML's yyyy-mm-ddThh:mm format otherwise the DOM won't parse it.
' 09Mar04 PH   Changed to "presume" dd/mm/yyyy for ambiguous date strings, rather than using cdate()
' 10Jul04 PH   Now raises an error if textual date format isnt TDate
' 11Aug04 PH   Now accepts 5 character 99:99 format strings of where DateType is trnDataTypeDateTime as a time.
'------------------------------------------------------------------------------------

Const SUB_NAME As String = "CreateInputParameterXML"
Dim ErrorState As udtErrorState

Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMElement
Dim enmDataType As ADODB.DataTypeEnum
   
   On Error GoTo ErrorHandler
   
   Set xmlDoc = New MSXML2.DOMDocument
   
   Set xmlnode = xmlDoc.createElement("Parameter")
   
   'enmDataType = AdoDataType(DataType)   '08Aug12 CKJ ICW transport layer uses DbType enum
   enmDataType = DbType(DataType)         '   "
   
   xmlDoc.appendChild xmlnode
   xmlnode.setAttribute "Name", Name
   xmlnode.setAttribute "DataType", enmDataType
   xmlnode.setAttribute "Direction", ADODB.adParamInput
   xmlnode.setAttribute "Length", Length
   
   ' "Null"s are represented by the absense of the "Value" attribute
   If Not IsNull(Value) Then
      
      Select Case enmDataType
         Case DbTypeDateTime   '08Aug12 CKJ was adDBDate
            ' A date parameter could come through in many different datatypes/formats
            ' Start by determining the variant's subtype
            Select Case VarType(Value)
               Case VbVarType.VBDate
                  ' If the variant subtype is a date, then convert it to a TDate string
                  xmlnode.setAttribute "Value", Date2TDate(Value)
               Case VbVarType.vbString
                  ' Examine the string to work out what format the date is in.
                  If Mid$(Value, 11, 1) = "T" Then
                     ' Date format is "TDate", so use it "as is"
                     xmlnode.setAttribute "Value", Value
                  ElseIf Len(Trim$(Value)) = 5 And Mid$(Trim$(Value), 3, 1) = ":" Then
                     ' Date value is a 5 character 24-hour time string
                     xmlnode.setAttribute "Value", Trim$(Value)
                  Else
                     RaiseError erUnknownDateFormat, Value
                  End If
               Case Else
                  RaiseError erUnknownDateFormat, Value
               End Select
            
''         Case adChar, adVarChar     'maybe also adLongVarChar adLongVarWChar ?
''            EscapeXML Value
''            xmlnode.setAttribute "Value", Value
            
         Case Else
            xmlnode.setAttribute "Value", Value
     
         End Select
   
   End If
   
   CreateInputParameterXML = xmlDoc.xml

Cleanup:
   Set xmlnode = Nothing
   Set xmlDoc = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, Name & ", " & DataType & ", " & Length & ", " & Value
 
   Resume Cleanup
End Function


Public Function CreateOutputParameterXML( _
                                           ByVal Name As String, _
                                           ByVal DataType As trnDataTypeEnum, _
                                           ByVal Length As Long _
                                       ) _
                                       As String
'------------------------------------------------------------------------------------
' Purpose   :  Builds an XML output parameter element, for use in the Execute methods
'
' Inputs    :  Name       -  Name of the parameter
'              DataType   -  SQL Datatype
'              Value      -  Value to pass
'
' Outputs   :  None
'
' Return    :  XML Output Parameter Element
'
' Revision History
'
' 03May02 RA - Created
' 18Jan03 PH - Updated
'------------------------------------------------------------------------------------
Const SUB_NAME = "CreateOutputParameterXML"
Dim ErrorState As udtErrorState

Dim xmlDoc As MSXML2.DOMDocument
Dim xmlnode As MSXML2.IXMLDOMElement

   On Error GoTo ErrorHandler
   
   Set xmlDoc = New MSXML2.DOMDocument
   
   Set xmlnode = xmlDoc.createElement("Parameter")
   
   xmlDoc.appendChild xmlnode
   xmlnode.setAttribute "Name", Name
   'xmlnode.setAttribute "DataType", AdoDataType(DataType)   '08Aug12 CKJ ICW transport layer uses DbType enum
   xmlnode.setAttribute "DataType", DbType(DataType)         '   "
   xmlnode.setAttribute "Direction", ADODB.adParamOutput
   xmlnode.setAttribute "Length", Length
 
   CreateOutputParameterXML = xmlDoc.xml

Cleanup:
   Set xmlnode = Nothing
   Set xmlDoc = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, Name & ", " & DataType & ", " & Length
   
   Resume Cleanup
End Function

'07Aug12 CKJ Replaced with DbType() as this is now sent to .NET not via ADO direct
'Private Function AdoDataType( _
'                                 ByVal enmDataType As trnDataTypeEnum _
'                            ) _
'                            As ADODB.DataTypeEnum
''------------------------------------------------------------------------------------
'' Purpose   :  Converts local Enum to ADO enum
''
'' Inputs    :  DataType As trnDataTypeEnum
''
'' Outputs   :  None
''
'' Return    :  Enum, datatype indicator
''
'' Revision History
''
'' 03May02 RA - Created
'' 18Jan03 PH - Updated
''------------------------------------------------------------------------------------
'Const SUB_NAME As String = "AdoDataType"
'Dim ErrorState As udtErrorState
'
'   On Error GoTo ErrorHandler
'
'   Select Case enmDataType
'      Case trnDataTypeEnum.trnDataTypeChar:             AdoDataType = ADODB.DataTypeEnum.adChar
'      Case trnDataTypeEnum.trnDataTypeFloat:            AdoDataType = ADODB.DataTypeEnum.adDouble
'      Case trnDataTypeEnum.trnDataTypeint:              AdoDataType = ADODB.DataTypeEnum.adInteger
'      Case trnDataTypeEnum.trnDataTypeText:             AdoDataType = ADODB.DataTypeEnum.adLongVarChar
'      Case trnDataTypeEnum.trnDataTypeVarChar:          AdoDataType = ADODB.DataTypeEnum.adVarChar
'      Case trnDataTypeEnum.trnDataTypeDateTime:         AdoDataType = ADODB.DataTypeEnum.adDBDate
'      Case trnDataTypeEnum.trnDataTypeBit:              AdoDataType = ADODB.DataTypeEnum.adBoolean
'      Case trnDataTypeEnum.trnDataTypeUniqueIdentifier: AdoDataType = ADODB.DataTypeEnum.adGUID
'      Case trnDataTypeEnum.trnDataTypeBase64Binary:     AdoDataType = ADODB.DataTypeEnum.adBinary
'      End Select
'
'Cleanup:
'   On Error GoTo 0
'   BubbleOnError ErrorState
'
'Exit Function
'ErrorHandler:
'   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, CStr(enmDataType)
'   Resume Cleanup
'End Function

Private Function DbType(ByVal enmDataType As trnDataTypeEnum) _
                                 As DbTypeEnum
'------------------------------------------------------------------------------------
' Purpose   :  Converts local Enum to .Net DbType enum
'
' Inputs    :  DataType As trnDataTypeEnum
'
' Outputs   :  None
'
' Return    :  Enum, datatype indicator
'
' Revision History
'
' 03Aug12 CKJ Replicates AdoDataType to handle .Net DbType data types
'             Needed for trnrtl10.transport.XMLParamsToSqlClient
' 19Sep12 CKJ DbTypeAnsiString was DbTypeString - caused problems web-side where 4000 < length <= 8000
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "DbType"
Dim ErrorState As udtErrorState

   On Error GoTo ErrorHandler
   
'   DbTypeAnsiString = 0                'A variable-length stream of non-Unicode characters ranging between 1 and 8,000 characters.
'   DbTypeBinary = 1                    'A variable-length stream of binary data ranging between 1 and 8,000 bytes.
'   DbTypeByte = 2                      'An 8-bit unsigned integer ranging in value from 0 to 255.
'   DbTypeBoolean = 3                   'A simple type representing Boolean values of true or false.
'   DbTypeCurrency = 4                  'A currency value ranging from -2 63 (or -922,337,203,685,477.5808) to 2 63 -1 (or +922,337,203,685,477.5807) with an accuracy to a ten-thousandth of a currency unit.
'   DbTypeDate = 5                      'A type representing a date value.
'   DbTypeDateTime = 6                  'A type representing a date and time value.
'   DbTypeDecimal = 7                   'A simple type representing values ranging from 1.0 x 10 -28 to approximately 7.9 x 10 28 with 28-29 significant digits.
'   DbTypeDouble = 8                    'A floating point type representing values ranging from approximately 5.0 x 10 -324 to 1.7 x 10 308 with a precision of 15-16 digits.
'   DbTypeGuid = 9                      'A globally unique identifier (or GUID).
'   DbTypeInt16 = 10                    'An integral type representing signed 16-bit integers with values between -32768 and 32767.
'   DbTypeInt32 = 11                    'An integral type representing signed 32-bit integers with values between -2147483648 and 2147483647.
'   DbTypeInt64 = 12                    'An integral type representing signed 64-bit integers with values between -9223372036854775808 and 9223372036854775807.
'   DbTypeObject = 13                   'A general type representing any reference or value type not explicitly represented by another DbType value.
'   DbTypeSByte = 14                    'An integral type representing signed 8-bit integers with values between -128 and 127.
'   DbTypeSingle = 15                   'A floating point type representing values ranging from approximately 1.5 x 10 -45 to 3.4 x 10 38 with a precision of 7 digits.
'   DbTypeString = 16                   'A type representing Unicode character strings.
'   DbTypeTime = 17                     'A type representing a SQL Server DateTime value. If you want to use a SQL Server time value, use Time.
'   DbTypeUInt16 = 18                   'An integral type representing unsigned 16-bit integers with values between 0 and 65535.
'   DbTypeUInt32 = 19                   'An integral type representing unsigned 32-bit integers with values between 0 and 4294967295.
'   DbTypeUInt64 = 20                   'An integral type representing unsigned 64-bit integers with values between 0 and 18446744073709551615.
'   DbTypeVarNumeric = 21               'A variable-length numeric value.
'   DbTypeAnsiStringFixedLength = 22    'A fixed-length stream of non-Unicode characters.
'   DbTypeStringFixedLength = 23        'A fixed-length string of Unicode characters.
'   DbTypeXml = 25                      'A parsed representation of an XML document or fragment.
'   DbTypeDateTime2 = 26                'Date and time data. Date value range is from January 1,1 AD through December 31, 9999 AD. Time value range is 00:00:00 through 23:59:59.9999999 with an accuracy of 100 nanoseconds.
'   DbTypeDateTimeOffset = 27           'Date and time data with time zone awareness. Date value range is from January 1,1 AD through December 31, 9999 AD. Time value range is 00:00:00 through 23:59:59.9999999 with an accuracy of 100 nanoseconds. Time zone value range is -14:00 through +14:00.

   Select Case enmDataType                                                                                  'Old type
      Case trnDataTypeEnum.trnDataTypeChar:              DbType = DbTypeEnum.DbTypeAnsiStringFixedLength    'adChar
      Case trnDataTypeEnum.trnDataTypeFloat:             DbType = DbTypeEnum.DbTypeDouble                   'adDouble
      Case trnDataTypeEnum.trnDataTypeint:               DbType = DbTypeEnum.DbTypeInt32                    'adInteger
     'Case trnDataTypeEnum.trnDataTypeText:              DbType = DbTypeEnum.DbType?         **DEPRECATED** 'adLongVarChar
      Case trnDataTypeEnum.trnDataTypeVarChar:           DbType = DbTypeEnum.DbTypeAnsiString               'adVarChar '19Sep12 CKJ was DbTypeString
      Case trnDataTypeEnum.trnDataTypeDateTime:          DbType = DbTypeEnum.DbTypeDateTime                 'adDBDate
      Case trnDataTypeEnum.trnDataTypeBit:               DbType = DbTypeEnum.DbTypeBoolean                  'adBoolean
     'Case trnDataTypeEnum.trnDataTypeUniqueIdentifier:  DbType = DbTypeEnum.DbTypeGUID      **DEPRECATED** 'adGUID
     'Case trnDataTypeEnum.trnDataTypeBase64Binary:      DbType = DbTypeEnum.DbType?         **DEPRECATED** 'adBinary
     'Case trnDataTypeEnum.trnDataTypeDecimal:           DbType = DbTypeEnum.DbTypeDecimal   **DEPRECATED** 'no counterpart in AdoDataType
   End Select
   
Cleanup:
   On Error GoTo 0
   BubbleOnError ErrorState

Exit Function
ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, CStr(enmDataType)
   Resume Cleanup
End Function

Public Function ExecuteSelectSP( _
                                   ByVal SessionID As Long, _
                                   ByVal ProcedureName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As ADODB.Recordset
'------------------------------------------------------------------------------------
' Purpose   :  Executes a stored procedure, and returns a recordset
'
' Inputs    :  SessionID      -  User's session id, used for security and audit logging
'              ProcedureName  -  name of SP to execute
'              Parameters_XML -  the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Recordset
'
' Revision History
'
' 15Sep04 PW - Created
' 15Apr05 PW - Added loop with rsNext to store adodb.recordset.nextrecordset if one exists
' 05Oct12 CKJ When converting returned XML to RS, replaced use of DOMDocument with
'             direct loading from a stream as this passes control characters 0x01-0x1F
'             A vbNull 0x00 terminates the string for just the one field.   (TFS44486)
'15Nov15 TH   Explicit set of curosr loaction to adUseClient to try to preserve filter, find and sort properties (TFS 134997)
'------------------------------------------------------------------------------------

Const SUB_NAME As String = "ExecuteSelectSP"
Dim ErrorState As udtErrorState
   
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlParamsDoc As MSXML2.DOMDocument
Dim xmlFunc As MSXML2.IXMLDOMElement
Dim xmlProc As MSXML2.IXMLDOMElement
Dim xmlParams As MSXML2.IXMLDOMElement
Dim xmlParamWrite As MSXML2.IXMLDOMElement
Dim xmlParamRead As MSXML2.IXMLDOMElement
Dim strResponse As String
Dim rs As ADODB.Recordset
Dim xmlSIDname As MSXML2.IXMLDOMElement
Dim ParamNum As Integer
Dim ParamKey As String
Dim oStream As ADODB.Stream
Dim blnFullSessionIDName As Boolean
Dim strParams As String
   
   On Error GoTo ErrorHandler
     
    If mblnWCF Then
		OpenWCFConnection
        blnFullSessionIDName = True
        strParams = ""
    Else
        Set xmlDoc = New MSXML2.DOMDocument
        
        Set xmlFunc = xmlDoc.createElement("Function")
        xmlDoc.appendChild xmlFunc
        xmlFunc.setAttribute "Name", "ExecuteSelectSP"
        
        Set xmlProc = xmlDoc.createElement("Procedure")
        xmlFunc.appendChild xmlProc
        xmlProc.Text = ProcedureName
    End If
   
   '14aug12 CKJ added block
   If GetParameterList(SessionID, ProcedureName) Then
      ParamKey = ProcedureName & ":1"
      If mdParam.Exists(ParamKey) Then
         If LCase(mdParam.Item(ParamKey)) = "sessionid" Then        'First param is "sessionid" (case insensitive)
             If mblnWCF Then
               blnFullSessionIDName = False
             Else
               Set xmlSIDname = xmlDoc.createElement("SessionIDName")
               xmlFunc.appendChild xmlSIDname
               xmlSIDname.Text = mdParam.Item(ParamKey)
             End If
          End If
       End If
    End If
   
   If Parameters_XML <> vbNullString Then
        If Not mblnWCF Then
            Set xmlParams = xmlDoc.createElement("Parameters")
            xmlFunc.appendChild xmlParams
        End If
        
      Set xmlParamsDoc = New MSXML2.DOMDocument
           
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"         '08aug12 CKJ added
      
      If Not xmlParamsDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      ParamNum = 1
      For Each xmlParamRead In xmlParamsDoc.documentElement.childNodes
         Set xmlParamWrite = xmlParamRead.cloneNode(True)
         
         '14aug12 CKJ added block
         ParamNum = ParamNum + 1
         ParamKey = ProcedureName & Format$(ParamNum, "\:0")
         If mdParam.Exists(ParamKey) Then
            xmlParamWrite.setAttribute "Name", mdParam.Item(ParamKey)
         End If
            
            If mblnWCF Then
                strParams = strParams & xmlParamWrite.xml
            Else
                xmlParams.appendChild xmlParamWrite
            End If
      Next xmlParamRead
   End If
   
   Set rs = New ADODB.Recordset
   
   rs.CursorLocation = adUseClient  '15Nov15 TH Added to preserve filter, find and sort properties
   
    If mblnWCF Then
        Set rs = mobjWCF.ExecuteSelectSP(SessionID, ProcedureName, strParams, blnFullSessionIDName)
    Else
        
        strResponse = SendData(SessionID, xmlDoc.xml)
        
        If Len(strResponse) > 0 Then
           '05Oct12 CKJ Replaced use of DOM with direct loading from stream as this passes control characters 0x01-0x1F      (TFS44486)
           Set oStream = New ADODB.Stream
           oStream.Open
           oStream.WriteText strResponse    'Pass XML string to ADO Stream
           oStream.Position = 0             'Set the stream position to the start
           rs.Open oStream                  'Open recordset from the stream
           oStream.Close
           Set oStream = Nothing
        End If
    End If
   
   Set ExecuteSelectSP = rs

Cleanup:
   If Not xmlDoc Is Nothing Then Set xmlDoc = Nothing
   If Not xmlParamsDoc Is Nothing Then Set xmlParamsDoc = Nothing
   If Not xmlFunc Is Nothing Then Set xmlFunc = Nothing
   If Not xmlProc Is Nothing Then Set xmlProc = Nothing
   If Not xmlParams Is Nothing Then Set xmlParams = Nothing
   If Not xmlParamWrite Is Nothing Then Set xmlParamWrite = Nothing
   If Not xmlParamRead Is Nothing Then Set xmlParamRead = Nothing
   'If Not xmlRetDoc Is Nothing Then Set xmlRetDoc = Nothing      '05Oct12 CKJ not used now
   If Not xmlSIDname Is Nothing Then Set xmlSIDname = Nothing     '20Aug12 CKJ added
   'If Not xmlResults Is Nothing Then Set xmlResults = Nothing
   'If rs.State = ADODB.adStateOpen Then rs.Close        '20aug12 CKJ removed - closing here prevents use as return
   'If Not rs Is Nothing Then Set rs = Nothing           '
   If Not oStream Is Nothing Then Set oStream = Nothing  '05Oct12 CKJ added
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & ProcedureName & ", " & Parameters_XML
   Resume Cleanup
End Function

Public Function ExecuteSelectOutputSP( _
                                   ByVal SessionID As Long, _
                                   ByVal ProcedureName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As String

Const SUB_NAME As String = "ExecuteSelectOutputSP"
Dim ErrorState As udtErrorState

Dim xmlDoc As MSXML2.DOMDocument
Dim xmlParamsDoc As MSXML2.DOMDocument
Dim xmlFunc As MSXML2.IXMLDOMElement
Dim xmlProc As MSXML2.IXMLDOMElement
Dim xmlParams As MSXML2.IXMLDOMElement
Dim xmlParamWrite As MSXML2.IXMLDOMElement
Dim xmlParamRead As MSXML2.IXMLDOMElement
Dim strResponse As String
Dim xmlSIDname As MSXML2.IXMLDOMElement
Dim ParamNum As Integer
Dim ParamKey As String
Dim blnFullSessionIDName As Boolean
Dim strParams As String

   On Error GoTo ErrorHandler
   
    If mblnWCF Then
		OpenWCFConnection
        blnFullSessionIDName = True
        strParams = ""
    Else
        Set xmlDoc = New MSXML2.DOMDocument
        
        Set xmlFunc = xmlDoc.createElement("Function")
        xmlDoc.appendChild xmlFunc
        xmlFunc.setAttribute "Name", "ExecuteSelectOutputSP"
                                    
        Set xmlProc = xmlDoc.createElement("Procedure")
        xmlFunc.appendChild xmlProc
        xmlProc.Text = ProcedureName
    End If

   '20aug12 CKJ added block
   If GetParameterList(SessionID, ProcedureName) Then
      ParamKey = ProcedureName & ":1"
      If mdParam.Exists(ParamKey) Then
         If LCase(mdParam.Item(ParamKey)) = "sessionid" Then        'First param is "sessionid" (case insensitive)
               If mblnWCF Then
                  blnFullSessionIDName = False
               Else
                  Set xmlSIDname = xmlDoc.createElement("SessionIDName")
                  xmlFunc.appendChild xmlSIDname
                  xmlSIDname.Text = mdParam.Item(ParamKey)
               End If
            End If
        End If
    End If
   
   If Parameters_XML <> vbNullString Then
        If Not mblnWCF Then
            Set xmlParams = xmlDoc.createElement("Parameters")
            xmlFunc.appendChild xmlParams
        End If
      Set xmlParamsDoc = New MSXML2.DOMDocument
      
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"         '03aug12 CKJ added
      
      If Not xmlParamsDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      ParamNum = 1
      For Each xmlParamRead In xmlParamsDoc.documentElement.childNodes
         Set xmlParamWrite = xmlParamRead.cloneNode(False)
         
         '20aug12 CKJ added block
         ParamNum = ParamNum + 1
         ParamKey = ProcedureName & Format$(ParamNum, "\:0")
         If mdParam.Exists(ParamKey) Then
            xmlParamWrite.setAttribute "Name", mdParam.Item(ParamKey)
         End If
         
            If mblnWCF Then
                strParams = strParams & xmlParamWrite.xml
            Else
                xmlParams.appendChild xmlParamWrite
            End If
      Next xmlParamRead
   End If

    If mblnWCF Then
        strResponse = mobjWCF.ExecuteSelectOutputSP(SessionID, ProcedureName, strParams, blnFullSessionIDName)
    Else
        strResponse = SendData(SessionID, xmlDoc.xml)
    End If

   ExecuteSelectOutputSP = strResponse
   
Cleanup:
   If Not xmlDoc Is Nothing Then Set xmlDoc = Nothing
   If Not xmlParamsDoc Is Nothing Then Set xmlParamsDoc = Nothing
   If Not xmlFunc Is Nothing Then Set xmlFunc = Nothing
   If Not xmlProc Is Nothing Then Set xmlProc = Nothing
   If Not xmlParams Is Nothing Then Set xmlParams = Nothing
   If Not xmlParamWrite Is Nothing Then Set xmlParamWrite = Nothing
   If Not xmlParamRead Is Nothing Then Set xmlParamRead = Nothing
   If Not xmlSIDname Is Nothing Then Set xmlSIDname = Nothing     '20Aug12 CKJ added
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & ProcedureName & ", " & Parameters_XML
   Resume Cleanup
End Function

Public Function ExecuteSelectReturnSP( _
                                   ByVal SessionID As Long, _
                                   ByVal ProcedureName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As Long
'------------------------------------------------------------------------------------
' Purpose   :  Executes a stored procedure, returning it's ReturnValue as a Long
'
' Inputs    :  SessionID      - User's session id, used for security and audit logging
'              ProcedureName  - Name of procedure
'              Parameters_XML - the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
' 26Nov02 RA - Created
' 18Jan03 PH - Updated
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteSelectReturnSP"
Dim ErrorState As udtErrorState
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlParamsDoc As MSXML2.DOMDocument
Dim xmlFunc As MSXML2.IXMLDOMElement
Dim xmlProc As MSXML2.IXMLDOMElement
Dim xmlParams As MSXML2.IXMLDOMElement
Dim xmlParamWrite As MSXML2.IXMLDOMElement
Dim xmlParamRead As MSXML2.IXMLDOMElement
Dim strResponse As String
Dim xmlSIDname As MSXML2.IXMLDOMElement
Dim ParamNum As Integer
Dim ParamKey As String
Dim blnFullSessionIDName As Boolean
Dim strParams As String
Dim lngRet As Long

   On Error GoTo ErrorHandler
   
   If mblnWCF Then
	  OpenWCFConnection
      blnFullSessionIDName = True
      strParams = ""
   Else
      Set xmlDoc = New MSXML2.DOMDocument
   
      Set xmlFunc = xmlDoc.createElement("Function")
      xmlDoc.appendChild xmlFunc
      xmlFunc.setAttribute "Name", SUB_NAME
                                  
      Set xmlProc = xmlDoc.createElement("Procedure")
      xmlFunc.appendChild xmlProc
      xmlProc.Text = ProcedureName
   End If
   
   '14aug12 CKJ added block
   If GetParameterList(SessionID, ProcedureName) Then
      ParamKey = ProcedureName & ":1"
      If mdParam.Exists(ParamKey) Then
         If LCase(mdParam.Item(ParamKey)) = "sessionid" Then        'First param is "sessionid" (case insensitive)
            If mblnWCF Then
               blnFullSessionIDName = False
            Else
               Set xmlSIDname = xmlDoc.createElement("SessionIDName")
               xmlFunc.appendChild xmlSIDname
               xmlSIDname.Text = mdParam.Item(ParamKey)
            End If
         End If
      End If
   End If
   
   If Parameters_XML <> vbNullString Then
      If Not mblnWCF Then
         Set xmlParams = xmlDoc.createElement("Parameters")
         xmlFunc.appendChild xmlParams
      End If
      Set xmlParamsDoc = New MSXML2.DOMDocument
      If Not xmlParamsDoc.loadXML("<PARAMETERS>" & Trim(Parameters_XML) & "</PARAMETERS>") Then
         RaiseError erLoadXMLFailed
      End If
      ParamNum = 1
      For Each xmlParamRead In xmlParamsDoc.documentElement.childNodes
         Set xmlParamWrite = xmlParamRead.cloneNode(False)
         
         '14aug12 CKJ added block
         ParamNum = ParamNum + 1
         ParamKey = ProcedureName & Format$(ParamNum, "\:0")
         If mdParam.Exists(ParamKey) Then
            xmlParamWrite.setAttribute "Name", mdParam.Item(ParamKey)
         End If

         If mblnWCF Then
            strParams = strParams & xmlParamWrite.xml
         Else
            xmlParams.appendChild xmlParamWrite
         End If
      Next xmlParamRead
   End If

   If mblnWCF Then
      lngRet = mobjWCF.ExecuteSelectReturnSP(SessionID, ProcedureName, strParams, blnFullSessionIDName)
   Else
      strResponse = SendData(SessionID, xmlDoc.xml)
      lngRet = CLng(strResponse)
   End If

   ExecuteSelectReturnSP = lngRet
   
Cleanup:
   If Not xmlDoc Is Nothing Then Set xmlDoc = Nothing
   If Not xmlParamsDoc Is Nothing Then Set xmlParamsDoc = Nothing
   If Not xmlFunc Is Nothing Then Set xmlFunc = Nothing
   If Not xmlProc Is Nothing Then Set xmlProc = Nothing
   If Not xmlParams Is Nothing Then Set xmlParams = Nothing
   If Not xmlParamWrite Is Nothing Then Set xmlParamWrite = Nothing
   If Not xmlParamRead Is Nothing Then Set xmlParamRead = Nothing
   If Not xmlSIDname Is Nothing Then Set xmlSIDname = Nothing     '20Aug12 CKJ added
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & ProcedureName & ", " & Parameters_XML
   Resume Cleanup
End Function

Public Function ExecuteUpdateCustomSP( _
                                   ByVal SessionID As Long, _
                                   ByVal ProcedureName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As Long
'------------------------------------------------------------------------------------
' Purpose   :  Executes a custom stored procedure, returning it's ReturnValue as a Long
'
' Inputs    :  SessionID      - User's session id, used for security and audit logging
'              ProcedureName  - Name of procedure
'              Parameters_XML - the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
'
' 19Oct04 PW - Created
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteUpdateCustomSP"
Dim ErrorState As udtErrorState
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlParamsDoc As MSXML2.DOMDocument
Dim xmlFunc As MSXML2.IXMLDOMElement
Dim xmlProc As MSXML2.IXMLDOMElement
Dim xmlParams As MSXML2.IXMLDOMElement
Dim xmlParamWrite As MSXML2.IXMLDOMElement
Dim xmlParamRead As MSXML2.IXMLDOMElement
Dim strResponse As String
Dim xmlSIDname As MSXML2.IXMLDOMElement   '20aug12 CKJ
Dim ParamNum As Integer                   '   "
Dim ParamKey As String                    '   "
Dim blnFullSessionIDName As Boolean
Dim strParams As String
Dim lngRet As Long

   On Error GoTo ErrorHandler
   
   If mblnWCF Then
	  OpenWCFConnection
      blnFullSessionIDName = True
      strParams = ""
   Else
      Set xmlDoc = New MSXML2.DOMDocument
   
      Set xmlFunc = xmlDoc.createElement("Function")
      xmlDoc.appendChild xmlFunc
      xmlFunc.setAttribute "Name", SUB_NAME
                                  
      Set xmlProc = xmlDoc.createElement("Procedure")
      xmlFunc.appendChild xmlProc
      xmlProc.Text = ProcedureName
   End If
   
   '20aug12 CKJ added block
   If GetParameterList(SessionID, ProcedureName) Then
      ParamKey = ProcedureName & ":1"
      If mdParam.Exists(ParamKey) Then
         If LCase(mdParam.Item(ParamKey)) = "sessionid" Then        'First param is "sessionid" (case insensitive)
            If mblnWCF Then
               blnFullSessionIDName = False
            Else
               Set xmlSIDname = xmlDoc.createElement("SessionIDName")
               xmlFunc.appendChild xmlSIDname
               xmlSIDname.Text = mdParam.Item(ParamKey)
            End If
         End If
      End If
   End If
   
   If Parameters_XML <> vbNullString Then
      If Not mblnWCF Then
         Set xmlParams = xmlDoc.createElement("Parameters")
         xmlFunc.appendChild xmlParams
      End If
      Set xmlParamsDoc = New MSXML2.DOMDocument
      
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"         '20aug12 CKJ added

      If Not xmlParamsDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      ParamNum = 1
      For Each xmlParamRead In xmlParamsDoc.documentElement.childNodes
         Set xmlParamWrite = xmlParamRead.cloneNode(True)
         
         '20aug12 CKJ added block
         ParamNum = ParamNum + 1
         ParamKey = ProcedureName & Format$(ParamNum, "\:0")
         If mdParam.Exists(ParamKey) Then
            xmlParamWrite.setAttribute "Name", mdParam.Item(ParamKey)
         End If
         
         If mblnWCF Then
            strParams = strParams & xmlParamWrite.xml
         Else
            xmlParams.appendChild xmlParamWrite
         End If
      Next xmlParamRead
   End If

   If mblnWCF Then
      lngRet = mobjWCF.ExecuteUpdateCustomSP(SessionID, ProcedureName, strParams, blnFullSessionIDName)
   Else
      strResponse = SendData(SessionID, xmlDoc.xml)
      lngRet = CLng(strResponse)
   End If

   ExecuteUpdateCustomSP = lngRet
   
Cleanup:
   If Not xmlDoc Is Nothing Then Set xmlDoc = Nothing
   If Not xmlParamsDoc Is Nothing Then Set xmlParamsDoc = Nothing
   If Not xmlFunc Is Nothing Then Set xmlFunc = Nothing
   If Not xmlProc Is Nothing Then Set xmlProc = Nothing
   If Not xmlParams Is Nothing Then Set xmlParams = Nothing
   If Not xmlParamWrite Is Nothing Then Set xmlParamWrite = Nothing
   If Not xmlParamRead Is Nothing Then Set xmlParamRead = Nothing
   If Not xmlSIDname Is Nothing Then Set xmlSIDname = Nothing     '20Aug12 CKJ added
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & ProcedureName & ", " & Parameters_XML
   Resume Cleanup
End Function

Public Function ExecuteInsertSP( _
                                   ByVal SessionID As Long, _
                                   ByVal TableName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As Long
'------------------------------------------------------------------------------------
' Purpose   :  Executes the Insert stored procedure associated with TableName,
'              to insert a record using values specified in Parameters_XML.
'              Parameter values are matched to columns by ordinal position, (not by name, as parameter names are ignored)
'              Parameters should not include the table's primary key.
'              The number of parameter's passed in should be one less than the number of columns in the table.
'              Return value is the Primary Key of the newly inserted record.
'
' Inputs    :  SessionID       - User's session id, used for security and audit logging
'              TableName       - Name of table
'              Parameters_XML  - The Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Returns the Last OUTPUT parameter of SP,
'              which will be the PrimaryKey of the newly inserted record.
'
' Revision History
'
' 22Apr02 RA - Created
' 18Jan03 PH - Updated
' 28Jul03 AE  Code to copy XML parameters into adoCmd now in XMLParamsToADO
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteInsertSP"
Dim ErrorState As udtErrorState
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlParamsDoc As MSXML2.DOMDocument
Dim xmlFunc As MSXML2.IXMLDOMElement
Dim xmlTableName As MSXML2.IXMLDOMElement
Dim xmlParams As MSXML2.IXMLDOMElement
Dim xmlParamWrite As MSXML2.IXMLDOMElement
Dim xmlParamRead As MSXML2.IXMLDOMElement
Dim strResponse As String
Dim xmlSIDname As MSXML2.IXMLDOMElement   '20aug12 CKJ
Dim ParamNum As Integer                   '   "
Dim ParamKey As String                    '   "
Dim ProcedureName As String               '   "
Dim blnFullSessionIDName As Boolean
Dim strParams As String
Dim lngRet As Long

   On Error GoTo ErrorHandler
   
   If mblnWCF Then
	  OpenWCFConnection
      blnFullSessionIDName = True
      strParams = ""
   Else
      Set xmlDoc = New MSXML2.DOMDocument
   
      Set xmlFunc = xmlDoc.createElement("Function")
      xmlDoc.appendChild xmlFunc
      xmlFunc.setAttribute "Name", SUB_NAME
                                  
      Set xmlTableName = xmlDoc.createElement("TableName")
      xmlFunc.appendChild xmlTableName
      xmlTableName.Text = TableName
   End If
   
   '20aug12 CKJ added block
   ProcedureName = "p" & TableName & "INSERT"
   If GetParameterList(SessionID, ProcedureName) Then
      ParamKey = ProcedureName & ":1"
      If mdParam.Exists(ParamKey) Then
         If LCase(mdParam.Item(ParamKey)) = "sessionid" Then        'First param is "sessionid" (case insensitive)
            If mblnWCF Then
               blnFullSessionIDName = False
            Else
               Set xmlSIDname = xmlDoc.createElement("SessionIDName")
               xmlFunc.appendChild xmlSIDname
               xmlSIDname.Text = mdParam.Item(ParamKey)
            End If
         End If
      End If
   End If
   
   If Parameters_XML <> vbNullString Then
      If Not mblnWCF Then
         Set xmlParams = xmlDoc.createElement("Parameters")
         xmlFunc.appendChild xmlParams
      End If
      Set xmlParamsDoc = New MSXML2.DOMDocument
      
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"         '20aug12 CKJ added
      
      If Not xmlParamsDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      ParamNum = 1
      For Each xmlParamRead In xmlParamsDoc.documentElement.childNodes
         Set xmlParamWrite = xmlParamRead.cloneNode(True)
         
         '20aug12 CKJ added block
         ParamNum = ParamNum + 1
         ParamKey = ProcedureName & Format$(ParamNum, "\:0")
         If mdParam.Exists(ParamKey) Then
            xmlParamWrite.setAttribute "Name", mdParam.Item(ParamKey)
         End If
         
         If mblnWCF Then
            strParams = strParams & xmlParamWrite.xml
         Else
            xmlParams.appendChild xmlParamWrite
         End If
      Next xmlParamRead
   End If

   If mblnWCF Then
      lngRet = mobjWCF.ExecuteInsertSP(SessionID, TableName, strParams, blnFullSessionIDName)
   Else
      strResponse = SendData(SessionID, xmlDoc.xml)
      lngRet = CLng(strResponse)
   End If

   ExecuteInsertSP = lngRet
   
Cleanup:
   If Not xmlDoc Is Nothing Then Set xmlDoc = Nothing
   If Not xmlParamsDoc Is Nothing Then Set xmlParamsDoc = Nothing
   If Not xmlFunc Is Nothing Then Set xmlFunc = Nothing
   If Not xmlTableName Is Nothing Then Set xmlTableName = Nothing
   If Not xmlParams Is Nothing Then Set xmlParams = Nothing
   If Not xmlParamWrite Is Nothing Then Set xmlParamWrite = Nothing
   If Not xmlParamRead Is Nothing Then Set xmlParamRead = Nothing
   If Not xmlSIDname Is Nothing Then Set xmlSIDname = Nothing     '20Aug12 CKJ added
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & TableName & ", " & Parameters_XML
   Resume Cleanup
End Function

Public Function ExecuteUpdateSP( _
                                   ByVal SessionID As Long, _
                                   ByVal TableName As String, _
                                   ByVal Parameters_XML As String _
                               ) _
                               As Long
'------------------------------------------------------------------------------------
' Purpose   :  Executes the Update stored procedure associated with TableName.
'              Parameters_XML will contain the new values in column order.
'              The first ordinal parameter must be the PrimaryKey of the row to update.
'              Return Value is a SQL Error number returned from the stored procedure.
'              A Return Value of zero indicates success.
'
' Inputs    :  SessionID      - User's session id, used for security and audit logging
'              TableName      - name of table
'              ParametersXML  - the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
' 22Apr02 RA - Created
' 18Jan03 PH - Updated
' 28Jul03 AE  Code to copy XML parameters into adoCmd now in XMLParamsToADO
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteUpdateSP"
Dim ErrorState As udtErrorState
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlParamsDoc As MSXML2.DOMDocument
Dim xmlFunc As MSXML2.IXMLDOMElement
Dim xmlTableName As MSXML2.IXMLDOMElement
Dim xmlParams As MSXML2.IXMLDOMElement
Dim xmlParamWrite As MSXML2.IXMLDOMElement
Dim xmlParamRead As MSXML2.IXMLDOMElement
Dim strResponse As String
Dim xmlSIDname As MSXML2.IXMLDOMElement   '20aug12 CKJ
Dim ParamNum As Integer                   '   "
Dim ParamKey As String                    '   "
Dim ProcedureName As String               '   "
Dim blnFullSessionIDName As Boolean
Dim strParams As String
Dim lngRet As Long

   On Error GoTo ErrorHandler
   
   If mblnWCF Then
	  OpenWCFConnection
      blnFullSessionIDName = True
      strParams = ""
   Else
      Set xmlDoc = New MSXML2.DOMDocument
   
      Set xmlFunc = xmlDoc.createElement("Function")
      xmlDoc.appendChild xmlFunc
      xmlFunc.setAttribute "Name", SUB_NAME
                                  
      Set xmlTableName = xmlDoc.createElement("TableName")
      xmlFunc.appendChild xmlTableName
      xmlTableName.Text = TableName
   End If

   '20aug12 CKJ added block
   ProcedureName = "p" & TableName & "UPDATE"
   If GetParameterList(SessionID, ProcedureName) Then
      ParamKey = ProcedureName & ":1"
      If mdParam.Exists(ParamKey) Then
         If LCase(mdParam.Item(ParamKey)) = "sessionid" Then        'First param is "sessionid" (case insensitive)
            If mblnWCF Then
               blnFullSessionIDName = False
            Else
               Set xmlSIDname = xmlDoc.createElement("SessionIDName")
               xmlFunc.appendChild xmlSIDname
               xmlSIDname.Text = mdParam.Item(ParamKey)
            End If
         End If
      End If
   End If
   
   If Parameters_XML <> vbNullString Then
      If Not mblnWCF Then
         Set xmlParams = xmlDoc.createElement("Parameters")
         xmlFunc.appendChild xmlParams
      End If
      Set xmlParamsDoc = New MSXML2.DOMDocument
      
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"         '20aug12 CKJ added
      
      If Not xmlParamsDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      ParamNum = 1
      For Each xmlParamRead In xmlParamsDoc.documentElement.childNodes
         Set xmlParamWrite = xmlParamRead.cloneNode(True)
         
         '20aug12 CKJ added block
         ParamNum = ParamNum + 1
         ParamKey = ProcedureName & Format$(ParamNum, "\:0")
         If mdParam.Exists(ParamKey) Then
            xmlParamWrite.setAttribute "Name", mdParam.Item(ParamKey)
         End If

         If mblnWCF Then
            strParams = strParams & xmlParamWrite.xml
         Else
            xmlParams.appendChild xmlParamWrite
         End If
      Next xmlParamRead
   End If

   If mblnWCF Then
      lngRet = mobjWCF.ExecuteUpdateSP(SessionID, TableName, strParams, blnFullSessionIDName)
   Else
      strResponse = SendData(SessionID, xmlDoc.xml)
      lngRet = CLng(strResponse)
   End If

   ExecuteUpdateSP = lngRet
   
Cleanup:
   If Not xmlDoc Is Nothing Then Set xmlDoc = Nothing
   If Not xmlParamsDoc Is Nothing Then Set xmlParamsDoc = Nothing
   If Not xmlFunc Is Nothing Then Set xmlFunc = Nothing
   If Not xmlTableName Is Nothing Then Set xmlTableName = Nothing
   If Not xmlParams Is Nothing Then Set xmlParams = Nothing
   If Not xmlParamWrite Is Nothing Then Set xmlParamWrite = Nothing
   If Not xmlParamRead Is Nothing Then Set xmlParamRead = Nothing
   If Not xmlSIDname Is Nothing Then Set xmlSIDname = Nothing     '20Aug12 CKJ added
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & TableName & ", " & Parameters_XML
   Resume Cleanup
End Function

Public Function ExecuteDeleteSP( _
                                   ByVal SessionID As Long, _
                                   ByVal TableName As String, _
                                   ByVal PrimaryKey As Long _
                               ) _
                               As Long
'------------------------------------------------------------------------------------
' Purpose   :  Executes the Delete stored procedure associated with TableName,
'              removing the record identified by PrimaryKey.
'              Return Value is a SQL Error number returned from the stored procedure.
'              A Return Value of zero indicates success.
'
' Inputs    :  SessionID  -  User's session id, used for security and audit logging
'              TableName  - name of table
'              PrimaryKey - Primary Key of record to delete
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
' 22Apr02 RA - Created
' 18Jan03 PH - Updated
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteDeleteSP"
Dim ErrorState As udtErrorState
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlParamsDoc As MSXML2.DOMDocument
Dim xmlFunc As MSXML2.IXMLDOMElement
Dim xmlTableName As MSXML2.IXMLDOMElement
Dim xmlPrimaryKey As MSXML2.IXMLDOMElement
Dim strResponse As String
Dim xmlSIDname As MSXML2.IXMLDOMElement   '20aug12 CKJ
Dim ParamKey As String                    '   "
Dim ProcedureName As String               '   "
Dim blnFullSessionIDName As Boolean
Dim lngRet As Long

   On Error GoTo ErrorHandler
   
   If mblnWCF Then
	  OpenWCFConnection
      blnFullSessionIDName = True
   Else
      Set xmlDoc = New MSXML2.DOMDocument
   
      Set xmlFunc = xmlDoc.createElement("Function")
      xmlDoc.appendChild xmlFunc
      xmlFunc.setAttribute "Name", SUB_NAME
                                  
      Set xmlTableName = xmlDoc.createElement("TableName")
      xmlFunc.appendChild xmlTableName
      xmlTableName.Text = TableName
      
      Set xmlPrimaryKey = xmlDoc.createElement("PrimaryKey")   'Note: This is replaced by the correct name within the server code
      xmlFunc.appendChild xmlPrimaryKey                        '      No need to look up the name here (unlike most other calls)
      xmlPrimaryKey.Text = PrimaryKey
   End If
   
   '20aug12 CKJ added block
   ProcedureName = "p" & TableName & "DELETE"               'Note: The web side is hard coded to DELETE not LOGICALDELETE
   If GetParameterList(SessionID, ProcedureName) Then
      ParamKey = ProcedureName & ":1"
      If mdParam.Exists(ParamKey) Then
         If LCase(mdParam.Item(ParamKey)) = "sessionid" Then        'First param is "sessionid" (case insensitive)
            If mblnWCF Then
               blnFullSessionIDName = False
            Else
               Set xmlSIDname = xmlDoc.createElement("SessionIDName")
               xmlFunc.appendChild xmlSIDname
               xmlSIDname.Text = mdParam.Item(ParamKey)
            End If
         End If
      End If
   End If
   
   If mblnWCF Then
      lngRet = mobjWCF.ExecuteDeleteSP(SessionID, TableName, PrimaryKey, blnFullSessionIDName)
   Else
      strResponse = SendData(SessionID, xmlDoc.xml)
      lngRet = CLng(strResponse)
   End If

   ExecuteDeleteSP = lngRet
   
Cleanup:
   If Not xmlDoc Is Nothing Then Set xmlDoc = Nothing
   If Not xmlParamsDoc Is Nothing Then Set xmlParamsDoc = Nothing
   If Not xmlFunc Is Nothing Then Set xmlFunc = Nothing
   If Not xmlTableName Is Nothing Then Set xmlTableName = Nothing
   If Not xmlPrimaryKey Is Nothing Then Set xmlPrimaryKey = Nothing
   If Not xmlSIDname Is Nothing Then Set xmlSIDname = Nothing     '20Aug12 CKJ added
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & TableName & ", " & PrimaryKey
   Resume Cleanup
End Function

Public Function ExecuteInsertLinkSP( _
                                        ByVal SessionID As Long, _
                                        ByVal TableName As String, _
                                        ByVal Parameters_XML As String _
                                    ) _
                                    As Long
'------------------------------------------------------------------------------------
' Purpose   :  Executes the Insert Link stored procedure associated with the Link Table named TableName.
'              Parameter values are matched to columns by ordinal position, (not by name, as parameter names are ignored)
'              Link tables only ever contain two columns: the primary keys of the two tables they join together,
'              therefore, there should only ever be two parameters in Parameters_XML.
'              Return Value is a SQL Error number returned from the stored procedure.
'              A Return Value of zero indicates success.
'
' Inputs    :  SessionID      -  User's session id, used for security and audit logging
'              TableName      - name of table
'              ParametersXML  - the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
' 25Nov02 PH - Created
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteInsertLinkSP"
Dim ErrorState As udtErrorState
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlParamsDoc As MSXML2.DOMDocument
Dim xmlFunc As MSXML2.IXMLDOMElement
Dim xmlTableName As MSXML2.IXMLDOMElement
Dim xmlParams As MSXML2.IXMLDOMElement
Dim xmlParamWrite As MSXML2.IXMLDOMElement
Dim xmlParamRead As MSXML2.IXMLDOMElement
Dim strResponse As String
Dim xmlSIDname As MSXML2.IXMLDOMElement   '20aug12 CKJ
Dim ParamNum As Integer                   '   "
Dim ParamKey As String                    '   "
Dim ProcedureName As String               '   "
Dim blnFullSessionIDName As Boolean
Dim strParams As String
Dim lngRet As Long

   On Error GoTo ErrorHandler
   
   If mblnWCF Then
	  OpenWCFConnection
      blnFullSessionIDName = True
      strParams = ""
   Else
      Set xmlDoc = New MSXML2.DOMDocument
   
      Set xmlFunc = xmlDoc.createElement("Function")
      xmlDoc.appendChild xmlFunc
      xmlFunc.setAttribute "Name", SUB_NAME
                                  
      Set xmlTableName = xmlDoc.createElement("TableName")
      xmlFunc.appendChild xmlTableName
      xmlTableName.Text = TableName
   End If
   
   '20aug12 CKJ added block
   ProcedureName = "p" & TableName & "INSERT"               'Note: The web side SP is INSERT not INSERTLINK
   If GetParameterList(SessionID, ProcedureName) Then
      ParamKey = ProcedureName & ":1"
      If mdParam.Exists(ParamKey) Then
         If LCase(mdParam.Item(ParamKey)) = "sessionid" Then        'First param is "sessionid" (case insensitive)
            If mblnWCF Then
               blnFullSessionIDName = False
            Else
               Set xmlSIDname = xmlDoc.createElement("SessionIDName")
               xmlFunc.appendChild xmlSIDname
               xmlSIDname.Text = mdParam.Item(ParamKey)
            End If
         End If
      End If
   End If

   If Parameters_XML <> vbNullString Then
      If Not mblnWCF Then
         Set xmlParams = xmlDoc.createElement("Parameters")
         xmlFunc.appendChild xmlParams
      End If
      Set xmlParamsDoc = New MSXML2.DOMDocument
      
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"         '20aug12 CKJ added
      
      If Not xmlParamsDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      ParamNum = 1
      For Each xmlParamRead In xmlParamsDoc.documentElement.childNodes
         Set xmlParamWrite = xmlParamRead.cloneNode(True)

         '20aug12 CKJ added block
         ParamNum = ParamNum + 1
         ParamKey = ProcedureName & Format$(ParamNum, "\:0")
         If mdParam.Exists(ParamKey) Then
            xmlParamWrite.setAttribute "Name", mdParam.Item(ParamKey)
         End If

         If mblnWCF Then
            strParams = strParams & xmlParamWrite.xml
         Else
            xmlParams.appendChild xmlParamWrite
         End If
      Next xmlParamRead
   End If

   If mblnWCF Then
      lngRet = mobjWCF.ExecuteInsertLinkSP(SessionID, TableName, strParams, blnFullSessionIDName)
   Else
      strResponse = SendData(SessionID, xmlDoc.xml)
      lngRet = CLng(strResponse)
   End If

   ExecuteInsertLinkSP = lngRet
   
Cleanup:
   If Not xmlDoc Is Nothing Then Set xmlDoc = Nothing
   If Not xmlParamsDoc Is Nothing Then Set xmlParamsDoc = Nothing
   If Not xmlFunc Is Nothing Then Set xmlFunc = Nothing
   If Not xmlTableName Is Nothing Then Set xmlTableName = Nothing
   If Not xmlParams Is Nothing Then Set xmlParams = Nothing
   If Not xmlParamWrite Is Nothing Then Set xmlParamWrite = Nothing
   If Not xmlParamRead Is Nothing Then Set xmlParamRead = Nothing
   If Not xmlSIDname Is Nothing Then Set xmlSIDname = Nothing     '20Aug12 CKJ added
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & TableName & ", " & Parameters_XML
   Resume Cleanup
End Function

Public Function ExecuteDeleteLinkSP( _
                                        ByVal SessionID As Long, _
                                        ByVal TableName As String, _
                                        ByVal Parameters_XML As String _
                                    ) _
                                    As Long
'------------------------------------------------------------------------------------
' Purpose   :  Executes the Delete Link stored procedure associated with the Link Table named TableName.
'              Parameter values are matched to columns by ordinal position, (not by name, as parameter names are ignored)
'              Link tables only ever contain two columns: the primary keys of the two tables they join together,
'              therefore, there should only ever be two parameters in Parameters_XML.
'              Return Value is a SQL Error number returned from the stored procedure.
'              A Return Value of zero indicates success.
'
' Inputs    :  SessionID      - User's session id, used for security and audit logging
'              TableName      - name of table
'              ParametersXML  - the Command object parameters to pass to the SP
'
' Outputs   :
'
' Return    :  Return value of stored procedure
'
' Revision History
'
' 25Nov02 PH - Created
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "ExecuteDeleteLinkSP"
Dim ErrorState As udtErrorState
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlParamsDoc As MSXML2.DOMDocument
Dim xmlFunc As MSXML2.IXMLDOMElement
Dim xmlTableName As MSXML2.IXMLDOMElement
Dim xmlParams As MSXML2.IXMLDOMElement
Dim xmlParamWrite As MSXML2.IXMLDOMElement
Dim xmlParamRead As MSXML2.IXMLDOMElement
Dim strResponse As String
Dim xmlSIDname As MSXML2.IXMLDOMElement   '20aug12 CKJ
Dim ParamNum As Integer                   '   "
Dim ParamKey As String                    '   "
Dim ProcedureName As String               '   "
Dim blnFullSessionIDName As Boolean
Dim strParams As String
Dim lngRet As Long

   On Error GoTo ErrorHandler
   
   If mblnWCF Then
	  OpenWCFConnection
      blnFullSessionIDName = True
      strParams = ""
   Else
      Set xmlDoc = New MSXML2.DOMDocument
   
      Set xmlFunc = xmlDoc.createElement("Function")
      xmlDoc.appendChild xmlFunc
      xmlFunc.setAttribute "Name", SUB_NAME
                                  
      Set xmlTableName = xmlDoc.createElement("TableName")
      xmlFunc.appendChild xmlTableName
      xmlTableName.Text = TableName
   End If

   '20aug12 CKJ added block
   ProcedureName = "p" & TableName & "DELETE"               'Note: The web side is hard coded to DELETE not DELETELINK, LOGICALDELETE or LOGICALDELETELINK
   If GetParameterList(SessionID, ProcedureName) Then
      ParamKey = ProcedureName & ":1"
      If mdParam.Exists(ParamKey) Then
         If LCase(mdParam.Item(ParamKey)) = "sessionid" Then        'First param is "sessionid" (case insensitive)
            If mblnWCF Then
               blnFullSessionIDName = False
            Else
               Set xmlSIDname = xmlDoc.createElement("SessionIDName")
               xmlFunc.appendChild xmlSIDname
               xmlSIDname.Text = mdParam.Item(ParamKey)
            End If
         End If
      End If
   End If
   
   If Parameters_XML <> vbNullString Then
      If Not mblnWCF Then
         Set xmlParams = xmlDoc.createElement("Parameters")
         xmlFunc.appendChild xmlParams
      End If
      Set xmlParamsDoc = New MSXML2.DOMDocument
      
      Parameters_XML = "<Parameters>" & Parameters_XML & "</Parameters>"         '20aug12 CKJ added
      
      If Not xmlParamsDoc.loadXML(Parameters_XML) Then
         RaiseError erLoadXMLFailed
      End If
      ParamNum = 1
      For Each xmlParamRead In xmlParamsDoc.documentElement.childNodes
         Set xmlParamWrite = xmlParamRead.cloneNode(True)

         '20aug12 CKJ added block
         ParamNum = ParamNum + 1
         ParamKey = ProcedureName & Format$(ParamNum, "\:0")
         If mdParam.Exists(ParamKey) Then
            xmlParamWrite.setAttribute "Name", mdParam.Item(ParamKey)
         End If

         If mblnWCF Then
            strParams = strParams & xmlParamWrite.xml
         Else
            xmlParams.appendChild xmlParamWrite
         End If
      Next xmlParamRead
   End If

   If mblnWCF Then
      lngRet = mobjWCF.ExecuteDeleteLinkSP(SessionID, TableName, strParams, blnFullSessionIDName)
   Else
      strResponse = SendData(SessionID, xmlDoc.xml)
      lngRet = CLng(strResponse)
   End If

   ExecuteDeleteLinkSP = lngRet
   
Cleanup:
   If Not xmlDoc Is Nothing Then Set xmlDoc = Nothing
   If Not xmlParamsDoc Is Nothing Then Set xmlParamsDoc = Nothing
   If Not xmlFunc Is Nothing Then Set xmlFunc = Nothing
   If Not xmlTableName Is Nothing Then Set xmlTableName = Nothing
   If Not xmlParams Is Nothing Then Set xmlParams = Nothing
   If Not xmlParamWrite Is Nothing Then Set xmlParamWrite = Nothing
   If Not xmlParamRead Is Nothing Then Set xmlParamRead = Nothing
   If Not xmlSIDname Is Nothing Then Set xmlSIDname = Nothing     '20Aug12 CKJ added
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & TableName & ", " & Parameters_XML
   Resume Cleanup
End Function

Public Function GetRowLock( _
                                   ByVal SessionID As Long, _
                                   ByVal TableName As String, _
                                   ByVal PrimaryKey As Long _
                               ) _
                               As Boolean
                               
'------------------------------------------------------------------------------------
' Purpose   :  Uses SQL to lock a ROW on a given table
'
' Inputs    :  SessionID      -  User's session id, used for security and audit logging
'              TableName      -  name of Table where locked ROW is required
'              PrimaryKey     -  Numeric value
'
' Outputs   :
'
' Return    :  Boolean for Success
'
' Revision History
'
' 08Oct2004 PW - Created
'------------------------------------------------------------------------------------

Const SUB_NAME As String = "GetRowLock"
Dim ErrorState As udtErrorState
Dim xmlDoc As MSXML2.DOMDocument
Dim xmlParamsDoc As MSXML2.DOMDocument
Dim xmlFunc As MSXML2.IXMLDOMElement
Dim xmlTableName As MSXML2.IXMLDOMElement
Dim xmlPrimaryKey As MSXML2.IXMLDOMElement
Dim strResponse As String

   On Error GoTo ErrorHandler
   
   Set xmlDoc = New MSXML2.DOMDocument

   Set xmlFunc = xmlDoc.createElement("Function")
   xmlDoc.appendChild xmlFunc
   xmlFunc.setAttribute "Name", SUB_NAME
                               
   Set xmlTableName = xmlDoc.createElement("TableName")
   xmlFunc.appendChild xmlTableName
   xmlTableName.Text = TableName
      
   Set xmlPrimaryKey = xmlDoc.createElement("PrimaryKey")   'Note: This is replaced by the correct name within the server code
   xmlFunc.appendChild xmlPrimaryKey                        '      No need to look up the name here (unlike most other calls)
   xmlPrimaryKey.Text = PrimaryKey
   
   strResponse = SendData(SessionID, xmlDoc.xml)            'Note: No need to look up 'SessionID' param name as no SP is used.

   GetRowLock = CLng(strResponse)
   
Cleanup:
   If Not xmlDoc Is Nothing Then Set xmlDoc = Nothing
   If Not xmlParamsDoc Is Nothing Then Set xmlParamsDoc = Nothing
   If Not xmlFunc Is Nothing Then Set xmlFunc = Nothing
   If Not xmlTableName Is Nothing Then Set xmlTableName = Nothing
   If Not xmlPrimaryKey Is Nothing Then Set xmlPrimaryKey = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & TableName & ", " & PrimaryKey
   Resume Cleanup
End Function

Function GetParameterList(ByVal SessionID As Long, ByVal ProcedureName As String) As Boolean
'------------------------------------------------------------------------------------
' Purpose   :  Find list of parameters for a given SQL stored procedure
'
' Inputs    :  SessionID      -  User's session id, used for security and audit logging
'              ProcedureName  -  name of procedure to look up
'
' Actions   :  Places parameter details in module level dictionary mdParam
'
' Outputs   :  none
'
' Return    :  boolean success
'
' Revision History
' 14Aug12 CKJ Written
'------------------------------------------------------------------------------------
Const SUB_NAME As String = "GetParameterList"
Dim ErrorState As udtErrorState
Dim strResponse As String
Dim success As Boolean
Dim xml As String
Dim xmlRetDoc As MSXML2.DOMDocument
Dim rs As ADODB.Recordset
Dim ParamNum As Integer

   On Error GoTo ErrorHandler
   success = False
   
   If Len(ProcedureName) Then
      If mdParam.Exists(ProcedureName) Then
         success = True
      Else
         xml = "<Function Name=""ExecuteSelectSP""><Procedure>pParameterList</Procedure><Parameters>" & _
               "<Parameter Name=""ProcedureName"" DataType=""16"" Direction=""1"" Length=""255"" Value=""" & ProcedureName & """/>" & _
               "</Parameters></Function>"
      
         If Not mblnWCF Then strResponse = SendData(SessionID, xml)
         
         If Len(strResponse) > 0 Or mblnWCF Then
            If mblnWCF Then
               Set rs = New ADODB.Recordset
               Set rs = mobjWCF.ExecuteSelectSP(SessionID, "pParameterList", "<Parameter Name=""ProcedureName"" DataType=""16"" Direction=""1"" Length=""255"" Value=""" & ProcedureName & """/>", True)
            Else
               Set xmlRetDoc = New MSXML2.DOMDocument
               xmlRetDoc.loadXML strResponse
               Set rs = New ADODB.Recordset
               rs.Open xmlRetDoc
            End If
            rs.MoveFirst
            
            mdParam.Add ProcedureName, rs.RecordCount
            
            ParamNum = 0
            Do While Not rs.EOF
               ParamNum = ParamNum + 1
               mdParam.Add ProcedureName & Format$(ParamNum, "\:0"), rs!Parameter.Value
               rs.MoveNext
            Loop
            If ParamNum > 0 Then success = True
         End If
      End If
   End If
   
Cleanup:
   On Error GoTo 0
   If Not xmlRetDoc Is Nothing Then Set xmlRetDoc = Nothing
   If Not rs Is Nothing Then Set rs = Nothing
   BubbleOnError ErrorState
   GetParameterList = success
Exit Function

ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME, SessionID & ", " & ProcedureName
   Resume Cleanup
End Function


