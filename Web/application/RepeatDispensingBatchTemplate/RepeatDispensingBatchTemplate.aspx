<%@ Page Language="C#" AutoEventWireup="true" CodeFile="RepeatDispensingBatchTemplate.aspx.cs" Inherits="application_RepeatDispensingBatchTemplate_RepeatDispensingBatchTemplate" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<!-- 02Apr12 AJK 30988 Major code rework of all UI slot/length related logic -->
<!-- 11Sep12 AJK 43558 PageLoad and PageLoadAndPostBack: Fence posted JVM specific operations -->
<!-- 26Mar13 TH  (orig for 10.08.01 (05Mar13) 57518 Added getDaysBetweenDates() as replacement for DateDiffDays. This accounts for daylight saving changes -->

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <script language="javascript" src="../sharedscripts/icwfunctions.js"></script>
    <script type="text/javascript" src="../sharedscripts/icw.js"></script>    
    <script type="text/javascript" src="../sharedscripts/DateLibs.js"></script>
    <script type="text/javascript" src="../sharedscripts/Controls.js"></script>
    <script type="text/javascript" src="../sharedscripts/icwfunctions.js"></script>
    <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"></script>
	<script type="text/javascript" src="../sharedscripts/lib/json2.js"></script>
	<script type="text/javascript" src="../pharmacysharedscripts/pharmacyscript.js"></script>
    <title></title>
    <script type="text/javascript">

        var chkBatchBreakfast;
        var chkBatchLunch;
        var chkBatchTea;
        var chkBatchNight;
        var chkStartBreakfast;
        var chkStartLunch;
        var chkStartTea;
        var chkStartNight;
        var chkEndBreakfast;
        var chkEndLunch;
        var chkEndTea;
        var chkEndNight;
        var txtStartDate;
        var txtBatchDays;
        var lblSlotsNumber;
        var txtEndDate;
        var doseSlot1 = new Date();
        var doseSlot2 = new Date();
        var doseSlot3 = new Date();
        var doseSlot4 = new Date();
        var mode;
        var slotsPerDay;

        function LocationLookup() {
            var sessionId = <%=_SessionID %>;
//            var strXML = window.showModalDialog("../routine/RoutineLookupWrapper.aspx?SessionID=" + sessionId + "&RoutineName=pWardLookupList", undefined, "center:yes;status:no;dialogWidth:900px;dialogHeight:480px");
//            var newVal = "";
//            if ((strXML != undefined) && (strXML != false))
//            {
//                var xmlLookup = new ActiveXObject("Microsoft.XMLDOM");
//                xmlLookup.loadXML(strXML);
//                var xmlNode = xmlLookup.selectSingleNode("*");
//                if (typeof (xmlNode) != "undefined") {
//                    document.getElementById('txtLocation').value = xmlNode.attributes.getNamedItem("detail").nodeValue;
//                    document.getElementById('hdnLocationID').value = xmlNode.attributes.getNamedItem("dbid").nodeValue;
//                }
//            }

            var strURLParameters = '';
            strURLParameters += '?SessionID=' + sessionId;
            strURLParameters += '&Title=Select Ward';
            strURLParameters += '&sp=pWardLookupForPharmacy';
            strURLParameters += '&Parms=';
            strURLParameters += '&SearchType=Basic';
            strURLParameters += '&Columns=Description,98';
            strURLParameters += '&BasicSearchColumns=0';
			strURLParameters += '&Info=Select a ward';
            var result = window.showModalDialog('../pharmacysharedscripts/PharmacyLookupList.aspx' + strURLParameters, '', 'status:off; center:Yes;');
            if (result == 'logoutFromActivityTimeout') {
                window.returnValue = 'logoutFromActivityTimeout';
                result = null;
                window.close();
                window.parent.close();
                window.parent.ICWWindow().Exit();
            }

            if (result != undefined)
            {
				var params = { sessionId: sessionId, locationId: parseInt(result) };
                document.getElementById('txtLocation').value   = PostServerMessage('RepeatDispensingBatchTemplate.aspx/GetWardName', JSON.stringify(params)).d;
                document.getElementById('hdnLocationID').value = result;
            }
        }

        function LocationClear() {
            document.getElementById('txtLocation').value = "";
            document.getElementById('hdnLocationID').value = "";
        }  

        function KeyPressed(event) // Called whenever a keypress event is fired, assigned to body element
        {
            event = event || window.event; // Capture browser or window event (such as tab in IE)
            if (event.keyCode == 27) // ESC
            {
                document.getElementById('btnCancel').click();
            }
            else if (event.altKey && event.keyCode == 83)//Alt + S
            {
                document.getElementById('btnSave').click();
            }
            else if (event.altKey && event.keyCode == 65) //Alt + A
            {
                document.getElementById('btnSaveAs').click();
            }
            else if (event.altKey && event.keyCode == 76) // Alt + L
            {
                document.getElementById('btnLocationLookup').click();
            }
            else if (event.altKey && event.keyCode == 67) // Alt + C
            {
                document.getElementById('btnClearLocation').click();
            }
        }
     
        function EndRequest()
        {
            PageLoadAndPostback();
        }
        
        function PageLoadAndPostback()
        {
            mode = document.getElementById('hdnMode').value;
            if (mode == 'Batch' && document.getElementById('chkJVM') != null &&  document.getElementById('chkJVM').checked)
            {
                chkBatchBreakfast = document.getElementById('chkBatchBreakfast');
                chkBatchLunch = document.getElementById('chkBatchLunch');
                chkBatchTea = document.getElementById('chkBatchTea');
                chkBatchNight = document.getElementById('chkBatchNight');
                chkStartBreakfast = document.getElementById('chkFromBreakfast');
                chkStartLunch = document.getElementById('chkFromLunch');
                chkStartTea = document.getElementById('chkFromTea');
                chkStartNight = document.getElementById('chkFromNight');
                chkEndBreakfast = document.getElementById('chkToBreakfast');
                chkEndLunch = document.getElementById('chkToLunch');
                chkEndTea = document.getElementById('chkToTea');
                chkEndNight = document.getElementById('chkToNight');
                txtStartDate = document.getElementById('txtFromDate');
                txtBatchDays = document.getElementById('txtBatchDays');
                lblSlotsNumber = document.getElementById('lblSlotsNumber');
                txtEndDate = document.getElementById('txtTo');

                doseSlot1.setHours(parseInt(document.getElementById('hdnDoseSlot1').value.substring(0,2),10));
                doseSlot1.setMinutes(parseInt(document.getElementById('hdnDoseSlot1').value.substring(3,5),10));
                doseSlot2.setHours(parseInt(document.getElementById('hdnDoseSlot2').value.substring(0,2),10));
                doseSlot2.setMinutes(parseInt(document.getElementById('hdnDoseSlot2').value.substring(3,5),10));
                doseSlot3.setHours(parseInt(document.getElementById('hdnDoseSlot3').value.substring(0,2),10));
                doseSlot3.setMinutes(parseInt(document.getElementById('hdnDoseSlot3').value.substring(3,5),10));
                doseSlot4.setHours(parseInt(document.getElementById('hdnDoseSlot4').value.substring(0,2),10));
                doseSlot4.setMinutes(parseInt(document.getElementById('hdnDoseSlot4').value.substring(3,5),10));

                // Sort visibility out which isn't being read properly from the server side setting
                if (document.getElementById('hdnFBV').value.length > 0)
                {
                    chkStartBreakfast.style.visibility = document.getElementById('hdnFBV').value;
                }
                if (document.getElementById('hdnFLV').value.length > 0)
                {
                    chkStartLunch.style.visibility = document.getElementById('hdnFLV').value;
                }
                if (document.getElementById('hdnFTV').value.length > 0)
                {
                    chkStartTea.style.visibility = document.getElementById('hdnFTV').value;
                }
                if (document.getElementById('hdnFNV').value.length > 0)
                {
                    chkStartNight.style.visibility = document.getElementById('hdnFNV').value;
                }
                if (document.getElementById('hdnTBV').value.length > 0)
                {
                    chkEndBreakfast.style.visibility = document.getElementById('hdnTBV').value;
                }
                if (document.getElementById('hdnTLV').value.length > 0)
                {
                    chkEndLunch.style.visibility = document.getElementById('hdnTLV').value;
                }
                if (document.getElementById('hdnTTV').value.length > 0)
                {
                    chkEndTea.style.visibility = document.getElementById('hdnTTV').value;
                }
                if (document.getElementById('hdnTNV').value.length > 0)
                {
                    chkEndNight.style.visibility = document.getElementById('hdnTNV').value;
                }   
                SetBatchLength(); // 11Sep12 AJK 43558 Moved batch length calc
            }
        }
        
        function PageLoad()
        {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest  (EndRequest);
            PageLoadAndPostback();
            if (mode == 'Batch' && document.getElementById('chkJVM') != null &&  document.getElementById('chkJVM').checked) // 11Sep12 AJK 43558 Only perform these ops for JVM batches
            {
                //03Apr13 AJK 60503 Removed as this is being done server side
//                chkStartBreakfast.style.visibility = 'visible';
//                chkStartLunch.style.visibility = 'visible';
//                chkStartTea.style.visibility = 'visible';
//                chkStartNight.style.visibility = 'visible';
//                chkEndBreakfast.style.visibility = 'visible';
//                chkEndLunch.style.visibility = 'visible';
//                chkEndTea.style.visibility = 'visible';
//                chkEndNight.style.visibility = 'visible';                
                MonthView_Selected('');
            }
        }
        
        function UKToUniversalDate(ukDate)
        {
            var univDate = new Date(parseInt(ukDate.toString().substring(6,10),10), parseInt(ukDate.substring(3,5),10) - 1, parseInt(ukDate.substring(0,2),10));
            return univDate;
        }
        
        function chkBatchBreakfast_Click()
        {
            if (chkBatchBreakfast.checked) // Slot is being enabled
            {
                // Enable end slot if start and end date different
                if (txtStartDate.value != txtEndDate.value)
                {
                    chkEndBreakfast.style.visibility = 'visible';
                    document.getElementById('hdnTBV').value = 'visible';
                }
                chkEndBreakfast.checked = true; // Always ticked as there must be a later slot on the end date ticked

                // Only enable the start slot if the day or time is greater than now
                var today = new Date();
                var fromDate = new Date(UKToUniversalDate(txtStartDate.value));
                //if (DateDiffDays(today, fromDate) > 0 || today <= doseSlot1)  14Mar15 XN 147943 daylight savings fix
                if (getDaysBetweenDates(today, fromDate) > 0 || today <= doseSlot1)
                {
                    chkStartBreakfast.style.visibility = 'visible';
                    document.getElementById('hdnFBV').value = 'visible';                    
                    chkStartBreakfast.checked = false; // Never ticked as first available slot and was not previously available
                }
            }
            else // Slot is being disabled
            {
                // Never let the last available slot be unticked
                if (!chkBatchLunch.checked && !chkBatchTea.checked && !chkBatchNight.checked)
                {
                    // Undo the tick action
                    alert('A batch must have at least one available slot');
                    chkBatchBreakfast.checked = true;
                }
                else
                {
                    chkStartBreakfast.style.visibility = 'hidden'; //There will always be another start slot ticked
                    document.getElementById('hdnFBV').value = 'hidden';
                    // Check end slot as this may have been the last ticked slot, if so select the next
                    if ((chkEndLunch.style.visibility == 'hidden' || !chkEndLunch.checked) && (chkEndTea.style.visibility == 'hidden' || !chkEndTea.checked) && (chkEndNight.style.visibility == 'hidden' || !chkEndNight.checked))
                    {
                        // No other end slots ticked, so tick first available
                        if (chkEndLunch.style.visibility == 'visible')
                        {
                            chkEndLunch.checked = true;
                        }
                        else if (chkEndTea.style.visibility == 'visible')
                        {
                            chkEndTea.checked = true;
                        }
                        else if (chkEndNight.style.visibility == 'visible')
                        {
                            chkEndNight.checked = true;
                        }
                    }
                    chkStartBreakfast.style.visibility = 'hidden'; // Hide the start breakfast slot
                    document.getElementById('hdnFBV').value = 'hidden';
                    chkEndBreakfast.style.visibility = 'hidden'; // Hide the end breakfast slot
                    document.getElementById('hdnTBV').value = 'hidden';
                }
            }
            SetBatchLength();
            __doPostBack('upUpdatePanelForForm', 'CheckManual'); // Set's the manual tickbox
        }
        
        function chkFromBreakfast_Click()
        {
            if (chkStartBreakfast.checked)
            {
                // Slot has been selected, select all other slots which are later
                chkStartLunch.checked = true;
                chkStartTea.checked = true;
                chkStartNight.checked = true;
            }
            else
            {
                // If it was the only ticked slot, don't allow it
                if ((chkStartLunch.style.visibility == 'hidden' || !chkStartLunch.checked) && (chkStartTea.style.visibility == 'hidden' || !chkStartTea.checked) && (chkStartNight.style.visibility == 'hidden' || !chkStartNight.checked))
                {
                    chkStartBreakfast.checked = true;
                }
            }
            SetBatchLength();
        }
        
        function chkFromLunch_Click()
        {
            if (chkStartLunch.checked)
            {
                // Slot has been selected, select all other slots which are later
                chkStartTea.checked = true;
                chkStartNight.checked = true;
            }
            else
            {
                // No newer slot available, don't allow it
                if (chkStartTea.style.visibility == 'hidden' && chkStartNight.style.visibility == 'hidden')
                {
                    chkStartBreakfast.checked = false;
                    chkStartLunch.checked = true;
                    chkStartTea.checked = true;
                    chkStartNight.checked = true;
                }
                else
                {
                    // Untick breakfast
                    chkStartBreakfast.checked = false;
                }
            }
            SetBatchLength();
        }
        
        function chkFromNight_Click()
        {
            if (!chkStartNight.checked)
            {
                chkStartNight.checked = true;
                // Untick breakfast, lunch and tea
                chkStartBreakfast.checked = false;
                chkStartLunch.checked = false;
                chkStartTea.checked = false;
            }
            SetBatchLength();
        }
        
        function chkFromTea_Click()
        {
            if (chkStartTea.checked)
            {
                // Slot has been selected, select all other slots which are later
                chkStartNight.checked = true;
            }
            else
            {
                // If it was the only ticked slot, don't allow it
                if (chkStartNight.style.visibility == 'hidden')
                {
                    chkStartBreakfast.checked = false;
                    chkStartLunch.checked = false;
                    chkStartTea.checked = true;
                    chkStartNight.checked = true;
                }
                else
                {
                    // Untick breakfast and lunch
                    chkStartBreakfast.checked = false;
                    chkStartLunch.checked = false;
                }
            }
            SetBatchLength();
        }
        
        function chkBatchLunch_Click()
        {
            if (chkBatchLunch.checked) // Slot is being enabled
            {
                // Enable end slot
                if (txtStartDate.value != txtEndDate.value)
                {
                    chkEndLunch.style.visibility = 'visible';
                    document.getElementById('hdnTLV').value = 'visible';
                }
                // If end tea or night is selected, then select lunch too
                if ((chkEndTea.style.visibility == 'visible' && chkEndTea.checked) || (chkEndNight.style.visibility == 'visible' && chkEndNight.checked))
                {
                    chkEndLunch.checked = true;
                }
                else
                {
                    chkEndLunch.checked = false;
                }

                // Only enable the start slot if the day or time is greater than now
                var today = new Date();
                var fromDate = new Date(UKToUniversalDate(txtStartDate.value));
                //if (DateDiffDays(today, fromDate) > 0 || today <= doseSlot2) 14Mar15 XN 147943 daylight savings fix
                if (getDaysBetweenDates(today, fromDate) > 0 || today <= doseSlot2)
                {
                    chkStartLunch.style.visibility = 'visible';
                    document.getElementById('hdnFLV').value = 'visible';
                    // If start breakfast is selected, select lunch too
                    if (chkStartBreakfast.style.visibility == 'visible' && chkStartBreakfast.checked)
                    {
                        chkStartLunch.checked = true;
                    }
                    else
                    {
                        chkStartLunch.checked = false;
                    }
                }
            }
            else // Slot is being disabled
            {
                // Never let the last available slot be unticked
                if (!chkBatchBreakfast.checked && !chkBatchTea.checked && !chkBatchNight.checked)
                {
                    // Undo the tick action
                    alert('A batch must have at least one available slot');
                    chkBatchLunch.checked = true;
                }
                else
                {
                    // Check if lunch was the last ticked start slot, if so, tick the latest remaining available or we'll need to move day
                    if ((chkStartBreakfast.style.visibility == 'hidden' || !chkStartBreakfast.checked) && (chkStartTea.style.visibility == 'hidden' || !chkStartTea.checked) && (chkStartNight.style.visibility == 'hidden' || !chkStartNight.checked))
                    {
                        if (chkStartBreakfast.style.visibility == 'hidden') // If there are not slots ticked, lunch has been unticked and breakfast is invisible, this means start date is today and doseslot1 is past
                        {
                            // We need to move start date to tomorrow and tick all available
                            alert('There are no available slots for today. Resetting start date to tomorrow.');
                            var startDate = new Date(UKToUniversalDate(txtStartDate.value));
                            startDate.setDate(UKToUniversalDate(txtStartDate.value).getDate() + 1);
                            txtStartDate.value = String.format('{0:dd/MM/yyyy}', startDate);
                            // Make all slots visible as per batch slot settings as we're not on today now, tick all visible
                            if (chkBatchBreakfast.checked)
                            {
                                chkStartBreakfast.style.visibility = 'visible';
                                document.getElementById('hdnFBV').value = 'visible';
                                chkStartBreakfast.checked = true;
                                chkStartLunch.checked = true;
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            if (chkBatchLunch.checked)
                            {
                                chkStartLunch.style.visibility = 'visible';
                                document.getElementById('hdnFLV').value = 'visible';
                                chkStartLunch.checked = true;
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            if (chkBatchTea.checked)
                            {
                                chkStartTea.style.visibility = 'visible';
                                document.getElementById('hdnFTV').value = 'visible';
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            if (chkBatchNight.checked)
                            {
                                chkStartNight.style.visibility = 'visible';
                                document.getElementById('hdnFNV').value = 'visible';
                                chkStartNight.checked = true;
                            }
                        }
                        else
                        {
                            // Breakfast is available, tick that
                            chkStartBreakfast.checked = true;
                            chkStartLunch.checked = true;
                            chkStartTea.checked = true;
                            chkStartNight.checked = true;
                        }
                    }
                    // Check end slot as this may have been the last ticked slot, if so select the next
                    if ((chkEndBreakfast.style.visibility == 'hidden') && (chkEndTea.style.visibility == 'hidden' || !chkEndTea.checked) && (chkEndNight.style.visibility == 'hidden' || !chkEndNight.checked))
                    {
                        // No other end slots ticked, so tick first available, which can't be breakfast
                        if (chkEndTea.style.visibility == 'visible')
                        {
                            chkEndTea.checked = true;
                        }
                        else if (chkEndNight.style.visibility == 'visible')
                        {
                            chkEndNight.checked = true;
                        }
                    }
                    chkStartLunch.style.visibility = 'hidden'; // Hide the start lunch slot
                    document.getElementById('hdnFLV').value = 'hidden';
                    chkEndLunch.style.visibility = 'hidden'; // Hide the end lunch slot
                    document.getElementById('hdnTLV').value = 'hidden';
                }
            }
            SetBatchLength();
            __doPostBack('upUpdatePanelForForm', 'CheckManual'); // Set's the manual tickbox
        }
        
        function chkBatchNight_Click()
        {
            if (chkBatchNight.checked) // Slot is being enabled
            {
                // Enable end slot
                if (txtStartDate.value != txtEndDate.value)
                {
                    chkEndNight.style.visibility = 'visible';
                    document.getElementById('hdnTNV').value = 'visible';
                }
                
                chkEndNight.checked = false; // Always unticked as there has to be an earlier end slot ticked already marking the end of the batch

                // Only enable the start slot if the day or time is greater than now
                var today = new Date();
                var fromDate = new Date(UKToUniversalDate(txtStartDate.value));
                // Has to always be true as we must always have an earlier dose slot to get here
//                if (DateDiffDays(today, fromDate) > 0 || today <= doseSlot4)
//                {
//                    chkStartNight.style.visibility = 'visible';
//                    document.getElementById('hdnFNV').value = 'visible';
//                    // If start breakfast, lunch or tea is selected, select night too, this has to be the case
////                    if ((chkStartBreakfast.style.visibility == 'visible' && chkStartBreakfast.checked) || (chkStartLunch.style.visibility == 'visible' && chkStartLunch.checked) || (chkStartTea.style.visibility == 'visible' && chkStartTea.checked))
////                    {
////                        chkStartNight.checked = true;
////                    }          
//                }
                chkStartNight.style.visibility = 'visible';
                document.getElementById('hdnFNV').value = 'visible';
                chkStartNight.checked = true;          
            }
            else // Slot is being disabled
            {
                // Never let the last available slot be unticked
                if (!chkBatchBreakfast.checked && !chkBatchLunch.checked && !chkBatchTea.checked)
                {
                    // Undo the tick action
                    alert('A batch must have at least one available slot');
                    chkBatchNight.checked = true;
                }
                else
                {
                    // Check if night was the last ticked start slot, if so, tick the latest remaining available or we'll need to move day
                    if ((chkStartBreakfast.style.visibility == 'hidden' || !chkStartBreakfast.checked) && (chkStartLunch.style.visibility == 'hidden' || !chkStartLunch.checked) && (chkStartTea.style.visibility == 'hidden' || !chkStartTea.checked))
                    {
                        if (chkStartBreakfast.style.visibility == 'hidden' && chkStartLunch.style.visibility == 'hidden' && chkStartTea.style.visibility == 'hidden') // If there are not slots ticked, tea has been unticked and breakfast, lunch and tea are invisible, this means start date is today and doseslot3 is past
                        {
                            // We need to move start date to tomorrow and tick breakfast all available
                            alert('There are no available slots for today. Resetting start date to tomorrow.');
                            var startDate = new Date(UKToUniversalDate(txtStartDate.value));
                            startDate.setDate(UKToUniversalDate(txtStartDate.value).getDate() + 1);
                            txtStartDate.value = String.format('{0:dd/MM/yyyy}', startDate);
                            // Make all slots visible as per batch slot settings as we're not on today now, tick all visible
                            if (chkBatchBreakfast.checked)
                            {
                                chkStartBreakfast.style.visibility = 'visible';
                                document.getElementById('hdnFBV').value = 'visible';
                                chkStartBreakfast.checked = true;
                                chkStartLunch.checked = true;
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            if (chkBatchLunch.checked)
                            {
                                chkStartLunch.style.visibility = 'visible';
                                document.getElementById('hdnFLV').value = 'visible';
                                chkStartLunch.checked = true;
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            if (chkBatchTea.checked)
                            {
                                chkStartTea.style.visibility = 'visible';
                                document.getElementById('hdnFTV').value = 'visible';
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            if (chkBatchNight.checked)
                            {
                                chkStartNight.style.visibility = 'visible';
                                document.getElementById('hdnFNV').value = 'visible';
                                chkStartNight.checked = true;
                            }
                        }
                        else
                        {
                            // Breakfast, lunch or tea are available, tick latest
                            if (chkStartTea.style.visibility == 'visible')
                            {
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            else if (chkStartLunch.style.visibility == 'visible')
                            {
                                // Lunch is the latest visible
                                chkStartLunch.checked = true;
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            else
                            {
                                // Breakfast is visible
                                chkStartBreakfast.checked = true;
                                chkStartLunch.checked = true;
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                        }
                    }
                    chkStartNight.style.visibility = 'hidden'; // Hide the start Night slot
                    document.getElementById('hdnFNV').value = 'hidden';
                    chkEndNight.style.visibility = 'hidden'; // Hide the end Night slot
                    document.getElementById('hdnTNV').value = 'hidden';
                }
            }
            SetBatchLength();
            __doPostBack('upUpdatePanelForForm', 'CheckManual'); // Set's the manual tickbox
        }

        function chkBatchTea_Click()
        {
            if (chkBatchTea.checked) // Slot is being enabled
            {
                // Enable end slot
                if (txtStartDate.value != txtEndDate.value)
                {
                    chkEndTea.style.visibility = 'visible';
                    document.getElementById('hdnTTV').value = 'visible';
                }
                // If end night is selected, then select tea too
                if (chkEndNight.style.visibility == 'visible' && chkEndNight.checked)
                {
                    chkEndTea.checked = true;
                }
                else
                {
                    chkEndTea.checked = false;
                }

                // Only enable the start slot if the day or time is greater than now
                var today = new Date();
                var fromDate = new Date(UKToUniversalDate(txtStartDate.value));
                //if (DateDiffDays(today, fromDate) > 0 || today <= doseSlot3)  14Mar15 XN 147943 daylight savings fix
                if (getDaysBetweenDates(today, fromDate) > 0 || today <= doseSlot3)
                {
                    chkStartTea.style.visibility = 'visible';
                    document.getElementById('hdnFTV').value = 'visible';
                    // If start breakfast or lunch is selected, select tea too
                    if ((chkStartBreakfast.style.visibility == 'visible' && chkStartBreakfast.checked) || (chkStartLunch.style.visibility == 'visible' && chkStartLunch.checked))
                    {
                        chkStartTea.checked = true;
                    }
                    else
                    {
                        chkStartTea.checked = false;
                    }
                }
            }
            else // Slot is being disabled
            {
                // Never let the last available slot be unticked
                if (!chkBatchBreakfast.checked && !chkBatchLunch.checked && !chkBatchNight.checked)
                {
                    // Undo the tick action
                    alert('A batch must have at least one available slot');
                    chkBatchTea.checked = true;
                }
                else
                {
                    // Check if tea was the last ticked start slot, if so, tick the latest remaining available, which has to be breakfast or lunch or we'll need to move day
                    if ((chkStartBreakfast.style.visibility == 'hidden' || !chkStartBreakfast.checked) && (chkStartLunch.style.visibility == 'hidden' || !chkStartLunch.checked) && (chkStartNight.style.visibility == 'hidden' || !chkStartNight.checked))
                    {
                        if (chkStartBreakfast.style.visibility == 'hidden' && chkStartLunch.style.visibility == 'hidden') // If there are not slots ticked, tea has been unticked and breakfast & lunch are invisible, this means start date is today and doseslot2 is past
                        {
                            // We need to move start date to tomorrow and tick all available
                            alert('There are no available slots for today. Resetting start date to tomorrow.');
                            var startDate = new Date(UKToUniversalDate(txtStartDate.value));
                            startDate.setDate(UKToUniversalDate(txtStartDate.value).getDate() + 1);
                            txtStartDate.value = String.format('{0:dd/MM/yyyy}', startDate);
                            // Make all slots visible as per batch slot settings as we're not on today now, tick all visible
                            if (chkBatchBreakfast.checked)
                            {
                                chkStartBreakfast.style.visibility = 'visible';
                                document.getElementById('hdnFBV').value = 'visible';
                                chkStartBreakfast.checked = true;
                                chkStartLunch.checked = true;
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            if (chkBatchLunch.checked)
                            {
                                chkStartLunch.style.visibility = 'visible';
                                document.getElementById('hdnFLV').value = 'visible';
                                chkStartLunch.checked = true;
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            if (chkBatchTea.checked)
                            {
                                chkStartTea.style.visibility = 'visible';
                                document.getElementById('hdnFTV').value = 'visible';
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            if (chkBatchNight.checked)
                            {
                                chkStartNight.style.visibility = 'visible';
                                document.getElementById('hdnFNV').value = 'visible';
                                chkStartNight.checked = true;
                            }
                        }
                        else
                        {
                            // Breakfast or lunch are available, tick latest
                            if (chkStartLunch.style.visibility == 'visible')
                            {
                                chkStartLunch.checked = true;
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                            else
                            {
                                // Breakfast is visible
                                chkStartBreakfast.checked = true;
                                chkStartLunch.checked = true;
                                chkStartTea.checked = true;
                                chkStartNight.checked = true;
                            }
                        }
                    }
                    // Check end slot as this may have been the last ticked slot, if so select the next
                    if (chkEndBreakfast.style.visibility == 'hidden' && chkEndLunch.style.visibility == 'hidden' && !chkEndNight.checked)
                    {
                        // No other end slots ticked, so tick first available, which has to be night
                        chkEndNight.checked = true;
                    }
                    chkStartTea.style.visibility = 'hidden'; // Hide the start lunch slot
                    document.getElementById('hdnFTV').value = 'hidden';
                    chkEndTea.style.visibility = 'hidden'; // Hide the end lunch slot
                    document.getElementById('hdnTTV').value = 'hidden';
                }
            }
            SetBatchLength();
            __doPostBack('upUpdatePanelForForm', 'CheckManual'); // Set's the manual tickbox
        }
        
        function GetSlotsPerDay()
        {
            var slotsPerDay = 0;
            if (chkBatchBreakfast.checked) slotsPerDay++;
            if (chkBatchLunch.checked) slotsPerDay++;
            if (chkBatchTea.checked) slotsPerDay++;
            if (chkBatchNight.checked) slotsPerDay++;
            return slotsPerDay;
        }

        
        function chkToBreakfast_Click()
        {
            if (!chkEndBreakfast.checked)
            {
                chkEndBreakfast.checked = true;
                chkEndLunch.checked = false;
                chkEndTea.checked = false;
                chkEndNight.checked = false;
            }
            SetBatchLength();
        }
        
        function chkToLunch_Click()
        {
            if (chkEndLunch.checked)
            {
                // Selected
                chkEndBreakfast.checked = true;
                chkEndTea.checked = false;
                chkEndNight.checked = false;
            }
            else
            {
                // Unticked
                // Check it wasn't the last selectable slot
                if (chkEndBreakfast.style.visibility == 'hidden')
                {
                    // No older slot so keep this selected and unselect all later
                    chkEndBreakfast.checked = true;
                    chkEndLunch.checked = true;
                    chkEndTea.checked = false;
                    chkEndNight.checked = false;
                }
                else
                {
                    // Old slot, should already be selected so just unselect later
                    chkEndTea.checked = false;
                    chkEndNight.checked = false;
                }
            }
            SetBatchLength();
        }
 
        function chkToTea_Click()
        {
            if (chkEndTea.checked)
            {
                // Selected
                chkEndBreakfast.checked = true;
                chkEndLunch.checked = true;
                chkEndNight.checked = false;
            }
            else
            {
                // Unticked
                // Check it wasn't the last selectable slot
                if (chkEndBreakfast.style.visibility == 'hidden' && chkEndLunch.style.visibility == 'hidden')
                {
                    // No older slot so keep this selected and unselect all later
                    chkEndBreakfast.checked = true;
                    chkEndLunch.checked = true;
                    chkEndTea.checked = true;
                    chkEndNight.checked = false;
                }
                else
                {
                    // Old slot, should already be selected so just unselect later
                    chkEndNight.checked = false;
                }
            }
            SetBatchLength();
        }
 
        function chkToNight_Click()
        {
            if (chkEndNight.checked)
            {
                // Selected
                chkEndBreakfast.checked = true;
                chkEndLunch.checked = true;
                chkEndTea.checked = true;
            }
            else
            {
                // Unticked
                // Check it wasn't the last selectable slot
                if (chkEndBreakfast.style.visibility == 'hidden' && chkEndLunch.style.visibility == 'hidden' && chkEndTea.style.visibility == 'hidden')
                {
                    // No older slot so keep this selected and unselect all later
                    chkEndBreakfast.checked = true;
                    chkEndLunch.checked = true;
                    chkEndTea.checked = true;
                    chkEndNight.checked = true;
                }
            }
            SetBatchLength();
        }
        
        function btnMinus_Click()
        {
            // We need some slots on the end day visible or else ignore the command
            if (chkEndNight.style.visibility == 'visible' || chkEndTea.style.visibility == 'visible' || chkEndLunch.style.visibility == 'visible' || chkEndBreakfast.style.visibility == 'visible')
            {
                // Untick the last used end day slot
                if (chkEndNight.style.visibility == 'visible' && chkEndNight.checked)
                {
                    chkEndNight.checked = false;
                }
                else if (chkEndTea.style.visibility == 'visible' && chkEndTea.checked)
                {
                    chkEndTea.checked = false;
                }
                else if (chkEndLunch.style.visibility == 'visible' && chkEndLunch.checked)
                {
                    chkEndLunch.checked = false;
                }
                else if (chkEndBreakfast.style.visibility == 'visible' && chkEndBreakfast.checked)
                {
                    chkEndBreakfast.checked = false;
                }
                
                // See if we've unticked the whole day
                if (!(chkEndBreakfast.style.visibility == 'visible' && chkEndBreakfast.checked) && !(chkEndLunch.style.visibility == 'visible' && chkEndLunch.checked) && !(chkEndTea.style.visibility == 'visible' && chkEndTea.checked) && !(chkEndNight.style.visibility == 'visible' && chkEndNight.checked))
                {
                    // We've unticked a whole day
                    // Get the current dates
                    var endDate = new Date(UKToUniversalDate(txtEndDate.value));
                    //endDate.setDate(UKToUniversalDate(txtEndDate.value).getDate());
                    var startDate = new Date(UKToUniversalDate(txtStartDate.value));
                    //startDate.setDate(UKToUniversalDate(txtStartDate.value).getDate());
                    endDate.setDate(endDate.getDate() - 1);
                    txtEndDate.value = String.format('{0:dd/MM/yyyy}', endDate);
                    //if (DateDiffDays(startDate, endDate) == 0) 14Mar15 XN 147943 daylight savings fix
                    if (getDaysBetweenDates(startDate, endDate) == 0)
                    {
                        // We've just removed the end date, so call show/hide and leave it at that
                        ShowHideEndDate();
                    }
                    else
                    {
                        chkEndBreakfast.checked = true;
                        chkEndLunch.checked = true;
                        chkEndTea.checked = true;
                        chkEndNight.checked = true;
                    }
                }
                SetBatchLength();
            }
        }
        
        function SetBatchLength()
        {
            var days = 0;
            var slotsPerDay = GetSlotsPerDay();
            
            // Get dates
            var endDate = new Date(UKToUniversalDate(txtEndDate.value));
            var startDate = new Date(UKToUniversalDate(txtStartDate.value));
            
            //days = DateDiffDays(startDate, endDate) - 1; 14Mar15 XN 147943 daylight savings fix
            days = getDaysBetweenDates(startDate, endDate) - 1;
            if (days < 0) days = 0; // Stops negative day count as this will never happen and will be handled by slot count
            
            // Get used slots on both start and end date
            var slotsUsed = 0;
            if (chkStartBreakfast.style.visibility == 'visible' && chkStartBreakfast.checked)
                slotsUsed++;
            if (chkStartLunch.style.visibility == 'visible' && chkStartLunch.checked)
                slotsUsed++;
            if (chkStartTea.style.visibility == 'visible' && chkStartTea.checked)
                slotsUsed++;
            if (chkStartNight.style.visibility == 'visible' && chkStartNight.checked)
                slotsUsed++;
            if (chkEndBreakfast.style.visibility == 'visible' && chkEndBreakfast.checked)
                slotsUsed++;
            if (chkEndLunch.style.visibility == 'visible' && chkEndLunch.checked)
                slotsUsed++;
            if (chkEndTea.style.visibility == 'visible' && chkEndTea.checked)
                slotsUsed++;
            if (chkEndNight.style.visibility == 'visible' && chkEndNight.checked)
                slotsUsed++;
                
            // We may have up to two days worth of slots used, and if so switch the value over to the day count
            if (slotsUsed >= slotsPerDay)
            {
                slotsUsed -= slotsPerDay
                days++
            }
            if (slotsUsed >= slotsPerDay)
            {
                slotsUsed -= slotsPerDay
                days++
            }
            
            // Days and slotsUsed should now be correct
            txtBatchDays.value = days.toString();
            lblSlotsNumber.innerText = slotsUsed.toString() + ' ';
        }
        
        function btnPlus_Click()
        {
            // Tick next available slot
            if (chkEndBreakfast.style.visibility == 'visible' && !chkEndBreakfast.checked)
            {   
                chkEndBreakfast.checked = true;
            }
            else if (chkEndLunch.style.visibility == 'visible' && !chkEndLunch.checked)
            {   
                chkEndLunch.checked = true;
            }
            else if (chkEndTea.style.visibility == 'visible' && !chkEndTea.checked)
            {   
                chkEndTea.checked = true;
            }
            else if (chkEndNight.style.visibility == 'visible' && !chkEndNight.checked)
            {   
                chkEndNight.checked = true;
            }
            else
            {
                // The day is full, need to move onto next
                var endDate = new Date(UKToUniversalDate(txtEndDate.value));
                endDate.setDate(UKToUniversalDate(txtEndDate.value).getDate() + 1);
                txtEndDate.value = String.format('{0:dd/MM/yyyy}', endDate);                
                ShowHideEndDate();
                if (chkEndBreakfast.style.visibility == 'visible')
                {
                    chkEndBreakfast.checked = true;
                    chkEndLunch.checked = false;
                    chkEndTea.checked = false;
                    chkEndNight.checked = false;
                }
                else if (chkEndLunch.style.visibility == 'visible')
                {
                    chkEndBreakfast.checked = true;
                    chkEndLunch.checked = true;
                    chkEndTea.checked = false;
                    chkEndNight.checked = false;
                }
                else if (chkEndTea.style.visibility == 'visible')
                {
                    chkEndBreakfast.checked = true;
                    chkEndLunch.checked = true;
                    chkEndTea.checked = true;
                    chkEndNight.checked = false;
                }
                else if (chkEndNight.style.visibility == 'visible')
                {
                    chkEndBreakfast.checked = true;
                    chkEndLunch.checked = true;
                    chkEndTea.checked = true;
                    chkEndNight.checked = true;
                }
            }
            
            SetBatchLength();
        }
        
        function txtBatchDays_KeyUp()
        {
            var oldString = "";
            var newString = "";
            oldString = txtBatchDays.value;
            for (var i = 0; i < oldString.length; i++)
            {
                if (oldString.charCodeAt(i) > 47 && oldString.charCodeAt(i) < 58)
                    newString += oldString.substring(i,i+1);
            }
            if (newString.length == 0)  //Treat as 1 day
                newString = '1';
            if (parseInt(newString,10) > 999)
                newString = '999';
            if (newString != oldString)
                txtBatchDays.value = newString;
            
            // Just call SetEndDate
            SetEndDate();
        }

        function imgCalendar_Click()
        {
            ShowMonthViewWithDate(txtStartDate, txtStartDate ,txtStartDate.value);
        }

// 14Mar15 XN 147943 Removed as does not work with daylight savings
//        function DateDiffDays(date1, date2)
//        {
//            var d1 = new Date(date1);
//            var d2 = new Date(date2);
//            d1.setHours(0);
//            d1.setMinutes(0);
//            d1.setSeconds(0);
//            d1.setMilliseconds(0);
//            d2.setHours(0);
//            d2.setMinutes(0);
//            d2.setSeconds(0);
//            d2.setMilliseconds(0);
//            var t2 = d2.getTime();
//            var t1 = d1.getTime();
//            return parseInt((t2-t1)/(24*3600*1000),10);
//        }

	//TFS 57518 05Mar13 TH Added. This accounts for daylight saving changes
	function getDaysBetweenDates(d0, d1) {

  		var msPerDay = 8.64e7;

  		// Copy dates so don't mess them up
  		var x0 = new Date(d0);
  		var x1 = new Date(d1);

  		// Set to noon - avoid DST errors
  		x0.setHours(12,0,0);
  		x1.setHours(12,0,0);

  		// Round to remove daylight saving errors
  		return Math.round( (x1 - x0) / msPerDay );
	}

        function MonthView_Selected(controlID)
        {
            var fromDate = UKToUniversalDate(txtStartDate.value);
            var today = new Date();
            
            // Is the date today?
            //if (DateDiffDays(today, fromDate) == 0)
	    if (getDaysBetweenDates(today, fromDate) == 0)
            {
                var slotsLeft = 4;
                var unticked = 0;

                // See how many slots we have available for today based on current time
                if (today > doseSlot1 || !chkBatchBreakfast.checked)
                    slotsLeft--;
                if (today > doseSlot2 || !chkBatchLunch.checked)
                    slotsLeft--;
                if (today > doseSlot3 || !chkBatchTea.checked)
                    slotsLeft--;
                if (today > doseSlot4 || !chkBatchNight.checked)
                    slotsLeft--;
                
                // See if we have slots left. If so, hide all unavailable, keep count of any we untick for length adjustment
                if (slotsLeft > 0)
                {
                    // See if the breakfast slot is in the past and unavailable
                    if (today > doseSlot1)
                    {
                        // Seee if we need to remove the selected slot from the batch in which case keep count to adjust length
                        if (chkStartBreakfast.style.visibility == 'visible' && chkStartBreakfast.checked)
                        {
                            unticked++;
                        }
                        chkStartBreakfast.checked = false;
                        chkStartBreakfast.style.visibility = 'hidden';
                        document.getElementById('hdnFBV').value = 'hidden';
                    }
                    else
                    {
                        if (chkBatchBreakfast.checked)
                        {
                            //Make slot visible
                            chkStartBreakfast.style.visibility = 'visible';
                            document.getElementById('hdnFBV').value = 'visible';
                        }
                    }

                    // See if the lunch slot is in the past and unavailable
                    if (today > doseSlot2)
                    {
                        // Seee if we need to remove the selected slot from the batch in which case keep count to adjust length
                        if (chkStartLunch.style.visibility == 'visible' && chkStartLunch.checked)
                        {
                            unticked++;
                        }
                        chkStartLunch.checked = false;
                        chkStartLunch.style.visibility = 'hidden';
                        document.getElementById('hdnFLV').value = 'hidden';
                    }
                    else
                    {
                        if (chkBatchLunch.checked)
                        {
                            chkStartLunch.style.visibility = 'visible';
                            document.getElementById('hdnFLV').value = 'visible';
                        }
                    }

                    // See if the tea slot is in the past and unavailable
                    if (today > doseSlot3)
                    {
                        // Seee if we need to remove the selected slot from the batch in which case keep count to adjust length
                        if (chkStartTea.style.visibility == 'visible' && chkStartTea.checked)
                        {
                            unticked++;
                        }
                        chkStartTea.checked = false;
                        chkStartTea.style.visibility = 'hidden';
                        document.getElementById('hdnFTV').value = 'hidden';
                    }
                    else
                    {
                        if (chkBatchTea.checked)
                        {
                            chkStartTea.style.visibility = 'visible';
                            document.getElementById('hdnFTV').value = 'visible';
                        }
                    }
                    
                    // See if night slot is in the past and unavailable
                    if (today > doseSlot4)
                    {
                        // Seee if we need to remove the selected slot from the batch in which case keep count to adjust length
                        if (chkStartNight.style.visibility == 'visible' && chkStartNight.checked)
                        {
                            unticked++;
                        }
                        chkStartNight.checked = false;
                        chkStartNight.style.visibility = 'hidden';
                        document.getElementById('hdnFNV').value = 'hidden';
                    }
                    else
                    {
                        if (chkBatchNight.checked)
                        {
                            chkStartNight.style.visibility = 'visible';
                            document.getElementById('hdnFNV').value = 'visible';
                        }
                    }
                    
                    // Checked to see if all start slots are unticked
                    if (!chkStartBreakfast.checked && !chkStartLunch.checked && !chkStartTea.checked && !chkStartNight.checked)
                    {
                        // we need to tick the last available slot and adjust the unticked count
                        if (!chkStartNight.checked)
                            chkStartNight.checked = true;
                        else if (!chkStartTea.checked)
                            chkStartTea.checked = true;
                        else if (!chkStartLunch.checked)
                            chkStartLunch.checked = true;
                        else
                            chkStartBreakfast.checked = true;
                        unticked--;
                    }
                    
                    // Check if we've unticked any slots
                    if (unticked > 0)
                    {
                        // As we've deducted, we need to adjust the lenght of the batch so that the SetEndDate is correct and does not shift with the unticks.
                        var slotsPerDay = GetSlotsPerDay();
                        var slots = parseInt(lblSlotsNumber.innerText,10);
                        var days = txtBatchDays.value;
                        
                        // See if we don't have enough slots to untick
                        if (slots < unticked)
                        {
                            // Now we need to break a day into slots to do our unticking
                            slots += slotsPerDay;
                            days--;
                        }
                        
                        // Remove remove the unticked count from the slots count
                        slots -= unticked;
                        
                        // Now set the UI elements to their ammended figures so they're right for the SetEndDate
                        txtBatchDays.value = days.toString();
                        lblSlotsNumber.innerText = slots.toString() + ' ';
                    }
                }
                else
                {
                    // There are no slots left for today, reset to tomorrow. No need to call function again as we've made no changes.
                    
                    //txtStartDate.value = String.format('{0:dd/MM/yyyy}', today.setDate(today.getDate() + 1));
                    var tomorrow = new Date(today);
                    tomorrow.setDate(tomorrow.getDate() + 1);
                    txtStartDate.value = String.format('{0:dd/MM/yyyy}', tomorrow);
                    alert('All available slots for today have passed. Resetting start date to tomorrow.');
                }    
            }
            //else if (DateDiffDays(today, fromDate) > 0)
            else if (getDaysBetweenDates(today, fromDate) > 0)
            {
                // Start date is in the future, make all available slots visible
                if (chkBatchBreakfast.checked)
                {
                    chkStartBreakfast.style.visibility = 'visible';
                    document.getElementById('hdnFBV').value = 'visible';
                }
                if (chkBatchLunch.checked)
                {
                    chkStartLunch.style.visibility = 'visible';
                    document.getElementById('hdnFLV').value = 'visible';
                }
                if (chkBatchTea.checked)
                {
                    chkStartTea.style.visibility = 'visible';
                    document.getElementById('hdnFTV').value = 'visible';
                }
                if (chkBatchNight.checked)
                {
                    chkStartNight.style.visibility = 'visible';
                    document.getElementById('hdnFNV').value = 'visible';
                }
            }
            
            
            //if (DateDiffDays(today, fromDate) < 0)
	    if (getDaysBetweenDates(today, fromDate) < 0)
            {
                // Past date selected, reset and call function again
                alert('You cannot select a date in the past. Resetting start date to today.');
                txtStartDate.value = String.format('{0:dd/MM/yyyy}', today);
                MonthView_Selected('');
            }
            else
            {
                // All updates should have been carried out correctly, so set the end date
                SetEndDate();
            }

        }
        
        function SetEndDate()
        {
            // Get stuff
            var slotsPerDay = GetSlotsPerDay();
            var slots = parseInt(lblSlotsNumber.innerText,10);
            var days = txtBatchDays.value;
            var startDate = new Date(UKToUniversalDate(txtStartDate.value));
            //startDate.setDate(UKToUniversalDate(txtStartDate.value).getDate());

            // See how many slots we've used on the start day
            var slotsUsed = 0;
            if (chkStartBreakfast.style.visibility == 'visible' && chkStartBreakfast.checked)
                slotsUsed++;
            if (chkStartLunch.style.visibility == 'visible' && chkStartLunch.checked)
                slotsUsed++;
            if (chkStartTea.style.visibility == 'visible' && chkStartTea.checked)
                slotsUsed++;
            if (chkStartNight.style.visibility == 'visible' && chkStartNight.checked)
                slotsUsed++;

            // Work out if the total length means we have exceeded the start date, in which case check the batch slots rather than end slots
            // Convert batch length to total slots
            var totalSlots = (parseInt(days,10) * slotsPerDay) + slots;
            if (totalSlots > slotsUsed)
            {
                // We'll need more than 1 day to cover these, which ShowHideEndDate will sort out, but we need to ensure the slot counting pretends these are visible if they're not yet
                if (chkBatchBreakfast.checked && chkEndBreakfast.checked)
                    slotsUsed++;
                if (chkBatchLunch.checked && chkEndLunch.checked)
                    slotsUsed++;
                if (chkBatchTea.checked && chkEndTea.checked)
                    slotsUsed++;
                if (chkBatchNight.checked && chkEndNight.checked)
                    slotsUsed++;
            }

            // Calculate how many days in between the start and end day
            if (slotsUsed > slots)
            {
                days--;
                slots += slotsPerDay;
            }
            if (slotsUsed > slots)
            {
                days--;
                slots += slotsPerDay;
            }
            slots -= slotsUsed; // should always be 0?
            
            // Now set the end date
            var endDate = new Date(startDate.toDateString());
            if (days > 0)
            {
                endDate.setDate(startDate.getDate() + parseInt(days,10) + 1);
            }
            else if (slotsUsed > slotsPerDay)
            {
                endDate.setDate(startDate.getDate() + 1);
            }
            else
            {
                endDate = startDate;
            }                
            
            txtEndDate.value = String.format('{0:dd/MM/yyyy}', endDate);
            
            ShowHideEndDate();
            
        }
        
        function ShowHideEndDate()
        {
            if (txtStartDate.value == txtEndDate.value)
            {
                // Start and end date are the same so hide end date
                chkEndBreakfast.style.visibility = 'hidden';
                document.getElementById('hdnTBV').value = 'hidden';
                chkEndLunch.style.visibility = 'hidden';
                document.getElementById('hdnTLV').value = 'hidden';
                chkEndTea.style.visibility = 'hidden';
                document.getElementById('hdnTTV').value = 'hidden';
                chkEndNight.style.visibility = 'hidden';
                document.getElementById('hdnTNV').value = 'hidden';
                
                // Always tick all boxes when hiding them
                chkEndBreakfast.checked = true;
                chkEndLunch.checked = true;
                chkEndTea.checked = true;
                chkEndNight.checked = true;
            }
            else
            {
                // Start and end date are different so display the end date
                if (chkBatchBreakfast.checked)
                {
                    chkEndBreakfast.style.visibility = 'visible';
                    document.getElementById('hdnTBV').value = 'visible';
                }
                if (chkBatchLunch.checked)
                {
                    chkEndLunch.style.visibility = 'visible';
                    document.getElementById('hdnTLV').value = 'visible';
                }
                if (chkBatchTea.checked)
                {
                    chkEndTea.style.visibility = 'visible';
                    document.getElementById('hdnTTV').value = 'visible';
                }
                if (chkBatchNight.checked)
                {
                    chkEndNight.style.visibility = 'visible';
                    document.getElementById('hdnTNV').value = 'visible';
                }
            }
        }
        
        
        

    </script>

<link href="../../style/application.css" rel="stylesheet" type="text/css" />
    <style type="text/css">
        .style1
        {
            width: 167px;
        }
        .style2
        {
            width: 477px;
        }
    </style>
    <style type="text/css">html, body{height:100%}</style>  <!-- Ensure page is full height of screen -->
</head>
<body onkeydown="KeyPressed(event)" onload="PageLoad()" >
    <form id="mainForm" runat="server" style="width: 100%">
        <asp:ScriptManager ID="ScriptManager1" runat=server EnablePageMethods=true></asp:ScriptManager>
        <asp:UpdatePanel ID="upUpdatePanelForForm" runat=server UpdateMode=Conditional>
            <ContentTemplate>
                <asp:HiddenField ID="hdnLocationID" runat="server" />
                <asp:HiddenField ID="hdnTemplateID" runat="server" />
                <asp:HiddenField ID="hdnDoseSlot1" runat="server" />
                <asp:HiddenField ID="hdnDoseSlot2" runat="server" />
                <asp:HiddenField ID="hdnDoseSlot3" runat="server" />
                <asp:HiddenField ID="hdnDoseSlot4" runat="server" />
                <asp:HiddenField ID="hdnMode" runat="server" />
                <asp:HiddenField ID="hdnFBV" runat="server" />
                <asp:HiddenField ID="hdnFLV" runat="server" />
                <asp:HiddenField ID="hdnFTV" runat="server" />
                <asp:HiddenField ID="hdnFNV" runat="server" />
                <asp:HiddenField ID="hdnTBV" runat="server" />
                <asp:HiddenField ID="hdnTLV" runat="server" />
                <asp:HiddenField ID="hdnTTV" runat="server" />
                <asp:HiddenField ID="hdnTNV" runat="server" />
                <%--<asp:HiddenField ID="hdnOldLength" runat="server" />
                <asp:HiddenField ID="hdnOldStartDate" runat="server" /> --%>
                
                <div style="height:435px; margin:5px;">
                    <div style="margin-bottom:5px;">
                        <asp:Label ID="lblDescription" runat="server" Text="Description" Width="65px"></asp:Label>
                        <asp:TextBox ID="txtDescription" runat="server" Width="610px" CssClass="MandatoryField" Font-Names="Arial Narrow" ></asp:TextBox><br />
                        <asp:CustomValidator ID="ValidatorDescription" runat="server" Display=Dynamic OnServerValidate="ValidateDescription"></asp:CustomValidator>
                    </div>
                    
                    <div>
                        <asp:Label ID="lblLocation" runat="server" Text="Location" Width="65px"></asp:Label>
                        <asp:TextBox ID="txtLocation" runat="server" Text="" Width="465px" CssClass="FieldDisabled" ></asp:TextBox>
                        <input id="btnLocationLookup" type="button" value="Lookup" onclick="Javascript:LocationLookup()" class="ICWButton" runat=server />
                        <input id="btnClearLocation" type=button value="Clear" onclick="Javascript:LocationClear()" class="ICWButton" runat=server /><br />
                        <asp:CustomValidator ID="ValidatorLocation" runat="server" Display=Dynamic OnServerValidate="ValidateLocation"></asp:CustomValidator>
                    </div>
                    
                    <br />

<%--  XN 09Jun11 F0119748 <tr>
                            <td colspan=3>
                                <asp:Label ID="lblTypes" runat="server" Text="Select one or more dispensing types"></asp:Label>&nbsp
                                <asp:CustomValidator ID="ValidatorTypes" runat="server" Display=Dynamic OnServerValidate="ValidateTypes"></asp:CustomValidator>
                            </td>
                        </tr>
                        <tr>
                            <td colspan=6>
                                <asp:CheckBox ID="chkInPatient" runat="server" Text="In-patient" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan=6>
                                <asp:CheckBox ID="chkOutPatient" runat="server" Text="Out-patient" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan=6>
                                <asp:CheckBox ID="chkDischarge" runat="server" Text="Discharge" />
                            </td>
                        </tr>
                        <tr>
                            <td colspan=6>
                                <asp:CheckBox ID="chkLeave" runat="server" Text="Leave" />
                            </td>
                        </tr>--%>
                        <table width="500px" cellspacing="0" style="margin-bottom:5px">
                        <tr>
                            <td width="150px">
                                <asp:Label ID="lblSelectPatients" runat="server" Text="Select patients by default" Width="150px"></asp:Label>
                            </td>
                            <td width="150px">
                                <asp:CheckBox ID="chkSelectPatients" runat="server" />
                            </td>
                            <td width="50px">
                                <asp:Label ID="lblJVM" runat="server" Text="Use JVM" ></asp:Label>
                            </td>
                            <td>
                                <asp:CheckBox ID="chkJVM" runat="server" oncheckedchanged="chkJVM_CheckedChanged" AutoPostBack=true Checked=false />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Label ID="lblBagLabels" runat="server" Text="Bag labels per patient"></asp:Label>
                            </td>
                            <td>
                                <asp:TextBox ID="txtBagLabels" runat="server" Width="43px" CssClass="MandatoryField" ></asp:TextBox>
                                <asp:CustomValidator ID="ValidatorBagLabels" runat="server" Display=Dynamic OnServerValidate="ValidateBagLabels"></asp:CustomValidator>
                            </td>
                            <td>
                                <asp:Label ID="lblInUse" runat="server" Text="In-use"></asp:Label>&nbsp;&nbsp;&nbsp;&nbsp;                              
                            </td>
                            <td>
                                <asp:CheckBox ID="chkInUse" runat="server" Text="" />
                            </td>
                        </tr>
                        <tr runat=server id="rowFactor">
                            <td>
                                <asp:Label ID="lblFactor" runat="server" Text="Manual supplier length multiplier" width="150px"></asp:Label>
                            </td>
                            <td colspan=3>
                                <asp:DropDownList ID="ddlFactor" runat="server">
                                    <asp:ListItem Selected=True>1</asp:ListItem>
                                    <asp:ListItem>2</asp:ListItem>
                                    <asp:ListItem>3</asp:ListItem>
                                </asp:DropDownList>
                            </td>
                        </tr>
                    </table>
                    <div runat=server id="divJVM" visible=false>
                        <hr />
                        <table runat="server" id="tblJVM">
                            <tr runat="server" id="rowDefaultStartTomorrow">
                                <td class="style1">
                                    <asp:Label ID="lblDefailtStartTomorrow" runat="server" Text="Default Start date to tomorrow"></asp:Label>
                                </td>
                                <td class="style2">
                                    <asp:CheckBox ID="chkDefaultStartTomorrow" runat="server" />
                                </td>
                            </tr>
                            <tr runat="server" id="rowDuration">
                                <td class="style1">
                                    <asp:Label ID="lblDuration" runat="server" Text="Enter duration"></asp:Label>
                                </td>
                                <td class="style2">
                                    <asp:TextBox ID="txtDuration" runat="server" Width="36px" CssClass="MandatoryField"></asp:TextBox>
                                    <asp:Label ID="lblDays" runat="server" Text="days"></asp:Label>
                                    <asp:CustomValidator ID="ValidatorDuration" runat="server" Display=Dynamic OnServerValidate="ValidateDuration"></asp:CustomValidator>
                                </td>
                            </tr>
                            <tr runat="server" id="rowTemplateBreakfast">
                                <td class="style1">
                                    <asp:CustomValidator ID="ValidatorSlots" runat="server" Display=Dynamic OnServerValidate="ValidateSlots"></asp:CustomValidator>
                                </td>
                                <td class="style2">
                                    <asp:CheckBox ID="chkBreakfast" runat="server" Text="B'fast" OnCheckedChanged="chkSlot_CheckedChanged" AutoPostBack=true  />
                                </td>
                            </tr>
                            <tr runat="server" id="rowTemplateLunch">
                                <td class="style1"/>
                                <td class="style2">
                                    <asp:CheckBox ID="chkLunch" runat="server" Text="Lunch" OnCheckedChanged="chkSlot_CheckedChanged" AutoPostBack=true  />
                                </td>
                            </tr>
                            <tr runat="server" id="rowTemplateTea">
                                <td class="style1"/>
                                <td class="style2">
                                    <asp:CheckBox ID="chkTea" runat="server" Text="Tea" OnCheckedChanged="chkSlot_CheckedChanged" AutoPostBack=true  />
                                </td>
                            </tr>
                            <tr runat="server" id="rowTemplateNight">
                                <td class="style1"/>
                                <td class="style2">
                                    <asp:CheckBox ID="chkNight" runat="server" Text="Night" OnCheckedChanged="chkSlot_CheckedChanged" AutoPostBack=true  />
                                </td>
                            </tr>
                            <tr runat="server" id="rowBatchSlots">
                                <td colspan="3">
                                    <table>
                                        <tr>
                                            <td>
                                            </td>
                                            <td>
                                                <asp:Label ID="Label1" runat="server" Text="From "></asp:Label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtFromDate" runat="server" validchars="DATE:dd/mm/yyyy" onkeypress="MaskInput(this);" onPaste="MaskInput(this)" Width="75px" CssClass="DisabledField" />&nbsp
                                                    <img src="..\..\images\ocs\show-calendar.gif" onclick="imgCalendar_Click();" style="border: 0">
                                            </td>
                                            <td>
                                                <asp:Label ID="Label2" runat="server" Text=" for "></asp:Label>
                                                <asp:TextBox ID="txtBatchDays" runat="server" Width="35px" CssClass="MandatoryField"></asp:TextBox>
                                                <asp:Label ID="lblBatchDays" runat="server" Text=" days and "></asp:Label>
                                                <input id="btnMinus" type="button" value="-" class="ICWButton" style="width:auto" onclick="btnMinus_Click();" />
                                                <asp:Label ID="lblSlotsNumber" runat="server" Text=" 0 "></asp:Label>
                                                <input id="btnPlus" type="button" value="+" class="ICWButton" style="width:auto" onclick="btnPlus_Click();" />
                                                <asp:Label ID="lblSlots" runat="server" Text=" slots"></asp:Label>
                                                <asp:Label ID="Label3" runat="server" Text=" to "></asp:Label>
                                            </td>
                                            <td>
                                                <asp:TextBox ID="txtTo" runat="server" CssClass="DisabledField" Width="75px" ></asp:TextBox>
                                            </td>
                                        </tr>
                                        <tr>
                                            <td >
                                                <asp:CheckBox ID="chkBatchBreakfast" runat="server" Text="Breakfast"  />
                                            </td>
                                            <td />
                                            <td align=center>
                                                <asp:CheckBox ID="chkFromBreakfast" runat="server" Checked=true />
                                            </td>
                                            <td />
                                            <td align=center >
                                                <asp:CheckBox ID="chkToBreakfast" runat="server" Checked=true />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td >
                                                <asp:CheckBox ID="chkBatchLunch" runat="server" Text="Lunch"  />
                                            </td>
                                            <td />
                                            <td align=center >
                                                <asp:CheckBox ID="chkFromLunch" runat="server" Checked=true />
                                            </td>
                                            <td />
                                            <td align=center >
                                                <asp:CheckBox ID="chkToLunch" runat="server" Checked=true />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td >
                                                <asp:CheckBox ID="chkBatchTea" runat="server" Text="Tea" />
                                            </td>
                                            <td />
                                            <td align=center >
                                                <asp:CheckBox ID="chkFromTea" runat="server" Checked=true />
                                            </td>
                                            <td />
                                            <td align=center >
                                                <asp:CheckBox ID="chkToTea" runat="server" Checked=true />
                                            </td>
                                        </tr>
                                        <tr>
                                            <td >
                                                <asp:CheckBox ID="chkBatchNight" runat="server" Text="Night"  />
                                            </td>
                                            <td />
                                            <td align=center >
                                                <asp:CheckBox ID="chkFromNight" runat="server" Checked=true />
                                            </td>
                                            <td />
                                            <td align=center >
                                                <asp:CheckBox ID="chkToNight" runat="server" Checked=true />
                                            </td>
                                        </tr>
                                    </table>
                                </td>
                            </tr>
                            <tr>
                                <td class="style1">
                                    <asp:Label ID="lblIncludeManual" runat="server" Text="Include non-JVM items"></asp:Label>
                                </td>
                                <td class="style2">
                                    <asp:CheckBox ID="chkManual" runat="server" />
                                </td>
                            </tr>
                            <tr>
                                <td class="style1">
                                    <asp:Label ID="lblPackingOrder" runat="server" Text="Packing order"></asp:Label>
                                </td>
                                <td class="style2">
                                    <asp:RadioButton ID="optSortName" runat="server" Text="Sort by patient name" GroupName="PackingOrder" />
                                </td>
                            </tr>
                            <tr>
                                <td class="style1" />
                                <td class="style2">
                                    <asp:RadioButton ID="optSortTime" runat="server" Text="Sort by administration slot"  GroupName="PackingOrder" />
                                </td>
                            </tr>
                        </table>
                        <hr />
                    </div>
                </div>
                
                <div  style="height:20px; text-align: center;">
		    <asp:Button ID="btnSave" runat="server" Text="Save" onclick="btnSave_Click" class="ICWButton" UseSubmitBehavior="false" />&nbsp
		    <asp:Button ID="btnCancel" runat="server" Text="Cancel" onclick="btnCancel_Click" class="ICWButton" />&nbsp
		    <asp:Button ID="btnSaveAs" runat="server" Text="Save As" onclick="btnSaveAs_Click" class="ICWButton" />
		</div>
            </ContentTemplate>
        </asp:UpdatePanel>
    </form>
</body>
</html>
