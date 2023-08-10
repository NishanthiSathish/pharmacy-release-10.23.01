
// Constants for highlighting style changes:
var INDEX_HIGHLIGHT_BGCOLOUR = "#00599C"
var INDEX_HIGHLIGHT_COLOUR = "#ffffff"

//page-level variables:
var m_currentFormIndex=-1;

//------------------------------------------------------------------------------------------------

function ResizeTables() {

//Resize the main table based on the screen size.

var intTableHeight;
	
	try {
		intTableHeight = oeBody.offsetHeight - (cmdOK.offsetHeight + tblMain.offsetTop);
		tblMain.style.height = intTableHeight;
		ResizeOrderForm();
			}
	catch (err) {}
		
}

//------------------------------------------------------------------------------------------------

function NavigateToForm(intFormIndex_IN) {

//Move to the specified form in the collection, and
//update the index pane as appropriate, if it appears on this page.

var intCount

	//Hide all frames
	for (intCount=0; intCount < orderFormDiv.length; intCount++) {
		if (intCount != intFormIndex_IN) {
			orderFormDiv[intCount].style.display="none";
			spnItemTitle[intCount].style.display="none";
		}
		else {
		//except the specified one
			orderFormDiv[intCount].style.display="block";
			spnItemTitle[intCount].style.display="block";
		}
	}
		
	//update index
	HighlightIndex(intFormIndex_IN);

	//update the "page x of y" text
	spnCurrentItem.innerText='Page ' + (intFormIndex_IN + 1) + ' of ' + orderFormDiv.length

	//Close the scheduler if it's open
	if (SchedulePaneIsOpen()) {
		CloseSchedulePane();
	}

	//update module-level index variables
	m_currentFormIndex = intFormIndex_IN
	m_minWidth = 0;
	m_minHeight = 0;

	//Arrange this form
	ResizeOrderForm();

}


//------------------------------------------------------------------------------------------------

function MoveFormPrevious() {

var blnResult=false;

	if (m_currentFormIndex > 0) {
		//skip previous form if it is filled in and "skip completed forms" is set
		if (FilledIn(m_currentFormIndex - 1) && (chkSkip.checked)) {
			m_currentFormIndex = m_currentFormIndex - 1;
			blnResult = MoveFormPrevious();
			if (blnResult != true) {
			//move failed, rollback the current index
				MoveFormNext();
			}
		}
		else {
			NavigateToForm(m_currentFormIndex - 1);
			blnResult=true;
		}
	}

	return blnResult;

}


//------------------------------------------------------------------------------------------------

function MoveFormNext() {

var blnResult = false;

	if (m_currentFormIndex < (orderFormDiv.length - 1)) {
		//skip next form if it is filled in and "skip completed forms" is set
		if (FilledIn(m_currentFormIndex + 1) && (chkSkip.checked)) {
			m_currentFormIndex = m_currentFormIndex + 1;
			blnResult=MoveFormNext();
			if (blnResult != true) {
			//move failed, rollback to the previous index
				MoveFormPrevious();
			}
		}
		else {
			NavigateToForm(m_currentFormIndex + 1);
			blnResult=true;
		}
	}

	return blnResult;

}



//------------------------------------------------------------------------------------------------


function FilledIn(index_IN) {

//True if the specified item is filled in, otherwise false.

var vValue
var blnResult

	vValue = orderFormData[index_IN].XMLDocument.selectSingleNode('xmldata/data').getAttribute('filledin');
	blnResult=(vValue=='1');
	return blnResult

}


//------------------------------------------------------------------------------------------------


function HighlightIndex(intFormIndex_IN) {

//highlight the index cell

var intCount;
var strClassName = "";

	for (intCount=0; intCount < orderFormDiv.length; intCount++)  {
	//determine how this cell should appear.
		if (intCount == intFormIndex_IN) {
			orderIndexRow[intCount].style.backgroundColor=INDEX_HIGHLIGHT_BGCOLOUR;
			orderIndexRow[intCount].style.color=INDEX_HIGHLIGHT_COLOUR;
		}
		else {
			orderIndexRow[intCount].style.backgroundColor="";
			orderIndexRow[intCount].style.color="";
		}
	}

}


//------------------------------------------------------------------------------------------------

function ToggleIndex() {

//Hide the index if it's visible, show it if not...

	if (IndexPaneIsOpen()) {
		CloseIndexPane();
	}
	else {
		OpenIndexPane();
	}

}


//------------------------------------------------------------------------------------------------

function IndexPaneIsOpen() {

//Returns true if the index pane is displayed

var blnReturn = true;

	if (indexControlBar.style.display=='none') {
		blnReturn=false;
	}

	return blnReturn;

}



//------------------------------------------------------------------------------------------------

function CloseIndexPane() {

var intCount;

	indexControlBar.style.display='none';
	indexPaddingCell.className='ControlBar';
	indexPaddingCell.innerText = 'I n d e x';
	indexButton.value='>';
	indexButton.title='Click here to show the index'
	indexContainer.style.width='0px';

//hide the index items
	for (intCount=0; intCount < orderFormDiv.length; intCount++) {
		orderIndexRow[intCount].style.display='none';
	}

//Resize the Order form
	ResizeOrderForm();

}


//------------------------------------------------------------------------------------------------

function OpenIndexPane() {

var intCount;

	indexControlBar.style.display='block';
	indexPaddingCell.className='';
	indexPaddingCell.innerText = '';
	indexButton.value='X';
	indexButton.title='Click here to hide the index'
	indexContainer.style.width='20%';

//hide the index items
	for (intCount=0; intCount < orderFormDiv.length; intCount++) {
		orderIndexRow[intCount].style.display='block';
	}


//Resize the Order form
	ResizeOrderForm();

}




//------------------------------------------------------------------------------------------------

function ToggleSchedule() {

//Show/hide the scheduler pane.

	if (SchedulePaneIsOpen()) {
		CloseSchedulePane();
	}
	else {
		OpenSchedulePane();
	}

}


//------------------------------------------------------------------------------------------------

function SchedulePaneIsOpen() {

var blnReturn=true;

	if (scheduleContainer.currentStyle.display=='none') {
		blnReturn=false;
	}
	
	return blnReturn;

}



//------------------------------------------------------------------------------------------------


function OpenSchedulePane() {

	//Show the schedule pane
	scheduleContainer.style.height='400px';
	scheduleContainer.style.display='block';
	cmdShowSchedule.value='Hide';


	//Resize the Order form
	ResizeOrderForm();
}


//------------------------------------------------------------------------------------------------


function CloseSchedulePane() {

	//Hide the schedule pane
	scheduleContainer.style.height='';
	scheduleContainer.style.display='none';
	cmdShowSchedule.value='Show';

	//Resize the Order form
	ResizeOrderForm();
}

