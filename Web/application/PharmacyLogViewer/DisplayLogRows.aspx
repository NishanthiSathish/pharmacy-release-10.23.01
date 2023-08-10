<%@ Page Language="C#" AutoEventWireup="true" CodeFile="DisplayLogRows.aspx.cs" Inherits="application_PharmacyLogViewer_DisplayLogRows" %>
<%@ Register src="DisplayLogRows.ascx" tagname="LogRows" tagprefix="uc" %>
<%@ OutputCache Location="None" VaryByParam="None" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%--<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=SessionInfo.SessionID%>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "DisplayLogRows.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>--%>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Log File Viewer</title>
    <base target=_self>

    <link href="../../style/application.css"        rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"   rel="stylesheet" type="text/css" />
    <link href="style/PharmacyLogViewer.css"        rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/jquery-1.3.2.js"                   async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"    async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"         async></script>
    <script type="text/javascript">
        // Called when form loads
        // Correctly calculates size of the form 21Jan15 XN 108627
        function form_onload() 
        {
            var width = Math.min(screen.width, 1200) + "px";
			var gridHeight 		= $('div[id$="divLogGrid"]').height();
			var infoHeight 		= $('div[id$="logGrid"]'   ).height();
			var exportBtnHeight = 25;			
            var height = Math.min(screen.height, Math.max(gridHeight + infoHeight + exportBtnHeight, 200)) + "px";
            SizeAndCentreWindow(width, height);
        }

        // Called when export to CSV button is clicked
        // splits table up into CSV, and the calls SaveAs.aspx to ask user where to save the file
        function btnExportToCSV_OnClick() 
        {
            // Get heading info
            // var headingInfo = ConvertTableToCSV('tblInfo', ' '); 27Oct13 XN 84572 Updates to way ConvertTableToCSV works 
            var headingInfo = ConvertTableToCSV( $('#tblInfo'), ' ' );
            headingInfo = ReplaceString(headingInfo, ',', ' ');

            // Convert to table to CSV string
            // var gridStr = ConvertTableToCSV('logGrid');          27Oct13 XN 84572 Updates to way ConvertTableToCSV works 
            var gridStr = ConvertTableToCSV( $('#logGrid') );

            // Perform save as
            var cr = String.fromCharCode(13);   // row separator characters
            document.frames['fraSaveAs'].SetSaveAsData('Log File Viewer.csv', headingInfo + cr + gridStr + cr);
        }
    </script>
    

        
    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body onload="form_onload();" onkeydown="if (event.keyCode == 27) { window.close(); }">
    <form id="form1" runat="server">
    <div style="overflow-y:hidden;">
        <table style="width:99%;height:98%;padding-top:5px">
            <tr>
                <td id="trLogRows"><uc:LogRows ID="logRows" runat="server" /></td>
            </tr>
            <tr style="height:25px">
                <td><div style="float:right;"><asp:Button ID="btnExportToCSV" CssClass="ICWButton" Text="Export To CSV" runat="server" AccessKey="E" Width="98px" OnClientClick="btnExportToCSV_OnClick(); return false;" UseSubmitBehavior="false"  /></div></td>
            </tr>
        </table>
    </div>
    </form>

    <iframe style="display:none;" id="fraSaveAs" src="../pharmacysharedscripts/SaveAs.aspx" border="0" frameborder="no" disabled noresize />
   <%-- <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>--%>
</body>
</html>
