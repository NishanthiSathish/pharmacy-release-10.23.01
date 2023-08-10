VERSION 5.00
Begin VB.Form frmToolTip 
   Appearance      =   0  'Flat
   BackColor       =   &H00E0FFFF&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "frmToolTip"
   ClientHeight    =   540
   ClientLeft      =   3585
   ClientTop       =   2115
   ClientWidth     =   1860
   ClipControls    =   0   'False
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
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   540
   ScaleWidth      =   1860
   Visible         =   0   'False
   Begin VB.Timer tmrToolTip2 
      Enabled         =   0   'False
      Interval        =   5
      Left            =   1350
      Top             =   45
   End
   Begin VB.Timer tmrToolTip 
      Interval        =   1000
      Left            =   855
      Top             =   45
   End
   Begin VB.Label Label1 
      Appearance      =   0  'Flat
      AutoSize        =   -1  'True
      BackColor       =   &H0080FFFF&
      BackStyle       =   0  'Transparent
      Caption         =   "Label1"
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
      Height          =   195
      Left            =   210
      TabIndex        =   0
      Top             =   150
      Width           =   480
   End
End
Attribute VB_Name = "frmToolTip"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'This pseudo-object was written by AVS for v1.0.
'For this to work, you must include the tooltips.bas
'module.
'17Dec96 CKJ Added replace [cr]=>cr$
'12Nov99 CKJ Replaced MicroHelp Timers with real ones


Option Explicit
DefInt A-Z

Private Sub Form_Load()

   Me.Caption = ""                            'Get rid of title bar
   
   Label1.Left = 1 * Screen.TwipsPerPixelX    'Place label in form
   Label1.Top = 0

End Sub

Private Sub tmrToolTip_Timer()
' AVS wrote this routine for a timed tooltip: after a delay of
' g_TIP_PAUSE_TIME seconds, if mouse is still on trigger,
' tooltip will display for g_TIP_DISPLAY_TIME seconds.   v1.1
'17Dec96 CKJ Added replace [cr]=>cr$

Static last_MousePosition As POINTAPI
Dim MousePosition As POINTAPI
Dim ret As Integer
Dim CurrentWindow As Long
     
   Call GetCursorPos(MousePosition)                       'Get the current cursor position  'v1.2
   'Get current window (control) the mouse is over                                          'v1.2
   CurrentWindow = WindowFromPoint(MousePosition.Y, MousePosition.X)                        'v1.2
  
   'Proceed only if program still has input focus and the mouse is still on control         'v1.2
   If (GetActiveWindow() = g_hwndFormCallingTip) And (CurrentWindow = g_LastWindow) Then    'v1.2
         'If frmToolTip is not visible and the mouse has not moved from when the time was started
         If (Not frmToolTip.Visible) And g_Old_MousePosition.X = MousePosition.X And g_Old_MousePosition.Y = MousePosition.Y Then
               'We want to display the tool tip for 2 seconds (or mouse move)
               tmrToolTip.interval = g_TIP_DISPLAY_TIME                                     'v1.1
               'We want to display it only if not in old position (prevent flashing)
               If (last_MousePosition.X <> MousePosition.X) Or (last_MousePosition.Y <> MousePosition.Y) Then
                     frmToolTip.Hide
                     replace gMsg, "[cr]", cr, 0             '17Dec96 CKJ Added
                     frmToolTip.Label1.Caption = gMsg
                     frmToolTip.Top = (MousePosition.Y + 18) * Screen.TwipsPerPixelY
                     frmToolTip.Left = (MousePosition.X - 2) * Screen.TwipsPerPixelX
                     frmToolTip.Width = frmToolTip.Label1.Width + 4 * Screen.TwipsPerPixelX
                     frmToolTip.Height = frmToolTip.Label1.Height + 2 * Screen.TwipsPerPixelY
                     'Prevent Tooltip from extending off the right side of the screen        v1.2
                     If (frmToolTip.Left + frmToolTip.Width) > Screen.Width Then            'v1.2
                           frmToolTip.Left = Screen.Width - frmToolTip.Width - 1 * Screen.TwipsPerPixelY 'v1.2
                        End If                                                              'v1.2
                     'Prevent ToolTip from appearing off the bottom of the screen           'v1.2
                     If (frmToolTip.Top + frmToolTip.Height) > Screen.Height Then           'v1.2
                           frmToolTip.Top = (MousePosition.Y - 24) * Screen.TwipsPerPixelY  'v1.2
                        End If                                                              'v1.2
                     frmToolTip.ZOrder
                     ret = ShowWindow(frmToolTip.hWnd, 4)
                     last_MousePosition.X = MousePosition.X
                     last_MousePosition.Y = MousePosition.Y
                  Else 'Disable Timer to not come back here if mouse does not move
                     tmrToolTip.interval = 0
                     tmrToolTip2.Enabled = False                                            'v1.2
                  End If

            ElseIf frmToolTip.Visible Then    'hide frmToolTip and stop timer
               SleepTip
               'frmToolTip.Visible = False
               'tmrToolTip.Interval = 0
               'tmrToolTip2.Enabled = False                                                  'v1.2
            End If

      Else 'Program does not have input focus, so put tool tip to sleep
         SleepTip
         'frmToolTip.Visible = False
         'tmrToolTip.Interval = 0
         'tmrToolTip2.Enabled = False                                                        'v1.2
      End If

End Sub

Private Sub tmrToolTip2_Timer()
'Hides tip and disables timers if mouse is moved off of
'active control. Sub added with v1.2.
Dim CurrentWindow As Long
Dim MousePosition As POINTAPI
  
   Call GetCursorPos(MousePosition)         'Get pointer position

   'Get current window (control) the mouse is over
   CurrentWindow = WindowFromPoint(MousePosition.Y, MousePosition.X)

   If CurrentWindow <> g_LastWindow Then SleepTip
         'frmToolTip.Visible = False
         'tmrToolTip.Enabled = False
         'tmrToolTip2.Enabled = False
      'End If

End Sub

