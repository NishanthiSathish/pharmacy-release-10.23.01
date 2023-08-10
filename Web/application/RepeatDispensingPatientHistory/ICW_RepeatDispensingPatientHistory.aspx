<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_RepeatDispensingPatientHistory.aspx.cs" Inherits="application_RepeatDispensingPatientHistory_RepeatDispensingPatientHistory" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>

<!-- 12Apr12 AJK Created -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script type="text/javascript" language="javascript" src="../SharedScripts/lib/jquery-1.4.3.min.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/json2.js"></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.8.17.min.js"></script>
	<script type="text/javascript" language="javascript" src="../sharedscripts/icwfunctions.js"></script>
	<script type="text/javascript" language="javascript" src="../sharedscripts/icw.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/Controls.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
	<script type="text/javascript" language="javascript" src="../pharmacysharedscripts/pharmacyscript.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/ocs/OCSShared.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/ocs/OCSContextActions.js"></script>
    <script type="text/javascript" language="javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"></script>

    <telerik:RadCodeBlock ID="CodeBlock" runat="server">
        <script>

        function EVENT_EpisodeCleared()
        { 
            var strURL = QuerystringReplace(document.URL, "EpisodeID", 0);
            window.navigate (strURL);
        }
        
        function EVENT_EpisodeSelected(vid) 
        {
            // Check episode and entity rows exist in the DB with the expected versions as specified in the vid parameter
            ICW.clinical.episode.episodeSelected.init(<%= Request.QueryString["SessionID"] %>, vid, EntityEpisodeSyncSuccess);
            
            // Called if or when Entity & Episode exist in the DB at the correct versions
            function EntityEpisodeSyncSuccess(vid) 
            {
                var strURL = QuerystringReplace(document.URL, "EpisodeID", vid.EntityEpisode.vidEpisode.EpisodeID);
                window.navigate (strURL);
            }            
        }

        function RadGrid_OnGridCreated(sender, args)
        {
            radgrid_resize();
        }            

        function radgrid_resize()
        {        
            // size grid correctly
            var radgrid = $find('RadGrid1');
            if (radgrid != null)
            {
                var height = $(window).height() - radgrid.GridHeaderDiv.clientHeight - 85;
                if (height < 0)
                    height = 0;
                radgrid.GridDataDiv.style.height = height + "px";
            }              
        }



        </script>
    </telerik:RadCodeBlock>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server"/>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" Skin="Web20" />
        <asp:UpdatePanel ID="UpdatePanel1" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <telerik:RadGrid ID="RadGrid1" runat="server" Skin="Web20" CellSpacing="0" 
                    GridLines="None" Width="875px" oncolumncreated="RadGrid1_ColumnCreated" 
                    onitemdatabound="RadGrid1_ItemDataBound" onprerender="RadGrid1_PreRender" >
                    <MasterTableView ClientDataKeyNames="RepeatDispensingBatchID" DataKeyNames="RepeatDispensingBatchID" HierarchyLoadMode="ServerOnDemand" AllowNaturalSort="False">
                    </MasterTableView>

                    <ClientSettings AllowKeyboardNavigation="true" AllowExpandCollapse="true">
                        <Selecting AllowRowSelect="True" />
                        <ClientEvents OnGridCreated="RadGrid_OnGridCreated" />
                        <KeyboardNavigationSettings EnableKeyboardShortcuts="False" />
                        <Scrolling AllowScroll="True" UseStaticHeaders="True" SaveScrollPosition="True" ScrollHeight="100%" />
                    </ClientSettings>
                </telerik:RadGrid>
            
            </ContentTemplate>
        </asp:UpdatePanel>
    </div>
    </form>
</body>
</html>
