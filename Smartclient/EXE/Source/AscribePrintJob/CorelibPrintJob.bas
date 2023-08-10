Attribute VB_Name = "CORELIB"
'-----------------------------------------------------------------------------
'                       CorelibPrintJob
'                      -----------------
'
'17Sep10 CKJ written
'            Supports only the minimalist print job handler AscribePrintJob
'15DEc10 CKJ Removed unused procedures        (RCN P0573 F0104170 10.5 branch)
'03May16 XN	 Added SetChrome 123082
'			 Added ListBoxTextBoxSetTabs 123082
'-----------------------------------------------------------------------------

Option Explicit
DefInt A-Z

Global Const MB_OK = 0                 ' OK button only
Global Const MB_OKCANCEL = 1           ' OK and Cancel buttons
'Global Const MB_ABORTRETRYIGNORE = 2  ' Abort, Retry, and Ignore buttons
Global Const MB_YESNOCANCEL = 3        ' Yes, No, and Cancel buttons
Global Const MB_YESNO = 4              ' Yes and No buttons
Global Const MB_RETRYCANCEL = 5        ' Retry and Cancel buttons

Global Const MB_DEFBUTTON1 = 0        ' First button is default
Global Const MB_DEFBUTTON2 = 256       ' Second button is default
Global Const MB_DEFBUTTON3 = 512       ' Third button is default

'MsgBox return values                      15Dec97 CKJ moved from report.bas
Global Const IDOK = 1                    ' OK button pressed
Global Const IDCANCEL = 2                ' Cancel button pressed
'Global Const IDABORT = 3                ' Abort button pressed
'Global Const IDRETRY = 4                ' Retry button pressed
'Global Const IDIGNORE = 5               ' Ignore button pressed
Global Const IDYES = 6                   ' Yes button pressed
Global Const IDNO = 7                    ' No button pressed
Global Const IDCHECKED = 256             ' Check Box Ticked

'MsgBox icon values                        15Dec97 CKJ moved from Highasc.bas
Global Const MB_ICONSTOP = 16            ' Critical message
Global Const MB_ICONQUESTION = 32        ' Warning query
Global Const MB_ICONEXCLAMATION = 48     ' Warning message
Global Const MB_ICONINFORMATION = 64     ' Information message
Global Const ASC_ICONSAMPLE = 8          ' Box shaped icon   16Feb98 CKJ Added

'Keycode constants
Global Const KEY_F1 = &H70
Global Const KEY_F2 = &H71
Global Const KEY_F3 = &H72
Global Const KEY_F4 = &H73
Global Const KEY_F5 = &H74
Global Const KEY_F6 = &H75
Global Const KEY_F7 = &H76
Global Const KEY_F8 = &H77
Global Const KEY_F9 = &H78
Global Const KEY_F10 = &H79
Global Const KEY_F11 = &H7A
Global Const KEY_F12 = &H7B
Global Const KEY_ESCAPE = &H1B
Global Const KEY_PgUp = &H21
Global Const KEY_PgDn = &H22
Global Const KEY_END = &H23
Global Const KEY_HOME = &H24
Global Const KEY_LEFT = &H25
Global Const KEY_UP = &H26
Global Const KEY_RIGHT = &H27
Global Const KEY_DOWN = &H28
Global Const VK_CAPITAL = &H14
Global Const VK_NUMLOCK = &H90
'Global Const VK_SCROLL = &H91
Global Const KEY_RETURN = &HD
Global Const KEY_INSERT = &H2D
Global Const KEY_DELETE = &H2E
Global Const KEY_TAB = &H9

' Shift parameter masks
Global Const NO_MASK = 0
Global Const SHIFT_MASK = 1
Global Const CTRL_MASK = 2
Global Const ALT_MASK = 4

Global Const LEFT_BUTTON = 1
Global Const RIGHT_BUTTON = 2
Global Const MIDDLE_BUTTON = 4

Global Const LB_SETTABSTOPS = &H192                 'WM_USER + 19
Global Const EM_SETTABSTOPS = &HCB                  'WM_USER + 27

Global Const STDCURSOR = 0       'Cursor shape - default
Global Const HOURGLASS = 11      'Cursor shape - wait...
                              
Global Const cr   As String = Constants.vbCr      ' carriage return, CHR$(13)
Global Const lf   As String = Constants.vbLf      ' line feed, CHR$(10)
Global Const crlf As String = Constants.vbCrLf    ' carriage return, line feed (13),(10)
Global Const TB   As String = Constants.vbTab     ' tab, CHR$(9)

Global nulls As String * 11    'Ten Chr$(0)        '12Nov08 CKJ Eleven chr$(0) to match length of .validchars

Global Nul As String * 1              '   "        was local

Const OBJNAME As String = PROJECT & "Corelib."

' Constants that will be used in the API functions 123082 03May16 XN Added
Public Const STD_INPUT_HANDLE = -10&
Public Const STD_OUTPUT_HANDLE = -11&

' Declare the needed API functions 123082 03May16 XN Added
Declare Function GetStdHandle Lib "Kernel32" (ByVal nStdHandle As Long) As Long
Declare Function WriteFile Lib "Kernel32" (ByVal hFile As Long, ByVal lpBuffer As String, ByVal nNumberOfBytesToWrite As Long, lpNumberOfBytesWritten As Long, lpOverlapped As Any) As Long
Declare Function SendMessage Lib "user32" Alias "SendMessageA" (ByVal Hwnd As Long, ByVal wMsg As Long, ByVal wParam As Long, lParam As Any) As Long

Sub deflines(alllines$, lines$(), sepctrl$, firstlin, Numoflines)
'-----------------------------------------------------------------------------
' split a line into individual parts, based on given separator
' set firstlin before calling, eg 0 if line$(0) is to be used, else 1
' numoflines is returned
' 9Feb94 CKJ Add "(*)" to the separator to preserve all blank lines
' 1Feb95 CKJ Removed line; "a,b,c" returned 3 lines, ",," returned 2 lines
'            - now both return 3 lines
' 9Feb95 CKJ Added line - did not parse "a,b,c" style lines correctly
'-----------------------------------------------------------------------------
Dim lin$, keepblanks%, sep$, cursep%, linnum%, lastsep%

   lin$ = RTrim$(alllines$)
   keepblanks = False
   sep$ = sepctrl$
   If Right$(sep$, 3) = "(*)" Then
         sep$ = Left$(sep$, Len(sep$) - 3)
         keepblanks = True
      End If
   If sep$ = "" Then
         lines$(firstlin) = alllines$
         Numoflines = 1
         Exit Sub
      End If
  'IF RIGHT$(lin$, 1) <> sep$ THEN lin$ = lin$ + sep$   1Feb95 CKJ Removed
   lin$ = lin$ & sep$       '9Feb95 CKJ Added
   cursep = InStr(lin$, sep$)
   linnum = firstlin

   Do While cursep
      lines$(linnum) = Mid$(lin$, lastsep + 1, cursep - lastsep - 1)
      If cursep - lastsep > 1 Or keepblanks Then linnum = linnum + 1   'optionally ignore blank lines
      lastsep = cursep
      cursep = InStr(lastsep + 1, lin$, sep$)
      If linnum > UBound(lines$) Then Exit Do
   Loop

   Numoflines = linnum - firstlin
   
End Sub


Function digits(lin$) As String
' 3Dec96 CKJ Written
'            Takes a string & returns only digits 0-9, removing all other chars
Dim chars$, i%, ch$

   chars$ = ""
   For i = 1 To Len(lin$)
      ch$ = Mid$(lin$, i, 1)
      Select Case ch$
         Case "0" To "9": chars$ = chars$ & ch$
         End Select
   Next
   digits$ = chars$

End Function


Function asciiz$(st As String)
'--------------------------------
' given an ASCIIZ string (one terminated by null), returns an ordinary string.
' if passed an ordinary variable length string, returns it unchanged.
Dim ptr%

   ptr = InStr(st, Chr$(0))             '  ""=0   "ABC"=0   "|"=1   "ABC|"=4
   If ptr Then asciiz$ = Left$(st, ptr - 1) Else asciiz$ = st

End Function


Function IsDigits(ByVal txt As String) As Boolean
'12Sep96 CKJ Written. Takes string & tests for 0-9 in all chars.
'            Returns True if all chars are numeric or if string is blank

Dim IsNumber%, counter%

   IsNumber = True
   For counter = 1 To Len(txt$)
      If InStr("0123456789", Mid$(txt$, counter, 1)) = 0 Then
            IsNumber = False
            Exit For
         End If
   Next
   IsDigits = IsNumber

End Function


Function IsNumber(ByVal chars As String, ByVal AllowNegative As Boolean) As Boolean
'09May05 CKJ Does a string conform to the structure for a simple integer or real number?
'            One decimal point is allowed, either leading, trailing or embedded
'            Leading/trailing zero optional, except for zero itself (ie '' '-' '-.' and '.' are not valid)
'            No spaces permitted, so trim before calling.
'            Exponentials, Hex, etc are not permitted
'            Note that this is deliberately stricter than the companion function CleanUpNumber()

Dim valid As Boolean
Dim strParsed As String

   valid = True      'assume innocent until proven guilty
   strParsed = chars
   
   replace strParsed, ".", "", 0
   If Len(chars) - Len(strParsed) > 1 Then valid = False       'more than one decimal point
   If Len(strParsed) = 0 Then valid = False
   
   If valid And AllowNegative Then                             'remove leading negative sign if permitted
      If Left$(chars, 1) = "-" Then                            'using original ensures trapping of '.-' etc
         strParsed = Mid$(strParsed, 2)
         If Len(strParsed) = 0 Then valid = False
      End If
   End If
   
   If valid Then
      valid = IsDigits(strParsed)                              'remaining chars must be 0 to 9 only
   End If
   
   IsNumber = valid

End Function


Sub replace(item$, was$, isnow$, ByVal length As Long)
'Usage:  Replace part of one string with another, but only if it is greater than a given length
'        Note, this procedure _is_ case sensitive - it replaces only on exact match
'        Avoid iterative use: eg Replace chars$, "A", "AB", 0  will loop until crump.
'         - this is by design; it allows repetitive strings of chars to be cut to a minimum size
'           eg Replace chars$, "   ", "  ", 0   will reduce multiple spaces to just two.
'
'Example:
'        longname$ = "Mister Algernon Person"
'        Replace longname$, "Mister", "Mr.", 20   'will replace only if longname$ is > 20 chars
'        Replace longname$, "Algernon", "Al", 0   'will replace regardless of length

'05Oct96 CKJ Once replacing commenced, it carried on with all occurrences.
'            Now stops once length is satisfactory
'29May97 CKJ Splice new text into existing string if length before & after is unchanged
'            This is to reduce string handling & improve performance
'10Jul98 CKJ If length is negative then replace using case insensitive comparison
'            If the replace is not dependent on length then just use True for ignore case &
'            False for the normal case specific replace
'09May05 uses longs

Dim posn As Long, splice As Long, ignorecase%

   splice = (Len(was$) = Len(isnow$))  ' if length is the same then splice is true
   ignorecase = -(length < 0)          ' set true/false
   length = Abs(length)
   If Len(item$) > length Then
         Do
            'posn = InStr(item$, was$)
            posn = InStr(1, item$, was$, ignorecase)   '10Jul98 CKJ added case option

            If posn Then
                 If splice Then
                       Mid$(item$, posn) = isnow$
                    Else
                       item$ = Left$(item$, posn - 1) & isnow$ & Mid$(item$, posn + Len(was$))
                    End If
              End If
         Loop While posn And Len(item$) > length
      End If

End Sub


Function trimz(chars$) As String
'-----------------------------------------------------------------------------
'  Remove all spaces at left & right, and remove anything beyond a null byte.
'-----------------------------------------------------------------------------

   trimz = Trim$(asciiz$(chars$))

End Function

Sub SetChrome(frm As Form)
'03May16 XN  123082 Copied from main Pharmacy code

Dim ctrl As Control
Dim Colour_Background As Long

   Colour_Background = &HFFE3D6     '!!** needs setting outside the app
   
   For Each ctrl In frm.Controls
'      Select Case ctrl.ForeColor
'         Case &H80000008
'         Case &H8000000A
'         Case &H80000005
'         End Select
      
'      ctrl.BackColor = &HFFE3D6     'main background
'      ctrl.BackColor = &HC0C0C0     'silver
'      ctrl.BackColor = &HB48246     'bit darker blue
'      ctrl.BackColor = &HA97868     'another blue
'      ctrl.BackColor = &HF0D3C6     'and another
'      ctrl.BackColor = &HE6E0B0     'Paler blue
      
      On Error GoTo ErrorHandler
      
''      If TypeOf ctrl Is CommandButton Then
''         ctrl.Style = 1 ' graphical
''      End If
      
      Select Case ctrl.BackColor
         Case &H80000008
''            Stop
         Case &H8000000A, &HC0C0C0
            ctrl.BackColor = Colour_Background
         Case &H8000000F
            ctrl.BackColor = Colour_Background
         Case &H80000005, &HFFFFFF
            'white is fine for text boxes
         Case Else
''            Debug.Print Hex(ctrl.BackColor), ctrl.name
''            Stop
         End Select
      ctrl.FontName = "Arial"                '!!** for testing

Continue:
   Next

   frm.BackColor = Colour_Background
   
Exit Sub

ErrorHandler:
Resume Continue

End Sub

Sub ListBoxTextBoxSetTabs(ctlList As Control, NumTabs As Integer, TabStops() As Long)
'21Sep96 CKJ Written - but not ready for use.
' 2Oct96 CKJ Released. Normally used in conjunction with LstBoxShow, but is OK for
'            any standard list box. The TabStops() values are in dialogbox units, ie
'            approx 4 per average character. Send NumTabs=0 to clear previous settings.
'18Sep97 CKJ Now works for text boxes too. Unfortunately, it's still called LstBoxSetTabs!
'09May05 CKJ changed array int to long
'            changed procedure name from LstBoxSetTabs as it also handles text boxes
'03May16 XN  123082 Copied from main Pharmacy code

Dim dummy&, param&
   
   param& = 0
   If TypeOf ctlList Is ListBox Then
         param& = LB_SETTABSTOPS
      ElseIf TypeOf ctlList Is TextBox Then
         param& = EM_SETTABSTOPS
      End If

   If param& Then
         On Error GoTo ErrorHandler

         dummy& = SendMessage(ctlList.Hwnd, param&, 0, ByVal 0&)                'clear tabs
         If NumTabs > 0 And UBound(TabStops) >= NumTabs Then
               dummy& = SendMessage(ctlList.Hwnd, param&, NumTabs, TabStops(1)) 'set tabs
            End If
      End If

Cleanup:
   On Error GoTo 0
Exit Sub

ErrorHandler:
   'No action, just exit safely
Resume Cleanup
   
End Sub
