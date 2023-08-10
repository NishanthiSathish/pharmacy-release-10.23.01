Attribute VB_Name = "VERNIER"
'Vernier
'-------
'05Oct98 CKJ module written
'            Designed to provide tools to measure text against a given size textbox, and
'            allow it to be fitted using a series of font sizes
'23Oct98 TH  FormatText: Added fix to stop infinite loop if max chars exceeded
'23Oct98 TH  FormatText: Added switch on maxchars(pass in neg value) for Prescribing label printing
'16Feb00 AE  FormatTextNonStd:Code copied from FormatText And modified to allow reading of settings from
'            given sections in a given ini file.
'16Feb00 AE  FormatLabelNonStd:Code ported from FormatLabel. This version allows it to look in a given ini file and
'            Section instead of the default terminal entry in terminal.ini
  

'
DefInt A-Z
Option Explicit

Sub FormatLabel(ByVal TextIn$, ByVal LinesWanted%, ByVal MaxChars%, FontNumber%, LinesAcheived%, TextOut$, ByVal blnExtendedLabel As Boolean)
'05Oct98 CKJ
   

Dim fontcount%

   ReDim lines$(100)

   TextIn$ = Trim$(asciiz$(TextIn$))
   If blnExtendedLabel Then
      fontcount = Val(terminal$("ExtLblNumFonts", "0"))
      If fontcount = 0 Then
         fontcount = Val(terminal$("StdLblNumFonts", "0"))
      End If
   Else
      fontcount = Val(terminal$("StdLblNumFonts", "0"))        'read Terminal.ini
   End If
   
   If fontcount = 0 Then                                    'not set up, so do standard only
         TextOut$ = TextIn$
         FontNumber = 0                                     'not defined
         deflines TextIn$, lines$(), cr, 0, LinesAcheived
         Exit Sub                                           '<=== WAY OUT if not configured
      End If
   
   'Parse CR and LF;  ..CR..LF..CRLF..          all act as CRLF
   '                  ..CRCR..LFLF..CRLFCRLF..  all act as CRLFCRLF
   'Note: LFCR is not a valid separator
   replace TextIn$, crlf, Chr$(0) & Chr$(1), 0              'same size -> fast
   replace TextIn$, lf, Chr$(0), 0                          'same size -> fast
   replace TextIn$, cr, Chr$(0), 0                          'same size -> fast
   replace TextIn$, Chr$(0) & Chr$(1), crlf, 0              'same size -> fast
   replace TextIn$, Chr$(0), crlf, 0                        '1->2, slow
   If Right$(TextIn$, 2) = crlf Then TextIn$ = Left$(TextIn$, Len(TextIn$) - 2)

   FontNumber = 0
   Do                                                       'progressively reduce font size
      FontNumber = FontNumber + 1
      FormatText TextIn$, MaxChars, FontNumber, LinesAcheived, TextOut$, blnExtendedLabel
      If LinesAcheived <= LinesWanted Then Exit Do
   Loop While FontNumber < fontcount
   
   If LinesAcheived > LinesWanted Then   'failed to fit them in so remove all line feeds & retry
         replace TextIn$, cr, " ", 0                        'CR => space
         replace TextIn$, lf, "", 0                         'LF => nothing
         replace TextIn$, "  ", " ", 0                      'two spaces => one space
         FontNumber = 0
         Do                                                 'progressively reduce font size
            FontNumber = FontNumber + 1
            FormatText TextIn$, MaxChars, FontNumber, LinesAcheived, TextOut$, blnExtendedLabel
            If LinesAcheived <= LinesWanted Then Exit Do
         Loop While FontNumber < fontcount
      End If

End Sub

Sub FormatLabelNonStd(ByVal TextIn$, iniFile$, iniSection$, ByVal LinesWanted%, ByVal MaxChars%, FontNumber%, LinesAcheived%, TextOut$)
'05Oct98 CKJ
'16Feb00 AE  Code ported from FormatLabel. This version allows it to look in a given ini file and
'            Section instead of the default terminal entry in terminal.ini

Dim fontcount%
Dim iFound As Integer

   ReDim lines$(100)

   TextIn$ = Trim$(asciiz$(TextIn$))
   
   'fontcount = Val(terminal$("StdLblNumFonts", "0"))        'read Terminal.ini
   fontcount = Val(TxtD(iniFile$, iniSection$, "0", "StdLblNumFonts", iFound))

   If fontcount = 0 Then                                    'not set up, so do standard only
         TextOut$ = TextIn$
         FontNumber = 0                                     'not defined
         deflines TextIn$, lines$(), cr, 0, LinesAcheived
         Exit Sub                                           '<=== WAY OUT if not configured
      End If
   
   'Parse CR and LF;  ..CR..LF..CRLF..          all act as CRLF
   '                  ..CRCR..LFLF..CRLFCRLF..  all act as CRLFCRLF
   'Note: LFCR is not a valid separator
   replace TextIn$, crlf, Chr$(0) & Chr$(1), 0              'same size -> fast
   replace TextIn$, lf, Chr$(0), 0                          'same size -> fast
   replace TextIn$, cr, Chr$(0), 0                          'same size -> fast
   replace TextIn$, Chr$(0) & Chr$(1), crlf, 0              'same size -> fast
   replace TextIn$, Chr$(0), crlf, 0                        '1->2, slow
   If Right$(TextIn$, 2) = crlf Then TextIn$ = Left$(TextIn$, Len(TextIn$) - 2)

   FontNumber = 0
   Do                                                       'progressively reduce font size
      FontNumber = FontNumber + 1
      FormatTextNonStd TextIn$, MaxChars, FontNumber, LinesAcheived, TextOut$, iniFile$, iniSection$
      If LinesAcheived <= LinesWanted Then Exit Do
   Loop While FontNumber < fontcount
   
   If LinesAcheived > LinesWanted Then   'failed to fit them in so remove all line feeds & retry
         replace TextIn$, cr, " ", 0                        'CR => space
         replace TextIn$, lf, "", 0                         'LF => nothing
         replace TextIn$, "  ", " ", 0                      'two spaces => one space
         FontNumber = 0
         Do                                                 'progressively reduce font size
            FontNumber = FontNumber + 1
            FormatTextNonStd TextIn$, MaxChars, FontNumber, LinesAcheived, TextOut$, iniFile$, iniSection$
            If LinesAcheived <= LinesWanted Then Exit Do
         Loop While FontNumber < fontcount
      End If

End Sub

Sub FormatText(ByVal TextIn$, ByVal MaxChars%, ByVal FontNumber%, lines%, TextOut$, ByVal blnExtendedLabel As Boolean)
'23Oct98 TH  Added fix to stop infinite loop if max chars exceeded
'23Oct98 TH  Added switch on maxchars(pass in neg value) for
'23Oct98 TH  Prescribing label printing

'The following must be set up in terminal.ini file:
'StdLblFontname=   name of the font (Set to "" for non-proportional printer fonts)
'StdLblWidthTwips= actual printable width on the label for proportional font in twips
'StdLblNumFonts=   total number of font sizes available
'StdLblFontsize1=  largest point size of proportional font (absent if non-proportional)
'...
'StdLblFontsizeN=  smallest point size
'
'StdLblMaxChars1=  max no of characters if non-proportional (otherwise absent)
'...
'StdLblMaxCharsN=  maximum number of characters for smallest font
'
'RxLblFontName=    As above but for prescribing
'RxLblFontSize=    As above but for prescribing
'RxLblWidthTwips=    As above but for prescribing
'RxLblMaxChars=    As above but for prescribing

'There are approx 1440 twips to a logical inch or 567 twips to a logical centimeter
'Note that this can be set up once for the whole dept and changed per terminal as required
'
'example 1, truetype font:
'StdLblFontName  = "Arial"
'StdLblWidthTwips= "2880"           'actual printable wodth on label, 1440=1 inch 567=1 cm
'StdLblNumFonts  = "4"
'StdLblFontSize1 = "14"             'largest font
'StdLblFontSize2 = "12"
'StdLblFontSize3 = "10"
'StdLblFontSize4 = "8.25"           'smallest
'
'example 2, printer font:
'StdLblNumFonts  = "3"
'StdLblMaxChars1 = "21"             'largest font (pica)
'StdLblMaxChars2 = "26"             'medium font (elite)
'StdLblMaxChars3 = "36"             'smallest (condensed) room for 36 chars

'Mods Required
'If using Maxchars and on cutting line when maxchars exceeded, there is a possibility of      '22Oct98 TH
'introducing a blank line when there are a number of spaces at the start of th overlap line   '    "

                          
Dim lin$, i%, buffer$, numchars%, toowide%
Dim objVernier As frmVernier                                     'declare local object
Dim temp$, pos%, pos2%, prefix$

   
   Set objVernier = New frmVernier                                       'create new instance
   Load objVernier                                                       'and load it

   If MaxChars < 0 Then                                                  '23Oct98 TH  Added switch for
         prefix$ = "Rx"                                                  '23Oct98 TH  prescribing rtf
      ElseIf blnExtendedLabel Then
         prefix$ = "Ext"
      Else
         prefix$ = "Std"                                                 '23Oct98 TH
      End If                                                             '23Oct98 TH

   On Error GoTo FormatText_Err
   lin$ = terminal$(prefix$ & "LblFontName", "Courier New")
   objVernier.txtVernier.FontName = lin$

   lin$ = terminal$(prefix$ & "LblFontSize" & Format$(FontNumber), "9.75")
   objVernier.txtVernier.FontSize = Val(lin$)
   On Error GoTo 0
   MaxChars = Abs(MaxChars)

   If MaxChars = 0 Then MaxChars = 32767
   
   If objVernier.txtVernier.FontName = "Courier New" Then                       'measure in chars
            objVernier.txtVernier.Width = txtwidth(objVernier.txtVernier, String$(Val(terminal$(prefix$ & "LblMaxChars" & Format$(FontNumber), "36")), "X"))
         Else                                                                      'measure in twips
            objVernier.txtVernier.Width = Val(terminal$(prefix$ & "LblWidthTwips", "2880"))  '2 inches
         End If
      
   
   objVernier.txtVernier = TextIn$
   
   Do
      If InStr(1, Command$, "/FormatTextDebug", 1) Then objVernier.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
      toowide = False
      TextOut = ""
      lines = SendMessage(objVernier.txtVernier.Hwnd, EM_GETLINECOUNT, 0, 0&)   'count lines
      For i = 1 To lines
         buffer = String$(Len(TextIn$) + 2, 0)
         Mid$(buffer, 1, 2) = Chr$(Len(TextIn$) And &HFF) & Chr$(Len(TextIn$) \ &H100)
         numchars = SendMessage(objVernier.txtVernier.Hwnd, EM_GETLINE, (i - 1), ByVal buffer)
         buffer$ = Left$(buffer, numchars)
         If i > 1 Then                                                    '23Oct98 TH Seperates words on line
               If toowide Then                                            '23Oct98 TH wrapping
                     If Right$(TextOut, 1) <> " " Then TextOut = TextOut & " " 'single sp between lines
                  Else                                                    '23Oct98 TH
                     TextOut = TextOut & cr                                    'single cr between lines
                  End If                                                  '23Oct98 TH
            End If
         Do While Len(buffer) > MaxChars
            toowide = True
            temp$ = Left$(buffer, MaxChars)                               '23Oct98 TH/CKJ  Added to make sure words
            pos2 = MaxChars                                               '23Oct98 TH/CKJ  not chopped during line
            pos = 0                                                       '23Oct98 TH/CKJ  wrapping
            Do                                                            '23Oct98 TH/CKJ
               If pos > 1 Then pos2 = pos                                 '23Oct98 TH/CKJ
               pos = InStr(pos + 1, temp$, " ")                           '23Oct98 TH/CKJ
            Loop While pos > 0                                            '23Oct98 TH/CKJ
            TextOut = TextOut & Left$(buffer$, pos2) & cr                 '23Oct98 TH/CKJ
            buffer$ = Mid$(buffer$, pos2 + 1)                             '23Oct98 TH/CKJ
         Loop
         TextOut = TextOut & buffer$
      Next
      If toowide Then                                                     '23Oct98 TH
            replace TextOut$, cr, Chr$(0), 0                              'same size -> fast
            replace TextOut$, Chr$(0), crlf, 0                            'slower
                                                                          
            objVernier.txtVernier = TextOut$                              '23Oct98 TH Reset object for
            objVernier.txtVernier.Refresh                                 '23Oct98 TH next run
         End If
   Loop While toowide

   Unload objVernier                                                     'unload local object
   Set objVernier = Nothing                                              'give memory back to pool

Exit Sub

FormatText_Err:
   popmessagecr ".", "Configuration error in Terminal.ini: Font name or size invalid " & lin$
Resume Next
Exit Sub

End Sub

Sub FormatTextNonStd(ByVal TextIn$, ByVal MaxChars%, ByVal FontNumber%, lines%, TextOut$, iniFile$, iniSection$)

'23Oct98 TH  Added fix to stop infinite loop if max chars exceeded
'23Oct98 TH  Added switch on maxchars(pass in neg value) for
'23Oct98 TH  Prescribing label printing
'16Feb00 AE  Code copied from FormatText And modified to allow reading of settings from
'            given sections in a given ini file.

'The following must be set up in terminal.ini file:
'StdLblFontname=   name of the font (Set to "" for non-proportional printer fonts)
'StdLblWidthTwips= actual printable width on the label for proportional font in twips
'StdLblNumFonts=   total number of font sizes available
'StdLblFontsize1=  largest point size of proportional font (absent if non-proportional)
'...
'StdLblFontsizeN=  smallest point size
'
'StdLblMaxChars1=  max no of characters if non-proportional (otherwise absent)
'...
'StdLblMaxCharsN=  maximum number of characters for smallest font
'
'RxLblFontName=    As above but for prescribing
'RxLblFontSize=    As above but for prescribing
'RxLblWidthTwips=  As above but for prescribing
'RxLblMaxChars=    As above but for prescribing

'There are approx 1440 twips to a logical inch or 567 twips to a logical centimeter
'Note that this can be set up once for the whole dept and changed per terminal as required
'
'example 1, truetype font:
'StdLblFontName  = "Arial"
'StdLblWidthTwips= "2880"           'actual printable wodth on label, 1440=1 inch 567=1 cm
'StdLblNumFonts  = "4"
'StdLblFontSize1 = "14"             'largest font
'StdLblFontSize2 = "12"
'StdLblFontSize3 = "10"
'StdLblFontSize4 = "8.25"           'smallest
'
'example 2, printer font:
'StdLblNumFonts  = "3"
'StdLblMaxChars1 = "21"             'largest font (pica)
'StdLblMaxChars2 = "26"             'medium font (elite)
'StdLblMaxChars3 = "36"             'smallest (condensed) room for 36 chars

'Mods Required
'If using Maxchars and on cutting line when maxchars exceeded, there is a possibility of      '22Oct98 TH
'introducing a blank line when there are a number of spaces at the start of th overlap line   '    "

                          
Dim lin$, i%, buffer$, numchars%, toowide%
Dim objVernier As frmVernier                                     'declare local object
Dim temp$, pos%, pos2% ', prefix$
Dim iFound As Integer


   If iniFile$ = "" Then
         popmessagecr "", "Procedure FormatTextNonStd Requires iniFile$ to be set."
         Exit Sub
      End If
   
   Set objVernier = New frmVernier                                       'create new instance
   Load objVernier                                                       'and load it

'   If MaxChars < 0 Then                                                  '23Oct98 TH  Added switch for
'         prefix$ = "Rx"                                                  '23Oct98 TH  prescribing rtf
'      Else                                                               '23Oct98 TH  printing
'         prefix$ = "Std"                                                 '23Oct98 TH
'      End If                                                             '23Oct98 TH

   On Error GoTo FormatTextNS_Err
   'lin$ = terminal$(prefix$ & "LblFontName", "Courier New")
   lin$ = TxtD(iniFile$, iniSection$, "Courier New", "StdLblFontName", iFound)
   objVernier.txtVernier.FontName = lin$

   'lin$ = terminal$(prefix$ & "LblFontSize" & Format$(FontNumber), "9.75")
   lin$ = TxtD(iniFile$, iniSection$, "9.75", "StdLblFontSize" & Format$(FontNumber), iFound)
   objVernier.txtVernier.FontSize = Val(lin$)
   On Error GoTo 0
   MaxChars = Abs(MaxChars)

   If MaxChars = 0 Then MaxChars = 32767
   
   If objVernier.txtVernier.FontName = "Courier New" Then                       'measure in chars
            'objVernier.txtVernier.Width = TxtWidth(objVernier.txtVernier, String$(Val(terminal$(prefix$ & "LblMaxChars" & Format$(FontNumber), "36")), "X"))
            objVernier.txtVernier.Width = txtwidth(objVernier.txtVernier, String$(Val(TxtD(iniFile$, iniSection$, "36", "StdLblMaxChars" & Format$(FontNumber), iFound)), "X"))
         Else                                                                      'measure in twips
            'objVernier.txtVernier.Width = Val(terminal$(prefix$ & "LblWidthTwips", "2880"))  '2 inches
            objVernier.txtVernier.Width = Val(TxtD(iniFile$, iniSection$, "2880", "StdLblWidthTwips", iFound)) '2 inches
         End If
      
   
   objVernier.txtVernier = TextIn$
   
   Do
      If InStr(1, Command$, "/FormatTextDebug", 1) Then objVernier.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
      toowide = False
      TextOut = ""
      lines = SendMessage(objVernier.txtVernier.Hwnd, EM_GETLINECOUNT, 0, 0&)   'count lines
      For i = 1 To lines
         buffer = String$(Len(TextIn$) + 2, 0)
         Mid$(buffer, 1, 2) = Chr$(Len(TextIn$) And &HFF) & Chr$(Len(TextIn$) \ &H100)
         numchars = SendMessage(objVernier.txtVernier.Hwnd, EM_GETLINE, (i - 1), ByVal buffer)
         buffer$ = Left$(buffer, numchars)
         If i > 1 Then                                                    '23Oct98 TH Seperates words on line
               If toowide Then                                            '23Oct98 TH wrapping
                     If Right$(TextOut, 1) <> " " Then TextOut = TextOut & " " 'single sp between lines
                  Else                                                    '23Oct98 TH
                     TextOut = TextOut & cr                                    'single cr between lines
                  End If                                                  '23Oct98 TH
            End If
         Do While Len(buffer) > MaxChars
            toowide = True
            temp$ = Left$(buffer, MaxChars)                               '23Oct98 TH/CKJ  Added to make sure words
            pos2 = MaxChars                                               '23Oct98 TH/CKJ  not chopped during line
            pos = 0                                                       '23Oct98 TH/CKJ  wrapping
            Do                                                            '23Oct98 TH/CKJ
               If pos > 1 Then pos2 = pos                                 '23Oct98 TH/CKJ
               pos = InStr(pos + 1, temp$, " ")                           '23Oct98 TH/CKJ
            Loop While pos > 0                                            '23Oct98 TH/CKJ
            TextOut = TextOut & Left$(buffer$, pos2) & cr                 '23Oct98 TH/CKJ
            buffer$ = Mid$(buffer$, pos2 + 1)                             '23Oct98 TH/CKJ
         Loop
         TextOut = TextOut & buffer$
      Next
      If toowide Then                                                     '23Oct98 TH
            replace TextOut$, cr, Chr$(0), 0                              'same size -> fast
            replace TextOut$, Chr$(0), crlf, 0                            'slower
                                                                          
            objVernier.txtVernier = TextOut$                              '23Oct98 TH Reset object for
            objVernier.txtVernier.Refresh                                 '23Oct98 TH next run
         End If
   Loop While toowide

   Unload objVernier                                                     'unload local object
   Set objVernier = Nothing                                              'give memory back to pool

Exit Sub

FormatTextNS_Err:
   popmessagecr ".", "Configuration error in Terminal.ini: Font name or size invalid " & lin$
Resume Next
Exit Sub


End Sub

