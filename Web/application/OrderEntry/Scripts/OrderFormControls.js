
/*
------------------------------------------------------------------------------------------------

								ORDER FORM CONTROLS SCRIPT

	Set of procedures for dealing with the HTML elements that make up
	controls on our order forms.

	------------------------------------------------------------------
	Modification History:
	18Nov02 AE  Written
	  Mar04 AE	Added Support for long / typed / inherited lookups
	30Apr04 AE  Added support for Read Only fields
    22Feb10 XN  Use discharge picker if control foreign lookup table is [OrderCatalogue] (F0053577)
    12Sep11 XN  TFS13682 In SearchOrderCatalogueLookups if user does not select anything then clears the current selection    
------------------------------------------------------------------------------------------------
*/
var m_objHintsWindow;													//Object reference for the pop-up hits window.
// 25Jun07 ST Changed to look for readonly attribute instead
var ATTR_READONLY = 'nowrite';										//03Oct06 AE  #SC-06-0797   Constantised attribute name. Persist Readonly fields through saves to the pending tray
var ATTR_READONLY = 'readonly';

//------------------------------------------------------------------------
//								Public Utility Interfaces
//------------------------------------------------------------------------

function IsControl(objElement) {

//Returns TRUE if the element specified in objElement is 
//a ControlSpan class element.

//Note that sub forms are considered to be controls by this procedure.

var thisClassName=new String();
var blnReturn = false;

	thisClassName=objElement.className;
	thisClassName = thisClassName.toLowerCase();
	if(thisClassName=='controlspan') {
		blnReturn=true;
	}
	return blnReturn;

}

//------------------------------------------------------------------------
function IsSubForm(objControlSpan) {

//Returns TRUE if the specified control span element
//contains a sub form.
var blnReturn = false;

	var objSubForm = GetSubFormElementFromSpan(objControlSpan);
	if (objSubForm != null ) {
		blnReturn=true;
	}
	
	return blnReturn

}

//------------------------------------------------------------------------

function IsCustomControl(objControlSpan) {

//Returns TRUE if the specified control span element
//contains a custom control

var blnReturn = false;

	var objControl = GetCustomControlElementFromSpan(objControlSpan);
	if (objControl != null ) {
		blnReturn=true;
	}
	
	return blnReturn

}

//------------------------------------------------------------------------

function GetInputElementFromSpan(objSpan) {

//Given a ControlSpan element containing one or more
//HTML elements, of which one is an input control, returns
//a reference to the input control.
//Input controls are determined by their className attribute;
//they are either MandatoryField or StandardField class elements.

// objSpan: reference to an HTML DOM <span> element
//	Returns: reference to an HTML DOM element, or null
//				if no input control was found.
	
	
var intCount = new Number(0);
var className = new String();
var returnElement = null;


	for (intCount=0; intCount< objSpan.all.length; intCount++ ) {
		//Check each element in the span
		className = objSpan.all[intCount].className;

		switch (className.toLowerCase() ) {
			case 'mandatoryfield':
				returnElement = objSpan.all[intCount];
				break;
				
			case 'standardfield':
				returnElement = objSpan.all[intCount];
				break;
		}
	
		//Exit if we've found the element		
		if (returnElement != null) {
			break;
		}
	}

	//Return
	return returnElement;
	
}
//------------------------------------------------------------------------

function GetLabelElementFromSpan(objSpan) {

//Returns the label in this span, if there is one; otherwise returns null.
//Becuase we are no longer mixing labels  and input controls within spans, 
//this procedure is not as generic as the others of a similar ilk
//09Mar04 AE  Written

	var objLabel = objSpan.firstChild;
	if (objLabel.className.toLowerCase() == 'labelfield') {
		return objLabel;
	}
	else {
		return null;
	}
}

//------------------------------------------------------------------------

function GetSubFormElementFromSpan(objSpan) {

//Search throught the given span.  If an Iframe
//of class OrderFormFrame is found, return a reference
//to it.  Otherwise, null is returned.

// objSpan: reference to an HTML DOM <span> element
//	Returns: reference to an HTML DOM element, or null
//				if no sub form was found.

var intCount = new Number(0);
var className = new String();
var returnElement = null;

	for (intCount=0; intCount<objSpan.all.length; intCount++ ) {
		//Check each element in the span
		className = objSpan.all[intCount].className;
		className = className.toLowerCase();

		if (className=='orderformframe') {
			//Found the span
			returnElement = objSpan.all[intCount];
			break;
		}
	}

	return returnElement;

}
//-----------------------------------------------------------------------

function GetCustomControlElementFromSpan(objSpan) {

//Search throught the given span.  If an Iframe
//of class CustomControlFrame is found, return a reference
//to it.  Otherwise, null is returned.

// objSpan: reference to an HTML DOM <span> element
//	Returns: reference to an HTML DOM element, or null
//				if no custom control was found.

var intCount = new Number(0);
var className = new String();
var returnElement = null;

	for (intCount=0; intCount<objSpan.all.length; intCount++ ) {
		//Check each element in the span
		className = objSpan.all[intCount].className;
		className = className.toLowerCase();

		if (className=='customcontrolframe') {
			//Found the span
			returnElement = objSpan.all[intCount];
			break;
		}
	}

	return returnElement;

}

//------------------------------------------------------------------------
//							Public Methods
//------------------------------------------------------------------------

function FocusFirstControl() {

//Set focus to the first asc control on the order form.	
//TabIndex for these controls start at 1, rather than 0, as
//0 is the default.  If we use 0 we would not be able to differentiate
//controls with no tabindex set from one with an actual tabindex of 0
//
//	returns: TRUE if the focus was set, FALSE if the focus could not be set.
//25Mar05 AE  Added support for custom controls.  

var objElement = new Object();
var firstTabIndex= new Number(Infinity);
var intCount = new Number(0);
var blnReturn = false;
var blnFoundCustom = false;

	//Check to see if our form is using a custom control
	for (intCount = 0; intCount < formBody.all.length; intCount++) {
		objElement = formBody.all[intCount];
		var objCustom = GetCustomControlElementFromSpan(objElement);
		if (objCustom != null) {				
			blnFoundCustom = true
			break;
		}
	}

	//If we have a custom control, call its onboard ControlFocus method, 
	//otherwise use the one here
	if (blnFoundCustom){
		if (document.frames[objCustom.id].ControlFocus != undefined){
			blnReturn = document.frames[objCustom.id].ControlFocus();
		}
	}
	else {
		blnReturn = ControlFocus();
	}

	return blnReturn;

}

//---------------------------------------------------------------------------------------
function ControlFocus(){
	
//Focus on the the first applicable control on the form;
//	this is the first empty mandatory field;
//	or the first empty standard field if all mandatory fields are full;
//	or the first control if all fields are filled in
	
var firstControl = null;
var firstMandatory = null;
var firstStandard = null;
var targetControl = null;
var blnIsEmpty = false;
var blnReturn = false;
var blnCanFocus = false;

	for (intCount = 0; intCount < formBody.all.length; intCount++) {

		objControl = formBody.all[intCount];
		blnEmpty = false;
		switch (objControl.tagName.toLowerCase()){
			case 'input':
			case 'textarea':
			case 'select':
				//determine if this control is currently empty
				if (objControl.tagName.toLowerCase() == 'select'){
					if (objControl.selectedIndex == 0){
						blnEmpty = (objControl.options[0].innerText == '');
					}
					else {
						blnEmpty = (objControl.selectedIndex == -1);	
					}
				}
				else{
					blnEmpty = (objControl.value == '');
				}
				
			//Check if this has the lowest tab index yet found
				if (objControl.tabIndex > 0){	

					if (CanAcceptFocus(objControl)){
						if (firstControl == null || objControl.tabIndex < firstControl.tabIndex)firstControl = objControl;
						if (objControl.className.toLowerCase() == 'mandatoryfield'){
							if (blnEmpty && (firstMandatory == null || objControl.tabIndex < firstMandatory.tabIndex)) firstMandatory = objControl;
						}
						else {
							if (blnEmpty && (firstStandard == null || objControl.tabIndex < firstStandard.tabIndex)) firstStandard = objControl;
						}
					}
				}
				break;
			
			default:
			//Not an input control	
		}		
	}

	//Now focus on, the first empty mandatory field, or first empty standard field
	//if all mandatory fields are filled in, or the first control on the form if
	//everything is filled in
	if (firstControl != null) targetControl = firstControl;
	if (firstStandard != null) targetControl = firstStandard;
	if (firstMandatory != null) targetControl = firstMandatory;
	
	if (targetControl != null) {
		targetControl.focus();

		blnReturn = true;
	}
	return blnReturn;
	
}
//---------------------------------------------------------------------------------------

function SetReadOnly() {

//Makes every control on the form read-only.  Intended for use from Custom Controls, 
//as for standard forms this is done in the server script.

	void SetReadOnlyByTag('input');
	void SetReadOnlyByTag('textarea');	
	void SetReadOnlyByTag('button');
	void SetReadOnlyByTag('select');
	void SetReadOnlyByTag('img');		
}

//---------------------------------------------------------------------------------------

function SetReadOnlyByTag(strTagName) {

//Sets every element of the given tag name to be read only	
//04Aug04 AE  Changed from using the disabled attribute where
//				  possible to give a better appearance
var intCount = new Number();

	var colElements = document.all.tags(strTagName);
	
	for (intCount = 0; intCount < colElements.length; intCount++) {
		switch (strTagName) {
			case 'input':				
				switch (colElements[intCount].getAttribute('type').toLowerCase()){
					case 'text':
						colElements[intCount].attachEvent('onmousedown', ReturnFalse);
						colElements[intCount].attachEvent('onkeydown', ReturnFalse);
						colElements[intCount].attachEvent('oncontextmenu', ReturnFalse);
						break;
						
					case 'hidden':																					//23May08 AE  Fix "order entry not refreshing in display mode"
						//do nothing - we don't want to disable these as they are used to 
						//send data up to the server, and disabling stops it working
						break;
					
					default:
						colElements[intCount].disabled = true;	
						break;
				}
		
			case 'textarea':
				colElements[intCount].attachEvent('onmousedown', ReturnFalse);
				colElements[intCount].attachEvent('onkeydown', ReturnFalse);
				colElements[intCount].attachEvent('oncontextmenu', ReturnFalse);
				break;

			case 'img':
				colElements[intCount].style.cursor = 'default';
				colElements[intCount].setAttribute('onclick', '');			
				break;
				
			case 'button':
				//We make exception for the reference lookup button
				//And now the Edit Diluent butto
				if (colElements[intCount].id == "cmdEditDiluent" || colElements[intCount].id == "btnCalculation")
				{
				    break;
				}
				
				if (colElements[intCount].id != 'btnReference') colElements[intCount].disabled = true;									//23Oct06 AE  Don't disable the lookup button #SC-06-0982
				break;

			//All below drop through to default
			case 'select':				
			default:
				colElements[intCount].disabled = true;
				break;
		}	
	}
}
//---------------------------------------------------------------------------------------

function RenderStacked(){

//Takes any custom control on this form and ensures that it is 
//rendered with no scrolling.  Returns the resulting height of the
//form (which may well be greater than its height in paged mode).

//Assumes that there is only a single custom control; this is always
//the case at present, although the concept allows for multiples in 
//theory.  Will need more work if we ever support multiple custom controls.

//19Apr05 AE  Written

var objSpan;
var objCustom;

	var newHeight = formBody.scrollHeight;

	for (intCount=0; intCount < formBody.all.length; intCount++) {
		objSpan = formBody.all[intCount];
		if (IsControl(objSpan)) {	
			objCustom = GetCustomControlElementFromSpan(objSpan);
			if (objCustom != null){

				objSpan.setAttribute('oldheight', objSpan.style.height)
				newHeight = document.frames[objCustom.id].document.body.scrollHeight;
				newHeight = Number(newHeight) + 50;
				objSpan.style.height = newHeight + 'px';
				objSpan.style.overflow = 'visible';
			}
		}
	}
	formBody.style.overflow='visible';
	return (Number(newHeight));
		
}

//---------------------------------------------------------------------------------------

function RenderPaged(){

//Assumes that there is only a single custom control; this is always
//the case at present, although the concept allows for multiples in 
//theory.  Will need more work if we ever support multiple custom controls.

//19Apr05 AE  Written

var objSpan;
var objCustom;

	for (intCount=0; intCount < formBody.all.length; intCount++) {
		objSpan = formBody.all[intCount];
		if (IsControl(objSpan)) {	
			objCustom = GetCustomControlElementFromSpan(objSpan);
			if (objCustom != null){

				objSpan.style.height = objSpan.getAttribute('oldheight');
				objSpan.style.overflow = 'auto';
			}
		}
	}
	formBody.style.overflow='auto';
	return;
		
}

//---------------------------------------------------------------------------------------
function ReturnFalse() {
//Does what it says on the tin!  Used for attachEvent since you have to give a function pointer
	return false;
}

//---------------------------------------------------------------------------------------
function SetReadOnlyByControlSpan(objControlSpan) {

//Sets any input controls in the given Control Span to be read-only
//objControl - reference to an HTML span containing input controls	

//30Apr04 AE  Written

var intCount = new Number();
var tagName = new String();
var objElement = new Object();

	var colElements = objControlSpan.all;	
	for (intCount = 0; intCount < colElements.length; intCount++) {
		tagName = objControlSpan.all[intCount].tagName;

		switch (tagName.toLowerCase() ) {
			case 'input':
				objElement = objControlSpan.all[intCount];
				break;
				
			case 'textarea':
				objElement = objControlSpan.all[intCount];
				break;
			
			case 'img':
				objElement = objControlSpan.all[intCount];
				break;
				
			case 'select':
				objElement = objControlSpan.all[intCount];
				break;
        //F0077085 PCannavan - Enable Readonly state to be added to the following control type 
        case 'dropdown':
            objElement = objControlSpan.all[intCount];
            break;
        //F0077085 PCannavan - Enable Readonly state to be added to the following control type  
        case 'button':
            objElement = objControlSpan.all[intCount];
            break;
			default:
				objElement = null;
				break;
		}

		if (objElement != null) {
			objElement.disabled = true;
		}
	}
	//And set the attribute on the span so that it will get saved.
	objControlSpan.setAttribute(ATTR_READONLY, 1);																			//03Oct06 AE  Persist Readonly fields through saves to the pending tray
	
}
//---------------------------------------------------------------------------------------

function SetBackgroundColor(strColor) {
	
//Sets the background color for this form, subforms and labels.	

var intCount = new Number(0);
var objSpan = new Object();
var objCustom = new Object();
var returnXML = new String();
var objLabel = new Object();

	document.body.style.backgroundColor = strColor;
	
	for (intCount=0; intCount < formBody.all.length; intCount++) {
		objSpan = formBody.all[intCount];
		if (IsControl(objSpan)) {	
			//This is a control.  If it's a label then update its background color, 
			//otherwise leave it alone.
			objLabel = GetLabelElementFromSpan(objSpan)
			if (objLabel != null) {
				objLabel.style.backgroundColor = strColor;
			}
			
		}	
		else {
			//We may have a subform.  Check for this:
			//We may have a custom control
			objCustom = GetCustomControlElementFromSpan(objSpan);
			if (objCustom != null) {
				void document.frames[objCustom.id].SetBackgroundColor(strColor);
			}
		}
	}
}

//------------------------------------------------------------------------
//
//
//		Specialised script for lookup controls
//
//------------------------------------------------------------------------
function ShowLookupDefaults(columnID) {

//Handler function for the lookup search button on Order Templates;
//in this mode we allow the user to limit the lookup by type if
//appropriate, and to pick a default value for the lookup.

	//Get a reference to the label where we display the selected values
	//and store the selected ids.	
	var objSrc = window.event.srcElement;
	var objLabel = objSrc.parentNode.parentNode.all['lookuplabel'];

	//Read existing ids from the label
	var typeID = objLabel.getAttribute('typeid');
	var valueID = objLabel.getAttribute('valueid');
	if (typeID == null) {typeID = 0};
	if (valueID == null) {valueID = 0};

	//Show the pop-up
	var strURL = '../OrderEntry/LookupSearch.aspx'
				  + '?SessionID=' + document.body.getAttribute('sid')
				  + '&Mode=typed'
				  + '&ColumnID=' + columnID
				  + '&ValueID=' + valueID
				  + '&TypeID=' + typeID;  

	var strReturn = window.showModalDialog(strURL, '', LookupSearchFeatures());
	if (strReturn == 'logoutFromActivityTimeout') {
		strReturn = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	if (strReturn == undefined) {strReturn = ''};
	
	//Now save the given typeID and valueID in the lookup control
	//strReturn = "TypeID|TypeDescription|ValueID|ValueDescription"  
	if (strReturn != '') {
		astrReturn = strReturn.split('|');
		typeID = astrReturn[0];
		var typeDesc = astrReturn[1];
		valueID = astrReturn[2];
		var valueDesc = astrReturn[3];
		
		void objLabel.setAttribute('typeid', typeID);
		void objLabel.setAttribute('typedescription', typeDesc);
		void objLabel.setAttribute('valueid', valueID);
		void objLabel.setAttribute('valuedescription', valueDesc);
		objLabel.innerText = typeDesc + ',' + valueDesc;
		objLabel.title = typeDesc + ',' + valueDesc;
	}	
	
}
//------------------------------------------------------------------------

function SearchLookups(columnID, typeID) {
//Handler function for the lookup search controls.
//Used when there are too many values in the given lookup
//to display in a simple list.

	//Get a reference to the label where we display the selected values
	//and store the selected ids.	
	var objSrc = window.event.srcElement;
	var objLabel = objSrc.parentNode.parentNode.all['lookuplabel'];

	//Show the pop-up
	var strURL = '../OrderEntry/LookupSearch.aspx'
				  + '?SessionID=' + document.body.getAttribute('sid')
				  + '&Mode=lookup'
				  + '&ColumnID=' + columnID
				  + '&TypeID=' + typeID;  
	var strReturn = window.showModalDialog(strURL, '', LookupSearchFeatures());
	if (strReturn == undefined) {strReturn = ''};
	
	//Now save the given valueID in the lookup control
	//strReturn = "TypeID|TypeDescription|ValueID|ValueDescription"  - we don't care about the type stuff here
	if (strReturn != '') {
		astrReturn = strReturn.split('|');
		valueID = astrReturn[2];
		var valueDesc = astrReturn[3];
		
		void objLabel.setAttribute('valueid', valueID);
		void objLabel.setAttribute('valuedescription', valueDesc);
		objLabel.innerText = valueDesc;
		objLabel.title = valueDesc;
	}

}

//------------------------------------------------------------------------

function SearchOrderCatalogueLookups(columnID, orderCatalogueRootDescription) {
    //Handler function for the lookup search controls.
    //Used when there are too many values in the given lookup
    //to display in a simple list.

    //Get a reference to the label where we display the selected values
    //and store the selected ids.	
    var objSrc = window.event.srcElement;
    var objLabel = objSrc.parentNode.parentNode.all['lookuplabel'];

    var intHeight = 400;
    var intWidth = 750;

    valueID = objLabel.getAttribute('valueid');
    valueDesc = objLabel.getAttribute('valuedescription');

    var strURL = "../DischargeSummary/DischargeOrderCataloguePickerWrapper.aspx"
					+ "?sessionid=" + document.body.getAttribute('sid')
					+ "&description=" + orderCatalogueRootDescription
//					+ "&folder="
					+ "&singleItemMode=True";

    var strFeatures = 'dialogHeight:' + intHeight + 'px;'
					+ 'dialogWidth:' + intWidth + 'px;'
					+ 'resizable:yes;unadorned:no;'
					+ 'status:no;help:no;';
    var strItem_XML;
    if (valueID > 0)
        strItem_XML = '<root><item id="' + valueID + '" text="' + valueDesc + '" /></root>';
    else
        strItem_XML = '<root></root>';

	var strXML = window.showModalDialog(strURL, strItem_XML, strFeatures);
	if (strXML == 'logoutFromActivityTimeout') {
		strXML = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

    if (strXML == undefined) { strXML = 'cancel' };

    if (strXML != 'cancel') 
    {
        var xmldoc = new ActiveXObject("Microsoft.XMLDOM");
        xmldoc.async = "false";
        xmldoc.loadXML(strXML);

        // XN 12Sep11 TFS13682 If user does not select anything then clears the current selection
        var xmlnode = xmldoc.selectSingleNode("//item");
        if (xmlnode != null)
        {
            valueID = xmlnode.getAttribute("id");
            valueDesc = xmlnode.getAttribute("text");
        }
        else
        {
            valueID = ''
            valueDesc = ''
        }
        
        objLabel.setAttribute('valueid', valueID);
        objLabel.setAttribute('valuedescription', valueDesc);

        objLabel.innerText = valueDesc;
        objLabel.title = valueDesc;
    }    
}

//------------------------------------------------------------------------

function LookupSearchFeatures() {
	
	var strFeatures = 'dialogHeight:500px;' 
						 + 'dialogWidth:600px;'
						 + 'resizable:no;'
						 + 'status:no;help:no;';	
	return strFeatures;
}


//------------------------------------------------------------------------
//
//		Specialised script for template mode; allows the user to set certain
//		fields as read-only.
//		30Apr04 AE  Added support for Read Only fields
//------------------------------------------------------------------------

function TemplateFieldReadOnlyToggle() {
//Toggle the field between read only and writable
	var objSrc = window.event.srcElement;

	if (objSrc.getAttribute(ATTR_READONLY) == '1'){															//03Oct06 AE Constantised attribute #SC-06-0797   10Aug05 AE  Now stores flag on the image, not the parent span
		void TemplateFieldReadOnlySet(objSrc, 0);
	}
	else {
		void TemplateFieldReadOnlySet(objSrc, 1);
	}
}

//------------------------------------------------------------------------
function TemplateFieldReadOnlySet(objImage, bitReadOnly){

//Set the field to be read-only or writable
	var strTitle = 'This field will be READ-ONLY. Click here to make it editable.';
	var strImage = 'stylusModeOff.gif';
	if (Number(bitReadOnly) == 0) {
		strImage = 'stylusModeOn.gif';	
		var strTitle = 'This field will be EDITABLE. Click here to make it read-only.';
	}	
	
	var strURL = document.URL;																					//10Aug05 AE  Deal with relative paths properly
	strURL = strURL.substring(0, strURL.indexOf('application'));
	strURL += 'images/ocs/';

	objImage.setAttribute('src', strURL + strImage);
	objImage.setAttribute('title', strTitle);
	objImage.setAttribute(ATTR_READONLY, bitReadOnly);														//03Oct06 AE Constantised attribute #SC-06-0797 10Aug05 AE  now stores flag on the image, not the parent span
}

//----------------------------------------------------------------------------------------
function SelectReason(objSelect){

//Allows the user to pick a clinical problem/reason, and adds it to the combo box.
//10Nov04 AE  Enhanced;  now uses optgroups and button replaced with an "other..." option
//				  to reduce confusion.
var intCount = new Number();
var blnAlreadySelected = false;
var objOption;
var objGroup;

	if (objSelect.selectedIndex > -1) {
		if (objSelect.options[objSelect.selectedIndex].value == 'other') {
		
			var strReturn = SelectProblem();
			//<root><item id="123" text="abc" /></root>
			if (strReturn != 'cancel') {
				tempXML.XMLDocument.loadXML (strReturn);
				var xmlItem = tempXML.XMLDocument.selectSingleNode('root/item');
				var lngID = xmlItem.getAttribute('id');
				var strDescription = xmlItem.getAttribute('text');				
				
				//Add a new option to the drop down list, if it aint there already.
				for (intCount = 0; intCount < lstReason.options.length; intCount ++){
					if (Number(lstReason.options[intCount].value) == lngID) {
						blnAlreadySelected = true;
						break;
					}
				}
				
				if (!blnAlreadySelected) {
				//Add it to the clinical reasons option group
					objOption = document.createElement('option');
					lstReason.firstChild.insertBefore(objOption, lstReason.firstChild.firstChild);
					objOption.value = lngID;
					objOption.innerText = strDescription;
					objOption.setAttribute (XML_ATTR_REASONTYPE, REASONTYPE_CLINICAL)		//These are always clinical reasons
					
				//Select the new option.  Setting objOption.selected does not seem to work
				//consistently here, so doing it the long way and setting the selectedIndex
				//property instead.
					for (intCount = 0; intCount < lstReason.options.length; intCount++) {
						if (lstReason.options[intCount].value == lngID) {
							lstReason.selectedIndex = intCount;
							break;	
						}
					}
					
				}
			}	
		}
	}	
}
//----------------------------------------------------------------------------------------
function ShowFieldHints(strTableIDorName, strFieldName){
//17Jan06 AE  Simple wrapper to launch new hints window.
//07Apr06 AE  Modified; always close old window, then open new one, instead of reusing.
//23May07 ST  Changed to showModelessDialog as window.open/window.close now cause an error after MS service pack	


	void CloseFieldHintsWindow();
	var strURL = '../FieldHints.aspx?SessionID=' + document.body.getAttribute('sid') + '&Table=' + strTableIDorName + '&Field=' + strFieldName;
	
	if(m_objHintsWindow != undefined || m_objHintsWindow != null)
	{
		m_objHintsWindow.close();
	}

	m_objHintsWindow = window.showModalDialog(strURL, '', "status:false;dialogWidth:500px;dialogHeight:400px");
}

//----------------------------------------------------------------------------------------
function CloseFieldHintsWindow()
{
	if (m_objHintsWindow != undefined){
		m_objHintsWindow.close();
		m_objHintsWindow = undefined;			
	}		
}
