VERSION 5.00
Begin VB.Form Dctfrm 
   Appearance      =   0  'Flat
   AutoRedraw      =   -1  'True
   BackColor       =   &H00C0C0C0&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Ward Stock Interface"
   ClientHeight    =   6495
   ClientLeft      =   1560
   ClientTop       =   1485
   ClientWidth     =   9480
   ClipControls    =   0   'False
   BeginProperty Font 
      Name            =   "MS Sans Serif"
      Size            =   8.25
      Charset         =   0
      Weight          =   700
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   ForeColor       =   &H00C0C0C0&
   Icon            =   "WDCTFRM.frx":0000
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   6495
   ScaleWidth      =   9480
   Begin VB.ListBox LstHdr 
      Appearance      =   0  'Flat
      BackColor       =   &H00C00000&
      Height          =   225
      Left            =   60
      TabIndex        =   5
      Top             =   60
      Width           =   9375
   End
   Begin VB.ListBox LstDCTimport 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      ForeColor       =   &H00000000&
      Height          =   5295
      Left            =   60
      TabIndex        =   0
      Top             =   360
      Width           =   9375
   End
   Begin VB.Frame FrmImport 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      ForeColor       =   &H00000000&
      Height          =   720
      Left            =   3000
      TabIndex        =   3
      Top             =   2400
      Visible         =   0   'False
      Width           =   3240
      Begin VB.Label Lblmsg 
         Appearance      =   0  'Flat
         BackColor       =   &H00C0C0C0&
         Caption         =   "Importing..."
         ForeColor       =   &H00000000&
         Height          =   240
         Left            =   120
         TabIndex        =   4
         Top             =   0
         Width           =   2880
      End
   End
   Begin VB.Label Label1 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H00C0C0C0&
      Caption         =   " F1 Help |        | F6 Delete File |        | F8 Issue | F9 Delete | PgUp/PgDn"
      ForeColor       =   &H00000000&
      Height          =   210
      Left            =   0
      TabIndex        =   1
      Top             =   6060
      Visible         =   0   'False
      Width           =   9375
   End
   Begin VB.Label LblHeader 
      Appearance      =   0  'Flat
      BackColor       =   &H00C0C0C0&
      BackStyle       =   0  'Transparent
      Caption         =   "Ward Description                       Qty        Problem  Barcode       User"
      ForeColor       =   &H00000000&
      Height          =   195
      Left            =   120
      TabIndex        =   2
      Top             =   120
      Visible         =   0   'False
      Width           =   8760
   End
   Begin VB.Menu MnuFile 
      Caption         =   "&File"
      Begin VB.Menu MnuImport 
         Caption         =   "&Load DCT file"
         Enabled         =   0   'False
         Visible         =   0   'False
      End
      Begin VB.Menu MnuDeleteFile 
         Caption         =   "&Delete DCT File"
         Enabled         =   0   'False
         Shortcut        =   {F6}
         Visible         =   0   'False
      End
      Begin VB.Menu MnuPrint 
         Caption         =   "&Print exceptions"
      End
      Begin VB.Menu MnuNew 
         Caption         =   "&Close DCT File"
         Enabled         =   0   'False
         Visible         =   0   'False
      End
      Begin VB.Menu MnuPsion3 
         Caption         =   "&Export wards to Psion 3"
         Enabled         =   0   'False
         Index           =   0
         Visible         =   0   'False
      End
      Begin VB.Menu MnuPsion3 
         Caption         =   "&Import wards from a Psion 3"
         Enabled         =   0   'False
         Index           =   1
         Visible         =   0   'False
      End
      Begin VB.Menu MnuPsion3 
         Caption         =   "-"
         Index           =   2
      End
      Begin VB.Menu MnuPsion3 
         Caption         =   "&Write Psion3 File (PsiWin)"
         Enabled         =   0   'False
         Index           =   3
         Visible         =   0   'False
      End
      Begin VB.Menu MnuPsion3 
         Caption         =   "Lo&ad Psion3 File (PsiWIn)"
         Enabled         =   0   'False
         Index           =   4
         Visible         =   0   'False
      End
      Begin VB.Menu MnuPsion3 
         Caption         =   "Write Windows CE File"
         Index           =   6
      End
      Begin VB.Menu MnuPsion3 
         Caption         =   "Load Windows CE File"
         Index           =   7
      End
      Begin VB.Menu MnuPsion3 
         Caption         =   "-"
         Index           =   8
      End
      Begin VB.Menu MnuExit 
         Caption         =   "E&xit"
      End
   End
   Begin VB.Menu MnuOptions 
      Caption         =   "&Options"
      Begin VB.Menu MnuChkView 
         Caption         =   "View all before issue"
      End
   End
   Begin VB.Menu MnuHelp 
      Caption         =   "&Help"
      Begin VB.Menu MnuHlp 
         Caption         =   "&Help"
         Shortcut        =   {F1}
      End
      Begin VB.Menu MnuAbout 
         Caption         =   "&About"
      End
   End
End
Attribute VB_Name = "Dctfrm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'31Mar95 ASC -changed default again! so that items with no problems bookout
'            -Exit when no file loaded fixed
'12Apr95 CKJ Corrected handling in several areas
'            Simplified file selection, using SiteInfo
'21Jun95 CKJ Added editform
'23Jan02 TH  Removed the report control from this form - was strangely causing a GPF on uploading the CE files.
'    "       Shouldnt be a problem as only EDI was still using this (now transfered to the ctrl on stocktake form) (#55693)

DefInt A-Z
Option Explicit

Private Sub Form_Load()
   'SCREEN.ControlPanel(7) = 0
   CentreForm Me
   SetChrome Me
   startup
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

    Select Case UnloadMode
        Case 0, 1
            mnuExit_Click
        Case Else
            Cancel = False
    End Select

End Sub

Private Sub Form_Unload(Cancel As Integer)

    Me.Hide

End Sub

Private Sub mnuAbout_Click()

'Dim msg$

''  msg$ = "ASCribe Generic Data Capture Terminal Interface " + Chr$(13)
''  msg$ = msg$ + "" + Chr$(13)
''  msg$ = msg$ + "Copyright ASC computer software Ltd. 2009" + Chr$(13)
''  msg$ = msg$ + "" + Chr$(13)
''  'msg$ = msg$ + "Configured for use with Psion II" + Chr$(13)
''  'msg$ = msg$ + "Configured for use with Zetes" + Chr$(13)
''  MsgBox msg$

ShowAboutBox "Ward Stock Interface"

End Sub

Private Sub MnuChkView_Click()

   MnuChkView.Checked = -1 Xor MnuChkView.Checked

End Sub

Private Sub MnuConfirm_Click()
   confirmissue
End Sub

Private Sub MnuDelete_Click()
   deleteline
End Sub

Private Sub MnuDeleteFile_Click()

    If Psion2 Then DeleteFile

End Sub

Private Sub mnuExit_Click()

   exitprog

End Sub

Private Sub MnuHlp_Click()
Static msg$

msg$ = "After transmitting the files from your 'DCT' use this program to" + Chr$(13)
msg$ = msg$ + "issue the stock from the system. Although any directory can" + Chr$(13)
msg$ = msg$ + "be used for the files the C:\DCT directory is the default." + Chr$(13)
msg$ = msg$ + Chr$(13)
msg$ = msg$ + "Options can be chosen with either the mouse or the keyboard. If the" + Chr$(13)
msg$ = msg$ + "keyboard is used use the Alt key and then the first letter of the menu" + Chr$(13)
msg$ = msg$ + "option desired." + Chr$(13)
msg$ = msg$ + Chr$(13)
msg$ = msg$ + "First select the file using the [File] and then the [Load] menu. " + Chr$(13)
msg$ = msg$ + "The program defaults to booking out all items without 'problems'" + Chr$(13)
msg$ = msg$ + "and reporting the 'exceptions'. If you would like to see all the" + Chr$(13)
msg$ = msg$ + "items before booking out choose 'View all before issue' from the" + Chr$(13)
msg$ = msg$ + "[Options] menu. You can then either turn this option off again and " + Chr$(13)
msg$ = msg$ + "Reload after selecting [Close DCT file] or treat each item individually." + Chr$(13)
msg$ = msg$ + Chr$(13)
msg$ = msg$ + "Once items are displayed you may either delete those items which are" + Chr$(13)
msg$ = msg$ + "erroneous or book out the item despite the 'problem' using F8 and F9." + Chr$(13)
MsgBox msg$, 0, "Help"

msg$ = "SL=XXX   Stock level too low and is XXX" + Chr$(13)
msg$ = msg$ + "User ID  No user initials" + Chr$(13)
msg$ = msg$ + "No Ward  No cost centre code" + Chr$(13)
msg$ = msg$ + "NF       Barcode not found" + Chr$(13)
msg$ = msg$ + ">Max     Quantity for issue is greater than Maximum" + Chr$(13)
msg$ = msg$ + "<Min     Quantity for issue is less than Minimum" + Chr$(13)
msg$ = msg$ + Chr$(13)
msg$ = msg$ + "You may print the exception list at any time using the [File] Print" + Chr$(13)
msg$ = msg$ + "menu. Once the file is processed and all items dealt with the file" + Chr$(13)
msg$ = msg$ + "can be deleted with the F6 key. A file can also be deleted without loading" + Chr$(13)
msg$ = msg$ + "using the F6 with no file loaded and entering the file name." + Chr$(13)
msg$ = msg$ + Chr$(13)
msg$ = msg$ + "N.B. each time the file is loaded without the 'View all before issue'" + Chr$(13)
msg$ = msg$ + "selected (Blob shown to left on menu) all items will be issued." + Chr$(13)
msg$ = msg$ + "Be careful not to issue a whole file more than once." + Chr$(13)

MsgBox msg$, 0, "Help"
msg$ = ""
End Sub

Private Sub MnuImport_Click()
   
ReDim TabStops(10) As Long
Dim i%, x%

    Psion2 = True

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

    Dctfrm.LstDCTimport.Clear

    ImportDCTfile

End Sub

Private Sub MnuNew_Click()
   
   ClearListBox

End Sub

Private Sub mnuPrint_Click()

   DCTPrintExceptions

End Sub

Private Sub MnuPsion3_Click(Index As Integer)
'03Dec97 EAC only export data for a particular ward
'22Jun98 EAC/CFY distinguish between Psion and CE when exporting

ReDim TabStops(5) As Long
Dim i%, x%
Dim FILE$
'03Dec97 EAC
ReDim WDname$(1)
Dim ward$
Dim nw%, totnw%, found%, SelectionTypes%, escaped%, count%
Dim numofsups&

   Select Case Index
      Case 0
            x = Shell("\ascpsion\mclink @txwrds.txt", 1)
      Case 1
            x = Shell("\ascpsion\mclink @recwrds.txt", 1)
      Case 4, 7
            Psion2 = False
            Dctfrm.LblHeader = "Ward   " & TB & "NSVCode " & TB & "Qty       " & TB & "Problem "
            
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
            
            Dctfrm.LstDCTimport.Clear
            If Index = 4 Then ImportWardData 0
            If Index = 7 Then ImportWardData 1

        Case 3, 6
            
            ''GetPointer dispdata$ & "\supfile.v5", numofsups&, False
            ReDim WDname$(numofsups&)

            SelectionTypes% = Val(UCase$(TxtD$(dispdata$ & "\winord.ini", "WardStockList", "0", "SelectionTypes", found)))
            readfilenames WDname$(), totnw, SelectionTypes%
                        
            Load MultiList
            For count = 1 To totnw
                MultiList.LstUnselected.AddItem WDname$(count)
            Next
            
            'multilist.LstUnselected.AddItem " New Ward"  '10Sep96 EAC New wards must be created in the supplier file now
            MultiList.Caption = "Select one department or ward"
            MultiList.lblLine(1).Caption = "Press A-Z or CURSOR KEYS to move, then SPACE to select, RETURN when finished"
            MultiList.Tag = "1"                'max one line
            
            MultiList.Show 1
            
            If Val(MultiList.Tag) = True Then  'valid
                    nw = 1
                    WDname$(1) = MultiList.LstSelected.List(0)
                Else
                    nw = 0
                    k.escd = True
                End If
            
            Unload MultiList
            
            ScreenRefresh
            
            escaped = False
            If nw = 0 Then
                    escaped = True
                    Exit Sub                                         ' <== way out !!
                End If
            
            If Not escaped Then
                    ward$ = Trim$(Left$(WDname$(1), Len(sup.Code)))
                    '22Jun98 EAC/CFY distinguish between Psion and CE when exporting
                    'ExportWardData ward$
                    If Index = 3 Then ExportWardData ward$, 0
                    If Index = 6 Then ExportWardData ward$, 1
                    '--- 22Jun98 EAC/CFY
                End If

   End Select


End Sub

