Attribute VB_Name = "PNMain"

Public Sub ProcessPN(ByRef frmPNProcess As Form)

'17Jan12 TH Based on ProcessRepeatBatch

'18May11 TH Added section to read JVM settings

Dim success As Boolean
Dim RepeatDispensingBatchID As Long
Dim RepeatDispensingXML As String
Dim strXML As String
Dim strBatchNotes As String

Dim xmldoc As MSXML2.DOMDocument
Dim XMLelement As MSXML2.IXMLDOMElement
Dim xmlnode As MSXML2.IXMLDOMElement
Dim HasRobot As Boolean
Dim PackerSection As String
Dim MachineName As String
Dim DisplayName As String
Dim strText As String
Dim lngMTSNo As Long
'Dim blnMTSNoSuccess As Boolean
Dim strFile As String
Dim strOutfile As String
Dim strFileinfo As String
Dim strPrintReport As String
Dim intReportChan As Integer
Dim strPrevFile As String
Dim intMultiplier As Integer
Dim strMsg As String
Dim strAns As String
Dim intloop As Integer
Dim strParams As String
Dim lngOK As Long
Dim blnUpdateBatch As Boolean
Dim strErrMsg As String
Dim filno As Long
Dim strRequiredDate As String
Dim strTemp As String
Dim valid As Integer
Dim blnDone As Boolean
Dim strRequiredDateShuffle As String
Dim JVMsortorder As Integer
Dim strFormat As String '23May11 TH Added (F0118397)
  ''    On Error GoTo ProcessRepeatBatchError
  
  
  
      'Work out the mode and switch it here
      
      Select Case m_PNMode
         Case "I"
               'issuing - Load in the regimen and supply request/Load in the productbvols into arrays
               PNLoadRegimen
               PNLoadProducts
               issueregimen
         Case "P"
         
         Case "C"
         
         Case "R"
      
      
      End Select
      
      
      success = True
      
      
      strXML = RepeatDispensingBatchXML
      'Debug MsgBox RepeatDispensingBatchXML
      replace strXML, "<xmlData>", "<xml>", 0
      replace strXML, "</xmlData>", "</xml>", 0
      If LCase(Left(strXML, 5)) <> "<xml>" Then             'encase raw XML in suitable tags
         strXML = "<xml>" & strXML & "</xml>"
      End If
      
      'DEBUG
      'filno = FreeFile                        'create file of 0 bytes on disk
      'Open "C:\rptdisp.txt" For Output As filno
      'Print #filno, strXML
      'Close filno
      
      RepeatDispensingBatchID = 0
      Set xmldoc = New MSXML2.DOMDocument
      xmldoc.loadXML strXML
      
      For Each XMLelement In xmldoc.selectNodes("//Batch")              'for each batch (only process first, as design is for only one)
         For Each xmlnode In XMLelement.selectNodes("ValidationError")  'handle batch errors here
            strBatchNotes = strBatchNotes & xmlnode.xml & crlf          'should never be batch errors  '** tidy for printing
            'We should only fail now for real errors
            If Val(Iff(IsNull(xmlnode.getAttribute("Exception")), "", xmlnode.getAttribute("Exception"))) = 1 Then success = False   '02Nov09 TH Added
            'success = False
         Next
         
         If success Then
            RepeatDispensingBatchID = XMLelement.getAttribute("BatchID")
            If RepeatDispensingBatchID <= 0 Then                'not a valid batch
               strBatchNotes = strBatchNotes & "Batch ID not supplied" & crlf
               success = False
            ElseIf HasRobot And UCase(MachineName) = "JVADTPS" Then '18May11 TH Added to read JVM settings
               'JVM so prefill the batch level pattern
               blnJVMBreakfast = True
               blnJVMLunch = True
               blnJVMTea = True
               blnJVMNight = True
               intJVMStartSlot = 1
               intJVMTotalSlots = 0
               If XMLelement.getAttribute("Breakfast") = "0" Then blnJVMBreakfast = False
               If XMLelement.getAttribute("Lunch") = "0" Then blnJVMLunch = False
               If XMLelement.getAttribute("Tea") = "0" Then blnJVMTea = False
               If XMLelement.getAttribute("Night") = "0" Then blnJVMNight = False
               If LCase(XMLelement.getAttribute("Breakfast")) = "false" Then blnJVMBreakfast = False  '07Jun11 TH Added after getting actual XML
               If LCase(XMLelement.getAttribute("Lunch")) = "false" Then blnJVMLunch = False          '  "
               If LCase(XMLelement.getAttribute("Tea")) = "false" Then blnJVMTea = False              '  "
               If LCase(XMLelement.getAttribute("Night")) = "false" Then blnJVMNight = False          '  "
               intJVMStartSlot = Val(XMLelement.getAttribute("StartSlot"))
               intJVMTotalSlots = Val(XMLelement.getAttribute("TotalSlots"))
               strTemp = XMLelement.getAttribute("StartDate")    'date as ccyy-mm-ddT00:00:00 only
               m_strJVMStartDate = Mid$(strTemp, 9, 2) & Mid$(strTemp, 6, 2) & Left$(strTemp, 4)   'date as ddmmccyy only
            End If
            m_RepeatDispensingBatchDescription = XMLelement.getAttribute("Description")
            m_intBagLabels = Val(XMLelement.getAttribute("BagLabels")) '30May11 TH Bag labels now batch not patient specific
         End If
         Exit For    'amend here if more than one batch needs to be supported
      Next
      
         
      If success Then   'find and process all patients in batch
         'Read the multiplier and do here - we need to do two reports at present
         intMultiplier = CInt(XMLelement.getAttribute("Factor"))
         k.escd = False '09Nov09 TH
         For intloop = 1 To intMultiplier
            If Not k.escd Then    '09Nov09 TH Added
               If RepeatDispensingAction = "I" Then
                  frmPNProcess.lblRpt.Caption = "Issuing Stock ..."
                  strFile = dispdata$ & "\RPTDISP.DAT"
                  If fileexists(strFile) Then
                     strFileinfo = FileDateTime(strFile)
                     strPrintReport = "N"
                     askwin "?Repeat Dispensing", "Before creating a new report do you want to re-print the " & cr & "previous report that was created on: " & strFileinfo, strPrintReport, k
                     If strPrintReport = "Y" Then
                        Do
                           Heap 10, gPRNheapID, "repeatdispensingdata", "[#include" & TB & strFile & "]", 0
                           If InStr(UCase$(Command$), "/HEAPDEBUG") Then Heap 100, gPRNheapID, "", "", 0
                           parseRTF dispdata$ & "\RPTDISP.RTF", strOutfile
                           Hedit 14, "RptDisp" & Chr$(0) & strOutfile
                           askwin "?Repeat Dispensing", "Previous repeat dispensing report printed" & cr & "Did the report print successfully?", strPrintReport, k
                           If k.escd Then strPrintReport = "Y"
                        Loop Until strPrintReport = "Y"
                        If k.escd Then GoTo RptErrExit      '**!! consider cleaner exit
                     End If
                     Kill dispdata$ & "\RPTDISP.DAT"
                     End If
                     strPrintReport = "Y"
                     askwin "?Repeat Dispensing", "Do you want to print a report of all the" & cr & "items issued at the end of this batch?", strPrintReport, k
                     If k.escd Then
                        popmessagecr "#Repeat Dispensing", "Issuing of stock cancelled"
                        GoTo RptErrExit
                     End If
                     If strPrintReport = "Y" Then
                        strFile = dispdata$ & "\RPTDISP.DAT"
                        intReportChan = FreeFile
                        Open strFile For Output Lock Read Write As intReportChan
                     End If
                     
               ElseIf RepeatDispensingAction = "L" Then
                  'Here we want to check that the user has set up the environment
                  strMsg = "Please check label printer is on-line and has sufficient label stock available. OK to proceed Y/N"
                  strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingLabelPrinterCheckMsg", 0)
                           
                  askwin "Repeat Dispensing", strMsg, strAns, k
                  If strAns <> "Y" Then k.escd = True
                  If k.escd Then
                     frmPNProcess.lblRpt.Caption = "Batch labelling cancelled. No labels will be printed"
                  Else
                     frmPNProcess.lblRpt.Caption = "Printing labels ..."
                     If RepeatDispensingAction = "L" And HasRobot Then
                        Select Case MachineName
                           Case "MTS"      ' Only allocate number when potentially outputting to robot, not at issue
                              GetPointerSQL patdatapath$ & "\MTSRPT.dat", lngMTSNo, True
                              SetMTSNo lngMTSNo
                           Case "JPADTPS"
                              '!!** no action yet - may not actually be needed
                           End Select
                     End If
                  End If
                  
               ElseIf RepeatDispensingAction = "S" Then '22Mar11 TH Added new medicine schedule stuff, Tayside(F0082043)
                  m_strRequiredDate = ""
                  strMsg = "OK to print medicine schedule Yes/No"
                  strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingMedSchedCheckMsg", 0)
                           
                  askwin "Repeat Dispensing", strMsg, strAns, k
                  If strAns <> "Y" Then k.escd = True
                  If k.escd Then
                  'frmPNProcess.lblRpt.Caption = "Medecine Schedule print cancelled."
                  frmPNProcess.lblRpt.Caption = "Medicine Schedule print cancelled." '23May11 TH Spell medicine properly (F0118399)
                  Else
                     'OK Now we need to get the Required Date
                     Do
                        strMsg = "Required date for Medicine Schedule"
                        strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingMedSchedDateMsg", 0)
                        strMsg = "Enter " & strMsg & " dd/mm/yyyy"
                        setinput 0, k
                        k.Max = 10
            
                        parsedate strRequiredDate, strRequiredDateShuffle, "1", valid           'dd/mm/yyyy
                        inputwin "Repeat Dispensing", strMsg, strRequiredDateShuffle, k
                        If Not k.escd Then
                           strFormat = "3"
                        parsedate strRequiredDateShuffle, strTemp, strFormat, valid
                           If strFormat = "0" Then valid = False
                           If valid Then
                              If strRequiredDate = strTemp Then blnDone = True
                              strRequiredDate = strTemp
                           Else
                              BadDate
                           End If
                        End If
                     Loop Until blnDone Or k.escd
                     
                     If Not k.escd Then
                        'Put the date on the heap - No, defer this until later
                        m_strRequiredDate = strRequiredDateShuffle
                        frmPNProcess.lblRpt.Caption = "Printing Medicine Schedule ..." '23May11 TH Spell medicine correctly(F00118398)
                     Else  '23May11 TH Added (F0118403)
                        frmPNProcess.lblRpt.Caption = "Medicine Schedule print cancelled."
                     End If
                     
                  End If
               
               ElseIf RepeatDispensingAction = "R" Then '04May11 TH Added new DORIS requirements report, Norfolk(F)
                  strMsg = "OK to print Batch Requirements Report Yes/No"
                  strMsg = TxtD(dispdata$ & "\RptDisp.ini", "", strMsg, "RepeatDispensingReportCheckMsg", 0)
                           
                  askwin "Repeat Dispensing", strMsg, strAns, k
                  If strAns <> "Y" Then k.escd = True
                  If k.escd Then
                      frmPNProcess.lblRpt.Caption = "Batch Requirements Report print cancelled."
                  Else
                      frmPNProcess.lblRpt.Caption = "Printing Batch Requirements Report ..."
                  End If
                  ReDim m_BatchReportList(0) As String ' BatchReportRec  'reset the batch report array
               End If
                  
               Screen.MousePointer = STDCURSOR
         
                 
               End If
              '09Nov09 TH Added
         Next
      Else
      
      End If
      If blnUpdateBatch Then
         On Error GoTo RepeatBatchUpdateError
         'We will need the batchID,EntityID (of us), the
         ' RepeatDispensingBatchID,gEntityID_User,RepeatDispensingAction
         strParams = gTransport.CreateInputParameterXML("BatchID", trnDataTypeint, 4, RepeatDispensingBatchID) & _
                     gTransport.CreateInputParameterXML("EntityID_User", trnDataTypeint, 7, gEntityID_User) & _
                     gTransport.CreateInputParameterXML("RepeatDispensingAction", trnDataTypeVarChar, 1, RepeatDispensingAction)
         lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pRepeatDispensingBatchUpdateAction", strParams)
      End If
      If Not success Then
         'popmessagecr "ASCribe Repeat Dispensing", "Batch Failed." & crlf & crlf & strBatchNotes
         strErrMsg = TxtD(dispdata$ & "\RptDisp.ini", "", "Problems with Batch.", "RepeatDispensingBatchFailMsg", 0)
         popmessagecr "Repeat Dispensing", strErrMsg & crlf & crlf & strBatchNotes
         frmPNProcess.lblRpt.Caption = strErrMsg
         If Trim$(strBatchNotes) <> "" Then
            'frmPNProcess.lblWarnings.Caption = strBatchNotes
            frmPNProcess.txtWarnings.Text = strBatchNotes
            frmPNProcess.fraWarnings.Visible = True
         End If
      End If
         
      '** return to inactive state, message on screen if needed
      'close db
      
ProcessRepeatBatchExit:
   On Error Resume Next
   Set xmlnode = Nothing
   Set XMLelement = Nothing
   Set xmldoc = Nothing
   On Error GoTo 0

Exit Sub

RepeatBatchUpdateError:
success = False
   strBatchNotes = strBatchNotes & ">>>>> Error: " & Err.Number & " " & "Source: RepeatBatchUpdate " & Err.Description
   frmPNProcess.lblRpt.Caption = "Repeat batch errors"
   If Trim$(strBatchNotes) <> "" Then
      'frmPNProcess.lblWarnings.Caption = strBatchNotes
      frmPNProcess.txtWarnings.Text = strBatchNotes
      frmPNProcess.fraWarnings.Visible = True
   End If
   popmessagecr "Repeat Dispensing", "Failed to update batch status" & crlf & crlf & strBatchNotes
Resume ProcessRepeatBatchExit

ProcessRepeatBatchError:
   success = False
   strBatchNotes = strBatchNotes & ">>>>> Error: " & Err.Number & " " & "Source: ProcessRepeatBatch " & Err.Description
   frmPNProcess.lblRpt.Caption = "Repeat batch errors"
   If Trim$(strBatchNotes) <> "" Then
      'frmPNProcess.lblWarnings.Caption = strBatchNotes
      frmPNProcess.txtWarnings.Text = strBatchNotes
      frmPNProcess.fraWarnings.Visible = True
   End If
   popmessagecr "Repeat Dispensing", "problem(s) have been encountered with this batch :" & crlf & crlf & strBatchNotes
Resume ProcessRepeatBatchExit

RptErrExit:
frmPNProcess.lblRpt.Caption = "Batch Processed. Error printing batch report"
'Resume ProcessRepeatBatchExit
GoTo ProcessRepeatBatchExit  '10Dec09 TH (F0071709)
End Sub

