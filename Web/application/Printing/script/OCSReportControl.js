var m_blnPreview = false;

function PrintBatch(BatchID, Preview, IsReprint)
{
	m_blnPreview = Preview;

	var URL = "../Printing/OCSReportLoader.aspx?SessionID=" + document.all("body").getAttribute("SessionID")
					+ "&BatchID=" + BatchID
					+ "&Preview=" + Preview
					+ "&IsReprint=" + (IsReprint ? "YES" : "NO");

	document.all['fraOCSReportLoader'].src = URL; 					//13Sep03 AE  Changed .navigate to .src; .navigate does not always interpret relative URLs properly.
}

function ProcessNextPrintItem(RTF_Data, DeviceName) 
{
    // Bug 61494 30April2013 YB - Added PrevDeviceName to hold the previously selected printer to prevent printer list showing up on every single print item when AlwaysShowPrinterList=true. . Copied changes from 10.8
    fraOCSReportLoader.document.all("txtPrevDeviceName").value = DeviceName;
	fraOCSReportLoader.document.all("txtAction").value = "P";
	fraOCSReportLoader.document.all("txtPrintStatusID").value = 3;
	fraOCSReportLoader.document.all("txtReport_RTF").innerText = RTF_Data;
	fraOCSReportLoader.document.all("frmOCSReportLoader").submit();
}

function DataReady()
{
	var ReportName = fraOCSReportLoader.document.all("txtReportName").value;

	PrintReport(ReportName);
}

function PrintCancelled()
{
	window.parent.PrintCancelled();
}

function DocumentPrinted(ReportName, DeviceName, RTF_Data, UpdateDialog)
{
	if (UpdateDialog)
	{
		window.parent.DocumentPrinted(ReportName, DeviceName);
	}

	ProcessNextPrintItem(RTF_Data, DeviceName);

}

function PrintReport(ReportName)
{
	if (ReportName == '')
	{
		window.parent.AllReportsPrinted();
	}
	else
	{
		var RoutineError = fraOCSReportLoader.document.all("txtRoutineError").value;
		if (RoutineError != '')
		{
			var RoutineName = fraOCSReportLoader.document.all("txtRoutineName").value;
			var Msg = 'An error occured in routine "' + RoutineName + '"\n\n' + RoutineError
			Popmessage(Msg, 'Report Routine Error');
			window.parent.close();
			return false;
		}

		var DeviceName = fraOCSReportLoader.document.all("txtDeviceName").value;
		var CopiesToPrint = Number(fraOCSReportLoader.document.all("txtCopies").value);

		if (!m_blnPreview)
		{
			// Check the supplied print device exists
			var DeviceShortName = DeviceName;

			// 13Nov06 PH Extract device short name from device string. It's everything up to the first comma.
			//	e.g. Microsoft Office Document Image Writer,winspool,Ne00:
			if (DeviceName != "")
			{
				var FirstComma = DeviceName.indexOf(",", 0);
				if (FirstComma > -1)
				{
					DeviceShortName = DeviceName.substr(0, FirstComma);
				}
			}

			var DeviceList = String(document.all("HEditAssist").GetWindowsPrintDeviceList());
			if (DeviceName == "" || DeviceList.indexOf(DeviceShortName, 0) == -1)
			{
				// Doesnt exist, so display list of devices that the user can choose from.
				var MediaTypeDescription = fraOCSReportLoader.document.all("txtMediaTypeDescription").value;
				var Features = "dialogWidth:640px;dialogHeight:480px;scroll:no;status:no;resizable:yes";

				DeviceName = window.showModalDialog("PrintDeviceSelector.aspx?SessionID=" + document.all("body").getAttribute("SessionID"), MediaTypeDescription, Features);
				
				if (DeviceName == undefined)
				{
					PrintCancelled();
					return false;
				}
				else
				{
					var MediaTypeID = Number(fraOCSReportLoader.document.all("txtMediaTypeID").value);
					PrintDeviceSave(MediaTypeID, DeviceName);
				}
			}
			else
			{
				PrintReportAfterDeviceCheck(ReportName, CopiesToPrint, DeviceName);
			}
		}
		else
		{
			PrintReportAfterDeviceCheck(ReportName, CopiesToPrint, DeviceName);
		}
	}
}

function PrintDeviceSave(MediaTypeID, DeviceName)
{
	fraPrintDeviceSaver.document.all("txtMediaTypeID").value = MediaTypeID;
	fraPrintDeviceSaver.document.all("txtDeviceName").value = DeviceName;
	fraPrintDeviceSaver.document.all("frmPrintDeviceSaver").submit();
}

function PrintDeviceSaveComplete(DeviceName)
{
	var ReportName = fraOCSReportLoader.document.all("txtReportName").value;
	var CopiesToPrint = Number(fraOCSReportLoader.document.all("txtCopies").value);

	PrintReportAfterDeviceCheck(ReportName, CopiesToPrint, DeviceName);
}

function PrintReportAfterDeviceCheck(ReportName, CopiesToPrint, DeviceName)
{
	var ReportRTF = fraOCSReportLoader.document.all("txtReport_RTF").value;
	var ReportXML = fraOCSReportLoader.document.all("xmlData_XML").xml;
	var Reprint = fraOCSReportLoader.document.all("txtReprintItemID").value != "";
    var portrait = fraOCSReportLoader.document.all("txtPortrait").value != "0";

    	var margin
    	if (fraOCSReportLoader.document.all("txtMarginTop").value != '')
    	{
    		margin = new Object();
    		margin.top   = fraOCSReportLoader.document.all("txtMarginTop"	).value;
    		margin.bottom= fraOCSReportLoader.document.all("txtMarginBottom").value;
    		margin.left  = fraOCSReportLoader.document.all("txtMarginLeft"	).value;
    		margin.right = fraOCSReportLoader.document.all("txtMarginRight"	).value;
    	}
    	else
		margin = undefined;

	if (CopiesToPrint == 0)
	{
		fraPrintControl.DoPrint(ReportName, ReportRTF, ReportXML, DeviceName, m_blnPreview, false, Reprint, 0, CopiesToPrint, portrait, margin);
	}
	else
	{
		for (var Copy = 1; Copy <= CopiesToPrint; Copy++)
		{
			fraPrintControl.DoPrint(ReportName, ReportRTF, ReportXML, DeviceName, m_blnPreview, false, Reprint, Copy, CopiesToPrint, portrait, margin);
		}
	}
}

function DocumentPrinting(ReportName, DeviceName, Copies, NoOfCopies)
{
	window.parent.DocumentPrinting(ReportName, DeviceName, Copies, NoOfCopies);
}

function window_onload()
{
    window.parent.ReadyToPrint();
}

