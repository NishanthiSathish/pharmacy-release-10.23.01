//--------------------------------------------------------------------------------------------------
//
//											RoutineSearch.js
//
//	Shared script to partner RoutineSearch.vb.  This handles the client-side
//	functions, including calling the server to actually perform the search
//
//	Modification History:
//	07Apr04 AE  Extracted code from PH's RoutineSearch.aspx for shared use
//	31Aug04 AE  btnClear_onclick(); Corrected to use the following generic method.
//  31Jan06 ST  ClearInputs(); Added code to clear values from lookup input boxes
//
//--------------------------------------------------------------------------------------------------

function SetSearchButtonState()
{
	//document.getElementById("btnSearch").disabled = AreInputsClear();
}
//--------------------------------------------------------------------------------------------------
function btnSearch_onclick()
{
	Search();
}
//--------------------------------------------------------------------------------------------------
function Search()
{
	if ( ValidateInputs() )
	{
		document.getElementById("btnSearch").disabled = true;
		if (document.getElementById("btnEdit") != undefined) {				//10Mar03 AE  Added; btnEdit may not be scripted, depending on security
			document.getElementById("btnEdit").disabled = true;
		}

		document.getElementById("spnMsg").style.fontWeight = "bold";
		document.getElementById("spnMsg").style.fontSize = '12pt';
		document.getElementById("spnMSg").style.color = "red";
		document.getElementById("spnMsg").innerText = "Searching...";
		if(document.title != "Routine Execute") {

		    if (document.getElementById("txtParamCount") != undefined) {
		        var paramCount = document.getElementById("txtParamCount").getAttribute("value");
		        for (var i = 0; i < paramCount; i++) {
		            var colObj = document.getElementById("col" + i);
		            if (colObj != undefined && document.getElementById("type" + i) != undefined) {
		                var paramVal = colObj.getAttribute("value");
		                var descObj = document.getElementById("type" + i);
		                var paramDesc = descObj.getAttribute("value");

		                void document.frames["fraSaveState"].SetStateGeneric(paramVal);
		            }
		        }

		        document.getElementById('frmRoutineSearch').setAttribute('action', ActionURL());
		    }
		}
		if (document.getElementById("txtMode") != undefined) 
        {
		    document.getElementById("txtMode").setAttribute("value", "Submit");
		}

		frmRoutineSearch.submit();
    }
}
//--------------------------------------------------------------------------------------------------
function btnClear_onclick()
{
	//window.parent.Clear();										//31Aug04 AE  Corrected to use the following generic method.
	void ClearInputs();
}
//--------------------------------------------------------------------------------------------------
function ClearInputs()
{
    //var intCount = Number(document.getElementById("txtParamCount").value);
    var intCount = 0;
    var objControl;

    if (document.getElementById("txtParamCount") != undefined) {
        intCount = Number(document.getElementById("txtParamCount").value);
    }
	
	for ( var intIndex=0; intIndex<intCount; intIndex++ )
	{
	    objControl = document.getElementById("col" + intIndex);

	    if (objControl != null) {
	        switch (objControl.getAttribute("type")) {
	            case "checkbox":
	                objControl.checked = false;
	                break;
	            case "text":
	                objControl.value = "";
	                break;
	        }
	    }
		
	    // 31Jan06 ST  Clear lookup input box values
	    objControl = document.getElementById("desc"+intIndex);
	    if(objControl != null)
	    {
	        objControl.value = "";
	    }
	}

	SetSearchButtonState();

//	if (intCount>0)
//	{
//		document.getElementById("col0").focus();
//	}
}

//--------------------------------------------------------------------------------------------------

function AreInputsClear()
{
    //var intCount = Number(document.getElementById("txtParamCount").value);
    var intCount = 0;
	var objControl;
	var blnAreClear = true;
	var strText;

	if (document.getElementById("txtParamCount") != undefined) {
	    intCount = Number(document.getElementById("txtParamCount").value);
	}

	for ( var intIndex=0; intIndex<intCount; intIndex++ )
	{
		objControl = document.getElementById("col"+intIndex);

		switch (objControl.getAttribute("type"))
		{
			case "checkbox":
				if (objControl.checked)
				{
					blnAreClear = false;
				}
				break;
			case "text":
				strText = objControl.value;
				while ( strText.indexOf(" ")!=-1 )
				{
					strText = strText.replace(" ", "");
				}
				if ( strText != "" )
				{
					blnAreClear = false;
				}
				break;
		}
	}
	return blnAreClear;
}

//--------------------------------------------------------------------------------------------------

function btnEdit_onclick()
{
	var strPageName;
	strPageName = new String(window.parent.location);
	strPageName = strPageName.substr(0, strPageName.indexOf("?") );
	
	window.parent.navigate("../routine/RoutineDetail.aspx?CallingPage=" + strPageName + "&SessionID=" + document.getElementById("txtSessionID").value + "&Action=E&RoutineTypeID=2&RoutineID=" + document.getElementById("txtRoutineID").value);
}

//--------------------------------------------------------------------------------------------------

function DoLookup(lngOrder, strRoutineName)
{
	var strXML = window.showModalDialog("../routine/RoutineLookupWrapper.aspx?SessionID=" + document.getElementById("txtSessionID").value + "&RoutineName=" + strRoutineName, undefined, "center:yes;status:no;dialogWidth:640px;dialogHeight:480px");
	if (strXML == 'logoutFromActivityTimeout') {
		strXML = null;
		window.close();
		window.parent.close();
		window.parent.ICWWindow().Exit();
	}

	//alert('test1 ' + strType);
    if (strXML!=undefined)
	{
		xmlLookup.XMLDocument.loadXML(strXML);
		var xmlNode = xmlLookup.selectSingleNode("*");
		//alert('test2');
	    // F0096495 ST 20Sep10 Added check for null value if user presses alt+f4 to close window.
		if ( typeof(xmlNode) !="undefined" && xmlNode != null )
		{
			document.getElementById("col" + lngOrder).value = xmlNode.attributes.getNamedItem("dbid").nodeValue;
			document.getElementById("desc" + lngOrder).value = xmlNode.attributes.getNamedItem("detail").nodeValue;
			//document.getElementById("type" + lngOrder).value = xmlNode.attributes.getNamedItem("type").nodeValue;
			//alert('xmlNode.attributes.getNamedItem("dbid").nodeValue = ' + xmlNode.attributes.getNamedItem("dbid").nodeValue);
			//alert('xmlNode.attributes.getNamedItem("detail").nodeValue = ' + xmlNode.attributes.getNamedItem("detail").nodeValue);

		}
	}
}
//--------------------------------------------------------------------------------------------------
function CancelThisEvent()
{
	if (event.keyCode!=9)
	{
		event.cancelBubble = true;
		return false;
	}
}
//--------------------------------------------------------------------------------------------------
function body_onkeyup()
{
	switch (event.keyCode)
	{
		case 27: // Escape
			window.parent.Clear();
			event.cancelBubble = true;
			return false;
			
		case 13: 
			Search();
			break;
	}
}

//--------------------------------------------------------------------------------------------------

function ValidateInputs()
{
    //var intCount = Number(document.getElementById("txtParamCount").value);
    var intCount = 0;
	var objControl;
	var blnAreClear = true;
	var strText;

	if (document.getElementById("txtParamCount") != undefined) {
	    intCount = Number(document.getElementById("txtParamCount").value);
	}

	for ( var intIndex=0; intIndex<intCount; intIndex++ )
	{
	    objControl = document.getElementById("col" + intIndex);
	    if (objControl != undefined)
        {
            if (objControl.getAttribute("xtype") == "datetime") {
	            strMsg = ValidateDateInput(new String(objControl.value));
	            if (strMsg.length > 0) {
	                alert(strMsg);
	                return false;
	                break;
	            }
	        }
	    }
	}
	return true;
}

//--------------------------------------------------------------------------------------------------

function ValidateDateInput(strText)
{
// Returns a stirng error validation message, or blank if all is well

var strStage; // Parsing Step: DayDigit, MonthDigit, YearDigit
var intIndex; // Pasing position throught the entire string
var intCount; // Count of characters since beginning, or last slash character
var strChar;  // Character currently being parsed

var strDay = "";
var strMonth = "";
var strYear = "";
var strWarn = "Date must be in the format: dd/mm/yyyy"; //29Jun2009 Rams    F0057077 Episode Selector - Incorrect Error message appears 
	strStage = "DayDigit";
	intCount = 0;	

	if (strText.length>0)
	{
		if (strText.length<6) return strWarn;
	
		for (intIndex=0; intIndex<strText.length; intIndex++)
		{
			strChar = strText.substr(intIndex, 1);
			
			switch (strStage)
			{
				case "DayDigit":
					if (strChar=="/" && intCount==0) return strWarn +  "\nDay part of date must contain 1 or more digits.";
					if (strChar=="/")
					{
						var intDay = Number(strDay) 
						if (intDay<1 || intDay>31) return strWarn + "\nDay part of date must be between 1 and 31"
						strStage = "MonthDigit"
						intCount = 0;
					}
					else
					{
						if (intCount>=2) return strWarn +  "\nDay part of date must contain no more than 2 digits.";
						if ( !IsDigit(strChar) ) return strWarn +  "\nDay part of date may only contain digits.";
						strDay += strChar;
						intCount++;
					}
					break;
					
				case "MonthDigit":
					if (strChar=="/" && intCount==0) return strWarn + "\nMonth part of date must contain 1 or more digits.";
					if (strChar=="/")
					{ 
						var intMonth = Number(strMonth) 
						if (intMonth<1 || intMonth>12) return strWarn + "\nMonth part of date must be between 1 and 12"
						strStage = "YearDigit"
						intCount = 0;
					}
					else
					{
						if (intCount>=2) return strWarn +  "\nMonth part of date must contain no more than 2 digits.";
						if ( !IsDigit(strChar) ) return strWarn + "\nMonth part of date may only contain digits.";
						strMonth += strChar;
						intCount++;
					}
					break;

            	case "YearDigit":
				    if (strChar == "/" && intCount == 0) return strWarn + "\nYear part of date must contain 1 or more digits.";
					//F0049614 ST 31Mar09   Removed extra spaces from text being returned.
					if (intCount>=4) return strWarn + "\nYear part of date must contain 4 digits.";
					if ( !IsDigit(strChar) ) return strWarn + "\nYear part of date may only contain digits.";
					strYear += strChar;
					intCount++;
					break;
			}
		}
		if (strYear.length<4) return strWarn + "\nYear part of date must contain 4 digits.";
	}
	return "";
}

function IsDigit(strChar)
{
	return ( strChar>='0' && strChar<='9' );
}

