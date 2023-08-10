/*
------------------------------------------------------------------------------------------------------

													OrderFormResizing.js

	Resizing script for OrderForm.aspx.  Arranges and scales the controls on an order form
 	in the same proportions as the form was designed in.  


	---------------------------------------------------------------------------------------
	Modification History:
	11Nov02 AE  Written
	

	
------------------------------------------------------------------------------------------------------	
*/



//Max / Minimum limits for sizing
var MAX_FONT_SIZE = 20;											
var MIN_TA_FONTSIZE = 10;								//minimum fs supported by HTML controls (in px).  This is intrinsic to HTML.

//Spacing between controls within a span (prevents wrapping behaviour)
var CONTROL_SPACING = 10;

//Space between the edge of the span and the controls within.
var CONTROL_MARGIN = 10;

//================================================================================================


function ResizeOrderForm(formDocument, blnDefaultArrange) {

//Re-arrange the controls according to the size of the given formDocument.
//The whole document is scaled proportionally to the design-time version, 
//so that it can be designed in one resolution and viewed in many others.
//
// formDocument: reference to an HTMLDOM document object.
// blnDefaultArrange: if TRUE, this ignores the proportional sizing
//									 and simply puts the controls in their designed positions.

// Returns: void


return; // 16Feb04 PH Turn off resizing

var objSpan;
var designFormWidth = new Number();
var designFormHeight = new Number();

var designTop = new Number();
var designLeft = new Number();

var designHeight = new Number();
var designWidth = new Number();

var newTop = new Number();
var newLeft = new Number();
var newHeight = new Number();
var newWidth = new Number();

var intCount = new Number();


//alert('ResizeOrderForm\n\n\n' + formDocument.all['formBody'].innerHTML)
	//If blnDefault arrange is not specified, it is set to false.
	if (blnDefaultArrange==undefined) {
		blnDefaultArrange=false;
	}

	//Available height/width
	var formWidth = formDocument.all['formBody'].offsetWidth;
	var formHeight = formDocument.all['formBody'].offsetHeight;
	// check for really stupid values (!)											//21Aug03 AE  Removed.  There is no need for this, it is already handled.
	
	
	//Height/width the form was designed in
	var objLayout = formDocument.all['layoutData'].XMLDocument.selectSingleNode('xmldata/layout');
	var designFormWidth=objLayout.getAttribute('width');
	var designFormHeight=objLayout.getAttribute('height');
//alert('design: \n' + designFormWidth + ',' + designFormHeight + '\n\nActual: ' + formWidth + ',' + formHeight);

	//Use this info to calculate the font size required:
	var newFontValue = GetFontSize(designFormHeight,designFormWidth, formHeight, formWidth);

	//The smallest font size supportable by a text area is 10px.  If the font
	//size calculated is smaller than this, don't do any resizing, UNLESS
	//the blnDefaultArrange flag is set.
	
	//blnDefaultArrange = true; // PH Hack to fix resizing issues										//12Dec03 AE  Replaced with fix in OrderEntry.js
	if(blnDefaultArrange && (newFontValue < MIN_TA_FONTSIZE)) {
		newFontValue = MIN_TA_FONTSIZE
	}

	if ( (newFontValue >= MIN_TA_FONTSIZE) ) {
	
		//now re-calculate each control's position and size so that they
		//are proportionally the same in the new resolution.
		var formCanvas = formDocument.all['formBody']
		var colSpans = formCanvas.getElementsByTagName('span');
		
		for (intCount=0; intCount < colSpans.length; intCount++) {						
			objSpan = colSpans[intCount];
			if(IsControl(objSpan)) {

			//Ignore anything which isn't a control span
				//design-time top,left and size of this control
				designLeft = eval(objSpan.getAttribute('left'));
				designTop = eval(objSpan.getAttribute('top'));
				designWidth = eval(objSpan.getAttribute('width'));
				designHeight = eval(objSpan.getAttribute('height'));
				//calculate new co-ordinates:
				if (!blnDefaultArrange) {
					//Normal resizing; values are scaled to the current form size.
					newLeft = (designLeft/designFormWidth) * formWidth;
					newTop = (designTop/designFormHeight) * formHeight;
					newWidth = (designWidth/designFormWidth) * formWidth;
					newHeight = (designHeight/designFormHeight) * formHeight;
				}
				else {					
					//Override; we just move everything to its designed position.
					newLeft = designLeft;
					newTop = designTop;
					newWidth = designWidth;
					newHeight = designHeight;	
				}
				//Apply the new sizing.  This is applied to the 
				//style collection and hence overwrites the design-time values
				//which are held in the height/width attributes of the tag.
				objSpan.style.left = newLeft;
				objSpan.style.top = newTop;			
				objSpan.style.width = newWidth;
				objSpan.style.height = newHeight;

				//now size the contents of the control.
				objSpan.scrollTop = 3;
				void SizeControlSpanContents (objSpan,designFormHeight,designFormWidth,formHeight,formWidth, newFontValue);
			}
		}
	}	
}

//============================================================================================================

function SizeControlSpanContents(objSpan, designFormHeight,designFormWidth, formHeight, formWidth, fontSize) {

//The span has been sized proportionally with the form.  We now size its
//contents to suit.

var intUsedWidth = new Number();
var intUsedHeight = new Number();
var intCount = new Number();
var strTagName = new String();
var objNode = new Object();
var strType = new String();
var blnFinished = false;
var objInput = undefined;

	//Now iterate through each element in the span and resize them
	//as appropriate.		
	for (intCount = 0; intCount < objSpan.childNodes.length; intCount++) {
		objNode = objSpan.childNodes[intCount];
		strTagName = objNode.tagName;

		if((strTagName!=undefined) && (objNode.style.display != 'none') ){
			objNode.style.fontSize = (fontSize + 'px') ;		
			strTagName = strTagName.toLowerCase();

			switch (strTagName) {	
			//Resize everything except the input control; this is then resized to fit
			//the remaining space in the control span after everything else has been.
				case 'input':
				//Check if this is a text box
					strType = objNode.getAttribute('type');
					strType=strType.toLowerCase();
		
					if (strType=='text') {
					//if so, this is the control we resize to fit the remaining space.
						objInput = objNode;
					}
					else {
					//otherwise, it is unresizable content
						intUsedWidth += objNode.offsetWidth + CONTROL_SPACING;
					}
					break;	
		
				case 'textarea':
				//Multiline text box
					objInput = objNode;
					break;
				
				case 'select':
				//Drop-down list
					objInput = objNode;					
					break;
					
				case 'iframe' :
				//Custom control OR sub form				
					objInput = objNode;
					break;

				case 'button':
				//Standard HTML Button
					void ResizeButton(objSpan, objNode, fontSize);
					intUsedWidth += objNode.offsetWidth;
					break;
					
				//Non input controls - resize these now:	
				case 'span':				
					strType = objSpan.childNodes[intCount].className;
					strType = strType.toLowerCase();
				
					switch (strType) {
						case 'lookupsearchcontrol':
							//Lookup search control containing a text box and combo.
							void ResizeLookupSearch(objSpan,objNode, intUsedWidth, intUsedHeight, fontSize);
							blnFinished=true;
							break;
							
						default:
						//otherwise, it is unresizable content
							intUsedWidth += objNode.offsetWidth + CONTROL_SPACING;
					}
					break;
									
				case 'br':
				//BR indicates a line break, so we must increase the used height counter
				//and reset the used width counter.
					intUsedHeight += objNode.offsetHeight;
					intUsedWidth = 0;
					break;
			
				case 'img':
				//Images may be used to indicate mandatory fields
					void ResizeImage(objNode, fontSize);
					intUsedWidth += (objNode.offsetWidth + CONTROL_SPACING);
					break;
				
/*				case 'button':
					void ResizeButton(objNode, fontSize);
					intUsedWidth += (objNode.offsetWidth + CONTROL_SPACING);
					break;
*/									
				default:
				//Anything else is just padding, and autoresizes according to its font size.
					intUsedWidth += objNode.offsetWidth;
					break;
				
			}

		}
	}

	//Finally, we resize the input control to take up the remaining space.	
	if (objInput != undefined) {

		strTagName = objInput.tagName;
		strTagName = strTagName.toLowerCase();
		switch (strTagName) {			
			case 'input':
				//Single Line Text Box
				void ResizeTextInput(objSpan, objInput, intUsedWidth, intUsedHeight);
				break;	
				
			case 'textarea':
			//Multiline text box
				void ResizeTextArea(objSpan, objInput, intUsedWidth, intUsedHeight);
				break;
			
			case 'select':
			//Drop-down list
				void ResizeSelect(objSpan, objInput, intUsedWidth, intUsedHeight);
				break;
				
			case 'iframe' :
			//Custom control OR sub form				
				void ResizeIframe(objSpan, objInput, intUsedWidth, intUsedHeight);
				break;
		}
	}
	
}


//================================================================================================---
function ResizeButton(objSpan, objButton, fontSize) {

//Resizes a button within objSpan	
	objButton.style.height = objSpan.offsetHeight - 5;
	objButton.style.width = objButton.offsetHeight;
	
}

//================================================================================================---

function GetFontSize(designFormHeight,designFormWidth,formHeight,formWidth) {

//Calculates the font size in Pixels from the dimensions of the order form.
	
var newFontSize

	newFontSize = ((formHeight/designFormHeight) ) * (17 *  (formWidth/designFormWidth ));

	if (newFontSize > MAX_FONT_SIZE) {
		newFontSize=MAX_FONT_SIZE;
	}
	return newFontSize;	
}

//================================================================================================---

function ResizeTextInput(objSpan, objInputElement, intUsedWidth, intUsedHeight) {

//Resizes an <Input type=text> element within objSpan
//It is sized to take up all remaining width and height in objSpan
	objInputElement.style.height = (objSpan.offsetHeight - intUsedHeight - 5);
	objInputElement.style.width = (objSpan.offsetWidth - intUsedWidth - CONTROL_MARGIN);
}

//================================================================================================---

function ResizeTextArea(objSpan, objInputElement, intUsedWidth, intUsedHeight) {

//Resizes a <textarea> element within objSpan.
//We have to calculate the number of ROWS which will fit in the remaining height, 
//as this attribute overrides any height settings on the textarea.

	var intAvailableHeight = objSpan.offsetHeight - intUsedHeight;
	var intRows = objInputElement.rows;
	var intTries = intRows;
   
   if (intAvailableHeight < 1) // this occurs when the form controls are zero height. Weird.
   {
		intRows = 1;	
   }
   else
   {
		do {
			objInputElement.rows = intRows;
			if (objInputElement.offsetHeight > intAvailableHeight) {
				intRows --;
				intTries --;
			}
			else {
				intRows ++;
				intTries=1;
			}
		}while((intRows > 0) && (intTries > 0));
	
		if (intRows == 0) {
			intRows = 1;
		}		
	}	
	
	objInputElement.style.width = objSpan.offsetWidth - intUsedWidth - CONTROL_MARGIN;
	objInputElement.rows = intRows;

}


//================================================================================================---

function ResizeSelect(objSpan, objInputElement, intUsedWidth, intUsedHeight) {

//Resizes a drop-down list within objSpan.
//The list is sized to take up all the remaining height and width in objSpan.

	objInputElement.style.height = objSpan.offsetHeight - intUsedHeight - CONTROL_MARGIN;
	objInputElement.style.width = objSpan.offsetWidth - intUsedWidth - CONTROL_MARGIN;

}

//================================================================================================---

function ResizeIframe(objSpan, objIframe, intUsedWidth, intUsedHeight) {

//Resizes an Iframe within objSpan.
//The Iframe will contain either a Subform, or a custom control.
	
	var frameID = objIframe.id;

	if(IsSubForm(objSpan)) {
		//Call the sub-form's resize procedures	
		document.frames[frameID].ResizeOrderForm(document.frames[subFormID].document, true);
		document.frames[frameID].ResizeOrderForm(document.frames[subFormID].document);
		
	}
	else {
		//Is a custom control.	
		objIframe.style.width = objSpan.offsetWidth;
		objIframe.style.height = objSpan.offsetHeight;	

		//Raise the resize event to the control
		try {
			document.frames[frameID].Resize();
		}
		catch (err) {}
	}


}

//================================================================================================---

function ResizeLookupSearch(objSpan, objInputElement, intUsedWidth, intUsedHeight, fontSize) {

//Resizes a LookupSearch control within objSpan.
//LookupSearch controls consist of: 
//							<span class="LookupSearchControl">
//								<input type="text"></input>
//								<span type="button"></span>
//							</span>
	
var intCount = new Number;


	//Size the whole lookup search control:
	objInputElement.style.height = objSpan.offsetHeight - intUsedHeight - CONTROL_MARGIN;
	objInputElement.style.width = objSpan.offsetWidth - intUsedWidth -  CONTROL_MARGIN ;

	//Size the box and "find" link
	objInputElement.all[0].style.fontSize = fontSize + 'px';	
	objInputElement.all[0].style.width = objInputElement.offsetWidth - objInputElement.all[1].offsetWidth - CONTROL_MARGIN;
	objInputElement.all[1].style.height = objInputElement.all[0].offsetHeight;
	objInputElement.all[1].style.top = objInputElement.all[0].offsetTop;

}

//================================================================================================---
function ResizeImage(imgElement, fontSize) {

	var newImgSize = fontSize + 5;

	imgElement.style.height = newImgSize;
	imgElement.style.width = newImgSize;

}

//================================================================================================---




//================================================================================================---

function ArrangeSubForm(objIframe, blnResizeNow) {

// A sub form has just been scripted and loaded.  Here we take
// care of sizing it and arranging every other control around it.
// This is done using the design positions and sizes of each control,
// then calling the resize procedures to scale everything to the current
// screen size.

// objIframe: reference to the HTML DOM Iframe element which has just loaded.
//	blnResizeNow: if TRUE, the form is resized immediately.  
	
	
var intTop = new Number();
var blnRearrange = false;
var intPos = new Number();
var callingControlID = new String();
var objControl = new Object();
var controlTop = new Number();
var objThisControlSpan = new Object();
var controlNewTop = new Number();
var intThisControlTop = new Number();
var intHeight = new Number();
var strIframeID = new String();

	//Get a reference to the parent form's BODY element
	//hierarchy is always <body><span><iframe></iframe></span></body> so we know that
	// objIframe.parentElement.parentElement refers to the body.
	var objBody = objIframe.parentElement.parentElement;

	//Get the required position from the containing ControlSpan element.
	//for certain positions, the calling control is stored as "position:controlid"
	var framePosition = objIframe.parentNode.getAttribute('position');
	intPos = framePosition.indexOf(':');
	if (intPos > -1) {
		callingControlID = framePosition.substring(intPos + 1, framePosition.length);
		objControl = objBody.all[callingControlID]
		framePosition = framePosition.substring(0, intPos)
	}
	framePosition = framePosition.toLowerCase();

	//Get the design height of the new form
	var frameID = objIframe.id;
	var objLayout = document.frames[frameID].document.all['layoutData'].XMLDocument.selectSingleNode('xmldata/layout');
	var subFormDesignHeight = objLayout.getAttribute("height");
	var subFormDesignWidth = objLayout.getAttribute('width');

	// Now position the new Iframe:
	switch (framePosition) {
		case 'top':
			//the very top of the form
			intTop = 0;
			blnRearrange = true;
			break;
		
		case 'next':
			//immediately below the calling control
			intTop = eval(objControl.getAttribute('top')) + eval(objControl.getAttribute('height')) + CONTROL_SPACING;
			blnRearrange = true;	
			break;
			
		case 'bottom':	
			//bottom of the form; immediately after the
			//lowest control.
			//Find the lowest control:
			intTop = 0;
			for (intCount = 0; intCount < formBody.all.length; intCount++) {

				if (IsControl(objBody.all[intCount])) {

					intThisControlTop = eval(objBody.all[intCount].getAttribute('top'));

					if (intThisControlTop > intTop)	{
						intTop = intThisControlTop;
						intHeight = eval(objBody.all[intCount].getAttribute('height'));
					}						
				}
			}
			//Add the height of the lowest control, plus a spacer.
			intTop += eval((intHeight + CONTROL_SPACING));
			break;
	}

	//Set up the new tabindexes
	void ShuffleTabIndex(framePosition, objControl, objIframe);

	//now re-arrange the parent form.  We do this by modifying the design Top
	//attributes of all of the controls, and calling the resize procedures.
	if (blnRearrange) {

		for (intCount = 0; intCount < objBody.all.length; intCount++) {
			objThisControlSpan = objBody.all[intCount];
			if (IsControl(objThisControlSpan)) {
				controlTop = eval(objThisControlSpan.getAttribute('top'));
				
				if (controlTop >= (intTop)) {
					//If this control is below the top of where the frame has
					//been inserted, increase its design top attribute to move it
					//downwards.
					controlNewTop = (eval(controlTop) + eval(subFormDesignHeight));
					objThisControlSpan.setAttribute('top', controlNewTop);
					
					//Store the original position of the control in case the form is removed.
					objThisControlSpan.setAttribute('originaltop', controlTop);
				
				}
			}	
			
		}
	}	

	//Store the new form's top and size in its controlspan.
	objIframe.parentElement.setAttribute('height', subFormDesignHeight);
	objIframe.parentElement.setAttribute('top', intTop);	
	objIframe.parentElement.setAttribute('width', subFormDesignWidth);

	//Set up the Iframe with the design positioning
	strIframeID = objIframe.id;

	if (blnResizeNow) {
		//Resize the frame if specified.
		document.frames[strIframeID].ResizeOrderForm(document.frames[strIframeID].document, true);
		//Finally, resize everything as specified:
		//Default pass - ensures we get resizing even if window size is too small to fit everything in.
		ResizeOrderForm (objBody.parentElement,true);				
		//This pass then does the proportional sizing where possible.
		ResizeOrderForm(objBody.parentElement);	
	}		
}

//================================================================================================------

function ShuffleTabIndex(newFramePosition, objCallingControl, objSubForm ) {

//As a new sub form is incorporated into the main form, we re-arrange
//the tab indexes so that it appears seamlessly in the tab order.
//Done as a separate loop to the positional suffling as there is
//not necessarilly a relationship between screen position and tab
//order, although in practice there usually will be.

//	newFramePosition: 	string specifying the position the sub form 
//								has been inserted ('top', 'bottom', 'next').
//	objCallingControl:	HTML DOM controlSpan element which inserted the subform.
//	objSubForm:				HTML DOM Iframe element containing the subform.
//
//	Returns: void.

var insertedTabIndex = new Number();
var intTemp = new Number();
var blnShuffle = false;
var intCount = new Number();
var objInputElement = new Object();

	switch (newFramePosition) {
		case 'top' :
			//Frame is inserted at the very top.  It becomes tabindex 1, 
			//all other control's tabindexes are incremented.	
			insertedTabIndex = 1;
			blnShuffle = true;
			break;
			
		case 'next':
			//Frame inserted after the calling control.  It's tab index becomes
			//that of the calling control + 1
			objInputElement = GetInputElementFromSpan(objCallingControl);
			intTemp = objInputElement.tabIndex;
			insertedTabIndex = intTemp + 1;
			blnShuffle = true;
			break;
			
		case 'bottom':
			//Frame inserted at the bottom.  Its tab index is 1 more than the last
			//tabindex on the form.
			intTemp = -1;
			for (intCount = 0; intCount < formBody.all.length; intCount ++) {
				if (formBody.all[intCount].tabIndex > intTemp) {
					//Store the largest tabindex yet found.
					intTemp = formBody.all[intCount].tabIndex;
				}
			}
			insertedTabIndex = intTemp + 1;
			break;			
	}

	//Now shuffle following controls down the order if required
	if (blnShuffle) {
		for (intCount=0; intCount < formBody.all.length; intCount++ ){
			if (formBody.all[intCount].tabIndex >= insertedTabIndex) {
				formBody.all[intCount].tabIndex++ ;
			}
		}
	}
	
	//Finally set the tab index of the subform
	objSubForm.tabIndex = insertedTabIndex;		
}
