<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PNProductEditor.aspx.cs" Inherits="application_PNSettings_PNProductEditor" %>
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

            document.getElementById('tbDescription').focus();
        }
    </script>   

    <style type="text/css">html, body{height:90%}</style>  <!-- Ensure page is full height of screen -->
    
    <title>PN Product Editor</title>
</head>
<body scroll="no"
      onload="form_onload();">
    <form id="form1" runat="server" defaultbutton="btnSave">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <div>
    <asp:UpdatePanel ID="updatePanel" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:HiddenField ID="hfPNProductID"  runat="server" />
        <asp:HiddenField ID="hfPNCode"       runat="server" />
        <asp:HiddenField ID="hfOpenDate"     runat="server" />
        <asp:Panel ID="Panel1" runat="server" CssClass="PNSettings" Height="625px" ScrollBars="Vertical" >
            <br />
            <div class="Section">
                <span class="SectionHeader">General</span>
                <span class="SectionControls">
                    <span ID="lbDescription" runat="server" class="EditControlLabel">Description</span><asp:TextBox ID="tbDescription" runat="server" Width="300px" /><asp:Button ID="btnDescription" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('description'); return false;" /><br />
                    <span class="EditControlLabel">&nbsp;</span><asp:Label ID="lbDescriptionError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" ></asp:Label><br />
                    <span ID="lbPNCode" runat="server" class="EditControlLabel">Code:</span><asp:TextBox ID="tbPNCode" runat="server" Width="100px" /><asp:Label ID="lbPNCodeError" runat="server" CssClass="ErrorMessage" /><br />
                    <span ID="lbInUse" runat="server" class="EditControlLabel">In use:</span><asp:CheckBox ID="cbInUse" runat="server" /><br />
                    <br />
                    <span ID="lbForAdult" runat="server" class="EditControlLabel">For Adult</span><asp:CheckBox ID="cbForAdult" runat="server" /><br />
                    <span ID="lbForPaediatric" runat="server" class="EditControlLabel">For Paediatric</span><asp:CheckBox ID="cbForPaediatric" runat="server" /><br />
                    <br />
                    <span ID="lbSortIndex" runat="server" class="EditControlLabel">Sort Index:</span><asp:TextBox ID="tbSortIndex" runat="server" Width="60px" /><asp:Label ID="lbSortIndexError" runat="server" CssClass="ErrorMessage" /><br />
                    <span ID="lbSharePacks" runat="server" class="EditControlLabel">Share Packs:</span><asp:CheckBox ID="cbSharePacks" runat="server" /><br />
                </span>
            </div>
            
            <div class="Section">
                <span class="SectionHeader">Details</span>
                <span class="SectionControls">
                    <span ID="lbAqueousOrLipid" runat="server" class="EditControlLabel">Type:</span><asp:DropDownList ID="ddlAqueousOrLipid" runat="server" EnableViewState="true" /><br />
                    <span ID="lbPreMix" runat="server" class="EditControlLabel">Pre Mix</span><asp:TextBox ID="tbPreMix" runat="server" Width="60px" ></asp:TextBox><asp:Button ID="btnPreMix" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('premix'); return false;" />&nbsp;<asp:Label ID="lbPreMixError" runat="server" CssClass="ErrorMessage" /><br />
                    <span ID="lbMaxMlTotal" runat="server" class="EditControlLabel">Maximum ml Total</span><asp:TextBox ID="tbMaxMlTotal" runat="server" Width="60px" /><asp:Button ID="btnMaxMlTotal" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('maxmltotal'); return false;" />&nbsp;<asp:Label ID="lbMaxMlTotalError" runat="server" CssClass="ErrorMessage" /><br />
                    <span ID="lbMaxMlPerKg" runat="server" class="EditControlLabel">Maximum ml per kg</span><asp:TextBox ID="tbMaxMlPerKg" runat="server" Width="60px" /><asp:Button ID="btnMaxMlPerKg" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('maxmlperkg'); return false;" />&nbsp;<asp:Label ID="lbMaxMlPerKgError" runat="server" CssClass="ErrorMessage" /><br />
                    <span ID="lbSpGrav" runat="server" class="EditControlLabel">SpGrav</span><asp:TextBox ID="tbSpGrav" runat="server" Width="60px" /><asp:Button ID="btnSpGrav" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('spgrav'); return false;" />&nbsp;<asp:Label ID="lbSpGravError" runat="server" CssClass="ErrorMessage" /><br />
                    <span ID="lbMOsmperml" runat="server" class="EditControlLabel">mOsmperml</span><asp:TextBox ID="tbMOsmperml" runat="server" Width="60px" /><asp:Button ID="btnMOsmperml" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('mosmperml'); return false;" />&nbsp;<asp:Label ID="lbMOsmpermlError" runat="server" CssClass="ErrorMessage" /><br />
                    <span ID="lbGH2Operml" runat="server" class="EditControlLabel">gH2Operml</span><asp:TextBox ID="tbGH2Operml" runat="server" Width="60px" /><asp:Button ID="btnGH2Operml" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('gh2operml'); return false;" />&nbsp;<asp:Label ID="lbGH2OpermlError" runat="server" CssClass="ErrorMessage" /><br />
                </span>
            </div>

            <div class="Section">
                <span class="SectionHeader">Ingredients</span>
                <span class="SectionControls">
                    <span ID="lbContainerVol" runat="server" class="EditControlLabel" style="width:175px">Container Volume (millilitre)</span><asp:TextBox ID="tbContainerVol" runat="server" Width="60px" /><asp:Button ID="btnContainerVol" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" /><asp:Label ID="lbContainerVolError" runat="server" CssClass="ErrorMessage" /><br />
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
                    <asp:Label ID="lbIngredientError" runat="server" CssClass="ErrorMessage" />
                </span>
            </div>

            <div class="Section">
                <asp:UpdatePanel ID="upSuppliedBy" runat="server" ChildrenAsTriggers="True" UpdateMode="Conditional" >                    
                <ContentTemplate>
                    <span class="SectionHeader">Supplied by</span>
                    <span class="SectionControls">
                        Stock Lookup&nbsp;&nbsp;<asp:TextBox ID="tbStockLookup" runat="server" Width="200px" ></asp:TextBox><asp:Button ID="btnStockLookup" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('StockLookup'); return false;" />&nbsp;&nbsp;<asp:Button CssClass="PharmButton" ID="btnRefreshProductList" runat="server" Text="Refresh Product List" OnClick="RefreshProductList_Click" Width="150px" Height="25px" /><br />
                        <asp:Label ID="lbStockLookupError" runat="server" CssClass="ErrorMessage" ></asp:Label><br />
                        <div class="EditControlLabel" style="width: 500px">Below are stocked pharmacy products suitable for supplying this parenteral nutrition item. Uncheck items to be excluded from this list when issuing.</div>
                        <br />
                        <asp:CheckBoxList ID="cblSuppliedBy" runat="server" Width="500px" CellPadding="0" CellSpacing="0" onselectedindexchanged="cblSuppliedBy_SelectedIndexChanged" AutoPostBack="True"></asp:CheckBoxList>
                        <div style="text-align:center; width: 500px; padding-top: 10px;">
                            <asp:Label runat="server" ID="lbNoItemsToSupply" Visible="false" Text="No suitable pharmacy products found"></asp:Label>
                            <asp:Label runat="server" ID="lbNoItemsSelected" Visible="false" Text="No pharmacy products selected" CssClass="InfoMessage"></asp:Label>
                        </div>
                    </span>
                </ContentTemplate>
                </asp:UpdatePanel>
            </div>
            
            <div class="Section">
                <span ID="lbBaxaMMIg" runat="server" class="SectionHeader">Baxa Info</span>
                <span class="SectionControls">
                    BaxaMMIg&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<asp:TextBox ID="tbBaxaMMIg" runat="server" Width="150px" /><asp:Button ID="btnBaxaMMIg" runat="server" CssClass="PharmButton" Text="..." Width="20px" Height="20px" Visible="false" OnClientClick="DisplayDssCustomisation('baxammig'); return false;" /><asp:Label ID="lbBaxaMMIgError" runat="server" CssClass="ErrorMessage" /><br />
                </span>
            </div>
            
            <div class="Section">
                <span class="SectionHeader">Update Info</span><asp:Label ID="lbModifiedInfo" runat="server" /><br />
                <span class="SectionHeader">&nbsp;</span><asp:TextBox ID="tbInfo" runat="server" Width="500px" Height="150px" TextMode="MultiLine" /><br />
                <span class="SectionHeader">&nbsp;</span><asp:Label ID="lbInfoError" runat="server" CssClass="ErrorMessage" />
            </div>
        </asp:Panel>
        <div style="padding-top: 20px;">
            <table style="width: 100%">
                <tr>
                    <td style="text-align:left;width:33%">
                        <asp:LinkButton runat="server" id="lbtSites" CssClass="LinkButton" Width="220px" OnClientClick="lbtSelectSites_onclick(); return false;" ToolTip="Click to change sites to replicate to" />
                    </td>
                    <td style="text-align:center; width:33%">
                        <asp:Button CssClass="PharmButton" ID="btnSave"   runat="server" Text="Save"   AccessKey="S" OnClick="Save_Click" />&nbsp;&nbsp;&nbsp;
                        <asp:Button CssClass="PharmButton" ID="btnCancel" runat="server" Text="Cancel" AccessKey="C" OnClientClick="window.close(); return false;" />
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
