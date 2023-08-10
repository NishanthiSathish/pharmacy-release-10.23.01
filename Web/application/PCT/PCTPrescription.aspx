<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PCTPrescription.aspx.cs" Inherits="application_PCT_PCTPrescription" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=SessionInfo.SessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "PCTPrescription.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>PCT Prescription</title>
    <base target="_self" />
</head>
<body onkeydown="KeyPressed(event)" >
    <script type="text/javascript">
        function CloseForm(sender, args)
        {
            window.close();
        }
        function ClearSpecialist()
        {
            var combo = $find("<%=rcboSpecialist.ClientID %>");
            var item = combo.findItemByValue('-1');
            item.select();
        }
        function alertCallBackFn(arg) 
        {
            window.close();
        }
        function numKeyPress(sender, args)
        {
            var text = sender.get_value() + args.get_keyCharacter();
            if(!text.match('^[0-9]+$'))
                args.set_cancel(true);
        }
        function KeyPressed(event) // Called whenever a keypress event is fired, assigned to body element
        {
            event = event || window.event; // Capture browser or window event (such as tab in IE)
            if (event.keyCode == 27) // If Esc
            {
                window.close();
            }
            //else if (event.altKey && event.keyCode == 79)//Alt + O
            //{
            //    document.getElementById('<%=rbtnOK.ClientID %>').click();
           // }
        }
        function rcboSpecialistChanged(sender, args)
        {
            if (document.getElementById('rcboSpecialist').value.length > 0)
            {
                document.getElementById('<%=lblreqEndorsement.ClientID %>').style.visibility = 'visible';
            }
            else
            {
                document.getElementById('<%=lblreqEndorsement.ClientID %>').style.visibility = 'hidden';
            }
        }
        
        
    </script>
    <form id="form1" runat="server">
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
        </telerik:RadScriptManager>
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" Skin="Web20" DecoratedControls=All />
    <telerik:RadWindowManager ID="RadWindowManager1" runat="server" Skin="Web20">
    </telerik:RadWindowManager>
    <br />                  
        <table cellpadding="5px">
            <tr>
                <td align=right>
                    <label>Please select the PCT Prescriber</label>
                </td>
                <td>
                    <telerik:RadComboBox ID="rcboConsultants" runat="server" MarkFirstMatch="True" Width="248px" Skin="Web20"  >
                    </telerik:RadComboBox>&nbsp<asp:Label ID="lblreqConsultants" runat="server" Text="*" ForeColor=Red></asp:Label>&nbsp
                    <asp:CustomValidator ID="rvlPCTPrescriber" runat="server" 
                        ErrorMessage="Required" 
                        onservervalidate="rvlPCTPrescriber_ServerValidate"></asp:CustomValidator>
                </td>
            </tr>   
            <tr>
                <td align=right>
                    <label>Please select the oncology type for this prescription</label>
                </td>
                <td colspan=2>
                    <telerik:RadComboBox ID="rcboOncology" runat="server" MarkFirstMatch="True" Width="248px" Skin="Web20" >
                    </telerik:RadComboBox>&nbsp<asp:Label ID="lblreqOncology" runat="server" Text="*" ForeColor=Red></asp:Label>&nbsp
                    <asp:CustomValidator ID="rvlOncology" runat="server"  ErrorMessage="Required" 
                          onservervalidate="rvlOncology_ServerValidate" 
                        ></asp:CustomValidator>
                </td>
            </tr>
            <tr>
                <td align=right>
                    <label>Please enter the Prescription Form number</label>
                </td>
                <td>
                    <telerik:RadTextBox ID="rtxtFormNumber" runat="server" Skin="Web20" MaxLength="9">
                        <ClientEvents OnKeyPress="numKeyPress" />
                    </telerik:RadTextBox>&nbsp<asp:Label ID="lblreqFormNumber" runat="server" Text="*" ForeColor=Red></asp:Label>&nbsp
                    <asp:CustomValidator ID="rvlFormNumber" runat="server" 
                        ErrorMessage="Required" 
                         onservervalidate="rvlFormNumber_ServerValidate" 
                        ></asp:CustomValidator>
                </td>
            </tr>
            <tr>
                <td align=right>
                    <label>Please enter the special authority number</label>
                </td>
                <td>
                    <telerik:RadTextBox ID="rtxtSLANumber" runat="server" Skin="Web20" MaxLength="10">
                        <ClientEvents OnKeyPress="numKeyPress" /></telerik:RadTextBox>&nbsp
                    <asp:CustomValidator ID="rvlSLANumber" runat="server" 
                        ErrorMessage="Must be numeric" 
                         onservervalidate="rvlSLANumber_ServerValidate" 
                        ></asp:CustomValidator>
                </td>
            </tr>
            <tr>
                <td align=right>
                    <label>Please select the Specialist endorser</label>
                </td>
                <td>
                    <telerik:RadComboBox ID="rcboSpecialist" runat="server" MarkFirstMatch="True" 
                        Width="248px" Skin="Web20" OnClientSelectedIndexChanged="rcboSpecialistChanged" >
                    </telerik:RadComboBox>&nbsp
                    <input type=button ID="rbtnClearSpecialist" onclick="ClearSpecialist()" value="Clear">
                    
                </td>
            </tr>
            <tr>
                <td align=right>
                    <label>Please enter the Endorsement date</label>                </td>
                <td>
                    <telerik:RadDatePicker ID="rdatEndorsement" runat="server"
                    DateInput-DateFormat="dd/MM/yyyy" DateInput-DisplayDateFormat="dd/MM/yyyy" DateInput-SelectionOnFocus="SelectAll" Skin="Web20">
                    </telerik:RadDatePicker>
                    &nbsp<asp:Label ID="lblreqEndorsement" runat="server" Text="*" ForeColor=Red style="visibility:hidden"></asp:Label>&nbsp
                    <asp:CustomValidator ID="rvlEndorsementDate" runat="server" 
                        ErrorMessage="Required" 
                         onservervalidate="rvlEndorsementDate_ServerValidate" 
                        ></asp:CustomValidator>
                </td>
            </tr>
            <tr>
                <td align=right>
                    <label>Full wastage</label>
                </td>
                <td>
                    <asp:CheckBox ID="chkWastage" runat="server"  />
                </td>
            </tr>
        </table>
        <br />
        <br />
        <div style="position:absolute;bottom:10px;right:0px">
            <asp:Button ID="rbtnOK" runat="server" 
                Skin="Web20" onclick="rbtnOK_Click" Width=60px AccessKey="O" Text="OK"  >
                </asp:Button>&nbsp
            <Button   
                 onclick="CloseForm()" Width=60px>Cancel</Button>&nbsp&nbsp            
        </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
