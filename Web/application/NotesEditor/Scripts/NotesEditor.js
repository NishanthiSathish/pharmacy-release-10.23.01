

var m_objCurrentRow;
var SessionID = new Number(); 

//==========================================================================================
//											Event Handlers
//==========================================================================================

function Initialise() {

	//Highlight the first row, if any.
	SessionID = notesBody.getAttribute('sid');
	
	if (notesTable.rows.length > 4) {
		var objTR = notesTable.rows[2];
		void HighlightRow(objTR);
	}
}

//==========================================================================================
function AddNote(){

//Adds a new note
//21Sep04 AE  Modified; all notes are now created as enabled by default

//Show order entry
	var strURL = 'EditNote.aspx'
				  + '?SessionID=' + SessionID
				  + '&NoteID=-1';
				  
	strReturn = window.showModalDialog(strURL, '', NotesEntryFeatures());
	if (strReturn == 'logoutFromActivityTimeout') {
		window.returnValue = 'logoutFromActivityTimeout';
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	//If the user didn't cancel, save the returned data
	if (strReturn != 'cancel') {
		//Check if they filled everything in; this is helpfully stored in the returned xml
		void parsingIsland.XMLDocument.loadXML(strReturn);		
		var objData = parsingIsland.XMLDocument.selectSingleNode('data');
		if (objData.getAttribute('filledin') == 'true') {
			//Ok to save		
			void SetReturnVal(true); // 18Jan05 PH Return true to refresh Worklist
			document.all['dataXML'].value = '<root>' 
													+ strReturn 
													+ '</root>';
			frmSave.action = 'NotesEditorContents.aspx'
								+ '?SessionID=' + SessionID
								+ '&AddNew=True'
								+ '&Mode=' + notesBody.getAttribute('ascmode')
								+ '&ID=' + notesBody.getAttribute('itemid')
								+ '&ShowAll='  + notesBody.getAttribute('showall');
			void frmSave.submit();
		}
		else {
			//they didn't fill it all in; reshow the form
			void AddNote();
		}
	}
}
//==========================================================================================

function ViewNote(objTR) {

//Views the note represented by the given row
//objTR:			HTML DOM tr element reference

	var strURL = 'EditNote.aspx'
				  + '?SessionID=' + SessionID
				  + '&NoteID=' + objTR.getAttribute('dbid');
  
	strReturn = window.showModalDialog(strURL, '', NotesEntryFeatures());
	if (strReturn == 'logoutFromActivityTimeout') {
		strReturn = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}

//==========================================================================================

function ToggleView(){
//Toggles view between showing only active notes, and showing all notes.

	var blnShowAll = (notesBody.getAttribute('showall') == 'True');

	var strURL = 'NotesEditorContents.aspx'
				  + '?SessionID=' + SessionID
				  + '&Mode=' + notesBody.getAttribute('ascmode')
				  + '&ID=' + notesBody.getAttribute('itemid')
				  + '&ShowAll=' + (!blnShowAll)

					
	void window.navigate(strURL);
}

//==========================================================================================

function ToggleNoteActive(objTR) {

//Toggles the selected note between active and deactivated.
//objTR: HTML DOM tr element reference

	var blnEnabled = CurrentNoteEnabled();
	
	var strURL = 'NotesEditorContents.aspx'
				  + '?SessionID=' + SessionID
				  + '&Mode=' + notesBody.getAttribute('ascmode')
				  + '&ID=' + notesBody.getAttribute('itemid')
				  + '&SetEnabled=' + (!blnEnabled)
				  + '&AddNew=True'
				  + '&ShowAll='  + notesBody.getAttribute('showall')
				  + '&NoteID=' + m_objCurrentRow.getAttribute('dbid');

	void SetReturnVal(true); // 18Jan05 PH Return true to refresh Worklist
	void window.navigate(strURL);
	
}

//==========================================================================================
//										Internal procedures
//==========================================================================================

function CurrentNoteEnabled() {

//Returns true if the currently highlighted note is enabled
	var blnReturn = false;
	if (m_objCurrentRow != undefined) {
		blnReturn = (m_objCurrentRow.getAttribute('enabled') == '1');
	}
	return blnReturn;
}

//==========================================================================================

function HighlightRow(trElement) {
//Highlight the given row, unhighlight all others.
//
//		trElement:		HTML DOM tr Element reference

var intCount = new Number();
var strClass = new String();
var intPos = new Number();
var intCell = new Number();

	if (m_objCurrentRow != undefined) {
		//Unhighlight the previously selected row
		void ChangeRowHighlight(m_objCurrentRow, false);
	}
	
	void ChangeRowHighlight (trElement, true);
	m_objCurrentRow = trElement
	
	//Update the buttons
	cmdToggleActive.disabled = false;
	cmdShow.disabled = false;
	if (CurrentNoteEnabled()) {
		cmdToggleActive.innerHTML = '<u>D</u>eactivate';
		cmdToggleActive.accessKey = 'd';
	}
	else {
		cmdToggleActive.innerHTML = '<u>A</u>ctivate';	
		cmdToggleActive.accessKey = 'a';
	}
			
}

//==========================================================================================

function ChangeRowHighlight(objRow, blnHighlight) {

//Highlight/remove the highlight from each cell in the row
//
//		objRow:			HTML DOM <tr> Element reference
//		blnHighlight:	If true, the row is highlighted, if false, it is returned to its normal appearance

var intCell = new Number();
var intPos = new Number();

	for (intCell = 0; intCell < objRow.cells.length; intCell ++) {
		//For each cell in the row...
		strClass = objRow.cells[intCell].className;
		if (blnHighlight) {
			strClass += ' Selected';
		}
		else {
			intPos = strClass.indexOf(' ');
			strClass = strClass.substring(0, intPos);			
		}
		objRow.cells[intCell].className = strClass;
	}
}

//=============================================================================================

function NotesEntryFeatures() {

	var intWidth = screen.width / 2.0;
	var intHeight = screen.height / 2.0;

	if (intWidth < 540) {intWidth = 540};
	if (intHeight < 600) {intHeight = 600};
	if (intWidth > 680) {intWidth = 850}; //LM Code 162 16/01/2008
	if (intHeight > 800) {intHeight = 800};

	var strFeatures =  'dialogHeight:' + intHeight + 'px;' 
						  + 'dialogWidth:' + intWidth + 'px;'
						  + 'resizable:yes;'
						  + 'status:no;help:no;';

	return strFeatures;					 
}

//==================================================================================================
/*
function AddEnabledAttribute(data_XML, blnEnabled) {

//Adds the system-controlled enabled attribute to the data
//xml returned

	var blnValue = (blnEnabled ? 'True':'False');

	//Load into the parsing xml island
	void parsingIsland.XMLDocument.loadXML(data_XML);
	var objData = parsingIsland.XMLDocument.selectSingleNode('data');
	
	//If the enabled attribute already exists, update it; otherwise, 
	//create the element.
	var objEnabledNode = objData.selectSingleNode('attribute[@name="Enabled"]');
	if (objEnabledNode == null) {
		//Create a new enabled node
		objEnabledNode = parsingIsland.XMLDocument.createElement('attribute');
		void objEnabledNode.setAttribute('name', 'Enabled');
		void objData.appendChild(objEnabledNode);
	}
	
	void objEnabledNode.setAttribute('value', blnValue);
	return parsingIsland.XMLDocument.xml;

}
*/
//==================================================================================================

function SetReturnVal(strValue) {
//Sets the returnValue for the parent window
	window.parent.returnValue = strValue;
}

//==================================================================================================

