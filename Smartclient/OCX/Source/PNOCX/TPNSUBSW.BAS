Attribute VB_Name = "TPNSUBSW"
'DOStoWIN V1.0 (c) ASCribe 1996
'-----------------------------------------------------------------------------
'                     TPN subprogramme library   18.11.89
'                                  ASC
'-----------------------------------------------------------------------------
' 4Aug90 CKJ changename move from tpn
'21Aug90 CKJ CPline layout tidied
'06Dec90 CKJ Binary search removed and placed in Q4LIB\IDX.BAS
'           -get and putpatid changed to 173 byte structure
'13Dec90 CKJ dob$ fault fixed in getpatid
'19Dec90 ASC weight sorted out was rounding incorrectly in getpatid
' 3Feb91 CKJ ASC's fix to my fix now sorted out! (dec pt added to valid chars)
'24Feb91 CKJ Openrandomfile moved to DFHL
' 9Aug91 CKJ GetPointer renamed GetPointerX to avoid conflict with GetPointer
'            in DFHL. ** IMPORTANT See caveats in comments at start of proc **
'29Sep91 CKJ CPline removed, now as in-line code in TPN
' 6Oct91 CKJ Warningsvdu: all in one window
'20Oct91 CKJ Threesigfigsvdu/lptr >9999 now displayed
'27Oct91 CKJ Removed GetPointerX, moved to tpnrems.bas. Moved Cleol from TPN
'11Nov91 CKJ Added U for unknown to Adult
'16Jan92 CKJ % signs removed
'26Jan92 CKJ Moved activity & injury factors and not-in-batch msg from
'            TPN to make more room.
' 3Oct94 ASC Mod to Threesigfigs
'23Mar95 CKJ Mod to gettpn1
'27Jul95 CKJ Merged mod from server
' 1Aug95 CKJ Invokes INI file from TPN.
' 2Jan96 CKJ TpnIni$ added
' 8Nov96 CKJ ThreeSigFigs: Corrected neg number handling
' 3Jan96 CKJ ThreeSigFigs, tsf, tsfvdu: Changed handling of 1.0 to 9.5 ml from x.x to x.xx
'            ie truly three significant figures
'30May97 CKJ Changed Money to MoneyV to avoid conflict
'12Jun97 CKJ ConstitsFormat: changed Selenium from umol to nmol
'19Oct98 CKJ FourSF() written. Option Explicit turned on
'18Jul00 CKJ NotInBatch: Modified wording of message
'14Feb02 ATW OneDecFIg & odf - ENHDB 1511 ; restrict precision of TPN infusion rate to one DP.
'30Mar04 CKJ {SP1}
'            Removed obsolete procs enteractfact, enterinjfact

DefInt A-Z
Option Explicit

'---------------------- MOVED FROM TPN.BAS -------------------------------
'TPN defaults file structure for adult/paed, amino/fat/mixed
'Disk file consists of two records, first is paediatric, second is adult.
' 1Nov91 CKJ file written
' 2Nov91 CKJ infusionrate & dropspermin added from Libname, baxapump added
' 9Nov91 CKJ overage as % removed
'24Nov91 CKJ Added printreversefeed
'15Dec91 CKJ Added printer numbers
'18Jan92 CKJ Added issretenabled
'26Jan92 CKJ Added 4 inch labels, split issret into issue & return enabled
' 1Oct96 CKJ Moved this from Tpn.bas to Tpnsubsw.bas
'---------------------------------------------------------------------------

Type tpndefaults
   seplabels     As Integer            'T/F
   infusionrate  As Integer            'T/F
   dropspermin   As Integer            'T/F
   printreversefeed As Integer         'T/F
   baxapump      As Integer            'T/F
   plainprinter  As Integer            '1/2/3
   labelprinter  As Integer            '1/2/3
   issueenabled  As Integer            'T/F
   returnenabled As Integer            'T/F
   labels4inches As Integer            'T/F
   ' 1 = Amino  2 = Fat  3 = Mixed
   overagevol(1 To 3) As Integer       'eg 50 mls
   expiry(1 To 3) As String * 10       'DD/MM/YYYY
   NumLabels(1 To 3) As Integer        'eg  2 labels
   infusehrs(1 To 3) As Integer        'eg 20 hrs
   dropsperml(1 To 3) As Integer       'eg 15 d/ml
End Type


'Sub enteractfact (AF$, k As kbdcontrol)
''----- ACTIVITY FACTOR------
'Dim s$, count%, ans$
'
'   s$ = ""
'   For count = 0 To 3
'     's$ = s$ & Format$(count + 1, " #0   ") & tp("af" & Format$(count)) & cr$ & " "
'      s$ = s$ & Fmt$(count + 1, " #0   ") & tp("af" & Format$(count)) & cr$ & " "
'   Next
'   s$ = s$ & cr$ & "    Enter activity"
'   Do
'      k.max = 1
'      k.min = 1
'      ans$ = LTrim$(Str$(Val(AF$) + 1))
'      k.helpnum = 90
'      k.validchars = "1234" & nulls
'      inputwin "Activity Factor", s$, ans$, k
'      If k.escd Then Exit Do
'      Select Case Val(ans$)
'         Case 1 To 4: Exit Do
'         Case Else:   popmessagecr "!n!i", "Invalid"
'         End Select
'   Loop Until Val(ans$) < 4
'   If Not k.escd Then AF$ = LTrim$(Str$(Val(ans$) - 1))
'
'End Sub

'Sub enterinjfact (ifact$, k As kbdcontrol)
''---- INJURY FACTOR-----
'Dim s$, count%, ans$
'
'   s$ = ""
'   For count = 0 To 10
'     's$ = s$ & Format$(count + 1, " #0   ") & tp("if" & Format$(count)) & cr$ & " "
'      s$ = s$ & Fmt$(count + 1, " #0   ") & tp("if" & Format$(count)) & cr$ & " "
'   Next
'   s$ = s$ & cr$ & "    Enter injury"
'   Do
'      ans$ = LTrim$(Str$(Val(ifact$) + 1))
'      k.nums = True
'      k.max = 2
'      k.min = 1
'      k.helpnum = 100
'      inputwin "Injury Factor", s$, ans$, k
'      If k.escd Then Exit Do
'      Select Case Val(ans$)
'         Case 1 To 11: Exit Do
'         Case Else: popmessagecr "!n!iIncorrect entry", "Please enter a number in the range 1 to 11"
'         End Select
'   Loop
'   If Not k.escd Then ifact$ = LTrim$(Str$(Val(ans$) - 1))
'
'End Sub


Sub EnterSerumPotassium(KVal%)
' 3Nov96 CKJ Uses inputmenu

Dim ans$, count%
ReDim Menu$(6), menuhlp(6) As Integer
                           
   ans$ = Format(KVal% + 1)
   Menu$(0) = "Select category for Serum Potassium"
   For count = 0 To 5
      Menu$(count + 1) = tp("KQ" & Format$(count))
   Next
   inputmenu Menu$(), menuhlp(), ans$, k
   If Not k.escd Then KVal% = Val(ans$) - 1

   's$ = ""
   'For count = 0 To 5
   '   s$ = s$ & Fmt$(count + 1, " #0   ") & tp("KQ" & Format$(count)) & cr$ & " "
   'Next
   's$ = s$ & cr$ & "    Select category"
   'Do
   '   ans$ = Format(KVal% + 1)   'LTrim$(Str$(Val(ifact$) + 1))
   '   k.nums = True
   '   k.max = 2
   '   k.min = 1
   '   k.helpnum = 100
   '   inputwin "Serum Potassium", s$, ans$, k
   '   If k.escd Then Exit Do
   '   Select Case Val(ans$)
   '      Case 1 To 6: Exit Do
   '      Case Else: popmessagecr "!n!iIncorrect entry", "Please enter a number in the range 1 to 6"
   '      End Select
   'Loop
   'If Not k.escd Then KVal% = Val(ans$) - 1
                       
End Sub

Sub enterSerumSodium(NaVal%)
' 3Nov96 CKJ Uses inputmenu

Dim ans$, count%
ReDim Menu$(6), menuhlp(6) As Integer
                           
   ans$ = Format(NaVal% + 1)
   Menu$(0) = "Select category for Serum Sodium"
   For count = 0 To 5
      Menu$(count + 1) = tp("NaQ" & Format$(count))
   Next
   inputmenu Menu$(), menuhlp(), ans$, k
   If Not k.escd Then NaVal% = Val(ans$) - 1

   
'   s$ = ""
'   For count = 0 To 5
'      s$ = s$ & Fmt$(count + 1, " #0   ") & tp("NaQ" & Format$(count)) & cr$ & " "
'   Next
'   s$ = s$ & cr$ & "    Select category"
'   Do
'      ans$ = Format(NaVal% + 1)   'LTrim$(Str$(Val(ifact$) + 1))
'      k.nums = True
'      k.max = 2
'      k.min = 1
'      k.helpnum = 100
'      inputwin "Serum Sodium", s$, ans$, k
'      If k.escd Then Exit Do
'      Select Case Val(ans$)
'         Case 1 To 6: Exit Do
'         Case Else: popmessagecr "!n!iIncorrect entry", "Please enter a number in the range 1 to 6"
'         End Select
'   Loop
'   If Not k.escd Then NaVal% = Val(ans$) - 1

End Sub

Sub FindBaxaFiles(pathfile$, Lastfil$, Numfiles%)
'-----------------------------------------------------------------------------
' Find LAST file which matches patient number, format \BAXA\1234C.DAT
'28Jan92 CKJ proc written
'-----------------------------------------------------------------------------
Dim filespec$, Fileis$

   Lastfil$ = ""
   Numfiles = 0
   If pathfile$ <> "" Then
         filespec$ = pathfile$
         Do
            On Local Error GoTo baxaerrhandler
            If filespec$ <> "" Then
                  Fileis$ = Dir$(filespec$)
                  filespec$ = ""
               Else
                  Fileis$ = Dir$
               End If
            On Local Error GoTo 0
            If Fileis$ <> "" Then
                  Numfiles = Numfiles + 1
                  If Fileis$ > Lastfil$ Then Lastfil$ = Fileis$
               End If
         Loop While Fileis$ <> ""
      End If

Exit Sub

baxaerrhandler:
' error 57 device I/O error
' error 68 device unavailable
' error 71 disk not ready
   Select Case Err
      Case 57, 68, 71
         Fileis$ = ""
      Case Else
         Error Err
      End Select
Resume Next

End Sub

Function FourSF$(ByVal X!)
'ThreeSigFigs
' 1Mar95 CKJ Written. Note y! is *not* changed
'16Sep96 CKJ Allow neg numbers. Added Abs()
' 3Jan96 CKJ Changed display of 1.0 to 9.5 ml to x.xx from x.x
'ASC 3Oct94 added 000001 to .5 .055 now becomes .06 instead of .05 !!
'16Sep96 CKJ Allow neg numbers: added Abs() & Int()->Fix()
' 8Nov96 CKJ Corrected neg number handling
' 3Jan96 CKJ Changed handling of 1.0 to 9.5 ml to x.xx from x.x
'19Oct98 CKJ Revised for 4 sig figs;
'               IN              OUT
'            9999.999     => 9999
'             999.9999    =>  999.9
'              99.99999   =>   99.99
'               9.999999  =>    9.999
'                .9999999 =>     .9999
'                .999     =>    0.999
'            any minus sign is in addition to the above
                         
Dim sign%, txt$

   sign = Sgn(X!)
   X! = Abs(X!)
   Select Case X!
      Case Is > 999.9999: X! = Fix(X! + 0.501)                    '1000 <=  0DP
      Case Is > 99.99999: X! = Fix(X! * 10 + 0.5001) / 10         ' 100 <=  1DP  <1000
      Case Is > 9.999999: X! = Fix(X! * 100 + 0.50001) / 100      '  10 <=  2DP  <100
      Case Is > 0.9999999: X! = Fix(X! * 1000 + 0.500001) / 1000  '   1 <=  3DP  <10
      Case Else:          X! = Fix(X! * 10000 + 0.5000001) / 10000 '         4DP  <1
      End Select
   
   Select Case X!
      Case Is > 9999.99: txt$ = Format$(X!)                       ' unchanged
      Case Is > 999.999: txt$ = Format$(X!, "####")               ' whole numbers
      Case Is > 99.9999: txt$ = Format$(X!, "###.#")              ' 1DP
      Case Is > 9.99999: txt$ = Format$(X!, "##.0#")              ' 2DP
      Case Is > 0.999999: txt$ = Format$(X!, "#.0##")             ' 3DP
      Case Is > 0:       txt$ = Format$(X!, ".####")              ' 4DP
      Case 0:            txt$ = "0"                               ' 0
      Case Else:         txt$ = Format$(X!)                       ' unchanged
      End Select

   If Left$(txt$, 1) = "." Then                                   'leading decimal point,
         If Len(txt$) < 5 Then txt$ = "0" & txt$                  'and room for leading 0
      End If
   If sign < 0 Then txt$ = "-" & txt$                             'replace minus sign
   If Len(txt$) < 5 Then txt$ = Right$("    " + txt$, 5)          'pad with preceding spaces
   
   FourSF$ = txt$
         
End Function

Function moneyV(dosh!) As String
'Takes a positive monetary value, rounds it to the nearest 0.5p,
'and returns it as both string & numeric values
'String is RJ left space padded to 7 chars
'30May97 CKJ Changed Money to MoneyV to avoid conflict

Dim tmp$

   dosh! = Int(dosh! * 100 + 0.5001) / 100
   tmp$ = Format$(dosh!, "###0.00")
   If Len(tmp$) < 7 Then tmp$ = Space$(7 - Len(tmp$)) + tmp$
   moneyV = tmp$

End Function

Sub NotInBatch()
'18Jul00 CKJ Modified wording
   
   'popmessagecr "WARNING", "Not allowed in batch manufacture"
   popmessagecr "!", "Not available in batch manufacture"

End Sub

Function odf(ByVal sngValue As Single) As String
' One sig fig
' 14Feb02 ATW ; Written for ENHDB 1511 (reduce precision on TPN infusion rate printouts to 1 sig fig)

   Dim temp$

   OneDecFig sngValue

   Select Case sngValue
      Case Is >= 9999.5: temp = Format$(sngValue)
      Case Is > 99.4:    temp = Format$(sngValue, "####")
      Case Is > 9.999:   temp = Format$(sngValue, "##.0")
      Case Is > 0:       temp = Format$(sngValue, "0.0")
      Case 0:            temp = "0"
      Case Else:
      End Select

   If Len(temp) < 4 Then temp = Right$("    " & temp, 4)

   odf = temp

End Function

Sub OneDecFig(X!)
'ASC 3Oct94 added 000001 to .5 .055 now becomes .06 instead of .05 !!
'16Sep96 CKJ Allow neg numbers: added Abs() & Int()->Fix()
' 8Nov96 CKJ Corrected neg number handling
' 3Jan96 CKJ Changed handling of 1.0 to 9.5 ml to x.xx from x.x
'14Feb02 ATW; Copied from threesigfigs and butchered to only emit up to 1 dp
Dim sign%, Y!


   sign = Sgn(X!)
   Y! = Abs(X!)
   Select Case Y!
      Case Is > 99.4:  X! = Fix(Y! + 0.5001)
     'Case Is > .9999: x! = Fix(y! * 10 + .500001) / 10        '3Jan96 CKJ removed
      Case Is > 9.999: X! = Fix(Y! * 10 + 0.50001) / 10        '3Jan96 CKJ added
      Case Else:       X! = Fix(Y! * 10 + 0.500001) / 10
      End Select
   X! = X! * sign

End Sub

''Sub threesigfigs(X!)
'''ASC 3Oct94 added 000001 to .5 .055 now becomes .06 instead of .05 !!
'''16Sep96 CKJ Allow neg numbers: added Abs() & Int()->Fix()
''' 8Nov96 CKJ Corrected neg number handling
''' 3Jan96 CKJ Changed handling of 1.0 to 9.5 ml to x.xx from x.x
''
''Dim sign%, Y!
''
''   'IF x! > 99.4 THEN
''   '      x! = INT(x! + .5001)
''   '   ELSE
''   '      IF INT(x!) > .9999 THEN
''   '            x! = INT(x! * 10 + .500001) / 10
''   '         ELSE
''   '            x! = INT(x! * 100 + .5000001) / 100
''   '         END IF
''   '   END IF
''
''   sign = Sgn(X!)
''   Y! = Abs(X!)
''   Select Case Y!
''      Case Is > 99.4:  X! = Fix(Y! + 0.5001)
''     'Case Is > .9999: x! = Fix(y! * 10 + .500001) / 10        '3Jan96 CKJ removed
''      Case Is > 9.999: X! = Fix(Y! * 10 + 0.50001) / 10        '3Jan96 CKJ added
''      Case Else:       X! = Fix(Y! * 100 + 0.5000001) / 100
''      End Select
''   X! = X! * sign
''
''End Sub

Function tp$(Entry$)
'ASC 3Jun94 Finds language elements
'11Aug94 NAH Changed from pump
'11Aug95 CKJ Changed from tpnlabel

   'tp$ = txt$("tpnw", "", Entry$)
   tp$ = txt$("pnw", "", Entry$) '28Mar12 TH

End Function

Function tpnini$(Item$, def$)
' 2Jan96 CKJ Written

Dim found%

   'tpnini$ = TxtD$(dispdata$ + "\tpn.ini", "", def$, Item$, found%)
   tpnini$ = TxtD$(dispdata$ + "\pn.ini", "", def$, Item$, found%) '02Feb12 TH Now file = PN
   If Not found Then popmessagecr "!n!iWarning", "Item '" + Item$ + "' missing from PN configuration settings"

End Function

Function tsf$(Y!)
'ThreeSigFigs
' 1Mar95 CKJ Written. Note y! is *not* changed
'16Sep96 CKJ Allow neg numbers. Added Abs()
' 3Jan96 CKJ Changed display of 1.0 to 9.5 ml to x.xx from x.x

Dim X!, Text$

   X! = Y!
   threesigfigs X!

   Select Case Abs(X!)
      Case Is >= 9999.5: Text$ = Format$(X!)          ' unchanged
      Case Is > 99.4:    Text$ = Format$(X!, "####")  ' whole numbers
     'Case Is > .9999:   text$ = Format$(x!, "##.0")  ' 5.0 5.1      '3Jan96 CKJ removed
      Case Is > 9.999:   Text$ = Format$(X!, "##.0")  ' 15.0 15.1    '3Jan96 CKJ added
      Case Is > 0:       Text$ = Format$(X!, "0.0#")  ' 0.0 0.01 0.1
      Case 0:            Text$ = "0"                  '   0
      Case Else:         Text$ = Format$(X!)          ' unchanged
      End Select
   If Len(Text$) < 4 Then Text$ = Right$("    " + Text$, 4)      'pad with preceding spaces
   tsf$ = Text$

   'If x! >= 9999.5 Then
   '      text$ = Str$(x!)
   '   Else
   '      If x! > 99.4 Then
   '            text$ = Format$(x!, "####")        ' whole nos.
   '         Else
   '            If Int(x!) > .9999 Then
   '                  text$ = Format$(x!, "##.0")  ' 5.0 5.1
   '               Else
   '                  text$ = Format$(x!, "0.0#")  ' 0.0 0.01 0.1
   '               End If
   '         End If
   '      text$ = Right$("    " + text$, 4)        'pad with preceding spaces
   '   End If
   'tsf$ = text$

End Function

Function tsfvdu(Y!) As String
'">9999" now shown as ">10K"
'12Sep95 CKJ Added "NEG!" for negative numbers
'16Sep96 CKJ Removed Neg - now allows neg numbers. Added Abs()
' 3Jan96 CKJ Changed display of 1.0 to 9.5 ml to x.xx from x.x

Dim X!

   X! = Y!
   threesigfigs X!   'ASC 5Oct94

   Select Case Abs(X!)
      Case Is >= 9999.5: tsfvdu = ">10K"
      Case Is > 99.4:    tsfvdu = Format$(X!, "####")
     'Case Is > .9999:   tsfvdu = Format$(x!, "#0.0")    '3Jan96 CKJ removed
      Case Is > 9.999:   tsfvdu = Format$(X!, "#0.0")    '3Jan96 CKJ added
      Case 0:            tsfvdu = ""
     'Case Is < 0:       tsfvdu = "NEG!"
      Case Else:         tsfvdu = Format$(X!, "0.0#")
      End Select

End Function

Sub wsheetwarningsformat(tot1!, tot2!, tot!(), Text$)
'PRINT WARNINGS AT BOTTOM OF PAGE
'NB !!** tot1! & tot2! are not used
'!!** phosphate warning & glucose concn in 'A' warning not printed - why?

   If tot!(0) > 0 Then
         Text$ = ""
         If tot!(6) / (tot!(0) / 1000) > 60 Then Text$ = Text$ + "[KWarn]"
         If tot!(5) / (tot!(0) / 1000) > 80 Then Text$ = Text$ + "[NaWarn]"
         If tot!(7) / (tot!(0) / 1000) > 5 Then Text$ = Text$ + "[CaWarn]"
         If tot!(8) / (tot!(0) / 1000) > 3.8 Then Text$ = Text$ + "[MgWarn]"
         If tot!(9) > 200 Then Text$ = Text$ + "[ZnWarn]"
      End If

End Sub

Sub constitsformat(Text$, tot!(), combined%, perkilo%, weight!, ByRef xmlElement As MSXML2.IXMLDOMElement)
'-----------------------------------------------------------------------------
'                          Prints the total constituents
'
'23Nov91 CKJ Changed spacing of fat entry, changed onlyone% to combined%
' 1Mar95 CKJ Derived from constits & constitsperkg. Returns text.
'            Requires that tot!() is already suitably calculated
' 9Aug95 CKJ Added volume
' 1Oct96 CKJ Modified for Windows. Replaced Volume with Copper. No trailing [cr]
'12Jun97 CKJ changed Selenium from umol to nmol
'-----------------------------------------------------------------------------
Dim w!, kg$, Cals$, gram$, mmol$, umol$, nmol$, CalN$, noi%, t0$
Dim a0$, a1$, a2$, a3$, a4$, a5$, a6$, a7$, a8$, a9$, a10$, a11$, a12$, a13$, a14$, a15$

   If perkilo Then             ' paed
         w! = weight!
         kg$ = "kg"
      Else                     ' adult
         w! = 1!
         kg$ = ""
      End If

   Cals$ = "[Cals" & kg$ & "]"
   gram$ = "[gram" & kg$ & "]"
   mmol$ = "[mmol" & kg$ & "]"
   umol$ = "[umol" & kg$ & "]"
   nmol$ = "[nmol" & kg$ & "]"        '12Jun97 CKJ added nmol
   CalN$ = "[CalN" & kg$ & "]"

  ' FOR i = 1 TO igMax
  '    MSGBOX STR$(tot!(i)), 0, STR$(i)
  ' NEXT

   If noi >= 14 Then t0$ = "[8lpi]"           'CHR$(27); "0";
   
   'a1$ = "[Calories]" & tsf$(tot!(1) / w!) & Cals$
   a1$ = "[Calories]" & xmlElement.selectSingleNode("i1qt").Text & Cals$
   
   'a2$ = "[Nitrogen]" & tsf$(tot!(2) / w!) & gram$
   a2$ = "[Nitrogen]" & xmlElement.selectSingleNode("i2qt").Text & gram$
   
   'a3$ = "[Glucose]" & tsf$(tot!(3) / w!) & gram$ & "[cr]"
   a3$ = "[Glucose]" & xmlElement.selectSingleNode("i3qt").Text & gram$ & "[cr]"

   If combined Then
         'a4$ = "[Fat]" & tsf$(tot!(4) / w!) & gram$
         a4$ = "[Fat]" & xmlElement.selectSingleNode("i4qt").Text & gram$
      Else
         a4$ = "[FatinPB]"
      End If
   'a5$ = "[sodium]" & tsf$(tot!(5) / w!) & mmol$
   a5$ = "[sodium]" & xmlElement.selectSingleNode("i5qt").Text & mmol$
   'a6$ = "[Potassium]" & tsf$(tot!(6) / w!) & mmol$ & "[cr]"
   a6$ = "[Potassium]" & xmlElement.selectSingleNode("i6qt").Text & mmol$ & "[cr]"

   'a7$ = "[Calcium]" & tsf$(tot!(7) / w!) & mmol$
   a7$ = "[Calcium]" & xmlElement.selectSingleNode("i7qt").Text & mmol$
   'a8$ = "[Magnesium]" & tsf$(tot!(8) / w!) & mmol$
   a8$ = "[Magnesium]" & xmlElement.selectSingleNode("i8qt").Text & mmol$
   'a9$ = "[Zinc]" & tsf$(tot!(9) / w!) & umol$ & "[cr]"
   a9$ = "[Zinc]" & xmlElement.selectSingleNode("i9qt").Text & umol$ & "[cr]"

   'a10$ = "[Phosphate]" & tsf$(tot!(10) / w!) & mmol$
   a10$ = "[Phosphate]" & xmlElement.selectSingleNode("i10qt").Text & mmol$
   'a11$ = "[Chloride]" & tsf$(tot!(11) / w!) & mmol$
   a11$ = "[Chloride]" & xmlElement.selectSingleNode("i11qt").Text & mmol$
   'a12$ = "[Acetate]" & tsf$(tot!(12) / w!) & mmol$ & "[cr]"
   a12$ = "[Acetate]" & xmlElement.selectSingleNode("i12qt").Text & mmol$ & "[cr]"

   'a13$ = "[Selenium]" & tsf$(tot!(13) / w!) & nmol$       '12Jun97 CKJ changed umol to nmol
   a13$ = "[Selenium]" & xmlElement.selectSingleNode("i13qt").Text & nmol$       '12Jun97 CKJ changed umol to nmol
   'a14$ = "[Copper]" & tsf$(tot!(14) / w!) & umol$
   a14$ = "[Copper]" & xmlElement.selectSingleNode("i14qt").Text & umol$
   If tot!(2) > 0 Then
         'a15$ = "[kcalpergN]" & tsf$(Int(tot!(1) / (tot!(2) * w!))) & CalN$   '1Oct96 CKJ Added /w! & CalN$
         a15$ = "[kcalpergN]" & tsf$(Int(tot!(1) / (tot!(2) * w!))) & CalN$   '1Oct96 CKJ Added /w! & CalN$
      End If

   'a15$ = "[constitV]" & tsf$(tot!(0) / w!) & "[ml...][cr]"   '1Oct96 CKJ Removed

   Text$ = "[condOn]" & a0$ & a1$ & a2$ & a3$ & a4$ & a5$ & a6$ & a7$ & a8$ & a9$ & a10$ & a11$ & a12$ & a13$ & a14$ & a15$
   
End Sub

