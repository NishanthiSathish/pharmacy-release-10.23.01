var objTDSelected;

function window_onload()
{
	var strDeviceList;
	var lngCommaIndex;
	var objOption;

	strDeviceList = String(document.all("HEditAssist").GetPrinterList());
	
	if (strDeviceList.length>0)
	{
		spnMediaTypeDescription.innerText = window.dialogArguments
		strDeviceList += "|";
		while ( (lngCommaIndex = strDeviceList.indexOf("|")) != -1 )
		{
			objOption = document.createElement("option");
			objOption.innerText = strDeviceList.substring(0, lngCommaIndex);
			selDevices.appendChild(objOption);
			strDeviceList = strDeviceList.substring(lngCommaIndex+1, strDeviceList.length);
		}
	}
}

function btnOK_onclick()
{
	window.returnValue = selDevices.childNodes(selDevices.selectedIndex).innerText;
	window.close();
}

function btnCancel_onclick()
{
	window.close();
}

function selDevices_onclick()
{
	btnOK.disabled = false;
}

function selDevices_onchange()
{
	btnOK.disabled = false;
}

function selDevices_dblclick()
{
	btnOK_onclick();
}

