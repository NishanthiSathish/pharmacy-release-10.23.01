<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>

<%
    '---------------------------------------------------------------------------------
    '
    'State.aspx
    '
    'Used along with GetKey(session, table) in icwfunctions.js as an AJAX call to 
    'allow you to get the primary key from state for the specified table.
    '
    'Modification History:
    '20May10 ST  Written 
    '--------------------------------------------------------------------------------

    Dim Table As String = Request.QueryString("Table")
    Dim SessionID As Integer = CInt(Request.QueryString("SessionID"))
    Dim StateRead As GENRTL10.StateRead = New GENRTL10.StateRead()
    
    Response.Write(StateRead.GetKey(SessionID, Table))
%>
