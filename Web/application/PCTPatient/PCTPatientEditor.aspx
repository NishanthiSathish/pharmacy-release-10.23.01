<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PCTPatientEditor.aspx.cs" Inherits="application_PCTPatient_PCTPatientEditor" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head id="Head1" runat="server">
    <script language="javascript" src="../sharedscripts/icwfunctions.js"></script>
    <script type="text/javascript" src="../sharedscripts/icw.js"></script>    
    <script type="text/javascript" src="../sharedscripts/DateLibs.js"></script>
    <script type="text/javascript" src="../sharedscripts/Controls.js"></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"></script>
    <title></title>
    <script type="text/javascript">


        function KeyPressed(event) // Called whenever a keypress event is fired, assigned to body element
        {
            event = event || window.event; // Capture browser or window event (such as tab in IE)
            if (event.keyCode == 27) // ESC
            {
                document.getElementById('btnCancel').click();
            }
            else if (event.altKey && event.keyCode == 83)//Alt + S
            {
                document.getElementById('btnSave').click();
            }
        }
        
        function txtHUHCNo_KeyUp()
        {
            if (document.getElementById('txtHUHCNo').value.length > 0)
            {
                document.getElementById('lblHUHCExp').style.visibility = 'visible';
                document.getElementById('txtHUHCExp').style.visibility = 'visible';
                document.getElementById('imgHUHCExp').style.visibility = 'visible';
            }
            else
            {
                document.getElementById('lblHUHCExp').style.visibility = 'hidden';
                document.getElementById('txtHUHCExp').style.visibility = 'hidden';
                document.getElementById('imgHUHCExp').style.visibility = 'hidden';
            }
            CheckExpired();
        }

        function ToggleCSCDate()
        {
            if (document.getElementById('optCSC').checked)
            {
                document.getElementById('lblCSCExp').style.visibility = 'visible';
                document.getElementById('txtCSCExp').style.visibility = 'visible';
                document.getElementById('imgCSCExp').style.visibility = 'visible';
            }
            else
            {
                document.getElementById('lblCSCExp').style.visibility = 'hidden';
                document.getElementById('txtCSCExp').style.visibility = 'hidden';
                document.getElementById('imgCSCExp').style.visibility = 'hidden';
            }
            CheckExpired();
        }

        function MonthView_Selected(controlID)
        {
            CheckExpired();
        }
           

        function DateDiffDays(date1, date2)
        {
            var d1 = new Date(date1);
            var d2 = new Date(date2);
            d1.setHours(0);
            d1.setMinutes(0);
            d1.setSeconds(0);
            d1.setMilliseconds(0);
            d2.setHours(0);
            d2.setMinutes(0);
            d2.setSeconds(0);
            d2.setMilliseconds(0);
            var t2 = d2.getTime();
            var t1 = d1.getTime();
            return parseInt((t2-t1)/(24*3600*1000));
        }
        
        function CheckExpired()
        {
            var now = new Date();
            if (document.getElementById('optCSC').checked && document.getElementById('txtCSCExp').value.length > 0 && DateDiffDays(UKToUniversalDate(document.getElementById('txtCSCExp').value),now) > 0)
            {
                document.getElementById('lblCSCExpValid').style.visibility = 'visible';
            }
            else
            {
                document.getElementById('lblCSCExpValid').style.visibility = 'hidden';
            }
            if (document.getElementById('txtHUHCNo').value.length > 0 && document.getElementById('txtHUHCExp').value.length > 0 && DateDiffDays(UKToUniversalDate(document.getElementById('txtHUHCExp').value),now) > 0)
            {
                document.getElementById('lblHUHCExpValid').style.visibility = 'visible';
            }
            else
            {
                document.getElementById('lblHUHCExpValid').style.visibility = 'hidden';
            }
        }

        function optCSC_Click()
        {
            ToggleCSCDate();
        }
        
        function optPRH_Click()
        {
            ToggleCSCDate();
        }
        
        function optNoConc_Click()
        {
            ToggleCSCDate();
        }
        
        function EndRequest()
        {
            PageLoadAndPostback();
        }
        
        function PageLoadAndPostback()
        {
            txtHUHCNo_KeyUp();
            optCSC_Click();

        }
        
        function PageLoad()
        {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest  (EndRequest);
            PageLoadAndPostback();
        }
        
        function UKToUniversalDate(ukDate)
        {
            var univDate = new Date(parseInt(ukDate.toString().substring(6,10),10), parseInt(ukDate.substring(3,5),10) - 1, parseInt(ukDate.substring(0,2),10));
            return univDate;
        }
        
        function imgHUHCExp_Click()
        {
            var control = document.getElementById('txtHUHCExp');
            ShowMonthViewWithDate(control, control ,control.value);
            CheckExpired();
        }

        function imgCSCExp_Click()
        {
            var control = document.getElementById('txtCSCExp');
            ShowMonthViewWithDate(control, control ,control.value);
            CheckExpired();
        }
        
        
        

    </script>

<link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .style1
        {
            width: 167px;
        }
        .style2
        {
            width: 477px;
        }
    </style>
    <style type="text/css">html, body{height:100%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body onkeydown="KeyPressed(event)" onload="PageLoad()" >
    <form id="mainForm" runat="server" style="width: 100%">
        <asp:ScriptManager ID="ScriptManager1" runat=server EnablePageMethods=true></asp:ScriptManager>
        <asp:UpdatePanel ID="upUpdatePanelForForm" runat=server UpdateMode=Conditional>
            <ContentTemplate>
                <asp:HiddenField ID="hdnEntityID" runat="server" />
                <table cellspacing="0" style="margin-bottom:5px">
                    <tr>
                        <td>
                            <asp:Label ID="lblNHI" runat="server" Text="NHI No." ></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtNHINo" runat="server" MaxLength="10" ReadOnly=true />
                            <asp:Label ID="lblNHIValid" runat="server" MaxLength="10" Text="Invalid" CssClass="BrokenRule_Text" Visible=false/>
                        </td>
                    </tr>
                    <tr>
                        <td >
                            <asp:Label ID="lblHUHCNo" runat="server" Text="HUHC No." ></asp:Label>
                        </td>
                        <td >
                            <asp:TextBox ID="txtHUHCNo" runat="server" MaxLength="10"  />
                        </td>
                    </tr>
                    <tr>
                        <td >
                            <asp:Label ID="lblHUHCExp" runat="server" Text="HUHC Expiry Date" ></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtHUHCExp" runat="server" validchars="DATE:dd/mm/yyyy" Width="75px" CssClass="MandatoryField" />&nbsp
                                <img id="imgHUHCExp" src="..\..\images\ocs\show-calendar.gif" onclick="imgHUHCExp_Click();" style="border: 0">
                            <asp:Label ID="lblHUHCExpValid" runat="server" Text="Expired" style="visibility:hidden" CssClass="BrokenRule_Text"/>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblCSC" runat="server" Text="CSC" ></asp:Label>
                        </td>
                        <td>
                            <asp:RadioButton ID="optCSC" GroupName="ConTypeGroup" runat=server />
                        </td>
                    </tr>
                    <tr>
                        <td >
                            <asp:Label ID="lblCSCExp" runat="server" Text="CSC Expiry Date" ></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtCSCExp" runat="server" validchars="DATE:dd/mm/yyyy"  Width="75px"  CssClass="MandatoryField" />&nbsp
                                <img id="imgCSCExp" src="..\..\images\ocs\show-calendar.gif" onclick="imgCSCExp_Click();" style="border: 0">
                            <asp:Label ID="lblCSCExpValid" runat="server" Text="Expired" style="visibility:hidden"  CssClass="BrokenRule_Text"/>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblPRH" runat="server" Text="Permanent Resident of Hokianga" ></asp:Label>
                        </td>
                        <td>
                            <asp:RadioButton ID="optPRH" GroupName="ConTypeGroup" runat=server />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblNoConc" runat="server" Text="No concessionary type"></asp:Label>
                        </td>
                        <td>
                            <asp:RadioButton ID="optNoConc" GroupName="ConTypeGroup" runat=server />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lbl" runat="server" Text="PHO Registered" ></asp:Label>
                        </td>
                        <td>
                            <asp:CheckBox ID="chkPHO" runat=server />
                        </td>
                    </tr>
                    <tr>
                        <td colspan=2 align=right>
                        </td>
                    </tr>
                </table>
                <div align=right>
                    <asp:Button ID="btnSave" runat="server" Text="Save" onclick="btnSave_Click" class="ICWButton" UseSubmitBehavior="false" />&nbsp
                    <asp:Button ID="btnCancel" runat="server" Text="Cancel" onclick="btnCancel_Click" class="ICWButton" />&nbsp
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
