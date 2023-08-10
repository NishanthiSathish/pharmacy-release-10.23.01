/*

OCSGrid.js

Script which provides support for the grids used in the order comms system, 
eg the pending orders and work list applications.
	
The data to be displayed is scripted to the client as an XML data island.
This script contains the routines which display pages of this data to the
screen, navigate between pages, column sorting and resizing, etc.

Specific routines which deal with the actions which can be performed 
on each item are held in separate script files as these are specific
to each different page.

Useage:
Include this script.
In the Body tag add the following event handlers:
		
<body 
onLoad="InitialisePage();" 		- For ICW applications, the call to InitialisePage() should be in the Initialise() function
>
		
Functions for use from other scripts (the "public interface" of the grid):
		
GetCurrentRowXML()					- Returns an iXMLDomElement for the currently focussed row.  NB: In multiselect mode, this may not be a selected (highlighted) row
GetHighlightedRowXML()				- Returns an iXMLDomNodeList containing an element for each currently highlighted (selected) row.
GetRowXML(rowIndex)					- Returns the XML Dom node for the specified row.
GetTypeItem(xmlItem)					- Returns an iXMLDomElement holding the type definition for the specified item (eg, if xmlItem holds a request, we return its RequestType)
GetTypeItem_Batch(colItems)		- Returns an XML Document containing all of the type definitions for the items specified.
FocusFirstRow()						- Moves the row highlight to the very first row.			
MoveFocus('up'|'down')				- Moves the row highlight 1 row as specified.
IsItemSet(objXMLNode)				- Given an XML Dom Node, returns TRUE if it has child items.
IsOrderset(objXMLNode)				- Given an XML Dom Node, returns TRUE if it is an Orderset.
IsInOrderset(objXMLNode)			- Given an XML Dom Node, returns TRUE if it is contained within an orderset.
RowCount()								- Returns the number of rows in the grid
GetStylusMode()						- Returns TRUE if the grid currently has stylus mode turned on.		
ToggleStylusMode()					- Toggles the stylus mode between on and off
GetGridXML()							- Returns the XML DOM for the grid's entire data island.
GetHTMLRowFromXML(xmlItem)			- Returns the TR element in the grid which represents the given xml item
				
"Events"
		
ItemMouseClick(colItems)			- Function is optional, it is called when an item is left-clicked on, 
after the focus has moved, and returns the a collection of xml elements representing the selected rows
ItemContextClick(colItems)			- Fires when an item is right-clicked, OR if stylus mode is on,
when the highlighted row is left-clicked.  Intended for use
in showing context menus.													  	  
ItemDoubleClick(objRow)				- Function is optional.  Called when the user double clicks on a row
ItemKeypress(keyCode, colItems)	- Function is optional.  It's called when the user presses a key (apart
from one of the cursor keys) on a row, and returns the keycode and 
an iXMLDomNodeList of XML elements, one for each highlighted row
StylusModeChange(blnNewMode);		- Fires when the Stylus mode is changed
OCSGridRowChange();					- Fires when the highlight is moved, or when a new row is highlighted in multiselect mode.  
Fires AFTER mouseclick and keypress events

Requires: OCSImages.js
ICWFunctions.js
	
Modification History:
12Dec02 AE  Written
22Jan03 AE  Modifications to GetRowHTML; Item sets now include dateinfo and status attributes.
GetXMLNodeFromHTMLSpan: Modified so that the unique key of each item is based on 
class and dbid, to prevent any possibility of duplicates.	
15Feb03 AE  Added ItemKeyPress event.
19Feb03 AE  Major internal restructuring.  
30May03 AE  GetCurrentProgenitorXML: Corrected xPath (added . before //*) as the function
was not returning the correct node in all circumstances.  Also, now returns
a reference to the current node if it is already at the top level.
26Jun03 AE  IsItemSet:  Was considering ocsimage nodes as children, hence singleton items were
being reported as sets.  Now fixed.
27Jun03 AE	ExpandNode: Bug fix; child nodes which were siblings of child nodes which had children
were not displayed.
02Jul03 AE  GetCurrentRowXML: Now deals with the case when no row is selected.
04Sep03 AE  ToggleStylusMode: Now raises an event when fired.
05Mar04 AE  GetHTMLRowFromXML: Written

??Feb06 AE  Implemented Multiselection in the grid.  This has entailed changes to the inernals AND the 
public interface of the grid. 
10Feb06 ST  RowIsInView() Added and GridKeyDown() modified to check row and scroll correctly so
that highlight bar doesn't get lost when the container scrolls.
22Feb07 CJM	HighlightRow() changed to set blnRowChange to true when deselecting a row in multiselect mode so that an
OCSGridRowChange() is triggered to review the status of the toolbar buttons.  
Also added code to handle toggling selection of current row when CTRL key is held down.
10Aug07 CJM Rather radical rewrite of the row selection process
02Sep08 AE  InitialisePage() - Added RowChange event here as it was no longer being called, resulting in a highlighted
row which didn't match the rest of the world.
10/05/10    LAW     Added function AlternateRowColour() this is for alternating grid colours
27Jun11 Rams    (F0117256 - Ward and consultant lookup)
*/
//--------------------------------------------------------------------------

var m_blnMasterDisable = false;
var m_objCurrentRow = undefined; 														//Currently selected row.  When performing multiselection, this is the row indicated by the focus box
var m_aobjHighlightedRows = new Array(); //SC-07-0433	undefined;							//Array of object references to any currently highglighted rows
var m_blnStylusMode = false;
var m_objWaitWindow;
var m_strLastDirection = '';
var m_timerID;

//==================================================================================
//										Event Handler Gubbins
//==================================================================================

function InitialisePage(blnFocusFirstRow) {
    //Standard initialise method.
    //Highlight the first row
    //if (typeof(gridInfo)!="undefined") gridInfo.innerText = RowCount() + ' Item' + ((RowCount() != 1) ? 's' : '');
    UpdateGridItemCount();

    if (blnFocusFirstRow == undefined || blnFocusFirstRow) {
        void FocusFirstRow();
        RaiseRowChangeEvent(); 																							//02Sep08 AE  Moved rowchange event here as it no longer fires in FocusFirstRow
    }
    else {
        try {
            document.body.setActive(); 																						//13May05 AE  Added SetActive to prevent focus being left behind    
        }
        catch (e) {
        }

        tblGrid.focus();
    }
}

function UpdateGridItemCount() {
    if (typeof (gridInfo) != "undefined") {
        var GridItemCount = RowCount(true);
        gridInfo.innerText = GridItemCount + ' Item' + ((GridItemCount != 1) ? 's' : '');
    }
}

//==================================================================================

function ClearSelection() {
    //10Aug07 CJM
    if (m_aobjHighlightedRows != null) {
        for (var x = 0; x < m_aobjHighlightedRows.length; x++) {
            SetRowHighlight(m_aobjHighlightedRows[x], false);
        }
    }

    m_aobjHighlightedRows = new Array();
}

//=================================================================================

var UseAlternateColours = false;
var MainColour = "#FFFFFF";
var AlternateColour0 = "#FFFFE5";
var AlternateColour1 = "#E5E5FF";
var AlternateColour2 = "#E5FFE5";
var AlternateColour3 = "#FFE5E5";
var AlternateColour4 = "#FFE5FF";
var AlternateColour5 = "#E5FFFF";

$(document).ready(function () {
    AlternateRowColour();
    $("#tblGrid[class = 'GridTable']").mousedown(function () { AlternateRowColour(); });
    $("#tblGrid[class = 'GridTable']").keydown(function () { AlternateRowColour(); });
});

function AlternateRowColour() {
    if (UseAlternateColours) {
        var lastIndent = -1;
        var lastRowHightlighted = new Array();
        var AlternateColour = new Array(AlternateColour0, AlternateColour1, AlternateColour2, AlternateColour3, AlternateColour4, AlternateColour5);
        $("tr.GridRow").each(function (index, value) {
            if (IsVisible(value)) {
                var indent = new Number(value.getAttribute('indentLevel'));
                if (indent > lastIndent) { lastRowHightlighted[indent] = false }
                value.style.setAttribute("backgroundColor", lastRowHightlighted[indent] ? MainColour : AlternateColour[indent % 6]);
                lastRowHightlighted[indent] = !lastRowHightlighted[indent];
                lastIndent = indent;
            }
        });
    }
}

function IsVisible(domElement) {
    displayType = domElement.style.display;
    return displayType == "inline" || displayType == "block" || displayType == "";
}

//==================================================================================

function ClearSelectionAndHighlights() {
    //21Jul08 LB
    ClearSelection();
    RemoveFocus();
    m_objCurrentRow = undefined;
}

//==================================================================================

function ExpandAllRows() {
    $("tr[class = 'GridRow'][haschildren = '1']").each(function () {     //   
        ExpandRow($(this).get(0));
    });
}

//=================================================================================

function ContractRow(objRow) {
    //Contract this row	
    var childIndent = new Number();
    var objChild = new Object();
    var strImage = new String();

    var parentIndent = eval(objRow.getAttribute('indentlevel'));
    var rowIndex = objRow.rowIndex;

    void objRow.setAttribute('expanded', '0');

    try {
        if (objRow.all.imgControl != undefined && objRow.all.imgControl != null) {
            objRow.all.imgControl.src = IMAGE_DIR + IMAGE_CLOSED;
        }
        else {
            imgControl.src = IMAGE_DIR + IMAGE_CLOSED; ;
        }
    }
    catch (err) { }

    do {
        rowIndex++;
        if (rowIndex < (tblGrid.rows.length)) {
            objChild = tblGrid.rows[rowIndex];
            //Is this row an arbitary child of objRow?
            childIndent = objChild.getAttribute('indentlevel')
            if (childIndent > parentIndent) {
                //If so, hide it.
                objChild.style.display = 'none';
            }
            else {
                //We've come to the next sibling in the grid, so stop looking.
                break;
            }
        }
    }
    while (rowIndex < tblGrid.rows.length)
    UpdateGridItemCount();
}

//==================================================================================

function ExpandRow(objRow) {
    //Expand this row	
    var childIndent = new Number();
    var objChild = new Object();

    var parentIndent = eval(objRow.getAttribute('indentlevel'));
    var rowIndex = objRow.rowIndex;
    var v11Load = (objRow.getAttribute("QuerySet") != null && objRow.getAttribute("QuerySet") != "");

    //Update this row
    void objRow.setAttribute('expanded', '1');
    try {
        if (objRow.all.imgControl != undefined && objRow.all.imgControl.src != null) {
            objRow.all.imgControl.src = IMAGE_DIR + IMAGE_OPEN;
        }
        else {
            imgControl.src = IMAGE_DIR + IMAGE_OPEN;
        }
    }
    catch (err) { }

    // If this row has a sub query then dynamically load the child records
    if (v11Load) {
        LoadPagedWorklistData(objRow, true);
    }

    do {
        rowIndex++;
        if (rowIndex < (tblGrid.rows.length)) {
            objChild = tblGrid.rows[rowIndex];
            //Is this row a child of objRow?
            childIndent = objChild.getAttribute('indentlevel')
            if (childIndent == (parentIndent + 1)) {
                //If so, display it.
                objChild.style.display = 'block';
                objChild.focus();
                objChild.scrollIntoView(false);

                //If it has children, display them IF it is expanded.
                if (objChild.getAttribute('haschildren') == 1) {
                    if (objChild.getAttribute('expanded') == 1) {
                        void ExpandRow(objChild);
                    }
                }

            }
            else {
                if (childIndent == parentIndent) {																		//27Jun03 AE
                    //We've come to the next sibling in the grid, so stop looking.
                    break;
                }
            }
        }
    }
    while (rowIndex < tblGrid.rows.length)
    UpdateGridItemCount();
}

//==================================================================================

function FocusFirstRow() {
    //Focus on the first row, if there is one.	
    if (RowCount() > 0) {
        // 08-02-2008 PR SupportWorks Ref F0012867
        // Error when sorting worklists with an orderset
        // When setting focus to first row, row is highlighted then a check of highlighted
        // items performed to determine buttons to enable, etc. m_aobjHighlightedRows is
        // used to determine highlighted rows, but is not re-initialised before setting focus
        // Need to re-initialised m_aobjHighlightedRows

        void ClearSelection();

        for (var i = 0; i < tblGrid.rows.length; i++) {
            if (tblGrid.rows[i].className.indexOf("Header") == -1) {
                var row = tblGrid.rows[i];
                void SelectRow(row, true);
                SetFocus(row);
                break;
            }
        }
        document.body.setActive(); 																					//13May05 AE  Added SetActive to prevent focus being left behind
        void tblGrid.focus();
    }
}

//SIK02092011 -- Expand Rows for Episode Selector - Needed a new function as the existing one won't work!!
function ExpandEpisodeSelectorRows() {
    for (i = 0; i < tblGrid.rows.length; i++) {
        if (tblGrid.rows[i].getAttribute('haschildren') == 1) {
            ExpandRow(tblGrid.rows[i]);
        }
    }
}

//==================================================================================

function GetStylusMode() {
    return m_blnStylusMode;
}

//==================================================================================

function GridDoubleClick() {
    //Expand/contract the row if it's a parent, 
    //otherwise just raise the double click event
    var objRow = GetTRFromChild(window.event.srcElement);

    if (objRow.getAttribute('haschildren') == 1) {
        void ToggleRow(objRow);
    }
    else {
        try {
            void ItemDoubleClick(objRow);
        }
        catch (err) { }
    }
}

//==================================================================================

function GridKeyUp() {
    switch (window.event.keyCode) {
        case 38:
            //Cursor UP
            RaiseRowChangeEvent();
            window.event.cancelBubble = true;
            window.returnValue = false;
            break;

        case 40:
            //Cursor DOWN
            RaiseRowChangeEvent();
            window.event.cancelBubble = true;
            window.returnValue = false;
            break;
        case 116: //  F5.
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;
        case 13:  // Return - don't want to capture selection, raising event twice, on both key down and key up
            break;
        default:
            //Raise the ItemKeypress event
            try {
                void ItemKeypress(window.event.keyCode, GetHighlightedRowXML());
                window.event.cancelBubble = true;
                window.returnValue = false;
            }
            catch (err) { };
    }

    //	window.event.cancelBubble = true; GP removed because it stops noEvent.js from working
    //	window.returnValue = false;

    ICWNoEventskeyboardEventHandler();
}

function GridKeyDown() {
    var blnMoveFocusOnly = (MultiselectOn() && window.event.ctrlKey); 									//If ctrl is held, we just move the focus, and leave the highlight where it is
    var blnMultiselect = (MultiselectOn() && window.event.shiftKey); 									//If shift is held, we highlight the next row and add it to the multiselect list
    var isEnterKey = false;
    if (blnMoveFocusOnly && blnMultiselect) blnMultiselect = false; 									//Don't allow both together though!
    switch (window.event.keyCode) {
        case 38:
            //Cursor UP
            window.clearTimeout(m_timerID);
            m_timerID = 0;

            //25Jan2013 Rams    Clicking on empty pending tray and press any arrow key creates script error and new worklistis not accepting any arrow keys
            if (m_objCurrentRow != undefined) {
                void MoveFocus('up', m_objCurrentRow);
                if (!RowIsInView(m_objCurrentRow)) void m_objCurrentRow.scrollIntoView(true);
            }
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;

        case 40:
            //Cursor DOWN

            window.clearTimeout(m_timerID);
            m_timerID = 0;

            //25Jan2013 Rams    Clicking on empty pending tray and press any arrow key creates script error and new worklistis not accepting any arrow keys
            if (m_objCurrentRow != undefined) {
                void MoveFocus('down', m_objCurrentRow);
                if (!RowIsInView(m_objCurrentRow)) void m_objCurrentRow.scrollIntoView(false);
            }
            window.event.cancelBubble = true;
            window.event.returnValue = false;
            break;

        case 39:
            //Cursor RIGHT - expand this node if applicable
            //25Jan2013 Rams    Clicking on empty pending tray and press any arrow key creates script error and new worklistis not accepting any arrow keys	
            if (m_objCurrentRow != undefined) {
                void ToggleRow(m_objCurrentRow, false, true);
                window.event.cancelBubble = true;
            }
            break;

        case 37:
            //Cursor LEFT - collapse this node if applicable
            //25Jan2013 Rams    Clicking on empty pending tray and press any arrow key creates script error and new worklistis not accepting any arrow keys
            if (m_objCurrentRow != undefined) {
                void ToggleRow(m_objCurrentRow, true, false);
                window.event.cancelBubble = true;
            }
            break;

        case 32:
            //space:  When moving using CTRL-cursor keys, selects the current row
            if (window.event.ctrlKey == true) {
                if (RowHighlighted(m_objCurrentRow)) {
                    RemoveRow(m_objCurrentRow);
                } else {
                    //18Oct11   Rams    Tfs12167 - Able to select multiple patients from the Worklists on the AGH Medicines Due Desktop
                    if (!MultiselectOn()) {
                        ClearSelection();
                    }
                    SelectRow(m_objCurrentRow, true);
                }
                window.event.cancelBubble = true;
            }

            break;

        case 16: //  SHIFT
            break;

        case 17: //  CTRL

            break;
        //		case 116: //  F5 
        //			window.event.cancelBubble = true; 
        //			window.event.returnValue = false; 
        //			break; 
        default:
            //Raise the ItemKeypress event
            try {
                if (window.event.keyCode == 13) isEnterKey = true;
                void ItemKeypress(window.event.keyCode, GetHighlightedRowXML());
                window.event.cancelBubble = true;
            }
            catch (err) { };
    }

    //window.event.cancelBubble = true; // gp removed because the noEvent.js will stop working and that file stops F5 etc
    //20Aug14   Rams    96984 - Return value when pressing cancel or esacpe button on the episode selector should be undefined (introduced top.DonotOverrideReturnValue)
    if ((isEnterKey == true && window.parent.document.body.getAttribute("GetReturnValue") != undefined && window.parent.document.body.getAttribute("GetReturnValue").toLowerCase() == "true")
        || top.DoNotOverrideReturnValue) {
        //
        top.DoNotOverrideReturnValue = false;
        // alert('return value passed back');    
    }
    else {
        window.returnValue = false;
    }

    ICWNoEventskeyboardEventHandler();
}

//==================================================================================
function GridMouseUp() {
    RaiseRowChangeEvent();
}

function GridMouseDown() {
    window.clearTimeout(m_timerID);
    m_timerID = 0;

    //Highlight the row, expand it if they've clicked on
    //a control image, and raise the ItemMouseClick event
    var objTR = GetTRFromChild(window.event.srcElement);
    var blnMultiselect = (window.event.ctrlKey == true);
    var blnHighlightBlock = (window.event.shiftKey == true);

    //Is this the row which is already highlighted?
    var blnIsHighlightedRow = false;
    if (m_objCurrentRow != undefined) {
        blnIsHighlightedRow = (objTR.id == m_objCurrentRow.id);
    }
    //30Mar2010 JMei F0080947 only select row when <Tr> selected not something else
    if (objTR.getAttribute('ispadding') != 1 && objTR.innerHTML.toUpperCase().indexOf("<TBODY>") == -1) {
        UpdateCurrentRow(objTR);
    }

    if (window.event.srcElement.id == 'imgControl') {
        //If this is a control box, toggle the row
        void ToggleRow(objTR);
    }
    else {
        //Raise the item mouse click event or context click
        //as appropriate
        if ((blnIsHighlightedRow && m_blnStylusMode) || (window.event.button == 2)) {
            try {
                void ItemContextClick(GetHighlightedRowXML());
            }
            catch (err) { }
        }
        else {
            try {
                void ItemMouseClick(GetHighlightedRowXML());
            }
            catch (err) { }
        }
    }
}

//==================================================================================

function HeaderClick() {
    //Fires when the header row is clicked.

    // V11 worklists don't have sortable columns so we pick up a new attribute on the body tag to see if we are allowed to do so.
    if (document.body.getAttribute("columnsort") == "1") {
        //ShowStatusWindow('Sorting, please wait...');

        //Sort the table by this row
        var objCol = window.event.srcElement;
        while (objCol.nodeName != "TD") {
            objCol = objCol.parentNode;
        }
        var tagName = objCol.tagName;
        tagName = tagName.toLowerCase();
        if (tagName == 'img') { objCol = objCol.parentElement; }

        var intIndex = objCol.getAttribute('colindex');

        if (intIndex != null) {
            if (intIndex >= 0) {
                SortColumn(intIndex);
                ScriptGrid();
                FocusFirstRow();
            }
        }

        // F0079624 ST Check to see if the status message window exists on the parent page before we try to execute it.
        if (window.ShowStatusMessage != undefined) {
            void ShowStatusMessage('');
        }

        if (m_objWaitWindow != null || m_objWaitWindow != undefined) {
            m_objWaitWindow.close();
        }
    }
}

//==================================================================================

function MoveFocus(strDirection, objCurrentRow) {
    //Move focus in the specified direction.
    //	strDirection:			"up"|"down"
    var rowIndex = objCurrentRow.rowIndex;
    var objOrderset;

    if (strDirection != m_strLastDirection) {

        ClearSelection();
    }

    if (strDirection == 'up') {
        if (rowIndex > 0) {
            rowIndex--;

            //  Are we in an orderset and is block mode on - if so we want to go to the item above the orderset rather than us
            objOrderset = OrdersetFromRow(tblGrid.rows[rowIndex]);
            if (BlockSelectOn() && (objOrderset != null)) {
                objCurrentRow = objOrderset;
                rowIndex = objCurrentRow.rowIndex;
            }

            if (rowIndex >= 0) {
                if (tblGrid.rows[rowIndex].style.display == 'none' || tblGrid.rows[rowIndex].getAttribute("searchmore") == "1") {
                    //The next row down is hidden, so try 
                    //the one above that...
                    void MoveFocus('up', tblGrid.rows[rowIndex]);
                }
                else {
                    //Select it
                    UpdateCurrentRowByKey(tblGrid.rows[rowIndex]);
                }
            }
        }
    }
    else {
        if (rowIndex < (tblGrid.rows.length - 2)) {
            //  Are we in an orderset and is block mode on - if so we want to go to the item above the orderset rather than us
            objOrderset = OrdersetLastRow(objCurrentRow);
            if (BlockSelectOn() && (objOrderset != null)) {
                objCurrentRow = objOrderset;
                rowIndex = objCurrentRow.rowIndex;
            }

            if (rowIndex < (tblGrid.rows.length - 2)) {
                rowIndex++;
                if (tblGrid.rows[rowIndex].style.display == 'none' || tblGrid.rows[rowIndex].getAttribute("searchmore") == "1") {
                    //The next row down is hidden, so try 
                    //the one above that...
                    void MoveFocus('down', tblGrid.rows[rowIndex]);
                }
                else {
                    //Select it
                    UpdateCurrentRowByKey(tblGrid.rows[rowIndex]);
                }
            }
        }
    }

    m_strLastDirection = strDirection;
}

//==================================================================================

function OrdersetFromRow(objTR) {
    //  10Aug07 CJM  Returns null if row is not or is not in an orderset
    if (RowIsOrderset(objTR)) {
        return objTR;
    } else if (RowIsInOrderset(objTR)) {
        var xmlParent;
        var xmlCurrentTopmost;

        var xmlItem = GetRowXML(objTR.rowIndex);
        do {
            xmlParent = xmlItem.parentNode;
            if (xmlParent.nodeName != '#document') {
                if (ItemIsOrderset(xmlParent)) {
                    xmlCurrentTopmost = xmlParent;
                }
                xmlItem = xmlParent;
            }
        }
        while (xmlParent.nodeName != '#document')

        return GetHTMLRowFromXML(xmlCurrentTopmost);
    } else {
        return null;
    }
}

//==================================================================================

function OrdersetLastRow(objTR) {
    //  10Aug07	CJM Gets last row in an orderset
    var objChild;
    var childIndent = 0;
    var objLastTR;
    var objOrdersetTR;

    objOrdersetTR = OrdersetFromRow(objTR);
    if (objOrdersetTR == null) {
        return null;
    }

    var parentIndent = eval(objOrdersetTR.getAttribute('indentlevel'));
    var rowIndex = objOrdersetTR.rowIndex;

    objLastTR = objOrdersetTR;

    do {
        rowIndex++;
        if (rowIndex < (tblGrid.rows.length)) {
            objChild = tblGrid.rows[rowIndex];
            //Is this row a child of objRow, and is it in an orderset (we don't want to include
            //child items that aren't in ordersets; for example, any responses to requests would be children,
            //but not part of the orderset)
            childIndent = objChild.getAttribute('indentlevel')
            if (childIndent > parentIndent) {
                //If so, highlight it.
                if (RowIsInOrderset(objChild)) {
                    objLastTR = objChild;
                }
            }
            else {
                //Exit as soon as we reach the bottom of the orderset																												//21Feb06 AE
                break;
            }
        }
    }
    while (rowIndex < tblGrid.rows.length)

    return objLastTR;
}

//==================================================================================

function RemoveRow(objTR) {
    //  Is the row an Orderset
    if (RowIsOrderset(objTR)) {
        SelectedRowRemove(objTR);

        if (BlockSelectOn()) {
            //  for each child add them to the selected list
            var objChild;
            var childIndent = 0;

            var parentIndent = eval(objTR.getAttribute('indentlevel'));
            var rowIndex = objTR.rowIndex;

            do {
                rowIndex++;
                if (rowIndex < (tblGrid.rows.length)) {
                    objChild = tblGrid.rows[rowIndex];
                    //Is this row a child of objRow, and is it in an orderset (we don't want to include
                    //child items that aren't in ordersets; for example, any responses to requests would be children,
                    //but not part of the orderset)
                    childIndent = objChild.getAttribute('indentlevel')
                    if (childIndent > parentIndent) {
                        //If so, add it.
                        if (RowIsInOrderset(objChild)) {
                            void SelectedRowRemove(objChild);
                        }
                    }
                    else {
                        //Exit as soon as we reach the bottom of the orderset																												//21Feb06 AE
                        break;
                    }
                }
            }
            while (rowIndex < tblGrid.rows.length)
        }
    } else if (RowIsInOrderset(objTR)) {
        if (BlockSelectOn()) {
            RemoveRow(OrdersetFromRow(objTR));
        } else {
            SelectedRowRemove(objTR);
        }
    } else {
        SelectedRowRemove(objTR);
    }
}

//==================================================================================

function RaiseRowChangeEvent() {
    //  10Aug07	CJM	Moved from Highlight row so that it could be used once in Highlight block rather than when every row changes
    //              This substantially speeds up multiple selects
    //NOTE:  Did code a window.setTimeout in here, to only call the OCSGridRowChange method after 100ms.  This speeded
    //up rapidly cursoring up/down the grid.  Alas, holding down the ctrl or shift keys with the mouse, as when doing multiselect, 
    //prevents the setTimeout method from actually firing.  Pants.

    if (typeof (OCSGridRowChange) != 'undefined') {
        if (!m_timerID) {
            m_timerID = window.setTimeout(OCSGridRowChange, 100);
        }
    }
}

//==================================================================================

function RowHighlighted(objTR) {
    //Returns true if the specified row exists in m_aobjHighlightedRows, ie is one of the currently highlighted rows.
    var blnReturn = false;
    for (i = 0; i < m_aobjHighlightedRows.length; i++) {
        if (objTR.rowIndex == m_aobjHighlightedRows[i].rowIndex) {
            blnReturn = true;
            break;
        }
    }
    return blnReturn;
}

//==================================================================================

function SelectBlock(objStartRow, objEndRow) {
    //Highlight all rows between objStartRow (already highlighted) and objEndRow (which has just been clicked)
    var objStart;
    var objEnd;
    var objThisRow;
    var start;
    var end;
    //  Sort out the start and end
    if (objStartRow != null) {
        start = objStartRow.rowIndex;
    } else {
        start = 0;
    }
    end = objEndRow.rowIndex;

    if (end < start) {
        var temp = start;
        start = end;
        end = temp;
    }
    //  Now sort out any order sets
    objStart = OrdersetFromRow(tblGrid.rows[start]);
    if (objStart == null) {
        objStart = tblGrid.rows[start];
    }
    start = objStart.rowIndex;
    objEnd = OrdersetLastRow(tblGrid.rows[end]);
    if (objEnd == null) {
        objEnd = tblGrid.rows[end];
    }
    end = objEnd.rowIndex;
    for (var x = start; x <= end; x++) {
        objThisRow = tblGrid.rows[x];
        //F0095701 JMei 10Sep2010 it this item is orderset or displayed, and same time it is the top level of itsself
        // GP Removed for TFS59348 && (objThisRow.getAttribute('indentlevel') == 0)
        if ((ItemIsOrderset(GetRowXML(x)) || (tblGrid.rows[x].style.display != 'none'))) {
            //if it is orderset then try to select what's in that folder
            if (ItemIsOrderset(GetRowXML(x))) {
                void SelectRow(objThisRow, true);
            } else {
                void SelectRow(objThisRow, false);
            }
        }
    }

    SetFocus(objEnd);
}

//==================================================================================

function SelectedRowAdd(objTR) {
    //23Jan06 AE
    if (m_aobjHighlightedRows != undefined) {
        for (var intIndex = 0; intIndex < m_aobjHighlightedRows.length; intIndex++) {
            if (objTR.getAttribute('id') == m_aobjHighlightedRows[intIndex].getAttribute('id')) {
                // 25May08 PH Row is already highlighted, and in the list of highlighted rows, so son't add it again!
                return;
            }
        }
        if (objTR.getAttribute("searchmore") == null || objTR.getAttribute("searchmore") == "") {
            m_aobjHighlightedRows[m_aobjHighlightedRows.length] = objTR;
        }
    }
    else {
        if (objTR.getAttribute("searchmore") == null || objTR.getAttribute("searchmore") == "") {
            m_aobjHighlightedRows = new Array();
            m_aobjHighlightedRows[0] = objTR;
        }
    }

    SetRowHighlight(objTR, true);
}

//==================================================================================

function SelectedRowRemove(objTR) {
    //Remove the specified row from the array
    var aobjTemp = new Array();
    //Copy to temp array, leaving out the one we want to remove
    for (i = 0; i < m_aobjHighlightedRows.length; i++) {
        if (objTR.rowIndex != m_aobjHighlightedRows[i].rowIndex) aobjTemp[aobjTemp.length] = m_aobjHighlightedRows[i];
    }

    //Then copy the temp array back to the real array
    m_aobjHighlightedRows = new Array();
    for (i = 0; i < aobjTemp.length; i++) {
        m_aobjHighlightedRows[i] = aobjTemp[i];
    }

    SetRowHighlight(objTR, false);
}

//==================================================================================

function SelectRow(objTR, propogate) {
    if (propogate) {
        //  Is the row an Orderset
        if (RowIsOrderset(objTR)) {
            SelectedRowAdd(objTR);

            if (BlockSelectOn()) {
                //  for each child add them to the selected list
                var objChild;
                var childIndent = 0;

                var parentIndent = eval(objTR.getAttribute('indentlevel'));
                var rowIndex = objTR.rowIndex;

                do {
                    rowIndex++;
                    if (rowIndex < (tblGrid.rows.length)) {
                        objChild = tblGrid.rows[rowIndex];
                        //Is this row a child of objRow, and is it in an orderset (we don't want to include
                        //child items that aren't in ordersets; for example, any responses to requests would be children,
                        //but not part of the orderset)
                        childIndent = objChild.getAttribute('indentlevel')
                        if (childIndent > parentIndent) {
                            //If so, add it.
                            if (RowIsInOrderset(objChild)) {
                                void SelectedRowAdd(objChild);
                            }
                        }
                        else {
                            //Exit as soon as we reach the bottom of the orderset																												//21Feb06 AE
                            break;
                        }
                    }
                }
                while (rowIndex < tblGrid.rows.length)
            }
        } else if (RowIsInOrderset(objTR)) {
            if (BlockSelectOn()) {
                SelectRow(OrdersetFromRow(objTR), true);
            } else {
                SelectedRowAdd(objTR);
            }
        } else {
            SelectedRowAdd(objTR);
        }
    } else {
        //  Just select this row
        SelectedRowAdd(objTR);
    }
}

//==================================================================================

function RemoveFocus() {
    if (m_objCurrentRow != null) {
        m_objCurrentRow.className = m_objCurrentRow.className.split(' focus').join('');

        var objOrdersetTR = OrdersetFromRow(m_objCurrentRow);
        if ((objOrdersetTR != null) && (objOrdersetTR != m_objCurrentRow)) {
            //  Unhighlight the orderset as well
            objOrdersetTR.className = objOrdersetTR.className.split(' focus').join('');
        }
    }
}


function SetFocus(objTR) {
    //  10Aug07	CJM		Set the current row and apply focus highlighting
    var CLASS_FOCUS = ' focus';

    //  Check we are not resetting to ourself
    if (m_objCurrentRow == objTR) {
        return;
    }

    //  If a row is already current then remove focus from that
    RemoveFocus();

    m_objCurrentRow = objTR;

    if (m_objCurrentRow != null) {
        if (tblGrid.rows[m_objCurrentRow.rowIndex].style.display == 'none') {
            var objOrdersetTR = OrdersetFromRow(m_objCurrentRow);
            if ((objOrdersetTR != null) && (objOrdersetTR != m_objCurrentRow)) {
                //  Unhighlight the orderset as well
                objOrdersetTR.className = objOrdersetTR.className.split(CLASS_FOCUS).join('');
                objOrdersetTR.className += CLASS_FOCUS;
            }
        } else {
            //  Remove focus if already set (for tidyness)
            m_objCurrentRow.className = m_objCurrentRow.className.split(CLASS_FOCUS).join('');
            m_objCurrentRow.className += CLASS_FOCUS;
        }
    }

    // This event now happens on key up or on mouse up - GDW 23/5/08
    //RaiseRowChangeEvent();
}

//==================================================================================

function SetRowHighlight(objTR, blnOn) {
    //  Set highlighting on a single row
    var CLASS_HIGHLIGHT = ' selected';

    if (objTR != null) {
        if (blnOn && !IsHeaderRow(objTR)) {
            objTR.className += CLASS_HIGHLIGHT;
        }
        else {
            //Remove all old highlighting, unless moving a focus box, when we leave the highlight style on the original row
            objTR.className = objTR.className.split(CLASS_HIGHLIGHT).join('');
        }
    }
}

function IsHeaderRow(objRow) {
    if (objRow.className.indexOf("Header") > 0) {
        return true;
    }
    return false;
}

//==================================================================================

function StylusMode(newMode, blnRaiseEvent) {
    //Sets stylus mode on or off
    //	newMode:		boolean

    var strImage = new String();

    m_blnStylusMode = newMode
    if (m_blnStylusMode) {
        strImage = 'StylusModeOn.gif';
        imgStylus.title = 'Click here to turn stylus mode off';
    }
    else {
        strImage = 'StylusModeOff.gif';
        imgStylus.title = 'Click here to turn stylus mode on';
    }
    imgStylus.src = '../../images/ocs/' + strImage;

    //Raise an event to the outside world
    if (blnRaiseEvent) {
        try {
            void StylusModeChange(newMode);
        }
        catch (err) { };
    }
}

//==================================================================================

function ToggleRow(objRow, blnPreventOpen, blnPreventClose) {
    //If this row has children, expand/contract it as
    //appropriate.	

    if (objRow.getAttribute('haschildren') == 1) {
        if (objRow.getAttribute('expanded') == 1) {
            //Contract this row
            if (!blnPreventClose) { void ContractRow(objRow); }
        }
        else {
            //Expand this row	
            if (!blnPreventOpen) { void ExpandRow(objRow); }
        }
    }
}

//==================================================================================

function ToggleStylusMode() {
    //Toggle stylus mode between on and off
    var blnRaiseEvent = (window.event != null); 			//Raise an event if this came from a user action, not from code
    void StylusMode(!m_blnStylusMode, blnRaiseEvent);
}

//==================================================================================

function UpdateCurrentRow(objTR) {
    //18Oct11   Rams    Tfs12167 - Able to select multiple patients from the Worklists on the AGH Medicines Due Desktop
    //  If we have control keys pressed then what do we do
    if (MultiselectOn() && window.event.shiftKey == true) {
        ClearSelection();
        SelectBlock(m_objCurrentRow, objTR);
    } else if (MultiselectOn() && window.event.ctrlKey == true) {
        if (RowHighlighted(objTR)) {
            RemoveRow(objTR);
        } else {
            SelectRow(objTR, true);
        }
    } else {
        ClearSelection();
        SelectRow(objTR, true);
    }
    SetFocus(objTR);
}

//==================================================================================

function UpdateCurrentRowByKey(objTR) {
    //18Oct11   Rams    Tfs12167 - Able to select multiple patients from the Worklists on the AGH Medicines Due Desktop
    //  If we have control keys pressed then what do we do
    if (MultiselectOn() && window.event.shiftKey == true) {
        SelectBlock(m_objCurrentRow, objTR);
    }
    else if (window.event.ctrlKey == true) {
        //  Do nothing re highlighting
    }
    else {
        ClearSelection();
        SelectRow(objTR, true);
    }
    SetFocus(objTR);
}

//==================================================================================
//									Public Properties
//==================================================================================

function RowCount(ignoreHidden) {
    //Returns the number of data rows in the table
    if (typeof (tblGrid) != "undefined") {
        var rowCount = tblGrid.rows.length - 1;
        if (rowCount == 1) {
            //One row could be a padding row, or a real row
            if (tblGrid.rows[0].getAttribute('ispadding') == 1) {
                rowCount = 0;
            }
        }
        if (rowCount < 0) { rowCount = 0; }

        // we need to check to see if there are any search buttons in the grid and if so take those off the total

        if (rowCount > 0) {
            var gridCount = rowCount;
            for (idx = 0; idx < gridCount; idx++) {
                if (tblGrid.rows[idx].getAttribute('searchmore') == "1" || tblGrid.rows[idx].getAttribute("className") == "GridRow Header") {
                    rowCount = rowCount - 1;
                }
                else if (ignoreHidden && tblGrid.rows[idx].style.display == 'none') {
                    rowCount = rowCount - 1;
                }
            }
        }

        return rowCount;
    }
    else {
        return 0;
    }
}

//==================================================================================

function IsItemSet(objXMLNode) {
    //Determine if this item has children which are not <ocsimage> nodes
    var colChildren = objXMLNode.selectNodes('*');
    var colImageNodes = objXMLNode.selectNodes('ocsimage');
    blnReturn = ((colChildren.length - colImageNodes.length) > 0);
    return blnReturn;
}

//==================================================================================
function RowIsOrderset(objTR) {
    //Determine if this item is an orderset.  IsItemSet is true for all ordersets, 
    //but not everything for which IsItemSet is true is an orderset.
    var xmlItem = GetRowXML(objTR.rowIndex);
    return ItemIsOrderset(xmlItem);
}

//==================================================================================
function ItemIsOrderset(xmlItem) {
    if (xmlItem != null) {
        if (xmlItem.nodeName == 'PendingItem') {
            //No separate type data for Pending items
            strClass = xmlItem.getAttribute('class');
            return (strClass == 'ordersetinstance' || strClass == 'orderset');

        }
        else {
            //Everything else...worklists etc.  We use the type to determine if this is an orderset
            var xmlType = GetTypeItem(xmlItem);
            if (xmlType != null) {
                return (xmlType.getAttribute('Description').toLowerCase() == 'order set');
            }
        }
    }
    return false;
}

//==================================================================================
function RowIsInOrderset(objTR) {
    //Determines if this item is in an orderset.  	
    var xmlItem = GetRowXML(objTR.rowIndex);
    if (xmlItem != null) {
        return ItemIsOrderset(xmlItem.parentNode);
    }
    return false;
}


//==================================================================================
function ItemIsSelected(xmlItem) {
    //returns true if the specified item is selected (ie, it is within m_aobjHighlightedRows);
    var blnReturn = false;
    var i = 0;

    var strClass = xmlItem.getAttribute('class');
    var lngID = Number(xmlItem.getAttribute('dbid'));

    if (m_aobjHighlightedRows != undefined) {
        for (i = 0; i < m_aobjHighlightedRows.length; i++) {
            xmlElement = GetRowXML(m_aobjHighlightedRows[i].rowIndex);
            if (xmlElement != null) {
                if (xmlElement.getAttribute('class') == strClass && Number(xmlElement.getAttribute('dbid')) == lngID) {
                    //Found it
                    blnReturn = true;
                    break;
                }
            }
        }
    }
    return blnReturn;
}

//==================================================================================

function GetCurrentRowXML() {
    //Returns an iXMLDomElement object containing the xml definition for the current row.
    //Note that if we are in multiselect mode, this might not be a highlighted row, but the
    //one currently focussed.

    var strID = '';

    //Standard, single select mode
    if (m_objCurrentRow != undefined) {
        strID = m_objCurrentRow.getAttribute('id');
        var xmlElement = gridData.selectSingleNode('root//*[@htmlid="' + strID + '"]');
    }
    else {
        xmlElement = undefined;
    }
    return xmlElement;
}

//==================================================================================
function GetHighlightedRowXML() {
    //Returns an iXMLDomNodeList collection of xml elements, one for each currently 
    //highlighted row.
    var xmlElement;
    var strID = '';
    var objTR;
    var blnInOrderset;
    var xmlParent;
    var i = 0;
    var DOM = new ActiveXObject("MSXML2.DOMDocument");
    var xmlRoot = DOM.appendChild(DOM.createElement('root'));

    if (MultiselectOn()) {
        //In multiselect mode, return an iXMLDomNodeList of all selected rows.
        //Wel, almost all.  Rows in orderset are not returned, because the parent orderset
        //will be selected.  The highlighting of the child rows is done for user feedback, but
        //we only deal with the parent orderset.  This is to ensure consistency, as a worklist
        //query might not return all items in a set, but they must all be considered together by order entry etc.
        if (m_aobjHighlightedRows != undefined) {
            for (i = 0; i < m_aobjHighlightedRows.length; i++) {
                blnInOrderset = RowIsInOrderset(m_aobjHighlightedRows[i]);
                strID = m_aobjHighlightedRows[i].getAttribute('id');
                xmlElement = gridData.selectSingleNode('root//*[@htmlid="' + strID + '"]');
                if (blnInOrderset) {
                    //Check if the orderset itself is selected, don't return this row
                    //If if is.
                    xmlParent = xmlElement.parentNode;
                    if (!blnInOrderset || blnInOrderset && !ItemIsSelected(xmlParent)) {
                        strID = m_aobjHighlightedRows[i].getAttribute('id');
                        xmlRoot.appendChild(xmlElement.cloneNode(false));
                    }
                }
                else {
                    //Singleton item, just return it, only if xmlElement is not null
                    if (xmlElement != null) {
                        void xmlRoot.appendChild(xmlElement.cloneNode(false));
                    }
                }
            }
        }
    }
    else {
        //Standard, single select mode
        if (m_objCurrentRow != undefined) {
            var currentNode = GetCurrentRowXML();
            if (currentNode != null && currentNode != undefined) {
                xmlRoot.appendChild(currentNode.cloneNode(false));
            }
        }
    }
    return DOM.selectNodes('root/*');
}

//==================================================================================

function GetGridXML() {
    //Returns the XML DOM for the grid's entire data island.
    return gridData;
}

//==================================================================================
function MultiselectOn() {
    return (typeof (ocsGrid) != 'undefined' && ocsGrid.getAttribute('multiselect') == 'true'); 																//24Feb06  AE  Added check for undefined ocsGrid
}

//==================================================================================
function BlockSelectOn() {
    return (typeof (ocsGrid) != 'undefined' && ocsGrid.getAttribute('ordersetblockselect') == 'true'); 													//24Feb06  AE  Added check for undefined ocsGrid
}

//==================================================================================

function GetCurrentProgenitorXML() {
    //Not needed, was only used in the PRV
}

//==================================================================================

function GetRowXML(rowIndex) {
    //Return the XML element for the given row
    if (rowIndex >= 0 && rowIndex < RowCount()) {
        var strID = tblGrid.rows[rowIndex].getAttribute('id');
        var xmlElement = gridData.selectSingleNode('root//*[@htmlid="' + strID + '"]');
        return xmlElement;
    }
    else {
        return null;
    }
}

//==================================================================================

function GetHTMLRowFromXML(xmlItem) {
    //Returns a reference to the TR in the grid which 
    //represents the specified xmlItem	

    var strID = xmlItem.getAttribute('htmlid');
    return document.all[strID];
}

//==================================================================================
function GetTypeItem(objXMLItem) {
    //Return the XML element from the types definition
    //for the given XMLItem.
    //Returns null if we don't have it (for types which we have not
    //yet implemented)
    //So if objXMLItem is an XRayOrder, we return
    //the RequestType for that order; similarly for
    //any other data type, if they have been implemented.
    //10Feb06 AE  Moved into here from worklist.js.

    var strXPath = new String();

    var strClass = objXMLItem.getAttribute('class');

    //Build an xpath query according to the type we have:
    switch (strClass) {
        case 'request':
            strXPath = '*/RequestType[@RequestTypeID="' + objXMLItem.getAttribute('RequestTypeID') + '"]';
            break;

        case 'note':
            strXPath = '*/NoteType[@NoteTypeID="' + objXMLItem.getAttribute('NoteTypeID') + '"]';
            break;

        case 'response':
            strXPath = '*/ResponseType[@ResponseTypeID="' + objXMLItem.getAttribute('ResponseTypeID') + '"]';
            break;

        case 'entity':
            strXPath = '*/EntityType[@EntityTypeID="' + objXMLItem.getAttribute('EntityTypeID') + '"]';
            break;

        case 'location':
            strXPath = '*/LocationType[@LocationTypeID="' + objXMLItem.getAttribute('LocationTypeID') + '"]';
            break;

        case 'product':
            strXPath = '*/ProductType[@NoteTypeID="' + objXMLItem.getAttribute('ProductTypeID') + '"]';
            break;
    }

    //Now look for the item in the xml data island
    if (strXPath != '') {
        //Get the item
        //25Sep07  ST  Check to make sure typeData is on the page
        if (document.all['typeData'] != undefined) {
            objReturn = typeData.XMLDocument.selectSingleNode(strXPath);
        }
        else {
            objReturn = null;
        }
    }
    else {
        objReturn = null;
    }

    return objReturn;
}

//==========================================================================================
function GetTypeItemBatch(colItems) {
    //Return an iXMLDOMDocument containing a list of type item xml nodes for the items specified in colItems
    //10Feb06 AE  Written to support multiselect

    var i = 0;
    var strClass = '';
    var xmlElement;
    var xmlItem;
    var strXPath = '';

    var DOM = new ActiveXObject("MSXML2.DOMDocument");
    var xmlRoot = DOM.appendChild(DOM.createElement('root'));

    for (i = 0; i < colItems.length; i++) {
        strClass = colItems[i].getAttribute('class');

        switch (strClass) {
            case 'request':
                strXPath = '*/RequestType[@RequestTypeID="' + colItems[i].getAttribute('RequestTypeID') + '"]';
                break;

            case 'note':
                strXPath = '*/NoteType[@NoteTypeID="' + colItems[i].getAttribute('NoteTypeID') + '"]';
                break;

            case 'response':
                strXPath = '*/ResponseType[@ResponseTypeID="' + colItems[i].getAttribute('ResponseTypeID') + '"]';
                break;

            case 'entity':
                strXPath = '*/EntityType[@EntityTypeID="' + colItems[i].getAttribute('EntityTypeID') + '"]';
                break;

            case 'location':
                strXPath = '*/LocationType[@LocationTypeID="' + colItems[i].getAttribute('LocationTypeID') + '"]';
                break;

            case 'product':
                strXPath = '*/ProductType[@NoteTypeID="' + colItems[i].getAttribute('ProductTypeID') + '"]';
                break;
        }
        if (strXPath != '') {																																		//17Feb06 AE  Avoid looking for types for anything else.
            xmlItem = DOM.selectSingleNode(strXPath);
            if (xmlItem == undefined) {
                //We don't have it, go get it	
                xmlElement = GetTypeItem(colItems[i]);
                if (xmlElement != null) {
                    xmlRoot.appendChild(xmlElement.cloneNode(false));
                }
            }
        }
    }

    return DOM;
}

//==================================================================================
//										Internal Gubbins
//==================================================================================

function SortColumn(intColumnIndex) {
    //Sort according to the given column.  The sort is 
    //actually done on the XML data island, the table is
    //then re-scripted from scratch.
    var strSortAttribute = new String();
    var blnChanged = false;
    var intCount = new Number();
    var colTopLevelRows = new Object();
    var objRoot = new Object();
    var thisNode = new Object();
    var nextNode = new Object();
    var thisValue = new String();
    var nextValue = new String();
    var blnExchange = false;
    var nodeCount = new Number();

    //Map the given column to the appropriate attribute in the XML
    switch (eval(intColumnIndex)) {
        case 0:
            strSortAttribute = 'detail';
            break;

        case 1:
            strSortAttribute = 'dateinfo';
            break;

        case 2:
            strSortAttribute = 'statusdescription';
            break;

        default:
            return;
    }

    //Determine the sort order.  Each time we click on
    //a header, we toggle the sort order.  0 - asc, 1 - desc
    var lastSortOrder = colHeader[intColumnIndex].getAttribute('sortorder');
    if (lastSortOrder == null) { lastSortOrder = 1; }
    var sortOrder = 0;
    if (lastSortOrder == 0) { sortOrder = 1; }

    //Now sort the XML - standard bubble sort
    do {
        blnChanged = false;
        intCount = 0;
        objRoot = gridData.XMLDocument.selectSingleNode('root');

        if (objRoot != null) {
            colTopLevelRows = objRoot.selectNodes('*');
            nodeCount = (colTopLevelRows.length - 1);

            do {
                if (intCount < nodeCount) {
                    //Fetch the next two values to compare
                    thisNode = colTopLevelRows[intCount];
                    nextNode = colTopLevelRows[intCount + 1];

                    thisValue = trim(thisNode.getAttribute(strSortAttribute)); 																						//25Oct06 AE  Added trim to ensure sort works properly
                    nextValue = trim(nextNode.getAttribute(strSortAttribute));

                    if (strSortAttribute == 'dateinfo' && !isNaN(Date.parse(thisValue))) {
                        var thisValueInt = Date.parse(thisValue);
                        var nextValueInt = Date.parse(nextValue);
                        if (sortOrder == 0) {
                            blnExchange = (thisValueInt > nextValueInt); 							//Ascending sort
                        }
                        else {
                            blnExchange = (thisValueInt < nextValueInt); 							//Descending sort
                        }
                    } else {
                        if (sortOrder == 0) {
                            blnExchange = (thisValue > nextValue); 							//Ascending sort
                        }
                        else {
                            blnExchange = (thisValue < nextValue); 							//Descending sort
                        }
                    }

                    if (blnExchange) {
                        //Nodes are out of position, so swap them
                        void objRoot.insertBefore(nextNode, thisNode);
                        blnChanged = true;
                        break;

                    }
                    intCount++;

                }
            }
            while (intCount < nodeCount)
        } 																																	//25Oct06 AE  Changed to use nodeCount
    }
    while (blnChanged)

    //Now update the images and record the sort order.
    if (sortOrder == 0) {
        strImage = 'sortAsc.gif';
    }
    else {
        strImage = 'sortDesc.gif';
    }

    for (intCount = 0; intCount < imgSort.length; intCount++) {
        if (intCount == intColumnIndex) {
            //Set this image to the appropriate sort image
            imgSort[intCount].src = IMAGE_DIR + strImage;
        }
        else {
            //Clear all other images
            imgSort[intCount].src = IMAGE_DIR + IMAGE_EMPTY;
        }
    }

    void colHeader[intColumnIndex].setAttribute('sortorder', sortOrder);
}

//=================================================================================================================

function ScriptGrid() {
    //Rescripts the grid from the XML data island

    //Kill the existing data.  "Wake up...time to die"
    var rowCount = (tblGrid.rows.length);
    for (intCount = 0; intCount < rowCount; intCount++) {
        void tblGrid.deleteRow(0);
    }
    //****	m_objCurrentRow = undefined;
    SetFocus(undefined);

    //Now script the new rows	
    void AddChildRows(gridData.XMLDocument.selectSingleNode('root'), 0);

    //And the padding row
    var objRow = tblGrid.insertRow();
    void objRow.insertCell();
    objRow.style.height = '100%';
    void objRow.setAttribute('ispadding', '1');
    AlternateRowColour();
}

//=================================================================================================================

function AddChildRows(parentXMLNode, intIndentLevel) {
    //Copy all child nodes of this parent node into HTML rows
    //This routine calls itself recursively to populate 
    //further levels of the hierarchy.	

    var intCount = new Number();
    var strHTML = new String();
    var strControlImage = new String();
    var strClassImage = new String();
    var strClass = new String();
    var colChildren = new Object();
    var colImages = new Object();
    var objRow = new Object();
    var objCol = new Object();
    var strColStyle = new String();
    var intImage = new Number();
    var intAttr = new Number();
    var strImageHTML = new String();
    var strOCSType = new String();
    var strNodeName = new String();

    if (parentXMLNode != null) {
        var colItems = parentXMLNode.selectNodes('*')
        for (intCount = 0; intCount < colItems.length; intCount++) {
            strNodeName = colItems[intCount].nodeName.toLowerCase();

            switch (strNodeName) {
                case 'request':
                case 'note':
                case 'episode':
                case 'entity':
                case 'response':
                case 'location':
                case 'product':
                case 'pendingitem':
                case 'allergy':
                case 'allergyreaction':

                    strClass = colItems[intCount].getAttribute('class');
                    colChildren = colItems[intCount].selectNodes('*');
                    colImages = colItems[intCount].selectNodes('ocsimage');

                    //Get the request, response, or note type.  Class is held as lower case, so we uppercase
                    //the first letter and add "Type", to get "RequestType", "ResponseType", "NoteType" etc
                    strOCSType = colItems[intCount].getAttribute(strClass.substring(0, 1).toUpperCase() + strClass.substring(1) + 'Type'); 	//25Oct06 AE  Pass OCSType parameter to GetImageByClass.  Fixes incorrect icons and disapearance #SC-06-1020


                    //Insert the new row
                    objRow = tblGrid.insertRow();
                    objRow.className = "GridRow";
                    void objRow.setAttribute('id', colItems[intCount].getAttribute('htmlid'));
                    void objRow.setAttribute('indentlevel', intIndentLevel);

                    //Hide it if it is a child row.
                    if (intIndentLevel > 0) { objRow.style.display = 'none'; }

                    //Build the description column
                    strClassImage = IMAGE_DIR + GetImageByClass(strClass, strOCSType); 															//25Oct06 AE  Pass OCSType parameter to GetImageByClass.  Fixes incorrect icons #SC-06-1020
                    if ((colChildren.length - colImages.length) > 0) {
                        //This item has children
                        strControlImage = IMAGE_CLOSED;
                        void objRow.setAttribute('haschildren', '1');
                        void objRow.setAttribute('expanded', '0');
                    }
                    else {
                        strControlImage = IMAGE_EMPTY;
                    }

                    strControlImage = IMAGE_DIR + strControlImage;

                    strHTML = '<img id="imgControl" src="' + strControlImage + '"></img>'
							  + '<img id="imgClass" src="' + strClassImage + '"></img>'
							  + '&nbsp;' + colItems[intCount].getAttribute("detail");

                    strHTML = Indent(strHTML, intIndentLevel);

                    objCol = objRow.insertCell();
                    objCol.innerHTML = '<span class="gridCellLiner">' + strHTML + '</span>';
                    objCol.className = 'gridCell';
                    objCol.unselectable = 'on';
                    objCol.style.width = colHeader[0].offsetWidth;
                    if (intCount == 0) { objCol.style.borderTop = 'none'; }

                    //Now the date info column
                    strHTML = colItems[intCount].getAttribute('dateinfo');
                    if (strHTML == '') { strHTML = '&nbsp;' }
                    objCol = objRow.insertCell();
                    objCol.innerHTML = '<span class="gridCellLiner">' + strHTML + '</span>';
                    objCol.className = 'gridCell';
                    objCol.unselectable = 'on';
                    objCol.style.width = colHeader[1].offsetWidth;
                    if (intCount == 0) { objCol.style.borderTop = 'none'; }

                    //And the status column
                    strHTML = colItems[intCount].getAttribute('statusdescription');
                    if (strHTML == '') { strHTML = '&nbsp;' }
                    objCol = objRow.insertCell();
                    objCol.innerHTML = '<span class="gridCellLiner">' + strHTML + '</span>';
                    objCol.className = 'gridCell';
                    objCol.unselectable = 'on';
                    objCol.style.width = colHeader[2].offsetWidth;
                    if (intCount == 0) { objCol.style.borderTop = 'none'; }

                    //And the generic images column
                    strImageHTML = '';
                    for (intImage = 0; intImage < colImages.length; intImage++) {
                        strImageHTML += '<img ';
                        for (intAttr = 0; intAttr < colImages[intImage].attributes.length; intAttr++) {
                            strImageHTML += colImages[intImage].attributes[intAttr].nodeName + '="';
                            strImageHTML += colImages[intImage].attributes[intAttr].value + '" ';
                        }
                        strImageHTML += ' />';
                    }
                    if (strImageHTML == '') { strImageHTML = '&nbsp;' }
                    objCol = objRow.insertCell();
                    objCol.innerHTML = objCol.innerHTML = '<span class="gridCellLiner">' + strImageHTML + '</span>';
                    objCol.className = 'gridCell';
                    objCol.unselectable = 'on';
                    if (intCount == 0) { objCol.style.borderTop = 'none'; }

                    //Now do child rows if we have any
                    if (colChildren.length > 0) {
                        void AddChildRows(colItems[intCount], (intIndentLevel + 1));
                    }
                    break;
            }
        }
    }
}

//=================================================================================================================

function Indent(strHTML, intIndentLevel) {
    //Indent the given text to the given level

    var intCount = new Number();
    var strSpace = new String();

    for (intCount = 0; intCount < intIndentLevel * 6; intCount++) {
        strSpace += '&nbsp;';
    }

    return (strSpace + strHTML);
}

//=================================================================================================================

function RowIsInView(objTR) {
    //Determines if a given row in one of our browsing windows is in view
    var divParent = objTR.offsetParent.offsetParent;

    var intTop = objTR.offsetTop - divParent.scrollTop												//Position of the top of the row
    var intBottom = objTR.offsetTop + objTR.offsetHeight - divParent.scrollTop; 		//Position of the bottom of the row.
    //It is in view if the top is below the top of the scroll window, and 
    //if the bottom is above the bottom of the scroll window
    return ((intBottom <= divParent.clientHeight) && (intTop >= 0));
}

//=================================================================================================================
function ShowStatusWindow(strMsg) {
    // 04Jul07 ST  Displays a message on screen with an hourglass - Use blank string to hide the message.

    var intTop = document.body.offsetHeight / 2;
    var intLeft = (document.body.offsetWidth / 2) - strMsg.length;

    m_objWaitWindow = window.open("", "_blank", "height=100,top=" + intTop + ",left=" + intLeft + ",width=200,status=no,toolbar=no,menubar=no,location=no,titlebar=no", false);
    m_objWaitWindow.document.writeln("<html><body bgcolor=#d6e3ff><div align='center' style='font-family:trebuchet ms; font-size:14px;color:#000000;'>" + strMsg + "<br><br><img id='sp_img' src='../../images/ocs/HourglassWait.gif'/></div></body></html>");
    m_objWaitWindow.document.close();
    m_objWaitWindow.focus();
}


//=================================================================================================================
// New V11 Worklist functions follow
//=================================================================================================================


//==================================================================================
// Loads more worklist data for either the main worklist or the child items
// objRow  :: The row that has been clicked on
// isChild :: Bool indicating if the row was part of an expanded set of results
//
function LoadPagedWorklistData(objRow, isChild) {

    var xmlData = null;
    var objLastRow = null;
    var objParent = null;
    var parentID = 0;
    var rowsPosition = 0;
    var orderRowsReturned = 0;
    var queryset = "";
    var worklist = document.body.getAttribute("Routine"); ;
    var indentLevel = 0;
    var queryid = 0;
    var queryParams = "";

    if (!isChild) {
        // If the search button clicked is on the main worklist rather than an expanded item
        // then we need to go back up to the top of the grid to get the data for continuing
        // the worklist.

        // Get the number of rows we have returned so far for this query  
        if (objRow.parentNode.parentNode.getAttribute("rowsposition") != null) {
            rowsPosition = Number(objRow.parentNode.parentNode.getAttribute("rowsposition"));
        }

        if (objRow.parentNode.parentNode.getAttribute("orderrowsreturned") != null) {
            orderRowsReturned = Number(objRow.parentNode.parentNode.getAttribute("orderrowsreturned"));
        }

        if (objRow.getAttribute("queryid") != null) {
            queryid = objRow.getAttribute("queryid");
        }

        // Find the last row in the grid
        objLastRow = objRow.parentNode.parentNode.previousSibling;

        // Find the parent row for this button
        objParent = objRow.parentNode.parentNode.parentNode;

        // and remove it from the list
        objParent.removeChild(objRow.parentNode.parentNode);

    }
    else {
        if (objRow.tagName == "TR") {
            if (objRow.getAttribute("dataloaded") == null || objRow.getAttribute("dataloaded") == "0") {
                // Row has been expanded via the [+]
                if (objRow.getAttribute("parentid") != null) {
                    parentID = Number(objRow.getAttribute("parentid"));
                }

                if (objRow.getAttribute("queryset") != null) {
                    queryset = objRow.getAttribute("queryset");
                }

                if (objRow.getAttribute("indentlevel") != null) {
                    indentLevel = Number(objRow.getAttribute("indentlevel"));
                    indentLevel++;
                }

                queryParams = GetQueryParamsFromRow(objRow);

                objRow.setAttribute("dataloaded", "1");

                objLastRow = objRow;
            }
            else {
                return;
            }
        }
        else {
            // For expanded items were we have clicked on the search button we need to go to the top level
            // item for this child to get the name of the queryset to run.
            var objButtonRow = objRow.parentNode.parentNode;
            objParent = objButtonRow.parentNode;
            objLastRow = objButtonRow.previousSibling;
            var objParentRow = GetParentFromButton(objButtonRow);

            if (objRow.getAttribute("queryid") != null) {
                queryid = objRow.getAttribute("queryid");
            }

            if (objButtonRow.getAttribute("rowsposition") != null) {
                rowsPosition = Number(objButtonRow.getAttribute("rowsposition"));
            }

            if (objButtonRow.getAttribute("orderrowsreturned") != null) {
                orderRowsReturned = Number(objButtonRow.getAttribute("orderrowsreturned"));
            }

            if (objParentRow.getAttribute("queryset") != null) {
                queryset = objParentRow.getAttribute("queryset");
            }

            if (objParentRow.getAttribute("parentid") != null) {
                parentID = Number(objParentRow.getAttribute("parentid"));
            }

            if (objLastRow.getAttribute("indentlevel") != null) {
                indentLevel = Number(objLastRow.getAttribute("indentlevel"));
            }

            queryParams = GetQueryParamsFromRow(objParentRow);

            // Remove the search more button from the list
            objParent.removeChild(objButtonRow);
        }
    }

    xmlData = DynamicallyLoadData(parentID, indentLevel, worklist, queryset, rowsPosition + 1, orderRowsReturned, queryid, queryParams);
    if (xmlData != null && xmlData != "") {
        AddDynamicDataToWorklist(objLastRow, xmlData, isChild);
    }
    else {
        // Nothing came back so make the control icon a space instead
        if (imgControl[objRow.rowIndex] != undefined && imgControl[objRow.rowIndex] != null) {
            imgControl[objRow.rowIndex].src = IMAGE_DIR + IMAGE_EMPTY;
        }
        else {
            imgControl.src = IMAGE_DIR + IMAGE_EMPTY;
        }
    }
}

//==================================================================================
// Adds the retrieved data back into the worklist
// parentRow :: The parent row of row we have clicked on
// xmlData   :: The data, as xml, that we want to add to the worklist
// isChild   :: Bool indicating if the row was part of an expanded set of results
//
function AddDynamicDataToWorklist(parentRow, xmlData, isChild) {
    var xmlNode = null;
    var xmlRoot = null;
    var xmlWorklistData = null;
    var xmlDOM = null;

    xmlDOM = new ActiveXObject("MSXML2.DOMDocument");
    xmlDOM.loadXML("<root>" + xmlData + "</root>");

    xmlRoot = xmlDOM.selectSingleNode("root");
    xmlWorklistData = xmlRoot.selectSingleNode("WorklistData");
    if (xmlWorklistData != null) {
        xmlRoot.removeChild(xmlWorklistData);
    }

    var parent = parentRow;
    var xmlNodes = xmlDOM.selectNodes("//GridHtml/*");

    //parentRow.setAttribute('dataloaded', "1");
    for (idx = 0; idx < xmlNodes.length; idx++) {
        xmlNode = XMLtoHTML(xmlNodes[idx], false);

        if (xmlNode.getAttribute("class") == "GridRow Header") {
            xmlNode.className = "GridRow Header";
        }
        else {
            xmlNode.className = "GridRow";
        }

        xmlNode.style.display = 'block';

        // add the new row in
        insertAfter(xmlNode, parent);
        // now set our objRow (which is now the parent) to the new row
        parent = xmlNode;
    }
    parent.focus();
    parent.scrollIntoView(false);

    var addSearchMoreButton = AddSearchMoreButton(parent, xmlWorklistData, isChild);
    insertAfter(addSearchMoreButton, xmlNode);
    MergeDataIntoGridXml(xmlDOM);

    UpdateGridItemCount();
}


//==================================================================================
// Dynamically loads the data from either a worklist or a queryset
// parentID    :: The parentID (dbid) of the row we have clicked on
// indentLevel :: The level of indentation to use
// worklist    :: The name of the worklist we want to run (may be empty if is part of sub query)
// querySet    :: The name of the queryset we want to run
// rowPosition :: The position of the record that we are currently on
//
function DynamicallyLoadData(parentID, indentLevel, worklist, querySet, rowPosition, orderRowsReturned, queryid, strPostData) {
    if (strPostData == null) {
        strPostData = "";
    }

    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    var strURL = '../worklist/worklisthelper.aspx'
            + '?SessionID=' + document.body.getAttribute("sid")
            + '&Mode=getworklistdata'
            + '&worklist=' + worklist
            + '&parentId=' + parentID
            + '&indentlevel=' + indentLevel
            + '&episodeId=' + document.body.getAttribute("episodeid")
            + '&userId=' + document.body.getAttribute("userid")
            + '&terminalId=' + document.body.getAttribute("terminalid")
            + '&queryset=' + querySet
            + '&position=' + rowPosition
            + '&orderRowsCount=' + orderRowsReturned
            + '&queryid=' + queryid;

    if (xmlParameters != null) {
        var xmlNodes = xmlParameters.selectNodes("//RoutineParameter");

        for (var i = 0; i < xmlNodes.length; i++) {
            var strParameter = xmlNodes[i].getAttribute("Description");

            if (strPostData.length > 0) {
                strPostData = strPostData + "&";
            }

            strPostData = strPostData + strParameter + "=" + document.forms[0].elements["col" + i].value;
        }
    }

    objHTTPRequest.open("POST", strURL, false);
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send(strPostData);

    return objHTTPRequest.responseText;
}

//==================================================================================
// Inserts a new element after the target element
// newElement    :: The new element to add to the xml
// targetElement :: The element we want to insert after
//
function insertAfter(newElement, targetElement) {
    if (newElement != null) {
        //target is what you want it to go after. Look for this elements parent.
        var parent = targetElement.parentNode;

        //if the parents lastchild is the targetElement...
        if (parent.lastchild == targetElement) {
            //add the newElement after the target element.
            parent.appendChild(newElement);
        } else {
            // else the target has siblings, insert the new element between the target and it's next sibling.
            parent.insertBefore(newElement, targetElement.nextSibling);
        }
    }
}

//==================================================================================
// Merges the retrieved data back into the grid xml islands
// xmlDOM :: The xml document to merge into the grid
//
function MergeDataIntoGridXml(xmlDOM) {
    var idx;
    var xmlRoot = gridData.XMLDocument.selectSingleNode("root");                // Get the root of our gridData xml island
    var xmlTypeInfo = xmlRoot.selectSingleNode("typeinfo");                     // Get the typeinfo node of our gridData xml island

    var xmlNodes = xmlDOM.selectNodes("//GridData/*");                          // Get the list of new items we want to add on
    var xmlTypeInfoNodes = xmlDOM.selectNodes("//TypeData/*");                  // Get the list of typedata items we want to add on
    var xmlTypeData = typeData.XMLDocument.selectSingleNode("root");            // Get the root of the typedata xml island

    // Add everything in bar the typeinfo data, we do this afterwards
    for (idx = 0; idx < xmlNodes.length; idx++) {
        if (xmlNodes[idx].nodeName != "typeinfo") {
            xmlRoot.appendChild(xmlNodes[idx].cloneNode(true));
            //xmlRoot.appendChild(xmlNodes[idx]);
        }
    }

    //11Mar11   Rams    F0109435 - no lookup available on worklist
    if (xmlTypeInfo != null)
        xmlRoot.removeChild(xmlTypeInfo);

    // Add in the typeinfo data
    for (idx = 0; idx < xmlTypeInfoNodes.length; idx++) {
        //24May11   Rams    F0118539 - script error on worklist
        if (xmlTypeInfo != null) {
            xmlTypeInfo.appendChild(xmlTypeInfoNodes[idx].cloneNode(true));
        }
        xmlTypeData.appendChild(xmlTypeInfoNodes[idx].cloneNode(true));
    }

    //11Mar11   Rams    F0109435 - no lookup available on worklist
    if (xmlTypeInfo != null)
        xmlRoot.appendChild(xmlTypeInfo.cloneNode(true));

    RefreshToolBar();
    //11Mar11   Rams    F0109435 - no lookup available on worklist
    AlternateRowColour();
}

//==================================================================================
// Refreshes the toolbar on a worklist when more data is loaded
//
function RefreshToolBar() {
    var windowID = document.body.getAttribute("windowid");
    var statusnote = ReplaceString(typeData.XMLDocument.xml, '&', '_amp;');     // we need to replace any & characters so they don't get treated as posted fields
    var strPostData = "statusnote=" + statusnote + "&statusnotefilter=" + xmlStatusNoteFilter.XMLDocument.xml;

    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    var strURL = '../worklist/worklisthelper.aspx'
            + '?SessionID=' + document.body.getAttribute("sid")
            + '&Mode=refreshtoolbar'
            + '&WindowID=' + windowID;

    objHTTPRequest.open("POST", strURL, false);
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send(strPostData);

    document.getElementById("WorklistToolBar").innerHTML = objHTTPRequest.ResponseText;
}


//==================================================================================
// Convert xml nodes to html nodes
// xml          :: The xml node we want to process into html
// notrecursive :: Determines if we want to recurse through the child elements
//
function XMLtoHTML(xml, notrecursive) {
    switch (xml.nodeType) {
        case 1: // Element Node
            var i;
            var html = document.createElement(xml.nodeName);
            for (i = 0; i < xml.attributes.length; i++) {
                attr = xml.attributes.item(i);

                // In IE 5+ you can't set the style of an element so here we check to see if we are dealing
                // the style attribute for an element and if so then we do it the IE way.
                if (attr.name == "style") {
                    html.style.cssText = attr.value;
                }
                else if (attr.name == "onclick") {
                    html.onclick = new Function(attr.value);
                }
                else {
                    html.setAttribute(attr.name, attr.value);
                }
            }
            if (!notrecursive) {
                for (i = 0; i < xml.childNodes.length; i++) {
                    html.appendChild(XMLtoHTML(xml.childNodes[i]));
                }
            }
            return html;
        case 3: // Text Node
            // Task 31127 - document.createElement(xml.nodeName) changed to document.createElement("label") because the nodeName for a text node is "#Text" which causes issues in the worklist
            // that shows the "#Text" in the worklist. Replacing the #text with a label renders the worklist correctly.
            var node = document.createElement("label");
            node.innerHTML = xml.nodeValue;
            return node;

    }
}

//==================================================================================
// Adds the button to allow the user to search for more records
// objRow           :: The row we are currently on
// xmlWorklistData  :: The xml data containing information regarding the worklist
// isChild          :: Bool indicating if the row was part of an expanded set of results
//
function AddSearchMoreButton(objRow, xmlWorklistData, isChild) {
    var rowsAvailable = 0;
    var rowsReturned = 0;
    var rowPosition = 0;
    var orderRowsReturned = 0;
    var queryid;
    var xmlResultDetail = null;
    //var indentlevel = Number(objRow.parentNode.getAttribute("indentlevel")) + 1;
    var indentlevel = Number(objRow.getAttribute("indentlevel"));
    var spanwidth = (35 + (20 * indentlevel));
    var objTR = null;
    var objTD = null;

    if (isChild)
        spanwidth = spanwidth - 10;

    if (xmlWorklistData != null) {
        xmlResultDetail = xmlWorklistData.selectSingleNode("ResultDetail");
        if (xmlResultDetail != null) {
            if (xmlResultDetail.getAttribute("RowsAvailable") != null) {
                rowsAvailable = Number(xmlResultDetail.getAttribute("RowsAvailable"));
            }

            if (xmlResultDetail.getAttribute("RowsReturned") != null) {
                rowsReturned = Number(xmlResultDetail.getAttribute("RowsReturned"));
            }

            if (xmlResultDetail.getAttribute("RowsPosition") != null) {
                rowPosition = Number(xmlResultDetail.getAttribute("RowsPosition"));
            }

            if (xmlResultDetail.getAttribute("OrderRowsReturned") != null) {
                orderRowsReturned = Number(xmlResultDetail.getAttribute("OrderRowsReturned"));
            }

            if (xmlResultDetail.getAttribute("QueryID") != null) {
                queryid = xmlResultDetail.getAttribute("QueryID");
            }

            objTR = document.createElement("tr");
            objTR.setAttribute("indentlevel", indentlevel);
            objTR.setAttribute("rowsposition", rowPosition);
            objTR.setAttribute("orderrowsreturned", orderRowsReturned);
            objTR.setAttribute("searchmore", "1");

            objTD = document.createElement("td");
            objTR.appendChild(objTD);
            objTD.setAttribute("colSpan", 4);

            if (!isChild) {
                spanwidth = 0;
            }
            objTD.innerHTML = "<button queryid='" + queryid + "' onclick='LoadPagedWorklistData(this, " + isChild + ");' style='margin-left:" + spanwidth + "px;width:100%;height:25px;font-size:12px;font-family:trebuchet ms'>" + orderRowsReturned + " of " + rowsAvailable + " items have been displayed. Click here to show more&nbsp;<img src='../../images/ocs/searchmore.gif' border='0' style='vertical-align:middle;'</button>";
        }
    }
    return objTR;
}

//==================================================================================
// From the search more button, find the parent record, i.e. orderset
// objRow :: The row we are starting to search from
//
function GetParentFromButton(objRow) {
    var currentIdent = parseInt(objRow.getAttribute("indentlevel"));

    if (isNaN(currentIdent) || currentIdent == 0) {
        return objRow;
    }

    do {
        objRow = objRow.previousSibling;
        var previousIdent = parseInt(objRow.getAttribute("indentlevel"));
        if (isNaN(previousIdent) || previousIdent < currentIdent) {
            break;
        }
    }
    while (true)

    return objRow;
}

//==================================================================================

function GetQueryParamsFromRow(objRow) {
    var rowAttributes = objRow.attributes;
    var params = "";

    for (var i = 0; i < rowAttributes.length; i++) {
        var attribute = rowAttributes[i];
        var parameter = new String(attribute.nodeName);
        if (parameter.length > 7 && parameter.substr(0, 7) != "param__") {
            continue;
        }

        if (params.length > 0) {
            params = params + "&";
        }

        params = params + parameter.substr(7) + "=" + attribute.nodeValue;
    }

    return params;
}

function ICWNoEventskeyboardEventHandler() {

    var ICWNoEventsWindow = window;

    if (window.ICWWindow) {
        ICWNoEventsWindow = ICWWindow();
    } else {
        if (window.top) {
            if (window.top.ICW) {
                ICWNoEventsWindow = window.top;
            }
        }
    }

    if (ICWNoEventsWindow.ICW) {
        if (ICWNoEventsWindow.ICW.noEvents) {
            ICWNoEventsWindow.ICW.noEvents.keyboardEvent(window.event);
        }
    }
}