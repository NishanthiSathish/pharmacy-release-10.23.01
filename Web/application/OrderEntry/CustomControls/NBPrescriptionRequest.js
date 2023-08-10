var glngUnitID = 0;

//
//===========================================================================
//							Public Methods
//===========================================================================

function Resize() {
    //Standard resize event
    void ResizeOrderForm(document, false);
}

//===========================================================================

function Populate(strData_XML) {
    //Standard Populate method, called from the hosting form
    var lngID = 0;
    var lngProductID = 0;
    var routeAtt = null;
    //
    instanceData.loadXML(strData_XML);
    if (instanceData.selectSingleNode('//attribute[@name="ProductID"]/@value') != null) {
        lngProductID = Number(instanceData.selectSingleNode('//attribute[@name="ProductID"]/@value').value);
        //05Jul11   Rams    7822 - F0122093 print 4 week profile
        var selectedIndex = SetListItemByDbIdReturnSelectedIndex(lstProducts, lngProductID);
        if (selectedIndex > -1) {
            var oProducts = document.getElementById("lstProducts");
            if (oProducts != undefined) {
                var IsMDA = Number(oProducts.options[oProducts.selectedIndex].getAttribute("ismda"));
                if (IsMDA)
                    UpdateProfileLength(IsMDA);
            }
        }
        // 
        //09Sep09   Rams    Removed few Duplicate coding  
        GetProductForm(lngProductID);
        GetProductStrengths(lngProductID);
        GetProductPack(lngProductID);
        GetProductBrands(lngProductID);
        GetProductRoutes(lngProductID);
        //
        routeAtt = instanceData.selectSingleNode("/data/attribute[@name='ProductRouteID']");
    }
    //Strength
    var oProcessData = instanceData.selectSingleNode("/data/attribute[@name='Strength']");
    if (oProcessData != null && oProcessData.getAttribute("value") != "") {
        SetListItemByAttribute(lstProductStrength, "text", oProcessData.getAttribute("value"));
    }

    //Pack
    oProcessData = instanceData.selectSingleNode("/data/attribute[@name='Pack']");
    if (oProcessData != null && oProcessData.getAttribute("value") != "") {
        SetListItemByAttribute(lstProductPack, "text", oProcessData.getAttribute("value"));
    }
    if (lngProductID > 0) {
        GetDoseUnits(lngProductID);
    }

    //Brands
    oProcessData = instanceData.selectSingleNode("/data/attribute[@name='Brand']");
    if (oProcessData != null && oProcessData.getAttribute("value") != "") {
        SetListItemByAttribute(lstProductBrand, "text", oProcessData.getAttribute("value"));
    }

    //Units
    oProcessData = instanceData.selectSingleNode("/data/attribute[@name='UnitID']");
    if (oProcessData != null) {
        //F0078831 ST 21Jun10 If the dosing unit is quantity which is the case when the item is prescribed
        //in its form i.e. tablet rather than mg.
        //For such items we need to set the dosing unit dropdown to show this form
        if (oProcessData.getAttribute("text").toLowerCase() == "qty") {
            // dosed in qty so get the product form instead
            oProcessData = instanceData.selectSingleNode("/data/attribute[@name='ProductFormID']");
            if (oProcessData != null) {
                SetListItemByAttribute(lstUnits, "formid", oProcessData.getAttribute("value"));
            }
        }
        else {
            if (Number(oProcessData.getAttribute("value")) > 0) {
                SetListItemByDBID(lstUnits, oProcessData.getAttribute("value"));
            }
        }
    }

    if (window.parent.scheduleData.XMLDocument.xml != '') {																						//25Apr04 AE  Won't be a schedule when loading a template; fixed "silent" bug which was preventing the rest of this procedure from working
        txtStartDate.value = window.parent.scheduleData.selectSingleNode("/root/Schedule").getAttribute("StartDate");
    }
    else {
        //16May2011 Rams    F0117286 - Refer to RFC (When amend the past date, Start date should be revise itself to Today)"
        var sDate;
        if (instanceData.selectSingleNode("/data/attribute[@name='RequestDate']/@value") != null &&
                         DisplayStartDateWithoutModify(Date2ddmmccyy(ParseTDate(instanceData.selectSingleNode("/data/attribute[@name='RequestDate']/@value").value)))) {
            sDate = Date2ddmmccyy(ParseTDate(instanceData.selectSingleNode("/data/attribute[@name='RequestDate']/@value").value));
        }
        else {
            sDate = Date2ddmmccyy((new Date()))
        }
        txtStartDate.value = sDate;
    }
    if (IsTDate(txtStartDate.value)) {
        txtStartDate.value = Date2ddmmccyy(TDate2Date(txtStartDate.value));
    }
    //
    if (routeAtt != null && Number(routeAtt.getAttribute("value")) > 0)					//13Apr04 AE  Modified IF; previous clause seemed to be a hack to prevent unwanted pop-ups on page load.  Now fixed.
    {
        //24Nov10   Rams    F0102308 - route changes from 'Sublingual' to 'Ear topically' when item is viewed    
        if (SetListItemByDBID(lstProductRoute, routeAtt.getAttribute("value")) != true) {
            ProductRouteChange(lngProductID, "SHOWALL");
            SetListItemByDBID(lstProductRoute, routeAtt.getAttribute("value"));
        }
    }

    // Distribution Method
    if (instanceData.selectSingleNode('//attribute[@name="DistributionMethodID"]') != null) {
        SetListItemByDBID(lstDistribution, Number(instanceData.selectSingleNode('//attribute[@name="DistributionMethodID"]').getAttribute("value")));
    }
    // dose
    if (instanceData.selectSingleNode("/data/attribute[@name='Dose']/@value") != null) {
        txtDoseQty.value = Number(instanceData.selectSingleNode("/data/attribute[@name='Dose']/@value").value);
    }

    //  09Sep09 Rams    Commented as the Unit is already loaded 
    //	//15Apr04 AE  Added support for ProductForms																																		
    //	//Unit: may be an actual unit (mg, ml) or a form (tablet, capsule)			
    //	//In the case of a form, we have a unitID of quantity, and only ever a single entry in the list.
    //	if (lngProductID>0)
    //	{
    //		lngID = GetValueFromXML('UnitID');
    //	}
    //	if (lngID == null)
    //	{
    //		lngID = 0;
    //	}	
    //	//store the ID for use when the units list has loaded asyncronously											
    //	glngUnitID = lngID;

    // EndDate
    if (instanceData.selectSingleNode("/data/attribute[@name='EndDate']/@value") != null) {
        chkEndDate.checked = true;
        txtEndDate.value = instanceData.selectSingleNode("/data/attribute[@name='EndDate']/@value").value;
        txtEndDate.setAttribute("LastValue", txtEndDate.value);
        txtEndDate.className = "StandardField";
        if (IsTDate(txtEndDate.value)) {
            txtEndDate.value = Date2ddmmccyy(TDate2Date(txtEndDate.value));
        }
        lstProfileLength.disabled = true;
    }
    else {
        chkEndDate.checked = false;
        txtEndDate.value = "";
        txtEndDate.className = "DisabledField";
    }
    txtEndDate.setAttribute("LastValue", txtEndDate.value);
    //
    //Now set the Duration
    if (instanceData.selectSingleNode("/data/attribute[@name='Duration']/@text") != null) {
        SetListItemByAttribute(lstProfileLength, "dbid", instanceData.selectSingleNode("/data/attribute[@name='Duration']").getAttribute("value"));
        lstProfileLength_onchange(lstProfileLength);
    }

    if (instanceData.selectSingleNode("/data/attribute[@name='DoseChange']/@value") != null && Number(instanceData.selectSingleNode("/data/attribute[@name='DoseChange']/@value").value) < 0) {
        // Reducing regime
        txtTitrateBy.value = -Number(instanceData.selectSingleNode("/data/attribute[@name='DoseChange']/@value").value);
        txtTitrateInterval.value = instanceData.selectSingleNode("/data/attribute[@name='DoseChangeInterval']/@value").value;
        txtTitrateThreshold.value = Number(instanceData.selectSingleNode("/data/attribute[@name='DoseChangeThreshold']/@value").value);
        lstTitrateAction.selectedIndex = (instanceData.selectSingleNode("/data/attribute[@name='MaintainDose']/@value").value == 1 ? 0 : 1);
        SetRegimeName("reducing");
    }
    else if (instanceData.selectSingleNode("/data/attribute[@name='DoseChange']/@value") != null && Number(instanceData.selectSingleNode("/data/attribute[@name='DoseChange']/@value").value) > 0) {
        // Increasing regime
        txtTitrateBy.value = instanceData.selectSingleNode("/data/attribute[@name='DoseChange']/@value").value;
        txtTitrateInterval.value = instanceData.selectSingleNode("/data/attribute[@name='DoseChangeInterval']/@value").value;
        txtTitrateThreshold.value = Number(instanceData.selectSingleNode("/data/attribute[@name='DoseChangeThreshold']/@value").value);
        lstTitrateAction.selectedIndex = (instanceData.selectSingleNode("/data/attribute[@name='MaintainDose']/@value").value == 1 ? 0 : 1);
        SetRegimeName("increasing");
    }
    else {
        // Standard Regime
        SetRegimeName("standard");
    }

    //08Sep09   Rams    Set the Form State after the Regimen is Set
    SetFormState();

    // PickUp and Takeon check boxes
    for (var intDayCounter = 1; intDayCounter <= 7; intDayCounter++) {
        //Takeon from 0 to 6
        if (instanceData.selectSingleNode("/data/attribute[@name='TakeOn" + (intDayCounter).toString() + "']/@value") != null) {
            if (instanceData.selectSingleNode("/data/attribute[@name='TakeOn" + (intDayCounter).toString() + "']/@value").value == 1) {
                document.getElementById("chkTakeOn" + (intDayCounter - 1).toString()).checked = true;
            }
            else {
                document.getElementById("chkTakeOn" + (intDayCounter - 1).toString()).checked = false;
            }
        }

        //PickUp from 1 to 6
        if ((intDayCounter < 7 && instanceData.selectSingleNode("/data/attribute[@name='PickUp" + (intDayCounter + 1).toString() + "']/@value") != null)) {
            if (instanceData.selectSingleNode("/data/attribute[@name='PickUp" + (intDayCounter + 1).toString() + "']/@value").value == 1) {
                document.getElementById("chkPickUp" + intDayCounter.toString()).checked = true;
            }
            else {
                document.getElementById("chkPickUp" + intDayCounter.toString()).checked = false;
            }
        }
        //
    }

    //Supplementary text
    if (instanceData.selectSingleNode("/data/attribute[@name='SupplementaryText']/@value") != null) {
        txtExtra.value = instanceData.selectSingleNode("/data/attribute[@name='SupplementaryText']/@value").value; 		//01Dec03 TH end block
    }

    //unitsData.src = "PrescriptionLoader.aspx?SessionID=" + formBody.getAttribute("sid") + "&ProductID=" + lngProductID + "&Mode=doseunits";
    //routesData.src = "PrescriptionLoader.aspx?SessionID=" + formBody.getAttribute("sid") + "&ProductID=" + lngProductID + "&Mode=approvedroutes";
    //
    //CalculateTotals();

    FillWeeklyBoxes();

    //Loads the days xml and fill the corresponding days with the prescribed dose.
    //21Oct09   Rams    F0066962
    if (instanceData.selectSingleNode("/data/attribute[@name='Days']/@value") != null) {
        var sDays = "<data>" + instanceData.selectSingleNode("/data/attribute[@name='Days']/@value").value.toString() + "</data>";
        instanceData.loadXML(sDays);
        var iMaxDays = MaxDayBoxCount();
        for (var intDayCounter = 0; intDayCounter < iMaxDays; intDayCounter++) // 14 ; intDayCounter++)
        {
            if (instanceData.selectSingleNode("/data/Day[@DayNo='" + (intDayCounter + 1).toString() + "']/@Dose") != null) {
                document.getElementById("txtDay" + intDayCounter.toString()).value = instanceData.selectSingleNode("/data/Day[@DayNo='" + (intDayCounter + 1).toString() + "']/@Dose").value;
            }
            else {
                document.getElementById("txtDay" + intDayCounter.toString()).value = 0;
            }
        }
    }
    RenderDayNames(txtStartDate);
    DisableDayBoxesIfViewing();
    //SetFormState();
}

//===========================================================================

function GetData() {
    //Standard method to read data from this control.
    //Called from the hosting form to retrieve data
    //Returns XML elements as follows:
    //			<attribute name="" value="" />

    var strXML = "";
    var strUnitText = '';
    var strDays = "";
    //alert the user in case the total dose entered does not add up to the to take in during the treatment period
    //08Sep09   Rams    F0062911 - Referenced GetTotalDose
    if (GetRegimeName() == "standard" && Number(txtTotal.value) != GetTotalDose(MaxDayBoxCount())) {
        var strFeatures = 'dialogHeight:10px;'
					 + 'dialogWidth:425px;'
					 + 'resizable:no;'
					 + 'status:no;help:no;';
        //
        MessageBox('Cannot Save', 'Entered Dose (' + txtTotal.value + ') does not add up to the Total of doses (' + GetTotalDose(MaxDayBoxCount()).toString() + ') in the treatment period.Re-visit the Doses entered', 'ok', strFeatures);
        return 'ERROR';
    }
    //
    strXML += FormatXML('ProductID', lstProducts.children(lstProducts.selectedIndex).getAttribute("dbid"), lstProducts.children(lstProducts.selectedIndex).innerText); //TH Added Desc
    if (document.getElementById("lstProductRoute").length > 0) {
        strXML += FormatXML('ProductRouteID', document.getElementById("lstProductRoute").options[document.getElementById("lstProductRoute").selectedIndex].getAttribute("dbid"), document.getElementById("lstProductRoute").options[document.getElementById("lstProductRoute").selectedIndex].innerText); 														//13Apr04 AE  Now saves text along with ID
    }
    else {
        strXML += FormatXML('ProductRouteID', '0', '');
    }

    strXML += FormatXML('Dose', txtDoseQty.value);

    //Units; may be actual units (mg, ml etc) or forms (tablet, capsule etc)														//20Apr04 AE  Further modified 15Apr04 AE  Added support for ProductForms	
    if (lstUnits.selectedIndex > -1) {
        //Units may hold an actual unit, or a form (eg tablet), or eventually packaging (eg, pack, kit, etc)
        strType = lstUnits.options[lstUnits.selectedIndex].getAttribute('type');
        if (strType == 'form') {
            //ProductForms, eg tablet, capsule, etc. 
            strXML += FormatXML('ProductFormID', lstUnits.options[lstUnits.selectedIndex].getAttribute('formid'), lstUnits.options[lstUnits.selectedIndex].text);
            strUnitText = '';
        }
        else {
            strUnitText = lstUnits.options[lstUnits.selectedIndex].text;
        }

        //Now the actual units, mg, ml etc. In the case of Forms this is not shown, and is always Quantity.
        strXML += FormatXML('UnitID', lstUnits.options[lstUnits.selectedIndex].getAttribute('dbid'), strUnitText);
    }
    else {
        strXML += FormatXML('ProductFormID', 0, '');
    }

    //-------------------------------------------------------------------

    if (GetRegimeName() == "reducing") {
        // Reducing
        strXML += FormatXML('DoseChange', -Number(txtTitrateBy.value));
        strXML += FormatXML('DoseChangeInterval', Number(txtTitrateInterval.value));
        strXML += FormatXML('DoseChangeThreshold', Number(txtTitrateThreshold.value));
        strXML += FormatXML('MaintainDose', document.getElementById("lstTitrateAction").children[document.getElementById("lstTitrateAction").selectedIndex].innerText == "Maintain" ? 1 : 0);
    }
    else if (GetRegimeName() == "increasing") {
        // Increasing
        strXML += FormatXML('DoseChange', Number(txtTitrateBy.value));
        strXML += FormatXML('DoseChangeInterval', Number(txtTitrateInterval.value));
        strXML += FormatXML('DoseChangeThreshold', Number(txtTitrateThreshold.value));
        strXML += FormatXML('MaintainDose', document.getElementById("lstTitrateAction").children[document.getElementById("lstTitrateAction").selectedIndex].innerText == "Maintain" ? 1 : 0);
    }
    else {
        strXML += FormatXML('DoseChange', 0);
        strXML += FormatXML('DoseChangeInterval', 0);
        strXML += FormatXML('DoseChangeThreshold', 0);
        strXML += FormatXML('MaintainDose', 0);
    }

    //Additional text
    strXML += FormatXML('SupplementaryText', txtExtra.value);

    strXML += FormatXML('DistributionMethodID', lstDistribution.children(lstDistribution.selectedIndex).getAttribute("dbid"));

    if (txtEndDate.value != "") {
        strXML += FormatXML('EndDate', Date2TDate(ddmmccyy2Date(txtEndDate.value)));
    }

    // Take on days
    for (var intTakeOn = 0; intTakeOn < 7; intTakeOn++) {
        var blnChecked = document.getElementById('chkTakeOn' + intTakeOn.toString()).checked;
        strXML += FormatXML('TakeOn' + ((intTakeOn + 1).toString()), blnChecked ? 1 : 0);
    }

    for (var intPickUp = 1; intPickUp < 7; intPickUp++) {
        var blnChecked = document.getElementById('chkPickUp' + intPickUp.toString()).checked;
        strXML += FormatXML('PickUp' + ((intPickUp + 1).toString()), blnChecked ? 1 : 0);
    }

    strXML += FormatXML('Duration', lstProfileLength.options[lstProfileLength.selectedIndex].getAttribute("dbid"), lstProfileLength.options[lstProfileLength.selectedIndex].innerText);

    var fltDose = 0;
    for (var intDayCounter = 0; intDayCounter < 99; intDayCounter++) {
        if (document.getElementById('spnDay' + intDayCounter) == undefined || document.getElementById('spnDay' + intDayCounter).style.display == "none")
            break;


        fltDose = Number(document.getElementById('txtDay' + intDayCounter.toString()).value);

        if (fltDose > 0)
            strDays += "<Day DayNo='" + (intDayCounter + 1) + "' Dose='" + fltDose + "' />";
    }

    //Amend the Maintain Dose as well in case if found and it has to be done for Titrating doses alone
    if (GetRegimeName() != "standard") {
        var intCurrentCounter = intDayCounter;
        fltDose = 0;
        for (intDayCounter = 0; intDayCounter < 14; intDayCounter++) {
            intCurrentCounter++;
            if (document.getElementById('spnMnDay' + intDayCounter).style.display == "none")
                break;
            //
            fltDose = Number(document.getElementById('txtMnDay' + intDayCounter.toString()).value);
            //
            if (fltDose > 0)
                strDays += "<Day DayNo='" + (intCurrentCounter) + "' Dose='" + fltDose + "' />";
        }
        //
    }
    //
    if (strDays != "")
        strXML += FormatXML('Days', strDays);

    //Duplicate info of Product ID
    //strXML += FormatXML('ProductID', lstProducts.children(lstProducts.selectedIndex).getAttribute("dbid"), lstProducts.children(lstProducts.selectedIndex).innerText); //TH Added Desc

    strXML += FormatXML('Strength', lstProductStrength.options[lstProductStrength.selectedIndex].innerText);
    strXML += FormatXML('Pack', lstProductPack.options[lstProductPack.selectedIndex].innerText);

    if (lstProductBrand.selectedIndex != -1) {
        strXML += FormatXML('Brand', lstProductBrand.options[lstProductBrand.selectedIndex].innerText);
    }


    //Build a default description
    strXML += FormatXML('ASCDescription', lstProducts.children(lstProducts.selectedIndex).innerText);
    //30Oct2009 JMei F0066887 add startdate into xml
    strXML += FormatXML('StartDate', Date2TDate(ddmmccyy2Date(txtStartDate.value)));

    // Hack the scheduleData XML island on the parent OrderForm.aspx page to put a schedule so that it will save the date we want
    // in the Request.RequestDate field. What an ache! 
    strSchedule_XML = "";
    strSchedule_XML += '<root><Schedule ScheduleID_Parent="0" ScheduleID="0" ScheduleTypeID="1" ScheduleFrequency="0" DailyFrequency="0" DailyFrequencyUnit="" StartTime="00:00" EndTime="11:59" ';
    strSchedule_XML += ' StartDate="' + Date2TDate(ddmmccyy2Date(txtStartDate.value)) + '" EndDate="' + Date2TDate(ddmmccyy2Date(txtEndDate.value)) + '"';
    strSchedule_XML += ' Detail="" UnitID="2" Every="" Once="CHECKED" Repeats="1" Daily="CHECKED" Weeks="" Weekly="" Days="0" ';
    strSchedule_XML += ' Months="0" DayID="0" MonthlyFrequency="1" Monthly="" Monday="" Tuesday="" Wednesday="" Thursday="" Friday="" Saturday="" Sunday="" ';
    strSchedule_XML += ' SpecificDay="CHECKED" GenericDay="on" Description="Once on ' + txtStartDate.value + '" LocationID="0">';
    strSchedule_XML += '<WeeklySchedule WeeklyScheduleID="0" ScheduleID="0" Day1="0" Day2="0" Day3="0" Day4="0" Day5="0" Day6="0" Day7="0"/>';
    strSchedule_XML += '<MonthlySchedule MonthlyScheduleID="0" ScheduleID="0"/></Schedule></root>';
    window.parent.scheduleData.loadXML(strSchedule_XML);

    //Return it
    return 'xml=' + strXML;
}

//===========================================================================

function FilledIn() {
    if (lstProducts.selectedIndex == -1) return false;
    if (lstUnits.selectedIndex == -1) return false;
    if (Number(txtDoseQty.value) <= 0) return false;
    if (Number(document.getElementById("lstProductRoute").options[document.getElementById("lstProductRoute").selectedIndex].getAttribute("dbid")) <= 0) return false;
    if (Number(document.getElementById("lstProductStrength").options[document.getElementById("lstProductStrength").selectedIndex].innerText) == 0) return false;
    if (GetRegimeName() == "reducing" && (Number(txtTitrateBy.value) <= 0 || Number(txtTitrateInterval.value) <= 0)) return false;
    if (GetRegimeName() == "increasing" && (Number(txtTitrateBy.value) <= 0 || Number(txtTitrateInterval.value) <= 0)) return false;

    return true;
}

//===========================================================================

//===========================================================================
//									Route selection 
//===========================================================================

function NBSelectRoute(blnShowAllRoutes) {
    //Launch the route picker so that the user can select a route
    //
    //			blnShowAllRoutes:			If true, then a list of all routes is loaded from
    //											the server, if required, and all are displayed 
    //											in the list.  Otherwise, only approved routes are shown.

    var blnWaitForLoad = false;

    //Check if we have, and/or need, all routes
    var blnAllRoutesLoaded = (routesData.getAttribute('allloaded') == '1');
    if (blnShowAllRoutes == true) {
        //Show all routes, we may need to load them from the server
        if (!blnAllRoutesLoaded) {
            //We do have to load the data.  Start the async load, 
            //and wait for it to complete
            formBody.style.cursor = 'wait';
            void routesData.setAttribute('loading', '1');
            var strURL = 'PrescriptionLoader.aspx'
					  + '?SessionID=' + formBody.getAttribute('sid')
					  + '&ProductID=' + lstProducts.children(lstProducts.selectedIndex).getAttribute("dbid")
					  + '&Mode=allroutes';
            routesData.src = strURL;
            blnWaitForLoad = true;
        }
    }

    if (!blnWaitForLoad) {

        var intTop = GetButtonTop(cmdPickRoute); 															//13Apr04 AE  Deleted if which did not show menu if a route was already selected.  Don't know why that was there.
        var intLeft = GetButtonRight(cmdPickRoute);

        //Create a new pick list object
        var objPick = new ICWPickList('Route for Administration', cmdPickRoute, NBEnterRoute);

        //Populate it using the text XML
        var objRoutes = routesData.XMLDocument.selectSingleNode("Routes")

        if (objRoutes != undefined) {
            void objPick.PopulateFromXMLNode(objRoutes, 'ProductRoute');
        }

        //Add a "show all routes" node if we're only showing the approved ones
        if ((blnShowAllRoutes != true) && !blnAllRoutesLoaded) {
            void objPick.AddRow(ID_SHOWALL, true, 0, 'ProductRoute', '[All Routes...]');
        }
        //And display it																								//13Apr04 AE  Moved out of IF...we always want to show it
        void objPick.Show(intLeft, intTop, 300, 400);
    }
}

//===========================================================================

function NBEnterRoute(routeID, routeDescription) {
    //Enter the selected route into the text box	

    if (routeID == ID_SHOWALL) {
        //Redisplay the popup, containing all routes
        void NBSelectRoute(true);
    }
    else {
        //Check if this is an approved route
        var objRoute = routesData.XMLDocument.selectSingleNode('Routes//ProductRoute[@ProductRouteID="' + routeID + '"]');
        if (objRoute == null) {
            //txtRoute.dbid = routeID;
            NBSelectRoute(true);
            return;
        }
        blnApproved = false;

        if (objRoute != undefined) {
            blnApproved = (objRoute.getAttribute('Approved') == '1');
        }

        if (!blnApproved) {
            imgRouteWarning.src = '../../../images/ocs/exclamation.gif';
        }
        else {
            imgRouteWarning.src = '../../../images/ocs/classSetEmpty.gif';
        }

        //TODO
        //txtRoute.value = trim(routeDescription);
        //txtRoute.setAttribute('dbid', routeID);
        //lngProductID = Number(instanceData.selectSingleNode('//attribute[@name="ProductID"]/@value').value);
        SetListItemByDBID(lstProductRoute, routeID);
    }
}

//===========================================================================

function NBCheckRoutesLoaded() {
    //Fires as the routes data island is loading.  When it's loaded,
    //we display the routes list

    if (routesData.readyState == 'complete') {
        if (routesData.getAttribute('loading') == '1') {
            formBody.style.cursor = 'default';
            void routesData.setAttribute('allloaded', '1');
            void routesData.setAttribute('loading', '0');
            //void NBSelectRoute(true);
        }
    }
}


//===========================================================================

function lstTitrateAction_onchange(objSelect) {
    FillWeeklyBoxes();
    //Rams 2
    //SetFormState();
    if (objSelect.options[objSelect.selectedIndex].getAttribute("id") == "lstTitration2") //Stop
    {
        //Hide Maintained Pickups Grid
        document.getElementById("divMaintain").style.display = 'none';
        document.getElementById("lblMaintain").style.display = 'none';
    }
    else {   //Unhide Maintained Pickups Grid
        document.getElementById("divMaintain").style.display = 'block';
        document.getElementById("lblMaintain").style.display = 'block';
    }
}

//===========================================================================

//function lstIncreaseAction_onchange(objSelect)
//{
//	FillWeeklyBoxes();
//	SetFormState();
//}

//===========================================================================

function UnitsDataLoaded() {
    var objOption;
    var xmlnode;

    if (unitsData.readyState == 'complete') {
        formBody.style.cursor = 'default';
        void unitsData.setAttribute('allloaded', '1');
        void unitsData.setAttribute('loading', '0');

        lstUnits.innerHTML = "";

        var xmlnodelist = unitsData.selectNodes("//unit")
        for (var lngIndex = 0; lngIndex < xmlnodelist.length; lngIndex++) {
            xmlnode = xmlnodelist(lngIndex);
            objOption = document.createElement("option");
            lstUnits.appendChild(objOption);
            objOption.setAttribute("dbid", xmlnode.getAttribute("id"));
            objOption.setAttribute("formid", xmlnode.getAttribute("formid"));
            objOption.setAttribute("type", xmlnode.getAttribute("type")); 						//25Apr04 AE  Added missing attribute type
            objOption.innerText = xmlnode.getAttribute("description");
        }

        //Set the item in the list to that stored in glngUnitID										//25Apr04 AE  Handle async units loading - was not functional when viewing existing data
        if (glngUnitID > 0) {																					//					Dodgy try catch is to avoid an occaisional horrible timing error.
            try {
                SetListItemByDBID(lstUnits, glngUnitID);
                glngUnitID = 0;
            }
            catch (e) { };
        }
    }
}


//===========================================================================

function MaxDayBoxCount() {
    // 04Jan07 PH Returns the number of days boxes that should be displayed.

    /* 
    For Standard dosing, it is the smallest of the following calculations:
    1) If an end date specified, then number of days (inclusive) between start and end date
    2) Profile length
			
    For Variable dosing, it is the smallest of the following calculations:
    1) If an end date specified, then number of days (inclusive) between start and end date
    2) Number of days taken to reach terminal dose
    3) 99 Days
		
	This function follows all the above rules, except the "days taken to reach terminal dose", which
    is calculated as part of the FillWeeklyBoxes function.
    */

    // 99 is the maximum possible number of dose days (since we have just 99 fields in the table!)
    var intMaxDays = 99;

    // Now see if a "HUMAN ENTERED" end date reduces the number of dose days any further.
    if (chkEndDate.checked && !chkEndDate.disabled) {
        var dateStart = ddmmccyy2Date(txtStartDate.value);
        var dateEnd = ddmmccyy2Date(txtEndDate.value);

        var intDayRange = VBDateDiff("d", Date2ISODate(dateStart), Date2ISODate(dateEnd), 0, 0) + 1;
        if (intDayRange < intMaxDays) {
            intMaxDays = intDayRange;
        }
    }
    var oProfileLength = document.getElementById("lstProfileLength");
    var intProfileLength = Number(oProfileLength.options[oProfileLength.selectedIndex].getAttribute("dbid")) * 7;
    if (GetRegimeName() != "standard") {
        var StartDate = ddmmccyy2Date(txtStartDate.value);
        var StartDose = Number(txtDoseQty.value);
        var DoseChange = Number(txtTitrateBy.value);
        var DoseChangeInterval = Number(txtTitrateInterval.value);
        var StopDose = Number(txtTitrateThreshold.value);
        if (GetRegimeName() == 'reducing') {
            DoseChange *= -1;
        }
        var EndDate = CalculateStopDate(StartDate, StartDose, DoseChange, DoseChangeInterval, StopDose);
        var Profilelength = DateDiff(StartDate, EndDate, 'd');
        if (document.getElementById("lstTitrateAction").children[document.getElementById("lstTitrateAction").selectedIndex].innerText == "Stop") {
            intProfileLength = Profilelength + 1;
        }
        else {
            Profilelength += 7 - (Profilelength % 7);
            intProfileLength = Profilelength;
        }
    }

    if (intMaxDays != 99) {
        return intMaxDays;
    }
    else {
        return intProfileLength;
    }
}

function FillWeeklyBoxes() {

    //11Jul11   Rams    TFS 7778/SW 103285 Titrating medication discrepancy - cannot view over 15 weeks
    var intDayCounter;
    var fltDoseChangeAmount;
    var intDoseChangeInterval;
    var fltDoseChangeThreshold;
    var fltDose;
    var fltLastValue;
    var dateThis;
    var intVisibleDays = -1;
    var blnStop = false;
    var bMaintain = false;
    var intMaintainWeekNo = -1;
    var intDayNo;

    fltDose = Number(txtDoseQty.value);
    fltLastValue = Number(txtDoseQty.getAttribute("LastValue"));
    //
    txtDoseQty.setAttribute("LastValue", txtDoseQty.value);

    dateThis = ddmmccyy2Date(txtStartDate.value);
    //

    var intMaxDayCount = MaxDayBoxCount();

    divTitrate.innerHTML = "";

    //Create text boxes now
    var lastWeek = -1;
    for (intDayCounter = 0; intDayCounter < intMaxDayCount; intDayCounter++) {
        var spanday = document.createElement("span");
        var week = Math.floor(intDayCounter / 7);

        if (lastWeek != week) {
            //Create Week labels
            lastWeek = week;
            if (lastWeek < 2) {
                document.getElementById("spnMnWeekName" + week).style.display = "none";
            }
            //
            var spanwk = document.createElement("span");
            spanwk.id = "spnWeekName" + week;
            spanwk.className = "ControlSpan";
            spanwk.style.top = 5 + 26 * week;
            spanwk.style.left = 5;
            spanwk.style.width = 60;
            spanwk.style.height = 40;

            spanwk.innerHTML = "Week " + (Number(week) + 1).toString();

            divTitrate.appendChild(spanwk);
        }

        //Create day boxes
        spanday.id = "spnDay" + Number(intDayCounter).toString();
        spanday.className = "ControlSpan";
        spanday.style.top = 5 + 26 * (week);
        spanday.style.left = 75 + (intDayCounter % 7) * 50;
        spanday.style.width = 40;
        spanday.style.height = 40;

        var txt = document.createElement("input");
        txt.type = "text";
        txt.id = "txtDay" + Number(intDayCounter).toString();
        txt.setAttribute("DayNo", intDayCounter);
        txt.setAttribute("validchars", "NUMBERS");
        txt.setAttribute("onKeyPress", "MaskInput(this);");
        txt.setAttribute("onfocus", "this.lastvalue=value;");
        txt.setAttribute("onPaste", "MaskInput(this);");
        txt.name = intDayCounter % 6;
        txt.maxlength = 10;
        txt.style.width = "40px";
        txt.className = "StandardField";
        txt.size = "3";
        txt.onchange = "txtDoseDays_change(this);";
        txt.lastvalue = "";

        spanday.appendChild(txt);

        divTitrate.appendChild(spanday);
    }
    //4 Weeks selected
    if (lstProfileLength.disabled == false && Number(lstProfileLength.options[lstProfileLength.selectedIndex].getAttribute("dbid")) == 4) {
        for (var DayCount = 0; DayCount < (4 * 7); DayCount++) {
            if (DayCount == 0) {
                txtDay0.value = fltDose * 28;
            }
            else {//Set all other to Zero
                document.getElementById("txtDay" + DayCount.toString()).value = 0;
            }
        }
        CalculateTotals(28);    // calculate total for 4 weeks
        return;
    }


    if (GetRegimeName() == "reducing") {
        // Reducing
        fltDoseChangeAmount = -Number(txtTitrateBy.value);
        intDoseChangeInterval = Number(txtTitrateInterval.value);
        fltDoseChangeThreshold = Number(txtTitrateThreshold.value);

        blnStop = (document.getElementById("lstTitrateAction").children[document.getElementById("lstTitrateAction").selectedIndex].innerText == "Stop");
    }
    else if (GetRegimeName() == "increasing") {
        // Increasing
        fltDoseChangeAmount = Number(txtTitrateBy.value);
        intDoseChangeInterval = Number(txtTitrateInterval.value);
        fltDoseChangeThreshold = Number(txtTitrateThreshold.value);

        blnStop = (document.getElementById("lstTitrateAction").children[document.getElementById("lstTitrateAction").selectedIndex].innerText == "Stop");
    }
    else {
        fltDoseChangeAmount = 0;
        intDoseChangeInterval = 1;
        fltDoseChangeThreshold = fltDose;
    }

    // Set day dose values
    for (intDayCounter = 0; intDayCounter < intMaxDayCount; intDayCounter++) {
        if (GetRegimeName() == "standard") {
            document.getElementById("txtDay" + intDayCounter).disabled = false;
        }
        else {
            document.getElementById("txtDay" + intDayCounter).disabled = true;
        }
        intWeekNo = Math.floor(intDayCounter / 7);
        intDayNo = intDayCounter % 7;
        var fltThisDose = fltDose + (fltDoseChangeAmount * (intDoseChangeInterval == 0 ? 0 : Math.floor(intDayCounter / intDoseChangeInterval)));
        if ((fltDoseChangeAmount > 0 && fltThisDose > fltDoseChangeThreshold) || (fltDoseChangeAmount < 0 && fltThisDose < fltDoseChangeThreshold)) {
            fltThisDose = fltDoseChangeThreshold;
        }
        document.getElementById("txtDay" + intDayCounter.toString()).value = Number(fltThisDose);

        if (fltDoseChangeAmount != 0 && fltThisDose == fltDoseChangeThreshold && intDayNo == 6) {
            intDayCounter++;
            break;
        }
    }
    
    if (fltDoseChangeAmount != 0 && !blnStop && fltDoseChangeThreshold > 0) {
        FillMaintainBoxes(intWeekNo, fltDoseChangeThreshold);
    }
    intVisibleDays = intDayCounter;
    //
    var ForceUncheckPickUp = -1;
    var fltAddonValue = 0;
    var fltAddonMnValue = 0;
    // Move doses on unchecked days, to checked days.
    for (intDayCounter = intMaxDayCount - 1; intDayCounter >= 0; intDayCounter--) {
        var intDayPosition = intDayCounter % 7;
        //
        if (intDayPosition > 0) {
            if (document.getElementById("chkTakeOn" + intDayPosition).checked && !document.getElementById("chkPickUp" + intDayPosition).checked) {//Take on and No PickUp
                if (document.getElementById("chkTakeOn" + (intDayPosition - 1)).checked) {
                    document.getElementById("txtDay" + (intDayCounter - 1).toString()).value = Number(document.getElementById("txtDay" + (intDayCounter - 1).toString()).value) + Number(document.getElementById("txtDay" + intDayCounter.toString()).value);
                    if (intDayCounter < 14) {
                        document.getElementById("txtMnDay" + (intDayCounter - 1).toString()).value = Number(document.getElementById("txtMnDay" + (intDayCounter - 1).toString()).value) + Number(document.getElementById("txtMnDay" + intDayCounter.toString()).value);
                    }
                }
                else {
                    fltAddonValue = Number(fltAddonValue) + Number(document.getElementById("txtDay" + intDayCounter.toString()).value);
                    if (intDayCounter < 14) {
                        fltAddonMnValue = Number(fltAddonMnValue) + Number(document.getElementById("txtMnDay" + intDayCounter.toString()).value);
                    }
                }
                document.getElementById("txtDay" + intDayCounter.toString()).value = 0;
                if (intDayCounter < 14) {
                    document.getElementById("txtMnDay" + intDayCounter.toString()).value = 0;
                }
            }
            else if (!document.getElementById("chkTakeOn" + intDayPosition).checked && document.getElementById("chkPickUp" + intDayPosition).checked) {//No Take on and only PickUp
                document.getElementById("txtDay" + (intDayCounter).toString()).value = (fltAddonValue > 0 ? fltAddonValue : Number(document.getElementById("txtDay" + (intDayCounter + 1).toString()).value));
                if (intDayCounter < 14) {
                    document.getElementById("txtMnDay" + (intDayCounter).toString()).value = (fltAddonMnValue > 0 ? fltAddonMnValue : Number(document.getElementById("txtMnDay" + (intDayCounter + 1).toString()).value));
                }
                //
                document.getElementById("txtDay" + (intDayCounter + 1).toString()).value = 0;
                if (intDayCounter < 14) {
                    document.getElementById("txtMnDay" + (intDayCounter + 1).toString()).value = 0;
                }
                ForceUncheckPickUp = intDayPosition + 1; //intDayCounter+1;
                fltAddonMnValue = 0;
                fltAddonValue = 0;
            }
            else if (!document.getElementById("chkTakeOn" + intDayPosition).checked && !document.getElementById("chkPickUp" + intDayPosition).checked) {//No PickUp and No Take on 
                if (document.getElementById("chkTakeOn" + Number(intDayPosition - 1)).checked) {
                    document.getElementById("txtDay" + (intDayCounter - 1).toString()).value = Number(document.getElementById("txtDay" + (intDayCounter - 1).toString()).value) + fltAddonValue;
                    if (intDayCounter < 14) {
                        document.getElementById("txtMnDay" + (intDayCounter - 1).toString()).value = Number(document.getElementById("txtMnDay" + (intDayCounter - 1).toString()).value) + fltAddonMnValue;
                    }
                    fltAddonMnValue = 0;
                    fltAddonValue = 0;
                }
                document.getElementById("txtDay" + intDayCounter).value = 0;
                if (intDayCounter < 14) {
                    document.getElementById("txtMnDay" + intDayCounter).value = 0;
                }
            }
        }
        else {   //When intDayPosition = 0, then do the same processing No Take on and Only Pick Up
            if (!document.getElementById("chkTakeOn" + intDayPosition).checked) {
                document.getElementById("txtDay" + (intDayCounter).toString()).value = (fltAddonValue > 0 ? fltAddonValue : Number(document.getElementById("txtDay" + (intDayCounter + 1).toString()).value));
                if (intDayCounter < 14) {
                    document.getElementById("txtMnDay" + (intDayCounter).toString()).value = (fltAddonMnValue > 0 ? fltAddonMnValue : Number(document.getElementById("txtMnDay" + (intDayCounter + 1).toString()).value));
                }
                //
                document.getElementById("txtDay" + (intDayCounter + 1).toString()).value = 0;
                if (intDayCounter < 14) {
                    document.getElementById("txtMnDay" + (intDayCounter + 1).toString()).value = 0;
                }
                ForceUncheckPickUp = (intDayPosition) + 1;
                fltAddonMnValue = 0;
                fltAddonValue = 0;
            }
        }
    }
    //
    if (ForceUncheckPickUp != -1)
        document.getElementById("chkPickUp" + ForceUncheckPickUp).checked = false;
    //
    CalculateTotals(intVisibleDays);
}

function CalculateTotals(intVisibleDays) {
    var fltTotalDose;
    var intTotalInstallments;

    // Calculate totals	
    fltTotalDose = 0;
    intTotalInstallments = 0;
    for (var intDayCounter = 0; intDayCounter < intVisibleDays; intDayCounter++) {
        var fltDose = Number(document.getElementById('txtDay' + intDayCounter.toString()).value);
        if (Number(fltDose) > 0) {
            fltTotalDose += fltDose;
            intTotalInstallments++;
        }
    }
    txtInstallments.value = intTotalInstallments.toString();
    txtTotal.value = fltTotalDose.toString();

    // Set EndDate for stopping increasing/reducing doses
    if ((GetRegimeName() == "increasing" || GetRegimeName() == "reducing") && document.getElementById("lstTitrateAction").children[document.getElementById("lstTitrateAction").selectedIndex].innerText == "Stop") {
        var dateThis = ddmmccyy2Date(txtStartDate.value);
        var dateEndDate = dateThis;
        var StopDose = Number(txtTitrateThreshold.value);
        var LastDose = 0;
        for (intDayCounter = 1; intDayCounter < intVisibleDays; intDayCounter++) {
            dateThis = new Date(dateThis.getFullYear(), dateThis.getMonth(), dateThis.getDate() + 1);
            if (document.getElementById("txtDay" + intDayCounter.toString()).style.display == "") {
                dateEndDate = dateThis;
                LastDose = Number(document.getElementById("txtDay" + intDayCounter.toString()).value);
            }
        }

        if (LastDose != StopDose && !chkEndDate.checked) {
            var StartDate = ddmmccyy2Date(txtStartDate.value);
            var StartDose = Number(txtDoseQty.value);
            var DoseChange = Number(txtTitrateBy.value);
            var DoseChangeInterval = Number(txtTitrateInterval.value);
            if (GetRegimeName() == 'reducing') {
                DoseChange *= -1;
            }
            dateEndDate = CalculateStopDate(StartDate, StartDose, DoseChange, DoseChangeInterval, StopDose)
        }

        txtEndDate.value = Date2ddmmccyy(dateEndDate);
    }
}

function CalculateStopDate(StartDate, StartDose, DoseChange, DoseChangeInterval, StopDose) {
    var StopDate = new Date(StartDate.toUTCString());
    var EndDay;
    if ((StartDose > StopDose && DoseChange > 0) || (StartDose < StopDose && DoseChange < 0)) {
        EndDay = DoseChangeInterval;
    }
    else {
        EndDay = (DoseChange == 0 || DoseChangeInterval == 0 ? 98 : Math.abs(Math.ceil((StartDose - StopDose) / DoseChange)) * DoseChangeInterval);
    }
    StopDate.setDate(StopDate.getDate() + EndDay);
    return StopDate;
}

function GetRegimeName() {
    var objSel = document.getElementById("lstTitration");
    var optSel = objSel.options[objSel.selectedIndex].innerText;
    return optSel.toLowerCase();
}

function SetRegimeName(RegimeName) {
    var objSel = document.getElementById("lstTitration");
    var idx = 0;

    for (idx = 0; idx < objSel.options.length; idx++) {
        if (objSel.options[idx].innerText.toLowerCase() == RegimeName)
            objSel.options[idx].selected = true;
    }
}

function SetFormState() {
    var blnDisplay = document.body.getAttribute("displaymode");

    if (GetRegimeName() == "standard") {
        document.getElementById("txtTitrateBy").disabled = true;
        document.getElementById("txtTitrateBy").className = "DisabledField";
        document.getElementById("txtTitrateBy").value = "";

        document.getElementById("txtTitrateInterval").disabled = true;
        document.getElementById("txtTitrateInterval").className = "DisabledField";
        document.getElementById("txtTitrateInterval").value = "";

        document.getElementById("txtTitrateThreshold").disabled = true;
        document.getElementById("txtTitrateThreshold").className = "DisabledField";
        document.getElementById("txtTitrateThreshold").value = "";

        document.getElementById("lstTitrateAction").disabled = true;
        document.getElementById("lstTitrateAction").className = "DisabledField";
        document.getElementById("lstTitrateAction").selectedIndex = 0;

        document.getElementById("spnTitrateBy").style.display = "none";
        document.getElementById("spnTitrateInterval").style.display = "none";
        document.getElementById("spnTitrateThreshold").style.display = "none";
        document.getElementById("spnTitrateAction").style.display = "none";
        document.getElementById("lblTitrate").innerHTML = "";
        //
        document.getElementById("lblDose").innerHTML = "Daily Dose";
        document.getElementById("divMaintain").style.display = 'none';
        document.getElementById("lblMaintain").style.display = 'none';
        document.getElementById("lblTitratePickUp").innerHTML = "Maintained Pickups";
        DisableTakeOnCheckBoxes(false);
    }
    else {
        document.getElementById("txtTitrateBy").disabled = false;
        document.getElementById("txtTitrateBy").className = "MandatoryField";
        document.getElementById("txtTitrateBy").value = document.getElementById("txtTitrateBy").value;

        document.getElementById("txtTitrateInterval").disabled = false;
        document.getElementById("txtTitrateInterval").className = "MandatoryField";
        document.getElementById("txtTitrateInterval").value = document.getElementById("txtTitrateInterval").value;

        document.getElementById("txtTitrateThreshold").disabled = false;
        document.getElementById("txtTitrateThreshold").className = "MandatoryField";
        document.getElementById("txtTitrateThreshold").value = document.getElementById("txtTitrateThreshold").value;

        document.getElementById("lstTitrateAction").disabled = false;
        document.getElementById("lstTitrateAction").className = "MandatoryField";
        document.getElementById("lstTitrateAction").selectedIndex = document.getElementById("lstTitrateAction").selectedIndex;

        document.getElementById("spnTitrateBy").style.display = "";
        document.getElementById("spnTitrateInterval").style.display = "";
        document.getElementById("spnTitrateThreshold").style.display = "";
        document.getElementById("spnTitrateAction").style.display = "";
        //
        document.getElementById("lblDose").innerHTML = "Starting Dose";
        document.getElementById("divMaintain").style.display = 'block';
        document.getElementById("lblMaintain").style.display = 'block';
        DisableTakeOnCheckBoxes(true);
        //
        if (GetRegimeName() == "reducing") {
            document.getElementById("lblTitrate").innerHTML = "Reduce By";
            document.getElementById("lblTitratePickUp").innerHTML = "Reducing Pickups";
        }
        else {
            document.getElementById("lblTitrate").innerHTML = "Increase By";
            document.getElementById("lblTitratePickUp").innerHTML = "Increasing Pickups";
        }
        //
    }


    if (blnDisplay == "False") {
//        chkEndDate.disabled = (GetRegimeName() == "increasing" && document.getElementById("lstTitrateAction").children[document.getElementById("lstTitrateAction").selectedIndex].innerText == "Stop")
//					  || (GetRegimeName() == "reducing" && document.getElementById("lstTitrateAction").children[document.getElementById("lstTitrateAction").selectedIndex].innerText == "Stop");

        chkEndDate.disabled = (GetRegimeName() == "increasing" || GetRegimeName() == "reducing");
    }
    else {
        txtTitrateInterval.disabled = true;
        txtTitrateBy.disabled = true;
        txtTitrateThreshold.disabled = true;
        lstTitrateAction.disabled = true;
        chkEndDate.disabled = true;
    }

    txtEndDate.disabled = !chkEndDate.checked || chkEndDate.disabled;
    txtEndDate.className = (txtEndDate.disabled ? "DisabledField" : "StandardField");
    if (chkEndDate.disabled) {
        imgEndDate.style.visibility = 'hidden';
    }
    else {
        imgEndDate.style.visibility = '';
    }
    //	imgEndDate.style.display = (chkEndDate.checked ? "" : "none" );
}

function BlankRoute() {
    document.getElementById("lstProductRoute").selectedIndex = 0;
    //txtRoute.value = "";
}

function txtStartDate_LostFocus(txtDate) {
    var dateThis = ddmmccyy2Date(txtDate.value);
    if (txtDate.value != "" && DateStringValid(txtDate.value) && !isNaN(dateThis)) {
        txtDate.setAttribute("LastValue", Date2ddmmccyy(dateThis));
        txtDate.value = Date2ddmmccyy(dateThis);
    }
    else {
        txtDate.value = txtDate.getAttribute("LastValue");
    }

    // clear checks
    ClearChecks();
    FillChecks();
    FillWeeklyBoxes();
    RenderDayNames(txtDate);
    //Rams 2
    //SetFormState();
}

function RenderDayNames(txtDate) {
    var arrDayNames = new Array("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat");
    var dateThis = ddmmccyy2Date(txtDate.value);

    for (var intDayNo = 0; intDayNo < 7; intDayNo++) {
        document.getElementById("DayName" + intDayNo).innerText = arrDayNames[dateThis.getDay()];
        document.getElementById("TakeOnDayName" + intDayNo).innerText = arrDayNames[dateThis.getDay()];
        dateThis = new Date(dateThis.getFullYear(), dateThis.getMonth(), dateThis.getDate() + 1);
    }
}

function chkEndDate_onclick(chkStop) {
    if (!chkStop.checked) {
        txtEndDate.value = "";
        txtEndDate.setAttribute("LastValue", "");
    }
    else {
        txtEndDate.value = txtStartDate.value;
        txtEndDate.setAttribute("LastValue", txtStartDate.value);
    }
    document.getElementById("lstProfileLength").disabled = chkStop.checked;
    txtEndDate.disabled = !chkStop.checked;
    txtEndDate.className = (txtEndDate.disabled ? "DisabledField" : "StandardField");

    //	// clear checks
    ClearChecks();
    //    //
    FillChecks();
    //
    FillWeeklyBoxes();
    //SetFormState();
}

function chkPickUp_onclick(chkPickUp) {
    //26Oct09   Rams    F0066956 & F0067016 - Rewritten 
    //Do calculations based on the Takeon days 
    var intDayPosition = 0;
    var intDayNo = Number(chkPickUp.getAttribute("name"));

    //26Nov10   Rams    F0084640 - Commented the following pickup event moves
    /*

	if (!document.getElementById("chkPickUp" + intDayNo).checked)
    {
    for (intDayPosition = intDayNo + 1; intDayPosition < 7; intDayPosition++)
    {
    if (document.getElementById("chkTakeOn" + intDayPosition).checked && !document.getElementById("chkPickUp" + intDayPosition).checked)// && intDayPosition==6)
    {
    document.getElementById("chkPickUp" + intDayPosition).checked = true;
    break;
    }
    else if (document.getElementById("chkTakeOn" + intDayPosition).checked)
    {
    //If found a takeOn then Exit
    break;
    }
    }
    }
    else   //true
    {
    if (!document.getElementById("chkTakeOn" + intDayNo).checked)
    {
    for (intDayPosition = intDayNo + 1; intDayPosition < 7; intDayPosition++)
    {
    if (document.getElementById("chkPickUp" + intDayPosition).checked)
    {
    document.getElementById("chkPickUp" + intDayPosition).checked = false;
    break;
    }
    else if (document.getElementById("chkTakeOn" + intDayPosition).checked)
    {
    //If found a next available takeOn then Exit
    break;
    }
    }
    }
    //
    for (intDayPosition = intDayNo - 1; intDayPosition > 0; intDayPosition--)
    {
    if (document.getElementById("chkPickUp" + intDayPosition).checked && !document.getElementById("chkTakeOn" + intDayPosition).checked)
    {
    //If Pickup with out Takeon then disable PickUp
    document.getElementById("chkPickUp" + intDayPosition).checked = false;
    break;
    }
    else if (document.getElementById("chkTakeOn" + intDayPosition).checked)
    {
    //If found a previous available takeOn then Exit
    break;
    }
    }
    }
    */

    FillWeeklyBoxes();
}

//Rams Currently not used.. but this is written for testing purpose
function chkPickUp_onclick_new(chkPickUp) {
    var intDayPosition = 0;
    var intDayNo = Number(chkPickUp.getAttribute("name"));
    var TakeOn = new Array("true", "true", "true", "true", "true", "true", "true");   //by default all the Takeons will be ticked
    var PickUp = new Array("true", "true", "true", "true", "true", "true", "true");  //By Default all the pcikups will be ticked

    //fill the Takeon Array and PickUp Array, before altering 
    for (intDayPosition = 0; intDayPosition < 7; intDayPosition++) {
        //
        TakeOn[intDayPosition] = (document.getElementById("chkTakeOn" + intDayPosition).checked ? "true" : "false");
        if (intDayPosition == 0) {
            PickUp[intDayPosition] = "true";
        }
        else {
            PickUp[intDayPosition] = (document.getElementById("chkPickUp" + intDayPosition).checked ? "true" : "false");
        }
    }
    //
    //now alter the Array according to the User
    if (PickUp[intDayNo] == "false") {
        for (intDayPosition = intDayNo + 1; intDayPosition < 7; intDayPosition++) {
            if (TakeOn[intDayPosition] == "true" && PickUp[intDayPosition] == "false")// && intDayPosition==6)
            {
                PickUp[intDayPosition] = "true";
                break;
            }
            else if (TakeOn[intDayPosition] == "true") {
                //If found a takeOn then Exit
                break;
            }
        }
    }
    else   //true
    {
        if (TakeOn[intDayNo] == "false") {
            for (intDayPosition = intDayNo + 1; intDayPosition < 7; intDayPosition++) {
                if (PickUp[intDayPosition] == "true") {
                    PickUp[intDayPosition] = "false";
                    break;
                }
                else if (TakeOn[intDayPosition] == "true") {
                    //If found a takeOn then Exit
                    break;
                }
            }
        }
        //
        for (intDayPosition = intDayNo - 1; intDayPosition > 0; intDayPosition--) {
            if (PickUp[intDayPosition] == "true" && TakeOn[intDayPosition] == "false") {
                //If Pickup with out Takeon then disable PickUp
                PickUp[intDayPosition] = "false";
                break;
            }
            else if (TakeOn[intDayPosition] == "true") {
                //If found a takeOn then Exit
                break;
            }
        }
    }

    //Now Alter the Physical control Array 
    for (intDayPosition = 0; intDayPosition < 7; intDayPosition++) {
        document.getElementById("chkTakeOn" + intDayPosition).checked = (TakeOn[intDayPosition] == "false" ? false : true);
        if (intDayPosition != 0)
            document.getElementById("chkPickUp" + intDayPosition).checked = (PickUp[intDayPosition] == "false" ? false : true);
    }
    //
    FillWeeklyBoxes();
}

function txtEndDate_LostFocus(txtDate) {
    var dateThis = ddmmccyy2Date(txtDate.value);
    if (txtDate.value != "" && DateStringValid(txtDate.value) && !isNaN(dateThis)) {
        txtDate.setAttribute("LastValue", Date2ddmmccyy(dateThis));
        txtDate.value = Date2ddmmccyy(dateThis);
    }
    else {
        txtDate.value = txtDate.getAttribute("LastValue");
    }

    // clear checks
    ClearChecks();
    //
    FillChecks();
    //
    FillWeeklyBoxes();
}

function ctlStartDate_onclick(txtStartDate) {
    txtStartDate.LastValue = txtStartDate.value;
    ShowMonthViewWithDate(txtStartDate, txtStartDate, txtStartDate.value);
    //FillWeeklyBoxes();
    //RenderDayNames(txtStartDate)
}

function ctlEndDate_onclick(txtEndDate) {
    //Rams 2
    //SetFormState();
    ShowMonthViewWithDate(txtEndDate, txtEndDate, txtEndDate.value);
}


//-------------------------------------------------------------------------------------
function MonthView_Selected(controlID) {
    //Callback when pop-up monthview has been used.
    //disble the profile length
    if (controlID == "txtEndDate") {
        document.getElementById("lstProfileLength").disabled = true;
        chkEndDate.checked = true;
        txtEndDate.disabled = false;
        txtEndDate.className = (txtEndDate.disabled ? "DisabledField" : "StandardField");
        if (ddmmccyy2Date(txtStartDate.value) > ddmmccyy2Date(txtEndDate.value)) {
            var strFeatures = 'dialogHeight:10px;'
					 + 'dialogWidth:350px;'
					 + 'resizable:no;'
					 + 'status:no;help:no;';
            //alert('Last Dose on cannot be before the Start date');
            MessageBox('Data Error', 'Last Dose On cannot be before the Prescription Start date', 'ok', strFeatures);
            txtEndDate.value = txtStartDate.value;
        }
    }
    // clear checks
    ClearChecks();
    FillChecks();
    FillWeeklyBoxes();
    RenderDayNames(txtStartDate);
}

function txtStartDate_onkeydown() {
    txtStartDate.LastValue = txtStartDate.value;
}

function ClearChecks() {
    //var intDay = 0;
    var dateThis = ddmmccyy2Date(txtStartDate.value);
    //var dateLast = ddmmccyy2Date(txtStartDate.LastValue)
    var dateLast = ddmmccyy2Date(txtEndDate.value);
    var intMaxDayCount = MaxDayBoxCount();
    //if( DateDiff( dateLast, dateThis, 'd', false ) != 0 )
    if (DateDiff(dateThis, dateLast, 'd', false) >= 0 && intMaxDayCount < 7) {
        for (intDayCount = intMaxDayCount; intDayCount < 7; intDayCount++) //Scan it just for the first week
        {
            if (intDayCount > 0) {
                document.getElementById("chkPickUp" + intDayCount).checked = false;
                document.getElementById("chkTakeOn" + intDayCount).checked = false;
                document.getElementById("chkPickUp" + intDayCount).disabled = true;
                document.getElementById("chkTakeOn" + intDayCount).disabled = true;
            }
        }
    }
}

function FillChecks() {
    var intDay = 0;
    var dateThis = ddmmccyy2Date(txtStartDate.value);
    //var dateLast = ddmmccyy2Date(txtStartDate.LastValue)
    var dateLast = ddmmccyy2Date(txtEndDate.value);
    var intMaxDayCount = MaxDayBoxCount();
    //if( DateDiff( dateLast, dateThis, 'd', false ) != 0 )
    if (DateDiff(dateThis, dateLast, 'd', false) != 0) {
        for (intDayCount = 0; intDayCount < intMaxDayCount; intDayCount++) {
            intDay = intDayCount % 7;
            if (intDay > 0) {
                document.getElementById("chkPickUp" + intDay).checked = true;
                document.getElementById("chkPickUp" + intDayCount).disabled = false;
            }
            document.getElementById("chkTakeOn" + intDay).checked = true;
            document.getElementById("chkTakeOn" + intDayCount).disabled = false;
            //
            if (intDay == 6)    //Exit loop after scanning for the first week.
                break;
        }
    }
}





//===========================================================================


// 16Nov05 PH NBPrescriptionRequest used to use the shared Prescription.js. 
//	However, Prescription.js has now changed so much that it is no longer compatible
//	So I have pasted the contents of the old 9.2.2 Prescription.js into here

//===========================================================================
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
//===========================================================================



var ID_SHOWALL = -5;

//Pop-up picker variables
//var m_objPop = new Object();											//Popup object used for pop-up lists etc
var m_objDateOutput = new Object(); 									//Object for storing the destination control when displaying the pop-up calendar
var m_blnTemplateMode = false; 										//Determines if we are in template mode or not
var m_blnShownDetails = false; 										//Used as a switch to indicate that we've shown the calculation automatically

var SCHEDULER_WIDTH = 750;
var SCHEDULER_HEIGHT = 450;

//Constants
var SELECTED_BACKGROUND_COLOUR = '#00599C';
var BACKGROUND_COLOUR = '#D6E3FF';

var FORMAT_DDMMYYYY = 'dd-mm-yyyy'; 									//Format used for saving dates

var ATTR_SHOWN = 'isshown'; 											//Used as a flag on the dose / time to... boxes to indicate if they are expanded or not


//Pseudo Frequency IDs.  We present these to the user
//as if they are frequency templates, although in fact
//they each work differently.
var FQID_ADVANCED = -100; 												//Indicates that an advanced (ad-hoc) schedule is being used, rather than a template									
var FQID_PRN = -200; 														//Indicates that the prescription is a true PRN (As Required), with no dosing times specified.
//The PRN box may be checked AND a frequency specified; this represents an IF required prescription.
//Both are considered to be PRN by medics, although the meaning is actually quite different.
var FQID_STAT = -300; 													//Indicates a STAT (one-off) dose

//Text for standard menu items; may be read from the 
//server in future, so constantised for easy modification.
var MNUTXT_ADVANCED = '[Advanced...]';
var MNUTXT_PRN = 'PRN - When Required';
var MNUTXT_STAT = 'STAT - Single Dose';
var MNUTXT_CONTINUOUS = 'Continuous Infusion';

//Title strings
var TITLE_RANGEHIDDEN = 'Click here to enter a range of doses (such as "1 to 2 tablets")';
var TITLE_RANGESHOWN = 'Click here to enter only a single dose (such as "10 mg")';

//===========================================================================
//								Form set-up
//===========================================================================

function InitForm() {
    //Ensure the proper bits are shown/hidden; called immediately
    //after the PopulateForm method
    //Dose2 - show if there is an entry in the dose2 box, otherwise hide it
    var blnShow = (txtDoseQty2.value != '');
    if (!IsVisible(spnDose2) && blnShow) {
        void ToggleDose2();
    }
}

//===========================================================================
//								Dose Calculations
//===========================================================================

function ShowCalculation(blnDoseWasCalculated) {
    //blnDoseWasCalculated:		True if a calculation has been made.
    var intCount = new Number();
    var astrDose = new Array();
    var astrItem = new Array();

    //Load the dose calculation dialog
    var strFeatures = 'dialogHeight:500px;'
					 + 'dialogWidth:700px;'
					 + 'resizable:yes;unadorned:no;'
					 + 'status:no;help:no;';
    //17-Jan-2008 Error code 162
    var strURL = '../../DSS/DoseCalculation.aspx'
		  + '?SessionID=' + formBody.getAttribute('sid')
		  + '&RoutineID=' + formBody.getAttribute('calculation_routineid')
		  + '&Value=' + formBody.getAttribute('calculation_dose')
		  + '&ValueLow=' + formBody.getAttribute('calculation_doselow')
		  + '&Unit=' + lstUnits.options[lstUnits.selectedIndex].innerText
		  + '&changed=0';

    //Show it
    var newDose = window.showModalDialog(strURL, '', strFeatures)
    if (newDose == 'logoutFromActivityTimeout') {
        newDose = null;
        window.close();
        window.parent.close();
        window.parent.ICWWindow().Exit();
    }

    if (newDose!=null && newDose != 'cancel') {
        //Update the prescription with the new dose
        //dose=xxx;[doselow=xxx]
        var astrDose = newDose.split(';');
        for (intCount = 0; intCount < astrDose.length; intCount++) {
            astrItem = astrDose[intCount].split('=');
            switch (astrItem[0]) {
                case 'dose':
                    if (astrDose.length > 1) {
                        txtDoseQty2.value = astrItem[1];
                    }
                    else {
                        txtDoseQty.value = astrItem[1];
                    }
                    break;

                case 'doselow':
                    txtDoseQty.value = astrItem[1];
                    break;
            }
        }

        lblCalcWarning.style.color = '#000000'
        lblCalcWarning.innerText = '(This is a calculated Dose)';
    }
}

//===========================================================================

function RoundDose(doseControl, strDirection) {
    //	Rounds the dose up or down to the next available size, 
    //	based on the product sizes we have in the db.
    //
    //	This assumes that the increments are returned in ASCENDING order
    //		doseControl:		control holding the dose value in its value field
    //		strDirection:		'up'|'down'

    var nextNode = new Object();
    var smallestNode = new Object();

    var smallestDose = new Number();
    var intDivisions = new Number();
    var blnFinished = false
    var intCount = new Number();

    //Get the dose currently in the text box.
    var enteredDose = eval(doseControl.value);
    if (enteredDose == undefined) { enteredDose = 0; }
    var thisDose = enteredDose;

    // 01Dec03 PH Extra IF added below to default incrementation/decrementation to 1
    if (lstUnits.selectedIndex >= 0) {
        var thisUnit = lstUnits.options[lstUnits.selectedIndex].innerText;

        //Get a reference to the Node in the XML document for this unit
        //var unitsNode = unitsData.XMLDocument.selectSingleNode('units/unit[@description="' + thisUnit + '"]');
        //
        //01Dec09   Rams    F0070698 - Script Error when clicking on the button next to Dose Field
        var unitsNode = unitsData.selectSingleNode('units/unit[@description="' + thisUnit + '"]');

        var colIncrements = unitsNode.selectNodes('increment')

        //And off we go...	
        //Divide by each increment, starting at the largest.
        for (intCount = 0; intCount < colIncrements.length; intCount++) {
            nextNode = colIncrements[intCount];
            thisIncrement = eval(nextNode.getAttribute('value'));
            //Can we divide by this increment?
            intDivisions = (eval(thisDose) / eval(thisIncrement));
            intDivisions = intDivisions.toString().split('.')[0]; 			//Does the same as vb's INT, only much less pleasant...
            if (intDivisions >= 1) {
                //yup, so do so and carry on
                thisDose = thisDose - (intDivisions * thisIncrement);
            }
            else {
                //We've finished; 
                break;
            }
        }

        //Now we have the remainder left over after we've divided the entered dose
        //by every possible dose size.
        //Move to the next dose step up or down
        smallestNode = colIncrements[0];
        smallestDose = eval(smallestNode.getAttribute('value'));

        if (strDirection == 'up') {
            //Moving up; add the difference from where we are to the next step up
            enteredDose += (eval(smallestDose) - eval(thisDose));
        }
        else {
            //Going down
            if (thisDose > 0) {
                enteredDose -= thisDose; 									//Move down to the next step
            }
            else {
                enteredDose -= smallestDose; 								//We are exactly at a step, move down another
            }
        }
    }
    else {
        if (strDirection == 'up') {
            enteredDose++;
        }
        else {
            enteredDose--;
        }
    }

    //Final bounds check
    if (enteredDose <= 0) {
        enteredDose = 0;
    }

    //Enter the new dose into the text box
    doseControl.value = enteredDose.toString();
}

//===========================================================================
//								Event Handlers
//===========================================================================

function ToggleDose2() {
    //Show/hide the second dose box
    var blnVisible = !(spnDose2.getAttribute(ATTR_SHOWN));
    spnDose2.style.visibility = GetVisibilityString(blnVisible);
    void spnDose2.setAttribute(ATTR_SHOWN, blnVisible);

    if (blnVisible) {
        spnDoseUnit.style.left = 315;
        spnDoseCalculationLbl.style.left = 455;
        spnDoseCalculation.style.left = 485;
        spnCalculationInfo.style.left = 370;
        spnEnableDose2.style.left = 370;

        cmdEnableDose2.innerText = 'Single Dose...';
        cmdEnableDose2.title = TITLE_RANGESHOWN;

    }
    else {

        spnDoseUnit.style.left = 180;
        spnDoseCalculationLbl.style.left = 290;
        spnDoseCalculation.style.left = 320;
        spnCalculationInfo.style.left = 235;
        spnEnableDose2.style.left = 235;

        cmdEnableDose2.innerText = 'Range...';
        cmdEnableDose2.title = TITLE_RANGEHIDDEN;
    }
}
//===========================================================================


function ChangeDuration(intAddition) {
    //Change the figure in the duration box by the value
    //in intAddition

    var thisValue = eval(txtDuration.value);
    if (isNaN(thisValue)) { thisValue = 0; }
    thisValue += intAddition;
    if (thisValue < 0) { thisValue = 0; }
    txtDuration.value = thisValue;

    void UpdateStopDate();
}

//===========================================================================

function SignalDateChange() {
    //Fires when the start date is changed; we must inform the container, orderentry,
    //of the change so that if we are in an order set, it can syncronise the
    //start dates of any items which follow on from this one.
    void window.parent.parent.ShuffleStartTimes(txtStartDate.value + ' 00:00'); 	//For prescriptions, we always start at midnight
}

//===========================================================================
//								Duration / stop date syncronisation
//===========================================================================

function UpdateStopDate() {
    //Update the stop date based on the value of the start date field
    //Needs some serious work to cope with various date formats etc.
    var intMultiply = new Number();

    if (!m_blnTemplateMode) {
        //This section needs attention as will not cope with all date formats
        var strStart = ParseDate(txtStartDate.value, 'dd/mm/yyyy');

        if (strStart != '') {
            var dtStart = StringToDate(strStart);

            //Determine the duration;
            var intDuration = eval(txtDuration.value);
            if (lstDurationUnits.selectedIndex > -1) {
                var strUnit = lstDurationUnits.options[lstDurationUnits.selectedIndex].getAttribute('abbreviation');

                //Convert from the given units into milliseconds.
                switch (strUnit.toLowerCase()) {
                    case 'sec':
                        intMultiply = 1000;
                        break;

                    case 'min':
                        intMultiply = 60000;
                        break;

                    case 'hr':
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

                //Now add the stop date to the duration	
                var intStopDateMS = Date.parse(dtStart) + intDuration;
                var dtStopDate = new Date(intStopDateMS);

                txtStopDate.value = FormatDate(dtStopDate, 'dd/mm/yyyy');
            }
        }
        else {
            txtStopDate.value = '';
        }
    }
}
//===========================================================================

function UpdateDuration() {
    //When the stop date is changed, update the duration controls.
    //This means blanking them at present.	

    if (window.event.keyCode > 47) {
        //Ignore control keys etc
        txtDuration.value = ''
        lstDurationUnits.selectedIndex = -1;
    }
}

//===========================================================================
//									Route selection 
//===========================================================================

function SelectRoute(blnShowAllRoutes) {
    //Launch the route picker so that the user can select a route
    //
    //			blnShowAllRoutes:			If true, then a list of all routes is loaded from
    //											the server, if required, and all are displayed 
    //											in the list.  Otherwise, only approved routes are shown.

    var blnWaitForLoad = false;

    //Check if we have, and/or need, all routes
    var blnAllRoutesLoaded = (routesData.getAttribute('allloaded') == '1');

    if (blnShowAllRoutes == true) {
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
            routesData.src = strURL;
            blnWaitForLoad = true;
        }
    }

    if (!blnWaitForLoad) {
        //var intTop = GetButtonTop(cmdPickRoute);
        //var intLeft = GetButtonRight(cmdPickRoute);
        var intTop = document.getElementById("cmdPickRoute").offsetTop;
        var intLeft = document.getElementById("cmdPickRoute").offsetWidth; document.getElementById("cmdPickRoute").offsetWidth;

        //Create a new pick list object
        var objPick = new ICWPickList('Route for Administration', cmdPickRoute, EnterRoute);

        //Populate it using the text XML
        var objRoutes = routesData.XMLDocument.selectSingleNode("Routes")
        void objPick.PopulateFromXMLNode(objRoutes, 'ProductRoute');

        //Add a "show all routes" node if we're only showing the approved ones
        if ((blnShowAllRoutes != true) && !blnAllRoutesLoaded) {
            void objPick.AddRow(ID_SHOWALL, true, 0, 'ProductRoute', '[All Routes...]');
        }

        //And display it
        void objPick.Show(intLeft, intTop, 300, 400);
    }
}


//===========================================================================

function EnterRoute(routeID, routeDescription) {
    //Enter the selected route into the text box	

    if (routeID == ID_SHOWALL) {
        //Redisplay the popup, containing all routes
        void SelectRoute(true);
    }
    else {
        //Enter the chosen route
        var objRoute = routesData.XMLDocument.selectSingleNode('Routes//ProductRoute[@ProductRouteID="' + routeID + '"]');

        var blnApproved = false;
        var blnInfusion = false;

        if (objRoute != undefined) {
            blnApproved = (objRoute.getAttribute('Approved') == '1');
            blnInfusion = (objRoute.getAttribute('Infusion') == '1');
        }

        //Check if this is an Infusion route; if so, show the Infusion form 
        //instead of the standard prescription form.											//17Dec03 AE 
        if (false) { // blnInfusion
            void ShowInfusionForm(routeID, routeDescription);
        }
        else {

            //Check if this is an approved route
            if (!blnApproved) {
                imgRouteWarning.src = '../../../images/ocs/exclamation.gif';
            }
            else {
                imgRouteWarning.src = '../../../images/ocs/classSetEmpty.gif';
            }

            //And enter it into the text box
            //TODO
            //txtRoute.value = trim(routeDescription);
            //void txtRoute.setAttribute('dbid', routeID);
        }
    }
}

//===========================================================================

function ShowInfusionForm(routeID, routeDescription) {
    //Display the infusion custom control rather than the standard prescription one

    var strURL = document.URL;
    var strQuerystring = strURL.substring(strURL.indexOf('?'), strURL.length);
    strURL = 'PrescriptionInfusion.aspx'
		 + strQuerystring
		 + '&ProductText=' + lblDrugName.innerText
		 + '&RouteID=' + routeID
		 + '&RouteText=' + routeDescription
		 + '&SelfInitialise=true';

    void window.navigate(strURL);
}

//===========================================================================

function CheckRoutesLoaded() {
    //Fires as the routes data island is loading.  When it's loaded,
    //we display the routes list

    if (routesData.readyState == 'complete') {
        if (routesData.getAttribute('loading') == '1') {
            formBody.style.cursor = 'default';
            void routesData.setAttribute('allloaded', '1');
            void routesData.setAttribute('loading', '0');
            void SelectRoute(true);
        }
    }
}

//===========================================================================
//								Frequency Selection
//===========================================================================

function SelectFrequency(objButton) {
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
        var intTop = GetButtonTop(objButton);
        var intLeft = GetButtonRight(objButton);

        //Create a new pick list object
        var objPick = new ICWPickList('Frequency', objButton, EnterFrequency);

        //Add standard items to the top of the list
        objPick.AddRow(FQID_ADVANCED, true, 0, '', MNUTXT_ADVANCED);
        objPick.AddRow(FQID_PRN, true, 0, '', MNUTXT_PRN);
        objPick.AddRow(FQID_STAT, true, 0, '', MNUTXT_STAT);

        //Populate it using the schedule XML
        var objFrequency = frequencyData.XMLDocument.selectSingleNode('root');
        void objPick.PopulateFromXMLNode(objFrequency, 'ScheduleTemplate');

        //And display it
        void objPick.Show(intLeft, intTop, 300, 400);
    }
}

//===========================================================================

function EditAdvancedFrequency() {
    //Event Handler called from the cmdPickFreqLong button.
    //Launches the advanced frequency editor, skipping the picklist.
    void EnterFrequency(FQID_ADVANCED, '');
}
//===========================================================================

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
}

//===========================================================================

function EnterFrequency(selectedID, selectedText) {
    //Enter the selected frequency.  This may be an actual schedule template, 
    //or one of the special items Advanced, PRN, or STAT.  Each of those
    //is specifically handled here.

    var frequencyID = selectedID;
    if (frequencyID < 0) { frequencyID = 0 };

    //Enter the give scheduletemplatefrequency into the box
    void txtFreq.setAttribute('dbid', frequencyID);

    //Check if we've chosen the "advanced" item:
    if (selectedID == FQID_ADVANCED) {
        //Show the advanced scheduler pop-up
        var objSchedule = advancedFrequencyData.XMLDocument.selectSingleNode('root/Schedule');
        var strFrequency_XML = advancedFrequencyData.XMLDocument.xml;

        var strURL = '../../Scheduler/SchedulerModal.aspx'
				  + '?SessionID=' + formBody.getAttribute('sid');
        var strFeatures = 'dialogHeight:' + SCHEDULER_HEIGHT + 'px;'
						 + 'dialogWidth:' + SCHEDULER_WIDTH + 'px;'
						 + 'resizable:no;unadorned:no;'
						 + 'status:no;help:no;';
        strFrequency_XML = window.showModalDialog(strURL, strFrequency_XML, strFeatures);
        if (strFrequency_XML == 'logoutFromActivityTimeout') {
            strFrequency_XML = null;
            window.close();
            window.parent.close();
            window.parent.ICWWindow().Exit();
        }

        if (strFrequency_XML) {
            switch (strFrequency_XML) {
                case 'cancel':
                    //Do nothing
                    break;

                case 'templates':
                    //Revert to the template pick list
                    if (spnFrequency.style.visibility == 'visible') {
                        void SelectFrequency(cmdPickFreq);
                    }
                    else {
                        void SelectFrequency(cmdPickFreqLong);
                    }
                    break;


                default:
                    //We have some schedule XML;
                    //Store the schedule in the advancedFrequencyData island, and copy the 
                    //description into the long frequency text box and display it in 
                    //place of the ordinary one.
                    void AdvancedScheduleToForm(strFrequency_XML);
                    break;
            }
        }
    }
    else {
        //Just enter the selected text into the box, revert it to normal size
        txtFreq.value = selectedText;
        void ShowLongFrequencyControls(false);

        //If they've chosen the PRN - As Required item, hide the PRN check box 
        //to avoid confusion.
        switch (eval(selectedID)) {
            case FQID_PRN:
                //If they've chosen PRN, hide the duration controls and 
                //PRN check box
                chkStat.checked = false;
                chkPRN.checked = true;
                void ShowStatControls(false);
                void ShowPRNControls(false);
                break;


            case FQID_STAT:
                //If they've chosen the STAT item, hide the duration controls and
                //stop date, and change the StartDate label. Also udpdate the hidden
                //stat checkbox.
                chkStat.checked = true;
                chkPRN.checked = false;
                void ShowPRNControls(false);
                void ShowStatControls(true);
                void SetStatControls(optImmediate.checked);
                break;


            default:
                chkStat.checked = false;
                void ShowStatControls(false);
                void ShowPRNControls(true);
                break;
        }
        void ResizeOrderForm(document, false);
    }
}
//===========================================================================


function AdvancedScheduleToForm(strFrequency_XML) {
    //Enter the schedule specified in strFrequency_XML onto the form as
    //an advanced/ad-hoc schedule.
    advancedFrequencyData.loadXML(strFrequency_XML);
    objSchedule = advancedFrequencyData.XMLDocument.selectSingleNode('root/Schedule');
    txtFreq.innerText = '[Advanced]'; 																		//This should never be seen, it's a "just in case"
    void txtFreq.setAttribute('dbid', 0);
    txtFreqLong.setAttribute('title', objSchedule.getAttribute('Description')); 				//This is the long text box used for display
    txtFreqLong.value = objSchedule.getAttribute('Description')

    //Ensure that we syncronise the start and stop date fields; although now
    //hidden, we will still be saving them.
    txtStartDate.value = ParseDate(objSchedule.getAttribute('StartDate'), 'dd/mm/yyyy');
    txtStopDate.value = ParseDate(objSchedule.getAttribute('EndDate'), 'dd/mm/yyyy');
    void ShowLongFrequencyControls(true);
    void ResizeOrderForm(document, false);
}

//===========================================================================
//								Stat / PRN / Avanced Frequency Controls
//===========================================================================

function ShowLongFrequencyControls(blnVisible) {
    //Re-arranges the form when an advanced shchedule has been chosen.
    //Because the description of these tends to be long, we hide the ordinary
    //frequency box and replace it with a larger multiline box.
    //Duration, start and stop date controls are hidden
    spnDurationUnits.style.visibility = GetVisibilityString(!blnVisible);
    spnDuration.style.visibility = GetVisibilityString(!blnVisible);
    spnFrequency.style.visibility = GetVisibilityString(!blnVisible);
    spnFrequencyLabelLong.style.visibility = GetVisibilityString(blnVisible);
    spnFrequencyTextLong.style.visibility = GetVisibilityString(blnVisible);
    spnStartDate.style.visibility = GetVisibilityString(!blnVisible);
    spnStopDate.style.visibility = GetVisibilityString(!blnVisible);
}

//===========================================================================

function ShowStatControls(blnVisible) {
    //Re-arranges the form to display the STAT dosing options.
    //we hide the duration controls, and display the "immediate / give on the"
    //radio buttons and start time box.
    //If blnVisible is false, we do the reverse.

    spnDurationUnits.style.visibility = GetVisibilityString(!blnVisible);
    spnDuration.style.visibility = GetVisibilityString(!blnVisible);
    spnStopDate.style.visibility = GetVisibilityString(!blnVisible);
    spnImmediate.style.visibility = GetVisibilityString(blnVisible);
    spnScheduled.style.visibility = GetVisibilityString(blnVisible);
    spnStartTime.style.visibility = GetVisibilityString(blnVisible);

    if (document.all['spnPRN'] != undefined) {								//No PRN box on the infusion form
        spnPRN.style.visibility = GetVisibilityString(!blnVisible);
        chkPRN.style.visibility = GetVisibilityString(!blnVisible);
    }

    if (blnVisible) {
        lblStartDate.innerText = 'Give on the ';
        spnStartDate.style.left = 70;
        //spnStartDate.setAttribute('left', 40);
        if (txtStartTime.value == '') {
            //Set time to now
        }
    }
    else {
        lblStartDate.innerText = 'Start Date: ';
        spnStartDate.style.left = 20;
        //		spnStartDate.setAttribute('left', 20);
    }

    //Store the status of the stat controls 
    void spnImmediate.setAttribute(ATTR_SHOWN, blnVisible);
}

//===========================================================================

function ShowPRNControls(blnVisible) {
    //Re-arranges the form to display the PRN Dosing options.
    //The PRN box is shown or hidden according to the value of blnVisible
    if (document.all['chkPRN'] != undefined) {
        lblPRN.style.visibility = GetVisibilityString(blnVisible);
        chkPRN.style.visibility = GetVisibilityString(blnVisible);
    }
    spnStartDate.disabled = false;
}

//===========================================================================
function GetVisibilityString(blnVisible) {
    //In-line function used from ShowStatControls
    if (blnVisible) {
        return 'visible';
    }
    else {
        return 'hidden';
    }
}

//===========================================================================

function SetStatControls(blnImmediate) {
    //Called when the option buttons are clicked.  Enables/disables
    //the Start date/time boxes as appropriate.
    lblImmediate.disabled = !blnImmediate;
    spnStartDate.disabled = blnImmediate;
    spnStartTime.disabled = blnImmediate;
}

//===========================================================================
//								ArbText Selection
//===========================================================================

function SelectText() {
    //Select some text using the arbitrary text picker

    //Load the data if it isn't already loaded
    if (arbtextData.getAttribute('allloaded') != '1') {
        var strURL = 'PrescriptionLoader.aspx'
				  + '?SessionID=' + formBody.getAttribute('sid')
				  + '&Mode=arbtext';
        formBody.style.cursor = 'wait';
        void arbtextData.setAttribute('loading', '1');
        arbtextData.src = strURL

    }
    else {
        //We already have the data, just show it in the picker
        var intTop = GetButtonTop(cmdPickText);
        var intLeft = GetButtonRight(cmdPickText);

        //Create a new pick list object
        var objPick = new ICWPickList('Direction', cmdPickText, EnterText);

        //Populate it using the text XML
        var objText = arbtextData.XMLDocument.selectSingleNode('root');
        void objPick.PopulateFromXMLNode(objText, 'ArbText');

        //And display it
        //void objPick.Show(intLeft, intTop, 300, 400);
        objPick.Show(15, -intTop, 300, 400);

    }
}

//===========================================================================

function CheckArbTextLoaded() {
    //Fires off as the ArbText data island is loading asyncronously.
    //Show the arb text picker when it's all loaded

    if (arbtextData.readyState == 'complete') {
        if (arbtextData.getAttribute('loading') == '1') {
            formBody.style.cursor = 'default';
            void arbtextData.setAttribute('loading', '0');
            void arbtextData.setAttribute('allloaded', '1');
            void SelectText();
        }
    }
}

//===========================================================================

function EnterText(dummyID, newText) {
    //Appends the given text to the end of the box.	
    if (txtExtra.value != '') { txtExtra.value += ' '; }
    txtExtra.value += newText;
}

//===========================================================================
//								Alternative Prescriptions
//===========================================================================

function AddAlternativePrescription() {
    //Allows the user to add a prescription which can be specified as an alternative	
}


//===========================================================================
//								Internal Procedures
//===========================================================================
function PopulateForm(strData_XML, blnTemplateMode) {
    //Populate the form with the specified XML
    //
    //strData_XML:			Data in the standard order entry format of <data><attribute .../></data>
    //blnTemplateMode:	Set to true when creating a template, rather than an actual order.

    var objItem = new Object();
    var lngID = new Number();
    var strText = new String();
    var strPRN = new String();
    var strXML = new String();
    var doseLow = new Number(0);
    var doseHigh = new Number(0);

    //Store the template mode flag;
    m_blnTemplateMode = blnTemplateMode;

    //Now populate the entry controls
    //Parse using the instanceData island
    void instanceData.XMLDocument.loadXML(strData_XML);

    //Now populate the controls
    //Routes box
    lngID = GetValueFromXML('ProductRouteID');
    strText = GetTextFromXML('ProductRouteID');
    void EnterRoute(lngID, strText);

    //Dose Quantity/Units.  This may have been calculated server-side, 
    //in which case it will already contain a value
    if (formBody.getAttribute('iscalculateddose') != 'true') {
        doseHigh = GetValueFromXML('Dose');
        doseLow = GetValueFromXML('DoseLow');

        if (Number(doseLow) > 0) {																//09Jan04 AE  Added Dose ranges
            //We have a range of doses
            txtDoseQty.value = doseLow;
            txtDoseQty2.value = doseHigh;
            void ToggleDose2();
        }
        else {
            //Just a single dose
            txtDoseQty.value = doseHigh;
        }
    }
    else {
        //If a value has been calculated, store the original value in the body element
        formBody.setAttribute('calculation_dose', GetValueFromXML('Dose'));
        formBody.setAttribute('calculation_doselow', GetValueFromXML('DoseLow'));
    }

    lngID = GetValueFromXML('Calculation_RoutineID');
    void SetListItemByDBID(lstRoutine, lngID);

    //Dose Units.  May be units (mg, ml), Forms (tablet, capsule), or in future packaging (kit, pack)
    //In the case of form, we'll only ever have a single entry in the list however. (A product cannot
    //have multiple forms)
    lngID = GetValueFromXML('UnitID_Dose');
    if (lngID == null) { lngID = 0 };

    //	if (Number(lngID) == 0) {
    //		//No unit, look for a form:
    //		lngID = GetValueFromXML('ProductFormID_Dose');
    //	}
    void SetListItemByDBID(lstUnits, lngID);


    //Dates; stored as cannonical dd-mmm-yyyy format, we convert them here back into the
    //display format.  This should come from the validchars attribute of the date controls.
    //Start Date; if we don't have one, default to the current time											//!!** Integrate date formats here the validchars attribute
    if (!m_blnTemplateMode) {
        strText = GetValueFromXML('StartDate');
    }
    else {
        strText = '';
    }

    if (strText == '' && !m_blnTemplateMode) {
        //No date saved, use the current time UNLESS we are making a template;
        //in this case, start / stop date are irrelevant
        var dtStart = new Date(); 																					//The current time
        strText = FormatDate(dtStart, 'dd/mm/yyyy');
    }
    else {
        strText = ParseDate(strText, 'dd/mm/yyyy');
    }
    txtStartDate.value = strText;

    //Stop Date: If they've specified one, use it; otherwise, 
    //calculate it based on the start date and duration (if any)
    if (!m_blnTemplateMode) {
        strText = GetValueFromXML('StopDate');
        strText = ParseDate(strText, 'dd/mm/yyyy');
    }
    else {
        strText = '';
    }

    if (strText != '') {
        txtStopDate.value = strText;
    }
    else {
        //Create it from the stop date
        void UpdateStopDate();
    }

    //Duration																			//01Dec03 TH Moved here above the schedule train crash
    lngID = GetValueFromXML('Duration');
    txtDuration.value = lngID;

    //Duration units
    lngID = GetValueFromXML('UnitID_Duration');
    void SetListItemByDBID(lstDurationUnits, lngID);

    //Supplimentary text
    txtExtra.value = GetValueFromXML('SupplimentaryText'); 			//01Dec03 TH end block

    //PRN box
    strPRN = GetValueFromXML('PRN');
    chkPRN.checked = (strPRN == 'true');

    //Dose Frequency
    lngID = GetValueFromXML('ScheduleTemplateID');
    strText = GetTextFromXML('ScheduleTemplateID');
    //This may be 0; in that case it indicates either an Advanced schedule
    //has been created, or they've selected the PRN schedule, OR
    //none has genuinely been selected.

    if (chkPRN.checked && (Number(lngID) == 0)) {
        //Indicates an "as required" prescription with no schedule.
        void EnterFrequency(FQID_PRN, strText);
    }
    else {
        if (Number(lngID) != 0) {
            //This is a normal schedule template
            void EnterFrequency(lngID, strText);
        }
        else {
            //Whereas this is an ad-hoc schedule - 28Nov03 TH or maybe a STAT ?
            if (GetValueFromXML('STAT') == 'true')			//28Nov03 TH Added clause to retain the stat if default
            {
                void EnterFrequency(FQID_STAT, strText);
            }
            else {
                strXML = GetValueFromXML('Schedule_AdHoc');
                if (strXML != '') {											//10Dec03 AE  May not have one, may be genuinely empty.
                    void AdvancedScheduleToForm(strXML);
                }
            }
        }
    }

    //Start by focusing on the routes picker
    void cmdPickRoute.focus();
}

//===========================================================================

function ReadDataFromForm() {
    //Read the data back off of the form for returning to the order entry page.

    var strXML = new String();
    var objTemp = new Object();
    var lngRouteID = new Number();
    var dtDate = new Date();
    var strDate = new String();
    var lngScheduleID = new Number();
    var lowDose = new Number();
    var highDose = new Number();
    var strType = new String();
    var strUnitText = new String();

    //Obtain data from the form
    lngRouteID = document.getElementById("lstProductRoute").options[document.getElementById("lstProductRoute").selectedIndex].getAttribute('dbid');

    //Build up the data in an XML string to be included in the 
    //standard form data

    //Product and route
    strXML += FormatXML('ProductID', lblDrugName.getAttribute('productid'), lblDrugName.innerText);
    strXML += FormatXML('ProductRouteID', document.getElementById("lstProductRoute").options[document.getElementById("lstProductRoute").selectedIndex].getAttribute('dbid'), document.getElementById("lstProductRoute").options[document.getElementById("lstProductRoute").selectedIndex].innerText);

    //Dose; this may have been calculated or not, and there may be a range...				//09Jan04 AE  Added Dose ranges
    if (spnDose2.getAttribute(ATTR_SHOWN)) {
        //Dose 1 is the low dose, dose 2 is the high dose...
        highDose = txtDoseQty2.value;
        lowDose = txtDoseQty.value;
    }
    else {
        //Single dose only; dose 1 is the high dose, low dose is 0.
        highDose = txtDoseQty.value;
        lowDose = 0;
    }

    strXML += FormatXML('Dose', highDose);
    strXML += FormatXML('DoseLow', lowDose);

    if (formBody.getAttribute('iscalculateddose') == 'true') {
        //This is a calculated dose; we have to make sure we persist
        //the original dose value which was used in the calculation,
        //and also the routine used to do the calculation
        strXML += FormatXML('Calculation_Dose', formBody.getAttribute('calculation_dose'));
        strXML += FormatXML('Calculation_RoutineID', formBody.getAttribute('calculation_routineid'));
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
        if (strType == 'form') {
            //ProductForms, eg tablet, capsule, etc. 
            strXML += FormatXML('ProductFormID_Dose', lstUnits.options[lstUnits.selectedIndex].getAttribute('formid'), lstUnits.options[lstUnits.selectedIndex].text);
            strUnitText = '';
        }
        else {
            strUnitText = lstUnits.options[lstUnits.selectedIndex].text;
        }

        //Now the actual units, mg, ml etc. In the case of Forms this is not shown, and is always Quantity.
        strXML += FormatXML('UnitID_Dose', lstUnits.options[lstUnits.selectedIndex].getAttribute('dbid'), strUnitText);
    }


    //Administration schedule, including (stat and prn)
    strXML += FormatXML('PRN', (chkPRN.checked));
    strXML += FormatXML('STAT', (chkStat.checked));

    lngScheduleID = txtFreq.getAttribute('dbid');
    strXML += FormatXML('ScheduleTemplateID', lngScheduleID, txtFreq.value);

    if (lngScheduleID == 0) {
        //We have something other than a simple schedule template ID; either PRN, stat, or an ad-hoc schedule.
        if (!chkPRN.checked && !chkStat.checked) {
            //If we have an ad-hoc schedule, we need to store it.
            strXML += FormatXML('Schedule_AdHoc', advancedFrequencyData.XMLDocument.xml, txtFreqLong.value);
        }

        if (chkStat.checked) {
            //This is a stat dose.  Either immediate, or with a start date and time.
            //Start date is always recorded, time is only recorded for stat doses.
            strXML += FormatXML('STAT_Immediate', optImmediate.checked);
            if (!optImmediate.checked) {
                strXML += FormatXML('StartTime', txtStartTime.value); 													//This will only be filled for Stat doses	
            }
        }
    }

    //Duration 
    strXML += FormatXML('Duration', txtDuration.value);
    if (lstDurationUnits.selectedIndex > -1) {
        strXML += FormatXML('UnitID_Duration', lstDurationUnits.options[lstDurationUnits.selectedIndex].getAttribute('dbid'), lstDurationUnits.options[lstDurationUnits.selectedIndex].text);
    }

    //Start and stop dates.  We format them to dd-mm-yyyy format to prevent misinterpretation.
    //Start date only added if NOT an immediate STAT dose.
    if (!(chkStat.checked && optImmediate.checked)) {
        strDate = ParseDate(txtStartDate.value, FORMAT_DDMMYYYY);
        if (strDate != '') {
            strXML += FormatXML('StartDate', strDate);
        }
    }

    strDate = ParseDate(txtStopDate.value, FORMAT_DDMMYYYY)
    if (strDate != '') {
        strXML += FormatXML('StopDate', strDate);
    }

    //Additional text
    strXML += FormatXML('SupplimentaryText', txtExtra.value);

    //Build a default description
    strXML += FormatXML('ASCDescription', BuildDefaultDescription());


    //Return it
    return 'xml=' + strXML;
}

//==========================================================================

function BuildDefaultDescription() {
    //Build a default description.  This is used if no description configuration
    //is found.

    //Drug
    var strDrug = lblDrugName.innerText;

    //Route
    var strRoute = document.getElementById("lstProductRoute").options[document.getElementById("lstProductRoute").selectedIndex].innerText;
    if (strRoute == '') {
        strRoute = '[route not specified]';
    }

    //Dose + Unit
    var strDose = '';
    if (txtDoseQty.value == '') {
        strDose = '[dose not specified]';
    }
    else {
        if (!IsVisible(spnDose2)) {
            //Single dose
            strDose = txtDoseQty.value;
        }
        else {
            strDose = txtDoseQty.value + ' to ' + txtDoseQty2.value;
        }
        strDose += ' ' + lstUnits.options[lstUnits.selectedIndex].innerText;
    }
    //Frequency + PRN
    var strFrequency = txtFreq.value;
    if (strFrequency == '') {
        strFrequency = txtFreqLong.value;
    }
    else {
        if (chkPRN.checked) { strFrequency += ' PRN' };
    }

    //Duration
    var strDuration = txtDuration.value;

    if (strDuration != '') {
        strDuration = ', for ' + strDuration + ' ' + lstDurationUnits.options[lstDurationUnits.selectedIndex].text;
    }

    //Return the full description
    return (strDrug + ': ' + strDose + ' ' + strRoute + ', ' + strFrequency + strDuration);
}

//===========================================================================

function GetButtonTop(objButton) {
    //Obtain the screen top of this button
    var intTop = objButton.offsetTop + objButton.parentElement.offsetTop + window.parent.screenTop;

    //Add to it the top of the control containing this page on the parent form
    var controlID = formBody.getAttribute('controlid');
    intTop += window.parent.document.all(controlID).parentElement.offsetTop;

    return intTop;
}

//===========================================================================

function GetButtonRight(objButton) {
    //Obtain the screen right of this button
    var intLeft = objButton.offsetLeft + objButton.parentElement.offsetLeft + window.parent.screenLeft;

    //Add to it the top of the control containing this page on the parent form
    var controlID = formBody.getAttribute('controlid');
    intLeft += window.parent.document.all(controlID).parentElement.offsetLeft;

    return intLeft;
}

//===========================================================================

function TextPickerFeatures() {
    var intHeight = screen.height / 1.5;
    var intWidth = screen.width / 2.5;

    if (intHeight < 600) { intHeight = 600; }
    if (intWidth < 600) { intWidth = 600; }

    var strFeatures = 'dialogHeight:' + intHeight + 'px;'
						 + 'dialogWidth:' + intWidth + 'px;'
						 + 'resizable:yes;unadorned:yes;'
						 + 'status:no;help:no;';

    return strFeatures;
}

function FillMaintainBoxes(intWeekNo_, DoseThreshold) {
    var oProfileLength = document.getElementById("lstProfileLength");
    var intProfileLength = oProfileLength.options[oProfileLength.selectedIndex].getAttribute("dbid");
    var intMaintainWeekNo = 0;

    //Hide Maintained Week display and set the value to Zero
    for (intMaintainWeekNo = 0; intMaintainWeekNo <= 1; intMaintainWeekNo++) {
        document.getElementById("spnMnWeekName" + intMaintainWeekNo).style.display = "none";

        for (var intDayNo = 0; intDayNo <= 6; intDayNo++) {
            document.getElementById("txtMnDay" + (intDayNo + (intMaintainWeekNo * 7)).toString()).style.display = "none";
            document.getElementById("txtMnDay" + (intDayNo + (intMaintainWeekNo * 7)).toString()).value = 0;
       }
    }

    for (intMaintainWeekNo = 0; intMaintainWeekNo < intProfileLength; intMaintainWeekNo++) {
        for (intDayNo = 0; intDayNo <= 6; intDayNo++) {
            document.getElementById("spnMnWeekName" + intMaintainWeekNo).style.display = "";
            document.getElementById("spnMnWeekName" + intMaintainWeekNo).innerText = "Week " + Number(intWeekNo_ + intMaintainWeekNo + 2);
            document.getElementById("txtMnDay" + (intDayNo + (intMaintainWeekNo * 7)).toString()).style.display = "";    
            document.getElementById("txtMnDay" + (intDayNo + (intMaintainWeekNo * 7)).toString()).value = Number(DoseThreshold);
        }
    }

}

function txtDoseDays_change(txtDay) {
    //26Oct09   Rams    F0066960 - rewritten    
    var DayNo = Number(txtDay.getAttribute("DayNo"));
    var bDataChanged = false;
    var strFeatures = 'dialogHeight:20px;'
					 + 'dialogWidth:375px;'
					 + 'resizable:no;'
					 + 'status:no;help:no;';
    //
    if (txtDoseQty.value > 0 && txtDay.value > 0 && IsInteger(txtDay.value / txtDoseQty.value) == false) {
        MessageBox('Data Error', 'The entered value (<b>' + txtDay.value + '</b>) is not an multiple of Dose value (<b>' + txtDoseQty.value + '</b>).\nHence Re-setting the value to old value.', 'ok', strFeatures);
        //alert ("The entered value (" + txtDay.value + ") is not an multiple of Dose value (" + txtDoseQty.value + ").\nHence Re-setting the value to old value.");
        txtDay.value = (txtDay.lastvalue > 0 ? txtDay.lastvalue : txtDoseQty.value);
    }

    //Identify whether this is the last Sunday,Monday..etc on the profile length
    //(dayno % 7) = 0 default Pickup (i.e) day in which the Prescription is prescribed
    if ((DayNo % 7) > 0 && document.getElementById("txtDay" + (DayNo + 7).toString()).disabled) {
        if (document.getElementById("txtDay" + (DayNo - 7).toString()) == null) {//gives this is the first row
            document.getElementById("chkPickUp" + (DayNo % 7)).checked = false;
        }
        else if (document.getElementById("txtDay" + (DayNo - 7).toString()).value == 0 || document.getElementById("txtDay" + (DayNo - 7).toString()).value == '') {//Previous row has value zero
            document.getElementById("chkPickUp" + (DayNo % 7)).checked = false;
        }
    }

    if ((DayNo % 7) > 0 && (txtDay.value != 0) && !document.getElementById("chkPickUp" + (DayNo % 7)).checked) {
        document.getElementById("chkPickUp" + (DayNo % 7)).checked = true;
    }

    CalculateTotals(MaxDayBoxCount());
}


//xx-XXX-09 Rams    F0008155 Helps to identify whether the passed value is integer or not
function IsInteger(value) {
    return ((value % 1) == 0);
}

//08Sep09   Rams    F0062911 - Get the Total Dose alone.. Do not do any other job
//21Oct09   Rams    F0066961 -
function GetTotalDose(intVisibleDays) {
    // this function is applicable only for Standard Regime
    var fltTotalDose;
    var intTakeOnDays;
    // Calculate totals	
    fltTotalDose = 0;
    intTakeOnDays = 0;
    for (var intDayCounter = 0; intDayCounter < intVisibleDays; intDayCounter++) {
        //total dose = Number of take on days * daily Dose    
        if (document.getElementById("chkTakeOn" + (intDayCounter % 7).toString()).checked == true)
            intTakeOnDays++;
    }

    //return fltTotalDose;
    return intTakeOnDays * document.getElementById("txtDoseQty").value;
}

//===========================================================================

//
// If we are viewing the prescription back then disable the day boxes
//
// F0102751 ST 29Nov10 New function to disable any daily dose boxes on the form.
function DisableDayBoxesIfViewing() {
    var blnDisplay = document.body.getAttribute("displaymode");

    if (blnDisplay) {
        var inputElements = document.getElementsByTagName("input");

        for (var i = 0; i < inputElements.length; i++) {
            if (inputElements[i].id.substr(0, 6).toLowerCase() == "txtday" || inputElements[i].id.substr(0, 8).toLowerCase() == "txtmnday")
                inputElements[i].disabled = true;
        }
    }
}


function DisplayStartDateWithoutModify(data) {

    var bRetValue;

    if (window.parent.parent.document.body.getAttribute("amendmode") == "true" || window.parent.parent.document.body.getAttribute("copymode") == "true") {
        if (data < Date2ddmmccyy(new Date())) {
            bRetValue = false;
        }
        else {
            bRetValue = true;
        }
    }
    else {
        bRetValue = true;
    }

    return bRetValue;
}