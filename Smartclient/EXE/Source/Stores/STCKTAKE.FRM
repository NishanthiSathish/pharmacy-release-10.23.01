VERSION 5.00
Object = "{831FDD16-0C5C-11D2-A9FC-0000F8754DA1}#2.1#0"; "MSCOMCTL.OCX"
Object = "{00025600-0000-0000-C000-000000000046}#5.2#0"; "crystl32.ocx"
Begin VB.Form StockTake 
   Appearance      =   0  'Flat
   AutoRedraw      =   -1  'True
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Stock Take Utility"
   ClientHeight    =   8580
   ClientLeft      =   930
   ClientTop       =   555
   ClientWidth     =   13410
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H80000008&
   Icon            =   "STCKTAKE.frx":0000
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   8580
   ScaleWidth      =   13410
   StartUpPosition =   2  'CenterScreen
   Begin Crystal.CrystalReport rptStockTake 
      Left            =   7680
      Top             =   480
      _ExtentX        =   741
      _ExtentY        =   741
      _Version        =   348160
      PrintFileLinesPerPage=   60
   End
   Begin VB.Frame FraInput 
      Height          =   855
      Left            =   0
      TabIndex        =   6
      Top             =   7680
      Width           =   13335
      Begin VB.TextBox txtStockLvl2 
         Height          =   375
         Left            =   9960
         TabIndex        =   12
         Top             =   240
         Width           =   1095
      End
      Begin VB.TextBox txtStockLvl1 
         Height          =   375
         Left            =   7680
         TabIndex        =   10
         Top             =   240
         Width           =   1095
      End
      Begin VB.Label lblExtraInfo 
         Height          =   495
         Left            =   120
         TabIndex        =   16
         Top             =   240
         Width           =   4815
      End
      Begin VB.Label LblTotal 
         Height          =   375
         Left            =   12240
         TabIndex        =   14
         Top             =   240
         Width           =   855
      End
      Begin VB.Label Label5 
         Caption         =   "Total Stock Level"
         Height          =   375
         Left            =   11160
         TabIndex        =   13
         Top             =   240
         Width           =   1095
      End
      Begin VB.Label lblLocation2 
         Caption         =   "Location 2"
         Height          =   495
         Left            =   8880
         TabIndex        =   11
         Top             =   240
         Width           =   1095
      End
      Begin VB.Label lblLocation1 
         Caption         =   "Location 1 "
         Height          =   495
         Left            =   6600
         TabIndex        =   9
         Top             =   240
         Width           =   1095
      End
      Begin VB.Label lblSysLevel 
         Height          =   375
         Left            =   5760
         TabIndex        =   8
         Top             =   240
         Width           =   735
      End
      Begin VB.Label Label1 
         Caption         =   "System    Level"
         Height          =   495
         Left            =   5040
         TabIndex        =   7
         Top             =   240
         Width           =   735
      End
   End
   Begin VB.PictureBox picHeader 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   12
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   330
      Left            =   0
      ScaleHeight     =   300
      ScaleWidth      =   14025
      TabIndex        =   3
      Top             =   0
      Width           =   14055
      Begin VB.PictureBox picToolBar 
         Appearance      =   0  'Flat
         BorderStyle     =   0  'None
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   285
         Left            =   0
         ScaleHeight     =   285
         ScaleWidth      =   13365
         TabIndex        =   4
         Top             =   0
         Width           =   13365
         Begin VB.CommandButton cmdToolbar 
            Caption         =   "Empty"
            BeginProperty Font 
               Name            =   "MS Sans Serif"
               Size            =   8.25
               Charset         =   0
               Weight          =   400
               Underline       =   0   'False
               Italic          =   0   'False
               Strikethrough   =   0   'False
            EndProperty
            Height          =   495
            Index           =   0
            Left            =   0
            Style           =   1  'Graphical
            TabIndex        =   5
            Top             =   0
            Width           =   1215
         End
         Begin VB.Line lineToolBar 
            Visible         =   0   'False
            X1              =   990
            X2              =   1710
            Y1              =   135
            Y2              =   135
         End
      End
   End
   Begin MSComctlLib.ListView lvwMainScreen 
      Height          =   4335
      Left            =   0
      TabIndex        =   2
      Top             =   1200
      Width           =   13365
      _ExtentX        =   23574
      _ExtentY        =   7646
      View            =   3
      LabelEdit       =   1
      LabelWrap       =   0   'False
      HideSelection   =   0   'False
      FullRowSelect   =   -1  'True
      GridLines       =   -1  'True
      _Version        =   393217
      ForeColor       =   -2147483640
      BackColor       =   -2147483643
      BorderStyle     =   1
      Appearance      =   1
      BeginProperty Font {0BE35203-8F91-11CE-9DE3-00AA004BB851} 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      NumItems        =   0
   End
   Begin VB.TextBox txtNotes 
      Appearance      =   0  'Flat
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   1710
      Left            =   6960
      MultiLine       =   -1  'True
      ScrollBars      =   2  'Vertical
      TabIndex        =   1
      TabStop         =   0   'False
      Top             =   5805
      Width           =   6375
   End
   Begin VB.PictureBox picFooter 
      Appearance      =   0  'Flat
      AutoRedraw      =   -1  'True
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      ForeColor       =   &H80000008&
      Height          =   2055
      Left            =   0
      ScaleHeight     =   2025
      ScaleWidth      =   13335
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   5580
      Width           =   13365
   End
   Begin VB.Label lblHeading 
      Alignment       =   2  'Center
      Appearance      =   0  'Flat
      BackColor       =   &H80000003&
      BorderStyle     =   1  'Fixed Single
      Caption         =   "Label1"
      ForeColor       =   &H80000008&
      Height          =   900
      Index           =   0
      Left            =   0
      TabIndex        =   15
      Top             =   0
      Visible         =   0   'False
      Width           =   1935
      WordWrap        =   -1  'True
   End
   Begin VB.Line Line1 
      X1              =   0
      X2              =   11880
      Y1              =   0
      Y2              =   0
   End
   Begin VB.Menu MnuFileTop 
      Caption         =   "&File"
      Begin VB.Menu mnuStockTake 
         Caption         =   "&Load Existing Stock Take"
         Index           =   0
         Shortcut        =   ^L
      End
      Begin VB.Menu mnuStockTake 
         Caption         =   "&Create New Stock Take"
         Index           =   1
         Shortcut        =   ^C
      End
      Begin VB.Menu mnuStockTake 
         Caption         =   "-"
         Index           =   2
      End
      Begin VB.Menu mnuStockTake 
         Caption         =   "&Print Stock Take Sheet"
         Index           =   3
         Shortcut        =   ^P
      End
      Begin VB.Menu mnuStockTake 
         Caption         =   "&Enter Stock Levels"
         Enabled         =   0   'False
         Index           =   4
         Shortcut        =   ^E
      End
      Begin VB.Menu mnuStockTake 
         Caption         =   "&Authorise Stock Levels"
         Enabled         =   0   'False
         Index           =   5
         Shortcut        =   ^A
      End
      Begin VB.Menu mnuStockTake 
         Caption         =   "Print &Difference Report"
         Index           =   6
         Shortcut        =   ^D
      End
      Begin VB.Menu sep1 
         Caption         =   "-"
      End
      Begin VB.Menu MnuPrintDest 
         Caption         =   "P&rinter Destination"
         Begin VB.Menu MnuDest 
            Caption         =   "Printer"
            Checked         =   -1  'True
            Index           =   0
         End
         Begin VB.Menu MnuDest 
            Caption         =   "Screen"
            Index           =   1
         End
      End
      Begin VB.Menu mnuRobotMessages 
         Caption         =   "View Robot Messages"
      End
      Begin VB.Menu sep3 
         Caption         =   "-"
      End
      Begin VB.Menu MnuExit 
         Caption         =   "E&xit"
         Shortcut        =   ^X
      End
   End
   Begin VB.Menu mnuEditHdg 
      Caption         =   "&Edit"
      Begin VB.Menu mnuRobotEnterAll 
         Caption         =   "Update All &Robot Items"
         Enabled         =   0   'False
         Shortcut        =   ^R
      End
      Begin VB.Menu mnuEdit 
         Caption         =   "&Edit Notes"
         Shortcut        =   ^N
      End
   End
   Begin VB.Menu mnuOptionshdg 
      Caption         =   "&Options"
      Begin VB.Menu mnuOptions 
         Caption         =   "&Review Product File"
         Index           =   1
      End
      Begin VB.Menu mnuOptions 
         Caption         =   "-"
         Index           =   2
      End
      Begin VB.Menu mnuOptions 
         Caption         =   "&Delete Stock Take"
         Index           =   3
      End
      Begin VB.Menu mnuOptions 
         Caption         =   "spare"
         Index           =   4
         Visible         =   0   'False
      End
      Begin VB.Menu mnuOptions 
         Caption         =   "&Reset Product File"
         Index           =   5
      End
      Begin VB.Menu mnuOptions 
         Caption         =   "&Full Product Reset"
         Enabled         =   0   'False
         Index           =   6
         Visible         =   0   'False
      End
   End
   Begin VB.Menu mnuHelphdg 
      Caption         =   "&Help"
      Begin VB.Menu mnuHelp 
         Caption         =   "&Contents                             F1"
         Index           =   0
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "&Search For Help On ..."
         Index           =   1
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "&How To Use Help"
         Index           =   2
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "-"
         Index           =   3
      End
      Begin VB.Menu mnuHelp 
         Caption         =   "&About"
         Index           =   4
      End
   End
End
Attribute VB_Name = "StockTake"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-------------------------------------------------------------------------------------------------------------
'                    STOCKTAKE Form
'
'29Dec97 EAC Use Stores drug description
'06Feb98 EAC lvwMainScreen_Validate,
'            lvwMainScreen_Update : Col changed from 4 to 6 to take account of new fields in grid
'05Mar98 ASC stcktake.frm: Importdata: Facility added to carry out random stock takes.
'01Jul98 CFY/SF MnuPrint_Click: Added TrimRight function to selection criteria to stop crystal complaining
'               with a database dll error. Not sure why this works though.
'23Jul98 CFY ImportData: Local code now also saved in array so that it corresponds with the contents
'            of the MDB.
'24Aug98 TH  LoadSiteData: Sorted Data Alphabetically on description
'24Aug98 TH  ImportData: Sorts Imported Data and order alphabetically on description
'17Nov98 TH  FormLoad: Added switch to deal with Two locations,Check database and update structure if required
'17Nov98 TH  LoadSiteData: Added code to handle two stock locations
'17Nov98 TH  ImportData: Imports extra information if needed for two stock locations
'17Nov98 TH  MnuPrint()_click: Print MSTKLIST.RPT if two stock locations
'17Nov98 TH  lvwMainScreen_Update: Added code to calculate total from both locations.
'19Nov98 TH  MnuPrint()_click: Added check for new report
'13Jan98 CKJ Moved Db check to LoadStockTake
'08Mar99 TH  Prilist: Set report to specific stocktake
'17May99 TH  ImportData: Write to new ID field correctly
'17May99 TH  Removed above mod
'25Aug99 TH  FormLoad: Enable Full Reset menu option on ini setting
'25Aug99 TH  MnuOptions()_Click: Added Full Reset option (on ini setting)
'19Oct99 TH  DeleteStockTake: Change status whether local or nsv code
'16Feb00 AW  LoadSiteData: Added code to read winord.ini and then order by Location1 if required.
'04Jul00 JN  ImportData: Added code to handle 'Out of String Space' error
'30Oct00 AW  StockTake enhancements
'            new global added
'            importdata, printlist, form_load, mnustocktake_click, lvwMainScreen_update, lvwMainScreen_validate
'            lvwMainScreen_keypress: code added to allow stocktake to be displayed in packs
'28Mar01 TH  ClearStockTake: If any cell is currently being edited then clear it to ensure it is not carried across (#48598)
'24sep01 CKJ Merged:
'01Sep01 TH  Replaced stocktakeinpacks ini file setting to conform to other ini switches (as boolean) (#52438)
'11Jan02 TH  MnuStockTake_Click: Tidy up to ensure delete option handled correctly on menu (#55390)
'11Jan02 TH  mnuOptionshdg_Click:   "   (#55390)
'12Apr02 TH  DeleteStockTake: Delete STname$ as its presence maintans the enabled state of the delete button (#55390)
'06Mar07 CKJ Ported MechDisp handling from V8.6
'20Nov07 CKJ Ported mods from V9.9
   '19Mar07 CKJ Corrected stock in packs handling with robot enquiries
   '            Set focus to txt 1 after robot enquiry when feasible
   '26May11 TH  Removed intStockInPacks% (now global from the bas)(F0111999)
'22Jan13 CKJ Added robot stock take for full stocklist TFS26732
'            Added wildcard & comma separated list of locations to new stock take  TFS53365
'            Removed superfluous code - remnants of unsupported TrueGrid
'24Jan13 CKJ Added standard ToolBar colour (but no menu or picture)  TFS 54244
'28Jan13 CKJ Added stocktake name to caption bar   TFS54463
'            Tidied column headings
'06Jan15 TH  ImportData: Ensure systemlevel field is 0 (zero) rather than blank (TFS 97994)
'24Nov16 TH  PrintList: DB based Crystal Mods. For Hosted we access the DB for crystal template NOT fileshare. The rpt file is then written locally for use
'                       This is then persisted fro future use for performance. (TFS 157972)
'02Dec16 TH  Further changes - the main one being to revert the default setting to use context printing - not using this breaks it. (TFS 169915)
'08Jan17 TH  PrintList: Added param and modified RTF handling (TFS 157969)

'mods wanted
'  Escape from the form
'  Timeout needed

'-------------------------------------------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Const modulename$ = "STCKTAKE.FRM"

Dim blnAllAuthorised As Boolean
Dim stnsv$()
Dim numoflines%
Dim SiteCode$, STname$
'Dim TableChanged%          '22Jan13 CKJ Removed - old & not used
'Dim strstockinpacks$        '16Oct00 AW added
'Dim intStockInPacks%       '01Sep01 TH Replaced  '26May11 TH  Removed(F0111999)


Dim StkLine As StockTakeLine
Dim blnChangeFlag As Boolean
Dim blnViewSystemLevel As Boolean

'22Jan13 CKJ Removed - old & not used
'Dim m_intlvwMainScreenShiftBase As Integer  'SQL flags to control selection on grid
'Dim m_intlvwMainScreenDirection As Integer  '   "
'Dim m_blnlvwMainctrlOn As Boolean

'22Jan13 CKJ added
Dim m_BusyInRobot As Boolean
Dim m_CancelRobot As Boolean

Private Sub ClearStockTake()

   'update display
   ''lvwMainScreen.RowIndex = 0  '28Mar01 TH If any cell is currently being edited
                            '           then clear it to ensure it is not carried across  (#48589)
   numoflines = 0
   ReDim stnsv$(numoflines)
   lvwMainScreen.ListItems.Clear
   lvwMainScreen.Refresh

   picHeader.Cls
   picFooter.Cls
   txtNotes.text = ""

   'disable other items
   mnuStockTake(4).Enabled = False
   mnuStockTake(4).Checked = False
   mnuStockTake(5).Enabled = False
   mnuStockTake(5).Checked = False
   mnuRobotEnterAll.Enabled = False '10Jan13 CKJ added
   
   'If strstockinpacks$ = "Y" Then
   If intStockInPacks = True Then    '01Sep01 TH Replaced
      ''lvwMainScreen.ColumnVisible(3) = True
      lvwMainScreen.ColumnHeaders.Item(5).Alignment = lvwColumnCenter '' = 1 + 8192 + &H20   'centred, readonly, centred heading
      ''lvwMainScreen.ColumnStyle(7) = 1 + 8192 + &H20   'centred, readonly, centred heading
      lvwMainScreen.ColumnHeaders.Item(7).Alignment = lvwColumnCenter
      ''lvwMainScreen.ColumnBackColor(3) = &H80000009    'System Caption Text Colour
      'lvwMainScreen.ColumnHeaders.Item(3)
      ''lvwMainScreen.ColumnBackColor(5) = &H80000009    'System Caption Text Colour
      ''lvwMainScreen.ColumnBackColor(7) = &H80000009    'System Caption Text Colour
      ''lvwMainScreen.ColumnBackColor(8) = &H80000009   'System Caption Text Colour
   Else
      ''lvwMainScreen.ColumnVisible(5) = True
      ''lvwMainScreen.ColumnHeaders.Item(5).
      ''lvwMainScreen.ColumnStyle(7) = 1 + 8192 + &H20   'centred, readonly, centred heading
      lvwMainScreen.ColumnHeaders.Item(7).Alignment = lvwColumnCenter
      ''lvwMainScreen.ColumnStyle(9) = 1 + 8192 + &H20   'centred, readonly, centred heading
      lvwMainScreen.ColumnHeaders.Item(9).Alignment = lvwColumnCenter
      ''lvwMainScreen.ColumnBackColor(5) = &H80000009    'System Caption Text Colour
      ''lvwMainScreen.ColumnBackColor(7) = &H80000009    'System Caption Text Colour
      ''lvwMainScreen.ColumnBackColor(9) = &H80000009    'System Caption Text Colour
      ''lvwMainScreen.ColumnBackColor(10) = &H80000009   'System Caption Text Colour
   End If
        
   ''setStockRow 0
   lvwMainScreen_RowChange 0
   
End Sub

Private Sub cmdToolbar_Click(Index As Integer)

   DoToolBarButton (cmdToolbar(Index).Tag)

End Sub

Private Sub DeleteStockTake(STname$)
'@~@~ Archive any at status '2' before deleting
'19Oct99 TH Change status whether local or nsv code
'12Apr02 TH Delete STname$ as its presence maintans the enabled state of the delete button (#55390)
'29Jan13 CKJ Removed first param SiteCode$ & removed from check below - deprecated

Dim loopvar%, SQL$, criteria$, foundPtr As Long, blnFound As Integer  '01Jun02 ALL/ATW
Dim strParams As String
Dim lngResult As Long

'   If Trim$(SiteCode$) = "" Or Trim$(STname$) = "" Then
   If Trim$(STname$) = "" Then
         popmessagecr "!", "No Stock Take loaded"
         Exit Sub
      End If

   Screen.MousePointer = HOURGLASS

   'criteria$ = " WHERE SiteNumber = '" & SiteCode$ & "' AND StockTakeName = '" & STname$ & "'"
   'SQL$ = "DELETE FROM StockTake" & criteria$ & ";"
   'WSDB.Execute SQL$
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("STockTakeName", trnDataTypeVarChar, STNAMELEN, STname$)
               
   lngResult = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWStockTakeDeletebyStockTakeName", strParams)
   
   For loopvar = 1 To numoflines
      If (loopvar Mod 10) = 0 Then
         picFooter.Cls
         picFooter.Print " Deleting: "; loopvar; "/"; numoflines;
         picFooter.Refresh
      End If

      findrdrug "=" & stnsv$(loopvar), 1, d, 0, blnFound, 2, False, False            '19Oct99 TH Change status whether local or nsv code
      If blnFound = 0 Then                                              '   "
         d.SisCode = stnsv$(loopvar)                              '   "
      End If                                                      '   "

      'd.siscode = stnsv$(loopvar)
      getdrug d, 0, foundPtr, True  '01Jun02 ALL/ATW
      If foundPtr Then              '01Jun02 ALL/ATW
         d.stocktakestatus = "0"
         putdrug d '', foundPtr&    '01Jun02 ALL/ATW
      End If
   Next
   picFooter.Cls

   ClearStockTake

   STname$ = "" '12Apr02 TH Delete this as its presence maintans the enabled state of the delete button (#55390)
   SetCaption  '28Jan13 CKJ

   Screen.MousePointer = STDCURSOR

End Sub

Private Sub EditTxtNotes()
'
Dim notes$, change%
Dim strParams As String
Dim lngRow As Long
Dim rsStockTake As ADODB.Recordset
Dim lngOK As Long
   
   If Me.lvwMainScreen.ListItems.count > 0 Then
      lngRow = Me.lvwMainScreen.SelectedItem.Index
      If lngRow Then
'29Jan13 CKJ Removed SiteCode
'         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
'                     gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
'                     gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$) & _
'                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, stnsv(lngRow))
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$) & _
                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, stnsv(lngRow))
         Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakeNotesbyNSVCode", strParams)
         
         If Not rsStockTake Is Nothing Then     'use returned recordset
            If rsStockTake.State = adStateOpen Then
               If rsStockTake.RecordCount <> 0 Then
                  notes$ = RtrimGetField(rsStockTake!notes)
               End If
            End If
         End If
         rsStockTake.Close
         Set rsStockTake = Nothing
               
         change = True
         TextEdit "Notes", notes$, stnsv(lngRow), change, False
   
         If change Then
            '@~@~ if >255 give truncation warning
            On Error Resume Next
            
            'Update The record but Only the Notes ? Yes so read (lock maybe if poss) then write
'29Jan13 CKJ Removed SiteCode
'            strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
'                        gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
'                        gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$) & _
'                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, stnsv(lngRow))
            strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$) & _
                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, stnsv(lngRow))
            Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakeSelectForLine", strParams)
            
            strParams = gTransport.CreateInputParameterXML("WStockTakeID", trnDataTypeint, 4, rsStockTake!WStockTakeID) & _
                        gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, rsStockTake!SiteNumber) & _
                        gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, rsStockTake!StockTakeName) & _
                        gTransport.CreateInputParameterXML("createddate", trnDataTypeDateTime, 8, rsStockTake!createddate) & _
                        gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, rsStockTake!CreatedUser) & _
                        gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, rsStockTake!createdterminal()) & _
                        gTransport.CreateInputParameterXML("modifieddate", trnDataTypeDateTime, 8, rsStockTake!modifieddate) & _
                        gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, rsStockTake!modifieduser) & _
                        gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, rsStockTake!modifiedterminal) & _
                        gTransport.CreateInputParameterXML("status", trnDataTypeVarChar, 1, rsStockTake!status) & _
                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, rsStockTake!NSVCode) & _
                        gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, rsStockTake!Description) & _
                        gTransport.CreateInputParameterXML("PackSize", trnDataTypeVarChar, 5, rsStockTake!PackSize) & _
                        gTransport.CreateInputParameterXML("issueprice", trnDataTypeVarChar, 13, rsStockTake!issueprice) & _
                        gTransport.CreateInputParameterXML("SystemLevel", trnDataTypeVarChar, 9, rsStockTake!SystemLevel) & _
                        gTransport.CreateInputParameterXML("IssueUnits", trnDataTypeVarChar, 5, rsStockTake!IssueUnits) & _
                        gTransport.CreateInputParameterXML("Location1", trnDataTypeVarChar, 3, rsStockTake!Location1) & _
                        gTransport.CreateInputParameterXML("StockLevel1", trnDataTypeVarChar, 9, rsStockTake!StockLevel1) & _
                        gTransport.CreateInputParameterXML("Location2", trnDataTypeVarChar, 3, rsStockTake!Location2) & _
                        gTransport.CreateInputParameterXML("StockLevel2", trnDataTypeVarChar, 9, rsStockTake!StockLevel2) & _
                        gTransport.CreateInputParameterXML("StockLevel", trnDataTypeVarChar, 9, rsStockTake!StockLevel) & _
                        gTransport.CreateInputParameterXML("ClosedStockTake", trnDataTypeint, 4, rsStockTake!ClosedStockTake) & _
                        gTransport.CreateInputParameterXML("notes", trnDataTypeVarChar, 1024, notes$) & _
                        gTransport.CreateInputParameterXML("AuthorisedDate", trnDataTypeDateTime, 4, rsStockTake!AuthorisedDate)
                         
            strParams = strParams & gTransport.CreateInputParameterXML("AuthorisedUser", trnDataTypeVarChar, 3, rsStockTake!AuthorisedUser) & _
                        gTransport.CreateInputParameterXML("AuthorisedTerminal", trnDataTypeVarChar, 15, rsStockTake!AuthorisedTerminal) & _
                        gTransport.CreateInputParameterXML("AuthorisedChange", trnDataTypeFloat, 5, rsStockTake!AuthorisedChange) & _
                        gTransport.CreateInputParameterXML("SystemLevelBeforeAuth", trnDataTypeVarChar, 9, rsStockTake!SystemLevelBeforeAuth) & _
                        gTransport.CreateInputParameterXML("WTranslogID", trnDataTypeint, 4, rsStockTake!WTranslogID)
            lngOK = gTransport.ExecuteUpdateSP(g_SessionID, "WStockTake", strParams)
            On Error GoTo 0
            lvwMainScreen_RowChange 0
            lvwMainScreen_RowChange lngRow
         End If
      End If
   End If
   

End Sub

Private Sub UpdateStockLevels()
Dim lngRow As Long
Dim lvwItem       As ListItem
Dim lvwSubItem    As ListSubItem
Dim strStock1 As String
Dim strStock2 As String
Dim strTotalStock As String
Dim strParams As String
Dim rsStockTake As ADODB.Recordset
Dim lngOK As Long

   If blnChangeFlag Then
      blnChangeFlag = False
''   lngRow = GetStockRow
''   If lngRow < 1 Then Exit Sub
''   Set lvwItem = lvwMainScreen.ListItems(lngRow)
''   If Not intStockInPacks Then
''      Set lvwSubItem = lvwItem.ListSubItems(6)
''   Else
''      Set lvwSubItem = lvwItem.ListSubItems(4)
''   End If
''   strStock1 = lvwSubItem.Text
''   Set lvwSubItem = Nothing
''   If Not intStockInPacks Then
''      Set lvwSubItem = lvwItem.ListSubItems(8)
''   Else
''      Set lvwSubItem = lvwItem.ListSubItems(6)
''   End If
''   strStock2 = lvwSubItem.Text
''   strTotalStock = Format$(Val(strStock1) + Val(strStock2))
''
''   Set lvwSubItem = Nothing
''   Set lvwItem = Nothing
   'If change Then
      '@~@~ if >255 give truncation warning
      On Error Resume Next
      
      'Update The record but Only the Notes ? Yes so read (lock maybe if poss) then write
'29Jan13 CKJ Removed SiteCode
'      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
'                  gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
'                  gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, StkLine.StockTakeName) & _
'                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, StkLine.NSVCode)
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, StkLine.StockTakeName) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, StkLine.NSVCode)
      Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakeSelectForLine", strParams)
      
      strParams = gTransport.CreateInputParameterXML("WStockTakeID", trnDataTypeint, 4, rsStockTake!WStockTakeID) & _
                  gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, rsStockTake!SiteNumber) & _
                  gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, rsStockTake!StockTakeName) & _
                  gTransport.CreateInputParameterXML("createddate", trnDataTypeDateTime, 8, rsStockTake!createddate) & _
                  gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, rsStockTake!CreatedUser) & _
                  gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, rsStockTake!createdterminal()) & _
                  gTransport.CreateInputParameterXML("modifieddate", trnDataTypeDateTime, 8, Now) & _
                  gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, UserID$) & _
                  gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, ASCTerminalName()) & _
                  gTransport.CreateInputParameterXML("status", trnDataTypeVarChar, 1, "1") & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, rsStockTake!NSVCode) & _
                  gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, rsStockTake!Description) & _
                  gTransport.CreateInputParameterXML("PackSize", trnDataTypeVarChar, 5, rsStockTake!PackSize) & _
                  gTransport.CreateInputParameterXML("issueprice", trnDataTypeVarChar, 13, rsStockTake!issueprice) & _
                  gTransport.CreateInputParameterXML("SystemLevel", trnDataTypeVarChar, 9, rsStockTake!SystemLevel) & _
                  gTransport.CreateInputParameterXML("IssueUnits", trnDataTypeVarChar, 5, rsStockTake!IssueUnits) & _
                  gTransport.CreateInputParameterXML("Location1", trnDataTypeVarChar, 3, rsStockTake!Location1) & _
                  gTransport.CreateInputParameterXML("StockLevel1", trnDataTypeVarChar, 9, Trim$(StkLine.StockLevel1)) & _
                  gTransport.CreateInputParameterXML("Location2", trnDataTypeVarChar, 3, rsStockTake!Location2) & _
                  gTransport.CreateInputParameterXML("StockLevel2", trnDataTypeVarChar, 9, Trim$(StkLine.StockLevel2)) & _
                  gTransport.CreateInputParameterXML("StockLevel", trnDataTypeVarChar, 9, Trim$(StkLine.StockTotal)) & _
                  gTransport.CreateInputParameterXML("ClosedStockTake", trnDataTypeint, 4, rsStockTake!ClosedStockTake) & _
                  gTransport.CreateInputParameterXML("notes", trnDataTypeVarChar, 1024, rsStockTake!notes) & _
                  gTransport.CreateInputParameterXML("AuthorisedDate", trnDataTypeDateTime, 4, rsStockTake!AuthorisedDate)
                   
      strParams = strParams & gTransport.CreateInputParameterXML("AuthorisedUser", trnDataTypeVarChar, 3, rsStockTake!AuthorisedUser) & _
                  gTransport.CreateInputParameterXML("AuthorisedTerminal", trnDataTypeVarChar, 15, rsStockTake!AuthorisedTerminal) & _
                  gTransport.CreateInputParameterXML("AuthorisedChange", trnDataTypeFloat, 5, rsStockTake!AuthorisedChange) & _
                  gTransport.CreateInputParameterXML("SystemLevelBeforeAuth", trnDataTypeVarChar, 9, rsStockTake!SystemLevelBeforeAuth) & _
                  gTransport.CreateInputParameterXML("WTranslogID", trnDataTypeint, 4, rsStockTake!WTranslogID)
      lngOK = gTransport.ExecuteUpdateSP(g_SessionID, "WStockTake", strParams)
      On Error GoTo 0
   End If
   
   blnChangeFlag = False
         
'setStockRow 0  '21Jan13 CKJ Get/SetStockRow looked useful but actually did nothing

End Sub

Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
'05mar07 CKJ Ported from V8.6

   If KeyCode = KEY_F4 And Shift = 0 Then             '16oct06 CKJ if robot item then do stock enquiry
      KeyCode = 0
      StockTakeMechDispEnquiry
      SetFocusTo txtStockLvl1                         '19Mar07 CKJ Added. No effect unless stock level 1 is editable
   End If

End Sub

Private Sub Form_Load()

'14Jan98 EAC display packsize and issue units
'17Nov98 TH  Added switch to deal with Two locations and
'            Check database and update structure if required
'13Jan98 CKJ Moved Db check to LoadStockTake
'25Aug99 TH  Enable Full Reset menu option on ini setting
'30Oct00 AW  Added code to change stock take screen to display in packs if setting found in ini file

Dim X As Integer
Dim found%  '25Aug99 TH
Dim tempnum%
Const intWidthMultiplier = 110 '80

   SetChrome Me

   SetStockTakeMode 0
   'strstockinpacks$ = TxtD$(dispdata$ & "\winord.ini", "Stock take", "", "StockInPacks", found%)      '16Oct00 AW added
   intStockInPacks = TrueFalse(TxtD$(dispdata$ & "\winord.ini", "StockTake", "N", "StockInPacks", 0)) '01Sep01 TH Replaced
   ''LvwMainScreen.Width = StockTake.ScaleWidth
   numoflines = 0
   ''LvwMainScreen.Rows = numoflines
   'set column headings and widths for each column
   lvwMainScreen.View = lvwReport
   lvwMainScreen.ListItems.Clear
   lvwMainScreen.ColumnHeaders.Clear
   SetToolBarcontext 2
   SetToolBarLinkCntrl Me.lvwMainScreen
   SetSiteToolBarColourByForm StockTake '24Jan13 CKJ Added   TFS 54244

   ''LvwMainScreen.ColumnName(1) = "Code"
   ''LvwMainScreen.ColumnName(2) = "Description"
   lvwMainScreen.ColumnHeaders.Add , "H:1", "Code", (10 * intWidthMultiplier)
   lvwMainScreen.ColumnHeaders.Add , "H:2", "Description", (45 * intWidthMultiplier)
   
   'If strstockinpacks$ = "Y" Then                                         '16Oct00 AW added
   If intStockInPacks = True Then                                         '01Sep01 TH Replaced
           ''LvwMainScreen.ColumnName(3) = "System Level"                      '        "
           ''lvwMainScreen.ColumnHeaders.
           ''LvwMainScreen.ColumnName(4) = "Locn 1"                            '        "
           ''LvwMainScreen.ColumnName(5) = "Stock Level 1"                     '        "
           ''LvwMainScreen.ColumnName(6) = "Locn 2"                            '        "
           ''LvwMainScreen.ColumnName(7) = "Stock Level 2"                     '        "
           ''LvwMainScreen.ColumnName(8) = "Total Stock Level"                 '        "
           ''lvwMainScreen.ColumnHeaders.Item(8).Width =
           
           lvwMainScreen.ColumnHeaders.Add , "H:3", "System" & crlf & "Level", (9 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:4", "Locn" & crlf & "1", (5 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:5", "Stock Level" & crlf & "1", (9 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:6", "Locn" & crlf & "2", (5 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:7", "Stock Level" & crlf & "2", (9 * intWidthMultiplier)
        lvwMainScreen.ColumnHeaders.Add, "H:8", "Stock Level" & crlf & "Total", (23 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:9", "Status", (6 * intWidthMultiplier)
           tempnum% = 9                                                   '        "
        Else                                                              '        "
           ''LvwMainScreen.ColumnName(3) = "Pack Size"
           ''LvwMainScreen.ColumnName(4) = "Issue Units"
           ''LvwMainScreen.ColumnName(5) = "System Level"
           ''LvwMainScreen.ColumnName(6) = "Locn 1"
           ''LvwMainScreen.ColumnName(7) = "Stock Level 1"
           ''LvwMainScreen.ColumnName(8) = "Locn 2"
           ''LvwMainScreen.ColumnName(9) = "Stock Level 2"
           ''LvwMainScreen.ColumnName(10) = "Total Stock Level"
           
           lvwMainScreen.ColumnHeaders.Add , "H:3", "Pack" & crlf & "Size", (7 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:4", "Issue" & crlf & "Units", (7 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:5", "System" & crlf & "Level", (9 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:6", "Locn" & crlf & "1", (5 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:7", "Stock Level" & crlf & "1", (9 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:8", "Locn" & crlf & "2", (5 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:9", "Stock Level" & crlf & "2", (9 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:10", "Stock Level" & crlf & "Total", (9 * intWidthMultiplier)
           lvwMainScreen.ColumnHeaders.Add , "H:11", "Status", (6 * intWidthMultiplier)
           tempnum% = 11                                                  '        "
        End If                                                            '16Oct00 AW changed
   
   For X = 1 To tempnum%                                                  '     "     added
        'If strstockinpacks = "Y" Then
''      If intStockInPacks = True Then    '01Sep01 TH Replaced
''         LvwMainScreen.ColumnWidth(x) = Choose(x, 10, 45, 9, 5, 9, 5, 9, 9, 5)
''      Else
''         LvwMainScreen.ColumnWidth(x) = Choose(x, 10, 45, 7, 7, 9, 5, 9, 5, 9, 9, 5)
''      End If
''      LvwMainScreen.ColumnVisible(x) = True
      'If strstockinpacks = "Y" Then
      If intStockInPacks = True Then  '01Sep01 TH Replaced
         Select Case X
            Case 3, 4:       lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnCenter '' = 1 + 8192 + &H20  'Centered, readonly, centred heading
            ''Case 2:        LvwMainScreen.ColumnStyle(x) = 8192 + &H20      'readonly, centred heading
            ''Case 5, 7:     LvwMainScreen.ColumnStyle(x) = 5 + 8192 + &H20  'right justified, readonly, centred heading
            Case 5, 7:       lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnRight
            Case 1, 2, 6, 8: lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnLeft
         End Select
      Else
         Select Case X
            Case 1, 5, 6, 8, 10, 2:
               ''LvwMainScreen.ColumnStyle(x) = 1 + 8192 + &H20  'Centered, readonly, centred heading
               lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnLeft ''lvwColumnCenter
            Case 4:
               ''LvwMainScreen.ColumnStyle(x) = 8192 + &H20      'readonly, centred heading
               lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnCenter
            Case 3, 7, 9:
               ''LvwMainScreen.ColumnStyle(x) = 2 + 8192 + &H20  'right justified, readonly, centred heading
               lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnRight
'''         Case 7, 9:
'''         ''LvwMainScreen.ColumnStyle(x) = 5 + 8192 + &H20  'right justified, readonly, centred heading
'''         LvwMainScreen.ColumnHeaders(x).Alignment = lvwColumnRight
         End Select
      End If
   Next

   ''LvwMainScreen.SelectedBackColor = QBColor(7)
   lvwMainScreen.GridLines = True
   ''LvwMainScreen.SelectMode = 0
   ''LvwMainScreen.MarqueeStyle = 3

   ''LvwMainScreen.ParamBackColor = QBColor(7) ' Grey
   ''LvwMainScreen.ParamStatus = -1            ' Apply to all cells
   'If strstockinpacks$ = "Y" Then
'''   If intStockInPacks = True Then  '01Sep01 TH Replaced  SQL ?????
'''      LvwMainScreen.ColumnAddRegexAttr(8) = "^" & Chr$(160)
'''   Else
'''      LvwMainScreen.ColumnAddRegexAttr(10) = "^" & Chr$(160)
'''   End If
   SetTextBoxReadOnly txtNotes, True
   lvwMainScreen.Width = lvwMainScreen.Width + 20
   HeaderDisplay Me, Me.lvwMainScreen, Create, 10
      
   'Turn off specified menu options
   setStockTakeMenus
   CentreForm StockTake
   SetToolBarIniFile Me, dispdata$ & "\winordtb.ini"
   SetToolBarView Me, "StockTake"

   If Storepasslvl > 4 And TrueFalse(TxtD$(dispdata$ & "\winord.ini", "Defaults", "", "StockControlReset", found)) = True Then   '25Aug99 TH Enable Full Reset option
      mnuOptions(6).Visible = True                                                                       '   "
      mnuOptions(6).Enabled = True                                                                       '   "
   End If                                                                                                '   "
   rptStockTake.Destination = crptToPrinter 'set default
   
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)
    If blnChangeFlag And (GetMStockTakeMode() = 1) Then UpdateStockLevels
''   If UnloadMode <> 1 Then    'anything except unload by code
''         Cancel = True
''         Me.Hide
''      End If
   IPLinkShutdown          '06mar07 CKJ Added
   
End Sub

Private Sub Form_Resize()

   On Error Resume Next
   '''picHeader.Width = Me.ScaleWidth
   '''LvwMainScreen.Width = Me.ScaleWidth
   '''picFooter.Width = Me.ScaleWidth
   '''txtNotes.Width = Me.ScaleWidth - txtNotes.Left
   If FraInput.Visible = True Then
      picFooter.Height = (Me.ScaleHeight - (FraInput.Height + 50)) - picFooter.Top
      txtNotes.Height = (Me.ScaleHeight - (FraInput.Height + 50)) - txtNotes.Top
      FraInput.Top = Me.ScaleHeight - (FraInput.Height + 50)
   Else
      picFooter.Height = Me.ScaleHeight - picFooter.Top
      txtNotes.Height = Me.ScaleHeight - txtNotes.Top
      ''FraInput.top = Me.ScaleHeight - (FraInput.Height + 50)
   End If
   On Error GoTo 0

End Sub

Private Sub ImportData(ByVal SiteCode$, ByVal Method%, ByVal MethodText$, ByVal Includes$, ByVal Closed%, ByVal maxitems%, STname$, NumImported%)
'29Dec97 EAC Use Stores drug description
'14Jan98 EAC display packsize and issue units
'            Use Local code instead of NSVCode if available
'05Mar98 ASC Facility added to carry out random stock takes.
'23Jul98 CFY Local code now also saved in array so that it corresponds with the contents
'            of the MDB.
'24Aug98 TH  Now Sorts Imported Data and order alphabetically on description
'17Nov98 TH  Imports extra information if needed for two stock locations
'17May99 TH  Write to new ID field correctly
'17May99 TH  Removed above mod
'04Jul00 JN  Added erase to clear memory for stnsv$ and added related error-trapping (event 43082)
'16Oct00 AW  Added code to display stocktake in packs
'21Jan13 CKJ Added support for multiple location codes with wildcards
'06Jan15 TH  Ensure systemlevel field is 0 (zero) rather than blank (TFS 97994)

'MethodText is Location code or BNF code
'MaxItems   is 0 for no restriction
'Includes = "000" to "111", "<Inc NonStock><Inc Not In Use><Inc Not on Live StockControl>"

Const procname$ = "STCKTAKE.FRM"

'Dim retries%, nod&, criteria$
Dim numofrecs%, count&, SQL$, ans$, desc$, ThisDrug%   '01Jun02 ALL/ATW
Dim DoIt%, numselected%, include%, Suitable%, counter%, DrugCode$
Dim ErrNum&, msg$    '05Jul00 JN Added
Dim tempstock!
Dim foundPtr As Long
'Dim strBNF As String
Dim strLocCodes As String  'up to 100 chars
Dim strInUse As String
Dim strSisstock As String
Dim strLivestockctrl As String
Dim lngOK As Long
Dim strParams As String
Dim rsStockTake As ADODB.Recordset
Dim datNow As Date
Dim strNSVCode As String  '16Feb05 TH Added
Dim ptr As Integer

   Screen.MousePointer = HOURGLASS
   NumImported = 0

''   criteria$ = " WHERE SiteNumber = '" & SiteCode$ & "' AND StockTakeName = '" & STname$ & "'"
''   SQL$ = "SELECT COUNT (*) FROM StockTake" & criteria$ & ";"
   
'29Jan13 CKJ Removed SiteCode & swapped gWardStockSite for gDispSite
'   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gWardStockSite) & _
'               gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
'               gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$)
'   numofrecs = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWStockTakeCountbySiteNumberandStockTakeName", strParams)
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$)
   numofrecs = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWStockTakeCountbySiteAndStockTakeName", strParams)
   
   Screen.MousePointer = STDCURSOR

   If numofrecs > 0 Then
      k.escd = True
      'popmessagecr "!Stocktake", "A stock take of this name already exists."  '28Jan13 CKJ handled outside now  TFS54466
   End If

   If Not k.escd Then
      Screen.MousePointer = HOURGLASS
      MethodText$ = Trim$(UCase$(MethodText$))
      'If Method = 3 Then Parsebnfcode MethodText$   'Method 1 Random, 2 Location, 3 BNF
      On Error GoTo OutOfStringSpaceErr   '04Jul00 JN Added error trapping routine
      Erase stnsv$      '04Jul00 JN Added re event 43082
      On Error GoTo 0

      numselected = 0
      If Mid$(Includes$, 1, 1) = "0" Then strSisstock = "Y"      '0xx' non stock
      If Mid$(Includes$, 2, 1) = "0" Then strInUse = "Y"         'x0x' not in use
      If Mid$(Includes$, 3, 1) = "0" Then strLivestockctrl = "Y" 'xx0' not on live stock control
      
      Select Case Method
         Case 2              'Location
            '18Jan13 CKJ Now allows comma separated list of items, with optional * or % wildcards
            replace MethodText$, "*", "%", 0
            'filter out illegal chars & empty entries
            For ptr = 1 To Len(MethodText$)
               Select Case Mid$(MethodText$, ptr, 1)
                  Case "a" To "z", "A" To "Z", "0" To "9", "%", "*", "&", ",", "-"
                     'valid, no action
                  Case Else
                     Mid$(MethodText$, ptr, 1) = ","
                  End Select
            Next
            replace MethodText$, ",,", ",", 0
            If Len(MethodText$) Then
               If Left$(MethodText$, 1) = "," Then MethodText$ = Mid$(MethodText$, 2)
            End If
            If Len(MethodText$) Then
               If Right$(MethodText$, 1) = "," Then MethodText$ = Left$(MethodText$, Len(MethodText$) - 1)
            End If
            strLocCodes = MethodText$
      
         Case 3              'BNF
            'strBNF = MethodText$
            popmessagecr "!", "BNF filter no longer supported"
            Exit Sub

         Case 4              'NSVCode
            strNSVCode = MethodText$
         End Select
      
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("Sisstock", trnDataTypeVarChar, 1, strSisstock) & _
                  gTransport.CreateInputParameterXML("Inuse", trnDataTypeVarChar, 1, strInUse) & _
                  gTransport.CreateInputParameterXML("Livestockctrl", trnDataTypeVarChar, 1, strLivestockctrl) & _
                  gTransport.CreateInputParameterXML("Loccode", trnDataTypeVarChar, 100, strLocCodes) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, strNSVCode)
      Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWProductbyCriteriaForStockTake", strParams)
      
      If Not rsStockTake Is Nothing Then     'use returned recordset
         If rsStockTake.State = adStateOpen Then
            If rsStockTake.RecordCount <> 0 Then
               Do While Not rsStockTake.EOF               'find all potential matches
                  If (rsStockTake.RecordCount Mod 10) = 0 Then
                     picFooter.Cls
                     picFooter.Print " Checking: "; count; "/"; rsStockTake.RecordCount;
                     picFooter.Refresh
                  End If
                  numselected = numselected + 1
                  ReDim Preserve stnsv$(numselected)
                  stnsv$(numselected) = RtrimGetField(rsStockTake!SisCode)    'store NSVcode
                  rsStockTake.MoveNext
               Loop                          'We now have a list of suitable items in an array of nsvcodes
               picFooter.Cls
            End If
         End If
      End If

      If maxitems = 0 Then maxitems = numselected     'use all if no limit
      If numselected < maxitems Then maxitems = numselected

      If numselected = 0 Then
         popmessagecr "!", "There are no items available for Stock Take" & cr & "which match the chosen criteria." & cr & cr & "Either widen the search criteria or use" & cr & "Options/Reset if all items have been checked."
      Else
         count = 0
         datNow = Now
         Do
            If (count Mod 10) = 0 Then
               picFooter.Cls
               'picFooter.Print crlf; crlf; Tab(10); String$(100! * count / nod, "|"); 'pseudo bargraph
               picFooter.Print " Processing: "; count; "/"; maxitems;
               picFooter.Refresh
            End If
            count = count + 1                                                'running count of items processed
            If Method = 1 Then                                               'pick one at random
               Randomize
               ThisDrug = Int(Rnd * numselected) + 1
               If ThisDrug = 0 Then ThisDrug = 1                          'belt & braces
               If ThisDrug > numselected Then ThisDrug = numselected      'belt & braces
            Else
               ThisDrug = count                                           'pick next one
            End If
   
            d.SisCode = stnsv$(ThisDrug)                  'get NSV code from array
            getdrug d, 0, foundPtr&, True                     'lock & read drug  '01Jun02 ALL/ATW
   
            ''DrugCode$ = GetLocalCode$()
            DrugCode$ = d.SisCode
            desc$ = d.DrugDescription ' desc$ = GetStoresDescription()  XN 4Jun15 98073 New local stores description
            plingparse desc$, "!"
            Dim tempstring$
            If intStockInPacks = True Then  '01Sep01 TH Replaced
               If Trim$(d.stocklvl) = "" Then
                  tempstock! = 0
               Else
                  tempstock! = CDbl(d.stocklvl) / CDbl(d.convfact)
               End If
               tempstring$ = NoExp(tempstock!)
               tempstring$ = Trim$(Left$(tempstring$, 6))
            Else
               tempstring$ = Trim$(d.stocklvl)
            End If
            
            If Trim$(tempstring$) = "" Then tempstring$ = "0" '06Jan15 TH Added (TFS 97994)
         
            strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                        gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
                        gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$) & _
                        gTransport.CreateInputParameterXML("createddate", trnDataTypeDateTime, 8, datNow) & _
                        gTransport.CreateInputParameterXML("CreatedUser", trnDataTypeVarChar, 3, UserID$) & _
                        gTransport.CreateInputParameterXML("createdterminal", trnDataTypeVarChar, 15, ASCTerminalName()) & _
                        gTransport.CreateInputParameterXML("modifieddate", trnDataTypeDateTime, 8, Null) & _
                        gTransport.CreateInputParameterXML("modifieduser", trnDataTypeVarChar, 3, "") & _
                        gTransport.CreateInputParameterXML("modifiedterminal", trnDataTypeVarChar, 15, "") & _
                        gTransport.CreateInputParameterXML("status", trnDataTypeVarChar, 1, "0") & _
                        gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, DrugCode$) & _
                        gTransport.CreateInputParameterXML("Description", trnDataTypeVarChar, 56, desc$) & _
                        gTransport.CreateInputParameterXML("PackSize", trnDataTypeVarChar, 5, Trim$(d.convfact)) & _
                        gTransport.CreateInputParameterXML("issueprice", trnDataTypeVarChar, 13, Left$(Format$(Val(d.cost) / 100), 13)) & _
                        gTransport.CreateInputParameterXML("SystemLevel", trnDataTypeVarChar, 9, tempstring$) & _
                        gTransport.CreateInputParameterXML("IssueUnits", trnDataTypeVarChar, 5, Trim$(d.PrintformV)) & _
                        gTransport.CreateInputParameterXML("Location1", trnDataTypeVarChar, 3, Trim$(d.loccode)) & _
                        gTransport.CreateInputParameterXML("StockLevel1", trnDataTypeVarChar, 9, "") & _
                        gTransport.CreateInputParameterXML("Location2", trnDataTypeVarChar, 3, Trim$(d.loccode2)) & _
                        gTransport.CreateInputParameterXML("StockLevel2", trnDataTypeVarChar, 9, "") & _
                        gTransport.CreateInputParameterXML("StockLevel", trnDataTypeVarChar, 9, "") & _
                        gTransport.CreateInputParameterXML("ClosedStockTake", trnDataTypeint, 4, Closed) & _
                        gTransport.CreateInputParameterXML("notes", trnDataTypeVarChar, 1024, "") & _
                        gTransport.CreateInputParameterXML("AuthorisedDate", trnDataTypeDateTime, 4, Null)  '28Jan13 stocktake name was 20 chars max
                   
            strParams = strParams & _
                        gTransport.CreateInputParameterXML("AuthorisedUser", trnDataTypeVarChar, 3, "") & _
                        gTransport.CreateInputParameterXML("AuthorisedTerminal", trnDataTypeVarChar, 15, "") & _
                        gTransport.CreateInputParameterXML("AuthorisedChange", trnDataTypeFloat, 5, Null) & _
                        gTransport.CreateInputParameterXML("SystemLevelBeforeAuth", trnDataTypeVarChar, 9, "") & _
                        gTransport.CreateInputParameterXML("WTranslogID", trnDataTypeint, 4, Null)
                                    
            lngOK = gTransport.ExecuteInsertSP(g_SessionID, "WStockTake", strParams)
            d.stocktakestatus = "1"                      'added to stock take list
            putdrug d ', foundPtr&                             'put & unlock drug   '01Jun02 ALL/ATW
                     
            'now remove ThisDrug from list of possible matches if doing random matches
            If Method = 1 Then                                               'pick one at random
               For counter = ThisDrug To numselected - 1
                  stnsv$(counter) = stnsv$(counter + 1)                   'remove ThisDrug from array
               Next
               numselected = numselected - 1                              'number left to select from
            End If
         Loop While count < maxitems And numselected > 0
         picFooter.Cls
      End If
   End If

   Screen.MousePointer = STDCURSOR

Exit Sub

OutOfStringSpaceErr:    '05Jul00 JN Added error-trap routine
   Screen.MousePointer = STDCURSOR
   Select Case Err
      Case 14 'Out of string space, so give the error and change Maxitems to -1 so calling sub knows about error
         popmessagecr "!Stock Take Utility", "Unable to run stock take with so many items. Please refine your criteria."
         maxitems = -1
         On Error GoTo 0
         Exit Sub
      Case Else   'message is something else, so give the error and resume next line
         ErrNum = Err
         msg$ = "An error occured during Stock Take creation."
         msg$ = msg$ & cr$ & cr$ & "Error Number: " & Format$(ErrNum)
         msg$ = msg$ & cr$ & "Error Description: " & Error$(ErrNum)
         msg$ = msg$ & cr$ & cr$ & "Please report this error to your System Supervisor."

         popmessagecr "!Stock Take Utility - Error", msg$
         Screen.MousePointer = HOURGLASS
         Resume Next
   End Select
End Sub

Private Sub LoadSiteData(SiteCode$, STname$, strSortOrder As String)
'24Aug98 TH  Sorted Data Alphabetically on description
'17Nov98 TH  Added code to handle two stock locations
'16Feb00 AW  Added code to read winord.ini and then order by Location1 if required.

Dim loopvar%, SQL$, criteria$, viewsyslvl%, StrOptionalDesc$, orderby$
Dim strParams As String
Dim rsStockTake As ADODB.Recordset

   k.escd = False

'29Jan13 CKJ SiteCode must be own DispData.xxx
'   If Trim$(SiteCode$) = "" Then AskSiteCode SiteCode$
'   If k.escd Or SiteCode$ = "" Then
'         popmessagecr "#", "No site selected"
'         Exit Sub
'      End If
   SiteCode$ = Right$(dispdata$, 3)

   If Trim$(STname$) = "" Then AskStockTakeName STname$   '29Jan13 CKJ Removed SiteCode param
   SetCaption  '28Jan13 CKJ
   If STname$ = "" Then         'No Stock Take selected
      Exit Sub
   End If

   Screen.MousePointer = HOURGLASS

   ClearStockTake

   'select count(0) from WStockTake Where SiteNumber=@SiteNumber and LocationID_Site=@LocationID_Site and StockTakeName=@StockTakeName
'29Jan13 CKJ Removed SiteCode & swapped gWardStockSite for gDispSite
'   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gWardStockSite) & _
'               gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
'               gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$)
'   Numoflines = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWStockTakeCountbySiteNumberandStockTakeName", strParams)
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$)
   numoflines = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWStockTakeCountbySiteAndStockTakeName", strParams)
   
   If numoflines = 0 Then
         Screen.MousePointer = 0
         popmessagecr "!Stock Take Utility", "No data is stored for " & STname$ & " (" & SiteCode$ & ")"
         Exit Sub
      End If

   orderby$ = ReadPrivateIniFile(dispdata$ & "\winord.ini", "Stocktake", "OrderBy")
''   If Val(orderby$) = 1 Then
''         StrOptionalDesc$ = "Location1,"
''      Else
''         StrOptionalDesc$ = ""
''      End If
   'sql$ = "SELECT NSVcode,Description,SystemLevel,StockLevel FROM STOCKTAKE WHERE (SiteNumber = '" & SiteCode$ & "') order by description asc;"   ' Added orderby clause
   'sql$ = "SELECT NSVcode,Description,SystemLevel,StockLevel,Location,loc1level,Location2,loc2level FROM STOCKTAKE WHERE (SiteNumber = '" & SiteCode$ & "') order by description asc;"  '17Nov98 TH
   'Sql$ = "SELECT NSVcode,ClosedStockTake FROM STOCKTAKE" & criteria$ & " order by description asc;"'17Nov98 TH                   '16Feb00 AW changed
   ''SQL$ = "SELECT NSVcode,ClosedStockTake FROM STOCKTAKE" & criteria$ & " order by " & StrOptionalDesc$ & " description asc;"      '       "
   
'29Jan13 CKJ Removed SiteCode & swapped gWardStockSite for gDispSite
'   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gWardStockSite) & _
'               gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
'               gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$)
   strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
               gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$)
               
   '10Mar13 TH Added to ensure if muliple locs it orders on this (TFS 58445)
   If Val(orderby$) = 0 And Trim$(strSortOrder) = "" Then
      If IsMultiLocStockTake(gDispSite, STname$) Then orderby$ = "1"
   End If
   
   'If Val(orderby$) = 1 And Trim$(strSortOrder) <> "" Then
   If Val(orderby$) = 1 And Trim$(strSortOrder) = "" Then  '23Feb07 TH Replaced
      Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakeForLoadSiteDataOrderbyLocation", strParams)
   Else
      Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakeForLoadSiteData" & strSortOrder, strParams)
   End If
   If rsStockTake.EOF Then
         Screen.MousePointer = 0
         popmessagecr "!Stock Take Utility", "Error reading data for this site"
         rsStockTake.Close           '13Jan98 CKJ
         Set rsStockTake = Nothing   '13Jan98 CKJ
         Exit Sub
      Else
         If rsStockTake.RecordCount > 0 Then
            rsStockTake.MoveFirst
            viewsyslvl = True
            viewsyslvl = GetField(rsStockTake!ClosedStockTake)
            redrawgrid viewsyslvl
         End If
      End If

   loopvar = 0
   ReDim stnsv$(1 To numoflines)

   viewsyslvl = True
   If Not rsStockTake.EOF Then blnAllAuthorised = True
   Do While Not rsStockTake.EOF
      loopvar = loopvar + 1
      stnsv$(loopvar) = Trim$(GetField(rsStockTake!NSVCode))
      If GetField(rsStockTake!ClosedStockTake) Then viewsyslvl = False
      ''lvwMainScreenFetch SiteCode$, STname$, ItemCode$, loopvar, Authorising%, Value
      If Val(GetField(rsStockTake!status)) <> 2 Then blnAllAuthorised = False
      'lvwMainScreenFetchRow SiteCode$, STname$, "", loopvar, 0, rsStockTake, 0
      lvwMainScreenFetchRow STname$, "", loopvar, 0, rsStockTake, 0     '29Jan13 CKJ removed SiteCode
      Me.lvwMainScreen.ListItems(loopvar).Selected = False
      rsStockTake.MoveNext
   Loop

   rsStockTake.Close
   Set rsStockTake = Nothing   '13Jan98 CKJ

   'update display
   Me.lvwMainScreen.ListItems(1).Selected = True
   lvwMainScreen_RowChange 1
   ''If strstockinpacks$ = "Y" Then
''   If intStockInPacks = True Then  '01Sep01 TH Replaced
''      LvwMainScreen.ColumnVisible(3) = viewsyslvl
''      If Not viewsyslvl Then LvwMainScreen.ColumnHeaders.Item(3).Width = 0
''   Else
''      LvwMainScreen.ColumnVisible(5) = viewsyslvl
''      LvwMainScreen.ColumnHeaders.Item(5).Width = 0
''      If Not viewsyslvl Then LvwMainScreen.ColumnHeaders.Item(5).Width = 0
''   End If
   'LvwMainScreen.Rows = numoflines
   'LvwMainScreen.Refresh

   'enable other items
   mnuStockTake(4).Enabled = True
   mnuStockTake(5).Enabled = True
   mnuRobotEnterAll.Enabled = True '10Jan13 CKJ added
   
   picHeader.Cls
   picHeader.Print Tab(32); "  Stock Take '" & STname$ & "'" '& " for Site " & SiteCode$

   Screen.MousePointer = STDCURSOR
   ''SetStockTakeMode 0 'Moved from outside to allow line below to superceed status
   If blnAllAuthorised Then mnuStockTake(6).Enabled = True
   
End Sub

Private Sub Form_Unload(Cancel As Integer)
   Close
   End
End Sub

Private Sub lblHeading_Click(Index As Integer)
Static blnAscending  'bad practice to have static in frm - should be module level
Dim strOrder As String

   Screen.MousePointer = HOURGLASS

   If lvwMainScreen.ListItems.count > 0 Then                                                                                                                     '            Replaced with this block
      'OK lets reload the stock take in the specified order if we are clicking status
      If (intStockInPacks = True And Index = 9) Or (intStockInPacks = False And Index = 11) Then
         ClearStockTake
         strOrder = Iff(blnAscending, "OrderbyStatusASC", "OrderbyStatusDES")
         LoadSiteData SiteCode$, STname$, strOrder
         blnAscending = Not blnAscending
      End If
   End If                                                                                                                                     '

   Screen.MousePointer = STDCURSOR

End Sub

Private Sub lvwMainScreen_click()
   
   If Me.lvwMainScreen.ListItems.count > 0 Then
      lvwMainScreen_RowChange Me.lvwMainScreen.SelectedItem.Index
   End If
   
End Sub

Sub SetStockTakeMode(ByVal intmode As Integer)

Dim lngRow As Long
   
   'If intMode <> GetMStockTakeMode() Then
   Select Case intmode
   Case 1 ' Edit Mode. Have input bar visible and enabled
      lvwMainScreen.MultiSelect = False
      '11Feb05 TH Added to ensure that entry boxes are disabled if line is already authorised (#78822)
      If lvwMainScreen.ListItems.count > 0 Then
         If lvwMainScreen.SelectedItem.SubItems(lvwMainScreen.SelectedItem.ListSubItems.count) = "A" Then
            txtStockLvl1.Enabled = False
            txtStockLvl2.Enabled = False
         Else
            txtStockLvl1.Enabled = True
            txtStockLvl2.Enabled = True
         End If
      End If
      '---------------------
      FraInput.Visible = True
      FraInput.Enabled = True
      txtStockLvl1.BackColor = &H80000005
      txtStockLvl2.BackColor = &H80000005
      ''picHeader.Print " - Edit"
      picHeader.Cls
      picHeader.Print Tab(32); "  Stock Take '" & STname$ & "'    -    Edit" '& " for Site " & SiteCode$
   
   Case 2 'Authorise mode. Have input bar visible but NOT enabled
      lvwMainScreen.MultiSelect = True
      'Refresh the row
      txtStockLvl1.Enabled = False
      txtStockLvl2.Enabled = False
      txtStockLvl1.BackColor = &H80000013
      txtStockLvl2.BackColor = &H80000013
      FraInput.Visible = True
      '''picHeader.Print " - Authorise"
      picHeader.Cls
      picHeader.Print Tab(32); "  Stock Take '" & STname$ & "'    -    Authorise"
      FraInput.Enabled = False
      
   Case Else  'Initial load or create - input bar invisible
      lvwMainScreen.MultiSelect = False
      FraInput.Visible = False
      txtStockLvl1.BackColor = &H80000005
      txtStockLvl2.BackColor = &H80000005
   End Select

   SetMStockTakeMode intmode
   'REFRESH HERE
   If lvwMainScreen.ListItems.count > 0 Then
      lngRow = lvwMainScreen.SelectedItem.Index
      If lngRow < 1 Then lngRow = 1
      lvwMainScreen_RowChange lngRow
   End If
   setStockTakeMenus
   Form_Resize
   'End If
 
End Sub

Private Sub setStockTakeMenus()
   
   If Storepasslvl < 5 Then
      mnuStockTake(5).Enabled = False
      mnuOptionshdg.Enabled = False
   Else  '**!! UNSURE
      mnuStockTake(0).Enabled = True
      mnuStockTake(1).Enabled = True
      mnuStockTake(3).Enabled = True
      mnuStockTake(4).Enabled = True
      mnuStockTake(6).Enabled = True
      mnuRobotEnterAll.Enabled = True '10Jan13 CKJ added
   End If
   
End Sub

Private Sub lvwMainScreen_ColumnClick(ByVal ColumnHeader As MSComctlLib.ColumnHeader)
Static blnAscending
Dim strOrder As String
   Screen.MousePointer = HOURGLASS

   If lvwMainScreen.ListItems.count > 0 Then                                                                                                                     '            Replaced with this block
      'OK lets reload the stock take in the specified order if we are clicking status
      If (intStockInPacks = True And ColumnHeader.Index = 9) Or (intStockInPacks = False And ColumnHeader.Index = 11) Then
         ClearStockTake
         strOrder = Iff(blnAscending, "OrderbyStatusASC", "OrderbyStatusDES")
         LoadSiteData SiteCode$, STname$, strOrder
         blnAscending = Not blnAscending
      End If
  End If                                                                                                                                     '

   Screen.MousePointer = STDCURSOR
End Sub

Private Sub MnuDest_Click(Index As Integer)

'Index 0  printer
'      1  screen
            
   MnuDest(Index).Checked = True

   Select Case Index
      Case 0
         MnuDest(1).Checked = False
         rptStockTake.Destination = crptToPrinter '' 1    'printer
      Case 1
         MnuDest(0).Checked = False
         rptStockTake.Destination = crptToWindow '' 0    'screen
      End Select

End Sub

Private Sub mnuEdit_Click()

   EditTxtNotes

End Sub

Private Sub mnuEditHdg_Click()

''   mnuEdit.Enabled = (lvwMainScreen.RowIndex > 0)

End Sub

Private Sub mnuExit_Click()

   'Me.Hide
   Unload Me
   Close
   End
   
End Sub

Private Sub MnuFileTop_Click()

   mnuStockTake(3).Enabled = (STname$ <> "")                   'allow print list if name present
   If Not blnAllAuthorised Then mnuStockTake(6).Enabled = mnuStockTake(5).Checked            'allow print difference if adjusting values

End Sub

Private Sub mnuHelp_Click(Index As Integer)
'14Jan99 CKJ

   Select Case Index
      Case 0: Help Me.Hwnd, 0                      '&Contents    F1
      Case 1: HelpSearch Me.Hwnd                  '&Search for Help on...
      Case 2: HelpGet Me.Hwnd, HELP_HELPONHELP, 0  '&How to use Help
      Case 3                               'separator
      Case 4: ShowAboutBox "EMIS Health"   'About
      End Select

End Sub

Private Sub mnuOptions_Click(Index As Integer)
'mods wanted
' possibly double check status "1" items - if no entry exits
' in a stocktake then reset to status "0"
'25Aug99 TH Added Full Reset option (on ini setting)

Dim count&, nod&, NumChecked%, ans$, msg$ ', altered%    '01Jun02 ALL/ATW
Dim lngAltered As Long
Dim status0 As Long, status1 As Long, status2 As Long, statusX As Long
Dim dlocal As DrugParameters
Dim strParams As String
Dim rsStockTake As ADODB.Recordset

   Select Case Index
      Case 1
         Screen.MousePointer = HOURGLASS
         nod = GetNod()
         'For count = 1 To nod
            If (count Mod 10) = 0 Then
                  picFooter.Cls
                  'picFooter.Print crlf; crlf; Tab(10); String$(100! * count / nod, "|"); 'pseudo bargraph
                  picFooter.Print " Processing: "; count; "/"; nod;
                  picFooter.Refresh
               End If
            'getdrug dlocal, count, 0, False
            'Select Case dlocal.stocktakestatus
            '   Case "0":  status0 = status0 + 1
            '   Case "1":  status1 = status1 + 1
            '   Case "2":  status2 = status2 + 1
            '   Case Else: statusX = statusX + 1
            '   End Select
         'Next
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "0")
         status0 = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWProductForStatusCount", strParams)
         
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "1")
         status1 = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWProductForStatusCount", strParams)
         
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                     gTransport.CreateInputParameterXML("Status", trnDataTypeVarChar, 1, "2")
         status2 = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWProductForStatusCount", strParams)
         
         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
         statusX = gTransport.ExecuteSelectReturnSP(g_SessionID, "pWProductForStatusCountOther", strParams)
''         If Not rsStockTake Is Nothing Then    'use returned recordset
''            If rsStockTake.State = adStateOpen Then
''               If rsStockTake.RecordCount <> 0 Then
''                  statusX = RtrimGetField(rsStockTake!statusCount)
''               End If
''            End If
''         End If
''         rsStockTake.Close
''         Set rsStockTake = Nothing
         picFooter.Cls
         msg$ = "Summary of Stock Take Status:" & cr & cr
         msg$ = msg$ & Format$(status0) & TB & " items have yet to be on a Stock Take" & cr
         msg$ = msg$ & Format$(status1) & TB & " items are on a current Stock Take sheet" & cr
         msg$ = msg$ & Format$(status2) & TB & " items have had a Stock Take completed" & cr
         msg$ = msg$ & Format$(statusX) & TB & " items have an invalid Stock Take status" & cr
         msg$ = msg$ & "---------" & cr
         msg$ = msg$ & Format$(nod) & TB & " items in total are in the product file"
         Screen.MousePointer = STDCURSOR
         popmessagecr "#", msg$

      Case 3                         'Delete stock take
         ans$ = "N"
         askwin "!Delete Current Stock Take", "Stock Take " & STname$ & " will be deleted" & cr & "Do you wish to delete it now?", ans$, k
         'If ans$ = "Y" Then DeleteStockTake SiteCode$, STname$
         If ans$ = "Y" Then DeleteStockTake STname$         '29Jan13 CKJ Removed SiteCode
         
      Case 5
         msg$ = "Warning: This option will reset all items in the product file." & cr
         msg$ = msg$ & "" & cr
         msg$ = msg$ & "All items which have had a stocktake completed" & cr
         msg$ = msg$ & "will be made available for future stocktakes." & cr
         msg$ = msg$ & "" & cr
         msg$ = msg$ & "If you continue this action cannot be reversed" & cr
         msg$ = msg$ & "Do you wish to proceed?" & cr
         ans$ = "N"
         askwin "!EMIS Health", msg$, ans$, k
         If ans$ = "Y" Then
               Screen.MousePointer = HOURGLASS
               nod = GetNod()
               'DO a custom Update
               strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
               lngAltered = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWStockTakeForReset", strParams)
               
''               'SQL getnod nod
''               For count = 1 To nod
''                  If (count Mod 10) = 0 Then
''                        picFooter.Cls
''                        picFooter.Print " Processing: "; count; "/"; nod;
''                        picFooter.Refresh
''                     End If
''                  getdrug dlocal, count, 0, False
''                  Select Case dlocal.stocktakestatus
''                     Case "0", "1"                                 'not changed
''                     Case Else                                     'change all others
''                        getdrug dlocal, count, 0, True             'lock & read
''                        dlocal.stocktakestatus = "0"
''                        altered = altered + 1
''                        putdrug dlocal '', count                      'put & unlock
''                     End Select
''               Next
               picFooter.Cls
               msg$ = Format$(lngAltered) & " items reset out of " & Format$(nod) & " items total"
               Screen.MousePointer = STDCURSOR
               popmessagecr "#", msg$
            End If

      Case 6                                                                '25Aug99 TH Added for Lewisham
         msg$ = "    WARNING: This option will reset ALL" & cr              '           Enabled on ini setting
         msg$ = msg$ & "             items in the product file." & cr       '   "
         msg$ = msg$ & "" & cr                                              '   "
         msg$ = msg$ & "        FULL PRODUCT RESET" & cr & cr               '   "
         msg$ = msg$ & "All items regardless of whether on a" & cr          '   "
         msg$ = msg$ & "current stocktake or not will be made" & cr         '   "
         msg$ = msg$ & "available for future stocktakes." & cr              '   "
         msg$ = msg$ & "" & cr                                              '   "
         msg$ = msg$ & "Ideally All Stock Takes should be deleted" & cr     '   "
         msg$ = msg$ & "before running this option" & cr & cr               '   "
         msg$ = msg$ & "If you continue this action cannot be" & cr         '   "
         msg$ = msg$ & "reversed " & cr & cr                                '   "
         msg$ = msg$ & "Do you wish to proceed?" & cr                       '   "
         ans$ = "N"                                                         '   "
         askwin "!EMIS Health", msg$, ans$, k                                   '   "
         If ans$ = "Y" Then                                                 '   "
               Screen.MousePointer = HOURGLASS                              '   "
               'SQL getnod nod                                                   '   "
               nod = GetNod()
               strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite)
               lngAltered = gTransport.ExecuteUpdateCustomSP(g_SessionID, "pWStockTakeForResetFull", strParams)
               
''               For count = 1 To nod                                         '   "
''                  If (count Mod 10) = 0 Then                                '   "
''                        picFooter.Cls                                       '   "
''                        picFooter.Print " Processing: "; count; "/"; nod;   '   "
''                        picFooter.Refresh                                   '   "
''                     End If                                                 '   "
''                  getdrug dlocal, count, 0, False                           '   "
''                  Select Case dlocal.stocktakestatus                        '   "
''                     Case "0"                                               '   "
''                     Case Else                                     'change all items (even those on stocktake)
''                        getdrug dlocal, count, 0, True             'lock & read
''                        dlocal.stocktakestatus = "0"                        '   "
''                        lngAltered = lngAltered + 1                               '   "
''                        putdrug dlocal '', count                      'put & unlock
''                     End Select                                             '   "
''               Next                                                         '   "
               picFooter.Cls                                                '   "
               msg$ = Format$(lngAltered) & " items reset out of " & Format$(nod) & " items total"
               Screen.MousePointer = STDCURSOR                              '   "
               popmessagecr "#", msg$                                       '   "
            End If                                                          '   "
      End Select

   SetCaption  '28Jan13 CKJ

End Sub

Private Sub mnuOptionshdg_Click()

   'mnuOptions(3).Enabled = (Trim$(SiteCode$ & STname$) <> "")                '11Jan02 TH Replaced (#55390)
   mnuOptions(3).Enabled = (Trim$(SiteCode$) <> "" And Trim$(STname$) <> "")  '   "
      
End Sub

Private Sub mnuRobotEnterAll_Click()
'10Jan13 CKJ Written
'            If in 'Enter' mode, scan all items and update stock level where stock enquiry is supported

   StockTakeMechDispEnquiryAll

End Sub

Private Sub mnuRobotMessages_Click()
'13Mar07 CKJ added (SC-07-0157)

   ShowAllRobotMessageWindows
   
End Sub

Private Sub mnuStockTake_Click(Index As Integer)
'30Oct00 AW changed to allow stock take to be shown in packs only
'11Jan02 TH Tidy up to ensure delete option handled correctly on menu (#55390)
'28Jan13 CKJ Duplicate stocktake name name now allows edit & retry TFS54466
'31Jan13 CKJ Removed k.escd checks
'08Mar13 TH  Added to reset k.escd. Escape was previously retained (TFS 58443)

Dim ans$, Method%, Includes$, count%, maxitems%, MethodText$, NumImported%, Closed%
Dim lngNod As Long
Dim strDescription As String
Dim lngFound As Long
Dim msg As String

''If GetMStockTakeMode() = 1 And GetStockRow > 0 Then UpdateStockLevels
          
   SiteCode$ = Right$(dispdata$, 3) '29Jan13 CKJ
   
   k.escd = False '08Mar13 TH Added to reset (TFS 58443)
   
   Select Case Index
      Case 0                        'Load existing stock take
         'AskSiteCode SiteCode$     '29Jan13 CKJ Deprecated - set to own dispdata.xxx
         'If Not k.escd Then        '31Jan13 CKJ removed
         ClearStockTake
         STname$ = ""
         SetCaption  '28Jan13 CKJ
         LoadSiteData SiteCode$, STname$, ""          '@~@~
         '   End If
         SetStockTakeMode 0
         
      Case 1                         'Create new stock take
         'AskSiteCode SiteCode$      'ask site    '29Jan13 CKJ Deprecated - set to own dispdata.xxx
         'If Not k.escd Then         '31Jan13 CKJ removed
         ClearStockTake
         STname = "" '28Jan13 CKJ
         SetCaption  '28Jan13 CKJ

         StockTakeDefaults.Show 1    'ask method: random, location, BNF, Max items
         If StockTakeDefaults.Tag = "1" Then
            Method = 0
            Includes$ = ""
            For count = 1 To 4 '3
               If StockTakeDefaults.optStockTake(count).Value Then Method = count
               If count < 4 Then Includes$ = Includes$ & Iff(StockTakeDefaults.chkStockTake(count), "1", "0")
            Next
            Closed = TrueFalse((StockTakeDefaults.chkStockTake(0)))
            MethodText$ = StockTakeDefaults.txtMethod(Method).text
            lngNod = GetNod()
            If Val(StockTakeDefaults.txtMaxItems.text) > lngNod Then
               k.escd = True
               popmessagecr "#", "There are only " & Format$(lngNod) & " items available in this stock holding." & _
               crlf & crlf & "Please amend the maximum number entered and try again."
            Else
               maxitems = Val(StockTakeDefaults.txtMaxItems.text)
            End If

            'now ask name
            k.Max = STNAMELEN    '28Jan13 CKJ Changed from 20
            k.min = 2
            If Method = 4 Then
               d.SisCode = MethodText
               getdrug d, 0, lngFound, False
               If lngFound > 0 Then
                  strDescription = d.DrugDescription ' strDescription = GetStoresDescription()  XN 4Jun15 98073 New local stores description
                  plingparse strDescription, "!"
                  'ans$ = Trim$(MethodText) & " " & Left$(strDescription, 12) '28Jan13 CKJ changed to allow full description  TFS54468
                  ans$ = Trim$(MethodText) & " " & Trim$(strDescription)      '7+1+56=54 chars max
               End If
            End If
            If Not k.escd Then
               msg = "Enter a name to identify this stock take"
               Do '28Jan13 CKJ added loop   TFS54466
                  STname$ = ""   'in case user exits on 2nd or subsequent pass
                  k.escd = False
                  inputwin "Stock Take", msg, ans$, k
                  If k.escd Then Exit Do     'user cancelled
                  STname$ = ans$
                  ImportData SiteCode$, Method, MethodText$, Includes$, Closed, maxitems, STname$, NumImported
                  msg = "A stock take already exists with name " & STname & cr & _
                        "Enter a new name to identify this stock take"
               Loop While k.escd    'duplicater name; re-enter
            End If
                                    
            SetCaption           '28Jan13 CKJ
            If Not k.escd Then
               If maxitems > -1 Then LoadSiteData SiteCode$, STname$, ""   '06Jul00 JN amended to check maxitems > -1
               'update display
               If lvwMainScreen.ListItems.count > 0 Then
                  ''Me.LvwMainScreen.ListItems(1).selected = True
                  lvwMainScreen_RowChange 0
                  ''setStockRow 0
                  lvwMainScreen_RowChange 1
               End If
            End If
         'End If           '11Jan02 TH Added (#55390)
         Else              '   "
            STname$ = ""   '   "
         End If
         Unload StockTakeDefaults
         '   End If
         SetStockTakeMode 0

      'Case 2                        'separator

      Case 3                         'Print stock take sheet
         PrintList 1

      Case 4                         'Enter stock levels     @~@~ ADD Passwords here
      If Trim$(STname$) <> "" Then '18Oct05 TH Only if there is a stock take loaded
''      'stocktake in packs change columns                     '16Oct00 AW added block
         mnuStockTake(4).Checked = True
         mnuStockTake(5).Checked = False
''         If strstockinpacks = "Y" Then
''         If intStockInPacks = True Then  '01Sep01 TH Replaced
''                lvwMainScreen.ColumnStyle(5) = 1 + &H20
''                lvwMainScreen.ColumnStyle(7) = 1 + &H20
''                lvwMainScreen.ColumnBackColor(5) = &H7FFFFF
''                lvwMainScreen.ColumnBackColor(7) = &H7FFFFF
''                lvwMainScreen.ColumnBackColor(3) = &H80000009
''                lvwMainScreen.ColumnBackColor(8) = &H80000009
''                lvwMainScreen.ColumnIndex = 5
''                lvwMainScreen.MarqueeStyle = 2
''
''            Else
''                 lvwMainScreen.ColumnStyle(7) = 1 + &H20           'centred, centred heading
''                 lvwMainScreen.ColumnStyle(9) = 1 + &H20           'centred, centred heading
''                 lvwMainScreen.ColumnBackColor(7) = &H7FFFFF       'Pale YELLOW
''                 lvwMainScreen.ColumnBackColor(9) = &H7FFFFF       'Pale YELLOW
''                 lvwMainScreen.ColumnBackColor(5) = &H80000009     'System Caption Text Colour
''                 lvwMainScreen.ColumnBackColor(10) = &H80000009    'System Caption Text Colour
''                 lvwMainScreen.ColumnIndex = 7
''                 lvwMainScreen.MarqueeStyle = 2
''            End If
         'Set the mode so we know what we are about
         'Fire off the current rowselect so that we can store the current stock levels and pick
         'them up if they change before moving off the row.
         SetStockTakeMode 1
         End If
         
      Case 5                         'Authorise stock levels    @~@~ ADD Passwords here
         mnuStockTake(4).Checked = False                           '16Oct00 AW added block
         mnuStockTake(5).Checked = True
         'If strstockinpacks = "Y" Then
''         If intStockInPacks = True Then  '01Sep01 TH Replaced
''                lvwMainScreen.ColumnStyle(5) = 1 + 8192 + &H20
''                lvwMainScreen.ColumnStyle(7) = 1 + 8192 + &H20
''                lvwMainScreen.ColumnBackColor(5) = &H80000009
''                lvwMainScreen.ColumnBackColor(7) = &H80000009
''                lvwMainScreen.ColumnBackColor(3) = &H7FFFFF
''                lvwMainScreen.ColumnBackColor(8) = &H7FFFFF
''                lvwMainScreen.ColumnIndex = 8
''                lvwMainScreen.MarqueeStyle = 3
''                lvwMainScreen.ColumnVisible(3) = True
''            Else
''                 lvwMainScreen.ColumnStyle(7) = 1 + 8192 + &H20    'centred,readonly, centred heading
''                 lvwMainScreen.ColumnStyle(9) = 1 + 8192 + &H20    'centred,readonly, centred heading
''                 lvwMainScreen.ColumnBackColor(7) = &H80000009     'System Caption Text Colour
''                 lvwMainScreen.ColumnBackColor(9) = &H80000009     'System Caption Text Colour
''                 lvwMainScreen.ColumnBackColor(5) = &H7FFFFF       'Pale YELLOW
''                 lvwMainScreen.ColumnBackColor(10) = &H7FFFFF      'Pale YELLOW
''                 lvwMainScreen.ColumnIndex = 10
''                 lvwMainScreen.MarqueeStyle = 3
''                 lvwMainScreen.ColumnVisible(5) = True
''            End If
         SetStockTakeMode 2
         
      Case 6                         'print difference report
         PrintList 2

      End Select
   
   SetCaption  '28Jan13 CKJ

End Sub

Private Sub PrintList(Index As Integer)
'01Jul98 CFY/SF Added TrimRight function to selection criteria to stop crystal complaining
'               with a database dll error. Not sure why this works though.
'17Nov98 TH  Print MSTKLIST.RPT if two stock locations
'19Nov98 TH  Added check for new report
'08Mar99 TH  Set report to specific stocktake
'30Oct00 AW  Added code to choose report
'12Jun06 TH  Revamped to allow generic reports built using ttx files
'24Nov16 TH  DB based Crystal Mods. For Hosted we access the DB for crystal template NOT fileshare. THe rpt file is then written locally for use
'            This is then persisted fro future use for performance. (TFS 157972)
'02Dec16 TH  Further changes - the main one being to revert the default setting to use context printing - not using this breaks it. (TFS 169915)

Dim StockListReport$                            '30Oct00 AW added
Dim blnExit As Boolean
Dim strAnswer As String
Dim strReportName As String
Dim strParams As String
Dim rs As ADODB.Recordset
Dim crxApp As New CRAXDDRT.Application
Dim crxRpt As CRAXDDRT.Report
Dim dlocal As DrugParameters
Dim dblDifference As Double
Dim strTemp As String
Dim strDetailLine As String
Dim strRTFLayout As String
Dim strContext As String
Dim strRTFTxt As String
Dim strPgHdr As String
Dim strPgItem As String
Dim strPgEnd As String
Dim strTmpFile As String
Dim intTmpFileNo As Integer
Dim strPRN As String       '04Jun08 TH Added (F0025081)
Dim strLines() As String   '  "
Dim blnNoCrystalReport As Boolean  '24Nov16 TH Added for DB based Crystal (TFS 157972)
Dim intSuccess As Integer '07Jan17 TH Added (TFS 157969)

   blnExit = False
   If TrueFalse(TxtD(dispdata$ & "\winord.ini", "StockTake", "Y", "UseCrystal", 0)) Then
      If intStockInPacks = True Then
         StockListReport$ = "\MSTLISTP.RPT"
      Else
         StockListReport$ = "\MSTKLIST.RPT"
      End If
   Else
      If intStockInPacks = True Then
         StockListReport$ = "\MSTLISTP.RTF"
      Else
         StockListReport$ = "\MSTKLIST.RTF"
      End If

   End If
   If Index = 2 Then
      'blnExit = UnAuthorisedStocklines(Trim$(SiteCode$), Trim$(STname$))
      blnExit = UnAuthorisedStocklines(Trim$(STname$))      '29Jan13 CKJ removed SiteCode$
      If blnExit Then
         askwin "", "Not all lines have been authorised. Do you wish to continue Y/N", strAnswer, k
         If strAnswer = "Y" And k.escd = False Then blnExit = False
      End If
   End If
   If Not blnExit Then
      If TrueFalse(TxtD(dispdata$ & "\winord.ini", "StockTake", "Y", "UseCrystal", 0)) Then
         Select Case Index
            Case 1
               'RptStockTake.ReportFileName = dispdata$ & "\STCKLIST.RPT"                        '16Oct00 AW changed
               If Not TrueFalse(TxtD(dispdata$ & "\winord.ini", "CrystalReports", "Y", "CrystalDBReports", 0)) Then '05Dec16 TH DOnt check if report is in DB
                  If Not fileexists(dispdata$ & StockListReport$) Then
                     popmessagecr ".Error", "Crystal report file " & StockListReport$ & " missing from directory " & dispdata$ & cr & cr & "Cannot load the Stock Take Utility."   '19Nov98 TH
                     Exit Sub
                  End If
               End If
               'Me.rptStockTake.ReportFileName = dispdata$ & StockListReport$
               strReportName = StockListReport$
            Case 2
               'Me.rptStockTake.ReportFileName = dispdata$ & "\STCKDIFF.RPT"
               strReportName = "\STCKDIFF.RPT"
         End Select
      Else
         Select Case Index
            Case 1
               GetRTFTextFromDB dispdata$ & StockListReport$, "", intSuccess
               'If Not fileexists(dispdata$ & StockListReport$) Then
               If Not intSuccess Then
                  'popmessagecr ".Error", "RTF file " & StockListReport$ & " missing from directory " & dispdata$ & cr & cr & "Cannot load the Stock Take Utility."   '19Nov98 TH
                  popmessagecr ".Error", "RTF " & StockListReport$ & " missing from database." & cr & cr & "Cannot load the Stock Take Utility."   '19Nov98 TH
                  Exit Sub
               End If
               strReportName = StockListReport$
            Case 2
               strReportName = "\STCKDIFF.RTF"
         End Select

      End If
      Screen.MousePointer = HOURGLASS
      '29Jan13 CKJ Removed SiteCode
'      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
'                  gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
'                  gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, Trim$(STname$))
'      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakeBySiteNumberandStockTakeName", strParams)
      strParams = gTransport.CreateInputParameterXML("SiteID", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, Trim$(STname$))
      Set rs = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakeBySiteAndStockTakeName", strParams)
      
      If TrueFalse(TxtD(dispdata$ & "\winord.ini", "StockTake", "Y", "UseCrystal", 0)) Then
         'Set crxApp = New CRAXDDRT.Application
         If TrueFalse(TxtD(dispdata$ & "\winord.ini", "CrystalReports", "Y", "CrystalDBReports", 0)) Then  '14Nov16 TH Added new section to get reports from the DB (TFS 157972)
            strReportName = getCrystalFilefromSQL(strReportName)
            If strReportName = "" Then
               Screen.MousePointer = STDCURSOR
               popmessagecr "Error", "Stock Take Crystal report file missing from Database." & Chr$(13) & Chr$(13) & "Cannot Print Stock Take Sheet."
               blnNoCrystalReport = True
            End If
         Else
            strReportName = dispdata$ & strReportName
            If Not fileexists(strReportName) Then
               Screen.MousePointer = STDCURSOR
               popmessagecr "!", "Could not print report. File " & strReportName & " not found"
               blnNoCrystalReport = True
            End If
         End If
         If Not blnNoCrystalReport Then
            Set crxApp = New CRAXDDRT.Application
            Set crxRpt = crxApp.OpenReport(strReportName)
         
            'rs.Sort = "ScreenPosn"  'sort order if required.
            crxRpt.Database.SetDataSource rs
            On Error GoTo PrintListErr
            '04Jun08 TH Added (F0025081)
            If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "StockTake", "N", "PreviewReports", 0)) Then
               Dim FormReport As New FrmReport
               FormReport.CRViewer.ReportSource = crxRpt
               FormReport.CRViewer.ViewReport
               'FormReport.CRViewer.PrintReport
               Screen.MousePointer = STDCURSOR
               FormReport.Show 1
               Unload FormReport
               Set FormReport = Nothing
            Else
               If TrueFalse(TxtD$(dispdata$ & "\winord.ini", "StockTake", "Y", "CrystalPrintContext", 0)) Then 'switched on debug
                  SelectPrinterFromContext "WSpool", strPRN
                  'MsgBox strPRN
                  If strPRN <> "" Then
                     ReDim strLines(3)
                     deflines strPRN, strLines(), ",", 0, 3
                     crxRpt.SelectPrinter strLines(1), strLines(0), strLines(2)
                  End If
               End If
               crxRpt.PrintOut
               'crxRpt.SelectPrinter
               Screen.MousePointer = STDCURSOR
            End If
            ''04Jun08 TH ----------------------------------------------------------------
            Set crxRpt = Nothing
            Set crxApp = Nothing
         End If
         
         '04Jun08 TH Moved above into if statement (F0025081)
         'Dim FormReport As New FrmReport
         'FormReport.CRViewer.ReportSource = crxRpt
         'FormReport.CRViewer.ViewReport
         'Screen.MousePointer = STDCURSOR
         'FormReport.Show 1
         'Unload FormReport
         'Set FormReport = Nothing
         '-----------------------------
         
         ''Set crxRpt = Nothing
         ''Set crxApp = Nothing
         On Error GoTo 0
      Else
         strRTFLayout = strReportName
         strContext = "StockTake"
         GetRTFTextFromDB dispdata$ & "\" & strRTFLayout, strRTFTxt, intSuccess '07Jan17 TH Moved here to ensure check (TFS 157969)
         'If fileexists(dispdata$ & "\" & strRTFLayout) Then
         If intSuccess Then
            'GetTextFile dispdata$ & "\" & strRTFLayout, strRTFTxt, 0
            'GetRTFTextFromDB dispdata$ & "\" & strRTFLayout, strRTFTxt, 0 '06Dec16 TH Replaced (TFS 157969)
            SplitFile strRTFTxt, strPgHdr, strPgItem, strPgEnd
            MakeLocalFile strTmpFile                                                  'Tmp file used to
            intTmpFileNo = FreeFile                                                   'build report
            Open strTmpFile For Binary Access Write Lock Read Write As intTmpFileNo
            
            'Header Info
            'FillHeapSupplierInfo gPRNheapID, sup, success
            Heap 10, gPRNheapID, "SiteNumber", Trim$(GetField(rs!SiteNumber)), 0    '22Sep05 TH Added
            Heap 10, gPRNheapID, "StockTakeName", Trim$(GetField(rs!StockTakeName)), 0
               
            ParseItems gPRNheapID, strPgHdr, 0
            Put intTmpFileNo, , strPgHdr
            Do While Not rs.EOF
               'Put relevant info on the heap
               'Heap 10, gPRNheapID, "iDescription", Trim$(temp$), 0
               Heap 10, gPRNheapID, "NSVCode", Trim$(GetField(rs!NSVCode)), 0    '22Sep05 TH Added
               Heap 10, gPRNheapID, "Description", Trim$(GetField(rs!Description)), 0
               Heap 10, gPRNheapID, "SystemLevel", Trim$(GetField(rs!SystemLevel)), 0  '18Aug04 TH DIscharge interface
               Heap 10, gPRNheapID, "StockLevel", Trim$(GetField(rs!StockLevel)), 0
               dblDifference = dp!(Val(GetField(rs!SystemLevel)) - Val(GetField(rs!StockLevel)))
               Heap 10, gPRNheapID, "Difference", Format$(dblDifference), 0
               
               Heap 10, gPRNheapID, "PackSize", Trim$(GetField(rs!PackSize)), 0
               Heap 10, gPRNheapID, "IssuePrice", Trim$(GetField(rs!issueprice)), 0
               Heap 10, gPRNheapID, "IssueUnits", Trim$(GetField(rs!IssueUnits)), 0
               Heap 10, gPRNheapID, "Location1", Trim$(GetField(rs!Location1)), 0
               Heap 10, gPRNheapID, "Location2", Trim$(GetField(rs!Location2)), 0
               Heap 10, gPRNheapID, "StockLevel1", Trim$(GetField(rs!StockLevel1)), 0
               Heap 10, gPRNheapID, "StockLevel2", Trim$(GetField(rs!StockLevel2)), 0
               'Heap 10, gPRNheapID, "Notes", Trim$(GetField(rs!Notes)), 0
               BlankWProduct dlocal
               dlocal.SisCode = Trim$(GetField(rs!NSVCode))
               getdrug dlocal, 0, 0, False
               FillHeapDrugInfo gPRNheapID, dlocal, 0
               strDetailLine = strPgItem
               ParseItems gPRNheapID, strDetailLine, 0
               Put intTmpFileNo, , strDetailLine

            
               rs.MoveNext
            Loop
            'If we need a footer put parsable elements here
            ParseItems gPRNheapID, strPgEnd, 0
         
            Put intTmpFileNo, , strPgEnd
            
            'Print and cleanup
            Close intTmpFileNo
            'ParseThenPrint strContext, strTmpFile, 1, 0, False '03Jul11 TH Added param
            ParseThenPrint strContext, strTmpFile, 1, 0, False, True '08Jan17 TH Added param (Hosted) (TFS 157969)
            On Error Resume Next
            Kill strTmpFile
            On Error GoTo 0
         End If
      End If
   End If
Exit Sub

PrintListErr:
   popmessagecr ".Print Error", Error$
Resume Next

End Sub

Private Sub lvwMainScreen_DblClick()

Dim intloop As Integer

   If mnuStockTake(5).Checked Then              'Authorise stock level
         ''lngRow = LvwMainScreen.RowIndex
         For intloop = 1 To lvwMainScreen.ListItems.count
            If lvwMainScreen.ListItems(intloop).Selected = True Then
               'intLoop = LvwMainScreen.SelectedItem.Index
               If intloop Then                           'Authorise changes here
                  'StockTakeAdjustLevel SiteCode$, STname$, stnsv(intloop), "", intloop
                  StockTakeAdjustLevel STname$, stnsv(intloop), "", intloop         '29Jan13 CKJ Removed SiteCode
                  
                  ''LvwMainScreen.RefreshRow = 0
                  lvwMainScreen_RowChange intloop
               End If
            End If
         Next
      End If

End Sub

Private Sub lvwMainScreen_KeyDown(KeyCode As Integer, Shift As Integer)
Dim lngRow As Long
Dim intloop As Integer

   Select Case KeyCode
      Case 13
         k.escd = 0
         If mnuStockTake(5).Checked Then              'Authorise stock level
            ''lngRow = LvwMainScreen.RowIndex
            For intloop = 1 To lvwMainScreen.ListItems.count
               If lvwMainScreen.ListItems(intloop).Selected = True Then
                  'intLoop = LvwMainScreen.SelectedItem.Index
                  If intloop Then                           'Authorise changes here
                     'StockTakeAdjustLevel SiteCode$, STname$, stnsv(intloop), "", intloop
                     StockTakeAdjustLevel STname$, stnsv(intloop), "", intloop         '29Jan13 CKJ Removed SiteCode
                     
                     ''LvwMainScreen.RefreshRow = 0
                     lvwMainScreen_RowChange intloop
                     If k.escd Then Exit For
                  End If
               End If
            Next
         End If
         KeyCode = 0
         k.escd = 0
      
'22Jan13 CKJ Removed because as written this does nothing useful & cursor keys are handled elewhere
'      Case 38
'         If Me.LvwMainScreen.SelectedItem.Index > 0 Then '''1 Then
'            'Me.LvwMainScreen.ListItems(Me.LvwMainScreen.SelectedItem.Index).selected = False
'            ''lngRow = Me.LvwMainScreen.SelectedItem.Index - 1
'            lngRow = Me.LvwMainScreen.SelectedItem.Index
'            ''Me.LvwMainScreen.ListItems(Me.LvwMainScreen.SelectedItem.Index).selected = False ''''
'            LvwMainScreen.SetFocus
'            'Me.LvwMainScreen.ListItems(lngRow).selected = True
'            lvwMainScreen_RowChange (lngRow)
'            ''If GetMStockTakeMode = 1 Then txtStockLvl1.SetFocus
'         End If
'
'      Case 40
'         ''If Me.LvwMainScreen.SelectedItem.Index < Me.LvwMainScreen.ListItems.count Then
'         If Me.LvwMainScreen.SelectedItem.Index <= Me.LvwMainScreen.ListItems.count Then
'            ''lngRow = Me.LvwMainScreen.SelectedItem.Index + 1
'            '''Me.LvwMainScreen.ListItems(Me.LvwMainScreen.SelectedItem.Index).selected = False ''''
'            lngRow = Me.LvwMainScreen.SelectedItem.Index
'            LvwMainScreen.SetFocus
'            lvwMainScreen_RowChange (lngRow)
'         End If
      
   End Select
End Sub

Private Sub lvwMainScreen_KeyPress(KeyAscii As Integer)
'30Oct00 AW  Changed code to allow stocktake to be shown in packs

''Dim row&
''Dim num1%, num2%     '30Oct00 AW added
''   'If strstockinpacks$ = "Y" Then     '30Oct00 AW added
''   If intStockInPacks = True Then     '01Sep01 TH Replaced
''        num1 = 5                      '        "
''        num2 = 7                      '        "
''    Else                              '        "
''        num1 = 7                      '        "
''        num2 = 9                      '        "
''    End If                            '        "
''
''   Select Case KeyAscii
''      Case 13
''         KeyAscii = 0
''         If mnuStockTake(4).Checked Then              'enter stock level
''               Select Case lvwMainScreen.ColumnIndex
''                  Case num1, num2                       '30Oct00 AW changed
''                  'Case 7, 9     'was 4
''                     lvwMainScreen.EditActive = Not (lvwMainScreen.EditActive)
''                  End Select
''            End If
''
''         If mnuStockTake(5).Checked Then              'Authorise stock level
''               row& = lvwMainScreen.RowIndex
''               If row& Then                           'Authorise changes here
''                     StockTakeAdjustLevel SiteCode$, STname$, stnsv(row&), ""
''                     lvwMainScreen.RefreshRow = 0
''                     lvwMainScreen_RowChange
''                  End If
''            End If
''      End Select
''Case 38 'Cursor Up
''
''                     If Me.LvwMainScreen.SelectedItem.Index > 1 Then
''                        'ReDim lines$(9)
''                        'deflines OInfoStore(lvwMainScreen.SelectedItem.Index - 1), lines$(), "|(*)", 1, 0
''                                    'Unselect previous
''
''                        ''intIndex = Me.LvwMainScreen.SelectedItem.Index
''                        lvwMainScreen_RowChange
''                        End If
      If GetMStockTakeMode() = 1 Then
         'If the status of this line is not authorised
         If lvwMainScreen.SelectedItem.SubItems(lvwMainScreen.SelectedItem.ListSubItems.count) <> "A" Then
            If KeyAscii > 47 And KeyAscii < 58 Or KeyAscii = 46 Then
               'txtStockLvl1.SetFocus
               blnChangeFlag = True
               txtStockLvl1.text = Chr(KeyAscii)
               KeyAscii = 0 'Stop beep
               On Error Resume Next
               txtStockLvl1.SetFocus
               On Error GoTo 0
            End If
         End If
      End If
''   End Select
End Sub

Private Sub lvwMainScreen_KeyUp(KeyCode As Integer, Shift As Integer)
Dim lngRow As Long
   Select Case KeyCode
   
      Case 13
         KeyCode = 0
         
      Case 38  'cursor up
         If lvwMainScreen.SelectedItem.Index >= 1 Then
            'Me.LvwMainScreen.ListItems(Me.LvwMainScreen.SelectedItem.Index).selected = False
            ''lngRow = Me.LvwMainScreen.SelectedItem.Index - 1
            lngRow = lvwMainScreen.SelectedItem.Index
            ''Me.LvwMainScreen.ListItems(Me.LvwMainScreen.SelectedItem.Index).selected = False ''''
            lvwMainScreen.SetFocus
            'Me.LvwMainScreen.ListItems(lngRow).selected = True
            lvwMainScreen_RowChange (lngRow)
            ''If GetMStockTakeMode = 1 Then txtStockLvl1.SetFocus
         End If
      
      Case 40  'cursor down
         If lvwMainScreen.SelectedItem.Index <= lvwMainScreen.ListItems.count Then
            ''lngRow = Me.LvwMainScreen.SelectedItem.Index + 1
            '''Me.LvwMainScreen.ListItems(Me.LvwMainScreen.SelectedItem.Index).selected = False ''''
            lngRow = lvwMainScreen.SelectedItem.Index
            lvwMainScreen.SetFocus
            lvwMainScreen_RowChange (lngRow)
         End If
         
      Case 33 'PgUp
         If lvwMainScreen.ListItems.count > 0 Then
            If lvwMainScreen.SelectedItem.Index - OInfoMaxLen >= 1 Then
               lvwMainScreen.ListItems(lvwMainScreen.SelectedItem.Index - OInfoMaxLen).Selected = True
               'lvwMainScreen.ListItems(lvwMainScreen.SelectedItem.Index - OInfoMaxLen).EnsureVisible
               lvwMainScreen.ListItems(lvwMainScreen.SelectedItem.Index).EnsureVisible   '28Apr06 TH Replaced above line
               lngRow = lvwMainScreen.SelectedItem.Index
               lvwMainScreen.SetFocus
               lvwMainScreen_RowChange (lngRow)
               
            Else
               lvwMainScreen.ListItems(1).Selected = True
               lvwMainScreen.ListItems(1).EnsureVisible
               lngRow = lvwMainScreen.SelectedItem.Index
               lvwMainScreen.SetFocus
               lvwMainScreen_RowChange (lngRow)
            End If
         Else
            lvwMainScreen.SelectedItem.Index = 0
         End If
         
      Case 34 'PgDn
         If lvwMainScreen.ListItems.count > 0 Then
            If lvwMainScreen.SelectedItem.Index + OInfoMaxLen > lvwMainScreen.ListItems.count Then
               'If blnRetainPosition Then ListIndex = LvwMainScreen.SelectedItem.Index
               'If blnRetainPosition Then
               '   If ListIndex + 1 < LvwMainScreen.ListItems.count Then
               '      LvwMainScreen.ListItems(1).selected = False
               '      LvwMainScreen.ListItems(ListIndex).selected = False
               '      LvwMainScreen.ListItems(ListIndex + 1).selected = True
               '      LvwMainScreen.ListItems(ListIndex + 1).EnsureVisible
               '   Else
               '      LvwMainScreen.ListItems(1).selected = False
               '      LvwMainScreen.ListItems(ListIndex).selected = False
               '      LvwMainScreen.ListItems(LvwMainScreen.ListItems.count).selected = True
               '      LvwMainScreen.ListItems(LvwMainScreen.ListItems.count).EnsureVisible
               '   End If
               'Else
               If lvwMainScreen.SelectedItem.Index + OInfoMaxLen > lvwMainScreen.ListItems.count Then
                  lvwMainScreen.ListItems(1).Selected = False
                  lvwMainScreen.ListItems(lvwMainScreen.ListItems.count).Selected = True
                  lvwMainScreen.ListItems(lvwMainScreen.ListItems.count).EnsureVisible
               Else
                  lvwMainScreen.ListItems(1).Selected = False
                  lvwMainScreen.ListItems(lvwMainScreen.ListItems.count).Selected = True
                  lvwMainScreen.ListItems(lvwMainScreen.ListItems.count).EnsureVisible
               End If
               'End If
            Else
               'If blnRetainPosition Then
               '   If ListIndex + 1 < LvwMainScreen.ListItems.count Then
               '      LvwMainScreen.ListItems(1).selected = False
               '      LvwMainScreen.ListItems(ListIndex).selected = False
               '      LvwMainScreen.ListItems(ListIndex + 1).selected = True
               '      LvwMainScreen.ListItems(ListIndex + 1).EnsureVisible
               '   Else
               lvwMainScreen.ListItems(1).Selected = False
               lvwMainScreen.ListItems(1).Selected = False
               lvwMainScreen.ListItems(lvwMainScreen.ListItems.count).Selected = True
               lvwMainScreen.ListItems(lvwMainScreen.ListItems.count).EnsureVisible
               '   End If
            End If
         Else
             lvwMainScreen.SelectedItem.Index = 0
         
         End If
         lngRow = lvwMainScreen.SelectedItem.Index
         lvwMainScreen.SetFocus
         lvwMainScreen_RowChange (lngRow)
      Case Else
   End Select

''   Select Case KeyCode
''      Case 35 'end
''         KeyCode = 0
''         Select Case Shift
''            Case 0: lvwMainScreen.RowIndex = lvwMainScreen.Rows  'no shift
''            End Select
''      Case 36 'home
''         KeyCode = 0
''         Select Case Shift
''            Case 0: lvwMainScreen.RowIndex = 1                'no shift
''            End Select
''      End Select

End Sub

Private Sub lvwMainScreen_RowChange(ByVal lngNewRow As Long)
'

Static lngRow As Long

Dim default As String
Dim strParams As String
Dim rsStockTake As ADODB.Recordset

   If lngNewRow = 0 Then
      lngRow = 0
      Exit Sub                         '<== WAY OUT
   End If
   
   ''If lngRow <> Me.LvwMainScreen.SelectedItem.Index Then
   If blnChangeFlag Then UpdateStockLevels
   
   'If lngRow <> lngNewRow Then                             '19Mar07 CKJ removed - info needs refreshing even if line has focus
      
   ''lngRow = Me.LvwMainScreen.SelectedItem.Index
   lngRow = lngNewRow
   picFooter.Cls
   If m_BusyInRobot Then
      default$ = crlf & "    <Click> here to interrupt robot enquiry"
   Else
      default$ = crlf & "    <Click> here or press Ctrl-N to enter Notes..."
   End If
   
   txtNotes.text = default$
   If lngRow Then
''      criteria$ = " WHERE SiteNumber = '" & SiteCode$ & "' AND StockTakeName = '" & STname$ & "'"
''      SQL$ = "SELECT * FROM StockTake" & criteria$ & " AND NSVCode = '" & stnsv(row&) & "';"

'29Jan13 CKJ Removed SiteCode
'      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
'                  gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
'                  gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$) & _
'                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, stnsv(lngRow))
      strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
                  gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, STNAMELEN, STname$) & _
                  gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, stnsv(lngRow))
      Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakeSelectForLine", strParams)
      If Not rsStockTake Is Nothing Then     'use returned recordset
         If rsStockTake.State = adStateOpen Then
            If rsStockTake.RecordCount <> 0 Then
               If Not rsStockTake.EOF Then
                  picFooter.FontBold = False
                  picFooter.Print " "; GetField(rsStockTake!Description);
         
                  picFooter.FontBold = True
                  picFooter.Print Tab(70); " Type: ";
                  picFooter.FontBold = False
                  picFooter.Print Iff(GetField(rsStockTake!ClosedStockTake), "Closed", "Open");

                  If Not GetField(rsStockTake!ClosedStockTake) Or mnuStockTake(5).Checked Then    'hidden unless authorising
                     picFooter.FontBold = True
                     picFooter.Print "   Issue Price: ";
                     picFooter.FontBold = False
                     picFooter.Print money(5); Format$(GetField(rsStockTake!issueprice), "0.00##");
                  End If
                  picFooter.Print
         
                  picFooter.FontBold = True
                  picFooter.Print " Created by: ";
                  picFooter.FontBold = False
                  picFooter.Print GetField(rsStockTake!CreatedUser); "  "; Format$(GetField(rsStockTake!createddate), "dd mmm yyyy hh:mm "); " ("; GetField(rsStockTake!createdterminal); ")"
         
                  If GetField(rsStockTake!status) >= "1" Then
                     picFooter.FontBold = True
                     picFooter.Print " Modified by: ";
                     picFooter.FontBold = False
                     picFooter.Print GetField(rsStockTake!modifieduser); "  "; Format$(GetField(rsStockTake!modifieddate), "dd mmm yyyy hh:mm "); " ("; GetField(rsStockTake!modifiedterminal); ")"
                  End If
         
                  If GetField(rsStockTake!status) = "2" Then
                     picFooter.FontBold = True
                     picFooter.Print " Authorised by: ";
                     picFooter.FontBold = False
                     picFooter.Print GetField(rsStockTake!AuthorisedUser); "  "; Format$(GetField(rsStockTake!AuthorisedDate), "dd mmm yyyy hh:mm "); " ("; GetField(rsStockTake!AuthorisedTerminal); ")"
         
                     picFooter.FontBold = True
                     picFooter.Print " Stock adjustment: ";
                     picFooter.FontBold = False
                     picFooter.Print GetField(rsStockTake!AuthorisedChange); " "; GetField(rsStockTake!IssueUnits)
                     If RtrimGetField(rsStockTake!ReasonCode) <> "" Then
                        picFooter.FontBold = True
                        picFooter.Print " Reason : ";
                        picFooter.FontBold = False
                        picFooter.Print GetField(rsStockTake!ReasonCode); " "; GetField(rsStockTake!Value)
''                           picFooter.FontBold = True
''                           picFooter.Print " : ";
''                           picFooter.FontBold = False
''                           picFooter.Print GetField(rsStockTake!AuthorisedChange); " "; GetField(rsStockTake!IssueUnits)
                     End If
                     StockTake.txtStockLvl1.Enabled = False
                     StockTake.txtStockLvl2.Enabled = False
                  Else
                     StockTake.txtStockLvl1.Enabled = True
                     StockTake.txtStockLvl2.Enabled = True
                  End If
         
                  If m_BusyInRobot Then
                     txtNotes.text = txtNotes.text & crlf & crlf & GetField(rsStockTake!notes)
                  Else
                     txtNotes.text = GetField(rsStockTake!notes)
                     If txtNotes.text = "" Then
                        '05Mar07 CKJ Ported block from V8.6  '16oct06 CKJ extra prompt if robot item
                        If lngRow > 0 And mnuStockTake(4).Checked Then              'row selected and entering stock level
                           ''If intStockInPacks Then Col = 5 Else Col = 7           'for primary stock location only 'V9: no column in focus
                           ''If tbldisplay.ColumnIndex = Col Then                   'V9: no column in focus
                           ''TblDisplayFetch SiteCode$, STname$, stnsv$(Row&), Col - 1, mnuStockTake(5).Checked, strLocn
                        
                           If TerminalForMechDisp(Trim$(GetField(rsStockTake!Location1))) Then
                              default$ = default$ & crlf & "    Press [F4] for robot stock level"
                           End If
                           ''End If                                                 'V9: no column in focus
                        End If
   
                        txtNotes.text = default$
                     End If
                  End If
                  
                  ''If GetMStockTakeMode() = 1 Or GetMStockTakeMode() = 2 Then
                  LblTotal.Caption = GetField(rsStockTake!StockLevel)
                  txtStockLvl1.text = GetField(rsStockTake!StockLevel1)
                  txtStockLvl2.text = GetField(rsStockTake!StockLevel2)
                  lblSysLevel.Caption = Iff(GetField(rsStockTake!ClosedStockTake), "Closed", Format$(GetField(rsStockTake!SystemLevel)))
                  lblLocation1.Caption = "Location 1   " & Iff(Trim$(GetField(rsStockTake!Location1)) <> "", "(" & Trim$(GetField(rsStockTake!Location1)) & ")", "")
                  lblLocation2.Caption = "Location 2   " & Iff(Trim$(GetField(rsStockTake!Location2)) <> "", "(" & Trim$(GetField(rsStockTake!Location2)) & ")", "")
                  lblExtraInfo.Caption = Trim$(GetField(rsStockTake!Description)) & Iff(Len(Trim$(GetField(rsStockTake!Description))) > 48, "  ", crlf) & GetField(rsStockTake!PackSize) & " " & GetField(rsStockTake!IssueUnits)
                  ''End If
               End If
            End If
         End If
      End If
      ''' GetMStockTakeMode = 1 Then txtStockLvl1.SetFocus
      On Error Resume Next
      rsStockTake.Close
      Set rsStockTake = Nothing
      On Error GoTo 0
   End If
   'End If                                   '19Mar07 CKJ

End Sub

'Private Sub lvwMainScreen_Update(Row As Long, Col As Integer, value As String)
'''06Feb98 EAC Col changed from 4 to 6 to take account of new fields in grid
'''17Nov98 TH  In two stock locations added code to calculate total from both locations.
'''            col = 6 was the stocklevel; now loc1,loc2,total
'''16Oct00 AW  Added code to display stocktake in packs
''
''Const procname$ = "lvwMainScreen_Update"
''Dim tempdyn As dynaset
''Dim resumeval%, retries%, SQL$, fieldname$
''Dim criteria$, maxlen%
''
''   'If strstockinpacks = "Y" Then                                '30Oct00 AW added block
''   If intStockInPacks = True Then              '01Sep01 TH Replaced
''            Select Case col                                     '        "
''                Case 5, 7, 8
''                    Select Case col
''                        Case 5: fieldname$ = "StockLevel1"
''                        Case 7: fieldname$ = "StockLevel2"
''                        Case 8: fieldname$ = "StockLevel"
''                      End Select
''                  End Select
''        Else                                                    '        "
''           Select Case col                                      '        "
''              Case 7, 9, 10                                     '        "
''                 Select Case col                                '        "
''                    Case 7:  fieldname$ = "StockLevel1"         '        "
''                    Case 9:  fieldname$ = "StockLevel2"         '        "
''                    Case 10: fieldname$ = "StockLevel"          '        "
''                  End Select                                    '        "
''               End Select                                       '        "
''        End If                                                  '        "
''         criteria$ = " WHERE SiteNumber = '" & SiteCode$ & "' AND StockTakeName = '" & STname$ & "'"
''         SQL$ = "SELECT ModifiedDate, ModifiedUser, ModifiedTerminal, Status, " & fieldname$ & " FROM StockTake" & criteria$ & " AND NSVCode = '" & stnsv(row&) & "';"
''
''         Set tempdyn = WSDB.CreateDynaset(SQL$)
''         maxlen = tempdyn.Fields(fieldname$).size
''         If Len(Trim$(Value$)) > maxlen Then            'Trap for too long
''               popmessagecr "!", "Not updated: Item '" & Value$ & "' would be too long"
''               Value$ = ""
''            End If
''         tempdyn.LockEdits = False
''         tempdyn.Edit
''         tempdyn.Fields(fieldname$) = Trim$(Value$)
''         tempdyn!modifieddate = Now
''         tempdyn!modifieduser = UserID$
''         tempdyn!modifiedterminal = ASCTerminalNameSQL()
''         tempdyn!status = "1"                           'stock level entered
''         On Error GoTo SUUpdateTableErr
''         tempdyn.Update
''      'End Select
''    'If strstockinpacks = "Y" Then                               '30Oct00 AW added
''    If intStockInPacks = True Then              '01Sep01 TH Replaced
''            If col = 5 Or col = 7 Then lvwMainScreen.ColumnText(8) = Str$(Val(lvwMainScreen.ColumnText(5)) + Val(lvwMainScreen.ColumnText(7)))
''        Else
''            If col = 7 Or col = 9 Then lvwMainScreen.ColumnText(10) = Str$(Val(lvwMainScreen.ColumnText(7)) + Val(lvwMainScreen.ColumnText(9)))
''        End If
''   On Error GoTo 0
''   lvwMainScreen.RefreshRow = row&
''
''   lvwMainScreen_RowChange
''
''Exit Sub
''
''SUUpdateTableErr:
''   resumeval = ProcessUpdateErr(Err, modulename$, procname$, row&, retries)
''
''   Select Case resumeval
''      Case -1: Resume
''      Case 0:  Resume Next
''      Case 1:  TerminateApp
''      End Select
   
'End Sub

'22Jan13 CKJ Commented out as not used
'Private Sub XlvwMainScreen_Validate(Row As Long, Col As Integer, value As String, Cancel As Integer)
''06Feb98 EAC Col changed from 4 to 6 to take account of new fields in grid
''19Jan99 CKJ rewritten
''30Oct00 AW  added code to display stocktake in packs
'
'Dim loopvar%, valid%
'Dim num1%, num2%                    '30Oct00 AW added
'    'If strstockinpacks = "Y" Then                            '30Oct00 AW added block
'    If intStockInPacks = True Then              '01Sep01 TH Replaced
'            num1 = 5                                         '         "
'            num2 = 7                                         '         "
'        Else                                                 '         "
'            num1 = 7                                         '         "
'            num2 = 9                                         '         "
'        End If                                               '         "
'
'   Select Case Col                                           '17Nov98 TH multiplestocklocations
'      Case num1, num2                                        '30Oct00 AW changed
'         valid = True
'         For loopvar = 1 To Len(value$)
'            Select Case Mid$(value$, loopvar, 1)
'               Case "0" To "9"
'               Case "."
'                  If InStr(loopvar + 1, value$, ".") Then valid = False
'               Case Else
'                  valid = False
'               End Select
'            If Not valid Then Exit For
'         Next
'
'         If Not valid Then
'               popmessagecr "#", "Numeric Values only"
'               Cancel = True
'            End If
'      End Select
'
'End Sub

Private Sub txtNotes_Click()

   If m_BusyInRobot Then
      m_CancelRobot = True
   Else
      EditTxtNotes
   End If
End Sub

Sub lvwMainScreenFetchRow(ByVal STname$, ByVal ItemCode$, ByVal lngRow As Long, ByVal Authorising%, rsStockTake As ADODB.Recordset, ByVal blnRemoveLine As Boolean)
'Given Site, StockTake name and drug code, plus column of grid, return the value at that point
'To force closure of the snapshot call TblDisplayFetch "","","",0,""
'30Oct00 AW added code to display stock take in packs
'status=0   no snapshot loaded
'       1   snapshot loaded and will be retained
'       2   snapshot has been loaded temporarily
'23Jan13 CKJ Commented out code which could never be executed.
'            Status has no meaning & rsStockTake is always passed in, ready filled.
'            pWStockTakebySiteNumberandStockTakeandNSVCode can never be called, so dropped from SQL
'29Jan13 CKJ Removed first param; ByVal SiteCode$

'Dim status%
Dim found%
Dim SQL$, criteria$
'Dim colnum%                 '30Oct00 AW added
''Static rsStockTake As adodb.Recordset
Dim strParams As String
Dim Col As Integer
Dim strValue As String
Dim strKey As String
Dim lvwItem       As ListItem
Dim lvwSubItem    As ListSubItem
Dim intColModifier As Integer

'23Jan13 CKJ hangover fom old code - status always 1 or 2 here so this cannot be executed
'            therefore commented out
'   status = 1
'   If SiteCode$ = "" Then                                    'force closure of snapshot
'      status = 2
'   Else
'      If status = 0 Then
'         'Now check the mode .~If we are in edit mode then we may need to save the existing row,
'         'We will certainly need to store the new stock levels incase they change and we need to alter them
'         '(Why - why not just use the grid ???) OK.
'
'         ''criteria$ = " WHERE SiteNumber = '" & SiteCode$ & "' AND StockTakeName = '" & STname$ & "'"
'         ''sql$ = "SELECT * FROM StockTake" & criteria$ & " AND NSVCode = '" & ItemCode$ & "';"
'         strParams = gTransport.CreateInputParameterXML("LocationID_Site", trnDataTypeint, 4, gDispSite) & _
'                     gTransport.CreateInputParameterXML("SiteNumber", trnDataTypeVarChar, 5, SiteCode$) & _
'                     gTransport.CreateInputParameterXML("StockTakeName", trnDataTypeVarChar, 20, gDispSite) & _
'                     gTransport.CreateInputParameterXML("NSVCode", trnDataTypeVarChar, 7, ItemCode$)
'
'         ''Set snap = WSDB.CreateSnapshot(sql$)
'         Set rsStockTake = gTransport.ExecuteSelectSP(g_SessionID, "pWStockTakebySiteNumberandStockTakeandNSVCode", strParams)
'
'         status = Iff(Col = 1, 1, 2)          'If column is 1 then load & retain, otherwise load/use/unload snapshot
'      End If
'
'      If status > 0 Then
         
   If Not rsStockTake.EOF Then
      'If strStockInPacks$ = "Y" Then
      strKey = "R" & CStr(lngRow)
      strValue = GetField(rsStockTake!NSVCode)
      ''If blnNewItem Then
      If blnRemoveLine Then
         ''Set lvwItem = Me.LvwMainScreen.ListItems.Add(, strKey & ":C1", strValue)
         Set lvwItem = lvwMainScreen.ListItems.Item(lngRow)
         '11Jul06 TH Added check for closed Stake
         If intStockInPacks = True Then
            For Col = 2 To 9 - Iff(GetField(rsStockTake!ClosedStockTake), 1, 0) '- 1 'Loop through the columns
               lvwItem.ListSubItems.Remove 1
            Next
         Else
            For Col = 2 To 11 - Iff(GetField(rsStockTake!ClosedStockTake), 1, 0) '- 1 'Loop through the columns
               lvwItem.ListSubItems.Remove 1
            Next
         End If
      Else
         Set lvwItem = lvwMainScreen.ListItems.Add(, strKey & ":C1", strValue)
      End If
      
      If intStockInPacks = True Then     '01Sep01 TH Replaced
         If GetField(rsStockTake!ClosedStockTake) Then
               For Col = 2 To 8
                  Select Case Col
                     Case 1:  strValue = GetField(rsStockTake!NSVCode) ''ItemCode$
                     Case 2:  strValue = GetField(rsStockTake!Description)
                     Case 3:  strValue = GetField(rsStockTake!Location1)                                            '       "
                     Case 4:  If IsNull(rsStockTake!StockLevel1) Then strValue = "" Else strValue = rsStockTake!StockLevel1  '       "
                     Case 5:  strValue = GetField(rsStockTake!Location2)                                            '       "
                     Case 6:  If IsNull(rsStockTake!StockLevel2) Then strValue = "" Else strValue = rsStockTake!StockLevel2  '       "
                     Case 7:                                                                               '       "
                        If IsNull(rsStockTake!StockLevel) Then strValue = "" Else strValue = rsStockTake!StockLevel          '       "
                        'If GetField(rsStockTake!status) = "2" Then strValue = Chr$(160) & strValue                    '       "
                     Case 8:
                        If GetField(rsStockTake!status) = "2" Then
                           strValue = "A"
                        Else
                           strValue = ""
                        End If
                     End Select
                  strValue = Trim$(strValue)
                  lvwItem.ListSubItems.Add , strKey & ":C" & CStr(Col), strValue
               Next
            Else
                For Col = 2 To 9
                  Select Case Col
                     Case 1:  strValue = GetField(rsStockTake!NSVCode) ''ItemCode$
                     Case 2:  strValue = GetField(rsStockTake!Description)
                     Case 3:  strValue = GetField(rsStockTake!SystemLevel)                                         '       "
                     Case 4:  strValue = GetField(rsStockTake!Location1)                                            '       "
                     Case 5:  If IsNull(rsStockTake!StockLevel1) Then strValue = "" Else strValue = rsStockTake!StockLevel1  '       "
                     Case 6:  strValue = GetField(rsStockTake!Location2)                                            '       "
                     Case 7:  If IsNull(rsStockTake!StockLevel2) Then strValue = "" Else strValue = rsStockTake!StockLevel2  '       "
                     Case 8:                                                                               '       "
                        If IsNull(rsStockTake!StockLevel) Then strValue = "" Else strValue = rsStockTake!StockLevel          '       "
                        'If GetField(rsStockTake!status) = "2" Then strValue = Chr$(160) & strValue                    '       "
                     Case 9:
                           If GetField(rsStockTake!status) = "2" Then
                              strValue = "A"
                           Else
                              strValue = ""
                           End If
                  End Select
                  strValue = Trim$(strValue)
                  lvwItem.ListSubItems.Add , strKey & ":C" & CStr(Col), strValue
               Next
            End If
            
      Else
         If GetField(rsStockTake!ClosedStockTake) Then
            For Col = 2 To 10
              Select Case Col
                  Case 1:  strValue = GetField(rsStockTake!NSVCode) ''ItemCode$
                  Case 2:  strValue = GetField(rsStockTake!Description)
                  Case 3:  strValue = GetField(rsStockTake!PackSize)
                  Case 4:  strValue = GetField(rsStockTake!IssueUnits)
                  Case 5:  strValue = GetField(rsStockTake!Location1)
                  Case 6:  If IsNull(rsStockTake!StockLevel1) Then strValue = "" Else strValue = rsStockTake!StockLevel1
                  Case 7:  strValue = GetField(rsStockTake!Location2)
                  Case 8:  If IsNull(rsStockTake!StockLevel2) Then strValue = "" Else strValue = rsStockTake!StockLevel2
                  Case 9:
                     If IsNull(rsStockTake!StockLevel) Then strValue = "" Else strValue = rsStockTake!StockLevel
                     'If GetField(rsStockTake!status) = "2" Then strValue = Chr$(160) & strValue
                  Case 10:
                     If GetField(rsStockTake!status) = "2" Then
                     strValue = "A"
                     Else
                     strValue = ""
                     End If
                  End Select
               strValue = Trim$(strValue)
               lvwItem.ListSubItems.Add , strKey & ":C" & CStr(Col), strValue
            Next
         Else
            For Col = 2 To 11
               Select Case Col
                  Case 1:  strValue = GetField(rsStockTake!NSVCode) ''ItemCode$
                  Case 2:  strValue = GetField(rsStockTake!Description)
                  Case 3:  strValue = GetField(rsStockTake!PackSize)
                  Case 4:  strValue = GetField(rsStockTake!IssueUnits)
                  Case 5
                   '  'If GetField(snap!ClosedStockTake) Then     'and not authorising them '@~@~
                   '  If GetField(snap!ClosedStockTake) And Not Authorising Then      'hidden unless authorising
                   '        Value$ = "-----"
                   '     Else
                           strValue = GetField(rsStockTake!SystemLevel)
                   '     End If
                  Case 6:  strValue = GetField(rsStockTake!Location1)
                  Case 7:  If IsNull(rsStockTake!StockLevel1) Then strValue = "" Else strValue = rsStockTake!StockLevel1
                  Case 8:  strValue = GetField(rsStockTake!Location2)
                  Case 9:  If IsNull(rsStockTake!StockLevel2) Then strValue = "" Else strValue = rsStockTake!StockLevel2
                  Case 10:
                     If IsNull(rsStockTake!StockLevel) Then strValue = "" Else strValue = rsStockTake!StockLevel
                     'If GetField(rsStockTake!status) = "2" Then strValue = Chr$(160) & strValue
                  Case 11:
                     If GetField(rsStockTake!status) = "2" Then
                        strValue = "A"
                     Else
                        strValue = ""
                     End If
                  End Select
               strValue = Trim$(strValue)
               lvwItem.ListSubItems.Add , strKey & ":C" & CStr(Col), strValue
            Next
         End If
      End If
   End If
      
'      End If
'   End If
   'If strStockInPacks = "Y" Then colnum = 8 Else colnum = 10
''   If intStockInPacks = True Then colnum = 8 Else colnum = 10    '01Sep01 TH Replaced above
''   If col = colnum Or status = 2 Then
''         On Error Resume Next
''         rsStockTake.Close
''         Set rsStockTake = Nothing
''         On Error GoTo 0
''         status = 0
''      End If

If blnRemoveLine Then
   lvwMainScreen_RowChange 0
   lvwMainScreen_RowChange lngRow
End If

End Sub

Private Sub txtStockLvl1_Change()

Dim lvwItem       As ListItem
Dim lvwSubItem    As ListSubItem
   
   LblTotal.Caption = Format$(Val(txtStockLvl1.text) + Val(txtStockLvl2.text))
   'Update the Grid ? Yeah might as well
   
   
   If lvwMainScreen.SelectedItem.Index > 0 And blnChangeFlag Then
      'setStockRow lvwMainScreen.SelectedItem.Index  '21Jan13 CKJ Get/SetStockRow looked useful but actually did nothing

      Set lvwItem = lvwMainScreen.ListItems(lvwMainScreen.SelectedItem.Index)
      If Not intStockInPacks Then
         If Not blnViewSystemLevel Then
         Set lvwSubItem = lvwItem.ListSubItems(5)
      Else
         Set lvwSubItem = lvwItem.ListSubItems(6)
         End If
      Else
         If Not blnViewSystemLevel Then
         Set lvwSubItem = lvwItem.ListSubItems(3)
         Else
         Set lvwSubItem = lvwItem.ListSubItems(4)
         End If
      End If
      If Val(txtStockLvl1.text) = 0 And InStr(txtStockLvl1.text, "0") = 0 Then
         lvwSubItem.text = ""
      Else
         lvwSubItem.text = Format$(Val(txtStockLvl1.text))
      End If
      'Store in the type for later saving
      If blnChangeFlag Then StkLine.StockLevel1 = lvwSubItem.text
      Set lvwSubItem = Nothing
      If Not intStockInPacks Then
         If Not blnViewSystemLevel Then
            Set lvwSubItem = lvwItem.ListSubItems(8)
            lvwSubItem.text = Format$(Val(lvwItem.ListSubItems(5).text) + Val(lvwItem.ListSubItems(7).text))
         Else
            Set lvwSubItem = lvwItem.ListSubItems(9)
            lvwSubItem.text = Format$(Val(lvwItem.ListSubItems(6).text) + Val(lvwItem.ListSubItems(8).text))
         End If
      Else
         If Not blnViewSystemLevel Then
            Set lvwSubItem = lvwItem.ListSubItems(6)
            lvwSubItem.text = Format$(Val(lvwItem.ListSubItems(3).text) + Val(lvwItem.ListSubItems(5).text))
         Else
            Set lvwSubItem = lvwItem.ListSubItems(7)
            lvwSubItem.text = Format$(Val(lvwItem.ListSubItems(4).text) + Val(lvwItem.ListSubItems(6).text))
         End If
      End If
      
      If blnChangeFlag Then
         StkLine.NSVCode = stnsv(lvwMainScreen.SelectedItem.Index)
         If Val(txtStockLvl2.text) = 0 And InStr(txtStockLvl2.text, "0") = 0 Then
            StkLine.StockLevel2 = ""
         Else
            StkLine.StockLevel2 = Format$(Val(txtStockLvl2.text))
         End If
         StkLine.StockTotal = lvwSubItem.text
         StkLine.StockTakeName = STname$
      End If
      
      Set lvwSubItem = Nothing
      Set lvwItem = Nothing
         
   End If
   
End Sub

Private Sub txtStockLvl1_GotFocus()
   txtStockLvl1.SelStart = Len(txtStockLvl1.text)
End Sub

Private Sub txtStockLvl1_KeyDown(KeyCode As Integer, Shift As Integer)
Dim intline

   blnChangeFlag = True
   
   Select Case KeyCode
      Case 38 'cursor up
         If Shift = 0 Then
            If lvwMainScreen.ListItems.count > 0 Then
               If lvwMainScreen.SelectedItem.Index > 1 Then
                  intline = lvwMainScreen.SelectedItem.Index
                  lvwMainScreen.ListItems(intline).Selected = False
                  lvwMainScreen.ListItems(intline - 1).Selected = True
               End If
               If blnChangeFlag And (GetMStockTakeMode() = 1) Then UpdateStockLevels
               lvwMainScreen_KeyDown KeyCode, Shift
               lvwMainScreen.SetFocus
            End If
         End If
      
      Case 40 'cursor down
         If Shift = 0 Then
            ''LvwMainScreen.SetFocus
            If lvwMainScreen.ListItems.count > 0 Then
               If lvwMainScreen.SelectedItem.Index < lvwMainScreen.ListItems.count Then
                  intline = lvwMainScreen.SelectedItem.Index
                  lvwMainScreen.ListItems(intline).Selected = False
                  lvwMainScreen.ListItems(intline + 1).Selected = True
               End If
               If blnChangeFlag And (GetMStockTakeMode() = 1) Then UpdateStockLevels
               lvwMainScreen_KeyDown KeyCode, Shift
               lvwMainScreen.SetFocus
            End If
         End If
      Case Else
      
   End Select
   ''''txtStockLvl1.SetFocus
End Sub

Private Sub txtStockLvl1_KeyPress(KeyAscii As Integer)
'Primitive masking added
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
  
End Sub

Private Sub txtStockLvl1_LostFocus()
   If blnChangeFlag Then UpdateStockLevels
End Sub

Private Sub txtStockLvl2_Change()

Dim lvwItem       As ListItem
Dim lvwSubItem    As ListSubItem

   'set the row flag for later DB update
   If lvwMainScreen.SelectedItem.Index > 0 Then
      
   
      LblTotal.Caption = Format$(Val(txtStockLvl1.text) + Val(txtStockLvl2.text))
      'Update the Grid ? Yeah might as well
      
      Set lvwItem = lvwMainScreen.ListItems(lvwMainScreen.SelectedItem.Index)
      If Not intStockInPacks Then
         If Not blnViewSystemLevel Then
            Set lvwSubItem = lvwItem.ListSubItems(7)
         Else
            Set lvwSubItem = lvwItem.ListSubItems(8)
         End If
      Else
         If Not blnViewSystemLevel Then
            Set lvwSubItem = lvwItem.ListSubItems(5)
         Else
            Set lvwSubItem = lvwItem.ListSubItems(6)
         End If
      End If
      If Val(txtStockLvl2.text) = 0 And InStr(txtStockLvl2.text, "0") = 0 Then
         lvwSubItem.text = ""
      Else
         lvwSubItem.text = Format$(Val(txtStockLvl2.text))
      End If
      'Store in the type for later saving
      ''If blnChangeFlag Then StkLine.StockLevel2 = lvwSubItem.Text
      Set lvwSubItem = Nothing
      If Not intStockInPacks Then
         If Not blnViewSystemLevel Then
            Set lvwSubItem = lvwItem.ListSubItems(8)
            If Val(lvwSubItem.text) <> (Val(lvwItem.ListSubItems(5).text) + Val(lvwItem.ListSubItems(7).text)) Then
               'setStockRow lvwMainScreen.SelectedItem.Index  '21Jan13 CKJ Get/SetStockRow looked useful but actually did nothing
               lvwSubItem.text = Format$(Val(lvwItem.ListSubItems(5).text) + Val(lvwItem.ListSubItems(7).text))
            End If
         Else
            Set lvwSubItem = lvwItem.ListSubItems(9)
            If Val(lvwSubItem.text) <> (Val(lvwItem.ListSubItems(6).text) + Val(lvwItem.ListSubItems(8).text)) Then
               'setStockRow lvwMainScreen.SelectedItem.Index  '21Jan13 CKJ Get/SetStockRow looked useful but actually did nothing
               lvwSubItem.text = Format$(Val(lvwItem.ListSubItems(6).text) + Val(lvwItem.ListSubItems(8).text))
            End If
         End If
      Else
         If Not blnViewSystemLevel Then
            Set lvwSubItem = lvwItem.ListSubItems(6)
            If Val(lvwSubItem.text) <> (Val(lvwItem.ListSubItems(5).text) + Val(lvwItem.ListSubItems(7).text)) Then
               'setStockRow lvwMainScreen.SelectedItem.Index  '21Jan13 CKJ Get/SetStockRow looked useful but actually did nothing
               lvwSubItem.text = Format$(Val(lvwItem.ListSubItems(3).text) + Val(lvwItem.ListSubItems(5).text))
            End If
         Else
            Set lvwSubItem = lvwItem.ListSubItems(7)
            If Val(lvwSubItem.text) <> (Val(lvwItem.ListSubItems(6).text) + Val(lvwItem.ListSubItems(8).text)) Then
               'setStockRow lvwMainScreen.SelectedItem.Index  '21Jan13 CKJ Get/SetStockRow looked useful but actually did nothing
               lvwSubItem.text = Format$(Val(lvwItem.ListSubItems(4).text) + Val(lvwItem.ListSubItems(6).text))
            End If
         End If
      End If
      
      If blnChangeFlag Then
         StkLine.NSVCode = stnsv(lvwMainScreen.SelectedItem.Index)
         If Val(txtStockLvl1.text) = 0 And InStr(txtStockLvl1.text, "0") = 0 Then
            StkLine.StockLevel1 = ""
         Else
            StkLine.StockLevel1 = Format$(Val(txtStockLvl1.text))
         End If
         If Val(txtStockLvl2.text) = 0 And InStr(txtStockLvl2.text, "0") = 0 Then
            StkLine.StockLevel2 = ""
         Else
            StkLine.StockLevel2 = Format$(Val(txtStockLvl2.text))
         End If
         StkLine.StockTotal = lvwSubItem.text
         StkLine.StockTakeName = STname$
      End If
      
      Set lvwSubItem = Nothing
      Set lvwItem = Nothing
      
   End If
End Sub

Private Sub txtStockLvl2_GotFocus()
'18Oct05 TH Added (#83827)

   txtStockLvl2.SelStart = 0
   txtStockLvl2.SelLength = Len(txtStockLvl2.text)
    
End Sub

Private Sub txtStockLvl2_KeyDown(KeyCode As Integer, Shift As Integer)
Dim intline

   blnChangeFlag = True
   
   Select Case KeyCode
   Case 38 'cursor up
      If Shift = 0 Then
         ''LvwMainScreen.SetFocus
         If lvwMainScreen.ListItems.count > 0 Then
                  If lvwMainScreen.SelectedItem.Index > 1 Then
                     intline = lvwMainScreen.SelectedItem.Index
                     lvwMainScreen.ListItems(intline).Selected = False
                     lvwMainScreen.ListItems(intline - 1).Selected = True
                     
                  End If
         lvwMainScreen_KeyDown KeyCode, Shift
         lvwMainScreen.SetFocus
         End If
      End If
   Case 40 'cursor down
      If Shift = 0 Then
         If lvwMainScreen.ListItems.count > 0 Then
            If lvwMainScreen.SelectedItem.Index < lvwMainScreen.ListItems.count Then
               intline = lvwMainScreen.SelectedItem.Index
               lvwMainScreen.ListItems(intline).Selected = False
               lvwMainScreen.ListItems(intline + 1).Selected = True
            End If
            lvwMainScreen_KeyDown KeyCode, Shift
            lvwMainScreen.SetFocus
         End If
      End If
   End Select
   
End Sub

Private Sub txtStockLvl2_KeyPress(KeyAscii As Integer)
'Primitive masking added
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58)) Then KeyAscii = 0
End Sub

Private Sub txtStockLvl2_LostFocus()
   If blnChangeFlag Then UpdateStockLevels
End Sub

Public Sub redrawgrid(ByVal blnClosed As Boolean)

Dim X As Integer
Dim found%  '25Aug99 TH
Dim tempnum%
Const intWidthMultiplier = 110 '80

   blnViewSystemLevel = Not (blnClosed)
   
   lvwMainScreen.ColumnHeaders.Clear
   lvwMainScreen.ListItems.Clear
   lvwMainScreen.Refresh
   
   ''Me.lblHeading Unload
   lvwMainScreen.ColumnHeaders.Add , "H:1", "Code", (10 * intWidthMultiplier)
   lvwMainScreen.ColumnHeaders.Add , "H:2", "Description", (45 * intWidthMultiplier)
   If intStockInPacks = True Then
       If blnClosed Then
         lvwMainScreen.ColumnHeaders.Add , "H:3", "Locn" & crlf & "1", (6 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:4", "Stock Level" & crlf & "1", (9 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:5", "Locn" & crlf & "2", (6 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:6", "Stock Level" & crlf & "2", (9 * intWidthMultiplier)
            lvwMainScreen.ColumnHeaders.Add, "H:7", "Stock Level" & crlf & "Total", (29 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:8", "Status", (7 * intWidthMultiplier)
         tempnum% = 8
       Else
         lvwMainScreen.ColumnHeaders.Add , "H:3", "System" & crlf & "Level", (9 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:4", "Locn" & crlf & "1", (5 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:5", "Stock Level" & crlf & "1", (9 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:6", "Locn" & crlf & "2", (5 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:7", "Stock Level" & crlf & "2", (9 * intWidthMultiplier)
            lvwMainScreen.ColumnHeaders.Add, "H:8", "Stock Level" & crlf & "Total", (23 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:9", "Status", (6 * intWidthMultiplier)
         tempnum% = 9                                                   '        "
         End If
   Else
      If blnClosed Then
         lvwMainScreen.ColumnHeaders.Add , "H:3", "Pack" & crlf & "Size", (8 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:4", "Issue" & crlf & "Units", (8 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:5", "Locn" & crlf & "1", (6 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:6", "Stock Level" & crlf & "1", (10 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:7", "Locn" & crlf & "2", (6 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:8", "Stock Level" & crlf & "2", (10 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:9", "Stock Level" & crlf & "Total", (10 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:10", "Status", (8 * intWidthMultiplier)
         tempnum% = 10
      Else
         lvwMainScreen.ColumnHeaders.Add , "H:3", "Pack" & crlf & "Size", (7 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:4", "Issue" & crlf & "Units", (7 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:5", "System" & crlf & "Level", (9 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:6", "Locn" & crlf & "1", (5 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:7", "Stock Level" & crlf & "1", (9 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:8", "Locn" & crlf & "2", (5 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:9", "Stock Level" & crlf & "2", (9 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:10", "Stock Level" & crlf & "Total", (9 * intWidthMultiplier)
         lvwMainScreen.ColumnHeaders.Add , "H:11", "Status", (6 * intWidthMultiplier)
         tempnum% = 11
      End If
   End If                                                            '16Oct00 AW changed
   HeaderDisplay Me, lvwMainScreen, Remove, 10
   HeaderDisplay Me, lvwMainScreen, Create, 10
   ''Exit Sub
   For X = 1 To tempnum%                                                  '     "     added
      If intStockInPacks = True Then
         If blnClosed Then
            Select Case X
               Case 3, 4, 6: lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnCenter '' = 1 + 8192 + &H20  'Centered, readonly, centred heading
               ''Case 4, 6:           LvwMainScreen.ColumnHeaders(x).Alignment = lvwColumnRight
               Case 1, 2, 5, 7:        lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnLeft
            End Select
         Else
            Select Case X
               Case 3, 4, 5, 7: lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnCenter '' = 1 + 8192 + &H20  'Centered, readonly, centred heading
               ''Case 5, 7:           LvwMainScreen.ColumnHeaders(x).Alignment = lvwColumnRight
               Case 1, 2, 6, 8:        lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnLeft
            End Select
         End If
      Else
         If blnClosed Then
            Select Case X
               Case 1, 5, 7, 9, 2:
                  lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnLeft ''lvwColumnCenter
               Case 4, 6, 8, 3:
                  lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnCenter
               
            End Select
         Else
            Select Case X
               Case 1, 5, 6, 8, 10, 2:
                  lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnLeft ''lvwColumnCenter
               Case 4, 7, 9, 3:
                  lvwMainScreen.ColumnHeaders(X).Alignment = lvwColumnCenter
''               Case 3:
''                  LvwMainScreen.ColumnHeaders(x).Alignment = lvwColumnRight
            End Select
         End If
      End If
   Next
Exit Sub

'22Jan13 CKJ Commented out as code is not reachable
'   ''LvwMainScreen.SelectedBackColor = QBColor(7)
'   LvwMainScreen.GridLines = True
'   LvwMainScreen.Refresh
'   ''LvwMainScreen.SelectMode = 0
'   ''LvwMainScreen.MarqueeStyle = 3
'
'   ''LvwMainScreen.ParamBackColor = QBColor(7) ' Grey
'   ''LvwMainScreen.ParamStatus = -1            ' Apply to all cells
'   'If strstockinpacks$ = "Y" Then
''''   If intStockInPacks = True Then  '01Sep01 TH Replaced  SQL ?????
''''      LvwMainScreen.ColumnAddRegexAttr(8) = "^" & Chr$(160)
''''   Else
''''      LvwMainScreen.ColumnAddRegexAttr(10) = "^" & Chr$(160)
''''   End If
'   LvwMainScreen.GridLines = True
'   SetTextBoxReadOnly txtNotes, True
'   ''LvwMainScreen.Width = LvwMainScreen.Width + 20
'   HeaderDisplay Me, Me.LvwMainScreen, Remove, 10
'   HeaderDisplay Me, Me.LvwMainScreen, Create, 10
End Sub

Sub StockTakeMechDispEnquiry()
'16oct06 CKJ If robot item and editing primary stock location then do stock enquiry
'            (if terminal authorised to enquire and robot link is active)
'05Mar07 CKJ Ported from V8.6

Dim Row As Long
Dim dlocal As DrugParameters
Dim foundPtr As Long
Dim strMachine As String
Dim strStock As String
Dim strMsg As String
Dim NumItems As Single
Dim strMessage As String
   
   If mnuStockTake(4).Checked Then                       'enter stock level
      ''If intStockInPacks Then Col = 5 Else Col = 7       'primary stock location only
      
      ''If tbldisplay.ColumnIndex = Col Then
      Row = lvwMainScreen.SelectedItem.Index      'tbldisplay.RowIndex
      If Row Then
         dlocal.SisCode = stnsv(Row)
         getdrug dlocal, 0, foundPtr, False
      
         If foundPtr Then
            If MechDispEnquiry(dlocal, strMachine, strStock, strMessage) Then
               If Len(strMessage) = 0 Then
                  If Len(strStock) Then
                     'If intStockInPacks And Val(dlocal.convfact) > 0 Then       '19Mar07 CKJ Corrected
                     If Not intStockInPacks And Val(dlocal.convfact) > 0 Then    '   "     "      "
                        NumItems = Val(strStock) * Val(dlocal.convfact)
                     Else
                        NumItems = Val(strStock)
                     End If
               
                     ''TblDisplay_Update Row, Col, Format$(numitems)
                     blnChangeFlag = True
                     txtStockLvl1.text = Format$(NumItems)
                     UpdateStockLevels
                  End If
               Else
                 popmessagecr "#", strMessage & cr   'error message from robot
               End If
        
            Else
               If strMachine = "<UNKNOWN>" Then
                  popmessagecr "#", "Dispensing machine not specified for this item"
               Else
                  popmessagecr "#", strMachine & " not available" & cr & cr & strMessage     'Shows 'Swisslog' or 'Rowa' if it should have linked but could not
               End If
            End If
         End If
      End If
      ''End If
   End If

End Sub

Sub StockTakeMechDispEnquiryAll()
'10Jan13 CKJ If in editing mode then scan all items & where supported do a
'            robot stock enquiry, putting results against location 1.
'            (if terminal authorised to enquire and robot link(s) are active)

Dim dlocal As DrugParameters
Dim foundPtr As Long
Dim strMachine As String
Dim strStock As String
Dim NumItems As Single
Dim strMessage As String
Dim strHead As String
Dim lngRow As Integer
Dim msg As String
Dim CountTotalItems As Long
Dim CountRobotItems As Long
Dim CountRobotError As Long
Dim MsgRobotErrors As String
Dim RobotUnavailable As Boolean
Dim desc As String
Dim ans As String

   strHead = "Stock Take - Update All Robot Items"
   If mnuStockTake(4).Checked And lvwMainScreen.ListItems.count > 0 Then   'enter stock level
      'warning
      msg = "This will scan the currently loaded stocktake and for every item" & cr & _
            "which is stored in a dispensing robot a stock enquiry is made" & cr & _
            "and the result is written to the primary stock location (Locn 1)." & cr & cr & _
            "This will overwrite stock levels which were previously entered." & cr & cr & _
            "Do you wish to proceed?"
      ans = "N"
      askwin "?" & strHead, msg, ans, k
      If ans <> "Y" Or k.escd Then Exit Sub     '<== Way Out
      
      'save any pending mods
      If GetMStockTakeMode() = 1 Then UpdateStockLevels

      'unselect current row
      Select Case lvwMainScreen.SelectedItem.Index
         Case 1 To lvwMainScreen.ListItems.count
            lvwMainScreen.ListItems(lvwMainScreen.SelectedItem.Index).Selected = False
         End Select
      
      'Prepare for automated enquiry
      msg = ""
      MnuFileTop.Enabled = False
      mnuEditHdg.Enabled = False
      mnuOptionshdg.Enabled = False
      picToolBar.Enabled = False
      m_BusyInRobot = True
      m_CancelRobot = False
      CountTotalItems = 0
      CountRobotItems = 0
      CountRobotError = 0
      
      'loop
      For lngRow = 1 To lvwMainScreen.ListItems.count
         'set current line
         lvwMainScreen.SetFocus
         lvwMainScreen.ListItems(lngRow).Selected = True
         lvwMainScreen.ListItems(lngRow).EnsureVisible
         lvwMainScreen_RowChange (lngRow)
         Me.Refresh
         
         CountTotalItems = CountTotalItems + 1
         dlocal.SisCode = stnsv(lngRow)
         getdrug dlocal, 0, foundPtr, False
      
         If foundPtr Then
            If MechDispEnquiry(dlocal, strMachine, strStock, strMessage) Then
               CountRobotItems = CountRobotItems + 1
               If Len(strMessage) = 0 Then
                  If Len(strStock) Then
                     If Not intStockInPacks And Val(dlocal.convfact) > 0 Then
                        NumItems = Val(strStock) * Val(dlocal.convfact)
                     Else
                        NumItems = Val(strStock)
                     End If
               
                     blnChangeFlag = True
                     txtStockLvl1.text = Format$(NumItems)
                     UpdateStockLevels
                  End If
               Else
                  'error message from robot
                  CountRobotError = CountRobotError + 1
                  'desc = Trim$(dlocal.storesdescription)       XN 4Jun15 98073 New local stores description
                  'If Len(desc) = 0 Then desc = Trim$(dlocal.Description)
                                  desc = Trim$(dlocal.DrugDescription)
                  plingparse desc, "!"
                  MsgRobotErrors = MsgRobotErrors & dlocal.SisCode & " " & desc & " " & strMessage & cr
               End If
        
            Else
               If strMachine = "<UNKNOWN>" Then
                  'no action; not a robot item
               Else
                  'robot not available - it should have linked but didn't
                  CountRobotItems = CountRobotItems + 1
                  m_CancelRobot = True
                  RobotUnavailable = True
               End If
            End If
         End If
         DoEvents
         If m_CancelRobot Then Exit For
      Next
            
      'exit automated enquiry
      m_BusyInRobot = False
      picToolBar.Enabled = True
      MnuFileTop.Enabled = True
      mnuEditHdg.Enabled = True
      mnuOptionshdg.Enabled = (Storepasslvl >= 5)
      lvwMainScreen_RowChange lvwMainScreen.SelectedItem.Index    'remove the prompt in the notes box
      
      'summary
      If m_CancelRobot Then msg = msg & "Update via robot cancelled" & cr
      If RobotUnavailable Then msg = msg & "Robot not available" & cr
      msg = msg & Format$(CountTotalItems) & " items scanned" & cr
      msg = msg & Format$(CountRobotItems) & " robot items" & cr
      If CountRobotError Then
         msg = msg & Format$(CountRobotError) & " errors on robot enquiry;" & cr & MsgRobotErrors & cr
      End If
      popmessagecr "#" & strHead, msg
         
   Else  'not in Enter mode
      If Not mnuStockTake(4).Checked Then   'no message if no rows on screen
         popmessagecr "#" & strHead, "Updating of all Robot stock items is available" & cr & "when 'Enter Stock Levels' is selected"
      End If
   End If

End Sub

Sub SetCaption()
'28Jan13 CKJ Include stocktake name in form caption  TFS 54463
'            Uses module level variable STname

   If Len(STname) Then
      Me.Caption = "Stock Take Utility - " & STname
   Else
      Me.Caption = "Stock Take Utility"
   End If

End Sub
