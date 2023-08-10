VERSION 5.00
Object = "{33337173-F789-11CE-86F8-0020AFD8C6DB}#1.0#0"; "ftp40.ocx"
Begin VB.Form PWLFrm 
   Appearance      =   0  'Flat
   AutoRedraw      =   -1  'True
   BackColor       =   &H00FFFFFF&
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Interface"
   ClientHeight    =   8880
   ClientLeft      =   150
   ClientTop       =   435
   ClientWidth     =   12210
   ForeColor       =   &H80000008&
   Icon            =   "HSSLFRM.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   8880
   ScaleWidth      =   12210
   StartUpPosition =   2  'CenterScreen
   WindowState     =   2  'Maximized
   Begin VB.ListBox LstDisplay 
      Appearance      =   0  'Flat
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   3150
      ItemData        =   "HSSLFRM.frx":030A
      Left            =   2760
      List            =   "HSSLFRM.frx":030C
      TabIndex        =   0
      Top             =   1560
      Width           =   6735
   End
   Begin FTPLibCtl.FTP FTP1 
      Left            =   240
      Top             =   240
      AltFile         =   ""
      LocalFile       =   ""
      Passive         =   0   'False
      Password        =   ""
      RemoteFile      =   ""
      RemoteHost      =   ""
      RemotePath      =   ""
      TransferMode    =   0
      User            =   ""
      WinsockLoaded   =   -1  'True
   End
   Begin VB.Menu MnuFileTop 
      Caption         =   "&File"
      Begin VB.Menu MnuFile 
         Caption         =   "&Create Order Files"
         Index           =   0
      End
      Begin VB.Menu MnuFile 
         Caption         =   "-"
         Index           =   1
      End
      Begin VB.Menu MnuFile 
         Caption         =   "E&xit"
         Index           =   2
      End
   End
   Begin VB.Menu MnuResendTop 
      Caption         =   "&Resend"
      Begin VB.Menu MnuResend 
         Caption         =   "&S29 Orders"
         Index           =   0
      End
      Begin VB.Menu MnuResend 
         Caption         =   "&CD Orders"
         Index           =   1
      End
   End
   Begin VB.Menu MnuSetupTop 
      Caption         =   "&Setup"
      Begin VB.Menu MnuSetup 
         Caption         =   "&HSSL Settings"
      End
   End
   Begin VB.Menu MnuHelpTop 
      Caption         =   "&Help"
      Begin VB.Menu MnHelp 
         Caption         =   "&About"
      End
   End
End
Attribute VB_Name = "PWLFrm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'----------------------------------------------------------------------------------------
'                                  HSSL Interface Form
'----------------------------------------------------------------------------------------
'13Nov08 CKJ Ported from V9.8 to V10.0
'            Removed unused control FTPx
'            Set DefBool
'            Removed all references to PWLFrm. from within PWLfrm
'
'----------------------------------------------------------------------------------------

Option Explicit
DefBool A-Z

Private Sub CreateHSSLOrder()

Dim DoS29s%, DoCds%, success%
Dim SvrReply$, UploadTime$, msg$

   If Trim$(HSSLCustCode$) = "" Then
      msg$ = "No HSSL Customer Number has been defined." & cr$ & cr$
      msg$ = msg$ & "The interface will not run until the customer number has been setup." & cr$
      msg$ = msg$ & "To setup the customer number select the Setup menu item and" & cr$
      msg$ = msg$ & "enter the HSSL customer number in the HSSL Customer Number field."
      popmessagecr "." & AppTitle$, msg$
      Exit Sub                                                '<== WAY OUT
   End If
   
   LstDisplay.Clear

   AcquireLock dispdata$ & "\PRNTORD2.LCK", -2, success  ' exclusive, keep trying

   If Not success Then
      Beep
      popmsg "Please try later", "EDI/Modem orders are being raised on another terminal", 64, "", 0
      Exit Sub                                                '<== WAY OUT
   End If

   CreateOrderFiles DoS29s, DoCds

   If Not DoS29s And Not DoCds Then Exit Sub

   HSSLScreenOutput ""
   HSSLScreenOutput ">> Logging on to FTP Server at " & HostIPAddr$
   success = FTPLogon(FTP1, HostIPAddr$, FTPUserName$, FTPPassword$, SvrReply$)
   HSSLScreenOutput "<< " & SvrReply$

   UploadTime$ = Format$(date, "yymmdd") & "." & Format$(Time, "hhmmss")
   
   If success And DoS29s Then
      HSSLScreenOutput ""
      HsslS29File$ = "sph." & UploadTime$
      HSSLScreenOutput ">> Sending S29 order to FTP host as file " & HsslS29File$
      FTPSend FTP1, ASCS29File$, HsslS29File$, SvrReply$, True
      HSSLScreenOutput "<< " & SvrReply$
   End If

   If success And DoCds Then
      HSSLScreenOutput ""
      HsslCdFile$ = "scd." & UploadTime$
      HSSLScreenOutput ">> Sending CD order to FTP host as file " & HsslCdFile$
      FTPSend FTP1, ASCCdFile$, HsslCdFile$, SvrReply$, True
      HSSLScreenOutput "<< " & SvrReply$
   End If

   HSSLScreenOutput ""
   HSSLScreenOutput ">> Closing Connection to FTP Server at " & HostIPAddr$
   success = FTPLogoff(FTP1, SvrReply$)
   HSSLScreenOutput "<< " & SvrReply$

End Sub

Private Sub Form_Activate()

   Me.LstDisplay.Left = Me.ScaleLeft + 500         '14Nov08 CKJ was Me.Left + 500
   Me.LstDisplay.Width = Me.ScaleWidth - 1000
   Me.LstDisplay.Top = Me.ScaleTop + 500           '            was Me.Top + 500
   Me.LstDisplay.Height = Me.ScaleHeight - 1000    '            was Me.ScaleHeight - 3000
   
End Sub

Private Sub Form_Load()
'

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

Dim ans As String * 1

   Select Case UnloadMode
      Case 0, 1
         ans$ = "Y"
         Confirm "?" & AppTitle$, "exit from " & AppTitle$, ans$, k
         If Not k.escd And UCase$(ans$) = "Y" Then
               Cancel = False
            Else
               Cancel = True
            End If
      Case Else
         Cancel = False
   End Select

End Sub

Private Sub Form_Resize()

   'Me.WindowState = 2

End Sub

Private Sub Form_Unload(Cancel As Integer)

   Close
   End

End Sub

Private Sub FTP1_Error(ErrorCode As Integer, Description As String)

'

End Sub

Private Sub MnHelp_Click()

   ShowAboutBox "HSSL Interface"
   
End Sub

Private Sub mnuFile_Click(index As Integer)

   Select Case index
      Case 0
         CreateHSSLOrder
      Case 2
         Unload Me
      Case Else
   End Select

End Sub

Private Sub MnuResend_Click(index As Integer)

Dim success%
Dim SvrReply$, UploadTime$

   LstDisplay.Clear

   HSSLScreenOutput ""
   HSSLScreenOutput ">> Logging on to FTP Server at " & HostIPAddr$
   success = FTPLogon(FTP1, HostIPAddr$, FTPUserName$, FTPPassword$, SvrReply$)
   HSSLScreenOutput "<< " & SvrReply$

   UploadTime$ = Format$(date, "yymmdd") & "." & Format$(Time, "hhmmss")
   
   If success And index = 0 Then
         HSSLScreenOutput ""
         HsslS29File$ = "sph." & UploadTime$
         HSSLScreenOutput ">> Sending S29 order to FTP host as file " & HsslS29File$
         FTPSend FTP1, ASCS29File$, HsslS29File$, SvrReply$, True
         HSSLScreenOutput "<< " & SvrReply$
      End If
   
   If success And index = 1 Then
         HSSLScreenOutput ""
         HsslCdFile$ = "scd." & UploadTime$
         HSSLScreenOutput ">> Sending CD order to FTP host as file " & HsslCdFile$
         FTPSend FTP1, ASCCdFile$, HsslCdFile$, SvrReply$, True
         HSSLScreenOutput "<< " & SvrReply$
      End If

   HSSLScreenOutput ""
   HSSLScreenOutput ">> Closing Connection to FTP Server at " & HostIPAddr$
   success = FTPLogoff(FTP1, SvrReply$)
   HSSLScreenOutput "<< " & SvrReply$


End Sub

Private Sub MnuResendTop_Click()

   MnuResend(0).Enabled = fileexists(ASCS29File$)
   MnuResend(1).Enabled = fileexists(ASCCdFile$)
   
End Sub

Private Sub MnuSetup_Click()

   HSSLSetup

End Sub

'14Nov08 CKJ No such control
'Private Sub TxtDisplay_KeyDown(KeyCode As Integer, Shift As Integer)
'
'   KeyCode = 0
'
'End Sub
'
'Private Sub TxtDisplay_KeyPress(KeyAscii As Integer)
'
'   KeyAscii = 0
'
'End Sub

