<%@ Page Language="VB" AutoEventWireup="false" CodeFile="AdministrationDrugPickList.aspx.vb" Inherits="application_DrugAdministration_AdministrationDrugPickList" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationDrugPickList.aspx
    '
    'Touchscreen Admin pick list application.
    '
    '
    '
    'Modification History:
    '31Jan07 AE  Written
    '
    '----------------------------------------------------------------------------------------------------------------
    Dim sessionId As Integer
    Dim routineName As String
    Dim mode As String 
    Dim scrollTop As Integer
    Dim routineRead As ICWRTL10.RoutineRead
    Dim domPatient As XmlDocument
    Dim colPatients As XmlNodeList
    Dim xmlPatient As XmlNode
    Dim domAdminRequests As XmlDocument
    Dim colAdminRequests As XmlNodeList
    Dim xmlAdminRequest As XmlNode
    Dim xmlAttribute As XmlNode
    Dim domDoses As XmlDocument = Nothing
    Dim xmlDoseRoot As XmlNode
    Dim colDoses As XmlNodeList
    Dim xmlDose As XmlNode
    Dim domDrugs As XmlDocument = Nothing
    Dim xmlDrug As XmlNode
    Dim strPatientXml As String
    Dim strRequestXml As String 
    Dim strDrugsXml As String 
    Dim blnShowWaitingPage As Boolean 
    Dim blnAddThis As Boolean 
    Dim strOnload As String 
    Dim lngProductId As String 
    Dim blnSelected As Integer 
    
    Const DEBUG_MODE As Boolean = False
    Const MODE_CALCULATELIST As String = "list"
    Const MODE_REGENERATE As String = "regenerate"
    '    Const MODE_SHOWSAVEDLIST As String = "show"
    
    Const TEXT_WARDSTOCK As String = "The following items have been located on Ward Stock."
    Const TEXT_PHARMACY As String = "The following items are shown as being held in stock, but did not appear to be on Ward Stock at the moment."
    Const TEXT_DISPENSED As String = "The following items have been dispensed directly to the patients concerned."

    blnShowWaitingPage = True
    
    'Read our state variables
    sessionId = CIntX(Request.QueryString("SessionID"))
    routineName = SessionAttribute(sessionId, CStr(DA_ROUTINENAME_PATIENT))
    mode = Request.QueryString(DA_MODE)
    scrollTop = Generic.CIntX(Request.QueryString("Top"))
    'First time through mode will be blank, and we'll script a waiting page as this will take a few seconds to run.
    'Otherwise, onto the list building...
    Select Case mode
        Case MODE_CALCULATELIST
            blnShowWaitingPage = False
            
            'Read the patient list
            routineRead = New ICWRTL10.RoutineRead()
            strPatientXml = routineRead.ExecuteByDescription(sessionId, CStr(routineName), "")
            routineRead = Nothing
            If strPatientXml <> "" Then
                ValidateRoutine_Patient(routineName, strPatientXml)
            End If
            domPatient = New XmlDocument()
            domPatient.TryLoadXml(strPatientXml)
            colPatients = domPatient.SelectNodes("//" & NODE_PATIENT)
            'For each patient, get their due doses and add them to the pile
            domDoses = New XmlDocument()
            xmlDoseRoot = domDoses.AppendChild(domDoses.CreateElement("root"))
            For Each xmlPatient In colPatients
                'Get a list of admin requests for this patient.
                strRequestXml = CStr(AdminRequestList(sessionId, CIntX(xmlPatient.Attributes(NODE_PATIENT & "ID").Value)))
                domAdminRequests = New XmlDocument()
                domAdminRequests.TryLoadXml(strRequestXml)
                colAdminRequests = domAdminRequests.SelectNodes("//" & NODE_ADMINREQUEST & "[@CanBeAdministered='1']")
                For Each xmlAdminRequest In colAdminRequests
                    'Check that all configurable status flags are set.
                    'These are named "XXX_Flag"
                    blnAddThis = True
                    For Each xmlAttribute In xmlAdminRequest.Attributes
                        If Right(xmlAttribute.Name, Len(NODE_SUFFIX_FLAG)) = CStr(NODE_SUFFIX_FLAG) Then
                            'This be a flag
                            If xmlAttribute.Value <> "1" Then
                                blnAddThis = False
                                Exit For
                            End If
                        End If
                    Next
                    
                    'We only include doseless prescriptions with the NoDoseInfo flag set.
                    'These are warfarins etc where the dose is too complex to express, and changes daily, rather than creams etc(which will be
                    'doseless but have NoDoseInfo set to 0).  We are assuming that for creams they will already have it at their bedside, but for
                    'the special cases we want to include them.
                    '02-11-2007 Error code 29
					If xmlAdminRequest.Attributes("RequestType") IsNot Nothing AndAlso xmlAdminRequest.Attributes("RequestType").Value = REQUESTTYPE_DOSELESS AndAlso xmlAdminRequest.Attributes("NoDoseInfo") IsNot Nothing AndAlso xmlAdminRequest.Attributes("NoDoseInfo").Value <> "1" Then
						blnAddThis = False
					End If
                    'We exclude anything marked as "Patient's Own"
					If xmlAdminRequest.Attributes("PatientsOwn") IsNot Nothing AndAlso xmlAdminRequest.Attributes("PatientsOwn").Value = "1" Then
						blnAddThis = False
					End If
                    'Now add this to the master list if appropriate.
                    If blnAddThis Then
                        xmlDoseRoot.AppendChild(xmlAdminRequest)
                        xmlAdminRequest.Attributes(CStr(ATTR_PATIENT)).Value = xmlPatient.Attributes("Description").Value
                    End If
                Next
            Next
            'Build the list of drugs required
            domDrugs = FindDrugsToFulfilDoses(sessionId, domDoses)
        Case MODE_REGENERATE
            'Show the waiting page and re-script the list
            blnShowWaitingPage = True
        Case Else
            'Show a list if we have it, otherwise recalculate it (the default action)
            strDrugsXml = SessionAttribute(sessionId, CStr(DA_PRODUCT_LIST_XML))
            If strDrugsXml <> "" Then
                domDrugs = New XmlDocument()
                domDrugs.TryLoadXml(strDrugsXml)
                blnShowWaitingPage = False
                strRequestXml = SessionAttribute(sessionId, CStr(DA_DOSES_LIST_XML))
                domDoses = New XmlDocument()
                domDoses.TryLoadXml(strRequestXml)
                If mode = MODE_TOGGLE Then
                    'User has pressed a checkbox; toggle it between on and off.
                    lngProductId = Request.QueryString("ID")
                    xmlDrug = domDrugs.SelectSingleNode("//" & NODE_PRODUCT & "[@" & ATTR_ID & "='" & lngProductId & "']")
                    blnSelected = CIntX(xmlDrug.Attributes(CStr(ATTR_SELECTED)).Value)
                    xmlDrug.Attributes(CStr(ATTR_SELECTED)).Value = IFF(blnSelected, "0", "1").ToString()
                End If
            End If
    End Select
    
    If blnShowWaitingPage Then 
        strOnload = "CalculateList()"
    Else
        'Save our lists in state
        SessionAttributeSet(sessionId, CStr(DA_PRODUCT_LIST_XML), domDrugs.OuterXml)
        SessionAttributeSet(sessionId, CStr(DA_DOSES_LIST_XML), domDoses.OuterXml)
        strOnload = "PicklistInitialise()"
    End IF
%>

<html>
<head>
<title></title>
<script type="text/javascript" language="javascript" src="../SharedScripts/touchscreen/TouchscreenShared.js"></script>
<script type="text/javascript" language="javascript">
//----------------------------------------------------------------------------------------------
function PicklistInitialise() {
	divScroller.scrollTop = <%= scrollTop %>;
	void EnableButtons();
}

//----------------------------------------------------------------------------------------------
function BackToEpisodeList() {
    // Fires when the "back" button is pressed
    var strUrl = 'AdministrationEpisodeList.aspx?SessionID=<%= sessionId %>';
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function Regenerate(){
	TouchNavigate ('../DrugAdministration/AdministrationDrugPicklist.aspx?SessionID=<%= sessionId %>&<%= DA_MODE %>=<%= MODE_REGENERATE %>');
}
//----------------------------------------------------------------------------------------------
function CalculateList(){
	TouchNavigate ('../DrugAdministration/AdministrationDrugPicklist.aspx?SessionID=<%= sessionId %>&<%= DA_MODE %>=<%= MODE_CALCULATELIST %>');
}
//----------------------------------------------------------------------------------------------
function EnableButtons(){

	if (tblContent.offsetHeight < (divScroller.offsetHeight -20) ){
		document.all['ascScrollup'].style.display = 'none';
		document.all['ascScrolldown'].style.display = 'none';
	}
	else {
		
		if (divScroller.scrollTop <= 0){
			void EnableButton(document.all['ascScrollup'], false);
		}
		else {
			void EnableButton(document.all['ascScrollup'], true);
		}		
		
		if ((divScroller.scrollTop + divScroller.offsetHeight) >= tblContent.offsetHeight){
			void EnableButton(document.all['ascScrolldown'], false);
		}
		else {
			void EnableButton(document.all['ascScrolldown'], true);
		}		
	}
}

//----------------------------------------------------------------------------------------------
function PageUp(){
//Scroll the content window 1 page upwards
	divScroller.scrollTop = divScroller.scrollTop - divScroller.offsetHeight - 150;
	EnableButtons();	
}
//----------------------------------------------------------------------------------------------
function PageDown(){
//Scroll the content window 1 page downwards
	divScroller.scrollTop = divScroller.scrollTop + divScroller.offsetHeight  - 150;
	EnableButtons();
}
//----------------------------------------------------------------------------------------------
</script>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>
<body class="Touchscreen Picklist" onload="document.body.style.cursor = 'default';<%= strOnload %>" style="overflow:auto" >

<table style="height:100%; width:100%">
	<tr>
		<td class="Toolbar" colspan="2">	
			<table cellpadding="0" cellspacing="0">
				<tr>
					<td style="padding-left:<%= BUTTON_SPACING %>">
<%
    'Script the "back to list" button.
    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/List.gif", "Back to Episode List", "BackToEpisodeList()", true)
%>

					</td>
					<td style="padding-left:<%= BUTTON_SPACING %>">
<%
    'Script the "regenerate list" button
    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/PickListRegenerate.gif", "RegenerateList", "Regenerate()", true)
%>

					</td>
				</tr>
			</table>
		</td>
	</tr>

	<tr>
		<td style="height:100%" valign="top">		
			<div id="divScroller" style="height:100%;overflow-y:hidden" >
<%
    If Not blnShowWaitingPage Then 
%>

		
			<table id="tblContent" cellpadding='0' cellspacing='0'>

<%
            'Debug
            'List the doses we're fulfilling so we can check the code!
        If DEBUG_MODE Then 
%>

		<tr class='SectionTitle'>
			<td colspan="4">Doses to be fullfilled:</td>
		</tr>
<%
    colDoses = domDoses.SelectNodes("//" & NODE_ADMINREQUEST)
    For Each xmlDose In colDoses
%>
			<tr>
				<td ><%=xmlDose.Attributes("RequestID").Value%></td>
				<td colspan="3"><%=xmlDose.Attributes("Description").Value%></td>
			</tr>
<%
            Next
        End IF
%>
	<tr>
		<td class="Prompt" colspan="3">Shown below is a list of all the drugs that will be needed on for this administration round.  
		To use this as a checklist, simply press the boxes on the left to tick each line off.  (This will be remembered if you log off.)
		</td>
	</tr>
<%
    WriteDosesWithNoDrugs(sessionId, domDoses)
    WriteDrugs(sessionId, domDrugs, STOCKLOCATION_WARDSTOCK, "Ward Stock Items", TEXT_WARDSTOCK)
    WriteDrugs(sessionId, domDrugs, STOCKLOCATION_DISPENSED, "Drugs Dispensed", TEXT_DISPENSED)
    WriteDrugs(sessionId, domDrugs, STOCKLOCATION_PHARMACY, "Non Ward Stock Items", TEXT_PHARMACY)
%>
				
			</table>
		</div>
	</td>
	<td>
			<table style="height:100%">
				<tr>
					<td valign="top" >
<%
        TouchscreenShared.ScrollButtonUp("PageUp()", true)
%>

					</td>
				</tr>
				<tr><td>&nbsp;</td></tr>
				<tr>
					<td valign="bottom" >
<%
        TouchscreenShared.ScrollButtonDown("PageDown()", true)
%>

					</td>
				</tr>
			</table>
<%
    Else
%>
		<table style="height:100%;width:100%">
			<tr><td style="height:100%; width:100%; text-align:center;" >
				<table class="StatusIndicator" nodisable='true'>
					<tr><td style='text-align:center;'>
						<h1>Compiling List of Medications</h1>
						<h2>This may take a few moments, please be patient.</h2>
						<div>
							<img nodisable='true' style="width:64px;height:64px;" src="../../images/ocs/HourglassWait.gif" />
						</div>
					</td></tr>
				</table>
			</td></tr>
		</table>
<%
    'Show a waiting page while we're generating the list
    End IF
%>
		</td>
	</tr>
</table>
</body>
</html>
