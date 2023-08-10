<%@ Page language="vb" %>
<!--#include file="ASPHeader.aspx"-->
<%
    'CloseWindow.aspx
    '
    'Provides a right aligned close button with a call to parent.close() on clicking
    'the button. This page can be used within a frame (frame or iframe) on your
    'main page and simply scripts a right aligned Close button. Ideal for any
    'information style web pages
    '
    '22Oct DB Written
    '--------------------------------------------------------------------------------
%>

<html>
<head>
<link href="../../style/application.css" rel="stylesheet">

<script language="javascript">
<!--
function cmdClose_onclick()
{
	parent.close();
}
//-->
</script>

</head>
<body oncontextmenu="return false" onselectstart="return false">

<table width="100%">
	<tr>
		<td align="right">
			<button id="cmdClose" onclick="cmdClose_onclick()" AccessKey="C"><U>C</U>lose</button>
		</td>
	</tr>
</table>

</body>
</html>
