<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ProductInfoPanel.aspx.cs" Inherits="application_StoresDrugInfoView_ProductInfoPanel" %>

<%@ Register src="../pharmacysharedscripts/PharmacyLabelPanelControl.ascx" tagname="LabelPanelControl" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Product Info Panel</title>
    
    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.4.3.min.js"               async></script>
    <script type="text/javascript" src="../sharedscripts/lib/jqueryui/jquery-ui-1.8.17.min.js"  defer></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"                       defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyLabelPanelControl.js"  async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             defer></script>
    <script type="text/javascript" src="scripts/ProductInfoPanel.js"                            defer></script>
    
    <link href="../sharedscripts/lib/jqueryui/jquery-ui-1.8.17.redmond.css"  rel="stylesheet" type="text/css" />
    <link href="../../style/application.css"                                 rel="stylesheet" type="text/css" />
    <link href="../../style/LabelPanelControl.css"                           rel="stylesheet" type="text/css" />
    <style type="text/css">html,body{ height:auto; width:auto; }</style>  <!-- Overridden _default CSS body style to set it back to normal -->
</head>
<body id="bdyMain" class="grid_body" onkeydown="frameElement.ownerDocument.parentWindow.form_onkeydown(event)">
    <form ID="form1" runat="server" enableviewstate="False">
        <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="True" EnableViewState="False"></asp:ScriptManager>
        
        <!-- main product info panel -->
        <uc1:LabelPanelControl height="50%" width="100%" ID="pnlProductInfoPanel" runat="server" />
        
        <!-- Notes part along the bottom (in an update panel) -->
        <asp:UpdatePanel ID="upNotes" runat="server" EnableViewState="False">
            <ContentTemplate>
                <table class="PanelBackground" width="840px" style="margin-right: -4px; margin-left: 2px;" >
                    <tr>
                        <td class="Caption" nowrap="nowrap">Notes [F2]:</td>
                        <td><asp:Label ID="lblNotesData"   runat="server" CssClass="Text" ></asp:Label></td>
                        <td align="right"><input id="lblEditNotes" type="button" value="Edit..." class="ICWButton" onclick="lblEditNotes_onclick($('#lblNotesData').text())" /></td>
                    </tr>
                </table>
            </ContentTemplate>
        </asp:UpdatePanel>
        
        <!-- Waiting authorisation label (disaplyed it product is waiting authoriation) -->
        <asp:Label ID="lblWaitingAuth"  runat="server" CssClass="Text" style="margin-top: 3px; text-align:center;" Width="840px" Text="Included upon an order awaiting authorisation." Visible="False"></asp:Label>  
    </form>    
</body>
</html>
