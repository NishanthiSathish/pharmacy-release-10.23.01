VERSION 5.00
Begin VB.Form frmHeap 
   Appearance      =   0  'Flat
   BackColor       =   &H80000005&
   Caption         =   "Heap Handler"
   ClientHeight    =   16995
   ClientLeft      =   1530
   ClientTop       =   345
   ClientWidth     =   11970
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
   Icon            =   "FRMHEAP.frx":0000
   LinkTopic       =   "Form1"
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   16995
   ScaleWidth      =   11970
   Visible         =   0   'False
   Begin VB.ListBox lstHeap 
      Appearance      =   0  'Flat
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   16995
      Index           =   0
      Left            =   0
      MultiSelect     =   2  'Extended
      TabIndex        =   0
      TabStop         =   0   'False
      Top             =   0
      Visible         =   0   'False
      Width           =   11985
   End
End
Attribute VB_Name = "frmHeap"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'----------------------------------------------------------
'                      HEAP MANAGER
'                      ------------
'
'13Jan98 CKJ Written
'            Never call this form directly
'            See Corelib: Heap
'23Apr98 CKJ Added popmessage on double click for debugging
'            Set form to .enabled = true at design time since
'            it seems to be ignored at run time
'25Sep98 CKJ List box now set unsorted, Heap specifies position
'28Oct99 CKJ Resize listboxes, and hide form with Esc or Tab
'09May05 CKJ Multiselect & copy added
'            Now full height on 1200x1600
'----------------------------------------------------------

Option Explicit
DefInt A-Z

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode <> 1 Then
         Cancel = True
         Me.Hide
      End If

End Sub

Private Sub Form_Resize()
'28Oct99 CKJ Written

Dim IDnum%

   On Error Resume Next
   For IDnum = 0 To Me.Controls.count - 1
      If TypeOf Me.Controls(IDnum) Is ListBox Then
            lstHeap(IDnum).Move 0, 0, Me.ScaleWidth, Me.ScaleHeight
         End If
   Next
   On Error GoTo 0

End Sub

Private Sub lstHeap_DblClick(index As Integer)
'23Apr98 CKJ Added for debugging

   If Len(lstHeap(index).Text) Then
         popmessagecr "", (lstHeap(index).Text)
      End If

End Sub

Private Sub lstHeap_KeyDown(index As Integer, KeyCode As Integer, Shift As Integer)
'09May05 CKJ Multiselect & copy added

Dim strBuffer As String
Dim iLoop As Integer

   'frmHeap.Caption = Format$(KeyCode) & "         " & Format$(Shift)      'for test only
   
   Select Case Shift
      Case 2                     'ctrl
         Select Case KeyCode
            Case 65              'A       select all
               For iLoop = 0 To lstHeap(index).ListCount - 1
                  lstHeap(index).Selected(iLoop) = True
               Next

            Case 45, 67          'Ins, C  copy
               For iLoop = 0 To lstHeap(index).ListCount - 1
                  If lstHeap(index).Selected(iLoop) Then
                     strBuffer = strBuffer & lstHeap(index).List(iLoop) & crlf
                  End If
               Next
               Clipboard.Clear
               Clipboard.SetText strBuffer, ClipBoardConstants.vbCFText   'copy line(s) to clipboard
            End Select
      End Select
      
End Sub

Private Sub lstHeap_KeyPress(index As Integer, KeyAscii As Integer)
'28Oct99 CKJ Added for debugging

   Select Case KeyAscii
      Case KEY_RETURN
         KeyAscii = 0
         If Len(lstHeap(index).Text) Then popmessagecr "", (lstHeap(index).Text)
      
      Case KEY_TAB, KEY_ESCAPE
         KeyAscii = 0
         Me.Hide
      
      End Select

End Sub

