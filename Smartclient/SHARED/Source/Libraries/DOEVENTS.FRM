VERSION 5.00
Begin VB.Form frmDoEvents 
   Appearance      =   0  'Flat
   BackColor       =   &H80000005&
   BorderStyle     =   0  'None
   Caption         =   "DoEventsMoreSafely"
   ClientHeight    =   5820
   ClientLeft      =   1095
   ClientTop       =   1485
   ClientWidth     =   7365
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
   ScaleHeight     =   5820
   ScaleWidth      =   7365
End
Attribute VB_Name = "frmDoEvents"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'------------------------------------------------------------------------
'                             DoEvents
'
'module name: \libfiles\DoEvents.frm
'form name  : frmDoEvents
'origin     : VBPJ
'
'18Sep97 CKJ Written. Derived from an idea in VBPJ online tips, to use a
'            modal form which is not on the visible part of the screen to
'            host a call to DoEvents. This allows control to be
'            relinquished but without some of the problems associated
'            with users clicking on menus etc. I do not expect this will
'            solve all problems - program will probably service any queued
'            events, but will stop the user choosing undesired options.
'            The form unloads or hides on completion under program control.
'            A handler proc must be used, and this form must never be called
'            directly. Enforced this by using the Tag. Added freelocks.
'            To use, see DoSaferEvents in Corelib
'
'
'mods wanted
'-----------
' Very safe option - call this as a child (Shelled) process
'
'
'------------------------------------------------------------------------

DefInt A-Z
Option Explicit

Private Sub Form_Activate()
' me.tag = "0"  Unload only
'          "1"  DoEvents then Unload
'          "2"  DoEvents then Hide
'          ""   Error - must call this via the wrapper DoSaferEvents

   Select Case Me.Tag
      Case ""
         popmessagecr "Programming error", "Form DoEvents called directly, bypassing wrapper function"
      Case "0"
         'no action
      Case Else
         ''SQLFreeLocks
         DoEvents
      End Select

   If Me.Tag = "2" Then
         Me.Tag = ""
         Me.Hide
      Else
         Me.Tag = ""
         Unload Me
      End If

End Sub

Private Sub Form_Load()
   
   Left = Width * -1
   Top = Height * -1

End Sub

