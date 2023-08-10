Attribute VB_Name = "QUESCROL"
'------------------------------------------------------------------------------------------------
'                                         Quescrol.bas
'
' 8Aug96 CKJ Supporting code to drive Quescrol.frm - the form must not be called directly.
'            Three procedures are provided:
'               QuesMakeCtrl   creates new instances of labels/entry boxes/buttons etc
'               QuesSetCtrl    sets these controls ready for use
'               QuesShow       sets final parameters & shows the form
'
'The following is an example of the callback procedure which is required to use this form.
'
'Sub Ques_Callback (Index)
'
'   Select Case QuesCallbackMode  'shared within the module
'      Case 1                     'first use of QuesScrl form
'         Select Case Index
'            Case 1
'            Case 2
'            End Select
'
'      Case 2                     'second use of QuesScrl form
'         Select Case Index
'            Case 1
'            Case 2
'            End Select
'      End Select
'
'End Sub
'
'20Oct96 CKJ added trim() to yes/no questions
'28Oct96 CKJ/EAC Added Callback on OK button - Index is set to 0, and Tag ="-1"
'            If the form cannot be accepted at this time, present message to
'            user, then set Tag="" and do a setfocus to the appropriate control.
'28Feb97 CKJ Added masktypes 3, 4, 5, 8, 9, -1
'            Procedures for setting & retrieving data also added, needed if the data
'            is not available at the time that the controls are created:
'            QuesSetText Index%, Text$   insert text$ into control
'            QuesGetText(Index%)         retrieve text$ from control
'            QuesTypeOfCtrl(Index)       returns type of control as integer 0-3
'12Apr97 CKJ Mask type 8: Mixed case allowed - set A for upper, a for mixed
'15Apr97 CKJ Corrected above mod
' 1May97 CKJ Added ConstructView - allows ini file definition of form
' 4May07 CKJ Extended functionality to command button and combo box
'            Use of .ini file to build a view is now preferred method of use.
'27Jun97 CKJ ConstructView: Corrected fault where info$ is repeated on next line(s)
'27Jun97 CKJ ConstructView: Added ForceState$ to allow the calling program to force particular
'            items to be editable or to be read only, irrespective of the ini file view.
'12Aug97 CKJ resize height to fit on 800x600 or 1024x768 screen
'16Dec97 CKJ QuesShow: Added DoSaferEvents to avoid timing issues
'14Aug98 CKJ QuesShow: Form is now always centred
'04Feb99 CFY QuesSetCtrl: Additional functionality to masktype 8:
'              X  any alphanumeric character
'              B  any alphabetic character upper or lower case plus space
'20Apr99 CKJ QuesShow: Widened text fields by one character
'27May02 CKJ QuesSetCtrl: Corrected mask handling: negatives are types 4 & 5
'24may04 CKJ QuesMakeCtrl: aligned labels
'15Jun05 CKJ Enabled basic use without masked input for V9.3
'16Jun05 CKJ All mask types enabled, but type 8 is not positional. It only acts as a list of valid chars
'            Insert by Ctrl-V and Shift-Ins are trapped, but not when using right click or drag/drop
'08oct08 CKJ QuesShow: accounts for taskbar when centering
'------------------------------------------------------------------------------------------------

DefInt A-Z
Option Explicit

Global QuesCallbackMode%

Function QuesGetText(Index%) As String
Dim tmp$

   On Error Resume Next
   tmp$ = Ques.txtQ(Index).text
   tmp$ = Ques.cmdQ(Index).Caption
   tmp$ = Ques.cmbQ(Index).text
   On Error GoTo 0
   QuesGetText = tmp$

End Function

Sub QuesMakeCtrl(Index As Integer, CtrlType As Integer)
'This procedure creates a new instance of a control for use in QuesScrl
'  set Index to the line number required (starting at 1)
'  set CtrlType to one of 0-3 as follows
'          0  create two labels only
'          1  create two labels and a text box (masked input)
'          2  create two labels and a command button
'          3  create two labels and a combo box
'       1000  enable the Print Button
' The labels provide room for a description and expansion/units
' with lblDesc at the left margin and lblInfo to the right of the
' specified input control.
'
'For more information see QuesScrl.frm
'12Aug97 CKJ Added the Print button option, to use call
'            QuesMakeCtrl 0, 1000
'24may04 CKJ aligned labels


Dim ctrlht As Integer

   If Index = 0 Then
         If CtrlType = 1000 Then
               Ques.CmdPrint.Visible = True
               Ques.CmdPrint.Enabled = True
            End If
      Else
         ctrlht = Ques.txtQ(0).Height + 15                        '15Jun05 CKJ Added padding of 15
         
         Load Ques.lblDesc(Index)
         Ques.lblDesc(Index).Visible = True
         Ques.lblDesc(Index).Enabled = True
         Ques.lblDesc(Index).Height = ctrlht
         Ques.lblDesc(Index).Top = ctrlht * Index + 45            '24may04 CKJ added +45
      
         Load Ques.lblInfo(Index)
         Ques.lblInfo(Index).Visible = True
         Ques.lblInfo(Index).Enabled = True
         Ques.lblInfo(Index).Height = ctrlht
         Ques.lblInfo(Index).Width = 4000
         Ques.lblInfo(Index).Top = ctrlht * Index + 45            '24may04 CKJ added +45
            
         Select Case CtrlType
            Case 0                                                'No control
               'no action
            Case 1                                                'Text box
               Load Ques.txtQ(Index)
               Ques.txtQ(Index).Visible = True
               Ques.txtQ(Index).Enabled = True
               Ques.txtQ(Index).Top = ctrlht * Index
            Case 2                                                'Callback cmd button
               Load Ques.cmdQ(Index)
               Ques.cmdQ(Index).Visible = True
               Ques.cmdQ(Index).Enabled = True
               Ques.cmdQ(Index).Top = ctrlht * Index
               Ques.cmdQ(Index).Height = ctrlht
            Case 3                                                'List/combo box
               'Load Ques.lst1(Index)
               'Ques.lst1(Index).Visible = True
               'Ques.lst1(Index).Enabled = True
               'Ques.lst1(Index).Top = ctrlht * Index + 30
               'Ques.lst1(Index).Height = ctrlht
               Load Ques.cmbQ(Index)
               Ques.cmbQ(Index).Visible = True
               Ques.cmbQ(Index).Enabled = True
               Ques.cmbQ(Index).Top = ctrlht * Index
            End Select
      End If

End Sub

Sub QuesPrintView(title$, heading$)
'12Aug97 CKJ Written
'            Routine prints simple dump of all info to the printer based on current view
'            Title$ is optional, if missing then "ASCribe System Maintenance" is printed
'            Heading is optional, if missing then the form caption & CR is used,
'            if supplied and ends in '+' then heading$ & form caption & CR is used,
'            if supplied but doesn't end in '+' then heading$ is used as given, no CR appended.

Dim i%, txt$, Changed%, dummy%
                                       
   RTFinternalTransfer$ = "" ' LstBoxFrm.lblTitle & "[cr][ulineon][boldon]" & LstBoxFrm.lblHead & "[boldoff][ulineoff][cr][cr]"
   
   On Error Resume Next
   For i = 1 To Ques.F3D1.Tag
      RTFinternalTransfer$ = RTFinternalTransfer$ & Ques.lblDesc(i) & "[tab]...[BoldOn]   " & QuesGetText(i) & "[BoldOff][tab][tab]" & Ques.lblInfo(i) & "[cr]"
   Next
   On Error GoTo 0
   
   replace RTFinternalTransfer$, cr, "[cr]", 0
   replace RTFinternalTransfer$, TB, "[Tab]", 0
   RTFinternalTitle$ = Iff(Len(title$), title$, "System Maintenance") 'any better generic title?
   RTFinternalHeading$ = Ques.Caption & "[cr]"
   If Len(heading$) Then
      If Right$(heading$, 1) = "+" Then  'add heading$ to the form caption & CR
         RTFinternalHeading$ = Left$(heading$, Len(heading$) - 1) & RTFinternalHeading$
      Else                               'use heading$ alone (no added CR)
         RTFinternalHeading$ = heading$
      End If
   End If
   RTFinternalHeader$ = ""
   RTFinternalFooter$ = ""
   'GetTextFile dispdata$ & "\StdPrint.rtf", txt$, dummy%
   GetRTFTextFromDB dispdata$ & "\StdPrint.rtf", txt$, dummy%  '06Dec16 TH Replaced (TFS 157969)

   Do
      Changed = False
      ParseStdDataItems txt$, Changed
      ParseCtrlChars dispdata$ & "\printer.ini", "RTF", txt$, Changed
   Loop While Changed
   Hedit 3, txt$       'print it
   
   
 'Alternative approach
'   MakeLocalFile file$
'   fil = FreeFile
'   Open file$ For Output As #fil
'   Print #fil, HospName1$; " "; Hospname2$
'   Print #fil, "Printed by "; userid$; " "; UserFullName$; "    Date: "; Mid$(Date$, 4, 3); Left$(Date$, 3); Mid$(Date$, 7); "    Time: "; Left$(Time$, 5)
'   Print #fil,
'   Print #fil, Space$(20); codedesc$;
'   If Right$(codedesc$, 1) <> "s" Then Print #fil, "s"  '13Feb95 CKJ
'   Print #fil,
'   Print #fil,
'   For count = 1 To items
'      code$ = Space$(codemax)
''      LSet code$ = codes(count)
 '     Print #fil, "   "; code$; " .... "; exps(count)
 '  Next
 '  Print #fil,
 '  Print #fil, Space$(10); "---------- End of list ----------"
 '  Close #fil
 '  spool file$

End Sub

Sub QuesSetCtrl(ctl As Control, masktype%, maxlen%, txt$)
'Setup the control for use with the QuesScrl form
'
'Pass the control itself, plus extra information as required
' For a command button leave masktype and maxlen as 0, set txt$ to the caption required
' For a text box (MH masked input) set masktype as detailed below, max length & default text
'   masktype = 0  simple text box, any characters
'              1  numeric characters 0 to 9 only
'              2  Y and N only, 1 char max
'             10  numeric mask ##.#, intended for entering body temperature
'NB: The Combo box control has to be set explicitly with calls to .Additem, not via here.
'
'For more information see QuesScrl.frm
'
'20Oct96 CKJ added trim() to yes/no questions
'28Feb97 CKJ Added masktypes 3, 4, 5, 8, 9, -1
'              3  digits 0-9 and .
'              4  digits 0-9 and -
'              5  digits 0-9 and . -
'              8  custom mask, where the Alphanumeric mask is passed in txt$
'                    set txt$ separately for this type using ONLY A and 9 in the mask
'                    this is automatically set to uppercase
'              9  custom mask, where the mask is passed in txt$, equivalent to k.validchars
'                    set txt$ separately for this type
'                    if all upper case is needed then set the mask in all upper case.
'             -1  simple text box, any characters, but upper case only
'12Apr97 CKJ Mask type 8: Mixed case allowed - set A for upper, a for mixed
'15Apr97 CKJ Corrected above mod
'04Feb99 CFY Additional functionality to masktype 8:
'              X  any alphanumeric character
'              B  any alphabetic character upper or lower case plus space
'27May02 CKJ Corrected mask handling: negatives are types 4 & 5
'15Jun05 CKJ Swapped MHmaskedinput for a plain textbox.
'            Now passes the mask information through in the control's tag
'            <mask type, two digits><force case, one char><mask details, variable length>
'              00^      any text, force uppercase, mask details are blank
'              00*      any text, mixed case, mask details are blank
'              01<sp>   numeric; mask 0 to 9 and optionally . and - are appended
'                       if . is present then only one is permitted
'                       if - is present then this must be the first character
'              02^...   list of valid characters, usable in any order, force uppercase
'              02*...   list of valid characters, usable in any order, mixed case allowed

Dim tmp$, Numoflines%, i%

   'If TypeOf ctl Is MhMaskInput Then        '15Jun05 CKJ Now uses plain text box
   If TypeOf ctl Is TextBox Then             '   "
      Select Case masktype
         Case 0, -1             ' text
            ctl.MaxLength = maxlen
            ctl.text = txt$
   '        If masktype = -1 Then ctl.Case = 1
            ctl.Tag = Iff(masktype, "00^", "00*")
          
         Case 1, 3, 4, 5        ' simple numeric, dp, neg, dp and neg
   '        tmp$ = "0123456789"
   '        ctl.CMask(0) = "0"
   '        If masktype = 3 Or masktype = 5 Then tmp$ = tmp$ & "."
   '        ctl.CMaskChars(0) = tmp$
             
   '        If masktype = 4 Or masktype = 5 Then tmp$ = tmp$ & "-"    '27May02 CKJ negatives are types 4 & 5
   '        ctl.CMask(1) = "-"
   '        ctl.CMaskChars(1) = tmp$
             
   '        ctl.Mask = "-0000000000000000000"
   '        ctl.TextDefault = txt$
            ctl.MaxLength = maxlen
            ctl.text = txt$
            Select Case masktype
               Case 1: tmp$ = ""    '0-9 only
               Case 3: tmp$ = "."   'decimals allowed
               Case 4: tmp$ = "-"   'negatives allowed
               Case 5: tmp$ = "-."  'negative decimals allowed
               End Select
            ctl.Tag = "01 0123456789" & tmp$

         Case 2                 ' yes/no
   '        ctl.CMask(0) = "Y"
   '        ctl.CMaskChars(0) = "YNyn"
   '        ctl.Mask = "Y"
   '        ctl.Case = 1
            ctl.MaxLength = 1
            Select Case Trim$(txt$)
               Case "-1": ctl.text = getYN(1)
               Case "0":  ctl.text = getYN(2)
               Case Else: ctl.text = UCase$(Left$(txt$, 1))
               End Select
            ctl.Tag = "02^" & getYN(0) & LCase$(getYN(0))      'YNyn in appropriate language

         Case 8                 ' custom mask, alphanumerics & space only
   '        ctl.CMask(0) = "9"
   '        ctl.CMaskChars(0) = "0123456789"
   '        ctl.CMask(1) = "A"
   '        ctl.CMaskChars(1) = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
   '        ctl.CMask(2) = "B"                                                                     '04Feb99 CFY Added
   '        ctl.CMaskChars(2) = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz "            '         "
   '        ctl.CMask(3) = "X"                                                                     '         "
   '        ctl.CMaskChars(3) = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"   '         "
   '        If txt$ = UCase$(txt$) Then ctl.Case = 1  '12Apr97 CKJ Mixed case allowed
   '        ctl.Mask = UCase$(txt$)                   '15Apr97 CKJ Added UCase
            ctl.MaxLength = maxlen
            ctl.text = ""
            
            tmp$ = ""
            If InStr(txt, "9") > 0 Or InStr(UCase$(txt), "X") > 0 Then
               tmp$ = "0123456789"
            End If
            If InStr(UCase$(txt), "A") > 0 Or InStr(UCase$(txt), "B") > 0 Or InStr(UCase$(txt), "X") > 0 Then
               tmp$ = tmp$ & "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
            End If
            If InStr(UCase$(txt), "B") Then
               tmp$ = tmp$ & " "
            End If
            
            ctl.Tag = "02" & Iff(txt$ = UCase$(txt$), "^", "*") & tmp$     '15Jun05 CKJ Temporary measure; not specific to position

         Case 9                 ' custom mask, equivalent to k.validchars
   '        ctl.CMask(0) = "X"
   '        If txt$ = UCase$(txt$) Then ctl.Case = 1
   '        ctl.CMaskChars(0) = UCase$(txt$) & LCase$(txt$)
   '        ctl.Mask = "X"
            ctl.MaxLength = maxlen
            ctl.text = ""
            ctl.Tag = "02" & Iff(txt$ = UCase$(txt$), "^", "*") & txt$

         Case 10                ' numeric as ##.#   (eg for temperature 38.4)
   '        ctl.CMask(0) = "0"
   '        ctl.CMaskChars(0) = "0123456789"
   '        ctl.CMask(1) = "."
   '        ctl.CMaskChars(1) = "."
   '        ctl.Mask = "00.0"
            ctl.MaxLength = 4
            ctl.text = txt$
            ctl.Tag = "01 0123456789."      'numeric with decimal point. NB Does not force dp as third character

         'Case 11                ' numeric as ##.##.##.## for BNF codes
         '   ctl.CMask(0) = "0"
         '   ctl.CMaskChars(0) = "0123456789"
         '   ctl.CMask(1) = "."
         '   ctl.CMaskChars(1) = "."
         '   ctl.Mask = "00.00.00.00.0"
         '   ctl.MaxLength = 13
         '   ctl.Text = txt$
         '   ctl.Tag = "11"

         End Select

    ElseIf TypeOf ctl Is CommandButton Then
       ctl.Caption = txt$
       ctl.Width = txtwidth(ctl, (ctl.Caption)) + 240

   ElseIf TypeOf ctl Is ComboBox Then
      '!!** More needs writing!
      If txt$ <> "" Then
         ReDim lines$(10)
         deflines txt$, lines$(), "|", 1, Numoflines
         For i = 1 To Numoflines
            ctl.AddItem lines$(i)
         Next
      End If
      'ctl.Width = txtwidth(ctl, (ctl.Caption)) + 240
   End If

End Sub

Sub QuesSetEnabled(intIndex As Integer, blnEnabled As Integer)
'23Feb03 TH (PBSv4) Written - Allows Ques text fields to be enabled or diabled dynamically
'           Required for PBS Unoriginal fields
Dim intloop As Integer

   On Error Resume Next
   For intloop = 1 To 100
      If Val(Ques.lblDesc(intloop).Tag) = intIndex Then
         Ques.txtQ(intloop).Enabled = blnEnabled
      Exit For
      End If
      If Err Then
         Err = 0
         Exit For
      End If
   Next
   On Error GoTo 0

End Sub

Sub QuesSetText(Index%, text$)

   On Error Resume Next
   Select Case QuesTypeOfCtrl(Index)
      Case 1   ' MhMaskInput/TextBox
         Ques.txtQ(Index).text = text$

      Case 2   ' CommandButton
         Ques.cmdQ(Index).Caption = text$
         Ques.cmdQ(Index).Width = txtwidth(Ques.cmdQ(Index), text$) + 240

      Case 3   ' ComboBox
         popmessagecr "!Warning", "Procedure QuesSetText: Use with a ComboBox is not allowed" & cr & "Please inform EMIS Health Support"
         'Stop '**!!**
      
      End Select
   On Error GoTo 0

End Sub

Sub QuesSetTextNoIndex(intIndex As Integer, strText As String)
'18Mar03 TH (PBSv4) Written - Allows Ques text fields to altered dynamically
'           without knowing the exact tag value (ie you need to change a specific field
'           outside the standard callback loops) Required for PBS Unoriginal fields

Dim intloop As Integer

   On Error Resume Next
   For intloop = 1 To 100
      If Val(Ques.lblDesc(intloop).Tag) = intIndex Then
         Ques.txtQ(intloop).text = strText
         Exit For
      End If
      
      If Err Then
         Err = 0
         Exit For
      End If
   Next
   On Error GoTo 0

End Sub

Sub QuesShow(Index As Integer)
'This procedure calls and shows QuesScrl modally.
'  Set Index to the number of controls (ie lines) created with QuesMakeCtrl
'
'On return Ques.tag = "-1" if the user pressed OK
'      and Ques.tag = ""   if Cancel was pressed.
'
'For more information see QuesScrl.frm
'12Aug97 CKJ resize height to fit on 800x600 or 1024x768 screen
'            Changed TxtWidth char from M to X
'16Dec97 CKJ Added DoSaferEvents to avoid timing issues
'14Aug98 CKJ Form now always centred
'20Apr99 CKJ Widened text fields
'08oct08 CKJ accounts for taskbar when centering

Dim X As Integer, wdth As Integer
Dim ScreenLeft As Long, ScreenTop As Long, ScreenRight As Long, ScreenBottom As Long
Dim ScreenHeightTwips As Long

   On Error Resume Next
   For X = 1 To Index
      If Ques.txtQ(X).MaxLength Then
         wdth = txtwidth(Ques.txtQ(X), String$(Ques.txtQ(X).MaxLength + 2, "X")) 'Uses 'magic' char of X and adds extra two chars to displayed length
         If wdth < Ques.txtQ(X).Width Then Ques.txtQ(X).Width = wdth
      End If
   
     'only one line will work, the others resume next
      Ques.lblInfo(X).Left = Ques.txtQ(X).Left + Ques.txtQ(X).Width + 120
      Ques.lblInfo(X).Left = Ques.cmdQ(X).Left + Ques.cmdQ(X).Width + 120
     'Ques.lblInfo(x).Left = Ques.lst1(x).Left + Ques.lst1(x).Width + 120
      Ques.lblInfo(X).Left = Ques.cmbQ(X).Left + Ques.cmbQ(X).Width + 120
   Next
   On Error GoTo 0
   
   Ques.F3D1.Tag = Str$(Index)
   
   '12Aug97 CKJ will it fit on a standard 640x480, 800x600 or 1024x768 screen?
   '08oct08 CKJ Now accounts for space taken by the taskbar
'   PixelsHigh = Screen.Height \ Screen.TwipsPerPixelY
'   If index <= 27 And PixelsHigh >= 768 Then             'no action, it fits
'      'no action
'   ElseIf index <= 21 And PixelsHigh >= 600 Then         'no action, it fits
'      'no action
'   ElseIf PixelsHigh > 480 Then                          'screen is not too small
'      Ques.Height = Screen.Height                        'enlarge height
'   End If
'   CentreForm Ques                                       'move to centre '14Aug98 CKJ centred
   
   '08oct08 CKJ replaces block above
   GetScreenWorkingArea ScreenLeft, ScreenTop, ScreenRight, ScreenBottom
   Ques.Height = (20 * (Index + 1) + 90) * Screen.TwipsPerPixelY                 '20 pixels per line, add room for one empty line, plus buttons
   ScreenHeightTwips = ScreenBottom - ScreenTop
   If Ques.Height > ScreenHeightTwips Then Ques.Height = ScreenHeightTwips
   On Error Resume Next
   Ques.Move (ScreenRight - Ques.Width + ScreenLeft) \ 2, (ScreenBottom - Ques.Height + ScreenTop) \ 2
   On Error GoTo 0

   Ques.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
   DoSaferEvents 1                                       '16Dec97 CKJ Added to avoid timing issues

End Sub

Function QuesTypeOfCtrl(Index%) As Integer
'Given Index this function returns the type of the control at that position
'using the same numbering as QuesMakeCtrl
'          0  two labels only, or control doesn't exist
'          1  text box (masked input)
'          2  command button
'          3  combo box

Dim tmp$, CtlType%, dummy%

   On Error GoTo QuesTypeOfCtrl_Err
   CtlType = 1
   
   dummy = Ques.txtQ(Index).Left
   If CtlType = 0 Then
         CtlType = 2
         dummy = Ques.cmdQ(Index).Left
      End If
   
   If CtlType = 0 Then
         CtlType = 3
         dummy = Ques.cmbQ(Index).Left
      End If
   On Error GoTo 0
   
   QuesTypeOfCtrl = CtlType

Exit Function

QuesTypeOfCtrl_Err:
   CtlType = 0
Resume Next

End Function

Sub ConstructView(pathfile$, ViewSection$, DataSection$, ViewWanted%, ForceState$, SetReadOnly%, Viewname$, NumOfEntries%)
'Read details of the view requested and populate Quescrol
'XXX Note that the E() structure must have been filled prior to calling
' ViewWanted must be prefilled with the code number of a valid view in stkmaint.ini
' NumOfEntries is returned with number of lines in the chosen view
'For read only items, set the code number negative eg: (from stkmaint.ini)
'  6=Test View,1,2,-3,4,-5
' items 3 and 5 will be read only
' 1May97 CKJ Moved proc to library & made more generic
'27Jun97 CKJ Corrected fault where info$ is repeated on next line(s)
'27Jun97 CKJ Added ForceState$ to allow the calling program to force particular items
'            to be editable or to be read only, irrespective of the ini file view.
'            Forcestate is a comma separated list of items each preceded by + or -
'            There must be no spaces in the list.
'            To force an item to read only set -xx where xx is the item number
'            To force an item to editable  set +xx where xx is the item number
'            e.g.  "+1,+3,-12,-14,-8"   sets 1 & 3 to editable and 8,12,14 to read only
'            The order of items is unimportant. Leading/Trailing commas are ignored.
'            If an item is set to BOTH editable and readonly then Read Only prevails
'            e.g. "-1,+1"  is Read Only
'            Entries without a prefix, or with any other prefix are ignored, although
'            they may be used in the future and are reserved at this time.
'            If SetReadOnly=True then all items are read only, irrespective of the view
'            chosen and the contents of ForceState$

Dim found%, tmp$, i%, Entry%, ReadOnly%, dummy%, State$

   ReDim lines$(60)  'max Entries per view
   ReDim Items$(6)   'data in each line of an entry:   hlp,len,msk,desc,info,mask data
   tmp$ = TxtD(pathfile$, ViewSection$, "", Format$(ViewWanted), found)
   deflines tmp$, lines$(), ",", 0, NumOfEntries
   Viewname$ = lines$(0)
   NumOfEntries = NumOfEntries - 1
   State$ = "," & ForceState$ & ","
                               
   'create Quescrol form & populate it
   For i = 1 To NumOfEntries
      Entry = Val(lines$(i))
      
      ReadOnly = (Entry < 0)
      If InStr(State$, ",+" & Format$(Entry) & ",") Then ReadOnly = False 'Force editable
      If InStr(State$, ",-" & Format$(Entry) & ",") Then ReadOnly = True  'Force read only
      If SetReadOnly Then ReadOnly = True                             'Everything read only

      Entry = Abs(Entry)
      tmp$ = TxtD(pathfile$, DataSection$, "", Format$(Entry), found)
      Items$(4) = ""   '27Jun97 CKJ prevents repeated info$ on next line(s)
      Items$(5) = ""
      Items$(6) = ""
      deflines tmp$, Items$(), ",(*)", 0, (dummy)
      '0 help As Integer
      '1 maxlen As Integer
      '2 mask As Integer
      '3 desc As String
      '4 info As String
      '5 masktext As String

      If Entry = 0 Or (Val(Items$(1)) = 0 And Val(Items$(2)) = 0) Then 'Asked for item zero, or one with a length and mask of zero
            QuesMakeCtrl i, 0
         ElseIf Val(Items$(2)) = 200 Then      'command button requested
            QuesMakeCtrl i, 2
            QuesSetCtrl Ques.cmdQ(i), 0, 0, Items$(5)
            If ReadOnly Then Ques.cmdQ(i).Enabled = False
         ElseIf Val(Items$(2)) = 300 Then      'combo box requesed
            QuesMakeCtrl i, 3
            QuesSetCtrl Ques.cmbQ(i), 0, 0, Items$(5)
            If ReadOnly Then Ques.cmbQ(i).Enabled = False
         Else                                  'normal text box requested
            QuesMakeCtrl i, 1
            QuesSetCtrl Ques.txtQ(i), Val(Items$(2)), Val(Items$(1)), Items$(5)
            If ReadOnly Then Ques.txtQ(i).Enabled = False
         End If
      Ques.lblDesc(i) = Items$(3)
      Ques.lblInfo(i) = Items$(4)
      Ques.lblDesc(i).Tag = Format$(Entry)
   Next
   ReDim lines$(0)

End Sub

