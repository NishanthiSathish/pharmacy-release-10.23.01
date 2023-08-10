/*

	Grid.js
	

	Events:
		grdCell_onclick(strGridID, intCol, intRow);
		grdRow_ondblclick(strGridID, intRow);
*/


// Image rendering functions

function CTL_Grid_Image_HTML(strGridID, strImageID, strImageURL)
{
	return "<img id='" + strImageID + "' src='" + strImageURL + "'>";
}

// CheckBox rendering functions

function CTL_Grid_CheckBox_HTML(strGridID, strCheckBoxID, blnChecked, intCol, intRow)
{
	var strHTML = "";
	strHTML += " <INPUT type='checkbox' id='" + strCheckBoxID + "' name='" + strCheckBoxID + "' ";
	strHTML += " onclick=' return CTL_Grid_CheckBox_onclick(" + Quote() + strGridID + Quote() + ", " + Quote() + strCheckBoxID + Quote() + ", " + Quote() + intCol + Quote() + ", " + Quote() + intRow + Quote() + ")' ";
	if (blnChecked==true)
	{
		strHTML += " CHECKED "
	}
	strHTML += " > ";
	return strHTML;	
}

function CTL_Grid_CheckBox_onclick(strGridID, strCheckBoxID, intCol, intRow)
{
	if (document.all(strCheckBoxID).checked == true)
	{
		Grid_SetCellValue(strGridID, intCol, intRow, "1" );
	}
	else
	{
		Grid_SetCellValue(strGridID, intCol, intRow, "0" );
	}
}

// TextBox rendering functions

// style="overflow: scroll" or overflow-x: scroll or overflow-y: scroll

function CTL_Grid_TextBox_HTML(strGridID, strTextBoxID, strText, intLength, strMask)
{
	var strHTML = "";
	strHTML += " <input  onselectstart='event.returnValue=true' class='ctltextbox' type='text' id='" + strTextBoxID + "' name='" + strTextBoxID + "' value='" + strText + "' mask='" + strMask + "' maxlength='" + intLength + "' size='" + intLength + "' ";
	strHTML += " onfocus=' return CTL_Grid_TextBox_onfocus(" + Quote() + strGridID + Quote() + ", " + Quote() + strTextBoxID + Quote() + ")' )' ";
	strHTML += " onblur=' return CTL_Grid_TextBox_onblur(" + Quote() + strGridID + Quote() + ", " + Quote() + strTextBoxID + Quote() + ")' )' ";
	strHTML += " onchange=' return CTL_Grid_TextBox_onchange(" + Quote() + strGridID + Quote() + ", " + Quote() + strTextBoxID + Quote() + ")' )' ";
	strHTML += " > ";
	return strHTML;
}

// Textbox events

function CTL_Grid_TextBox_onchange(strGridID, strTextBoxID)
{
	var intCol = Grid_CurrentColIndex(strGridID);
	var intRow = Grid_CurrentRowIndex(strGridID);
	Grid_SetCellValue(strGridID, intCol, intRow, document.all("txt" + strGridID + "_TextBox" + intCol).value );
}

function CTL_Grid_TextBox_onfocus(strGridID, strTextBoxID)
{
	Grid_SetRunTimeAtrribute(strGridID, "Editing", "1");
	event.srcElement.select();
}

function CTL_Grid_TextBox_onblur(strGridID, strTextBoxID)
{
	var intCol = Grid_CurrentColIndex(strGridID);
	var intRow = Grid_CurrentRowIndex(strGridID);
	Grid_SetRunTimeAtrribute(strGridID, "Editing", "0");
	event.srcElement.value = Grid_GetCellValue(strGridID, intCol, intRow);
}

// DropDown rendering functions

function CTL_Grid_DropDown_Option_HTML(strText, strUserData, blnSelected)
{
	var strHTML = "";
	strHTML += "<option "
	if (blnSelected)
	{
		strHTML += " selected ";
	}
	strHTML += " UserData=" + Quote() + strUserData + Quote() + ">" + strText + "</option>";
	return strHTML;
}

function CTL_Grid_DropDown_HTML(strGridID, strDropDownID, strOptions, strSelectedValue)
{
	var strHTML = "";
	
	strHTML += " <select id='" + strDropDownID + "' name='" + strDropDownID + "' ";
	strHTML += " onclick='return CTL_Grid_DropDown_onfocus(" + Quote() + strGridID + Quote() + ", " + Quote() + strDropDownID + Quote() + ")' ";
	strHTML += " onchange='return CTL_Grid_DropDown_onchange(" + Quote() + strGridID + Quote() + ", " + Quote() + strDropDownID + Quote() + ")' ";
	strHTML += " onkeydown='return CTL_Grid_DropDown_onkeydown(" + Quote() + strGridID + Quote() + ", " + Quote() + strDropDownID + Quote() + ")' ";
	strHTML +=  " >" + strOptions + "</select>";
	return strHTML;
}

// DropDown Events

function CTL_Grid_DropDown_onchange(strGridID, strDropDownID)
{
	var intCol = Grid_CurrentColIndex(strGridID);
	var intRow = Grid_CurrentRowIndex(strGridID);
	Grid_SetCellValue(strGridID, intCol, intRow, Grid_DropDownKeyFromIndex(strGridID, intCol, document.all("cbo" + strGridID + "_DropDown" + intCol ).selectedIndex ) );
}

function CTL_Grid_DropDown_onkeydown(strGridID, strDropDownID)
{
	switch (event.keyCode)
	{
		case 13: // Enter
		case 27: // Escape
			break;
		default:
			event.cancelBubble = true
	}
}

function CTL_Grid_DropDown_onfocus(strGridID, strDropDownID)
{
	Grid_SetRunTimeAtrribute(strGridID, "Editing", "1");
}

// Grid Rendering functions

function CTL_Grid_Layout_HTML(strGridID, strRows_HTML)
{
	var strHTML = "";
	var strCaption = "";

	var xmlDoc = document.getElementById("xmlGrid_" + strGridID).firstChild;
	
	var xmlNode = xmlDoc.selectSingleNode("//Grid/Structure");

	strHTML += "<input  onselectstart='event.returnValue=true' style='display:none' type='text' id='_focus" + strGridID + "' name='_focus" + strGridID + "' > " ;

	strHTML += "<table class='grid_container' cellpadding=0 cellspacing=0 width=" + xmlNode.getAttribute("Width") + " height=" + xmlNode.getAttribute("Height") + " ><tr><td> ";
	strHTML += "<div style='height:100%; height:100%; overflow-y:auto;' > ";

	strHTML += "<table class='grid_body' ";

	// Grid Title
	strHTML += " cellspacing='0'";
	strHTML += " width='100%'"
	strHTML += " >";
	
	strHTML += " <tr class='grid_title'><td colspan=" + xmlDoc.selectNodes("//Grid/Structure/Columns/Column").length + ">" + xmlNode.attributes.getNamedItem("Title").nodeValue + "</td></tr> ";

	// Column headings
	var xmlNodeListColumns = xmlDoc.selectNodes("//Grid/Structure/Columns/Column");
	strHTML += "<tr>";
	for (var intCol = 0; intCol<xmlNodeListColumns.length; intCol++)
	{
			strHTML += "<td class='grid_heading' nowrap ";
			if (xmlNodeListColumns(intCol).attributes.getNamedItem("Visible").nodeValue=="False")
			{
				strHTML += " style='display:none' ";

			}
			strHTML += " width='" + xmlNodeListColumns(intCol).attributes.getNamedItem("Width").nodeValue + "'";
			strHTML += " >";
			strCaption = xmlNodeListColumns(intCol).attributes.getNamedItem("Caption").nodeValue;
			if (strCaption=="")
			{
				strCaption = "&nbsp;";
			}
			strHTML += strCaption;
			strHTML += "</td>";
	}
	strHTML += "</tr>";
	
	strHTML += strRows_HTML;
	
	strHTML += "</table>";

	strHTML += "</div>";
	strHTML += "</td></tr></table>";

	return strHTML;
}

function CTL_Grid_Rows_HTML(strGridID)
{
	var intCol = 0;
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID);
	var strHTML = "";
	var intColCount; //JA 18-10-2007 Added declaration
	// Columns
	var xmlNodeListColumns = xmlDoc.selectNodes("//Grid/Structure/Columns/Column");

	// Rows
	var xmlNodeListRows = xmlDoc.selectSingleNode("//Data").firstChild.childNodes;
	//var xmlNodeListRows = xmlDoc.selectSingleNode("//Grid/Data");//.firstChild.childNodes;

	var intRowCount = xmlNodeListRows.length;

	if ( intRowCount==0 )
	{
		return "<tr class='grid_row'><td colspan='" + xmlNodeListColumns.length + "' align='center'>There are no items to show in this view</td></tr>";
	}

	if (Grid_ImageURL(strGridID)!="" )
	{
		var xmlNode;
		var xmlNewNode;
		var xmlNamedNodeMap;
		var xmlNewAttr;
		for (var intRow = 0; intRow < intRowCount; intRow++)
		{
			xmlNode = xmlNodeListRows(intRow);
			
			xmlNewNode = xmlDoc.createNode("Element", xmlNode.nodeName, "");
			xmlNamedNodeMap = xmlNewNode.attributes;
   
			xmlNewAttr = xmlDoc.createAttribute("_Image");
			xmlNewAttr.nodeValue = Grid_ImageURL(strGridID);
   
			xmlNamedNodeMap.setNamedItem(xmlNewAttr);
			   
			for (intCol = 0; intCol < xmlNode.attributes.length; intCol++)
			{
			   xmlNewAttr = xmlDoc.createAttribute(xmlNode.attributes(intCol).nodeName);
			   xmlNewAttr.nodeValue = xmlNode.attributes(intCol).nodeValue;
			   xmlNamedNodeMap.setNamedItem(xmlNewAttr);
			}
			xmlNode.parentNode.replaceChild(xmlNewNode, xmlNode);
		}
	}

	if (Grid_HasTicks(strGridID)=="1" )
	{
		var xmlNode;
		var xmlNewNode;
		var xmlNamedNodeMap;
		var xmlNewAttr;
		for (var intRow = 0; intRow < intRowCount; intRow++)
		{
			xmlNode = xmlNodeListRows(intRow);
			
			xmlNewNode = xmlDoc.createNode("Element", xmlNode.nodeName, "");
			xmlNamedNodeMap = xmlNewNode.attributes;
   
			xmlNewAttr = xmlDoc.createAttribute("_Tick");
			xmlNewAttr.nodeValue = "0";
   
			xmlNamedNodeMap.setNamedItem(xmlNewAttr);
			   
			for (intCol = 0; intCol < xmlNode.attributes.length; intCol++)
			{
			   xmlNewAttr = xmlDoc.createAttribute(xmlNode.attributes(intCol).nodeName);
			   xmlNewAttr.nodeValue = xmlNode.attributes(intCol).nodeValue;
			   xmlNamedNodeMap.setNamedItem(xmlNewAttr);
			}
			xmlNode.parentNode.replaceChild(xmlNewNode, xmlNode);
		}
	}

	if (xmlNodeListRows.length>0)
	{
		//11Dec03 ATW changed count ; was blowing up during iteration
		intColCount = xmlNodeListColumns.length;
	}
	

	Grid_SetRunTimeAtrribute(strGridID, "ColCount", intColCount);
	Grid_SetRunTimeAtrribute(strGridID, "RowCount", intRowCount);


	for (var intRow = 0; intRow < intRowCount; intRow++)
	{
		strHTML += "<tr class='grid_row' id='" + strGridID + "#" + intRow.toString() + "' ";
		strHTML += " ondblclick='return GridRow_ondblclick(" + Quote() + strGridID + Quote() + ", " + intRow + ")' ";
		strHTML += " >";
		for (intCol = 0; intCol < intColCount; intCol++)
		{
				strHTML += "<td ";
				if (xmlNodeListColumns(intCol).attributes.getNamedItem("Visible").nodeValue=="False")
				{
					strHTML += " style='display:none' ";

				}
				switch ( Grid_ColumnEditControlType(strGridID, intCol) )
				{
					case "":
					case "Image":
						strHTML += " tabindex=-1 ";
						break;
					default:
						strHTML += " tabindex=0 ";
						break;
				}
				strHTML += " class='grid_cell' id='" + strGridID + "#" + intCol.toString() + ":" + intRow.toString() + "' row='" + intRow.toString() + "' col='" + intCol.toString() + "' ";
				strHTML += " onclick='return GridCell_onclick(" + Quote() + strGridID + Quote() + ", " + intCol + ", " + intRow + ")' ";
				strHTML += " onkeydown='return GridCell_onkeydown(" + Quote() + strGridID + Quote() + ")' ";
				strHTML += " > ";
				switch ( Grid_ColumnEditControlType(strGridID, intCol) )
				{
					case "CheckBox":
						strHTML += CTL_Grid_CheckBox_HTML(strGridID, "chk" + strGridID + "_CheckBox_" + intCol + "_"+ intRow, xmlNodeListRows(intRow).attributes(intCol).nodeValue, intCol, intRow);
						break;
					case "DropDown":
						strHTML += Grid_DropDownTextFromKey(strGridID, intCol, xmlNodeListRows(intRow).attributes(intCol).nodeValue);
						break;
					case "Image":
						strHTML += CTL_Grid_Image_HTML(strGridID, "img" + intCol + "_" + intRow, xmlNodeListRows(intRow).attributes(intCol).nodeValue);
						break;
					default:
						strHTML += xmlNodeListRows(intRow).attributes(intCol).nodeValue;
						break;
				}
				strHTML += "</td>";
		}
		strHTML += "</tr>";
	}

	return strHTML;
}

function CTL_Grid_Draw(strGridID)
{
	document.getElementById("CTL_Grid_" + strGridID).insertAdjacentHTML( "afterBegin", CTL_Grid_Layout_HTML(strGridID, CTL_Grid_Rows_HTML(strGridID)) );
	Grid_DrawRow(strGridID, 0);
	Grid_DrawRowCursor(strGridID, 0,0 );
}

// Grid Events

function GridCell_onclick(strGridID, intCol, intRow)
{
	Grid_MoveCursor(strGridID, intCol, intRow);
	if ( typeof( grdCell_onclick )=="function" )
	{
		grdCell_onclick(strGridID, intCol, intRow);
	}
}

function GridRow_ondblclick(strGridID, intRow)
{
	Grid_MoveCursor(strGridID, 0, intRow);
	
	if ( typeof( grdRow_ondblclick )=="function" )
	{
		grdRow_ondblclick(strGridID, intRow);
	}
}

function GridCell_onkeydown(strGridID)
{
	var blnCursorMoved = false;
	var intNewCol = Grid_CurrentColIndex(strGridID);
	var intNewRow = Grid_CurrentRowIndex(strGridID);
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID);
	var xmlNodeListColumns = xmlDoc.selectNodes("//Grid/Structure/Columns/Column");
		
	if ( Grid_GetRunTimeAtrribute(strGridID, "Editing") == "0" )
	{
		
		switch (event.keyCode)
		{
			case 39: // cursor right
				while (true)
				{
					intNewCol++;
					if ( intNewCol >= Grid_ColCount(strGridID) )
					{
						intNewCol = Grid_CurrentColIndex(strGridID);
						break;
					}
					if ( xmlNodeListColumns(intNewCol).attributes.getNamedItem("Visible").nodeValue!="False" )
					{
						blnCursorMoved = true;
						break;
					}
				}
				break;
			case 37: // cursor left
				while (true)
				{
					intNewCol--;
					if ( intNewCol < 0 )
					{
						intNewCol = Grid_CurrentColIndex(strGridID);
						break;
					}
					if ( xmlNodeListColumns(intNewCol).attributes.getNamedItem("Visible").nodeValue!="False" )
					{
						blnCursorMoved = true;
						break;
					}
				}
				break;
			case 38: // cursor up
				blnCursorMoved = true;
				intNewRow--;
				break;
			case 40: // cursor down
				blnCursorMoved = true;
				intNewRow++;
				break;
			case 33: // page up
				break;
			case 34: // page down
				break;
		}

		if (blnCursorMoved)
		{
			blnCursorMoved = false;
			if ( intNewRow >= Grid_RowCount(strGridID) )
			{
				intNewRow = Grid_RowCount(strGridID) - 1;
			}
			else if ( intNewCol >= Grid_ColCount(strGridID) )
			{
				intNewRow = Grid_ColCount(strGridID) - 1;
			}
			else if ( intNewRow < 0 )
			{
				intNewRow = 0;
			}
			else if ( intNewCol < 0 )
			{
				intNewCol = 0;
			}
			else
			{
				blnCursorMoved = true;
			}
			if (blnCursorMoved)
			{
				Grid_MoveCursor(strGridID, intNewCol, intNewRow);
			}
		}
		else
		{
			switch ( Grid_ColumnEditControlType(strGridID, intNewCol) )
			{
				case "TextBox":
				case "DropDown":
					if ( event.keyCode==13 ) // Enter
					{
						Grid_SetRunTimeAtrribute(strGridID, "Editing", "1");
						if ( typeof( Grid_GetSelectedCellNode )=="function" )
						{
							Grid_GetSelectedCellNode(strGridID).firstChild.focus();
						} 
					}
			}
		}

	}
	else
	{
		switch (event.keyCode)
		{
			case 27: // Escape
			case 13: // Enter
				Grid_SetRunTimeAtrribute(strGridID, "Editing", "0");
				Grid_MoveCursor( strGridID, intNewCol, intNewRow );
				document.all( strGridID + "#" + intNewCol.toString() + ":" + intNewRow.toString() ).focus(); 
				break;
		}
	}
}

// Grid functions

function Grid_MoveCursor(strGridID, intCol, intRow)
{
	var intLastCol = Grid_CurrentColIndex(strGridID);
	var intLastRow = Grid_CurrentRowIndex(strGridID);
	var intColCount = Grid_ColCount(strGridID);
	var nodRow;

	if ( intCol!=intLastCol || intRow!=intLastRow )
	{

		Grid_SetRunTimeAtrribute(strGridID, "Editing", "0");

		if (intLastRow != intRow)
		{	
			document.all("_focus" + strGridID).style.display ="inline";
			document.all("_focus" + strGridID).focus();
			document.all("_focus" + strGridID).style.display ="none";

			// Previous Row
			nodRow = Grid_GetSelectedRowNode(strGridID);
			nodRow.className = "grid_row";

			// Previous Cell
			for (var intThisCol = 0; intThisCol < intColCount; intThisCol++)
			{
				Grid_DrawCell(strGridID, intThisCol, intLastRow);
			}

			Grid_DrawRow(strGridID, intRow);
			
		}

		Grid_DrawRowCursor(strGridID, intRow, intCol);
		if (document.activeElement != Grid_GetCellNode(strGridID, intCol, intRow).firstChild )
		{
			try
			{
				document.all( strGridID + "#" + intCol.toString() + ":" + intRow.toString() ).focus(); 
			}
			catch(e) {}
		}
		
	}
}

function Grid_DrawCell(strGridID, intCol, intRow)
{
	var nodCell = Grid_GetCellNode(strGridID, intCol, intRow);
	nodCell.className = "grid_cell";
	switch ( Grid_ColumnEditControlType(strGridID, intCol) )
	{
		case "CheckBox":
			nodCell.innerHTML = CTL_Grid_CheckBox_HTML( strGridID, "chk" + strGridID + "_CheckBox_" + intCol + "_"+ intRow, Grid_GetCellValue(strGridID, intCol, intRow), intCol, intRow );
			break;
		case "Image":
			nodCell.innerHTML = "<img src='" + Grid_GetCellValue( strGridID, intCol, intRow ) + "' >";
			break;
		default:
			nodCell.innerHTML = Grid_GetCellValue( strGridID, intCol, intRow );
			break;
	}
}

function Grid_DrawRow(strGridID, intRow)
{
	var intColCount = Grid_ColCount(strGridID);
	var nodCell;
	var nodRow;

	nodRow = Grid_GetRowNode(strGridID, intRow);
	if (nodRow!=null)
	{
		nodRow.className = "grid_row_selected";

		for (var intThisCol = 0; intThisCol < intColCount; intThisCol++)
		{
			nodCell = Grid_GetCellNode(strGridID, intThisCol, intRow);
			switch ( Grid_ColumnEditControlType(strGridID, intThisCol) )
			{
				case "CheckBox":
					nodCell.innerHTML = CTL_Grid_CheckBox_HTML(strGridID, "chk" + strGridID + "_CheckBox_" + intThisCol + "_"+ intRow, Grid_GetCellValue(strGridID, intThisCol, intRow), intThisCol, intRow );
					break;
				case "TextBox":
					nodCell.innerHTML = CTL_Grid_TextBox_HTML(strGridID, "txt" + strGridID + "_TextBox" + intThisCol, Grid_GetCellValue(strGridID, intThisCol, intRow), Grid_GetColumnTextBoxAttributeValue(strGridID, intThisCol, "Length"), Grid_GetColumnTextBoxAttributeValue(strGridID, intThisCol, "Mask") );
					break;
				case "Image":
					nodCell.innerHTML = CTL_Grid_Image_HTML(strGridID, "img" + intThisCol + "_" + intRow, Grid_GetCellValue(strGridID, intThisCol, intRow));
					break;
				case "DropDown":
					var strOptions = "";
					for (var intIndex = 0; intIndex < Grid_GetColumnDropDownOptionCount(strGridID, intThisCol); intIndex++)
					{
						strOptions += CTL_Grid_DropDown_Option_HTML( Grid_GetColumnDropDownOptionAttribute(strGridID, intThisCol, intIndex, "Text"), Grid_GetColumnDropDownOptionAttribute(strGridID, intThisCol, intIndex, "Key"), Grid_GetCellComboKey(strGridID, intThisCol, intRow)==Grid_GetColumnDropDownOptionAttribute(strGridID, intThisCol, intIndex, "Key") );
					}
					nodCell.innerHTML = CTL_Grid_DropDown_HTML(strGridID, "cbo" + strGridID + "_DropDown" + intThisCol, strOptions, "Allow" );
					break;
			}
		}
	}
}

function Grid_DrawRowCursor(strGridID, intRow, intCol)
{
	var intColCount = Grid_ColCount(strGridID);
	var nodCell;

	for (var intThisCol = 0; intThisCol < intColCount; intThisCol++)
	{
		nodCell = Grid_GetCellNode(strGridID, intThisCol, intRow);
		if ( intThisCol == intCol )
		{
			nodCell.className = "grid_cell_selected";
		}
		else
		{
			nodCell.className = "grid_cell";
		}
	}
	Grid_SetCurrentColRow(strGridID, intCol, intRow);
}
			
function Grid_SetCellValue(strGridID, intCol, intRow, varValue)
{
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID).firstChild;
	var xmlNodeRow = xmlDoc.selectSingleNode("//Data").firstChild.childNodes(intRow);
	//var xmlNodeRow = xmlDoc.selectSingleNode("//Grid/Data");//.firstChild.childNodes(intRow);
	xmlNodeRow.attributes(intCol).nodeValue = varValue;
}

function Grid_GetCellValue(strGridID, intCol, intRow)
{
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID).firstChild;
	var xmlNodeRow = xmlDoc.selectSingleNode("//Data").firstChild.childNodes(intRow);
    //var xmlNodeRow = xmlDoc.selectSingleNode("//Grid/Data");//.firstChild.childNodes(intRow);
	switch ( Grid_ColumnEditControlType(strGridID, intCol) )
	{
		case "DropDown":
			return Grid_DropDownTextFromKey(strGridID, intCol, xmlNodeRow.attributes(intCol).nodeValue)
			break;
		default:
			return xmlNodeRow.attributes(intCol).nodeValue;
			break;
	}

}

function Grid_GetCellComboKey(strGridID, intCol, intRow)
{
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID).firstChild;
	var xmlNodeRow = xmlDoc.selectSingleNode("//Data").firstChild.childNodes(intRow);
	//var xmlNodeRow = xmlDoc.selectSingleNode("//Grid/Data");//.firstChild.childNodes(intRow);
	return xmlNodeRow.attributes(intCol).nodeValue;
}

function Grid_GetSelectedCellNode(strGridID)
{
	return Grid_GetCellNode(strGridID, Grid_CurrentColIndex(strGridID), Grid_CurrentRowIndex(strGridID));
}

function Grid_GetCellNode(strGridID, intCol, intRow)
{
	return document.getElementById( strGridID + "#" + intCol.toString() + ":" + intRow.toString() );
}

function Grid_CurrentColIndex(strGridID)
{
	return Grid_GetRunTimeAtrribute(strGridID, "Col");
}

function Grid_CurrentRowIndex(strGridID)
{
	return Grid_GetRunTimeAtrribute(strGridID, "Row");
}

function Grid_ColCount(strGridID)
{
	return Grid_GetRunTimeAtrribute(strGridID, "ColCount");
}

function Grid_RowCount(strGridID)
{
	return Grid_GetRunTimeAtrribute(strGridID, "RowCount");
}

function Grid_SetCurrentColRow(strGridID, intCol, intRow)
{
	Grid_SetRunTimeAtrribute(strGridID, "Col", intCol);
	Grid_SetRunTimeAtrribute(strGridID, "Row", intRow);
}

function Grid_GetRunTimeAtrribute(strGridID, strName)
{
	return document.getElementById("xmlGrid_" + strGridID).firstChild.selectSingleNode("RunTime").attributes.getNamedItem(strName).nodeValue;
}

function Grid_SetRunTimeAtrribute(strGridID, strName, varValue)
{
	document.getElementById("xmlGrid_" + strGridID).firstChild.selectSingleNode("RunTime").attributes.getNamedItem(strName).nodeValue = varValue;
}

function Grid_GetSelectedRowNode(strGridID)
{
	return Grid_GetRowNode(strGridID, Grid_CurrentRowIndex(strGridID));
}

function Grid_GetRowNode(strGridID, intRow)
{
	return document.getElementById( strGridID + "#" + intRow.toString() );
}

function Grid_ColumnEditControlType(strGridID, intCol)
{
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID).firstChild;
	var xmlNodeListColumns = xmlDoc.selectNodes("//Grid/Structure/Columns/Column");
	return xmlNodeListColumns(intCol).attributes.getNamedItem("ControlType").nodeValue;
}

function Grid_GetColumnTextBoxAttributeValue(strGridID, intCol, strAttributeName)
{
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID).firstChild;
	var xmlNodeListColumns = xmlDoc.selectNodes("//Grid/Structure/Columns/Column");
	return xmlNodeListColumns(intCol).firstChild.attributes.getNamedItem(strAttributeName).nodeValue;
}

function Grid_GetColumnDropDownOptionCount(strGridID, intCol)
{
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID).firstChild;
	var xmlNodeListColumns = xmlDoc.selectNodes("//Grid/Structure/Columns/Column");
	return xmlNodeListColumns(intCol).childNodes.length;
}

function Grid_GetColumnDropDownOptionAttribute(strGridID, intCol, intIndex, strAttributeName)
{
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID).firstChild;
	var xmlNodeListColumns = xmlDoc.selectNodes("//Grid/Structure/Columns/Column");
	return xmlNodeListColumns(intCol).childNodes(intIndex).attributes.getNamedItem(strAttributeName).nodeValue;
}

function Grid_DropDownTextFromKey(strGridID, intCol, strKey)
{
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID).firstChild;
	var xmlNodeListColumns = xmlDoc.selectNodes("//Grid/Structure/Columns/Column");
	var xmlDropDownOptions = xmlNodeListColumns(intCol).childNodes;

	var intOptionCount = xmlDropDownOptions.length;
	var intIndex=0;
	while (intIndex < intOptionCount)
	{
		if ( xmlDropDownOptions(intIndex).attributes.getNamedItem("Key").nodeValue == strKey )
		{
			return xmlDropDownOptions(intIndex).attributes.getNamedItem("Text").nodeValue;
			break;
		}
		intIndex++;
	}
	return "[ERROR: Option not found]"
}

function Grid_DropDownIndexFromKey(strGridID, intCol, strKey)
{
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID).firstChild;
	var xmlNodeListColumns = xmlDoc.selectNodes("//Grid/Structure/Columns/Column");
	var xmlDropDownOptions = xmlNodeListColumns(intCol).childNodes;

	var intOptionCount = xmlDropDownOptions.length;
	var intIndex=0;
	while (intIndex < intOptionCount)
	{
		if ( xmlDropDownOptions(intIndex).attributes.getNamedItem("Key").nodeValue == strKey )
		{
			return intIndex;
			break;
		}
		intIndex++;
	}
	return 0;
}

function Grid_DropDownKeyFromIndex(strGridID, intCol, intIndex)
{
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID).firstChild;
	var xmlNodeListColumns = xmlDoc.selectNodes("//Grid/Structure/Columns/Column");
	var xmlDropDownOptions = xmlNodeListColumns(intCol).childNodes;

	return xmlDropDownOptions(intIndex).attributes.getNamedItem("Key").nodeValue;
}

function Grid_HasTicks(strGridID)
{
	return Grid_GetRunTimeAtrribute(strGridID, "Tickable");
}

function Grid_ImageURL(strGridID)
{
	return Grid_GetRunTimeAtrribute(strGridID, "ImageURL");
}

function Quote()
{
	return String.fromCharCode(34); 
}

function Grid_TickRow(strGridID, intRow, blnTicked)
{
	if (blnTicked)
	{
		Grid_SetCellValue(strGridID, 0, intRow, "1" );
	}
	else
	{
		Grid_SetCellValue(strGridID, 0, intRow, "0" );
	}

	Grid_DrawCell(strGridID, 0, intRow);
}

function FindRowByValue(strGridID, intCol, varValue)
{
	var xmlDoc = document.getElementById("xmlGrid_" + strGridID);

	var xmlNodeListRows = xmlDoc.selectSingleNode("//Data").firstChild.childNodes;
    //var xmlNodeListRows = xmlDoc.selectSingleNode("//Grid/Data");//.firstChild.childNodes;
	var intRowCount = xmlNodeListRows.length;

	var blnFound = false;

	for (var intRow=0; intRow < intRowCount; intRow++)
	{
		if ( xmlNodeListRows(intRow).attributes(intCol).nodeValue == varValue )
		{
			blnFound = true;
			break;
		}
	}
	if (blnFound==true)
	{
		return intRow;
	}
	else
	{
		return -1;
	}
}

function CTL_Grid_SyncXML(strGridID)
{
	document.all("txt" + strGridID + "_XML").value = document.getElementById("xmlGrid_" + strGridID).selectSingleNode("//Data").firstChild.xml;
}
