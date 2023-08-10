Attribute VB_Name = "OrderLibDISP"
'---------------------------------------------------------------------------
'          OrderLibDISP - Ordering Library routines for Dispensing
'---------------------------------------------------------------------------
'17oct08 CKJ Severely pruned version of orderlib for use in Dispensing.
'            Last orderlib mod incorporated here is;
'            '13oct08 CKJ Merged from V8.8: 01Aug08 TH/CKJ Updateprice: (F0023465) Extra fencepost to protect from "double receipt"
'            Any crucial orderlib changes after this date must be manually merged if deemed necessary.
'23Jun08 XN  F0033906 Added DisplayDrugEnquiry and ParseCommandURLServerAndWebFolder
'            method to use the ICW F4 desktop to display drug information
'17Oct14 XN  DisplayDrugEnquiry: 88560 Prevented user from searching for drug via BNF (findrdrug)
'06Oct15 XN  CallWebMethod add method 77780
'02Aug16 XN  ParseCommandURLServerAndWebFolder : Made public so can get site url form other parts of the system 159413

'To Do:
'  setting defBool showed missing type declaration in Sub getnumofords(edittype, pointer&, incr%)

Option Explicit
DefBool A-Z

Global ODrugInfo$

Dim ord As orderstruct
Dim dt As DateAndTime, td As DateAndTime
Dim ordedittype As Integer
Dim ReadSitesDoneOnce As Boolean
'

Sub blankorder(ord As orderstruct)

   r.record = ""
   LSet ord = r
   ord.pickno = 0 '20Mar93 CKJ Added
   ord.DLO = False   '07Aug12 TH Added

End Sub


Sub convdat(dat$)
'ddmmyy   => dd-mm-yy
'ddmmyyyy => dd-mm-yyyy

   dat$ = Left$(dat$, 2) & "-" & Mid$(dat$, 3, 2) & "-" & Mid$(dat$, 5)

End Sub

'XN 4Jun15 98073 Removed as new use new local stores description
'Function GetStoresDescription$()

   'If trimz$(d.storesdescription) = "" Then
      'GetStoresDescription$ = d.Description
   'Else
      'GetStoresDescription$ = d.storesdescription
   'End If

'End Function


Sub poporder(o As orderstruct, msg$)

Dim Info$
   
   Info$ = " Edit type          " & TB & Str$(ordedittype) & Space$(20) & cr & cr
   Info$ = Info$ & " NSVcode" & TB & o.Code & cr
   Info$ = Info$ & " ordered" & TB & o.qtyordered & cr
   Info$ = Info$ & " received" & TB & o.received & cr
   Info$ = Info$ & " outstanding" & TB & o.outstanding & cr
   Info$ = Info$ & " ord date" & TB & o.orddate & cr
   Info$ = Info$ & " rec date" & TB & o.recdate & cr
   Info$ = Info$ & " urgency" & TB & o.urgency & cr
   Info$ = Info$ & " location" & TB & o.loccode & cr
   Info$ = Info$ & " sup code" & TB & o.supcode & cr
   Info$ = Info$ & " status" & TB & o.status & cr
   Info$ = Info$ & " order number" & TB & o.num & cr
   Info$ = Info$ & " cost" & TB & o.cost & cr
   Info$ = Info$ & " picking ticket" & TB & Str$(o.pickno) & cr
   Info$ = Info$ & " to follow flag" & TB & o.tofollow & cr
   Info$ = Info$ & " invoice num etc" & TB & o.invnum & cr
   Info$ = Info$ & " pay date" & TB & o.paydate & cr
   Info$ = Info$ & " internal siteno" & TB & o.internalsiteno & cr
   Info$ = Info$ & " internal method" & TB & o.internalmethod & cr
   k.helpnum = 0
   popmsg msg$, Info$, 1, "", k.escd
   
End Sub


Sub ReadOrdData()

Const strFile = "\WorkingDefaults.ini"

'   preprint$ = TxtD(dispdata$ & strFile, "", "", "preprint", 0)
'   ordnumprefix$ = TxtD(dispdata$ & strFile, "", "", "ordnumprefix", 0)
'   ownname$ = TxtD(dispdata$ & strFile, "", "", "ownname", 0)
'   overdue$ = TxtD(dispdata$ & strFile, "", "", "overdue", 0)
'   ordmessage$ = TxtD(dispdata$ & strFile, "", "", "ordmessage", 0)
'   ordcontact$ = TxtD(dispdata$ & strFile, "", "", "ordcontact", 0)
'   maxnumoflines = Val(TxtD(dispdata$ & strFile, "", "", "maxnumoflines", 0))
'   tp$ = TxtD(dispdata$ & strFile, "", "", "tp", 0)
'   picknumoflines = Val(TxtD(dispdata$ & strFile, "", "", "picknumoflines", 0))
'   delreceipt = Val(TxtD(dispdata$ & strFile, "", "", "delreceipt", 0))
'   delreconcile = Val(TxtD(dispdata$ & strFile, "", "", "delreconcile", 0))
'   FullPageCS = Val(TxtD(dispdata$ & strFile, "", "", "FullPageCS", 0))
'   NSVcarriage$ = TxtD(dispdata$ & strFile, "", "", "NSVcarriage", 0)
'   NSVdiscount$ = TxtD(dispdata$ & strFile, "", "", "NSVdiscount", 0)
'   AskBatchNum = Val(TxtD(dispdata$ & strFile, "", "", "AskBatchNum", 0))
'   Delrequis = Val(TxtD(dispdata$ & strFile, "", "", "Delrequis", 0))
'   OrdPrintPrice = Val(TxtD(dispdata$ & strFile, "", "", "OrdPrintPrice", 0))
'   OrdPrintLin = Val(TxtD(dispdata$ & strFile, "", "", "OrdPrintLin", 0))
'   ProgressBarScale = Val(TxtD(dispdata$ & strFile, "", "", "ProgressBarScale", 0))
'   PrintStockCost = Val(TxtD(dispdata$ & strFile, "", "", "PrintStockCost", 0))
'   PrintToScreen$ = TxtD(dispdata$ & strFile, "", "", "PrintToScreen", 0)
'   PrintCanceledOrder$ = TxtD(dispdata$ & strFile, "", "", "PrintCanceledOrder", 0)
   PrintInPacks = Val(TxtD(dispdata$ & strFile, "", "", "PrintInPacks", 0))
'   AdjCostCentre$ = TxtD(dispdata$ & strFile, "", "", "AdjCostCentre", 0)
'   WSStores% = Val(TxtD(dispdata$ & strFile, "", "", "WSStores", 0))
'   NSVReconciliation$ = TxtD(dispdata$ & strFile, "", "", "NSVReconciliation", 0)
'   EOPMargin% = Val(TxtD(dispdata$ & strFile, "", "", "EOPMargin", 0))

End Sub

Sub ReadSites()

'Static ReadSitesdoneonce

Dim sites$
Dim comma%, NumItems%, count%

   If ReadSitesDoneOnce = False Then
      ReadSitesDoneOnce = True
      sites$ = siteinfo$("SiteNumbers", "")
      If sites$ <> "" Then
         comma = InStr(sites$, ",")
         NumItems = 1                                'at least one other site
         Do While comma
            NumItems = NumItems + 1
            comma = InStr(comma + 1, sites$, ",")
         Loop
   
         ReDim sitenos%(NumItems), siteabb$(NumItems), sitepth$(NumItems)
        
         deflines sites$, sitepth$(), ",(*)", 1, NumItems
         
         For count = 1 To NumItems
            sitenos%(count) = Val(sitepth$(count))
         Next
         sites$ = siteinfo$("dispdataDRVs", "")
         deflines sites$, sitepth$(), ",(*)", 1, NumItems
         sites$ = siteinfo$("hospabs", "")
         deflines sites$, siteabb$(), ",(*)", 1, NumItems
         For count = 1 To NumItems  ' example  G:\DISPDATA.003
             sitepth$(count) = sitepth$(count) + "\dispdata." + Right$("000" + Trim$(Str$(sitenos%(count))), 3)
         Next
      Else
          ReDim sitenos%(0), siteabb$(0), sitepth$(0)
      End If
      
      sitenos%(0) = SiteNumber
      siteabb$(0) = hospabbr$
      sitepth$(0) = dispdata$
   End If

End Sub


Function rightjust6$(Value$)

   rightjust6$ = Right$(Space$(6) + Left$(Trim$(Value$), 6), 6)

End Function


Sub SetDispdata(site%)
' 6Jan95 CKJ Written. If site is in SITEINFO.INI then add drive letter
'            else assume same server
'            Site = 0  set dispdata to own sitenumber
'            Site = -1 returns number of sites (0-n)
'            Site > 0  set dispdata to specified site
'sitenos() sitepth() and dispdata$ are Named Common Shared

Dim count%
Dim strParams As String

   ReadSites
   Select Case site
      Case -1     ' how many sites?
         site = UBound(sitenos)
      Case 0      ' set to own site
         dispdata$ = sitepth$(0)
         'reset gDispSite
         strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, SiteNumber)
         gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
         
      Case Else   ' set to specified site
         For count = 0 To UBound(sitenos)
            If sitenos%(count) = site% Then
                  dispdata$ = sitepth$(count)
                  strParams = gTransport.CreateInputParameterXML("Sitenumber", trnDataTypeint, 4, site%)
                  gDispSite = gTransport.ExecuteSelectReturnSP(g_SessionID, "pLocationID_SitebySiteNumber", strParams)
                  Exit For
               End If
         Next
         If count > UBound(sitenos) Then
            popmessagecr "WARNING", "Site " + Str$(site) + " missing from SITEINFO"
            'Close!!**        '17oct08 CKJ not correct when in OCX
            'End!!**          '   "
            SetDispdata 0     '   "
         End If
   End Select

End Sub

' Will display the finddrug and then the F4 screen from the full or partial
' drugSearchName$ description used by finddrug.
' Depending on configuration settings (UseOldF4Screens), and if application was called from
' an icw page the method will either display the original vb6, or the new icw desktop, F4 screens
' 23Jun09 XN F0033906
' 17Oct14 XN 88560 Prevented user from searching for drug via BNF (findrdrug)
Sub DisplayDrugEnquiry(ByVal drugSearchName$, ByVal isiteNumber As Integer)
   Dim useOldF4Screens As Boolean         ' If using original vb6 F4 screens or new icw web f4 desktop
   Dim DrugPtr&
   Dim found%                             ' If drug found
   Dim httpAddress As String              ' web url to icw web f4 desktop
   Dim httParamaters As String            ' parameters for icw web f4 desktop
   Dim httpServerAndWebFolder As String   ' web server used to call this application
   Dim strHideCost As String              ' if cost are to be hidden or displayed on the F4 screens
   
   ' Determine if we are displaying original F4 screens, or the new web ones
   useOldF4Screens = TrueFalse(TxtD$(dispdata$ & "\siteinfo.ini", "", "0", "UseOldF4Screens", False))
   
   ' Get web server and directory used to call this application
   httpServerAndWebFolder = ParseCommandURLServerAndWebFolder(g_URLToken)
   
   ' if server or directory not present then can only use old F4 screens
   If (httpServerAndWebFolder = Empty) Then
      useOldF4Screens = True
   End If
   
   ' Now display the find drug, and F4 screens
   If useOldF4Screens Then
      ' Display the original vb6 F4 screens
      ODrugInfo$ = drugSearchName$
      Load DrugInfo
      If Not k.escd Then
         DrugInfo.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
      Else
         Unload DrugInfo
      End If
   Else
      ' display the find drug form
      'findrdrug drugSearchName$, 1, d, DrugPtr&, found, 2, False, False   17Oct14 XN 88560 Prevented user from searching for drug via BNF (findrdrug)
      findrdrug drugSearchName$, 1, d, DrugPtr&, found, 2, False, False, False
      
      If found Then
         ' Determine if costs are to be hidden
         If (TrueFalse(TxtD(dispdata$ & "\patmed.ini", "", "", "SuppressCost", 0))) And (GetFindDrugLowPassLevel()) Then
            strHideCost = "Yes"
         Else
            strHideCost = "No"
         End If
                  
         ' Generate the address for the icw F4 screens desktop
         httpAddress = httpServerAndWebFolder + "/application/StoresDrugInfoView/ICW_StoresDrugInfoView.aspx"
         httParamaters = "SessionID=" & Format$(g_SessionID) & _
                         "&AscribeSiteNumber=" & Format$(isiteNumber) & _
                         "&NSVCode=" & d.SisCode & _
                         "&HideCost=" & strHideCost
                      
         ' Display the icw F4 screens desktop
         Dim webForm As New frmWebClient
         webForm.Navigate httpAddress + "?" + httParamaters
         webForm.Caption = "Stores info"
         Load webForm
         webForm.Show 1, OwnerForm      'AS : MS_Edge_Fix for modal windows without an owner form
         Unload webForm
      ElseIf Not k.escd Then
         ' Drug could not be found so display error message
         popmessagecr "!Item Enquiry", drugSearchName$ & " Not Found"
         k.escd = True
      End If
   End If
End Sub

' Extracts the web server, and root folder of the web site from the a URL
' So http://localhost/ICW/application/somefolder/somepage.aspx would
' return http://localhost/ICW
' If the url can't be passed correctly the method will return an empty string
' 23Jun09 XN F0033906
' 02Aug16 XN Made public so can get site url form other parts of the system 159413
' 08Aug16 XN 159843 Moved to CoreLib.bas
'Function ParseCommandURLServerAndWebFolder(ByVal strURL As String) As String
'   Dim strTemp As String    ' Temp string
'   Dim posn As String       ' Position in the string
'
'   posn = InStr(1, strURL, "//", vbTextCompare)                                 ' http://localhost/ICW/application/somefolder/somepage.aspx then posn=6
'
'   If posn > 1 Then posn = InStr(posn + 2, strURL, "/", vbTextCompare)          ' http://localhost/ICW/application/somefolder/somepage.aspx then posn=17
'
'   If posn > 1 Then posn = InStr(posn + 1, strURL, "/", vbTextCompare)          ' http://localhost/ICW/application/somefolder/somepage.aspx then posn=21
'
'   If posn > 1 Then ParseCommandURLServerAndWebFolder = Left$(strURL, posn - 1) ' http://localhost/ICW
'
'End Function

'Calls a web service method on the pharmacy web site
'urlPostFix - the web service name starting as the application folder (e.g. application/pharmacysharedscripts/PharmacyStatusNotesProcessor.asmx)
'methodName - the web service method to call SetStatusNoteState
'xmlParameters - parameters to pass to the method in xml formar (e.g. <sessionID>5424</sessionID><noteTypeID>11245</noteTypeID><requestTypeID>2154</requestTypeID>...)
'returns the data from the web service call
'XN 6Oct15 77780 created
' 08Aug16 XN 159843 Moved to CoreLib.bas
'Function CallWebMethod(ByVal urlPostFix As String, ByVal methodName As String, ByVal xmlParameters As String) As String
'    Dim HttpRequest As WinHttpRequest
'    Dim strRet As String
'    Dim intPos1 As Integer
'    Dim intPos2 As Integer
'    Dim XmlBody As String
'    Dim url As String
'
'    On Error GoTo CallWebMethod_Err
'
'    ' Build up the url to call
'    ' http://asc-xnorman/ICW_HongKong_Pharmacy/application/pharmacysharedscripts/PharmacyStatusNotesProcessor.asmx?op=SetStatusNoteState
'    url = ParseCommandURLServerAndWebFolder(g_URLToken) + "/" + urlPostFix + "?op=" + methodName
'
'    ' Create the XML body used to call the web service method
'    XmlBody = "<?xml version=""1.0"" encoding=""utf-8""?>" + _
'              "<soap:Envelope xmlns:xsi=""http://www.w3.org/2001/XMLSchema-instance"" xmlns:xsd=""http://www.w3.org/2001/XMLSchema"" xmlns:soap=""http://schemas.xmlsoap.org/soap/envelope/"">" + _
'                "<soap:Body>" + _
'                    "<" + methodName + " xmlns=""http://tempuri.org/"">" + _
'                        xmlParameters + _
'                    "</" + methodName + ">" + _
'                "</soap:Body>" + _
'              "</soap:Envelope>"
'
'
'    ' Open the webservice
'    Set HttpRequest = New WinHttpRequest
'    HttpRequest.setTimeouts 0, 60000, 30000, 120000
'    HttpRequest.open "POST", url, False
'
'    ' Create headings
'    HttpRequest.setRequestHeader "Content-Length", Format(Len(XmlBody))
'    HttpRequest.setRequestHeader "Content-Type", "text/xml; charset=utf-8"
'    HttpRequest.setRequestHeader "SOAPAction", "http://tempuri.org/" + methodName
'
'    ' Send XML command
'    HttpRequest.send XmlBody
'
'    ' Get all response text from webservice
'    strRet = HttpRequest.responseText
'
'    ' Close object
'    Set HttpRequest = Nothing
'
'    ' Extract result that is in the form
'    '   <?xml version="1.0" encoding="utf-8"?>
'    '   <soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
'    '       <soap:Body>
'    '           <SetStatusNoteStateResponse xmlns="http://tempuri.org/">
'    '               <SetStatusNoteStateResult>Text that will be returned</SetStatusNoteStateResult>
'    '           </SetStatusNoteStateResponse>
'    '       </soap:Body>
'    '   </soap:Envelope>
'    intPos1 = InStr(strRet, "<" + methodName + "Result>")
'    intPos2 = InStr(strRet, "</" + methodName + "Result>")
'    If intPos1 > 0 And intPos2 > 0 Then
'        intPos1 = InStr(intPos1, strRet, ">") + 1
'        CallWebMethod = Mid(strRet, intPos1, intPos2 - intPos1)
'    End If
'
'Exit Function
'CallWebMethod_Err:
'   popmessagecr "", "A problem occurred trying to access web method " & methodName & crlf & crlf & "Error : " & Format$(Err.Number) & " Description : " & Err.Description
'End Function

