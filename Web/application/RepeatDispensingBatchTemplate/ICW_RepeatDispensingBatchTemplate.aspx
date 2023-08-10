<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_RepeatDispensingBatchTemplate.aspx.cs" Inherits="application_RepeatDispensingBatchTemplate_ICW_RepeatDispensingBatchTemplate" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<%@ Register src="../../application/pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl"      tagprefix="gc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionID %>';
    var desktopURL = "../sharedscripts/CheckSessionExists.aspx";
    var pageName = "ICW_RepeatDispensingBatchTemplate.aspx";
    //alert(sessionId);
    //alert(desktopURL + " " + pageName);
    windowModal_CheckSession(sessionId, desktopURL, "CheckSessionExists" + "|" + pageName);
</script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Repeat Dispensing Template Editor</title>    
    
    <script type="text/javascript" src="../../application/sharedscripts/jquery-1.3.2.js"></script>
    <script type="text/javascript" src="../../application/pharmacysharedscripts/PharmacyGridControl.js"></script>
    <script type="text/javascript" src="scripts/ICW_RepeatDispensingBatchTemplate.js"></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"></script>
    <script type="text/javascript">
    </script>    
    
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <link href="../../style/OCSGrid.css"     rel="stylesheet" type="text/css" />
    
    <style type="text/css">html, body{height:100%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body onload="form_onload();">
    <form id="form1" runat="server" onkeydown="form_onkeydown(id, event);">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
    <div>
        <div class="PaneCaption" style="width: 100%;">Repeat Dispensing Template Selector</div>
        
        <br />
        
        <div style="width: 100%; height: 89%; text-align: center;">
            <div style="border: 1px solid; width: 89%; max-width: 700px; height:90%;">
                <gc:GridControl id="RDispTemplatesGrid" runat="server" JavaEventDblClick="btnEdit_onclick();"/>
                
                <br />
                
                <asp:UpdatePanel ID="upButtons" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <asp:Label ID="lbUpdating" runat="server" Text="&nbsp;" style="color: #00FF00; width: 80%; font-weight: bold;" EnableViewState="False"></asp:Label>
                    <asp:Label ID="lbError"    runat="server" Text="&nbsp;" style="color: #FF0000; width: 80%; font-weight: bold;" EnableViewState="False"></asp:Label>
                            
                    <br />
                    
                    <hr />
                
                    <table>
                        <tr> 
                            <td><input id="btnNew"    type="button" value="New..."  class="ICWButton" accesskey="N" onclick="DisplayTemplateEditor(0);"    /></td>
                            <td><input id="btnEdit"   type="button" value="Edit..." class="ICWButton" accesskey="E" onclick="btnEdit_onclick();"   /></td>
                            <td><input id="btnDelete" type="button" value="Delete"  class="ICWButton" accesskey="D" onclick="btnDelete_onclick();" /></td>
<% if (isModal) %>                            
<% { %>
                            <td><input id="btnCancel" type="button" value="Close"   class="ICWButton" accesskey="C" onclick="window.close();"      /></td>
<% } %>
                        </tr>                            
                    </table>
                </ContentTemplate>
                </asp:UpdatePanel>                    
            </div>
        </div>
    </div>
    </form>
    <iframe id="CheckSessionExists" application="yes" style="display: none;"></iframe>
</body>
</html>
