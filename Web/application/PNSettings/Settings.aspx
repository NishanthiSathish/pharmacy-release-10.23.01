<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Settings.aspx.cs" Inherits="application_PNSettings_Settings" %>
<%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Settings</title>
        
    <link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/application.css"            rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"       rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyGridControl.css"    rel="stylesheet" type="text/css" />
    <link href="../../style/PN.css"                     rel="stylesheet" type="text/css" />
    
    <style type="text/css">html, body{height:100%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body onload="form_onload();">
    <form id="form1" runat="server" class="PNSettings" defaultbutton="btnSave">
    <asp:ScriptManager ID="ScriptManager1" runat="server" />
    <div style="height: 100%">
        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>
        <!-- General section -->
        <div class="Section">
            <span class="SectionHeader">General</span>
            <span class="SectionControls">
                <span class="ControlLabel" ID="lbSeparateAminoAndFatLabels" runat="server">Separate amino and lipid labels</span><asp:CheckBox ID="cbSeparateAminoAndFatLabels" runat="server" />&nbsp;(don't tick for combined regimen)
                <br />
                <span class="ControlLabel" ID="lbCalcDripRateMlPerHour" runat="server">Calculate drip rate as ml/hr</span><asp:CheckBox ID="cbCalcDripRateMlPerHour" runat="server" />
                <br />
                <span class="ControlLabel" ID="lbBaxaPump" runat="server">Baxa Compounder in use</span><asp:CheckBox ID="cbBaxaPump" runat="server" />
                <br />
                <span class="ControlLabel" ID="lbIssueEnabled" runat="server">Allow issuing</span><asp:CheckBox ID="cbIssueEnabled" runat="server" />
                <br />
                <span class="ControlLabel" ID="lbReturnEnabled" runat="server">Allow returning</span><asp:CheckBox ID="cbReturnEnabled" runat="server" />
            </span>
        </div>
        
        <!-- Regimen section -->
        <div class="Section">
            <span class="SectionHeader">Regimen</span>
            <span class="SectionControls">
            <table>
                <col style="" />
                <col style="width:125px; text-align:center;" />
                <col style="width:125px; text-align:center;" />
                <col style="width:125px; text-align:center;" />
                <thead>                
                    <tr>
                        <td></td>
                        <td><span ID="lbRegimenDefaultsAqueous" runat="server">Aqueous part only</span></td>
                        <td><span ID="lbRegimenDefaultsLipid" runat="server">Lipid part only</span></td>
                        <td><span ID="lbRegimenDefaultsMixed" runat="server">Mixed Aqueous & Lipid</span></td>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td><span ID="lbRegimenDefaultsOverage" runat="server">Overage volume (ml)</span></td>
                        <td><asp:TextBox ID="tbAqueousOverageVolume" runat="server" Width="50px"></asp:TextBox></td>
                        <td><asp:TextBox ID="tbLipidOverageVolume"   runat="server" Width="50px"></asp:TextBox></td>
                        <td><asp:TextBox ID="tbMixedOverageVolume"   runat="server" Width="50px"></asp:TextBox></td>
                    </tr>
                    <tr>
                        <td><span ID="lbRegimenDefaultsExpiry" runat="server">Expiry (days)</span></td>
                        <td><asp:TextBox ID="tbAqueousExpiry" runat="server" Width="50px"></asp:TextBox></td>
                        <td><asp:TextBox ID="tbLipidExpiry"   runat="server" Width="50px"></asp:TextBox></td>
                        <td><asp:TextBox ID="tbMixedExpiry"   runat="server" Width="50px"></asp:TextBox></td>
                    </tr>
                    <tr>
                        <td><span ID="lbRegimenDefaultsNumberOfLabels" runat="server">Number of labels</span></td>
                        <td><asp:TextBox ID="tbAqueousNumberOfLabels" runat="server" Width="50px"></asp:TextBox></td>
                        <td><asp:TextBox ID="tbLipidNumberOfLabels"   runat="server" Width="50px"></asp:TextBox></td>
                        <td><asp:TextBox ID="tbMixedNumberOfLabels"   runat="server" Width="50px"></asp:TextBox></td>
                    </tr>                    
                    <tr>
                        <td><span ID="lbRegimenDefaultsInfusionDuration" runat="server">Infusion duration (hours)</span></td>
                        <td><asp:TextBox ID="tbAqueousInfusionDurationInHours" runat="server" Width="50px"></asp:TextBox></td>
                        <td><asp:TextBox ID="tbLipidInfusionDurationInHours"   runat="server" Width="50px"></asp:TextBox></td>
                        <td><asp:TextBox ID="tbMixedInfusionDurationInHours"   runat="server" Width="50px"></asp:TextBox></td>
                    </tr>                    
                </tbody>
            </table>
            <asp:Label ID="lbError" runat="server" Text="&nbsp;" CssClass="ErrorMessage"></asp:Label>
            </span>
        </div>
        <table style="width:95%;">
            <tr>
                <td style="width:50%;vertical-align:middle;">
    			    <asp:LinkButton runat="server" id="lbtSites" CssClass="LinkButton" Width="220px" OnClientClick="lbtSelectSites_onclick(); return false;" ToolTip="Click to change sites to replicate to" />
                </td>
                <td style="width:50%;text-align:right;">
                    <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="PharmButton" OnClick="btnSave_OnClick" />&nbsp;&nbsp;&nbsp;
                    <asp:Button CssClass="PharmButton" ID="btnPrint"  runat="server" Text="Print"  AccessKey="P" OnClick="Print_Click" />&nbsp;&nbsp;
                </td>
            </tr>
        </table>
        <br />     

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
    </div>
    </form>
    <iframe id="ActivityTimeOut"  application="yes" allowtransparency="true"  style="display: none;"> </iframe>
</body>
<script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"               async></script>
<script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
<script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
<script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"        defer></script>
<script type="text/javascript" src="scripts/PNSettings.js"                                  defer></script>
<script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"            defer></script>
<script type="text/javascript">
    function form_onload()
    {
        Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
        Sys.WebForms.PageRequestManager.getInstance().add_endRequest(HideProgressMsg);
        
        InitIsPageDirty();
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);    
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "Settings.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    }
</script>
</html>