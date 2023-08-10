VERSION 5.00
Begin VB.Form frmBlank 
   Appearance      =   0  'Flat
   AutoRedraw      =   -1  'True
   BackColor       =   &H80000005&
   BorderStyle     =   0  'None
   ClientHeight    =   1680
   ClientLeft      =   1095
   ClientTop       =   5625
   ClientWidth     =   3570
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
   ScaleHeight     =   1680
   ScaleWidth      =   3570
End
Attribute VB_Name = "frmBlank"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'----------------------------------------------------------------------------------
' Blank.frm
'
'13May97 CKJ This is a totally blank form, with no controls and no code!
'            Yes, it is useful and it is needed as a container for PrintScreen.
'            Properties: Autoredraw=True, No caption, control box, min/max buttons
'04Jun04 CKJ 32bit
'24Jun13 XN  Added default left, top width height so secrrtl works on any PC
'24Apr13 XN  Added DefaultLeft, DefaultTop, DefaultWidth, DefaultHeight  
'            So can have fixed seed (60910)
'----------------------------------------------------------------------------------
Option Explicit
DefInt A-Z

Public Property Get DefaultLeft() As Single
   DefaultLeft = 1095
End Property

Public Property Get DefaultTop() As Single
   DefaultTop = 5625
End Property

Public Property Get DefaultWidth() As Single
   DefaultWidth = 3570
End Property

Public Property Get DefaultHeight() As Single
   DefaultHeight = 1680
End Property
