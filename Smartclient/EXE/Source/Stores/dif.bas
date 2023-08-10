Option Explicit
DefInt A-Z

Const modulename$ = "DIF.BAS"

Sub GetDIFValue (filehd%, DIFLine$, value$, dataitem%)
'----------------------------------------------------------
'
' Created : 20 November 1996
' Author  : EAC
'
' Notes
'   This procedure returns the value of the current record.
'
'   The types of values it knows may need to be extended
'   in future.
'
'----------------------------------------------------------

Const procname$ = "GetDIFValue"
Dim temp$, nextline$
Dim commaposn%

    commaposn = InStr(DIFLine$, ",")
    If commaposn > 0 Then
            temp$ = Mid$(DIFLine$, 1, commaposn - 1)
        Else
            temp$ = ""
        End If

    Select Case temp$
        Case "", "-1"
            value$ = ""
            dataitem = False
            Line Input #filehd, nextline$
        Case "0"
            value$ = Trim$(Mid$(DIFLine$, commaposn + 1))
            dataitem = True
            Line Input #filehd, nextline$   'ignore next line
        Case "1"
            Line Input #filehd, nextline$
            value$ = Mid$(nextline$, 2, Len(nextline$) - 2) 'strip the commas
            dataitem = True
        Case Else
            popmessagecr "ERROR", "Procedure : " & procname$ & Chr$(13) & "Module   : " & modulename$ & Chr$(13) & "Unknown DIF variable type : " & temp$
            value$ = ""
            dataitem = False
    End Select

    'return next line
    DIFLine$ = Trim$(nextline$)

End Sub

Sub GetNextDifRecord (filehd%, dataitems$(), endoffile%)

Dim dataline$, item$
Dim loopvar%, valid%

    loopvar = 1
    endoffile = False

    Do

        Line Input #filehd, dataline$

        GetDIFValue filehd, dataline$, item$, valid

        If valid Then
                 If loopvar <= UBound(dataitems$) Then dataitems$(loopvar) = item$
                 loopvar = loopvar + 1
            End If


    Loop Until Trim$(Mid$(dataline$, 1, 3)) = "BOT" Or Trim$(Mid$(dataline$, 1, 3)) = "EOD"

    If Trim$(Mid$(dataline$, 1, 3)) = "EOD" Then endoffile = True
    If loopvar - 1 <> UBound(dataitems$) And Not endoffile Then popmessagecr "Error", "Procedure : GetNextDifRecord" & Chr$(13) & "Module   : " & modulename$ & Chr$(13) & "Expected " & Trim$(Str$(UBound(dataitems$))) & " items : read " & Trim$(Str$(loopvar - 1)) & " items."

End Sub

Sub ReadDifInfo (filehd%, totalfields%, totalrecords&, tablename$, SwapRowsandColumns)

'03Dec97 EAC Add code to swap rows and columns to cope with Excel and correct DIF


Dim dataline$, item$
Dim valid%


    'initialise variables
    totalfields% = 0
    totalrecords& = 0
    tablename$ = ""

    Seek #filehd%, 1

    Do

        Line Input #filehd, dataline$

        If UCase$(Mid$(dataline$, 1, 5)) = "TABLE" Then
                Line Input #filehd, dataline$
                GetDIFValue filehd%, dataline$, item$, valid
                tablename$ = item$
            End If

        If UCase$(Mid$(dataline$, 1, 7)) = "VECTORS" Then
                Line Input #filehd, dataline$
                GetDIFValue filehd%, dataline$, item$, valid
                '03Dec97 EAC
                'totalfields% = Val(item$)
                If SwapRowsandColumns Then
                        totalrecords& = Val(item$)
                    Else
                        totalfields% = Val(item$)
                    End If
                '---
            End If
        
        If UCase$(Mid$(dataline$, 1, 6)) = "TUPLES" Then
                Line Input #filehd, dataline$
                GetDIFValue filehd%, dataline$, item$, valid
                '03Dec97 EAC
                'totalrecords& = Val(item$)
                If SwapRowsandColumns Then
                        totalfields% = Val(item$)
                    Else
                        totalrecords& = Val(item$)
                    End If
                '---
            End If


    Loop Until UCase$(Mid$(dataline$, 1, 3)) = "BOT"



End Sub

Sub WriteDIFInfo (filehd%, tablename$, totalrecords&, totalfields%)


    Print #filehd, "TABLE"
    Print #filehd, "0,1"
    Print #filehd, Chr$(34); tablename$; Chr$(34)
    
    Print #filehd, "VECTORS"
    Print #filehd, "0,"; Trim$(Str$(totalrecords&))
    Print #filehd, Chr$(34); Chr$(34)
    
    Print #filehd, "TUPLES"
    Print #filehd, "0,"; Trim$(Str$(totalfields%))
    Print #filehd, Chr$(34); Chr$(34)

    Print #filehd, "DATA"
    Print #filehd, "0,0"
    Print #filehd, Chr$(34); Chr$(34)

    Print #filehd, "-1,0"
    Print #filehd, "BOT"

End Sub

Sub WriteDIFRecord (filehd%, dataitems$())

Dim loopvar


    For loopvar = 1 To UBound(dataitems$)
        Select Case loopvar
            Case 1, 7, 8
                Print #filehd, "1,0"
                Print #filehd, Chr$(34); Trim$(dataitems$(loopvar)); Chr$(34)
            Case 2, 3
                Print #filehd, "1,0"
                Print #filehd, Chr$(34); Chr$(34)
            Case 4, 5, 6
                Print #filehd, "0,"; Trim$(dataitems$(loopvar))
                Print #filehd, "V"
            Case Else
        End Select
    Next

    Print #filehd, "-1,0"
    Print #filehd, "BOT"

End Sub

