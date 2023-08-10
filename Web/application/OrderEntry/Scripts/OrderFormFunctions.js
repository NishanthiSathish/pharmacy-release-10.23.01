
/*
--------------------------------------------------------------------------------------

						ORDER FORM FUNCTIONS SCRIPT

	This script deals with the on-the fly configuration of the forms in response
	to user input. 
	It uses OrderFormClasses.js to provide abstraction from the actual HTML.
	The script also handles syncronising of identical data fields across a batch
	of fields, and scraping the data from a form ready for submission to the server.

	This page goes through some client-side initialisation routines upon loading.
	When these are complete, the page calls a method in the container called
	IndicateOrderFormReady().  
	The container should only attempt to manipulate the page once this method
	has been called.

	-----------------------------------------------------------------------------------
	Modification History:
	18Nov02 AE  Written
	03Jun02 AE  Modifications to use column names rather than control ids in the
					XML format used for loading and saving data.
	28Aug03 AE  Syncronise:Use SetValue instead of Populate, to ensure that dropdowns work properly
	04Sep03 AE  Added SetChanged(); now checks for edits, so you don't get asked "really cancel" if 
					you haven't changed anything.	
	27Oct03 AE  Syncronise: Added switch to fix checkbox and dropdowns
	30Apr04 AE  Added autopopulation of Date & Time fields when NOT in template mode.
				   Added support for Read-only fields
	26Jul04 AE  PopulateForm:  Date population now uses new DateControl class
	12Aug04 AE  PopulateForm:  Fix; prevents 12:05 appearing as 12:5 by adding leading zeros where appropriate.
	25Mar05 AE  Removed 800 lines of never-used code; this has been kept in OrderFormFunctions_Pickled.js 
					just in case.
    28Apr10 XN  F0056464 if lookups filtered out due to out_of_use and _deleted flags, then endure 
                they are displayed for standard lookup
--------------------------------------------------------------------------------------
*/

//Page-level variables:

//  Function collection and pointer for handling functions
//  asyncronously.
var m_colFunctions = new Object();
var m_currentFunction = -1;
var m_objControl=new Object();

var m_currentControlID = new Number(-1);
var m_blnIndicateWhenComplete = false;

//
var FORMID_PREFIX = 'orderForm';	


/*
--------------------------------------------------------------------------------

					INLINE CODE
					
					(function handlers etc.)

--------------------------------------------------------------------------------
*/

document.onreadystatechange=InitialiseWhenReady;

/*
--------------------------------------------------------------------------------

   				TOP-LEVEL FUNCTIONS:

function DoControlFunctions(objControlIn, blnDoSyncronise)				*** Not currently used ** 
function InitForm()
function PopulateForm(objData)
function GetDataFromForm()
*/

//-----------------------------------------------------------------------------
function SetChanged(blnChanged) {
//For subforms, we are the parent, and we need to pass this message on up to OrderForm.aspx, 
//which is the daddy.
	window.parent.SetChanged(blnChanged);
}
//-----------------------------------------------------------------------------
function FormFocus(frameID){
//For subforms, we are the parent, and we need to pass this message on up to OrderForm.aspx, 
//which is the daddy.	
	window.parent.FormFocus(frameID);
}
//-----------------------------------------------------------------------------

function InitialiseWhenReady() {

//This function waits until the document is
//fully loaded, then kicks off the initialisation
//process.  When this is completed, the container
//page is signalled that this page is ready.
//It is the top level function in the 
//initialisation procedure.

var intCount = new Number();
var blnAllReady = new Boolean();;

	if (document.readyState=='complete') {
		//Check that any frames on the page are
		//also ready
// 19Jul07 PH No need for this while loop
//		do {
			blnAllReady = true;

			for (intCount = 0; intCount<document.frames.length; intCount++) {
				if (document.frames[intCount].document.readyState != 'complete') {
					blnAllReady=false;
				}
			}
//		}
//		while (!blnAllReady);

		if (blnAllReady) 
		{
			InitForm();
		}
	}

}

//-----------------------------------------------------------------------------

function InitForm() {
	
//This function is called from the Document_onLoad event on the form.  It serves
//as a wrapper to PopulateForm; if any data is scripted onto the form, it
//calls PopulateForm.

//This function should not be called from outside this page.
	//Search for an XML island called instanceData
	try {
		var objDOM = instanceData.XMLDocument;
	}
	catch (err) {}
	
	if (objDOM != undefined) {
		//Found it
		var objData = objDOM.selectSingleNode('root/data');
		void PopulateForm(objData);
	}

	//Just signal that we're initialised														//25Mar05 AE  Moved outside of if (because of unused code removal)
	void SignalReady();
	
}


//-----------------------------------------------------------------------------------------

function PopulateForm(objData) {
		
//Enter the data specified in colAttributes into the layout

//This procedure works by recursing through each control on the form, then
//looking in the colAttributes to determine if there is any data for it.
//Although this is slower than the converse (itterating through colAttributes
//and assigning each value to the appropriate control) it is neccessary 
//since some of the controls may be on sub forms, but we have no way
//of knowing this up front.

//	objData: XML DOM Element containing one or more attribute elements:
//		<data>
//			<attribute id="xxx" value="yyy" />
//				'
//		</data>

var intCount = new Number();
var controlID = new String();
var objSpan = new Object();
var objInputElement = new Object();
var objControl = new Object();
var objTypedLookup = new Object();

var attributeValue = new String();
var objControl = new Object();
var objCustom = new Object();
var objHTMLControl = new Object();
var objForm = new Object();
var formID = new String();
var thisValue = new String();
var thisID = new String();
var thisTypeID = new String();
var thisTypeDescription = new String();
var thisText = new String();
var strHours = new String()
var strMinutes = new String()
var dtToday;

	for (intCount=0; intCount < formBody.all.length; intCount++) {
		objSpan = formBody.all[intCount];
		if (IsControl(objSpan)) {	
			//objSpan is a ControlSpan containing a number of
			//controls; one of which is the input control, 
			//OR a subform.

			//Get a reference to this control
			objInputElement = GetInputElementFromSpan(objSpan);

			if (objInputElement != null) {			
				//Found an input element.
				//See if we have a value for it in the XML
				thisValue = GetValueForControl(objData,objInputElement.getAttribute('columnname'), 'value');
				
				//Create a new OrderControl class and use it to 
				//populate the physical control with the data
				objControl = new OrderControl(objInputElement);	
				if (objControl.ControlType() == 'dropdown') {
					objTypedLookup = objControl.HTMLObject.all['lookuplabel'];
					if (objTypedLookup == undefined) {
						//List box - doesn't need populating, as it already
						//contains values; we want to set the selected row
					    objControl.SetValue(thisValue);

					    // XN 28Apr10 F0056464 if lookup filtered out due to out_of_use and _deleted flags, then ensure displayed if already selected
					    // If selected item is marked as deleted it may not be present in the list. 
					    // Problermatic if control is readonly as the user can not correct the information so 
					    // only way is to readd the information to the list and select it.
					    if ((objControl.HTMLObject.selectedIndex <= 0) && (SplitDataValue(thisValue) != 'null') && (SplitDataValue(thisValue) != '0'))
					    {
					        var objOption = document.createElement("OPTION");
					        var thisDescription = GetValueForControl(objData, objInputElement.getAttribute('columnname'), 'text');

					        objOption.text  = SplitDataValue(thisDescription);
					        objOption.value = SplitDataValue(thisValue);
					        objControl.HTMLObject.add(objOption);
					        objControl.HTMLObject.selectedIndex = objControl.HTMLObject.children.length - 1;
					    }
					    // End of F0056464
					}
					else {
						//Complex lookup; may have type information													//02Apr04 AE  Added lump for typed lookups.  Could have been neater, but my machine crashed and I'm in a hurry.
						void objTypedLookup.setAttribute ('valueid', SplitDataValue(thisValue));

						//Get the type and value IDs, if any						
						thisValue = GetValueForControl(objData,objInputElement.getAttribute('columnname'), 'text');							
						thisValue = SplitDataValue(thisValue);
						if (thisValue == '' && IsTemplateMode()) {
							thisValue = '<No Default>';
						}
						
						if (thisValue != 'null')
						    objTypedLookup.setAttribute ('valuedescription', thisValue);

						thisID = SplitDataValue(GetValueForControl(objData,objInputElement.getAttribute('columnname'), 'value'));
						thisTypeID = SplitDataValue(GetValueForControl(objData,objInputElement.getAttribute('columnname'), 'typeid'));
						if (thisTypeID == '' || thisTypeID == 'null') {thisTypeID = '0'};						
						if (thisID == '' || thisID == 'null') {thisID = '0'};						
						void objTypedLookup.setAttribute ('typeid', thisTypeID);
						void objTypedLookup.setAttribute ('valueid', thisID);

						//Get the description for the type, if any.  If we have a value, we don't display
						//the type
						if (Number(thisID) == 0) {
							thisTypeDescription = SplitDataValue(GetValueForControl(objData,objInputElement.getAttribute('columnname'), 'typedescription'));
							if (thisTypeDescription == 'null') {thisTypeDescription = '<Any Type>'};
						}						
							
						//Create the description for showing on screen; for typed lookups in template mode this is "type, lookup value"
						thisText = '';
						if (IsTemplateMode() ) {
							thisText = thisTypeDescription;
							if (thisText != '') {thisText += ','};
						}
						thisText += thisValue;
						objTypedLookup.innerText = thisText;

					}
				}
				else {
					//Populate the control.
					//If this is a date or time field, and we're NOT in template mode, and the field is empty, 
					//autopopulate with NOW.
					if ((objControl.IsDate() || objControl.IsTime()) && !IsTemplateMode()) {									//30Apr04 AE  Added Date population
						if (SplitDataValue(thisValue) == '') {
							dtToday = new Date();
							if (objControl.IsDate()) {
								var objDateControl = new DateControl(objInputElement);												//26Jul04 AE  New date handling			
								objDateControl.SetDate(dtToday);
								thisValue = '';
							}
							else {				
								strHours = dtToday.getHours().toString();																	//12Aug04 AE  Fix; prevents 12:05 appearing as 12:5
								if(strHours.length ==1) {strHours = '0' + strHours};
								strMinutes = dtToday.getMinutes().toString();
								if (strMinutes.length ==1) {strMinutes = '0' + strMinutes};
								thisValue +=  strHours + ':' + strMinutes;
							}
						}
					}
					if (thisValue != '') {
						//Populate it
						objControl.Populate(thisValue);					
					}
				}

			//Check the readonly status of this control and set appropriately.			//30Apr04 AE  Added support for Read-only fields
				bitReadOnly = SplitDataValue(GetValueForControl(objData,objInputElement.getAttribute('columnname'), ATTR_READONLY));						//03Oct06 AE Constantised attribute #SC-06-0797 
				if ((bitReadOnly == null) || (bitReadOnly == 'null')){bitReadOnly = 0};

				if (IsTemplateMode()) {
					var imgReadOnly = objSpan.all['imgReadOnly'];
					if (imgReadOnly != undefined) {
						void TemplateFieldReadOnlySet(imgReadOnly, bitReadOnly);	
					}
				}
				else {
					if (Number(bitReadOnly) == 1) {void SetReadOnlyByControlSpan(objSpan);}
				}

			}
			else {
				//We may have a subform.
				objSubForm = GetSubFormElementFromSpan(objSpan);
				if (objSubForm != null) {
					//Found a subform.  Populate all of its controls.
					void document.frames[objSubForm.id].PopulateForm(objData);

				}
				else  {
					//Or it could be a Custom Control
					objCustom = GetCustomControlElementFromSpan(objSpan);
					if (objCustom != null) {
						//Found one.  Populate it
						objControl = new OrderControl(objCustom);										
						void objControl.Populate(objData.xml);			
					}			
				}
			}
		}
	}
	//Now execute all client-side configuration functions
//  ** removed; never used, reinstate if this is ever implemented **
//	void DoAllControlFunctions();
	
}


//-----------------------------------------------------------------------------------------
function ValidityCheck(){

//Check that the data on the form passes any client-side validity checking. 
//Only custom controls will expose the CalidityCheck() method.
	
var objSpan = new Object();
var objSubForm = new Object();
var intCount = new Number();
var blnReturn = true;

	for (intCount=0; intCount < formBody.all.length; intCount++) {
		objSpan = formBody.all[intCount];

		if (IsControl(objSpan)) {	
			objCustom = GetCustomControlElementFromSpan(objSpan);
			if (objCustom != null) {
			//Found a custom control; check its ValidityCheck method.
				objControl = new OrderControl(objCustom);
				blnReturn = objControl.DataValid();
				if (!blnReturn) break;
			}
		}
	}
	return blnReturn;
	
}

//-----------------------------------------------------------------------------------------

function GetDataFromForm() {

//Read the data from this form, and all its
//sub forms, and return
//in an XML string as a series of attribute
//elements as follows:

//		<data filledin="true|false">
//			<attribute name="xxx" value="yyy" />
//		</data>

var returnXML = new String();
var thisValue = new String();
var thisExpansion = new String();
var thisTypeID = new String();
var thisTypeDescription = new String();
var thisType = new String();
var strReturn = new String();
var intPos = new Number();
var objSpan = new Object();
var objTypedLookup = new Object();
var objInputElement = new Object();
var objSubForm = new Object();
var objCustom = new Object();
var intCount = new Number();
var objControl;
var colInputControls = new Object();
var blnFilledIn = true;
var bitReadOnly = 0

	for (intCount=0; intCount < formBody.all.length; intCount++) {
		objSpan = formBody.all[intCount];
		if (IsControl(objSpan)) {	

			//objSpan is a ControlSpan containing a number of
			//controls; one of which is the input control, 
			//OR a subform.
			//Get a reference to this control	
			objInputElement = GetInputElementFromSpan(objSpan);

			if (objInputElement != null ) {				
				//Found an input element:
				//Create a new OrderControl class and use it to 
				//retrieve the data from the physical control.
				objControl = new OrderControl(objInputElement);
				strReturn = objControl.GetValue();
				
				//Strip off the valuetype indicator and escape any illegal XML characters
				thisValue = SplitDataValue(strReturn);
				thisValue = XMLEscape(thisValue);																					//17Apr03 AE  Added XMLEscape

				//Typed drop-downs may have extra attributes; include these here											//02Apr04 AE  Added code for typed lookups
				thisTypeID = '';
				thisTypeDescription = '';
				if (objControl.ControlType() == 'dropdown') {
					objTypedLookup = objControl.HTMLObject.all['lookuplabel'];
					if (objTypedLookup != undefined) {	
						thisTypeID = objTypedLookup.getAttribute('typeid');
						thisTypeDescription = objTypedLookup.getAttribute('typedescription');	
					}	
				}
				
				if(IsTemplateMode())
				{
					//In templates, we can mark fields as being read-only.  This is saved in a "readonly" attribute	//30Apr04 AE  Added support for read only fields
					bitReadOnly = 0;																											//10Aug05 AE  Modified to store flag on the image, not the span
					if (objSpan.all['imgReadOnly'] != undefined){
						bitReadOnly = objSpan.all['imgReadOnly'].getAttribute(ATTR_READONLY);								//03Oct06 AE Constantised attribute #SC-06-0797 
					}
				}
				else
				{
					bitReadOnly = 0;
					if(objInputElement.isDisabled == true)
					{
						bitReadOnly = 1;
					}
				}
				
				strReturn = objControl.GetValueExpanded();
				thisExpansion = SplitDataValue(strReturn);
				thisExpansion = XMLEscape(thisExpansion);
				returnXML += '<attribute ' 
								+ 'name="' + objControl.attributeName + '" '
								+ 'columnid="' + objControl.columnID + '" '
								+ 'value="' + thisValue + '" '
								+ 'text="' + thisExpansion + '" ' 																//06Apr04 AE  Added columnID
								+ 'readonly="' + bitReadOnly + '" ';															//30Apr04 AE  
				if (thisTypeID != '') {
					returnXML += 'typeid="' + thisTypeID + '" '
								  + 'typedescription="' + thisTypeDescription + '" ';
				}				
				returnXML += '/>';
																				
				//Check if this control is mandatory; if so, and it is
				//not filled in, then the form is marked as not filled in.
				if (objControl.Mandatory && !objControl.FilledIn()) {blnFilledIn = false;}

			}
			else {
				//We may have a subform.  Check for this:
				objSubForm = GetSubFormElementFromSpan(objSpan);
				if (objSubForm != null) {
					//Found a subform.  Include its data in this XML.
					returnXML += document.frames[objSubForm.id].GetDataFromForm();
				}
				else {
				//OR we may have a custom control
					objCustom = GetCustomControlElementFromSpan(objSpan);
					if (objCustom != null) {
						//Found one.  Read its data.						
						objControl = new OrderControl(objCustom);
						strReturn = objControl.GetValue()						
						if (strReturn=="ERROR")
							return strReturn;
						//
						thisType = SplitDataType(strReturn);
						thisValue = SplitDataValue(strReturn);
						
						//Now interpret the data
						switch (thisType) {
							case 'xml':
								//XML is returned in the correct format for inclusion in the string	
								returnXML += thisValue;		

								//Check if this is filled in; note that for custom controls, we are
								//assuming that they are always mandatory, since custom controls do
								//not expose a mandatory property.  I do not expect this to be a problem...yet
								blnFilledIn = objControl.FilledIn();				
								break;
						
							default:
								//Build up the attribute here
			 				  returnXML += '<attribute ' 
											+ 'id="' + objControl.attributeID + '" '
											+ 'name="' + objControl.attributeName + '" '
											+ 'value="' + thisValue + '" '
											+ '/>';								

								//Check if this control is mandatory; if so, and it is
								//not filled in, then the form is marked as not filled in.
								if (objControl.Mandatory && !objControl.FilledIn()) {blnFilledIn = false;}
								break;
						}
					}
				}	
			}
		}
	}

	returnXML = '<data ' 
				 + 'filledin="' + blnFilledIn + '" '
				 + '>'
				 + returnXML
 				 + ReasonCaptureXML()
				 + '</data>';
				 
	return returnXML;
	
}
//---------------------------------------------------------------------------------------
function ReasonCaptureXML(){

//Returns the contents of the reason capture field, if present.
var strReturn = new String();

	if(document.all['lstReason'] != undefined) {
		if (lstReason.options[lstReason.selectedIndex].value != null  && lstReason.options[lstReason.selectedIndex].value != 'other'){																		//04Nov05 AE  
			strReturn = '<' + XML_ELMT_REASON + ' '
						 + XML_ATTR_REASONID + '="' + lstReason.options[lstReason.selectedIndex].value + '" '
						 + XML_ATTR_REASONIDTEXT + '="' + lstReason.options[lstReason.selectedIndex].innerText + '" '
						 + XML_ATTR_REASONTYPE + '="' + lstReason.options[lstReason.selectedIndex].getAttribute(XML_ATTR_REASONTYPE) + '" '
						 + XML_ATTR_CAPTUREMODE + '="' + lstReason.getAttribute(XML_ATTR_CAPTUREMODE) + '" '
						 + ' />';
		}
	}	
	return strReturn;
}

//---------------------------------------------------------------------------------------

function IsTemplateMode() {

//Returns true if we are in template mode
	return (document.body.getAttribute('templatemode') == 'true');
}

/*
---------------------------------------------------------------------------------------

			INTERNAL FUNCTIONS

---------------------------------------------------------------------------------------
*/


//-----------------------------------------------------------------------------------------

function SignalReady() {

// Signal to the container that this form is now
//fully initialised.
//27Jan04 AE  Replaced try...catch with IF.  Means that you actually get
//				  error messages during the start up process if something goes wrong.
var intOrdinal = document.body.getAttribute("ordinal");
	if (window.parent.IndicateOrderFormReady != undefined) {
		void window.parent.IndicateOrderFormReady(intOrdinal);
	}

}


//-----------------------------------------------------------------------------------------

function GetValueForControl(objData, columnName, attributeName) {

//	Given a control ID and a collection of attribute data, 
//	finds the value to put in this control, if any.

//	objData: XML DOM Element containing one or mre attribute nodes:
//		<data>
//			<attribute name="xxx" value="yyy" />
//		</data>
//
//	columnID:  Name of the column; this should match to an attribute node's
//				  name field.  This will always be unique on a given form and
//				  its subforms, as each column in a virtual table is unique
//
//	Returns: string containing the value, or '' if no value
//				was found
//
//	02Apr04 AE  Added attributeName parameter
//
var intCount = new Number();
var strReturn = new String();

	//Now search the attributes for this item
	var objAttribute = objData.selectSingleNode('attribute[@name="' + columnName + '"]');
	if (objAttribute !== null) {
		strReturn = 'value=' + objAttribute.getAttribute(attributeName);
	}

	return strReturn;
	
}

//-----------------------------------------------------------------------------

function SplitDataValue(strData) {

//Given a string in the format DataType=DataValue(s), 
//returns the DataValue(s) part.
//If no '=' sign is found, the whole string is returned.
	
var strReturn = new String();

	var intPos = strData.indexOf('=');

	if (intPos > 0) {
		strReturn = strData.substring(intPos + 1, strData.length);
	}
	else {
		strReturn = strData;
	}	
	
	return strReturn;

}

//-----------------------------------------------------------------------------

function SplitDataType(strData) {

//Given a string in the format DataType=DataValue(s), 
//returns the DataType part in Lower Case.
//If no '=' sign is found, an empty string is returned.

var strReturn = new String();
var strDataString = new String();

	var intPos = strData.indexOf('=');
	if (intPos > 0) {
		strReturn = strData.substring(0, intPos);		
		strReturn = strReturn.toLowerCase();
	}

	return strReturn;
	
}
