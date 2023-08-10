Option Explicit
DefInt A-Z

Sub ShowSelDir(DirName$, escd%)

   If Trim$(DirName$) = "" Then
         SelDir.Tag = ""
      Else
         SelDir.Tag = DirName$
      End If

   SelDir.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form

   If Trim$(SelDir.Tag) = "" Then
         DirName$ = ""
         escd = True
      Else
         DirName$ = SelDir.Tag
         escd = False
      End If

   Unload SelDir

End Sub

