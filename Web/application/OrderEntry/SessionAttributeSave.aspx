<%@ Page language="vb" ValidateRequest="false"%>


<%
    Dim lngSessionID As Integer
    Dim strAttribute As String
    Dim strRequest As String
    Dim reader As New System.IO.StreamReader(Page.Request.InputStream)
    
    strRequest = reader.ReadToEnd()
    
    ' Get some of the standard parameters passed in on the querystring
    lngSessionID = CInt(Request.QueryString("SessionID"))
    strAttribute = Request.QueryString("Attribute")
    
    ' stick it in the db
    Ascribe.Common.Generic.SessionAttributeSet(lngSessionID, strAttribute.ToString(), strRequest.ToString())
%>