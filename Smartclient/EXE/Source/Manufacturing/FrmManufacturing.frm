VERSION 5.00
Begin VB.Form FrmManufacturing 
   Caption         =   "Manufacturing"
   ClientHeight    =   3195
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   Icon            =   "FrmManufacturing.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   3195
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   WindowState     =   2  'Maximized
End
Attribute VB_Name = "FrmManufacturing"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'------------------------------------------------------------------------------------
'                                Manufacturing
'------------------------------------------------------------------------------------
'13oct08 CKJ Token handling corrected  F0035499
'24Apr13 XN  Form_Load: Changed connection string encryption seed to work on any PC  (60910)

Option Explicit
DefBool A-Z

Private Sub Form_Load()
   
   SetChrome Me
'   frmBlank.Tag = Format$(((1# * frmBlank.top * frmBlank.Left) / frmBlank.Width) * frmBlank.Height)      '13oct08 CKJ added
   frmBlank.Tag = Format$(((1# * frmBlank.DefaultTop * frmBlank.DefaultLeft) / frmBlank.DefaultWidth) * frmBlank.DefaultHeight)  '24Apr13 XN 60910 Changed connection string encryption seed to work on any PC

End Sub

Public Sub startupManufacturing()
   callmanufacturing d, 9, False
End Sub

Private Sub Form_Resize()
   Me.WindowState = 2
End Sub
