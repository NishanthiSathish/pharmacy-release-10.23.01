/// <reference path="MenuScript.js" />
/// <reference path="xml2json.js" />
/// <reference path="xml2json_2.js" />
/// <reference path="lib/json2.js" />
/// <reference path="lib/jquery-1.4.3.min.js" />

var backupICWAccessKeysIslandJqueryObject;
var backupButtonCradleJqueryObject;
var backupICWAccessKeysIslandParentNodeJqueryObject;
var backupButtonCradleParentNodeJqueryObject;

$(function () {
    GenerateJsonVersionOfMenuForNavToApplicationByName();
});

// ------------------------------- MenuScript.js ------------------------------------
//
// A series of shared functions for the MenuDesigner and Menu ASP pages
//
// 11Jun03 DB Created
// ----------------------------------------------------------------------------------

function GenerateJsonVersionOfMenuForNavToApplicationByName() {
    /*
    ~ Following code required for RFC F0097938 ~
    Code parses XML returned for Toolbar menu creation
    into JSON using new method xml2json within icw.js
    menuMap object is created within top window scope
    JSON array is run through a loop, passing menu items with a valid
    description (our menu name) to the top.menuMap as an associative array
    ala DesktopName : DesktopID.
    This is needed to facilitate the new method NavigateToApplicationByName(string)
    */

    if (window.location.search.search("DoRefreshToolMenuFromDatabase") != -1) {
        var desktop = GetJsonVersionOfTheMenuWrittenInXml();
        var JSONMenu = desktop.ToolMenu.ToolMenu[0].ToolMenu;
        top.menuMap = {};
        i = null;

        for (i = 0; JSONMenu.length > i; i++) {
            top.menuMap[strTrim(JSONMenu[i].Description)] = JSONMenu[i].WindowID;
        }
    }
}

var IMAGE_PATH = "../../Images/User/",
    BACKSPACE_KEY = 8,
    TAB_KEY = 9,
    RETURN_KEY = 13,
    ALT_KEY = 18,
    ESCAPE_KEY = 27,
    SPACE_BAR = 32,
    LEFT_ARROW = 37,
    UP_ARROW = 38,
    RIGHT_ARROW = 39,
    DOWN_ARROW = 40,
    DELETE_KEY = 46,
    m_strDefaultName = "unnamed",
    objPopup,
    objStore;

function HotKeyDisplay(strDescription, strKey) {
    // Finds the position of strKey within strDescription and underlines that
    // character
    // for example 'File' with 'F' as strKey would return
    // <U>F</U>ile
    var strDescriptionUC = strDescription.toUpperCase(),
        lngPosAt;

    if (strKey != " ") {
        lngPosAt = strDescriptionUC.indexOf(strKey);
    }
    else {
        lngPosAt = -1;
    }

    var strNewDescription = strDescription,
        lngLenLastCharPos = strDescription.length - 1;

    if (lngPosAt > -1 && strKey != "") {
        if (lngPosAt > 0) {
            strNewDescription = strDescription.substr(0, lngPosAt);
            strNewDescription += "<U unselectable='on'>";
        }
        else {
            strNewDescription = "<U unselectable='on'>";
        }

        strNewDescription += strDescription.substr(lngPosAt, 1);
        strNewDescription += "</U>";


        if (lngPosAt < lngLenLastCharPos) {
            lngLenLastCharPos -= lngPosAt; // Number of characters to work from
            strNewDescription += strDescription.substr(lngPosAt + 1, lngLenLastCharPos);
        }
    }
    return strNewDescription;
}
function SelectXMLNode(lngToolMenuID) {
    // Selects an XML node with a given ToolMenuID for use with the Run time menu system
    return xmlToolMenu.selectSingleNode(".//ToolMenu[@ToolMenuID='" + lngToolMenuID + "']");
}
function ItemSelected(lngToolMenuID) {
    // Menu item selected. Get the node with the id passed in lngToolMenuID and call
    // the function MenuItemSelected passing along the selected node as a parameter
    // The function MenuItemSelected(xmlnodeToolMenu) MUST be 
    // scripted in your ASP page to make use of the menu system
    objPopup.hide();
    MenuItemSelected(SelectXMLNode(lngToolMenuID));
}
function Store() {
    // Store area for various settings including menu just on
    this.ToolMenuID_Child = null;
    this.ToolMenuID_Parent = null;
    this.ToolMenuIDHighlighted = null;
    this.blnAllowKeyboardNavigation = false;
    this.MenuInitialised = false;
    this.blnAllowClearDown = true;
    this.blnAllowExecution = true;
    this.blnFromHotKey = false;
    this.PosX = 0;
    this.PosY = 0;
}
function tblMenu_onclick(lngToolMenuID) {
    // Event code to trap user clicking on a top level menu item
    objStore.blnFromHotKey = false;

    if (objStore.MenuInitialised) {
        BuildMenu(lngToolMenuID);
    }
    else {
        alert("Menu Initialise failure. The routine Menu_Initialise() was not invoked");
    }

    window.event.cancelBubble = true;
    window.event.returnValue = false;
}
function BuildMenu(lngToolMenuID) {
    // Builds the sub menu from the xml island with the given ToolMenuID
    // Set the class to that of an open menu (inverted look)
    document.getElementById(lngToolMenuID).className = "MenuOpen";
    objStore.ToolMenuID_Parent = lngToolMenuID; // Store the ID for which has been chosen
    objStore.ToolMenuID_Child = null; // Reset child ID to null
    MenuRender(lngToolMenuID); // Call function to build the menu in a pop up window object
    objStore.blnAllowKeyboardNavigation = true; // Once the menu is open, allow the use of the cursor keys
}
function tblMenu_onmousenter(objHTMLMenu, lngToolMenuID) {
    // Event code to enter a mouse enter on a top menu item row
    var blnHighlight = true;
    if (objStore.ToolMenuID_Parent != null) {
        // If the menu that is open has the same id as the one we're hovering
        // over then do not change the highlight    
        if (objStore.ToolMenuID_Parent == lngToolMenuID) {
            blnHighlight = false;
        }
    }
    if (blnHighlight) {
        TopMenuHighlightOn(objHTMLMenu, lngToolMenuID, false);
    }
    window.event.cancelBubble = true;
    window.event.returnValue = false;
}
function tblMenu_onmouseleave(objHTMLMenu) {
    // Event code to enter a mouse leave from a top menu item row
    if (objStore.ToolMenuID_Parent == null) {
        TopMenuHighlightOff(objHTMLMenu);
        objStore.MenuIDHighlighted = null;
    }
    window.event.cancelBubble = true;
    window.event.returnValue = false;
}
function tblChildMenu_onmousemove(objHTMLMenu) {
    // Event code to trap a mouse move within the pop up object
    if (objStore.blnAllowExecution) {
        if (objStore.blnFromHotKey) {
            ChildMenuHighlightOn(objHTMLMenu);
        }
    }
    else { // If the pointer moved allow execution of the onmouseenter code again
        if (objPopup.document.parentWindow.event.screenX != objStore.PosX ||
            objPopup.document.parentWindow.event.screenY != objStore.PosY) {
            objStore.blnAllowExecution = true;
            ChildMenuHighlightOn(objHTMLMenu);
        }
    }
    objPopup.document.parentWindow.event.cancelBubble = true;
}
function tblChildMenu_onmouseenter(objHTMLMenu) {
    // Event code to enter a mouse enter on a menu item row
    if (objStore.blnAllowExecution) {
        ChildMenuHighlightOn(objHTMLMenu);
    }
    objPopup.document.parentWindow.event.cancelBubble = true;
}
function tblChildMenu_onmouseleave(objHTMLMenu) {
    // Event code to enter a mouse leave from a menu item row
    ChildMenuHighlightOff(objHTMLMenu);
    objPopup.document.parentWindow.event.cancelBubble = true;
}
function tblChildMenu_onclick(lngToolMenuID) {
    // Event code when user clicks on a sub menu item
    ItemSelected(lngToolMenuID);
}
function btnMenuDropDown_onclick(lngToolMenuID) {
    // Used by the Alt+Menu functionality
    btnMenuPopup_onclick(lngToolMenuID);
}
function btnMenuPopup_onclick(lngToolMenuID) {
    // Event code when the user presses a hot key for the top level menus
    // e.g ALT + F to drop down a "File" menu
    objStore.blnCanHighlight = false;
    TopMenuHighlightOn(document.getElementById(lngToolMenuID), lngToolMenuID, true);
    BuildMenuFocusFirstItem(lngToolMenuID);
    objStore.blnFromHotKey = true;
    objStore.blnAllowExecution = false; // indicate not to allow highlight for the child menu where the mouse pointer is positioned
    objStore.PosX = ICWWindow().event.screenX;
    objStore.PosY = ICWWindow().event.screenY;
}
function oPopBody_onkeydown() {
    // Event code for trapping key presses within the oPopBody object (Pop up body)
    var oParentWindow = objPopup.document.parentWindow,
        lngKeyPressed = oParentWindow.event.keyCode;
    objStore.blnFromHotKey = false;
    if (lngKeyPressed == UP_ARROW || lngKeyPressed == DOWN_ARROW) {
        ChildMenuNavigate(lngKeyPressed, objStore.ToolMenuID_Child);
    }
    else {
        if (lngKeyPressed >= 65 && lngKeyPressed <= 90) {
            ProcessHotKey(lngKeyPressed, objStore.ToolMenuID_Parent);
        }

        if (lngKeyPressed == RETURN_KEY) {
            ItemSelected(objStore.ToolMenuID_Child);
        }
    }
    objPopup.document.parentWindow.event.cancelBubble = true;
}
function oPopBody_window_onunload() {
    // Event code for trapping the window onunload within the popup body
    // Clears down any highlights on the menu and resets the menu to a state where no
    // sub menus are open
    if (objStore.ToolMenuIDHighlighted != null) {
        TopMenuHighlightOff(document.getElementById(objStore.ToolMenuIDHighlighted));
    }

    if (objStore.blnAllowClearDown) {
        objStore.ToolMenuID_Parent = null;
        objStore.ToolMenuID_Child = null;
        objStore.ToolMenuIDHighlighted = null;
        objStore.blnAllowKeyboardNavigation = false;
    }
    // 29162 - Pressing ESC in HTA moves the focus outside of the root frame. Therefore we force focus onto an element we know exists within the root frame.
    var lblDesktopWindow = ICWWindow().document.getElementById('panToolMenu');
    lblDesktopWindow.focus();
}

function tblMenu_onkeydown(lngToolMenuID) {
    // Event code for trapping key presses within the tblMenu object (top level menu)
    TopMenuNavigate(window.event.keyCode, lngToolMenuID);
    window.event.cancelBubble = true;
    window.event.returnValue = false;
}
function CheckForMenuOpen(lngToolMenuID, blnFromKeyboard) {
    // Check to see if another menu is open. If this is the case open up the
    // sub menu below the highlighted top menu
    if (objStore.ToolMenuID_Parent != null) {
        TopMenuHighlightOff(document.getElementById(objStore.ToolMenuID_Parent)); // Remove the highlight from the last menu
        BuildMenu(lngToolMenuID); // Call function to build the menu in a pop up window object
        // Select the first row in the menu if one was selected before in another menu
        // only if we've come in from the keyboard        
        if (blnFromKeyboard) {
            SelectTopChildMenu(objStore.ToolMenuID_Parent);
        }
    }
}
function BuildMenuFocusFirstItem(lngToolMenuID) {
    // Opens the child menu of the passed ToolMenuID and sets the highlight to the
    // first item
    BuildMenu(lngToolMenuID);
    SelectTopChildMenu(lngToolMenuID); // Select the first item in the drop down list
}
function TopMenuHighlightOn(objHTMLElement, lngToolMenuID, blnFromKeyboard) {
    // Turn on highlight on the passed in HTML element object (Top level menu)
    // blnFromKeyboard set true if we came in from the keyboard. Hard coded true
    // in the keyboard handling events, false in mouse handling events.
    // Close any old popups to prevent flicker when you show a new one.
    // Set the class variable blnAllowClearDown to false here as we do not
    // want to wipe out our storage fields at this time when the window_unload() event
    // fires on the popup window. (when the .hide() is called)
    objStore.blnAllowClearDown = false;
    objPopup.hide();
    objStore.blnAllowClearDown = true; // set back to true to allow cleardown
    objHTMLElement.focus();
    objHTMLElement.className = "MenuHover";
    CheckForMenuOpen(lngToolMenuID, blnFromKeyboard); // Check to see if another menu is open
    objStore.ToolMenuIDHighlighted = lngToolMenuID;
}
function TopMenuHighlightOff(objHTMLElement) {
    // Turn off highlight on the passed in HTML element object (Top level menu)
    objHTMLElement.className = "MenuNormal";
}
function ChildMenuHighlightOn(objHTMLElement) {
    // Turn on highlight on the passed in HTML element object
    if (objStore.ToolMenuID_Child != null) {
        ChildMenuHighlightOff(objPopup.document.getElementById(objStore.ToolMenuID_Child)); // Turn off last highlight
    }
    objHTMLElement.firstChild.nextSibling.className = "MenuItemText MenuItemText_Hover";
    objStore.ToolMenuID_Child = objHTMLElement.id; // Store the id of the currently select item
}
function ChildMenuHighlightOff(objHTMLElement) {
    // Turn off highlight on the passed in HTML element object
    objHTMLElement.firstChild.nextSibling.className = "MenuItemText";
}
function ChildMenuNavigate(lngKeyCode, lngToolMenuID) {
    // Capture cursor key press on the child menu system to navigate around
    switch (lngKeyCode) {
        case UP_ARROW:
            {
                if (lngToolMenuID != null) {
                    SelectPreviousChildMenu(lngToolMenuID);
                }
                else {
                    SelectLastChildMenu(objStore.ToolMenuID_Parent);
                }
                break;
            }

        case DOWN_ARROW:
            {
                if (lngToolMenuID != null) {
                    SelectNextChildMenu(lngToolMenuID);
                }
                else {
                    SelectTopChildMenu(objStore.ToolMenuID_Parent);
                }
                break;
            }

    }
}
function TopMenuNavigate(lngKeyCode, lngToolMenuID) {
    // Capture cursor key press on the top menu system to navigate around
    if (objStore.blnAllowKeyboardNavigation) {
        switch (lngKeyCode) {
            case LEFT_ARROW:
                {
                    if (lngToolMenuID != null) {
                        objStore.blnAllowExecution = false;
                        objStore.PosX = event.screenX;
                        objStore.PosY = event.screenY;
                        SelectPreviousTopMenu(lngToolMenuID);
                    }
                    break;
                }

            case RIGHT_ARROW:
                {
                    if (lngToolMenuID != null) {
                        objStore.PosX = event.screenX;
                        objStore.PosY = event.screenY;
                        objStore.blnAllowExecution = false;
                        SelectNextTopMenu(lngToolMenuID);
                    }
                    break;
                }

            case DOWN_ARROW:
                {
                    if (objStore.ToolMenuID_Parent == null) {
                        // If the child menu is not open then open it here and
                        // place the cursor on the top menu item
                        BuildMenuFocusFirstItem(objStore.ToolMenuIDHighlighted);
                    }
                    break;
                }

            case UP_ARROW:
                {
                    if (objStore.ToolMenuID_Parent == null) {
                        // If the child menu is not open then open it here and
                        // place the cursor on the top menu item                    
                        BuildMenuFocusFirstItem(objStore.ToolMenuIDHighlighted);
                    }
                    break;
                }

            case RETURN_KEY:
                {
                    if (objStore.ToolMenuID_Parent == null) {
                        // If the child menu is not open then open it here and
                        // place the cursor on the top menu item                    
                        BuildMenuFocusFirstItem(objStore.ToolMenuIDHighlighted);
                    }
                    break;
                }
        }
    }
}
function ProcessHotKey(lngKeyCode, lngToolMenuID) {
    // Compares the key pressed to any shortcut keys within this menu
    // If a match found, executes the Action for that menu item
    var objNode = xmlToolMenu.selectSingleNode(".//ToolMenu[@ToolMenuID='" + lngToolMenuID + "']"),
        objChildNodes = null,
        objCurrentNode = null;

    if (objNode != null) {
        var objChildNodes = objNode.childNodes,
            lngPosAt = -1,
            strHotKey = "",
            objChildNodesLen = objChildNodes.length;

        for (var i = 0; i < objChildNodesLen; i++) {
            objCurrentNode = objChildNodes[i];
            strHotKey = objCurrentNode.getAttribute("HotKey");

            if (strHotKey.toUpperCase() == String.fromCharCode(lngKeyCode)) {
                ItemSelected(eval(objCurrentNode.getAttribute("ToolMenuID")))
                break;
            }
        }
    }
}
function CheckXMLForShortCut(lngKeyCode) {
    // Checks the key combination press and compares it to the shortcut inside
    // the menu xml island. If there is a match then executes the action for that
    // menu item
    // As the user has to have hit control to come here do not bother to check
    // for it. This is done in the calling function (ApplicationKeyPress)
    // Search our XML using an XPath query
    var XPath = "[@Shortcut='" + String.fromCharCode(lngKeyCode) + "']",
        objNode = null,
        objMenuNode = xmlToolMenu.selectNodes(".//ToolMenu" + XPath),
        objMenuNodeLen = objMenuNode.length;

    for (var i = 0; i < objMenuNodeLen; i++) {
        objNode = objMenuNode[i];
        ItemSelected(eval(objNode.getAttribute("ToolMenuID")));
        break;
    }
}
function ApplicationKeyPress(blnAlt, blnCtrl, lngKeyCode) {
    // public function to capture key presses from all applications. Applications
    // must plug into this in order to make use of it
    // Check to see if the menu system has focus. If it does (MenuIDHighlighted
    // will be set) then ignore this routine
    if (objStore.ToolMenuIDHighlighted == null) {
        switch (lngKeyCode) {
            case (ALT_KEY):
                {
                    if (blnCtrl) {
                        var lngFirstNodeID = xmlToolMenu.selectSingleNode("Desktop/ToolMenu").firstChild.getAttribute("ToolMenuID");
                        SelectFirstTopMenu(lngFirstNodeID);
                        objStore.blnAllowKeyboardNavigation = true;
                        return 0;
                    }
                    break;
                }
        }
    }
    else {
        if (objStore.blnAllowKeyboardNavigation) {
            // ESCAPE key should only function if we selected the menu from the
            // keyboard.        
            if (lngKeyCode == ESCAPE_KEY) {
                if (objStore.ToolMenuID_Parent != null) {
                    // First press menu closes set child id store to null and parent id
                    // and put the system back to a state of top menu highlighted only                
                    objStore.ToolMenuID_Parent = null;
                    objStore.ToolMenuID_Child = null;
                    TopMenuHighlightOn(document.getElementById(objStore.ToolMenuIDHighlighted),
                        objStore.ToolMenuIDHighlighted, true);
                }
                else {
                    // Second press, remove highlight
                    TopMenuHighlightOff(document.getElementById(objStore.ToolMenuIDHighlighted));
                    objStore.ToolMenuIDHighlighted = null;
                }
            }
        }
    }

    if (blnCtrl) {
        if (!blnAlt) {
            CheckXMLForShortCut(lngKeyCode);
        }
    }
}
function SelectFirstTopMenu(lngToolMenuID) {
    // Selects the first (left hand most) menu 
    var lngFirstNodeID = SelectXMLNode(lngToolMenuID).parentNode.firstChild.getAttribute("ToolMenuID");
    TopMenuHighlightOn(document.getElementById(lngFirstNodeID), lngFirstNodeID, true);
}

function SelectLastTopMenu(lngToolMenuID) {
    // Selects the last (right hand most) menu 
    var lngLastNodeID = SelectXMLNode(lngToolMenuID).parentNode.lastChild.getAttribute("ToolMenuID");
    TopMenuHighlightOn(document.getElementById(lngLastNodeID), lngLastNodeID, true);
}
function SelectNextTopMenu(lngToolMenuID) {
    // Selects the next top level menu
    var objNode = SelectXMLNode(lngToolMenuID);
    if (objNode.nextSibling != null) {
        var lngNextNodeID = objNode.nextSibling.getAttribute("ToolMenuID");
        TopMenuHighlightOn(document.getElementById(lngNextNodeID), lngNextNodeID, true);
    }
    else {
        SelectFirstTopMenu(lngToolMenuID);
    }
}
function SelectPreviousTopMenu(lngToolMenuID) {
    // Selects the previous top level menu
    var objNode = SelectXMLNode(lngToolMenuID);
    if (objNode.previousSibling != null) {
        var lngPreviousNodeID = objNode.previousSibling.getAttribute("ToolMenuID");
        TopMenuHighlightOn(document.getElementById(lngPreviousNodeID), lngPreviousNodeID, true);
    }
    else {
        SelectLastTopMenu(lngToolMenuID);
    }
}
function SelectTopChildMenu(lngToolMenuID) {
    // Selects the top item in the drop down menu upon the menu being opened if done
    // via a hotkey
    var objFirstNode = SelectXMLNode(lngToolMenuID).firstChild,
        lngFirstNodeID = objFirstNode.getAttribute("ToolMenuID"),
        blnFoundEnabled = false;
    if (objFirstNode.getAttribute("Enabled") == "0") {
        var objNode = null,
            objFirstNodeLen = objFirstNode.parentNode.childNodes.length;

        for (var i = 0; i < objFirstNodeLen; i++) {
            objNode = objFirstNode.parentNode.childNodes[i]; // Go through our child nodes until we find an enabled node
            if (objNode.getAttribute("Enabled") != "0") {
                if (objNode.getAttribute("Divider") == "0") {
                    blnFoundEnabled = true;
                    break;
                }
            }
        }

        if (blnFoundEnabled) {
            ChildMenuHighlightOn(objPopup.document.getElementById(objNode.getAttribute("ToolMenuID")));
            objPopup.document.getElementById(objNode.getAttribute("ToolMenuID")).scrollIntoView(false);
        }
    }
    else {
        ChildMenuHighlightOn(objPopup.document.getElementById(lngFirstNodeID));
        objPopup.document.getElementById(lngFirstNodeID).scrollIntoView(false);
    }
}
function SelectLastChildMenu(lngToolMenuID) {
    // Selects the last item in the drop down menu
    var objLastChild = SelectXMLNode(lngToolMenuID).lastChild,
        lngLastNodeID = objLastChild.getAttribute("ToolMenuID");
    if (objLastChild.getAttribute("Enabled") != "0") {
        ChildMenuHighlightOn(objPopup.document.getElementById(lngLastNodeID));
        objPopup.document.getElementById(lngLastNodeID).scrollIntoView(false);
    }
    else {
        SelectPreviousChildMenu(lngLastNodeID);
    }
}
function SelectNextChildMenu(lngToolMenuID) {
    // Using the given ToolMenuID, selects the next ID from the XML island and highlights
    // the next menu item in the drop down menu. If no next ID exist then select the
    // first.
    var objNode = SelectXMLNode(lngToolMenuID);
    if (objNode.nextSibling != null) {
        var lngNextNodeID = objNode.nextSibling.getAttribute("ToolMenuID");
        // If node is a divider or the menu item is disabled
        if (objNode.nextSibling.getAttribute("Divider") == "-1" ||
            objNode.nextSibling.getAttribute("Enabled") == "0") {
            SelectNextChildMenu(lngNextNodeID); // Select next node as we cannot select a divider
        }
        else {
            ChildMenuHighlightOn(objPopup.document.getElementById(lngNextNodeID));
            objPopup.document.getElementById(lngNextNodeID).scrollIntoView(false);
        }
    }
    else {
        SelectTopChildMenu(objStore.ToolMenuID_Parent);
    }
}
function SelectPreviousChildMenu(lngToolMenuID) {
    // Using the given ToolMenuID, selects the previous ID from the XML island and highlights
    // the previous menu item in the drop down menu. If no previous ID exist then select the
    // last id
    var objNode = SelectXMLNode(lngToolMenuID);
    if (objNode.previousSibling != null) {
        var lngPreviousNodeID = objNode.previousSibling.getAttribute("ToolMenuID");
        // If node is a divider or the menu item is disabled
        if (objNode.previousSibling.getAttribute("Divider") == "-1" ||
                 objNode.previousSibling.getAttribute("Enabled") == "0") {
            SelectPreviousChildMenu(lngPreviousNodeID); // Select previous node as we cannot select a divider
        }
        else {
            ChildMenuHighlightOn(objPopup.document.getElementById(lngPreviousNodeID));
            objPopup.document.getElementById(lngPreviousNodeID).scrollIntoView(false);
        }
    }
    else {
        SelectLastChildMenu(objStore.ToolMenuID_Parent);
    }
}
// StringBuffer javascript version of c# string builder
function StringBuffer() {
    this.buffer = [];
}
StringBuffer.prototype.append = function append(string) {
    this.buffer.push(string);
    return this;
};
StringBuffer.prototype.toString = function toString() {
    if (this.buffer != undefined) {
        return this.buffer.join("");
    }
};
function MenuRender(lngToolMenuID) {
    // Creates a pop up menu from the passed in lngToolMenuID by constructing this
    // from the stored XML Menu island on the page
    var blnHasIcon = false,
        newMenu = new StringBuffer(),
        strImageMnu = "",
        strMainMnu = "",
        oPopBody = objPopup.document.body,
        objHTMLMenu = document.getElementById(lngToolMenuID);
    // Nest a table within a table tag in order to get a border	

    newMenu.append("<div class='MenuPopup_BorderOutline'>"); // now uses string buffer to remove memory leak within IE7
    newMenu.append("<table id='tblChildMenu' cellspacing=0 cellpadding=0>");
    newMenu.append("<tr height=5px><td></td></tr>");

    var objNode = SelectXMLNode(lngToolMenuID),
        objSubItems = objNode.selectNodes("ToolMenu"),
        strID = "",
        blnEnabled = false,
        strShortCut = "",
        objSubItemsLen = objSubItems.length;

    for (var i = 0; i < objSubItemsLen; i++) {
        var objMenuNode = objSubItems[i],
                strPictureName = "",
                strImageUrl = "",
                blnHasIcon = false;

        if (objMenuNode.getAttribute("Divider") == "0") {
            blnEnabled = !(objMenuNode.getAttribute("Enabled") != null && objMenuNode.getAttribute("Enabled") == "0");
            strPictureName = objMenuNode.getAttribute("PictureName");
            strImageUrl = objMenuNode.getAttribute("ImageUrl");
            strID = objMenuNode.getAttribute("ToolMenuID");

            newMenu.append("<tr  valign='top' title='" + TooltipRead(objMenuNode) + "' id='" + strID + "' class='MenuPopup_Normal' ");
            if (blnEnabled) {
                newMenu.append(" onmouseenter='parent.tblChildMenu_onmouseenter(this)'");
                newMenu.append(" onclick='parent.tblChildMenu_onclick(" + objMenuNode.getAttribute("ToolMenuID") + ")' ");
                newMenu.append(" onmouseleave='parent.tblChildMenu_onmouseleave(this)' ");
                newMenu.append(" onmousemove='parent.tblChildMenu_onmousemove(this)' ");
            }
            newMenu.append(">");
            newMenu.append("	<td unselectable='on' class='MenuPopup_Left' align='center'>");

            var imageUrlExists = strImageUrl != undefined && strImageUrl != "";
            if (strPictureName != "" || imageUrlExists) {
                strImageMnu = " <img ";
                if (!blnEnabled) {
                    strImageMnu += " style='filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1), progid:DXImageTransform.Microsoft.Alpha(Opacity=50)' "
                }
                var menuImageUrl = imageUrlExists ? strImageUrl : (IMAGE_PATH + strPictureName);
                strImageMnu += " unselectable='on' src='" + menuImageUrl + "'></img>";
                newMenu.append(strImageMnu);
                blnHasIcon = true;
            }
            else {
                newMenu.append(" <img style='visibility:hidden' height='16'></img>");
            }

            newMenu.append("	</td>");
            newMenu.append("	<td class='MenuItemText'");
            if (!blnEnabled) {
                newMenu.append("	   style='filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1), progid:DXImageTransform.Microsoft.Alpha(Opacity=50)' ");
            }
            newMenu.append("	   unselectable='on' nowrap ");
            newMenu.append("	>&nbsp;");
            newMenu.append(HotKeyDisplay(objMenuNode.getAttribute("Description"), objMenuNode.getAttribute("HotKey")));
            newMenu.append("	</td>");
            newMenu.append("  <td unselectable='on' width='20px'>&nbsp;"); // Add a gap between the text and shortcut
            newMenu.append("  </td>");
            newMenu.append("  <td unselectable='on' "); // Display any short cut text
            if (!blnEnabled) {
                newMenu.append(" style='filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1), progid:DXImageTransform.Microsoft.Alpha(Opacity=50)' ");
            }
            newMenu.append(">");
            newMenu.append("  </td>");
            newMenu.append("	<td width=3px>&nbsp;</td>");
            newMenu.append("</tr>");
        }
        else { // otherwise construct a horizontal rule (as a dividor of menu items)
            newMenu.append("<tr class='MenuPopup_Normal'>");
            newMenu.append("	<td class='MenuPopup_Left'><hr></td>");
            newMenu.append("	<td colspan='4'><hr></td>");
            newMenu.append("</tr>");
        }
    }
    newMenu.append("<tr height=2px><td></td></tr>");
    newMenu.append("</table>");
    newMenu.append("</div>");

    oPopBody.className = "MenuPopUp";
    divWidthHeight.innerHTML = newMenu.toString(); // Place the created HTML into the oPopBody object
    oPopBody.innerHTML = newMenu.toString();

    oPopBody.style.overflowY = "hidden";
    oPopBody.scrolling = "no";
    // show it once, so that the HTML table inside renders and we can the read the table's dimensions
    objPopup.show(0, 0, 0, 0, objHTMLMenu);
    // then show it again using the table dimensions we have read
    objPopup.show(-1, objHTMLMenu.offsetHeight - 1, oPopBody.document.getElementById("tblChildMenu").clientWidth + 3, oPopBody.document.getElementById("tblChildMenu").clientHeight + 3, objHTMLMenu);
    oPopBody.oncontextmenu = function() {
        return false;
    };
    
    // check if popup menu size is greater than the screen
    var intWinHeight = oPopBody.document.getElementById("tblChildMenu").clientHeight,
            bCanResizeChildMenu = (intWinHeight > (screen.height - window.screenTop));

    if (bCanResizeChildMenu) {
        var diffHeight = screen.height - screen.availHeight,
                resizeheight = screen.availHeight - (diffHeight + window.screenTop + 20);
        resizeheight = ((resizeheight / 100) * 90); // take 10% off so the menu stays within the window
        oPopBody.style.overflowY = "hidden";
        oPopBody.scrolling = "no";
        objPopup.show(-1, objHTMLMenu.offsetHeight - 1,
                oPopBody.document.getElementById("tblChildMenu").clientWidth + 16,
                resizeheight, objHTMLMenu
            );
    }
}
function ShortCutText(objNode) {
    // If there is a short cut key action for this menu item then display it in an
    // extra column, otherwise just add a blank column
    var strText = "";
    if (objNode.getAttribute("Shortcut") != null && trim(objNode.getAttribute("Shortcut")) != "") {
        strText = "Ctrl+"; // Always Ctrl + key
        strText += objNode.getAttribute("Shortcut");
        strText += "&nbsp;";
    }
    return strText;
}
function TooltipRead(objNode) {
    // Reads the display xml attribute and passes this back as a tool tip string
    return objNode.getAttribute("Detail");
}
function Menu_Initialise() {
    // This function must be called in order to start the menu system once on the client
    objPopup = window.createPopup();
    objStore = new Store();
    if (!objStore.MenuInitialised) {
        objPopup.document.createStyleSheet("../../style/application.css");
        objPopup.document.body.attachEvent('onkeydown', oPopBody_onkeydown);
        objPopup.document.parentWindow.window.attachEvent('onunload', oPopBody_window_onunload);
        objStore.MenuInitialised = true;
    }
    $("#tblMenu").show();
}
function xmlToolMenu_onreadystatechange() {
    Menu_Initialise();
}
function ClearApplicationMenus() {
    // This should remove all application-specific menus the main menu.
    var xmlnode,
        xmlnodelist,
        objHTML = null;
    ButtonCradle.innerHTML = ""; // Remove hotkey buttons
    xmlnodelist = xmlToolMenu.selectNodes("Desktop/ToolMenu/*");
    var xmlnodelistlen = xmlnodelist.length;
    for (var intIndex = 1; intIndex < xmlnodelistlen; intIndex++) {
        xmlnode = xmlnodelist(intIndex);
        objHTML = document.getElementById(xmlnode.getAttribute("ToolMenuID"));
        xmlnode.parentNode.removeChild(xmlnode);
        objHTML.parentNode.removeChild(objHTML);
    }
}

function ICWMenuEnable(intWindowID, strEventName, blnEnabled) {
    var xmlnodelist,
        xmlnode,
        intIndex,
        xmldoc;

    xmldoc = xmlToolMenu;

    if (xmldoc != null) {
        xmlnodelist = xmldoc.selectNodes("//ToolMenu[@EventName='" + strEventName + "' and @WindowID='" + intWindowID + "']");
        var xmlnodelistlen = xmlnodelist.length;
        for (intIndex = 0; intIndex < xmlnodelistlen; intIndex++) {
            xmlnode = xmlnodelist(intIndex);
            if (blnEnabled) {
                xmlnode.setAttribute("Enabled", 1);
            }
            else {
                xmlnode.setAttribute("Enabled", 0);
            }
        }
    }
}
function ICWToolMenuOverride(strEventName, strMenuText) {
    // Function to replace a menu description for a given Event name. Routine searches for
    // ToolMenu's of type MENU with the given event name and replaces the description with
    // strMenuText.
    var xmldoc,
        xmlNodeList,
        xmlNode;
    xmldoc = xmlToolMenu;
    if ((xmldoc != null) && (strMenuText != null)) {
        xmlNodeList = xmldoc.selectNodes("//ToolMenu[@ToolMenuTypeID='2' and @EventName='" + strEventName + "']");
        var xmlNodeListlen = xmlNodeList.length;
        for (var i = 0; i < xmlNodeListlen; i++) {
            xmlNode = xmlNodeList[i];
            xmlNode.setAttribute("Description", strMenuText);
        }
    }
}

var ToolMenuItem = function () {
    /// <summary>
    /// Create a new instance of ToolMenuObject used to define the menu items which make up the application menu.
    /// <summary>

    /// </summary>
    /// The name of the image file present in folder <icw_web_folder>/images/user/.
    /// <summary>   
    this.PictureName = "";

    /// </summary>
    /// The menu item description displayed to the user.
    /// <summary>
    this.Description = "";

    /// </summary>
    /// The menu item detail displayed when the user hover overs the menu item.
    /// <summary>
    this.Detail = "";

    /// </summary>
    /// The name of the ICW Event to call which is present in the application window.
    /// <summary>
    this.EventName = "";

    /// </summary>
    /// Used to specifiy if the menu item is a divider by specifying true. Default is false.
    /// <summary>
    this.Divider = false;

    /// </summary>
    /// The data to pass to the ICW Event which is present in the application window.
    /// <summary>
    this.ButtonData = "";

    /// </summary>
    /// Internal property used to enable disable menu items.
    /// <summary>
    this.Enabled = "1";

    /// </summary>
    /// An array of menu items of type ToolMenu to define the child menu items.
    /// <summary>
    this.ToolMenu = new Array();

    /// </summary>
    /// Used instead of PictureName to define a location of the image which exist outside
    /// of folder <icw_web_folder>/images/user/ e.g. http://integrated_app/icon.gif
    /// <summary>
    this.ImageUrl = "";
}

function GetApplicationMenu(windowID) {
    /// <summary>
    /// Returns the application menu which is displayed in the top menu bar of ICW window.
    /// Returns a new instance of the menu if it doesn't exist.
    /// </summary>
    /// <param name="windowID"  type="int">
    ///    The ICW Window ID for which application menu is required.
    /// </param>
    /// <returns type="ToolMenuItem" />
    /// </summary>

    var menu = new ToolMenuItem();

    var desktop = GetJsonVersionOfTheMenuWrittenInXml();

    var menuFound = false;

    // Search for the applciation menu by using the window id.
    for (var i = 0; i < desktop.ToolMenu.ToolMenu.length; i++) {
        var topLevelMenu = desktop.ToolMenu.ToolMenu[i];
        var topLevelMenuItems = topLevelMenu.ToolMenu;

        if (topLevelMenuItems == undefined) {
            if (topLevelMenu.WindowID == windowID) {
                menuFound = true;
                break;
            }
        }
        else {
            if (topLevelMenuItems instanceof Array) {
                if (topLevelMenuItems[0].WindowID == windowID) {
                    menuFound = true;
                    break;
                }
            } else {
                if (topLevelMenuItems.WindowID == windowID) {
                    menuFound = true;
                    break;
                }
            }
        }
    }

    // Set it so it can be returned
    if (menuFound) {
        menu = topLevelMenu;
    }

    ConvertMenuItemPropertiesDataTypes(menu);

    return menu;
}

function ConvertMenuItemPropertiesDataTypes(toolMenu) {
    /// <summary>
    /// It goes through each property of the passed in object 
    /// and converts to appropriate type.
    /// </summary>
    /// <param name="toolMenu"  type="TooMenuItem">
    ///    The menu object whose properties will be converted.
    /// </param>
    /// </summary>

    toolMenu.Divider = toolMenu.Divider == "-1" ? true : false;

    // Convert the ToolMenu property to an array type.
    if (!(toolMenu.ToolMenu instanceof Array)) {
        var childMenuItems = new Array();
        if (toolMenu.ToolMenu != undefined) {
            childMenuItems.push(toolMenu.ToolMenu);
        }
        toolMenu.ToolMenu = childMenuItems;
    }

    if (toolMenu.ToolMenu instanceof Array && toolMenu.ToolMenu.length > 0) {

        for (var childMenuItemNum = 0; childMenuItemNum < toolMenu.ToolMenu.length; childMenuItemNum++) {
            ConvertMenuItemPropertiesDataTypes(toolMenu.ToolMenu[childMenuItemNum]);
        }
    }
}

function SetApplicationMenu(windowID, toolMenu) {
    /// <summary>
    /// Sets the application menu which is display in the top menu bar of ICW window.
    /// </summary>
    /// <param name="windowID"  type="int">
    ///     The ICW Window ID for which <paramref name="toolMenu"> application menu is for.
    /// </param>
    /// <param name="toolMenu"  type="TooMenuItem">
    ///    The menu object whose properties will be converted.
    /// </param>
    /// </summary>

    if ((xmlToolMenu != null) && (toolMenu != null) && (windowID != null)) {

        // The menu must have menu items in accordance to the ICW desktop editor.

        if (toolMenu.ToolMenu.length == 0) {
            throw "The menu must have menu items";
        }

        ConfigureMenuItemsDisplayOrder(toolMenu);

        ConfigureUniqueMenuIds(windowID, toolMenu);

        AddApplicationRootMenuToTheMenubar(toolMenu);

        StoreApplicationMenuStructureInPage(windowID, toolMenu);

        GenerateJsonVersionOfMenuForNavToApplicationByName();
    }
}

function ConfigureMenuItemsDisplayOrder(toolMenu, displayOrder) {
    /// <summary>
    /// Sets the display order of the <paramref name="toolMenu"> in the menu.
    /// </summary>
    /// <param name="toolMenu"  type="TooMenuItem">
    ///    The menu object whose DisplayOrder property to be set.
    /// </param>
    /// <param name="displayOrder"  type="int">
    ///   (Optional) This is used to define the display order of <paramref name="toolMenu">.
    /// </param>
    /// </summary>

    toolMenu.DisplayOrder = displayOrder == undefined ? 0 : displayOrder;

    if (toolMenu.ToolMenu instanceof Array && toolMenu.ToolMenu.length > 0) {

        for (var childMenuItemNum = 0; childMenuItemNum < toolMenu.ToolMenu.length; childMenuItemNum++) {
            ConfigureMenuItemsDisplayOrder(toolMenu.ToolMenu[childMenuItemNum], childMenuItemNum);
        }
    }
}

function ConfigureUniqueMenuIds(windowID, toolMenu, parentToolMenu, menuItemNum) {
    /// <summary>
    /// Configures unique id for each menu item in <paramref name="toolMenu"> its not been defined.
    /// </summary>
    /// <param name="windowID"  type="int">
    ///   This is used to generate the menu ids.
    /// </param>
    /// <param name="toolMenu"  type="TooMenuItem">
    ///    The menu object whose menu items need to have unique ids if they don't exist.
    /// </param>
    /// <param name="parentToolMenu"  type="TooMenuItem">
    ///   (Optional) This is used to generate the menu ids.
    /// </param>
    /// <param name="menuItemNum"  type="int">
    ///   (Optional) This is used to generate the menu ids.
    /// </param>
    /// </summary>

    if (toolMenu.ToolMenuID == undefined) {
        var parentToolMenuID = parentToolMenu == undefined ? "" : parentToolMenu.ToolMenuID;
        toolMenu.ToolMenuID = String(windowID) + String(menuItemNum || "0") + String(parentToolMenuID).replace("-", "");
        toolMenu.ToolMenuID = Number(toolMenu.ToolMenuID) * -1;
    }

    if (toolMenu.ToolMenu instanceof Array && toolMenu.ToolMenu.length > 0) {

        for (var childMenuItemNum = 0; childMenuItemNum < toolMenu.ToolMenu.length; childMenuItemNum++) {
            var childMenuItem = toolMenu.ToolMenu[childMenuItemNum];
            ConfigureUniqueMenuIds(windowID, childMenuItem, toolMenu, childMenuItemNum);
        }
    }
}

function StoreApplicationMenuStructureInPage(windowID, toolMenu) {
    /// <summary>
    /// Stores <paramref name="toolMenu"> object in the xml island defined in the ToolMenu.aspx page.
    /// </summary>
    /// <param name="windowID"  type="int">
    ///   This is used store the menu into the xml island.
    /// </param>
    /// <param name="toolMenu"  type="TooMenuItem">
    ///    The menu object which needs to be persisted in the ToolMenu.aspx page.
    /// </param>
    /// </summary>

    var toolMenuXmlElement = CreateToolMenuXmlElement(windowID, toolMenu);

    AddApplicationMenuXmlElementToThePageXml(toolMenuXmlElement);
}

function AddApplicationRootMenuToTheMenubar(toolMenu) {
    /// <summary>
    /// Generates the html menu for <paramref name="toolMenu"> and then adds/replace it in the menu bar.
    /// </summary>
    /// <param name="windowID"  type="int">
    ///   This is used when generating the menu item.
    /// </param>
    /// <param name="toolMenu"  type="TooMenuItem">
    ///    The menu object which needs to be appear in the menu bar.
    /// </param>
    /// </summary>

    var topLevelMenuItem = CreateToolMenuHtml(toolMenu);

    var existingApplicationMenuItem = $("#tblMenu td[id=" + toolMenu.ToolMenuID + "]");

    if (existingApplicationMenuItem.length > 0) {
        existingApplicationMenuItem.replaceWith(topLevelMenuItem);
    }
    else {
        $("#tblMenu td:last-child").before(topLevelMenuItem).show();
    }
}

function AddApplicationMenuXmlElementToThePageXml(appMenuXmlElement) {
    /// <summary>
    /// Stores <paramref name="appMenuXmlElement"> in the xml island defined in the ToolMenu.aspx page.
    /// </summary>
    /// <param name="appMenuXmlElement"  type="XMLElement">
    ///    The xml representation of the menu object which needs to be persisted in the ToolMenu.aspx page.
    /// </param>
    /// </summary>

    /* Resources: XMLElement object methods http://msdn.microsoft.com/en-us/library/windows/desktop/ms757048(v=vs.85).aspx
    XPATH: http://www.w3schools.com/xpath/xpath_syntax.asp */

    var existingAppMenuChildItemXmlElements = xmlToolMenu.selectNodes("Desktop/ToolMenu/ToolMenu/ToolMenu[@WindowID='" + appMenuXmlElement.getAttribute('WindowID') + "']");

    if (existingAppMenuChildItemXmlElements.length > 0) {
        var existingAppMenuItemXmlElement = existingAppMenuChildItemXmlElements[0].parentNode;
        var rootMenuXmlElement = existingAppMenuItemXmlElement.parentNode;
        rootMenuXmlElement.replaceChild(appMenuXmlElement, existingAppMenuItemXmlElement);
    }
    else {
        var existingAppMenuItemsXmlElements = xmlToolMenu.selectNodes("Desktop/ToolMenu/*");
        var helpMenuNode = existingAppMenuItemsXmlElements[existingAppMenuItemsXmlElements.length - 1];
        var rootMenuXmlElement = helpMenuNode.parentNode;
        rootMenuXmlElement.insertBefore(appMenuXmlElement, helpMenuNode);
    }
}

function CreateToolMenuHtml(toolMenu) {
    /// <summary>
    /// Generates the html menu for <paramref name="toolMenu"> object.
    /// </summary>
    /// <param name="toolMenu"  type="TooMenuItem">
    ///    The menu object for which html menu needs to be generated.
    /// </param>
    /// <returns type="string" />
    /// </summary>

    var topLevelMenuItem = new StringBuffer();
    topLevelMenuItem.append("			<td tabIndex=\"-1\" class=\"menunormal\" unselectable=\"on\" id=\'");
    topLevelMenuItem.append(toolMenu.ToolMenuID);
    topLevelMenuItem.append("\' ");
    topLevelMenuItem.append("				onclick=\"tblMenu_onclick(\'");
    topLevelMenuItem.append(toolMenu.ToolMenuID);
    topLevelMenuItem.append("\')\"");
    topLevelMenuItem.append("				onmouseenter=\"tblMenu_onmousenter(this,\'");
    topLevelMenuItem.append(toolMenu.ToolMenuID);
    topLevelMenuItem.append("\')\"");
    topLevelMenuItem.append("				onmouseleave=\"tblMenu_onmouseleave(this)\"");
    topLevelMenuItem.append("				onkeydown=\"tblMenu_onkeydown(\'");
    topLevelMenuItem.append(toolMenu.ToolMenuID);
    topLevelMenuItem.append("\')\">");
    topLevelMenuItem.append("				<div tabIndex=\"-1\" id=\"divTopMenuButtonInnerBorder\" unselectable=\"on\">");
    topLevelMenuItem.append(toolMenu.Description)
    topLevelMenuItem.append("				</div>");
    topLevelMenuItem.append("			</td>");

    return topLevelMenuItem.toString();
}

function CreateToolMenuXmlElement(windowID, toolMenu, parentMenuItem) {
    /// <summary>
    /// Generates the XML Element object for <paramref name="toolMenu"> and all its child menu items.
    /// </summary>
    /// <param name="windowID"  type="TooMenuItem">
    ///    Used to define which ICW window the menu belongs to.
    /// </param>
    /// <param name="toolMenu"  type="TooMenuItem">
    ///    The menu object for which XML Element object needs to be generated.
    /// </param>
    /// <param name="parentMenuItem"  type="TooMenuItem">
    ///    This is to define the parent menu item id.
    /// </param>
    /// <returns type="XMLElement" />
    /// </summary>

    /* Resources: XMLElement object methods http://msdn.microsoft.com/en-us/library/windows/desktop/ms757048(v=vs.85).aspx
    XPATH: http://www.w3schools.com/xpath/xpath_syntax.asp */

    var menuItemXmlElement = xmlToolMenu.createElement("ToolMenu");
    menuItemXmlElement.setAttribute("ToolMenuID", toolMenu.ToolMenuID);
    menuItemXmlElement.setAttribute("ToolMenuTypeID", "2");
    menuItemXmlElement.setAttribute("PictureName", toolMenu.PictureName);
    menuItemXmlElement.setAttribute("Description", toolMenu.Description);
    menuItemXmlElement.setAttribute("Detail", toolMenu.Detail == "" ? toolMenu.Description : toolMenu.Detail);
    menuItemXmlElement.setAttribute("DisplayOrder", toolMenu.DisplayOrder);
    menuItemXmlElement.setAttribute("Shortcut", "");
    menuItemXmlElement.setAttribute("HotKey", "");
    menuItemXmlElement.setAttribute("Divider", toolMenu.Divider == true ? "-1" : "0");
    menuItemXmlElement.setAttribute("ButtonData", toolMenu.ButtonData);
    menuItemXmlElement.setAttribute("WindowEventID", "0");
    menuItemXmlElement.setAttribute("WindowID", windowID);
    menuItemXmlElement.setAttribute("EventName", toolMenu.EventName);
    menuItemXmlElement.setAttribute("Enabled", toolMenu.Enabled == "0" ? "0" : toolMenu.EventName == "" ? "0" : "1");
    menuItemXmlElement.setAttribute("ToolMenuID_Parent", parentMenuItem == undefined ? "-1" : parentMenuItem.ToolMenuID);
    menuItemXmlElement.setAttribute("ImageUrl", toolMenu.ImageUrl);

    if (toolMenu.ToolMenu instanceof Array && toolMenu.ToolMenu.length > 0) {

        for (var childMenuItemNum = 0; childMenuItemNum < toolMenu.ToolMenu.length; childMenuItemNum++) {

            var childXmlElement = CreateToolMenuXmlElement(windowID, toolMenu.ToolMenu[childMenuItemNum], toolMenu);
            menuItemXmlElement.appendChild(childXmlElement);
        }
    }

    return menuItemXmlElement;
}

function HideMenuAndRemoveAccessKey(menuId) {
    /// <summary>
    /// Used to hide the menu and remove the keyvboard access key with <param ref="menuId" />,
    /// </summary>
    /// <param name="menuId"  type="string">
    ///   Id of the menu which needs to be hidden and remove the access key.
    /// </param>

    RemoveMenuKeyboardAccessKey(menuId);

    HideMenu(menuId);
}

function HideMenu(menuId) {
    /// <summary>
    /// Used to hide the menu  with <param ref="menuId" />,
    /// </summary>
    /// <param name="menuId"  type="string">
    ///   Id of the menu which needs to be hidden.
    /// </param>

    $("#" + menuId).remove();
}

function RemoveMenuKeyboardAccessKey(menuId) {
    /// <summary>
    /// Used to remove access keys from the menu item with <param ref="menuId" />,
    /// </summary>
    /// <param name="menuId"  type="string">
    ///   Id of the menu whose access keys neds to be removed.
    /// </param>

    var menuKeyboardAccessButtonIdSelector = "#btnMenuDropDown" + menuId;

    $(ICWWindow().GetICWAccessKeysIsland()).find(menuKeyboardAccessButtonIdSelector).remove();
    $(window.ButtonCradle).find(menuKeyboardAccessButtonIdSelector).remove();
}

function BackupAndRemoveMenuKeyboardAccessKeys() {
    /// <summary>
    /// Used to backup access keys for all menus.
    /// </summary>
    var icwAccessKeysIslandJqueryObject = $(ICWWindow().GetICWAccessKeysIsland());
    var buttonCradleJqueryObject = $(window.ButtonCradle);

    if (icwAccessKeysIslandJqueryObject.length > 0) {
        backupICWAccessKeysIslandParentNodeJqueryObject = icwAccessKeysIslandJqueryObject.get(0).parentNode;
        backupICWAccessKeysIslandJqueryObject = icwAccessKeysIslandJqueryObject.detach();
    }

    if (buttonCradleJqueryObject.length > 0) {
        backupButtonCradleParentNodeJqueryObject = buttonCradleJqueryObject.get(0).parentNode;
        backupButtonCradleJqueryObject = buttonCradleJqueryObject.detach();
    }
}

function RestoreICWMenuKeyboardAccessKeys() {
    /// <summary>
    /// Used to restore from backup access keys for all menus.
    /// </summary>
    if (backupICWAccessKeysIslandJqueryObject != undefined && backupICWAccessKeysIslandParentNodeJqueryObject != undefined) {
        backupICWAccessKeysIslandJqueryObject.appendTo(backupICWAccessKeysIslandParentNodeJqueryObject);
    }
    if (backupButtonCradleJqueryObject != undefined && backupButtonCradleParentNodeJqueryObject != undefined) {
        backupButtonCradleJqueryObject.appendTo(backupButtonCradleParentNodeJqueryObject);
    }

    backupICWAccessKeysIslandJqueryObject = null;
    backupICWAccessKeysIslandParentNodeJqueryObject = null;

    backupButtonCradleJqueryObject = null;
    backupButtonCradleParentNodeJqueryObject = null;
}

function GetJsonVersionOfTheMenuWrittenInXml() {
    /// <summary>
    /// Converts the xml island stored in ToolMenu.aspx into a json object.
    /// Returned object is {ToolMenu : [ ToolMenu, ToolMenu] }
    /// </summary>
    /// <returns type="JSON" />

    var xml = $.parseXML(document.getElementsByTagName("xml")[0].innerHTML);

    return JSON.parse(String(xml2json_2(xml)).replace("undefined", "").replace(/@/g, "").replace(/\\/g, "\\\\")).Desktop;
}