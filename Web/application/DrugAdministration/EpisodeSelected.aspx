<%@ Page language="vb" %>

<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Constants" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%
    ' -----------------------------------------------------------------------------------------
    '
    '   EpisodeSelected.aspx
    '   To allow the AdministrationEpisodeList to set context on episode select
    '
    '   Date        Author      TFS         Note
    '   - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    '   06Oct15     CA          131387      Created 
    '
    ' -----------------------------------------------------------------------------------------

    Dim sessionId As Integer
    Dim episodeId as Integer

    sessionId = Integer.Parse(Request.QueryString("SessionID"))

    'Get the selected episodeId from the query string
    episodeId = CIntX(Request.QueryString(DA_EPISODEID))
    If episodeId > 0 Then
        StateSet(sessionId, "Episode", episodeId)
    End If
 %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
</body>
</html>
