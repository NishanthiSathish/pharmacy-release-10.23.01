<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Terms.aspx.cs" Inherits="application_PNWorklist_Terms" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "ListProperties.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>

 <html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    
    <title>Parenteral Nutrition</title>
    <base target=_self>
    <style type="text/css">
        .style1
        {
            font-family: Arial, Helvetica, sans-serif;
        }
    </style>
</head>
<body style="background-color:#E3EFFF" onload="this.focus();">
    
    <form id="form1" runat="server" defaultbutton="btnAccep" defaultfocus="btnAccep">
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" Skin="Web20" />
    <asp:ScriptManager ID="ScriptManager1" runat="server">
        </asp:ScriptManager>
        <script type="text/javascript">
            function HandleCancel()
            {
                window.close();
            }
        </script>
        <div style="padding:20px" runat="server" id="divAgree">
            <asp:Panel ID="pnMain" runat="server" Height="330px" ScrollBars="Auto">
                <label class="style1">
                    <span id="spnMessage" runat="server">
                    </span>
                </label>
                <label class="style1">
                    <span id="spnMessage2" runat="server"></span>        
                </label>
            </asp:Panel>            
            <div id="div1" runat="server" style="display:block;position:absolute;width:60%;bottom:20px;">
                <label class="style1">
                    <span id="spnPrompt" runat="server" />
                </label>
            </div>
            <div style="display:block;position:absolute;bottom:20px;right:20px">
                <img src="../../images/UKCABlackFill.png" style="display:block;position:relative;bottom:50px;left:40px;"/>
                <asp:Button id="btnAccep" OnClick="HandleAccept" runat="server" Text="Accept" />&nbsp&nbsp
                <button id="btnCancel" onclick="HandleCancel();" >Cancel</button>
            </div>
        </div>
        <div runat="server" style="padding:20px" id="divCancelled">
            <span id="spnCancelled" runat="server" 
                style="font-size: x-large; font-weight: bold; color: #FF0000">
            </span>
        </div>
    </form>
      <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
