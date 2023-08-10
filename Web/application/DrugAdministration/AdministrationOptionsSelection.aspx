<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationOptionsSelection.aspx
    '
    'Touchscreen Admin application.
    '
    'Will display all the items in the selected options order set in same manner as AdministrationRequestList.aspx.
    '
    'Results are paged onto the screen; if there are too many to fit on the screen, back and next buttons
    'allow the user to page through the results.
    '
    'Modification History:
    '05JanCD plagiarized from AdministrationRequestList
    '
    '----------------------------------------------------------------------------------------------------------------
    Dim referingUrl As String = "AdministrationRequestList.aspx"
    Dim sessionId As Integer = Integer.Parse(Request.QueryString("SessionID"))
    Dim windowHeight As Integer = Integer.Parse(Generic.RetrieveAndStore(sessionId, CStr(DA_HEIGHT)))
    Dim windowWidth As Integer = Integer.Parse(Generic.RetrieveAndStore(sessionId, CStr(DA_WIDTH)))
    Dim adminRequestId As Integer = Integer.Parse(Request.QueryString("AdminRequestID"))
    Dim prescriptionId As Integer = Integer.Parse(Request.QueryString("PrescriptionID"))
    Dim OverrideAdmin As Boolean = Not String.IsNullOrEmpty(Request.QueryString("OverrideAdmin")) AndAlso Request.QueryString("OverrideAdmin") = "1"
	Dim entityId As Integer = StateGet(sessionId, "Entity")
	Dim episodeId As Integer = StateGet(sessionId, "Episode")

    Dim intHeight As Integer
    Dim strRequestXml As String
    'Get an admin request type list for the options order set

    strRequestXml = AdminRequestListOptionsByID(sessionId, prescriptionId, entityId, adminRequestId)
    'And the patient details
    'strPatient_XML = PatientByID(SessionID, EntityID)
    'Sort out the height we have to fill with buttons
    intHeight = windowHeight - CIntX(TouchscreenShared.BUTTON_STANDARD_HEIGHT) - (4 * CIntX(BUTTON_SPACING))
%>
<html>
<head>
<title>Drug Administration</title>
<script type="text/javascript" language="javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
<script type="text/javascript" language="javascript" src='../sharedscripts/icwFunctions.js'></script>
<script type="text/javascript" language="javascript" src='scripts/DrugAdministrationConstants.js'></script>
<script type="text/javascript" language="javascript">

    function Administer(objSrc)
    {
        var blnOverrideAdmin = <%= OverrideAdmin.ToString().ToLower() %>;
        var strURL = 'AdministrationDSSCheck.aspx?SessionID=<%= sessionId %>'
	                + '&' + DA_REQUESTID + '=<%= adminRequestId %>'
	                + '&' + DA_PRESCRIPTIONID + '=' + objSrc.getAttribute('prescriptionid')
	                + '&Continuous=' + objSrc.getAttribute('continuousinfusion')
	                + '&IsGenericTemplate=' + objSrc.getAttribute('isgenerictemplate')
	                + '&OptionSelected=1';

        if (blnOverrideAdmin)
        {
            strURL = strURL + '&OverrideAdmin=1';
        }

        strURL = strURL + '&' + DA_MODE + '=select';
        void TouchNavigate(strURL);    
    }

    //----------------------------------------------------------------------------------------------

    function Navigate(strPage)
    {
        //Fires when a button is pressed
        var strUrl = strPage + '?SessionID=<%= sessionId %>';
        void TouchNavigate(strUrl);
    }
    
window.onload = function () { document.body.style.cursor = 'default'; }
</script>

<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />

</head>
<body class="Touchscreen RequestList">
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
                            TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/DrugChart.gif", "Back", "Navigate('" & referingUrl & "')", True)
                        %>
        		    </td>		
	            </tr>
            </table>
	    </td>
    </tr>
</table>    
<table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
<%
    'Script the list O' admin requests, if there is one.
    If CStr(strRequestXml) <> "" Then 
%>
	<tr>
		<td class="Prompt">Please select the route by which the dose is to be administered:</td>
	</tr>
	<tr>
		<td valign="top" colspan='2'><%
        
        ScriptButtonPage(sessionId, TYPE_ADMINREQUEST, strRequestXml, intHeight, windowWidth)
%>
        </td>
	</tr>
<%
    Else
%>
			<tr>
				<td align="center" colspan='2' class="Prompt" style="height:100%;">Nothing to be administered for this patient</td>
			</tr>
<%
    End IF
%>
</table>
<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>
</body>
</html>
