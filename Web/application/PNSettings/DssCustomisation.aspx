<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DssCustomisation.aspx.cs" Inherits="application_PNSettings_DssCustomisation" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "DssCustomisation.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Customer Specific Settings</title>
    <base target=_self>
    
    <link href="../../style/application.css"        rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"   rel="stylesheet" type="text/css" />
    <link href="../../style/PN.css"                 rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.4.3.min.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"></script>
    
    <script type="text/javascript">
        window.dialogHeight = "600px";
        window.dialogWidth  = "600px";
        
        function form_onload() 
        {
            Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(HideProgressMsg);
        }

        function checkbox_onclick(checkboxID, textboxID) 
        {
            var checked = $('#' + checkboxID)[0].checked;
            var tb      = $('#' + textboxID )[0];

            tb.disabled = !checked;
            if (!checked) 
                tb.value = '';
        }
    </script>
     
</head>
<body onload="form_onload();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <div>
        <asp:Panel ID="pnMain" runat="server" Height="515px" ScrollBars="Vertical" style="padding:10px;" >
            <asp:Label ID="lbPrompt" runat="server" Text="" /><br />
            <br />
            <asp:Table ID="table" runat="server" />
        </asp:Panel>
        
        <div style="text-align:center; width: 100%; padding-top: 20px;">
            <div>
                <asp:Button CssClass="PharmButton" ID="btnSave"   runat="server" Text="Save"   AccessKey="S" OnClick="Save_Click" />&nbsp;&nbsp;&nbsp;
                <asp:Button CssClass="PharmButton" ID="btnCancel" runat="server" Text="Cancel" AccessKey="C" OnClientClick="window.close(); return false;" />
            </div>
        </div>
    </div>

    <!-- update progress message -->
    <div id="divUpdateProgress" style="display:none;position:absolute;width:100%;z-index:9900;top:0px;left:0px;height:100%;">
    <table width=100% height=100% style="display:none;">
    <tr valign=center>
	    <td align=center>
            <div class="ICWStatusMessage" style="vertical-align:middle;height:75px;"><img src="../../images/Developer/spin_wait.gif" /><span id="spanMsg">Processing...</span></div>
        </td>
    </tr>     
    </table>           
    </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
