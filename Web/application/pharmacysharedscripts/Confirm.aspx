<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Confirm.aspx.cs" Inherits="application_pharmacysharedscripts_Confirm" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Emis Health</title>
    <base target=_self>

    <link href="../../style/PharmacyDefaults.css"    rel="stylesheet" type="text/css" />    

    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>

    <script type="text/javascript">
        SizeAndCentreWindow("500px", "150px");

        var escapeReturnValue = <%= this.EscapeReturnValue %>;
    </script>
</head>
<body onkeydown="if (event.keyCode == 27) { window.returnValue = escapeReturnValue; window.close(); }" onunload="if (window.returnValue == undefined)  { window.returnValue = escapeReturnValue; }">
    <form id="form1" runat="server">
    <div style="margin:10px;">
        <table>
            <tr>
                <td style="vertical-align: text-top;"><img src="../../images/ocs/questionmark.png" width="25px" height="25px" /></td>
                <td><p runat="server" ID="lbMsg" /></td>
            </tr>
        </table>        
        <br /><br />
        <div id="divButtons" runat="server" style="float:right; padding-right: 10px;margin-top:5px;vertical-align:middle;">
            <input id="btnOK"     runat="server" type="button" value="OK"     class="PharmButton" runat="server" onclick="window.returnValue=true;  window.close();" />&nbsp;
            <input id="btnCancel" runat="server" type="button" value="Cancel" class="PharmButton" runat="server" onclick="window.returnValue=false; window.close();" />
        </div>
    </div>
    </form>
</body>
</html>
