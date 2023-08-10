<%@ Page language="vb" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationAdministered.aspx
    '
    'Touchscreen Admin screen.  Shows dose, plus "Was this dose administered, y/n" option.
    '
    '
    'Modification History:
    '31May05 AE  Written
    '
    '----------------------------------------------------------------------------------------------------------------
    Dim sessionId As Integer
    Dim entityId As Integer
    Dim episodeId As Integer
    Dim requestId As Integer
    Dim dom As XmlDocument
    Dim xmlItem As XmlNode
    Dim prescriptionRead As OCSRTL10.PrescriptionRead
    Dim domRx As XmlDocument
    Dim colProducts As XmlNodeList
    Dim xmlProduct As XmlNode
    Dim xmlPrescription As XmlNode
    Dim strPrescriptionXml As String
    Dim strRequestXml As String
    Dim prescriptionId As Integer
    Dim productId As Integer
    Dim routeId As Integer
    Dim strAdminAction As String

    productId = 0
    routeId = 0
    'Read the appropriate state variables
    sessionId = CIntX(Request.QueryString("SessionID"))

    Dim strStillRequiredText As String = SettingGet(sessionId, "OCS", "Prescribing", "StillRequiredAdminText", "Still Required")
    Dim strNoLongerRequiredText As String = SettingGet(sessionId, "OCS", "Prescribing", "NoLongerRequiredAdminText", "No Longer Required")
    Dim blnShowRequiredMessage As Boolean = (SettingGet(sessionId, "OCS", "Prescribing", "DiscontinueDecisionOnOutstandingRequests", "false").ToLower() = "true")
    
    ' Make sure episode id is selected
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId = 0 Then
        Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If
    
    entityId = CIntX(StateGet(sessionId, "Entity"))
    
    'Read / Store the selected Admin Request.  This is passed on the querystring initially,
    'and read from state thereafter
    requestId = CIntX(RetrieveAndStore(sessionId, CStr(DA_REQUESTID)))
    
    'Read the admin request
    strRequestXml = AdminRequestByID(sessionId, requestId)

    dom = New XmlDocument()
    dom.TryLoadXml(strRequestXml)
    xmlItem = dom.SelectSingleNode("root/*")
    
    'Now get the prescription and determine how many products it requires.
    'If it is only a single product prescription, we go straight to the product picker;
    'if it is for multiple products, we show them the list of contained products first (the confirmation screen)
    prescriptionId = CIntX(xmlItem.Attributes("RequestID_Prescription").Value)
    SessionAttributeSet(sessionId, CStr(DA_PRESCRIPTIONID), prescriptionId.ToString())
    'Now read the prescription detail
    prescriptionRead = New OCSRTL10.PrescriptionRead()
    strPrescriptionXml = prescriptionRead.PrescriptionWithProductsXML(sessionId, CIntX(prescriptionId))
    prescriptionRead = Nothing
    '<Prescription RequestID="15360" ProductID="87928" ProductRouteID="59" ScheduleID_Administration="958" PRN="0"
    'StartDate="2005-05-19T00:00:00" ProductRoute="Topical">
    '<Product ProductID="87928" Description="Hydrocortisone Butyrate 0.1% Scalp Lotion" />
    ''
    '</Prescription>
    domRx = New XmlDocument()
    domRx.TryLoadXml(strPrescriptionXml)
    colProducts = domRx.SelectNodes("Prescription/Product")
    If colProducts.Count > 1 Then
        '** Note! Multi Product Infusions to be Implemented **
        strAdminAction = "alert('Multiple-Ingredient Prescriptions cannot currently be administered.');"
    Else
        strAdminAction = "Navigate_DrugEntry()"
        xmlProduct = colProducts(0)
        xmlPrescription = domRx.SelectSingleNode("Prescription")
        productId = CIntX(xmlProduct.Attributes("ProductID").Value)
        routeId = CIntX(xmlPrescription.Attributes("ProductRouteID").Value)
    End If
    'Note that we will have to deal with "either/or" prescriptions (eg paracetamol oral/rectal) here;
    'for now, we are just assuming a single prescription.
%>


<html>
<head>
<title>Drug Administration</title>
<script type="text/javascript" language="javascript" src="../sharedscripts/Touchscreen/Touchscreenshared.js"></script>
<script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
<script type="text/javascript" language="javascript">
//----------------------------------------------------------------------------------------------
function Navigate(strPage) {
//Fires when a button is pressed
    var strUrl = strPage + '?SessionID=<%= sessionId %>';
    void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function RecordNonAdministration(){

//Fires when the "no" button is pressed
//Go to the admin no screen via the reason picker screen
	var strUrl  = 'ArbtextPicker.aspx'
			  + '?SessionID=<%= sessionId %>'
              + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			  + '&' + DA_DESTINATION_URL + '=AdministrationNo.aspx'  
			  + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx'
			  + '&' + DA_ARBTEXTTYPE + '=' + ARBTEXTTYPE_NON_ADMIN_REASON
			  + '&' + DA_PROMPT + '=' + TXT_ENTER_NON_ADMIN_REASON;
	void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function RecordPartialAdministration(){

//Fires when the "no" button is pressed
//Go to the admin no screen via the reason picker screen
	var strUrl  = 'ArbtextPicker.aspx'
			  + '?SessionID=<%= sessionId %>'
              + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			  + '&' + DA_DESTINATION_URL + '=AdministrationYes.aspx'  
			  + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx'
			  + '&' + DA_ARBTEXTTYPE + '=' + ARBTEXTTYPE_PARTIAL_ADMIN_REASON
			  + '&' + DA_PROMPT + '=' + TXT_ENTER_PARTIAL_ADMIN_REASON;
	void TouchNavigate(strUrl);
}

//----------------------------------------------------------------------------------------------
function Navigate_DrugEntry() {
//Fires when the "yes" button is pressed
    var strUrl = 'AdministrationDrugEntry.aspx'
        + '?SessionID=<%= sessionId %>'
            + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&' + DA_PRODUCTID_PRESCRIBED + '=<%= productId %>'
                    + '&' + DA_ROUTEID + '=<%= routeId %>'; //	strURL  = 'AdministrationDateEntry.aspx'
//			  + '?SessionID=<%= sessionId %>'

	void TouchNavigate(strUrl);

}
//----------------------------------------------------------------------------------------------
window.onload = function () { document.body.style.cursor = 'default'; }

</script>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>
<body class="Touchscreen AdminDetails">
<table width="100%" cellpadding="0" cellspacing="0">        
<%
    'Selected Patient details
    PatientBannerByID(sessionId, entityId, episodeId)
%>
<tr>
    <td colspan="2">
        <table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
	<tr>
		<td class="Toolbar" style="padding-left:<%= BUTTON_SPACING %>">					
<%
    'Script the "back to list" button.
    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/DrugChart.gif", "Back to Drug List", "Navigate('AdministrationRequestList.aspx')", True)
%>
		</td>		
		<td class="Toolbar" style="padding-right:<%= BUTTON_SPACING %>" align="center">
<%
    ScriptBanner_AdminRequestCurrent(sessionId, false, entityId)
%>
		</td>
	</tr>
        </table>
	</td>
</tr>
</table>

<table cellpadding="0" cellspacing="<%= BUTTON_SPACING %>" align='center'>	
	<tr>
		<td colspan="3" align="center">
<%
    ScriptButton_AdminRequest(sessionId, xmlItem, false, blnShowRequiredMessage, strStillRequiredText, strNoLongerRequiredText) 
%>
		</td>
	</tr>	
	<tr>
		<td colspan="3" class="Prompt">
		Was this Dose Administered?
		</td>
	</tr>
	
	<tr>
		<td align="left">
<%
    TouchscreenShared.NavButton("../../images/touchscreen/Cross.gif", "No", "RecordNonAdministration()", true)
%>
		</td>
		<td align="center">
<%
    '
    'For partials; go to reason picker page; then onto product picker page, where they can
    'optionally enter any drugs which were used
    'Move arbtextid_reason onto Administration table.
    'Add NotGiven bit
    'Add Partial bit
    '
    'both to Administration table.
    '
    'Remove AdministrationNodeDone table and requesttype
%>

<%
    TouchscreenShared.NavButton("../../images/touchscreen/TickCross.gif", "Partial", "RecordPartialAdministration()", true)
%>
		</td>
		<td align="right">
<%
    TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Yes", strAdminAction, true)
%>
		</td>
	</tr>
</table>
</body>
</html>
