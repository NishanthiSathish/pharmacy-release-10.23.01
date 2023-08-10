Attribute VB_Name = "ToolBar"
'------------------------------------------------------------------------------------
'                           ToolBar Handler
'
'29Dec98 CKJ Uses picToolBar and cmdToolBar() array on a form in the project
'            Ini file must be specified before use, and can contain several views
'            Each view lists IDs of buttons, and each button can have a caption,
'            bitmap or both. The dummy button ID of '0' specifies a separator.
'            IDs can be any combination of printable chars & don't have to be numeric.
'            The path to the bitmaps can include [ascribe] or [dispdata] and these
'            are replaced at runtime with the current paths (without a trailing '\')
'24May99 TH  SetToolBarView: Replaced Prgsdrv$
'25May99 TH  Changed above mod
'09Nov99 AE  DoToolbarButton: Added contexts; Allows the buttons to work in Ward Stock List, by setting the focus
'              back to the list if appropriate.
'              Use SetToolBarContext x% and place code relating to that context in the case
'              statement in DoToolBarButton.
'              If you wish to refer to a specific control here, use SetToolBarLinkCntrl to pass the control
'              to the module, rather than referring to it explicitly. This keeps this module generic.
'            SetToolBarContext: Written as part of above
'            SetToolBarLinkCntrl: Written as part of above.
'05Jul12 CKJ SetToolBarAppearance: Added actions 3 & 4
'            SetBackgroundImage: written                     TFS26714
'28May17 TH  SetToolBarAppearance: Major overhaul to allow Hosted to work without the fileshare. Pictures can now be imported from local file folder only
'            and will be uploaded to the DB for wider "dissemination" (TFS 174888)
'21Jun17 TH  SetToolBarAppearance: Now we need to check the file is small enough to sensibly load (TFS 186470)

'
'--------------------------------------------------
'[views]
'viewname=0,1,0,2,3,0,IDCODE
'
'[buttons]
'caption1=Help
'caption2=Cut
'caption3=Copy
'captionIDCODE=Caption
'
'picture1=C:\Graphics\Bitmaps\Small\Color\help.bmp
'picture2=C:\Graphics\Bitmaps\Small\Color\cut.bmp
'picture3=C:\Graphics\Bitmaps\Small\Color\copy.bmp
'pictureIDCODE=[dispdata]\a_bitmap.bmp
'
'action1=
'action2=
'action3=
'actionIDCODE=
'--------------------------------------------------
'
'
'  _________________________________________________________________________________
' |    _____
' |   | [?] |
' |   |Help | etc...
' |   |_____|
' |_________________________________________________________________________________
'
' picToolBar   picture box acting as container for whole ToolBar
' lineToolBar  horizontal line forming lower border of ToolBar. Other borders are the
'               top, left and right edges of the host form
' cmdToolBar() control button array, with cmdToolBar(0) created at design time.
'               All visible buttons are created at run time
'               Each button may have a small bitmap, caption or both
'
'Data is held in the above controls as follows
' picToolBar.Tag         "inifile name"
' lineToolBar.Tag        "<show bitmaps><show captions>"    as 00 01 10 11 only
' cmdToolBar(0).caption  "view name"
' cmdToolBar(0).Tag      "current number of buttons"
'
'Since a project may contain more than one form with a toolbar installed, the form
' name must be passed as a parameter to most procedures. Generally this can be 'Me'
'
'
'mods wanted
' tooltips
' replaceable parameter in inifile name
'
'------------------------------------------------------------------------------------

DefInt A-Z
Option Explicit

Dim ToolbarContext%
Dim ToolBarLnkCntrl As Control

Function GetToolBarAppearance(frm As Form, Action%) As Integer
'Action = 1  is bitmap visible
'         2  is caption visible

   Select Case Action
      Case 1, 2: GetToolBarAppearance = TrueFalse(Mid$(frm.lineToolBar.Tag, Action, 1))
      Case Else: GetToolBarAppearance = False
      End Select

End Function

Function GetToolBarBackColour(frm As Form) As Long
'Returns current RBG colour

   GetToolBarBackColour = frm.picToolBar.BackColor

End Function

Function gettoolbarcontext%()
                           
'09Nov99 AE Added to return the value of toolbarcontext

   gettoolbarcontext = ToolbarContext


End Function

Sub DoToolBarButton(ButtonTag As String)
'Based on DoButton in events.bas
' ButtonTag has two operating modes;
'  "value1,value2"  where value2 determines the procedure to be called
'  "0,keystrokes"   for use with SendKeys
'    Note: the % prefix in dobutton is NOT added here
'          for Alt-F,X type "%FX"

'09Nov99 AE Added contexts; Allows the buttons to work in Ward Stock List, by setting the focus
'           back to the list if appropriate.

'

Dim keystrokes$
Dim numlines%
'Dim tagtext$()
'Dim validpass As Integer
'Dim fullname$, Accesslvl As String
'Dim Value%, SQLerror%, success%
'Dim pos%

   ReDim tagtext$(5)
   deflines ButtonTag, tagtext$(), ",", 1, numlines
   If Val(tagtext$(2)) <> 0 Then
         'k.escd = False
         Select Case Val(tagtext$(2))     'Standard Functionality
            Case -1                       'save patient-waiting time
               'PatientTicketNo           'patient waiting record
            Case 1, 10                    'display the SQL recordset
               'If Val(tagtext$(2)) = 1 Then
               '      askpassword validpass%, fullname$, "Teamwork Events"
               '   Else
               '      validpass = True
               '   End If
               'If validpass Then
               '      Accesslvl = Mid$(acclevels$, 1, 1)
               '      If Accesslvl = "0" Then
               '            popmessagecr "ASCribe", "Password does not have sufficient privilege for access."
               '         Else
               '            Load FrmOwner
               '            DisplayEventRecords Val(tagtext$(1))
               '            If OwnerFile <> dispdata$ + "\ASCribe" Then
               '                  On Error GoTo norecs
               '                  FrmOwner.OwnerData.Recordset.Update
               '                  On Error GoTo 0
               '                  FreeLocks
               '                  DoEvents
               '              End If
               '         End If
               '   End If
            Case 2:          'StdCancel
            Case 3:          'StdNew
            Case 4:          'StdDelete
            Case 5:          'archive
               
            'Teamwork functionality
            Case 6:          'LogonToAscribe
            Case 7:          'PrintEvent 1      'print single event
            Case 8:          'PrintEvent 2      'Print all the events
            Case 51 To 70:   'DoTeamwork Val(tagtext$(2)), Val(ButtonTag)
            Case 100 To 119: 'DoEmail Val(tagtext$(2))       'Email functionality
               
            Case Else
               
         End Select
      Else
         'tag not holding a function but characters for quick access buttons.
   
         'Do specific operations if the context requires them                    '09Nov99 AE Added block
         Select Case gettoolbarcontext()
            Case 0                     'Context not set -> sendkeys to the window as is.

            Case 1                     'Ward Stock List; set focus to the truegrid before sendkeys
               'mainscreen.TblDisplay.SetFocus
               ToolBarLnkCntrl.SetFocus
            '
            'More here
            '
            End Select

         keystrokes$ = tagtext$(2)
         'MsgBox keystrokes$
         SendKeys keystrokes$
      End If

End Sub

Sub SetToolBarAppearance(frm As Form, Action%, Visible%)
'05Jul12 CKJ Added actions 3 & 4    TFS26714
'
'Action = 1     set bitmaps
'         2     set caption
'Visible  False not visible
'         True  visible
'         1     toggle
'Action = 3     set toolbar colour & mirror in dispensing control (Visible ignored)
'Action = 4     set background image in stores module (Visible ignored)

Dim Value%, BmpTxt$
Dim ans As String
Dim Colour As Long
Dim filename As String
Dim msg As String
Dim success As Boolean
Dim adoStm As ADODB.stream
Dim strParams As String
Dim lngOK As Long
Dim dblFree As Double
Dim bytearray() As Byte
Dim strFilePath As String
Dim lngFileSize As Long
Dim strPic As String
Dim fileNum As Integer
Dim bytes() As Byte
   

   Select Case Action
      Case 1, 2
         'ShowAspect(Action) = Iff(Visible = 1, Not ShowAspect(Action), Visible)
         BmpTxt$ = pad$((frm.lineToolBar.Tag), 2)              'ensure 2 chars present
         Value = TrueFalse(Mid$(BmpTxt$, Action, 1))           'extract current setting
         Value = Iff(Visible = 1, Not Value, Visible)          'set/clear/toggle
         Mid$(BmpTxt$, Action, 1) = Iff(Value, "1", "0")       'splice back in again
         frm.lineToolBar.Tag = BmpTxt$                         'store in the Tag
         SetToolBarView frm, Nul                               'display chosen setting
         
      Case 3                                                   '04Jul12 CKJ Allow to setting of line colour
         On Error GoTo ComDlgCancel
         Colour = frm.picToolBar.BackColor
         frm.CommonDialog1.Flags = &H1& + &H2                  'cdlCCRGBInit and cdlCCFullOpen
         frm.CommonDialog1.Color = Colour
         frm.CommonDialog1.CancelError = True                  'raise error on Cancel (otherwise returns 'Black')
         frm.CommonDialog1.ShowColor
         frm.picToolBar.BackColor = frm.CommonDialog1.Color    'only gets here on [OK]
  
         'save to Stores setting & clear dispensary setting
         Confirm "?Save Site Specific Colour Bar", "save selected colour for display here and in the Dispensing module", ans, k
         If ans = "Y" And Not k.escd Then
            WritePrivateIniFile "", "StoresMenuBarColour", "&H" & Hex$(frm.picToolBar.BackColor), dispdata$ & "\SiteInfo.ini", 0
            WritePrivateIniFile "", "DispensingSiteColour", "", dispdata$ & "\SiteInfo.ini", 0
         Else
            frm.picToolBar.BackColor = Colour
         End If
      
      Case 4         '05Jul12 CKJ Added
         filename = TxtD(dispdata$ & "\siteinfo.ini", "", "", "BackgroundImageFile", 0)
         '25May17 TH REplaced dispdata with Local file path in msg - upoad from known place only (Hosted) (TFS 174888)
         msg = "To set a background image, enter the filename including extension" & cr & cr & _
               msg & "The file must already exist in " & GetLocalFilePath() & cr & _
               msg & "and should be of type BMP, JPG, JPEG or GIF" & cr & cr & _
               msg & "To remove a previously selected image, clear the filename below" & cr & _
               msg & "and press OK. The image file on disk is not affected." & cr
         inputwin "Set Background Image", msg, filename, k
         If Not k.escd Then
            If Len(filename) = 0 Then    'remove entry
               WritePrivateIniFile "", "BackgroundImageFile", "", dispdata$ & "\SiteInfo.ini", 0
               frm.PicLayout.Picture = Nothing
            Else                    'try to load file
               If fileexists(GetLocalFilePath() & "\" & filename) Then
               
                  '21Jun17 TH Now we need to check its small enough to sensibly load (TFS 186470)
                  If FileLen(GetLocalFilePath() & "\" & filename) > 1000000 Then
                    popmessagecr "!Background Image", "Image File is too large to upload. Please choose a smaller file"
                  Else
                      success = True
                      
                      '27May17 TH Load picture into stream (TFS 174888)
    ''                  Set adoStm = New ADODB.stream
    ''                  With adoStm
    ''                    .Type = adTypeBinary
    ''                    .open
    ''                    .LoadFromFile GetLocalFilePath() & "\" & filename
    ''                  End With
                      
                      dblFree = FreeFile
    ''                Open GetLocalFilePath() & "\" & filename For Binary As #dblFree
    ''                    lngFileSize = LOF(dblFree)
    ''                    ReDim bytearray(lngFileSize)
    ''                    Get #dblFree, 1, bytearray()
    ''                Close #dblFree
                    
                        '28May17 TH Use standard file handling now rather than stream (TFS 174888)
                        fileNum = FreeFile
                        Open GetLocalFilePath() & "\" & filename For Binary As fileNum
                        ReDim bytes(LOF(fileNum) - 1)
                        Get fileNum, , bytes
                        Close fileNum
                
                        strPic = encodeBase64(bytes) 'Now encode - transport layer does not support binary data
                        replace strPic, vbLf, "###LineFeed###", 0 'Horrible dirty frig to stop the existing transport layer mangling the encoded text
                      'Now write to DB
                      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                      gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 50, filename) & _
                      gTransport.CreateInputParameterXML("Image", trnDataTypeVarChar, Len(strPic), strPic)
                        
                          lngOK = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pPharmacyImageWrite", strParams)
                        
    ''                  adoStm.Close
    ''                  Set adoStm = Nothing
                
                
                      On Error GoTo SetImageError
                      frm.PicLayout.Picture = LoadPicture(GetLocalFilePath() & "\" & filename) '28May17 TH CHeap and cheeful load the existing file for now
                      On Error GoTo 0
SetImageResume:
                      If success Then
                         WritePrivateIniFile "", "BackgroundImageFile", filename, dispdata$ & "\SiteInfo.ini", 0
                         popmessagecr "#Set Image", "Image file has been set"
                      Else
                         popmessagecr "#Set Image", "Image could not be loaded:" & cr & GetLocalFilePath() & "\" & filename & cr & "No changes made"
                      End If
                    End If
               Else
                  popmessagecr "#Set Image", "File not found:" & cr & GetLocalFilePath() & "\" & filename
               End If
            End If
         End If
      End Select
      
exitsub:
   On Error GoTo 0
Exit Sub

ComDlgCancel:
   frm.picToolBar.BackColor = Colour
Resume exitsub

SetImageError:
   success = False
Resume SetImageResume

End Sub

Sub SetBackgroundImage(frm As Form)
'05Jul12 CKJ Written    TFS26714
'28May17 TH  Changes to utilise DB storage and remove fileshare (TFS 174888)

Dim filename As String

    
   filename = TxtD(dispdata$ & "\siteinfo.ini", "", "", "BackgroundImageFile", 0)
   If Len(filename) Then
      filename = getBackgroundPicture(filename) '28May17 TH Added to utilise DB storage and remove fileshare (TFS 174888)
      If fileexists(filename) Then
         On Error Resume Next
         frm.PicLayout.Picture = LoadPicture(filename)
         On Error GoTo 0
      End If
   End If
   
End Sub

Sub SetToolBarBackColour(frm As Form, Mode%, Colour&)
'If Mode=0 then use QBColor() ie Colour = 0 to 15 only
'If Mode=1 then use full range range of RGB colours

   Select Case Mode
      Case 0: frm.picToolBar.BackColor = Colour& Mod 16
      Case 1: frm.picToolBar.BackColor = Colour&
      End Select

End Sub

Private Sub SetToolBarButton(cmd As Control, ByVal DoBitmapCaption$, ByVal Bitmap$, ByVal Caption$, maxheight%)
'
'
' ----- Button ----     - Configuration -      ---- display ----
' caption    bitmap     caption    bitmap      caption    bitmap   height
'------------------------------------------------------------------------
'    N         N          N          N             nothing
'    N         N          Y    or    Y            separator
'
'    Y         Y          Y          Y           Y          Y
'    Y         Y          N          Y           N          Y
'    Y         Y          Y          N           Y          N
'    Y         Y          N          N             nothing
'
'
'
'
'
Dim showcaption%, showbitmap%, PicError%, hascaption%, hasbitmap%, thisheight%
   
   hasbitmap = (Bitmap$ <> "")                           'has bitmap file name BUT may not be able to load it
   hascaption = (Caption$ <> "")                         'has caption to display
   showbitmap = TrueFalse(Left$(DoBitmapCaption$, 1))    'configuration is selected by user
   showcaption = TrueFalse(Mid$(DoBitmapCaption$, 2, 1)) 'configuration is selected by user
   If showbitmap Or showcaption Then                     'user has not chosen to hide the toolbar
         showbitmap = showbitmap And hasbitmap           'and configuration is selected by user
         showcaption = showcaption And hascaption        'and configuration is selected by user
         If Not showbitmap Then showcaption = hascaption 'no bitmap so still show caption
         If Not showcaption Then showbitmap = hasbitmap  'no caption so still show bitmap
      End If

   PicError = False
   On Error GoTo SetToolBarButton_Err
   cmd.Picture = LoadPicture(Iff(showbitmap, Bitmap$, ""))
   On Error GoTo 0
   If PicError Then                                      'happens if bitmap file not found
         showbitmap = False
         showcaption = hascaption                        'bitmap requested but failed so show caption (if present)
      End If
   cmd.Caption = Iff(showcaption, Caption$, "")
   
   If showbitmap And showcaption Then                    'both
         cmd.Width = TxtWidth(cmd, Caption$) + 270       'text length plus margin
         thisheight = 570
         cmd.Visible = True
         cmd.Enabled = True
      ElseIf Not showbitmap And Not showcaption Then     'neither
         cmd.Width = 90
         thisheight = 60
         cmd.Visible = False
         cmd.Enabled = False
      Else                                               'just one
         cmd.Width = TxtWidth(cmd, Caption$) + 270       'text length plus margin
         thisheight = 315
         cmd.Visible = True
         cmd.Enabled = True
      End If
   cmd.Height = thisheight
   maxheight = GreaterOf(maxheight, thisheight)

SetToolBarButton_Exit:
Exit Sub

SetToolBarButton_Err:
   PicError = True
Resume Next
           
End Sub

Sub SetToolBarcontext (Context%)

'09Nov99 AE Written. Gives the toolbar knowledge of the form it exists on

   ToolbarContext = Context


End Sub

Sub SetToolBarIniFile (frm As Form, filename$)

   frm.picToolBar.Tag = filename$
   frm.lineToolBar.Tag = "11"           'bitmap,caption

End Sub

Sub SetToolBarLinkCntrl (AnyControl As Control)

'09Nov99 AE Added. Removes the need to explicitly refer to external forms in this module

   Set ToolBarLnkCntrl = AnyControl

End Sub

Sub SetToolBarView (frm As Form, Viewname$)
'Given ViewName, set toolbar to match.
' Viewname is held in the picToolBar.Tag
' If Viewname is chr(0) then use stored View
'
'24May99 TH Replaced Prgsdrv$
'25May99 TH Changed above mod

Dim View$, found%, numoflines%, count%, Caption$, Picture$, maxheight%, Action$, posn%
ReDim lines$(1 To 50)
   
   Select Case Viewname$
     Case nul
        View$ = frm.cmdToolbar(0).Caption
     Case ""
        View$ = ""
     Case Else
        View$ = TxTd$((frm.picToolBar.Tag), "Views", "", Viewname$, found)
     End Select

   frm.cmdToolbar(0).Caption = View$
   frm.cmdToolbar(0).Left = -frm.cmdToolbar(0).Width
   deflines View$, lines$(), ",", 1, numoflines
   For count = 1 To numoflines
      If count > Val(frm.cmdToolbar(0).Tag) Then         'If > NumOfButtons
            Load frm.cmdToolbar(count)
         End If
      Caption$ = TxTd$((frm.picToolBar.Tag), "Buttons", "", "Caption" & lines$(count), found)
      Action$ = TxTd$((frm.picToolBar.Tag), "Buttons", "", "Action" & lines$(count), found)
      Picture$ = TxTd$((frm.picToolBar.Tag), "Buttons", "", "Picture" & lines$(count), found)
      posn = InStr(1, Picture$, "[ASCribe]", 1)
      'If posn Then Picture$ = Left$(Picture$, posn - 1) & progsDRV$ & "\ascribe" & Mid$(Picture$, posn + 9)    '24May99 TH Replaced Prgsdrv$
      'If posn Then Picture$ = Left$(Picture$, posn - 1) & AppPathNoSlash() & "\ascribe" & Mid$(Picture$, posn + 9)     '   "
      If posn Then Picture$ = Left$(Picture$, posn - 1) & AppPathNoSlash() & Mid$(Picture$, posn + 9)           '25May99 TH Replaced above mod
      posn = InStr(1, Picture$, "[Dispdata]", 1)
      If posn Then Picture$ = Left$(Picture$, posn - 1) & dispdata$ & Mid$(Picture$, posn + 10)
      SetToolBarButton frm.cmdToolbar(count), frm.lineToolBar.Tag, Picture$, Caption$, maxheight
      frm.cmdToolbar(count).Tag = "0," & Action$                       '"0," added to stay compatible with DoButton
      frm.cmdToolbar(count).Left = frm.cmdToolbar(count - 1).Left + frm.cmdToolbar(count - 1).Width
   Next

   For count = Val(frm.cmdToolbar(0).Tag) To numoflines + 1 Step -1    'unload any spare buttons
      Unload frm.cmdToolbar(count)
   Next

   frm.cmdToolbar(0).Tag = Str$(numoflines)              'store NumOfButtons
   frm.lineToolBar.Y1 = maxheight
   frm.lineToolBar.Y2 = frm.lineToolBar.Y1
   frm.picToolBar.Height = frm.lineToolBar.Y1 + 15
   frm.picToolBar.Visible = True
   frm.lineToolBar.Visible = True
   frm.picToolBar.Refresh
   
'frm.picToolBar.Picture = LoadPicture("\pebldash.bmp")
'frm.PicLayout.Picture = LoadPicture("\pebldash.bmp")

End Sub

Sub ConfigureToolBarPopup (frm As Form)

Dim ans$

   popmenu 0, "", 0, 0
   popmenu 1, "Show Icons", True, GetToolBarAppearance(frm, 1)
   popmenu 1, "Show Text", True, GetToolBarAppearance(frm, 2)
   If Storepasslvl >= 8 Then                          '04Jul12 CKJ added
      popmenu 1, "Toolbar Colour", True, False
      popmenu 1, "Background Image", True, False
   End If
   PopMenuShow ans$, 0, 0
   SetToolBarAppearance frm, Val(ans$), 1
   popmenu 0, "", 0, 0

End Sub

