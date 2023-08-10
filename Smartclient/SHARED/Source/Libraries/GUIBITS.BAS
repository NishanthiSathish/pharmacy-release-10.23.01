Attribute VB_Name = "GUIBITS"
'****************************************************************************
' GUIBITS - Graphical User Interface procedures
'
'Modification History
'--------------------
'27Feb96  KR Moved CentreForm from Security.bas
'            Move CentreControl from Ident.Frm
'11Mar96 CKJ AskWin added
'12Mar96 KR  Added TextBoxHiLite
'14Mar96 CKJ Added HorizCentreForm, TxtWidth$ and Fmt$()
' 9Apr96 CKJ AskWin: added getYN$(6,7) & T1(cancel)  [09Aug96 CKJ Merged these mods which had been lost]
'12Aug96 CKJ LstBoxShow: font changed
'13Aug96 CKJ Timeout.frm added, function TimedOut() written
'            LstBoxShow: corrections made, timer added
' 3Sep96 CKJ InputMenu: Added Heading facility in menu$(0)
'12Sep96 CKJ Added norefresh to MsgWin ListBox and TxtWin
'13Sep96 CKJ AskWin: Added icons. First char of title sets icon to be used. (!?@#)
'17Sep96 CKJ Added SetTextBoxReadOnly
'18Sep96 CKJ InputWin: added k.escd=false
' 2Oct96 CKJ frmOption: added Radio buttons
'            LstBoxShow now handles tabbed columns & headings.  See proc for full details.
'            LstBoxSetTabs added. Mainly for use with LstBoxShow, but use if required.
'22Oct95 CKJ Inputwin: Added k.timd=false
'24Oct96 CKJ TextEdit: Use form caption for title, not label
' 2Nov96 CKJ Added k.helpnum
' 4Nov96 CKJ InputMenu: Converted from numbered list to a listbox
' 6Nov96 CKJ ListBox: added width of scrollbar & made heading width change on resize
'19Nov96 CKJ/EAC PopMenu, PopMenuShow: Added popup floating menu at cursor position
'            ListBox: supports PopMenu, fill menu, call listbox, test LstBoxFrm.LstBox.Tag
'21Nov96 CKJ Inputmenu: add only up to first blank item
' 8Dec96 CKJ CentreForm, CentreControl: Changed to integer divide, and simplified
'            FrmList: removed from GUIBITS - replaced by LstBoxFrm. Former only used for pts.
'17Dec96 CKJ ToolTips added - see ShowTip
'19Dec96 CKJ InputWin: k.passwrd added
' 7Mar97 CKJ Added global gTimedOut, and added code to each form used by this module.
'            Note: the intention is to phase out k.timd and k.exitval
'            Please test gTimedOut = T/F instead
'            NB Added timeout to the Editor form as well
' 1May97 CKJ LstBoxShow - display hourglass
'13May97 CKJ PrintScreen & CaptureScreen written
'            Note: CaptureScreen needs \libfiles\Blank.frm in project
'15Jun97 KR  LstBoxShow If title < header then set maxwidth according to length of header.
' 6Aug97 CKJ frmOptionShow: replaced IIF with Iff
'18Sep97 CKJ LstBoxSetTabs now works for text boxes too
'12Oct97 CKJ MessageBox released for alpha test
'            GreaterOf() and LesserOf() written
'            TxtWidthHeight: Trapped Overflow errors on sizing long strings
'15Oct97 CKJ MessageBox: Corrected WidthReqd when no scroll bars and no icon are shown
'15Oct97 CKJ Improved mod of 15Jun97 re list box width checking
'16Feb98 CKJ MessageBox: Added safety margin of 240, as tabs are not calculated correctly
'             Also enabled the fifth built in Icon, as attribute ASC_ICONSAMPLE = 8
'            TxtWidthHeight: Now removes instance of frmMsgWin when finished
'            Added facility for hidden first line to set tab stops;
'             terminate the first line with a nul, chr$(0), instead of cr or crlf
'23Feb98 CKJ TxtWidthHeight: Removed the form unload/set nothing
'            The speed of showing a list box dropped dramatically, and in the environment
'            Out Of Memory errors occur almost immediately. Another solution is required.
'15May98 CKJ LstBoxShow: increased max TabStops from 5 to 25
'15Jul98 CKJ frmOptionSet, frmOptionShow: Modified to allow multiple columns
'            Tested with up to 129 rows. Also now sets line with focus to bold.
'04Aug98 CKJ Merged 12Jul98 mods. LstBoxShow: corrected amount of blank space below box
'14Oct98 CKJ MessageBox: Retrieve font size from terminal.ini, and widen box if too narrow
'04dec98 CKJ Preserve cursor across call to AskWin
'24Feb99 SF  Added SetNumEditorLines: sub to set the number of editable lines in editors.frm
'24Feb99 SF  Added GetNumEditorLines() function to get the number of editable lines in editors.frm
'19Jul99 AE  FormatVal:Written.
'19Jul99 AE  InputValid:written
'02Mar00 AE  FillSetupOptions: Written
'02Mar00 AE  GetSetupHeapID: Written
'02Mar00 AE  GetSetupOptions:Written
'26May00 AE  AutoComplete: Written: Provides a generic autocomplete form, which can be visible or hidden.
'            provides static or dynamic lists, addition/removal of items, and loading/saving of lists.
'            Any number of autocomplete psuedo-objects can be used.  Requires AutoComp.Frm
'26May00 AE  AddToSelected:  Written.  Allows adding/removing between a pair of list boxes as per Multilist.frm
'            However this procedure is generic and can be used with any two forms.
'26May00 AE  Definition of DB_LANG_GENERAL moved from Events.bas to Corelib.bas so that it is available in DSStools
'26May00 AE  Added declaration of Type Rect, AutocompleteStatus and GetWindowRect for use with AutoComplete
'02Jun00 AE  AskWinChk: Written.  As for askwin, but with a check box which allows for "don't ask again"
'            style functionality as seen in modern windows apps.
'18Jul00 CKJ frmOptionSet: Allow invisible entries: set text to be a nul character chr$(0)
'             Allow visible but disabled: append a nul character chr$(0) to the end of the text
'            LstBoxShow: Height of list box at design time increased to full height of 768 pixels
'             Now has to be vertically centred
'26Jul00 AE  Moved Autocomplete into separate bas file, \libfiles\autocomp.bas
'14feb03 CKJ FrmOptionShow: Set width of form based on text box as well as individul items
'30Mar04 CKJ {SP1}
'            Removed proc message
'19Apr04 TH  EnhDisplayMacrofile: Written to use enh list box  (enh654)
'08oct08 CKJ GetScreenWorkingArea: written. Returns coordinates of usable screen excluding taskbar
'04Oct10 XN  MessageBox: F0023149 Windows 7 has larger boarders for windows forms so increased height of from by 10
'27May11 XN  LstBoxShow: F087364 Cleared SetKeyUpCallBackProc after form is displayed
'04Feb16 TH  LstBoxShow: Added option param to add extra button (TFS 138641)
'Bug 209006  Stores- Amend Orders-Price Entry Message box needs resizing
'Mods needed
'-----------
'/AskWin: defaults not setting correctly
' k.timd=false may need adding in more places
'
'
'Requires the following forms & custom controls:
'
' Filename     Form           Procedure(s)         Usage
' ------------ -----------    ------------         -------------------------------
' msgwin.frm   frmMsgWin      AskWin Confirm       Yes/No/Cancel box
' listbox.frm  LstBoxFrm      LstBoxShow           Generic self sizing list box
' timeout.frm  frmTimeout     TimedOut()           Provides timeout facilities
' txtwin.frm   frmTxtWin      InputWin InputMenu   Text input on self sizing form
' editform.frm Editor         TextEdit             Multi-line text editor
' options.frm  frmOption      frmOptionSet         Setup for option/radio buttons
'    "            "           frmOptionShow        Show option/radio buttons
' popmenu.frm  PopMnu         PopMenu PopMenuShow  Fill & show a floating menu
' tooltips.frm frmToolTip     ShowTip              place in Mousemove as required
' blank.frm    frmBlank       PrintScreen          Print screen to default printer
' msgbox.frm   frmMsgBox      MessageBox           Drop-in replacement for MsgBox
'
' frmSetup.frm frmSetupOptions   FillSetupOptions  Generic front end for setting any given options.
'
'Not used here anymore
' frmlist.frm  FrmList                             Patients only
'*********************************************************************************
Option Explicit
DefInt A-Z

Global gk As kbdcontrol
Global gTimedOut As Integer    ' 7Mar97 CKJ Added
Dim TimeoutCount As Integer
Dim RadioBtns As Integer       ' 2Oct96 Ckj Used in frmOption
Dim numEditorLines As Integer  ' 24Feb99 SF added

Dim iSetupHeap As Integer     '02Mar00  AE

'ToolTips by AVS
Type POINTAPI
   X As Long
   Y As Long
End Type

Type RECT
   Left As Long
   Top As Long
   Right As Long
   Bottom As Long
End Type

Private Declare Function SystemParametersInfo Lib "user32" Alias "SystemParametersInfoA" _
   (ByVal lngAction As Long, ByVal lngParam As Long, ByRef lpvParam As RECT, ByVal WinIni As Long) As Long
    
Private Const SPI_GETWORKAREA = 48     'for SystemParametersInfo

Public Declare Function GetActiveWindow Lib "user32" () As Long
Public Declare Function WindowFromPoint Lib "user32" (ByVal lpPointY As Long, ByVal lpPointX As Long) As Long
Public Declare Function ShowWindow Lib "user32.dll" (ByVal Hwnd As Long, ByVal nCmdShow As Long) As Long
'nCmdShow - flags specifying how to show the window:
'SW_HIDE = 0            'Hide the window.
'SW_SHOWNORMAL = 1      'Show the window and activate it (as usual).
'SW_SHOWMINIMIZED = 2   'Show the window minimized.
'SW_SHOWMAXIMIZED = 3   'Show the window maximized.
'SW_MAXIMIZE = 3        'Maximize the window.
'SW_SHOWNOACTIVATE = 4  'Show the window in its most recent size and position but do not activate it.
'SW_SHOW = 5            'Show the window.
'SW_MINIMIZE = 6        'Minimize the window.
'SW_SHOWMINNOACTIVE = 7 'Show the window minimized but do not activate it.
'SW_SHOWNA = 8          'Show the window in its current state but do not activate it.
'SW_RESTORE = 9         'Restore the window (not maximized nor minimized).

'Declare Function GetCursorPos Lib "user32" (lpPoint As POINTAPI) As Long
Public Declare Sub GetCursorPos Lib "user32" (lpPoint As POINTAPI)
'Declare sub GetWindowRect Lib "user32" (ByVal hwnd As Long, lpRect As RECT)
'Declare Function GetWindowRect Lib "user32" (ByVal hwnd As Long, lpRect As RECT) As Long

Global gMsg As String                     'v1.0
Global g_Old_MousePosition As POINTAPI    'v1.0
Global g_hwndFormCallingTip As Long
Global g_LastWindow As Integer            'Last Window the mouse cursor was over v1.2

Global Const g_TIP_DISPLAY_TIME = 10000   'v1.1 was 2000         '11May97 CKJ was 5000
Global Const g_TIP_PAUSE_TIME = 250       'time before display   'v1.1
       
Declare Function LoadIcon Lib "user32" Alias "LoadIconA" (ByVal hInstance As Long, ByVal lpIconName As Any) As Long
Declare Function LoadIconBynum Lib "user32" Alias "LoadIconA" (ByVal hInstance As Long, ByVal lpIconName As Long) As Long
Declare Function DrawIcon Lib "user32" (ByVal hdc As Long, ByVal X As Long, ByVal Y As Long, ByVal hIcon As Long) As Long
Declare Function GetTabbedTextExtent Lib "user32" Alias "GetTabbedTextExtentA" (ByVal hdc As Long, ByVal lpString As String, ByVal nCount As Long, ByVal nTabPositions As Long, lpnTabStopPositions As Long) As Long
    
Global Const OIC_SAMPLE = 32512&
Global Const OIC_HAND = 32513&
Global Const OIC_QUES = 32514&
Global Const OIC_BANG = 32515&
Global Const OIC_NOTE = 32516&

Private Const OBJNAME As String = PROJECT & "GUI."

Sub AddToSelected(cLstUnselected As ListBox, cLstSelected As ListBox, bAdding As Integer, sSwitches As String)

'Adds/removes items from LstUnselected to LstSelected in the style of Multilist.
'bAdding:
'        True:  move the selected item from LstUnSelected to LstSelected
'        False: move the selected item from LstSelected to LstUnselected
'
'sSwitches:
'        use like command line switches to hold different options.
'        /FR          - (Full Remove) - items removed from LstSelected are not added to LstSelected,
'                       but just deleted from the list
'        /DU          - (Duplicate) - Will add an item to a list even if it is already present in the
'                       list. If this setting is not used, duplicates are not permitted.


'Moves the item and the item data.
'Safe; if nothing is selected, just exits quietly.
'--------------------------------------------------------------------------------------
'26May00 AE  Written
'

Dim iIndUn As Integer, iIndSel As Integer, bFail As Integer
Dim sItem As String, lItemData As Long
Dim iPos As Integer, bInBox As Integer

   On Error GoTo AddToSelErr
   sSwitches = LCase(sSwitches)
   bInBox = False

'Check that the necessary boxes have an item selected.
   If bAdding Then
         'Requires a selected item in LstUnSelected
          iIndUn = cLstUnselected.ListIndex
          If iIndUn = -1 Then bFail = True
      Else
         'Requires a selected item in LstSelected
         iIndSel = cLstSelected.ListIndex
         If iIndSel = -1 Then bFail = True
      End If

   If bFail Then Exit Sub

'Now move the selected item and item data
   If bAdding Then
         'move from LstUnselected to LstSelected.
         sItem = cLstUnselected.List(iIndUn)
         lItemData = cLstUnselected.ItemData(iIndUn)
         cLstUnselected.RemoveItem iIndUn
         If InStr(sSwitches, "/du") = 0 Then           '/du = allow duplicates
            'not allowing duplicates, do not add if it already exists
               iPos = SendMessage(cLstSelected.Hwnd, LB_FINDSTRING, -1, ByVal sItem)
               If iPos > -1 Then bInBox = True     'Item already exists in box
            End If
         If Not bInBox Then
               cLstSelected.AddItem sItem
               cLstSelected.ItemData(cLstSelected.NewIndex) = lItemData
            End If
      Else
         'Move from LstSelcted to lstUnselected
         sItem = cLstSelected.List(iIndSel)
         lItemData = cLstSelected.ItemData(iIndSel)
         cLstSelected.RemoveItem iIndSel
         If cLstSelected.ListCount > iIndSel Then
               cLstSelected.ListIndex = iIndSel
            Else
               If cLstSelected.ListCount > 0 Then cLstSelected.ListIndex = iIndSel - 1
            End If
         If InStr(sSwitches, "/fr") = 0 Then    '/fr = Full remove
               'Not doing full remove, so add to box
               If InStr(sSwitches, "/du") = 0 Then
                  'Not allowing duplicates, check if it's in the box already
                     iPos = SendMessage(cLstSelected.Hwnd, LB_FINDSTRING, -1, ByVal sItem)
                     If iPos > -1 Then bInBox = True     'Item already exists in box
                  End If
               If Not bInBox Then
                     cLstUnselected.AddItem sItem
                     cLstUnselected.ItemData(cLstUnselected.NewIndex) = lItemData
                  End If
            End If
      End If
         

AddToSelExit:

Exit Sub


AddToSelErr:
   sItem = "Error " & Format$(Err) & ": '" & Error$ & "' occurred in " & cr$
   sItem = sItem & "procedure AddToSelected." & cr$
   sItem = sItem & "bAdding   = " & Iff(bAdding, "True", "False") & cr$
   sItem = sItem & "sSwitches = " & sSwitches & cr$
   popmessagecr "", sItem
Resume AddToSelExit

End Sub

Sub askwin(title$, prompt$, ans$, k As kbdcontrol)
'13Sep96 CKJ Added icons: First char of title sets icon to be used:
'            !  exclamtion
'            @  stop
'            ?  question
'            #  information
'04Jun04 CKJ 32bit: now calls MessageBox.
'            NB does not support k.exitval or k.timd        **GONE** may be needed though

Dim ttl$, ico As Long, currentcsr%

   currentcsr% = Screen.MousePointer '16Nov98 ASC stops hourglass persisting if fired in line
   Screen.MousePointer = STDCURSOR   '   "
   
'   gTimedOut = False
    
    ttl$ = title$
    Select Case Left$(ttl$, 1)
        Case "!":  ico = MB_ICONEXCLAMATION
        Case "?":  ico = MB_ICONQUESTION
        Case "#":  ico = MB_ICONINFORMATION
        Case ".":  ico = MB_ICONSTOP
        Case "~":  ico = ASC_ICONSAMPLE
        Case Else: ico = 0
        End Select
    If ico Then ttl$ = Mid$(ttl$, 2)
    
    Select Case UCase$(ans$)
        Case "Y":  ico = ico Or MB_DEFBUTTON1
        Case "N":  ico = ico Or MB_DEFBUTTON2
        Case Else: ico = ico Or MB_DEFBUTTON2
        End Select
    
    ico = ico Or MB_YESNOCANCEL
    popmsg ttl$, prompt$, ico, ans$, k.escd
    If k.escd Then ans$ = ""

'   k.exitval = 13 / 27
'   k.timd = gTimedOut
   
   Screen.MousePointer = currentcsr%
  
End Sub

''Function AskWinChk(sCaption As String, sPrompt As String, iButtons As Integer, sCheckPrompt As String) As Integer
''
'''Similar to AskWin, but has a check box to allow programs to provide
'''self-configuring "Don't ask again" type functionality, as seen in modern
'''windows apps. Code (heavilly!) based on AskWin.
'''Also self-sizes as per messagebox, and allows cr to be used as a line separator
''
'''sCaption - caption for form + iIconn declaration character as below.
'''           First char of Caption sets iIconn to be used:
'''            !  exclamtion
'''            @  stop
'''            ?  question
'''            #  information
'''
'''sPrompt - text message for user.
'''iButtons - as for message box, can use any of:
'''           MB_YESNOCANCEL
'''           MB_YESNO
'''
'''sCheckPrompt - If empty "", the check box is not shown.  Otherwise,
'''               this text is shown as the check box prompt.
'''               Bear in mind that the check box is unchecked by default when
'''               choosing a prompt....
'''
'''ReturnValue: Integer holding the button Id pressed, plus the check box value
'''             in the 8th bit
'''             Use: Value AND {IDYES|IDNO|IDCANCEL} to check the buttons
'''                  Value AND IDCHECKED to see if the check box was ticked.
''
'''------------------------------------------------------------------------------------------------
'''02Jun00 AE  Written, based on AskWin
''
''
''Dim sCap As String, iIcon As Integer, iCursor
''Dim bChkBox As Integer, iReturn As Integer
''Dim fWidth As Single, fheight As Single
''Dim n As Integer, iTmp As Integer
''Dim ObjMsgWin As frmMsgWin
''
''Const MW_MINHEIGHT = 300
''Const MW_MINWIDTH = 3000
''Const BORDER = 300
''
''   iCursor = Screen.MousePointer '16Nov98 ASC stops hourglass persisting if fired in line
''   Screen.MousePointer = STDCURSOR   '   "
''
''   Set ObjMsgWin = New frmMsgWin
''   Load ObjMsgWin
''
''
'''Set up title and icon
''   sCap = sCaption
''   iIcon = 0                 'no iIconn wanted
''   Select Case Left$(sCap, 1)
''      Case "@": iIcon = 1    'stop
''      Case "?": iIcon = 2    'question
''      Case "!": iIcon = 3    'exclamation
''      Case "#": iIcon = 4    'information
''      End Select
''   If iIcon Then
''         sCap = Mid$(sCap, 2)
''         ObjMsgWin.img1(iIcon).Left = 0.5 * BORDER
''         ObjMsgWin.img1(iIcon).Visible = True
''         ObjMsgWin.lblbox.Left = ObjMsgWin.img1(iIcon).Width + 1.5 * BORDER
''         ObjMsgWin.lblbox.Top = ObjMsgWin.img1(iIcon).Top
''      Else
''         ObjMsgWin.lblbox.Left = BORDER
''         ObjMsgWin.lblbox.Top = 0.5 * BORDER
''      End If
''   Do While Left$(sCap, 1) = "!" And Len(sCap) > 1
''      sCap = Mid$(sCap, 3)
''   Loop
''   ObjMsgWin.Caption = sCap
''
'''Size the form to the correct size according to the text:
''   TxtWidthHeight ObjMsgWin.lblbox, sPrompt, fWidth, fheight
''   ObjMsgWin.lblbox.Caption = sPrompt
''   If fWidth < MW_MINWIDTH Then fWidth = MW_MINWIDTH
''   If fheight < MW_MINHEIGHT Then fheight = MW_MINHEIGHT
''   ObjMsgWin.lblbox.Height = fheight
''   ObjMsgWin.lblbox.Width = fWidth
''
'''Set up check box if required
''   If sCheckPrompt <> "" Then bChkBox = True
''   ObjMsgWin.ChkBox.Value = 0
''   ObjMsgWin.ChkBox.Left = ObjMsgWin.lblbox.Left
''
''   If bChkBox Then
''         ObjMsgWin.ChkBox.Visible = True
''         ObjMsgWin.ChkBox.Enabled = True
''         ObjMsgWin.ChkBox.Caption = sCheckPrompt
''         ObjMsgWin.ChkBox.Top = ObjMsgWin.lblbox.Height + ObjMsgWin.lblbox.Top + 0.5 * BORDER
''      Else
''         ObjMsgWin.ChkBox.Visible = False
''         ObjMsgWin.ChkBox.Enabled = False
''         ObjMsgWin.ChkBox.Top = ObjMsgWin.lblbox.Height + ObjMsgWin.lblbox.Top
''      End If
''
'''Set up buttons:
''   'Captions
''   ObjMsgWin.cmdBtn(1).Caption = Trim$(getYN$(6))   '&Yes
''   ObjMsgWin.cmdBtn(2).Caption = Trim$(getYN$(7))   '&No
''   ObjMsgWin.cmdBtn(0).Caption = "&" & T1("Cancel") '&Cancel
''
''   'vertical position:
''   iTmp = ObjMsgWin.ChkBox.Height + ObjMsgWin.ChkBox.Top + 0.5 * BORDER
''   For n = 0 To 2
''      ObjMsgWin.cmdBtn(n).Top = iTmp
''   Next
''
'''Size the form:
''   'Vertical - done off the command button position, as they are the lowest control
''   'Lateral - done from the LblBox width
''   ObjMsgWin.Width = ObjMsgWin.lblbox.Left + ObjMsgWin.lblbox.Width
''   ObjMsgWin.Height = ObjMsgWin.cmdBtn(0).Top + ObjMsgWin.cmdBtn(0).Height + 2 * BORDER
''
''
''   'Which are visible and which are hidden
''   Select Case iButtons
''      Case MB_YESNOCANCEL
''         ObjMsgWin.cmdBtn(1).Enabled = True            '&Yes
''         ObjMsgWin.cmdBtn(2).Enabled = True            '&No
''         ObjMsgWin.cmdBtn(0).Enabled = True            '&Cancel
''         ObjMsgWin.cmdBtn(1).Visible = True
''         ObjMsgWin.cmdBtn(2).Visible = True
''         ObjMsgWin.cmdBtn(0).Visible = True
''
''         iTmp = (ObjMsgWin.Width - (3 * ObjMsgWin.cmdBtn(0).Width) - (2 * BORDER)) / 4
''         ObjMsgWin.cmdBtn(1).Left = BORDER + iTmp
''         ObjMsgWin.cmdBtn(2).Left = ObjMsgWin.cmdBtn(1).Left + ObjMsgWin.cmdBtn(1).Width + iTmp
''         ObjMsgWin.cmdBtn(0).Left = ObjMsgWin.cmdBtn(2).Left + ObjMsgWin.cmdBtn(2).Width + iTmp
''
''
''      Case MB_YESNO
''         ObjMsgWin.cmdBtn(1).Enabled = True            '&Yes
''         ObjMsgWin.cmdBtn(2).Enabled = True            '&No
''         ObjMsgWin.cmdBtn(0).Enabled = False           '&Cancel
''         ObjMsgWin.cmdBtn(1).Visible = True
''         ObjMsgWin.cmdBtn(2).Visible = True
''         ObjMsgWin.cmdBtn(0).Visible = False
''
''         iTmp = (ObjMsgWin.Width - (2 * ObjMsgWin.cmdBtn(0).Width) - (2 * BORDER)) / 3
''         ObjMsgWin.cmdBtn(1).Left = BORDER + iTmp
''         ObjMsgWin.cmdBtn(2).Left = ObjMsgWin.cmdBtn(1).Left + ObjMsgWin.cmdBtn(1).Width + iTmp
''      End Select
''
'''Use standard grey colour 'cos it looks better...
''   ObjMsgWin.BackColor = &H8000000A
''   ObjMsgWin.ChkBox.BackColor = &H8000000A
''   ObjMsgWin.lblbox.BackColor = &H8000000A
''
'''Show the box
''   gTimedOut = False
''   ObjMsgWin.Show 1     'modal
''
'''Return the button
''   Select Case ObjMsgWin.Tag
''      Case "0"
''         iReturn = IDCANCEL
''      Case "1"
''         iReturn = IDYES
''      Case "2"
''         iReturn = IDNO
''      End Select
''
'''And the checkbox
''   iReturn = iReturn + Iff(ObjMsgWin.ChkBox.Value = 1, IDCHECKED, 0)
''
''   AskWinChk = iReturn
''
''   Unload ObjMsgWin
''   Set ObjMsgWin = Nothing
''   Screen.MousePointer = iCursor      '16Nov98 ASC
''
''
''End Function

Sub CaptureScreen()
'13May97 CKJ Copy full screen onto frmBlank
'            Derived from Technet example screen saver 'Shuffle'

Dim ScreenhWnd As Long
Dim ScreenDC As Long
Dim retval As Long

   frmBlank.Move 0, 0, Screen.Width, Screen.Height  'Make form same size as screen
   
   ScreenhWnd = GetDesktopWindow()                  'Get hWnd to Desktop
   ScreenDC = GetDC(ScreenhWnd)                     'Get hDC of Desktop
   
   'Draw desktop onto blank form
   retval = BitBlt(frmBlank.hdc, 0, 0, frmBlank.ScaleWidth, frmBlank.ScaleHeight, ScreenDC, 0, 0, SRCCOPY)
   retval = ReleaseDC(ScreenhWnd, ScreenDC)         'Release DC
    
End Sub

Sub CentreControl(ControlName As Control, frmName As Form)
'27Feb96 KR Moved to GUIBITS.bas from ident.frm
' 8Dec96 CKJ Changed to integer divide, and simplified

   ControlName.Move (frmName.Width - ControlName.Width) \ 2, (frmName.Height - ControlName.Height) \ 2
   
End Sub

Sub CentreForm(AnyForm As Form)
'27Feb96  KR Moved from Security.bas
'12Aug96 CKJ Added error trap - needed if form maximised
' 8Dec96 CKJ Changed to integer divide, and simplified

   On Error Resume Next
   AnyForm.Move (Screen.Width - AnyForm.Width) \ 2, (Screen.Height - AnyForm.Height) \ 2
   AnyForm.Refresh
   On Error GoTo 0
   
End Sub

Sub Confirm(title$, prompt$, ans$, k As kbdcontrol)
'11Mar96 CKJ Simplified

Dim ttl$
   
   ttl$ = title$
   Do While Left$(ttl$, 1) = "!" And Len(ttl$) > 1
      ttl$ = Mid$(ttl$, 3)
   Loop
   askwin ttl$, T1("OKto", "OK to ") & prompt$ & "?", ans$, k

End Sub


Sub displaymacrofile(ByVal strFilename As String, ByVal strTitle As String, ByRef strCode As String, ByRef strDesc As String, ByVal blnShowall As Boolean)
'-----------------------------------------------------------------------------
'         Display macro file on screen
'-----------------------------------------------------------------------------

Dim posn%
Dim strParameters As String
Dim vInUse As Variant
Dim rsLookups As ADODB.Recordset
Dim lErrNo        As Long
Dim sErrDesc      As String
Dim strSortOrder As String
Const ErrSource   As String = "displaymacrofile"

   On Error GoTo ErrorHandler
   strCode = ""
   strDesc = ""

   LstBoxFrm.LstBox.Clear  '07Feb05 TH (#78710)

   LstBoxFrm.Caption = strTitle
   LstBoxFrm.lblHead.Caption = "Code    " & TB & "Description"
   
   If blnShowall Then vInUse = Null Else vInUse = True
   strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                   gTransport.CreateInputParameterXML("FileName", trnDataTypeChar, 255, strFilename) & _
                   gTransport.CreateInputParameterXML("Code", trnDataTypeChar, 10, Null) & _
                   gTransport.CreateInputParameterXML("InUse", trnDataTypeBit, 1, vInUse)

   Set rsLookups = gTransport.ExecuteSelectSP(g_SessionID, "pWLookupSelectByCriteria", strParameters)
   '05Dec05 TH Added Sort order Check
   strSortOrder = TxtD(dispdata$ & "\ascribe.ini", "LookupSortby", "", strFilename, 0)
   If Trim$(strSortOrder) <> "" Then
      rsLookups.Sort = strSortOrder
   End If
   '--------------------------------
   
   If Not rsLookups.EOF Then
      rsLookups.MoveFirst
      Do While Not rsLookups.EOF
         LstBoxFrm.LstBox.AddItem GetField(rsLookups!Code) & TB & Trim$(GetField(rsLookups!Value))
         rsLookups.MoveNext
      Loop
   End If
   rsLookups.Close
   
   LstBoxShow

   posn = InStr(LstBoxFrm.Tag, TB)
   If posn Then
      strCode = Left$(LstBoxFrm.Tag, posn - 1)
      strDesc = Mid$(LstBoxFrm.Tag, posn + 1)
   End If

Cleanup:
   On Error Resume Next
   rsLookups.Close
   Set rsLookups = Nothing
   Unload LstBoxFrm
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup

End Sub

Sub EnhDisplayMacrofile(ByVal strFilename As String, ByVal strTitle As String, ByRef strCode As String, ByRef strDesc As String, ByVal blnShowall As Boolean)

Dim posn%
Dim strParameters As String
Dim rsLookups As ADODB.Recordset
Dim vInUse As Variant
Dim lErrNo        As Long
Dim sErrDesc      As String
Const ErrSource   As String = "EnhDisplaymacrofile"

   On Error GoTo ErrorHandler
   strCode = ""
   strDesc = ""

   EnhLstFrm.LstBox.Clear
   EnhLstFrm.Caption = strTitle
   EnhLstFrm.lblTitle.Caption = ""
   EnhLstFrm.lblHead.Caption = "Code     " & TB & "Description  "

   If blnShowall Then vInUse = Null Else vInUse = True
   strParameters = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                   gTransport.CreateInputParameterXML("FileName", trnDataTypeChar, 255, strFilename) & _
                   gTransport.CreateInputParameterXML("Code", trnDataTypeChar, 10, Null) & _
                   gTransport.CreateInputParameterXML("InUse", trnDataTypeBit, 1, vInUse)

   Set rsLookups = gTransport.ExecuteSelectSP(g_SessionID, "pWLookupSelectByCriteria", strParameters)
   
   If Not rsLookups.EOF Then
      rsLookups.MoveFirst
      Do While Not rsLookups.EOF
         EnhLstFrm.LstBox.AddItem GetField(rsLookups!Code) & TB & Trim$(GetField(rsLookups!Value))
         rsLookups.MoveNext
      Loop
   End If
     
   rsLookups.Close
   
   EnhLstBoxShow

   posn = InStr(EnhLstFrm.LstBox.Tag, TB)
   If posn Then
      strCode = Left$(EnhLstFrm.LstBox.Tag, posn - 1)
      strDesc = Mid$(EnhLstFrm.LstBox.Tag, posn + 1)
   End If
   
Cleanup:
   On Error Resume Next
   rsLookups.Close
   Set rsLookups = Nothing
   Unload EnhLstFrm
   On Error GoTo 0
   
   If lErrNo Then
      Err.Raise lErrNo, OBJNAME & ErrSource, sErrDesc
   End If
Exit Sub

ErrorHandler:
   lErrNo = Err.Number
   sErrDesc = Err.Description
Resume Cleanup

End Sub

Function fmt(NumExpr As Single, fmtstr As String) As String
Dim tmp$

   tmp$ = Format$(NumExpr, fmtstr)
   fmt = Right$(Space$(Len(fmtstr)) & tmp$, Len(fmtstr))

End Function

Function FormatVal$(Level$, dcpl%, sgfig%)
'19Jul99 AE
' To return a formated version of a string containing a numerical value
' to sgfig% significant figures, with a mximum of dcpl% decimal places
' Whole numbers are returned with no decimal places.
'-----------------------------------------------------------------

Dim lv!, lvl$

   lvl$ = Level$                  'default to display 0
   lvl$ = StrDecPl$(lvl$, dcpl%)
   lvl$ = StrSigFigs$(lvl$, sgfig%)
   lv! = Val(lvl$)
   If lv! - Int(lv!) = 0 Then        'If a whole number, do not display any decimal places.
      lvl$ = StrDecPl$(lvl$, 0)
   End If

   FormatVal$ = lvl$

End Function

Sub frmoptionset(Action As Integer, txt$)
'14Aug96 CKJ Written. Use as follows;
'
'            frmOptionSet 0, "Mandatory Caption Here" 'Action 0 initialises
'            FOR count = 1 TO numofitems
'               frmOptionSet 1, description$(count)   'Action 1 adds a line
'            NEXT
'            frmOptionShow "010011", result$          'X against lines 2,5,6
'            'where '010011' represents those options to be pre-selected.
'            frmOptionSet 0, ""                       'To unload the form
'
'            The result string is returned in the same way, using 0 & 1
'            as place markers, or equal to "" if escaped or timed out.
'            The user's choice is held & is offered again next time, if the
'            form has not been unloaded and the preset string is empty.
'
' 2Oct96 CKJ Added Radio Buttons
'            Usage is basically the same, but call reset with Action=-1
'
'            frmOptionSet -1, "Mandatory Caption Here" 'Action -1 initialises for Radio buttons
'            FOR count = 1 TO numofitems
'               frmOptionSet 1, description$(count)    'Action 1 adds a line (same as above)
'            NEXT
'            frmOptionShow "4", result$                'Preset 4th button 'On'
'            frmOptionSet 0, ""                        'To unload the form
'
'            Result$ contains the number of the button selected or empty string if escaped.
'
'15Jul98 CKJ Corrected a few bits
'18Jul00 CKJ Allow invisible entries: text = nul character chr$(0)
'            Allow visible but disabled: append a nul character chr$(0) to the end of the text
'12sep01 CKJ added prompt above the frame.
'            To use it call with Action=-2
'            frmOptionSet -2, "Optional Prompt Text Here"
'            This can be over several lines, each separated by CRLF only.

Dim count%, created As Integer, tmp$
Dim iEnabled As Integer
Dim iVisible As Integer

   Select Case Action
      Case 0, -1                          'Reset & fill caption / Unload
         If txt$ = "" Then
               Unload frmOption
               Set frmOption = Nothing    '15Jul98 CKJ added
            Else
               frmOption.Caption = txt$
               On Error Resume Next       'unload all added check boxes and/or option buttons
               For count = 0 To frmOption.Controls.count - 1
                  Unload frmOption.Controls(count)
               Next
               On Error GoTo 0
               frmOption.CmdOk.Tag = "0"
               RadioBtns = Action         'T/F
               frmOption.mnuSet(1).Enabled = Not RadioBtns  '15Jul98 CKJ added
            End If
      
      Case -2                             'Set the Prompt text             '12sep01 CKJ added
         frmOption.lblPrompt.Caption = txt$
      
      Case 1                              'Add new line
         'If Len(Trim(txt$)) Then         '15Jul98 CKJ Removed as it could get out of step
         created = Val(frmOption.CmdOk.Tag) + 1
         iVisible = (txt$ <> Nul)                                          '18Jul00 CKJ allow invisible entries
         iEnabled = (Right$(txt$, 1) <> Nul)                               '   "        allow visible but disabled
         tmp$ = Iff(Len(txt$), " " & txt$, "")
         If RadioBtns Then
               Load frmOption.Option1(created)
               frmOption.Option1(created).Top = 240 * created
               'frmOption.Option1(created).Visible = True                  '18Jul00 CKJ allow invisible entries
               frmOption.Option1(created).Visible = iVisible
               'frmOption.Option1(created).Enabled = True                  '   "        allow visible but disabled
               frmOption.Option1(created).Enabled = iEnabled
               frmOption.Option1(created).Caption = tmp$
            Else
               Load frmOption.chk3D1(created)
               frmOption.chk3D1(created).Top = 240 * created
               'frmOption.chk3D1(created).Visible = True                   '18Jul00 CKJ allow invisible entries
               frmOption.chk3D1(created).Visible = iVisible
               'frmOption.chk3D1(created).Enabled = true                   '   "        allow visible but disabled
               frmOption.chk3D1(created).Enabled = iEnabled
               frmOption.chk3D1(created).Caption = tmp$
            End If
         frmOption.CmdOk.Tag = Str$(created)
         'End If
      End Select

End Sub

Sub frmoptionshow(preset As String, result As String)
'14Aug96 CKJ Written. See frmOptionSet for instructions.
' 2Oct96 CKJ Added Radio Buttons
' 6Aug97 CKJ replaced IIF with Iff
'15Jul98 CKJ Modified to allow multiple columns
'            Fairly crude and could be made much more elegant, but tested with up to 129 rows
'            Also now sets line with focus to bold, makes it more obvious
'14feb03 CKJ Set width of form based on text box as well as individul items

Dim count%, maxW%, tmp%, setup$, frmHt%, Rows%, Cols%

   maxW = 0                                                                                '14feb03 CKJ
   Rows = Val(frmOption.CmdOk.Tag)
   If Len(Trim$(frmOption.lblPrompt.Caption)) Then                                         '12sep01 CKJ added
         frmOption.Frame3D1.Top = frmOption.lblPrompt.Height + 240                         '   "
         maxW = frmOption.lblPrompt.Width + 240                                            '14feb03 CKJ
      End If
   
   Do
      frmOption.Frame3D1.Height = Rows * 240 + 480
      frmOption.CmdOk.Top = frmOption.Frame3D1.Top + frmOption.Frame3D1.Height + 120
      frmOption.cmdCancel.Top = frmOption.CmdOk.Top
        frmHt = frmOption.CmdOk.Top + frmOption.CmdOk.Height + 600 + 400 'Bug 208978 - Stores-Buttons in the bottom chopped off
      frmOption.Height = frmHt
      If frmOption.Height = frmHt Then Exit Do                  'successful
      Rows = Rows - 1
   Loop Until Rows = 1                                          'must be room for at least 1 row
   Cols = (Val(frmOption.CmdOk.Tag) - 1) \ Rows + 1

   'maxW = 0                                                                               '14feb03 CKJ
   setup$ = pad$(UCase$(preset), Val(frmOption.CmdOk.Tag))      '15Jul98 CKJ was 20 max
   For count = 1 To frmOption.CmdOk.Tag
      If RadioBtns Then
            tmp = txtwidth(frmOption.Option1(0), (frmOption.Option1(count).Caption))
            'If tmp > 2300 Then frmOption.Option1(count).Width = tmp + 300
         Else
            tmp = txtwidth(frmOption.chk3D1(0), (frmOption.chk3D1(count).Caption))
            'If tmp > 2300 Then frmOption.chk3D1(Count).Width = tmp + 240
         End If
      If tmp > maxW Then maxW = tmp                             'find max width of text
      If Not RadioBtns Then
            Select Case Mid$(setup, count, 1)
               Case Chr$(0)
               Case " ", "0", "F":
                  frmOption.chk3D1(count).Value = False
               Case Else:
                  frmOption.chk3D1(count).Value = 1  '07Feb12 TH Was True
               End Select
         End If
   Next
   
   For count = 1 To frmOption.CmdOk.Tag              'move columns 2 onwards to right
         If RadioBtns Then
            frmOption.Option1(count).Left = 240 + ((count - 1) \ Rows) * (maxW + 720)
            'frmOption.Option1(count).Width = maxW + 240
            frmOption.Option1(count).Width = maxW + 500  'v93 SQL Boosted this
            frmOption.Option1(count).Top = frmOption.Option1(count).Top - ((count - 1) \ Rows) * Rows * 240
            frmOption.Option1(count).FontBold = False
         Else
            frmOption.chk3D1(count).Left = 240 + ((count - 1) \ Rows) * (maxW + 720)
            frmOption.chk3D1(count).Width = maxW + 300
            frmOption.chk3D1(count).Top = frmOption.chk3D1(count).Top - ((count - 1) \ Rows) * Rows * 240
            frmOption.chk3D1(count).FontBold = False
         End If
   Next

   If RadioBtns Then
         On Error Resume Next
         frmOption.Option1(Val(preset)).Value = True
         On Error GoTo 0
      End If

   'text of 2280 needs width of 2500
   ' 240 240       240 240
   '|   |   X  text   |   |
   If (maxW + 720) * Cols + 240 > 3000 Then
         frmOption.Frame3D1.Width = (maxW + 720) * Cols + 240
         frmOption.Width = frmOption.Frame3D1.Width + 225
      End If

   frmOption.cmdCancel.Left = frmOption.ScaleWidth \ 2 + 120
   frmOption.CmdOk.Left = frmOption.cmdCancel.Left - frmOption.CmdOk.Width - 240
   
   CentreForm frmOption
   frmOption.Tag = ""
   gTimedOut = False    '7Mar97 CKJ Added

   frmOption.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   
   result = ""
   If frmOption.Tag = "1" Then 'OK pressed
         For count = 1 To frmOption.CmdOk.Tag
            If RadioBtns Then
                  If frmOption.Option1(count).Value Then
                        result = Format$(count)
                        Exit For
                     End If
               Else
                  'result = result + IIf(frmOption.chk3D1(Count).Value, "1", "0")
                  result = result & Iff((frmOption.chk3D1(count).Value), "1", "0") '6Aug97 CKJ replaced IIF with Iff
               End If
         Next
      End If

End Sub

Function GetNumEditorLines() As Integer
'24Feb99 SF added to get the number of editable lines on the editors form

   If numEditorLines% = 0 Then numEditorLines% = 10   ' default value
   GetNumEditorLines% = numEditorLines%

End Function

''Function GetSetupHeapID() As Integer
''
'''Return the Id of the SetupOptions Heap (module level)
'''02Mar00 AE
''
''   GetSetupHeapID = iSetupHeap
''
''
''End Function

''Sub GetSetupOptions(iIndex As Integer, sDescription As String, sInfo As String, iSetType As Integer, sSetting As String)
''
'''Partner to FillSetupOptions
'''Reads the heap to return a particular item
''
'''iIndex: Index of the item we want to return.
'''sDescription: Text description which appears in the top list box
'''sInfo: Further text describing the option which appears in the middle box for the selected option
'''iSetType: The type of settings allowed for this option:
'''        1: On / Off
'''        2: Numerical Value
'''        3: Free Text
'''sSetting: Default setting for this option.
'''----------------------------------------------------------------------
'''02Mar00 AE
''
''Dim sTmp As String
''
''   sDescription = ""
''   sInfo = ""
''   iSetType = 0
''   sSetting = ""
''
''   If iSetupHeap = 0 Or iIndex < 1 Then Exit Sub
''
''   Heap 11, iSetupHeap, "Description" & Format$(iIndex), sDescription, 0
''   Heap 11, iSetupHeap, "Info" & Format$(iIndex), sInfo, 0
''   Heap 11, iSetupHeap, "SetType" & Format$(iIndex), sTmp, 0
''   iSetType = Val(sTmp)
''   Heap 11, iSetupHeap, "Setting" & Format$(iIndex), sSetting, 0
''
''End Sub

Function GreaterOf(ByVal opt1 As Variant, ByVal opt2 As Variant) As Variant
'11Oct97 written
'returns the greater of two values

   If opt1 > opt2 Then
         GreaterOf = opt1
      Else
         GreaterOf = opt2
      End If

End Function

Sub HorizCentreForm(AnyForm As Form)
'12Aug96 CKJ Added error trap - needed if form maximised
' 8Dec96 CKJ Changed to integer divide and simplified

   On Error Resume Next
   AnyForm.Move (Screen.Width - AnyForm.Width) \ 2
   AnyForm.Refresh
   On Error GoTo 0

End Sub

Sub inputmenu(Menu$(), menuhlp(), ans$, k As kbdcontrol)
' 3Sep96 CKJ Added Heading facility in menu(0)
' 4Nov96 CKJ Converted from crude numbered list to a listbox
'21Nov96 CKJ Add only up to first blank entry in array

Dim X As Integer, prompt$

   Unload LstBoxFrm
   LstBoxFrm.Caption = "Select Option"
   prompt$ = ""
   On Error Resume Next
   prompt$ = Menu$(0)
   On Error GoTo 0
   If Len(prompt$) Then LstBoxFrm.lblTitle = cr & prompt$ & cr

   For X = 1 To UBound(Menu$)
      If Menu$(X) = "" Then Exit For   '21Nov96 CKJ Added
      LstBoxFrm.LstBox.AddItem "  " & Menu$(X)
      If X = Val(ans$) Then
            LstBoxFrm.LstBox.ListIndex = X - 1
         End If
   Next

   k.escd = False
   gTimedOut = False    '7Mar97 CKJ Added
   k.timd = gTimedOut   '7Mar97 CKJ Added
   
   LstBoxShow
   
   ans$ = Format$(LstBoxFrm.LstBox.ListIndex + 1)
   k.timd = gTimedOut   '7Mar97 CKJ Added
   Unload LstBoxFrm
   If ans$ = "0" Then k.escd = True: ans$ = ""

   
   'prompt$ = ""
   'On Error Resume Next
   'prompt$ = menu$(0)
   'On Error GoTo 0
   'If Len(prompt$) Then prompt$ = prompt$ + cr$ & cr$
   '
   'For x = 1 To UBound(menu$)
   '   prompt$ = prompt$ & Trim$(Str$(x)) & "  " & menu$(x) & cr$
   'Next
   'k.max = 2
   'inputwin "Select Option", prompt$, ans$, k

End Sub

Function InputValid(KeyAscii%, Vallidation$) As Boolean
'19Jul99 AE written
'Simple input masking function. Allows anything below ANSI 32 (space), rejects anything
'above ANSI 127 (~) and anything not held in Valiidation$.


Dim OK%


   OK = False

   If KeyAscii < 126 Then                           'anything >126 (~) returns false
         If KeyAscii > 31 Then                      'below 32 ( ) are control chars and are allowed
               If InStr(Vallidation$, Chr$(KeyAscii)) > 0 Then OK = True   'otherwise, check the vallidation string
            Else
               OK = True
            End If
      End If


   InputValid = OK

End Function

Sub InputWin(title$, prompt$, ans$, k As kbdcontrol)
'13Aug96 CKJ Added timeout
'18Sep96 CKJ added k.escd=false
'22Oct95 CKJ Added k.timd=false

   frmTxtWin.Caption = title$
   frmTxtWin.lblbox.Caption = prompt$
   frmTxtWin.txtBox = ans$
   frmTxtWin.txtBox.SelStart = 0
   frmTxtWin.txtBox.SelLength = Len(frmTxtWin.txtBox)
   If k.passwrd Then frmTxtWin.txtBox.PasswordChar = "*" '19Dec96 CKJ
   gTimedOut = False      '7Mar97 CKJ Added
   k.timd = False         '22Oct95 CKJ Added
   gk = k
   gk.exitval = 27
   HorizCentreForm frmTxtWin
   If gk.timeout Then TimeoutOn frmTxtWin.Timer1
   
   frmTxtWin.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form      'modal
   
   ans$ = frmTxtWin.txtBox
   Unload frmTxtWin
   'gk.timd = k.timd      'timeout uses 'normal' k   7Mar97 CKJ Removed
   k = gk
   k.escd = False         '18Sep96 CKJ added
   k.timd = gTimedOut     ' 7Mar97 CKJ Added
   If k.timd Then k.exitval = 27
   If k.exitval = 27 Then k.escd = True
   k.validchars = nulls
   k.Max = 0              ' max will default to available space (currently preset to 78)
   k.min = 0              ' no minimum as standard
   k.esc = True           ' allow escape
   k.nums = False         ' default is whole character set
   k.decimals = False     '    "
   k.timeout = True       ' reset to standard timeout
   k.norefresh = False    '12Sep96 CKJ
   k.date = False         '   "
''   frmTxtWin.txtBox.PasswordChar = "" '19Dec96 CKJ
   k.passwrd = False                  '   "

' Q4INPUT.BAS:inputline     Other bits to think about ...
'    k.wipedef = False    ' don't wipe default next time
'    ans = RTrim$(ans)    ' the string at time of exit (or empty if escd?   !!**)
'    k.ret = False        ' return alone not allowed

End Sub

Function LesserOf(opt1 As Variant, opt2 As Variant) As Variant
'11Oct97 written
'returns the lesser of two values

   If opt1 < opt2 Then
         LesserOf = opt1
      Else
         LesserOf = opt2
      End If

End Function

Sub ListBoxTextBoxSetTabs(ctlList As Control, NumTabs As Integer, TabStops() As Long)
'21Sep96 CKJ Written - but not ready for use.
' 2Oct96 CKJ Released. Normally used in conjunction with LstBoxShow, but is OK for
'            any standard list box. The TabStops() values are in dialogbox units, ie
'            approx 4 per average character. Send NumTabs=0 to clear previous settings.
'18Sep97 CKJ Now works for text boxes too. Unfortunately, it's still called LstBoxSetTabs!
'09May05 CKJ changed array int to long
'            changed procedure name from LstBoxSetTabs as it also handles text boxes

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

Sub LstBoxShowOriginal()
'Present a list box to the user, headings automatically sized as needed.
'Usage:
'   LstBoxFrm.Caption = "Caption displayed in the top bar"
'   LstBoxFrm.lblTitle = cr$ & "Main heading, optionally with CR's, and over several lines" & cr$
'   LstBoxFrm.lblHead  = "Optional secondary heading, for column names above the list box"
'   For x = 1 to n
'      LstBoxFrm.LstBox.AddItem " Add items here ..."
'   Next
'   LstBoxShow         'use this to size & show - do not call Show method directly
'   LineChosen = LstBoxFrm.LstBox.ListIndex + 1
'   Unload LstBoxFrm   'or use LstBoxFrm.LstBox.RemoveItem 0 until empty
' Note that the Caption, lblTitle and lblHead are all optional
'
'12Aug96 CKJ Changed font from Terminal to MS Linedraw
'13Aug96 CKJ Added timeout
' 2Oct96 CKJ Changed font back again, since MS Linedraw is not standard on W95 & won't
'            work at all on Chinese W95
'            Changed the maininfo label at the top to be lblTitle, to avoid confusion
'            with lblHead which is now used for the column headings.
'            Added automatic tab stops. To use simply set lblHead to the column headings
'            required, with tabs between each column and enough spaces in each column
'            to indicate the size wanted. Note that TB is preset and is global.  e.g.
'            LstBoxFrm.lblHead = "Description         " & TB & "Quantity    " & TB & "Cost "
'            will set up three columns of widths 20, 12 and 5 chars respectively.
' 2Nov96 CKJ Added k.helpnum
' 6Nov96 CKJ added width of scrollbar
'19Nov96 CKJ Supports use of popup menu on right click.
'            Fill menu with calls to PopMenu, and check on completion of
'            LstBoxShow for menu result in LstBoxFrm.LstBox.Tag. The line
'            highlighted at the tim ei sreturned in the normal way too, so
'            failure to check for right click & menu selection will resemble
'            a normal double click.
'29Apr97 CKJ Added mousepointer
'15Jun97 KR  If title < header then set maxwidth according to length of header.
'15Oct97 CKJ Corrected above mod
'15May98 CKJ increased max TabStops from 5 to 25
'12Jul98 CKJ corrected amount of blank space below box
'18Jul00 CKJ Height of list box at design time increased to full height of 768 pixels
'            Now has to be vertically centred
'27May11 XN  F087364 Cleared SetKeyUpCallBackProc after form is displayed

Dim maxwidth As Single, i As Single, X As Single

   ReDim TabStops(25) As Long

   'set to not min, not max
   LstBoxFrm.WindowState = 0   '!!** Sometines ignored for some reason!
   Screen.MousePointer = HOURGLASS
   
   LstBoxFrm.LstBox.Refresh '16Mar07 TH Added intermittent unreplicatable fault where listbox count is not returning all lines
                            '           Pitched the refresh in to see if this might be useful.

   If LstBoxFrm.lblTitle = "" Then
         LstBoxFrm.lblHead.Top = 120
      Else
         LstBoxFrm.lblHead.Top = LstBoxFrm.lblTitle.Height
      End If

   If LstBoxFrm.lblHead = "" Then
         LstBoxFrm.LstBox.Top = LstBoxFrm.lblHead.Top
         LstBoxFrm.LstBox.Height = LstBoxFrm.ScaleHeight - LstBoxFrm.lblHead.Top - 600
      Else
         LstBoxFrm.LstBox.Top = LstBoxFrm.lblHead.Top + LstBoxFrm.lblHead.Height
         'LstBoxFrm.LstBox.Height = LstBoxFrm.ScaleHeight - LstBoxFrm.lblHead.Top - LstBoxFrm.lblTitle.Height - 600  '12Jul98 CKJ corrected
         LstBoxFrm.LstBox.Height = LstBoxFrm.ScaleHeight - LstBoxFrm.lblTitle.Top - LstBoxFrm.lblTitle.Height - 600  '   "

      End If

   If LstBoxFrm.LstBox.ListCount > 0 And LstBoxFrm.LstBox.ListIndex = -1 Then LstBoxFrm.LstBox.ListIndex = 0

   'set width here
   '15Jun97 KR  If no title then set maxwidth according to length of header.
   '15Oct97 CKJ Improved this mod - since "WWW" is shorter than "...." but takes more space
   '            in a proportional font
   'If Len(LstBoxFrm.lblTitle) > Len(LstBoxFrm.lblHead) Then
   '      maxwidth = TxtWidth(LstBoxFrm.lblTitle, (LstBoxFrm.lblTitle))
   '   Else
   '      maxwidth = TxtWidth(LstBoxFrm.lblHead, (LstBoxFrm.lblHead))
   '   End If
   'tmp$ = LstBoxFrm.lblHead
   'plingparse tmp$, TB
   'X = TxtWidth(LstBoxFrm.lblHead, (tmp$))
   'If X > maxwidth Then maxwidth = X
   
   maxwidth = txtwidth(LstBoxFrm.lblTitle, (LstBoxFrm.lblTitle))
   maxwidth = GreaterOf(maxwidth, txtwidth(LstBoxFrm.lblHead, (LstBoxFrm.lblHead)))
   For i = 0 To LstBoxFrm.LstBox.ListCount - 1
      maxwidth = GreaterOf(maxwidth, txtwidth(LstBoxFrm.LstBox, (LstBoxFrm.LstBox.List(i))))
   Next
   'maxwidth = maxwidth + 240   'allow for width of scroll bar
   'maxwidth = maxwidth + 240   'bit of a white border at the right within the list box
   'maxwidth = maxwidth + 240   'allow 120 of grey either side of the list box
   maxwidth = maxwidth + 720    '= sum of the above
   If maxwidth > LstBoxFrm.LstBox.Width Then
         If maxwidth > Screen.Width Then maxwidth = Screen.Width
         LstBoxFrm.LstBox.Width = maxwidth - 240
         LstBoxFrm.Width = maxwidth + 120
      End If
   
   X = TxtHeight(LstBoxFrm.LstBox)
   If LstBoxFrm.LstBox.ListCount * X < LstBoxFrm.LstBox.Height + X Then
         LstBoxFrm.LstBox.Height = LstBoxFrm.LstBox.ListCount * X + X
         LstBoxFrm.CmdOk.Top = LstBoxFrm.LstBox.Top + LstBoxFrm.LstBox.Height + 120
         LstBoxFrm.cmdCancel.Top = LstBoxFrm.CmdOk.Top
         On Error Resume Next    '12Jul98 CKJ needed in case a hidden, maximised form is reshown
         LstBoxFrm.Height = LstBoxFrm.CmdOk.Top + LstBoxFrm.CmdOk.Height + 540
         On Error GoTo 0         '12Jul98 CKJ
      End If

   'HorizCentreForm LstBoxFrm    '18Jul00 CKJ
   CentreForm LstBoxFrm          '   "
   LstBoxFrm.CmdOk.Tag = ""    'used in Activate/Resize events
      
   If LstBoxFrm.lblHead <> "" Then
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
         LstBoxFrm.LstHdr.Top = LstBoxFrm.lblHead.Top - 15
         LstBoxFrm.LstHdr.Width = LstBoxFrm.LstBox.Width
         LstBoxFrm.LstBox.Height = LstBoxFrm.LstBox.Height - LstBoxFrm.LstHdr.Height '12Jul98 CKJ
      End If
   LstBoxFrm.HelpContextID = k.helpnum
   gTimedOut = False    '7Mar97 CKJ Added
   Screen.MousePointer = STDCURSOR

   LstBoxFrm.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   
   LstBoxFrm.CmdOk.Tag = ""
   LstBoxFrm.SetKeyUpCallBackProc 0 ' XN 27May11 F087364
   k.norefresh = False         '12Sep96
   
End Sub
Sub LstBoxShow(Optional strExtraButton As String = "")
'Present a list box to the user, headings automatically sized as needed.
'Usage:
'   LstBoxFrm.Caption = "Caption displayed in the top bar"
'   LstBoxFrm.lblTitle = cr$ & "Main heading, optionally with CR's, and over several lines" & cr$
'   LstBoxFrm.lblHead  = "Optional secondary heading, for column names above the list box"
'   For x = 1 to n
'      LstBoxFrm.LstBox.AddItem " Add items here ..."
'   Next
'   LstBoxShow         'use this to size & show - do not call Show method directly
'   LineChosen = LstBoxFrm.LstBox.ListIndex + 1
'   Unload LstBoxFrm   'or use LstBoxFrm.LstBox.RemoveItem 0 until empty
' Note that the Caption, lblTitle and lblHead are all optional
'
'12Aug96 CKJ Changed font from Terminal to MS Linedraw
'13Aug96 CKJ Added timeout
' 2Oct96 CKJ Changed font back again, since MS Linedraw is not standard on W95 & won't
'            work at all on Chinese W95
'            Changed the maininfo label at the top to be lblTitle, to avoid confusion
'            with lblHead which is now used for the column headings.
'            Added automatic tab stops. To use simply set lblHead to the column headings
'            required, with tabs between each column and enough spaces in each column
'            to indicate the size wanted. Note that TB is preset and is global.  e.g.
'            LstBoxFrm.lblHead = "Description         " & TB & "Quantity    " & TB & "Cost "
'            will set up three columns of widths 20, 12 and 5 chars respectively.
' 2Nov96 CKJ Added k.helpnum
' 6Nov96 CKJ added width of scrollbar
'19Nov96 CKJ Supports use of popup menu on right click.
'            Fill menu with calls to PopMenu, and check on completion of
'            LstBoxShow for menu result in LstBoxFrm.LstBox.Tag. The line
'            highlighted at the tim ei sreturned in the normal way too, so
'            failure to check for right click & menu selection will resemble
'            a normal double click.
'29Apr97 CKJ Added mousepointer
'15Jun97 KR  If title < header then set maxwidth according to length of header.
'15Oct97 CKJ Corrected above mod
'15May98 CKJ increased max TabStops from 5 to 25
'12Jul98 CKJ corrected amount of blank space below box
'18Jul00 CKJ Height of list box at design time increased to full height of 768 pixels
'            Now has to be vertically centred
'11Jul11 TH  Merged CKJ mods below and
'01Dec10 CKJ Revised to correct fault. Reshowing without unload could shrink listbox by
'            height of header. Now takes account of taskbar position & size, and gives
'            an extra line at end of listbox if there is enough room.
'27May11 XN  F087364 Cleared SetKeyUpCallBackProc after form is displayed
'04Feb16 TH  Added option param to add extra button (TFS 138641)

Dim maxwidth As Long, maxheight As Long, i As Integer, X As Integer
Dim ScreenLeft As Long, ScreenTop As Long, ScreenRight As Long, ScreenBottom As Long
Dim ScreenHeightTwips As Long, ScreenWidthTwips As Long

   ReDim TabStops(25) As Long

   With LstBoxFrm
      'set to not min, not max
      .WindowState = 0   '!!** Sometines ignored for some reason!
      Screen.MousePointer = HOURGLASS
      
      .LstBox.Refresh '16Mar07 TH Added intermittent unreplicatable fault where listbox count is not returning all lines
                               '           Pitched the refresh in to see if this might be useful.
   
      If .lblTitle = "" Then
            .LstHdr.Top = 120
         Else
            .LstHdr.Top = .lblTitle.Height
         End If
   
      If .lblHead = "" Then
            .LstHdr.Visible = False
            .LstBox.Top = .LstHdr.Top
         Else
            .LstBox.Top = .LstHdr.Top + .LstHdr.Height
            
            i = 0  'number of tabstops found
            X = 0  'position in string
            Do
               X = InStr(X + 1, .lblHead, TB)
               If X Then
                     i = i + 1
                     TabStops(i) = X * 4
                  End If
            Loop While X > 0
            ListBoxTextBoxSetTabs .LstHdr, (i), TabStops()     'clear old & set new tabstops
            ListBoxTextBoxSetTabs .LstBox, (i), TabStops()     '(just clears if none found)
      
            .LstHdr.Clear
            .LstHdr.AddItem .lblHead
            .LstHdr.Visible = True
         End If
   
      If .LstBox.ListCount > 0 And .LstBox.ListIndex = -1 Then .LstBox.ListIndex = 0
      
      GetScreenWorkingArea ScreenLeft, ScreenTop, ScreenRight, ScreenBottom
      ScreenHeightTwips = ScreenBottom - ScreenTop
      ScreenWidthTwips = ScreenRight - ScreenLeft
      
      'Find width of the form & both list boxes. Only increase width from design time size.
      maxwidth = txtwidth(.lblTitle, (.lblTitle.Caption))
      maxwidth = GreaterOf(maxwidth, txtwidth(.LstHdr, (.LstHdr.List(0))))
      For i = 0 To .LstBox.ListCount - 1
         maxwidth = GreaterOf(maxwidth, txtwidth(.LstBox, (.LstBox.List(i))))
      Next
      maxwidth = maxwidth + 600    '240 (scroll bar) + 120 (white border next to scroll bar) + 240 (grey either side of the list box)
      maxwidth = maxwidth + .Width - .ScaleWidth   'add width of form borders
      maxwidth = GreaterOf(maxwidth, 6720)         'keep at least the design-time width (ensures buttons are visible at modal show)
      
      If maxwidth > ScreenWidthTwips Then maxwidth = ScreenWidthTwips
            
      'Find height of the form & main list box.
      'Display as many lines as possible, up to screen height.
      'Try to show one extra blank line at end of list.
      maxheight = (.LstBox.ListCount + 1) * TxtHeight(.LstBox) + 30  'generally 120 twips per row, plus extra 30 for top & bottom borders
      maxheight = maxheight + .LstBox.Top                            'top is already set by the title and header position
      maxheight = maxheight + .CmdOk.Height + 240                    '120 + [ OK ] + 120
      maxheight = maxheight + .Height - .ScaleHeight                 'allow for title bar and bottom border of window
      If maxheight > ScreenHeightTwips Then maxheight = ScreenHeightTwips
         
      '26Jan16 TH Added
      If Trim$(strExtraButton) <> "" Then
         .cmdExtra.Enabled = True
         .cmdExtra.Visible = True
         .cmdExtra.Caption = strExtraButton
      Else
         .cmdExtra.Enabled = False
         .cmdExtra.Visible = False
      End If
      
      On Error Resume Next    'set position & size of the form & moveable controls in the resize event
      .Move (ScreenRight - maxwidth + ScreenLeft) \ 2, (ScreenBottom - maxheight + ScreenTop) \ 2, maxwidth, maxheight
      On Error GoTo 0
         
      .CmdOk.Tag = ""    'used in events
      .HelpContextID = k.helpnum
      
      
   
      gTimedOut = False    '7Mar97 CKJ Added
      Screen.MousePointer = STDCURSOR
   End With
   
   

   LstBoxFrm.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   
   LstBoxFrm.CmdOk.Tag = ""
   LstBoxFrm.SetKeyUpCallBackProc 0 ' XN 27May11 F087364
   k.norefresh = False         '12Sep96
   
End Sub

Function MessageBox(ByVal text$, ByVal buttons As Long, ByVal title$) As Integer
'-------------------------------------------------------------------------------
'Drop-in replacement for MsgBox
'Features:
'  * Self sizing, up to full screen width/height
'  * Column aware; tabs in first line determine tab settings (max 100)
'  * Scroll bars enabled automatically
'  * Navigate with cursor keys, PgUp/PgDn, Home/End and Ctrl+cursor keys
'  * Up to 32K of text displayed
'  * Menu with Edit/Copy and Help/About/Printscreen options
'  * Highlight any contiguous block then copy with right click
'  * Sizeable border
'  * Timeout enabled
'  * Icons extracted from Windows, consistent with system messages
'  * Button text is language aware (except abort/retry/ignore)
'  * Caption width affects width of form ('MsgBox trucates mess...')
'  * Multiple line messages can be separated by CR, LF or CRLF (not LFCR)
'  * Title defaults to 'ASCribe' if non given
'  * Recursive; allows MessageBox to call MessageBox again
'
' 7Oct97 CKJ increased tab arrays and made height/width long int
' 9Oct97 CKJ support for icons added, renamed to MessageBox from Message and
'            params switched to match MsgBox. Returns same codes as MsgBox.
'12Oct97 CKJ Recursion added. Debugged & ready for alpha test
'15Oct97 CKJ Corrected WidthReqd when no scroll bars and no icon are shown
'16Feb98 CKJ Added safety margin of 240, as tabs are not calculated correctly
'            Really need to use GetTabbedTExtExtent API instead
'            Also enabled the fifth built in Icon, as attribute 8
'            There is no MB_... for it so I've named it ASC_ICONSAMPLE
'            Added facility for hidden first line to set tab stops;
'             terminate the first line with a nul, chr$(0), instead of cr or crlf
'02Oct98 CKJ Retrieve font size from terminal.ini
'14Oct98 CKJ Widen box if too narrow
'09May05 uses longs
'04Oct10 XN  F0023149 Windows 7 has larger boarders for windows forms so increased height of from by 10
'
'set Buttons% =
'MB_OK                0  [ OK  ]
'MB_OKCANCEL          1  [ OK  ]           [Cancel]
'MB_ABORTRETRYIGNORE  2  [Abort]  [Retry]  [Ignore]
'MB_YESNOCANCEL       3  [ Yes ]  [ No  ]  [Cancel]
'MB_YESNO             4  [ Yes ]  [ No  ]
'MB_RETRYCANCEL       5  [Retry]           [Cancel]
'
'ASC_ICONSAMPLE       8  box icon
'MB_ICONSTOP         16  X
'MB_ICONQUESTION     32  ?
'MB_ICONEXCLAMATION  48  !
'MB_ICONINFORMATION  64  i
'
'MB_DEFBUTTON1        0  First button is default
'MB_DEFBUTTON2      256  Second button is default
'MB_DEFBUTTON3      512  Third button is default
'
'Note: the system modal option (4096) is not supported, as NT does not allow this with MsgBox
'
'Return value
'IDOK     1  OK button selected
'IDCANCEL 2  Cancel button selected
'IDABORT  3  Abort button selected
'IDRETRY  4  Retry button selected
'IDIGNORE 5  Ignore button selected
'IDYES    6  Yes button selected
'IDNO     7  No button selected
'-------------------------------------------------------------------------------

Dim lin$, posn As Long, i%, X%, TotLines%, lines As Long
Dim HeightReqd As Long, WidthReqd As Long, Loffset As Long
Dim objhandle As Long
Dim IDnum As Long, numbtns%, count As Long, HideLine%
Dim objMsgBox As frmMsgBox                             'declare local object

   ReDim TabStops(100) As Long
   
   Set objMsgBox = New frmMsgBox                       'create new instance
   Load objMsgBox                                      'and load it

   If Len(title$) = 0 Then title$ = "EMIS Health"          'set default title
   objMsgBox.Caption = title$

   Select Case (buttons And 7)                         'set the buttons here
      Case 0                                           'OK
         numbtns = 1
         objMsgBox.cmd(1).Tag = "0"                    'OK with no underscore
      Case 1                                           'OK    Cancel
         numbtns = 2
         objMsgBox.cmd(1).Tag = "1"                    'OK with an underscore
         objMsgBox.cmd(2).Tag = "2"
      Case 2                                           'Abort Retry  Ignore
         numbtns = 3
         objMsgBox.cmd(1).Tag = "3"
         objMsgBox.cmd(2).Tag = "4"
         objMsgBox.cmd(3).Tag = "5"
      Case 3                                           'Yes   No     Cancel
         numbtns = 3
         objMsgBox.cmd(1).Tag = "6"
         objMsgBox.cmd(2).Tag = "7"
         objMsgBox.cmd(3).Tag = "2"
      Case 4                                           'Yes   No
         numbtns = 2
         objMsgBox.cmd(1).Tag = "6"
         objMsgBox.cmd(2).Tag = "7"
      Case 5                                           'Retry Cancel
         numbtns = 2
         objMsgBox.cmd(1).Tag = "4"
         objMsgBox.cmd(2).Tag = "2"
      End Select

   objMsgBox.Picture2.Width = objMsgBox.cmd(numbtns).Left + objMsgBox.cmd(numbtns).Width
   For count = 1 To numbtns
      objMsgBox.cmd(count).Visible = True
      objMsgBox.cmd(count).Enabled = True
      Select Case objMsgBox.cmd(count).Tag
         Case 0: objMsgBox.cmd(count).Caption = T1("OK", "&OK")
         ''Case 1: objMsgBox.cmd(count).Caption = "&" & T1("OK", "&OK")
         Case 1: objMsgBox.cmd(count).Caption = "&" & T1("OK", "OK")             '11Feb05 TH Ensure default is now correct
         ''Case 2: objMsgBox.cmd(count).Caption = "&" & T1("Cancel", "&Cancel")
         Case 2: objMsgBox.cmd(count).Caption = "&" & T1("Cancel", "Cancel")     '    "
         Case 3: objMsgBox.cmd(count).Caption = "&Abort"
         Case 4: objMsgBox.cmd(count).Caption = "&Retry"
         Case 5: objMsgBox.cmd(count).Caption = "&Ignore"
         Case 6: objMsgBox.cmd(count).Caption = Trim$(getYN(6)) 'already has the &
         Case 7: objMsgBox.cmd(count).Caption = Trim$(getYN(7)) '   "
         End Select
   Next

   If numbtns > 1 And (buttons And 256) Then objMsgBox.cmd(2).default = True
   If numbtns = 3 And (buttons And 512) Then objMsgBox.cmd(3).default = True
   objMsgBox.cmd(numbtns).Cancel = True
   
   '                           idnum& = OIC_SAMPLE     ' box   ...but what's it for?
   If (buttons And 8) = 8 Then IDnum& = OIC_SAMPLE     ' X     ASC_ICONSAMPLE     =  8
   If (buttons And 16) = 16 Then IDnum& = OIC_HAND     ' X     MB_ICONSTOP        = 16
   If (buttons And 32) = 32 Then IDnum& = OIC_QUES     ' ?     MB_ICONQUESTION    = 32
   If (buttons And 48) = 48 Then IDnum& = OIC_BANG     ' !     MB_ICONEXCLAMATION = 48
   If (buttons And 64) = 64 Then IDnum& = OIC_NOTE     ' i     MB_ICONINFORMATION = 64
   If IDnum& Then
         objhandle = LoadIconBynum(0, IDnum&)
         If DrawIcon(objMsgBox.Picture1.hdc, 0, 0, objhandle) Then objMsgBox.Picture1.Tag = "1"
      End If
   
   '16Feb98 CKJ First line sets tabs. If it ends in Chr$(0) instead of cr or crlf then
   ' do not display it.
   HideLine = (InStr(text, Nul) > 0)
   
   'Parse CR and LF;  ..CR..LF..CRLF..          all act as CRLF
   '                  ..CRCR..LFLF..CRLFCRLF..  all act as CRLFCRLF
   'Note: LFCR is not a valid separator
   replace text$, crlf, Chr$(0) & Chr$(1), 0                    'same size -> fast
   replace text$, lf, Chr$(0), 0                                'same size -> fast
   replace text$, cr, Chr$(0), 0                                'same size -> fast
   replace text$, Chr$(0) & Chr$(1), crlf, 0                    'same size -> fast
   replace text$, Chr$(0), crlf, 0                              '1->2, slow
   
   posn = InStr(text$, cr)                                      'look for first CR
   If posn Then lin$ = Left$(text$, posn - 1) Else lin$ = text$ 'if found just keep first line

   If Len(lin$) Then
         i = 0                                                  'number of tabstops found
         X = 0                                                  'position in string
         Do
            X = InStr(X + 1, lin$, TB)
            If X Then
                  i = i + 1
                  TabStops(i) = X * 4
               End If
         Loop While X > 0
         
         ListBoxTextBoxSetTabs objMsgBox.txtBox(0), (i), TabStops()     '(just clears if none found)
         ListBoxTextBoxSetTabs objMsgBox.txtBox(1), (i), TabStops()     '(just clears if none found)
      End If
          
   posn = 0                                                     'find total number of lines
   TotLines = 2                                                 'allow one extra at end, since
   Do                                                           'one CR separates two lines
      posn = InStr(posn + 1, text$, cr)
      If posn Then TotLines = TotLines + 1
   Loop While posn
   
   If HideLine Then TotLines = TotLines - 1                     '16Feb98 CKJ
   
   '02Oct98 CKJ Retrieve font size and font name from terminal.ini
   On Error Resume Next
   objMsgBox.txtBox(0).FontName = terminal$("MsgBoxFontName", "")
   objMsgBox.txtBox(1).FontName = objMsgBox.txtBox(0).FontName
   objMsgBox.txtBox(0).FontSize = Val(terminal$("MsgBoxFontSize", ""))
   objMsgBox.txtBox(1).FontSize = objMsgBox.txtBox(0).FontSize
   On Error GoTo 0
   
   objMsgBox.txtBox(0) = text$
   Loffset = Iff(IDnum&, objMsgBox.Picture1.Left + objMsgBox.Picture1.Width, 0)     'idnum<>0 if icon is shown
   WidthReqd = txtwidth(objMsgBox.txtBox(0), text$) + 120 + Loffset + 2 * 135       '120 is diff between scalewidth & width, 135 is the left & right border
   WidthReqd = WidthReqd + 240                                                      '16Feb98 CKJ Added safety margin, as tabs are not calculated correctly
   WidthReqd = GreaterOf(WidthReqd, objMsgBox.Picture2.Width + 420)                 'are buttons wider than text? 2x210 space on either side of buttons
   WidthReqd = GreaterOf(WidthReqd, txtwidth(objMsgBox.cmd(1), title$) + 1230)      'is title wider than text or buttons? 1230 needed for control/max/min/close
    HeightReqd = TotLines * TxtHeight(objMsgBox.txtBox(0)) + 1200 + 145 + 155           '1200=6510-5310 diff between scaleheight & height, 145 is the top border
   If IDnum& Then                                                                   'is icon on show?
        HeightReqd = GreaterOf(HeightReqd, objMsgBox.Picture2.Height + 1200 + 145 + 155) 'is icon taller than the text?
      End If
   
   If HideLine Then                                  '16Feb98 CKJ [firstlineCRLF]keepremainder
         text$ = Mid$(text$, InStr(text$, cr) + 2)
         objMsgBox.txtBox(0) = text$
      End If

   objMsgBox.Move objMsgBox.Left, objMsgBox.Top, WidthReqd, HeightReqd              'set size -> generates resize event
   'may not have made the box big enough so lets see if it worked...
   
   Do                                                  'never mind the width ... feel the height
      lines = SendMessage(objMsgBox.txtBox(0).Hwnd, EM_GETLINECOUNT, 0&, 0&)   'count lines
      If lines = TotLines - 1 Then Exit Do                                    'too many = wrapped
      WidthReqd = WidthReqd + 120                                             'widen form
      objMsgBox.Width = WidthReqd                                             'set it
   Loop While objMsgBox.Width = WidthReqd                                     'not max width yet
   
   If objMsgBox.Width < WidthReqd Or objMsgBox.Height < HeightReqd Then
         objMsgBox.txtBox(0).text = ""
         objMsgBox.txtBox(0).Visible = False
         objMsgBox.txtBox(0).Enabled = False
         objMsgBox.txtBox(1).text = text$
         objMsgBox.txtBox(1).Visible = True
         objMsgBox.txtBox(1).Enabled = True
      End If

   CentreForm objMsgBox
   objMsgBox.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form

   MessageBox = GreaterOf(1, Val(objMsgBox.Tag))       'set return value (minimum of 1)

   Unload objMsgBox                                    'unload local object
   Set objMsgBox = Nothing                             'give memory back to pool

End Function

Sub popmenu(Action%, Caption$, Enabled%, Checked%)
'Prepare a popup (floating) menu for display with PopMenuShow
'Action = 0  Unload PopMnu form, all other parameters ignored
'                 eg   PopMenu 0, "", False, False
'         1  Additem:  PopMenu 1, Caption$, Enabled%, Checked%
'                 eg   PopMenu 1, "&Print Setup", True, False
'         2  Additems separated by [cr], (both Enabled% and Checked% ignored)
'            Maximum of 25 items can be added at one time
'                 eg   PopMenu 2, "Item One[cr]Item Two[cr]Item Three", 0, 0
'Note that several calls with Action = 1 or 2 can be made to add more items
'  to the menu, in sequence.
'Warning: separator bars cannot be used, and will cause an error if attempted
'  Instead, blank lines are permitted:  PopMenu 1, "", False, False
'
'Menu structure is as follows:
'  mnuTop           Never Shown
'  ---mnuItem(0)    Never Shown, set to not visible before form is shown
'  ---mnuItem(1)    First displayed item
'  ---mnuItem(2)    Second displayed item
'Total is total of all menu items, ie two greater than number to be displayed

Dim i%, total%, tmp$, Numoflines%, dummy%
ReDim Menu$(25)

   For i = 0 To PopMnu.Controls.count - 1
      If TypeOf PopMnu.Controls(i) Is Menu Then total = total + 1
   Next
   
   Select Case Action
      Case 0 'Unload
         On Error Resume Next
         For i = total To 3 Step -1            'leave heading and index 0
            Unload PopMnu.mnuItem(i - 1)       '0 to n-1
         Next
         Unload PopMnu
         On Error GoTo 0
      
      Case 1 'Add item
         Load PopMnu.mnuItem(total - 1)
         PopMnu.mnuItem(total - 1).Caption = Caption$
         PopMnu.mnuItem(total - 1).Enabled = Enabled
         PopMnu.mnuItem(total - 1).Checked = Checked
         
      Case 2 'Add items
         tmp$ = Caption$
         ParseCtrlChars dispdata$ & "\printer.ini", "Screen", tmp$, dummy
         deflines tmp$, Menu$(), cr, 1, Numoflines
         For i = 1 To Numoflines
            popmenu 1, Menu$(i), True, False   'recursion
         Next
      
      End Select

End Sub

Sub PopMenuShow(ans As String, ByVal X As Long, ByVal Y As Long)
'Partner to PopMenu
'Displays pre-prepared menu.
'Menu line number chosen is returned in ans$ as "1", "2" etc
' or ans$ = "" if escaped, or return pressed on a greyed-out item
'Value of ans$ on entry is ignored; first line is always highlighted
'09May05 CKJ Corrected positioning of menu and made params long

   On Error GoTo PopMenuShow_Err
   PopMnu.mnuItem(0).Visible = False   'illegal if no other items in menu enabled
   If X <> 0 Or Y <> 0 Then
         'PopMnu.PopupMenu PopMnu.mnuTop, 0, X, Y   'show menu at given position
         PopMnu.Left = X
         PopMnu.Top = Y
         PopMnu.PopupMenu PopMnu.mnuTop, 0, 0, 0   'show menu at given position
      Else
         PopMnu.PopupMenu PopMnu.mnuTop            'show menu at cursor position
      End If
   PopMnu.mnuItem(0).Visible = True    'restore this item, so others can be removed
   ans$ = PopMnu.Tag                   ' "", "1", "2" etc
   
PopMenuShow_Exit:
   On Error GoTo 0
Exit Sub

PopMenuShow_Err:
   ans$ = ""
Resume PopMenuShow_Exit

End Sub

Sub PrintScreen()
'13May97 CKJ Written. Dumps a copy of the whole screen to the default printer

   On Error GoTo PrintScreen_Err
   CaptureScreen
   frmBlank.PrintForm
   Printer.EndDoc

PrintScreen_Exit:
   Unload frmBlank
   On Error GoTo 0
Exit Sub

PrintScreen_Err:
   popmessagecr "EMIS Health", "Cannot print screen to the default printer"
Resume PrintScreen_Exit

End Sub

Sub ScreenRefresh()
Dim i As Integer

   On Error Resume Next
   For i = 0 To Forms.count - 1
      Forms(i).Refresh
   Next
   On Error GoTo 0

End Sub

Sub SetNumEditorLines(Number%)
'24Feb99 SF added to set the number of editable lines on the editors form

   numEditorLines% = Number%

End Sub

Sub SetTextBoxReadOnly(ctrl As Control, TrueFalse%)
'17Sep96 CKJ Written. Prevent user from editing text box
'            Set True for readonly, False for read/write
'            Only works for ordinary text boxes
Dim dummy&

   If TypeOf ctrl Is TextBox Then
         dummy = SendMessage(ctrl.Hwnd, EM_SETREADONLY, (TrueFalse <> 0), 0&)
      End If

End Sub

Sub ShowTip(msg As String, frm As Form)
'*********************************************************************************
' Code Description:
' --------------------
' This module is to be used with tooltips.frm.
' Written by Van Smith.
'
'Instructions:
'-------------
' Using tool tips is easy: just enter
'       ShowTip "Message", Me
' in the MouseMove procedure of the control.  If the
' mouse remains in place for g_TIP_PAUSE_TIME seconds, a tool
' tip will appear displaying the passed string.  The tool
' tip will remain visible for g_TIP_DISPLAY_TIME seconds.
'
'Modification log:
'-----------------
'  Date     Who  Ver  Modification description:
' --------  ---  ---  ------------------------------------------------------------
' 05/28/96  AVS  1.0  Created.
' 05/30/96  AVS  1.1  Added ShowWindow, and global constants for time delays.
' 06/05/96  AVS  1.2  Added WindowFromPoint and suppport for second timer.
' 09Dec96   CKJ       Received ToolTips from Van Smith, converted to VB3 from VB4/16
'                     Replaced the two VB timers with MHtimers, and added SleepTip
'*********************************************************************************

Dim MousePosition As POINTAPI          'v1.2
Dim CurrentWindow As Long
   
   g_hwndFormCallingTip = frm.Hwnd                       'Proceed if program has input focus
   If GetActiveWindow() = g_hwndFormCallingTip Then
         Call GetCursorPos(MousePosition)                                  'Get pointer position
         CurrentWindow = WindowFromPoint(MousePosition.Y, MousePosition.X) 'Get current window (control) the mouse is over

         ' If frmToolTip is visible and we are still over the same window (control) then
         ' keep tool tip visible by resetting timer:
         If (frmToolTip.Visible) And (CurrentWindow = g_LastWindow) And (msg = gMsg) Then  'v1.2
               frmToolTip.tmrToolTip.Enabled = False
               frmToolTip.tmrToolTip.Enabled = True
               frmToolTip.tmrToolTip.interval = g_TIP_DISPLAY_TIME
               g_Old_MousePosition.X = MousePosition.X   'so tool tip won't reappear 'v1.2
               g_Old_MousePosition.Y = MousePosition.Y   'after mouse stops          'v1.2

            ElseIf (msg = gMsg) And (CurrentWindow <> g_LastWindow) Then 'A drag happened.
               frmToolTip.Visible = False                'put tooltips to sleep      'v1.2
               frmToolTip.tmrToolTip.interval = 0                                    'v1.2
               frmToolTip.tmrToolTip2.Enabled = False                                'v1.2

            ElseIf ((MousePosition.X <> g_Old_MousePosition.X) Or (MousePosition.Y <> g_Old_MousePosition.Y)) Then 'Mouse has been moved:
               'Tool tip is invisible and MouseMove has been generated while left on control
               'or mouse has been moved to another control. In either case we should start
               'tooltip Timer. This condition should be left in because sometimes MouseMove
               'is triggered when the mouse has not moved -- we do not want to reset timer in that case:
               g_Old_MousePosition.X = MousePosition.X
               g_Old_MousePosition.Y = MousePosition.Y
               frmToolTip.Visible = False
               frmToolTip.tmrToolTip.Enabled = False
               frmToolTip.tmrToolTip.Enabled = True
               frmToolTip.tmrToolTip2.Enabled = True                                 'v1.2
               frmToolTip.tmrToolTip.interval = g_TIP_PAUSE_TIME
               g_LastWindow = CurrentWindow                                          'v1.2
               gMsg = msg                                                            'v1.2
            Else
               'Somehow MouseMove was triggered without moving the mouse
               'Don't do anything.
            End If

      Else     'Program does not have input focus, so put tool tip to sleep
         SleepTip
         'frmToolTip.Visible = False
         'frmToolTip.tmrToolTip.Interval = 0
         'frmToolTip.tmrToolTip2.Enabled = False                                      'v1.2
      End If

End Sub

Sub SleepTip()
' 9Dec96 CKJ Put Van Smith's ToolTip to sleep - saves multiple repetitions

   frmToolTip.Visible = False
   frmToolTip.tmrToolTip.interval = 0
   frmToolTip.tmrToolTip2.Enabled = False                                      'v1.2

End Sub

Sub TextBoxHiLight()
'Highlights existing text in a text box. Use in text box's GotFocus event

Dim txtBox As Control

   On Error Resume Next
   Set txtBox = Screen.ActiveForm.ActiveControl
   txtBox.SelStart = 0
   txtBox.SelLength = Len(txtBox.text)
   On Error GoTo 0

End Sub

Sub TextEdit(title$, body$, Code$, change%, FreeFormat%)
'12Mar95 CKJ Written
'  Title$ - top line of screen
'  Body$  - main body text, up to 32K max
'           individual lines are <cr><lf> separated
'  Code$  - Fixed message box at lower left of screen (optional)
'  Change - On entry: False for view only;  Returns false on exit
'                     True  allows editing; Returns true if altered
'20Jun95 CKJ Modified free format behaviour
'20Jul95 CKJ Minor mod in ruler display
'24Oct96 CKJ Uses form caption for title, not label

   Editor.Txt1.text = body$
   Editor.Txt1.Tag = body$
   Editor.lblCode.Caption = Code$
   'Editor.lblTitle.Caption = title$
   Editor.Caption = title$             '24Oct96 CKJ
   If change = 0 Then Editor.cmdExit.default = True    'view only
   If FreeFormat Then
         Editor.Tag = "L"
      Else
         Editor.Tag = ""
      End If
   gTimedOut = False    '7Mar97 CKJ Added

   Editor.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   body$ = Editor.Txt1.text
   change = Val(Editor.cmdExit.Tag)
   Unload Editor

End Sub

Function TimedOut() As Boolean
'13Aug96 CKJ Written
' 3Sep96 CKJ Timeout converted from millisecs to secs

   If TimeoutCount > 0 Then
         TimeoutCount = TimeoutCount - 1
         TimedOut = False
      Else
         frmTimeout.Tag = "X"
         frmTimeout.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
         If frmTimeout.Tag = "X" Then
               TimedOut = True
               gTimedOut = True  '7Mar97 CKJ Added
            Else
               TimedOut = False
               gTimedOut = False '7Mar97 CKJ Added
            End If
      End If
         
End Function

Sub TimeoutOff(TmrCtrl As Control)
'Turns timer off for form timeout

   If TypeOf TmrCtrl Is Timer Then
         TmrCtrl.Enabled = False
      End If

End Sub

Sub TimeoutOn(TmrCtrl As Control)
'Turns timer on for form timeout, resetting if already running
' 3Sep96 CKJ Timeout converted from millisecs to secs

   If TypeOf TmrCtrl Is Timer Then
         TimeoutCount = k.timedef \ 60
         If TimeoutCount = 0 Then TimeoutCount = StdTimeout \ 60
         If TimeoutCount = 0 Then TimeoutCount = 1
         TmrCtrl.interval = 60000 ' 60 secs
         TmrCtrl.Enabled = False
         TmrCtrl.Enabled = True
      End If

End Sub

Function TxtHeight(ctrl As Control) As Single
'14Mar96 CKJ Returns the height that text would be if it were in the control
'            If the control doesn't support font properties then default
'            values are used - typically current settings for frmMsgWin

Dim TxtW As Single, TxtH As Single

   TxtWidthHeight ctrl, "X", TxtW, TxtH
   TxtHeight = TxtH

End Function

Function txtwidth(ctrl As Control, txt$) As Single
'14Mar96 CKJ Returns the width that text would be if it were in the control
'            If the control doesn't support font properties then default
'            values are used - typically current settings for frmMsgWin
'12Aug96 CKJ Rewritten. Functionally identical but uses TxtWidthHeight

Dim TxtW As Single, TxtH As Single

   TxtWidthHeight ctrl, txt$, TxtW, TxtH
   txtwidth = TxtW

End Function

Sub TxtWidthHeight(ctrl As Control, txt$, TxtW As Single, TxtH As Single)
'14Mar96 CKJ Returns the width that text would be if it were in the control
'            If the control doesn't support font properties then default
'            values are used - typically current settings for frmMsgWin
'12Aug96 CKJ Modified to accommodate width & height in one procedure
'            See also functions TxtWidth() and TxtHeight()
'12Oct97 CKJ Trapped Overflow errors on sizing long strings
'16Feb98 CKJ Two problems - frmMsgWin does not behave same as some controls, esp when
'            tabs are embedded. Therefore use given control if possible.
'            Note that TextWidth does not work with Text boxes; need Get TabbedTextExtent API.
'            Secondly, as written it creates an instance of frmMsgWin which is not removed.
'            This must be unloaded before exiting.
'23Feb98 CKJ Removed the form unload/set nothing
'            The speed of showing a list box dropped dramatically, and in the environment
'            Out Of Memory errors occur almost immediately. Another solution is required.
'07Jun04 CKJ frmMsgWin no longer used. frmBlank used instead

Dim frmTarget As frmBlank

   On Error GoTo UseCtrlFailed           'control may not exist, or may not support TextHeight
   TxtH = ctrl.TextHeight(txt$)
   On Error GoTo TxtWidthHeight_Err      'control exists, but may get overflow error
   TxtW = ctrl.TextWidth(txt$)           '368640 maximum
   On Error GoTo 0
Exit Sub

UseNewForm:
   On Error Resume Next
   Set frmTarget = New frmBlank
   Load frmTarget
   frmTarget.FontName = ctrl.FontName
   frmTarget.FontSize = ctrl.FontSize
   frmTarget.FontBold = ctrl.FontBold
   frmTarget.FontUnderline = ctrl.FontUnderline
   frmTarget.FontStrikethru = ctrl.FontStrikethru
   frmTarget.FontItalic = ctrl.FontItalic

   On Error GoTo TxtWidthHeight_Err
   TxtW = frmTarget.TextWidth(txt$)      '368640 maximum
   On Error GoTo 0
   TxtH = frmTarget.TextHeight(txt$)
   
   Unload frmTarget
   Set frmTarget = Nothing

Exit Sub

UseCtrlFailed:                           '16Feb98 CKJ Now try with frmmsgwin
Resume UseNewForm

TxtWidthHeight_Err:
   If Err = 6 Then TxtW = 368640         'overflow
Resume Next

End Sub

Sub FillSetupOptions(iAction As Integer, sDescription As String, sInfo As String, iSetType As Integer, sSetting As String)

'Store settings on the heap for speed and ease of use.
'Call repeadtedly until all settings are stored, then show the form using frmSetupOptions.Show 1
'
'iAction:  1  = Add item
'          0  = clear all items
'          <0 = Overwrite item -iAction with new values. Blank or zero values do not overwrite existing ones.

'sDescription: Text description which appears in the top list box
'sInfo: Further text describing the option which appears in the middle box for the selected option
'iSetType: The type of settings allowed for this option:
'        1: On / Off
'        2: Numerical Value
'        3: Free Text
'sSetting: Default setting for this option.
'----------------------------------------------------------------------
'02Mar00 AE  Written

Static iPntr As Integer

   Select Case iAction
      Case 0
      'Clear heap
         Heap 2, iSetupHeap, "", "", 0
         iPntr = 0

      Case 1
      'Add Item
         iPntr = iPntr + 1
         If iSetupHeap = 0 Then Heap 1, iSetupHeap, "frmSetupOptions Heap", "", 0
         Heap 10, iSetupHeap, "Description" & Format$(iPntr), sDescription, 0
         Heap 10, iSetupHeap, "Info" & Format$(iPntr), sInfo, 0
         Heap 10, iSetupHeap, "SetType" & Format$(iPntr), Format$(iSetType), 0
         Heap 10, iSetupHeap, "Setting" & Format$(iPntr), sSetting, 0

      Case Is < 0
         If iSetupHeap = 0 Then Exit Sub
         Heap 10, iSetupHeap, "Description" & Format$(Abs(iAction)), sDescription, 0
         Heap 10, iSetupHeap, "Info" & Format$(Abs(iAction)), sInfo, 0
         Heap 10, iSetupHeap, "SetType" & Format$(Abs(iAction)), Format$(iSetType), 0
         Heap 10, iSetupHeap, "Setting" & Format$(Abs(iAction)), sSetting, 0

      End Select

End Sub

Sub SetChrome(frm As Form)

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
      If TypeOf ctrl Is StatusBar Then
         SendMessage ctrl.Hwnd, SB_SETBKCOLOR, 0, ByVal Colour_Background
      End If
      
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


Sub GetScreenWorkingArea(ScreenLeft As Long, ScreenTop As Long, ScreenRight As Long, ScreenBottom As Long)
'08oct08 CKJ Returns the working area of the screen in twips, excluding the taskbar

Dim ScreenInfo As RECT

   If SystemParametersInfo(SPI_GETWORKAREA, 0, ScreenInfo, 0) <> 0 Then
      ScreenLeft = ScreenInfo.Left * Screen.TwipsPerPixelX
      ScreenTop = ScreenInfo.Top * Screen.TwipsPerPixelY
      ScreenRight = ScreenInfo.Right * Screen.TwipsPerPixelX
      ScreenBottom = ScreenInfo.Bottom * Screen.TwipsPerPixelY
    Else      'use default values
      ScreenLeft = 0
      ScreenTop = 0
      ScreenRight = Screen.Width
      ScreenBottom = Screen.Height
    End If

End Sub


