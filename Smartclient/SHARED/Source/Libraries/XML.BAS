'18Mar02 ATW
'
' Routines to support very simple parsing of XML.

' At present, only supports Elements.

' To parse XML....

'  intContinue is a progress pointer and will be altered by the routines as they parse.

'  XMlGetNextTag returns the next tag name (or "" For EOF), whether it is a close tag, whether it is a text element,
'        and modifies the pointer to the character after the end of this tag.

'  XMlGetElementText returns the text in the tag (providing it returned isText = true - this is not trapped, so you
'         must be careful), and repositions the pointer AFTER the CLOSE TAG for that element.

' Will raise errors on a couple of glaring inconsistencies, but is largely untrapped as yet.


Option Explicit
DefInt A-Z     '01Jun02 All/CKJ

Const TAG_OPEN = "<"
Const TAG_CLOSE = ">"
Const ELEMENT_CLOSE = "/"

Private Sub FromSafeXML (pstr$)
' 24Apr02 ATW
'  Replaces XML escape sequences with their 'real' equivalents.

   replace pstr, "&quot;", """", 0
   replace pstr, "&lt;", "<", 0
   replace pstr, "&gt;", ">", 0
   replace pstr, "&apos;", "'", 0
   replace pstr, "&amp;", "&", 0

End Sub

Private Sub ToSafeXML (pstr$)
'27Feb02 ATW
' Replaces XML reserved characters in plain strings with their XML escape sequences.
  replace pstr, "&", "&amp;", 0
  replace pstr, "'", "&apos;", 0
  replace pstr, ">", "&gt;", 0
  replace pstr, "<", "&lt;", 0
  replace pstr, """", "&quot;", 0
  
'

End Sub

Function XMLGetElementText (strXML As String, intContinue As Integer) As String
'24Apr02 ATW
'
'  Description : Gets the text content from the element at intContinue
'                 and moves to the next element
'
'  Input:      strXML         ;  The XML, by reference for speed.
'              intContinue    ;  Current position in the XML
'
'  Output      intContinue    ;  Advanced to the beginning of the next element
'              Return         ;  Returns the string content of the element.

Dim intClosePos As Integer
Dim strOutput As String

   intClosePos = InStr(intContinue, strXML, TAG_OPEN & ELEMENT_CLOSE)

   strOutput = Mid$(strXML, intContinue, (intClosePos - intContinue))
   FromSafeXML strOutput
   XMLGetElementText = strOutput

   intContinue = InStr(intClosePos, strXML, TAG_CLOSE) + 1

End Function

Function XMLGetNextTag (strXML As String, intContinue As Integer, isText As Integer, isClose As Integer) As String
'24Apr02 ATW
'
'  Description :  Finds the next tag in an XML string and returns various info
'
'  Input :     strXML      ;  The XML, by reference for speed
'              intContinue ;  Progress pointer.
'
'  Output:     intContinue ;  Pointer is advanced to the beginning of the next tag
'              isText      ;  Boolean int - is this a text element? (i.e. contains no other elements)
'              isClose     ;  Boolean int - is this tag an element closure tag?
'              Return      ;  The name of the tag.
'
Dim strTag As String

Dim intTagOpen As Integer
Dim intTagClose As Integer
Dim intNextElementClose As Integer

   isClose = False
   isText = False
   
   If intContinue = 0 Then intContinue = 1

   intTagOpen = InStr(intContinue, strXML, TAG_OPEN)
   intTagClose = InStr(intTagOpen, strXML, TAG_CLOSE)

   If intTagOpen = 0 Then
         XMLGetNextTag = ""
         Exit Function
      End If

   If intTagClose = 0 Then
         Error 10001
      End If

   strTag = Mid$(strXML, intTagOpen + 1, (intTagClose - intTagOpen) - 1)

   If Left$(strTag, 1) = ELEMENT_CLOSE Then
         isClose = True
         strTag = Mid$(strTag, 2)
      End If

   If Not isClose Then
         intNextElementClose = InStr(intTagClose, strXML, TAG_OPEN & ELEMENT_CLOSE)
         
         If intNextElementClose = 0 Then
               Error 10001
            End If
         
         If InStr(intTagClose + 1, strXML, TAG_OPEN) = intNextElementClose Then
               isText = True
            End If

      End If

   XMLGetNextTag = strTag

   intContinue = intTagClose + 1
                                   
End Function

