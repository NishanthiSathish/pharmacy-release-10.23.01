//-------------------------------------------------------------------------------------------
//												TouchscreenShared.js
//
//	Shared touchscreen routines.
//	
//	HighlightButton()								onmouseover event handler for buttons
//	UnhighlightButton()							onmouseout event handler for buttons
//	ButtonDown()									onmousedown event handler for buttons
//	ButtonUp()										onmouseup event handler for buttons
//
//
//	TouchNavigate(strURL);						Navigate to another page. Use this instead of TouchNavigate();
//															for touchscreen apps, because it calls...
//	DisableButtons()								disable all buttons on a page.  Call immediately before
//															navigating to another page.
//
//-------------------------------------------------------------------------------------------
//									Navigation
//-------------------------------------------------------------------------------------------
function TouchNavigate(strURL){
//navigate to a new page.  Deals with disabling stuff while
//we're waiting for the page to load.	
	void DisableButtons();
	void window.navigate(strURL);
}

//-------------------------------------------------------------------------------------------
//									Highlighting gubbins
//-------------------------------------------------------------------------------------------
function HighlightButton(objSrc){

	//if (objSrc.className.indexOf(' inactive' == '0')){
	if (!objSrc.disabled){
		objSrc.className+=' Hover';
	}
}
//-------------------------------------------------------------------------------------------
function UnhighlightButton(objSrc){
	objSrc.className = objSrc.className.split(' Hover')[0];
}	
//-------------------------------------------------------------------------------------------
function ButtonDown(objSrc){
	objSrc.className+=' Mousedown';
}
//-------------------------------------------------------------------------------------------
function ButtonUp(objSrc){
	objSrc.className = objSrc.className.split(' Mousedown')[0];
}

//----------------------------------------------------------------------------------------------
function EnableButton(objButton, blnEnable){
//Enable/disable a button.  Try to do this server side where possible, this is only to be used
//where client-side code is suitable, such as for page up / down.
	objButton.disabled = !blnEnable;
	var strFilter = 'progid:DXImageTransform.Microsoft.BasicImage(grayscale=1)';
	if (blnEnable){
		 strFilter = '';	
	}
	else {
		UnhighlightButton(objButton);
	}
	objButton.all['imgScroll'].style.filter = strFilter;

}
//----------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------
//				Disabling; call this immediately before navigating to another page
//-------------------------------------------------------------------------------------------
function DisableButtons(){

//06Feb07 AE  Restructured; now only disables TouchButton elements
var blnDisable = false;
var intCount = 0;

	var colAll = document.body.all;
	for (intCount = 0; intCount < colAll.length; intCount++){
		if (colAll[intCount].className.toLowerCase().indexOf('touchbutton') >= 0) {
			DisableElement(colAll[intCount]);
		}
	}
	
	
	
}

//-------------------------------------------------------------------------------------------
function DisableElementChildImages(objElement){

var intCount = 0;
	
	var colChildren = objElement.getElementsByTagName('img');
	for (intCount = 0; intCount < colChildren.length; intCount++){
//		if (objElement.tagName.toLowerCase() == 'img'){
			colChildren[intCount].style.filter = 'progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);';	
//		}	

	}
}

//-------------------------------------------------------------------------------------------
function DisableElement(objElement){

//disable the current element, change mouse cursor, 
//grey out images.
	objElement.disabled = true;
	void UnhighlightButton(objElement);
	objElement.className += ' inactive';
	objElement.style.cursor = 'wait';
	DisableElementChildImages(objElement);

}