<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>

<%
    Dim SessionID As Integer
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'OCSReportControl.aspx
    '
    'Use this page to Print OCSReports.
    '
    'It is recommended that you host this page as a hidden IFrame inside a parent
    'page. The parent page should handle the displaying of print progress to the
    'user.
    '
    'This page acts as a container for OCSReportLoader.aspx and PrintControl.aspx,
    'which allows.
    '
    '12Mar03 PH 	Created
	'18Jan11 Rams	F0106461 - When issue FP10 or FP10MDA, there are no alert box which specify the batch number
    SessionID = Integer.Parse(Request.QueryString("SessionID"))
%>


<html>
<head>
<link rel="stylesheet" type="text/css" href="../../style/application.css">

<script src="script/OCSReportControl.js"></script>
<script src="../sharedscripts/icwfunctions.js"></script>

</head>
<body id="body" SessionID="<%= SessionID %>" onselectstart="event.returnValue=false" oncontextmenu="return false" scroll='no' onload="return window_onload()">

<object style="display:none" id="HEditAssist" tabindex="0" 
	classid=CLSID:22A94461-82F5-47D5-B001-9A1681C67CAF VIEWASTEXT>
	<PARAM NAME="_ExtentX" VALUE="16113">
	<PARAM NAME="_ExtentY" VALUE="11139"></OBJECT>

<iframe frameborder=1 application=yes style="height:100%" width="100%" id='fraPrintControl' src='../Printing/PrintControl.aspx?SessionID=<%= SessionID %>' ></iframe>
<iframe frameborder=1 application=yes style="height:33%" width="100%" id="fraOCSReportLoader" ></iframe>
<iframe frameborder=1 application=yes style="height:33%" width="100%" id='fraPrintDeviceSaver' src='../Printing/PrintDeviceSaver.aspx?SessionID=<%= SessionID %>'></iframe>

</body>
</html>
