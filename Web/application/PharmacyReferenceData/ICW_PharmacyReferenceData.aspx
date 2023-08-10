<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_PharmacyReferenceData.aspx.cs" Inherits="application_PharmacyReferenceData_ICW_PharmacyReferenceData" %>
<%@ Register src="../pharmacysharedscripts/SiteColourPanelControl.ascx" tagname="SiteColourPanelControl"    tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SiteNamePanelControl.ascx"   tagname="SiteNamePanelControl"      tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx"        tagname="ProgressMessage"           tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/EditList/EditList.ascx"      tagname="EditList"                  tagprefix="uc" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Pharmacy Reference Data</title>
    <base target="_self" />

    <link href="../../style/ScrollTableContainer.css"                       rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"                                 rel="stylesheet" type="text/css" />
	<link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../pharmacysharedscripts/EditList/EditList.css"             rel="stylesheet" type="text/css" />
    <link href="style/PharmacyReferenceData.css"                            rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../SharedScripts/lib/json2.js"                          defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"                       defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/EditList/EditList.js"          async></script>
    <script type="text/javascript" src="script/PharmacyReferenceData.js"                        async></script>
    <script type="text/javascript">
        var sessionID  = <%= SessionInfo.SessionID  %>;
        var siteNumber = <%= SessionInfo.SiteNumber %>;
    </script>

    <style type="text/css">html, body{height:93.5%}</style>  <!-- Ensure page is full height of screen -->    
</head>
<body onresize="body_onResize();" onload="body_onResize();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="icw-container">
        <!-- update progress message -->
        <uc:ProgressMessage ID="progressMessage" runat="server" />

        <asp:Panel ID="pnMain" runat="server">
        <table id="tbl" style="height:100%;" cellpadding="0" cellspacing="0">
            <tr style="vertical-align:top;">
                <td id="trViews" runat="server" class="ViewList" style="width:225px">
                    <div class="ViewHeader">Select Data Type:</div>
                    <asp:UpdatePanel ID="upViews" runat="server">
                    <ContentTemplate>
                        <asp:HiddenField ID="hfSelectedViewKey" runat="server" />
                        
                        <asp:Button ID="btnWarnings"     runat="server" OnClick="btnView_OnClick" Text="Warnings"            />
                        <asp:Button ID="btnInstructions" runat="server" OnClick="btnView_OnClick" Text="Instructions"        />
                        <asp:Button ID="btnDrugMsgCode"  runat="server" OnClick="btnView_OnClick" Text="Drug Message Codes"  />
                        <asp:Button ID="btnFFLabel"      runat="server" OnClick="btnView_OnClick" Text="Free Format Label"   />
                        <asp:Button ID="btnReason"       runat="server" OnClick="btnView_OnClick" Text="Finance Reason Code" />
                    </ContentTemplate>
                    </asp:UpdatePanel>
                </td>
                <td>
                    <table cellpadding="0" cellspacing="0" style="background-color:#DDDDDD; width:98%;height:25px;">
                        <tr>
                            <td><uc:SiteNamePanelControl ID="siteNamePanel" runat="server" /></td>
                            <td>&nbsp;</td>
                            <td style="width:5%;"><uc:SiteColourPanelControl ID="SiteColourPanelControl1" runat="server" /></td>
                        </tr>
                    </table>

                    <hr />

                    <asp:UpdatePanel ID="upView" runat="server">
                    <ContentTemplate>
                        <div id="divView" runat="server" onkeydown="divView_onkeydown();">
                            <asp:MultiView ID="multiView" runat="server">
                                <asp:View ID="vEditList" runat="server">
                                    <span style="float: left; vertical-align: middle;">
                                        Filter Code:&nbsp;
                                        <asp:TextBox ID="tbFilter"       runat="server" style="width:75px" onkeydown="if (window.event.keyCode == 13) { $('#btnSearch').click(); event.returnValue=false; event.cancel = true;}" />&nbsp;
                                        <asp:Button  ID="btnSearch"      runat="server" Text="Search"       CssClass="PharmButton" OnClick="btnSearch_OnClick" />
                                        <asp:Button  ID="btnClearFilter" runat="server" Text="Clear Filter" CssClass="PharmButton" OnClick="btnClearFilter_OnClick" />
                                        <asp:HiddenField ID="hfCurrentActiveFilter" runat="server" />
                                    </span>

                                    <span id="spanLanguageDescritpion" runat="server" style="float:right; padding-right:20px;">Language: </span>
                                    <br />
                                    <br />

                                    <uc:EditList ID="editList" runat="server" AllowMultiCopy="true" />
                                </asp:View>
                            </asp:MultiView>
                        </div>
                    </ContentTemplate>
                    </asp:UpdatePanel>
                </td>
            </tr>
            <tr id="trButtons" style="vertical-align:top;height:50px;">
                <td class="ViewList" style="padding-left:5px;padding-right:5px;" />
                <td style="padding-left:10px;padding-right:35px;">
                    <span style="float:left">
                        <asp:Button ID="btnAdd"     runat="server" CssClass="PharmButton" Text="Add..."  AccessKey="A" OnClientClick="btnAdd_OnClick();    return false;" />&nbsp;&nbsp;
                        <asp:Button ID="btnEdit"    runat="server" CssClass="PharmButton" Text="Edit..." AccessKey="E" OnClientClick="btnEdit_OnClick();   return false;" />&nbsp;&nbsp;
                        <asp:Button ID="btnDelete"  runat="server" CssClass="PharmButton" Text="Delete"  AccessKey="D" OnClientClick="btnDelete_OnClick(); return false;" />
                    </span>
                    <span style="float:right">
                        <asp:Button ID="btnPrint"   runat="server" CssClass="PharmButton" Text="Print" AccessKey="P" OnClientClick="btnPrint_OnClick(); return false;" />
                    </span>
                </td>    
            </tr>
        </table>
        </asp:Panel>
    </div>

    <!-- Printer site select popup -->
    <div id="divSites" style="display:none;">
        <div style="width:100%;height:100%">
            Select sites to print:<br />
            <br />
            <div style="max-height:250px;">
                <asp:CheckBoxList runat="server" ID="cblSites" />
            </div>                            
        </div>
    </div>
    </form>
</body>
</html>
