var m_intSessionID;
var m_strAttachToType;
var m_strID;
var m_strNoteType;
var m_strNoteGroupID;
var m_strNoteData;

function window_onload()
{
	if (document.getElementById('txtOrdersXML').value == '')
	{
		window.parent.SendOCSToolbarData();
	}
	else
	{
		var objTableDataElements = document.getElementsByName('tdToolbar');
		for (var index_td = 0; index_td < objTableDataElements.length; index_td++)
		{
			var objTableDataElement = objTableDataElements[index_td];
			var blnRequestComplete = (objTableDataElement.getAttribute('requestcomplete') == 'true');
			var objSelectElements = objTableDataElement.getElementsByTagName('select');
			for (var index_select = 0; index_select < objSelectElements.length; index_select++)
			{
				var objSelectElement = objSelectElements[index_select];
				if (blnRequestComplete && objSelectElement.getAttribute('notegroupname').toLowerCase() == 'administration')
				{
					objSelectElement.selectedIndex = -1;
					objSelectElement.disabled = true;
				}
				else
				{
					objSelectElement.disabled = false;
					SetCurrentNoteGroupSelection(objSelectElement);
				}
			}
		}
		window.parent.ToolbarReady();
	}
}

//------------------------------------------------------------------------------------------------------

function SetCurrentNoteGroupSelection(objSelectElement)
{
	var intSelectedGroupNote = 0;
	var objOptionElements = objSelectElement.getElementsByTagName('option');
	for (var index_option = 0; index_option < objOptionElements.length; index_option++)
	{
		var objOptionElement = objOptionElements[index_option];
		if (Number(objOptionElement.getAttribute('statusset')) == 1)
		{
			intSelectedGroupNote = index_option;
			break;
		}
		if (Number(objOptionElement.getAttribute('statusset')) == 2)
		{
			intSelectedGroupNote = -1;
			break;
		}
	}
	objSelectElement.selectedIndex = intSelectedGroupNote;
}

//------------------------------------------------------------------------------------------------------

function SetCurrentNoteButtonText(objButtonElement)
{
	var intStatusSet = Number(objButtonElement.getAttribute("statusset"));
	var objTableDataTextElement = objButtonElement.getElementsByTagName("td")[1];
	if (intStatusSet == 1)
	{
		objTableDataTextElement.innerText = objButtonElement.getAttribute("deactivateverb")
	}
	else
	{
		objTableDataTextElement.innerText = objButtonElement.getAttribute("applyverb")
	}
}

//------------------------------------------------------------------------------------------------------

function slcNoteGroup_onpropertychange(SelectElement)
{
	if (window.event.propertyName == 'selectedIndex')
	{
		var ButtonElement = SelectElement.parentNode.getElementsByTagName("button")[0];
		if (SelectElement.selectedIndex > -1)
		{
			ButtonElement.disabled = false;
		}
		else
		{
			ButtonElement.disabled = true;
		}
	}
}

//------------------------------------------------------------------------------------------------------

function SaveComplete(blnSuccess)
{
	//Fires when the save page has finished saving.  It contains
	//an XML Island which holds the details of the success / failiure
	//of each item in the 

	if (blnSuccess)
	{
		// refresh this page to update the buttons
		ClearStatusNoteCache();
		window.parent.SendOCSToolbarData();
	}
	else
	{
		//Just show the errors for now
		ShowSaveResults();
	}
}

//------------------------------------------------------------------------------------------------------

function NoteTypeToggle(objButton)
{
	// Add, enable, or disable a notetype to the current form item being edited
	window.parent.parent.returnValue = 'refresh';
	var strID = objButton.parentNode.getAttribute("ocsid");

	var SessionID = objButton.parentNode.parentNode.getAttribute("sessionid");
	var blnPendingMode = (objButton.parentNode.parentNode.getAttribute("pendingmode") == 'true');
	var allowDuplicates = objButton.getAttribute("allowDuplicates");
	var intStatusSet = Number(objButton.getAttribute("statusset"));

	if (!blnPendingMode && allowDuplicates == "False" && intStatusSet == 0)
	{
		//Lock Requests
		if (!LockRequests(SessionID, strID))
		{
			alert("The request selected is Locked via another terminal, please try again shortly.");
			window.parent.SendOCSToolbarData();
			return;
		}

		var existingNotes = GetExistingNoteIds(SessionID, objButton.getAttribute("notetypeid"), strID);
		if (existingNotes.length > 0)
		{
			alert("The request selected already has the note applied and does not allow duplicates.");
			UnlockRequests(SessionID, strID);
			window.parent.SendOCSToolbarData();
			return;
		}
	}

	var blnAuthenticate = (objButton.getAttribute("authenticate") == '1');
	var strPreconditionRoutine = objButton.getAttribute("precondition");
	var strAttachToType = objButton.parentNode.getAttribute("attachtotype");
	// authenticate user if required
	if (!ValidateUpdate(SessionID, blnPendingMode, blnAuthenticate, strPreconditionRoutine, strID, strAttachToType))
	{
		if (!blnPendingMode)
		{
			UnlockRequests(SessionID, strID);
		}
		return;
	}

	var intNoteID_Attached = Number(objButton.getAttribute("noteid_attached"));
	var strFormID = objButton.parentNode.getAttribute("formno");
	var strNoteType = objButton.getAttribute("notetype");

	if (intStatusSet == 1)
	{
		if (blnPendingMode)
		{
			//SC-07-0615 Remove the attached note from the "attachednotes" xml, previously this was not being removed and so could be added numerous times if clicked on and off
			RemovePendingNote(strFormID, strNoteType, objButton);
			SetCurrentNoteButtonText(objButton);
		}
		else
		{
			// Disable existing note type here
			fraSave.DisableAttachedNote(SessionID, strNoteType, strAttachToType, strID);
		}
	}
	else
	{
		var blnHasForm = (objButton.getAttribute('hasform') == 'true');
		var strNoteDataXML = '';
		var strTableName = objButton.getAttribute('tablename');

		if (blnHasForm)
		{
			//Show order entry 
			strNoteDataXML = ShowNoteForm(SessionID, strTableName);
		}
		if (!(strNoteDataXML == 'undefined' || strNoteDataXML == 'cancel'))
		{
			if (blnPendingMode)
			{
				if (strNoteDataXML == '')
				{
					strNoteDataXML = '<data></data>'
				}
				AttachPendingNote(strFormID, strNoteType, strNoteDataXML, objButton);
				SetCurrentNoteButtonText(objButton);
			}
			else
			{
				if (ValidateSaveFrame())
				{
					if (strAttachToType = "Request")
					{
						fraSave.AttachSystemNote(SessionID, strID, "", strNoteType, strNoteDataXML);
					}
					else
					{
						fraSave.AttachSystemNote(SessionID, "", strID, strNoteType, strNoteDataXML);
					}

					//Cache the data in case DSS checks fail and the user overrides the warnings
					m_intSessionID = SessionID;
					m_strAttachToType = strAttachToType;
					m_strID = strID;
					m_strNoteType = strNoteType;
					m_strNoteGroupID = '';
					m_strNoteData = strNoteDataXML;
				}
			}
		}
	}
	if (!blnPendingMode)
	{
		UnlockRequests(SessionID, strID);
	}
}


//------------------------------------------------------------------------------------------------------

function NoteGroupToggle(objButtonElement)
{
	window.parent.parent.returnValue = 'refresh';
	// Add, enable, or disable a notetype to the current form item being edited
	var objSpanElement = objButtonElement.parentNode;
	var objTableDataElement = objSpanElement.parentNode;
	var objTableRowElement = objTableDataElement.parentNode;
	var objSelectElement = objSpanElement.getElementsByTagName("select")[0];
	var objOptionElement = objSelectElement.options[objSelectElement.selectedIndex];

	var SessionID = objTableRowElement.getAttribute("sessionid");
	var blnPendingMode = (objTableRowElement.getAttribute("pendingmode") == 'true');
	var strAttachToType = objTableDataElement.getAttribute("attachtotype");
	var strID = objTableDataElement.getAttribute("ocsid");
	var strNoteGroupID = objSelectElement.getAttribute("notegroupid");
	var strNoteDataXML = '';

	if (!blnPendingMode)
	{
		if (!LockRequests(SessionID, strID))
		{
			alert("The request selected is Locked via another terminal, please try again shortly.");
			window.parent.SendOCSToolbarData();
			return;
		}
	}

	if (objOptionElement.id == 'optNoneText')
	{
		strNoteType = '';
	}
	else
	{
		var strNoteGroupName = objSelectElement.getAttribute("notegroupname");
		var strNoteType = objOptionElement.getAttribute('notetype')
		if (!ValidateNoteGroup(objTableDataElement, strNoteGroupName, strNoteType))
		{
			SetCurrentNoteGroupSelection(objSelectElement);
			if (!blnPendingMode)
			{
				UnlockRequests(SessionID, strID);
			}
			return;
		}

		var blnAuthenticate = (objOptionElement.getAttribute("authenticate") == '1');
		var strPreconditionRoutine = objOptionElement.getAttribute("precondition");
		if (!ValidateUpdate(SessionID, blnPendingMode, blnAuthenticate, strPreconditionRoutine, strID, strAttachToType))
		{
			SetCurrentNoteGroupSelection(objSelectElement);
			if (!blnPendingMode)
			{
				UnlockRequests(SessionID, strID);
			}
			return;
		}

		var strFormID = objTableDataElement.getAttribute("formno");
		var intNoteID_Attached = Number(objOptionElement.getAttribute("noteid_attached"));
		var blnHasForm = (objOptionElement.getAttribute('hasform') == 'true');
		var strTableName = objOptionElement.getAttribute('tablename');

		if (blnHasForm)
		{
			//Show order entry 
			strNoteDataXML = ShowNoteForm(SessionID, strTableName);
		}
	}

	if (!(strNoteDataXML == 'undefined' || strNoteDataXML == 'cancel'))
	{
		if (blnPendingMode)
		{
			if (strNoteDataXML == '')
			{
				strNoteDataXML = '<data></data>'
			}
			UpdatePendingGroupNote(strFormID, strNoteType, strNoteDataXML, objSelectElement, objOptionElement);
			SetCurrentNoteGroupSelection(objSelectElement);
		}
		else
		{
			if (strAttachToType = "Request")
			{
				fraSave.UpdateGroupNote(SessionID, strID, "", strNoteType, strNoteGroupID, strNoteDataXML);
			}
			else
			{
				fraSave.UpdateGroupNote(SessionID, "", strID, strNoteType, strNoteGroupID, strNoteDataXML);
			}

			//Cache the data in case DSS checks fail and the user overrides the warnings
			m_intSessionID = SessionID;
			m_strAttachToType = strAttachToType;
			m_strID = strID;
			m_strNoteType = strNoteType;
			m_strNoteGroupID = strNoteGroupID;
			m_strNoteData = strNoteDataXML;
		}
	}
	if (!blnPendingMode)
	{
		UnlockRequests(SessionID, strID);
	}
}

//---------------------------------------------------------------------------------

function AuthenticateUser(SessionID)
{
	var strURL = '../ICW/authenticatemodal.aspx'
				  	+ '?SessionID=' + SessionID

	var strFeatures = 'dialogHeight:250px;'
					+ 'dialogWidth:400px;'
					+ 'resizable:no;unadorned:no;'
					+ 'status:no;help:no;';

	strReturn = window.showModalDialog(strURL, '', strFeatures);
	if (strReturn == 'logoutFromActivityTimeout') {
		window.returnValue = 'logoutFromActivityTimeout';
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	return strReturn;
}

//---------------------------------------------------------------------------------

function ValidateNoteGroup(TableDataElement, strNoteGroupName, strNoteType)
{
	if (strNoteGroupName.toLowerCase() == 'administration' && (strNoteType.toLowerCase() == 'selfadmin' || strNoteType.toLowerCase() == 'homeadmin'))
	{
		if (TableDataElement.getAttribute("inprogress") == 'true')
		{
			var strFeatures = 'dialogHeight:250px;'
					+ 'dialogWidth:500px;'
					+ 'resizable:no;'
					+ 'status:no;help:no;';
			var strMessage = '\nThe infusion "' + objSelectedItems[index].getAttribute("detail")
					+ '" is recorded as being "In Progress" and its status cannot be changed to Self Administration or Home Administration.\n\n'
					+ 'If this is recorded in error, use the Drug Administration Module to record that the infusion has ended.'
			Popmessage(strMessage, 'Warning!', strFeatures)
			return false;
		}
		return true;
	}
	else
	{
		return true;
	}
}

//---------------------------------------------------------------------------------

function ValidateUpdate(SessionID, blnPendingMode, blnAuthenticate, strPreconditionRoutine, strID, strBaseType)
{
	// authenticate user if required
	if (blnAuthenticate)
	{
		// if our user did not authenticate then simply return.
		if (AuthenticateUser(SessionID) != 'Valid')
		{
			return false;
		}
	}
	// fire custom precondition routine if required
	if (!(strPreconditionRoutine == null || strPreconditionRoutine == ""))
	{
		if (blnPendingMode && strBaseType != 'pending')
		{
			// New item that has not yet been saved anywhere.
			var strURL = '../OrderEntry/PreconditionRoutine.aspx?SessionID=' + SessionID + '&ItemIDList=-1&BaseType=pending&Routine=' + strPreconditionRoutine;
		}
		else
		{
			var strURL = '../OrderEntry/PreconditionRoutine.aspx?SessionID=' + SessionID + '&ItemIDList=' + strID + '&BaseType=' + strBaseType + '&Routine=' + strPreconditionRoutine;
		}

		var myobjHTTPRequest = new ActiveXObject("Msxml2.XMLHTTP"); 							//Create the object
		myobjHTTPRequest.open("GET", strURL, false); 										//false = syncronously
		myobjHTTPRequest.send(); 															//Send the request syncronously

		//if we've got something back then we need to display this in a confirm dialog
		if (myobjHTTPRequest.responseText != "")
		{
			//if user presses CANCEL then we simply return
			if (!confirm(myobjHTTPRequest.responseText))
			{
				return false;
			}
		}
	}
	return true;
}

//---------------------------------------------------------------------------------

function ValidateSaveFrame()
{
	var strMsg = '';
	if (document.all['fraSave'] == undefined)
	{
		strMsg = 'the required HTML element "fraSave" is missing from the page.';
	}
	else
	{
		if (fraSave.AttachSystemNote == undefined)
		{
			strMsg = 'the method "AttachSystemNote()" is missing.';
		}
	}

	if (strMsg != '')
	{
		alert('Cannot save approval note: ' + strMsg);
		return false;
	}
	else
	{
		return true;
	}
}

//---------------------------------------------------------------------------------

function ShowNoteForm(SessionID, strNoteTableName)
{
	//Show the note form for editing
	var strURL = '../NotesEditor/EditNote.aspx'
				  + '?SessionID=' + SessionID
				  + '&NoteID=-1'
				  + '&TableName=' + strNoteTableName;

	var strFeatures = 'dialogHeight:600px;'
				 + 'dialogWidth:800px;'
				 + 'resizable:no;unadorned:no;'
				 + 'status:no;help:no;';

	return
	var ret = window.showModalDialog(strURL, '', strFeatures);
	if (ret == 'logoutFromActivityTimeout') {
		ret = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}


//---------------------------------------------------------------------------------

function AttachPendingNote(strFormID, strNoteType, strNoteDataXML, objElement)
{
	//Save the note
	var xmlnodeAttachedNotes = GetOrdersAttachedNotesNode(strFormID);
	var xmldoc = new ActiveXObject("MSXML2.DOMDocument");
	var strXML = '<attachednote type="' + strNoteType + '">'
					  + strNoteDataXML
					  + '</attachednote>';
	xmldoc.loadXML(strXML);
	xmlnodeAttachedNotes.appendChild(xmldoc.firstChild);
	objElement.setAttribute("isapplied", "1");
	objElement.setAttribute("noteid_attached", "9999");
	//Set StatusSet
	//24-Feb-09 Rams F0046339
	objElement.setAttribute("statusset", "1");
}


//---------------------------------------------------------------------------------

function RemovePendingNote(strFormID, strNoteType, objElement)
{
	//Delete the note
	var xmlattachednotes = GetOrdersAttachedNotesNode(strFormID);
	var xmlattachednote = xmlattachednotes.selectSingleNode("attachednote[@type='" + strNoteType + "']");
	if (xmlattachednote != null)
	{
		xmlattachednotes.removeChild(xmlattachednote);
	}
	objElement.setAttribute("isapplied", "0");
	objElement.setAttribute("noteid_attached", "0");
	//Remove StatusSet
	//24-Feb-09 Rams F0046339
	objElement.setAttribute("statusset", "0");
}


//---------------------------------------------------------------------------------

function UpdatePendingGroupNote(strFormID, strNoteType, strNoteDataXML, objSelectElement, objSelectedOptionElement)
{
	var objOptionElements = objSelectElement.getElementsByTagName('option');
	for (var index_option = 0; index_option < objOptionElements.length; index_option++)
	{
		var objOptionElement = objOptionElements[index_option];
		if (objOptionElement.getAttribute('id') != 'optNoneText')
		{
			RemovePendingNote(strFormID, objOptionElement.getAttribute("notetype"), objOptionElement);
		}
	}
	if (objSelectedOptionElement.getAttribute('id') != 'optNoneText')
	{
		AttachPendingNote(strFormID, strNoteType, strNoteDataXML, objSelectedOptionElement);
	}
}

//---------------------------------------------------------------------------------

function GetOrdersAttachedNotesNode(lngFormNo)
{
	// Return/create the "attachednote" node form the OrdersXML island
	var xmldocOrders = window.parent.document.getElementById("ordersXML").XMLDocument;
	var xmlnodeItem = xmldocOrders.selectNodes("//item")(lngFormNo);
	var xmlnodeAttachedNotes = xmlnodeItem.selectSingleNode("attachednotes");
	if (xmlnodeAttachedNotes == null)
	{
		//SC-07-0615   First check if there are any attached notes that have been loaded for this item
		var xmldoc = document.getElementById("AttachedNotesXML").XMLDocument;
		var xmlitem = xmldoc.documentElement.selectSingleNode("item[@formidx='" + lngFormNo + "']")
		if (xmlitem == null)
		{
			xmlnodeAttachedNotes = xmlnodeItem.appendChild(xmldocOrders.createElement("attachednotes"));
		}
		else
		{
			// F0056477 ST 22Jun09 Check to see if the xml is valid before we try to append the data.
			if (xmlitem.selectSingleNode("attachednotes") != null)
				xmlnodeAttachedNotes = xmlnodeItem.appendChild(xmlitem.selectSingleNode("attachednotes"));
		}
	}
	return xmlnodeAttachedNotes;
}

//---------------------------------------------------------------------------------

function MergeStatusNotesIntoFormData(xmldocSave)
{
	//SC-07-0615 change to pick up all items not just top-level items
	//var xmlnodelist = xmldocSave.selectNodes("save/item");
	var xmlnodelist = xmldocSave.selectNodes("//item");
	var colNotes;
	var idx = 0;
	var intForm = 0;
	if (xmldocSave.selectSingleNode("//shared") != null) //LM 17/01/2008 Code 162 Added this code
	{
		// forms start at 1 when shared page exists
		intForm = 1;
	}

	for (var intData = 0; intData < xmlnodelist.length; intData++, intForm++) //LM 17/01/2008 Code 162 
	{
		xmlnodeData = xmlnodelist[intData];
		xmlnodeItem = xmlnodeData.firstChild;

		xmlnodeAttachedNotes = GetOrdersAttachedNotesNode(intForm);

		//	24Sep07 ST  Commented out and changed as it would seem to clearing the original item notes
		//				i.e. the change report
		//  08Oct07 CJM Uncommented (and commented out below) - changed to append new notes to the saved notes rather than replace them
		if (xmlnodeAttachedNotes != null)
		{
			//  Check if the save XML already has an attached note
			var xmlnodeSaveAttachedNotes = xmlnodeItem.selectSingleNode("attachednotes");
			if (xmlnodeSaveAttachedNotes != null)
			{
				//xmlnodeItem.replaceChild(xmlnodeAttachedNotes, xmlnodeSaveAttachedNotes);
				for (var x = 0; x < xmlnodeAttachedNotes.childNodes.length; x++)
				{
					xmlnodeSaveAttachedNotes.appendChild(xmlnodeAttachedNotes.childNodes[x].cloneNode(true));
				}
			} else
			{
				xmlnodeItem.appendChild(xmlnodeAttachedNotes);
			}
		}
	}
}

//---------------------------------------------------------------------------------

function ShowSaveResults()
{
	var iFrame = window.parent.document.all['fraOCSToolbar'];

	iFrame.style.top = 0;
	iFrame.style.left = 0;
	iFrame.style.height = window.parent.document.body.offsetHeight;
	iFrame.style.width = window.parent.document.body.offsetWidth;
	iFrame.style.position = 'absolute';

	void DisplaySaveResults(document.all['fraSave'], 0, 0, document.body.offsetWidth, document.body.offsetHeight - 5);
}

//---------------------------------------------------------------------------------

function SetXmlData(intCurrentFormNo, strOrdersXML, strStatusNotefilterXML)
{
	document.getElementById("txtOrdersXML").value = strOrdersXML;
	document.getElementById("txtStatusFilterXML").value = strStatusNotefilterXML;
	document.getElementById("txtCurrentFormNo").value = intCurrentFormNo;
	frmXML.submit();
}

//---------------------------------------------------------------------------------

function ClearStatusNoteCache()
{
	//Clear the cache
	m_intSessionID = -1;
	m_strClass = '';
	m_strSelectedItemIDs = '';
	m_strNoteType = '';
	m_strNoteGroupID = '';
	m_strNoteData = '';
}

//---------------------------------------------------------------------------------

function DssResults_onClick(Override)
{
	var DSSLogResults = document.frames['fraSave'].document.all['dsslogresults'].xml;
	var iFrame = window.parent.document.all['fraOCSToolbar'];
	iFrame.style.top = '';
	iFrame.style.left = '';
	iFrame.style.height = '';
	iFrame.style.width = '';
	iFrame.style.position = '';

	var intSessionID = m_intSessionID;
	var strAttachToType = m_strAttachToType;
	var strID = m_strID;
	var strNoteType = m_strNoteType;
	var strNoteGroupID = m_strNoteGroupID;
	var strNoteData = m_strNoteData;
	ClearStatusNoteCache();
	if (Override && m_strID != '')
	{
		if (strNoteGroupID == '')
		{
			if (strAttachToType = "Request")
			{
				fraSave.AttachSystemNote(intSessionID, strID, "", strNoteType, strNoteData, true, DSSLogResults);
			}
			else
			{
				fraSave.AttachSystemNote(intSessionID, "", strID, strNoteType, strNoteData, true, DSSLogResults);
			}
		}
		else
		{
			if (strAttachToType = "Request")
			{
				fraSave.UpdateGroupNote(intSessionID, strID, "", strNoteType, strNoteGroupID, strNoteData, true, DSSLogResults);
			}
			else
			{
				fraSave.UpdateGroupNote(intSessionID, "", strID, strNoteType, strNoteGroupID, strNoteData, true, DSSLogResults);
			}
		}
	}
}

//---------------------------------------------------------------------------------

function PostServerMessage(url, data)
{
	var result;
	$.ajax({
		type: "POST",
		url: url,
		data: data,
		contentType: "application/json; charset=utf-8",
		dataType: "json",
		async: false,
		success: function(msg)
		{
			result = msg;
		}
	});
	return result;
}

//---------------------------------------------------------------------------------

function LockRequests(sessionId, requestIds)
{
	var url = "../WorklistHelper/worklistHelper.aspx/LockRequests"
	var sendData = "{'sessionId': '" + sessionId + "', 'requestIds': '" + requestIds + "' }";
	var returnData = PostServerMessage(url, sendData);
	if (returnData == null || returnData == undefined)
	{
		return null;
	}
	return returnData.d;
}

//---------------------------------------------------------------------------------

function UnlockRequests(sessionId, requestIds)
{
	var url = "../WorklistHelper/worklistHelper.aspx/UnlockRequests"
	var sendData = "{'sessionId': '" + sessionId + "', 'requestIds': '" + requestIds + "' }";
	var returnData = PostServerMessage(url, sendData);
	if (returnData == null || returnData == undefined)
	{
		return null;
	}
	return returnData.d;
}

//---------------------------------------------------------------------------------

function GetExistingNoteIds(sessionId, noteTypeId, requestIds)
{
	var url = "../WorklistHelper/worklistHelper.aspx/GetExistingNoteIds"
	var sendData = "{'sessionId': '" + sessionId + "', 'noteTypeId': '" + noteTypeId + "', 'baseType': 'Request', 'typeIds': '" + requestIds + "' }";
	var returnData = PostServerMessage(url, sendData);
	if (returnData == null || returnData == undefined)
	{
		return [];
	}
	return returnData.d;
}