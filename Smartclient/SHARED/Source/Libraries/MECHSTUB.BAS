Attribute VB_Name = "MechDispStub"
'                    MechDisp.bas
'                    ------------
'
'24Feb04 CKJ Written.
'            Stub file for inclusion in projects which do not require access to the
'            Mechanical Dispensing facilities of Swisslog/Rowa/Consis etc
'            FormatCtrlChars has been retained as it may be useful elsewhere, but all
'            other public procs return same answer as if no mech disp is available.
'01Jul04 CKJ MechDispIssue: added blnImmediatePick
'            MechDispEnquiry: added strMessage
'17Aug05 PJC MechDispIssue: added strMessageText
'10Feb07 CKJ Extended fields as necessary
'11Nov06 PJC GetRobotPrintLabelMessageID SetRobotPrintLabelMessageID: stub  (20May08 CKJ ported from V8.8)
'            MechDispIssue: added blnRobotLabelPrint
'20May08 CKJ MechDispLabelConfirm, MechDispClearLabelData: added

Option Explicit
DefInt A-Z


Function FormatCtrlChars(ByVal text As String) As String
'Take a text string and return it with unprintable control chars converted to <hex> equivalents.
'Runs of multiple characters e.g. 23 nulls are returned as <23x0>

Dim count As Integer
Dim msg As String
Dim charcount As Integer
Dim lastchar As Integer
Dim thischar As Integer
Dim asciichar As String

   charcount = 0
   lastchar = -1
   msg = ""

   For count = 1 To Len(text)
      asciichar = Mid$(text, count, 1)   '1 string char
      thischar = Asc(asciichar)          'numeric equivalent
      Select Case thischar
         Case 0 To 31                    'null chars & others often hunts in packs
            If charcount = 0 Or thischar = lastchar Then
                  charcount = charcount + 1                 'count how many ctrlchars are in a row
               Else
                  GoSub textforchars                        'append last group if any
                  charcount = 1                             'start new group
               End If
         Case Else                                          'not a ctrlchar
            GoSub textforchars
            msg = msg & asciichar
         End Select
      lastchar = thischar
   Next
   GoSub textforchars                                       'may be some left
   
   FormatCtrlChars = msg
       
Exit Function

textforchars:
   If charcount Then
         msg = msg & "<" & Iff(charcount > 1, Format$(charcount) & "x", "") & Hex$(lastchar) & ">"
         charcount = 0
      End If
Return

End Function

Function GetRobotPrintLabelMessageID () As Long
   '11Nov06 PJC stub
End Function

Function LocationForMechDisp(ByVal LocationCode As String, MachineType As String) As Integer
'24Feb04 CKJ stub

   MachineType = "<UNKNOWN>"
   LocationForMechDisp = False

End Function

Sub MechDispClearLabelData ()
'20May08 CKJ

End Sub

Function MechDispEnquiry(d As DrugParameters, MachineType As String, QuantityStocked As String, strMessage As String) As Integer
'24Feb04 CKJ stub
'01Jul04 CKJ added strMessage

   MechDispEnquiry = False

End Function

Function MechDispIssue(d As DrugParameters, ByVal blnImmediatePick As Integer, ByVal QuantityToIssue As String, QuantityIssued As String, QuantityStocked As String, strMessageText As String, blnRobotLabelPrint As Integer) As Integer
'24Feb04 CKJ stub
'01JUl04 CKJ added blnImmediatePick
'17Aug05 PJC added strMessageText
'23Feb07 TH Added extra param

   MechDispIssue = False

End Function

Function MechDispIssueComplete(strMessageText As String) As Integer
'Stub
End Function

Function MechDispLabelConfirm (RobotPrintLabelMessageID As String, RobotLabelUNCpath As String, strMessage As String) As Integer
'20May08 CKJ added

   MechDispLabelConfirm = False

End Function

Function SectionIDForMechDisp(ByVal LocationCode As String) As String
'24Feb04 CKJ stub

   SectionIDForMechDisp = ""

End Function

Sub SetRobotPrintLabelMessageID (ByVal MessageID As Long)
    '11Nov06 PJC stub
End Sub

Function TerminalForMechDisp(ByVal LocationCode As String) As Integer
'24Feb04 CKJ stub
      
   TerminalForMechDisp = False

End Function

Sub HideAllIPlinkForms()
'13sep04 ckj

End Sub
