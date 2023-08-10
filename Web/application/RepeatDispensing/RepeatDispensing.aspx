<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RepeatDispensing.aspx.cs" Inherits="application_RepeatDispensing_RepeatDispensing" %>

<html>
<head id="Head1" runat="server">

    <title>Repeat Dispensing Patient Settings</title>
	<link href="../../Style/application.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"></script>
    <script type="text/javascript">
        var postbackElement = null; // Control that instigated the postback
        var clickTargetID = "";
        var lastAction = "None";
        
        function SetFocusToNextControl(newTabIndex) // Finds control with specified tab index and sets focus
        {
            for (var i=0 ; i<=document.frmMain.elements.length-1 ; i++) // Loop through all form controls
            {
                var myElement = document.frmMain.elements[i]; // Get control
                if (myElement.tabIndex == newTabIndex && newTabIndex > 0) // If control tabindex matches parameter and parameter is > 0
                {
                    myElement.focus(); // Set focus on control
                    if (myElement.select)
                        myElement.select(); // Select control (radiobuttons, etc)
                }
            }
        }
        
        function RestoreFocus(source, args) // Restores focus - currently called at end of postback request
        {
            var myElement = document.getElementById(postbackElement.id); // Get control that instigated the postback
            myElement.focus(); // Set focus on control that caused postback
            if (myElement.type == "text") // If control is a textbox we need to work out how postback was initiated to see where focus should go
            {
                if (lastAction == "Tab") // If the postback was initiaed by tabbing out of a textbox
                {
                    SetFocusToNextControl(myElement.tabIndex+1); // Set focus to the next control in the tabindex
                }
                else if (lastAction == "Shift-Tab") // If the postback was initiated by shift-tabbing out of a textbox
                {
                    SetFocusToNextControl(myElement.tabIndex-1); // Set focus to the last control in the tabindex
                }
                else if (lastAction == "Click" && clickTargetID) // If the postback was initiated by clicking out of a textbox and we have the clicked element ID
                {
                    if (document.getElementById(clickTargetID) != null) // If another element was clicked
                    {
                        var clickedElement = document.getElementById(clickTargetID); // Get clicked element
                        clickedElement.focus(); // Focus on clicked element
                        if (clickedElement.select)
                            clickedElement.select(); // Select clicked element
                        if (clickedElement.type == "radio") // If clicked element is a radiobutton
                        {
                            clickedElement.checked = true; // Ensure radio button value is selected
                        }
                        else if (clickedElement.type == "checkbox") // If clicked element is a checkbox
                        {
                            if (clickedElement.checked == true) // If checkbox is currently checked
                            {
                                clickedElement.checked = false; // Uncheck checkbox
                                document.frmMain.submit(); // Submit form (as this should instigate an autopostback which will be bypassed currently)
                            }
                            else
                            {
                                clickedElement.checked = true; // Check checkbox
                                document.frmMain.submit(); // Submit form (as this should instigate an autopostback which will be bypassed currently)
                            }
                        }
                    }
                }
            }
            lastAction = "None"; // Reset last action
        }
        
        function SavePostBackElement(source, args) // Saves the postback element - currently called at the beginning of a postback request
        {
            postbackElement = args.get_postBackElement();
        }
        
        function AddRequestHandler() // Assigns methods to each end postback calls - currently loaded by default using body onload event - also sets default focus
        {
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(RestoreFocus); // Add RestoreFocus method to the end of the postback event
            prm.add_beginRequest(SavePostBackElement); // Add the SavePostBackElement to the beginning of the postback event
            document.getElementById("chkInUse").focus();
        }
        
        function KeyPressed(event) // Called whenever a keypress event is fired, assigned to body element
        {
            event = event || window.event; // Capture browser or window event (such as tab in IE)
            if (event.keyCode == 9 && event.shiftKey) // If Shift-Tab
            {
                lastAction = "Shift-Tab";
            }
            else if (event.keyCode == 9) // If Tab
            {
                lastAction = "Tab";
            }
            else if (event.keyCode == 27) // If Esc
            {
                CloseForm();
            }
            else // Not interested
            {
                lastAction = "None";
            }
        }
        
        function MouseClicked(event) // Called whenever a mouse button is clicked - currently assigned to body onmousedown event
        {
            event = event || window.event; // Capture browser or window event
            if (event.srcElement) // If an element was clicked on
            {
                clickTargetID = event.srcElement.id; // Capture instigating element ID
                lastAction = "Click" // Record that a mouse button was clicked
            }
        }

//        function PrintMe(event) {
//            window.print();
//        }
//             
        function CloseForm()
        {
            window.returnValue='cancel';
            self.close();
        }

        function btnDelete_Click() 
        {
            if (ICWConfirm('Do you really want to remove patient settings?', 'Yes,No', 'Delete', 'dialogHeight:80px;dialogWidth:300px;resizable:yes;status:no;help:no;') == 'Yes') 
                __doPostBack('UpdatePanel8', 'Delete');
        }
    </script>
    
</head>



<body scroll="no" onload="AddRequestHandler();" onkeydown="KeyPressed(event)" onmousedown="MouseClicked(event)">
    <form id="frmMain" runat=server style="margin-left: 5px; margin-top: 5px;">
        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <asp:UpdatePanel ID="UpdatePanel8" runat="server">
            <ContentTemplate>
                <h3><asp:label runat=server ID="lblPatient"></asp:label></h3>
                <table>
                    <tr>
                        <td style="width:135px">
                            <asp:Label ID="lblInUse" runat=server Text="In Use"></asp:Label>
                        </td>            
                        <td>
                            <asp:UpdatePanel ID="UpdatePanel7" runat="server">
                                <ContentTemplate>
                                    <asp:CheckBox ID="chkInUse" runat="server" TabIndex=1 />
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblLength" runat="server" Text="Length of supply"></asp:Label>
                        </td>
                        <td>
                            <asp:UpdatePanel ID="UpdatePanel1" runat="server">
                                <ContentTemplate>
                                    <asp:TextBox ID="txtLength" runat="server" AutoPostBack=true MaxLength="2" OnTextChanged="txtLength_TextChanged" TabIndex=2 CssClass="MandatoryField" Width="32px"></asp:TextBox>
                                    <asp:Label ID="lblLengthDays" runat="server" Text="days"></asp:Label>
                                    <asp:CustomValidator ID="ValidatorLength" runat="server" Display=Dynamic OnServerValidate="Validate"></asp:CustomValidator>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblAdditionalInformation" runat="server" Text="Additional Information"></asp:Label>
                        </td>
                        <td>
                            <asp:UpdatePanel ID="UpdatePanel5" runat="server">
                                <ContentTemplate>
                                    <asp:TextBox ID="txtAdditionalInformation" runat="server" MaxLength="30" TabIndex="3" AutoPostBack=true CssClass="" Width="510px"></asp:TextBox>
                                    <asp:CustomValidator ID="ValidatorAdditionalInformation" runat="server" Display=Dynamic OnServerValidate="Validate"></asp:CustomValidator>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                    <tr runat=server id="rowTemplate" visible="true">
                        <td>
                            <asp:Label ID="lblTemplate" runat="server" Text="Template"></asp:Label>
                        </td>
                        <td>
                            <asp:UpdatePanel ID="upTemplate" runat="server" UpdateMode="Conditional">
                                <ContentTemplate>                                
                                    <asp:DropDownList ID="ddlTemplate" runat="server" Width="510px" TabIndex="4" OnSelectedIndexChanged="ddlTemplate_SelectedIndexChanged" AutoPostBack="True" Font-Names="Arial Narrow"></asp:DropDownList>
                                    &nbsp;<asp:Label ID="lblNotInUse" runat="server" Text="Label" Visible="false" Font-Size="Smaller">not in use</asp:Label>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                    <tr runat=server id="rowADM" visible=false>
                        <td>
                            <asp:Label ID="lblADM" runat="server" Text="Packed by "></asp:Label>
                        </td>
                        <td>
                            <asp:UpdatePanel ID="UpdatePanel3" runat="server">
                                <ContentTemplate>
                                    <asp:CheckBox ID="chkADM" runat="server" OnCheckedChanged="chkADM_CheckedChanged" AutoPostBack=true TabIndex="5" CausesValidation=true  ValidationGroup="grpADM"/>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                    <tr runat="server" id="rowSupplyPattern" visible="false">
                        <td>
                            <asp:UpdatePanel ID="UpdatePanel6" runat="server">
                                <ContentTemplate>
                                    <asp:Label ID="lblSupplyPattern" runat="server" Text="Supply pattern"></asp:Label>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                        <td>
                            <asp:UpdatePanel ID="UpdatePanel4" runat="server">
                                <ContentTemplate>
                                    <asp:RadioButtonList ID="rblSupplyPattern" runat="server">
                                    </asp:RadioButtonList>
                                </ContentTemplate>
                            </asp:UpdatePanel>
                        </td>
                    </tr>
                    <tr runat="server" id="rowUpdated" visible=false >
                        <td colspan="2" style="padding:20px">
                            <asp:Label ID="lblUpdated" runat="server" Text=""></asp:Label>
                        </td>
                    </tr>
                </table>
            </ContentTemplate>
        </asp:UpdatePanel>               
                    
        <div style="width: 100%; top: 450px; position: absolute;">
            <div style="vertical-align: bottom; text-align: center;">
                <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="ICWButton" OnClientClick="CloseForm()" />&nbsp;
                <asp:Button ID="btnOK" runat="server" Text="Save" CssClass="ICWButton" OnClick="btnOK_Click" AccessKey="S" />&nbsp;
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="ICWButton" OnClick="btnClear_Click" />&nbsp;
                <asp:Button ID="btnDelete" runat="server" Text="Delete" CssClass="ICWButton" OnClientClick="btnDelete_Click()" UseSubmitBehavior="true" />
            </div>
        </div>            
    </form>
    
    
</body>
</html>

