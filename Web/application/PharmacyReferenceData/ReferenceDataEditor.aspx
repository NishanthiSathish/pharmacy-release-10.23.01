<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ReferenceDataEditor.aspx.cs" Inherits="application_PharmacyReferenceData_ReferenceDataEditor" %>
<%@ Register TagPrefix="icw" Assembly="Ascribe.Core.Controls" Namespace="Ascribe.Core.Controls" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%=SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "ReferenceDataEditor.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Edit </title>
    <base target="_self" />

    <link href="../../style/PharmacyDefaults.css" rel="stylesheet" type="text/css" />
    <link href="../../style/icwcontrol.css"       rel="stylesheet" type="text/css" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.11.3.min.js"      async></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"                      async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"     async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/reports.js"            async></script> <!-- Need to be asynchronous as controls seem to do complete post back -->
    <script type="text/javascript" src="../pharmacysharedscripts/FileHandling.js"       async></script> <!-- Need to be asynchronous as controls seem to do complete post back -->
    <script type="text/javascript" src="../pharmacysharedscripts/HelperWebService.js"   async></script> <!-- Need to be asynchronous as controls seem to do complete post back -->
    <script type="text/javascript">
        SizeAndCentreWindow("760px", <%# height %> + "px");

        function tbValue_onkeypress(event)
        {
            if (event.keyCode == 34)    // Replace " with '
                event.keyCode = 39;
        }
    
        function print(sessionId, siteId, applicationPath, numberOfLabels)
        {
            // Get the rtf and clear the hidden field
            var rtf = $('input[id$=hfRTF]').val();
            $('input[id$=hfRTF]').val('');

            // Save the rtf
            var filename = GetLocalTempFilename(sessionId, siteId);
            writeFile(filename, rtf);

            // Print using the ascribe print job
            AscribeVB6PrintJob(sessionId, siteId, applicationPath, filename, 'FFLabel', numberOfLabels);
        }
    </script>    
    <script type="text/javascript">
        SizeAndCentreWindow("600px", "450px");

        function tabSelected() {
        }
    </script>
    <style type="text/css">
        html, body{height:99%}
        
        /* 24Feb15 font for text area needs to be set size so fit with ruler used for printing */
        textarea 
        {
            font-family: Courier; 
            font-size: 13px;
        }
    </style>  <!-- Ensure page is full height of screen -->    
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div>
        <icw:Container ID="container" runat="server" ShowHeader="false" FillBrowser="false" Height="96%">
        <asp:UpdatePanel ID="upPanel" runat="server">
        <ContentTemplate>    
            <icw:Form runat="server" ID="frmMain">
                <icw:Label ID="lbCaption" runat="server" />
                <icw:ShortText  ID="tbCode"  runat="server" Mandatory="True" Caption="Code:" ReadOnly="true" />
                <div id="divRuler" runat="server">
                    <icw:Label runat="server" ReadOnly="true" Text="&nbsp;" />
                    <icw:Label runat="server" ReadOnly="true" Text="&nbsp;" />
                    <img id="imgRuler" runat="server" src="images\ruler.gif" style="position:absolute;left:141px;top:62px;" alt="ruler" />
                </div>
                <icw:ShortText ID="tbValueShort"  runat="server" Mandatory="True" Visible="false" Caption="Value:" TextboxWidth="250px" onkeypress="if (event.keyCode == 34) { event.keyCode = 39 }" />
                <icw:LongText  ID="tbValueLong"   runat="server" Mandatory="True" Visible="false" Caption="Value:" Columns="60"         onkeypress="if (event.keyCode == 34) { event.keyCode = 39 }" />
            </icw:Form>
            
            <div id="lbLocalCodeWarning" runat="server" style="position:absolute;left:20px;bottom:30px;width:260px;color:Red;font-style:italic;">This entry will be used on dispensing labels and associated documents in preference to any DSS value</div>        
                    
            <icw:General runat="server">
                <div style="position:absolute; bottom:30px; right:385px">
                    <icw:Button ID="btnOK"     runat="server" CssClass="PharmButton" Caption="OK"     AccessKey="O" OnClick="btnOK_OnClick" />
                </div>
                <div style="position:absolute; bottom:30px; left:385px">
                    <icw:Button ID="btnCancel" runat="server" CssClass="PharmButton" Caption="Cancel" AccessKey="C" />
                </div>
                <div style="position:absolute; bottom:30px; right:30px">
                    <icw:Button ID="btnPrint"  runat="server" CssClass="PharmButton" Caption="Print"  AccessKey="P" OnClick="btnPrint_OnClick" />
                </div>
            </icw:General>

            <icw:MessageBox ID="mbPrintNumberOfLabels" runat="server" Caption="Label Printer" Buttons="OKCancel" OnOkClicked="mbPrintNumberOfLabels_OnOkClicked" Visible="false">
                <icw:General runat="server">
                    <icw:Number ID="numNumberOrLabels" runat="server" Caption="Number of Labels: " AllowNegativeNumbers="false" AllowZeroNumbers="false" Value="1" MaxCharacters="3" />
                </icw:General>
            </icw:MessageBox>

            <asp:HiddenField ID="hfRTF" runat="server" />
        </ContentTemplate>
        </asp:UpdatePanel>                         
        </icw:Container>
    </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
