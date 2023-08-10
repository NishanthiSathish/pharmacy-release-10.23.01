//------------------------------------------------------------------------------------------------
//
//									ORDER ENTRY SCRIPT
//
//	This script handles initialising and resizing of the OrderEntry container (not the order
// forms themselves, that is handled in OrderFormResizing.js).
//	It deals with navigating backwards and forwards through a batch of 
// forms, as well as data gathering and submission.
//	It also handles the various pop-up panels such as the index.
//
//	Modification History:
// 30Apr03 AE  GetSkipCompletedForms:  Ensure we return a boolean, not string. 
//	19May03 AE  NavigateToForm:  Added calls to HideSchedulerControls and associated code
//	30May03 AE  Split script into two in an attempt to solve bizarre behaviour where errors do
//					not appear, but just stop the script running.  This script now only deals
//					with navigation/display, all data handling and communication is done in 
//					OrderEntryDataManipulation.js
//	15Aug03 AE  Improved initialisation behaviour, to go to the first unedited form.
//	27Aug03 AE  Explicitly co-erce m_currentFormIndex to Number before incrementing/decrementing.
//					Had suddenly started coercing to string, after months of working fine. Weird.
//	04Sep03 AE  Added SetChanged(); now checks for edits, so you don't get asked "really cancel" if 
//					you haven't changed anything.
//	12Dec03 AE  NavigateToForm: Ensure forms which are too big are at least resized
//	25Jan05 AE  Multiple fixes for ordersets in ordersets.
//	27Jan05 AE  Added info pages for ordersets; these are now shown in the index also.
//					Fixes for date/time shuffling and initialisation.
//					Added loading status message.
//	19Apr05 AE  Improved rendering in stacked view.  Improved functionally, the code 5ux0r5
//	21Apr05 AE 	Fixed m_currentFormIndex sync problem (#80060)
//	03Oct05 AE  Focus on OK button if only one form and it is filled in.
//  14Feb06 ST  Fixed focus/caret problem with first field and OK button
//	25Jul06 PH  Adding locking
//	25May07 PH  ViewMode now loads forms on demand
//------------------------------------------------------------------------------------------------

// Constants for highlighting style changes:
var INDEX_HIGHLIGHT_BGCOLOUR = "#00599C"
var INDEX_HIGHLIGHT_COLOUR = "#ffffff"
var FILTER_GREYSCALE = "progid:DXImageTransform.Microsoft.BasicImage(grayscale=1)";
var BACKGROUND_ACTIVE = '#ffffff';
var BACKGROUND_INACTIVE = '#c0c0c0';

//Constants for building IDs
var FORMID_PREFIX = 'orderForm';
var SCHEDULEID_PREFIX = "scheduleBar";

//Popmenu constants
var VIEW_STANDARD = 10;
var VIEW_STACKED = 20;

//Sizing stuff
var FORM_PADDING = 5;													//Padding added to the bottom of each form in stack mode

//page-level variables:
var m_currentFormIndex= new Number(-1);
var m_currentView = VIEW_STANDARD;
var m_blnInitialised = false;
var m_initialisedCount = 0;
var m_populateCount = -1;
var m_blnEditMade = false;

var m_StartTime;

//
// 14Dec07 ST - Changed status note toolbar iframe src to be set here where the main orderentry page has finished loading.
//
function orderentry_onload()
{
	var iframe_toolbar = document.getElementById("fraOCSToolbar");
	var SessionID = Number(document.body.getAttribute("sid"));
	var PendingMode = document.body.getAttribute("pendingmode");

	if (iframe_toolbar != null || iframe_toolbar != undefined)
	{
		iframe_toolbar.src = "../OrderEntry/OrderFormStatusToolbar.aspx?SessionID=" + SessionID + "&PendingMode=" + PendingMode;
	}
}

//------------------------------------------------------------------------------------------------
//										Initialisation Routines
//------------------------------------------------------------------------------------------------
function IndicateOrderFormReady(intOrdinal)
{
	//called from each order form as each one finishes initialising.	
	//Once all are loaded, this kicks off the initialisation process.

	var blnDisplayMode = (document.body.getAttribute("display") == 'true')

	if (intOrdinal == -1) // -1 indicates that this message has come from the toolbar, and not from an actual valid form window.
	{
		if ((m_initialisedCount < numForms + 1) && (m_currentFormIndex < 0))
		{
			m_initialisedCount++;
			return;
		}
	}

	if (false) //blnDisplayMode) // PH 20Jul07 Turned off load-on-demand feature
	{
		m_blnInitialised = true;

		tblMain.style.visibility = 'visible';

		EnableIndexAndButtons();

		if (typeof (intOrdinal) == "undefined")
		{
			intOrdinal = 0;
		}
		if (intOrdinal >= 0)
		{
			m_currentFormIndex = intOrdinal;
		}
		if (m_currentFormIndex >= 0)
		{
			var EndTime = (new Date()).getTime();

			//			alert(VBTimer() + " (" + ( EndTime - m_StartTime ) + ")");

			NavigateToForm(m_currentFormIndex);
		}
	}

	if (!m_blnInitialised)
	{
		//m_blnInitialised is used to ensure we only 
		//go through the init process once.
		//Increment the intialised count
		//if (intOrdinal!=-1)  SC-07-0385 CJM removed as this is stopping the form closing if the toolbar is loaded last
		//{
		m_initialisedCount++;
		//}
		//If all forms now initialised, perform the rest of the initialisation process
		var numForms = CountOrderForms();
		void ShowStatusMessage(document.body.getAttribute('loadingmessage') + 'loading page ' + m_initialisedCount + ' of ' + numForms); 				//23May05 AE  Replaced celStatus with ShowStatusMessage
		//		celStatus.innerText = ('loading page ' + m_initialisedCount + ' of ' + numForms);			//27Jan05 AE  Added loading message
		if (m_initialisedCount >= numForms + 1)
		{
			m_blnInitialised = true;
			void ShowStatusMessage(''); 																					//23May05 AE  Replaced celStatus with ShowStatusMessage
			void DoInitialisation();
		}
	}
}

//------------------------------------------------------------------------------------------------

function DoInitialisation()
{
	//Runs through the start-up process.  This is
	//called once all the order forms are loaded and
	//ready
	var moveOK = false;
	var intCount = 0;
	var numFormCount = 0;

	// F0034943
	// 14Oct08  ST  As the allergy editor has been changed to how it is now it relies upon certain aspects of order entry, which in this instance
	// do nothing on the allergy editor page except cause errors when double clicking products.
	// This simply checks to see if the loaded page is the allergy reactions editor and if so bypasses this code. - call it a hack, fudge or whatever but it should have been written right in the first place.
	if (document.body.getAttribute("id") == 'bdyAllergyReactions')
	{
		return;
	}

	spnLoadingTitle.style.display = 'none';
	tblMain.style.visibility = 'visible';
	void SetImmediateInfo();
	//For order set items, update the start date/time according	
	//to the offsets in the order set definition
	void UpdateStartTimes();
	//Move to the first form for editing.
	//This is either:
	//If all items are already in progress, the first non complete form, (or the first form if all are complete)
	//OR, the first new item, whether complete (if it contains all optional fields) or not.

	var objNewItem = ordersXML.XMLDocument.selectSingleNode('root//item[(@dataclass="template") or (@dataclass="orderset")]'); 		//12Aug04 AE  Corrected to use root//item so that items in ordersets are included in the search. Fixes #75830
	if (objNewItem != null)
	{
		//We have at least one brand new item; move to it.	
		moveOK = NavigateToForm(Number(objNewItem.getAttribute('formindex'))); 								//21Apr05 AE  Set moveOK; was always starting in the wrong place, causing issues with orderset date shuffling  #80060
	}
	else
	{
		if (document.body.getAttribute('display') == 'true')
		{																//13Apr05 AE  Prevent skipping first form in display mode
			//In display mode, always highlight the first form
			moveOK = NavigateToForm(0);
		}
		else
		{
			//Edit mode, move to the first incomplete form, or first form if all are complete
			moveOK = MoveFormNext(true);
		}
	}
	// F0095197 26Aug10 ST Moved back as should be here
	if (!moveOK)
	{																														//31Aug04 AE  Corrected; MoveFormNext's return value is more accurate than the old method of checking m_currentFormIndex
		//Move failed;
		//Just highlight the first one in this case
		void NavigateToForm(0);
	}
	void UpdateIndexClasses();
	void ShowWarnings();
	void EnableButtons();
	//Enable scrolling; this is disabled when loading to prevent flickering
	scrollWindow.style.overflowY = 'auto';

	//Arrange the form into the default view.
	m_currentView = VIEW_STANDARD;
	if (document.body.getAttribute('defaultview') == 'stacked')
	{
		m_currentView = VIEW_STACKED
		void FormArrange_Stacked(false);
	}

	//If cancelled, show the status pane by default
	if (document.body.getAttribute('display') == 'true' && !IsInfoPage(m_currentFormIndex) && !IsSharedPage(m_currentFormIndex))
	{				//27Jan05 AE  Added Orderset title page
		var strFormName = 'orderForm' + m_currentFormIndex;
		var objDOM = document.frames[strFormName].document.all['instanceData'].XMLDocument;
		var objStatus = objDOM.selectSingleNode('root/info/attribute[@name="status"]');
		if (StatusIsCancel(objStatus) || StatusIsDiscontinued(objStatus))
		{
			void OpenStatusPane();
		}
	}

	EnableIndexAndButtons();

	//Focus on the OK button if there's only one form and it's complete
	if (CountOrderForms() == 1 && FilledIn(0))
	{
		cmdCancel.setActive();      // 14Feb06 ST   For some reason the cmdOK button doesn't receive the focus and the caret is left in the first edit
		cmdOK.setActive();          // 14Feb06 ST   so we set cmdCancel to active and then set cmdOK active and then the focus
		cmdOK.focus(); 			// 03Oct05 AE   Focus on OK button
	}

	//25Aug10 JMei F0094955 fix script error when no form error occur and disable the OK button in that case
	if (IsTemplateMode() && !moveOK)
	{																														//31Aug04 AE  Corrected; MoveFormNext's return value is more accurate than the old method of checking m_currentFormIndex
		//Move failed;
		//Just highlight the first one in this case
		void NavigateToForm(0);
		cmdOK.disabled = true;
	}

	//Debug; show the loading time:
	if (document.body.getAttribute('showloadingtime') == 'true')
	{
		var dtFinish = new Date()
		var msStart = document.body.getAttribute('starttime')
		var msFinish = (dtFinish.getMilliseconds() + (dtFinish.getSeconds() * 1000) + (dtFinish.getMinutes() * 60000) + (dtFinish.getHours() * 3600000));
		void ShowStatusMessage('loaded in ' + eval(msFinish - msStart) + ' ms');
	}

	//    alert( ordersXML.xml );

	// 07Jul07 ST  Navigate to Shared Info Page When Loaded
	numFormCount = CountOrderForms();
	if (intCount > -1)
	{
		NavigateToForm(0);
	}


	for (intCount = 0; intCount < numFormCount; intCount++)
	{
		if (IsSharedPage(intCount))
		{
			NavigateToForm(intCount);
			break;
		}
	}
}

//-------------------------------------------------------------------------------------------------

function EnableIndexAndButtons()
{
	// 25May07 PH Enables the index of forms and the ok and cancel buttons
	//Enable the index																											//27Jan05 AE  Disable index until all pages are loaded.
	if (CountOrderForms() > 1)
	{
		for (intCount = 0; intCount < orderIndexRow.length; intCount++)
		{
			orderIndexRow[intCount].disabled = false;
		}
	}

	//Enable the OK/Cancel buttons																							//26Jan05 Buttons disabled until initialised
	if (document.all['cmdOK'] != undefined) cmdOK.disabled = false;
	if (document.all['cmdCancel'] != undefined) cmdCancel.disabled = false;
}

//-------------------------------------------------------------------------------------------------
function EnableButtons()
{
	//On initialisation, enables those buttons which should be enabled.
	//They are initially disabled to prevent clicking before everything is loaded.	

	var blnDisplay = (document.body.getAttribute('display') == 'true');
	var blnRespond = (document.body.getAttribute('respond') == 'true');
	var blnCopyMode = (document.body.getAttribute('copymode') == 'true'); //17-Jan-2008 JA Error code 162
	var blnAmendMode = (document.body.getAttribute('amendmode') == 'true');
	var blnPendingMode = (document.body.getAttribute('pendingmode').toLowerCase() == 'true');

	//F0078405 ST 18May10 Updated to pick up 1 as well as true
	var blnAutoCommitWhenAmend = (document.body.getAttribute('commitwhenamending') == 'true' || document.body.getAttribute('commitwhenamending') == '1');

	var numForms = CountOrderForms();

	//Enable the buttons appropriately
	//Notes
	if (document.all['cmdNotes'] != undefined)
	{
		cmdNotes.disabled = false;
		if (numForms > 1) { cmdView.disabled = false };
		if (blnRespond)
		{
			cmdNotes.disabled = true;
		}
		//if (IsInfoPage(m_currentFormIndex) || IsSharedPage(m_currentFormIndex)) cmdNotes.disabled = true;										//27Jan05 AE
		// F0056503 ST 09Apr10 Don't disable the notes button for infopages (ordersets)
		if (IsSharedPage(m_currentFormIndex)) cmdNotes.disabled = true; 									//27Jan05 AE

		//Notes button is disabled for new items (which have a class of "template")												//02Oct06 AE  #SC-06-0882
		if (document.all['ordersXML'] != undefined)
		{
			var objItem = ordersXML.XMLDocument.selectSingleNode('root//item[@formindex="' + m_currentFormIndex + '"]');
			if (objItem.getAttribute('dataclass') == 'template') cmdNotes.disabled = true;

			// F0056503 ST 09Apr10 Disable the notes button for notes, doh!
			if (objItem.getAttribute('dataclass') == 'note') cmdNotes.disabled = true;

			// F0090093 ST 28Jun10 If we are creating a new item and the current item is an orderset then disable notes button
			if (blnPendingMode && objItem.getAttribute('dataclass') == 'orderset') cmdNotes.disabled = true;
		}

		if (blnCopyMode) cmdNotes.disabled = true;

		if (!cmdNotes.disabled) { imgAttachedNote.style.filter = '' };
	}

	//Pending
	if (document.all['cmdPending'] != undefined)
	{
		if (!blnDisplay)
		{
			cmdPending.disabled = false;
		}
		if (IsInfoPage(m_currentFormIndex) || IsSharedPage(m_currentFormIndex)) cmdPending.disabled = true; 								//27Jan05 AE
		if (!cmdPending.disabled) { imgPending.style.filter = '' };
	}

	// Adjust doses
	if (document.all['cmdAdjustDoses'] != undefined)
	{
		var blnCalculatedPrescription = CurrentFormIsCalculatedPrescription();
		cmdAdjustDoses.disabled = blnDisplay || (!blnCalculatedPrescription);

		//F0051633 ST 27Apr09 We may need to disable the toolbar button if all of the items on the prescription have failed calculations.
		if (blnCalculatedPrescription && CalculatedPrescriptionCalculationFailed())
		{
			cmdAdjustDoses.disabled = true;
		}

		if (!cmdAdjustDoses.disabled) { cmdAdjustDoses.style.filter = '' };
	}

	// F0078405 ST 09Apr10 If amending and autocommitwhenamending setting is true then disable the leave pending button
	if (blnAmendMode && blnAutoCommitWhenAmend) 
	{
	    if (document.all['cmdPending'] != undefined) {
	        cmdPending.disabled = true;
	    }
	}

	//Ungrey the images on enabled buttons
	if (document.all['cmdPending'] != undefined)
	{
		if (!cmdView.disabled)
		{
			imgView.style.filter = '';
			imgDropView.style.filter = '';
		}
	}

	//enable the options button if in template mode
	if (document.all['cmdTemplateOptions'] != undefined)
	{
		imgOptions.style.filter = '';
		imgDropOptions.style.filter = '';
		cmdTemplateOptions.disabled = false;
	}

	//Shows/hides the attached note toolbars
	var fraToolbar = document.body.all['fraOCSToolbar'];
	if (fraToolbar != undefined)
	{																						//28Jul05 AE Prevent errors if frame not scripted
		var trToolbar = window.frames("fraOCSToolbar").document.getElementById("trOCSToolbar");
		if (trToolbar != null)
		{																							//25Apr05 AE  Prevent errors when no toolbar exists (eg, cancellations)
			var td;
			var intTDIndex = 0;

			for (intTDIndex = 0; intTDIndex < trToolbar.childNodes.length; intTDIndex++)
			{
				td = trToolbar.childNodes[intTDIndex];

				if (td.getAttribute("FormNo") != null)
				{
					if (Number(td.getAttribute("FormNo")) == m_currentFormIndex)
					{
						td.style.display = "";
						td.disabled = false;
					}
					else
					{
						td.style.display = "none";
						td.disabled = true;
					}
				}
			}
		}
		var ToolbarHeight = window.frames("fraOCSToolbar").document.body.scrollHeight - 4;
		fraToolbar.height = ToolbarHeight;
	}
}

//-------------------------------------------------------------------------------------------------
function ShowStatusMessage(strMsg)
{
	//displays a message in the status panel.  Use blank string to hide the message.

	var intTop = 100;
	if (document.all['statusPanel'] != undefined)
	{
		var intLeft = document.body.offsetWidth - statusPanel.offsetWidth - 200;
		void StatusMessage(strMsg, intTop, intLeft);
	}
}

////-------------------------------------------------------------------------------------------------

function UpdateActiveBorder(intCurrentFormIndex)
{
	// Move blue border around the current active form

	var objFrame;
	var intIndex;
	var intFormCount;
	var strClassName = " OrderFormFrameFocused";

	intFormCount = CountOrderForms();
	for (intIndex = 0; intIndex < intFormCount; intIndex++)
	{
		objFrame = document.getElementById("orderForm" + intIndex);
		if (objFrame.className.substr(objFrame.className.length - strClassName.length) == strClassName)
		{
			objFrame.className = objFrame.className.substr(0, objFrame.className.length - strClassName.length);
		}
	}

	document.getElementById("orderForm" + intCurrentFormIndex).className += strClassName;
}


//--------------------------------------------------------------------------------------
//										Navigation Routines
//--------------------------------------------------------------------------------------

function NavigateToFormDelayed(intFormIndex)
{
	if (CountOrderForms() > 1)
	{
		if (orderIndexRow[0].disabled)
		{
			return;
		}
		IndexEnabledStateSet(false);
	}

	//update index
	void HighlightIndex(intFormIndex);

	void ShowStatusMessage('Loading...');

	var formName = FORMID_PREFIX + intFormIndex;
	if (document.all[formName].src == "")
	{

		m_StartTime = (new Date()).getTime();

		document.all[formName].src = document.all[formName].getAttribute("srcdelay");
	}
	else
	{
		NavigateToForm(intFormIndex);
		IndexEnabledStateSet(true);
	}
}

function IndexEnabledStateSet(blnEnabled)
{
	for (intCount = 0; intCount < orderIndexRow.length; intCount++)
	{
		orderIndexRow[intCount].disabled = !blnEnabled;
	}
}

function NavigateToForm(intFormIndex)
{
	//Move to the specified form in the collection, and
	//update the index pane as appropriate, if it appears on this page.
	m_currentFormIndex = intFormIndex;

	var intCount

	//Count the number of forms we have loaded.
	var numForms = CountOrderForms();
	//Hide all frames, except the current one.
	void NavigateToForm_Standard(numForms, intFormIndex);
	//update index
	void HighlightIndex(intFormIndex);

	//update the "page x of y" text
	if (document.all['spnCurrentItem'] != undefined)						//07Oct04 AE  spnCurrentItem no longer scripted for singleton items
	{
		spnCurrentItem.innerText = 'Page ' + (Number(intFormIndex) + 1) + ' of ' + numForms
	}
	//update module-level index variables

	//Hide the scheduler controls if this is a prescription, as they 
	//cannot be scheduled in the same way as other orders
	void UpdateScheduleInfo(m_currentFormIndex);
	//Update the notes button
	void UpdateNotes();
	//Update the status bar
	void UpdateStatus(m_currentFormIndex);
	//Update the pending button
	void UpdatePending(m_currentFormIndex);
	//Update the back/next buttons
	void UpdateBackNext(m_currentFormIndex);
	//Update active border
	void UpdateActiveBorder(m_currentFormIndex);
	// Updated form_specific buttons
	void EnableButtons();
	//If the form was loaded ok, move the cursor to it.
	//	if (!IsInfoPage(m_currentFormIndex) && FormIsLoaded(m_currentFormIndex)) {										//27Jan05 AE
	var formName = FORMID_PREFIX + m_currentFormIndex;
	if (!IsInfoPage(m_currentFormIndex) && !IsSharedPage(m_currentFormIndex))
	{
		//25Aug10 JMei F0094955 fix script error when no form error occur and disable the OK button in that case
		if (document.frames[formName].PositionProblemDiv != undefined)
		{
			document.frames[formName].PositionProblemDiv(); 																	//02Nov05 AE  Added call to position problem div
			document.frames[formName].FocusFirstControl();
		} else
		{
			return false;
		}
	}
	else
	{
		//If it's the orderset page, it's disabled while loading, so we make sure it's enabled here.				//28Feb07 AE  Now disables Orderset page while loading #SC-07-0043
		if (!IsSharedPage(m_currentFormIndex))
		{
			document.frames[formName].Enable();
		}
	}

	void ShowStatusMessage('');

	return true; 																													//21Apr05 AE  Actually return a value is we succeed #80060
}

//------------------------------------------------------------------------------------------------

function NavigateToForm_Standard(numForms, intFormIndex)
{
	//Navigate to a form when the current view is Standard
	//The current form is rendered, the rest are hidden.

	if (numForms > 1)
	{
		for (intCount = 0; intCount < numForms; intCount++)
		{
			if (intCount != intFormIndex)
			{
				//Hide this
				orderFormDiv[intCount].style.display = "none";
				spnItemTitle[intCount].style.display = "none";
			}
			else
			{
				//Current frame; display this.
				orderFormDiv[intCount].style.display = "block";
				spnItemTitle[intCount].style.display = "block";
			}
		}
	}
	else
	{
		//In the case of a single form, we just display the title
		spnItemTitle.style.display = "block";
	}
}

//------------------------------------------------------------------------------------------------

function MoveFormPrevious(blnSkipCompletedForms)
{
	//Moves to the previous form

	var blnResult = false;
	var blnSkip = false;

	if (m_currentFormIndex > 0)
	{																									//04Feb05  AE  UnFu><0r3d some prototype code which fell into the main branch.
		if (CheckDataValid())
		{
			//skip previous form if it is filled in and "skip completed forms" is set		
			if (FilledIn(Number(m_currentFormIndex) - 1) && (blnSkipCompletedForms))
			{
				blnSkip = true;
			}
		}

		if (blnSkip)
		{
			m_currentFormIndex--;
			blnResult = MoveFormPrevious(blnSkipCompletedForms);
			if (blnResult != true)
			{
				//move failed, rollback the current index
				m_currentFormIndex++;
			}
		}
		else
		{
			void NavigateToForm(Number(m_currentFormIndex) - 1);
			blnResult = true;
		}
	}

	return blnResult;
}


//------------------------------------------------------------------------------------------------

function MoveFormNext(blnSkipCompletedForms)
{
	//Moves to the next form

	var blnResult = false;
	var blnSkip = false;
	var blnDisplayMode = (document.body.getAttribute("display") == 'true');

	//Find the number of Order form frames.  In the event that there is only
	//one, unfortunately it no longer behaves as a collection.
	var numFrames = CountOrderForms();

	if (m_currentFormIndex < numFrames - 1)
	{
		if (!blnDisplayMode)
		{
			if (CheckDataValid())
			{																										//04Feb05  AE  UnFu><0r3d some prototype code which fell into the main branch.
				//skip next form if it is filled in and "skip completed forms" is set
				if (FilledIn(Number(m_currentFormIndex) + 1) && (blnSkipCompletedForms))
				{
					blnSkip = true
				}
			}

			if (blnSkip)
			{
				m_currentFormIndex++;
				blnResult = MoveFormNext(blnSkipCompletedForms);
				if (blnResult != true)
				{
					//move failed, rollback to the previous index
					m_currentFormIndex--;
				}
			}
			else
			{
				void NavigateToForm(Number(m_currentFormIndex) + 1);
				blnResult = true;
			}
		}
		else
		{
			void NavigateToFormDelayed(Number(m_currentFormIndex) + 1);
			blnResult = true;
		}
	}

	return blnResult;
}

//------------------------------------------------------------------------------------------------


function FilledIn(index)
{
	//True if the specified item is filled in, otherwise false.

	var vValue;
	var blnResult = false;

	if (!IsInfoPage(index) && !IsSharedPage(index))
	{									//27Jan05 AE  Written
		//A form; check that it's filled in
		var formName = new String(FORMID_PREFIX + index);
		//25Aug10 JMei F0094955 fix script error when no form error occur and disable the OK button in that case
		if (document.frames[formName].document.all['instanceData'] != undefined)
		{
			var instanceData = document.frames[formName].document.all['instanceData'].XMLDocument.selectSingleNode('root/data');
			blnResult = (instanceData.getAttribute('filledin') == 'true');
		}
	}
	else
	{
		//This is an info page
		blnResult = true;
	}

	return blnResult;
}

//------------------------------------------------------------------------------------------------
function HighlightIndex(intFormIndex)
{
	//highlight the index cell

	var intCount;
	var strClassName = "";

	for (intCount = 0; intCount < orderFormDiv.length; intCount++)
	{
		//determine how this cell should appear.
		if (intCount == intFormIndex)
		{
			orderIndexRow[intCount].className += ' Highlight';
			//			orderIndexRow[intCount].style.backgroundColor=INDEX_HIGHLIGHT_BGCOLOUR;
			//			orderIndexRow[intCount].style.color=INDEX_HIGHLIGHT_COLOUR;
		}
		else
		{
			orderIndexRow[intCount].className = orderIndexRow[intCount].className.split(' Highlight').join('');
			//			orderIndexRow[intCount].style.backgroundColor="";
			//			orderIndexRow[intCount].style.color="";
		}
	}
}

//------------------------------------------------------------------------------------------------

function ToggleIndex()
{
	//Hide the index if it's visible, show it if not...

	if (IndexPaneIsOpen())
	{
		void CloseIndexPane();
	}
	else
	{
		void OpenIndexPane();
	}
}

//------------------------------------------------------------------------------------------------

function IndexPaneIsOpen()
{
	//Returns true if the index pane is displayed

	var blnReturn = true;

	if (indexControlBar.style.display == 'none')
	{
		blnReturn = false;
	}

	return blnReturn;
}

//------------------------------------------------------------------------------------------------

function CloseIndexPane()
{
	var intCount;

	indexControlBar.style.display = 'none';
	tblControl.className = 'Toolbar Closed';
	indexPaddingCell.className = 'Toolbar';
	indexPaddingCell.innerText = 'I n d e x';
	indexButton.value = '>';
	indexButton.title = 'Click here to show the index'
	indexContainer.style.width = '0px';

	//hide the index items
	for (intCount = 0; intCount < orderFormDiv.length; intCount++)
	{
		orderIndexRow[intCount].style.display = 'none';
	}
}


//------------------------------------------------------------------------------------------------

function OpenIndexPane()
{
	var intCount;

	indexControlBar.style.display = 'block';
	tblControl.className = 'Toolbar';
	indexPaddingCell.className = '';
	indexPaddingCell.innerText = '';
	indexButton.value = 'X';
	indexButton.title = 'Click here to hide the index'
	indexContainer.style.width = '20%';

	//hide the index items
	for (intCount = 0; intCount < orderFormDiv.length; intCount++)
	{
		orderIndexRow[intCount].style.display = 'block';
	}
}

//-------------------------------------------------------------------------------------------------
function UpdateBackNext(formIndex)
{
	//Updates the back/next buttons; each is enabled/disabled according
	//to the currently selected form.

	var numForms = CountOrderForms();
	if (numForms > 1)
	{
		if (m_currentView != VIEW_STACKED)
		{
			//Paged view, enable buttons dependin on which form is selected
			if (formIndex == (numForms - 1))
			{
				cmdNext.disabled = true;
				imgCmdNext.style.filter = FILTER_GREYSCALE;
			}
			else
			{
				cmdNext.disabled = false;
				imgCmdNext.style.filter = '';
			}

			if (formIndex == 0)
			{
				cmdPrevious.disabled = true;
				imgCmdPrevious.style.filter = FILTER_GREYSCALE;
			}
			else
			{
				cmdPrevious.disabled = false;
				imgCmdPrevious.style.filter = '';
			}
		}
		else
		{
			//Stacked view, the buttons are always disabled
			cmdPrevious.disabled = true;
			imgCmdPrevious.style.filter = FILTER_GREYSCALE;
			cmdNext.disabled = true;
			imgCmdNext.style.filter = FILTER_GREYSCALE;
		}
	}
}

//-------------------------------------------------------------------------------------------------
function DescriptionUpdate(formIndex, Description)
{
	//Callback to allow forms to update their descriptions
	//27May08 AE  Added.
	if (CountOrderForms() > 1)
	{
		spnItemTitle[formIndex].innerHTML = Description;

		//SCH Changing the Index to reflect the changes make to the form
		//Only do this if there is an order index
		if (window.orderIndexRow)
		{
			orderIndexRow[formIndex].innerHTML = Description;
		}

	}
	else
	{
		spnItemTitle.innerHTML = Description;

		//SCH Changing the Index to reflect the changes make to the form

		//Only do this if there is an order index
		if (window.orderIndexRow)
		{
			orderIndexRow.innerHTML = Description;
		}
	}
}

//-------------------------------------------------------------------------------------------------
function ToggleStatus()
{
	//Toggle the status panel between
	//opened and closed.

	if (StatusPaneIsOpen())
	{
		void CloseStatusPane();
	}
	else
	{
		void OpenStatusPane();
	}
}

//-------------------------------------------------------------------------------------------------

function CurrentFormIsPrescription()
{
	//Returns true if the current form is a prescription, false otherwise
	return FormIsPrescription(m_currentFormIndex);
}


function CurrentFormIsCalculatedPrescription()
{
	return FormIsCalculatedPrescription(m_currentFormIndex);
}



//-------------------------------------------------------------------------------------------------

function FormIsPrescription(intFormOrdinal)
{
	//Returns true if the  form is a prescription, false otherwise
	var blnReturn = false;
	//Check the xml definition of this form for the isrx attribute

	var objFormDef = ordersXML.XMLDocument.selectSingleNode('root//item[@formindex="' + intFormOrdinal + '"]');
	var isRx = objFormDef.getAttribute('isrx');
	if (isRx == '1')
	{
		blnReturn = true;
	}
	return blnReturn
}

//-----------------------------------------------------------------------------------------------------
// Given a form will determine if it is a calculated dose prescription
function FormIsCalculatedPrescription(intFormOrdinal)
{
	//Returns true if the  form is a prescription, false otherwise
	var blnReturn = false;

	//Check the xml definition of this form for the isrx attribute
	var objFormDef = ordersXML.XMLDocument.selectSingleNode('root//item[@formindex="' + intFormOrdinal + '"]');
	var isRx = objFormDef.getAttribute('isrx');
	var objRxForm = window.frames("orderForm" + intFormOrdinal);
	var isCalculated = false;

	if (CurrentFormIsPrescription())
	{
		isCalculated = objRxForm.IsCalculatedDose();
	}

	if (isRx == '1' && isCalculated == true)
	{
		blnReturn = true;
	}
	return blnReturn
}

//F0051633 ST 27Apr09   Checks to see if the calculated dose button is disabled which would be the case if the calculation has failed.
//If there are multiple buttons (items) on the form then checks if they are all disabled or not.
function CalculatedPrescriptionCalculationFailed()
{
	var objRxForm = window.frames("orderForm" + m_currentFormIndex);
	if (objRxForm.IsFailedCalculation())
	{
		return true;
	}
	else
	{
		return false;
	}
}

//-------------------------------------------------------------------------------------------------

function StatusPaneIsOpen()
{
	//Returns true if the status pane is displayed, 
	//false if it is hidden or does not exist.

	var blnReturn = true;

	try
	{
		if (statusContainer.currentStyle.display == 'none')
		{
			blnReturn = false;
		}
	}
	catch (err)
	{
		blnReturn = false;
	}

	return blnReturn;
}

//-------------------------------------------------------------------------------------------------

function OpenStatusPane()
{
	//Display the status pane
	void UpdateStatus(m_currentFormIndex);
	statusContainer.style.display = 'block';
	cmdShowStatus.innerHTML = '<u>H</u>ide';
	cmdShowStatus.title = 'Click here to hide the status details';
}

//-------------------------------------------------------------------------------------------------

function CloseStatusPane()
{
	//Hide the status pane
	statusContainer.style.height = '';
	statusContainer.style.display = 'none';
	cmdShowStatus.innerHTML = 'S<u>h</u>ow';
	cmdShowStatus.title = 'Click here to show the status details';
}

//---------------------------------------------------------------------------------------------------

function SetStatusClass(htmlElement, strClass)
{
	//Updates the class string of the status bar/panel.  The basic
	//class has strClass added to it; this replaces the previous 
	//extra class, if any.

	var strOldClass = htmlElement.className;
	var spacePos = strOldClass.indexOf(' ');

	//Strip off the old extra class, if there is one
	if (spacePos > -1) { strOldClass = strOldClass.substring(0, spacePos); }

	//Add the new one
	var strNewClass = strOldClass + ' ' + strClass;
	htmlElement.className = strNewClass;
}

//---------------------------------------------------------------------------------------------------

function ShowNotes()
{
	//Display the notes editor	
	var strMode = new String();

	//Extract the data
	var objItem = ordersXML.XMLDocument.selectSingleNode('root//item[@formindex="' + m_currentFormIndex + '"]');
	var strClass = objItem.getAttribute('dataclass');
	var lngID = objItem.getAttribute('id');

	//Launch the editor
	var strReturn = EditAttachedNotes(oeBody.getAttribute('sid'), strClass, lngID);
	if (strReturn)
	{
		window.parent.returnValue = 'refresh';
	}
}

//-------------------------------------------------------------------------------------------------

function UpdateIndexClasses()
{
	//Updates the HTML class of each index item to apply appropriate
	//styling for items which are completed, uncompleted etc

	var intCount = new Number();

	if (document.all['orderIndexRow'] !== undefined)
	{
		var numForms = CountOrderForms();
		for (intCount = 0; intCount < numForms; intCount++)
		{

			if (FilledIn(intCount))
			{
				orderIndexRow[intCount].className += ' Completed';
			}
			//
			//	other styles here...
			//
		}
	}
}

//-------------------------------------------------------------------------------------------------

function SetFocusToForm()
{
	//Sets the focus to the first control on the 
	//currently visible form.
	var blnDisplayMode = (document.body.getAttribute("display") == 'true');

	if (!blnDisplayMode && !IsInfoPage(m_currentFormIndex) && !IsSharedPage(m_currentFormIndex))
	{
		var formName = FORMID_PREFIX + m_currentFormIndex;
		void document.frames[formName].FocusFirstControl();
		if (window.event != null) window.event.cancelBubble = true; 						//16Aug06 AE  Added if, as we now may be called from events that originated in another window. #DR-05-0127
	}
}

//--------------------------------------------------------------------------------------------------

function FocusOffForm(strFocusVector)
{
	//The focus has moved off of an order form.  If
	//it is moving forwards, we go to the next form (if
	//there is one); if it is moving backwards, we go to
	//the previous form (if there is one).

	//	strFocusVector: either 'back' or 'next'.  This indicates
	//						 which way the focus is moving.
	// Returns:			 void.

	if (m_currentView == VIEW_STANDARD)
	{
		switch (strFocusVector)
		{
			case 'back':
				//If there is a previous form, move to it
				void MoveFormPrevious(false);
				break;

			case 'next':
				//If there is a following form, move to it
				void MoveFormNext(false);
				break;
		}
	}
}

//--------------------------------------------------------------------------------------------------
//												View changing functions
//--------------------------------------------------------------------------------------------------
function ChooseView()
{
	//Show the views pop-up which lets the user change view from normal, stacked, fit	
	//Create the popup
	var objPopup = new ICWPopupMenu(); 					//Create a new object
	objPopup.AddItem('Paged', VIEW_STANDARD, true);
	objPopup.AddItem('Stacked', VIEW_STACKED, true);

	//Work out where to show the menu
	if (document.body.getAttribute('embedded') != 'true')
	{
		//Modal mode
		var intX = cmdView.offsetWidth + cmdNotes.offsetWidth + indexContainer.offsetWidth + indexContainer.offsetLeft + tblBody.offsetLeft + 5;
		var intY = spnItemTitle[m_currentFormIndex].offsetHeight + cmdView.offsetHeight + 10;

		intX += window.screenLeft;
		intY += window.screenTop;
	}
	else
	{
	    //Embedded mode - a bit hacky but in a hurry as usual...
	    if (document.all['cmdPending'] != undefined) {
	        var intX = cmdPending.offsetWidth + cmdNotes.offsetWidth + indexContainer.offsetWidth + indexContainer.offsetLeft + tblBody.offsetLeft + 5;
	    }
	    else {
	        var intX = cmdNotes.offsetWidth + indexContainer.offsetWidth + indexContainer.offsetLeft + tblBody.offsetLeft + 5;
	    }
		if (m_currentView == VIEW_STANDARD)
		{
			var intY = cmdView.offsetHeight;
			intY += window.screenTop - 10;
		}
		else
		{
			intY = window.screenTop - 40;
		}
		intX += window.screenLeft;
	}

	objPopup.Show(0, cmdView.offsetHeight, cmdView); 										//Now show the menu
}

//--------------------------------------------------------------------------------------------------

function PopMenu_ItemSelected(selIndex, selDesc)
{

	m_currentView = selIndex;

	switch (selIndex)
	{
		case VIEW_STANDARD:
			void FormArrange_Paged(true);
			break;

		case VIEW_STACKED:
			void FormArrange_Stacked(true);
			break;

	}
}

//--------------------------------------------------------------------------------------------------

function FormArrange_Stacked(blnSaveSetting)
{
	//Arrange the forms so that they are stacked one below another.

	var layoutData = new Object();
	var intCount = new Number(0);
	var formName = new String();
	var formHeight = new Number();
	var scheduleName = new String();
	var intCall = 0;

	for (intCall = 0; intCall < 2; intCall++)
	{										//Alas; seemingly randomly, the pages will sometimes not report their full height.  
		//Running the procedure twice is the only way I've found to fix this.  Woe is me.
		var numForms = CountOrderForms();

		if (numForms > 1)
		{
			//Hide the index pane
			indexContainer.style.display = 'none';
			//Hide the title and page indicators; these are shown on a per-item basis below
			rowHeader.style.display = 'none';

			//Disable back and next buttons
			void UpdateBackNext();

			//Stack 'em
			for (intCount = 0; intCount < numForms; intCount++)
			{
				//Obtain the height of this form
				formName = FORMID_PREFIX + intCount;
				if (!IsInfoPage(intCount) && !IsSharedPage(intCount))
				{
					//Normal forms - read the height from the data island on the page			
					layoutData = document.frames[formName].document.all['layoutData'].XMLDocument.selectSingleNode('xmldata/layout');
					formHeight = document.frames[formName].RenderStacked(); 											//19Apr05 AE  Prevents custom controls scrolling within the overall scrolling-ness

				}
				else
				{
					//Info pages; read from the pages PageHeight() method
					formHeight = document.frames[formName].PageHeight();
				}

				//Display item title & schedule bar
				orderFormDiv[intCount].style.display = 'block';
				rowItemTitle[intCount].style.display = 'block';
				void UpdateScheduleInfo(intCount);

				//Size the item
				formHeight = Number(formHeight) + FORM_PADDING;

				//Size the actual frame
				document.all[formName].style.height = '100%'; //formHeight;

				//And the div it sits in
				scheduleName = SCHEDULEID_PREFIX + intCount;
				if (document.all[scheduleName] != undefined)
				{
					//there may be zero, one, or many schedulebars
					formHeight += Number(document.all[scheduleName].parentElement.parentElement.offsetHeight);
				}
				formHeight += Number(rowItemTitle[intCount].offsetHeight);
				orderFormDiv[intCount].style.height = formHeight;
			}
		}
		//store the new view	in the database					//13Apr05 AE
		if (blnSaveSetting)
		{
			fraSetting.SaveSettingForUser(SYSTEM_OCS, SECTION_ORDERENTRY, KEY_DEFAULT_VIEW, VALUE_STACKED_VIEW, DESCRIPTION_DEFAULT_VIEW);
		}
	}
}

//--------------------------------------------------------------------------------------------------

function FormArrange_Paged(blnSaveSetting)
{
	//Arrange the forms so that they are paged, ie only one is
	//shown at a time

	var intCount = new Number(0);

	var numForms = CountOrderForms();

	//Show the index
	indexContainer.style.display = 'block';
	//Show the title and page indicator
	rowHeader.style.display = 'block';
	//Enable back/next buttons
	void UpdateBackNext(m_currentFormIndex);

	//Hide all forms 'cept the current one
	for (intCount = 0; intCount < numForms; intCount++)
	{
		formName = FORMID_PREFIX + intCount;

		//Render the form back to paged mode (re-enable scrolling etc)

		if (!IsInfoPage(intCount) && !IsSharedPage(intCount))
		{
			document.frames[formName].RenderPaged(); 												//19Apr05 AE  Call undoes the changes that RenderStacked() makes
		}
		//Size the actual frame
		orderFormDiv[intCount].style.height = '100%';
		document.all[formName].style.height = '100%';

		if (intCount == m_currentFormIndex)
		{
			orderFormDiv[intCount].style.display = 'block';
		}
		else
		{
			orderFormDiv[intCount].style.display = 'none';
		}
		//Hide the per-item title
		rowItemTitle[intCount].style.display = 'none';

	}
	//store the new view	in the database					//13Apr05 AE
	if (blnSaveSetting)
	{
		fraSetting.SaveSettingForUser(SYSTEM_OCS, SECTION_ORDERENTRY, KEY_DEFAULT_VIEW, VALUE_PAGED_VIEW, DESCRIPTION_DEFAULT_VIEW);
	}
}

//--------------------------------------------------------------------------------------------------

function FormFocus(frameID)
{
	//Fires when a form gets the focus.  This is used in stacked view.
	//We update the buttons etc with the context of the form in focus.

	if (m_currentView == VIEW_STACKED)
	{																					//19May05 AE  Prevent obscure "focus stealing behaviour causes date shuffling error" on load in standard mode
		//Get the form index from the frameID (orderFormXXX) where XXX is the index
		intFormIndex = Number(frameID.substring(FORMID_PREFIX.length));
		m_currentFormIndex = intFormIndex

		//Update the various per-form controls
		void UpdateScheduleInfo(m_currentFormIndex);
		//Update the notes button
		void UpdateNotes();
		//Update the status bar
		void UpdateStatus(m_currentFormIndex);
		//Update the pending button
		void UpdatePending(m_currentFormIndex);
	}
}

//--------------------------------------------------------------------------------------------------
//													Internal Gubbins
//--------------------------------------------------------------------------------------------------

function CountOrderForms()
{
	//Count the number of order forms and return the number.
	//Used because more than one behaves like a collection, 
	//a single form must be referenced by id only with no
	//ordinal.
	if (document.all['orderFormDiv'] != undefined)
	{
		var numFrames = orderFormDiv.length;
	}
	if (numFrames == undefined) { numFrames = 1 };

	return numFrames;
}


//---------------------------------------------------------------------------------------------------
function IsInfoPage(index)
{
	//27Jan05 AE  Returns true if the specified form is a read-only information page
	if (orderFormDiv.length != undefined)
	{
		//Multiple pages.

		return (orderFormDiv[index].getAttribute('infopage') == '1');

	}
	else
	{
		//Single item only, must be a form
		return false;
	}
}

//-----------------------------------------------------------------------------------------------------
function IsSharedPage(index)
{
	//27Jan05 AE  Returns true if the specified form is a read-only information page
	if (orderFormDiv.length != undefined)
	{
		//Multiple pages.

		return (orderFormDiv[index].getAttribute('sharedpage') == '1');

	}
	else
	{
		//Single item only, must be a form
		return false;
	}
}

//-----------------------------------------------------------------------------------------------------
function SetChanged(blnChanged)
{
	//Function to indicate if the data on any of the forms has changed.
	m_blnEditMade = blnChanged;
}

//-----------------------------------------------------------------------------------------------------

function ShowWarnings()
{
	//Fires on start up, and pops up a message if there's anything
	//the user should know.  This is typically to warn them if they're
	//re-resulting an order and hence deprecating something.	

	var colNodes;
	var strMsg = new String();
	var numForms = new Number();
	var formName = new String();

	//Check for existing committed results - occurs if an order is re-resulted.
	colNodes = ordersXML.selectNodes('root/item[@instanceexists="1" and @allowduplicates!="1"]'); 		//29Jan04 AE  Changed from =0 to !=1, as the field is missing on some systems. 14Jan04 AE  Added check for AllowDuplicates flag
	if (colNodes.length > 0)
	{
		if (colNodes.length > 1)
		{
			strMsg += colNodes.length + ' item(s) have already been resulted.\n';
		}
		if (colNodes.length == 1)
		{
			strMsg += 'This item has already been resulted.\n';
		}
		strMsg += 'Saving new results will cause the existing result to '
				  + 'be superceded by the result you enter.\n\n';
	}

	//Check for existing pending results - occurs if an order is re-resulted before
	//the first results have been authorised.
	colNodes = ordersXML.selectNodes('root/item[@pendingexists="1"]');
	if (colNodes.length > 0)
	{
		strMsg += colNodes.length + ' item(s) have results pending; you will be presented with the \n'
										  + 'pending result(s) for editing.\n\n'
	}

	//Show the warnings, if any.
	if (strMsg.length > 0)
	{
		alert(strMsg);
	}
}

//---------------------------------------------------------------------------------

function BlankPage()
{
	//Once a save has been made in non-modal mode, blank the screen to save confusion.
	//We refresh the page to achieve this.
	window.navigate(document.URL + '&Action=blank');
}

//---------------------------------------------------------------------------------

function btnRefresh_onclick()
{
	// re-submit the order entry form, retaining any data that was passed on the query string, or submitted in the post data
	frmParameters.submit();
}

//--------------------------------------------------------------------------------------

function btnOverride_onclick()
{
	// re-submit the order entry form, retaining any data that was passed on the query string, or submitted in the post data
	// but with addition query string apram to indicate that the lock should be overwritten

	frmParameters.action = frmParameters.action + "&overridelock=1"
	frmParameters.submit();
}

//--------------------------------------------------------------------------------------

function window_unload()
{
	CloseWindow(false);
}

//--------------------------------------------------------------------------------------

//26Oct2009 JMei F0066887 F0066888 give user a chioce for saving when navigating away from this page
function SaveAsPendingItemWhenNavigateAway() 
{
    if (document.body.getAttribute("ignorepending") == "1")
    {
	    var strOrdersetMsg = 'Are you sure you want to navigate away from this page?\n'
                            + 'If you press Yes, the item(s) in Order Comms will not be saved.\n\n'
                            + 'Press Yes to navigate away without saving, or press No to stay on the current page.'
	    var strReturn = MessageBox('Warning', strOrdersetMsg, 'YesNo', '');
	    switch (strReturn)
	    {
		    case "y":
			    return true;
			    break;
		    default:
			    return false;
			    break
	    }
    }
    else
    {
	    var strOrdersetMsg = 'Are you sure you want to navigate away from this page?\n'
                            + 'If you press Yes, the item(s) in Order Comms will be saved as Pending Items.\n\n'
                            + 'Press Yes to navigate away after <b>Save</b>, or press No to leave <b>without Save</b>, or Cancel to stay on the current page.'
	    var strReturn = MessageBox('Warning', strOrdersetMsg, 'YesNoCancel', '');
	    switch (strReturn)
	    {
		    case "y":
			    // Check to see if someone else has overriden our lock
			    if (!LockHasBeenOverridden())
			    {
				    //SaveAsPendingItem(false);
				    // We still have the lock, so proceed to save the pending item
				    if (CheckDataValid())
				    {																											//04Oct03 AE Added validity checks for custom controls
					    var sessionID = oeBody.getAttribute('sid');
					    var enteredData_XML = CollateDataFromForms();
					    var strContinue;
					    if (enteredData_XML != "ERROR")
					    {
						    void generalXML.XMLDocument.loadXML(enteredData_XML);
						    var colItemsToCommit = generalXML.XMLDocument.selectNodes('//item[not (item)][@autocommit="1"]');
						    for (intCount = 0; intCount < colItemsToCommit.length; intCount++)
						    {
							    //don't commit even all filledin
							    colItemsToCommit[intCount].setAttribute('autocommit', 0);
						    }
						    if (typeof (fraOCSToolbar) != 'undefined')
						    {
							    fraOCSToolbar.MergeStatusNotesIntoFormData(generalXML);                                                                 // 24Feb06 Call method in Toolbar iframe to merge toolbar data into order data xml
						    }
						    enteredData_XML = generalXML.xml;
						    oeBody.style.cursor = 'wait';
						    cmdOK.disabled = true;
						    cmdCancel.disabled = true;
						    if (document.all['cmdNotes'] != undefined)
						    {
							    cmdNotes.disabled = true;
						    }
						    if (document.all['cmdNext'] != undefined)
						    {
							    cmdPrevious.disabled = true;
							    cmdNext.disabled = true;
						    }

						    m_saveMode = SAVE_PENDING;
						    void ShowStatusMessage('Checking Item(s) and Saving, please wait...');
						    //save and navigate to new desktop that user selected form menu
						    void document.frames['fraSave'].SaveAndNavigateAway(sessionID, enteredData_XML);
						    oeBody.style.cursor = 'default';
					    }
					    else
					    {
						    return false;
					    }
				    }
				    else
				    {
					    return false;
				    }
			    }
			    else
			    {
				    // Someone has overriden our lock, refresh the page to display the lock info
				    frmParameters.submit();
			    }
			    return true;
			    break;
		    case "n":
			    return true;
			    break;
		    default:
			    return false;
			    break
	    }
    }
}

//--------------------------------------------------------------------------------------

function SaveAsPendingItemCheck()
{
	// Check to see if someone else has overriden our lock
	if (!LockHasBeenOverridden())
	{
		// We still have the lock, so proceed to save the pending item
		SaveAsPendingItem(false);
	}
	else
	{
		// Someone has overriden our lock, refresh the page to display the lock info
		frmParameters.submit();
	}
}

//--------------------------------------------------------------------------------------

function SaveAsResponseCheck()
{
	// We dont lock response, so we dont have to check overrides, so just do the normal thing
	SaveAsResponse();
}

//--------------------------------------------------------------------------------------

function SaveAsCancellationCheck()
{
	// Check to see if someone else has overriden our lock
	if (!LockHasBeenOverridden())
	{
		// We still have the lock, so proceed to save the pending item
		SaveAsCancellation();
	}
	else
	{
		// Someone has overriden our lock, refresh the page to display the lock info
		frmParameters.submit();
	}
}

//--------------------------------------------------------------------------------------

function LockHasBeenOverridden()
{
	// Perform a check to ensure that our lock has not been overridden
	var lngSessionID = Number(document.body.getAttribute("sid"));
	var strLockResult = "";

	if (document.body.getAttribute("lockobject") == "entity")
	{
		strLockResult = LockEntity(lngSessionID, document.body.getAttribute("entityid"));
	}
	else
	{
		strLockResult = LockRequests(lngSessionID, document.all['orderEntryXML'].value);
	}

	return (strLockResult != "");
}

//--------------------------------------------------------------------------------------

function CloseWindow(blnCancel)
{
	//Close this window, if we are in modal mode.

	// blnCancel:  if True, we prompt the user to confirm that they
	//						really wish to close the window.
	var blnConfirmed = true;
	var lngSessionID = Number(document.body.getAttribute("sid"));
	//04/12/2009 JMei F0067456 In case of sessionid = 0, eg. the prescription is locked, click close button on right top, just return window.returnValue = 'cancel', so that no new prescription get created.  
	if (lngSessionID != 0)
	{
		if (document.readyState == "complete")
		{

			if (document.body.getAttribute("lockobject") == "entity")
			{
				UnlockEntity(lngSessionID, document.body.getAttribute("entityid"));
			}
			else
			{
				UnlockRequests(lngSessionID);
			}

			if (blnCancel && !cmdOK.disabled && m_blnEditMade)
			{
				blnConfirmed = window.confirm('Really Cancel without saving?');
			}

			if (blnConfirmed)
			{
				//Close the window, if in modal mode
				if (window.parent.CloseMe != undefined)
				{
					void window.parent.CloseMe(blnCancel, true);
				}
			}

		}
	}
	else
	{
		window.returnValue = 'cancel';
	}
}

//--------------------------------------------------------------------------------------

//
// Launch the Adjust doses dialog. This method is called from Order Entry or from one of the child prescription forms (iframes).
//
// intOrdinal - The ordinal number of the calling form.
//
function AdjustDoses(intOrdinal)
{
	// Gather adjustment xml from each child prescription forms.
	var objRxForm;
	var intIndex;
	var intFormCount;
	var strXML = '';
	var SessionID = document.body.getAttribute("sid");
	var blnChecked;

	strXML = "<root>";
	intFormCount = CountOrderForms();
	for (intIndex = 0; intIndex < intFormCount; intIndex++)
	{
		if (FormIsPrescription(intIndex))
		{
			blnChecked = (intOrdinal == -1 || intOrdinal == intIndex)
			objRxForm = window.frames("orderForm" + intIndex);
			strXML += objRxForm.GetAdjustmentXML(blnChecked);
		}
	}
	strXML += "</root>";

	// Save the XML into a Session Attribute in the DB so that the Adjustment page can pick it up when it loads.
	SessionAttributeSet(SessionID, "OrderEntry/Adjustments", strXML);

	// Launch the Adjustment dialog
	var strFeatures = "center: yes; scroll: no; status: no; dialogWidth: 1012px; dialogHeight: 756px;";
	//07Apr09   Rams    F0052389 Added Math.random to be passed as a querystring as the page is gettingcached, eventhough not configured for!
	if (showModalDialog("DoseReduction.aspx?SessionID=" + SessionID + "&r=" + Math.random(), "", strFeatures) != 'cancel')
	{
		// Read the adjusted dose back from session state
		strXML = SessionAttributeGet(SessionID, "OrderEntry/Adjustments");

		// Iterate through all the *products*, setting the adjusted dose(s) back on each original form.
		var xmldoc = document.getElementById("generalXML").XMLDocument;
		xmldoc.loadXML(strXML);
		var xmlnodelist = xmldoc.selectNodes("//rx");
		for (intIndex = 0; intIndex < xmlnodelist.length; intIndex++)
		{
			var xmlnodeRx = xmlnodelist[intIndex];
			var intFormNo = xmlnodeRx.getAttribute("FormOrdinal");
			var intProductID = xmlnodeRx.getAttribute("ProductID");
			objRxForm = window.frames("orderForm" + intFormNo);
			objRxForm.SetAdjustmentXML(intProductID, xmlnodeRx);
		}

	}
}


// F0091957 27Aug10 ST
// Checks the order xml to see if this is a template being created/edited
function IsTemplateMode()
{
	var objFormDef = ordersXML.XMLDocument.selectSingleNode('root//item[@formindex="0"]');
	var isTemplate = objFormDef.getAttribute('template');
	if (isTemplate == '1')
	{
		return true;
	}
	else
	{
		return false;
	}
}