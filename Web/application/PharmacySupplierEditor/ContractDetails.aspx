<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ContractDetails.aspx.cs" Inherits="application_PharmacySupplierEditor_ContractDetails" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register TagPrefix="icw" Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script type="text/javascript" src="../sharedscripts/inactivityTimeOut.js"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "ContractDetails.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Contract Details</title>
    <base target="_self" />

    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    
    <script type="text/javascript">
        SizeAndCentreWindow("725px", "600px");

        function btnClose_onclick() {
            if (!isPageDirty || confirm("Changes have been made.\n\nClick Cancel to continue and lose your changes or OK to return to the editor"))
                window.close();
        }
    </script>

    <style type="text/css">
        html, body {
            height: 98%
        }
    </style>
    <!-- Ensure page is full height of screen -->
</head>
<body onload="InitIsPageDirty();">
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" />
        <div>
            <icw:Container runat="server" Height="525px" FillBrowser="true">
                <asp:UpdatePanel runat="server">
                    <ContentTemplate>
                        <icw:Form runat="server">
                            <icw:LongText ID="tbCurrentContractDetails" runat="server" Columns="65" Rows="11" Caption="Current Contract Details" />
                            <icw:DateTime ID="dtDateOfChange" runat="server" Caption="Date of Change" Mode="Date" />
                            <icw:LongText ID="tbNewContractDetails" runat="server" Columns="65" Rows="12" Caption="New Contract Details" />
                        </icw:Form>

                        <icw:General runat="server">
                            <div style="position: absolute; bottom: 25px; left: 270px">
                                <icw:Button ID="btnSave" runat="server" Caption="Save" Width="75px" ShortcutKey="S" OnClick="btnSave_OnClick" />
                            </div>
                            <div style="position: absolute; bottom: 25px; right: 270px">
                                <icw:Button ID="btnClose" runat="server" Caption="Close" Width="75px" ShortcutKey="C" />
                            </div>
                            <div style="position: absolute; top: 205px; right: 75px">
                                <icw:Button ID="btnNewWithOld" runat="server" Caption="Replace new with current" Width="175px" ShortcutKey="R" OnClick="btnNewWithOld_OnClick" />
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
