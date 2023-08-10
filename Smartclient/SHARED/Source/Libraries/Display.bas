Attribute VB_Name = "Display"
Option Explicit
Public Enum eMode
   Create
   Refresh
   Remove
End Enum
Public Sub HeaderDisplay(frm As Form, lvw As ListView, blnMode As eMode, intBorder As Integer)
' Assumes a control is present and formatted to your liking.

On Error GoTo ErrHandler:

   Dim intColumns    As Integer
   Dim lvwHeader     As ColumnHeader
   Dim intFudge As Integer
   Dim intExtraWidth 'Scrollbar shennanigans
   
   
   lvw.HideColumnHeaders = False
   
   For Each lvwHeader In lvw.ColumnHeaders
      intColumns = intColumns + 1
      If blnMode = eMode.Create Then
         Load frm.lblHeading(intColumns)
      End If
      
      If blnMode = eMode.Remove Then
         Unload frm.lblHeading(intColumns)
      Else
          If intColumns > 1 Then intFudge = 30
          'If intColumns = lvw.ColumnHeaders.count Then intBorder = 0
          
         With frm.lblHeading(intColumns)
            .Visible = True
            .Left = lvwHeader.Left + lvw.Left + intBorder + intFudge '60
            If intColumns = lvw.ColumnHeaders.count Then 'intBorder = 0
            intBorder = 10
'            ''intExtraWidth = 220
            End If
            .Width = lvwHeader.Width + (intBorder * 2) '+ intFudge ''+ intExtraWidth '+ intFudge '+ 50
            .Caption = Chr(13) & lvwHeader.text
            .FontBold = False
            .FontSize = 8
            .BackColor = &H80000003
            .ForeColor = White
            .top = (lvw.top - frm.lblHeading(0).Height) + 10
            .ZOrder 0
         End With
      End If
   Next
   If Not lvw.ColumnHeaders.count > 0 And blnMode <> Remove Then frm.lblHeading(lvw.ColumnHeaders.count).Width = frm.lblHeading(lvw.ColumnHeaders.count).Width + 80
   lvw.HideColumnHeaders = True

Exit Sub

ErrHandler:
   MsgBox "Unable to display column headings."
End Sub

