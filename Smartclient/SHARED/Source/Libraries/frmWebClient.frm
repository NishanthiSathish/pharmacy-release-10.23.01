VERSION 5.00
Object = "{EAB22AC0-30C1-11CF-A7EB-0000C05BAE0B}#1.1#0"; "ieframe.dll"
Begin VB.Form frmWebClient 
   BorderStyle     =   3  'Fixed Dialog
   Caption         =   "Form1"
   ClientHeight    =   11010
   ClientLeft      =   45
   ClientTop       =   435
   ClientWidth     =   12960
   Icon            =   "frmWebClient.frx":0000
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   734
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   864
   ShowInTaskbar   =   0   'False
   StartUpPosition =   2  'CenterScreen
   Begin SHDocVwCtl.WebBrowser WebBrowserCtrl 
      Height          =   11055
      Left            =   0
      TabIndex        =   0
      Top             =   0
      Width           =   12975
      ExtentX         =   22886
      ExtentY         =   19500
      ViewMode        =   0
      Offline         =   0
      Silent          =   0
      RegisterAsBrowser=   0
      RegisterAsDropTarget=   1
      AutoArrange     =   0   'False
      NoClientEdge    =   0   'False
      AlignLeft       =   0   'False
      NoWebView       =   0   'False
      HideFileNames   =   0   'False
      SingleClick     =   0   'False
      SingleSelection =   0   'False
      NoFolders       =   0   'False
      Transparent     =   0   'False
      ViewID          =   "{0057D0E0-3573-11CF-AE69-08002B2E1262}"
      Location        =   ""
   End
   Begin VB.Timer CloseTimer 
      Enabled         =   0   'False
      Interval        =   250
      Left            =   3840
      Top             =   3960
   End
   Begin VB.Timer KeyPressTimer 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   3740
      Top             =   3860
   End
End
Attribute VB_Name = "frmWebClient"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

'-----------------------------------------------------------------------------------
'                               frmWebClient.frm
'
' Will display a web page within this form.
'
' Code example:
'       Dim webForm As New frmWebClient
'       webForm.Navigate "www.ascribe.com"
'       Load webForm
'       webForm.Show 1
'       Unload webForm
'
' It is possibled to set a call back method that will fire on a key press from web page.
' The web page will need a hfKeyPress hidden element on the page, whose value should be set
' to key code value that is pressed (only single value). 
' On the VB side before showing this form call SetKeyPessCallBackProc passing in the call back method address.
' The call back method should have parameters 
'    ByVal webForm As Object   - Instance of this web form
'    ByVal lngKeyPress As Long - Key code that was passed from web form (via hfKeyPress element)
'    ByVal nUnused3 As Long    - Not used but should be present
'    ByVal nUnused4 As Long    - Not used but should be present
' 
' 23Jun09 XN Created
' 05Jul10 XN F0090834 Original form could crash if web page requests the form to close.
'            Got around this problem by having the WebBrowser start a timer which
'            then causes the form to close.
' 26Jul11 XN F0118239 Add ability to call methods based on key press on web form
'            Added methods SetKeyPessCallBackProc, KeyPressTimer_Timer, CallJavaScript
'-----------------------------------------------------------------------------------

Option Explicit

Private strURL As String                  ' Url to display
Private lngKeyPressCallBackProc As Long   ' Address of method to call on key press   


' Sets the url to navigate to
' Call this before the form is displayed
Public Sub Navigate(ByVal url As String)
    strURL = url
End Sub

' Timer used to close the form after small delay.
' Called if the web page requests the form to close
' Done using this delayed close to prevent crash.
' 05Jul10 XN F0090834
Private Sub CloseTimer_Timer()
    CloseTimer.Enabled = False
    DoEvents
    Unload Me
End Sub

Private Sub Form_Load()
    WebBrowserCtrl.Navigate2 (strURL)
    
    While WebBrowserCtrl.Busy
        DoEvents
    Wend
    
    KeyPressTimer.Enabled = (lngKeyPressCallBackProc > 0)
End Sub

' Should close the form if the escape key is pressed
Private Sub Form_KeyUp(KeyCode As Integer, Shift As Integer)
    If KeyCode = vbKeyEscape Then
        Unload Me
    End If
End Sub

' Resizes the web browser control with the form
Private Sub Form_Resize()
    WebBrowserCtrl.Width = Me.ScaleWidth
    WebBrowserCtrl.Height = Me.ScaleHeight
End Sub

' Closes form when web browser page closes (actual use short timer to close the form)
Private Sub WebBrowserCtrl_WindowClosing(ByVal IsChildWindow As Boolean, Cancel As Boolean)
    ' Canceling the close request means that you don't get the popup message
    ' about the web page wanting to close the window, and asking the user if
    ' this is okay.
    Cancel = True
    ' Unload Me ' 05Jul10 XN F0090834
    
    ' Then start CloseTimer which causes a delayed form close.
    ' (if use Unload Me instead of using timer form can crash).
    ' 05Jul10 XN F0090834
    CloseTimer.Enabled = True
End Sub

' Setup call back method to be called when key is pressed on the web form
' Note web page will need a hfKeyPress hidden element on the page, 
' whose value should be set to key code value that is pressed (only single value). 
' 26Jul11 XN F0118239
Public Sub SetKeyPessCallBackProc(ByVal keyPressCallBackProc As Long)
    lngKeyPressCallBackProc = keyPressCallBackProc
End Sub

' Timer that fires every second that check if value has been set in web page hfKeyPress element
' If set will call method set in SetKeyPessCallBackProc
' 26Jul11 XN F0118239
Private Sub KeyPressTimer_Timer()
    KeyPressTimer.Enabled = False

    ' Get web doc   
    Dim doc As Object
    If (lngKeyPressCallBackProc <> 0) Then
        Set doc = WebBrowserCtrl.Document
    End If
    
    ' Get hfKeyPress reference
    Dim hfKeyPress As Object
    If Not (doc Is Nothing) Then
        Set hfKeyPress = doc.GetElementById("hfKeyPress")
    End If
    
    ' Get key code value in hfKeyPress (and then clear the hfKeyPress)
    Dim lngKeyCode As Long
    lngKeyCode = 0
    If Not (hfKeyPress Is Nothing) Then
        If IsNumber(hfKeyPress.getAttribute("value"), False) Then
            lngKeyCode = CLng(hfKeyPress.getAttribute("value"))
            hfKeyPress.setAttribute "value", ""
        End If
    End If
    
    ' Call the call back method
    If (lngKeyCode > 0) And (lngKeyPressCallBackProc <> 0) Then
        CallWindowProc lngKeyPressCallBackProc, ObjPtr(Me), lngKeyCode, 0, 0
    End If
        
    KeyPressTimer.Enabled = True
End Sub

' Allow running java script on the web page
Public Sub CallJavaScript(ByVal strScript As String)
    If Not (WebBrowserCtrl.Document Is Nothing) Then
        WebBrowserCtrl.Document.parentWindow.execScript strScript
    End If
End Sub

