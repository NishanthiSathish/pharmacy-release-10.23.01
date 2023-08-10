<%@ Page Language="vb" %>

<%
    Response.Cache.SetCacheability(System.Web.HttpCacheability.NoCache)

    Dim strDate As String = Request.QueryString("date")
    Dim strTime As String = Request.QueryString("time")

    Dim adminDateTime As DateTime = DateTime.Parse(string.Format("{0} {1}", strDate, strTime))

    Dim diff As TimeSpan = adminDateTime - DateTime.Now
    Response.ContentType = "text/xml"

	If diff.TotalMinutes >= 5 Then
		Response.Write("future")
	Else
		Response.Write(String.Format("{0}{1}", strDate, strTime))
	End If
%>
