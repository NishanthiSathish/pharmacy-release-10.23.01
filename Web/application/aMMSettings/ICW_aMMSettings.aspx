<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_aMMSettings.aspx.cs" Inherits="application_aMMSettings_ICW_aMMSettings" ClientIDMode="Static" %>

<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx" tagname="ProgressMessage" tagprefix="uc" %>
<%@ Register src="controls/ShiftEditor.ascx" tagname="ShiftEditor" tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>aMM Settings Desktop</title>

    <link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../Style/icwcontrol.css"                                 rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyGridControl.css"                        rel="stylesheet" type="text/css" />
    <style>
        html, body
        {
            background: white;
            height:90%
        }

        .menuHeader
        {
            padding-top: 10px;
            padding-left: 10px;
            font-size: 22px;
            text-align: left;
            color: #73617B;
        }        
    </style>

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
	<script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"        async></script>
    <script type="text/javascript" src="script/ShiftEditor.js"                                  defer></script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager runat="server" />
    <div style="width:100%;height:95%;">
        <!-- update progress message -->
        <uc:ProgressMessage ID="progressMessage" runat="server" />

        <div id="panelTitle" class="menuHeader" style="width:100%;">AMM Shifts</div>        
        <hr class="menuHeader" style="width:95%;" />

        <div style="width:100%;height:90%;">
            <uc:ShiftEditor ID="ctrlShiftEditor" runat="server" />
        </div>
    </div>
    </form>
</body>
</html>
