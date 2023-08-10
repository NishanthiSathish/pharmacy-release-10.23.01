var TOKEN_FOR_EACH = "[FOR EACH ";
var TOKEN_NEXT = "[NEXT ";
var TOKEN_START = "[";
var TOKEN_END = "]";
var TOKEN_SEPARATOR = ".";
var TOKEN_GROUP_START = "[GROUP START]";
var TOKEN_GROUP_END = "[GROUP END]";
var TOKEN_GROUP_BREAK_TEXT = "[GROUP BREAK TEXT]";
var TOKEN_NO_BREAK_END = "[NO BREAK END]";
var TOKEN_INSERT_IMG = "INSERT_IMG";
var TOKEN_END_INSERT_IMG = "END_INSERT_IMG";
var TOKEN_INSERT_RTFDOC = "[RTFDOC ";   // XN 28Dec12 51139 add ability to insert pure RTF into report
var TOKEN_END_INSERT_RTFDOC = "]";      // XN 28Dec12 51139 add ability to insert pure RTF into report

var SEARCH_FORWARD = 0;
var SEARCH_CASE = 2;
var SEARCH_WORD = 4;
var SEARCH_CURSOR = 8;
var SEARCH_BACK = 16;
var SEARCH_INIT = 32;

var SEARCH_NOTFOUND = 0;
var SEARCH_FOUND = 1;
var SEARCH_ERROR = 2;

var DOCUMENT_HEADER = 1;
var DOCUMENT_FOOTER = 2;
var DOCUMENT_BODY = 0;

var MT_XPOS = 1;
var MT_YPOS = 2;
var MT_CHAROFFSET = 3;
var MT_TABLE = 5;
var MT_ROW = 6;
var MT_COLUMN = 7;
var MT_BOOKMARK = 10;

var MT_ABSOLUTE = 0;
var MT_RELATIVE = 256;
var MT_ID = 512;

var MT_NOSELECT = 0;
var MT_SELECT = 16384;

var m_strReportName = "";
var m_strDeviceName = "";
var keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
var IsReprint;
var IsPreview;

// *****************************************************************************************************************************************
function DoPrint(strReportName, strReportRTF, strPrintDataXML, strDeviceName, blnPreview, blnShowFields, blnIsReprint, copy, noOfCopies, portrait, margin) {
    //01Nov13 Rams TFS - 77014/69565 - Print preview screen crashing
    IsReprint = blnIsReprint;
    IsPreview = blnPreview;
	var heAssist = document.all("HEditAssist");
	var heCurrent = document.all("HEdit0");

	//15Apr2013 Rams    61585 - hiedit print error messages when we try to print orderset ukall 14 phase 1 induction for b cell + (10.09.02)
	//
	// if report filename contains an invalid character, replace with something else
	strReportName = strReportName.replace("\\", "");
	strReportName = strReportName.replace(/[^A-Za-z0-9 +=-@]/g, "");

	var strReportFilePathName = heAssist.GetTemporaryFolder() + "\\" + strReportName;

	m_strReportName = strReportName;
	m_strDeviceName = strDeviceName;

	heCurrent.style.height = "0%";
	heCurrent.text = "";
	btnDone.style.display = "none";
	spanCancel.style.display = "none";

	try
	{
		window.parent.DocumentPrinting(strReportName, strDeviceName, copy, noOfCopies);
	}
	catch (e) { }

	if (strReportRTF == "") {
	    if (blnPreview == true) {
	        alert("No document.");
	    }
	    return;
    }

	try {
	    document.all("HEditAssist").WriteRTFText(strReportFilePathName, strReportRTF);

        if (heCurrent.IsPreview) {
            heCurrent.Preview();
        }

        heCurrent.BackColor = 0xffffff;
        heCurrent.MenuBar = false;
        heCurrent.StatusBar = false;
        heCurrent.StyleBar = false;
        heCurrent.style.display = "";
        try {
            heCurrent.focus();
        } catch (e) {
        }

        // Load the temporary RTF file into HighEdit
        heCurrent.LoadDoc(strReportFilePathName + ".rtf", 3);

        // rendering behaves differently if HiEdit is in Preview mode so make sure it is off
        if (!blnPreview) {
            var blnSetPrinterInstance = heCurrent.SetInstancePrinter(strDeviceName);
        }

        if (!blnIsReprint) {
            // XN 28Dec12 51139 render RTF tags first
            RenderRTFDoc(strReportFilePathName, strPrintDataXML);
            heCurrent.LoadDoc(strReportFilePathName + ".rtf", 3);

            heCurrent.SetOrientation(portrait ? 0 : 1);
            if (margin != undefined) {
                heCurrent.TopMargin = margin.top;
                heCurrent.LeftMargin = margin.left;
                heCurrent.RightMargin = margin.right;
                heCurrent.BottomMargin = margin.bottom;
            }
            if (!blnPreview) {
                var blnSetPrinterInstance = heCurrent.SetInstancePrinter(strDeviceName);
            }

            strPrintDataXML = "<PRINT_DATA>" + txtSessionDataXML.innerText + strPrintDataXML + "</PRINT_DATA>"
            RenderDoc(strPrintDataXML, blnShowFields);

            // MM21082012 After rendering, check if there are images to replace
            // Images will have been saved in the following manner
            // #INSERT_RTF xml_path_to_image_in_data_xml

            // first save rendered document back to disk
            heCurrent.SaveDoc(strReportFilePathName + ".rtf", 3); // 3 - RTF format

            // Read rendered document from disk
            strReportRTF = heAssist.ReadRTFText(strReportFilePathName);

            // check if there are images to replace
            if (strReportRTF.search(TOKEN_INSERT_IMG) != -1) {
                //strReportRTF = strReportRTF.replace("#INSERT_PICTURE ", imgrtf);
                strReportRTF = RenderImages(strReportRTF);

                //write rtf back and load again
                heAssist.WriteRTFText(strReportFilePathName, strReportRTF);
            }

            heCurrent.LoadDoc(strReportFilePathName + ".rtf", 3);
            if (!blnPreview) {
                var blnSetPrinterInstance = heCurrent.SetInstancePrinter(strDeviceName);
            }
        }


        heCurrent.SetOrientation(portrait ? 0 : 1);
        if (margin != undefined) {
            heCurrent.TopMargin = margin.top;
            heCurrent.LeftMargin = margin.left;
            heCurrent.RightMargin = margin.right;
            heCurrent.BottomMargin = margin.bottom;
        }

        if (blnPreview) {
            heCurrent.Preview();
            heCurrent.ReadOnly = true;
        } else {
            heCurrent.PrintDoc();
        }

        if (blnIsReprint) {
            strReportRTF = ""; // Blank rtf if doing a re-print, because we dont want/need to save the RTF back to the DB
        } else {
            // MM we dont need the lines below any more

            // Save Rendered document back to disk
            //heCurrent.SaveDoc(strReportFilePathName + ".rtf", 3); // 3 - RTF format

            // Read rendered document from disk and make it this function's return value
            //strReportRTF = heAssist.ReadRTFText(strReportFilePathName);
        }

    } catch (e) {
        
    }

    // Delete temporary RTF File
	heAssist.DeleteRTFFile(strReportFilePathName);

	if (blnPreview)
	{
		heCurrent.style.height = "100%";
		//trButtons.style.height = "1%";
		spanCancel.style.display = "";
		btnDone.style.display = "";
	}
	else
	{
		//		document.all("HEditAssist").SetDefaultWindowsPrintDevice(strPreviousDefaultWindowsPrintDevice);
		if (copy == noOfCopies)
		{
			window.parent.DocumentPrinted(strReportName, strDeviceName, strReportRTF);
		}
	}
}

// *****************************************************************************************************************************************
function RenderImages(reportRTF)
{

	var intStartPosition;
	var intClosingHashTag;
	// this is already loaded
	var xmlDoc = document.all("xmlPrintData");

	intStartPosition = reportRTF.search(TOKEN_INSERT_IMG);

	while (intStartPosition != -1)
	{
		//get position of closing #
		//alert(intStartPosition);
		//alert(reportRTF)
		intClosingHashTag = reportRTF.search(TOKEN_END_INSERT_IMG);
		//alert("closing - " + intClosingHashTag);

		//get the path to the XML node
		var nodePath = reportRTF.substring(intStartPosition + TOKEN_INSERT_IMG.length, intClosingHashTag);
		//alert("nodepath - " + nodePath);
		//get the attribute
		var xmlAttr = xmlDoc.selectSingleNode(nodePath);

		//replace in rtf
		if (xmlAttr == null)
		{
			reportRTF = reportRTF.replace(TOKEN_INSERT_IMG + nodePath + TOKEN_END_INSERT_IMG, "");
		}
		else
		{
			//alert(xmlAttr.text);
			var pict = decode64(xmlAttr.text);
			//alert(pict);
			reportRTF = reportRTF.replace(TOKEN_INSERT_IMG + nodePath + TOKEN_END_INSERT_IMG, pict);
		}

		//search again
		intStartPosition = reportRTF.search(TOKEN_INSERT_IMG);
	}

	return reportRTF;
}
// *****************************************************************************************************************************************

function RenderDoc(dataXML, blnShowFields)
{
	var heCurrent = document.all("HEdit0");
	var xmlDoc = document.all("xmlPrintData");

	if (xmlDoc.loadXML(dataXML))
	{
		heCurrent.SetContext(DOCUMENT_HEADER);
		Render(xmlDoc, blnShowFields);

		heCurrent.SetContext(DOCUMENT_FOOTER);
		Render(xmlDoc, blnShowFields);

		heCurrent.SetContext(DOCUMENT_BODY);
		Render(xmlDoc, blnShowFields);

		RenderPagination();
	}
	else
	{
		alert("Can't load XML data");
	}
}

// *****************************************************************************************************************************************

function Render(xmlDoc, blnShowFields)
{
	////////////////////////////////////////////////////////////////////////////////////////
	// Purpose   :  Render (mailmerge) the provided XML data into the current document
	//
	//              The method performs a recursive descent down the XML tree.
	//              For each attribute in each node it encounters, it searches the
	//              current documentRTF for the text:
	//
	//              [NodeName.AttributeName]
	//              where NodeName is the name of the node
	//              and AttributeName is the name of attribute!
	//
	//              If found, then it replaces that text with the value of attribute
	//
	//              The "mail merge" functionality is further enhanced by providing
	//              report designer the ability to be able to repeat sections of the
	//              document using special tags:
	//
	//              [FOR EACH NodeName]
	//              some document text
	//              [NEXT NodeName]
	//
	//              When the Renderer encounters the above tags, it will repeat the text
	//              inside the tags for each occurance of NodeName it finds in the XML Data.
	//
	//              e.g.
	//
	//              Document text:
	//
	//              Document text before the for-each-next
	//              [FOR EACH MyNode]
	//                 Document text inside the for-each-next [MyNode.MyAttribute]
	//              [NEXT MyNode]
	//              Document text after the for-each-next
	//
	//              XML Data:
	//
	//              <ROOT>
	//                 <MyNode MyAttribute="Some test data" />
	//                 <MyNode MyAttribute="Some more test data" />
	//                 <MyNode MyAttribute="More test data than I know what to do with!" />
	//              </ROOT>
	//
	//
	//              Rendered document output:
	//
	//
	//              Document text before the for-each-next
	//              [FOR EACH MyNode]
	//                 Document text inside the for-each-next Some test data
	//                 Document text inside the for-each-next Some more test data
	//                 Document text inside the for-each-next More test data than I know what to do with!
	//              [NEXT MyNode]
	//              Document text after the for-each-next
	//
	//
	// Input     :  Data_XML    -  XML data to be merged into the current document
	//
	// Outputs   :  None
	//
	// Return    :
	//
	// Revision History
	// 20Feb03 PH - Created
	////////////////////////////////////////////////////////////////////////////////////////

	RenderRepeats(0, xmlDoc, blnShowFields);

	RenderNode(0, xmlDoc.firstChild);

	if (!blnShowFields)
	{
		ClearUnmatchedTags(0);
	}
}

// *****************************************************************************************************************************************

function RenderRepeats(intDepth, xmlDoc, blnShowFields)
{
	////////////////////////////////////////////////////////////////////////////////////////
	// Purpose   :  Finds all the repeating sections FOR EACH NEXTs, and repeats them,
	//              processing each section in turn
	//
	// Input     :  xmlDoc   -  XML Source Data to be merged into current document
	//
	// Outputs   :  None
	//
	// Return    :
	//
	// Revision History
	// 20Feb03 PH - Created
	////////////////////////////////////////////////////////////////////////////////////////

	var heAssist = document.all("HEditAssist");
	var heCurrent = document.all("HEdit" + intDepth);
	var heRepeat = document.all("HEdit" + (intDepth + 1));

	var tokenName;

	var repeatStart = { X: 0, Y: 0, Cell_X: 0, Cell_Y: 0 };
	var repeatEnd = { X: 0, Y: 0, Cell_X: 0, Cell_Y: 0 };
	var repeatEndIsTable = false;

	var repeatBufferText;
	var repeatBufferFormat;

	var bufferText;
	var bufferFormat;

	// Search for [FOR EACH MyName]
	while (heCurrent.Search(SEARCH_INIT + SEARCH_FORWARD, TOKEN_FOR_EACH, false) == SEARCH_FOUND)
	{
		heAssist.GetSelectionExt(heCurrent);
		var forTokenStart = { X: heAssist.XEnd, Y: heAssist.YEnd, Cell_X: heAssist.CellXEnd, Cell_Y: heAssist.CellYEnd, InTable: (heAssist.CellYEnd != -1) };
		var forTokenEnd = { X: 0, Y: forTokenStart.Y, Cell_X: 0, Cell_Y: forTokenStart.Cell_Y, InTable: forTokenStart.InTable };

		var line = heAssist.GetLine(heCurrent);

		var forTokenStartPos = forTokenStart.InTable ? forTokenStart.Cell_X : forTokenStart.X;
		var forTokenEndPos = line.indexOf(TOKEN_END, forTokenStartPos + TOKEN_FOR_EACH.length);

		if (forTokenEndPos == -1)
		{
			window.alert("[FOR EACH should be terminated with a closing ], but isnt.");
			return;
		}

		if (forTokenEnd.InTable)
		{
			forTokenEnd.X = forTokenStart.X;
			forTokenEnd.Cell_X = forTokenEndPos + 1;
		}
		else
		{
			forTokenEnd.X = forTokenEndPos + 1;
			forTokenEnd.Cell_X = -1;
		}
		// Extract the MyName part
		tokenName = line.substring(forTokenStartPos + TOKEN_FOR_EACH.length, forTokenEndPos);

		heCurrent.SetSelectionExt(forTokenStart.Y, forTokenStart.X, forTokenStart.Cell_Y, forTokenStart.Cell_X, forTokenEnd.Y, forTokenEnd.X, forTokenEnd.Cell_Y, forTokenEnd.Cell_X);
		heCurrent.ReplaceSel("", 0);

		// If there is only whitespace after the [FOR EACH MyName] start repeat selection from next line
		var trailingText = line.substr(forTokenEnd.X);
		var hasTrailingText = false;
		for (var i = 0; i < trailingText.length; i++)
		{
			if (trailingText.charCodeAt(i) > 32)
			{
				hasTrailingText = true;
				break;
			}
		}
		if (hasTrailingText)
		{
			repeatStart.X = forTokenStart.X;
			repeatStart.Y = forTokenStart.Y;
			repeatStart.Cell_X = forTokenStart.Cell_X;
			repeatStart.Cell_Y = forTokenStart.Cell_Y;
		}
		else if (forTokenStart.InTable)
		{
			repeatStart.X = forTokenStart.X;
			repeatStart.Y = forTokenStart.Y;
			repeatStart.Cell_X = 0;
			repeatStart.Cell_Y = forTokenStart.Cell_Y + 1;
		}
		else
		{
			repeatStart.X = 0;
			repeatStart.Y = forTokenStart.Y + 1;
			repeatStart.Cell_X = -1;
			repeatStart.Cell_Y = -1;
		}

		// Find [NEXT MyName] that matches the [FOR EACH MyName]
		if (heCurrent.Search(SEARCH_FORWARD, TOKEN_NEXT + tokenName + TOKEN_END, false) != SEARCH_FOUND)
		{
			alert("No matching NEXT for FOR EACH: " + tokenName);
			return;
		}

		heAssist.GetSelectionExt(heCurrent);
		var nextTokenStart = { X: heAssist.XEnd, Y: heAssist.YEnd, Cell_X: heAssist.CellXEnd, Cell_Y: heAssist.CellYEnd, InTable: (heAssist.CellYEnd != -1) };

		if ((forTokenStart.InTable && (!nextTokenStart.InTable || forTokenStart.X != nextTokenStart.X || forTokenStart.Y != nextTokenStart.Y)) || (!forTokenStart.InTable && nextTokenStart.InTable))
		{
			alert("FOR EACH and NEXT must be in the same table cell if placed in a table");
			return;
		}

		heCurrent.ReplaceSel("", 0);
		line = heAssist.GetLine(heCurrent);
		var leadingText = line.substring(0, (nextTokenStart.InTable ? nextTokenStart.Cell_X : nextTokenStart.X));
		var hasLeadingText = false;
		for (i = 0; i < leadingText.length; i++)
		{
			if (leadingText.charCodeAt(i) > 32)
			{
				hasLeadingText = true;
				break;
			}
		}
		if (hasLeadingText)
		{
			repeatEnd.X = nextTokenStart.X;
			repeatEnd.Y = nextTokenStart.Y;
			repeatEnd.Cell_X = nextTokenStart.Cell_X;
			repeatEnd.Cell_Y = nextTokenStart.Cell_Y;
		}
		else if (nextTokenStart.InTable)
		{
			heCurrent.SetCursorExt(nextTokenStart.Y, nextTokenStart.X, nextTokenStart.Cell_Y - 1, 0, false);
			var lineLength = heCurrent.GetLineLength(-1);
			repeatEnd.X = nextTokenStart.X;
			repeatEnd.Y = nextTokenStart.Y;
			repeatEnd.Cell_X = lineLength;
			repeatEnd.Cell_Y = nextTokenStart.Cell_Y - 1;
		}
		else
		{
			repeatEnd.X = heCurrent.GetLineLength(nextTokenStart.Y - 1);
			repeatEnd.Y = nextTokenStart.Y - 1;
			repeatEnd.Cell_X = -1;
			repeatEnd.Cell_Y = -1;
		}

		if (repeatEnd.Cell_X == -1)
		{
			heCurrent.SetCursor(repeatEnd.X, repeatEnd.Y);
			repeatEndIsTable = heCurrent.IsTableActive();
		}

		if (repeatEndIsTable)
		{
			repeatEnd.X = 0;
			repeatEnd.Y = repeatEnd.Y + 1;
		}

		heCurrent.SetSelectionExt(repeatStart.Y, repeatStart.X, repeatStart.Cell_Y, repeatStart.Cell_X, repeatEnd.Y, repeatEnd.X, repeatEnd.Cell_Y, repeatEnd.Cell_X);

		heAssist.CopyData(heCurrent);
		repeatBufferText = heAssist.BufferText;
		repeatBufferFormat = heAssist.BufferFormat;

		heCurrent.SetSelectionExt(forTokenStart.Y, forTokenStart.X, forTokenStart.Cell_Y, forTokenStart.Cell_X, nextTokenStart.Y, nextTokenStart.X, nextTokenStart.Cell_Y, nextTokenStart.Cell_X);
		heCurrent.ReplaceSel("", 0);

		//29Jun11   Rams    F0110076 - F0054048 - DSS Results Printing - A requirement of the F0054048 development has not been met.
		var xmlNodeList = xmlDoc.selectNodes(".//" + tokenName);
		for (i = 0; i < xmlNodeList.length; i++)
		{
			var xmlNode = xmlNodeList(i);

			heRepeat.InitNewDoc();

			heAssist.PasteData(heRepeat, repeatBufferFormat, repeatBufferText);

			RenderRepeats(intDepth + 1, xmlNode, blnShowFields);
			RenderNode(intDepth + 1, xmlNode);
			if (!blnShowFields)
			{
				ClearUnmatchedTags(intDepth + 1);
			}

			heRepeat.SelectAll(false);
			heAssist.CopyData(heRepeat);
			bufferFormat = heAssist.BufferFormat;
			bufferText = heAssist.BufferText;

			/*
			when HighEdit copies the contents of a complete HighEdit document, the EOF character is also copied.
			When this is pasted the EOF character gets converted to a new line character, which is good as it ensures the next row starts on a new line.
			However if the insertion point, where the data will be pasted is immediately before the EOF character then HighEdit decides not to add the line break.
			To ensure we are never just before the EOF, an extra character is inserted before pasting and the insertion point moving to just before this extra character.
			After pasting the main data back in the extra character is removed.
			*/
			heAssist.GetSelectionExt(heCurrent);
			var currentCursor = { X: heAssist.XEnd, Y: heAssist.YEnd, Cell_X: heAssist.CellXEnd, Cell_Y: heAssist.CellYEnd, InTable: (heAssist.CellYEnd != -1) };
			heAssist.PasteData(heCurrent, "", "a");
			heCurrent.SetCursorExt(currentCursor.Y, currentCursor.X, currentCursor.Cell_Y, currentCursor.Cell_X, false);

			heAssist.PasteData(heCurrent, bufferFormat, bufferText);

			heAssist.GetSelectionExt(heCurrent);
			currentCursor = { X: heAssist.XEnd, Y: heAssist.YEnd, Cell_X: heAssist.CellXEnd, Cell_Y: heAssist.CellYEnd, InTable: (heAssist.CellYEnd != -1) };
			if (currentCursor.InTable)
			{
				heCurrent.SetCursorExt(currentCursor.Y, currentCursor.X, currentCursor.Cell_Y, currentCursor.Cell_X + 1, true);
			}
			else
			{
				heCurrent.SetCursorExt(currentCursor.Y, currentCursor.X + 1, currentCursor.Cell_Y, currentCursor.Cell_X, true);
			}
			heCurrent.ReplaceSel("", 0);
			if (repeatEndIsTable)
			{
				RemoveLineBreak(heAssist, heCurrent);
			}
		}

		if (xmlNodeList.length > 0 && !repeatEndIsTable)
		{
			RemoveLineBreak(heAssist, heCurrent);
		}
	}
}

// *****************************************************************************************************************************************

function RemoveLineBreak(heAssist, heControl)
{
	heAssist.GetSelectionExt(heControl);
	var currentCursor = { X: heAssist.XEnd, Y: heAssist.YEnd, Cell_X: heAssist.CellXEnd, Cell_Y: heAssist.CellYEnd, InTable: (heAssist.CellYEnd != -1) };
	var currentLine;
	if (currentCursor.InTable)
	{
		heControl.SetCursorExt(currentCursor.Y, currentCursor.X, currentCursor.Cell_Y - 1, 0, false);
		currentLine = heAssist.GetLine(heControl);
		heControl.SetCursorExt(currentCursor.Y, currentCursor.X, currentCursor.Cell_Y - 1, currentLine.length, false);
	}
	else
	{
		heControl.SetCursorExt(currentCursor.Y - 1, 0, currentCursor.Cell_Y, currentCursor.Cell_X, false);
		currentLine = heAssist.GetLine(heControl);
		heControl.SetCursorExt(currentCursor.Y - 1, currentLine.length, currentCursor.Cell_Y, currentCursor.Cell_X, false);
	}
	heControl.SetCursorExt(currentCursor.Y, currentCursor.X, currentCursor.Cell_Y, currentCursor.Cell_X, true);
	heControl.ReplaceSel("", 0);
}

// *****************************************************************************************************************************************

// add ability to insert pure RTF into report using a [RTFDoc {tagname}] tag
// The tag will be replaced with the RTF data
// XN 28Dec12 51139
function RenderRTFDoc(strReportFilePathName, dataXML)
{
	var heAssist = document.all("HEditAssist");
	var xmlDoc = document.all("xmlPrintData");
	xmlDoc.loadXML(dataXML);

	// Read in the RTF doc
	var reportRTF = heAssist.ReadRTFText(strReportFilePathName);

	// Find first RTFDoc tag
	var intStartPosition = reportRTF.indexOf(TOKEN_INSERT_RTFDOC, 0);
	while (intStartPosition != -1)
	{
		// Find end tag
		var intEndPosition = reportRTF.indexOf(TOKEN_END_INSERT_RTFDOC, intStartPosition);
		if (intEndPosition == -1)
		{
			alert("RTFDOC print tag '" + TOKEN_INSERT_RTFDOC + "' missing end tag '" + TOKEN_END_INSERT_RTFDOC + "' at position " + intStartPosition);
			break;
		}

		// Get tag name
		var tagName = reportRTF.substring(intStartPosition + TOKEN_INSERT_RTFDOC.length, intEndPosition);
		var pathIndex = tagName.lastIndexOf('.');
		if (pathIndex == -1)
		{
			alert("RTFDOC print tag should reference an attribute");
			break;
		}
		var nodePath = tagName.substring(0, pathIndex);
		var attributeName = tagName.substring(pathIndex + 1, tagName.length);

		// Get data for tag from xml
		//alert("nodepath - " + nodePath);
		//alert("nodeattr - " + attributeName);
		var text = ''
		var xmlNode = xmlDoc.selectSingleNode("//" + nodePath.replace('.', '/'));
		if (xmlNode != null)
		{
			if (xmlNode.getAttribute(attributeName) != null)
				text = xmlNode.getAttribute(attributeName);
		}

		// Do string replace of RTFDOC tag with data
		//alert(xmlAttr.text);
		reportRTF = reportRTF.replace(TOKEN_INSERT_RTFDOC + tagName + TOKEN_END_INSERT_RTFDOC, text);

		//search again
		intStartPosition = reportRTF.indexOf(TOKEN_INSERT_RTFDOC, 0);
	}

	// And save back
	heAssist.WriteRTFText(strReportFilePathName, reportRTF);
}

// *****************************************************************************************************************************************

function RenderNode(intDepth, xmlNode)
{
	////////////////////////////////////////////////////////////////////////////////////////
	// Purpose   :  For a given node, for each attribute, perform a search and replace
	//              of Tokens with Attrbute Values.
	//					 Then recursively call this function for any child nodes
	//
	// Input     :  xmlNode -  a XML single node
	//
	// Outputs   :  None
	//
	// Return    :
	//
	// Revision History
	// 26Mar03 PH - Created
	////////////////////////////////////////////////////////////////////////////////////////

	var heCurrent = document.all("HEdit" + intDepth);

	// For Each xmlAttrib In xmlNode.Attributes
	if (xmlNode.attributes != null)
	{
		for (var n = 0; n < xmlNode.attributes.length; n++)
		{
			//Leave the variable declarations here, don't move out of the loop
			var xmlAttrib = xmlNode.attributes(n);

			var strNodeText = GetNodeText(xmlAttrib.nodeName, xmlAttrib.text);

			var intSearchStatus = heCurrent.Search(SEARCH_INIT + SEARCH_FORWARD, TOKEN_START + xmlNode.nodeName + TOKEN_SEPARATOR + xmlAttrib.nodeName + TOKEN_END, false);
			while (intSearchStatus == SEARCH_FOUND)
			{
				heCurrent.ReplaceSel(strNodeText, strNodeText.length);
				intSearchStatus = heCurrent.Search(SEARCH_FORWARD + SEARCH_CURSOR, TOKEN_START + xmlNode.nodeName + TOKEN_SEPARATOR + xmlAttrib.nodeName + TOKEN_END, false);
			}
		}
	}

	// Recursively process child nodes
	var previousChild = '';
	if (xmlNode.childNodes != null)
	{
		for (var a = 0; a < xmlNode.childNodes.length; a++)
		{
			if (xmlNode.childNodes(a).nodeName != previousChild)
			{
				RenderNode(intDepth, xmlNode.childNodes(a));
			}

			previousChild = xmlNode.childNodes(a).nodeName;
		}
	}
}

// *****************************************************************************************************************************************

function ClearUnmatchedTags(intDepth)
{
	////////////////////////////////////////////////////////////////////////////////////////
	// Purpose   :  After all the rendering has been done, go through and remove any remaining
	//					 unmatched tags. e.g. [TableName.ColmunName]
	//
	// Revision History
	// 14Oct03 PH - Created
	////////////////////////////////////////////////////////////////////////////////////////
	var heAssist = document.all("HEditAssist");
	var heCurrent = document.all("HEdit" + intDepth);

	var strSelectedText;

	var searchResult = heCurrent.Search(SEARCH_INIT + SEARCH_FORWARD, TOKEN_START, false);
	// Search for [
	while (searchResult == SEARCH_FOUND)
	{
		heAssist.GetSelectionExt(heCurrent);
		var tagStart = { X: heAssist.XEnd, Y: heAssist.YEnd, Cell_X: heAssist.CellXEnd, Cell_Y: heAssist.CellYEnd, InTable: (heAssist.CellYEnd != -1) };

		// Find closing ]
		if (heCurrent.Search(SEARCH_FORWARD + SEARCH_CURSOR, TOKEN_END, false) != SEARCH_FOUND)
		{
			window.alert("[ should be terminated with a closing ], but isnt.");
		}

		heAssist.GetSelectionExt(heCurrent);
		var tagEnd = { X: heAssist.XStart, Y: heAssist.YStart, Cell_X: heAssist.CellXStart, Cell_Y: heAssist.CellYStart, InTable: (heAssist.CellYStart != -1) };

		// Select the area between the [ and the ]
		heCurrent.SetSelectionExt(tagStart.Y, tagStart.X, tagStart.Cell_Y, tagStart.Cell_X, tagEnd.Y, tagEnd.X, tagEnd.Cell_Y, tagEnd.Cell_X);
		strSelectedText = heAssist.GetSelectedText(heCurrent);

		if (strSelectedText == TOKEN_GROUP_START || strSelectedText == TOKEN_GROUP_END || strSelectedText == TOKEN_GROUP_BREAK_TEXT || strSelectedText == TOKEN_NO_BREAK_END)
		{
			heCurrent.SetCursorExt(tagEnd.Y, tagEnd.X, tagEnd.Cell_Y, tagEnd.Cell_X, false);
		}
		else
		{
			// Then remove the selected area
			heCurrent.ReplaceSel("", 0);
		}

		searchResult = heCurrent.Search(SEARCH_FORWARD + SEARCH_CURSOR, TOKEN_START, false);
	}
}

// *****************************************************************************************************************************************
function RenderPagination()
{
	var heAssist = document.all("HEditAssist");
	var heCurrent = document.all("HEdit0");

	var pageStart;
	var pageEnd;

	var bufferFormat = '';
	var bufferText = '';

	while (heCurrent.Search(SEARCH_INIT + SEARCH_FORWARD, TOKEN_GROUP_START, false) == SEARCH_FOUND)
	{
		var hasBreakText = false;
		heAssist.GetSelectionExt(heCurrent);
		var groupStart = { X: heAssist.XEnd, Y: heAssist.YEnd, Cell_X: heAssist.CellXEnd, Cell_Y: heAssist.CellYEnd, InTable: (heAssist.CellYEnd != -1) };

		if (groupStart.InTable)
		{
			alert('[GROUP START] cannot appear within a table');
			return;
		}

		heCurrent.SetSelection(0, 1);
		heCurrent.ReplaceSel("", 0);
		heCurrent.Paginate();
		pageStart = heAssist.GetCurrentPage(heCurrent);

		var groupBreak = { X: -1, Y: -1, Cell_X: -1, Cell_Y: -1, InTable: false };

		if (heCurrent.Search(SEARCH_FORWARD, TOKEN_GROUP_BREAK_TEXT, false) == SEARCH_FOUND)
		{
			hasBreakText = true;

			heAssist.GetSelectionExt(heCurrent);
			groupBreak.X = heAssist.XEnd;
			groupBreak.Y = heAssist.YEnd;
			groupBreak.Cell_X = heAssist.CellXEnd;
			groupBreak.Cell_Y = heAssist.CellYEnd;
			groupBreak.InTable = (heAssist.CellYEnd != -1);

			if (groupBreak.InTable)
			{
				alert('[GROUP BREAK TEXT] cannot appear within a table');
				return;
			}

			heCurrent.SetSelection(0, 1);
			heCurrent.ReplaceSel("", 0);
		}

		if (heCurrent.Search(SEARCH_FORWARD, TOKEN_GROUP_END, false) != SEARCH_FOUND)
		{
			alert('No matching [GROUP END] for [GROUP START]');
			return;
		}

		heAssist.GetSelectionExt(heCurrent);
		var groupEnd = { X: heAssist.XEnd, Y: heAssist.YEnd, Cell_X: heAssist.CellXEnd, Cell_Y: heAssist.CellYEnd, InTable: (heAssist.CellYEnd != -1) };

		if (groupEnd.InTable)
		{
			alert('[GROUP END] cannot appear within a table');
			return;
		}

		heCurrent.SetSelection(0, 1);
		heCurrent.ReplaceSel("", 0);

		if (hasBreakText)
		{
			heCurrent.SetCursor(groupBreak.X, groupBreak.Y);
			heCurrent.SetSelection(groupEnd.X, groupEnd.Y - groupBreak.Y);
			heAssist.CopyData(heCurrent);
			bufferText = heAssist.BufferText;
			bufferFormat = heAssist.BufferFormat;
			heCurrent.ReplaceSel("", 0);
		}

		heCurrent.Paginate();
		pageEnd = heAssist.GetCurrentPage(heCurrent);
		if (pageStart != pageEnd)
		{
			if (hasBreakText)
			{
				heCurrent.SetCursor(0, groupStart.Y);
				heAssist.PasteData(heCurrent, bufferFormat, bufferText);
				heAssist.GetSelectionExt(heCurrent);
				var breakTextEnd = { X: heAssist.XEnd, Y: heAssist.YEnd };
				//03Oct12   Rams    45563 - FP10 printing - the wording 'No more items on this prescription' is not printed on each FP10 (commented the following)
				/*
				heCurrent.Paginate();
				pageEnd = heAssist.GetCurrentPage(heCurrent);
				if (pageStart == pageEnd) {
				heCurrent.SetCursor(0, breakTextEnd.Y - 1);
				}
				else {
				heCurrent.SetCursor(0, groupStart.Y);
				heCurrent.SetSelection(breakTextEnd.X, breakTextEnd.Y - groupStart.Y);
				heCurrent.ReplaceSel("", 0);
				heCurrent.SetCursor(0, groupStart.Y - 1);
                    
				}
				*/
				heCurrent.SetCursor(0, breakTextEnd.Y - 1);
			}
			else
			{
				heCurrent.SetCursor(0, groupStart.Y - 1);
			}
			heCurrent.ToggleFormFeed();
			heCurrent.SetCursor(groupStart.X, groupStart.Y);
			heCurrent.Paginate();
		}
	}
	if (heCurrent.Search(SEARCH_INIT + SEARCH_FORWARD, TOKEN_NO_BREAK_END, false) == SEARCH_FOUND)
	{
		heAssist.GetSelectionExt(heCurrent);
		var noBreakStart = { X: heAssist.XEnd, Y: heAssist.YEnd, Cell_X: heAssist.CellXEnd, Cell_Y: heAssist.CellYEnd, InTable: (heAssist.CellYEnd != -1) };

		if (noBreakStart.InTable)
		{
			alert('[NO BREAK END] cannot appear within a table');
			return;
		}

		heCurrent.SetSelection(0, 1);
		heCurrent.ReplaceSel("", 0);
		heCurrent.Paginate();
		heCurrent.SetCursor(0, noBreakStart.Y - 1);
		var noBreakPage = heAssist.GetCurrentPage(heCurrent);
		heCurrent.CursorEnd();
		heAssist.GetSelectionExt(heCurrent);
		var docEnd = { X: heAssist.XEnd, Y: heAssist.YEnd, Cell_X: heAssist.CellXEnd, Cell_Y: heAssist.CellYEnd };
		var endPage = heAssist.GetCurrentPage(heCurrent);
		if (noBreakPage != endPage)
		{
			heCurrent.SetSelection(noBreakStart.X, noBreakStart.Y - docEnd.Y);
			try
			{
				heCurrent.ReplaceSel("", 0);
			}
			catch (err)
			{
			}
		}
	}
}

// *****************************************************************************************************************************************
function GetNodeText(strNodeName, strNodeText)
{
	if (strNodeName.indexOf("__") != -1)
	{
		if (strNodeName.indexOf("__INWORDS") != -1)
		{
			// Converts a numeric value to words
			strNodeText = NumberToWords(strNodeText.valueOf());
		}
		else if (strNodeName.indexOf("__YEARSOLD") != -1)
		{
			// Converts a date to an age as of today
			strNodeText = YearsOldToday(ParseTDate(strNodeText)).toString();
		}
		else if (strNodeName.indexOf("__DATE") != -1)
		{
			//17Feb03 TH Added. Converts Db date into format dd/mm/yyyy
			strNodeText = strNodeText.substr(8, 2) + "/" + strNodeText.substr(5, 2) + "/" + strNodeText.substr(0, 4);
		}
	}
	else
	{
		while (strNodeText.search(/\x5BCR\x5D/) != -1)
		{
			strNodeText = strNodeText.replace("[CR]", String.fromCharCode(13));
		}
		while (strNodeText.search(/\x5BTAB\x5D/) != -1)
		{
			strNodeText = strNodeText.replace("[TAB]", String.fromCharCode(9));
		}
	}

	strNodeText = XMLReturn(XMLReturn(strNodeText));
	strNodeText = ConvertXMLLfToCrLf(strNodeText);

	return strNodeText;
}

// *****************************************************************************************************************************************
function ConvertXMLLfToCrLf(strText)
{
	var intPos;

	intPos = strText.indexOf(String.fromCharCode(10), 0);
	while (intPos > -1)
	{
		strText = strText.substring(0, intPos) + String.fromCharCode(13) + strText.substr(intPos);
		intPos = strText.indexOf(String.fromCharCode(10), intPos + 2);
	}

	return strText;
}

// *****************************************************************************************************************************************

function btnDone_onclick()
{
	document.all("HEdit0").ReadOnly = false;
	try
	{
		window.parent.DocumentPrinted(m_strReportName, m_strDeviceName);
	}
	catch (e) { }
}

// *****************************************************************************************************************************************

function btnCancel_onclick()
{
	PrintCancelled();
}

// *****************************************************************************************************************************************

function PrintCancelled()
{
	document.all("HEdit0").ReadOnly = false;
	try
	{
		window.parent.PrintCancelled(m_strReportName, m_strDeviceName);
	}
	catch (e) { }
}

function decode64(input)
{
	var output = "";
	var chr1, chr2, chr3 = "";
	var enc1, enc2, enc3, enc4 = "";
	var i = 0;
	// remove all characters that are not A-Z, a-z, 0-9, +, /, or = 
	var base64test = /[^A-Za-z0-9\+\/\=]/g;
	if (base64test.exec(input))
	{
		alert("There were invalid base64 characters in the input text.\n" +
              "Valid base64 characters are A-Z, a-z, 0-9, '+', '/',and '='\n" +
              "Expect errors in decoding.");
	}
	input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
	do
	{
		enc1 = keyStr.indexOf(input.charAt(i++));
		enc2 = keyStr.indexOf(input.charAt(i++));
		enc3 = keyStr.indexOf(input.charAt(i++));
		enc4 = keyStr.indexOf(input.charAt(i++));
		chr1 = (enc1 << 2) | (enc2 >> 4);
		chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
		chr3 = ((enc3 & 3) << 6) | enc4;
		output = output + String.fromCharCode(chr1);
		if (enc3 != 64)
		{
			output = output + String.fromCharCode(chr2);
		}
		if (enc4 != 64)
		{
			output = output + String.fromCharCode(chr3);
		}
		chr1 = chr2 = chr3 = "";
		enc1 = enc2 = enc3 = enc4 = "";
	} while (i < input.length);
	return unescape(output);
}