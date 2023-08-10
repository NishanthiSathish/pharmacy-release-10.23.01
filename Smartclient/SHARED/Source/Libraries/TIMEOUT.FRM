VERSION 5.00
Begin VB.Form frmTimeout 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   BorderStyle     =   1  'Fixed Single
   ClientHeight    =   1875
   ClientLeft      =   2715
   ClientTop       =   3465
   ClientWidth     =   5595
   ControlBox      =   0   'False
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
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1875
   ScaleWidth      =   5595
   Begin VB.PictureBox Panel3D1 
      Height          =   1755
      Left            =   60
      ScaleHeight     =   1695
      ScaleWidth      =   5415
      TabIndex        =   3
      Top             =   60
      Width           =   5475
      Begin VB.Label Label5 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         ForeColor       =   &H80000008&
         Height          =   1875
         Left            =   -60
         TabIndex        =   5
         Top             =   0
         Width           =   5655
      End
      Begin VB.Label Label2 
         Appearance      =   0  'Flat
         BackColor       =   &H000000C0&
         BorderStyle     =   1  'Fixed Single
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
         Height          =   315
         Left            =   2460
         TabIndex        =   1
         Top             =   600
         Width           =   60
      End
      Begin VB.Label Label4 
         Appearance      =   0  'Flat
         BackColor       =   &H00808080&
         BorderStyle     =   1  'Fixed Single
         ForeColor       =   &H80000008&
         Height          =   315
         Left            =   2460
         TabIndex        =   4
         Top             =   600
         Width           =   2415
      End
      Begin VB.Image Image1 
         Appearance      =   0  'Flat
         Height          =   480
         Left            =   300
         Picture         =   "TIMEOUT.frx":0000
         Top             =   480
         Width           =   480
      End
      Begin VB.Label Label3 
         Alignment       =   2  'Center
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BorderStyle     =   1  'Fixed Single
         Caption         =   "Press a key or click mouse button to cancel"
         ForeColor       =   &H80000008&
         Height          =   255
         Left            =   660
         TabIndex        =   0
         Top             =   1260
         Width           =   4215
      End
      Begin VB.Label Label1 
         Appearance      =   0  'Flat
         AutoSize        =   -1  'True
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Timing out ..."
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   240
         Left            =   945
         TabIndex        =   2
         Top             =   660
         Width           =   1365
      End
   End
   Begin VB.Timer Timer1 
      Interval        =   1000
      Left            =   180
      Top             =   2280
   End
End
Attribute VB_Name = "frmTimeout"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------------
'                      TIMEOUT Form
'
'13Aug96 CKJ Written.
'            This will be called from each form which requires a timeout
'            using the Timeout() function in GUIbits.
'            Note that the calling form should use the Microhelp timer
'            to preserve the scarce timer resources (15 total in Win 3.0)
'            This form has to use a genuine timer since it will normally
'            be called from within an MhTimer event ... which turns off
'            all Microhelp timers!
'
'            In use, the user has 10 secs to cancel the timeout, by
'            either pressing a key or clicking with the left button
'            on the timeout form.  Using the right button freezes
'            the countdown until a key or left button is pressed.
'
' To use this form, do the following:
'   1) Add the MicroHelp Timer VBX to the project; MHTO200.VBX
'   2) Add a MicroHelp timer to the form
'   3) Don't bother setting its properties - they are set automatically.
'
'      Note the max timeout is 65535 millisecs
'      This corresponds to 1 min 5.5 secs & is the max allowed. Note
'      that this precludes direct use on reports etc! For these, more
'      coding would be required to enable/disable the timer appropriately.
'
'   4) Add this code to the form, replacing CmdCancel_Click if required
'
'         Sub MhTimer1_Timer ()
'            If TimedOut() Then CmdCancel_Click    'assume Esc pressed
'         End Sub
'
'   5) Add the following where it will be executed if the user is
'      still busy with the form, e.g. in Form KeyPreview, MouseMove etc.
'      This sets the timer back to zero each time a user does something.
'
'         TimeoutON MhTimer1
'
'   6) Add lines similar to these to start & stop the form
'
'         Sub AnyForm_Activate ()
'            TimeoutON MhTimer1
'         End Sub
'
'         Sub AnyForm_DeActivate ()
'            TimeoutOFF MhTimer1
'         End Sub
'
'   7) Note that by checking if k.timd = true, progs can distinguish
'      between esc and timeout.  This is cleared & set automatically.
'
'NB If screen saver is active, need to somehow bring screen back to life
'
' 3Sep96 CKJ Changed Increment to 30 from 60
'            Display user ID & name if paused
' 8Mar97 CKJ Removed Beep on each increment - caused problems on PCs
'            without a hardware sound card
'23Mar97 CKJ Added text "Timing out ..." to clear the paused message
'-----------------------------------------------------------------------
Option Explicit
DefInt A-Z

Const Increment = 30

Private Sub ExitTimeout()
         
   Timer1.Enabled = False
   Label1 = "Timing out ..."        '23Mar97 CKJ Added
   Me.Tag = ""
   Me.Hide

End Sub

Private Sub Form_Activate()

   k.timd = False
   SoundTimeOut   '7Mar97 CKJ Added
   On Error Resume Next
   Timer1.interval = 250
   Timer1.Enabled = True
   On Error GoTo 0
   Label2.Width = 0
   Label2.Refresh
   
End Sub

Private Sub Form_Deactivate()
'!!** decide here if hidden form should still time out
'eg if ASCribe is overlayed by Word or Access
End Sub

Private Sub Form_KeyPress(KeyAscii As Integer)

   ExitTimeout
   
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then    'not unload via main prog
         Cancel = True
         Timer1.Enabled = False
         Me.Tag = ""
         Me.Hide
      End If

End Sub

Private Sub Label5_MouseDown(Button As Integer, Shift As Integer, x As Single, Y As Single)
' 3Sep96 CKJ Display user ID & name if paused

   If Button = 2 Then
         Timer1.Enabled = False
         Label1 = "Paused"
         If Len(Trim$(UserID$)) Then
               Label1 = Label1 & " by" & cr & UserID$
            End If
         If Len(Trim$(UserFullName$)) Then
               Label1 = Label1 & "   " & Trim$(UserFullName$)
            End If
      Else
         ExitTimeout
      End If

End Sub

Private Sub Timer1_Timer()

   If Label2.Width < 2400 Then
         Label2.Width = Label2.Width + Increment   ' 30 twips a time
         Me.Refresh
         'Beep          ' 8Mar97 CKJ Removed
      Else              ' Timed out
         k.timd = True
         Timer1.Enabled = False
         Me.Hide
      End If

End Sub

