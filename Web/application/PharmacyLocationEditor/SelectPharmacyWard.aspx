<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SelectPharmacyWard.aspx.cs" Inherits="application_PharmacyWardEditor_SelectPharmacyWard" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "SelectPharmacyWard.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Select Location</title>
    <base target="_self" />

    <link href="../../style/PharmacyDefaults.css"       rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"             rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css"    rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"        async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"      async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js" async></script>
    <script type="text/javascript" src="script/SelectPharmacyWard.js"                    async></script>
    
    <script type="text/javascript">
        SizeAndCentreWindow("800px", "500px");
    </script>

    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body onload="body_onload()" onkeydown="body_onkeydown()">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <asp:HiddenField ID="hfSelectedID"   runat="server" />
    <div class="icw-container-fixed" style="padding:10px;">
    <asp:UpdatePanel ID="upMain" runat="server">
    <ContentTemplate>
        <!-- Search results grid -->
        <div id="divGrid" style="height:350px;">
            <uc:GridControl ID="gcGrid" runat="server" EnterAsDblClick="true" EnableAlternateRowShading="true" SortableColumns="true" JavaEventOnRowSelected="gcGrid_OnRowSelected" JavaEventOnRowUnselected="gcGrid_OnRowUnselected" JavaEventDblClick="gcGrid_OnDblClick" />
        </div>

        <div style="width:100%;text-align:center;padding-top:5px;height:20px;">
            <asp:Label ID="lbInfo" runat="server" Text="Select option from the list" style="color: #FF0000;font-weight: bold; display: none;" EnableViewState="False" />
        </div>
        
        <!-- Spacer -->
        <hr />
        
        <!-- Search panel -->
        <br />
        Search:&nbsp;&nbsp;<asp:TextBox ID="tbSearch" runat="server" Width="100px" />
            
        <!-- Sites panel -->
        <asp:Panel ID="sitesPanel" runat="server" Visible="false">
            <span>Select site:</span>&nbsp;&nbsp;
            <asp:DropDownList ID="ddlSites" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSites_OnSelectedIndexChanged"></asp:DropDownList>
        </asp:Panel>
                            
        <div>
            <div style="position:absolute; bottom:25px; left:300px">
                <asp:Button ID="btnOk"      runat="server" CssClass="PharmButton" Text="OK"     AccessKey="O" OnClientClick="return btnOk_onclick();" OnClick="btnOk_OnClick" />
            </div>
            <div style="position:absolute; bottom:25px; right:300px">
                <asp:Button ID="btnCancel"  runat="server" CssClass="PharmButton" Text="Cancel" AccessKey="C" OnClientClick="window.close();"  />
            </div>
        </div>
    </ContentTemplate>
    </asp:UpdatePanel>
    </div>     
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
