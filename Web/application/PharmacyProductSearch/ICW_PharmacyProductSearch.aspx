<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_PharmacyProductSearch.aspx.cs" Inherits="application_PharmacyProductSearch_ICW_PharmacyProductSearch" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx"       tagname="GridControl"       tagprefix="uc1" %>
<%@ Register src="../pharmacysharedscripts/PharmacyLabelPanelControl.ascx" tagname="LabelPanelControl" tagprefix="uc1" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx"           tagname="ProgressMessage"    tagprefix="pc" %>
<%@ Register src="controls/BNFTree.ascx"                                   tagname="BNFTree"           tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<% 
    //ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", "") 
    //ICW.ICWParameter("HideCost", "Determines if prices\\costs values should be hidden from the user.", "No,Yes") 
%>

<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%= SessionInfo.SessionID %>';
    var desktopURL = "../sharedscripts/CheckSessionExists.aspx";
    var pageName = "ICW_PharmacyProductSearch.aspx";
    //alert(sessionId);
    //alert(desktopURL + " " + pageName);
    windowModal_CheckSession(sessionId, desktopURL, "CheckSessionExists" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Pharmacy Product Search</title>
    
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"></script>
    <script type="text/javascript" src="../sharedscripts/icw.js"></script>
    <script type="text/javascript" src="../sharedscripts/jquery-1.3.2.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyLabelPanelControl.js"></script>
    <script type="text/javascript" src="scripts/ICW_PharmacyProductSearch.js"></script>
    <script type="text/javascript" src="scripts/BNFTree.js"></script>
    <script type="text/javascript">
        var embeddedMode = <%= this.embeddedMode.ToString().ToLower() %>;
        var allowBNF     = <%= this.allowBNF.ToString().ToLower() %>;
    </script>
    
<% if (this.vb6Style) %>    
<% { %>
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <link href="../../style/OCSGrid.css"     rel="stylesheet" type="text/css" />
<% } %>
<% else %>    
<% { %>
    <link href="../../style/PharmacyDefaults.css"    rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyGridControl.css" rel="stylesheet" type="text/css" />
<% } %>
    <link href="../../style/LabelPanelControl.css"  rel="stylesheet" type="text/css" />
</head>
<body onload="body_onload()" onkeydown="body_onkeydown(event)">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="scriptManager" runat="server"></asp:ScriptManager>
    <div style="margin:10px;">
        <pc:ProgressMessage runat="server" EnableTheming="False" EnableViewState="false" />
        <asp:UpdatePanel ID="updatePanel" runat="server">
        <ContentTemplate>
            <!-- Search panel -->
            <asp:MultiView ID="mvOption" runat="server">
            <asp:View ID="vStandardSearch" runat="server">
                <div id="divStandardSearch" runat="server" style="width:100%; height:30px; vertical-align:middle;">
                    <span style="width:175px;height:25px;display:inline-block; vertical-align:middle;">Enter pharmacy item code:&nbsp;</span>
                    <asp:TextBox ID="tbSearch" runat="server" Width="500px"></asp:TextBox>&nbsp;
                    <asp:Button  ID="btnSearch"  runat="server" CssClass="PharmButton" Height="25px" Text="Search" onclick="btnSearch_Click" />
                </div>
            </asp:View>
            <asp:View ID="vBNF" runat="server">
                Select a BNF Chapter:<br />
                <asp:Panel id="pnBnfTree" runat="server" Height="170px" BorderColor="White" style="border:solid 1px #C6D3F0;" >
                    <uc1:BNFTree ID="bnfTree" runat="server" OnClientNodeSelected="bnfTree_OnClientNodeSelected" />
                </asp:Panel>
            </asp:View>
            </asp:MultiView>

            <!-- Sites panel -->
            <asp:Panel ID="sitesPanel" runat="server" style="width:100%; height:25px; vertical-align:top;" Visible="False">
                <br />
                <span style="width:175px;display:inline-block;">Select site:</span>
                <asp:DropDownList ID="ddlSites" runat="server"></asp:DropDownList>
            </asp:Panel>

            <asp:Label ID="lbInfo" CssClass="BrokenRule_Text" runat="server" Text="&nbsp;" style="text-align:center;" Width="100%" EnableViewState="False">&nbsp;</asp:Label>
            
            <!-- Spacer -->
            <hr />
                    
            <!-- Search results grid -->
            Select Item:
            <div id="divSearchResults" runat="server" style="border:solid 1px #C6D3F0;" onkeydown="grid_onkeydown(event);">  <!-- height set in code -->
                <uc1:GridControl ID="gcSearchResults" runat="server" JavaEventDblClick="btnOK_click();" CellSpacing="0" CellPadding="2" EnterAsDblClick="true" />
            </div>
            
            <!-- XML island for updating bottom info panel -->
            <xml id="xmlRowData"><%= productDetails.ToString() %></xml>  
        </ContentTemplate>            
        </asp:UpdatePanel>
              
        <!-- Spacer -->
        <hr />
        
        <!-- Info panel for selected drug (populated by data from xml island) -->
        <div style="height:88px;">
            <uc1:LabelPanelControl ID="lpcProductDetail" runat="server"  />
        </div>
        
        <br />
        
        <table style="margin-bottom:10px;width:100%;">
        <tr>
            <td style="width: 33%;">&nbsp;</td>            
            <td id="divButtons" runat="server" style="width: 33%;text-align:center;">
                <input id="btnOK"     type="button" value="OK"     class="PharmButton" onclick="btnOK_click()"     />&nbsp;
                <input id="btnCancel" type="button" value="Cancel" class="PharmButton" onclick="btnCancel_click()" />
            </td>            
            <td style="width: 33%;text-align:right;">
                <asp:CheckBox ID="cbAllRoutes" runat="server" Text="All Routes" Visible="False" Checked="False" OnCheckedChanged="cbAllRoutes_OnCheckedChanged" />
            </td>
        </tr>            
        </table>
    </div>
    </form>
    <iframe id="CheckSessionExists" application="yes" style="display: none;"></iframe>
</body>
</html>
