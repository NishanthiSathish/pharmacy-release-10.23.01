<%@ Page language="vb" aspcompat = true %>
<%@ Import namespace="Ascribe.Xml" %>
<%@ Import Namespace="System.Xml" %>
<%
    '27Jun11    Rams    (F0117256 - Ward and consultant lookup) 
    
    Dim sessionId As Integer
    Dim strRoutineName As String 
    Dim objRoutineRead As ICWRTL10.RoutineRead
    Dim objMetaDataRead As ICWDTL10.MetaDataRead
    Dim strRoutineXml As String 
    Dim xmlDoc As XmlDocument
    Dim xmlNodeList As XmlNodeList
    Dim strSearchFrameHeight As String 
    Dim lngRoutineId As Integer
    Dim lngParamCount As Integer
    Dim optionsEnabled As Boolean = False

    sessionId = CInt(Request.QueryString("SessionID"))

    strRoutineName = Request.QueryString("RoutineName")
    '28Jun11    Rams    F0121628 - v10.5.6.9 - Template lookup causing an error when using.
    optionsEnabled = String.Compare(Request.QueryString("Options"), "True", True) = 0
%>
<html>
<head>
<script language="javascript" type="text/javascript" ID=clientEventHandlersJS>
<!--
function window_onload()
{
	window.frames("fraRoutineSearch").ParentReady();
}

function Clear()
{
	window.frames['fraGrid'].navigate("routinegrid.aspx?SessionID="+document.all("bdy").getAttribute("SessionID"));
}

function btnSelect_onclick() {
    // 22.06.09 AKnox - Added check to ensure a row in the grid has
    // been selected before returning back to the parent window and closing
    // in addition to defaulting the select button to be disabled
	if (window.frames('fraGrid').RowCount()>0 )
	{
	    window.parent.returnValue = window.frames('fraGrid').GetCurrentRowXML().xml;
	    window.close();
	}
	else
	{
	    alert("There are no items to select");
	    return false;
	}
    return true;
}

function btnCancel_onclick()
{
	window.parent.returnValue = undefined;
	window.close();
}

function ItemSelected()
{
	document.all("btnSelect").disabled = false;
}

function SearchResult(strXml)
{
	document.all("btnSelect").disabled = true;
	if (strXml != "")
	{																									//02Apr03 AE  Modified to use post method rather than inserting data client-side
		//Submit the xml to the episodegrid page in a form
		window.frames['fraGrid'].document.all['gridXML'].value = strXml;
		window.frames['fraGrid'].document.all['RoutineName'].value = "<%= strRoutineName %>";
		document.frames['fraGrid'].frmData.submit();
	}
}

//-->
</script>
<link rel="stylesheet" type="text/css" href="../../style/application.css" />
</head>

<%
    objRoutineRead = New ICWRTL10.RoutineRead()
    lngRoutineId = objRoutineRead.DescriptionToID(sessionId, strRoutineName)
    objRoutineRead = Nothing
    objMetaDataRead = new ICWDTL10.MetaDataRead()
    strRoutineXml = objMetaDataRead.RoutineXML(sessionId, CInt(lngRoutineId))
    objMetaDataRead = Nothing
    xmlDoc = New XmlDocument()
    xmlDoc.TryLoadXml(strRoutineXml)
    xmlNodeList = xmlDoc.SelectNodes("//RoutineParameter")
    lngParamCount = xmlNodeList.Count()
    xmlNodeList = Nothing
    xmlDoc = Nothing
    Select Case (lngParamCount)
    Case 0
        strSearchFrameHeight = "1px"
    Case 1
            strSearchFrameHeight = "80px"
    Case Else
        strSearchFrameHeight = "40%"
    End Select
%>


<body SessionID="<%= sessionId %>" onselectstart="event.returnValue=false" oncontextmenu="return false" id="bdy" scroll="no" onload="return window_onload()" GetReturnValue="<%= optionsEnabled.Tostring().ToLower() %>">

<table border="0" height="100%" width="100%">
	<tr style="height:<%= strSearchFrameHeight %>;" id='trSearch'>
	    <td>
	        <iframe application="yes" border="0" id="fraRoutineSearch" width="100%" height="100%" src="routinesearch.aspx?SessionID=<%Response.Write(sessionId)%>&RoutineName=<%Response.Write(strRoutineName)%>"></iframe>
	    </td>
	</tr>
	<tr>
	    <td>
	        <iframe application="yes" border="0" id="fraGrid" width="100%" height="100%" src="routinegrid.aspx?SessionID=<%Response.Write(sessionId)%>&RoutineName=<%= strRoutineName %>"></iframe>
        </td>
	</tr>
	<tr style="height:24px;">
	    <td>
	        <button id="btnSelect" style="width:48px;" onclick="return btnSelect_onclick();" disabled="true" accesskey=S><u>S</u>elect</button>&nbsp;<button id="btnCancel" style="width:48px" onclick="return btnCancel_onclick();" accesskey=C><u>C</u>ancel</button>
	    </td>
	</tr>
</table>
</body>
</html>
