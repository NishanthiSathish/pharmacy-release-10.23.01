Attribute VB_Name = "HIGHASC"
'-----------------------------------------------------------------------------
'                 HighAscPrintJob
'                -----------------
'
' High Edit support routines & constants
'
'17Sep10 CKJ written
'            Supports only the minimalist print job handler AscribePrintJob
'15Dec10 CKJ Tidied                           (RCN P0573 F0104170 10.5 branch)
'03May16 XN  123082 Added CitrixOverridePrinterPort
'15Jly19 AS  PBI -246985 : Task 249234, 249237 Highedit Removal
'-----------------------------------------------------------------------------
DefInt A-Z
Option Explicit

'---------------------------------------------
' Format for HEAppend-, HELoad- und HESaveDoc
'---------------------------------------------
'27Mar97 KR Removed  5Aug97 CKJ Reinstated
'Global Const FILEFORMAT_HIGHEDIT = 0
'Global Const FILEFORMAT_ANSI = 1
'Global Const FILEFORMAT_OEM = 2
Global Const FILEFORMAT_RTF = 3

'------------
' Units
'------------
Global Const UNIT_CM = 0
Global Const UNIT_IN = 1
'Start :  PBI -246985 : Task 249234, 249237
Global HighEdit As New TextControlEditorPharmacyClient.TxWrapper
Global He As New TextControlEditorPharmacyClient.HeEmulator
'End :  PBI -246985 : Task 249234, 249237

Function DeferredPrintingActive() As Integer
'27Nov01 CKJ Companion to DeferredPrinting procedure
'            Returns T/F depending on whether deferred printing is currently active
'            This is determined by the presence of "(DeferredPrinting)Total" in the print heap

   DeferredPrintingActive = False

End Function


Sub OverrideLayout(ByVal Settings As String)
'01Mar06 CKJ written
'            Override the orientation and/or margins on a per print context basis
'            Multiple print contexts can share the same settings, eg all small label contexts
'17Sep10 CKJ Modified to use the command line parameter of form "X|T|L|R|B" where
'            X    is the layout. L landscape  P portrait
'            T    is the Top margin in cm or P for physical margin
'            L    is the Left margin in cm or P for physical margin
'            R    is the Right margin in cm
'            B    is the Bottom margin in cm
'         [empty] is acceptable for any entry and results in no change

Dim PhysicalMarginTop As Integer
Dim PhysicalMarginLeft As Integer
Dim strValue As String
Dim result As Integer
Dim intloop As Integer
Dim posn As Integer
                        
   Settings = Trim$(Settings)       '|X|T|L|R|B' eg '|L|P|P|0.1|0.1'
   posn = 1
   
   Do
      posn = InStr(Settings, "|")
      If posn Then
         strValue = Mid$(Settings, posn + 1)
         replace strValue, "|", Nul, 0
         strValue = trimz(strValue)
         
         posn = InStr(2, Settings, "|")
         If posn Then
            Settings = Mid$(Settings, posn)
         End If
         
         Select Case intloop
            Case 0
               Select Case strValue
                  'Start :  PBI -246985 : Task 249234, 249237
                  'Case "P": result = HighEdit.He.SetOrientation(0)         'force Portrait
                  'Case "L": result = HighEdit.He.SetOrientation(1)         'force Landscape
                  Case "P": HighEdit.He.SetOrientation = 0        'force Portrait
                  Case "L": HighEdit.He.SetOrientation = 1      'force Landscape
                  'End :  PBI -246985 : Task 249234, 249237
                  End Select
            Case 1 To 4                'Margin "Top", "Left", "Right", "Bottom"
               Select Case strValue
                  Case ""
                     'no action
                  Case "P"             'physical
                     HighEdit.He.GetPhysicalMargins PhysicalMarginLeft, PhysicalMarginTop       'retrieve margins
                     Select Case intloop
                        Case 1: HighEdit.He.TopMargin = PhysicalMarginTop / 1000
                        Case 2: HighEdit.He.LeftMargin = PhysicalMarginLeft / 1000
                        Case Else      'no action
                        End Select
                  Case Else
                     If IsNumber(strValue, False) Then
                        Select Case intloop
                           Case 1: HighEdit.He.TopMargin = Val(strValue)
                           Case 2: HighEdit.He.LeftMargin = Val(strValue)
                           Case 3: HighEdit.He.RightMargin = Val(strValue)
                           Case 4: HighEdit.He.BottomMargin = Val(strValue)
                           End Select
                     Else
                        'no action
                     End If
                  End Select
            
            Case Else
               posn = 0
            End Select
      End If
      intloop = intloop + 1
   Loop While posn
   
End Sub

Public Function CitrixOverridePrinterPort(ByVal PrinterDriverPort As String) As String
'25Mar10 CKJ Citrix may allocate a different port to the same terminal's printer on subsequent Citrix sessions
'            If a printer is specified, check whether the port requested exists.
'            If not, check if the same Printer & Driver exist on a different port. (Checks are not case sensitive)
'            If so, then replace original Port with the one associated with the printer in this session,
'            otherwise return empty string, and allow calling routine to ask user or use default as desired.
'            Eg original printer Port may have been "Ne01:" but Citrix has now allocated "Ne02:" or "Ne74:" etc
'            Facility is optional, and should only be enabled for terminals which are actually Citrix virtual machines.
'            This can be done for individual terminals, or set as the departmental default (and overridden on an individual basis)
'            To enable set CitrixOverridePrinterPort="Y" in terminal section of wConfiguration, settings are Y/N/1/0/-1, default "N"
'            Logging is available but should not be turned on for the whole department, nor left on permanently.
'            To enable set CitrixOverridePrinterPortLog="Y" in terminal section of wConfiguration, settings are Y/N/1/0/-1, default "N"
'            Log is written to SQL table WPharmacyLog with 'CitrixOverridePrinterPort' as the designation          (RCN P0007 F0081840)
'03May16 XN  Moved from main pharmacy code 123082

Dim sTemp As String
Dim sPrinterDriverPort As String
Dim Prn As Printer
Dim valid As Boolean
Dim sLogfile As String

   sPrinterDriverPort = PrinterDriverPort
   If PrinterDriverPort <> "" Then
        valid = False
        For Each Prn In Printers         'is printer currently in the live list?
           If UCase$(sPrinterDriverPort) = UCase$(Prn.DeviceName & "," & Prn.DriverName & "," & Prn.Port) Then
              valid = True
              Exit For
           End If
        Next
        
        If Not valid Then                'is same printer + driver in the live list?
           For Each Prn In Printers
              If InStr(1, sPrinterDriverPort, Prn.DeviceName & "," & Prn.DriverName & ",", vbTextCompare) = 1 Then
                 valid = True
                 Exit For
              End If
           Next
                       
           If valid Then                 'found "printer,driver,*****"
              sPrinterDriverPort = Prn.DeviceName & "," & Prn.DriverName & "," & Prn.Port      'same printer & driver with new port
           Else                          'not found, return empty string
              sPrinterDriverPort = ""
           End If
        End If
   End If
   
   CitrixOverridePrinterPort = sPrinterDriverPort
   
End Function

