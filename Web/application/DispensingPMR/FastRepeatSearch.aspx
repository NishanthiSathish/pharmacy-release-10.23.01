<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FastRepeatSearch.aspx.cs" Inherits="application_DispensingPMR_FastRepeatSearch" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "FastRepeatSearch.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><%= this.searchName %> Search</title>
    <base target=_self>
    
    <link href="../../style/PharmacyDefaults.css" rel="stylesheet" type="text/css" />
    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->    
    
    <script type="text/javascript">
        window.dialogHeight = "150px";
        window.dialogWidth  = "400px";
        
        function form_onkeydown(event)
        {
            switch (event.keyCode)
            {
            case 13:    // Enter
                document.getElementById('btnSearch').focus();
                document.getElementById('btnSearch').click(); 
                window.event.cancelBubble = true;
                break;  
                 
            case 27:    // Esc
                window.close();                               
                window.event.cancelBubble = true;
                break;   
            }
        }
    </script>   
    
</head>
<body onkeydown="form_onkeydown(event);">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div style="margin:5px;">
        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>        
            <div>Enter the prescription <%= this.searchName.ToLower() %> in the box below.</div>
            <br />
            
            <div>
			    <%= this.searchName %>&nbsp;&nbsp;&nbsp;<asp:TextBox ID="txtFastRepeatNumber" runat="server" Width="150px" /><br />
                <asp:Label ID="lbError" runat="server" CssClass="ErrorMessage" Text="&nbsp;" EnableViewState="false" Width="100%" style="text-align: center;" />
            </div>
            
            <div style="position: absolute; right: 10px; bottom: 10px;">
                <asp:Button ID="btnSearch" runat="server" CssClass="PharmButton" Text="Search" AccessKey="S" OnClick="btnSearch_OnClick" />&nbsp;
                <button class="PharmButton" onclick="window.close();" >Cancel</button>
            </div>  
        </ContentTemplate>            
        </asp:UpdatePanel>
    </div>      
    </form>
      <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
