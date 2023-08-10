<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.RoutineSearch" %>
<%@ Import Namespace="Ascribe.Common.OCSStatusMessage" %>

<!--
								RoutineSearch.aspx
						
	Purpose:	Renders a search page for a given Routine Name.
				A search parameters is drawn for each input parameter the routine has.
				
	Inputs:	RoutineName		
			||				-	Name or ID of the routine to display the search page for.
			RoutineID
			
			ResultFormat	-	OCSGRid | Raw
				
				Default values for parameters can be provided on the query string
				The query string parameter name must match a routine parameter name.
				Routine parameters that have default values are hidden from display,
				but their values are still passed through to the routine when search
				is executed.
				
	History:	
	01Jan03	PH	Created
	07Jul03	PH	Added default/hidden parameter code
	07Apr04  AE Moved much vb and js script into shared files RoutineSearch.vb/js, for
					use in LookupSearch.aspx.
	07Oct04  PH Added option to format for OCSGrid, or to leave raw
	12Oct06 AE  Corrected previous uncommented mod that removed all functioning by routineID.  Now deals with both name and ID as before.
	27Jun11 Rams (F0117256 - Ward and consultant lookup)
				
-->

<script type="text/javascript" src="../sharedscripts/ocs/statusmessage.js"></script>

<%
    Dim lngSessionID As Integer
    Dim lngRoutineID As Integer 
    Dim strRoutineName As String 
    Dim strResultFormat As String 
    Dim objRoutineRead As ICWRTL10.RoutineRead
    Dim strRoutine_XML As String = String.Empty
    Dim strQueryResult_XML As String = String.Empty
    Dim strURL As String 
    Dim strErr As String = String.Empty
%>
<%
    lngSessionID = CInt(Request.QueryString("SessionID"))
    lngRoutineID = Generic.CIntX(Request.QueryString("RoutineID"))
    strRoutineName = CStr(Request.QueryString("RoutineName"))
    strResultFormat = CStr(Request.QueryString("ResultFormat"))
    If strResultFormat = "" Then 
        strResultFormat = "OCSGrid"
    End IF
%>


<html>
<head>
<title>Routine Execute</title>
<script src="../sharedscripts/ICWFunctions.js"></script>
<script src="../sharedscripts/Controls.js"></script>
<script src="Script/RoutineSearch.js"></script>
<script ID=clientEventHandlersJS language=javascript>
<!--

function window_onload()
{
	// Send SearchResult() event to parent window
<%
    If Request.Form("txtSearch") <> "" Then 
%>

	if ( (document.all("txtResult").innerText)=="<root></root>" )
	{
		document.all("spnMsg").innerText = "No matches found.";
	}
	window.parent.SearchResult( document.all("txtResult").value );
<%
    End IF
%>
	

	SetSearchButtonState();
}


//-->
</script>
<link rel="stylesheet" type="text/css" href="../../style/application.css" />

</head>
<xml id=xmlLookup></xml>
<body onkeyup="body_onkeyup()" onselectstart="event.returnValue=false" oncontextmenu="return false" id='bdy' onload="return window_onload()"
onkeypress="if (window.event.keyCode == 27) window.parent.btnCancel_onclick(); ">



<input type="hidden" id=txtSessionID name=txtSessionID value="<%
    Response.Write(lngSessionID)
%>
">

<!-- <h3><%
    Response.Write(strRoutineName)
%>
</h3> -->

<%
    'Build the URL of this page
    strURL = "RoutineSearch.aspx" & "?SessionID=" & lngSessionID & "&RoutineName=" & strRoutineName
    'Script the controls.  We may have a routine name or ID specified.
    If strRoutineName = "" Then 
        '12Oct06 AE  Corrected previous mod that removed all functioning by routineID.  Now deals with both name and ID as before.
        If lngRoutineID > 0 Then 
            'We have the routine ID
            ScriptInputControlsByRoutineID(lngSessionID, lngRoutineID, strURL, strRoutine_XML, Ascribe.Common.RoutineSearchLayout.Vertical)
        Else
            'No Name or ID specified = fubar.
            Generic.ScriptFailiure("exclamation_red.gif", "Missing Parameter", "Either a RoutineName or RoutineID must be specified", "")
        End IF
    Else
        'We have a name
        ScriptInputControlsByRoutineDescription(lngSessionID, strRoutineName, strURL, strRoutine_XML, Ascribe.Common.RoutineSearchLayout.Vertical)
    End IF
    'Build parameters then Execute Query
    If Request.Form("txtSearch") <> "" Then 
        SearchExecute(lngSessionID, strRoutine_XML, strQueryResult_XML, strErr)
    End IF
    If Len(strQueryResult_XML) > 0 And strResultFormat = "OCSGrid" Then 
        objRoutineRead = new ICWRTL10.RoutineRead()
        strQueryResult_XML = CStr(objRoutineRead.FormatForOCSGrid(lngSessionID, strQueryResult_XML))
        objRoutineRead = Nothing
    End IF
    strQueryResult_XML = Generic.XMLEscape(strQueryResult_XML)
%>


<script >
<!--

function ParentReady()
{
	// Parent page should call this after all pages have loaded, and that the 
	// parent page is ready to receive SearchResult() event.
	if ((document.all['txtParamCount'] != undefined) && Number(document.all['txtParamCount'].value) > 0) {
		document.all("col0").focus();
	}
	else {
		Search();
	}
}

//-->
</SCRIPT>

<%
    Response.Write(strErr)
%>

<input style='display:none' id=txtResult name=txtResult value="<%= strQueryResult_XML %>" >
<%
    ScriptStatusPanel()
%>

</body>
</html>
