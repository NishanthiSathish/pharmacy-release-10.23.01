<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PharmacyProductEditorSettings.aspx.cs" Inherits="application_PharmacyProductEditor_PharmacyProductEditorSettings" EnableEventValidation="true" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik"  %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx" tagname="ProgressMessage" tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "PharmacyProductEditorSettings.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base target="_self" />
        
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"                                 rel="stylesheet" type="text/css" />
	<link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    
    <script language="javascript" type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"     defer></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/json2.js"                    defer></script>
    <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"   async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("600px", "450px");

        function tabSelected()
        {
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    
    <asp:UpdatePanel ID="upMain" runat="server">
    <ContentTemplate>
    <div style="margin-left:15px;margin-right:15px;margin-top:15px;height:19px;">
        <telerik:RadTabStrip runat="server" ID="tabButtons" OnClientTabSelected="tabSelected" ScrollChildren="false" PerTabScrolling="false" ondragstart="return false;" > 
            <Tabs>
                <telerik:RadTab ID="tabDesktop" runat="server" Text="Desktop" Value="0" />
            </Tabs>
        </telerik:RadTabStrip>
    </div>
        
    <div class="icw-container" style="margin-left:15px;margin-right:15px;margin-bottom:20px;height:380px">
        <asp:MultiView ID="mvViews" runat="server">
            <asp:View ID="vDesktop" runat="server">
                <div style="padding-left:20px;padding-right:20px;">
                    <table style="width:100%;">
                        <tr style="text-align:left;"><td colspan="4"><asp:CheckBox ID="cbDesktopUseAllViews" runat="server" Text="Display all available views" OnCheckedChanged="cbDesktopUseAllViews_OnCheckedChanged" AutoPostBack="true" /><br /></td></tr>
                        <tr>
                            <td style="text-align:left;"><asp:ListBox ID="lbDesktopSelectedViews"  runat="server" Rows="20" SelectionMode="Multiple" Height="300px" Width="225px" /></td>
                            <td style="text-align:left;"><asp:ListBox ID="lbDesktopAllViews"       runat="server" Rows="20" Enabled="false"          Height="300px" Width="225px" /></td>
                            <td style="text-align:center;">
                                <asp:Button ID="btnDesktopUp"     runat="server" CssClass="PharmButtonSmall" Text="▲" OnClick="btnDesktopUp_OnClick" /><br />
                                <br /><br />
                                <asp:Button ID="btnDesktopAdd"    runat="server" CssClass="PharmButtonSmall" Text="◄" OnClick="btnDesktopAdd_OnClick" /><br />
                                <asp:Button ID="btnDesktopRemove" runat="server" CssClass="PharmButtonSmall" Text="►" OnClick="btnDesktopRemove_OnClick" /><br />
                                <br /><br />
                                <asp:Button ID="btnDesktopDown"   runat="server" CssClass="PharmButtonSmall" Text="▼" OnClick="btnDesktopDown_OnClick" />
                            </td>
                            <td style="text-align:right;"><asp:ListBox ID="lbDesktopAvaliableViews" runat="server" Rows="20" SelectionMode="Multiple" Height="300px" Width="225px" /></td>
                        </tr>
                    </table>
                </div>
            </asp:View>
        </asp:MultiView>

        <div style="padding-left:20px;padding-right:20px;">
            <table style="width:100%;">
                <tr>
                    <td style="width:33%;">&nbsp;</td>
                    <td style="width:33%; text-align:center;"><asp:Button ID="btnOK"   runat="server" CssClass="PharmButton" Text="Close" OnClientClick="window.returnValue='OK'; window.close();"  /></td>
                    <td style="width:33%; text-align:right;" ><asp:Button ID="btnSave" runat="server" CssClass="PharmButton" Text="Save"  OnClick="btnSave_OnClick"                                 /></td>
                </tr>
            </table>
        </div>
    </div>
    </ContentTemplate>
    </asp:UpdatePanel>   
    </form>
     <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
