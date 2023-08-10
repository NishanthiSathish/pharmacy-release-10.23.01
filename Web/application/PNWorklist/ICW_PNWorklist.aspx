<%@ Page Language="C#" AutoEventWireup="true" CodeFile="ICW_PNWorklist.aspx.cs" Inherits="application_PNWorklist_ICW_PNWorklist" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<%@ Import Namespace="ascribe.pharmacy.parenteralnutritionlayer" %>
<%@ Import Namespace="ascribe.pharmacy.icwdatalayer" %>

<%@ Register Assembly="Telerik.Web.UI" Namespace="Telerik.Web.UI" TagPrefix="telerik" %>
<%@ Register src="../pharmacysharedscripts/ProgressMessage.ascx" tagname="ProgressMessage" tagprefix="pc" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<% 
    //ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", "") 
    //ICW.ICWParameter("SelectEpisode", "Set this to True to use this application as a way of selecting an episode.  You should only have one application which can select an episode on each desktop.", "False,True")
    //ICW.ICWParameter("SelectRequest", "", "False,True");
    //ICW.ICWParameter("ShowFilterByWard",                 "Display filter by ward option",                    "False,True");
    //ICW.ICWParameter("ShowFilterByDays",                 "Display filter by days option",                    "False,True");
    //ICW.ICWParameter("ShowIncludeCancelled",             "Display filter by include cancelled",              "False,True");
    //ICW.ICWParameter("ShowWithoutSupplyRequest",         "Display filter by regimen without supply request", "False,True");
    //ICW.ICWParameter("RoutineLevel1", "SP to display level one items e.g. PN Prescriptions", "");
    //ICW.ICWParameter("RoutineLevel2", "SP to display level two items e.g. PN Regimens", "");
    //ICW.ICWParameter("RoutineLevel3", "SP to display level three items e.g. PN Supplier Requests", "");
    //ICW.ICWParameter("Lock_To_Site", "Lock To Site Number", "No,Yes");
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <link href="../../style/application.css"                                rel="stylesheet" type="text/css" />
    <link href="../../Style/PharmacyDefaults.css"                           rel="stylesheet" type="text/css" />
	<link href="../sharedscripts/lib/jqueryui/jquery-ui-1.8.17.redmond.css" rel="stylesheet" type="text/css" />

    <style type="text/css">
        html, body{height:90%}       /* Ensure page is full height of screen */
        
        TD.rgExpandCol  /* 29759 XN 28Nov12 made PN Worklist expand column white so looks nicer */
        {
            background: white !important;
            border-top: 1px !important;
            border-bottom: 1px !important;
            border-right: none !important;
        }
    </style>
    
    <script type="text/javascript" language="javascript" src="../SharedScripts/lib/jquery-1.4.3.min.js" async></script>
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
    <%--<script type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"></script> 134442 XN 5Nov15  --%>
	
    <telerik:RadCodeBlock ID="CodeBlock" runat="server">
    <script>
        var PNPrescriptionRequestType = 'PN Prescription';
        var PNRegimenRequestType      = 'PN Regimen';
        var PNSupplierRequestType     = 'Supply Request';
        //var selectByRequestID;    // Removed from being global variable to be a local variable so always correctly initalised TFS29646 XN 20Mar12
        var lastEpisodeID;
        var allowedToCopyPrescription = <%= PNSettings.Worklist.AllowCopyPrescription.ToString().ToLower() %>;

//===============================================================================
//						    ICW Toolbar EventListeners
//===============================================================================

        

        function PHARMACY_PNWorklist_NewRegimen()
        {
    //New Regimen
// <ToolMenu PictureName="new.gif" Caption="Regimen" ToolTip="New regimen" ShortCut="R" HotKey="" />

            // XN 13Mar15 113511 Check user has permission to edit regimen
            if ($('body').attr('CanEditRegimen').toLowerCase() == 'false')
            {
                alert("You don't have permission to create a new regimen");
                return;
            }

            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select a prescription from the list.');
                return;
            }

            if (row.getDataKeyValue('Request Cancellation') == "1")
            {
                alert('Can not create regimen for cancelled prescription.');
                return;
            }            
            
            if (row.getDataKeyValue('RequestType') != PNPrescriptionRequestType)
            {
                alert('Can\'t create regimen at this level.\n\nSelect a prescription from the list.');
                return;
            }
            
            var requestID = row.getDataKeyValue('RequestID');
            var selectByRequestID = DisplayViewAndAdjust(null, requestID, 'add');
            //alert('selectByRequestID' + selectByRequestID);
            if (selectByRequestID != undefined)
            {
                $find('worklist').clearSelectedItems();
                __doPostBack('lpWorklist', 'expand:' + requestID.toString() + ':' + selectByRequestID.toString());
            }
        }

	function PHARMACY_PNWorklist_Issue()
        {
    //Issue
// <ToolMenu Caption="Issue" ToolTip="Issue Supply Request" ShortCut="i" HotKey="" />

            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select a supply request from the list.');
                return;
            }
    
            if (row.getDataKeyValue('Request Cancellation') == "1")
            {
                alert('Can not issue from cancelled regimen.');
                return;
            }            
            
            var requestID   = row.getDataKeyValue('RequestID');
            var requestType = row.getDataKeyValue('RequestType');
            var selectByRequestID;
            
            switch (requestType)
            {
            case PNRegimenRequestType:
                alert('Select a supply request from the list');
                break;
            case PNPrescriptionRequestType:
        		alert('Select a supply request from the list');
		        break;
            case PNSupplierRequestType:
		        selectByRequestID = requestID;
                break;
            }            
                       
            if (selectByRequestID != undefined)
            {
                $find('worklist').clearSelectedItems();
                __doPostBack('upDummy', 'issue:' + requestID.toString() + ':' + selectByRequestID.toString());
		    }                
        }


	function PHARMACY_PNWorklist_Return()
        {
//Return
// <ToolMenu Caption="Return" ToolTip="Return Supply Request" ShortCut="r" HotKey="" />

            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select a supply request from the list.');
                return;
            }
    
            if (row.getDataKeyValue('Request Cancellation') == "1")
            {
                alert('Can not return from cancelled regimen.');
                return;
            }            
            
            var requestID   = row.getDataKeyValue('RequestID');
            var requestType = row.getDataKeyValue('RequestType');
            var selectByRequestID;
            
            switch (requestType)
            {
            case PNRegimenRequestType:
                alert('Select a supply request from the list'); 
                break;
            case PNPrescriptionRequestType:
		        alert('Select a supply request from the list');
		        break;
            case PNSupplierRequestType:
		        selectByRequestID = requestID;
                break;
            }            
                       
            if (selectByRequestID != undefined)
            {
                $find('worklist').clearSelectedItems();
                __doPostBack('upDummy', 'return:' + requestID.toString() + ':' + selectByRequestID.toString());
		    }                
        }

	function PHARMACY_PNWorklist_PrintandIssue()
        {
//Print and Issue
// <ToolMenu Caption="Print and Issue" ToolTip="Print and Issue Supply Request" ShortCut="" HotKey="" />

            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select a supply request from the list.');
                return;
            }
    
            if (row.getDataKeyValue('Request Cancellation') == "1")
            {
                alert('Can not print and issue from cancelled regimen.');
                return;
            }            
            
            var requestID   = row.getDataKeyValue('RequestID');
            var requestType = row.getDataKeyValue('RequestType');
            var selectByRequestID;

            switch (requestType)
            {
            case PNRegimenRequestType:
                alert('Select a supply request from the list'); 
                break;
            case PNPrescriptionRequestType:
        		alert('Select a supply request from the list');
		        break;
            case PNSupplierRequestType:
		        selectByRequestID = requestID;
                break;
            }            
                       
            if (selectByRequestID != undefined)
            {
                $find('worklist').clearSelectedItems();
                                
                var siteNumber = QueryString('AscribeSiteNumber');
                var sessionID  = QueryString('SessionID');
                
                var parameterGetToken =
                {
                    sessionID  : parseInt(sessionID)
                };
                var token  = PostServerMessage("ICW_PNWorklist.aspx/GetToken", JSON.stringify(parameterGetToken));
                
                var parameterGetPrintXML =
                {
                    sessionID  : parseInt(sessionID),
                    siteNumber : parseInt(siteNumber),
                    requestID  : parseInt(requestID)
                };
                var result = PostServerMessage("ICW_PNWorklist.aspx/GetPrintXML", JSON.stringify(parameterGetPrintXML));
                //if ((result != undefined) && result.d && (result.d != ""))
                if ((result != undefined) && result.d)  // 11Sep14 XN  88799  Added printing of prescription from regimen    TFS29645 XN 20Mar12 added checking that GetPrintXML returns valid data
                {
                    var intPortNumber = '<%= intPortNumber %>';
                    var ocxURL ="";
                    if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                    {
                        //var ocxURL = "<%= Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath  %>/integration/Pharmacy/GetEncryptedString.aspx?token=" + token.d + "&SessionID=" + sessionID;
		                ocxURL = "<%= strURLScheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath  %>/integration/Pharmacy/GetEncryptedString.aspx?token=" + token.d + "&SessionID=" + sessionID;
                    }
                    else
                    {
                        ocxURL = "<%= strURLScheme + Uri.SchemeDelimiter + Request.Url.Host %>" + ":" +  "<%= intPortNumber + Request.ApplicationPath  %>/integration/Pharmacy/GetEncryptedString.aspx?token=" + token.d + "&SessionID=" + sessionID;
                    }
                    var returnData = result.d;
                    
                    var ctrlRD = document.getElementById('objPN'); 
                    //ctrlRD.ProcessPN(parameterGetPrintXML.sessionID,parameterGetPrintXML.siteNumber,'C',requestID,result.d,'',ocxURL);     11Sep14 XN  88799   Added printing of prescription from regimen
                    ctrlRD.ProcessPN ( parameterGetPrintXML.sessionID,parameterGetPrintXML.siteNumber, 'C', returnData.requestID_Regimen, returnData.requestID_SupplyRequest, returnData.XML, '', ocxURL ); 
                    __doPostBack('lpWorklist', 'expandParent:' + requestID + ':' + requestID);
                }
		    }                
        }



function PHARMACY_PNWorklist_Print(buttonData)
        {
    //Print
// <ToolMenu Caption="Print" ToolTip="Print Supply Request" ShortCut="i" HotKey="" />

            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select a row from the list.');
                return;
            }
    
            if (row.getDataKeyValue('Request Cancellation') == "1")
            {
                alert('Can not issue from cancelled regimen.');
                return;
            }            
            
            var requestID   = row.getDataKeyValue('RequestID');
            var requestType = row.getDataKeyValue('RequestType');

            var siteNumber = QueryString('AscribeSiteNumber');
            var sessionID  = QueryString('SessionID');
            var selectByRequestID;

            switch (requestType)
            {
            case PNPrescriptionRequestType:
                alert('Select a supply request or regimen from the list');
                break;
            case PNRegimenRequestType:
                // alert('Select a supply request from the list');
                
                // Check if the regimen is authorised 11Sep14 XN 88799
                var parameterIsAuthorised =
                {
                    sessionID        : parseInt(sessionID),
                    requestID_Regimen: parseInt(requestID)
                };
                var authorised = PostServerMessage("ICW_PNWorklist.aspx/IsAuthorised", JSON.stringify(parameterIsAuthorised));
                if (authorised != undefined)
                {
                    if (!authorised.d)
                        alert('Regimen not authorised.');
                    else
                        selectByRequestID = requestID;
                }
		        break;
            case PNSupplierRequestType:
		        selectByRequestID = requestID;
                break;
            }            
                
            if (selectByRequestID != undefined)
            {
                $find('worklist').clearSelectedItems();
                                
                //var siteNumber = QueryString('AscribeSiteNumber');
                //var sessionID  = QueryString('SessionID');
                
                var parameterGetToken =
                {
                    sessionID  : parseInt(sessionID)
                };
                var token = PostServerMessage("ICW_PNWorklist.aspx/GetToken", JSON.stringify(parameterGetToken));
                
                var parameterGetPrintXML =
                {
                    sessionID  : parseInt(sessionID),
                    siteNumber : parseInt(siteNumber),
                    requestID  : parseInt(requestID)
                };
                var result = PostServerMessage("ICW_PNWorklist.aspx/GetPrintXML", JSON.stringify(parameterGetPrintXML));
                //if ((result != undefined) && result.d && (result.d != ""))
                if ((result != undefined) && result.d)  // 11Sep14 XN  88799 Added printing of prescription from regimen TFS29645 XN 20Mar12 added checking that GetPrintXML returns valid data
                {
                    if (buttonData.toLowerCase() == 'debug')
                    {
                        //$('<textarea rows="30" cols="45">' + result.d + '</textarea>').dialog({       11Sep14 XN  88799 Added printing of prescription from regimen
                        $('<textarea rows="30" cols="45">' + result.d.XML + '</textarea>').dialog({
                                modal: true,
                                title: 'Print xml',
                                open:  function(type, data) { $(this).parent().appendTo('form'); },
                                close: function(type, data) { __doPostBack('lpWorklist', 'expandParent:' + requestID + ':' + requestID) },
                                zIndex: 9009
                                });
                    }
                    
                    var intPortNumber = '<%= intPortNumber %>';
                    var ocxURL ="";
                    if (intPortNumber == 0 || intPortNumber == 80 || intPortNumber == 443)
                    {
                        ocxURL = "<%= Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host + Request.ApplicationPath  %>/integration/Pharmacy/GetEncryptedString.aspx?token=" + token.d + "&SessionID=" + sessionID;
                    }
                    else
                    {
                        ocxURL = "<%= Request.Url.Scheme + Uri.SchemeDelimiter + Request.Url.Host %>" + ":" +  "<%= intPortNumber + Request.ApplicationPath  %>/integration/Pharmacy/GetEncryptedString.aspx?token=" + token.d + "&SessionID=" + sessionID;
                    }
                    var returnData = result.d;  // 11Sep14 XN  88799 Added printing of prescription from regimen
                    
                    var ctrlRD = document.getElementById('objPN'); 
                    //ctrlRD.ProcessPN(parameterGetPrintXML.sessionID,parameterGetPrintXML.siteNumber,'P',requestID,result.d,'',ocxURL); 11Sep14 XN  88799 Added printing of prescription from regimen
                    ctrlRD.ProcessPN(parameterGetPrintXML.sessionID, parameterGetPrintXML.siteNumber, 'P', returnData.requestID_Regimen, returnData.requestID_SupplyRequest, returnData.XML, '', ocxURL); 
                    
                    if (buttonData.toLowerCase() != 'debug')
                        __doPostBack('lpWorklist', 'expandParent:' + requestID + ':' + requestID);
                }
            }
		}                

function PHARMACY_PNWorklist_LogView()
        {
    //Issue
// <ToolMenu Caption="Log View" ToolTip="View Issue Logs from Batch" ShortCut="l" HotKey="" />

	        var SessionID = QueryString('SessionID');

            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select a supply request from the list.');
                return;
            }
    
            if (row.getDataKeyValue('Request Cancellation') == "1")
            {
                alert('Can not issue from cancelled regimen.');
                return;
            }            
            
            var requestID   = row.getDataKeyValue('RequestID');
            var requestType = row.getDataKeyValue('RequestType');
            var selectByRequestID;

            switch (requestType)
            {
            case PNRegimenRequestType:
                alert('Select a supply request from the list'); 
                break;
            case PNPrescriptionRequestType:
        		alert('Select a supply request from the list');
		        break;
            case PNSupplierRequestType:
		        selectByRequestID = requestID;
                break;
            }            
                       
            if (selectByRequestID != undefined)
            {
                $find('worklist').clearSelectedItems();
                __doPostBack('upDummy', 'logview:' + requestID.toString() + ':' + selectByRequestID.toString());
		    }                
        }

function PHARMACY_PNWorklist_EditLayouts()
        {
    //Edit Layouts
// <ToolMenu Caption="Edit layouts" ToolTip="Edit layouts" ShortCut="e" HotKey="" />

            $find('worklist').clearSelectedItems();
            __doPostBack('upDummy', 'editlayouts');	                
        }

function PHARMACY_PNWorklist_ViewLayouts()
        {
    //View Layout
// <ToolMenu Caption="View layouts" ToolTip="View layouts" ShortCut="e" HotKey="" />

            $find('worklist').clearSelectedItems();
            __doPostBack('upDummy', 'viewlayouts');	                
        }


        function PHARMACY_PNWorklist_Copy()
        {
    //Copy
// <ToolMenu PictureName="copy.gif" Caption="Copy" ToolTip="Copy prescription or regimen" ShortCut="C" HotKey="" />

            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select an item from the worklist.');
                return;
            }
            
            var parentRow = getParentRow(row);
            if ((parentRow != null) && (parentRow.getDataKeyValue('Request Cancellation') == "1"))
            {
                alert('Parent item has been cancelled, so can not copy.');
                return;
            }

            // XN 13Mar15 113511 Check user has permission to edit regimen
            var requestType = row.getDataKeyValue('RequestType');
            if (requestType == PNRegimenRequestType && $('body').attr('CanEditRegimen').toLowerCase() == 'false')
            {
                alert("You don't have permission to copy the regimen");
                return;
            }

            // XN 20Oct15 You are not allowed to copy the prescription
            if (requestType == PNPrescriptionRequestType && !allowedToCopyPrescription)
            {
                alert("You don't have permission to copy the prescription");
                return;
            }

            var requestID   = row.getDataKeyValue('RequestID');
            var selectByRequestID;

            switch (requestType)
            {
            case PNPrescriptionRequestType: DoAction(OCS_REQUEST_REORDER); selectByRequestID = -1; break;   // new request is held in order entry xml (on session attrbitue)
            case PNRegimenRequestType:      selectByRequestID = DisplayViewAndAdjust(requestID, null, 'copy'); break;
            case PNSupplierRequestType:     alert('Select a prescription, or a regimen'); break;
            }
           
            if (selectByRequestID != undefined)
            {
                $find('worklist').clearSelectedItems();
                __doPostBack('lpWorklist', 'expandParent:' + requestID.toString() + ':' + selectByRequestID.toString());
            }              
        }

        function PHARMACY_PNWorklist_View(buttonData)
        {
    //View
// <ToolMenu PictureName="view.gif" Caption="View" ToolTip="View prescription, regimen, or supplier request" ShortCut="V" HotKey="" />
            var readonly = buttonData != undefined  && buttonData instanceof String && buttonData.toLowerCase() == 'readonly';  // Need buttonData instanceof String as not always string depending on how called

            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select an item from the worklist.');
                return;
            }
    
            var requestID   = row.getDataKeyValue('RequestID');
            var requestType = row.getDataKeyValue('RequestType');
            var canceled    = row.getDataKeyValue('Request Cancellation');
            var selectByRequestID;

            switch (requestType)
            {
            case PNPrescriptionRequestType:
                DoAction(OCS_VIEW);
                break;
            case PNRegimenRequestType:
                selectByRequestID = DisplayViewAndAdjust(requestID, null, readonly ? 'viewReadOnly': 'view');
                break;
                case PNSupplierRequestType:
                    {
                        selectByRequestID = window.showModalDialog('..\\PNWorklist\\PNSupplyRequest.aspx' + getURLParameters() + '&RequestID=' + requestID.toString(), '', 'center:Yes; status:off');
                        if (selectByRequestID == 'logoutFromActivityTimeout') {
                            window.returnValue = 'logoutFromActivityTimeout';
                            window.close();
                            window.parent.close();
                            window.parent.ICWWindow().Exit();
                        }
                        break;
                    }                    
            }
                       
            if (selectByRequestID != undefined)
            {
                $find('worklist').clearSelectedItems();
                __doPostBack('lpWorklist', 'expandParent:' + requestID.toString() + ':' + selectByRequestID.toString());
            }             
        }
        
        function PHARMACY_PNWorklist_ViewRegimen()
        {
    //View Regimen
// <ToolMenu PictureName="view.gif" Caption="View Regimen" ToolTip="View regimen from supplier request" ShortCut="" HotKey="" />

            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select an item from the worklist.');
                return;
            }
    
            var requestID   = row.getDataKeyValue('RequestID');
            var requestType = row.getDataKeyValue('RequestType');

            if ((requestType == PNPrescriptionRequestType) || (requestType == PNRegimenRequestType))
                alert('Select a supply request from the list');
            else
                __doPostBack('upDummy', 'viewRegimen:' + requestID.toString());
        }
        
        function PHARMACY_PNWorklist_Stop()
        {
    //Stop
// <ToolMenu PictureName="stop.gif" Caption="Stop" ToolTip="Stop" ShortCut="S" HotKey="" />

            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select an item from the list.');
                return;
            }

            if (row.getDataKeyValue('Request Cancellation') == "1")
            {
                alert('Item has already been cancelled.');
                return;
            }
            
            // XN 13Mar15 113511 Check user has permission to stop regimen
            var requestType = row.getDataKeyValue('RequestType');
            if ((requestType == PNRegimenRequestType || requestType == PNPrescriptionRequestType) && $('body').attr('CanEditRegimen').toLowerCase() == 'false')
            {
                alert("You don't have permission to stop the item");
                return;
            }

            var requestID   = row.getDataKeyValue('RequestID');
            
            var parameters = 
            {
                sessionID:   parseInt(QueryString('SessionID')),
                requestID:   parseInt(requestID),
                requestType: requestType
            }
            
            var result = PostServerMessage("ICW_PNWorklist.aspx/CanCancel", JSON.stringify(parameters))
            var message= ''
            if ((result != undefined) && (result.d != "") && result.d)
                message = result.d;
            
            if (message == "<ASKUSER>")
            {
                if (confirm('Supply request has been created\n\nDo you still want to cancel?') == false)
                    return;
            }
            else if (message.length > 0)
            {
                alert(message);
                return;
            }

            var selectByRequestID = window.showModalDialog('..\\PNWorklist\\CancelReason.aspx' + getURLParameters() + '&RequestID=' + requestID, '', 'center:Yes; status:off');
            if (selectByRequestID == 'logoutFromActivityTimeout') {
                window.returnValue = 'logoutFromActivityTimeout';
                window.close();
                window.parent.close();
                window.parent.ICWWindow().Exit();
            }

            if (selectByRequestID != undefined)
            {
                $find('worklist').clearSelectedItems();
                __doPostBack('lpWorklist', 'expandParent:' + requestID.toString() + ':' + selectByRequestID.toString());
            }
        }
        
        function PHARMACY_PNWorklist_RespondToItem() 
        {
        //Responds to the currently selected item, if applicable.
// <ToolMenu PictureName="note2.gif" Caption="Result / Reply" ToolTip="Allows you to create a Response to the selected item." ShortCut="R" HotKey="R" DisableEditing="1"/>
            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select an item from the list.');
                return;
            }

            if (row.getDataKeyValue('Request Cancellation') == "1")
            {
                alert('Item has been canelled.');
                return;
            }            
                        
            var requestType = row.getDataKeyValue('RequestType');
            if (requestType != PNSupplierRequestType)
            {
                alert('Item must be a supplier request.');
                return;
            }            

            var requestID = row.getDataKeyValue('RequestID');
            if (requestID != undefined)
                __doPostBack('lpWorklist', 'respondToItem:' + requestID.toString());
        }
        
        function PHARMACY_PNWorklist_SetStatus(buttonData)
        {
    //Set Status
// <ToolMenu Caption="Status" ToolTip="Set item status"  />
            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select an item from the list.');
                return;
            }

            if (row.getDataKeyValue('Request Cancellation') == "1")
            {
                alert('Item has been canelled.');
                return;
            }            

            var requestID = row.getDataKeyValue('RequestID');
            if (requestID != undefined)
                __doPostBack('lpWorklist', 'setStatus:' + requestID.toString() + ':' + buttonData);
        }

        function PHARMACY_PNWorklist_SupplierRequest()
        {
    //Supplier Request
// <ToolMenu PictureName="supply request.png" Caption="Supplier request" ToolTip="Create new supplier request" ShortCut="S" HotKey="" />

            var row = getSelectedItem();
            if (row == null)
            {
                alert('Select a regimen from the list.');
                return;
            }
    
            if (row.getDataKeyValue('Request Cancellation') == "1")
            {
                alert('Can not create supplier request for cancelled regimen.');
                return;
            }        
            
            if (row.getDataKeyValue('Authorised') == "No")
            {
                alert('Can not create supplier request for unauthorised regimen.');
                return;
            }    
            
            var requestID   = row.getDataKeyValue('RequestID');
            var requestType = row.getDataKeyValue('RequestType');
            var selectByRequestID;

            switch (requestType)
            {
                case PNRegimenRequestType:
                    {
                        selectByRequestID = window.showModalDialog('..\\PNWorklist\\PNSupplyRequest.aspx' + getURLParameters() + '&RequestID_Parent=' + requestID.toString(), '', 'center: Yes; status:off');
                        if (selectByRequestID == 'logoutFromActivityTimeout') {
                            window.returnValue = 'logoutFromActivityTimeout';
                            window.close();
                            window.parent.close();
                            window.parent.ICWWindow().Exit();
                        }

                        break;
                    }
            case PNPrescriptionRequestType:
            case PNSupplierRequestType:
                alert('Select a regimen from the list');
                break;
            }            
                       
            if (selectByRequestID != undefined)
            {
                $find('worklist').clearSelectedItems();
                __doPostBack('lpWorklist', 'expand:' + requestID.toString() + ':' + selectByRequestID.toString());
            }                
        }
        
        // Added event handler that selects a request (even if not expanded)
        // and then performs the button action event on the request 12Nov15 XN 133905
        function PHARMACY_PNWorklist_SelectRequestAndPrint(requestId, action)
        {
            __doPostBack('lpWorklist', 'find:' + requestId + ':' + action);
        }

        function worklist_OnGridCreated(sender, args)
        {
            worklist_resize();
        }            
        
        function PHARMACY_PendingItemChanged()
        {
	        __doPostBack('lpWorklist', 'refresh');
        }
        
        function PHARMACY_EpisodeCleared()
        { 
            var strURL = QuerystringReplace(document.URL, "EpisodeID", 0);
            window.navigate (strURL);
        }
        
        function PHARMACY_EpisodeSelected(vid) 
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

	    function RAISE_EpisodeSelected(jsonEntityEpisodeVid)    
	    {
	        ICWEventRaise();
	    }

	    function RAISE_RequestSelected(RequestID)
	    {
	        ICWEventRaise();
	    }

        //===============================================================================
        //						    Extra functions
        //===============================================================================

        // Need to redeclare this method here as pharmacyshared script method is overwritten by other sp
        function PostServerMessage(url, data, async)
        {
            var result;
            $.ajax({
                type: "POST",
                url: url,
                data: data,
                contentType: "application/json; charset=utf-8",
                dataType: "json",
                async:  (async == undefined) ? false : async,
                success: function(msg) 
                {
                    result = msg;
                },
                error: function(jqXHR, textStatus, errorThrown) 
                {
                    // Added support for showing error message
                    if (textStatus == 'error' ) 
                    {
                        if (jqXHR.responseText != undefined)
                            alert('Failed due to error\r\n\r\n' + jQuery.parseJSON(jqXHR.responseText).Message);
                        else if (errorThrown.message != undefined)
                            alert('Failed due to error\r\n\r\n' + errorThrown.message);
                        else
                            alert('Failed due to error.');
                    }
                }
            });
            return result;
        }

        // Called after postback
        // ensures grid has focus
        // 11Aug16 158922 XN
        function pageLoad()
        {            
            setTimeout(function() 
                            { 
                                if (!$('.ui-dialog').is(':visible'))
                                    $get('worklist').focus(); 
                            }, 250);
        }
                       
        function window_onload() {            
            if(<% = (!this.IsPostBack && !suppressTerms && (selectEpisodeMode || (episodeID.HasValue && episodeID > 0))).ToString().ToLower() %>)
            {
                var strURLParameters = getURLParameters();
            	var acceptedTerms;

                acceptedTerms = window.showModalDialog('..\\PNWorklist\\Terms.aspx' + strURLParameters + '&SiteID=' + <%=siteID %> + '&Cancelled=false', 'center: Yes; status:off');
                if (acceptedTerms == 'logoutFromActivityTimeout') {
                    window.returnValue = 'logoutFromActivityTimeout';
                    window.close();
                    window.parent.close();
                    window.parent.ICWWindow().Exit();
                }

                if (acceptedTerms != 'accepted')
                {
                    window.navigate ('..\\PNWorklist\\Terms.aspx' + strURLParameters + '&SiteID=' + <%=siteID %> + '&Cancelled=true');
                }
            }
                
//            // Setup update message 5Nov15 XN 134442 Updated to the new progress message
//            Sys.WebForms.PageRequestManager.getInstance().add_beginRequest(ShowProgressMsg);
//            Sys.WebForms.PageRequestManager.getInstance().add_endRequest  (HideProgressMsg);   

            //setTimeout(function() { $get('worklist').focus(); }, 500);    11Aug16 158922 XN now called in pageLoad
        }

        function worlist_OnKeyPress(sender, eventArgs) 
        {
            switch (eventArgs.get_keyCode())
            {
            case 13:    // Return
                eventArgs.set_cancel(true);
                PHARMACY_PNWorklist_View();
                break;
            case 37:    // left arrow  159036 XN 27Jul16 Added expand by key press
                var row         = getSelectedItem();
                var requestID   = row.getDataKeyValue('RequestID');
                var requestType = row.getDataKeyValue('RequestType');         // 11Aug16 158922 XN fixed script error for supply request   
                if (row != null && requestType != PNSupplierRequestType) 
                    __doPostBack('lpWorklist', 'collapse:' + requestID);
                break;
            case 39:    // right arrow   159036 XN 27Jul16 Added expand by key press
                var row         = getSelectedItem();
                var requestID   = row.getDataKeyValue('RequestID');
                var requestType = row.getDataKeyValue('RequestType');         // 11Aug16 158922 fixed script error for supply request
                if (row != null && requestType != PNSupplierRequestType) 
                    __doPostBack('lpWorklist', 'expand:' + requestID + ':' + requestID);
                break;
            }
        }
        
        function worklist_OnRowSelected(sender, eventArgs)
        {
            var row = getSelectedItem();
            if (QueryString('SelectRequest') == 'True')
                RAISE_RequestSelected(row.getDataKeyValue('RequestID'));
                       	     
            if (QueryString('SelectEpisode') == 'True')
            {
                while (getParentRow(row) != null)
                    row = getParentRow(row);

                var entityID  = row.getDataKeyValue('EntityID' );       	     	
                var episodeID = row.getDataKeyValue('EpisodeID');
                var sessionID = QueryString('SessionID');
                
                if (entityID != null && episodeID != null && lastEpisodeID != episodeID)
                {
                    lastEpisodeID = episodeID;
                    
                    var parameters =
                    {
                        sessionID  : parseInt(sessionID),
                        entityID   : parseInt(entityID),
                        episodeID  : parseInt(episodeID)
                    };
                    var result = PostServerMessage("ICW_PNWorklist.aspx/SetState_Episode", JSON.stringify(parameters));

                    var jsonEntityEpisodeVid = ICW.clinical.episode.eventSelectedRaised(episodeID, 0, sessionID);
                    RAISE_EpisodeSelected(jsonEntityEpisodeVid);
                }	    
            }        	     	
        }

        function getSelectedItem()
        {
            var worklist = $find('worklist');
            
            if (worklist.get_masterTableView().get_selectedItems().length > 0)
                return worklist.get_masterTableView().get_selectedItems()[0];
                
            for (var t = 0; t < worklist.get_detailTables().length; t++)
            {
                if (worklist.get_detailTables()[t].get_selectedItems().length > 0)
                    return worklist.get_detailTables()[t].get_selectedItems()[0];
            }
            
            return null;
        }
        
        function getParentRow(row)
        {
            var parentRow = row.get_owner().get_parentRow();
            row.get_parent().get_dataItems(); // line required to ensure items are created else $find below will return null    
            return (parentRow == null) ? null : $find(parentRow.id);
        }
        
        function worklist_resize()
        {        
            // size grid correctly
            var worklist = $find('worklist');
            if (worklist != null)
            {
                var height = $(window).height() - worklist.GridHeaderDiv.clientHeight - 85;
                if (height < 0)
                    height = 0;
                worklist.GridDataDiv.style.height = height + "px";

                // Resize the columns so that they line up with the headers XN 15Setp14 50736
                var cols     = $('col', worklist.GridHeaderDiv);
                var firstRow = $('tr:eq(0) td', worklist.GridDataDiv);
                for (var r = 0; r < firstRow.length; r++)
                    cols[r].style.width = Math.max($(firstRow[r]).width(), 0);  // 15Oct15 XN 77977 prevent it going -ve
            }
        }

        function DoAction(actionType)
        {
	        //Wrapper to OCSAction, called from the toolbar/menu event handlers	
	        var SessionID = QueryString('SessionID');
	        PrepareOCSData();
	        OCSAction(SessionID, actionType, xmlItem.firstChild, xmlType.firstChild, undefined, xmlStatusNoteFilter, null, null);
        }

        function PrepareOCSData() 
        {
            var SessionID     = QueryString('SessionID');
            var dbid          = getSelectedItem().getDataKeyValue('RequestID');
            var TableID;      
            var RequestTypeID;
            var manualResponse;
            
            switch (getSelectedItem().getDataKeyValue('RequestType'))
            {
            case PNPrescriptionRequestType:
                TableID       = <%= ICWTypes.GetTypeByDescription(ICWType.Request, "PN Prescription").Value.TableID %>;
                RequestTypeID = <%= ICWTypes.GetTypeByDescription(ICWType.Request, "PN Prescription").Value.ID      %>;
                manualResponse= 0;
                break;
            case PNRegimenRequestType:
                TableID       = <%= ICWTypes.GetTypeByDescription(ICWType.Request, "PN Regimen").Value.TableID %>;
                RequestTypeID = <%= ICWTypes.GetTypeByDescription(ICWType.Request, "PN Regimen").Value.ID      %>;
                manualResponse= 0;
                break;
            case PNSupplierRequestType:
                TableID       = <%= ICWTypes.GetTypeByDescription(ICWType.Request, "Supply Request").Value.TableID %>;
                RequestTypeID = <%= ICWTypes.GetTypeByDescription(ICWType.Request, "Supply Request").Value.ID      %>;
                manualResponse= 1;
                break;
            }
            
            var strItem_XML = '<item class="request" dbid="' + dbid + '"'
						        + ' tableid="' + TableID + '"'
						        + ' description=""'
						        + ' detail=""'
						        + ' RequestTypeID="' + RequestTypeID + '"'
						        + ' productid="0"'
						        + ' autocommit="1"'
						        + ' />';
            var strType_XML = '<RequestType RequestTypeID="' + RequestTypeID + '" Description="Prescription" Orderable="1" ManualResponse="' + manualResponse + '" />';

            xmlItem.XMLDocument.loadXML(strItem_XML);
            xmlType.XMLDocument.loadXML(strType_XML);
        }
        
        function DisplayViewAndAdjust(requestID, requestID_parent, action)
        {
            var width = 1007;
            var height= 700;
            var left  = (screen.width  - width ) / 2;
            var top   = (screen.height - height) / 2;
            
            var url = '..\\PNViewAndAdjust\\ICW_PNViewAndAdjust.aspx' + getURLParameters() + '&mode=' + action;
            if (requestID != null)
                url += '&RequestID=' + requestID;
            if (requestID_parent != null)
                url += '&RequestID_Parent=' + requestID_parent;
        
            
            var ret=window.showModalDialog(url, '', 'dialogWidth:' + width + 'px; dialogHeight:' + height + 'px; status:off; left:' + left + 'px; top:' + top + 'px;');
            //alert('retSessionStorage' + sessionStorage.getItem('logoutFromActivityTimeout'));
            if (ret == 'logoutFromActivityTimeout' || sessionStorage.getItem('logoutFromActivityTimeout') == 'true') {
                //alert('ret');
                
                window.returnValue = 'logoutFromActivityTimeout';
                window.close();
                window.parent.close();
                window.parent.ICWWindow().Exit();
            }
            return ret;

        }
    </script>
    </telerik:RadCodeBlock>
</head>
<body scroll="no" onload="window_onload()"
        CanPrescribe  ="<%= SessionInfo.HasAnyPolicies("Prescribing").ToString()             %>"
        CanEditRegimen="<%= SessionInfo.HasAnyPolicies(PNUtils.Policy.Editor).ToString()     %>"
        CanAuthorise  ="<%= SessionInfo.HasAnyPolicies(PNUtils.Policy.Authoriser).ToString() %>"
	AscribeSiteNumber  ="<%= ICW.ICWParameter("AscribeSiteNumber", "3 Digit Site Number e.g. 427", "") %>"
	LocktoSite  ="<%= ICW.ICWParameter("Lock_To_Site", "Lock To Site Number", "No,Yes") %>"
        Token="<%= this.token %>"
    >
<div id="xmlDIV">
<xml runat="server" id="xmlDataID"></xml>
</div>
    <form id="form1" runat="server">
    <pc:ProgressMessage ID="progressMessage" runat="server" />      <%-- 5Nov15 XN 13442 Updated to the new progress message--%>
    <telerik:RadScriptManager ID="RadScriptManager1" runat="server" />
    <asp:UpdatePanel ID="upDummy" runat="server" ChildrenAsTriggers="false" EnableViewState="false" UpdateMode="Conditional" /> <!-- Duumy pannel to allow updates without refresh -->
    
    <telerik:RadFormDecorator ID="RadFormDecorator1" runat="server" DecoratedControls="All" Skin="Web20" />
    <telerik:RadWindowManager ID="RadWindowManager1" runat="server" EnableShadow="true" />    
    <div>
    <table width="100%" height="100%" cellpadding="0" cellspacing="0">	
	    <tr>
		    <td>  
                <telerik:RadToolBar ID="radToolbar" runat="server" Skin="Office2007" OnClientButtonClicked="function (sender, args) {eval(args.get_item().get_commandName()); }">
                    <Items />
                </telerik:RadToolBar>
            </td>
        </tr>
        <tr>
            <td style="vertical-align: middle; padding-left: 15px; padding-top: 5px;">
                <!-- Toolbar below actual surrounds the filter options to just can't put HTML Controls in RadToolBar, so have to trick it width of toolbar set in code depending on number of items -->
                <telerik:RadToolBar ID="radToolbarFilters" runat="server" Skin="Office2007" style="position: absolute; top:35px; left: 0px; z-index:-1;" Height="22px" />
                <div id="toolBarDiv" runat="server" style="vertical-align: middle;">
                    <span id="divWards" runat="server" style="padding-right: 20px;">Ward:&nbsp;<asp:DropDownList ID="ddlWards" runat="server" Width="300px" OnSelectedIndexChanged="dropDownListFilter_OnSelectedIndexChanged" AutoPostBack="True" /></span>
                    <span id="divDays"  runat="server" style="padding-right: 20px;">Days:&nbsp;<asp:DropDownList ID="ddlDays"  runat="server" Width="125px" OnSelectedIndexChanged="dropDownListFilter_OnSelectedIndexChanged" AutoPostBack="True" /></span>
                    <asp:CheckBox ID="cbWithoutSupplyRequest" runat="server" style="padding-right: 20px;" TextAlign="Left" OnCheckedChanged="checkboxFilter_OnCheckedChanged" AutoPostBack="True" Text="Regimen without supply request: " />
                    <asp:CheckBox ID="cbIncludeCancelled" runat="server" TextAlign="Left" OnCheckedChanged="checkboxFilter_OnCheckedChanged" AutoPostBack="True" Text="Include cancelled: " />
                    <OBJECT 
		                id=objPN 
		                style="left:0px;top:0px;width:0px;height:0px"
		                codebase="../../../ascicw/cab/HEdit.cab" 
		                component="PNCtl.ocx"
		                classid=CLSID:23B16D80-1417-4455-8D59-FBB6952F58B2 VIEWASTEXT>
		                <PARAM NAME="_ExtentX" VALUE="16113">
		                <PARAM NAME="_ExtentY" VALUE="11139">					
		                <SPAN STYLE="color:red">ActiveX control failed to load! -- Please check browser security settings.</SPAN>
	                </OBJECT>                             
                </div>
            </td>
        </tr>
        <tr height="5px">
            <td><hr /></td>
        </tr>
        <tr height="100%">
            <td>
                <div id="gridDiv" style="position: absolute; top: 80px;" onresize="worklist_resize();">
                <asp:UpdatePanel ID="lpWorklist" runat="server" UpdateMode="Conditional">
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="ddlWards" />
                    <asp:AsyncPostBackTrigger ControlID="ddlDays" />
                    <asp:AsyncPostBackTrigger ControlID="cbWithoutSupplyRequest" />
                    <asp:AsyncPostBackTrigger ControlID="cbIncludeCancelled" />
                </Triggers>
                <ContentTemplate>
                <telerik:RadGrid ID="worklist" runat="server" Skin="Web20" CellSpacing="0" GridLines="None" Width="100%" Height="100%" OnDetailTableDataBind="worklist_DetailTableDataBind" OnColumnCreated="worklist_ColumnCreated" OnItemDataBound="worklist_OnItemDataBound">
                    <MasterTableView ClientDataKeyNames="RequestID, RequestType, Request Cancellation, EpisodeID, EntityID" DataKeyNames="RequestID, RequestType" HierarchyLoadMode="ServerOnDemand" AllowNaturalSort="False" ExpandCollapseColumn-CollapseImageUrl="../../images/grid/closed.gif" ExpandCollapseColumn-ExpandImageUrl="../../images/grid/open.gif" ExpandCollapseColumn-ButtonType="ImageButton">

                    <DetailTables>
                        <telerik:GridTableView runat="server" ClientDataKeyNames="RequestID, RequestType, Request Cancellation, Authorised" DataKeyNames="RequestID, RequestType" Name="RoutimeLevel2" Width="100%" HierarchyLoadMode="ServerOnDemand" ForeColor="#3333FF" ExpandCollapseColumn-CollapseImageUrl="../../images/grid/closed.gif" ExpandCollapseColumn-ExpandImageUrl="../../images/grid/open.gif" ExpandCollapseColumn-ButtonType="ImageButton">
                        <DetailTables>
                            <telerik:GridTableView runat="server" ClientDataKeyNames="RequestID, RequestType, Request Cancellation" DataKeyNames="RequestID, RequestType" Name="RoutimeLevel3" Width="100%" HierarchyLoadMode="ServerOnDemand" ForeColor="#990099" ExpandCollapseColumn-CollapseImageUrl="../../images/grid/closed.gif" ExpandCollapseColumn-ExpandImageUrl="../../images/grid/open.gif" ExpandCollapseColumn-ButtonType="ImageButton">
                            </telerik:GridTableView>
                        </DetailTables>
                        </telerik:GridTableView>
                    </DetailTables>
                    </MasterTableView>

                    <ClientSettings AllowKeyboardNavigation="true" AllowExpandCollapse="true">
                        <Selecting AllowRowSelect="True" />
                        <ClientEvents OnRowDblClick="PHARMACY_PNWorklist_View" OnKeyPress="worlist_OnKeyPress" OnGridCreated="worklist_OnGridCreated" OnRowSelected="worklist_OnRowSelected" />
                        <KeyboardNavigationSettings EnableKeyboardShortcuts="False" />
                        <Scrolling AllowScroll="True" UseStaticHeaders="True" SaveScrollPosition="True" ScrollHeight="100%" />
                    </ClientSettings>
                </telerik:RadGrid>
                </ContentTemplate>
                </asp:UpdatePanel>
                </div>
            </td>
        </tr>
        </table>  
        
        <%-- <!-- update progress message -->  5Nov15 XN 13442 Updated to the new progress message
        <div id="divUpdateProgress" style="display:none;position:absolute;width:100%;z-index:9900;top:0px;left:0px;height:100%;">
        <table width=100% height=100% style="display:none;">
	    <tr valign=center>
		    <td align=center>
                <div class="ICWStatusMessage" style="vertical-align:middle;height:75px;"><img src="../../images/Developer/spin_wait.gif" /><span id="spanMsg">Processing...</span></div>
            </td>
        </tr>     
        </table>           
        </div> --%>
    </div>
    </form>

    <xml id="xmlItem" />
    <xml id="xmlType" />
    <xml id="xmlStatusNoteFilter" />
</body>
</html>
