<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>
<%
    'Dim xmldom As XmlDocument
    'Dim lngSessionId As Integer
    'Dim strMode As String 
%>
<%
    'OrderingFrequencyCheck.aspx
    '
    'Amendment History
    '26Feb07	CJM	Created
    'lngSessionId = CInt(Request.QueryString("SessionID"))
    'strMode = Request.QueryString("Mode")
    'xmldom = New XmlDocument()
    Throw New Exception("This form of frequency checking has been deplicated.")
    ' xmldom.Load(Request)
    'strResponse = ""
    'objOCS = new OCSRTL10.OrderCommsItem()
    'strResponse = objOCS.CheckOrderingFrequency(lngSessionId, xmldom.OuterXml)
    'Response.Write(strResponse)
%>

