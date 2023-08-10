<%@ Page Language="C#" AutoEventWireup="true" CodeFile="aMMShiftEditor.aspx.cs" Inherits="application_aMMSettings_aMMShiftEditor" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register Src="../pharmacysharedscripts/ProgressMessage.ascx" TagName="ProgressMessage" TagPrefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "aMMShiftEditor.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>aMM Shift Editor</title>
    <base target="_self">

    <link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css" rel="stylesheet" type="text/css" />
    <link href="../../Style/icwcontrol.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.11.3.min.js" async></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js" defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript">
        SizeAndCentreWindow("475px", "235px");
    </script>
   
</head>
<body onkeydown="if (event.keyCode == 27) { window.close(); }">
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" />
        <div class="icw-container-fixed" style="height: 215px; padding-top: 5px; padding-left: 5px;">
            <!-- update progress message -->
            <uc:ProgressMessage ID="progressMessage" runat="server" />

            <asp:UpdatePanel ID="updatePanel" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <table>
                        <colgroup>
                            <col width="110px" />
                            <col width="50px" />
                            <col width="10px" />
                            <col width="80px" />
                            <col width="50px" />
                            <col width="125px" />
                        </colgroup>
                        <tr>
                            <td>Description</td>
                            <td colspan="4">
                                <asp:TextBox ID="tbDescription" runat="server" Width="200px" />&nbsp;<span style="color: Red; font-size: larger;">*</span></td>
                            <td id="tdDescriptionError" runat="server" class="ErrorMessage" />
                        </tr>
                        <tr>
                            <td>Manufacturing<br />
                                Slots Available</td>
                            <td colspan="4">
                                <asp:TextBox ID="tbSlotsAvailable" runat="server" Width="50px" />&nbsp;<span style="color: Red; font-size: larger;">*</span></td>
                            <td id="tdSlotsAvailableError" runat="server" class="ErrorMessage" />
                        </tr>
                        <tr>
                            <td>Start Time (HH:MM)</td>
                            <td>
                                <asp:TextBox ID="tbStartTime" runat="server" Width="50px" />&nbsp;<span style="color: Red; font-size: larger;">*</span></td>
                            <td />
                            <td style="text-align: right;">End Time (HH:MM)&nbsp;&nbsp;</td>
                            <td>
                                <asp:TextBox ID="tbEndTime" runat="server" Width="50px" />&nbsp;<span style="color: Red; font-size: larger;">*</span></td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                            <td id="tdTimeError" runat="server" class="ErrorMessage" colspan="4" style="text-align: center;" />
                        </tr>
                        <tr>
                            <td />
                            <td style="text-align: center;" colspan="4">
                                <table>
                                    <tr>
                                        <td>Sun</td>
                                        <td>Mon</td>
                                        <td>Tues</td>
                                        <td>Wed</td>
                                        <td>Thurs</td>
                                        <td>Fri</td>
                                        <td>Sat</td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:CheckBox ID="cbSun" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="cbMon" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="cbTues" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="cbWed" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="cbThurs" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="cbFri" runat="server" /></td>
                                        <td>
                                            <asp:CheckBox ID="cbSat" runat="server" /></td>
                                    </tr>
                                </table>
                            </td>
                            <td id="divDayError" runat="server" class="ErrorMessage"></td>
                        </tr>
                    </table>

                    <br />

                    <div style="text-align: center; width: 100%">
                        <asp:Button CssClass="PharmButton" ID="btnSave" runat="server" Text="Save" AccessKey="S" OnClick="btnSave_OnClick" CausesValidation="False" />&nbsp;&nbsp;&nbsp;
            <asp:Button CssClass="PharmButton" ID="btnCancel" runat="server" Text="Cancel" AccessKey="C" OnClientClick="window.close(); return false;" />
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>            
        </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
