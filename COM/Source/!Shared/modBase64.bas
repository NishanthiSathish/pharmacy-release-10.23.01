Attribute VB_Name = "modBase64"
Option Explicit
Private Const CLASS_NAME = "modBase64"
'23Oct03 ATW
' Nice & Easy Base64 encode/decode routines
' Thanks to Shamil Slakhetdinov <shamil@daisy.spb.ru> who wrote the original code, which I've trimmed
' considerably. He wrote his own Byte() => String routines, when all you need is StrConv

' Requires  :  MSXML 2.6 (or whatever you compiled it against) - you can get this in MDAC 2.6

' Note that MSXML inserts a newline character every 73 characters when it generates base64 streams
' This is not a legal Base64 alphabet character, but it copes with it's own sewage just fine.

' Thought this was a faster approach than writing a VB routine (the easy ways of doing this
'  in VB6 are really slow due to the apalling string concat, the elegant ways of doing it
'  require you to use MemCopy APIs and write bitshift routines, which are rather opaque in VB6.
'  Curse you Bill, we wanted the << and >> operators in VB3, why'd we have to wait for VB.NET?)


Public Function Encode(ByRef bytaData() As Byte) As String
'------------------------------------------------------------------------------------
' Purpose   :  Encode the data as Base64
'
' Inputs    :  Byte array

' Outputs   :  None
'
' Return    :  Chunk-o-base64
'
' Revision History
' 10Dec03 ATW - Created
'------------------------------------------------------------------------------------
Const SUB_NAME = "Encode"
Dim ErrorState As udtErrorState
'------------------------------

Dim mxmlDOC As DOMDocument
Dim xmlnode As IXMLDOMNode
Dim strTmp As String
Dim lngS As Long, lngE As Long
    
   Set mxmlDOC = New DOMDocument
' create XML node named "ENCODER"
   Set xmlnode = mxmlDOC.createElement("ENCODER")
   With xmlnode
      ' set XML node's data type = "bin.base64"
      .dataType = "bin.base64"
      If LCase(Left(TypeName(bytaData), 4)) = "byte" Then
         ' if input parameter - byte array - just assign it to the
         '  nodeTypedValue property of XML node
         .nodeTypedValue = bytaData
        
      End If
      ' extract base64 encoded value enclosed into
      ' <ENCODER ...>
      '  ...base64 coded value...
      ' </ENCODER>
      ' tags into strTmp temp string
      strTmp = xmlnode.xml
   End With

' get the position of the first char after the end of the beginning tag
   lngS = InStr(strTmp, ">") + 1
' get the position of the ending tag
   lngE = InStr(lngS, strTmp, "<")
' extract base64 encoded value and assign it as the return value of the function
   Encode = Mid$(strTmp, lngS, lngE - lngS)
   
'------------------------------
Cleanup:
   Set xmlnode = Nothing
   Set mxmlDOC = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function
'-------------------------------
ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME

   Resume Cleanup
End Function

Public Function Decode(ByVal vstr As String) As Byte()
'------------------------------------------------------------------------------------
' Purpose   :  Decode a chunk-o-base64 to a byte array
'
' Inputs    :  the string
'
' Outputs   :  None
'
' Return    :  a byte array
'
' Revision History
' 10Dec03 ATW - Created
'------------------------------------------------------------------------------------
Const SUB_NAME = "Decode"
Dim ErrorState As udtErrorState
'------------------------------

Dim strXML As String
Dim mxmlDOC As DOMDocument
Dim xmlnode As IXMLDOMNode

' make well formed XML string
   strXML = "<DECODER xmlns:dt=""urn:schemas-microsoft-com:datatypes"" " & _
      "dt:dt=""bin.base64"">" & _
      vstr & _
      "</DECODER>"
      
   Set mxmlDOC = New DOMDocument
   With mxmlDOC
      ' load XML document from string
      .loadXML strXML
      ' select XML node DECODER
      Set xmlnode = .selectSingleNode("DECODER")
      ' get decoded value and assign it as the function return value
      Decode = xmlnode.nodeTypedValue
   End With
   
'------------------------------
Cleanup:
   Set xmlnode = Nothing
   Set mxmlDOC = Nothing
   
   On Error GoTo 0
   BubbleOnError ErrorState
   Exit Function
'-------------------------------
ErrorHandler:
   CaptureErrorState ErrorState, CLASS_NAME, SUB_NAME

   Resume Cleanup
End Function




