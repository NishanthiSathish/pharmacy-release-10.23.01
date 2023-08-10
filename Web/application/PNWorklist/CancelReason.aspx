<%@ Page Language="C#" AutoEventWireup="true" CodeFile="CancelReason.aspx.cs" Inherits="application_PNWorklist_CancelReason" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
  <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "CancelReason.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target=_self>
    
    <link href="../../style/application.css"                                rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/PN.css"                                         rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.4.3.min.js"></script>
    <script type="text/javascript">
        // Handle Esc key press TFS31082  2Apr12  XN            
        function form_onkeydown(event) 
        {
            switch (event.keyCode) 
            {
            case 27:    // Escape (cancel)
                $('#btnCancel').click();
            break;
            }
        }
    </script>
    <style type="text/css">html, body{height:90%}</style>  <!-- Ensure page is full height of screen -->
    
    <title runat="server" id="pageTitle"></title>
</head>
<script language=javascript>
    window.dialogHeight = "300px";
    window.dialogWidth  = "430px";
</script>
<body scroll="no" onkeydown="form_onkeydown(event);">
    <form id="form1" runat="server" defaultbutton="btnOK">
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server"  DecoratedControls="All" Skin="Web20" />
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server" />
        <div style="margin: 10px;">            
            <telerik:RadAjaxLoadingPanel ID="lpWorklist" runat="server" />
            <telerik:RadAjaxPanel ID="pWorklist" runat="server" LoadingPanelID="lpWorklist">
                Reason for Stopping:&nbsp;<telerik:RadComboBox ID="ddlReasonForStopping"  runat="server" Width="275px" />&nbsp;<asp:Label ID="lbReasonForStopping" runat="server" Text="*" ForeColor=Red></asp:Label>
                <br />
                <asp:Label ID="lbReasonForStoppingError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" />
                <br />
                <div>Comments</div>
                <telerik:RadTextBox ID="tbComments" runat="server" Rows="10" TextMode="MultiLine" Width="400px" /><br />
                <br />
                <table width="100%">
                    <tr>
                        <td align="center">                
                            <asp:Button ID="btnOK"     runat="server" Text="OK"     AccessKey="O" OnClick="btnOK_OnClick" />
                            &nbsp;
                            <asp:Button ID="btnCancel" runat="server" Text="Cancel" AccessKey="C" OnClientClick="window.close(); return false;"  />
                        </td>
                    </tr>            
                </table>
            </telerik:RadAjaxPanel>
            </telerik:RadAjaxLoadingPanel>
        </div>       
    </form>
     <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
