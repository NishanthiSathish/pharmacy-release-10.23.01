<%@ Page language="vb" %>
<% 
    Response.Buffer = True
    Response.Expires = -1
    Response.CacheControl = "No-cache"
 %>
<%
    Dim lngSessionID As Integer 
%>
<%
    lngSessionID = 449
%>

<html>
<head>
<script>
<!--

function ReadyToPrint()
{
	// "Event" which is raised by OCSReportControl.aspx

	var lngRequestTypeID = 5;
	var lngResponseTypeID = 0;
	var lngNoteTypeID = 0;
	var lngTableID = 444;
	var lngOrderReportTypeID = 2;
	var lngPrimaryKey = 6
	var blnPreview = true;

	fraOCSReportControl.PrintOCSReports(
															lngRequestTypeID
														,	lngResponseTypeID
														,	lngNoteTypeID
														,	lngTableID
														,	lngOrderReportTypeID
														,	lngPrimaryKey
														,	blnPreview
													);

}

function OCSReportsPrinted()
{
	divProgress.innerText = "OCS Reports Printed";
	window.close();
}

function DocumentPrinted(strReportName, strDeviceName)
{
	divProgress.innerText = "Printed " + strReportName + " to " + strDeviceName;
}

function DocumentPrinting(strReportName, strDeviceName)
{
	divProgress.innerText = "Printing: " + strReportName + " to " + strDeviceName;
}

function PrintCancelled()
{
	alert("Print Cancelled");
	window.close();
}

//-->
</script>
</head>
<body onselectstart="event.returnValue=false" oncontextmenu="return false" >

<table height=100% width=100%>
	<tr height=1%>
		<td>
		    <div id='divProgress'/>
		</td>
	</tr>
	<tr>
		<td>
			<iframe application=yes id='fraOCSReportControl' src='../Printing/OCSReportControl.aspx?SessionID=<%= lngSessionID %>' width='100%' height='100%'></iframe>
		</td>
	</tr>
</table>

</body>
</html>
