<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PNRegimenDetails.aspx.cs" Inherits="application_PNViewAndAdjust_PNRegimenDetails" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <base target=_self>
    
    <link href="../../style/application.css"                                rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
    <link href="../../style/PN.css"                                         rel="stylesheet" type="text/css" />
	<link href="../sharedscripts/lib/jqueryui/jquery-ui-1.8.17.redmond.css" rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../SharedScripts/lib/jquery-1.4.3.min.js"></script>
    <script type="text/javascript" src="../sharedscripts/json2.js"></script>
    <script type="text/javascript" src="../SharedScripts/lib/jqueryui/jquery-ui-1.8.17.min.js"></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"></script>
    <script type="text/javascript" src="../sharedscripts/icw.js"></script>
    <script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"></script>
    
    <script type="text/javascript">
        function PostServerMessage(url, data)
        {
	        var result;
	        $.ajax({
		        type: "POST",
		        url: url,
		        data: data,
		        contentType: "application/json; charset=utf-8",
		        dataType: "json",
		        async: false,
		        success: function(msg)
		        {
			        result = msg;
		        }
	        });
	        return result;
	    }                
	    
	    // Called when text changes on requirments tab
	    // calls web method ingredient_TextChanged to calculate total value for peads
        function text_Changed(input)
        {
            var urlParams = document.URL.indexOf('?')[1];
            
            // If nothing changes do nothing
            // TFS30506 28Mar12 XN Prevent unneeded calles to ingredient_TextChanged causing calculated total value to be changed incorrectly 
            if ($(input).val() == $(input).attr('OriginalVersion'))
                return;

            var requestID = parseInt(QueryString('RequestID', urlParams));
            if (isNaN(requestID))
                requestID = null;

            // Call web method
            var parameters =
                {
                    sessionID : parseInt(QueryString('SessionID', urlParams)),
                    requestID : requestID,
                    dbName    : $(input).attr('ID'),
                    value     : $(input).val()
                };
            var result = PostServerMessage("PNRegimenDetails.aspx/ingredient_TextChanged", JSON.stringify(parameters));

            // If returns value the update form
            if (result != undefined)
            {
                var data = JSON.parse(result.d);
                $(input).val(data.value);
                $(input).attr('OriginalVersion', data.value);   // TFS30506 28Mar12 XN Prevent unneeded calles to ingredient_TextChanged causing calculated total value to be changed incorrectly
                $('#' + parameters.dbName + '_PerKilo').val(data.value_PerKilo);
            }
        }
        
        function form_onload() 
        {
            Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(HideProgressMsg);

            $('input[type=text]').filter('[id!=tbRegimenName]').focus(function() { this.select(); } );
        }

        // Handle key press safely  TFS31032  2Apr12  XN            
        function form_onkeydown(event) 
        {
            switch (event.keyCode) 
            {
            case 13:    // Enter (click ok)
                $('#btnOK').click();
                break;
            case 27:    // Escape (cancel)
                $('#btnCancel').click();
            break;
            }
        }
    </script>
     <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%=SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "PNRegimenDetails.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
    <style type="text/css">
    </style>  
    
    <title>Regimen Details</title>
</head>
<body scroll="no" onload="form_onload();" onkeydown="form_onkeydown(event);">
    <form id="form1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server" EnablePageMethods="True" />
    <div>
        <asp:Panel ID="Panel1" runat="server" CssClass="PNSettings" ScrollBars="None" style="padding-top:10px;padding-left:10px;" >
            <asp:UpdatePanel ID="updatePanel" runat="server" UpdateMode="Conditional">
            <ContentTemplate>                
                <asp:Button CssClass="TabSelected" ID="btnRegimen"      runat="server" Text=" Regimen    " onclick="tab_OnClick" AccessKey="G" UseSubmitBehavior="false" />
                <asp:Button CssClass="Tab"         ID="btnRequirements" runat="server" Text="Requirements" onclick="tab_OnClick" AccessKey="Q" UseSubmitBehavior="false" />
                <asp:MultiView ID="multiView" runat="server">
                    <asp:View ID="vInfo" runat="server">
                    <br /><br />
                    <div class="Section" style="padding-top:5px;">
                        <span class="SectionHeader">Info</span>
                        <span class="SectionControls">
                            <span class="EditControlLabel" style="width:100px">Regimen Name</span><asp:TextBox ID="tbRegimenName" runat="server" Width="325px" Height="50px" TextMode="MultiLine" Wrap="true" /><br />
                            <span class="EditControlLabel" style="width:170px">&nbsp;</span><asp:Label ID="lbRegimenNameError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" ></asp:Label><br />
                            
                            <span class="EditControlLabel" style="width:170px;padding-bottom: 10px">Combined</span><asp:CheckBox runat="server" ID="cbIsCombined" OnCheckedChanged="IsCombined_CheckedChanged" AutoPostBack="true" ></asp:CheckBox><br />
                            <span class="EditControlLabel" style="width:170px;padding-bottom: 10px">Central Line Only</span><asp:CheckBox runat="server" ID="cbCentralLineOnly"></asp:CheckBox><br />
                            <div id="divSupply48Hrs" runat="server">
                                <span class="EditControlLabel" style="width:170px;padding-bottom: 10px">48 Hour Regimen</span><asp:CheckBox runat="server" ID="cbSupply48Hrs" OnCheckedChanged="Supply48Hrs_CheckedChanged" AutoPostBack="true" ></asp:CheckBox><br />
                            </div>
                        </span>
                    </div>                

                    <div class="Section">
                        <span class="SectionHeader">Duration</span>
                        <span class="SectionControls">
                            <span class="EditControlLabel" ID="lbInfusionHoursAqueousOrCombined" runat="server" style="width:170px;padding-bottom: 10px">Hours for aqueous infusion</span><asp:TextBox ID="tbInfusionHoursAqueousOrCombined" runat="server" Width="30px" style="text-align:right" /><span style="vertical-align: top; padding-left:10px; padding-right:5px">hours per day</span><asp:Label ID="lbInfusionHoursAqueousOrCombinedError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" /><br />
                            <div ID="divInfusionHoursLipid" runat="server">
                                <span class="EditControlLabel" ID="lbInfusionHoursLipid" runat="server" style="width:170px;padding-bottom: 10px">Hours for lipid infusion</span><asp:TextBox ID="tbInfusionHoursLipid" runat="server" Width="30px" style="text-align:right" /><span style="vertical-align: top; padding-left:10px; padding-right:5px">hours per day</span><asp:Label ID="lbInfusionHoursLipidError"             runat="server" Text="&nbsp;" CssClass="ErrorMessage" /><br />
                            </div>
                        </span>
                    </div>
                        
<%--                    <div class="Section" id="syringeDiv" runat="server">
                        <span class="SectionHeader">Syringes</span>
                        <span class="SectionControls">
                            <span class="EditControlLabel" style="width:170px">Supply Lipid Syringe</span><asp:CheckBox runat="server" ID="cbSupplyLipidSyringe"></asp:CheckBox><br />
                            <span class="EditControlLabel" style="width:170px">Number of Syringes</span>  <asp:TextBox ID="tbNumberOfSyringes" runat="server" Width="50px" style="text-align:right" />&nbsp;<asp:Label ID="lbNumberOfSyringesError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" /><br />
                        </span>
                    </div>     --%>           

                    <div class="Section">                
                        <span class="SectionHeader">Overage</span>
                        <span class="SectionControls">
                            <span class="EditControlLabel" ID="lbOverageAqueousOrCombined" runat="server" style="width:170px;padding-bottom: 10px">Overage aqueous</span><asp:TextBox ID="tbOverageAqueousOrCombined" runat="server" Width="50px" style="text-align:right" />&nbsp;ml&nbsp;<asp:Label ID="lbOverageAqueousOrCombinedError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" /><br />
                            <div id="divOverageLipid" runat="server" >
                                <span class="EditControlLabel" ID="lbOverageLipid" runat="server" style="width:170px;padding-bottom: 10px">Overage lipid</span><asp:TextBox ID="tbOverageLipid" runat="server" Width="50px" style="text-align:right" />&nbsp;ml&nbsp;<asp:Label ID="lbOverageLipidError" runat="server" Text="&nbsp;" CssClass="ErrorMessage" /><br />
                            </div>                                
                        </span>
                    </div>
                    </asp:View>

                    <asp:View ID="vDetails" runat="server">
                        <br /><br />
                        <span class="SectionHeader" style="width:200px;">Ingredients (per 24 Hours)</span><br />
                        <asp:Label ID="lbDosingWeight" runat="server" style="padding-left:10px" />
                        <br /><br />
                        <div style="display:block;position:absolute;top:72px;left:155px">
                            <asp:Table ID="tbIngredients" runat="server" />   
                            <div style="width:100%;text-align:center;" >
                                <asp:Label ID="lbIngredientError" runat="server" CssClass="ErrorMessage" />
                            </div>                         
                        </div>
                    </asp:View>                    
                </asp:MultiView>
                <div style="display:block;position:absolute;bottom:10px;left:250px">
                    <asp:Button CssClass="PharmButton" ID="btnOK"     runat="server" Text="OK"     OnClick="OK_Click" CausesValidation="False" />&nbsp;&nbsp;&nbsp;
                    <asp:Button CssClass="PharmButton" ID="btnCancel" runat="server" Text="Cancel" OnClientClick="window.close(); return false;" />
                </div>                
            </ContentTemplate>
            </asp:UpdatePanel>                
        </asp:Panel>            
    </div>       
    </form>
     <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
