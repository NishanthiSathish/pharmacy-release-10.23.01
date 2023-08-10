
function lstProducts_onchange(lngProductID)
{
	var objSel;
	var blnIsMDA = false;
	objSel = document.getElementById("lstProducts");
	if (objSel)
		blnIsMDA = Number(objSel.options[objSel.selectedIndex].getAttribute("ismda"));

	//
	//09Sep09   Rams    Commented as the Units will be loaded by GetDoseUnits function
	//unitsData.src = "PrescriptionLoader.aspx?SessionID=" + formBody.getAttribute("sid") + "&ProductID=" + lngProductID + "&Mode=doseunits";

	GetProductForm(lngProductID);
	GetProductStrengths(lngProductID);
	GetProductPack(lngProductID);
	GetProductBrands(lngProductID);
	GetProductRoutes(lngProductID);
	GetDoseUnits(lngProductID);

	UpdateProfileLength(blnIsMDA);
	//
	txtDoseQty.value = "";
	FillWeeklyBoxes();
}

function lstProductForm_onchange(lngProductID)
{
	var objSel = document.getElementById("lstProductForm");

	// If we haven't selected a product form then set the product pack to empty
	if (objSel.options[objSel.selectedIndex].innerText == "")
	{
		document.getElementById("lstProductPack").selectedIndex = 0;
	}
	GetProductStrengths(lngProductID);
	GetDoseUnits(lngProductID);
	GetProductRoutes(lngProductID);
}

function lstProductStrength_onchange(lngProductID)
{
	var objSel = document.getElementById("lstProductStrength");

	// If we haven't selected a product strength and it is NOT set to not applicable (-) then set the product pack to empty
	if (objSel.options[objSel.selectedIndex].innerText == "" && objSel.options[objSel.selectedIndex].innerText != "-")
	{
		document.getElementById("lstProductPack").selectedIndex = 0;
	}
	else
	{
		GetDoseUnits(lngProductID);
		GetProductRoutes(lngProductID);
		GetProductPack(lngProductID);
	}
}

function lstProductPack_onchange(lngProductID)
{
	//F0095579 ST 08Oct10 Only get the dose units if the product package is not unknown.
	//if (document.getElementById("lstProductPack").options[document.getElementById("lstProductPack").selectedIndex].getAttribute("Pack") != "Unknown")
	//24Nov2010 Rams    F0102300 - Daily Dose of 'Tablet' changes to 'Unknown' if a pack quantity has been selected 
	GetDoseUnits(lngProductID);

	GetProductRoutes(lngProductID);
}

function lstProductBrand_onchange(lngProductID)
{
	GetProductRoutes(lngProductID);
}


function GetProductRoutes(lngProductID)
{
	var blnDisplay = document.body.getAttribute("displaymode");
	var idx;
	var objSel;
	var selOpt;
	var xmlDOM;
	var xmlNodes;
	var data_xml = "";
	var ProductForm = "";
	var ProductBrand = "";
	var ProductPack = "";

	if (document.getElementById("lstProductForm").selectedIndex >= 0)
	{
		ProductForm = document.getElementById("lstProductForm").options[document.getElementById("lstProductForm").selectedIndex].innerText;
	}

	if (document.getElementById("lstProductBrand").selectedIndex >= 0)
	{
		ProductBrand = document.getElementById("lstProductBrand").options[document.getElementById("lstProductBrand").selectedIndex].innerText;
	}

	//08Sep09   Rams    F0062913 Route DropDown is not getting populated without Strength

	if (document.getElementById("lstProductPack").selectedIndex >= 0)
	{
		// F0077337 ST 09Feb10 Changed so that we get the pack name to pass through to further database calls
		ProductPack = document.getElementById("lstProductPack").options[document.getElementById("lstProductPack").selectedIndex].getAttribute("Pack");
		// F0077907 ST 17Feb10 Check for a null value and replace with an empty string
		if (ProductPack == null)
		{
			ProductPack = "";
		}
		//ProductPack = document.getElementById("lstProductPack").options[document.getElementById("lstProductPack").selectedIndex].innerText;
	}


	objSel = document.getElementById("lstProductRoute");

	if (blnDisplay == "False")
	{
		objSel.disabled = true;
	}

	spnWaitRoute.style.left = objSel.offsetWidth + 100;
	spnWaitRoute.style.visibility = "visible";

	data_xml = httpRequest_ProductRoutes(lngProductID, ProductForm, ProductBrand, ProductPack);
	xmlDOM = new ActiveXObject('MSXML2.DOMDocument');
	xmlDOM.loadXML(data_xml);
	xmlNodes = xmlDOM.selectNodes("//ProductRoute");

	objSel.innerHTML = "";

	// Now add the rest of the items
	for (idx = 0; idx < xmlNodes.length; idx++)
	{
		selOpt = document.createElement("option");
		selOpt.value = xmlNodes[idx].getAttribute("Description");
		selOpt.innerText = xmlNodes[idx].getAttribute("Description");
		selOpt.setAttribute("dbid", xmlNodes[idx].getAttribute("ProductRouteID"));
		objSel.appendChild(selOpt);
	}

	// Add an other route selection in last
	selOpt = document.createElement("option");
	selOpt.value = "";
	selOpt.innerText = "--------------------";
	selOpt.setAttribute("dbid", -1);
	objSel.appendChild(selOpt);
	selOpt = document.createElement("option");
	selOpt.value = "";
	selOpt.innerText = "Other";
	selOpt.setAttribute("dbid", -1);
	objSel.appendChild(selOpt);

	if (blnDisplay == "False")
	{
		objSel.disabled = false;
	}

	spnWaitRoute.style.visibility = "hidden";
	return true;
}

function GetProductForm(lngProductID)
{
	var blnDisplay = document.body.getAttribute("displaymode");
	var idx;
	var objSel;
	var selOpt;

	var xmlDOM;
	var xmlNodes;
	var data_xml = "";

	objSel = document.getElementById("lstProductForm");

	if (blnDisplay == "False")
	{
		objSel.disabled = true;
	}

	spnWaitForm.style.left = objSel.offsetWidth + 100;
	spnWaitForm.style.visibility = "visible";

	data_xml = httpRequest_ProductForm(lngProductID);
	xmlDOM = new ActiveXObject('MSXML2.DOMDocument');
	xmlDOM.loadXML(data_xml);
	xmlNodes = xmlDOM.selectNodes("//ProductForm");

	objSel.innerHTML = "";


	// Now add the rest of the items
	for (idx = 0; idx < xmlNodes.length; idx++)
	{
		selOpt = document.createElement("option");
		selOpt.value = xmlNodes[idx].getAttribute("Description");
		selOpt.innerText = xmlNodes[idx].getAttribute("Description");
		selOpt.setAttribute("dbid", xmlNodes[idx].getAttribute("ProductFormID"));
		if (xmlNodes.length == 1)
		{
			selOpt.selected = true;
		}
		objSel.appendChild(selOpt);
	}

	if (xmlNodes.length == 1)
	{
		if (blnDisplay == "False")
		{
			objSel.disabled = true;
		}
	}
	else
	{
		if (blnDisplay == "False")
		{
			objSel.disabled = false;
		}
	}

	spnWaitForm.style.visibility = "hidden";
	return true;
}

function GetProductStrengths(lngProductID)
{
	var blnDisplay = document.body.getAttribute("displaymode");
	var idx;
	var objSel;
	var selOpt;
	var lngProductFormID;

	var xmlDOM;
	var xmlNodes;
	var data_xml = "";

	objSel = document.getElementById("lstProductForm");
	if (objSel)
		lngProductFormID = Number(objSel.options[objSel.selectedIndex].getAttribute("dbid"));

	objSel = document.getElementById("lstProductStrength");

	if (blnDisplay == "False")
	{
		objSel.disabled = true;
	}

	spnWaitStrength.style.left = objSel.offsetWidth + 100;
	spnWaitStrength.style.visibility = "visible";

	data_xml = httpRequest_ProductStrength(lngProductID, lngProductFormID)
	xmlDOM = new ActiveXObject('MSXML2.DOMDocument');
	xmlDOM.loadXML(data_xml);
	xmlNodes = xmlDOM.selectNodes("//Strength");

	objSel.innerHTML = "";

	// Now add the rest of the items
	for (idx = 0; idx < xmlNodes.length; idx++) 
	{
	    //Add a blank and set as default
	    //26Nov10   Rams    F0102572 - user not forced to select strength
	    if (idx == 0 && xmlNodes[idx].getAttribute("Strength") != "-") {
	        selOpt = document.createElement("option");
	        selOpt.value = "";
	        selOpt.innerText = "";
	        objSel.appendChild(selOpt);
	    }
	    //
		selOpt = document.createElement("option");
		selOpt.value = xmlNodes[idx].getAttribute("Strength");
		selOpt.innerText = xmlNodes[idx].getAttribute("Strength");
		selOpt.setAttribute("UnitID", xmlNodes[idx].getAttribute("UnitID"));
		selOpt.setAttribute("Quantity", xmlNodes[idx].getAttribute("Quantity"));
		objSel.appendChild(selOpt);
	}


	if (blnDisplay == "False")
	{
		objSel.disabled = false;
	}

	//F0066603 ST 09Nov09 Updated so that dropdown is disabled should the strength be '-' which is not applicable.
	if (objSel.options[objSel.selectedIndex].innerHTML == "-")
	{
		objSel.disabled = true;
	}

	spnWaitStrength.style.visibility = "hidden";
	return true;
}

function GetProductPack(lngProductID)
{
	var blnDisplay = document.body.getAttribute("displaymode");
	var idx;
	var objSel;
	var selOpt;
	var lngProductFormID;

	var xmlDOM;
	var xmlNodes;
	var data_xml = "";

	objSel = document.getElementById("lstProductForm");
	if (objSel)
		lngProductFormID = Number(objSel.options[objSel.selectedIndex].getAttribute("dbid"));

	objSel = document.getElementById("lstProductPack");

	if (blnDisplay == "False")
	{
		objSel.disabled = true;
	}

	spnWaitPack.style.left = objSel.offsetWidth + 100;
	spnWaitPack.style.visibility = "visible";

	data_xml = httpRequest_ProductPack(lngProductID, lngProductFormID)
	xmlDOM = new ActiveXObject('MSXML2.DOMDocument');
	xmlDOM.loadXML(data_xml);
	xmlNodes = xmlDOM.selectNodes("//pr");

	objSel.innerHTML = "";

	//Add a blank row into the drop down first
	selOpt = document.createElement("option");
	selOpt.value = "";
	selOpt.innerText = "";
	selOpt.setAttribute("dbid", -1);
	objSel.appendChild(selOpt);

	for (idx = 0; idx < xmlNodes.length; idx++)
	{
		selOpt = document.createElement("option");
		selOpt.value = xmlNodes[idx].getAttribute("Pack");
		selOpt.innerText = xmlNodes[idx].getAttribute("Pack");
		selOpt.setAttribute("Pack", xmlNodes[idx].getAttribute("Description"));
		selOpt.setAttribute("ProductPackageID", xmlNodes[idx].getAttribute("ProductPackageID"));
		selOpt.setAttribute("UnitID_Quantity", xmlNodes[idx].getAttribute("UnitID_Quantity"));
		objSel.appendChild(selOpt);
	}


	if (document.getElementById("lstProductForm").options[document.getElementById("lstProductForm").selectedIndex].innerText == "" && document.getElementById("lstProductForm").options[document.getElementById("lstProductForm").selectedIndex].innerText == "-")
	{
		objSel.selectedIndex = 0;
	}

	if (blnDisplay == "False")
	{
		objSel.disabled = false;
	}

	spnWaitPack.style.visibility = "hidden";
	return true;
}


function GetProductBrands(lngProductID)
{
	var blnDisplay = document.body.getAttribute("displaymode");
	var idx;
	var objSel;
	var selOpt;

	var xmlDOM;
	var xmlNodes;
	var data_xml = "";

	objSel = document.getElementById("lstProductBrand");

	if (blnDisplay == "False")
	{
		objSel.disabled = true;
	}

	spnWaitBrand.style.left = objSel.offsetWidth + 100;
	spnWaitBrand.style.visibility = "visible";

	data_xml = httpRequest_ProductBrand(lngProductID);
	xmlDOM = new ActiveXObject('MSXML2.DOMDocument');
	xmlDOM.loadXML(data_xml);
	xmlNodes = xmlDOM.selectNodes("//ProductTradeName");

	objSel.innerHTML = "";

	for (idx = 0; idx < xmlNodes.length; idx++)
	{
		selOpt = document.createElement("option");
		selOpt.value = xmlNodes[idx].getAttribute("Brand");
		selOpt.innerText = xmlNodes[idx].getAttribute("Brand");
		objSel.appendChild(selOpt);
	}

	if (blnDisplay == "False")
	{
		objSel.disabled = false;
	}

	spnWaitBrand.style.visibility = "hidden";
	return true;
}

function OptTitration_onclick()
{
	//
	lstProfileLength_onchange(lstProfileLength);
	btnRecalculate_onclick();
	SetFormState();
}

function DisableTakeOnCheckBoxes(blnDisabled)
{
	var blnDisplay = document.body.getAttribute("displaymode");
	var idx = 0;
	var takeon = "";

	for (idx = 0; idx < 7; idx++)
	{
		takeon = "chkTakeOn" + idx.toString();
		document.getElementById(takeon).checked = true;
		if (blnDisplay == "False")
		{
			document.getElementById(takeon).disabled = blnDisabled;
		}
		else
		{
			// always disable when viewing back
			document.getElementById(takeon).disabled = true;
		}
	}
}


function TurnOnTakeOnCheckBoxes()
{
	for (var idx = 0; idx < 7; idx++)
	{
		document.getElementById("chkTakeOn" + idx.toString()).checked = true;
		//
		if (idx > 0)
			document.getElementById("chkPickup" + idx.toString()).checked = true;
	}
}

function TurnOffPickUpCheckBoxes()
{
	for (var idx = 1; idx < 7; idx++)
	{
		document.getElementById("chkPickup" + idx.toString()).checked = false;
	}
}


function btnRecalculate_onclick()
{
	var bDataChanged = false;
	//Reset to Take ons
	for (var idx = 1; idx < 7; idx++)
	{

		document.getElementById("chkPickup" + idx.toString()).checked = document.getElementById("chkTakeOn" + idx.toString()).checked;
	}
	//
	FillWeeklyBoxes();
}

//
// Hides/unhides sections of the profile depending upon the length of profile selected.
//
function lstProfileLength_onchange(object)
{
	if (Number(object.options[object.selectedIndex].getAttribute("dbid")) == 4)
	{
		document.getElementById("divDispensingSchedule").style.display = 'none';
		document.getElementById("divPickupProfile").style.display = 'none';
		//document.getElementById("spnDistribution").style.top = 270;
		//document.getElementById("spnSupplementary").style.top = 305;
		document.getElementById("spnDistribution").style.top = 375;
		document.getElementById("spnSupplementary").style.top = 410;
		document.getElementById("spnTakeonWarn").style.display = 'none';
		//Enable Take ons, since it might be disabled when it goes to Titrating Dose
		DisableTakeOnCheckBoxes(false);
		//untick all the PickUps 
		TurnOffPickUpCheckBoxes();
	}
	else
	{
		document.getElementById("divDispensingSchedule").style.display = 'block';
		document.getElementById("divPickupProfile").style.display = 'block';
		document.getElementById("spnDistribution").style.top = 730;
		document.getElementById("spnSupplementary").style.top = 760;
		document.getElementById("spnTakeonWarn").style.display = 'block';
		//MakePickUpsVisible(object.options[object.selectedIndex].getAttribute("dbid"));
	}
	FillWeeklyBoxes();
}


function MakePickUpsVisible(BatchLength)
{
	var blnDisplay = document.body.getAttribute("displaymode");

	//Loop through Titrating Pickups as this will form the maintained pickups in case of "Standard" Dose Option
	// Disable all the Day fields, for titrating dose as the user is not allowed to enter anything when dose is titrating
	// this is just to disable, from standard titrating to reducing or increasing
	for (var oDays = 0; oDays <= 13; oDays++)
	{
		document.getElementById("txtDay" + oDays).disabled = true;
	}
	//
	if (document.getElementById("lstTitration").options[document.getElementById("lstTitration").selectedIndex].getAttribute("id") == "1")
	{
		switch (Number(BatchLength - 1))
		{
			case 0:
				document.getElementById("spnWeekName1").style.display = 'none';
				for (var oDays = 7; oDays <= 13; oDays++)
				{
					document.getElementById("spnDay" + oDays).style.display = 'none';
				}
				// now enable Days fields that are visible for BatchLength 1
				for (var oDays = 0; oDays <= 6; oDays++)
				{
					if (blnDisplay == "False")
					{
						document.getElementById("txtDay" + oDays).disabled = false;
					}
					else
					{
						// Always disable when viewing back
						document.getElementById("txtDay" + oDays).disabled = true;
					}
				}
				break;
			case 1:
				document.getElementById("spnWeekName1").style.display = 'block';
				for (var oDays = 7; oDays <= 13; oDays++)
				{
					document.getElementById("spnDay" + oDays).style.display = 'block';
				}
				// now enable Days fields that are visible for BatchLength 2
				for (var oDays = 0; oDays <= 13; oDays++)
				{
					if (blnDisplay == "False")
					{
						document.getElementById("txtDay" + oDays).disabled = false;
					}
					else
					{
						// always disable when viewing back
						document.getElementById("txtDay" + oDays).disabled = true;
					}
				}
				break;
		}
		//
		FillWeeklyBoxes();
	}
}
    
//
// Generates a product description based upon the values from the drop downs on the form.
// Excludes items that are disabled or set to Any
//
function GenerateDescription()
{
	var PrescriptionDescription = '';
	var objSelect = null;

	// Product Name
	objSelect = document.getElementById("lstProducts");
	PrescriptionDescription += objSelect.options[objSelect.selectedIndex].innerHTML;

	// Product Strength
	objSelect = document.getElementById("lstProductStrength");
	if (objSelect.disabled == false)
	{
		if (objSelect.selectedIndex > -1)
		{
			if (objSelect.options[objSelect.selectedIndex].innerHTML != "Any")
				PrescriptionDescription += " " + objSelect.options[objSelect.selectedIndex].innerHTML;
		}
	}

	// Product Form
	objSelect = document.getElementById("lstProductForm");
	if (objSelect.disabled == false)
	{
		if (objSelect.selectedIndex > -1)
		{
			if (objSelect.options[objSelect.selectedIndex].innerHTML != "Any")
				PrescriptionDescription += " " + objSelect.options[objSelect.selectedIndex].innerHTML;
		}
	}

	// Product Brand
	objSelect = document.getElementById("lstProductBrand");
	if (objSelect.disabled == false)
	{
		if (objSelect.selectedIndex > -1)
		{
			//F0066852 ST 21Oct09 Stopped empty brackets appearing when selection is empty
			if (objSelect.options[objSelect.selectedIndex].innerHTML != "Any" && objSelect.options[objSelect.selectedIndex].innerHTML != "")
			{
				PrescriptionDescription += " (" + objSelect.options[objSelect.selectedIndex].innerHTML + ")";
			}
		}
	}

	// Product Pack
	objSelect = document.getElementById("lstProductPack");
	if (objSelect.disabled == false)
	{
		if (objSelect.selectedIndex > -1)
		{
			//F0066852 ST 21Oct09 Stopped empty brackets appearing when selection is empty
			if (objSelect.options[objSelect.selectedIndex].innerHTML != "Any" && objSelect.options[objSelect.selectedIndex].innerHTML != "")
			{
				PrescriptionDescription += " (" + objSelect.options[objSelect.selectedIndex].innerHTML + ")";
			}
		}
	}

	// Update the main window product description
	window.parent.parent.document.getElementById("spnItemTitle").innerHTML = PrescriptionDescription;
}

//
// Gets the data to populate the product form combobox
//
function httpRequest_ProductForm(lngProductID)
{
	var objHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");
	var strURL = '../../OrderEntry/CustomControls/SMSWorker.aspx'
				  + '?SessionID=' + document.body.getAttribute("sid")
				  + '&ProductID=' + lngProductID
				  + '&Mode=productform';

	objHTTPRequest.open("POST", strURL, false);
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");
	objHTTPRequest.send(null);

	return objHTTPRequest.responseText;
}

//
// Gets the data to populate the product pack combobox
//
function httpRequest_ProductPack(lngProductID, lngProductFormID)
{
	var objHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");
	var strURL = '../../OrderEntry/CustomControls/SMSWorker.aspx'
				  + '?SessionID=' + document.body.getAttribute("sid")
				  + '&ProductID=' + lngProductID
				  + '&ProductFormID=' + lngProductFormID
				  + '&Mode=productpack';

	objHTTPRequest.open("POST", strURL, false);
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");
	objHTTPRequest.send(null);

	return objHTTPRequest.responseText;
}

//
// Gets the data to populate the product brand combobox
//
function httpRequest_ProductBrand(lngProductID)
{
	var objHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");
	var strURL = '../../OrderEntry/CustomControls/SMSWorker.aspx'
				  + '?SessionID=' + document.body.getAttribute("sid")
				  + '&ProductID=' + lngProductID
				  + '&Mode=productbrands';

	objHTTPRequest.open("POST", strURL, false);
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");
	objHTTPRequest.send(null);

	return objHTTPRequest.responseText;
}

//
// Gets the data to populate the product strength combobox
//
function httpRequest_ProductStrength(lngProductID, lngProductFormID)
{
	var objHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");
	var strURL = '../../OrderEntry/CustomControls/SMSWorker.aspx'
				  + '?SessionID=' + document.body.getAttribute("sid")
				  + '&ProductID=' + lngProductID
				  + '&ProductFormID=' + lngProductFormID
				  + '&Mode=productstrength';

	objHTTPRequest.open("POST", strURL, false);
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");
	objHTTPRequest.send(null);

	return objHTTPRequest.responseText;
}

//
// Gets the data to populate the product route combobox
//
function httpRequest_ProductRoutes(lngProductID, ProductForm, ProductBrand, ProductPack)
{
	var objHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");
	var strURL = '../../OrderEntry/CustomControls/SMSWorker.aspx'
				  + '?SessionID=' + document.body.getAttribute("sid")
				  + '&ProductID=' + lngProductID
				  + '&ProductForm=' + ProductForm
				  + '&ProductBrand=' + ProductBrand
				  + '&ProductPack=' + ProductPack
				  + '&Mode=productroutes';

	objHTTPRequest.open("POST", strURL, false);
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");
	objHTTPRequest.send(null);

	return objHTTPRequest.responseText;
}

//
// Gets the data to populate the dose units combobox
//
function httpRequest_DoseUnits(lngProductID, ProductForm, StrengthQuantity, UnitID)
{
	var objHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP");
	var strURL = '../../OrderEntry/CustomControls/SMSWorker.aspx'
				  + '?SessionID=' + document.body.getAttribute("sid")
				  + '&ProductID=' + lngProductID
				  + '&ProductForm=' + ProductForm
				  + '&StrengthQuantity=' + StrengthQuantity
				  + '&UnitID=' + UnitID
				  + '&Mode=doseunits';

	objHTTPRequest.open("POST", strURL, false);
	objHTTPRequest.setRequestHeader("Content-Type", "text/xml");
	objHTTPRequest.send(null);

	return objHTTPRequest.responseText;
}

//
// Updates the contents of the profile length combobox with the available options according to the drug selected.
//
function UpdateProfileLength(blnIsMDA)
{
	var selOpt;

	var objSel = document.getElementById("lstProfileLength");
	objSel.innerHTML = "";

	selOpt = document.createElement("option");
	selOpt.value = "1 Week";
	selOpt.innerText = "1 Week";
	selOpt.setAttribute("dbid", 1);
	objSel.appendChild(selOpt);

	selOpt = document.createElement("option");
	selOpt.value = "2 Weeks";
	selOpt.innerText = "2 Weeks";
	selOpt.selected = true;
	selOpt.setAttribute("dbid", 2);
	objSel.appendChild(selOpt);

	if (!blnIsMDA)
	{
		selOpt = document.createElement("option");
		selOpt.value = "4 Weeks";
		selOpt.innerText = "4 Weeks";
		selOpt.setAttribute("dbid", 4);
		objSel.appendChild(selOpt);
	}
}

function ProductRouteChange(lngProductID, Mode)
{
	var blnDisplay = document.body.getAttribute("displaymode");
	var idx;
	var objSel;
	var selOpt;

	var xmlDOM;
	var xmlNodes;
	var data_xml = "";


	objSel = document.getElementById("lstProductRoute");
	if (Mode == 'SHOWALL' || objSel.options[objSel.selectedIndex].innerText == 'Other')
	{
		if (blnDisplay == "False")
		{
			objSel.disabled = true;
		}

		spnWaitBrand.style.left = objSel.offsetWidth + 100;
		spnWaitBrand.style.visibility = "visible";

		data_xml = httpRequest_ProductRoutes(lngProductID, '', '', '')

		xmlDOM = new ActiveXObject('MSXML2.DOMDocument');
		xmlDOM.loadXML(data_xml);
		xmlNodes = xmlDOM.selectNodes("//Routes/ProductRoute");

		objSel.innerHTML = "";

		for (idx = 0; idx < xmlNodes.length; idx++)
		{
			selOpt = document.createElement("option");
			selOpt.value = xmlNodes[idx].getAttribute("Description")
			selOpt.innerText = xmlNodes[idx].getAttribute("Description")
			selOpt.setAttribute("dbid", xmlNodes[idx].getAttribute("ProductRouteID"));
			objSel.appendChild(selOpt);
		}
	}

	if (blnDisplay == "False")
	{
		objSel.disabled = false;
	}

	spnWaitBrand.style.visibility = "hidden";
	return true;
}

function chkTakeOn_onclick(objTakeOn)
{
	var idx = 0;
	var takeon = "";
	var checked = 0;


	if (objTakeOn.checked == false)
	{
		// make sure this isn't the last checkbox being unchecked and if it is then don't allow it

		for (idx = 0; idx < 7; idx++)
		{
			takeon = "chkTakeOn" + idx.toString();

			// ignore the one we are currently on
			if (document.getElementById(takeon).id == objTakeOn.id)
				continue;

			if (document.getElementById(takeon).checked == true)
			{
				checked++;
			}
		}

		if (checked == 0)
		{
			objTakeOn.checked = true;
		}
	}
	//
	var ChkPickUp = document.getElementById("chkPickup" + Number(objTakeOn.getAttribute("name")));
	if (ChkPickUp && !ChkPickUp.disabled)
	{
		ChkPickUp.checked = objTakeOn.checked;
		//    
		btnRecalculate_onclick();
	}
	else if (Number(objTakeOn.getAttribute("name")) == 0)
	{
		FillWeeklyBoxes();
	}
	//
}

//Given a listbox object and description will select that item from the list
function SelectListboxItemByDescription(objSel, strDescription)
{
	var idx = 0;

	for (idx = 0; idx < objSel.length; idx++)
	{
		if (objSel.options[idx].innerText == strDescription)
			objSel.options[idx].selected = true;
	}
}

function GetDoseUnits(lngProductID)
{
	var ProductPack = document.getElementById("lstProductPack").options[document.getElementById("lstProductPack").selectedIndex].innerText;
	var blnDisplay = document.body.getAttribute("displaymode");
	var objSel = document.getElementById("lstUnits");

	if (blnDisplay == "False")
	{
		objSel.disabled = true;
	}

	spnWaitBrand.style.left = objSel.offsetWidth + 100;
	spnWaitBrand.style.visibility = "visible";

	if (ProductPack == "" || ProductPack == undefined)
	{
		var objStrength = document.getElementById("lstProductStrength");
		var ProductForm = document.getElementById("lstProductForm").options[document.getElementById("lstProductForm").selectedIndex].innerText;
		var ProductStrength = objStrength.options[objStrength.selectedIndex].innerText;
		// If either product form or strength is empty then set dosing units to blank
		if (ProductForm == "" || ProductStrength == "")
		{
			data_xml = '<units></units>';
		}
		else
		{
			data_xml = httpRequest_DoseUnits(lngProductID, ProductForm, objStrength.options[objStrength.selectedIndex].getAttribute("Quantity"), objStrength.options[objStrength.selectedIndex].getAttribute("UnitID"));
		}
	}
	else {
	    var objSelPack = document.getElementById("lstProductPack");
		data_xml = '<units><unit description="' + objSelPack.options[objSelPack.selectedIndex].getAttribute("Pack") + '" divisible="false" id="' + objSelPack.options[objSelPack.selectedIndex].getAttribute("UnitID_Quantity") + '" productpackageid="' + objSelPack.options[objSelPack.selectedIndex].getAttribute("ProductPackageID") + '" type="pack" >';
		data_xml = data_xml + '<increment value="1" />';
		data_xml = data_xml + '</unit></units>';
    }

	
	//01Dec09   Rams    F0070698 - Script Error when clicking on the button next to Dose Field    
	unitsData.loadXML(data_xml);

	xmlDOM = new ActiveXObject('MSXML2.DOMDocument');
	xmlDOM.loadXML(data_xml);
	xmlNodes = xmlDOM.selectNodes("//unit");
	//
	objSel.innerHTML = "";
	//
	for (idx = 0; idx < xmlNodes.length; idx++)
	{
		var selOpt = document.createElement("option");
		selOpt.value = xmlNodes[idx].getAttribute("Description")
		selOpt.setAttribute("dbid", xmlNodes[idx].getAttribute("id"));
		selOpt.setAttribute("formid", xmlNodes[idx].getAttribute("formid"));
		selOpt.setAttribute("productpackageid", xmlNodes[idx].getAttribute("productpackageid"));
		selOpt.setAttribute("type", xmlNodes[idx].getAttribute("type")); 						//25Apr04 AE  Added missing attribute type
		selOpt.innerText = xmlNodes[idx].getAttribute("description");
		objSel.appendChild(selOpt);
	}
	//
	if (blnDisplay == "False")
	{
		objSel.disabled = false;
	}

	spnWaitBrand.style.visibility = "hidden";
	return true;
}