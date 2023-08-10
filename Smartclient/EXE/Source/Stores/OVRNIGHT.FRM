VERSION 2.00
Begin Form FrmOverNight 
   AutoRedraw      =   -1  'True
   BackColor       =   &H8000000A&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Overnight Job"
   ClientHeight    =   8550
   ClientLeft      =   2835
   ClientTop       =   990
   ClientWidth     =   7635
   Height          =   9240
   Icon            =   OVRNIGHT.FRX:0000
   Left            =   2775
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   8550
   ScaleWidth      =   7635
   Top             =   360
   Width           =   7755
   Begin SSPanel PnlTestMode 
      BackColor       =   &H8000000A&
      Height          =   735
      Left            =   5520
      TabIndex        =   26
      Top             =   7080
      Width           =   1935
      Begin OptionButton OptTestOff 
         BackColor       =   &H8000000A&
         Caption         =   "Test Mode &OFF"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   240
         TabIndex        =   16
         Top             =   360
         Width           =   1455
      End
      Begin OptionButton OptTestOn 
         BackColor       =   &H8000000A&
         Caption         =   "Test Mode O&N"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   240
         TabIndex        =   15
         Top             =   120
         Width           =   1335
      End
   End
   Begin SSPanel PnlTitle 
      BackColor       =   &H8000000A&
      Height          =   1335
      Left            =   120
      TabIndex        =   24
      Top             =   120
      Width           =   7335
      Begin Label LblTitle 
         Alignment       =   2  'Center
         BackColor       =   &H8000000A&
         Caption         =   "LblTitle"
         FontBold        =   -1  'True
         FontItalic      =   0   'False
         FontName        =   "Arial"
         FontSize        =   18
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   1095
         Left            =   120
         TabIndex        =   19
         Top             =   120
         Width           =   6975
      End
   End
   Begin CommandButton CmdProcede 
      Caption         =   "Next..."
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   375
      Left            =   480
      TabIndex        =   17
      Top             =   8040
      Width           =   1335
   End
   Begin CommandButton CmdExit 
      Cancel          =   -1  'True
      Caption         =   "E&xit"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   375
      Left            =   6120
      TabIndex        =   18
      Top             =   8040
      Width           =   1335
   End
   Begin SSPanel PnlInfo 
      Height          =   615
      Left            =   120
      TabIndex        =   22
      Top             =   7200
      Width           =   5175
      Begin Label Lblinfo 
         BackColor       =   &H8000000A&
         Caption         =   "LblInfo"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   9.75
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   375
         Left            =   120
         TabIndex        =   23
         Top             =   120
         Width           =   4950
      End
   End
   Begin SSPanel PnlSummary 
      BackColor       =   &H8000000A&
      Height          =   5175
      Left            =   150
      TabIndex        =   21
      Top             =   1665
      Visible         =   0   'False
      Width           =   7335
      Begin HScrollBar HscSummary 
         Height          =   240
         LargeChange     =   10
         Left            =   225
         Max             =   100
         TabIndex        =   46
         Top             =   4080
         Width           =   3645
      End
      Begin PictureBox PicBackground 
         BackColor       =   &H8000000A&
         Height          =   1800
         Left            =   195
         ScaleHeight     =   1770
         ScaleWidth      =   6900
         TabIndex        =   44
         Top             =   2205
         Width           =   6930
         Begin ListBox LstSummary 
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   1005
            Left            =   30
            TabIndex        =   45
            Top             =   390
            Width           =   6855
         End
      End
      Begin PictureBox PicSplash 
         AutoRedraw      =   -1  'True
         Height          =   4335
         Left            =   435
         ScaleHeight     =   4305
         ScaleWidth      =   6345
         TabIndex        =   28
         Top             =   465
         Width           =   6375
         Begin PictureBox PicLogo 
            AutoRedraw      =   -1  'True
            BorderStyle     =   0  'None
            Height          =   1695
            Left            =   930
            Picture         =   OVRNIGHT.FRX:0302
            ScaleHeight     =   1695
            ScaleWidth      =   4695
            TabIndex        =   29
            Top             =   180
            Width           =   4695
         End
         Begin Label LblSplash 
            Alignment       =   2  'Center
            FontBold        =   -1  'True
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   18
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   1095
            Left            =   285
            TabIndex        =   27
            Top             =   2145
            Width           =   5895
         End
      End
      Begin TextBox TxtStatus 
         BackColor       =   &H8000000A&
         BorderStyle     =   0  'None
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   735
         Left            =   240
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   25
         Text            =   "TxtStatus"
         Top             =   1440
         Width           =   6855
      End
   End
   Begin SSPanel PnlOptions 
      BackColor       =   &H8000000A&
      BevelOuter      =   1  'Inset
      BevelWidth      =   2
      Height          =   5145
      Left            =   165
      TabIndex        =   30
      Top             =   1665
      Visible         =   0   'False
      Width           =   7305
      Begin TextBox txtExtraInfo 
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   975
         Left            =   300
         MultiLine       =   -1  'True
         ScrollBars      =   2  'Vertical
         TabIndex        =   42
         Text            =   "txtExtraInfo"
         Top             =   2565
         Width           =   6675
      End
      Begin Frame FraOptionControls 
         BackColor       =   &H8000000A&
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   735
         Left            =   300
         TabIndex        =   37
         Top             =   3630
         Width           =   6690
         Begin ComboBox CmbSetup 
            Height          =   315
            Left            =   3210
            TabIndex        =   43
            Text            =   "Combo1"
            Top             =   270
            Width           =   1590
         End
         Begin TextBox TxtSetup 
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   315
            Left            =   5115
            TabIndex        =   40
            Top             =   255
            Width           =   1110
         End
         Begin OptionButton OptSetupOFF 
            BackColor       =   &H8000000A&
            Caption         =   "Off"
            Height          =   345
            Left            =   5835
            TabIndex        =   39
            Top             =   255
            Width           =   615
         End
         Begin OptionButton OptSetupON 
            BackColor       =   &H8000000A&
            Caption         =   "On"
            Height          =   345
            Left            =   5100
            TabIndex        =   38
            Top             =   255
            Width           =   615
         End
         Begin Label LblSetupPrompt 
            BackColor       =   &H8000000A&
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   255
            Left            =   1365
            TabIndex        =   41
            Top             =   270
            Width           =   3270
         End
         Begin Label Label4 
            BackColor       =   &H8000000A&
            Caption         =   "Apply Setting:"
            Height          =   345
            Left            =   105
            TabIndex        =   31
            Top             =   270
            Width           =   2505
         End
      End
      Begin ListBox LstOptions 
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   810
         Left            =   300
         Sorted          =   -1  'True
         TabIndex        =   35
         Top             =   1515
         Width           =   6675
      End
      Begin Label Label1 
         BackColor       =   &H8000000A&
         Caption         =   "Choose Option:"
         Height          =   255
         Left            =   285
         TabIndex        =   36
         Top             =   1230
         Width           =   3870
      End
      Begin Label Label3 
         Alignment       =   2  'Center
         BackColor       =   &H8000000A&
         Caption         =   "These options can fundamentally change the way the system runs. DO NOT CHANGE any of these settings except on instruction from EMIS Health. (All Changes will be logged.)"
         ForeColor       =   &H000000FF&
         Height          =   660
         Left            =   135
         TabIndex        =   33
         Top             =   450
         Width           =   7050
      End
      Begin Label Label2 
         Alignment       =   2  'Center
         BackColor       =   &H8000000A&
         Caption         =   "Warning!!"
         ForeColor       =   &H000000FF&
         Height          =   255
         Left            =   90
         TabIndex        =   32
         Top             =   135
         Width           =   7005
      End
   End
   Begin SSPanel PnlJob 
      BackColor       =   &H8000000A&
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   5175
      Left            =   135
      TabIndex        =   0
      Top             =   1665
      Width           =   7335
      Begin Frame FraJobs 
         BackColor       =   &H8000000A&
         Caption         =   "Current Jobs"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   2895
         Left            =   480
         TabIndex        =   4
         Top             =   960
         Width           =   6135
         Begin CommandButton CmdJobMore 
            Caption         =   "More..."
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   300
            Index           =   4
            Left            =   4260
            TabIndex        =   14
            Top             =   2385
            Width           =   945
         End
         Begin CommandButton CmdJobMore 
            Caption         =   "More..."
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   300
            Index           =   3
            Left            =   4275
            TabIndex        =   12
            Top             =   1875
            Width           =   945
         End
         Begin CommandButton CmdJobMore 
            Caption         =   "More..."
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   300
            Index           =   2
            Left            =   4275
            TabIndex        =   10
            Top             =   1410
            Width           =   945
         End
         Begin CommandButton CmdJobMore 
            Caption         =   "More..."
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   300
            Index           =   1
            Left            =   4230
            TabIndex        =   8
            Top             =   990
            Width           =   945
         End
         Begin CommandButton CmdJobMore 
            Caption         =   "More..."
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   300
            Index           =   0
            Left            =   4245
            TabIndex        =   6
            Top             =   360
            Width           =   945
         End
         Begin CheckBox ChkJob 
            BackColor       =   &H8000000A&
            Caption         =   "Single Financial Copy (To Dispdata.9**)"
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   240
            Index           =   3
            Left            =   240
            TabIndex        =   11
            Top             =   1890
            Width           =   5670
         End
         Begin CheckBox ChkJob 
            BackColor       =   &H8000000A&
            Caption         =   "Patient Re-Indexing"
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   255
            Index           =   4
            Left            =   240
            TabIndex        =   13
            Top             =   2355
            Width           =   1950
         End
         Begin CheckBox ChkJob 
            BackColor       =   &H8000000A&
            Caption         =   "Multiple Financial Copy (To \Monthend\)"
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   255
            Index           =   2
            Left            =   240
            TabIndex        =   9
            Top             =   1425
            Width           =   5700
         End
         Begin CheckBox ChkJob 
            BackColor       =   &H8000000A&
            Caption         =   "Contract Price Update"
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            Height          =   255
            Index           =   1
            Left            =   240
            TabIndex        =   7
            Top             =   945
            Width           =   5775
         End
         Begin CheckBox ChkJob 
            BackColor       =   &H8000000A&
            Caption         =   "Orders Re-Indexing"
            FontBold        =   0   'False
            FontItalic      =   0   'False
            FontName        =   "MS Sans Serif"
            FontSize        =   8.25
            FontStrikethru  =   0   'False
            FontUnderline   =   0   'False
            ForeColor       =   &H00000000&
            Height          =   255
            Index           =   0
            Left            =   240
            TabIndex        =   5
            Top             =   360
            Width           =   5745
         End
      End
      Begin CommandButton CmdJobNext 
         Caption         =   "Next >"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   3480
         TabIndex        =   3
         Top             =   480
         Width           =   615
      End
      Begin CommandButton CmdJobPrev 
         Caption         =   "< Prev"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   255
         Left            =   2760
         TabIndex        =   2
         Top             =   480
         Width           =   615
      End
      Begin Label LblSiteNum 
         Alignment       =   2  'Center
         BorderStyle     =   1  'Fixed Single
         Height          =   255
         Left            =   1080
         TabIndex        =   1
         Top             =   480
         Width           =   855
      End
      Begin Label LblJobs 
         BackColor       =   &H8000000A&
         Caption         =   "Site: "
         Height          =   255
         Left            =   600
         TabIndex        =   20
         Top             =   480
         Width           =   375
      End
   End
   Begin Label LblPasswordFlag 
      Caption         =   "PasswordFlag"
      Height          =   240
      Left            =   2955
      TabIndex        =   34
      Top             =   6900
      Visible         =   0   'False
      Width           =   1260
   End
   Begin Menu MnuFileTitle 
      Caption         =   "&File"
      Begin Menu MnuFile 
         Caption         =   "Run &Jobs"
         Index           =   0
      End
      Begin Menu MnuFile 
         Caption         =   "E&xit"
         Index           =   1
      End
      Begin Menu MnuFile 
         Caption         =   "&Next"
         Enabled         =   0   'False
         Index           =   2
         Visible         =   0   'False
      End
   End
   Begin Menu MnuViewtitle 
      Caption         =   "&View"
      Begin Menu MnuView 
         Caption         =   "&All Jobs"
         Index           =   0
      End
      Begin Menu MnuView 
         Caption         =   "Jobs by &Site"
         Index           =   1
      End
      Begin Menu MnuView 
         Caption         =   "Status &Report"
         Index           =   2
      End
   End
   Begin Menu MnuOptionsTitle 
      Caption         =   "O&ptions"
      Begin Menu MnuOptions 
         Caption         =   "&Setup..."
         Index           =   0
      End
      Begin Menu MnuOptions 
         Caption         =   "Change Live &Drive..."
         Index           =   1
      End
   End
   Begin Menu MnuInfoTitle 
      Caption         =   "&Information"
      Begin Menu MnuInfo 
         Caption         =   "&Master Log"
         Index           =   0
      End
      Begin Menu MnuInfo 
         Caption         =   "Most &Recent Log"
         Index           =   1
      End
      Begin Menu MnuInfo 
         Caption         =   "-"
         Index           =   2
      End
      Begin Menu MnuInfo 
         Caption         =   "View &Audit Trail"
         Index           =   3
      End
   End
   Begin Menu MnuHelpTitle 
      Caption         =   "&Help"
      Begin Menu MnuHelp 
         Caption         =   "&About"
         Index           =   0
      End
   End
End
Option Explicit
DefInt A-Z

'                             OVERNIGHT JOB FORM
'                    -----------------------------------
'
'25Jan00 AE  Written
'01Mar00 AE  Changed Tab order on form

Sub ChkJob_Click (Index As Integer)

   ChkJob(Index).FontBold = IFF(ChkJob(Index).Value = 1, True, False)
   CmdJobMore(Index).Enabled = (ChkJob(Index).Value = 1)

End Sub

Sub CmbSetup_Click ()

   If CmbSetup.Tag <> "" Then
         UpdateOptionSettings Val(CmbSetup.Tag), (LstOptions.ItemData(LstOptions.ListIndex))
      End If

End Sub

Sub CmbSetup_KeyPress (KeyAscii As Integer)

   KeyAscii = 0

End Sub

Sub cmdExit_Click ()

Dim iValid As Integer


   SaveONJSettings iValid
   If iValid Then
         Me.Hide
      End If


End Sub

Sub CmdExit_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)

   ShowTip "Save and Exit", Me

End Sub

Sub CmdJobMore_Click (Index As Integer)

'Extra options.  Currently only for Patient Re-index


   Select Case Index
      Case 4
      'Patient Re-indexing
         ChoosePatIdxOptions
      '
      '
      'more...
      '
      '
      End Select


End Sub

Sub CmdJobNext_Click ()
   

Dim iDX As Integer

   UpdateSiteJobs

   iDX = GetSiteIndex()
   If iDX < iNumOfSites Then iDX = iDX + 1

   showsitejobs iDX


End Sub

Sub CmdJobNext_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)

   ShowTip "Show jobs for next site", Me

End Sub

Sub CmdJobPrev_Click ()

Dim iDX As Integer

   UpdateSiteJobs
   
   iDX = GetSiteIndex()
   If iDX > 1 Then iDX = iDX - 1

   showsitejobs iDX


End Sub

Sub CmdJobPrev_MouseMove (Button As Integer, Shift As Integer, X As Single, Y As Single)

   ShowTip "Show jobs for previous site", Me

End Sub

Sub CmdProcede_Click ()

'02Feb00 AE  Added lines to update menus after status report

Dim iTestRun As Integer, iValid As Integer
Dim sMsg As String, ans$, k As KbdControl
   
   If Val(frmOvernight.LblPasswordFlag.Caption) Then GetONJPassword

   iTestRun = OptTestOn.Value
   
   Select Case UCase(CmdProcede.Tag)
      Case "NEXT"
         'Begin setup by showing summary of jobs
         CmdProcede.Tag = ""
         CmdProcede.Enabled = False
         CmdProcede.Visible = False
         LblInfo.Caption = ""
         mnufileTitle.Enabled = True
         mnuViewTitle.Enabled = True
         MnuFile(1).Enabled = True
         MnuFile(2).Visible = False                    '02Feb00 AE
         MnuFile(2).Enabled = False                    '    "
         mnuOptionsTitle.Enabled = True
         mnuInfoTitle.Enabled = True
         'SaveONJSettings iValid                        'Dont think this is needed, the first time the prog is run
         showsitejobs 1

      Case "RUN"
         UpdateSiteJobs

         'Double confirm required as before
         sMsg = "WARNING! System Manager ONLY!" & cr$ & cr$
         sMsg = sMsg & cr$ & "The Overnight Job requires exclusive use of the system."
         sMsg = sMsg & cr$ & "All terminals MUST be logged off the system before proceeding!"
         sMsg = sMsg & cr$ & cr$ & "OK to continue?"
         AskWin "Overnight Re-Indexing", sMsg, ans$, k
         If ans$ <> "Y" Then Exit Sub

         If iTestRun Then
               sMsg = "do a test run of the overnight job"
            Else
               sMsg = "run Overnight Job"
            End If
         Confirm "Overnight Re-Indexing", sMsg, ans$, k
         If ans$ <> "Y" Then Exit Sub
      
         SaveONJSettings iValid
         If iValid Then
               ClearONJFiles
      
               'Set up screen if running a test run.
               If iTestRun Then
                     DoTestRun
                  Else
                     frmOvernight.Tag = "CONTINUE"
                     frmOvernight.Hide
                  End If
            End If

      Case "EXITSETUP"
         'Log any changes to settings in .aud log.
         CheckSetupChanges

      Case "BACK"
         'Back to all jobs view
         JobsSummary

      '
      '
      '
      End Select

End Sub

Sub CmdSave_Click ()

   
   SaveONJSettings 0


End Sub

Sub Form_Activate ()
'
Static iDoneOpt As Integer

   Select Case UCase(Me.Tag)
      Case "FIRST"
         ShowStatus True
         Me.Tag = ""

      Case "SETUP"
         If InStr(UCase(Command$), "/VIEWMASTER") And Not iDoneOpt Then
               ViewONJLog 0, ""
               iDoneOpt = True
            ElseIf InStr(UCase(Command$), "/TEST") And Not iDoneOpt Then
               frmOvernight.LblPasswordFlag.Caption = "-1"
               Me.Tag = ""
               DoTestRun
               iDoneOpt = True
               '
               '
               'More options if needed
               '
               '
            Else
               JobsSummary
               Me.Tag = ""
            End If
            
      
      Case "RUN", "CONTINUE"
         
         ArrangeONJForm 5
         GoOvernightJob False, False
         
         
      End Select


End Sub

Sub Form_Load ()

   Me.Caption = "Overnight Job " & ONJVer

End Sub

Sub Form_QueryUnload (Cancel As Integer, UnloadMode As Integer)

'Prevent shutting by clicking on the X button
   If UnloadMode <> 1 Then Cancel = True


End Sub

Sub HscSummary_Change ()

'Scroll the list box within the background by moving its offset.

   LstSummary.Left = -((HscSummary.Value / 100) * (LstSummary.Width - PicBackground.Width)) - LST_OFFSET

   

End Sub

Sub LblTitle_Change ()

   If Len(LblTitle.Caption) > 42 Then
         LblTitle.FontSize = 13.5
      Else
         LblTitle.FontSize = 18
      End If
   
   LblTitle.Refresh

End Sub

Sub LstOptions_Click ()

   ShowExtraSetupInfo (LstOptions.ItemData(LstOptions.ListIndex))

End Sub

Sub LstSummary_DblClick ()

'Depending on if we're showing jobs or a log;
'Show this site's jobs.

Dim iDX As Integer
Dim sLine As String, sFile As String
Dim iCount As Integer, ifinished As Integer

   Select Case LstSummary.Tag
      Case "JOBS"
         iDX = frmOvernight.LstSummary.ItemData(frmOvernight.LstSummary.ListIndex)
         If iDX <> 0 Then showsitejobs iDX

      Case "LOG"
         iCount = 0
         'Find the closest Date, and display that file
            Do
               If LstSummary.ItemData(LstSummary.ListIndex - iCount) <> 0 Then
                     sLine = LstSummary.List(LstSummary.ListIndex - iCount)
                     sLine = Left$(sLine, 10)
                     sFile = Right$(sLine, 4) & Mid$(sLine, 4, 2) & Mid$(sLine, 1, 2)
                     sFile = "\" & sFile & ".Log"
                     ViewONJLog 2, AppPathNoSlash() & ONJLogDir$ & sFile
                     ifinished = True
                  Else
                     iCount = iCount + 1
                     If (LstSummary.ListIndex - iCount) < 0 Then ifinished = True
                  End If
            

            Loop Until ifinished
               

      End Select

End Sub

Sub LstSummary_KeyPress (KeyAscii As Integer)

   Select Case KeyAscii
      Case 13, 32             'Return, Space - same as dbl click
            LstSummary_DblClick
      End Select

End Sub

Sub mnuFile_Click (Index As Integer)

   If Val(frmOvernight.LblPasswordFlag.Caption) Then GetONJPassword

   Select Case Index
      Case 0            'Run Jobs
         CmdProcede_Click

      Case 1            'Exit
         cmdExit_Click

      Case 2            'Next
         CmdProcede_Click

      End Select

End Sub

Sub mnuHelp_Click (Index As Integer)

   If Val(frmOvernight.LblPasswordFlag.Caption) Then GetONJPassword

   Select Case Index
      Case 0
         ShowAboutBox Me, "Overnight Job " & ONJVer
      End Select
   

End Sub

Sub MnuInfo_Click (Index As Integer)

   If Val(frmOvernight.LblPasswordFlag.Caption) Then GetONJPassword

   Select Case Index
      Case 0, 1              'Log View
         ViewONJLog Index, ""

      Case 3
         'View encrypted log file
         ViewONJLog -210, AppPathNoSlash() & ONJLogDir & ONJAudit
      '
      'more               app
      '
      End Select


End Sub

Sub mnuOptions_Click (Index As Integer)

Dim sMsg As String, iButton As Integer

   If Val(frmOvernight.LblPasswordFlag.Caption) Then GetONJPassword

   Select Case Index
      Case 0                  'Go to setup
         UpdateSiteJobs
         ShowSetupOptions

      Case 1                  'Change Live Drive
         'Browse for the live drive. Show a list of all available, writable drives.
         'Allow user to change after severe warnings!
         sMsg = "WARNING!  Changing the Live Drive will blank all" & cr$
         sMsg = sMsg & "Overnight Job settings." & cr$
         sMsg = sMsg & "DO NOT CONTINUE except under instruction" & cr$
         sMsg = sMsg & "from EMIS Health." & cr$ & cr$
         sMsg = sMsg & "Proceed to setup ?"
         iButton = MessageBox(sMsg, MB_YESNO + MB_DEFBUTTON2 + MB_ICONSTOP, "Overnight Job Setup")
         If iButton = IDYES Then
               BrowseDriveList False
            End If
         
      '
      '
      'Others
      '
      '
      End Select

End Sub

Sub MnuView_Click (Index As Integer)

   If Val(frmOvernight.LblPasswordFlag.Caption) Then GetONJPassword

   UpdateSiteJobs

   Select Case Index
      Case 0
         JobsSummary
      Case 1
         showsitejobs 1
      Case 2
         ShowStatus False
   
      End Select


End Sub

Sub ONJtimer_Timer ()

'Start time set in TAG, Displays the current time minus the start time


'Dim sTmp As String
'Dim iSSec As Integer, iSMin As Integer, iSHr As Integer
'Dim iNSec As Integer, iNMin As Integer, iNHr As Integer
'Dim lSSec As Long, lNSec As Long, lElapsedSec As Long
'
'Dim vStartTime As Variant, vNowTime As Variant, vElapsed As Variant
'
'   'Start time set in tag
'   sTmp = ONJTimer.Tag
'
 '  'Convert to total seconds (since start of the day)
 '  iSSec = Val(Right$(sTmp, 2))
'   iSMin = Val(Mid$(sTmp, InStr(sTmp, ":") + 1, 2))
'   iSHr = Val(Mid$(sTmp, 1, InStr(sTmp, ":") - 1))
'
'   lSSec = (iSHr * 3600&) + (iSMin * 60&) + iSSec
'
'   'Time now; again convert to total seconds
'   sTmp = Format$(Now, "hh:mm:ss")
'
'   iNSec = Val(Right$(sTmp, 2))
'   iNMin = Val(Mid$(sTmp, InStr(sTmp, ":") + 1, 2))
'   iNHr = Val(Mid$(sTmp, 1, InStr(sTmp, ":") - 1))
'
'   'Take account of midnight
'   If iNHr < iSHr Then iNHr = iNHr + 24
'
'   lNSec = (iNHr * 3600&) + (iNMin * 60&) + iNSec
'
'   lElapsedSec = lNSec - lSSec
'
'   iNHr = Int(lElapsedSec / 3600)
'   iNMin = Int((lElapsedSec - iNHr) / 60)
'   iNSec = lElapsedSec - (iNHr * 3600&) - (iNMin * 60)
'
'   frmOvernight.LblElapsed.Caption = Format$(iNHr, "00") & ":" & Format$(iNMin, "00") & ":" & Format$(iNSec, "00")
'   frmOvernight.LblElapsed.Refresh
'
End Sub

Sub OptSetupOFF_Click ()

   If OptSetupOFF.Tag = "" Then
         UpdateOptionSettings (frmOvernight.LstOptions.ItemData(frmOvernight.LstOptions.ListIndex)), (frmOvernight.LstOptions.ListIndex)
      End If

End Sub

Sub OptSetupON_Click ()

   If OptSetupON.Tag = "" Then
         UpdateOptionSettings (frmOvernight.LstOptions.ItemData(frmOvernight.LstOptions.ListIndex)), (frmOvernight.LstOptions.ListIndex)
      End If

End Sub

Sub OptTestOff_Click ()
   
Dim iValid As Integer

   If Val(frmOvernight.LblPasswordFlag.Caption) Then GetONJPassword

   If OptTestOff.Value Then
         PnlTestMode.BackColor = &HFF&
         OptTestOn.BackColor = &HFF&
         OptTestOff.BackColor = &HFF&
      End If

End Sub

Sub OptTestOn_Click ()

   If Val(frmOvernight.LblPasswordFlag.Caption) Then GetONJPassword

   If OptTestOn.Value Then
         PnlTestMode.BackColor = &HFF00&
         OptTestOn.BackColor = &HFF00&
         OptTestOff.BackColor = &HFF00&
      End If


End Sub

Sub txtExtraInfo_KeyPress (KeyAscii As Integer)

   KeyAscii = 0

End Sub

Sub TxtSetup_GotFocus ()

   txtSetup.SelStart = 0
   txtSetup.SelLength = Len(txtSetup.Text)

End Sub

Sub TxtSetup_KeyPress (KeyAscii As Integer)

   If Not InputValid(KeyAscii, (txtSetup.Tag)) Then
         KeyAscii = 0
      Else
         If KeyAscii = 13 Then
               UpdateOptionSettings (frmOvernight.LstOptions.ItemData(frmOvernight.LstOptions.ListIndex)), (frmOvernight.LstOptions.ListIndex)
            End If
      End If

End Sub

Sub TxtStatus_KeyPress (KeyAscii As Integer)

   KeyAscii = 0

End Sub

