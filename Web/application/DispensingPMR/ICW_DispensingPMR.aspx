<%@ Page Language="C#" EnableTheming="false" EnableViewState="false" AutoEventWireup="true" CodeFile="ICW_DispensingPMR.aspx.cs" Inherits="application_DispensingPMR_ICW_DispensingPMR" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.icwdatalayer" %>
<%@ Import Namespace="Newtonsoft.Json" %>

<%
    //ICW.ICWParameter("WorkListAlternateRowColour", "Set this to True to alternate the row colours on a worklist.", "True,False");
    //ICW.ICWParameter("StatusNoteFilterAction", "Determines whether the StatusNoteFilter is a list of note statuses to be included or excluded.", "exclude,include");
    //ICW.ICWParameter("StatusNoteFilter", "Comma-separated list of Status Note Type buttons to include/excluded", "");
    //ICW.ICWParameter("PrescriptionRoutine", "Routine used to load prescriptions", "");
    //ICW.ICWParameter("SelectEpisode", "Set this to True to use this application as a way of selecting an episode.  You should only have one application which can select an episode on each desktop.", "False,True");
    //ICW.ICWParameter("RepeatDispensing", "Used to identify whether the application is running in repeat dispensing mode", "False,True");
    //ICW.ICWParameter("View", "List only current items or history items", "Current,History");
    //ICW.ICWParameter("PSO",  "Used to identify whether the application is running in PSO mode", "False,True");
    //ICW.ICWParameter("EnableEMMRestrictions", "Enables restrictions of the new amend and cancel buttons for eMM wards", "False,True");
%>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Dispensing PMR</title>

    <link rel="stylesheet" type="text/css" href="../../style/application.css"    />
    <link rel="stylesheet" type="text/css" href="../../style/DispensingPMR.css" />
    
    <script language="javascript" type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"                 async></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/icw.js"                                  async></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/icwfunctions.js"                         async></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/ocs/OCSShared.js"                        async></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/ocs/OCSContextActions.js"                async></script>
    <script language="javascript" type="text/javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"      defer></script>
    <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"               async></script>
    <script language="javascript" type="text/javascript" src="script/DispensingPMR.js"                                  async></script>
    <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/ProgressMessage.js"              defer></script>
    <script language="javascript" type="text/javascript" src="../pharmacysharedscripts/OCSProcessor.js"                 defer></script>
    
    <script language="javascript">
        var m_SessionID                = <%= this.sessionID                                                     %>;
        var m_EpisodeID                = <%= this.episodeID.ToString()                                          %>; 
//        var m_SelectEpisode            = <%= (this.Request["SelectEpisode"]              ?? "false").ToLower()  %>;   66246 19Jun13 XN moved into viewSettings so can pass to server
        var workListAlternateRowColour = <%= (this.Request["WorklistAlternateRowColour"] ?? "true" ).ToLower()  %>;
        var viewSettings               = <%= JsonConvert.SerializeObject(this.viewSettings) %>;     /* 60657 18Jul13 XN set view settings directly so automatically takes new parameters */
        var controlCleared = true;      
        var V11Location = '<%= ConfigurationSettings.AppSettings["ICW_V11Location"] %>';                     
        var treatmentPlanRequestTypeID = <%= (ICWTypes.GetTypeByDescription(ICWType.Request, "Treatment Plan") ?? new ICWTypeData()).ID %>; /* XN 59791 25Mar13 fix task picker issue */
        
        //===============================================================================
        //									ICW Raised Events
        //===============================================================================


        function EVENT_DispensingList_PrescriptionNew()
        {
        //Views the currently selected item
        // <ToolMenu PictureName="new.gif" Caption="New Prescription" ToolTip="New Prescription" ShortCut="N" HotKey="" />
	        PrescriptionNew();
        }

	    function EVENT_DispensingList_PrescriptionNewPSO()
	    {
	    //Views the currently selected item
	    // <ToolMenu PictureName="new.gif" Caption="New PSO Prescription" ToolTip="New PSO Prescription" ShortCut="" HotKey="" />
		    PrescriptionNewPSO();
	    }
        
        function EVENT_DispensingList_UMMCBilling()
        {
        // XN 11Jan11 F0100728 Displays UMMC billing screen 
        // <ToolMenu PictureName="dollar.gif" Caption="Billing" ToolTip="Allows selection of dispensings to send to billing." ShortCut="B" HotKey="" />
            var strURL = document.URL;
            var intSplitIndex = strURL.indexOf('?');
            var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

            // Displays the UMMC billing screen as a popup
            var ret=window.showModalDialog('../UMMCBilling/UMMCBillingScreenModal.aspx' + strURLParameters, '', 'dialogHeight:670px; dialogWidth:980px; status:off; center: Yes');
            if (ret == 'logoutFromActivityTimeout') {
                ret = null;
                window.close();
                window.parent.close();
                window.parent.ICWWindow().Exit();
            }

        }
        
        function EVENT_DispensingList_RPTDispLink()
        {
        //links the currently selected dispensing to its prescription
        // <ToolMenu PictureName="new.gif" Caption="Repeat Dispensing Link" ToolTip="Link for Repeat Dispensing" ShortCut="" HotKey="" />
            var selectedRows = GetSelectedRows();
            if (selectedRows.length != 1)
                return;
            
            var requestID_Prescription = selectedRows[0].getAttribute("id_parent");
            var requestID_Dispensing   = selectedRows[0].getAttribute("id");
	        RAISE_Dispensing_RefreshState(0, 0); //20Sep13 TH (TFS 73841)

            //20Feb14 TH Added call (TFS 84751)
            //We now want a validation check here to ensure the patient has a linked Repeat dispensing settings row
            //var sessionID = document.body.getAttribute("SessionID");
            //var episodeID = document.body.getAttribute("EpisodeID");
            var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
            var strURL = '../RepeatDispensing/RepeatDispensing.aspx?Method=IsRepeatPatientSaved'
			          + '&SessionID=' + m_SessionID
			          + '&EpisodeID=' + m_EpisodeID;
			  
			  
            objHTTPRequest.open("POST", strURL, false); //false = syncronous                              
            objHTTPRequest.send("");
            if (objHTTPRequest.responseText.substring(0,1) == "0") 
            {
               alert('Cannot link as patient does not have Repeat Dispensing Patient Details set');
            }
            else
            {
                var res = window.showModalDialog("../RepeatDispensing/RepeatDispensingLinkingModal.aspx?DispensingID=" + requestID_Dispensing + "&SessionID=" + m_SessionID, "", "");
                if (res == 'logoutFromActivityTimeout') {
                    res = null;
                    window.close();
                    window.parent.close();
                    window.parent.ICWWindow().Exit();
                }

                if (res != undefined)
                {
                    RefreshRow(requestID_Prescription);
                    RefreshRow(requestID_Dispensing, true);
                }
            }
        }        
        
        function EVENT_DispensingList_PatientPrint()
        {
        //Views the currently selected item
        // <ToolMenu PictureName="new.gif" Caption="Patient Printing" ToolTip="Patient Printing" ShortCut="P" HotKey="" />
	        RAISE_Dispensing_RefreshState(0, -1);
            controlCleared = false;
        }        
        
        function EVENT_DispensingList_PatientBagLabel()
        {
            //Views the currently selected item
            // <ToolMenu PictureName="new.gif" Caption="Bag Label" ToolTip="Patient Bag Label Printing" ShortCut="B" HotKey="" />
	        RAISE_Dispensing_RefreshState(0, -3);
            controlCleared = false;
        }
        
        function EVENT_DispensingList_Dispense()
        {
            //Dispense an item
            // <ToolMenu PictureName="syringe.gif" Caption="Dispense" ToolTip="Dispense" ShortCut="D" HotKey="" />
	        Dispense();
        }        

        function EVENT_DispensingList_DispenseNewDose()
        {
            //Dispense an item
            // <ToolMenu PictureName="syringe.gif" Caption="Dispense" ToolTip="Dispense" ShortCut="D" HotKey="" />
            var selectedRows = GetSelectedRows();
            
	        if (selectedRows.length == 1 && selectedRows[0].getAttribute("current") == "1" &&
	            (selectedRows[0].getAttribute("rowType") == "Prescription" || selectedRows[0].getAttribute("rowType") == "Merged"))
	        {
				var requestID_Prescription	= Number(selectedRows[0].getAttribute("id"));
				RAISE_Dispensing_RefreshState(requestID_Prescription, -4);
                controlCleared = false;
		    }
		}
		
        function EVENT_DispensingList_View() 
        {
            //Copies the selected item, then cancels the original
            // <ToolMenu PictureName="view.gif" Caption="View" ToolTip="Displays the selected item." ShortCut="" HotKey="V" />
            void DoAction(OCS_VIEW, null);
        }		

        function EVENT_DispensingList_CancelAndCopyItem() 
        {
            //Copies the selected item, then cancels the original
            // <ToolMenu PictureName="action remove.gif" Caption="Copy and Cancel" ToolTip="Creates a copy of the selected item, then cancels the original." ShortCut="" HotKey="C" />	
	        ClearControl();
	        
    		var strNewItem_XML = DoAction(OCS_CANCEL_AND_REORDER, null);

            //Deal with the items the user selected.
            //TaskPicker returns a blank string if the user cancels.
            if (strNewItem_XML != '' && strNewItem_XML != undefined && strNewItem_XML.indexOf('<saveresults') >= 0) 
            {
                if (strNewItem_XML.indexOf('<saveok ') >= 0)
                {
                    // Reload self
                    var xmlDoc = $.parseXML(strNewItem_XML);
                    var requestID_Prescription = Number($('saveok', xmlDoc).attr('id'));
                
                    RefreshGrid(requestID_Prescription, true);
                }
                else
                {
                    var requestId = GetSelectedRows().attr('id');
                    if (requestId != undefined)
                    {
                        RefreshRow(requestId);
                        RowSelect(FindRow(requestId), undefined, true);
                    }
                }

            }    		
        }
        
        function EVENT_DispensingList_CancelItem() 
        {
            //Cancels the selected item, if applicable
            // <ToolMenu PictureName="cross green.gif" Caption="Cancel" ToolTip="Cancels the selected request." ShortCut="" HotKey="X" />
	        var refreshFunc = (GetSelectedRows().length > 1) ? DataChangedRefreshGrid : DataChangedRefreshRow;
	        ClearControl();
	        void DoAction(OCS_CANCEL, refreshFunc);
        }        

        function EVENT_DispensingList_AttachNotes() 
        {
            //View/edit attached notes for the selected item
            // <ToolMenu PictureName="../ocs/classAttachedNote.gif" Caption="Attached Notes" ToolTip="Allows you to view and create notes which are attached to the selected item." ShortCut="A" HotKey="" />
	        void DoAction(OCS_ANNOTATE, DataChangedRefreshRow);

            // If merged prescription the update the parent 01Dec15 XN 136786
            var parentId = GetSelectedRows().attr('id_parent');
            if (parentId != undefined)
                RefreshRow(parentId);
        }        
        
        function EVENT_DispensingList_PrescriptionNewPCT()
        {
            //Views the currently selected item
            // <ToolMenu PictureName="new.gif" Caption="New PCT Prescription" ToolTip="New PCT Prescription" ShortCut="" HotKey="" />
	        PrescriptionNewPCT();
        }

        function EVENT_DispensingList_PrintSpecifiedReport(ReportName)
        {
            //Prints the selected item
            // <ToolMenu PictureName="Printer.gif" Caption="Print Report" ToolTip="Prints the report." ShortCut="" HotKey="" />
            if (ReportName == "")
                alert("The specified report button_data cannot be found. Please ensure that the name is specified correctly in the Desktop Editor.");
            else 
            {
                // txtPrintReport.value = ReportName; 18Sep13 XN 72788 prevent txtPrintReport script error
                $('#txtPrintReport').val(ReportName);
                if (PrintNamedReport(m_SessionID, ReportName, false))
                    ToolMenuEnable($('radMainButtonsToolbar'), 'DispensingList_PrintSpecifiedReport', false);
            }
        }

        function EVENT_DispensingList_PrescriptionMerge()
        {
            // XN 31May11 F0100728 Added button for PrescriptionLinking
            // <ToolMenu PictureName="prescription linking.gif" Caption="Prescription Merge" ToolTip="Allow selection of prescription to linking screen." ShortCut="A" HotKey="" />
            PrescriptionMerge();
        }

	function EVENT_DispensingList_DispensePSO()
	{
	//Create a PSO from a prescription
	// <ToolMenu PictureName="supply request.png" Caption="Patient Specific Order" ToolTip="Creates a Patient Specific Order for the given item" ShortCut="" HotKey="" />
            var selectedRows = GetSelectedRows();
            
	        if (selectedRows.length == 1 && selectedRows[0].getAttribute("current") == "1" &&
	            (selectedRows[0].getAttribute("rowType") == "Prescription" || selectedRows[0].getAttribute("rowType") == "Merged"))
	        {
				var requestID_Prescription	= Number(selectedRows[0].getAttribute("id"));
				RAISE_Dispensing_RefreshState(requestID_Prescription, -5);
                controlCleared = false;
		    }
	}

	function EVENT_DispensingList_DispenseNewDosePSO()
	{
	//Dispense an item
	// <ToolMenu PictureName="supply request.png" Caption="Patient Specific Order" ToolTip="Creates a Patient Specific Order for the given item" ShortCut="D" HotKey="" />
            var selectedRows = GetSelectedRows();
            
	        if (selectedRows.length == 1 && selectedRows[0].getAttribute("current") == "1" &&
	            (selectedRows[0].getAttribute("rowType") == "Prescription" || selectedRows[0].getAttribute("rowType") == "Merged"))
	        {
				var requestID_Prescription	= Number(selectedRows[0].getAttribute("id"));
				RAISE_Dispensing_RefreshState(requestID_Prescription, -6);
                controlCleared = false;
		    }
	}

        
        // F0096556 ST 23Sep10 Added missing refresh event to prevent javascript error.
        function Refresh() 
        {
            // RefreshGrid(); XN think this first more due to bug if canceling form, so do nothing and let reset of code handle true refresh
        }        
                
        function EVENT_Dispensing_RefreshView(RequestID_Prescription, RequestID_Dispensing)
        {
            // Causes this list to be refreshed from the DB
	        if (RequestID_Dispensing > 0)
	        {
		        if (FindRow(RequestID_Dispensing) != null)
		            RefreshRow(RequestID_Dispensing);
		        else
		            FetchChildRows(RequestID_Prescription, RequestID_Dispensing);
		        RefreshRow(RequestID_Prescription);
		        
		        // Done manually here so dispensing get selected
                refreshRowStripes();
                //RowSelect(FindRow(RequestID_Dispensing));     60557 04Apr13 XN prevent setting focus if dispensing control should have it                
                RowSelect(FindRow(RequestID_Dispensing), undefined, true);
		    }
	        else
	            SetFocus();
        }        

	function EVENT_DispensingList_PatientInvoice() {
            // <ToolMenu PictureName="new.gif" Caption="Patient Invoice" ToolTip="Patient Invoice Printing" HotKey="" />
            RAISE_Dispensing_RefreshState(0, -7);
            controlCleared = false;
        }

        //===============================================================================
        //									ICW EventListeners
        //===============================================================================

        function EVENT_ReportNotFound(ReportName)
        {
            // if (document.all("txtPrintReport") != undefined && ReportName == txtPrintReport.value)   18Sep13 XN 72788 prevent txtPrintReport script error
            if (document.all("txtPrintReport") != undefined && ReportName == $('#txtPrintReport').val())
            {
                var msg = 'The specified report ' + ReportName + ' cannot be found.\nPlease ensure that the name is specified correctly in the Desktop Editor.'
                Popmessage(msg, 'Report Not Found!', 'dialogHeight:200px;dialogWidth:325px;resizable:yes;status:no;help:no;');
            }
        }

        function EVENT_EpisodeSelected(vid)
        {
//          11Sep13 XN 72983 prevent updateing whole page just refresh grid
//            var episodeID = $.parseJSON(vid).EntityEpisode.vidEpisode.EpisodeID;
//            if (m_EpisodeID == episodeID)
//            {
//                RefreshGrid(0, false);
//                form_onload();
//                UpdateToolbarButtons(); // 49908 XN 26Nov12 Disable other buttons
//            }
//            else
//                ICW.clinical.episode.episodeSelected.init(<%= Request["SessionID"] %>, vid, EntityEpisodeSyncSuccess);  // if episode changes force complete refresh.
//                
//            function EntityEpisodeSyncSuccess(vid)
//            {
//    	        window.location.reload();
//            }                                

            SetNewPatientEpisode($.parseJSON(vid).EntityEpisode.vidEpisode.EpisodeID);
        }

        //DJH - TFS Bug 12880 - Add new Episode Cleared event.
        function EVENT_EpisodeCleared() 
        {
            ClearControl();
            $('#tbdy').children().remove();
            m_EpisodeID = 0;
            form_onload();
            UpdateToolbarButtons(); // 49908 XN 26Nov12 Disable other buttons
        }
        
        function EVENT_RequestSelected() //LM 16/01/2008 Code 162
        {
            RowUnselect();
        }

        function EVENT_RequestChanged() 
        {
            RefreshGrid(GetSelectedRows().focus().first().attr('id'));
        }

        function EVENT_NoteChanged()
        {
            RefreshGrid(GetSelectedRows().focus().first().attr('id'));
        }

        function EVENT_CustomEvent(buttonData) 
        {
            switch (buttonData.toLowerCase())
            {
            case 'fastrepeat': 
                if (ICWWindowIsVisible())   // 20Sep13 XN 73809 Only display fast repeat if current page is in view (prevent multiple dialoges being displayed)
                    ShowFastRepeat(); 
                break;
            }
        }
                
        // Called by button on episode selector
        // Brings up fast repeat form, and reloads new patient (will also dispense the seleted prescription)
        function EVENT_FastRepeat()
        {
            ShowFastRepeat();
        }

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

        function RAISE_EpisodeSelected(jsonEntityEpisodeVid)
        {
        // Occurs when episode is changed. Causes a patient to be selected.
	        window.parent.RAISE_EpisodeSelected(jsonEntityEpisodeVid);
        }

        //DJH TFS13018
        function RAISE_EpisodeCleared() 
        {
            window.parent.RAISE_EpisodeCleared();
        }

        function RAISE_RequestSelected()
        {
            window.parent.RAISE_RequestSelected();
        }

        function RAISE_RequestChanged()
        {
            window.parent.RAISE_RequestChanged();
        }
        
        function RAISE_NoteChanged()
        {
            window.parent.RAISE_NoteChanged();
        }
    
	    function RAISE_Prescription_info(lngRequestID_Prescription)
	    {
	        window.parent.RAISE_Prescription_info(lngRequestID_Prescription);
	    }
	    
	    function RAISE_Dispensing_info(lngRequestID_Dispensing)
	    {
	        window.parent.RAISE_Dispensing_info(lngRequestID_Dispensing);
	    }
    </script>
</head>
<body scroll="no" class="GridBody" onload="form_onload();" onresize="worklist_resize();">
    <form id="form1" runat="server">
    <div>
	<asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>
        <input type="hidden" id="txtPrintReport" name="txtPrintReport" value="" />
        
        <div class="PaneCaption PaneCaptionFont" style="padding: 5px;" nowrap><%= this.title %></div>        
        <div id="Toolbar" style="padding-bottom:1px;" class="Toolbar">
            <asp:Panel ID="panMainButtonsToolbar" runat="server" Width="100%" EnableTheming="False" EnableViewState="False" CssClass="Toolbar">
<%= this.mainToolbar %>
            </asp:Panel>
		    <asp:Panel ID="panStatusButtonsToolbar" runat="server" Width="100%" EnableTheming="False" EnableViewState="False" CssClass="Toolbar">
<%= this.statusToolbar %>
            </asp:Panel>
        </div>
        <div id="tbl-container" style="width:100%;height:100%;overflow-y: scroll;">
            <table id="tbl" cellspacing="0" style="width: expression(document.getElementById(&quot;tbl-container&quot;).width - 20);">
            <thead>
                <tr class="GridHeading" style="top: expression(document.getElementById(&quot;tbl-container&quot;).scrollTop); position:relative;">
                    <th style="width:1%;  padding:2px; border:none" class="GridHeadingCell">&nbsp;</th>
                    <th style="width:70%; padding:2px" class="GridHeadingCell">Description</th>
                    <th style="width:1%;  padding:2px" class="GridHeadingCell">&nbsp;</th>
                    <th style="width:1%;  padding:2px" class="GridHeadingCell">NSV</th>
                    <th style="width:1%;  padding:2px" class="GridHeadingCell">Ward</th>
                    <th style="width:1%;  padding:2px" class="GridHeadingCell">Cons</th>
                    <th style="width:1%;  padding:2px" class="GridHeadingCell">By</th>
                    <th style="width:1%;  padding:2px" class="GridHeadingCell">Site</th>
                    <th style="width:1%;  padding:2px" class="GridHeadingCell">Dispensed</th>
                    <th style="width:10%; padding:2px" class="GridHeadingCell">Qty</th>
                    <th style="width:1%;  padding:2px" class="GridHeadingCell">Start</th>
                    <th style="width:1%;  padding:2px" class="GridHeadingCell">Stop</th>
                    <th style="width:1%;  padding:2px" class="GridHeadingCell">Id</th>
                    <th style="width:1%;  padding:2px" class="GridHeadingCell">&nbsp;</th>
                    <th style="width:1%; padding:2px" class='GridHeadingCell'>POM</th>
<%  
    if (this.viewSettings.RepeatDispensing)
    {
%>
                    <th style="width:1%; padding:2px" class='GridHeadingCell'>Rpt</th>
<%  } %>
<%  
    if (this.viewSettings.PSO)
    {
%>
                    <th style="width:1%; padding:2px" class='GridHeadingCell'>PSO</th>
<%  } %>

                </tr>
            </thead>
		    <tbody id="tbdy" onclick="grid_onclick()" onkeydown="grid_onkeydown()" onselectstart="return false;">
<%=  application_DispensingPMR_ICW_DispensingPMR.RefreshGrid(this.sessionID, this.episodeID, this.viewSettings) %>
            </tbody>
        </table>
        </div>
    </div>
    </form>

    <xml id="xmlItem"></xml>
    <xml id="xmlType"></xml>
    <xml id="xmlStatusNoteFilter" runat="server"><%=strStatusNoteFilter_XML%></xml>
</body>
</html>
