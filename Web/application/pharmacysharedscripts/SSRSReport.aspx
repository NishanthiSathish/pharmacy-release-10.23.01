<%@ Page Language="C#" AutoEventWireup="true" CodeFile="SSRSReport.aspx.cs" Inherits="application_pharmacysharedscripts_SSRSReport" %>

<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=10.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
 <script type="text/javascript" src="../sharedscripts/inactivityTimeOut.js"></script>
     <script type="text/javascript" FOR="window" EVENT="onload">
         //MM-2848-Inactivity Monitor
         var sessionId = '<%= SessionInfo.SessionID %>';
         //alert('sessionId ' + sessionId);
         var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
         var pageName = "SSRSReport.aspx";
         windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
     </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title><%=title %></title>
    <base target="_self" />

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js" async></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js" async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
   
    <script type="text/javascript">
<% if (!this.embeddedMode) %>
<% { %>
        SizeAndCentreWindow('800px', '600px');
<% } %>
        function pageLoad() {
            window.document.getElementById('__EVENTARGUMENT').value = '';
            $('#reportViewer').find('*').css('overflow', 'visible');    // Updated to prevent the right scroll bar continually resizing causing application to lock 27Jul16 XN 157124
        }

        // Method user to print report
        // starts timer to invoke printing (after 0.5secs) so form is displayed
        function autoPrint() {
            //            autoPrintTimer = setInterval(function() 
            //                                            {
            //                                                var reportViewer = $find('reportViewer');
            //                                                if (reportViewer != null && !reportViewer.get_isLoading())
            //                                                {
            //                                                    clearInterval(autoPrintTimer);
            //                                                    reportViewer.invokePrintDialog();
            //                                                }
            //                                            }, 500);  27Jul16 XN 157124 replaced with single timeout to prevent it continually being called
            setTimeout(function () {
                var reportViewer = $find('reportViewer');
                if (reportViewer != null && !reportViewer.get_isLoading())
                    reportViewer.invokePrintDialog();
            }, 500);
        }

        // Called by server side to displau PharmacyLookupList
        // parameterName - name of parameter being search for
        // sp            - sp to run to populate the list
        // spParameters  - parameters to pass to sp (as Param1:Value1,Param2:Value2,Param3:Value3
        function LookupParameter(parameterName, sp, spParameters) {
            var strURLParameters = '';
            strURLParameters += '?SessionID=' + <%= SessionInfo.SessionID %>;
            strURLParameters += '&Title=Select Items';
            strURLParameters += '&Info=Select items for report';
            strURLParameters += '&SP=' + sp;
            strURLParameters += '&Params=' + spParameters;
            strURLParameters += '&Columns=Description,100';
            strURLParameters += '&Width=500';
            strURLParameters += '&SearchType=Basic';
            strURLParameters += '&BasicSearchColumns=0';
            var result = window.showModalDialog('../pharmacysharedscripts/PharmacyLookupList.aspx' + strURLParameters, undefined, 'status:off;');
            if (result == 'logoutFromActivityTimeout') {
                window.returnValue = 'logoutFromActivityTimeout';
                result = null;
                window.close();
                window.parent.close();
                window.parent.ICWWindow().Exit();
            }
            if (result != null)
                __doPostBack('upMain', 'ParameterValue:' + parameterName + ':' + result);
            else if (parent != null && typeof (parent.ssrsreport_cancelledcreation) == 'function')
                parent.ssrsreport_cancelledcreation();
            else
                window.close();
        }

        function EnterParameter(parameterName, required) {
            var result = InputBox('Enter value', 'Enter ' + ReplaceString(parameterName, '_', ' '), 'OkCancel', '', 'ANY', undefined, required);
            if (result == null) {
                if (parent != null && typeof (parent.ssrsreport_cancelledcreation) == 'function')
                    parent.ssrsreport_cancelledcreation();
                else
                    window.close();
            }
            else
                __doPostBack('upMain', 'ParameterValue:' + parameterName + ':' + result);
        }
    </script>

    <style type="text/css">
        html, body {
            height: 98%
        }
    </style>
    <!-- Ensure page is full height of screen -->
</head>
<body style="overflow: hidden;">
    <form id="form1" runat="server">
        <asp:ScriptManager runat="server" />
        <asp:HiddenField runat="server" ID="hfParametersLoadedSoFar" />
        <div style="overflow: hidden;">
            <div style="width: 100%; height: 100%; overflow-y: visible;">
                <rsweb:ReportViewer ID="reportViewer" runat="server" Height="100%" Width="100%" ShowExportControls="False" ShowZoomControl="False" ShowRefreshButton="False" />
            </div>
        </div>          
    </form>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
