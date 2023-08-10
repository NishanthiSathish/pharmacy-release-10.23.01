VERSION 5.00
Begin VB.Form PopMnu 
   Appearance      =   0  'Flat
   BackColor       =   &H80000005&
   Caption         =   "Popup Menu"
   ClientHeight    =   1365
   ClientLeft      =   3720
   ClientTop       =   1950
   ClientWidth     =   2820
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
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   1365
   ScaleWidth      =   2820
   Visible         =   0   'False
   Begin VB.Menu mnuTop 
      Caption         =   ""
      Begin VB.Menu mnuItem 
         Caption         =   ""
         Enabled         =   0   'False
         Index           =   0
      End
   End
End
Attribute VB_Name = "PopMnu"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'-----------------------------------------------------------------------
'          PopMenu.frm
'
'See PopMenu and PopMenuShow for usage
'Do not show this form directly
'
'07Jun04 CKJ removed Hide - seems not to be needed in 32bit
'-----------------------------------------------------------------------
Option Explicit
DefInt A-Z

Private Sub Form_Activate()

   Me.Tag = ""

End Sub

Private Sub Form_Load()

   SetChrome Me
   
End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then   'anything other than from code
         Me.Tag = ""
         'Hide
      End If

End Sub

Private Sub mnuItem_Click(index As Integer)

   Me.Tag = Format$(index)
   'Hide

End Sub

