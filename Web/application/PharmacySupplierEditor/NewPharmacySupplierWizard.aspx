<%@ Page Language="C#" AutoEventWireup="true" CodeFile="NewPharmacySupplierWizard.aspx.cs" Inherits="application_PharmacySupplierEditor_NewPharmacySupplierWizard" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register src="../pharmacysharedscripts/QuesScrl/QuesScrl.ascx" tagname="QuesScrl"        tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx"   tagname="ProgressMessage" tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "NewPharmacySupplierWizard.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Add Supplier Wizard</title>
    <base target="_self" />

	<link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/ScrollTableContainer.css"                       rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"                                 rel="stylesheet" type="text/css" />
    <link href="../pharmacysharedscripts/QuesScrl/QuesScrl.css"             rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  async></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"                              defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/QuesScrl/QuesScrl.js"          async></script>
    <script type="text/javascript" src="script/NewPharmacySupplierWizard.js"                    defer></script>    
    <script type="text/javascript">
        SizeAndCentreWindow("750px", "675px");

        var sessionID = <%= SessionInfo.SessionID %>;
        var siteID    = <%= SessionInfo.SiteID    %>;
    </script>
    
    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body onkeydown="body_onkeydown();" onload="body_onload();" >
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <uc:ProgressMessage runat="server" />
    <div class="icw-container-fixed" style="height:655px;">
        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>
            <asp:HiddenField ID="hfCurrentStep" runat="server" />

            <div style="margin-top:10px;margin-left:10px;margin-right:10px;" >
                <asp:HiddenField ID="hfHeaderSuffix" runat="server" />
                <hr />
                <span id="spanHeader" runat="server" class="icw-title" />
                <hr />
            </div>

            <asp:MultiView ID="multiView" runat="server">
                <asp:View ID="vSelectAddMethod" runat="server">
                    <div style="margin:10px">
                        <br />

                        <asp:RadioButtonList ID="rblSelectAddMethod" runat="server" CellPadding="5">
                            <asp:ListItem Text="External Supplier"      Value="0" Selected="True" />
                            <asp:ListItem Text="Internal Supplier"      Value="1" />
                            <asp:ListItem Text="Import from Other Site" Value="2" />
                        </asp:RadioButtonList>
                    </div>                    
                </asp:View>

                <asp:View ID="vSelectSite" runat="server">
                    <div style="margin:10px">
                        <br />

                        <asp:Panel ID="pnSelectSite" runat="server" Height="505px"> <!- scrolls if over 60 sites -->
                            <asp:RadioButtonList ID="rblSelectSite" runat="server" CellPadding="2"  Width="650px" /> <!- adds columns for over 20 sites -->
                        </asp:Panel>
                    </div>                    
                </asp:View>

                <asp:View ID="vFindSupplier" runat="server">
                    <div style="margin:10px;">
                        <asp:HiddenField ID="hfFindSupplierParams" runat="server" />
                        <asp:HiddenField ID="hfFindSupplierID" runat="server" />
                        <iframe id="fraFindSupplier" application="yes" width="100%" height="500px" src="SelectPharmacySupplier.aspx?SessionID=<%= SessionInfo.SessionID %>&WindowID=<%= Request["WindowID"] %>&EmbeddedMode=true<%= hfFindSupplierParams.Value %>"></iframe>
                    </div>
                </asp:View>
    
                <asp:View ID="vEditorControl" runat="server">
                    <asp:HiddenField ID="hfDisplayEditorValidated" runat="server" />
                    <div id="divEditorControl" style="margin:10px;height:520px">
                        <uc:QuesScrl ID="editorControl" runat="server" OnValidated="editorControl_OnValidated" />
                    </div>
                </asp:View>
    
                <asp:View ID="vSelectImportToSites" runat="server">
                    <div style="margin:10px">
                        <asp:Button ID="btnCheckAll"   runat="server" CssClass="PharmButtonSmall" Width="65px" OnClientClick="$('#cblSelectImportToSites :checkbox:enabled').prop('checked', true ); return false;" Text="Check All"   />&nbsp;&nbsp;
                        <asp:Button ID="btnUncheckAll" runat="server" CssClass="PharmButtonSmall" Width="65px" OnClientClick="$('#cblSelectImportToSites :checkbox:enabled').prop('checked', false); return false;" Text="Uncheck All" />
                        <br />
                        <br />

                        <asp:Panel ID="pnSelectImportToSites" runat="server" Height="505px"> <!- scrolls if over 60 sites -->
                            <asp:CheckBoxList ID="cblSelectImportToSites" runat="server" CellPadding="2"  Width="650px" /> <!- adds columns for over 20 sites -->
                        </asp:Panel>
                    </div>
                </asp:View>
            </asp:MultiView>    

            <div style="width:100%;text-align:center;">
                <asp:Label id="errorMessage" CssClass="ErrorMessage" runat="server" Text="&nbsp" />
            </div>

            <div style="position:absolute;bottom:15px;right:25px;width:160px;text-align:right;z-index:99"> 
                <asp:Button ID="btnNext" runat="server" CssClass="PharmButton" Text="Next >" Width="75px" OnClientClick="return btnNext_onclick();" OnClick="btnNext_OnClick" AccessKey="N" />
            </div>

            <div style="position:absolute;bottom:15px;width:99%;text-align:center;"> 
                <asp:Button ID="btnCancel" runat="server" CssClass="PharmButton" Text="Cancel" AccessKey="C" Width="75px" OnClientClick="window.returnValue=null;window.close();return false;" />
            </div>
        </ContentTemplate>
        </asp:UpdatePanel>
    </div>       
    </form>
     <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
