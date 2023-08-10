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
//---------------------------------------------------------------------------------------------
//Objects for asyncronous http requests
var m_objHTTPRequest;
var m_objHTTPDestinationElement;
var m_blnReplaceExisting = false;
var m_fnCallBack;

var m_objReferenceWindow;
var REFERENCEWINDOW_FEATURES = 'location=no,menubar=no,resizable=yes,status=no,titlebar=no,toolbar=no,directories=no,height=600,width=800';

function ReplaceString(str1, str2, str3) {

	// Function to replace one string with another. Replaces ALL occurances of the string
	
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
   ch = retValue.substring(retValue.length-1, retValue.length);
   while (ch == " ") { // Check for spaces at the end of the string
      retValue = retValue.substring(0, retValue.length-1);
      ch = retValue.substring(retValue.length-1, retValue.length);
   }
   while (retValue.indexOf("  ") != -1) { // Note that there are two spaces in the string - look for multiple spaces within the string
      retValue = retValue.substring(0, retValue.indexOf("  ")) + retValue.substring(retValue.indexOf("  ")+1, retValue.length); // Again, there are two spaces in each of the strings
   }
   return retValue; // Return the trimmed string back to the user
} // Ends the "trim" function


//---------------------------------------------------------------------------------------------

function GetTRFromChild (objHTMLElement) {
	
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

function GetTableFromChild (objHTMLElement) {
	
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

	for (intCount = 0; intCount < anyString.length; intCount ++) {
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
		strFeatures =  'dialogHeight:200px;' 
						 + 'dialogWidth:300px;'
						 + 'resizable:yes;'
						 + 'status:no;help:no;';			 	
	}
	
	if (strTitle == undefined) {
		strTitle = 'ascribe';
	}
	
	// 27Aug04 PH Made custom title work.
	var strURL = GetSharedScriptsURL() + 'Popmessage.aspx?title=' + strTitle;												//11Aug04 AE  Added GetSharedScriptsURL()
	
	void window.showModalDialog(strURL, strText, strFeatures);
}


//---------------------------------------------------------------------------------------------


function InputBox(strTitle, strText, strButtons, strDefault, strMask, strFeatures) 
{              
//Wrapper to display the InputBox.
//VB and JS control chars are honored, and XML can be passed unescaped.
                
// strTitle:    Title for the top of the box.  Defaults to "ascribe ICW"
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
//
// Returns:     Value entered by the user if Yes or OK button is pressed, else null.
//
//            Modification History:
//            07Jan09 XN  Written
//            03Jul09 XN  Returns null instead of blank string if user presses Yes or Ok

    var strURL           = new String();
    var astrURL          = new Array();
    var intCount         = new Number();
    var strMessageBoxURL = new String();
    var objArgs          = new Object();

    if (strFeatures == undefined) 
    {
        strFeatures = 'dialogHeight:200px;' 
                      + 'dialogWidth:300px;'
                      + 'resizable:yes;'
                      + 'status:no;help:no;';                                                 
    }
    
    // If title not specific then set default
    objArgs.title = (strTitle == undefined) ? 'ascribe ICW' : strTitle;
    
    // Get test for buttons
    switch (strButtons.toLowerCase()) 
    {
    case 'ok'      : objArgs.button1 = 'OK,y';                  
                     objArgs.button2 = undefined;
                     break;   
    case 'okcancel': objArgs.button1 = 'OK,y'; 
                     objArgs.button2 = 'Cancel,x';
                     break;        
    case 'yesno'   : objArgs.button1 = 'Yes,y';
                     objArgs.button2 = 'No,n';    
                     break;                              
    case 'cancelok': objArgs.button1 = 'Cancel,x';
                     objArgs.button2 = 'OK,y'; 
                     break;                            
    case 'noyes'   : objArgs.button1 = 'No,n';
                     objArgs.button2 = 'Yes,y';    
                     break;
    }
    
    // If no mask then default to any
    objArgs.mask = ((strMask == undefined) || (strMask == '')) ? 'ANY' : strMask; 
                    
    // If no default value set to blank string
    objArgs.defaultValue = (strDefault == undefined) ? '' : strDefault;    
    
    // set text to display
    objArgs.text = (strText == undefined) ? '' : strText;

    // Work out the relative path to InputBox.htm (since we may be calling this from anywhere)
    strInputBoxURL = GetSharedScriptsURL() + 'InputBox.htm';
    return window.showModalDialog(strInputBoxURL, objArgs, strFeatures);
}


//---------------------------------------------------------------------------------------------

function ICWConfirm(strText, strButtons, strTitle, strFeatures) {
	
//Wrapper to display the simple ICWConfirm window.
	
	if (strFeatures == undefined) {
		strFeatures =  'dialogHeight:200px;' 
						 + 'dialogWidth:300px;'
						 + 'resizable:yes;'
						 + 'status:no;help:no;';			 	
	}
	
	if (strTitle == undefined) {
		strTitle = 'ascribe';
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
	strReturn_XML = ReplaceString(strReturn_XML, "'", '&apos;');
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
function ImprovedXMLReturn(strEscaped_XML) 
{
	var strReturn_XML = new String(strEscaped_XML);
	strReturn_XML = ReplaceString(strReturn_XML, '&quot;', '"');
	strReturn_XML = ReplaceString(strReturn_XML, '&lt;', '<');
	strReturn_XML = ReplaceString(strReturn_XML, '&gt;', '>');
	strReturn_XML = ReplaceString(strReturn_XML, '&#47;', '/');
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
	strURL = ReplaceString(strURL, '\x5C', '%5C');			// \x5c = "\"	which is a js control character.
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
	strURL = ReplaceString(strURL, '+', '%2B');				//09Feb06 AE  Added +
	
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
	var HTMLTab = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';							//No real tab, so this is an approximation
	
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

function NumberToWords( fltNumber )
{
// Converts a number to words
	var arrDigits = new Array("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine");
	var strReturn = "";
	var blnAnd = false;
	var arrThousands = Array("thousand", "million");
	var strFraction;
	var intDecimalPointPos = 0;
	var intDecimalPlaces = 0;

	if (fltNumber>999999999)
	{
		strReturn = fltNumber.toString();
	}
	else
	{
		if (fltNumber>999999)
		{
			strReturn += ThreeDigitText(Math.floor( fltNumber/1000000 )) + " million";
			blnAnd = true;
		}
		if (fltNumber>999)
		{
			if (blnAnd)
			{
				strReturn += " ";
			}
			strReturn += ThreeDigitText(Math.floor( fltNumber/1000 )) + " thousand";
			blnAnd = true;
		}
		if (blnAnd)
		{
			strReturn += " ";
		}
		strReturn += ThreeDigitText(Math.floor( fltNumber ));
	}
	
	// Work on the fractional part
	
	strFraction = fltNumber.toString();
	intDecimalPointPos = strFraction.indexOf(".");
	if (intDecimalPointPos > 0 )
	{
		strReturn += " point";
		strFraction = strFraction.substr(intDecimalPointPos+1);
		intDecimalPlaces = strFraction.length;
		for (var intDecimalPlace = 0; intDecimalPlace < intDecimalPlaces; intDecimalPlace++)
		{
			strReturn += (" " + arrDigits[ Number( strFraction.substr(intDecimalPlace, 1) ) ] );
		}
	}
	
	return strReturn;
}


//---------------------------------------------------------------------------------------------
function ThreeDigitText(fltNumber)
{
// Converts 3 digits of a number to text
	var arrSingles = new Array("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen");
	var strReturn = "";

	fltNumber %= 1000;

	if (fltNumber>=100)
	{
		fltNumber = Math.floor(fltNumber);
		strReturn = arrSingles[ (Math.floor(fltNumber/100)%10) ] + " hundred"
		if ( (fltNumber % 100) != 0 )
		{
			strReturn += " and " + TwoDigitText(fltNumber);
		}
	}
	else
	{
		strReturn = TwoDigitText(fltNumber);
	}
	return strReturn; 
}


//---------------------------------------------------------------------------------------------

function TwoDigitText(fltNumber)
{
// Converts 2 digits of a number to text

	fltNumber %= 100;
	//04Oct12   Rams    Corrected the typo for eighteen
	var arrSingles = new Array("zero", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen", "fifteen", "sixteen", "seventeen", "eighteen", "nineteen");
	var arrTens = new Array("twenty", "thirty", "forty", "fifty", "sixty", "seventy", "eighty", "ninety");
	fltNumber = Math.floor(fltNumber);
	if (fltNumber<20)
	{
		return arrSingles[fltNumber];
	}
	else if ((fltNumber % 10) == 0)
	{
		return arrTens[ (Math.floor(fltNumber/10)%10)-2 ];
	}
	else
	{
		return arrTens[ (Math.floor(fltNumber/10)%10)-2 ] + "-" + arrSingles[ (fltNumber%10) ];
	}
}

//---------------------------------------------------------------------------------------------

function DigitAtPower(fltNumber, intPower)
{
// Returns the digit at a given power-position
	var strNumber = Math.floor(fltNumber).toString();
	return strNumber.substr(strNumber.length-intPower);
}

//---------------------------------------------------------------------------------------------
function RoundToDecPl(anyNumber, decimalPlaces){

//Rounds any number to the given number of decimal places
	return Math.round(anyNumber * Math.pow(10,decimalPlaces)) / Math.pow(10,decimalPlaces);
}
//---------------------------------------------------------------------------------------------

function FormatDecimal(anyNumber){

//Takes a number.  If the number is a decimal with only zeros after the decimal point, 
//removes the decimal part.
//3.0  -> 3
//3.25 -> 3.25
//3.01 -> 3.01

	var num2 = Math.round(anyNumber);
	if (anyNumber - num2 == 0){
		return String(Math.round(anyNumber));
	}
	else {
		return String(anyNumber);
	}


}
//---------------------------------------------------------------------------------------------

function ShowHints(strHintArray,height,width)
{
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
	
	try
	{
		var strHintTitle = strHintArray[0];	
	}
	catch(x)
	{
		blnError = true;
	}
    if(height == undefined)
    {
        height = 450;
    }
    if(width == undefined)
    {
        width = 350;
    }
	if (strHintTitle == undefined)
	{
		blnError = true;
	}
	
	if (blnError)
	{
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
             
    for (var i=1; i < strHintArray.length; i++)
    {
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

function MessageBox(strTitle, strText, strButtons, strFeatures, strDefault) {
	
//Wrapper to display the MessageBox.
//VB and JS control chars are honoured, and XML can be passed unescaped.
	
//	strTitle:				Title for the top of the box.  Defaults to "ascribe ICW"
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
		strFeatures =  'dialogHeight:250px;' 
						 + 'dialogWidth:350px;'
						 + 'resizable:yes;'
						 + 'status:no;help:no;';			 	
	}
	
	if (strTitle == undefined || strTitle =='') {
		strTitle = 'ascribe ICW';
	}
	
	switch (strButtons.toLowerCase()) {
		case 'ok':
			strBtns = 'button1=OK,y;'
			break;	

		case 'okcancel':
			strBtns = 'button1=OK,y;button2=Cancel,x;'
			break;	

		case 'yesno':
			strBtns = 'button1=Yes,y;button2=No,n;'
			break;	
	
		case 'yesnocancel':
			strBtns = 'button1=Yes,y;button2=No,n;button3=Cancel,x;'
			break;	
		
		case 'cancelok':
		    strBtns = 'button1=Cancel,x;button2=OK,y;'
		    break;
		    
		case 'noyes':
		    strBtns = 'button1=No,n;button2=Yes,y;'
		    break;
	}

	var strArgs = 'title=' + strTitle + ';'
				   + 'text=' + strText + ';'
				   + strBtns;

//Work out the relative path to MessageBox.htm (since we may be calling this from anywhere ('cos it's the monkey)) 11Aug04 AE  Added
	strMessageBoxURL = GetSharedScriptsURL() + 'MessageBox.htm';
	return window.showModalDialog(strMessageBoxURL, strArgs, strFeatures);
}

//----------------------------------------------------------------------------------------------
function GetSharedScriptsURL() {

//Returns the path to the sharedscripts folder from wherever we are
var strURL_OUT = new String()
	var strURL = document.URL;
	strURL = strURL.substring(0, strURL.indexOf('?'));											//Strip the querystring
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
	
	if (strURL_OUT == "")
	{
	    strURL_OUT = "../sharedscripts/";
	}
	return strURL_OUT;
}

function RepeatString(strSource, intNoOfTimes)
{
//	29Oct04 PH Repeats the given string the specified number of times

	var strResult = '';

	for (var intIndex=0; intIndex<intNoOfTimes; intIndex++)
	{
		strResult += strSource;
	}
	
	return strResult;
}

function PadR(strSource, intNewLength, strUsingChar)
{
//	29Oct04 PH Pads the right-hand-side of a string with characters, up to the specifed length.
//				If the source string is already longer than the lengthm then it is truncated to that length.

	return (strSource + RepeatString(strUsingChar, intNewLength) ).substr(0, intNewLength);
}

function PadL(strSource, intNewLength, strUsingChar)
{
//	29Oct04 PH Pads the left-hand-side of a string with characters, up to the specifed length.
//				If the source string is already longer than the lengthm then it is truncated to that length.

	var strPrependedSource = RepeatString(strUsingChar, intNewLength) + strSource;

	return strPrependedSource.substr(strPrependedSource.length-intNewLength, intNewLength);
}


//----------------------------------------------------------------------------------------------
function LoadHTMLIntoElementAsync(strURL, objHTMLElement, blnReplaceExisting, fnCallback){
	
//Load HTML asyncronously from a specified page into the object specified in objHTMLElement.
//Use instead of a hidden Iframe, when the data is expected to take an appreciable time to load.
//
//	strURL:					URL of the page to load
//	objHTMLElement:		HTML DOM object into which the contents of the page are loaded.
//	blnReplaceExisting:	If true, the existing content of objHTMLElement are overwritten; if false, they are appended to
//	fnCallBack:				(optional).  Function Reference.  If specified, this function is called when the process has completed.


	m_objHTTPDestinationElement = objHTMLElement;
	m_blnReplaceExisting = blnReplaceExisting;
	m_fnCallBack = fnCallback;
	m_objHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");								//Create the object
	m_objHTTPRequest.onreadystatechange=LoadHTMLIntoElementReturn;						//Specify an onreadystatechange event handler
	m_objHTTPRequest.open("GET", strURL, true);												//true = asyncronously
	m_objHTTPRequest.send();																		//Send the request asyncronously
}

function LoadHTMLIntoElementReturn(){
//Asyncronous callback function for LoadHTMLIntoElementAsync
	if (m_objHTTPRequest.readyState == 4){														//4 = complete
		//Load the html into the specified element
		if (m_blnReplaceExisting){
			m_objHTTPDestinationElement.innerHTML = m_objHTTPRequest.responseText;
		}
		else {
			m_objHTTPDestinationElement.insertAdjacentHTML ('beforeEnd', m_objHTTPRequest.responseText);
		}
		
		//If a callback function was specified, call it now
		if (m_fnCallBack != undefined) void m_fnCallBack();
	}
}
//----------------------------------------------------------------------------------------------
function LoadHTMLIntoElementSync(strURL, objHTMLElement, blnReplaceExisting){

//Load HTML syncronously from a specified page into the object specified in objHTMLElement.
//Use instead of a hidden Iframe.  Note that if the data is likely to take more than a few tenths
//of a second, you might be better using the asyncronous method as this one will block

	m_objHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");								//Create the object
	m_objHTTPRequest.open("GET", strURL, false);												//false = syncronously
	m_objHTTPRequest.send();																		//Send the request syncronously
	if (blnReplaceExisting){
		objHTMLElement.innerHTML = m_objHTTPRequest.responseText;
	}
	else {
		objHTMLElement.insertAdjacentHTML ('beforeEnd', m_objHTTPRequest.responseText);
	}

}
//----------------------------------------------------------------------------------------------

function toUpperFirstChar(strInputString)
{
	// 21Dec05 ST	Takes strInputString and returns it as strReturnString with the first letter of each word being 
	//				upper case and the remainder being lower case
	
	var temp = new Array();
	var strReturnString = "";
	var idx;
	
	temp = strInputString.split(' ');
	
	for(idx = 0; idx < temp.length; idx++)
	{
		strReturnString += temp[idx].charAt(0).toUpperCase();
		strReturnString += temp[idx].substr(1, temp[idx].length -1).toLowerCase();
		
		if(temp[idx+1] != null && temp[idx+1].length > 0)
		{
			strReturnString += ' ';
		}
	}
	return(strReturnString);
}

//=======================================================================================================================
function QuerystringReplace(Querystring, VariableName, NewValue){

//Takes the specified querystring and replaces the specified variable with the new value.
//08Mar06 AE  Pulled out of Prescription.js to share.

var thisAttribute = '';
var blnFound = false;
	
	var astrQS = Querystring.split('&');
	VariableName = VariableName.toString().toLowerCase();
	
	strQuerystring = '';
	
	for (intCount=0; intCount < astrQS.length; intCount++) {
		if (strQuerystring != '') strQuerystring += '&';
		
		thisAttribute = astrQS[intCount].split('=')[0];
		if (thisAttribute.toLowerCase() == VariableName){
			strQuerystring += VariableName + '=' + NewValue;	
			blnFound = true;
		}
		else {
			strQuerystring += astrQS[intCount];
		}
	}
	if (!blnFound)
	{
	    strQuerystring += "&" + VariableName + "=" + NewValue;
	}
	return strQuerystring;
}

//=======================================================================================================================
function ShowReferenceForProduct(SessionID, SearchCriteria){
//Shows reference sources for the specified product (eg, the BNF)
//SearchCriteria can be a ProductID (preferred) or a search string.
//04Apr06 AE  Written
var strURL = '';

	if (IsNumeric(SearchCriteria)){
		strURL = ReferenceURLForProductID(SessionID, SearchCriteria);
	}
	else {
		strURL = ReferenceURLForProductName(SessionID, SearchCriteria);
	}
	void Local_ShowReferenceWindow(strURL);
}

//=======================================================================================================================
function ShowReferenceForInteraction(SessionID, DrugA, DrugB){
//Shows reference sources for interactions between the specified products.
//DrugA/DrugB can be a ProductID or a search string.
//04Apr06 AE  Written
	void Local_ShowReferenceWindow(ReferenceURLForInteraction(SessionID, DrugA, DrugB))
}

//----------------------------------------------------------------------------------------
function ReferenceURLForProductID(SessionID, lngProductID){
	return GetSharedScriptsURL() + '../Dss/Reference.aspx'
			  + '?SessionID=' + 	SessionID
			  + '&Mode=productsearch'
			  + '&ID=' + lngProductID;
}
//----------------------------------------------------------------------------------------
function ReferenceURLForProductName(SessionID, strProductName){
	return GetSharedScriptsURL() + '../Dss/Reference.aspx'
			  + '?SessionID=' + 	SessionID
			  + '&Mode=productsearch'
			  + '&Search=' + strProductName;
}
//----------------------------------------------------------------------------------------
function ReferenceURLForInteraction(SessionID, DrugA, DrugB){
	return GetSharedScriptsURL() + '../Dss/Reference.aspx'
				  + '?SessionID=' + 	SessionID
				  + '&Mode=interactionsearch'
				  + '&DrugA=' + DrugA
				  + '&DrugB=' + DrugB;
}
//----------------------------------------------------------------------------------------
function Local_ShowReferenceWindow(strURL){
//Wrapper function to open a single window for displaying a reference source in a new window.
//We only open a single window, and close it if it's already open.  -> Prevent thousands of IE windows
//being spawned.
	try {
		//We might be in an application window, so we'll try to use the ICW function
		ICWWindow().ICW_ShowReferenceWindow(strURL, REFERENCEWINDOW_FEATURES);
	}
	catch (e){
	//If not, we are in a modal dialog, and must do it ourselves.
		if (m_objReferenceWindow != undefined){
			void Local_CloseReferenceWindow();
		}

		//F0049606 ST 31Mar09 Changed to showmodaldialog as IE7 does not allow you to hide the url from top of the popup dialog.
		//m_objReferenceWindow = window.open (strURL, '' ,REFERENCEWINDOW_FEATURES);
		m_objReferenceWindow = window.showModalDialog(strURL, '', REFERENCEWINDOW_FEATURES);
	}
}
//----------------------------------------------------------------------------------------
function Local_CloseReferenceWindow(){
//Remove the local reference window.	
//On modal dialog pages, be sure to call this in the window.onUnload event handler, otherwise we'll never
//be able to close the window.
	if (m_objReferenceWindow != undefined)
	{			
	    try
	    {
		    m_objReferenceWindow.close(); //Danger of closing a window that isn't open
		}
		catch (e)
		{
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

/*
'-----------------------------------------------------------------------------------
' Shared server-side vb script for StatusNoteToolbar
' Currrently shared by Worklist and DispensingPMR
'-----------------------------------------------------------------------------------
*/

var m_SessionID;
var m_RequestList;
var m_ResponseList;
var m_NoteType;
var m_NoteGroupID;
var m_NoteData;
var m_DiscontinuationReason;

var VALIDATION_PASS = 0;
var VALIDATION_FAIL = 1;
var VALIDATION_FAIL_LOCK = 2;

function StatusNoteButtonEnable(objButton, colItems)
{
	//Based on the currently highlighted rows (held in colItems), enable or disable
	//objButton as appropriate.
	var i = 0;
	var lngRequestTypeID = 0;
	var lngResponseTypeID = 0;
	var lastVal = 0;
	var thisVal = 0;
	var blnEnable = true;

	var strNoteType = objButton.getAttribute('notetype').split(' ').join('_x0020_'); 												//_x0020_ = placeholder for space character

	if (colItems.length == 0)
	{
		blnEnable = false;
	}
	else
	{
		lastVal = Number(colItems[0].getAttribute(strNoteType));
	}
	for (i = 0; i < colItems.length; i++)
	{
		lngRequestTypeID = Number(colItems[i].getAttribute('RequestTypeID'));
		lngResponseTypeID = Number(colItems[i].getAttribute('ResponseTypeID'));

		// See if this button applies to the selected request/response
		if (
				!RequestTypeExistsInButton(objButton, lngRequestTypeID)
				&&
				!ResponseTypeExistsInButton(objButton, lngResponseTypeID)
		   )
		{
			//This button does not apply to this item.  Hence it is disabled.	
			blnEnable = false;
			break;
		}

		thisVal = Number(colItems[i].getAttribute(strNoteType));
		if (thisVal != lastVal)
		{
			//The value of this status on this item is different from the last item, hence this status is not available
			blnEnable = false;
			break;
		}
		lastVal = thisVal;
	}
	objButton.disabled = !blnEnable
	objButton.all['imgStatusNote'].style.filter = blnEnable ? '' : 'progid:DXImageTransform.Microsoft.BasicImage(grayscale=1)';

	if (blnEnable && thisVal == 1) 
	{
		objButton.all['txtStatusNote'].innerHTML = objButton.getAttribute('deactivateverb');
	}
	else
	{
		objButton.all['txtStatusNote'].innerHTML = objButton.getAttribute('applyverb');
	}
	return blnEnable;
}

//=================================================================================================

function RequestTypeExistsInButton(objButton, lngID)
{
	// Searches for requesttype data in status buttons
	lngID = Number(lngID);
	col = objButton.getElementsByTagName("requesttype");
	for (var i = 0; i < col.length; i++)
	{
		if (Number(col[i].getAttribute("id")) == lngID)
		{
			return true;
		}
	}
	return false;
}

//=================================================================================================

function ResponseTypeExistsInButton(objButton, lngID)
{
	// Searches for responsetype data in status buttons
	lngID = Number(lngID);
	col = objButton.getElementsByTagName("responsetype");
	for (var i = 0; i < col.length; i++)
	{
		if (Number(col[i].getAttribute("id")) == lngID)
		{
			return true;
		}
	}
	return false;
}

//=================================================================================================
//F0109913 ST 04Mar11 Now breaks down the list of items into their request/response types and
//runs the old code against that 'group' of items.

function NoteTypeToggle(Button) {
    //Fires when a statusnote button is clicked.
    var bMultiSelect = false;
    var WorklistItems = null;

    // only used with paged version of the worklist!
    if (document.body.getAttribute("pagelevel") != null && document.body.getAttribute("MultiSelect") != null) {
        bMultiSelect = CanMultiSelect(document.body.getAttribute("pagelevel"), document.body.getAttribute("MultiSelect"));
    }
    
    if (!bMultiSelect) {
        WorklistItems = GetHighlightedRowXML();
    }
    else {
        WorklistItems = GetMultiHighlightedRowXML();
    }

    if (WorklistItems == null) {
        return;
    }

    
    if (!StatusNoteButtonEnable(Button, WorklistItems)) 
    {
        //Generic Status Note bits
        //Each status note results in the appearance of a button called cmdStatusNote.  Each button deals with one requesttype.
        var colStatusButtons = document.all['cmdStatusNote'];
        if (colStatusButtons != undefined) 
        {
            if (colStatusButtons.length == undefined) 
            {
                //Single button
                void StatusNoteButtonEnable(colStatusButtons, WorklistItems);
            }
            else 
            {
                //Collection
                for (i = 0; i < colStatusButtons.length; i++) 
                {
                    void StatusNoteButtonEnable(colStatusButtons[i], WorklistItems);
                }
            }
        }
        return;
    }
	
	//Fires when a statusnote button is clicked.
	//We've already established that the selected items have the same status WRT this button,
	//and hence require the same action.  But we'll check anyway...
	if (Button.disabled)
	{
		return;
	}
	var SessionID = document.body.getAttribute('sid');
	var Enabled = false;

	var StatusNoteUpdateDoc = PrepareStatusNoteUpdateXML(Button, WorklistItems);
	var NoteTypeNode = StatusNoteUpdateDoc.documentElement;
	var NoteType = NoteTypeNode.getAttribute("NoteType").split('_x0020_').join(' ');
	var NoteTypeID = NoteTypeNode.getAttribute("NoteTypeID");

	var RequestList = "";
	var ResponseList = "";

	var StatusNotes = NoteTypeNode.selectNodes("//RequestTypeStatusNote")
	for (StatusNoteIndex = 0; StatusNoteIndex < StatusNotes.length; StatusNoteIndex++)
	{
		var StatusNote = StatusNotes[StatusNoteIndex];
		var Items = StatusNote.childNodes;
		var ItemList = "";
		for (index = 0; index < Items.length; index++)
		{
			var Item = Items[index];
			if (ItemList.length > 0)
			{
				ItemList = ItemList + ",";
			}
			ItemList = ItemList + Item.getAttribute("RequestID");
			Enabled = Item.getAttribute("Enabled") == "1"
		}
		var ValidationResult = ValidateUpdate(SessionID, StatusNote, NoteTypeID, NoteType, "Request", Items, ItemList, Enabled, false);
		if (ValidationResult == VALIDATION_FAIL_LOCK)
		{
			Refresh();
			return;
		}
		else if(ValidationResult == VALIDATION_FAIL)
		{
			UnlockRequests(SessionID, ItemList);
			return;
		}
		if (RequestList.length > 0)
		{
			RequestList = RequestList + ",";
		}
		RequestList = RequestList + ItemList;
	}

	StatusNotes = NoteTypeNode.selectNodes("//ResponseTypeStatusNote")
	for (StatusNoteIndex = 0; StatusNoteIndex < StatusNotes.length; StatusNoteIndex++)
	{
		var StatusNote = StatusNotes[StatusNoteIndex];
		var Items = StatusNote.childNodes;
		var ItemList = "";
		for (index = 0; index < Items.length; index++)
		{
			var Item = Items[index];
			if (ItemList.length > 0)
			{
				ItemList = ItemList + ",";
			}
			ItemList = ItemList + Item.getAttribute("ResponseID");
			Enabled = Item.getAttribute("Enabled") == "1"
		}
		var ValidationResult = ValidateUpdate(SessionID, StatusNote, NoteTypeID, NoteType, "Response", Items, ItemList, Enabled, false);
		if (ValidationResult != VALIDATION_PASS)
		{
			return;
		}
		if (ResponseList.length > 0)
		{
			ResponseList = ResponseList + ",";
		}
		ResponseList = ResponseList + ItemList;
	}

	Button.disabled = true; //13Mar07 CD
	document.body.setAttribute('userenabled', 'false'); //13Mar07 CD
	for (index = 0; index < WorklistItems.length; index++)
	{
		// 06Dec06 PH	Add note type add to each item so that the printing system can later use it to find all reports
		//				associated with the notetype.
		WorklistItems[index].setAttribute("NoteTypeID", NoteTypeID);
    }
	if (Enabled)
	{
		//A note of this type exists, so we deactivate it. (or rather, all such notes for all selected items)
		void fraSave.DisableAttachedNoteMultiple(SessionID, NoteType, RequestList, ResponseList,m_DiscontinuationReason);
	}
	else
	{
		var HasForm = NoteTypeNode.getAttribute("HasForm") == 'true';
		var IsPrintPreview = (document.body.getAttribute("IsPrintPreview") == "on");
		//Create a new note of that type.
		if (HasForm)
		{
			//Show order entry
			if (IsPrintPreview)
			{
				// 08Apr07 PH Cannot print-preview actions with complex forms
				alert("Buttons with forms cannot be print-previewed. Switch off Print-Preview before changing the status of this item.");
				Button.disabled = false;
			}
			else
			{
				var TableName = NoteTypeNode.getAttribute("TableName");
				var NoteData = GetNoteData(SessionID, TableName);

				if (!(NoteData == 'undefined' || NoteData == 'cancel'))
				{
					//Save the note against the specified item(s)
				    fraSave.AttachSystemNote(SessionID, RequestList, ResponseList, NoteType, NoteData);

					//Cache the data in case DSS checks fail and the user overrides the warnings
					m_SessionID = SessionID;
					m_RequestList = RequestList;
					m_ResponseList = ResponseList;
					m_NoteType = NoteType;
					m_NoteGroupID = '';
					m_NoteData = NoteData;
					// 06Dec06 PH Call printing system to print any reports associated with the note type, in BATCH mode.
					PrintItem(SessionID, WorklistItems, "batch", IsPrintPreview);
				}
				else {
				    document.body.setAttribute('userenabled', 'true');
					Button.disabled = false; //13Mar07 CD
				}
			}
		}
		else
		{
			//No form, just a simple call to create a note
			// 08Apr07 PH When print-previewing, we dont write any status changes
			if (!IsPrintPreview)
			{
			    fraSave.AttachSystemNote(SessionID, RequestList, ResponseList, NoteType, '');

				//Cache the data in case DSS checks fail and the user overrides the warnings
				m_SessionID = SessionID;
				m_RequestList = RequestList;
				m_ResponseList = ResponseList;
				m_NoteType = NoteType;
				m_NoteGroupID = '';
				m_NoteData = '';
			}
			// 06Dec06 PH Call printing system to print any reports associated with the note type, in BATCH mode.
			PrintItem(SessionID, WorklistItems, "batch", IsPrintPreview);
		}
	}
	UnlockRequests(SessionID, RequestList);
}

//=================================================================================================

function StatusNoteGroupEnable(objSpanElement, objSelectedItems)
//Based on the currently highlighted rows (held in SelectedItems), enable or disable
//SpanElement as appropriate.
{
	var objSelectElement = objSpanElement.getElementsByTagName("select")[0];
	var objOptionElements = objSelectElement.getElementsByTagName("option");
	var objOptionElement;
	var intRequestTypeID = 0;
	var intResponseTypeID = 0;
	var blnEnable = true;
	var intSelectIndex;  // stores index of select group option element relating to status of selected worklist items

	// loop through option items in select element and enable all options
	for (var optIndex = 0; optIndex < objOptionElements.length; optIndex++)
	{
		objOptionElement = objOptionElements[optIndex];
		if (!(objOptionElement.id == 'optDefaultNote'))
		{
			objOptionElement.disabled = false;
			objOptionElement.style.color = '';
		}
	}
	if (objSelectedItems.length == 0)
	{
		blnEnable = false;
	}
	// loop through all selected worklist items to check item type against request / response types linked to note types in select group
	for (var index = 0; index < objSelectedItems.length; index++)
	{
		intRequestTypeID = Number(objSelectedItems[index].getAttribute('RequestTypeID'));
		intResponseTypeID = Number(objSelectedItems[index].getAttribute('ResponseTypeID'));
		// See if this element applies to the selected request/response
		if (!RequestTypeExistsInButton(objSelectElement, intRequestTypeID) && !ResponseTypeExistsInButton(objSelectElement, intResponseTypeID))
		{
			//This element does not apply to this item.  Hence it is disabled.	
			blnEnable = false;
			break;
		}
		// See if the selected item is a completed request and notegroup is Administration
		if (intRequestTypeID > 0)
		{
			if (objSelectedItems[index].getAttribute('AdministrationStatus') == 'Complete' && objSelectElement.getAttribute('notegroupname').toLowerCase() == 'administration')
			{
				//This element applies to a completed item.  Hence it is disabled.	
				blnEnable = false;
				break;
			}

			if (objSelectedItems[index].getAttribute('CreationType') == 'Pre Pack' && objSelectElement.getAttribute('notegroupname').toLowerCase() == 'administration')
			{
				blnEnable = false;
				break;
			}
		}
		// loop through select group option elements to check if it should be enabled and to check if its associated Note Type is currently set
		// It may be possible to have items in a Note Group with some Note Types allowed in worklist and others not. If we have a mix then
		// need to disabled the option
		var intSelectedNoteType = 0;
		for (var optIndex = 0; optIndex < objOptionElements.length; optIndex++)
		{
			objOptionElement = objOptionElements[optIndex];
			if (!(objOptionElement.id == 'optDefaultNote'))
			{
				// Check if current worklist item is applies to the NoteType attached to option element
				if (!RequestTypeExistsInButton(objOptionElement, intRequestTypeID) && !ResponseTypeExistsInButton(objOptionElement, intResponseTypeID))
				{
					objOptionElement.disabled = true;
					objOptionElement.style.color = '#C0C0C0';
				}
				// check if note type related to option element is currently set for worklist item
				// if it is set then check it is also the same for other selected worklist items
				var strNoteType = objOptionElement.getAttribute('notetype');
				if (Number(objSelectedItems[index].getAttribute(strNoteType)) == 1)
				{
					intSelectedNoteType = optIndex;
				}
				if (Number(objSelectedItems[index].getAttribute(strNoteType)) == 2)
				{
					intSelectedNoteType = -1;
				}
			}
		}
		if (intSelectIndex == undefined)
		{
			intSelectIndex = intSelectedNoteType;
		}
		else
		{
			if (!(intSelectIndex == intSelectedNoteType))
			{
				intSelectIndex = -1;
			}
		}
	}
	if (blnEnable)
	{
		objSelectElement.disabled = false;
		objSelectElement.selectedIndex = intSelectIndex;
	}
	else
	{
		objSelectElement.selectedIndex = -1;
		objSelectElement.disabled = true;
	}
	return blnEnable;
}

//=================================================================================================
function NoteGroupToggle(Button) {
	var Span = Button.parentNode;
	if (Span.disabled) 
	{
		return;
	}

	var WorklistItems = GetHighlightedRowXML();

	var Select = Span.getElementsByTagName("select")[0];
	var SelectedIndex = Select.selectedIndex;

	if (!StatusNoteGroupEnable(Span, WorklistItems))
	{
		return;
	}

	Select.selectedIndex = SelectedIndex;
	
	var Option = Select.options[Select.selectedIndex];
	var SessionID = document.body.getAttribute('sid');
	var StatusNoteUpdateDoc = PrepareStatusNoteUpdateXML(Option, WorklistItems);

	var NoteGroupID = Select.getAttribute("notegroupid");
	var NoteGroupName = Select.getAttribute("notegroupname");

	var NoteTypeNode = StatusNoteUpdateDoc.documentElement;
	var NoteTypeID = NoteTypeNode.getAttribute("NoteTypeID");
	var NoteType = NoteTypeNode.getAttribute("NoteType").split('_x0020_').join(' ');

	var RequestList = "";
	var ResponseList = "";

	if (!ValidateNoteGroup(SessionID, WorklistItems, NoteGroupName, NoteType))
	{
		StatusNoteGroupEnable(Span, WorklistItems);
		return;
	}

	var StatusNotes = NoteTypeNode.selectNodes("//RequestTypeStatusNote")
	for (StatusNoteIndex = 0; StatusNoteIndex < StatusNotes.length; StatusNoteIndex++)
	{
		var StatusNote = StatusNotes[StatusNoteIndex];
		var Items = StatusNote.childNodes;
		var ItemList = "";
		for (index = 0; index < Items.length; index++)
		{
			var Item = Items[index];
			if (ItemList.length > 0)
			{
				ItemList = ItemList + ",";
			}
			ItemList = ItemList + Item.getAttribute("RequestID");
		}
		var ValidationResult = ValidateUpdate(SessionID, StatusNote, NoteTypeID, NoteType, "Request", Items, ItemList, true, true);
		if (ValidationResult == VALIDATION_FAIL_LOCK)
		{
			Refresh();
			return;
		}
		else if (ValidationResult == VALIDATION_FAIL)
		{
			UnlockRequests(SessionID, ItemList);
			StatusNoteGroupEnable(Span, WorklistItems);
			return;
		}
		if (RequestList.length > 0)
		{
			RequestList = RequestList + ",";
		}
		RequestList = RequestList + ItemList;
	}

	StatusNotes = NoteTypeNode.selectNodes("//ResponseTypeStatusNote")
	for (StatusNoteIndex = 0; StatusNoteIndex < StatusNotes.length; StatusNoteIndex++)
	{
		var StatusNote = StatusNotes[StatusNoteIndex];
		var Items = StatusNote.childNodes;
		var ItemList = "";
		for (index = 0; index < Items.length; index++)
		{
			var Item = Items[index];
			if (ItemList.length > 0)
			{
				ItemList = ItemList + ",";
			}
			ItemList = ItemList + Item.getAttribute("ResponseID");
		}
		var ValidationResult = ValidateUpdate(SessionID, StatusNote, NoteTypeID, NoteType, "Response", Items, ItemList, true, true);
		if (ValidationResult != VALIDATION_PASS)
		{
			StatusNoteGroupEnable(Span, WorklistItems);
			return;
		}
		if (ResponseList.length > 0)
		{
			ResponseList = ResponseList + ",";
		}
		ResponseList = ResponseList + ItemList;
	}

	//Lock Requests
	if (!LockRequests(SessionID, RequestList))
	{
		alert("One of the requests selected is Locked via another terminal, please try again shortly.");
		Refresh();
		return;
	}


	Span.disabled = true; 			//13Mar07 CD
	document.body.setAttribute('userenabled', 'false'); 			//13Mar07 CD
	for (index = 0; index < WorklistItems.length; index++)
	{
		// 06Dec06 PH	Add note type add to each item so that the printing system can later use it to find all reports
		//				associated with the notetype.
		WorklistItems[index].setAttribute("NoteTypeID", NoteTypeID);
	}
	//Create a new note of that type.
	var HasForm = NoteTypeNode.getAttribute("HasForm") == 'true';
	var IsPrintPreview = (document.body.getAttribute("IsPrintPreview") == "on");
	if (HasForm)
	{
		//Show order entry 
		if (IsPrintPreview)
		{
			// 08Apr07 PH Cannot print-preview actions with complex forms
			alert("Buttons with forms cannot be print-previewed. Switch off Print-Preview before changing the status of this item.");
		}
		else
		{
			var TableName = NoteTypeNode.getAttribute("TableName");
			var NoteData = GetNoteData(SessionID, TableName);
			if (!(NoteData == 'undefined' || NoteData == 'cancel'))
			{
				//Save the note against the specified item(s)
				fraSave.UpdateGroupNote(SessionID, RequestList, ResponseList, NoteType, NoteGroupID, NoteData);

				//Cache the data in case DSS checks fail and the user overrides the warnings
				m_SessionID = SessionID;
				m_RequestList = RequestList;
				m_ResponseList = ResponseList;
				m_NoteType = NoteType;
				m_NoteGroupID = NoteGroupID;
				m_NoteData = NoteData;
				// 06Dec06 PH Call printing system to print any reports associated with the note type, in BATCH mode.
				PrintItem(SessionID, WorklistItems, "batch", IsPrintPreview);
			}
			else
			{
				// F0079163 ST 17Mar10 Added refresh if we cancel from the note window
				Refresh();
				UnlockRequests(SessionID, RequestList);
				return;
			}
		}
	}
	else
	{
		//No form, just a simple call to create a note
		// 08Apr07 PH When print-previewing, we dont write any status changes
		if (!IsPrintPreview)
		{
			fraSave.UpdateGroupNote(SessionID, RequestList, ResponseList, NoteType, NoteGroupID, '');

			//Cache the data in case DSS checks fail and the user overrides the warnings
			m_SessionID = SessionID;
			m_RequestList = RequestList;
			m_ResponseList = ResponseList;
			m_NoteType = NoteType;
			m_NoteGroupID = NoteGroupID;
			m_NoteData = '';
		}
		// 06Dec06 PH Call printing system to print any reports associated with the note type, in BATCH mode.
		PrintItem(SessionID, WorklistItems, "batch", IsPrintPreview);
	}
	UnlockRequests(SessionID, RequestList);
}

//=================================================================================================

function GetSelectedItemIDs(objSelectedItems)
{
	var strSelectedIDs = '';
	for (var index = 0; index < objSelectedItems.length; index++)
	{
		if (strSelectedIDs != '')
		{
			strSelectedIDs += ',';
		}
		strSelectedIDs += objSelectedItems[index].getAttribute('dbid');
	}
	return strSelectedIDs;
}

//=================================================================================================

function UpdateSelectedNoteTypes(objSelectedItems, strNoteTypeID)
{
	var objReturnItems = objSelectedItems;
	for (var index = 0; index < objReturnItems.length; index++)
	{
		// 06Dec06 PH	Add note type add to each item so that the printing system can later use it to find all reports
		//				associated with the notetype.
		objReturnItems[index].setAttribute("NoteTypeID", strNoteTypeID);
	}
	return objReturnItems;
}

//=================================================================================================

function ValidateNoteGroup(intSessionID, objSelectedItems, strNoteGroupName, strNoteType)
{
	var strItemsXML = '<setnote notegroup="' + strNoteGroupName + '" notetype="' + strNoteType + '">';
	for (var index = 0; index < objSelectedItems.length; index++)
	{
		strItemsXML = strItemsXML + objSelectedItems[index].xml
	}
	strItemsXML = strItemsXML + '</setnote>'
	var strURL = '../OrderEntry/NoteGroupCheck.aspx' + '?SessionID=' + intSessionID;

	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
	objHTTPRequest.open("POST", strURL, false);      //false = syncronous                              
	objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	objHTTPRequest.send(strItemsXML);

	//  Check the response to see if any items are invalid
	var strResponseXML = objHTTPRequest.responseText;
	var xmlDOM = new ActiveXObject("MSXML2.DOMDocument")
	xmlDOM.loadXML(strResponseXML);
	var InvalidItems = xmlDOM.documentElement.childNodes;
	var retVal = true;
	for (var index = 0; index < InvalidItems.length; index++)
	{
		var strMessage = InvalidItems[index].getAttribute("message")
		var strFeatures = 'dialogHeight:250px;'
				+ 'dialogWidth:500px;'
				+ 'resizable:no;'
				+ 'status:no;help:no;';
		Popmessage(strMessage, 'Warning!', strFeatures)
		retVal = false;
	}
	return retVal;
}

//=================================================================================================

function ValidateUpdate(SessionID, StatusNote, NoteTypeID, NoteType, DataClass, Items, ItemList, Enabled, IsNoteGroup) {
	var AllowDuplicates = StatusNote.getAttribute("AllowDuplicates") == "1";
	if (!IsNoteGroup && !AllowDuplicates && !Enabled)
	{
		if (DataClass == 'Request' && !LockRequests(SessionID, ItemList))
		{
			alert("One of the requests selected is Locked via another terminal, please try again shortly.");
			return VALIDATION_FAIL_LOCK;
		}

		var existingNotes = GetExistingNoteIds(SessionID, NoteTypeID, DataClass, ItemList);

		if (existingNotes.length > 0)
		{
			var invalidDescriptions = "";
			for (var index = 0; index <= existingNotes.length; index++)
			{
				var Item = FindItemByDbId(Items, DataClass, existingNotes[index]);
				if (Item == null) continue;
				invalidDescriptions += Item.getAttribute("Detail") + "\n";
			}
		    alert("The item(s) below have already been marked as '" + StatusNote.getAttribute("ApplyVerb") + "', so they have been left unchanged.\n\n" + invalidDescriptions);
			return VALIDATION_FAIL;
		}
	}

	var UserAuthentication = StatusNote.getAttribute("UserAuthentication") == "1";
	var PreconditionRoutine = StatusNote.getAttribute("PreconditionRoutine");
	var StopOnError = StatusNote.getAttribute("StopOnError") == "1";
	var DiscontinuationReasonMandatory = StatusNote.getAttribute("DiscontinuationReasonMandatory") == "1";
	var NoteVerb;
	var StatusChange;
	if (Enabled)
	{
		NoteVerb = StatusNote.getAttribute("DeactivateVerb");
		StatusChange = 'Disable';
	}
	else {
	    m_DiscontinuationReason = null;
		NoteVerb = StatusNote.getAttribute("ApplyVerb");
		StatusChange = 'Enable';
	}

	if (UserAuthentication)
	{
		if (AuthenticateUser(SessionID) != 'Valid')
		{
			return VALIDATION_FAIL;
		}
	}

	if (!(PreconditionRoutine == null || PreconditionRoutine == ""))
	{
		var URL = '../OrderEntry/PreconditionRoutine.aspx?SessionID=' + SessionID + '&ItemIDList=' + ItemList + '&BaseType=' + DataClass + '&Routine=' + PreconditionRoutine + '&StatusChange=' + StatusChange;
		var myobjHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");
		myobjHTTPRequest.open("GET", URL, false);
		myobjHTTPRequest.send();
		var PreconditionResult = myobjHTTPRequest.responseText;

		if (PreconditionResult != "")
		{
			if (StopOnError && PreconditionResult.substr(0, 6) == "ERROR:")
			{
				alert(NoteType + "\r\n\r\n" + PreconditionResult.substr(6, myobjHTTPRequest.responseText.length - 6));
				return VALIDATION_FAIL;
			}
			else
			{
				if (!confirm(NoteType + "\r\n\r\n" + PreconditionResult))
				{
					return VALIDATION_FAIL;
				}
			}
		}
    }

    if (Enabled && DiscontinuationReasonMandatory) {
        m_DiscontinuationReason = new Object();
        if (ShowStopReason(SessionID) == false) {
            return VALIDATION_FAIL;
        }
    }
	
	return VALIDATION_PASS;
}

//=================================================================================================

function AuthenticateUser(SessionID)
{
	var URL = '../ICW/authenticatemodal.aspx'
				  	+ '?SessionID=' + SessionID

	var Features = 'dialogHeight:250px;'
					+ 'dialogWidth:400px;'
					+ 'resizable:no;unadorned:no;'
					+ 'status:no;help:no;';

	var Return = window.showModalDialog(URL, '', Features);
	if (Return == 'logoutFromActivityTimeout') {
		Return = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	return Return;
}

//=================================================================================================

function ShowStopReason(SessionID) {
    var URL = '../ICW/ReasonCapture.aspx'
				  	+ '?SessionID=' + SessionID;
				  	

    var Features = 'dialogHeight:300px;'
					+ 'dialogWidth:600px;'
					+ 'resizable:no;unadorned:no;'
					+ 'status:no;help:no;';

    var Return = window.showModalDialog(URL, '', Features);
	if (Return == 'logoutFromActivityTimeout') {
		Return = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

    if (Return == null || Return.cancelselected == 'true') {
        alert('Cannot Save changes, Discontinuation Reason is mandatory');
        return  false;
    }
    else {
        m_DiscontinuationReason = Return;
        return true;
    }
    
}

//=================================================================================================

function GetNoteData(SessionID, TableName)
{
	var URL = V11Location(SessionID) + '/OrderComms/Views/OrderEntry/AttachedNoteDataEntry.aspx'
					+ '?SessionID=' + SessionID
					+ '&TableName=' + TableName;
	var v11Mask = ICWWindow().document.getElementById('v11Mask');

	v11Mask.style.display = 'block';
	v11Mask.style.top = 0;

	var NoteData = window.showModalDialog(URL, '', OrderEntryFeaturesV11());
	if (NoteData == 'logoutFromActivityTimeout') {
		NoteData = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	v11Mask.style.display = 'none';

	return NoteData;
}

//=================================================================================================

function slcNoteGroup_onpropertychange(SelectElement)
{
	if (window.event.propertyName == 'selectedIndex')
	{
		var ButtonElement = SelectElement.parentNode.getElementsByTagName("button")[0];
		if (SelectElement.selectedIndex > -1)
		{
			if (SelectElement.options[SelectElement.selectedIndex].isDisabled)
			{
				SelectElement.selectedIndex = -1;
			}
			else
			{
				ButtonElement.disabled = false;
			}
		}
		else
		{
			ButtonElement.disabled = true;
		}
	}
}

//=================================================================================================

function ClearStatusNoteCache()
{
	//Clear the cache
	m_SessionID = -1;
	m_RequestList = '';
	m_ResponseList = '';
	m_NoteType = '';
	m_NoteGroupID = '';
	m_NoteData = '';
}

//=================================================================================================

function DSSCheckOnFail(Override, DSSLogResults)
{
	var SessionID = m_SessionID;
	var RequestList = m_RequestList;
	var ResponseList = m_ResponseList;
	var NoteType = m_NoteType;
	var NoteGroupID = m_NoteGroupID;
	var NoteData = m_NoteData;
	ClearStatusNoteCache();
	//04Apr11   Rams    F0113638 - If DSS Checking is enabled against the screening note, when the screening note is applied, the worklist is not refreshed - see attachement - 10.06.00.31 - Norfolk
	//                  [Changed from (RequestList != '' && ResponseList != '') to (RequestList != '' || ResponseList != '')]
	if (Override && (RequestList != '' || ResponseList != ''))
	{
		if (NoteGroupID == '')
		{
			fraSave.AttachSystemNote(SessionID, RequestList, ResponseList, NoteType, NoteData, true, DSSLogResults);
		}
		else
		{
			fraSave.UpdateGroupNote(SessionID, RequestList, ResponseList, NoteType, NoteGroupID, NoteData, true, DSSLogResults);
		}
	}
	else
	{
		Refresh();
	}
}

//================================================================================================

function PostServerMessage(url, data)
{
	var result;
	$.ajax({
		type: "POST",
		url: url,
		data: data,
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function(msg)
		{
			result = msg;
		}
	});
	return result;
}

//================================================================================================

function GetExistingNoteIds(sessionId, noteTypeId, baseType, typeIds)
{
	var url = "../WorklistHelper/worklistHelper.aspx/GetExistingNoteIds"
	var sendData = "{'sessionId': '" + sessionId + "', 'noteTypeId': '" + noteTypeId + "', 'baseType': '" + baseType + "', 'typeIds': '" + typeIds + "' }";
	var returnData = PostServerMessage(url, sendData);
	if (returnData == null || returnData == undefined)
	{
		return [];
	}
	return returnData.d;
}

//================================================================================================

function LockRequests(sessionId, requestIds)
{
	var url = "../WorklistHelper/worklistHelper.aspx/LockRequests"
	var sendData = "{'sessionId': '" + sessionId + "', 'requestIds': '" + requestIds + "' }";
	var returnData = PostServerMessage(url, sendData);
	if (returnData == null || returnData == undefined)
	{
		return null;
	}
	return returnData.d;
}

//================================================================================================

function UnlockRequests(sessionId, requestIds)
{
	var url = "../WorklistHelper/worklistHelper.aspx/UnlockRequests"
	var sendData = "{'sessionId': '" + sessionId + "', 'requestIds': '" + requestIds + "' }";
	var returnData = PostServerMessage(url, sendData);
	if (returnData == null || returnData == undefined)
	{
		return null;
	}
	return returnData.d;
}

//================================================================================================

function FindItemByDbId(Items, DataClass, requestedDbId)
{
	if (requestedDbId == null) return null;
	for (var index = 0; index <= Items.length; index++)
	{
		var dbid;
		if (DataClass == "Request")
		{
			dbid = Items[index].getAttribute("RequestID");
		}
		else
		{
			dbid = Items[index].getAttribute("ResponseID");
		}
		if (dbid != undefined && dbid != null && dbid != requestedDbId) continue;
		return Items[index];
	}
	return null;
}

//=================================================================================================

function GetRequestTypeDataForRequestTypeID(requestTypeID, noteTypeID)
{
	var SessionID = document.body.getAttribute('sid');
	var strURL = '../sharedscripts/StatusNoteHelper.aspx' + '?SessionID=' + SessionID + '&RequestTypeID=' + requestTypeID + '&Mode=RequestType' + '&NoteTypeID=' + noteTypeID;
	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
	objHTTPRequest.open("POST", strURL, false);
	objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	objHTTPRequest.send("");

	var xmlDOM = new ActiveXObject('MSXML2.DOMDocument');
	xmlDOM.loadXML(objHTTPRequest.responseText);

	return xmlDOM.selectSingleNode("//RequestTypeStatusNote");
}

//=================================================================================================

function GetResponseTypeDataForResponseTypeID(responseTypeID, noteTypeID)
{
	var SessionID = document.body.getAttribute('sid');
	var strURL = '../sharedscripts/StatusNoteHelper.aspx' + '?SessionID=' + SessionID + '&ResponseTypeID=' + responseTypeID + '&Mode=ResponseType' + '&NoteTypeID=' + noteTypeID;
	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
	objHTTPRequest.open("POST", strURL, false);
	objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	objHTTPRequest.send("");

	var xmlDOM = new ActiveXObject('MSXML2.DOMDocument');
	xmlDOM.loadXML(objHTTPRequest.responseText);

	return xmlDOM.selectSingleNode("//ResponseTypeStatusNote");
}

//=================================================================================================

function PrepareStatusNoteUpdateXML(objSrc, colItems) {
    var NODE_ELEMENT = 1;
	var NoteTypeID = objSrc.getAttribute("notetypeid");
	var NoteTypeName = objSrc.getAttribute("notetype");
	var NoteTypeDoc = new ActiveXObject('MSXML2.DOMDocument');
	NoteTypeDoc.loadXML("<NoteType><RequestTypes /><ResponseTypes /></NoteType>");
	var NoteType = NoteTypeDoc.documentElement;
	NoteType.setAttribute("NoteTypeID", NoteTypeID);
	NoteType.setAttribute("NoteType", NoteTypeName);
	NoteType.setAttribute("TableName", objSrc.getAttribute("tablename"));
	NoteType.setAttribute("HasForm", objSrc.getAttribute("hasform"));

	for (index = 0; index < colItems.length; index++)
	{
		var item = colItems[index];
		var Class = item.getAttribute("class");
		var dbid = item.getAttribute("dbid");
		var Enabled = item.getAttribute(NoteTypeName);
		var Detail = item.getAttribute("detail");
		if (Class == "request")
		{
			var RequestTypeID = item.getAttribute("RequestTypeID");
			var RequestType = NoteType.selectSingleNode("RequestTypes/RequestTypeStatusNote[@RequestTypeID='" + RequestTypeID + "']");
			if (RequestType == null)
			{
				RequestType = NoteType.selectSingleNode("RequestTypes").appendChild(GetRequestTypeDataForRequestTypeID(RequestTypeID, NoteTypeID));
			}
			if (RequestType != null)
			{
				var Request = NoteTypeDoc.createNode(NODE_ELEMENT, "Request", "");
				Request.setAttribute("RequestID", dbid);
				Request.setAttribute("Detail", Detail);
				Request.setAttribute("Enabled", Enabled == null ? "0" : Enabled);
				RequestType.appendChild(Request);
			}
		}
		else if (Class == "response")
		{
			var ResponseTypeID = item.getAttribute("ResponseTypeID");
			var ResponseType = NoteType.selectSingleNode("ResponseTypes/ResponseTypeStatusNote[@ResponseTypeID='" + ResponseTypeID + "']");
			if (ResponseType == null)
			{
				ResponseType = NoteType.selectSingleNode("ResponseTypes").appendChild(GetResponseTypeDataForResponseTypeID(ResponseTypeID, NoteTypeID));
			}
			if (RequestType != null)
			{
				var Response = NoteTypeDoc.createNode(NODE_ELEMENT, "Response", "");
				Request.setAttribute("ResponseID", dbid);
				Request.setAttribute("Detail", Detail);
				Request.setAttribute("Enabled", Enabled == null ? "0" : Enabled);
				ResponseType.appendChild(Response);
			}
		}
	}
	return NoteTypeDoc;
}

/*
-----------------------------------------------------------------------------

										CONTROLS.JS
		
	Routines to provide support for dealing with user input.
	Combines InputMasking.js, DateControl.js, and monthview.js/asp into
	a single script to reduce complexity.
	
	Features:
	
		Input Masking:		All user input should be through masked input controls.
								Use the standard MaskInput() handler in the onKeyPress and
								onPaste events to implement this.
								(See Input Masking section)

		Date Handling:		Input/Output to all date controls should be through the DateControl
								class.  This provides an abstraction layer to ensure that all dates
								are handled in a consistent manner. (See DateControl section)
	
		Date Picker:		Each date control should consist of a masked text box and date picker
								button.  The button consists of a calendar image with an onclick handler
								that calls the CalendarShow() method. (See MonthView section)
		
		CanAcceptFocus()	Function which determines whether a control can have the focus set to it or not.
		
		RecordChanges()	Utility functions to check if the data in a control has changed.  Allows tabbing over
		Changed()			fields without firing events, if required.

	Examples:								
		HTML for masked input controls:

		Free entry text box/area:		
			<input type="text" maxlength="10" validchars="ANY" onKeyPress="MaskInput(this)" onPaste="MaskInput(this)" />
			<textarea id="" rows="3" maxlength="1024" validchars="ANY" onKeyPress="MaskInput(this);" onPaste="MaskInput(this);" ></textarea>

		Integer Entry box		
			<input type="text" maxlength="5" validchars="INTEGER" onKeyPress="MaskInput(this)" onPaste="MaskInput(this)" />

		Time Entry
			<input type="text" maxlength="5" validchars="TIME" onKeyPress="MaskInput(this)" onPaste="MaskInput(this)" />
			
		Date Entry
			<input id="myDate" class="MandatoryField" type="text" validchars="DATE:dd/mm/yyyy" onkeypress="MaskInput(this);" onpaste="MaskInput(this);" />
			<img src="../../../images/ocs/show-calendar.gif" onclick="CalendarShow(this, myDate);" class="linkImage">

			Reading the entered date from the above control:
				var objDateControl = new DateControl(myDate);
				var dtCurrent = objDateControl.GetDate();
				var strTDate = objDateControl.GetTDate();

			Writing a date to the above control:
				var objDateControl = new DateControl(myDate);
				var dtNow = new Date()
				var strTDate = '2004-06-01T11:00:00:000';
				objDateControl.SetDate(dtNow);
				objDateControl.SetTDate(strTdate);
		
		RecordChanges / Changed - suppressing onblur events if the user has just tabbed over a control
			<input id="mycontrol" onfocus="RecordChanges(this)" onblur="if(Changed(this)){return mycontrol_onblur}" />
			
			
------------------------------------------------------------------------------
	Modification History:
	26Jul04 AE  Combined scripts into Controls.js
	27Jul04 AE  DateControl; corrected a couple of fencepost errors (stupid zero-based months)
	30Sep04 AE  DateControl:InputStringValid; corrected bug which didn't recognise days over 30 in leap years as valid.
	19Oct04 AE  Monthview:Build URL from root so that we always find the stylesheet
	07Apr05 AE  CanAcceptFocus():	Written
	23Nov05 AE  Callendar Control: now uses inline styling instead of attached stylesheet.
					Required because some implementations host the ICW in a web control that doesn't support all
					the functions of IE,	just as we predicted.	
	21Mar06 AE  DateControl():  Corrected handling of js zero-based months
	30May08 AE  Added RecordChanges/Changed
	16Sep11 XN  Add ANYVALIDXML TFS 14097
/*
-----------------------------------------------------------------------------

										INPUT MASKING
		
	INPUT MASKING ROUTINES

	Currently supports masking of single and multi line text
	boxes with the following:

	NUMBERS: Only numbers and the '.' character allowed
	LETTERS: all letters, plus ' .,;:"?!£&-@%/\><[]{}()*#+=`$^_~|"' are allowed
 	ANY: characters from both NUMBERS and LETTERS are allowed.
 	ANYVALIDXML: same as ANY except without punctuation marks <>"& or '
 	DATE: Dates matching a specified date mask are allowed.
	TIME: a time matching HH:mm format is allowed.  24 hour clock is enforced (eg, 09:30 rather than 9:30)

------------------------------------------------------------------------------

	Usage:
	
		The input control to be masked must be either:
		an <Input type="text">
		or <textarea> element.
		
		The type of masking is specified using a custom attribute:
		
		validchars="sValidationToken"
		
		where sValidationToken is one of:
			INTEGER
			NUMBERS
			LETTERS
			ANY
			ANYVALIDXML
			DATE[:dateformat]
			TIME
			
		In the case of dates, dateformat is any combination of dd, mm, mmm, yyyy
		separated by one of the DATE_DELIMITERS (see below).  If dateformat is 
		not specified, the format specified in DATEMASK_DEFAULT is used.
		
		To perform masking, the function MaskInput should be called from the
		onKeyPress and onPaste handlers
		
		Example of a box masked to accept dates in dd/mmm/yyy format (eg '10/nov/2002')
		<input type="text" validchars="DATE:dd/mmm/yyyy" onKeyPress="MaskInput(this)" onPaste="MaskInput(this)" ></input>

	------------------------------------------------------------------------
	Modification History:
	18Nov02 AE  Written
	07Aug03 AE  MaskInput_Length: Written.  <textarea> elements do not support the 
					maxlength attribute, so this function replicates that functionality.
	29Oct03 DB  Added '@' as a valid character for support of email addresses
	30Oct03 DB  Added '%' as a valid character for support in product names
	04May04 AE  Added '/\><[]{}()*#+=' as valid punctuation
					Added Integer mask type
	03Jul09 XN  Added '`$^_~|\' as valid punctuation
-----------------------------------------------------------------------------
*/

//Input masking constants:
var VALID_INTEGER = '1234567890';
var VALID_NUMBERS = VALID_INTEGER + '.';							

var VALID_LETTERS = 'abcdefghijklmnopqrstuvwxyz';		//Note this is not case sensetive, ie 'A' is valid
var VALID_PUNCTUATION = ' .,;:"?!£&-@%/\\><[]{}()*#+=`$^_~|' + "'";
var VALID_XMLPUNCTUATION = ' .,;:?!£-@%/\\[]{}()*#+=`$^_~|';

//Dates
var DATE_DELIMITERS = './- '									//Allowed delimiters between day, month, year

//Deafult date mask.  dd, mm, mmm, yyyy in any order, separated by one of DATE_DELIMITERS
var DATEMASK_DEFAULT = 'dd/mm/yyyy'													

//Valid entries for mmm format.  Must be lower case.
var MONTHS_UK = 'jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec'		

//----------------------------------------------------------------------------------

function MaskInput(objInput) {

//Performs input masking.  Each control specifies the type
//of characters it allows, this routine blocks any disallowed ones.

//This is the only "public" function of the script. 

var strType = new String();

	//Get the type of the control
	var tagName = objInput.tagName;
	tagName = tagName.toLowerCase();

	switch (tagName) {
		case 'textarea':
			if (MaskInput_Length(objInput)) {												//Textarea does not support the maxlength property
				void MaskInput_TextBox(objInput);
			}
			break;
		
		case 'input':
			strType = objInput.getAttribute('type');
			strType = strType.toLowerCase();
		
			switch (strType) {
				case 'text':
					void MaskInput_TextBox(objInput);
					break;	
			
			}	
	}	

}

//---------------------------------------------------------------------------------
function MaskInput_TextBox(objTextArea)
{

	//Perform input masking on a textarea or text input element.
	//Also performs masking of incomming text from the clipboard (pasting).

	var incommingText = new String();
	var maskString = new String();
	var intCount = new Number();
	var thisCode = new Number();
	var maskExtra = new String();
	
	//read the type of masking required from the control
	var maskType = objTextArea.getAttribute('validchars')
	maskType = maskType.toLowerCase();

	//Date masks are specified after the type of 'date'
	if (maskType.indexOf(':') > -1)
	{
		maskExtra = maskType.substring(maskType.indexOf(':') + 1, maskType.length);
		maskType = maskType.substring(0, maskType.indexOf(':'));
	}
	
	// Get the insertion point
	var CurrentSelection = document.selection.createRange();
	var SelectionSize = CurrentSelection.text.length;
	CurrentSelection.moveStart('character', -objTextArea.value.length);
	var InsertPoint = CurrentSelection.text.length - SelectionSize;

	//Build a string of valid characters
	switch (maskType)
	{
		case 'integer': 																				//04May04 AE  Added
			maskString = VALID_INTEGER;
			break; 																						//02Jun04 AE  Fix:  Added missing break

		case 'signedinteger':
			maskString = VALID_INTEGER;
			if (event.type =='keypress' && InsertPoint == 0)
			{
				maskString = "+-" + maskString;
			}
			break;

		case 'numbers':
			maskString = VALID_NUMBERS;
			//Make sure that they only enter one "."

			//21Aug2009 JMei Only allow 3 decimals for numbers
			if (objTextArea.value.indexOf('.') > -1)
			{
				if (objTextArea.value.split('.')[1].length > 2)
				{
					event.returnValue = false;
					return;
				}
				maskString = maskString.split('.').join(''); 		//Removes the '.'					
			}
			break;

		case 'letters':
			maskString = VALID_LETTERS.toLowerCase() + VALID_LETTERS.toUpperCase() + VALID_PUNCTUATION;
			break

		case 'any':
			maskString = VALID_LETTERS.toLowerCase() + VALID_NUMBERS + VALID_LETTERS.toUpperCase() + VALID_PUNCTUATION;
			break;
			
        case 'anyvalidxml':			
			maskString = VALID_LETTERS.toLowerCase() + VALID_NUMBERS + VALID_LETTERS.toUpperCase() + VALID_XMLPUNCTUATION;
			break;

		case 'date':
			if (maskExtra == '')
			{
				maskExtra = DATEMASK_DEFAULT;
			}
			maskString = NextDateCharacters(objTextArea.value, maskExtra);
			break;

		case 'time':
			maskString = NextTimeCharacters(objTextArea.value);
			break;

		default:
			maskString = maskType  //TH Changed - was ''
			break;
	}

	//now check the input.
	switch (event.type)
	{
		case 'keypress':
			//Get the entered value
			thisCode = event.keyCode;

			if (thisCode != 13 && thisCode != 27 && thisCode != 9)
			{						//Ignore control keys
				incommingText = String.fromCharCode(thisCode);
				//Check the single character against the list of valid ones.
				if (maskString.indexOf(incommingText) < 0)
				{
					//Character not allowed.
					event.returnValue = false;
				}
			}
			break;

		case 'paste':
			//Get the incomming string
			incommingText = window.clipboardData.getData('Text');

			// Check that length doesnt exceed maxlength
			if (Number(objTextArea.getAttribute("maxlength")) > 0
				&& (incommingText.length + objTextArea.value.length - SelectionSize) > Number(objTextArea.getAttribute("maxlength"))
			   )
			{
				event.returnValue = false;
			}
			else
			{
				//Check the whole incomming string against the valid chars.		
				for (intCount = 0; intCount < incommingText.length; intCount++)
				{
					var thisMask = maskString;
					if (maskType == 'signedinteger' && InsertPoint == 0 && intCount == 0)
					{
						thisMask = '+-' + thisMask;
					}
					if (thisMask.indexOf(incommingText.charAt(intCount)) < 0)
					{
						//Character not allowed; block the whole string.
						event.returnValue = false;
						break;
					}
				}
			}
			break;
	}
}

//--------------------------------------------------------------------------------------------------------

function NextDateCharacters(textString, dateMask) {

//For date fields, we return the next valid characters
//given the current textString in the field.

//The format allowed is specified in dateMask.
//Any combination of dd, mm, mmm, yyyy is allowed

//	textString: Characters already entered by the user
//	dateMask: string specifying the date mask to validate against.
	
//	returns: string containing all valid characters
	

var strMaskChars = new String();
var strReturn = new String();
var intCount = new Number();
var previousCharacters = new String();
var astrMask = new Array();
var astrText = new Array();

	//Replace delimiters with '/' so we can use it throughout
	for (intCount=0; intCount < DATE_DELIMITERS.length; intCount++ ) {
		dateMask = ReplaceString(dateMask, DATE_DELIMITERS.charAt(intCount),'/' );
		textString = ReplaceString(textString, DATE_DELIMITERS.charAt(intCount),'/' );
	}

	//Now split into arrays.  We then match the field the user
	//is currently entering with the appropriate field in the
	//mask (since dd can be entered as '01' or simply '1', for eg, 
	//we cannot simply go by character position)
	astrMask = dateMask.split('/');
	astrText = textString.split('/');

	//Determine where abouts in the Date Mask they are.
	//Do this by working out which field they are on based
	//on the number of delimiters in textString.
	strMaskChars = astrMask[astrText.length - 1];

    // if characters exist beyond mask take last characters
    if(strMaskChars==null)
    {
	    strMaskChars = astrMask[astrMask.length - 1];    
    }
    //Now get the valid chars based on the field and what they've already typed.
    if (textString.length > 0) {
	    previousCharacters = astrText[astrText.length - 1];
    }

    switch (strMaskChars.charAt(0).toLowerCase()) {
	    case 'd':
		    strReturn = GetNextDayChars(previousCharacters, strMaskChars);			
		    break;
			
	    case 'm':
		    strReturn = GetNextMonthChars(previousCharacters, strMaskChars);	
		    break;
			
	    case 'y':
		    strReturn = GetNextYearChars(previousCharacters, strMaskChars);
		    break;
		
    }
    
    return strReturn;
	
	
}

//-----------------------------------------------------------------------------------------

function GetNextDayChars(textString, dateMask) {

//Returns the next valid characters which can be 
//entered for a 2-number day field

//	textString: Day characters already entered by the user
//	dateMask: string specifying the date mask to validate against.
//	intLastDelimiter: position in textString of the last field delimiter (ie, the start of this field)
	
//	returns: string containing all valid characters
	
var strTemp = new String();
var strReturn = new String();
	
	switch (textString.length) {
		case 1: 
			//This is the second 'd'
			//Check what the first one holds.
			strTemp = textString.charAt(0);
			
			if (eval(strTemp) == 3 ) {
				//Can only allow 0 or 1;
				strReturn = '01' + DATE_DELIMITERS;
			}
			
			if ( (eval(strTemp)==0) ) {
				//If a zero was entered, the next character must
				//be a non-zero number
				strReturn = '123456789'
			}
			
			if ( (eval(strTemp) < 3) && (eval(strTemp) >0) ) {
				//Allow anything;
				strReturn = '0123456789' + DATE_DELIMITERS;
			}
			
			if ( eval(strTemp) > 3) {
				//Entered 4-9, only delimiters allowed now
				strReturn = DATE_DELIMITERS;
			}
			break;
		
		case 2:
			//Entered two characters, only delimiters allowed
			strReturn = DATE_DELIMITERS;
			break;
			
		default:
			//This is the first 'd'
			strReturn = '1234567890';
			break;
	}

	return strReturn;

}

//------------------------------------------------------------------------------------------

function GetNextMonthChars(textString, dateMask) {
	
//Determine which characters they can enter into the month field, 
//based on the dateMask and the text they've already entered.
	
//	textString: Month characters already entered by the user
//	dateMask: string specifying the date mask to validate against.
//	intLastDelimiter: position in textString of the last field delimiter (ie, the start of this field)
	
//	returns: string containing all valid characters
	
var strReturn = new String();
var intCount = new Number();
var intNumber = new Number();

	//Now determine the allowed characters

	switch (textString.length) {
		case 0:
			//this is the first m.  
			switch (dateMask.length) {
				case 3: 															//'mmm'
					strReturn = GetMonthChars(textString);
					break;
	
				case 2: 															//'mm'
					strReturn = GetMonthDigits(textString);
					break;
			}
			break;
			
		case 1:
			//Second m.
			switch (dateMask.length) {
				case 3: 															//'mmm'
					strReturn = GetMonthChars(textString);
					break;

				case 2: 															//'mm'
					strReturn = GetMonthDigits(textString);
					break;
			}			
			break;
			
		case 2:
			//third m, or delimter.
			switch (dateMask.length) {
				case 3: 															//'mmm'
					strReturn = GetMonthChars(textString);
					break;

				case 2: 															//'mm/'
					strReturn = DATE_DELIMITERS;
					break;
			}			
			break;
			
		case 3:
			//fourth m.  Must be a text entry
			strReturn = GetMonthChars(textString);
			break;
		
	}
						
	return strReturn;
			
}



//-----------------------------------------------------------------------------------------

function GetMonthDigits(previousCharacters) {

//Get a list of the possible digits which can
//be entered to make a valid date, based on 
//what has already been entered.

//returns: string containing all possible valid digits.

var strReturn = new String();
var strTemp = new String();

	if (previousCharacters.length==0) {
		//This is the first character
		strReturn = '0123456789';
	}
	else {
		//Second number.
		//Get the first number they entered.
		strTemp = previousCharacters.charAt(0);

		switch (strTemp) {
			case '1':
				//Already entered a 1, can only have 10, 11 or 12
				strReturn = '012' + DATE_DELIMITERS;		
				break;
			
			case '0':
				//First number was 0, so allow 01-09
				strReturn ='123456789';
				break;
				
			default:
				//Already entered a number > 1, so they must be entering
				//a single-digit month.  Next char must be a delimiter
				strReturn = DATE_DELIMITERS;
				break;
		}
	}	
	
	return strReturn;
	
}


//-----------------------------------------------------------------------------------------

function GetMonthChars(previousCharacters) {

//Get a list of possible characters given the ones
//already entered.

//Returns: string containing all possible valid chars, in lower case.
	
var astrMonths = new Array(12);
var astrValidMonths = new Array(0);
var intCount = new Number();
var intChar = new Number();
var intValidCount = new Number(0);
var blnValid = new Boolean();
var strReturn = new String();

	astrMonths = MONTHS_UK.split(',');
	previousCharacters = previousCharacters.toLowerCase();

	if (previousCharacters.length < 3) {
		//Determine which months apply based on what they've entered		
		for (intCount=0; intCount < 12; intCount++) {
			//Check previousCharacters against each month, record
			//which ones match in astrValidMonths. 
			blnValid=true;
			if (previousCharacters.length > 0) {
				for (intChar=0; intChar<previousCharacters.length; intChar++) {
					if (previousCharacters.charAt(intChar) != astrMonths[intCount].charAt(intChar) ) {
						blnValid=false;
						break;	
					}
				}
			}
			
			if (blnValid) {
				//Match found, add this month to astrValidMonths
				intValidCount++;
				astrValidMonths[intValidCount]=astrMonths[intCount];
			}
			
		}
		
		//Now return a list of all valid characters for the 
		//valid months, at the next position.	
		for (intCount=1; intCount <= intValidCount; intCount++) {
			strReturn += astrValidMonths[intCount].charAt(previousCharacters.length);
		}
	}
	else {
		//They've already entered 3 valid characters, the next must
		//be a delimiter
		strReturn = DATE_DELIMITERS;
	}

	return strReturn;

}

//------------------------------------------------------------------------------------

function GetNextYearChars(previousChars, dateMask) {	
	
//Determine which characters they can enter into the year field, 
//based on the dateMask and the text they've already entered.
	
//	textString: Year characters already entered by the user
//	dateMask: string specifying the date mask to validate against.
//	intLastDelimiter: position in textString of the last field delimiter (ie, the start of this field)
	
//	returns: string containing all valid characters
	
var strReturn = new String();
	
	switch (previousChars.length) {	
		case 0:
			strReturn='123';									//Note: to prevent year 2.4k bug, add 3 to this string...
			break;
			
		default:
			strReturn = '0123456789';
			break;
			
	}

	return strReturn;
	
}


//-----------------------------------------------------------------------------------

function NextTimeCharacters(previousChars) {

//Determine which characters they can enter into the year field, 
//based on the text they've already entered	

//	previousChars: text already entered by the user
//	returns: String containing all valid characters.

var strReturn = new String();

	switch (previousChars.length) {
		case 0:	
			//This is the first character
			strReturn = '120';
			break;
			
		case 1:	
			//This is the second character
			if (previousChars.charAt(0) == '2') {
				strReturn = '0123';
			}
			else {
				strReturn = '0123456789';
			}
			break;
			
		case 2:
			//Colon
			strReturn = ':';
			break;
			
		case 3:
			//first minute character.
			strReturn = '012345';
			break;
			
		case 4:
			//Second minute character.
			strReturn = '0123456789';
			break;		
	}
			
	return strReturn	
	
}

//------------------------------------------------------------------------------------------------------

function MaskInput_Length(objTextarea) {

//07Aug03 AE  	MaskInput_Length: Written.  <textarea> elements do not support the 
//					maxlength attribute, so this function replicates that functionality.
//10Dec03 AE   Now ignores maxlength if <= 0


var blnReturn = true;

	var maxLength = objTextarea.getAttribute('maxlength');
	if (maxLength == null) {maxLength = 0;}
	
	if (maxLength > 0) {
		var textLength = objTextarea.value.length;
		
		if (eval(textLength) >= eval(maxLength)) {
			//We're already at the max length; block the incomming event.	
			event.returnValue = false;
			blnReturn = false;
		}
	}
	return blnReturn;
}







//------------------------------------------------------------------------------------------------------------
//										DateControl Class Script
//
//	Use to wrapper a date input control and provide abstracted input-output routines.
//	Use this for ALL date entry / reading from the client.
//
//	Requires DateLibs.js
//
//	Useage:
//		//Create the DateControl class from a date-masked input element:
//		var objDateControl = new DateControl(htmlInputElement);	
//		
//		objDateControl.IsBlank()									-- Returns Boolean.  Indicates whether the control contains
//																				no characters.
//		objDateControl.ContainsValidDate()						-- Returns Boolean.  Indicates whether the control 
//																				contains a valid date.
//		objDateControl.GetTDate()									-- Returns a T Date string (ccyy-mm-ddT00:00:000)
//																				as defined by the input into the control.  If the control
//																				does not contain a valid date, an empty string is returned.
//		objDateControl.GetDate()									-- Returns a js Date object as defined by the input in the 33
//																				control. If the control does not contain a valid
//																				date, the method returns null
//		objDateControl.SetTDate()									--	Sets the value in the control to the specified T date string.
//																				The control will display the date in the format specified
//																				by the control's validchars attribute.
//		objDateControl.SetDate()									--	Sets the value in the control to the value of the 
//																				specified js date object. The control will display 
//																				the date in the format specified by the control's validchars attribute.
//		objDateControl.Blank()										--	Blanks the value in the control.
//
//	Modification History:
//	22Jul04 AE  Written
//
//------------------------------------------------------------------------------------------------------------
function DateControl(htmlInputElement){

//Check that we have an html Input element
var blnFail = false;
var strMask = new String();
var strDateFormat = new String();
var strDelimiter = new String();
var intCount = new Number();
var DATEFORMAT_DEFAULT = 'dd/mm/ccyy';
var DATE_DELIMITERS = './- ';

	try {
		blnFail = (htmlInputElement.tagName.toLowerCase() != 'input') 
	}
	catch (err) {
		blnFail = true;
	}

	if (!blnFail) {
	//Construct the object
		//Check that it is a date masked input box
		strMask = htmlInputElement.getAttribute('validchars');
		if (strMask.indexOf('DATE:') > -1) {
		//Extract the actual date mask, eg dd/mm/yyyy
			strMask = strMask.substring(strMask.indexOf(':') + 1, strMask.length);
			if (strMask == '') {strMask = DATEFORMAT_DEFAULT};
			
			//if (InputValid (strMask) )
			
					
				//Search for a delimiter; this is one of DateDelimiters
					for (intCount=0; intCount < DATE_DELIMITERS.length; intCount++) {
						if (strMask.indexOf(DATE_DELIMITERS.charAt(intCount)) > -1) {
							//Found a delimiter
							strDelimiter = DATE_DELIMITERS.charAt(intCount);
							break;
						}						
					}
					
				//===========================================================================
				//Object Interface definition
					this.HTMLElement = htmlInputElement;
					this.DateMask = strMask.toLowerCase();			
					this.Delimiter = strDelimiter;
					
					this.ContainsValidDate = InputStringValid;
					this.IsBlank = InputIsBlank;
					this.GetTDate = InputToTDateString;
					this.GetDate = InputToDate;
					this.SetTDate = TDateStringToInput;
					this.SetDate = DateToInput;
					this.Blank = BlankControl;
					
					//Internally - used methods
					this.GetDays = GetDays;
					this.GetMonths = GetMonths;
					this.GetYears = GetYears;
					this.GetValueFromMaskPosition = GetValueFromMaskPosition;
					this.DatePartsToInput = DatePartsToInput
					
					this.GetRawValue = htmlInputElement.value;
				//===========================================================================	
		}
		else {
		//No date mask specified	
			alert('DateControl objects can only be constructed from elements with a validchars="DATE:" attribute.');
		}
	}
	else {
		//Failed, sucka.
		alert('DateControl objects can only be constructed from HTML <input>	element references');
	}

}

//------------------------------------------------------------------------------------------------------------
//										Internal Workings
//------------------------------------------------------------------------------------------------------------
function InputIsBlank() {

//returns true if the control is empty	
	var strValue = this.GetRawValue;
	return (strValue.split(' ').join('') == '');
}
//------------------------------------------------------------------------------------------------------------
function InputStringValid() {

//Determines if the date currently entered in the control is valid, 
//and returns true or false.
var intDaysInMonth = new Number();

	var intDay = Number(this.GetDays());
	var intMonth = Number(this.GetMonths());
	var intYear = Number(this.GetYears());

	if (intDay == NaN) {intDay = 0};
	if (intMonth == NaN) {intMonth = 0};
	if (intYear == NaN) {intYear = 0};

	return DateValid(intYear, intMonth, intDay);
}

//------------------------------------------------------------------------------------------------------------
function DateValid(intYear, intMonth, intDay) {

//Determines if the specified year, month and day form a valid date.

    var blnValid = true;

    if (intYear < EARLIEST_YEAR) { blnValid = false };

    if (intYear > LATEST_YEAR) { blnValid = false };
	
	if (intMonth < 1 || intMonth > 12) {blnValid = false};
	if (intDay < 1) {blnValid = false};

	if (blnValid) {
	//Check that the correct number of days for this month are entered.
		intDaysInMonth = DaysInMonth(intMonth.toString());		
		if (IsLeapYear(intYear) && intMonth == 2) {intDaysInMonth = 29};									//30Sep04 AE  Changed OR in "if feburary OR a leap year then daysinmonth=29" to AND.  Ooops.
		if (intDay > intDaysInMonth) {blnValid = false};
	}
	
	return blnValid;
}

//------------------------------------------------------------------------------------------------------------
function InputToTDateString() {
//Convert what's in the box to a TDate string.  Returns an empty string if the
//entered date is incomplete or otherwise not valid.
	if (this.ContainsValidDate()) {
		return (this.GetYears() + '-' + this.GetMonths() + '-' + this.GetDays() + 'T00:00:00');
	}
	else {
		return '';
	}
}

//------------------------------------------------------------------------------------------------------------
function InputToDate() {
//Convert what's in the box to a TDate string
	if (this.ContainsValidDate()) {	
		return new Date(Number(this.GetYears()), Number(this.GetMonths() -1), Number(this.GetDays()));
	}
	else {
		return null;
	}
}

//------------------------------------------------------------------------------------------------------------
function BlankControl() {
//Blank the value in the control
	this.HTMLElement.value = '';	
}
//------------------------------------------------------------------------------------------------------------
function TDateStringToInput(strTDate) {

//Enter the given string into the input box.
//returns true if succesful, false if the supplied date was invalid	
//Tdate format is ccyy-mm-ddThh:nn:ss:fff.  All time information (after
//the 'T') is ignored here.
	
var blnValid = true;

	try {
		var strYear = strTDate.substring(0, 4);
		var strMonth = Number(strTDate.substring(5, 7));						//21Mar06 AE  DateValid actually uses real months removed -1.		//13Aug04 AE  Deal with JS funny zero-based months
		var strDay = strTDate.substring(8, 10);									//23Aug04 AE  Corrected substring

		if (strYear == '') {strYear = 0};
		if (strMonth == '') {strMonth = 0};
		if (strDay == '') {strDay = 0};
		
		var intYear = Number(strYear);
		var intMonth = Number(strMonth);
		var intDay = Number(strDay);
	}
	catch (err) {
		blnValid = false;
	}

	if (blnValid) {blnValid = DateValid	(intYear, intMonth, intDay)};
	if (blnValid) {
	//We have a valid date, enter it into the input box in the format specified.
		this.DatePartsToInput(intYear, intMonth, intDay);
	}

	return blnValid;
}

//------------------------------------------------------------------------------------------------------------
function DateToInput(objDate) {

//Enter the given js date object into the input box in the format specified
//in the input box's DateMask.
//Returns true if the operation was succesful, false otherwise
var blnSuccess = true;

	try {
		var intYear = objDate.getFullYear();
		var intMonth = objDate.getMonth() + 1;																							//21Mar06 AE  Deal with js dates here
		var intDay = objDate.getDate();
		this.DatePartsToInput(intYear, intMonth, intDay);
	}
	catch (err) {
		blnSuccess = false;
	}
	
	return blnSuccess

}

//------------------------------------------------------------------------------------------------------------
function DatePartsToInput(intYear, intMonth, intDay) {

//Enters the specified date into the input box in the format
//specified by the box's input mask.
var strDay = new String();
var strMonth = new String();
var strYear = new String();
	
	var strOut = this.DateMask;
	
	//Format days to two digits
	strDay = intDay.toString();
	if (strDay.length == 1) {strDay = '0' + strDay};
	strOut = strOut.split('dd').join(strDay);							//dd		->		intDay							//06Aug04 AE  Corrected, to always show 2 digit days
	
	//Format month to the required format
//	intMonth ++																															//21Mar06 AE  Moved handling of js dates up into DateToInput//Stupid js dates start at 0
	if (strOut.indexOf('mmm') > -1) {
	//3-letter month
		strMonth = MonthNameFromNumber(intMonth, true);
		strOut = strOut.split('mmm').join(strMonth);					//mmm 	->		jan, feb etc
	}
	
	if (strOut.indexOf('mm') > -1) {
	//2 - digit month	
		strMonth = intMonth.toString();
		if (strMonth.length == 1){strMonth = '0' + strMonth};	
		strOut = strOut.split('mm').join(strMonth);					//mm		->		intMonth
	}
	
	//And the year
	strYear = intYear.toString();
	strOut = strOut.split('ccyy').join(strYear);						//ccyy	->		intYear
	strOut = strOut.split('yyyy').join(strYear);						//yyyy	->		intYear

	this.HTMLElement.value = strOut;

}

//------------------------------------------------------------------------------------------------------------
function GetDays() {

//Returns the days (in 2 digit form) which are currently entered in the control,
//or an empty string if no days are entered yet.
	var strDays = this.GetValueFromMaskPosition('dd');
	if (strDays.length == 1) {strDays = '0' + strDays};
	return strDays;
}

//------------------------------------------------------------------------------------------------------------

function GetMonths() {

//Returns the month (in 2 digit form) which is currently entered in the control,
//or an empty string if no month are entered yet.

	var strMonths = this.GetValueFromMaskPosition('mm');
	if (strMonths == '') {
		strMonths = this.GetValueFromMaskPosition('mmm');
		if (strMonths != '') {
			//we have a 3-letter month, convert it to a numerical one
			strMonths = MonthNumberFromName(strMonths).toString();
		}
	}
	else
	{
		if (strMonths.length == 1){strMonths = '0' + strMonths};
	}
	
	return strMonths;
}

//------------------------------------------------------------------------------------------------------------

function GetYears() {

//Returns the year (in numerical form) which is currently entered in the control,
//or an empty string if no month are entered yet.
	var strYears = this.GetValueFromMaskPosition('yyyy');		
	if (strYears == '') {
		strYears = this.GetValueFromMaskPosition('ccyy');	
	}
	return strYears;
}

//------------------------------------------------------------------------------------------------------------
function GetValueFromMaskPosition(strMask) {

//Given a part of the mask (for example, 'dd', or 'ccyy'), returns
//the string in the control matching that part of the mask.
//So GetValueFromMaskPosition('dd') will return the days that have
//been entered in the control.
//Returns an empty string if the requested data has not yet been entered.

var intCount = new Number();
var intIndex = new Number(-1);
var strReturn = new String();

	//First find the index position of the days in the mask string
	var astrMask = this.DateMask.split(this.Delimiter);
	
	for (intCount = 0; intCount < astrMask.length; intCount ++){
		if (astrMask[intCount] == strMask) {
			intIndex = intCount;			
			break;	
		}
	}
	
	//Now find the corresponding input from the string in the control
	if (intIndex > -1) {
		var astrInput = this.GetRawValue.split(this.Delimiter);
		strReturn = astrInput[intIndex];
	}
			
	//And return it
	if (strReturn == undefined) {strReturn = ''};
	return strReturn;
	
}


//============================================================================================================
//
//																MonthView
//
//	A pop-up calendar used to pick a date.
//
//	Useage:
//
//		CalendarShow(objSrc, htmlInputElement)							
//
//		Use this call typically in an onclick handler to display a pop-up calendar.
//		objSrc:		Used for positioning; the popup is displayed level with the top of this object, 
//						and 20px to the right of its left-hand edge.  This will normally be the small 
//						calendar icon.
//
//		htmlInputElement:	This is a date-masked input box.  
//
//	Modification History:
//	23Jul04 AE  Written.  Replaces old month view with a fully client side version.
//					No need for hidden frames, only one script, and less than half the 
//					lines of code.
//	23Nov05 AE  Removed proper, nice, attached stylesheet, and replaced with nasty verbose inline styles.
//					Required because some implementations host the ICW in a web control that doesn't support all
//					the functions of IE,	just as we predicted.
//
//============================================================================================================

var MVCAL_WIDTH = 175;																	//Width of the pop-up
var MVCAL_HEIGHT = 195;																	//Height of the pop-up

var m_objPop;																				//Reference to the popup
var m_objSrc;																				//Reference to the object we are showing the popup relative to
var m_objDateControl;																	//Reference to a DateControl class wrappering the input box we are entering a date for
var m_dtDateInControl;

//============================================================================================================
//									Pop-up Construction and Display
//============================================================================================================
function CalendarShow(objSrc, htmlInputElement)
{
	//Show a popup calendar.  
	//objControl contains a reference to an HTML <input> element which is date-masked
	//(ie, has a validchars attribute of "DATE:")
	//The calendar defaults to show the date in the control, if a valid date exists;
	//otherwise, it defaults to TODAY.
	//The selected date is written back to objControl.  If the user does not select
	//a date, the value in objControl is left unchanged.

    m_objDateControl = new DateControl(htmlInputElement);

    var dtCurrent = null;
    if (m_objDateControl.IsBlank() == false) {
        dtCurrent = m_objDateControl.GetDate();
    }

	if (dtCurrent == null)
	{
		//No valid date in the control, default to today.
		dtCurrent = new Date();
	}
	else
	{
		m_dtDateInControl = dtCurrent;
	}

	//Build the pop-up
	m_objSrc = objSrc;
	m_objPop = window.createPopup();

	//Obtain a path to the style folder
	//	var strURL = document.URL;
	//	strURL = strURL.substring(0, strURL.indexOf('application')) + 'style/monthview.css';						//19Oct04 AE  Build URL from root so that we always find the stylesheet
	//	m_objPop.document.createStyleSheet (strURL);
	MV_BuildCalendarInfrastructure(m_objPop, dtCurrent);
	MV_PopulateMonth(m_objPop.document.body.all['tdMonth'], dtCurrent);
	m_objPop.show(20, 0, MVCAL_WIDTH, MVCAL_HEIGHT, objSrc);
}

//===========================================================================
function MV_BuildCalendarInfrastructure(objPop, dtCurrent) {

//Builds the framework of the calendar, into which different months
//can be shown

	strHTML = '<div style="height:100%;border:#808080 2 solid;">'
			   + '<table cellpadding="0" cellspacing="0" style="font-family:arial;font-size:8pt;width:100%">'
				+ '<tr class="DropDownRows"><td align="center">'
				+ MV_BuildMonthDropDown(dtCurrent)
				+ '</td><td align="center" >'
				+ MV_BuildYearDropDown(dtCurrent)
				+ '</td></tr>'
				+ '<tr>'
				+ '<td id="tdMonth" colspan="2">'
				+ '</td></tr>'
				+ '<tr>';
					
	//Build the "today" link
	var dtNow = new Date()
	strHTML += '<td colspan="2" style="text-align:center">'
				+ '<span onclick="parent.MV_Select(' + dtNow.getFullYear() + ',' + dtNow.getMonth() + ',' + dtNow.getDate() + ');" '
				+ 'style="text-decoration:underline;cursor:hand">Today</span>'
				+ '</td></tr>'
				+ '</table></div>';

	objPop.document.body.innerHTML = strHTML;
}

//===========================================================================
function MV_BuildMonthDropDown(dtDate){

	var strReturn = '<select id="lstMonths" onchange="parent.MV_MonthChange()" style="font-weight:bold;font-size:7pt;background-color:#c0c0c0;">';
	for (intCount = 0; intCount < 12; intCount++) {
		strReturn += '<option value="' + intCount + '" '
		if (intCount == dtDate.getMonth()) {strReturn += ' selected '};
		strReturn += '>' + MonthNameFromNumber(intCount) + '</option>';
	}
	strReturn += '</select>';			
	return strReturn;
}

//16-Jan-2008 JA Error code 162
////===========================================================================
//function MV_BuildYearDropDown(dtDate){

////Show a list of years from this year - 2 up to this year + 2

//	var intYear = dtDate.getFullYear();

//	var strReturn = '<select id="lstYears" onchange="parent.MV_MonthChange()" style="font-weight:bold;font-size:7pt;background-color:#c0c0c0;">';
//	
//	for (intCount = (intYear - 10); intCount < (intYear + 13); intCount++) {
//		strReturn += '<option';
//		if (intCount == intYear) {strReturn += ' selected '};
//		strReturn += '>' + intCount + '</option>';
//	}
//	strReturn += '</select>';			
//	return strReturn;

//}
function MV_BuildYearDropDown(dtDate){

//Show a list of years from this year - 2 up to this year + 2

	var intYear = dtDate.getFullYear();

    var strHTML = '';
    strHTML += '<button id="btnMVYearMinus" onclick="lblYear.innerText=Number(lblYear.innerText)-1;parent.MV_MonthChange();" style="height:16px"><div style="margin-top:-4">-</div></button>';
    strHTML += '<label id="lblYear" style="padding:2px;border:gray 1px solid">' + intYear + '</label>';
    strHTML += '<button id="btnMVYearPlus" onclick="lblYear.innerText=Number(lblYear.innerText)+1;parent.MV_MonthChange();" style="height:16px"><div style="margin-top:-4">+</div></button>';
	return strHTML;
}

//===========================================================================
function MV_PopulateMonth(objContainer, dtDate){

//Build a single month calendar for the month specified in dtDate.
//(This is the procedure which builds all of the dates into the table)

var intDay = new Number();
var intRow = new Number();

//Build the header with the day abbreviations along the top
	var strHTML = '<table cellpadding="2" cellspacing="0" align="center" style="font-family:arial;font-size:8pt;border-bottom:#808080 1 solid;margin-bottom:2px;width:100%;">'
					+ '<tr style="font-weight:bold;">'
					+ '<td align="center" style="width:12px;border-bottom:#808080 1 solid;">S</td><td align="center" style="width:12px;border-bottom:#808080 1 solid;">M</td>'
					+ '<td align="center" style="width:12px;border-bottom:#808080 1 solid;">T</td><td align="center" style="width:12px;border-bottom:#808080 1 solid;">W</td>'
					+ '<td align="center" style="width:12px;border-bottom:#808080 1 solid;">T</td><td align="center" style="width:12px;border-bottom:#808080 1 solid;">F</td>'
					+ '<td align="center" style="width:12px;border-bottom:#808080 1 solid;">S</td>'
					+ '</tr>';
					
//Now populate rows for the days in the month, in 6 rows.
	//First, obtain the sunday of the week that the first day of this month falls on.
	var dtDay = new Date(dtDate.getFullYear(), dtDate.getMonth(), 1);			//This holds the first day of the current month
	intFirstDayOfMonth = dtDay.getDay();												//This is the day of the week of the first day (0=sun, 1=mon etc)
	dtDay.setDate(1 - intFirstDayOfMonth);												//This holds the sunday of the week in which the first day of the month falls (which may be in the previous month)

	//Get today's date for comparison.  We are only comparing down to
	//the day level, so we need to set the hours, minutes etc to zero
	var dtToday = new Date();	
	dtToday.setHours(0);
	dtToday.setMinutes(0);
	dtToday.setSeconds(0);
	dtToday.setMilliseconds(0);

	for (intRow = 0; intRow < 6; intRow++) {
		strHTML += '<tr >';
		for (intDay = 0; intDay < 7; intDay++) {
			strHTML += '<td align="center" style="width:12px;cursor:hand;';
			
			//Add a class so that we can highlight days in the selected month
			if (dtDay.getMonth() == dtDate.getMonth()) {
				strHTML += '';
			}
			else {
				strHTML += 'color:#808080;';
			}
			//Add a class if this is today
			if (dtDay.valueOf() == dtToday.valueOf()) {				
				strHTML += 'border:#ff0000 2 solid;';					
			}
			//And another to indicate the selected day (if any)
			if (m_dtDateInControl != undefined && dtDay.valueOf() == m_dtDateInControl.valueOf()) {				
				strHTML += 'background-color:#c0c0c0;';					
			}
			
			//Add the onclick event handler
			strHTML += '" onclick="parent.MV_Select(' + dtDay.getFullYear() + ',' + dtDay.getMonth() + ',' + dtDay.getDate() + ');" '			
					   + '>' + dtDay.getDate() + '</td>';
			dtDay.setDate(dtDay.getDate() + 1);
		}
		strHTML += '</tr>';
	}

	strHTML += '</table>';
	objContainer.innerHTML = strHTML;
}
//============================================================================================================
//											Event Handling
//============================================================================================================

function MV_Select(intYear, intMonth, intDay)
{
	//Catches clicks on a day on the calendar.  Enter the selected
	//date into the DateControl
	var dtNew = new Date(intYear, intMonth, intDay);
	m_objDateControl.SetDate(dtNew);
	void m_objPop.hide();

	try
	{
		//Raise an event to indicate that we've selected a date
		void MonthView_Selected(m_objDateControl.HTMLElement.id);
	}
	catch (err) { };
}
//============================================================================================================
function MV_MonthChange()
{
	//Fires when a new month is chosen.  We reconstruct the dates and
	//redisplay the popup
	var objMonths = m_objPop.document.body.all['lstMonths'];
	//var objYears = m_objPop.document.body.all['lstYears']; 16-Jan-2008 JA Error code 162
	var objYear = m_objPop.document.body.all['lblYear'];
	var intMonth = objMonths.options[objMonths.selectedIndex].value;
	//var intYear = Number(objYears.options[objYears.selectedIndex].innerText); 16-Jan-2008 JA Error code 162
	var intYear = Number(objYear.innerText);

	var dtNewMonth = new Date(intYear, intMonth, 1);
	MV_PopulateMonth(m_objPop.document.body.all['tdMonth'], dtNewMonth);
	// F0049597 31-03-09 PR Calendar control doing strange things when selectinga date after a month change
	//						Hiding before showing updated control seems to fix this.
	m_objPop.hide();
	m_objPop.show(20, 0, MVCAL_WIDTH, MVCAL_HEIGHT, m_objSrc);
}

//===========================================================================
//								Miscellaneaous functions
//===========================================================================
function CanAcceptFocus(objControl){
	
//Returns true if this control can have the focus set to it.
//We check whether it's disabled and whether it is hidden (which may
//be specified by a style on an element several levels up in the DOM)

//07Apr05 AE  written	
	
var objElement;
	
//Check the simple things:
	if (typeof(objControl) == 'undefined') return false;
	if (objControl.disabled) return false;
	if (objControl.isDisabled) return false;
	if (Number(objControl.tabIndex) < 0) return false;
	
//Check the control type:
	switch (objControl.tagName.toLowerCase()){
		//List o' control types we can focus on 
		case 'input':
		case 'textarea':
		case 'button':
		case 'select':
		case 'a':
			break;
		
	
		default:
		//Anything else is a no-go
			return false;	
	}

//Now check the visibility and display styles of the control and its parents
	objElement = objControl;
	do {
		if (objElement.currentStyle.display == 'none') return false;
		if (objElement.currentStyle.visibility == 'hidden') return false;
		
		objElement = objElement.parentElement;	
	}
	while (objElement.tagName.toLowerCase() != 'body');

	return true;
}

//===========================================================================
//								Legacy support
//===========================================================================
function ShowMonthViewWithDate(objSrc, objForDateOutput,strDisplayDate) {

//DO NOT USE THIS METHOD for new code; it exists only for backwards-compatability.
	return CalendarShow(objSrc, objForDateOutput)
}
//===========================================================================


//===========================================================================
//								Utility Functions
//===========================================================================

//27May08 AE  Utility functions to allow us to check if a field has changed.  Used to
//				  prevent event cascades when just tabbing over fields.
//
//					Useage:
//							<input id="mycontrol" onfocus="RecordChanges(this)" onblur="if(Changed(this)){return mycontrol_onblur}" />
//
var CONTROLSJS_CHANGEDATTRIBUTE = '_value_original';

function RecordChanges(objInput){
	switch (objInput.tagName.toLowerCase()){
		case 'input':
			objInput.setAttribute(CONTROLSJS_CHANGEDATTRIBUTE, objInput.value);
			break;
			
		case 'textarea':
			objInput.setAttribute(CONTROLSJS_CHANGEDATTRIBUTE, objInput.text);
			break;
			
		case 'select':
			objInput.setAttribute(CONTROLSJS_CHANGEDATTRIBUTE, objInput.selectedIndex);
			break;
			
			//
			//	other control types...
			//
	}
}

function Changed(objInput){
var value_original = '';
var value_now = '';

	value_original = objInput.getAttribute(CONTROLSJS_CHANGEDATTRIBUTE);

	switch (objInput.tagName.toLowerCase()){
		case 'input':
			value_now = objInput.value;
			break;
			
		case 'textarea':
			value_now = objInput.text;	
			break;			

		case 'select':
			value_now = objInput.selectedIndex;	
			break;
			
			//
			//	other control types...
			//
			
		default:
			value_original = value_now;
			break;

	}
	
	return (value_now != value_original);
}

/*

icw.js
	
Include this in any page that will appear as a primary "application pane" in an ICW "Desktop"

*/

var __m_ICWEventWindowID = 0,
	IMAGE_PATH = "../../Images/User/",
	SHARED_SCRIPTS = "/Web/application/sharedscripts/",
	ICWWin = null;
//var ordersXML;

//=================================================================================================
//= Common Methods

function FunctionExists(strFunctionName)
{
    return (typeof (strFunctionName) === "function") ? true : false;
}

var loadJS = function(file)
{
    var script = document.createElement('script');
    script.src = file;
    script.type = 'text/javascript';
    document.getElementsByTagName('head')[0].appendChild(script);
};

var loadCSS = function(file)
{
    var css = document.createElement('link');
    css.setAttribute("rel", "stylesheet");
    css.setAttribute("type", "text/css");
    css.setAttribute("href", file);
    document.getElementsByTagName('head')[0].appendChild(css);
};

//= Prototype Extensions 
/* Check to ensure Array.push/pop prototype exists, creating one if it doesnt. */
if (!Array.prototype.push)
{
    Array.prototype.push = function(x)
    {
        this[this.length] = x;

        return true;
    };
}

if (!Array.prototype.pop)
{
    Array.prototype.pop = function()
    {
        var response = this[this.length - 1];
        this.length--;
        return response;
    };
}

//JSON functionality is integrated into IE8+ this script provides for IE7
if (typeof (JSON) == "undefined")
{
    loadJS("../../application/sharedscripts/lib/json2.js");
}


/* String Trim strTrim(" string ") returns "string" */
var strTrim = function(s) { return s.replace(/^\s\s*/, '').replace(/\s\s*$/, ''); };
if (!String.prototype.trim) String.prototype.trim = function() { return this.replace(/^\s+|\s+$/g, ''); };



//=================================================================================================
function DesktopWindow()
{
    return ICWWindow().frames["fraCubicle"].frames["fraDesktop"];
}
//=================================================================================================
// Pointer created in ICW.aspx; single point of reference to the Window object in an accessible location.
// Null would be returned where ICW.js is used in modal windows as zero scope is passed in the ICW framework (why?)
function ICWWindow()
{
    /*
    var lngFrameLimit = 99,//Self-imposed nested frame limit
    objICWWindow = window,
    objHTMLTag = objICWWindow.document.all("html"),
    strTagName = "";
	
	while (true) {
    ++count;
    if (objHTMLTag !== null) {
    strTagName = objHTMLTag.className;
    }
    if (strTagName == "_ICW") {
    break;
    }
    if (lngFrameLimit == 0 || objICWWindow.parent == undefined || objICWWindow.parent == null || objICWWindow.location.href == objICWWindow.parent.location.href) {
    throw "Error: Hit top window: icw.js: ICWWindow(): " + window.location.href + ". This error can sometimes occur if ICW Events are raised from modal dialog boxes.";
    break;
    }
    objICWWindow = objICWWindow.parent;
    objHTMLTag = objICWWindow.document.all("html");
    lngFrameLimit--;
    }
    return objICWWindow;
    */
    return top.ptrICW || null;
}



//=================================================================================================
function ICWWindowIsVisible()
{

    var lngFrameLimit = 99, //Self-imposed nested frame limit 
        objICWWindow = window,
        objHTMLTag = objICWWindow.document.all("html"),
        strTagName = "";

    while (true)
    {
        if (objHTMLTag !== null)
        {
            strTagName = objHTMLTag.className;
        }
        if (strTagName == "_ICW")
        {
            break;
        }
        if (lngFrameLimit === 0 || objICWWindow.parent === undefined || objICWWindow.parent === null || objICWWindow.location.href === objICWWindow.parent.location.href)
        {
            alert("Error: Hit top window: icw.js: ICWWindow(): " + window.location.href + ". This error can sometimes occur if ICW Events are raised from modal dialog boxes.");
            break;
        }
        //* 2008.04.11 DPA - taken out since classname always empty - however the new code may not be realising intention here...?
        if (objICWWindow.parent.document.all("html").className == "_TABSTRIP")
        //if (objICWWindow.parent.document.all[0].innerHTML.indexOf("TabStrip") > -1)
        {
            if (objICWWindow.parent.SelectedWindowID() != objICWWindow.ICWWindowID())
            {
                return false;
            }
        }
        objICWWindow = objICWWindow.parent;
        objHTMLTag = objICWWindow.document.all("html");
        lngFrameLimit--;
    }
    return true;


    //    return ICWWindow() ? true : false;

}
//=================================================================================================

//=================================================================================================
function ToolMenuWindow()
{
    return ICWWindow().frames["fraToolMenu"];
}

//=================================================================================================
function BannerWindow() {
    return ICWWindow().frames["fraBanner"];
}

//=================================================================================================

function CubicleWindow()
{
    return ICWWindow().frames["fraCubicle"];
}

//=================================================================================================
function ShortcutBarWindow()
{
    return CubicleWindow().frames["fraShortcutBar"];
}

//=================================================================================================
function ICWEventWindowID()
{
    // 05Sep03 PH	Can be used in an event listener to return the ID of the Window that 
    //					raised the event. Returns 0 if not in an event.
    return __m_ICWEventWindowID;
}

//=================================================================================================
function ICWEventRaise()
{
    // 01Jul03 PH	Is meant to exist in an ICW "RAISE_MyEvent" stub.
    //					Reads the signature of the calling function and use that info to broadcast
    //					and ICW event. The name of the event broadcast is the calling function 
    //					name minus the "RAISE_" prefix, and the parameters of the event are the 
    //					parameters of the calling function.
    // 05Sep03 PH	Changed so that events do not get broadcast back to the calling window.
    // 18Feb11 PH	Added support for JSON parameters

    __m_ICWEventWindowID = ICWWindowID();

    var strFunctionText = String(ICWEventRaise.caller);

    if (strFunctionText.indexOf("RAISE_") == -1)
    {
        alert("Event System Error: Events can only be raised from with RAISE event stubs");
        return false;
    }
    if (window.location.href.indexOf(".aspx") == -1)
    {
        alert("Event System Error: Events can only be raised from .aspx pages");
        return false;
    }

    var intEventNameStart = (strFunctionText.indexOf("_") + 1),
		intEventNameEnd = strFunctionText.indexOf("(", intEventNameStart + 1),
		strEventName = strFunctionText.substring(intEventNameStart, intEventNameEnd),

		objArguments = ICWEventRaise.caller.arguments,
		intParamLength = objArguments.length,
		strParams = "";

    // 18Feb11 PH Added support for JSON string parameters
    if (intParamLength == 1 && (typeof objArguments[0]) == "string" && (objArguments[0]).charAt(0) == '{')
    {
        // This is a Desktop Event that contain a single JSON object parameter, so use new event broadcast mechanism
        var jsonString = objArguments[0];
        // Escape it, so it can be used in an Eval, later.
        var jsonStringEscaped = jsonString
	                                .replace(/\"/g, '\\\"')
	                                .replace(/\r/g, " ")
	                                .replace(/\t/g, " ")
	                                .replace(/\n/g, " ")
        ICWEventBroadcast(strEventName, jsonStringEscaped, __m_ICWEventWindowID, 0);
        //ICWWindow().ICW.util.broadcastFnCall("EVENT_" + strEventName, jsonString);
    }
    else if (intParamLength > 0)
    {
        // This is an non-JSON Desktop Event, so use old-style multi-parameter broadcast mechanism.
        for (var intIndex = 0; intIndex < intParamLength; intIndex++)
        {
            strParams += (", " + FormatArgument(objArguments[intIndex]));
        }
        window.execScript('ICWEventBroadcast("' + strEventName + '"' + strParams + ', ' + __m_ICWEventWindowID + ', 0)');
    }
    else if (intParamLength == 0)
    { //SIK 25072011 handle events without parameters. <strParams> is not exactly needed but it will be an empty string at this point.
        window.execScript('ICWEventBroadcast("' + strEventName + '"' + strParams + ', ' + __m_ICWEventWindowID + ', 0)');
    }
    __m_ICWEventWindowID = 0;

    return true;
}

// Should be used to wrapper an ICW Application URL to auto-include the WindowID QueryString variable in the URL
function ICWURL(strURL)
{

    strURL += strURL.indexOf("?") === -1 ? "?" : "&";
    strURL += ("WindowID=" + ICWWindowID());

    return strURL;
}

// Returns the value of the given key within the query string, empty string if not found
function QueryString(strKey, queryStr)
{
    var i,
		result = "",
		parameters = queryStr != null ? queryStr.substr(1).split("&") : window.location.search.substr(1).split("&"),
		param;

    for (i = 0; i < parameters.length; i++)
    {
        param = parameters[i].split("=");

        if (param[0] == strKey)
        {
            result = param[1];
            break;
        }
    }

    return result;
}

// Return the window ID, 0 if not found
function ICWWindowID()
{
    try
    {
        return parseInt(QueryString("WindowID"), 10);
    }
    catch (e)
    {
        return 0;
    }
}

// Puts " (double quotes) around a variable, if it's a string.
function FormatArgument(MyArgument)
{
    switch (typeof (MyArgument))
    {
        case "string":
            return ('"' + MyArgument + '"');
            break;
        default:
            return MyArgument;
            break;
    }
}

//=================================================================================================
function ICWBroadcastActivateEvent()
{
    //	17Nov05 PH Broadcast an activate to all "visible" child windows

    ICWEventBroadcastToChilden(window, "Activate", "", 0, 0, true);
}

//=================================================================================================
function ICWEventBroadcast(strEventName)
{
    // 31May03 PH	Raises an ICW event, by getting the Desktop window, then traversing all child frames,and 
    //				attempting to call the specified event handler on each window. Any addition parameters
    //				included in the call to this function, are passed through in the broadcasted event calls.

    var objWindow;
    var strParams;
    var intLength;
    var intIndex;

    objWindow = DesktopWindow();

    if (objWindow != null)
    {
        intLength = arguments.length;
        if (intLength > 1)
        {
            strParams = FormatArgument(arguments[1]);
            for (intIndex = 2; intIndex < intLength; intIndex++)
            {
                strParams += ", " + FormatArgument(arguments[intIndex]);
            }
        }

        ICWEventBroadcastToChilden(objWindow, strEventName, strParams, __m_ICWEventWindowID, 0, false);
    }
}

//=================================================================================================
function ICWEventBroadcastToChilden(objWindow, strEventName, strParams, lngWindowID_Source, lngWindowID_Target, blnOnlyVisbleWindows)
{
    // 31May03 PH	See ICWEventBroadcast, above.

    var intLength;
    var intIndex;
    var nodelist;
    var node;
    var objWindow_Target;
    var blnFireEvent = false;

    var xmldoc;
    xmldoc = objWindow.document.all("WindowData");
    if (xmldoc != null)
    { //MK 20092011 bug 14749 Timeout screen on launcher is not modal
        nodelist = objWindow.document.all("WindowData").selectNodes("//Window");

        intLength = nodelist.length;

        for (intIndex = 0; intIndex < intLength; intIndex++)
        {
            node = nodelist(intIndex);
            objWindow_Target = objWindow.frames("fra" + node.getAttribute("ID"));
            switch (Number(node.getAttribute("Type")))
            {
                case 1: // Pane window type
                    if (typeof objWindow_Target.ICWWindowIsVisible == 'function')
                    {
                        if (!blnOnlyVisbleWindows || objWindow_Target.ICWWindowIsVisible())
                        {
                            if (lngWindowID_Target <= 0)
                            {
                                // If no target window specified then send event to all windows, 
                                //	except the source window

                                blnFireEvent = (Number(node.getAttribute("ID")) != lngWindowID_Source)
                            }
                            else
                            {
                                // If a target window IS specified then send event to the target window only

                                blnFireEvent = (Number(node.getAttribute("ID")) == lngWindowID_Target)
                            }

                            if (blnFireEvent)
                            {
                                if (typeof (eval("objWindow_Target.EVENT_" + strEventName)) == "function")
                                {
                                    eval("objWindow_Target.EVENT_" + strEventName + "(" + strParams + ")");
                                }
                            }
                        }
                    }
                    break;

                default: // tabstrip or splitter windows - process child windows
                    //01Mar2010    Rams    F0079170 - javascript error after selecting report editor - Added check to see if window is loaded
                    //all it needs is a minor time delay which needs the document to be fully loaded, presuming this loop will provide that delay required.
                    var tryCount = 0;
                    while (tryCount < 4)
                    {
                        if (typeof objWindow_Target.ICWWindowIsVisible == 'function')
                        {
                            ICWEventBroadcastToChilden(objWindow_Target, strEventName, strParams, lngWindowID_Source, lngWindowID_Target);
                            break;
                        }
                        tryCount++;
                    }
                    break;
            }

        }
    }
}

//=================================================================================================
function FormatArgument(MyArgument)
{
    // 31May03 Puts " (double quotes) around a variable, if it's a string. 

    switch (typeof (MyArgument))
    {
        case "string":
            return '"' + MyArgument + '"';
            break;
        default:
            return MyArgument;
            break;
    }
}

//=================================================================================================
function ICWStatusShow(strText)
{
    var objWindow = ICWWindow();
    if (objWindow.document.all("fraStatus").getAttribute("ICWOpened") != "yes")
    {
        objWindow.frames("fraStatus").MessageSet(strText);
        objWindow.document.all("fraStatus").style.display = "";
    }
}

//=================================================================================================
function ICWStatusHide()
{
    var objWindow = ICWWindow();
    if (objWindow.document.all("fraStatus").getAttribute("ICWOpened") != "yes")
    {
        objWindow.document.all("fraStatus").style.display = "none";
    }
}

//=================================================================================================
function ICWWindowExtraCaptionSet(strText)
{
    document.getElementById("spnICWExtraCaptionText").innerText = strText;
}

//=================================================================================================
function ICWWindowUserCaptionSet(strText)
{
    document.getElementById("spnICWUserCaptionText").innerText = strText;
}

// --------------------------Toolbar code----------------------------------
// Event handling code for ICW and Window Toolbar.
//
// Click events on toolbar icons are captured below in 'btnToolBar_onclick' 
// which calls the function ICWToolbar_onclick(EventName, WindowID)
// You must script this into your own application web pages in order to capture
// this event. Passes through EventName. This can then be
// handled however you like within your own code.
//
// Example of use;
//
// function ICWToolbar_onclick(EventName, WindowID)
// {
//     alert("EventName: " + EventName + " WindowID: " + WindowID);
// }
//
// 17Jun03 DB Created
// ----------------------------------------------------------------------

//=================================================================================================
function ToolbarHighlightOn(objToolbarTD)
{
    // Handles a mouse enter event for toolbars. Changes the class to
    // one with a border

    if (!objToolbarTD.parentNode.parentNode.parentNode.parentNode.disabled)
    {
        objToolbarTD.className = "toolbarHover";
    }
}

//=================================================================================================
function ToolbarHighlightOff(objToolbarTD)
{
    // Handles a mouse leave event for toolbars. Sets the class back to normal

    objToolbarTD.className = "toolbarNormal";
}

//=================================================================================================
function btnToolBar_onmousedown(objToolbarButton)
{
    // Event code to capture mousedown event for toolbar button

    // Set the class back to Selected
    if (!objToolbarButton.disabled)
    {
        this.className = "toolbarSelected";
    }
}

//=================================================================================================
function btnToolBar_onmouseup(objToolbarButton)
{
    // Event code to capture mouseup event for toolbar button

    // Set the class back to hover
    this.className = "toolbarHover";
}

function btnToolBar_onclick(EventName, EventParameter, WindowID)
{
    // Captures a toolbar button click and passes it up to the ICW container for processing
    var Parameter = "'" + EventParameter + "'";
    ICWWindow().ICWToolbar_onclick(EventName, Parameter, WindowID);
}

function ICWToolMenuEnable(strEventName, blnEnabled)
{
    ICWWindowToolBarEnable(window, strEventName, blnEnabled);
    ICWWindowToolBarEnable(ToolMenuWindow(), strEventName, blnEnabled);
}

//=================================================================================================
function ICWWindowToolBarEnable(objWindow, strEventName, blnEnabled)
{
    var xmlnodelist,
	xmlnode,
	intIndex,
	imgToolMenu,
	btnToolMenu,
	xmldoc = objWindow.document.all("xmlICWToolbar");

    if (xmldoc != null)
    {
        xmlnodelist = xmldoc.selectNodes("//ToolMenu[@EventName='" + strEventName + "']");
        for (intIndex = 0; intIndex < xmlnodelist.length; intIndex++)
        {
            xmlnode = xmlnodelist(intIndex);

            imgToolMenu = objWindow.document.getElementById("imgICWToolMenu_" + xmlnode.getAttribute("ToolMenuID"));
            if (imgToolMenu != null)
            {
                if (blnEnabled)
                {
                    imgToolMenu.style.filter = "";
                }
                else
                {
                    imgToolMenu.style.filter = "progid:DXImageTransform.Microsoft.BasicImage(grayscale=0)";
                }
            }

            btnToolMenu = objWindow.document.getElementById("btnToolBar_" + xmlnode.getAttribute("ToolMenuID"));
            if (btnToolMenu != null)
            {
                btnToolMenu.disabled = !blnEnabled;
                if (blnEnabled)
                {
                    btnToolMenu.style.filter = "";
                }
                else
                {
                    btnToolMenu.style.filter = "progid:DXImageTransform.Microsoft.Alpha(Opacity=75)";
                }
            }
        }
    }

    ToolMenuWindow().ICWMenuEnable(strEventName, blnEnabled);
}

//=================================================================================================
function ICWToolMenuOverride(strEventName, strCaption, strPictureName)
{
    //17May07 AE  Added ability to change image here as well
    ToolMenuWindow().ICWToolMenuOverride(strEventName, strCaption, strPictureName);
    ICWToolOverride(strEventName, strCaption, strPictureName);
}

//=================================================================================================
function ICWToolOverride(strEventName, strCaption, strPictureName)
{
    /* 
    21Feb07 CJM Added ability to change image as well
    */

    var xmldoc;
    var xmlNodeList;
    var xmlNode;

    xmldoc = document.all("xmlICWToolbar");
    if ((xmldoc != null) && !((strCaption == null) && (strPictureName == null))) // added check on menutext for classes that have no CopyPhrase etc.
    {
        xmlNodeList = xmldoc.selectNodes("//ToolMenu[@EventName='" + strEventName + "']");

        for (var i = 0; i < xmlNodeList.length; i++)
        {
            xmlNode = xmlNodeList[i];

            if (strCaption != null)
            {
                tdToolMenu = document.getElementById("tdICWToolMenu_" + xmlNode.getAttribute("ToolMenuID"));
                if (tdToolMenu != null)
                {
                    tdToolMenu.innerText = strCaption;
                }
            }

            if (strPictureName != null)
            {
                imgToolMenu = document.getElementById("imgICWToolMenu_" + xmlNode.getAttribute("ToolMenuID"));
                if (imgToolMenu != null)
                {
                    imgToolMenu.src = IMAGE_PATH + strPictureName;
                }
            }
        }
    }
}

//=================================================================================================
function ICWToolMenuList(lngWindowID, blnEnabledOnly)
{

    //Return a reference to an iXMLNodeList containing a list of all menu items for the specified window.
    //If blnEnabledOnly is true, only enabled items are included in the list.
    //Returns undefined if there is no menu.
    //07Feb05 AE  Written

    var DOM = ToolMenuWindow().document.all['xmlToolMenu'];

    if (DOM != undefined)
    {
        var strXPath = '//ToolMenu';
        if (blnEnabledOnly)
        {
            strXPath += '[(@WindowID="' + lngWindowID + '") and (@Enabled="1")]';
        }
        else
        {
            strXPath += '[@WindowID="' + lngWindowID + '"]';
        }
        return DOM.selectNodes(strXPath);
    }
}

//=================================================================================================
function IsICWEventEnabledInMenu(SessionID, EventName, WindowID)
{
    // 19Apr06 PH Checks to see if the specified action is available and enabled in the ICW toolbar.

    var lngWindowID = ICWWindowID();
    var colItems = ICWToolMenuList(lngWindowID, true);

    if (colItems != undefined && colItems.length > 0)
    {																		//27Feb06 AE  Added check for length > 0
        for (i = 0; i < colItems.length; i++)
        {
            if (colItems[i].getAttribute('EventName') == EventName)
            {
                return true;
            }
        }
    }
    return false;
}

//=================================================================================================
// 24Jun2009 JMei method for removing a variable from querystring array
// query format: {[variable1=y],[variable2=yy],[variable3=yyy],[variable4=yyyy]}
function RemoveVariable(query, key)
{
    var queryvalue, i;
    for (i = 0; i < query.length; i++)
    {
        queryvalue = query[i].split("=");
        if (queryvalue[0] == key)
        {
            query.splice(i, 1);
        }
    }
    return query;
}

function GetVariable(query, key)
{
    var queryvalue, i;
    for (i = 0; i < query.length; i++)
    {
        queryvalue = query[i].split("=");
        if (queryvalue[0] == key)
        {
            return queryvalue[1];
        }
    }
    return "";
}
//=================================================================================================

//16Jul10   Rams    F0083243 - Additional Login support for Symphony Integration
//24Aug10   MK      Changes the interface to allow a sessionID parameter
//13dec10   Rams    Removed SessionID being passed as a param and
//                  created a new function that can be called across to get the CurrentSessionID
//01Nov11   Mattius Bug 8326 - Changed to ICWValidateLogin which returns either a Username if Successful and
//                  an empty string if not
function ICWValidateLogin()
{
    var retval = window.showModalDialog("../ICW/AdditionalLogin.aspx?SessionID=" + GetCurrentSessionID(), "", "center:yes;status:no;dialogWidth:640px;dialogHeight:480px");
	if (retval == 'logoutFromActivityTimeout') {
		retval = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

    if (retval == null) { retval = ''; }

    return retval;
}

//16Jul10   Rams    F0083243 - Additional Login support for Symphony Integration
function IsGUID(source)
{
    if (source != undefined && source !== null)
    {
        var guidRegEx = new RegExp("^(\{{0,1}([0-9a-fA-F]){8}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){4}-([0-9a-fA-F]){12}\}{0,1})$");

        return source.match(guidRegEx);
    }
    return false;
}

//Added as part of RFC F0097938 - Function accepts desktop descriptions, checks for the matching name in the top.menumap object created in ToolMenu.aspx
//and passes the ID and Name arguments as required by NavigateToApplication.
var NavigateToApplicationByName = function(strDescription)
{
    function getWindow(tagName)
    {
        if (isNaN(top.menuMap[tagName])) { return false; }
        return top.menuMap[tagName];
    };

    var tmpInt = getWindow(strTrim(strDescription));
    if (tmpInt !== false)
    {
        ICWWindow().NavigateToApplication(tmpInt, strDescription);
        return true;
    } else
    {
        return false;
    }

}


/// <summary>
///     Find Window by FileName to retrieve the WindowID
///	  Returns WindowID if found; otherwise returns 0
/// </summary>
/// <param name="str" domElement="false">
///    FileName to search for, must be a string, must not be null
/// </param>
/// <returns type="Int" />
var ICWFindWindowIdByPageName = function(str)
{
    var frames = null,
		arrCount = -1;
    function getFileName(winObj)
    {
        var tmp = winObj.location.pathname.split("/");
        return String(tmp[tmp.length - 1]).toLowerCase();
    }

    if ((typeof str === "string") && (typeof ICWWindow().ICW.util.getFrames === "function"))
    {
        frames = ICWWindow().ICW.util.getFrames();
        arrCount = frames.length;
        while (arrCount--)
        {
            if (getFileName(frames[arrCount]) == String(str).toLowerCase())
            {
                return QueryString("WindowID", frames[arrCount].location.search) || 0;
            }
        }
        return 0;
    }
};

/// <summary>
///     Finds a window object by its Window ID 
///	  Returns Window object or Null if not found
/// </summary>
/// <param name="iID" domElement="false">
///    Accepts Window ID
/// </param>
/// <returns type="Window[Object]" />
var findWindowByID = function(iID)
{
    var frames = null, arrCount = 0;
    if (FunctionExists(ICWWindow().ICW.util.getFrames))
    {
        frames = ICWWindow().ICW.util.getFrames();
        arrCount = frames.length;

        while (arrCount--)
        {
            if ((frames[arrCount].location.search.length > 0) && (QueryString("WindowID", frames[arrCount].location.search) == iID))
            {
                return frames[arrCount];
            }
        }
    }
    return null;
}


/// <summary>
///     Finds a window object by its Window ID 
///	  Returns Position & Dimensions based on frameElement
/// </summary>
/// <param name="ICWWinID" domElement="false">
///    Accepts Window ID
/// </param>
/// <returns type="Object" />
var ICWWindowDimensions = function(ICWWinID, RelativeOffset)
{
    var winByID = findWindowByID,
		win, ICWScreen;

    if (typeof (RelativeOffset) == 'undefined')
    {
        RelativeOffset = true;
    }


    if ((!isNaN(ICWWinID)) && (ICWWinID > 0) && (typeof ICWWindow().ICW.util.screen === "object"))
    {
        win = winByID(Number(ICWWinID));
        if (win !== null)
        {
            ICWWindow().ICW.util.screen.init(win.parent.document, win.parent);
            return {
                top: RelativeOffset == false ? window.screenTop : ICWWindow().ICW.util.screen.absYPosition(win.frameElement, true),
                left: RelativeOffset == false ? window.screenLeft : ICWWindow().ICW.util.screen.absXPosition(win.frameElement, true),
                height: win.frameElement.height,
                width: win.frameElement.width
            };
        }
    }
    return null;
};


/// <summary>
///     Queries available windows for permission to run the desktop close event
///	  'raises' desktop close event (called across available frames)
///	  Returns true if the event was raised; false if it wasnt.
/// </summary>
/// <returns type="Bool" />
var Desktop_QueryClose = function()
{
    var frames = null, arrCount = 0, flag = true;

    frames = ICWWindow().ICW.util.getFrames();
    arrCount = frames.length;

    while (arrCount--)
    {
        if (FunctionExists(frames[arrCount].EVENT_Desktop_QueryClose))
        {
            if (frames[arrCount].EVENT_Desktop_QueryClose() === false) { flag = false; }
            break;
        }
    }

    if (flag)
    {
        ICWWindow().ICW.util.broadcastFnCall("EVENT_Desktop_Close");
        return true; /* Raise DesktopClose Event */
    }

    return false; /* Dont Raise DesktopClose Event */
};


/// <summary>
///    Should Be Called from within the IFRAME(tab) wishing to be disabled.
/// </summary>
/// <param name="bEnable" domElement="false">
///    True enables frames related tab, disabled disables
/// </param>
/// <returns type="Void" />
var ICWTabEnable = function(bEnable)
{

    var targetFrameTab,
		ICWWin = ICWWindow(),
		tabStrip = ICWWin.ICWFindWindowIdByPageName("tabstrip.aspx"),
		tabWindow = ICWWin.findWindowByID(tabStrip);

    targetFrameTab = "tabfor" + window.frameElement.id;

    if (bEnable)
    {
        tabWindow.document.getElementById(targetFrameTab).disabled = "";
    } else
    {
        tabWindow.document.getElementById(targetFrameTab).disabled = "disabled";
    }

};

//13Dec10   Rams    function created to get the SessionID that can be accessed globally
//
function GetCurrentSessionID()
{
    return ICWWindow().document.body.getAttribute("SessionID");
}

//14Dec10 ST    F0103979 Retrieves a setting value for the specified item.
function ICWGetSetting(system, section, key, defaultvalue)
{
    var url = "../sharedscripts/ICWHelper.aspx?Mode=ICWGetSetting",
		data = "sessionID=" + GetCurrentSessionID()
                + "&system=" + system
                + "&section=" + section
                + "&key=" + key
                + "&defaultvalue=" + defaultvalue,

		objHTTPRequest = (window.XMLHttpRequest) ? new XMLHttpRequest() : new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", url, false);
    objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    objHTTPRequest.send(data);

    return objHTTPRequest.responseText || "";
}

/*
//Set/Get State
var SetState = function(strKey, strValue) {

if (top.window.name == "" || typeof (top.window.name) != String) {
var setup = { ICWVID: "", SESSION: GetCurrentSessionID(), DATE: null };
top.window.name = JSON.stringify(setup);
}

strKey = strKey.toUpperCase();

var dataStore = JSON.parse(top.window.name);
dataStore[String(strKey)] = strValue;
top.window.name = JSON.stringify(dataStore);

return true;
};

var GetState = function(strKey) {
var jsonReturn = "";

if (top.window.name === "" || typeof (top.window.name) !== "string") {
var setup = { ICWVID: "", SESSION: GetCurrentSessionID(), DATE: null };
top.window.name = JSON.stringify(setup);
}

strKey = strKey.toUpperCase();

jsonReturn = JSON.parse(top.window.name);
return jsonReturn[strKey] ? jsonReturn[strKey] : {};

};
*/

var splash = (function() {

    var opt = {
        ptrWindow: window,
        blnIsOpen: false,
        objData: null,
        strMessage: "Loading Data",
        strErrorTitle: "Patient Not Found",
        fnRefreshCallback: null,
        fnCancelCallback: null,
        strError: ""
    };

    function _$(e) { return document.getElementById(e); } /* Returns Element */
    function _$$(e) { return document.getElementById(e) ? true : false; } /* Returns True if element exist, else false */

    var DialogueHTML = "\
							<div id=\"tboverlay\"> <!--  Overlay --> <\/div> \
							<div id=\"tbwindow\"><div id=\"win\"> \
							<p id=\"topMessage\" style=\"font-weight:bold;\">" + opt.strMessage + "</p><br \/><img id=\"splashimg\" hspace=\"2\" vspace=\"2\" src=\"../../images/Developer/ajax-loader.gif\" height=\"42\" width=\"42\" /><br \/> \
							<p id=\"warnMessage\"  style=\"margin-top:-40px;\" onclick=\"window.clipboardData.setData('Text', this.innerHTML);\">&nbsp;<\/p> \
							<input type=\"button\" id=\"cancelthickbox\" value=\"Cancel\" \/>\
							<input type=\"button\" id=\"refreshthickbox\" style=\"display:none\" value=\"Retry\" \/> \
							<\/div><\/div> ";


    function OpenModalSplashFunc(fnRefreshCallBackFunc, fnCancelCallBackFunc, objMyData) {
        if (opt.blnIsOpen) {
            // If already open, then close
            CloseModalSplashFunc()
        }

        // Open the dialog
        var modalDiv = opt.ptrWindow.document.createElement("div");
        opt.blnIsOpen = true;
        opt.ptrWindow.document.body.innerHTML += DialogueHTML;
        opt.fnRefreshCallback = fnRefreshCallBackFunc;
        opt.fnCancelCallback = fnCancelCallBackFunc;
        opt.objData = objMyData;

        _$("cancelthickbox").onclick = function() { splash.cancelButtonPressed() };
        _$("refreshthickbox").onclick = function() { splash.refreshButtonPressed() };
    }

    function CloseModalSplashFunc() {
        // Close the dialog
        var bodyObj = opt.ptrWindow.document.body
        bodyObj.removeChild(_$("tboverlay"));
        bodyObj.removeChild(_$("tbwindow"));
        opt.blnIsOpen = false;
    }

    function SetModalError(error) {
        opt.strError = error;
    }

    // Can be called prior to OpenModalSplashFunc to set the Header message
    function SetTitle(text) {
        opt.strMessage = text;
    }

    // Can be called prior to OpenModalSplashFunc to set the Header message
    function SetErrorTitle(text) {
        opt.strErrorTitle = text;
    }

    function CancelModalSplashFunc() {
        ToggleButtonToCancelText();
    }

    function CancelButtonPressedFunc() {
        ToggleButtonToCancelText();
        // Call cancel call back function, passing an user-defined data
        opt.fnCancelCallback(opt.objData);
    }

    function RefreshButtonPressedFunc() {
        // Refresh button pressed, so call Refresh callback function
        if (_$$("splashimg")) {
            _$("splashimg").src = "../../images/Developer/ajax-loader.gif";
        }
        if (_$$("refreshthickbox") && _$$("cancelthickbox")) {
            _$("cancelthickbox").style.display = "";
            _$("refreshthickbox").style.display = "none";
        }
        // Call refresh call back function, passing an user-defined data
        opt.fnRefreshCallback(opt.objData);
    }

    function ToggleButtonToCancelText() {
        if (_$$("warnMessage")) {
            if (opt.strError.length > 0) {
                _$("splashimg").style.display = 'none';
                _$("topMessage").innerHTML = opt.strErrorTitle + '&hellip;';
                _$("warnMessage").innerHTML = opt.strError;
            }
            else {
                _$("splashimg").style.display = '';
                _$("topMessage").innerHTML = opt.strMessage + '&hellip;';
                _$("warnMessage").innerHTML = "";
            }
        }
        // Cancel button pressed, so replace with Refresh button
        if (_$$("splashimg")) {
            _$("splashimg").src = "../../images/ajax-loader-stopped.gif";
        }
        if (_$$("refreshthickbox") && _$$("cancelthickbox")) {
            _$("cancelthickbox").style.display = "none";
            _$("refreshthickbox").style.display = "";
        }
    }

    // Public method
    function Cancel() {
        ToggleButtonToCancelText();
    }

    // Setup Splash object properties and methods
    return {
        option: opt,
        openModalSplash: OpenModalSplashFunc,
        closeModalSplash: CloseModalSplashFunc,
        cancelModalSplash: CancelModalSplashFunc,
        cancelButtonPressed: CancelButtonPressedFunc,
        refreshButtonPressed: RefreshButtonPressedFunc,
        setModalError: SetModalError,
        setTitle: SetTitle,
        setErrorTitle: SetErrorTitle
    };

} ());

//----------------------------------------------------------------------------------------------

//23Mar11 PH F0112877 Return the type of installation (LIVE, TRAINING, TEST, UNKNOWN). 
// Installation type is determined by database name suffix.
function ICWGetInstallationType()
{
    return ToolMenuWindow().document.body.getAttribute("InstallationTypeCode");
}
//17may11  MK f0037899  during a major incident - display incident name in title bar
function ICWWindowUserCaptionVisible(isVisible)
{
    document.getElementById("divPaneCaption").style.display = (isVisible ? "" : "None");
}

