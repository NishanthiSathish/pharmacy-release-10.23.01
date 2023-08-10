<%@ Page Language="C#" AutoEventWireup="true" CodeFile="EditList.aspx.cs" Inherits="application_PNSettings_EditList" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Import Namespace="ascribe.pharmacy.parenteralnutritionlayer" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/application.css"                                rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyGridControl.css"                        rel="stylesheet" type="text/css" />
    <link href="../../style/PN.css"                                         rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/jqueryExtensions.js"           defer></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"                       defer></script>
    <script type="text/javascript" src="../sharedscripts/icw.js"                                async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"        defer></script>
    <script type="text/javascript" src="scripts/EditList.js"                                    defer></script>
    <script type="text/javascript" src="scripts/PNSettings.js"                                  defer></script>    
    <script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"            async></script>
    
    <script type="text/javascript">
        var sessionID           = <%= this.sessionID  %>;
        var siteNumber          = <%= this.siteNumber %>;
        var isMultiSiteEditMode = <%= this.isMultiSiteEditMode.ToString().ToLower() %>;
        var ddsOnWebSiteURL     = '<%= this.dssOnWebSiteUrl %>';
        
        function form_onload() 
        {
            Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(HideProgressMsg);
        }    
    </script>
    
    <style type="text/css">html, body{height:90%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body scroll="no" DataType="<%= this.dataType %>" FilterColumn="<%= this.filterColumn %>" onload="form_onload();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <div>
        <!-- Update pannel mainly here for __doPostBack so does not cause full screen refresh -->
        <asp:UpdatePanel ID="upButtons" runat="server" UpdateMode="Conditional" EnableViewState="False" ChildrenAsTriggers="False">
        <ContentTemplate>    
        </ContentTemplate>
        </asp:UpdatePanel>        
        
        <table style="width: 95%; margin-bottom: 10px; margin-top: 10px;" cellpadding="0" cellspacing="0">
            <tr>
                <td>
                    Filter:&nbsp;<input id="tbFilter" type="text" style="width:200px" onkeyup="tbFilter_onkeyup();" onpaste="tbFilter_onpaste();" onkeydown="if (window.event.keyCode == 13) {event.returnValue=false;event.cancel = true;}" />
                </td>
                <td>
                </td>
                <td style="width: 400px; text-align: right">
<% if (this.allowAddingFromDSSRequest && dataType.EqualsNoCaseTrimEnd("AllProducts")) %>
<% { %>
                    <input ID="btnAddFromRequest" type="button" class="PharmButton" style="height:23px; width:125px;" onclick="btnAddFromDSSRequest_onclick();"  value="Add from Request"  />
<% } %>
<% if (this.allowAdding) %>                
<% { %>
                    <input ID="btnAdd"  type="button" class="PharmButton" style="height: 23px" accesskey="A" onclick="btnAdd_onclick();"  value="Add"  />
<% } %>
                    <input ID="btnEdit" type="button" class="PharmButton" style="height: 23px" accesskey="E" onclick="btnEdit_onclick();" value="Edit" />
                </td>
            </tr>
        </table>
        
        <div style="width: 95%; height: 95%;" onkeydown="grid_onkeydown('gridItemList', event);" >
            <asp:UpdatePanel ID="gridUpdatePanel" runat="server" UpdateMode="Conditional" ChildrenAsTriggers="True">
            <ContentTemplate>    
                    <gc:GridControl id="gridItemList" runat="server" EnableTheming="False" JavaEventDblClick="btnEdit_onclick();" />
                    <div id="gridItemListError" class="ErrorMessage" style="width:100%;text-align:center;">&nbsp;</div>
                    <div style="float:right">
                        <asp:Button ID="btnRefresh" runat="server" Text="Refresh" CssClass="PharmButton" Height="23px" accesskey="R" onclick="btnRefresh_OnClick"                      UseSubmitBehavior="False" CausesValidation="False" />
                        <asp:Button ID="btnPrint"   runat="server" Text="Print"   CssClass="PharmButton" Height="23px" accesskey="P" onClientClick="btnPrint_OnClick(); return false;" UseSubmitBehavior="False" CausesValidation="False" />
                    </div>

                    <!-- Used to display the site to print -->
                    <div id="divSitesToPrint" style="display:none;">
                        <div style="width:100%;height:100%;">
                            Select sites to print:<br />
                            <br />
                            <div style="max-height:400px;">
                                <gc:GridControl id="gridSites" runat="server" EnableTheming="False" JavaEventDblClick="Print(getSelectedRow('gridSites').attr('SiteNumber')); $('#divSitesToPrint').dialog('destroy');" EnterAsDblClick="true" />
                            </div>
                        </div>
                    </div>    
            </ContentTemplate>
            </asp:UpdatePanel>        
        </div>
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
</body>
</html>
