/*
													DssChecks.js

	Shared script to be used for performing all decision support checking, 
	and handling the results.

	Internal functions are all prefixed with DSS_

	Modification History:
	08Nov03 AE  Written

*/

var OCSEVENT_ONSELECT = 'onSelection';
var OCSEVENT_ONCOMMIT = 'onCommit';

//==================================================================================================
//											Public Functions
//==================================================================================================
function DssChecks_onSelection(SessionID, OCSType, OCSTypeID) {

//Do onSelection checks.
	var strReturn = DSS_ShowChecksPageModal(SessionID, OCSType, OCSTypeID, OCSEVENT_ONSELECT);
	
}

//==================================================================================================
//											Internal Functions
//==================================================================================================

function DSS_ShowChecksPageModal(SessionID, OCSType, OCSTypeID, EventName) {
	
//Do the checks using the modal page DssChecks.aspx.
//We create this as a very small page at the bottom of the screen, 
//so that if no checks are done, or all checks are passed, it 
//does not get in the way.
//The page will expand itself if there is anything of interest to display.
	
	var strURL = 'DoseChecks.aspx' 
				  + '?SessionID=' + SessionID
				  + '&OCSType=' + OCSType
				  + '&OCSTypeID=' + OCSTypeID
				  + '&OCSEvent=' + EventName;
	
	var strReturn = window.showModalDialog(strURL, '',DSS_DoseChecksFeatures() ); 
	if (strReturn == 'logoutFromActivityTimeout') {
		strReturn = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}

//==================================================================================================

function DSS_DoseChecksFeatures() {
	
	var intHeight = 50;
	var intWidth = 100;
	var intTop = screen.availHeight - intHeight;
	var intLeft = screen.availWidth - intWidth;
	
	var strFeatures =  'dialogHeight:' + intHeight + 'px;' 
						 + 'dialogWidth:' + intWidth + 'px;'
						 + 'dialogTop:' + intTop + ';'
						 + 'dialogLeft:' + intLeft + ';'
						 + 'resizable:yes;unadorned:no;'
						 + 'status:no;help:no;';			
	
	return strFeatures;	
}

//==================================================================================================

