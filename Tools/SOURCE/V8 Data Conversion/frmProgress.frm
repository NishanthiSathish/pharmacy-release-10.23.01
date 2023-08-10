VERSION 5.00
Begin VB.Form frmProgress 
   ClientHeight    =   1110
   ClientLeft      =   60
   ClientTop       =   60
   ClientWidth     =   5475
   ControlBox      =   0   'False
   Icon            =   "frmProgress.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   ScaleHeight     =   1110
   ScaleWidth      =   5475
   StartUpPosition =   3  'Windows Default
   Begin VB.Label lblSiteNumber 
      AutoSize        =   -1  'True
      Caption         =   "Site Number: "
      Height          =   195
      Left            =   1950
      TabIndex        =   4
      Top             =   120
      Width           =   960
   End
   Begin VB.Label lblMax 
      Caption         =   "0"
      Height          =   195
      Left            =   2910
      TabIndex        =   3
      Top             =   720
      Width           =   1395
   End
   Begin VB.Label lblOf 
      Alignment       =   1  'Right Justify
      AutoSize        =   -1  'True
      Caption         =   " of "
      Height          =   195
      Left            =   2640
      TabIndex        =   2
      Top             =   720
      Width           =   225
   End
   Begin VB.Label lblNow 
      Alignment       =   1  'Right Justify
      Caption         =   "0"
      Height          =   195
      Left            =   1200
      TabIndex        =   1
      Top             =   720
      Width           =   1395
   End
   Begin VB.Label lblAction 
      AutoSize        =   -1  'True
      Caption         =   "Converting the "
      Height          =   195
      Left            =   210
      TabIndex        =   0
      Top             =   360
      Width           =   1080
   End
End
Attribute VB_Name = "frmProgress"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
DefInt A-Z

Private Const CLASS_NAME = "FrmProgress"

Public Sub ProgressHide()
'----------------------------------------------------------------------------------
'
' Purpose: Hides the modeless progress form
'
' Inputs:
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  02Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ProgressHide"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   Me.Hide
   
   DoEvents

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Sub

Public Sub ShowProgress(ByVal SiteNumber As String, _
                        ByVal Caption As String, _
                        ByVal MaxValue As Long)
'----------------------------------------------------------------------------------
'
' Purpose: Loads and shows the progress form.
'
' Inputs:
'     Caption        :  The text telling the user what is being done
'     MaxValue       :  The maximum number of records to be processed.
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  02Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ShowProgress"

Dim udtError As udtErrorState
                        
Dim lngPosn As Long

   On Error GoTo ErrorHandler

   'position the modeless form in the centre of the main form
   Me.Left = frmMain.Left + (frmMain.Width / 2) - (Me.Width / 2)
   
   Me.Top = frmMain.Top + (frmMain.height / 2) - (Me.height / 2)
   
   'set the site number label
   lblSiteNumber.Caption = "Site Number: " & SiteNumber
   
   'center the site number label
   lngPosn = (Me.ScaleWidth - lblSiteNumber.Width) / 2
   
   If lngPosn < 20 Then lngPosn = 20
   
   lblSiteNumber.Left = lngPosn
   
   'set the action being performed
   lblAction.Caption = Caption
   
   'center the action label
   lngPosn = (Me.ScaleWidth - lblAction.Width) / 2
   
   If lngPosn < 20 Then lngPosn = 20
   
   lblAction.Left = lngPosn
   
   'hide the X of y labels if y = 0
   If (MaxValue = 0) Then
      lblNow.Visible = False
      lblOf.Visible = False
      lblMax.Visible = False
   Else
      lblNow.Visible = True
      lblOf.Visible = True
      lblMax.Visible = True
   End If
   
   'set the number of records being processed
   lblMax.Caption = Format$(MaxValue)
   
   'zero the count
   lblNow.Caption = "0"
   
   'show the form
   Me.Show vbModeless

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Public Sub UpdateProgress(ByVal CurrentValue As Long)
'----------------------------------------------------------------------------------
'
' Purpose: Updates the progress on the modeless progress form
'
' Inputs:
'     CurrentValue        :  The number of the record currently being processed
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  02Oct07 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "UpdateProgress"

Dim udtError As udtErrorState


   On Error GoTo ErrorHandler

   lblNow.Caption = Format$(CurrentValue)
   
   Me.Refresh
   
   DoEvents

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub



