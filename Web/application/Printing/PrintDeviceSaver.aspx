<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.ICWCookie" %>

<%
    Dim SessionID As Integer = Integer.Parse(Request.QueryString("SessionID"))
    Dim MediaTypeID As Integer = Generic.CIntX(Request.Form("txtMediaTypeID"))
    Dim DeviceName As String = Request.Form("txtDeviceName")
    Dim SuccessString As String = String.Empty

    If MediaTypeID > 0 Then
        'Page has been posted

        Dim CookieID As Integer = GetCookieID(SessionID)
        If CookieID = -1 Then
            'Create cookie because it doesnt exist
            CookieID = CreateCookie(SessionID)
        End If

        'By this stage, we should have a valid cookie ID & GUILD, so time to store
        'the selected device name against the supplied CookieID and MediaTypeID
        Dim Success As Boolean = False
        If CookieID > 0 Then
            Success = Ascribe.Common.BrokenRules.NoRulesBroken(New PRTRTL10.PrintDevice().Save(SessionID, CookieID, MediaTypeID, DeviceName))
        End If
        If Success Then
            SuccessString = "Yes"
        Else
            SuccessString = "No"
        End If
    End If
%>


<html>
<head>
<title>Print Device Saver</title>

<script type="text/javascript">

function window_onload()
{
    if (txtSuccess.value == "Yes")
    {
        window.parent.PrintDeviceSaveComplete(document.all("txtDeviceName").value);
    }
    if (txtSuccess.value == "No")
    {
        alert("PrintDeviceSaver.aspx: Unable to record Print Device preference");
        window.parent.PrintDeviceSaveComplete();
    }
}

</script>
</head>


<body onload="return window_onload();" scroll="no">

<form action="PrintDeviceSaver.aspx?SessionID=<%= SessionID %>" method="post" id="frmPrintDeviceSaver" name="frmPrintDeviceSaver">
	<input type="text" id="txtMediaTypeID" name="txtMediaTypeID" value="<%= MediaTypeID %>" />
	<input type="text" id="txtDeviceName" name="txtDeviceName" value="<%= DeviceName %>" />
</form>

Success: <input type="text" id="txtSuccess" name="txtSuccess" value="<%= SuccessString %>" />

</body>
</html>
