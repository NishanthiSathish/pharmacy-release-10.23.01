<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>


<%
    Dim lngSessionID As Integer
    Dim lngRoutineID As Integer 
    Dim lngRoutineTypeID As Integer 
    Dim strColumns_XML As String 
    Dim strRoutines_XML As String 
    Dim objMetaDataRead As ICWDTL10.MetaDataRead
%>
<%
    lngSessionID = CInt(Request.QueryString("SessionID"))
    lngRoutineID = CInt(Request.QueryString("RoutineID"))
    'lngRoutineTypeID = CInt(Request.QueryString("RoutineTypeID"))
    lngRoutineTypeID = 2
    'Only support for user stored procedure routines, so far...
    Ascribe.Common.Security.ValidatePolicy(lngSessionID, "Routine Administration")
%>


<html>
<head>
<title>Routines</title>
<script src="../sharedscripts/Grid.js"></script>
<SCRIPT ID=clientEventHandlersJS LANGUAGE=javascript>
<!--

function window_onload()
{
	CTL_Grid_Draw("grdRoutines");
	var lngRowToSet = FindRowByValue("grdRoutines", 0, document.all("txtRoutineID").value );
	if (lngRowToSet != -1 )
	{
		Grid_MoveCursor("grdRoutines", 0, lngRowToSet);
	}
	if ( Grid_RowCount("grdRoutines") == 0 )
	{
		document.all("btnEdit").disabled = true;
		document.all("btnDelete").disabled = true;
	}
}

function btnEdit_onclick()
{
	window.navigate("RoutineDetail.aspx?CallingPage=ICW_Routine.aspx&SessionID=" + document.all("txtSessionID").value + "&Action=E&RoutineTypeID=" + document.all("txtRoutineTypeID").value + "&RoutineID=" + Grid_GetCellValue("grdRoutines", 1, Grid_CurrentRowIndex("grdRoutines")) );
}

function btnDelete_onclick()
{
	window.navigate("RoutineDetail.aspx?CallingPage=ICW_Routine.aspx&SessionID=" + document.all("txtSessionID").value + "&Action=D&RoutineTypeID=" + document.all("txtRoutineTypeID").value + "&RoutineID=" + Grid_GetCellValue("grdRoutines", 1, Grid_CurrentRowIndex("grdRoutines")) );
}

function btnNew_onclick()
{
	window.navigate("RoutineDetail.aspx?CallingPage=ICW_Routine.aspx&SessionID=" + document.all("txtSessionID").value + "&Action=N&RoutineTypeID=" + document.all("txtRoutineTypeID").value );
}
//-->
</SCRIPT>

<link rel="stylesheet" type="text/css" href="../../style/application.css" />

</head>

<body onselectstart="event.returnValue=false" oncontextmenu="return false" id="body" onload="return window_onload()">

<form action='ICW_Routine.aspx?SessionID=<%= lngSessionID %>' method=POST id=frmroutine name=frmroutine>

<input type="hidden" id=txtSessionID name=txtSessionID value="<%= lngSessionID %>">

<input type="hidden" id=txtRoutineID name=txtRoutineID value="<%= lngRoutineID %>">

<input type="hidden" id=txtRoutineTypeID name=txtRoutineTypeID value="<%= lngRoutineTypeID %>">

<table border=0 height=100% width=100%>
<tr valign="middle">
<td >

<%
    objMetaDataRead = new ICWDTL10.MetaDataRead()
    strRoutines_XML = objMetaDataRead.RoutineListXML(lngSessionID, lngRoutineTypeID)
    objMetaDataRead = Nothing
    strColumns_XML = Grid.CTL_Grid_AddColumn("RoutineID", "RoutineID", 0, false, "", "") & Grid.CTL_Grid_AddColumn("Description", "Description", 0, true, "", "")
    Grid.CTL_Grid("grdRoutines", strColumns_XML, strRoutines_XML, "100%", "100%", "Routines", false, "../../images/grid/routine.gif")
%>


</td>

<td></td>
<td width=100 align=center>
<div><button id="btnNew" name="btnNew" LANGUAGE=javascript onclick="return btnNew_onclick()" accesskey=N><u>N</u>ew</button></div>
<br>
<div><button id="btnEdit" name="btnEdit" LANGUAGE=javascript onclick="return btnEdit_onclick()" accesskey=E><u>E</u>dit</button></div>
<br>
<div><button id="btnDelete" name="btnDelete" LANGUAGE=javascript onclick="return btnDelete_onclick()" accesskey=D><u>D</u>elete</button></div>
</td>

</tr>
</table>

</form>

</body>
</html>
