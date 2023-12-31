//Variable naming Constants
var DA_ROUTINENAME_PATIENT = 'RoutinePatient';
var DA_PATIENT_SEARCH = 'SearchPatient';
var DA_ENTITYID = 'EntityID';
var DA_EPISODEID = 'EpisodeID';
var DA_HEIGHT = 'Height';
var DA_WIDTH = 'Width';
var DA_REQUESTID = 'RequestID_Admin';
var DA_ARBTEXTTYPE = 'TypeText';
var DA_DESTINATION_URL = 'Dest';
var DA_REFERING_URL = 'Referer';
var DA_ARBTEXTID = 'ArbTextID';
var DA_ADMINISTERED = 'Administered';
var DA_PARTIAL = 'Partial';
var DA_PRESCRIPTIONID = 'RequestID_Rx';
var DA_ARBTEXTRETURNID = 'ArbTextReturnID';
var DA_ARBTEXTID_EARLY = 'ArbTextID_EARLY';
//var DA_ENTITYID_CHECKER = "EntityID_Checker";														// 25Jan07 ST  Added for double checking administration
var DA_REPLY = 'Reply';
var DA_PRODUCTID_PRESCRIBED = 'ProductID_Prescribed';												//Product which was surprised
var DA_PRODUCTID_SELECTED = 'psl';																		//Product which the user has chosen to administer against the prescribed product
var DA_BATCHNUMBER_XML = 'BatchNumberXML';															//List of batch numbers entered;
var DA_BATCHEXPIRYDATE_XML = 'BatchExpiryDateXML';															//List of batch numbers entered;
var DA_SELECTED_PRODUCT_XML = 'SelectedProductXML';
var DA_PRODUCT_LIST_XML	= 'AvailableProductXML';													//List of all products for all doses, generated by the pick list page.
var DA_DOSES_LIST_XML = 'AllDosesXML';																	//List of all doses
var DA_NOTE = "AdministrationNote";

var DA_ROUTEID = 'ProductRouteID';
var DA_FORMID = 'ProductFormID';
var DA_PROMPT = 'Prompt';
var DA_ADMINDATE = 'Date';
var DA_DOSE = 'Dose';
var DA_DOSETO = 'DoseTo';
var DA_UNITNAME = 'UnitName';
var DA_UNITID = 'UnitID';
var DA_ADD_QUANTITY = 'Quantity';
var DA_MODE = 'Mode';
var DA_TOTAL_SELECTED = "DoseSelected"																	//Dose the user has entered
var DA_UNITID_SELECTED = "UnitID_Selected"															//Unit in which the above DoseSelected is expressed.
var DA_UNIT_SELECTED = "Unit_Selected"																	//Description of the Unit in which the above DoseSelected is expressed.

//Immediate Admin
var IA_ITEMS = 'ImmediateAdminItems'          //state items xml list
var IA_INDEX = 'ImmediateAdminIndex'          //state current item index
var IA_ADMIN = 'ImmediateAdministration'      //state flag indicating immediate admin

//Text strings
var TXT_ENTER_NON_ADMIN_REASON = 'Please indicate why the dose was not given.';
var TXT_ENTER_PARTIAL_ADMIN_REASON = 'Please indicate the problem which occurred with the administration of this dose.';
var TXT_ENTER_INFUSIONDATEDISCREPENCY = 'MaxInfusionChangeTimeMinutes exceeded, please indicate why.';
var TXT_ENTER_PRN_EARLY_ADMIN_REASON = 'Please indicate the reason for early administration.';

//Type name constants
var ARBTEXTTYPE_NON_ADMIN_REASON = 'Non Administration Codes';
var ARBTEXTTYPE_PARTIAL_ADMIN_REASON = 'Partial Administration Codes';
var ARBTEXTTYPE_FLUID_CHANGE_ADMIN_REASON = 'Fluid Change Reason Codes';
var ARBTEXTTYPE_PRN_EARLY_ADMIN_REASON = 'PRN Early Reason'

//XML Constants
var ATTR_PRODUCTID_SELECTED = "ProductID_Selected"
var ATTR_UNIT_ACTIVEQUANTITY = "u";																//Description of the unit of the active ingredient; usually mg
var ATTR_UNIT_ACTIVEQUANTITYID = "y";															//Unit of the active ingredient; usually mg
var ATTR_QUANTITY = "rqty"																			//Quantity required in whole "things" - tablets, capsules etc, but will be whole containers (sachets, syringes) for liquids
var ATTR_QUANTITY_ML = "mqty"																		//Quantity required in mL, if this is a liquid. as calculated by the puter
var ATTR_QUANTITY_SELECTED = 'sqty';															//Quantity the user has selected
var ATTR_PRODUCTID = 'k';
var ATTR_HIDE = 'h';
var ATTR_DRUG_TRADENAME = 't';
var ATTR_DRUG_DESCRIPTION = 'd';
var ATTR_ACTIVEQUANTITY = "q";																	//Amount of active ingredient per whole "thing" (eg number of mg per tablets).  For liquids, the amount per mL
var ATTR_DISPLAYUNIT = 'i';																		//"dosing unit" for display; forms such as "tablet", "capsule" etc, but mL for liquids
var ATTR_BATCHEXPIRYDATE = 'bed'                                                                // Tage used to indicate this is a batch number expiry date
var ATTR_BATCHNUMBER = 'n';
var ATTR_STOCKLOCATION = 'l';																		//Tag used to indicate if this is ward stock, pharmacy stock, or dispensed.
var ATTR_UNABLE_TO_FULFILL = 'x';
var ATTR_PATIENT = 'p'
var ATTR_SELECTED = 's';
var ATTR_ID = 'id';
var ATTR_PRODUCTFORMID = 'f';
var ATTR_DISABLED = 'z';
var ATTR_SECONDCHECK = "sec";

var NODE_PRODUCT = 'P'

//Values for pick list
var STOCKLOCATION_DISPENSED = 'dispensed';
var STOCKLOCATION_WARDSTOCK = 'ward'
var STOCKLOCATION_PHARMACY = 'pharmacy'

// Batch constants
var BATCH_EXPDATEENTRY_OFF       = "off"
var BATCH_EXPDATEENTRY_OPTIONAL  = "optional"
var BATCH_EXPDATEENTRY_MANDATORY = "mandatory"

//Request & Response Type Constants
var RESPONSETYPE_BASE = "Administration Simple"
var RESPONSETYPE_STANDARD = "Administration Standard"
var RESPONSETYPE_DOSELESS = "Administration Doseless"
var RESPONSETYPE_INFUSION = "Administration Infusion"

var REQUESTTYPE_STANDARD = "Drug Administration"
var REQUESTTYPE_INFUSION = "Infusion Administration"
var REQUESTTYPE_DOSELESS = "Doseless Administration"

var REQUESTTYPE_ORDERSET = "Order set"
var REQUESTTYPE_CYCLEDORDERSET = "Cycled order set"
var REQUESTTYPE_ADMINISTRATIONSESSIONORDERSET = "Administration Session Order Set"
