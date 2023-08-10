VERSION 5.00
Begin VB.Form FrmPatPrint 
   Appearance      =   0  'Flat
   BackColor       =   &H8000000A&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Patient Printing"
   ClientHeight    =   3795
   ClientLeft      =   4080
   ClientTop       =   3120
   ClientWidth     =   5280
   ClipControls    =   0   'False
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
   Icon            =   "PATPRINT.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   PaletteMode     =   1  'UseZOrder
   ScaleHeight     =   3795
   ScaleWidth      =   5280
   Begin VB.CommandButton CmdSave 
      Appearance      =   0  'Flat
      Caption         =   "&Save"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   330
      Left            =   1530
      TabIndex        =   25
      Top             =   3375
      Visible         =   0   'False
      Width           =   1185
   End
   Begin VB.CheckBox ChkPreview 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Caption         =   "Pre&view"
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
      Height          =   240
      Left            =   90
      TabIndex        =   14
      Top             =   3375
      Width           =   1185
   End
   Begin VB.CommandButton CmdCancel 
      Appearance      =   0  'Flat
      Cancel          =   -1  'True
      Caption         =   "&Cancel"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   330
      Left            =   2790
      TabIndex        =   15
      Top             =   3375
      Width           =   1185
   End
   Begin VB.CommandButton CmdPrint 
      Appearance      =   0  'Flat
      Caption         =   "&Print"
      Default         =   -1  'True
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   8.25
         Charset         =   0
         Weight          =   400
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   330
      Left            =   4050
      TabIndex        =   16
      Top             =   3375
      Width           =   1185
   End
   Begin VB.Frame FraDocuments 
      Appearance      =   0  'Flat
      BackColor       =   &H8000000A&
      Caption         =   "Documents"
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
      Height          =   3210
      Left            =   45
      TabIndex        =   18
      Top             =   45
      Width           =   5190
      Begin VB.CheckBox ChkIssuesOnly 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
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
         Height          =   240
         Index           =   1
         Left            =   4410
         TabIndex        =   24
         Top             =   630
         Width           =   285
      End
      Begin VB.TextBox TxtCopies 
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
         Height          =   285
         Index           =   1
         Left            =   2970
         TabIndex        =   17
         Top             =   585
         Visible         =   0   'False
         Width           =   735
      End
      Begin VB.Frame FraDateRange 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
         Caption         =   "Date Range"
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
         Height          =   690
         Left            =   90
         TabIndex        =   22
         Top             =   2385
         Width           =   5010
         Begin VB.CheckBox ChkUseDate 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
            Caption         =   "&Use Date"
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
            Left            =   3915
            TabIndex        =   13
            Top             =   360
            Width           =   960
         End
         Begin VB.TextBox TxtDtFrom 
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
            Height          =   285
            Left            =   675
            TabIndex        =   10
            Top             =   270
            Width           =   1365
         End
         Begin VB.TextBox TxtDtTo 
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
            Height          =   285
            Left            =   2385
            TabIndex        =   12
            Top             =   270
            Width           =   1365
         End
         Begin VB.Label Label1 
            Alignment       =   1  'Right Justify
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "From"
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
            Height          =   285
            Left            =   135
            TabIndex        =   9
            Top             =   315
            Width           =   375
         End
         Begin VB.Label Label2 
            Alignment       =   1  'Right Justify
            Appearance      =   0  'Flat
            BackColor       =   &H80000005&
            BackStyle       =   0  'Transparent
            Caption         =   "To"
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
            Height          =   285
            Left            =   2070
            TabIndex        =   11
            Top             =   315
            Width           =   240
         End
      End
      Begin VB.Frame FraRxTypes 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
         Caption         =   "Prescripton Types"
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
         Height          =   1320
         Left            =   90
         TabIndex        =   21
         Top             =   990
         Width           =   5010
         Begin VB.CheckBox ChkRxType 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
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
            Height          =   240
            Index           =   8
            Left            =   2340
            TabIndex        =   8
            Top             =   990
            Visible         =   0   'False
            Width           =   1725
         End
         Begin VB.CheckBox ChkRxType 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
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
            Height          =   240
            Index           =   1
            Left            =   135
            TabIndex        =   1
            Top             =   315
            Visible         =   0   'False
            Width           =   1725
         End
         Begin VB.CheckBox ChkRxType 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
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
            Height          =   240
            Index           =   2
            Left            =   2340
            TabIndex        =   2
            Top             =   315
            Visible         =   0   'False
            Width           =   1725
         End
         Begin VB.CheckBox ChkRxType 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
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
            Height          =   240
            Index           =   3
            Left            =   135
            TabIndex        =   3
            Top             =   540
            Visible         =   0   'False
            Width           =   1725
         End
         Begin VB.CheckBox ChkRxType 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
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
            Height          =   240
            Index           =   4
            Left            =   2340
            TabIndex        =   4
            Top             =   540
            Visible         =   0   'False
            Width           =   1725
         End
         Begin VB.CheckBox ChkRxType 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
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
            Height          =   240
            Index           =   5
            Left            =   135
            TabIndex        =   5
            Top             =   765
            Visible         =   0   'False
            Width           =   1725
         End
         Begin VB.CheckBox ChkRxType 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
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
            Height          =   240
            Index           =   6
            Left            =   2340
            TabIndex        =   6
            Top             =   765
            Visible         =   0   'False
            Width           =   1725
         End
         Begin VB.CheckBox ChkRxType 
            Appearance      =   0  'Flat
            BackColor       =   &H8000000A&
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
            Height          =   240
            Index           =   7
            Left            =   135
            TabIndex        =   7
            Top             =   990
            Visible         =   0   'False
            Width           =   1725
         End
      End
      Begin VB.CheckBox ChkDoc 
         Appearance      =   0  'Flat
         BackColor       =   &H8000000A&
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
         Height          =   285
         Index           =   1
         Left            =   135
         TabIndex        =   0
         Top             =   585
         Visible         =   0   'False
         Width           =   2775
      End
      Begin VB.Label Label5 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Issues Only"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   -1  'True
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   285
         Left            =   4140
         TabIndex        =   23
         Top             =   360
         Width           =   960
      End
      Begin VB.Label Label4 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Copies"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   -1  'True
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   285
         Left            =   2970
         TabIndex        =   20
         Top             =   360
         Width           =   735
      End
      Begin VB.Label Label3 
         Appearance      =   0  'Flat
         BackColor       =   &H80000005&
         BackStyle       =   0  'Transparent
         Caption         =   "Document"
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   400
            Underline       =   -1  'True
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         ForeColor       =   &H80000008&
         Height          =   285
         Left            =   360
         TabIndex        =   19
         Top             =   315
         Width           =   1230
      End
   End
End
Attribute VB_Name = "FrmPatPrint"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'27Oct99 CFY Added ChkIssuesOnly Checkbox
'07Dec99 AW Added Save button and right mouse click popup menu
'14Dec99 CFY ChkDoc_MouseDown: Changed password level which allows configuration of patient printing
'            Form_Load: Changed password level which allows patient printing to be configured
'28Jan00 AW  ChkDoc_MouseDown: Changed to allow right mouse button to be clicked to edit pil descriptions.
'            Removed pop up menu. Document Name to be edited now depends on which description is clicked on.
'07Mar00 MMA/TH ChkDoc_Click: Changed label types become checked when document is selected
'11Sep00 AW/CKJ ChkDoc_Click: commented out code as reduced designed functionality.
'01Jun02 All/CKJ added defint a-z, no errors found

Option Explicit
DefInt A-Z

Private Sub ChkDoc_Click(Index As Integer)
'07Mar00 MMA/TH added so label types become checked when document is selected
'11Sep00 AW/CKJ commented out above mod as reduced designed functionality.
'27Jul04 TH Ignore errors here - v cheap way of ignoring referencing issues where some ctrls
'           will no longer be loaded (for interface option)
Dim i%, PatientTypes$

   On Error Resume Next  '27Jul04 TH Added as quick way to allow interface options to work

   If ChkDoc(Index).Value <> 1 Then
         TxtCopies(Index).Enabled = False
         ChkIssuesOnly(Index).Enabled = False
      Else
         TxtCopies(Index).Enabled = True
         ChkIssuesOnly(Index).Enabled = True
         '11Sep00 AW/CKJ commented out code below
         'PatientTypes$ = txtd(dispdata$ & "\patmed.ini", "", "", "PossiblePatientTypes", 0)'07Mar00 MMA/TH added
         'For i = 1 To Len(PatientTypes$)                                                   '       ''
         '   ChkRxType(i).Value = 1                                                         '       ''
         'Next                                                                              '       ''
      End If
      
   On Error GoTo 0       '27Jul04 TH
      
End Sub

Private Sub ChkDoc_MouseDown(Index As Integer, button As Integer, Shift As Integer, X As Single, Y As Single)
'07Dec99 AW Created Displays a pop up menu to allow Name of document to be edited
'            if null string entered original name kept
'14Dec99 CFY Changed password level which allows configuration of patient printing
'28Jan00 AW  Changed to allow right mouse button to be clicked to edit pil descriptions.
'            Removed pop up menu. Document Name to be edited now depends on which description is clicked on.
                                       

Dim ans$, text$, Newtext$
Dim DocEntries%, i%

   'If Mid$(acclevels$, 1, 1) = "8" Then              '14Dec99 CFY Replaced
   If Mid$(acclevels$, 1, 1) = "4" Then               '         "
         If button = 2 Then                           '28Jan00 AW changed
               'DocEntries% = Val(txtd(dispdata$ & "\patmed.ini", "PatientPrinting", "", "NumDocs", 0))
               'For i = 1 To DocEntries%
               '      text$ = ChkDoc(i).Caption
               '      popmenu 2, text$, True, False
               '   Next
               'popmenushow ans$, 500, 500
               Newtext$ = ChkDoc(Index).Caption
               k.escd = False
               InputWin "Edit Document Name", "Type in the new name of the document", Newtext$, k
               If Not k.escd Then
                     If Newtext$ <> "" Then
                           ChkDoc(Index).Caption = Newtext$
                        End If
                  End If
               FrmPatPrint.Refresh
               FraDocuments.Refresh
               FraRxTypes.Refresh
               FraDateRange.Refresh
               TxtDtFrom.Refresh
               TxtDtTo.Refresh
               DocEntries% = Val(TxtD(dispdata$ & "\patmed.ini", "PatientPrinting", "", "NumDocs", 0))
               For i = 1 To DocEntries%
                     ChkDoc(i).Refresh
                     TxtCopies(i).Refresh
                     ChkIssuesOnly(i).Refresh
                  Next
               DocEntries% = Len(TxtD(dispdata$ & "\patmed.ini", "", "", "PossiblePatientTypes", 0))
               For i = 1 To DocEntries%
                     ChkRxType(i).Refresh
                  Next
            End If
      End If
End Sub

Private Sub ChkUseDate_Click()

   If ChkUseDate.Value <> 1 Then
         TxtDtFrom.Enabled = False
         TxtDtTo.Enabled = False
      Else
         TxtDtFrom.Enabled = True
         TxtDtTo.Enabled = True
      End If
   
End Sub

Private Sub CmdCancel_Click()

   Unload Me

End Sub

Private Sub CmdPrint_Click()
   MinimizeAllApplication   'AS - MM-10837 10.22 - another application in focus when printing in pharmacy
   PatientPrinting

End Sub

Private Sub CmdSave_Click()
'06Dec99 AW

   PatientPrintingSave

End Sub

Private Sub Form_Load()
'07Dec99 Atw Added code to display Save button when password with sufficient access used
'14Dec99 CFY Changed password level which allows patient printing to be configured

   SetChrome Me '19Nov07 TH Added
   CentreForm Me
   'If Mid$(acclevels$, 1, 1) = "8" Then      '07Dec99 ATW Added     '14Dec99 CFY Replaced
   If Mid$(acclevels$, 1, 1) = "4" Then       '07Dec99 ATW Added     '     "
         CmdSave.Visible = True              '         "
      Else                                   '         "
         CmdSave.Visible = False             '         "
      End If                                 '         "
   PatientPrintFormInit

End Sub

