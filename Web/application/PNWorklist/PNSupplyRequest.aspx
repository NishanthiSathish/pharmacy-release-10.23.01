<%@ Page Language="C#" AutoEventWireup="true" CodeFile="PNSupplyRequest.aspx.cs" Inherits="application_PNSupplyRequest_PNSupplyRequest" %>
<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- 28Mar12 30493 AJK Increased page size. Addec cell padding and spacing to tables. Added hidden field for storing 48hr bag flag. Added custom validator to check for odd days and 48hr bags. -->
<!-- 28Mar12 30669 AJK Added NoDecimalOrMinus function. Added call to said function from all numeric controls. Changed validation routine to roll several checks into one -->
<!-- 28Mar12 30676 AJK Changed text on many labels. Removed iteration functionality from number/date controls -->
<script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
    <script type="text/javascript" FOR="window" EVENT="onload">
        //MM-2848-Inactivity Monitor
        var sessionId = '<%= SessionInfo.SessionID %>';
        //alert('sessionId ' + sessionId);
        var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
        var pageName = "PNSupplyRequest.aspx";
        windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
    </script>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>PN Supply Request</title>
    <base target=_self>
    
    <link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <link href="../../style/PN.css"          rel="stylesheet" type="text/css" />
    
    <script type="text/javascript" src="../sharedscripts/jquery-1.3.2.js"></script>     
    <script type="text/javascript">                
        window.dialogHeight = "525px"; //28Mar12 30493 AJK Increased for cosmetic benefit
        window.dialogWidth  = "600px"; //28Mar12 30493 AJK Increased for cosmetic benefit

        // Called when key is pressed in from
        // if ESC key performs same operation as cancel button
        // if OK key performs same operation as ok button
        function body_onkeydown(event)
        {
            switch (event.keyCode)  // Check which key was pressed
            {
            case 27: window.close();      break;  // ESC (close the form only works when page is called as modal dialog)
            case 13: $('#btnOK').click(); break;  // Enter (close the form setting return value)  
            }
        }
        
        function form_onload() 
        {       
            Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(StartRequest);
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest  (EndRequest);
        }

        function StartRequest(sender, e)
        {
            $('input').attr('disabled', 'disabled');
            $('button').attr('disabled', 'disabled');
            $('#updateMessage').html("Updating...");
            $('#updateMessage').show();
         }

        function EndRequest(sender, e)
        {
            $('input').removeAttr('disabled');
            $('button').removeAttr('disabled');
            $('#updateMessage').hide();
        }
        
        // 28Mar12 30669 AJK Added. Stops . and - from being passed to the calling control.
        function NoDecimalOrMinus(sender, eventArgs)
        {
            var c = eventArgs.get_keyCharacter();
            if (c == '.' || c == '-')
                eventArgs.set_cancel(true);
        }

    </script>
    <style type="text/css">
        .style1
        {
            width: 168px;
        }
        .style2
        {
            width: 170px;
        }
        .style3
        {
            width: 165px;
        }
    </style>
</head>
<body onkeypress="body_onkeydown(event)" onload="form_onload()">
    <form id="form1" runat="server" style="margin-top: 10px; margin-left: 10px">
        <input type="hidden" id="hdnEpisodeID" runat="server" />
        <input type="hidden" id="hdnRxID" runat="server" />
        <asp:HiddenField ID="hf48hr" runat="server" />
        <asp:HiddenField ID="hfAqueousCombinedExpDays" runat="server" />
        <asp:HiddenField ID="hfLipidExpDays"           runat="server" />
        <telerik:RadScriptManager ID="RadScriptManager1" runat="server">
        </telerik:RadScriptManager>
        <div>
        <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" 
            DecoratedControls="All" Skin="Web20" />
        <telerik:RadWindowManager ID="RadWindowManager1" runat="server">
        </telerik:RadWindowManager>
        <div align="center">
            <asp:Label runat="server" ID="lblNameLabel" Text="Name" />&nbsp<asp:Label runat="server" ID="lblName" Font-Bold="true" />&nbsp&nbsp&nbsp
            <asp:Label runat="server" ID="lblAgeLabel" Text="Age" />&nbsp<asp:Label runat="server" ID="lblAge" Font-Bold="true" />&nbsp&nbsp&nbsp
            <asp:Label runat="server" ID="lblWeightLabel" Text="Dosing Weight" />&nbsp<asp:Label runat="server" ID="lblWeight" Font-Bold="true" />
        </div>
        <div align="center">
            <asp:Label runat="server" ID="lblCaseNoLabel" Text="Case Number" />&nbsp<asp:Label runat="server" ID="lblCaseNo" Font-Bold="true" />&nbsp&nbsp&nbsp
            <asp:Label runat="server" ID="lblNHSNumberLabel" Text="NHS Number" />&nbsp<asp:Label runat="server" ID="lblNHSNumber" Font-Bold="true" />
        </div>
        <br />
        <table cellpadding="5" cellspacing="5" runat="server"> <!-- 28Mar12 30493 AJK Added cell padding and spacing -->
            <tr>
            <td colspan="4" align="center">
                <asp:Label ID="lblCancelled" runat="server" Text="Request has been cancelled" ForeColor="Red" Font-Bold="True" Visible="false" />
            </td>
            </tr>
            <tr>
                <td class="style2">
                    <asp:Label ID="lblRegimen" runat="server" Text="Regimen"></asp:Label>
                </td>
                <td colspan=3>
                    <asp:Label ID="lblRegimenDescription" runat="server" Text="" />
                </td>
            </tr>
        </table>
        <br/>
        <table cellpadding="5px" cellspacing="5px">  <!-- 28Mar12 30493 AJK Added cell padding and spacing -->
            <tr>
                <td class="style2">
                    <asp:Label ID="lblBatchNumber" runat="server" Text="Batch Number"></asp:Label>
                </td>
                <td>
                    <telerik:RadTextBox ID="rtxtBatchNumber" runat="server" Skin="Web20" MaxLength="8" />
                </td>
                <td>
                    <asp:Label ID="lblReqBatchNumber" runat="server" Text="*" ForeColor=Red></asp:Label>
                </td>
                <td>
                    <asp:CustomValidator ID="valBatchNumber"  runat="server" ErrorMessage="Required" onservervalidate="valBatchNumber_ServerValidate" Display="Dynamic" />
                </td>
            </tr>
            <tr>
                <td class="style2">
                    <asp:Label ID="lblAdminStartDate" runat="server" Text="Administration Start Date"></asp:Label><!-- 28Mar12 AJK 30676 Changed text -->
                </td>
                <td colspan=3>
                    <telerik:RadDatePicker ID="rdpAdminStart" runat="server" Skin="Web20" Culture="English (United Kingdom)" >
                        <Calendar UseRowHeadersAsSelectors="False" UseColumnHeadersAsSelectors="False" ViewSelectorText="x" Skin="Web20" ShowRowHeaders="False"></Calendar>
                        <DatePopupButton ImageUrl="" HoverImageUrl=""></DatePopupButton>
                        <DateInput runat="server" DisabledStyle-ForeColor="black" > 
                            <IncrementSettings InterceptArrowKeys="False" InterceptMouseWheel="False" />
                            <DisabledStyle ForeColor="Black"></DisabledStyle>
                        </DateInput>
                    </telerik:RadDatePicker>
                </td>
            </tr>
            <tr>
                <td class="style2">
                    <asp:Label ID="lblPreparationDate" runat="server" Text="Date of Preparation" />
                </td>
                <td>
                    <telerik:RadDatePicker ID="rdpPreparationDate" runat="server" Skin="Web20" 
                        Culture="English (United Kingdom)">
                        <Calendar UseRowHeadersAsSelectors="False" UseColumnHeadersAsSelectors="False" ViewSelectorText="x" Skin="Web20" ShowRowHeaders="False"></Calendar>
                        <DatePopupButton ImageUrl="" HoverImageUrl=""></DatePopupButton>
                        <DateInput ID="DateInput1" runat="server" DisabledStyle-ForeColor="black" > 
                            <IncrementSettings InterceptArrowKeys="False" InterceptMouseWheel="False" />
                            <DisabledStyle ForeColor="Black"></DisabledStyle>
                        </DateInput>
                    </telerik:RadDatePicker>
                </td>
                <td>
                    <asp:Label ID="lblReqPreparationDate" runat="server" Text="*" ForeColor="Red" />
                </td>
                <td>
                    <asp:CustomValidator ID="valPreparationDate"       runat="server" ErrorMessage="Required" onservervalidate="valPreparationDate_ServerValidate"      Display="Dynamic" ></asp:CustomValidator>
                    <asp:CustomValidator ID="valPreparationDateRange"  runat="server" ErrorMessage="After admin start date" onservervalidate="valPreparationDateRange_ServerValidate" Display="Dynamic" ></asp:CustomValidator>
                </td>                
            </tr>
            <tr>
                <td class="style2">
                    <asp:Label ID="lblAqueousCombinedExpiry" runat="server" Text="Aqueous Expiry"></asp:Label><br /><!-- 28Mar12 AJK 30676 Changed text -->
                    <asp:Label ID="lblAqueousCombinedNote" runat="server" Text="(days after preparation date)" Font-Size="X-Small"></asp:Label><!-- 28Mar12 AJK 30676 Changed text -->
                </td>
                <td>
                    <telerik:RadNumericTextBox ID="rnAqueousCombinedExpiryDays" runat="server" Skin="Web20" NumberFormat-DecimalDigits="0" NumberFormat-AllowRounding="False">
                        <IncrementSettings InterceptArrowKeys="False" InterceptMouseWheel="False" />
                        <ClientEvents OnKeyPress="NoDecimalOrMinus" /> 
                        <NumberFormat DecimalDigits="0" />
                    </telerik:RadNumericTextBox>
                </td>
                <td>
                    <asp:Label ID="lblReqAqueousCombinedExpiry" runat="server" Text="*" ForeColor=Red></asp:Label>
                </td>
                <td>
                    <asp:CustomValidator ID="valAqueousCombinedExpiry"       runat="server" ErrorMessage="Required"               onservervalidate="valAqueousCombinedExpiry_ServerValidate"       Display="Dynamic" />
                    <asp:CustomValidator ID="valAqueousCombinedExpiryRange"  runat="server" ErrorMessage="After admin start date" onservervalidate="valAqueousCombinedExpiryRange_ServerValidate"  Display="Dynamic" />
                </td>
            </tr>
            <tr runat="server" id="rowLipidExpDate">
                <td class="style2">
                    <asp:Label ID="lblLipidExpiryDate" runat="server" Text="Lipid Expiry"></asp:Label><br /><!-- 28Mar12 AJK 30676 Changed text -->
                    <asp:Label ID="lblLipidExpiryNote" runat="server" Text="(days after preparation date)" Font-Size="X-Small"></asp:Label><!-- 28Mar12 AJK 30676 Changed text -->
                </td>
                <td>
                    <telerik:RadNumericTextBox ID="rnLipidExpiryDays" runat="server" Skin="Web20" NumberFormat-DecimalDigits="0" NumberFormat-AllowRounding="False">
                        <IncrementSettings InterceptArrowKeys="False" InterceptMouseWheel="False" />
                        <ClientEvents OnKeyPress="NoDecimalOrMinus" /> 
                        <NumberFormat DecimalDigits="0" />
                    </telerik:RadNumericTextBox>
                </td>
                <td>
                    <asp:Label ID="lblReqLipidExpiryDate" runat="server" Text="*" ForeColor=Red></asp:Label>
                </td>
                <td>
                    <asp:CustomValidator ID="valLipidExpiry"      runat="server" ErrorMessage="Required"               onservervalidate="valLipidExpiry_ServerValidate"       Display="Dynamic" />
                    <asp:CustomValidator ID="valLipidExpiryRange" runat="server" ErrorMessage="After admin start date" onservervalidate="valLipidExpiryRange_ServerValidate" Display="Dynamic" />
                </td>
            </tr>
            <tr>
                <td class="style2">
                    <asp:Label ID="lblAqueousCombinedLabelQty" runat="server" Text="Number of Aqueous Labels"></asp:Label><!-- 28Mar12 AJK 30676 Changed text -->
                </td>
                <td>
                    <telerik:RadNumericTextBox ID="rntxtAqueousCombinedLabelQty" runat="server" Skin="Web20" NumberFormat-DecimalDigits="0" NumberFormat-AllowRounding="False">
                        <IncrementSettings InterceptArrowKeys="False" InterceptMouseWheel="False" />
                        <ClientEvents OnKeyPress="NoDecimalOrMinus" /> 
                        <NumberFormat DecimalDigits="0" />
                    </telerik:RadNumericTextBox>
                </td>
                <td>
                    <asp:Label ID="lblReqAqueousCombinedLabelQty" runat="server" Text="*" ForeColor=Red></asp:Label>
                </td>
                <td>
                    <asp:CustomValidator ID="valAminoCombinedQuantity"  runat="server" ErrorMessage="Required" onservervalidate="valAminoCombinedQuantity_ServerValidate" Display="Dynamic"  ></asp:CustomValidator>
                </td>
            </tr>
            <tr runat="server" id="rowLipidLabels">
                <td class="style2">
                    <asp:Label ID="lblLipidLabelQty" runat="server" Text="Number of Lipid Labels"></asp:Label><!-- 28Mar12 AJK 30676 Changed text -->
                </td>
                <td class="style1">
                    <telerik:RadNumericTextBox ID="rntxtLipidLabelQty" runat="server" Skin="Web20"  NumberFormat-DecimalDigits="0" NumberFormat-AllowRounding="False">
                        <IncrementSettings InterceptArrowKeys="False" InterceptMouseWheel="False" />
                        <ClientEvents OnKeyPress="NoDecimalOrMinus" /> 
                        <NumberFormat DecimalDigits="0" />
                    </telerik:RadNumericTextBox>
                </td>
                <td>
                    <asp:Label ID="lblReqLipidLabelQty" runat="server" Text="*" ForeColor=Red></asp:Label>
                </td>
                <td>
                    <asp:CustomValidator ID="valLipidQuantity"  runat="server" 
                        ErrorMessage="Required" 
                        onservervalidate="valLipidQuantity_ServerValidate" Display="Dynamic"  ></asp:CustomValidator>
                </td>
            </tr>
            <tr>
                <td class="style2">
                    <asp:Label ID="lblDays" runat="server" Text="Number of Days Required"></asp:Label>
                </td>
                <td>
                    <telerik:RadNumericTextBox ID="rntxtDays" runat="server" Skin="Web20" NumberFormat-DecimalDigits="0" NumberFormat-AllowRounding="False">
                        <IncrementSettings InterceptArrowKeys="False" InterceptMouseWheel="False" />
                        <ClientEvents OnKeyPress="NoDecimalOrMinus" /> 
                        <NumberFormat DecimalDigits="0" />
                    </telerik:RadNumericTextBox>
                </td>
                <td>
                    <asp:Label ID="lblReqDays" runat="server" Text="*" ForeColor=Red></asp:Label>
                </td>
                <td>
                    <!-- 28Mar12 30669 AJK changed name and rolled multiple checks into one -->
                    <asp:CustomValidator ID="valDays"  runat="server" 
                        ErrorMessage="Required" Display="Dynamic" 
                        onservervalidate="valDays_ServerValidate"  ></asp:CustomValidator>
                </td>
            </tr>
            <tr runat="server" id="rowBaxaCompounder">
                <td class="style2">
                    <asp:Label ID="lblBaxaCompounder" runat="server" Text="Baxa Compounder"></asp:Label>
                </td>
                <td>
                    <asp:CheckBox ID="chkBaxaCompounder" runat="server" />
                </td>
            </tr>
            <tr runat="server" id="rowBaxaLipid">
                <td class="style2">
                    <asp:Label ID="lblBaxaIncludeLipid" runat="server" Text="Baxa Include Lipid"></asp:Label>
                </td>
                <td class="style1">
                    <asp:CheckBox ID="chkBaxaIncludeLipid" runat="server" />
                </td>
            </tr>
        </table>
        <br/>
        <br/>
        <table width="100%">
            <tr>
                <td align="right">
                    <asp:Button ID="btnOK" runat="server" Text="OK" onclick="btnOK_Click" />
                    &nbsp
                    <button ID="btnCacnel" runat="server" onclick="window.close()">Cancel</button>
                </td>
                <td width="10px">
                </td>
            </tr>            
        </table>
    </div>       
    </form>
     <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
