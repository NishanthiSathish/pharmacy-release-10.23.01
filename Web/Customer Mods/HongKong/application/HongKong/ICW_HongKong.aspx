<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_HongKong.aspx.cs" Inherits="application_HongKong_ICW_HongKong" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Hong Kong</title>

    <link rel="stylesheet" type="text/css" href="../../style/application.css"/>

    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"   async></script>
    <script type="text/javascript" src="../sharedscripts/lib/json2.js"              async></script>
	<script type="text/javascript" src="../sharedscripts/icwfunctions.js"           async></script>
	<script type="text/javascript" src="../sharedscripts/icw.js"                    async></script>
    <script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js" async></script>
    <script type="text/javascript">
        var sessionId       = <%=  SessionInfo.SessionID                    %>;
        var canEditRegimen  = <%=  this.canEditRegimen.ToString().ToLower() %>;
        var episodeId       = <%=  this.episodeId                           %>;

        // Will
        //  Create new prescription
        //  Create new regimen 
        //  Create new supply request
        function NewPresciptionWizard() 
        {
            // Create new prescription
            var requestId_Prescription = CreatePrescription();

            // If prescription created create new regimen
            if (requestId_Prescription != undefined)
                var regimenInfo = ViewRegimen(null, requestId_Prescription, 'add', true);

            // If regimen created copy over the request alias to the regimen (from session attribute)
            if (regimenInfo != undefined && regimenInfo.RequestId != undefined)
                UpdateAttributeRequestAliases(regimenInfo.RequestId, null);

            // If regimen authorised then create supply request
            if (regimenInfo != undefined && regimenInfo.isAuthorised)
                var requestId_SupplyRequest = CreateSupplyRequest(regimenInfo.RequestId);

            // Ensure request alias are removed from the session attribute
            ClearSessionAttributeRequestAliases();

            // If supply request created print and issue (else select the most appropriate level)
            if (requestId_SupplyRequest != undefined)
                PrintAndIssue(requestId_SupplyRequest);
            else if (regimenInfo != undefined && regimenInfo.RequestId != undefined)
                RAISE_PNWorklist_SelectRequestAndPrint(regimenInfo.RequestId, '');
            else if (requestId_Prescription != undefined)
                RAISE_PendingItemChanged();
        }

        // Will
        //  View or create copy of a new regimen
        //  Create new supply request
        function ModifyRegimenWizard(requestId_OriginalRegimen, editOrCopy) 
        {
            // View or create copy of a new regimen
            var regimenInfo = ViewRegimen(requestId_OriginalRegimen, null, editOrCopy == 'E' ? 'view' : 'copy', true);

            // If regimen created copy over the request alias to the regimen (from session attribute)
            if (regimenInfo != undefined && regimenInfo.RequestId != undefined)
            {
                UpdateAttributeRequestAliases(regimenInfo.RequestId, requestId_OriginalRegimen);
                
                // If new regimen has been created as part of the modify then cancel the old one            
                if (regimenInfo.RequestId != requestId_OriginalRegimen)
                    CancelRegimenAndSupplyRequest(requestId_OriginalRegimen);
            }

            // If regimen authorised then create supply request
            if (regimenInfo != undefined && regimenInfo.isAuthorised)
                var requestId_SupplyRequest = CreateSupplyRequest(regimenInfo.RequestId);
        
            // Ensure request alias are removed from the session attribute
            ClearSessionAttributeRequestAliases();

            // If supply request created print and issue (else select the most appropriate level)
            if (requestId_SupplyRequest != undefined)
                PrintAndIssue(requestId_SupplyRequest);
            else if (regimenInfo != undefined && regimenInfo.RequestId != undefined)
                RAISE_PNWorklist_SelectRequestAndPrint(regimenInfo.RequestId, '');
        }

        // Will 
        //  Allow user to select a regimen
        //  Create copy of regimen
        //  Create new supply request
        function NewSupplyRequestWizard(requestId_OriginalRegimen) 
        {
            // Allow user to select a regimen
            if (requestId_OriginalRegimen == undefined)
            {
                var url = 'SelectRegimen.aspx' + getURLParameters() + '&EpisodeID=' + episodeId;
                requestId_OriginalRegimen = window.showModalDialog(url, '', 'status:off;');
            }

            // Copy regimen
            if (requestId_OriginalRegimen != undefined)
                var regimenInfo = ViewRegimen(requestId_OriginalRegimen, null, 'copy', true);

            // If regimen created copy over the request alias to the regimen (from session attribute)
            if (regimenInfo != undefined && regimenInfo.RequestId != undefined)
                UpdateAttributeRequestAliases(regimenInfo.RequestId, null);

            // If regimen authorized then create supply request
            if (regimenInfo != undefined && regimenInfo.isAuthorised)
                var requestId_SupplyRequest = CreateSupplyRequest(regimenInfo.RequestId);
        
            // Ensure request alias are removed from the session attribute
            ClearSessionAttributeRequestAliases();

            // If supply request created print and issue (else select the most appropriate level)
            if (requestId_SupplyRequest != undefined)
                PrintAndIssue(requestId_SupplyRequest);
            else if (regimenInfo != undefined && regimenInfo.RequestId != undefined)
                RAISE_PNWorklist_SelectRequestAndPrint(regimenInfo.RequestId, '');
            else if (requestId_OriginalRegimen != undefined)
                RAISE_PNWorklist_SelectRequestAndPrint(requestId_OriginalRegimen, '');
        }

        // Will allow a regimen to be viewed in readonly mode
        function ViewRegimenWizard(requestId_Regimen) 
        {
            ViewRegimen(requestId_Regimen, null, 'ViewReadOnly');
            RAISE_PNWorklist_SelectRequestAndPrint(requestId_Regimen, '');
        }

        // Will display the task pick (with just PN templates) as a modal dialog
        // 19Oct15 XN 77976
        function CreatePrescription()
        {
            var requestId = undefined;

            // Show task picker
            var url = ICWGetICWV10Location() + '/application/TaskPicker/TaskPickerModal.aspx?Mode=Folder&ModalMode=Yes&LockSearchFolder=True&Folder=Parenteral Nutrition&Default_Creation_Type=StandardPrescription&Structure=My Formulary&SessionID=<%= SessionInfo.SessionID %>&Show_Contents=Yes&Show_Favourites=No&Show_Search=No&AutoSelectSingleItem=Yes&DispensaryMode=1';
            var res = window.showModalDialog(url, '', 'dialogWidth:420px;dialogHeight:220px;status:off;');
            if (res != undefined && res != '')
            {
                // parse the XML returned from task picker to get the requestId
                var xml = new ActiveXObject("Microsoft.XMLDOM");
                xml.async = false;
                xml.loadXML(res);
                requestId = parseInt(xml.selectSingleNode('//saveok').getAttribute('id'));
            }

            return requestId;
        }

        // Allows creation\copying\vviewing of a regimen
        // requestID_Original - original regimen if copying or viewing
        // requestID_parent   - prescription if adding new regimen
        // action             - PN view mode
        // checkIfAuthorised  - If uses closes without authorising then ask user to confirm
        // return structure of 
        //      RequestId   - new regimen id
        //      isAuthorised- if regimen is authorised
        function ViewRegimen(requestID_Original, requestID_parent, action, checkIfAuthorised)
        {
            var width = 1007;
            var height= 700;
            var left  = (screen.width  - width ) / 2;
            var top   = (screen.height - height) / 2;

            if (!canEditRegimen)
            {
                alert("You don't have permission to create a new regimen");
                return;
            }
            
            // Build up ural
            var url = '..\\PNViewAndAdjust\\ICW_PNViewAndAdjust.aspx' + getURLParameters() + '&mode=' + action;
            if (requestID_Original != null)
                url += '&RequestID=' + requestID_Original;
            if (requestID_parent != null)
                url += '&RequestID_Parent=' + requestID_parent;
            if (action == 'view')
                url += '&EnableEdit=Y';
        
            // Display PN view and adjust screen
            requestID = window.showModalDialog(url, '', 'dialogWidth:' + width + 'px; dialogHeight:' + height + 'px; status:off; left:' + left + 'px; top:' + top + 'px;');
            // Check if regimen is authorised
            var isAuthorised = undefined;
            if (checkIfAuthorised)
                isAuthorised = requestID != undefined && IsRegimenAuthorised(requestID);

            // If not authorise then ask if 
            if (isAuthorised == false)
            {
                var res = confirm('You have not authorised your regimen.\nClose the regimen?');
                if (res == false)
                    return ViewRegimen(requestID == undefined ? requestID_Original : requestID, requestID_parent, action, true);
            }

            return { RequestId: requestID, isAuthorised: isAuthorised };
        }

        // Create the new supply request
        // Returns new supply request Id
        function CreateSupplyRequest(requestID_Regimen)
        {
            var requestId = window.showModalDialog('..\\PNWorklist\\PNSupplyRequest.aspx' + getURLParameters() + '&RequestID_Parent=' + requestID_Regimen.toString(), '', 'center: Yes; status:off');            
            if (requestId == undefined && confirm('You have not created a supply request.\nOK to continue?') == false)
                requestId = CreateSupplyRequest(requestID_Regimen);

            return requestId;
        }

        // Preforms a print and issue
        // this has to be done on the PN View and Adjust screen
        function PrintAndIssue(supplyRequestId)
        {
            RAISE_PNWorklist_SelectRequestAndPrint(supplyRequestId, 'PHARMACY_PNWorklist_PrintandIssue');
        }

        // Calls the web method UpdateAttributeRequestAliases to copy request alias values from the session attribute
        function UpdateAttributeRequestAliases(requestId, requestId_ToCopyFrom)
        {
            var parameters = { 
                                sessionId           : parseInt(sessionId), 
                                requestId           : parseInt(requestId),
                                requestId_ToCopyFrom: parseInt(requestId_ToCopyFrom)
                             };
            PostServerMessage("ICW_HongKong.aspx/UpdateAttributeRequestAliases", JSON.stringify(parameters));
        }

        // Called to clear all the RequestAlias SessionAttributes
        // 19Oct15 XN 77976
        function ClearSessionAttributeRequestAliases()
        {
            var parameters = { sessionId : sessionId };
            PostServerMessage("ICW_HongKong.aspx/ClearSessionAttributeRequestAliases", JSON.stringify(parameters));
        }

        // Calls the web method IsRegimenAuthorised returns if regimen is authorised
        function IsRegimenAuthorised(requestId)
        {
            var parameters = { 
                                sessionId : parseInt(sessionId), 
                                requestId : parseInt(requestId)
                             };
            var result = PostServerMessage("ICW_HongKong.aspx/IsRegimenAuthorised", JSON.stringify(parameters));
            return (result != undefined) && result.d;
        }

        // Calls the web method CancelRegimenAndSupplyRequest to cancel regimen
        function CancelRegimenAndSupplyRequest(requestId_Regimen)
        {
            var parameters = { 
                                sessionId :         parseInt(sessionId), 
                                requestId_Regimen : parseInt(requestId_Regimen)
                             };
            var result = PostServerMessage("ICW_HongKong.aspx/CancelRegimenAndSupplyRequest", JSON.stringify(parameters));
        } 

        // Raise event that is caught by PN worklist
	    function RAISE_PNWorklist_SelectRequestAndPrint(requestId, action)
	    {
	        ICWEventRaise();
	    }

        // Raise event that item has changed causing full refresh 24Nov15 XN 135999
        function RAISE_PendingItemChanged()
        {
	        ICWEventRaise();
        }
    </script>
</head>
<body>
    <form id="form1" runat="server">
    <asp:ScriptManager runat="server" />
    </form>
</body>
</html>
