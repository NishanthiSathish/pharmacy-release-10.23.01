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



