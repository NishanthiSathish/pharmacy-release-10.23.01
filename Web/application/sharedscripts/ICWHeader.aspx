<%@ Page language="vb" %>
<!--#include file="ASPHeader.aspx"-->
<%
    'Can be used, perhaps in a frameset, to just draw the header part of an ICW window
    '07Oct04 PH Created
    
    Dim sessionId As Integer
    sessionId = CInt(Request.QueryString("SessionID"))
%>

<html>
<head>
<link rel="stylesheet" type="text/css" href="../../style/application.css">
</head>
<body>
<%
    Ascribe.Common.ICW.ICWHeader(sessionId)
%>

</body>
</html>
