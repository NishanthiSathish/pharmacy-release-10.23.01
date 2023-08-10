<%@ Page language="vb" %>
<%
	Dim RoutineXML As String = Session("RoutineXML").ToString
	Session.Remove("RoutineXML")
	Response.ContentType() = "text/xml"
	Response.Write(RoutineXML)
	Response.End()
%>
