
//Max / Minimum limits for sizing
//var MIN_INPUT_WIDTH = 60;		
var MAX_FONT_SIZE = 20;											

//Spacing between controls within a span (prevents wrapping behaviour)
var CONTROL_SPACING = 10;

//------------------------------------------------------------------------------------------------

function ResizeOrderForm() {

//Re-arrange the controls according to the size of the containing DIV

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

	//Available height/width
	var formWidth=orderFormDiv[m_currentFormIndex].offsetWidth;
	var formHeight=orderFormDiv[m_currentFormIndex].offsetHeight;

	//Height/width the form was designed in
	//var objLayout = orderFormData[m_currentFormIndex].XMLDocument.selectSingleNode('xmldata/layout');
	var strFrame = 'orderForm' + m_currentFormIndex
	var objLayout = document.frames(strFrame).document.all('layoutData').xmlDocument.selectSingleNode('xmldata/layout');
	var designFormWidth=objLayout.getAttribute('width');
	var designFormHeight=objLayout.getAttribute('height');
	
	//Now re-calculate each control's position and size so that they
	//are proportionally the same in the new resolution.
	objSpan=orderFormDiv[m_currentFormIndex].firstChild;

	while (objSpan !=	null) {
						
		if(IsControl(objSpan)) {
		//Ignore anything which isn't a control span

			//design-time top,left and size of this control
			designLeft = eval(objSpan.getAttribute('left'));
			designTop = eval(objSpan.getAttribute('top'));
			designHeight = eval(objSpan.getAttribute("height"));
			designWidth = eval(objSpan.getAttribute("width"));

			//calculate new co-ordinates:
			newLeft = (designLeft/designFormWidth) * formWidth;
			newTop = (designTop/designFormHeight) * formHeight;
			newWidth = (designWidth/designFormWidth) * formWidth;
			newHeight = objSpan.offsetHeight
								
			//Apply the new sizing.  This is applied to the 
			//style collection and hence overwrites the design-time values
			//which are held in the height/width attributes of the tag.
			objSpan.style.left = newLeft;
			objSpan.style.top = newTop;			
			objSpan.style.width = newWidth;

			//Now size the contents of the control.
			SizeInputControl (objSpan,formHeight,formWidth);


		}
		//get the next control
		objSpan=objSpan.nextSibling;
	}
}


//------------------------------------------------------------------------------------------------

function IsControl(objElement) {

//Returns TRUE if the element specified in objElement is 
//a ControlSpan class element.

var thisClassName=new String();
var blnReturn = false;

	thisClassName=objElement.className;
	thisClassName = thisClassName.toLowerCase();
	if(thisClassName=='controlspan') {
		blnReturn=true;
	}
	return blnReturn;

}

//------------------------------------------------------------------------------------------------

function SizeInputControl(objSpan_IN, formHeight_IN, formWidth_IN) {

//The given span has been sized according to the size of the form.
//we now size the input control to take up the available
//horizontal space in the span.
//Text boxes, date fields, time fields and combos are resized.  Other 
//controls are not. They automatically size themselves when their font
//size is set (eg buttons, labels)

var thisTagName = new String();
var thisType=new String();
var intResizeIndex=0;
var intCount = 0;
var intWidth = new Number();
var newWidth = new Number();
var blnLabelOnTop = false;
	
	//Calculate the font size to use
	var newFontSize = GetFontSize(formHeight_IN, formWidth_IN);
	
	for (intCount =0; intCount < objSpan_IN.childNodes.length; intCount++ ) {
		thisTagName = objSpan_IN.childNodes[intCount].tagName;

		if (thisTagName != undefined) {
		//closing tags are included in the childNodes collection
	
			//Update the font size of this control 
			objSpan_IN.childNodes[intCount].style.fontSize = (newFontSize);

			//is this tag one of the controls we resize?	
			thisTagName = thisTagName.toLowerCase();

			switch (thisTagName) {
				case 'textarea' :
					intResizeIndex=intCount;
					break;					

				case 'input':
				//Check if this is a text box
					thisType = objSpan_IN.childNodes[intCount].getAttribute('type');
					thisType=thisType.toLowerCase();
					if (thisType=='text') {
					//if so, this is the control we resize.
						intResizeIndex=intCount;
					}
					else {
					//otherwise, it is unresizable content
						intWidth += objSpan_IN.childNodes[intCount].offsetWidth + CONTROL_SPACING;
					}
					break;
					
				case 'select':
					intResizeIndex=intCount;
					break;
					
				case 'br':																												
				//the presence of a <br> indicates that the label is along the top of the control,
				//rather than at the left-hand side.
					blnLabelOnTop = true;
					break;
					
				default:
				//Other controls are here just treated as padding, taking up
				//the space in the span.  Labels are the prime example of this
					if (objSpan_IN.childNodes[intCount].offsetWidth > 0) {
						intWidth += objSpan_IN.childNodes[intCount].offsetWidth + CONTROL_SPACING;			
					}
			}

		}

	}


	if (intResizeIndex > 0 ) {
		//resize this control to fit the available space in the span.		
		if (blnLabelOnTop) {
			newWidth = objSpan_IN.offsetWidth ;		
		}
		else {
			newWidth = (objSpan_IN.offsetWidth - intWidth );
		}		

		objSpan_IN.childNodes[intResizeIndex].style.width = newWidth;
				
	}


}

//---------------------------------------------------------------------------------------------------

function GetFontSize(formHeight_IN,formWidth_IN) {

//Calculates the font size in Pixels from the dimensions of the order form.
	
var newFontSize

	newFontSize = formHeight_IN / 25
	if (newFontSize > MAX_FONT_SIZE) {
		newFontSize=MAX_FONT_SIZE;
	}
	newFontSize += 'px' ;
	return newFontSize;
	
}


//---------------------------------------------------------------------------------------------------

