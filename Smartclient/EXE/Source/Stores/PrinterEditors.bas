Attribute VB_Name = "PrinterEditors"
''Sub EditPrintContexts(SystemEntries%)
'''12Jan98 CKJ Written
'''Show a list box of all printer contexts and current settings for this terminal
'''If SystemEntries then show for [Default] instead of the current terminal
'''User can select any and amend as required
''
''Dim res$, numoflines%, i%, Context$, term$, PRNwas$
''Dim allcontexts$, numofcontexts%, Comment$, PrinterDriverPort$
''ReDim lines$(100)
''
''   Do
''      FlushIniCache
''      HighEdit.Tag = ""
''      LstBoxFrm.Caption = "ASCribe"
''      LstBoxFrm.lblTitle.Caption = cr & "Select print context to amend for " & Iff(SystemEntries, "SYSTEM DEFAULTS", "this terminal") & cr
''      LstBoxFrm.lblHead.Caption = "Context     " & TB & "Printer" & Space$(20) & TB & "Driver    " & TB & "Port" & Space$(15) & TB & "Comment" & Space$(100)
''      'Context        Printer       Driver      Port                Comment
''      '-------------  ------------  ----------  ------------------  ---------------------
''      'GeneralLbl     Epson-FX80    UNIDRV      LPT1:               Prescription labels
''      'GeneralPlain   HP-4L         HP_DRV      \\Pharmacy\Queue1   Plain paper on laser
''
''      allcontexts$ = terminal("PrintContexts", "")
''
''      ReDim lines$(100)
''      deflines allcontexts$, lines$(), ",", 1, numofcontexts
''
''      For i = 1 To numofcontexts
''         If SystemEntries Then                             'read printer for [Default]
''               term$ = "Default"
''               PrinterDriverPort$ = TxtD$(dispdata$ & "\TERMINAL.INI", term$, "", lines$(i), 0)
''            Else                                           'read printer for this term/context
''               term$ = ASCTerminalName()
''               PrinterDriverPort$ = terminal(lines$(i), "")
''            End If
''         Comment$ = terminal(lines$(i) & "Prompt", "")
''         replace PrinterDriverPort$, ",", TB, 0
''         If PrinterDriverPort$ = "" Then PrinterDriverPort$ = TB & TB
''         LstBoxFrm.LstBox.AddItem lines$(i) & TB & PrinterDriverPort$ & TB & Comment$
''      Next
''
''      LstBoxShow
''      res$ = LstBoxFrm.Tag
''      Unload LstBoxFrm
''
''      If Len(res$) Then
''            ReDim lines$(100)
''            deflines res$, lines$(), TB & "(*)", 1, numoflines
''            Context$ = lines$(1)
''            i = GetCurrentPrinter(PRNwas$)
''            If Len(lines$(2)) Then
''                  PrinterDriverPort$ = lines$(2) & "," & lines$(3) & "," & lines$(4)
''                  i = SetSpecifiedPrinter(PrinterDriverPort$)
''               Else
''                  PrinterDriverPort$ = ""
''               End If
''
''            ChooseDevice lines$(5), PrinterDriverPort$, True
''            i = SetSpecifiedPrinter(PRNwas$)
''
''            If Len(Context$) > 0 Then 'And Len(PrinterDriverPort$) > 0 Then 'save it
''                  replace PrinterDriverPort$, TB, ",", 0
''                  'Add this context and printer to the user's terminal (may already be there!)
''                  WritePrivateIniFile term$, Context$, PrinterDriverPort$, dispdata$ & "\TERMINAL.INI", 0
''                  'Add this context to [default] PrintContexts if not already there (Should be there!)
''                  If InStr("," & UCase$(allcontexts$) & ",", "," & UCase$(Context$) & ",") = 0 Then
''                        WritePrivateIniFile "Default", "PrintContexts", allcontexts$ & "," & Context$, dispdata$ & "\TERMINAL.INI", 0
''                     End If
''                  FlushIniCache     '28Jun00 JN Added
''               End If
''         End If
''   Loop While Len(res$)
''
''End Sub

Sub EditContextDescriptions()
'12Jan98 CKJ Written
'Show a list box of all printer contexts and current descriptions

Dim res$, numoflines%, i%, Context$
Dim allcontexts$, numofcontexts%, Comment$, ans$
ReDim lines$(100)
           
   Do
      FlushIniCache
      LstBoxFrm.Caption = "EMIS Health"
      LstBoxFrm.lblTitle.Caption = cr & "Select print context description to amend" & cr
      LstBoxFrm.lblHead.Caption = "Context     " & TB & "Comment" & Space$(100)
      'Context        Comment
      '-------------  ---------------------
      'GeneralLbl     Prescription labels
      'GeneralPlain   Plain paper on laser
      
      allcontexts$ = terminal("PrintContexts", "")
      
      ReDim lines$(100)
      deflines allcontexts$, lines$(), ",", 1, numofcontexts
   
      For i = 1 To numofcontexts
         Comment$ = terminal(lines$(i) & "Prompt", "")
         LstBoxFrm.LstBox.AddItem lines$(i) & TB & Comment$
      Next
   
      LstBoxShow
      res$ = LstBoxFrm.Tag
      LstBoxFrm.Show 0
      LstBoxFrm.Enabled = False
   
      If Len(res$) Then
            ReDim lines$(100)
            deflines res$, lines$(), TB & "(*)", 1, numoflines
            Context$ = lines$(1)
            Comment$ = lines$(2)
                       
            ans$ = Comment$
            k.Max = 50
            k.min = 0
            inputwin "EMIS Health", "Change description for " & Context$, ans$, k
            If ans$ <> Comment$ Then
                  WritePrivateIniFile "Default", Context$ & "Prompt", ans$, dispdata$ & "\TERMINAL.INI", 0
                  FlushIniCache     '28Jun00 JN Added
               End If
         End If
   
      LstBoxFrm.Enabled = True
      Unload LstBoxFrm
   
   Loop While Len(res$)
               
End Sub

Sub PrinterEditorsMain()
'06Feb06 TH Written

Dim ans$, pathfile$
ReDim Menu$(3), menuhlp%(3)

   Menu$(1) = "Printer Selection - Terminal"
   Menu$(2) = "Printer Selection - Default"
   Menu$(3) = "Printer Selection - Descriptions"
   inputmenu Menu$(), menuhlp(), ans$, k
         
   Select Case Val(ans$)
      Case 1: EditPrintContexts (False)
      Case 2: EditPrintContexts (True)
      Case 3: EditContextDescriptions
   End Select
      
End Sub


