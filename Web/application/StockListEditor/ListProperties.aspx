<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ListProperties.aspx.cs" Inherits="application_StockListEditor_ListProperties" %>
<%@ Register TagPrefix="icw" Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" %>
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
<head runat="server">
    <title>List Properties</title>
    <base target="_self" />

    <link href="../../style/icwcontrol.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"       async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"     async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"   defer></script>
    <script type="text/javascript" src="script/ListProperties.js"                       async></script>
    <script type="text/javascript">
        SizeAndCentreWindow('650px', '500px');
    </script>
    
    <style type="text/css">html, body{height:98%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div>
        <icw:Container runat="server" Height="525px" FillBrowser="true">
        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>   
            <icw:Form Caption="Details" runat="server">
                <icw:Label runat="server">Enter details for the ward stock list<br /><br /></icw:Label>
                <icw:ShortText ID="tbCode" runat="server" Caption="List Code:" Mandatory="true" TextboxWidth="75px" />
                <icw:ShortText ID="tbShortName" runat="server" Caption="Short Name:"  Mandatory="true"  TextboxWidth="225px" />
                <icw:ShortText ID="tbFullName"  runat="server" Caption="Full Name:"   Mandatory="true"  TextboxWidth="225px" />

                <icw:ShortText ID="txtLocationDescription" runat="server" Caption="Location:" TextboxWidth="300px" />
                <asp:Button ID="btnLocation"      runat="server" CssClass="PharmButtonSmall" style="position:absolute; width:20px; height:20px;" Text="..."   OnClientClick="btnLocation_OnClick(); return false;" BorderStyle="None" />
                <asp:Button ID="btnLocationClear" runat="server" CssClass="PharmButtonSmall" style="position:absolute; width:40px; height:20px;" Text="Clear" OnClientClick="btnLocationClear_OnClick(); return false;" />
                <asp:Label ID="lblNotInUse" runat="server" style="color:red; position:absolute; width:60px; height:20px; padding-top:5px;" Text="Not in use" />
                <asp:HiddenField ID="hfWCustomerID"   runat="server" />
                <asp:HiddenField ID="hfWCustomerCode" runat="server" />
                <icw:CheckBox ID="cbVisibleToLocation"    runat="server" Caption="List Visible to Location" />
            </icw:Form>
         
            <icw:Form Caption="Settings" runat="server">
                <icw:CheckBox ID="cbPrintPickingTicket"     runat="server" Caption="Print Picking Ticket" />
                <icw:CheckBox ID="cbPrintDeliveryNote"      runat="server" Caption="Print Delivery Note"  />
                <icw:CheckBox ID="cbOnlyAvailableToSite"    runat="server" Caption="Only available to site {0:000}" ReadOnly="true" />
                <icw:CheckBox ID="cbInUse"                  runat="server" Caption="In Use"               />
            </icw:Form>

            <icw:General runat="server">
                <div style="position:absolute; bottom:20px; right:335px">
                    <icw:Button ID="btnOK"     runat="server" CssClass="PharmButton" Caption="OK"     ShortcutKey="O" OnClick="btnOK_OnClick" />
                </div>
                <div style="position:absolute; bottom:20px; left:335px">
                    <icw:Button ID="btnCancel" runat="server" CssClass="PharmButton" Caption="Cancel" ShortcutKey="C" OnClick="btnCancel_OnClick"  />
                </div>
            </icw:General>
        </ContentTemplate>    
        </asp:UpdatePanel>
        </icw:Container>
    </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
