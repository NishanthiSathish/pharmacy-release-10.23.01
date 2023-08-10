Attribute VB_Name = "Module1"
'DOStoWIN V1.0 (c) ASCribe 1996
'-------------------------------------------------------------------------------
'
'                          DCT IMPORT Program
'                         -------------------------
'-------------------------------------------------------------------------------
'modification history
'--------------------
' 4Apr95 CKJ/ASC changed sitepaths to sitenumber
'12Apr95 CKJ Corrected handling in several areas
'21Jun95 CKJ Mod to ImportDCTfile
'29Jan98 CFY removed If Not endoffile condition in ReadPsionWardStock
'05Feb98 EAC/CFY use temporary file on C: drive to import WardStockList from CE machines
'05Mar98 ASC ImportDCTfile: Ammended to stop trunction of drug descriptions.
'03May98 CKJ Y2K. Removed MakeReq as it is not needed
'11Mar98 CFY WritePsionWardStock: Changed Selection formula to export the description lines.
'            ReadPsionWardStock: Added extra condition to filter out description lines.
'12May98 EAC/CFY/SF use Crystal DLLs to output data to file
'12Jun98 EAC ReadPsionWardStockFile: handle issue of split packs from Ward Stock
'23Jun98 EAC/CFY Stopped lines with a blank top-up level being interperated as zero's.
'                Added extra code to filter out the first two lines as these are now descriptions.
'                New code added to display the dct form if coming from a right mouse click in
'                the ward stock lists.
'08Jul98 CFY WritePsionWardStockListFile: Removed OLE code that converts .dif file to a .xls as it causes
'            a gpf in kernal386. As yet we do not know the cause eof this.
'16Jul98 CFY WritePsionWardStockFile: Changed destination of where .dif files are written. The destination can now be specified by
'            the user.
'10Sep98 CFY ImportWardData: Fix to set the current drive back to what it was originally after doing the
'            dif -> Excel conversion. Was previously causing a problem when importing files
'            from a local machine.
'22Sep98 CFY ImportWardData: Added functionality which allows the location of the temporary file which is used
'            for converting .xls files to dif files to be specified using an ini file setting.
'            This is in an attempt to overcome problems when running with citrix.
'19Apr00 AE  WritePsionWardStockFile: Made screen.mousepointer = hourglass before starting export
'31May02 TH  ReadPsionWardStockFile: Added new parameter to CreateDeliveryNoteRecord
'17May04 ckj Startup: removed sethelp
'19Jul11 TH  WritePsionWardStockFile: Altered spelling on export set up error (F0123242)
'08Apr15 XN  WritePsionWardStockFile: 114692 prevent title line from showing packsize in output file
'06Dec16 TH  WritePsionWardStockFile: Replaced RTF Handling (TFS 157969)

Option Explicit
DefInt A-Z

Declare Function PEOpenEngine Lib "CRPE.DLL" () As Integer
Declare Sub PECloseEngine Lib "CRPE.DLL" ()

Declare Function PEGetErrorCode Lib "CRPE.DLL" (ByVal printJob%) As Integer

Declare Function PEGetErrorText Lib "CRPE.DLL" (ByVal printJob%, TextHandle%, TextLength%) As Integer

Declare Function PEGetHandleString Lib "CRPE.DLL" (ByVal TextHandle%, ByVal buffer$, ByVal BufferLength%) As Integer

Declare Function PEOpenPrintJob Lib "CRPE.DLL" (ByVal RptName$) As Integer
Declare Sub PEClosePrintJob Lib "CRPE.DLL" (ByVal printJob%)
Declare Function PEDiscardSavedData Lib "CRPE.DLL" (ByVal printJob%) As Integer
Declare Function PEOutputToFile Lib "CRPE.DLL" (ByVal printJob%, ByVal OutputFilePath$, ByVal FileType%, Options As Any) As Integer
Declare Function PEStartPrintJob Lib "CRPE.DLL" (ByVal printJob%, ByVal WaitOrNot%) As Integer
Declare Function PESetSelectionFormula Lib "CRPE.DLL" (ByVal printJob As Integer, ByVal formulaString As String) As Integer


Type PETableLocation
   StructSize As Integer
   location As String * 256
End Type

Declare Function PESetNthTableLocation Lib "CRPE.DLL" (ByVal printJob As Integer, ByVal tableN As Integer, location As PETableLocation) As Integer

Type PEExportOptions
    StructSize As Integer   'initialize to # bytes in PEExportOptions

    FormatDLLName As String * 64
    FormatType As Long
    FormatOptions As Long

    DestinationDLLName As String * 64
    DestinationType As Long
    destinationOptions As Long

    ' following are set by PEGetExportOptions,
    ' and ignored by PEGetExportOptions
    NFormatOptionsBytes As Integer
    NDestinationOptionsBytes As Integer
End Type

Const modulename = "WDCTIMP.BAS"
Const NumPsionFields = 8

'global variables, arrays etc
    Global Psion2%
    
    'Dim Shared d As drugparameters
    Dim drug As drugdetails
    'Dim Shared R As filerecord
    Dim dispdatapath$, transchan%, findchan%
    'Dim Shared k As kbdcontrol       ' one line keyboard input
    Dim loadedfile$
    Dim errored%
    Dim sitepth$(0)
    Dim wdebug As Integer

Sub confirmissue()

ReDim Item$(6)
Static barcode$, Qty$, UserID$, ward$, problem$
Dim foundPtr&, found%, done%, numoflines, loopvar, spacepos   '01Jun02 ALL/ATW
Dim duplicates%, NumLabels%
Dim issueunitcost$, batchno$, expiry$, temp$

   temp$ = Dctfrm.LstDCTimport.text
   deflines temp$, Item$(), Chr$(9) & "(*)", 1, numoflines

    If InStr(Command$, "/debug") Then
            For loopvar = 1 To UBound(Item$)
                Debug.Print Trim$(Str$(loopvar)) & " : " & Item$(loopvar)
            Next
        End If

   'ward$ = Left$(DCTFrm.LstDCTimport.Text, 4)
   'qty$ = Mid$(DCTFrm.LstDCTimport.Text, 40, 5)
   'userid$ = Mid$(DCTFrm.LstDCTimport.Text, 74, 4)
   'barcode$ = Mid$(DCTFrm.LstDCTimport.Text, 60, 13)
   'problem$ = Mid$(DCTFrm.LstDCTimport.Text, 51, 2)
   
   If Psion2 Then
           ward$ = Trim$(Item$(1))
           Qty$ = Trim$(Item$(3))
           spacepos = InStr(Qty$, Chr$(32))
           If spacepos > 0 Then Qty$ = Mid$(Qty$, 1, spacepos - 1)
           UserID$ = Trim$(Item$(6))
           barcode$ = Trim$(Item$(5))
           problem$ = Trim$(Item$(4))
        Else
           ward$ = Trim$(Item$(1))
           Qty$ = Trim$(Item$(3))
           spacepos = InStr(Qty$, Chr$(32))
           If spacepos > 0 Then Qty$ = Mid$(Qty$, 1, spacepos - 1)
           'userid$ = trim$(item$(6))
           barcode$ = Trim$(Item$(2))
           problem$ = Trim$(Item$(4))
        End If
   
   If problem$ = "NF" Then
         barcode$ = InputBox$("Enter Item Code", "Barcode not found", "")
      End If
   findrdrug barcode$, False, d, foundPtr&, found%, 2, False, False
   If foundPtr& > 0 Then
         Issue k, Val(Qty$), 0, d, UserID$, "", "", done%, "S", ward$, "", SiteNumber, "H", issueunitcost$, batchno$, expiry$, duplicates%, NumLabels%, 1
         If Not k.escd Then
               deleteline
            End If
      End If

End Sub

Function ConvertFile(inputfile$, outputfile$, OutputType%) As Integer
'30Dec97 CFY Added
'DESCRIPTION
' Creates an OLE object to load the file specified in the parameter InputFile$ and
' re-saves the file under the name as specified in the parameter OutputFile$ in the
' format of OutputType%, where OutputType% can contain the following values:
'
'  Value    FileType
'     9     DIF
'
' NOTE: Other formats are available but have yet to be tested.
'
' In theory the function should be able to handle any input file type
' as long as it is associated with an application which is present
' and supports OLE.

Dim FileObject As Object

   On Error GoTo ConvertFile_Error
   Set FileObject = GetObject(inputfile$)
   FileObject.SaveAs outputfile$, OutputType
   ConvertFile = True
   
ConvertFile_Exit:
   On Error Resume Next
   Set FileObject = Nothing
   On Error GoTo 0
   Exit Function
   
ConvertFile_Error:
   ConvertFile = False
   GoTo ConvertFile_Exit

End Function

Sub DeleteFile()

Dim ans$


   If Len(RTrim$(loadedfile$)) = 0 Then
         loadedfile$ = InputBox$(" Enter file name:" + Chr$(13) + Chr$(13) + "(no file loaded at present)", "", "")
      End If

   If Len(RTrim$(loadedfile$)) > 0 Then
         ans$ = "N"
         Confirm "DELETE FILE", "DELETE  " + loadedfile$, ans$, k
         If ans$ = "Y" Then
               On Error GoTo notfound
               Kill siteinfo$("DCTfilepath", "C:\PSION\") + loadedfile$   '12Apr95 CKJ Added path
               If errored Then
                     MsgBox "File not found", 0, Str$(Err)
                  Else
                     loadedfile$ = ""
                     ClearListBox
                  End If
               errored = False
               On Error GoTo 0
            End If
      End If
Exit Sub

notfound:
   errored = True
   Resume Next

End Sub

Sub deleteline()

Static thisline%
Dim ans$
   
   ans$ = "Y"
   Confirm "Delete Line", "delete line", ans$, k
   If ans$ = "Y" And Not k.escd Then
         thisline = Dctfrm.LstDCTimport.ListIndex
         Dctfrm.LstDCTimport.RemoveItem thisline
         Dctfrm.LstDCTimport.ListIndex = thisline + (thisline >= Dctfrm.LstDCTimport.ListCount)
      End If

End Sub

Sub exitprog()

Dim ans$

    If Len(loadedfile$) Then
         ans$ = "N"
         Confirm " Exiting could allow file to be booked out again ", "exit without deleting file", ans$, k
      Else
         ans$ = "Y"
      End If
   
   If ans$ = "Y" Then
         'End
         Unload Dctfrm
      End If

End Sub

Sub ExportWardData(wardcode$, Index)
'22Jun98 EAC/CFY added Index to subroutine parameters
    
    WritePsionWardStockFile wardcode$, Index    '03Dec97 EAC added wardcode$       '22Jun98 EAC/CFY added ,Index

End Sub

Sub getpsion2(chan%, temp$, UserID$, ward$, Qty$, barcode$, failed$)
      
Dim found%, digits%, count%, foundPtr&, forissue%, done%  '01Jun02 ALL/ATW



    Select Case RTrim$(temp)
        Case "FIRST"
        Line Input #chan, temp                             'date
        'parsedate RTRIM$(temp), dctdate, "2", datedone
        'IF debug THEN MSGBOX dctdate, 0, "date"
        Line Input #chan, temp                             'time
        Line Input #chan, temp                             'initials
        If Len(Trim$(temp)) Then             '11Apr95 CKJ only if not null
            UserID = temp
        End If
        If wdebug Then MsgBox UserID, 0, "userid"
        Line Input #chan, temp                             'DCT number
        
        Case "LAST"
        'no action
        
        Case Else
        If Left$(temp, 1) = "B" Then  '28Mar95 ASC
                failed = ""
                barcode = Trim$(Mid$(temp, 2, 13))
                If wdebug Then MsgBox barcode, 0, "Barcode"
                ''cleardrug d                    '12Apr95 CKJ Added
                BlankWProduct d
                found = False
        
                digits = 0                     '21Jun95 CKJ Added section
                For count = 1 To Len(barcode)
                    If InStr("0123456789", Mid$(barcode, count, 1)) Then
                        digits = count
                    Else
                        Exit For
                    End If
                Next
        
                If digits = 8 Or digits = 13 Then             '21Jun95 CKJ
                    d.barcode = Left$(barcode, digits)
                    'IF INSTR(temp, ".") = 0 THEN
                    '     IF LTRIM$(STR$(VAL(MID$(temp, 2, 13)))) = RTRIM$(MID$(temp, 2, 13)) THEN
                    '           findrdrug barcode, false, d, foundptr%, found%, 2
                    '   END IF
                    findrdrug barcode, False, d, foundPtr&, found%, 2, False, False
                    End If
        
                If found Then
                    If wdebug Then MsgBox d.LabelDescription, 0, "Description"
                        forissue = True
                    Else
                        forissue = False
                        d.LabelDescription = "Not found"
                        failed = "NF"
                    End If
            End If
        
        If Left$(temp, 2) = "CC" Then                     'cost centre   11Apr95 CKJ Was "CC:"
                ward = Mid$(temp, 3)
                If Left$(ward, 1) = ":" Then ward = Mid$(ward, 2) '11Apr95 CKJ strip : if present
                If wdebug Then MsgBox ward, 0, "Ward"
        
            ElseIf LTrim$(Str$(Val(temp))) = RTrim$(temp) Then     'quantity
                Qty = temp
                If wdebug Then MsgBox Qty, 0, "qty"
                Qty = temp
                done = True
            End If
    End Select

End Sub

Sub ImportDCTfile()
'''12Apr95 CKJ Modified to use simple file selection box
'''21Jun95 CKJ Modified to use EAN8 correctly
'''05Mar98 Ammended to stop trunction of drug descriptions.
''
''Const procname$ = "ImportDCTfile"
''
''Dim temp As String * 14
''Dim ward  As String * 4
''Dim Qty As String * 5
''Dim barcode As String * 13
''Dim UserID As String * 4
''Dim dctdate As String * 8
''Dim failed As String * 8
''Dim issued%, numoflines%, Psion2%, fileptr%, botfound%, TotErrors%
''Dim forissue%, chan%, stoppos%, datedone$, found%, done%, TotRead%
''Dim filpath$, filspec$, ans$, stocklvl$, workfile$, issueunitcost$
''Dim dctitem$, msg$
''ReDim Lines$(1)
''
''
''    If InStr(UCase$(Command$), "DEBUG") > 0 Then wdebug = True
''
''    If Len(loadedfile$) Then
''            popmessagecr "File " + loadedfile$ + " is already loaded", "Close or delete the current file before importing the next"
''            Exit Sub                                                '<== WAY OUT
''        End If
''
''    workfile$ = ""
''    filpath$ = siteinfo$("DCTfilepath", "C:\ASCPSION\")
''    Dctfrm.DirList.InitDir = filpath$
''
''    'filspec$ = filpath$ + siteinfo$("DCTfilespec", "*.ODB")
''    filspec$ = siteinfo$("DCTfilespec", "*.ODB")
''    Dctfrm.DirList.Filter = filspec$
''    Dctfrm.DirList.filename = filspec$
''
''    On Error GoTo ImportDCTFileErr
''    Dctfrm.DirList.Action = 1
''    On Error GoTo 0
''
''    If Dctfrm.DirList.filename = "" Then
''          popmessagecr "DCT Files", "No file selected for importing"
''          Exit Sub
''       Else
''            workfile$ = Dctfrm.DirList.filename
''       End If
''
''    If Not Dctfrm.MnuChkView.Checked Then
''            ans$ = "N"
''            Confirm "IMPORT FILE", "load " + workfile$ + " and book out all those items without problems", ans$, k
''            If ans$ = "N" Or k.escd Then workfile$ = "": Exit Sub   '<== WAY OUT
''        End If
''
''    issued% = 0
''    Dctfrm.LstDCTimport.Visible = False
''    Dctfrm.Lblmsg.Caption = "Importing ... "
''    Dctfrm.FrmImport.Visible = True
''    loadedfile$ = workfile$
''    chan = FreeFile
''    Open workfile$ For Input As chan
''
''    Screen.MousePointer = HOURGLASS
''
''    If Right$(workfile$, 3) = "ODB" Then Psion2 = True
''
''    Do While Not EOF(chan)
''        Line Input #chan, temp
''        If Psion2 Then
''                getpsion2 chan, temp, UserID, ward, Qty, barcode, failed
''                done = True
''            Else 'psion 3
''                If Left$(temp, 3) = "BOT" Then
''                        fileptr = 1
''                        botfound = True
''                    End If
''
''                If botfound Then
''                        fileptr = fileptr + 1
''                        Select Case fileptr
''                            Case 9    'stock level
''                                plingparse temp, Chr$(34)
''                                deflines temp, Lines$(), ",", 0, (numoflines)
''                                stocklvl$ = Lines$(1)
''                                If wdebug Then MsgBox "Stock level", 0, stocklvl$
''                            Case 13   'imprest
''                                plingparse temp, Chr$(34)
''                                deflines temp, Lines$(), ",", 0, (numoflines)
''                                Qty = Str$(Val(Lines$(1)) - Val(stocklvl$))
''                                If wdebug Then MsgBox "Imprest", 0, Qty
''                            Case 16   'NSV code
''                                plingparse temp, Chr$(34)
''                                barcode$ = temp
''                                If wdebug Then MsgBox "NSVcode", 0, barcode$
''                            Case 18   'ward code
''                                plingparse temp, Chr$(34)
''                                ward = temp
''                                If Asc(barcode$) <> 0 And Len(Trim$(barcode$)) = 7 And Left$(stocklvl$ + "X", 1) <> "X" Then done = True
''                                botfound = False
''                                If wdebug Then MsgBox "Ward" + Str$(done), 0, temp
''                            Case Else
''                                'MsgBox Str$(fileptr), 0, temp
''                        End Select
''                    End If
''            End If
''
''        'process lines and storing rejects in list box
''        If done Then
''            If forissue Then
''                    If failed <> "NF      " Then
''                        failed = ""
''                        If Trim$(UserID) = "" Then failed = "User ID"             '12Apr95 CKJ Added
''                        If Trim$(ward) = "" Then failed = "No Ward"               '12Apr95 CKJ Added
''                        If Abs(Val(Qty)) > Val(d.maxissue) Then failed = ">Max"  '12Apr95 CKJ Added ABS()
''                        If Abs(Val(Qty)) < Val(d.minissue) Then failed = "<Min"  '12Apr95 CKJ Added ABS()
''                        If d.livestockctrl = "Y" Then
''                                If Val(d.stocklvl) - Val(Qty) < 0 And Val(Qty) > 0 Then '12Apr95 CKJ Added and qty>0
''                                    failed = "SL=" + d.stocklvl
''                                    End If
''                            End If
''                        If RTrim$(failed) = "" And Not Dctfrm.MnuChkView.Checked Then
''                                Translog d, 0, UserID, "", Val(Qty), "", ward, "", "S", sitenumber, "H", issueunitcost$
''                                issued = issued + 1
''                            Else
''                                forissue = False
''                            End If
''                        End If
''                End If
''            If Not forissue Then
''                    'dctitem$ = ward + "|" + Left$(d.Description, 33) + "|" + qty + d.printformV + "|" + failed + "|" + barcode + "|" + userid
''                    'dctitem$ = ward + TB + Left$(d.description, 33) + TB + qty + d.PrintformV + TB + failed + TB + Barcode + TB + userid
''                    dctitem$ = ward + TB + d.Description + TB + Qty + d.PrintformV + TB + failed + TB + barcode + TB + UserID '05Mar98 ASC/CFY
''                    Dctfrm.LstDCTimport.AddItem dctitem$
''                    TotErrors = TotErrors + 1
''                End If
''
''            TotRead = TotRead + 1
''            If Dctfrm.MnuChkView.Checked Then
''                    Dctfrm.Lblmsg.Caption = "Importing ..." + Str$(TotRead)
''                Else
''                    Dctfrm.Lblmsg.Caption = "Importing ..." + Str$(TotRead) + " (" + LTrim$(Str$(TotErrors)) + ")"
''                End If
''            End If
''        done = False
''    Loop
''
''    Screen.MousePointer = STDCURSOR
''
''    If Dctfrm.LstDCTimport.ListCount > 0 Then Dctfrm.LstDCTimport.ListIndex = 0
''    Close chan
''    Dctfrm.FrmImport.Visible = False
''    Dctfrm.LstDCTimport.Visible = True
''    If issued% > 0 Then
''            msg$ = Str$(TotRead) + " items processed" + Chr$(13)
''            msg$ = msg$ + Str$(issued%) + " items issued" + Chr$(13)
''            msg$ = msg$ + Str$(TotErrors) + " items to check"
''            MsgBox msg$, 0, "Import Completed"
''        End If
''
''Exit Sub
''
''ImportDCTFileErr:
''
''    'trap error number 32755 - Cancel button pressed in Common Dialog
''    If Err = 32755 Then
''            Dctfrm.DirList.filename = ""
''        Else
''            Dctfrm.DirList.filename = ""
''            popmessagecr "ERROR", "Module: " & modulename$ & Chr$(13) & "Procedure : " & procname$ & Chr$(13) & "Error Number " & Str$(Err) & " occurred. Please inform ASC Computer Software Ltd."
''        End If
''    Resume Next
End Sub

Sub ImportWardData(Machine%)
'30Dec97 CFY Added file conversion routine to convert XLS to DIF
'05Feb98 EAC/CFY use temporary file on C: drive to overcome problem of excel not saving to \dispdata on drive
'                that you are currently working from.
'10Sep98 CFY Fix to set the current drive back to what it was originally after doing the
'            dif -> Excel conversion. Was previously causing a problem when importing files
'            from a local machine.
'22Sep98 CFY Added functionality which allows the location of the temporary file which is used
'            for converting .xls files to dif files to be specified using an ini file setting.
'            This is in an attempt to overcome problems when running with citrix.

Const procname$ = "ImportWardData"
Dim FILE$
Dim CurDirectory$                '10Sep98 CFY Added
Dim TempPath$                    '22Sep98 CFY
Dim strImportPath As String
Dim strFile As String
Dim strWard As String


   Unload LstBoxFrm
    'CurDirectory$ = CurDir$      '10Sep98 CFY Added
    'Dctfrm.DirList.Filter = "DIF Format (*.DIF)|*.DIF|Microsoft Excel|*.XLS"
    strImportPath = TxtD(dispdata$ & "\winord.ini", "wardstocklist", "", "ExportPath", 0) '22Sep98 CFY
    
    strImportPath = TxtD(dispdata$ & "\winord.ini", "wardstocklist", strImportPath, "ImportPath", 0) '22Sep98 CFY
    
    strFile = Dir(strImportPath & "\*_AI.xml")
    If strFile <> "" Then
      LstBoxFrm.Caption = "Select Ward to Import"
    Do
    'OK pars the file Name anddisplay in list box to user
    LstBoxFrm.LstBox.AddItem Left$(strFile, Len(strFile) - 7)
    strFile = Dir$
    Loop While strFile <> ""
    LstBoxShow
    strFile = Trim$(LstBoxFrm.Tag)
    strWard = strFile
    If strFile <> "" Then strFile = strImportPath & "\" & strFile & "_AI.xml" 'rebuild file with path
    Else
      popmessagecr "EMIS Health", "No wards are ready for import"
    End If
'
'    LstBoxFrm.Caption = "Select Report"
'   LstBoxFrm.LstBox.Clear
'
'   ReDim astrFile(1 To intReportCount)
'
'   For intReportCounter = 1 To intReportCount
'      deflines TxtD$(dispdata$ & "\winord.ini", "HierarchicalReports", "", CStr(intReportCounter), 0), astrReportSpec(), ",", 1, 0
'      LstBoxFrm.LstBox.AddItem astrReportSpec(1)
'      astrReportPath(intReportCounter) = astrReportSpec(2)
'   Next intReportCounter
'
'   LstBoxShow
'
'   ans$ = Format$(LstBoxFrm.LstBox.ListIndex + 1)
'
'   Unload LstBoxFrm

      
''    TempPath$ = TxtD(dispdata$ & "\winord.ini", "wardstocklist", "c:\", "TempFilePath", 0) '22Sep98 CFY
''
''    'needpicker here
''
''
''    'FILE$ = Dctfrm.DirList.filename
''
''    '30Dec97 CFY Added ---- Start
''    If Machine = 1 Then
''         On Error Resume Next
''         '05Feb98 EAC/CFY
''         'If fileexists(dispdata$ & "\ward.dif") Then
''         '      Kill dispdata$ & "\ward.dif"
''         'If fileexists("c:\ward.dif") Then              '22Sep98 CFY Replaced
''         If fileexists(TempPath$ & "ward.dif") Then      '     "
''               'Kill "c:\ward.dif"                       '22Sep98 CFY Replaced
''               Kill TempPath$ & "ward.dif"               '     "
''            End If
''         '---
''
''         'If ConvertFile(file$, dispdata$ & "\ward.dif", 9) Then  'DIF
''         'If ConvertFile(file$, "c:\ward.dif", 9) Then   'DIF              '22Sep98 CFY Replaced
''         If ConvertFile(FILE$, TempPath$ & "ward.dif", 9) Then   'DIF      '     "
''               '05Feb98 EAC/CFY
''               'file$ = dispdata$ & "\ward.dif"
''               'file$ = "c:\ward.dif"                                      '22Sep98 CFY Replaced
''               FILE$ = TempPath$ & "ward.dif"                              '     "
''               '---
''            Else
''               FILE$ = ""
''               popmessagecr "ASCribe", "Could not load file"
''            End If
''         On Error GoTo 0
''      End If
''    '30Dec97 CFY Added ---- End
''
''    On Error GoTo SetDriveErr
''    ChDrive CurDirectory$              '10Sep98 CFY Added
''    On Error GoTo 0
''
      If Trim$(strFile) = "" Then
          Exit Sub
      Else
          Screen.MousePointer = HOURGLASS
          ReadPsionWardStockFile strFile, strWard, Machine
          Screen.MousePointer = STDCURSOR
      End If

ImportWardData_Exit:
Exit Sub

ReadTopupCancelErr:                    '10Sep98 CFY Added

    'trap error number 32755 - Cancel button pressed in Common Dialog
    If Err = 32755 Then
            ''Dctfrm.DirList.filename = ""
        Else
            ''Dctfrm.DirList.filename = ""
            popmessagecr "ERROR", "Module: " & modulename$ & Chr$(13) & "Procedure : " & procname$ & Chr$(13) & "Error Number " & Str$(Err) & " occurred. Please inform EMIS Health."
        End If
    Resume Next

SetDriveErr:                                             '10Sep98 CFY Added
   popmessagecr "", "Error : " & Err & cr & Error$       '         "
   Screen.MousePointer = STDCURSOR                       '         "
   GoTo ImportWardData_Exit                              '         "

End Sub

Sub makereq(wardcode$, reqno$)
'05May98 EAC/CKJ Proc superceded by CreateRequisitionRecord

'Dim ord As orderstruct
'Dim reqpoint&
'Dim siscode$, dateord$, daterec$, qtyord$, contract$
'Dim found%
'
'
'   getnumofords edittype, reqpoint&, True
'
'   getorder ord, (reqpoint&), edittype, True        '<----LOCK (no idx)
'   ord.status = "5"
'   'ord.orddate = thedate(False, False) '03May98 CKJ Y2K
'   ord.orddate = thedate(False, True)   '03May98 CKJ Y2K
'   ord.num = reqno$
'   ord.supcode = ""
'   ord.ward = wardcode$
'   ord.internalsiteno = LTrim$(Str(sitenumber))
'   putorder ord, (reqpoint&)                            '<----UNLOCK  (no idx)
'
'   updateoutstanding Val(ord.outstanding), d'ASC 20Mar93
'   updateordreqindex edittype, "", ord.code, "", ord.num, (reqpoint&)
'   '21Aug95 ASC
'   updateordreqindex 7, "", "", "", ord.supcode, (reqpoint&)
'   '----
'
'   '------make transaction on orderlog for buyer's end----------
'   'IF debug THEN popmessagecr "4", dispdata$ + "!"
'   'dispdata$ = "\dispdata." + RIGHT$("000" + trim$(asciiz$(STR$(sitepaths))), 3)
'   dispdata$ = sitepth$(0)        '6Jan95 CKJ
'   ordernum$ = ord.num
'   siscode$ = ord.code
'   dateord$ = ord.orddate
'   daterec$ = ""
'   qtyord$ = ord.outstanding
'   'IF debug THEN popmessagecr "5", dispdata$ + "!"
'   'orderlog now done when issueing
'   'Now "O" type order for ASCribe internal "I" type produced when stock issued in store
'   LookupDrug ord.code, d, (found) '14Jan94 CKJ Added
'
'   contract$ = ""    '24Feb94 CKJ Contract details
'   If ord.supcode = d.supcode And Val(d.contprice) > 0 Then
'         contract$ = Trim$(d.contno) ' 10 chars wide
'         If contract$ = "" Then contract$ = "CONTRACT"
'         End If
'   Orderlog ordernum$, siscode$, userid$, dateord$, daterec$, qtyord$, "", "", sup.code, "I", sitenumber, contract$, d.vatrate '14Jan94 CKJ VAT '17Feb92 ASC

End Sub

Function PEerrorMessage$(hJob%)
'return appropriate CRW PE error message

Dim success%, TextHandle%, TextLength%, ErrorString$


   success% = PEGetErrorText(hJob%, TextHandle%, TextLength%)
   ErrorString$ = String$(TextLength + 1, " ")
   success% = PEGetHandleString(TextHandle%, ErrorString$, TextLength%)
   PEerrorMessage$ = Trim$(ErrorString$)

End Function

Sub ReadPsionWardStockFile(diffile$, ByVal strWard As String, MachineType%)
'----------------------------------------------------------
'
' Created : 20 November 1996
' Author  : EAC
'
' Notes
'   This procedure assumes the following record layout is
'   presented by the PSION software
'       field(1) : drug description
'       field(2) :
'       field(3) :
'       field(4) :
'       field(5) :
'       field(6) :
'       field(7) :  NSVCode
'       field(8) :  Ward Code
'
'03Dec97 Added MachineType to Parameter List
'29Jan98 CFY removed If Not endoffile condition
'05Feb98 EAC match dif fields to the Crystal Report
'11May98 CFY Added extra condition to filter out description lines
'12Jun98 EAC handle issue of split packs from Ward Stock
'23Jun98 EAC/CFY Stopped lines with a blank top-up level being interpreted as zero.
'                Added extra coide to filter out the first two lines as these are now descriptions.
'                New code added to display the dct form if coming from a right mouse click in
'                the ward stock lists.
'31May02 TH Added new parameter to CreateDeliveryNoteRecord
'02Apr13 TH Changes added to handle a specific ID if available
'----------------------------------------------------------
'18Dec14 TH Now send the ward list line (if available) to the requisition we will create, so we can update the correct line

''Dim snap As snapshot
Dim quantity!
Dim itemunitcost$, batchnumber$, expiry$, lastissueqty$, UnitCost$, NSVCode$, topupqty$
Dim Items$(), tblname$, SiteCode$, lastsitecode$, msg$, SQL$, costcentre$
Dim foundPtr&, PsionHoldsStockOnWard%, done%, exceptions%  '01Jun02 ALL/ATW
Dim difhd%, numoffields%, endoffile%, tofind%, donext%, topuplvl%
Dim numofrecords&, numfound&
Dim PackSize$                                                  '12Jun98 EAC Added
Dim ans$
Dim strxXML As String
Dim xmldoc As MSXML2.DOMDocument
Dim lngFound As Long
Dim xmlNodeList  As MSXML2.IXMLDOMNodeList
Dim xmlnode As MSXML2.IXMLDOMNode
Dim strParams As String
Dim rsWardStock As ADODB.Recordset
Dim blnExceptions As Boolean
Dim strArchiveFile As String
Dim intProcessed As Integer
Dim strArchivePath As String
Dim intloop As Integer
Dim blnNameOK As Boolean
Dim strMsg As String
Dim lngWWardStockListID As Long '02Apr13 TH initialise (TFS 58711)


   If Not Dctfrm.Visible Then                '23Jun98 EAC/CFY Added
          Dctfrm.Show 0                      '           "
          Dctfrm.MnuChkView.Checked = True   '           "
      End If                                 '           "

    If Not Dctfrm.MnuChkView.Checked Then
            k.escd = False
            ans$ = "N"
            Confirm "IMPORT FILE", "Import for " + strWard + " and book out all those items without problems", ans$, k
            If ans$ = "N" Or k.escd Then diffile$ = "": Exit Sub   '<== WAY OUT
        End If


    PsionHoldsStockOnWard% = (TxtD$(dispdata$ & "\stockl.ini", "", "Y", "PsionHoldsStockLvl", 0) = "Y")

    difhd = FreeFile
    Open diffile$ For Binary Lock Read Write As difhd
    
    'chan = FreeFile
    '  Open strFile For Binary As #chan
      strxXML = Space$(LOF(difhd))
      Get #difhd, , strxXML
      Close #difhd

    'find first record
    'If MachineType = 0 Then ReadDifInfo difhd, numoffields, numofrecords&, tblname$, False
    'If MachineType = 1 Then ReadDifInfo difhd, numoffields, numofrecords&, tblname$, True

    'ReDim items$(1 To numoffields)
    
    Set xmldoc = New MSXML2.DOMDocument
    
    If xmldoc.loadXML(strxXML) Then
      Set xmlNodeList = xmldoc.selectNodes("wardstockrequisitions/wards/ward/line")
         
         For Each xmlnode In xmlNodeList
         
            lngWWardStockListID = 0 '02Apr13 TH initialise (TFS 58711)
         
            donext = True
            quantity! = 0

            SiteCode$ = strWard
            NSVCode$ = xmlnode.selectSingleNode("nsvcode").text
            PackSize$ = xmlnode.selectSingleNode("packsize").text
            topupqty$ = xmlnode.selectSingleNode("topupqty").text
            
            
            If Val(PackSize$) <= 0 Then PackSize$ = "1"    '   "
'This nay be needed  later
            If SiteCode$ <> lastsitecode$ Then
                getsupplier SiteCode$, 0, lngFound, sup
                lastsitecode$ = SiteCode$
            End If
            
            If lngFound = 0 Then
                msg$ = SiteCode$ & TB & " " & TB & " " & TB & "Ward not found"
                donext = False
            End If
                            
            If donext Then
               If Trim$(NSVCode$) = "&" Then donext = False
            End If
            
            If donext Then
               'SQL$ = "SELECT topuplvl FROM Layout WHERE (NSVCode = '" & Trim$(NSVCode$) & "' AND SiteName = '" & Trim$(SiteCode$) & "');"
               'Set snap = WSDB.CreateSnapshot(SQL$)
               If InStr(strxXML, "WWardStockListID") > 0 Then
                  lngWWardStockListID = CLng(xmlnode.selectSingleNode("WWardStockListID").text)
                  strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, lngWWardStockListID)
                  Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListByWWardStockListIDForImport", strParams)

               Else
                  strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
                  gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(SiteCode$)) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, Trim$(NSVCode$))
                  Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListBySiteNameandNSVCodeForImport", strParams)
               End If
               If Not rsWardStock.EOF Then
                   'check drug has a topup qnty defined
                   topuplvl = RtrimGetField(rsWardStock!topuplvl)
                   If PsionHoldsStockOnWard And topuplvl <= 0 Then
                      donext = False
                      msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & "no topup quantity defined in Ward Stock List"
                  End If
               Else
                   donext = False
                   msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & "item not found in ward stock list for " & Trim$(SiteCode$)
               End If
               rsWardStock.Close
               Set rsWardStock = Nothing
            End If
            
            If donext Then
               'check if we need to issue
               d.SisCode = Trim$(NSVCode$)
               getdrug d, 0, foundPtr, False  '01Jun02 ALL/ATW
               If foundPtr Then                      '01Jun02 ALL/ATW
                  If PsionHoldsStockOnWard Then
                     If trimz$(topupqty$) <> "" Then quantity! = topuplvl - Val(topupqty$)
                  Else
                      quantity! = Val(topupqty$)
                  End If
                  quantity! = quantity! * Val(PackSize$)   '12Jun98 EAC handle splict packs
                  If quantity! <= 0 Then
                     donext = False
                     msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & "Issue quantity is equal to zero. No issue neccessary."
                  End If
               Else
                   msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & Trim$(Str$(quantity!)) & TB & "not found in drug file."
                   donext = False
               End If
            End If
            
            If donext Then
               'check if there is enough stock
               If (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "N") Or (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "Y") Then
                  If Val(d.stocklvl) - quantity! < 0 Then
                      msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & Trim$(Str$(quantity!)) & TB & "stock level too low to issue."
                      donext = False
                  End If
               End If
            End If

            If donext Then
               'check if there is enough stock
               If (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "N") Or (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "Y") Then
                  If quantity! > Val(d.maxissue) Then
                      msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & Trim$(Str$(quantity!)) & TB & "issue above maximum."
                      donext = False
                  End If
               End If
            End If

            If donext Then
               'check if there is enough stock
               If (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "N") Or (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "Y") Then
                  If quantity! < Val(d.minissue) Then
                     msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & Trim$(Str$(quantity!)) & TB & "issue below minimum."
                     donext = False
                  End If
               End If
            End If
            
            If donext Then
               If Trim$(sup.wardcode) = "" Then
                  msg$ = "Select the new Cost Centre Code"
                  'AskSupplier WardCode$, 0, 2, msg$
                  DisplayWardCodes costcentre$, msg$
                  If Trim$(costcentre$) = "" Then
                     donext = False
                     msg$ = "No cost centre defined for Ward Stock List " & SiteCode$
                  End If
               Else
                  costcentre$ = sup.wardcode
               End If
            End If

            If donext And Not Dctfrm.MnuChkView.Checked Then
               If (sup.PrintDeliveryNote = "N" And sup.PrintPickTicket = "N") Then
                  'debit stock and update translog
                  Translog d, 0, UserID, "", quantity, "", costcentre$, "", "S", SiteNumber, "H", itemunitcost$
                  intProcessed = intProcessed + 1
                  ''Update the ward stock list if necessary.
                  'UpdateWardStockListIssueData d.SisCode, sup.wardcode, "DCT", CInt(quantity) '27Jun11 TH Added
                  'UpdateWardStockListIssueData d.SisCode, sup.wardcode, "DCT", CLng(quantity) '11Apr14 TH Coerce to long (TFS 88720)
                  UpdateWardStockListIssueData d.SisCode, sup.wardcode, "DCT", CLng(quantity), lngWWardStockListID '18Dec14 TH Added new param
               ElseIf (sup.PrintDeliveryNote = "Y" And sup.PrintPickTicket = "N") Then
                  'create a Delivery note record
                  ''28Jun11 TH Surely this should also update stock !!!!!!
                  '10Jul11 TH F???
                  'debit stock and update translog
                  Translog d, 0, UserID, "", quantity, "", costcentre$, "", "S", SiteNumber, "H", itemunitcost$
                  'UpdateWardStockListIssueData d.SisCode, sup.wardcode, "DCT", CInt(quantity) '27Jun11 TH Added
                  'UpdateWardStockListIssueData d.SisCode, sup.wardcode, "DCT", CLng(quantity) '11Apr14 TH Coerce to long (TFS 88720)
                  UpdateWardStockListIssueData d.SisCode, sup.wardcode, "DCT", CLng(quantity), lngWWardStockListID  '18Dec14 TH Added new param
                  '10Jul11 TH End
                  
                  If PrintInPacks Then quantity! = quantity! / Val(d.convfact)  '12Jun98 EAC handle qty print on picks/del notes in Print In Packs turned on
                  CreateDeliveryNoteRecordSQL quantity!, UnitCost$, costcentre$, 0, False '31May02 TH Added new parameter
                  intProcessed = intProcessed + 1
               ElseIf (sup.PrintPickTicket = "Y") Then
                  'create  a requistion record
                  If PrintInPacks Then quantity! = quantity! / Val(d.convfact)  '12Jun98 EAC handle qty print on picks/del notes in Print In Packs turned on
                  '29May12 TH Check if item is DLO
                  
                  CreateRequisitionRecordSQL quantity!, ordernum$, costcentre$, lngWWardStockListID  '02Apr13 TH Added lineID param (TFS 58711)
                  intProcessed = intProcessed + 1
               End If

            Else
                If msg$ <> "" Then
                  Dctfrm.LstDCTimport.AddItem msg$
                  'LstBoxFrm.LstBox.AddItem msg$
                  blnExceptions = True
                End If
            End If
            
         Next
         Screen.MousePointer = STDCURSOR
         If (sup.PrintDeliveryNote = "N" And sup.PrintPickTicket = "N") Then
            strMsg = Format$(intProcessed) & " transactions processed"
         ElseIf (sup.PrintDeliveryNote = "Y" And sup.PrintPickTicket = "N") Then
            strMsg = Format$(intProcessed) & " delivery note lines created"
         ElseIf (sup.PrintPickTicket = "Y") Then
            strMsg = Format$(intProcessed) & " picking ticket lines created"
         Else
            strMsg = Format$(intProcessed) & " lines processed"
         End If
         
         If (Not blnExceptions) And Dctfrm.MnuChkView.Checked Then
            popmessagecr "Ward Stock Import", "File loaded and checked without exceptions"
         ElseIf (blnExceptions) And (Dctfrm.MnuChkView.Checked) Then
            popmessagecr "Ward Stock Import", "File loaded and checked with exceptions"
         ElseIf (Not blnExceptions) And (Not Dctfrm.MnuChkView.Checked) Then
            popmessagecr "Ward Stock Import", "File loaded and processed without exceptions" & crlf & crlf & strMsg
         ElseIf (blnExceptions) And (Not Dctfrm.MnuChkView.Checked) Then
            popmessagecr "Ward Stock Import", "File loaded and processed with exceptions" & crlf & crlf & strMsg
         End If
         
         If Not Dctfrm.MnuChkView.Checked Then
            'Archive the file now
            strArchivePath = TxtD(dispdata$ & "\winord.ini", "wardstocklist", "", "ArchivePath", 0) '22Sep98 CFY
            If Trim$(strArchivePath) = "" Then
               popmessagecr "EMIS Health", "Ward Stock File Archive path has not been configured for this site." & crlf & crlf & "The import file for " & strWard & " cannot be removed and archived."
            Else
               If Not (DirExists(strArchivePath)) Then
                  popmessagecr "EMIS Health", "Ward Stock File Archive directory - " & strArchivePath & " cannot be found or is not available." & crlf & crlf & "The import file for " & strWard & " cannot be removed and archived."
               Else
                  'OK we are ready to go Lets see if we can "slot" the file home
                  strArchiveFile = strWard & "_" & Format(Now, "DDMMYYYY") & "_AI.xml"
                  If fileexists(strArchivePath & "\" & strArchiveFile) Then
                     'OK. Lets find another alternative
                     For intloop = 65 To 90 Step 1
                        strArchiveFile = strWard & "_" & Format(Now, "DDMMYYYY") & Chr$(intloop) & "_AI.xml"
                        If Not fileexists(strArchivePath & "\" & strArchiveFile) Then
                           blnNameOK = True
                           Exit For
                        End If
                     Next
                  Else
                     blnNameOK = True
                  End If
                  If blnNameOK = True Then
                     'Good to go. Copy then kill
                     FileCopy diffile$, strArchivePath & "\" & strArchiveFile
                     Kill diffile$
                  Else
                     popmessagecr "EMIS Health", "There are too many archives for this ward for today" & crlf & crlf & "The import file for " & strWard & " cannot be removed and archived."
                  End If
               End If
            End If
         
         End If
    Else
      'Could not load  XML message
      popmessagecr "EMIS Health", "Unable to load xml import file." & crlf & crlf & "The import file for " & strWard & " cannot be loaded by the XML control."
    End If

    'read each record from the file
''''    While Not endoffile
''''
''''        'read next record
''''        'ReDim items$(1 To numoffields)
''''
''''        GetNextDifRecord difhd, items$(), endoffile
''''
''''        'If Not endoffile Then                 '29Jan98 CFY removed
''''                numfound& = numfound& + 1
''''
''''               If numfound <= 2 Then           '23Jun98 EAC/CFY Added
''''                     donext = False            '         "
''''                  Else
''''                'start checks
''''                donext = True
''''                quantity! = 0
''''
''''                'sitecode$ = Trim$(items$(8))
''''                SiteCode$ = Trim$(items$(UBound(items$)))
''''                NSVCode$ = Trim$(items$(UBound(items$) - 1))
''''                'topupqty$ = Trim$(items$(UBound(items$) - 4)) '05Feb98 EAC changed to match Crystal Report
''''                topupqty$ = Trim$(items$(UBound(items$) - 2))
''''                packsize$ = Trim$(items$(UBound(items$) - 3))  '12Jun98 EAC added
''''                If Val(packsize$) <= 0 Then packsize$ = "1"    '   "
''''
''''                If SiteCode$ <> lastsitecode$ Then
''''                        getsupplier SiteCode$, 0, lngFound, sup
''''                        lastsitecode$ = SiteCode$
''''                    End If
''''
''''                If lngFound = 0 Then
''''                        msg$ = SiteCode$ & TB & " " & TB & " " & TB & "Ward not found"
''''                        donext = False
''''                    End If
''''                  End If
''''
''''                '11May98 CFY Added
''''                If donext Then
''''                     If Trim$(NSVCode$) = "&" Then donext = False
''''                  End If
''''
''''                If donext Then
''''''                        SQL$ = "SELECT topuplvl FROM Layout WHERE (NSVCode = '" & Trim$(NSVCode$) & "' AND SiteName = '" & Trim$(SiteCode$) & "');"
''''''                        Set snap = WSDB.CreateSnapshot(SQL$)
''''''                        If Not snap.EOF Then
''''''                                'check drug has a topup qnty defined
''''''                                topuplvl = GetField(snap!topuplvl)
''''''                                If PsionHoldsStockOnWard And topuplvl <= 0 Then
''''''                                        donext = False
''''''                                        msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & "no topup quantity defined in Ward Stock List"
''''''                                    End If
''''''                            Else
''''''                                donext = False
''''''                                msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & "item not found in ward stock list for " & Trim$(SiteCode$)
''''''                            End If
''''                    End If
''''
''''                If donext Then
''''                        'check if we need to issue
''''                        d.SisCode = Trim$(NSVCode$)
''''                        getdrug d, 0, foundPtr, False  '01Jun02 ALL/ATW
''''                        If foundPtr Then                      '01Jun02 ALL/ATW
''''                                If PsionHoldsStockOnWard Then
''''                                       If trimz$(topupqty$) <> "" Then quantity! = topuplvl - Val(topupqty$)
''''                                    Else
''''                                        quantity! = Val(topupqty$)
''''                                    End If
''''                                quantity! = quantity! * Val(packsize$)   '12Jun98 EAC handle splict packs
''''                                If quantity! <= 0 Then
''''                                       donext = False
''''                                       msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & "Issue quantity is equal to zero. No issue neccessary."
''''                                    End If
''''                            Else
''''                                msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & Trim$(Str$(quantity!)) & TB & "not found in drug file."
''''                                donext = False
''''                            End If
''''                    End If
''''
''''                If donext Then
''''                        'check if there is enough stock
''''                        If (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "N") Or (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "Y") Then
''''                                If Val(d.stocklvl) - quantity! < 0 Then
''''                                        msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & Trim$(Str$(quantity!)) & TB & "stock level too low to issue."
''''                                        donext = False
''''                                    End If
''''                            End If
''''                    End If
''''
''''                If donext Then
''''                        'check if there is enough stock
''''                        If (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "N") Or (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "Y") Then
''''                                If quantity! > Val(d.maxissue) Then
''''                                        msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & Trim$(Str$(quantity!)) & TB & "issue above maximum."
''''                                        donext = False
''''                                    End If
''''                            End If
''''                    End If
''''
''''                If donext Then
''''                        'check if there is enough stock
''''                        If (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "N") Or (sup.PrintPickTicket = "N" And sup.PrintDeliveryNote = "Y") Then
''''                                If quantity! < Val(d.minissue) Then
''''                                        msg$ = Trim$(SiteCode$) & TB & Trim$(NSVCode$) & TB & Trim$(Str$(quantity!)) & TB & "issue below minimum."
''''                                        donext = False
''''                                    End If
''''                            End If
''''                    End If
''''
''''                If donext Then
''''                        If Trim$(sup.wardcode) = "" Then
''''                              msg$ = "Select the new Cost Centre Code"
''''                              'AskSupplier WardCode$, 0, 2, msg$
''''                              DisplayWardCodes costcentre$, msg$
''''                              If Trim$(costcentre$) = "" Then
''''                                    donext = False
''''                                    msg$ = "No cost centre defined for Ward Stock List " & SiteCode$
''''                                 End If
''''                           Else
''''                              costcentre$ = sup.wardcode
''''                           End If
''''                     End If
''''
''''                If donext And Not Dctfrm.MnuChkView.Checked Then
''''                        If (sup.PrintDeliveryNote = "N" And sup.PrintPickTicket = "N") Then
''''                                'debit stock and update translog
''''                                Translog d, 0, UserID, "", quantity, "", costcentre$, "", "S", SiteNumber, "H", itemunitcost$
''''                            ElseIf (sup.PrintDeliveryNote = "Y" And sup.PrintPickTicket = "N") Then
''''                                'create a Delivery note record
''''                                If PrintInPacks Then quantity! = quantity! / Val(d.convfact)  '12Jun98 EAC handle qty print on picks/del notes in Print In Packs turned on
''''                                CreateDeliveryNoteRecordSQL quantity!, UnitCost$, costcentre$, 0 '31May02 TH Added new parameter
''''                            ElseIf (sup.PrintPickTicket = "Y") Then
''''                                'create  a requistion record
''''                                If PrintInPacks Then quantity! = quantity! / Val(d.convfact)  '12Jun98 EAC handle qty print on picks/del notes in Print In Packs turned on
''''                                CreateRequisitionRecordSQL quantity!, ordernum$, costcentre$
''''                            End If
''''
''''                    Else
''''                        Dctfrm.LstDCTimport.AddItem msg$
''''                        'LstBoxFrm.LstBox.AddItem msg$
''''                        'exceptions = True
''''                    End If
''''        '    End If                            '29Jan98 CFY removed
''''
''''    Wend

    'Screen.MousePointer = NORMAL
    'If exceptions Then
    '        LstBoxFrm.Caption = "Psion Stock List Exceptions"
    '        LstBoxFrm.lblHead = "NSVCode    " & TB & "Exception"
    '        LstBoxFrm.CmdOk.Caption = "&Print"
    '        LstBoxShow
    '        Unload LstBoxFrm
    '    End If

   'Close #difhd
   
   ''??Killfile ? Archive !!!!

''   If numfound& <> numofrecords& Then
''      popmessagecr "Error", "Procedure : ReadPsionWardStockList" & Chr$(13) & "Module   : WSLIST.BAS" & Chr$(13) & "Expected " & Trim$(Str$(numofrecords&)) & " records : read " & Trim$(Str$(numfound&)) & " records."
''   End If
End Sub

Sub startup()
'17May04 ckj removed sethelp

ReDim TabStops(10) As Long
Dim i%, x%

    k.HelpFile = "dctimp.hlp"
    setinput 0, k
    'sethelp                                         '17May04 ckj removed sethelp

    If fileexists("\ascpsion\mclink.exe") Then
            Dctfrm.MnuPsion3(0).Enabled = True
            Dctfrm.MnuPsion3(1).Enabled = True
            Dctfrm.MnuPsion3(2).Enabled = True
            Dctfrm.MnuPsion3(3).Enabled = True
        End If

    Dctfrm.LblHeader = "Ward " & TB & "Description" & Space$(33 - Len("Description")) & TB & "Qty       " & TB & "Problem " & TB & "Barcode      " & TB & "User "
   
    i = 0  'number of tabstops found
    x = 0  'position in string
    Do
    x = InStr(x + 1, Dctfrm.LblHeader, TB)
    If x Then
            i = i + 1
            TabStops(i) = x * 4
        End If
    Loop While x > 0
    
    ListBoxTextBoxSetTabs Dctfrm.LstHdr, (i), TabStops()     'clear old & set new tabstops
    ListBoxTextBoxSetTabs Dctfrm.LstDCTimport, (i), TabStops()     '(just clears if none found)

    Dctfrm.LstHdr.Clear
    Dctfrm.LstHdr.AddItem Dctfrm.LblHeader
    Dctfrm.LstHdr.Visible = True
    Dctfrm.LstHdr.Top = Dctfrm.LblHeader.Top - 15
    Dctfrm.LstHdr.Width = Dctfrm.LstDCTimport.Width


End Sub

Sub WritePsionWardStockFile(wardcode$, Index)
'----------------------------------------------------------
'
' Created : 25 November 1996
' Author  : EAC
'
' Notes
'   This procedure assumes the following record layout is
'   presented by the PSION software
'       field(1) : drug description
'       field(2) : blank
'       field(3) : blank
'       field(4) : qty on ward
'       field(5) : pack size
'       field(6) : topup qty
'       field(7) : NSVCode
'       field(8) : Ward Code
'
'11Nov97 EAC Add code to allow writing of .XLS files for Windows CE
'03Dec97 EAC Only export data for a specific ward
'            Add MOVEFIRST,MOVELAST for COUNT statement as a precaution
'08Dec97 EAC Use Crystal to generate DIF and XLS files
'11Mar98 CFY Changed Selection formula to export the description lines.
'12May98 EAC/CFY/SF use Crystal DLLs to output data to file
'22Jun98 EAC/CFY added Index to subroutine parameters
'08Jul98 CFY Removed OLE code that converts .dif file to a .xls as it causes
'            a gpf in kernal386. As yet we do not know the cause eof this.
'16Jul98 CFY Changed destination of where .dif files are written
'19Apr00 AE  Made screen.mousepointer = hourglass before starting export
'19Jul11 TH  Altered spelling on export set up error (F0123242)
'08Apr15 XN  114692 prevent title line from showing packsize in output file
'06Dec16 TH  Replaced RTF Handling (TFS 157969)
'----------------------------------------------------------

Const xlExcel5 = 39
Const xlDIF = 9

Dim msg$
Dim ErrNum%

Dim hJob%, dummy%
Dim Options As PEExportOptions
Dim location As PETableLocation
Dim Formula As String
Dim FileObject As Object                        '22Jun98 EAC/CFY added
Dim inputfile$, outputfile$, datadrv$           '          "
Dim converted%                                  '          "
Dim ExportPath$
Dim suplocal As supplierstruct
Dim strHeader As String
Dim strFooter As String
Dim strOutfile As String
Dim strTempFile As String
Dim devno As Integer
Dim strTempData As String
Dim strData As String
Dim strParams As String
Dim rsWardStock As ADODB.Recordset
Dim strTemp As String
Dim intLines As Integer
Dim bIsDrugLine As Boolean  ' XN 8Apr15 114692 prevent title line from showing packsize in output file
'Dim strTemp As String

   '12May98 EAC/CFY/SF
   ' DCTFrm.report.ReportFileName = dispdata$ & "\wardexpt.rpt"
   ' DCTFrm.report.DataFiles(0) = dispdata$ & "\wslist.mdb"
   ' DCTFrm.report.PrintFileName = wardcode$
   ' 'DCTFrm.Report.Destination = 2 'print to file
   ' DCTFrm.report.Destination = 0 'screen preview
   ' 'DCTFrm.Report.SelectionFormula = "{Layout.NSVcode} <> '&' AND {Layout.SiteName} = '" & Trim$(wardcode$) & "'"
   ' DCTFrm.report.SelectionFormula = "{Layout.SiteName} = '" & Trim$(wardcode$) & "'"
   ' On Error GoTo CrystalRepErr
   ' DCTFrm.report.Action = 1
   ' On Error GoTo 0
   '---
   On Error GoTo ExportErr
   
   intLines = 0
   Screen.MousePointer = HOURGLASS                 '19Apr00 AE  Added

   ExportPath$ = TxtD(dispdata$ & "\winord.ini", "WardStockList", dispdata$, "ExportPath", 0)

   'If fileexists(ExportPath$ & "\" & wardcode$ & ".dif") Then Kill ExportPath$ & "\" & wardcode$ & ".dif"
   
   If fileexists(ExportPath$ & "\" & Trim$(wardcode$) & "_AO.xml") Then Kill ExportPath$ & "\" & Trim$(wardcode$) & "_AO.xml"
   
   strOutfile = ExportPath$ & "\" & Trim$(wardcode$) & "_AO.xml"
   MakeLocalFile strTempFile
   devno = FreeFile
   Open strTempFile For Binary Access Write Lock Read Write As devno
            
   'Pop the required elements on to the heap.
   
   getsupplier wardcode$, 0, 0, suplocal
   
   FillHeapSupplierInfo gPRNheapID, suplocal, 0   '25Jan05 TH Added '17Nov05 TH Merged
               
               
   
   'Get,parse and write the header
   'GetTextFile dispdata$ & "\WSExpHdr.rtf", strHeader, 0
   GetRTFTextFromDB dispdata$ & "\WSExpHdr.rtf", strHeader, 0  '06Dec16 TH Replaced (TFS 157969)
   
   ParseItems gPRNheapID, strHeader, 0
   
   Put #devno, , strHeader
   
   'Here we will load the information for the main lines of  the export file
   
   strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gWardStockSite) & _
               gTransport.CreateInputParameterXML("SiteName", trnDataTypeVarChar, 5, Trim$(wardcode$))
   Set rsWardStock = gTransport.ExecuteSelectSP(g_SessionID, "pWWardStockListBySiteNameForExport", strParams)
   
   '''On Error GoTo loadwarderr
   If Not rsWardStock.EOF Then
      'GetTextFile dispdata$ & "\WSExpData.rtf", strData, 0
      GetRTFTextFromDB dispdata$ & "\WSExpData.rtf", strData, 0  '06Dec16 TH Replaced (TFS 157969)

      rsWardStock.MoveFirst
      Do Until rsWardStock.EOF
         bIsDrugLine = Len(Trim$(RtrimGetField(rsWardStock!NSVCode))) >= 7      ' XN 8Apr15 114692 prevent title line from showing packsize in output file
      
         'OK we have a row. we need to pop therequriedstuff on the heap, parse and add
         Heap 10, gPRNheapID, "wsTitleText", Trim$(RtrimGetField(rsWardStock!titletext)), 0
         strTemp = (Trim$(RtrimGetField(rsWardStock!titletext)))
         EscapeXML strTemp
         Heap 10, gPRNheapID, "wsTitleTextXML", strTemp, 0
         Heap 10, gPRNheapID, "wsPacksize", Iff(bIsDrugLine, Trim$(RtrimGetField(rsWardStock!PackSize)), ""), 0 ' XN 8Apr15 114692 prevent title line from showing packsize in output file Heap 10, gPRNheapID, "wsPacksize", Trim$(RtrimGetField(rsWardStock!PackSize)), 0
         Heap 10, gPRNheapID, "wsNSVCode", Trim$(RtrimGetField(rsWardStock!NSVCode)), 0
         strTemp = (Trim$(RtrimGetField(rsWardStock!NSVCode)))
         EscapeXML strTemp
         Heap 10, gPRNheapID, "wsNSVCodeXML", strTemp, 0
         Heap 10, gPRNheapID, "wsbarcode", Trim$(RtrimGetField(rsWardStock!barcode)), 0
         strTemp = Trim$(RtrimGetField(rsWardStock!barcode))
         plingparse strTemp, "*"
         Heap 10, gPRNheapID, "wsbarcodeDigits", strTemp, 0 '15Oct09 TH Parse asterisks if required.
         Heap 10, gPRNheapID, "wsTopUpLvl", Iff(bIsDrugLine, Trim$(RtrimGetField(rsWardStock!topuplvl)), ""), 0 ' XN 8Apr15 114692 prevent title line from showing packsize in output file Heap 10, gPRNheapID, "wsTopUpLvl", Trim$(RtrimGetField(rsWardStock!topuplvl)), 0
         
         '02Apr13 TH Added to extend interface (TFS 58711)
         Heap 10, gPRNheapID, "wsWWardStockListID", RtrimGetField(rsWardStock!WWardStockListID), 0
         Heap 10, gPRNheapID, "wsPrintLabel", Trim$(RtrimGetField(rsWardStock!PrintLabel)), 0
         
         strTempData = strData
                 
         ParseItems gPRNheapID, strTempData, 0
         Put #devno, , strTempData
         rsWardStock.MoveNext
         intLines = intLines + 1
      Loop
   End If
   
   rsWardStock.Close
   Set rsWardStock = Nothing
   
   'Get,parse and write the footer
   'GetTextFile dispdata$ & "\WSExpFtr.rtf", strFooter, 0
   GetRTFTextFromDB dispdata$ & "\WSExpFtr.rtf", strFooter, 0  '06Dec16 TH Replaced (TFS 157969)

   
   ParseItems gPRNheapID, strFooter, 0
   
   Put #devno, , strFooter
   
   'Close channel to the local file. Move to export folder, kill local file
   
   Close #devno
            
   FileCopy strTempFile, strOutfile  '16Nov05 TH Replaced above line to allow configurable file extension
                           
   Kill strTempFile
   Screen.MousePointer = STDCURSOR
   If Trim$(wardcode$) <> Trim$(suplocal.name) Then
      popmessagecr "EMIS Health", "Export file for " & Trim$(wardcode$) & " - " & Trim$(suplocal.name) & " completed with " & Format$(intLines) & " lines written."
   Else
      popmessagecr "EMIS Health", "Export file for " & Trim$(wardcode$) & " completed with " & Format$(intLines) & " lines written."
   End If
   
   
   'Gubbins
''   dummy = PEOpenEngine()
''   If dummy = 0 Then
''         msg$ = PEerrorMessage(hJob)
''         popmessagecr "", msg$
''      End If
''
''   hJob = PEOpenPrintJob(dispdata$ & "\wardexpt.rpt")
''   ' force print engine to refresh the data
''   If hJob = 0 Then popmessagecr "", PEerrorMessage(hJob)
''
''   dummy = PEDiscardSavedData(hJob)
''
''   location.location = dispdata$ & "\WSLIST.MDB" & Chr$(0)
''   location.StructSize = Len(location)
''   dummy = PESetNthTableLocation(hJob, 0, location)
''   If dummy <> 1 Then
''         msg$ = PEerrorMessage(hJob)
''         popmessagecr "Location", msg$
''      End If
''
''   Formula = "{Layout.SiteName} = '" & Trim$(wardcode$) & "'" & Chr$(0)
''   dummy = PESetSelectionFormula(hJob, Formula)
''   If dummy <> 1 Then
''         msg$ = PEerrorMessage(hJob)
''         popmessagecr "Selection Formula", msg$
''      End If
''
''   Options.FormatDLLName = "uxfxls.dll" & Chr$(0)
''   Options.FormatType = 2
''   Options.FormatOptions = 0
''   Options.DestinationDLLName = "uxddisk.dll" & Chr$(0)
''   Options.DestinationType = 0
''   'Options.destinationOptions = DiskOptionsPtr%
''   Options.StructSize = Len(Options)
''
''   ' create export
''   dummy = PEOutputToFile(ByVal hJob%, ExportPath$ & "\" & wardcode$ & ".dif", 3, Options)     '22Jun98 EAC/CFY was .xls
''
''   dummy = PEStartPrintJob(hJob%, True)
''
''
''   ' release handle
''   PEClosePrintJob hJob
''
''
''   PECloseEngine

Cleanup:
On Error Resume Next
Close #devno
rsWardStock.Close
Set rsWardStock = Nothing
On Error GoTo 0
   
    '08Jul98 CFY Removed block
'   Screen.MousePointer = HOURGLASS
'   If index = 1 Then
'         converted = True
'         datadrv$ = Left$(CurDir$, 2)
'         inputfile$ = datadrv$ & dispdata$ & "\" & wardcode$ & ".DIF"
'         outputfile$ = datadrv$ & dispdata$ & "\" & wardcode$ & ".XLS"
'
'         On Error GoTo Excel_ConvertFile_Error
'         Set FileObject = CreateObject("Excel.Sheet")
'         FileObject.Application.Workbooks.open inputfile$, , , , , , , , , , , xlDIF
'         FileObject.Application.ActiveWorkbook.SaveAs outputfile$, xlExcel5
'      End If

   

Exit Sub

ExportErr:

   ErrNum = Err
   'msg$ = "An error occured while trying to create teh export."
   msg$ = "An error occured while trying to create the export."  '19Jul11 TH Altered spelling (F0123242)
   msg$ = msg$ & cr$ & cr$ & "Error Number: " & Format$(ErrNum)
   msg$ = msg$ & cr$ & "Error Description: " & Error$(ErrNum)
   msg$ = msg$ & cr$ & cr$ & "Please report this error to your System Supervisor."
   Screen.MousePointer = STDCURSOR
   popmessagecr "Error", msg$
   
   Resume Cleanup

'Excel_ConvertFile_Error:
'   converted = False
'   Screen.MousePointer = STDCURSOR
'   msg$ = "An error occurred trying to convert from DIF to Excel 5.0." & cr$
'   msg$ = msg$ & "Error No: " & Format$(Err) & cr$
'   msg$ = msg$ & "Error Msg: " & Error$(Err) & cr$
'   popmessagecr "Error", msg$
'   Screen.MousePointer = HOURGLASS
'   GoTo Excel_ConvertFile_Exit

End Sub

Sub ClearListBox()

Dim ans$


   If Len(loadedfile$) Then
         ans$ = "N"
         Confirm "Exiting could allow file to be booked out again", "exit without deleting file", ans$, k
      End If
   If ans$ = "Y" Then
         Do While Dctfrm.LstDCTimport.ListCount
            Dctfrm.LstDCTimport.RemoveItem 0
         Loop
         loadedfile$ = ""
      End If

End Sub

