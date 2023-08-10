VERSION 2.00
Begin Form FrmEnterDur 
   BackColor       =   &H8000000A&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Reprint File Duration"
   ClientHeight    =   5190
   ClientLeft      =   5535
   ClientTop       =   2460
   ClientWidth     =   4350
   Height          =   5595
   Icon            =   ENTERDUR.FRX:0000
   Left            =   5475
   LinkTopic       =   "Form1"
   ScaleHeight     =   5190
   ScaleWidth      =   4350
   Top             =   2115
   Width           =   4470
   Begin Frame FraDisp 
      BackColor       =   &H8000000A&
      Caption         =   "Dispensary Reprints"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   1500
      Left            =   225
      TabIndex        =   14
      Top             =   2880
      Width           =   3930
      Begin TextBox TxtLabels 
         Height          =   285
         Left            =   2565
         TabIndex        =   19
         Top             =   945
         Width           =   675
      End
      Begin TextBox TxtWorksht 
         Height          =   285
         Left            =   2565
         TabIndex        =   16
         Top             =   450
         Width           =   675
      End
      Begin Label Label10 
         BackColor       =   &H8000000A&
         Caption         =   "Keep Label reprints for "
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   285
         Left            =   135
         TabIndex        =   18
         Top             =   945
         Width           =   1905
      End
      Begin Label Label9 
         BackColor       =   &H8000000A&
         Caption         =   "Keep Worksheet reprints for"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   285
         Left            =   135
         TabIndex        =   15
         Top             =   450
         Width           =   2220
      End
      Begin Label Label8 
         BackColor       =   &H8000000A&
         Caption         =   "days."
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Left            =   3285
         TabIndex        =   20
         Top             =   945
         Width           =   465
      End
      Begin Label Label7 
         BackColor       =   &H8000000A&
         Caption         =   "days."
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Left            =   3285
         TabIndex        =   17
         Top             =   450
         Width           =   510
      End
   End
   Begin Frame FraStores 
      BackColor       =   &H8000000A&
      Caption         =   "Stores Reprints"
      FontBold        =   0   'False
      FontItalic      =   0   'False
      FontName        =   "MS Sans Serif"
      FontSize        =   8.25
      FontStrikethru  =   0   'False
      FontUnderline   =   0   'False
      Height          =   2490
      Left            =   225
      TabIndex        =   1
      Top             =   180
      Width           =   3930
      Begin TextBox TxtReturnNote 
         Height          =   285
         Left            =   2565
         TabIndex        =   12
         Top             =   1935
         Width           =   675
      End
      Begin TextBox TxtRequisition 
         Height          =   285
         Left            =   2565
         TabIndex        =   9
         Top             =   1440
         Width           =   675
      End
      Begin TextBox TxtOrderNote 
         Height          =   285
         Left            =   2565
         TabIndex        =   6
         Top             =   945
         Width           =   675
      End
      Begin TextBox TxtDelNote 
         Height          =   285
         Left            =   2565
         TabIndex        =   3
         Top             =   450
         Width           =   675
      End
      Begin Label Label12 
         BackColor       =   &H8000000A&
         Caption         =   "days."
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Left            =   3285
         TabIndex        =   13
         Top             =   1980
         Width           =   465
      End
      Begin Label Label11 
         BackColor       =   &H8000000A&
         Caption         =   "Keep Return Note reprints for"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   285
         Left            =   135
         TabIndex        =   11
         Top             =   1980
         Width           =   2355
      End
      Begin Label Label6 
         BackColor       =   &H8000000A&
         Caption         =   "days."
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Left            =   3285
         TabIndex        =   10
         Top             =   1485
         Width           =   465
      End
      Begin Label Label5 
         BackColor       =   &H8000000A&
         Caption         =   "days."
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   285
         Left            =   3285
         TabIndex        =   7
         Top             =   990
         Width           =   465
      End
      Begin Label Label4 
         BackColor       =   &H8000000A&
         Caption         =   "Keep Requisition Note reprints for "
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   420
         Left            =   135
         TabIndex        =   8
         Top             =   1485
         Width           =   2625
      End
      Begin Label Label3 
         BackColor       =   &H8000000A&
         Caption         =   "Keep Order Note reprints for"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   375
         Left            =   135
         TabIndex        =   5
         Top             =   990
         Width           =   2130
      End
      Begin Label Label2 
         BackColor       =   &H8000000A&
         Caption         =   "days."
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   240
         Left            =   3285
         TabIndex        =   4
         Top             =   495
         Width           =   465
      End
      Begin Label Label1 
         BackColor       =   &H8000000A&
         Caption         =   "Keep Delivery Note reprints for"
         FontBold        =   0   'False
         FontItalic      =   0   'False
         FontName        =   "MS Sans Serif"
         FontSize        =   8.25
         FontStrikethru  =   0   'False
         FontUnderline   =   0   'False
         Height          =   375
         Left            =   135
         TabIndex        =   2
         Top             =   495
         Width           =   2310
      End
   End
   Begin CommandButton CancelButton 
      Caption         =   "Cancel"
      Height          =   375
      Left            =   315
      TabIndex        =   0
      Top             =   4545
      Width           =   1140
   End
   Begin CommandButton OKButton 
      Caption         =   "OK"
      Height          =   375
      Left            =   2925
      TabIndex        =   21
      Top             =   4545
      Width           =   1140
   End
   Begin MhTimer MhTimer1 
      Height          =   420
      Interval        =   0
      Left            =   2115
      Top             =   3870
      Width           =   420
   End
End
Option Explicit '01Jun02 ALL/ATW
DefInt A-Z '01Jun02 ALL/ATW
'17May99 AE  Written

'Allows the user to enter the number of days which each type of reprint file (labels,
'worksheets,order notes, requisitions, delivery notes and return notes) are allowed to
'stay on disk when a TidyUpReprints is called. Values are written to the default ini file
'(wdelord.ini) in the section [FileDurations]



Dim Changed%

Sub CancelButton_Click ()

   Me.Hide
   
End Sub

Function EntriesValid% ()


Dim Min%, Max%, valid%

   Min% = 0
   Max% = (10 ^ TxtDelNote.MaxLength) - 1   'only to catch entries like 10e5
   valid% = True

   If Val(TxtDelNote.Text) < Min Or Val(TxtDelNote.Text) > Max Then valid = False
   If valid Then If Val(TxtOrderNote.Text) < Min Or Val(TxtOrderNote.Text) > Max Then valid = False
   If valid Then If Val(TxtReturnNote.Text) < Min Or Val(TxtReturnNote.Text) > Max Then valid = False
   If valid Then If Val(TxtRequisition.Text) < Min Or Val(TxtRequisition.Text) > Max Then valid = False
   If valid Then If Val(TxtOrderNote.Text) < Min Or Val(TxtOrderNote.Text) > Max Then valid = False
   If valid Then If Val(TxtWorksht.Text) < Min Or Val(TxtWorksht.Text) > Max Then valid = False
   If valid Then If Val(TxtLabels.Text) < Min Or Val(TxtLabels.Text) > Max Then valid = False

   EntriesValid = valid%

End Function

Sub Form_Activate ()
             
   Changed% = False
   TimeoutOn MhTimer1
   CancelButton.SetFocus

End Sub

Sub Form_Load ()

   CentreForm Me

End Sub

Sub MhTimer1_Timer ()

   If TimedOut() Then
         Me.Hide
      End If

End Sub

Sub OKButton_Click ()

Dim msg$, t$, Ans$, valid%, t1$, msg1$ '01Jun02 ALL/ATW
   
   Me.Tag = "0"                         'same as pressing 'cancel' by default

   t$ = "? Confirm Changes?"
   msg$ = "About to change File Duration" & cr$
   msg$ = msg$ & "settings. This will change the length of" & cr$
   msg$ = msg$ & "time that files are stored on disk." & cr$
   msg$ = msg$ & "Store New Settings ?"
   t1$ = "#"
   msg1$ = "Entries for file durations must be" & cr$
   msg1$ = msg1$ & "must be positive whole numbers"

   If Changed% Then
      If EntriesValid() Then
         AskWin t$, msg$, Ans$, k  'k?  'entries are ok, ask to confirm changes
         If Ans$ = "Y" Then
          Me.Tag = "1"                  'To indicate Ok to the calling form
         End If
         Me.Hide
      Else                              'entries invalid.
         popmessagecr t1$, msg1$
      End If

   Else                                 'no changes have been made
      Me.Hide
   End If


End Sub

Sub TxtDelNote_Change ()

   Changed% = True
   
End Sub

Sub TxtDelNote_LostFocus ()

    TxtDelNote.Text = Int(Val(TxtDelNote.Text))

End Sub

Sub TxtLabels_Change ()

   Changed% = True

End Sub

Sub TxtLabels_LostFocus ()

   TxtLabels.Text = Int(Val(TxtLabels.Text))

End Sub

Sub TxtOrderNote_Change ()

   Changed% = True

End Sub

Sub TxtOrderNote_LostFocus ()

   TxtOrderNote.Text = Int(Val(TxtOrderNote.Text))

End Sub

Sub TxtRequisition_Change ()

   Changed% = True


End Sub

Sub TxtRequisition_LostFocus ()

   TxtRequisition.Text = Int(Val(TxtRequisition.Text))

End Sub

Sub TxtReturnNote_Change ()

   Changed% = True


End Sub

Sub TxtReturnNote_LostFocus ()

   TxtReturnNote.Text = Int(Val(TxtReturnNote.Text))

End Sub

Sub TxtWorksht_Change ()

   Changed% = True


End Sub

Sub TxtWorksht_LostFocus ()

   TxtWorksht.Text = Int(Val(TxtWorksht.Text))

End Sub

