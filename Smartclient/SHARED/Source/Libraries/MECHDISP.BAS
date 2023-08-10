Attribute VB_Name = "MechDisp"
'                    MechDisp.bas
'                    ------------
'
'24Nov03 CKJ Written. Interface to Dispensing Machinery
'            - Supports Swisslog Pack Picker
'
' Procedures named Swisslog* are specific to that interface
' All other procedures are general
' Never refer to the frmIPlink directly
' Always refer to specific instances via this module only
'
'MechDisp.ini holds settings for the mechanical dispensing equipment
'Terminal.ini holds settings for department and individual terminal
'  Robots:
'     Swisslog          - Pack Picker
'     Rowa    (ARX)     - Speedcase
'     Baxter            - Consis
'     Dematic (Siemens) - Apostore
'     JVM     (Meditec) - JVATDPS   (JV-400SL ATDPS)
'     MTS               - MTS Medication Technologies
'     RoboPharma        - RoboPharma

'A department may have more than one robot installed
'Each terminal may have the right to communicate with none, one or more of the robots
'An installed robot may be
'     disconnected - no connection attempted yet, or connection explicitly terminated
'     connected    - connection just completed or comms in progress
'     dormant      - comms recently finished and not explicitly terminated, may still be contactable
'     failed       - comms attempted but resulted in error message, may need connection closing
'
' See interface document for ini file settings and options
'
'11mar04 CKJ SwisslogRequestProduct: Moved messages to ini file
'12Mar04 CKJ SwisslogRequestProduct: Corrected boolean on Heap closure
'12May04 CKJ Rowa interface commenced
'16Jun05 CKJ Brought Swisslog i/f up to Rowa standard, for patient and ward issues
'18Aug05 CKJ Apostore interface ready for test
'24Aug05 CKJ ApostoreRequestProduct: added format(val())
'24Aug05 CKJ Baxter Consis written - testbed only at this stage
'14Sep05 CKJ Consis i/f improved - checks msg returned from a pick request, added state engine logging
'             StringExtract: written
'            MechDispIssue: Removed picking tickets from Consis - was doing stock enquiry but then showing a message because PTs are not supported
'18May06 CKJ JVM added. This machine only shares a portion of the existing code as it supports one way, batch packing only
'            It does not require an frmIPlink.
'            All previous robots are driven by the d.location of the drug in scope. JVM is different in that the robot
'            has to be known and configured before a patient or drug is in scope
'            Finding it MechDisp.ini therefore needs a different approach, MechDispPacker written
'24Jul06 CKJ Apostore extended to handle label printing. Now keeps MessageID to be used when label is written as a file.
'10Nov06 CKJ ApostoreRequestProduct: Added message to aid log analysis
'#######################################################################
'19Dec06 CKJ Ported from V8.6 to V9.7
'10Feb07 CKJ Revised to use ascribeTcpipComms. Removed IPPortV4.
'11Feb07 CKJ Note that mobjIPClient does not support setting WinsockLoaded - lines commented out but may need revision
'06Mar07 CKJ Added extra checks for object creation
'12mar07 CKJ Added trap for error 406: Can't show-non modal form from VB OCX, hosted in non-VB parent, after connecting to COM+, except in IDE. (SC-07-0157)
'25Jan08 CKJ Added MTS. Most code for MTS resides in RPTDISP form & module (20May08 CKJ Ported from V8.8)
'20May08 CKJ Corrected use of intSuccess in heap handling (all robots) - now set to false, search on '20May08 CKJ was intSuccess'  (F0021830)
'            Added option RowaDisconnectDelay to delay closing Rowa connection. Default is 2 ticks (up to 110 msec) (F0023793)
'            Added option EnableRowaLocking, default True. Rowa labeller allows concurrent connections so locking is not needed (F0017010)
'            Changed lock file from dispdata.xxx\Rowa to dispdata.xxx\Rowa.Lck
'            Rowa Label Printing added (F0017010)
'16Dec09 CKJ RoboPharma: commenced interface
'07Jan10 CKJ RoboPharma: internal testing suggests that the robot may not accept simultaneaous connections
'20Jan10 CKJ RoboPharma: added lock mechanism similar to the Rowa i/f, using dispdata.xxx\RoboPhma.Lck
'29Jan10 CKJ RoboPharmaRequestProduct: corrected locking during internal testing  (Merged 24Mar10 CKJ)
'24Mar10 CKJ Robopharma does not now send status 03/04/05 messages, but stops at the 01 acknowledgement
'            - modified to reflect this, retries reduced and link file corrected
'            Note that Robopharma locking should not be necessary, as RoboConnect now accepts multiple connections   (RCN P0007 F0067753)
'03Jun10 CKJ SectionIDforMechDisp: Moved Exit For inside the IF to allow second & subsequent robot sections to be used    (RCN P0158 F0083830)
'            ApostoreRequestProduct: Added stores & label description, to avoid use of global d struct in enquiry message (RCN P0158 F0088211)
'22Jul10 CKJ MechDispIssue: 5 char ward codes - Consis needs fixed length ward code. RCN P00158 F0092472 (fix to F0051906)
'07Sep10 CKJ Consis problem with scoping of d.barcode on stock enquiry from Findrdrug screen (RCN P0158 F0096016)
'            For clarity, changed d. to dLocal. in areas which do not share the d structure. Nothing here now uses d.____ variables
'24Jul12 CKJ MechDispSendProductData, MechDispSendProductDataSupported, HL7safe: written
'            RowaRequestProduct: Added ZDI product information message                               TFS37640
'18Feb17 TH  MechDispLog: Converted to use Database instead of Log file
'            Use the settings for logging - but not the logfile - the log file name will now
'            be general mechdisp as all the logfile name/path differentiation should be available
'            from SQL for ease of investigation (TFS 177654)
'20Feb17 TH  RoboPharmaRequestProduct: RowaRequestProduct: Replaced use of locking details file so we can use the message as per the old files (TFS 177820)
'05Jun17 TH  PostMechDispLog: Written (TFS 185185)
'05Jun17 TH  MechDispLog: Now log locally during coms and then upload to DB after connection closes (TFS 185185)
'05Jun17 TH  ApostoreTerminate: ConsisComms: ConsisInitiateComms: ConsisTerminate: MechDispEnquiry: MechDispIssue:
'            RowaRequestProduct: RowaTerminate: Post logs to DB(TFS 185185)
'05Jun17 TH  Removed locking info file write - dont use files
'05Jun17 TH  WriteRowaLink: WriteRobopharmaLink: Removed - we must not write to fileshares anymore ! (TFS 185851)


'Mods Required
'-------------
' Swisslog Comms failure -> stock level zero instead of msg
'     Shows "no stock in Swisslog" instead of "Error inserting into database" etc
'  Separate display name from internal robot name
'  Menu option to re-display the hidden form
' Rowa/Apostore/Consis - enable max issue options

'-----------------------------------------------------------------------
                                 
Option Explicit
DefInt A-Z

Const MechDispIni = "\MechDisp.ini"
Const IPclientMissingMsg = "Missing component 'AscribeTcpipComms.exe' needs to be installed and registered on this terminal" & vbCrLf
Const ROWALCK = "\ROWA.LCK"                  '20May08 CKJ Replaces "\Rowa"
Const ROBOPHARMALCK = "\RoboPhma.LCK"        '20Jan10 CKJ

'Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Dim m_hWndParent As Integer
Dim m_lngRobotPrintLabelMessageID As Long    '24Jul06 CKJ Added
Dim m_RobotPrintLabelSection As String       '20May08 CKJ Added

Dim Swisslog As frmIPlink       '            PackPicker from Swisslog
Dim ROWA As frmIPlink           '12may04 CKJ ROWA Speedcase from ARX
Dim Apostore As frmIPlink       '09Aug05 CKJ Apostore from Siemens Dematic
Dim Consis As frmIPlink         '   "        Consis from Baxter
Dim RoboPharma As frmIPlink     '16Dec09 CKJ

Dim m_blnEnableRowaLocking As Integer        '20May08 CKJ
Dim m_blnEnableRoboPharmaLocking As Integer  '20Jan10 CKJ

Dim m_strLoggingfile As String   '05Jun17 TH Store for logging caching (TFS 185185)
Dim m_strInterface As String     '  "
'

'20May08 CKJ Removed unused test proc
'Sub JVMParseLine (ByVal JVMheapID As Integer, DoseDateTime As DateAndTime)
''23jun06 CKJ Uses global patient, label & drug in scope
'
'Dim inifile As String
'Dim inisection As String
'Dim strVal As String
'
'   inifile = dispdata$ & MechDispIni
'   inisection = Format$(MechDispPackerSection("", ""))
'   '$$ check section valid
'
'   'MessageOut="[JVMpatientname][JVMlocation][pCaseno]  [iNSVcode][JVMfractioncode]   [JVMscript][JVMDoseDateTime]  [JVMqty][JVMDay][cr][lf]"
'
'   Heap 10, JVMheapID, "JVMfractioncode", "X", 0
'   'Heap 10, JVMheapID, "JVMscript", "", 0
'   Heap 10, JVMheapID, "JVMDoseDateTime", "2306062200", 0
'   Heap 10, JVMheapID, "JVMqty", "2", 0
'   Heap 10, JVMheapID, "JVMDay", "Monday", 0
'
'   PadHeapField JVMheapID, inifile, inisection, "JVMfractioncode"
'   PadHeapField JVMheapID, inifile, inisection, "JVMscript"
'   PadHeapField JVMheapID, inifile, inisection, "JVMDoseDateTime"
'   PadHeapField JVMheapID, inifile, inisection, "JVMqty"
'   PadHeapField JVMheapID, inifile, inisection, "JVMDay"
'
'End Sub

Private Function ApostoreInitialise(ByVal ForceReset As Integer) As Integer
'09Aug05 CKJ written
'            If ForceReset=True then an existing link will be broken & reinitialised
'            otherwise an exiting link is simply used.

Dim dummy As Integer

   If ForceReset And Not Apostore Is Nothing Then
         dummy = ApostoreTerminate()
      End If
   
   If Apostore Is Nothing Then
         Set Apostore = New frmIPlink
         Load Apostore
         Apostore.Caption = "Apostore Interface"
      End If

   ApostoreInitialise = True

End Function

'Private Function ApostoreRequestProduct(ByVal SectionID As String, ByVal strMessageType As String, ByVal Identifier1 As String, ByVal Identifier2 As String, ByVal ProductID As String, ByVal QuantityToIssue As String, QuantityIssued As String, QuantityStocked As String, strMessageText As String, intRobotPrint As Integer, ByVal storesdescription As String, ByVal LabelDescription As String) As Integer   XN 4Jun15 98073 New local stores description
Private Function ApostoreRequestProduct(ByVal SectionID As String, ByVal strMessageType As String, ByVal Identifier1 As String, ByVal Identifier2 As String, ByVal ProductID As String, ByVal QuantityToIssue As String, QuantityIssued As String, QuantityStocked As String, strMessageText As String, intRobotPrint As Integer, ByVal Description As String) As Integer
'09Aug05 CKJ Siemens Apostore handler

'Given a number of whole packs to issue (must not be negative) and a barcode,
'contact Apostore, send message if possible, and return details of product or failure code
'SectionID is the MechDisp.ini section for the product requested
'                                                                  -----------Success------------ -----------Failure------------
' strMessageType Identifier1 Identifier2 ProductID QuantityToIssue QuantityIssued QuantityStocked QuantityIssued QuantityStocked   Implemented
'  Enquiry          blank      blank      EAN13       ignored       ""             n               unchanged      unchanged          Yes
'  Patient          ward       blank      EAN13       n             n              decremented     unchanged      unchanged          Yes
'  Ward             ward      picktickno  EAN13       n             n              decremented     unchanged      unchanged          Yes
'  Final            ward      picktickno  zeroes      0             ""             unchanged       unchanged      unchanged          Yes
'
'All quantities are positive integers.
'
'return value is success T/F
'
'MSA|AA|00087464|                    |||'           patient issue or stock issue, no message=success
'MSA|AA|00087464|00123               |||'           single item enquiry, qty in stock shown
'
'24Aug05 CKJ added format(val())
'24Jul06 CKJ added print check. New ZRR message item is available [PrintLabel] = 0 or 1
'            intRobotPrint is returned, false unless specifically set by robot
'10Nov06 CKJ Added message to aid log analysis
'03Jun10 CKJ Added stores & label description, to avoid use of global d struct in enquiry message  (RCN P0158 F0088211)

Dim strMessage As String
Dim strReply As String
Dim RobotHeap As Integer
Dim intSuccess As Integer
Dim dummy As Integer
Dim Numoflines As Integer
Dim intloop As Integer
Dim strReplyText As String
Dim strTemp As String
Dim iniFile As String
Dim strQtyIssued As String
Dim strQtyStocked As String
Dim strReplyMID As String
Dim MessageID As Long
Dim blnBusy As Integer
Dim strReplyType As String
Dim strReplyStatus As String
Dim strText As String
Dim numofsubfields As Integer
Dim strStatus As String
Dim WillRobotPrint As Integer
Dim ApostoreDatPath As String
Dim AllowRepeatForLowMessageID As Integer
Dim RepeatForLowMessageID As Integer

   intSuccess = False
   MessageID = 0
   iniFile = dispdata$ & MechDispIni
   strMessageText = ""
   WillRobotPrint = intRobotPrint                                                   '24Jul06 CKJ added printing
   intRobotPrint = False                                                            '   "        assume it won't
   SetRobotPrintLabelMessageID 0                                                    '   "
   ApostoreDatPath = TxtD(iniFile, SectionID, dispdata$, "ApostoreDatPath", False)  '06Oct06 CKJ added
   AllowRepeatForLowMessageID = TrueFalse(TxtD(iniFile, SectionID, "N", "AllowRepeatForLowMessageID", False))

   If Not blnBusy Then
         blnBusy = True

         strTemp = terminal("ApostoreTerminalName", "<INVALID>")           'Not currently sent to Apostore, but needed to show Terminal is robot enabled
         strMessage = "[MSG" & strMessageType & "]"                        'MessageType = Patient, Ward, Enquiry
         ParseCtrlChars iniFile, SectionID, strMessage, 0
      
         If strTemp = "<INVALID>" Then
               'no action: not a Apostore enabled terminal
      
            ElseIf strMessage = "[MSG" & strMessageType & "]" Then
               strMessageText = "Unsupported message type: " & strMessageType
               MechDispLog SectionID, "E", strMessageText
            
            ElseIf Len(ProductID) = 0 And strMessageType <> "Final" Then   '17Aug05 CKJ Added check for final picking ticket msg
               'no action: no barcode provided
            
            ElseIf Val(SectionID) = 0 Then
               strMessageText = "Invalid SectionID: " & SectionID
               MechDispLog SectionID, "E", strMessageText
      
            Else
               Select Case strMessageType                                  'Trap issue qty outside range 001 to 999
                  Case "Patient", "Ward"                                   'Immediate or deferred issue request, needs a valid issue quantity
                     Select Case Val(QuantityToIssue)
                        Case Is < 1, Is > 999
                           strMessageText = "Invalid Issue Quantity (1-999): " & QuantityToIssue
                           MechDispLog SectionID, "E", strMessageText
                        End Select
                  End Select
               
               If strMessageText = "" Then
                     Heap 1, RobotHeap, "Apostore Data Heap", "", intSuccess
                     If Not intSuccess Then strMessageText = "Failed to allocate data heap for Apostore"
                  End If
            End If
            
         If intSuccess Then
               GetPointerSQL ApostoreDatPath & "\Apostore.dat", MessageID, True                    'only get number once lock is granted
               Select Case MessageID
                  Case Is < 1, Is > 99999999                                                    '8 digits only
                     GetPointerSQL ApostoreDatPath & "\Apostore.dat", 1, 2
                     MessageID = 1
                  End Select
      
               Heap 10, RobotHeap, "yyyymmddNow", Format$(Now, "yyyymmdd"), 0
               Heap 10, RobotHeap, "hhnnssNow", Format$(Now, "hhnnss"), 0
               Heap 10, RobotHeap, "MessageID", Format$(MessageID, "00000000"), 0
               Heap 10, RobotHeap, "IssueQty", Format$(QuantityToIssue, "000"), 0
               Heap 10, RobotHeap, "EANcode", ProductID, 0
              'Heap 10, RobotHeap, "TerminalName", strTemp, 0
               Heap 10, RobotHeap, "ChuteID", pad(terminal("ApostoreChuteID", "  "), 2), 0      'must be 2 chars
              'Heap 10, RobotHeap, "UserID", UserID$, 0
               Heap 10, RobotHeap, "ToName", pad(Identifier1, 5), 0                             'ward
               Heap 10, RobotHeap, "ToCode", pad(Identifier2, 4), 0                             'blank  / picking picket
               Heap 10, RobotHeap, "PrintLabel", Iff(WillRobotPrint, "1", "0"), 0               '24jul06 ckj added

               '03Jun10 CKJ d may not be in scope here - need to use local copy (RCN P0158 F0088211)
               'strTemp = Trim$(d.StoresDescription)                                             '** uses global drug ** Stock Enquiry only, and d.barcode is already necessary
               'If Len(strTemp) = 0 Then
               '      strTemp = Trim$(d.Description)                                             'no stores description
               '   End If
               'strTemp = Trim$(storesdescription)
               'If Len(strTemp) = 0 Then strTemp = Trim$(LabelDescription)  XN 4Jun15 98073 New local stores description
               strTemp = Trim$(d.DrugDescription)
                           
               replace strTemp, "|", "", 0                                         'remove as this is an HL7 separator
               replace strTemp, "!", " ", 0
               Heap 10, RobotHeap, "iDescription", pad(strTemp, 56), 0             'product description

               ParseItems RobotHeap, strMessage, False
               
               LastReply True, ""                                                  '22Aug05 CKJ Added
               intSuccess = ApostoreSendMessage(SectionID, strMessage)             'Actually send the message (Loads the IPlink form if not already present)
               
               If intSuccess Then
                     Do
                        intSuccess = False
                        RepeatForLowMessageID = False                              '20May08 CKJ
                        Apostore.lblMessage.Caption = TxtD(iniFile, SectionID, "  Waiting for reply from Apostore... ", "WaitingReplyMsg", False)
                        'LastReply True, ""                                           '22Aug05 CKJ moved above
                        dummy = ApostoreShow(True)                                    'modal show while waiting for reply
                        '...stay as modal form until reply received or user Cancels...
                        LastReply False, strReply
                        LastReply True, ""                                            '22Aug05 CKJ Added
   
                        If Len(strReply) Then
                              dummy = ApostoreShow(False)                             'non modal show
                              Apostore.lblMessage.Caption = Chr$(12)                  'clear window
                              
                              'dismantle reply
                              replace strReply, Chr$(&HB), "<B>", 0
                              replace strReply, Chr$(&HD), "<D>", 0
                              replace strReply, Chr$(&H1C), "|", 0
                              ReDim lines(50) As String
                              deflines strReply, lines$(), "|(*)", 1, Numoflines
                              
                              strReplyText = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyText", False)))
                              strQtyIssued = ""                       'lines$(Val(txtd(inifile, SectionID, "", "ReplyQuantityIssued", False)))
                              strQtyStocked = QuantityStocked         'lines$(Val(txtd(inifile, SectionID, "", "ReplyQuantityStocked", False)))
                              strReplyMID = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyMessageID", False)))
                              Heap 10, RobotHeap, "ReceivedText", RTrim$(strReplyText), False      '20May08 CKJ was intSuccess
                              Heap 10, RobotHeap, "ReceivedMessageID", strReplyMID, False      '20May08 CKJ was intSuccess
                              Heap 10, RobotHeap, "CR", crlf, False      '20May08 CKJ was intSuccess
                              
                              strReplyType = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyType", False)))       '<B>MSA
                              strReplyStatus = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyStatus", False)))   'AA/AR
                              Heap 10, RobotHeap, "ReplyType", strReplyType, False      '20May08 CKJ was intSuccess
                              Heap 10, RobotHeap, "ReplyStatus", strReplyStatus, False      '20May08 CKJ was intSuccess
                              
                              If InStr(strReply, TxtD(iniFile, SectionID, "", "ReplyPreamble", False)) <> 1 Then    'invalid reply
                                    strText = "[InvalidMsg]"                                       '" Reply is not a valid message"
                                 
                                 ElseIf CDbl(strReplyMID) <> MessageID Then
                                    strText = "[IncorrectIDMsg]"                                   '" Reply is not for this message[cr] - Message ID expected is [MessageID][cr] - Message ID in reply is [ReceivedMessageID]"
                                    If AllowRepeatForLowMessageID Then
                                       If CDbl(strReplyMID) < MessageID Then
                                          RepeatForLowMessageID = True
                                          strText = "[IncorrectIDMsgRetry]"
                                       End If
                                    End If

                                 Else   'looks OK to parse
                                    Select Case strReplyType
                                       Case "<D>MSA"    'Message Acknowledgement
                                          strMessageText = RTrim$(strReplyText)
   
                                          Select Case strReplyStatus
                                             Case "AA"  'Order sent to robot                                      MSA AA OK Free dispensing
                                                Select Case strMessageType
                                                   Case "Patient", "Ward"                                        'Immediate or deferred issue request
                                                      strQtyIssued = QuantityToIssue                             'inferred because it was accepted for issue
                                                      Heap 10, RobotHeap, "QtyIssued", strQtyIssued, False
                                                      strQtyStocked = Format$(Val(strQtyStocked) - Val(strQtyIssued))  'also inferred, and assumes qtystocked was set before calling
                                                      Heap 10, RobotHeap, "QtyStocked", strQtyStocked, False      '20May08 CKJ was intSuccess
                                                      strText = "[IssuedMsg]"
                                                      Select Case Left$(strReplyText, 1)
                                                         Case "0"
                                                            strMessageText = RTrim$(Mid$(strReplyText, 2))       'should be blank
                                                         Case "1"                       '24Jul06 CKJ added printing
                                                            strMessageText = RTrim$(Mid$(strReplyText, 2))       'should be blank
                                                            SetRobotPrintLabelMessageID MessageID
                                                            intRobotPrint = True
                                                         End Select
                                                      intSuccess = True
   
                                                   Case "Enquiry"                                                'Reply to stock level request
                                                      If IsDigits(Left$(strReplyText, 5)) Then
                                                            strQtyStocked = Format$(Val(Left$(strReplyText, 5))) '00018 => 18     '24Aug05 CKJ added format(val())
                                                            strText = "[StockedMsg]"
                                                            strMessageText = RTrim$(Mid$(strReplyText, 6))       'should be blank
                                                            intSuccess = True
                                                         Else
                                                            strText = "[InvalidSLMsg]"                           'not five digits, success stays false
                                                         End If
                                                      Heap 10, RobotHeap, "QtyStocked", strQtyStocked, False      '20May08 CKJ was intSuccess
   
                                                   Case "Final"                                                  'Reply to end of picking ticket notification
                                                      If RTrim$(strReplyText) = "0" Then strMessageText = ""
                                                      intSuccess = True
   
                                                   End Select
   
                                             Case "AR"  'Rejected  -  due to incorrect barcode
                                                'no action: success is already false and the message, if any, is in the heap
   
   
                                            ' Case       'Quantity asked > Quantity in stock                      Not supported in current Siemens robots
                                            '    strQtyIssued = "0"
                                            '    strQtyStocked = strReplyText
                                            '    Heap 10, RobotHeap, "QtyIssued", strQtyIssued, intSuccess
                                            '    Heap 10, RobotHeap, "QtyStocked", strQtyStocked, intSuccess
                                            '    strText = "[InsufficientMsg]"
                                             
                                             Case Else       'unknown message type within acknowledgement
                                                strText = "[InvalidReplyStatusMsg]"
                                             End Select
                                          
                                          If Not intSuccess And Len(strText) = 0 Then
                                                strText = "[RejectedMsg]"                                      '" Request Rejected: [cr] - [ReceivedText]"
                                             End If
   
                                       Case Else             'unknown reply type - not an acknowledgement
                                          strText = "[InvalidReplyMsg]"
                                       End Select
                                             
                                    QuantityIssued = Trim$(strQtyIssued)
                                    QuantityStocked = strQtyStocked
                                 End If
   
                              ParseCtrlChars iniFile, SectionID, strText, False
                              ParseItems RobotHeap, strText, False
                              Apostore.lblMessage.Caption = strText
   
                           Else         'user cancelled
                              'no action, return failure code
                              Apostore.lblStatus.Caption = "Cancelled by User"    '10Nov06 CKJ Added message to aid log analysis
                           End If
                     Loop While RepeatForLowMessageID                   '10oct06 CKJ Allow another message to be read
                  Else
                     'no action, return failure code
                     strMessageText = "Apostore not responding"
                  End If

               Heap 2, RobotHeap, "", "", False
                  
            Else
               'messages already set above
            End If
         
         blnBusy = False
      End If
   '07Jun17 TH If we have any log msgs then write here
   PostMechDispLog
   ApostoreRequestProduct = intSuccess

End Function

Private Function ApostoreSendMessage(ByVal SectionID As String, ByVal strMessage As String) As Integer
'09Aug05 CKJ
'Never call this directly - only call via ApostoreRequestProduct
'otherwise the busy flag would be bypassed
'16oct06 CKJ Copied Swisslog traps for immediate reuse of failed connection
'            Extended to cover error 20105
'            Changed DoEvents to DoSaferEvents
'06Mar07 CKJ Added extra checks

Dim success As Integer
Dim AfterNSeconds As Variant
Dim iniFile As String
Dim RemoteHost As String
Dim RemotePort As String

   success = False

   ApostoreSendMessage = False

   If strMessage <> "" And Val(SectionID) > 0 Then
      success = ApostoreShow(False)
      
      '06Mar07 CKJ Added extra checks
      If Not success Then
         popmessagecr ".", "Apostore Interface could not be started"
         
      ElseIf Apostore.mobjIPClient Is Nothing Then
         Apostore.lblStatus.Caption = IPclientMissingMsg
         Apostore.lblMessage.Caption = IPclientMissingMsg
         
      Else
         iniFile = dispdata$ & MechDispIni
      
         Apostore.lblMessage.Caption = Chr$(12)
         If Not Apostore.mobjIPClient.WinsockLoaded Then
   '11feb07            Apostore.mobjIPClient.WinsockLoaded = True
            End If
         
         Apostore.mobjIPClient.EOL = Chr$(&H1C) & Chr$(&HD)
         
         'close old connections (if any)
         '!!** should not be needed in current implementation
         '     may be needed if multiple connections to several machines
         
         If success Then                                    'attempt connection
            If Not Apostore.mobjIPClient.Connected Then
               Apostore.Tag = SectionID
               RemoteHost = TxtD(iniFile, SectionID, "127.0.0.1", "IPaddress", False)           '16oct06 CKJ avoids immediate reuse after failed connection (see Swisslog)
               If Apostore.mobjIPClient.RemoteHost <> RemoteHost Then
                  Apostore.mobjIPClient.RemoteHost = RemoteHost
               End If
               RemotePort = TxtD(iniFile, SectionID, "0", "IPport" & ASCTerminalName$(), False) '   "     "
               If Apostore.mobjIPClient.RemotePort <> RemotePort Then
                  Apostore.mobjIPClient.RemotePort = RemotePort
               End If
               If Apostore.mobjIPClient.RemotePort = 0 Then
                  Apostore.lblStatus.Caption = "IP port must be configured for terminal " & ASCTerminalName$()
               Else
                  Apostore.lblMessage.Caption = TxtD(iniFile, SectionID, "  Waiting for connection to Apostore... ", "WaitingConnectionMsg", False)
                  Apostore.lblStatus.Caption = "Connecting to " & Apostore.mobjIPClient.RemoteHost & " port " & Apostore.mobjIPClient.RemotePort & " ..."
                  '16oct06 CKJ Connection may be closing, returns .Connected=False but won't accept new connection yet (Err 20105)
                  Screen.MousePointer = HOURGLASS
                  Do
                     On Error Resume Next
                     Apostore.mobjIPClient.Connected = True
                     If Err = 20105 Then DoSaferEvents 1
                  Loop While Err = 20105
                  On Error GoTo 0
                  Screen.MousePointer = STDCURSOR
               End If
            End If
            
            If Apostore.mobjIPClient.RemotePort > 0 Then
               'wait until the connection is achieved (timeout in 10 seconds)
               AfterNSeconds = Now + CDbl(TxtD(iniFile, SectionID, "10", "timeout", False)) / (3600# * 24#)
               Do Until Now > AfterNSeconds
                  If Apostore.mobjIPClient.Connected Then Exit Do
                  DoSaferEvents 1                               '16oct06 CKJ was DoEvents, but this allowed main prog to continue
               Loop
            End If
            
            Apostore.lblMessage.Caption = Chr$(12)
            If Not Apostore.mobjIPClient.Connected Then
               Apostore.lblMessage.Caption = TxtD(iniFile, SectionID, "  Apostore is not available.", "NotAvailableMsg", False)
               Apostore.lblStatus.Caption = "Connection timed out."
            Else
               Apostore.lblStatus.Caption = "Send: " & FormatCtrlChars(strMessage)
                           
               'send the data
               Apostore.mobjIPClient.DataToSend = strMessage
               ApostoreSendMessage = True
            End If
         End If
      End If
   End If

End Function

Private Function ApostoreShow(ByVal SetModal As Integer) As Integer
'09Aug05 CKJ
'If the form is not loaded, then load and show
'If the form is loaded, then hide if necessary and show
'If already loaded and on show with the correct modality, do nothing
'SetModal = -1 True                          modal
'            0 False (or any other integer)  nonmodal
'            1                               don't change mode if set, use non modal if not set

Dim IsModal As Integer
Dim dummy As Integer
Dim blnHide As Integer

   ApostoreShow = False
   IsModal = (SetModal = True)                   'only set modal if specifically requested
   If Apostore Is Nothing Then
         dummy = ApostoreInitialise(False)
         IsModal = True
         Apostore.cmdCancel.Visible = IsModal
         Apostore.Timer1.Enabled = True
      End If
   
   If Not Apostore Is Nothing Then
         If Apostore.Visible Then
               If SetModal = 1 Then IsModal = (Apostore.cmdCancel.Tag = "-1")         'set modal based on existing form
               blnHide = False
               If Apostore.cmdCancel.Tag = "-1" And Not IsModal Then blnHide = True   'Modal wanted, not modal now
               If Apostore.cmdCancel.Tag = "0" And IsModal Then blnHide = True        'Non modal wanted, modal now ** should not be necessary of course
               If Apostore.cmdCancel.Tag = "0" And Not IsModal Then blnHide = True    'Non modal wanted, non modal now BUT might need to auto hide -2 because of existing modal form
               If blnHide Then
                     IPlinkHide Apostore         'hide first to change modality
                  End If
            End If
         
         ApostoreShow = True
         If Not Apostore.Visible Then
               Apostore.cmdCancel.Visible = IsModal
               Apostore.cmdCancel.Tag = Format$(IsModal)
               On Error GoTo ApostoreShow_Err
               Apostore.Show Iff(IsModal, 1, 0), OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form          'Show
            End If
      End If

Exit Function

ApostoreShow_Err:
   Select Case Err
      'Can't display non-modal form when modal form showing
      '12mar07 CKJ Added: Non-modal forms cannot be displayed in this host application from an ActiveX DLL, ActiveX Control, or Property Page. (406)
      Case 401, 406
         IPlinkHide Apostore
         IsModal = True
         Apostore.cmdCancel.Visible = IsModal
         Apostore.cmdCancel.Tag = "-1"
         IPlinkResize Apostore
         Apostore.Timer1.Enabled = True                  'show modally then hide immediately
         Resume

      Case Else
         popmessagecr ".", "Procedure ApostoreShow Error:" & crlf & Error & " (" & Format$(Err) & ")"
         Resume Next

      End Select

Resume Next
      
End Function

Private Function ApostoreTerminate() As Integer
'09Aug05 CKJ Cancel any current connection, close the IP port and close the form

Dim dummy As Integer

   If Not Apostore Is Nothing Then
         dummy = IPlinkCloseConnection(Apostore)

         Unload Apostore                                                         'this closes current connection if any
         Set Apostore = Nothing
         '05Jun17 TH Post logs (TFS 185185)
         PostMechDispLog
      End If

   ApostoreTerminate = True                                                      'may return error indication

End Function

Private Function ConsisComms(ByVal SectionID As String, ByVal RobotHeap As Integer, ByVal strMessageType As String, ByVal strReplyType As String, strReply As String, strMessageText As String) As Integer
'23Aug05 CKJ Written. Partner function to ConsisInitiateComms
'            Use this to handle a specific message types; A (stock issue) and B (stock enquiry)
'            Do not call until ConsisInitiateComms returns success=true
'
'                      Ascribe                                Consis
'            1         A...                ==>
'            2                            <==                 <Ack>
'            3                            <==                 a...
'            4         <Ack>               ==>
'
' Parameters In:
'            SectionID        standard for this module
'            RobotHeap           "
'            strMessagetype   Consis message type to send,  eg 'A' 'B' etc, ready for parsing as [MSGA] [MSGB] etc
'            strReplyType     Consis message type expected, eg 'a' 'b' etc
' Parameters Out:
'            strReply         received message if any (not including any ACK)
'            strMessageText   displayable text if relevant, not currently used - always returns empty string
' Returns:   True/False       success
'
'            States are numbered such that they can be distinguished from the ConsisInitiateComms states where relevant
'               0         base state
'               1  - 9    CIM/CIA
'               101- 909  CIM/CIA errors
'              11  -19    R/r
'              1101-1909  R/r errors
'              20         connect via states 1-19
'              21  -29    specific msg
'              2101-2909  specific msg errors
'             999         restart interface
'              -2         quit with fail
'              -1         quit with success
'
'14Sep05 CKJ Added logging

Dim success As Integer
Dim State As Integer
         
Dim strMessage As String
Dim intSuccess As Integer
Dim dummy As Integer
Dim iniFile As String
Dim retries As Integer
Dim restarts As Integer
Dim ACKchar As String
Dim NAKchar As String

   success = False
   State = 0               'not tried yet, unknown state
   retries = 0
   
   iniFile = dispdata$ & MechDispIni
   strMessageText = ""
   ACKchar = Chr$(6)
   NAKchar = Chr$(15)

   Do
      MechDispLog SectionID, "D", "State : " & Format$(State)

      Select Case State
         Case 0            'base state, lets try to send
            If restarts <= 3 And retries < 10 Then      'limit number of times it will restart the link or resend a packet  !!** make configurable
                  restarts = restarts + 1
                  retries = retries + 1
                  State = 20       'start link
               Else
                  MechDispLog SectionID, "E", "State -2: Quitting after " & Format$(retries) & " retries and " & Format$(restarts) & " restarts"
                  State = -2       'give up and exit with failure
               End If

         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Connect ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 20        'connect and exchange preamble
            If ConsisInitiateComms(SectionID, RobotHeap, strMessageText) Then    'success
                  LastReply 2, strReply         'there should be nothing up the spout now
                  If Len(strReply) Then
                        State = 2001
                     Else
                        State = 21        'try the msg
                     End If
               Else
                  State = -2        'plenty of retries inside ConsisInitiateComms so just exit here
               End If
                    
         Case 2001
            MechDispLog SectionID, "E", "State 2001: Buffer not empty after connection opened: " & FormatCtrlChars(strReply)
            State = 999             'restart interface

         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MSG/msg ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 21                  'ready to send the msg
            strMessage = "[MSG" & strMessageType & "]"
            ParseCtrlChars iniFile, SectionID, strMessage, 0
            ParseItems RobotHeap, strMessage, False
            LastReply True, ""
            
            If ConsisSendMessage(SectionID, strMessage, "") Then         'Actually send the message
                  State = 22      'successful send
               Else
                  State = 2101    'send failed
               End If
      
         Case 22                  'sent msg, what's the reply?
            Consis.lblMessage.Caption = Chr$(12)
            Consis.lblMessage.Caption = "  Waiting for <ACK> from Consis... (22)"
            dummy = ConsisShow(True)                                      'modal show while waiting for reply
            '...stay as modal form until reply received or user Cancels...
            LastReply 2, strReply

            If Len(strReply) Then   'something arrived
                  Select Case Left$(strReply, 1)
                     Case ACKchar
                        If Len(strReply) = 1 Then
                              State = 23          'wait for msg reply
                           Else
                              strReply = Mid$(strReply, 2)     'probably got it already in this message
                              State = 24
                           End If
   
                     Case NAKchar
                        State = 2201              'we should resend last message (counts as a retry)
   
                     Case Else
                        State = 2202              'unexpected reply
   
                     End Select
               Else
                  State = 2203           'no reply: timed out or user got bored waiting
               End If

         Case 23                     'wait for msg reply
            Consis.lblMessage.Caption = Chr$(12)
            Consis.lblMessage.Caption = "  Waiting for reply from Consis... (23)"
            dummy = ConsisShow(True)                                      'modal show while waiting for reply
            '...stay as modal form until reply received or user Cancels...
            LastReply 2, strReply
            
            If Len(strReply) Then    'something arrived
                  State = 24
               Else
                  State = 2301       'no reply: timed out or user got bored waiting
               End If
         
         Case 24                     'got a reply, now send Ack
            strMessageType = "ACK"
            strMessage = "[MSG" & strMessageType & "]"
            ParseCtrlChars iniFile, SectionID, strMessage, 0
            ParseItems RobotHeap, strMessage, False
            LastReply True, ""
            
            If ConsisSendMessage(SectionID, strMessage, "") Then         'Actually send the message
                  State = 25                            'details logged so don't parse
               Else
                  State = 2401    'send ACK failed
               End If

         Case 25                     'parse reply after getting ACK
            If Left$(strReply, 1) = strReplyType Then            'correct preamble          '!!** not strictly necessary - could exit here & parse outside
                  State = -1      'successful send, return to calling routine   <== DONE
               Else
                  State = 2501
               End If

         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MSG/msg Errors ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 2101
            MechDispLog SectionID, "E", "State 2101: send " & strMessageType & " failed"
            State = 999             'restart interface
         
         Case 2201
            MechDispLog SectionID, "E", "State 2201: NAK received after sending " & strMessageType
            retries = retries + 1
            State = 2               'send it again
         
         Case 2202
            MechDispLog SectionID, "E", "State 2202: unexpected reply when waiting for ACK: " & FormatCtrlChars(strReply)
            State = 999             'restart interface   '!!** may have to Ack then start again?
         
         Case 2203
            MechDispLog SectionID, "E", "State 2203: no reply when waiting for ACK"
            State = 999             'restart interface

         Case 2301
            MechDispLog SectionID, "E", "State 2301: no reply when waiting for " & strReplyType
            State = 999             'restart interface

         Case 2401
            MechDispLog SectionID, "E", "State 2401: send ACK failed"
            State = 999             'restart interface

         Case 2501
            MechDispLog SectionID, "E", "State 2501: Incorrect reply to " & strMessageType & ": " & FormatCtrlChars(strReply)
            State = -2             'quit with failure
                                                              

         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Restart ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 999                   'turned pear shaped, close IP port & restart from beginning
            If Not Consis Is Nothing Then
                  dummy = IPlinkCloseConnection(Consis)
                  '05Jun17 TH Post logs (TFS 185185)
                  PostMechDispLog
               End If
            State = 0               'start again

         Case -2                    '-2 quit with fail
            Exit Do

         Case -1                    '-1 quit with success
            Exit Do

         Case Else
            MechDispLog SectionID, "E", "State " & Format$(State) & ": This state has not been programmed: Quitting"
            State = -2                                                          '<== DONE
            
         End Select
   Loop

   ConsisComms = (State = -1)                 'success only if state = -1

End Function

Private Function ConsisInitialise(ByVal ForceReset As Integer) As Integer
'12Aug05 CKJ written
'            If ForceReset=True then an existing link will be broken & reinitialised
'            otherwise an existing link is simply used.

Dim dummy As Integer

   If ForceReset And Not Consis Is Nothing Then
         dummy = ConsisTerminate()
      End If
   
   If Consis Is Nothing Then
         Set Consis = New frmIPlink
         Load Consis
         Consis.Caption = "Consis Interface"
      End If

   ConsisInitialise = True

End Function

Private Function ConsisInitiateComms(ByVal SectionID As String, RobotHeap As Integer, strMessageText As String) As Integer
'21Aug05 CKJ Written
'            Consis requires successful exchange of SEVEN messages before we can do anything useful
'            Failure on a previous occasion can leave a previous reply from Consis up the spout
'            ready for sending to us the next time we connect, even from a different program.
'
'                      Ascribe                                Consis
'            1         CIM...              ==>
'            2                            <==                 <Ack>CIA...
'            3         <Ack>               ==>
'
'            4         R...<0>             ==>
'            5                            <==                 <Ack>
'            6                            <==                 r...<0>
'            7         <Ack>               ==>
'
'            1-3 are one set, 4-7 are another. Note that 2 is really an Ack plus a totally separate message
'            but Consis sends them as one. No other Ack-msg seems to work the same way.
'            Only msg 6 from Consis is nul terminated; Acks are not, neither is the CIA reply.
'            Update from Baxter: SOME messages end in nul, others may have embedded nulls as a fill character!
'            therefore we cannot use them as a terminator. There is however a terminator option but this does
'            not apply to Ack/Nak and maybe not to CIM/CIA      <sigh />
'            The fill char can be set to space if desired. A delay beweeen Ack and CIA may be available if we ask.
'            \Consis_Connect\Consis.ini
'                [Host]
'                ReportCapacity = Yes               - 'b' msg includes/excludes the 5 char 'total capacity' item
'                Fill_Character=32                  - default is to fill gaps in msg with nul, use 32 for space
'                Terminator = 3                     - default is no terminator, this sets <etx> except for Ack/Nak
'            - none of this is documented in Revision 1.6 of the i/f spec from Baxter
'
'            6: The <Ack> and 'r' msg should follow almost immediately in sequence, use modal shows with append
'               example: 'r003O113008ABIKOPRS<0>  r_003_O113_008_ABIKOPRS_<0>
'
'14Sep05 CKJ Added logging

Dim success As Integer
Dim State As Integer
         
Dim strMessage As String
Dim strMessageType As String
Dim strReply As String
Dim intSuccess As Integer
Dim dummy As Integer
Dim iniFile As String
Dim retries As Integer
Dim restarts As Integer
Dim ACKchar As String
Dim NAKchar As String

   success = False
   State = 0               'not tried yet, unknown state
   retries = 0
   
   iniFile = dispdata$ & MechDispIni
   strMessageText = ""
   ACKchar = Chr$(6)
   NAKchar = Chr$(15)

   Do
      MechDispLog SectionID, "D", "State : (" & Format$(State) & ")"
      
      Select Case State
         Case 0            'base state, lets try to link
            If restarts <= 3 And retries < 10 Then      'limit number of times it will restart the link or resend a packet  !!** make configurable
                  restarts = restarts + 1
                  retries = retries + 1
                  State = 1        'try the CIM msg
               Else
                  MechDispLog SectionID, "E", "State -2: Quitting after " & Format$(retries) & " retries and " & Format$(restarts) & " restarts"
                  State = -2       'give up and exit with failure
               End If

         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CIM/CIA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 1                  'ready to send CIM msg
            strMessageType = "CIM"
            strMessage = "[MSG" & strMessageType & "]"
            ParseCtrlChars iniFile, SectionID, strMessage, 0
            ParseItems RobotHeap, strMessage, False
            LastReply True, ""
            
            If ConsisSendMessage(SectionID, strMessage, "") Then         'Actually send the message (Loads the IPlink form & connects if not already done)
                  State = 2      'successful send
               Else
                  State = 101    'send CIM failed
               End If

         Case 2                  'sent CIM, what's the reply?
            Consis.lblMessage.Caption = Chr$(12)
            Consis.lblMessage.Caption = "  Waiting for <ACK> from Consis... (2)"
            dummy = ConsisShow(True)                                      'modal show while waiting for reply
            '...stay as modal form until reply received or user Cancels...
            LastReply 2, strReply

            If Len(strReply) Then   'something arrived
                  Select Case Left$(strReply, 1)
                     Case ACKchar
                        If Len(strReply) = 1 Then
                              State = 3          'wait for CIA reply
                           Else
                              strReply = Mid$(strReply, 2)     'probably got it already in this message
                              State = 4
                           End If
   
                     Case NAKchar
                        State = 201              'we should resend last message (counts as a retry)
   
                     Case Else
                        State = 202              'unexpected reply
   
                     End Select
               Else
                  State = 203           'no reply: timed out or user got bored waiting
               End If

         Case 3                     'wait for CIA reply
            Consis.lblMessage.Caption = Chr$(12)
            Consis.lblMessage.Caption = "  Waiting for <CIA> from Consis... (3)"
            dummy = ConsisShow(True)                                      'modal show while waiting for reply
            '...stay as modal form until reply received or user Cancels...
            LastReply 2, strReply
            
            If Len(strReply) Then   'something arrived
                  State = 4
               Else
                  State = 301       'no reply: timed out or user got bored waiting
               End If

         Case 4                     'got a reply, now send Ack
            strMessageType = "ACK"
            strMessage = "[MSG" & strMessageType & "]"
            ParseCtrlChars iniFile, SectionID, strMessage, 0
            ParseItems RobotHeap, strMessage, False
            LastReply True, ""
            
            If ConsisSendMessage(SectionID, strMessage, "") Then         'Actually send the message (Loads the IPlink form & connects if not already done)
                  State = 5         'details logged so don't parse
               Else
                  State = 401       'send ACK failed
               End If

         Case 5                     'parse CIA reply after getting ACK
            If InStr(strReply, "CIA|CONSIS|") = 1 Then 'correct preamble
                  State = 11     'successful send, move on to next phase
               Else
                  State = 501
               End If
         
         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CIM/CIA Errors ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 101
            MechDispLog SectionID, "E", "State 101: send CIM failed"
            State = 999             'restart interface
         
         Case 201
            MechDispLog SectionID, "E", "State 201: NAK received after sending CIM"
            retries = retries + 1
            State = 2               'send it again
         
         Case 202
            MechDispLog SectionID, "E", "State 202: unexpected reply when waiting for ACK: " & FormatCtrlChars(strReply)
            State = 999             'restart interface   '!!** may have to Ack then start again?
         
         Case 203
            MechDispLog SectionID, "E", "State 203: no reply when waiting for ACK"
            State = 999             'restart interface

         Case 301
            MechDispLog SectionID, "E", "State 301: no reply when waiting for CIA"
            State = 999             'restart interface
         
         Case 401
            MechDispLog SectionID, "E", "State 401: send ACK failed"
            State = 999             'restart interface

         Case 501
            MechDispLog SectionID, "E", "State 501: Incorrect reply to CIM: " & FormatCtrlChars(strReply)
            State = 999             'restart interface     '!!** may have to start again?
             
         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ R/r ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 11                  'ready to send R msg
            strMessageType = "R"
            strMessage = "[MSG" & strMessageType & "]"
            ParseCtrlChars iniFile, SectionID, strMessage, 0
            ParseItems RobotHeap, strMessage, False
            LastReply True, ""
            
            If ConsisSendMessage(SectionID, strMessage, "") Then         'Actually send the message (Loads the IPlink form & connects if not already done)
                  State = 12      'successful send
               Else
                  State = 1101    'send CIM failed
               End If
      
         Case 12                  'sent R, what's the reply?
            Consis.lblMessage.Caption = Chr$(12)
            Consis.lblMessage.Caption = "  Waiting for <ACK> from Consis... (12)"
            dummy = ConsisShow(True)                                      'modal show while waiting for reply
            '...stay as modal form until reply received or user Cancels...
            LastReply 2, strReply

            If Len(strReply) Then   'something arrived
                  Select Case Left$(strReply, 1)
                     Case ACKchar
                        If Len(strReply) = 1 Then
                              State = 13          'wait for r reply
                           Else
                              strReply = Mid$(strReply, 2)     'probably got it already in this message
                              State = 14
                           End If
   
                     Case NAKchar
                        State = 1201              'we should resend last message (counts as a retry)
   
                     Case Else
                        State = 1202              'unexpected reply
   
                     End Select
               Else
                  State = 1203           'no reply: timed out or user got bored waiting
               End If

         Case 13                     'wait for r reply
            Consis.lblMessage.Caption = Chr$(12)
            Consis.lblMessage.Caption = "  Waiting for <r> from Consis... (13)"
            dummy = ConsisShow(True)                                      'modal show while waiting for reply
            '...stay as modal form until reply received or user Cancels...
            LastReply 2, strReply
            
            If Len(strReply) Then    'something arrived
                  State = 14
               Else
                  State = 1301       'no reply: timed out or user got bored waiting
               End If
         
         Case 14                     'got a reply, now send Ack
            strMessageType = "ACK"
            strMessage = "[MSG" & strMessageType & "]"
            ParseCtrlChars iniFile, SectionID, strMessage, 0
            ParseItems RobotHeap, strMessage, False
            LastReply True, ""
            
            If ConsisSendMessage(SectionID, strMessage, "") Then         'Actually send the message (Loads the IPlink form & connects if not already done)
                  State = 15                            'details logged so don't parse
               Else
                  State = 1401    'send ACK failed
               End If

         Case 15                     'parse 'r' reply after getting ACK
            If Left$(strReply, 1) = "r" Then            'correct preamble
                  '!!** could return message types it supports
                  State = -1      'successful send, return to calling routine   <== DONE
               Else
                  State = 1501
               End If

         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ R/r Errors ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 1101
            MechDispLog SectionID, "E", "State 1101: send R failed"
            State = 999             'restart interface
         
         Case 1201
            MechDispLog SectionID, "E", "State 1201: NAK received after sending R"
            retries = retries + 1
            State = 2               'send it again
         
         Case 1202
            MechDispLog SectionID, "E", "State 1202: unexpected reply when waiting for ACK: " & FormatCtrlChars(strReply)
            State = 999             'restart interface   '!!** may have to Ack then start again?
         
         Case 1203
            MechDispLog SectionID, "E", "State 1203: no reply when waiting for ACK"
            State = 999             'restart interface

         Case 1301
            MechDispLog SectionID, "E", "State 1301: no reply when waiting for r"
            State = 999             'restart interface

         Case 1401
            MechDispLog SectionID, "E", "State 1401: send ACK failed"
            State = 999             'restart interface

         Case 1501
            MechDispLog SectionID, "E", "State 1501: Incorrect reply to R: " & FormatCtrlChars(strReply)
            State = 999             'restart interface     '!!** may have to start again?
                                                              

         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Restart ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 999                   'turned pear shaped, close IP port & restart from beginning
            If Not Consis Is Nothing Then
                  dummy = IPlinkCloseConnection(Consis)
                  '05Jun17 TH Post logs (TFS 185185)
                  PostMechDispLog
               End If
            State = 0               'start again

         Case -2                    '-2 quit with fail
            Exit Do

         Case -1                    '-1 quit with success
            Exit Do

         Case Else
            MechDispLog SectionID, "E", "State " & Format$(State) & ": This state has not been programmed: Quitting"
            State = -2                                                          '<== DONE
            
         End Select
   Loop

   ConsisInitiateComms = (State = -1)                 'success only if state = -1

End Function

Private Function ConsisRequestProduct(ByVal SectionID As String, ByVal strMessageType As String, ByVal Identifier1 As String, ByVal Identifier2 As String, ByVal ProductID As String, ByVal QuantityToIssue As String, QuantityIssued As String, QuantityStocked As String, strMessageText As String) As Integer
'12Aug05 CKJ Siemens Consis handler
'Given a number of whole packs to issue (must not be negative) and a barcode,
'contact Consis, send message if possible, and return details of product or failure code
'SectionID is the MechDisp.ini section for the product requested
'                                                                  -----------Success------------ -----------Failure------------
' strMessageType Identifier1 Identifier2 ProductID QuantityToIssue QuantityIssued QuantityStocked QuantityIssued QuantityStocked   Implemented
'  B  Enquiry       blank     blank       EAN13       ignored       ""             n               unchanged      unchanged          Yes
'  A  Patient    SNAME Fname Caseno Ward  EAN13       n             n              unchanged       unchanged      unchanged          Yes
'  A  Ward          ward      picktickno  EAN13       n             n              unchanged       unchanged      unchanged          *NO*

'  CIM  is handled internally, do not request from outside
'  R    is handled internally, do not request from outside
'
'All quantities are positive integers.
'Return value is success T/F
'
'14Sep05 CKJ Consis i/f improved - checks msg returned from a pick request
'07Sep10 CKJ Stock Enquiry now compares returned barcode with ProductID instead of d.barcode  (F0096016)

Dim strMessage As String
Dim strReply As String
Dim RobotHeap As Integer
Dim intSuccess As Integer
Dim dummy As Integer
Dim strReplyType As String
Dim strReplyText As String
Dim strTemp As String
Dim iniFile As String
Dim strQtyIssued As String
Dim strQtyStocked As String
Dim strReplyMID As String
Dim MessageID As Long
Dim blnBusy As Integer
Dim strReplyStatus As String
Dim strText As String
Dim strTemplate As String
Dim strMask As String

   intSuccess = False

   MessageID = 0
   iniFile = dispdata$ & MechDispIni
   strMessageText = ""

   If Not blnBusy Then
         blnBusy = True

         strTemp = terminal("ConsisTerminalName", "<INVALID>")           'Not currently sent to Consis, but needed to show Terminal is robot enabled
         strMessage = "[MSG" & strMessageType & "]"                        'MessageType = Patient, Ward, Enquiry
         ParseCtrlChars iniFile, SectionID, strMessage, 0
         strReplyType = TxtD(iniFile, SectionID, "", "ANS" & strMessageType, 0)
      
         If strTemp = "<INVALID>" Then
               'no action: not a Consis enabled terminal
      
            ElseIf strMessage = "[MSG" & strMessageType & "]" Then
               strMessageText = "Unsupported message type: " & strMessageType
               MechDispLog SectionID, "E", strMessageText
            
            'ElseIf Len(strReplyType) = "" Then           'config error - MSGx defined with no ANSx      '10Jan10 CKJ corrected
            ElseIf Len(strReplyType) = 0 Then           'config error - MSGx defined with no ANSx        '   "
               strMessageText = "ReplyType not defined for MessageType: " & strMessageType
               
            ElseIf Len(ProductID) = 0 Then                                  'no message id number
               'no action: no barcode provided
            
            ElseIf Val(SectionID) = 0 Then
               strMessageText = "Invalid SectionID: " & SectionID
               MechDispLog SectionID, "E", strMessageText
      
            Else
               Heap 1, RobotHeap, "Consis Data Heap", "", intSuccess
               If Not intSuccess Then strMessageText = "Failed to allocate data heap for Consis"

            '** Trap issue qty outside range 00001 to 99999
            
            End If
            
         If intSuccess Then
               Select Case strMessageType
                  Case "A"                                                                   'message id number needed
                     GetPointerSQL dispdata$ & "\Consis.dat", MessageID, True                   'only get number once lock is granted
                     Select Case MessageID
                        Case Is < 1, Is > 89999999                                           '0 < n < 90,000,000
                           GetPointerSQL dispdata$ & "\Consis.dat", 1, 2
                           MessageID = 1
                        End Select
                  Case Else
                     MessageID = 0
                  End Select
      
               Heap 10, RobotHeap, "yyyymmddNow", Format$(Now, "yyyymmdd"), 0
               Heap 10, RobotHeap, "hhnnssNow", Format$(Now, "hhnnss"), 0
               Heap 10, RobotHeap, "MessageID", Format$(MessageID, "00000000"), 0
               Heap 10, RobotHeap, "IssueQty", Format$(QuantityToIssue, "00000"), 0
               Heap 10, RobotHeap, "EANcode", ProductID, 0
               Heap 10, RobotHeap, "TerminalName", strTemp, 0
               Heap 10, RobotHeap, "ChuteID", pad(terminal("ConsisChuteID", "  "), 3), 0           'must be 3 chars
               Heap 10, RobotHeap, "TerminalID", pad(terminal("ConsisTerminalID", "   "), 3), 0    'must be 001 to 899
               Heap 10, RobotHeap, "UserID", UserID$, 0
               Heap 10, RobotHeap, "ToCode", pad(Identifier2, 15), 0                               'caseno ward  / picking picket
               Heap 10, RobotHeap, "ToName", pad(Identifier1, 30), 0                               'Patient name / ward
            
               intSuccess = ConsisComms(SectionID, RobotHeap, strMessageType, strReplyType, strReply, strMessageText)

               If intSuccess Then
                     intSuccess = False

                     Consis.lblMessage.Caption = Chr$(12)                  'clear window

                     strReplyText = strReply
                     strQtyIssued = ""
                     strQtyStocked = QuantityStocked
                     strReplyMID = ""
                     Heap 10, RobotHeap, "ReceivedText", FormatCtrlChars(strReplyText), False      '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "ReceivedMessageID", strReplyMID, False      '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "CR", crlf, False      '20May08 CKJ was intSuccess
                     
                     strReplyStatus = "OK"
                     Heap 10, RobotHeap, "ReplyType", strReplyType, False      '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "ReplyStatus", strReplyStatus, False      '20May08 CKJ was intSuccess

                     replace strReply, Nul, " ", 0                         'Nul => space

                     Select Case strReplyType
                        Case "a"
                           'SEND
                           '01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                           'A< msgid><3><3>!<><       20         >< 5 >!<   10   ><  15 Caseno  ><    30 Patient name         >
                           'A000000680030033016878661207908       000010                                                       '
                           'A000000030010013018779763806502       000010          A100084756 MED1SURNAME Forename1 Forename2   '
                           
                           'REPLY
                           'size posn  description & content
                           ' 1    0 message-ID ´a´
                           ' 8    1 order-number > ´00000000´ & < ‘90000000’
                           ' 3    9 number of requesting location > ´000´ & < ‘900’
                           ' 3   12 delivery-location > ´000´
                           ' 2   15 order-state
                           '        ´01´ in queue
                           '        ´05´ change of quantity from CONSIS to PS
                           '        ´04´ completed
                           '        ´00´ in progress        XXX
                           '        ´02´ queue full         XXX
                           '        ´03´ stopped            XXX
                           '
                           ' 2   17 number of following articles = ´01´
                           '20   19 Article code
                           ' 5   39 delivered quantity >= ´00000´
                           '10   44 Prescription number (optional)
                           '15   54 Patient ID (optional)
                           '30   69 Patient Name (optional)
                           
                           'REPLY
                           '01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
                           'a<  8   ><3><3><><><       20         >< 5 ><   10   ><     15      ><                30          >
                           '.AAAAAAAABBBCCCDDEEFFFFFFFFFFFFF.......GGGGGHHHHHHHHHHIIIIIIIIIIIIIIIJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ'
                           'a0000007200300105016878661207908       00000                                                       '
                           
                           'check msgid       - AAAAAAAA
                           'check order state - DD
                           'check barcode     - FFFFFFFFFFFFF
                           'check quantity    - GGGGG
                           'build suitable message if not successful.

                           
                           '14Sep05 CKJ removed - replaced with section below
                           'strQtyIssued = QuantityToIssue                             'inferred because it was accepted for issue
                           'Heap 10, RobotHeap, "QtyIssued", strQtyIssued, False
                           'strText = "[IssuedMsg]"
                           
                           intSuccess = True                                                                     '14Sep05 CKJ section written
                           strTemplate = TxtD(iniFile, SectionID, "", "ANSaTEMPLATE", 0)

                           'check message length
                           If Len(strTemplate) <> Len(strReply) Then
                                 strText = "[IncorrectLengthMsg]"
                                 intSuccess = False
                              End If
                           
                           If intSuccess Then
                                 strMask = TxtD(iniFile, SectionID, "", "ANSaMESSAGEID", 0)
                                 strReplyMID = StringExtract(strTemplate, strMask, strReply)
                                 Heap 10, RobotHeap, "ReceivedMessageID", strReplyMID, False      '20May08 CKJ was intSuccess
      
                                 If CDbl(strReplyMID) <> MessageID Then
                                       strText = "[IncorrectIDMsg]"
                                       intSuccess = False
                                    End If
                              End If
                             
                           If intSuccess Then
                                 strMask = TxtD(iniFile, SectionID, "", "ANSaBARCODE", 0)
                                 If StringExtract(strTemplate, strMask, strReply) <> ProductID Then
                                       strText = "[InvalidBarcode]"
                                       intSuccess = False
                                    End If
                              End If
                            
                           If intSuccess Then
                                 strMask = TxtD(iniFile, SectionID, "", "ANSaORDERSTATE", 0)
                                 strReplyStatus = StringExtract(strTemplate, strMask, strReply)
                                 Heap 10, RobotHeap, "ReplyStatus", strReplyStatus, False      '20May08 CKJ was intSuccess

                                 Select Case strReplyStatus
                                    Case "01", "04", "05"      'in queue, completed, in progress - all OK
                                       strMask = TxtD(iniFile, SectionID, "", "ANSaQUANTITY", 0)                        '!!** Have to assume issue qty
                                       strQtyIssued = StringExtract(strTemplate, strMask, strReply)
                                       Heap 10, RobotHeap, "QtyIssued", strQtyIssued, False
                                       strQtyStocked = Format$(Val(strQtyStocked) - Val(strQtyIssued))         'assumes qtystocked was set before calling
                                       Heap 10, RobotHeap, "QtyStocked", strQtyStocked, False      '20May08 CKJ was intSuccess
                                       strText = "[IssuedMsg]"
                                       
                                    Case Else
                                       strText = "[InvalidReplyStatusMsg]"
                                       intSuccess = False
                                    End Select
                              End If
                           
                        Case "b"          'stock enquiry reply
                           '1234567890123456789012345678901234567890123456
                           'b0035011641800534       000000000000'
                           '.AAABBBBBBBBBBBBB.......CCCCCDDDDDEE'
                           'b_003_5011641800534       _00000_00000_00

                           'check barcode is for correct msg
                           'If Mid$(strReply, 5, 13) = d.barcode Then      '07Sep10 CKJ should be ProductID not d.barcode  (F0096016)
                           If Mid$(strReply, 5, 13) = ProductID Then       '   "     "
                                 If IsDigits(Mid$(strReply, 25, 5)) Then
                                       strQtyStocked = Format$(Val(Mid$(strReply, 25, 5)))  '00018
                                       strText = "[StockedMsg]"
                                       Heap 10, RobotHeap, "QtyStocked", strQtyStocked, False      '20May08 CKJ was intSuccess
                                       intSuccess = True
                                    Else
                                       strText = "[InvalidSLMsg]"                           'not five digits, success stays false
                                    End If
                              Else
                                 strText = "[InvalidSLBarcode]"                             'not for correct barcode
                              End If

                        Case Else       'unknown message type within acknowledgement
                           strText = "[InvalidReplyMsg]"

                        End Select
                           
                     ' Case       'Quantity asked > Quantity in stock                      Not supported in current version
                     '    strQtyIssued = "0"
                     '    strQtyStocked = strReplyText
                     '    Heap 10, RobotHeap, "QtyIssued", strQtyIssued, intSuccess
                     '    Heap 10, RobotHeap, "QtyStocked", strQtyStocked, intSuccess
                     '    strText = "[InsufficientMsg]"
                     
                     If Not intSuccess And Len(strText) = 0 Then
                           strText = "[RejectedMsg]"                                      '" Request Rejected: [cr] - [ReceivedText]"
                        End If
               
                     QuantityIssued = Trim$(strQtyIssued)
                     QuantityStocked = strQtyStocked

                     ParseCtrlChars iniFile, SectionID, strText, False
                     ParseItems RobotHeap, strText, False
                     Consis.lblMessage.Caption = strText
                     If Len(strText) Then strMessageText = strText                        '10jan10 ckj should be blank except for errors

                  Else
                     'no action, return failure code
                     strMessageText = "Consis not responding or message is not valid" & cr & FormatCtrlChars(strReply)
                     '!!** replace when strMessageText is set inside ConsisComms
                  End If

               Heap 2, RobotHeap, "", "", False
                  
            Else
               'messages already set above
            End If
         
         blnBusy = False
      End If

   ConsisRequestProduct = intSuccess

End Function

Private Function ConsisSendMessage(ByVal SectionID As String, ByVal strMessage As String, EOL As String) As Integer
'12Aug05 CKJ
'Never call this directly - only call via ConsisRequestProduct
'otherwise the busy flag would be bypassed
'16oct06 CKJ Changed DoEvents to DoSaferEvents
'06Mar07 CKJ Added extra checks

Dim success As Integer
Dim AfterNSeconds As Variant
Dim iniFile As String

   success = False

   ConsisSendMessage = False

   If strMessage <> "" And Val(SectionID) > 0 Then
         success = ConsisShow(False)
         
         '06Mar07 CKJ Added extra checks
         If Not success Then
            popmessagecr ".", "Consis Interface could not be started"
            
         ElseIf Consis.mobjIPClient Is Nothing Then
            Consis.lblStatus.Caption = IPclientMissingMsg
            Consis.lblMessage.Caption = IPclientMissingMsg
            
         Else
            iniFile = dispdata$ & MechDispIni
         
            Consis.lblMessage.Caption = Chr$(12)
            If Not Consis.mobjIPClient.WinsockLoaded Then
   '11feb07               Consis.mobjIPClient.WinsockLoaded = True
               End If
            
            Consis.mobjIPClient.EOL = EOL            'Consis data is NOT MLLP encapsulated
            
            'close old connections (if any)
            '!!** should not be needed in current implementation
            '     may be needed if multiple connections to several machines
            
            If success Then                                    'attempt connection
                  If Not Consis.mobjIPClient.Connected Then
                        Consis.Tag = SectionID
                        Consis.mobjIPClient.RemoteHost = TxtD(iniFile, SectionID, "127.0.0.1", "IPaddress", False)
                        Consis.mobjIPClient.RemotePort = TxtD(iniFile, SectionID, "0", "IPport", False)
                        If Consis.mobjIPClient.RemotePort = 0 Then
                              Consis.lblStatus.Caption = "IP port must be configured for terminal " & ASCTerminalName$()
                           Else
                              Consis.lblStatus.Caption = "Connecting to " & Consis.mobjIPClient.RemoteHost & " port " & Consis.mobjIPClient.RemotePort & " ..."
                              Consis.mobjIPClient.Connected = True
                           End If
                     End If
                  
                  If Consis.mobjIPClient.RemotePort > 0 Then
                        'wait until the connection is achieved (timeout in 10 seconds)
                        AfterNSeconds = Now + CDbl(TxtD(iniFile, SectionID, "10", "timeout", False)) / (3600# * 24#)
                        Do Until Now > AfterNSeconds
                           If Consis.mobjIPClient.Connected Then Exit Do
                           DoSaferEvents 1                               '16oct06 CKJ was DoEvents, but this allowed main prog to continue
                        Loop
                     End If
                  
                  If Not Consis.mobjIPClient.Connected Then
                        Consis.lblStatus.Caption = "Connection timed out."
                     Else
                        Consis.lblStatus.Caption = "Send: " & FormatCtrlChars(strMessage)
                                    
                        'send the data
                        Consis.mobjIPClient.DataToSend = strMessage
                        ConsisSendMessage = True
                     End If
               End If
         End If
      End If

End Function

Private Function ConsisShow(ByVal SetModal As Integer) As Integer
'12Aug05 CKJ
'If the form is not loaded, then load and show
'If the form is loaded, then hide if necessary and show
'If already loaded and on show with the correct modality, do nothing
'SetModal = -1 True                          modal
'            0 False (or any other integer)  nonmodal
'            1                               don't change mode if set, use non modal if not set

Dim IsModal As Integer
Dim dummy As Integer
Dim blnHide As Integer

   ConsisShow = False
   IsModal = (SetModal = True)                   'only set modal if specifically requested
   If Consis Is Nothing Then
         dummy = ConsisInitialise(False)
         IsModal = True
         Consis.cmdCancel.Visible = IsModal
         Consis.Timer1.Enabled = True
      End If
   
   If Not Consis Is Nothing Then
         If Consis.Visible Then
               If SetModal = 1 Then IsModal = (Consis.cmdCancel.Tag = "-1")         'set modal based on existing form
               blnHide = False
               If Consis.cmdCancel.Tag = "-1" And Not IsModal Then blnHide = True   'Modal wanted, not modal now
               If Consis.cmdCancel.Tag = "0" And IsModal Then blnHide = True        'Non modal wanted, modal now ** should not be necessary of course
               If Consis.cmdCancel.Tag = "0" And Not IsModal Then blnHide = True    'Non modal wanted, non modal now BUT might need to auto hide -2 because of existing modal form
               If blnHide Then
                     IPlinkHide Consis         'hide first to change modality
                  End If
            End If
         
         ConsisShow = True
         If Not Consis.Visible Then
               Consis.cmdCancel.Visible = IsModal
               Consis.cmdCancel.Tag = Format$(IsModal)
               On Error GoTo ConsisShow_Err
               Consis.Show Iff(IsModal, 1, 0), OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form          'Show
            End If
      End If

Exit Function

ConsisShow_Err:
   Select Case Err
      'Can't display non-modal form when modal form showing
      '12mar07 CKJ Added: Non-modal forms cannot be displayed in this host application from an ActiveX DLL, ActiveX Control, or Property Page. (406)
      Case 401, 406
         IPlinkHide Consis
         IsModal = True
         Consis.cmdCancel.Visible = IsModal
         Consis.cmdCancel.Tag = "-1"
         IPlinkResize Consis
         Consis.Timer1.Enabled = True                  'show modally then hide immediately
         Resume

      Case Else
         popmessagecr ".", "Procedure ConsisShow Error:" & crlf & Error & " (" & Format$(Err) & ")"
         Resume Next

      End Select

Resume Next
      
End Function

Private Function ConsisTerminate() As Integer
'12Aug05 CKJ Cancel any current connection, close the IP port and close the form

Dim dummy As Integer

   If Not Consis Is Nothing Then
         dummy = IPlinkCloseConnection(Consis)

         Unload Consis                                                         'this closes current connection if any
         Set Consis = Nothing
         '05Jun17 TH Post logs (TFS 185185)
         PostMechDispLog
      End If

   ConsisTerminate = True                                                      'may return error indication

End Function

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

Function GetHWndParent() As Integer
'07Mar04 CKJ

   GetHWndParent = m_hWndParent
   
End Function

Function GetRobotPrintLabelMessageID() As Long

   GetRobotPrintLabelMessageID = m_lngRobotPrintLabelMessageID

End Function

Sub HideAllIPlinkForms()
'09Mar04 CKJ written

Dim intloop As Integer

   For intloop = (Forms.count - 1) To 0 Step -1
      If TypeOf Forms(intloop) Is frmIPlink Then
            IPlinkHide Forms(intloop)
         End If
   Next

End Sub

Function IPlinkCloseConnection(frm As Form) As Integer
'16June04 CKJ Changed to public to allow use from the IPlink form
'             Added test for WinsockLoaded and KeepAlive
'             Linger moved above the disconnect

   If Not frm.mobjIPClient Is Nothing Then        '06Mar07 CKJ added
      If frm.mobjIPClient.WinsockLoaded Then
         If frm.mobjIPClient.Connected Then
               frm.lblStatus.Caption = "Connection disconnecting"
               frm.mobjIPClient.KeepAlive = False
               frm.mobjIPClient.Linger = True  ' False
               frm.mobjIPClient.Connected = False
            
               Do While frm.mobjIPClient.Connected
                  DoEvents
                  frm.lblStatus.Caption = "Waiting for disconnection"
               Loop
            End If
      End If
   End If
   
   IPlinkCloseConnection = True

End Function

Sub IPlinkHide(frm As Form)
'Always use this to hide the form, as this ensures that the modality flag is cleared

   frm.cmdCancel.Tag = "0"
   frm.cmdCancel.Visible = False
   frm.Timer1.Enabled = False
   
   If frm.Visible Then     '06Mar07 CKJ added
      frm.Hide
   End If
       
End Sub

Sub IPlinkResize(frm As Form)

Dim intPixels As Integer
Dim formWidth As Integer
Dim formHeight As Integer

   On Error Resume Next
   formWidth = frm.ScaleWidth
   formHeight = frm.ScaleHeight
   intPixels = 0
   If frm.cmdCancel.Tag = "-1" Then
         intPixels = frm.cmdCancel.Height + 30
         frm.cmdCancel.Move (formWidth - frm.cmdCancel.Width) \ 2, formHeight - frm.cmdCancel.Height
      End If
   
   frm.txtStatus(0).Move 0, 0, formWidth, formHeight - intPixels
   frm.txtStatus(1).Move 60, 0, formWidth - 60, formHeight - intPixels
   On Error GoTo 0

  ' If frm.Visible And frm.cmdCancel.Tag = "-2" Then  '20Feb04 CKJ/TH Hide as soon as show is complete
  '       IPlinkHide frm
  '    End If

End Sub

Sub IPLinkShutdown()
'30Jun05 CKJ Close all dispensing robot interfaces

Dim success As Integer

   success = SwisslogTerminate()
   success = RowaTerminate()
   success = ApostoreTerminate()
   success = ConsisTerminate()
   success = RoboPharmaTerminate()
   '...

End Sub

Sub JVMAppendLine(ByVal channel As String, ByVal strText As String)
'

   

End Sub

Sub LastReply(ByVal intWrite As Integer, strReply As String)
'Repository for reply
'
'intWrite =  0 False    read reply
'           -1 True     store reply
'            1          append reply
'            2          read reply & clear the buffer

Static buffer As String

   Select Case intWrite
      Case 0                 'read from buffer
         strReply = buffer

      Case -1                'write to buffer
         buffer = strReply
      
      Case 1                 'append to buffer
         buffer = buffer & strReply
      
      Case 2                 'read and clear buffer
         strReply = buffer
         buffer = ""
      
      End Select

End Sub

Function LocationForMechDisp(ByVal LocationCode As String, MachineType As String) As Integer
'Given product locationcode return whether that product is marked for mechanical dispensing
' and the machine type e.g. "Swisslog"

   MachineType = TxtD(dispdata$ & MechDispIni, SectionIDForMechDisp(LocationCode), "<UNKNOWN>", "Identifier", 0)
   LocationForMechDisp = (MachineType <> "<UNKNOWN>")

End Function

Sub MechDispClearLabelData()
'20May08 CKJ written
'            Clear module level stored data for robot label printing
'            In many cases supercedes  SetRobotPrintLabelMessageID 0  EXCEPT where the ID is being temporarily moved
'            to allow non-robot printing before being put back in place.

   m_lngRobotPrintLabelMessageID = 0
   m_RobotPrintLabelSection = ""
   
End Sub

Function MechDispEnquiry(dlocal As DrugParameters, MachineType As String, QuantityStocked As String, strMessage As String) As Integer
'Get stock level of given product, if stocked in machine
'16Jun04 CKJ added message parameter
'11Aug05 CKJ Added Apostore

Dim success As Integer
Dim dummy As Integer

   success = False
   strMessage = ""
   
   If LocationForMechDisp(dlocal.loccode, MachineType) Then
         Select Case LCase$(MachineType)
            Case "swisslog"
               success = SwisslogRequestProduct(SectionIDForMechDisp(dlocal.loccode), "Enquiry", "", "", Trim$(dlocal.barcode), "0", "0", QuantityStocked, strMessage) '16Jun05 CKJ Added strMessage
            
            Case "rowa"
               success = RowaRequestProduct(SectionIDForMechDisp(dlocal.loccode), "Enquiry", "", "", Trim$(dlocal.barcode), "0", "0", QuantityStocked, strMessage, False)      '20May08 CKJ Added print param
            
            Case "apostore"
               'success = ApostoreRequestProduct(SectionIDForMechDisp(dlocal.loccode), "Enquiry", "", "", Trim$(dlocal.barcode), "0", "0", QuantityStocked, strMessage, False, dlocal.storesdescription, dlocal.Description) XN 4Jun15 98073 New local stores description '24jul06 ckj added print param  '03Jun10 CKJ Added decsriptions
                           success = ApostoreRequestProduct(SectionIDForMechDisp(dlocal.loccode), "Enquiry", "", "", Trim$(dlocal.barcode), "0", "0", QuantityStocked, strMessage, False, dlocal.DrugDescription)
            
            Case "consis"
               success = ConsisRequestProduct(SectionIDForMechDisp(dlocal.loccode), "B", "", "", Trim$(dlocal.barcode), "0", "0", QuantityStocked, strMessage)
               If Not Consis Is Nothing Then
                  dummy = IPlinkCloseConnection(Consis)
                  '05Jun17 TH Post logs (TFS 185185)
                  PostMechDispLog
               End If
            
            Case "jvadtps"       '18May06 CKJ Enquiry not supported
               success = False

            Case "mts"           '25Jan08 CKJ Enquiry not supported
               success = False
               
            Case "robopharma"    '16Dec09 CKJ
               success = RoboPharmaRequestProduct(SectionIDForMechDisp(dlocal.loccode), "Enquiry", "", "", Trim$(dlocal.barcode), "0", "0", QuantityStocked, strMessage)
'               If Not RoboPharma Is Nothing Then                  'Was needed for Consis but should not be for RoboPharma !!**
'                  dummy = IPlinkCloseConnection(RoboPharma)
'               End If
            
            Case Else
               '
            
            End Select
      End If
   
   MechDispEnquiry = success

End Function

Function MechDispIssue(dlocal As DrugParameters, ByVal blnImmediatePick As Integer, ByVal QuantityToIssue As String, QuantityIssued As String, QuantityStocked As String, strMessageText As String, blnRobotLabelPrint As Integer) As Integer
'Issue product from machine, if stocked there
'          d As drugparameters   drug to process
'          blnImmediatePick      True: immediate (patient) picking, False: allow delayed (batch) picking
'          QuantityToIssue       Whole packs only
'          QuantityIssued        Whole packs, zero, or "" if unable to complete
'          QuantityStocked       Whole packs, zero, or "" if unable to complete. If not null after issue then this is the stock level remaining on completion of issue
'          Return value          Success = T/F
'16Jun05 CKJ added strMessageText parameter
'11Aug05 CKJ Added Apostore
'14Sep05 CKJ Removed picking tickets from Consis - was doing stock enquiry but then showing a message because PTs are not supported
'24Jul06 CKJ Added input/output param blnRobotLabelPrint
'            Input blnRobotLabelPrint=false  label not required, returns blnRobotLabelPrint=false
'            Input blnRobotLabelPrint=true   label is wanted, returns blnRobotLabelPrint=T/F depending on whether robot supports labelling
'22Jul10 CKJ 5 char ward codes - Consis needs fixed length ward code. RCN P00158 F0092472 (fix to F0051906)

Dim MachineType As String
Dim success As Integer
Dim Identifier1 As String
Dim Identifier2 As String
Dim issuetype As String
Dim strMessage As String
Dim QuantityStockedInitially As String
Dim QuantityRobotIssueMax As Integer
Dim iniFile As String
Dim RobotHeap As Integer
Dim SectionID As String
Dim ShelfStock As Single
Dim PacksToPick As Single
Dim dummy As Integer
Dim strTemp As String
Dim WillRobotPrint As Integer

   MechDispIssue = False
   strMessageText = ""
   iniFile = dispdata$ & MechDispIni

   If LocationForMechDisp(dlocal.loccode, MachineType) Then
         Select Case LCase$(MachineType)
            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            Case "swisslog"
               SectionID = SectionIDForMechDisp(dlocal.loccode)
               If blnImmediatePick Then
                     Heap 11, gPRNheapID, "pForenameSurname", Identifier1, 0
                     Heap 11, gPRNheapID, "pCaseno", Identifier2, 0
                     issuetype = "Patient"                                             'also includes ad hoc stock issues
                     QuantityRobotIssueMax = Val(TxtD(iniFile, SectionID, "0", "MaxIssueImmediate", 0))
                  Else
                     Heap 11, gPRNheapID, "MechDispIdentifier1", Identifier1, 0        'ward
                     Heap 11, gPRNheapID, "MechDispIdentifier2", Identifier2, 0        'picktickno
                     issuetype = "Ward"
                     QuantityRobotIssueMax = Val(TxtD(iniFile, SectionID, "0", "MaxIssueDeferred", 0))
                  End If

               '16Jun05 CKJ Added block for max robot issue qty
               If QuantityRobotIssueMax > 0 And Val(QuantityToIssue) > QuantityRobotIssueMax Then  'requested quantity is greater than allowed for a single robot issue
                     success = SwisslogRequestProduct(SectionID, "Enquiry", "", "", Trim$(dlocal.barcode), "0", "0", QuantityStocked, strMessage)
                     'options are:
                     '  when asking for up to QuantityRobotIssueMax
                     '     deliver as much from robot as necessary, use shelf for any remainder
                     '  when asking for more than QuantityRobotIssueMax
                     '     use shelf in preference to robot, deliver remainder if any from robot  (ignoring any part pack on shelf)
                     'NB needs shelf stock level to be sensible - ie not less than robot stock level
                     
                     QuantityIssued = "0"
                     If success Then
                           Heap 1, RobotHeap, "Swisslog Data Heap", "", success
                           If Not success Then
                                 strMessageText = "Failed to allocate data heap for Swisslog"
                              Else
                                 Heap 10, RobotHeap, "CR", crlf, False
                                 Heap 10, RobotHeap, "IssueQty", QuantityToIssue, False
                                 Heap 10, RobotHeap, "MaxIssueQty", Format$(QuantityRobotIssueMax), False

                                 ShelfStock = Int(dp!(Val(dlocal.stocklvl) / Val(dlocal.convfact))) - Val(QuantityStocked)    'dept total in packs minus any robot stock
                                 If ShelfStock < 0 Then ShelfStock = 0                          'consider negative shelf stock to be zero shelf stock
                                 'what if RobotStock > TotalStock and QtyToIssue > TotalStock  ...  ?  (should have been checked before calling of course)
                                 'what if RobotStock > TotalStock and QtyToIssue < TotalStock  ...  ?
                                 
                                 If blnImmediatePick Then                                       'use shelf first & get all remaining stock from robot
                                       PacksToPick = Val(QuantityToIssue) - ShelfStock
                                    Else                                                        'use either shelf or robot but not both
                                       Select Case ShelfStock
                                          Case Is >= Val(QuantityToIssue)                       'shelf supplies it all
                                             PacksToPick = 0
                                          Case Is >= QuantityRobotIssueMax                      'shelf can supply at least robot limit, so take it
                                             PacksToPick = 0
                                          Case Is >= ((Val(QuantityToIssue) + 1) \ 2)           'shelf can supply at least half amount wanted (rounded up), so take it
                                             PacksToPick = 0
                                          Case Is >= Val(QuantityStocked)                       'shelf can supply as much as robot, so take it
                                             PacksToPick = 0
                                          Case Else                                             'shelf is depleted so use whatever is in robot (may be the full amount)
                                             PacksToPick = Val(QuantityToIssue)
                                          End Select
                                    End If

                                 If PacksToPick > 0 Then                                        'still need some or all from robot
                                       success = SwisslogRequestProduct(SectionIDForMechDisp(dlocal.loccode), issuetype, Identifier1, Identifier2, Trim$(dlocal.barcode), Format$(PacksToPick), QuantityIssued, QuantityStocked, strMessageText)
                                       If success Then
                                             strMessageText = "[MaxIssueMsg" & Iff(blnImmediatePick, "Immediate", "Deferred") & "Part]"
                                          End If
                                    Else
                                       strMessageText = "[MaxIssueMsg" & Iff(blnImmediatePick, "Immediate", "Deferred") & "None]"
                                    End If
                                 ParseCtrlChars iniFile, SectionID, strMessageText, False
                                 ParseItems RobotHeap, strMessageText, False
                                 Heap 2, RobotHeap, "", "", False
                              End If
                        Else
                           strMessageText = strMessage
                        End If

                  Else         'ask for whole amount from robot, reply indicates how much will be supplied
                     success = SwisslogRequestProduct(SectionIDForMechDisp(dlocal.loccode), issuetype, Identifier1, Identifier2, Trim$(dlocal.barcode), QuantityToIssue, QuantityIssued, QuantityStocked, strMessageText)
                  End If
               blnRobotLabelPrint = False
               MechDispIssue = success

            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            Case "rowa"
               WillRobotPrint = blnRobotLabelPrint                                           '20May08 CKJ take local copy
               blnRobotLabelPrint = False                                                    '            assume no print unless overridden
               If blnImmediatePick Then
                     Heap 11, gPRNheapID, "pForenameSurname", Identifier1, 0
                     Heap 11, gPRNheapID, "pCaseno", Identifier2, 0
                     issuetype = "Patient"
                  Else
                     Heap 11, gPRNheapID, "MechDispIdentifier1", Identifier1, 0       'ward
                     Heap 11, gPRNheapID, "MechDispIdentifier2", Identifier2, 0       'picktickno
                     issuetype = "Ward"
                  End If

               'QuantityToIssue  (Stock level)  QuantityIssued  QuantityStocked
               '       0              n/a             0          some or none
               '      >0             some            some             0
               '      >0            enough           all         some or none
               
               QuantityIssued = "0"
               QuantityStocked = ""
               success = MechDispEnquiry(d, "", QuantityStockedInitially, strMessage)
               
               'If success And Val(QuantityToIssue) > 0 Then          'machine available and talking to us (and we want to pick some stock)
               If success And Val(QuantityToIssue) > 0 And Len(QuantityStockedInitially) > 0 Then        'machine available and talking to us (and we want to pick some stock) '17JUn08 CKJ
                     'Try to issue all stock which was requested (may not succeed)
                     'success = RowaRequestProduct(SectionIDForMechDisp(d.loccode), issuetype, Identifier1, Identifier2, Trim$(d.BarCode), QuantityToIssue, QuantityIssued, QuantityStocked, strMessage)                     '20May08 added printing
                     blnRobotLabelPrint = WillRobotPrint      '20May08 CKJ
                     success = RowaRequestProduct(SectionIDForMechDisp(dlocal.loccode), issuetype, Identifier1, Identifier2, Trim$(dlocal.barcode), QuantityToIssue, QuantityIssued, QuantityStocked, strMessage, blnRobotLabelPrint)  '   "
               
                     If success Then
                           If Val(QuantityIssued) = 0 And Val(QuantityStocked) > 0 Then
                                 'If more is asked for than is held in Rowa then it picks none but returns current stock level
                                 'Therefore reissue the request using the exact stock it says it has
                                 'success = RowaRequestProduct(SectionIDForMechDisp(d.loccode), issuetype, Identifier1, Identifier2, Trim$(d.BarCode), (QuantityStocked), QuantityIssued, QuantityStocked, strMessage)                       '20May08
                                 blnRobotLabelPrint = WillRobotPrint      '20May08 CKJ
                                 success = RowaRequestProduct(SectionIDForMechDisp(dlocal.loccode), issuetype, Identifier1, Identifier2, Trim$(dlocal.barcode), (QuantityStocked), QuantityIssued, QuantityStocked, strMessage, blnRobotLabelPrint)    '   "
                                 If success And QuantityStocked = "" Then
                                       QuantityStocked = "0"
                                    End If
                              ElseIf Val(QuantityIssued) > 0 And QuantityStocked = "" Then
                                  QuantityStocked = Format$(Val(QuantityStockedInitially) - Val(QuantityIssued))
                              End If
                        Else
                           'issue request failed
                        End If
                  Else
                     'either stock enquiry failed or we asked to issue none
                  End If
               
               If Len(strMessage) Then popmessagecr "!", MachineType & ":" & crlf & strMessage        'generally only happens if comms failure
               strMessageText = strMessage                  '16Jun05 CKJ added
               'blnRobotLabelPrint = False                  '20May08 CKJ removed
               MechDispIssue = success


            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            Case "apostore"
               WillRobotPrint = blnRobotLabelPrint                                           '24jul06 CKJ take local copy
               blnRobotLabelPrint = False                                                    '            assume no print unless overridden
               If blnImmediatePick Then
                     Heap 11, gPRNheapID, "pWard", Identifier1, 0
                     Identifier2 = ""                                                        'Heap 11, gPRNheapID, "pCaseno", Identifier2, 0
                     issuetype = "Patient"
                  Else
                     Heap 11, gPRNheapID, "MechDispIdentifier1", Identifier1, 0              'ward
                     Heap 11, gPRNheapID, "MechDispIdentifier2", Identifier2, 0              'picktickno
                     Identifier1 = pad$(Identifier1, 5)
                     Identifier2 = Format$(Identifier2, "0000")
                     issuetype = "Ward"
                  End If

               'QuantityToIssue  (Stock level)  QuantityIssued  QuantityStocked
               '       0              n/a             0          some or none
               '      >0             some            some             0
               '      >0            enough           all         some or none
               
               QuantityIssued = "0"
               QuantityStocked = ""
               success = MechDispEnquiry(d, "", QuantityStockedInitially, strMessage)        'determine stock level Note: DOES NOT include pending (queued) orders so may be overestimated
               
               If success Then                                                               'machine available and talking to us
                     QuantityStocked = QuantityStockedInitially
                     If Val(QuantityToIssue) > 0 Then                                        'we want to pick some stock
                           If Val(QuantityToIssue) > Val(QuantityStockedInitially) Then
                                 QuantityToIssue = QuantityStockedInitially                  'less than we wanted, may still be zero
                              End If
      
                           If Val(QuantityToIssue) >= 1 Then                                 'Try to issue stock (may not succeed)
                                 'success = ApostoreRequestProduct(SectionIDForMechDisp(d.loccode), issuetype, Identifier1, Identifier2, Trim$(d.BarCode), QuantityToIssue, QuantityIssued, QuantityStocked, strMessage)                   '24Jul06 CKJ added printing
                                 'success = ApostoreRequestProduct(SectionIDForMechDisp(dlocal.loccode), issuetype, Identifier1, Identifier2, Trim$(dlocal.barcode), QuantityToIssue, QuantityIssued, QuantityStocked, strMessage, WillRobotPrint, dlocal.storesdescription, dlocal.Description)  XN 4Jun15 98073 New local stores description '03Jun10 CKJ Added descriptions
                                                                 success = ApostoreRequestProduct(SectionIDForMechDisp(dlocal.loccode), issuetype, Identifier1, Identifier2, Trim$(dlocal.barcode), QuantityToIssue, QuantityIssued, QuantityStocked, strMessage, WillRobotPrint, dlocal.DrugDescription)
                                 blnRobotLabelPrint = WillRobotPrint                         'return answer                                                                                                                                '   "

                                'moved decrementing QuantityStocked inside ApostoreRequestProduct so it is parsed in issue message
                                ' If success Then
                                '       QuantityStocked = Format$(Val(QuantityStockedInitially) - Val(QuantityIssued))
                                '    Else                                   'issue request failed - can only be comms since all requests are accepted even if unknown barcode or no stock is present
                                '       'Failed to issue. Already set QuantityStocked above
                                '    End If
                              Else                                                           'machine is empty
                                 strMessage = "No stock available"
                              End If
                        Else
                           'we asked to issue none (success=T)
                        End If
                  Else
                     'stock enquiry failed (success=F)
                  End If
               
               If Len(strMessage) Then popmessagecr "!", MachineType & ":" & crlf & strMessage        'generally only happens if comms failure or robot empty
               strMessageText = strMessage
               MechDispIssue = success
               

            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            Case "consis"
               If blnImmediatePick Then
                     Heap 11, gPRNheapID, "pSurname", Identifier1, 0
                     Heap 11, gPRNheapID, "pForename", strTemp, 0
                     Identifier1 = UCase$(Identifier1) & " " & strTemp           'SURNAME Forename1 Forename2   '
                                                                      
                     Heap 11, gPRNheapID, "pCaseno", Identifier2, 0
                     Heap 11, gPRNheapID, "pWard", strTemp, 0
                     'Identifier2 = Identifier2 & " " & strTemp                  'CASENO1234 WARD'       '22Jul10 CKJ RCN P00158 F0092472 (fix to F0051906)
                     strTemp = trimz(strTemp)
                     Select Case Len(strTemp)
                        Case Is < 5: strTemp = " " & pad(strTemp, 4)             ' W   '  ' WA  '  ' WAR '  ' WARD'
                        Case 5       'no action, use all five chars              'WARD5'
                        Case Else:   strTemp = Left$(strTemp, 5)                 'longer than 5 so truncate at 5
                        End Select
                     Identifier2 = Identifier2 & strTemp                         'CASENO1234 WARD' or 'CASENO1234WARD5'
                     
                     issuetype = "A"

                     'QuantityToIssue  (Stock level)  QuantityIssued  QuantityStocked
                     '       0              n/a             0          some or none
                     '      >0             some            some             0
                     '      >0            enough           all         some or none
      
                     QuantityIssued = "0"
                     QuantityStocked = ""
                     'success = MechDispEnquiry(d, "", QuantityStockedInitially, strMessage)        'determine stock level Note: DOES NOT include pending (queued) orders so may be overestimated
                     success = ConsisRequestProduct(SectionIDForMechDisp(dlocal.loccode), "B", "", "", Trim$(dlocal.barcode), "0", "0", QuantityStockedInitially, strMessage)
      
                     If success Then                                                               'machine available and talking to us
                           QuantityStocked = QuantityStockedInitially
                           If Val(QuantityToIssue) > 0 Then                                        'we want to pick some stock
                                 If Val(QuantityToIssue) > Val(QuantityStockedInitially) Then
                                       QuantityToIssue = QuantityStockedInitially                  'less than we wanted, may still be zero
                                    End If
            
                                 If Val(QuantityToIssue) >= 1 Then                                 'Try to issue stock (may not succeed)
                                       success = ConsisRequestProduct(SectionIDForMechDisp(dlocal.loccode), issuetype, Identifier1, Identifier2, Trim$(dlocal.barcode), QuantityToIssue, QuantityIssued, QuantityStocked, strMessage)
                                    Else                                                           'machine is empty
                                       strMessage = "No stock available"
                                    End If
                              Else
                                 'we asked to issue none (success=T)
                              End If
                        Else
                           'stock enquiry failed (success=F)
                        End If
                     
                     If Not Consis Is Nothing Then                                                 'deliberate closure to dump extra 'b' msgs
                           dummy = IPlinkCloseConnection(Consis)
                           '05Jun17 TH Post logs (TFS 185185)
                           PostMechDispLog
                        End If
      
                     If Len(strMessage) Then popmessagecr "!", MachineType & ":" & crlf & strMessage        'generally only happens if comms failure or robot empty
                     strMessageText = strMessage
                     MechDispIssue = success
                  
                  Else
                     '!!** Picking Ticket issue via Consis is NOT SUPPORTED
                  End If
               blnRobotLabelPrint = False


            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            Case "jvadtps"       '18May06 CKJ Real-time interface not supported
               blnRobotLabelPrint = False
               MechDispIssue = False
            
            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            Case "mts"           '25Jan08 CKJ Enquiry not supported
               blnRobotLabelPrint = False
               MechDispIssue = False
               
            '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
            Case "robopharma"    '16Dec09 CKJ
               blnRobotLabelPrint = False
               
               If blnImmediatePick Then
                     'Identifier1 & Identifier2 not used for patient/immediate pick
                     Identifier1 = ""
                     Identifier2 = ""
                     issuetype = "Patient"
                  Else
                     Heap 11, gPRNheapID, "MechDispIdentifier1", Identifier1, 0              'ward
                     Heap 11, gPRNheapID, "MechDispIdentifier2", Identifier2, 0              'picktickno
                     Identifier1 = pad$(Left$(trimz(Identifier1), 5), 5)                     'take left 5 non space chars, pad to 5 with spaces on right
                     
                     Identifier2 = trimz(Identifier2)                                        'take non space chars
                     If Not IsDigits(Identifier2) Then Identifier2 = "0"                     'set zero if non-numeric
                     Identifier2 = Format$((Val(Identifier2) Mod 10000), "00000")            'take 5 least significant digits and left zero pad to five chars
                     issuetype = "WardBox"
                  End If

               'QuantityToIssue  (Stock level)  QuantityIssued  QuantityStocked
               '       0              n/a             0          some or none
               '      >0             some            some             0
               '      >0            enough           all         some or none

               QuantityIssued = "0"
               QuantityStocked = ""
               'determine stock level Note: SHOULD include pending (queued) immediate pick orders, but not ward stock so may be overestimated
               success = RoboPharmaRequestProduct(SectionIDForMechDisp(dlocal.loccode), "Enquiry", "", "", Trim$(dlocal.barcode), "0", "0", QuantityStockedInitially, strMessage)

               If success Then                                                               'machine available and talking to us
                     QuantityStocked = QuantityStockedInitially
                     If Val(QuantityToIssue) > 0 Then                                        'we want to pick some stock
                           If Val(QuantityToIssue) > Val(QuantityStockedInitially) Then
                                 QuantityToIssue = QuantityStockedInitially                  'less than we wanted, may still be zero
                              End If
      
                           If Val(QuantityToIssue) >= 1 Then                                 'Try to issue stock (may not succeed)
                                 success = RoboPharmaRequestProduct(SectionIDForMechDisp(dlocal.loccode), issuetype, Identifier1, Identifier2, Trim$(dlocal.barcode), QuantityToIssue, QuantityIssued, QuantityStocked, strMessage)
                              Else                                                           'machine is empty
                                 'No stock available. Leave calling routine to construct message if needed.
                              End If
                        Else
                           'we asked to issue none (success=T)
                        End If
                  Else
                     'stock enquiry failed (success=F)
                  End If
               
''               If Not RoboPharma Is Nothing Then                                             'deliberate closure to dump extra 'b' msgs    !!** robopharma should not need it
''                     dummy = IPlinkCloseConnection(RoboPharma)
''                  End If

               If Len(strMessage) Then popmessagecr "!", MachineType & ":" & crlf & strMessage        'generally only happens if comms failure or robot empty
               strMessageText = strMessage
               MechDispIssue = success
                           
            Case Else
               '

            End Select
      End If

End Function

Function MechDispIssueComplete(strMessageText As String) As Integer
'09Aug05 CKJ Written. Used to close off a ward stock transfer
'            Currently needed by Apostore only
'          Return value          Success = T/F
'          strMessageText        Error text if available

Dim MachineType As String
Dim success As Integer
Dim Identifier1 As String
Dim Identifier2 As String
Dim strMessage As String
Dim iniFile As String
Dim RobotHeap As Integer
Dim SectionID As String
Dim SectionForFinalMessage As String

   MechDispIssueComplete = True     'assume OK unless proven otherwise
   strMessageText = ""
   iniFile = dispdata$ & MechDispIni
   SectionForFinalMessage = TxtD(iniFile, "common", "", "SectionForFinalMessage", 0)

   If Val(SectionForFinalMessage) Then
         MachineType = TxtD(iniFile, SectionForFinalMessage, "", "Identifier", 0)
         Select Case LCase$(MachineType)
            Case "swisslog"
               'no action
            
            Case "rowa"
               'no action

            Case "apostore"
               Heap 11, gPRNheapID, "MechDispIdentifier1", Identifier1, 0      'ward
               Heap 11, gPRNheapID, "MechDispIdentifier2", Identifier2, 0      'picktickno
               Identifier1 = pad$(Identifier1, 5)
               Identifier2 = Format$(Identifier2, "0000")
               
               'success = ApostoreRequestProduct(SectionForFinalMessage, "Final", Identifier1, Identifier2, "", "", "", "", strMessage, False)  '26jul06 ckj added print param
               'success = ApostoreRequestProduct(SectionForFinalMessage, "Final", Identifier1, Identifier2, "", "", "", "", strMessage, False, "", "") XN 4Jun15 98073 New local stores description '26jul06 ckj added print param  '03Jun10 CKJ Added empty descriptions
                           success = ApostoreRequestProduct(SectionForFinalMessage, "Final", Identifier1, Identifier2, "", "", "", "", strMessage, False, "")
         
               If Len(strMessage) Then popmessagecr "!", MachineType & ":" & crlf & strMessage        'generally only happens if comms failure
               strMessageText = strMessage
               MechDispIssueComplete = success

            Case "consis"
               'no action

            Case "jvadtps"
               'No action
            
            Case "mts"
               'No action
               
            Case "robopharma"    '16Dec09 CKJ
               'No action at this time, but may be required for speed/efficiency reasons on RoboPharma
                           
            Case Else
               '

            End Select
      End If


End Function

Function MechDispLabelCancel(ByVal MessageID As String, strMessage As String) As Integer
'20May08 CKJ written
'            Counterpart to MechDispLabelConfirm
'            Cancel production of a label, given the messageid of the original picking message
'            Can be used safely regardless of whether the interface has such a label pending, however will inform Rowa if it had agreed to print.
'            Returns success = T/F and a message if populated
'            Note that at present only the latest Rowa interfaces support this type of label printing.
'            The module level variables are cleared by this call.
'            UNCpath is removed even if set, as any pending label request will be cancelled
   
   MechDispLabelCancel = MechDispLabelHandler(MessageID, "LabelCancel", "", strMessage)

End Function

Function MechDispLabelConfirm(ByVal MessageID As String, ByVal PrintLabelUNCpath As String, strMessage As String) As Integer
'20May08 CKJ written
'            Request production of a label, given the messageid of the original picking message and the path\filename.ext of the label to print
'            Returns success = T/F and a message if populated
'            Note that at present only the latest Rowa interfaces support this type of label printing.
'            Apostore already looks for an rtf in a shared area without having to receive this type of message.
'            For this to be invoked, there already has to be a successful call requesting an issue with label where Rowa has agreed to print.
'            The results of this first call are put into module level variables ready to be used here.
'            If a label was intended but is not actually wanted, then call MechDispLabelCancel

   MechDispLabelConfirm = MechDispLabelHandler(MessageID, "LabelConfirm", PrintLabelUNCpath, strMessage)

End Function

Private Function MechDispLabelHandler(ByVal MessageID As String, ByVal strAction As String, ByVal PrintLabelUNCpath As String, strMessage As String) As Integer
'20May08 CKJ written
'            Called only by MechDispLabelConfirm & MechDispLabelCancel
'            Returns success = T/F and a message if populated
'            Note that at present only the latest Rowa interfaces support this type of label printing.
'            The module level variables are cleared by this call.
'            Action "LabelConfirm" needs the UNCpath
'            Action "LabelCancel" should have UNCpath as empty string

Dim success As Integer

   success = True                                                             'Default True, override if perform a call to robot
   strMessage = ""
   
   If m_lngRobotPrintLabelMessageID <> 0 Then                                 'pending print message (may be Apostore or Rowa)
      If m_lngRobotPrintLabelMessageID = Val(MessageID) Then                  'pending data is for the requested messageid
         If Len(m_RobotPrintLabelSection) > 0 Then                            'only Rowa fills in the config section
            'If in the future another robot uses this mechanism then look up robot type based on Section
            If strAction = "LabelConfirm" And PrintLabelUNCpath = "" Then     'error
               MechDispLog Format$(m_RobotPrintLabelSection), "E", "MechDispLabelHandler: LabelConfirm called without UNCpath"
            End If
            If PrintLabelUNCpath = "" Then strAction = "LabelCancel"          'Can't confirm unless path is given
            If strAction = "LabelCancel" Then PrintLabelUNCpath = ""          'Corollary to the above, clear before calling
            success = RowaRequestProduct(m_RobotPrintLabelSection, strAction, MessageID, PrintLabelUNCpath, "", "0", "0", "", strMessage, False)
         End If
      End If
   End If
   
   m_lngRobotPrintLabelMessageID = 0
   m_RobotPrintLabelSection = ""

   MechDispLabelHandler = success

End Function

Sub MechDispLog(ByVal interface As String, ByVal datatype As String, ByVal text As String)
'Only log if the particular datatype is marked for logging in mechdisp.ini
'[1]
'logging="SMEC"
'logfile="fullpath\filename.ext"
' where any part of the path or file name can contain [yyyy] [mm] [dd]
' and [dispdata] is replaced by the current dispdata.xxx
'for example
'   "L:\[yyyy]logs\log[mm].[dd]"              may map to  L:\2004logs\log02.14
'   "[dispdata]\swisslog\[yyyy][mm][dd].log"  may map to  L:\dispdata.123\swisslog\20040214.log
'NOTE the path must exist already - it will not be created. Remember to use 8.3 format only
'
'interface = 1, 2 etc   eg Swisslog may be 1
'datatype  = "S"tatus "M"essage "E"rror "C"onfig or blank to force logging anyway
'text      = string for logging. CRLF becomes a space, control chars are converted to <hex>
'
'24feb04 CKJ Added terminal name
'18Feb17 TH  Converted to use Database instead of Log file
'            Use the settings for logging - but not the logfile - the log file name will now
'            be general mechdisp as all the logfile name/path differentiation should be available
'            from SQL for ease of investigation (TFS 177654)

'Dim pathfile As String   '18Feb17 TH REmove Pathfile usage

'   pathfile = TxtD(dispdata$ & MechDispIni, interface, "", "logfile", 0)
'   If pathfile <> "" Then
'   05Jun17 TH Now log locally during coms and then upload to DB after connection closes (TFS 185185)

    m_strInterface = interface

    If InStr(1, TxtD(dispdata$ & MechDispIni, interface, "", "logging", 0), datatype, 1) Then
        If Trim$(m_strLoggingfile) = "" Then MakeLocalFile m_strLoggingfile 'If starting output create new local file and cache it
        replace text, crlf, " ", 0
        WriteLog m_strLoggingfile, 0, UserID, interface & " " & pad$(datatype, 1) & " " & FormatCtrlChars(Trim$(text)), True
    End If

'05Jun17 Replaced with above code (TFS 185185)

'   If InStr(1, TxtD(dispdata$ & MechDispIni, interface, "", "logging", 0), datatype, 1) Then
'      'replace pathfile, "[yyyy]", Format$(Now, "yyyy"), True
'      'replace pathfile, "[mm]", Format$(Now, "mm"), True
'      'replace pathfile, "[dd]", Format$(Now, "dd"), True
'      'replace pathfile, "[dispdata]", dispdata$, True
'
'      replace text, crlf, " ", 0
'
'      '18Feb17 TH Replace standard log right with database alternative
'      'WriteLog pathfile, 0, UserID, pad$(ASCTerminalName$(), 8) & " " & interface & " " & pad$(datatype, 1) & " " & FormatCtrlChars(Trim$(text))
'      'If Len(pathfile) > 25 Then pathfile = Right$(pathfile, 25) '18Feb17 TH It is hoped that the description of these files will be reconfigured sensibly on upgrade - No Best to make general from here
'      WriteLogSQL interface & " " & pad$(datatype, 1) & " " & FormatCtrlChars(Trim$(text)), "MechDisp", 0, 0, "", 0, lngLogID
'   End If
      
'   End If

End Sub

Function MechDispNameByLocation(ByVal LocationCode As String) As String
'09Aug05 CKJ Written
'            Given d.loccode, return the name of the robot which serves that location
'            If there is no robot configured then return ""
'            If the robot has a display name return it, otherwise return the internal name for the robot

Dim strSectionID As String
Dim strName As String

   strName = ""
   strSectionID = SectionIDForMechDisp(LocationCode)           'get sectionID or ""
   If Len(strSectionID) Then
         strName = MechDispNameBySectionID(strSectionID)       'get name from sectionID
      End If
   MechDispNameByLocation = strName

End Function

Function MechDispNameBySectionID(ByVal strSectionID As String) As String
'09Aug05 CKJ Written
'            Given a valid section ID for mechdisp.ini, return the name of the robot which serves that location
'            If there is no robot configured then return ""
'            If the robot has a display name return it, otherwise return the internal name for the robot

Dim strName As String
Dim strFile As String

   strFile = dispdata & MechDispIni
   strName = TxtD(strFile, strSectionID, "", "Identifier", 0)       'read the internal name of the robot, if any
   strName = TxtD(strFile, strSectionID, strName, "DisplayName", 0) 'replace with display name, if any
   MechDispNameBySectionID = strName

End Function

Function MechDispPackerSection(MachineName As String, DisplayName As String) As Integer
'18May06 CKJ written
'            returns MechDisp section if a batch type tablet packer is present (Baxter ATC, JVM ATDPS)
'            and name of machine if present

Dim Section As Integer
Dim iniFile As String

   Section = 0
   MachineName = "<UNKNOWN>"
   iniFile = dispdata$ & MechDispIni
   If Val(TxtD(iniFile, "", "0", "total", 0)) > 0 Then
      Section = Val(TxtD(iniFile, "", "", "PackerSection", 0))
      If Section Then
         MachineName = TxtD(iniFile, Format$(Section), "<UNKNOWN>", "Identifier", 0)
         DisplayName = TxtD(iniFile, Format$(Section), MachineName, "DisplayName", 0)
         MechDispPackerSection = Section
      End If
   End If

End Function

Function MechDispSendProductDataSupported(dlocal As DrugParameters, MachineType As String) As Boolean
'12Jul12 CKJ written
'           Returns T/F indicating whether product information message is supported, along with machine name
'           Currently supported by Apostore & Rowa

Dim supported As Boolean

   supported = False
   
   If LocationForMechDisp(dlocal.loccode, MachineType) Then
         Select Case LCase$(MachineType)
            Case "swisslog"
            Case "rowa":     supported = True
            Case "apostore": supported = True
            Case "consis"
            Case "jvadtps"
            Case "mts"
            Case "robopharma"
            Case Else
               '
            End Select
      End If
   
   MechDispSendProductDataSupported = supported

End Function

Function MechDispSendProductData(dlocal As DrugParameters, ByVal ItemDescription As String, MachineType As String, strMessage As String) As Integer
'12Jul12 CKJ written
'           Send product information
'           Currently supported by Apostore & Rowa
'           Rowa requires max 40 character description, so pass in as param. Not needed for Apostore as dlocal is used, so pass "".

Dim success As Integer
Dim dummy As Integer
Dim QuantityStocked As String

   success = False
   strMessage = ""
   
   If LocationForMechDisp(dlocal.loccode, MachineType) Then
         Select Case LCase$(MachineType)
            Case "swisslog"
               success = False
            
            Case "rowa"
               'caution; preparse description before calling: 40 chars max
               success = RowaRequestProduct(SectionIDForMechDisp(dlocal.loccode), "ProductData", ItemDescription, Trim$(d.PrintformV), Trim$(dlocal.barcode), Format$(d.convfact), "", "", strMessage, False)
        
            Case "apostore"
               'success = ApostoreRequestProduct(SectionIDForMechDisp(dlocal.loccode), "Enquiry", "", "", Trim$(dlocal.barcode), "0", "0", QuantityStocked, strMessage, False, dlocal.storesdescription, dlocal.Description)  XN 4Jun15 98073 New local stores description
                           success = ApostoreRequestProduct(SectionIDForMechDisp(dlocal.loccode), "Enquiry", "", "", Trim$(dlocal.barcode), "0", "0", QuantityStocked, strMessage, False, dlocal.DrugDescription)
            
            Case "consis"
               success = False
            
            Case "jvadtps"
               success = False

            Case "mts"
               success = False
               
            Case "robopharma"
               success = False
               
            Case Else
               success = False
            
            End Select
      End If
   
   MechDispSendProductData = success


End Function


Sub PadHeapField(ByVal HeapID As Integer, ByVal iniFile As String, ByVal iniSection As String, ByVal fieldname As String)
'23Jun06 CKJ Given a filled Heap, an ini file and an item on the heap, pad/truncate the value and
'            put it back on the heap if PAD(<fieldname>)=n(n...) is found in the ini file.
'            For example, if item DrugData="ABCDEF" is present on the heap then the following transformations apply
'              RPAD(Drugdata)="6"     =>   "ABCDEF"
'              LPAD(Drugdata)="6"     =>   "ABCDEF"
'              RPAD(Drugdata)="10"    =>   "ABCDEF    "
'              LPAD(Drugdata)="10"    =>   "    ABCDEF"
'              RPAD(Drugdata)="4"     =>   "ABCD"
'              LPAD(Drugdata)="4"     =>   "ABCD"
'
'            No trimming is performed before padding so leading/trailing spaces originally given are retained as follows
'            For example, if item DrugData=" ABC " is present on the heap then the following transformations apply
'              RPAD(Drugdata)="6"     =>   " ABC  "
'              LPAD(Drugdata)="6"     =>   "  ABC "
'              RPAD(Drugdata)="10"    =>   " ABC      "
'              LPAD(Drugdata)="10"    =>   "      ABC "
'              RPAD(Drugdata)="4"     =>   " ABC"
'              LPAD(Drugdata)="4"     =>   " ABC"
'            Note that left and right padding applies space before and after the text
'            But truncation is always applied to the right hand end of the text
'            Valid padding is 1 to 32767. Outside this range values are ignored.
'            However the length of the original string plus padding length cannot exceed 32767.
'            Fractions are first converted to an integer
'
'            If both RPAD and LPAD are present then RPAD is applied first followed by LPAD
'            For example, if item DrugData="ABC" is present on the heap and both transformations are applied in sequence
'              RPAD(Drugdata)="4"     =>   "ABC "
'            then
'              LPAD(Drugdata)="6"     =>   "  ABC "
'
'            If the item is not on the heap, then it is created, containing only spaces.

Dim strVal As String
Dim strlen As String
Dim valid As Integer

   Heap 11, HeapID, fieldname, strVal, valid            'may be blank

   strlen = TxtD(iniFile, iniSection, "", "RPAD(" & fieldname & ")", 0)
   If IsDigits(strlen) Then
      Select Case Val(strlen)
         Case 1 To 32767
            strVal = pad((strVal), Int(Val(strlen)))                             'right pad, left justify
         End Select
   End If

   strlen = TxtD(iniFile, iniSection, "", "LPAD(" & fieldname & ")", 0)
   If IsDigits(strlen) Then
      Select Case Val(strlen)
         Case 1 To 32767
            strVal = Right$(Space$(Int(Val(strlen))) & strVal, Int(Val(strlen))) 'left pad, right justify
         End Select
   End If

   Heap 10, HeapID, fieldname, strVal, valid            'may still be blank

End Sub

Private Function RowaInitialise(ByVal ForceReset As Integer) As Integer
'12May04 CKJ written
'            If ForceReset=True then an existing link will be broken & reinitialised
'            otherwise an exiting link is simply used.

Dim dummy As Integer

   If ForceReset And Not ROWA Is Nothing Then
         dummy = RowaTerminate()
      End If
   
   If ROWA Is Nothing Then
         Set ROWA = New frmIPlink
         Load ROWA
        ROWA.Caption = "Robot Interface"
      End If

   RowaInitialise = True

End Function

Private Function RowaRequestProduct(ByVal SectionID As String, ByVal strMessageType As String, ByVal Identifier1 As String, ByVal Identifier2 As String, ByVal ProductID As String, ByVal QuantityToIssue As String, QuantityIssued As String, QuantityStocked As String, strMessageText As String, intRobotPrint As Integer) As Integer
'12May04 CKJ Based on Swisslog design
'16Jun04 CKJ Added strMessageText parameter
'12Jul12 CKJ Added ProductData message (ZDI)

'Public function
'Given a number of whole packs to issue (must not be negative) and a barcode,
'contact the Rowa, send message if possible, and return details of product or failure code
'SectionID is the MechDisp.ini section for the product requested
'                                                                             -----------Success----------------------- -----------Failure------------
' strMessageType Identifier1 Identifier2 ProductID QuantityToIssue RobotPrint QuantityIssued QuantityStocked RobotPrint QuantityIssued QuantityStocked   Implemented
'  Patient          name        caseno    EAN8/13       1 to n       T / F       0 to n          -n to n       T / F      unchanged      unchanged          Yes
'  Ward             ward      picktickno  EAN8/13       1 to n       T / F       0 to n          -n to n       T / F      unchanged      unchanged          Yes
'  Enquiry         optional    optional   EAN8/13       ignored       n/a        unchanged       -n to n     unchanged    unchanged      unchanged          Yes
'  Enquiry         optional    optional   EAN~EAN       ignored       n/a        unchanged         n~n       unchanged    unchanged      unchanged          No
'  LabelConfirm   MessageID    UNC path    blank        blank                    unchanged       unchanged                unchanged      unchanged          Yes
'  LabelCancel    MessageID     blank      blank        blank                    unchanged       unchanged                unchanged      unchanged          Yes
'  ProductData   description    units      EAN13       packsize       n/a        unchanged       unchanged   unchanged    unchanged      unchanged          Yes
'
'For message type 'Label', setting UNCpath="" cancels the pending label request by setting ZRL seq2 from 2 (label data) to 0 (just pick without label)
'
'All quantities are currently positive integers, although part packs may be supported by Rowa in due course
'
'return value is success T/F
'
'MSA|AA|435672||2|123|'          patient issue or stock issue, issued 2 with 123 left afterwards
'MSA|AA|435672|||123|'           single item enquiry, qty issued is blank, qty in stock
'MSA|AA|435672|||123~456~678|'   multiple item enquiry, qty issued is blank, qty in stock tilda separated

'20May08 CKJ added:
'            disconnect delay
'            repeat read on low messageid
'            robot labelling
'17jul12 CKJ Added ZDI product information message
'20Feb17 TH Replaced use of locking details file so we can use the message as per the old files (TFS 177820)

Dim strMessage As String
Dim strReply As String
Dim RobotHeap As Integer
Dim intSuccess As Integer
Dim dummy As Integer
Dim Numoflines As Integer
Dim intloop As Integer
Dim strReplyText As String
Dim strTemp As String
Dim iniFile As String
Dim strQtyIssued As String
Dim strQtyStocked As String
Dim strReplyMID As String
Dim MessageID As Long
Dim blnBusy As Integer
Dim strReplyType As String
Dim strReplyStatus As String
Dim strText As String
Dim numofsubfields As Integer
Dim strStatus As String

Dim WillRobotPrint As Integer
Dim AllowRepeatForLowMessageID As Integer       '20May08 CKJ
Dim RepeatForLowMessageID As Integer            '   "
Dim strReplyLabel As String                     '   "    holds labelling element from MSA
Dim UNCpath As String                           '   "    optional replace for reserved \ character
Dim strWas As String                            '   "
Dim strNow As String                            '   "
Dim DelAll As Boolean                           '17Jul12 CKJ Delete All HL7 separators y/n (default is yes)

   intSuccess = False
   MessageID = 0
   iniFile = dispdata$ & MechDispIni
   strMessageText = ""
   strMessageType = LCase$(strMessageType)

   WillRobotPrint = intRobotPrint                        '20May08 CKJ added block
   intRobotPrint = 0
   If Left$(strMessageType, 5) <> "label" Then
      m_lngRobotPrintLabelMessageID = 0
      m_RobotPrintLabelSection = ""
   End If

   If Not blnBusy Then
         blnBusy = True

         strTemp = terminal("RowaTerminalName", "<INVALID>")
         strMessage = "[MSG" & strMessageType & "]"                        'MessageType = Patient, Ward, Enquiry etc as above
         ParseCtrlChars iniFile, SectionID, strMessage, 0

         AllowRepeatForLowMessageID = TrueFalse(TxtD(iniFile, SectionID, "N", "AllowRepeatForLowMessageID", False))     '20May08 CKJ
      
         If strTemp = "<INVALID>" Then
               'no action: not a Rowa enabled terminal
      
            ElseIf strMessage = "[MSG" & strMessageType & "]" Then
               strMessageText = "Unsupported message type: " & strMessageType
               MechDispLog SectionID, "E", strMessageText
            
            'ElseIf Len(ProductID) = 0 Then                                                  '20May08 CKJ
            ElseIf Len(ProductID) = 0 And Left$(strMessageType, 5) <> "label" Then   'OK for labels
               'no action: no barcode provided
            ElseIf Val(Identifier1) = 0 And Left$(strMessageType, 5) = "label" Then  '   "
               'no action: no MessageID provided
               
            ElseIf Len(Identifier1) = 0 And strMessageType = "productdata" Then      '17Jul12 CKJ added block; ZDI checks
               'no action: no description provided
            ElseIf Len(QuantityToIssue) = 0 And strMessageType = "productdata" Then
               'no action: no pack size provided
            ElseIf Len(Identifier2) = 0 And strMessageType = "productdata" Then
               'no action: no units provided
               
            ElseIf Val(SectionID) = 0 Then
               strMessageText = "Invalid SectionID: " & SectionID
               MechDispLog SectionID, "E", strMessageText
      
            Else
               Heap 1, RobotHeap, "Rowa Data Heap", "", intSuccess
               If Not intSuccess Then strMessageText = "Failed to allocate data heap for Rowa"

            End If

         If intSuccess Then                                                               '16jun04 CKJ added block to acquire lock & update info file
               m_blnEnableRowaLocking = TrueFalse(TxtD(iniFile, SectionID, "T", "EnableRowaLocking", False))      '20May08 CKJ added option - Rowa labeller allows concurrent connections
               If m_blnEnableRowaLocking Then                                                                     '   "
                  'AcquireLock dispdata$ & ROWALCK, 2, intSuccess                                                  '20May08 CKJ Was "\Rowa"
                  AcquireLock dispdata$ & ROWALCK, 2, intSuccess, strMessageText  '20Feb17 TH Replaced above so we can use the message as per the old files (TFS 177820)
                  If Not intSuccess Then
                     'GetTextFile dispdata$ & "\ROWAlink.txt", strText, 0  '20Feb17 TH Removed
                     'If Len(strText) Then popmessagecr "#", "ROWA is in use:" & crlf & crlf & strText & crlf & "Check with user of the first terminal as this is where the ROWA is locked"
                     'If Len(strText) Then strMessageText = crlf & "Check with user of this terminal as this is where the ROWA is locked:" & crlf & strText
                     If Len(strText) Then strMessageText = crlf & strMessageText & crlf & strText '20Feb17 TH Replaced above
                     strText = ""
                  End If
                  'strStatus = Iff(intSuccess, "acquired", "rejected")  '20Feb17 TH Removed lines - we dnt use the files anymore
                  'WriteRowaLink intSuccess, strStatus                  '  "
                  'Rowa.lblStatus.Caption = "Lock " & strStatus
               End If

               If intSuccess Then
                     
                     '!!**
                     'If InStr(UCase$(Command$), "/ROWAPAUSE") Then popmessagecr "!", "RowaLink locked - continue when ready"      '!!** TESTBED
                     
                     
                     GetPointerSQL dispdata$ & "\Rowa.dat", MessageID, True                        'only get number once lock is granted
                     Select Case MessageID
                        Case Is < 1, Is > 99999                                                 'NB 5 digits only
                           GetPointerSQL dispdata$ & "\Rowa.dat", 1, 2
                           MessageID = 1
                        End Select
            
                     Heap 10, RobotHeap, "yyyymmddNow", Format$(Now, "yyyymmdd"), False      '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "hhnnssNow", Format$(Now, "hhnnss"), False          '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "MessageID", Format$(MessageID), False              '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "IssueQty", QuantityToIssue, False                  '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "EANcode", ProductID, False                         '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "TerminalName", strTemp, False                      '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "RowaChuteID", terminal("RowaChuteID", "0"), False  '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "UserID", UserID$, False                            '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "ToName", Identifier1, False                        '20May08 CKJ was intSuccess
                     Heap 10, RobotHeap, "ToCode", Identifier2, False                        '20May08 CKJ was intSuccess

                     UNCpath = Identifier2                                                   '20May08 CKJ optional; UNCpathReplace="\,\E\" or  UNCpathReplace="\,/"
                     strWas = TxtD(iniFile, SectionID, "", "UNCpathReplace", False)          '
                     If InStr(strWas, ",") = 2 And Len(strWas) > 2 Then                      'If used, must be "<one char><comma><one or more chars>"
                        strNow = Mid$(strWas, 3)                                             '\E\'
                        strWas = Left$(strWas, 1)                                            '\'
                        replace UNCpath, strWas, Nul, 0                                      'replace with nul first to allow \ => \E\
                        replace UNCpath, Nul, strNow, 0                                      '
                     End If                                                                  '
                     Heap 10, RobotHeap, "UNCpath", UNCpath, False                           '
                     Heap 10, RobotHeap, "ZRLFormat", Iff(Len(UNCpath), "2", "0"), False     '2=Confirm label & issue  0=Cancel label but still issue
                     
                     '20May08 CKJ added block:
                     '1' Free dispensing
                     '2' Ward box picking
                     '8' Free dispensing with ZRL label
                     '9' Ward box picking with ZRL label
                     Select Case strMessageType
                        Case "patient": Heap 10, RobotHeap, "PickingType", Iff(WillRobotPrint, "8", "1"), False
                        Case "ward":    Heap 10, RobotHeap, "PickingType", Iff(WillRobotPrint, "9", "2"), False
                        Case Else:      Heap 10, RobotHeap, "PickingType", "", False
                        End Select
                           
                     '12Jul12 CKJ Added ZDI elements for ProductData message
                     'MSGProductData = "[MSHstandard][13][ZDIProduct][13]"
                     'ZDIProduct = "ZDI|[PackBarcode]^[ItemDescription]^[PackQuantity]^[ItemForm]^[EANcode]^[CDflag]^[FridgeFlag]"
                     DelAll = TrueFalse(TxtD(iniFile, SectionID, "Y", "HL7DeleteAllSeparators", False))     'default is delete all  |^~\&  not just  |^
                     Heap 10, RobotHeap, "PackBarcode", "", False                                'actual barcode from side of pack - not implemented
                     Heap 10, RobotHeap, "ItemDescription", HL7safe(Identifier1, DelAll), False  'd.description shortened to 40 chars max, HL7 chars removed
                     Heap 10, RobotHeap, "PackQuantity", HL7safe(QuantityToIssue, DelAll), False 'd.convfact, 10 chars max, HL7 chars removed
                     Heap 10, RobotHeap, "ItemForm", HL7safe(Identifier2, DelAll), False         'd.printformv, 10 chars max, HL7 chars removed
                     Heap 10, RobotHeap, "CDflag", "false", False                                'set as false - let Rowa handle this
                     Heap 10, RobotHeap, "FridgeFlag", "false", False                            'set as false - let Rowa handle this

                     ParseItems RobotHeap, strMessage, False
                     
                     LastReply True, ""                                                '20May08 CKJ
                     intSuccess = RowaSendMessage(SectionID, strMessage)               'Actually send the message (Loads the IPlink form if not already present)
                     
                     If intSuccess Then
                           Do                                                          '20May08 CKJ
                              intSuccess = False
                              RepeatForLowMessageID = False                            '20May08 CKJ

                              ROWA.lblMessage.Caption = TxtD(iniFile, SectionID, "  Waiting for reply from Rowa... ", "WaitingMsg", False)
                              'LastReply True, ""                                      '20May08 CKJ moved above
                              dummy = RowaShow(True)                                   'modal show while waiting for reply
                              '...stay as modal form until reply received or user Cancels...
                              'LastReply False, strReply                               '20May08 CKJ
                              LastReply 2, strReply                                    '20May08 CKJ read reply & clear buffer
                                                                    
                              If m_blnEnableRowaLocking Then                           '20May08 CKJ added
                                 dummy = IPlinkCloseConnection(ROWA)
                                 waitforticks Val(TxtD(iniFile, SectionID, "2", "RowaDisconnectDelay", False))  '20May08 CKJ added option - Rowa may take some time to disconnect properly
                                 ROWA.lblStatus.Caption = "Lock Released" '05Jun17 Moved from above to ensure log can be written inside lock
                                 '05Jun17 TH Post logs
                                 PostMechDispLog
                                 AcquireLock dispdata$ & ROWALCK, 0, 0                 '16jun04 CKJ added block to release lock   '20May08 CKJ Was "\Rowa"
                                 'WriteRowaLink False, "released"                       '            & update info file '20Feb17 TH removed
                                 'ROWA.lblStatus.Caption = "Lock Released"
                              End If
                        
                              If Len(strReply) Then
                                    dummy = RowaShow(False)                             'non modal show
                                    ROWA.lblMessage.Caption = Chr$(12)                  'clear window
                                    
                                    'dismantle reply
                                    replace strReply, Chr$(&HB), "<B>", 0
                                    replace strReply, Chr$(&HD), "<D>", 0
                                    replace strReply, Chr$(&H1C), "|", 0
                                    ReDim lines$(50)
                                    deflines strReply, lines$(), "|(*)", 1, Numoflines
                                    
                                    strReplyText = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyText", False)))
                                    'strQtyIssued = lines$(Val(txtd(inifile, SectionID, "", "ReplyQuantityIssued", False)))
                                    'strQtyStocked = lines$(Val(txtd(inifile, SectionID, "", "ReplyQuantityStocked", False)))
                                    strReplyMID = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyMessageID", False)))
                                    Heap 10, RobotHeap, "ReceivedText", strReplyText, False      '20May08 CKJ was intSuccess
                                    Heap 10, RobotHeap, "ReceivedMessageID", strReplyMID, False      '20May08 CKJ was intSuccess
                                    Heap 10, RobotHeap, "CR", crlf, False      '20May08 CKJ was intSuccess
                                    
                                    strReplyType = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyType", False)))       '<B>MSA
                                    strReplyStatus = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyStatus", False)))   'AA
                                    Heap 10, RobotHeap, "ReplyType", strReplyType, False      '20May08 CKJ was intSuccess
                                    Heap 10, RobotHeap, "ReplyStatus", strReplyStatus, False      '20May08 CKJ was intSuccess
                                    
                                    strReplyLabel = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyLabel", False)))     '20May08 CKJ
                                    Heap 10, RobotHeap, "ReplyLabel", strReplyLabel, False                             '0' will label  '1^message' will not label

                                    ReDim subfields$(50)
                                    deflines strReplyText, subfields$(), "^(*)", 1, numofsubfields
         
                                    If InStr(strReply, TxtD(iniFile, SectionID, "", "ReplyPreamble", False)) <> 1 Then    'invalid reply
                                          strText = "[InvalidMsg]"                                       '" Reply is not a valid message"
                                       
                                       ElseIf CDbl(strReplyMID) <> MessageID Then
                                          strText = "[IncorrectIDMsg]"                                   '" Reply is not for this message[cr] - Message ID expected is [MessageID][cr] - Message ID in reply is [ReceivedMessageID]"
                                          If AllowRepeatForLowMessageID Then                             '20May08 CKJ Added block
                                             If CDbl(strReplyMID) < MessageID Then                       '
                                                RepeatForLowMessageID = True                             '
                                                strText = "[IncorrectIDMsgRetry]"                        '
                                             End If                                                      '
                                          End If                                                         '
                                       
                                       Else   'looks OK to parse
                                          Select Case strReplyType
                                             Case "<D>MSA"    'Message Acknowledgement
                                                Select Case strReplyStatus
                                                   Case "AA"  'Order sent to Speedcase                                 MSA AA OK Free dispensing
                                                      strQtyIssued = QuantityToIssue                                   'inferred because it was accepted for issue
                                                      Heap 10, RobotHeap, "QtyIssued", strQtyIssued, False      '20May08 CKJ was intSuccess
                                                      strText = "[IssuedMsg]"

                                                      If Left$(strReplyLabel, 1) = "0" Then                     '20May08 CKJ check if robot will label
                                                         m_lngRobotPrintLabelMessageID = MessageID              '
                                                         m_RobotPrintLabelSection = SectionID                   '            set the sectionID so we can use it in MechDispLabelHandler
                                                         intRobotPrint = True
                                                      End If
                                                      
                                                      intSuccess = True
                                                                                                                                                                                       
                                                   Case "AE"  'Invalid HL7 message format
                                                      strText = "[InvalidHL7Msg]"
         
                                                   Case "AQ"  'Quantity asked > Quantity in stock                      MSA AQ 123
                                                      strQtyIssued = "0"
                                                      strQtyStocked = strReplyText
                                                      Heap 10, RobotHeap, "QtyIssued", strQtyIssued, False      '20May08 CKJ was intSuccess
                                                      Heap 10, RobotHeap, "QtyStocked", strQtyStocked, False      '20May08 CKJ was intSuccess
                                                      strText = "[InsufficientMsg]"
                                                      intSuccess = True                                           '17Jun08 CKJ added
                                                   Case "AT"  'Item taken into account by IT System
                                                   
                                                   Case "AD"  'Valid delivery number
                                                   
                                                   Case "AF"  'Invalid delivery number
                                                   
                                                   Case "AX"  'Drug information available
                                                   
                                                   Case "AN"  'No drug information available
                                                   
                                                   Case "EA"  'Drug input (ZEN)
                                                   
                                                   Case "EB"  'Drug not input (ZEN)
                                                   
                                                   Case "AS"  'Reply to stock level request
                                                      If numofsubfields >= 2 Then
                                                            If UCase$(subfields$(2)) = "X" Then
                                                                  strText = "[UnknownBarcodeMsg]"
                                                               Else
                                                                  strQtyStocked = subfields$(2)                      '5011641800534^3'
                                                                  '!!** Handle part packs here
                                                                  strText = "[StockedMsg]"
                                                                  intSuccess = True
                                                               End If
                                                            intSuccess = True                                           '17Jun08 CKJ added
                                                         Else
                                                            strText = "[InvalidSLMsg]"
                                                         End If
                                                      Heap 10, RobotHeap, "QtyStocked", strQtyStocked, False      '20May08 CKJ was intSuccess

                                                   Case "LA"  'Label accepted                                     '20May08 CKJ added block
                                                      strText = "[LabelAcceptedMsg]"
                                                      intSuccess = True
                                                   
                                                   Case "LE"  'Label error                                        '20May08 CKJ added block
                                                      'strReplyText holds 'x^message' where x is error code 1-6
                                                      '1 ZRA not found
                                                      '2 ZRA already completed
                                                      '3 Labelling system disabled
                                                      '4 Labelling system error
                                                      '5 Labelling disabled for this item
                                                      '6 Unsupported format
                                                      'we could choose to still print locally in these cases
                                                      strText = "[LabelRejectedMsg]"
                                                      
                                                   Case "DI"   '12Jul12 CKJ ZDI Drug Information
                                                      intSuccess = True    'no message or other data in reply, receipt is success enough
                                                      
                                                   Case Else       'unknown message type within acknowledgement
                                                      strText = "[InvalidReplyStatusMsg]"
                                                   End Select
                                                
                                                If Not intSuccess And Len(strText) = 0 Then
                                                      strText = "[RejectedMsg]"                                      '" Request Rejected: [cr] - [ReceivedText]"
                                                   End If
         
                                             Case Else             'unknown reply type - not an acknowledgement
                                                strText = "[InvalidReplyMsg]"
                                             End Select
                                                   
                                          QuantityIssued = Trim$(strQtyIssued)
                                          QuantityStocked = strQtyStocked
                                       End If
         
                                    ParseCtrlChars iniFile, SectionID, strText, False
                                    ParseItems RobotHeap, strText, False
                                    ROWA.lblMessage.Caption = strText
                                    PostMechDispLog '07Jun17 TH Log dump - extra write after exiting lock. This is heavy as it will cach and then read from file, but best to stick in same mechdisp paradigm and we have left robot comms.
                                 Else         'user cancelled
                                    'no action, return failure code
                                 End If
                           Loop While RepeatForLowMessageID                            '20May08 CKJ Allow another message to be read
            

                        Else
                           If m_blnEnableRowaLocking Then                              '20May08 CKJ added
                              waitforticks 2                                           '20May08 CKJ added
                              ROWA.lblStatus.Caption = "Lock Released"  '07Jun17 TH Moved from below to capture in log
                              PostMechDispLog '07Jun17 TH Log dump !
                              AcquireLock dispdata$ & ROWALCK, 0, 0                    '16jun04 CKJ added block to release lock   '20May08 CKJ Was "\Rowa"
                              'WriteRowaLink False, "released"                          '            & update info file '05Jun17 TH Removed - dont use files
                              'ROWA.lblStatus.Caption = "Lock Released"
                           End If
                           
                           'no action, return failure code
                        End If
      
                     Heap 2, RobotHeap, "", "", False                                                 '12mar04 CKJ changed from intsuccess as this would override the RowaSendMessage return value
                  
                  Else  'could not acquirelock
                     'message already done above
                  End If
            Else
               'messages already set above
            End If
         
         blnBusy = False
      End If

   RowaRequestProduct = intSuccess

End Function

Private Function RowaSendMessage(ByVal SectionID As String, ByVal strMessage As String) As Integer
'12May04 CKJ
'Never call this directly - only call via RowaRequestProduct
'otherwise the busy flag would be bypassed
'16oct06 CKJ Changed DoEvents to DoSaferEvents
'06Mar07 CKJ Added extra checks

Dim success As Integer
Dim AfterNSeconds As Variant
Dim iniFile As String

   success = False

   RowaSendMessage = False

   If strMessage <> "" And Val(SectionID) > 0 Then
         success = RowaShow(False)
         
         '06Mar07 CKJ Added extra checks
         If Not success Then
            popmessagecr ".", "ROWA Interface could not be started"
            
         ElseIf ROWA.mobjIPClient Is Nothing Then
            ROWA.lblStatus.Caption = IPclientMissingMsg
            ROWA.lblMessage.Caption = IPclientMissingMsg
            
         Else
            iniFile = dispdata$ & MechDispIni
         
            ROWA.lblMessage.Caption = Chr$(12)
            If Not ROWA.mobjIPClient.WinsockLoaded Then
   '11feb07               ROWA.mobjIPClient.WinsockLoaded = True
               End If
            
            ROWA.mobjIPClient.EOL = Chr$(&H1C) & Chr$(&HD)
            
            'close old connections (if any)
            '!!** should not be needed in current implementation
            '     may be needed if multiple connections to several machines
            
            If success Then
                  'attempt connection
                  If Not ROWA.mobjIPClient.Connected Then
                        ROWA.Tag = SectionID
                        ROWA.mobjIPClient.RemoteHost = TxtD(iniFile, SectionID, "127.0.0.1", "IPaddress", False)
                        ROWA.mobjIPClient.RemotePort = TxtD(iniFile, SectionID, "5200", "IPport", False)
                        ROWA.lblStatus.Caption = "Connecting to " & ROWA.mobjIPClient.RemoteHost & " port " & ROWA.mobjIPClient.RemotePort & " ..."
                        ROWA.mobjIPClient.Connected = True
                     End If
                  
                  'wait until the connection is achieved (timeout in 10 seconds)
                  AfterNSeconds = Now + CDbl(TxtD(iniFile, SectionID, "10", "timeout", False)) / (3600# * 24#)
                  Do Until Now > AfterNSeconds
                     If ROWA.mobjIPClient.Connected Then Exit Do
                     DoSaferEvents 1                               '16oct06 CKJ was DoEvents, but this allowed main prog to continue
                  Loop
                  
                  If Not ROWA.mobjIPClient.Connected Then
                        ROWA.lblStatus.Caption = "Connection timed out."
                     Else
                        ROWA.lblStatus.Caption = "Send: " & FormatCtrlChars(strMessage)
                                    
                        'send the data
                        ROWA.mobjIPClient.DataToSend = strMessage
                        RowaSendMessage = True
                     End If
               End If
         End If
      End If

End Function

Private Function RowaShow(ByVal SetModal As Integer) As Integer
'If the form is not loaded, then load and show
'If the form is loaded, then hide if necessary and show
'If already loaded and on show with the correct modaility, do nothing
'SetModal = -1 True                          modal
'            0 False (or any other integer)  nonmodal
'            1                               don't change mode if set, use non modal if not set

Dim IsModal As Integer
Dim dummy As Integer
Dim blnHide As Integer
   
   RowaShow = False
   IsModal = (SetModal = True)                   'only set modal if specifically requested
   If ROWA Is Nothing Then
         dummy = RowaInitialise(False)
         IsModal = True
         ROWA.cmdCancel.Visible = IsModal
         ROWA.Timer1.Enabled = True
      End If
   
   If Not ROWA Is Nothing Then
         If ROWA.Visible Then
               If SetModal = 1 Then IsModal = (ROWA.cmdCancel.Tag = "-1")         'set modal based on existing form
               blnHide = False
               If ROWA.cmdCancel.Tag = "-1" And Not IsModal Then blnHide = True   'Modal wanted, not modal now
               If ROWA.cmdCancel.Tag = "0" And IsModal Then blnHide = True        'Non modal wanted, modal now ** should not be necessary of course
               If ROWA.cmdCancel.Tag = "0" And Not IsModal Then blnHide = True    'Non modal wanted, non modal now BUT might need to auto hide -2 because of existing modal form
               If blnHide Then
                     IPlinkHide ROWA         'hide first to change modality
                  End If
            End If
         
         RowaShow = True
         If Not ROWA.Visible Then
               ROWA.cmdCancel.Visible = IsModal
               ROWA.cmdCancel.Tag = Format$(IsModal)
               On Error GoTo RowaShow_Err
               ROWA.Show Iff(IsModal, 1, 0), OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form          'Show
            End If
      End If

Exit Function

RowaShow_Err:
   Select Case Err
      'Can't display non-modal form when modal form showing
      '12mar07 CKJ Added: Non-modal forms cannot be displayed in this host application from an ActiveX DLL, ActiveX Control, or Property Page. (406)
      Case 401, 406
         IPlinkHide ROWA
         IsModal = True
         ROWA.cmdCancel.Visible = IsModal
         ROWA.cmdCancel.Tag = "-1"
         IPlinkResize ROWA
         ROWA.Timer1.Enabled = True                  'show modally then hide immediately
         Resume

      Case Else
         popmessagecr ".", "Procedure RowaShow Error:" & crlf & Error & " (" & Format$(Err) & ")"
         Resume Next

      End Select

Resume Next
      
End Function

Private Function RowaTerminate() As Integer
'12May04 CKJ Cancel any current connection, close the IP port and close the form

Dim dummy As Integer
Dim blnLinked As Integer
Dim done As Integer

   If Not ROWA Is Nothing Then
      If Not ROWA.mobjIPClient Is Nothing Then        '06Mar07 CKJ added
         If ROWA.mobjIPClient.WinsockLoaded Then
               If ROWA.mobjIPClient.Connected Then
                     blnLinked = True                                            'remember state purely to update the RowaLink file later
                  End If
            End If
         End If

         dummy = IPlinkCloseConnection(ROWA)

         Unload ROWA                    'this closes current connection if any
         Set ROWA = Nothing
         '05Jun17 TH Post logs
         PostMechDispLog
      End If

   If m_blnEnableRowaLocking Then                                                   '20May08 CKJ added
      'release lock & update info file
      AcquireLock dispdata$ & ROWALCK, 0, done                                      'Attempt to release lock anyway - no harm if not locked   '20May08 CKJ Was "\Rowa"
      'If blnLinked Then WriteRowaLink False, "released"                             'Only write to file if we were connected, regardless of lock state  '05Jun17 TH Dont write to file
   End If

   RowaTerminate = True                 'may return error indication

End Function

Function SectionIDForMechDisp(ByVal LocationCode As String) As String
'Given locationcode, return the ID number as defined in MechDisp.ini
'This number is used as the section identifier, eg [1]
'Returns "" if item is not for mechanical dispensing

'03Jun10 CKJ Moved Exit For inside the IF to allow second & subsequent robot sections to be used (RCN P0158 F0083830)

Dim numrobots As Integer
Dim intRobot
Dim tmp As String

   SectionIDForMechDisp = ""
   For intRobot = 1 To Val(TxtD(dispdata$ & MechDispIni, "", "0", "total", 0))
      tmp = UCase$(Trim$(TxtD(dispdata$ & MechDispIni, Format$(intRobot), "", "LocationCode", 0)))
      If Len(tmp) Then
         If UCase$(Trim$(LocationCode)) = tmp Then          'product belongs here, but where is here?
            SectionIDForMechDisp = Format$(intRobot)
            Exit For          '03Jun10 CKJ Moved inside the IF (RCN P0158 F0083830)
         End If
         'Exit For            '   "
      End If
   Next

End Function

Sub SetHWndParent(ByVal NewhWndParent As Integer)
'0Mar04 CKJ

   m_hWndParent = NewhWndParent

End Sub

Sub SetRobotPrintLabelMessageID(ByVal MessageID As Long)

   m_lngRobotPrintLabelMessageID = MessageID

End Sub

Function StringExtract(ByVal strTemplate As String, ByVal strMask As String, ByVal strData As String) As String
'14Sep05 CKJ Extract a substring from strData at a position corresponding to the location of strMask in strTemplate
'              strTemplate  '.....XXX...'   '.....XXX...'   '.....XXX...'   '.....XXX...'   '.....XXX...'
'              strMask      'XXX'           'XX'            'XXXX'          'XXX'           'XXX'
'              strData      '01234567890'   '01234567890'   '01234567890'   '0123456'       '012'
'              result       '567'           '56'            ''              '56'            ''
'
'            Any characters can be used in Mask and Template, but only exact matches including case are used.
'            The mask is aligned with the first position in Template which matches.
'            If the data string is too short then the string returned may be shorter than the Mask or blank.

Dim posn As Integer
Dim chars As Integer
Dim result As String

   result = ""
   chars = Len(strMask)
   If chars Then
         posn = InStr(strTemplate, strMask)
         If posn Then
               result = Mid$(strData, posn, chars)
            End If
      End If
   StringExtract = result

End Function

Private Function SwisslogInitialise(ByVal ForceReset As Integer) As Integer
'24Nov03 CKJ written
'            If ForceReset=True then an existing link will be broken & reinitialised
'            otherwise an exiting link is simply used.
'17feb04 ckj removed call to SwisslogShow.
'            This function must only be used from inside SwisslogShow

Dim dummy As Integer
Dim success As Integer

   If ForceReset And Not Swisslog Is Nothing Then
         dummy = SwisslogTerminate()
      End If
   
   If Swisslog Is Nothing Then
         Set Swisslog = New frmIPlink
         Load Swisslog
         Swisslog.Caption = "Swisslog Interface"
      End If

   SwisslogInitialise = success

End Function

Private Function SwisslogRequestProduct(ByVal SectionID As String, ByVal strMessageType As String, ByVal Identifier1 As String, ByVal Identifier2 As String, ByVal ProductID As String, ByVal QuantityToIssue As String, QuantityIssued As String, QuantityStocked As String, strMessageText As String) As Integer
'Public function
'Given a number of whole packs to issue (must not be negative) and a barcode,
'contact the Swisslog, send message if possible, and return details of product or failure code
'SectionID is the MechDisp.ini section for the product requested
'                                                                  -----------Success------------ -----------Failure------------
' strMessageType Identifier1 Identifier2 ProductID QuantityToIssue QuantityIssued QuantityStocked QuantityIssued QuantityStocked   Implemented
'  Patient          name        caseno    EAN8/13       1 to n        0 to n          -n to n        unchanged      unchanged          Yes
'  Ward             ward      picktickno  EAN8/13       1 to n        0 to n          -n to n        unchanged      unchanged          No
'  Enquiry         optional    optional   EAN8/13       ignored       unchanged       -n to n        unchanged      unchanged          Yes
'  Enquiry         optional    optional   EAN~EAN       ignored       unchanged         n~n          unchanged      unchanged          No
'
'All quantities are currently positive integers, although part packs may be supported by Swisslog in due course
'
'return value is success T/F
'
'MSA|AA|435672||2|123|'          patient issue or stock issue, issued 2 with 123 left afterwards
'MSA|AA|435672|||123|'           single item enquiry, qty issued is blank, qty in stock
'MSA|AA|435672|||123~456~678|'   multiple item enquiry, qty issued is blank, qty in stock tilda separated
'
'11mar04 CKJ Moved messages to ini file
'12Mar04 CKJ Corrected boolean on Heap closure

Dim strMessage As String
Dim strReply As String
Dim RobotHeap As Integer
Dim intSuccess As Integer
Dim dummy As Integer
Dim Numoflines As Integer
Dim intloop As Integer
Dim strReplyText As String
Dim strTemp As String
Dim iniFile As String
Dim strQtyIssued As String
Dim strQtyStocked As String
Dim strReplyMID As String
Dim MessageID As Long
Dim blnBusy As Integer
Dim strText As String
Dim SwisslogDatPath As String

   intSuccess = False
   MessageID = 0
   iniFile = dispdata$ & MechDispIni
   strMessageText = ""
   SwisslogDatPath = TxtD(iniFile, SectionID, dispdata$, "SwisslogDatPath", False)
   
   If Not blnBusy Then
         blnBusy = True

         strTemp = terminal("SwisslogTerminalName", "<INVALID>")
         strMessage = "[MSG" & strMessageType & "]"                        'MessageType = Patient, Ward, Enquiry
         ParseCtrlChars iniFile, SectionID, strMessage, 0
      
         If strTemp = "<INVALID>" Then
               'no action: not a Swisslog enabled terminal
      
            ElseIf strMessage = "[MSG" & strMessageType & "]" Then
               strMessageText = "Unsupported message type: " & strMessageType                '16Jun05 CKJ added
               MechDispLog SectionID, "E", strMessageText
            
            ElseIf Len(ProductID) = 0 Then
               'no action: no barcode provided
            
            ElseIf Val(SectionID) = 0 Then
               strMessageText = "Invalid SectionID: " & SectionID                            '16Jun05 CKJ added
               MechDispLog SectionID, "E", strMessageText
      
            Else
               Heap 1, RobotHeap, "Swisslog Data Heap", "", intSuccess
               If Not intSuccess Then strMessageText = "Failed to allocate data heap for Swisslog"    '16Jun05 CKJ added
            
            End If
      
         If intSuccess Then
               GetPointerSQL SwisslogDatPath & "\Swisslog.dat", MessageID, True                 '30Jun05 CKJ changed from fixed path
               Select Case MessageID
                  Case Is < 1, Is > 99999999
                     GetPointerSQL SwisslogDatPath & "\Swisslog.dat", 1, 2                      '   "
                     MessageID = 1
                  End Select
      
               Heap 10, RobotHeap, "yyyymmddNow", Format$(Now, "yyyymmdd"), False      '20May08 CKJ was intSuccess
               Heap 10, RobotHeap, "hhnnssNow", Format$(Now, "hhnnss"), False      '20May08 CKJ was intSuccess
               Heap 10, RobotHeap, "MessageID", Format$(MessageID), False      '20May08 CKJ was intSuccess
               Heap 10, RobotHeap, "IssueQty", QuantityToIssue, False      '20May08 CKJ was intSuccess
               Heap 10, RobotHeap, "EANcode", ProductID, False      '20May08 CKJ was intSuccess
               Heap 10, RobotHeap, "TerminalName", strTemp, False      '20May08 CKJ was intSuccess
               Heap 10, RobotHeap, "UserID", UserID$, False      '20May08 CKJ was intSuccess
               Heap 10, RobotHeap, "ToName", Identifier1, False      '20May08 CKJ was intSuccess
               Heap 10, RobotHeap, "ToCode", Identifier2, False      '20May08 CKJ was intSuccess
               ParseItems RobotHeap, strMessage, False
               
               intSuccess = SwisslogSendMessage(SectionID, strMessage)             'Actually send the message
               
               If intSuccess Then
                     intSuccess = False
                     Swisslog.lblMessage.Caption = TxtD(iniFile, SectionID, "  Waiting for reply from Swisslog... ", "WaitingMsg", False)
                     LastReply True, ""
                     dummy = SwisslogShow(True)                                    'modal show while waiting for reply
                     '...stay as modal form until reply received or user Cancels...
                     LastReply False, strReply
            
                     If Len(strReply) Then
                           dummy = SwisslogShow(False)                             'non modal show
                           Swisslog.lblMessage.Caption = Chr$(12)                  'clear window
                           'strText = "[HeaderMsg]"                                             ' txtd(inifile, SectionID, " Product code [EANcode][cr]", "HeaderMsg", False) & strText
                           
                           'dismantle reply
                           replace strReply, Chr$(&HB), "<B>", 0
                           replace strReply, Chr$(&HD), "<D>", 0
                           replace strReply, Chr$(&H1C), "|", 0
                           ReDim lines$(50)
                           deflines strReply, lines$(), "|(*)", 1, Numoflines
                           
                           strReplyText = Trim$(lines$(Val(TxtD(iniFile, SectionID, "", "ReplyText", False))))        '27Jun05 CKJ added trim
                           strQtyIssued = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyQuantityIssued", False)))
                           strQtyStocked = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyQuantityStocked", False)))
                           strReplyMID = lines$(Val(TxtD(iniFile, SectionID, "", "ReplyMessageID", False)))
                           Heap 10, RobotHeap, "ReceivedText", strReplyText, False        '27Jun05 CKJ Replaced intSuccess with False to prevent failed Tx/Rx
                           Heap 10, RobotHeap, "QtyIssued", strQtyIssued, False           '   "        from setting overall success to True
                           Heap 10, RobotHeap, "QtyStocked", strQtyStocked, False         '   "
                           Heap 10, RobotHeap, "ReceivedMessageID", strReplyMID, False    '   "
                           Heap 10, RobotHeap, "CR", crlf, False                          '   "
                           strMessageText = strReplyText                                  '   "        Send back to calling proc

                           If InStr(strReply, TxtD(iniFile, SectionID, "", "ReplyPreamble", False)) <> 1 Then    'invalid reply
                                 strText = "[InvalidMsg]"                                       ' txtd(inifile, SectionID, " Reply is not a valid message", "InvalidMsg", False)
                              
                              ElseIf CDbl(strReplyMID) <> MessageID Then
                                 strText = "[IncorrectIDMsg]"                                   ' txtd(inifile, SectionID, " Reply is not for this message[cr] - Message ID expected is [MessageID][cr] - Message ID in reply is [ReceivedMessageID]", "IncorrectIDMsg", False)
                              
                              ElseIf lines$(Val(TxtD(iniFile, SectionID, "", "ReplyStatus", False))) <> "AA" Then
                                 strText = "[RejectedMsg]"                                      ' txtd(inifile, SectionID, " Request Rejected: [cr] - [ReceivedText]", "RejectedMsg", False)
                                 
                              Else   'looks OK to use
                                 If strMessageType = "Enquiry" Then
                                       strText = "[StockedMsg]"                                 ' txtd(inifile, SectionID, "  [QtyStocked] stocked[cr]  [ReceivedText]", "StockedMsg", False)
                                    Else
                                       strText = "[IssuedMsg]"                                  ' txtd(inifile, SectionID, "  [QtyIssued] issued[cr]  [QtyStocked] stocked[cr]  [ReceivedText]", "IssuedMsg", False)
                                    End If
                                 
                                 QuantityIssued = Trim$(strQtyIssued)
                                 QuantityStocked = strQtyStocked
                                 intSuccess = True
                              End If

                           ParseCtrlChars iniFile, SectionID, strText, False
                           ParseItems RobotHeap, strText, False
                           Swisslog.lblMessage.Caption = strText

                        Else         'user cancelled
                           'no action, return failure code
                        End If
                  Else
                     'no action, return failure code
                     strMessageText = "Swisslog not responding"                                 '30Jun05 CKJ Added
                  End If

               Heap 2, RobotHeap, "", "", False                                                 '12mar04 CKJ changed from intsuccess as this would override the SwisslogSendMessage return value
            End If
         blnBusy = False
      End If

   SwisslogRequestProduct = intSuccess

End Function

Private Function SwisslogSendMessage(ByVal SectionID As String, strMessage As String) As Integer
'Never call this directly - only call via SwisslogRequestProduct
'otherwise the busy flag would be bypassed
'16oct06 CKJ Changed DoEvents to DoSaferEvents
'06Mar07 CKJ Added extra checks

Dim success As Integer
Dim AfterNSeconds As Variant
Dim iniFile As String
Dim RemoteHost As String
Dim RemotePort As String

   success = False

   SwisslogSendMessage = False

   If strMessage <> "" And Val(SectionID) > 0 Then
         success = SwisslogShow(False)
         
         '06Mar07 CKJ Added extra checks
         If Not success Then
            popmessagecr ".", "Swisslog Interface could not be started"
            
         ElseIf Swisslog.mobjIPClient Is Nothing Then
            Swisslog.lblStatus.Caption = IPclientMissingMsg
            Swisslog.lblMessage.Caption = IPclientMissingMsg
            
         Else
            iniFile = dispdata$ & MechDispIni
         
            Swisslog.lblMessage.Caption = Chr$(12)
   '11feb07         Swisslog.mobjIPClient.WinsockLoaded = True
            
            Swisslog.mobjIPClient.EOL = Chr$(&H1C) & Chr$(&HD)
            
            'close old connections (if any)
            '!!** should not be needed in current implementation
            '     may be needed if multiple connections to several machines
   
            'attempt connection
            If Not Swisslog.mobjIPClient.Connected Then
                  Swisslog.Tag = SectionID
                  RemoteHost = TxtD(iniFile, SectionID, "127.0.0.1", "IPaddress", False)        '30Jun05 CKJ set only if different
                  If Swisslog.mobjIPClient.RemoteHost <> RemoteHost Then                            '            avoids immediate reuse after failed connection,
                        Swisslog.mobjIPClient.RemoteHost = RemoteHost                               '            since connected=false but the last attempt is still busy
                     End If
                  RemotePort = TxtD(iniFile, SectionID, "5200", "IPport", False)                '   "
                  If Swisslog.mobjIPClient.RemotePort <> RemotePort Then
                        Swisslog.mobjIPClient.RemotePort = RemotePort
                    End If
                  Swisslog.lblStatus.Caption = "Connecting to " & Swisslog.mobjIPClient.RemoteHost & " port " & Swisslog.mobjIPClient.RemotePort & " ..."
                  Swisslog.mobjIPClient.Connected = True
               End If
            
            'wait until the connection is achieved (timeout in 10 seconds)
            AfterNSeconds = Now + CDbl(TxtD(iniFile, SectionID, "10", "timeout", False)) / (3600# * 24#)
            Do Until Now > AfterNSeconds
               If Swisslog.mobjIPClient.Connected Then Exit Do
               DoSaferEvents 1                               '16oct06 CKJ was DoEvents, but this allowed main prog to continue
            Loop
            
            If Not Swisslog.mobjIPClient.Connected Then
                  Swisslog.lblStatus.Caption = "Connection timed out."
               Else
                  Swisslog.lblStatus.Caption = "Send: " & FormatCtrlChars(strMessage)
                              
                  'send the data
                  Swisslog.mobjIPClient.DataToSend = strMessage
                  SwisslogSendMessage = True
               End If
         End If
      End If

End Function

Private Function SwisslogShow(ByVal SetModal As Integer) As Integer
'If the form is not loaded, then load and show
'If the form is loaded, then hide if necessary and show
'If already loaded and on show with the correct modaility, do nothing
'SetModal = -1 True                          modal
'            0 False (or any other integer)  nonmodal
'            1                               don't change mode if set, use non modal if not set

Dim IsModal As Integer
Dim dummy As Integer
Dim blnHide As Integer

   SwisslogShow = False
   IsModal = (SetModal = True)                   'only set modal if specifically requested
   If Swisslog Is Nothing Then
         dummy = SwisslogInitialise(False)
         IsModal = True
         Swisslog.cmdCancel.Visible = IsModal
         'Swisslog.cmdCancel.Tag = "-2"           'show then hide immediately
         Swisslog.Timer1.Enabled = True
      End If
   
   If Not Swisslog Is Nothing Then
         If Swisslog.Visible Then
               If SetModal = 1 Then IsModal = (Swisslog.cmdCancel.Tag = "-1")         'set modal based on existing form
               blnHide = False
               If Swisslog.cmdCancel.Tag = "-1" And Not IsModal Then blnHide = True   'Modal wanted, not modal now
               If Swisslog.cmdCancel.Tag = "0" And IsModal Then blnHide = True        'Non modal wanted, modal now ** should not be necessary of course
               If Swisslog.cmdCancel.Tag = "0" And Not IsModal Then blnHide = True    'Non modal wanted, non modal now BUT might need to auto hide -2 because of existing modal form
               If blnHide Then
                     IPlinkHide Swisslog         'hide first to change modality
                  End If
            End If
         
         SwisslogShow = True
         If Not Swisslog.Visible Then
               Swisslog.cmdCancel.Visible = IsModal
               Swisslog.cmdCancel.Tag = Format$(IsModal)
               On Error GoTo SwisslogShow_Err
               Swisslog.Show Iff(IsModal, 1, 0), OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form          'Show
            End If
      End If

Exit Function

SwisslogShow_Err:
   Select Case Err
      'Can't display non-modal form when modal form showing
      '12mar07 CKJ Added: Non-modal forms cannot be displayed in this host application from an ActiveX DLL, ActiveX Control, or Property Page. (406)
      Case 401, 406
         IPlinkHide Swisslog
         IsModal = True
         Swisslog.cmdCancel.Visible = IsModal
         Swisslog.cmdCancel.Tag = "-1"
         IPlinkResize Swisslog
         Swisslog.Timer1.Enabled = True                  'show modally then hide immediately
         Resume

      Case Else
         popmessagecr ".", "Procedure SwisslogShow Error:" & crlf & Error & " (" & Format$(Err) & ")"
         Resume Next

      End Select

Resume Next
      
End Function

Private Function SwisslogTerminate() As Integer
'Cancel any current connection, close the IP port and close the form

Dim dummy As Integer

   If Not Swisslog Is Nothing Then
         dummy = IPlinkCloseConnection(Swisslog)

         Unload Swisslog                    'this closes current connection if any
         Set Swisslog = Nothing
         '05Jun17 TH Post logs
         PostMechDispLog
      End If

   SwisslogTerminate = True                 'may return error indication

End Function

Function TerminalForMechDisp(ByVal LocationCode As String) As Integer
'Is the current terminal set up to use the mechanical dispensing unit implied by LocationCode?
' Returns True if LocationCode uses e.g. Swisslog, and the terminal has a Swisslog Identifier
'18May06 CKJ JVM does not support real-time interface, so all terminals report not for Mech Disp
'            However all terminals have the right to prepare output files - not handled here
      
Dim MachineType As String
Dim TerminalID As String

   TerminalForMechDisp = False
   If LocationForMechDisp(LocationCode, MachineType) Then
         Select Case LCase$(MachineType)
            Case "swisslog"
               TerminalID = terminal("SwisslogTerminalName", "<INVALID>")
               TerminalForMechDisp = (TerminalID <> "<INVALID>")
            
            Case "rowa"
               TerminalID = terminal("RowaTerminalName", "<INVALID>")
               TerminalForMechDisp = (TerminalID <> "<INVALID>")
            
            Case "apostore"
               TerminalID = terminal("ApostoreTerminalName", "<INVALID>")
               TerminalForMechDisp = (TerminalID <> "<INVALID>")
            
            Case "consis"
               TerminalID = terminal("ConsisTerminalName", "<INVALID>")
               TerminalForMechDisp = (TerminalID <> "<INVALID>")
            
            Case "jvadtps"       '18May06 CKJ Real-time interface not supported
               TerminalForMechDisp = False

            Case "mts"           '25Jan08 CKJ Real-time interface not supported
               TerminalForMechDisp = False
            
            Case "robopharma"    '16Dec09 CKJ
               TerminalID = terminal("RoboPharmaTerminalName", "<INVALID>")
               TerminalForMechDisp = (TerminalID <> "<INVALID>")
            
            Case Else
               '
            End Select
      End If

End Function

Private Sub WriteRowaLink(ByVal blnNewFile As Integer, ByVal strStatus As String)
'05Jun17 TH Removed - we dont write to any files anymore (TFS 185851)

'Dim chan As Integer
'Dim strFile As String

'   On Error Resume Next
'   strFile = dispdata$ & "\RowaLink.txt"
'   chan = FreeFile
'   If blnNewFile Then
'         Open strFile For Output Lock Read Write As #chan
'      Else
'         Open strFile For Append Lock Read Write As #chan
'      End If
'   Print #chan, "Link "; strStatus; " by user "; Trim$(UserID$); " on terminal "; ASCTerminalName(); " at "; Format$(Now, "yyyy/mm/dd hh:nn:ss"); " using "; App.EXEName
'   Close #chan
'   On Error GoTo 0

End Sub

Sub ShowAllRobotMessageWindows()
'13Mar07 CKJ written (SC-07-0157)
'            If any IPlink form is loaded, show each one in turn, modally in sequence
'            Not applicable to JVM or MTS

   If Not Apostore Is Nothing Then ApostoreShow True
   If Not Consis Is Nothing Then ConsisShow True
   If Not ROWA Is Nothing Then RowaShow True
   If Not Swisslog Is Nothing Then SwisslogShow True
   If Not RoboPharma Is Nothing Then RoboPharmaShow True   '16Dec09 CKJ
   '!! add more as needed

End Sub

Function CountAllRobotMessageWindows() As Integer
'07Jan10 CKJ Written. Return number of instances of robot interface windows loaded
   
Dim WindowCount As Integer

   WindowCount = 0
   If Not Apostore Is Nothing Then WindowCount = WindowCount + 1
   If Not Consis Is Nothing Then WindowCount = WindowCount + 1
   If Not ROWA Is Nothing Then WindowCount = WindowCount + 1
   If Not Swisslog Is Nothing Then WindowCount = WindowCount + 1
   If Not RoboPharma Is Nothing Then WindowCount = WindowCount + 1

   CountAllRobotMessageWindows = WindowCount
   
End Function

Private Function RoboPharmaInitialise(ByVal ForceReset As Integer) As Integer
'16Dec09 CKJ written
'            If ForceReset=True then an existing link will be broken & reinitialised
'            otherwise an existing link is simply used.

Dim dummy As Integer

   If ForceReset And Not RoboPharma Is Nothing Then
         dummy = RoboPharmaTerminate()
      End If
   
   If RoboPharma Is Nothing Then
         Set RoboPharma = New frmIPlink
         Load RoboPharma
         RoboPharma.Caption = "RoboPharma Interface"
      End If

   RoboPharmaInitialise = True

End Function

Private Function RoboPharmaRequestProduct(ByVal SectionID As String, ByVal strMessageType As String, ByVal Identifier1 As String, ByVal Identifier2 As String, ByVal ProductID As String, ByVal QuantityToIssue As String, QuantityIssued As String, QuantityStocked As String, strMessageText As String) As Integer
'12Aug05 CKJ Siemens RoboPharma handler
'Given a number of whole packs to issue (must not be negative) and a barcode,
'contact RoboPharma, send message if possible, and return details of product or failure code
'SectionID is the MechDisp.ini section for the product requested
'                                                                  -----------Success------------ -----------Failure------------
' strMessageType Identifier1 Identifier2 ProductID QuantityToIssue QuantityIssued QuantityStocked QuantityIssued QuantityStocked   Implemented
'  B  Enquiry       blank     blank       EAN13       ignored       ""             n               unchanged      unchanged          Yes
'  A  Patient       blank     blank       EAN13       n             n              unchanged       unchanged      unchanged          Yes
'  A  Ward          ward      picktickno  EAN13       n             n              unchanged       unchanged      unchanged          Yes

'All quantities are positive integers.
'Return value is success T/F

'29Jan10 CKJ corrected locking during internal testing
'20Feb17 TH Replaced use of locking details file so we can use the message as per the old files (TFS 177820)


Dim strMessage As String
Dim strReply As String
Dim RobotHeap As Integer
Dim intSuccess As Integer
Dim dummy As Integer
Dim strReplyType As String
Dim strReplyText As String
Dim strTemp As String
Dim iniFile As String
Dim strQtyIssued As String
Dim strQtyStocked As String
Dim strReplyMID As String
Dim MessageID As Long
Dim blnBusy As Integer
Dim strReplyStatus As String
Dim strText As String
Dim strTemplate As String
Dim strMask As String
Dim strStatus As String

   intSuccess = False

   MessageID = 0
   iniFile = dispdata$ & MechDispIni
   strMessageText = ""

   If Not blnBusy Then
      blnBusy = True

      strTemp = terminal("RoboPharmaTerminalName", "<INVALID>")         'Sent to RoboPharma as Location (3 digits, no spaces, >000, <900)
      strMessage = "[MSG" & strMessageType & "]"                        'MessageType = A for Patient/Ward, B for Enquiry
      ParseCtrlChars iniFile, SectionID, strMessage, 0
      strReplyType = TxtD(iniFile, SectionID, "", "ANS" & strMessageType, 0)
   
      If strTemp = "<INVALID>" Then
         'no action: not a RoboPharma enabled terminal
         
      ElseIf Len(strTemp) <> 3 Then
         strMessageText = "RoboPharma Terminal Location must be 3 digits: " & strTemp
      
      ElseIf Not IsDigits(strTemp) Then
         strMessageText = "RoboPharma Terminal Location must be 3 digits: " & strTemp

      ElseIf strMessage = "[MSG" & strMessageType & "]" Then
         strMessageText = "Unsupported message type: " & strMessageType
         MechDispLog SectionID, "E", strMessageText
      
      ElseIf Len(strReplyType) = 0 Then           'config error - MSGx defined with no ANSx
         strMessageText = "ReplyType not defined for MessageType: " & strMessageType
         
      ElseIf Len(ProductID) = 0 Then                                  'no message id number
         'no action: no barcode provided
      
      ElseIf Val(SectionID) = 0 Then
         strMessageText = "Invalid SectionID: " & SectionID
         MechDispLog SectionID, "E", strMessageText

      ElseIf strReplyType = "a" And Val(QuantityToIssue) < 1 Then
         strMessageText = "Quantity to issue too low: " & QuantityToIssue
         MechDispLog SectionID, "E", strMessageText

      ElseIf strReplyType = "a" And Val(QuantityToIssue) > 99999 Then
         strMessageText = "Quantity to issue too high: " & QuantityToIssue
         MechDispLog SectionID, "E", strMessageText
      
      Else
         Heap 1, RobotHeap, "RoboPharma Data Heap", "", intSuccess
         If Not intSuccess Then strMessageText = "Failed to allocate data heap for RoboPharma"

      End If
            
      If intSuccess Then                '20Jan10 CKJ added block to acquire lock & update info file
         m_blnEnableRoboPharmaLocking = TrueFalse(TxtD(iniFile, SectionID, "F", "EnableRoboPharmaLocking", False))      'default is NOT locked
         If m_blnEnableRoboPharmaLocking Then
            'AcquireLock dispdata$ & ROBOPHARMALCK, 2, intSuccess
            AcquireLock dispdata$ & ROBOPHARMALCK, 2, intSuccess, strMessageText  '20Feb17 TH Replaced above so we can use the message as per the old files (TFS 177820)
            
            If Not intSuccess Then
                  'GetTextFile dispdata$ & "\RoboLink.txt", strText, 0
                  'If Len(strText) Then strMessageText = crlf & "Check with user of this terminal as this is where the RoboPharma is locked:" & crlf & strText
                  If Len(strText) Then strMessageText = crlf & strMessageText & crlf & strText '20Feb17 TH Replaced above
                  strText = ""
               End If
            'strStatus = Iff(intSuccess, "acquired", "rejected") '20Feb17 TH Remove - we dont use files anymore
            'WriteRowaLink intSuccess, strStatus               '29Jan10 CKJ corrected during internal testing
            'WriteRoboPharmaLink intSuccess, strStatus          '   "        '24Mar10 CKJ   '20Feb17 TH REmoved
         End If
         
         If intSuccess Then
            Select Case strMessageType
               Case "Patient", "WardBox"                                                         'message id number needed
                  GetPointerSQL dispdata$ & "\RoboPharma.dat", MessageID, True                   'only get number once lock is granted
                  Select Case MessageID
                     Case Is < 1, Is > 89999999                                           '0 < n < 90,000,000
                        GetPointerSQL dispdata$ & "\RoboPharma.dat", 1, 2
                        MessageID = 1
                     End Select
               Case Else
                  MessageID = 0
               End Select
   
            Heap 10, RobotHeap, "yyyymmddNow", Format$(Now, "yyyymmdd"), 0
            Heap 10, RobotHeap, "hhnnssNow", Format$(Now, "hhnnss"), 0
            Heap 10, RobotHeap, "MessageID", Format$(MessageID, "00000000"), 0
            Heap 10, RobotHeap, "IssueQty", Format$(QuantityToIssue, "00000"), 0
            Heap 10, RobotHeap, "EANcode", ProductID, 0
            Heap 10, RobotHeap, "TerminalID", Format$(strTemp, "000"), 0
            
            strTemp = terminal("RoboPharmaChuteID", "001")
            If Len(strTemp) <> 3 Or Not IsDigits(strTemp) Then strTemp = "001"                  'default to chute 001 if not set properly
            If Val(strTemp) <= 0 Then strTemp = "001"                                           '   "
            Heap 10, RobotHeap, "ChuteID", strTemp, 0                                           'must be 3 digits
                           
            Heap 10, RobotHeap, "UserID", UserID$, 0
            Heap 10, RobotHeap, "ToCode", pad(Identifier2, 15), 0                               'caseno ward  / picking picket
            Heap 10, RobotHeap, "ToName", pad(Identifier1, 30), 0                               'Patient name / ward
         
            intSuccess = RoboPharmaComms(SectionID, RobotHeap, ProductID, strMessageType, strReplyType, strReply, strMessageText)
   
            dummy = IPlinkCloseConnection(RoboPharma)                      '24Mar10 CKJ moved out of locking block
            
            '05Jun17 TH Post logs
            PostMechDispLog
            
            If m_blnEnableRoboPharmaLocking Then                           '20Jan10 CKJ added block
               'dummy = IPlinkCloseConnection(RoboPharma)                  '24Mar10 CKJ
               waitforticks Val(TxtD(iniFile, SectionID, "2", "RoboPharmaDisconnectDelay", False))  'RoboPharma may take some time to disconnect properly
               AcquireLock dispdata$ & ROBOPHARMALCK, 0, 0
               'WriteRoboPharmaLink False, "released"  '20Feb17 TH REmoved
               RoboPharma.lblStatus.Caption = "Lock Released"
            End If

            'strMessageText may be set if there is an error from the comms layer
            'this may be with intSuccess = true or false, depending on the severity
            If intSuccess Then            'reply received which matches validity checks in comms layer (may not be valid barcode or enough stock though)
               intSuccess = False
   
               RoboPharma.lblMessage.Caption = Chr$(12)                  'clear window
   
               strReplyText = strReply
               strQtyIssued = ""
               strQtyStocked = QuantityStocked
               strReplyMID = ""
               Heap 10, RobotHeap, "ReceivedText", FormatCtrlChars(strReplyText), False
               Heap 10, RobotHeap, "ReceivedMessageID", strReplyMID, False
               Heap 10, RobotHeap, "CR", crlf, False
               
               strReplyStatus = ""
               Heap 10, RobotHeap, "ReplyType", strReplyType, False
               Heap 10, RobotHeap, "ReplyStatus", strReplyStatus, False
   
               replace strReply, Nul, " ", 0                         'ASCII 0x00 => space
               replace strReply, Chr$(1), " ", 0                     'ASCII 0x01 => space
   
               Select Case strReplyType
                  Case "a"
                     'SEND
                     '0123456789012345678901234567890123456789012345678901234'
                     'ABBBBBBBBCCCDDDEFFGGGGGGGGGGGGGGGGGGGGHHHHHIJJJJJJJJJJK'
                     'A<OrdNum><3><3>!<><   20 Barcode     ><Qty>|<10 RxNum>¬'
                     'A000000680030033016878661207908|||||||00001|          ¬'
                     'A000000030010013018779763806502|||||||00001|          ¬'
                     'where | is ASCII 0x01 and ¬ is ASCII 0x03
                     'A    Message Type is 'A'
                     'B    Message sequence number
                     'C    Requesting location
                     'D    Chute number, replaced by specific chute to indicate ward box filling
                     'E    Priority 1-5
                     'F    Number of following products '01'
                     'G    Barcode, right padded with ASCII 0x01
                     'H    Issue quantity
                     'I    ASCII 0x01
                     'J    Rx Number, unused with immediate picking, send ten ASCII 0x01
                     '     For ward boxes send <ward><picking ticket> where
                     '        <ward> is left justified, right 0x01 padded to 5 characters
                     '        <picking ticket> is five digits (Modulo 100,000 and left 0 padded)
                     'K    ASCII 0x03
                     
                     'REPLY
                     'size posn  description & content
                     ' 1    0 message-ID 'a'
                     ' 8    1 order-number > '00000000' & < '90000000' (ie Message sequence number)
                     ' 3    9 number of requesting location > '000' & < '900'
                     ' 3   12 delivery-location > '000'
                     ' 2   15 order-state
                     '        ´00´ in progress
                     '        ´01´ in queue
                     '        ´02´ queue full
                     '        ´03´ stopped
                     '        ´04´ completed
                     '        ´05´ change of quantity from RoboPharma to PS
                     '
                     ' 2   17 number of following articles = ´01´
                     '20   19 Article code
                     ' 5   39 delivered quantity >= ´00000´
                     '10   44 Prescription number (optional)
                     ' 1   54 ASCII 0x03 (ETX - end of text)
                                                
                     'REPLY
                     '0123456789012345678901234567890123456789012345678901234
                     'a<  8   ><3><3><><><       20         >< 5 ><   10   >¬
                     '.AAAAAAAABBBCCCDDEEFFFFFFFFFFFFF.......GGGGGHHHHHHHHHH¬'
                     'a0000007200300105016878661207908       00000          ¬'
                     
                     '01234567890123456789
                     'a<  8   ><3><3><><>¬      product barcode not found: orderstate=03, number of products following=00
                     '.AAAAAAAABBBCCCDDEE¬'
                     'a000000720030010300¬'
                     
                     'check msg seq num - AAAAAAAA                - done in commms layer
                     'check order state - DD                      - 00 01 02 03 05 in comms layer, 04 here
                     'check barcode     - FFFFFFFFFFFFF           - done in commms layer
                     'check quantity    - GGGGG                   - here
                     'build suitable message if not successful.
                                                
                     strTemplate = TxtD(iniFile, SectionID, "", "ANSaTEMPLATE", 0)
                     strMask = TxtD(iniFile, SectionID, "", "ANSaMESSAGEID", 0)
                     strReplyMID = StringExtract(strTemplate, strMask, strReply)
                     Heap 10, RobotHeap, "ReceivedMessageID", strReplyMID, False
                                          
                     strMask = TxtD(iniFile, SectionID, "", "ANSaORDERSTATE", 0)
                     strReplyStatus = StringExtract(strTemplate, strMask, strReply)
                     Heap 10, RobotHeap, "ReplyStatus", strReplyStatus, False
   
                     Select Case strReplyStatus
                        Case "03"                  'cancelled - unknown barcode
                           'no special action required, message already set
                           
                        Case "01", "04"                 'completed   '24Mar10 CKJ
                           strMask = TxtD(iniFile, SectionID, "", "ANSaQUANTITY", 0)
                           strQtyIssued = StringExtract(strTemplate, strMask, strReply)
                           Heap 10, RobotHeap, "QtyIssued", Format$(Val(strQtyIssued)), False
                           
                           strQtyStocked = Format$(Val(strQtyStocked) - Val(strQtyIssued))         'assumes qtystocked was set before calling
                           Heap 10, RobotHeap, "QtyStocked", strQtyStocked, False
                           If Val(QuantityToIssue) > Val(strQtyIssued) Then
                              strText = "[InsufficientMsg]"
                           Else
                              strText = "[IssuedMsg]"
                           End If
                           intSuccess = True
               
                        Case Else
                           strMessageText = "[InvalidReplyStatusMsg]"
                        End Select
                     
                  Case "b"          'stock enquiry reply
                     '123456789012345678901234567890123
                     'b0035011641800534       0045600¬'
                     '.AAABBBBBBBBBBBBB.......CCCCCDD¬'
                     'b_003_5011641800534       _00456_00_¬
   
                     'check barcode is for correct msg
                     If Mid$(strReply, 5, 13) = ProductID Then    'NOT  d.barcode
                           If IsDigits(Mid$(strReply, 25, 5)) Then
                                 strQtyStocked = Format$(Val(Mid$(strReply, 25, 5)))  '00018
                                 strText = "[StockedMsg]"
                                 Heap 10, RobotHeap, "QtyStocked", strQtyStocked, False
                                 intSuccess = True
                              Else
                                 strMessageText = "[InvalidSLMsg]"                           'not five digits, success stays false
                              End If
                        Else
                           strMessageText = "[InvalidSLBarcode]"                             'not for correct barcode
                        End If
   
                  Case Else       'unknown message type within acknowledgement
                     strMessageText = "[InvalidReplyMsg]"
   
                  End Select
                                 
               If Not intSuccess And Len(strText) = 0 Then
                  strMessageText = "[RejectedMsg]"                                      '" Request Rejected: [cr] - [ReceivedText]"
               End If
         
               QuantityIssued = Format$(Val(strQtyIssued))
               QuantityStocked = strQtyStocked
   
               ParseCtrlChars iniFile, SectionID, strMessageText, False
               ParseItems RobotHeap, strMessageText, False
   
               ParseCtrlChars iniFile, SectionID, strText, False
               ParseItems RobotHeap, strText, False
               RoboPharma.lblMessage.Caption = strText
               
               If Len(strMessageText) Then strText = strMessageText                 'strMessageText holds errors, strText shows stock & issues
   
            Else
               'no action, return failure code
               If Len(strMessageText) = 0 Then
                  strMessageText = "RoboPharma not responding or message is not valid" & cr & FormatCtrlChars(strReply)
               End If
               
            End If
   
            Heap 2, RobotHeap, "", "", False
         Else
            'robot locked message already set above
         End If
            
      Else
         'messages already set above
      End If
      
      blnBusy = False
   End If
   '05Jun17 TH If we happen to have any msgs then post logs
   PostMechDispLog

   RoboPharmaRequestProduct = intSuccess

End Function

Private Function RoboPharmaSendMessage(ByVal SectionID As String, ByVal strMessage As String, EOL As String) As Integer
'16Dec09 CKJ
'Never call this directly - only call via RoboPharmaRequestProduct
'otherwise the busy flag would be bypassed

Dim success As Integer
Dim AfterNSeconds As Variant
Dim iniFile As String

   success = False

   RoboPharmaSendMessage = False

   If strMessage <> "" And Val(SectionID) > 0 Then
         success = RoboPharmaShow(False)
         
         '06Mar07 CKJ Added extra checks
         If Not success Then
            popmessagecr ".", "RoboPharma Interface could not be started"
            
         ElseIf RoboPharma.mobjIPClient Is Nothing Then
            RoboPharma.lblStatus.Caption = IPclientMissingMsg
            RoboPharma.lblMessage.Caption = IPclientMissingMsg
            
         Else
            iniFile = dispdata$ & MechDispIni
         
            If Not RoboPharma.mobjIPClient.WinsockLoaded Then
            '!!** no action available to load manually - consider an abort here
            End If
            
            RoboPharma.mobjIPClient.EOL = EOL            'RoboPharma data is NOT MLLP encapsulated
            
            'close old connections (if any)
            '!!** should not be needed in current implementation
            '     may be needed if multiple connections to several machines
            
            If success Then                                    'attempt connection
                  If Not RoboPharma.mobjIPClient.Connected Then
                        RoboPharma.Tag = SectionID
                        RoboPharma.mobjIPClient.RemoteHost = TxtD(iniFile, SectionID, "127.0.0.1", "IPaddress", False)
                        RoboPharma.mobjIPClient.RemotePort = TxtD(iniFile, SectionID, "0", "IPport", False)
                        If RoboPharma.mobjIPClient.RemotePort = 0 Then
                              RoboPharma.lblStatus.Caption = "IP port must be configured for terminal " & ASCTerminalName$()
                           Else
                              RoboPharma.lblStatus.Caption = "Connecting to " & RoboPharma.mobjIPClient.RemoteHost & " port " & RoboPharma.mobjIPClient.RemotePort & " ..."
                              RoboPharma.mobjIPClient.Connected = True
                           End If
                     End If
                  
                  If RoboPharma.mobjIPClient.RemotePort > 0 Then
                        'wait until the connection is achieved (timeout in 10 seconds)
                        AfterNSeconds = Now + CDbl(TxtD(iniFile, SectionID, "10", "timeout", False)) / (3600# * 24#)
                        Do Until Now > AfterNSeconds
                           If RoboPharma.mobjIPClient.Connected Then Exit Do
                           DoSaferEvents 1                               '16oct06 CKJ was DoEvents, but this allowed main prog to continue
                        Loop
                     End If
                  
                  If Not RoboPharma.mobjIPClient.Connected Then
                        RoboPharma.lblStatus.Caption = "Connection timed out."
                     Else
                        RoboPharma.lblStatus.Caption = "Send: " & FormatCtrlChars(strMessage)
                                    
                        'send the data
                        RoboPharma.mobjIPClient.DataToSend = strMessage
                        RoboPharmaSendMessage = True
                     End If
               End If
         End If
      End If

End Function

Private Function RoboPharmaShow(ByVal SetModal As Integer) As Integer
'16Dec09 CKJ
'If the form is not loaded, then load and show
'If the form is loaded, then hide if necessary and show
'If already loaded and on show with the correct modality, do nothing
'SetModal = -1 True                          modal
'            0 False (or any other integer)  nonmodal
'            1                               don't change mode if set, use non modal if not set

Dim IsModal As Integer
Dim dummy As Integer
Dim blnHide As Integer

   RoboPharmaShow = False
   IsModal = (SetModal = True)                   'only set modal if specifically requested
   If RoboPharma Is Nothing Then
         dummy = RoboPharmaInitialise(False)
         IsModal = True
         RoboPharma.cmdCancel.Visible = IsModal
         RoboPharma.Timer1.Enabled = True
      End If
   
   If Not RoboPharma Is Nothing Then
         If RoboPharma.Visible Then
               If SetModal = 1 Then IsModal = (RoboPharma.cmdCancel.Tag = "-1")         'set modal based on existing form
               blnHide = False
               If RoboPharma.cmdCancel.Tag = "-1" And Not IsModal Then blnHide = True   'Modal wanted, not modal now
               If RoboPharma.cmdCancel.Tag = "0" And IsModal Then blnHide = True        'Non modal wanted, modal now ** should not be necessary of course
               If RoboPharma.cmdCancel.Tag = "0" And Not IsModal Then blnHide = True    'Non modal wanted, non modal now BUT might need to auto hide -2 because of existing modal form
               If blnHide Then
                     IPlinkHide RoboPharma         'hide first to change modality
                  End If
            End If
         
         RoboPharmaShow = True
         If Not RoboPharma.Visible Then
               RoboPharma.cmdCancel.Visible = IsModal
               RoboPharma.cmdCancel.Tag = Format$(IsModal)
               On Error GoTo RoboPharmaShow_Err
               RoboPharma.Show Iff(IsModal, 1, 0), OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form          'Show
            End If
      End If

Exit Function

RoboPharmaShow_Err:
   Select Case Err
      'Can't display non-modal form when modal form showing (401)
      'Non-modal forms cannot be displayed in this host application from an ActiveX DLL, ActiveX Control, or Property Page. (406)
      Case 401, 406
         IPlinkHide RoboPharma
         IsModal = True
         RoboPharma.cmdCancel.Visible = IsModal
         RoboPharma.cmdCancel.Tag = "-1"
         IPlinkResize RoboPharma
         RoboPharma.Timer1.Enabled = True                  'show modally then hide immediately
         Resume

      Case Else
         popmessagecr ".", "Procedure RoboPharmaShow Error:" & crlf & Error & " (" & Format$(Err) & ")"
         Resume Next

      End Select

Resume Next
      
End Function

Private Function RoboPharmaTerminate() As Integer
'16Dec09 CKJ Cancel any current connection, close the IP port and close the form

Dim dummy As Integer
Dim blnLinked As Integer
Dim done As Integer

   If Not RoboPharma Is Nothing Then
      If Not RoboPharma.mobjIPClient Is Nothing Then
         If RoboPharma.mobjIPClient.WinsockLoaded Then
            If RoboPharma.mobjIPClient.Connected Then
               blnLinked = True                                                  'remember state purely to update the RowaLink file later
            End If
         End If
      End If
      
      dummy = IPlinkCloseConnection(RoboPharma)

      Unload RoboPharma                                                          'this closes current connection if any
      Set RoboPharma = Nothing
      '05Jun17 TH Post logs
      PostMechDispLog
   End If

   If m_blnEnableRoboPharmaLocking Then                                          '20Jan10 CKJ added. release lock & update info file
      AcquireLock dispdata$ & ROBOPHARMALCK, 0, done                             'Attempt to release lock anyway - no harm if not locked   '20May08 CKJ Was "\Rowa"
      'If blnLinked Then WriteRoboPharmaLink False, "released"                    'Only write to file if we were connected, regardless of lock state '05Jun17 TH This should have been removed as file share has gone
   End If

   RoboPharmaTerminate = True                                                      'may return error indication

End Function

Private Function RoboPharmaComms(ByVal SectionID As String, ByVal RobotHeap As Integer, ByVal ProductID As String, ByVal strMessageType As String, ByVal strReplyType As String, strReply As String, strMessageText As String) As Integer
'16Dec09 CKJ Written, based on Consis state engine.
'            Use this to handle specific message types; A (stock issue) and B (stock enquiry)
'
'                      Ascribe                                RoboPharma
'            1         B...                ==>                                Stock enquiry
'            2                            <==                 b...
'
'            1         A...                ==>                                Issue
'            2                            <==                 a...
'            3                            <==                 a...
'            4                            <==                 a...
'
'            Up to three a... messages may be sent in response to one A... message, depending on the statuses encountered during delivery.
'              A...       request picking, await reply
'              a...1      acknowledge request, immediate reply and always present if working normally
'                a...3    error with order or robot (end)
'                a...4    order processed & qty ok  (end)
'                a...5    order processed but qty not ok
'                  a...4  (end)
'            Should never see a...0 (in progress) but if so discard and continue waiting
'            a...2 (queue full) action undefined in Robopharma spec - need confirmation if this is a recoverable error  !!**
'
' Parameters In:
'            SectionID        standard for this module
'            RobotHeap           "
'            strMessagetype   RoboPharma message type to send,  eg 'A' 'B' etc, ready for parsing as [MSGA] [MSGB] etc
'            strReplyType     RoboPharma message type expected, eg 'a' 'b' etc
' Parameters Out:
'            strReply         received message if any
'            strMessageText   displayable text if relevant, not currently used - always returns empty string
' Returns:   True/False       success
'
'            States are numbered (retaining comparable states to Consis where relevant)
'               0         base state
'              21  -29    msg & replies
'              2101-2909  specific msg errors
'             999         restart interface
'              -2         quit with fail
'              -1         quit with success
'

Dim success As Integer
Dim State As Integer
         
Dim strMessage As String
Dim intSuccess As Integer
Dim dummy As Integer
Dim iniFile As String
Dim retries As Integer
Dim restarts As Integer
Dim ETX As String
Dim OrderState As Integer
Dim strTemplate As String
Dim strReplyStatus As String
Dim strMask As String
Dim MessageIDSent As String
Dim MessageIDReply As String

   success = False
   State = 0               'not tried yet, unknown state
   retries = 0
   
   iniFile = dispdata$ & MechDispIni
   strMessageText = ""
   ETX = Chr$(3)
   
   Do
      MechDispLog SectionID, "D", "State : " & Format$(State)

      Select Case State
         Case 0            'base state, lets try to send
            'If restarts <= 3 And retries < 10 Then      'limit number of times it will restart the link or resend a packet  !!** make configurable?
            If restarts <= 2 And retries < 2 Then      'limit number of times it will restart the link or resend a packet  !!** make configurable?   '24Mar10 CKJ
               restarts = restarts + 1
               retries = retries + 1
               State = 21       'start link
            Else
               strMessageText = "RoboPharma is not responding"
               MechDispLog SectionID, "E", "Quitting after " & Format$(retries) & " retries and " & Format$(restarts) & " restarts"
               State = -2       'give up and exit with failure
            End If

         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MSG/msg ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 21                  'connect & send the msg
            strMessage = "[MSG" & strMessageType & "]"
            ParseCtrlChars iniFile, SectionID, strMessage, 0
            ParseItems RobotHeap, strMessage, False
            LastReply True, ""
            dummy = RoboPharmaShow(False)                                     'non-modal show
            RoboPharma.lblMessage.Caption = Chr$(12)
            RoboPharma.lblMessage.Caption = "  Waiting for reply from RoboPharma..." & crlf
            
            If RoboPharmaSendMessage(SectionID, strMessage, ETX) Then         'Actually send the message
                  State = 23      'successful send
               Else
                  State = 2101    'send failed
               End If
      
         Case 23                     'wait for msg reply
            dummy = RoboPharmaShow(True)                                      'modal show while waiting for reply
            '...stay as modal form until reply received or user Cancels...
            LastReply 2, strReply
            
            If Len(strReply) Then    'something arrived
                  State = 25
               Else
                  State = 2301       'no reply: timed out or user got bored waiting
               End If
         
         Case 25                     'parse first reply
            dummy = RoboPharmaShow(False)                         'non modal show
            
            If Left$(strReply, 1) = strReplyType Then             'correct preamble
               If strReplyType = "b" Then
                  State = -1                                      'successful send and reply for enquiry, return to calling routine   <== DONE
               
               ElseIf strReplyType = "a" Then                     'check 'a' message for valid fields & state
                  Heap 11, RobotHeap, "MessageID", MessageIDSent, 0      'read heap
                  strMask = TxtD(iniFile, SectionID, "", "ANSaMESSAGEID", 0)
                  strTemplate = TxtD(iniFile, SectionID, "", "ANSaTEMPLATE", 0)   '24Mar10 CKJ moved from below StringExtract
                  MessageIDReply = StringExtract(strTemplate, strMask, strReply)
               
                  If Len(strTemplate) <> Len(strReply) Then       'check message length for normal reply
                     strTemplate = TxtD(iniFile, SectionID, "", "ANSaTEMPLATEstate03", 0)
                     If Len(strTemplate) = Len(strReply) Then     'check message length for state 03 product unknown/request cancelled
                        If MessageIDReply = MessageIDSent Then    'is it for correct messageid
                           strMask = TxtD(iniFile, SectionID, "", "ANSaORDERSTATE", 0)
                           strReplyStatus = StringExtract(strTemplate, strMask, strReply)
      
                           If strReplyStatus = "03" Then
                              State = 2510   'cancelled - unknown barcode
                           Else
                              State = 2505   'invalid order state (for this message length)
                           End If
                        Else
                           State = 2503      'incorrect messageid
                        End If
                     Else
                        State = 2502         'incorect length for 'a' message
                     End If
                  
                  Else
                     If MessageIDReply = MessageIDSent Then
                        strMask = TxtD(iniFile, SectionID, "", "ANSaBARCODE", 0)
                        If StringExtract(strTemplate, strMask, strReply) = ProductID Then          'is it for correct barcode?
                           strMask = TxtD(iniFile, SectionID, "", "ANSaORDERSTATE", 0)             'is status appropriate?
                           strReplyStatus = StringExtract(strTemplate, strMask, strReply)
      
                           Select Case strReplyStatus  '(see above for status 03)
                              Case "00"
                                 RoboPharma.lblMessage.Caption = "  Item in progress... "
                                 State = 23
                              Case "01"
                                 RoboPharma.lblMessage.Caption = "  Item in queue... "
                                 'State = 23   '24Mar10 CKJ
                                 State = -1    '24Mar10 CKJ status 01 now signals end of communication
                              Case "02"
                                 RoboPharma.lblMessage.Caption = "  ** QUEUE FULL **" & crlf
                                 State = 23
                              Case "04"
                                 RoboPharma.lblMessage.Caption = ""     ' "  Completed" & crlf
                                 State = -1           'completed (although possibly with quantity change)
                              Case "05"               'change of quantity
                                 'Should be rare because we stock check first, though does depend on pending issues being properly accounted for
                                 'The revised quantity is also reflected in the subsequent 04 message, so no special action is needed here
                                 strMask = TxtD(iniFile, SectionID, "", "ANSaQUANTITY", 0)
                                 RoboPharma.lblMessage.Caption = "  Quantity reduced to " & Format$(Val(StringExtract(strTemplate, strMask, strReply))) & crlf
                                 State = 23
                              Case Else      'invalid order state
                                 State = 2505
                              End Select
                        Else
                           State = 2504      'wrong barcode
                        End If
                     Else
                        State = 2503         'wrong message id - log, skip & wait
                     End If
                  End If
               Else
                  State = 2501
               End If
            Else
               State = 2501
            End If

         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MSG/msg Errors ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 2101
            MechDispLog SectionID, "E", "State 2101: send " & strMessageType & " failed"
            State = 999             'restart interface
                  
         Case 2301
            MechDispLog SectionID, "E", "State 2301: no reply when waiting for " & strReplyType
            State = 999             'restart interface

         Case 2501
            strMessageText = "[IncorrectReplyMsg]"
            MechDispLog SectionID, "E", "State 2501: Incorrect reply to " & strMessageType & ": " & FormatCtrlChars(strReply)
            State = -2              'quit with failure
                                                              
         Case 2502                  'incorrect length for ANSa msg
            strMessageText = "[IncorrectLengthMsg]"
            MechDispLog SectionID, "E", "State 2502: Incorrect Message length: " & Len(strReply) & " received (expected " & Len(strTemplate) & "): " & FormatCtrlChars(strReply)
            State = -2              'quit with failure
         
         Case 2503                  'incorrect message id for ANSa msg
            MechDispLog SectionID, "E", "State 2503: Incorrect MessageID: " & MessageIDReply & " received (expected " & MessageIDSent & "): " & FormatCtrlChars(strReply)
            State = 23              'wait for next message
         
         Case 2504                  'incorrect barcode for ANSa msg
            strMessageText = "[InvalidBarcode]"
            MechDispLog SectionID, "E", "State 2504: Incorrect Barcode: " & StringExtract(strTemplate, strMask, strReply) & " received (expected " & ProductID & "): " & FormatCtrlChars(strReply)
            State = -2              'quit with failure  (could'wait for next message
         
         Case 2505                  'invalid order state for ANSa msg
            strMessageText = "[InvalidOrderStateMsg]"
            MechDispLog SectionID, "E", "State 2505: Invalid OrderState " & strReplyStatus & ": " & FormatCtrlChars(strReply)
            State = -2              'quit with failure
         
         Case 2510                  'request cancelled by robot for ANSa msg
            strMessageText = "[UnknownBarcodeMsg]"
            RoboPharma.lblMessage.Caption = crlf & "  ** Request CANCELLED, product code not known on RoboPharma **" & crlf
            MechDispLog SectionID, "E", "State 2510: OrderState 03: Order cancelled by robot: " & FormatCtrlChars(strReply)
            State = -2              'quit with failure
         
         '~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Restart ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
         Case 999                   'turned pear shaped, close IP port & restart from beginning
            If Not RoboPharma Is Nothing Then
               dummy = IPlinkCloseConnection(RoboPharma)
               '05Jun17 TH Post logs
               PostMechDispLog
            End If
            State = 0               'start again

         Case -2                    '-2 quit with fail
            Exit Do

         Case -1                    '-1 quit with success
            Exit Do

         Case Else
            strMessageText = "Internal State " & Format$(State) & " not supported"
            MechDispLog SectionID, "E", "State " & Format$(State) & ": This state has not been programmed: Quitting"
            State = -2                                                          '<== DONE
            
         End Select
   Loop

   RoboPharmaComms = (State = -1)                 'success only if state = -1

End Function

Private Sub WriteRoboPharmaLink(ByVal blnNewFile As Integer, ByVal strStatus As String)
'20Jan10 CKJ added
'05Jun17 TH Removed - we must not write to fileshares anymore ! (TFS 185851)

'Dim chan As Integer
'Dim strFile As String
'
'   On Error Resume Next
'   strFile = dispdata$ & "\RoboLink.txt"
'   chan = FreeFile
'   If blnNewFile Then
'         Open strFile For Output Lock Read Write As #chan
'      Else
'         Open strFile For Append Lock Read Write As #chan
'      End If
'   Print #chan, "Link "; strStatus; " by user "; Trim$(UserID$); " on terminal "; ASCTerminalName(); " at "; Format$(Now, "yyyy/mm/dd hh:nn:ss"); " using "; App.EXEName
'   Close #chan
'   On Error GoTo 0

End Sub

Function HL7safe(ByVal strIn As String, ByVal All As Boolean) As String
'12Jul12 CKJ written
'            Removes HL7 reserved characters  |^~\&  (last three are optional)
'            May escape these if any robot ever implements HL7 escaping.

Dim strTemp As String

   strTemp = strIn
   replace strTemp, "|", "", 0
   replace strTemp, "^", "", 0
   If All Then
      replace strTemp, "~", "", 0
      replace strTemp, "\", "", 0
      replace strTemp, "&", "", 0
   End If
   HL7safe = strTemp
   
End Function

Private Sub PostMechDispLog()
'----------------------------------------------------------------------------------
'
'Purpose:  Upload local cached mechdisplogs to DB  (WPharmacyLog)
'
'Modification History:
'05Jun17  TH  Written (TFS 185185)

'----------------------------------------------------------------------------------

Dim lngFilePos As Long
Dim lngFound As Long
Dim lngLocationID_Site As Long
Dim lngFileSize As Long
Dim strFile As String
Dim intLogChan As Integer
Dim TempStr As String
Dim ErrNumber As Long, ErrDescription As String
Const ErrSource As String = "PostMechDispLog"
Static lngLogID As Long
   
  
On Error GoTo ErrorHandler

    If Trim$(m_strLoggingfile) <> "" Then
        If lngLogID = 0 Then lngLogID = CLng(TxtD(dispdata$ & MechDispIni, m_strInterface, "0", "MechDispLogTypeID", 0))
        If lngLogID = 0 Then lngLogID = GetWPharmacyLogTypeIDFromDescription("MechDisp")
                             
        lngFileSize = FileLen(m_strLoggingfile)
         
        If lngFileSize > 1 Then
            intLogChan = FreeFile()
            Open m_strLoggingfile For Input As intLogChan
                     
            While lngFilePos < lngFileSize
                Line Input #intLogChan, TempStr
                'take off what we need and write to the DB
                TempStr = Right$(TempStr, Len(TempStr) - 29)
                WriteLogSQL TempStr, "MechDisp", 0, 0, "", 0, lngLogID
                lngFilePos = Seek(intLogChan)
            Wend
            Close intLogChan
            Kill m_strLoggingfile 'only kill if successful - otherwise keep for support analysis
            
        End If
   End If

Cleanup:

On Error Resume Next
Close #intLogChan
m_strLoggingfile = "" 'Very important to clear for next run - regardless of state of DB write
If ErrNumber Then Err.Raise ErrNumber, ErrSource, ErrDescription

Exit Sub

ErrorHandler:
    ErrNumber = Err.Number
    ErrDescription = Err.Description
Resume Cleanup

End Sub
