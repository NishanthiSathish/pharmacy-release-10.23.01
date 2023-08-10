/*

								POPMENU.JS

	Creates a standard pop-up menu for use with right-click etc.
	The calling script MUST include the following function:
	
	PopMenu_ItemSelected(lngSelectedIndex, strSelectedDescription)
	
	This function is called when the user chooses an item from the menu.


	Useage:
	
		1: Create a new ICWPopupMenu object.
		2: Add menu items to it.
		3: Call its Show method.
		4: The selected item (if any) is reported to a function
			called PopMenu_ItemSelected

	
	Functions:
	
		ICWPopupMenu():													Constructor.
		AddItem(sDescription, lngID, blnEnabled)					Add a menu item.
																					sDescription: Text to display, or '-' to make a separator
																					lngID: Numerical item data.  Reported when an item is selected
																					blnEnabled: set to False to disable the item
		Show(x,y, oElement)												Show the menu at the specified screen co-ordinates, relative to oElement
																					If oElement can be left blank, then x,y willl be relative to the desktop
		
			
	Example:
	
		function ShowRightClickMenu(x, y) {

			var objPopup = new ICWPopupMenu();						//Create a new object
		
			objPopup.AddItem('Menu Item 1', 1, true);				//Add a menu item
			objPopup.AddItem('-', 3, true);							//Passing '-' as a description creates a separator bar
			objPopup.AddItem('Menu Item 3', 4, false);			//Add a disabled menu item
		
			objPopup.Show(x, y);											//Now show the menu
		}
		
		
		function PopMenu_ItemSelected(selIndex, selDesc) {		//This function is called when an item is selected
			alert('you selected: ' + selDesc);
		}


	Modification History:
	04Feb03 AE  Set cursorstyle to default over the menu
	04Jun03 PH  Added Style parameter to the constructor, an oElement to the show method
	30Jul03 AE  ICWPM_StandardHTML:  Added onselectstart handler to prevent drag-selecting.  This
					has only become a problem in IE6.
	07Feb06 AE  Added Image support and slight HTML restructuring.

*/

//-------------------------------------------------------------------------------

//Sizing constants
var MENUITEM_HEIGHT = 16;
var MENUITEM_WIDTH = 7.5;						//an average width of each character in the menu; not exact but close enough.
var IMAGE_CELL_TOTAL_WIDTH = 23;				//Approx size of image cell + padding and margins etc.  Ditto
var MIN_WIDTH = 120;

//Module level reference to the HTML popup menu
var m_objPop;
var maxChars = 0;
var m_blnContainsImages = false;

//Styling variables
var BORDER_HIGHLIGHT = '#E5EEFF';
var BORDER_LOWLIGHT = '#91B5FF';
var BACKGROUND_COLOUR = '#D6E3FF';
var SELECTED_BACKGROUND_COLOUR = '#00599C';

//-------------------------------------------------------------------------------

function ICWPopupMenu() {

//Constructor for the ICWPopupMenu class

	m_objPop = window.createPopup();
		
	//Properties and Methods
	this.AddItem = AddMenuItem;	
	this.popupObject = m_objPop;
	this.Show = ShowMenu;
	this.selectedID = -1;
	this.selectedDescription = '';

	//Create the standard HTML parts of the pop-up
	m_objPop.document.body.innerHTML = ICWPM_StandardHTML();

}

//-------------------------------------------------------------------------------

function ShowMenu(x,y, oElement){

//Display the pop-up menu
	var menuHeight = MENUITEM_HEIGHT * (this.popupObject.document.all['tblItems'].rows.length + 1);
	this.popupObject.document.all['outerDiv'].style.height = menuHeight;
	
	var menuWidth = maxChars * MENUITEM_WIDTH;
	if (m_blnContainsImages) menuWidth += IMAGE_CELL_TOTAL_WIDTH;										//Add on a bit for images if present
	if (menuWidth < MIN_WIDTH) {menuWidth = MIN_WIDTH;}

	this.popupObject.show(x,y,menuWidth,menuHeight, oElement);	

}


//-------------------------------------------------------------------------------

function AddMenuItem(strItemDescription, varItemID, blnEnabled, blnTicked, strImageURL) {

/* 
	 Add an item to the table on the pop-up module.
		
		strItemDescription: Text to display, or '-' for a horizontal rule
		varItemID: Unique ID of this item 
		blnEnabled: specifies if the item is enabled or disabled.
		blnTicked (optional):	If true or false, creates a checkbox control with the state set
										according to blnTicked.  If not specified, or set to null, no checkbox is created.
		strImageURL(optional):	Allows you to specify an image, shown to the left of the item. Pass '' to use a blank
										image.


	07Feb06 AE  Added image parameter, slightly restructured HTML to cope
*/

var strContents = new String();
var strHTML = new String();
var strImage = '';

	var objTable = this.popupObject.document.all['tblItems'];
	var objRow = objTable.insertRow();
	objRow.setAttribute('menuid', varItemID);
	
	//Add the image, if specified
	strItemDescription = strItemDescription.toString();
	if (strImageURL != undefined){
		strImage = '<img style="height:16px;width:16px;'
		if (!blnEnabled) strImage += 'filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1)';
		strImage += '"  onmouseover="parent.ICWPM_MouseOver(this)" '
	 				+ 'onmouseout="parent.ICWPM_MouseOut(this)" '
	 				+ 'onmousedown="parent.ICWPM_MouseDown(this);" ';
		if (strImageURL == '') strImageURL = '../../images/ocs/classSetEmpty.gif';
		strImage += ' src="' + strImageURL + '" />';
	}
	
	
	if (strItemDescription == '-') {
	//Add an HR rather than a real item
		strContents = '<HR>	';
	}
	else {
		strContents = '<span '
		if (!blnEnabled) {strContents += 'disabled ';}
		strContents += 'onmouseover="parent.ICWPM_MouseOver(this)" '
		 				 + 'onmouseout="parent.ICWPM_MouseOut(this)" '
		 				 + 'onmousedown="parent.ICWPM_MouseDown(this);" '
						 + 'style=" '
			 			 + 'width:100%;height:100%; '
			 			 + 'padding-left:5px; '
			 			 + 'padding-right:15px; '
			 			 + 'padding-top:0px; '
			 			 + 'padding-bottom:0px; '
			 			 + 'overflow:visible; '
			 			 + 'cursor:default; '
			 			 + '" '
			 			 + '>'
			 			 + strItemDescription 
			 			 + '</span>';

	}

	if (strImage != ''){
		var objImageCell = objRow.insertCell();
		objImageCell.innerHTML = strImage;
		objImageCell.style.paddingRight = '3px';
		objImageCell.style.paddingLeft = '3px';
		objImageCell.style.paddingTop = '0px';
		objImageCell.style.paddingBottom = '0px';
		m_blnContainsImages = true;
	}

	var objCell = objRow.insertCell();
	objCell.style.height = MENUITEM_HEIGHT + 'px';
	objCell.style.width = '100%';
	objCell.style.paddingTop = '0px';
	objCell.style.paddingBottom = '0px'
	objCell.innerHTML = strContents;
	
	if (typeof(blnTicked) == 'boolean') {														//30Apr04 AE  Added ticked items
	//Add a check box
		var objCheckCell = objRow.insertCell();
		strContents = '<input type="checkbox" ' 
						+ 'value="' + blnTicked + '" />'
		objCheckCell.style.height = MENUITEM_HEIGHT + 'px';
		objCheckCell.style.paddingTop = '0px';
		objCheckCell.style.paddingBottom = '0px'
		objCheckCell.innerHTML = strContents;	
	}
		
	//Update the max number of characters
	if (strItemDescription.length > maxChars) {maxChars = strItemDescription.length;}
}

//-------------------------------------------------------------------------------

function ICWPM_StandardHTML() {
	
// Returns the standard HTML framework for the popup menu.

	var strHTML = '<div id="outerDiv" '
					+ 'style="'
					+ 'height:100%; width:100%; '
					+ 'border-top:' + BORDER_HIGHLIGHT + ' 2 solid;'
					+ 'border-left:' + BORDER_HIGHLIGHT + ' 2 solid;'
					+ 'border-right:' + BORDER_LOWLIGHT + ' 2 solid;'
					+ 'border-bottom:' + BORDER_LOWLIGHT + ' 2 solid;'
					+ 'cursor:default;'
					+ '" '
					+ 'onselectstart="return false;" '
					+ '>'
					+ '<div id="mainDiv" ' 
					+ ' style="'
					+ 'height:100%; width:100%; '
					+ 'background-color:' + BACKGROUND_COLOUR + ';'
					+ '" >'
					+ '<table id=tblItems width=100% height=100% '
					+ 'cellpadding=0 cellspacing=0 '
					+ 'style="' 
					+ 'font-family:arial; '
					+ 'font-size: 8pt; '
					+ '" >'
					+ '</table>'
					+ '</div>';
	
	return strHTML	
	
	
}

//---------------------------------------------------------------------------

function ICWPM_MouseOver(objCell) {

//Highlight the row
//Longhand to avoid stylesheet problems when running in dodgy web controls rather than proper browsers.
	var objRow = objCell.parentElement.parentElement;
	for (i = 0; i < objRow.cells.length; i ++){
		objRow.cells[i].style.backgroundColor=SELECTED_BACKGROUND_COLOUR;
		objRow.cells[i].style.color='#ffffff';
	}
}

//---------------------------------------------------------------------------

function ICWPM_MouseOut(objCell) {
//Remove the highlighting
	var objRow = objCell.parentElement.parentElement;
	for (i = 0; i < objRow.cells.length; i ++){
		objRow.cells[i].style.backgroundColor=BACKGROUND_COLOUR;
		objRow.cells[i].style.color='#000000';
	}
}

//---------------------------------------------------------------------------

function ICWPM_MouseDown(objCell) {
	
//Call the return function.
//Exits quietly if the function is not available.
	//Hide the pop-up
	m_objPop.hide();
	
	//Attempt to call the function
	try{
		var objRow = GetTRFromChild(objCell);
		void PopMenu_ItemSelected (objRow.getAttribute('menuid'), objRow.innerText);
	}
	catch (err) {}
	
}

//---------------------------------------------------------------------------
