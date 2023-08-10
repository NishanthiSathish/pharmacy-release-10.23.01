﻿<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_FinanceManager.aspx.cs" Inherits="application_FinanceManager_ICW_FinanceManager" %>
<%@ Import Namespace="ascribe.pharmacy.shared"              %>
<%@ Import Namespace="ascribe.pharmacy.financemanagerlayer" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik"  %>
<%@ Register src="controls/FMStockAccountSheet.ascx"        tagname="FMStockAccountSheet"   tagprefix="fm" %>
<%@ Register src="controls/FMAccountSheet.ascx"             tagname="FMAccountSheet"        tagprefix="fm" %>
<%@ Register src="controls/FMGrniSheet.ascx"                tagname="FMGrniSheet"           tagprefix="fm" %>
<%@ Register src="../PharmacyLogViewer/DisplayLogRows.ascx" tagname="LogRows"               tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%= SessionInfo.SessionID %>';
    var desktopURL = "../sharedscripts/CheckSessionExists.aspx";
    var pageName = "ICW_FinanceManager.aspx";
    //alert(sessionId);
    //alert(desktopURL + " " + pageName);
    windowModal_CheckSession(sessionId, desktopURL, "CheckSessionExists" + "|" + pageName);
</script>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <base target="_self" />
        
    <link href="../../style/PharmacyDefaults.css"   rel="stylesheet" type="text/css" />
    <link href="style/ICW_FinanceManager.css"       rel="stylesheet" type="text/css" />
    <link href="style/FMGrniSheet.css"              rel="stylesheet" type="text/css" />
    <link href="style/FMAccountSheet.css"           rel="stylesheet" type="text/css" />
    <link href="style/FMStockAccountSheet.css"      rel="stylesheet" type="text/css" />
    
    <script language="javascript" type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"                             async></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/json2.js"                                            async></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/icwcombined.js"                                      defer></script>
    <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"                           defer></script>
    <script language="javascript" type="text/javascript" src="../FinanceManagerSettings/scripts/FMStockAccountSheetLayoutEditor.js" defer></script>
    <script language="javascript" type="text/javascript" src="script/Utils.js"                                                      defer></script>
    <script language="javascript" type="text/javascript" src="script/ICW_FinanceManager.js"                                         async></script>
    <script language="javascript" type="text/javascript" src="script/FMStockAccountSheet.js"                                        defer></script>
    <script language="javascript" type="text/javascript" src="script/FMAccountSheet.js"                                             defer></script>
    <script language="javascript" type="text/javascript" src="script/FMGrniSheet.js"                                                defer></script>
    <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"                          defer></script>

    <telerik:RadCodeBlock ID="CodeBlock" runat="server">
    <script type="text/javascript">
        var MNU_EDIT_SECTION            = 1;
        var sectionType_AccountSection  = '<%= EnumDBCodeAttribute.EnumToDBCode(WFMStockAccountSheetSectionType.AccountSection) %>';
        var sessionID                   = <%= SessionInfo.SessionID %>;        
        var ID_selectedForEdit          = 0;
    </script>
    </telerik:RadCodeBlock>            
    
    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body onresize="body_onResize();" onload="form_onload();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    
    <div style="margin-left:15px;margin-right:15px;margin-top:20px;height:19px;">
        <%-- <telerik:RadTabStrip runat="server" ID="RadTabStrip1" OnClientTabSelected="tabSelected" > 08Jul13 XN 65597 add scrolling of tabs --%>
        <telerik:RadTabStrip runat="server" ID="tabButtons" OnClientTabSelected="tabSelected" ScrollChildren="true" PerTabScrolling="true" ondragstart="return false;" > 
            <Tabs /> 
        </telerik:RadTabStrip>
    </div>
        
    <div class="container" >
        <div id="divSheets" style="overflow-y:scroll;">&nbsp;</div>
        
        <hr />
                                
        <asp:Panel ID="pnFooter" runat="server" style="height:40px">
            <asp:UpdatePanel ID="upFooter" runat="server">
            <ContentTemplate>    
                <div style="float:left; margin-left:5px;">
                    <span id="spanAddStockAccountSheet" runat="server"><asp:Button ID="btnAddStockAccountSheet" CssClass="PharmButton" Text="Stock Balance Sheet..." runat="server" AccessKey="S" Width="150px" OnClientClick="btnAddStockAccountSheet_OnClick(); return false;" />&nbsp;&nbsp;</span>
                    <span id="spanAddAccountSheet"      runat="server"><asp:Button ID="btnAddAccountSheet"      CssClass="PharmButton" Text="Account Enquiry..."     runat="server" AccessKey="A" Width="150px" OnClientClick="btnAddAccountSheet_OnClick(); return false;"      />&nbsp;&nbsp;</span>
                    <span id="spanAddGRNISheet"         runat="server"><asp:Button ID="btnAddGRNISheet"         CssClass="PharmButton" Text="GRNI Report..."         runat="server" AccessKey="G" Width="150px" OnClientClick="btnAddGRNISheet_OnClick(); return false;"         />&nbsp;&nbsp;</span>
                                                                       <asp:Button ID="btnRemoveSheet"          CssClass="PharmButton" Text="Delete"                 runat="server" AccessKey="R" Width="75px"  OnClientClick="btnRemoveSheet_OnClick(); return false;"          />
                </div>

                <div style="float:right; margin-right:5px;">
                    <asp:Button ID="btnUpdateData"  CssClass="PharmButton" Text="Update Data"      runat="server" Width="100px" OnClick="btnUpdateData_OnClick" Visible="false" />&nbsp;&nbsp;
                    <asp:Button ID="btnExportToCSV" CssClass="PharmButton" Text="Export To CSV..." runat="server" Width="125px" onClientClick="btnExportToCSV_OnClick(); return false;"               UseSubmitBehavior="False" CausesValidation="False" />&nbsp;&nbsp;
                    <asp:Button ID="btnPrint"       CssClass="PharmButton" Text="Print"            runat="server"               onClientClick="btnPrint_OnClick(); return false;"       accesskey="P" UseSubmitBehavior="False" CausesValidation="False" />
                </div>
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
    <iframe id="CheckSessionExists" application="yes" style="display: none;"></iframe>
</body>
</html>
