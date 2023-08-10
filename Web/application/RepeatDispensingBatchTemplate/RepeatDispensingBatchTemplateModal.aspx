<!--	
                                RepeatDispensingTemplateEditorModal.aspx

	Wrapper for RepeatDispensingBatchTemplateEditor.aspx

	12May11 XN Created
-->
<%@ Page language="vb" %>
<!--#include file="../SharedScripts/ASPHeader.aspx"-->
<%
    Dim sessionId As Integer = CInt(Request.QueryString("SessionID"))
%>
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionId %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "RepeatDispensingTemplateEditorModal.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

<html>
<head>
    <title id="pageTitle">Repeat Dispensing Template Editor</title>
    <script type="text/javascript">
        function querySt(ji)
        {
            hu = window.location.search.substring(1);
            gy = hu.split("&");
            for (i=0;i<gy.length;i++)
            {
                ft = gy[i].split("=");
                if (ft[0] == ji)
                {
                    return ft[1];
                }
            }
        }
        
        function form_onkeydown(event) // Called whenever a keypress event is fired, assigned to body element
        {
            event = event || window.event; // Capture browser or window event (such as tab in IE)
            if (event.keyCode == 27) // ESC
            {
                window.returnValue = false;
                window.close();
            }
        }
                
        var mode = querySt("Mode");
        var pageTitleCtl = document.getElementById('pageTitle');
        if (mode == "Template")
        {
            pageTitleCtl.text = "Repeat Dispensing Batch Template Editor";
        }
        else
        {
            pageTitleCtl.text = "Repeat Dispensing Batch Editor";
        }
        
        
    </script>
</head>
<frameset rows="1" cols="1" onkeydown="form_onkeydown(event)">
    <frame application="yes" src="RepeatDispensingBatchTemplate.aspx<%= Request.Url.Query %>&IsInModal=yes" />
    <frame id="ActivityTimeOut" application="yes" style="display: none;"/>
</frameset>
</html>

