//------------------------------------------------------------------------------------------------
//
//									ORDER ENTRY DATA MANIPULATION SCRIPT
//
//	This script deals with all of the data handling and retrieving / pushing
//	to and from the various order forms hosted on the order entry page.  It
//	also deals with communication with the scheduler etc.
//
//	Modification History:
//	30May03 AE  Created by excising these procedures from OrderEntry.js in an 
//					attempt to make it all more manageable.
//	15Aug03 AE  Additions for cancelling orders.
//	25Mar04 AE  More XML Escapage
//	28Apr04 AE  Moved GoToDesktop into SaveComplete to allow error reporting in embedded mode.
//	16Jun04 AE  Removed defunct call to CloseSchedulePane().  #74878
//	05Aug04 AE  UpdateStartTimes:Now uses proper date object (part of DateControl changes)
//	04Feb05 AE  Loads of fixes and tweaks around ShuffleStartTimes/UpdateDependants, to make offsetting
//					work correctly with recursive ordersets and when editing pending ordersets
//	05Apr05 AE  Time Shuffling code: Modified to deal with copied ordersets
//      14Jul06 PH Changes description limit from 128 to 256
//      05Mar07 CJM Added checks for suspended prescriptions
//      04Jul07 ST  Added trap for null schedule info in CreateOneOffSchedule()
//------------------------------------------------------------------------------------------------

var m_blnCancelSave = false;									//Nasty module variable for cancelling in recursive calls.  k.Escd anybody?

var m_saveMode = '';												//Remember which method we were calling across asyncronous calls
var SAVE_PENDING = 'pending';
var SAVE_RESPONSE = 'response';
var SAVE_CANCELLATION = 'cancel';

//Constants
var TITLE_HAVENOTES = 'There are notes attached to this item. Click here to view or add a new note.';
var TITLE_NONOTES = 'Click here to attach a note to this item.';

var TITLE_HASSCHEDULE = 'Click here to view or edit the schedule.';
var TITLE_NOSCHEDULE = 'Click here to schedule this item to occur on a repeating schedule.';

var TITLE_ISPENDING = 'This item will be left pending';
var TITLE_NOTPENDING = 'Click here if you wish to leave this item unsent when you log off.';

var TITLE_LEAVEBLANK = '(Leave blank for "immediate")';
var TITLE_CLEARSCHEDULE = '(Click here to clear)';
var TITLE_INVALIDDATETIME = '(Date / Time invalid)';

//Exclusion lists
var DATACLASS_NO_DESCRIPTIONS = '|templateformula|';					//Items which do not have descriptions; each item must be bracketed by "|" characters

var SCHEDULER_WIDTH = 750;
var SCHEDULER_HEIGHT = 450;

var MIN_DESCRIPTION_CHARS = 3;													//23May06 AE  Implemented as constant, reduced min length.
var MIN_DESCRIPTION_CHARS_PRODUCT = 5;											
var MAX_DESCRIPTION_CHARS = 256;

//-------------------------------------------------------------------------------------------------
//												Status Handling
//-------------------------------------------------------------------------------------------------

function UpdateStatus(formIndex){

//Get the status information from the order form  and enter it into the 
//status panel.
//The statuses are scripted on the status bar, the rest of the information
//is scripted into the panel and hidden untill the "show" button is clicked.

var objInfo = new Object();
var strHTML = new String();
var strClass = new String();
var strStatus = new String();
var strMultipleStatus = new String();
var strTemp = new String();
var strMultiTemp = new String();
var SessionID = new String();
var objRow = new Object();
var objCell = new Object
var colStatus = new Object();
var colMultiStatus = new Object();
var colInfo = new Object();
var colSession = new Object();
var objRequest = new Object();
var attrRequest = new Object();
var RequestID = new String();
var intCount = new Number();
var rowCount = new Number();
var blnIsCancelled = false;
var blnIsSuspended = false;
var blnIsDiscontinued = false;
var blnIsMultiStatus = false;
var strText = '', formDescription = new String(), tableName = new String(), noteID = new String()
var dispenseText = new String(), administeredText = new String();
dispenseText = 'Dispensings have been made against this Prescription';
administeredText = 'Administration information is available for this Prescription';
var Url = new String(), Features = new String(), Parameters = new String()
var colAdministered = new Object(), administeredBy = new String(), administeredDate = new String();					
var colDispense = new Object();					
var dispenseBy = new String(), dispenseDate = new String()

    if (document.all['cmdShowStatus'] != undefined) {
		statusInfoBar.innerHTML = "";

		var strFormName = new String('orderForm' + formIndex);
	
		//Get a reference to the data 
		try {
			var objDom = document.frames[strFormName].document.all['instanceData'].XMLDocument
		}
		catch(err){};
	
		if (objDom != undefined) {
			//Find the status node
			objInfo = objDom.selectSingleNode('root/info');
			//Check if this is a prescription
			
			if (document.all['ordersXML'] != undefined) {
			
				var objDefinition = ordersXML.XMLDocument.selectSingleNode('//item[@formindex="' + formIndex + '"]');
				var blnIsRx = (objDefinition.getAttribute('isrx') == '1');
				var blnIsOrderSet = (objDefinition.getAttribute('requesttype') == 'Order set');
				if (objInfo != undefined ) {	
					//Got it; now read out the info and script it.
					//Start with the status of the item; there may be 
					//more than one!
					strTemp = '';
					strClass = '';	
					strMultipleStatus = '';													//Default HTML Class
					colStatus = objInfo.selectNodes('attribute[@name="status"]');
					for (intCount = 0; intCount < colStatus.length; intCount++ ) {
						if (strTemp != '') {strTemp += ', ';}				
						strStatus = colStatus[intCount].getAttribute('text');
						strTemp += strStatus;

						blnIsCancelled = StatusIsCancel(colStatus[intCount]);
						blnIsDiscontinued = StatusIsDiscontinued(colStatus[intCount]);
						blnIsSuspended = StatusIsSuspended(colStatus[intCount]);
						
						//Certain statuses are overriding; that is, they take precedence
						//over others in terms of importance:
						if (blnIsCancelled || blnIsDiscontinued)
						{
							strClass = 'StatusCancelled';
						}				
					}
					
					//* pick up multistatus node...
					colMultiStatus = objInfo.selectNodes('attribute[@name="multistatus"]');
					for (intCount = 0; intCount < colMultiStatus.length; intCount++ ) {
						if (strMultiTemp != '') {strMultiTemp += ', ';}				
						strMultipleStatus = colMultiStatus[intCount].getAttribute('text');
						strMultiTemp += strMultipleStatus;
						blnIsMultiStatus = true;
					}
					
					//* pick up SessionID
					colSession = objInfo.selectNodes('attribute[@name="sessionid"]');
					SessionID = colSession[0].getAttribute('text');

					//Update the class of the control bar etc.
					void SetStatusClass (statusInfoBar, strClass);
					void SetStatusClass (cmdShowStatus, strClass);
					void SetStatusClass (statusContainer, strClass);
		
					//Prescriptions don't come back with a status, unless cancelled (as they do not
					//have responses in the same way as other requests), so we deal with it here.
	//				if (blnIsRx && strTemp == '') {
					//	14Feb07 PH Make prescriptions and ordersets show a status of blank if not cancelled
					if ((blnIsRx || blnIsOrderSet) && !blnIsCancelled && !blnIsSuspended && !blnIsMultiStatus) {
						strTemp = '';	
					}
					else
					{
						//Should never happen, but check that a status was attached and warn if not.			

						// Comment out this so that SMS prescriptions do not display this warning.
						// This will be fixed properly from version 9.14 and above				
//						if (strTemp == '') {
//							strTemp = '<span style="background-color:white; color:red;font-weight:bold">' 
//									  + 'WARNING! No Statuses returned for this item!</span>';
//						}
//						else {  

                        if( '' != strTemp )
                        {
							strTemp = '<span style="font-style:italic;">' + strTemp + '</span>';
							if(blnIsMultiStatus != '')
							    strTemp += '&nbsp;&nbsp;&nbsp;<span>' + strMultipleStatus + '</span>';
							    
						}
						statusInfoBar.innerHTML = 'Status: ' + strTemp;						//This item is In Progress, Resulted, etc
					}	
		
					//Clear any existing info
					rowCount = statusContainer.rows.length;
					for (intCount=0; intCount < rowCount; intCount++) {
						void statusContainer.deleteRow(0);
					}
					
					objRow = statusContainer.insertRow(); //* insert blank rows
					objRow = statusContainer.insertRow(); objRow = statusContainer.insertRow();
					//Now write the rest of the info out as individual rows	
					colInfo = objInfo.selectNodes('attribute[@name!="status" and @name!="multistatus" and @name!="dispensedate" and @name!="dispensedby" and @name!="administereddate" and @name!="administeredby" and @name!="sessionid"]');
					for (intCount = 0; intCount < colInfo.length; intCount ++ ) {
						if(colInfo[intCount].getAttribute('displayname')!=null)
						{
						    objRow = statusContainer.insertRow();
						    objCell = objRow.insertCell(); 
						    objCell.className = 'StatusCell';
						    objCell.innerText = colInfo[intCount].getAttribute('displayname');

						    objCell = objRow.insertCell();
						    objCell.className = 'StatusCell';				
						    strText = colInfo[intCount].getAttribute('text');															//03Nov06 AE  Use text expansion if there is one, otherwise use the plain value. #SC-06-0941
						    if (strText == '' || strText == null) strText = colInfo[intCount].getAttribute('value');
						    objCell.innerText = strText ;
						}
					}

					objRow = statusContainer.insertRow(); //* insert blank rows
					//JMei F0074444 28Jan2010 match last row, so that text in last row are all left-justified
					objRow.insertCell();
					objRow.insertCell();
					objRow = statusContainer.insertRow(); 
					objRow = statusContainer.insertRow();
					
					objRequest = objDom.selectSingleNode('root/data/attribute[@name="RequestID"]');
					if (objRequest != undefined)
					{
					    RequestID = objRequest.getAttribute('value');					
    					
					    //* inclusion of supply info... dispensings and whether administered...
					    if (blnIsMultiStatus && (strMultipleStatus.indexOf('Administered',0) > -1) || 
					        (strMultipleStatus.indexOf('Dispensed',0) > -1))    
					    {
				            objRow = statusContainer.insertRow(); //* insert blank row
				            //F0087885 ST 02Jun10 Check for the administered details rather than the text so that note types dont
				            //make the link appear in error
				            if (objInfo.selectNodes('attribute[@name="administeredby"]').length > 0)
				            //if(strMultipleStatus.indexOf('Administered',0) > -1)
				            {
					            objRow = statusContainer.insertRow();
						        objCell = objRow.insertCell(); objCell.style.width = "350px"; objCell.className = 'StatusCell'; 
						        objCell.innerText = administeredText;
						        objCell = objRow.insertCell(); objCell.className = 'StatusCell';
						        Url = 'AdministrationRecord.aspx?SessionID='+ SessionID + '&RequestID='+ RequestID;
				                Features = 'dialogHeight:600px;dialogWidth:800px;resizable:yes;unadorned:no;status:no;help:no;';
				                objCell.innerHTML = '<a style="color:White" href="Javascript:void window.showModalDialog(' + "'" + Url + "', '', '" + Features + "'" + ');">View</a>';
						    }

						    //F0087885 ST 02Jun10 Check for the dispensed details rather than the text so that note types dont
						    //make the link appear in error
						    if (objInfo.selectNodes('attribute[@name="dispensedby"]').length > 0)
						    //if(strMultipleStatus.indexOf('Dispensed',0) > -1)
						    {
						        objRow = statusContainer.insertRow();
						        objCell = objRow.insertCell(); objCell.style.width = "350px"; objCell.className = 'StatusCell'; 
						        objCell.innerText = dispenseText;
						        objCell = objRow.insertCell(); objCell.className = 'StatusCell';
						        Url = 'DispensingRecord.aspx?SessionID='+ SessionID + '&RequestID='+ RequestID;
				                Features = 'dialogHeight:600px;dialogWidth:800px;resizable:yes;unadorned:no;status:no;help:no;';
				                objCell.innerHTML = '<a style="color:White" href="Javascript:void window.showModalDialog(' + "'" + Url + "', '', '" + Features + "'" + ');">View</a>';
						    }
					    }
					}
					
				    objRow = statusContainer.insertRow(); //* insert blank rows
				    objRow = statusContainer.insertRow(); objRow = statusContainer.insertRow();

				    //* Attached Note Status rows...
				    colInfo = objInfo.selectNodes('attribute[@name="attachednotestatuslist"]');
    				
				    Url = '../NotesEditor/EditNote.aspx?SessionID='+ SessionID
			        Features = 'dialogHeight:600px;dialogWidth:900px;resizable:no;unadorned:no;status:no;help:no;';
			        for (intCount = 0; intCount < colInfo.length; intCount ++ ) 
			        {
				        objRow = statusContainer.insertRow();
				        objCell = objRow.insertCell(); objCell.className = 'StatusCell';
				        objCell.innerText = colInfo[intCount].getAttribute('attachednotestatus') + ' by ';
				        objCell = objRow.insertCell(); objCell.className = 'StatusCell';
				        objCell.innerText = colInfo[intCount].getAttribute('attachednotecreatedby');
    					
				        objCell = objRow.insertCell(); objCell.className = 'StatusCell';
				        objCell.innerText = colInfo[intCount].getAttribute('attachednotecreateddate');
    	                
    	                //* parse note info...
    	                formDescription = colInfo[intCount].getAttribute('attachednoteform');
    	                tableName = colInfo[intCount].getAttribute('attachednotetablename');
    	                noteID = colInfo[intCount].getAttribute('attachednoteid');
    	                
    	                if(formDescription != null && formDescription != ''
    	                   && tableName != null && tableName != ''
    	                   && noteID != null && noteID != '')
					    {
				            Parameters = '&TableName=' + tableName + '&NoteID=' + noteID + "&FormCallType=AttachedNoteStatusList";
					        
			                objCell = objRow.insertCell(); objCell.className = 'StatusCell';
			                objCell.innerHTML = '<a style="color:White" href="Javascript:void window.showModalDialog(' + "'" + Url + Parameters + "', '', '" + Features + "'" + ');">View</a>';
			            }
			        }
				    
				    colDispense = objInfo.selectNodes('attribute[@name="dispensedby"]');
				    if(colDispense.length > 0)
				    {
				        dispenseBy = colDispense[0].getAttribute('text');
				        colDispense = objInfo.selectNodes('attribute[@name="dispensedate"]');
				        dispenseDate = colDispense[0].getAttribute('text');
        				
				        if(dispenseBy != '' && dispenseDate != '')
				        {
			                objRow = statusContainer.insertRow();
			                objCell = objRow.insertCell(); objCell.className = 'StatusCell';
				            objCell.innerText = 'Dispensed by ';
				            objCell = objRow.insertCell(); objCell.className = 'StatusCell';
				            objCell.innerText = dispenseBy;
				            objCell = objRow.insertCell(); objCell.className = 'StatusCell';
				            objCell.innerText = dispenseDate;
				            //objCell = objRow.insertCell(); objCell.className = 'StatusCell';
				            //objCell.innerText = 'View';
				            //Url = 'DispensingRecord.aspx?SessionID='+ SessionID + '&RequestID='+ RequestID;
				            //Features = 'dialogHeight:600px;dialogWidth:800px;resizable:yes;unadorned:no;status:no;help:no;';
				            //objCell.innerHTML = '<a style="color:White" href="Javascript:void window.showModalDialog(' + "'" + Url + "', '', '" + Features + "'" + ');">View</a>';
				        }
				    }
				    
				    colAdministered = objInfo.selectNodes('attribute[@name="administeredby"]');
				    if(colAdministered.length > 0)
				    { 
				        administeredBy = colAdministered[0].getAttribute('text');
				        colAdministered = objInfo.selectNodes('attribute[@name="administereddate"]');
				        administeredDate = colAdministered[0].getAttribute('text');
        				
				        if(administeredBy != '' && administeredDate != '')
			            {
			                objRow = statusContainer.insertRow();
			                objCell = objRow.insertCell(); objCell.className = 'StatusCell';
			                objCell.innerText = 'Last administration attempted by ';
				            objCell = objRow.insertCell(); objCell.className = 'StatusCell';
				            objCell.innerText = administeredBy;
				            objCell = objRow.insertCell(); objCell.className = 'StatusCell';
				            objCell.innerText = administeredDate;
				            //objCell = objRow.insertCell(); objCell.className = 'StatusCell';
				            //Url = 'AdministrationRecord.aspx?SessionID='+ SessionID + '&RequestID='+ RequestID;
				            //Features = 'dialogHeight:600px;dialogWidth:800px;resizable:yes;unadorned:no;status:no;help:no;';
				            //objCell.innerHTML = '<a style="color:White" href="Javascript:void window.showModalDialog(' + "'" + Url + "', '', '" + Features + "'" + ');">View</a>';
				        }
				    }
				}
			}
		}
	}
		
}
//---------------------------------------------------------------------------------------------------

function StatusIsCancel(objStatusXML) {

//Determines if the given status means "cancelled"
//The value attribute of each status node holds either the token "cancel", or some arbitrary text.
//If it contains "cancel", then this status means "Cancelled" as far as we are concerned.
//02Jun08 ST    strvalue.tolowercase wasn't being assigned to anything so the return statement never worked - have now assigned it back to itself


	var strValue = objStatusXML.getAttribute('value');
	strValue = strValue.toLowerCase();
	return (strValue == 'cancel');			
	
}
//---------------------------------------------------------------------------------------------------

function StatusIsSuspended(objStatusXML) {

//Determines if the given status means "suspended"
//The value attribute of each status node holds either the token "suspended", or some arbitrary text.
//If it contains "suspended", then this status means "Suspended" as far as we are concerned.
//02Jun08 ST    strvalue.tolowercase wasn't being assigned to anything so the return statement never worked - have now assigned it back to itself

	var strValue = objStatusXML.getAttribute('value');
	strValue = strValue.toLowerCase();
	return (strValue == 'suspended');			
	
}

function StatusIsDiscontinued(objStatusXML)
{
//Determines if the given status means "discontinued"
//The value attribute of each status node holds either the token "discontinued", or some arbitrary text.
//If it contains "suspended", then this status means "Suspended" as far as we are concerned.
//02Jun08 ST    strvalue.tolowercase wasn't being assigned to anything so the return statement never worked - have now assigned it back to itself
//02Jun08 ST    discontinued comes back with the word Discontinued in the text attribute which is unlink Cancelled/Suspended
    var strValue = objStatusXML.getAttribute('text');
    strValue = strValue.toLowerCase();
    return (strValue == 'discontinued');
}

//---------------------------------------------------------------------------------------------------
//											Adding Items on-the-fly
//---------------------------------------------------------------------------------------------------
function AddItem() {
//Entry point to the process; used in embedded mode, a user can select an item or items to 
//add to the list.
	

}

//---------------------------------------------------------------------------------------------------
//											Attached Notes Handling
//---------------------------------------------------------------------------------------------------

function UpdateNotes(){
	
//Determine if there are any notes attatched to this item and 
//Show the button and banner as appropriate.
//04Mar04 AE  Changed to use visibility instead of display style
var blnHaveNotes = false;
var blnEnableButton = false;
var strClass = new String();

//Check if we have even scripted the Notes button (won't have done in template mode for eg);
//if not, don't even bother...
	if (document.all['cmdNotes'] != undefined) {
	
	//Find the node in the OrdersXML island
			
		if (document.all['ordersXML'] != undefined) {
			
			var objNode = ordersXML.XMLDocument.selectSingleNode('root//item[@formindex="' + m_currentFormIndex + '"]');
			blnHaveNotes = ( objNode.getAttribute('hasnotes') == '1' );
			blnEnableButton = blnHaveNotes;
		
			if (blnHaveNotes) {
				//We have one or more notes; enable the
				//banner.
				imgAttachedNote.src = '../../images/ocs/classAttachedNote.gif';
				cmdNotes.title = TITLE_HAVENOTES;
			}
			else {
				//We have no notes; hide the banner 
				imgAttachedNote.src = '../../images/ocs/classAttachedNote.gif';
				cmdNotes.title = TITLE_NONOTES;
			}
		
			//Do we enable the button? we do IF:
			//this is a pending or request item.
			strClass = objNode.getAttribute('dataclass');

			if (strClass == 'pending' ) {
				blnEnableButton = true;
			}
		}
		cmdNotes.disabled = !blnEnableButton;
	}
}
//---------------------------------------------------------------------------------------
//										Schedule Handling
//---------------------------------------------------------------------------------------

function InsertScheduleData(formIndex, strSchedule_XML, dtStartDate) {

//Inserts strSchedule_XML into the given form's Schedule data island
//strSchedule_XML:  <root><Schedule...>...</Schedule></root>

//Get a reference to the data island to put it in
	var formName = 'orderForm' + formIndex;
	var scheduleData = document.frames[formName].document.all['scheduleData'].XMLDocument;
	//And in it goes...	
	void scheduleData.loadXML (strSchedule_XML);
}

//-------------------------------------------------------------------------------------------------

function GetScheduleNodeFromForm(formIndex) {

//Retrieve the schedule XML element from the given form

	var strReturn_XML = new String();

	var formName = 'orderForm' + formIndex;																//12May04 AE  Corrected from m_currentFormIndex
	var scheduleData = document.frames[formName].document.all['scheduleData'].XMLDocument;
	if (scheduleData !== undefined) {
		return scheduleData.selectSingleNode('root/Schedule');                   
	}
	else {
		return null;
	}

}


// updates the start time on the orderset
function UpdateStartTime(datStartTime)
{
	var objOrders = document.all['ordersXML'].XMLDocument.selectSingleNode('root');
	if (objOrders.childNodes.length > 1)
	{																									//18Apr05 AE  Added to prevent single items entering the process
		var objChangedItem = objOrders.selectSingleNode('//item[@formindex="' + m_currentFormIndex + '"]');			
		objChangedItem.setAttribute('startsat', datStartTime);
		objChangedItem.setAttribute('dotimeupdate', '1');																			//04Feb05 AE  Make sure we update the schedule of the changed item too!
		objChangedItem.setAttribute('calculated', '0');																				//05Dec06 AE  Flag to indicate that this date was set by the user, not calculated #DR-06-0019
	}		
}



//----------------------------------------------------------------------------------------

function UpdateStartTimes() {

//Copy the startsat attribute (date time in 'dd/mm/yyyy hh:nn' format) from the xml
//definition of each item (held in the ordersXML data island on OrderEntry.aspx) into
//the schedule data island (or equivilent) on each order form.

var intSetCount = new Number();
var intItemCount = new Number();
var strStartDate = new String();
var strStartTime = new String();
var formName = new String();
var intFormIndex = new Number();
var objSpan = new Object();
var intSpan = new Number();
var objPrescription = new Object();
var objScheduleTemplate = new Object();
var colOrdersetItems = new Object();
var colChildren = new Object();
var objItem = new Object();
var dtDate;

	//For each order set, return its items which are flagged to be changed
	colOrdersetItems = ordersXML.XMLDocument.selectNodes('//item[@dotimeupdate="1"]');
	for (intItemCount = 0; intItemCount < colOrdersetItems.length; intItemCount++) {
		objItem = colOrdersetItems[intItemCount];
		strStartDate = objItem.getAttribute('startsat'); 								//dd/mm/yyyy hh:mm
		var blnImmediate = (objItem.getAttribute('immediate') == 1);

		strStartTime = strStartDate.substring(strStartDate.indexOf(' ') + 1);		//hh:mm										//12May04 AE  Corrected to use indexOf + 1
		strStartDate = strStartDate.substring(0, strStartDate.indexOf(' '));			//dd/mm/yyyy								//05Aug04 AE  Removed call to parsedate
		dtDate = new Date(Number(strStartDate.substring(6, 10)), Number(strStartDate.substring(3, 5)) - 1, Number(strStartDate.substring(0, 2)) )	

		// 07Sep05 ST	Added the time to the date object
		dtDate.setHours(Number(strStartTime.substring(0,2)))
		dtDate.setMinutes(Number(strStartTime.substring(3,5)))


		//Now store the date appropriately; this is in the schedule for everything,
		//yes, you guessed it, except for prescriptions.
		intFormIndex = objItem.getAttribute('formindex');
		formName = FORMID_PREFIX + intFormIndex;

		if	(objItem.getAttribute('isrx') == 1) {
			//Prescription; send to the prescription custom control's 
			//SetStartDate method
			// 23Jul07 PH Now we host the RX page directly
	
			void document.frames[formName].SetStartDate(dtDate, blnImmediate);
		}
		else {
			//Everything else; need to create a schedule for "occurs once at" the start date
			//We use the empty schedule template which is stored in the ordersXML document
			objScheduleTemplate = ordersXML.XMLDocument.selectSingleNode('root/Schedule');
			//Insert our start/stop dates; note that these are the same, as this is a once-off.
			objScheduleTemplate.setAttribute('StartDate', strStartDate);
			objScheduleTemplate.setAttribute('StartTime', strStartTime);
			objScheduleTemplate.setAttribute('EndDate', strStartDate);
			objScheduleTemplate.setAttribute('EndTime', strStartTime);

			//Insert the schedule into this item's xml						
			void InsertScheduleData(intFormIndex, '<root>' + objScheduleTemplate.xml + '</root>', dtDate);

			if (!IsInfoPage(intFormIndex) && !IsSharedPage(intFormIndex)){		
				void UpdateScheduleInfo(intFormIndex);																								//12May04 Added
			}
			else {
			//Orderset information page; use its SetStartDate method
				dtDate = new Date(Number(strStartDate.substring(6, 10)), Number(strStartDate.substring(3, 5)) - 1, Number(strStartDate.substring(0, 2)) )	

				// 07Sep05 ST	Added the time to the date object
				dtDate.setHours(Number(strStartTime.substring(0,2)))
				dtDate.setMinutes(Number(strStartTime.substring(3,5)))
				
				void document.frames[formName].SetStartDate(dtDate, blnImmediate);
			}						
		}

		//Mark this item as done
		void objItem.setAttribute('dotimeupdate', '0');
	}
}

//-------------------------------------------------------------------------------------------------

function ShuffleStartTimes (strStartsAt, blnImmediate) {

//Checks for dependant items of the current item, and if any
//are found, updates their start times appropriately.
//We update the startsat attribute in the ordersXML data island, then UpdateStartTimes
//is called to handle the passing of this information back to the individual schedule
//data islands (or equivilent) on the various forms and custom controls.
//NOTE TO SELF:  It is done this way, using the startsat attribute, for good reason; custom controls
//					  (well prescribing) can call this method, but would not "know" about their schedules
//					  or schedule bars.  UpdateStartTimes is called at the end of the process to deal
//			        with updating each form / schedule bar / schedule as appropriate.

//strStartsAt:			datetime in "dd/mm/yyyy hh:nn" format

var objThisItem = new Object();
var strMsg = new String();
var blnContinue = false;

	//Check if we are in an order set
	var objOrders = document.all['ordersXML'].XMLDocument.selectSingleNode('root');
	if (objOrders.childNodes.length > 1){																									//18Apr05 AE  Added to prevent single items entering the process
		var objChangedItem = objOrders.selectSingleNode('//item[@formindex="' + m_currentFormIndex + '"]');

		//Build a list of items which will be affected by this change
		strMsg = DependantsList(objChangedItem);																							//27Jan05 AE  Corrected logic; now uses recursive procedure.
	
		if (strMsg.length > 0) {
		//Indicates that we found at least one dependant item
			var strMsg = 'Do you wish to update the start dates of the following items\n'
						  + 'to take account of the changes you have just made?\n' 
						  + strMsg + '\n\n'
						  + '(Click OK to change the start dates, Cancel to leave them unchanged)'
			blnContinue = window.confirm(strMsg);			
		}
		else {
			blnContinue = true;																													//04Dec06 AE  Make sure we update the startsat attribute for items without dependants #DR-06-0019
		}
		
		if (blnContinue) {
			//Go ahead and update the items
			//Update the first item with the new start and stop time
			var objChangedItem = objOrders.selectSingleNode('//item[@formindex="' + m_currentFormIndex + '"]');			
			objChangedItem.setAttribute('startsat', strStartsAt);
			objChangedItem.setAttribute('dotimeupdate', '1');																			//04Feb05 AE  Make sure we update the schedule of the changed item too!
			objChangedItem.setAttribute('calculated', '0'); 																			//05Dec06 AE  Flag to indicate that this date was set by the user, not calculated #DR-06-0019
			if (blnImmediate)
			{
				objChangedItem.setAttribute('immediate', '1');
			}
			else
			{
				objChangedItem.setAttribute('immediate', '0');
			}
			DependantsUpdate(objChangedItem); 																						//27Jan05 AE  Corrected logic; now uses recursive procedure.
			ImmediateInfoUpdate(objChangedItem)

			//Finally, update each forms schedule data island (or equivilient) with the
			//newly calculated start times	
			UpdateStartTimes();
		}
	}
}

//-------------------------------------------------------------------------------------------------
function DependantsList(objItem){

//Return a string containing a list of all items which are dependants
//of objItem; this does not include children of dependants.
//27Jan05 AE  Written

var intCount = 0;
var strMsg = '';
var lngItemID = 0;

//Show children of the changed item, if any
	var colChildren = objItem.selectNodes('item[@ocstype="request"]');													//20May05 AE  Now only looks for requests (nothing else can be scheduled anyhow.  All children of this item (will only apply if an orderset has been changed)
	for (intCount=0; intCount < colChildren.length; intCount++){
	//Add this item to the list				
		strMsg += '\n\t' + colChildren[intCount].getAttribute('description');
	}

//And siblings which are affected
	var colDependants = GetDependantSiblings(objItem)
	for (intCount=0; intCount < colDependants.length; intCount++){
	//Add this item to the list				
		strMsg += '\n\t' + colDependants[intCount].getAttribute('description');
	}

	return strMsg;
}

//-------------------------------------------------------------------------------------------------
function DependantsUpdate(objItem){

//Updates all dependants of objItem based on its new start date.
//This change is propogated recursively, so that dependants of 
//dependants are updated as well.
//27Jan05 AE  Written
//05Apr05 AE  Modified to deal with copied ordersets

var intCount = 0;
var strMsg = '';
var lngItemID = 0;
var colChildren;

//All children of this item (will only apply if an orderset has been changed) which are offset
//from the start of the orderset
	switch (objItem.getAttribute('dataclass')){
		case 'orderset':
		case 'template':
		case 'pending':	
		//New/edit of pending items
			colChildren = objItem.selectNodes('item[@dependson="0"]');				
			break;
			
		case 'request':
		//copy of an existing orderset
			colChildren = objItem.selectNodes('item[@requestid_requisit="' + objItem.getAttribute('id') + '"]');									
			break;
		
	}
	if (colChildren != undefined){					//20May05 AE  Prevent error if objItem is a note
		for (intCount=0; intCount < colChildren.length; intCount++){
		//Update me baby	
			void UpdateDependantStartTime(objItem, colChildren[intCount])
		//Now update dependants of this item
			void DependantsUpdate(colChildren[intCount]);
		}
	
	//Now update any siblings of objItem which depend on it
		var colDependants = GetDependantSiblings(objItem);	
		for (intCount=0; intCount < colDependants.length; intCount++){
		//Update me baby
			void UpdateDependantStartTime(objItem, colDependants[intCount])
		//Now update dependants of this item
			void DependantsUpdate(colDependants[intCount]);
		}
	}
}


//------------------------------------------------------------------------------------------------
function ImmediateInfoUpdate(objItem)
{
	var intCount = 0;
	var colChildren;

	//All children of this item (will only apply if an orderset has been changed) which are offset
	//from the start of the orderset
	switch (objItem.getAttribute('dataclass'))
	{
		case 'orderset':
		case 'template':
		case 'pending':
			//New/edit of pending items
			colChildren = objItem.selectNodes('item[@dependson="0"]');
			break;

		case 'request':
			//copy of an existing orderset
			colChildren = objItem.selectNodes('item[@requestid_requisit="' + objItem.getAttribute('id') + '"]');
			break;

	}
	if (colChildren != undefined)
	{					//20May05 AE  Prevent error if objItem is a note
		for (intCount = 0; intCount < colChildren.length; intCount++)
		{
			//Update me baby
			void UpdateDependantImmediateInfo(objItem, colChildren[intCount])
			//Now update dependants of this item
			void ImmediateInfoUpdate(colChildren[intCount]);
		}

		//Now update any siblings of objItem which depend on it
		var colDependants = GetDependantSiblings(objItem);
		for (intCount = 0; intCount < colDependants.length; intCount++)
		{
			//Update me baby
			void UpdateDependantImmediateInfo(objItem, colDependants[intCount])
			//Now update dependants of this item
			void ImmediateInfoUpdate(colDependants[intCount]);
		}
	}
}


//-------------------------------------------------------------------------------------------------
function GetDependantSiblings(objItem){

//Return an iXMLDomNodeList of elements which are dependants of this item within
//objParentItem
//05Apr05 AE  Modified to deal with copied ordersets
//20Apr05 AE  Prevent pending ordersets trying to update themselves
var objItemParent;
var lngItemID = 0;

//Find dependancies of this item which are siblings

	objItemParent = objItem.parentNode;
	var colDependants = objItemParent.selectNodes('nomatch')							//default the object to be an empty collection 
	switch (objItem.getAttribute('dataclass')){
		case 'template':
		case 'pending':
		//new/existing Pending items
			if (objItem.getAttribute('ordersetitemid') != null){
				lngItemID = objItem.getAttribute('ordersetitemid');
				colDependants = objItemParent.selectNodes('item[(@dependson="' + lngItemID + '") and (@ordersetitemid!="' + lngItemID + '")]');				//20Apr05 AE  Prevent pending ordersets trying to update themselves
			}
			break;			
		
		case 'request':
			lngItemID = objItem.getAttribute('id');
			colDependants = objItemParent.selectNodes('item[@requestid_requisit="' + lngItemID + '"]');		
			break;
	
		case 'note':
		//This case can never happen, since notes cannot be scheduled!
			break;
	}

	//Get the dependants if objItem in the orderset
	return colDependants;
}


//-------------------------------------------------------------------------------------------------
function UpdateDependantStartTime(objBaseItem, objDependantItem) {

//Update objDependantItem's start date/time based on its offset from objBaseItem's 
//start time. This is stored in the startsat attribute of the XML definition of the form
	
	//Get the start date/time from the base item, and store in its definition

	var strStartsAtBase = objBaseItem.getAttribute('startsat');					//dd/mm/yyyy hh:nn format
	
	var astrStarts = strStartsAtBase.split(' ');
	var astrStartDate = astrStarts[0].split('/');									//[0]dd [1]mm [2]yyyy
	var astrStartTime = astrStarts[1].split(':');									//[0]hh [1]nn
	
	//Create a new date object, using parameters method to remove any ambiguity
	var dtBaseStart = new Date(astrStartDate[2], (Number(astrStartDate[1]) - 1), astrStartDate[0], astrStartTime[0], astrStartTime[1]);		

	//Add the offset as specified in the dependant item
	var offsetMinutes = new Number(objDependantItem.getAttribute('offsetminutes'));
	var lngBaseMilliseconds = Date.parse(dtBaseStart.toUTCString());							//ms since fundamental epoch
	var lngDependantMilliseconds = lngBaseMilliseconds + eval(60000 * offsetMinutes);
	var dtNewStart = new Date(lngDependantMilliseconds);

	if (dtBaseStart.getTimezoneOffset() != dtNewStart.getTimezoneOffset() && offsetMinutes > 1440){										//02Nov05 AE  Handle the DST boundary
	//We've gone over a daylight savings time boundary, eg oct 30th -> 31st, and the addition
	//specified is in days (or greater).
	//This will cause problems if a time is not specified; we assume midnight, and add an offset of minutes, 
	//the js date object puts the hour back/forwards correctly, but this is not what we want if adding
	//a number of days, for example.
	//Subtract the difference from the sum
		lngDependantMilliseconds -= (dtBaseStart.getTimezoneOffset() - dtNewStart.getTimezoneOffset()) * 60000;						//getTimezoneOffset returns minutes.
		dtNewStart = new Date(lngDependantMilliseconds);
	}

	var strStartsAtNew =  PadL(dtNewStart.getDate(),2,'0') + '/'
						+ PadL((dtNewStart.getMonth() + 1),2,'0') + '/'																					//27Jan05 AE  added "+ 1" to convert JS stupid dates into normal ones
						+ PadL(dtNewStart.getFullYear(),4,'0') + ' '											
						+ PadL(dtNewStart.getHours(),2,'0') + ':'
						+ PadL(dtNewStart.getMinutes(),2,'0');																								//Return new start as "dd/mm/yyyy hh:nn"


	objDependantItem.setAttribute('startsat', strStartsAtNew);
	objDependantItem.setAttribute('dotimeupdate', '1');																							//Flag to indicate to UpdateStartTimes that this item should be processed
	objDependantItem.setAttribute('calculated', '1'); 																						//Flag to indicate that this date was calculated from dependancy info 05Dec06 AE  #DR-06-0019
}


//-------------------------------------------------------------------------------------------------
function UpdateDependantImmediateInfo(objBaseItem, objDependantItem) {

	//Update objDependantItem's immediate flag based on its offset from objBaseItem's
	//start time. This is stored in the startsat attribute of the XML definition of the form

	var offsetMinutes = new Number(objDependantItem.getAttribute('offsetminutes'));

	if (offsetMinutes == 0)
	{
		var requisitImmediate = objBaseItem.getAttribute('immediate');
		if (requisitImmediate == undefined)
		{
			requisitImmediate = "1";
		}
		objDependantItem.setAttribute('immediate', requisitImmediate);
	}
	else
	{
		objDependantItem.setAttribute('immediate', '0');
	}

}


//------------------------------------------------------------------------------------------------
function SetImmediateInfo()
{
	var xmlItems = document.all['ordersXML'].XMLDocument.documentElement.selectNodes('item');
	for (index = 0; index < xmlItems.length; index++)
	{
		if (xmlItems[index].childNodes.length > 0)
		{
			ImmediateInfoUpdate(xmlItems[index]);
		}
	}
}

//------------------------------------------------------------------------------------------------
function UpdateScheduleInfo(formIndex) {

//If this item has repeats scheduled, display this fact on the scheduler bar.	
var intDailyRepeat = -1;
var intScheduleRepeat = -1;
var strStartDate = new String();
var strStartTime = new String();

	var scheduleName = SCHEDULEID_PREFIX + formIndex;
	var tblScheduleBar = document.all[scheduleName];
	if (tblScheduleBar !== undefined) {												//Scheduler is not shown for templates
		var spnCaption = tblScheduleBar.all['scheduleCaption'];
		var imgIndicator = tblScheduleBar.all['imgSchedule'];
		var objSchedule = GetScheduleNodeFromForm(formIndex);
		
		if (objSchedule !== null) {
			intDailyRepeat = objSchedule.getAttribute('DailyFrequency');
			intScheduleRepeat = objSchedule.getAttribute('ScheduleFrequency');
			strStartDate = objSchedule.getAttribute('StartDate');
			strStartTime = objSchedule.getAttribute('StartTime');
		}	

		if (intDailyRepeat > 0 || intScheduleRepeat > 0) {
			//We have repeats.  Show the schedule description and disable the 
			//start/stop date boxes.
			spnCaption.innerText = objSchedule.getAttribute('Description') + '  (' + TITLE_HASSCHEDULE + ')';
	
			//Remove the simple schedule controls
			void SetScheduleControls(false, formIndex);
		}
		else {
		//Show the simple schedule controls
			void SetScheduleControls(true, formIndex);
			spnCaption.innerText = TITLE_NOSCHEDULE;
			tblScheduleBar.all['txtRequestDate'].value = strStartDate;
			tblScheduleBar.all['txtRequestTime'].value = strStartTime;
		}
	}
		
}

//------------------------------------------------------------------------------------------------
function SetScheduleControls(blnIsSimpleSchedule, formIndex){
//Set the specify schedule bar to simple or advanced view
//25May04 AE  Corrected error when only a single scheduleSimple element existed.

	var scheduleName = SCHEDULEID_PREFIX + formIndex;
	var tblScheduleBar = document.all[scheduleName];
	var objScheduleSimple = tblScheduleBar.all['scheduleSimple'];

	var strDisplay = blnIsSimpleSchedule ? 'block' : 'none';

	tblScheduleBar.rows[0].cells[2].style.display = strDisplay;
	tblScheduleBar.rows[0].cells[3].style.display = strDisplay;
	tblScheduleBar.rows[0].cells[4].style.display = strDisplay;
	tblScheduleBar.rows[0].cells[5].style.display = strDisplay;
	objScheduleSimple.style.color='#000000';

	if (blnIsSimpleSchedule) {
		tblScheduleBar.all['imgSchedule'].style.display = 'block';
		objScheduleSimple.innerText = TITLE_LEAVEBLANK;	
		objScheduleSimple.className = '';
		void objScheduleSimple.detachEvent('onmouseover', ScheduleText_MouseOver);
		void objScheduleSimple.detachEvent('onmouseout', ScheduleText_MouseOut);
		void objScheduleSimple.detachEvent('onclick', SetSimpleSchedule);
		
	}
	else {
		tblScheduleBar.all['imgSchedule'].style.display = 'none';
		objScheduleSimple.innerText = TITLE_CLEARSCHEDULE;
		objScheduleSimple.style.textDecoration='none';
		objScheduleSimple.className = 'scheduleText';
		void objScheduleSimple.attachEvent('onmouseover', ScheduleText_MouseOver);
		void objScheduleSimple.attachEvent('onmouseout', ScheduleText_MouseOut);
		void objScheduleSimple.attachEvent('onclick', SetSimpleSchedule);
	}
}

//------------------------------------------------------------------------------------------------
function ScheduleText_MouseOver() {
	window.event.srcElement.style.textDecoration = 'underline';
}
//------------------------------------------------------------------------------------------------
function ScheduleText_MouseOut() {
	window.event.srcElement.style.textDecoration = 'none';
}
//------------------------------------------------------------------------------------------------
function BrowseStartTime(objPicker) {

//Show the date picker and enter a start date/time in the given schedule bar.
	var tblScheduleBar = objPicker.parentElement.parentElement.parentElement.parentElement;

	var dateNow = new Date();
	var now_hour, now_min;
	var objDate = tblScheduleBar.all['txtRequestDate'];
	var objTime = tblScheduleBar.all['txtRequestTime'];

	//Enter "now" as the time, if it isn't already filled in.
	//13Jan2010 JMei F0074414 use isotime as format here
	if (objTime.value == '') {
	    if (dateNow.getHours() < 10) {
	        now_hour = "0" + dateNow.getHours();
	    }
	    else {
	        now_hour = dateNow.getHours();
	    }

	    if (dateNow.getMinutes() < 10) {
	        now_min = "0" + dateNow.getMinutes();
	    }
	    else {
	        now_min = dateNow.getMinutes();
	    }
	    objTime.value = now_hour + ":" + now_min;
	}
	//Let the user browse for the date
	void ShowMonthViewWithDate(objPicker, objDate, objDate.value);	

}

//-------------------------------------------------------------------------------`-----------------
function EditSchedule(objScheduleBar) {

//Event handler for the schedule bar.
//Edit the schedule for this item in the pop-up scheduler.

	//This is for future use in form stacking...currently very simple
	void EditScheduleByIndex(m_currentFormIndex);

}
//------------------------------------------------------------------------------------------------

function EditScheduleByIndex(formIndex) {

//Edit the schedule for this item in the pop-up scheduler
var strSchedule_XML = new String();

	var objScheduleXML = GetScheduleNodeFromForm(formIndex);
	
	if (objScheduleXML != null) {
		strSchedule_XML = '<root>' + objScheduleXML.xml + '</root>';	
	}
	
	var Url = '../Scheduler/SchedulerModal.aspx'
				  + '?SessionID=' + document.body.getAttribute('sid')
				  + '&Mode=order';
	var Features =  'dialogHeight:' + SCHEDULER_HEIGHT + 'px;' 
						 + 'dialogWidth:' + SCHEDULER_WIDTH + 'px;'
						 + 'resizable:no;unadorned:no;'
						 + 'status:no;help:no;';		
	strSchedule_XML = window.showModalDialog(Url, strSchedule_XML, Features);
	if (strSchedule_XML == 'logoutFromActivityTimeout') {
		strSchedule_XML = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	if (strSchedule_XML!=null && strSchedule_XML != 'cancel' ) {
		if (strSchedule_XML != 'templates') {
			void InsertScheduleData(formIndex, strSchedule_XML);	
		}
		void UpdateScheduleInfo(formIndex);
	}
}
//-------------------------------------------------------------------------------------------------
function SetSimpleSchedule() {

//Returns the schedule bar to the simple schedule mode.
	var tblSchedule = GetTRFromChild(window.event.srcElement).parentElement.parentElement;
	var tableID = tblSchedule.id;
	var formIndex = tableID.substring(SCHEDULEID_PREFIX.length);	
	var objSchedule = GetScheduleNodeFromForm(formIndex);
	void objSchedule.setAttribute('DailyFrequency', 0);
	void objSchedule.setAttribute('ScheduleFrequency', 0);
	void objSchedule.setAttribute('StartDate', '');
	void objSchedule.setAttribute('StartTime', '');
	void UpdateScheduleInfo(formIndex);
}
//-------------------------------------------------------------------------------------------------

function CreateOneOffSchedule(formIndex) {

//If a start date / time has been entered in the schedule bar, create a schedule
//containing that date; otherwise return a blank string.	
var strReturn = new String();
var strStartDate = new String();
var objSchedule = new Object();

	var tblScheduleBar = document.all[(SCHEDULEID_PREFIX + formIndex)];			//Reference to the appropriate schedule bar
	if(tblScheduleBar != undefined)
	{
		var objDate = tblScheduleBar.all['txtRequestDate'];
		var objTime = tblScheduleBar.all['txtRequestTime'];
		m_currentFormIndex = formIndex;
	
		if ((objDate != undefined) && (objTime != undefined)) 
		{
			var strDate = objDate.value;
			var strTime = objTime.value;
			if ((strDate != '') && (strTime != '')) 
			{
				strDate = ParseDate(strDate, 'dd/mm/yyyy');

				if ((strDate != '') && (TimeStringValidation(strTime) == '') ) 
				{
					//We have a valid simple date/time; insert it into the schedule XML document
					//tblScheduleBar.all['scheduleSimple'].style.display = 'none';
					tblScheduleBar.all['scheduleSimple'].innerText = '';
					tblScheduleBar.all['scheduleSimple'].style.color='#ffffff';	

					objSchedule = GetScheduleNodeFromForm(formIndex);
					// 04Jul07 ST  Traps if there is no schedule info there
					if(objSchedule != null)
					{
						objSchedule.setAttribute('DailyFrequency', 0);
						objSchedule.setAttribute('ScheduleFrequency', 0);
						objSchedule.setAttribute('StartDate', strDate);
						objSchedule.setAttribute('StartTime', strTime);
						void ShuffleStartTimes (strDate + ' ' + strTime);
					}
					else
					{
						// 05Sep07 ST  Updated so that it actually creates something in the schedule
						// We use the empty schedule template which is stored in the ordersXML document
						objSchedule = ordersXML.XMLDocument.selectSingleNode('root/Schedule');
					
						//Insert our start/stop dates; note that these are the same, as this is a once-off.
						objSchedule.setAttribute('StartDate', strDate);
						objSchedule.setAttribute('StartTime', strTime);
						objSchedule.setAttribute('EndDate', strDate);
						objSchedule.setAttribute('EndTime', strTime);

						//Insert the schedule into this item's xml						
						void InsertScheduleData(formIndex, '<root>' + objSchedule.xml + '</root>');
					}
				}
				else 
				{
					//Date and time entered, but not valid.
					//tblScheduleBar.all['scheduleSimple'].style.display = 'block';
					tblScheduleBar.all['scheduleSimple'].innerText = TITLE_INVALIDDATETIME;
					tblScheduleBar.all['scheduleSimple'].style.color='#ff0000';	
				}
			}
		}
	}
	// 05Sep07 ST  Function wasn't returning anything so we send
	// something back if we have it.
	if(objSchedule.xml != undefined)
	{
		return objSchedule.xml;
	}

}

//-------------------------------------------------------------------------------------------------
//											Pending Reason Handling
//-------------------------------------------------------------------------------------------------

function UpdatePending(formIndex) {

//Updates the pending reason button
	//Check to see if there is a pending reason for this item already.
	if ((document.all['cmdPending'] != undefined) && !IsInfoPage(formIndex) && !IsSharedPage(formIndex)) {													//26Jan05 AE  Added Info pages
		var formName = FORMID_PREFIX + formIndex;
		var instanceData = document.frames[formName].document.all['instanceData'].XMLDocument.selectSingleNode('root/data');
		var strPending = instanceData.getAttribute('reason');
		if (strPending == null) {strPending = ''};
		if (strPending != '') {
			imgPending.src = '../../images/ocs/classPending.gif';
			cmdPending.title = TITLE_ISPENDING + ' (' + strPending + ')';
		}
		else {
			imgPending.src = '../../images/ocs/classUnknown.gif';
			cmdPending.title = TITLE_NOTPENDING;
		}		
	}
}
//-------------------------------------------------------------------------------------------------

function EditPending() {

//Allows the user to add a pending reason.
	//Check for an existing reason
	var formName = FORMID_PREFIX + m_currentFormIndex;
	var instanceData = document.frames[formName].document.all['instanceData'].XMLDocument.selectSingleNode('root/data');
	var strPending = instanceData.getAttribute('reason');

	//Show the picker dialog
	var Url = '../PendingItemsV10/PendingReasonPicker.aspx'
			  + '?SessionID=' + document.body.getAttribute("sid");
	var Features = 'status:off; dialogHeight:680px; dialogWidth:600px';
	var strPending = window.showModalDialog(Url, strPending, Features);
	if (strPending == 'logoutFromActivityTimeout') {
		strPending = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	if (strPending!=null && strPending != 'CANCEL' ){
		//Save the reason back to the xml island
		instanceData.setAttribute('reason', strPending);
		void UpdatePending(m_currentFormIndex);
	}
	
}
//---------------------------------------------------------------------------------------
//										Data Retrieval for saving
//---------------------------------------------------------------------------------------

function CheckDataValid() {
	
//Checks each form for a ValidityChecks() method.  If one exists (only certain custom controls
//will expose this method), then it is queried.  We return false if any of these method calls return false.	
var formName = new String();
var blnValid = true;
var blnAllValid = true;
var strMsg = new String();

	var intNumForms = CountOrderForms();
	
	for (formIndex = 0; formIndex < intNumForms; formIndex++) {
		formName = 'orderForm' + formIndex;	
		if (document.frames[formName].ValidityCheck != undefined) {
			blnValid = document.frames[formName].ValidityCheck();
			if (!blnValid) {
				blnAllValid = false;				
				if (intNumForms > 1) {
					//We only build a message if there is more than one form; otherwise
					//the mistakes are there to see.  With more than one form, the mistakes
					//could be on a hidden form, so we want to inform them which one
					if (strMsg != '') strMsg += '\n';
					strMsg += '\t - ' + spnItemTitle[formIndex].innerText
				}
			}
		}
	}
	
	if (strMsg != '') {
		strMsg = 'The following item(s) contain incorrect information, and must be '
				 + 'corrected before the can be saved:\n\n' + strMsg;
		Popmessage(strMsg, 'Warning');
	}
	
	return blnAllValid;
	
}

//---------------------------------------------------------------------------------------
function CollateDataFromForms() {
	
//Gather all the inputted data from all the forms and return in an 
//xml string as follows:
//
//		<save>
//			<item class="template|pending|orderset" id="xxx" tableid="xxx" >
//				<attribute .... />
//			</item>
//			<item class="orderset" id="xxx" tableid="xxx" >
//				<item class="template|pending|orderset" id="xxx" tableid="xxx" >
//					'
//			</item>
//			<item ......
//			</item>
//		</save>

	//Read through the XML document, which specifies the hierarchy of the 
	//items, and read the data for each item form each order form.	
	var objRoot = ordersXML.XMLDocument.selectSingleNode('root');		
	strReturn_XML = CollateDataFromChildForms(objRoot);
	if (strReturn_XML!="ERROR")
	{
	    strReturn_XML = '<save>' + strReturn_XML + '</save>';
	}
	return strReturn_XML;
}

//------------------------------------------------------------------------------------------------

// 05Sep07 MA  Gets the schedule date if we have entered it in our start date
function GetSimpleScheduleDate(formIndex)
{
	var tblScheduleBar = document.all[(SCHEDULEID_PREFIX + formIndex)];			//Reference to the appropriate schedule bar
	
	if (tblScheduleBar != null) {
	    var objDate = tblScheduleBar.all['txtRequestDate'];
	    var objTime = tblScheduleBar.all['txtRequestTime'];
    	
	    if ((objDate != undefined) && (objTime != undefined)) {
		    var strDate = objDate.value;
		    var strTime = objTime.value;
    		
		    if ((strDate != '') && (strTime != '')) {
    		
			    strDate = ParseDate(strDate, 'dd/mm/yyyy');
    			
			    if (TimeStringValidation(strTime, "") == "") {
			        return strDate + " " + strTime;	    
			    }
		    }
	    }
	}
	return null;
}


function CollateDataFromChildForms(objParentItem) {

/*
	30Apr04 PH  Moved the reading of the scheduleData xml island to after the call
					to GetDataFromForm(), because the NB custom control hacks data
					directly into this XML island during the GetData() call. This
					was done this way because there is no defined way for custom controls
					to update schedule data. We hope to improve this later.
					
	12Jun04 PH	Had to put the move of the reading of the scheduleData xml island back in again
					because it seems to have reverted by to "not being moved" again, somehow.
	
	16Jun04 AE  Moved call to GetDatafFromForm() upwards to allow custom controls to create default descriptions for templates
	04Oct04 AE  Added client-side validity checking. 
*/


var intCount = new Number();
var strReturn_XML = new String();
var strItem_XML = new String();
var colChildItems = new Object();
var scheduleXML = new String();
var strDataXML = new String();
var lngID = new Number();
var instanceData= new Object();
var objData = new Object();
var layoutData = new Object();
var scheduleData = new Object();
var formName = new String();
var lngTypeID = new Number();
var lngProductID = new Number();
var strDescription = new String();
var lngInReplyToID = new Number();
var lngCancelItemID = new Number();
var strReason = new String();
var strAnswer = '';
var strAttrTemplate_Copy = '';
var bitCalculatedDate = 0;
var strStartsAt = '';
var strOptionsDataXML = '';

	//Select nodes immediately below the parent item
	var colItems = objParentItem.selectNodes('item');
	for (intCount = 0; intCount < colItems.length; intCount ++) {
		strClass = colItems[intCount].getAttribute('dataclass')	
		intFormIndex = colItems[intCount].getAttribute('formindex');		
		formName = FORMID_PREFIX + intFormIndex;				
		//If the start date was calculated from dependancy information, we don't store it as it will be
		//reclaculated every time the item is accessed.  If it were set by the user, we store it in the
		//startsat attribute.
		bitCalculatedDate = colItems[intCount].getAttribute('calculated');																//05Dec06 AE  #DR-06-0019
		strStartsAt = bitCalculatedDate == '1' ? null : colItems[intCount].getAttribute('startsat');
		
		// 05Sep07 MA  Get the start date for this item
		if (strStartsAt == null) {
		    strStartsAt = GetSimpleScheduleDate(intCount);
		}
		
		// Hack to get immediate items to save dates as null
		if ( document.frames[formName].document.all['formXMLData'] != null )
		{
    		var formData = document.frames[formName].document.all['formXMLData'].XMLDocument.selectSingleNode ( 'root' );
        	if ( ( formData != null ) && ( formData.getAttribute ( 'lstScheduleIndex' ) != '1' ) )
    	        strStartsAt = null;
        }
    	    
		//Check for child items under this item
		colChildItems = colItems[intCount].selectNodes('item');
		
		if (colChildItems.length > 0) {
			//Item has children, so it is an Order set OR a request placholder
			//These have no data other than that held in the XML island, and possibly a schedule.
			//query the xml island for the data to append to the pending item row, as the ItemXML column						
			//LB we have two root nodes if we simply take the whole instance data so we get only the "data" node
			//strOptionsDataXML = window.frames[formName].document.all['instanceData'].XMLDocument.xml;
            strOptionsDataXML = window.frames[formName].document.all['instanceData'].XMLDocument.selectSingleNode('root/data').xml;

			//17-Jan-2008 JA Error code 162
			strItem_XML = '<item '
							+ 'description="' + XMLEscape(colItems[intCount].getAttribute('description')) + '" '
							+ 'tableid="' + colItems[intCount].getAttribute('tableid') + '" '
							+ 'id="' + colItems[intCount].getAttribute('id') + '" '
						    + 'ocstype="' + colItems[intCount].getAttribute('ocstype') + '" '
						    + 'ocstypeid="' + colItems[intCount].getAttribute('ocstypeid') + '" '	
						    + 'ordertemplateid="' + colItems[intCount].getAttribute('ordertemplateid') + '" '							   
							+ 'class="' + strClass + '" '
							+ 'requesttype="' + colItems[intCount].getAttribute('requesttype') + '" '
							+ 'mandatory="' + colItems[intCount].getAttribute('mandatory') + '" ' 										// 03Feb05  AE Also Added mandatory flag for ordersets
							+ 'lastupdateddate="' + colItems[intCount].getAttribute('lastupdateddate') + '" '
							+ 'ordersetitemid="' + colItems[intCount].getAttribute('ordersetitemid') + '" '
							+ 'indexorder="' + colItems[intCount].getAttribute('indexorder') + '" '
							+ 'startsat="' + strStartsAt + '" '																						//25Nov06 AE  #DR-06-0019 
							+ 'dependson="' + colItems[intCount].getAttribute('dependson') + '" '
							+ 'offsetminutes="' + colItems[intCount].getAttribute('offsetminutes') + '" '								//31Mar05 AE  persist dependancy information
							+ 'readonly="' + colItems[intCount].getAttribute('ReadOnly') + '" '										// 26Oct07 ST  If amending and its an orderset then this should be true
							+ '>'
						    + strOptionsDataXML;    //append the options data xml the the main row in the pending table



			//Get the schedule for this item ; this is held in the scheduleXML island on the order form		
			scheduleXML = '';																																//02Feb05 AE  Added schedules to Ordersets
			scheduleData = document.frames[formName].document.all['scheduleData'].XMLDocument;

			if (scheduleData.selectSingleNode('//Schedule') != undefined) {																//16May05 AE  Replaced root/ with //
			//We have a complex schedule
				scheduleXML = scheduleData.selectSingleNode('//Schedule').xml;
			}
			strItem_XML += scheduleXML;			

			//And retrieve the child items
			strItem_XML += CollateDataFromChildForms(colItems[intCount]);
			strItem_XML += '</item>';
			
		}
		else {
			//This is an item which holds data. 
			//Get references to the data islands on the appropriate form.

			//Read the data from this form
			strItem_XML = '';		
			if ( IsSharedPage(intFormIndex) )
			{
				strItem_XML = document.frames[formName].GetDataFromForm();
			}
			else if (!IsInfoPage(intFormIndex) ) {																														//10Feb05 AE  Added IsInfoPage
				instanceData = document.frames[formName].document.all['instanceData'].XMLDocument.selectSingleNode('root');
				objData = instanceData.selectSingleNode('data');
				layoutData = document.frames[formName].document.all['layoutData'].XMLDocument.selectSingleNode('xmldata/layout');

				strDataXML = document.frames[formName].GetDataFromForm();														//Moved call to GetDatafFromForm() upwards to allow custom controls to create default descriptions for templates
                if (strDataXML=="ERROR")
                    return strDataXML;
/*				
		12Jun04 PH	This used used to be here but I have now re-rem'd out...  again... for the 3rd time.
						I have moved the code further down this function to a point AFTER the call to
						GetDataFromForm(). This move had to be done because the PrescriptionRequest custom control
						updates the scheduleData xml island manually during the execution of GetDataFromForm().
						Consequently, if this code is not moved, then the modifications that the PrescriptioRequest
						control manually makes to the schedule data xml are not read, and thus not recorded in the DB,
						and you end up with a bug where the PrescriptionRequest start date (RequestDate) never gets
						saved properly, and gets defaulted as being "today's" date, rather than the actual date
						entered on the PrescriptionRequest form.

				//Get any schedule attached to this item
				scheduleXML = '';
				scheduleData = document.frames[formName].document.all['scheduleData'].XMLDocument;
				if (scheduleData.selectSingleNode('root/Schedule') != undefined) {
					//We have a complex schedule
					scheduleXML = scheduleData.selectSingleNode('root/Schedule').xml;
				}
				else {
					//We may have a simple start date/time entered
					scheduleXML = CreateOneOffSchedule(intFormIndex);
				}

*/
				lngID = instanceData.getAttribute('id');
				blnIsTemplate = IsTemplate(intCount);
				if (blnIsTemplate && colItems[intCount].getAttribute('dss') == '1' && document.body.getAttribute('mastermode') != 'true'){
					//This is a dss-maintained item, warn that they can only make a copy, not change it.
				    var strMsg = 'This item is maintained by the Decision Support Service, and you cannot change it.  '
								  + 'If you proceed, we will save a local version that you can use in your local formulary.  If you do this, '
								  + 'the item will no longer be updated by EHSC.'
					strAnswer = MessageBox('Dss Item', strMsg, 'OkCancel');
					switch (strAnswer){
						case 'y':	
							lngID = -1;											//Set ID to -1 to force creation of a new item
							strAttrTemplate_Copy = 'templateid_copy="' + instanceData.getAttribute('id') + '" ';
							break;
						
						default:													//Otherwise, just cancel and don't do a save
							return;
							break;
					}
				}

        		// Hack to get immediate items to save dates as null
                var DOMDataXML = new ActiveXObject('MSXML2.DOMDocument');
                DOMDataXML.loadXML ( strDataXML );

                // 10Oct08 PH Get the start time from the for data, if we don't have it already
                // 15Oct08 PH Also add more default time values, for when entered time is blank
                if (strStartsAt == null)
                {
                	strStartsAt = Date2ddmmccyy(new Date()) + ' ' + "00:00";
                	var xmlele = DOMDataXML.selectSingleNode('data/attribute[@name="StartDate"]');
                	if (xmlele != null)
                	{
                		var strDateAttrib = xmlele.getAttribute("value");
                		strStartsAt = strDateAttrib;
                		// 24Oct08 PH Check if strStartsAt is in TDate format, and if so convert into dd/mm/ccyy hh:mm, which sadly is used in so many places, it's hard  to change now :(
                		if (String(strStartsAt).indexOf("T", 0) >= 0)
                		{
                			strStartsAt = Date2ddmmccyy(TDate2Date(strStartsAt)) + " 00:00:00";
                		}
                		xmlele = DOMDataXML.selectSingleNode('data/attribute[@name="StartTime"]');
                		if (xmlele != null)
                		{
                			var strTime = xmlele.getAttribute("value");
                			if (strTime.length == 0) strTime = "00:00";
                			strStartsAt = Date2ddmmccyy(TDate2Date(strDateAttrib)) + " " + strTime + ":00";
                		}
                	}
                }

                var xmlStat = DOMDataXML.selectSingleNode('data/attribute[@name="STAT"]');
				var xmlScheduleIndex = DOMDataXML.selectSingleNode('data/attribute[@name="lstScheduleIndex"]');
				if ( ( xmlScheduleIndex != null ) && ( xmlScheduleIndex.getAttribute ( 'value' ) == '0' ) )
				{
				    if ( xmlStat.getAttribute ( 'value' ) == '0' )
				    {
				        var dtDate = new Date()
				        strStartsAt = Date2ddmmccyy ( dtDate ) + ' ' + dtDate.getHours() + ':' + dtDate.getMinutes();
				    }
                    else				        
                        strStartsAt = null;
				}
	
				//If the item is a new item, the id refers to the template used to create it.
				//Otherwise, the id will be the id of the item being edited, or -1 if this is a new template being created.
				strItem_XML = '<item '
							   + 'id="' + lngID + '" '
							   + 'tableid="' + layoutData.getAttribute('tableid') + '" '
							   + 'class="' + instanceData.getAttribute('class') + '" '
							   	+ 'isrx="' + colItems[intCount].getAttribute('isrx') + '" '							   
							   + 'ocstype="' + colItems[intCount].getAttribute('ocstype') + '" '
							   + 'ocstypeid="' + colItems[intCount].getAttribute('ocstypeid') + '" '
								+ 'ordersetitemid="' + colItems[intCount].getAttribute('ordersetitemid') + '" '
								+ 'indexorder="' + colItems[intCount].getAttribute('indexorder') + '" '
								+ 'startsat="' + strStartsAt + '" '																//25Nov06 AE  #DR-06-0019 
								+ 'dependson="' + colItems[intCount].getAttribute('dependson') + '" '
								+ 'offsetminutes="' + colItems[intCount].getAttribute('offsetminutes') + '" '													//31Mar05 AE  persist dependancy information
								+ 'dependancytypeid="' + colItems[intCount].getAttribute('dependancytypeid') + '" '													//14Oct08 PH persist MORE dependancy information
								+ 'ordertemplateid="' + colItems[intCount].getAttribute('ordertemplateid') + '" '							   			//07Feb05 AE  Added ordertemplateid  
								+ 'mandatory="' + colItems[intCount].getAttribute('mandatory') + '" ' 															//03Feb05  PH Added mandatory flag						   
								+ 'lastupdateddate="' + colItems[intCount].getAttribute('lastupdateddate') + '" '
								+ 'template="' + blnIsTemplate + '" ' 
								+ 'parentid_request="' + colItems[intCount].getAttribute('parentid') + '" '			// 25Oct07 ST	Orderset items need to know their committed orderset requestid
								+ strAttrTemplate_Copy;							
								
				//If this is a template, we must also send the description to the server.
				if (blnIsTemplate) {					
					//Certain items do not have a description; these are held in the constant DATACLASS_NO_DESCRIPTIONS
					if (DATACLASS_NO_DESCRIPTIONS.indexOf('|' + instanceData.getAttribute('class') + '|') == -1) {						//Don't prompt for descriptions for items which don't have one 19Nov04 AE 
						
						strDescription = GetDescription(intCount);
						strDescription = XMLEscape(strDescription);																//Escape the description to ensure the XML is valid
	
						//Note; we can also add long detail to each template, but this is implemented in the properties popup.
						//strItem_XML += 'detail="No Further Details" ';
						strItem_XML += 'detail="" ';																										//31Jan05 Removed
					}
					else {
						strDescription = 'N/A';	
					}
					
					strItem_XML += 'description="' + strDescription + '" ' ;

				}
				else {
					strItem_XML += 'description="' + XMLEscape(colItems[intCount].getAttribute('description')) + '" '
				}

				//If we have a productID, pass that as well; otherwise pass -1
				lngProductID = colItems[intCount].getAttribute('productid');
				if (lngProductID == null) {lngProductID = -1;}
				
				//If we are resulting / replying to a message or request, then we'll
				//have the ID of the thing we are replying to, so add that as well
				lngInReplyToID = colItems[intCount].getAttribute('inreplytoid');
				if (lngInReplyToID != null) { 
					strItem_XML += 'inreplytoid="' + lngInReplyToID + '" ';
				}

				//If this is a request cancellation, then pass the ID of the Request we are cancelling		
				lngCancelItemID = colItems[intCount].getAttribute('cancelrequestid');
				if (lngCancelItemID != null) {
					strItem_XML += 'cancelrequestid="' + lngCancelItemID + '" ';	
				}

				//If this is a note cancellation, then pass the ID of the Note we are cancelling		
				lngCancelItemID = colItems[intCount].getAttribute('cancelnoteid');
				if (lngCancelItemID != null) {
					strItem_XML += 'cancelnoteid="' + lngCancelItemID + '" ';	
				}

				//Add the pending reason, if any																						//04Mar04 AE added pending reason to order form
				strReason = objData.getAttribute('reason');
				if (strReason == null) {strReason = ''};
				strItem_XML += 'reason="' + strReason + '" ';

				//Add the autocommit flag; giving a pending reason overrides this
				strItem_XML += 'autocommit="';
				if (document.body.getAttribute("amendmode") == "true" && document.body.getAttribute("commitwhenamending") == "1")
				{
					// 10Oct08 Force auto-commit when amending
					strItem_XML += '1" ';
				}
				else if (strReason != '')
				{
					strItem_XML += '0" ';
				}
				else
				{
					strItem_XML += colItems[intCount].getAttribute('autocommit') + '" ';
				}

				//Finally add the productID, and the actual xml data	
				strItem_XML += 'productid="' + lngProductID + '" ' 
								+ '>'
							   + strDataXML;

/*
		12Jun04 PH	This is where the code got moved to! It likes being here. It's a warm snuggley place of happiness 
						and joy. Please dont move it. At least dont move it without checking if the PrescriptionRequest 
						custom control still saves its start date properly, after whatever change here is made.
*/
				//Get the schedule for this item ; this is held in the scheduleXML island on the order form
				scheduleXML = '';
				scheduleData = document.frames[formName].document.all['scheduleData'].XMLDocument;
				if (scheduleData.selectSingleNode('root/Schedule') != undefined) {
				//We have a complex schedule
					
					scheduleXML = scheduleData.selectSingleNode('root/Schedule').xml;
				}
				else 
				{
					// 05Sep07 ST  We get the start date/time from the form here
					// We may have a simple start date/time entered
				    if (!IsInfoPage(intCount) && !IsSharedPage(intCount))
					{
				        scheduleXML = CreateOneOffSchedule(intCount);
			        }
                }
                
				strItem_XML += scheduleXML;
				strItem_XML += '</item>';			
			}					
		}
		//Add this item to the return string
		strReturn_XML += strItem_XML;
	}
//Popmessage (strReturn_XML)
	return strReturn_XML;		

}

//-----------------------------------------------------------------------------------------------------
//												Saving Routines
//-----------------------------------------------------------------------------------------------------

function SaveAsTemplate(){
//24Oct06 AE  Added to make calling code clearer.  Templates actually go through the pending save method.
	return SaveAsPendingItem(true);
}
//-----------------------------------------------------------------------------------------------------
function SaveAsPendingItem(template) {

//Saves the data in the order form(s) as pending item(s).
//Collate the data from the various order forms and submit it to the server.
//  "template" parameter is true if the item is an order template / false if it is a pending item.
	
//15Feb06 AE  CheckAutoCommitStatus now returns a tristate (to support Dispensary mode)
//21May07 CJM Added check for ordering frequency

	//Gather data together in abundance.
	m_blnCancelSave = false;


	if (CheckDataValid()) {																											//04Oct03 AE Added validity checks for custom controls
		var sessionID = oeBody.getAttribute('sid');
		var enteredData_XML = CollateDataFromForms();

		var strContinue;
		if (enteredData_XML  != "ERROR")
		{
		    strContinue = CheckAutoCommitStatus(enteredData_XML);																//17Jan04 AE  Added Autocomplete facility	
		    if (DispensaryMode()){																												//22Feb06 AE  Added dispensary mode
			    var xmlSave = generalXML.XMLDocument.selectSingleNode('save');
			    xmlSave.setAttribute('dispensarymode', '1');
		    }
		    if (typeof(fraOCSToolbar)!='undefined')
		    {
			    fraOCSToolbar.MergeStatusNotesIntoFormData(generalXML);                                                                 // 24Feb06 Call method in Toolbar iframe to merge toolbar data into order data xml
		    }			
		    enteredData_XML = generalXML.xml;
		}
		else
		{
		    //Allow user to change the entry, so persist the form
		    strContinue ="x";
		}
		switch (strContinue){																										//15Feb06 AE  CheckAutocommitStatus now returns a tri state
			case 'y':
			//Go ahead and save
			
				//Lob it at the server.
				//Once the save is finished, the saver page indicates the results
				//back to this page.
				if (!m_blnCancelSave) {
					oeBody.style.cursor='wait';
					cmdOK.disabled = true;
					cmdCancel.disabled = true;
					if (document.all['cmdNotes'] != undefined) {
						cmdNotes.disabled = true;
					}
					if (document.all['cmdNext'] != undefined) {
						cmdPrevious.disabled = true;
						cmdNext.disabled = true;
					}
					
					m_saveMode = SAVE_PENDING;
					void ShowStatusMessage('Checking Item(s) and Saving, please wait...');															//23May05 AE  Replaced celStatus with ShowStatusMessage
					void document.frames['fraSave'].SaveBatch(sessionID, enteredData_XML);
					oeBody.style.cursor='default';
				}
				break;
				
			case 'c':
			//Close without saving
				void CloseWindow(false);
				break;		
				
			case 'x':
			//Cancel - go back to current form																													//16Aug06 AE  Added case for cancelled #DR-05-0127
				void SetFocusToForm();
				break;	
		}
	}
}

//------------------------------------------------------------------------------------------------------

function SaveAsResponse() {

//Saves the data in the form(s) as responses (or notes in a message thread).
//15Feb06 AE  CheckAutoCommitStatus now returns a tristate (to support Dispensary mode)

	m_blnCancelSave = false;

	if (CheckDataValid()) {																											//04Oct03 AE Added validity checks for custom controls
		//obtain the data from the forms
		var enteredData_XML = CollateDataFromForms();
		
		var strContinue = CheckAutoCommitStatus(enteredData_XML);																//17Jan04 AE  Added Autocomplete facility
		enteredData_XML = generalXML.xml;
		
		switch (strContinue){																												//15Feb06 AE  CheckAutocommitStatus now returns a tri state
			case 'y':
			//Send it to the server.
			//Once the save is finished, the saver page indicates the results
			//back to this page.
				if (!m_blnCancelSave) {
					var sessionID = oeBody.getAttribute('sid');
					oeBody.style.cursor='wait';
					cmdOK.disabled = true;
					cmdCancel.disabled = true;
					if (document.all['cmdNotes'] != undefined) {
						cmdNotes.disabled = true;
					}
					if (document.all['cmdNext'] != undefined) {
						cmdPrevious.disabled = true;
						cmdNext.disabled = true;
					}
					
					m_saveMode = SAVE_RESPONSE;
					void ShowStatusMessage('Saving, please wait...');																		//23May05 AE  Replaced celStatus with ShowStatusMessage
					void document.frames['fraSave'].SaveResponse(sessionID, enteredData_XML);
					oeBody.style.cursor='default';
				}
				break;
				
			case 'c':
			//Close without saving
				void CloseWindow(false);
				break;

			case 'x':
			//Cancel - go back to current form																													//16Aug06 AE  Added case for cancelled #DR-05-0127
				void SetFocusToForm();
				break;	
						
		}	
	}
}
//------------------------------------------------------------------------------------------------------

function SaveAsCancellation() {
	
//Saves the data in the form(s) as cancellation notes.	
	m_blnCancelSave = false;

	var enteredData_XML = CollateDataFromForms();

	//Check that all mandatory fields are filled in.  For this we load into yet another DOM...
	void generalXML.XMLDocument.loadXML(enteredData_XML);
	
	var colUnfilled = generalXML.XMLDocument.selectNodes('save/item/data[@filledin="false"]');
	if (colUnfilled.length > 0) {
		//At least one form is not filled in...we need to not let them continue.
		alert('All mandatory fields must be completed before this item can be saved.');
	}
	else {
		//Everything is filled in, so now we lob it at the server.
		//Once the save is finished, the saver page indicates the results
		//back to this page.
		var sessionID = oeBody.getAttribute('sid');

		if (!m_blnCancelSave) {
			//Copy the IDs of the request(s) we are cancelling as attribute elements into the DOM
			var xmlData = generalXML.XMLDocument.selectSingleNode('save/item/data');
			var colRequestIDs = ordersXML.XMLDocument.selectNodes('root/item/attribute[@name="cancelrequestid"]');
			for (i=0; i < colRequestIDs.length; i++){
				xmlData.appendChild (colRequestIDs[i].cloneNode(false));	
			}
			var colNoteIDs = ordersXML.XMLDocument.selectNodes('root/item/attribute[@name="cancelnoteid"]');
			for (i=0; i < colNoteIDs.length; i++){
				xmlData.appendChild (colNoteIDs[i].cloneNode(false));	
			}
			enteredData_XML = generalXML.XMLDocument.xml;
			
			oeBody.style.cursor='wait';
			cmdOK.disabled = true;
			cmdCancel.disabled = true;
			if (document.all['cmdNotes'] != undefined) {
				cmdNotes.disabled = true;
			}
			if (document.all['cmdNext'] != undefined) {
				cmdPrevious.disabled = true;
				cmdNext.disabled = true;
			}
			m_saveMode = SAVE_CANCELLATION;
			void ShowStatusMessage('Saving, please wait...');																		//23May05 AE  Replaced celStatus with ShowStatusMessage
			void document.frames['fraSave'].SaveCancellation(sessionID, enteredData_XML);
			oeBody.style.cursor='default';
		}
	}		
}

//------------------------------------------------------------------------------------------------------
//After items are saved, before calling SaveComplete, check if any immediate stat doses are to be administered
function CheckImmediateAdministrationOfSTAT() {
    //F0019394  ST 17Apr09 Check setting for immediate admin prompt and just return if its true.
    var strReturn;
    if (document.body.getAttribute("immediateadmin") == "False") {
        var Url = '../DrugAdministration/ImmediateAdmin_Modal.aspx'
		    + '?SessionID=' + document.body.getAttribute('sid')
		    + '&Phase=startfast';

        var Features = 'dialogHeight:300px;'
		    + 'dialogWidth:450px;'
		    + 'resizable:no;unadorned:no;'
		    + 'status:no;help:no;';

        
		strReturn = window.showModalDialog(Url, '', Features);
		if (strReturn == 'logoutFromActivityTimeout') {
			strReturn = null;
			window.close();
			window.parent.close();
			window.parent.ICWWindow().Exit();
		}

    }
	return(strReturn);
}
//------------------------------------------------------------------------------------------------------

function SaveComplete(blnSuccess,navigateaway) {
//Fires when the save page has finished saving.  It contains
//an XML Island which holds the details of the success / failiure
//of each item in the 

	//if (document.getElementById("cmdCancel")!=null) cmdCancel.disabled = false;
	//if (document.getElementById("cmdOK")!=null) cmdOK.disabled = false;
	
	if (blnSuccess) {
		//Just close the window, & return the details
		//of what was saved.	
		void ShowStatusMessage('');																					//23May05 AE  Replaced celStatus with ShowStatusMessage
		window.returnValue = document.frames['fraSave'].saveData.XMLDocument.xml;

		if (document.body.getAttribute('embedded') == 'true') {
		    //28Apr04 AE  Added; moved GoToDesktop here to allow error reporting in embedded mode.
		    //26Oct2009 JMei F0066887 F0066888 Don't go back to desktop when navigating away this page
		    if (navigateaway != true) {
		        void GoToDesktop();
		    }
		}
		else {
			void CloseWindow(false);
		}			
	}
	else {
		//Something failed; show the error report
		void ShowStatusMessage('');																		//23May05 AE  Replaced celStatus with ShowStatusMessage
		void ShowSaveResults();		
	}
}

//------------------------------------------------------------------------------------------------------

function ShowSaveResults() {

//Display the save results, held on the saver page.
//22Jul05 AE  Now uses standard SaveResults page.
	void DisplaySaveResults(document.all['fraSave'], document.body.offsetTop, document.body.offsetLeft, document.body.offsetWidth, document.body.offsetHeight);	
}

//---------------------------------------------------------------------------------------------------------
function DssResults_onClick(blnContinueAnyway)
{
	//Event handler for the SaveResults page
	if (blnContinueAnyway)
	{
		//F0045745 In case of the "Yes" button on DSS warnning Div was clicked, those two buttons on order entry should be disabled
		if (document.getElementById("cmdCancel") != null) cmdCancel.disabled = true;
		if (document.getElementById("cmdOK") != null) cmdOK.disabled = true;
		//User has seen warnings, and chosen to override them
		//Find the ID of the item which failed (on the save page)
		var failedItem = document.frames['fraSave'].document.all['failedData'].XMLDocument.selectSingleNode('//item');
		if (failedItem != undefined)
		{
			var lngPendingItemID = failedItem.getAttribute('id');
			var OnCommitWarningLog = document.frames['fraSave'].document.all['dsslogresults'].XMLDocument.selectSingleNode('//LogEntry');
			var OnCommitWarningLogID = OnCommitWarningLog.getAttribute('LogID');

			//get a reason for overridding warning
			// entire block commented out until spec has been done
			//var strReturn = DSSOverrideReason();

			//var itemReason = generalXML.XMLDocument.selectSingleNode('//data');

			//var dssOverrideNoteNode = itemReason.appendChild(generalXML.XMLDocument.createElement("dssoverridenote"));
			//var dssReasonNode = dssOverrideNoteNode.appendChild(generalXML.XMLDocument.createElement("reasonnote"));
			//var dssDataNode = dssReasonNode.appendChild(generalXML.XMLDocument.createElement("data"));
			//var dssAttribNode = dssDataNode.appendChild(generalXML.XMLDocument.createElement("attribute"));
			//dssAttribNode.setAttribute("name", "XML")
			//dssAttribNode.setAttribute("value", strReturn);

			//Now flag the appropriate item on this page as "to be saved anyway"
			//Now flag the appropriate item on this page as "to be saved anyway"

			// 14Oct08 When auto-committing, the ID in "failedItem" will be an OrderTemplateID, NOT a PendingItemID,
			//			and may therefore not be unique if an OrderTemplate occurs more than once in an OrderSet.
			//			The SaveDialog roundtrips to the server for each DSS warning that it receives! Each time it marks the next
			//			warned item with a overridewarning="1" attribute. Because of this, we'll also have to search for the 
			//			"overridewarning" attribute not existing in the generalXML, in order to find the next failed item.
			var itemToBeSaved = generalXML.XMLDocument.selectSingleNode('//item[@id="' + lngPendingItemID + '" and not(@overridewarning)]');
			void itemToBeSaved.setAttribute('overridewarning', '1');
			void itemToBeSaved.setAttribute('oncommitwarninglogid', OnCommitWarningLogID);

			//And run the save again
			var sessionID = document.body.getAttribute('sid');
			var enteredData_XML = generalXML.xml;
			void ShowStatusMessage('Saving...');

			switch (m_saveMode)
			{
				case SAVE_PENDING:
					void document.frames['fraSave'].SaveBatch(sessionID, enteredData_XML);
					break;

				case SAVE_RESPONSE:
					void document.frames['fraSave'].SaveResponse(sessionID, enteredData_XML);
					break;

				case SAVE_CANCEL:
					void document.frames['fraSave'].SaveCancellation(sessionID, enteredData_XML);
					break;
			}

		}
		else
		{
			//Should never be able to get here; an item has failed, but we
			//don't know which one.
			alert('Cannot resave; item ID not returned.');
			// 14Aug07 PH Don't close the window and lose their data, give 'em another chance at saving it!
			//			void CloseWindow(true);			
		}


	}
	else
	{
		//F0045745 In case of the "No" button on DSS warnning Div was clicked, those two buttons on order entry should be enabled 
		if (document.getElementById("cmdCancel") != null) cmdCancel.disabled = false;
		if (document.getElementById("cmdOK") != null) cmdOK.disabled = false;
		//Just close the window
		void ShowStatusMessage('');
		if (document.body.getAttribute('embedded') == 'true')
		{
			void GoToDesktop();
		}
		else
		{
			// 14Aug07 PH Don't close the window and lose their data, give 'em another chance at saving it!
			//			void CloseWindow(false);		
		}
	}
}

//===============================================================================================================
function DSSOverrideReason()
{
	var Url = '../NotesEditor/EditNote.aspx'
		+ '?SessionID=' + document.body.getAttribute('sid')
		+ '&NoteID=-1'
		+ '&TableName=DSSWarningNote';
				
	var Features = 'dialogHeight:400px;' 
		+ 'dialogWidth:720px;'
		+ 'resizable:no;unadorned:no;'
		+ 'status:no;help:no;';		
		
	var strReturn = window.showModalDialog(Url, '', Features);
	if (strReturn == 'logoutFromActivityTimeout') {
		window.returnValue  = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}
	return(strReturn);
}

//---------------------------------------------------------------------------------------------------------
function SettingSaveComplete(blnSuccess){
//13Apr05 AE  Required event handler, nothing to do though.	
}

//--------------------------------------------------------------------------------------------------------

function GetDescription(intFormIndex) {

//For use when entering a template.
//Read the description from the html, and prompt to allow the user to change it.	
	
//09Aug05 AE  Corrected behaviour on cancelling
var strDescription = '';
var strTextFixed = '';
var strPrompt='';
var minChars = 0;

	var numForms = CountOrderForms();
//	if (numForms == 1) {
//		strDescription = spnItemTitle.innerText;
//	}
//	else {
//		strDescription = spnItemTitle[intFormIndex].innerText	
//	}
	
	var objItem = ordersXML.XMLDocument.selectSingleNode('root//item[@formindex="' + intFormIndex + '"]');
	var blnIsRx = (objItem.getAttribute('isrx') == '1');

	do {
	    //F0095890 07Sep10 ST Moved getting the description inside the loop so that it is repopulated when the input dialog is
	    //redisplayed if the user does not enter the mandatory text.
	    if (numForms == 1) 
	    {
	        strDescription = spnItemTitle.innerText;
	    }
	    else {
	        strDescription = spnItemTitle[intFormIndex].innerText	
	    }

	    //strDescription = window.prompt("Please enter a description for this template", strDescription)
		if (blnIsRx) {
			strTextFixed = strDescription;
			strDescription = '';
			strPrompt = 'Enter any supplementary information for this dose';
			minChars = MIN_DESCRIPTION_CHARS_PRODUCT;
		}
		else {
			strPrompt = 'Enter a description for this template';
			minChars = MIN_DESCRIPTION_CHARS;
		}
		var Url = 'DescriptionPrompt.aspx'
					  + '?Title=Enter Description'
					  + '&Prompt=' + strPrompt
					  + '&Text=' + strDescription
					  + '&TextFixed=' + strTextFixed;
					  
		strDescription = window.showModalDialog(Url);
		if (strDescription == 'logoutFromActivityTimeout') {
			strDescription = null;
			window.close();
			window.parent.close();
			window.parent.ICWWindow().Exit();
		}

		if (strDescription == null) break;																//null = cancelled
		if (strDescription.length < minChars || strDescription.length > MAX_DESCRIPTION_CHARS) 
		{
		    alert('Description must be between ' + minChars + ' - ' + MAX_DESCRIPTION_CHARS + ' characters long');
		}
	}
	while (strDescription.length < minChars || strDescription.length > MAX_DESCRIPTION_CHARS) 
	
	m_blnCancelSave = (strDescription == null);
	return strDescription;
	
}

//--------------------------------------------------------------------------------------------------------

function IsTemplate(intFormIndex) {
	
//Returns 1 if the given form is for a template, 0 otherwise

	var bitReturn = 0;
	var numForms = CountOrderForms();
	if (numForms == 1) {
		bitReturn = (orderFormDiv.getAttribute("template") == '1')
	}
	else {
		bitReturn = orderFormDiv[intFormIndex].getAttribute("template")
	}

	if (bitReturn == null) {bitReturn = 0;}
	return eval(bitReturn);

}
//---------------------------------------------------------------------------------------------------------

function CheckAutoCommitStatus(strXML) {
//Checks the batch of items for any which are marked for auto committing.
//If any are found, we first check that they are filled in.
//If any are part of an orderset, then the whole orderset will be autocommitted
//if everything is filled in; otherwise it will go into the pending tray as usual.
//If a required item is not filled in, we show a warning message. 
//Function returns:
//	 'c' - Indicates close; Order Entry should be closed, without saving changes.
//	 'x' - Indicates cancel; take no further action
//	 'y' - Indicates carry on and save.

//15Nov04 AE  Added newlines to format message properly.
//16Feb06 AE  Modified to return a tristate instead of boolean.  Added checks for DispensaryMode.
	
var objData = new Object();
	
var intCount = new Number();
var intSetItem = new Number();
var strMsg = new String();
var strOrdersetMsg = new String();
var strReturn = new String();
var strAnswer = '';
var strXPath = '';
var IgnorePending = document.body.getAttribute("ignorepending");
	var blnDispensaryMode = DispensaryMode();
    void generalXML.XMLDocument.loadXML (strXML);
	if (!blnDispensaryMode){
		var colItemsToCommitInOrderset = generalXML.XMLDocument.selectNodes('//item/item[@autocommit="1"]');
		for (intCount = 0; intCount < colItemsToCommitInOrderset.length; intCount ++) {
			//Flag each item in an orderset that has an item to autocommit in for autocommit themselves;
			//we must do "all or nothing" (can't commit half an orderset)
			void colItemsToCommitInOrderset[intCount].parentNode.setAttribute('autocommit', '1');
			void MarkChildItemsForCommit (colItemsToCommitInOrderset[intCount].parentNode, 1);
		}
	
		//We've now marked everything required for autocommit; now check that they are filled in.
		var colItemsToCommit = generalXML.XMLDocument.selectNodes('//item[not (item)][@autocommit="1"]');							//all non-orderset items marked for autocommit
		for (intCount = 0; intCount < colItemsToCommit.length; intCount ++) {
			objData = colItemsToCommit[intCount].selectSingleNode('data');
			if (objData.getAttribute('filledin') != 'true') {
				//This one isn't filled in.  Add it to the appropriate message string, and unmark it
				//since it cannot be committed.
				if (colItemsToCommit[intCount].parentNode.nodeName == 'item') {
					//this is in an orderset
					strOrdersetMsg += '\n\t<b>' + colItemsToCommit[intCount].getAttribute('description') +'\t'
										+ '(in ' + colItemsToCommit[intCount].parentNode.getAttribute('description') + ')</b>';
					//Unmark the orderset, and all of its children
					void colItemsToCommit[intCount].parentNode.setAttribute('autocommit', 0);
					void MarkChildItemsForCommit (colItemsToCommit[intCount].parentNode, 0);
	
				}
				else {
				    //singleton item
				    strMsg += '\n\t<b>' + XMLReturn(colItemsToCommit[intCount].getAttribute('description')) + '</b>\n\n';

                    if (IsSMS())
				    {
				        var missingItems = CheckSMSMandatoryItems(colItemsToCommit[intCount]);

				        if (missingItems != "") {
				            strMsg += '\n' + missingItems;
				    }
				}

			    //Unmark the commit flag.
					void colItemsToCommit[intCount].setAttribute('autocommit', 0);		
				}
			}
		}
	}
	else {
	//In dispensary mode, everything is auto-autocommitted.  So anything not being filled in stops the process.									//21Feb06 AE  Autocommit everything in dispensary mode
	    var colItemsToCommit = generalXML.XMLDocument.selectNodes('//item');																	//10Mar06 AE  Added [not (item)]
	    for (intCount = 0; intCount < colItemsToCommit.length; intCount++) {

	        var colChildren = colItemsToCommit[intCount].selectNodes('item'); 		                                                        //12Nov09 AE  Last fix ever??  Ensure ordersets are marked as autocommit														//12Nov09 AE  Last fix ever??  Ensure ordersets are marked as autocommit
	        if (colChildren.length > 0) {
	            //this is an orderset, just flag it as autocommit
	            colItemsToCommit[intCount].setAttribute('autocommit', '1');
	        }
	        else {
	        //non-ordersets; check the filled in flag
		
			    objData = colItemsToCommit[intCount].selectSingleNode('data');
			    void colItemsToCommit[intCount].setAttribute('autocommit', '1');
			    if (objData.getAttribute('filledin') != 'true') {
			        strMsg += '\n\t<b>' + colItemsToCommit[intCount].getAttribute('description') + '</b>\n\n';
			    }
		    }
		}
	}
		
	//Now, tell the user if necessary.
	strReturn = 'y';	
	if (strMsg != '') {
		if (!blnDispensaryMode && !IgnorePending){		
			strMsg = 'The following item(s) are not complete, and will be saved as pending items.\n\n'
					 + strMsg 
					 + 'Choose OK to save as pending items, or Cancel to go back and fill in the \n'
					 + 'required fields.';
			strReturn = MessageBox('Warning', strMsg, 'okcancel', '');
		}
		else {
		    if (!IsSMS()) {
		        strMsg = 'The following item(s) are not complete.\n\n'
					 + strMsg
					 + 'Do you really wish to exit and lose changes?';
		    }
		    else {
		        strMsg = 'The following item(s) are not complete.\n\n'
    		        + strMsg;
		    }
		    if (!IsSMS()) {
		        strAnswer = MessageBox('Warning', strMsg, 'yesno', '');
		        if (strAnswer == 'y') {
		            strReturn = 'c'; //Yes they want to exit, return 'c' -> Exit without saving
		        }
		        else {
		            strReturn = 'x'; //No they don't want to exit, return 'x' -> cancel, ie do nothing
		        }
		    }
		    else {
		        MessageBox('Warning', strMsg, 'ok', '');
		        strReturn = 'x';
		    }
		}
	}
	else {
		if (strOrdersetMsg != '') {
			strOrdersetMsg = 'The following item(s) are not complete. if not completed, the.\n'
								 + 'entire orderset will be saved as pending items.\n\n'
								 + strOrdersetMsg + '\n\n'
								 + 'Choose OK to save as pending items, or Cancel to go back and fill in the \n'
								 + 'required fields.';
			strReturn = MessageBox('Warning', strOrdersetMsg, 'okcancel', '');
		}
	}		

	
	return strReturn;
	
}

//---------------------------------------------------------------------------------------------------------

function MarkChildItemsForCommit (objParent, bitCommit) {
	
//Marks each <item> under objParent with the autocommit flag,
//set to the value of blnCommit.
//recurses to mark children of children.
	
var intCount = new Number();
var colMoreChildren = new Object();
	
	var colChildren = objParent.selectNodes('item');
	for (intCount = 0; intCount < colChildren.length; intCount ++) {
		void colChildren[intCount].setAttribute('autocommit', bitCommit);
		colMoreChildren = colChildren[intCount].selectNodes('item');
		
		//Mark children of this item, if any
		if (colMoreChildren.length > 0) {
			void MarkChildrenForCommit (colChildren[intCount]);
		}
	}
	
}

//---------------------------------------------------------------------------------------------------------
function DispensaryMode(){
	return (document.body.getAttribute('dispensarymode') == 'true');
}

function CheckSMSMandatoryItems(item) {
    var missingItems = '<b>It is missing the following mandatory items:\r</b>';
    var dataAttribute;
    var incomplete = false;

    dataAttribute = item.selectSingleNode('//data/attribute[@name="ProductID"]/@value').value;
    if (dataAttribute == "" || Number(dataAttribute) == 0) {
        incomplete = true;
        missingItems += "\rProduct";
    }

    dataAttribute = item.selectSingleNode('//data/attribute[@name="Strength"]/@value').value;
    if (dataAttribute == "" || Number(dataAttribute) == 0) {
        incomplete = true;
        missingItems += "\rProduct Strength";
    }

    if (item.selectSingleNode('//data/attribute[@name="ProductFormID"]') != null) {
        dataAttribute = item.selectSingleNode('//data/attribute[@name="ProductFormID"]/@value').value;
        if (dataAttribute == "" || Number(dataAttribute) == 0) {
            incomplete = true;
            missingItems += "\rProduct Form";
        }
    }
    
    dataAttribute = item.selectSingleNode('//data/attribute[@name="ProductRouteID"]/@value').value;
    if (dataAttribute == "" || Number(dataAttribute) == 0) {
        incomplete = true;
        missingItems += "\rProduct Route";
    }

    dataAttribute = item.selectSingleNode('//data/attribute[@name="StartDate"]/@value').value;
    if (dataAttribute == "" || Number(dataAttribute) == 0) {
        incomplete = true;
        missingItems += "\rStart Date";
    }

    dataAttribute = item.selectSingleNode('//data/attribute[@name="Dose"]/@value').value;
    if (dataAttribute == "" || Number(dataAttribute) == 0) {
        incomplete = true;
        missingItems += "\rDose";
    }

    missingItems += "\r\r";

    if (incomplete) {
         return missingItems;
    }
    else {
        return "";
    }
}

function IsSMS() {
    var sms = document.frames['orderForm0'].document.frames[0].document.body.getAttribute('sms');
    
    if (sms != null && sms != "") {
        return (sms.toLowerCase() == "true");
    }

    return false;
}