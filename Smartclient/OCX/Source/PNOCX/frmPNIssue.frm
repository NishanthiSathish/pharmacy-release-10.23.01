VERSION 5.00
Begin VB.Form frmPNIssue 
   Caption         =   "Parenteral Nutrition Issue"
   ClientHeight    =   11115
   ClientLeft      =   7665
   ClientTop       =   345
   ClientWidth     =   15135
   LinkTopic       =   "Form1"
   ScaleHeight     =   11115
   ScaleWidth      =   15135
   Begin VB.CommandButton cmdWarnings 
      Caption         =   "View &Warnings"
      Height          =   495
      Left            =   13680
      TabIndex        =   4
      Top             =   10800
      Width           =   1335
   End
   Begin VB.CommandButton cmdLog 
      Caption         =   "&View Logs"
      Height          =   495
      Left            =   12480
      TabIndex        =   3
      Top             =   10800
      Width           =   1095
   End
   Begin VB.Frame Frame2 
      Caption         =   "Supply Details"
      Height          =   1935
      Left            =   6360
      TabIndex        =   145
      Top             =   240
      Width           =   8655
      Begin VB.Label lblRegimen 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   9.75
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   615
         Left            =   960
         TabIndex        =   153
         Top             =   360
         Width           =   7455
         WordWrap        =   -1  'True
      End
      Begin VB.Label lblRegimenDesc 
         Caption         =   "Regimen"
         Height          =   375
         Left            =   120
         TabIndex        =   152
         Top             =   360
         Width           =   735
      End
      Begin VB.Label lblOverageDesc 
         Caption         =   "Overage"
         Height          =   255
         Left            =   120
         TabIndex        =   151
         Top             =   1080
         Width           =   735
      End
      Begin VB.Label lblOverage 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   960
         TabIndex        =   150
         Top             =   1080
         Width           =   7215
      End
      Begin VB.Label lblBatchDesc 
         Caption         =   "Batch"
         Height          =   255
         Left            =   120
         TabIndex        =   149
         Top             =   1440
         Width           =   615
      End
      Begin VB.Label lblBatch 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   960
         TabIndex        =   148
         Top             =   1440
         Width           =   4215
      End
      Begin VB.Label lblBagsDesc 
         Caption         =   "No. of Bags"
         Height          =   255
         Left            =   6360
         TabIndex        =   147
         Top             =   1440
         Width           =   855
      End
      Begin VB.Label lblBags 
         Alignment       =   1  'Right Justify
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   7320
         TabIndex        =   146
         Top             =   1440
         Width           =   615
      End
   End
   Begin VB.Frame Frame1 
      Caption         =   "Patient Details"
      Height          =   1935
      Left            =   120
      TabIndex        =   132
      Top             =   240
      Width           =   6015
      Begin VB.Label lblPatNameCaption 
         Caption         =   "Name"
         Height          =   255
         Left            =   120
         TabIndex        =   144
         Top             =   360
         Width           =   495
      End
      Begin VB.Label lblPatientName 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   720
         TabIndex        =   143
         Top             =   360
         Width           =   5055
      End
      Begin VB.Label Label3 
         Caption         =   "DOB"
         Height          =   255
         Left            =   120
         TabIndex        =   142
         Top             =   840
         Width           =   495
      End
      Begin VB.Label lblDOB 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   720
         TabIndex        =   141
         Top             =   840
         Width           =   1095
      End
      Begin VB.Label Label4 
         Caption         =   "Age"
         Height          =   255
         Left            =   1920
         TabIndex        =   140
         Top             =   840
         Width           =   375
      End
      Begin VB.Label lblAge 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   2400
         TabIndex        =   139
         Top             =   840
         Width           =   1575
      End
      Begin VB.Label Label5 
         Caption         =   " Weight"
         Height          =   255
         Left            =   4080
         TabIndex        =   138
         Top             =   840
         Width           =   615
      End
      Begin VB.Label lblWeight 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   4785
         TabIndex        =   137
         Top             =   840
         Width           =   1095
      End
      Begin VB.Label lblNHSdesc 
         Caption         =   "National Identifier"
         Height          =   255
         Left            =   120
         TabIndex        =   136
         Top             =   1320
         Width           =   1335
      End
      Begin VB.Label lblNHS 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   1560
         TabIndex        =   135
         Top             =   1320
         Width           =   1335
      End
      Begin VB.Label lblCaseNoDesc 
         Caption         =   "Hospital Number"
         Height          =   255
         Left            =   3000
         TabIndex        =   134
         Top             =   1320
         Width           =   1215
      End
      Begin VB.Label lblCaseNo 
         BeginProperty Font 
            Name            =   "MS Sans Serif"
            Size            =   8.25
            Charset         =   0
            Weight          =   700
            Underline       =   0   'False
            Italic          =   0   'False
            Strikethrough   =   0   'False
         EndProperty
         Height          =   255
         Left            =   4560
         TabIndex        =   133
         Top             =   1320
         Width           =   1215
      End
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   19
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   44
      Top             =   8160
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   18
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   42
      Top             =   7800
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   17
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   40
      Top             =   7440
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   16
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   38
      Top             =   7080
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   15
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   36
      Top             =   6720
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   14
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   34
      Top             =   6480
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   13
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   32
      Top             =   6120
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   12
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   30
      Top             =   5760
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   11
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   28
      Top             =   5400
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   10
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   26
      Top             =   5040
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   9
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   24
      Top             =   4680
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   8
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   22
      Top             =   4320
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   7
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   20
      Top             =   3960
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   6
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   18
      Top             =   3600
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   5
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   16
      Top             =   3240
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   4
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   14
      Top             =   3120
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   3
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   12
      Top             =   3000
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   2
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   10
      Top             =   2880
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   1
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   8
      Top             =   2880
      Width           =   855
   End
   Begin VB.TextBox txtWaste 
      Height          =   300
      Index           =   0
      Left            =   4200
      MaxLength       =   9
      TabIndex        =   6
      Top             =   3240
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   19
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   43
      Top             =   8160
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   18
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   41
      Top             =   7800
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   17
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   39
      Top             =   7440
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   16
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   37
      Top             =   7080
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   15
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   35
      Top             =   6720
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   14
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   33
      Top             =   6480
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   13
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   31
      Top             =   6120
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   12
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   29
      Top             =   5760
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   11
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   27
      Top             =   5400
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   10
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   25
      Top             =   5040
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   9
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   23
      Top             =   4680
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   8
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   21
      Top             =   4320
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   7
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   19
      Top             =   3960
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   6
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   17
      Top             =   3600
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   5
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   15
      Top             =   3240
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   4
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   13
      Top             =   3120
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   300
      Index           =   3
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   11
      Top             =   3120
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   285
      Index           =   2
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   9
      Top             =   3000
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   300
      Index           =   1
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   7
      Top             =   2880
      Width           =   855
   End
   Begin VB.TextBox txtQty 
      Height          =   300
      Index           =   0
      Left            =   3240
      MaxLength       =   9
      TabIndex        =   5
      Top             =   2760
      Width           =   855
   End
   Begin VB.CommandButton cmdCancel 
      Cancel          =   -1  'True
      Caption         =   "&No"
      Default         =   -1  'True
      Height          =   495
      Left            =   11280
      TabIndex        =   2
      Top             =   10800
      Width           =   1095
   End
   Begin VB.CommandButton cmdOK 
      Caption         =   "&Yes"
      Height          =   495
      Left            =   10080
      TabIndex        =   1
      Top             =   10800
      Width           =   1095
   End
   Begin VB.Label lblAllWarnings 
      Height          =   1095
      Left            =   480
      TabIndex        =   154
      Top             =   9480
      Visible         =   0   'False
      Width           =   15135
      WordWrap        =   -1  'True
   End
   Begin VB.Label lblhdrUnit 
      Caption         =   "Unit"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   5940
      TabIndex        =   131
      Top             =   2425
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   19
      Left            =   5160
      TabIndex        =   130
      Top             =   8160
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   18
      Left            =   5160
      TabIndex        =   129
      Top             =   7920
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   17
      Left            =   5160
      TabIndex        =   128
      Top             =   7560
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   16
      Left            =   5160
      TabIndex        =   127
      Top             =   7200
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   15
      Left            =   5160
      TabIndex        =   126
      Top             =   6840
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   14
      Left            =   5160
      TabIndex        =   125
      Top             =   6480
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   13
      Left            =   5160
      TabIndex        =   124
      Top             =   6120
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   12
      Left            =   5160
      TabIndex        =   123
      Top             =   5760
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   11
      Left            =   5160
      TabIndex        =   122
      Top             =   5400
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   10
      Left            =   5160
      TabIndex        =   121
      Top             =   5040
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   9
      Left            =   5160
      TabIndex        =   120
      Top             =   4680
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   8
      Left            =   5160
      TabIndex        =   119
      Top             =   4320
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   7
      Left            =   5160
      TabIndex        =   118
      Top             =   3960
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   6
      Left            =   5160
      TabIndex        =   117
      Top             =   3600
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   5
      Left            =   5160
      TabIndex        =   116
      Top             =   3240
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   4
      Left            =   5160
      TabIndex        =   115
      Top             =   2880
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   3
      Left            =   5160
      TabIndex        =   114
      Top             =   2400
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   2
      Left            =   5160
      TabIndex        =   113
      Top             =   2880
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   1
      Left            =   5160
      TabIndex        =   112
      Top             =   3000
      Width           =   615
   End
   Begin VB.Label lblStock 
      Height          =   255
      Index           =   0
      Left            =   5160
      TabIndex        =   111
      Top             =   3120
      Width           =   615
   End
   Begin VB.Label lblhdrStock 
      Alignment       =   2  'Center
      Caption         =   "Stock level"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   5120
      TabIndex        =   110
      Top             =   2300
      Width           =   735
   End
   Begin VB.Label lblWaste 
      Alignment       =   2  'Center
      Caption         =   "Waste Qty"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   4200
      TabIndex        =   109
      Top             =   2300
      Width           =   855
   End
   Begin VB.Label lblProd 
      Caption         =   "Pharmacy Product / Information"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   6540
      TabIndex        =   108
      Top             =   2425
      Width           =   4095
   End
   Begin VB.Label LBLQty 
      Alignment       =   2  'Center
      Caption         =   "Issue Qty"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   495
      Left            =   3360
      TabIndex        =   107
      Top             =   2300
      Width           =   615
   End
   Begin VB.Label Label1 
      Caption         =   "Product"
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   255
      Left            =   240
      TabIndex        =   106
      Top             =   2420
      Width           =   2775
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   19
      Left            =   6525
      TabIndex        =   105
      Top             =   8400
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   18
      Left            =   6525
      TabIndex        =   104
      Top             =   7920
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   17
      Left            =   6525
      TabIndex        =   103
      Top             =   7440
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   16
      Left            =   6525
      TabIndex        =   102
      Top             =   7080
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   15
      Left            =   6525
      TabIndex        =   101
      Top             =   6600
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   14
      Left            =   6525
      TabIndex        =   100
      Top             =   6240
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   13
      Left            =   6525
      TabIndex        =   99
      Top             =   5880
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   12
      Left            =   6525
      TabIndex        =   98
      Top             =   5520
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   11
      Left            =   6525
      TabIndex        =   97
      Top             =   5160
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   10
      Left            =   6525
      TabIndex        =   96
      Top             =   4560
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   9
      Left            =   6525
      TabIndex        =   95
      Top             =   4320
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   8
      Left            =   6525
      TabIndex        =   94
      Top             =   4080
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   7
      Left            =   6525
      TabIndex        =   93
      Top             =   3840
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   6
      Left            =   6525
      TabIndex        =   92
      Top             =   3600
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   5
      Left            =   6525
      TabIndex        =   91
      Top             =   3360
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   4
      Left            =   6525
      TabIndex        =   90
      Top             =   3000
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   3
      Left            =   6525
      TabIndex        =   89
      Top             =   2640
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   2
      Left            =   6525
      TabIndex        =   88
      Top             =   3000
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   1
      Left            =   6525
      TabIndex        =   87
      Top             =   2640
      Width           =   8500
   End
   Begin VB.Label lblInfo 
      Height          =   300
      Index           =   0
      Left            =   6525
      TabIndex        =   86
      Top             =   2640
      Width           =   8500
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   11
      Left            =   240
      TabIndex        =   85
      Top             =   5400
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   10
      Left            =   240
      TabIndex        =   84
      Top             =   5040
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   12
      Left            =   240
      TabIndex        =   83
      Top             =   5760
      Width           =   3000
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   20
      Left            =   6000
      TabIndex        =   82
      Top             =   8280
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   19
      Left            =   6000
      TabIndex        =   81
      Top             =   7920
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   18
      Left            =   6000
      TabIndex        =   80
      Top             =   7560
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   17
      Left            =   6000
      TabIndex        =   79
      Top             =   7200
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   16
      Left            =   6000
      TabIndex        =   78
      Top             =   6840
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   15
      Left            =   6000
      TabIndex        =   77
      Top             =   6480
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   14
      Left            =   6000
      TabIndex        =   76
      Top             =   6120
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   13
      Left            =   6000
      TabIndex        =   75
      Top             =   5760
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   12
      Left            =   6000
      TabIndex        =   74
      Top             =   5400
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   11
      Left            =   6000
      TabIndex        =   73
      Top             =   5040
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   10
      Left            =   6000
      TabIndex        =   72
      Top             =   4680
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   9
      Left            =   6000
      TabIndex        =   71
      Top             =   4320
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   8
      Left            =   6000
      TabIndex        =   70
      Top             =   3960
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   7
      Left            =   6000
      TabIndex        =   69
      Top             =   3600
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   6
      Left            =   6000
      TabIndex        =   68
      Top             =   3240
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   5
      Left            =   6000
      TabIndex        =   67
      Top             =   2880
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   255
      Index           =   4
      Left            =   6000
      TabIndex        =   66
      Top             =   2520
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   300
      Index           =   3
      Left            =   6000
      TabIndex        =   65
      Top             =   2280
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   300
      Index           =   2
      Left            =   6000
      TabIndex        =   64
      Top             =   2880
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   300
      Index           =   1
      Left            =   6000
      TabIndex        =   63
      Top             =   2880
      Width           =   300
   End
   Begin VB.Label lblUnits 
      Height          =   300
      Index           =   0
      Left            =   6000
      TabIndex        =   62
      Top             =   2880
      Width           =   300
   End
   Begin VB.Label lblSummary 
      BeginProperty Font 
         Name            =   "MS Sans Serif"
         Size            =   9.75
         Charset         =   0
         Weight          =   700
         Underline       =   0   'False
         Italic          =   0   'False
         Strikethrough   =   0   'False
      EndProperty
      Height          =   375
      Left            =   360
      TabIndex        =   61
      Top             =   10800
      Width           =   9495
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   19
      Left            =   240
      TabIndex        =   60
      Top             =   8280
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   18
      Left            =   240
      TabIndex        =   59
      Top             =   7920
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   17
      Left            =   240
      TabIndex        =   58
      Top             =   7440
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   16
      Left            =   240
      TabIndex        =   57
      Top             =   7200
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   15
      Left            =   240
      TabIndex        =   56
      Top             =   6840
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   14
      Left            =   240
      TabIndex        =   55
      Top             =   6360
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   13
      Left            =   240
      TabIndex        =   54
      Top             =   6120
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   9
      Left            =   240
      TabIndex        =   53
      Top             =   4680
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   8
      Left            =   240
      TabIndex        =   52
      Top             =   4320
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   7
      Left            =   240
      TabIndex        =   51
      Top             =   3960
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   255
      Index           =   6
      Left            =   240
      TabIndex        =   50
      Top             =   3600
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   300
      Index           =   5
      Left            =   240
      TabIndex        =   49
      Top             =   3200
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   300
      Index           =   4
      Left            =   240
      TabIndex        =   48
      Top             =   2805
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   300
      Index           =   3
      Left            =   240
      TabIndex        =   47
      Top             =   2400
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   300
      Index           =   2
      Left            =   240
      TabIndex        =   46
      Top             =   3360
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   300
      Index           =   1
      Left            =   240
      TabIndex        =   45
      Top             =   3120
      Width           =   3000
   End
   Begin VB.Label lblDescription 
      Height          =   300
      Index           =   0
      Left            =   240
      TabIndex        =   0
      Top             =   2880
      Width           =   3000
   End
End
Attribute VB_Name = "frmPNIssue"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Dim blnLoaded As Boolean
Private Sub cmdCancel_Click()
   Me.Tag = "N"
   Me.Hide
End Sub

Private Sub cmdLog_Click()
   frmLogView.txtDateFrom.Text = Format$(DateAdd("yyyy", -1, Now), "dd mmm yyyy")
   frmLogView.txtTransBatchNumber = Me.lblBatch.Caption
   frmLogView.txtLabeltype = "T"
   frmLogView.Show 1
   Unload frmLogView
   Set frmLogView = Nothing
End Sub

Private Sub cmdOK_Click()
   Me.Tag = "Y"
   Me.Hide
End Sub

Private Sub cmdWarnings_Click()
   popmessagecr "!Warnings", Me.lblAllWarnings.Caption
End Sub

Private Sub Form_Activate()
'22Mar12 TH Slightly raised the height of main product labels (TFS 29555)
Const intLeftMove = 700
Const inttopMove = 1500

If Not blnLoaded Then '18Mar12 TH Added (TFS28928)

   If Not Me.Tag = "WASTE" Then
      Me.lblWaste.Visible = False
      Me.lblhdrStock.Left = (Me.lblhdrStock.Left) - intLeftMove
      Me.lblhdrUnit.Left = (Me.lblhdrUnit.Left) - intLeftMove
      Me.lblProd.Left = (Me.lblProd.Left) - intLeftMove
   End If
   
   For intloop = 0 To 19
   
      If Me.lblDescription.Item(intloop).Caption = "" Then Exit For
      'Me.lblDescription.Item(intLoop).Top = 1200 + (400 * intLoop)
      Me.lblDescription.Item(intloop).Top = 1470 + (400 * intloop) + inttopMove
      Me.lblDescription.Item(intloop).Height = 300
      'Me.txtQty.Item(intLoop).Top = 1100 + (400 * intLoop)
      Me.txtQty.Item(intloop).Top = 1400 + (400 * intloop) + inttopMove
      Me.txtQty.Item(intloop).Height = 300
      'Me.txtWaste.Item(intLoop).Top = 1100 + (400 * intLoop)
      'Me.txtWaste.Item(intloop).Top = 1400 + (400 * intloop) + inttopMove
      'Me.txtWaste.Item(intloop).Height = 300
      'Me.lblUnits.Item(intLoop).Top = 1200 + (400 * intLoop)
      Me.lblUnits.Item(intloop).Top = 1470 + (400 * intloop) + inttopMove
      Me.lblUnits.Item(intloop).Height = 300
      'Me.lblInfo.Item(intLoop).Top = 1200 + (400 * intLoop)
      Me.lblInfo.Item(intloop).Top = 1470 + (400 * intloop) + inttopMove
      Me.lblInfo.Item(intloop).Height = 300
      Me.lblStock.Item(intloop).Top = 1470 + (400 * intloop) + inttopMove
      Me.lblStock.Item(intloop).Height = 300
      If Not Me.Tag = "WASTE" Then
         Me.txtWaste.Item(intloop).Visible = False
         Me.lblUnits.Item(intloop).Left = (Me.lblUnits.Item(intloop).Left) - intLeftMove
         Me.lblInfo.Item(intloop).Left = (Me.lblInfo.Item(intloop).Left) - intLeftMove
         Me.lblStock.Item(intloop).Left = (Me.lblStock.Item(intloop).Left) - intLeftMove
      Else
         Me.txtWaste.Item(intloop).Top = 1400 + (400 * intloop) + inttopMove
         Me.txtWaste.Item(intloop).Height = 300
      End If
   Next
   CentreForm Me
End If

blnLoaded = True '18Mar12 TH Added (TFS28928)

End Sub

Private Sub Form_Load()
Dim intloop As Integer


'MsgBox Format$(intLoop)
'For intloop = 0 To 20
CentreForm Me
SetChrome Me
End Sub

Private Sub Form_Unload(Cancel As Integer)
blnLoaded = False '18Mar12 TH Added (TFS28928)
End Sub

Private Sub txtQty_GotFocus(Index As Integer)
'18Mar12 TH TFS 28931
   txtQty(Index).SelStart = 0
   txtQty(Index).Text = Trim$(txtQty(Index).Text)
   txtQty(Index).SelLength = Len(txtQty(Index).Text)
 
End Sub

Private Sub txtQty_KeyPress(Index As Integer, KeyAscii As Integer)
   If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58) Or KeyAscii = 46) Then KeyAscii = 0
   
   If KeyAscii = 46 And (InStr(txtQty(Index).Text, ".") > 0) Then KeyAscii = 0
   
End Sub

Private Sub txtWaste_GotFocus(Index As Integer)
'18Mar12 TH TFS 28931
   txtWaste(Index).SelStart = 0
   txtWaste(Index).Text = Trim$(txtWaste(Index).Text)
   txtWaste(Index).SelLength = Len(txtWaste(Index).Text)
   
End Sub

Private Sub txtWaste_KeyPress(Index As Integer, KeyAscii As Integer)
If Not ((KeyAscii = 46 Or KeyAscii = 8) Or (KeyAscii > 47 And KeyAscii < 58) Or KeyAscii = 46) Then KeyAscii = 0
   
   If KeyAscii = 46 And (InStr(txtWaste(Index).Text, ".") > 0) Then KeyAscii = 0
   
End Sub
