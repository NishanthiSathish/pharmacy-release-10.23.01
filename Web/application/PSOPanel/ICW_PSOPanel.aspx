<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../SharedScripts/ASPHeader.aspx"-->

<%
    Dim objSetting As Object 
    Dim objStateRead As Object 
    Dim lngSessionID As Long 
    Dim lngDispensingID As Long 
    Dim strSelectEpisode As Object 
    Dim strFieldStyle As String 
    Dim m_intPSOFieldCount As Integer 
    Dim objRoutineRead As Object ' ICWRTL10.RoutineRead
    Dim xmlEpisode As Object 
    Dim xmlDoc As XmlDocument       ' As Object Removed MSXML2
    Dim xmlNodeList As XmlNodeList  ' As Object Removed MSXML2
    Dim xmlElement As XmlElement    ' As Object Removed MSXML2
    Dim xmlAttrib As XmlAttribute   ' As Object Removed MSXML2
    Dim strParams_XML As Object 
    Dim xmlret As Object 
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'ICW_PSOPanel.aspx
    '
    'Displays PSO information . 
    'The DispensingID is passed into the "PSO Panel" Routine that fires a user-
    'defined query, which returns the column names and values to be displayed.
    'The column names are used as "caption titles" for the column values.
    '
    'QueryString Parameters
    'SessionID				- SessionID
    '
    '
    'Modification History:
    '22Nov12 TH Written from Entity/Episode panel for PSO Dispensing details Panel (TFs 40930)
    '30Nov12 TH Changed stylesheet from PBSEntityPanel to EntityPanel (TFS 50502)
    '20Aug13 XN Removed MSXML2
%>

<%
    'Dim blnAllowEpisodeSelection
    'dim strEpisodeTitle
    'Dim m_intEpisodeFieldCount
    strFieldStyle = UCase(Trim(ICW.ICWParameter("FieldStyle", "Fields are drawin in either columns across the screen or rows down the screen", "Columns,Rows")))
    lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    lngDispensingID = Generic.CLngX(Request.QueryString("DispensingID"))
%>


<html>
<head>
<title>PSO Order Details</title>
<script src="../sharedscripts/icw.js"></script>
<script src="../SharedScripts/Menu.js"></script>
<script src="script/PSOPanel.js"></script>
<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/EntityPanel.css" />

</head>

<body id=bdy 
		SessionID="<%= lngSessionID %>" 
		lngDispensingID="<%= lngDispensingID %>" 
		FieldStyle="<%= strFieldStyle %>"
		scroll="no" 
		onload="return window_onload()"
>

<%
    If lngDispensingID > 0 Then 
%>


	<table width="100%" height=100% cellpadding="0" cellspacing="0">
		<tr valign=top>
			<td width=100%>
				<!-- Patient Detail Area -->
				<table width="100%" height="100%">	
					<tr height="1%">
						<td>
<%
        ICW.ICWHeader(lngSessionID)
%>

						</td>
					</tr>
					<tr>
						<td id="tdPSOPanel" class="PanelBackground">
							<div style="overflow-y:auto;width:100%;height:100%">
<%
        'Read the entitys details
        xmlDoc = new XmlDocument()  ' new MSXML2.DOMDocument() Removed MSXML2
        objRoutineRead = new ICWRTL10.RoutineRead()
        strParams_XML = objRoutineRead.CreateParameter("DispensingID", 2, 4, lngDispensingID)
        xmlret = objRoutineRead.ExecuteByDescription(lngSessionID, "PSO Order Panel", strParams_XML)
        xmlDoc.loadXML(CStr(xmlret))
        objRoutineRead = Nothing
        xmlNodeList = xmlDoc.selectNodes("//*")
        m_intPSOFieldCount = 0
        For Each xmlElement In xmlNodeList
            For Each xmlAttrib In xmlElement.attributes
%>
<span id="divPSO<%= m_intPSOFieldCount %>" style="visibility: hidden" nowrap>
<span id="spnPSOCaption<%= m_intPSOFieldCount %>" class="caption" >&nbsp;<%= replace(Trim(xmlAttrib.Name), " ", "&nbsp;") %>:&nbsp;</span>
<span id="spnPSOText<%= m_intPSOFieldCount %>" class="text" style="visibility: visible">&nbsp;<%= replace(Trim(xmlAttrib.Value), " ", "&nbsp;") %>&nbsp;</span>
</span>
<br id="br<%= m_intPSOFieldCount %>">
<%
                m_intPSOFieldCount = m_intPSOFieldCount + 1
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

	<input type="hidden" id=txtPSOFieldCount value="<%= m_intPSOFieldCount %>">

	

<%
    Else
%>

	<table width="100%" height="100%">
		<tr height="1%">
			<td>
<%
        ICW.ICWHeader(lngSessionID)
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
