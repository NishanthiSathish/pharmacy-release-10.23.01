Attribute VB_Name = "RPTHELP"
Option Explicit
'22Aug02 ATW
'  Description :  Moved some routines with more general use out
'                    of TOFOLLOW.BAS

Function HeaderFromLayout(ByVal Layout As String, ByVal ReportName As String) As String
'26Apr02 ATW
'  Description  :  Constructs a report header from a layout line
'                    by parsing the line and replacing the tags with descriptive headers
'
'  Input :        Layout      ;  The layout line
'                 ReportName  ;  Determines which section of HEAPDESC.ini to use
'
'  Output:        Return      ;  The header line
'
Dim astrTag() As String
Dim intCounter As Integer
Dim intTagCount As Integer

Dim strOpenFormat As String
Dim strCloseFormat As String

Dim intTagEnd As Integer
Dim strTag As String

Static m_intHeaderHeap As Integer

   If m_intHeaderHeap = 0 Then
         Heap 1, m_intHeaderHeap, "TO_FOLLOW_HEADER", "To Follow report dynamic header heap", 0
      End If

   strOpenFormat = TagDescription("FormatOpen", ReportName)
   strCloseFormat = TagDescription("FormatClose", ReportName)

   'parse out the heap tags and fetch the descriptions for them from HeapDesc.ini
   ReDim astrTag(50)

   deflines Layout, astrTag(), "[(*)", 0, intTagCount
   
   For intCounter = 1 To intTagCount - 1
      intTagEnd = InStr(1, astrTag(intCounter), "]")
      strTag = Left$(astrTag(intCounter), intTagEnd - 1)
      Heap 10, m_intHeaderHeap, strTag, strOpenFormat & TagDescription(strTag, ReportName) & strCloseFormat, 0
   Next intCounter
   
   ParseItems m_intHeaderHeap, Layout, 0
   
   HeaderFromLayout = TrimToRTFTable(Layout, True, False)

End Function

Private Function TagDescription(ByVal TagName As String, ByVal ReportName As String) As String
'26Apr02 ATW
'  Description :  Get a description for this heap tag
'
'  Input       :  TagName     ; The tag name
'                 ReportName  ; The report name == section name
'
'  Output      :  Return      ; The description
'
Const FILE = "\HEAPDESC.INI"

Dim strPath As String

Dim found As Integer

   strPath = dispdata$ & FILE
   TagDescription = txtd(strPath, ReportName, TagName, TagName, found)

   If Not found Then ' return the one from the default section instead
         TagDescription = txtd(strPath, "", TagName, TagName, found)
      End If

End Function

Function TrimToRTFTable(ByVal RTF As String, ByVal isFirst As Integer, ByVal isLast As Integer) As String
'26Apr02 ATW
'  Description :  Trim the passed text to a single rtf table row
'
'  Input       :  RTF      ;  The rtf
'                 isFirst  ;  Is this the first row?
'                 isLast   ;  IS this the last row?
'
'  Output      :  Return   ;  The clipped rtf
'
Const RTF_TABLEOPEN = "\trowd"
Const RTF_TABLECLOSE = "\row"

Dim intOpenTable As Integer
Dim intCloseTable As Integer

   intOpenTable = InStr(1, RTF, RTF_TABLEOPEN)
   
   If intOpenTable = 0 Then
         TrimToRTFTable = RTF
         Exit Function
      End If

   intCloseTable = InStr(intOpenTable, RTF, RTF_TABLECLOSE)

   'If isFirst Then intOpenTable = 1

   'If isLast Then
   '      TrimToRTFTable = Mid$(RTF, intOpenTable)
   '   Else
         TrimToRTFTable = Mid$(RTF, intOpenTable, (intCloseTable - intOpenTable) + 4)
   '   End If

End Function

