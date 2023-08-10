<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PNRuleEditor.aspx.cs" Inherits="application_PNSettings_PNRuleEditor" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target=_self>
    
    <link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/application.css"                                rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyGridControl.css"                        rel="stylesheet" type="text/css" />
    <link href="../../style/PN.css"                                         rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"        defer></script>
    <script type="text/javascript" src="scripts/PNSettings.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"></script>
    
    <script type="text/javascript">
        function form_onload() 
        {
            Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(HideProgressMsg);
        }    
    </script>
     
    <style type="text/css">html, body{height:90%}</style>  <!-- Ensure page is full height of screen -->
    
    <title>PN Rule Editor</title>
</head>
<body scroll="no" onload="form_onload();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <div>
    <asp:UpdatePanel ID="updatePanel" runat="server">
    <ContentTemplate>
        <asp:HiddenField ID="hfRuleID"          runat="server" />
        <asp:HiddenField ID="hfPNRuleNumber"    runat="server" />
        <asp:HiddenField ID="hfOpenDate"        runat="server" />
        <asp:Panel ID="Panel1" runat="server" CssClass="PNSettings" Height="625px" ScrollBars="Vertical" >
            <br />
            <asp:Panel ID="pnGeneralSection" runat="server" CssClass="Section">
                <span class="SectionHeader">General</span>
                <span class="SectionControls">
                    <span ID="lbRuleNumber" runat="server" class="EditControlLabel">Rule Number</span><asp:TextBox ID="tbRuleNumber" runat="server" Width="100px" /><asp:Label ID="lbRuleNumberError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" ></asp:Label><br />
                    <span ID="lbDescription" runat="server" class="EditControlLabel">Description</span><asp:TextBox ID="tbDescription" runat="server" Width="300px" /><asp:Button ID="btnDescription" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('description'); return false;" /><br />
                    <span class="EditControlLabel">&nbsp;</span><asp:Label ID="lbDescriptionError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" ></asp:Label><br />
                    <span ID="lbInUse" runat="server" class="EditControlLabel">In use:</span><asp:CheckBox ID="cbInUse" runat="server" /><br />
                    <span ID="lbPerKilo" runat="server" class="EditControlLabel">Per Kilo:</span><asp:CheckBox ID="cbPerKilo" runat="server" /><br />
                </span>
            </asp:Panel>
            <asp:Panel ID="pnDetailsSection" runat="server" CssClass="Section">
                <span class="SectionHeader">Details</span>
                <span class="SectionControls">
                    <span ID="lbExplanation" runat="server" class="EditControlLabel" style="height:70px;">Explanation</span><asp:TextBox ID="tbExplanation" runat="server" Width="300px" Height="70px" TextMode="MultiLine" /><asp:Button ID="btnExplanation" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('explanation'); return false;" /><br />
                    <span class="EditControlLabel">&nbsp;</span><asp:Label ID="lbExplanationError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" /><br />
                    <span ID="lbRuleSQL" runat="server" class="EditControlLabel" style="height:70px;">Rule SQL</span><asp:TextBox ID="tbRuleSQL" runat="server" Width="300px" Height="70px" TextMode="MultiLine" /><asp:Button ID="btnRuleSQL" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('rulesql'); return false;" /><br />
                    <span class="EditControlLabel">&nbsp;</span><asp:Label ID="lbRuleSQLError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" /><br />
                    <asp:Panel ID="pnCritical" runat="server" > <!-- in panel as may be hidden -->
                        <span ID="lbCritical" runat="server" class="EditControlLabel">Critical</span><asp:CheckBox ID="cbCritical" runat="server" />
                    </asp:Panel>
                </span>
            </asp:Panel>
            <asp:Panel ID="pnIngredientSection" runat="server" CssClass="Section">
                <span ID="lbIngredient" runat="server" class="SectionHeader">Ingredient</span>
                <span class="SectionControls">
                    <asp:TextBox ID="tbIngredient" runat="server" Width="50px" />&nbsp;is supplied by product&nbsp;<asp:DropDownList ID="ddlPNProduct" runat="server" Width="225px" /><br />
                    <asp:Label ID="lbIngredientError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" />
                </span>
            </asp:Panel>
            <asp:Panel ID="pnProformaIngredient" runat="server" CssClass="Section">
                <span ID="lbProformaIngredient" runat="server" class="SectionHeader">Ingredients</span>
                <span class="SectionControls">
                    <span ID="lbVol" runat="server" class="EditControlLabel" style="width:125px">Volume (millilitre)</span><asp:TextBox ID="tbVol" runat="server" Width="60px" ></asp:TextBox><asp:Label ID="lbVolError" runat="server" CssClass="ErrorMessage" ></asp:Label><br />
                    <br />
                    <table>
                        <tr>
                        <td style="vertical-align: top; padding-right:15px;">
                            <asp:Table ID="tbIngredientsLeft" runat="server" CellPadding="0" CellSpacing="0" EnableTheming="False">                    
                            </asp:Table>
                        </td>                    
                        <td style="vertical-align: top">
                            <asp:Table ID="tbIngredientsRigth" runat="server" CellPadding="0" CellSpacing="0" EnableTheming="False">                    
                            </asp:Table>
                        </td>                    
                        </tr>
                    </table>                
                    <div style="width:100%;text-align:center;">
                        <asp:Label ID="lbProformaIngredientError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" />
                    </div>
                </span>
            </asp:Panel>
            <asp:Panel ID="pnUpdateInfoSection" runat="server" CssClass="Section">
                <span class="SectionHeader">Update Info</span><asp:Label ID="lbModifiedInfo" runat="server" /><br />
                <span class="SectionHeader">&nbsp;</span><asp:TextBox ID="tbInfo" runat="server" Width="450px" Height="90px" TextMode="MultiLine" /><br />
                <span class="SectionHeader">&nbsp;</span><asp:Label ID="lbInfoError" runat="server" CssClass="ErrorMessage" />
            </asp:Panel>
        </asp:Panel>        
        <div style="text-align:center; width: 100%; padding-top: 20px;">
            <table style="width: 100%">
                <tr>
                    <td style="text-align:left;width:33%">
                        <asp:LinkButton runat="server" id="lbtSites" CssClass="LinkButton" Width="220px" OnClientClick="lbtSelectSites_onclick(); return false;" ToolTip="Click to change sites to replicate to" />
                    </td>
                    <td style="text-align:center; width:33%">
                        <asp:Button CssClass="PharmButton" ID="btnSave"   runat="server" Text="Save"   OnClick="Save_Click" />&nbsp;&nbsp;&nbsp;
                        <asp:Button CssClass="PharmButton" ID="btnCancel" runat="server" Text="Cancel" OnClientClick="window.close(); return false;" />
                    </td>
                    <td style="text-align:right; width:33%">
                        <asp:Button CssClass="PharmButton" ID="btnPrint"  runat="server" Text="Print"  AccessKey="P" OnClick="Print_Click" />&nbsp;&nbsp;
                    </td>
                </tr>
            </table>
        </div>

        <!-- Used to display sites to replicate to  -->
        <div id="divSites" style="display:none;">
            <div style="width:100%;height:100%">
                Select sites to replicate to:<br />
                <br />
                <div style="max-height:400px;">
                    <asp:CheckBoxList runat="server" ID="cblSites" />
                </div>
            </div>
        </div>

        <!-- Used to display the site to print -->
        <div id="divSitesToPrint" style="display:none;">
            <div style="width:100%;height:100%;">
                Select sites to print:<br />
                <br />
                <div style="max-height:400px;">
                    <gc:GridControl id="gridSites" runat="server" EnableTheming="False" JavaEventDblClick="divSitesOk_onclick();" EnterAsDblClick="true" />
                </div>
            </div>
        </div>    
    </ContentTemplate>    
    </asp:UpdatePanel>
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
