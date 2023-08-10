//=======================================================================================================================
//
//									Standard Prescription Functions
//
//	Please be aware that this is a shared script, and is used for PrescriptionInfusion.aspx
//	and Nurse admin.aspx (and possibly others).
//	Ensure that any changes made here do not cause problems in these other pages.
//
//	Modification History:
//	05Mar03 AE  Written
// 05Jun03 AE  Moved all the pop-up pick list functions into PickList.js
//	20Apr04 AE  Additions for ProductFormID as well as UnitIDs
// 04Oct04 AE  RoundDose:  Rewrote algorithm, now works properly.
//	06Oct04 AE  RoundDose: Added some linking logic between the from/to boxes
//	04Feb05 AE  Fixes in PopulateForm_Common to ensure start date correctly populated.
//	19Apr05 AE  Added Track Changes functionality

//	20Apr05 AE  Don't try to save a note with nothing in it.
// 02Sep05 ST  Fixed problem with duration getting ID from duration listbox instead of actual duration value
//	05Oct05 AE  Considerable restructuring as the route picker and frequency picker have been changed to use combo
//					boxes instead of pickers.  Old EnterRoute, EnterFrequency methods removed.
// 24Nov05 AE  Added ProductPackage to the available Dosing Units, for sachets etc
// 13Dec05 AE  ControlFocus: Removed duplicate call to lstRoute.focus()  #DR-05-0022
//	15Dec05 AE  Modified description building as per #DR-05-0069.
//					Corrected persisting of PRN frequency as per #SC-05-0124
//16Mar06 AE  	Moved attachednotes node.  Fixes #SC-06-0377, (broken by "attached notes on pending" item enhancement)
//	27Mar06 AE  Changed direction lookup boxes to Label elements, also only allows single code entry.  Fix #SC-06-0190 and #DR-06-0151
// 04Apr06 AE  Prevent duplication of text in doseless prescriptions
//	24May06 AE  Added NoDoseInfo attribute for Doseless prescriptions and associated code. #DJ-06-0079
// 14Jul06 PH Removed 128 description truncation
//	04Sep60 AE  PopulateForm_Standard: SC-06-0685  Prevent trailing zeros
// 26Feb07 AE  ShowStatControls: Reinstated as had been mysteriously deleted. #SC-07-0101
// 15/8/08 SH Added an update function to allow the description to be changed as data is entered - part of F0023374
//=======================================================================================================================

var ID_SHOWALL = -5;

//Pop-up picker variables
var m_blnShownDetails = false;											//Used as a switch to indicate that we've shown the calculation automatically
var m_objTextBox = new Object();											//Stores a reference to the destination text box during asyncronous pop-up calls
var m_objPickerButton = new Object();											//Stores a reference to the button used to call the method during asyncronous pop-up calls

var SCHEDULER_WIDTH = 750;
var SCHEDULER_HEIGHT = 450;

//Constants
var SELECTED_BACKGROUND_COLOUR = '#00599C';
var BACKGROUND_COLOUR = '#D6E3FF';

//Indexes for the "special" items in lstFrequency
var INDEX_NODOSEINFO = 3;
var INDEX_STAT = 1;
var INDEX_PRN = 2;
//Pseudo Frequency IDs.  We present these to the user
//as if they are frequency templates, although in fact
//they each work differently.//var FQID_ADVANCED = -100;				//Indicates that an advanced (ad-hoc) schedule is being used, rather than a template									
//var FQID_PRN = -200;															//Indicates that the prescription is a true PRN (As Required), with no dosing times specified.
																						//The PRN box may be checked AND a frequency specified; this represents an IF required prescription.
																						//Both are considered to be PRN by medics, although the meaning is actually quite different.
var FQID_STAT = -300;															//Indicates a STAT (one-off) dose

//Request Type Identifiers
var REQUESTTYPE_STANDARD = 'Standard Prescription';
var REQUESTTYPE_DOSELESS = 'Doseless Prescription';
var REQUESTTYPE_INFUSION = 'Infusion Prescription';

//Text for standard menu items; may be read from the 
//server in future, so constantised for easy modification.
var MNUTXT_ADVANCED = '[Advanced...]';
var MNUTXT_PRN = 'PRN - When Required';
var MNUTXT_STAT = 'STAT - Single Dose';
var MNUTXT_CONTINUOUS = 'Continuous Infusion';

var MESSAGE_RECALCULATING = 'Recalculating Doses...';
//Title strings
var TITLE_RANGEHIDDEN = 'Click here to enter a range of doses (such as "1 to 2 tablets")';
var TITLE_RANGESHOWN = 'Click here to enter only a single dose (such as "10 mg")';

var m_objPicker;
var m_objHTTPRequest; 														//HTTP Request object used for asyncronous ajax calls.

var m_CurrentStartDate; 				// Used to determine when the start date changes. (And not just rely on blur (lost focus) event)
var m_CurrentStartTime; 				// Used to determine when the start time changes. (And not just rely on blur (lost focus) event)

var originalDurationMandatory;                          // Stores the original duration mandatory value, as this value may change when using stat frequency

//=======================================================================================================================
//								Form set-up
//=======================================================================================================================

var m_windowLoading; // Used to prevent prescription refreshing during initial load for bug F0023374

function window_onload()
{
    m_windowLoading = true; //Used by bug fix F0023374


	if (document.readyState=='complete')
	{
		if ( instanceData.XMLDocument.xml!="" )
		{
			PopulateForm();
		}
		else
		{
			instanceData.XMLDocument.loadXML('<root id="-1" class="template" template="1"><data /></root>');
			if (document.body.getAttribute("rxask")=='false' && document.body.getAttribute("istemplatemode")=='true')
			{
			    if ( document.body.getAttribute('requesttype') == REQUESTTYPE_INFUSION )
			        PopulateForm_Infusion();
			    else
                    PopulateForm_Common();
			}
		}
		var intOrdinal = document.body.getAttribute("ordinal");

		if (window.parent.IndicateOrderFormReady != undefined)
		{
			void window.parent.IndicateOrderFormReady(intOrdinal);
		}
	}
	
	m_windowLoading = false; //Used as part of bug fix F0023374

    //Refresh the Description, in case we were loaded as part of the diluence refresh
    DescriptionChangeRequired();    

}

function InitRxForm() {
//Ensure the proper bits are shown/hidden; called immediately
//after the PopulateForm method

	void ToggleStartDate();
}

//=======================================================================================================================
function ControlFocus(){
//Function called from outside when readying the form.
//Focus on the first empty mandatory field.
var blnDone = false;

	if (document.body.getAttribute('displaymode') == 'true') return;
	var blnDoseless = (document.body.getAttribute('requesttype') == REQUESTTYPE_DOSELESS);
	var blnInfusion = (document.body.getAttribute('requesttype') == REQUESTTYPE_INFUSION);

	if (document.all['lstRoute'] != undefined){	
		if ( (lstRoute.options[lstRoute.selectedIndex].value=="empty" ) && CanAcceptFocus(lstRoute)) {lstRoute.focus(); blnDone = true;};					//Route
		if (!blnDone && !blnDoseless && CanAcceptFocus(document.all['txtDoseQty']) && Number(txtDoseQty.value) == 0){txtDoseQty.focus(); blnDone = true; };		//Normal Prescription - Dose
		if (!blnDone && blnDoseless && CanAcceptFocus(cmdPickDirection) && GetValueFromTextBoxOrLabel(txtDirection) == ''){										//16Aug06 AE  #SC-06-0678 - focus to button and autodisplay pop-up
			cmdPickDirection.focus(); 
			SelectText(cmdPickDirection, txtDirection, true); 
			blnDone = true;																	//Doseless Prescription - Directions
		}
		if (!blnDone && blnInfusion){
			if (document.all['txtDose'].length == undefined){																															//Infusion Prescription - Dose
			//Single Product, only one txtDose box exists
				if (CanAcceptFocus(document.all['txtDose']) && txtDose.value == ''){txtDose.focus(); blnDone = true; };												
			}
			else {
			//Multiple products, txtDose is a collection
				for (i=0;i<txtDose.length;i++){
					if (CanAcceptFocus(txtDose[i]) && txtDose[i].value == ''){
						txtDose[i].focus(); 
						blnDone = true;
						break;
					}
				}	
			}
		}
		if (document.all['lstFrequency'] == undefined)
		    return; //13Feb07 CD  lstFrequency doesn't exist on rate based infusions
		if (!blnDone && lstFrequency.selectedIndex == 0 && CanAcceptFocus(lstFrequency)) {lstFrequency.focus(); blnDone = true};								//Frequency
	}
}

//=====================
// Infusion Rate Change 
//=====================
function InfusionRate_Change(objControl)
{
    //Whenever the settings for the Infusion Rate Change, update the description with the changes
    DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}


//=======================================================================================================================
//								Dose Calculations and handling
//=======================================================================================================================
function DoseChanged_Infusion(objControl) {
//When the dose has changed on an infusion, we will usually need to update the diluent calculations
//to match, if a diluent is specified.
var objRow;
var lngProductID = 0;
var dblDose = 0;
var objSelect;
var lngUnitId = 0;
var xmlProduct;
var xmlIngredient;
var xmlRoot;
var blnDoCalculation = true;
var strDoseUnit = "";

	//We will need to recalculate if:
	//	at least one of the ingredients requires reconstitution
	//	OR the diluent quantity is calculated 
	
	var colReconstitution = infusionDiluent.XMLDocument.selectNodes('Diluents/Reconstitution/Product[@ReconstitutionRequired="1"]');
	//var colCalculatedFinalVol = infusionDiluent.XMLDocument.selectNodes('Diluents/Product[@FinalVolume_Calculated="True"]');
	var colCalculatedDiluentQty = infusionDiluent.XMLDocument.selectNodes('Diluents/Product[@DiluentQuantity_Calculated="True"]');
	//if (colReconstitution.length > 0 || colCalculatedFinalVol.length > 0){
	if (colReconstitution.length > 0 || colCalculatedDiluentQty.length > 0){
	//We need to recalculate.
	//We'll do it as an async ajax call to keep things looking nice.
		//First update the xml with the entered dose(s).
		for (i=1;i < tblIngredients.rows.length; i++){	
			objRow = tblIngredients.rows[i].all['trDose_Infusion'];
			if (typeof(objRow) != 'undefined'){
				lngProductID = objRow.getAttribute('productid');		
				dblDose = objRow.all['txtDose'].value;
				objSelect = objRow.all['lstUnits'];
				lngUnitID = objSelect.options[objSelect.selectedIndex].getAttribute('dbid');	
				strDoseUnit = objSelect.options[objSelect.selectedIndex].innerText;
		
				xmlProduct = infusionDiluent.XMLDocument.selectSingleNode('Diluents/Reconstitution/Product[@ProductID="' + lngProductID + '"]');
				if(xmlProduct == null)
				{
					blnDoCalculation = false;
					break;
				}

                // F0083669 ST 16Apr10 Add the dose unit name to the xml for later use				
				xmlProduct.setAttribute('DoseRequired', dblDose);
				xmlProduct.setAttribute('DoseUnit', lngUnitID);
				xmlProduct.setAttribute('DoseUnitName', strDoseUnit);	
				
				xmlIngredient = infusionProducts.XMLDocument.selectSingleNode('Ingredients/Product[@ProductID="' + lngProductID + '"]');
				if (xmlIngredient != null && document.body.getAttribute("istemplatemode") != 'true') // PR do not want to set attribute in templates, as it is stopping doses from being calculated
				{
				    xmlIngredient.setAttribute('IsDoseChanged', true);
				}

			}
		}

		if (blnDoCalculation){
			var strURL = '../../OrderEntry/DiluentWorker.aspx'			
						  + '?SessionID=' + document.body.getAttribute('sid')
						  + '&Mode=DoCalculations';

			tdDiluentDose.innerText = 'Recalculating...';	
			m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
			m_objHTTPRequest.open("POST", strURL, true);	//false = syncronous    
			m_objHTTPRequest.setRequestHeader("Content-Type", "text/xml");                            //application/x-www-form-urlencoded
			m_objHTTPRequest.onreadystatechange=DoseChanged_Infusion_Return;
			m_objHTTPRequest.send(infusionDiluent.XMLDocument.xml);
		}
		else {
			tdDiluentName.innerHTML = 'Unable&nbsp;to&nbsp;perform&nbsp;calculations';
		}		
	}

	DescriptionChangeRequired();  // Call to change description for bug fix F0023374
	DisplayDoseDifference(objControl);
}

function DoseChanged_Infusion_Return(){
//Event handler for the m_objHTTPRequest object
	if (m_objHTTPRequest.readyState == 4){	
		infusionDiluent.XMLDocument.loadXML (m_objHTTPRequest.responseText);

		var xmlDiluent = infusionDiluent.XMLDocument.selectSingleNode('Diluents/Product')
		if (null != xmlDiluent) {
		    //F0083417 ST 13Apr10 Updated to use final volume so now the same as everywhere else.
		    tdDiluentDose.innerText = RoundToDecPl(xmlDiluent.getAttribute('DiluentFinalVolume'), 2) + "mL";
		    //tdDiluentDose.innerText = RoundToDecPl(xmlDiluent.getAttribute('DiluentQty'), 2)+"mL";
		    //tdDiluentDose.innerText = RoundToDecPl(xmlDiluent.getAttribute('DiluentFinalVolume'), 2);
		}
	}
	DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}



function CalculationFormFeatures(){

//The features string used for the dose calculation pop-up
	var strReturn = 'dialogHeight:500px;' 
					 + 'dialogWidth:800px;'
					 + 'resizable:yes;unadorned:no;'
					 + 'status:no;help:no;';		
	return strReturn;
}	
	
//=======================================================================================================================

function ShowCalculation(blnDoseWasCalculated) {

//blnDoseWasCalculated:		True if a calculation has been made.
var intCount = new Number();
var astrDose = new Array();
var astrItem = new Array();
    //17-Jan-2008 JA Error code 162
	//Load the dose calculation dialog
	var strURL = '../../DSS/DoseCalculation.aspx'
				  + '?SessionID=' + formBody.getAttribute('sid')
				  + '&RoutineID=' + lblDrugName.getAttribute('calculation_routineid')
				  + '&Value=' + lblDrugName.getAttribute('calculation_dose')
				  + '&ValueLow=' + lblDrugName.getAttribute('calculation_doselow')
				  + '&Unit=' + lstUnits.options[lstUnits.selectedIndex].innerText
			  	  + '&UnitID=' + lstUnits.options[lstUnits.selectedIndex].getAttribute('dbid')
			  	  + '&changed=0';				  

    
	if(Number(txtRoundValue.value) > 0)
	{	
		var roundTo = txtRoundValue.value;	
		var roundToUnit = lblRoundUnit.getAttribute('dbid');
		if (Number(roundTo) > 0)
		{																									//07Apr05 AE  Added rounding support
			strURL += '&RoundTo=' + roundTo
				  + '&RoundToUnitID=' + roundToUnit;
		}
	}
	else
	{
		var roundTo = lblDrugName.getAttribute('persisted_roundto');
		var roundToUnit = lblDrugName.getAttribute('persisted_roundtounitid');
		if (Number(roundTo) > 0)
		{																									//07Apr05 AE  Added rounding support
			strURL += '&RoundTo=' + roundTo
				  + '&RoundToUnitID=' + roundToUnit;
		}
	}

	var CapAt = txtDoseCap.value;	
	var CapAtToUnitID = lblDoseCapUnit.getAttribute('dbid');
	if (Number(CapAt) > 0){																									//07Apr05 AE  Added rounding support
		strURL += '&CapAt=' + CapAt
				  + '&CapAtUnitID=' + CapAtToUnitID;
	}

	//Show it
	var newDose = window.showModalDialog(strURL, '', CalculationFormFeatures())
	if (newDose == 'logoutFromActivityTimeout') {
		newDose = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	
	//If we've changed it, reload the page to force a recalculation of the dose.								//26Mar07 AE  Use reload method to cascade changes through ordersets.
	if (newDose!=null && newDose != 'cancel') window.parent.Reload(MESSAGE_RECALCULATING);
}


function ShowCalculationHistoryPending(lngPendingItemID) {

	//Load the dose calculation dialog
	var strURL = '../../DSS/DoseCalculationHistory.aspx'
				  + '?SessionID=' + formBody.getAttribute('sid')
				  + '&RequestID=' + 0
				  + '&PendingItemID=' + lngPendingItemID
				  + '&Type=Standard';
				  
	var ret= window.showModalDialog(strURL, '', CalculationFormFeatures());
	if (ret == 'logoutFromActivityTimeout') {
		ret = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}


//=======================================================================================================================
function ShowCalculationHistory(blnDoseWasCalculated, lngRequestID)
{
var intCount = new Number();
var astrDose = new Array();
var astrItem = new Array();

	//Load the dose calculation dialog
	var strURL = '../../DSS/DoseCalculationHistory.aspx'
				  + '?SessionID=' + formBody.getAttribute('sid')
				  + '&RequestID=' + lngRequestID
				  + '&ProductID=' + lblDrugName.getAttribute('productid')
				  + '&Type=Standard';
	
	var ret = window.showModalDialog(strURL, '', CalculationFormFeatures());
	if (ret == 'logoutFromActivityTimeout') {
		ret = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}

//=======================================================================================================================
function RoundDoseInfusion(objSrc, strDirection)
{

    //	Rounds the dose up or down to the next available size, 
    //	based on the product sizes we have in the db.
    //
    //	This assumes that the increments are returned in ASCENDING order
    //		doseControl:		control holding the dose value in its value field
    //		strDirection:		'up'|'down'
    var nextNode = new Object();
    var smallestNode = new Object();

    var intDivisions = new Number();
    var intCount = new Number();

    var difference = new Number();
    var differenceSmallest = Infinity;
    var incrementSmallest = new Number();
    var permittedDoseLowest = new Number();
    var permittedDoseHighest = new Number();
    var objRow = GetTRFromChild(objSrc);
    
    //Get the dose currently in the text box.
    //Ensure that the "to" dose starts from the "from" dose.
    var enteredDose = objRow.all['txtDose'].value;
    permittedDoseLowest = 0;
    permittedDoseHighest = Infinity;

    if (enteredDose == undefined || enteredDose == '' || enteredDose == 0) enteredDose = permittedDoseLowest;

    var thisDose = Number(enteredDose);

    // 01Dec03 PH Extra IF added below to default incrementation/decrementation to 1
    if (objRow.all['lstUnits'].selectedIndex >= 0)
    {
        var thisUnit = objRow.all['lstUnits'].options[objRow.all['lstUnits'].selectedIndex].innerText;

        //Get a reference to the Node in the XML document for this unit
        var unitsNode = unitsData.XMLDocument.selectSingleNode('units/unit[@description="' + thisUnit + '"]');
        var colIncrements = unitsNode.selectNodes('increment')

        //And off we go...	
        //Divide by each increment
        for (intCount = 0; intCount < colIncrements.length; intCount++)
        {
            nextNode = colIncrements[intCount];
            var thisIncrement = Number(nextNode.getAttribute('value'));

            //Divide by this increment and take the int() of the result.
            intDivisions = Math.round(thisDose * 100000 / thisIncrement) / 100000;      //Added rounding to 5 dp to combat issues with floating point numbers
            intDivisions = Number(intDivisions.toString().split('.')[0]); 			   //Does the same as vb's INT, only much less pleasant...
            //Now measure the step from here to the next dose up or down; we are looking for the 
            //smallest difference
            if (strDirection == 'up')
            {
                difference = thisDose - ((intDivisions + 1) * thisIncrement);
            }
            else
            {
                difference = thisDose - (intDivisions * thisIncrement);
            }
            difference = Math.round(difference * 100000) / 100000;      //Added rounding to 5 dp to combat issues with floating point numbers

            //Store this if it is the smallest difference so far.
            if (Math.abs(difference) < Math.abs(differenceSmallest))
            {
                differenceSmallest = Math.abs(difference);
                incrementSmallest = thisIncrement;
            }
        }

        //Now add or subtract the increment with the smallest difference.
        //In the case of increment which divide exactly, the difference will be zero.
        //In this case, add/subtract 1 whole increment
        if (differenceSmallest == 0) differenceSmallest = incrementSmallest;
        if (strDirection == 'up')
        {
            enteredDose = thisDose + Number(differenceSmallest);
        }
        else
        {
            enteredDose = thisDose - Number(differenceSmallest);
        }
    }
    else
    {
        //No unit information, just default to increment/decrement by one.
        if (strDirection == 'up')
        {
            enteredDose++;
        }
        else
        {
            enteredDose--;
        }
    }

    //Final bounds check
    if (enteredDose <= permittedDoseLowest)
    {
        enteredDose = permittedDoseLowest;
    }
    if (enteredDose > permittedDoseHighest)
    {
        enteredDose = permittedDoseHighest;
    }

    //Enter the new dose into the text box
    objRow.all['txtDose'].value = (Math.round(enteredDose * 100) / 100).toString();

    DescriptionChangeRequired();  // Call to change description for bug fix F0023374

    DisplayDoseDifference(objSrc);
}


//=======================================================================================================================
function RoundDose(doseControl, strDirection) {

//	Rounds the dose up or down to the next available size, 
//	based on the product sizes we have in the db.
//
//	This assumes that the increments are returned in ASCENDING order
//		doseControl:		control holding the dose value in its value field
//		strDirection:		'up'|'down'
var nextNode = new Object();
var smallestNode = new Object();

var intDivisions = new Number();
var intCount = new Number();

var difference = new Number();
var differenceSmallest = Infinity;
var incrementSmallest = new Number();
var permittedDoseLowest = new Number();
var permittedDoseHighest = new Number();

	//Get the dose currently in the text box.
	//Ensure that the "to" dose starts from the "from" dose.
	var enteredDose = doseControl.value;
	switch (doseControl.id) {																												//06Oct04 AE  Added some linking logic between the from/to boxes
		case 'txtDoseQty':
			permittedDoseLowest = 0;
			permittedDoseHighest = txtDoseQty2.value;
			if (permittedDoseHighest == '') permittedDoseHighest = Infinity;
			break;
			
		case 'txtDoseQty2':
			permittedDoseLowest = txtDoseQty.value
			permittedDoseHighest = Infinity;
			break;


        case 'txtDose':
            permittedDoseLowest = 0;
            permittedDoseHighest = Infinity;
            isIngredient = true;
            break;
	}		

	if (enteredDose == undefined || enteredDose == '' || enteredDose == 0) enteredDose = permittedDoseLowest;

	var thisDose = Number(enteredDose);

	// 01Dec03 PH Extra IF added below to default incrementation/decrementation to 1
	if (lstUnits.selectedIndex >= 0){
		var thisUnit = lstUnits.options[lstUnits.selectedIndex].innerText;
	
		//Get a reference to the Node in the XML document for this unit
		var unitsNode = unitsData.XMLDocument.selectSingleNode('units/unit[@description="' + thisUnit + '"]');
		var colIncrements = unitsNode.selectNodes('increment')

		//And off we go...	
		//Divide by each increment
		for (intCount = 0; intCount < colIncrements.length ; intCount++) {
			nextNode = colIncrements[intCount];				
			var thisIncrement = Number(nextNode.getAttribute('value'));
	
			//Divide by this increment and take the int() of the result.
			intDivisions = Math.round(thisDose * 100000 / thisIncrement) / 100000 ;      //Added rounding to 5 dp to combat issues with floating point numbers
			intDivisions = Number(intDivisions.toString().split('.')[0]);				//Does the same as vb's INT, only much less pleasant...
			//Now measure the step from here to the next dose up or down; we are looking for the 
			//smallest difference
			if (strDirection == 'up') {		
				difference = thisDose - ((intDivisions + 1) * thisIncrement);
			}
			else {
				difference = thisDose - ((intDivisions) * thisIncrement);				
			}
            difference = Math.round(difference * 100000) / 100000;      //Added rounding to 5 dp to combat issues with floating point numbers
			
			//Store this if it is the smallest difference so far.
			if (Math.abs(difference) < Math.abs(differenceSmallest)) {
					differenceSmallest = Math.abs(difference);
					incrementSmallest = thisIncrement;
			}
		}

		//Now add or subtract the increment with the smallest difference.
		//In the case of increment which divide exactly, the difference will be zero.
		//In this case, add/subtract 1 whole increment
		if (differenceSmallest == 0) differenceSmallest = incrementSmallest;
		if (strDirection == 'up') {
			enteredDose = thisDose + Number(differenceSmallest);
		}
		else {
			enteredDose = thisDose - Number(differenceSmallest);
		}
	}	
	else	{
	//No unit information, just default to increment/decrement by one.
		if (strDirection == 'up'){
			enteredDose++;
		}
		else{
			enteredDose--;
		}
	}

//Final bounds check
	if (enteredDose <= permittedDoseLowest) {
		enteredDose = permittedDoseLowest;
	}
	if (enteredDose > permittedDoseHighest) {
		enteredDose = permittedDoseHighest;
	}
	
//Enter the new dose into the text box
    doseControl.value = (Math.round(enteredDose * 100) / 100).toString();

	DescriptionChangeRequired();  // Call to change description for bug fix F0023374
	
	DisplayDoseDifference(doseControl);
}

//=======================================================================================================================

function ChangeDuration(intAddition) {
 
//Change the figure in the duration box by the value
//in intAddition

	var thisValue = eval(txtDuration.value);
	if (isNaN(thisValue)) {thisValue=0;}
	thisValue += intAddition;
	if (thisValue < 0) {thisValue=0;}
	txtDuration.value = thisValue;
	
	void UpdateStopDate();

 DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}


//=======================================================================================================================
function ChangeReviewDate(intAddition) {

// Change the figure in the review days box by the value
// in intAddition

	var thisValue = eval(txtReviewDate.value);
	if(isNaN(thisValue)) {thisValue=0;}
	thisValue += intAddition;
	if(thisValue < 0) {thisValue=0;}
	txtReviewDate.value = thisValue;

     DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}

//=======================================================================================================================
function SignalDateChange(){

//Fires when the start date is changed; we must inform the container, orderentry,
//of the change so that if we are in an order set, it can syncronise the
//start dates of any items which follow on from this one.

	//ShuffleStartTimes uses explicit dd/mm/yyyy hh:nn format, so convert the date
	//into that form.
	var objDateControl = new DateControl(txtStartDate);

	if (objDateControl.ContainsValidDate())
	{
		var objDate = objDateControl.GetDate();
		if (txtStartTime.value.length != 5)
		{
			txtStartTime.value = '00:00';
		}
		var strDDMMYYYY = Date2DDMMYYYY(objDate) + ' ' + txtStartTime.value; 						//25Mar05 AE  Fixed "strTime is undefined"
		var blnImmediate = (lstSchedule.options[lstSchedule.selectedIndex].value == 'immediate');
		void window.parent.ShuffleStartTimes(strDDMMYYYY, blnImmediate);
	}
	
	 DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}

//=======================================================================================================================
function StartDateOnFocus()
{
	m_CurrentStartDate = txtStartDate.value;
}

//=======================================================================================================================
function StartDateLostFocus()
{
	var objDateControl = new DateControl(txtStartDate);
	if (objDateControl.ContainsValidDate() && m_CurrentStartDate != txtStartDate.value)
	{
		// 12Oct08 PH Fix to set Rx start time based upon date selection
		var objDate = objDateControl.GetDate();
		UpdateRxStartTime(objDate);
		SignalDateChange();
	}
}

//=======================================================================================================================
function StartTimeOnFocus()
{
	m_CurrentStartTime = txtStartTime.value;
}

//=======================================================================================================================
function StartTimeLostFocus()
{
	if (m_CurrentStartTime != txtStartTime.value)
	{
		SignalDateChange();
	}
}

//=======================================================================================================================
//								Duration / stop date syncronisation
//=======================================================================================================================

function MonthView_Selected(controlID) {
//06Sep04 AE  Added 
	switch(controlID) {
		case 'txtStopDate':
			void UpdateDuration();	
			break;
			
		case 'txtStartDate':
			void UpdateStopDate();
			void StartDateLostFocus();
			break;
	}
	
	void ValidityCheck();

    DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}
//=======================================================================================================================
function UpdateReviewDate()
{
var intMultiply = new Number();
var blnChanged = false;
var strDate;
var dtToday;

	var intDuration = Number(txtReviewDate.value);
	var objStartDate = new DateControl(txtStartDate);
	//var objStopDate = new DateControl(txtStopDate);

	if (txtReviewDate.value != '')
	{
		var dtStart = objStartDate.GetDate();

		if (dtStart != null) 
		{		
			//Determine the duration;
				
			if (lstReviewUnits.selectedIndex > -1 && lstReviewUnits.options[lstReviewUnits.selectedIndex].getAttribute('dbid') != '0') 
			{
				var strUnit = lstReviewUnits.options[lstReviewUnits.selectedIndex].getAttribute('value');

				//Convert from the given units into milliseconds.
				switch (strUnit.toLowerCase()) 
				{
					case 'days':
						intMultiply = 86400000;
						break;
						
					case 'weeks':
						intMultiply = 604800000;
						break;
				}
				intDuration = intDuration * intMultiply;
				//Now add the stop date to the duration
				//combine date and time F0041959

				// F0042459  ST 07Jan09
				// Removed the code from F0041959 as it was producing NAN for the time and failing on committing.
				// Updated code to get a new date and simply use the time element from that to return with the review date.
                var dateNow = new Date();

                var intStopDateMS = Date.parse(dtStart) + intDuration;
				var dtStopDate = new Date(intStopDateMS);

                var strYear = dtStopDate.getYear().toString();
                var strMonth = (dtStopDate.getMonth()+1).toString();
                var strDay = dtStopDate.getDate().toString();
                var strHour = dateNow.getHours().toString();
                var strMinute = dateNow.getMinutes().toString();
                var strSecond = dateNow.getSeconds().toString();

                if (strMonth.length==1) { strMonth = "0" + strMonth; }
                if (strDay.length==1) { strDay = "0" + strDay; }
                if (strHour.length==1) { strHour = "0" + strHour; }
                if (strMinute.length==1) { strMinute = "0" + strMinute; }
                if (strSecond.length==1) { strSecond = "0" + strSecond; }
	
                return strYear + "-" + strMonth + "-" + strDay + "T" + strHour + ":" + strMinute + ":" + strSecond;
            }
		}
	}

    DescriptionChangeRequired ();  // Call to change description for bug fix F0023374

	return('');
}
//=======================================================================================================================

function UpdateStopDate()
{

	//Update the stop date based on the value of the start date field
	//Needs some serious work to cope with various date formats etc.
	//27Aug04 AE  Restructured a little to cope with empty duration unit
	var intMultiply = new Number();
	var blnChanged = false;
	var intDuration = Number(txtDuration.value);
	var objStartDate = new DateControl(txtStartDate);
	var objStopDate = new DateControl(txtStopDate);
	var strUnit = '';

	if (lstDurationUnits.selectedIndex > -1 && lstDurationUnits.options[lstDurationUnits.selectedIndex].getAttribute('dbid') != '0')
	{
		strUnit = lstDurationUnits.options[lstDurationUnits.selectedIndex].getAttribute('abbreviation');
	}

	//F0046700
	//26Feb09 JM 
	//if (strUnit != 'dose' && strUnit != ''){
	if (strUnit.toLowerCase() != 'dose' && strUnit != '')
	{
		trStopDate.style.visibility = 'visible';
		if (!m_blnTemplateMode)
		{
			if (txtDuration.value != '')
			{
				var dtStart = objStartDate.GetDate();
				var strStartTime = txtStartTime.value;
				var intStartTime = (Number(strStartTime.substr(0, 2)) * 3600000) + Number(strStartTime.substr(3, 2)) * 60000;
				if (dtStart != null)
				{
					//Determine the duration;

					//Convert from the given units into milliseconds.
					switch (strUnit.toLowerCase())
					{
						case 'sec':
							intMultiply = 1000;
							break;
						case 'min':
							intMultiply = 60000;
							break;
						case 'hour':
							intMultiply = 3600000;
							break;
						case 'day':
							intMultiply = 86400000;
							break;
						case 'wk':
							intMultiply = 604800000;
							break;
					}
					intDuration = intDuration * intMultiply;

					//Now add the durationto the start date
					var intStopDateMS = Date.parse(dtStart) + intStartTime + intDuration;
					var dtStopDate = new Date(intStopDateMS);

					objStopDate.SetDate(dtStopDate);
					blnChanged = true;
				}
			}
		}
	}
	else
	{
		//If duration is specified in a number of doses, hide the stop date controls.	
		trStopDate.style.visibility = 'hidden';
	}

	DescriptionChangeRequired();  // Call to change description for bug fix F0023374

	if (!blnChanged)
	{																								//27Aug04 AE  Restructured
		objStopDate.Blank();
	}
}
//=======================================================================================================================

function UpdateDuration() {

//When the stop date is changed, update the duration controls.	
var intCount = new Number();
var strUnit = new String();
var intDivide = new Number();
var intRemainder = new Number();

	var objStart = new DateControl(txtStartDate);
	var objStop = new DateControl(txtStopDate);
	
	//If either date is not valid, just blank the duration controls
	if (!objStart.ContainsValidDate() || !objStop.ContainsValidDate()){
		txtDuration.value = ''
		lstDurationUnits.selectedIndex = 0;
	}
	else {
		//Otherwise, update the duration to reflect the time between the start/stop date
		//Start at the biggest unit, and try each one until we find one where the duration will
		//fit in whole units.
		var dtStart = objStart.GetDate();
		var dtStop = objStop.GetDate();
		var intDurationSeconds = DateDiff(dtStart, dtStop, 's', false);

		for (intCount = (lstDurationUnits.options.length - 1); intCount > 0; intCount --) {
			strUnit = lstDurationUnits.options[intCount].getAttribute('abbreviation');
			
			switch (strUnit.toLowerCase()) {
				case 'sec':
					intDivide = 1;
					break;
				
				case 'min':
					intDivide = 60;
					break;
				
				case 'hr':
					intDivide = 3600;
					break;
				
				case 'day':
					intDivide = 86400;
					break;
				
				case 'wk':
					intDivide = 604800;
					break;
			}
			
			//See if our duration will fit exactly into this unit (so whole days, hours etc)
			intRemainder = (intDurationSeconds / intDivide) - Math.floor(intDurationSeconds / intDivide)
			if (intRemainder == 0) {
			//If so, update the screen and stop looking
				txtDuration.value = (intDurationSeconds / intDivide);
				lstDurationUnits.selectedIndex = intCount;
				break;
			}
		}
	}	
	
	DescriptionChangeRequired ();	
}
//=======================================================================================================================
function DateValidityCheck(inputControl){

//Checks that the specified control contains a valid date, or nothing
	var blnValid = true;
	var objDate = new DateControl(inputControl);
	if (!objDate.IsBlank() && !objDate.ContainsValidDate()) blnValid = false;
	
	return blnValid;
}

//=======================================================================================================================
function DateRangeValid(){
//Check that the start/stop date are valid
	
	var objStart = new DateControl(txtStartDate);
	var objStop = new DateControl(txtStopDate);
	var blnReturn = true;
	
	if (objStart.ContainsValidDate() && objStop.ContainsValidDate()){
		var dtStart = objStart.GetDate();
		var dtStop = objStop.GetDate();	
		
		if (DateDiff(dtStart, dtStop, 's', false) < 0) {
			blnReturn = false;
		}
	}
	return blnReturn
}

//=======================================================================================================================
function DurationValidityCheck() {
//Check that the duration is filled in properly.
    //22May06 AE  Added function #SC-06-0541
    //F0095792 JMei 07Sep2010 duration value and unit must both have value or both blank
    if (document.all['lstDurationUnits'] != undefined && lstDurationUnits.selectedIndex >= -1) {
        var blnHaveUnit;
        if (lstDurationUnits.selectedIndex == -1) {
            blnHaveUnit = false
        } else {
            blnHaveUnit = (Number(lstDurationUnits.options[lstDurationUnits.selectedIndex].getAttribute('dbid')) > 0);
        }
             
		var blnHaveValue = (txtDuration.value != '' && Number(txtDuration.value) > 0) ;																				//19Sep06 AE  Added check for 0 days #SC-06-0541								
		if (blnHaveUnit ^ blnHaveValue){														// ^ = XOR
			tdDurationWarning.innerText = 'You must enter a duration ' + (blnHaveUnit ? 'value' : 'unit') + ', or leave both duration boxes blank.';
			tdDurationWarning.style.display = 'block';
			return false;
		}
		else {
			tdDurationWarning.style.display = 'none';
		}
	}
		
	return true;

}
//=======================================================================================================================
//25Feb08 ST - Added to validate the min/max infusion duration range and prevent saving if there is an error
function InfusionDurationValidityCheck()
{

    var intMin;
    var intMax;
    
    if(document.all['lstInfusionDuration'] != undefined && lstInfusionDuration.options[lstInfusionDuration.selectedIndex].innerText == 'Infusion Over')
    {
        // If we've entered a start but the end is blank than just return true.
        if(txtInfusionDuration.value != "" && txtInfusionDuration2.value == "")
        {
            return true;
        }
        
        intMin = Number(txtInfusionDuration.value);
        intMax = Number(txtInfusionDuration2.value);
        
        if(intMin > intMax)
        {
            tdInfusionDurationWarning.innerText = 'The second duration must be larger than the first';
            tdInfusionDurationWarning.style.display = 'block';
            return false;
        }
        else
        {
            tdInfusionDurationWarning.style.display = 'none';
        }
    }
        
    return true;
}

//=======================================================================================================================
function ReviewValidityCheck() {

    // check the review details are correct

    if (document.getElementById("txtReviewDate") != undefined)
    {
        if (document.all['lstReviewUnits'] != undefined && lstReviewUnits.selectedIndex > -1)
        {
            var blnHaveUnit = (Number(lstReviewUnits.options[lstReviewUnits.selectedIndex].getAttribute('dbid')) > 0);
            var blnHaveValue = (txtReviewDate.value != '' && Number(txtReviewDate.value) > 0);

            tdReviewWarning.style.display = 'none';

            if (blnHaveUnit == true && blnHaveValue == false)
            {

                tdReviewWarning.innerText = 'You must specify how many ' + lstReviewUnits.options[lstReviewUnits.selectedIndex].value + ', or leave both boxes blank';
                tdReviewWarning.style.display = 'block';
                return false;
            }

            if (blnHaveUnit == false && blnHaveValue == true)
            {
                tdReviewWarning.innerText = 'You must enter a time unit, or leave boxes blank.';
                tdReviewWarning.style.display = 'block';
                return false;
            }
        }

        var blnShowReviewIn = txtReviewDate.getAttribute('nowrite');
        if (blnShowReviewIn == 1)
        {
            if (blnHaveUnit == false || blnHaveValue == false)
            {
                tdReviewWarning.innerText = 'You must enter a time unit.';
                tdReviewWarning.style.display = 'block';
                return false;
            }
        }


        if (Number(txtDuration.value) > 0 && Number(txtReviewDate.value) > 0)
        {

            if (lstDurationUnits.options[lstDurationUnits.selectedIndex].innerText == 'days' && lstReviewUnits.options[lstReviewUnits.selectedIndex].innerText == 'days')
            {
                if (Number(txtReviewDate.value) > Number(txtDuration.value))
                {
                    tdReviewWarning.innerText = 'The review must occur before the end date of the prescription.';
                    tdReviewWarning.style.display = 'block';
                    return false;
                }
            }

            if (lstDurationUnits.options[lstDurationUnits.selectedIndex].innerText == 'weeks' && lstReviewUnits.options[lstReviewUnits.selectedIndex].innerText == 'weeks')
            {
                if (Number(txtReviewDate.value) > Number(txtDuration.value))
                {
                    tdReviewWarning.innerText = 'The review must occur before the end date of the prescription.';
                    tdReviewWarning.style.display = 'block';
                    return false;
                }
            }
        }
    }

	
	return true;
}

//=======================================================================================================================
function DoseRangeValid() {

//Checks that the "from" dose is smaller than the "to" dose
//04Oct04 AE

	if ((txtDoseQty2.value != '') && (txtDoseQty2.value != '')) {
		dose2 = txtDoseQty2.value;
		if (dose2 == '')dose2 = 0;
		dose2 = Number(dose2);
		dose1 = Number(txtDoseQty.value);
		DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
		return ((dose1 < dose2) || (dose2 == 0));
	}
	else {
    	DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
	    return true;
	}
}

//=======================================================================================================================
function DoseCapValidatityCheck()
{
	var dblDoseCap = parseFloat(txtDoseCap.getAttribute("DoseCap_Converted"));
	var strDoseCapUnit = txtDoseCap.getAttribute("DoseCapUnitName_Converted");
	var dblDose = parseFloat(txtDoseQty.value);
	var dblDose2 = parseFloat(txtDoseQty2.value);
	var blnCapOverridable = (lnkDoseCapOverridable.getAttribute("override")=="1")
	
	if (dblDoseCap > 0 && !blnCapOverridable)
	{
		if (dblDoseCap > 0)
		{
			// Checks that the dose(s) have not exceed the cap.
			if ( dblDose > dblDoseCap )
			{
				var strMsg = "The dose cannot exceed " + dblDoseCap + " " + strDoseCapUnit + ".";
				alert(strMsg);
				return false;
			}
			if ( dblDose2 > dblDoseCap )
			{
				var strMsg = "The 'To Dose' cannot exceed " + dblDoseCap + " " + strDoseCapUnit + ".";
				alert(strMsg);
				return false;
			}
		}
	}
	
	DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
	return true;
}

//=======================================================================================================================
function RouteValid() {

//We do two checks here; firstly, that the route is a licenced / approved one;
//and secondly, to ensure that if a route with subroutes was selected, one of
//the subroutes has been chosen (so if the template's route is EAR, the 
//user must pick left, right, both, affected etc).

var blnApproved = false;
var blnValid = true;

//Check that the route is approved
	if (typeof(document.all['tdRouteWarning']) != 'undefined') {

	    if (lstRoute.options[lstRoute.selectedIndex].value != 'empty') {
			var routeID = lstRoute.options[lstRoute.selectedIndex].getAttribute('dbid');
			var objRoute = routesData.XMLDocument.selectSingleNode('Routes//ProductRoute[@ProductRouteID="' + routeID +  '"]');
		
			if (objRoute != undefined) {		
				//Check if this route is approved for this product
				blnApproved = (objRoute.getAttribute('Approved') == '1');
		
				if (!blnApproved) {
				//Also check if the parent route is approved for this product (so if EAR is approved, LEFT EAR must also be).			
					if (objRoute.parentNode.nodeName == 'ProductRoute') {
						blnApproved = (objRoute.parentNode.getAttribute('Approved') == '1');	
					}	
				}
				if (!blnApproved) tdRouteWarning.innerText = '(Route Not Approved)';
			}
			else {
			//No route, but don't show the warning
				blnApproved = true;
			}
		
		//Check that the route has no subroutes
			if (objRoute!=null && objRoute.selectNodes('ProductRoute').length > 0) {	// 02Nov04 PH Check if objRoute is null before trying to read it
			//It does, so they must select one of the subroutes
				if (!m_blnTemplateMode){
				//Unless it is in template mode																										//12Apr05 AE 
					blnValid = false;
					tdRouteWarning.innerText = 'You must select which ' + objRoute.getAttribute('Description');
				}
			}
		
		//Show the warning if required
			tdRouteWarning.style.display = GetDisplayString(!blnApproved || !blnValid);
		}
		else {
			tdRouteWarning.innerText = 'You must select a route.';
			blnValid = false;																																//16Nov05 AE 
		}
		tdRouteWarning.style.display = GetDisplayString(!blnValid);
	}		
	
	DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
	return blnValid;
	
}

//=======================================================================================================================
//									Route selection 
//=======================================================================================================================
function RouteChange(){

//Fires when a new route is selected	
var i = 0;
var numOptions = 0;
var formID_temp = 0;
var objOption;
var colOptions;
var DOM;
var objHTTPRequest;
	
	switch (lstRoute.options[lstRoute.selectedIndex].value){
	    case 'empty':
	        //F0095825 ST 09Sep10 If we've selected an empty option i.e. ------------- then just select the blank entry.
	        lstRoute.selectedIndex = 0;
			//Just a spacer
			break;
			
		case 'all':
			//Load all the routes
			void PopulateRouteFromXML();
			break;
			
		default:
			var routeID = lstRoute.options[lstRoute.selectedIndex].getAttribute('dbid');
			var objRoute = routesData.XMLDocument.selectSingleNode('Routes//ProductRoute[@ProductRouteID="' + routeID +  '"]');
			if (objRoute != undefined) {
				blnTopical =  (objRoute.getAttribute('Topical') == '1');
				blnInfusion  = (objRoute.getAttribute('Infusion') == '1');
				strDescription = objRoute.getAttribute('Description')
			}
			
			if (document.all['lstForm'] != undefined){																											//14Nov06 AE  Added restriction of avaialble forms by route #DR-05-013
			//If we're on a chemical template, load the appropriate product forms for this route.	
				//Store the current form
				if (lstForm.selectedIndex > -1) formID_temp = lstForm.options[lstForm.selectedIndex].getAttribute('dbid');					
				
				//Reload with list of appropriate forms using a server request
				strURL = 'PrescriptionLoader.aspx?SessionID=' + document.body.getAttribute('sid')	
						 + '&Mode=formbyroute&ProductID=' + lblDrugName.getAttribute('productid') + '&RouteID=' + routeID;

				var objHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");								//Create the object
				objHTTPRequest.open("GET", strURL, false);													//false = syncronously
				objHTTPRequest.send();																				//Send the request syncronously
			
				DOM = new ActiveXObject('MSXML2.DOMDocument');
				DOM.loadXML('<root>' + objHTTPRequest.responseText + '</root>');
				colOptions = DOM.selectNodes('root/option');
				lstForm.innerHTML = '';

				for (i=0; i<colOptions.length; i++){
					objOption = document.createElement('OPTION');
					objOption.text = colOptions[i].text;
					objOption.setAttribute('dbid', colOptions[i].getAttribute('dbid'));
					lstForm.add(objOption);		
				}
				
				lstForm.selectedIndex = 0;
				void SetListItemByDBID(lstForm, formID_temp);
			}																																									//14Nov06 AE  End #DR-05-013
			
			
			//Check if this is an approved route
			void RouteValid();
			
			//If it's a topical route, show the "doseless" controls.		
//			if (!blnInfusion) void ShowDoselessControls(blnTopical)// || blnDoseless);																	//28Apr06 AE  Removed.  Doseless template must now be chosen manually.
	}	
    DescriptionChangeRequired ();  // Call to change description for bug fix F0023374	
}
//=======================================================================================================================
function PopulateRouteFromXML() {


var blnWaitForLoad = false;
var colRoutes = new Object();
var xmlRoute = new Object();
var intCount = new Number();
var lngSelectedRouteID = 0;
var bitInfusion = 0;
var intNumOptions = 0;
var colRoutes;
var objOption;
var strForm = '';

	//Check if we have, and/or need, all routes
	var blnAllRoutesLoaded = (routesData.getAttribute('allloaded') == '1' );

	//Show all routes, we may need to load them from the server
	if (!blnAllRoutesLoaded) {
		//We do have to load the data.  Start the async load, 
		//and wait for it to complete
		formBody.style.cursor = 'wait';
		void routesData.setAttribute('loading', '1');
		var strURL = 'PrescriptionLoader.aspx'
					  + '?SessionID=' + formBody.getAttribute('sid')
					  + '&ProductID=' + lblDrugName.getAttribute('productid')
					  + '&Mode=allroutes';
					  
		//Depending on our mode, we want to show:
		//All non-infusion and non-topical routes
		//Infusion Routes only
		//Doseless Routes only			  			
		//Routes marked as (Doseless & Infusion)
		if (document.body.getAttribute('requesttype') == REQUESTTYPE_INFUSION){
			strURL += '&Infusion=true' ;				
		}
		if ((document.body.getAttribute('requesttype') == REQUESTTYPE_DOSELESS)){
			strURL += '&Topical=true' ;				
		}
		if (m_blnTemplateMode) strURL += '&Standard=true;'
		routesData.src = strURL;
		blnWaitForLoad = true;		
	}
	
	//Default x path on the routes xml document; by default we show all routes in the document
	//(which may only be a subset of all the routes in the database!
	strXPath = 'Routes/ProductRoute';

	if (!blnWaitForLoad) {
		//If we are in template mode, we want to only allow selection of parent routes (such as "ear")
		if (m_blnTemplateMode){
			strXPath = 'Routes/ProductRoute';
		}		
		else {
		//Not in template mode, don't show routes with children. (so they can pick "left ear", but not "ear")
			strXPath = 'Routes//ProductRoute[not (ProductRoute)]';
		}
		//Now fill in the combo
		//Out with the old...
		intNumOptions = lstRoute.options.length;
		for (i = 0; i < intNumOptions; i++){
			lstRoute.options.remove(0);
		}
		
		//...And in with the new
		colRoutes = routesData.XMLDocument.selectNodes(strXPath);
		for (i = 0; i < colRoutes.length; i++){
			objOption = document.createElement('OPTION');
			lstRoute.options.add(objOption);
			void objOption.setAttribute('dbid', colRoutes[i].getAttribute('ProductRouteID'));
			objOption.innerText = colRoutes[i].getAttribute('Description');
		}
	}
}
//=======================================================================================================================

function ShowInfusionForm(routeID, routeDescription) {

//Display the infusion custom control rather than the standard prescription one

//Update the prescription metadata to point at the infusion data type
	var xmlElement = UpdatePrescriptionMetadata(REQUESTTYPE_INFUSION);
	var strURL = document.URL;
	var strQuerystring = strURL.substring(strURL.indexOf('?') + 1,strURL.length);
	
	var strQuerystring = QuerystringReplace(strQuerystring, 'tableid', xmlElement.getAttribute('TableID'));
	strQuerystring = QuerystringReplace(strQuerystring, 'ask', 'false');

//Refresh the page, specifying the TableID of the PrescriptionInfusion table.
	strURL = 'Prescription.aspx' 
			 + '?' + strQuerystring
			 + '&RouteID=' + routeID
			 + '&RouteText=' + routeDescription;

	void window.navigate(strURL);			
}
//=======================================================================================================================
function ShowDoselessForm(){

//Display the doseless form, rather than the infusion one.  Not the same as ShowDoselessControls!
	
//Update the prescription metadata to point at the infusion data type
	var xmlElement = UpdatePrescriptionMetadata(REQUESTTYPE_DOSELESS);
	var strURL = document.URL;
	var strQuerystring = strURL.substring(strURL.indexOf('?') + 1,strURL.length);

	var strQuerystring = QuerystringReplace(strQuerystring, 'tableid', xmlElement.getAttribute('TableID'));
	strQuerystring = QuerystringReplace(strQuerystring, 'ask', 'false');

//Refresh the page, specifying the TableID of the PrescriptionInfusion table.
	strURL = 'Prescription.aspx' 
			 + '?' + strQuerystring;

	void window.navigate(strURL);
}

//=======================================================================================================================

function CheckRoutesLoaded() {
//Fires as the routes data island is loading.  When it's loaded,
//we display the routes list

	if (routesData.readyState == 'complete') {
		if (routesData.getAttribute('loading') == '1') {
			formBody.style.cursor = 'default';
			void routesData.setAttribute('allloaded', '1');
			void routesData.setAttribute('loading', '0');	
//			void SelectRoute(true);
			void PopulateRouteFromXML();
		}
	}	
	
}

//=======================================================================================================================
//								Frequency Selection
//=======================================================================================================================

function SelectFrequency(objButton) {

	if (objButton.getAttribute('noevents') == '1') return;

	//Load the data if it isn't already loaded
	if (frequencyData.getAttribute('allloaded') != '1') {
		var strURL = 'PrescriptionLoader.aspx'
				  + '?SessionID=' + formBody.getAttribute('sid')
				  + '&Mode=frequency';
		formBody.style.cursor = 'wait';
		void frequencyData.setAttribute('loading', '1');
		frequencyData.src = strURL
		
	}
	else {
		//We already have the data, just show it in the picker
		//Create a new pick list object
		var m_objPicker = new ICWPickList('Frequency', objButton, EnterFrequency);

		//Add standard items to the top of the list
//		m_objPicker.AddRow (FQID_ADVANCED, true, 0, '', MNUTXT_ADVANCED);									//01Apr05 AE  Removed button to fix P1.  No really.
		m_objPicker.AddRow (FQID_PRN, true, 0, '', MNUTXT_PRN);
		m_objPicker.AddRow (FQID_STAT, true, 0, '', MNUTXT_STAT);

		//Populate it using the schedule XML
		var objFrequency = frequencyData.XMLDocument.selectSingleNode('root');
		void m_objPicker.PopulateFromXMLNode(objFrequency, 'ScheduleTemplate');

		//And display it
		void m_objPicker.Show(cmdPickFreq.offsetWidth, 0, 300, 400);
	}
	
	DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}

//=======================================================================================================================
//								Frequency Selection
//=======================================================================================================================
function PopulateReviewRequestFromXML() {

    
var blnWaitForLoad = false;
var colRoutes = new Object();
var xmlRoute = new Object();
var intCount = new Number();
var lngSelectedRouteID = 0;
var bitInfusion = 0;
var intNumOptions = 0;
var colRoutes;
var objOption;
var strForm = '';

	//Check if we have, and/or need, all routes
	var blnAllRequestsLoaded = (reviewrequestData.getAttribute('allloaded') == '1' );

	if (!blnAllRequestsLoaded) {
		//We do have to load the data.  Start the async load, 
		//and wait for it to complete
		formBody.style.cursor = 'wait';
		void blnAllRequestsLoaded.setAttribute('loading', '1');
		var strURL = 'PrescriptionLoader.aspx'
					  + '?SessionID=' + formBody.getAttribute('sid')
					  + '&Mode=requesttypes';
					  
//		if (m_blnTemplateMode) strURL += '&Standard=true;'
		reviewrequestData.src = strURL;
		blnWaitForLoad = true;		
	}

	DescriptionChangeRequired ();  // Call to change description for bug fix F0023374	
}

//=======================================================================================================================

function EditAdvancedFrequency() {

//Event Handler called from the cmdPickFreqLong button.
//Launches the advanced frequency editor, skipping the picklist.
	void EnterFrequency(FQID_ADVANCED, '');
	DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}
//=======================================================================================================================

function CheckFreqLoaded() {

//Fires as the frequency data island is loading data asyncronously	
//Show the frequency picker when it's all loaded

	if (frequencyData.readyState == 'complete') {
		if (frequencyData.getAttribute('loading') == '1') {
			formBody.style.cursor = 'default';
			void frequencyData.setAttribute('loading', '0');
			void frequencyData.setAttribute('allloaded', '1');
			void SelectFrequency(cmdPickFreq);
		}
	}
	
	DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}

//=======================================================================================================================
function CheckRevReqLoaded() {

//Fires as the reviewrequest data island is loading data asyncronously	
//Show the reviewrequest picker when it's all loaded
	if(reviewrequestData.readyState == 'complete') 
	{	    
		if(reviewrequestData.getAttribute('loading') == '1') 
		{
			formBody.style.cursor = 'default';
			void reviewrequestData.setAttribute('loading', '0');
			void reviewrequestData.setAttribute('alloaded', '1');
			void PopulateReviewRequestFromXML();
		}		
	}
}



//=======================================================================================================================
function FrequencyChange(){

    //24May06 AE  Added handling for NoDoseInfo to all cases. #DR-06-0250
    if (document.all['lstFrequency'] == undefined) return;

    FrequencySelected(); // for incident f0037338
	
	//19Jan06 AE  lstFrequency doesn't exist on rate based infusions	
	
	var blnDoseless = (document.body.getAttribute('requesttype') == REQUESTTYPE_DOSELESS);
	switch (lstFrequency.options[lstFrequency.selectedIndex].value) {
		case 'prn':
		//If they've chosen PRN, hide the duration controls and 
		//PRN check box
			chkStat.checked = false;
			chkPRN.checked = true;
			chkNoDoseInfo.checked = false;
			void ShowStatControls(false);	
			void ShowPRNControls(false);
			tdFrequencyWarning.style.display='none';
			break;
			
	
		case 'stat':
		//If they've chosen the STAT item, hide the duration controls and
		//stop date, and change the StartDate label. Also udpdate the hidden
		//stat checkbox.
			chkStat.checked = true;
			chkPRN.checked = false;
			chkNoDoseInfo.checked = false;
			void ShowPRNControls(false);
			void ShowStatControls(true);
			tdFrequencyWarning.style.display='none';
			// 12Jul04 Added in Immediate and StartTime values here that weren't being updated.
			switch (GetValueFromXML('STAT_Immediate')) {
				case '1':																														//26Mar05 AE  Move away from true/false litterals to 1/0
				case 'true':
					lstSchedule.selectedIndex = 0;
					break;
				
				case null:
				//Drop through to clause below
				
				case '':
					lstSchedule.selectedIndex = 0;
					break;
				
				case 'false':	
					lstSchedule.selectedIndex = 1;
					break;
			}
			
			//We fill in the start time if we're doing a scheduled stat, OR if we're in 
			//display mode (as you still want to see the time an "Immediate" STAT was made once
			//it's been committed)
			if ((lstSchedule.options[lstSchedule.selectedIndex].value == 'schedule') || DisplayMode()) {
			    txtStartTime.value = GetValueFromXML('StartTime');

			    // F0035966
			    if (txtStartTime.value == "" && !DisplayMode())
			    {
			        var strTimeNow = Date2TDate(new Date());
			        txtStartTime.value = strTimeNow.substr(11, 5);
			    }
			}
			void ToggleStartDate();
			break;
		
		case 'nodoseinfo':
			if (blnDoseless){
				chkNoDoseInfo.checked = true;
				tdFrequencyWarning.style.display='block';
				void ShowStatControls(false);	
				void ShowPRNControls(false);
			}
			else {
				lstFrequency.selectedIndex = 0;
			}
			break;
				
		case 'blank':
			lstFrequency.selectedIndex = 0;			
			break;
		
		default:
			chkStat.checked = false;
			chkPRN.checked = false;
			chkNoDoseInfo.checked = false;
			void ShowStatControls(false);	
			void ShowPRNControls(true);
			tdFrequencyWarning.style.display = 'none';
			break;			
	}
	ShowDoseControls();	
	DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}
//=======================================================================================================================
function ShowStatControls(blnVisible) {
 
//Re-arranges the form to display the STAT dosing options.
	trStartDate.style.visibility = GetVisibilityString(blnVisible || (lstSchedule.options[lstSchedule.selectedIndex].value != 'immediate'));
	tdStartTime.style.visibility = GetVisibilityString(blnVisible || (lstSchedule.options[lstSchedule.selectedIndex].value != 'immediate'));
	tdStartTimeLabel.style.visibility = GetVisibilityString(blnVisible || (lstSchedule.options[lstSchedule.selectedIndex].value != 'immediate'));
	
	trDuration.style.visibility = GetVisibilityString(!blnVisible);
	trStopDate.style.visibility = GetVisibilityString(!blnVisible);
	
	//Change the text in the drop down;
	if (blnVisible) {
		lstSchedule.options[0].innerText = 'Immediately';
		lstSchedule.options[1].innerText = 'Choose Time';
		
		//blank the duration box                        															//23Mar05 AE  prevent description building bug #77522
		txtDuration.value = '';																								
		lstDurationUnits.selectedIndex = -1;																			//14Mar07 AE  Clear units box as well, to prevent the validation thinking that the duration is half filled-in. Fixes #SC-07-0180
	}
	else {
		lstSchedule.options[0].innerText = 'Today';
		lstSchedule.options[1].innerText = 'Choose Date';
	}

	UpdateDurationMandatory(blnVisible);
}
//=======================================================================================================================

// F0069701 - 01Mar2010 CD Update the duration mandatoryness depending on whether a single dose is selected or not
function UpdateDurationMandatory(isSingleDose) {
    if (!m_blnTemplateMode) {
        if (originalDurationMandatory == undefined) {
            originalDurationMandatory = GetMandatoryStatusFromXML('Duration');
        }

        if (isSingleDose) {
            SetMandatoryStatus('Duration', false);
        }
        else {
            SetMandatoryStatus('Duration', originalDurationMandatory == 1 ? true : false);
        }
    }
}


//=======================================================================================================================

function AdvancedScheduleToForm(strFrequency_XML) {
/*
//Enter the schedule specified in strFrequency_XML onto the form as
//an advanced/ad-hoc schedule.
	advancedFrequencyData.loadXML(strFrequency_XML);
	objSchedule = advancedFrequencyData.XMLDocument.selectSingleNode('root/Schedule');
	txtFreq.innerText = '[Advanced]';																			//This should never be seen, it's a "just in case"
	void txtFreq.setAttribute('dbid', 0);
	txtFreqLong.setAttribute('title', objSchedule.getAttribute('Description'));					//This is the long text box used for display
	txtFreqLong.innerText = objSchedule.getAttribute('Description')
	
	//Ensure that we syncronise the start and stop date fields; although now
	//hidden, we will still be saving them.
	var objStartDate = new DateControl(txtStartDate);
	var objStopDate = new DateControl(txtStopDate);

	//Obtain the start/end dates from the scheduler. 
	objStartDate.SetTDate(objSchedule.getAttribute('StartDate'));
	objStopDate.SetTDate(objSchedule.getAttribute('EndDate'));

	void ShowLongFrequencyControls(true);
*/
}

//=======================================================================================================================
//								Stat / PRN / Avanced Frequency Controls
//=======================================================================================================================

function ShowLongFrequencyControls(blnVisible) {

//Re-arranges the form when an advanced shchedule has been chosen.
//Because the description of these tends to be long, we hide the ordinary
//frequency box and replace it with a larger multiline box.
//Duration, start and stop date controls are hidden

	trFrequencyLong.style.display = GetDisplayString(blnVisible);
	trFrequencyNormal.style.display = GetDisplayString(!blnVisible);
	
	trDuration.style.visibility = GetVisibilityString(!blnVisible);
	trStopDate.style.visibility = GetVisibilityString(!blnVisible);
	trStartDate.style.visibility = GetVisibilityString(!blnVisible);
	trSchedule.style.visibility = GetVisibilityString(!blnVisible);
}

//=======================================================================================================================
//'doses' selected as the time unit, hide stop date
function ShowDoseControls()
{
	//trStopDate.style.visibility = GetVisibilityString(!blnVisible);
    if (lstDurationUnits.selectedIndex > -1 && lstDurationUnits.options[lstDurationUnits.selectedIndex].getAttribute('dbid') != '0')
    {
	    var strUnit = lstDurationUnits.options[lstDurationUnits.selectedIndex].getAttribute('abbreviation');
	    switch (strUnit.toLowerCase())
	    {
	        case 'dose':
            	 trStopDate.style.visibility = GetVisibilityString(false);
	             break;
	        default:
	             trStopDate.style.visibility = GetVisibilityString(true);
	             break;
	    }
	}
}
//=======================================================================================================================

function ShowPRNControls(blnVisible) {
	
//Re-arranges the form to display the PRN Dosing options.
//The PRN box is shown or hidden according to the value of blnVisible
	if (document.all['chkPRN'] != undefined) {
		tdPRN.style.visibility = GetVisibilityString(blnVisible);
        ScriptDurationList(blnVisible); //refrersh the duration list contents
	}

}

//17-Jan-2008 JA Error code 162
//=======================================================================================================================
function ScriptDurationList(blnIncludeDurationByDoses)
{

//27Feb07 AE  Moved here from PrescriptionCommon.  Replace ActiveXObject with use of xml data island.
//12Mar07 AE  Script in the correct list box, and make the removal/addition work properly. #SC-07-0125
//21Mar07 AE  And more...don't add the "doses" item if it already exists #SC-07-0212
	var blnInfusion = (document.body.getAttribute('requesttype') == REQUESTTYPE_INFUSION);
	
    if(!blnIncludeDurationByDoses)   //remove the 'dose' option if present
    {
        lstLength = lstDurationUnits.options.length; 
        for(i = 0;i < lstLength;i++)
        {
            if(lstDurationUnits.options[i].text == "doses") //find the "doses" option
            {
                lstDurationUnits.removeChild (lstDurationUnits.options[i]);
            }
        }

        // F0078428 ST 26Feb10 Updated to only blank the duration if its an immediate dose.
        if (lstFrequency.options[lstFrequency.selectedIndex].value == "stat") {
            txtDuration.value = ''; 									//Also blank the text box
        }
    }
    else    //add the 'dose' option if its not already present	
	{
		// don't add dose option if its a rate based infusion
		if (document.all['lstFrequency'] == undefined && blnInfusion)
		{
			return;
		}
		else
		{
			var xmlUnit = unitDoseData.XMLDocument.selectSingleNode('root/Unit');
			var blnExists = false;
			for (i=0;i<lstDurationUnits.options.length;i++){
				if (lstDurationUnits.options[i].getAttribute('abbreviation') == xmlUnit.getAttribute('Abbreviation')){
					blnExists = true;
					break;
				}	
			}
			if (!blnExists){
				var objOption = document.createElement('OPTION');	
				lstDurationUnits.options.add(objOption);																					//12Mar07 AE  Corrected; add to the duration units list, not the Routes list.
				objOption.setAttribute('dbid', xmlUnit.getAttribute('UnitID'));	
				objOption.innerText = xmlUnit.getAttribute('Description').toLowerCase() + 's';								//12Mar07 AE  Corrected; this must match the tetxt searched for in the If above!
				objOption.setAttribute('abbreviation', xmlUnit.getAttribute('Abbreviation'));
			}
		}
	}		
}


//=======================================================================================================================

function ToggleStartDate(objDate)
{
	//Called when the "today/choose time" drop down is changed.Enables/disables
	//the Start date/time boxes as appropriate.
	blnImmediate = (lstSchedule.options[lstSchedule.selectedIndex].value == 'immediate');
	trStartDate.style.visibility = GetVisibilityString(!blnImmediate);

	if (!DisplayMode())
	{
		//Edit mode, we only show the start time box if this is an dose scheduled for later.
		tdStartTime.style.visibility = GetVisibilityString(!blnImmediate);
	}
	else
	{
		//In display mode, we show the start time even if Immediate was chosen, this will show the
		//time the prescription was actually approved.
		tdStartTime.style.visibility = GetVisibilityString(true);
	}
	tdStartTimeLabel.style.visibility = tdStartTime.style.visibility;

	//Populate the Start Time box if appropriate
	if (blnImmediate)
	{
		var strTimeNow = Date2TDate(new Date());
		txtStartTime.value = strTimeNow.substr(11, 5);
	}
	if (!m_blnTemplateMode)
	{
		var objDateControl = new DateControl(txtStartDate);
		if (objDateControl.GetDate() == null || blnImmediate)
		{
			var dtNow = new Date();
			if (objDate != undefined)
			{
				dtNow = objDate
			}
			objDateControl.SetDate(dtNow);
			UpdateStopDate();
		}
	}
	DescriptionChangeRequired();  // Call to change description for bug fix F0023374
}
//=======================================================================================================================
function ShowDoselessControls(blnShow){

    //Shows or hides the "doseless" controls, if they are on the page
	//If it has been manually been set to doseless using the link at the top of the page, then that
	//overrides everything else.
	if (document.all['lnkDoseless'] != undefined && lnkDoseless.getAttribute('override') == '1') return;
	
	//Otherwise, set the controls as specified.
	if (typeof(document.all['trDose']) != 'undefined') {
		trDose.style.display = GetDisplayString(!blnShow);
		trDose2.style.display = GetDisplayString(!blnShow);
		trExtra.style.display = GetDisplayString(!blnShow);
		trDoseless.style.display = GetDisplayString(blnShow);
		if (document.all['lnkDoseless'] != undefined) lnkDoseless.style.display = GetDisplayString(!blnShow);					//11Jan06 AE  Added manual "convert to doseless" option
		
		//Also clear the dose boxes
		if (blnShow) {
			txtDoseQty.value = '';
			txtDoseQty2.value = ''
			lstRoutine.selectedIndex = 0;
			
			//Add the special "associated bumpf" frequency item
			if (lstFrequency.options[3].value != 'nodoseinfo'){																				//16Aug06 AE  #SC-06-0666. <maiden>Fix, Fix Fix, the number of the beast </maiden> .Only add the option if it isn't there already.
				var objOption = document.createElement('OPTION');
				lstFrequency.options.add(objOption, INDEX_NODOSEINFO);
				objOption.value='nodoseinfo';
				objOption.setAttribute('dbid', -100);
				objOption.innerText = '(See Accompanying Paperwork)';
			}
		}
				
		//Mark that this is now a doseless type prescription.  
		if (blnShow) {
			void formBody.setAttribute('requesttype', REQUESTTYPE_DOSELESS);
		}
		else {
			void formBody.setAttribute('requesttype', REQUESTTYPE_STANDARD);
		}
	
		//And mark the arbtext xml as not loaded, so it will be refreshed if the
		//text picker is used.
		void arbtextData.setAttribute('allloaded', '0');	
	}
	
}

//=======================================================================================================================
//								ArbText Selection
//=======================================================================================================================

function SelectText(objButton, objTextBox) {

//Select some text using the arbitrary text picker

//objButton:				Button we want to position the pop-up by
//objTextBox:				Text box where the selected text goes
//blnReplaceExisting:	If true, existing text in the text box is replaced; if false,
//								it is appended.

	//Store the text box & button references
	if (objButton.getAttribute('noevents') == '1') return;

	m_objTextBox = objTextBox;
	m_objPickerButton = objButton;

	//Load the data if it isn't already loaded
	if (arbtextData.getAttribute('allloaded') != '1') {
		var strURL = 'PrescriptionLoader.aspx'
					  + '?SessionID=' + formBody.getAttribute('sid')
					  + '&Mode=arbtext'
					  + '&Form=' + GetProductForm();																										//04Mar05 AE  now uses GetProductForm()
		formBody.style.cursor = 'wait';
		void arbtextData.setAttribute('loading', '1');	
		arbtextData.src = strURL
	}
	else {
		//We already have the data, just show it in the picker
		void ShowArbTextPicker(arbtextData, 'Direction');
		arbtextData.setAttribute('allloaded', 0)
	}
}

//=======================================================================================================================
function ClearText(objTextBox){
//Clear the text and id from objTextBox
//27Mar06 AE  objTextBox now might be a label... #SC-06-0190
	void SetTextBoxOrLabel(objTextBox, '');
	objTextBox.setAttribute('dbid', null);
	
}
//=======================================================================================================================
function SelectDispensingText(){

	//Store the textbox and button references
	if (cmdPickInstructions.getAttribute('noevents') == '1') return;	
	
	m_objTextBox = txtPharmacyDirections;
	m_objPickerButton = cmdPickInstructions;

	//Load the data if it isn't loaded already
	if (dispensingtextData.getAttribute('allloaded') != '1') {
		var strURL = 'PrescriptionLoader.aspx'
					  + '?SessionID=' + formBody.getAttribute('sid')
					  + '&Mode=arbtext'
					  + '&Type=dispensinginstruction'
					  + '&Form=' + GetProductForm();																									//04Mar05 AE  now uses GetProductForm()
		formBody.style.cursor = 'wait';
		void dispensingtextData.setAttribute('loading', '1');
		dispensingtextData.src = strURL
		
	}
	else {
		void ShowArbTextPicker(dispensingtextData, 'Dispensing Instruction');
		arbtextData.setAttribute('allloaded', 0)
	}
}
//=======================================================================================================================

function ShowArbTextPicker(XMLElement, strTitle){

	//Create a new pick list object
	var m_objPicker = new ICWPickList(strTitle, m_objPickerButton, EnterText);

	//Populate it using the text XML
	var objText = XMLElement.XMLDocument.selectSingleNode('root');
	void m_objPicker.PopulateFromXMLNode(objText, 'ArbText');

	//And display it
	void m_objPicker.Show(m_objPickerButton.offsetWidth, 0, 300, 400);			//01Sep04 AE  
	
}
//=======================================================================================================================

function CheckArbTextLoaded() {

//Fires off as the ArbText data island is loading asyncronously.
//Show the arb text picker when it's all loaded
	
	if (arbtextData.readyState == 'complete' && arbtextData.XMLDocument.xml != ''){
		if (arbtextData.getAttribute('loading') == '1') {
			formBody.style.cursor = 'default';
			void arbtextData.setAttribute('loading', '0');
			void arbtextData.setAttribute('allloaded', '1');
			void SelectText(m_objPickerButton, m_objTextBox);
		}
	}
}
//=======================================================================================================================

function CheckDispensingTextLoaded() {

//Fires off as the ArbText data island is loading asyncronously.
//Show the arb text picker when it's all loaded
	
	if (dispensingtextData.readyState == 'complete') {
		if (dispensingtextData.getAttribute('loading') == '1') {
			formBody.style.cursor = 'default';
			void dispensingtextData.setAttribute('loading', '0');
			void dispensingtextData.setAttribute('allloaded', '1');
			void SelectDispensingText();
		}
	}
}

//=======================================================================================================================

function EnterText(arbTextID, newText) {

//Fires when the user selects something from the arb text picker
//Replace text in the box
	SetTextBoxOrLabel(m_objTextBox, newText);
	
	//Now stores the arb text id as an attribute on the text box
	m_objTextBox.setAttribute('dbid', arbTextID);
	m_objPickerButton.focus();
	m_objPickerButton.setActive();

}
//=======================================================================================================================
function SetTextBoxOrLabel(objControl, strText){
//27Mar06 AE

	if (objControl.tagName.toLowerCase() == 'label'){
		objControl.innerText = strText;
	}
	else {
		objControl.value = strText;
	}	
}

function GetValueFromTextBoxOrLabel(objControl){

	if (objControl.tagName.toLowerCase() == 'label'){
		return objControl.innerText;
	}
	else {
		return objControl.value;
	}		
}

//=======================================================================================================================
//								Alternative Prescriptions
//=======================================================================================================================

function AddAlternativePrescription() {
	
//Allows the user to add a prescription which can be specified as an alternative	
	
}


//=======================================================================================================================
//								Internal Procedures
//=======================================================================================================================
//=======================================================================================================================

function PopulateForm(strData_XML)
{

//Now populate the form.
	switch (document.body.getAttribute('requesttype')) {
		case REQUESTTYPE_STANDARD:
			void PopulateForm_Standard();
			break;

		case REQUESTTYPE_DOSELESS:
			void PopulateForm_Standard();
			break;

		case REQUESTTYPE_INFUSION:
			void PopulateForm_Infusion();
			break;
	}
	
}

//=======================================================================================================================
function PopulateForm_Standard() {

//Populate the form with the specified XML
//
//strData_XML:			Data in the standard order entry format of <data><attribute .../></data>
//blnTemplateMode:	Set to true when creating a template, rather than an actual order.

    
var lngID = new Number();
var strText = new String();
var strXML = new String();
var doseLow = new Number(0);
var doseHigh = new Number(0);
var blnCopyMode = Number(lblDrugName.getAttribute("copying"));
var blnDataPopulated = false;

//Now populate the controls
	//Set the calculated dose flag.  When creating a new item from template, this will have been set server side.
	//When reloading a pending item that had a calculated dose in, the flag will have been saved in the XML
	if  (GetValueFromXML('CalculatedDose') != '') lblDrugName.setAttribute('iscalculateddose', GetValueFromXML('CalculatedDose'));

	var blnIsCalculatedDose = (lblDrugName.getAttribute('iscalculateddose') == 'true');
	var blnIsDoseless = (document.body.getAttribute('doseless') == 'true');
	var blnIsFromTemplate = (document.body.getAttribute('dataclass') == 'template');

	//Dose Quantity/Units.  This may have been calculated server-side, 
	//in which case it will already contain a value	
	doseHigh = Number(GetValueFromXML('Dose'));																											//04Sep06 AE  #SC-06-0685 Added Number() to prevent trailing zeros comming back from db
	doseLow = Number(GetValueFromXML('DoseLow'));

	// its we're copying a calculated dose rx then we use the data provided server side as it wont be in the xml here
    // ST 12Nov08 - F0038413
    if (blnCopyMode && blnIsCalculatedDose)
    {
        blnDataPopulated = true;
    }
    else
    {
	    if (!blnIsCalculatedDose || (blnIsCalculatedDose && !blnIsFromTemplate))
	    {
	        //Non-calculated doses, or when reloading a pending item, we need to populate the dose
	        //fields from the XML
	        if (doseLow > 0)
	        {																//09Jan04 AE  Added Dose ranges
	            //We have a range of doses
	            txtDoseQty.value = doseLow;
	            txtDoseQty2.value = doseHigh;

	            void SetReadonlyStatus(document.all['txtDoseQty2'], 'Dose')
	            void SetReadonlyStatus(document.all['txtDoseQty'], 'DoseLow')

	        }
	        else
	        {
	            //Just a single dose
	            txtDoseQty.value = doseHigh;
	            void SetReadonlyStatus(document.all['txtDoseQty'], 'Dose')
	            void SetReadonlyStatus(document.all['txtDoseQty2'], 'DoseLow')
	        }
	    }
	}

	if (blnIsCalculatedDose){
		if (!blnIsFromTemplate && !blnCopyMode){
		//Reloading a pending item with a calculated dose:
		//need to persist the calculation information
			lblDrugName.setAttribute('calculation_dose', GetValueFromXML('Calculation_Dose'));													//07Feb05 AE  Persist calculation information across saves to the pending tray.
			lblDrugName.setAttribute('calculation_doselow', GetValueFromXML('Calculation_DoseLow'));	
			lblDrugName.setAttribute('calculation_routinedescription', GetTextFromXML('Calculation_RoutineID'));
			lblDrugName.setAttribute('calculation_routineid', GetValueFromXML('Calculation_RoutineID'));
			lblDrugName.setAttribute('calculation_calculateddose', GetValueFromXML('Calculation_CalculatedDose'));	
			lblDrugName.setAttribute('calculation_calculateddoselow', GetValueFromXML('Calculation_CalculatedDoseLow'));	
		}	
		else {
		//When creating a new item from template:
		    //Dose fields already populated server-side.
		    if (!blnCopyMode)
		    {
		        lblDrugName.setAttribute('calculation_dose', doseHigh); 																					//07Feb05 AE  Persist calculation information across saves to the pending tray.
		        lblDrugName.setAttribute('calculation_doselow', doseLow);
		    }
		}
	}

	lngID = GetValueFromXML('Calculation_RoutineID');
	void SetListItemByDBID(lstRoutine, lngID);

	//Calculation Rounding Stuff; if not in template mode, this is populated server side as
	//we do the calculation.																																		//08Apr05 AE   Added calculation rounding
	var strDoseCap = GetValueFromXML(ATTR_DOSE_CAP);
	var strDoseRound = GetValueFromXML(ATTR_ROUND_INCREMENT);

	//F0056793 ST 02Jul09 No longer display the capping info via client side script when creating new items
	//Now done server side in prescription.vb
    if (!m_blnTemplateMode && !blnIsFromTemplate) {
	    if (Number(strDoseCap) > 0 && Number(strDoseRound) > 0)
	    {
	        strMsg = String(lblCalcWarning.innerText);
	        strMsg = strMsg.substr(0, strMsg.length - 1);

	        if (doseHigh < Number(strDoseCap)) {
	            // F0056793 ST 27Jul09
	            // If the dose is less than the capping value then the dose wasn't capped.
	            lblCalcWarning.innerText = strMsg + " (Value has been rounded)";
	        }
	        else
	        {
	            lblCalcWarning.innerText = strMsg + " (Value has been rounded and capped)";
            }
	    }
	    else
	    {
	        if (Number(strDoseCap) > 0)
	        {
	            strMsg = String(lblCalcWarning.innerText);
	            strMsg = strMsg.substr(0, strMsg.length - 1);
	            lblCalcWarning.innerText = strMsg + " (Value has been capped)";
	        }
	        if (Number(strDoseRound) > 0)
	        {
	            strMsg = String(lblCalcWarning.innerText);
	            strMsg = strMsg.substr(0, strMsg.length - 1);
	            lblCalcWarning.innerText = strMsg + " (Value has been rounded)";
	        }
	    }
	}

	if (m_blnTemplateMode && !blnIsDoseless) {
		txtRoundValue.value = GetValueFromXML(ATTR_ROUND_INCREMENT);
		lblRoundUnit.setAttribute('dbid', GetValueFromXML(ATTR_ROUND_UNIT));

		txtDoseCap.value = strDoseCap;
		lblRoundUnit.setAttribute('dbid', GetValueFromXML(ATTR_DOSE_CAP_UNIT));
		
		void UpdateRoundingLabel(lstUnits);
		void EnableRoundingControls(lstRoutine);
		void UpdateDoseOptionsLabel(lstRoutine);

		document.getElementById('lnkDoseCapOverridable').setAttribute('override',GetValueFromXML(ATTR_DOSE_CAP_CAN_OVERRIDE));
		
        //04Sep08 ST - added dose reduction options
        document.getElementById('lnkDoseReevaluate').setAttribute('override',GetValueFromXML(ATTR_DOSE_REEVALUATE));
		
		DoseCapOverrideSet(lnkDoseCapOverridable);
	}


	//Dose Units.  May be units (mg, ml), Forms (tablet, capsule), or in future packaging (kit, pack)
	//In the case of form/package, we'll only ever have a single entry in the list however. (A product cannot
	//have multiple forms or packaging)
	lngID = GetValueFromXML('UnitID_Dose');
	
	if (lngID == null) {lngID = 0};
	void SetListItem(lstUnits, lngID);

	//Product Form; this is the form required which can be specified on Chemical templates only.
	//It never clashes with the case when a form is specified in the Dosing Units box.
	if (document.all['lstForm'] != undefined){
		lngID = GetValueFromXML('ProductFormID_Dose');
        strText = GetTextFromXML('ProductFormID_Dose');			
        
        if (DisplayMode())        
        {
			var objOption = document.createElement('option')																															//11Nov05 AE  Quick fix for display mode
			objOption.innerText = strText;
			objOption.selected = true;
			void lstForm.appendChild (objOption);        
        }
        else
        {
		    if ( !SetListItem(lstForm, lngID) )
		        lstForm.selectedIndex = -1;
		    void SetReadonlyStatus(document.all['lstForm'], 'ProductFormID_Dose')																		//27Sep06 AE  Corrected field name.  Fixes #SC-06-0820 
        }
	}
	
	//DirectionText and coded text for doseless prescriptions
	// 02Feb06 PH Rem'd out to stop directions not loading properly
//	if (document.body.getAttribute('doseless') == 'true'){

		strText = GetValueFromXML('DirectionText');
		txtDirectionFree.value = strText;
		
		lngID = GetValueFromXML('ArbTextID_Direction');
		strText = GetTextFromXML('ArbTextID_Direction');
		void txtDirection.setAttribute('dbid', lngID);
		SetTextBoxOrLabel(txtDirection, strText);
		
//	}	

	
	//Now populate the shared parts
	void PopulateForm_Common();

	//Hide any unused fields if in display mode
	void HideEmptyFields_Standard();

}
	
//====================================================================================================================================
function PopulateForm_Common()
{
	var objDateControl;
	var strDate = new String();
	var dtRequest;
	var dtCreated;
	var dtNow = new Date();
	var strPRN = new String();
	var blnPRN = false;
	var blnNoDoseInfo = false;
	var lngID = new Number();
	var intValue = new Number();
	var strTime = "";
	var bitValue = 0;
	var strClassName;

	//Populate the shared parts of the form (startdate, stopdate etc)
	//Routes box
	lngID = GetValueFromXML('ProductRouteID');
	void SetListItemByDBID(document.all['lstRoute'], lngID);
	void SetReadonlyStatus(document.all['lstRoute'], 'ProductRouteID')

	if (document.all['lstRoute'] != undefined && document.all['lstRoute'].options[document.all['lstRoute'].selectedIndex].value == 'empty')
	{		//20Nov06 AE  Update the filledin states for routes with children #SC-06-0435
		//This will happen when a route with children (eg, "eye") is chosen on the template.  In this case we need
		//to update the "filled in" status to 0 until a child route is chosen.
		instanceData.XMLDocument.selectSingleNode('root/data').setAttribute('filledin', 'false');
	}

	//Start Date;
	objDateControl = new DateControl(txtStartDate);
	if (!m_blnTemplateMode)
	{
		strText = GetValueFromXML('StartDate');
	}
	else
	{
		strText = '';
	}
	
	//Immediate/Choose Date box
	lngID = GetValueFromXML('lstScheduleIndex'); 																			//05Oct04 AE  Corrected loading of the today/choose date section
	//Set the immediate/choose date option box to whatever it was, if we have a value for it.
	//(we wont have a value when viewing a committed request)
	if (DisplayMode())
	{
		//Display mode, just hide the box entirely
		lstSchedule.selectedIndex = 1;
		trSchedule.style.display = 'none';
		objDateControl.SetTDate(strText); // 01Nov04 PH Stop date being lost when viewing comitted prescriptions.
	}
	else
	{
		//Set the box to what it was before
		lstSchedule.selectedIndex = lngID;
		if (lstSchedule.options[lstSchedule.selectedIndex].value == 'immediate')
		{
			//If it's set to immediate, fill in today's date in the box, which is hidden
			//but used under the bonnet.
			objDateControl.SetDate(dtNow);
			// F0035966
			var strTimeNow = Date2TDate(new Date());
			txtStartTime.value = strTimeNow.substr(11, 5);
		}
		else
		{
			objDateControl.SetTDate(strText);
			if (m_blnTemplateMode)
			{
				strTime = '';
			}
			else
			{
				strTime = GetValueFromXML('StartTime');
				if (strTime == '')
				{
					var strTimeNow = Date2TDate(new Date());
					strTime = strTimeNow.substr(11, 5);
				}
			}
			txtStartTime.value = strTime;
		}
	}
	void ToggleStartDate();

	//Duration	
	ScriptDurationList(true); 																						//21Mar07 AE SC-07-0212
	intValue = GetValueFromXML('Duration');
	lngID = GetValueFromXML('UnitID_Duration');

	if (Number(intValue) > 0 && Number(lngID) > -1)
	{
		// 02Sep05 ST Listbox item ID was being passed to duration edit, 
		// changed to now pass the duration value.
		txtDuration.value = intValue; //lngID;
		void SetListItem(lstDurationUnits, lngID);
	}
	else
	{
		lstDurationUnits.selectedIndex = -1;
	}
	void SetReadonlyStatus(txtDuration, 'Duration');

	//Set the mandatory toggle
	bitValue = GetMandatoryStatusFromXML('Duration');
	void SetMandatoryIndicator(txtDuration, bitValue);


	//Stop Date: If they've specified one, use it; otherwise, 
	//calculate it based on the start date and duration (if any)
	objDateControl = new DateControl(txtStopDate);

	if (!m_blnTemplateMode)
	{
		strText = GetValueFromXML('StopDate');
	}
	else
	{
		strText = '';
	}

	if (strText != '')
	{
		objDateControl.SetTDate(strText);
	}
	else
	{
		//Create it from the stop date
		void UpdateStopDate();
	}

	//
	// If viewing a prescription back then the review details will have be created server side so no need to do it here
	//
	if (!DisplayMode())
	{
		PopulateReviewDetails();
	}

	//Supplimentary text 																														//19Jan06 AE  Should be included for doseless rx
	txtExtraFree.value = GetValueFromXML('SupplimentaryText'); 																//01Dec03 TH end block
	lngID = GetValueFromXML('ArbTextID_Direction');
	strText = GetTextFromXML('ArbTextID_Direction');
	void txtExtra.setAttribute('dbid', lngID);
	SetTextBoxOrLabel(txtExtra, strText);

	//Dispensing Instruction; this is held as a DispensingInstruction 
	//child element of the data element
	void PopulateDispensingInstruction();

	//Have we got any dose calculation data if so stick that in the xml island
	void PopulateDoseCalculationXML();

	//Template detail (Read-only instructions)
	void PopulateTemplateDetail();

	//PRN box
	strPRN = GetValueFromXML('PRN');
	blnPRN = (strPRN == 'true' || strPRN == '1'); 																																		//07Nov06 AE  Fix "PRN not being saved" #SC-06-1043.  This was broken by the change made for #SC-06-0588
	blnNoDoseInfo = (GetValueFromXML('NoDoseInfo') == '1');

	//Dose Frequency; not scripted for continuous infusions.
	if (typeof (document.all['lstFrequency']) != 'undefined')
	{
		chkNoDoseInfo.checked = blnNoDoseInfo;

		if (DisplayMode() || (document.body.getAttribute('dataclass') == 'request'))
		{
			//Displaying a committed prescription OR creating a copy of a commmitted prescription.  

			if (DisplayMode())
			{
				//We will have some different fields here, since schedule templates are replaced with real schedules, etc.													//11Mar05 AE  Added clause to include copies  05Aug04 AE  Added to retrieve scheduleID_administration for committed prescriptions
				lngID = GetValueFromXML('ScheduleID_Administration');
				strText = GetTextFromXML('ScheduleID_Administration');

				var objOption = document.createElement('option')																															//11Nov05 AE  Quick fix for display mode
				objOption.innerText = strText;
				objOption.selected = true;
				void lstFrequency.appendChild(objOption);

			}
			else
			{
				//Doing a copy																																												//12Apr05 AE  Now returns the template for copies
				lngID = GetValueFromXML('ScheduleTemplateID');
				strText = GetTextFromXML('ScheduleTemplateID');
			}

			if (Number(lngID) == 0)
			{
				//Indicates a PRN, STAT, or frequencyless; set text appropriately, since all we'll
				//have here is the description of schedule 0.
				if (blnPRN)
				{																																											//07Nov06 AE  Fix "PRN not being saved" #SC-06-1043.  This was broken by the change made for #SC-06-0588
					lstFrequency.selectedIndex = INDEX_PRN;
				}
				if (chkNoDoseInfo.checked)
				{																																						//24May06 AE  Added case for NoDoseInfo #DJ-06-0079
					lstFrequency.selectedIndex = INDEX_NODOSEINFO;
				}
				if (!blnPRN && !chkNoDoseInfo.checked)
				{																																		//07Nov06 AE  Fix "PRN not being saved" #SC-06-1043.  This was broken by the change made for #SC-06-0588
					//Stat; may have been immediate, or scheduled.  We determine this
					//by comparing the created date and request date.
					strDate = GetValueFromXML('CreatedDate');
					dtCreated = TDate2Date(strDate);
					strDate = GetValueFromXML('StartDate');
					dtRequest = TDate2Date(strDate);
					if (Date.parse(dtCreated) == Date.parse(dtRequest))
					{
						//Was prescribed for Immediate use, so select the immediate option button
						//and blank the start date
						lstSchedule.selectedIndex = 0;
						if (!DisplayMode())
						{
							objDateControl = new DateControl(txtStartDate);
							objDateControl.Blank();
						}
					}
					else
					{
						//Scheduled STAT.
						lstSchedule.selectedIndex = 1;
					}
					lstFrequency.selectedIndex = INDEX_STAT;
				}
			}
			else
			{
				//Standard schedules from templates ('Daily, Twice a day, etc)
				void SetListItemByDBID(lstFrequency, lngID);
			}
		}
		else
		{
			//This prescription is still being edited; we are dealing with a ScheduleTemplateID	
			lngID = GetValueFromXML('ScheduleTemplateID');
			strText = GetTextFromXML('ScheduleTemplateID');
			//This may be 0; in that case it indicates either an Advanced schedule
			//has been created, or they've selected the PRN schedule, OR
			//none has genuinely been selected.)	
			if (chkNoDoseInfo.checked)
			{																																							//24May06 AE  Added case for NoDoseInfo #DJ-06-0079
				lstFrequency.selectedIndex = INDEX_NODOSEINFO;
			}
			else
			{
				if (blnPRN && (Number(lngID) <= 0))
				{																							//07Nov06 AE  Fix "PRN not being saved" #SC-06-1043.  This was broken by the change made for #SC-06-0588
					//Indicates an "as required" prescription with no schedule.
					//void EnterFrequency(FQID_PRN, strText);
					lstFrequency.selectedIndex = INDEX_PRN;
				}
				else
				{
					if (Number(lngID) != 0)
					{
						//This is a normal schedule template
						//void EnterFrequency(lngID, strText);	
						void SetListItemByDBID(lstFrequency, lngID);
					}
					else
					{
						//Whereas this is an ad-hoc schedule - 28Nov03 TH or maybe a STAT ?
						if (GetValueFromXML('STAT') == '1')																						//28Nov03 TH Added clause to retain the stat if default (PH changed compare from 'true' to '1')
						{
							//void EnterFrequency(FQID_STAT, strText);																		//04Feb05 AE  Removed code which set start date as this is already done above
							lstFrequency.selectedIndex = INDEX_STAT;
						}
						else
						{
							strXML = GetValueFromXML('Schedule_AdHoc');
							if (strXML != '')
							{																										//10Dec03 AE  May not have one, may be genuinely empty.
								void AdvancedScheduleToForm(strXML);
							}
						}
					}
				}
			}
		}
		if (document.body.getAttribute('dataclass') == 'request')
		{
			void SetReadonlyStatus(document.all['lstFrequency'], 'ScheduleID_Administration');
		}
		else
		{
			void SetReadonlyStatus(document.all['lstFrequency'], 'ScheduleTemplateID');
		}
	}
	void FrequencyChange()
	if (document.all['chkPRN'] != undefined) chkPRN.checked = blnPRN; 																////07Nov06 AE  Fix "PRN not being saved" #SC-06-1043.  This was broken by the change made for #SC-06-0588  02Aug06 AE  #SC-06-0588 Moved below FrequencyChange() as this clears the prn flag 
	//15Dec05 AE  Make sure controls are updated. 
	void ShowDoselessControls(document.body.getAttribute('doseless') == 'true');
	//In display mode, we hide fields that were not filled in
	void HideEmptyFields_Common();

	//Show the changes report
	void ShowChangeReport();

	UpdateStopDate();
}

//====================================================================================================================================
function HideEmptyFields_Standard(){

	if (DisplayMode()){
	//Hide second dose if not entered.
	//Note that this may already be hidden if in doseless mode.
		if (txtDoseQty2.value == '') 	{trDose2.style.visibility = 'hidden'};		
	}
}

//====================================================================================================================================
function HideEmptyFields_Common(){

//In display mode, we hide fields which were left blank for clarity.

	if (DisplayMode()){
	//Hide the choose start date/time box and just show the start date & stop date if any
		trStartDate.style.visibility = 'visible';	
		trSchedule.style.visibility = 'hidden';
	
	//Hide stop date and duration if not specified
		if (trim(txtStopDate.value) == '') trStopDate.style.visibility = 'hidden';
		if (txtDuration.value == '') trDuration.style.visibility = 'hidden';

	//Extra text and dispensing instruction fields
		if (trim(txtExtraFree.value) == '' && trim(txtExtra.value) == '') {																								//18Aug06 AE  Fix #SC-06-0664 as well 27Jul06 AE  Fix  #SC-06-0612
			trExtra.style.visibility = 'hidden';
		}
		if (trim(txtPharmacyDirections.value) == '') {
			trPharmacyDirections.style.visibility = 'hidden';
		}
	}		
}

//====================================================================================================================================
function HideEmptyFields_Infusion(){

var intCount = 0;
var intTd = 0;
var objRow;

	if (DisplayMode()){
		if (typeof(document.all['chkVaryRate']) != 'undefined') {
			//Hide the "vary rate" boxes if not used
			trRateVary.style.display = GetDisplayString(chkVaryRate.checked);
		}
		if (typeof(document.all['chkVaryDose']) != 'undefined'){
			//Hide the "vary dose" boxes if not used	
			trVary.style.display = GetDisplayString(chkVaryDose.checked);
		}

		//Hide any unused boxes on the ingredient listing.
		//loop through rows in the table
		for (intCount=1;intCount < tblIngredients.rows.length; intCount++){	
		//Get a reference to this row and the corresponding product element in the xml
			objRow = tblIngredients.rows[intCount];
			if ((typeof(objRow.all['txtDose']) != 'undefined')){
				if (objRow.all['txtDose'].value == ''){
					for (intTD = 0; intTD < objRow.all['tdDose'].length; intTD ++){
						objRow.all['tdDose'][intTD].style.visibility = 'hidden';	
					}
				}
			}
		}
	}
}
//====================================================================================================================================
function SetReadonlyStatus(objControl, strColumnName){
//When not in display mode (when everything is read-only anyway),
//for the given control, checks whether it is marked as being a read-only field.
//If so, in template mode we update the read only control image, in edit mode
//we make the control read-only.
//09Aug05 AE  Implemented read-only controls in prescribing
	if (!DisplayMode()){
		var bitReadOnly = GetReadonlyStatusFromXML(strColumnName);
		if (isNaN(bitReadOnly))
		{
			bitReadOnly = null
		}

		if (m_blnTemplateMode){
			var objImage = objControl.parentElement.parentElement.all['imgReadOnly'];
			if (objImage != null ){
			void TemplateFieldReadOnlySet(objImage, bitReadOnly);}
		}
		else {
			objControl.setAttribute(ATTR_READONLY, bitReadOnly);															//03Oct06 AE Persist read only fields through the pending tray #SC-06-0797 

			if (bitReadOnly == 1){
				//Set the control to be read-only
				objControl.disabled = true;
				
				//Special cases, (which is everything I think).
				switch (objControl.id){						
					case 'txtDoseQty':
					//Need to make read-only the buttons, units box etc.
						objControl.parentElement.parentElement.all['cmdDecDose'].disabled = true;
						objControl.parentElement.parentElement.all['cmdIncDose'].disabled = true;
						trDose.all['lstUnits'].disabled = true;
						//tdDoseUnits.all['lstUnits'].disabled = true;
						break;
				
					case 'txtDoseQty2':
					//Hide this box if it's read only and empty, and disable the buttons
						if (Number(objControl.value) == 0) trDose2.style.visibility = 'hidden'
						break;
												
					case 'txtDuration':
					//Disable the units box and buttons
						cmdDecDuration.disabled = true;
						cmdIncDuration.disabled = true;
						lstDurationUnits.disabled = true;
						txtStopDate.disabled = true;
						txtStopDate.parentElement.all['imgCalendar'].disabled = true;
						break;
						
					case 'lstInfusionDurationUnits':
					//Disable the "give as" box, plus the duration text boxes
						lstInfusionDuration.disabled = true;
						txtInfusionDuration.disabled = true;
						txtInfusionDuration2.disabled = true;
						break;

				}
			}
		}		
	}

}

//====================================================================================================================================
function ToggleMandatoryIndicator(objControl){

	var bitMandatory = objControl.getAttribute('mandatory');
	if (bitMandatory == null) bitMandatory = 0;
	bitMandatory = (Number(bitMandatory) == 1 ? 0 : 1);
	SetMandatoryIndicator (objControl, bitMandatory);

}

//====================================================================================================================================
function SetMandatoryIndicator(objControl, bitMandatory){

    //Toggle a mandatory indicator (as seen in template mode) on or off

    
	bitMandatory = Number(bitMandatory);
	if (m_blnTemplateMode){
		var objIndicator = objControl.parentElement.parentElement.all['lnkMandatory'];
	
		if (bitMandatory == 1){
			objIndicator.innerHTML = '(mandatory)';
			objIndicator.title = 'This field will be MANDATORY; click to make it optional';
		}
		else {
			objIndicator.innerHTML = '(optional)';
			objIndicator.title = 'This field will be OPTIONAL; click to make it mandatory';
		}
	}
	
//Set the control's class appropriately
	var strClassName = (bitMandatory == 1) ? 'MandatoryField' :  'StandardField';
	switch (objControl.id){
		case 'txtDuration':
			txtDuration.className = strClassName;
			lstDurationUnits.className = strClassName;
			break;
	
		default:
			objControl.className = strClassName;
	}

	void objControl.setAttribute('mandatory', bitMandatory);
}

//====================================================================================================================================
function GetReadOnlyAttribute(objControl){

//Returns the xml attribute "readonly='1'" if the specified control is marked as readonly
	var strReturn = '';	
	if (m_blnTemplateMode){
		var objImage = objControl.parentElement.parentElement.all['imgReadOnly'];
		if (objImage != undefined){
			strReturn = 'readonly="' + objImage.getAttribute(ATTR_READONLY) + '" ';
		}
	}
	else {
		strReturn = 'readonly="' + objControl.getAttribute(ATTR_READONLY) + '" ';									//03Oct06 AE Persist read only fields through the pending tray #SC-06-0797 
	}
		
	return strReturn;
}

//====================================================================================================================================
function ReviewDetails(){

	if (document.all['lstReviewType'] == undefined) return;																		//19Jan06 AE  lstFrequency doesn't exist on rate based infusions	
	
	if(lstReviewType.options[lstReviewType.selectedIndex].getAttribute('dbid') == '-1')
	{
		txtReviewDate.className = 'Disabled';
		txtReviewDate.disabled = true;
		txtReviewDate.value = '';
		
		lstReviewUnits.className = 'Disabled';
		lstReviewUnits.selectedIndex = 0;
		lstReviewUnits.disabled = true;
		
		lstReviewDate.className = 'Disabled';
		lstReviewDate.disabled = true;
		
		cmdDecReview.disabled = true;
		cmdIncReview.disabled = true;
	}
	else
	{
		txtReviewDate.className = 'MandatoryField';
		txtReviewDate.disabled = false;
		
		lstReviewUnits.className = 'MandatoryField';
		lstReviewUnits.disabled = false;
		
		lstReviewDate.className = 'MandatoryField';
		lstReviewDate.disabled = false;
		
		cmdDecReview.disabled = false;
		cmdIncReview.disabled = false;
	}
}

//====================================================================================================================================
function SetListItem(objSelect, lngID) {
//Handles list boxes; sets the given list box to display the item with the given dbid.
//If only one item is in the list, OR we're in display mode, we hide the list box
//and show an ordinary, non-editable field instead.
//Would prefer to do this on the server, but we only know the item we're displaying in
//the list box on the client.
//Returns if found the item with ID lngID
//13Sep04 AE  Written.

var bFound = false;

    if(objSelect != null)
    {
	    var blnChange = ((objSelect.options.length == 1) || DisplayMode() );
    	
	    //Set the item in the list box
	    bFound = SetListItemByDBID(objSelect, lngID);
    	
	    //Now replace the list box with a standard field if appropriate. The list box still exists, 
	    //so that the code only has to deal with one way of working.
	    if (blnChange)
	    {
	    	var label = objSelect.parentNode.all["label_replacer"];
	    	if (typeof(label) == "undefined")
			{
				var intWidth = objSelect.offsetWidth;
				objSelect.style.display = 'none';
				var objLabel = objSelect.parentNode.appendChild(document.createElement('label'));
				if (objSelect.selectedIndex != -1) {
				    objLabel.innerText = objSelect.options[objSelect.selectedIndex].innerText;				
				}				
				objLabel.className = 'StandardField';
				objLabel.style.width = intWidth;
				objLabel.id = "label_replacer";
			}
			else
			{
				label.innerText = objSelect.innerText;
	    	}
	    }
	}
	
	return bFound;
}

//====================================================================================================================================
function FilledIn_PrescriptionStandard() {

//Return true if all of the mandatory fields on this
    //page are filled in.
var blnComplete = true;
var lngRouteID = new Number();
	
	//Drug
	if (lblDrugName.value == '') blnComplete = false;
		
	//Standard Prescriptions
	if (document.body.getAttribute('requesttype') != REQUESTTYPE_DOSELESS) {
		if (txtDoseQty.value == '') {
			blnComplete = false;
		}
		else {
			blnComplete = (Number(txtDoseQty.value) > 0);																			//04Oct04 AE  Prevent dose of "0"
		}
		if (lstUnits.selectedIndex == -1) {blnComplete = false;}	
	}
	else {
		if (trim(GetValueFromTextBoxOrLabel(txtDirection)) == ''){blnComplete = false;}
	}

	//if (lstFrequency.selectedIndex <= 0) blnComplete = false;

	if (!FrequencySelected()) {
	    blnComplete = false
	}

	return (blnComplete && FilledIn_PrescriptionCommon());
		
}
//====================================================================================================================================
function FilledIn_PrescriptionCommon() {

//Check that the common parts (start, stop, duration) are filled in.	
	
var blnComplete = true;
var blnDurationMandatory = false;

	//Route;
	if (lstRoute.options[lstRoute.selectedIndex].value == 'empty')
	{
	    //29Mar10   Rams    F0079620 - An order-set appears in state of ready despite not having a populated route and causes an error when trying to commit
	    //                  If route is empty (which is always mandatory) then just get out from here, need not do any other checking
	     blnComplete = false;
	     return blnComplete;
	}

	//Frequency
	if ((document.all['lstFrequency']!= undefined)) {
		if (lstFrequency.selectedIndex <= 0)blnComplete = false;
		if (lstFrequency.options[lstFrequency.selectedIndex].value == 'blank') blnComplete = false;													//11Nov05 AE  Added test for separator.
	}

	//Duration is optional, but if entered then so must its units be
	//Duration now may be set to mandatory!
	blnDurationMandatory = (GetMandatoryStatusFromXML('Duration') == 1);

	if (blnDurationMandatory) blnComplete = false;

	if (txtDuration.value != '' && txtDuration.value != '0') 
	{
	//Duration has been entered, check that there are units
	    if (lstDurationUnits.selectedIndex == -1) 
	    {
	        blnComplete = false;
	    }
	    else {
	        if (lstDurationUnits.options[lstDurationUnits.selectedIndex].getAttribute('dbid') == '0') 
	        {
	            blnComplete = false;
	        }
	        else 
	        {
	            blnComplete = true;
	        }
	    }
	}
	else 
	{
	    //No duration entered or 0 is inputted reset to be complete (i.e. duration is optional again)
	    //24Aug2009 JMei Don't reset it back in case of duration is mandatory 
	    if (!blnDurationMandatory) blnComplete = true;
	}
	
	//Must have a start date, unless this is an immediate dose
	if (blnComplete){
		if (txtStartDate.value == '') {
			blnComplete = (lstSchedule.options[lstSchedule.selectedIndex].value == 'immediate');
		}	
	}

    //12Nov10   Rams    F0101107 - the field on the order-comms screen should default to blank
    if(blnComplete)
    {
        var oReasonCtl = document.getElementById('lstReason');
        if (oReasonCtl != undefined && document.body.getAttribute("isreasoncapturemandatory") == "true")
        {
            if (oReasonCtl.options[oReasonCtl.selectedIndex].text == "") 
                blnComplete = false;
        }
    }

	return blnComplete;

}

//====================================================================================================================================
function FilledIn_PrescriptionInfusion(){

//Continuous infusions require:
//		Rate
//		Rate Mass Unit
//		Rate Time Unit
//
//		The common stuff

var blnComplete = true;
var blnRateInDose = true;
var intCount = 0;
var objSelect;

	if (IsContinuous()) {			
	//Continuous Infusions (those with a rate)
		if (Number(txtInfusionRate.value) <= 0)blnComplete = false;																				//28Apr05 AE  Corrected logic in continuous section
		if (trRateStart.all['lstUnits'].selectedIndex < 0) blnComplete = false;
		if (chkVaryRate.checked){
			if (Number(txtInfusionRateMin.value) <=0 || Number(txtInfusionRateMax.value) <= 0) blnComplete = false;			
		}
	}
	
	if (typeof(document.all['txtInfusionDuration']) != 'undefined') {																			//25Jan05 AE  Support for Bolus Doses
	//Intermittent Infusions (those with a duration
		//Each product must have a dose specified.
		for (intCount=1;intCount < tblIngredients.rows.length; intCount++){
			objRow = tblIngredients.rows[intCount];

			if (typeof (objRow.all['txtDose']) != 'undefined') {
			    //05Oct10 JMei F0098058 infusions with 0 dose shouldn't be able to be committed 
			    if (txtDose.value == '' || parseFloat(txtDose.value) == 0) blnComplete = false;
				objSelect = objRow.all['lstUnits'];
				if (Number(objSelect.options[objSelect.selectedIndex].getAttribute('dbid')) <= 0) blnComplete = false;
				if (!blnComplete) break;
			}
//			if (txtFreq.value == '') {blnComplete = false;}																							//11Mar05 AE  Added check for frequency
			if (lstFrequency.selectedIndex < 0) blnComplete = false
		}
	
		//Must have a duration specified if "Give as Infusion" is chosen
		if (lstInfusionDuration.options[lstInfusionDuration.selectedIndex].value == 'duration'){										//25Jan05 AE
		    if (txtInfusionDuration.value == '') blnComplete = false;
			if (lstInfusionDurationUnits.selectedIndex < 0) blnComplete = false;
		}

		//F0046776
		//ST 25Feb09 - frequency is a mandatory field but also has a blank entry at the top of the list so we check for that as well.
		if (lstFrequency.options[lstFrequency.selectedIndex].innerText == '') blnComplete = false;
	}

	return (blnComplete && FilledIn_PrescriptionCommon());
}

function FrequencySelected() {
    var rtnValue = false;
    var styleString = "block";
    if (lstFrequency.options[lstFrequency.selectedIndex] != null) {
        var FrequencySelectedOption = lstFrequency.options[lstFrequency.selectedIndex];
        var FrequencySelectedDbID = FrequencySelectedOption.getAttribute('dbid');
        var frequencySelectedValue = FrequencySelectedOption.value;
        if (
            DisplayMode() || 
            (FrequencySelectedDbID != null && FrequencySelectedDbID != "" && frequencySelectedValue != "blank")
            )
         {
            styleString = "none";
            rtnValue = true;
        }
    }
    tdFrequencyWarningNoSelection.style.display = styleString;
    return rtnValue;
}

//====================================================================================================================================
function ValidityCheck_Standard() {
	
//Checks the validity of the data in the standard and doseless prescription entry form.
//Returns true if the data is valid, false if not.
//Note that this is not the same as FilledIn
	
var spnTitle = new Object();
var strDisplay
var strTitle = '';
var strFeatures = '';
var frameIndex = 0;


//Hide all warnings to start with
	var blnValid = true;
	
	tdDoseWarning.style.display = 'none';
	trDateFormatWarning_StartDate.style.display = 'none';
	trDateFormatWarning_StopDate.style.display = 'none';
	trDateWarning.style.display = 'none';

	if (document.all['trProductFormWarning'] != undefined)
	{
        trProductFormWarning.style.display = 'none';
    }

//Show any warnings for failed checks
	if (!DoseRangeValid()) {
		blnValid = false;
		tdDoseWarning.style.display = 'block';
	}
	//22Jan2010 JMei f0075325 allow save a template without route selected
//	if (!RouteValid()) {
//	//This does not check for APPROVED routes, but rather than if a route which has multiple subroutes
//	//is selected (for example, EAR), that one of the subroutes is specified (for example, Left Ear, Right Ear).
//		blnValid = false;
//	}

	if (!DateValidityCheck(txtStartDate)) {
		blnValid = false;
		trDateFormatWarning_StartDate.style.display = 'block';
	}

	if (!DateValidityCheck(txtStopDate)) {
		blnValid = false;
		trDateFormatWarning_StopDate.style.display = 'block';
	}

	if (!DateRangeValid()) {
		trDateWarning.style.display = 'block';
		blnValid = false
	}

	if (!DurationValidityCheck()){																							//22May06 AE  Added duration checks #SC-06-0541
		blnValid = false;
    }
	
	if (!ReviewValidityCheck()) {
		blnValid = false;
	}

	if (!DoseCapValidatityCheck())
	{
		blnValid = false;
	}
	
	if ( (document.all['lstForm'] != undefined) && (document.all['lstForm'].selectedIndex == -1) )
	{
    	if (document.all['trProductFormWarning'] != undefined)
    	{
            trProductFormWarning.style.display = 'block';
        }

		blnValid = false;
	}

    DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
	return (blnValid);
}	

//====================================================================================================================================
function ReadDataFromFormWithRoot()
{

    var strXML = '<root';
	if (instanceData.XMLDocument == undefined)
	{
		strXML += '>'
	}
	else
	{
		var docLoadedRoot = instanceData.XMLDocument.documentElement;
		var strClass = docLoadedRoot.getAttribute('class')
		if (strClass == undefined)
		{
			strXML += '>'
		}
		else
		{
			var strID = docLoadedRoot.getAttribute('id')
			var strOTID = docLoadedRoot.getAttribute('ordertemplateid')
			strXML += ' class="' + strClass + '" id="' + strID + '" ordertemplateid="' + strOTID + '">';
		}
	}
    strXML += ReadDataFromForm() + '</root>'
	return strXML;
}

//====================================================================================================================================
function ReadDataFromForm() {

var strXML = '';

//First check if we've changed the request type; if the prescription has been changed to be doseless
//or infusion, we need to update the metadata held on the client so that it will be saved into the 
//PrescriptionDoseless table rather than the ordinary Prescription table.
	UpdatePrescriptionMetadata(document.body.getAttribute('requesttype'));

//Now get the data
	switch (document.body.getAttribute('requesttype')) {
		case REQUESTTYPE_STANDARD:
			strXML = ReadDataFromForm_Standard();
			break;

		case REQUESTTYPE_DOSELESS:
			strXML = ReadDataFromForm_Standard();
			break;

		case REQUESTTYPE_INFUSION:
			strXML = ReadDataFromForm_Infusion();
			break;
	}

	blnFilledIn = FilledIn();

	//21June2010 F0066673 JMei Put reason capture for prescription back to icw
	/*
	var returnXML = '<data ' 
	+ 'filledin="' + blnFilledIn + '" '
	+ '>'
	+ strXML
	+ '</data>';
	*/

	var returnXML = '<data '
				 + 'filledin="' + blnFilledIn + '" '
				 + '>'
				 + strXML
 				 + ReasonCaptureXML()
				 + '</data>';

	DescriptionChangeRequired();  // Call to change description for bug fix F0023374
	return returnXML;
}

//21June2010 F0066673 JMei Put reason capture for prescription back to icw
function ReasonCaptureXML() {

    //Returns the contents of the reason capture field, if present.
    var strReturn = new String();
    if (document.all['lstReason'] != undefined) {
    	if (lstReason.options[lstReason.selectedIndex].value != null && lstReason.options[lstReason.selectedIndex].value != 'other')
    	{
    		//04Nov05 AE  
    		strReturn = '<' + XML_ELMT_REASON + ' '
						 + XML_ATTR_REASONID + '="' + lstReason.options[lstReason.selectedIndex].value + '" '
						 + XML_ATTR_REASONIDTEXT + '="' + lstReason.options[lstReason.selectedIndex].innerText + '" '
						 + XML_ATTR_REASONTYPE + '="' + lstReason.options[lstReason.selectedIndex].getAttribute(XML_ATTR_REASONTYPE) + '" '
						 + XML_ATTR_CAPTUREMODE + '="' + lstReason.getAttribute(XML_ATTR_CAPTUREMODE) + '" '
						 + ' />';
    	}
    	else // need to return empty element with just the capture mode if nothing selected, in order to preserve reason capture between saves and reads from / to pending tray
    	{
    		strReturn = '<' + XML_ELMT_REASON + ' '
						 + XML_ATTR_CAPTUREMODE + '="' + lstReason.getAttribute(XML_ATTR_CAPTUREMODE) + '" '
						 + ' />';
    	}
    }
    return strReturn;
}


//====================================================================================================================================
function ReadDataFromForm_Standard() {

//Read the data back off of the form for returning to the order entry page.
//This is for Standard and Doseless prescriptions
//12Aug05 AE  Added Support for read-only controls
var strXML = new String();
var strUnitText = new String();
var strAttrsHigh = '';
var strAttrsLow = '';
var ArbTextID;

//Build up the data in an XML string to be included in the 
//standard form data

	//Porcduct
	strXML += FormatXML('ProductID', lblDrugName.getAttribute('productid'), lblDrugName.innerText );							
	//strXML += FormatXML('ProductID', lblDrugName.getAttribute('productid'), XMLEscape(lblDrugName.innerText) );							//01Aug06 AE  Added XML Escape
	
	//Form, if present																						//09Aug05 AE  Added form for chemical prescriptions
	//Note that form is saved in the same field as when a MeteredDosing TM or above is prescribed.  
	//It is in fact the same information displayed in two different ways, however the two different 
	//ways can never both be used at the same time.  So there's no conflict.
	if (document.body.all['lstForm'] != undefined){
		strXML += FormatXML('ProductFormID_Dose', lstForm.options[lstForm.selectedIndex].getAttribute('dbid'), lstForm.options[lstForm.selectedIndex].innerText, GetReadOnlyAttribute(lstForm));	
	}
	
	//Directions	(for doseless prescription only)

														//19Jan06 AE  Removed If; applies to all standard types.
	// 02Feb06 PH Added "IF" back in, as was getting duplicate <attribute name="ArbTestID_Direction" ... /> rows in the xml. 
	if ( document.body.getAttribute('requesttype') == REQUESTTYPE_DOSELESS )
	{
	    ArbTextID = txtDirection.getAttribute('dbid');
	    if(ArbTextID == 0)
	    {
	        ArbTextID = '';
	    }
	    strXML += FormatXML('ArbTextID_Direction', ArbTextID, GetValueFromTextBoxOrLabel(txtDirection));
		strXML += FormatXML('DirectionText', txtDirectionFree.value);
	}
			
	//Dose; this may have been calculated or not, and there may be a range...				//09Jan04 AE  Added Dose ranges
	if (txtDoseQty2.value != '') {
		//Dose 1 is the low dose, dose 2 is the high dose...
		highDose = txtDoseQty2.value;
		lowDose = txtDoseQty.value;

		strAttrsHigh = GetReadOnlyAttribute(txtDoseQty2)											//12Aug05 AE  Added Support for read-only controls
		strAttrsLow = GetReadOnlyAttribute(txtDoseQty)
	}
	else {
		//Single dose only; dose 1 is the high dose, low dose is 0.
		highDose = txtDoseQty.value;
		lowDose = 0;
		strAttrsHigh = GetReadOnlyAttribute(txtDoseQty);											//12Aug05 AE  Added Support for read-only controls
		strAttrsLow = GetReadOnlyAttribute(txtDoseQty2);
	}
			
	strXML += FormatXML('Dose', highDose, '', strAttrsHigh);										//12Aug05 AE  Added Support for read-only controls
	strXML += FormatXML('DoseLow', lowDose, '', strAttrsLow);

	if (lblDrugName.getAttribute('iscalculateddose') == 'true') {
		//This is a calculated dose; we have to make sure we persist
		//the original dose value which was used in the calculation,
		//and also the routine used to do the calculation
		strXML += FormatXML('CalculatedDose', lblDrugName.getAttribute('iscalculateddose'))
		strXML += FormatXML('Calculation_Dose', lblDrugName.getAttribute('calculation_dose'));															//07Feb05 AE  Persist all calculation data across saves to the pending tray
		strXML += FormatXML('Calculation_DoseLow', lblDrugName.getAttribute('calculation_doselow'));		
		strXML += FormatXML('Calculation_CalculatedDose', lblDrugName.getAttribute('calculation_calculateddose'));				
		strXML += FormatXML('Calculation_CalculatedDoseLow', lblDrugName.getAttribute('calculation_calculateddoselow'));						
		strXML += FormatXML('Calculation_RoutineID', lblDrugName.getAttribute('calculation_routineid'), lblDrugName.getAttribute('calculation_routinedescription'));
	}	
	else {
		//Dose is not calculated, OR this is a template and we are specifying a 
		//calculation to be done in future.
		//Dose calculation routine
		if (lstRoutine.selectedIndex > -1) {
			strXML += FormatXML('Calculation_RoutineID', lstRoutine.options[lstRoutine.selectedIndex].getAttribute('dbid'), lstRoutine.options[lstRoutine.selectedIndex].text);
		}
	}

	if (lstUnits.selectedIndex > -1) {
		//Units may hold an actual unit, or a form (eg tablet), or eventually packaging (eg, pack, kit, etc)
		strType = lstUnits.options[lstUnits.selectedIndex].getAttribute('type')
		switch (strType){
			case 'form':
			//ProductForms, eg tablet, capsule, etc. 
			//Note that this is the same field as for the form shown on chemical templates.  It is in fact the same information displayed
			//in two different ways, however the two different ways can never both be used.  So there's no conflict
				strXML += FormatXML('ProductFormID_Dose', lstUnits.options[lstUnits.selectedIndex].getAttribute('formid'), lstUnits.options[lstUnits.selectedIndex].text);
				break;
			
			case 'pack':
			//Packages, such as sachets
				strXML += FormatXML('ProductPackageID_Dose', lstUnits.options[lstUnits.selectedIndex].getAttribute('productpackageid'), lstUnits.options[lstUnits.selectedIndex].text);
				break;
			
			default:
			//Actual unity-units, grams, mL, etc.
				strUnitText = lstUnits.options[lstUnits.selectedIndex].text;
		}		
		//Now the actual units, mg, ml etc. In the case of Forms/Packs this is not shown, and is always Quantity.
		strXML += FormatXML('UnitID_Dose', lstUnits.options[lstUnits.selectedIndex].getAttribute('dbid'), strUnitText);
	}

	//Rounding value and unit																																							//08Apr05 AE  Added
	if (txtRoundValue.value != ''){
		strXML += FormatXML (ATTR_ROUND_INCREMENT, txtRoundValue.value);
		strXML += FormatXML(ATTR_ROUND_UNIT, lblRoundUnit.getAttribute('dbid'),'');
	}

	//Dose cap value and unit																																							//08Apr05 AE  Added
	if (txtDoseCap.value != ''){
		strXML += FormatXML(ATTR_DOSE_CAP, txtDoseCap.value);
		strXML += FormatXML(ATTR_DOSE_CAP_UNIT, lblDoseCapUnit.getAttribute('dbid'),'');
	}
	strXML += FormatXML(ATTR_DOSE_CAP_CAN_OVERRIDE, lnkDoseCapOverridable.getAttribute('override'),'');
	//04Sep08 ST  - Dose reduction options
	strXML += FormatXML(ATTR_DOSE_REEVALUATE, lnkDoseReevaluate.getAttribute('override'), '');

	// Add any dose calculation xml in as well
	strXML += FormatXML("Persisted_RoundTo", lblDrugName.getAttribute('persisted_roundto'));
	strXML += FormatXML("Persisted_RoundToUnitID", lblDrugName.getAttribute('persisted_roundtounitid'));
	//strXML += FormatXML("Dose_XML", XMLEscape(lblDrugName.getAttribute('dose_xml')));
	strXML += FormatXML("Dose_XML", lblDrugName.getAttribute('dose_xml'));
	
	strXML += ReadDataFromForm_Common();

	//Return it
    DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
	return strXML;	

}

//==================================================================================================================================
function ReadDataFromForm_Common()
{
	//Read the data from all controls in PrescriptionCommon.aspx;
	//that is, the frequency, duration, and all controls below.
	//10Aug05 AE  Added support for read-only controls
	var strDate = new String();
	var lngScheduleID = new Number();
	var lngUnitID = 0;
	var lowDose = new Number();
	var highDose = new Number();
	var strType = new String();
	var strUnitText = new String();
	var objDateControl;
	var strText = '';

	var strXML = new String();
	var bitPRN = 0;
	var bitStat = 0;
	var bitImmediate = 0;
	var bitNoDoseInfo = 0;
	var ArbTextID;

	strXML += FormatXML('OnSelectWarningLogID', document.body.getAttribute("onselectwarninglogid"));
	//Product and route
	if (lstRoute.selectedIndex > -1 && lstRoute.options[lstRoute.selectedIndex].value != 'empty')
	{																		//29Nov05 AE  Added check for empty #SC-05-0007
		var lngRouteID = lstRoute.options[lstRoute.selectedIndex].getAttribute('dbid');
		var strText = lstRoute.options[lstRoute.selectedIndex].innerText;
		var xmlRoute = routesData.XMLDocument.selectSingleNode('//ProductRoute[@ProductRouteID="' + lngRouteID + '"]');
		var lngRouteID_Parent = xmlRoute.getAttribute('ProductRouteID_Parent');
		strXML += FormatXML('ProductRouteID', lngRouteID, strText, GetReadOnlyAttribute(lstRoute) + ' value_parent="' + lngRouteID_Parent + '"'); 		//16Nov05 AE  Added text to saved data, for change reporting.   //12Aug05 AE  Added Support for read-only controls
	}
	//Administration schedule, including (stat and prn). Is not scripted for continuous infusions.
	if (typeof (document.all['lstFrequency']) != 'undefined')
	{

		bitPRN = (chkPRN.checked ? 1 : 0);
		bitStat = (chkStat.checked ? 1 : 0);
		bitNoDoseInfo = (chkNoDoseInfo.checked ? 1 : 0); 																																//24May06 AE  Added checks for NoDoseInfo #DJ-06-0079

		lngScheduleID = 0
		if (document.all['lstFrequency'] != undefined)
		{
			if (lstFrequency.selectedIndex >= 0)
			{
				lngScheduleID = lstFrequency.options[lstFrequency.selectedIndex].getAttribute('dbid');
				strText = lstFrequency.options[lstFrequency.selectedIndex].innerText;
			}
		}
		strXML += FormatXML('ScheduleTemplateID', lngScheduleID, strText, GetReadOnlyAttribute(lstFrequency)); 													//16Nov05 AE  Added text to saved data, for change reporting.   12Aug05 AE  Added Support for read-only controls

		if (lngScheduleID <= 0)
		{
			//We have something other than a simple schedule template ID; either PRN, stat, truely frequencyless, or an ad-hoc schedule.
			if (!chkPRN.checked && !chkStat.checked && !chkNoDoseInfo.checked)
			{
				//If we have an ad-hoc schedule, we need to store it.
				strXML += FormatXML('Schedule_AdHoc', advancedFrequencyData.XMLDocument.xml, txtFreqLong.innerText);
			}

			if (chkStat.checked)
			{
				//This is a stat dose.  Either immediate, or with a start date and time.
				//Start date is always recorded, time is only recorded for stat doses.
				bitImmediate = (lstSchedule.options[lstSchedule.selectedIndex].value == 'immediate') ? 1 : 0; 													//26Mar05 AE  Move away from true/false to 1/0
				strXML += FormatXML('STAT_Immediate', bitImmediate);
			}
		}
	}



	//PRN, NoDoseInfo & STAT		
	strXML += FormatXML('PRN', bitPRN);
	strXML += FormatXML('STAT', bitStat);
	strXML += FormatXML('NoDoseInfo', bitNoDoseInfo); 																																//24May06 AE  Added checks for NoDoseInfo #DJ-06-0079

	//Duration 
	if (lstDurationUnits.selectedIndex > -1)
	{
		lngUnitID = Number(lstDurationUnits.options[lstDurationUnits.selectedIndex].getAttribute('dbid'));
		strText = lstDurationUnits.options[lstDurationUnits.selectedIndex].text;
	}
	strXML += FormatXML('UnitID_Duration', lngUnitID, strText);
	strXML += FormatXML('Duration', txtDuration.value, '', GetReadOnlyAttribute(txtDuration) + ' ' + GetMandatoryAttribute(txtDuration)); 													//12Aug05 AE  Added Support for read-only controls

	//Start and stop dates. 
	//Start time is not added if Immediate STAT dosing is specified.
	strXML += FormatXML('lstScheduleIndex', lstSchedule.selectedIndex);
	if (!m_blnTemplateMode)
	{
		objDateControl = new DateControl(txtStartDate);
		strDate = objDateControl.GetTDate();
		if (strDate != '')
		{
			strXML += FormatXML('StartDate', strDate);
		}

		if (lstSchedule.options[lstSchedule.selectedIndex].value != 'immediate')
		{
			strXML += FormatXML('StartTime', txtStartTime.value); 													//Move from above
		}
	}


	objDateControl = new DateControl(txtStopDate);
	strDate = objDateControl.GetTDate();

	if (strDate != '')
	{
		strXML += FormatXML('StopDate', strDate);
	}

	//Additional text / direction code
	// 02Feb06 PH Added "IF" here because was getting duplicate <attribute name="ArbTestID_Direction" ... /> rows in the xml
	if (document.body.getAttribute('requesttype') != REQUESTTYPE_DOSELESS)
	{
		ArbTextID = txtExtra.getAttribute('dbid');
		if (ArbTextID == 0)
		{
			ArbTextID = '';
		}

		strXML += FormatXML('ArbTextID_Direction', ArbTextID, txtExtra.innerText);
		strXML += FormatXML('SupplimentaryText', txtExtraFree.value);
	}
	//Build a default description
	var strDefaultDescription = BuildDefaultDescription();
	if (m_blnTemplateMode)
	{
		//When building templates, set the description to the default description; the user can
		//then overtype this if they desire.
		window.parent.document.all['spnItemTitle'].innerHTML = strDefaultDescription;
	}
	strXML += FormatXML('ASCDescription', strDefaultDescription);



	// Review details

	if (document.getElementById("lstReviewType") != null)
	{
		var lngRequestTypeID = lstReviewType.options[lstReviewType.selectedIndex].getAttribute('dbid');
		var lngReviewPeriod = txtReviewDate.value;
		var strReviewDate = UpdateReviewDate();
		var strReviewUnits = lstReviewUnits.options[lstReviewUnits.selectedIndex].innerText;
		var strReviewAction = lstReviewDate.options[lstReviewDate.selectedIndex].innerText;

		var strReviewDescription = lstReviewType.options[lstReviewType.selectedIndex].innerText + " ";
		strReviewDescription += txtReviewDate.value + " ";
		strReviewDescription += lstReviewUnits.options[lstReviewUnits.selectedIndex].innerText + " ";
		strReviewDescription += strReviewAction;

		strXML += FormatXML('ReviewRequestTypeID', lngRequestTypeID, lstReviewType.options[lstReviewType.selectedIndex].innerText, GetReadOnlyAttribute(lstReviewType));
		strXML += FormatXML('ReviewIn', lngReviewPeriod, "", GetReadOnlyAttribute(txtReviewDate));
		strXML += FormatXML('ReviewRequestDate', strReviewDate);
		strXML += FormatXML('ReviewUnits', lstReviewUnits.options[lstReviewUnits.selectedIndex].getAttribute('dbid'), lstReviewUnits.options[lstReviewUnits.selectedIndex].innerText);
		strXML += FormatXML('ReviewAction', lstReviewDate.options[lstReviewDate.selectedIndex].getAttribute('dbid'), lstReviewDate.options[lstReviewDate.selectedIndex].value);
		strXML += FormatXML('ReviewDescription', strReviewDescription);
	}

	//Instructions to pharmacy. If any are entered, we use them to create a DispensingInstruction attached note			
	strXML += '<attachednotes>'; 																															//16Mar06 AE  Moved attachednotes node here.  Fixes #SC-06-0377, (broken by "attached notes on pending" item enhancement)
	strXML += CreateDispensingInstructionsXML();

	//Change reporting
	strXML += CreateChangeReportXML();
	strXML += '</attachednotes>';

	strXML += '<attribute name="TemplateDetail" value="' + XMLEscape(divTemplateDetail.innerHTML) + '" />';

	//Return it
	DescriptionChangeRequired();  // Call to change description for bug fix F0023374
	return strXML;
}

//==========================================================================
function DescriptionUpdate(RequestID){

//When we edit the diluent of a committed prescription, the page is refreshed to rescript it with 
//the new diluent details and dose.  This procedure is then called to rebuild and save the description
//using an ajax call
//27May08 AE 

	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");  
	
	//SCH 7/8/8 - This is now done in a common place
	//var strDescription = BuildDefaultDescription();
	//window.parent.DescriptionUpdate(document.body.getAttribute("ordinal"), strDescription);

	var strURL = '../../OrderEntry/DiluentWorker.aspx'
							 + '?SessionID=' + document.body.getAttribute("sid")
							 + '&Mode=DescriptionUpdate_Request'
							 + '&RequestID=' + RequestID

	objHTTPRequest.open("POST", strURL, false);
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");
	objHTTPRequest.send(BuildDefaultDescription());
	strReturn = objHTTPRequest.responseText;
	if (strReturn != '') {
		Popmessage (strReturn);
	}	

	window.returnValue = 'refresh';
	   
}

//==========================================================================
function BuildDefaultDescription() {
//Now get the data
// 14Jul06 PH Removed 128 truncation

	var strDescription = "";

	switch (document.body.getAttribute('requesttype')) {
		case REQUESTTYPE_STANDARD:
			strDescription = BuildDefaultDescription_Standard();
			break;

		case REQUESTTYPE_DOSELESS:
			strDescription = BuildDefaultDescription_Standard();
			break;

		case REQUESTTYPE_INFUSION:
			strDescription = BuildDefaultDescription_Infusion();
			break;
	}
	
	//return strDescription.substr(0,128);  // 14Jul06 PH Removed 128 truncation
	return trim(strDescription);																	//01Nov06 AE  Added trim
}
//==========================================================================

function BuildDefaultDescription_Standard() {
//Build a default description.  This is used if no description configuration
//is found.
//27May05 AE  Improved full stops/commas between route, frequency & duration.  Also moved extra directions to the end of the string
var doseFrom = new Number(0);
var doseTo = new Number(0);
var strForm = '';

    //Drug
    // 10Oct08  ST F0034941 - check to see if the drug name is on the form before we try gathering the data
    var strDrug = '';
    if (document.all['lblDrugName'] != undefined)
    {
        strDrug = lblDrugName.innerText;


        var blnDoseless = (document.body.getAttribute('requesttype') == REQUESTTYPE_DOSELESS);

        //Route
        //	var strRoute = txtRoute.value;
        var strRoute = '';
        if (lstRoute.options[lstRoute.selectedIndex].value != 'empty')
        {
            var lngRouteID = lstRoute.options[lstRoute.selectedIndex].getAttribute('dbid');

            //F0039413
            //24Nov08 ST  Check for a null ID, as is the case when 'all' is selected as this isn't a true record from the database
            if (lngRouteID != null)
            {
                strRoute = routesData.XMLDocument.selectSingleNode('//ProductRoute[@ProductRouteID="' + lngRouteID + '"]').getAttribute('Detail');
            }
        }
        else
        {
            strRoute = '[route not specified]';
        }

        //Dose + Unit
        var strDose = '';
        doseFrom = txtDoseQty.value;
        if (doseFrom == '') doseFrom = 0;

        doseTo = txtDoseQty2.value;
        if (doseTo == '') doseTo = 0;

        if (doseFrom == 0)
        {
            //No dose; this may be because the form is incomplete, or because it's a doseless
            //prescription type.
            if (blnDoseless)
            {
                //We don't have a dose qty, just some text in this case.
                //Also we don't show the route text.
                //08Jul2009 JMei F0057697 It seems this Route is needed even for doseless
                strDose = GetValueFromTextBoxOrLabel(txtDirection);
                //strRoute = '';
            }
            else
            {
                strDose = '[Specify dose]'; 																													//15Mar06 AE  Modified text as per #DR-06-0200
            }
        }
        else
        {

            strDose = doseFrom;
            if (doseTo != 0)
            {
                strDose += ' to ' + doseTo;
            }

            // Shouldn't happen but check that we actually have something in the units list before we try and access it
            if (lstUnits.length > 0) {
                strDose += lstUnits.options[lstUnits.selectedIndex].innerText; 																			//15Dec05 AE  #DR-05-0069
                //If our unit is tablet, puff, drop, sachet etc, pluralise if required.
                var strType = lstUnits.options[lstUnits.selectedIndex].getAttribute('type');
                switch (strType) {
                    case 'form':
                    case 'pack':
                        if ((doseFrom != 1) || (doseTo > 0)) {
                            //F0047631 ST   09Mar09
                            //Added check to see if we have (s) in the dose text and if so we don't want to add on the extra 's'
                            if (strDose.toLowerCase().indexOf('(s)') > 0)
                                break

                            if (strDose.substring(strDose.length - 1, strDose.length).toLowerCase() != 's') {
                                strDose += 's';
                            }
                        }
                        break;
                }
            }            
        }
        //Include the routine if used
        if (lstRoutine.options[lstRoutine.selectedIndex].getAttribute('dbid') > 0)
        {
            if (lstRoutine.options[lstRoutine.selectedIndex].getAttribute("shortdescription") != "")
            {
                strDose += '/' + lstRoutine.options[lstRoutine.selectedIndex].getAttribute("shortdescription");
            }
            else
            {
                strDose += '/' + lstRoutine.options[lstRoutine.selectedIndex].innerText;
            }
        }

        //Frequency + PRN
        var strFrequency = BuildDefaultDescription_Frequency();

        //Form, if a chemical template
        if (document.all['lstForm'] != undefined)
        {
            if (lstForm.selectedIndex > 0) strForm = ' (as ' + lstForm.options[lstForm.selectedIndex].innerText + ')';
        }

        //Supplimentary info
        var strExtra = '';
        if (!blnDoseless) strExtra = ' ' + trim(txtExtra.innerText) + ' '; 																		//04Apr06 AE  Prevent duplication of text in doseless prescriptions

        //Duration
        var strDuration = '';
        var strUnit_Duration = '';
        if (lstDurationUnits.selectedIndex > -1)
        {
            if (lstDurationUnits.options[lstDurationUnits.selectedIndex].text != '' && txtDuration.value != '')
            {
                strUnit_Duration = lstDurationUnits.options[lstDurationUnits.selectedIndex].text;
                if (Number(txtDuration.value) == 1) strUnit_Duration = strUnit_Duration.substring(0, strUnit_Duration.length - 1); //15Dec05 AE  Remove 's' for singletons, eg "1 day" not "1 days"  #DR-05-0069
                strDuration = ', for ' + txtDuration.value + ' ' + strUnit_Duration + '. ';
            }
        }

        //Return the full description
        if (m_blnTemplateMode)
        {
            return (strDose + ' ' + strRoute + ' ' + strFrequency + strDuration + strForm + strExtra); 										//15Dec05 AE  #DR-05-0069
        }
        else
        {
            return (strDrug + ': ' + strDose + ' ' + strRoute + ' ' + strFrequency + strDuration + strForm + strExtra); 				//15Dec05 AE  #DR-05-0069
        }
    }
    else
    {
        return ""
    }
}

//=======================================================================================================================
function BuildDefaultDescription_Frequency(){
	var strFrequency = '';
	if (document.all['lstFrequency'] != undefined){
		if (lstFrequency.options[lstFrequency.selectedIndex].value != 'blank'){
			strFrequency = lstFrequency.options[lstFrequency.selectedIndex].innerText;
		}
	}

	if (strFrequency == '') {
		strFrequency = txtFreqLong.innerText;
	}
	else {
		if (chkPRN.checked) {
		//Add "PRN" to the text, UNLESS the "When Required" PRN direction is required.
			//if (Number(txtFreq.getAttribute('dbid')) != 0) {
			if (lstFrequency.options[lstFrequency.selectedIndex].value != 'prn'){															//15Dec05 AE  Corrected. #SC-05-0124
				strFrequency += ', if required';																											//15Mar06 AE  Modified text as per #DR-06-0200
			}
		}
	}
	return strFrequency;
}	
	

//=======================================================================================================================
function PopulateTemplateDetail(){
	
//If we have any further detail for this order template, we show them in a read-only field.

	var strText = GetValueFromXML('TemplateDetail');
	if (strText != ''){
		divTemplateDetail.innerHTML = strText;
		trTemplateDetail.style.display = 'block';
	}
	
}

//=======================================================================================================================
function CreateDispensingInstructionsXML(){

//If dispensing instructions have been entered, we store them in an xml island on
//the form.  This is then read from OrderEntry's CollateDataFromChildForms method.
//16Mar06 AE  Removed <attachednotes> node from here and moved up a level so that we
//				  can put the change report note in it as well.  #SC-06-0377
var strXML = '';
var slicePoint = 0;
var strReturn_XML = ''

	var strText = txtPharmacyDirections.value;

	if (trim(strText) != ''){																															//05Dec06 AE  Changed to save dispensing instruction in template mode as well. #SC-06-1041
	//Close up and escape
		strReturn_XML = '<attachednote type="Dispensing Instruction">'
						  + '<data>'
						  + FormatXML('Detail', strText , '')
						  + '</data>'
						  + '</attachednote>';
	}
	
	return strReturn_XML;
}

//=======================================================================================================================
function CreateReviewRequestXML() 
{

// if there is a reviewrequest type selected then we'll create the appropriate xml here

var strXML = '';
var strReturn_XML = '';

	if(lstReviewType.selectedIndex > -1 && lstReviewType.options[lstReviewType.selectedIndex].getAttribute('dbid') != -1) 
	{
		var lngRequestTypeID = lstReviewType.options[lstReviewType.selectedIndex].getAttribute('dbid');
		//var lngReviewPeriod = txtReviewDate.value;
		var strReviewDate = UpdateReviewDate();
		var strReviewUnits = lstReviewUnits.options[lstReviewUnits.selectedIndex].innerText;
		var strReviewAction = lstReviewDate.options[lstReviewDate.selectedIndex].innerText;
		
		var strReviewDescription = lstReviewType.options[lstReviewType.selectedIndex].innerText + " ";
		strReviewDescription += txtReviewDate.value + " ";
		strReviewDescription += lstReviewUnits.options[lstReviewUnits.selectedIndex].innerText + " ";
		strReviewDescription += strReviewAction;

		strReturn_XML = '<reviewrequest>'
					+ '<data>'
					+ FormatXML('ReviewRequestTypeID', lngRequestTypeID, lstReviewType.options[lstReviewType.selectedIndex].innerText)
					+ FormatXML('ReviewRequestDate', strReviewDate)
					+ FormatXML('ReviewDescription', strReviewDescription)
					+ FormatXML('ReviewUnits', strReviewUnits, lstReviewUnits.options[lstReviewUnits.selectedIndex].innerText)
					+ FormatXML('ReviewAction', lstReviewDate.options[lstReviewDate.selectedIndex].value, strReviewAction)
					+ '</data>'
					+ '</reviewrequest>';
	}
	
	return strReturn_XML;
}
//=======================================================================================================================
//										Change Reporting ("track changes")
//=======================================================================================================================
function CreateChangeReportXML()
{
//Checks certain fields to see if their values have changed from those templated.
//This is then used so that a user reviewing the prescription can easilly see
//what has changed from the norm. Returns a <changes> xml document:
//	<attachednote type="Change Report">
//		<data>
//			<changes>
//				<c id='{strFieldID}' old="{originalValue}" new="{currentValue}" ... />	
//						'
//			</changes>
//		</data>
    //	</attachednote>

var strXML = '';
var strReturn_XML = '';
var value_original = '';
var valuelow_original = '';
var value_new = '';
var value_new_parent = '';
var valuelow_new = '';
var unit_original = '';
var unit_new = '';
var unittime_original = '';
var unittime_new = '';
var strOrig = '';
var strNew = '';
var xmlElement;
var routine = '';

	if (!m_blnTemplateMode && !CopyMode()){
		//Route
		value_original = GetOriginalValue('ProductRouteID');
		//Old templates only stored the id, so we won't have the text.  In this case, 
		//we'll look it up in the xml.  New templates will store the text to start with.
		if (value_original != '' && IsNumeric(value_original)){
			xmlElement = routesData.XMLDocument.selectSingleNode('Routes//ProductRoute[@ProductRouteID="' + value_original +  '"]');		
			if (xmlElement != undefined){
				value_original = xmlElement.getAttribute('Description');
			}
		}
		value_new = lstRoute.options[lstRoute.selectedIndex].innerText;
		if (value_original.toLowerCase() != value_new.toLowerCase() && value_original != '')
		{
			//We have a change.  However, the change may be to pick a child route (eg, picking "left eye" when the original route was "eye"),
		//in which case we don't want to flag it up.
			xmlElement = routesData.XMLDocument.selectSingleNode('Routes//ProductRoute[@ProductRouteID="' + lstRoute.options[lstRoute.selectedIndex].getAttribute('dbid') +  '"]');
			if (xmlElement != null && Number(xmlElement.getAttribute('ProductRouteID_Parent')) == 0){
			//Selected route isn't a child route, so record the change
				strXML += ChangeReportItemXML(ATTR_CHANGE_ROUTE, value_original, value_new);
			}			
		}
	
		//Dose
		strXML += CreateChangeReport_Dose();
	
		if (typeof(document.all['lstFrequency']) != 'undefined'){
		//Common fields
			strXML += CreateChangeReportItemXML('ScheduleTemplateID', ATTR_CHANGE_FREQUENCY , lstFrequency.options[lstFrequency.selectedIndex].innerText);
			
			//Duration; we treat the value and unit as a single field here.
			if (lstDurationUnits.selectedIndex > -1)
			{
				value_original = GetOriginalValue('Duration');
				value_new = txtDuration.value;
				unit_original = GetOriginalValue('UnitID_Duration');
				if ( !isNaN(Number(unit_original)) )
				{
					unit_original = Number(unit_original);
				}
				unit_new = lstDurationUnits.options[lstDurationUnits.selectedIndex].innerText;
				if ( !isNaN(Number(unit_new)) )
				{
					unit_new = Number(unit_new);
				}

				// F0042026
				// ST 14Jan09 Comparing '0' and ' ' cause a change report to be created so we'll wrap values up in a Number() function to get the real difference
				if (Number(value_original) != Number(value_new) || unit_original != unit_new)
				{
					strXML += ChangeReportItemXML(ATTR_CHANGE_DURATION, (value_original + ' ' + unit_original), (value_new + ' ' + unit_new));
				}
			}
				
			if (document.body.getAttribute('requesttype') == REQUESTTYPE_DOSELESS){
			//Doseless directions
				strXML += CreateChangeReportItemXML('DirectionText', ATTR_CHANGE_DIRECTION_DOSELESS, GetValueFromTextBoxOrLabel(txtDirection));
			}
			else {
			//Standard directions
				strXML += CreateChangeReportItemXML('SupplimentaryText', ATTR_CHANGE_DIRECTION, txtExtraFree.value);						//27Jul06 AE  Fix  #SC-06-0612
			}

			//Non-rate based infusion fields
			if (typeof (document.all['lstInfusionDuration']) != 'undefined')
			{
				//Infusion Duration		
				value_original = Number(GetOriginalValue(ATTR_INFUSIONDURATION));
				valuelow_original = Number(GetOriginalValue(ATTR_INFUSIONDURATIONLOW));
				unit_original = GetOriginalValue(ATTR_UNIT_DURATION);
				if (value_original == 0 && (unit_original == 0 || unit_original == '' || unit_original.toLowerCase() == 'unknown'))
				{
					strOrig = 'Give as Bolus';
				}
				else if (GetOriginalValue(ATTR_INFUSIONDURATION) != '')
				{
					strOrig = 'Infusion over ';
					strOrig += (valuelow_original == '') ? value_original : (valuelow_original + ' to ' + value_original);
					strOrig += ' ' + unit_original;
				}
				if (lstInfusionDuration.options[lstInfusionDuration.selectedIndex].value == 'duration')
				{
					unit_new = lstInfusionDurationUnits.options[lstInfusionDurationUnits.selectedIndex].innerText;
					if (txtInfusionDuration2.value != '')
					{
						value_new = Number(txtInfusionDuration2.value);
						valuelow_new = Number(txtInfusionDuration.value);
					}
					else
					{
						value_new = Number(txtInfusionDuration.value);
						valuelow_new = 0;
					}
					strNew = 'Infusion over ';
					strNew += (valuelow_new == '') ? value_new : (valuelow_new + ' to ' + value_new);
					strNew += ' ' + unit_new;
				}
				else
				{
					strNew = 'Give as Bolus';
				}

				if (strOrig != strNew)
				{
					strXML += ChangeReportItemXML(ATTR_CHANGE_DURATION_INFUSION, strOrig, strNew);
				}
			}
		}
		// 23-03-09 F0047361	Commenting out block of code below. There are still some big issues around red text so has been decided to cancel red text
		//						around rate based infusion data. A new spec is to be decided for 'proper' implementation in the next release.
//		else
//		{
//		//Rate-based Infusion fields
//			//Rate
//			objSelect = trRateStart.all['lstUnits'];
//			value_original = GetOriginalValue(ATTR_INFUSIONRATE);
//			value_new = txtInfusionRate.value;
//			unit_original = GetOriginalValue(ATTR_UNIT_RATEMASS);
//			unit_new = objSelect.options[objSelect.selectedIndex].innerText;
//			unittime_original = GetOriginalValue(ATTR_UNIT_RATETIME);
//			unittime_new = lstRateTime.options[lstRateTime.selectedIndex].innerText;
//			routine = GetOriginalValue(ATTR_ROUTINEID);

//			if(value_original != '' )
//			{
//			    if (routine == '' || routine == '0'){
//				    if (value_original != value_new || unit_original != unit_new || unittime_original != unittime_new){
//					    strOrig = value_original + ' ' + unit_original + ' per ' + unittime_original;														//13Mar07 AE  corrected text
//					    strNew = value_new + ' per ' + unit_new + ' per ' + unittime_new ;															//13Mar07 AE  corrected to set strNew here, not strOrig
//					    strXML += ChangeReportItemXML(ATTR_CHANGE_RATE, strOrig, strNew);
//				    }
//			    }
//			    else {																																					//13Mar07 AE  Deal properly with calculated rates
//			    //Calculated rates
//				    if (txtInfusionRate.getAttribute('dblrate_calculated') != txtInfusionRate.value || unit_original != unit_new || unittime_original != unittime_new){
//				    //Entered rate different from calculated rate	
//					    strOrig = 'calculated: ' + value_original + unit_original + ' per ' + routine + ' per ' + unittime_original
//							      + '\n= ' + txtInfusionRate.getAttribute('dblrate_calculated') + unit_original + ' per ' + unittime_original;
//					    strNew =  txtInfusionRate.value + ' ' + unit_new + ' per ' + unittime_new;
//					    strXML += ChangeReportItemXML(ATTR_CHANGE_RATE, strOrig, strNew);
//				    }
//			    }
//			}
//				
//			//Rate limits
//			value_original = GetOriginalValue(ATTR_INFUSIONRATEMIN);
//			valuelow_original = GetOriginalValue(ATTR_INFUSIONRATEMAX);
//			value_new = txtInfusionRateMax.value;
//			valuelow_new = txtInfusionRateMin.value;

//            if(value_original != '')
//            {
//                if (routine == '' || routine == '0') {
//				    if (value_original != value_new || valuelow_original != valuelow_new ){
//					    strOrig = valuelow_original + ' to ' + value_original + ' ' + unit_original + ' per ' + unittime_original;
//					    strNew = valuelow_new + ' to ' + value_new + ' ' + unit_new + ' per ' + unittime_new;	
//					    strXML += ChangeReportItemXML(ATTR_CHANGE_RATE_LIMITS, strOrig, strNew);
//				    }
//			    }
//			    else {
//			    //Calculated
//				    if (txtInfusionRateMin.getAttribute('dblrate_calculated') != valuelow_new || txtInfusionRateMax.getAttribute('dblrate_calculated') != value_new){
//					    strOrig = 'calculated: ' + value_original + ' to ' + valuelow_original + ' ' +  unit_original + ' per ' + routine + ' per ' + unittime_original;
//					    strOrig += '\n= ' + txtInfusionRateMin.getAttribute('dblrate_calculated') + ' to ' + txtInfusionRateMax.getAttribute('dblrate_calculated');
//					    strOrig += unit_original + ' per ' + unittime_original;
//					    strNew =  txtInfusionRateMin.value + ' to ' + txtInfusionRateMax.value + unit_new + ' per ' + unittime_new;
//					    strXML += ChangeReportItemXML(ATTR_CHANGE_RATE_LIMITS, strOrig, strNew);
//				    }
//			    }
//			}
//		}
//		
		
	//return as a <changes> document if we found any
		if (strXML != ''){
			strXML = '<' + XML_ELMT_CHANGEROOT + '>' + strXML + '</' + XML_ELMT_CHANGEROOT + '>';
			strReturn_XML  = '<attachednote type="' + NOTETYPE_CHANGEREPORT + '">'
							   + '<data>'
							   + FormatXML('XML', XMLEscape(strXML))
							   + '</data>'
							   + '</attachednote>';	
		}
	}
	
	return strReturn_XML;
	
}

//=======================================================================================================================

function CreateChangeReport_Dose(){

var strReturn = '';
	switch (document.body.getAttribute('requesttype')) {
		case REQUESTTYPE_STANDARD:
			strReturn = CreateChangeReport_Dose_Standard();
			break;

		case REQUESTTYPE_INFUSION:
			strReturn = CreateChangeReport_Dose_Infusion();
	}	

	return strReturn;
}

//=======================================================================================================================
function CreateChangeReport_Dose_Standard(){

//Creates text to show any changes to the dose which fall outside that specified in the template

//15Apr05 AE  Largely rewritten for new full-scale change reporting

var strRoutineDescription = '';
var strUnit = '';
var value_original = 0;												//Dose specified as an argument to the calculation, eg the 2 in 2mg/kg
var value_original_low = 0;										
var value_calculated = 0;											//Calculated value
var value_calculated_low = 0;										
var value_entered = 0;												//Value actually entered by the prescriber
var value_entered_low = 0;
var value_dosecap = 0;
var strReturn = '';
var strOriginal = '';
var strUnit_original = '';
var strEntered = '';

	if (txtDoseQty2.value != ''){
		value_entered_low = txtDoseQty.value;
		value_entered = txtDoseQty2.value;
	}
	else {
		value_entered = txtDoseQty.value;
		value_entered_low = 0;
	}
	
	var objSelect = trDose.all['lstUnits'];
//	var objSelect = tdDoseUnits.all['lstUnits'];
	strUnit = objSelect.options[objSelect.selectedIndex].innerText;
	strUnit_original = GetOriginalValue('UnitID_Dose');

	if (lblDrugName.getAttribute('iscalculateddose') == 'true') {
	//Calculated doses
		strRoutineDescription = lblDrugName.getAttribute('calculation_routinedescription');
		value_original = lblDrugName.getAttribute('calculation_dose');
		value_original_low = lblDrugName.getAttribute('calculation_doselow');
		value_calculated = lblDrugName.getAttribute('calculation_calculateddose');	
		value_calculated_low = lblDrugName.getAttribute('calculation_calculateddoselow');	
		value_dosecap = txtDoseCap.getAttribute("DoseCap_Converted");
		strReturn = CreateChangeReport_Dose_XML(0, '', strRoutineDescription, strUnit_original, strUnit, value_original, value_original_low, value_calculated, value_calculated_low, value_entered, value_entered_low, value_dosecap);	// AI 11/01/2008 Migrated code
	}
	else {
	//non-calculated doses
		value_original = GetOriginalValue('Dose');
		value_original_low = GetOriginalValue('DoseLow');		
		value_dosecap = txtDoseCap.getAttribute("DoseCap_Converted");
		strReturn = CreateChangeReport_Dose_XML(0, '', '', strUnit_original, strUnit,  value_original, value_original_low, 0, 0, value_entered, value_entered_low, value_dosecap);// AI 11/01/2008 Migrated Code

	}
		
	return strReturn;																													
}

//=======================================================================================================================
function CreateChangeReport_Dose_Infusion(){

//Creates text to show any changes to the dose which fall outside that specified in the template, for each Drug in the formula.
//07Feb05 AE 
//15Apr05 AE  Largely rewritten for new full-scale change reporting

var objRow;
var objSelect;
var lngRoutineID = 0;
var strRoutineDescription = '';
var lngProductID = 0;
var strReturn = '';
var strDrug = '';
var strUnit = '';
var value_original = 0;												//Dose specified as an argument to the calculation, eg the 2 in 2mg/kg
var value_calculated = 0;											//Calculated value
var value_entered = 0;												//Value actually entered by the prescriber
var unit_original = '';
var unit_entered = '';

	for (intCount=1;intCount < tblIngredients.rows.length; intCount++){
	//Get a reference to this row and the corresponding product element in the xml
		objRow = tblIngredients.rows[intCount].all['trDose_Infusion'];
		if (typeof(objRow) != 'undefined') {	
		//If this row has a routineid attribute, it will contain a calculated dose.
			lngProductID = objRow.getAttribute('productid');		
			strProduct = objRow.parentElement.parentElement.parentElement.parentElement.all['tdIngredientName'].innerText;	
			lngRoutineID = objRow.getAttribute('routineid');			
			value_original = objRow.getAttribute('dose_original');
			value_entered = objRow.all['txtDose'].value;
			objSelect = objRow.all['lstUnits'];
			unit_entered = objSelect.options[objSelect.selectedIndex].innerText;
			unit_original = objRow.getAttribute('unit_original');

			
			if (Number(lngRoutineID) > 0){
			//Add the name of each product if there is more than one
				if (tblIngredients.rows.length > 2)	strReturn += tblIngredients.rows[intCount].all['tdIngredientName'].innerText + ':\n';
			
			//Now build the calculation description
				strRoutineDescription = objRow.getAttribute('routinedescription');
				value_calculated = objRow.getAttribute('dose_calculated');
				strDrug = CreateChangeReport_Dose_XML(lngProductID, strProduct, strRoutineDescription, unit_original, unit_entered, value_original, 0, value_calculated, 0, value_entered, 0);

				strReturn += strDrug;
			}
			else {
			//non-calculated dose, just show any differences
				strReturn = CreateChangeReport_Dose_XML(lngProductID, strProduct, '', unit_original, unit_entered, value_original, 0, 0, 0, value_entered, 0);
			}						
		}
	}	
	return strReturn;
}

//=======================================================================================================================
function CreateChangeReport_Dose_XML(lngProductID, strProductName, strRoutine, unit_original, unit_entered, value_original, value_original_low, value_calculated, value_calculated_low, value_entered, value_entered_low, value_dosecap){ // AI 11/01/2008 Migrated Code

//Determine if the entered dose deviates from that specified, and if so, builds a report describing it.

//lngProductID:  				ID of the product that this dose relates to.  Only needed for infusion types (as these can have
//									multiple drugs), pass 0 for others.
//strRoutine:					Name of the routine used in the calculation, if one was specified; otherwise blank string.
//strUnit:						Abbreviation of the unit in which the dose was specified.
//value_original:				Values specified in the template
//value_original_low:
//value_calculated:			Values calculated; pass 0 if no calculation was done
//value_calculated_low:
//value_entered:				Values currently entered by the user.
//value_entered_low:
//value_dosecap

var strReturn = '';
var strOriginal = '';
var strEntered = '';
var strProductAttributes = '';
var blnMakeReport = false;
var xmlUnit_original;
var xmlUnit_entered;
var multiple_original = 1;
var multiple_entered = 1;


//Determine if we want to create a report (only if an entered value differs from the
//dose specified)
	var blnWasRange = (Number(value_original_low) > 0) ;																										//If the template specified a range
	var blnIsRange = (Number(value_entered_low) > 0);																											//If a range has been entered
	if ((blnIsRange && blnWasRange) || (!blnIsRange && !blnWasRange)){																											//11Nov05 AE  Explicit conversion to Number before comparison.
		if ((Number(value_calculated) > 0) && (Number(value_calculated) != Number(value_entered))) blnMakeReport = true;											//28Apr05 AE  Restructured so that it, like, works and stuff	
		if ((Number(value_calculated_low) > 0) && (Number(value_calculated_low) != Number(value_entered_low))) blnMakeReport = true;								
		if ((Number(value_calculated) == 0) && (Number(value_original) != Number(value_entered))) blnMakeReport = true;											//04May05 AE  Ooops...missed uncalculated doses
		if ((Number(value_calculated) == 0) && (Number(value_original_low) != Number(value_entered_low))) blnMakeReport = true;
		if (Number(value_original) == 0) blnMakeReport = false;																														//18Nov05 AE  #83739  Don't make report if dose not specified in template.  Prevents "infinity % higher" message
	}
	if (blnIsRange && !blnWasRange) blnMakeReport = true;
	if (!blnIsRange && blnWasRange){
		if (value_entered < value_calculated_low || value_entered > value_calculated) blnMakeReport = true;
	}

	if (unit_original != '' && (unit_original != unit_entered)){
	//Unit change; convert the entered values into the original unit for comparison
	//Note that this may be due to one unit being an id and the other a description...
		if (IsNumeric(unit_original)){																																	//28Apr05 AE  Deal with units in old templates being just an ID
			xmlUnit_original = unitsData.selectSingleNode('//unit[@id="' + unit_original + '"]');
			unit_original = xmlUnit_original.getAttribute('description');
		}
		else {
			xmlUnit_original = unitsData.selectSingleNode('//unit[@description="' + unit_original + '"]');
		}
		if (IsNumeric(unit_entered)){
			xmlUnit_entered = unitsData.selectSingleNode('//unit[@id="' + unit_entered + '"]');
			unit_entered = xmlUnit_entered.getAttribute('description');
		}
		else{
			xmlUnit_entered = unitsData.selectSingleNode('//unit[@description="' + unit_entered + '"]');
		}
		
		//Now check if we really have a different unit
		blnMakeReport = (blnMakeReport || (unit_original != unit_entered));																					//04May05 AE  Added "blnMakeReport ||"; don't let this switch set blnMakeReport back to false
		
		//Obtain the multiple to do the conversion; AMPs and above will not have multiples, since their
		//units are forms and packages, not actual units
		multiple_entered = xmlUnit_entered.getAttribute('multiple');
		if (xmlUnit_original != null) 
		{
		    multiple_original = xmlUnit_original.getAttribute('multiple');
		    if (multiple_original != null && multiple_entered != null) {																								//28Apr05 AE  Handle AMPs and above
		        value_entered = value_entered * (multiple_entered / multiple_original);
		        value_entered_low = value_entered_low * (multiple_entered / multiple_original);
		    }
		}
	}
//Make the report if required.
	if (blnMakeReport){														
		strOriginal = blnWasRange ? (value_original_low.toString() + ' to ' + value_original.toString()) : value_original.toString();		
		strOriginal += ' ' + unit_original;
		if (strRoutine != ''){																																				//28Jul06 AE  Modify to improve reporting when calculation couldn't be performed #SC-06-0377
			//Calculation specified
			strOriginal = 'dose specified: ' + strOriginal + ' per ' + strRoutine + '\n';

			if ((blnWasRange && value_calculated_low == 0) || (!blnWasRange && value_calculated == 0)){
			//Dose could not be calculated, or calculation came out as 0
				strOriginal += ' The dose could not be calculated, and was entered manually';
			}
			else {			
				//The dose which was calculated
				strOriginal += '= '
				strOriginal += blnWasRange ? (value_calculated_low.toString() + ' to ' + value_calculated.toString()) : value_calculated.toString();
				strOriginal += ' ' + unit_original + '\n';
				strOriginal += CreateChangeReport_DoseDifference(blnWasRange, blnIsRange, value_calculated_low, value_calculated, value_entered_low, value_entered);
			}
		}
		else
		{
		    if (strOriginal != " ")
		    {
		        strOriginal = '(was ' + strOriginal + ')\n'; 																										//25Aug06 AE  Prevent unit appearing twice
		        strOriginal += CreateChangeReport_DoseDifference(blnWasRange, blnIsRange, value_original_low, value_original, value_entered_low, value_entered);
		    }
		}
				
		//What has been entered
		strEntered = blnIsRange ? (value_entered_low.toString() + ' to ' + value_entered.toString()) : value_entered.toString();		
		strEntered += ' ' + unit_entered ;
		
		if (Number(lngProductID) > 0) strProductAttributes = ('productid="' + lngProductID + '" product="' + strProduct + '" ');
		strProductAttributes += ATTR_ISCALCULATED + '="1"'
		strReturn = ChangeReportItemXML(ATTR_CHANGE_DOSE, strOriginal, strEntered, strProductAttributes);

	}	

	// 21Oct07 PH Dose capping
	if (value_dosecap>0) // There was a dose cap
	{
		if (value_calculated>value_dosecap || value_calculated_low>value_dosecap )
		{
			strReturn += ChangeReportItemXML(ATTR_CHANGE_DOSECAP_CALCULATED, value_dosecap, 0, strProductAttributes);
		}
		if (value_entered>value_dosecap || value_entered_low>value_dosecap)
		{
			strReturn += ChangeReportItemXML(ATTR_CHANGE_DOSECAP_ENTERED, value_dosecap, 0, strProductAttributes);
		}
	}

	return strReturn;
}

//=======================================================================================================================
function CreateChangeReport_DoseDifference(blnWasRange, blnIsRange, valuelow_original, value_original, valuelow_entered, value_entered){

//Build text to describe the percentage difference between what was entered and what was specified/calculated in the template.
//
//blnWasRange:					//True if the dose specified was a range
//blnIsRange:					//True if the dose entered is a range
//value_original:				Values specified
//value_original_low:
//value_entered:				Values currently entered by the user.
//value_entered_low:

var difference = 0;
var percentage = 0;
var strReturn = '';

	valuelow_original = Number(valuelow_original);
	value_original = Number(value_original);
	valuelow_entered = Number(valuelow_entered);
	value_entered = Number(value_entered);

	if (blnIsRange){
		if (blnWasRange){
		//a range was specified, a range was entered
		    difference = valuelow_entered - valuelow_original;
		    if (valuelow_original < difference && valuelow_original != 0)
		    {
		        percentage = (Math.abs(difference) / valuelow_original) * 100;
		    }
		    else
		    {
		        percentage = 0;
		    }
		}
		else {
		//A single value was specified, a range was entered
		    difference = valuelow_entered - value_original;
		    if (value_original < difference && value_original != 0)
		    {
		        percentage = (Math.abs(difference) / value_original) * 100;
		    }
		    else
		    {
		        percentage = 0;
		    }
		}

		if (percentage != 0)
		{
		    percentage = Number(percentage).toFixed(1);
		    strReturn += percentage.toString() + '% ' + (difference > 0 ? 'higher' : 'lower');
		}
	}

	if (!blnWasRange && (blnIsRange || (Number(value_original) != Number(value_entered)))){
	//Single value specified, or the upper value of a range
		difference = value_entered - value_original;

		if (value_original < difference && value_original != 0)
		{
		    percentage = (Math.abs(difference) / value_original) * 100;
		    percentage = Number(percentage).toFixed(1);
		}
		else
		{
		    percentage = 0
		}


		if (blnIsRange && percentage != 0)
		{
		    //Range specified, range entered
		    strReturn += ' and ';
		}

		if (percentage != 0)
		{
		    strReturn += percentage.toString() + '% ' + (difference > 0 ? 'higher' : 'lower');
		}
	}
	
	if (blnWasRange && !blnIsRange){
	//Range specified in template, only one value entered
	//Indicate if the entered value is outside the range specified.
		difference = 0;
		if (value_entered < valuelow_original){
		//Value entered is below the range specified
		    difference = value_entered - valuelow_original;
		    if (valuelow_original < difference && valuelow_original != 0)
		    {
		        percentage = (Math.abs(difference) / valuelow_original) * 100;
		    }
		    else
		    {
		        percentage = 0;
		    }
		}
			
		if (value_entered > value_original){
		//Value entered is above the range specified
		    difference = value_entered - value_original;
		    if (value_original < difference && value_original != 0)
		    {
		        percentage = (Math.abs(difference) / value_original) * 100;
		    }
		    else
		    {
		        percentage = 0;
		    }
		}
			
		if (difference != 0){
		//Value was outside the range
		    percentage = Number(percentage).toFixed(1);
		    if (percentage != 0)
		    {
		        strReturn += percentage.toString() + '% ' + (difference > 0 ? 'above' : 'below') + ' this range';
		    }
		}
	}

	if (strReturn != ''){
		//Dose actually entered
		strReturn = 'The dose' + (blnIsRange ? 's' : '') + ' entered ' + (blnIsRange ? 'are ' : 'is ') + strReturn;		
	}

	return strReturn;
}

//=======================================================================================================================

function ShowChangeReport(){

//Called during Populate.
//Displays original values next to any fields which have been changed; 	

var intCount = 0;
var fieldName = '';
var strText = '';
var strXML = '';
var xmlElement;
var xmlElement2;
var xmlElementUnit;
var xmlElementUnit2;
var strWarning = '';
var strUnit = '';

//don't show when doing a copy

if (CopyMode()) return;														
	xmlElement = instanceData.XMLDocument.selectSingleNode('//data/attachednote[@type="' + NOTETYPE_CHANGEREPORT + '"]');
	if (xmlElement != undefined) {
		//Load the change report (if any) into an XML Island for parsing
		xmlElement2 = xmlElement.selectSingleNode('data/attribute[@name="XML"]');
		strXML = XMLReturn(xmlElement2.getAttribute('value'));
		if (changesData.XMLDocument.loadXML(strXML)){	
			//And process eet.
			var xmlChanges = changesData.XMLDocument.selectSingleNode('//' + XML_ELMT_CHANGEROOT );
			var colChanges = xmlChanges.selectNodes(XML_ELMT_CHANGE);
			for (intCount = 0; intCount < colChanges.length; intCount ++){
			//Loop through each change and display each as appropriate
				fieldName = colChanges[intCount].getAttribute(ATTR_CHANGE_ID);
				strText = colChanges[intCount].getAttribute(ATTR_CHANGE_ORIGINAL);
				switch (fieldName){
					case ATTR_CHANGE_ROUTE:
					//Route
						tdCompare_Route.innerText = ChangeText(strText);
						break;
						
					case ATTR_CHANGE_FREQUENCY:
					//Frequency
						tdCompare_Frequency.innerText = ChangeText(strText);
						break;				
						
					case ATTR_CHANGE_DIRECTION_DOSELESS:
					//Doseless directions		
						tdCompare_Directions.innerText = ChangeText(strText);
						break;
		
					case ATTR_CHANGE_DIRECTION:
					//Standard directions		
						tdCompare_Extra.innerText = ChangeText(strText);
						break;

		            case ATTR_CHANGE_DURATION:
		                //Prescription Duration
		                //F0047361 ST 12Mar09
		                //Added check for a 0 duration as it would actually have been blank on the form so we don't want
		                //to display (was 0) as a change.
		                
		                if (trim(strText) != "0")
            		        tdCompare_Duration.innerText = ChangeText(strText);
		            
                        break;
										
					case ATTR_CHANGE_DOSE:
						void ShowChangeReport_Dose(colChanges[intCount]);	
						break;				
						
					case ATTR_CHANGE_DURATION_INFUSION:
					    if ( strText != '' )
						    tdCompare_InfusionDuration.innerText = ChangeText(strText);
						break;
		
					case ATTR_CHANGE_RATE:
						tdCompare_RateStart.innerText = ChangeText(strText);
						break;
		
					case ATTR_CHANGE_RATE_LIMITS:
						tdCompare_RateVary.innerText = ChangeText(strText);
						break;
						
					case ATTR_CHANGE_DOSECAP_CALCULATED:
						tdCompare_Dose.innerHTML += "<br/>Calculated Dose too High, Dose was capped at " + strText;
						break;

					case ATTR_CHANGE_DOSECAP_ENTERED:
						tdCompare_Dose.innerHTML += "<br/>Entered Dose exceeds cap value of " +  + strText;
						break;
				}
			}
		}
	}	
}

//=======================================================================================================================
function ShowChangeReport_Dose(xmlElement){

//Show the dose change report next to each dose field; in the case of
//infusions, we may have multiple dose fields.
var objRow;
var intCount = 0;
var blnCalculated = false;

	switch (document.body.getAttribute('requesttype')) {
		case REQUESTTYPE_STANDARD:
		//Simple, single product standard prescription
			blnCalculated = (xmlElement.getAttribute(ATTR_ISCALCULATED) == '1');
			tdCompare_Dose.innerText = blnCalculated ? xmlElement.getAttribute(ATTR_CHANGE_ORIGINAL) : ChangeText(xmlElement.getAttribute(ATTR_CHANGE_ORIGINAL));
			break;

		case REQUESTTYPE_INFUSION:
		//Infusions can have multiple products; each dose element is tagged
		//with the productID to which it refers.

			var productID = xmlElement.getAttribute('productid');

			for (intCount=1;intCount < tblIngredients.rows.length; intCount++){
			//Get a reference to this row and the corresponding product element in the xml
				objRow = tblIngredients.rows[intCount].all['trDose_Infusion'];
				if (typeof(objRow) != 'undefined') {	
					if (Number(objRow.getAttribute('productid')) == Number(productID)){
					//found it	
						objRow.all['tdCompare_Dose'].innerText = xmlElement.getAttribute(ATTR_CHANGE_ORIGINAL);
						break;
					}
				}
			}
			break;
	}
	
}

//=======================================================================================================================
function ChangeText(strText)
{
    if (strText != " ")
    {
        return '(was ' + strText + ')';
    }
    return("");
}

//=======================================================================================================================
function PopulateDispensingInstruction(){

//When the form is being loaded, check the XML for a DispensingInstruction element, 
//and populate the dispensing instructions area if it's found.

var xmlElement;
var strText = '';

	if (document.body.getAttribute('copydispensinginstruction') != 'true'){																		//13Mar07 AE  Made configurable
	//don't populate when doing a copy	
		if (document.body.getAttribute('dataclass') == 'request' && !DisplayMode()) return;													//13Apr05 AE  Corrected; added !DisplayMode()  06Apr05 AE  Don't do if we're doing a copy of a committed prescription
	}
	
	var objElement = instanceData.XMLDocument.selectSingleNode('//attachednote[@type="Dispensing Instruction"]');					//04Oct06 AE  Corrected XPath to ensure notes are repopulated correctly
	if (objElement != undefined) {
		var objAttribute = objElement.selectSingleNode('data/attribute[@name="Detail"]')
		txtPharmacyDirections.value = XMLReturn(objAttribute.getAttribute('value'));
	}
}
//=======================================================================================================================
function PopulateDoseCalculationXML()
{
	var objData = calculatedDoseXML.XMLDocument.selectSingleNode("//ascribe_dss_calculation");
	
	if(objData != null)
	{
		calculatedDoseXML.XMLDocument.loadXML(objData.xml)
	}
	
}
//=======================================================================================================================
//											Misc Internal functions
//=======================================================================================================================

function TextPickerFeatures() {

	var intHeight = screen.height / 1.5;
	var intWidth = screen.width / 2.5;
	
	if (intHeight < 600) {intHeight=600;}
	if (intWidth < 600) {intWidth=600;}
	
	var strFeatures = 	'dialogHeight:' + intHeight + 'px;' 
							 + 'dialogWidth:' + intWidth + 'px;'
							 + 'resizable:yes;unadorned:yes;'
							 + 'status:no;help:no;';		

	return strFeatures;

}

//=======================================================================================================================
function DisplayMode() {
//Returns true if we are in display mode
	return (document.body.getAttribute('displaymode') == 'true');	
}
//=======================================================================================================================

function CopyMode(){
//Returns true if we are creating a copy.
	var strClass = document.body.getAttribute('dataclass');
	return ( (strClass == 'request' || strClass == 'note') && !DisplayMode() );
}

//=======================================================================================================================
function UpdatePrescriptionMetadata(strRequestType) {

//Finds the request type ID and TableID of the given request type, 
//and updates the metadata held in the xml island on OrderEntry to match.
//Used when we change the prescription type, for eg from standard to doseless.
//16Sep04 AE  Written

	//First find the request type in our xml island
	var xmlElement = requesttypeData.XMLDocument.selectSingleNode('//RequestType[@Description="' + strRequestType + '"]');
	if (xmlElement != null) {
		var lngTableID = xmlElement.getAttribute('TableID');
		var lngRequestTypeID = xmlElement.getAttribute('RequestTypeID');	
		void UpdateOrderformMetadata('request', lngRequestTypeID, lngTableID);
	}
			
	return xmlElement;
}
//=======================================================================================================================
//						PrescriptionAsk script
//=======================================================================================================================

function TypeSelected(strType) {

//Navigate to either the Prescription form or the PrescriptionInfusion form.	

var thisAttribute = '';
var strContinuous = '';

	var strURL = document.URL;
	var strQuerystring = strURL.substring(strURL.indexOf('?') + 1,strURL.length);

	switch (strType.toLowerCase()){
		case 'infusion_continuous':
			strContinuous = '&Continuous=1';														
			//No break here because we deliberately want to run into the next case!
			
		case 'infusion_intermittent':
		//Update the prescription metadata to point at the infusion data type
			var xmlElement = UpdatePrescriptionMetadata(REQUESTTYPE_INFUSION);
	
		//Swap the table id in the querystring for the one specifying the infusion table
			var astrQS = strQuerystring.split('&');
			strQuerystring = '';
			
			for (intCount=0; intCount < astrQS.length; intCount++) {
				if (strQuerystring != '') strQuerystring += '&';
				
				thisAttribute = astrQS[intCount].split('=')[0];
				if (thisAttribute.toLowerCase() == 'tableid'){
					strQuerystring += 'tableid=' + xmlElement.getAttribute('TableID');	
				}
				else {
					strQuerystring += astrQS[intCount];
				}
			}			
			break;

	}
	
//Now refresh the page
	strURL = 'Prescription.aspx' 
			 + '?' + strQuerystring
			 + '&ask=false'
			 + strContinuous;
			 
	void window.navigate(strURL);

}

//=======================================================================================================================
//								PrescriptionInfusion Script
//
//
//=======================================================================================================================

function FormulaDescriptionChange(strDescription){

//Update the description with that built by the formula page
	lblDrugName.innerText = strDescription
		
}

//=======================================================================================================================
function DoseRoutineChange(objSrc) {

//Fires when the DSS routine box on the dose of a drug changes.
//We only enable the "per time" list (only on the primary drug in continuous infusions)
//if a routine has been chosen.

	var objTR = GetTRFromChild(objSrc);
	var blnEnable = (objSrc.selectedIndex > 0);

	if (!blnEnable) objTR.all['lstDoseRateTime'].selectedIndex = 0;
	objTR.all['lstDoseRateTime'].disabled = !blnEnable;	
	tdDoseRateLabel.disabled = !blnEnable;

    DescriptionChangeRequired ();  // Call to change description for bug fix F0023374	
}

//=======================================================================================================================
function EnableVariableRate(){

//Fires when the "vary between" checkbox in the Rate section is clicked; 
//enables/disables the max/min rate boxes.

	var blnEnable = (chkVaryRate.checked);
	if (blnEnable){
		txtInfusionRateMin.className = 'MandatoryField';
		txtInfusionRateMax.className = 'MandatoryField';		
		trRateLabel.innerText = 'Starting Rate:';
	}
	else {
		txtInfusionRateMin.className = 'DisabledField';
		txtInfusionRateMax.className = 'DisabledField';		
		txtInfusionRateMin.value = '';
		txtInfusionRateMax.value = '';
		trRateLabel.innerText = 'Rate:';
	}
	txtInfusionRateMin.disabled = !blnEnable;
	txtInfusionRateMax.disabled = !blnEnable;
	void UpdateRateLabel();
	
	
}

//=============================================================================================================================================
function UpdateRateLabel(){

//When the rate unit boxes are changed, updates the label on the "vary between" line
//which is a repeat of what's in the boxes.
//21Mar05 AE  Added support for calculated rate

	if (typeof(document.all['tdRateUnitLabel']) != 'undefined') {
		tdRateUnitLabel.innerText = '';
		if (chkVaryRate.checked){
			if (trRateStart.all['lstUnits'].selectedIndex > 0){			
				tdRateUnitLabel.innerText = trRateStart.all['lstUnits'].options[trRateStart.all['lstUnits'].selectedIndex].innerText;
				
				if ((trRateStart.all['lstRoutine'] != undefined) && trRateStart.all['lstRoutine'].selectedIndex > 0){
					tdRateUnitLabel.innerText += ' per '
													  + trRateStart.all['lstRoutine'].options[trRateStart.all['lstRoutine'].selectedIndex].innerText;
				}
													  
				
				if (lstRateTime.selectedIndex > 0){
					tdRateUnitLabel.innerText += ' per '
									 				  + lstRateTime.options[lstRateTime.selectedIndex].innerText;
				}
			}
		}							
	}		
	
    DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}

//=============================================================================================================================================
function InfusionDurationChange(){

//Show or hide the infusion duration controls as they change between "give as bolus"
//and "give as infusion over"
var intCount = 0;

	var blnShow = (lstInfusionDuration.options[lstInfusionDuration.selectedIndex].value == 'duration');
	for (intCount = 0; intCount < tdOver.length; intCount++){
		tdOver[intCount].style.visibility = GetVisibilityString(blnShow);	
	}
	if (!blnShow){
		txtInfusionDuration.value = 0;
		txtInfusionDuration2.value = ''; //F0025167
	}
	
  DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}

//=============================================================================================================================================
function UpdateRoundingLabel(objSrc){

//As the dose unit changes, so the units label on the rounding control is set to match.
//Note that this only happens in template mode; when actually prescribing, the rounding unit
//is fixed to that specified in the template
	if (m_blnTemplateMode){
		var objTR = GetTRFromChild(objSrc);
		var objSelect = objTR.all['lstUnits'];
		var objText = objTR.all['txtRoundValue'];	
		if (typeof(objText) != 'undefined'){
			objTR.all['lblRoundUnit'].innerText = objSelect.options[objSelect.selectedIndex].innerText;
			objTR.all['lblRoundUnit'].setAttribute('dbid', objSelect.options[objSelect.selectedIndex].getAttribute('dbid'));
		}
	}	
			
	UpdateDoseCapLabel(objSrc);
	UpdateDoseOptionsLabel(objSrc);
    DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
}
//=============================================================================================================================================

function UpdateDoseCapLabel(objSrc) {
    //As the dose unit changes, so the units label on the dose cap control is set to match.
    //Note that this only happens in template mode; when actually prescribing, the rounding unit
    //is fixed to that specified in the template
    if (m_blnTemplateMode) {
        var objTR = GetTRFromChild(objSrc);
        var objSelect = objTR.all['lstUnits'];
        var objText = objTR.all['txtDoseCap'];

        if (typeof (objText) == 'undefined') {
            objText = document.getElementById('txtDoseCap');
            document.getElementById('lblDoseCapUnit').innerText = objSelect.options[objSelect.selectedIndex].innerText;
            document.getElementById('lblDoseCapUnit').setAttribute('dbid', objSelect.options[objSelect.selectedIndex].getAttribute('dbid'));
        }
        else {
            objTR.all['lblDoseCapUnit'].innerText = objSelect.options[objSelect.selectedIndex].innerText;
            objTR.all['lblDoseCapUnit'].setAttribute('dbid', objSelect.options[objSelect.selectedIndex].getAttribute('dbid'));
        }
    }
}
//=============================================================================================================================================

function EnableRoundingControls(objSrc){

//If a dss routine has been selected, the rounding control is enabled; otherwise, 
//it is disabled	
	if (objSrc != undefined){																									//11Apr05 AE  isn't scripted in view mode
		objRow = GetTableFromChild(objSrc);																						//02Jun08 AE  Handle multiple rows
		var blnDisabled = (objSrc.selectedIndex == 0);
		var strClass = blnDisabled ? 'DisabledField':'StandardField';
		objRow.all['lblRoundTitle'].disabled = blnDisabled;
		if (blnDisabled) objRow.all['txtRoundValue'].value = '';
		objRow.all['txtRoundValue'].disabled = blnDisabled;
		objRow.all['txtRoundValue'].className = strClass;
		objRow.all['lblRoundUnit'].disabled = blnDisabled;
		
		objRow.all['lnkDoseCapOverridable'].disabled = blnDisabled;
		objRow.all['txtDoseCap'].disabled = blnDisabled;
		
		if(blnDisabled) 
		{
		    objRow.all['tdDoseOptions'].style.visibility = 'hidden';
		}
		else
		{
		    objRow.all['tdDoseOptions'].style.visibility = 'visible';
		}
		
		if (!blnDisabled) void UpdateRoundingLabel(objSrc);
	}
}

//=============================================================================================================================================
//														Data Load/Save
//=============================================================================================================================================
function ValidityCheck_Infusion() {	

//Determines if the data which has been entered is valid (ranges run the right way etc).
//25Jan05 AE  Prevent incorrect dose warnings in template mode.

var intCount = 0;
var objRow;
var blnDose = false;
var blnUnit = false;
var blnRoutine = false;
var blnPerTime = false;
var blnValid = true;
var strMsg = '';

	for (intCount=1;intCount < tblIngredients.rows.length; intCount++){
	//Get a reference to this row and the corresponding product element in the xml
		objRow = tblIngredients.rows[intCount];

		//Check that each row has no boxes filled in, or they are filled in correctly.
		if (typeof(objRow.all['txtDose']) != 'undefined'){
			//Determine what we've got on this row...
			blnDose = (objRow.all['txtDose'].value != '');
			blnUnit = (objRow.all['lstUnits'].selectedIndex != -1) && (Number(objRow.all['lstUnits'].options[objRow.all['lstUnits'].selectedIndex].getAttribute('dbid')) >= 0);
			blnRoutine = false;
			if (m_blnTemplateMode){
				blnRoutine = (Number(objRow.all['lstRoutine'].options[objRow.all['lstRoutine'].selectedIndex].getAttribute('dbid')) > 0);			//25Jan05 AE Corrected >= to >
			}

			//Now work out if it's valid or not
			strMsg = ''
			if (blnDose && !blnUnit){																			//Dose with no unit
				blnValid = false;													
				strMsg = 'You must enter a Dosing Unit';
			}
			if (blnRoutine && (!blnUnit || !blnDose)){ 													//Routine with no unit or dose
				blnValid = false;													
				strMsg = 'You must enter a Dose and Dosing Unit';
			}

			objRow.all['tdWarning'].innerHTML = strMsg;

			var dblDoseCap = parseFloat(objRow.all['txtDoseCap'].getAttribute("DoseCap_Converted"));
			var strDoseCapUnit = objRow.all['txtDoseCap'].getAttribute("DoseCapUnitName_Converted");
			var dblDose = parseFloat(objRow.all['txtDose'].value);

			var blnCapOverridable = (objRow.all['lnkDoseCapOverridable'].getAttribute("override")=="1")
			
			if (dblDoseCap > 0 && !blnCapOverridable)
			{
				// Checks that the dose(s) have not exceed the cap.
				if ( dblDose > dblDoseCap )
				{
					var strMsg = "The dose cannot exceed " + dblDoseCap + " " + strDoseCapUnit + ".";
					alert(strMsg);
					return false;
				}
			}
		}	
	}
	blnValid = blnValid && InfusionDurationValidityCheck();

	if (!DateValidityCheck(txtStartDate))
	{
		blnValid = false;
		trDateFormatWarning_StartDate.style.display = 'block';
	}

	if (!DateValidityCheck(txtStopDate))
	{
		blnValid = false;
		trDateFormatWarning_StopDate.style.display = 'block';
	}

	if (!DateRangeValid())
	{
		trDateWarning.style.display = 'block';
		blnValid = false
	}

	if (!DurationValidityCheck())
	{																							//22May06 AE  Added duration checks #SC-06-0541
		blnValid = false;
	}

    return blnValid;
}

//====================================================================================================================================
function ReadDataFromForm_Infusion() {

//Read the data from the infusion form
//21Mar05 AE  Added support for calculated rates
//14Mar07 AE  Store text of rate units so that change report will work correctly.
var strXML = '';		
	
var intCount = 0;
var value1 = 0;
var value2 = 0;
var blnIsContinuous = false;
var lngUnitID_InfusionDuration = 0;
var strText = '';
	
//Sync our ingredients xml island with the on-screen data
	UpdateProductXML();
	
//Sync our diluent xml island with the on-screen data
    UpdateDiluentXML();

//Add our ingredient list to the XML
	strXML += infusionProducts.XMLDocument.xml;
	
//Add any diluent to the XML
    strXML += infusionDiluent.XMLDocument.xml;

//And record a productID of 0
	strXML += FormatXML('ProductID', 0, '');	

//Infusion rate (continuous only)
	if (IsContinuous()) {
	    blnIsContinuous = true;
	    //F0047763 ST 10Mar09
	    //Multiple people have done multiple changes to this code to prevent the infusion rate from being recalculated when editing diluents
	    //I've commented out all of this code and replaced with the original code that was working and added a parameter to the form submit
	    //function when editing diluents elsewhere in this code.
	    
	    //F0039091
	    //A previous fix breaks the calculated infusion prescriptions, however reverting the code back to the original reintroduces a previous bug when the prescription page is refreshed.
	    //if (Number(txtInfusionRate.value) > 0)
	    //{
        //  if (Number(document.getElementById("txtInfusionRate").getAttribute("dblRate_Calculated")) > 0)
        //  {
        //	    strXML += FormatXML(ATTR_INFUSIONRATE, txtInfusionRate.value, undefined, 'IsCalculated="true"');
        //	}
        //	else
        //	{
        //	    strXML += FormatXML(ATTR_INFUSIONRATE, txtInfusionRate.value, undefined, 'IsCalculated="false"');
        //	}

	        //strXML += FormatXML(ATTR_INFUSIONRATE, txtInfusionRate.value, undefined, 'IsCalculated="false"');
	        strXML += FormatXML(ATTR_INFUSIONRATE, txtInfusionRate.value);
	        strXML += FormatXML(ATTR_INFUSIONRATE_ORIGINAL, txtInfusionRate.getAttribute('dblrate_original')); 					//21Mar05 AE  Added support for calculated rates
	        strXML += FormatXML(ATTR_INFUSIONRATE_CALCULATED, txtInfusionRate.getAttribute('dblrate_calculated'));
        //}
				
		if (chkVaryRate.checked){
			strXML += FormatXML(ATTR_INFUSIONRATEMIN, txtInfusionRateMin.value);
			strXML += FormatXML(ATTR_INFUSIONRATEMIN_ORIGINAL, txtInfusionRateMin.getAttribute('dblrate_original'));			//21Mar05 AE  Added support for calculated rates
			strXML += FormatXML(ATTR_INFUSIONRATEMIN_CALCULATED, txtInfusionRateMin.getAttribute('dblrate_calculated'));		

			strXML += FormatXML(ATTR_INFUSIONRATEMAX, txtInfusionRateMax.value);
			strXML += FormatXML(ATTR_INFUSIONRATEMAX_ORIGINAL, txtInfusionRateMax.getAttribute('dblrate_original'));			//21Mar05 AE  Added support for calculated rates
			strXML += FormatXML(ATTR_INFUSIONRATEMAX_CALCULATED, txtInfusionRateMax.getAttribute('dblrate_calculated'));		

		}		
		//Routine in the rate (eg, kg in "mg/Kg/min")
		objSelect = trRateStart.all['lstRoutine'];
		if (typeof(objSelect) != 'undefined'){
			strXML += FormatXML(ATTR_ROUTINEID, objSelect.options[objSelect.selectedIndex].getAttribute('dbid'), objSelect.options[objSelect.selectedIndex].innerText)
		}
		else
		{
		    // get the correct value form the row
		    strXML += FormatXML(ATTR_ROUTINEID, trRateStart.getAttribute('routineid'))
		}

		//Mass unit of the rate (eg, mg in "mg/Kg/min")
		objSelect = trRateStart.all['lstUnits'];
		strXML += FormatXML(ATTR_UNIT_RATEMASS, objSelect.options[objSelect.selectedIndex].getAttribute('dbid'), objSelect.options[objSelect.selectedIndex].innerText);
	
		//Time unit of the rate (eg, min in "mg/min")
		strXML += FormatXML(ATTR_UNIT_RATETIME, lstRateTime.options[lstRateTime.selectedIndex].getAttribute('dbid'), lstRateTime.options[lstRateTime.selectedIndex].innerText);
	}

    // Add the infusion into line value	
	strXML += FormatXML(ATTR_INFUSIONLINEID, lstInfusionIntoLine.options[lstInfusionIntoLine.selectedIndex].getAttribute('dbid'), lstInfusionIntoLine.options[lstInfusionIntoLine.selectedIndex].innerText, GetReadOnlyAttribute(lstInfusionIntoLine));

//Infusion Duration (intermittent only)
	if (typeof(document.all['txtInfusionDuration']) != 'undefined') {
		if (lstInfusionDuration.options[lstInfusionDuration.selectedIndex].value == 'duration'){
			if (txtInfusionDuration2.value == '') {
				value1 = txtInfusionDuration.value;
				value2 = null;
			}
			else {
				value1 = txtInfusionDuration2.value;
				value2 = txtInfusionDuration.value
			}
			//Time units
			lngUnitID_InfusionDuration = lstInfusionDurationUnits.options[lstInfusionDurationUnits.selectedIndex].getAttribute('dbid');
			strText = lstInfusionDurationUnits.options[lstInfusionDurationUnits.selectedIndex].innerText;
			strXML += FormatXML("DurationBased", "1");
		}
		else {
		//Bolus dose; we just return 0 time.
			value1 = 0;
			value2 = null
			lngUnitID_InfusionDuration = 0;
			strText = '';
		}
		
		//Store the values in the xml
		strXML += FormatXML(ATTR_INFUSIONDURATION, value1);
		if (value2 != null) strXML += FormatXML(ATTR_INFUSIONDURATIONLOW, value2);

		//Time units
		strXML += FormatXML(ATTR_UNIT_DURATION, lngUnitID_InfusionDuration, strText, GetReadOnlyAttribute(lstInfusionDurationUnits));

	}

	strXML += FormatXML(ATTR_CONTINOUS, (blnIsContinuous ? '1' : '0') );
	
	// Add on the rate calculation xml as well
	if (typeof(document.all['txtInfusionRate']) != 'undefined') 
	{
		strXML += FormatXML("Persisted_RateCalculated", txtInfusionRate.getAttribute('persisted_ratecalculated'));
		strXML += FormatXML("Rate_XML", XMLEscape(txtInfusionRate.getAttribute('rate_xml')));
	}

	// 23Mar10 PH F0081306 Save the EditDiluent Button enabled state
	var imgDil = document.getElementById('imgShowEditDiluentButton')
	if (imgDil != null) {
	    var attr = imgDil.getAttribute('readonly');
	    if (attr != null && attr == "1") {
	        strXML += FormatXML("ShowEditDiluentButton", "0");
	    }
	    else {
	        strXML += FormatXML("ShowEditDiluentButton", "1");
	    }
	}
	    

//Get the standard stuff (route, frequency, startdate, etc)
	strXML += ReadDataFromForm_Common();
DescriptionChangeRequired ();  // Call to change description for bug fix F0023374
	return strXML;

}
//====================================================================================================================================
function PopulateForm_Infusion(){

var value1;
var value2;
var lngID;
var objRow;

//(The product list and associated data is scripted sever-side).
//Popliate the infusion rate/duration section.		
//Infusion rate (continuous only)
	if (IsContinuous()) {			

		EnableVariableRate();

		//Now the rate mass unit
		lngID = GetValueFromXML(ATTR_UNIT_RATEMASS);
		void SetListItem(trRateStart.all['lstUnits'], lngID);
		
		//And the rate routine
		lngID = GetValueFromXML(ATTR_ROUTINEID);
		if( m_blnTemplateMode )
		{
		    void SetListItem(trRateStart.all['lstRoutine'], lngID);
		}
		else
		{
		    void trRateStart.setAttribute('routineid', lngID);
		}
		
		//And the rate volume unit
		lngID = GetValueFromXML(ATTR_UNIT_RATETIME);
		void SetListItem(lstRateTime, lngID);
		void UpdateRateLabel();
	}		


//Infusion Duration (intermittent only)
	if (typeof(document.all['txtInfusionDuration']) != 'undefined') {
		value1 = Number(GetValueFromXML(ATTR_INFUSIONDURATIONLOW));		
		if (value1 > 0) {
		//We have a range of rates
			value2 = GetValueFromXML(ATTR_INFUSIONDURATION);			
		}
		else {
		//Single rate only
			value1 = GetValueFromXML(ATTR_INFUSIONDURATION);			
			value2 = '';
		}

		//Now the duration time unit
		lngID = GetValueFromXML(ATTR_UNIT_DURATION);
		void SetListItem(lstInfusionDurationUnits, lngID);
		if (Number(value1) == 0 && Number(lngID == 0)){																					//25Jan05 AE  Added support for IV Bolus
		//If the time and unitID are both 0, we have a bolus dose.
			lstInfusionDuration.selectedIndex = 1;
			InfusionDurationChange();
		}
		else {
		//Infusion with a duration		
			txtInfusionDuration.value = value1;
			txtInfusionDuration2.value = value2;
		}		
	
		//Set the read-only control

		void SetReadonlyStatus (lstInfusionDurationUnits, ATTR_UNIT_DURATION); 
	}
	lngID = GetValueFromXML(ATTR_INFUSIONLINEID);
	void SetListItem(lstInfusionIntoLine, lngID);
	void SetReadonlyStatus(lstInfusionIntoLine, ATTR_INFUSIONLINEID);

	//Update the rounding unit label for each product row
	//loop through rows in the table
	for (intCount=1;intCount < tblIngredients.rows.length; intCount++){
	//Get a reference to this row and the corresponding product element in the xml
		objRow = tblIngredients.rows[intCount].all['trDose_Infusion'];
		if (typeof(objRow) != 'undefined') 
		{
			void UpdateRoundingLabel(objRow);
			void EnableRoundingControls(objRow.all['lstRoutine']);
			
			//void UpdateDoseCapLabel(objRow);
		}		
	}	
	
	//populate the shared parts
	void PopulateForm_Common();
	
	//Hide any unused fields in display mode
	void HideEmptyFields_Infusion();

}

//=======================================================================================================================
function BuildDefaultDescription_Infusion() {
//Builds a default description for the infusion / injection form.
//	[{<Dose><Unit>|Drug1[,Drug2,Drug3...&DrugX]}] {continuous infusion|infusion|Bolus Injection <frequency>} 
// 27May05 AE  Improved full stops/commas between route, frequency & duration.  Also moved extra directions to the end of the string
// 16Jan06 PH  Replaced hard-coded "infusion" text with route text.

var objSelect;
var objRow;
var strDescription = new String();
var strContinuous = new String();
var strDrugList = new String();
var strFrequency = new String();
var strDrugName = new String();
var strInfusion = new String();
var blnBolus = false;
var strDose = new String();
var strRoute = '';	
var strBolus = '';
var strInfusionTime = '';
var strSeperationCharacter;
var strPrimaryIngredient = '';
var strDiluent = '';
var strStartingRate = '';
var strRateTime = '';
var strRateRange = '';
var strRate = '';
var strDiluentDose = '';

var colIngredients;
var idx;
var lngIngredients = 0;
var idxContents;

	if ( (lstRoute.options[lstRoute.selectedIndex].value != 'empty') &&
         (lstRoute.options[lstRoute.selectedIndex].getAttribute('dbid') != null) )
    {
		var lngRouteID = lstRoute.options[lstRoute.selectedIndex].getAttribute('dbid');
		strRoute = routesData.XMLDocument.selectSingleNode('//ProductRoute[@ProductRouteID="' + lngRouteID + '"]').getAttribute('Detail');
		//strRoute = routesData.XMLDocument.selectSingleNode('//ProductRoute[@ProductRouteID="' + lngRouteID + '"]').getAttribute('Description');
    }
	else {
		strRoute = '[route not specified]';
	}

	if (document.all['lstInfusionDuration'] != undefined){																			//27Jan05 AE  Fastest fix in the west
		blnBolus = (lstInfusionDuration.options[lstInfusionDuration.selectedIndex].value != 'duration');
	}

    // get the separation character to be used, default to a ', ' if none specified
    strSeperationCharacter = lblDrugName.getAttribute('seperationcharacter');


    // build up a common description for the drug
    for(idx = 1; idx < tblIngredients.rows.length; idx++)
    {
        objRow = tblIngredients.rows[idx];
        if(typeof(objRow) != 'undefined')
        {
            if(objRow.getAttribute("id") == "trIngredientContainer")
            {
                objRow = objRow.all['trIngredient'];
                if (objRow) {
                    strProduct = '';
                    

                    if (idx > 1 || !m_blnTemplateMode) strProduct = strProduct + objRow.all['tdIngredientName'].getAttribute('atomicname') + ' ';    //21May08 AE  Don't show first product name in template mode.  Also use atomic name as per spec.
                    //24Apr08 ST Changed as the ingredient name isn't here when in runtime mode.
                    //strProduct = objRow.parentElement.parentElement.parentElement.parentElement.all['tdIngredientName'].innerText;
                    strDose = objRow.all['txtDose'].value;


                    // F0080965 ST 18Mar10
                    // In all cases, if the dose is empty 
                    // AND
                    // If this is a RATE BASED infusion and its not the primary ingredient 
                    // OR
                    // If this is not a RATE BASED infusion
                    // Then add the text to the description.
                    if (objRow.all['txtDose'].value == '' && ((IsRateBased() && idx > 1) || !IsRateBased())) {
                        strProduct = strProduct + "[specify dose]";
                    }
                    
                    if (strDose != '')
                    {
                        objSelect = objRow.all['lstUnits'];
                        if (Number(objSelect.options[objSelect.selectedIndex].getAttribute('dbid')) > 0)
                        {
                            strProduct += strDose + objSelect.options[objSelect.selectedIndex].innerText;
                        }
                    }
                    //Include the routine if used

                    //if(idx == 1)
                    //{
                    // 03Jun08 PH F0025032 Routine name is now added to all products, not just the first
                    objSelect = objRow.all['lstRoutine'];
                    if (objSelect != undefined)
                    {
                        if (objSelect.options[objSelect.selectedIndex].getAttribute('dbid') > 0)
                        {
                            if (objSelect.options[objSelect.selectedIndex].getAttribute('shortdescription') != "")
                            {
                                strProduct += '/' + objSelect.options[objSelect.selectedIndex].getAttribute("shortdescription");
                            }
                            else
                            {
                                strProduct += '/' + objSelect.options[objSelect.selectedIndex].innerText;
                            }
                        }
                    }
                    //}

                    if (strPrimaryIngredient == "")
                    {
                        strPrimaryIngredient = objRow.all['tdIngredientName'].innerText;
                        //24Apr08 ST Changed as the ingredient name isn't here when in runtime mode.
                        //strPrimaryIngredient = objRow.parentElement.parentElement.parentElement.parentElement.all['tdIngredientName'].innerText;	
                    }

                    // add the seperation character in if we already have something in our description.
                    if (strDescription != "")
                    {
                        strDescription += strSeperationCharacter + " ";
                    }
                    // add the product to the description
                    strDescription += strProduct;

                    // add one to our ingredient count
                    lngIngredients++;
                }
            }
        }
    }

    // get the diluent if it's there
    objRow = tblIngredients.all['trDiluent'];
    if(typeof(objRow) != 'undefined')
    {
        if(Number(objRow.all['trDiluentDose'].getAttribute('productid') > 0))
        {
            strDiluent = objRow.all['tdDiluentName'].innerText;
            
            objRow = tblIngredients.all['trDiluentDose'];
            if(typeof(objRow) != 'undefined')
            {
                strDiluentDose = objRow.all['tdDiluentDose'].innerText;    
            }
        }
    }

    //
    //
    //
    //F0080338 ST 10Mar10 Moved as it's not correct for all instances
    //strDescription += " " + strRoute;

    
    if(IsContinuous())
    {
        var strRateUnit = new String();
        var strRateRoutine = new String();
        var strRateTimeUnit = new String();


	    objSelect = trRateStart.all['lstUnits'];
	    if (objSelect.selectedIndex > -1)
	    {
	        strRateUnit = objSelect.options[objSelect.selectedIndex].innerText;
	    }
	    else
	    {
	        strRateUnit = '[enter unit]';
	    }

		objSelect = trRateStart.all['lstRoutine'];
		if (objSelect != undefined && objSelect.selectedIndex > 0)
		{
		    if(objSelect.options[objSelect.selectedIndex].getAttribute("shortdescription") != "")
		    {
		        strRateRoutine += '/' + objSelect.options[objSelect.selectedIndex].getAttribute("shortdescription");
		    }
		    else
		    {
			    strRateRoutine += '/' + objSelect.options[objSelect.selectedIndex].innerText;
			}
		}

		objSelect = lstRateTime;
    	if (objSelect.selectedIndex > 0)
		{
    	    strRateTimeUnit = '/' + objSelect.options[objSelect.selectedIndex].innerText;
        }
		else 
		{
    	    strRateTimeUnit = '/[enter unit]';
        }
    
        if(chkVaryRate.checked == false)
        {
            if (txtInfusionRate.value == '')
            {
                strRate = '[enter rate]';
            }
            else
            {
                strRate = txtInfusionRate.value;
            }
        }
        else
        {
            if (txtInfusionRateMin.value == '')
            {
                strRate = '[enter min rate] to ';
            }
            else
            {
                strRate = txtInfusionRateMin.value + ' to ';
            }
            if(txtInfusionRateMax.value == '')
            {
                strRate += '[enter max rate]';
            }
            else
            {
                strRate += txtInfusionRateMax.value;
            }
        }
        strRate += " " + strRateUnit + strRateRoutine + strRateTimeUnit;

        if(strDiluent != "")
        {
            strDescription += " in " + strDiluent + " " + strDiluentDose;
        }

        //F0080338 ST 10Mar10 Add route to description
        strDescription += " " + strRoute;

        strDescription += " at " + strRate;
        //if(lngIngredients > 1)
        //{
        //    strDescription += " of " + strPrimaryIngredient;
        //}
	}
	else
	{
        if(strDiluent != "")																							//23May08 AE  Replaces above
		{
		    strDescription += " in " + strDiluent + " " + strDiluentDose;
		}

        //F0080338 ST 10Mar10 Add route to description
		strDescription += " " + strRoute;
		
		if (!blnBolus) {

		    strInfusionTime = txtInfusionDuration.value;
		    if (strInfusionTime != '') {											//23May08 AE  Removed, Not as per spec
		        if (txtInfusionDuration2.value != '') {
		            strInfusionTime += "-" + txtInfusionDuration2.value;
		        }
		        strInfusionTime += ' ' + lstInfusionDurationUnits.options[lstInfusionDurationUnits.selectedIndex].innerText;
		        strDescription += " over " + strInfusionTime;
		    }			

		}
		else {
		    strDescription += " bolus injection";
		    //if(strDiluent != "")
		    //{
		    //    strDescription += " in " + strDiluent + " " + strDiluentDose;
		    //}
		}

		strFrequency = ' ' + BuildDefaultDescription_Frequency();

		//Add the duration for intermittent / bolus doses
//		if (lstDurationUnits.selectedIndex > -1 && txtDuration.value != '') {
//		    var strUnit_Duration = lstDurationUnits.options[lstDurationUnits.selectedIndex].text;
//		    if (Number(txtDuration.value) == 1)
//		        strUnit_Duration = strUnit_Duration.substring(0, strUnit_Duration.length - 1); 			//15Dec05 AE  Remove 's' for singletons, eg "1 day" not "1 days"  #DR-05-0069
//		    strFrequency += ' ' + txtDuration.value + ' ' + strUnit_Duration + '. ';
//		}

		strDescription += strFrequency;
    }

	return strDescription;
}
//--------------------------------------------------------------------------------------------------------
function IsContinuous(){
//Returns true if this is a continuous infusion.
//We determine this at present by checking for the existance of the Rate box, 
//which is only scripted for continuous infusions.

	return (typeof(document.all['txtInfusionRate']) != 'undefined');
}

//--------------------------------------------------------------------------------------------------------
function GetProductForm(){

//03Mar06 AE  Form may be specified on the product, or by the drop down on chemical templates
	var strForm = lblDrugName.getAttribute('productform');
	if (strForm == 'chemical'){																																	
	//Read the form from the combo box, if there is one.
		if (document.all['lstForm'] != undefined){
			if (lstForm.selectedIndex > 0) strForm = lstForm.options[lstForm.selectedIndex].innerText;
		}
	}
	return strForm;
}

//--------------------------------------------------------------------------------------------------------
//F0082399 30Mar10 ST Updated to now pass in the order template id
function DiluentEdit(lngRequestID, lngOrderTemplateID)
{

    var idx;
    var xmlDiluent;
    var xmlRoot;
    var objRow;
    var objSelect;
    
    var lngDose;
    var strDose_Unit;
    var strRoutine;
    var lngDuration_Min;
    var lngDuration_Max;
    var strTime_Unit;
    var strRate_Dose_Unit;
    var strRateRoutine;
    
    var lngProductID;
    var strProductName;
    
    var blnIsPrimary;
    
    var strInfusionXML = "";
    var strRateXML = "";
    var strDuration_XML = "";   
    var DOM; 
    var xmlReconstitution;
    var xmlRemove;
    var xmlProduct;
    var DoseUnitID = 0;
	var SessionID = document.body.getAttribute("sid");
	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");   
	
   	if (IsContinuous()) 
	{
	    // rate based infusions
        objSelect = trRateStart.all['lstUnits'];
        strRate_Dose_Unit = objSelect.options[objSelect.selectedIndex].innerText;
        DoseUnitID = objSelect.options[objSelect.selectedIndex].getAttribute("dbid");
        
		objSelect = trRateStart.all['lstRoutine'];
		if (typeof(objSelect) != 'undefined')
		{
			strRateRoutine = objSelect.options[objSelect.selectedIndex].innerText;
		}
        
        strRateXML += FormatXML('RateMin', txtInfusionRateMin.value, '' );
        strRateXML += FormatXML('RateMax', txtInfusionRateMax.value, '' );
        strRateXML += FormatXML('RateStart', txtInfusionRate.value, '' );
        strRateXML += FormatXML('DoseUnit', strRate_Dose_Unit, '' );
        strRateXML += FormatXML('DoseUnitID', DoseUnitID, '' );
        strRateXML += FormatXML('Routine', strRateRoutine, '' );
        strRateXML += FormatXML('TimeUnit', lstRateTime.options[lstRateTime.selectedIndex].innerText, '' );
	}
	else
	{
	    // Infusion Duration (intermittent only)
    	if (typeof(document.all['txtInfusionDuration']) != 'undefined') 
    	{
		    if (lstInfusionDuration.options[lstInfusionDuration.selectedIndex].value == 'duration')
		    {
			    if (txtInfusionDuration2.value == '') 
			    {
			        lngDuration_Min = txtInfusionDuration.value;
			        lngDuration_Max = 0;
			    }
			    else 
			    {
			        lngDuration_Min = txtInfusionDuration.value;
			        lngDuration_Max = txtInfusionDuration2.value;
			    }
			    strTime_Unit = lstInfusionDurationUnits.options[lstInfusionDurationUnits.selectedIndex].innerText;
		    }
		    else 
		    {
		        //Bolus dose
		        lngDuration_Min = 0;
		        lngDuration_Max = 0;
		        strTime_Unit = "";
		    }
		    
		    strDuration_XML += FormatXML('Duration_Min', lngDuration_Min, '');
		    strDuration_XML += FormatXML('Duration_Max', lngDuration_Max, '');
		    strDuration_XML += FormatXML('Duration_TimeUnit', strTime_Unit, '');
		}
    }

    strInfusionXML = "<root>";
    blnIsPrimary = true;
    
    for(idx = 1; idx < tblIngredients.rows.length; idx++)
    {
        objRow = tblIngredients.rows[idx].all['trDose_Infusion'];
        if(typeof(objRow) != 'undefined')
        {
            if(typeof(objRow.all['txtDose']) != 'undefined')
            {
                lngProductID = objRow.getAttribute('ProductID');
                lngDose = objRow.all['txtDose'].value;

                objSelect = objRow.all['lstUnits'];
                strDose_Unit = objSelect.options[objSelect.selectedIndex].innerText;
                DoseUnitID = objSelect.options[objSelect.selectedIndex].getAttribute("dbid");
                
                if(m_blnTemplateMode)
                {
                    // template mode
                    objSelect = objRow.all['lstRoutine'];
                    strRoutine = objSelect.options[objSelect.selectedIndex].innerText;
                }
                else
                {
                    // runtime mode
                    strRoutine = objRow.getAttribute('routinedescription');
                }
                strProductName = objRow.parentElement.parentElement.parentElement.parentElement.all['tdIngredientName'].innerText;	
            }
            
            strInfusionXML += "<Product ProductID='" + lngProductID + "' ";
            strInfusionXML += "IsPrimary='" + blnIsPrimary + "' ";
            strInfusionXML += "ProductName='" + strProductName + "' ";
            strInfusionXML += "Dose='" + lngDose + "' ";
            strInfusionXML += "DoseUnit='" + strDose_Unit + "' ";
            strInfusionXML += "DoseUnitID='" + DoseUnitID + "' ";
            strInfusionXML += "Routine='" + strRoutine + "'";
            strInfusionXML += "></Product>";
            
            blnIsPrimary = false;
        }
    }

    if(strRateXML != "")
    {
        strInfusionXML += strRateXML;
    }
    
    if(strDuration_XML != "")
    {
        strInfusionXML += strDuration_XML;
    }
    
    // add any diluent information in
    if(infusionDiluent.XMLDocument.xml != "")
    {
        strInfusionXML += infusionDiluent.XMLDocument.xml;
    }
        
    // and close the xml
    strInfusionXML += "</root>";
    strInfusionXML = ReplaceString(strInfusionXML, '"', '\'');
    
    
    
	var strURL = '../../OrderEntry/SessionAttributeSave.aspx'
				  + '?SessionID=' + SessionID
				  + '&Mode=set'
				  + '&Attribute=' + "OrderEntry/Diluent";

	objHTTPRequest.open("POST", strURL, false);	//false = syncronous    
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");                            //application/x-www-form-urlencoded
	objHTTPRequest.send(strInfusionXML);
	objHTTPRequest.responseText;
	
	//
	// don't hang around, simply open the new dialog which will read in the values
	//

	//F0082399 30Mar10 ST Added on the order template id	
    var strURL = '../../OrderEntry/ReconstitutionDiluentModal.aspx'
                + '?SessionID=' + document.body.getAttribute('sid')
                + '&RequestID=' + lngRequestID
                + '&TemplateMode=' + m_blnTemplateMode
                + '&OrderTemplateID=' + lngOrderTemplateID
                + '&DisplayMode=' + DisplayMode();



    strReturn = window.showModalDialog(strURL, '', DiluentFeatures());
	if (strReturn == 'logoutFromActivityTimeout') {
		strReturn = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

    // Check what came back from the dialog
    // Basically if 'ok' comes back then we save the data
    // If in displaymode then a return of 'saved' indicates that it has already been saved.
	//if ((strReturn != undefined) && (strReturn != 'cancel') && (strReturn != 'saved')) 

	if ((strReturn != undefined) && (strReturn != 'cancel')) 
	{
	    if(strReturn == 'saved' || strReturn == 'ok')
	    {

	        // this gets returned when we are dealing with an already committed item.
	        // saved is returned because the diluent information has already been saved via diluents.js	       
	        strURL = '../../sharedscripts/SessionAttribute.aspx'
				        + '?SessionID=' + SessionID
				        + '&Mode=get'
				        + '&Attribute=OrderEntry/SavedDiluent';

	        objHTTPRequest.open("POST", strURL, false);	//false = syncronous                              
	        objHTTPRequest.send('');
    	    
	        if(objHTTPRequest.responseText != "")
	        {
	            DOM = new ActiveXObject('MSXML2.DOMDocument');
	            DOM.loadXML(objHTTPRequest.responseText);
                xmlObj = DOM.selectSingleNode("root/Diluents/Product");
                	        
                if(xmlObj != null)
                {
		            //Record this product in the temporary store and submit the whole page back 
		            //to the server for rescripting
		            xmlRoot = infusionDiluent.XMLDocument.selectSingleNode('Diluents');
		            if(xmlRoot == null)
		            {
		               xmlRoot = infusionDiluent.appendChild(infusionDiluent.createElement('Diluents'));					//28May08 AE Append the root to the document so that it doesn't just vanish
    		            //xmlProduct = xmlRoot.appendChild(infusionDiluent.XMLDocument.createElement('Product'));
		            }
		            else
		            {
		                // delete the existing item so we can add the new one in
		                xmlRemove = xmlRoot.selectSingleNode('Product');
		                if(xmlRemove != null)
		                {
		                    xmlProduct = xmlRoot.removeChild(xmlRemove);
		                }
		            }
		            xmlProduct = xmlRoot.appendChild(xmlObj);
                    // and reconstitution information		    
                    xmlObj = null;
                    xmlObj = DOM.selectSingleNode("root/Diluents/Reconstitution");
                    if(xmlObj != null)
                    {
                        xmlRoot = infusionDiluent.XMLDocument.selectSingleNode('Diluents');
                        if(xmlRoot != null)
                        {
                            xmlRemove = xmlRoot.selectSingleNode('Reconstitution');
                            if(xmlRemove != null)
                            {
                                xmlReconstitution = xmlRoot.removeChild(xmlRemove);
                            }
                        }
                        xmlRoot = infusionDiluent.XMLDocument.selectSingleNode('Diluents');
                        if(xmlRoot != null)
                            xmlReconstitution = xmlRoot.appendChild(xmlObj);
                    }
                }
                
                // we might have a new calculated dose saved so get that here
	            strURL = '../../sharedscripts/SessionAttribute.aspx'
				            + '?SessionID=' + SessionID
				            + '&Mode=get'
				            + '&Attribute=OrderEntry/SavedDose';

	            objHTTPRequest.open("POST", strURL, false);	//false = syncronous                              
	            objHTTPRequest.send('');
        	    
	            if(objHTTPRequest.responseText != "")
	            {
        	        objRow = tblIngredients.rows[1].all['trDose_Infusion'];
        	        if (objRow.all['txtDose'].value != objHTTPRequest.responseText)
        	        {
        	            objRow.all['txtDose'].value = objHTTPRequest.responseText;
        	        }
	            
	                // Clear out the previous saved dose entry
	                var strURL = '../../OrderEntry/SessionAttributeSave.aspx'
				                  + '?SessionID=' + SessionID
				                  + '&Mode=set'
				                  + '&Attribute=' + "OrderEntry/SavedDose";

	                objHTTPRequest.open("POST", strURL, false);
	                objHTTPRequest.setRequestHeader("Content-Type", "text/xml");
	                objHTTPRequest.send("");
	            }


	            //F0047763 ST 10Mar09
	            //When editing diluents we add on a flag to the querystring to indicate to the prescription form that
	            //we have done so. This will allow us to pick this up in the code and prevent the infusion rate from 
	            //being recalculated all of the time the page is refreshed.
	            frmData.action = QuerystringReplace(frmData.action, "DiluentEdit", "1");

		        //We also submit the data currently in the form      	    					
				  if (DisplayMode()) {
//				     frmData.action += '&DescriptionUpdate=1';					//indicate that we need to update the description once the form has reloaded
                    // 04Jun08 PH F0025294 DescriptionUpdate was being concatenated multiple times
				     frmData.action = QuerystringReplace(frmData.action, "DescriptionUpdate", "1");
				  }
		        document.all['formDataXML'].value = ReadDataFromFormWithRoot();		       
		        frmData.submit();
            }
	    }
	}		
}

function DiluentFeatures()
{
    //F0082460 ST 31Mar10 Prevent modal dialog from being resized.
    //F0083323 ST 12Apr10 Increased width from 900px to 1000px as long diluent names cause screen to be shift over.
    var strFeatures = 'dialogWidth:1000px;'
						 + 'resizable:no;'
						 + 'status:no;help:no;'
    if( screen.availHeight < 900 )
    {
	    strFeatures += 'dialogHeight:710px;';
	}
    else
    {
	    strFeatures += 'dialogHeight:900px;';
	}
	return strFeatures;                  
}

//=======================================================================================================================
//									Add/Remove products
//=======================================================================================================================

function IngredientSearchFeatures(){

	var strFeatures = 'dialogHeight:500px;' 
						 + 'dialogWidth:600px;'
						 + 'resizable:no;'
						 + 'status:no;help:no;';	
	return strFeatures;
}
//--------------------------------------------------------------------------------------------------------
function IngredientAdd() {

//Add a new product to the formula list	

var xmlProduct;
var xmlRoot;
	
var astrProduct = new Array();
var lngProductID = 0;
var strDescription = '';
var strElementName = '';
	
	//Build the URL for the IngredientPicker
	var strURL = '../../ProductSearch/IngredientSearch.aspx'
				  + '?SessionID=' + document.body.getAttribute('sid');
				  
	strReturn = window.showModalDialog(strURL, '', IngredientSearchFeatures());
	if (strReturn == 'logoutFromActivityTimeout') {
		strReturn = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	if ((strReturn != undefined) && (strReturn != 'cancel')) {		
	//strReturn is in the format <ProductID>,<Description>
		astrProduct = strReturn.split(',');
	
		//Record this product in the temporary store and submit the whole page back 
		//to the server for rescripting
		xmlRoot = infusionProducts.XMLDocument.selectSingleNode('Ingredients');
		xmlProduct = xmlRoot.appendChild(infusionProducts.XMLDocument.createElement('Product'));
		void xmlProduct.setAttribute('ProductID', astrProduct[0]);
		void xmlProduct.setAttribute('Description', astrProduct[1]);
		
		//We also submit the data currently in the form
		document.all['formDataXML'].value = ReadDataFromFormWithRoot();

		frmData.submit();
	}

}

//--------------------------------------------------------------------------------------------------------
function IngredientRemove(objSrc){

//Get the productID from the row that's been clicked on
	var objTR = GetTRFromChild(objSrc).all['trDose_Infusion'];
	var productID = objTR.getAttribute('productid');

//Remove this product from the xml document
	var xmlProduct = infusionProducts.XMLDocument.selectSingleNode('Ingredients/Product[@ProductID="' + productID + '"]');
	xmlProduct.parentNode.removeChild(xmlProduct);

//We also submit the data currently in the form
	document.all['formDataXML'].value = ReadDataFromFormWithRoot();
		
//Rescript the page

	frmData.submit();

}

//--------------------------------------------------------------------------------------------------------
function UpdateDiluentXML()
{
    var xmlDiluent;
    var xmlRoot;
    var xmlNode;
    var objRow;
    var lngID;
    

//    objRow = tblIngredients.all['trDiluent'];
//    if(typeof(objRow) != 'undefined')
//    {
        // update the existing diluent information
        
//        xmlRoot = infusionDiluent.XMLDocument.selectSingleNode('Diluents');
//		if(xmlRoot == null)
//		{
//		    xmlRoot = infusionDiluent.createElement('Diluents');
//		}

//		xmlProduct = xmlRoot.appendChild(infusionDiluent.XMLDocument.createElement('Product'));
//		void xmlProduct.setAttribute('ProductID', '1234');
//		void xmlProduct.setAttribute('Description', 'MyTestProduct');
//   }

}

//--------------------------------------------------------------------------------------------------------
function UpdateProductXML(){

//Screen scrapes the product data from the form and updates the internal XML document
//to match.
var xmlProduct;
var intCount = 0;
var objRow;
var objSelect;
var lngDoseUnitID = 0;

//Read the data from the product list
	//loop through rows in the table
	for (intCount=1;intCount < tblIngredients.rows.length; intCount++){
	//Get a reference to this row and the corresponding product element in the xml
		objRow = tblIngredients.rows[intCount].all['trDose_Infusion'];
		if (typeof(objRow) != 'undefined') {
			lngID = objRow.getAttribute('productid');
			xmlProduct = infusionProducts.XMLDocument.selectSingleNode('Ingredients/Product[@ProductID="' + lngID + '"]');
			
		//Update the xml element with the data from the form.
			if ((typeof(objRow.all['txtDose']) != 'undefined') && xmlProduct != null){
				xmlProduct.setAttribute (ATTR_DOSE, objRow.all['txtDose'].value);
				xmlProduct.setAttribute (ATTR_DOSE_ORIGINAL, objRow.getAttribute('dose_original'));
				objSelect = objRow.all['lstUnits'];
				lngDoseUnitID = objSelect.options[objSelect.selectedIndex].getAttribute('dbid');
				xmlProduct.setAttribute (ATTR_DOSEUNIT, lngDoseUnitID );																
				xmlProduct.setAttribute (ATTR_DOSEUNIT_ORIGINAL,  objRow.getAttribute('unit_original'));
				objSelect = objRow.all['lstRoutine'];
				if (typeof(objSelect) != 'undefined'){
				//When building a template
					xmlProduct.setAttribute (ATTR_ROUTINEID, objSelect.options[objSelect.selectedIndex].getAttribute('dbid') );
				}
				else {
				//When in "run time" mode		
					xmlProduct.setAttribute (ATTR_ROUTINEID, objRow.getAttribute('routineid'));	
					xmlProduct.setAttribute (ATTR_ROUTINEDESCRIPTION, objRow.getAttribute('routinedescription'));	
				}
				//Add the calculation information, if any																												//08Feb05 AE  Persist calculation information
				xmlProduct.setAttribute(ATTR_ISCALCULATED, objRow.getAttribute('iscalculateddose'));
				xmlProduct.setAttribute(ATTR_CALCULATION_ORIGINAL, objRow.getAttribute('dose_original'));					
				xmlProduct.setAttribute(ATTR_CALCULATION_CALCULATED, objRow.getAttribute('dose_calculated'));					

				xmlProduct.setAttribute(ATTR_ROUND_INCREMENT, objRow.all['txtRoundValue'].value);														//26Mar05 AE
				xmlProduct.setAttribute(ATTR_ROUND_UNIT, lngDoseUnitID);																							//07Apr05 AE   Also store the rounding unit, to support rounding of manually-entered doses

				xmlProduct.setAttribute (ATTR_DOSE_CAP, objRow.all['txtDoseCap'].value);
				xmlProduct.setAttribute (ATTR_DOSE_CAP_UNIT, objRow.all['lblDoseCapUnit'].getAttribute("dbid"));
				xmlProduct.setAttribute (ATTR_DOSE_CAP_CAN_OVERRIDE, objRow.all['lnkDoseCapOverridable'].getAttribute("override"));
				xmlProduct.setAttribute(ATTR_DOSE_REEVALUATE, objRow.all['lnkDoseReevaluate'].getAttribute("override"));
				if (objRow.all['txtDose'].getAttribute("IsAdjustedDose") == 'True')
				{
				    xmlProduct.setAttribute("IsAdjustedDose", "True");
				}
				else
				{
				    xmlProduct.setAttribute("IsAdjustedDose", "False");
				}
				

				xmlProduct.setAttribute("OriginalCalculated", objRow.getAttribute('dose_originalcalculated'));
				
				xmlProduct.setAttribute("Dose_XML", XMLEscape(objRow.getAttribute("dose_xml")));
			}
		}
	}
	
}

//=======================================================================================================================
//											Dose Calculation
//=======================================================================================================================
function ShowCalculationHistory_Infusion(objSrc, lngRequestID)
{
    var objTR = GetIngredientFromChild(objSrc);
	var lngProductID = objTR.getAttribute('productid');
	
	var strURL = '../../DSS/DoseCalculationHistory.aspx'
				+ '?SessionID=' + document.body.getAttribute('sid')
				+ '&RequestID=' + lngRequestID
				+ '&ProductID=' + lngProductID
				+ '&Type=Infusion';
	
	var ret = window.showModalDialog(strURL, '', CalculationFormFeatures());
	if (ret == 'logoutFromActivityTimeout') {
		ret = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}


function ShowCalculationHistory_InfusionPending(objSrc, lngPendingItemID)
{
    var objTR = GetIngredientFromChild(objSrc);
	var lngProductID = objTR.getAttribute('productid');
	
	var strURL = '../../DSS/DoseCalculationHistory.aspx'
				+ '?SessionID=' + document.body.getAttribute('sid')
				+ '&RequestID=' + 0
				+ '&PendingItemID=' + lngPendingItemID
				+ '&ProductID=' + lngProductID
				+ '&Type=Infusion';
	
	var ret = window.showModalDialog(strURL, '', CalculationFormFeatures());
	if (ret == 'logoutFromActivityTimeout') {
		ret = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}

function ShowCalculation_Infusion(objSrc){

//Read the templated dose and unit from the given row.
//The original dose and routine id (eg 50mg/Kg) are stored on the tr element 
//along with the product id, and we use this to recalculate, rather than 
//the resulting value which is what is in the text box.
    var objTR = GetIngredientFromChild(objSrc);
	var routineID = objTR.getAttribute('routineid');
	var dblDose = objTR.getAttribute('dose_original');
	var unit = objTR.all['lstUnits'].options[objTR.all['lstUnits'].selectedIndex].innerText;
	var unitID = objTR.all['lstUnits'].options[objTR.all['lstUnits'].selectedIndex].getAttribute('dbid');
	var objRound = objTR.all['txtRoundValue']
	var roundTo = Number(objRound.value);
	var roundToUnit = objRound.getAttribute('unitid');

	//17-Jan-2008  JA Error code 162
		var strURL = '../../DSS/DoseCalculation.aspx'
				  + '?SessionID=' + document.body.getAttribute('sid')
				  + '&RoutineID=' + routineID
				  + '&Value=' + dblDose
				  + '&ValueLow=0'
				  + '&Unit=' + unit
				  + '&UnitID=' + unitID
				  + '&changed=0';
	
	if (roundTo > 0){																									//07Apr05 AE  Added rounding support
		strURL += '&RoundTo=' + roundTo
				  + '&RoundToUnitID=' + roundToUnit;
	}
	
	var CapAt = objTR.all['txtDoseCap'].value;	
	var CapAtToUnitID = objTR.all['lblDoseCapUnit'].getAttribute('dbid');
	if (Number(CapAt) > 0){																									//21Oct07 PH  Added dose capping support
		strURL += '&CapAt=' + CapAt
				  + '&CapAtUnitID=' + CapAtToUnitID;
	}

	//Show it
	var newDose = window.showModalDialog(strURL, '', CalculationFormFeatures())
	if (newDose == 'logoutFromActivityTimeout') {
		newDose = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	if (newDose!=null && newDose != 'cancel') window.parent.Reload(MESSAGE_RECALCULATING);												//26Mar07 AE  Use reload method to cascade changes through ordersets
		
}

//--------------------------------------------------------------------------------------------------------
function ShowCalculationHistory_Rate(objSrc, lngRequestID)
{

	var objTR = GetTRFromChild(objSrc);
	var strURL = '../../DSS/DoseCalculationHistory.aspx'
				  + '?SessionID=' + document.body.getAttribute('sid')
				  + '&RequestID=' + lngRequestID
				  + '&Type=Rate';
		 
	//Show it
	var ret = window.showModalDialog(strURL, '', CalculationFormFeatures());
	if (ret == 'logoutFromActivityTimeout') {
		ret = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}

function ShowCalculationHistory_RatePending(objSrc, lngPendingItemID)
{
	var objTR = GetTRFromChild(objSrc);
	

	var strURL = '../../DSS/DoseCalculationHistory.aspx'
				  + '?SessionID=' + document.body.getAttribute('sid')
				  + '&RequestID=' + 0
				  + '&PendingItemID=' + lngPendingItemID
				  + '&Type=Rate';
		 
	//Show it
	var ret = window.showModalDialog(strURL, '', CalculationFormFeatures());
	if (ret == 'logoutFromActivityTimeout') {
		ret = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}


function ShowCalculation_Rate(objSrc){
//Read the templated rate and unit from the given row.
//The original rate and routine id (eg 50mg/Kg) are stored on the input element 
//and we use this to recalculate, rather than 
//the resulting value which is what is in the text box.
//23Mar05 AE  Written

var rateStart = 0
var rateValueHigh = 0;
var rateValueLow = 0;
var rateNew = 0;
var rateNewHigh = 0;
var rateNewLow = 0;
var rateMin = 0;
var rateMax = 0;

	var objTR = GetTRFromChild(objSrc);
	var routineID = objTR.getAttribute('routineid_calculation');

	rateStart = txtInfusionRate.getAttribute('dblrate_original');			
	rateValueLow = txtInfusionRateMin.getAttribute('dblrate_original');
	rateValueHigh = txtInfusionRateMax.getAttribute('dblrate_original');

	rateMin = txtInfusionRateMin.getAttribute('dblrate_calculated');
	rateMax = txtInfusionRateMax.getAttribute('dblrate_calculated');
	
	var unit = trRateStart.all['lstUnits'].options[trRateStart.all['lstUnits'].selectedIndex].innerText;
	var duration = trRateStart.all['lstRateTime'].options[trRateStart.all['lstRateTime'].selectedIndex].innerText;
    //17-Jan-2008 JA Error code 162
	var strURL = '../../DSS/DoseCalculation.aspx'
				  + '?SessionID=' + document.body.getAttribute('sid')
				  + '&RoutineID=' + routineID
				  + '&Value=' + rateStart
				  + '&ValueLow=0'
				  + '&Unit=' + unit
				  + '&RateCalculation=True'
				  + '&Duration=' + duration
				  + '&RateStart=' + rateStart
				  + '&RateLow=' + rateValueLow
				  + '&RateHigh=' + rateValueHigh
				  + '&RateMin=' + rateMin
				  + '&RateMax=' + rateMax
				  + '&changed=0';
				  
		 
	//Show it
	var newRate = window.showModalDialog(strURL, '', CalculationFormFeatures());
	if (newRate == 'logoutFromActivityTimeout') {
		newRate = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}


	
	//If we've changed it, reload the page to force a recalculation of the dose.
	if (newRate!=null && newRate != 'cancel') window.parent.Reload(MESSAGE_RECALCULATING);
	
	/* LM 13/11/2007 Code 108 Commented out code that has not yet been implemented. Was causing the Js not to load.
				!!!! *** to be implemented *** !!!
*/

}
//--------------------------------------------------------------------------------------------------------

//function PositionProblemDiv()
//{
//	// Dummy
//}

//--------------------------------------------------------------------------------------------------------

function ToggleDoseCapOverride(objSpan)
{

	if (objSpan.getAttribute("override")=="1")
	{
		objSpan.setAttribute("override","0");
	}
	else
	{
		objSpan.setAttribute("override","1");
	}
	DoseCapOverrideSet(objSpan);	
}

function DoseCapOverrideSet(objSpan)
{
    if (objSpan.getAttribute("override")=="1")
	{
		objSpan.innerHTML = "The&nbsp;user&nbsp;CAN&nbsp;override&nbsp;maximum";
	}
	else
	{
		objSpan.innerHTML = "The&nbsp;user&nbsp;CANNOT&nbsp;override&nbsp;maximum";
	}		
}

//BUG FIX, Christie's SLA F0023374
function DescriptionChangeRequired()
{
    if (m_windowLoading) //Don't redraw description if the page is loading
    {
        return;
    }      
 
    var strDescription = BuildDefaultDescription();   
    
    //Test parent to see whether the method exists, if not do nothing
    if (window.parent.DescriptionUpdate)
    {
         window.parent.DescriptionUpdate(document.body.getAttribute("ordinal"), strDescription);
    }    
    else
    {
        return;
    }
    
		
}
//END BUG FIX, Christie's SLA F0023374


function ShowDoseOptionsDialog(objSrc)
{
    var objRow = GetTableFromChild(objSrc);
    var objSelect;
    var DoseUnit;
    var Routine;
    var astrDoseOptions = new Array();

    var RoundToNearest = objRow.all['txtRoundValue'].value;
    var ToMaximumOf = objRow.all['txtDoseCap'].value;
    var AllowOverride = objRow.all['lnkDoseCapOverridable'].getAttribute("override");
    var Reevaluate = objRow.all['lnkDoseReevaluate'].getAttribute("override");
    var Dose;
    
    if(objRow.all['txtDose'] != undefined)
    {
        Dose = objRow.all['txtDose'].value;
    }

    if(objRow.all['txtDoseQty'] != undefined)
    {
        Dose = objRow.all['txtDoseQty'].value;
    }
    
    objSelect = objRow.all['lstUnits'];
    DoseUnit = objSelect.options[objSelect.selectedIndex].innerText;
    
    objSelect = objRow.all['lstRoutine'];
    Routine = objSelect.options[objSelect.selectedIndex].innerText;
    
    
	var strURL = '../../OrderEntry/DoseOptionsModal.aspx'
				  + '?SessionID=' + formBody.getAttribute('sid')
				  + '&Dose=' + Dose
				  + '&DoseUnit=' + DoseUnit
				  + '&Routine=' + Routine
				  + '&RoundToNearest=' + RoundToNearest
				  + '&ToMaximumOf=' + ToMaximumOf
				  + '&AllowOverride=' + AllowOverride
				  + '&Reevaluate=' + Reevaluate;
				  
	var strReturn = window.showModalDialog(strURL, '', 'dialogHeight:450px;dialogWidth:800px;resizable:yes;unadorned:no;status:no;help:no;');
	if (strReturn == 'logoutFromActivityTimeout') {
		strReturn = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

    if(strReturn != undefined)
    {
        astrDoseOptions = strReturn.split(',');
    	
	    objRow.all['txtRoundValue'].value = astrDoseOptions[0];
	    objRow.all['txtDoseCap'].value = astrDoseOptions[1];
	    if(astrDoseOptions[2] == 'true')
	    {
	        objRow.all['lnkDoseCapOverridable'].setAttribute('override', '1');
	    }
	    else
	    {
	        objRow.all['lnkDoseCapOverridable'].setAttribute('override', '0');
	    }
	    
	    if(astrDoseOptions[3] == 'true')
	    {
	        objRow.all['lnkDoseReevaluate'].setAttribute('override', '1');
	    }
	    else
	    {
	        objRow.all['lnkDoseReevaluate'].setAttribute('override', '0');
	    }
    	
	    UpdateDoseOptionsLabel(objSrc);
    }
}


function UpdateDoseOptionsLabel(objSrc)
{
	if (m_blnTemplateMode)
	{
		var objRow = GetTableFromChild(objSrc);
		var objSelect = objRow.all['lstUnits'];
		var strLabelText = "";
		
		var objRound = objRow.all['txtRoundValue'];
		var objCap = objRow.all['txtDoseCap'];
		var objOverride = objRow.all['lnkDoseCapOverridable'];
		var objReevalute = objRow.all['lnkDoseReevaluate'];
       
        if(objRound!=null && (objRound.value) > 0)
        {
            strLabelText = "Rounding " + objRound.value + objSelect.options[objSelect.selectedIndex].innerText;
        }
        else
        {
            strLabelText = "No Rounding";
        }
        
        if(objCap!=null && Number(objCap.value) > 0)
        {
            strLabelText += ", Cap " + objCap.value + objSelect.options[objSelect.selectedIndex].innerText;
        }
        else
        {
            strLabelText += ", No Cap";
        }

        if (objOverride!=null && objOverride.getAttribute("override") == "1")
        {
            strLabelText += ", Override Cap On";
        }
        else
        {
            strLabelText += ", Override Cap Off";
        }

        if (objReevalute != null && objReevalute.getAttribute("override") == "1")
        {
            strLabelText += ", Reevaluate Doses On";
        }
        else
        {
            strLabelText += ", Reevaluate Doses Off";
        }
        
        if (objRow.all['spnDoseOptions'] != null) 
        {
            objRow.all['spnDoseOptions'].innerText = strLabelText;
        }
	}
}


//
//  Launches the dose reduction dialog for standard prescriptions
//
function AdjustDose_Standard(objSrc)
{
	var intFormOrdinal = document.body.getAttribute("ordinal");
	// Call adjust doses on order entry form.
	window.parent.AdjustDoses(intFormOrdinal);
}

//
// Launches the dose reduction dialog for infusion prescriptions
//
function AdjustDose_Infusion(objSrc)
{
	var intFormOrdinal = document.body.getAttribute("ordinal");
	// Call adjust doses on order entry form.
	window.parent.AdjustDoses(intFormOrdinal);
}

//
// Construct the Adjustment XML (to be used by the Dose Adjustment Dialog) for this prescription
//
function GetAdjustmentXML(blnChecked)
{
	switch (document.body.getAttribute('requesttype'))
	{
		case REQUESTTYPE_STANDARD:
			return GetAdjustmentXML_Standard(blnChecked);

		case REQUESTTYPE_DOSELESS:
			return GetAdjustmentXML_Standard(blnChecked);

		case REQUESTTYPE_INFUSION:
			return GetAdjustmentXML_Infusion(blnChecked);
	}
}

//
// Get the XML required for the Ajustment dialog for a standard prescription
//
function GetAdjustmentXML_Standard(blnChecked)
{
	// Get the data required for the Adjustment Form, for a standard prescription.
	
	var strXML = '';
	var objDrug = document.getElementById("lblDrugName");
	var objDateControl = new DateControl(txtStartDate);

	if (objDrug.getAttribute("iscalculateddose") == "true") // Only return data for RX's that have a calculated dose.
	{
		strXML += "<rx ";

		strXML += "FormOrdinal='" + document.body.getAttribute("ordinal") + "' ";
		strXML += "ProductID='" + objDrug.getAttribute("productid") + "' ";
		strXML += "RxType='Standard' ";
		strXML += "Description='" + objDrug.innerText + "' ";
		strXML += "Route='" + lstRoute.options[lstRoute.selectedIndex].text + "' ";
		strXML += "StartDate='" + objDateControl.GetTDate() +"' ";

		// Dose
		strXML += "Dose_Low='" + objDrug.getAttribute("calculation_doselow") + "' ";
		strXML += "Dose='" + objDrug.getAttribute("calculation_dose") + "' ";
		strXML += "UnitID='' ";
		strXML += "Unit='" + objDrug.getAttribute("DoseUnit_ForCalculation") + "' ";
		strXML += "RoutineID='" + objDrug.getAttribute("calculation_routineid") + "' ";
		strXML += "RoutineName='" + objDrug.getAttribute("calculation_routinedescription") + "' ";

		// Calculated Dose
		strXML += "Dose_Low_Calc='" + objDrug.getAttribute("calculation_calculateddoselow") + "' ";
		strXML += "Dose_Calc='" + objDrug.getAttribute("calculation_calculateddose") + "' ";
		strXML += "UnitID_Calc='' ";
		strXML += "Unit_Calc='" + objDrug.getAttribute("DoseUnit_ForCalculation") + "' ";

		// Prescribed Dose
		// When a single dose is used, then the dose if stored in "Dose_Prescribed", and Dose_Low_Prescribed is 0,
		// however, on screen the single dose is stored in the "From" field, and "To" is blank, so sadly we have to swap 
		// the values around!
		if (String(txtDoseQty2.value).length == 0)
		{
			// Single dose
			strXML += "Dose_Low_Prescribed='0' ";
			strXML += "Dose_Prescribed='" + txtDoseQty.value + "' ";
		}
		else
		{
			// Ranged Dose
			strXML += "Dose_Low_Prescribed='" + txtDoseQty.value + "' ";
			strXML += "Dose_Prescribed='" + txtDoseQty2.value + "' ";
		}
		strXML += "UnitID_Prescribed='" + lstUnits.options[lstUnits.selectedIndex].getAttribute("dbid") + "' ";
		strXML += "Unit_Prescribed='" + lstUnits.options[lstUnits.selectedIndex].text + "' ";

		// Dose Cap
		strXML += "Dose_Cap='" + txtDoseCap.value + "' ";
		strXML += "UnitID_Cap='" + lblDoseCapUnit.getAttribute("dbid") + "' ";
		strXML += "Unit_Cap='" + lblDoseCapUnit.innerText + "' ";
		strXML += "Dose_Cap_Overridable='" + lnkDoseCapOverridable.getAttribute("override") + "' ";

		// Dose Cap
		strXML += "Dose_Round='" + txtRoundValue.value + "' ";
		strXML += "UnitID_Round='" + lblRoundUnit.getAttribute("dbid") + "' ";
		strXML += "Unit_Round='" + lblRoundUnit.innerText + "' ";

		strXML += "Checked='" + (blnChecked ? "1" : "0") + "'"; 

		strXML += " />";
	}
	return strXML;
}

//
// Get the XML required for the Ajustment dialog for an infusion prescription
//
function GetAdjustmentXML_Infusion(blnChecked)
{
	// Get the data required for the Adjustment Form, for a standard prescription.

	var strXML = '';
	var objDateControl = new DateControl(txtStartDate);

	for (var idx = 1; idx < tblIngredients.rows.length; idx++)
	{
		objRow = tblIngredients.rows[idx];
		if (typeof (objRow) != 'undefined' && objRow.getAttribute("id") == "trIngredientContainer")
		{
			var objTblDose = objRow.all["trDose_Infusion"]

			if (objTblDose.getAttribute("dose_xml") != "") // Only return data for RX's that have a calculated dose.
			{
				strXML += "<rx ";

				strXML += "FormOrdinal='" + document.body.getAttribute("ordinal") + "' ";
				strXML += "ProductID='" + objTblDose.getAttribute("productid") + "' ";
				strXML += "RxType='Infusion' ";
				strXML += "Description='" + objRow.all["tdIngredientName"].getAttribute("atomicname") + "' ";
				strXML += "Route='" + lstRoute.options[lstRoute.selectedIndex].text + "' ";
				strXML += "StartDate='" + objDateControl.GetTDate() + "' ";

				// Dose
				strXML += "Dose_Low='0' ";
				strXML += "Dose='" + objTblDose.getAttribute("dose_original") + "' ";
				strXML += "Unit='" + objTblDose.getAttribute("unit_original") + "' ";
				strXML += "UnitID='' ";
				strXML += "RoutineID='" + objTblDose.getAttribute("routineid") + "' ";
				strXML += "RoutineName='" + objTblDose.getAttribute("routinedescription") + "' ";

				// Calculated Dose
				strXML += "Dose_Low_Calc='0' ";
				strXML += "Dose_Calc='" + objTblDose.getAttribute("dose_originalcalculated") + "' ";
				strXML += "UnitID_Calc='' ";
				strXML += "Unit_Calc='" + objTblDose.getAttribute("unit_original") + "' ";

				// Prescribed Dose
				strXML += "Dose_Low_Prescribed='0' ";
				strXML += "Dose_Prescribed='" + objTblDose.all["txtDose"].value + "' ";
				strXML += "UnitID_Prescribed='" + objTblDose.all["lstUnits"].options[objTblDose.all["lstUnits"].selectedIndex].getAttribute("dbid") + "' ";
				strXML += "Unit_Prescribed='" + objTblDose.all["lstUnits"].options[objTblDose.all["lstUnits"].selectedIndex].text + "' ";

				// Dose Cap
				strXML += "Dose_Cap='" + objTblDose.all["txtDoseCap"].value + "' ";
				strXML += "UnitID_Cap='" + objTblDose.all["lblDoseCapUnit"].getAttribute("dbid") + "' ";
				strXML += "Unit_Cap='' ";
				strXML += "Dose_Cap_Overridable='" + objTblDose.all["lnkDoseCapOverridable"].getAttribute("override") + "' ";

				// Dose Round
				strXML += "Dose_Round='" + objTblDose.all["txtRoundValue"].value + "' ";
				strXML += "UnitID_Round='" + objTblDose.all["txtRoundValue"].getAttribute("unitid") + "' ";
				strXML += "Unit_Round='' ";

				strXML += "Checked='" + (blnChecked ? "1" : "0") + "'"; 

				strXML += " />";
			}
		}
	}
	return strXML;
}

//
// Set dose and adjustment data on this form
//
function SetAdjustmentXML(ProductID, xmlnodeRx)
{
	switch (document.body.getAttribute('requesttype'))
	{
		case REQUESTTYPE_STANDARD:
			return SetAdjustmentXML_Standard(ProductID, xmlnodeRx);

		case REQUESTTYPE_DOSELESS:
			return SetAdjustmentXML_Standard(ProductID, xmlnodeRx);

		case REQUESTTYPE_INFUSION:
			return SetAdjustmentXML_Infusion(ProductID, xmlnodeRx);
	}
}

//
// Set the dose and adjustment data on a standard prescription form.
//
function SetAdjustmentXML_Standard(ProductID, xmlnodeRx)
{
	// Set prescribed dose from the adjustment XML node
	// When a single dose is used, then the dose if stored in "Dose_Prescribed", and Dose_Low_Prescribed is 0,
	// however, on screen the single dose is stored in the "From" field, and "To" is blank, so sadly we have to swap 
	// the values around!
	if (txtDoseQty.value = xmlnodeRx.getAttribute("Dose_Low_Prescribed") == "0")
	{
		txtDoseQty.value = (Math.round(Number(xmlnodeRx.getAttribute("Dose_Prescribed")) * 100) / 100).toString();
		txtDoseQty2.value = "";
	}
	else
	{
		txtDoseQty.value = (Math.round(Number(xmlnodeRx.getAttribute("Dose_Low_Prescribed")) * 100) / 100).toString();
		txtDoseQty2.value = (Math.round(Number(xmlnodeRx.getAttribute("Dose_Prescribed")) * 100) / 100).toString();
	}
	DisplayDoseDifference(document.getElementById("txtDoseQty"));
	DescriptionChangeRequired();
	
//	SetListItem(lstUnits, xmlnodeRx.getAttribute("UnitID_Prescribed")); We won't update units, because the adjustment form doesn't cha\nge units anyway.
}

//
// Set the dose and adjustment data on an infusion prescription form.
//
function SetAdjustmentXML_Infusion(ProductID, xmlnodeRx)
{
	// Set prescribed dose from the adjustment XML node

	for (var idx = 1; idx < tblIngredients.rows.length; idx++)
	{
		objRow = tblIngredients.rows[idx];
		if (typeof (objRow) != 'undefined' && objRow.getAttribute("id") == "trIngredientContainer")
		{
			var objTblDose = objRow.all["trDose_Infusion"]
			if (objTblDose.getAttribute("productid") == ProductID)
			{
			    objTblDose.all["txtDose"].value = (Math.round(Number(xmlnodeRx.getAttribute("Dose_Prescribed")) * 100) / 100).toString();
			    objTblDose.all["txtDose"].setAttribute("IsAdjustedDose", "True"); 
			    DisplayDoseDifference(objTblDose);

			    // F0042323 ST 07Jan09
			    // Not entirely sure this call should be here as it's affecting the calculated doses when the page is refreshed.
			    //DoseChanged_Infusion(objTblDose);
			}
		}
    }
    //F0049605 ST 30Mar09   Update the description so that the side panel doesn't show the wrong dose!
    DescriptionChangeRequired();
	//	SetListItem(lstUnits, xmlnodeRx.getAttribute("UnitID_Prescribed")); We won't update units, because the adjustment form doesn't cha\nge units anyway.
}




//
// As we now have 3 rows to a calculated infusion we have these held in a container row in the table.
// This function will find the container row and then the line with the ingredient that belongs to the objSrc.
// This is mainly used for the calculation button which is now on a different row to the ingredient.
//
function GetIngredientFromChild(objSrc)
{
    var blnFound = false;
    var objElement = objSrc;
    var strNodeID = new String();
    
    do
    {
        strNodeID = objElement.id;
        strNodeID = strNodeID.toLowerCase();

        if (strNodeID == 'tringredientcontainer')
        {
            blnFound = true;
        }
        else
        {
            objElement = objElement.parentElement;
        }
    } while (!blnFound)

    if (blnFound)
    {
        objElement = objElement.all['trDose_Infusion'];
        return objElement;
    }

    return null;
}

function GetDifferenceRowFromChild(objSrc)
{
    var blnFound = false;
    var objElement = objSrc;
    var strNodeID = new String();

    do
    {
        strNodeID = objElement.id;
        strNodeID = strNodeID.toLowerCase();

        if (strNodeID == 'tringredientcontainer')
        {
            blnFound = true;
        }
        else
        {
            objElement = objElement.parentElement;
        }
    } while (!blnFound)

    if (blnFound)
    {
        objElement = objElement.all['trDoseDifference'];
        return objElement;
    }

    return null;
}


//
// Depending upon the prescription type standard/infusion this routine
// does an ajax call to calculate the difference between the calculated dose
// and the prescribed dose and returns the appropriate string (blank if no difference)
//
function DisplayDoseDifference(objSrc)
{
    var DoseSpecified = 0;
    var DoseSpecified_Low = 0;
    var DoseSpecifiedUnitID = 0;

    var DosePrescribed = 0;
    var DosePrescribed_Low = 0;
    var DosePrescribedUnitID = 0;

    if (!m_blnTemplateMode && IsCalculatedDose())
    {
        if (document.body.getAttribute('requesttype') == REQUESTTYPE_INFUSION)
        {
            var objRow = GetIngredientFromChild(objSrc);
            var objDifferenceRow = GetDifferenceRowFromChild(objSrc);

            DoseSpecified = objRow.getAttribute("dose_calculated");
            DoseSpecifiedUnitID = objRow.all["lstUnits"].options[objRow.all["lstUnits"].selectedIndex].getAttribute("dbid");

            DosePrescribed = objRow.all['txtDose'].value;
            DosePrescribedUnitID = objRow.all["lstUnits"].options[objRow.all["lstUnits"].selectedIndex].getAttribute("dbid");
        }
        else
        {
            var objDifferenceRow = document.all['trDoseDifference'];
            DosePrescribedUnitID = document.all['lstUnits'].options[document.all['lstUnits'].selectedIndex].getAttribute("dbid");
            DoseSpecifiedUnitID = document.all['trDoseSpecified'].getAttribute('unitid');

            if (document.getElementById("txtDoseQty2").value > 0)
            {
                DosePrescribed = document.getElementById("txtDoseQty2").value;
                DosePrescribed_Low = document.getElementById("txtDoseQty").value;
                DoseSpecified = document.all['lblDrugName'].getAttribute("calculation_calculateddose");
                DoseSpecified_Low = document.all['lblDrugName'].getAttribute("calculation_calculateddoselow");
            }
            else
            {
                DosePrescribed = document.getElementById("txtDoseQty").value;
                DosePrescribed_Low = 0;
                DoseSpecified = document.all['lblDrugName'].getAttribute("calculation_calculateddose");
                DoseSpecified_Low = 0;
            }
        }

		// F0075183 ST 04Feb10 Only perform the difference calculation if the calculated dose is greater than 0, this prevents a 10000% increase result
		if(Number(DoseSpecified) > 0)
		{
			var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
			var strURL = '../../OrderEntry/DoseDifference.aspx'
									 + '?SessionID=' + document.body.getAttribute("sid")
									 + '&DoseSpecified=' + DoseSpecified
									 + '&DoseSpecified_Low=' + DoseSpecified_Low
									 + '&DoseSpecified_UnitID=' + DoseSpecifiedUnitID
									 + '&DosePrescribed=' + DosePrescribed
									 + '&DosePrescribed_Low=' + DosePrescribed_Low
									 + '&DosePrescribed_UnitID=' + DosePrescribedUnitID;



			objHTTPRequest.open("POST", strURL, false);
			objHTTPRequest.setRequestHeader("Content-Type", "text/xml");
			objHTTPRequest.send("")
			strReturn = objHTTPRequest.responseText;

			if (objDifferenceRow != null)
			{
				objDifferenceRow.all['tdDoseDifference'].innerText = strReturn;
			}
		}
    }
}

//--------------------------------------------------------------------------------------------------------

/* 
12Oct08 PH
Fires when the Rx date is changed.
If the date is today, then time will be set to "now".
If the date is not today, then time will be set to "12:00"
*/
function UpdateRxStartTime(datEnteredDate)
{
	var strTEnteredDate = Date2TDate(datEnteredDate);
	var strTNow = Date2TDate(new Date());

	// If the entered date, today's date?
	if (strTEnteredDate.substr(0, 10) == strTNow.substr(0, 10))
	{
		// Is today's date, so set the time to now
		txtStartTime.value = strTNow.substr(11, 5);
	}
	else
	{
		// Is NOT today's date, so set the time to midnight
		txtStartTime.value = "00:00";
	}
}

//---------------------------------------------------------------------------------------------------------


function IsCalculatedDose()
{
    switch (document.body.getAttribute('requesttype'))
    {
        case REQUESTTYPE_STANDARD:
            return IsCalculatedDose_Standard();

        case REQUESTTYPE_DOSELESS:
            return IsCalculatedDose_Standard();

        case REQUESTTYPE_INFUSION:
            return IsCalculatedDose_Infusion();
    }
}


function IsCalculatedDose_Standard()
{
    var blnIsCalculatedDose = (lblDrugName.getAttribute('iscalculateddose') == 'true');
    
    return blnIsCalculatedDose;
}

function IsCalculatedDose_Infusion()
{
    var lngRoutineID = 0;
    for (var idx = 1; idx < tblIngredients.rows.length; idx++)
    {
        objRow = tblIngredients.rows[idx];
        if (typeof (objRow) != 'undefined' && objRow.getAttribute("id") == "trIngredientContainer")
        {
            var objTblDose = objRow.all["trDose_Infusion"];
            lngRoutineID = Number(objTblDose.getAttribute("routineid"));
            if (lngRoutineID > 0)
            {
                return true;
            }
        }
    }
    return false;
}

//F0051633 ST 27Apr09   Checks to see if the calculated dose button is disabled which would be the case if the calculation has failed.
//If there are multiple buttons (items) on the form then checks if they are all disabled or not.
function IsFailedCalculation() {
    var blnFailed = false;
    //F0052237 ST 07May09   Updated code to check to see if ingredients table exists (won't in the case of non infusion items) and if not then just get the adjustment button from the document

    if (document.all['tblIngredients'] != null && document.all['tblIngredients'] != 'undefined') {
        for (var idx = 1; idx < tblIngredients.rows.length; idx++) {
            objRow = tblIngredients.rows[idx];
            if (typeof (objRow) != 'undefined' && objRow.getAttribute("id") == "trIngredientContainer") {
                var objBtn = objRow.all["btnAdjust"];

                if (objBtn != null && objBtn != undefined) {
                    if (objBtn.disabled == true)
                        blnFailed = true;
                    else
                        blnFailed = false;
                }
            }
        }
    }
    else {
        var objBtn = document.all["btnAdjust"];

        if (objBtn != null && objBtn != undefined) {
            if (objBtn.disabled == true)
                blnFailed = true;
            else
                blnFailed = false;
        }
    }    
    return blnFailed;
}


function PopulateReviewDetails()
{
    if (m_blnTemplateMode)
    {
        if(GetValueFromXML('ReviewRequestTypeID') > 0)
        {
            SetListItem(lstReviewType, GetValueFromXML('ReviewRequestTypeID'));
        }
        
        txtReviewDate.value = GetValueFromXML('ReviewIn');

        if (GetValueFromXML('ReviewUnits') > 0)
        {
            SetListItem(lstReviewUnits, GetValueFromXML('ReviewUnits'));
        }

        if (GetValueFromXML('ReviewAction') > 0)
        {
            SetListItem(lstReviewDate, GetValueFromXML('ReviewAction'));
        }

        void SetReadonlyStatus(document.all['lstReviewType'], 'ReviewRequestTypeID');
        void SetReadonlyStatus(document.all['txtReviewDate'], 'ReviewIn');
    }
    else
    {
        if (document.getElementById("trReviewType") != null)
        {
            var objItem = instanceData.XMLDocument.selectSingleNode('//data/attribute[@name="ReviewRequestTypeID"]');
            if (objItem != undefined || objItem != null)
            {
                if (GetValueFromXML('ReviewRequestTypeID') > 0)					// type of review
                {
                    SetListItem(lstReviewType, GetValueFromXML('ReviewRequestTypeID'));
                    if (GetReadonlyStatusFromXML('ReviewRequestTypeID') == 1)
                    {
                        document.getElementById("lstReviewType").disabled = true;
                    }
                }
                else
                {
                    document.all('trReviewType').style.display = "none";
                    document.all('trReviewDays').style.display = "none";
                    document.all('trReviewDate').style.display = "none";
                    return;
                }

                txtReviewDate.value = GetValueFromXML('ReviewIn');
                if (GetReadonlyStatusFromXML('ReviewIn') == 1)
                {
                    document.getElementById("txtReviewDate").setAttribute("nowrite", "1");
                    document.getElementById("txtReviewDate").disabled = true;

                    cmdDecReview.disabled = true;
                    cmdIncReview.disabled = true;

                    lstReviewUnits.className = 'Disabled';
                    lstReviewUnits.disabled = true;
                    lstReviewUnits.selectedIndex = 0;
                }


                if (GetValueFromXML('ReviewUnits') > 0)						// days or weeks
                {
                    SetListItem(lstReviewUnits, GetValueFromXML('ReviewUnits'));
                }

                if (GetReadonlyStatusFromXML('ReviewUnits') == 1)
                {
                    document.getElementById("ReviewUnits").disabled = true;
                }

                if (GetValueFromXML('ReviewAction') > 0)						// review action
                {
                    SetListItem(lstReviewDate, GetValueFromXML('ReviewAction'));
                }

                if (GetReadonlyStatusFromXML('ReviewAction') == 1)
                {
                    document.getElementById("ReviewAction").disabled = true;
                }


                void SetReadonlyStatus(document.all['lstReviewType'], 'ReviewRequestTypeID');
                void SetReadonlyStatus(document.all['txtReviewDate'], 'ReviewIn');
            }
            else if (Number(document.getElementById("trReviewType").getAttribute("dbid") > 0))
            {
                // Review details have been scripted onto the form
                // We need to set the review request type in the combo box here
                var objSelect = document.getElementById("lstReviewType");
                var idx;

                if (objSelect != null)
                {
                    for (idx = 0; idx < objSelect.options.length; idx++)
                    {
                        if (objSelect.options[idx].getAttribute("dbid") == document.getElementById("trReviewType").getAttribute("dbid"))
                        {
                            objSelect.options[idx].selected = true;
                            break;
                        }
                    }
                }
            }
            else
            {
                document.all('trReviewType').style.display = "none";
                document.all('trReviewDays').style.display = "none";
                document.all('trReviewDate').style.display = "none";
                return;
            }
        }
    }
}


// Determines if the current prescription is a RATE BASED INFUSION
function IsRateBased() {
    var blnInfusion = (document.body.getAttribute('requesttype') == REQUESTTYPE_INFUSION);

    if (document.all['lstFrequency'] == undefined && blnInfusion) {
        return true;
    }
    else {
        return false;
    }
}

//If openning an existing template with a deleted direction, alert msg to user and remove the direction
//19Apr10 JMei F0082951 still display deleted direction for created template but not for updating template
function RemoveDeletedDirection() {
    var eleTxtDirection = document.getElementById("txtExtra");
    if (eleTxtDirection != null) {
        eleTxtDirection.innerText = "";
        eleTxtDirection.setAttribute("dbid","");
        alert("This template uses a direction text that is no longer in use on the system.\n\nThis text has now been removed from this template.");
    }

}


//function IsReasonCaptureFilled()
//{
//    debugger;
//    var oReasonCtl = document.getElementById('lstReason');
//    if (oReasonCtl != undefined)
//    {
//        if (oReasonCtl.options[oReasonCtl.selectedIndex].text == "") 
//            return false;
//    }
//    
//    return true;
//}