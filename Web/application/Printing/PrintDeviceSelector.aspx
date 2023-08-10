<%@ Page language="vb" %>
<% 
    Response.Buffer = True
    Response.Expires = -1
    Response.CacheControl = "No-cache"
 %>
<%
    Dim sessionId As Integer = CInt(Request.QueryString("SessionID"))
%>

<html>
<head>
<title>Select Printer</title>
<link rel="stylesheet" type="text/css" href="../../style/application.css">
<script src="script/PrintDeviceSelector.js"></script>
</head>
<body onload="return window_onload()" scroll=no>

<table height=100% width=100% >
	<tr height=1%>
		<td>From the list below, select the printer that stationery&nbsp;"<span id="spnMediaTypeDescription"></span>"&nbsp;should be printed to:</td>
	</tr>
	<tr>
		<td>
			<select id="selDevices" style="height:100%;width:100%" size=10 ondblclick="selDevices_dblclick()" onclick="selDevices_onclick()" onchange="return selDevices_onchange()">
			</select>
		</td>
	</tr>
	<tr height=1%>
		<td align=right>
			<button id=btnOK disabled accesskey=O onclick="return btnOK_onclick()"><u>O</u>K</button>
			&nbsp;
			<button id=btnCancel accesskey=C onclick="return btnCancel_onclick()"><u>C</u>ancel</button>
		</td>
	</tr>
</table>

<OBJECT style="display:none" id="HEditAssist" tabindex="0"  
	classid=CLSID:22A94461-82F5-47D5-B001-9A1681C67CAF VIEWASTEXT>
	<PARAM NAME="_ExtentX" VALUE="16113">
	<PARAM NAME="_ExtentY" VALUE="11139"></OBJECT>	
</body>
</html>
