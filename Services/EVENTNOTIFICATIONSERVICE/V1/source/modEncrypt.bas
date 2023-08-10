Attribute VB_Name = "modEncrypt"
Option Explicit
DefInt A-Z


Public Function encodehex(ByVal passw As String, Optional i_intSeed As Integer = 0) As String
'-----------------------------------------------------------------------------
'30Oct94 CKJ Written. Returns an decoded hex string
'05Jul01 AE  Added Optional Seed parameter.
'            calls to this function with the same value of i_intSeed
'            will always produce the same encoded string
'-----------------------------------------------------------------------------

Dim temppas$, plen%, ByteNo%, pasch%
Dim intDummy

   If i_intSeed <> 0 Then
      'Set the seed to always give the same sequence of random numbers
         intDummy = Rnd(-i_intSeed)
         Randomize i_intSeed
      Else
      'Use a different sequence each time
         Randomize Timer
      End If

   plen = Len(passw)
   temppas$ = ""
   If plen Then
         For ByteNo = 1 To plen
            pasch = Asc(Mid$(passw, ByteNo))
            temppas$ = temppas$ & Right$("0" & Hex$(((pasch \ 2) And &H55) Or ((Rnd * 256) And &HAA)), 2)
            temppas$ = temppas$ & Right$("0" & Hex$((pasch And &H55) Or ((Rnd * 256) And &HAA)), 2)
         Next       '14Feb95 CKJ removed byteno
      End If

   encodehex = temppas$
   
End Function

Public Function decodehex(passw As String) As String
'-----------------------------------------------------------------------------
'30Oct94 CKJ Written. Returns an encoded hex string
'-----------------------------------------------------------------------------
Dim temppas$, plen%, ByteNo%

   plen = Len(passw) \ 4
   temppas$ = ""
   If plen Then
         For ByteNo = 1 To plen * 4 Step 4
            temppas$ = temppas$ & Chr$((((Val("&h" & Mid$(passw, ByteNo, 2)) * 2) Mod 256) And &HAA) Or (Val("&h" & Mid$(passw, ByteNo + 2, 2)) And &H55))
         Next       '14Feb95 CKJ removed byteno
      End If

   decodehex = temppas$
End Function
