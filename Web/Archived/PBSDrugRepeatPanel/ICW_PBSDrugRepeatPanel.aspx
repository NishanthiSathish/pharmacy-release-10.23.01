<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../../application/SharedScripts/ASPHeader.aspx"-->

<%
    Dim objSetting As Object 
    Dim objStateRead As Object 
    Dim lngSessionID As Long 
    Dim lngPrescriptionID As Long 
    Dim strSelectEpisode As Object 
    Dim strFieldStyle As String 
    Dim m_intPBSDrugRepeatFieldCount As Integer 
    Dim objRoutineRead As Object ' ICWRTL10.RoutineRead
    Dim xmlEpisode As Object 
    Dim xmlDoc As XmlDocument       ' As Object MSXML2 Removal
    Dim xmlNodeList As XmlNodeList  ' As Object MSXML2 Removal
    Dim xmlElement As XmlElement    ' As Object MSXML2 Removal
    Dim xmlAttrib As XmlAttribute   ' As Object MSXML2 Removal
    Dim strParams_XML As Object 
    Dim xmlret As Object 
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'ICW_PBSEntityPanel.aspx
    '
    'Displays PBSPatient information . The entity to be
    'displayed is determined by querying the State table to get an EpisodeID. The
    'EpisodeID is then passed into the "Entity Panel" Routine that fire a user-
    'defined query, which returns the column names and values to be displayed.
    'The column names are used as "caption titles" for the column values.
    '
    'QueryString Parameters
    'SessionID				- SessionID
    '
    '
    'Modification History:
    '24Apr07 TH Written from Entity/Episode panel
    '20Aug13 XN Removed MSXML2
%>

<%
    'Dim blnAllowEpisodeSelection
    'dim strEpisodeTitle
    'Dim m_intEpisodeFieldCount
    strFieldStyle = UCase(Trim(ICW.ICWParameter("FieldStyle", "Fields are drawin in either columns across the screen or rows down the screen", "Columns,Rows")))
    lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    lngPrescriptionID = Generic.CLngX(Request.QueryString("PrescriptionID"))
%>


<html>
<head>
<title>PBS Prescription Details</title>
<script src="../sharedscripts/icw.js"></script>
<script src="../SharedScripts/Menu.js"></script>
<script src="script/PBSDrugRepeatPanel.js"></script>

<script >
<!--

//===============================================================================
//									ICW ToolMenus
//===============================================================================






//===============================================================================
//									ICW EventListeners
//===============================================================================

function EVENT_Prescription_info(RequestID_Prescription)
{
// Listens for "EpisodeSelected" events, and refreshes the page if one occurs. 
// 28Jan04 AE Added SelectEpisode to parameter list
// 05May04 PH Added EpisodeTitle & FieldStyle

	//alert(RequestID_Prescription);
	var strURL = '../PBSDrugRepeatPanel/ICW_PBSDrugRepeatPanel.aspx'
				  + '?SessionID=<%= lngSessionID %>'
				  + '&PrescriptionID=' + RequestID_Prescription
				  + '&FieldStyle=<%= strFieldStyle %>';
				  
	//alert(strURL );
	//alert(RequestID_Dispensing);
	window.navigate(ICWURL(strURL));
}

//-->
</script>

<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/PBSPatientPanel.css" />

</head>

<body id=bdy 
		SessionID="<%= lngSessionID %>" 
		lngPrescriptionID="<%= lngPrescriptionID %>" 
		FieldStyle="<%= strFieldStyle %>"
		scroll="no" 
		onload="return window_onload()"
>

<%
    If lngPrescriptionID > 0 Then 
%>


	<table width="100%" height=100% cellpadding="0" cellspacing="0">
		<tr valign=top>
			<td width=100%>
				<!-- Patient Detail Area -->
				<table width="100%" height="100%">	
					<tr height="1%">
						<td>
<%
    'ICW.ICWHeader()
%>

						</td>
					</tr>
					<tr>
						<td id="tdPBSDrugRepeatPanel" class="PanelBackground">
							<div style="overflow-y:auto;width:100%;height:100%">
<%
        'Read the entitys details
        xmlDoc = new XmlDocument()  ' new MSXML2.DOMDocument() MSXML2 Removal
        objRoutineRead = new ICWRTL10.RoutineRead()
        strParams_XML = objRoutineRead.CreateParameter("PrescriptionID", 2, 4, lngPrescriptionID)
        xmlret = objRoutineRead.ExecuteByDescription(lngSessionID, "PBS Drug Repeat Panel", strParams_XML)
        xmlDoc.loadXML(CStr(xmlret))
        objRoutineRead = Nothing
        xmlNodeList = xmlDoc.selectNodes("//*")
        m_intPBSDrugRepeatFieldCount = 0
        For Each xmlElement In xmlNodeList
            For Each xmlAttrib In xmlElement.attributes
%>
<span id="divPBSDrugRepeat<%= m_intPBSDrugRepeatFieldCount %>" style="visibility: hidden" nowrap><span id="spnPBSDrugRepeatCaption<%= m_intPBSDrugRepeatFieldCount %>" class="caption">&nbsp;<%= Replace(Trim(xmlAttrib.Name), " ", "&nbsp;") %>:&nbsp;</span><span id="spnPBSDrugRepeatText<%= m_intPBSDrugRepeatFieldCount %>" class="text">&nbsp;<%= Replace(Trim(xmlAttrib.Value), " ", "&nbsp;") %>&nbsp;</span></span><br id="br<%= m_intPBSDrugRepeatFieldCount %>"><%
                m_intPBSDrugRepeatFieldCount = m_intPBSDrugRepeatFieldCount + 1
            Next
        Next
        xmlElement = Nothing
        xmlNodeList = Nothing
        xmlDoc = Nothing
%>

							</div>
						</td>
					</tr>

				</table>
			</td>
			
		</tr>
	</table>

	<input type="hidden" id=txtPBSDrugRepeatFieldCount value="<%= m_intPBSDrugRepeatFieldCount %>">

	

<%
    Else
%>

	<table width="100%" height="100%">
		<tr height="1%">
			<td>
<%
    'ICW.ICWHeader()
%>

			</td>
		</tr>
		<tr valign=center>
			<td align=center>
				
			</td>
		<tr>
	</table>
<%
    End IF
%>


</body>
</html>
