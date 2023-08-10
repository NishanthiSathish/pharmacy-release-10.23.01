<%@ Page language="vb" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%@ Import Namespace="Ascribe.Xml" %>

<% 
    '---------------------------------------------------------------------------------------------------------
    '
    'AdministrationSave.aspx
    '
    'Creates and Saves a drug admin response, then redirects to the AdministrationRequestList.aspx page.
    '
    'Useage:
    '
    '
    'Modification History:
    '01Jun05 AE  Written
    '24Jan07 ST  Updated to handle user details for double checking
    'Feb07 AE  Dose Recording
    '06Mar07 AE  Fix saving problem when Dose Recording not active #SC-07-0115
    '18Feb11 Rams F0041360 - Added changes to Generic Templates
    '
    '---------------------------------------------------------------------------------------------------------
    Dim sessionId As Integer
    Dim requestId As Integer
    Dim arbTextId As Integer
    Dim arbTextIdEarlyReason As String
    Dim administered As String
    Dim [Partial] As String
    Dim prescriptionId As Integer
    Dim adminDate As String = String.Empty
    Dim entityIdChecker As Integer
    Dim prescriptionIdChecked As String
    Dim responseTypeRead As OCSRTL10.ResponseTypeRead
    Dim orderCommsItem As OCSRTL10.OrderCommsItem
    Dim dom As XmlDocument
    Dim domProduct As XmlDocument
    Dim colProducts As XmlNodeList
    Dim xmlProduct As XmlNode
    Dim xmlResponseType As XmlNode
    Dim strResponseType As String
    Dim strXml As String
    Dim strDataXml As String
    Dim strResponseTypeXml As String
    Dim strReturnXml As String
    Dim strProductXml As String
    Dim strDescription As String
    Dim strDescriptionShort As String
    Dim blnWarningsToShow As Boolean
    Dim strDate As String = String.Empty
    Dim strTime As String = String.Empty
    Dim strArbText As String
    Dim strRequestTypeId As String
    Dim strInfusionAction As String
    Dim strInfusionEnded As String
    Dim strInfusionFlowRate As String
    Dim strInfusionFlowRateUnitId As String
    Dim strInfusionFlowRateUnitIdTime As String
    Dim strContinuous As String
    Dim bLongDurationBased As Boolean
    Dim blnIsImmediateAdmin As Object
    Dim dose As Double
    Dim unitId As Integer
    Dim intQuantity As Integer
    Dim strBatchNumber As String
    Dim strExpiryDate As String
    Dim originalUrl As String
    Dim strBatchNumberXml As String
    Dim strAdministrationNote As String
    Dim bOverrideAdmin As Boolean
    Dim origin As String = String.Empty

    'Short Descriptions
    Const DESCRIPTIONSHORT_ADMINISTERED As String = "A"
    Const DESCRIPTIONSHORT_NOTDONE As String = "X"
    Const DESCRIPTIONSHORT_PARTIAL As String = "P"
    Const DESCRIPTIONSHORT_STARTED As String = "S"
    Const DESCRIPTIONSHORT_ENDED As String = "E"
    Const DESCRIPTIONSHORT_CHANGED As String = "C"
    Const DESCRIPTIONSHORT_FLOWCHANGED As String = "F"
%>

<html>
<head>
<title>Save Failed</title>
<script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
<link rel="stylesheet" type="text/css" href="../../style/dss.css" />
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
</head>
<body>
<%
    strArbText = ""

	'Read the info the user has entered from Session State
    sessionId = CIntX(Request.QueryString("SessionID"))
    requestId = CIntX(SessionAttribute(sessionId, CStr(DA_REQUESTID)))
	strAdministrationNote = SessionAttribute(sessionId, CStr(DA_NOTE))
	Dim r As Integer
    r = CIntX(Ascribe.Common.Generic.SessionAttribute(sessionId, DA_NOTE_REQUESTID))
	If (r <> requestId) Then
		strAdministrationNote = String.Empty
	End If
    entityIdChecker = CIntX(SessionAttribute(sessionId, CStr(DA_ENTITYID_CHECKER & requestId)))
    prescriptionIdChecked = CIntX(SessionAttribute(sessionId, DA_RXID_CHECKED & requestId))
	originalUrl = SessionAttribute(sessionId, "OriginURL")
	arbTextId = CIntX(SessionAttribute(sessionId, CStr(DA_ARBTEXTID)))
    arbTextIdEarlyReason = SessionAttribute(sessionId, CStr(DA_ARBTEXTID_EARLY))
    strContinuous = SessionAttribute(sessionId, "Continuous")
	bLongDurationBased = (SessionAttribute(sessionId, "LongDurationBased") = "1")
    prescriptionId = CIntX(SessionAttribute(sessionId, CStr(DA_PRESCRIPTIONID)))
	administered = Request.QueryString(DA_ADMINISTERED)
	[Partial] = Request.QueryString(DA_PARTIAL)

    dose = Generic.CDblX(SessionAttribute(sessionId, CStr(DA_TOTAL_SELECTED)))
    
	unitId = CIntX(SessionAttribute(sessionId, CStr(DA_UNITID_SELECTED)))
	'06Mar07 AE  Fix saving problem when Dose Recording not active #SC-07-0115
	'Selected Products and Batch numbers; ideally we'd assign batchnumbers to actual products, but
	'we're not quite there yet.  However, they are both in the same format, so we combine them and
	'they are all saved in the same table
	Dim oBatchNumbersRead As OCSRTL10.RequestBatchNumberRead = New OCSRTL10.RequestBatchNumberRead
	strBatchNumberXml = oBatchNumbersRead.BatchNumbersByRequestIDXML(sessionId, requestId)
	strProductXml = StripRoot(strBatchNumberXml, "root")
	strProductXml = strProductXml & StripRoot(SessionAttribute(sessionId, (DA_SELECTED_PRODUCT_XML & requestId)), "root")
	strProductXml = "<root>" & strProductXml & "</root>"
	strRequestTypeId = SessionAttribute(sessionId, "RequestTypeID")
	'Always saving the simple type at present, without the expanded information
	strInfusionAction = SessionAttribute(sessionId, "InfusionAction")
    strInfusionEnded = SessionAttribute(sessionId, "FCEndDate")
    strInfusionFlowRate = SessionAttribute(sessionId, DA_FLOW_RATE)
    strInfusionFlowRateUnitId = SessionAttribute(sessionId, DA_FLOW_RATE_UNITID)
    strInfusionFlowRateUnitIdTime = SessionAttribute(sessionId, DA_FLOW_RATE_UNITID_TIME)
    origin = SessionAttribute(sessionId, "origin")
    strResponseType = RESPONSETYPE_BASE
    bOverrideAdmin = SessionAttribute(sessionId, "OverrideAdmin") = True
	'Always saving the simple type at present, without the expanded information
    
    blnIsImmediateAdmin = SessionAttribute(sessionId, CStr(IA_ADMIN))
    '02Feb07 CD detect immediate admin so we can return to that page and resize etc
    If CStr(blnIsImmediateAdmin) = "" Then
        blnIsImmediateAdmin = 0
    End If
    
    'Add the admin date/time if we've administered
    If administered = "1" Then
        If strContinuous = "1" And strInfusionAction = "FluidChange" Then
            'Fluid change infusions record the start date in the FCStartDate variable
            adminDate = SessionAttribute(sessionId, "FCStartDate")
            
            strDate = Mid(adminDate, 1, InStr(adminDate, "T") - 1) & "T00:00:00"
            strTime = "2001-01-01T" & Mid(adminDate, InStr(adminDate, "T") + 1) & ":00"
        Else
            'Everything else records it in the AdminDate variable
            adminDate = SessionAttribute(sessionId, CStr(DA_ADMINDATE))
            If adminDate.ToLower <> "null" Then
                strDate = Mid(adminDate, 1, InStr(adminDate, "T") - 1) & "T00:00:00"
                strTime = "2001-01-01T" & Mid(adminDate, InStr(adminDate, "T") + 1) & ":00"
            Else
                strDate = "null"
                strTime = "null"
            End If
        End If
    End If
    'Build the description
    'Read the reason string to put in the description
    If arbTextId <> 0 Then
        strArbText = CStr(ArbTextByID(sessionId, arbTextId, True))
    End If

    strArbText = XMLEscape(strArbText)
    If administered <> "1" Then                                                                                                                         '02Jun08 AE  Improved description building to take account of the Infusion Action
        strDescription = "Not Administered (" & strArbText & ")"
        strDescriptionShort = DESCRIPTIONSHORT_NOTDONE
    Else
        If [Partial] = "1" Then
            strDescription = "Partially Administered (" & strArbText & ")"
            strDescriptionShort = DESCRIPTIONSHORT_PARTIAL
        Else

            Select Case LCase(strInfusionAction)
                Case "ended"
                    strDescription = "Infusion Ended"
                    strDescriptionShort = DESCRIPTIONSHORT_ENDED
											
                Case "started"
                    strDescription = "Infusion Started"
                    strDescriptionShort = DESCRIPTIONSHORT_STARTED
					
                Case "fluidchange"
                    strDescription = "Fluid Changed"
                    strDescriptionShort = DESCRIPTIONSHORT_CHANGED
					
                Case "flowratechange"
                    Dim strInfusionFlowRateUnit As String = SessionAttribute(sessionId, DA_FLOW_RATE_UNIT)
                    Dim strInfusionFlowRateUnitTime As String = SessionAttribute(sessionId, DA_FLOW_RATE_UNIT_TIME)
                    strDescription = "Flow Rate Changed: " & strInfusionFlowRate & " " & strInfusionFlowRateUnit & "/" & strInfusionFlowRateUnitTime
                    strDescriptionShort = DESCRIPTIONSHORT_FLOWCHANGED
					
                Case Else
                    'Non infusions 
                    strDescription = "Administered"
                    strDescriptionShort = DESCRIPTIONSHORT_ADMINISTERED
            End Select
            '
        End If
    End If
    'find the response type from the state request type
    responseTypeRead = New OCSRTL10.ResponseTypeRead()
    strResponseTypeXml = responseTypeRead.ResponseTypeByRequestTypeXML(sessionId, CIntX(strRequestTypeId))
    responseTypeRead = Nothing
    
    dom = New XmlDocument()
    dom.TryLoadXml(strResponseTypeXml)
    xmlResponseType = dom.SelectSingleNode("//ResponseType")
    strResponseType = xmlResponseType.Attributes("Description").Value
    Dim prescription As OCSRTL10.Prescription = New OCSRTL10.Prescription()

    If (strResponseType = "Administration Infusion" And (strContinuous <> "1") And Not (bLongDurationBased)) Then
        'force administration simple for all other admins
        strResponseType = RESPONSETYPE_STANDARD
        responseTypeRead = New OCSRTL10.ResponseTypeRead()
        strResponseTypeXml = responseTypeRead.GetByDescription(sessionId, strResponseType)
        responseTypeRead = Nothing
        dom.TryLoadXml(strResponseTypeXml)
        xmlResponseType = dom.SelectSingleNode("//ResponseType")
    End If
	
    Dim listEntities As List(Of Integer) = New List(Of Integer)

    If Not xmlResponseType Is Nothing Then
        'Now build up our xml document
        strDataXml = GetFieldXML("ASCDescription", strDescription, "") & GetFieldXML("ASCDescriptionShort", strDescriptionShort, "") & GetFieldXML("RequestID_Prescription", prescriptionId, "") & GetFieldXML("ProductRouteID", 0, "") & GetFieldXML("Dose", dose, "") & GetFieldXML("UnitID_Dose", unitId, "")
        If administered = "1" Then
            strDataXml = strDataXml & GetFieldXML("AdministeredDate", strDate, "") & GetFieldXML("AdministeredTime", strTime, "")
        End If
        strDataXml = strDataXml & GetFieldXML("NotGiven", IFF(administered, "0", "1"), "")
        strDataXml = strDataXml & GetFieldXML("Partial", [Partial], "") 
		strDataXml = strDataXml & GetFieldXML("ArbTextID_Reason", arbTextId, strArbText, True) ' arbtextid could be 0 which is a FK breaker so pass true to have it converted to blank
        strDataXml = strDataXml & GetFieldXML("ArbTextID_EarlyReason", arbTextIdEarlyReason, "")
        
        ' Add overridden prescription TFS40979 29Aug12 XN
        Dim responseIdOverridden As Integer = 0
        Dim noLongerRequired As Boolean = False
       
        If bOverrideAdmin Then 
            responseIdOverridden = prescription.GetLastAdministrationResponseForAdminRequest(sessionId, requestId) 
            noLongerRequired = prescription.GetNoLongerRequiredForAdminResponse(sessionId, responseIdOverridden)
        Else If strInfusionAction = "Ended" Then
            Dim responseIdOverridden_noset = prescription.GetLastAdministrationResponseForAdminRequest(sessionId, requestId)
            noLongerRequired = prescription.GetNoLongerRequiredForAdminResponse(sessionId, responseIdOverridden_noset)
        End If

        strDataXml = strDataXml & "<attribute name='ResponseID_Overridden' value='" + IIf(responseIdOverridden = 0, "", responseIdOverridden.ToString()).ToString() + "' />"
        strDataXml = strDataXml & "<attribute name='NoLongerRequiredAfterCancellation' value='" + noLongerRequired.ToString() + "' />"

        '29Jan07 CD extra fields for administration infusion
        If strResponseType = "Administration Infusion" Then
            If strInfusionAction <> "Ended" And strInfusionAction <> "FluidChange" Then
                strInfusionEnded = ""
            End If
            'blank out unecessary end date
            If strInfusionAction = "Ended" Then
                strInfusionEnded = adminDate
            End If
            'if ended then get the admin as the ended date
            strDataXml = strDataXml & "<attribute name='Volume' value='0' />"
            strDataXml = strDataXml & "<attribute name='UnitID_Volume' value='0' />"
            strDataXml = strDataXml & "<attribute name='Ended' value='" & strInfusionEnded & "' />"
            strDataXml = strDataXml & "<attribute name='Action' value='" & strInfusionAction & "' />"
            strDataXml = strDataXml & "<attribute name='FlowRate' value='" & strInfusionFlowRate & "' />"
            strDataXml = strDataXml & "<attribute name='UnitID_FlowRate' value='" & strInfusionFlowRateUnitId & "' />"
            strDataXml = strDataXml & "<attribute name='UnitID_FlowRateTime' value='" & strInfusionFlowRateUnitIdTime & "' />"
        End If
        
        '25Jan07 ST  Double checked addition
        'Add in the checker entityid if we have it
        strDataXml = strDataXml & GetFieldXML("EntityID_Checker", entityIdChecker, "")
        strDataXml = strDataXml & GetFieldXML("PrescriptionID_Checked", prescriptionIdChecked, "")
        'If we've recorded products and / or batchnumbers, add them in
        If strProductXml.Trim() <> "" Then
            '
            domProduct = New XmlDocument()
            domProduct.TryLoadXml(strProductXml)
            colProducts = domProduct.SelectNodes("//" & NODE_PRODUCT & "[(@" & ATTR_BATCHNUMBER & ") or (@" & ATTR_QUANTITY_SELECTED & ")]")
            For Each xmlProduct In colProducts
                strBatchNumber = IFF(String.IsNullOrEmpty(xmlProduct.Attributes(CStr(ATTR_BATCHNUMBER)).Value), "", xmlProduct.Attributes(CStr(ATTR_BATCHNUMBER)).Value)
                strExpiryDate = IFF(String.IsNullOrEmpty(xmlProduct.Attributes(CStr(ATTR_BATCHEXPIRYDATE)).Value), "", xmlProduct.Attributes(CStr(ATTR_BATCHEXPIRYDATE)).Value).ToString()
                If Not xmlProduct.Attributes(CStr(ATTR_QUANTITY_SELECTED)) Is Nothing Then
                    intQuantity = CIntX(xmlProduct.Attributes(CStr(ATTR_QUANTITY_SELECTED)).Value)
                End If
                
                If (CStr(strBatchNumber) <> "") Or (intQuantity > 0) Then
                    strDataXml = strDataXml & "<attribute name='ProductID' " & "value='"
                    
                    If xmlProduct.Attributes(CStr(ATTR_PRODUCTID)) Is Nothing OrElse xmlProduct.Attributes(CStr(ATTR_PRODUCTID)).Value = "" Then
                        strDataXml = strDataXml & "0"
                    Else
                        strDataXml = strDataXml & xmlProduct.Attributes(CStr(ATTR_PRODUCTID)).Value.ToString()
                    End If

                    strDataXml = strDataXml & "' " & "quantity='" & intQuantity & "' " & "batchnumber='" & strBatchNumber.ToString().Replace("'", "&apos;") & "' " & "expirydate='" & strExpiryDate & "' " & "/>"
                End If
            Next
            '
            If Boolean.Parse(SessionAttribute(sessionId, "IsGenericTemplate")) = True Then
                '13Apr11    Rams    F0114532 - F0041360 - Where a freetext prescription has an apostrophe in the drug name, the application errors when administering the drug. Found in NT 10.06.00.38
                strDataXml = strDataXml & "<attribute name='DrugName' " & "value='" & XMLEscape(SessionAttribute(sessionId, "DrugName")) & "'" & "/>"
            End If
            '
        End If

        strXml = "<save>" & "<item " & "inreplytoid='" & requestId & "' " & "tableid='" & xmlResponseType.Attributes("TableID").Value & "' " & "class='response' " & "ocstype='response' " & "ocstypeid='" & xmlResponseType.Attributes("ResponseTypeID").Value & "' " & "template='0' " & "autocommit='1'>" & "<data filledin='1'>" & strDataXml & "</data>" & "</item>" & "</save>"
        'And save it
        orderCommsItem = New OCSRTL10.OrderCommsItem()
        '22Apr2010  Rams    F0078434 - Do not Create AdminRequest for PRN's when Override Administration    
        'Set the Override Admin property to true, just to enable OrderComms to avoid creating the Admin request for a PRN
        'If Generic.SessionAttribute(SessionID, "OverrideAdmin") = True Then objOCSItem.OverrideAdmin = True    TFS40979 29Aug12 XN
        orderCommsItem.OverrideAdmin = bOverrideAdmin
        '
        ' Task 32282 - SaveResponseBatch may return an error if prescription has been changed.
        Try
            strReturnXml = orderCommsItem.SaveResponseBatch(sessionId, strXml)
        Catch ex As Exception
            '28022013   Rams    57640 - unable to administer a drug (commented out the String.empty line and throw the actual error, as locking is happening as expected in prescribing, as tested by yousaf)
            'strReturn_XML = String.Empty
            Throw ex
        End Try


        If strReturnXml <> String.Empty Then
            'Clear the overrideAdmin SessionAttribute here and reset all the flags
            orderCommsItem.OverrideAdmin = False
            SessionAttributeSet(sessionId, "OverrideAdmin", False)
            'begin LB 24-Sept-2008
            If (Not strAdministrationNote Is Nothing And (Not strAdministrationNote = "")) Then
                strAdministrationNote = strAdministrationNote.Replace("<br/>", "&#13;")
            End If    
                
            Dim domSaved As XmlDocument = New XmlDocument()
            Dim colSaved As XmlNodeList
            domSaved.TryLoadXml(strReturnXml)
            colSaved = domSaved.SelectNodes("saveresults//item//saveok")
            For Each item As XmlNode In colSaved
                Dim responseId As Integer = CIntX(item.Attributes("id").Value)
                
                If (Not strAdministrationNote Is Nothing And (Not strAdministrationNote = "")) Then
                    Dim noteXml As String
                    noteXml = "<root><data><attribute name=""Detail"" value=""" & strAdministrationNote & """/></data></root>"
                    orderCommsItem.CreateAttachedNote(sessionId, noteXml, "Administration Note", "Response", responseId)
                End If

                listEntities.Add(responseId)
            Next
            'end LB 24-Sept-2008
            'LB 04-Aug-2008 start
            prescription.UpdateAdministrationStatus(sessionId, prescriptionId, administered, [Partial], strInfusionAction)
            'LB 04-Aug-2008 end
        Else
            Response.Redirect("AdministrationRequestList.aspx?SessionID=" + sessionId.ToString() + "&LockRequestFailed=true")
            Return
        End If
    Else
        'Missing response type
        strReturnXml = "<saveresults><item description='Administration Response'>" & "<BrokenRules>" & "<Rule Code='Configuration Error' " & "Text='The system ResponseType [" & strResponseType & "] is missing.' " & "/>" & "</BrokenRules>" & "</item></saveresults>"
    End If
    'If all went well, we simply direct back to the request list and this page is never seen.
    'If anything went wrong, we'll display the error further down.
    blnWarningsToShow = SaveResults.ScriptSaveResults(sessionId, strReturnXml, False, True)

    If Not blnWarningsToShow Then
        'Clear state variables which were specific to this admin response
        SessionAttributeSet(sessionId, CStr(DA_DOSE), "")
        SessionAttributeSet(sessionId, CStr(DA_DOSETO), "")
        SessionAttributeSet(sessionId, CStr(DA_REQUESTID), "")
        SessionAttributeSet(sessionId, CStr(DA_NOTE), "")
        SessionAttributeSet(sessionId, CStr(DA_NOTE_REQUESTID), "")
        SessionAttributeSet(sessionId, CStr(DA_PRESCRIPTIONID), "")
        SessionAttributeSet(sessionId, CStr(DA_ARBTEXTID), "")
        SessionAttributeSet(sessionId, (DA_SELECTED_PRODUCT_XML & requestId), "")
        '06Jun10 ST Clear out the second checker from state
        SessionAttributeSet(sessionId, (DA_ENTITYID_CHECKER & requestId), "")
        SessionAttributeSet(sessionId, (DA_RXID_CHECKED & requestId), "")

        SessionAttributeSet(sessionId, "InfusionAction", "")
        SessionAttributeSet(sessionId, "OriginURL", "")
        SessionAttributeSet(sessionId, "IsDoseLess", "")
        SessionAttributeSet(sessionId, CStr(DA_NODOSERULES), "")
        SessionAttributeSet(sessionId, "origin", "")
        
        'Delete second check from the database
        'Dim oSecondCheck As OCSRTL10.RequestSecondCheck = New OCSRTL10.RequestSecondCheck
        'oSecondCheck.DeleteSecondCheck(SessionID, iRequestSecondCheckID)
        
        ' Delete batch numbers from the database
        Dim oBatchNumbers As OCSRTL10.RequestBatchNumber = New OCSRTL10.RequestBatchNumber
        oBatchNumbers.DeleteBatchNumbers(sessionId, strBatchNumberXml)
        
        ' Unlock the request
        Dim requestLock As OCSRTL10.RequestLock = New OCSRTL10.RequestLock()
        requestLock.UnlockMyRequestLock(sessionId, requestId)
        
        ' Build Json Dictionary
        Dim dictRoot As Dictionary(Of String, Object) = New Dictionary(Of String, Object)
        dictRoot.Add("SessionId", SessionID.ToString())
        dictRoot.Add("Entities", listEntities.ToArray())
        dictRoot.Add("Origin", origin)

        ' Serialize to json
        Dim serializer As Script.Serialization.JavaScriptSerializer = New Script.Serialization.JavaScriptSerializer
        Dim json As String = serializer.Serialize(dictRoot)
            
        ' Call web api to create event
        Dim apiUrl As String = ConfigurationManager.AppSettings("ICW_V11Location") & "/webapi/OrderComms/SendDrugAdministeredMessage"
        Dim webRequest As Net.HttpWebRequest
        webRequest = Net.WebRequest.Create(apiUrl)
        webRequest.Method = "POST"
        webRequest.ContentType = "application/json"
            
        Try
            Dim streamOut As IO.StreamWriter = New IO.StreamWriter(webRequest.GetRequestStream(), System.Text.Encoding.ASCII)
            streamOut.Write(json)
            streamOut.Close()
            Dim streamIn As IO.StreamReader = New IO.StreamReader(webRequest.GetResponse().GetResponseStream())
            Dim strResponse As String = streamIn.ReadToEnd()
            streamIn.Close()
        Catch ex As Exception

        End Try

        'And go back to the list o' drugs to be administered, or immediate admin
        If CIntX(blnIsImmediateAdmin) = 1 Then
            'Response.Redirect "ImmediateAdmin.aspx?SessionID=" & SessionID & "&Mode=increment"
            Response.Write("<script language=""javascript"">window.parent.RemoteNextItem(1);</script>")
            'script a call to the admin java function to resizxe the window and navigate to the immediate admin page again
        Else
            Response.Redirect("AdministrationRequestList.aspx?SessionID=" & sessionId)
        End If
    End If
%>
</body>

<script type="text/javascript" language="javascript">
//--------------------------------------------------------------------------------------------------------
function DssResultsButtonHandler(blnContinueAnyway) {

//Fires if a warning has been shown.  In this case, we'll just go back to the request list
    var strUrl = '<%= originalUrl %>' + '?SessionID=<%= sessionId %>';
    void TouchNavigate(strUrl);
}
//--------------------------------------------------------------------------------------------------------
</script>
</html>
