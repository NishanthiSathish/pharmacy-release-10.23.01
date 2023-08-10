<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_StockListFindAndReplace.aspx.cs" Inherits="application_StockListFindAndReplace_ICW_StockListFindAndReplace" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register src="../pharmacysharedscripts/PharmacyLabelPanelControl.ascx"  tagname="LabelPanelControl"         tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SiteColourPanelControl.ascx"     tagname="SiteColourPanelControl"    tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/SiteNamePanelControl.ascx"       tagname="SiteNamePanelControl"      tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx"            tagname="ProgressMessage"           tagprefix="uc" %>
<%@ Register src="../pharmacysharedscripts/QuesScrl/QuesScrl.ascx"          tagname="QuesScrl"                  tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Stock List Find and Replace</title>

    <link href="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/ScrollTableContainer.css"                       rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"                                 rel="stylesheet" type="text/css" />
    <link href="../../style/LabelPanelControl.css"                          rel="stylesheet" type="text/css" />
    <link href="../pharmacysharedscripts/QuesScrl/QuesScrl.css"             rel="stylesheet" type="text/css" />
    <style>
        .icw-title
        {
            font-weight: bold;
            font-size:   12px;            
        }
    </style>

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../sharedscripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"                              defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/QuesScrl/QuesScrl.js"          defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyLabelPanelControl.js"  defer></script>
    <script type="text/javascript" src="script/StockListFindAndReplace.js"                      async></script>    
    <script type="text/javascript">
        var sessionID = <%= SessionInfo.SessionID %>;
        var siteID    = <%= SessionInfo.SiteID    %>;
    </script>
</head>
<body style="width:820px;height:650px;background-image:none;background-color:white;">
    <form id="form1" runat="server">
    <asp:ScriptManager runat="server" />

    <!-- update progress message -->
    <uc:ProgressMessage ID="progressMessage" runat="server" />

    <table cellpadding="0" cellspacing="0" style="background-color:#DDDDDD;width:100%;height:25px;">
    <tr>
        <td><uc:SiteNamePanelControl ID="siteNamePanel" runat="server" /></td>
        <td style="width:25%;">&nbsp;</td>
        <td style="width:5%;"><uc:SiteColourPanelControl ID="SiteColourPanelControl1" runat="server" /></td>
    </tr>
    </table>

    <asp:UpdatePanel ID="upMain" runat="server" UpdateMode="Conditional">
    <ContentTemplate>
        <asp:HiddenField ID="hfCurrentStep" runat="server" />

        <div id="divHeader" runat="server">
            <asp:HiddenField ID="hfHeaderSuffix" runat="server" />
            <hr />
            <asp:Label id="lbHeader" runat="server" CssClass="icw-title" />
            <hr />
        </div>

        <asp:MultiView ID="multiView" runat="server">
            <asp:View ID="vSelectFindType" runat="server">
                <asp:RadioButton ID="rbFindAndReplace" runat="server" Text="Find and Replace" Checked="true" GroupName="selectFindType" /><br />
                <span style="font-style:italic;padding-left:20px;">Use this option to replace one item with another across a selection of stocklists</span><br />
                <br />
                <asp:RadioButton ID="rbFindAndUpdate"  runat="server" Text="Find and Update"  GroupName="selectFindType" /><br />
                <span style="font-style:italic;padding-left:20px;">Use this option to edit and update an item across a selection of stocklists</span><br />
                <br />
                <asp:RadioButton ID="rbFindAndDelete"  runat="server" Text="Find and Delete"  GroupName="selectFindType" /><br />
                <span style="font-style:italic;padding-left:20px;">Use this option to delete an item from selection of stocklists</span><br />
                <br />
            </asp:View>

            <asp:View ID="vSearchFor" runat="server">
                <asp:HiddenField ID="hfSearchForNSVCode"     runat="server" />
                <asp:HiddenField ID="hfSearchForDescription" runat="server" />
                <iframe id="fraPharmacyProductSearch" application="yes" width="100%" height="570px" style="margin-top:-7px;margin-left:-10px;" src="../PharmacyProductSearch/ICW_PharmacyProductSearch.aspx?SessionID=<%= SessionInfo.SessionID %>&WindowID=<%= Request["WindowID"] %>&EmbeddedMode=true&VB6Style=false&SiteID=<%= SessionInfo.SiteID %>"></iframe>
            </asp:View>

            <asp:View ID="vReplace" runat="server">
                <div>
                    <asp:HiddenField ID="hfReplaceNSVCode"     runat="server" />
                    <asp:HiddenField ID="hfNSVCodeForRepeater" runat="server" />
                    <table>
                        <tr>
                            <td colspan="2" style="font-weight:bold;">Current item</td>
                        </tr>
                        <tr>
                            <td>Code:</td>
                            <td><asp:Label ID="lbCurrentNSVCode" runat="server" /></td>
                        </tr>
                        <tr>
                            <td>Description:</td>
                            <td><asp:Label ID="lbCurrentDescription" runat="server" /></td>
                        </tr>
                        <tr>
                            <td>Pack Size:</td>
                            <td><asp:Label ID="lbCurrentPackSize" runat="server" /></td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                            <td>
                                <div style="width:400px;">
                                    <uc:LabelPanelControl ID="pnCurrentDrugInfo" runat="server" EnableViewState="true" />
                                </div>
                            </td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                        </tr>
                        <tr>
                            <td colspan="2" style="font-weight:bold;">Replacement item</td>
                        </tr>
                        <tr>
                            <td><asp:Label ID="lbReplaceCode" runat="server" Text="Code:" /></td>
                            <td>
                                <asp:Label ID="lbReplaceNSVCode" runat="server" Width="100px" />
                                <asp:Button  ID="btnReplaceNSVCode"      runat="server" CssClass="PharmButtonSmall" style="width:70px; height:20px;" Text="Search..."   OnClientClick="btnReplaceNSVCode_onclick(); return false;" />&nbsp;
                                <asp:Button  ID="btnClearReplaceNSVCode" runat="server" CssClass="PharmButtonSmall" style="width:40px; height:20px;" Text="Clear"       OnClick="btnClearReplaceNSVCode_OnClick" />
                            </td>
                        </tr>
                        <tr>
                            <td><asp:Label ID="lbReplaceDescription" runat="server" Text="Description:" /></td>
                            <td>
                                <asp:TextBox     ID="tbReplaceDescription"     runat="server" Width="530px" />&nbsp;
                                <asp:ImageButton ID="imgRevertDescription" runat="server" OnClick="imgRevert_OnClick" ToolTip="Click to revert to item description" Width="16" Height="16" ImageUrl="~/images/User/undo.gif" />
                            </td>
                        </tr>
                        <tr>
                            <td><asp:Label ID="lbReplacePackSize"  runat="server" Text="Pack Size:" /></td>
                            <td>
                                <asp:TextBox     ID="tbReplacePackSize"       runat="server" Width="100px" />&nbsp;
                                <asp:ImageButton ID="imgRevertPackSize"       runat="server" OnClick="imgRevert_OnClick" ToolTip="Click to revert to item pack size"   Width="16" Height="16" ImageUrl="~/images/User/undo.gif" />&nbsp;
                                <asp:Label       ID="lbReplacePackSizeSuffix" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>&nbsp;</td>
                            <td>
                                <div style="width:400px;">
                                    <uc:LabelPanelControl ID="pnReplaceDrugInfo" runat="server" EnableViewState="true" />
                                </div>
                            </td>
                        </tr>
                    </table>
                </div>
            </asp:View>

            <asp:View ID="vSelectLists" runat="server">
                <div>
                    <asp:Button ID="btnCheckAll"   runat="server" CssClass="PharmButtonSmall" Height="20px" Width="65px" Text="Check All"   OnClick="btnCheckAll_OnClick"   />&nbsp;
                    <asp:Button ID="btnUnCheckAll" runat="server" CssClass="PharmButtonSmall" Height="20px" Width="65px" Text="Uncheck All" OnClick="btnUncheckAll_OnClick" />

                    <br />

                    <asp:Panel ID="divLists" runat="server" ScrollBars="Vertical" Width="800px" Height="500px" style="border: solid 1px #E4C48B;margin-top:5px;">
                        <asp:CheckBoxList ID="cblLists" runat="server" />
                    </asp:Panel>
                </div>
            </asp:View>

            <asp:View ID="vEditor" runat="server">
                <asp:HiddenField ID="hfEditorControlValidated" runat="server" />
                <div style="margin:10px;height:550px">
                    <uc:QuesScrl ID="editorControl" runat="server" ShowHeaderRow="true" OnValidated="editorControl_OnValidated" OnCreatedHeader="editorControl_OnCreatedHeader" />
                </div>
            </asp:View>

            <asp:View ID="vInfoPanel" runat="server">
                <div id="divInfoPanel" runat="server" style="max-height:500px;margin:10px;overflow-y:auto;overflow-x:hidden;" />

                <br />

                <asp:CheckBox ID="cbPrintReport" runat="server" Text="Print Report" Checked="true" />
            </asp:View>
        </asp:MultiView>

        <div style="position:absolute;top:627px;left:10px;text-align:center;width:800px;">
            <asp:Label id="lbErrorMessage" CssClass="ErrorMessage" runat="server" Text="&nbsp" EnableViewState="false" Width="100%" />
        </div>

        <!-- button at bottom -->
        <hr style="position:absolute;top:645px;left:10px;width:800px;z-index:99" />

        <div style="position:absolute;top:655px;left:738px;text-align:right;z-index:99"> 
            <asp:Button ID="btnNext" runat="server" CssClass="PharmButton" Text="Next >" Width="75px" OnClick="btnNext_OnClick" OnClientClick="return btnNext_OnClick();" AccessKey="N" />
        </div>

        <div style="position:absolute;top:655px;left:362px;text-align:right;z-index:99"> 
            <asp:Button ID="btnRestart" runat="server" CssClass="PharmButton" Text="Restart" Width="75px" OnClientClick="btnRestart_OnClick(); return false;" AccessKey="R" />
        </div>
    </ContentTemplate>
    </asp:UpdatePanel>
    </form>
</body>
</html>
