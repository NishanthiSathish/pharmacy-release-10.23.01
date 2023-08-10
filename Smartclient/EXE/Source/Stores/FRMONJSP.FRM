VERSION 2.00
Begin Form frmONJSplash 
   AutoRedraw      =   -1  'True
   BorderStyle     =   0  'None
   Caption         =   "ONJsplash"
   ClientHeight    =   1860
   ClientLeft      =   5460
   ClientTop       =   3945
   ClientWidth     =   4665
   Height          =   2280
   Icon            =   FRMONJSP.FRX:0000
   Left            =   5400
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   1860
   ScaleWidth      =   4665
   Top             =   3585
   Width           =   4785
   Begin PictureBox PicLogo 
      AutoRedraw      =   -1  'True
      Height          =   1800
      Left            =   45
      Picture         =   FRMONJSP.FRX:0302
      ScaleHeight     =   1770
      ScaleWidth      =   4440
      TabIndex        =   0
      Top             =   15
      Width           =   4470
      Begin Label LblInfo 
         Alignment       =   2  'Center
         Caption         =   "Overnight Job"
         FontBold        =   -1  'True
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   9.75
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   285
         Left            =   75
         TabIndex        =   1
         Top             =   1485
         Width           =   4320
      End
   End
End
'  --------------------------------------------------------------------
'                       OVERNIGHT JOB START-UP FORM
'  --------------------------------------------------------------------
'
'This form is used instead of sub main, since that is already used in wdelord.bas
'the program then procededs to sub Overnight in Overnight.Bas

'
'25Jan00 AE Written
'10Feb00 AE Form_Load: Changed to use new procedure ONJReadSiteInfo.  This does the
'              Same as ReadSiteInfo, but uses ONJLivePath instead of the
'              current drive.  This removes the need to give the program a
'              mapped drive as a parameter.
'           EnquireDrives: Written for debug use only, not used now.
'01Mar00 AE Form_Load: Moved code from here to Overnight. Now only asks for password after the
'              Live Drive has been set.
'22Nov00 CKJ Form_Load: ReadSiteInfo is not called until well into the program, so pseudo-constants set explicitly at start
'21May01 AE  FrmONJSp: Changed to use main version instead of the ONJ specific one.  This had been done in 8.3r3 but appears
'            to have been lost somewhere along the line
'01oct03 CKJ added brackets on ASCver()

Option Explicit
DefInt A-Z

Sub EnquireDrives ()
'
'Debug option. Poll the available drives for a given time, or until
'the drive specified on the command line is found.

'10Feb00 AE  For testing only, now defunct and not used

Static iCount  As Integer

Dim n As Integer, iValue As Integer
Dim sDrv As String, sList As String, sSrchDrv As String
Dim iFound As Integer, iFinished As Integer

tb$ = Chr$(9)

   iFinished = False

   sSrchDrv = UCase(Mid$(Command$, InStr(Command$, ":") - 1, 1))

   For n = Asc("Z") To Asc("E") Step -1
      sDrv = Chr$(n) & ":\"
      On Error Resume Next
      iValue = GetAttr(sDrv)                       '(ATTR_READONLY = 1)
      If Err = 0 And Not (iValue And 1) Then       'device available, and not (readonly)
            sList = sList & sDrv & ", "
            If Left$(sDrv, 1) = sSrchDrv Then iFound = True
         End If
   Next

   ONJLog "Found Drives: " & sList & tb$ & Format$(Now, "hh:mm:ss"), False, False, False, False
   If Not iFound Then iCount = iCount + 1
   If iCount = 30 Then                             '5 minutes
         ONJLog "Timed out...Quitting." & tb$ & tb$ & Format$(Now, "hh:mm:ss"), False, False, False, False
         iFinished = True
      End If

   If iFound Then
         ONJLog "Found drive " & sSrchDrv & ":\" & tb$ & tb$ & tb$ & Format$(Now, "hh:mm:ss"), False, False, False, False
         iFinished = True
      End If

   If iFound Then Me.Hide

End Sub

Sub Form_Load ()

'10Feb00 AE  Changed to use new procedure ONJReadSiteInfo.  This does the
'            Same as ReadSiteInfo, but uses ONJLivePath instead of the
'            current drive.  This removes the need to give the program a
'            mapped drive as a parameter.
'01Mar00 AE  Moved code from here to Overnight. Now only asks for password after the
'            Live Drive has been set.
'22Nov00 CKJ ReadSiteInfo is not called until well into the program, so pseudo-constants set explicitly at start
'21May01 AE  Changed to use main version instead of the ONJ specific one.  This had been done in 8.3r3 but appears
'            to have been lost somewhere along the line
'01oct03 CKJ added brackets on ASCver()

Dim iSetupMode As Integer, iFound As Integer
Dim sTmp As String, n As Integer, sDummy As String
Dim sPath As String, sMsg As String
Dim sCommand As String, iPos As Integer                               '10Feb00 AE
Dim iFinished As Integer, sDrv As String, iAutoMapped As Integer                             '    "
Dim iFailed As Integer

   cr$ = Chr$(13)      '22Nov00 CKJ Added, since these pseudo-constants are essential for the program to run.
   lf$ = Chr$(10)      '   "
   crlf$ = cr & lf     '   "
   tb$ = Chr$(9)       '   "

   On Error GoTo ONJError
   If App.PrevInstance Then
         popmessagecr ".Overnight Job", "Cannot Start more than one copy of the Overnight Job"
         Error 5001
      End If

   Me.Height = PicLogo.Height
   Me.Width = PicLogo.Width
   PicLogo.Left = 0
   PicLogo.Top = 0
   LblINfo.Caption = "Overnight Job " & AscVer() & AscRelease          '21May01 AE  Changed to use main version   '01oct03 CKJ added brackets on ASCver()
   HorizCentreForm Me
   Me.Top = (Screen.Height / 2) - (Screen.Height / 3)
   
   Me.Show 0                           'Show splash screen whilst loading; not necessary if not required.

   DoSaferEvents 1

   'Check for a non-standard live drive, ie one on a different drive to the program.
   sTmp = ReadPrivateIniFile(AppPathNoSlash() & ONJIniFile, "", "NonStandardLivePath")             '01Mar00 AE  Changed to use wrapper function
   If sTmp <> "" Then
         SetONJLivePath sTmp
      Else
         GetLivePath
      End If

   'Check that data on the live drive is accessible; otherwise, Readsiteinfo goes into
'01Mar00 AE  Moved block into Overnite. Commented out code deleted for clarity

   iSetupMode = False
   If InStr(LCase(Command$), "/run") = 0 Then iSetupMode = 2          'Re-Enter Setup if /run not found
   If InStr(LCase(Command$), "/test") <> 0 Then iSetupMode = 3       'or if /test on command line; in this case go straight into a test run
   
   'Search ini file, to determine if this is the first run or not
   sTmp = ReadPrivateIniFile(AppPathNoSlash() & ONJIniFile, "", "LastRan")                         '01Mar00 AE
   If sTmp = "" Then
         iSetupMode = 1
      End If

'   Select Case iSetupMode
'      Case 1, 2                                      '01Mar00 AE  Changed; only asks for pasword after live drive is chosen.
'         GetONJPassword
'      End Select
'   Me.Hide

   OverNight iSetupMode                               '<= Entry point to main program
   
ONJExit:

   On Error Resume Next
   Close                                        'Close everything
            
   'Unload all forms
   'Unload this form last
   Do
      If Forms(0).hWnd = Me.hWnd And Forms.Count > 1 Then
            Unload Forms(1)
         Else
            Unload Forms(n)
         End If
   Loop Until Forms.Count <= 1
   Unload Me
   'End

   Exit Sub

ONJError:

   Select Case Err
      Case 5001         'Generic failed -> quit error
         Resume ONJExit
      
      Case Else
         Resume ONJExit
      End Select


End Sub

