/*------------------------------------------------------------------------------------------

											Printing.js

	Shared functions and definitions for printing.

	Modification History:
	11Sep03 AE  Written, based on (ie copied from) PH's code from PrescriptionManager
	04Mar04 PH  Copied and changed name to Printing.js, as part of solving 4k limit problem.
					Added PrintBatch function

------------------------------------------------------------------------------------------*/

function PrintBatch(lngSessionID, lngPrintBatchID, blnPreview, pntFunctionCalledWhenPrintComplete, ShowAlert)
{
	if (lngPrintBatchID > 0)
	{
		InvokeModelessPrintWindow(lngSessionID, lngPrintBatchID, blnPreview, pntFunctionCalledWhenPrintComplete, false, ShowAlert);
	}
}

function PrintReprintBatch(lngSessionID, lngReprintBatchID, blnPreview, pntFunctionCalledWhenPrintComplete)
{
	InvokeModelessPrintWindow(lngSessionID, lngReprintBatchID, blnPreview, pntFunctionCalledWhenPrintComplete, true, false);
}

function InvokeModelessPrintWindow(lngSessionID, lngBatchID, blnPreview, pntFunctionCalledWhenPrintComplete, blnIsReprint, ShowAlert)
{
	ICWWindow().ICW_InvokeModelessPrintWindow(lngSessionID, lngBatchID, blnPreview, pntFunctionCalledWhenPrintComplete, blnIsReprint, PrintingModlessDialogFeatures(blnPreview), ShowAlert);
}

function PrintingModlessDialogFeatures(blnPreview)
{
	var strFeatures = "";

	if (blnPreview)
	{
		strFeatures = 'dialogLeft:0;dialogTop:0;'
						+ 'dialogWidth:' + screen.availWidth + 'px;dialogHeight:' + screen.availHeight + 'px;';
	}
	else
	{
		var lngWidth = 200;
		var lngHeight = 60;
		strFeatures = "dialogLeft:" + ((screen.availWidth/2) - (lngWidth/2))  
						+ ";dialogTop:" + ((screen.availHeight/2) - (lngHeight/2))  
						+ ";dialogWidth:" + lngWidth + 'px'
						+ ";dialogHeight:" + lngHeight + 'px';
	}
		
	strFeatures += ";center:no;scroll:no;status:no;resizable:yes";		//real
	//strFeatures += ";center:no;scroll:no;status:no;resizable:yes";			//debug
	
	return strFeatures;
}