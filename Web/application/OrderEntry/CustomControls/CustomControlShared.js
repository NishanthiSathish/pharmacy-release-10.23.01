//===================================================================================================
//
//										CustomControlShared.js
//
//		Shared client-side functions for custom controls.
//
//		FormatXML:				Used for building XML attribute nodes for returning from a custom control
//		GetValueFromXML:		Use to read the value for a given attribute from xml held in document.all['instanceData']
//		GetTextFromXML:		Use to read the text for a given attribute from xml held in document.all['instanceData']
//		SetListItemByDBID:	Use to set the item in a Select element by its database primary key.
//		IsVisible:				Determines if a span element is visible or hidden.
//		IncrementValue:		Increase the value in a control by a given amount.
//		GetFieldNumeric:		Returns the value from a field, nulls are returned as 0
//
//		Modification History:
//		29Jan04 AE  Created from procedures in Prescription.js and NurseAdmin.js
//		01Feb05 AE  Moved GetVisibilityString/GetDisplayString here from Prescription.js
//		03Oct05 AE  Added Get/SetMandatoryField
//      28Apr10 XN  F0056464 if lookups filtered out due to out_of_use and _deleted flags, then ensured 
//                  they are displayed for standard lookup
//===================================================================================================
//Constant used on OrderEntry for building frame names
var FORMID_PREFIX = 'orderForm';

//List o' fields which do not have their original value persisted
var FIELDS_NO_PERSIST = '[ASCDescription][Detail]';

//===================================================================================================
function FormatXML(columnName, enteredValue, enteredDescription, extraXMLAttributes) {

//Format the given data into an XML <attribute> element
//
//	columnName:				The name attribute is set to this value
//	enteredValue:			The value attribute is set to this value
//	enteredDescription:	(optional) The text attribute is set to this. 
//									typically an expansion of the value;  usually when value is a foreign key. 
//extraXMLAttributes:	(optional) Any extra xml in a string, in the form 'attribute="value" attribute2="value2"...'

//13Apr05 AE  Now persists original value

var originalValue = '';
var originalText = '';
var xmlElement;

//Find the original value of this field (ie that specified in the template).
	//If we are creating a new item from template, this will be the value from
	//the "value" column in the instanceData; otherwise, 
	//it has been stored in the value_orig field
	if (!m_blnTemplateMode){
		if (FIELDS_NO_PERSIST.indexOf('[' + columnName + ']') < 0){
			originalValue = GetOriginalValue(columnName);
		}	
	}
	
//Build the xml 
	var strReturn = '<attribute '
					  + 'name="' + columnName + '" '
					  + 'value="' + XMLEscape(enteredValue) + '" ';
	
	if (enteredDescription != undefined){
		strReturn += 'text="' + XMLEscape(enteredDescription) + '" ';
	}
					  
	if (extraXMLAttributes != undefined) {
		strReturn += extraXMLAttributes + ' ';
	}	
	
	strReturn += 'value_orig="' + XMLEscape(originalValue) + '" />';												//16Aug06 AE  #SC-06-0670
	
	return strReturn;
}

//===========================================================================

function GetValueFromXML(strColumnName) {

//Returns the value for this column, if any.

var returnVal = new String();

	var objItem = instanceData.XMLDocument.selectSingleNode('//data/attribute[@name="' + strColumnName + '"]');
	if (objItem != undefined) {
		returnVal = objItem.getAttribute('value');
	}

	return returnVal;
}

//===========================================================================

function GetTextFromXML(strColumnName) {

//Return the text for this column, if any
var returnVal = new String();

	var objItem = instanceData.XMLDocument.selectSingleNode('//data/attribute[@name="' + strColumnName + '"]');
	if (objItem != undefined) {
		returnVal = objItem.getAttribute('text');
	}
	return returnVal;

}

//=======================================================================================================================
function GetReadonlyStatusFromXML(strColumnName)
{
    var returnVal = 0;
	var objItem = instanceData.XMLDocument.selectSingleNode('//data/attribute[@name="' + strColumnName + '"]');
	if (objItem != undefined)
	{
        if(isNaN(objItem.getAttribute('readonly')))
	    {
	        if(objItem.getAttribute('readonly').toLowerCase() == "true")
	        {
	            returnVal = 1;
	        }
	    }
	    else
	    {
    	    returnVal = objItem.getAttribute('readonly');
	    }
	}
	return Number(returnVal);	
}

//=======================================================================================================================
function SetMandatoryStatus(strColumnName, blnMandatory){
	
	var objItem = instanceData.XMLDocument.selectSingleNode('//data/attribute[@name="' + strColumnName + '"]');
	if (objItem != undefined) {
		void objItem.setAttribute('mandatory', (blnMandatory ? '1' : '0') );
	}			
}

//=======================================================================================================================
function GetMandatoryStatusFromXML(strColumnName){

var returnVal = 0;

	var objItem = instanceData.XMLDocument.selectSingleNode('//data/attribute[@name="' + strColumnName + '"]');
	if (objItem != undefined) {
		returnVal = objItem.getAttribute('mandatory');
		if (returnVal == null) returnVal = 0;
	}
	return returnVal;
}

//=======================================================================================================================
function GetMandatoryAttribute(objControl){
	
	var strReturn = '';
	if (objControl.getAttribute('mandatory') != null) strReturn = 'mandatory="' + objControl.getAttribute('mandatory') + '"';
	return strReturn;
}
//=======================================================================================================================
function CreateChangeReportItemXML(strColumnName, strFieldID, currentValue){

//If this field has changed from its original(template) value, 
//return an xml element as a string to describe it:
//25Sep06 AE  Made case-insensetive for #SC-06-0873.  This is really only a temporary patch; what is needed
//				  is globally unique IDs, the problem we now have is that IDs and text are changed by DSS and there
//				  is no way to distinguish semantic from cosmetic changes.

	var strReturn = '';
	var originalValue = GetOriginalValue(strColumnName);
	if (originalValue != '' && trim(currentValue.toLowerCase()) != trim(originalValue.toLowerCase())){												//25Sep06 AE  Made case-insensetive #SC-06-0873
		strReturn = ChangeReportItemXML(strFieldID, originalValue, currentValue)
	}	
	return strReturn;
}

//===========================================================================
function ChangeReportItemXML(strFieldID, originalValue, currentValue, strExtraAttributes){
//		<f id='{strFieldID}' old="{originalValue}" new="{currentValue}" [strExtraAttributes] />	
	var strReturn = '<' + XML_ELMT_CHANGE + ' ' + ATTR_CHANGE_ID + '="' + strFieldID + '" '
					  + ATTR_CHANGE_ORIGINAL + '="' + originalValue + '" '
					  + ATTR_CHANGE_NEW + '="' + currentValue + '" ';
	if (typeof(strExtraAttributes) == 'string') strReturn += ' ' + strExtraAttributes + ' ';			  
	strReturn += '/>';
	return strReturn;
}

//===========================================================================
function GetOriginalValue(strColumnName){

//Retrieve the original value for this column.  Returns blank string if
//none found.
var strReturn = ''
var originalValue = '';

	var xmlElement = instanceData.XMLDocument.selectSingleNode('//data/attribute[@name="' + strColumnName + '"]');
	if (xmlElement != undefined){
		if (document.body.getAttribute('dataclass') == 'template'){
			
		//Creating a new item from template;
			originalValue = xmlElement.getAttribute('text');
			if (originalValue == null || originalValue == '' || originalValue == 'null' || originalValue == 'undefined'){
				originalValue = xmlElement.getAttribute('value');
			}
			// F0047361 23-03-09 PR Template data getting screwed. Has data in text attributes for fields with a 0 value (ie no data set)
			//						Returns 0 if text exists and value is 0
			else if (Number(xmlElement.getAttribute('value')) == 0)
			{
				originalValue = xmlElement.getAttribute('value');
			}
		}
		else
		{
		    //Editing item
		    //F0028537 ST  27Jan09
		    //We might be editing an item that has been copied/amended and therefore not come from a template
		    //so we need to do some additional checking of values here to see if anything has changed.
		    originalValue = xmlElement.getAttribute('text_orig');
		    if (originalValue == null || originalValue == '' || originalValue == 'null' || originalValue == 'undefined')
		    {
		        originalValue = xmlElement.getAttribute('text');
		        if (originalValue == null || originalValue == '' || originalValue == 'null' || originalValue == 'undefined')
		        {
		            originalValue = xmlElement.getAttribute('value_orig');
		            if (originalValue == null || originalValue == '' || originalValue == 'null' || originalValue == 'undefined')
		            {
		                originalValue = xmlElement.getAttribute('value');
		            }
		        }
			}
		}
	}
	if (originalValue != null && originalValue != '' && originalValue != 'null' && originalValue != 'undefined'){ 
		strReturn = originalValue;
	}

	return strReturn;	
}

//===========================================================================

function SetListItemByDBID(objList, dbID, strOptionToAddIfItemMissing) {

//Highlight the item in this list box with a
//dbID attribute matching the dbID given
//Returns if dbID was found in the list

var intCount = new Number();
var bFound = false;

	if (dbID == '') {dbID = 0;}

	for (intCount = 0; intCount < objList.options.length; intCount++ ) {
	    if (objList.options[intCount].getAttribute('dbid') == dbID) {
			//Found it
			objList.options[intCount].selected = true;
			bFound = true;
			break;
		}
    }

    // XN 28Apr10 F0056464 if lookup filtered out due to out_of_use and _deleted flags, then ensure displayed if already selected
    // If selected item is marked as deleted it may not be present in the list. 
    // Problermatic if control is readonly as the user can not correct the information so 
    // only way is to readd the information to the list and select it.
    if ((strOptionToAddIfItemMissing != undefined) && !bFound) 
    {
        var objOption = document.createElement("OPTION");
        objOption.text = strOptionToAddIfItemMissing;
        objOption.value = dbID;
        objList.add(objOption);
        objList.selectedIndex = objList.children.length - 1;    
    }
    // End of F0056464
	
	return bFound;
}
//===========================================================================
//05Jul11   Rams    7822 - F0122093 print 4 week profile
function SetListItemByDbIdReturnSelectedIndex(objList, dbId) {

    //Highlight the item in this list box with a
    //dbID attribute matching the dbID given
    //Returns if dbID was found in the list

    var intCount = new Number();
    var iselectedIndex = -1;
    
    
    if (dbId == '') { dbId = 0; }

    for (intCount = 0; intCount < objList.options.length; intCount++) {
        if (objList.options[intCount].getAttribute('dbid') == dbId) {
            //Found it
            objList.options[intCount].selected = true;
            iselectedIndex = intCount;
            break;
        }
    }
    
    return iselectedIndex;
}

function IsVisible(objElement) {
	
//Returns a boolean indicating if objElement is currently visible
	var blnVisible = true;
	
	if (objElement.currentStyle.display == 'none') {blnVisible = false};
	if (objElement.currentStyle.visibility == 'hidden') {blnVisible = false};

    return blnVisible;	
}
//===========================================================================

function IncrementValue(inputControl, incrementValue) {
	
//Incrememnt the value in inputControl by incrementValue	
	var numValue = GetFieldNumeric(inputControl);
	numValue = Number(numValue) + Number(incrementValue);
	if (numValue < 0) {numValue = 0};
	
	inputControl.value = numValue;
	
}
//===========================================================================

function GetFieldNumeric(inputControl) {

//Wrapper to return the value of a field, returning
//0 in place of null

	var numValue = inputControl.value;

	if ((numValue == null) || (numValue =='') || (numValue == 'null') ) {numValue = 0};
	return Number(numValue);
}

//==============================================================================
function UpdateOrderformMetadata(ocsType, ocsTypeID, tableID){

//Updates the metadata held on OrderEntry.aspx with the given information
//16Sep04 AE  Added

	//Get a reference to the XML element holding the metadata for this page	
	var frameID = formBody.getAttribute('frameid');
	var frameIndex = frameID.substring(FORMID_PREFIX.length);
	if (typeof(window.parent.parent.ordersXML)=="undefined")
	{
		var xmlItem = window.parent.ordersXML.XMLDocument.selectSingleNode('//item[@formindex="' + frameIndex + '"]');
	}
	else
	{
		var xmlItem = window.parent.ordersXML.XMLDocument.selectSingleNode('//item[@formindex="' + frameIndex + '"]');
	}

	//And update it
	void xmlItem.setAttribute('ocstype', ocsType);
	void xmlItem.setAttribute('ocstypeid', ocsTypeID);
	void xmlItem.setAttribute('tableid', tableID);
	
	//Also update the metadata on the OrderForm page(this page's immediate parent, as this is a control on the form)
	if (typeof(window.parent.layoutData)=="undefined")
	{
		xmlItem = layoutData.XMLDocument.selectSingleNode('xmldata/layout');
	}
	else
	{
		xmlItem = window.parent.layoutData.XMLDocument.selectSingleNode('xmldata/layout');
	}
	void xmlItem.setAttribute('tableid', tableID);
		
}
//=======================================================================================================================
function GetVisibilityString(blnVisible) {
	
//In-line function used from ShowStatControls
	if (blnVisible) {
		return 'visible';
	}
	else {
		return 'hidden';
	}
}

//=======================================================================================================================
function GetDisplayString(blnVisible) {
	
//In-line function used from ShowStatControls
	if (blnVisible) {
		return 'block';
	}
	else {
		return 'none';
	}
}
//=======================================================================================================================
function SetListItemByAttribute(objList, Attribute, value) {

//Highlight the item in this list box with a
//any attribute matching the value given
//Returns if value was found in the list and selects it.

var intCount = new Number();
var bFound = false;
    
    if (Attribute =='') 
        return bFound;	
        
	for (intCount=0; intCount < objList.options.length; intCount++ ) {
		if (objList.options[intCount].getAttribute(Attribute) != undefined && objList.options[intCount].getAttribute(Attribute ) == value) 
		{
			//Found it
			objList.options[intCount].selected = true;
			bFound = true;
			break;
		}
	}	
	
	return bFound;
}
