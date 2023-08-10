<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FMStockAccountDrillDown.aspx.cs" Inherits="application_FinanceManager_FMStockAccountDrillDown" %>
<%@ Import Namespace="ascribe.pharmacy.shared"  %>
<%@ Import Namespace="Newtonsoft.Json"          %>

<%@ Register src="../PharmacyLogViewer/DisplayLogRows.ascx" tagname="LogRows" tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base target=_self>
    
    <link href="../../style/icwcontrol.css"         rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"   rel="stylesheet" type="text/css" />
    <link href="style/FMStockAccountDrillDown.css"  rel="stylesheet" type="text/css" />
    
    <script language="javascript" type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"     async></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/json2.js"                    async></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/icwcombined.js"              async></script>
    <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"   async></script>
    <script language="javascript" type="text/javascript" src="script/Utils.js"                              defer></script>
    <script language="javascript" type="text/javascript" src="script/FMStockAccountDrillDown.js"            async></script>
    
    <script type="text/javascript">
        SizeAndCentreWindow("900px", "610px");        
        
        var sessionID                    = <%= SessionInfo.SessionID                   %>;
        var summaryPage                  = <%= this.summaryPage.ToString().ToLower()   %>;
        var discrepancies                = <%= this.discrepancies.ToString().ToLower() %>;
        var sheetSettingsStr             ='<%= JsonConvert.SerializeObject(settings)   %>';
        var wfmStockAccountSheetLayoutID = <%= this.wfmStockAccountSheetLayoutID       %>;        
    </script>    
        
    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body onkeydown="if (event.keyCode == 27) { window.close(); }">
    <form id="form1" runat="server">
    <div class="icw-container">
        <br />
        
        <div style="text-align: center; margin: 0px; padding: 0px; width: 100%;">
            <span ID="lbHeading"   runat="server" class="fm-drilldown-heading">Stock Balance Sheet</span><br />
            <span ID="lbSites"      runat="server" class="fm-drilldown-info">Site No: 123 234 456</span><br />
            <span ID="lbDatePeriod" runat="server" class="fm-drilldown-info">Period: - </span><br />
            <span ID="lbDrug"       runat="server" class="fm-drilldown-info"></span>
        </div>
        
        <br />
        
        <div style="height:435px;overflow-y:scroll;">
            <asp:Table ID="table" runat="server" CssClass="fm-drilldown-table" CellSpacing="0" />
            <div id="divNoTransactionsMsg" runat="server" style="width:95%;text-align:center;">
                <br />
                <%= discrepancies ? "No discrepancies" : "No stock transactions" %>
            </div>
        </div>
    
        <hr />
                                
        <asp:Panel ID="pnFooter" runat="server" style="height:40px;">
            <table style="width: 100%">
                <tr>
                    <td style="width:33%; text-align:left;"  ></td>
                    <td style="width:33%; text-align:center;"><asp:Button ID="btnOK"          CssClass="PharmButton" Text="OK"            runat="server" AccessKey="O" Width="80px"  OnClientClick="window.close(); return false;"           /></td>
                    <td style="width:33%; text-align:right;" >
                        <asp:Button ID="btnPrint"       CssClass="PharmButton" Text="Print"         runat="server" AccessKey="P" Width="100px" OnClientClick="btnPrint_OnClick(); return false;"        />&nbsp;&nbsp;
                        <asp:Button ID="btnExportToCSV" CssClass="PharmButton" Text="Export To CSV" runat="server" AccessKey="E" Width="100px" OnClientClick="btnExportToCSV_OnClick(); return false;"  />&nbsp;
                    </td>
                </tr>
            </table>
        </asp:Panel>              
    </div>
    </form>

    <iframe style="display:none;" id="fraSaveAs" src="../pharmacysharedscripts/SaveAs.aspx" border="0" frameborder="no" disabled noresize />
</body>
</html>
