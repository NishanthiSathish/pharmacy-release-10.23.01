<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_CsvImportExport.aspx.cs" Inherits="application_CsvImportExport_ICW_CsvImportExport" %>
<%@ Import Namespace="ascribe.pharmacy.basedatalayer" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Csv Import\Export</title>

    <link href="../../style/application.css"      rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css" rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.11.3.min.js"   async></script>
	<script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"  async></script>
    <script type="text/javascript">
        function btnImport_onclick() 
        {
            if (window.showModalDialog('FileImport.aspx' + getURLParameters(), '', 'status:off;center:Yes') != undefined)
            {
                RAISE_TableSelected(undefined, undefined);
                alert('Data imported successfully');
            }
            return false;
        }

        function RAISE_TableSelected(tableID, rootTableName) 
        {
            window.parent.RAISE_TableSelected(tableID, rootTableName);
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager runat="server" />
    <asp:UpdatePanel ID="upData" runat="server">
    <ContentTemplate>
        <asp:HiddenField ID="hfData" runat="server" />
    </ContentTemplate>
    </asp:UpdatePanel>

    <div style="margin:10px;">
        <asp:Button ID="btnImport" runat="server" CssClass="PharmButton" Text="Import..." Width="75px" Height="40px" Enabled="false" OnClientClick="return btnImport_onclick();" />&nbsp;&nbsp;
        <asp:Button ID="btnExport" runat="server" CssClass="PharmButton" Text="Export..." Width="75px" Height="40px" Enabled="false" OnClick="btnExport_OnClick" />
    </div>
    </form>

    <iframe style="display:none;" id="fraSaveAs" src="../pharmacysharedscripts/SaveAs.aspx" border="0" frameborder="no" disabled noresize />
</body>
</html>
