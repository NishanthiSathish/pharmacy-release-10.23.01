<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ValidationErrors.aspx.cs" Inherits="application_RepeatDispensingBatchProcessor_ValidationErrors" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
<link href="../../style/application.css" rel="stylesheet" type="text/css" />
<style>
html,body{ height:auto; width:auto; }
</style>
</head>
<script language=javascript>
    heightVal = 700;
    widthVal = 1000;
    leftVal = (screen.width - widthVal) / 2;
    topVal = (screen.height - heightVal) / 2;
    window.dialogHeight = heightVal + "px";
    window.dialogWidth = widthVal + "px";
    window.dialogLeft = leftVal;
    window.dialogTop = topVal;

    function PrintForm() {
        window.print();
    }

</script>

<body>
    <form id="form1" runat="server">
        <div align=right>
            <input type=button class=ICWButton value="Print" onclick="PrintForm()" />
        </div>
        <div>
            <h1 runat=server id="lblBatchDescription"></h1>
        </div>
        <table style="height:100%; width:100%; overflow:auto;" bordercolor="Black" border=true> 
            <thead>
                <tr id="trHeader" class="PaneTitleBarActive">
                    <th>Error</th>
                    <th>Object(s)</th>
                    <th>Exception</th>
                    <th>Code</th>
                </tr>
            </thead>
            <tbody runat=server id="tbdy">
                <asp:Repeater ID="rptData" runat=server>
                    <ItemTemplate>
                        <tr class="grid_row">
                            <Td><%# DataBinder.Eval(Container.DataItem, "ErrorMessage") %></Td>
                            <td><%# DataBinder.Eval(Container.DataItem, "KeyValue") %></td>
                            <td><%# DataBinder.Eval(Container.DataItem, "Exception") %></td>
                            <td><%# DataBinder.Eval(Container.DataItem, "ErrorCode")%></td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </form>
</body>
</html>
