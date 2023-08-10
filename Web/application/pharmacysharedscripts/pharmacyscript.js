/*

pharmactscript.js


Provides pharmacy helper functions, there include the following functions

Mark if page has changed
------------------------
On form load call InitIsPageDirty(); then whenever user enters text, or click checkbox, form will be marked dirty.
To test this call this.isPageDirty which will be set to true.
Once page has been saved the call clearIsPageDirty(); to clear this flag.
Need jquery libaray to make this work

String format function
----------------------
Provides a very basic string format function a bit like C#
so format('Hello {0}!!', 'Fred') returns 'Hello Fred!!'
Does NOT provide any formatters e.g. {0:##}

Enhanced alert box
------------------
Provides a nicer jquery ui message box with OK button
To use alertEnh('Hi there<br />How are you doing.');

Boolean parser
--------------
Parse string to bool accepts string of '1', 'T', 'Yes', 'true', etc
e.g. parseBoolean('TRUE') return true
If can't convert then return undefined

Replace string
--------------
Simple replace string functions, same as ICW one, but implemented here
to prevent dependancy on icw
e.g. ReplaceString('Helllo there', 'Helllo', 'Hello')

XML & Java escape or unescape
-----------------------------
Unescape string escaped with server side string.JavaStringEscape
    JavaStringUnescape(serverStr);
Unescape XLM escaped with server side string.XMLEscape
    XMLUnescape(serverStr);    
Escape XLM with 
    XMLEscape(str)
Escape url with does not require unescaping on server
    URLEscape(str)    

PostServerMessage
-----------------
Added PostServerMessage method

ConvertTableToCSV
-----------------
Takes a table and converts it to a CSV string

isBarcode
---------
Returns if string is a barcode (8 or 13 chars all digits)

debounce
--------
Calling debounceAll(); on page load will debounce all button clicks on your page (is save to call on multiple page loads)


getICWSetting
-------------
Allows getting and ICW setting by providing system.section.key details
*/

/*

Function for check if form has been changed

*/
var isPageDirty = false;

function InitIsPageDirty()
{
    isPageDirty = false;
    RegisterControlsWithIsPageDirty();
}

function RegisterControlsWithIsPageDirty()
{
    // Use delegate as will update any controls added by postback or other means
    $(document).delegate('input[type="text"]',    'change',function() { isPageDirty = true; });
    $(document).delegate('input[type="password"]','change',function() { isPageDirty = true; });
    $(document).delegate('textarea',              'change',function() { isPageDirty = true; });
    $(document).delegate('input[type="checkbox"]','change',function() { isPageDirty = true; });
    $(document).delegate('input[type="radio"]',   'change',function() { isPageDirty = true; });
    $(document).delegate('select',                'change',function() { isPageDirty = true; });
}

function setIsPageDirty()
{
    isPageDirty = true;
}

function clearIsPageDirty()
{
    isPageDirty = false;
}

// Extension method to the string class
// Allowed to do a string.format function
// usage format("Hi there {0}", "Fred");
// outputs "Hi there Fred"
function format(formatString)
{
    var formatted = formatString;
    for (var arg = 1; arg < arguments.length; arg++)
        formatted = formatted.replace("{" + (arg - 1).toString() + "}", arguments[arg]);
    return formatted;
}

// Provides a nicer alert message (uses jquery ui message box)
// To use this method you need to include 'jquery-ui-1.10.3.redmond.css', and 'jquery-1.6.4.min.js', and 'jquery-ui-1.10.3.min.js' files in your asp.net page
// okfunction defines the funciton to call when form closes
function alertEnh(message, okfunction,width)
{
    var tempDiv = '<div style="font-size:11px">' + message + '</div>';
    $(tempDiv).dialog(
        {
		    modal: true,
    	    buttons: 
    	    {
    	        //'Ok': function() { if (okfunction!=undefined) { okfunction(); }; $(this).dialog("destroy"); } // 24Jul13 XN 24653 Replace "close" with "destroy"
    	        //'Ok': function() { $(this).dialog("destroy"); if (okfunction!=undefined) { okfunction(); };  }  // 30Oct14 XN 102838 Better at setting focus to parent if close dialog first
                'OK': function() { $(this).dialog("destroy"); if (okfunction!=undefined) { okfunction(); };  }  // 21Jan15 XN 108123 Changed to OK
	        },
            open: function(type, data)
            {
                $(this).dialog('option', 'position', 'center');
            },
            title: 'Emis Health',
            closeOnEscape: true,
	        draggable: false,
	        resizable: false,
            width: width,
            zIndex: 9002  // To put it in front of popup
        });
}


// Provides a nicer confirm message (uses jquery ui message box)
// To use this method you need to include 'jquery-ui-1.8.17.redmond.css', and 'jquery-1.4.3.min.js', and 'jquery-ui-1.8.17.min.js' files in your asp.net page
// If user presses 'Yes' executes yesFunction, if no executes noFunction
function confirmEnh(message, defaultYes, yesFunction, noFunction,width)
{
    var tempDiv = '<div style="font-size:11px">' + message + '</div>';
    $(tempDiv).dialog(
        {
            modal: true,
            buttons:
    	    {
    	        //'Yes': function() { if (yesFunction!=undefined) { yesFunction(); }; $(this).dialog("destroy"); },    // 24Jul13 XN 24653 Replace "close" with "destroy"
    	        //'No' : function() { if (noFunction !=undefined) { noFunction();  }; $(this).dialog("destroy"); }     // 24Jul13 XN 24653 Replace "close" with "destroy"
    	        'Yes': function() { $(this).dialog("destroy"); if (yesFunction!=undefined) { yesFunction(); }; },    // 30Oct14 XN 102838 Better at setting focus to parent if close dialog first
    	        'No' : function() { $(this).dialog("destroy"); if (noFunction !=undefined) { noFunction();  }; }     // 30Oct14 XN 102838 Better at setting focus to parent if close dialog first
    	    },
            title: 'Emis Health',
            focus: function(type, data) { $(this).siblings('.ui-dialog-buttonpane').find('button:eq(' + (defaultYes ? '0' : '1') + ')').focus(); },
            closeOnEscape: true,
            draggable: false,
            resizable: false,
            appendTo: 'form',
            width: width
        });
}


// shows the pharmacy Confirm.aspx page with yes and no buttons (return true if yes, and false for no)
// message          - text message to display (non HTML)
// defaultYes       - if to default to Yes or No
// escapeReturnValue- value to return if user escape out
// Added 24Jul15 XN 114905
function confirmPharmYesNo(message, defaultYes, escapeReturnValue)
{
    var ulr = '../pharmacysharedscripts/Confirm.aspx';
    ulr += '?Msg=' + message;
    ulr += '&DefaultButton=' + (defaultYes ? 'Ok' : 'Cancel');
    ulr += '&EscapeReturnValue=' + escapeReturnValue;
    ulr += '&OkText=Yes';
    ulr += '&CancelText=No';
    return window.showModalDialog(ulr);
}

// Returns the parameters part of the current page's URL
// e.g. if current page is http://localhost/ICW_Trunk/application/PNViewAndAdjust/ICW_PNViewAndAdjust.aspx?SessionID=4366&WindowID=1728&Description=&AscribeSiteNumber=503&SelectEpisode=False&SelectRequest=False
// method will return ?SessionID=4366&WindowID=1728&Description=&AscribeSiteNumber=503&SelectEpisode=False&SelectRequest=False
function getURLParameters() 
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var intEndPos     = strURL.indexOf('#');
    if (intEndPos < 0)
        intEndPos = strURL.length;

    return strURL.substring(intSplitIndex, intEndPos);
}

// Returns the value of the URL parameter 124812
// e.g. if current page is http://localhost/ICW_Trunk/application/PNViewAndAdjust/ICW_PNViewAndAdjust.aspx?SessionID=4366&WindowID=1728&Description=&AscribeSiteNumber=503&SelectEpisode=False&SelectRequest=False
// If select sessionID the method return 4366 
// returns undefined if parameter does not exist in the URL
function getURLParameter(paramName) 
{
    var strURL = document.URL;
    
    // Get start position of the parameter
    var intStartPos = strURL.indexOf('&' + paramName + '=');
    if (intStartPos < 0)
        intStartPos = strURL.indexOf('?' + paramName + '=');
    if (intStartPos < 0)
        return undefined;
    intStartPos = intStartPos + paramName.length + 2;

    // Get end position of the parameter
    var intEndPos = strURL.indexOf('&', intStartPos);
    if (intEndPos < 0)
        intEndPos = strURL.length;

    return strURL.substring(intStartPos, intEndPos);
}

// Parses the a bool value
function parseBoolean(string) 
{
  switch (String(string).toLowerCase()) 
  {
  case "true"   :
  case "1"      :
  case "yes"    :
  case "y"      : return true;
  case "false"  :
  case "0"      :
  case "no"     :
  case "n"      : return false;
  default:        return undefined;
  }
}

// Replace all occurense of str2 in str1, with str3
function ReplaceString(str1, str2, str3) 
{
    return str1.split(str2).join(str3);
}

// Unescape string that was escaped with server side function string.JavaStringEscape
function JavaStringUnescape(strEscaped) 
{
	var strUnescape = new String(strEscaped);
	strUnescape = ReplaceString(strUnescape, '\\n',     '\n');
	strUnescape = ReplaceString(strUnescape, '\\r',     '\r');
	strUnescape = ReplaceString(strUnescape, '&slash;', '\\');
	//return strEscaped;    Fix 14Apr16 XN 123082
    return strUnescape;
}

//Escapes the given string according to the XML syntax.
//29May13 XN 27038
function XMLEscape(strUnescaped_XML) 
{
    var strReturn_XML = new String(strUnescaped_XML);
    strReturn_XML = ReplaceString(strReturn_XML, '&', '&amp;');
    strReturn_XML = ReplaceString(strReturn_XML, '"', '&quot;');
    strReturn_XML = ReplaceString(strReturn_XML, "'", '&apos;');
    strReturn_XML = ReplaceString(strReturn_XML, '<', '&lt;');
    strReturn_XML = ReplaceString(strReturn_XML, '>', '&gt;');
    strReturn_XML = ReplaceString(strReturn_XML, '/', '&#47;');

    return strReturn_XML;

}

// Unescape string that was escaped with server side function string.XMLEscape
function XMLUnescape(strEscaped_XML) 
{
    var strReturn_XML = new String(strEscaped_XML);
    strReturn_XML = ReplaceString(strReturn_XML, '&quot;', '"');
    strReturn_XML = ReplaceString(strReturn_XML, '&lt;',   '<');
    strReturn_XML = ReplaceString(strReturn_XML, '&gt;',   '>');
    strReturn_XML = ReplaceString(strReturn_XML, '&#47;',   '/');
    strReturn_XML = ReplaceString(strReturn_XML, '&amp;',   '&');
    strReturn_XML = ReplaceString(strReturn_XML, '&apos;',  "'"); // seems to work have this after the &amp;
    strReturn_XML = ReplaceString(strReturn_XML, '&#39;',   "'"); // seems to work have this after the &amp;
    return strReturn_XML;
}

function URLEscape(strURL) 
{
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
	strURL = ReplaceString(strURL, "'", '%27');
	strURL = ReplaceString(strURL, ';', '%3B');
	strURL = ReplaceString(strURL, '/', '%2F');
	strURL = ReplaceString(strURL, '?', '%3F');
	strURL = ReplaceString(strURL, ':', '%3A');
	strURL = ReplaceString(strURL, '@', '%40');
	strURL = ReplaceString(strURL, '=', '%3D');
	strURL = ReplaceString(strURL, '&', '%26');
	strURL = ReplaceString(strURL, '$', '%24');
	strURL = ReplaceString(strURL, '+', '%2B');				//09Feb06 AE  Added +
    strURL = ReplaceString(strURL, '¦', '%C2%A6');
	
	return strURL;
}

// jquery ajax server call
function PostServerMessage(url, data, async, asyncMethod)
{
    var result;
    $.ajax({
        type: "POST",
        url: url,
        data: data,
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        async:  (async == undefined) ? false : async,
        success: function(msg) 
        {
            if (async == true && asyncMethod != undefined)
                asyncMethod(msg);
            else
                result = msg;
        },
        error: function(jqXHR, textStatus, errorThrown) 
        {
            if (textStatus == 'error' ) 
            {
                if (jqXHR.responseText != undefined)
                    alertEnh(jqXHR.responseText);
                else if (errorThrown.message != undefined)
                    alert('Failed due to error\r\n\r\n' + errorThrown.message);
                else
                    alert('Failed due to error.');
            }
        }
    });
    return result;
}

// Converts at tale to CSV string
// format the CSV suitable for Excel so that
//      " replaced with ""
//      if field contains coma field wrapped in double quotes
// 29May13 XN 27038
// 27Oct14 XN 84572 Pass in jquery table rather than name, 
//                  Also got the method to handle colspan.
function ConvertTableToCSV(table, separatorChar) 
{
    var gridStr = '';
    var cr      = String.fromCharCode(13);

    if (separatorChar == undefined)
        separatorChar = ",";

    // Split up the table into rows, the columns
    // var allRows = $('#' + tableID  + ' tr'); 27Oct14 XN 84572 Pass in jquery table rather than name, 
    var allRows = $('tr', table);
    $.each(allRows, function() 
    {
        $.each($('th,td', this), function() 
        {
            var field = ReplaceString($(this).text(), '"', '""');   // Escape double quotes
            if (field.indexOf(',') >= 0 || field.indexOf(cr) >= 0)
                field = '"' + field + '"';                          // If string contain , or cr then wrap in quotes
            // gridStr += field + separatorChar;    27Oct14 XN 84572
            gridStr += field;

            //  Also got the method to handle colspan. 27Oct14 XN 84572
            var colSpan = $(this).attr('colspan');
            var cols = (colSpan == '') ? 1 : parseInt(colSpan);
            for (var c = 0; c < cols; c++)
                gridStr += separatorChar;
        });
        gridStr += cr;
    });

    // Replace HTML spaces, and br with spaces
    gridStr = ReplaceString(gridStr, '&nbsp;',  ' ' );
    gridStr = ReplaceString(gridStr, '<BR>',    ' ' );
    gridStr = ReplaceString(gridStr, 'Â',       ''  );   // Odd char that appears before the £ when imported in Excel

    return gridStr;
}

// Sets the height and width of the dialog, and positions it in the centre of the current screen
// seems to work better if set dialog to centre when call showModalDialog e.g. window.showModalDialog(..., ..., 'center:yes; status:off');
function SizeAndCentreWindow(width, height) 
{
    var isEMUnits = window.dialogHeight.indexOf('em') >= 0;

    var dialogLeft = parseInt(window.dialogLeft);
    var dialogTop  = parseInt(window.dialogTop );

    window.dialogHeight = height;
    window.dialogWidth  = width;

    var screenOffsetX = (dialogLeft > screen.width ) ? screen.width  : 0;   // Works out the left most position of the screen (for dual monitors)
    var screenOffsetY = (dialogTop  > screen.height) ? screen.height : 0;

    var newLeft = (screen.width  - parseInt(width )) / 2;
    var newTop  = (screen.height - parseInt(height)) / 2;

    if (isEMUnits)
        window.moveBy(newLeft - dialogLeft, newTop - dialogTop);    // Seems to work better using moveBy if have em units
    else 
    {
        window.dialogLeft = (screenOffsetX + newLeft) + "px";
        window.dialogTop  = (screenOffsetY + newTop) + "px";
    }
}

// Converts date time to pharmacy format date time dd/MM/yyyy HH:mm
function toPharmacyDateTimeString(datetime)
{
    var date  = datetime.getDate().toString();
    var month = (datetime.getMonth() + 1).toString();
    var year  = datetime.getFullYear().toString();
    var hour  = datetime.getHours().toString();
    var min   = datetime.getMinutes().toString();

    if (date.length < 2)
        date = '0' + date;
    if (month.length < 2)
        month = '0' + month;
    if (hour.length < 2)
        hour = '0' + hour;
    if (min.length < 2)
        min = '0' + min;

    return date + '/' + month + '/' + year + ' ' + hour + ':' + min;
}

// Puts the position of the caret at the end of the control
// Will also give the control focus
function moveCaretToEnd(input)
{
    if(input.setSelectionRange)
    {
        input.focus();
        var length = input.value.length;
        input.setSelectionRange(length, length);
    }
    else if(input.createTextRange)
    {
        var range = input.createTextRange();
        range.collapse(false);

        // In try catch as gives javascript access violation crash for no particular reason XN 22Mar16 99381
        try
        {
            range.select();
        }
        catch (e)
        { }
    }

    input.focus();
}

// Converts list to a string each elements separated by separator
// Will call toString for each item in the list
function toCSV(list, separator)
{
    var result = '';
    for(var c = 0; c < list.length; c++)
        result += list[c].toString() + separator;

    if (result.length >= separator.length)
        result = result.substr(0, result.length - separator.length);

    return result;
}

// Return urlParameters with parameter name and value replacing an existing one or added to the end
// Assumes that urlParameters is just the list of parameters (starting with ?)
function queryAddOrReplace(urlParameters, name, value)
{
    var nameLowerCase =  name.toLowerCase()

    var variables = urlParameters.substring(1, urlParameters.length - 1).split('&');
    for (var v = 0; v < variables.length; v++)
    {
        if (variables[v].split('=')[0].toLowerCase() == nameLowerCase)
        {
            // found existing so repalace (or add to end)
            variables[v] = name + '=' + value;
            return '?' + toCSV(variables, '&');
        }
    }

    // Add to end
    return urlParameters + '&' + name + '=' + value;
}

// returns true if text represents a barcode (8 or 13 chars all digits)
function isBarcode(text) 
{
    return (text.length == 8 || text.length == 13) && (/^\d+$/.test(text));
}

// will debounce click events in all 
//  input[type=button]
//  input[type=submit]
// in current page
// Only call once on page load (is save to call on multiple page loads)
// 1Jul15 XN 39882
function debounceAll()
{   
    $(document).undelegate('input[type=button]', 'click', debounce);
    $(document).delegate('input[type=button]', 'click', debounce);
    $(document).undelegate('input[type=submit]', 'click', debounce);
    $(document).delegate('input[type=submit]', 'click', debounce);
}

// debounces an event (decounce time is 300ms)
// Normally just uses debounceAll but this method allows you to call for individual items
// e.g.     $(document).undelegate('input[type=checkbox]', 'click', debounce);
// 1Jul15 XN 39882
function debounce(e)
{
    var elem = $(this);
    var nowTicks = new Date().getTime();

    var bounceStartTime = elem.attr('bounceStartTime');
    if (bounceStartTime == undefined || bounceStartTime == '')
        elem.attr('bounceStartTime', nowTicks);
    else if ((nowTicks - bounceStartTime) < 300)
    {
        elem.attr('bounceStartTime', nowTicks);
        e.preventDefault();
        e.stopPropagation();
    }
    else
        elem.removeAttr('bounceStartTime');
}

// Returns the ICW setting table value 22Jan16 XN 124812
// TODO: Needs improving to use web method rather than full aspx page call
function getICWSetting(system, section, key, defaultValue) 
{
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    var strURL = '../sharedscripts/SettingRead.aspx'
			          + '?SessionID=' + getURLParameter('SessionID');
			          + '&System='    + system
			          + '&Section='   + section
			          + '&Key='       + key;
    objHTTPRequest.open("POST", strURL, false); //false = syncronous                              
    objHTTPRequest.send("");
    return (objHTTPRequest.responseText == undefined) ? defaultValue : objHTTPRequest.responseText;
}

// Used by PharmacyInterface.cs
// Will save an interface file to the network
// tempFilename     - temp name used to save the file
// filename         - final file name to use
// hiddenFieldName  - name of the hidden field where the content of the file is save on the page (field is removed at end of method)
// 17Aug16 XN  Fixed issue with allowing to work with hosted file 160358
function saveInterfaceFile(tempFilename, filename, hiddenFieldName)
{
    var hiddenField = $('input[id^=' + hiddenFieldName + ']');
    try
    {
        var fso = new ActiveXObject('Scripting.FileSystemObject');

        // Delete existing temp file
        if (fso.FileExists(tempFilename))
            fso.DeleteFile(tempFilename);
    
        // save the temp file
        var file = fso.CreateTextFile(tempFilename, true, false);
        file.Write(hiddenField.val());
        file.close();

        // if file does not exist then rename temp file to existing filename
        if (!fso.FileExists(filename))
            fso.MoveFile(tempFilename, filename);

        // error if failed to save
        if (!fso.FileExists(filename))
            alert('Failed to create interface file ' + filename);
    }
    finally
    {
        hiddenField.remove();
    }
}