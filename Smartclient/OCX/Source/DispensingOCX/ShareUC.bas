Attribute VB_Name = "ShareUC"
'    ShareUC
'
'24Sep04 Share controls from a User Control withing modules of the same project

Option Explicit
DefInt A-Z

'This is a reference to the Usercontrol.Controls collection, set during startup
Public colControls As Object
'

Public Function RefUCbyIndex(index As Integer) As Control
'Fetch a reference to a control on our Usercontrol, this is the
'crux of the matter, THIS is indeed the thing "we can't do"
   
   If UserControlIsAlive = 1 Then
      Set RefUCbyIndex = colControls(index)
   Else
      MsgBox "UserControl not in live state:" & Str$(UserControlIsAlive), MB_ICONSTOP, "RefUCbyIndex"
   End If

End Function

Public Function RefUCbyName(ctrlname As String, Optional ctrlindex As Variant) As Control
   
   If UserControlIsAlive = 1 Then
      If IsMissing(ctrlindex) Then
         Set RefUCbyName = colControls.Item(ctrlname)
      Else
         Set RefUCbyName = colControls.Item(ctrlname).Item(ctrlindex)
      End If
   Else
      MsgBox "UserControl not in live state:" & Str$(UserControlIsAlive), MB_ICONSTOP, "RefUCbyName"
   End If

End Function

Public Function txtUC(ctrlname As String, Optional ctrlindex As Variant) As TextBox

   Set txtUC = RefUCbyName(ctrlname, ctrlindex)
   
End Function

Public Function lstUC(ctrlname As String, Optional ctrlindex As Variant) As ListBox

   Set lstUC = RefUCbyName(ctrlname, ctrlindex)
   
End Function

Public Function cmbUC(ctrlname As String, Optional ctrlindex As Variant) As ComboBox

   Set cmbUC = RefUCbyName(ctrlname, ctrlindex)
   
End Function

Public Function fraUC(ctrlname As String, Optional ctrlindex As Variant) As Frame

   Set fraUC = RefUCbyName(ctrlname, ctrlindex)
   
End Function

Public Function picUC(ctrlname As String, Optional ctrlindex As Variant) As PictureBox

   Set picUC = RefUCbyName(ctrlname, ctrlindex)
   
End Function

Public Function imgUC(ctrlname As String, Optional ctrlindex As Variant) As Image

   Set imgUC = RefUCbyName(ctrlname, ctrlindex)
   
End Function

Public Function cmdUC(ctrlname As String, Optional ctrlindex As Variant) As CommandButton

   Set cmdUC = RefUCbyName(ctrlname, ctrlindex)
   
End Function

Public Function lblUC(ctrlname As String, Optional ctrlindex As Variant) As label

   Set lblUC = RefUCbyName(ctrlname, ctrlindex)
   
End Function

Public Function chkUC(ctrlname As String, Optional ctrlindex As Variant) As CheckBox

   Set chkUC = RefUCbyName(ctrlname, ctrlindex)
   
End Function

Public Function shpUC(ctrlname As String, Optional ctrlindex As Variant) As Shape

   Set shpUC = RefUCbyName(ctrlname, ctrlindex)
   
End Function

Public Function linUC(ctrlname As String, Optional ctrlindex As Variant) As Line

   Set linUC = RefUCbyName(ctrlname, ctrlindex)
   
End Function

