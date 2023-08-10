Attribute VB_Name = "ENHLIST"
'02Jun97 EAC Added OK,Cancel & Show All buttons & code to
'            handle placement/resizing of buttons on form
'26Jun97 CKJ Re-enabled passing of selected text in the form tag
'            This is blank if escaped, or return pressed on empty textbox
'09May05 CKJ Changed tabstop array from int to long

Option Explicit
DefInt A-Z

Sub EnhLstBoxShow()
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
'19Feb97 EAC copied LstBoxShow and modified for enhanced list box
'26Jun97 CKJ Removed line which clears form tag on exit
'            To enable Shift-F1 lookup set EnhLstFrm.CmdDropDown.Visible = True

Dim maxwidth As Single, i As Single, X As Single, Numoflines%, dummy&, tmp$

   ReDim TabStops(5) As Long

   'set to not min, not max
   EnhLstFrm.WindowState = 0   '!!** Sometines ignored for some reason!
   Screen.MousePointer = HOURGLASS
   If EnhLstFrm.lblTitle = "" Then
         EnhLstFrm.lblHead.Top = 120
      Else
         EnhLstFrm.lblHead.Top = EnhLstFrm.lblTitle.Height
      End If

   If EnhLstFrm.lblHead = "" Then
         EnhLstFrm.LstBox.Top = EnhLstFrm.lblHead.Top
         EnhLstFrm.LstBox.Height = EnhLstFrm.ScaleHeight - EnhLstFrm.lblHead.Top - 600
      Else
         EnhLstFrm.LstBox.Top = EnhLstFrm.lblHead.Top + EnhLstFrm.lblHead.Height
         EnhLstFrm.LstBox.Height = EnhLstFrm.ScaleHeight - EnhLstFrm.lblHead.Top - EnhLstFrm.lblTitle.Height - 600
      End If

   If EnhLstFrm.LstBox.ListCount > 0 And EnhLstFrm.LstBox.ListIndex = -1 Then EnhLstFrm.LstBox.ListIndex = 0

   'set width here
   maxwidth = txtwidth(EnhLstFrm.lblTitle, (EnhLstFrm.lblTitle))
   tmp$ = EnhLstFrm.lblHead
   plingparse tmp$, TB
   X = txtwidth(EnhLstFrm.lblHead, (tmp$))
   If X > maxwidth Then maxwidth = X
   For i = 0 To EnhLstFrm.LstBox.ListCount - 1
      X = txtwidth(EnhLstFrm.LstBox, (EnhLstFrm.LstBox.List(i)))
      If X > maxwidth Then maxwidth = X
   Next
   'maxwidth = maxwidth + 240   'allow for width of scroll bar
   'maxwidth = maxwidth + 240   'bit of a white border at the right within the list box
   'maxwidth = maxwidth + 240   'allow 120 of grey either side of the list box
   maxwidth = maxwidth + 720    'sum of the above
   If maxwidth > EnhLstFrm.LstBox.Width Then
         If maxwidth > Screen.Width Then maxwidth = Screen.Width
         EnhLstFrm.LstBox.Width = maxwidth - 240
         EnhLstFrm.Width = maxwidth + 120
      End If
   
   X = TxtHeight(EnhLstFrm.LstBox)
   If EnhLstFrm.LstBox.ListCount * X < EnhLstFrm.LstBox.Height + X Then
         EnhLstFrm.LstBox.Height = EnhLstFrm.LstBox.ListCount * X + X
         EnhLstFrm.TxtInput.Top = EnhLstFrm.LstBox.Top + EnhLstFrm.LstBox.Height + EnhLstFrm.CmdOk.Height + 120
         EnhLstFrm.LblInput.Top = EnhLstFrm.TxtInput.Top
         EnhLstFrm.CmdDropDown.Top = EnhLstFrm.TxtInput.Top
         
         
         EnhLstFrm.CmdOk.Top = EnhLstFrm.TxtInput.Top - ((EnhLstFrm.CmdOk.Height - EnhLstFrm.TxtInput.Height) / 2)
         EnhLstFrm.cmdCancel.Top = EnhLstFrm.CmdOk.Top
        EnhLstFrm.Height = EnhLstFrm.TxtInput.Top + EnhLstFrm.TxtInput.Height + 700 'Bug Stores-Buttons in the bottom chopped off
         
         
         EnhLstFrm.cmdCancel.Left = EnhLstFrm.LstBox.Left + EnhLstFrm.LstBox.Width - EnhLstFrm.cmdCancel.Width - 200
         EnhLstFrm.CmdOk.Left = EnhLstFrm.cmdCancel.Left - EnhLstFrm.CmdOk.Width - 100
         EnhLstFrm.TxtInput.Left = EnhLstFrm.CmdOk.Left - EnhLstFrm.TxtInput.Width - EnhLstFrm.CmdDropDown.Width - 200
         EnhLstFrm.CmdDropDown.Left = EnhLstFrm.TxtInput.Left + EnhLstFrm.TxtInput.Width
         EnhLstFrm.LblInput.Left = EnhLstFrm.TxtInput.Left - EnhLstFrm.LblInput.Width - 100
      End If
   
   EnhLstFrm.CmdOk.Tag = ""    'used in Activate/Resize events
      
   If EnhLstFrm.lblHead <> "" Then
         i = 0  'number of tabstops found
         X = 0  'position in string
         Do
            X = InStr(X + 1, EnhLstFrm.lblHead, TB)
            If X Then
                  i = i + 1
                  TabStops(i) = X * 4
               End If
         Loop While X > 0
         
         ListBoxTextBoxSetTabs EnhLstFrm.LstHdr, (i), TabStops()     'clear old & set new tabstops
         ListBoxTextBoxSetTabs EnhLstFrm.LstBox, (i), TabStops()     '(just clears if none found)
   
         EnhLstFrm.LstHdr.Clear
         EnhLstFrm.LstHdr.AddItem EnhLstFrm.lblHead
         EnhLstFrm.LstHdr.Visible = True
         EnhLstFrm.LstHdr.Top = EnhLstFrm.lblHead.Top - 15
         EnhLstFrm.LstHdr.Width = EnhLstFrm.LstBox.Width
      End If
   EnhLstFrm.HelpContextID = k.helpnum
   
   CentreForm EnhLstFrm
   EnhLstFrm.CmdDropDown.Enabled = EnhLstFrm.CmdDropDown.Visible '26Jun97 CKJ Added
   Screen.MousePointer = STDCURSOR
   
   EnhLstFrm.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form

   'EnhLstFrm.Tag = ""         26Jun97 CKJ Line removed as this holds the selected item
   EnhLstFrm.CmdOk.Tag = ""
   k.norefresh = False         '12Sep96
   EnhLstFrm.CmdDropDown.Visible = False
   EnhLstFrm.CmdDropDown.Enabled = False
   
End Sub

