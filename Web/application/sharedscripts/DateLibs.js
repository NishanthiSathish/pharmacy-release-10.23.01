//===========================================================================
//										DateLibs.js
//
//	Set of date manipulation procedures.  Geared mainly around handling
//	user-entered dates, validating them, and transforming them to 
//	dd-mmm-yyyy format to prevent any ambiguity.
//
//	Will need a fair bit of work in future, esp for internationalisation,
//	but deal with most common uk and us formats.
//
//	Useage:
//				FormatDate(dtIN, strFormat):					Formats a date object into a string.
//				StringToDate(dateString, splitterChar)		Converts a date string into a date object.  
//				ParseDate(dateString, dateFormatOut) 		Converts a date string into a different format. Deals with any combination of dd, mm, mmm, yyyy separated by one of ./-	
//				ParseTDate( strTDate )							Converts a SQL-generated XML format string date from (ccyy-mm-ddThh:mm:ss:fff) to a Date object, where f = milli-seconds
//				IsValidMonth(monthString)						Determines if the string specifies a valid month.  mm and mmm supported.
//				DaysInMonth(monthString)						Returns the number of days in a month. mm and mmm supported
//				MonthNumberFromName(monthName)				Returns the number of a month from its name.  mm and mmm supported.
//				YearsOld( datBirth, datWhen )					Calculates an age in years, between two dates 
//				YearsOldToday( datBirth )						Calculates an age in years from a birth date, to today.
//				IsLeapYear(intYear)								Returns true if the specified year is a leap year, false if not.
//          MonthNameFromNumber(monthNumber,blnShort)       Returns Name of Month for given number (remember 0 = jan for JS Dates) - set short for 3 char abbreviation
//          DateDiff(datStart,datEnd,strInterval,blnRounding) Returns the number of intervals specified between the start and end date
//				ddmmccyy2Date(strDate)							Takes ddmmccyyyy string (with or without leading zeros) and returns JScript Date object
//				Date2ddmmccyy(dateThis)							Takes JScript Date object and returns ddmmccyy string
//				Date2TDate(dateThis)								Takes JScript Date object and returns TDate string
//				TDate2Date(strTDate)								Converts a SQL-generated XML format string date from (ccyy-mm-ddThh:mm:ss:fff) to a Date object, where f = milli-seconds. Same a ParseTDate, but just included for naming facism sake.
//				DateStringValid(dateString)					Returns true if the date string is valid, false if not
//
//	Requirements:
//		ICWFunctions.js
//	
//	Modification History:
//	05Mar03 AE  Written
//	18Mar03 AE  Added "ParseDate2003" and reworked many of the internals to use it.
//	27May03 AE  ParseDate: Now accepts date times; the time portion of the string is removed and the 
//					date parsed as usual.
//	28May03 AE  DaysInMonth; corrected bug caused by the 0-11 month numbering of js.
// 02Jul03 TH  Added MonthNameFromNumber function
//	07Apr04 PH	Added ddmmccyy2Date & Date2ddmmccyy
//	07Apr04 PH	Added Date2TDate & TDate2Date
//	02Jun04 AE  Added DateStringValid
//	04Jul07 ST  Added ParseDate back in as it's still being used in code and was causing bad bad things to happen
//
//===========================================================================
var m_astrMonths = new Array ('jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec');
var m_aintMonthDays = new Array(31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

var DATE_DELIMITERS = './- '

var EARLIEST_YEAR = 1753						//The earliest year we deal with
var LATEST_YEAR = 9999						//The latest year we deal with

function DaysInMonth(monthString) {

//Returns the days in a month.
//	monthString can be in either mm or mmm format	
//
//	If the given month is not recognised, -1 is returned.
//	NOTE: Returns 28 for feburary!

var intDays = new Number(-1);

	if (IsNumeric(monthString)) {
		if (monthString.length <= 2) {
			//nice easy 1-2 digit month
			intDays = m_aintMonthDays[eval(monthString) - 1];
		}
	}
	else {
		//Non-numeric month. At present, only 3-letter months are supported
		if (monthString.length == 3) {
			//3 letter month.
			var intMonth = MonthNumberFromName(monthString);
			if (intMonth != -1) {intDays = m_aintMonthDays[intMonth];}
		}
	}
	return intDays;
}

//=================================================================================

function MonthNumberFromName(monthName) {
	
//Given a month name, returns the number of the month.
//ie 1 for jan, 2 for feb, etc.
//
//	monthName: 		month in mmm format
//
//	returns:
//						Integer; -1 if the month was not recognised.

var intCount = new Number();
var intReturn = -1
	
	monthName = monthName.toLowerCase();
	for (intCount =0; intCount < 12; intCount++) {
		if (monthName == m_astrMonths[intCount]) {
			intReturn = intCount + 1;
			break;
		}
	}
	
	return intReturn;
}


//=================================================================================

function ParseTDate( strTDate )
{
	return TDate2Date( strTDate );
}

//=================================================================================
function YearsOld( datBirth, datWhen )
{
// Calculates an age in years, between two dates

	var intBirthYear = datBirth.getFullYear();
	var intWhenYear = datWhen.getFullYear();
	var intYearsOld = intWhenYear - intBirthYear;

	var datAdjustedBirth = new Date(intWhenYear, datBirth.getMonth(), datBirth.getDate() );

	if ( datAdjustedBirth > datWhen )
	{
		intYearsOld--;
	}

	return intYearsOld;
}

//=================================================================================

function YearsOldToday( datBirth )
{
	// Calculates an age in years from a birth date, to today.
	return YearsOld( datBirth, (new Date()) );
}

//=================================================================================

function IsLeapYear(intYear)
{
// Returns true if the specified year is a leap year, false if not.

// "Leap Year occurs every four years, except for years ending in 00, 
// in which case only if the year is divisible by 400."

	// PH I was going to code the above rules, long hand, but then I thought 
	//	   I might as well allow JScript to do it for me.
	return (new Date(intYear, 1, 29)).getDate() == 29;
}

//=================================================================================

function MonthNameFromNumber(monthNumber,blnShort) {
//02Jul03 TH Written
	
//Given a month number, returns the name of the month.
//ie 0 for jan, 1 for feb, etc. (uses unreconstructed JS month array 
//
//	monthNumber: 		month as Number
//  blnShort   :        if true then name to 3 chars else full name
//
//	returns:			string of MonthName
//						Integer; -1 if the month was not recognised.

var strMonth ;
	
	switch (monthNumber)	
	{
		case 0:strMonth = "january";break;
		case 1:strMonth = "february";break;
		case 2:strMonth = "march";break;
		case 3:strMonth = "april";break;
		case 4:strMonth = "may";break;
		case 5:strMonth = "june";break;
		case 6:strMonth = "july";break;
		case 7:strMonth = "august";break;
		case 8:strMonth = "september";break;
		case 9:strMonth = "october";break;
		case 10:strMonth = "november";break;
		case 11:strMonth = "december";break;
	}
	if (blnShort == true)
	{
		strMonth = strMonth.substring(0,3);
	}
	
	return strMonth;
}

//=================================================================================
function DateDiff(datStart,datEnd,strInterval,blnRounding) 
{
//29Jul03 TH Borrowed wholesale from www.flws.com.au/showusyourcode/codeLib
//           though suppressed error popups/msgs - if its wrong in any way you get null
//           and altered to allow input of date objects

    var iOut = 0;
    
    var bufferA = Date.parse(datStart.toUTCString());  //( datStart ) ;
    var bufferB = Date.parse(datEnd.toUTCString());  //( datEnd ) ;
    	
    // check that the start parameter is a valid Date. 
    if ( isNaN (bufferA) || isNaN (bufferB) ) {
		return null ;
    }
	
    // check that an interval parameter was not numeric. 
    if ( strInterval.charAt == 'undefined' ) {
        // the user specified an incorrect interval, handle the error.
        return null ;
    }
    
    var number = bufferB-bufferA ;
    
    // what kind of add to do? 
    switch (strInterval.charAt(0))
    {
        case 'd': case 'D': 
            iOut = parseInt(number / 86400000) ;
            if(blnRounding) iOut += parseInt((number % 86400000)/43200001) ;
            break ;
        case 'h': case 'H':
            iOut = parseInt(number / 3600000 ) ;
            if(blnRounding) iOut += parseInt((number % 3600000)/1800001) ;
            break ;
        case 'm': case 'M':
            iOut = parseInt(number / 60000 ) ;
            if(blnRounding) iOut += parseInt((number % 60000)/30001) ;
            break ;
        case 's': case 'S':
            iOut = parseInt(number / 1000 ) ;
            if(blnRounding) iOut += parseInt((number % 1000)/501) ;
            break ;
        default:
        // If we get to here then the interval parameter
        // didn't meet the d,h,m,s criteria.  Handle
        // the error. 		
        return null ;
    }
    return iOut ;
}

//===========================================================================
function IsTDate(strDate)
{
	strDate = new String(strDate);
	
	return strDate.indexOf("T")>=0;
}
//===========================================================================
function Date2TDate(dateThis)
{
// PH converts Date object to a TDate string
	strYear = dateThis.getFullYear().toString();
	strMonth = (dateThis.getMonth()+1).toString();
	strDay = dateThis.getDate().toString();
	strHour = dateThis.getHours().toString();
	strMinute = dateThis.getMinutes().toString();
	strSecond = dateThis.getSeconds().toString();

	if (strMonth.length==1) { strMonth = "0" + strMonth; }
	if (strDay.length==1) { strDay = "0" + strDay; }
	if (strHour.length==1) { strHour = "0" + strHour; }
	if (strMinute.length==1) { strMinute = "0" + strMinute; }
	if (strSecond.length==1) { strSecond = "0" + strSecond; }
	
	return strYear + "-" + strMonth + "-" + strDay + "T" + strHour + ":" + strMinute + ":" + strSecond;
}
//===========================================================================
function Date2ISODate(dateThis)
{
// PH converts Date object to an ISO 8601 string (Basically TDate without the T!)
	strYear = dateThis.getFullYear().toString();
	strMonth = (dateThis.getMonth()+1).toString();
	strDay = dateThis.getDate().toString();
	strHour = dateThis.getHours().toString();
	strMinute = dateThis.getMinutes().toString();
	strSecond = dateThis.getSeconds().toString();

	if (strMonth.length==1) { strMonth = "0" + strMonth; }
	if (strDay.length==1) { strDay = "0" + strDay; }
	if (strHour.length==1) { strHour = "0" + strHour; }
	if (strMinute.length==1) { strMinute = "0" + strMinute; }
	if (strSecond.length==1) { strSecond = "0" + strSecond; }
	
	return strYear + "-" + strMonth + "-" + strDay + " " + strHour + ":" + strMinute + ":" + strSecond;
}
//===========================================================================
function TDate2Date( strTDate )
{
// Converts a string date from SQL-generated XML format (ccyy-mm-ddThh:mm:ss:fff)
// to a Date object, where f = milli-seconds

	var intYear = Number(strTDate.substr(0,4));
	var intMonth = Number(strTDate.substr(5,2))-1;
	var intDay = Number(strTDate.substr(8,2));

	var intHours = Number(strTDate.substr(11,2));
	var intMinutes = Number(strTDate.substr(14,2));
	var intSeconds = Number(strTDate.substr(17,2));
	
	var intMS = Number(strTDate.substr(20,2));

	return new Date( intYear, intMonth, intDay, intHours, intMinutes, intSeconds, intMS );
}

//===========================================================================

function Date2DDMMYYYY(dtDate){

//04Feb05 AE  Reinstated for Custom Controls ONLY.
//				  To patch bug in start date shuffling procedures which still use
//					ddmmyyyy format.  DO NOT USE THIS PROCEDURE FOR ANY NEW CODE!

	var DD = dtDate.getDate();
	if (DD.toString().length == 1) DD = '0' + DD;
	
	var MM = Number(dtDate.getMonth()) + 1;										//Convert js 0-11 months to proper 1-12 ones
	if (MM.toString().length == 1) MM = '0' + MM;

	return (DD + '/' + MM + '/' + dtDate.getFullYear() );

}


//===========================================================================

function Date2DDMMYYYY(dtDate){

//04Feb05 AE  Reinstated for Custom Controls ONLY.
//				  To patch bug in start date shuffling procedures which still use
//					ddmmyyyy format.  DO NOT USE THIS PROCEDURE FOR ANY NEW CODE!

	var DD = dtDate.getDate();
	if (DD.toString().length == 1) DD = '0' + DD;
	
	var MM = Number(dtDate.getMonth()) + 1;										//Convert js 0-11 months to proper 1-12 ones
	if (MM.toString().length == 1) MM = '0' + MM;

	return (DD + '/' + MM + '/' + dtDate.getFullYear() );

}

function ddmmccyy2Date(strDate)
{
// PH Converts a ddmmccyy date string to a Date object
	var SlashOne = strDate.indexOf("/");
	var SlashTwo = strDate.lastIndexOf("/");
	return new Date(Number(strDate.substr(SlashTwo+1,4)), Number(strDate.substr(SlashOne+1,SlashTwo-SlashOne-1))-1, Number(strDate.substr(0,SlashOne)));
}

//===========================================================================

function Date2ddmmccyy(dateThis)
{
	// PH Converts a Date object to a ddmmccyy date string
	strDay = dateThis.getDate().toString();
	strMonth = (dateThis.getMonth() + 1).toString();
	strYear = dateThis.getFullYear().toString();

	if (strDay.length == 1) { strDay = "0" + strDay; }
	if (strMonth.length == 1) { strMonth = "0" + strMonth; }

	return strDay + "/" + strMonth + "/" + strYear;

}

//===========================================================================

function Date2hhmmss(dateThis)
{
	// PH Converts a Date object to a hh:mm:ss 24-hour time string
	strHour = dateThis.getHours().toString();
	strMinute = (dateThis.getMinutes()).toString();
	strSecond = dateThis.getSeconds().toString();

	if (strHour.length == 1) { strHour = "0" + strHour; }
	if (strMinute.length == 1) { strMinute = "0" + strMinute; }
	if (strSecond.length == 1) { strSecond = "0" + strSecond; }

	return strHour + ":" + strMinute + ":" + strSecond;

}

// Takes a JS date object and converts it into dd/mm/ccyy string where "/" is an optional delimiter 
// that will default to "-" if not passed
function DateFromJSDate(dateToConvert, dateDelimiter) {
    var dateDay = dateToConvert.getDate().toString();
    var dateMonth = (dateToConvert.getMonth() + 1).toString();
    var dateYear = dateToConvert.getFullYear().toString();

    if (dateDelimiter == null) {
        dateDelimiter = "-";
    }

    if (dateDay.length == 1) {
        dateDay = "0" + dateDay;
    }

    if (dateMonth.length == 1) {
        dateMonth = "0" + dateMonth;
    }

    return dateDay + dateDelimiter + dateMonth + dateDelimiter + dateYear;
}

// Takes a JS date object and returns a time string as hh:mm
function TimeFromJSDate(dateToConvert) {
    var timeMinutes = dateToConvert.getMinutes().toString();
    var timeHours = dateToConvert.getHours().toString();

    if (timeMinutes.length == 1) {
        timeMinutes = "0" + timeMinutes;
    }

    if (timeHours.length == 1) {
        timeHours = "0" + timeHours;
    }

    return timeHours + ":" + timeMinutes;
}

//===========================================================================
// 04Jul07 ST Put back in as shock, horror it's still being used!  Oh to be .NET


function ParseDate(dateString, dateFormatOut) {
	
// Checks if the given date string contains a valid date
// And returns it as a string
//	If the date was not valid, an empty string is returned.
//	Any time information is removed from the string (so dd/mm/ccyy hh:mm is accepted, but hh:mm is removed)
//
//	dateString:  		String to check for validity
//	dateFormatOut:		Required format of the date.
//							Combination of mm, mmm, dd, ccyy and .- or /
//
//	Assumptions:
//					One of DATE_DELIMITERS is used to split the fields
//					The same delimiter is used throughout (so no dd.mmm/yyyy)
//					For ambigous dates (eg 10/09/2003) we assume dd/mm/yyyy
//
//	Accepts:
//					dd/mm/ccyy			dd-mm-ccyy			dd.mm.ccyy		
//					mm/dd/ccyy			mm-dd-ccyy			mm.dd.ccyy
//					dd/mmm/ccyy			dd-mmm-ccyy			dd.mmm.ccyy
//					mmm/dd/ccyy			mmm-dd-ccyy			mmm.dd.ccyy
//
//					dd:			one or two digit day, 01 and 1 are both accepted
//					mm:			one or two digit month, 01 and 1 are both accepted
//					mmm:			3 letter month, jan, feb etc.
//					ccyy:			full year.
//
//	Returns:
//		Empty string if the given date, or date format, were invalid; otherwise, 
//		returns the given date formatted as requried.
//
//	toDo:
//
// Check that the supplied dateFormatOut is valid
//	Handle 3-letter or full day names?
//	Handle full month names?
//
//	Modification History:
//	27May03 AE  Now accepts date times; the time portion of the string is removed and the 
//					date parsed as usual.

var strDelimiter = new String();
var intCount = new Number();
var blnValid = true;
var astrDate = new Array();
var astrDateFormat = new Array();
var dtTemp = new Date();
var intDayField = new Number();
var intMonthField = new Number();
var strDateOut = new String();
var thisMonth = new String();
var thisDay = new String();
var thisYear = new String();
var intDaysintheMonth = 0;
var intLeapYear =1;

var debugstring = '';

	if (dateString.length > 11) {
		//Looks like we have some time information here; remove it
		//We may have "[date] [time]" or "[date]T[time]"...
		dateString = dateString.split('T').join(' ');
		dateString = dateString.substring(0, dateString.indexOf(' '));
	}

//Search for a delimiter; this is one of DateDelimiters
//Could do with RegExp?
	for (intCount=0; intCount < DATE_DELIMITERS.length; intCount++) {
		if (dateString.indexOf(DATE_DELIMITERS.charAt(intCount)) > -1) {
			//Found a delimiter
			strDelimiter = DATE_DELIMITERS.charAt(intCount);
			break;
		}			
	}

	if (strDelimiter.length > 0) {
		//Now split the string		
		astrDate = dateString.split(strDelimiter);
		if (astrDate.length != 3) {blnValid = false;}
	}
	else {
		blnValid = false;
	}

//Check each field for validity
	//Check first field:
	if (blnValid) {			
		//First field; dd, mm, or mmm
		if (astrDate[0].length < 3) {
			//Must be dd or mm, ie numeric
			if (!IsNumeric(astrDate[0])) {
				blnValid = false;	
debugstring += '1'				
			}
			
		}else {
			if (astrDate[0].length ==3) {
				//Must be mmm		
				if (IsValidMonth(astrDate[0])) {
					astrDateFormat[0] = 'mmm';
					intMonthField = 0;
				}	
				else {blnValid = false;debugstring += '2'}

			}
			else {blnValid = false;debugstring += '3'}
		}
	}

//Now the second
	if (blnValid) {
		//Now the second
		if (astrDateFormat[0] == 'mmm') {
			//We know that the second field must be dd
			if (IsNumeric(astrDate[1]) && astrDate[1].length <=2) {
				astrDateFormat[1] = 'dd';	
				intDayField = 1;
			}
			else {blnValid = false;debugstring += '4'}			
			
		}else {
			//We have either dd, mm, or mmm as the second field
			if (astrDate[1].length == 3) {
				//Should be mmm
				if (IsValidMonth(astrDate[1])) {
					astrDateFormat[1] = 'mmm';
					intMonthField = 1;
				}	
				else {blnValid = false;debugstring += '5'}			
				
			}
			else {
				//Either mm or dd
				if (IsNumeric(astrDate[1])) {
					//Determine whether this is mm or dd
					if (astrDateFormat[0] == 'mmm' ) {
						//First field is mmm or a number over 12, Must be dd
						if ( eval(astrDate[1]) > DaysInMonth(astrDate[0]) || eval(astrDate[1]) < 1 ) {
							blnValid = false;				
							debugstring += '6'
						}	
						else {
							astrDateFormat[1] = 'dd';
							intDayField = 1;
						}
					}
					else {
						//Check the first field
						if (eval(astrDate[0]) > 12) {
							//First one must be dd, second is mm.  Check that field 1 is valid
							intDaysintheMonth = DaysInMonth(astrDate[1]);
							if (intDaysintheMonth == 28){ 
							//Feb, so check the year
								intLeapYear = ((astrDate[2]) % 4);
								if (intLeapYear == 0){
								//Leap year
								intDaysintheMonth = 29;
								}
							}
							if ( eval(astrDate[0]) > intDaysintheMonth || eval(astrDate[0]) < 1 ) {
								blnValid = false;				
								debugstring += '7'
							}
							else {
								astrDateFormat[0] = 'dd';
								astrDateFormat[1] = 'mm';
								intDayField = 0;
								intMonthField = 1;
							}
						}
						else {
							//First field is <12, so could be a month or day...
							if (eval(astrDate[1]) > 12) {	
								//Second must be the day, check that it's valid
								if (eval(astrDate[1]) > DaysInMonth(astrDate[0]) || eval(astrDate[1]) < 1) {
									blnValid = false;
									debugstring += '8'				
								}
							}
							else {
								//Both fields are under 12.  Assume that the first field is dd, cos we're english.
								if (eval(astrDate[0]) > DaysInMonth(astrDate[1]) || eval(astrDate[0]) < 1) {
									blnValid = false;		
									debugstring += '9'
								}
								else {
									astrDateFormat[0] = 'dd';
									astrDateFormat[1] = 'mm';								
									intDayField = 0;
									intMonthField = 1;
								}
							}
						}	
					}
				}	
				else {				
					blnValid = false;
					debugstring += '10'
				}							
			}					
		}
	}

	if (blnValid) {
	//Finally, the century.  ALWAYS the 3rd field, ALWAYS 4 digits.
		if (astrDate[2].length != 4) {
			blnValid = false;
		}
		else {
			if (eval(astrDate[2]) < EARLIEST_YEAR) {
				blnValid = false;
			}	
			else {
				astrDateFormat[2] = 'ccyy';
			}
		}
	}

//Now format to the required output
	if (blnValid) {
		strDateOut = dateFormatOut.toLowerCase();

		//Get the day - format to dd, so 1 becomes 01
		thisDay = astrDate[intDayField];
		if (thisDay.length == 1) {thisDay = '0' + thisDay;}
		thisDay = thisDay.toString();

		//Get the month:
		if (dateFormatOut.indexOf('mmm') > -1) {
			//They want a 3 letter month...
			if (astrDateFormat[intMonthField] == 'mmm') {				
				//already have it:
				thisMonth = astrDate[intMonthField];
			}
			else {
				//Need to go find it				
				thisMonth = m_astrMonths[eval(astrDate[intMonthField]) - 1];		
			}
		}
		else {
			//We assume they want a 2-digit month then
			if (astrDateFormat[intMonthField] == 'mm') {
				//Just use the one they gave us
				thisMonth = astrDate[intMonthField];	
			}
			else {
				//Convert the 3-letter month into a digit.
				thisMonth = MonthNumberFromName(astrDate[intMonthField]);
			}
		}
		
		//Make sure that any numerical months are formatted with a leading 0 if required
		thisMonth = thisMonth.toString();		
		if (thisMonth.length == 1) {
			thisMonth = '0' + thisMonth;
		}

		//And finally the year
		thisYear = astrDate[2];
	
		//Now replace the format holders in the string with the actual values
		strDateOut = strDateOut.split('dd').join(thisDay);									// dd   => 01, 02 etc
		strDateOut = strDateOut.split('mmm').join(thisMonth);								//	mmm  => jan, feb etc
		strDateOut = strDateOut.split('mm').join(thisMonth);								//	mm	  => 01, 02 etc
		strDateOut = strDateOut.split('ccyy').join(thisYear);								// ccyy => 1999, 2003 etc
		strDateOut = strDateOut.split('yyyy').join(thisYear);								// yyyy => 1999, 2003 etc
		
	}
//if (debugstring != '') {alert(debugstring); }
	return strDateOut;
	
}

//===========================================================================
//16-Jan-2008  JA Error code 162 
//===========================================================================

function DateStringValid(dateString) {
//Returns true if the date string is valid, false if not
	return (ParseDate(dateString, 'dd-mm-ccyy') != '');
}
//=================================================================================
