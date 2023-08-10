//==================================================================================================================
//								
//										PickList.js
//
//		Script which creates a pop-up pick list with keyboard and mouse support.
//		Similar to Popmenu, but handles hierarchical items and long lists of
//		items.
//
//		(All functions are prefixed with ICWPL_ to prevent clashes with common function names
//		in other scripts.)
//
//		Useage:
//
//		//Create a new pick list object
//		var objPick = new ICWPickList('Your Title', cmdAnyButton, MyReturnFunction);
//
//		//Populate it using an XML node AND/OR use the AddRow method
//		var objXMLNode = xmlIsland.XMLDocument.selectSingleNode('root');
//		void objPick.PopulateFromXMLNode(objXMLNode, 'NodeNamesToShow');
//
//		void objPick.AddRow(lngSomeID, true, 0, 'ClassName', 'TextForDisplay');
//
//		//And display it
//		void objPick.Show(intLeft, intTop, 300, 400);
//
//		Where MyReturnFunction has the form:
//
//		function MyReturnFunction(lngReturnValue, strReturnDescription, strReturnClass) {
//		}
//
//		And the XML Document contains a flat or hierarchical XML document.
//		Only nodes called the specified name will be displayed in the picker.
//		Each node must have an ID attribute which is named [NodeName]ID, and
//		a Detail field which is the text used for display.  If no Detail field is
//		found, the Description field is used.
//			<NodeName NodeNameID="123" Detail="123" Description="abc".... />
//		
//		Modification History:
//		05Jun03 AE  Written
//		04Oct03 AE  Ensure the event can't escape from here - prevents keyboard event storms.
//		07Nov03 AE - now looks for description field if no detail field found.  
//						 This and other fixes to take account of changes to the ScheduleTemplate stuff.  
//		01Sep04 AE - Show method.  Top, Left parameters are now RELATIVE to the objCallingControl 
//						 passed to the constructor.
//		08Oct04 AE  ICWPL_PopupReturn: Moved tidy up before callback to prevent re-entrancy problems.
//		05Sep06 AE  ICWPL_PickerKeyDown: #SC-06-0827 Prevent error when nothing is selected
//
//==================================================================================================================

var m_objPop = undefined;									//Reference to the pop-up object itself.
var m_objButton = undefined;								//Reference to the button used to show the picker
var m_fpReturn = undefined;									//Pointer to the function to be called when an item is selected
var m_strHTMLBuffer = new String(); 						//Buffer used to build up HTML
var m_intHeight;					 						//Height of popup to scroll list when navigating with keyboard


//=========================================================================================================================================================
//										Constructor
//
//	strTitle:					Title displayed at the top of the popup
//	objCallingControl:		Control used to capture key presses.  Typically, the button used to launch the control
//	fpReturnFunction:			Pointer to the function to be called when the user has selected an item
//
//=========================================================================================================================================================
function ICWPickList(strTitle, objCallingControl, fpReturnFunction)
{
	//Constructor function for the class

	//Create a popup object
	m_objPop = window.createPopup();

	//Store refs to the calling control and return function
	m_objButton = objCallingControl;
	m_fpReturn = fpReturnFunction;

	//Build the generic part of the HTML
	m_strHTMLBuffer = ICWPL_PopupHeaderHTML(strTitle);

	//Methods
	this.PopulateFromXMLNode = ICWPL_ScriptFromXML;
	this.AddRow = ICWPL_AddSingleRow;
	this.Show = ICWPL_ShowPicker;

	//Return Property
	this.selectedID = -1;
	this.selectedDescription = '';
}

//==================================================================================================================
//													Public Methods
//==================================================================================================================

function ICWPL_ScriptFromXML(objXMLElement, strNodeName)
{
	//Public method attached to PopulateFromXMLNode.   Creates the HTML
	//for the popup from the given xml element.

	var strHTML = ICWPL_ScriptChildren(objXMLElement, strNodeName, 0);
	m_strHTMLBuffer += strHTML;
}

//==================================================================================================================

function ICWPL_AddSingleRow(lngID, blnSelectable, intIndent, strClass, strDescription)
{
	//Public method attached to AddRow.  Allows a single row to be added manually.
	//Create the row:
	var strHTML = ICWPL_CreatePopupRow(lngID, blnSelectable, intIndent, strClass, strDescription);
	m_strHTMLBuffer += strHTML;
}

//==================================================================================================================

function ICWPL_ShowPicker(intLeft, intTop, intWidth, intHeight)
{
	//Launches the pick list and passes control to it.
	//When the user selects an item, the function specified in fpReturn is called.

	//Finish the HTML and store in the popup:
	m_strHTMLBuffer += '</table>'
						  + '</div>';

	m_objPop.document.body.innerHTML = m_strHTMLBuffer;

	//Set the selected row, default properties, etc.	
	m_objPop.document.body.style.backgroundColor = BACKGROUND_COLOUR;
	void m_objPop.document.body.setAttribute('selectedrow', -1);

	//Attach keydown events to the calling control for keyboard support
	void m_objButton.detachEvent('onkeydown', ICWPL_Picker_KeyDown);	// detach first in case event already exists (does not error if doesn't already exists so safe to do this)
	void m_objButton.attachEvent('onkeydown', ICWPL_Picker_KeyDown);

	//And display it:
	m_intHeight = intHeight;
	void m_objPop.show(intLeft, intTop, intWidth, intHeight, m_objButton); 		//01Sep04 AE  Added m_objButton
}

//==================================================================================================================
//								Internal	Construction Methods
//==================================================================================================================
function ICWPL_PopupHeaderHTML(strTitle)
{
	//Returns the standard HTML for the top of the popup

	var strHTML = '<div style="overflow-y:auto;height:100%; border:1 solid;">'
			  	+ '<div style="font-weight:bolder; font-family:arial;font-size:12pt" '
			  	+ '>'
			   + 'Select a ' + strTitle + ':</div>';
	strHTML += '<table id="tblPMList" style="width:100%" '
				+ 'style="'
				+ 'font-family:arial;'
				+ '">';

	return strHTML;
}

//==================================================================================================================

function ICWPL_ScriptChildren(objXMLElement, strNodeName, intIndent)
{
	//Script the immediate children of this element
	//
	//	objXMLElement:			iXML DOM Element containing one or more elements to script
	//	strNodeName:			Name of the child nodes to search for
	//	intIndent:				Used for recursive calls, to indicate how far down the tree we are

	var colItems = new Object();
	var intCount = new Number();
	var lngID = new Number();
	var blnSelectable = false;
	var objItem = new Object();
	var strHTML = new String();

	var strIDAttribute = strNodeName + 'ID';
	colItems = objXMLElement.selectNodes(strNodeName);

	for (intCount = 0; intCount < colItems.length; intCount++)
	{
		objItem = colItems(intCount);
		lngID = objItem.getAttribute(strIDAttribute);
		blnSelectable = (objItem.getAttribute('noselect') != '1');
		strDescription = objItem.getAttribute('Detail');

		if (strDescription == '' || strDescription == null)
		{															//07Nov03 AE - now looks for description field if no detail field found
			strDescription = objItem.getAttribute('Description');
		}

		strHTML += ICWPL_CreatePopupRow(lngID, blnSelectable, intIndent, strNodeName, strDescription);

		if (objItem.selectNodes(strNodeName).length > 0)
		{
			//This item has children, script them
			strHTML += ICWPL_ScriptChildren(objItem, strNodeName, (intIndent + 1));
		}
	}

	return strHTML;
}
//==================================================================================================================

function ICWPL_CreatePopupRow(lngID, blnSelectable, intIndent, strClass, strDescription)
{
	var strAttrs = new String();
	var strStyle = new String();
	var strHTML = new String();
	var strSpaces = new String();

	//Build the indenting string
	for (intCount = 0; intCount < intIndent; intCount++)
	{
		strSpaces += '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
	}

	if (blnSelectable)
	{
		//This can be selected
		strAttrs += 'onclick="parent.ICWPL_PopupReturn(this)" '
		strStyle = 'cursor:hand;'
	}
	else
	{
		//Mark this as not selectable
		strAttrs += 'noselect="1"';
	}

	//Add standard attributes & event handlers
	strAttrs += 'onmouseover="parent.ICWPL_Popup_MouseOver(this)" '
 				 + 'onmouseout="parent.ICWPL_Popup_MouseOut(this)" '
 				 + 'dbid="' + lngID + '" '
 				 + 'ascclass="' + strClass + '" ';

	if (intIndent == 0)
	{
		strStyle += 'border-top:#838383 1 solid;';
	}
	strStyle = 'style="' + strStyle + '" ';

	//Build this row
	strHTML += '<tr ' + strAttrs + '>'
			  + '<td ' + strStyle + '>' + strSpaces + strDescription + '</td>'
			  + '</tr>';

	return strHTML;
}

//==================================================================================================================
//										Event Handlers
//==================================================================================================================
function ICWPL_Picker_KeyDown()
{
	switch (window.event.keyCode)
	{
		case 38:
			//Cursor UP
			window.event.returnValue = false; 																	//04Oct03 AE  Ensure the event can't escape from here
			window.event.cancelBubble = true;
			void ICWPL_MoveFocus(-1);
			break;

		case 40:
			//Cursor DOWN
			window.event.returnValue = false; 																	//04Oct03 AE  Ensure the event can't escape from here
			window.event.cancelBubble = true;
			void ICWPL_MoveFocus(1);
			break;

		case 13:
			//RETURN key
			//Stop the event before it does anything stupid.
			window.event.returnValue = false; 																	//04Oct03 AE  Ensure the event can't escape from here
			window.event.cancelBubble = true;

			//Select this item
			var thisRow = m_objPop.document.body.getAttribute('selectedrow');
			if (Number(thisRow) > -1)
			{																					//05Sep06 AE SC-06-0827 Prevent error when nothing is selected
				var objRow = m_objPop.document.body.all['tblPMList'].rows[thisRow];
				if (objRow.getAttribute('noselect') != '1')
				{
					void ICWPL_PopupReturn(objRow);
				}
			}
			break;
	} 
}

//==================================================================================================================

function ICWPL_MoveFocus(deltaValue)
{
	var thisRow = m_objPop.document.body.getAttribute('selectedrow');
	var newRow = eval(thisRow) + eval(deltaValue);

	if (newRow > -1 && newRow < m_objPop.document.all['tblPMList'].rows.length)
	{
		//Do the move

		var objNewRow = m_objPop.document.all['tblPMList'].rows[newRow];
		var objOldRow = m_objPop.document.all['tblPMList'].rows[thisRow];

		m_objPop.document.body.setAttribute('selectedrow', newRow);
		void ICWPL_Popup_HighlightRow(objNewRow);
		objNewRow.scrollIntoView(false);
		if (objOldRow != undefined) { void ICWPL_Popup_UnHighlightRow(objOldRow); }
	} 
}

//==================================================================================================================

function ICWPL_PopupReturn(objRow)
{
	//Close down the popup
	void m_objPop.hide();

	//Return the selected item:
	var retValue = objRow.getAttribute('dbid');
	var retClass = objRow.getAttribute('ascclass');
	var retDescription = objRow.cells[0].innerText;

	//Get the return function
	var fpReturn = m_fpReturn;

	//Tidy up
	void ICWPL_Closedown(); 																				//08Oct04 AE  Moved tidy up before callback to prevent re-entrancy problems

	//Route to the correct handler function to interpret the result	
	void fpReturn(retValue, retDescription, retClass);
}

//==================================================================================================================

function ICWPL_Closedown()
{
	//Ensure all events detached etc
	void m_objButton.detachEvent('onkeydown', ICWPL_Picker_KeyDown);

	m_objPop = undefined;
	m_objButton = undefined;
	m_fpReturn = undefined;
	m_strHTMLBuffer = '';

	window.returnValue = false;
	window.cancelBubble = true;
}	

//==================================================================================================================

function ICWPL_Popup_MouseOver(objRow)
{
	//Highlight the row
	void ICWPL_Popup_HighlightRow(objRow);
	void objRow.parentElement.parentElement.parentElement.parentElement.setAttribute('selectedrow', objRow.rowIndex);
}

//==================================================================================================================

function ICWPL_Popup_MouseOut(objRow)
{
	//Remove the highlighting from this row
	void ICWPL_Popup_UnHighlightRow(objRow);

	//And also from the currently selected row, which may be different
	var oldRow = objRow.parentElement.parentElement.parentElement.parentElement.getAttribute('selectedrow');
	var objOldRow = objRow.parentElement.parentElement.rows[oldRow]
	void ICWPL_Popup_UnHighlightRow(objOldRow);
}

//==================================================================================================================

function ICWPL_Popup_HighlightRow(objRow)
{
	//Highlight the given row

	objRow.style.backgroundColor = SELECTED_BACKGROUND_COLOUR;
	objRow.style.color = '#ffffff';
}

//==================================================================================================================

function ICWPL_Popup_UnHighlightRow(objRow)
{
	//Unhighlight the given row
	objRow.style.backgroundColor = BACKGROUND_COLOUR;
	objRow.style.color = '#000000';
}