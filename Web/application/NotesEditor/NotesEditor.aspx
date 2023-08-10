<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>

<%
    'NOTESEDITOR.aspx
    '
    'This page is used as a quick lookup for notes linked to requests, responses,
    'or pending items.
    'It has the ability to launch orderentry to add or view notes.
    '
    'The actual mechanics are held in NotesEditorContents.aspx; because of the
    'weird behaviour of submit() when used in a modal dialog (ie it forces open in
    'new window), we have to use this page as a wrapper.
    '
    'The page takes query string parameters as follows:
    '
    'SessionID 	(mandatory)						      :		The standard security token
    'Mode			(mandatory)
    'Pending					:		Show notes attached to the given pending item
    'Request					:		Show notes attached to the given Request
    'Response					:		Show notes attached to the given Response
    '
    'ID  			(mandatory)  	 						:      ID of Request/Response/PendingItem from which to display notes
    'ShowAll     (Optional)
    'TRUE = show all associated Notes
    'FALSE (default) = Show only live Notes
    '
    'ReturnValue:				'cancel' if no changes were made, empty string if anything
    'was modified.
    '
    '-----------------------------------------------------------------------
    'Modification History:
    '21Nov03 TH  Written
    '13Jun03 AE  Finished, with mods to original code to bring it up to date
    '-----------------------------------------------------------------------
    Dim strUrl As String
    Dim strApplication As String
    Dim sessionId As Integer
    
    sessionId = CInt(Request.QueryString("SessionID"))
    If OrderEntry.UseVersion11(sessionId) = True Then
        strUrl = System.Configuration.ConfigurationManager.AppSettings("ICW_V11Location") & "/OrderComms/Views/OrderEntry/TextualNotes.aspx?"
        strApplication = "yes"
    Else
        strUrl = "NotesEditorContents.aspx?"
        strApplication = "no"
    End If
%> 
<%--<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //Called in V11, so removed here
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionId %>';
    //alert('sessionId ' + sessionId);    
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "NotesEditor.aspx";
    var ret = windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
  </script>--%>


<html>
<head>
<title>Attached Notes</title>
<script language="javascript" type="text/javascript">
    function closeWindow() {

        //var refresh = document.body.getAttribute('changed');
       
        //if (refresh == "refresh" || refresh == null) {
        //    window.returnValue = true;
        //}        
    }
</script>

</head>

<body onunload="closeWindow();">
<iframe id="fraOnly" src="<%= strUrl %><%= Request.QueryString %>" width="100%" height="100%" scrolling="no" application="<%= strApplication %>"></iframe>    
<%--<iframe id="ActivityTimeOut"  application="yes" allowtransparency="true"  style="display: none;"> </iframe>--%>

</body>

</html>
