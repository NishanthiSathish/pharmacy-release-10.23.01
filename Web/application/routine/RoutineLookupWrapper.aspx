<%@ Page language="vb" %>
<%
    Dim sessionId As Integer = CInt(Request.QueryString("SessionID"))
%>


<%--    Modification History
        ====================
    27Jun11 Rams    (F0117256 - Ward and consultant lookup)

--%>

<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionId %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "RoutineLookupWrapper.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

<html>
<head>
<title>Lookup</title>
</head>
<body onselectstart="event.returnValue=false" oncontextmenu="return false" scroll="no">
<iframe application=yes border=0 style="position: absolute; left: 0; top: 0;" width=100% height=100% src='RoutineLookup.aspx?<%=Request.QueryString().Tostring()%>' ></iframe>
<iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
