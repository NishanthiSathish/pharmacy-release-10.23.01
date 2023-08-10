Attribute VB_Name = "modSystemTray"
Option Explicit
DefInt A-Z

'=========================================================================================
'NB. The following skeleton procedure must be added to the form that is being used to
'    call the ShowIconInSysTray procedure. A popup menu should be added to the forms menu
'    using the menu editor. You will then have to code responses to click events on the
'    popup menu.
'=========================================================================================
'
'Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)
'
'Dim lResult As Long
'Dim lMsg As Long
'
'   If Me.ScaleMode = vbPixels Then
'         lMsg = X
'      Else
'         lMsg = X / Screen.TwipsPerPixelX
'      End If
'
'   Select Case lMsg
'      Case WM_RBUTTONUP
'           'popup a menu
'      Case Else
'   End Select
'
'End Sub

Private Type NOTIFYICONDATA
        cbSize As Long
        hwnd As Long
        uID As Long
        uFlags As Long
        uCallbackMessage As Long
        hIcon As Long
        szTip As String * 64
End Type

Private Const NIM_ADD = &H0&
Private Const NIM_MODIFY = &H1&
Private Const NIM_DELETE = &H2&
Private Const NIF_MESSAGE = &H1&
Private Const NIF_ICON = &H2&
Private Const NIF_TIP = &H4&

Public Const WM_MOUSEMOVE = &H200&
Public Const WM_LBUTTONDOWN = &H201&
Public Const WM_LBUTTONUP = &H202&
Public Const WM_LBUTTONDBLCLK = &H203&
Public Const WM_RBUTTONDOWN = &H204&
Public Const WM_RBUTTONUP = &H205&
Public Const WM_RBUTTONDBLCLK = &H206&

Private Declare Function Shell_NotifyIcon Lib "shell32.dll" Alias "Shell_NotifyIconA" (ByVal dwMessage As Long, lpData As NOTIFYICONDATA) As Long
Private Declare Function SetForegroundWindow Lib "user32" (ByVal hwnd As Long) As Long

Private nid As NOTIFYICONDATA

Public Sub ShowIconInSysTray(oForm As Form, Optional ByVal sToolTipText As String = "")
   
   With nid
      .cbSize = Len(nid)
      .hwnd = oForm.hwnd
      .uID = vbNull
      .uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
      .uCallbackMessage = WM_MOUSEMOVE
      .hIcon = oForm.Icon
      .szTip = Trim(sToolTipText) & vbNullChar
   End With
   
   Shell_NotifyIcon NIM_ADD, nid
   
End Sub

Public Sub ModifySysTrayToolTip(Optional ByVal sToolTipText As String = "")

   If sToolTipText <> "" Then nid.szTip = sToolTipText & vbNullChar
      
   Shell_NotifyIcon NIM_MODIFY, nid
   
End Sub

Public Sub RemoveIconFromSysTray()

   Shell_NotifyIcon NIM_DELETE, nid
   
End Sub

Public Sub ModifySysTrayIcon(ByRef oForm As Form, _
                             Optional ByVal sIconPath As String = "")

   If Trim(sIconPath) <> "" Then
         If UCase(Dir(sIconPath)) = UCase(sIconPath) Then Set oForm.Icon = LoadPicture(sIconPath)
      End If
      
   nid.hIcon = oForm.Icon
   Shell_NotifyIcon NIM_MODIFY, nid
      
End Sub



