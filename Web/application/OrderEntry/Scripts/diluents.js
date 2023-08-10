//22Apr09   Rams    F0051337 Before encaping the number function, the content from the form is correct to be a proper numeric string
//
// OnChange event for the devices drop down list
//
function lstDevices_onchange()
{
    var objSelect = document.getElementById("lstDevices");

    if(objSelect != undefined && objSelect.selectedIndex > -1 && Number(objSelect.options[objSelect.selectedIndex].getAttribute('volumerequired') > -1))
    {
        var blnVolume = Number(objSelect.options[objSelect.selectedIndex].getAttribute('volumerequired'));
        
        if(!blnVolume)
        {
            document.all['trNoVolumeWarning'].style.visibility = 'visible';
            Dilution_SetState(true);
            return;
        }
    }
    document.all['trNoVolumeWarning'].style.visibility = 'hidden';    
    Dilution_SetState(false);
}

//
// Handler for the EXACT radio button
//
function rbDiluentQtyExact_onclick(blnReset)
{
    var idx = 0;
    var colIngredients = tblDiluents.all['tdDilutionIngredientLabel'];
    // 24Mar2010 CD F0081306 Changed text when switching between nominal and exact values
    if(colIngredients != undefined && colIngredients.length == undefined)
    {
        // Is the case when there is actually only one of the elements in the html
        document.getElementById("tdDilutionIngredientLabel").innerText = "(Infusion rate will be calculated in Drug Administration)";
    }
    else
    {
        for(idx = 0; idx < colIngredients.length; idx++)
        {
            colIngredients[idx].innerText = "(Infusion rate will be calculated in Drug Administration)";
        }
    }
    document.getElementById("tdDiluentFinalVolume").innerText = "(Infusion rate will be calculated in Drug Administration)";
    document.getElementById("rbDiluentQtyNominal").checked = false;

    // F0082460 ST 31Mar10
    // As per discussions we now unhide a couple of sections when the nominal button is selected and reset the values on screen
    document.getElementById("trFinalConcentrationLabel").style.display = '';
    document.getElementById("trFinalConcentration").style.display = '';
    document.getElementById("trCalculationsLink").style.display = '';
    document.getElementById("trReconstitutionLabel").style.display = '';
    document.getElementById("trReconstitutionInstructionLabel").style.display = '';
    document.getElementById("trReconstitutionDivider").style.display = '';

    // F0082683 ST 01Apr10 Show all instances of the elements in the page
    if (document.all["trReconstitution"].length > 1) {
        for (idx = 0; idx < document.all["trReconstitution"].length; idx++) {
            document.all["trReconstitution"][idx].style.display = '';
        }
    }
    else {
        document.getElementById("trReconstitution").style.display = '';
    }

    if (document.all["trFinalConcentration"].length > 1) {
        for (idx = 0; idx < document.all["trFinalConcentration"].length; idx++) {
            document.all["trFinalConcentration"][idx].style.display = '';
        }
    }
    else {
        document.getElementById("trFinalConcentration").style.display = '';
    }

    //F0082841 ST 06Apr10 If we are first loading the page then don't reset the display.
    if (blnReset)
        ResetValues();
}

//
// Handler for the Nominal radio button
//
function rbDiluentQtyNominal_onclick(blnReset)
{
    var idx = 0;
    var colIngredients = tblDiluents.all['tdDilutionIngredientLabel'];
    
    // 24Mar2010 CD F0081306 Changed text when switching between nominal and exact values
    if(colIngredients != undefined && colIngredients.length == undefined)
    {
        // Is the case when there is actually only one of the elements in the html
        document.getElementById("tdDilutionIngredientLabel").innerText = "(Infusion rate will NOT be calculated in Drug Administration)";
    }
    else
    {
        for(idx = 0; idx < colIngredients.length; idx++)
        {
            colIngredients[idx].innerText = "(Infusion rate will NOT be calculated in Drug Administration)";
        }
    }

    document.getElementById("tdDiluentFinalVolume").innerText = "(Infusion rate will NOT be calculated in Drug Administration)";
    document.getElementById("rbDiluentQtyExact").checked = false;

    // F0082460 ST 31Mar10
    // As per discussions we now hide a couple of sections when the nominal button is selected and copy the final volume into the diluent quantity
    document.getElementById("trFinalConcentrationLabel").style.display = 'none';
    document.getElementById("trCalculationsLink").style.display = 'none';
    document.getElementById("trReconstitutionLabel").style.display = 'none';
    document.getElementById("trReconstitutionInstructionLabel").style.display = 'none';
    document.getElementById("trReconstitutionDivider").style.display = 'none';

    // F0082683 ST 01Apr10 Hide all instances of the elements in the page
    if (document.all["trReconstitution"].length > 1) {
        for (idx = 0; idx < document.all["trReconstitution"].length; idx++) {
            document.all["trReconstitution"][idx].style.display = 'none';
        }
    }
    else {
        document.getElementById("trReconstitution").style.display = 'none';
    }

    if (document.all["trFinalConcentration"].length > 1) {
        for (idx = 0; idx < document.all["trFinalConcentration"].length; idx++) {
            document.all["trFinalConcentration"][idx].style.display = 'none';
        }
    }
    else {
        document.getElementById("trFinalConcentration").style.display = 'none';
    }
    
    document.getElementById("txtDiluentQty").value = document.getElementById("txtDiluentFinalVolume").value;
}

//
// Sets the state of the controls on the form to enabled/disabled
//
function Dilution_SetState(blnState)
{
    var colIngredientsConcentrations = document.getElementById("tblDiluents").all['tdIngredientConcentration'];

    // 24Mar2010 CD F0081306 No longer automatically changed the nominal and exact options
//    document.getElementById("rbDiluentQtyNominal").disabled = blnState;
//    document.getElementById("rbDiluentQtyExact").disabled = blnState;
    document.getElementById("txtDiluentFinalVolume").disabled = blnState;
    document.getElementById("txtDiluentQty").disabled = blnState;
    document.getElementById("txtPrimaryIngredientConcentration").disabled = blnState;
    
    if(blnState)
    {
        // 24Mar2010 CD F0081306 No longer automatically changed the nominal and exact options
//        document.getElementById("rbDiluentQtyNominal").checked = false;
//        document.getElementById("rbDiluentQtyExact").checked = false;
        document.getElementById("txtDiluentFinalVolume").value = "";
        document.getElementById("txtDiluentQty").value = "";
        document.getElementById("txtPrimaryIngredientConcentration").value = "";
        
        // Also blank the other ingredients concentrations
        if(colIngredientsConcentrations != null)
        {
            if(colIngredientsConcentrations.length != undefined)
            {
                for(idx = 0; idx < colIngredientsConcentrations.length; idx++)
                {
                    colIngredientsConcentrations[idx].innerText = "";
                }
            }
            else
            {
                colIngredientsConcentrations.innerText = "";
            }
        }
    }                    
}

//
// Handler for the OK button
//
function btnOK_onclick()
{
	var strReturn = 'ok';
	var lngProductID = 0;
	var strProductName = '';
	var objSelect;
	var blnTemplateMode = false;
	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");  
	var blnDisplayMode = document.body.getAttribute('DisplayMode'); 
	var lngSessionID = document.body.getAttribute('sid');
	var lngRequestID = document.body.getAttribute('requestid');
	    
    var strDiluentXML = GatherDataAsXML();
    
    if(blnDisplayMode == "True" )				
    {
        //
        // If we are editing diluents whilst in display mode then we save the data here
        //
        var strURL = '../OrderEntry/DiluentWorker.aspx'
                            + '?SessionID=' + lngSessionID
                            + '&RequestID=' + lngRequestID
                            + '&Mode=SaveDiluent';
                            
        objHTTPRequest.open("POST", strURL, false);
        objHTTPRequest.setRequestHeader("Content-Type", "text/xml");
        objHTTPRequest.send(strDiluentXML);
        objHTTPRequest.responseText;
        
        window.returnValue = "saved";
        void window.close();
	}



     // 23May08 AE Always save into state as we need to update some prescription info even in display mode
     // Now save it into state and if the dose has been recalculated then save that back to the form

     // save our data to sessionattribute
	 var strURL = '../OrderEntry/SessionAttributeSave.aspx'
		                + '?SessionID=' + lngSessionID
				        + '&Mode=set'
				        + '&Attribute=' + "OrderEntry/SavedDiluent";

     objHTTPRequest.open("POST", strURL, false);	//false = syncronous    
	 objHTTPRequest.setRequestHeader("Content-Type", "text/xml");                            
	 objHTTPRequest.send(strDiluentXML);
	 objHTTPRequest.responseText;
	       
	       
	 window.returnValue = strReturn;
	 if(IsCalculatedDose() && IsTemplateMode())
	 {
	    void window.close();
	 }
	 else
	 {
	     if(Number(document.getElementById("txtDose").value) > 0)
	     {
	         var strURL = '../OrderEntry/SessionAttributeSave.aspx'
				            + '?SessionID=' + lngSessionID
				            + '&Mode=set'
				            + '&Attribute=' + "OrderEntry/SavedDose";

             objHTTPRequest.open("POST", strURL, false);	//false = syncronous    
	         objHTTPRequest.setRequestHeader("Content-Type", "text/xml");                    
	         objHTTPRequest.send(document.getElementById("txtDose").value);
	         objHTTPRequest.responseText;
         }
     }
	 void window.close();
}

//
// Handler for the cancel button
//
function btnCancel_onclick()
{
    window.close();
}


//
// Window onload event handler
//
function window_onload() {
    parent.frames['fraReconstitutionDiluent'].parent.document.title = 'Reconstitution and Diluent';
    CheckIfComplete();
    lstDevices_onchange();
    
    // F0082841 ST 06Apr10 Don't redo everything if we've just reloaded the page which will be the case if we cancelled from the reconstitution form
    if (document.body.getAttribute("Mode") == "Reload") {
        return;
    }


    // F0083669 ST 16Apr10 If we have any ingredients in mls then we don't want to allow exact to be chosen
    if (!IsDisplayMode() && AnyIngredientsInMls() && document.getElementById("rbDiluentQtyExact").checked == true) {
        alert('This template has one or more ingredients dosed by volume.\n\nIf you resave then the calculation will be saved to nominal.');
        document.getElementById("rbDiluentQtyExact").checked = false;
        document.getElementById("rbDiluentQtyExact").disabled = true;
        document.getElementById("rbDiluentQtyNominal").checked = true;
        document.getElementById("rbDiluentQtyNominal").disabled = false;
    }
    
    
    //07Apr09   Rams    Are the values to be recalculated?
    if (document.getElementById("txtReCalculate").value == "true") {
        // 24Mar2010 CD F0081306 If we have the recalculate field set reset all the values
        ResetValues();
    }
    else {
        // F0082410 ST 30Mar10 If loading the page and not in template but a calculated dose the recalculate ingredient concentrations
        if (!IsTemplateMode() && IsCalculatedDose()) {
            CalculateIngredientFinalConcentration();
            CalculateSecondaryIngredientFinalConcentration();
        }
    }


    // F0083669 ST 16Apr10 If we have any ingredients in mls then we don't want to allow exact to be chosen
    if (!IsDisplayMode() && AnyIngredientsInMls()) {
        document.getElementById("rbDiluentQtyExact").checked = false;
        document.getElementById("rbDiluentQtyExact").disabled = true;
        document.getElementById("rbDiluentQtyNominal").checked = true;
        document.getElementById("rbDiluentQtyNominal").disabled = false;
    }

    // F0083669 ST 16Apr10 If viewing back then disable both the exact and nominal radio buttons
    if(IsDisplayMode()) {
        document.getElementById("rbDiluentQtyExact").disabled = true;
        document.getElementById("rbDiluentQtyNominal").disabled = true;
    }
    
    //
    // Ensure that if either of the radio buttons are checked the screen is up to date
    if (document.getElementById("rbDiluentQtyNominal").checked == true)
        rbDiluentQtyNominal_onclick(false);

    if (document.getElementById("rbDiluentQtyExact").checked == true) {
        rbDiluentQtyExact_onclick(false);
        txtDiluentFinalVolume_onblur(true);
        //dblTotalDose = GetTotalDose();
        //txtDiluentQty_onblur(true);
        //document.getElementById("txtDiluentQty").value = Number(document.getElementById("txtDiluentFinalVolume").value) - dblTotalDose;
        //document.getElementById("txtDiluentQty").value = Number(document.getElementById("txtDiluentQty").value) - dblTotalDose;
    }

}

//
// 24Mar2010 CD F0081306
// Checks to see if all ingredients have been reconstituted or don't require reconstitution 
//
function AreIngredientsReconstituted() {
    var blnResult = true;
    var idx = 0;
    var colIngredients = document.all['tdReconstitutedIngredients'];
    if (colIngredients != undefined && colIngredients.length == undefined) {
        if (colIngredients.innerText == 'Not Specified' || colIngredients.innerText == 'Incomplete') {
            blnResult = false;
        }
    }
    else {
        for (idx = 0; idx < colIngredients.length; idx++) {
            if (colIngredients[idx].innerText == 'Not Specified' || colIngredients[idx].innerText == 'Incomplete') {
                blnResult = false;
            }
        }
    }

    return blnResult;
}

//
// Checks to see if all solids have been reconstituted or don't require reconstitution 
//
function AreSolidsReconstituted()
{
    var blnResult = true;
    var idx = 0;
    var colIngredients = document.all['tdReconstitutedIngredients'];
    
    if(colIngredients != undefined && colIngredients.length == undefined)
    {
        if(colIngredients.getAttribute("issolid") == "True")
        {
            if(colIngredients.innerText == 'Not Specified' || colIngredients.innerText == 'Incomplete')
            {
                blnResult = false;
            }
        }
    }
    else
    {
        for(idx = 0; idx < colIngredients.length; idx++)
        {
            if(colIngredients[idx].getAttribute("issolid") == "True")
            {
                if(colIngredients[idx].innerText == 'Not Specified' || colIngredients[idx].innerText == 'Incomplete')
                {
                    blnResult = false;
                }
            }
        }
    }
    
    return blnResult;
}

//
// Calculate the final volume quantity
//
function CalculateFinalVolume()
{
    var idx;
    var lngDiluentQuantity = 0;
    var lngFinalVolume = 0;
    var lngVolofIngredients = 0;

    if(IsCalculatedDose() && IsTemplateMode())
    {
        return lngFinalVolume;
    }
    else
    {
            //12Feb10   Rams    F0077357 - The nominal check box within the diluent form does not work.
            lngDiluentQuantity = Number(document.getElementById("txtDiluentQty").value);
            lngVolofIngredients = VolumeOfIngredients();
            if(lngDiluentQuantity > 0)  //&& lngVolofIngredients > 0)
            {
                lngResult = lngDiluentQuantity + lngVolofIngredients;
                //lngFinalVolume = Math.round(lngResult * 100)/100;

                lngFinalVolume = RoundToDecPl(lngResult,2);
                document.getElementById("txtDiluentFinalVolume").setAttribute("iscalculated", "True");
                document.getElementById("txtDiluentFinalVolume").className += ' calculated';
                document.getElementById("txtDiluentFinalVolume").setAttribute("calculated", String(lngFinalVolume));               

            }
    }    
    return lngFinalVolume;
}

function IsCalculatedDose()
{
    if(document.getElementById("tdPrimaryIngredientPrescribed").getAttribute("Routine") != "")
    {
        return true;
    }
    else
    {
        return false;
    }
}

function IsTemplateMode()
{
    if(document.body.getAttribute('TemplateMode') == "False")
    {
        return false;
    }
    else
    {
        return true;
    }
}

//
// Calculate the volume of ingredients
//
function VolumeOfIngredients() {
    return VolumeOfLiquidIngredients() + VolumeOfSolidIngredients();
}

//
// Calculate the volume of liquid ingredients
//
function VolumeOfLiquidIngredients() {
    var idx = 0;
    var lngVolumeofLiquidIngredients = 0;
    var colIngredients = tblDiluents.all['tdReconstitutedIngredients'];
    var liquidVolume = 0;
    var reconstitutedVolume = 0;
    
    if(colIngredients != undefined && colIngredients.length == undefined)
    {
        // Is the case when there is actually only one of the elements in the html
		lngVolumeofLiquidIngredients += LiquidVolume(colIngredients);											//30May08 AE  Use new LiquidVolume() function to deal with reconstituted liquids
    }
    else
    {    
        for(idx = 0; idx < colIngredients.length; idx++)
        {
			lngVolumeofLiquidIngredients += LiquidVolume(colIngredients[idx]);
        }
    }
    return (lngVolumeofLiquidIngredients);
}

function LiquidVolume(objHTMLElement){

//Returns the volume of liquid specified for this reconstituted or unreconstituted liquid
    if (objHTMLElement.getAttribute("issolid") == "False") {
		var liquidVolume = objHTMLElement.getAttribute("liquidvolume");;
		var reconVolume = objHTMLElement.getAttribute("reconstitutionvolume");
		return Number(reconVolume == null ? liquidVolume : reconVolume.replace(',',''));
	}
	else {
		return 0;
	}
}


function VolumeOfSolidIngredients()
{
    var idx = 0;
    var lngVolumeofSolidIngredients = 0;
    var colIngredients = tblDiluents.all['tdReconstitutedIngredients'];
    
    if(colIngredients != undefined && colIngredients.length == undefined)
    {
        // Is the case when there is actually only one of the elements in the html
        if(colIngredients.getAttribute("issolid") == "True")
        {
            lngVolumeofSolidIngredients = lngVolumeofSolidIngredients + Number(colIngredients.getAttribute("reconstitutionvolume")!=null? colIngredients.getAttribute("reconstitutionvolume").replace(',',''): 0);
        }
    }
    else
    {    
        for(idx = 0; idx < colIngredients.length; idx++)
        {
            if(colIngredients[idx].getAttribute("issolid") == "True")
            {
                lngVolumeofSolidIngredients = lngVolumeofSolidIngredients + Number(colIngredients[idx].getAttribute("reconstitutionvolume")!= null ?colIngredients[idx].getAttribute("reconstitutionvolume").replace(',','') : 0);
            }
        }
    }
    return (lngVolumeofSolidIngredients);
}

//
// Calculate the dose of the primary ingredient
//
function CalculateDose()
{
    var lngSessionID = document.body.getAttribute('sid');
    var lngRequestID = document.body.getAttribute('requestid');
    var blnTemplateMode = IsTemplateMode();
    var blnDisplayMode = document.body.getAttribute('DisplayMode');

    var lngFinalVolume = Number(document.getElementById("txtDiluentFinalVolume").value);
    var lngConcentration = Number(document.getElementById("txtPrimaryIngredientConcentration").value);
   
    if(lngFinalVolume > 0)
    {
        //document.getElementById("txtDose").value = lngFinalVolume / lngConcentration;
        //29May08 ST  -  Changed to a multiplication 
        
        document.getElementById("txtDose").value = lngFinalVolume * lngConcentration;
        document.getElementById("txtDose").setAttribute("iscalculated", "True");
        document.getElementById("txtDose").setAttribute("calculated", String(lngFinalVolume / lngConcentration));
        document.getElementById("txtDose").className += ' calculated';
        document.getElementById("tblDiluents").all['tdPrimaryIngredientPrescribed'].setAttribute("Dose", document.getElementById("txtDose").value)
        // 29May08 ST   Need to update the liquidvolume attributes now that we have a dose calculated
        UpdateLiquidVolume();
        UpdateReconstitutionVolume();
    }
}

//
// Calculate the concentration of secondary etc ingredients
//
function CalculateSecondaryIngredientFinalConcentration()
{
    var colIngredientsPrescribed = document.getElementById("tblDiluents").all['tdIngredientPrescribed'];
    var colIngredientsConcentrations = document.getElementById("tblDiluents").all['trConcentrationSecondary'];
    var dblFinalVolume = Number(document.getElementById("txtDiluentFinalVolume").value);
    var idx;
    var lngDose;
    var lngResult = 0;
    var lngUnitID = 0;

    // Quicky check to see if there are more than just the primary ingredients    
    if(colIngredientsPrescribed != null)
    {
        if(colIngredientsPrescribed.length != undefined)
        //multiple secondary ingredients
        {
            for(idx = 0; idx < colIngredientsPrescribed.length; idx++)
            {
					CalculateSecondaryIngredientFinalConcentration_Row(colIngredientsPrescribed[idx], colIngredientsConcentrations[idx], dblFinalVolume);					
            }
        }
        else
        //just the one
        {
				CalculateSecondaryIngredientFinalConcentration_Row(colIngredientsPrescribed, colIngredientsConcentrations, dblFinalVolume);					
        }
    }
}


function CalculateSecondaryIngredientFinalConcentration_Row(objProductCell, objConcentrationRow, FinalVolume){

//Performs the calculation for the given secondary ingredient row
	var dblDose = Number(objProductCell.getAttribute("Dose"));
	var lngUnitID = Number(objProductCell.getAttribute("unitid"));
	var strUnit = objConcentrationRow.all['tdIngredientConcentrationUnit'].innerText;
	
	if(dblDose > 0 && FinalVolume > 0)
	{
        //Calculate the concentration
        if(dblDose > 0 && FinalVolume > 0)
        {
            var dblResult = dblDose / FinalVolume;
        }
        else
        {
            var dblResult = 0;
        }
      
	  
	  if (dblResult < 1){
		//Convert 0.xxxx into a smaller unit
			var strResult_XML = ConvertToSmallestUnit (document.body.getAttribute('sid'), dblResult, lngUnitID)

            //F0083673 ST 15Apr10 Check to see if we have some data before processing it
			if (strResult_XML != "") {
			    var DOM = new ActiveXObject("MSXML2.DOMDocument");
			    DOM.loadXML(strResult_XML);
			    var xmlConverted = DOM.selectSingleNode('*');
			    lngUnitID = xmlConverted.getAttribute('UnitID');
			    strUnit = xmlConverted.getAttribute('Abbreviation') + '/mL';
			    dblResult = Number(xmlConverted.getAttribute('Value_Converted'));
			}
	  }
	  //Update the screen
	  objConcentrationRow.all['tdIngredientConcentration'].innerText = RoundToDecPl(dblResult, 2);
	  objConcentrationRow.all['tdIngredientConcentrationUnit'].innerText = strUnit;
	}
}


//
// Calculate the final concentration of the primary ingredient
//
function CalculateIngredientFinalConcentration()
{
    var colIngredientsPrescribed = document.getElementById("tblDiluents").all['tdIngredientPrescribed'];
    var colIngredientsConcentrations = document.getElementById("tblDiluents").all['tdIngredientConcentration'];
    var lngFinalVolume = Number(document.getElementById("txtDiluentFinalVolume").value);
    var idx;
    var dblDose;
    var dblResult = 0;
    var lngCalculation = 0;
    var strResult = '';
    var strCalculation = '';
    var pos = 0;
    var conversionFactor = 1;

    // Calculate the primary ingredient
    dblDose = document.getElementById("tdPrimaryIngredientPrescribed").getAttribute("Dose");
    lngDoseUnit = document.getElementById("tdPrimaryIngredientPrescribed").getAttribute("unitid");
    strUnit = document.getElementById('FinalConcentrationUnit_Primary').innerText;
    
    if(Number(dblDose) > 0 && lngFinalVolume > 0)
    {
        dblResult = dblDose/lngFinalVolume;

		 //Convert to the smallest unit that lets us display the figure as an integer
		 if (Number(dblResult) < 1){
			//We have a decimal begining with 0.x, so convert its unit if possible
			var strResult_XML = ConvertToSmallestUnit (document.body.getAttribute('sid'), dblResult, lngDoseUnit)

			//F0083673 ST 15Apr10 Check to see if we have some data before processing it
			if (strResult_XML != "") {
			    var DOM = new ActiveXObject("MSXML2.DOMDocument");
			    DOM.loadXML(strResult_XML);
			    var xmlConverted = DOM.selectSingleNode('*');
			    lngDoseUnit = xmlConverted.getAttribute('UnitID');
			    strUnit = xmlConverted.getAttribute('Abbreviation') + '/mL';
			    dblResult = xmlConverted.getAttribute('Value_Converted');
			    conversionFactor = Number(xmlConverted.getAttribute('ConversionFactor'));
			}
		 }
	}
    else
    {
       //12Feb10   Rams    F0076088 - On the Reconstitution and Diluent screen, if the user amends the Final Concentration value of the primary ingrediant, no amendment is to the calculated values
       //set the calculated concentration to Zero
       dblResult = 0;
    }
    //Update the screen
    document.getElementById("txtPrimaryIngredientConcentration").value = RoundToDecPl(dblResult, 2);
    document.getElementById('FinalConcentrationUnit_Primary').innerText = strUnit;
    document.getElementById("txtPrimaryIngredientConcentration").setAttribute("iscalculated", "True");
    document.getElementById("txtPrimaryIngredientConcentration").setAttribute("calculated", String(dblResult));
    document.getElementById("txtPrimaryIngredientConcentration").setAttribute("unitid", String(lngDoseUnit));
    document.getElementById("txtPrimaryIngredientConcentration").setAttribute("conversionfactor", String(conversionFactor));
    document.getElementById("txtPrimaryIngredientConcentration").className += ' calculated';       
    //            
    CalculateSecondaryIngredientFinalConcentration();
    //
}


function ConvertToSmallestUnit(SessionID, Value_IN, UnitID_IN)
{

   var strData_XML = "";
	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");   
	
	var strURL = '../OrderEntry/DiluentWorker.aspx'
				  + '?SessionID=' + SessionID
				  + '&Mode=ConvertToSmallestUnit';
    
    strData_XML = "<Value Value='" + Value_IN + "'";
    strData_XML = strData_XML + " UnitID='" + UnitID_IN + "'";
    strData_XML = strData_XML + "/>";
    
	objHTTPRequest.open("POST", strURL, false);	//false = syncronous    
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");                            //application/x-www-form-urlencoded
	objHTTPRequest.send(strData_XML);
	
	return (objHTTPRequest.responseText);
}


//
// OnBlur handler for the diluent quantity edit
//
function txtDiluentQty_onblur(blnCalculate) {
    // 24Mar2010 CD F0081306 Only recalculate if all ingredients have reconstitution values
    if (blnCalculate && AreIngredientsReconstituted())
    {
        if(IsDoseEntered())
        {
            if(!IsFinalVolumeEntered())
            {
                //calculate final volume
                document.getElementById("txtDiluentFinalVolume").value = CalculateFinalVolume(); 
            }
            
            if(!IsTemplateMode())
            {
                if(!IsFinalConcentrationEntered())
                {
                    // calculate final concentration
                    CalculateIngredientFinalConcentration();
                }
            }
            else
            {
                if(!IsCalculatedDose())
                {
                    if(!IsFinalConcentrationEntered())
                    {
                        // calculate final concentration
                        CalculateIngredientFinalConcentration();
                    }
                }
            }
        }
        else
        {
            if(IsFinalConcentrationEntered())
            {
                //calculate dose
                if(!IsTemplateMode() && !IsCalculatedDose())
                {
                    CalculateDose();
                }

                //calculate final volume
                document.getElementById("txtDiluentFinalVolume").value = CalculateFinalVolume(); 
            }
        }
// 24Mar2010 CD F0081306 No longer automatically changed the nominal and exact options
//        document.getElementById("rbDiluentQtyExact").checked = false;
//        document.getElementById("rbDiluentQtyExact").disabled = false;
//        document.getElementById("rbDiluentQtyNominal").checked = false;
//        document.getElementById("rbDiluentQtyNominal").disabled = false;
    }
}

//
// OnBlur handler for the diluent final volume edit
//
function txtDiluentFinalVolume_onblur(blnCalculate) {
    var dblResult;
    var Routine = tblDiluents.all['tdPrimaryIngredientPrescribed'].getAttribute("Routine");
    var dblTotalDose = 0;

    // 24Mar2010 CD F0081306 Only recalculate if all ingredients have reconstitution values
    if (blnCalculate && AreIngredientsReconstituted())
    {
        if(IsDoseEntered() && Routine == '')
        {
            //calculate diluent quantity
            if(Number(document.getElementById("txtDiluentFinalVolume").value) > 0)
            {
                // only calculate if final volume is greater than 0
                dblResult = RoundToDecPl(Number(document.getElementById("txtDiluentFinalVolume").value) - VolumeOfIngredients(), 2);
                
                document.getElementById("txtDiluentQty").value = dblResult;
                document.getElementById("txtDiluentQty").setAttribute("iscalculated", "True");
                document.getElementById("txtDiluentQty").setAttribute("calculated", String(dblResult));
                document.getElementById("txtDiluentQty").className += ' calculated';
            }
            //calculate final concentration
            if(!IsTemplateMode())
            {
                CalculateIngredientFinalConcentration();
            }
            else
            {
                if(!IsCalculatedDose())
                {
                    CalculateIngredientFinalConcentration();
                }
            }
        }
        else 
        {
            if (IsFinalConcentrationEntered()) {
                //calculate dose
                if (!IsCalculatedDose()) {
                    CalculateDose();
                }

                //calculate diluent quantity
                dblResult = RoundToDecPl(Number(document.getElementById("txtDiluentFinalVolume").value) - VolumeOfIngredients(), 2);

                document.getElementById("txtDiluentQty").value = dblResult;
                document.getElementById("txtDiluentQty").setAttribute("iscalculated", "True");
                document.getElementById("txtDiluentQty").setAttribute("calculated", String(dblResult));
                document.getElementById("txtDiluentQty").className += ' calculated';
            }
            else {
                //F0082410 ST 30Mar10 Recalculate the diluent qty and optionally the ingredient concentration
                //calculate diluent quantity
                dblResult = RoundToDecPl(Number(document.getElementById("txtDiluentFinalVolume").value) - VolumeOfIngredients(), 2);

                document.getElementById("txtDiluentQty").value = dblResult;
                document.getElementById("txtDiluentQty").setAttribute("iscalculated", "True");
                document.getElementById("txtDiluentQty").setAttribute("calculated", String(dblResult));
                document.getElementById("txtDiluentQty").className += ' calculated';
            
                if (!IsTemplateMode() && IsCalculatedDose()) {
                    CalculateIngredientFinalConcentration();
                    CalculateSecondaryIngredientFinalConcentration();
                }
            }
        }
        // 24Mar2010 CD F0081306 No longer automatically changed the nominal and exact options
//        document.getElementById("rbDiluentQtyExact").checked = true;
//        document.getElementById("rbDiluentQtyExact").disabled = true;
//        document.getElementById("rbDiluentQtyNominal").checked = false;
//        document.getElementById("rbDiluentQtyNominal").disabled = true;
    }



    // F0082460 ST 31Mar10
    // As per discussions we now hide a couple of sections when the nominal button is selected and copy the final volume into the diluent quantity

    if (document.getElementById("rbDiluentQtyNominal").checked == true) {
        document.getElementById("txtDiluentQty").value = document.getElementById("txtDiluentFinalVolume").value;
    }

    if (document.getElementById("rbDiluentQtyExact").checked == true) {
        //dblTotalDose = GetTotalDose();
        //document.getElementById("txtDiluentQty").value = Number(document.getElementById("txtDiluentFinalVolume").value) - dblTotalDose;
        //document.getElementById("txtDiluentQty").value = Number(document.getElementById("txtDiluentQty").value) - dblTotalDose;
    }
}

//
// OnBlur handler for the primary ingredient concentration edit
//
function txtPrimaryIngredientConcentration_onblur(blnCalculate)
{
    var lngDose;
    var dblResult;

    // 24Mar2010 CD F0081306 Only recalculate if all ingredients have reconstitution values
    if (blnCalculate && !IsTemplateMode() && AreIngredientsReconstituted())
    {
        //Final concentration = Primary Ingredient Dose/Diluent Volume
        if(IsDoseEntered())
        {
            //12Feb10   Rams    F0076088 - On the Reconstitution and Diluent screen, if the user amends the Final Concentration value of the primary ingrediant, no amendment is to the calculated values
            //Calculate the diluent Final Volume
            //Diluent Final Volume = Dose (Primary Ingredient) / Final Concentration
            var dblDose = document.getElementById("tdPrimaryIngredientPrescribed").getAttribute("Dose");
            var lngDoseUnit = document.getElementById("tdPrimaryIngredientPrescribed").getAttribute("unitid");
            var lngConcentrationUnit = document.getElementById("txtPrimaryIngredientConcentration").getAttribute("unitid");
            var conversionFactor = document.getElementById('txtPrimaryIngredientConcentration').getAttribute("conversionfactor");    
            var lngFinalConcentration = document.getElementById('txtPrimaryIngredientConcentration').value; 
            
            //If units are not different convert Unit Dose to Final Concentration as this is the smallest
            if (lngDoseUnit != lngConcentrationUnit)
            {
                if(conversionFactor== undefined || conversionFactor==null)
                {
                    var strResult_XML = ConvertToSmallestUnit(document.body.getAttribute('sid'), dblDose, lngDoseUnit)

                    //F0083673 ST 15Apr10 Check to see if we have some data before processing it
                    if (strResult_XML != "") {
                        var DOM = new ActiveXObject("MSXML2.DOMDocument");
                        DOM.loadXML(strResult_XML);
                        var xmlConverted = DOM.selectSingleNode('*');
                        dblDose = xmlConverted.getAttribute('Value_Converted');
                        conversionFactor = Number(xmlConverted.getAttribute('ConversionFactor'));
                        document.getElementById("txtPrimaryIngredientConcentration").setAttribute("conversionfactor", String(conversionFactor));
                    }
		        }
		        else
		        {
                    dblDose *= conversionFactor;
		        }
            }
            
            if(Number(dblDose) > 0 && lngFinalConcentration > 0)
            {
                dblResult = dblDose/lngFinalConcentration;
//		          //Update the screen
                document.getElementById("txtDiluentFinalVolume").value = RoundToDecPl(dblResult, 2);
                document.getElementById("txtDiluentFinalVolume").setAttribute("iscalculated", "True");
                document.getElementById("txtDiluentFinalVolume").setAttribute("calculated", String(dblResult));
                document.getElementById("txtDiluentFinalVolume").className += ' calculated'; 
                document.getElementById("txtPrimaryIngredientConcentration").className= '';
            } 
            
            if(Number(document.getElementById("txtDiluentFinalVolume").value) > 0)
            {
                //only perform calculation if final volume is greater than 0
                dblResult = RoundToDecPl(Number(document.getElementById("txtDiluentFinalVolume").value) - VolumeOfIngredients(),2);
                document.getElementById("txtDiluentQty").value = dblResult;
                document.getElementById("txtDiluentQty").setAttribute("iscalculated", "True");
                document.getElementById("txtDiluentQty").setAttribute("calculated", String(dblResult));
                document.getElementById("txtDiluentQty").className += ' calculated';
                //
                // 24Mar2010 CD F0081306 No longer automatically changed the nominal and exact options
//                document.getElementById("rbDiluentQtyExact").checked = true;
//                document.getElementById("rbDiluentQtyExact").disabled = true;
//                document.getElementById("rbDiluentQtyNominal").checked = false;
//                document.getElementById("rbDiluentQtyNominal").disabled = true;
            }                        
       
        }
    }    
}

//
// Performs an AJAX call to get the strength for the specified item
//
function GetProductStrength(lngProductID, lngSessionID)
{

	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");   
	var strURL = '../OrderEntry/DiluentWorker.aspx'
				  + '?SessionID=' + lngSessionID
				  + '&Mode=GetStrength';

	objHTTPRequest.open("POST", strURL, false);	//false = syncronous    
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");                            //application/x-www-form-urlencoded
	objHTTPRequest.send(lngProductID);
	
	if(objHTTPRequest.responseText != "")
	{
	    return Number(objHTTPRequest.responseText);
	}
	return 0;
}

function UpdateReconstitutionVolume()
{
    var colIngredients = document.getElementById("tblDiluents").all['tdReconstitutedIngredients'];
    var dblDose = Number(document.getElementById("txtDose").value);
    var dblConcentration = 0;
    var dblResult = 0;

    if(colIngredients != undefined && colIngredients.length == undefined)
    {
        dblConcentration = Number(colIngredients.getAttribute("concentration"));
        // primary ingredient dose held in txtDose.value
        dblDose = Number(document.getElementById("txtDose").value);
            
        if(dblDose > 0 && dblConcentration > 0)
        {
            dblResult = dblDose / dblConcentration;
            colIngredients.setAttribute("reconstitutionvolume", dblResult);
        }
    }
    else
    {
        for(idx = 0; idx < colIngredients.length; idx++)
        {
            dblConcentration = Number(colIngredients[idx].getAttribute("concentration"));
            if(idx == 0)
            {
                // primary ingredient dose held in txtDose.value
                dblDose = Number(document.getElementById("txtDose").value);
            }
            else
            {
                dblDose = Number(colIngredients[idx].getAttribute("dose"));
            }

            if(dblDose > 0 && dblConcentration > 0)
            {
                dblResult = dblDose / dblConcentration;
                colIngredients[idx].setAttribute("reconstitutionvolume", dblResult);
            }
        }
    }
}

function UpdateLiquidVolume()
{
    var lngSessionID = document.body.getAttribute('sid');
    var colIngredients = document.getElementById("tblDiluents").all['tdReconstitutedIngredients'];
    var dblDose = 0;
    
    var idx = 0;
    var lngStrength = 0;
    var lngProductID = 0;
    var lngLiquidVolume = 0;

    if(colIngredients != undefined && colIngredients.length == undefined)
    {
        if(colIngredients.getAttribute("issolid") == "False")
        {
            lngProductID = Number(colIngredients.getAttribute("productid"));
            lngStrength = GetProductStrength(lngProductID, lngSessionID);
            // primary ingredient dose held in txtDose.value
            dblDose = Number(document.getElementById("txtDose").value);
            
            if(dblDose > 0 && lngStrength > 0)
            {
                lngLiquidVolume = dblDose / lngStrength;
                colIngredients.setAttribute("liquidvolume", lngLiquidVolume);
            }
        }   
    }
    else
    {
        for(idx = 0; idx < colIngredients.length; idx++)
        {
            if(colIngredients[idx].getAttribute("issolid") == "False")
            {
                if(idx == 0)
                {
                    dblDose = Number(document.getElementById("txtDose").value);
                }
                else
                {
                    dblDose = Number(colIngredients[idx].getAttribute("Dose"));
                }
                
                lngProductID = Number(colIngredients[idx].getAttribute("productid"));
                lngStrength = GetProductStrength(lngProductID, lngSessionID);
                if(dblDose > 0 && lngStrength > 0)
                {
                    lngLiquidVolume = dblDose / lngStrength;
                    colIngredients[idx].setAttribute("liquidvolume", lngLiquidVolume);
                }
            }   
        }
    }
}

//
// Gathers all of the available data and produces one block of xml
//
function GatherDataAsXML()
{
    var DOMdata;
    var DOMcopy;
    var xmlRoot;
    var xmlRootCopy;
    var strData_XML = '';
    var strDiluent_XML = '';
    var strReconstitution_XML = '';
    var strPrescription_XML = '';
    var xmlRemove;
    var xmlAdd;
    var xmlDiluents;
    var xmlReconstitution;

    // Get the form data and store it
    document.getElementById("txtDiluent_XML").value = ReadDataFromForm();

    strDiluent_XML = document.getElementById("txtDiluent_XML").value;
    strReconstitution_XML = document.getElementById("txtReconstitution_XML").value;
    strPrescription_XML = document.getElementById("txtPrescription_XML").value;

    DOMdata = new ActiveXObject('MSXML2.DOMDocument');
    
    DOMcopy = new ActiveXObject('MSXML2.DOMDocument');
    DOMcopy.loadXML(strPrescription_XML);
    xmlRoot = DOMdata.appendChild(DOMcopy.selectSingleNode("root"));

    // Add the diluent information
    DOMcopy.loadXML(strDiluent_XML);
    xmlRootCopy = DOMcopy.selectSingleNode("root/Diluents");
    if(xmlRootCopy != null)
    {
        xmlDiluents = xmlRoot.selectSingleNode("Diluents");
        
        if ( xmlDiluents != null) //F0023196 LM 13/05/2008 Handle situations when there is no diluent present
        {
           xmlRemove = xmlRoot.removeChild(xmlDiluents);
        }
        
        
        xmlAdd = xmlRoot.appendChild(xmlRootCopy);
    }


    // Add the reconstitution information
    DOMcopy.loadXML(strReconstitution_XML);
    xmlRootCopy = DOMcopy.selectSingleNode("root/Reconstitution");
    if(xmlRootCopy != null)
    {
        xmlReconstitution = xmlRoot.selectSingleNode("root/Diluents/Reconstitution");
        if(xmlReconstitution != null)
        {
            xmlRemove = xmlRoot.removeChild(xmlReconstitution);
            xmlAdd = xmlRoot.appendChild(xmlRootCopy);
        }
        else
        {
            xmlRoot = DOMdata.selectSingleNode("root/Diluents");
            xmlAdd = xmlRoot.appendChild(xmlRootCopy);
        }
    }
    strData_XML = DOMdata.xml;
    DOMdata = null;
    DOMcopy = null;

    return strData_XML;
}


// Utility functions to determine if any of the following have been user entered
// Dose, FinalVolume, FinalConcentration, DiluentQuantity
function IsDoseEntered()
{
    if(document.getElementById("txtDose").getAttribute("iscalculated") == "False")
    {
        if(Number(document.getElementById("txtDose").value) > 0)
        {
            return true;
        }
    }
    return false;
}

function IsFinalVolumeEntered()
{
    if(document.getElementById("txtDiluentFinalVolume").getAttribute("iscalculated") == "False")
    {
        if(Number(document.getElementById("txtDiluentFinalVolume").value) > 0)
        {
            return true;
        }
    }
    return false;
}

function IsFinalConcentrationEntered()
{
    if(document.getElementById("txtPrimaryIngredientConcentration").getAttribute("iscalculated") == "False")
    {
        if(Number(document.getElementById("txtPrimaryIngredientConcentration").value) > 0)
        {
            return true;
        }
    }
    return false;
}

function IsDiluentQuantityEntered()
{
    if(document.getElementById("txtDiluentQty").getAttribute("iscalculated") == "False")
    {
        if(Number(document.getElementById("txtDiluentQty").value) > 0)
        {
            return true;
        }
    }
    return false;
}

//
// Reads all the data from the form and returns a block of xml
//
function ReadDataFromForm() {
    var strData_XML = "";
    var objSelect;
    var strInstruction = "";
    var blnTemplateMode = false;
    var lngNominal = 0;
    var lngExact = 0;
    var blnDose_Calculated = document.getElementById("txtDose").getAttribute("iscalculated");
    
    var blnFinalVolume_Calculated = document.getElementById("txtDiluentFinalVolume").getAttribute("iscalculated");
    var blnFinalConcentration_Calculated = document.getElementById("txtPrimaryIngredientConcentration").getAttribute("iscalculated");
    var blnDiluentQuantity_Calculated = document.getElementById("txtDiluentQty").getAttribute("iscalculated");
    
    var dblFinalConcentration = Number(document.getElementById("txtPrimaryIngredientConcentration").value);

    //Cast this back to the original dosing unit using the stored conversion factor.  This specifies the conversion between
    //the current unit and the dosing unit

    // 06Jun08 ST   Only do this calculation if final concentration is > 0 and
    // Number(document.getElementById("txtPrimaryIngredientConcentration").getAttribute('conversionfactor') ) > 0
    if(dblFinalConcentration > 0 && Number(document.getElementById("txtPrimaryIngredientConcentration").getAttribute('conversionfactor') ) > 0)
    {
        dblFinalConcentration = dblFinalConcentration / (Number(document.getElementById("txtPrimaryIngredientConcentration").getAttribute('conversionfactor') ));
    }        
    
	 var lngFinalConcentration_UnitID = Number(document.getElementById("txtPrimaryIngredientConcentration").getAttribute('unitid_original'));	 
	 
    var lngDiluentInformationID = document.body.getAttribute('diluentinfoid');
    var lngDiluentQty = Number(document.getElementById("txtDiluentQty").value);
    var lngDiluentFinalVolume = Number(document.getElementById("txtDiluentFinalVolume").value);
    
    // To get the volume of ingredients we need to read from the xml
    var lngVolumeOfIngredients = VolumeOfIngredients();
    if(lngVolumeOfIngredients == 0)
    {
        // Sometimes ingredients volume seems to be 0 when it shouldn't so we'll just check
        var strPrescription_XML = document.getElementById("txtPrescription_XML").value;
        DOMdata = new ActiveXObject('MSXML2.DOMDocument');
        DOMdata.loadXML(strPrescription_XML);
        xmlDiluentRoot = DOMdata.selectSingleNode("root/Diluents/Product");
        if(xmlDiluentRoot != null)
        {
            lngVolumeOfIngredients = Number(xmlDiluentRoot.getAttribute("VolumeOfIngredients"));           
        }        
    }

    var lngVolumeOfLiquidIngredients = VolumeOfLiquidIngredients();
    var objDiv = document.getElementById("divDiluentInstruction");
    
    if(IsTemplateMode())
    {
        strInstruction = document.getElementById("txtDiluentInstruction").value;
    }
    else
    {
        if(typeof(objDiv) != 'undefined' && objDiv != null)
        {
            strInstruction = document.getElementById("divDiluentInstruction").innerText;
        }
        else
        {
            strInstruction = "";
        }
    }
    
    if(document.getElementById("rbDiluentQtyNominal").checked == true)
        lngNominal = 1;
        
    if(document.getElementById("rbDiluentQtyExact").checked == true)
        lngExact = 1;
    
    
    objSelect = document.getElementById("selDiluents");
    var lngDiluentProductID = objSelect.options[objSelect.selectedIndex].getAttribute("dbid");
    var strProductName = objSelect.options[objSelect.selectedIndex].innerText;
   
    objSelect = document.getElementById("lstDevices");
    var lngAdministrationDeviceID = objSelect.options[objSelect.selectedIndex].getAttribute("dbid");
    
    strData_XML = "<root><Diluents><Product ";
    strData_XML += "DiluentInformationID='" + lngDiluentInformationID + "' ";
    strData_XML += "DiluentProductID='" + lngDiluentProductID + "' ";
    strData_XML += "ProductName='" + strProductName + "' ";
    strData_XML += "DiluentQty='" + lngDiluentQty + "' ";
    strData_XML += "DiluentFinalVolume='" + lngDiluentFinalVolume + "' ";
    strData_XML += "Nominal='" + lngNominal + "' ";
    strData_XML += "Exact='" + lngExact + "' ";
    strData_XML += "FinalConcentration='" + dblFinalConcentration + "' ";
    strData_XML += "Dose_Calculated='" + blnDose_Calculated + "' ";
    strData_XML += "FinalVolume_Calculated='" + blnFinalVolume_Calculated + "' ";
    strData_XML += "FinalConcentration_Calculated='" + blnFinalConcentration_Calculated + "' ";
    strData_XML += "DiluentQuantity_Calculated='" + blnDiluentQuantity_Calculated + "' ";
    strData_XML += "VolumeOfIngredients='" + lngVolumeOfIngredients + "' ";
    strData_XML += "VolumeOfLiquidIngredients='" + lngVolumeOfLiquidIngredients + "' ";
    strData_XML += "DeviceID='" + lngAdministrationDeviceID + "' ";
    strData_XML += "Instruction='" + strInstruction + "'";
    strData_XML += "/></Diluents></root>";
    return strData_XML;
}

//
// Handler for displaying the calculations form
//
function CalculationsForm()
{
	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");   
    var lngSessionID = document.body.getAttribute('sid');
    var blnTemplateMode = document.body.getAttribute('TemplateMode');
    
    // Get the form data        
    var strData_XML = GatherDataAsXML();    

    // Save it to state
	var strURL = '../OrderEntry/SessionAttributeSave.aspx'
				  + '?SessionID=' + lngSessionID
				  + '&Mode=set'
				  + '&Attribute=' + "OrderEntry/DiluentCalculation";

	objHTTPRequest.open("POST", strURL, false);	//false = syncronous    
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");                            //application/x-www-form-urlencoded
	objHTTPRequest.send(strData_XML);
	objHTTPRequest.responseText;

    // Show the calculations dialog
    var strURL = '../OrderEntry/DiluentCalculations.aspx'
                + '?SessionID=' + lngSessionID
                + '&TemplateMode=' + blnTemplateMode;

    strReturn = window.showModalDialog(strURL, '', 'dialogHeight:900px;dialogWidth:900px;resizable:yes;status:no;help:no;');
    if (strReturn == 'logoutFromActivityTimeout') {
        strReturn = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

}

//
// Handler for displaying the reconstitution form
//
function ReconstitutionForm(lngProductID)
{
    var lngSessionID = document.body.getAttribute('sid');
    var lngRequestID = document.body.getAttribute('requestid');
    var blnTemplateMode = false;
    
    blnTemplateMode = IsTemplateMode();
    
    var blnDisplayMode = document.body.getAttribute('DisplayMode');
    var strData_XML = ReadDataFromForm();

    document.getElementById("txtDiluent_XML").value = strData_XML;
    document.forms['frmDiluents'].action="reconstitution.aspx?SessionID=" + lngSessionID + "&RequestID=" + lngRequestID +"&ProductID=" + lngProductID + "&TemplateMode=" + blnTemplateMode + "&DisplayMode=" + blnDisplayMode;
    document.forms['frmDiluents'].submit();
}

//
// Checks if the minimum requirements have been input and displays the appropriate message on the screen
//
function CheckIfComplete()
{
    var colIngredients = tblDiluents.all['tdReconstitutedIngredients'];
    var objSelect;
    var idx = 0;
    var blnIncomplete = false;
    var blnNoVolumeSpecified = false;
    var blnNoVolumeRequired = false;
    var blnMissingDiluent = false;
   
   
    objSelect = document.getElementById("lstDevices")
    if(objSelect != undefined && objSelect.selectedIndex > -1 && Number(objSelect.options[objSelect.selectedIndex].getAttribute('volumerequired') > -1))
    {
        blnNoVolumeRequired = !Number(objSelect.options[objSelect.selectedIndex].getAttribute('volumerequired'));
    }

    // check to see if any of the fields in the diluent section are missing

    objSelect = document.getElementById("selDiluents");
    if(objSelect != undefined && objSelect.selectedIndex > -1 && objSelect.options[objSelect.selectedIndex].innerText == "")
    {
        blnMissingDiluent = true;
    }
    else
    {
        if(document.getElementById("rbDiluentQtyExact").checked == false && document.getElementById("rbDiluentQtyNominal").checked == false)
        {
            blnMissingDiluent = true;
        }
            
        if(Number(document.getElementById("txtDiluentQty").value) == 0 || Number(document.getElementById("txtDiluentFinalVolume").value) == 0 || Number(document.getElementById("txtPrimaryIngredientConcentration").value) == 0)
        {
            blnMissingDiluent = true;
        }
    }
    
    if(blnMissingDiluent && !blnNoVolumeRequired)
    {
        // 24Mar2010 CD F0081306 No volume warning removed
        // document.all['trNoVolumeSpecified'].style.display = 'inline';
        document.all['trComplete'].style.display = 'none';
        document.all['trIncomplete'].style.display = 'none';
        return;
    }
    
    
    // check to see if reconstituted products are set to not specified
    if(colIngredients != undefined && colIngredients.length == undefined)
    {
        // Is the case when there is actually only one of the elements in the html
        if(typeof(colIngredients) != 'undefined')
        {
            if(colIngredients.innerText == "Not Specified")
            {
                blnIncomplete = true;
            }
        }        
    }
    else
    {
        for(idx = 0; idx < colIngredients.length; idx++)
        {
            if(typeof(colIngredients[idx]) != 'undefined')
            {
                if(colIngredients[idx].innerText == "Not Specified")
                {
                    blnIncomplete = true;
                }
            }
        }
    }

    if(blnIncomplete && !blnNoVolumeRequired)
    {
        document.all['trIncomplete'].style.display = 'inline';
        // 24Mar2010 CD F0081306 No volume warning removed
        //document.all['trNoVolumeSpecified'].style.display = 'none';
        document.all['trComplete'].style.display = 'none';
        return;
    }
    
    document.all['trComplete'].style.display = 'inline';
    // 24Mar2010 CD F0081306 No volume warning removed
    //document.all['trNoVolumeSpecified'].style.display = 'none';
    document.all['trIncomplete'].style.display = 'none';
    return;
}

function SetFlags(objInput){
	// reset flags on control
	objInput.setAttribute("iscalculated", "False");
	objInput.setAttribute("calculated", "");
	objInput.className = objInput.className.split(' calculated').join('');				//remove the "calculated" css class
}

//
// 24Mar2010 CD F0081306
// Resets all values to 0
//
function ResetValues() {
    document.getElementById("txtDiluentQty").value = "0";
    document.getElementById("txtDiluentQty").removeAttribute("iscalculated");
    document.getElementById("txtDiluentQty").removeAttribute("calculated");
    var className = document.getElementById("txtDiluentQty").className;
    while (className.indexOf("calculated") != -1) {
        className = className.replace("calculated", "");
    }
    document.getElementById("txtDiluentQty").className = className;

    document.getElementById("txtDiluentFinalVolume").value = "0"
    document.getElementById("txtDiluentFinalVolume").removeAttribute("iscalculated");
    document.getElementById("txtDiluentFinalVolume").removeAttribute("calculated");
    className = document.getElementById("txtDiluentFinalVolume").className;
    while (className.indexOf("calculated") != -1) {
        className = className.replace("calculated", "");
    }
    document.getElementById("txtDiluentFinalVolume").className = className;

    document.getElementById("txtPrimaryIngredientConcentration").value = "0";
    document.getElementById("txtPrimaryIngredientConcentration").removeAttribute("iscalculated");
    document.getElementById("txtPrimaryIngredientConcentration").removeAttribute("calculated");
    className = document.getElementById("txtPrimaryIngredientConcentration").className;
    while (className.indexOf("calculated") != -1) {
        className = className.replace("calculated", "");
    }
    document.getElementById("txtPrimaryIngredientConcentration").className = className;

    // Also blank the other ingredients concentrations
    var colIngredientsConcentrations = document.getElementById("tblDiluents").all['tdIngredientConcentration'];
    if (colIngredientsConcentrations != null) {
        if (colIngredientsConcentrations.length != undefined) {
            for (idx = 0; idx < colIngredientsConcentrations.length; idx++) {
                colIngredientsConcentrations[idx].innerText = "0";
            }
        }
        else {
            colIngredientsConcentrations.innerText = "0";
        }
    }
}




function GetTotalDose() {
    // Returns a dose quantity to remove from the final volume when prescribing in mLs
    // If in template mode then we return 0 if any of the ingredients are part of a calculated dose.
    var dblDose = 0;
    
    if (IsTemplateMode()) {
        if (IsCalculatedDose() || IsCalculatedIngredients()) {
            // If a calculated dose of either primary of secondary ingredients in template mode then don't work out anything to return
            return dblDose;
        }
    }
    
        if (document.getElementById("tdPrimaryIngredientPrescribed").getAttribute("unit").toLowerCase() == "ml") {
            dblDose = Number(document.getElementById("tdPrimaryIngredientPrescribed").getAttribute("Dose"));
        }

        
        if (document.all["tdIngredientPrescribed"] != undefined) {
            if (document.all["tdIngredientPrescribed"].length > 1) 
            {
                for (idx = 0; idx < document.all["tdIngredientPrescribed"].length; idx++) 
                {
                    if (document.all["tdIngredientPrescribed"][idx].getAttribute("unit").toLowerCase() == "ml")
                    {
                        dblDose = dblDose + Number(document.getElementById("tdIngredientPrescribed").getAttribute("Dose"));
                    }
                }
            }
            else 
            {
                if (document.all["tdIngredientPrescribed"].getAttribute("unit").toLowerCase() == "ml")
                {
                    dblDose = dblDose + Number(document.getElementById("tdIngredientPrescribed").getAttribute("Dose"));
                }
            }
        }


        return dblDose;

}

// Checks to see if any of the ingredients are calculated doses
function IsCalculatedIngredients() 
{
    var blnResult = false;

    if (document.all["tdIngredientPrescribed"] != undefined) {
        if (document.all["tdIngredientPrescribed"].length > 1) {
            for (idx = 0; idx < document.all["tdIngredientPrescribed"].length; idx++) {
                if (document.all["tdIngredientPrescribed"][idx].getAttribute("Routine") != "") {
                    blnResult = true;
                }
            }
        }
        else {
            if (document.all["tdIngredientPrescribed"].getAttribute("Routine") != "") {
                blnResult = true;
            }
        }
    }

    return blnResult;
}


// Checks to see if any of our ingredients are being prescribed in mls
function AnyIngredientsInMls() {
    var colIngredients = document.all["tdIngredientPrescribed"];
    var blnResult = false;
    var idx = 0;

    if (document.getElementById("tdPrimaryIngredientPrescribed").getAttribute("unit").toLowerCase() == "ml")
        blnResult = true;

    if (colIngredients != null && colIngredients != undefined && colIngredients.length != undefined) {
        for (idx = 0; idx < colIngredients.length; idx++) {
            if (colIngredients[idx].getAttribute("unit").toLowerCase() == "ml")
                blnResult = true;
        }
    }
    else {
        if (document.getElementById("tdIngredientPrescribed") != undefined) {
            if (document.getElementById("tdIngredientPrescribed").getAttribute("unit").toLowerCase() == "ml") {
                blnResult = true;
            }
        }
    }
    
    return blnResult;
}


// Determines if we are viewing
function IsDisplayMode() {
    var blnDisplayMode = (document.body.getAttribute('DisplayMode').toLowerCase() == "true")

    return blnDisplayMode;
}
