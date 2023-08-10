<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AddNewCode.aspx.cs" Inherits="application_PharmacyReferenceData_AddNewCode" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register TagPrefix="icw" Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=SessionInfo.SessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "PharmacySupplierWardSearch.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Adding </title>
    <base target="_self" />

    <link href="../../style/PharmacyDefaults.css" rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"       rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("360px", "250px");
    </script>

    <style type="text/css">html, body{height:96%}</style>  <!-- Ensure page is full height of screen -->  
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div>
        <icw:Container ID="container" runat="server" ShowHeader="false" FillBrowser="false" Height="93%">
        <asp:UpdatePanel ID="upPanel" runat="server">
        <ContentTemplate>    
            <icw:Form runat="server">
                <icw:Label ID="lbCaption" runat="server" />
                <icw:ShortText  ID="tbCode"  runat="server" Mandatory="True" Caption="Code:" />
            </icw:Form>
                    
            <icw:General runat="server">
                <div style="position:absolute; bottom:30px; right:185px">
                    <icw:Button ID="btnOK"     runat="server" CssClass="PharmButton" Caption="OK"     AccessKey="O" OnClick="btnOK_OnClick" />
                </div>
                <div style="position:absolute; bottom:30px; left:185px">
                    <icw:Button ID="btnCancel" runat="server" CssClass="PharmButton" Caption="Cancel" AccessKey="C" />
                </div>
            </icw:General>

            <icw:MessageBox ID="mbExistsOnOtherSites" runat="server" Caption="Emis Health" Buttons="OKCancel" OnOkClicked="mbExistsOnOtherSites_OnOkClicked" Visible="false">
                <div style="margin:5px;">
                    This code already exists for site(s)<br />
                    <div id="divExistsOnOtherSites" runat="server" style="margin:10px;" />
                    Click OK to add to other sites not listed here.
                </div>
            </icw:MessageBox>
        </ContentTemplate>
        </asp:UpdatePanel>                         
        </icw:Container>
    </div>
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>     
</html>
