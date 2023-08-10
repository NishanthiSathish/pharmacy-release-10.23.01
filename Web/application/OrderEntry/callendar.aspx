<%@ Page language="vb" %>
<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>
<HTML>
<HEAD>



</HEAD>

<BODY>

<%
    Dim strSchedule_XML As String 
%>
<%
    '----------------------------------Server Script ----------------------------------------
    'Here we retrieve the data from the FORM which has been submitted to this page.
    'The XML from the scheduler (in this case the CallendarTestbed.aspx) is contained in
    'a control called txtXML
    'Read the xml from the form
    strSchedule_XML = Request.Form("txtXML")
    'write it to the client.
    Response.Write(strSchedule_XML)
%>





</BODY>
</HTML>
