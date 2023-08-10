function page_onload()
{
	if(document.body.getAttribute("limitselection") == "True")
	{
		SetItemsDefaultState_Limited();
	}
	else
	{
		SetItemsDefaultState();
	}
	
	HideUnusedColumns();
}

//
// Fires when the OK button is clicked on the dialog
//
function btnOK_onclick()
{

	// perform a quick scan to see if anything is checked
	if(AnythingToProcess() == false)
	{
		window.returnValue = 'cancel';
		window.close();
		return;
	}

	var strData_XML = GatherFormData();
	
	var SessionID = document.body.getAttribute("sid");
	var objHTTPRequest = new ActiveXObject("Microsoft.XMLHTTP");                                      

	var strURL = '../sharedscripts/SessionAttribute.aspx'
				  + '?SessionID=' + SessionID
				  + '&Mode=set'
				  + '&Attribute=' + "OrderEntry/StopOrders";

	objHTTPRequest.open("POST", strURL, false);	//false = syncronous                              
	objHTTPRequest.send(strData_XML);
	objHTTPRequest.responseText;

	window.returnValue = 'ok';
	window.close();
}

//
// Fires when the CANCEL button is clicked on the dialog
//
function btnCancel_onclick()
{
	window.returnValue = 'cancel';
	window.close();
}

//
//
//
function CloseDialog()
{
	// generally caused because the user has clicked on the 'x' on the dialog or done alt+f4
	if(window.returnValue == undefined)
	{
		// so we set the return value to 'cancel' to exit gracefully
		window.returnValue = 'cancel';
	}
}


function IsItemChecked(dbid)
{
	var colItems = document.getElementsByName("check");
	var idx;
	
	for(idx = 0; idx < colItems.length; idx++)
	{
		if(colItems[idx].getAttribute("dbid") == dbid && colItems[idx].checked)
		{
			return true;
		}
	}
	return false;
}



//
// Fires when we click on an orderset checkbox
// Goes through the child nodes and checks their boxes according to the orderset checkbox
//
function orderset_onclick_limited(objSrc)
{
	var colItems = document.getElementsByName("check");
	var dbid = objSrc.getAttribute("dbid");
	var idx;
	var items;
	var disabledcount = 0;
	var blnUncheckOrderset = false;
	var blnRequestsChecked = false;

	for(idx = 0; idx < colItems.length; idx++)
	{
		if(colItems[idx].getAttribute("dbid_parent") == dbid)
		{
			if(objSrc.checked)
			{
			    if (colItems[idx].getAttribute("complete") != "True")
			    {
			        colItems[idx].checked = true;
			    }
			}
			else
			{
			    if (colItems[idx].getAttribute("complete") != "True") 
			    {
			        colItems[idx].checked = false;
			    }
			}
		}
			
		if(colItems[idx].disabled)
		{
			blnUncheckOrderset = true;
		}
	}
}

//
// Backup copy of the original function
// Must revert back to this once design has been finalised.
function orderset_onclick(objSrc)
{

	var colItems = document.getElementsByName("check");
	var dbid = objSrc.getAttribute("dbid");
	var idx;
	var items;
	var disabledcount = 0;
	var blnUncheckOrderset = false;
	var blnRequestsChecked = false;

	for (idx = 0; idx < colItems.length; idx++)
	{
		if (colItems[idx].getAttribute("dbid_parent") == dbid)
		{
			/*
			// if this is a note type then we need to check if any items
			// in this orderset are disabled - if there are then the note
			// cannot be checked.
			if(colItems[idx].getAttribute("ocstype") == "note")
			{
				for(items = 0; items < colItems.length; items++)
				{
					if(colItems[items].getAttribute("dbid_parent") == dbid)
					{
						if(colItems[items].disabled == true)
						{
							disabledcount++;
						}
				}
			}
				
			// if we don't have any disabled items then allow the note to be checked.
			if(disabledcount == 0)
			{
				if(objSrc.checked)
				{
					colItems[idx].checked = true;
				}
				else
				{
					colItems[idx].checked = false;
				}
			}
			else
			{
				disabledcount = 0;
			}
			}
			else
			{
			*/
			if (colItems[idx].disabled != true)
			{
				if (objSrc.checked)
				{
					colItems[idx].checked = true;
				}
				else
				{
					colItems[idx].checked = false;
				}
			}
			//}

			/*
			if(colItems[idx].disabled)
			{
			blnUncheckOrderset = true;
			}
			*/
		}
	}

	// uncheck the orderset if any of our items are complete
	if (blnUncheckOrderset)
	{

		// objSrc.checked = false;  07Jan09 PH Prevent unticking of Orderset, so that an Orderset is cancelled when all the child items are cancelled.

		// as we've now unchecked the orderset we need to make sure we don't have notes and requests checked
		// so uncheck the note types.
		//for(idx = 0; idx < colItems.length; idx++)
		//{
		//	if(colItems[idx].getAttribute("dbid_parent") == dbid)
		//	{
		//		if(colItems[idx].getAttribute("ocstype") != "note" && colItems[idx].checked == true)
		//		{
		//			blnRequestsChecked = true;
		//		}
		//	}
		//}

		//if(blnRequestsChecked)
		//{
		//	for(idx = 0; idx < colItems.length; idx++)
		//	{
		//		if(colItems[idx].getAttribute("dbid_parent") == dbid)
		//		{
		//			if(colItems[idx].getAttribute("ocstype") == "note")
		//			{
		//				colItems[idx].checked = false;
		//			}
		//		}
		//	}
		//}
	}
}



//
// Fires when an orderset item is clicked
//
function ordersetitem_onclick(objSrc)
{
	var colItems = document.getElementsByName("check")
	var dbid_parent = objSrc.getAttribute("dbid_parent");
	var parentItem = GetParentFromChild(objSrc);
	var itemState = objSrc.checked;			// Gets the current state of this item
	var idx;

	// If we uncheck an item then we also need to uncheck the parent orderset item if it exists
	if(objSrc.checked == false)
	{
		parentItem.checked = false;
	}
	
	// Cycle through our items and find items that belong in this orderset,
	// count the number of checked and unchecked items and count the total
	// number of items.
	parentItem.checked = true;
	
	for (idx = 0; idx < colItems.length; idx++)
	{
	    if (colItems[idx].getAttribute("dbid_parent") == dbid_parent)
	    {
	        if (colItems[idx].disabled == false && colItems[idx].checked == false)
	        {
	            parentItem.checked = false;
	            return;
	        }
	    }
	}
}


function item_onclick(objSrc)
{
	var colItems = document.getElementsByName("check");
	var dbid = objSrc.getAttribute("dbid");
	var idx;
	
//	if(objSrc.checked == true)
//	{
//		if(objSrc.getAttribute("ocstype") == "note")
//		{
//			for(idx = 0; idx < colItems.length; idx++)
//			{
//				if(colItems[idx].getAttribute("dbid") != dbid && colItems[idx].getAttribute("ocstype") != "note")
//				{
//					if(colItems[idx].checked)
//					{
//						if(colItems[idx].getAttribute("dbid_parent") > 0)
//						{
//							if(GetParentFromChild(colItems[idx]).checked == false)
//							{
//								objSrc.checked = false;
//								alert('Notes cannot be selected at the same time as requests.');
//								return false;
//							}
//						}
//						else
//						{
//							objSrc.checked = false;
//							alert('Notes cannot be selected at the same time as requests.');
//							return false;
//						}
//					}
//				}
//			}
//		}
//		else
//		{
//			for(idx = 0; idx < colItems.length; idx++)
//			{
//				if(colItems[idx].getAttribute("dbid") != dbid && colItems[idx].getAttribute("ocstype") == "note")
//				{
//					if(colItems[idx].checked)
//					{
//						if(colItems[idx].getAttribute("dbid_parent") > 0)
//						{
//							if(GetParentFromChild(colItems[idx]).checked == false)
//							{
//								objSrc.checked = false;
//								alert('Requests cannot be selected at the same time as notes.');
//								return false;
//							}
//						}
//						else
//						{
//							objSrc.checked = false;
//							alert('Requests cannot be selected at the same time as notes.');
//							return false;
//						}
//					}
//				}
//			}
//		}
//	}
}



//
// Returns the parent checkbox for our child checkbox
//
function GetParentFromChild(objSrc)
{
	var colItems = document.getElementsByName("check");
	var dbid = objSrc.getAttribute("dbid");
	var idx;
	
	for(idx = 0; idx < colItems.length; idx++)
	{
		if(colItems[idx].getAttribute("dbid") == objSrc.getAttribute("dbid_parent"))
		{
			return colItems[idx];
		}
	}
	return null;
}

//
// Copy of original function that limits scope of application.
// This should revert back to original version once design has been finalised.
//
function SetItemsDefaultState_Limited()
{
	var colItems = document.getElementsByName("check");
	var idxItems;
	var idx;
	var items;
	var dbid;
	var disabledcount = 0;
	var prescriptioncount = 0;
	var prescriptioncompletecount = 0;

	for(idx = 0; idx < colItems.length; idx++)
	{
		if(colItems[idx].getAttribute("requesttype") == "Order set")
		{
			dbid = colItems[idx].getAttribute("dbid");
			colItems[idx].checked = true;
			
			for(idxItems = 0; idxItems < colItems.length; idxItems++)
			{
				if(colItems[idxItems].getAttribute("dbid_parent") == dbid)
				{
				    if (colItems[idxItems].getAttribute("complete") != "True") 
				    {
				        colItems[idxItems].checked = true;
				    } else {
				        prescriptioncompletecount++;
				    }
				    prescriptioncount++;    
  
				    colItems[idxItems].disabled = true;
					
				}
			}
			//F0086322 14May10 JMei uncheck and disable order set item if all items under are completed
			if ((prescriptioncount == prescriptioncompletecount) && (prescriptioncompletecount != 0)) {
			    colItems[idx].checked = false;
			    colItems[idx].disabled = true;
			}
		
		}
		else
		{
			if(colItems[idx].getAttribute("dbid_parent") == "-1")
			{
				if(colItems[idx].disabled == false)
				{
					colItems[idx].checked = true;
				}
			}
		}
	}
}


//
// Fired from page onload, this cycles through the check boxes and picks up the
// ordersets, checks them and then fires the orderset onclick routine.
//
function SetItemsDefaultState()
{
	var colItems = document.getElementsByName("check");
	var idxItems;
	var idx;
	var items;
	var dbid;
	var disabledcount = 0;
	var prescriptioncount = 0;
	var prescriptioncompletecount = 0;
	
	for(idx = 0; idx < colItems.length; idx++)
	{
		if(colItems[idx].getAttribute("requesttype") == "Order set")
		{
			dbid = colItems[idx].getAttribute("dbid");
			colItems[idx].checked = true;
			
			for(idxItems = 0; idxItems < colItems.length; idxItems++)
			{
				if(colItems[idxItems].getAttribute("dbid_parent") == dbid) {

				    //F0086322 14May10 JMei uncheck and disable order set item if all items under are completed
				    if (colItems[idxItems].getAttribute("complete") == "True") {
				        prescriptioncompletecount++;
				    }
				    prescriptioncount++;    
				    
					if(colItems[idxItems].getAttribute("ocstype") == "note")
					{
						for(items = 0; items < colItems.length; items++)
						{
							if(colItems[items].getAttribute("dbid_parent") == dbid)
							{
								if(colItems[items].disabled == true)
								{
									disabledcount++;
								}
							}
						}
				
						// if we don't have any disabled items then allow the note to be checked.
						if(disabledcount == 0)
						{
							colItems[idxItems].checked = true;
						}
						else
						{
							colItems[idx].checked = false;
							disabledcount = 0;
						}
					}
					else
					{
						if(colItems[idxItems].disabled != true)
						{
							colItems[idxItems].checked = true;
						}
					}
				}
            }
			
			//F0086322 14May10 JMei uncheck and disable order set item if all items under are completed
			if ((prescriptioncount == prescriptioncompletecount) && (prescriptioncompletecount != 0)) {
			    colItems[idx].checked = false;
			    colItems[idx].disabled = true;
			}
			//colItems[idx].checked = true;
			//orderset_onclick(colItems[idx]);
		}
		else
		{
			if(colItems[idx].getAttribute("dbid_parent") == "-1")
			{
				if(colItems[idx].disabled == false)
				{
					colItems[idx].checked = true;
				}
			}
		}
	}
}

//
//
//
function HideUnusedColumns()
{
	HideAdministrationColumns();
	HideDispensingColumns();
	HideStatusColumns();
}

function HideAdministrationColumns()
{
	var colItems = document.getElementsByName("Administration");
	var idx;
	var blnFailed = false;
	
	for(idx = 0; idx < colItems.length; idx++)
	{
		if(colItems[idx].innerHTML != "")
		{
			blnFailed = true;
		}
	}
	
	if(blnFailed == false)
	{
		for(idx = 0; idx < colItems.length; idx++)
		{
			colItems[idx].style.visibility = "hidden";
		}
	}
}

function HideDispensingColumns()
{
	var colItems = document.getElementsByName("Dispensing");
	var idx;
	var blnFailed = false;
	
	for(idx = 0; idx < colItems.length; idx++)
	{
		if(colItems[idx].innerHTML != "" )
		{
			blnFailed = true;
		}
	}
	
	if(blnFailed == false)
	{
		for(idx = 0; idx < colItems.length; idx++)
		{
			colItems[idx].style.visibility = "hidden";
		}
	}
}

function HideStatusColumns()
{
	var colNotes;
	var colItems;
	var idx;
	var idxNotes;
	var blnFailed;
	var strNoteType;
	
	var colNotes = statusnotesXML.selectNodes("root/requesttypestatusnote");
	
	for(idxNotes = 0; idxNotes < colNotes.length; idxNotes++)
	{
		strNoteType = colNotes[idxNotes].getAttribute("NoteType").replace(" ", "_x0020_");
		colItems = document.getElementsByName(strNoteType);
		blnFailed = false;
		
		for(idx = 0; idx < colItems.length; idx++)
		{
			if(colItems[idx].innerHTML != "")
			{
				blnFailed = true;
			}
		}
		
		if(blnFailed == false)
		{
		    for (idx = 0; idx < colItems.length; idx++) {
		        //F0055544 ST 15Jun09   Under some circumstances with status note names the check boxes are getting hidden from view
		        //Added this check to prevent this from happening
		        if (colItems[idx].type != "checkbox")
		            colItems[idx].style.visibility = "hidden";
		    }
		}
		blnFailed = false;
	}
}

function NotesChecked(objSrc)
{
	var colItems = document.getElementsByName("check");
	var idx;
	
	for(idx = 0; idx < colItems.length; idx++)
	{
		if(colItems[idx].getAttribute("ocstype") == "note")
		{
			if(colItems[idx].checked == true)
			{
				if(colItems[idx].getAttribute("dbid") != objSrc.getAttribute("dbid"))
				{
					return true;
				}
			}
		}
	}
	return false;
}

function RequestsChecked(objSrc)
{
	var colItems = document.getElementsByName("check");
	var idx;
	
	for(idx = 0; idx < colItems.length; idx++)
	{
		if(colItems[idx].getAttribute("ocstype") != "note")
		{
			if(colItems[idx].checked == true)
			{
				if(colItems[idx].getAttribute("dbid") != objSrc.getAttribute("dbid"))
				{
					return true;
				}
			}
		}
	}
	return false;
}

//
// Opens a modal dialog window with details of the administrations for this item
//
function AdministrationRecord(SessionID, RequestID)
{
	var strReturn = "";
	var strFeatures = 'dialogHeight:600px; dialogWidth:800px; resizable:no;unadorned:no; status:no;help:no;';
	var strURL = '../OrderEntry/AdministrationRecord.aspx'
				  + '?SessionID=' + SessionID
				  + '&RequestID=' + RequestID;

	strReturn = window.showModalDialog(strURL, '', strFeatures);
	if (strReturn == 'logoutFromActivityTimeout') {
		strReturn = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}

//
// Opens a modal dialog window with details of the dispensings for this item
//
function DispensingRecord(SessionID, RequestID)
{
	var strReturn = "";
	var strFeatures = 'dialogHeight:600px; dialogWidth:800px; resizable:no;unadorned:no; status:no;help:no;';
	var strURL = '../OrderEntry/DispensingRecord.aspx'
				  + '?SessionID=' + SessionID
				  + '&RequestID=' + RequestID;

	strReturn = window.showModalDialog(strURL, '', strFeatures);
	if (strReturn == 'logoutFromActivityTimeout') {
		strReturn = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

}

//
// Cycles through the checkboxes and determines if any are checked
//
function AnythingToProcess()
{
	var colItems = document.getElementsByName("check");
	var idx;
	for(idx = 0; idx < colItems.length; idx++)
	{
		if(colItems[idx].checked)
		{
			return true;
		}
	}
	return false;
}

//
// Gathers the data from the form
//
function GatherFormData()
{
	var colItems = document.getElementsByName("check");
	var idx;
	var strXML;
	var blnOrderSetOpen = false;
	var lngLastParent = -1;
	var strAction = document.body.getAttribute("action").toLowerCase();

	strXML = "<cancel>";
	for (idx = 0; idx < colItems.length; idx++)
	{
		if (colItems[idx].checked)
		{
			// We close an open order set if, a) one is already open, AND b) this item is either a new orderset OR item not in an orderset
			if (blnOrderSetOpen && (colItems[idx].getAttribute("requesttype") == "Order set" || colItems[idx].getAttribute("dbid_parent") != lngLastParent))
			{
				strXML += '</item>';
				blnOrderSetOpen = false;
			}

			if ( !(colItems[idx].getAttribute("requesttype") == "Order set" && strAction == "amend" && colItems[idx].getAttribute("partialcomplete").toLowerCase() == "true") )
			{
				// Append then current item, leaving it open in case it's the start of a new orderset
				strXML += '<item';
				strXML += ' class="' + colItems[idx].getAttribute("itemclass") + '"';
				strXML += ' id="' + colItems[idx].getAttribute("dbid") + '"';
				strXML += ' description="' + ReplaceString(colItems[idx].getAttribute("description"), '&', '_amp_') + '"';
				strXML += ' detail="' + ReplaceString(colItems[idx].getAttribute("detail"), '&', '_amp_') + '"';
				strXML += ' tableid="' + colItems[idx].getAttribute("tableid") + '"';
				strXML += ' productid="' + colItems[idx].getAttribute("productid") + '"';
				strXML += ' ocstype="' + colItems[idx].getAttribute("ocstype") + '"';
				strXML += ' ocstypeid="' + colItems[idx].getAttribute("ocstypeid") + '"';
				strXML += ' autocommit="' + colItems[idx].getAttribute("autocommit") + '"';
				strXML += ' parentid="' + colItems[idx].getAttribute("dbid_parent") + '"';
				strXML += '>';

				if (colItems[idx].getAttribute("requesttype") == "Order set")
				{
					// Current item IS an orderset
					blnOrderSetOpen = true;
					lngLastParent = colItems[idx].getAttribute("dbid");
				}
				else
				{
					// Current item is NOT and orderset, so close off the end if this individual item
					strXML += '</item>';
					lngLastParent = colItems[idx].getAttribute("dbid_parent");
				}
			}

		}
	}

	// We're at the end, so close of an open orderset, if there is one
	if (blnOrderSetOpen)
	{
		strXML += '</item>';
	}

	strXML += "</cancel>";
	return strXML;
}	

