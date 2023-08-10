<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_RepeatDispensing.aspx.cs" Inherits="application_RepeatDispensing_ICW_RepeatDispensing" %>
<%@ Import Namespace="ascribe.pharmacy.shared"%>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Repeat Dispensing Batch Creation</title>
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript">
        function TemplateLookup() {
            var sessionId = <%=_SessionID %>;
            var strXML = window.showModalDialog("../routine/RoutineLookupWrapper.aspx?SessionID=" + sessionId + "&RoutineName=RepeatDispensingBatchTemplateLookupList", undefined, "center:yes;status:no;dialogWidth:900px;dialogHeight:480px");
            if (strXML == 'logoutFromActivityTimeout') {
                strXML = null;
                window.close();
                window.parent.close();
                window.parent.ICWWindow().Exit();
            }

            var newVal = "";
            if ((strXML != undefined) && (strXML != false))
            {
                var xmlLookup = new ActiveXObject("Microsoft.XMLDOM");
                xmlLookup.loadXML(strXML);
                var xmlNode = xmlLookup.selectSingleNode("*");
                if (typeof (xmlNode) != "undefined") 
                    DisplayBatchEditor(xmlNode.attributes.getNamedItem("dbid").nodeValue, "");
            }
        }
        
        function DisplayBatchEditor(templateID,entityID) 
        {
            //var REPEATDISPENSINGBATCHPROCESSORSCREEN_FEATURES = 'dialogHeight:600px; dialogWidth:650px; status:off; center: Yes';
            var REPEATDISPENSINGBATCHPROCESSORSCREEN_FEATURES = 'dialogHeight=475px; dialogWidth=725px; status:off; center:Yes;';
            var strURL = document.URL;
            var intSplitIndex = strURL.indexOf('?');
            var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

            strURLParameters += "&RepeatDispensingBatchTemplateID=" + templateID;
            strURLParameters += "&EntityID=" + entityID;
            strURLParameters += "&Mode=Batch";

            // Clear any existing selection of template or patient
            document.getElementById('txtBatchDesc').text = '';
            if(templateID == '0')
                document.getElementById('hdnEntityID').value = entityID;    // Patient selected
            else
                document.getElementById('hdnEntityID').value = '';
            
            // Displays the tempalte page
            var result = window.showModalDialog('../RepeatDispensingBatchTemplate/RepeatDispensingBatchTemplateModal.aspx' + strURLParameters, '', REPEATDISPENSINGBATCHPROCESSORSCREEN_FEATURES);
            if (result == 'logoutFromActivityTimeout') {
                result = null;
                window.close();
                window.parent.close();
                window.parent.ICWWindow().Exit();
            }

            if ((result != null) && (result != undefined))
            {
            	var resultSplit = result.split(',', 2) // RepeatDispensingBatchTemplateModal returns {BatchID},{SelectPatientByDefault} so split out 
                __doPostBack('BatchCreated', 'TemplateID:' + templateID + ',BatchID:' + resultSplit[0] + ',SelectPatientsByDefault:' + resultSplit[1]);
            }
        }

    </script>
<%
    //ICW.ICWParameter("SiteID", "The Site ID", ""); 
%>
<link href="../../style/WorkListPaged.css" rel="stylesheet" type="text/css" />
<script language="javascript" src="../sharedscripts/ocs/OCSImages.js"></script>
<script language="javascript" src="scripts/ICW_RepeatDispensing.js"></script>
<script language="javascript" src="../sharedscripts/icwfunctions.js"></script>
<script language="javascript" src="../sharedscripts/icw.js"></script>
<script language="javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
<script>
<!--

//===============================================================================
//									ICW Raised Events
//===============================================================================

function RAISE_Dispensing_RefreshState(RequestID_Prescription, RequestID_Dispensing)
{
// This event is listened to by the Dispensing page that hosts the ActiveX Dispensing control, 
// which is hosted in Dispensing web page.
// This event is raised when an item needs to be created or edited by the Dispensing control. 
// A RequestID of 0 means "create", a positive RequestID means edit the item with that RequestID
	window.parent.RAISE_Dispensing_RefreshState(RequestID_Prescription, RequestID_Dispensing);
}

//function RAISE_EpisodeSelected()                      //DJH - Bug 13234 - 06/09/11
function RAISE_EpisodeSelected(jsonEntityEpisodeVid)    //DJH - Bug 13234 - 06/09/11
{
// Occurs when episode is changed. Causes a patient to be selected.
	window.parent.RAISE_EpisodeSelected(jsonEntityEpisodeVid);
}

function RAISE_EpisodeCleared() //DJH - TFS18299
{
    window.parent.RAISE_EpisodeCleared();
}

//-->
</script>

<style type="text/css">html, body{height:100%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body SessionID="<%=_SessionID %>" >
    <form id="frmMain" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat=server EnablePageMethods=true></asp:ScriptManager>
        <asp:UpdatePanel ID="updMain" runat=server UpdateMode=Conditional>
            <ContentTemplate>
                <asp:HiddenField ID="hdnEntityID" runat="server" />
                <asp:HiddenField ID="hdnBatchID" runat="server" />
                <table>
                    <tr>
                        <td nowrap="nowrap">
                            <asp:Label ID="lblTemplate" runat="server" Text="Template"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtTemplate" runat="server" Text="" CssClass="FieldDisabled" Width="625px" Font-Names="Arial Narrow"></asp:TextBox>
                        </td>
                        <td>
                            <input id="btnTemplateLookup" type=button value="Lookup" onclick="Javascript:TemplateLookup()" class="ICWButton" />
                        </td>
                        <td>
                            <asp:Button ID="btnPatient" runat="server" Text="Use Current Patient" CssClass="ICWButton" onclick="btnPatient_Click" Width=125 />
                        </td>
                    </tr>
                    <tr>
                        <td nowrap="nowrap">
                            <asp:Label ID="lblBatchDesc" runat="server" Text="Batch"></asp:Label>
                        </td>
                        <td>
                            <asp:TextBox ID="txtBatchDesc" runat="server" CssClass="FieldDisabled" Width="625px" Font-Names="Arial Narrow"></asp:TextBox>
                        </td>
                        <td>
                            <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="ICWButton" 
                                onclick="btnSave_Click" />
                        </td>
                    </tr>
                </table>
                <div id="tbl-container" style="height:expression(document.frames.frameElement.clientHeight - document.getElementById(&quot;tbl-container&quot;).offsetTop); width:100%; overflow:scroll;"  >
                    <table id="tbl" cellspacing="0" style="width:expression(document.frames.frameElement.clientWidth - 20);" cellpadding=2px>
                            
                            <thead>
                            <tr id="trHeader" class="GridHeading" style="top: expression(document.getElementById(&quot;tbl-container&quot;).scrollTop);position:relative;">
                                <th class="GridHeadingCell GridImage"><img src="../../images/ocs/classPatient.gif"/></th>
                                <th class="GridHeadingCell">Surname</th>
                                <th class="GridHeadingCell">Forename</th>
                                <th class="GridHeadingCell">DOB</th>
                                <th class="GridHeadingCell">Hospital No.</th>
                                <th class="GridHeadingCell">In Use</th>
                                <th class="GridHeadingCell">Matched</th>
                                <th class="GridHeadingCell">Additional Info</th>
                            </tr>
                        </thead>                
                        <tbody id="tbdy"  runat="server" onclick="grid_onclick()" onkeydown="grid_onkeydown()">
                            
                            <asp:Repeater ID="rptData" runat="server" >
                                <ItemTemplate>
                                    <tr e='<%# DataBinder.Eval(Container.DataItem, "EpisodeID") %>' >
                                        <TD><asp:Label Visible="false" ID="EntityID" Text='<%# DataBinder.Eval(Container.DataItem, "EntityID") %>' runat=server /><asp:CheckBox ID="chkSelected" Enabled='<%# (!((bool?)DataBinder.Eval(Container.DataItem, "Available")).HasValue || ((bool?)DataBinder.Eval(Container.DataItem, "Available")).Value) %>'  runat="server" Checked='<%# forceSelectPatientsByDefault || (selectPatientsByDefault && (((bool?)DataBinder.Eval(Container.DataItem, "Available")) ?? false) && (((bool?)DataBinder.Eval(Container.DataItem, "InUse")) ?? false)) %>' /></td>
                                        <td><%# DataBinder.Eval(Container.DataItem, "Surname") %></td>
                                        <td><%# DataBinder.Eval(Container.DataItem, "Forename") %></td>
                                        <td><%# ((DateTime?)DataBinder.Eval(Container.DataItem, "DOB")).ToPharmacyDateString()%></td>
                                        <td><%# DataBinder.Eval(Container.DataItem, "HospitalNumber") %></td>
                                        <td><%# DataBinder.Eval(Container.DataItem, "InUse") == null ? "" : ((bool?)DataBinder.Eval(Container.DataItem, "InUse")).ToYesNoString() %></td>
                                        <td><%# DataBinder.Eval(Container.DataItem, "MatchedDescription") == null ? "" : DataBinder.Eval(Container.DataItem, "MatchedDescription")%></td>
                                        <td><%# DataBinder.Eval(Container.DataItem, "AdditionalInformation") %></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
                
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
