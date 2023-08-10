//------------------------------------------------------------------------------------
//
//										OCSIMAGES.JS
//
//	Contains constants and functions for returning image names and paths
//	for Order Comms Items.
//	
//	In general, use IMAGE_DIR + <image name> as the src attribute of an image.
//	<image name> would normally be returned from the GetImageByClass() function;
//	The exception is IMAGE_OPEN and IMAGE_CLOSED which are used for expanding / 
// contracting tree nodes.
//
//	06Oct04 AE  Added Optional strOCSType parameter and Admin image.
//	25Oct06 AE  Handle Orderset type Requests.  Fixes incorrect icons #SC-06-1020
//------------------------------------------------------------------------------------


//Images Name and location constants
IMAGE_DIR = '../../images/ocs/';

IMAGE_OPEN = 'classSetOpen.gif';
IMAGE_CLOSED = 'classSetClosed.gif';
IMAGE_EMPTY = 'classSetEmpty.gif';
IMAGE_FOLDEROPEN = 'classFolderOpen.gif';
IMAGE_FOLDERCLOSED = 'classFolderClosed.gif';
IMAGE_SET = 'classOrderSet.gif';
IMAGE_OPTIONSSET = 'classOptionOrderset.png';
IMAGE_TEMPLATE = 'classTemplate.gif';
IMAGE_REQUEST = 'classRequest.gif';
IMAGE_RESPONSE = 'classResponse.gif';
IMAGE_NOTE = 'classNote.gif';
IMAGE_ATTACHEDNOTE = 'classAttachedNote.gif';
IMAGE_SEARCHTYPE = 'classSearchStructure.gif';
IMAGE_PATIENT = 'classPatient.gif';
IMAGE_EPISODE = 'classEpisode.gif';
IMAGE_PRESCRIPTION = 'classPrescription.gif';
IMAGE_INFUSION = 'classPrescription_Infusion.gif';
IMAGE_ALLERGY = "classAllergy.gif";
IMAGE_INFO = 'classInfo.gif';
IMAGE_PENDING = 'classPending.gif';
IMAGE_UNKNOWN = 'classUnknown.gif';
IMAGE_CLINICALTERM = 'classClinicalTerm.gif';
IMAGE_CLINICALTERMTYPE = 'classClinicalTermType.gif';
IMAGE_CLINICALTERMROOT = 'classClinicalTermRoot.gif';
IMAGE_REASON = 'classTreatmentReason.gif';
IMAGE_REASONROOT = 'classTreatmentReasonRoot.gif';
IMAGE_ADMINISTRATION = 'classAdmin.gif';
IMAGE_PRODUCT = 'classProduct.gif';

//------------------------------------------------------------------------------------

function GetImageByClass(strClassName, strOCSType, blnContentsAreOptions) {
/*
	Given an item type, returns the correct image name to use.
	
		strClassName: 	String containing one of    "Request|Response|Note"   (case insensetive)
		strOCSType:		Optional; string containing the request, response or note type description.
		returns: 		string containing the image name
		
*/
	var strImage = new String('blank');
	var blnPrescription = false;
	var blnInfusion = false;
	var blnAdmin = false;
	var blnOrderset = false;
			
	//Determine special items which we wish to give separate icons to

	if ( typeof( strOCSType )!="string" )
	{
		strOCSType='';
	}

	strOCSType = strOCSType.toLowerCase();
	switch (strOCSType) {
		case 'standard prescription':
		case 'doseless prescription':
			blnPrescription = true;
			break;
		
		case 'infusion prescription':
			blnInfusion = true;
			break;
		
		case 'drug administration':
		case 'infusion administration':
		case 'doseless administration':
			blnAdmin = true;
			break;
			
		case 'order set':																					//25Oct06 AE  Handle Orderset type Requests.  Fixes incorrect icons #SC-06-1020
			blnOrderset = true;
			break;
	}


	var strClass = strClassName.toLowerCase();
	switch (strClass) {
		case 'request':
			strImage = IMAGE_REQUEST;
			if (blnPrescription) strImage = IMAGE_PRESCRIPTION;
			if (blnInfusion) strImage = IMAGE_INFUSION;
			if (blnAdmin) strImage = IMAGE_ADMINISTRATION;
			if (blnOrderset) strImage = IMAGE_SET;													//25Oct06 AE  Handle Orderset type Requests.  Fixes incorrect icons #SC-06-1020
			break;
			
		case 'response':			
			strImage = IMAGE_RESPONSE;
			break;
	
		case 'note':
			strImage = IMAGE_NOTE;
			break;

        case 'orderset':
            if (blnContentsAreOptions) {
                strImage = IMAGE_OPTIONSSET;
            }
            else {
                strImage = IMAGE_SET;
            }
            break;
			
		case 'ordersetinstance':
			strImage = IMAGE_SET;
			break;
			
		case 'folder':
			strImage = IMAGE_FOLDERCLOSED;
			break;

		case 'patient':
			strImage = IMAGE_PATIENT;
			break;

		case 'episode':
			strImage = IMAGE_EPISODE;
			break;
		
		case 'template':			
			strImage = IMAGE_TEMPLATE;
			break;
			
		case 'prescription':			
			strImage = IMAGE_PRESCRIPTION;
			break;
			
		case 'attached note':
			strImage = IMAGE_ATTACHEDNOTE;
			break;
			
		case 'allergy':
			strImage = IMAGE_ALLERGY;
			break;
			
		case 'entity':
			strImage = IMAGE_PATIENT;
			break;
			
		case 'pending':
			strImage = IMAGE_PENDING;
			break;
		
		case 'product':
			strImage = IMAGE_PRODUCT;
			break;

        case "treatmentplan":
            strImage = IMAGE_SET;
            break;
		
		default:
			strImage = IMAGE_UNKNOWN;
			break;
	}
	
	return strImage
		
}


