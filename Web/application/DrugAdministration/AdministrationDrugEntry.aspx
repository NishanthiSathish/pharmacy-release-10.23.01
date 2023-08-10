<%@ Page Language="VB" AutoEventWireup="false" CodeFile="AdministrationDrugEntry.aspx.vb" Inherits="application_DrugAdministration_AdministrationDrugEntry" %>

<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationDrugEntry.aspx
    '
    'Drug/Dose picker.
    'For the specified product and route, shows a list of actual administerable products
    '
    '
    'Modification History:
    '02Jun05 AE  Written
    '20Feb07 AE  Rewritten, with a spec this time.  Shiny.
    '20Mar07 AE  SC-07-0219; don't show this page in continuous infusion mode.
    '05Feb10 Rams F0063046-   Doseless prescription should not be prompted for Dose
    '29Mar11 Rams F0113133 - Free text admin of when required doses - due text issue
    '23May11 Rams F0118417 - admin from stock, text off screen
    '07Sep11 XN   TFS 11281 Get correct unit ID for bolus infusions, and fixed crash with prescription that have Quantity
    '
    '----------------------------------------------------------------------------------------------------------------
    Const SIMPLE_ENTRY_ONLY = True                  'Override switch to force the application into simple numerical entry mode.
    'Set to FALSE to use normal, product selection mode.
    
    Dim sessionId As Integer
    Dim entityId As Integer
    Dim episodeId As Integer
    Dim productIdPrescribed As Integer
    Dim productIdAdded As String 
    Dim prescriptionId As Integer
    Dim Dose As Object 
    Dim doseTo As String = String.Empty
    Dim unit As String = String.Empty
    Dim unitId As Integer = 0
    Dim productRouteId As String = String.Empty
    Dim productFormId As String = String.Empty
    Dim requestId As Integer 
    Dim quantityToAdd As String
    Dim DoseSelected As String
    Dim dom As XmlDocument = Nothing
    Dim domProducts As XmlDocument = Nothing
    Dim colProducts As XmlNodeList = Nothing
    Dim xmlProductRoot As XmlNode
    Dim xmlProduct As XmlNode
    Dim xmlData As XmlNode
    Dim strProductXml As String 
    Dim strProductAvailableXml As String = String.Empty
    Dim intQty As Integer 
    Dim dblQuantity As Double
    Dim dblQuantityPerUnit As Double 
    Dim dblTotal As Double 
    Dim strActiveUnit As String
    Dim activeUnitId As Integer
    Dim blnOverdose As Boolean 
    Dim blnUnderdose As Boolean 
    Dim blnRecordDoses As Boolean = False
    Dim strRecordDoses As String
    Dim blnContinuous As Boolean
    Dim bLongDurationBased As Boolean     
    Dim usePom As Boolean
    Dim blnMandatoryDose As Boolean
    Dim isDoseLess As Boolean = False
    Dim isGenericTemplate As Boolean = False
    '------------------------------------------------------------------------------------------------

    dblQuantity = 0
    dblQuantityPerUnit = 0
    dblTotal = 0
    strActiveUnit = ""
    blnOverdose = false
    blnUnderdose = False

    'Read querystring and State to get out standard variables
    sessionId = CIntX(Request.QueryString("SessionID"))
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If
    
    entityId = CIntX(StateGet(sessionId, "Entity"))
	requestId = CInt(SessionAttribute(sessionId, DA_REQUESTID))
    
    'F0063047 ST 040210 Get new setting for mandatory dose recording and changed version of dose recording
    'blnRecordDoses = (Generic.SettingGet(SessionID, "OCS", "DrugAdministration", "RecordDoses", "0") = "1")
    blnMandatoryDose = (SettingGet(sessionId, "OCS", "DrugAdministration", "MandatoryRecordDoses", "0") = "1")
    strRecordDoses = SettingGet(sessionId, "OCS", "DrugAdministration", "RecordDoses", "None")
    blnContinuous = (SessionAttribute(sessionId, "Continuous") = "1")
    bLongDurationBased = (SessionAttribute(sessionId, "LongDurationBased") = "1")
    usePom = (SessionAttribute(sessionId, "UsePOM") = "1")

    'We may have to store the Admin Date if we've come from the date picker
    If Request.QueryString(DA_ADMINDATE) <> "" Then
		SessionAttributeSet(sessionId, DA_ADMINDATE, Request.QueryString(DA_ADMINDATE))
	End If
	
	'If we have been sent a dose to store (this will be the case when confirming in numerical entry mode), store it and move
	'on to the next page
	If Request.QueryString("Confirm") = "1" Then
		SessionAttributeSet(sessionId, DA_TOTAL_SELECTED, Request.QueryString(DA_TOTAL_SELECTED))
		SessionAttributeSet(sessionId, DA_UNITID_SELECTED, Request.QueryString(DA_UNITID_SELECTED))
		SessionAttributeSet(sessionId, DA_UNIT_SELECTED, Request.QueryString(DA_UNIT_SELECTED))
		Response.Redirect("AdministrationYes.aspx?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate"))
	End If
	'Otherwise, on we go...
	DoseSelected = SessionAttribute(sessionId, DA_TOTAL_SELECTED)

	'F0078155 & F0078156 ST 18Feb10 Added this check in here to show/hide the dose screen depending on the prescription type
	If Not String.IsNullOrEmpty(DoseSelected) Then
		blnRecordDoses = True
	ElseIf strRecordDoses.ToLower() <> "none" AndAlso Not blnContinuous AndAlso Not bLongDurationBased Then
		prescriptionId = CIntX(SessionAttribute(sessionId, DA_PRESCRIPTIONID))
		Dose = SessionAttribute(sessionId, DA_DOSE)
		If CStr(Dose) = "" Then
			dom = PrescriptionRowByID(sessionId, prescriptionId)
			xmlData = dom.SelectSingleNode("//data")
			isGenericTemplate = (GetXMLExpandedValue(xmlData, "RequestTypeID").ToLower() = "generic prescription")
			'
			'Get the dose of this product, which may be a range
			productIdPrescribed = CIntX(GetXMLValueNumeric(xmlData, "ProductID"))
			'Standard or Doseless Prescription with a single product
			'29Mar11    Rams    F0113133 - Free text admin of when required doses - due text issue
			If Not isGenericTemplate Then
				colProducts = xmlData.SelectNodes("Ingredients/Product")
				If colProducts.Count = 1 Then
					xmlProduct = xmlData.SelectSingleNode("Ingredients/Product")
					If xmlProduct.Attributes("QuantityMin") IsNot Nothing AndAlso xmlProduct.Attributes("QuantityMin").Value.Length > 0 AndAlso xmlProduct.Attributes("QuantityMin").Value <> "0" AndAlso xmlProduct.Attributes("QuantityMax") IsNot Nothing AndAlso xmlProduct.Attributes("QuantityMax").Value.Length > 0 AndAlso xmlProduct.Attributes("QuantityMax").Value <> "0" Then
						Dose = xmlProduct.Attributes("QuantityMin").Value
						doseTo = xmlProduct.Attributes("QuantityMax").Value
					ElseIf xmlProduct.Attributes("Quantity") IsNot Nothing AndAlso xmlProduct.Attributes("Quantity").Value.Length > 0 AndAlso xmlProduct.Attributes("Quantity").Value <> "0" Then
						doseTo = xmlProduct.Attributes("Quantity").Value
						Dose = 0
					End If
				Else
					If CDblX(GetXMLValueNumeric(xmlData, "DoseLow")) = 0 Then
						'Single Dose
						doseTo = CStr(GetXMLValueNumeric(xmlData, "Dose"))
						Dose = 0
					Else
						'Range of doses
						Dose = GetXMLValueNumeric(xmlData, "DoseLow")
						doseTo = CStr(GetXMLValueNumeric(xmlData, "Dose"))
					End If
				End If
        
				unit = GetAdminUnit(xmlData, (CDblX(Dose) > 1 Or CDblX(doseTo) > 1), sessionId)
                If String.IsNullOrEmpty(unit) Then
                    unitId = 0
                Else
                    unitId = GetAdminUnitID(xmlData)
                End If

				productRouteId = CStr(GetXMLValueNumeric(xmlData, "ProductRouteID"))
				productFormId = CStr(GetXMLValueNumeric(xmlData, "ProductFormID_Dose"))
			Else
				Dose = 0
				doseTo = 0
			End If
			'
			isDoseLess = (GetXMLExpandedValue(xmlData, "RequestTypeID").ToLower() = "doseless prescription") OrElse isGenericTemplate
			SessionAttributeSet(sessionId, DA_DOSE, Dose)
			SessionAttributeSet(sessionId, DA_DOSETO, doseTo)
			SessionAttributeSet(sessionId, DA_UNITNAME, unit)
			SessionAttributeSet(sessionId, DA_UNITID, unitId.ToString())
			SessionAttributeSet(sessionId, DA_ROUTEID, productRouteId)
			SessionAttributeSet(sessionId, DA_FORMID, productFormId)
			SessionAttributeSet(sessionId, "IsDoseLess", isDoseLess.ToString())
		Else
			doseTo = SessionAttribute(sessionId, DA_DOSETO)
			Dim doselessAttribute As String = SessionAttribute(sessionId, "IsDoseLess")
			isDoseLess = Not String.IsNullOrEmpty(doselessAttribute) AndAlso Boolean.Parse(doselessAttribute)
		End If

		If ((strRecordDoses.ToLower() = "variable" And CDblX(Dose) > 0 And CDblX(doseTo) > 0) Or strRecordDoses.ToLower() = "all") Then
			blnRecordDoses = True
		End If
   
		If isDoseLess Then
			blnRecordDoses = False
		End If
    End If

    ' Even if dose recording is not enabled we still have to record a dose for a variable dose prescription that has a maximum dose rule defined
    If Not blnRecordDoses Then
		prescriptionId = CIntX(SessionAttribute(sessionId, DA_PRESCRIPTIONID))
		Dose = SessionAttribute(sessionId, DA_DOSE)
        If CStr(Dose) = "" Then
            dom = PrescriptionRowByID(sessionId, prescriptionId)        
            xmlData = dom.SelectSingleNode("//data")
            If CDblX(GetXMLValueNumeric(xmlData, "MaximumDoseOverTimeDose")) <> 0.0 And CIntX(GetXMLValueNumeric(xmlData, "MaximumDoseOverTimeInterval")) <> 0 And CIntX(GetXMLValueNumeric(xmlData, "UnitID_MaximumDoseOverTime")) <> 0 And CDblX(GetXMLValueNumeric(xmlData, "DoseLow")) <> 0 Then
                blnRecordDoses = True
            End If
        End If
    End If
    
    'Check if Dose Recording is enabled.  If not, skip this page and go directly to AdministrationYes.aspx.
	If (Not blnRecordDoses) Or (blnContinuous) Or (bLongDurationBased) Then
		Generic.SessionAttributeSet(sessionId, "DoseRecording", "")
		dblQuantity = CDblX(RetrieveAndStore(sessionId, DA_TOTAL_SELECTED))
        
		Dim sUrl As String = "AdministrationYes.aspx?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate")
        
		' copy ADMINISTERED and PARTIAL states (for partial infusions)			  
		If Request.QueryString(DA_ADMINISTERED) <> "" Then
			sUrl &= "&" + DA_ADMINISTERED + "=" + Request.QueryString(DA_ADMINISTERED)
		End If
        
		If Request.QueryString(DA_PARTIAL) <> "" Then
			sUrl &= "&" + DA_PARTIAL + "=" + Request.QueryString(DA_PARTIAL)
		End If
        
		Response.Redirect(sUrl)
	End If
    
	Generic.SessionAttributeSet(sessionId, "DoseRecording", "1")
    'Read the Prescription so we can interpret the dose required.
    'We store this in the SessionAttribute table after the first hit, for speed
	prescriptionId = CIntX(SessionAttribute(sessionId, DA_PRESCRIPTIONID))
	Dose = SessionAttribute(sessionId, DA_DOSE)
    If CStr(Dose) = "" Then
        'Have't got it in state, so read the prescription.  We will only have one at this point, as the
        'user will have selected which of an either/or prescription is to be given.
        dom = PrescriptionRowByID(sessionId, prescriptionId)
       
        xmlData = dom.SelectSingleNode("//data")
        'Get the dose of this product, which may be a range
        productIdPrescribed = CIntX(GetXMLValueNumeric(xmlData, "ProductID"))
		SessionAttributeSet(sessionId, DA_PRODUCTID_PRESCRIBED, productIdPrescribed.ToString())
        'Standard or Doseless Prescription with a single product
        colProducts = xmlData.selectNodes("Ingredients/Product")
        If colProducts.Count = 1 Then
            xmlProduct = xmlData.selectSingleNode("Ingredients/Product")
			If xmlProduct.Attributes("QuantityMin") IsNot Nothing AndAlso xmlProduct.Attributes("QuantityMin").Value.Length > 0 AndAlso xmlProduct.Attributes("QuantityMin").Value <> "0" AndAlso xmlProduct.Attributes("QuantityMax") IsNot Nothing AndAlso xmlProduct.Attributes("QuantityMax").Value.Length > 0 AndAlso xmlProduct.Attributes("QuantityMax").Value <> "0" Then
				Dose = xmlProduct.Attributes("QuantityMin").Value
				doseTo = CStr(xmlProduct.Attributes("QuantityMax").Value)
			ElseIf xmlProduct.Attributes("Quantity") IsNot Nothing AndAlso xmlProduct.Attributes("Quantity").Value.Length > 0 AndAlso xmlProduct.Attributes("Quantity").Value <> "0" Then
				doseTo = CStr(GetXMLValueNumeric(xmlData, "Quantity"))
				Dose = 0
			End If
        Else
			If CDblX(GetXMLValueNumeric(xmlData, "DoseLow")) = 0 Then
				'Single Dose
				doseTo = CStr(GetXMLValueNumeric(xmlData, "Dose"))
				Dose = 0
			Else
				'Range of doses
				Dose = GetXMLValueNumeric(xmlData, "DoseLow")
				doseTo = CStr(GetXMLValueNumeric(xmlData, "Dose"))
			End If
        End If
        
		unit = GetAdminUnit(xmlData, (CDblX(Dose) > 1 Or CDblX(doseTo) > 1), sessionId)
        unitId = GetAdminUnitID(xmlData)    ' XN 07Sep11 TFS 11281 Get correct unit ID for bolus infusions
        
        'Unit = CStr(GetXMLExpandedValue(xmlData, "UnitID_Dose"))
        'UnitID = CStr(GetXMLValueNumeric(xmlData, "UnitID_Dose")) ' XN 07Sep11 TFS 11281 Get correct unit ID for bolus infusions
        productRouteId = CStr(GetXMLValueNumeric(xmlData, "ProductRouteID"))
        productFormId = CStr(GetXMLValueNumeric(xmlData, "ProductFormID_Dose"))
        
        
		isDoseLess = (GetXMLExpandedValue(xmlData, "RequestTypeID").ToLower() = "doseless prescription")
        'Store in state for next time to save reading the prescription each time, which is quite heavy.

		SessionAttributeSet(sessionId, DA_DOSE, Dose)
		SessionAttributeSet(sessionId, DA_DOSETO, doseTo)
		SessionAttributeSet(sessionId, DA_UNITNAME, unit)
		SessionAttributeSet(sessionId, DA_UNITID, unitId.ToString())
		SessionAttributeSet(sessionId, DA_ROUTEID, productRouteId)
		SessionAttributeSet(sessionId, DA_FORMID, productFormId)
        SessionAttributeSet(sessionId, "IsDoseLess", isDoseLess.ToString())
    Else
        'Read the lot from state
		doseTo = SessionAttribute(sessionId, DA_DOSETO)
		unit = SessionAttribute(sessionId, DA_UNITNAME)
		unitId = CIntX(SessionAttribute(sessionId, DA_UNITID))
		productRouteId = SessionAttribute(sessionId, DA_ROUTEID)
		productFormId = SessionAttribute(sessionId, DA_FORMID)
        Dim doselessAttribute As String = SessionAttribute(sessionId, "IsDoseLess")
        isDoseLess = Not String.IsNullOrEmpty(doselessAttribute) AndAlso Boolean.Parse(doselessAttribute)
    End If

    If Not SIMPLE_ENTRY_ONLY Then
        'Read the list of drugs we could administer against this dose
        strProductXml = Generic.SessionAttribute(sessionId, (DA_SELECTED_PRODUCT_XML & requestId))
        domProducts = New XmlDocument()
        If strProductXml = "" Then
            'First time through, create the administerable product list for this dose
            xmlProductRoot = domProducts.appendChild(domProducts.createElement("root"))
            GetAdministerableDrugs(sessionId, productIdPrescribed, productRouteId, productFormId, Dose, unitId, xmlProductRoot)
            strProductXml = domProducts.OuterXml
        Else
            domProducts.TryLoadXml(strProductXml)
        End If
        'And the list of drugs which have been selected in the pick list.
        'Note that this step is optional, so we may not have anything here.
		strProductAvailableXml = Generic.SessionAttribute(sessionId, DA_PRODUCT_LIST_XML)
        'Update this list with what has just been selected, if anything; as the user selects
        'products, the quantity of each is passed on the querystring
        quantityToAdd = Request.QueryString(DA_ADD_QUANTITY)
        productIdAdded = Request.QueryString(DA_PRODUCTID_SELECTED)
        If productIdAdded <> "" Then
            xmlProduct = domProducts.SelectSingleNode("//" & NODE_PRODUCT & "[@" & ATTR_PRODUCTID & "='" & productIdAdded & "']")
			intQty = Generic.CIntX(xmlProduct.Attributes(ATTR_QUANTITY_SELECTED).Value)
            intQty = intQty + CIntX(quantityToAdd)
            If intQty < 0 Then
                intQty = 0
            End If
            
			xmlProduct.Attributes(ATTR_QUANTITY_SELECTED).Value = intQty.ToString()
            DisableAllExceptSelectedForm(domProducts)
        End If
        'Determine if we've found any products
        colProducts = domProducts.selectNodes("//" & NODE_PRODUCT)
    End If
%>

<html>
<head>
<title>Drug Picker</title>
<script language="javascript" type="text/javascript" src="scripts/DrugAdministrationConstants.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
<script language="javascript" type="text/javascript">
    var m_strPage;

    //------------------------------------------------------------------------------------------------------------------
    //function Navigate(strPage, blnShowWarnings){
    //
    //	if (blnShowWarnings){
    //	//Show any dose range warnings
    //		var blnOverdose = <%= LCase(CStr(blnOverdose)) %>;
    //		var blnUnderdose = <%= LCase(CStr(blnUnderdose)) %>;
    //		
    //		if (blnOverdose || blnUnderdose){
    //			void ShowDoseWarning(blnOverdose, blnUnderdose, strPage);			
    //		}			
    //		else {
    //			void NavigateToPage(strPage);
    //		}
    //	}
    //	else {
    //		void NavigateToPage(strPage);
    //	}
    //}
    //----------------------------------------------------------------------------------------------
    function ShowDoseWarning(blnOverdose, blnUnderdose, strDestinationPage) {

        var strPromptHtml = '<h1>WARNING!</h1><p>This dose is ';
        if (blnOverdose) {
            strPromptHtml += 'GREATER ';
        }
        
        if (blnUnderdose) {
            strPromptHtml += 'LOWER ';   
        }
        strPromptHtml += 'than the prescribed dose.  Are you sure that you wish to continue?</p>';
        m_strPage = strDestinationPage;
        void document.frames['fraConfirm'].Show(strPromptHtml, 'yesno');
    }

    //----------------------------------------------------------------------------------------------

    function Confirmed(strChosen) {

        //User was warned of an over- or underdose and has selected yes or no.
        if (strChosen == 'yes') {
            NavigateToPage("../../DrugAdministration/" + m_strPage);
        }
        else {
            m_strPage = '';
        }
    }
    //------------------------------------------------------------------------------------------------------------------
    function NavigateToPage(strPage) {

        //var strURL = document.URL.toLowerCase()
        //strURL = strURL.substring(0, strURL.indexOf('?'));
        //strURL = strURL.split('administrationdrugentry.aspx').join(strPage);
        // F0068155 JMei 16Nov2009 when iis set to “use uri” instead of “use cookie”, don't navigate to a whole URL, remove path.
        var strUrl = strPage;
        if (strUrl.toLowerCase().indexOf('?sessionid') < 0) {
            strUrl += '?SessionID=<%= sessionId %>';  
        } 
        void TouchNavigate(strUrl);
    }

    //------------------------------------------------------------------------------------------------------------------
    function Confirm() {

        //When confirm is pressed
        var dosePrescribedFrom = Number(dose.value);
        var dosePrescribedTo = Number(doseto.value);
        var doseGiven = Number(doseselected.value);
        var strRecordDose = document.body.getAttribute("recorddoses").toLowerCase();
        var blnMandatory = (document.body.getAttribute("mandatorydose").toLowerCase() == "true");
        var blnVariableDose = (dosePrescribedFrom > 0 && dosePrescribedTo > 0);

        var strPage = 'AdministrationDrugEntry.aspx?SessionID=<%= sessionId %>'
        + '&Confirm=1'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&<%= DA_TOTAL_SELECTED %>=' + doseGiven
                    + '&<%= DA_UNITID_SELECTED %>=' + unitid.value
                        + '&<%= DA_UNIT_SELECTED %>=' + unit.value;


        // F0063047 ST Now prompts for the dose if Mandatory Dose Recording is ON and the prescription type matches the Record Doses setting of either
        // Variable Dose or All prescriptions.
        //F0063046  Rams    Doseless prescription should not be prompted for Dose
        if (blnMandatory && strRecordDose != "none" && document.body.getAttribute("IsDoseLess").toLowerCase() != "true") {
            if ((blnVariableDose && doseGiven == 0 && strRecordDose == "variable") || (strRecordDose == "all" && doseGiven == 0)) {
                SetDose();
                return;
            }
        }

        var blnUnder = (doseGiven >= 0 && ((dosePrescribedFrom > 0 && doseGiven < dosePrescribedFrom) || (dosePrescribedFrom <= 0 && doseGiven < dosePrescribedTo)));
        var blnOver = (doseGiven > dosePrescribedTo);
        if (blnUnder || blnOver) {
            void ShowDoseWarning(blnOver, blnUnder, strPage);
        }
        else {
            void TouchNavigate(strPage);
        }
    }

    //------------------------------------------------------------------------------------------------------------------
    function SetDose() {
        document.frames['fraKeyboard'].ShowNumpad('Enter Dose Given in <%= unit %>', null, 4);
    }
    //------------------------------------------------------------------------------------------------------------------
    function ScreenKeyboard_EnterText(doseQuantity) {

        //Fires when the user has entered a quantity on the number pad
        //If they didn't cancel, we need to add this drug to our basket o' drugs.

        if (doseQuantity != '') {
            tdDose.innerHTML = doseQuantity + ' ' + unit.value;
        }
        else {
            tdDose.innerHTML = '(Not Recorded)';
        }
        doseselected.value = doseQuantity;
    }

    //----------------------------------------------------------------------------------------------
    function EnableButtons() {

        if (tblContent.offsetHeight < (divScroller.offsetHeight - 20)) {
            document.all['tblScrollButtons'].style.display = 'none';
        }
        else {
            if (divScroller.scrollTop <= 0) {
                void EnableButton(document.all['ascScrollup'], false);
            }
            else {
                void EnableButton(document.all['ascScrollup'], true);
            }

            if ((divScroller.scrollTop + divScroller.offsetHeight) >= tblContent.offsetHeight) {
                void EnableButton(document.all['ascScrolldown'], false);
            }
            else {
                void EnableButton(document.all['ascScrolldown'], true);
            }

        }

    }

    //----------------------------------------------------------------------------------------------
    function PageUp() {
        //Scroll the content window 1 page upwards
        divScroller.scrollTop = divScroller.scrollTop - divScroller.offsetHeight;
        EnableButtons();
    }
    //----------------------------------------------------------------------------------------------
    function PageDown() {
        //Scroll the content window 1 page downwards
        divScroller.scrollTop = divScroller.scrollTop + divScroller.offsetHeight;
        EnableButtons();
    }
    //----------------------------------------------------------------------------------------------
</script>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>
<!-- F0063047 ST 040210 Add new settings to body tag -->
<body mandatorydose="<%=blnMandatoryDose %>" recorddoses="<%=strRecordDoses %>" isDoseless="<%=isDoseLess.ToString() %>" class="Touchscreen DrugEntry"	onload="document.body.style.cursor = 'default';<%
    
     If Not SIMPLE_ENTRY_ONLY Then
        If colProducts.Count > 0 Then 
            Response.Write("EnableButtons()")
        End If
     ElseIf String.IsNullOrEmpty(DoseSelected) OrElse CDbl(DoseSelected) = 0
        Response.Write("SetDose()")
     End if
%>">
<table width="100%" cellpadding="0" cellspacing="0">        
<%
    'Selected Patient details
    PatientBannerByID(sessionId, entityId, episodeId)
%>
<tr>
    <td colspan="2">
        <table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
        	<tr>
                <%
                    If Not SIMPLE_ENTRY_ONLY Then
                        If colProducts.Count > 0 Then
                %>
                <td class="Toolbar" style="padding-left:<%= BUTTON_SPACING %>">					
                <%
                	Dim NavCancelURL As String = "AdministrationPrescriptionDetail.aspx?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & "&OverrideAdmin=" & IIf(String.Compare(SessionAttribute(sessionId, "OverrideAdmin"), "True", True) = 0, "1", "0").ToString()
                	TouchscreenShared.NavButton("../../images/touchscreen/Cross.gif", "Cancel", "NavigateToPage('" & NavCancelURL & "');", True)
                %>
		        </td>
                <%
                End If
            End IF
                %>
        		<td class="Toolbar" style="padding-right:<%= BUTTON_SPACING %>" align="center">
                <%
                ScriptBanner_AdminRequestCurrent(sessionId, False, entityId)
                %>
        		</td>
	        </tr>
        </table>
	</td>
</tr>
</table>

<table style="width:100%;height:90%" cellpadding="0" cellspacing="0">	
    <tr>
		<td class="Prompt">
		<%
	        DrugAdminEpisodeBannerByID(sessionId, episodeId)
        %>
		</td>
	</tr>
<%
        'Script the list O' drugs
    '    If colProducts.length > 0 And Not blnUsePOM Then   'Bypass product selection for now and always use simple mode.  Uncomment this line to revert back to product selection.  Like that'll ever happen.
    If Not SIMPLE_ENTRY_ONLY Then
%>

			<tr>
				<td class="Prompt" colspan='2'>Select the Drugs which were administered.</td>
			</tr>
			<tr>
				<td class="Info" colspan='2'>Press the Tick button to fill in the required dose automatically.  Use the Plus and Minus buttons to adjust the 
				quantity of drugs if required.  The Cross button will clear the quantity for that drug.</td>
			</tr>
			<tr>
				<td style="width:100%;height:40%;vertical-align: top;text-align:center;padding-left:30px;padding-right:30px;">
					<div id="divScroller" style="height:90%;overflow-y:hidden" >
				        <table id="tblContent" style="width:100%" cellpadding='0' cellspacing='0' border='0'>
					        <tr>
						        <td style="vertical-align: top;"><%WriteDrugs(sessionId, dom, domProducts, strProductAvailableXml)%></td>
					        </tr>
				        </table>
				    </div>
				</td>
				
				<td>
					<table id="tblScrollButtons" style="height:100%">
						<tr>
							<td style="vertical-align: top;"><%TouchscreenShared.ScrollButtonUp("PageUp()", true)%></td>
						</tr>
						<tr><td>&nbsp;</td></tr>
						<tr>
							<td style="vertical-align: bottom;"><%TouchscreenShared.ScrollButtonDown("PageDown()", true)%></td>
						</tr>
					</table>						
				</td>
			</tr>
<%
        'Add up all of the doses selected so far - (must be after WriteDrugs as this calculates defaults)
        colProducts = domProducts.SelectNodes("//" & NODE_PRODUCT & "[@" & ATTR_QUANTITY_SELECTED & "]")
        For Each xmlProduct In colProducts
			dblQuantity = CDbl(xmlProduct.Attributes(ATTR_QUANTITY_SELECTED).Value)
            'Number of these that the user has chosen to give
			dblQuantityPerUnit = CDbl(xmlProduct.Attributes(ATTR_ACTIVEQUANTITY).Value)
            'Amount of active ingredient in each one
			dblTotal = dblTotal + dblQuantity * dblQuantityPerUnit
            If CStr(strActiveUnit) = "" Then 
				strActiveUnit = xmlProduct.Attributes(ATTR_UNIT_ACTIVEQUANTITY).Value
				activeUnitId = CIntX(xmlProduct.Attributes(ATTR_UNIT_ACTIVEQUANTITYID).Value)
            End IF
        Next
            'Check if we're over or underdosing
        If CDblX(Dose) = 0 Then 
            'Single dose to check against
            blnOverdose = (dblTotal > CDbl(doseTo))
            blnUnderdose = (dblTotal < CDbl(doseTo))
        Else
            'Dose range
            blnOverdose = (dblTotal > CDbl(doseTo))
            blnUnderdose = (dblTotal < CDbl(Dose))
        End IF
%>


			<tr> 
				<td colspan='2'>
					<table class='TotalDose' style="width:100%" cellpadding='0' cellspacing='0' >
						<tr>
							<td>
								<table style="height:100%;width:100%" cellpadding='0' cellspacing='0' nowrap="true" >
									<tr>
										<td class='AttrName'>Prescribed:</td>
										<td class='AttrValue'><%If CDblX(Dose) > 0 Then
										                      		  Response.Write(Dose & " to ")
										                      	  End If
										                          Response.Write(doseTo)
										                      %>&nbsp;<%= unit %>
										</td>
										<td class='AttrName  <%If blnOverdose Then 
                                                                    Response.Write("sad")
                                                                End IF%>'>
											Total:
										</td>
										<td class='AttrValue <%If blnOverdose Then 
                                                                    Response.Write("sad")
                                                               End IF%>'><%= dblTotal %>&nbsp<%= strActiveUnit %>
										
										</td>
									</tr>
								</table>
                            </td>
								
							<td style='text-align:right;padding-right:<%= BUTTON_SPACING %>'>
<%
        TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "OK", "Confirm();", true)
%>
							</td>
						</tr>
					</table>
				</td>
			</tr>
<%
Else
    'No products found - use simple "enter a number mode".
    If Not SIMPLE_ENTRY_ONLY Then
%>

			<tr>
				<td style="height:100%;text-align: center; vertical-align: top;">
				
					<table cellpadding="0"  style="width:<%= BANNER_WIDTH_DOSE %>" align='center' class="NumericEntry">	
						<tr>
							<td colspan="2" class="Prompt">
							<%If usePom Then %>
								The drugs are patients own medication!
							<%Else %>
								We could not find any drugs for this dose!
							<%End If %>
							</td>
						</tr>
						<tr>
							<td colspan="2" class="info">
							<%If usePom Then %>
								Enter
							<%Else %>
								If the drugs are actually available, enter
							<%End If %>
							the dose given by pressing on the button below.  Or you may simply
							leave it blank and press [Confirm].
							</td>
						</tr>
						<tr>
							<td colspan="2" class="TotalDose" style="text-align: center;">
								Dose Prescribed:&nbsp;
<%
            'No products found; fall back to simple "enter a number" mode
	If CDblX(Dose) > 0 Then
		Response.Write(Dose)
	End If
	If CDblX(doseTo) > 0 Then
    	If CDblX(Dose) > 0 Then Response.Write(" to ")
		Response.Write(doseTo)
	End If
%>

								&nbsp;<%=unit%>

							</td>
						</tr>						

    <% 
        
    Else
        
     %>
			<tr>
				<td style="height:100%;text-align: center; vertical-align: top;" >
				
					<table cellpadding="0"  style="width:<%= BANNER_WIDTH_DOSE %>" align='center' class="NumericEntry">	
						<tr>
							<td colspan="2" class="TotalDose" style="text-align: center;">
								Dose Prescribed:&nbsp;
<%
            'No products found; fall back to simple "enter a number" mode
	If CDblX(Dose) > 0 Then
		Response.Write(Dose)
	End If
	If CDblX(doseTo) > 0 Then
    	If CDblX(Dose) > 0 Then Response.Write(" to ")
		Response.Write(doseTo)
	End If
	
	dblTotal = CDblX(DoseSelected)
%>

								&nbsp;<%=unit%>

							</td>
						</tr>

	<%
	
	End If
	
	%>					

						
						<tr>
							<td colspan="2" style="text-align: center;">
								<table border='1' cellpadding='0' cellspacing='0' class='Dose' style="width:100%">
									<tr>
										<td class="TouchButton" onclick="SetDose()" id="btnDose"
											 style="height:<%= TouchscreenShared.BUTTON_STANDARD_HEIGHT %>;"
<%= TouchscreenShared.EVENTHANDLER_BUTTON %>
											 align="center"
											 >
											 	<table cellpadding='1' cellspacing='0'>
											 		<tr class='Prompt'>
											 			<td>Dose Given:&nbsp;</td>
											 			<td id='tdDose'><%=IIf(String.IsNullOrEmpty(DoseSelected) OrElse CDbl(DoseSelected) = 0, "(Not Recorded)", DoseSelected & " " & Unit)%></td>
											 		</tr>
											 		<tr class='Info'><td>(press to change)</td></tr>
											 	</table>
										</td>
									</tr>
								</table>
							</td>
						</tr>
						<tr>
							<td colspan="2" class="Prompt" style="padding:<%= BUTTON_SPACING %>">
							Click [Confirm] to confirm this Dose, or [Cancel] to return to the previous page
							</td>
						</tr>
						<tr>
							<td style="text-align: right;padding:<%= BUTTON_SPACING %>">
<%
		Dim CancelURL As String = "AdministrationYes.aspx?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate")
		If Request.QueryString(DA_ADMINISTERED) <> "" Then
			CancelURL &= "&" + DA_ADMINISTERED + "=" + Request.QueryString(DA_ADMINISTERED)
		End If

		If Request.QueryString(DA_PARTIAL) <> "" Then
			CancelURL &= "&" + DA_PARTIAL + "=" + Request.QueryString(DA_PARTIAL)
		End If

		If String.IsNullOrEmpty(DoseSelected) Then
		CancelURL = "AdministrationPrescriptionDetail.aspx?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & "&OverrideAdmin=" & IIf(String.Compare(SessionAttribute(sessionId, "OverrideAdmin"), "True", True) = 0, "1", "0").ToString()
		End If

		TouchscreenShared.NavButton("../../images/touchscreen/Cross.gif", "Cancel", "NavigateToPage('" & CancelURL & "');", True)
%>

							</td>
							<td style="text-align: left;padding:<%= BUTTON_SPACING %>">
<%
        TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Confirm", "Confirm();", true)
%>
							</td>
						</tr>
					</table>				
				</td>
			</tr>
<%
    End IF
%>
</table>
<%
    If Not SIMPLE_ENTRY_ONLY Then
        'If we found no products, the active unit becomes the same as the one prescribed.
		If strActiveUnit = "" Then
			strActiveUnit = unit
			activeUnitId = unitId
		End If
        'Bung the product xml back into SessionAttribute
        Generic.SessionAttributeSet(sessionId, (DA_SELECTED_PRODUCT_XML & requestId), domProducts.OuterXml)
    End IF
        
%>
<input type="hidden" id="over" value='<%
    If blnOverdose Then 
        Response.Write("1")
    Else
        Response.Write("0")
    End IF
%>
' />
<input type="hidden" id="under" value='<%
    If blnUnderdose Then 
        Response.Write("1")
    Else
        Response.Write("0")
    End IF
%>
' />
<input type="hidden" id="dose" value='<%= Dose %>' />
<input type="hidden" id="doseto" value='<%= doseTo %>' />
<input type="hidden" id="doseselected" value='<%= dblTotal %>' />

<%  
    Dim unitClient As String
    Dim unitIdClient As Integer
    
    unitClient = unit
    unitIdClient = unitId
    
    If Not SIMPLE_ENTRY_ONLY Then
        If colProducts.Count > 0 Then
            unitClient = strActiveUnit
            unitIdClient = activeUnitId
        End If
    End If
    
%>
<input type="hidden" id="unitid" value='<%= unitIdClient %>' />
<input type="hidden" id="unit" value='<%= unitClient  %>' />

<iframe id="fraKeyboard" frameborder="1" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/keyboard.htm"></iframe>
<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>
</body>
</html>

