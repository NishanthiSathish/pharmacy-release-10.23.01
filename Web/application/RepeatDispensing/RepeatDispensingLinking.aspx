<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RepeatDispensingLinking.aspx.cs"
    Inherits="application_RepeatDispensing_RepeatDispensingLinking" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../sharedscripts/Controls.js"></script>
    <script type="text/javascript" src="../sharedscripts/DateLibs.js"></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"></script>

    <script type="text/javascript">
        var txtExpDate;
        
        function CloseForm() {
            window.returnValue = 'cancel';
            self.close();
        }
        function LoadForm() {
            document.getElementById("chkInUse").focus();
        }
        function KeyPressed(event) // Called whenever a keypress event is fired, assigned to body element
        {
            event = event || window.event; // Capture browser or window event (such as tab in IE)
            if (event.keyCode == 27) // If Esc
            {
                CloseForm();
            }
        }

        function imgCalendar_Click() {
            txtExpDate = document.getElementById('txtExpDate');
            ShowMonthViewWithDate(txtExpDate, txtExpDate, txtExpDate.value);
        }
        
    
    </script>


</head>
<body style="height: 100%;" onkeydown="KeyPressed(event)" onload="LoadForm()">
    <form id="frmMain" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server">
    </asp:ScriptManager>
    <div >
        <table style="width: 520px; height: 100px">
            <tr>
                <td>
                    <asp:Label runat="server" ID="lblPrescriptionLabel" Text="Prescription" />
                </td>
                <td colspan="2">
                    <div style="margin-bottom: 3px;">
                        <asp:Label runat="server" ID="lblPrescription"></asp:Label></div>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label runat="server" ID="lblLabelLabel" Text="Label" />
                </td>
                <td colspan="2">
                    <div style="margin-bottom: 3px;">
                        <asp:Label runat="server" ID="lblLabel"></asp:Label></div>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblInUse" runat="server" Text="In Use" />
                </td>
                <td>
                    <asp:CheckBox ID="chkInUse" runat="server" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblJVM" runat="server" Text="JVM" Visible="false" />
                </td>
                <td>
                    <asp:CheckBox ID="chkJVM" runat="server" Visible="false" OnCheckedChanged="chkJVM_Change"
                        AutoPostBack="true" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblQuantity" runat="server" Text="Quantity"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtQuantity" runat="server" Enabled="true" CssClass="Field" MaxLength="7"
                        Width="51px"></asp:TextBox>
                    <asp:Label ID="lblIssueUnits" runat="server" Text=""></asp:Label>
                </td>
                <td>
                    <asp:Label ID="lblQtyWarning" runat="server" Text="If Entered, this will override any calculated quantity"></asp:Label>
                </td>
            </tr>
            <tr runat="server" id="rowRepeats">
                <td>
                    <asp:Label ID="lblNumberOfRepeats" runat="server" Text="Number of Repeats" Width="60px"></asp:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtNumberOfRepeats" runat="server" Enabled="true" CssClass="Field" MaxLength="3"
                        Width="51px"></asp:TextBox>
                </td>
                <td>
                    <asp:Label ID="lblRepeatsRemaining" runat="server" Text="Repeats Remaining"></asp:Label>&nbsp
                    <asp:TextBox ID="txtRepeatsRemaining" runat="server" Enabled="true" CssClass="Field" MaxLength="3"
                        Width="51px"></asp:TextBox>&nbsp
                </td>
            </tr>
            <tr runat="server" id="rowRxExpiry">
                <td>
                    <asp:Label ID="lblRxExpiryDate" runat="server" Text="Prescription Expiry date"  Width="60px"></asp:Label>
                </td>
                <td colspan=2>
                    <asp:TextBox ID="txtExpDate" runat="server" validchars="DATE:dd/mm/yyyy" onkeypress="MaskInput(this);" onPaste="MaskInput(this)" Width="75px" />&nbsp
                        <img src="..\..\images\ocs\show-calendar.gif" onclick="imgCalendar_Click();" style="border: 0">
                </td>
            </tr>
            <tr runat="server" id="rowUpdated" visible="false">
                <td colspan="4" style="padding: 20px">
                    <asp:Label ID="lblUpdated" runat="server" Text=""></asp:Label>
                </td>
            </tr>
        </table>
    </div>
    <div style="height: 20px; text-align: center; padding-bottom:5px;">
        <asp:Button runat="server" ID="btnCancel" Text="Cancel" CssClass="ICWButton" OnClientClick="CloseForm()" />
        <asp:Button runat="server" ID="btnDelete" Text="Delete" CssClass="ICWButton" Enabled="false"
            OnClick="btnDelete_Click" />
        <asp:Button runat="server" ID="btnSave" Text="Save" CssClass="ICWButton" Enabled="true"
            OnClick="btnSave_Click" />
    </div>
    <div style="width:520px; height:70px; overflow:auto; ">
        <table>
            <tr>
                <td>
                    <asp:CustomValidator ID="ValidatorQuantity" runat="server" Display="Dynamic" OnServerValidate="Validate"></asp:CustomValidator>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:CustomValidator ID="ValidatorNumberOfRepeats" runat="server" Display="Dynamic" OnServerValidate="Validate"></asp:CustomValidator>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:CustomValidator ID="ValidatorRepeatsRemaining" runat="server" Display="Dynamic" OnServerValidate="Validate"></asp:CustomValidator>
                </td>
            </tr>
            <tr>
                <td>
                    <asp:CustomValidator ID="ValidatorRxExpiry" runat="server" Display="Dynamic" OnServerValidate="Validate"></asp:CustomValidator>
                </td>
            </tr>
            <tr>
                <td>
                    <div >
                        <asp:Label ID="lblErrors" runat="server" CssClass="ErrorField"></asp:Label></div>
                </td>
            </tr>
        </table>
    </div>
    </form>
</body>
</html>
