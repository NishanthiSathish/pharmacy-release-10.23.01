<%@ Page language="vb" %>
<!--#include file="ASPHeader.aspx"-->
<html>
<head>
<title>Change Options</title>
<%
    '----------------------------------------------------------------------------------------------------
    '
    'Generic options page
    '
    'Useage:
    'pass the options to be rendered on the dialogArguments property in xml as follows:
    '<*>
    '<setting key='text or numerical key' type='bit' value='default value' description='text for display' [enabled='{1|0}'] />
    ''
    '</*>
    '
    'Returns:
    'XML as above, with the new values overwriting the old.
    'Or an empty string if cancel was pressed
    '
    'Notes:
    '- Each value of the "key" attribute must be unique.
    '- enabled is assumed to be '1' if not specified
    '
    '- The following data types are supported at present; more can be added as required:
    'type:					valid values:
    'bit						1 or 0
    '
    '
    '
    'Modification History:
    '06May05 AE  Written
    '
    '----------------------------------------------------------------------------------------------------
%>


<style>
.OptionsTable
{
	background-color:#ffeeee;
	border-right:#ffffff 1px solid;
	border-bottom:#ffffff 1px solid;
	border-top:midnightblue 1px solid;
	border-left:midnightblue 1px solid;
}



</style>


<script language="javascript">
window.returnValue = '';
window.dialogHeight='300px';
window.dialogWidth='400px';


function OptionsRender(){

var strKey = '';
var strValue = '';
var strType = '';
var strDescription = '';
var blnSkip = false;
var blnEnabled = true;

//render the specified options
    if (configData.XMLDocument.loadXML(window.dialogArguments)) {

		var colOptions = configData.XMLDocument.selectNodes('//setting');
		for (intCount = 0; intCount < colOptions.length; intCount++){
		
		//Read this option from the xml, warn if anything is missing
			strType = colOptions[intCount].getAttribute('type').toLowerCase();
			strKey = colOptions[intCount].getAttribute('key');
			strValue = colOptions[intCount].getAttribute('value');
			strDescription = colOptions[intCount].getAttribute('description');
			blnEnabled = (colOptions[intCount].getAttribute('enabled') != '0');
			blnSkip = false;
			
			if (strKey == null || strKey == '') {
				ErrorRender('The required attribute "key" was missing');
				blnSkip = true;
			}
			
		//Now render the appropriate control type:
			if (!blnSkip){
				switch (strType){
					case 'bit':
						OptionsRender_Bit(strKey, strValue, strDescription, blnEnabled)
						break;
				
						//
						// more ...
						//
						
					default:
						ErrorRender('The required attribute "type" was missing, or specified an unrecognised type.');
						break;
				}
			}
		}

	}
	else {
		ErrorRender('The XML specified in dialogArguments was missing or invalid');
	}
}

//-----------------------------------------------------------------------------------------------------------------
function OptionsRender_Bit(strKey, strValue, strText, blnEnabled){
//Render a checkbox type option

	var objRow = tblOptions.insertRow();
	objRow.disabled = !blnEnabled;
	var objControlCell = objRow.insertCell();
	var objCheckbox = document.createElement('input');
	objCheckbox.setAttribute ('type', 'checkbox');
	objControlCell.appendChild(objCheckbox);
	var objTextCell = objRow.insertCell();

	objCheckbox.id = 'inputObject';
	objCheckbox.checked = (Number(strValue) == 1)
	objCheckbox.disabled = !blnEnabled;
	
	objRow.setAttribute('key', strKey);
	objTextCell.innerText = strText;
	objTextCell.style.width = '100%';
}

//-----------------------------------------------------------------------------------------------------------------
function ErrorRender(strText){
//Adds a warning row to the table

	var objRow = tblOptions.insertRow();
	var objTextCell = objRow.insertCell();
	objTextCell.className = 'StatusMessage';
	objTextCell.innerText = strText;

}

//-----------------------------------------------------------------------------------------------------------------
function CloseForm(blnCancel){
//Return the data, unless cancel was pressed

var xmlElement;
var strKey = '';
var strValue = '';
var strType = '';

	window.returnValue = '';
	if (!blnCancel){
		//Fetch each option from the screen, and update its value in the xml island
		for (intCount = 0; intCount < tblOptions.rows.length; intCount ++){
			strKey = tblOptions.rows[intCount].getAttribute('key');
			if (strKey != '' && strKey != null){
				xmlElement = configData.XMLDocument.selectSingleNode('//setting[@key="' + strKey + '"]');
				strType = xmlElement.getAttribute('type').toLowerCase();
				switch(strType){
					case 'bit':
						strValue = tblOptions.rows[intCount].all['inputObject'].checked ? '1' : '0';
						break;
						
						//
						//	more...
						//
						
					default:
						strValue = 'unknown';
						break;
				}
				xmlElement.setAttribute('value', strValue);	
			}
		}
		window.returnValue = configData.XMLDocument.xml;
	}
	void window.close();

}
</script>
<link rel='stylesheet' type='text/css' href='../../style/application.css' />
</head>
<body onload="OptionsRender();" style="overflow:hidden">

<table style="height:100%;width:100%">
	<tr>
		<td class="PaneCaption">
			&nbsp;
		</td>
	</tr>
	
	<tr>
		<td style="height:100%">
			<div style="height:100%;overflow-y:auto;">
				
				<table id="tblOptions" style="width:100%" class="OptionsTable">
				</table>	
	
			</div>
		</td>
	</tr>
	
	<tr>
		<td align="right">
			<table>
				<tr>
					<td><button tabindex='9' id='cmdOK' accesskey='o' onClick='void CloseForm(false);'><u>O</u>K</button></td>
					<td><button tabindex='10' id='cmdCancel' accesskey='n' onClick='void CloseForm(true);'>Ca<u>n</u>cel</button></td>
				</tr>
			</table>		
		</td>
	</tr>


</table>






<xml id="configData"></xml>

</body>
</html>
