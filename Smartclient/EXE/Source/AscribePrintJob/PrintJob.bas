Attribute VB_Name = "PrintJob"
'------------------------------------------------------------------------------------------
'                    PrintJob
'                   ----------
'
'17Sep10 CKJ written
'            Minimalist print job handler with command line parameters for file and options
'            Usage:
'              AscribePrintJob pathfile|printerdriverport|X|T|L|R|B
'                 pathfile must be rtf format
'                 printer,driver,port is optional but if used must be valid
'                 X is layout override, L or P for landscape or potrait, optional
'                 T,L are top,left margins in cm or P for physical margins, optional
'                 R,B are right,bottom margins in cm, optional
'            Example:
'              AscribePrintJob C:\file.rtf|Epson,winspool,LPT1:|L|P|P|0.1|0.1
'              AscribePrintJob L:\label.tmp
'                 (defaults are used including current Windows default printer)
'
'            If printing cannot be completed for any reason, a modal dialog is shown.
'            Nothing is passed back to the calling program.
'
'15Dec10 CKJ Any error in parameter list stops at first problem instead of carrying on.
'            Made printer|driver|port comparison case insensitive
'            Added icon to MsgBox                          (RCN P0573 F0104170 10.5 branch)
'23Dec10 CKJ Exe does not always close if an error occurs so added End.  (F0104815 from F0104170 testing)
'03May16 XN  Added Main ability to select printer (so moved this file from main pharmacy) 123082
'12Jul19 AS PBI - 246985 : Task 249234 - Removing/change hiedit printing to TxTextControl in Printjob,
'                          Task 249237 - Dev-use the printjob executable for printing,
'                          Task 249240
'19 july AS Bug - 250786 : Printing from Pharmacy prompts user to save file rather than sending to default printer
'------------------------------------------------------------------------------------------

Option Explicit
DefBool A-Z

Global Const PROJECT = "Print Job "

Sub Main()

Dim posn As Integer
Dim cmd As String
Dim pathfile As String
Dim res As Integer
Dim OldPrinterDriverPort As String
Dim NewPrinterDriverPort As String
Dim Override As String
Dim msgtitle As String
Dim success As Boolean
Dim PrinterDriverPort$, tmp$
Dim llResult As Long
Dim DefPrntr%
Dim Prn As Object
Dim i As Integer, X As Integer
Dim TabStops(25) As Long
Dim citrixify As Boolean
'stat : Bug : 250786
Dim newPrinterDeviceName As String
Dim newPrinterDeviceEndPosition As Integer
Dim oldPrinterDeviceName As String
Dim oldPrinterDeviceEndPosition As Integer
'end : Bug : 250786

   msgtitle = App.EXEName
   cmd = Command
   citrixify = False
   ' If input parameter is SELECTPRINT then allows the user to select the printer
   ' 03May16 XN 123082
   If UCase$(cmd) = "SELECTPRINT" Then
        Unload LstBoxFrm
        LstBoxFrm.Caption = "EMIS Health"
        LstBoxFrm.lblTitle.Caption = cr & "Select printer" & cr
        LstBoxFrm.lblHead.Caption = "Printer Name" & Space$(30) & TB & "Driver" & Space$(5) & TB & "Port" & Space$(20) & "."
        HighEdit.He.GetInstancePrinter PrinterDriverPort$, DefPrntr
        replace PrinterDriverPort$, ",", TB, 0
        LstBoxFrm.LstBox.AddItem PrinterDriverPort$
        
        For Each Prn In Printers
           tmp$ = Prn.DeviceName & TB & Prn.DriverName & TB & Prn.Port
           If Right$(tmp$, 4) <> "PUB:" And tmp$ <> PrinterDriverPort$ Then
                 LstBoxFrm.LstBox.AddItem tmp$
              End If
        Next
           
        LstBoxFrm.LstBox.Top = LstBoxFrm.LstHdr.Top + LstBoxFrm.LstHdr.Height
            
        i = 0  'number of tabstops found
        X = 0  'position in string
        Do
            X = InStr(X + 1, LstBoxFrm.lblHead, TB)
            If X Then
                i = i + 1
                TabStops(i) = X * 4
            End If
        Loop While X > 0
        ListBoxTextBoxSetTabs LstBoxFrm.LstHdr, (i), TabStops()     'clear old & set new tabstops
        ListBoxTextBoxSetTabs LstBoxFrm.LstBox, (i), TabStops()     '(just clears if none found)
      
        LstBoxFrm.LstHdr.Clear
        LstBoxFrm.LstHdr.AddItem LstBoxFrm.lblHead
        LstBoxFrm.LstHdr.Visible = True
           
        LstBoxFrm.Show 1

        PrinterDriverPort$ = LstBoxFrm.Tag
        replace PrinterDriverPort$, TB, ",", 0
        
                ' Return the selected printer in StdOut
        WriteFile GetStdHandle(STD_OUTPUT_HANDLE), PrinterDriverPort$, Len(PrinterDriverPort$), llResult, ByVal 0&
        
        Close
        End
   End If

   posn = InStr(1, cmd, "|", 1)
   If posn Then                           '"pathfileext|printerdriverport|X|T|L|R|B" "C:\file.rtf|Epson,winspool,LPT1:|L|P|P|0.1|0.1"
      pathfile = Left$(cmd, posn - 1)                                            'C:\file.rtf'
      NewPrinterDriverPort = Mid$(cmd, posn + 1)
      
      Override = ""
      posn = InStr(1, NewPrinterDriverPort, "|", 1)
      If posn Then
         Override = Mid$(NewPrinterDriverPort, posn)                             '|L|P|P|0.1|0.1'
         NewPrinterDriverPort = Left$(NewPrinterDriverPort, posn - 1)            'Epson,winspool,LPT1:'
         
         If (Left$(Override, 2) = "|C") Then
            citrixify = True
            Override = Right$(Override, Len(Override) - 2)
         End If
      End If
   End If
   
   If Len(pathfile) = 0 Then
      MsgBox "Document name is missing" & vbCrLf & vbCrLf _
         & "Add parameters:" & vbCrLf _
         & "   Pathfile|Printer,Driver,Port|{C}|X|T|L|R|B" & vbCrLf & vbCrLf _
         & "Pathfile must be rtf format" & vbCrLf _
         & "Printer,Driver,Port is optional but if used must be valid" & vbCrLf _
         & "C set if you need to printer name citrixfied" & vbCrLf _
         & "X is the layout override, L for landscape, P for portrait (optional)" & vbCrLf _
         & "T,L are top & left margins in cm or P for physical margins (optional)" & vbCrLf _
         & "R,B are right & bottom margins in cm (optional)" & vbCrLf & vbCrLf _
         , vbInformation + vbOKOnly, App.EXEName
         
   Else
      Screen.MousePointer = HOURGLASS
      success = True
      msgtitle = msgtitle & " " & pathfile
      HighEdit.Tag = ""    'load HighEdit
      'Sending 1 as extra parameter for applying mergeRTF for Stores template
      res = HighEdit.He.LoadDoc(pathfile, FILEFORMAT_RTF, 1)
      If res = 0 Then
         Screen.MousePointer = STDCURSOR
         MsgBox "Document load failed", vbOKOnly, msgtitle
         success = False
      End If
      
      If success And citrixify Then
         NewPrinterDriverPort = CitrixOverridePrinterPort(NewPrinterDriverPort)
      End If

      If success Then
         OldPrinterDriverPort$ = LCase$(Printer.DeviceName & "," & Printer.DriverName & "," & Printer.Port)
         If LCase$(NewPrinterDriverPort$) <> OldPrinterDriverPort$ And NewPrinterDriverPort$ <> "" Then
            'Start : Bug : 250786
            'Set instance printer from pharmacy printing desktop
            newPrinterDeviceEndPosition = InStr(1, NewPrinterDriverPort$, ",")
            If (newPrinterDeviceEndPosition > 0) Then
                newPrinterDeviceName = Mid(NewPrinterDriverPort$, 1, newPrinterDeviceEndPosition - 1)
                If (newPrinterDeviceName <> "") Then
                    res = HighEdit.He.SetInstancePrinter(newPrinterDeviceName)
                    If res = 0 Then
                        Screen.MousePointer = STDCURSOR
                        MsgBox "SetInstancePrinter failed", vbOKOnly, msgtitle
                        success = False
                    End If
                End If
            End If
            'End : Bug : 250786
         ElseIf LCase$(NewPrinterDriverPort$) = OldPrinterDriverPort$ And NewPrinterDriverPort$ <> "" Then
            newPrinterDeviceName = "1"
         End If
      End If
                     
      If success Then
         OverrideLayout Override                                                 'no error if settings can't be used
         'Start : Bug : 250786
         res = HighEdit.He.PrintDocAbortDlg("document", newPrinterDeviceName)
         'End : Bug : 250786
         If res = 0 Then
            Screen.MousePointer = STDCURSOR
            MsgBox "Print not completed", vbExclamation + vbOKOnly, msgtitle     '15Dec10 CKJ Added icon
         End If
         'Start : Bug : 250786
         'Set the default printer back after printing
         If LCase$(NewPrinterDriverPort$) <> OldPrinterDriverPort$ And OldPrinterDriverPort$ <> "" Then
            oldPrinterDeviceEndPosition = InStr(1, OldPrinterDriverPort$, ",")
            If (oldPrinterDeviceEndPosition > 0) Then
                oldPrinterDeviceName = Mid(OldPrinterDriverPort$, 1, oldPrinterDeviceEndPosition - 1)
                If (oldPrinterDeviceName <> "") Then
                    res = HighEdit.He.SetInstancePrinter(oldPrinterDeviceName)
                    If res = 0 Then
                        Screen.MousePointer = STDCURSOR
                        MsgBox "SetInstancePrinter failed", vbOKOnly, msgtitle
                        success = False
                    End If
                End If
            End If
         End If
         'End : Bug : 250786
         DoEvents
         'Start : PBI -246985 : Task 249234, 249237
         'Unload HighEdit
         HighEdit.Unload
         'Start : PBI -246985 : Task 249234, 249237
         Set HighEdit = Nothing
               
         Screen.MousePointer = STDCURSOR
      End If
   End If
   
   Close    '23Dec10 CKJ Exe does not always close if an error occurs eg when a non existent printer is passed in
   End      '            There will be a non-zero ref count which keeps the exe open, so although End is not ideal
            '            it serves its purpose and is acceptable
   
End Sub

