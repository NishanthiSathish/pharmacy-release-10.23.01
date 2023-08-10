<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../../application/SharedScripts/ASPHeader.aspx"-->

<%
    Dim lngSessionID As String 
%>
<%
    'PBSFastRepeatSearchModal.aspx
    '
    'Wrapper for PBSFastRepeatSearch.aspx
    '
    '10May07 ST Created
    lngSessionID = Request.QueryString("SessionID")
%>

<html>
<head>
<title>PBS Fast Repeat Number Search</title>
<head>
<frameset rows=1 cols=1>
	<frame application=yes src="../PBSEntityPanel/PBSFastRepeatSearch.aspx?SessionID=<%= lngSessionID %>">
<frameset>
<html>
