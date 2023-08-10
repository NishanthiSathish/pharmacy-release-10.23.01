//---------------------------------------------------------------------------------------------
//
// Shared Javascript functions for the ICW
//
//	Author:	Dave Baxter
//
//	Modification History:
//		05Feb03 AE  Added GetTRFromChild
//		17Mar03 AE  Added IsNumeric
//		03Apr03 AE  Added Popmessage (in memory of v8).			To use call: Popmessage('some text')	
//		17Apr03 AE  Added XMLEscape									usage:  strEscapedXML = XMLEscape(strUnescapedXML);
//      17Apr03 DB  Added XMLReturn                           usage : strReturnXML = XMLReturn(strEscapedXML);
//		06May03 AE  Added ToHTML										Converts string with js/vb/xml into HTML.  Used by Popmessage
//      29May03 DB  Added ShowHints                           To use ShowHints(strHintsArray). Set Element 0 to be the title,
//                                                              any subsequent elements are new paragraphs of hints/tips text. See
//                                                              function comments for further help.
//		22Jun03 PH	Added NumberToWords								Converts a floating point number into words
//		22Jun03 PH	Updated Popmessage								Now detects and auto formats BrokenRules XML
//		17Jan03 AE  Added MessageBox (old-skool dude!)		
//		29Jul04 AE  Added URLEscape()									useage:  strURL = URLEscape(strURL);	
//		11Aug04 AE  Added GetSharedScriptsURL() so that Popmessage and MessageBox can be called from anywhere
//		02N0v05 AE  Added wrapper functions, to use the XMLHTTP request object to retrieve data from the server ("AJaX")
//							function LoadHTMLIntoElementAsync(strURL, objHTMLElement)
//							function LoadHTMLIntoElementSync(strURL, objHTMLElement)
//      16May11 XN  Added ImprovedXMLReturn function
//      13Jul15 JP  TFS 121942 - EMIS re-branding
//---------------------------------------------------------------------------------------------
//Objects for asyncronous http requests
var m_objHTTPRequest;
var m_objHTTPDestinationElement;
var m_blnReplaceExisting = false;
var m_fnCallBack;

var m_objReferenceWindow;
var REFERENCEWINDOW_FEATURES = 'location:no;menubar:no;resizable:yes;status:no;titlebar:no;toolbar:no;directories:no';

(function () {

    var loadJS = function (file) {
        var script = document.createElement('script');
        script.src = file;
        script.type = 'text/javascript';
        document.getElementsByTagName('head')[0].appendChild(script);
    };

    var loadRelativeToWebsiteRootJS = function (jsFileLocationRelativeToWebsiteRoot, hasJsLoaded, nextScriptToLoad) {

        var loadNextScript = function () {
            if (nextScriptToLoad) {
                if (hasJsLoaded()) {
                    nextScriptToLoad();
                } else {
                    window.setTimeout(loadNextScript, 10);
                }
            }
        };

        var load = function () {

            if (hasJsLoaded()) {
                loadNextScript();
                return;
            }

            function GetWebSiteAddressFromScriptTagWhichLoadedThisScript() {
                var scripts = document.getElementsByTagName('script');
                var path = "";
                var mydir = "";

                for (var i = scripts.length - 1; i >= 0; i--) {
                    var scriptPath = scripts[i].src;
                    if (scriptPath.length > 0) {
                        path = scriptPath.split('?')[0]; // remove any ?query
                    }
                }

                if (path.indexOf("http://") != -1) {
                    mydir = path.split('/').slice(0, -1).join('/') + '/'; // remove last filename part of path
                }

                return mydir;
            }

            var mydir = GetWebSiteAddressFromScriptTagWhichLoadedThisScript();

            for (var i = 0; i < 5 && !hasJsLoaded(); i++) {
                loadJS(mydir + jsFileLocationRelativeToWebsiteRoot);

                jsFileLocationRelativeToWebsiteRoot = "../" + jsFileLocationRelativeToWebsiteRoot;
            };

            loadNextScript();
        };

        load();
    }

    try {

    loadRelativeToWebsiteRootJS("application/sharedscripts/ICW/lib/ICW.min.js?v=00.00.00.00", function () { return window.ICW != undefined && window.ICW.MIN != undefined; });

} catch (ex) {
    }

})();

function ReplaceString(str1, str2, str3) {

    // Function to replace one string with another. Replaces ALL occurrences of the string

    str1 = str1.split(str2).join(str3);

    return str1;

}

//---------------------------------------------------------------------------------------------


function trim(inputString) {
    // Removes leading and trailing spaces from the passed string. Also removes
    // consecutive spaces and replaces it with one space. If something besides
    // a string is passed in (null, custom object, etc.) then return the input.
    if (typeof inputString != "string") { return inputString; }
    var retValue = inputString;
    var ch = retValue.substring(0, 1);
    while (ch == " ") { // Check for spaces at the beginning of the string
        retValue = retValue.substring(1, retValue.length);
        ch = retValue.substring(0, 1);
    }
    ch = retValue.substring(retValue.length - 1, retValue.length);
    while (ch == " ") { // Check for spaces at the end of the string
        retValue = retValue.substring(0, retValue.length - 1);
        ch = retValue.substring(retValue.length - 1, retValue.length);
    }
    while (retValue.indexOf("  ") != -1) { // Note that there are two spaces in the string - look for multiple spaces within the string
        retValue = retValue.substring(0, retValue.indexOf("  ")) + retValue.substring(retValue.indexOf("  ") + 1, retValue.length); // Again, there are two spaces in each of the strings
    }
    return retValue; // Return the trimmed string back to the user
} // Ends the "trim" function


//---------------------------------------------------------------------------------------------

function GetTRFromChild(objHTMLElement) {

    //Given an element contained within a table row, return
    //a reference to the row.  The given element may be any number
    //of levels down, eg an <img> within a <span> within a <td>
    //Mostly usefull in event handlers which deal with whole rows, 
    //as srcElement will report the particular item in the row which
    //raised the event, rather than the row itself
    //
    //		objHTMLElement:		Any HTML DOM Element reference
    //		returns:					Refernce to the <TR> element containing
    //									the objHTMLElement

    var strTag = new String();
    var blnFound = false;

    var objElement = objHTMLElement;

    do {
        strTag = objElement.tagName;
        strTag = strTag.toLowerCase();
        if (strTag == 'tr') {
            blnFound = true;
        }
        else {
            objElement = objElement.parentElement;
        }
    }
    while (!blnFound)

    return objElement;

}


//---------------------------------------------------------------------------------------------

function GetTableFromChild(objHTMLElement) {

    //Given an element contained within a table row, return
    //a reference to the row.  The given element may be any number
    //of levels down, eg an <img> within a <span> within a <td>
    //Mostly usefull in event handlers which deal with whole rows, 
    //as srcElement will report the particular item in the row which
    //raised the event, rather than the row itself
    //
    //		objHTMLElement:		Any HTML DOM Element reference
    //		returns:					Refernce to the <TR> element containing
    //									the objHTMLElement

    var strTag = new String();
    var blnFound = false;

    var objElement = objHTMLElement;

    do {
        strTag = objElement.tagName;
        strTag = strTag.toLowerCase();
        if (strTag == 'table') {
            blnFound = true;
        }
        else {
            objElement = objElement.parentElement;
        }
    }
    while (!blnFound)

    return objElement;

}

//---------------------------------------------------------------------------------------------

function IsNumeric(anyString) {

    //Returns true if the string given contains only numerical characters, plus up to one dec point.

    var blnReturn = true;
    var intCount = new Number();
    var ALL_NUMERICS = '1234567890';
    var intPointCount = new Number();

    for (intCount = 0; intCount < anyString.length; intCount++) {
        if (ALL_NUMERICS.indexOf(anyString.charAt(intCount)) < 0) {
            //This char is not a number...
            if (anyString.charAt(intCount) == '.') {
                intPointCount++;
                if (intPointCount > 1) {											//Cam only have one dp
                    blnReturn = false;
                    break;
                }
            }
            else {																		//Not a number, not a dp, so no way jose
                blnReturn = false;
            }

        }
    }

    return blnReturn;

}

//---------------------------------------------------------------------------------------------

function Popmessage(strText, strTitle, strFeatures) {

    //Wrapper to display the simple popmessage window.
    //VB and JS control chars are honoured, and XML can be passed unescaped.

    if (strFeatures == undefined) {
        strFeatures = 'dialogHeight:200px;'
						 + 'dialogWidth:300px;'
						 + 'resizable:yes;'
						 + 'status:no;help:no;';
    }

    if (strTitle == undefined) {
        strTitle = 'EMIS Health';
    }

    // 27Aug04 PH Made custom title work.
    var strURL = GetSharedScriptsURL() + 'Popmessage.aspx?title=' + strTitle; 											//11Aug04 AE  Added GetSharedScriptsURL()

    void window.showModalDialog(strURL, strText, strFeatures);
}


//---------------------------------------------------------------------------------------------


function InputBox(strTitle, strText, strButtons, strDefault, strMask, strFeatures, required) {
    //Wrapper to display the InputBox.
    //VB and JS control chars are honored, and XML can be passed unescaped.

    // strTitle:    Title for the top of the box.  Defaults to "EMIS Health ICW"
    // strText:     Text message to display 
    // strButtons:  one of (case insensitive)
    //                                          "Ok"
    //                                          "OkCancel"
    //                                          "YesNo"
    //                                          "CancelOk"
    //                                          "NoYes"
    //  strDefault: Default input. Defaults to empty
    //  strMask:    see controls.js for full ranged of valid chars normally one of
    //                                                                             INTEGER
    //                                                                             NUMBERS
    //                                                                             LETTERS
    //                                                                             ANY
    //                                                                             DATE[:dateformat]
    //                                                                             TIME
    // strFeatures: Features string for the showModalDialog method.  Defaults if not set.
    // required:    If value is required
    //
    // Returns:     Value entered by the user if Yes or OK button is pressed, else null.
    //
    //            Modification History:
    //            07Jan09 XN  Written
    //            03Jul09 XN  Returns null instead of blank string if user presses Yes or Ok
    //            21Jan15 XN  Added required option 26734

    var strURL = new String();
    var astrURL = new Array();
    var intCount = new Number();
    var strMessageBoxURL = new String();
    var objArgs = new Object();

    if (strFeatures == undefined) {
        strFeatures = 'dialogHeight:200px;'
                      + 'dialogWidth:300px;'
                      + 'resizable:yes;'
                      + 'status:no;help:no;';
    }

    // If title not specific then set default
    objArgs.title = (strTitle == undefined) ? 'EMIS Health ICW' : strTitle;

    // Get test for buttons
    switch (strButtons.toLowerCase()) {
        case 'ok': objArgs.button1 = 'OK,y';
            objArgs.button2 = undefined;
            break;
        case 'okcancel': objArgs.button1 = 'OK,y';
            objArgs.button2 = 'Cancel,x';
            break;
        case 'yesno': objArgs.button1 = 'Yes,y';
            objArgs.button2 = 'No,n';
            break;
        case 'cancelok': objArgs.button1 = 'Cancel,x';
            objArgs.button2 = 'OK,y';
            break;
        case 'noyes': objArgs.button1 = 'No,n';
            objArgs.button2 = 'Yes,y';
            break;
    }

    // If no mask then default to any
    objArgs.mask = ((strMask == undefined) || (strMask == '')) ? 'ANY' : strMask;

    // If no default value set to blank string
    objArgs.defaultValue = (strDefault == undefined) ? '' : strDefault;

    // set text to display
    objArgs.text = (strText == undefined) ? '' : strText;

    // set required 21Jan15 XN  26734
    objArgs.required = required;

    // Work out the relative path to InputBox.htm (since we may be calling this from anywhere)
    strInputBoxURL = GetSharedScriptsURL() + 'InputBox.htm';
    return window.showModalDialog(strInputBoxURL, objArgs, strFeatures);
}


//---------------------------------------------------------------------------------------------

function ICWConfirm(strText, strButtons, strTitle, strFeatures) {

    //Wrapper to display the simple ICWConfirm window.

    if (strFeatures == undefined) {
        strFeatures = 'dialogHeight:200px;'
						 + 'dialogWidth:300px;'
						 + 'resizable:yes;'
						 + 'status:no;help:no;';
    }

    if (strTitle == undefined) {
        strTitle = 'EMIS Health';
    }

    if (strButtons == undefined) {
        strTitle = 'OK,Cancel';
    }

    var strURL = GetSharedScriptsURL() + 'ICWConfirm.aspx?title=' + strTitle + '&buttons=' + strButtons;

    return window.showModalDialog(strURL, strText, strFeatures);
}

//---------------------------------------------------------------------------------------------

function XMLEscape(strUnescaped_XML) {

    //Escapes the given string according to the XML syntax.	

    var strReturn_XML = new String(strUnescaped_XML);
    strReturn_XML = ReplaceString(strReturn_XML, '&', '&amp;');
    strReturn_XML = ReplaceString(strReturn_XML, '"', '&quot;');
    strReturn_XML = ReplaceString(strReturn_XML, "'", "&#39;");
    //strReturn_XML = ReplaceString(strReturn_XML, "'", '&apos;'); XN 12Mar15 Updated after code review 113624
    strReturn_XML = ReplaceString(strReturn_XML, '<', '&lt;');
    strReturn_XML = ReplaceString(strReturn_XML, '>', '&gt;');
    strReturn_XML = ReplaceString(strReturn_XML, '/', '&#47;');

    return strReturn_XML;

}


//---------------------------------------------------------------------------------------------

function XMLReturn(strEscaped_XML) {

    // Returns Escaped XML back to it's original form.	

    var strReturn_XML = new String(strEscaped_XML);

    strReturn_XML = ReplaceString(strReturn_XML, '&amp;', '&');
    strReturn_XML = ReplaceString(strReturn_XML, '&quot;', '"');
    strReturn_XML = ReplaceString(strReturn_XML, "&#39;", "'");
    strReturn_XML = ReplaceString(strReturn_XML, '&apos;', "'");
    strReturn_XML = ReplaceString(strReturn_XML, '&lt;', '<');
    strReturn_XML = ReplaceString(strReturn_XML, '&gt;', '>');
    strReturn_XML = ReplaceString(strReturn_XML, '&#47;', '/');

    return strReturn_XML;

}

//---------------------------------------------------------------------------------------------

// Returns Escaped XML back to it's original form.	
// However unlike the XMLReturn 
// if unescaped string is '&lt;' then escaped string returns '&amplt;'
// with XMLReturn this becomes '<lt' be with ImprovedXMLReturn becomes '&lt;'
function ImprovedXMLReturn(strEscaped_XML) {
    var strReturn_XML = new String(strEscaped_XML);
    strReturn_XML = ReplaceString(strReturn_XML, '&quot;', '"');
    strReturn_XML = ReplaceString(strReturn_XML, '&lt;', '<');
    strReturn_XML = ReplaceString(strReturn_XML, '&gt;', '>');
    strReturn_XML = ReplaceString(strReturn_XML, '&#47;', '/');
    strReturn_XML = ReplaceString(strReturn_XML, "&#39;", "'");  // XN 12Mar15 Updated after code review 113624
    strReturn_XML = ReplaceString(strReturn_XML, '&amp;', '&');
    strReturn_XML = ReplaceString(strReturn_XML, '&apos;', "'"); // seems to work have this after the &amp;
    return strReturn_XML;
}

//---------------------------------------------------------------------------------------------

function URLEscape(strURL) {

    //Escapes control characters (such as "&"	) in the given string for
    //use as a URL
    strURL = ReplaceString(strURL, '%', '%25');
    strURL = ReplaceString(strURL, ' ', '%20');
    strURL = ReplaceString(strURL, '<', '%3C');
    strURL = ReplaceString(strURL, '>', '%3E');
    strURL = ReplaceString(strURL, '#', '%23');
    strURL = ReplaceString(strURL, '{', '%7B');
    strURL = ReplaceString(strURL, '}', '%7D');
    strURL = ReplaceString(strURL, '|', '%7C');
    strURL = ReplaceString(strURL, '\x5C', '%5C'); 		// \x5c = "\"	which is a js control character.
    strURL = ReplaceString(strURL, '^', '%5E');
    strURL = ReplaceString(strURL, '~', '%7E');
    strURL = ReplaceString(strURL, '[', '%5B');
    strURL = ReplaceString(strURL, ']', '%5D');
    strURL = ReplaceString(strURL, "'", '%60');
    strURL = ReplaceString(strURL, ';', '%3B');
    strURL = ReplaceString(strURL, '/', '%2F');
    strURL = ReplaceString(strURL, '?', '%3F');
    strURL = ReplaceString(strURL, ':', '%3A');
    strURL = ReplaceString(strURL, '@', '%40');
    strURL = ReplaceString(strURL, '=', '%3D');
    strURL = ReplaceString(strURL, '&', '%26');
    strURL = ReplaceString(strURL, '$', '%24');
    strURL = ReplaceString(strURL, '+', '%2B'); 			//09Feb06 AE  Added +

    return strURL;
}
//---------------------------------------------------------------------------------------------

function ToHTML(strText, blnDoNotEscapeHTML) {

    //Takes a string containing text with 
    //unescaped HTML / XML, vb or js control characters
    //and formats it as HTML for display.  Note this is used for
    //display and is not intended as a complete HTML escaping routine
    //
    //blnDoNotEscapeHTML:  If true, HTML is not escaped, although vb and js
    //							  control characters are. 
    //Not complete yet, other control chars can be added as required.

    //21Jan04 AE  Added blnDoNotEscapeHTML parameter.

    //Constants:
    var vbCr = String.fromCharCode(13);
    var vbTab = String.fromCharCode(9);

    var HTMLNewLine = '<br>';
    var HTMLTab = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;'; 						//No real tab, so this is an approximation

    var strReturn = strText;

    //Escape XML / HTML tags
    if (blnDoNotEscapeHTML == undefined) (blnDoNotEscapeHTML = false);
    if (!blnDoNotEscapeHTML) {
        strReturn = ReplaceString(strReturn, '<', '&#60;');
        strReturn = ReplaceString(strReturn, '>', '&#62;');
        strReturn = ReplaceString(strReturn, '"', '&#34;');
    }

    //Convert vb control characters
    strReturn = ReplaceString(strReturn, vbCr, HTMLNewLine);
    strReturn = ReplaceString(strReturn, vbTab, HTMLTab);

    //Convert js control characters - now using regexp as simple string replace doesn't work on \n or \t
    strReturn = strReturn.replace(/\\n/g, "<br />");
    strReturn = strReturn.replace(/\\t/g, "<br />");

    //Return
    return strReturn;

}
//---------------------------------------------------------------------------------------------

function NumberToWords(fltNumber) {
    // Converts a number to words
    var arrDigits = new Array("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine");
    var strReturn = "";
    var blnAnd = false;
    var arrThousands = Array("thousand", "million");
    var strFraction;
    var intDecimalPointPos = 0;
    var intDecimalPlaces = 0;

    if (fltNumber > 999999999) {
        strReturn = fltNumber.toString();
    }
    else {
        if (fltNumber > 999999) {
            strReturn += ThreeDigitText(Math.floor(fltNumber / 1000000)) + " million";
            blnAnd = true;
        }
        if (fltNumber > 999) {
            if (blnAnd) {
                strReturn += " ";
            }
            strReturn += ThreeDigitText(Math.floor(fltNumber / 1000)) + " thousand";
            blnAnd = true;
        }
        if (blnAnd) {
            strReturn += " ";
        }
        strReturn += ThreeDigitText(Math.floor(fltNumber));
    }

    // Work on the fractional part

    strFraction = fltNumber.toString();
    intDecimalPointPos = strFraction.indexOf(".");
    if (intDecimalPointPos > 0) {
        strReturn += " point";
        strFraction = strFraction.substr(intDecimalPointPos + 1);
        intDecimalPlaces = strFraction.length;
        for (var intDecimalPlace = 0; intDecimalPlace < intDecimalPlaces; intDecimalPlace++) {
            strReturn += (" " + arrDigits[Number(strFraction.substr(intDecimalPlace, 1))]);
        }
    }

    return strReturn;
}


//---------------------------------------------------------------------------------------------
function ThreeDigitText(fltNumber) {
    // Converts 3 digits of a number to text
    var arrSingles = new Array("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen");
    var strReturn = "";

    fltNumber %= 1000;

    if (fltNumber >= 100) {
        fltNumber = Math.floor(fltNumber);
        strReturn = arrSingles[(Math.floor(fltNumber / 100) % 10)] + " hundred"
        if ((fltNumber % 100) != 0) {
            strReturn += " and " + TwoDigitText(fltNumber);
        }
    }
    else {
        strReturn = TwoDigitText(fltNumber);
    }
    return strReturn;
}


//---------------------------------------------------------------------------------------------

function TwoDigitText(fltNumber) {
    // Converts 2 digits of a number to text

    fltNumber %= 100;
    //04Oct12   Rams    Corrected the typo for eighteen
    var arrSingles = new Array("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen");
    var arrTens = new Array("twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety");
    fltNumber = Math.floor(fltNumber);
    if (fltNumber < 20) {
        return arrSingles[fltNumber];
    }
    else if ((fltNumber % 10) == 0) {
        return arrTens[(Math.floor(fltNumber / 10) % 10) - 2];
    }
    else {
        return arrTens[(Math.floor(fltNumber / 10) % 10) - 2] + "-" + arrSingles[(fltNumber % 10)];
    }
}

//---------------------------------------------------------------------------------------------

function DigitAtPower(fltNumber, intPower) {
    // Returns the digit at a given power-position
    var strNumber = Math.floor(fltNumber).toString();
    return strNumber.substr(strNumber.length - intPower);
}

//---------------------------------------------------------------------------------------------
function RoundToDecPl(anyNumber, decimalPlaces) {

    //Rounds any number to the given number of decimal places
    return Math.round(anyNumber * Math.pow(10, decimalPlaces)) / Math.pow(10, decimalPlaces);
}
//---------------------------------------------------------------------------------------------

function FormatDecimal(anyNumber) {

    //Takes a number.  If the number is a decimal with only zeros after the decimal point, 
    //removes the decimal part.
    //3.0  -> 3
    //3.25 -> 3.25
    //3.01 -> 3.01

    var num2 = Math.round(anyNumber);
    if (anyNumber - num2 == 0) {
        return String(Math.round(anyNumber));
    }
    else {
        return String(anyNumber);
    }


}
//---------------------------------------------------------------------------------------------

function ShowHints(strHintArray, height, width) {
    // ------------- ShowHints -------------------------------------------------------
    // Displays a floating window for hints
    // Usage :
    // strHintArray[0] - Place the TITLE for the window in here
    // strHintArray[1-n] - Place the rest of the hints here. For each new
    // section, place inside a new element.
    //
    // example of use :
    // var strHints = new Array();
    // strHints[0] = "Hints on the menu editor";
    // strHints[1] = "When on the menu/tool bar press RETURN after adding a new option";
    // strHints[2] = "Sub menus are created when....." 
    // etc...
    // void ShowHints(strHints);
    // --------------------------------------------------------------------------------

    //Display a hints in a pop-up dialogue

    var blnError = false;

    try {
        var strHintTitle = strHintArray[0];
    }
    catch (x) {
        blnError = true;
    }
    if (height == undefined) {
        height = 450;
    }
    if (width == undefined) {
        width = 350;
    }
    if (strHintTitle == undefined) {
        blnError = true;
    }

    if (blnError) {
        alert("Usage : ShowHints(HintArray), where element 0 is the title and all other elements seperate a new section of hint text");
        return 0;
    }

    var strHTML = "";
    var objPop = window.createPopup();
    objPop.document.body.style.fontFamily = 'arial';
    objPop.document.body.style.fontSize = '8pt';
    objPop.document.body.style.color = '#000000';
    objPop.document.body.style.backgroundColor = '#FFFFE3';
    objPop.document.body.style.border = '#c0c0c0 1 solid';

    strHTML = '<div style="overflow-y:auto;height:100%; border:1 solid;">'
             + '<div style="background-color:#FFFF80;border:#838383 1 solid;font-weight:bolder; font-size:10pt">'
             + strHintTitle + '</div>';

    for (var i = 1; i < strHintArray.length; i++) {
        strHTML += '<div style="border-bottom:#838383 1 solid; margin:2px;">';
        strHTML += strHintArray[i];
        strHTML += '</div>';
    }

    strHTML += '</div>';

    objPop.document.body.innerHTML = strHTML;

    // Task 52967 - Make sure popup is not cut off
    var x = window.event.screenX, y = window.event.screenY;
    if (x + width > screen.width) {
        x = screen.width - width;
    }

    void objPop.show(x, y, width, height);
}

//----------------------------------------------------------------------------------------------

function MessageBox(strTitle, strText, strButtons, strFeatures, strDefault, strIconURL) {

    //Wrapper to display the MessageBox.
    //VB and JS control chars are honoured, and XML can be passed unescaped.

    //	strTitle:				Title for the top of the box.  Defaults to "EMIS Health ICW"
    //	strText:					Text for the box
    //	strButtons:				one of (case insensetive)
    //									"Ok"
    //									"OkCancel"
    //									"YesNo"
    //									"YesNoCancel"
    //                                  "CancelOk"
    //                                  "NoYes"
    //	strFeatures:			Features string for the showModalDialog method.  Defaults if not set.
    //
    //	Returns:
    //		Value depending on the button pressed:
    //			Cancel:				"x"
    //			Yes, OK:				"y"
    //			No:					"n"
    //
    //	Modification History:
    //	17Jan04 AE  Written
    //	11Aug04 AE  Now can be called from anywhere (done to support use in NurseAdmin.aspx
    //  28Mar06 ST  Added Cancel/OK and No/Yes options (same as original but defaults to the cancel)

    var strBtns = new String();
    var strURL = new String();
    var astrURL = new Array();
    var intCount = new Number();
    var strMessageBoxURL = new String();

    //15Sep11   Rams    TFS13748 - Creating a profile with the blank strength produces bug
    if (strFeatures == undefined || strFeatures == '') {
        strFeatures = 'dialogHeight:250px;' + 'dialogWidth:350px;' + 'resizable:yes;' + 'status:no;help:no;';
    }

    if (strTitle == undefined || strTitle == '') {
        strTitle = 'EMIS Health ICW';
    }

    switch (strButtons.toLowerCase()) {
        case 'ok':
            strBtns = 'button1=OK,y;';
            break;

        case 'okcancel':
            strBtns = 'button1=OK,y;button2=Cancel,x;';
            break;

        case 'yesno':
            strBtns = 'button1=Yes,y;button2=No,n;';
            break;

        case 'yesnocancel':
            strBtns = 'button1=Yes,y;button2=No,n;button3=Cancel,x;';
            break;

        case 'cancelok':
            strBtns = 'button1=Cancel,x;button2=OK,y;';
            break;

        case 'noyes':
            strBtns = 'button1=No,n;button2=Yes,y;';
            break;
    }

    if (strDefault != undefined && strDefault != "") {
        strBtns = strBtns + "defaultbtn=" + strDefault + ";";
    }

    var strArgs = 'title=' + strTitle + ';' + 'text=' + strText + ';' + strBtns;

    //CA 16/10/14 - allow the use of an icon
    if (strIconURL != null)
        strArgs += ";icon=" + strIconURL;

    //Work out the relative path to MessageBox.htm (since we may be calling this from anywhere ('cos it's the monkey)) 11Aug04 AE  Added
    strMessageBoxURL = GetSharedScriptsURL() + 'MessageBox.htm';
    return window.showModalDialog(strMessageBoxURL, strArgs, strFeatures);
}

//----------------------------------------------------------------------------------------------
function GetSharedScriptsURL() {

    //Returns the path to the sharedscripts folder from wherever we are
    var strURL_OUT = new String()
    var strURL = document.URL;
    strURL = strURL.substring(0, strURL.indexOf('?')); 										//Strip the querystring
    var astrURL = strURL.split('/');

    //Work back up towards the /application folder, which is always present, 
    //adding a ../ link at each level we traverse.
    for (intCount = astrURL.length - 3; intCount > -1; intCount--) {
        strURL_OUT += '../';
        if (astrURL[intCount].toLowerCase() == 'application') {
            //That's as far as we need to go	
            strURL_OUT += 'sharedscripts/';
            break;
        }
    }

    if (strURL_OUT == "") {
        strURL_OUT = "../sharedscripts/";
    }
    return strURL_OUT;
}

function RepeatString(strSource, intNoOfTimes) {
    //	29Oct04 PH Repeats the given string the specified number of times

    var strResult = '';

    for (var intIndex = 0; intIndex < intNoOfTimes; intIndex++) {
        strResult += strSource;
    }

    return strResult;
}

function PadR(strSource, intNewLength, strUsingChar) {
    //	29Oct04 PH Pads the right-hand-side of a string with characters, up to the specifed length.
    //				If the source string is already longer than the lengthm then it is truncated to that length.

    return (strSource + RepeatString(strUsingChar, intNewLength)).substr(0, intNewLength);
}

function PadL(strSource, intNewLength, strUsingChar) {
    //	29Oct04 PH Pads the left-hand-side of a string with characters, up to the specifed length.
    //				If the source string is already longer than the lengthm then it is truncated to that length.

    var strPrependedSource = RepeatString(strUsingChar, intNewLength) + strSource;

    return strPrependedSource.substr(strPrependedSource.length - intNewLength, intNewLength);
}


//----------------------------------------------------------------------------------------------
function LoadHTMLIntoElementAsync(strURL, objHTMLElement, blnReplaceExisting, fnCallback) {

    //Load HTML asyncronously from a specified page into the object specified in objHTMLElement.
    //Use instead of a hidden Iframe, when the data is expected to take an appreciable time to load.
    //
    //	strURL:					URL of the page to load
    //	objHTMLElement:		HTML DOM object into which the contents of the page are loaded.
    //	blnReplaceExisting:	If true, the existing content of objHTMLElement are overwritten; if false, they are appended to
    //	fnCallBack:				(optional).  Function Reference.  If specified, this function is called when the process has completed.

    // If the object we are loading the HTML into is null there is no point carrying on.
    if (objHTMLElement == null) {
        return;
    }

    m_objHTTPDestinationElement = objHTMLElement;
    m_blnReplaceExisting = blnReplaceExisting;
    m_fnCallBack = fnCallback;
    m_objHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP"); 							//Create the object
    m_objHTTPRequest.onreadystatechange = LoadHTMLIntoElementReturn; 					//Specify an onreadystatechange event handler
    m_objHTTPRequest.open("GET", strURL, true); 											//true = asyncronously
    m_objHTTPRequest.send(); 																	//Send the request asyncronously
}

function LoadHTMLIntoElementReturn() {
    //Asyncronous callback function for LoadHTMLIntoElementAsync
    if (m_objHTTPRequest.readyState == 4) {														//4 = complete
        //Load the html into the specified element
        if (m_blnReplaceExisting) {
            m_objHTTPDestinationElement.innerHTML = m_objHTTPRequest.responseText;
        }
        else {
            m_objHTTPDestinationElement.insertAdjacentHTML('beforeEnd', m_objHTTPRequest.responseText);
        }

        //If a callback function was specified, call it now
        if (m_fnCallBack != undefined) void m_fnCallBack();
    }
}
//----------------------------------------------------------------------------------------------
function LoadHTMLIntoElementSync(strURL, objHTMLElement, blnReplaceExisting) {

    //Load HTML syncronously from a specified page into the object specified in objHTMLElement.
    //Use instead of a hidden Iframe.  Note that if the data is likely to take more than a few tenths
    //of a second, you might be better using the asyncronous method as this one will block

    m_objHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP"); 							//Create the object
    m_objHTTPRequest.open("GET", strURL, false); 											//false = syncronously
    m_objHTTPRequest.send(); 																	//Send the request syncronously
    if (blnReplaceExisting) {
        objHTMLElement.innerHTML = m_objHTTPRequest.responseText;
    }
    else {
        objHTMLElement.insertAdjacentHTML('beforeEnd', m_objHTTPRequest.responseText);
    }

}
//----------------------------------------------------------------------------------------------

function toUpperFirstChar(strInputString) {
    // 21Dec05 ST	Takes strInputString and returns it as strReturnString with the first letter of each word being 
    //				upper case and the remainder being lower case

    var temp = new Array();
    var strReturnString = "";
    var idx;

    temp = strInputString.split(' ');

    for (idx = 0; idx < temp.length; idx++) {
        strReturnString += temp[idx].charAt(0).toUpperCase();
        strReturnString += temp[idx].substr(1, temp[idx].length - 1).toLowerCase();

        if (temp[idx + 1] != null && temp[idx + 1].length > 0) {
            strReturnString += ' ';
        }
    }
    return (strReturnString);
}

//=======================================================================================================================
function QuerystringReplace(Querystring, VariableName, NewValue) {

    //Takes the specified querystring and replaces the specified variable with the new value.
    //08Mar06 AE  Pulled out of Prescription.js to share.

    var thisAttribute = '';
    var blnFound = false;

    var astrQS = Querystring.split('&');
    VariableName = VariableName.toString().toLowerCase();

    strQuerystring = '';

    for (intCount = 0; intCount < astrQS.length; intCount++) {
        if (strQuerystring != '') strQuerystring += '&';

        thisAttribute = astrQS[intCount].split('=')[0];
        if (thisAttribute.toLowerCase() == VariableName) {
            strQuerystring += VariableName + '=' + NewValue;
            blnFound = true;
        }
        else {
            strQuerystring += astrQS[intCount];
        }
    }
    if (!blnFound) {
        strQuerystring += "&" + VariableName + "=" + NewValue;
    }
    return strQuerystring;
}

//=======================================================================================================================
function ShowReferenceForProduct(SessionID, SearchCriteria) {
    //Shows reference sources for the specified product (eg, the BNF)
    //SearchCriteria can be a ProductID (preferred) or a search string.
    //04Apr06 AE  Written
    var strURL = '';

    if (IsNumeric(SearchCriteria)) {
        strURL = ReferenceURLForProductID(SessionID, SearchCriteria);
    }
    else {
        strURL = ReferenceURLForProductName(SessionID, SearchCriteria);
    }
    void Local_ShowReferenceWindow(strURL);
}

//=======================================================================================================================
function ShowReferenceForInteraction(SessionID, DrugA, DrugB) {
    //Shows reference sources for interactions between the specified products.
    //DrugA/DrugB can be a ProductID or a search string.
    //04Apr06 AE  Written
    void Local_ShowReferenceWindow(ReferenceURLForInteraction(SessionID, DrugA, DrugB))
}

//----------------------------------------------------------------------------------------
function ReferenceURLForProductID(SessionID, lngProductID) {
    return GetSharedScriptsURL() + '../Dss/Reference.aspx'
			  + '?SessionID=' + SessionID
			  + '&Mode=productsearch'
			  + '&ID=' + lngProductID;
}
//----------------------------------------------------------------------------------------
function ReferenceURLForProductName(SessionID, strProductName) {
    return GetSharedScriptsURL() + '../Dss/Reference.aspx'
			  + '?SessionID=' + SessionID
			  + '&Mode=productsearch'
			  + '&Search=' + strProductName;
}
//----------------------------------------------------------------------------------------
function ReferenceURLForInteraction(SessionID, DrugA, DrugB) {
    return GetSharedScriptsURL() + '../Dss/Reference.aspx'
				  + '?SessionID=' + SessionID
				  + '&Mode=interactionsearch'
				  + '&DrugA=' + DrugA
				  + '&DrugB=' + DrugB;
}
//----------------------------------------------------------------------------------------
function Local_ShowReferenceWindow(strURL) {
    //Wrapper function to open a single window for displaying a reference source in a new window.
    //We only open a single window, and close it if it's already open.  -> Prevent thousands of IE windows
    //being spawned.


    try {
        //We might be in an application window, so we'll try to use the ICW function
        ICWWindow().ICW_ShowReferenceWindow(strURL, REFERENCEWINDOW_FEATURES);
    }
    catch (e) {
        //If not, we are in a modal dialog, and must do it ourselves.
        if (m_objReferenceWindow != undefined) {
            void Local_CloseReferenceWindow();
        }



        //F0049606 ST 31Mar09 Changed to showmodaldialog as IE7 does not allow you to hide the url from top of the popup dialog.

        //m_objReferenceWindow = window.open (strURL, '' ,REFERENCEWINDOW_FEATURES);
        m_objReferenceWindow = window.showModalDialog(strURL, '', REFERENCEWINDOW_FEATURES);
        if (m_objReferenceWindow == 'logoutFromActivityTimeout') {
            m_objReferenceWindow = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }

    }
}
//----------------------------------------------------------------------------------------
function Local_CloseReferenceWindow() {
    //Remove the local reference window.	
    //On modal dialog pages, be sure to call this in the window.onUnload event handler, otherwise we'll never
    //be able to close the window.
    if (m_objReferenceWindow != undefined) {
        try {
            m_objReferenceWindow.close(); //Danger of closing a window that isn't open
        }
        catch (e) {
            //Hate catching all, but don't see what other alternatives there are at this point
        }

        m_objReferenceWindow = undefined;
    }
}

//23Jul2007 JMei an onclick function for poping up a searchable window
function btnMore_onclick(routine, textelement, idelement) {
    var strXML = window.showModalDialog("../routine/RoutineLookupWrapper.aspx?SessionID="
                                            + document.body.attributes("SessionID").value
                                            + "&RoutineName=" + routine
                                            + "&Options=True",
                                        undefined,
                                        "center:yes;status:no;dialogWidth:660px;dialogHeight:480px");
    if (strXML == 'logoutFromActivityTimeout') {
        strXML = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }


    if (strXML != undefined) {
        var xmlLookup = new ActiveXObject("Microsoft.XMLDOM");
        xmlLookup.loadXML(strXML);
        var xmlNode = xmlLookup.selectSingleNode("*");
        if (typeof (xmlNode) != "undefined") {
            textelement.value = xmlNode.attributes.getNamedItem("detail").nodeValue;
            idelement.value = xmlNode.attributes.getNamedItem("dbid").nodeValue;
        }
    }

}
function btnDel_onclick(textelement, idelement) {
    textelement.value = "";
    idelement.value = "0";
}


// F0086568 20May10 ST Javascript implementation of the GetKey method from GENRTL10
function GetKey(SessionID, Table) {
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    var strURL = '../sharedscripts/State.aspx'
		        + '?SessionID=' + SessionID
	            + '&Table=' + Table;

    objHTTPRequest.open("POST", strURL, false);
    objHTTPRequest.setRequestHeader("Content-Type", "text/xml");
    objHTTPRequest.send("");
    return objHTTPRequest.responseText;
}
