<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>


<html>
<script language="javascript" src='Touchscreenshared.js'></script>

<head>

<link rel='stylesheet' type='text/css' href='../../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../../style/Touchscreen.css' />
<script language="javascript" src="../jquery-1.3.2.js"></script>
<script language="javascript" src="../../sharedscripts/ICWFunctions.js"></script>
<script language="javascript">
//-------------------------------------------------------------------------------------------
//									
//									Touch-screen ASCII Keyboard
//
//	Useage:
//		Host in an iframe on the page where you wish to use the keyboard, using the following HTML:
//		<iframe id="fraKeyboard" frameborder="0" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/keyboard.htm"></iframe>
//
//		The following properties can be set:
//			document.frames['fraKeyboard'].NoDecimalPoint(blnValue);					//Set to false to hide the "." button
//			document.frames['fraKeyboard'].PasswordMode(blnValue);					//Set to true to cause the display to only show "*" characters
//
//		To show the keyboard, call one of its Show methods:
//			document.frames['fraKeyboard'].ShowKeyboard([strPromptText]);			//Shows a qwerty keyboard + number keys only
//			document.frames['fraKeyboard'].ShowNumpad([strPromptText]);				//Shows a small 0-9 Number pad only
//			document.frames['fraKeyboard'].ShowFull([strPromptText]);				//Shows a qwerty keyboard and 0-9 Number pad
//          document.frames['fraKeyboard'].ShowDateTimePad([strPromptText]);		//Shows a key board that expects entry of a date and time in format 
//                                                                                  //dd/mm/yyyy hh:nn
//
//		When the user has pressed ok or cancel, the keyboard will hide itself, and call
//		an event handler on the hosting page as follows:
//			function ScreenKeyboard_EnterText(strText)
//
//	Modification History:
//	25May05 AE  Written
//  13Jul12 ST  TFS36372    Added CAPS LOCK button to keyboard and added code to handle that
//                          including updated code from keyboard.htm
//
//-------------------------------------------------------------------------------------------

//Constants
var KEYBOARD_HEIGHT = 400;
var KEYBOARD_WIDTH = 750;
var FULL_HEIGHT = 400;
var FULL_WIDTH = 950;
var NUMPAD_HEIGHT = 300;
var NUMPAD_WIDTH = 400;
var DATETIMEPAD_HEIGHT = 300;
var DATETIMEPAD_WIDTH = 400;

var TYPE_FULL           = 'all';
var TYPE_KEYBOARD_ONLY  = 'kb';
var TYPE_NUMPAD_ONLY    = 'np';
var TYPE_DATETIMEPAD    = 'dt';

var m_intMaxChars;											//Maximum number of characters we allow to be input

//Property flags
var m_blnNoDecimalPoint = false;							
var m_blnPasswordMode = false;
var m_sType;
var m_ShiftDown = false;

var CapsLocked = false;

//-------------------------------------------------------------------------------------------
//									Public Methods
//-------------------------------------------------------------------------------------------
function ShowKeyboard(strPromptText, intMaxChars)
{
    void KB_Show(TYPE_KEYBOARD_ONLY, strPromptText, intMaxChars);
}

//-------------------------------------------------------------------------------------------
function ShowNumpad(strPromptText, intMaxChars)
{
    void KB_Show(TYPE_NUMPAD_ONLY, strPromptText, intMaxChars);
}

//-------------------------------------------------------------------------------------------
function ShowFull(strPromptText, intMaxChars)
{
    void KB_Show(TYPE_FULL, strPromptText, intMaxChars);
}

//-------------------------------------------------------------------------------------------
function ShowDateTimePad(strPromptText)
{
    void KB_Show(TYPE_DATETIMEPAD, strPromptText, 16);
}

//-------------------------------------------------------------------------------------------
//									Public Properties
//-------------------------------------------------------------------------------------------
function NoDecimalPoint(blnValue)
{
    m_blnNoDecimalPoint = blnValue
}

//-------------------------------------------------------------------------------------------
function PasswordMode(blnValue)
{
    m_blnPasswordMode = blnValue;
}

//-------------------------------------------------------------------------------------------
//									Internal Methods
//-------------------------------------------------------------------------------------------
function KB_Show(strType, strPromptText, intMaxChars)
{
    //Uses fraKeyboard to show the onscreen keyboard and get a search string

    // hide all items to start with
    tdNumpad.style.display = 'none';
    tdKeyboard.style.display = 'none';
    tdNumpadPrompt.style.display = 'none';

    // store type
    m_sType = strType;

    //Show the appropriate config
    switch (strType)
    {
        case TYPE_KEYBOARD_ONLY:
            //We're just showing the keyboard, the numpad is hidden
            tdKeyboard.style.display = '';
            divKeyboard.style.width = KEYBOARD_WIDTH + 'px';
            divKeyboard.style.height = KEYBOARD_HEIGHT + 'px';

            //Show the prompt if they've specified one
            lblNumpadPrompt.innerHTML = '';
            if (strPromptText != undefined && strPromptText != '')
            {
                lblPrompt.innerHTML = strPromptText
                lblPrompt.style.display = 'block';
            }
            break;

        case TYPE_NUMPAD_ONLY:
            //Just the numpad
            tdNumpad.style.display = '';
            divKeyboard.style.width = NUMPAD_WIDTH + 'px';
            divKeyboard.style.height = NUMPAD_HEIGHT + 'px';

            //Show the prompt if they've specified one
            lblPrompt.innerHTML = '';
            if (strPromptText != undefined && strPromptText != '')
            {
                lblNumpadPrompt.innerHTML = strPromptText
                tdNumpadPrompt.style.display = 'block';
            }

            break;

        case TYPE_FULL:
            tdKeyboard.style.display = '';
            divKeyboard.style.width = FULL_WIDTH + 'px';
            divKeyboard.style.height = FULL_HEIGHT + 'px';

            //Show the prompt if they've specified one
            lblNumpadPrompt.innerHTML = '';
            if (strPromptText != undefined && strPromptText != '')
            {
                lblPrompt.innerHTML = strPromptText
                lblPrompt.style.display = 'block';
            }
            break;

        case TYPE_DATETIMEPAD:
            //Just the numpad
            tdNumpad.style.display = '';
            divKeyboard.style.width = DATETIMEPAD_WIDTH + 'px';
            divKeyboard.style.height = DATETIMEPAD_HEIGHT + 'px';

            //Show the prompt if they've specified one
            lblPrompt.innerHTML = '';
            if (strPromptText != undefined && strPromptText != '')
            {
                lblNumpadPrompt.innerHTML = strPromptText + '<br>(use dd/mm/yyyy hh:mmm format)';
                tdNumpadPrompt.style.display = 'block';
            }

            // Disable decimal places
            m_blnNoDecimalPoint = true;

            break;
    }

    //Set Properties
    if (m_blnNoDecimalPoint) tdDecimal.style.visibility = 'hidden';

    //Store the number of maxchars specified
    m_intMaxChars = intMaxChars;

    //Show it
    window.parent.document.all['fraKeyboard'].style.display = 'block';
    lblDisplay.focus(); 																									//27Apr06 AE  Set focus to allow keystroke capture
}


//-------------------------------------------------------------------------------------------
//									Highlighting gubbins
//-------------------------------------------------------------------------------------------
function HighlightKey(objSrc) {
    if (IsKey(objSrc)) {
        objSrc.className = objSrc.className.split(' ')[0];
        objSrc.className += ' Hover';
    }
}

//-------------------------------------------------------------------------------------------
function UnHighlightKey(objSrc)
{
    if (IsKey(objSrc)) {
        if (objSrc.innerText.toLowerCase() == 'caps lock') {

            if (!CapsLocked) {
                objSrc.className = objSrc.className.split(' ')[0];
                objSrc.className += ' Mousedown';
            } else {
                objSrc.className = objSrc.className.split(' ')[0];
            }
        } else {
            objSrc.className = objSrc.className.split(' ')[0];
        }
    }
}

//-------------------------------------------------------------------------------------------
function KeyDown(objSrc)
{
    if (IsKey(objSrc) && (objSrc.innerText.toLowerCase() != 'caps lock')) {
        objSrc.className += ' Mousedown';
    }
}

//-------------------------------------------------------------------------------------------
function UnKeyDown(objSrc)
{
    if (IsKey(objSrc) && (objSrc.innerText.toLowerCase() != 'caps lock')) {
        if (objSrc.className.indexOf(' Mousedown') > 0) {
            objSrc.className = objSrc.className.split(' Mousedown')[0];
        }
    }
}

//-------------------------------------------------------------------------------------------
function IsKey(objSrc)
{
    var blnIsKey = true;
    if (objSrc.tagName.toLowerCase() != 'td') blnIsKey = false;
    if (objSrc.id == 'nokey') blnIsKey = false;

    return blnIsKey;
}

//-------------------------------------------------------------------------------------------
//									Character Entry
//-------------------------------------------------------------------------------------------
function CapitalizeLetters(o) {
    var objRegExp = /^[a-z]{1}$/;
    var colTD = divKeyDeck.getElementsByTagName('td');
    for (i = 0; i < colTD.length; i++) {
        if (objRegExp.test(colTD[i].innerText.toLowerCase())) {
            if (o) {
                colTD[i].innerText = colTD[i].innerText.toUpperCase();
            } else {
                colTD[i].innerText = colTD[i].innerText.toLowerCase();
            }
        }
    }
}

function GetKey(o) {
    // o -- keys on keyboad
    var colTD = divKeyDeck.getElementsByTagName('td');
    for (i = 0; i < colTD.length; i++) {
        if (colTD[i].innerText == o) {
            return colTD[i];
        }
    }
}

function KeyClick(objSrc)
{
    var keyChar = '';
    var strText = '';
    var strOriginalText = '';
    var CapsLockClass;
    
    if (lblDisplay.getAttribute('output') != null)
    {
        strText = lblDisplay.getAttribute('output');
        strOriginalText = strText;
    }

    if (IsKey(objSrc))
    {
        keyChar = objSrc.innerText;
        switch (keyChar.toLowerCase())
        {
            case 'caps lock':
                if (!CapsLocked) {
                    objSrc.className = objSrc.className.split(' ')[0];
                    CapsLocked = true;
                    CapitalizeLetters(false);
                }
                else {
                    objSrc.className += ' Mousedown';
                    CapsLocked = false;
                    CapitalizeLetters(true);
                }
                break;
            case 'back':
            case 'backspace':
                if (strText.length > 0) {
                    var cr = "&lt;br/&gt;";
                    if (strText.length >= cr.length && strText.substring(strText.length - cr.length) == cr) {
                        strText = strText.substring(0, strText.length - cr.length);
                    }
                    else {
                        strText = strText.substring(0, strText.length - 1);
                    }

                    // If displaying date time pad then also auto delete the '/', and ':' characters
                    if (m_sType == TYPE_DATETIMEPAD) {
                        var iTypeLen = strText.length;
                        if ((iTypeLen == 2) || (iTypeLen == 5) ||
				             (iTypeLen == 10) || (iTypeLen == 13))
                            strText = strText.substring(0, strText.length - 1);
                    }
                }
                void SetDisplay(strText);
                break;
            case 'return':
                if (strText.length > 0)
                {
                    strText = strText + "&lt;br/&gt;";
                }
                if (strText.length > 1024)
                {
                    strText = strOriginalText;
                }
                SetDisplay(strText);
                break;
            case 'ok':
                var bValid = true;
                if ((m_sType == TYPE_DATETIMEPAD) && !ValidateDisplayAsDateTime()) {
                    // Date\time entered is not valid
                    var sPrompt = "Invalid Expiry Date!<br>" +
                        "Dates must be in dd/mm/yyyy hh:mm format, including zeros.<br>" +
                            "For example, for nine-thirty am on the 2<super>nd<super> of November 2007, enter <br>" +
                                "02/11/2007 09:30";
                    document.frames['fraConfirm'].Show(sPrompt, "cancel");

                    bValid = false;
                }

                //  Only return if data is valid
                if (bValid)
                    ReturnText(false);
                break;

            case 'cancel':
                ReturnText(true);
                break;

            case 'space':
                //Set keyChar to char 32 and Drop down to default case
                keyChar = ' ';

            default:
                if (strText.length < 1024)
                {
                    if (
				    (strText.length == 0)
				    || (strText.substr(strText.length - 1) == ".")
				    || ((strText.length > 11) && (strText.substr(strText.length - 11) == "&lt;br/&gt;"))
				    || ((strText.length > 12) && (strText.substr(strText.length - 12) == "&lt;br/&gt; "))
				    || ((strText.length > 2) && (strText.substr(strText.length - 2) == ". "))
				    || (m_ShiftDown == true)
				    )
                    {
                        strText += keyChar;
                    }
                    else
                    {
                        if (CapsLocked) {
                            strText += keyChar.toLowerCase();
                        } else {
                            strText += keyChar;
                        }
                    }

                    // If displaying date\time keypad then auto add the '\' and ':' characters
                    if (m_sType == TYPE_DATETIMEPAD)
                    {
                        switch (strText.length)
                        {
                            case 2:
                            case 5: strText += '/'; break;
                            case 10: strText += ' '; break;
                            case 13: strText += ':'; break;
                        }
                    }
                    void SetDisplay(strText);
                }
                break;
        }
    }
    GoToBottomOfPage();
}

function onKeyDown(e) {

	if (window.event.keyCode == 8) {

		alert("z");

		e.cancelBubble = true;
	
		return false;
	}
}

//-------------------------------------------------------------------------------------------
function onKeyUp(e) {

	//Handle keypresses.  Actually intended to support barcode readers etc.
    var intCode = window.event.keyCode;
    var strChar = '';
    switch (true)
    {
        case (intCode == 20): 				//Caps Lock
            strChar = 'Caps Lock';
            break;
        case (intCode == 8): 				//backspace
            if (tdNumpad.style.display != 'none')
                strChar = 'Back';
            else
                strChar = 'Backspace';
            break;
        case (intCode == 13): 				//return
            //02Apr2009 Juny F0049416 Press "Enter" from keyboard when you add note on Patient Administration Screen, the action should move cursor to next line instead of saving the note
            strChar = 'Return';
            break;
        case (intCode == 16): 				//shift
            strChar = 'Shift';
            m_ShiftDown = true;
            break;
        case (intCode == 27): 				//escape
            strChar = 'Cancel';
            break;
        case (intCode == 32): 				//Space
            strChar = 'Space';
            break;
        case ((intCode >= 96) && (intCode <= 105)):
            strChar = String.fromCharCode(intCode - 48);
            break;
        case ((intCode == 109) || (intCode == 189)):
            strChar = '-';
            break;
        case ((intCode == 110) || (intCode == 190)):
            strChar = '.';
            break;
        case (intCode == 192):
            strChar = '\'';
            break;
        default:
            strChar = String.fromCharCode(intCode);
    }

    //Find the key for this character.  If it's visible, 'click' it
    var colTD = divKeyDeck.getElementsByTagName('td');
    for (i = 0; i < colTD.length; i++) {
        if (((colTD[i].innerText == strChar) || (colTD[i].innerText == strChar.toLowerCase())) && IsVisible(colTD[i])) {
            KeyClick(colTD[i]);

        	return;
        }
    }
}

//-------------------------------------------------------------------------------------------
function onKeyup()
{
    //Handle keypresses.  Actually intended to support barcode readers etc.
    var intCode = window.event.keyCode;
    if (intCode == 16)				//shift
        m_ShiftDown = false;
}

//-------------------------------------------------------------------------------------------
function IsVisible(objElement)
{
    //Returns true if the element is visible.  Note that invisibility might be specified some levels higher.
    do
    {
        if (objElement.currentStyle.display == 'none') return false;
        if (objElement.currentStyle.visibility == 'hidden') return false;

        objElement = objElement.parentElement;
    }
    while (objElement.tagName.toLowerCase() != 'body');

    return true;
}

//-------------------------------------------------------------------------------------------
function SetDisplay(strText)
{
    //Store the text 
    void lblDisplay.setAttribute('output', strText);

    //Update the display; replace with * for password mode
    if (m_blnPasswordMode)
    {
        strText = RepeatString('*', strText.length);
    }
    var tidyInnerText = strText
    while (tidyInnerText.indexOf("&lt;") >= 0)
    {
        tidyInnerText = tidyInnerText.replace("&lt;", "<", "g").replace("&gt;", ">", "g").replace("<br/>", "\n", "g");
    }
    lblDisplay.innerText = tidyInnerText;
}

//-------------------------------------------------------------------------------------------
function DayInMonth(iMonth, year)
{
    if (iMonth == 4 || iMonth == 6 || iMonth == 9 || iMonth == 11)
        return 30;
    else if (iMonth == 2)
    // February has 29 days in any year evenly divisible by four,
    // EXCEPT for centurial years which are not also divisible by 400.
        return (((year % 4 == 0) && ((!(year % 100 == 0)) || (year % 400 == 0))) ? 29 : 28);
    return 31;
}

//-------------------------------------------------------------------------------------------
function ValidateDisplayAsDateTime()
{
    var strText = '';

    // Get the display text
    if (lblDisplay.getAttribute('output') != null)
        strText = lblDisplay.getAttribute('output');

    // Convert from text to ints        
    var iYear = strText.substring(6, 10);
    var iMonth = strText.substring(3, 5);
    var iDay = strText.substring(0, 2);
    var iHour = strText.substring(11, 13);
    var iMins = strText.substring(14, 16);

    if (iMonth < 1 || iMonth > 12)                       // Validate Month
        return false;
    if (iDay < 1 || iDay > DayInMonth(iMonth, iYear)) // Validate Day
        return false;
    if (iYear == 0 || iYear < 1900 || iYear > 2100)      // Validate Year
        return false;
    if (iHour < 0 || iHour > 23)                         // Validate hour
        return false;
    if (iMins < 0 || iMins > 59)                         // Validate mins 
        return false;
    if (strText.length < m_intMaxChars)                  // Make all the data is present in the string 
        return false;

    return true;
}

//-------------------------------------------------------------------------------------------
//									Returning
//-------------------------------------------------------------------------------------------

function ReturnText(blnCancel)
{
    window.parent.document.all['fraKeyboard'].style.display = 'none';

    if (window.parent.ScreenKeyboard_EnterText != undefined)
    {
        //Call the event handler on the hosting page
        if (!blnCancel)
        {
            var strText = lblDisplay.getAttribute('output');
            if (strText == null) strText = ''; 																						//18Mar06 AE  Final catch to make sure we always pass a string out
            window.parent.ScreenKeyboard_EnterText(strText);
        }
        else
        {
            window.parent.Cancel();
        }
    }
    else
    {
        //Show a warning if the event handler isn't there, to help us poor developers!
        alert('Event Handler "ScreenKeyboard_EnterText()" \n\n is missing from page "' + window.parent.document.URL + '"');
    }

    //Clear the display
    lblDisplay.innerText = '';
    lblDisplay.setAttribute('output');
}

//-------------------------------------------------------------------------------------------
//									Events
//-------------------------------------------------------------------------------------------

function Confirmed(strReturn)
{
    // Fired after the confirm dialog, but user does not have to do anything
    if (strReturn == 'cancel')//F0021340
    {
        //            ReturnText(true );
        window.parent.Confirmed("yes");
    }
}

//----------------------------------------------------------------------------------------------
function EnableScrollButtons()
{
    if (divContent.offsetHeight < (divScroller.offsetHeight - 20))
    {
        document.all['ascScrollup'].style.display = 'none';
        document.all['ascScrolldown'].style.display = 'none';
    }
    else
    {
        EnableButton(document.all['ascScrollup'], false);
    }
}

//----------------------------------------------------------------------------------------------
function PageUp()
{
    //Scroll the content window 1 page upwards
    divScroller.scrollTop = divScroller.scrollTop - 175;
    void EnableButton(document.all['ascScrolldown'], true);
    if (divScroller.scrollTop == 0)
    {
        void EnableButton(document.all['ascScrollup'], false);
    }
    else
    {
        void EnableButton(document.all['ascScrollup'], true);
    }
}

//----------------------------------------------------------------------------------------------
function GoToBottomOfPage()
{
    //Scroll the content window 1 page downwards
    divScroller.scrollTop = divContent.offsetHeight - divScroller.offsetHeight;
    void EnableButton(document.all['ascScrollup'], true);
    void EnableButton(document.all['ascScrolldown'], false);
}

//----------------------------------------------------------------------------------------------
function PageDown()
{
    //Scroll the content window 1 page downwards
    divScroller.scrollTop = divScroller.scrollTop + 175;
    void EnableButton(document.all['ascScrollup'], true);

    if ((divScroller.scrollTop + divScroller.offsetHeight) >= divContent.offsetHeight)
    {
        void EnableButton(document.all['ascScrolldown'], false);
    }
    else
    {
        void EnableButton(document.all['ascScrolldown'], true);
    }
}

</script>
</head>
<body onselectstart='return false;' 
		class="ScreenKeyboard" 
		scroll="no"	
		onkeyUp="onKeyUp(event)"
		onload="EnableScrollButtons()"
		>
		
<!-- This first table is used for alignment, plus to allow a transparent background which blocks events
	  passing through to the page below.  Other elements (divs, etc) don't seem to do this -->
<table style='height:100%;width:100%'>
	<tr>
		<td align='center'>
			
			<!-- This is the start of the keyboard itself -->
			<div class="Surround" id="divKeyboard">
				<div class="Prompt">
					<label id="lblPrompt" style="display:none;width:100%;"></label>
				</div>
				
				<div class="Display" id="" >
				<table style="width:650px;">
				<tr>
				<td>
				    	<div id="divScroller" style="overflow:hidden;height:175px;">
				<div id="divContent" style="height:175px">
					<label  style="height:175px;width:100%;" tabindex="1" id="lblDisplay" output='' hidefocus="true"	></label>					
					</div>
					</div>
				
				</td>
				<td style="width:75px">
				<table style="width:100%;height:100%">
				<tr>
					<td valign="top" >
<%
    TouchscreenShared.ScrollButtonUp("PageUp()", true,"../../../Images/Touchscreen/")
%>

					</td>
				</tr>
				<tr><td>&nbsp;</td></tr>
				<tr>
					<td valign="bottom" >
<%
    TouchscreenShared.ScrollButtonDown("PageDown()", true,"../../../Images/Touchscreen/")
%>

					</td>
				</tr>
			</table>
			</td>
			</tr>
			</table>
				</div>
				<div id="divKeyDeck" class="KeyDeck" >
				
					<table style="width:100%">
						<tr>
							<td id="tdKeyboard" align="center">
							
							<table class="Keyboard"
								onmouseover="HighlightKey(event.srcElement);"
								onmousedown="KeyDown(event.srcElement);"
								onmouseup="UnKeyDown(event.srcElement);"
								onmouseout="UnHighlightKey(event.srcElement);"
								onclick="KeyClick(event.srcElement);"
								cellpadding="0" cellspacing="2" 
								>
								<tr>
									<td class="Spacer1">&nbsp;</td>
									<td>1</td>
									<td>2</td>
									<td>3</td>
									<td>4</td>
									<td>5</td>
									<td>6</td>
									<td>7</td>
									<td>8</td>
									<td>9</td>
									<td>0</td>
									<td>-</td>
								</tr>
							</table>
							<table cellpadding="0" cellspacing="2">
								<tr>
									<td colspan=12 id="nokey">
										<table class="Keyboard" 
											onmouseover="HighlightKey(event.srcElement);"
											onmousedown="KeyDown(event.srcElement);"
											onmouseup="UnKeyDown(event.srcElement);"				
											onmouseout="UnHighlightKey(event.srcElement);"
											onclick="KeyClick(event.srcElement);"											
											cellpadding="0" cellspacing="2"
											>
											<tr class="row2">		
												<td class="Spacer2" id="nokey">&nbsp;</td>
												<td>Q</td>
												<td>W</td>
												<td>E</td>
												<td>R</td>
												<td>T</td>
												<td>Y</td>
												<td>U</td>
												<td>I</td>
												<td>O</td>
												<td>P</td>
											</tr>
											<tr>		
												<td class="Spacer3" id="nokey">&nbsp;</td>
												<td>A</td>
												<td>S</td>
												<td>D</td>
												<td>F</td>
												<td>G</td>
												<td>H</td>
												<td>J</td>
												<td>K</td>
												<td>L</td>
												<td>'</td>
											</tr>
										</table>
									
									</td>
									<td class="TallKey"
										onmouseover="HighlightKey(this);"
										onmousedown="KeyDown(this);"
										onmouseup="UnKeyDown(this);"
										onmouseout="UnHighlightKey(this);"		
										onclick="KeyClick(this);"
										>Return</td>
								
								</tr>
							</table>
							
							<table cellpadding="0" cellspacing="2">
								<tr>
									<td id="nokey" class="Spacer5">
										<table cellpadding="0" cellspacing="2">
											<tr>
												<td>
							
													<table class="Keyboard" 
														onmouseover="HighlightKey(event.srcElement);"
														onmousedown="KeyDown(event.srcElement);"
														onmouseup="UnKeyDown(event.srcElement);"
														onmouseout="UnHighlightKey(event.srcElement);"
														onclick="KeyClick(event.srcElement);"
														cellpadding="0" cellspacing="2"
														>
														<tr>
															<td class="Spacer4" id="nokey">&nbsp;</td>
															<td class="FunctionKey">Caps Lock</td>
															<td>Z</td>
															<td>X</td>
															<td>C</td>
															<td>V</td>
															<td>B</td>
															<td>N</td>
															<td>M</td>
															<td>.</td>
															
														</tr>
													</table>
							
												</td>
											</tr>
											<tr>
												<td>
													<table class="Keyboard" 
														onmouseover="HighlightKey(event.srcElement);"
														onmousedown="KeyDown(event.srcElement);"
														onmouseup="UnKeyDown(event.srcElement);"
														onmouseout="UnHighlightKey(event.srcElement);"
														onclick="KeyClick(event.srcElement);"
														cellpadding="0" cellspacing="2"
														>
														<tr>
															<td class="Spacer5" id="nokey">&nbsp;</td>
															<td class="WideKey">Space</td>				<td class="MediumKey">Backspace</td>
														</tr>
													</table>
												</td>
											</tr>
										</table>
									</td>
									<td class="TallKey"
										onmouseover="HighlightKey(this);"
										onmousedown="KeyDown(this);"
										onmouseup="UnKeyDown(this);"
										onmouseout="UnHighlightKey(this);"		
										onclick="KeyClick(this);"
										>OK</td>
								<td class="TallKey"
										onmouseover="HighlightKey(this);"
										onmousedown="KeyDown(this);"
										onmouseup="UnKeyDown(this);"
										onmouseout="UnHighlightKey(this);"		
										onclick="KeyClick(this);"
									>Cancel</td>	
								</tr>
							</table>
							
						</td>
						
                        <td id="tdNumpadPrompt" class="Prompt" style="display:none;">
						    <label id="lblNumpadPrompt" style="width:380px"></label>
						</td>
						
						<td id="tdNumpad" >
							<table cellpadding="0" cellspacing="2" style="width:230px">
								<tr>
									<td>
										
										<table class="Keyboard" 
											onmouseover="HighlightKey(event.srcElement);"
											onmousedown="KeyDown(event.srcElement);"
											onmouseup="UnKeyDown(event.srcElement);"
											onmouseout="UnHighlightKey(event.srcElement);"
											onclick="KeyClick(event.srcElement);"
											cellpadding="0" cellspacing="2"
											
											>
											<tr>
												<td>7</td>
												<td>8</td>
												<td>9</td>
											</tr>
											<tr>
												<td>4</td>
												<td>5</td>
												<td>6</td>
											</tr>
											<tr>
												<td>1</td>
												<td>2</td>
												<td>3</td>
											</tr>
											<tr>
												<td class="Spacer7" id="noKey">&nbsp;</td>
												<td>0</td>
												<td id='tdDecimal'>.</td>
											</tr>
										</table>
										
									</td>
									
									<td>
										<table class="Keyboard" 
											onmouseover="HighlightKey(event.srcElement);"
											onmousedown="KeyDown(event.srcElement);"
											onmouseup="UnKeyDown(event.srcElement);"
											onmouseout="UnHighlightKey(event.srcElement);"
											onclick="KeyClick(event.srcElement);"
											cellpadding="0" cellspacing="2"
										 	style="height:100%"
											>
											<tr>
												<td style="height:100px;width:50px" class="TallKey">OK</td>									
											</tr>
											<tr>
												<td >Back</td>
											</tr>
											<tr>
												<td>Cancel</td>
											</tr>
										</table>
									</td>
								</tr>
							</table>
						
						</td>
						
					</tr>
				</table>
											
				</div>
			</div>

		</td>
	</tr>
</table>

<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="confirm.aspx"></iframe>
</body>
<script type="text/javascript" >
    KeyClick(GetKey("Caps Lock"));    
</script>
</html>
