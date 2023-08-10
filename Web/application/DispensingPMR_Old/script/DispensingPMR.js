// **********************************************************************************************
// *                                                                                            *
// * THIS IS THE OLD VERSION OF THE PMR AND YOU SHOULD NOT BE MAKING YOUR CHANGES HERE.         *
// * FOR THE NEW PMR ALL THIS CODE NOW EXISTS IN THE DispensingPMR.aspx PROJECT                 *
// *                                                                                            * 
// **********************************************************************************************
var m_trSelected = null;
var m_IsActive = false;

function window_onload() {
    var tr = null;
    ICWToolMenuEnable("DispensingList_PrescriptionNew", true);
    ICWToolMenuEnable("DispensingList_PrescriptionNewPSO", true);  //14Feb13 TH  56201 Added PSO Rx Button 
    ICWToolMenuEnable("DispensingList_PrescriptionNewPCT", true);
    //ICWToolMenuEnable("DispensingList_RPTDispLink", true); //20sep10 TH Removed as default (F0096331)
    ICWToolMenuEnable("DispensingList_PatientPrint", true); //TH Added
    ICWToolMenuEnable("DispensingList_PatientBagLabel", true); //TH Added (F0032604)

    // XN 11Jan11 F0100728 if episode selected the the billing button is always enabled independand on if there are any dispenings in the list
    var episodeID = Number(document.body.getAttribute("EpisodeID"));
    ICWToolMenuEnable("DispensingList_UMMCBilling", episodeID > 0);

    if (document.getElementById("tbdy").rows.length > 0)
    {
        tr = document.getElementById("tbdy").rows[0];
    }

    var lngRequestID_Prescription = Number(document.body.getAttribute("RequestID_Prescription"));
    var lngRequestID_Dispensing = Number(document.body.getAttribute("RequestID_Dispensing"));

    if (lngRequestID_Prescription > 0) {
        var trSearch = FindPrescription(lngRequestID_Prescription);
        if (trSearch != null) {
            tr = trSearch;
            tr.scrollIntoView(false);
            SetFolderOpen(tr, true, lngRequestID_Dispensing);
        }
    }

    if (tr != null) {
        RowSelect(tr);
        if (lngRequestID_Prescription == 0) {
            tr.focus();
        }
    }
    else {
        document.getElementById("tbdy").focus();
    }

    if (document.body.getAttribute("AutoDispense") == 'True') {
        if (lngRequestID_Prescription > 0) {
            Dispense();
        }
    }
	
	refreshRowStripes();
}

function DoAction(actionType)
{
	//Wrapper to OCSAction, called from the toolbar/menu event handlers	
	var SessionID = document.body.getAttribute('SessionID');
	PrepareOCSData();
	var strNewItem_XML = OCSAction(SessionID, actionType, xmlItem.firstChild, xmlType.firstChild, DataChanged, xmlStatusNoteFilter, null, null);
	if (m_trSelected != null)
	{
		m_trSelected.focus();
	}
	else
	{
		document.getElementById("tbdy").focus();
	}
	return strNewItem_XML;
}

function PrepareOCSData() {
    // Translate this grid's info into OrderComms lingo.

    var SessionID = document.body.getAttribute('SessionID');
    var dbid = m_trSelected.getAttribute("i");
    var TableID = m_trSelected.getAttribute("t");
    var RequestTypeID = m_trSelected.getAttribute("rt");
    var Description = m_trSelected.firstChild.nextSibling.innerText;
    var Mortal = m_trSelected.getAttribute("ic");
    var ProductID = m_trSelected.getAttribute("prod");
    var AutoCommit = m_trSelected.getAttribute("ac");
    var CreationType = m_trSelected.getAttribute("pct");
    var strItem_XML = '<item class="request" dbid="' + dbid + '"'
						+ ' tableid="' + TableID + '"'
						+ ' description="' + XMLEscape(Description) + '"'														//07Nov06 AE  Added XML Escape to fix #SC-06-1025
						+ ' detail="' + XMLEscape(Description) + '"'
    //	+ ' Mortal="' + Mortal + '"'
						+ ' RequestTypeID="' + RequestTypeID + '"'
						+ ' productid="' + ProductID + '"'
						+ ' autocommit="' + AutoCommit + '"'
						+ ' CreationType="' + CreationType + '"';
    // Copy rest of attributes to ocsitem node
    for (var intIndex = 0; intIndex < m_trSelected.attributes.length; intIndex++) {
        strAttribName = m_trSelected.attributes(intIndex).nodeName;
        strAttribValue = m_trSelected.attributes(intIndex).nodeValue;
        if (strAttribName.substr(0, 3) == "SB_") {
            strAttribName = strAttribName.substr(3, 999);
            strItem_XML += ' ' + strAttribName + '="' + strAttribValue + '" ';
        }
    }


    strItem_XML += ' />';
    var strType_XML = '<RequestType RequestTypeID="' + RequestTypeID + '" Description="Prescription" Orderable="1" />';

    xmlItem.XMLDocument.loadXML(strItem_XML);
    xmlType.XMLDocument.loadXML(strType_XML);

}

function PrescriptionCancelCopy()
{
	var SessionID = document.body.getAttribute('SessionID');
	if (UsingV11(SessionID))
	{
		var strNewItem_XML = DoAction(OCS_CANCEL_AND_REORDER);
		if (!AfterCopy(strNewItem_XML))
		{
			RefreshGrid(0, 0);
		}
	}
	else
	{
		PrepareOCSData();
		var blnSuccess = CancelRequest(SessionID, xmlItem.selectNodes("*"), xmlType.selectNodes("*"));
		if (blnSuccess)
		{
			if (!CopyPrescription(SessionID, xmlItem.firstChild, xmlType.firstChild, xmlStatusNoteFilter))
			{
				RefreshGrid(0, 0);
			}
		}
	}
}

function CancelRequest(SessionID, colItems, DOMTypes) {
    return CancelItem(SessionID, colItems, DOMTypes, "");
}

function CopyPrescription(SessionID, xmlItem, xmlType, xmlStatusNoteFilter) {

    //Copy a request item, ie use it as a template for creating a new pending item.
    strItem_XML = CreateOrderEntryItemXML(xmlItem);

    //Add the closing tag
    strItem_XML += '</item>';
    //And the root tags for order entry
    strItem_XML = '<copy>' + strItem_XML + xmlStatusNoteFilter + '</copy>';
    //Now load into the Order Entry component
    var strNewItem_XML = OrderEntry(SessionID, strItem_XML, true)																//15Nov06 AE  Use new OrderEntry function #SC-06-1046

    return AfterCopy(strNewItem_XML);
}

function AfterCopy(ReturnXML)
{
	//Deal with the items the user selected.
	//TaskPicker returns a blank string if the user cancels.
	if ((ReturnXML != '') && (ReturnXML != undefined))
	{
		if (ReturnXML.indexOf('<saveok ') >= 0)
		{																					//18Jun05 AE  Removed the 'refresh' return value; now refreshes if anything has been saved
			//Item has been committed
			//Load the returned xml into our data island for parsing
			ReturnXML = '<batchentry>' + ReturnXML + '</batchentry>';
			void basketData.XMLDocument.loadXML(ReturnXML);

			//Now search to make sure that there is at least one 'template' type node
			//Can only be a single item since we are forcing the task picker into "nobasket" mode
			var xmlnode = basketData.XMLDocument.selectSingleNode('//item/saveok'); 											//21Jun05 AE  Read the id from the saveok node							
			var lngRequestID_Prescription = xmlnode.getAttribute("id");

			// Reload self
			RefreshGrid(lngRequestID_Prescription, 0);
			// Send refresh to Dispensing control
			RAISE_Dispensing_RefreshState(lngRequestID_Prescription, 0);
			return true;
		}
	}
	return false;
}

function PrescriptionNewPCT() 
{
    var lngSessionID = document.body.getAttribute("SessionID");
    var lngEpisodeID = document.body.getAttribute("EpisodeID");
    var strXML = "";
    var strException = "";
    var Exceptions;
    var DOM;
    var lngHeight = 450;
    var lngWidth = 650;
    var ret;
    var undefined;

    var strReturn = new String();
    var blnShowOrderEntry = true;

    //First check the patient
    ///var strURL ='../PCTPatientBilling/default.aspx?txtMethod=ValidatePCTPatientDetails&txtSessionID=' + lngSessionID + '&txtDATAID=' +lngEpisodeID;

    ///var strPost ='txtMethod=ValidatePCTPatientDetails&txtSessionID=' + lngSessionID + '&txtDATAID=' +lngEpisodeID;

    ///m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");							
    ///m_objHTTPRequest.open("POST", strURL, false);
    ///m_objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    ///m_objHTTPRequest.send(strPost);
    ///strXML = m_objHTTPRequest.responseText;
    ///if (strXML.indexOf('<Exception>') == -1)
    ///{

    //NewThreshold Checks
    ///var strURL ='../PCTPatientBilling/default.aspx?txtMethod=PatientThresholdCheck&txtSessionID=' + lngSessionID + '&txtDATAID=' +lngEpisodeID;
    ///var strPost ='txtMethod=PatientThresholdCheck&txtSessionID=' + lngSessionID + '&txtDATAID=' +lngEpisodeID;

    ///m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");							
    ///m_objHTTPRequest.open("POST", strURL, false);
    ///m_objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    ///m_objHTTPRequest.send(strPost);
    ///strXML = m_objHTTPRequest.responseText;
    ///if (strXML.indexOf('Exceeded') != -1)
    ///{
    ///	alert('Patient has reached safety net threshold. Please review entitlement details');
    ///}

    //var strURL ='../PCTPatientBilling/default.aspx?txtMethod=PutPCTPrescriptionAction&txtSessionID=' + lngSessionID + '&txtDATA=P';
    //var strPost ='txtMethod=PutPCTPrescriptionAction&txtSessionID=' + lngSessionID + '&txtDATA=P';

    ///m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");							
    ///m_objHTTPRequest.open("POST", strURL, false);
    ///m_objHTTPRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    ///m_objHTTPRequest.send(strPost);

    var lngPCTPrescriptionID = window.showModalDialog("../PCT/PCTPrescription.aspx?SessionID=" + document.body.getAttribute("SessionID"), "",  "dialogHeight: " + lngHeight + "px; dialogWidth: " + lngWidth + "px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: No; status: No;");

    if ((lngPCTPrescriptionID != '') && (lngPCTPrescriptionID != undefined))
    {

        intWidth = screen.width / 1.1; //27Nov06 ST Made wider
        intHeight = screen.height / 1.6;

        if (intWidth < 800) { intWidth = 800 };
        if (intHeight < 600) { intHeight = 600 };

        var strFeatures = 'dialogHeight:' + intHeight + 'px;'
						     + 'dialogWidth:' + intWidth + 'px;'
						     + 'resizable:no;'  // + 'resizable:yes;' XN 4Oct12 45896 It is a risk to have the task picker resizable!!!!!
						     + 'status:no;help:no;';

        //Show the task picker:
        strURL = ICWLocation(lngSessionID) + '/application/TaskPicker/TaskPickerModal.aspx'																						//23May05 AE  Use new taskpicker
            + '?SessionID=' + lngSessionID
                + '&Show_Contents=Yes'
                    + '&Show_Favourites=Yes'
                        + '&Show_Search=Yes'
                            + '&Use_Order_Basket=No'
                                + '&DispensaryMode=1'
                                + '&RequestTypeFilter=' + document.body.getAttribute('treatmentplanrequesttype')
                                    + '&HideFilteredTypes=true';

        var strArgs = '<root singleitemonly="1" />';

        //30Jun2010 JMei F0040487 Passing the caller self and a xml message to modal dialog so that modal dialog can access its opener
        var objArgs = new Object();
        objArgs.opener = self;
        objArgs.Message = strArgs;
        if (window.dialogArguments == undefined)
        {
		    objArgs.icwwindow = window.parent.ICWWindow();
        }
        else
        {
    	    objArgs.icwwindow = window.dialogArguments.icwwindow;
        }

        var strNewItem_XML = window.showModalDialog(strURL, objArgs, strFeatures);

        //Deal with the items the user selected.
        //TaskPicker returns a blank string if the user cancels.
        if ((strNewItem_XML != '') && (strNewItem_XML != undefined)) 
        {
            if (strNewItem_XML.indexOf('<saveok ') >= 0) 
            {																					//18Jun05 AE  Removed the 'refresh' return value; now refreshes if anything has been saved
                //Item has been committed
                //Load the returned xml into our data island for parsing
                strNewItem_XML = '<batchentry>' + strNewItem_XML + '</batchentry>';
                void basketData.XMLDocument.loadXML(strNewItem_XML);

                //Now search to make sure that there is at least one 'template' type node
                //Can only be a single item since we are forcing the task picker into "nobasket" mode
                var xmlnode = basketData.XMLDocument.selectSingleNode('//item/saveok'); 											//21Jun05 AE  Read the id from the saveok node							
                var lngRequestID_Prescription = xmlnode.getAttribute("id");

                var strURL = '../PCT/PCTPrescription.aspx?SessionID=' + document.body.getAttribute("SessionID") + '&Method=LinkPCTPrescription&PCTPRescriptionID=' + lngPCTPrescriptionID + '&RequestID_Prescription=' + lngRequestID_Prescription;

                m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
                m_objHTTPRequest.open("GET", strURL, false);
                m_objHTTPRequest.send();

                // Reload self
                RefreshGrid(lngRequestID_Prescription, 0);
                // Send refresh to Dispensing control
                RAISE_Dispensing_RefreshState(lngRequestID_Prescription, 0);
            }
            else 
            {
                if (m_trSelected != null) 
                {
                    m_trSelected.focus();
                }
                else 
                {
                    document.getElementById("tbdy").focus();
                }
            }
        }
        else 
        {
            if (m_trSelected != null) 
            {
                m_trSelected.focus();
            }
            else 
            {
                document.getElementById("tbdy").focus();
            }
        }
    }
}


function PrescriptionNew() {
    var strReturn = new String();
    var blnShowOrderEntry = true;
    var lngSessionID = document.body.getAttribute("SessionID");

    //Determine the size to show the task picker in.
    //F0093562 09Aug10 JMei make sure Width of Task Picker is around 90% of screen width
    var intWidth = screen.width / 1.1; //27Nov06 ST Made wider
    var intHeight = screen.height / 1.6;

    if (intWidth < 800) { intWidth = 800 };
    if (intHeight < 600) { intHeight = 600 };

    var strFeatures = 'dialogHeight:' + intHeight + 'px;'
						 + 'dialogWidth:' + intWidth + 'px;'
						 + 'resizable:no;'  // + 'resizable:yes;' XN 4Oct12 45896 It is a risk to have the task picker resizable!!!!!
						 + 'status:no;help:no;';

    //Show the task picker:
    strURL = ICWLocation(lngSessionID) + '/application/TaskPicker/TaskPickerModal.aspx'																						//23May05 AE  Use new taskpicker
        + '?SessionID=' + lngSessionID
            + '&Show_Contents=Yes'
                + '&Show_Favourites=Yes'
                    + '&Show_Search=Yes'
                        + '&Use_Order_Basket=No'
                            + '&DispensaryMode=1'
                                + '&RequestTypeFilter=' + document.body.getAttribute('treatmentplanrequesttype')
                                    + '&HideFilteredTypes=true';

    var strArgs = '<root singleitemonly="1" />'

    //30Jun2010 JMei F0040487 Passing the caller self and a xml message to modal dialog so that modal dialog can access its opener
    var objArgs = new Object();
    objArgs.opener = self;
    objArgs.Message = strArgs;
    if (window.dialogArguments == undefined)
    {
		objArgs.icwwindow = window.parent.ICWWindow();
    }
    else
    {
    	objArgs.icwwindow = window.dialogArguments.icwwindow;
    }

    var strNewItem_XML = window.showModalDialog(strURL, objArgs, strFeatures);

    //Deal with the items the user selected.
    //TaskPicker returns a blank string if the user cancels.
    if ((strNewItem_XML != '') && (strNewItem_XML != undefined)) {
        if (strNewItem_XML.indexOf('<saveok ') >= 0) {																					//18Jun05 AE  Removed the 'refresh' return value; now refreshes if anything has been saved
            //Item has been committed
            //Load the returned xml into our data island for parsing
            strNewItem_XML = '<batchentry>' + strNewItem_XML + '</batchentry>';
            void basketData.XMLDocument.loadXML(strNewItem_XML);

            //Now search to make sure that there is at least one 'template' type node
            //Can only be a single item since we are forcing the task picker into "nobasket" mode
            var xmlnode = basketData.XMLDocument.selectSingleNode('//item/saveok'); 											//21Jun05 AE  Read the id from the saveok node							
            var lngRequestID_Prescription = xmlnode.getAttribute("id");

            // Reload self
            RefreshGrid(lngRequestID_Prescription, 0);
            // Send refresh to Dispensing control
            RAISE_Dispensing_RefreshState(lngRequestID_Prescription, 0);
        }
        else {
            if (m_trSelected != null) {
                m_trSelected.focus();
            }
            else {
                document.getElementById("tbdy").focus();
            }

        }
    }
    else {
        if (m_trSelected != null) {
            m_trSelected.focus();
        }
        else {
            document.getElementById("tbdy").focus();
        }
    }
}

function DataChanged() {
    // Callback function from OCSAction, used to update the grid, if required
    var lngRequestID_Prescription = Number(m_trSelected.getAttribute("i")); //25Aug11 TH Added to retain current posn
    RAISE_NoteChanged();

    RefreshGrid(lngRequestID_Prescription , 0);
}

function FindDispensing(lngID) {
    var tr;

    tr = document.getElementById("tbdy").firstChild;
    while (tr != null) {
        if (tr.getAttribute("c") == "D" && Number(tr.getAttribute("i")) == lngID) {
            return tr;
        }

        tr = tr.nextSibling;
    }
    return null;
}

function FindPrescription(lngID) {
    var tr;

    tr = document.getElementById("tbdy").firstChild;
    while (tr != null) {
	    if ((tr.getAttribute("c") == "P" || tr.getAttribute("c") == "M") && Number(tr.getAttribute("i")) == lngID)
		{
            return tr;
        }

        tr = tr.nextSibling;
    }
    return null;
}

function ClearControl() {
    RAISE_Dispensing_RefreshState(0, 0);
}

function RefreshControl() {
    var lngSessionID = 0;
    var lngRequestID_Prescription = 0;
    var lngRequestID_Dispensing = 0;
    var tr;

    if (m_trSelected != null) {
        lngSessionID = document.body.getAttribute("SessionID");

        switch (m_trSelected.getAttribute("c")) {
            case "P": // Prescription
			case "M": // Merged Prescription
                lngRequestID_Prescription = 0;
                lngRequestID_Dispensing = 0;
                break;

            case "D": // Dispensing
                tr = m_trSelected;
                while (tr.previousSibling != null) {
                    tr = tr.previousSibling;
					if (tr.getAttribute("c") == "P" || tr.getAttribute("c") == "M")
					{
                        lngRequestID_Prescription = Number(tr.getAttribute("i"));
                        break;
                    }
                }
                lngRequestID_Dispensing = Number(m_trSelected.getAttribute("i"));
                break;

        }

        RAISE_Dispensing_RefreshState(lngRequestID_Prescription, lngRequestID_Dispensing);
    }
}

function Dispense() {
    var lngSessionID = 0;
    var lngRequestID_Prescription = 0;
    var lngRequestID_Dispensing = 0;
    var tr;

    if (m_trSelected != null && m_trSelected.getAttribute("ic") == "1") 
    {
//        if (m_trSelected.getAttribute("isgenerictemplate") == "1") 
//        {
//            //04Mar2011 Rams    F0041360 - Should not dispense Generic Prescription
//            alert('You cannot dispense a Generic Prescription. Click on View to see the prescription details.');
//            return;
//        }

        lngSessionID = document.body.getAttribute("SessionID");

//      XN 13Mar13 59024 Fixed trying to connect to invalid missing page
//        var strURL = '../PBS_PatientBilling_aspx/default.aspx?txtMethod=PutPBSPrescriptionAction&txtSessionID=' + lngSessionID + '&txtDATA=';

//        m_objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
//        m_objHTTPRequest.open("GET", strURL, false);
//        m_objHTTPRequest.send();
        switch (m_trSelected.getAttribute("c")) {
            case "P": // Prescription
            case "M": // Merged Prescription
                lngRequestID_Prescription = Number(m_trSelected.getAttribute("i"));
                lngRequestID_Dispensing = 0;
                RAISE_Dispensing_RefreshState(lngRequestID_Prescription, lngRequestID_Dispensing);
                break;

            case "D": // Dispensing
                RefreshControl()
                break;
        }
		
	}
}

function DispenseNewDose()
{
var lngSessionID = 0;
var lngRequestID_Prescription = 0;
var lngRequestID_Dispensing = 0;
var tr;

	if ( m_trSelected != null && m_trSelected.getAttribute("ic")=="1"  )
	{
		lngSessionID				= document.body.getAttribute("SessionID");


		switch (m_trSelected.getAttribute("c"))
		{
			case "P": // Prescription
			case "M": // Merged Prescription 11Nov11 TH Added TFS 19062 
				lngRequestID_Prescription	= Number(m_trSelected.getAttribute("i"));
				lngRequestID_Dispensing		= -4;
				RAISE_Dispensing_RefreshState(lngRequestID_Prescription, lngRequestID_Dispensing);
				break;

			case "D": // Dispensing
				//RefreshControl()
				break;
		}
		
	}
}



//02Aug12 TH Added for PSO (TFS 40531)

function DispensePSO()
{
var lngSessionID = 0;
var lngRequestID_Prescription = 0;
var lngRequestID_Dispensing = 0;
var tr;

	if ( m_trSelected != null && m_trSelected.getAttribute("ic")=="1"  )
	{
		lngSessionID				= document.body.getAttribute("SessionID");


		switch (m_trSelected.getAttribute("c"))
		{
			case "P": // Prescription
			case "M": // Merged Prescription  
				lngRequestID_Prescription	= Number(m_trSelected.getAttribute("i"));
				lngRequestID_Dispensing		= -5;
				RAISE_Dispensing_RefreshState(lngRequestID_Prescription, lngRequestID_Dispensing);
				break;

			case "D": // Dispensing
				//RefreshControl()
				break;
		}
		
	}
}

function DispenseNewDosePSO()
{
var lngSessionID = 0;
var lngRequestID_Prescription = 0;
var lngRequestID_Dispensing = 0;
var tr;

	if ( m_trSelected != null && m_trSelected.getAttribute("ic")=="1"  )
	{
		lngSessionID				= document.body.getAttribute("SessionID");


		switch (m_trSelected.getAttribute("c"))
		{
			case "P": // Prescription
			case "M": // Merged Prescription 11Nov11 TH Added TFS 19062 
				lngRequestID_Prescription	= Number(m_trSelected.getAttribute("i"));
				lngRequestID_Dispensing		= -6;
				RAISE_Dispensing_RefreshState(lngRequestID_Prescription, lngRequestID_Dispensing);
				break;

			case "D": // Dispensing
				//RefreshControl()
				break;
		}
		
	}
}


function RowMoveCursor(tr) {
    var trLastRow = m_trSelected;
    m_trSelected = tr;

    if (trLastRow != null) {
        SetRowClass(trLastRow);
        trLastRow.tabIndex = -1;
    }

    SetRowClass(m_trSelected);
    m_trSelected.tabIndex = 0;
}

function GetHighlightedRowXML() {
    PrepareOCSData();
    return xmlItem.selectNodes("*");
}

function RowSelect(tr) {
    var objHTTPRequest;

    if (tr != null) {
        RowMoveCursor(tr);
        PrepareOCSData();
        var colItems = GetHighlightedRowXML();
        var DOMTypes = new ActiveXObject("MSXML2.DOMDocument");
        var xmlRoot = DOMTypes.appendChild(DOMTypes.createElement('root'));
        var parent = $('#tbdy tr[i="' + tr.getAttribute("p") + '"]');

        xmlRoot.appendChild(xmlType.firstChild.cloneNode(false));

        //14Nov12 AJK 43495 Added EnableEmmRestrictions to the check (ported 59544 21Mar13 AJK)
        var blnCanStopOrAmend = ((tr.getAttribute('csa') == null || tr.getAttribute('csa') == '' || tr.getAttribute('csa') == '1') && document.body.getAttribute("EnableEmmRestrictions") != "True");

        ICWToolMenuEnable("DispensingList_PrescriptionNew", document.body.getAttribute("View") == "Current" && document.body.getAttribute("EnableEmmRestrictions") != "True"); //14Nov12 AJK 43495 Added EnableEmmRestrictions to the check (ported 59544 21Mar13 AJK)
        ICWToolMenuEnable("DispensingList_PrescriptionNewPSO", document.body.getAttribute("View") == "Current" && document.body.getAttribute("EnableEmmRestrictions") != "True"); //14Nov12 AJK 43495 Added EnableEmmRestrictions to the check (ported 59544 21Mar13 AJK)
        ICWToolMenuEnable("DispensingList_View", (tr.getAttribute("c") == "P") || (tr.getAttribute("c") == "T"));
		ICWToolMenuEnable("DispensingList_AttachNotes", tr.getAttribute("c") == "P" || tr.getAttribute("c") == "M" || tr.getAttribute("c") == "T"); 
        //ICWToolMenuEnable("DispensingList_Dispense", document.body.getAttribute("View")=="Current" && tr.getAttribute("ic")=="1" );
		ICWToolMenuEnable("DispensingList_Dispense", tr.getAttribute("ic") == "1" && tr.getAttribute("c") != "T" && tr.getAttribute("mergeCancelled") != "1" && parent.attr("mergeCancelled") != "1");
        //ICWToolMenuEnable("DispensingList_CancelAndCopyItem", (blnCanStopOrAmend && tr.getAttribute("c") == "P" && tr.getAttribute("ic") == "1" && tr.getAttribute("Level") == "0"));
        ICWToolMenuEnable("DispensingList_CancelAndCopyItem", (blnCanStopOrAmend && OCSActionAvailable_Batch(OCS_CANCEL_AND_REORDER, colItems, DOMTypes) && tr.getAttribute("c") == "P" && tr.getAttribute("ic") == "1" && tr.getAttribute("Level") == "0"));
        ICWToolMenuEnable("DispensingList_CancelItem", (blnCanStopOrAmend && OCSActionAvailable_Batch(OCS_CANCEL, colItems, DOMTypes) && tr.getAttribute("c") == "P" && tr.getAttribute("ic") == "1" && tr.getAttribute("Level") == "0"));
        ICWToolMenuEnable("DispensingList_PrescriptionNewPCT", document.body.getAttribute("View") == "Current" && document.body.getAttribute("EnableEmmRestrictions") != "True"); //14Nov12 AJK 43495 Added EnableEmmRestrictions to the check (ported 59544 21Mar13 AJK)
        ICWToolMenuEnable("DispensingList_RPTDispLink", tr.getAttribute("c") == "D"); //10Jul09 TH Repeat liinking only available on current disp lines //08Sep11 TH Allow for history also TFS13476
        ICWToolMenuEnable("DispensingList_PrintSpecifiedReport", tr.getAttribute("c") != "T");  // XN 30Jan11 Disabled for PN prescription 
        ICWToolMenuEnable("DispensingList_UMMCBilling", tr.getAttribute("c") != "T");  // XN 30Jan11 Updated to be disabled for PN // XN 11Jan11 F0100728 Added UMMC billing button to dispensing PMR screen
		ICWToolMenuEnable("DispensingList_PrescriptionMerge", (tr.getAttribute("ic") == "1") && ((tr.getAttribute("c") == "P" || tr.getAttribute("c") == "M") && tr.getAttribute("Level") == "0"));  // XN 16Jun11 F0041502 Asymmetric Dosing button
		//ICWToolMenuEnable("DispensingList_DispenseNewDose",  tr.getAttribute("ic")=="1" ); 
	//22Aug11 TH disable splitting button on merged rx
        //ICWToolMenuEnable("DispensingList_DispenseNewDose",  (tr.getAttribute("ic") == "1") && ((tr.getAttribute("c") == "P") && tr.getAttribute("Level") == "0")) ; // 03Aug11 TFS 10614
		ICWToolMenuEnable("DispensingList_DispenseNewDose", (tr.getAttribute("ic") == "1") && (((tr.getAttribute("c") == "P") && tr.getAttribute("Level") == "0") || tr.getAttribute("c") == "M") && (tr.getAttribute("c") != "D") && tr.getAttribute("mergeCancelled") != "1"); // 09Nov11 THTFS 18827	
        ICWToolMenuEnable("DispensingList_PatientBagLabel", tr.getAttribute("c") != "T");       // XN 30Jan11 Disabled for PN prescription //TH Added (F0032604)
        ICWToolMenuEnable("DispensingList_DispensePSO",  (tr.getAttribute("ic") == "1") && (((tr.getAttribute("c") == "P") && tr.getAttribute("Level") == "0") || tr.getAttribute("c") == "M") && (tr.getAttribute("c") != "D")); // 09Nov11 THTFS 18827	
        ICWToolMenuEnable("DispensingList_DispenseNewDosePSO",  (tr.getAttribute("ic") == "1") && (((tr.getAttribute("c") == "P") && tr.getAttribute("Level") == "0") || tr.getAttribute("c") == "M") && (tr.getAttribute("c") != "D")); // 22Nov12 TH TFS 40895	
        
	//Generic Status Note bits
        //Each status note results in the appearance of a button called cmdStatusNote.  Each button deals with one requesttype.

        var colStatusButtons = document.all['cmdStatusNote'];
        if (colStatusButtons != undefined) {
            PrepareOCSData();
            if (colStatusButtons.length == undefined) {
                //Single button 
                void StatusNoteButtonEnable(colStatusButtons, xmlItem.selectNodes("*"));
            }
            else {
                //Collection
                for (i = 0; i < colStatusButtons.length; i++) {
                    void StatusNoteButtonEnable(colStatusButtons[i], xmlItem.selectNodes("*"));
                }
            }
        }
        //New info launch
        if (tr.getAttribute("c") == "P") {
            var lngRequestID_Prescription = Number(tr.getAttribute("i"));
            RAISE_Prescription_info(lngRequestID_Prescription); //20-11-2007 JA commented this out as the function is not existent -10Aug12 TH yes it was bozo

        }
	//For PSO
	if (tr.getAttribute("c") == "D") {
            var lngRequestID_Dispensing = Number(tr.getAttribute("i"));
            RAISE_Dispensing_info(lngRequestID_Dispensing); 

        }
	else
	{
	    RAISE_Dispensing_info(0); 
	}

        if (document.body.getAttribute('SelectEpisode') == 'True') {
            var previous;
            previous = tr;
            //is the selected row a dispensing? need to get the episode id from the parent row
            if (previous.getAttribute('pres_row') != 'true') {
                while (previous.getAttribute('pres_row') == 'false') //iterate through the previous elements until the top level prtescription record is found with a pres_row of true
                    previous = previous.previousSibling;
            }
            lngEpisodeID = previous.getAttribute("e");
            //if (lngEpisodeID != null) {                   //DJH TFS13018
            if (lngEpisodeID != null && lngEpisodeID > 0) { //DJH TFS13018
                var strURL = "../DispensingPMR_Old/EpisodeSaver.aspx?SessionID=" + document.body.getAttribute("SessionID") + "&EpisodeID=" + lngEpisodeID;
                objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP"); 						//Create the object
                if (objHTTPRequest != null) {
                    objHTTPRequest.open("POST", strURL, false); 									//false = syncronously
                    objHTTPRequest.send(null); 													//Send the request syncronously

                    // 21Feb11 PH Take ICW EpisodeID integer, convert to entity & episode versioned identifiers, and raise the ICW Episode Selected Event
                    // Create JSON episode event data
                    var jsonEntityEpisodeVid = ICW.clinical.episode.eventSelectedRaised(lngEpisodeID, 0, document.body.getAttribute("SessionID"));
                    // Raise episode event via ICW framework, using entity & episode versioned identifier
                    RAISE_EpisodeSelected(jsonEntityEpisodeVid);

                    //RAISE_EpisodeSelected();
                }
                else
                    alert("Create XMLHTTP failed");
            }
            else {                          //DJH TFS13018
                RAISE_EpisodeCleared();     //DJH TFS13018
            }                               //DJH TFS13018
        }
    }
}

function RowSelectByPID(lngID) {
// 13Jun13 AJK 66474 Added function to enable row select by RxID
    var tr;

    tr = FindPrescription(lngID);

    if (tr != null) {
        RowSelect(tr);
    }
}

function grid_onclick() {
    var tr = GetTR(event.srcElement);
    if (tr.attributes['i'] != undefined)    // XN 20Oct12 49631 Norfolk script error fix
    {
        RowSelect(tr);
        ClearControl();
    }
}

function x_clk(td) {
    // folder has been opened or closed
    var tr = td.parentNode;
    SetFolderOpen(tr, tr.getAttribute("loaded") != "1" || tr.nextSibling.style.display == "none");
}

function SetFolderOpen(tr, blnOpen, lngRequestID)
{
    // Toggle folder state between open/closed

    var lngParentID = Number(tr.getAttribute("i"));
    var strRepeatDispensing = document.body.getAttribute("RepeatDispensing");
    var strPSO = document.body.getAttribute("PSO");
    var level = Number(tr.getAttribute("Level"));

    if (tr.firstChild.firstChild != null && tr.firstChild.firstChild != undefined && tr.firstChild.firstChild.tagName == "IMG")
    {
        tr.firstChild.firstChild.src = (!blnOpen ? "../../images/grid/open.gif" : "../../images/grid/closed.gif");
        if (blnOpen && tr.getAttribute("loaded") != "1")
        {
            if (tr.getAttribute("c") == "P")
                //FetchDispensings(lngParentID, lngRequestID, strRepeatDispensing, level);
		FetchDispensings(lngParentID, lngRequestID, strRepeatDispensing, strPSO);
            else
                FetchPrescriptionMerge(lngParentID, lngRequestID, strRepeatDispensing);
        }
        else
        {
            // Create an array of if a specific child element is open
            var openlevel = new Array();
            for (var l = 0; l < 3; l++)
                openlevel[l] = blnOpen;

            // Iterate through all child elements (level > current level)
            // and hide or display item
            // if hide then hide all if, opening then only open if parent item state is open
            trChild = tr.nextSibling;
            while (trChild != null && (trChild.getAttribute("Level") > level)) 
            {
                var l = Number(trChild.getAttribute("Level"));

                // If this item has children check if it's state is open or closed
                // (only effective if blnOpen is open else will always close)
                if (trChild.firstChild.firstChild.src != undefined)
                    openlevel[l + 1] = openlevel[l] && (trChild.firstChild.firstChild.src.indexOf('closed.gif') >= 0);

                // Hide or display the items if the parent is being open or closed
                trChild.style.display = (!openlevel[l] ? "none" : "");
                trChild = trChild.nextSibling;
            }
        }
    }
}

function refreshRowStripes()
{
    if ($('body').attr('WorkListAlternateRowColour') == 'True')
    {
        if (m_trSelected != null)
            $(m_trSelected).removeClass('RowSelected');

        $('#tbdy tr').removeClass('RowOdd');
        $('#tbdy tr[level="0"]').removeClass('RowLevel0Even');
        $('#tbdy tr[level="1"]').removeClass('RowLevel1Even');
        $('#tbdy tr[level="2"]').removeClass('RowLevel2Even');

        $('#tbdy tr[level="0"]:even').addClass('RowLevel0Even');
        $('#tbdy tr[level="0"]:odd').addClass('RowOdd');

        $('#tbdy tr[level="1"]:even').addClass('RowLevel1Even');
        $('#tbdy tr[level="1"]:odd').addClass('RowOdd');

        $('#tbdy tr[level="2"]:even').addClass('RowLevel2Even');
        $('#tbdy tr[level="2"]:odd').addClass('RowOdd');

        if (m_trSelected != null)
            SetRowClass(m_trSelected)
    }
}

function FetchDispensings(lngRequestID_Prescription, lngRequestID_Dispensing, strRepeatDispensing, strPSO)
{
    var strURL = "../DispensingPMR_old/DispensingLoader.aspx?SessionID=" + document.body.getAttribute("SessionID") + "&RequestID_Prescription=" + lngRequestID_Prescription + "&RequestID_Dispensing=" + lngRequestID_Dispensing + "&Level=2";
    strURL = strURL + "&RepeatDispensing=" + strRepeatDispensing;
    strURL = strURL + "&PSO=" + strPSO;
	window.frames("fraLoader").navigate(strURL);
}

function FetchPrescriptionMerge(requestID_WPrescriptionMerge, requestID_Dispensing, strRepeatDispensing) 
{
    var strURL = "../DispensingPMR_old/PrescriptionMergeLoader.aspx?SessionID=" + document.body.getAttribute("SessionID");
    strURL += "&RequestID_WPrescriptionMerge=" + requestID_WPrescriptionMerge;
    if (Number(requestID_Dispensing) > 0)
        strURL += "&RequestID_Dispensing=" + requestID_Dispensing;
    strURL += "&RepeatDispensing=" + strRepeatDispensing;
    strURL += "&PSO=" + document.body.getAttribute("PSO");
    window.frames("fraLoader").navigate(strURL);
}

function grid_onkeydown() {
    if (m_trSelected != null) {
        switch (event.keyCode) {
            case 36: // Home
                if (tbl.rows.length > 1) {
                    RowSelect(tbl.rows[1]);
                    tbl.rows[1].scrollIntoView(false);
                }
                event.returnValue = false;
                break;

            case 35: // End
                if (tbl.rows.length > 1) {
                    RowSelect(tbl.rows[1]);
                    var tr = tbl.rows[tbl.rows.length - 1];
                    while (tr.style.display == "none") {
                        tr = tr.previousSibling;
                    }
                    RowSelect(tr);
                    tr.scrollIntoView(false);
                }
                event.returnValue = false;
                break;

            case 38: // Up
                var tr = m_trSelected;
                if (tr.previousSibling != null) {
                    do {
                        tr = tr.previousSibling;
                    } while (tr.style.display == "none")
                    RowSelect(tr);
                    tr.scrollIntoView(false);
                    ClearControl();
                }
                event.returnValue = false;
                break;

            case 40: // Down
                var tr = m_trSelected;
                do {
                    tr = tr.nextSibling;
                } while (tr != null && tr.style.display == "none")
                if (tr != null) {
                    RowSelect(tr);
                    tr.scrollIntoView(false);
                    ClearControl();
                }
                event.returnValue = false;
                break;

            case 37: // Left
                if (m_trSelected.nextSibling != null) {
                    var strClass = m_trSelected.getAttribute("c");
                    switch (strClass) {
                        case "D": // Dispensing
                            // Move cursor to containing folder
                            var lngRequestID_Parent = Number(m_trSelected.getAttribute("p"));
                            var trParent = FindPrescription(lngRequestID_Parent);
                            trParent.scrollIntoView(false);
                            RowSelect(trParent);
                            ClearControl();
                            break;

                        case "P": // Prescription
                            if (HasDispensings(m_trSelected)) // Has children
                            {
                                if (m_trSelected.getAttribute("loaded") == "1" && m_trSelected.nextSibling.style.display != "none") // that are visible in an expanded folder
                                {
                                    // close folder
                                    SetFolderOpen(m_trSelected, false);
                                }
                            }
                            break;
							
			            case "M":
			                if (m_trSelected.getAttribute("loaded") != "1" || m_trSelected.nextSibling.style.display == "none") // that are not visible in a closed folder
			                {
			                    // open folder
			                    SetFolderOpen(m_trSelected, false);
			                }
			                break;
                    }
                }
                event.returnValue = false;
                break;

            case 39: // Right
                if (HasDispensings(m_trSelected)) {
                    Expand();
                }
                event.returnValue = false;
                break;

            case 13: // Enter
                if (HasDispensings(m_trSelected)) {
                    Expand();
                }
                Dispense();
                event.returnValue = false;
                break;
        }
    }
}

function Expand() {
    var strClass = m_trSelected.getAttribute("c");
    switch (strClass) {
        case "D": // Dispensing
            break;

        case "P": // Prescription
            if (HasDispensings(m_trSelected)) // has children
            {
                if (m_trSelected.getAttribute("loaded") != "1" || m_trSelected.nextSibling.style.display == "none") // that are not visible in a closed folder
                {
                    // open folder
                    SetFolderOpen(m_trSelected, true);
                }
            }
            break;

        case "M":
            if (m_trSelected.getAttribute("loaded") != "1" || m_trSelected.nextSibling.style.display == "none") // that are not visible in a closed folder
            {
                // open folder
                SetFolderOpen(m_trSelected, true);
            }
            break;            
    }
}

function HasDispensings(tr) {
    return tr.getAttribute("chld") == "1";
}

function grid_onactivate() {
    m_IsActive = true;
    if (m_trSelected != undefined) {    //DJH - 01/09/2011 - Bug 11052
        SetRowClass(m_trSelected);
    }                                   //DJH - 01/09/2011 - Bug 11052
}

function grid_ondeactivate() {
    m_IsActive = false;
    if (m_trSelected != undefined) {    //DJH - 01/09/2011 - Bug 11052
        SetRowClass(m_trSelected);
    }                                   //DJH - 01/09/2011 - Bug 11052
}

function GetTR(ele) {
    while (ele.nodeName != "TR") {
        ele = ele.parentNode;
    }
    return ele;
}

function DispensingsLoaded(lngRequestID_Prescription, lngRequestID_Dispensing) {
    var trPrescription = FindPrescription(lngRequestID_Prescription);
    trPrescription.setAttribute("loaded", "1");
    var tblLoader = window.frames("fraLoader").document.getElementById("tblLoader");
    for (var intRow = tblLoader.rows.length - 1; intRow >= 0; intRow--) {
        var trLoaded = tblLoader.rows[intRow];
        trLoaded.scrollIntoView(false);
		if (trLoaded.firstChild.firstChild.tagName == "IMG")
		    $("td:first", trLoaded).click(function() { x_clk(this); });
        trPrescription.insertAdjacentElement("afterEnd", trLoaded);
    }
	refreshRowStripes();
    if (Number(lngRequestID_Dispensing) > 0) {
        var trSearch = FindDispensing(lngRequestID_Dispensing);
        if (trSearch != null) {
            trSearch.scrollIntoView(false); ;
            RowSelect(trSearch);
        }
    }
}

function PrescriptionMergesLoaded(requestID_WPrescriptionMerge, lngRequestID_Dispensing)
{
    var trPrescription = FindPrescription(requestID_WPrescriptionMerge);
    trPrescription.setAttribute("loaded", "1");
    var tblLoader = window.frames("fraLoader").document.getElementById("tblLoader");
    for (var intRow = tblLoader.rows.length - 1; intRow >= 0; intRow--)
    {
        var trLoaded = tblLoader.rows[intRow];
        trLoaded.scrollIntoView(false);
        if (trLoaded.firstChild.firstChild.tagName == "IMG")
            $("td:first", trLoaded).click(function() { x_clk(this); });
        trPrescription.insertAdjacentElement("afterEnd", trLoaded);
    }

    var lngParentID         = Number(trPrescription.getAttribute("i"));
    var lngRequestID        = m_trSelected.getAttribute("c")
    var strRepeatDispensing = document.body.getAttribute("RepeatDispensing");
    var lngLevel            = Number(trPrescription.getAttribute("Level"));
    FetchDispensings(lngParentID, lngRequestID, strRepeatDispensing, lngLevel);
}

function SetRowClass(tr) {
    var strClass = "";

    if (tr == m_trSelected) 
    {
        if (!$(tr).hasClass('RowSelected'))
            $(tr).attr('oldClass', tr.className);

        strClass += "RowSelected ";

        if (!m_IsActive)
            strClass += "RowUnfocused ";
    }
    else 
    {
        var oldClass = $(tr).attr('oldClass');
        if (oldClass != '')
            strClass += oldClass;
    }

    if (tr != null) {
        tr.className = strClass;
    }
}
function PatientPrint() {
    //TH Added from 9.9

    RAISE_Dispensing_RefreshState(0, -1);

}

function PatientBagLabel() {
    //TH Added for middlemore (F0032604)

    RAISE_Dispensing_RefreshState(0, -3);

}
function RPTDispensingLink() {
    //TH Added for repeat Dispensing
    //InputBox("Repeat Dispensing", "Enter Quantity to Repeat Dispense", "OkCancel", "OK", "NUMBERS", "")
    window.showModalDialog("../RepeatDispensing/RepeatDispensingLinkingModal.aspx?DispensingID=" + m_trSelected.getAttribute("i") + "&SessionID=" + document.body.getAttribute("SessionID"), "", "");
    RefreshGrid(document.body.getAttribute("RequestID_Prescription"), document.body.getAttribute("RequestID_Dispensing"));
}

function UMMCBilling()
{
// XN 11Jan11 F0100728 Added for UMMC billing
var strURL = document.URL;
var intSplitIndex = strURL.indexOf('?');
var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

// Displays the UMMC billing screen as a popup
window.showModalDialog('../UMMCBilling/UMMCBillingScreenModal.aspx' + strURLParameters, '', 'dialogHeight:670px; dialogWidth:980px; status:off; center: Yes');
}

// XN 11Jun11 F0041502 Added for Prescription linking
// Display the link form for exsiting prescriptions, and unlinks alreadt linked items
function PrescriptionMerge()
{
    var sessionID = document.body.getAttribute("SessionID");
    var requestID = m_trSelected.getAttribute("i");
    var episodeID = document.body.getAttribute("EpisodeID");

    if (m_trSelected.getAttribute("c") == "P")
    {
        var strURLParameters = '?SessionID=' + sessionID + '&RequestID=' + requestID + '&EpisodeID=' + episodeID;
        
        // Displays the Prescription Linking screen as a popup
        if (window.showModalDialog('../DispensingPMR/PrescriptionMergeModal.aspx' + strURLParameters, '', 'status:off; center: Yes;') == true)
            RefreshGrid(document.body.getAttribute("RequestID_Prescription"), document.body.getAttribute("RequestID_Dispensing"));
    }
    else if (m_trSelected.getAttribute("c") == "M")
    {
        // Ask if want to unlink
        if (ICWConfirm('Do you want to unlink this prescription?', 'Yes,No', 'Prescription Unlinking', 'dialogHeight:80px;dialogWidth:275px;status:no;help:no;') == 'Yes')
        {
            // Unlink
            var sendData = "{'sessionID': '" + sessionID + "', 'requestID': '" + requestID + "' }";
            PostServerMessage("../DispensingPMR/PrescriptionMerge.aspx/Unlink", sendData);
            RefreshGrid(document.body.getAttribute("RequestID_Prescription"), document.body.getAttribute("RequestID_Dispensing"));
        }
    }
}

function PrintSpecifiedReport(ReportName) {
    if (ReportName == "") {
        alert("The specified report button_data cannot be found. Please ensure that the name is specified correctly in the Desktop Editor.");
    }
    else {
        txtPrintReport.value = ReportName;
        var SessionID = document.body.getAttribute('sid');
        return PrintNamedReport(SessionID, ReportName, document.body.getAttribute("IsPrintPreview") == "on");
    }
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

// XN 15Nov12 TFS49152 Prevent status notes from crashing
function V11Location(SessionID) {
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    var strURL = '../sharedscripts/AppSettingRead.aspx'
			  + '?SessionID=' + SessionID
			  + '&Setting=ICW_V11Location';
    var v11Location = '';

    objHTTPRequest.open("POST", strURL, false); //false = syncronous                              
    objHTTPRequest.send("");
    v11Location = objHTTPRequest.responseText;

    return v11Location;
}

function PrescriptionNewPSO() {
    var strReturn = new String();
    var blnShowOrderEntry = true;
    var lngSessionID = document.body.getAttribute("SessionID");

    //Determine the size to show the task picker in.
    //F0093562 09Aug10 JMei make sure Width of Task Picker is around 90% of screen width
    var intWidth = screen.width / 1.1; //27Nov06 ST Made wider
    var intHeight = screen.height / 1.6;

    if (intWidth < 800) { intWidth = 800 };
    if (intHeight < 600) { intHeight = 600 };

    var strFeatures = 'dialogHeight:' + intHeight + 'px;'
						 + 'dialogWidth:' + intWidth + 'px;'
						 + 'resizable:no;'  // + 'resizable:yes;' XN 4Oct12 45896 It is a risk to have the task picker resizable!!!!!
						 + 'status:no;help:no;';

    //Show the task picker:
    strURL = ICWLocation(lngSessionID) + '/application/TaskPicker/TaskPickerModal.aspx'																						//23May05 AE  Use new taskpicker
        + '?SessionID=' + lngSessionID
            + '&Show_Contents=Yes'
                + '&Show_Favourites=Yes'
                    + '&Show_Search=Yes'
                        + '&Use_Order_Basket=No'
                            + '&DispensaryMode=1'
                                + '&RequestTypeFilter=' + document.body.getAttribute('treatmentplanrequesttype')
                                    + '&HideFilteredTypes=true';

    var strArgs = '<root singleitemonly="1" />'

    //30Jun2010 JMei F0040487 Passing the caller self and a xml message to modal dialog so that modal dialog can access its opener
    var objArgs = new Object();
    objArgs.opener = self;
    objArgs.Message = strArgs;
    if (window.dialogArguments == undefined)
    {
		objArgs.icwwindow = window.parent.ICWWindow();
    }
    else
    {
    	objArgs.icwwindow = window.dialogArguments.icwwindow;
    }

    var strNewItem_XML = window.showModalDialog(strURL, objArgs, strFeatures);

    //Deal with the items the user selected.
    //TaskPicker returns a blank string if the user cancels.
    if ((strNewItem_XML != '') && (strNewItem_XML != undefined)) {
        if (strNewItem_XML.indexOf('<saveok ') >= 0) {																					//18Jun05 AE  Removed the 'refresh' return value; now refreshes if anything has been saved
            //Item has been committed
            //Load the returned xml into our data island for parsing
            strNewItem_XML = '<batchentry>' + strNewItem_XML + '</batchentry>';
            void basketData.XMLDocument.loadXML(strNewItem_XML);

            //Now search to make sure that there is at least one 'template' type node
            //Can only be a single item since we are forcing the task picker into "nobasket" mode
            var xmlnode = basketData.XMLDocument.selectSingleNode('//item/saveok'); 											//21Jun05 AE  Read the id from the saveok node							
            var lngRequestID_Prescription = xmlnode.getAttribute("id");

            // Reload self
            RefreshGrid(lngRequestID_Prescription, 0);
            // Send refresh to Dispensing control
            RAISE_Dispensing_RefreshState(lngRequestID_Prescription, -5);
        }
        else {
            if (m_trSelected != null) {
                m_trSelected.focus();
            }
            else {
                document.getElementById("tbdy").focus();
            }

        }
    }
    else {
        if (m_trSelected != null) {
            m_trSelected.focus();
        }
        else {
            document.getElementById("tbdy").focus();
        }
    }
}

function ICWLocation(SessionID) {
    var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");
    var strURL = '../sharedscripts/AppSettingRead.aspx'
			  + '?SessionID=' + SessionID
			  + '&Setting=ICW_Location';
    var v11Location = '';

    objHTTPRequest.open("POST", strURL, false); //false = syncronous                              
    objHTTPRequest.send("");
    v11Location = objHTTPRequest.responseText;

    return v11Location;
}
