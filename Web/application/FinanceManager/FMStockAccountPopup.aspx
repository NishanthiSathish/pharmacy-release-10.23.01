<%@ Page Language="C#" AutoEventWireup="true" CodeFile="FMStockAccountPopup.aspx.cs" Inherits="application_FinanceManager_FMStockAccountPopup" %>
<%@ Import Namespace="ascribe.pharmacy.shared"              %>
<%@ Import Namespace="ascribe.pharmacy.financemanagerlayer" %>

<%@ Register src="controls/FMStockAccountSheet.ascx" tagname="FMStockAccountSheet" tagprefix="fm" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "FMStockAccountPopup.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base target="_self" />
        
    <link href="../../style/PharmacyDefaults.css"   rel="stylesheet" type="text/css" />
    <link href="style/ICW_FinanceManager.css"       rel="stylesheet" type="text/css" />
    <link href="style/FMStockAccountSheet.css"      rel="stylesheet" type="text/css" />
    
    <script language="javascript" type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"                             async></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/json2.js"                                            async></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/icwcombined.js"                                      defer></script>
    <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"                           async></script>
    <script language="javascript" type="text/javascript" src="../FinanceManagerSettings/scripts/FMStockAccountSheetLayoutEditor.js" defer></script>
    <script language="javascript" type="text/javascript" src="script/Utils.js"                                                      defer></script>
    <script language="javascript" type="text/javascript" src="script/FMStockAccountPopup.js"                                        async></script>
    <script language="javascript" type="text/javascript" src="script/FMStockAccountSheet.js"                                        async></script>
    <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"                          defer></script>
    

    <script type="text/javascript">
        SizeAndCentreWindow("920px", "700px");        

        var MNU_EDIT_SECTION            = 1;
        var sectionType_AccountSection  = '<%= EnumDBCodeAttribute.EnumToDBCode(WFMStockAccountSheetSectionType.AccountSection) %>';
        var sessionID                   = <%= SessionInfo.SessionID %>;        
        var ID_selectedForEdit          = 0;
    </script>
</head>
<body onload="form_onload();" onkeydown="if (event.keyCode == 27) { window.close(); }">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <div class="container" style="margin-top:15px;" >
        <div id="divSheets" style="overflow-y:scroll;height:600px;">
            <fm:FMStockAccountSheet ID="stockAccountSheet" runat="server" />
        </div>

        <hr />
                                
        <asp:Panel ID="pnFooter" runat="server" style="height:40px">
            <asp:UpdatePanel ID="upFooter" runat="server">
            <ContentTemplate>    
            <table style="width: 100%">
                <tr>
                    <td style="width:33%; text-align:left;"  ></td>
                    <td style="width:33%; text-align:center;"><asp:Button ID="btnOK"    CssClass="PharmButton" Text="OK"    runat="server" Width="80px" OnClientClick="window.close(); return false;" /></td>
                    <td style="width:33%; text-align:right;" >
                        <asp:Button ID="btnExportToCSV" CssClass="PharmButton" Text="Export To CSV..." runat="server" Width="125px" onClientClick="btnExportToCSV_OnClick(); return false;"               UseSubmitBehavior="False" CausesValidation="False" />&nbsp;&nbsp;
                        <asp:Button ID="btnPrint"       CssClass="PharmButton" Text="Print"            runat="server" Width="80px"  OnClientClick="btnPrint_OnClick(); return false;"       accesskey="P" UseSubmitBehavior="False" CausesValidation="False" />&nbsp;
                    </td>
                </tr>
            </table>
            </ContentTemplate>    
            </asp:UpdatePanel>
        </asp:Panel>              
    </div>

    <!-- update progress message -->
    <div id="divUpdateProgress" style="display:none;position:absolute;width:100%;z-index:9900;top:0px;left:0px;height:100%;">
    <table width=100% height=100% style="display:none;">
    <tr valign=center>
	    <td align=center>
            <div class="ICWStatusMessage" style="vertical-align:middle;height:75px;"><img src="../../images/Developer/spin_wait.gif" /><span id="spanMsg">Processing...</span></div>
        </td>
    </tr>     
    </table>           
    </div>
    </form>

    <iframe style="display:none;" id="fraSaveAs" src="../pharmacysharedscripts/SaveAs.aspx" border="0" frameborder="no" disabled noresize />
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
