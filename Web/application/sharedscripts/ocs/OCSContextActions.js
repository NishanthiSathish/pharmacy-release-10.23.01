/*------------------------------------------------------------------------------------------------------

													OCS CONTEXT ACTIONS
													
	Single script which deals with determining which actions can be taken on a given item, 
	and providing methods to do those actions.

	Use this whenever using generic context menus on order comms items.
	There are two sets of methods; ones dealing with single items, and ones dealing with collections of items.
	The latter all have the prefix "_Batch", and would be used in conjunction with a multiselect grid.

	The script provides the following "public" methods:
	
	OCSActionAvailable(actionType, xmlItem, xmlType)								-- Central point for determining if a given action can be
	OCSActionAvailable_Batch(actionType, colItems, DOMTypes)						-- performed on a given item or items.
	
	OCSAction(actionType, xmlItem, xmlType)											-- Central point for performing actions on Order Comms Items.
	OCSAction_Batch(actionType, colItems, DOMTypes)									-- (eg, view, copy, result etc).
																									--	returns false if the action is not valid, 'cancel' if the user
																									-- cancells the action, blank string on success.

	OCSShowContextMenu(SessionID, xmlItem, xmlType, x, y, fpRefresh)			-- Displays a context (right click) menu suitable for the item or items specified
	OCSShowContextMenu_Batch(SessionID, colItems, DOMTypes, x, y, fpRefresh)
	
	
	
	Modification History:
	14Sep04 AE  Written; consolidating worklist.js and the evils of the PRV into one script of purity.
	29Sep04 AE  Corrected refresh handling; no longer refreshes if an action is cancelled.
	09Feb05 AE  Approve / Annotate: Now allows the attaching of notes to ordersets.
	03Nov05 PH  PrintProcessors iframe moved to ICW subframe, so will always be available
	06Feb06 AE  Added _Batch methods to deal with multiselect
	10Mar06 ST  Amended OCS_VIEW in OCSActionAvailable() to trap any items with '0' for selected attributes.
	            In particular imported v8 patient pmr data.
    31Aug11 XN  12166 - Selecting the header on the current medication with few more prescriptions and view gives error	    
    22Feb12 CJM TFS24305 - Added TrackChanges parameter to OCSAction_Batch, then  passed through as a parameter to all methods that call OrderEntry()        
	
------------------------------------------------------------------------------------------------------*/
//Action Constants; these specify the actions which can be taken.
var OCS_VIEW = 100;												//28Mar03 AE  Changed; order entry will figure out if this is a request or response, we don't need to care here
var OCS_REQUEST_REORDER =200;
var OCS_RESPOND_TO =300;
var OCS_ANNOTATE = 700;
var OCS_VIEW_REQUEST = 800;
var OCS_CANCEL = 900;											//07Aug03 AE  Added cancellations 
var OCS_TOGGLE_SUSPENSION = 910;								//21Feb07 CJM Added Suspensions
var OCS_CANCEL_AND_REORDER = 1000;
var OCS_PRINTTHIS = 1100;										//13Sep03 AE  Added printing
var OCS_PRINTRESULTS = 1110;
var OCS_APPROVE = 1300;											//02Dec03 PH  Allows order to be approved
var OCS_DEAPPROVE = 1350;										//09Feb05 AE  Allows orders to be marked for intervention (unnaproved)
var OCS_DSSREASON = 1400;										//17Jan07 ST  Added to allow viewing dss override reason
var OCS_SUPPLY_REQUEST = 1450;
var OCS_PBS_REQUEST = 1460;
var OCS_PBS_PRINT = 1470;
var OCS_RECONCILE = 1500;                                       //26Jun12 Rams Added to Reconcile medications
var OCS_REVIEWREQUEST = 1510;
var OCS_PRINT_NAMED_REPORT_FOR_EPISODE = 9;

//Variables used to hold the current item during
//whilst showing a context menu
var m_SessionID = new Number();

var m_colItems;
var m_DOMTypes;

var DEFAULT_TRACKCHANGES_VALUE = "Hide Changes";

var m_IsSingleItemSelected = false;
var m_IsOrderSetSelected = false;


//=================================================================================================
//											Public Functions
//=================================================================================================

function OCSActionAvailable(actionType, xmlItem, xmlType)
{
//Determines if the specified action can be taken on the given item.	
	//Note that this does not include role/security checking, that should be implemented
	//on the calling page.
	//
	//actionType - one of the Action Constants defined at the top of this file
	//xmlItem - iXMLDomElement holding the row definition.  Must contain the attributes as
	//				defined in QueryValidation.vb
	//xmlType - iXMLDomElement containing the type (RequestType, NoteType, ResponseType) row for the given item.

	// F0045558 19-03-09 PR Added discharge summary check so that unable to copy, amend or cancel a discharge summary

	var blnAvailable = false;
	var strClass = '';
	var blnIsOrderset = false;
	var blnIsMortal = false;
	var blnIsCancelled = false;
	var blnHasResults = false;
	var blnOrderable = false;
	var blnApproved = false;
	var blnSuspended = false;
	var blnContinuous = false;
	var blnFullyResulted = false;
	var blnDischargeSummary = false;
	var blnSingleItem = false;
	var blnCanStopOrAmend = true;
    var blnCanStop = false;
	var blnExpired = false;
	var blnCancelled = false;
	var blnPrescription = false;
	var blnCanCopy = false;
	var blnCanCreatePBSRequest = false;
	var strRequestType;
	var blnCanDoReviewRequest = false;

	if (xmlItem != undefined && xmlItem != null)
	{
		blnIsMortal = (xmlItem.getAttribute('Mortal') == '1');
		blnIsCancelled = (xmlItem.getAttribute('Cancelled') == '1');
		blnHasResults = (xmlItem.getAttribute('Responses') == '1');
		blnApproved = (xmlItem.getAttribute('Approved') == '1');
		blnSuspended = (xmlItem.getAttribute('Suspended') == '1');
		blnContinuous = (xmlItem.getAttribute('Continuous') == '1');
		blnFullyResulted = (xmlItem.getAttribute('FullyResulted') == '1');
		blnDischargeSummary = (xmlItem.getAttribute('RequestType') == 'Discharge Summary');
		blnSingleItem = ((xmlItem.getAttribute('RequestType') != 'Order set') && (xmlItem.getAttribute('RequestID_Parent') == '0'));
		blnCanStopOrAmend = (xmlItem.getAttribute('CanStopOrAmend') == null || xmlItem.getAttribute('CanStopOrAmend') == '' || xmlItem.getAttribute('CanStopOrAmend') == '1');
		blnCanStop = xmlItem.getAttribute('CanStop') == '1';
		blnCanCopy = (xmlItem.getAttribute('CanCopy') == null || xmlItem.getAttribute('CanCopy') == '' || xmlItem.getAttribute('CanCopy') == '1');
		blnCanDoReviewRequest = (xmlItem.getAttribute('CanDoReviewRequest') == '1');
		//blnExpired = (xmlItem.getAttribute('Expired') == null || xmlItem.getAttribute('Expired') == '' || xmlItem.getAttribute('Expired') == '1');
		if ((xmlItem.getAttribute('Expired') == null || xmlItem.getAttribute('Expired') == '' || xmlItem.getAttribute('Expired') == '0'))
		{
			blnExpired = false;
		}
		else
		{
			blnExpired = true;
		}

		blnCancelled = (xmlItem.getAttribute('Cancelled') == null || xmlItem.getAttribute('Cancelled') == '' || xmlItem.getAttribute('Cancelled') == '1');
		if (xmlItem.getAttribute('RequestType'))
		{
			blnPrescription = (xmlItem.getAttribute('RequestType').indexOf('Prescription', 0) > 0) || (xmlItem.getAttribute('RequestType') == 'Product Order'); // TFS41942 XN 22Aug12 Allow supply request to work with prescription
		}

		blnCanCreatePBSRequest = (xmlItem.getAttribute('CanCreatePBSRequest') == '1');
	}
	if (xmlType != undefined && xmlType != null)
	{
		strClass = xmlItem.getAttribute("class");
		blnIsOrderset = IsOrderSet(xmlType);
		blnOrderable = (xmlType.getAttribute('Orderable') == '1');
		strRequestType = xmlItem.getAttribute('RequestType');
	}

	switch (actionType)
	{
		//20Jun13 YB TFS66805 - Print is enabled only for viewable items
	case OCS_VIEW:
	case OCS_PRINTTHIS:
		//View an item - always available	
		//10Mar06 ST    Traps any items with 0 tableid, notetypeid and productid/
		//              In particular imported v8 patient pmr data.
		if ((xmlItem.getAttribute('tableid') == '0' && xmlItem.getAttribute('NoteTypeID') == '0' && xmlItem.getAttribute('productid') == '0'))
		{
			blnAvailable = false;
		}
		else
		{
			// 12Apr11 PH Prevent Adminsitration Responses being viewed
			blnAvailable = true;
			if (strClass == "response")
			{
				switch (xmlItem.getAttribute('ResponseType'))
				{
				case "Administration Standard":
				case "Administration Doseless":
				case "Administration Infusion":
				case "Administration Simple":
					blnAvailable = false;
					break;
				}
			}
			else if (strClass == "request") // TFS41790 21Aug12 XN When viewing supply request show parent prescription so as interim fix disabled viewing of supply request
			    blnAvailable = (xmlItem.getAttribute('CanView') == null || xmlItem.getAttribute('CanView') == '1');
		}

		//05Aug13   Rams    this check was removed as a result of combining the view and print this functionality for TFS66805
		if (actionType == OCS_PRINTTHIS && blnAvailable)
		{
			blnAvailable = (xmlItem.getAttribute('RequestType') != 'Generic Order') && (xmlItem.getAttribute('RequestType') != 'Prescription Request');
			//05Aug13   Rams    69712 - bug - printing of discontinued items.
			if (blnAvailable && (xmlItem.getAttribute('RequestType') == 'PBS Request'))
				blnAvailable = !blnCancelled;
		}

		break;

	/*case OCS_PRINTTHIS:

	        //22Mar11   Rams    F0112505 - Freetext Order does not printout a modality report when selecting Print Item from the worklist
	        blnAvailable = (xmlItem.getAttribute('RequestType') != 'Generic Order') && (xmlItem.getAttribute('RequestType') != 'Prescription Request');

	        break;*/
	case OCS_PBS_PRINT:
		blnAvailable = (xmlItem.getAttribute('RequestType') == 'PBS Request' && !blnCancelled && (xmlItem.getAttribute('CanView') == null || xmlItem.getAttribute('CanView') == '1'));
		break;
	case OCS_VIEW_REQUEST:
		//View request for a response; only for responses!
		blnAvailable = (strClass == 'response');
		break;


	case OCS_REQUEST_REORDER:
	    
		//Copy an item; only for requests which are orderable
		//24Jun13   Rams    Allow cancelled PBS Request to copy (Done against the TFS 66979 - Error when amending a Pbs request.)
	    var IsPBSRequest = (strRequestType == 'PBS Request');
	    
        //30Jul15   Rams    119522 - temporary fix to stop copying options orderset and orderset and stop copying individual items in options orderset if it is prescribed on different episode
	    if (blnCanCopy && (xmlItem.getAttribute('ContentsAreOptions') == "1" || xmlItem.getAttribute('IsOptionsSetChild') == "1" || blnIsOrderset)) {
	        blnCanCopy = GetKey(document.body["sid"], "Episode") == EpisodeIDFromRow(xmlItem);	        
	    }
	    blnAvailable = ((strClass == 'request' || strClass == 'note') && blnOrderable && !blnDischargeSummary && blnCanCopy && (IsPBSRequest || !blnIsCancelled || blnSingleItem)) ;

		//29Nov2012 Rams    Commented the following as the it was decided not to allow copy of cancelled items, and uncommented the above line.(against TFS 50014)
		//blnAvailable = (strClass == 'request' && blnOrderable && !blnDischargeSummary && blnCanCopy);
		break;

	case OCS_CANCEL:
		//Cancel; only for individual requests which are orderable, and not canceleld, and now notes too!
		blnAvailable = strRequestType != 'PN Prescription' && strRequestType != 'PN Regimen' && ((strClass == 'request' && blnOrderable && blnIsMortal && !blnFullyResulted && !blnDischargeSummary && (blnCanStopOrAmend || blnCanStop) && !blnExpired) || strClass == 'note' || (strRequestType == 'Supply Request' && !blnCancelled));
		break;

	case OCS_TOGGLE_SUSPENSION:
		//Suspend/Unsuspend: only available if request can be suspended and when it has not expired
		blnAvailable = false;
		if (xmlItem.getAttributeNode('Suspended') != null)
		{
			if ((strClass == 'request') && blnIsMortal && !blnExpired && !blnFullyResulted)
			{
				if (xmlItem.getAttribute('StatusNotesDisabled') != "1")
				{
					var strRequestType = xmlItem.getAttribute('RequestType');
					//31Jan2014     Rams    83488: Inability to suspend Enteral infusions or bolus(Added Enteral Prescriptions to the list of type that are allowed for suspension)
					if (xmlItem.getAttribute('IsOptionsSetChild') != '1' && ((strRequestType == 'Standard Prescription') || (strRequestType == 'Doseless Prescription') || (strRequestType == 'Infusion Prescription') || (strRequestType == 'Generic Prescription') || (strRequestType == "Order set" && xmlItem.getAttribute('ContentsAreOptions') == "1") || (strRequestType == "Enteral Prescription")))
					{
						if (!blnContinuous)
						{
							blnAvailable = true;
						}
					}
				}
			}
		}
		break;

	case OCS_CANCEL_AND_REORDER:
		//Cancel & reorder; only for individual requests or notes which are not cancelled, and orderable
		// 28664 CD 16 Jan 2013 - allow amend for notes
		blnAvailable = strRequestType != 'PN Prescription' && strRequestType != 'PN Regimen' && ((strClass == 'request' || strClass == 'note') && blnOrderable && (blnIsMortal || strClass == 'note') && !blnFullyResulted && !blnDischargeSummary && blnCanStopOrAmend && !blnExpired);
		break;

	case OCS_RESPOND_TO:
		//Respond to a Request or note
		switch (strClass)
		{
		case 'request':
			var blnCanRespond = (xmlType.getAttribute('ManualResponse') == '1');
			blnAvailable = (blnCanRespond && !blnIsCancelled && !blnIsOrderset);
			break;

		case 'note':
			blnAvailable = (xmlType.getAttribute('Response') == '1');
			break;
		}
		break;

	case OCS_ANNOTATE:
		//View / Edit attached notes
		blnAvailable = ((strClass == 'request' || strClass == 'response')); //09Feb05 AE  Removed !blnIsOrderset, as you can attach notes to a whole protocol, for example.
		break;

	case OCS_DSSREASON: // 17Jan07 ST  Added to handle dss warning override reason
		blnAvailable = ((strClass == 'request' || strClass == 'response'));
		break;


	case OCS_PRINTRESULTS:
		//Print results; only for orders which have been resulted
		// blnAvailable = blnAvailable = ((document.all['fraPrintProcessor'] != undefined) && blnHasResults);
		blnAvailable = blnHasResults; //06Feb06 AE  PrintProcessor may always exist, but item doesn't always have results!  Corrected logic.  03Nov05 PH PrintProcessor moved to ICW subframe, so will always exist
		break;

	case OCS_SUPPLY_REQUEST:

		if (blnExpired || blnCancelled || !blnPrescription)
		{
			blnAvailable = false;
		}
		else
		{
			blnAvailable = true;
		}
		break;

	case OCS_PBS_REQUEST:
		// Task 66563 YB 17Jun2013 - Only enable if blnCanCreatePBSRequest is true for a prescription
		if (!blnPrescription || !blnCanCreatePBSRequest)
		{
			blnAvailable = false;
		}
		else
		{
			blnAvailable = true;
		}
		break;

	case OCS_RECONCILE:
		//13Jul12    Rams    32154 - Ability to amend, copy and discontinue all prescription creation types on a patient in a non-electronic  prescribing location as a User with Transcription creation only rights and have the active item saved as a Transcription
		blnAvailable = ((strClass == 'request') && blnOrderable && blnIsMortal && !blnFullyResulted && !blnDischargeSummary && blnCanStopOrAmend);

		//30Jul15   Rams    119522 - temporary fix to stop copying options orderset and orderset and stop copying individual items in options orderset if it is prescribed on different episode
		if (blnAvailable && (xmlItem.getAttribute('ContentsAreOptions') == "1" || xmlItem.getAttribute('IsOptionsSetChild') == "1" || blnIsOrderset)) {
		    blnAvailable = GetKey(document.body["sid"], "Episode") == EpisodeIDFromRow(xmlItem);
		}
        
        break;

    case OCS_REVIEWREQUEST:
        blnAvailable = ((strClass == 'request') && blnCanDoReviewRequest);
        break;

	case OCS_PRINT_NAMED_REPORT_FOR_EPISODE:
		if (xmlItem == undefined || xmlItem == null)
		{
			blnAvailable = false;
		}
		else
		{
			var episodeId = EpisodeIDFromRow(xmlItem);
			blnAvailable = episodeId > 0;
		}

		break;
	}

	return blnAvailable;
}

//--------------------------------------------------------------------------------------------------------

function OCSActionAvailable_Batch_ChekcEpisode(actionType, colItems, DOMTypes, episodeIdInContext) {
    //
    //This is just a wrapper for OCSActionAvailable_Batch with episodeId checking enabled
    //
    //actionType - one of the Action Constants defined at the top of this file
    //colItems 	- iXMLDomNodeList of elements, each holding a row definition.  Must contain the attributes as
    //					defined in QueryValidation.vb
    //DOMTypes 	- iXMLDomDocument containing a list of types (RequestType, NoteType, ResponseType) for each 
    //					of the items in colItems

    var i = 0;
    var blnAvailable = false;
    var rowEpisodeId;
    m_IsSingleItemSelected = false;
    m_IsOrderSetSelected = false;

    if (colItems.length == 0 || episodeIdInContext == undefined || episodeIdInContext == null || episodeIdInContext <= 0) {
        return false;
    }
    //Only certain actions can be performed on multiple items:
    switch (actionType) {
        case OCS_RECONCILE:
            for (i = 0; i < colItems.length; i++) {
                blnAvailable = false;
                if (colItems[i].getAttribute("class") != 'request') break;

                rowEpisodeId = colItems[i].getAttribute("EpisodeID");
                // If episodeId of the selected row matches with the current episode in context
                if (rowEpisodeId == undefined || rowEpisodeId == null || rowEpisodeId == episodeIdInContext) {
                    break;
                }
                else {
                    blnAvailable = true;
                }

                //check if Prescription and Ordersets are both selected, 
                // if both are selected, Reconcile button will be disabled, as the workflow for both are different
                /* Currently the different ways of handling orderset and single items are not needed as the logic for handling the Ordersets were changed
                if (colItems[i].getAttribute("RequestID_Parent") == undefined || colItems[i].getAttribute("RequestID_Parent") == null || colItems[i].getAttribute("RequestID_Parent") <= 0) {
                    if (m_IsOrderSetSelected) {
                        blnAvailable = false;
                        break;
                    }
                    m_IsSingleItemSelected = true;
                }
                else {
                    // this is orderset item
                    if (m_IsSingleItemSelected) {
                        blnAvailable = false;
                        break;
                    }
                    m_IsOrderSetSelected = true;
                }
                */
                if (!blnAvailable) break;
            }
            break;
        default:
            blnAvailable = false;
    }
    return blnAvailable ? OCSActionAvailable_Batch(actionType, colItems, DOMTypes) : false;
}

//--------------------------------------------------------------------------------------------------------

function OCSActionAvailable_Batch(actionType, colItems, DOMTypes)
{
	//Determine if the specified action is available for ALL of the items specified in colItems.
	//If the action cannot be performed for any one of the items, false is returned.
	//Note that this does not include role/security checking, that should be implemented
	//on the calling page.
	//
	//actionType - one of the Action Constants defined at the top of this file
	//colItems 	- iXMLDomNodeList of elements, each holding a row definition.  Must contain the attributes as
	//					defined in QueryValidation.vb
	//DOMTypes 	- iXMLDomDocument containing a list of types (RequestType, NoteType, ResponseType) for each 
	//					of the items in colItems

	var i = 0;
	var blnAvailable = false;
	var xmlType;

	if (colItems.length == 0)
	{
		return false;
	}
	//Only certain actions can be performed on multiple items:
	switch (actionType) {
	    
	    case OCS_REQUEST_REORDER:
		case OCS_CANCEL_AND_REORDER: 	// 16Oct07 ST  // AI 11/01/2008 162
		case OCS_CANCEL:
		case OCS_VIEW:
		case OCS_PRINTTHIS:
		case OCS_RECONCILE:
		case OCS_SUPPLY_REQUEST:
		case OCS_PBS_REQUEST:
		case OCS_PBS_PRINT:

		    for (i = 0; i < colItems.length; i++) {

		        blnAvailable = false;

		        //BugFix 89094 - If cancelled, do not enable "Ammed" button on Worklist
		        //Note: For some reason this attribute does not exist on the XML
		        if (actionType == OCS_CANCEL_AND_REORDER) {
		            if (colItems[i].getAttribute('Cancelled') == '1') break;
		        }

		        var blnIsRequest = false;
		        var blnIsNote = false;

		        //First get the type item for this item
		        xmlType = OCSTypeElementForItem(colItems[i], DOMTypes);
		        switch (colItems[i].getAttribute("class")) {
		            case "request":
		                blnIsRequest = true;
		                break;
		            case "note":
		                blnIsNote = true;
		                break;
		        }
		        //Now check if we can do this action for this item
		        if (xmlType != null) {
		            if (actionType == OCS_SUPPLY_REQUEST) {
		                if (!OCSActionAvailable(actionType, colItems[i], xmlType)) {
		                    blnAvailable = false;
		                    break;
		                }
		                else {
		                    blnAvailable = true;
		                }
		            }

		            //04Nov13   Rams    69520 - DAPM when editing multiple DAPM prescription profiles simultaneously, selecting titration option causes Error
		            //Prevent Prescription Request to Amend or Copy when multiple items selected
		            if ((actionType == OCS_CANCEL_AND_REORDER || actionType == OCS_REQUEST_REORDER) && i > 0 && colItems[i].getAttribute('RequestType') == 'Prescription Request') {
		                blnAvailable = false;
		                break;
		            }

		            //Check if it is a v11 worklist, if not then we cant do multiple OCS_REQUEST_REORDER
		            if (actionType == OCS_REQUEST_REORDER) {
		                var sessionId = document.body["sid"];
		                blnAvailable = (UsingV11(sessionId) || colItems.length == 1) && OCSActionAvailable(actionType, colItems[i], xmlType);
		            }
		            else {
		                blnAvailable = OCSActionAvailable(actionType, colItems[i], xmlType);
		            }
		        }
		        if (blnIsRequest && blnIsNote && actionType == OCS_CANCEL) blnAvailable = false;    // 05Mar07 PH Can't cancel notes and request at the same time.
		        if (!blnAvailable) break;
		    }
		    break;

		case OCS_TOGGLE_SUSPENSION:
		    //  check that they are all either suspended or unsuspended and available?
		    //  get the suspended state of the first item
		    if (colItems.length > 1) {
		        //06Feb13   Rams    30951 - Patient Locking - No locking occurs when suspending the same prescription at the same time
		        //Cannot allow multi selection for suspension, since the suspend and unsuspend are for single item only
		        blnAvailable = false;
		    }
		    else {
		        if (colItems.length > 0) {
		            var blnSuspended = (colItems[0].getAttribute('Suspended') == '1');
		            var blnSuspendedCurrent;
		            for (i = 0; i < colItems.length; i++) {
		                //First get the type item for this item
		                xmlType = OCSTypeElementForItem(colItems[i], DOMTypes);

		                //Now check if we can do this action for this item
		                if (xmlType != null) blnAvailable = OCSActionAvailable(actionType, colItems[i], xmlType);
		                if (!blnAvailable) break;

		                //  If the suspended state is different (even though it is available) then fail

		                blnSuspendedCurrent = (colItems[i].getAttribute('Suspended') == '1');
		                if ((blnSuspended && !blnSuspendedCurrent) || (!blnSuspended && blnSuspendedCurrent)) {
		                    blnAvailable = false;
		                    break;
		                };
		            }
		        }
		    }
		    break;

		default:
			//Nothing else is permitted for multiple items
			if (colItems.length > 1)
			{
				blnAvailable = false;
			}
			else
			{
				//Single item, check it																													//20Feb06 AE  corrected handling of single items
				xmlType = OCSTypeElementForItem(colItems[i], DOMTypes);
				blnAvailable = OCSActionAvailable(actionType, colItems[0], xmlType);
			}
	}
	return blnAvailable;
}

//--------------------------------------------------------------------------------------------------------

function OCSAction(SessionID, actionType, xmlItem, xmlType, fpRefresh, xmlStatusNoteFilter, blnPrintPreview, blnSelectReports) {
	//Performs the specified action on the specified item (if allowed).
	//Note that this does not include role/security checking, that should be implemented
	//on the calling page.
	//
	//actionType - one of the Action Constants defined at the top of this file
	//xmlItem - iXMLDomElement holding the row definition.  Must contain the attributes as
	//				defined in QueryValidation.vb
	//xmlType - iXMLDomElement containing the type (RequestType, NoteType, ResponseType) row for the given item.
	//fpRefresh - Function Pointer to a function which updates the current page.  If the action requires it,
	//				  this function will be called once the action is complete.
	//				  (most actions which change data will require the page to be updated; exceptions are printing and
	//					viewing.  Typically, this will be the page's Refresh() method.)
	//xmlStatusNoteFilter - Contains an xml document that describes the StatusNote inclusions/exclusions that can be applied 
	//					to this item
	//blnPrintPreview - Indicates whether print preview is on
	//blnSelectReports - Indicates that a selection screen of availble reports should be displayed.


	//Returns:	false if the action could not be taken, otherwise returns the value from the action method chosen.
	//				This will be 'cancel' if the user cancelled, otherwise an empty string.

	//Route through the _Batch method, to do this we need to convert the single item and type into collections.

    //Create the types DOM document
    
	var DOMTypes = new ActiveXObject("MSXML2.DOMDocument");
	var xmlRoot = DOMTypes.appendChild(DOMTypes.createElement('root'));
	xmlRoot.appendChild(xmlType.cloneNode(false));

	//And a collection of the single item
	var DOMItems = new ActiveXObject("MSXML2.DOMDocument");                                             // 20Feb06 PH Fixed some types involving DOMItem & DOMItems
	DOMItems.appendChild(xmlItem.cloneNode(false));
	var colItems = DOMItems.selectNodes('*');

	//Now do the action
	return OCSAction_Batch(SessionID, actionType, colItems, DOMTypes, fpRefresh, xmlStatusNoteFilter, blnPrintPreview, blnSelectReports, DEFAULT_TRACKCHANGES_VALUE);

}

//=================================================================================================
function OCSAction_Batch(SessionID, actionType, colItems, DOMTypes, fpRefresh, xmlStatusNoteFilter, blnPrintPreview, blnSelectReports, trackChanges, xmlOrderEntryExclusions, dispensingMode)
{
	//Performs the specified action on the specified items (if allowed).
	//Note that this does not include role/security checking, that should be implemented
	//on the calling page.
	//
	//actionType 	- one of the Action Constants defined at the top of this file
	//colItems 	- iXMLDomNodeList of elements, each holding a row definition.  Must contain the attributes as
	//					defined in QueryValidation.vb
	//DOMTypes 	- iXMLDomDocument containing a list of types (RequestType, NoteType, ResponseType) for each 
	//					of the items in colItems
	//fpRefresh - Function Pointer to a function which updates the current page.  If the action requires it,
	//				  this function will be called once the action is complete.
	//				  (most actions which change data will require the page to be updated; exceptions are printing and
	//					viewing.  Typically, this will be the page's Refresh() method.)
	//xmlStatusNoteFilter - Contains an xml document that describes the StatusNote inclusions/exclusions that can be applied 
	//					to this item
	//blnPrintPreview - Indicates whether print preview is on.
	//blnSelectReports - Indicates that a selection screen of availble reports should be displayed.
	//trackChanges - Sets whether Order Entry automatically shows changes to prescriptions when viewing.  Only available if Change Tracking is installed. Options : Hide Changes, Compare with Template, Compare with Previous
	//dispensingMode - If on dispensing desktop

	//Returns:	false if the action could not be taken, otherwise returns the value from the action method chosen.
	//				This will be 'cancel' if the user cancelled, otherwise an empty string.

	var returnVal;
	var blnRefresh = false;
	var blnAvailable = false;
	var xmlType;

	//Final gatekeeping check to make sure that we can do this
	if (colItems.length > 1)
	{
		blnAvailable = OCSActionAvailable_Batch(actionType, colItems, DOMTypes);
	}
	else
	{
		xmlType = OCSTypeElementForItem(colItems[0], DOMTypes);
		blnAvailable = OCSActionAvailable(actionType, colItems[0], xmlType);
	}
	//If it's ok, off we go...
	if (blnAvailable)
	{
		returnVal = true;
		switch (actionType)
		{
		    case OCS_VIEW: //View an item
			    var strTemp = ViewOCSItem(SessionID, colItems, DOMTypes, xmlStatusNoteFilter, trackChanges, xmlOrderEntryExclusions);
			    blnRefresh = (strTemp != 'cancel');
			    break;

		    case OCS_VIEW_REQUEST: //View request for a response
			    void ViewRequestForResponse(SessionID, colItems[0], xmlStatusNoteFilter, trackChanges, xmlOrderEntryExclusions);
			    break;

		    case OCS_REQUEST_REORDER: //Copy an item or item(s)
			    blnRefresh = CopyRequest(SessionID, colItems, DOMTypes, xmlStatusNoteFilter, trackChanges, xmlOrderEntryExclusions);
			    break;
		    case OCS_CANCEL: //Cancel an item or item(s)
			    blnRefresh = CancelItem(SessionID, colItems, DOMTypes, xmlStatusNoteFilter, 'Stop'); // AI 11/01/2008 code 162
			    break;

		    case OCS_TOGGLE_SUSPENSION: //Suspend/Unsuspend an item or item(s)
			    blnRefresh = ChangeRequestSuspension(SessionID, colItems);
			    returnVal = blnRefresh;
			    break;

		    case OCS_CANCEL_AND_REORDER: //Copy and cancel a request.
			    var useV11 = UsingV11(SessionID);
			    //                var v11Mask = ICWWindow().document.getElementById('v11Mask');
			    if (useV11)
			    {
				    returnVal = V11AmendOCSRequest(SessionID, colItems, DOMTypes, xmlStatusNoteFilter, trackChanges, false, xmlOrderEntryExclusions, dispensingMode);
				    blnRefresh = (returnVal != 'cancel');
			    }
			    else
			    {
				    var blnSuccess = CancelItem(SessionID, colItems, DOMTypes, xmlStatusNoteFilter, 'Amend'); // AI 11/01/2008 code 162
				    if (blnSuccess)
				    {
					    blnRefresh = true; //21Feb06 AE  Always refresh if we've cancelled, regardless of whether they cancel out of the copy. // AI 11/01/2008 Migrated code
					    blnSuccess = AmendOCSRequest(SessionID, xmlType, xmlStatusNoteFilter, trackChanges); // 23Oct07 ST  Now calls amend  // AI 11/01/2008  code 162
					    //blnSuccess = CopyOCSRequest(SessionID, colItems[0], xmlType, xmlStatusNoteFilter);	// AI 11/01/2008 code 162
				    }
			    }
			    break;

		    case OCS_RESPOND_TO: //Respond to a Request or note
			    blnRefresh = RespondToOCSItem(SessionID, colItems[0], xmlType, trackChanges);
			    break;

		    case OCS_ANNOTATE: //View / Edit attached notes
			    blnRefresh = EditNotes(SessionID, colItems[0], xmlType);
			    break;

		    case OCS_DSSREASON: //17Jan07 ST  Added to handle dss warning override reason
			    // commented out until spec has been done
			    //blnRefresh = ShowDSSReason(SessionID, colItems[0], xmlType);
			    break;

		    case OCS_PRINTTHIS:
			    returnVal = PrintItem(SessionID, colItems, 'standard', blnPrintPreview, blnSelectReports);
			    break;

		    case OCS_PBS_PRINT:
			    returnVal = PrintPBSItemsByBatch(SessionID, colItems, blnPrintPreview);
			    break;

		    case OCS_PRINTRESULTS:
			    returnVal = PrintItem(SessionID, colItems, 'results', blnPrintPreview, blnSelectReports);
			    break;

            case OCS_REVIEWREQUEST:
                returnVal = UpdateReviewRequest(SessionID, colItems[0]);
                blnRefresh = true;
                break;

		    case OCS_RECONCILE:
		        returnVal = ReconcileItems(SessionID, colItems, true, xmlStatusNoteFilter, document.body.getAttribute("reconcileAdminStatus"));
			    blnRefresh = true;
//                fpRefresh = forceRefresh();
			    break;

		    default:
			    returnVal = false;
			    break;
		}

		//Now call the refresh function if required.
		if (blnRefresh)
		{
			if (fpRefresh != undefined)
			{
				void fpRefresh(colItems);
			}
		}
	}
	else
	{
		alert('You cannot perform that action on the selected item(s)');
		returnVal = false;
	}

	return returnVal;
}

function CheckForSubForms(SessionID, colItems) {
    var requestIds = "";
    var noteIds = "";
    for (var i = 0; i < colItems.length; i++) {
        if (colItems[0].getAttribute('class') == 'request') {
            if (requestIds.length > 0) requestIds += ',';
            requestIds += colItems[i].getAttribute('dbid');
        }
        if (colItems[0].getAttribute('class') == 'note') {
            if (noteIds.length > 0) noteIds += ',';
            noteIds += colItems[i].getAttribute('dbid');
        }
    }
    return OrdersHaveSubforms(SessionID, requestIds, noteIds, "The following table types cannot be amended as they contain inline subforms: ");    
}

//=================================================================================================
function OCSShowContextMenuForWindow(SessionID, WindowID, x, y, fpRefresh) {
	
//Builds a context at the specified x,y co-ordinates based on the window menu.
var strImageName = '';

	var lngWindowID = ICWWindowID();
	var colItems = ICWToolMenuList(lngWindowID, true);
	if (colItems != undefined && colItems.length > 0){																		//27Feb06 AE  Added check for length > 0
		var objPopup = new ICWPopupMenu();
		for (i = 0; i < colItems.length; i++){
			strImageName = colItems[i].getAttribute('PictureName');
			strImageName = '../../images/user/' + strImageName;					
			objPopup.AddItem(colItems[i].getAttribute('Description')
								 ,colItems[i].getAttribute('EventName') 
								 ,(colItems[i].getAttribute('Enabled') == '1')
								 ,null
								 ,strImageName);		
		}
	}
	//Store variables for the asyncrounous call
	m_SessionID = SessionID;

//Now show the menu	
	void objPopup.Show(x, y);	
	
}

//=================================================================================================
function OCSShowContextMenu(SessionID, xmlItem, xmlType, x, y, fpRefresh) {
//Defunct, use OCSShowContextMenuForWindow instead
	return OCSShowContextMenuForWindow(SessionID, WindowID, x, y);
}


//=================================================================================================
function PopMenu_ItemSelected(selData, selDesc) {

//Called when the user selects an option from the right-click menu.
//Directs the program to the appropriate procedure.  selData holds the name of the 
//toolbar/menu event handler to be called.
	eval('EVENT_' + selData + '()');	
}

//=================================================================================================
//									Internal Action functions - view, reorder, etc
//=================================================================================================
function ViewOCSItem(SessionID, colItems, DOMTypes, xmlStatusNoteFilter, trackChanges, xmlOrderEntryExclusions) {
    //View the currently selected item in Order Entry.
    //If the item is an order set, all of its children are included.		
    var xmlType;
    var blnIsOrderset = false;
    var strItem_XML = '';
	for (i = 0; i < colItems.length; i++){
		xmlType = OCSTypeElementForItem(colItems[i], DOMTypes);  
		blnIsOrderset = IsOrderSet(xmlType);	
		strItem_XML += CreateOrderEntryItemXML(colItems[i]);
	
		//Check for children of this item; note that we only include children of order sets,
		//not responses which are grouped under requests.	
		if (blnIsOrderset) {
			strItem_XML += GetChildItemsXML(colItems[i]);
		}
		//Add the closing tag
		strItem_XML += '</item>';
    }

    // And StatusNote data
strItem_XML += xmlStatusNoteFilter.xml;
if (xmlOrderEntryExclusions != null) {
    strItem_XML += xmlOrderEntryExclusions.xml;
}
	
    var strReturn = '';
    var firstItem = colItems[0];

    if (firstItem.getAttribute('RequestType') == 'PBS Request') {
        var pbsRequestType = firstItem.getAttribute("PBSRequestType");
        strItem_XML = '<pbsrequest>' + strItem_XML + '</pbsrequest>';
        strReturn = PBSRequest(SessionID, strItem_XML, pbsRequestType, 'view');
    } else {
        //And the root tags for order entry
        strItem_XML = '<display>' + strItem_XML + '</display>';

        //Now load into the Order Entry component
        strReturn = OrderEntry(SessionID, strItem_XML, false, "undefined", trackChanges); 			//15Nov06 AE  Use new OrderEntry function #SC-06-1046	
    }
    
    return strReturn;	
}

//===================================================================================================

function ViewRequestForResponse(SessionID, xmlItem, xmlStatusNoteFilter, trackChanges, xmlOrderEntryExclusions) {
	
//View the associated request for the given response.	
	//	<item class="request" id="xxx" tableid="123" description="xxx" >	
	
	//We can obtain the RequestID and associated values from the  response item
	var xmlItem = GetCurrentRowXML();

	var strXML = '<displayrequest>'
				  + '<item class="response" '
				  + 'id="' + xmlItem.getAttribute('dbid') + '" '
				  + 'requestid="' + xmlItem.getAttribute("RequestID") + '" '
				  + '/>'
				  + xmlStatusNoteFilter.xml
				  + '</displayrequest>';
				  
	//Now load into the Order Entry component
	return OrderEntry(SessionID, strXML, false, "undefined", trackChanges); 			//15Nov06 AE  Use new OrderEntry function #SC-06-1046		
	
}

//==========================================================================================-----------

function CopyOCSRequest(SessionID, xmlItem, xmlType, xmlStatusNoteFilter, trackChanges) {

//Copy a request item, ie use it as a template for creating a new pending item.
	strItem_XML = CreateOrderEntryItemXML(xmlItem);

	//Check for children of this item
//	if (IsOrderSet(xmlType)) {																	//25Mar05 AE  Now done onboard OrderEntry for safety
//		strItem_XML += GetChildItemsXML(xmlItem);
//	}
	
	//Add the closing tag
	strItem_XML += '</item>';
	//And the root tags for order entry
	strItem_XML = '<copy>' + strItem_XML + xmlStatusNoteFilter.xml + '</copy>';
	//Now load into the Order Entry component
	var strReturn = OrderEntry(SessionID, strItem_XML, false, "undefined", trackChanges); 			//15Nov06 AE  Use new OrderEntry function #SC-06-1046		
	return (strReturn != 'cancel');

}

//==========================================================================================-----------

function PrintSupplyRequest(SessionID, SupplyRequestType) {

    var colItems = GetHighlightedRowXML();

    strItem_XML = '<supplyrequest>'
    for (i = 0; i<colItems.length; i++)
    {
        strItem_XML+= '<item '
							 + 'class="request" '
							 + 'id="' + $(colItems(i)).attr("dbid") + '"'
							 + '/>'        
    
    }
    strItem_XML += '</supplyrequest>';

    return SupplyRequest(SessionID, strItem_XML, SupplyRequestType);
}

//==========================================================================================-----------

function IssuePBS(SessionID, PBSRequestType) {

    var colItems = GetHighlightedRowXML();

    strItem_XML = '<pbsrequest>'
    for (i = 0; i < colItems.length; i++) {
        strItem_XML += '<item '
							 + 'class="request" '
							 + 'id="' + $(colItems(i)).attr("dbid") + '"'
							 + '/>'

    }
    strItem_XML += '</pbsrequest>';

    return PBSRequest(SessionID, strItem_XML, PBSRequestType, 'new');
}

//==========================================================================================-----------

function RespondToOCSItem(SessionID, xmlItem, xmlType, trackChanges) {

//Responds to / results the selected item
//This procedure is the public "result this" interface, and
//routes to the correct handler
	switch (xmlItem.getAttribute("class")) {
		case 'note':
		    return RespondToNote(SessionID, xmlItem, trackChanges); 													//12Oct06 AE  Passing the parameters makes it work better.
			break;
			
		case 'request':
		    return ResultRequest(SessionID, xmlItem, xmlType, trackChanges);
			break;
			
		default:
			return false;
			break;
	}	
}

//==========================================================================================-----------

function ResultRequest(SessionID, xmlItem, xmlType, trackChanges) {

//Result a request. 

	var strItem_XML = CreateOrderEntryItemXML(xmlItem);

	//Check for children of this item	
	if (IsOrderSet(xmlType)) {																					//22Aug03 AE  Corrected to use the Type definition rather than xmlItem
		strItem_XML += GetChildItemsXML(xmlItem);
	}
	//Add the closing tag
	strItem_XML += '</item>';

	//And the root tags for order entry
	strItem_XML = '<respond>' + strItem_XML + '</respond>';

	//Now load into the Order Entry component
	var strReturn = OrderEntry(SessionID, strItem_XML, false, "undefined", trackChanges); 			//15Nov06 AE  Use new OrderEntry function #SC-06-1046		
	return (strReturn != 'cancel');
}

function CopyRequest(sessionId, colItems, xmlType, xmlStatusNoteFilter, trackChanges, xmlOrderEntryExclusions) {
    if (UsingV11(sessionId)) {
        return V11CopyOCSRequest(sessionId, colItems, xmlType, xmlStatusNoteFilter, trackChanges);
    }
    else {
        return CopyOCSRequest(sessionId, colItems[0], xmlType, xmlStatusNoteFilter, trackChanges);
    }
}

function V11CopyOCSRequest(sessionId, colItems, domTypes, xmlStatusNoteFilter, trackChanges) {

    var strItem_XML = '';

    for (i = 0; i < colItems.length; i++) {
        strItem_XML += CreateOrderEntryItemXML(colItems[i]) + '</item>';
    }
	
	var strReturn = '';
    var firstItem = colItems[0];

    if (firstItem.getAttribute('RequestType') == 'PBS Request') {
        var pbsRequestType = firstItem.getAttribute("PBSRequestType");
        //Add the root tags for PBS Request
        strItem_XML = '<pbsrequest>' + strItem_XML + xmlStatusNoteFilter.xml + '</pbsrequest>';
        strReturn = PBSRequest(sessionId, strItem_XML, pbsRequestType, 'copy');
	} else {

	//Add the root tags for order entry
	    strItem_XML = '<copy>' + strItem_XML + xmlStatusNoteFilter.xml + '</copy>';
	    //Now load into the Order Entry component
	    strReturn = OrderEntry(sessionId, strItem_XML, false, "undefined", trackChanges);
	}
	
	return (strReturn != 'cancel');

}

function V11AmendOCSRequest(SessionID, colItems, DOMTypes, xmlStatusNoteFilter, trackChanges, isReconcile, xmlOrderEntryExclusions, dispensingMode) {
    var strItem_XML = '';
    var DispensaryMode = false; // AI 11/01/2008 code 162

    for (i = 0; i < colItems.length; i++) {
        strItem_XML += CreateOrderEntryItemXML(colItems[i]) + '</item>';
    }

    var strReturn = '';
    var firstItem = colItems[0];

    if (firstItem.getAttribute('RequestType') == 'PBS Request') {
        var pbsRequestType = firstItem.getAttribute("PBSRequestType");
        //Add the root tags for PBS Request
        strItem_XML = '<pbsrequest>' + strItem_XML + xmlStatusNoteFilter.xml + '</pbsrequest>';
        strReturn = PBSRequest(SessionID, strItem_XML, pbsRequestType, 'amend');
    } else {
        //Add the root tags for order entry
        strItem_XML = '<amend><reconcile>' + isReconcile + '</reconcile>' + strItem_XML + xmlStatusNoteFilter.xml + '</amend>';
        var strReturn = OrderEntry(SessionID, strItem_XML, dispensingMode == true, "undefined", trackChanges);
    }
    
    return strReturn;
}

function ReconcileOCSRequest(SessionID, colItems, xmlStatusNoteFilter) {
    var strItem_XML = '';

    for (i = 0; i < colItems.length; i++) {
        strItem_XML += CreateOrderEntryItemXML(colItems[i]) + '</item>';
    }

    var strReturn = '';

        //Add the root tags for order entry
    strItem_XML = '<reconcile>' + strItem_XML + xmlStatusNoteFilter.xml + '</reconcile>';
    var strReturn = OrderEntry(SessionID, strItem_XML, false, "undefined", true);

    return strReturn;
}

//===================================================================================================

function RespondToNote(SessionID, xmlItem, trackChanges) {

    //Reply to a note.  In actual fact, we add this note
    //as the last note in the discussion thread, rather than
    //replying to an individual note.

    var intCount = new Number();
    var astrItem = new Array();

    var lngNoteTypeID = new Number();
    var lngTableID = new Number();
    var strDescription = new String();

    //Get the ID of the note we are replying to;
    var lngInReplyToID = xmlItem.getAttribute('dbid')
    if (!UsingV11(SessionID)) {
        //Get the user to choose which note type they want to add.
        var strNoteTypeInfo = SelectNoteType(SessionID);
        //notetypeid=xxx|tableid=123|description=abc

        if (strNoteTypeInfo.length > 0) {
            var astrInfo = strNoteTypeInfo.split('|');
            for (intCount = 0; intCount < astrInfo.length; intCount++) {
                astrItem = astrInfo[intCount].split('=');
                switch (astrItem[0]) {
                    case 'notetypeid':
                        lngNoteTypeID = astrItem[1];
                        break;

                    case 'tableid':
                        lngTableID = astrItem[1];
                        break;

                    case 'description':
                        strDescription = astrItem[1];
                        break;
                }
            }
        }
        else {
            return false;
        }
    }

    //Now spawn order entry 
    var strItem_XML = '<reply>'
							 + '<item '
							 + 'class="note" '
							 + 'id="0" '
							 + 'ocstypeid="' + lngNoteTypeID + '" '
							 + 'tableid="' + lngTableID + '" '
							 + 'description="' + strDescription + '" '
							 + 'inreplytoid="' + lngInReplyToID + '" '
							 + '/>'
							 + '</reply>';

    //Now load into the Order Entry component
    var strReturn = OrderEntry(SessionID, strItem_XML, false, "undefined", trackChanges); 								//15Nov06 AE  Use new OrderEntry function #SC-06-1046		
    return (strReturn != 'cancel');
}

//=====================================================================================================
// AI 11/01/2008 code 162
function AmendOCSRequest(SessionID, xmlType, xmlStatusNoteFilter, trackChanges)
{
	var strItem_XML = '';
	var strReturn_XML = '';
	var xmlDOM;
	var xmlNodes;
	var idx;

	var strURL = '../sharedscripts/SessionAttribute.aspx'
					+ '?SessionID=' + SessionID
					+ '&Mode=get'
					+ '&Attribute=OrderEntry/OrdersXML';

	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");                                      
	objHTTPRequest.open("POST", strURL, false);
	objHTTPRequest.send('');
	strReturn_XML = objHTTPRequest.responseText;	

	xmlDOM = new ActiveXObject("MSXML2.DOMDocument")
	xmlDOM.loadXML(strReturn_XML);	
	xmlNodes = xmlDOM.selectNodes('//item');
	
	if(xmlNodes.length > 0)
	{
		strItem_XML = '<amend>';
		for(idx = 0; idx < xmlNodes.length; idx++)
		{
			strItem_XML += xmlNodes[idx].xml;
		}
		strItem_XML += '</amend>';
	}
	else
	{
		// oops, something has gone wrong
		return('cancel');
	}

	//Now load into the Order Entry component
	var strReturn = OrderEntry(SessionID, strItem_XML, false, "undefined", trackChanges); 			//15Nov06 AE  Use new OrderEntry function #SC-06-1046		
	return (strReturn != 'cancel');
}
//==========================================================================================-----------


// F0045558 19-03-09 PR Split CancelItem into 2 functions, first is concerned with selecting items to stop
//						Second takes the list of items and performs the actual cancellation, done to allow
//						discharges to be cancel dirtectly.
function CancelItem(SessionID, colItems, DOMTypes, xmlStatusNoteFilter, strMode) {// AI 11/01/2008 code 162
    //Cancel the current request.	
    //Returns true if the request was cancelled, false if the user..urrr...cancelled the cancellation.
    var strItem_XML = '';
    var DispensaryMode = false;// AI 11/01/2008 code 162
    var blnSetting = false;
    var blnSkipSingleItem = false;
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");                                      
    var strURL = '../sharedscripts/SettingRead.aspx'
			      + '?SessionID=' + SessionID
			      + '&System=OCS'
			      + '&Section=StopAmend'
			      + '&Key=ShowStopScreenForSingleItems';

    var useV11 = UsingV11(SessionID);

    if (useV11) {
        blnSkipSingleItem = true;
    }


	//Read the items
	if(colItems.length == 1)
	{
        objHTTPRequest.open("POST", strURL, false);	//false = syncronous                              
        objHTTPRequest.send("");
        if(objHTTPRequest.responseText == "True")
        {
            blnSetting = true;
        }
	
	    // single item selected, check to see if it's an order set
	    if(colItems[0].xml.indexOf("Order set") == -1)
	    {
	        if(!blnSetting)
	        {
	            strReturn = 'ok';
	            blnSkipSingleItem = true;
            }
	    }
	}

	for (i = 0; i < colItems.length; i++){
		strItem_XML += CreateOrderEntryItemXML(colItems[i]) + '</item>';
    }
    
strItem_XML += xmlStatusNoteFilter.xml;
	
	var firstItem = colItems[0];
	if (firstItem.getAttribute('RequestType') == 'PBS Request') {
	    var pbsRequestType = firstItem.getAttribute("PBSRequestType");
	    strItem_XML = '<pbsrequest>' + strItem_XML + '</pbsrequest>';
        strReturn = PBSRequest(SessionID, strItem_XML, pbsRequestType, 'cancel');
    }
    else {
        //And the root tags for order entry
        strItem_XML = '<cancel>' + strItem_XML + '</cancel>';
        // AI 11/01/2008  code 162

        if (!blnSkipSingleItem) {
            var strReturn = StopOrder(SessionID, strItem_XML, false, strMode); 	// show the stop item dialog and let the user choose which items to stop
        }
        else {
            SessionAttributeSet(SessionID, "OrderEntry/StopOrders", strItem_XML);
        }

        if (strReturn != 'cancel') {
            // get our data from state
            strItem_XML = SessionAttributeGet(SessionID, "OrderEntry/StopOrders")

            strReturn = PerformCancelItem(SessionID, strItem_XML, DispensaryMode);
        }
    }
	
	return (strReturn != 'cancel');
}

//==========================================================================================-----------
function PerformCancelItem(SessionID, strItem_XML, DispensaryMode)
{
	var strURL = '../OrderEntry/OrderEntrySaver.aspx'
					+ '?SessionID=' + SessionID
					+ '&Mode=xmlput';

	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
	objHTTPRequest.open("POST", strURL, false);               										//false = syncronous                              
	objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
	objHTTPRequest.send(strItem_XML);

	//Now we show OrderEntry itself
	DispensaryMode = (DispensaryMode == true); 	//Ensure that DispensaryMode is a boolean				//12Mar07 AE  Corrected n00b-standard boolean logic error.

	strURL = '../OrderEntry/StopItemsModal.aspx'
					+ '?SessionID=' + SessionID
					+ '&Action=load'
					+ '&DispensaryMode=' + (DispensaryMode ? '1' : '0');

	var ReturnValue;
	var useV11 = UsingV11(SessionID);
	//	var v11Mask = ICWWindow().document.getElementById('v11Mask');
	if (useV11) {
	    var v11Mask = ICWWindow().document.getElementById('v11Mask');
	    v11Mask.style.display = 'block';
	    v11Mask.style.top = 0;
		var retValue = window.showModalDialog(strURL, '', OrderEntryFeaturesV11());
		if (retValue == 'logoutFromActivityTimeout') {
			retValue = null;
			window.close();
			window.parent.close();
			window.parent.ICWWindow().Exit();
		}

	    v11Mask.style.display = 'none';
	    ReturnValue = retValue;
	}
	else {
	    ReturnValue = window.showModalDialog(strURL, '', 'dialogHeight:500px;dialogWidth:850px;resizable:yes;unadorned:no;status:no;help:no;');
		if (ReturnValue == 'logoutFromActivityTimeout') {
			ReturnValue = null;
			window.close();
			window.parent.close();
			window.parent.ICWWindow().Exit();
		}
	}

	//13May10 JMei F0086322 After close button on the right top corner clicked from Stop Item(s), refresh the page
	if (ReturnValue == 'cancel') {
	    void RAISE_RequestChanged();
	    void Refresh();
	}
	return ReturnValue;

}

//==========================================================================================-----------

function CancelNote(SessionID, colItems, DOMTypes, trackChanges) {
	
//Cancel the current request.	
//Returns true if the request was cancelled, false if the user..urrr...cancelled the cancellation.
var strMsg = new String();
var strClass = '';
var strItem_XML = '';

	//Read the items
	for (i = 0; i < colItems.length; i++){
		strItem_XML += CreateOrderEntryItemXML(colItems[i]) + '</item>';
	}
	//And the root tags for order entry
	strItem_XML = '<cancelnoteid>' + strItem_XML + '</cancelnoteid>';
						 
	//Load the Order Entry component
	var strReturn = OrderEntry(SessionID, strItem_XML, false, "undefined", trackChanges); 								//15Nov06 AE  Use new OrderEntry function #SC-06-1046		
	return (strReturn != 'cancel');
		
}

//==========================================================================================-----------

function SaveRequestSuspension(SessionID, Item_XML) {
	//do post
	var strURL = '../OrderEntry/SuspendPrescriptionSaver.aspx'
				  + '?SessionID=' + SessionID
				  + '&Mode=savesuspendchanges';
	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");                                      
	objHTTPRequest.open("POST", strURL, false);               										//false = syncronous                              
	objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

	objHTTPRequest.send(Item_XML);
	                                                      
	return objHTTPRequest.responseText;	
}


function ChangeRequestSuspension(SessionID, colItems)
{
	//Toggles the suspension status of the selected request(s)
	//Returns true if the request(s) was suspended, false if the user cancelled.

	var strItem_XML = '';
	var strItem_InnerXML;
	var strReturn;

	//  Add a call to a new method in OCSShared.js that displayes the Suspend dialog and returns the xml to insert into the 
	//  <item> node for each one selected
	//  then sort out how to change Order Entry to handle suspending stuff

	if (colItems.length > 0)
	{
		//  Work out whether we are suspending or unsuspending by looking at the Susoended attribute on the first item
		var blnSuspended = (colItems[0].getAttribute('Suspended') == '1');

		//28Oct11   Rams    17561 - Can’t unsuspend a prescription that has been suspended from a date in the future        
        //Always display the suspension dialog
		var strSuspensionInfo = ShowSuspensionDetailsDialog(SessionID, colItems);
        if (strSuspensionInfo == 'cancelled')
		{
		    return false;
		}

		if (strSuspensionInfo.indexOf('unsuspend_now="now"') != -1) {
		    StatusMessage('Unsuspending Prescriptions');
		    strItem_InnerXML = '<unsuspend></unsuspend>';
		}
		else {
		    StatusMessage('Suspending Prescriptions');
		    strItem_InnerXML = '<suspend>' + strSuspensionInfo + '</suspend>';
		}
		//Read the items
		for (var i = 0; i < colItems.length; i++)
		{
			strItem_XML += CreateOrderEntryItemXML(colItems[i]) + strItem_InnerXML + '</item>';
		}
		//And the root tags for order entry
		strItem_XML = '<changesuspend>' + strItem_XML + '</changesuspend>';

		//Load the Order Entry component
		strReturn = SaveRequestSuspension(SessionID, strItem_XML);
		StatusMessage('');

		// Check the success of the save	
		var DOM = new ActiveXObject("MSXML2.DOMDocument");
		DOM.loadXML(strReturn);

		var colErrors = DOM.selectNodes('//BrokenRules');
		if (colErrors.length > 0)
		{
			var strMsg = 'WARNING!  Save Failed!\n\n';
			for (var intCount = 0; intCount < colErrors.length; intCount++)
			{
				var objRule = colErrors[intCount].selectSingleNode('Rule');
				strMsg += objRule.getAttribute('Text') + '\n\n';
			}
			Popmessage(strMsg);
			return false;
		}
		else
		{
			return true;
		}
	}
	else
	{
		return false;
	}
}

//==========================================================================================-----------

function EditNotes(SessionID, xmlItem, xmlType) {

	if (xmlItem == null) {
		return;
	}
//Edit / view the notes attached to this item
	var ItemID = xmlItem.getAttribute('dbid');
	var strClass = xmlItem.getAttribute('class');
	
	return EditNotesByClassAndID(SessionID, strClass, ItemID);
}

function EditNotesByClassAndID(SessionID, strClass, lngItemID, V11PendingID) {
//Edit / view the notes attached to this item
	var returnVal = false;

	if ( strClass == 'request' || strClass == 'response' || strClass == 'pending') {
		returnVal = EditAttachedNotes(SessionID, strClass, lngItemID, V11PendingID);
	}
	else {
		alert('You cannot attach notes to a "' + strClass);
	}
	return returnVal;
}

//==========================================================================================-----------
function ShowDSSReason(SessionID, xmlItem, xmlType) {
	
	var ItemID = xmlItem.getAttribute('dbid');
	var strClass = xmlItem.getAttribute('class');
	var returnVal = false;

	if ( strClass == 'request' || strClass == 'response') {							
		returnVal = ViewDSSReason(SessionID, strClass , ItemID);
	}
	return returnVal;
}

//==========================================================================================-----------

function PrintItem(SessionID, colItems, strPrintType, blnPrintPreview, blnSelectReports)
{
	//Print the given item
	//
	//	xmlItem													 - iXMLDomElement containing the item to be printed.
	//	strPrintType:		either		"standard"		 - print the standard order comms report for this item
	//						or			"results"		 - print the result summary report for this item
	//						or			"standalone"	 - print the stand alone report for this item
	//						or			"batch"			 - print the a batch mode report

	//15Feb06 AE  Modified to use new PrintItems method, for multiselect
	//06Dec06 PH  Added "batch" mode. In "batch" mode a batch is still created, but only one report is printed, 
	//				and the PrintBatchID is passed into the report's routine, rather than the usual record id. 
	//				SingleCallMode is used when Status Buttons are used to print single/multiple selected items in the worklist.
	//10Apr07 PH  Added Print Preview and Report Selection

	var strReports_XML = "";
	var strXML = '<printitems>';
	var lngOrderReportTypeID = 0;  

	for (i = 0; i < colItems.length; i++)
	{
		strXML += '<item '
				  + 'tableid="' + colItems[i].getAttribute('tableid') + '" '
				  + 'dbid="' + colItems[i].getAttribute('dbid') + '" '
				  + 'requesttypeid="' + colItems[i].getAttribute('RequestTypeID') + '" '
				  + 'responsetypeid="' + colItems[i].getAttribute('ResponseTypeID') + '" '
				  + 'notetypeid="' + colItems[i].getAttribute('NoteTypeID') + '" '
                  + 'print="true" '
				  + '/>'
	}
	
	strXML += '</printitems>'

	switch (strPrintType)
	{
		case "standard":
			lngOrderReportTypeID = 1;
			break;

		case "results":
			lngOrderReportTypeID = 2;
			break;

		case "standalone":
			lngOrderReportTypeID = 2;
			break;

		case "batch":
			lngOrderReportTypeID = 4;
			break;
	}

	if (blnSelectReports)
	{
		var strFeatures = "dialogHeight: 320px; dialogWidth: 320px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: Yes; status: No;";

		strReports_XML = window.showModalDialog("../Printing/ReportSelectorModal.aspx?SessionID=" + SessionID
											    + "&OrderReportTypeID=" + lngOrderReportTypeID
											    + "&IsMHAForm=false"
											, strXML
											, strFeatures
		);

		if (strReports_XML == 'logoutFromActivityTimeout') {
			strReports_XML= null;
			window.close();
			window.parent.close();
			window.parent.ICWWindow().Exit();
		}

	}
	
	if (!blnSelectReports || (strReports_XML!=null && strReports_XML != ""))
	{
		var icw;
		if (window.dialogArguments != undefined) 
        {		    
			icw = window.dialogArguments.icwwindow;
		}
        else if (window.parent.ICWWindow == undefined || window.parent.ICWWindow() == null) 
        {
        		    
			icw = ICWWindow();
		}
        else 
        {
			icw = window.parent.ICWWindow();
		}

	    if (icw != null && icw.document.frames['fraPrintProcessor'] != undefined) {
	        icw.document.frames['fraPrintProcessor'].PrintItems(SessionID, strXML, lngOrderReportTypeID, blnPrintPreview, strReports_XML);
	    }
	}

	if (blnSelectReports || strReports_XML == "")
	{
		return false;
	}
	return true;
}

function PrintNamedReport(SessionID, strReportName, blnPrintPreview)
{
	var strReportTypes_XML = '<ReportTypeFilter filtertype="exclude">'
				 + '<ReportType description="Standard Order Comms" />'
				 + '<ReportType description="Results Summary" />'
				 + '<ReportType description="Batch" />'
				 + '<ReportType description="Drug Chart Replacement" />'
				 + '</ReportTypeFilter>';

	ICWWindow().document.frames['fraPrintProcessor'].PrintReport(SessionID, strReportName, 0, blnPrintPreview, strReportTypes_XML);
}

function PrintNamedReportForCurrentEpisode(SessionID, strReportName, blnPrintPreview)
{
	var xmlList = GetHighlightedRowXML();

	if (xmlList.length != 1)
	{
		return false;
	}

	var episodeId = EpisodeIDFromRow(xmlList[0]);

	if (episodeId < 1)
	{
		return false;
	}

	var strReportTypes_XML = '<ReportTypeFilter filtertype="exclude">'
				 + '<ReportType description="Standard Order Comms" />'
				 + '<ReportType description="Results Summary" />'
				 + '<ReportType description="Batch" />'
				 + '<ReportType description="Drug Chart Replacement" />'
				 + '</ReportTypeFilter>';

	ICWWindow().document.frames['fraPrintProcessor'].PrintReport(SessionID, strReportName, episodeId, blnPrintPreview, strReportTypes_XML);
}

//==========================================================================================
function PrintPBSItemsByBatch(SessionID, colItems, blnPrintPreview) { 
    
    /*
        1.  Group all the items based on the condition.
                If items selected falls under the following conditions, they can be printed in one go
                a.  Same Patient    -   PBSPatientID
                b.  Same Prescriber -   PBSPrescriberID
                c.  Same Script Type (Script types can be PBS or RPBS or Non- PBS ) -   ScriptType
                d.  Brand Substitution Selection
                d.  No Authority Required   -   AuthorityRequired
        2.  Issue batch print statement when the above conditions met or number of items reached 3
        3.  If the above conditions do not met then issue print items command,
    */
    //15Aug13   Rams    71165 - Added support for print group
    var itemstoprocess = [];
    //make all the items in collection into json array
    for (i = 0; i < colItems.length; i++) {
        var item = {
                        id: colItems[i].getAttribute('dbid'),
                        tableid : colItems[i].getAttribute('tableid') ,
                        requesttypeid : colItems[i].getAttribute('RequestTypeID'),
				        responsetypeid : colItems[i].getAttribute('ResponseTypeID') ,
				        notetypeid : colItems[i].getAttribute('NoteTypeID'),
				        scripttype : colItems[i].getAttribute('ScriptType'),
				        patientid : colItems[i].getAttribute('PBSPatientID'),
				        prescriberid : colItems[i].getAttribute('PBSPrescriberID'),
				        authorityrequired: colItems[i].getAttribute('AuthorityRequired'),
				        brandsub: colItems[i].getAttribute('BrandSubPermitted')
				    };
				    
        itemstoprocess.push(item);
    }

    var strXML = "<printitems>";
    var printGroup = 0;
    var lngOrderReportTypeID = 1; //Standard order comms
    var patientIds = JSLINQ(itemstoprocess).Select(function(item){ return item.patientid; });
    var patientArray = patientIds.ToArray();
    var uniquePatientArray = [];
    //remove duplicate patient id from the selected list
    $.each(patientArray, function(i, el) {
        if ($.inArray(el, uniquePatientArray) === -1) uniquePatientArray.push(el);
    });

    for (var patientIndex in uniquePatientArray) {
        var patientid = uniquePatientArray[patientIndex];

        var itemsForThisPatient = JSLINQ(itemstoprocess)
                                            .Where(function(item) { return item.patientid == patientid; });
        
        //get the authority required ones
        if (itemsForThisPatient.Any(function(item) { return item.authorityrequired == "1" })) {
            var itemsWithAuthorityRequired = itemsForThisPatient.Where(function(item) { return item.authorityrequired == "1"; });
            //print the authority required ones straight away
            var itemsWithAuthorityRequiredLength = itemsWithAuthorityRequired.Count();
            for (j = 0; j < itemsWithAuthorityRequiredLength; j++) {
                var data = itemsWithAuthorityRequired.ElementAt(j);
                strXML += '<item '
	                    + 'tableid="' + data.tableid + '" '
	                    + 'dbid="' + data.id + '" '
	                    + 'requesttypeid="' + data.requesttypeid + '" '
	                    + 'responsetypeid="' + data.responsetypeid + '" '
	                    + 'notetypeid="' + data.notetypeid + '" '
	                    + '/>';
            }
        }
        
        if (itemsForThisPatient.Any(function(item) { return item.authorityrequired == "0" })) {
            var itemsWithNoAuthority = itemsForThisPatient.Where(function(item) { return item.authorityrequired == "0"; });
            var prescriberIds = itemsWithNoAuthority.Select(function(item) { return item.prescriberid; });
            var prescriberArray = prescriberIds.ToArray();
            var uniquePrescriberArray = [];
            //remove duplicate prescriber id from the selected list
            $.each(prescriberArray, function(i, el) {
                if ($.inArray(el, uniquePrescriberArray) === -1) uniquePrescriberArray.push(el);
            });
            // Now loop through each prescribers prescription request
            for (var prescriberIndex in uniquePrescriberArray) {
                var prescriberid = uniquePrescriberArray[prescriberIndex];
                var itemsCreatedBySamePrescriber = itemsWithNoAuthority.Where(function(item) { return item.prescriberid == prescriberid; });
                if (itemsCreatedBySamePrescriber.Any(function(item) { return item.scripttype == "pbs" })) {
                    var pbsScriptTypeItems = itemsCreatedBySamePrescriber.Where(function(item) { return item.scripttype == "pbs"; });
                    //
                    var pbsBrandSubScriptTypeItems = pbsScriptTypeItems.Where(function(item) { return item.brandsub == "1"; });
                    if (pbsBrandSubScriptTypeItems.Count() > 0) {
                        printGroup += 1;
                        strXML += GetPrintGroupXMLFromPBSData(SessionID, blnPrintPreview, pbsBrandSubScriptTypeItems, printGroup);
                    }
                    
                    var pbsNoBrandSubScriptTypeItems = pbsScriptTypeItems.Where(function(item) { return item.brandsub == "0"; });
                    if (pbsNoBrandSubScriptTypeItems.Count() > 0) {
                        printGroup += 1;
                        strXML += GetPrintGroupXMLFromPBSData(SessionID, blnPrintPreview, pbsNoBrandSubScriptTypeItems, printGroup);
                    }
                }
                
                if (itemsCreatedBySamePrescriber.Any(function(item) { return item.scripttype == "rpbs" })) {
                    var rpbsScriptTypeItems = itemsCreatedBySamePrescriber.Where(function(item) { return item.scripttype == "rpbs"; });
                    //
                    var rpbsBrandSubScriptTypeItems = rpbsScriptTypeItems.Where(function(item) { return item.brandsub == "1"; });
                    if (rpbsBrandSubScriptTypeItems.Count() > 0) {
                        printGroup += 1;
                        strXML += GetPrintGroupXMLFromPBSData(SessionID, blnPrintPreview, rpbsBrandSubScriptTypeItems, printGroup);
                    }

                    var rpbsNoBrandSubScriptTypeItems = rpbsScriptTypeItems.Where(function(item) { return item.brandsub == "0"; });
                    if (rpbsNoBrandSubScriptTypeItems.Count() > 0) {
                        printGroup += 1;
                        strXML += GetPrintGroupXMLFromPBSData(SessionID, blnPrintPreview, rpbsNoBrandSubScriptTypeItems, printGroup);
                    }
                }

                if (itemsCreatedBySamePrescriber.Any(function(item) { return item.scripttype == "nonpbs" })) {
                    var nonpbsScriptTypeItems = itemsCreatedBySamePrescriber.Where(function(item) { return item.scripttype == "nonpbs"; });
                    //
                    var nonpbsBrandSubScriptTypeItems = nonpbsScriptTypeItems.Where(function(item) { return item.brandsub == "1"; });
                    if (nonpbsBrandSubScriptTypeItems.Count() > 0) {
                        printGroup += 1;
                        strXML += GetPrintGroupXMLFromPBSData(SessionID, blnPrintPreview, nonpbsBrandSubScriptTypeItems, printGroup);
                    }

                    var nonpbsNoBrandSubScriptTypeItems = nonpbsScriptTypeItems.Where(function(item) { return item.brandsub == "0"; });
                    if (nonpbsNoBrandSubScriptTypeItems.Count() > 0) {
                        printGroup += 1;
                        strXML += GetPrintGroupXMLFromPBSData(SessionID, blnPrintPreview, nonpbsNoBrandSubScriptTypeItems, printGroup);
                    }
                }
            }
        }
    }
    strXML += "</printitems>";
    ICWWindow().document.frames['fraPrintProcessor'].PrintItems(SessionID, strXML, lngOrderReportTypeID, blnPrintPreview, "");
    return true;
}

//==========================================================================================

function GetPrintGroupXMLFromPBSData(SessionID, blnPrintPreview, collection, printGroup) {

    //15Aug13   Rams    71165 - Added support for print group 
    var strXML = '';
    var count = collection.Count();
    var createNewGroup = false;
    
    for (i = 1 ; i <= count ; i++ ) {
        //only 3 items allowed per form
        if ((i > 2 && i % 3 == 0) || i == count) {
            createNewGroup = true;    
        }
        strXML += GetPrintItemXMLFromPBSData(collection.ElementAt(i - 1), printGroup);
        if (createNewGroup == true) {
            createNewGroup = false;
            //increase the print group so the item goes to the next group
            printGroup += 1;
        }
    }
    return strXML;
}


function GetPrintItemXMLFromPBSData(data, printGroup) {
    //15Aug13   Rams    71165 - Added support for print group 
    return '<item '
		      + 'tableid="' + data.tableid + '" '
		      + 'dbid="' + data.id + '" '
		      + 'requesttypeid="' + data.requesttypeid + '" '
		      + 'responsetypeid="' + data.responsetypeid + '" '
		      + 'notetypeid="' + data.notetypeid + '" '
		      + 'printgroup="' + printGroup + '" '
		      + '/>';
}

//==========================================================================================

function Approve(SessionID, xmlItem){

var strMsg = '';
var lngID = 0;
var strClass = '';

	if (document.all['fraSave'] != undefined) {
		if (fraSave.AttachSystemNote != undefined) {
		//Save the note
			strClass = new String(xmlItem.getAttribute('class'));
			lngID = xmlItem.getAttribute('dbid');
			fraSave.AttachSystemNote(SessionID, strClass, lngID, 'Approval Note', '');
		}
		else {
			strMsg = 'the method "AttachSystemNote()" is missing.';
		}	
	}
	else {
		strMsg = 'the required HTML element "fraSave" is missing from the page.';
	}

	if (strMsg != '') {
		alert('Cannot save approval note: ' + strMsg);
	}
	
}

//==========================================================================================
function Disapprove(SessionID, xmlItem){

//The opposite of Approve.  But much the same in fact.
//Save a special type of attached note against this item

//Note:  This method was written at very short notice.  Interventions
//			raises a lot of questions, and we may need to do something
//			different in future.

//09Feb05 AE   Added Disaproval.  About everything.

var strMsg = '';
var lngID = 0;
var strClass = '';
var strURL = '';

	if (document.all['fraSave'] != undefined) {
		if (fraSave.AttachSystemNote != undefined) {
		//Show the note form for editing		
			strURL = '../NotesEditor/EditNote.aspx'
						  + '?SessionID=' + SessionID
						  + '&NoteID=-1'
						  + '&TableName=InterventionNote';
			
			var strFeatures = 'dialogHeight:600px;' 
						 + 'dialogWidth:800px;'
						 + 'resizable:no;unadorned:no;'
						 + 'status:no;help:no;';		
	
			strReturn = window.showModalDialog(strURL, '', strFeatures);			
			if (strReturn == 'logoutFromActivityTimeout') {
				strReturn = null;
				window.close();
				window.parent.close();
				window.parent.ICWWindow().Exit();
			}

			if ( (strReturn != undefined) && (strReturn != 'cancel') ){
			//Save the note
				strClass = new String(xmlItem.getAttribute('class'));
				lngID = xmlItem.getAttribute('dbid');		
				fraSave.AttachSystemNote(SessionID, strClass, lngID, 'Intervention Note', strReturn);
			}
		}
		else {
			strMsg = 'the method "AttachSystemNote()" is missing.';
		}	
	}
	else {
		strMsg = 'the required HTML element "fraSave" is missing from the page.';
	}

	if (strMsg != '') {
		alert('Cannot save approval note: ' + strMsg);
	}

}
//==========================================================================================
//											Internal Functions
//==========================================================================================

function IsOrderSet(xmlType) {

//Returns true if the given item is an order set.
//27Feb06 AE  Added check for undefined type.
	var strType = '';
	if (xmlType != undefined){
		strType = xmlType.getAttribute('Description');
		strType = strType.toString().toLowerCase();
	}
	return (strType == 'order set');
	
	
}
//--------------------------------------------------------------------------------------------------------

function IsPrescription(xmlItem){

//Returns true if this item is a prescription.
//Prescriptions always have a productID as part of their standard 
//xml:
	var productID = xmlItem.getAttribute('productid');
	if (productID == null || productID == '') {productID = -1};	
	return (Number(productID) > 0);
}

//--------------------------------------------------------------------------------------------------------
function OCSTypeElementForItem(xmlItem, DOMTypes){
//Returns the appropriate type definition element from DOMTypes for the 
//item specified. (so if xmlItem is a request, we return the RequestType element for it)
	
	if (xmlItem != null) {	
		var strClass = xmlItem.getAttribute('class');
		switch (strClass){
			case 'request':
				return DOMTypes.selectSingleNode('*/RequestType[@RequestTypeID="' + xmlItem.getAttribute('RequestTypeID') + '"]');
				break;
			
			case 'response':
				return DOMTypes.selectSingleNode('*/ResponseType[@ResponseTypeID="' + xmlItem.getAttribute('ResponseTypeID') + '"]');
				break;			
			
			case 'note':
				return DOMTypes.selectSingleNode('*/NoteType[@NoteTypeID="' + xmlItem.getAttribute('NoteTypeID') + '"]');
				break;			
			
			default:
				return null;
				break;	
		}
	} else {
		return null;
	}
}

//--------------------------------------------------------------------------------------------------------

function GetChildItemsXML(objItem) {

//Return XML for the OrderEntry component.
//Here, we return items in the list which are children of the current items, 
//and their children if they have any.

var intCount = new Number();
var strReturn_XML = new String();
var lngID = new Number();
var objTypeItem = new Object();

	//get all children of this item
	var colItems = objItem.selectNodes('*');

	for (intCount = 0; intCount < colItems.length; intCount++ ) {
		//Create the XML element for this item
		strReturn_XML += CreateOrderEntryItemXML(colItems[intCount]);
		objTypeItem = GetTypeItem(colItems[intCount]);

		if (IsOrderSet(objTypeItem)) {
		//This item is an orderset, so script its child orders
			lngID = colItems[intCount].getAttribute('dbid');
			strReturn_XML += GetChildItemsXML(colItems[intCount]);			
		}
	
		//Add the closing tag
		strReturn_XML += '</item>';
	}
		
	return strReturn_XML;
	
}

//==========================================================================================-----------

function CreateOrderEntryItemXML(objItem) {
//Extracts the usefull parts from objItem.xml and returns an XML 
//string formatted for passing to order entry.
//Note that we're passing all possible attributes that order entry may need
//(productID being a good example, it's only required for Prescription requests).
//These should be checked for in Worklist.aspx:CheckWorkListAttributes(), so
//that at this stage we never need to worry about whether the required data is here;
//we just pass everything we might be interested in, whether it's there or not.
//
//		objItem: XML DOM <item> Element containing at leaset id, and class attributes.
//
//	returns XML as follows (note no end tag added here):
//		<item class="note|request|response" id="xxx" tableid="123" description="xxx" 
//				detail="xxx" productid="123" ocstype="note|request|response" ocstypeid="123" />
//
//	Modification History:
//	23Oct03 AE  Added XMLEscape to catch illegal characters.
//	17Jan04 AE  Added AutoCommit flag

var ocsTypeID = '';
	var strClass = new String(objItem.getAttribute('class'));
	
	//Get the type attribute; 
	switch (strClass.toLowerCase()) {
		case 'request':
			ocsTypeID = objItem.getAttribute('RequestTypeID');
			break;
			
		case 'response':
			ocsTypeID = objItem.getAttribute('ResponseTypeID');
			break;
		
		case 'note':
			ocsTypeID = objItem.getAttribute('NoteTypeID');
			break;		
	}
	
	var strReturn = '<item class="' + strClass + '" '
					  + 'id="' + objItem.getAttribute('dbid') + '" '
					  + 'description="' + XMLEscape(objItem.getAttribute('detail')) + '" '
					  + 'detail="' + XMLEscape(objItem.getAttribute('detail')) + '" '					  
					  + 'tableid="' + objItem.getAttribute('tableid') + '" '
					  + 'productid="' + objItem.getAttribute('productid') + '" '
					  + 'ocstype="' + strClass + '" '
					  + 'ocstypeid="' + ocsTypeID + '" '
					  + 'autocommit="' + objItem.getAttribute('autocommit') + '" '
					  + ' >';

	return strReturn;
}	


//===========================================================================================
function UsingV11(SessionID) {
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    var strURL = '../sharedscripts/SettingRead.aspx'
			  + '?SessionID=' + SessionID
			  + '&System=ICW'
			  + '&Section=OrderEntry'
			  + '&Key=UseV11';
    var blnUseV11 = false;

    objHTTPRequest.open("POST", strURL, false); //false = syncronous                              
    objHTTPRequest.send("");
    if (objHTTPRequest.responseText.toLowerCase() == "true") {
        blnUseV11 = true;
    }

    return blnUseV11;
}


function PrintMHAForm(SessionID) { 

    var colItems = GetHighlightedRowXML();

    var strXML = '<printitems>';
	for (i=0; i < colItems.length; i++){
		strXML += '<item '
				  + 'tableid="' + colItems[i].getAttribute('tableid') + '" '
				  + 'dbid="' + colItems[i].getAttribute('dbid') + '" '
				  + 'requesttypeid="' + colItems[i].getAttribute('RequestTypeID') + '" '
				  + 'responsetypeid="' + colItems[i].getAttribute('ResponseTypeID') + '" '
				  + 'notetypeid="' + colItems[i].getAttribute('NoteTypeID') + '" '	
				  + '/>'
	}
	strXML += '</printitems>'

    var strFeatures = "dialogHeight: 600px; dialogWidth: 600px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: Yes; status: No;";

    var returnval = window.showModalDialog("../Printing/ReportSelectorModal.aspx?SessionID=" + SessionID
											    + "&OrderReportTypeID=2" 
											    + "&IsMHAForm=true"
											, strXML
											, strFeatures
										 );
	if (returnval == 'logoutFromActivityTimeout') {
		returnval = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	if (returnval != undefined) {
	    var returnData;
	    returnData = JSON.parse(returnval);

	    if (returnData.Cancel == false) {
	        var strReportTypes_XML = '<ReportTypeFilter filtertype="exclude">';
	        strReportTypes_XML += '<ReportType description="Standard Order Comms" />';
	        strReportTypes_XML += '<ReportType description="Results Summary" />';
	        strReportTypes_XML += '<ReportType description="Batch" />';
	        strReportTypes_XML += '<ReportType description="Drug Chart Replacement" />';
	        strReportTypes_XML += '</ReportTypeFilter>';
	        ICWWindow().document.frames['fraPrintProcessor'].PrintReport(SessionID, returnData.ReportName, returnData.NoteId, false, strReportTypes_XML);
	    }
	}
}


//03Jul12   Rams    30302 - Reconcile button to automatically bring from other episode into new episode
function GetV11Location(SessionID) {
    var strURL = '../sharedscripts/WebConfigReader.aspx'
					+ '?SessionID=' + SessionID
					+ '&Find=V11Location';

    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    objHTTPRequest.open("POST", strURL, false);
    objHTTPRequest.send('');
    return objHTTPRequest.responseText;
}

function UpdateReviewRequest(SessionID, colItem) {
    var strFeatures = 'dialogWidth:860px;' + 'dialogHeight:750px;' + 'resizable:no;' + 'status:no;help:no;';
    var v11Location = ICWGetICWV11Location();
    if (v11Location != null)
        v11Location = v11Location + (v11Location.indexOf("/", v11Location.length - 1) == -1 ? "/" : "");

    var url = v11Location + "OrderComms/Views/OrderEntry/ReviewRequest.aspx?SessionID=" + SessionID + "&RequestID=" + colItem.getAttribute("dbid");
    var v11Mask = ICWWindow().document.getElementById('v11Mask');
    v11Mask.style.display = 'block';
    v11Mask.style.top = 0;
	var ret = window.showModalDialog(url, null, strFeatures);
	if (ret == 'logoutFromActivityTimeout') {
		ret = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}
    v11Mask.style.display = 'none';
    if (ret != null) 
    {
        switch (ret.toLowerCase()) 
        {
            case "cancel":
                ret = DoAction(OCS_CANCEL, document.body.getAttribute("trackChanges"));
                break;

            case "amend":
                ret = DoAction(OCS_CANCEL_AND_REORDER, document.body.getAttribute("trackChanges"));
                break;
        }
    }
    return ret;
}

//03Jul12   Rams    30302 - Reconcile button to automatically bring from other episode into new episode
function ReconcileItems(SessionID, colItems, includeChecks, xmlStatusFilter, adminStatus) {
    var returnVal = false;
    var strFeatures = 'dialogHeight:270px;' + 'dialogWidth:400px;' + 'resizable:no;' + 'status:no;help:no;';
    var RequestIDs = "";

    if (MessageBox("Warning", "Do you wish to prescribe the selected items in the current admission?", "NoYes", strFeatures) == "y") {
        for (i = 0; i < colItems.length; i++) {
            if (colItems[i].getAttribute("dbid") != null) {
                if (RequestIDs == "") {
                    RequestIDs = colItems[i].getAttribute("dbid");
                }
                else {
                    RequestIDs = RequestIDs + ',' + colItems[i].getAttribute("dbid");
                }
            }
        }
        //Show status message
        var HTMLwait = "<div style='width:300px;height:300px;top:40%;left:45%;position:absolute;overflow:auto;display:inline;'><div style='width:50px;height:50px;top:20%;left:4%;position:absolute;overflow:auto;display:inline;'><img src='../../images/Developer/ajax-loader.gif'></div><div style='width:50px;height:50px;top:35%;left:0%;position:absolute;font-family:arial;font-size:12px;color:#000000;'>Reconciling...</div></div>";
        document.getElementById("divContainer").innerHTML = HTMLwait;

        returnVal = CallReconcileService(SessionID, RequestIDs, includeChecks, colItems, xmlStatusFilter, adminStatus);
    }

    return returnVal;
}

function CallReconcileService(sessionId, requestIds, includeChecks, colItems, statusNoteFilter, adminStatus) {
    //        var v11Location = GetV11Location(SessionID); 
    //22Apr2014 Rams    With Https enabled cannot get the call from sharedscripts when the certificate error is thrown
    var v11Location = ICWGetICWV11Location();
    if (v11Location != null)
        v11Location = v11Location + (v11Location.indexOf("/", v11Location.length - 1) == -1 ? "/" : "");

    var xmlHttp = new ActiveXObject("Microsoft.XmlHttp");
    var url = v11Location + "ICWIntegrationService.svc/Web/AmendRequestsAndMoveEpisode";

    var body = '{"sessionToken":';
    body = body + sessionId + ',"includeChecks":' + includeChecks + ',"adminStatus":"' + adminStatus + '","requestsToAmend":';
    body = body + '"' + requestIds + '"' + '}';

    // Send the HTTP request
    xmlHttp.open("POST", url, false);
    xmlHttp.setRequestHeader("Content-type", "application/json");
    xmlHttp.send(body);

    // Create result handler 
    var result = JSON.parse(xmlHttp.responseText);

    if (result.d.Message.toLowerCase() == 'dsswarnings') {
        returnVal = ShowReconcileWarnings(sessionId, requestIds, result.d.StackTrace, colItems, statusNoteFilter, adminStatus);
    }
    else if (result.d.Message.toLowerCase() == 'incompleteitems') {
        returnVal = ReconcileOCSRequest(sessionId, colItems, statusNoteFilter);
    }
    else if (result.d.Message != 'Success') {
        alert(result.d.Message);
    }
    else {
        returnVal = true;
    }    
}

function ShowReconcileWarnings(sessionId, requestIds, warnings, colItems, statusNoteFilter, adminStatus) {
    SessionAttributeSet(sessionId, "V11DssChecks", warnings);

    var url = "../dss/V11DssResultsDisplay.aspx?SessionID=" + sessionId;

    var objArgs = new Object();
    objArgs.opener = self;

    var ret = window.showModalDialog(url, objArgs, 'dialogHeight:700px;dialogWidth:1000px;resizable:yes;unadorned:no;status:no;help:no;menubar:no');
	if (ret == 'logoutFromActivityTimeout') {
		ret = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	if (ret) {
        return CallReconcileService(sessionId, requestIds, false, colItems, statusNoteFilter, adminStatus);
    }

    return false;
}

//==========================================================================================
function EpisodeIDFromRow(objItem)
{
	//Return an episode id of this row, if it has one
	var lngEpisodeID = 0;
	do
	{
		// Changed below to handle episode items returned in worklist
		try
		{
			if (objItem.getAttribute("class") == 'episode')
			{
				lngEpisodeID = objItem.getAttribute("dbid");
			}
			else
			{
				lngEpisodeID = objItem.getAttribute("EpisodeID");
			}
		}
		catch (e)
		{
			break; 		 	//error indicates item has no getattribute method - in which case we've reached the top and have to stop, but it's not bothering me.
		}

		if (lngEpisodeID == null)
		{
			//Look at the parent item	
			objItem = objItem.parentNode;
		}
		else
		{
			break;
		}
	}
	while (objItem != undefined)

	if (lngEpisodeID == null || Number(lngEpisodeID) == NaN)
	{
		lngEpisodeID = 0;
	}

	return lngEpisodeID;
}
