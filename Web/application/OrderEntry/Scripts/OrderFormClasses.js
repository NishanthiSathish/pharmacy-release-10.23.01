/*
------------------------------------------------------------------------------------------------

					ORDERFORMCLASSES.JS

	Class Definitions for Order Form Controls

	These classes provide abstracted methods for working with 
 	the actual HTML controls, hiding the complexity of 
 	sub forms etc.

	------------------------------------------------------------
	Modification History:
	18Nov02 AE  Written
	21Feb03 AE  Added Mandatory and FilledIn functions
	02Jun03 AE  WriteDataToControl:  Check boxes now recognise "true" and "1" as checked.
	03Jun03 AE  Removed method attributeID from OrderControl; attributeName is now used throughout
	09Sep03 AE  Added GetTextFromControl method to return the description of lookups.
	02Apr04 AE  Added code for long lookups, and for typed lookups.
	30Apr04 AE  Added IsDate() and IsTime()
	10Aug04 AE  Added proper date handling, using the DateControl class
	04Oct04 AE  Added ControlDataValid()
------------------------------------------------------------------------------------------------
*/


//Tokens used as string delimiters
var constValueToken='value';
var constListToken='list';
var constTextToken='text';

//----------------------------------------------------------------------------------------------------------------------------------
// Control class: represents a control and allows
// access to its methods and values.
function OrderControl(HTMLDomElement) {

	if (HTMLDomElement!=null) {
	
		this.controlID = HTMLDomElement.getAttribute('id');
		
		this.HTMLObject = HTMLDomElement;
		this.attributeName = this.HTMLObject.getAttribute('columnname');	
		this.columnID = this.HTMLObject.getAttribute('ColumnID');								//05Apr04 AE  Added
		this.Mandatory = (this.HTMLObject.className == 'MandatoryField');
		
		this.ControlType = GetControlType;								//Function to interpret and return the control type	
		this.Functions = ConfiguredFunctions;							//Function to return the XML Functions attached to this control
		this.Populate = WriteDataToControl;								//Function to populate a control with data.  Use with Order Form functions.
		this.SetValue = SetControlValue									//Same as Populate, except that for list controls, selects the item 
																					//rather than populating the list.  Use when populating a form with data.
		this.GetValue = GetValueFromControl;							//Function to read data from a control.  Format is: 'valuetype=values'
		this.GetValueExpanded = GetTextFromControl;					//Reads the expanded value from a control.  Mainly for use with Lookups, where the value is a primary key, this will return the description
																					//where valuetype is one of: 'value=', 'list='
		
		this.FilledIn = ControlFilledIn;									//Returns TRUE if each mandatory field in the form contains valid data.
		this.DataValid = ControlDataValid;								//Returns true if the data in the form is valid; for goes beyond FilledIn; FilledIn will always be true if this is true, but FilledIn can be true and this can be falsed.
		this.SetEnabled = SetControlEnabled;							//Function to enable or disable a control;																				
		this.IsDate = ControlIsDate;										//Returns true if this is a Date control.
		this.IsTime = ControlIsTime;										//Returns true if this is a time control.
	}

}

//Methods--------------------------------------------------------------------------------------------------------------------------

function ConfiguredFunctions() {
//returns the XML functions attacthed to this
//control as an XML DOM NodeList.

var colFunctions;
var intCount = new Number();
var strTagName = new String();
var objDOM = null;

	var objControl = this.HTMLObject; 

	for (intCount=0; intCount < objControl.parentElement.all.length; intCount++) {
		strTagName = objControl.parentElement.all[intCount].tagName;
		strTagName = strTagName.toLowerCase();
		if (strTagName == 'xml') {
			//Found an xml element; this holds the functions
			objDOM = objControl.parentElement.all[intCount];
			break;
		}
	}

	if (objDOM != null) {
		//Return the functions tag
		colFunctions = objDOM.XMLDocument.selectNodes('xmldata/function')	;
		return colFunctions;
	}
	else {
		//No functions found
		return null;
	}
}	

//-----------------------------------------------------------------------------

function GetValueFromControl(methodName) {

//Return a value from the control, using the 
//method specified in methodName

var varReturn=null;
var strMask = '';

	if (methodName==undefined) {
	//Use default method if not specified.
		methodName='value';
	}
	var strType = this.ControlType();
	
	switch (methodName.toLowerCase()) {
		case 'value':
			//Standard .value method	
			switch (strType) {
				case 'textarea':
				//Same as for a text input element...drop down to the clause below					
				case 'text':
					//Check if this is a date box; if so, use the datecontrol to retrieve the date in Tdate format
					strMask = this.HTMLObject.getAttribute('validchars');												//10Aug04 AE  Added proper date handling
					if (strMask.indexOf('DATE') != -1) {
						var objDateControl = new DateControl(this.HTMLObject);
						varReturn = constValueToken  + '=' +  objDateControl.GetTDate();	
					}
					else {
						varReturn = constValueToken  + '=' +  this.HTMLObject.value;
					}
					break;
					
				case 'checkbox':
					varReturn = constValueToken  + '=' +  this.HTMLObject.checked;
					break;
					
				case 'dropdown':			
					varReturn = GetValueFromControl_DropDown(this.HTMLObject);
					break;
					
				case 'custom':
					//Custom control; the control itself specifies the token (the 
					//part before the '='; some may return a single value, others
					//a whole set of different values as XML
					varReturn = document.frames[this.controlID].GetData();
					break;

			}
			break;

		default:
			// Custom method.  The custom control
			// will add the 'valuetype=' token as appropriate
			alert('get custom value not implemented');
	//		this.HTMLObject.GetCustomValue(methodName);
			
	}

	return varReturn;
	
}

//-----------------------------------------------------------------------------

function GetValueFromControl_DropDown(objTarget) {

//Obtain the value from a drop down; now complicated as large lookups cause
//different controls to be scripted.

var varReturn = new String();

	if (objTarget.tagName.toLowerCase() == 'select') {
	//Ordinary select element	
		if (objTarget.selectedIndex > -1 && objTarget.options[objTarget.selectedIndex].value!=-1 ) { // 03Sep04 PH Added extra checking for nullable dropdowns
			varReturn = constValueToken  + '=' +  objTarget.options[objTarget.selectedIndex].value;			//27Aug03 Corrected; now only looks for the option element if one is selected
		}
		else {
			varReturn = constValueToken  + '=null';
		}																			//19Aug03 AE 					
	}
	else {
	//Complex lookup; contains a table with a label and button.  The label
	//(first cell) holds the important information
		var objLabel = objTarget.all['lookuplabel'];
		varReturn = constValueToken + '=' + objLabel.getAttribute('valueid');	
	}
	
	return varReturn;
	
}
//-----------------------------------------------------------------------------

function GetTextFromControl() {
	
//Returns the text from a drop down control, as opposed to the value which would be a primary key.

var varReturn = new String();

	var strType = this.ControlType();

	if (strType == 'dropdown') {
	
		if (this.HTMLObject.tagName.toLowerCase() == 'select') {
		//Simple select box
			if (this.HTMLObject.selectedIndex > -1) {			
				varReturn = this.HTMLObject.options[this.HTMLObject.selectedIndex].text;			
			}
		}
		else {
		//Complex lookup
			var objLabel = this.HTMLObject.all['lookuplabel'];
			varReturn = objLabel.getAttribute('valuedescription');
			//04Sep09   Rams    F0062235 - Lookup fields tends to lose information selected as default.
			//                  Try to get the information from innerText as it will have the selected text.
			if (varReturn == null || varReturn == undefined)
			    varReturn = objLabel.getAttribute('innerText');
		}
	}	
	return (constTextToken + '=' + varReturn);

}

//-----------------------------------------------------------------------------

function GetControlType() {
	
//Return a string indicating the control type as follows:
//	textarea
//	textbox
//	checkbox
//						datebox / timebox - need doing
//	dropdown
// button
//	custom

var strTagName = new String();
var strType = new String();


	strTagName = this.HTMLObject.tagName;
	strTagName = strTagName.toLowerCase();

	switch (strTagName) {
		case 'textarea':
			strType = 'textarea';
			break;
			
		case 'select':
			strType = 'dropdown';
			break;
			
		case 'table':
			strType = 'dropdown';									//Complex lookup type (ie too many values to script as a simple drop down)
			break	
		
		case 'input':
			strType=this.HTMLObject.type;
			strType = strType.toLowerCase();
			break;
			
		case 'button':
			strType = 'button';
			break;

		case 'iframe':
			strType = 'custom';
			break;
		
		default:
			strType = ''
			break;
			
	}	

	return strType;
		
}

//-----------------------------------------------------------------------------


function WriteDataToControl(strData){
	
//Populate the control with the specified data.
	
//	strData: String containing data in the following format:
//				'valuetype'=values

var strURL = new String();
var strMask = '';

	var strType = this.ControlType()	
	var objControl = this.HTMLObject;

	//strip the valuetype from the value
	var strValue = SplitDataValue(strData);
	var strValueType = SplitDataType(strData);
	
	try {
		switch (strType) {
			
			//Standard HTML controls
			case 'textarea':	
				//Same as text type <input> elements..drop down to clause below				
			case 'text':					
				strMask = objControl.getAttribute('validchars');														//10Aug04 AE  Added Proper date handling
				if (strMask.indexOf('DATE') != -1) {
					var objControl = new DateControl(objControl);
					
				    //SC-07-0737 - change to check for dd/mm/yyyy
				    //* DPA 22.11.2007 insert for merge operation...
					var strDate = new String(strValue);
					if (strDate.indexOf("/") > -1) {
						var dtDate = ddmmccyy2Date(strValue);
						objControl.SetDate(dtDate);
					}
					else
					{
						//  Assume TDate
						objControl.SetTDate(strValue);
					}
				}
				else {	
					objControl.value = strValue;				
				}
				break;
				
			case 'checkbox':
				if ((strValue=='1') || (strValue.toLowerCase() == 'true') ) {
					objControl.checked = true;
				}
				else {
					objControl.checked = false;									
				}
				break;
			
			case 'dropdown':
				//list.  We expect a list of the form:
				//<option value=xxx>"option text"</option><option value=xxx>"option text"</option>
				//This is then inserted directly into the select element
				objControl.insertAdjacentHTML('beforeEnd',strValue);
				break;
				
			case 'custom':
				//custom controls.  To populate these, we call
				//their Populate() method.  We have to do this through
				//the document.frames[] collection
				if (document.frames[this.controlID].Populate != undefined) {
					document.frames[this.controlID].Populate(strData);
				}
//				else {
//					alert('Warning!  Missing Method Populate() in\ncustom control ' + this.controlID );
//				}
				break;
				
		}
	}
	catch (err) {
		//Failed; data was probably of the wrong type
	}	
	
}

//-----------------------------------------------------------------------------

function SetControlValue(strData) {

//Set the index of a dropdown type contols

var intCount = new Number();

	var strType = this.ControlType()	

	if (strType == 'dropdown' ){
		//strip the valuetype from the value
		var strValue = SplitDataValue(strData);	
		var objControl = this.HTMLObject;

		if (strValue != 'null') {

		//Check if this is a simple drop down, or complex lookup...
			if (this.HTMLObject.tagName.toLowerCase() == 'select') {
			//Simple select box
				for (intCount = 0; intCount < objControl.options.length; intCount++ ) {
					if (objControl.options[intCount].value == strValue	) {
						//This is the one				
						objControl.selectedIndex = intCount;
						break;	
					}
				}
			}
			else {
			//Complex lookup; label and search button  
				var objLabel = this.HTMLObject.rows[0].cells[0];
				void objLabel.setAttribute('valueid', strValue);

			}
			
		}
		else {
			objControl.selectedIndex = -1;															//19Aug03 AE
		}

	}
	else  {
		//other controls, reroute to populate()
		this.Populate(strData);
	}

}

//-----------------------------------------------------------------------------

function SetControlEnabled(blnEnable) {
	
//Enable or disable the specified control.
//Disabling a control also clears it.

//	blnEnable: True to enable the control, false to disable it.
	var strType = this.ControlType();
	var objControl = this.HTMLObject;

	if (strType!='custom') {
		//standard HTML controls, use disabled property.
		objControl.disabled = (!blnEnable);
		
		//Also disable/enable the control span (ensures labels 
		//etc reflect the status)
		objControl.parentElement.disabled = (!blnEnable);
		
		if (!blnEnable) {
			//If we're disabling, also clear the control.
			void this.Populate(constValueToken + '=' );
		}
		
	}
	else {
		//custom control.
		alert('not implemented for custom controls');
	}
		
}

//--------------------------------------------------------------------------------------------------------------------------

function ControlFilledIn() {

//Return true if this control contains valid(?) data.
//Since all input is masked, we assume that it's valid
//if it's there.  May need to be cleverer, but I hope not...
//Custom controls expose a FilledIn method which we query here

// 25Aug04 PH Add code to cater for case where dropdown has more than x items and is therefore rendered as a table with a lookup button

	switch (this.ControlType()) {
		case 'custom':
			//Use the custom control's FilledIn method	
			blnReturn = document.frames[this.controlID].FilledIn();
			break;
		
		case 'dropdown':
			//Check that we have a row selected with a value 
			//(ie database id) greater than zero.
			// 25Aug04 PH or that in the case of a table, there is somne text in it. 

			if (this.HTMLObject.tagName=="TABLE")
			{
				blnReturn =  (this.HTMLObject.rows(0).cells(0).innerText != "")
			}
			else
			{
				var intIndex = this.HTMLObject.selectedIndex;
				if (intIndex > -1) {
					//We have an item selected, but does it have an id > 0?
					var lngValue = this.HTMLObject.options[this.HTMLObject.selectedIndex].value;
					lngValue = eval(lngValue);
					blnReturn = (lngValue > 0);
				}
				else {
					//Nowt selected so it must be false
					blnReturn = false;
				}	
			}
			break;
		
		
		default:
			var strValue = this.GetValue();
			var intPos = strValue.indexOf('=');
			var strValue = strValue.substring(intPos + 1);
			//16Jan2013 Rams    30638 - Putting "SPACE" in the detail field on the allergy reaction editor saves it
			if (this.Mandatory)
			{
			    strValue = strValue.replace(/^\s+|\s+$/g, '');
			}
			if (strValue.length > 0) {
				blnReturn = true;
			}
			else {
				blnReturn = false;
			}
		
			break;		
	}

	return blnReturn;

}

//--------------------------------------------------------------------------------------------------------------------------
function ControlDataValid(){

//Checks that the data entered into a control makes sense; for example, that start dates are before stop dates, etc.
//This is an extended set of checks beyond that done in FilledIn. An item may be saved as pending even if not filled in;
//however, an item will never be allowed to be saved if ControlDataValid is false.  The former case is when some data
//is missing; the latter, when data is supplied, but does not make sense.
	
//Not all controls expose this method; only certain custom controls.
	var blnReturn = true;
	
	if (document.frames[this.controlID].ValidityCheck != undefined) {
		blnReturn = document.frames[this.controlID].ValidityCheck();
	}
	
	return blnReturn;
}

//--------------------------------------------------------------------------------------------------------------------------
// SubForm class: represents an order form and allows access
// to controls etc on it.
function OrderForm(formID) {
	
	if (formID!=null) {
		
		this.formID = formID;
		this.formName = FORMID_PREFIX + formID;									//Name used to refer to the form's Iframe in script.	
		this.Body = FormHTMLBody;												//Function to return a formBody object reference
		this.GetControlRef = GetControlReference;							//Function to return a reference to a control
		this.HTMLScript = ScriptOrderFrame;									//Function to return the HTML script for the given order form

	}
	else {
		alert('A formid must be specified for all functions and data\n'
			 + 'elements which refer to a control.');
	}
		
}

//Methods-------------------------------------------------------------------------------------------------------------------

function FormHTMLBody() {
// Returns a reference to the specified form's BODY element.	
// If the form does not exist (for eg, if it is not loaded), 
// the function returns null.

var objBody; 
var formName;

	//Current document's formID
	var parentFormID = layoutData.XMLDocument.selectSingleNode('xmldata/layout').getAttribute('formid');	
	if (this.formID==parentFormID) {
		//specified form is the same as the current HTML DOM document.
		objBody = document.all['formBody'];
	}
	else {
		//specified form is a sub-form
		formName = this.formName;
		try {
			objBody = document.frames[formName].document.all['formBody']
		}
		catch (err) {
			objBody = null
		}
	}

	if (objBody==undefined) {
		objBody=null;
	}

	return objBody
}

//---------------------------------------------------------------------------------------------------------------------------

function GetControlReference(controlID) {
	
// return a reference to a control on the given form.

var objControl;

	//Get a reference to the form
	var objForm = this.Body();

	if (objForm!=null) {	
		//now read the type of control:
		try {
			var strTagName = objForm.all[controlID].tagName;
			if (strTagName.toLowerCase()=='iframe') {
			//control is an iframe 
				objControl = objForm.frames[controlID];
			}
			else {
			//control is an ordinary html element	
				objControl = objForm.all[controlID];
			}

		}
		catch (err) {
			//Failed; control does not exist yet (may be on 
			//an uninstantiated sub form)
			objControl = null;
		}		

	}
	else {
		//Control not found; most probably a control
		//on a sub form which is not loaded.
		objControl=null;
	}


	return objControl;
	
}

//------------------------------------------------------------------

function ScriptOrderFrame(blnRearrangeOnLoad) {
	
//Returns the HTML for the iframe containing the specified form.
//If the specified form is already loaded in an iframe, the 
//frame's .outerHTML property is returned.
//If the current form (ie this document) is specified, then 
//the function returns null (as a form cannot be its own subform).
//Otherwise, the HTML is that to create a new frame.

//	blnRearrangeOnLoad: Boolean.  This parameter is passed to 
//							 ArrangeSubForm, and is used to prevent
//							 resizing code firing if the form is not
//							 visible.

var strReturn = new String();
var strOnLoad = new String();
var blnArrangeNow = false;

	//Current document's formID
	var parentFormID = layoutData.XMLDocument.selectSingleNode('xmldata/layout').getAttribute('formid');	
	if (this.formID==parentFormID) {
		//not allowed; return null.
		strReturn = null;
	}
	else {
		//Form specified is not the current document.
		if (this.Body() != null) {		
			//form exists.  Return it's frame's HTML
			strReturn = document.all[(this.formID)].outerHTML;
		}
		else {		
			//form not yet loaded.  Return HTML definition

			strReturn =  '<iframe '; 
			strReturn += 'id=' + this.formName + ' ';
			strReturn += 'src="OrderForm.aspx?Tableid=' + this.formID + '" ';
			strReturn += 'onLoad="ArrangeSubForm(this,' + blnRearrangeOnLoad + ');DoNextFunction();" '
			strReturn += 'frameborder="0" ';
			strReturn += 'class=OrderFormFrame ';
			strReturn += '></iframe>';
		}
		
	}

	return strReturn;
}
//----------------------------------------------------------------------------------------------------

function ControlIsDate() {

//Determine if this is a date input control
	if (this.ControlType() == 'text') {
		var strMask = this.HTMLObject.getAttribute('validchars');	
		if (strMask == null) {strMask = ''};
		return (strMask.toLowerCase().indexOf('date') > -1);
	}
	else {
		return false;	
	}	
}
//----------------------------------------------------------------------------------------------------
function ControlIsTime() {
//Determine if this is a time input control
	if (this.ControlType() == 'text') {
		var strMask = this.HTMLObject.getAttribute('validchars');
		if (strMask == null) {strMask = ''};
		return (strMask.toLowerCase().indexOf('time') > -1);
	}
	else {
		return false;
	}
}
//----------------------------------------------------------------------------------------------------

