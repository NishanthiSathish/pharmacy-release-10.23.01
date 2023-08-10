//==================================================================================================
//
//		Provides standard functions to handle the SaveResults page.
//		Expects that a function exists on the parent page called 
//
//		DssResults_onClick(blnContinue).
//
//		This is called when the buttons on the save results page are called
//
//==================================================================================================


var m_objIframe;

function DisplaySaveResults(objIframe, intTop, intLeft, intWidth, intHeight) {

//Assumes that the results page has been hosted in an iframe.
//Displays the Iframe centralised over the page.

//09Mar04 AE  Added optional left, top, width, height.  These can be used to override
//					the default, central position.

//Store the reference to the Iframe so that the HideSaveResults method
//knows what it's called.
    m_objIframe = objIframe;

//Work out where to stick it
    if (intHeight == undefined) {
        intHeight = (document.body.offsetHeight * 2 / 3);}
    if (intWidth == undefined) {
        intWidth = (document.body.offsetWidth * 2 / 3);}
    if (intTop == undefined) {
        intTop = (document.body.offsetHeight - intHeight) / 2;}
    if (intLeft == undefined) {
        intLeft = (document.body.offsetWidth - intWidth) / 2;}

//alert('intHeight: '  + intHeight + '\n' + 'intWidth: ' + intWidth + '\n' + 'intTop: ' + intTop + '\n' + 'intLeft: ' + intLeft);

//And stick it there
    objIframe.style.top = intTop;
    objIframe.style.left = intLeft;

    objIframe.style.height = intHeight;
    objIframe.style.width = intWidth;
	
//Force the frame to display by changing its class
	objIframe.className = 'SaveResultsFrame_Display';
	
//frig
    objIframe.style.display = 'block';

}


//==================================================================================================

function HideSaveResults() {
	
	m_objIframe.className = 'SaveResultsFrame_Hide';
	m_objIframe.style.display = 'none';
	//belt n braces - the 'display' attribute of SaveResultsFrame_Hide																		
	//is not always honoured when changing classes 																			
}

//==================================================================================================

function DssResultsButtonHandler(blnContinueAnyway) {
    
//Occurs when one of the Yes/No buttons on the Dss results page
//is clicked.  
//	blnContinueAnyway is true if they chose to continue regardless
//26Jul05 AE  Corrected to call DssResults_onClick on this window, not window.parent.
//				  was working because all windows it was used on were top level themselves.

	//This is a temporary bit of code to check if the event handler
	//procedure exists, and warn the developer if not.
	var objFunction = DssResults_onClick;
	if (objFunction == undefined) {
	    alert('Event handler DssResults_onClick() needs defining in ' + window.document.URL);
	}
	else {
		//Hide the results page, then call the event handler
		void HideSaveResults();
		void DssResults_onClick(blnContinueAnyway);
	}	
}

// F0106786 ST 21Jan11 Added method to allow copying of celldata to the clipboard
// Copies the innertext of the passed in cell to the clipboard
// Takes into account that there might be multiple rows with the same name 
// and cycles through those building up a string to copy.
function DssResultsCopyDataToClipboard(cellData) {
    var returnString = '';
    
    if(cellData.length > 0) {
        for (var idx = 0; idx < cellData.length; idx++) {
            if (returnString != '') {
                returnString += '\r\n' + cellData[idx].innerText;
            }
            else {
                returnString = cellData[idx].innerText;
            }
        }
    }
    else {
        returnString = cellData.innerText;
    }

    if (window.clipboardData.setData('Text', returnString)) {
        alert('Details have been copied to the clipboard');
    }
}
