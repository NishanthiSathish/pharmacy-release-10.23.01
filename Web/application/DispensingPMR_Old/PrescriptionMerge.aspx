<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PrescriptionMerge.aspx.cs" Inherits="application_DispensingPMR_PrescriptionMerge" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Register src="../../application/pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="gc" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Prescription Linking</title>

    <script type="text/javascript" src="../sharedscripts/jquery-1.3.2.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"></script>
    <script type="text/javascript" src="../SharedScripts/icwfunctions.js"></script>
    <script type="text/javascript" src="script/PrescriptionMerge.js"></script>

    <link href="../../style/application.css"        rel="stylesheet" type="text/css" />
    <link href="../../style/OCSGrid.css"            rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"   rel="stylesheet" type="text/css" />
</head>
<body onload="form_onload();"
    SessionID="<%= sessionID %>"
    RequestID="<%= requestID %>"
    EpisodeID="<%= episodeID %>"
    >
    <form id="form1" runat="server" onkeydown="form_onkeydown(id, event);" defaultbutton="btnOK" enableviewstate="False">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div class="PaneCaption" style="padding: 2px">        
        <asp:Label ID="lblSelectedDrug" runat="server" Text="lblSelectedDrug" Width="100%"></asp:Label>
        <asp:Label ID="lbDate"          runat="server" Text="lbStartDate"     Font-Size="Small"></asp:Label>
        <asp:HiddenField ID="hfSelectedDrugData" runat="server" />
    </div>
    
    <div style="margin: 5px">        
        <div style="margin-bottom: 5px; margin-top: 5px;">Select items you want to link to the prescription.</div>
                
        <div style="border: 1px solid; width: 99%; height: 220px; text-align: center;">
            <gc:GridControl id="gridAsymetricCandidates" runat="server" EmptyGridMessage="There are no suitable prescriptions available for linking." EnableAlternateRowShading="True" SortableColumns="True" EnableViewState="False" EnableTheming="False" JavaEventCheckBoxClick="gridAsymetricCandidates_CheckBox_click" />
        </div>      
        
        <asp:Label ID="lblAsymetricCandidatesError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" Width="100%" style="text-align:center"></asp:Label>

        <hr />      
        
        <div style="margin-bottom: 5px; margin-top: 5px;">Following prescriptions are not suitable for linking.</div>
        
        <div style="border: 1px solid; width: 99%; height: 210px; text-align: center;">
            <gc:GridControl id="gridNonAsymetricCandidates" runat="server" EnableAlternateRowShading="True" SortableColumns="True" EnableViewState="False" EnableTheming="False" />
        </div>       
        
        <br />

        <div style="width:99%; white-space:nowrap; text-align:center;">
            <asp:Button ID="btnOK" runat="server" Text="OK" CssClass="ICWButton" AccessKey="O" OnClientClick="btnOK_onclick();" CausesValidation="False" EnableViewState="False" />&nbsp;&nbsp;
            <input id="btnCancel" class="ICWButton" type="button" accesskey="C" value="Cancel" onclick="window.close();" />
        </div>   
    </div>
    </form>
</body>
</html>
