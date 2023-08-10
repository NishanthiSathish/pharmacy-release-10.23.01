VERSION 5.00
Object = "{8B2104A3-F5AC-11CE-A0DD-00AA0062530E}#1.0#0"; "MHTIME32.OCX"
Object = "{54DEA423-F812-11CE-8F33-00AA00B46FE8}#1.0#0"; "MHMLBL32.OCX"
Object = "{B11ECDA8-C130-11CE-9BE9-00AA00575482}#1.0#0"; "MHLIST32.OCX"
Begin VB.Form frmEventNotifierV1 
   Caption         =   "Form1"
   ClientHeight    =   5415
   ClientLeft      =   165
   ClientTop       =   735
   ClientWidth     =   8520
   Icon            =   "frmEventNotifierV1.frx":0000
   LinkTopic       =   "Form1"
   ScaleHeight     =   5415
   ScaleWidth      =   8520
   StartUpPosition =   3  'Windows Default
   Begin MhgmulLib.Mh3dMulLabel lblStatus 
      Align           =   2  'Align Bottom
      Height          =   735
      Left            =   0
      TabIndex        =   11
      Top             =   4680
      Width           =   8520
      _Version        =   65536
      _ExtentX        =   15028
      _ExtentY        =   1296
      _StockProps     =   205
      ForeColor       =   -2147483640
      AutoSize        =   -1  'True
      BevelSize       =   0
      FontTransparent =   0   'False
      Scalemode       =   1
      SegmentStyle    =   1
      Segments        =   3
      Picture         =   "frmEventNotifierV1.frx":0442
      DataFieldCount  =   0
      SegBevelStyle0  =   0
      SegBevelSize0   =   2
      SegFontStyle0   =   0
      SegPicLeft0     =   0
      SegPicTop0      =   0
      SegPicWidth0    =   0
      SegPicHeight0   =   0
      SegWallpaper0   =   0
      SegBorderStyle0 =   0
      SegMax0         =   3
      SegMin0         =   0
      SegValue0       =   0
      SegFillStyle0   =   0
      SegAlignment0   =   0
      SegRectTop0     =   4
      SegRectLeft0    =   4
      SegRectBottom0  =   45
      SegRectRight0   =   111
      SegLightColor0  =   -2147483643
      SegShadowColor0 =   -2147483632
      SegBackColor0   =   -2147483633
      SegFillColor0   =   16711680
      SegTextColor0   =   -2147483640
      SegTwipLeft0    =   0
      SegTwipTop0     =   0
      SegTwipWidth0   =   0
      SegTwipHeight0  =   0
      SegAutosize0    =   -1  'True
      SegMultiline0   =   0   'False
      SegFontStrike0  =   0   'False
      SegFontTransparent0=   0   'False
      SegFontUnder0   =   0   'False
      SegFontBold0    =   0   'False
      SegFontItalic0  =   0   'False
      SegFontSize0    =   0
      SegPicture0     =   "frmEventNotifierV1.frx":045E
      SegCaption0     =   ""
      SegFontName0    =   ""
      SegDataField0   =   ""
      SegFormat0      =   ""
      SegBevelStyle1  =   0
      SegBevelSize1   =   2
      SegFontStyle1   =   0
      SegPicLeft1     =   0
      SegPicTop1      =   0
      SegPicWidth1    =   0
      SegPicHeight1   =   0
      SegWallpaper1   =   0
      SegBorderStyle1 =   0
      SegMax1         =   3
      SegMin1         =   0
      SegValue1       =   0
      SegFillStyle1   =   0
      SegAlignment1   =   0
      SegRectTop1     =   4
      SegRectLeft1    =   113
      SegRectBottom1  =   45
      SegRectRight1   =   337
      SegLightColor1  =   -2147483643
      SegShadowColor1 =   -2147483632
      SegBackColor1   =   -2147483633
      SegFillColor1   =   16711680
      SegTextColor1   =   -2147483640
      SegTwipLeft1    =   0
      SegTwipTop1     =   0
      SegTwipWidth1   =   0
      SegTwipHeight1  =   0
      SegAutosize1    =   -1  'True
      SegMultiline1   =   0   'False
      SegFontStrike1  =   0   'False
      SegFontTransparent1=   0   'False
      SegFontUnder1   =   0   'False
      SegFontBold1    =   0   'False
      SegFontItalic1  =   0   'False
      SegFontSize1    =   0
      SegPicture1     =   "frmEventNotifierV1.frx":047A
      SegCaption1     =   ""
      SegFontName1    =   ""
      SegDataField1   =   ""
      SegFormat1      =   ""
      SegBevelStyle2  =   0
      SegBevelSize2   =   2
      SegFontStyle2   =   0
      SegPicLeft2     =   0
      SegPicTop2      =   0
      SegPicWidth2    =   0
      SegPicHeight2   =   0
      SegWallpaper2   =   0
      SegBorderStyle2 =   0
      SegMax2         =   3
      SegMin2         =   0
      SegValue2       =   0
      SegFillStyle2   =   0
      SegAlignment2   =   0
      SegRectTop2     =   4
      SegRectLeft2    =   339
      SegRectBottom2  =   45
      SegRectRight2   =   563
      SegLightColor2  =   -2147483643
      SegShadowColor2 =   -2147483632
      SegBackColor2   =   -2147483633
      SegFillColor2   =   16711680
      SegTextColor2   =   -2147483640
      SegTwipLeft2    =   0
      SegTwipTop2     =   0
      SegTwipWidth2   =   0
      SegTwipHeight2  =   0
      SegAutosize2    =   -1  'True
      SegMultiline2   =   0   'False
      SegFontStrike2  =   0   'False
      SegFontTransparent2=   0   'False
      SegFontUnder2   =   0   'False
      SegFontBold2    =   0   'False
      SegFontItalic2  =   0   'False
      SegFontSize2    =   0
      SegPicture2     =   "frmEventNotifierV1.frx":0496
      SegCaption2     =   ""
      SegFontName2    =   ""
      SegDataField2   =   ""
      SegFormat2      =   ""
   End
   Begin MhtimerLib.MhTimer timInterval 
      Height          =   420
      Left            =   2700
      TabIndex        =   4
      Top             =   450
      Width           =   420
      _Version        =   65536
      _ExtentX        =   741
      _ExtentY        =   741
      _StockProps     =   64
      Enabled         =   0   'False
      Interval        =   1000
   End
   Begin VB.Frame fraStatus 
      Height          =   600
      Left            =   90
      TabIndex        =   6
      Top             =   4230
      Width           =   8655
      Begin VB.Label Label1 
         AutoSize        =   -1  'True
         Caption         =   "Last Message Received : "
         Height          =   195
         Index           =   0
         Left            =   405
         TabIndex        =   7
         Top             =   225
         Width           =   1860
      End
      Begin VB.Label Label1 
         AutoSize        =   -1  'True
         Caption         =   "Last Error Occurred : "
         Height          =   195
         Index           =   1
         Left            =   4545
         TabIndex        =   9
         Top             =   225
         Width           =   1515
      End
      Begin VB.Label lblLastMsg 
         Height          =   195
         Left            =   2340
         TabIndex        =   8
         Top             =   225
         Width           =   1995
      End
      Begin VB.Label lblLastError 
         Height          =   195
         Left            =   6120
         TabIndex        =   10
         Top             =   225
         Width           =   1995
      End
   End
   Begin VB.PictureBox picGreen 
      Height          =   600
      Left            =   1755
      Picture         =   "frmEventNotifierV1.frx":04B2
      ScaleHeight     =   540
      ScaleWidth      =   495
      TabIndex        =   3
      Top             =   315
      Visible         =   0   'False
      Width           =   555
   End
   Begin VB.PictureBox picAmber 
      Height          =   600
      Left            =   1080
      Picture         =   "frmEventNotifierV1.frx":08F4
      ScaleHeight     =   540
      ScaleWidth      =   495
      TabIndex        =   2
      Top             =   315
      Visible         =   0   'False
      Width           =   555
   End
   Begin VB.PictureBox picRed 
      Height          =   600
      Left            =   360
      Picture         =   "frmEventNotifierV1.frx":0D36
      ScaleHeight     =   540
      ScaleWidth      =   495
      TabIndex        =   1
      Top             =   315
      Visible         =   0   'False
      Width           =   555
   End
   Begin MhglbxLib.Mh3dList LstStatus 
      Height          =   1485
      Left            =   0
      TabIndex        =   5
      Top             =   3225
      Width           =   7395
      _Version        =   65536
      _ExtentX        =   13039
      _ExtentY        =   2625
      _StockProps     =   95
      Caption         =   "Mh3dList1"
      Text            =   "Mh3dList1"
      BackColor       =   13160660
      Caption         =   "Mh3dList1"
      ColTitleButtons =   0   'False
      BevelStyleInner =   0
      BevelSizeInner  =   0
      BorderType      =   1
      BorderColor     =   0
      Case            =   0
      Col             =   1
      ColCharacter    =   9
      ColScale        =   0
      ColSizing       =   0
      DividerStyle    =   1
      FontStyle       =   0
      LightColor      =   16777215
      MultiSelect     =   0
      PictureHeight   =   0
      PictureWidth    =   0
      AdjustHeight    =   0
      ScrollBars      =   1
      ShadowColor     =   8421504
      WallPaper       =   0
      Sorted          =   0   'False
      TextColor       =   0
      WrapList        =   0   'False
      WrapWidth       =   0
      ColInstr        =   -1
      TitleHeight     =   0
      TitleFontBold   =   0   'False
      TitleFontItalic =   0   'False
      TitleFontName   =   "MS Sans Serif"
      TitleFontSize   =   8.25
      TitleFontStrike =   0   'False
      TitleFontUnder  =   0   'False
      TitleFontStyle  =   0
      TitleBevelStyle =   0
      TitleBevelSize  =   0
      TitleColor      =   0
      FocusColor      =   0
      HighColor       =   16777215
      VirtualList     =   0   'False
      BufferSize      =   100
      SortOrder       =   ""
      SelectedColor   =   8388608
      Transparent     =   0   'False
      TransparentColor=   0
      TitleFillColor  =   12632256
      Platform        =   0
      FireDrawItem    =   0   'False
      DrawItemLeft    =   0
      DrawItemRight   =   0
      DataSourceList  =   ""
      ListDividersH   =   -1  'True
      ListDividersV   =   -1  'True
      TitleDividers   =   -1  'True
      DataField       =   ""
      DataFieldCount  =   0
      FooterColor     =   0
      FooterFillColor =   0
      ColTitle0       =   "DateTime"
      ColTitle1       =   "Status Message"
      CheckPicture    =   "frmEventNotifierV1.frx":1178
      CheckPictureSel =   "frmEventNotifierV1.frx":1194
      SortCaseSesitive=   0
   End
   Begin MhglbxLib.Mh3dList LstMessages 
      Height          =   3225
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Visible         =   0   'False
      Width           =   7395
      _Version        =   65536
      _ExtentX        =   13044
      _ExtentY        =   5689
      _StockProps     =   95
      Caption         =   "Mh3dList1"
      Text            =   "Mh3dList1"
      BackColor       =   16777215
      Caption         =   "Mh3dList1"
      ColTitleButtons =   0   'False
      BevelStyleInner =   0
      BevelSizeInner  =   0
      BorderType      =   1
      BorderColor     =   0
      Case            =   0
      Col             =   0
      ColCharacter    =   9
      ColScale        =   0
      ColSizing       =   1
      DividerStyle    =   1
      FillColor       =   -2147483643
      FontStyle       =   0
      LightColor      =   16777215
      MultiSelect     =   0
      PictureHeight   =   16
      PictureWidth    =   16
      AdjustHeight    =   0
      ScrollBars      =   3
      ShadowColor     =   8421504
      WallPaper       =   0
      Sorted          =   0   'False
      TextColor       =   0
      WrapList        =   0   'False
      WrapWidth       =   0
      ColInstr        =   -1
      TitleHeight     =   0
      TitleFontBold   =   0   'False
      TitleFontItalic =   0   'False
      TitleFontName   =   "MS Sans Serif"
      TitleFontSize   =   8.25
      TitleFontStrike =   0   'False
      TitleFontUnder  =   0   'False
      TitleFontStyle  =   0
      TitleBevelStyle =   0
      TitleBevelSize  =   0
      TitleColor      =   0
      FocusColor      =   0
      HighColor       =   16777215
      VirtualList     =   0   'False
      BufferSize      =   100
      SortOrder       =   ""
      SelectedColor   =   8388608
      Transparent     =   -1  'True
      TransparentColor=   12632256
      TitleFillColor  =   12632256
      Platform        =   0
      FireDrawItem    =   0   'False
      DrawItemLeft    =   0
      DrawItemRight   =   0
      DataSourceList  =   ""
      ListDividersH   =   -1  'True
      ListDividersV   =   -1  'True
      TitleDividers   =   -1  'True
      DataField       =   ""
      DataFieldCount  =   0
      FooterColor     =   0
      FooterFillColor =   0
      ColTitle0       =   "Time"
      ColWidth0       =   10
      ColTitle1       =   "Message"
      ColWidth1       =   1000
      CheckPicture    =   "frmEventNotifierV1.frx":11B0
      CheckPictureSel =   "frmEventNotifierV1.frx":11CC
      SortCaseSesitive=   0
   End
   Begin VB.Menu mnuProcessorTop 
      Caption         =   "&Processor"
      Begin VB.Menu mnuProcessor 
         Caption         =   "&Manual Run"
         Index           =   0
      End
      Begin VB.Menu mnuProcessor 
         Caption         =   "-"
         Index           =   1
      End
      Begin VB.Menu mnuProcessor 
         Caption         =   "&Close Window"
         Index           =   2
         Shortcut        =   ^{F4}
      End
   End
   Begin VB.Menu mnuModeTop 
      Caption         =   "&Mode"
      Begin VB.Menu mnuMode 
         Caption         =   "&Automatic"
      End
   End
   Begin VB.Menu mnuOptionsTop 
      Caption         =   "&Options"
      Begin VB.Menu mnuOptions 
         Caption         =   "&Show Messages"
         Index           =   0
      End
      Begin VB.Menu mnuOptions 
         Caption         =   "-"
         Index           =   1
         Visible         =   0   'False
      End
      Begin VB.Menu mnuOptions 
         Caption         =   "&Clear Messages"
         Index           =   2
         Visible         =   0   'False
      End
   End
   Begin VB.Menu mnuSetupTop 
      Caption         =   "&Setup"
      Begin VB.Menu mnuSetup 
         Caption         =   "&Configuration"
      End
   End
   Begin VB.Menu mPopup 
      Caption         =   "Popup"
      Visible         =   0   'False
      Begin VB.Menu mnuPopupShow 
         Caption         =   "&Show"
      End
      Begin VB.Menu mPopupSep1 
         Caption         =   "-"
      End
      Begin VB.Menu mnuPopupProcessing 
         Caption         =   "&Resume"
      End
      Begin VB.Menu mPopupSep2 
         Caption         =   "-"
      End
      Begin VB.Menu mPopupShutdown 
         Caption         =   "Sh&utdown"
      End
   End
End
Attribute VB_Name = "frmEventNotifierV1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit
DefInt A-Z

Private Const CLASS_NAME = "frmEventNotifierV1."


Private mobjConfig As EventNotifierV1.Config
Private mlngTimerCount As Long

Private Const trnDataTypeInt = 2
Public Sub AddToMessageList(sMsg As String)

   LstMessages.AddItem Format(Now, "dd-mmm-yyyy HH:mm:ss") & vbTab & sMsg, 0
   
   If LstMessages.ListCount > 50 Then LstMessages.RemoveItem (LstMessages.ListCount - 1)

End Sub

Public Sub AddToStatusList(sMsg As String)

   LstStatus.AddItem Format(Now, "dd-mmm-yyyy HH:mm:ss") & vbTab & sMsg, 0
   
   If LstStatus.ListCount > 50 Then LstStatus.RemoveItem (LstStatus.ListCount - 1)

End Sub

Private Function DecodeMode() As String

   DecodeMode = IIf((mobjConfig.MsgProcessing = Automatic), "Automatic", "Manual")
   
End Function

Private Function DecodeState() As String

   Select Case mobjConfig.ProcessorState
      Case Stopped
         DecodeState = "Stopped"
      Case Waiting
         DecodeState = "Waiting..."
      Case Running
         DecodeState = "Processing..."
   End Select
   
End Function

Private Sub DisableMessageProcessing()

Const SUB_NAME = "DisableMessageProcessing"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
   
   timInterval.Enabled = False
   mlngTimerCount = 0
   
   mobjConfig.ProcessorState = Stopped
   mobjConfig.MsgProcessing = Manual
   
   mnuMode.Caption = "&Automatic"
   mnuPopupProcessing.Caption = "&Resume"
   mnuProcessor(0).Enabled = True
   mnuSetupTop.Visible = True
   
   Me.Icon = Me.picRed
   ModifySysTrayIcon Me
   
Cleanup:

   On Error Resume Next
   UpdateStatusBar
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup

End Sub

Private Sub EnableMessageProcessing()

Const SUB_NAME = "EnableMessageProcessing"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
   
   mobjConfig.MsgProcessing = Automatic
   mnuMode.Caption = "&Manual"
   mnuPopupProcessing.Caption = "&Pause"
   mnuProcessor(0).Enabled = False
   mnuSetupTop.Visible = False
   
   Me.Icon = Me.picAmber
   ModifySysTrayIcon Me
   
   If mobjConfig.MsgProcessing = Automatic Then
         mobjConfig.ProcessorState = Waiting
         timInterval.Enabled = True
      End If
      
Cleanup:

   On Error Resume Next
   UpdateStatusBar
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Function LogToFile(ByVal strToLog As String)
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  10Mar05 EAC  Written
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "LogToFile"

Dim udtError As udtErrorState

Dim objFSO As Scripting.FileSystemObject
Dim objTxt As Scripting.TextStream

   On Error GoTo ErrorHandler

   Set objFSO = New Scripting.FileSystemObject
   Set objTxt = objFSO.OpenTextFile(App.Path & "\LogFile.txt", ForAppending, True)
   
   objTxt.WriteLine Format$(Now, "DD-MMM-YYYY HH:MM:SS") & " - " & strToLog

Cleanup:

   On Error Resume Next
   objTxt.Close
   Set objTxt = Nothing
   Set objFSO = Nothing
   
   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Private Function SaveMessages(ByVal strTranslatedXML As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     lngSessionID        :  Standard sessionid
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  02Sep05 EAC  Written
'
'----------------------------------------------------------------------------------

Const END_TAG = "</File>"
Const START_TAG = "<File>"
Const SUB_NAME = "SaveMessages"

Dim udtError As udtErrorState

Dim lngStart As Long
Dim lngEnd As Long

Dim strMessage As String

   On Error GoTo ErrorHandler

   strTranslatedXML = Replace(strTranslatedXML, "<Files>", vbNullString)
   strTranslatedXML = Replace(strTranslatedXML, "</Files>", vbNullString)
   
   If Len(strTranslatedXML) > 0 Then
      lngStart = 1
      
      Do
         lngEnd = InStr(lngStart, strTranslatedXML, END_TAG)
               
         If lngEnd > 0 Then
            strMessage = Mid$(strTranslatedXML, lngStart, lngEnd - lngStart)
            strMessage = Replace(strMessage, START_TAG, vbNullString)
            
            If Len(strMessage) > 0 Then
               SaveMessageToFile mobjConfig.InstanceName, _
                                 mobjConfig.OutputDirectory, _
                                 mobjConfig.OutputFileExtension, _
                                 strMessage
            End If
            lngStart = lngEnd + Len(END_TAG)
         End If
         
      Loop While lngEnd <> 0
      
   End If

Cleanup:

   On Error GoTo 0
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
End Function

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)

Dim lMsg As Long

   If Me.ScaleMode = vbPixels Then
         lMsg = X
      Else
         lMsg = X / Screen.TwipsPerPixelX
      End If

   Select Case lMsg
      Case WM_RBUTTONUP
         'popup a menu
         PopupMenu mPopup
      Case Else
   End Select

End Sub

Private Sub Form_QueryUnload(Cancel As Integer, UnloadMode As Integer)

   If UnloadMode = vbFormControlMenu Then
      Me.Visible = False
      mnuPopupShow.Caption = "&Show"
      Cancel = True
   End If
   
   If (UnloadMode = vbAppWindows) Or (UnloadMode = vbAppTaskManager) Then

      gboolShutdown = True
      Cancel = True
      
   End If
   
End Sub

Private Sub Form_Resize()
Dim iLoop As Integer
Dim lSegWidth As Long
Dim lSegStart As Long

   If Me.WindowState = vbMinimized Then Exit Sub
   
   lblStatus.Enabled = False
   LstMessages.Enabled = False
   LstStatus.Enabled = False
   
   
   With Me.lblStatus
      .Top = Me.ScaleHeight - .Height
      
      lSegWidth = Me.ScaleWidth / .Segments
      For iLoop = 0 To .Segments - 1
         .Segment = iLoop
         .SegLeft = lSegStart
         lSegStart = lSegStart + lSegWidth
         .SegWidth = lSegWidth
      Next
   End With
   
   With LstMessages
      .Left = 0
      .Height = ((Me.ScaleHeight - (lblStatus.Height + fraStatus.Height)) / 10) * 7
      .Width = Me.ScaleWidth
      .Top = Me.ScaleTop
      
      .Col = 0
      .ColScale = mhColSmTwips
      .ColWidth = (.Width / 100) * 20
      .ColMultiline = True
      
      .Col = 1
      .ColScale = mhColSmTwips
      .ColWidth = (.Width / 100) * 80
      .ColMultiline = True
   End With
   
   With LstStatus
      .Top = LstMessages.Top + LstMessages.Height
      .Width = Me.ScaleWidth
      .Left = 0
      .Height = ((Me.ScaleHeight - (lblStatus.Height + fraStatus.Height)) / 10) * 3
      
      .Col = 0
      .ColScale = mhColSmTwips
      .ColWidth = (.Width / 100) * 20
      .ColMultiline = True

      .Col = 1
      .ColScale = mhColSmTwips
      .ColWidth = (.Width / 100) * 80
      .ColMultiline = True
   End With
   
   With fraStatus
      .Width = Me.ScaleWidth - 50
      .Left = Me.ScaleLeft
      .Top = LstStatus.Top + LstStatus.Height
   End With
   
   lblStatus.Enabled = True
   LstMessages.Enabled = True
   LstStatus.Enabled = True
   
End Sub

Private Sub Form_Unload(Cancel As Integer)

   Set mobjConfig = Nothing
   Unload frmOptions
   Unload frmShowMsg
   
End Sub

Private Function GetNextRegisteredAuditLogEntry(ByRef strAuditLogEntryXML As String) As String
'----------------------------------------------------------------------------------
'
' Purpose: Reads the InterfaceRegistered table for the next AuditLog entry we are
'          interested in, reads that entry from the AuditLog and returns the
'          AuditLog data as XML
'
' Inputs:
'
'
' Outputs:
'           strAuditLogEntryXML  :  the AuditLog entry as XML
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  13Oct04 EAC  Written
'
'----------------------------------------------------------------------------------
Const AUDIT_LOG_READ_SP_NAME = "pAuditLogXML"
Const INTERFACEREGISTER_READ_SP_NAME = "pInterfaceRegisterPopRowXML"
Const INTERFACE_REGISTER_TABLE = "InterfaceRegister"
Const SUB_NAME = "GetNextRegisteredAuditLogEntry"

Dim udtError As udtErrorState

Dim objDOM As MSXML2.DOMDocument
Dim objTransportRead As Object
Dim objTransport As Object

Dim lngAuditLogID As Long
Dim lngInterfaceRegisterID As Long
Dim lngReturn As Long

Dim strExtraInfo As String
Dim strParameterXML As String
Dim strReturn As String

   On Error GoTo ErrorHandler
   
   strReturn = vbNullString

   strExtraInfo = "Creating the transport layer object using '" & mobjConfig.INFAppId & ".TransportProxyRead'"
   Set objTransportRead = CreateObject(mobjConfig.INFAppId & ".TransportProxyRead")
   strReturn = objTransportRead.ExecuteSelectStreamSP(mobjConfig.SessionId, _
                                                      INTERFACEREGISTER_READ_SP_NAME, _
                                                      vbNullString)
   Set objTransportRead = Nothing
                                            
   strExtraInfo = vbNullString
   If NoRulesBroken(strReturn) Then _
         strReturn = LoadXML(ROOT_ELEMENT & strReturn & CLOSE_ROOT_ELEMENT, _
                             objDOM)
                             
   If NoRulesBroken(strReturn) Then
      If objDOM.documentElement.childNodes.length > 0 Then
         lngAuditLogID = CLng(objDOM.documentElement.firstChild.Attributes.getNamedItem("AuditLogID").Text)
         lngInterfaceRegisterID = CLng(objDOM.documentElement.firstChild.Attributes.getNamedItem("InterfaceRegisterID").Text)
         
      
         strExtraInfo = "Creating the transport layer object using '" & mobjConfig.INFAppId & ".TransportProxyRead'"
         Set objTransportRead = CreateObject(mobjConfig.INFAppId & ".TransportProxyRead")
         
         With objTransportRead
            strExtraInfo = "Creating the stored procedure parameter XML"
            strParameterXML = .CreateInputParameterXML("AuditLogID", trnDataTypeInt, 4, lngAuditLogID)
            
            strExtraInfo = "Calling " & mobjConfig.INFAppId & ".ExecuteSelectStreamSP to call " & AUDIT_LOG_READ_SP_NAME
            strReturn = .ExecuteSelectStreamSP(mobjConfig.SessionId, _
                                               AUDIT_LOG_READ_SP_NAME, _
                                               strParameterXML)
         
         End With
         Set objTransportRead = Nothing
         
         strExtraInfo = "Creating the transport layer object using '" & mobjConfig.INFAppId & ".TransportProxy'"
         Set objTransport = CreateObject(mobjConfig.INFAppId & ".TransportProxy")
         
         strExtraInfo = "Calling " & mobjConfig.INFAppId & ".TransportProxy.ExecuteDeleteSp"
         lngReturn = objTransport.ExecuteDeleteSP(mobjConfig.SessionId, _
                                                  INTERFACE_REGISTER_TABLE, _
                                                  lngInterfaceRegisterID)
         Set objTransport = Nothing
      End If
   End If
   
   strExtraInfo = vbNullString
   If NoRulesBroken(strReturn) Then
      strAuditLogEntryXML = strReturn
      strReturn = vbNullString
   End If
   
Cleanup:

   On Error Resume Next
   Set objDOM = Nothing
   Set objTransport = Nothing
   Set objTransportRead = Nothing
   
   On Error GoTo 0
   GetNextRegisteredAuditLogEntry = strReturn
   BubbleOnError udtError

Exit Function

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME, , strExtraInfo
   Resume Cleanup
   
End Function

Private Sub LookForMessages()

Const SUB_NAME = "LookForMessages"

Dim uError As udtErrorState

Dim strBrokenRules As String
Dim strMsg As String


   On Error GoTo ErrorHandler
   
   gboolProcessingMessages = True
   
   Me.Icon = Me.picGreen
   ModifySysTrayIcon Me
   
   mobjConfig.ProcessorState = Running
   UpdateStatusBar
   
   If Not mobjConfig.LoggedIn Then mobjConfig.Login
            
   If mobjConfig.LoggedIn Then
         Do
            strBrokenRules = GetNextRegisteredAuditLogEntry(strMsg)
            
            If NoRulesBroken(strBrokenRules) Then
               If Len(strMsg) > 0 Then
                  strBrokenRules = ProcessMessage(strMsg)
                  mobjConfig.LastMessageProcessed = Now
               End If
            End If
         
            If RulesBroken(strBrokenRules) Then
               LogDecodeError mobjConfig.InstanceName, _
                              strMsg, _
                              vbNullString, _
                              vbObjectError + 1, _
                              SUB_NAME, _
                              strBrokenRules
               mobjConfig.LastErrorOccurred = Now
            End If
            
            
            UpdateInfoBar
            DoEvents
         Loop Until (strMsg = vbNullString) Or (gboolShutdown = True)
      End If

Cleanup:

   On Error Resume Next
   
   If mobjConfig.MsgProcessing = Automatic Then
         mobjConfig.ProcessorState = Waiting
         Me.Icon = Me.picAmber
      Else
         mobjConfig.ProcessorState = Stopped
         Me.Icon = Me.picRed
      End If
   ModifySysTrayIcon Me
   UpdateStatusBar
   
   gboolProcessingMessages = False
   
   On Error GoTo 0
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   mobjConfig.LastMessageProcessed = Now
   mobjConfig.LastErrorOccurred = mobjConfig.LastMessageProcessed
   LogDecodeError mobjConfig.InstanceName, _
                  strMsg, _
                  vbNullString, _
                  uError.Number, _
                  uError.Source, _
                  uError.Description
   Resume Next
   
End Sub

Private Sub LstMessages_DblClick()

Dim strMsg As String

   If LstMessages.ListIndex < 0 Then Exit Sub

   strMsg = LstMessages.List(LstMessages.ListIndex)
   frmShowMsg.ShowMsg strMsg
   
End Sub

Private Sub LstStatus_DblClick()

Const SUB_NAME = "LstStatus_DblClick"

Dim uError As udtErrorState

Dim sMsg As String

   On Error GoTo ErrorHandler
   
   If LstStatus.ListIndex < 0 Then GoTo Cleanup
   
   sMsg = LstStatus.List(LstStatus.ListIndex)
   sMsg = Replace(sMsg, vbCrLf, Chr(3))
   sMsg = Replace(sMsg, vbCr, vbCrLf)
   sMsg = Replace(sMsg, vbLf, vbCrLf)
   sMsg = Replace(sMsg, Chr(3), vbCrLf)
   sMsg = Replace(sMsg, vbTab, vbCrLf & vbCrLf, 1, 1)
   frmShowMsg.ShowMsg sMsg
   
Cleanup:

   On Error GoTo 0
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   AddToStatusList CreateModuleErrorString(SUB_NAME, uError)
   Resume Cleanup

End Sub

Private Sub mnuMode_Click()

   If mnuMode.Caption = "&Manual" Then
         DisableMessageProcessing
      Else
         EnableMessageProcessing
      End If
      
   UpdateInfoBar
   
End Sub

Private Sub mnuOptions_Click(Index As Integer)

Const SUB_NAME = "mnuOptions_Click"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
   
   Select Case Index
      Case 0
         mnuOptions(Index).Checked = Not (mnuOptions(Index).Checked)
         mobjConfig.ShowMessages = mnuOptions(Index).Checked
         mnuOptions(1).Visible = mnuOptions(Index).Checked
         mnuOptions(2).Visible = mnuOptions(Index).Checked
         LstMessages.Visible = mnuOptions(Index).Checked
      Case 2
         LstMessages.Clear
   End Select
   
Cleanup:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:
   
   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   AddToStatusList CreateModuleErrorString(SUB_NAME, uError)
   Resume Cleanup
   
End Sub

Private Sub mnuPopupProcessing_Click()

Const SUB_NAME = "mnuPopupProcessing_Click"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
   
   If mnuPopupProcessing.Caption = "&Resume" Then
         EnableMessageProcessing
      Else
         DisableMessageProcessing
      End If
   
Cleanup:

   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub mnuPopupShow_Click()

   If mnuPopupShow.Caption = "&Show" Then
      Me.Visible = True
      mnuPopupShow.Caption = "&Hide"
   Else
      Me.Visible = False
      mnuPopupShow.Caption = "&Show"
   End If
   
End Sub

Private Sub mnuProcessor_Click(Index As Integer)

Const SUB_NAME = "mnuProcessor_Click"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler

   Select Case Index
      Case 0   'Manual Run
         LookForMessages
      Case 2   'Close Window
         mnuPopupShow_Click
   End Select
   
Cleanup:

   On Error GoTo 0
   
Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   AddToStatusList CreateModuleErrorString(SUB_NAME, udtError)
   Resume Cleanup
   
End Sub

Private Sub mnuSetup_Click()

Const SUB_NAME = "mnuSetup_Click"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
   
   frmOptions.ShowConfig mobjConfig
    
   If mobjConfig.MsgProcessing = Automatic Then
         EnableMessageProcessing
      Else
         DisableMessageProcessing
      End If
      
Cleanup:

   On Error Resume Next
   Unload frmOptions
   UpdateStatusBar
   
   On Error GoTo 0
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   AddToStatusList CreateModuleErrorString(SUB_NAME, uError)
   Resume Cleanup
   
End Sub

Private Sub mPopupShutdown_Click()

   On Error Resume Next
   
   gboolShutdown = True
   
   On Error GoTo 0
   
End Sub

Private Function ProcessMessage(ByVal strMsg As String) As String
'----------------------------------------------------------------------------------
'
' Purpose:
'
' Inputs:
'     strMsg        :  XML from the Audit Log
'
' Outputs:
'
'     returns an errors as <BrokenRules/> XML string
'
' Modification History:
'  06Jul05 EAC  Modified the writing of messages to disk to work with batched data.
'               Now expected the transformed message to be wrapped in
'               <Files><File>..data..</File><File>..data..</File></Files> xml tags
'
'----------------------------------------------------------------------------------

Const SUB_NAME = "ProcessMessage"

Dim objTransform As Object

Dim uError As udtErrorState

Dim strBrokenRules As String
Dim strExtraInfo As String
Dim strTranslatedXML As String


   On Error GoTo ErrorHandler
   
   If mobjConfig.LoggingOn Then LogToFile strMsg
   If mobjConfig.ShowMessages Then AddToMessageList strMsg

   'check if the incoming XML needs to be transformed
   If Len(mobjConfig.TransformationDllAppID) = 0 Then
      strTranslatedXML = strMsg
   Else
      strExtraInfo = "Creating object '" & mobjConfig.TransformationDllAppID & "'"
      Set objTransform = CreateObject(mobjConfig.TransformationDllAppID)
      
      strExtraInfo = "Calling the translate method of '" & mobjConfig.TransformationDllAppID & "'"
      strBrokenRules = objTransform.translate(mobjConfig.SessionId, _
                                              mobjConfig.InstanceName, _
                                              strMsg, _
                                              strTranslatedXML)
      
      strExtraInfo = vbNullString
      Set objTransform = Nothing
   End If
   
   If mobjConfig.ShowMessages Then AddToMessageList strTranslatedXML
   
   If NoRulesBroken(strBrokenRules) Then
      If mobjConfig.LoggingOn Then LogToFile "Translated message: " & strTranslatedXML
      strBrokenRules = SaveMessages(strTranslatedXML)
   End If
      
Cleanup:

   On Error Resume Next
   Set objTransform = Nothing
   
   On Error GoTo 0
   ProcessMessage = strBrokenRules
   BubbleOnError uError
   
Exit Function

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Function

Public Sub Startup(ByRef objConfig As EventNotifierV1.Config)

Const SUB_NAME = "Startup"

Dim udtError As udtErrorState

   On Error GoTo ErrorHandler
   
   Set mobjConfig = objConfig
   
   If mobjConfig.MsgProcessing = Automatic Then
         EnableMessageProcessing
      Else
         DisableMessageProcessing
      End If
      
Cleanup:

   On Error GoTo 0
   BubbleOnError udtError
   
Exit Sub

ErrorHandler:

   CaptureErrorState udtError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub timInterval_Timer()

Const SUB_NAME = "timInterval_Timer"

Dim uError As udtErrorState

   On Error GoTo ErrorHandler
      
   timInterval.Enabled = False
   mlngTimerCount = mlngTimerCount + 1
   
   If mlngTimerCount = mobjConfig.ProcessingInterval Then
         LookForMessages
         mlngTimerCount = 0
      End If
      
   If (mobjConfig.MsgProcessing = Automatic) And (Not gboolShutdown) Then timInterval.Enabled = True
   
Cleanup:
   
   On Error GoTo 0
   BubbleOnError uError
   
Exit Sub

ErrorHandler:

   CaptureErrorState uError, CLASS_NAME, SUB_NAME
   Resume Cleanup
   
End Sub

Private Sub UpdateInfoBar()


   lblLastMsg.Caption = Format(mobjConfig.LastMessageProcessed, _
                               "DDMMMYYYY HH:MM:SS")
   lblLastError.Caption = Format(mobjConfig.LastErrorOccurred, _
                                 "DDMMMYYYY HH:MM:SS")

End Sub

Private Sub UpdateStatusBar()

   With Me.lblStatus
      .Segment = 0
      .SegCaption = "Mode : " & DecodeMode()
      
      .Segment = 1
      .SegCaption = "Status : " & DecodeState()
               
   End With
   
End Sub
