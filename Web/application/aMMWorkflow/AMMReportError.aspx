<%@ Page Language="C#" AutoEventWireup="true" CodeFile="AMMReportError.aspx.cs" Inherits="application_aMMWorkflow_AMMReportError" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" TagPrefix="icw" %>
<%@ Register Src="../pharmacysharedscripts/PatientBanner/PatientBanner.ascx" TagName="PatientBanner" TagPrefix="uc" %>
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "AMMReportError.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Report Error</title>
    <base target="_self">

    <link href="../../style/icwcontrol.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        html, body {
            height: 95%
        }
    </style>
    <!-- Ensure page is full height of screen -->

    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript" src="../sharedscripts/inactivityTimeOut.js"></script>
    <script type="text/javascript">SizeAndCentreWindow("700px", "275px");</script>
</head>
<body scroll="none" onkeydown="if (event.keyCode == 13) { $('#btnOK').click(); }">
    <form runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />

        <icw:Container runat="server" Height="255px">
            <div style="font-size: 12px; background: white; border-top: solid 5px #D6DBEF; border-bottom: solid 5px #D6DBEF; padding: 5px;">
                <uc:PatientBanner ID="patientBanner" runat="server" />
            </div>
            <asp:UpdatePanel runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <icw:Form runat="server">
                        <icw:List runat="server" ID="lsReason" Caption="Reason" Mandatory="True" ShortListMaxItems="50" ShowClearOption="False" />
                        <icw:LongText runat="server" ID="tbComments" Caption="Comment" Rows="3" Columns="20" />
                    </icw:Form>

                    <icw:General ID="General1" runat="server">
                        <div style="width: 99%; text-align: center;">
                            <icw:Button ID="Button1" runat="server" CssClass="PharmButton" Caption="OK" AccessKey="O" OnClick="btnOK_OnClick" />
                        </div>
                    </icw:General>
                </ContentTemplate>
            </asp:UpdatePanel>            
        </icw:Container>
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
