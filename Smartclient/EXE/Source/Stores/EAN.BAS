Attribute VB_Name = "Module17"
'DOStoWIN V1.0 (c) ASCribe 1996
'-----------------------------------------------------------------------------

'     EAN barcode library
'     This code may also be used with other code types, see individual
'     procedures for info on usage.


'Mod History:
'------------
'12Sep89 Adaptation to allow 'mode' to be varied during bit-image printing
'        ie variable width printing, given same data.
'13Jun94 CKJ EanPrint/2ndPass use Prn instead of opening LPT1: directly
'28Mar96 CKJ Modified to return string of data rather than print
'-----------------------------------------------------------------------------
DefInt A-Z
Option Explicit


'END

'-----------------------------------------------------------------------------

'     test program for EAN barcodes

'-----------------------------------------------------------------------------
'esc$ = CHR$(27)

'CLS
'PRINT "EAN Barcode Printing Testbed"
'PRINT "   V1.2   14 Mar 89   CKJ"
'PRINT

'DO
'   INPUT "Enter 12 digits :  ", dig$
'   t$ = dig$ + eanaddchkdigit$(dig$)
'   eandigitstobars t$, out$
'   PRINT t$
'   PRINT out$
'   PRINT
'
'   LPRINT esc$; "@"; esc$; "M";
'   LPRINT t$
'
'   eanprint out$, 0, 0, true
'   LPRINT esc$; "3"; CHR$(1)
'   eanprint2ndpass out$, 0, 0, true
'   LPRINT esc$; "3"; CHR$(23)
'
'   eanprint out$, 0, 0, true
'   LPRINT esc$; "3"; CHR$(1)
'   eanprint2ndpass out$, 0, 0, true
'   LPRINT esc$; "3"; CHR$(23)
'
'   eanprint out$, 0, 0, true
'   LPRINT esc$; "3"; CHR$(1)
'   eanprint2ndpass out$, 0, 0, true
'
'   LPRINT esc$; "@"; CHR$(15)
'   LPRINT out$
'   LPRINT esc$; "@"
'   LPRINT
'LOOP
'
'END
'
'
'
'  Hand-coded test bars
' ----------------------
'
'bar$ = "1111231321122211231111113112113211141213111"
'       '...5---0---1---5---.....9---4---6---8---...  tot 67 pixels wide
'
'bar$ = "11132111123112321223211122211111113211141213111422212221111"
'    (5) ...0---0---0---2---0---1---.....4---6---8---6---1---1---...  95 pixels

Function eanaddchkdigit$(ip As String)
'-----------------------------------------------------------------------------

'  take 12 digits as string & find the check digit

'-----------------------------------------------------------------------------

Dim i%, chk%

ReDim EAN(1 To 12)

eanaddchkdigit$ = ""
If Len(ip) = 12 Then
      For i = 1 To 12
         EAN(i) = Val(Mid$(ip, i, 1))
      Next i

      chk = 0
      For i = 2 To 12 Step 2
         chk = chk + EAN(i)
      Next i
      chk = chk * 3
      chk = chk Mod 10
      For i = 1 To 11 Step 2
         chk = chk + EAN(i)
      Next i
      chk = chk Mod 10
      chk = (10 - chk) Mod 10
      If chk < 0 Then chk = chk + 10
      eanaddchkdigit$ = Right$(Str$(chk), 1)
   Else
      Beep   ' not 12 digits
   End If
End Function

Sub eandigitstobars(ip As String, op As String)
'-----------------------------------------------------------------------------

'     convert the 13 digits to 48 bars

'-----------------------------------------------------------------------------

ReDim bar$(0 To 1)
Dim ab$, derive$
Dim deriv%, count%

    '          0---1---2---3---4---5---6---7---8---9---
    bar$(0) = "3211222121221411113212311114131212133112" '  type A & C bars
    bar$(1) = "1123122222121141231113214111213131212113" '  type B bars
    
    '          ab$ ;  0 for type A, 1 for type B
    ab$ = "000000001011001101001110010011011001011100010101010110011010"
    '      0-----1-----2-----3-----4-----5-----6-----7-----8-----9-----
    'ab$ = "000111001011001101001110010011011001011100010101010110011010"
    
    '000000        0
    '001011        1
    '001101        2
    '001110        3
    '010011        4
    '011001        5
    '011100        6
    '010101        7
    '010110        8
    '011010        9
    
    op = "111"                                            ' left guard bars
    
    If Len(ip) <> 13 Then Beep: Exit Sub                  ' not 13 digits
    deriv = Val(Left$(ip$, 1))                            ' the derived digit
    derive$ = Mid$(ab$, deriv * 6 + 1, 6) + "000000"       ' right side all type C
    
    For count = 1 To 6                                    ' left side types A/B
       op = op + Mid$(bar$(Val(Mid$(derive$, count, 1))), Val(Mid$(ip, count + 1, 1)) * 4 + 1, 4)
    Next count
    
    op = op + "11111"                                     ' centre guard bars
    
    For count = 7 To 12                                   ' right side
       op = op + Mid$(bar$(Val(Mid$(derive$, count, 1))), Val(Mid$(ip, count + 1, 1)) * 4 + 1, 4)
    Next count
    
    op = op + "111"                                       ' right guard bars

End Sub

Sub eanprint(op As String, density, devno, Mode)
'-----------------------------------------------------------------------------
'13Jun94 CKJ uses Prn
'28Mar96 CKJ Uses ParseEANpass2
'-----------------------------------------------------------------------------

Dim char$
Dim escd%

   char$ = ""
   parseEANpass1 char$, op, density, devno, Mode

   If devno Then                   '13Jun94 CKJ uses Prn
         Print #devno, char$;
      Else
         '''prn 1, char$, False, escd
      End If

End Sub

Sub eanprint2ndpass(op As String, density, devno, Mode)
'-----------------------------------------------------------------------------
'13Jun94 CKJ uses Prn
'28Mar96 CKJ Uses ParseEANpass2
'-----------------------------------------------------------------------------

Dim char$
Dim escd%

   char$ = ""
   parseEANpass2 char$, op, density, devno, Mode

   If devno Then                                 ' 13Jun94 CKJ uses Prn
         Print #devno, char$;
      Else
         ''''prn 1, char$, False, escd
      End If

End Sub

Sub parseEANpass1(char$, op As String, density, devno, Mode)
'-----------------------------------------------------------------------------
'
'   input of string of digits, output of one row of bars to the printer
'   set density=1 or 2 for normal printing,
'   set density=3 for double density printing, eg worn ribbon
'   DEVNO is used if >0 & < 256. If =0 then lpt1: is opened & used
'
'   NB routine expects the first 'bar' to be solid, not space,
'   If space is required then prefix the string with 0
'      eg  '5252' ==> '*****  *****  '
'         '05252' ==> '     **     **'
'   If bar widths of more than 9 are needed, do the same, eg '906' for 15 etc.
'
'   NB The mode parameter takes values of 0 to 6 inclusive. If -1 is specified
'   then the mode varies according to the hidensity flag.
'   Warning!! Check printer manual before selecting high density & a manually
'   chosen mode value - some cannot be printed fast enough & are disallowed.
'   Note that the chosen mode is returned to the calling routine.
'
'13Jun94 CKJ uses Prn
'-----------------------------------------------------------------------------

Dim hidensity%, count%, tot%, hi%, lo%, bar%, barwidth%, bars%
Dim esc$

   If Len(op) = 0 Then Beep: Exit Sub  ' nothing to print

   If density > 2 Then hidensity = 1 Else hidensity = 0
   esc$ = Chr$(27)

   tot = 0
   For count = 1 To Len(op)
     tot = tot + Val(Mid$(op, count, 1))  ' count bar widths, ignore 0
   Next

   If Mode < 0 Or Mode > 6 Then
         Mode = 2 + (hidensity = 1)         ' fast print if density = 0/1
      End If

   hi = (tot * 2) \ 256
   lo = (tot * 2) Mod 256

   char$ = char$ + esc$ + "*" + Chr$(Mode) + Chr$(lo) + Chr$(hi)

   bar = 255                                ' commence with solid bar
   For count = 1 To Len(op)
      barwidth = Val(Mid$(op, count, 1))    ' extract width
      If barwidth > 1 Then                  ' 'body' of bar as '****'
            For bars = 1 To barwidth - 1    '               or '* * '
               char$ = char$ + Chr$(bar) + Chr$(bar * hidensity)
            Next
         End If
      If barwidth > 0 Then      ' finish each bar with '* '      '12Sep89 CKJ separate IF statement added to allow width of 0
            char$ = char$ + Chr$(bar) + Chr$(0)
         End If
      bar = 255 - bar                       ' swap between solid bar & space
   Next

End Sub

Sub parseEANpass2(char$, op As String, density, devno, Mode)
'-----------------------------------------------------------------------------
'
'       To be called after EANPRINT, to darken the wide bars
'       ----------------------------------------------------
'
'     __--__--__--__
'       o o o   o       density=1
'        * *            o = first pass
'       o o o   o       * = second pass
'        * *
'
'       o o o   o       density=2
'        * *    *       o = first pass
'       o o o   o       * = second pass
'        * *    *
'
'       ooooo   o       density=3
'       *****   *       o = first pass
'       ooooo   o       * = second pass
'       *****   *
'
'
' !!WARNING!! before using this routine, read the comments associated with
'   Eanprint, relating to the use of mode & hidensity.
'
'13Jun94 CKJ uses Prn
'-----------------------------------------------------------------------------

Dim fillmode%, hidensity%, tot%, count%, hi%, lo%, bar%, barwidth%, bars%
Dim esc$

   If Len(op) = 0 Then Beep: Exit Sub            ' nothing to print

   Select Case density
      Case Is <= 1
         fillmode = 0
         hidensity = 0
      Case 2
         fillmode = 1
         hidensity = 0
      Case Else    ' i.e. = 3 or more
         hidensity = 1
         fillmode = 1
      End Select

   esc$ = Chr$(27)
   tot = 0
   For count = 1 To Len(op)
     tot = tot + Val(Mid$(op, count, 1))
   Next

   If Mode < 0 Or Mode > 6 Then
         Mode = 2 + (hidensity = 1)              ' fast print if density = 0/1
      End If

   hi = (tot * 2) \ 256
   lo = (tot * 2) Mod 256
   char$ = char$ + esc$ + "*" + Chr$(Mode) + Chr$(lo) + Chr$(hi)

   bar = 255
   For count = 1 To Len(op)
      barwidth = Val(Mid$(op, count, 1))
      If barwidth > 1 Then                       ' fill in the gaps
            For bars = 1 To barwidth - 1
               char$ = char$ + Chr$(bar * hidensity) + Chr$(bar)
            Next
            char$ = char$ + Chr$(bar * hidensity) + Chr$(0)
         End If
      If barwidth = 1 Then                       ' mod to allow 0 width bars
            char$ = char$ + Chr$(bar * fillmode) + Chr$(0)
         End If
      bar = 255 - bar
   Next count
   
End Sub

