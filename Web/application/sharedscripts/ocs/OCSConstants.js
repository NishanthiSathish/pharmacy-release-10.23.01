//Infusions Constants
var ATTR_DOSE = 'Quantity';
var ATTR_DOSE_ORIGINAL = 'Quantity_Original';
var ATTR_DOSEMIN = 'QuantityMin';
var ATTR_DOSEMAX = 'QuantityMax';
var ATTR_DOSEUNIT = 'UnitID';
var ATTR_DOSEUNIT_ORIGINAL = 'UnitID_Original';
var ATTR_ROUTINEID = 'RoutineID';
var ATTR_DOSERATEUNIT = 'UnitID_Time';
var ATTR_INFUSIONRATE = 'Rate';
var ATTR_INFUSIONRATEMIN = 'RateMin';
var ATTR_INFUSIONRATEMAX = 'RateMax';
var ATTR_INFUSIONRATE_ORIGINAL = 'Rate_Original';									//21Mar05 AE  Added _Original and _Calculated to all 3 rate fields
var ATTR_INFUSIONRATEMIN_ORIGINAL = 'RateMin_Original';
var ATTR_INFUSIONRATEMAX_ORIGINAL = 'RateMax_Original';
var ATTR_INFUSIONRATE_CALCULATED = 'Rate_Calculated';
var ATTR_INFUSIONRATEMIN_CALCULATED = 'RateMin_Calculated';
var ATTR_INFUSIONRATEMAX_CALCULATED = 'RateMax_Calculated';
var ATTR_INFUSIONLINEID = 'InfusionLineID'
var ATTR_UNIT_RATEMASS = 'UnitID_RateMass';
var ATTR_UNIT_RATETIME = 'UnitID_RateTime';
var ATTR_ROUND_INCREMENT = 'RoundToNearest';											//26Mar05 AE  Added	rounding
var ATTR_ROUND_UNIT = 'UnitID_Rounding';												//07Apr05 AE  ...and the unit thereof
var ATTR_DOSE_CAP = 'DoseCap';
var ATTR_DOSE_CAP_UNIT = 'UnitID_DoseCap';
var ATTR_DOSE_CAP_CAN_OVERRIDE = 'DoseCap_CanOverride';
var ATTR_DOSE_REEVALUATE = 'Reevaluate_Dose';


var ATTR_INFUSIONDURATION = 'InfusionDuration';
var ATTR_INFUSIONDURATIONLOW = 'InfusionDurationLow';
var ATTR_UNIT_DURATION = 'UnitID_InfusionDuration';
var ATTR_CONTINOUS = 'Continuous';

//General Constants
var ATTR_ISDOSECHANGED = 'IsDoseChanged';
var ATTR_ISCALCULATED = 'IsCalculated';
var ATTR_CALCULATION_ORIGINAL = 'Calculation_Original';
var ATTR_CALCULATION_CALCULATED = 'Calculation_Calculated';
var ATTR_ROUTINEDESCRIPTION = 'RoutineDescription';
var ATTR_TEMPLATEDETAIL = 'TemplateDetail';

//Change reporting Constants																//15Apr05 AE  Added change reporting
var NOTETYPE_CHANGEREPORT = 'Change Report';
var XML_ELMT_CHANGEROOT = 'changes';
var XML_ELMT_CHANGE = 'c';
var ATTR_CHANGE_ID = 'id';
var ATTR_CHANGE_ORIGINAL = 'old';
var ATTR_CHANGE_NEW = 'new';
var ATTR_CHANGE_DOSE = 'Dose';
var ATTR_CHANGE_ROUTE = 'Route';
var ATTR_CHANGE_FREQUENCY = 'Frequency';
var ATTR_CHANGE_DURATION = 'Duration';
var ATTR_CHANGE_DURATION_INFUSION = 'Infusion Duration';
var ATTR_CHANGE_RATE = 'Rate';
var ATTR_CHANGE_RATE_LIMITS = 'Rate Limits';
var ATTR_CHANGE_DIRECTION_DOSELESS = 'Direction Text';
var ATTR_CHANGE_DIRECTION = 'Directions';
var ATTR_CHANGE_DOSECAP_CALCULATED = "DoseCapCalculated";
var ATTR_CHANGE_DOSECAP_ENTERED = "DoseCapEntered";

//Reason Capture Constants
var ATTR_DOSERANGE_RULE = "Rule_DoseRange"
var XML_ELMT_REASON = "reasoncapture"
var XML_ATTR_CAPTUREMODE = "mode"
var XML_ATTR_REASONID = "reasonid"
var XML_ATTR_REASONIDTEXT = "reasontext"
var XML_ATTR_REASONTYPE = "type"
var REASONTYPE_CLINICAL = "clinical"
var REASONTYPE_NONCLINICAL = "nonclinical"

//Values for the mode attribute
var CAPTUREMODE_NEVER = "never"
var CAPTUREMODE_OPTIONAL = "optional"
var CAPTUREMODE_MANDATORY = "mandatory"

//Settings Definitions
var SYSTEM_OCS = "OCS"
var SECTION_TASKPICKER = "Taskpicker"
var SECTION_ORDERENTRY = "OrderEntry"

var KEY_SEARCH_IN = "SearchIn"
var DESCRIPTION_SEARCH_IN = "The default option shown in the 'search in' box on the task picker."
var DEFAULT_SEARCH_IN = "My Formulary"

var KEY_FILTER = "Filtering"
var DESCRIPTION_FILTER = "Hide Doses which do not apply to the current patient."
var DEFAULT_FILTER = "1"

//var KEY_INCLUDE_PRODUCTS = "IncludeProductSearch"
//var DESCRIPTION_INCLUDE_PRODUCTS = "Search the entire product recipe hierarchy when searching in 'Everything' (not recommended)"
//var DEFAULT_INCLUDE_PRODUCTS = "0"

var KEY_REMEMBER_SEARCH_IN = "RememberSearchIn"
var DESCRIPTION_REMEMBER_SEARCH_IN = "Remember the last option selected in the 'search in' box."
var DEFAULT_REMEMBER_SEARCH_IN = "1"

var KEY_REMEMBER_TAB = "RememberTab"
var DESCRIPTION_REMEMBER_TAB = "Remember the last tab used, and take me straight to that tab next time."
var DEFAULT_REMEMBER_TAB = "1"

var KEY_LAST_TAB = "Tab"
var DESCRIPTION_LAST_TAB = "The tab which will be selected when the task picker is loaded. (one of 'contents', 'favourites', 'search')"
var VALUE_TAB_CONTENTS = 'contents'
var VALUE_TAB_FAVOURITES = 'favourites'
var VALUE_TAB_SEARCH = 'search'

var KEY_SEARCH_ALWAYS_VISIBLE = "SearchAlwaysShown"
var DESCRIPTION_SEARCH_ALWAYS_VISIBLE = "Search box is always visible.";
var DEFAULT_SEARCH_ALWAYS_VISIBLE = '1';

var KEY_NOBASKET = "NoBasket"
var DESCRIPTION_NOBASKET = "Close the taskpicker as soon as an item is selected; (hides the Orders Selected tab)"
var DEFAULT_NOBASKET = "0"

var KEY_DEFAULT_VIEW = 'DefaultView'
var DESCRIPTION_DEFAULT_VIEW = "Specifies the default view for Order Entry - use Standard for "
									  + "a Paged View, Stacked for the Stacked view.";
var VALUE_PAGED_VIEW = 'Paged';
var VALUE_STACKED_VIEW = 'Stacked';

var KEY_SEARCH_NON_FORMULARY = 'SearchNonFormularyDrugs';
var DEFAULT_SEARCH_NON_FORMULARY = '0';
var DESCRIPTION_SEARCH_NON_FORMULARY = 'Include non-formulary drugs in searches (generally this should be turned off; '
												 + 'only use when you need to find something non-formulary)';
												 
var KEY_TEXT_SEARCH = 'SimpleTextSearch'
var DESCRIPTION_TEXT_SEARCH = 'Tick this option to use simple text searching.  This will search template descriptions only; '
									 + 'searching by indication, bnf chapter etc will not be available.'
var DEFAULT_TEXT_SEARCH = 0

var SECTION_PRESCRIBING = "Prescribing"																						//13Mar07 AE  Added configurable copy dispensing instruction
var KEY_COPY_DISPENSING_INSTR = "CopyDispensingInstruction"
var DEFAULT_COPY_DISPENSING_INSTR = 0