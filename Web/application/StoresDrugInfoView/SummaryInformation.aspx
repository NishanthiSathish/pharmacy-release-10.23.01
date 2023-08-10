<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SummaryInformation.aspx.cs" Inherits="application_StoresDrugInfoView_SummaryInformation" %>

<%@ Register src="controls/GridControl.ascx" tagname="GridControl" tagprefix="uc1" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Summary Information</title>
    
	<link href="../../style/application.css" rel="stylesheet" type="text/css" />
	<link href="../../style/OCSGrid.css"     rel="stylesheet" type="text/css" />
</head>
<body id="bdyMain" scroll="no" style="width:100%;height:100%;margin:0px;" onkeydown="frameElement.ownerDocument.parentWindow.form_onkeydown(event)">
    <!-- Ordering & Issuing grid -->
    <asp:Label ID="lblOrderingIssuing" runat="server" Text="Ordering & Issuing info (for last {0} months)" CssClass="PaneCaption" Width="100%"></asp:Label>
    <br />
    <center>
        <div style="width: 75%; height: 365px;">
            <uc1:GridControl ID="orderingIssuingGrid" runat="server" />
        </div>
    </center>
</body>
</html>
