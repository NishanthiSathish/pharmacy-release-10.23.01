<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ManualContractEditor.aspx.cs" Inherits="application_ContractEditor_ManualContractEditor" %>

<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx" tagname="ProgressMessage" tagprefix="pc" %>
<%@ Register src="ManualContractEditor.ascx"                     tagname="ContractEditor"  tagprefix="uc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "ManualContractEditor.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Manual Contract Editor - <%= SessionInfo.SiteNumber.ToString() %></title>
    <base target=_self>
    
    <link href="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.redmond.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="style/ManualContractEditor.css"                             rel="stylesheet" type="text/css" />
    <style type="text/css">html, body{height:99%}</style>  <!-- Ensure page is full height of screen -->    

    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"               async></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.10.3.min.js"  defer></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"             async></script>
    <script type="text/javascript" src="script/ManualContractEditor.js"                         async></script>
    
    <script type="text/javascript">
        SizeAndCentreWindow("670px", "480px");

        function form_onload()
        {
            InitIsPageDirty();
    
            if ($('#hfSupCode').val() == '')
                lbtnSupplier_onclick(true);
        }

        function form_onkeydown(event)
        {
            switch (event.keyCode)
            {
            case 115: btnItemEnquiry_onclick(); break;  // F4
            case 27 : window.close();           break;  // esc
            }
        }

        function form_onkeyup(event) 
        {
            if (event.keyCode == 112 && event.shiftKey)
                imgEdiBarcodeLookup_onclick(); 
                return false;
        }

        // called when item enquiry buton is clicked (calls F4 screen)
        function btnItemEnquiry_onclick()
        {
            var strURL           = document.URL;
            var intSplitIndex    = strURL.indexOf('?');
            var strURLParameters = strURL.substring(intSplitIndex, strURL.length);
            var ret= window.showModalDialog('../StoresDrugInfoView/ICW_StoresDrugInfoView.aspx' + strURLParameters, '', 'dialogHeight:735px; dialogWidth:865px; status:off; center: Yes'); // 30Jul15 XN 121034 Changed from using StoresDrugInfoViewModal.aspx to main ICW_StoresDrugInfoView.aspx'
            if (ret == 'logoutFromActivityTimeout') {
                ret = null;
                window.close();
                window.parent.close();
                window.parent.ICWWindow().Exit();
            }

        }

        function form_onbeforeunload() 
        {
            if (isPageDirty)
                event.returnValue = 'If you press OK, your latest changes will be lost!';
        }               

        function btnSave_onclick()
        {
            if (!isPageDirty)
            {
                // Error message made to look exactly the same as the Contract import when for when no changes made
                var msg = "<table cellspacing='10'><colgroup><col width='15px' valign='top' /><col width='100%' valign='top' /></colgroup>" + 
                          "<tr><td><img src='images/exclamation_red.gif' /></td><td>No changes made</td></tr>" + 
                          "</table>";    
                alertEnh(msg);
        
                event.cancelBubble = true;
            }
        }
    </script>
</head>
<body onload="form_onload();" onkeydown="form_onkeydown(event)" onkeyup="form_onkeyup(event)" onbeforeunload="form_onbeforeunload();">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <telerik:RadWindowManager ID="RadWindowManager1" runat="server" />
    <div>
        <asp:UpdatePanel ID="upMain" runat="server">
        <ContentTemplate>        
            <asp:HiddenField runat="server" ID="hfSupCode" />
            <table runat="server" class="MainTable" id="tblMain" border="1" width="100%" >
                <thead>
                    <tr>
                        <td width="20%" />
                        <td width="40%" />
                        <td width="40%" />
                    </tr>
                </thead> 
                <tbody>
                <tr class="HeaderRow">
                    <td />
                    <td runat="server" id="AscribeHeader" colspan="2">
                        Pharmacy current data for:<br />
                        ACETAZOLAMIDE 250mg TABLETS (112)<br />
                        Pack size: 112<br />
                        NSV code: ABC123A<br />
                    </td>
                </tr>
            </table>                
            <uc:ContractEditor ID="contractEditor" runat="server" OnSupplierCodeUpdated="contractEditor_OnSupplierCodeUpdated" OnValidated="contractEditor_OnValidated" OnSaved="contractEditor_OnSaved" />

            <div style="position: absolute; right: 10px; bottom: 10px;">
                <button class="PharmButton" onclick="btnItemEnquiry_onclick();" style="width:110px">Item Enquiry</button>&nbsp;
                <asp:Button ID="btnSave" runat="server" CssClass="PharmButton" Text="Save" AccessKey="S" OnClick="btnSave_OnClick" OnClientClick="btnSave_onclick();" />&nbsp;
                <button class="PharmButton" onclick="window.close();">Cancel</button>
            </div>    
        </ContentTemplate>            
        </asp:UpdatePanel>
                
        <!-- update progress message -->
        <pc:ProgressMessage id="progressMessage" runat="server" EnableTheming="False" EnableViewState="false" />
    </div>        
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
