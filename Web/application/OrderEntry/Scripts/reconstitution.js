//
// Checks if the required values have been entered and displays the appropriate warning message
//
function CheckIfComplete()
{
    var blnComplete = true;
    
    // 25May08 CD - Changed to check that the No radio button is not checked rather than that the Yes is in order to handle the fact that
    // neither is selected initially
    if(document.getElementById("rbReconstitutionNo").checked == false)
    {
        // check to see if any of the following are blank, if so we cannot be complete.
        if(document.getElementById("selReconstituteIn").options[document.getElementById("selReconstituteIn").selectedIndex].innerText == "")
            blnComplete = false;
            
        if(document.getElementById("txtReconstitutionVialSize").value == "" || document.getElementById("txtReconstitutionVialSize").value == "0")
            blnComplete = false;
            
        if(document.getElementById("txtReconstitutionVolume").value == "" || document.getElementById("txtReconstitutionVolume").value == "0")
            blnComplete = false;
            
        if(document.getElementById("txtReconstitutionConcentration").value == "" || document.getElementById("txtReconstitutionConcentration").value == "0")
            blnComplete = false;
        
        if(blnComplete)
        {
            document.all['trIncomplete'].style.display = 'none';
            document.all['trComplete'].style.display = 'inline';
        }
        else
        {
            document.all['trIncomplete'].style.display = 'inline';
            document.all['trComplete'].style.display = 'none';
        }
    }
    else
    {
        document.all['trComplete'].style.display = 'inline';    
        document.all['trIncomplete'].style.display = 'none';
    }
}

//
// Handler for the YES radio button
//
function rbReconstitutionYes_onclick()
{
    var blnComplete = true;
        
    document.getElementById("rbReconstitutionNo").checked = false;    
        
    document.getElementById("txtReconstitutionVialSize").disabled = false;
    document.getElementById("selReconstituteIn").disabled = false;
    if (IsSolid()){document.getElementById("txtReconstitutionDisplacementVolume").disabled = false};
    document.getElementById("txtReconstitutionVolume").disabled = false;
    document.getElementById("txtReconstitutionConcentration").disabled = false;
    
    CheckIfComplete();
}

//
// Handler for the NO radio button
// 
function rbReconstitutionNo_onclick()
{
    document.getElementById("rbReconstitutionYes").checked = false;

    document.getElementById("txtReconstitutionVialSize").disabled = true;
    document.getElementById("selReconstituteIn").disabled = true;
    document.getElementById("txtReconstitutionDisplacementVolume").disabled = true;
    document.getElementById("txtReconstitutionVolume").disabled = true;
    document.getElementById("txtReconstitutionConcentration").disabled = true;

    document.all['trComplete'].style.display = 'inline';    
    document.all['trIncomplete'].style.display = 'none';
}

//
// Calculates the number of vials required
//
function CalculateVialsRequired()
{
    var lngDose = 0;
    var dblVialSize = 0;
    var lngVialsRequired = 0;
        
    lngDose = Number(document.getElementById("txtIngredientDose").getAttribute("dose"));
    dblVialSize = Number(document.getElementById("txtReconstitutionVialSize").value);
    
    if(lngDose > 0 && dblVialSize > 0)
    {
    
        lngVialsRequired = Math.ceil(lngDose / dblVialSize);
        document.getElementById("tdVialsRequired").innerText = lngVialsRequired;
    }
    else
    {
        document.getElementById("tdVialsRequired").innerText = "";
    }
    
    CheckIfComplete();
}

//
// Performs an AJAX call to get the strength for the specified item
//
function GetProductStrength(lngProductID, lngSessionID)
{
    var lngSessionID = document.body.getAttribute('sid');
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

//
// Performs an AJAX call to get derive the dose unit concentration
//
function DeriveConcentrationUnits(lngSessionID, Concentration, UnitID)
{
    var lngSessionID = document.body.getAttribute('sid');
    var strData_XML = "";
	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");   
	
	var strURL = '../OrderEntry/DiluentWorker.aspx'
				  + '?SessionID=' + lngSessionID
				  + '&Mode=ConvertToSmallestUnit';

    strData_XML = "<Value Value='" + Concentration + "'";
    strData_XML = strData_XML + " UnitID='" + UnitID + "'";
    strData_XML = strData_XML + "/>";
    
	objHTTPRequest.open("POST", strURL, false);	//false = syncronous    
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");                            //application/x-www-form-urlencoded
	objHTTPRequest.send(strData_XML);
	return objHTTPRequest.responseText;
}



//
// OnBlur handler for the displacement volume edit
//
function txtReconstitutionDisplacementVolume_onblur()
{
    if(Number(document.getElementById("txtReconstitutionVolume").value) > 0)
    {
        CalculateConcentration();
    }
}

function IsSolid()
{
    var blnIsSolid = false;
    
    if(document.getElementById("txtIngredientDose").getAttribute("issolid") == "True")
    {
        blnIsSolid = true;
    }
    
    return blnIsSolid;    
}

//
// Calculate the concentration value
//

function CalculateConcentration() {
    var dblVialSize = 0;
    var dblReconstitutionVolume = 0;
    var lngDisplacementVolume = 0;
    var dblReconstitutionConcentration = 0;
    var dblReconstitutionConcentration_display = 0;
    var dblConversion = 1;
    var dblStrength = 0;												//note - will be float becuase strength may be a decimal
    var lngProductID = 0;
    var intVialsRequired = 0;
    var lngSessionID = document.body.getAttribute('sid');
    var strResult = '';
    var pos = 0;
    var lngResult1 = 0;
    var lngResult2 = 0;
    var DOM;
    var xmlObj;
    var xmlNode;
    var strReturn_XML = "";

    lngProductID = Number(tdIngredient.getAttribute("dbid"));
    dblStrength = GetProductStrength(lngProductID, lngSessionID);
    dblVialSize = Number(document.getElementById("txtReconstitutionVialSize").value);
    dblReconstitutionVolume = Number(document.getElementById("txtReconstitutionVolume").value);
    lngDisplacementVolume = Number(document.getElementById("txtReconstitutionDisplacementVolume").value);   
	intVialsRequired = Number(document.getElementById("tdVialsRequired").innerText);

	//For solids, the sum is:
	//			 VialSize / (ReconstitutionVolume + DisplacementVolume)

    if(IsSolid())
    {
        lngResult1 = lngDisplacementVolume + dblReconstitutionVolume;
        if(dblVialSize > 0)
        {
            if(lngResult1 > 0)
            {
                lngResult2 = (dblVialSize / lngResult1);
            }
            else
            {
                // unable to calculate so ensure the result is zero
                lngResult2 = 0;
            }
            dblReconstitutionConcentration = lngResult2;
            
        }
    }
    else
    {
//		For Liquids, the sum is
//			(VialSize) / (ReconstitutionVolume + (VialSize / Strength))

        if(dblVialSize > 0 && dblReconstitutionVolume > 0 && dblStrength > 0)
        {     
            //dblReconstitutionConcentration = Math.round((dblStrength * dblVialSize) / (dblReconstitutionVolume + dblVialSize), 2);
            dblReconstitutionConcentration = dblVialSize / (dblReconstitutionVolume + (dblVialSize / dblStrength));
            dblReconstitutionConcentration =  dblReconstitutionConcentration, 2;

        }
    }

	 dblReconstitutionConcentration_display  = dblReconstitutionConcentration;    
	 if (Number(dblReconstitutionConcentration) < 1 && Number(dblReconstitutionConcentration) > 0)
    {    
        // if we are a decimal, convert to a unit in which we can be expressed as an integer
        strReturn_XML = DeriveConcentrationUnits(document.body.getAttribute('sid'), dblReconstitutionConcentration,document.getElementById("txtReconstitutionConcentration").getAttribute("unitid_original") );
			
        if(strReturn_XML != "")
        {
            //We have some data returned back
            DOM = new ActiveXObject('MSXML2.DOMDocument');
            DOM.loadXML(strReturn_XML);
            xmlNode = DOM.selectSingleNode("*");
            if(xmlNode != null)
            {
  
              dblReconstitutionConcentration_display = Number(xmlNode.getAttribute('Value_Converted'));
              dblConversion = Number(xmlNode.getAttribute('ConversionFactor'));
              document.getElementById("txtReconstitutionConcentration").setAttribute("unit", xmlNode.getAttribute("Abbreviation"));
              document.getElementById("txtReconstitutionConcentration").setAttribute("unitid", xmlNode.getAttribute("UnitID"));
              document.all['tdConcentrationUnit'].innerText = " " + xmlNode.getAttribute("Abbreviation") + "/mL";
               
            }
        }
    }
    document.getElementById("txtReconstitutionConcentration").value = RoundToDecPl(dblReconstitutionConcentration_display, 2);
    document.getElementById("txtReconstitutionConcentration").setAttribute("ConversionFactor", dblConversion);
    document.getElementById("txtReconstitutionConcentration").setAttribute("iscalculated", "True");
    document.getElementById("txtReconstitutionConcentration").setAttribute("calculated", String(dblReconstitutionConcentration));
    ShowDrawUpText();
    CheckIfComplete();
    
}

//
// Displays the DRAW UP text on the dialog
//
function ShowDrawUpText()
{
    var lngDose = 0;
    var dblReconstitutionConcentration = 0;
    var dblConversion = 1;
    var lngDrawUp = 0;
    var strResult = '';
    var pos = 0;

    lngDose = Number(document.getElementById("txtIngredientDose").getAttribute("dose"))
    
    dblConversion = Number(document.getElementById("txtReconstitutionConcentration").getAttribute('ConversionFactor'));
    if (dblConversion==0) dblConversion = 1;
    
    dblReconstitutionConcentration = Number(document.getElementById("txtReconstitutionConcentration").value) / dblConversion;
    
    if(lngDose > 0 && dblReconstitutionConcentration > 0)
    {
        lngDrawUp = FormatDecimal(RoundToDecPl(lngDose / dblReconstitutionConcentration, 2));
        document.getElementById("tdDrawUpText").innerText = "Draw up " + lngDrawUp + "mL of the reconstituted fluid and add to main Diluent";
    }
    else {
        document.getElementById("tdDrawUpText").innerHTML = "<br>";
        //document.getElementById("tdDrawUpText").innerText = "";
    }
}

//
// Handler for the OK button
//
function btnOK_onclick()
{
    var lngSessionID = document.body.getAttribute('sid');
    var blnTemplateMode = document.body.getAttribute('TemplateMode');
    var blnDisplayMode = document.body.getAttribute('DisplayMode');
    var lngRequestID = document.body.getAttribute('requestid');
    var strErrorMessage = "";
    
    if(blnTemplateMode == "False")
    {
        strErrorMessage = ValidateMandatoryFields();
    }
    
    if(strErrorMessage == "")
    {
        var strReconstitution_XML = ReadDataFromForm();
        document.getElementById("txtReconstitution_XML").value = strReconstitution_XML;
        //07Apr09   Rams    Set Recalculate to true when ok is clicked on Reconstitution.
        //document.forms['frmReconstitution'].action="diluents.aspx?SessionID=" + lngSessionID + "&RequestID=" + lngRequestID + "&TemplateMode=" + blnTemplateMode + "&DisplayMode=" + blnDisplayMode + "&ReCalculate=true";
        //12feb10   Rams    F0077357 - The nominal check box within the diluent form does not work.
        //23Mar10   CD      F0081306 - Added the recacluate flag back on the querystring so it can be used to blank out the fields on the diluent screen
        document.forms['frmReconstitution'].action = "diluents.aspx?SessionID=" + lngSessionID + "&RequestID=" + lngRequestID + "&TemplateMode=" + blnTemplateMode + "&DisplayMode=" + blnDisplayMode + "&ReCalculate=true";
        document.forms['frmReconstitution'].submit();
    }
    else
    {
        alert(strErrorMessage);
    }
}

//
// Handler for the Cancel button
// 
function btnCancel_onclick()
{
    var lngSessionID = document.body.getAttribute('sid');
    var blnTemplateMode = document.body.getAttribute('TemplateMode');
    var blnDisplayMode = document.body.getAttribute('DisplayMode');
    var lngRequestID = document.body.getAttribute('requestid');

    document.forms['frmReconstitution'].action="diluents.aspx?SessionID=" + lngSessionID + "&TemplateMode=" + blnTemplateMode + "&DisplayMode=" + blnDisplayMode + "&RequestID=" + lngRequestID + "&Mode=Reload";
    document.forms['frmReconstitution'].submit();
}

//
// Validates the mandatory fields on the form
//
function ValidateMandatoryFields()
{
    var strErrorTitle = "The following errors need to rectified before these changes can be saved:\r\n\r\n";
    var strErrorMessage = "";
    var objSelect;
    
    if(document.getElementById("rbReconstitutionYes").checked == true)
    {
        if(document.getElementById("txtReconstitutionVialSize").value == "" || document.getElementById("txtReconstitutionVialSize").value == 0)
        {
            strErrorMessage += "Vial/Amp Size is a Mandatory input\r\n";
        }
        
        if(document.getElementById("txtReconstitutionVolume").value == "" || document.getElementById("txtReconstitutionVolume").value == 0)
        {
            strErrorMessage += "Add is a Mandatory input\r\n";
        }

        if(document.getElementById("txtReconstitutionConcentration").value == "" || document.getElementById("txtReconstitutionConcentration").value == 0)
        {
            strErrorMessage += "Concentration is a Mandatory input\r\n";
        }
        
        objSelect = document.getElementById("selReconstituteIn");
        if(objSelect.options[objSelect.selectedIndex].innerText == "")
        {
            strErrorMessage += "Reconstitute In is a Mandatory input";
        }
        
        if(strErrorMessage != "")
        {
            strErrorMessage = strErrorTitle + strErrorMessage;
        }
    }
    return strErrorMessage;
}

//
// OnBlur handler for the Reconstitution Concentration edit
//

function txtReconstitutionConcentration_onblur()
{
    var lngCalculated = Number(document.getElementById("txtReconstitutionConcentration").getAttribute("calculated"));
    var lngEntry = Number(document.getElementById("txtReconstitutionConcentration").value);
    
    if(document.getElementById("txtReconstitutionConcentration").getAttribute("calculated") != "" && lngEntry != lngCalculated)
    {
        document.getElementById("txtReconstitutionConcentration").setAttribute("calculated", "");
        document.getElementById("txtReconstitutionConcentration").setAttribute("iscalculated", "False");
    }
}

//
// Onload handler for the dialog
//
function window_onload()
{


    parent.frames['fraReconstitutionDiluent'].parent.document.title = 'Reconstitution';
    
    // Check the status of the radio buttons if we are loading data back in
    // and enable/disable as appropriate
    if(document.getElementById("rbReconstitutionYes").checked == true)
    {
        rbReconstitutionYes_onclick();
    }
    if(document.getElementById("rbReconstitutionNo").checked == true)
    {
        rbReconstitutionNo_onclick();
    }


    CalculateVialsRequired();
    //20Jan2010 F0074572 JMei allow user change concentration value without recalculating
    //can't recalculate here, because value of concentration may from user input
    //CalculateConcentration();
    //ShowDrawUpText();
    CheckIfComplete();

}

function ReadDataFromForm() {
    var DOM;
    var xmlObj;
    var xmlNode;
    var xmlRoot;
    var blnReconstitution = false;
    var objSelect = document.getElementById("selReconstituteIn");
    var dblConversionFactor = 1;
    
    if(document.getElementById("rbReconstitutionYes").checked == true)
    {
        blnReconstitution = true;
    }
    
    //Get any existing reconstitution data here
    var strReconstitution_XML = document.getElementById("txtReconstitution_XML").value;
    var lngProductID = Number(tblReconstitution.all['tdIngredient'].getAttribute("dbid"));
    var lngDoseRequired = Number(document.getElementById("txtIngredientDose").getAttribute("dose"));
    var dblVialSize = Number(document.getElementById("txtReconstitutionVialSize").value);
    var lngDisplacementVolume = Number(document.getElementById("txtReconstitutionDisplacementVolume").value);    
    
    //Convert the concentration back into dosing units for consistency (i.e. the unit the product is expressed in)
    dblConversionFactor = Number(document.getElementById("txtReconstitutionConcentration").getAttribute("ConversionFactor"));
    if (dblConversionFactor == 0) dblConversionFactor = 1;
    var lngConcentration = Number(document.getElementById("txtReconstitutionConcentration").value) / dblConversionFactor;

    var lngVolume = Number(document.getElementById("txtReconstitutionVolume").value);
    var lngReconstitutionProductID = objSelect.options[objSelect.selectedIndex].getAttribute("dbid");
    var strReconstitutionProductName = objSelect.options[objSelect.selectedIndex].getAttribute("Description");
    var strInstructionLabel = document.getElementById("tdDrawUpText").innerText;
    var blnConcentration_Calculated = document.getElementById("txtReconstitutionConcentration").getAttribute("iscalculated");

    var dblReconstitutionConcentration = 0;

    var strConcentration_Unit = document.getElementById("txtReconstitutionConcentration").getAttribute("unit_original")
    var intConcentration_UnitID = Number(document.getElementById("txtReconstitutionConcentration").getAttribute("unitid_original"));
    var dblConcentration_Multiple = document.getElementById("txtReconstitutionConcentration").getAttribute("multiple");
    
    if(strReconstitutionProductName == null)
    {
        strReconstitutionProductName = "";
    }
    
    if(strReconstitution_XML != "")
    {
        // something already there so look to merge the data
        DOM = new ActiveXObject('MSXML2.DOMDocument');
        DOM.loadXML(strReconstitution_XML);
        xmlNode = DOM.selectSingleNode("root/Reconstitution/Product[@ProductID='" + lngProductID + "']");
        if(xmlNode != null)
        {
            // product exists, update the data
            xmlNode.setAttribute('ProductID', lngProductID);
            if(blnReconstitution == true)
            {
                xmlNode.setAttribute('ReconstitutionRequired', '1');
            }
            else
            {
                xmlNode.setAttribute('ReconstitutionRequired', '0');
            }
            dblConversionFactor = Number(xmlNode.getAttribute('ConversionFactor'));

            xmlNode.setAttribute('DoseRequired', lngDoseRequired);
		    xmlNode.setAttribute('VialSize', dblVialSize);
		    xmlNode.setAttribute('ReconstituteProductID', lngReconstitutionProductID);
            xmlNode.setAttribute('ReconstituteProductName', strReconstitutionProductName);
		    xmlNode.setAttribute('DisplacementVolume', lngDisplacementVolume);
            xmlNode.setAttribute('Concentration', lngConcentration);
		    xmlNode.setAttribute('Volume', lngVolume);
		    xmlNode.setAttribute('Concentration_Calculated', blnConcentration_Calculated);
		 		    
		    xmlNode.setAttribute('Instruction', strInstructionLabel);
		    xmlNode.setAttribute('Concentration_Unit', strConcentration_Unit);
		    xmlNode.setAttribute('Concentration_UnitID', intConcentration_UnitID);
//		    xmlNode.setAttribute('Concentration_Multiple', dblConcentration_Multiple);
        }
        else
        {
            // new product, add it in
            xmlRoot = DOM.selectSingleNode("root/Reconstitution");
            xmlNode = xmlRoot.appendChild(DOM.createElement("Product"));
            xmlNode.setAttribute('ProductID', lngProductID);
            if(blnReconstitution == true)
            {
                xmlNode.setAttribute('ReconstitutionRequired', '1');
            }
            else
            {
                xmlNode.setAttribute('ReconstitutionRequired', '0');
            }
            xmlNode.setAttribute('DoseRequired', lngDoseRequired);
		    xmlNode.setAttribute('VialSize', dblVialSize);
		    xmlNode.setAttribute('ReconstituteProductID', lngReconstitutionProductID);
            xmlNode.setAttribute('ReconstituteProductName', strReconstitutionProductName);
		    xmlNode.setAttribute('DisplacementVolume', lngDisplacementVolume);
            xmlNode.setAttribute('Concentration', lngConcentration);
		    xmlNode.setAttribute('Volume', lngVolume);
		    xmlNode.setAttribute('Concentration_Calculated', blnConcentration_Calculated);
		    xmlNode.setAttribute('Instruction', strInstructionLabel);
		    xmlNode.setAttribute('Concentration_Unit', strConcentration_Unit);
		    xmlNode.setAttribute('Concentration_UnitID', intConcentration_UnitID);
//		    xmlNode.setAttribute('Concentration_Multiple', dblConcentration_Multiple);
        }
        strReconstitution_XML = DOM.xml;
    }
    else
    {
        // nothing there so simply add it in
        strReconstitution_XML = "<root><Reconstitution><Product ";
        strReconstitution_XML += "ProductID='" + lngProductID + "' ";
        if(blnReconstitution == true)
        {
            strReconstitution_XML += "ReconstitutionRequired='1' ";
        }
        else
        {
            strReconstitution_XML += "ReconstitutionRequired='0' ";
        }
        strReconstitution_XML += "DoseRequired='" + lngDoseRequired + "' ";
        strReconstitution_XML += "VialSize='" + dblVialSize + "' ";
        strReconstitution_XML += "ReconstituteProductID='" + lngReconstitutionProductID + "' ";
        strReconstitution_XML += "ReconstituteProductName='" + strReconstitutionProductName + "' ";
        strReconstitution_XML += "DisplacementVolume='" + lngDisplacementVolume + "' ";
        strReconstitution_XML += "Concentration='" + lngConcentration + "' ";
        strReconstitution_XML += "Volume='" + lngVolume + "' ";
        strReconstitution_XML += "Concentration_Calculated='" + blnConcentration_Calculated + "' ";
        strReconstitution_XML += "Instruction='" + strInstructionLabel + "' "
        strReconstitution_XML += "Concentration_Unit='" + strConcentration_Unit + "' "
        strReconstitution_XML += "Concentration_UnitID='" + intConcentration_UnitID + "' /></Reconstitution></root>";
        //strReconstitution_XML += "Concentration_Multiple='" + dblConcentration_Multiple + "' /></Reconstitution></root>";
    }        
    return strReconstitution_XML;
}

