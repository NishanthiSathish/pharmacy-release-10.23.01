<%@ Page language="vb" %>
<%
    Dim strTitle As String 
    Dim strButtons As String 
    Dim lngPos As Integer 
    Dim strButtonText As String 
%>
<%
    'ICWConfirm.aspx
    '
    '27Sep06 PH
    '
    'Replacement Confirmation Dialog page, for the JScript "Confirm" function.
    'To use this page, call ICWConfirm(strText, strTitle, strFeatures) in icwfunctions.js
    strTitle = CStr(Request.QueryString("title"))
    strButtons = Trim(Request.QueryString("buttons")) & ","
%>


<html>

<head>
	<title><%= strTitle %></title>
	<link href="../../style/application.css" rel="stylesheet">
	
<script>

function body_onload()
{
	//Insert the text as soon as we've loaded
	var strText = window.dialogArguments;
			
	document.getElementById("divMsg").innerText = strText;
				
	// Set focus to last button						
	for (intIndex=0; intIndex < document.getElementById("tdButtons").childNodes.length; intIndex++)
	{
		ele = document.getElementById("tdButtons").childNodes[intIndex];
		if ( ele.nodeName == "BUTTON" )
		{
			ele.focus();
		}
	}
}
	
function button_click(btn)
{
	strSelectedText = btn.innerText;
	window.returnValue = strSelectedText;
	window.close();
}
	
</script>

</head>
	
<body onload="body_onload()">
	<table width="100%" height="100%">
		<tr>
			<td align="center">
				<div id="divMsg"></div>
			</td>
		</tr>
		<tr height="1%">
			<td id="tdButtons" align="right">
<%
    If strButtons <> "," Then 
        Do 
            lngPos = InStr(1, strButtons, ",")
            strButtonText = Left(strButtons, lngPos - 1)
%>

					<button onclick='button_click(this)'><%= strButtonText %></button>&nbsp;
<%
            strButtons = Mid(strButtons, lngPos + 1)
        Loop While strButtons <> ""
    End IF
%>

			</td>
		</tr>
	</table>
</body>
	
</html>
