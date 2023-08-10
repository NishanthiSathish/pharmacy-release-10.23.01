VERSION 5.00
Object = "*\AStoresCtl_wrk.vbp"
Begin VB.Form storesTest 
   Caption         =   "Form1"
   ClientHeight    =   4260
   ClientLeft      =   60
   ClientTop       =   345
   ClientWidth     =   4680
   LinkTopic       =   "Form1"
   ScaleHeight     =   4260
   ScaleWidth      =   4680
   StartUpPosition =   3  'Windows Default
   Begin StoresCtl.ucStores ucStores1 
      Height          =   855
      Left            =   960
      TabIndex        =   1
      Top             =   480
      Width           =   1095
      _extentx        =   1931
      _extenty        =   1508
   End
   Begin VB.CommandButton Command1 
      Caption         =   "Command1"
      Height          =   615
      Left            =   1200
      TabIndex        =   0
      Top             =   2880
      Width           =   2415
   End
End
Attribute VB_Name = "storesTest"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Private Sub Command1_Click()
Dim SessionID As Long
Dim Sitenumber As Long
Dim WardstockID As Long
Dim strMode As String
Dim strCostCentre As String

   SessionID = 1577
   Sitenumber = 1
   WardstockID = 36
   strMode = "R"
   strCostCentre = "AW1"
   ucStores1.WardStockAction SessionID, Sitenumber, WardstockID, strCostCentre, strMode
   
   
End Sub


