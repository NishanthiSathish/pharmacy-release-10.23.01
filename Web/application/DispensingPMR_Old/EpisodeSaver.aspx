<%@ Page language="vb" %>
<%
    Dim SessionID As Long 
    Dim lngEpisodeID As Long 
    Dim lngEntityID As Integer 
    Dim objState As Object ' GENRTL10.State
    Dim objEpisodeRead As Object ' ENTRTL10.EpisodeRead
%>
<%
    SessionID = CLng(Request.QueryString("SessionID"))
    lngEpisodeID = CLng(Request.QueryString("EpisodeID"))
    objEpisodeRead = new ENTRTL10.EpisodeRead()
    lngEntityID = objEpisodeRead.EntityIDFromEpisode(CInt(SessionID), CInt(lngEpisodeID))
    objEpisodeRead = Nothing
    objState = new GENRTL10.State()
    On Error Resume Next
    objState.SetKey(CInt(SessionID), "Episode", CInt(lngEpisodeID))
    objState.SetKey(CInt(SessionID), "Entity", lngEntityID)
    objState = Nothing
%>

