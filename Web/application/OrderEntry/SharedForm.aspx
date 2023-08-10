<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import namespace="Ascribe.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Dss" %>
<%@ Import Namespace="Ascribe.Common.OrderForm" %>

<%
    Dim sessionId As Integer
    
    sessionId = CInt(Request.QueryString("SessionID"))
%>


<script language="vb" runat="server">

    'SharedForm.aspx
    '
    'Used for viewing/editing shared columns
    '
    'The page takes query string parameters as follows:
    '
    'SessionID 	(mandatory)						:		The standard security token
    '
    '-----------------------------------------------------------------------
    'Modification History:
    '18Nov02 AE  Written
    ''			(in development)
    '13Sep03 AE  Now traps attempts to view deleted items
    '24May04 AE  Bulk of the code moved into OrderForm.vb for clarity.
    '02Nov05 AE  Removed onload call to PositionProblemDiv (was crashing on items in ordersets).
	'			Now is called from NavigateToForm, and only does the work once.
	'PR 05-05-09 - F0052946 - Fixed the scripting of the controls. The creation of a div element had been commented out, causing all sorts of grief
    'Script the given layout.
    Dim intOrdinal As Integer 
    Dim blnDisplayMode As Boolean
    Dim blnTemplateMode As Boolean 
    Dim lngFrameID As Integer 
    Dim strTableIDList As String 
    Dim EpisodeID As Integer 
    'Tidy up.
	Dim objSharedDetailRead As OCSRTL10.SharedDetailRead
	Dim xmldocForm As XmlDocument
    'Form contain Shared Columns
	Dim xmlnodelistTable As XmlNodeList
	Dim xmlnodeTable As XmlElement
	Dim xmlnodelistCol As XmlNodeList
	Dim xmlnodeCol As XmlElement
	Dim xmlnodelistLookup As XmlNodeList
	Dim xmlnodeLookup As XmlElement
    
    Sub ScriptMetaFields(ByVal xmlnodeCol As XmlElement)
        Response.Write(" id='sharedfield' ")
        Response.Write(" name='sharedfield' ")
        If xmlnodeCol.Attributes.GetNamedItem("Nullable").Value = "0" Then
            Response.Write(" class='MandatoryField' ")
        Else
            Response.Write(" class='StandardField' ")
        End If
        Response.Write(" DataType='" & xmlnodeCol.Attributes.GetNamedItem("DataType").Value & "' ")
        Response.Write(" Nullable='" & xmlnodeCol.GetAttribute("Nullable") & "' ")
        '04Feb11    Rams    
        Response.Write(" ColumnID='" & IIf(Not XmlExtensions.AttributeExists(xmlnodeCol.ParentNode.GetAttribute("ColumnID")) AndAlso Not xmlnodeCol.GetAttribute("ColumnID") = Nothing, xmlnodeCol.GetAttribute("ColumnID"), xmlnodeCol.ParentNode.GetAttribute("ColumnID")) & "' ")
        Response.Write(" Description='" & xmlnodeCol.GetAttribute("Description") & "' ")
        Response.Write(" DisplayName='" & xmlnodeCol.GetAttribute("DisplayName") & "' ")
    End Sub

</script>

<html>
<head>

<script language="javascript" src="../sharedscripts/ocs/ocsConstants.js"></script>
<script language="javascript" src="scripts/OrderFormResizing.js" ></script>
<script language="javascript" src="scripts/OrderFormControls.js" ></script>
<script language="javascript" src="scripts/OrderFormFunctions.js" ></script>
<script language="javascript" src="../sharedscripts/Controls.js" ></script>
<script language="javascript" src="scripts/OrderFormClasses.js" ></script>
<script language="javascript" src="../sharedscripts/icwFunctions.js" ></script>
<script language="javascript" src="../sharedscripts/DateLibs.js" ></script>
<script language="javascript" src="../sharedscripts/OCS/OCSShared.js" ></script>

<%
	'Obtain the session ID from the querystring
	intOrdinal = CInt(Request.QueryString("Ordinal"))
	'If we're in display mode, script a call to set the form read-only on start up
    blnDisplayMode = Generic.CBoolX(Request.QueryString("Display"))
    blnTemplateMode = LCase(Request.QueryString("Template")) = "true"
	lngFrameID = Generic.CIntX(Request.QueryString("FrameID"))
	strTableIDList = CStr(Request.QueryString("TableIDList"))
	EpisodeID = Generic.CIntX(Request.QueryString("EpisodeID"))
%>


<link rel="stylesheet" type="text/css" href="../../style/OrderEntry.css" />
<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/SharedForm.css" />
</head>

<body id="formBody" 
		class="OrderFormBody"
		oncontextmenu="return false;"
		tabindex="-100"
		style="overflow:auto;"
		frameid="<%= lngFrameID %>"
		sid="<%= sessionId %>"
		templatemode="<%= LCase(CStr(blnTemplateMode)) %>"		
		onkeydown="if (window.event.keyCode == 27) window.parent.CloseWindow(true);"
		ordinal="<%= intOrdinal %>"
		>
<%
        'Set the form read-only if in display mode
    If blnDisplayMode Then 
    'SetReadOnly objLayout
    End IF
    'Write a hidden element which the order entry page uses to infer 																	'16Feb04 AE  improve error reporting and handling
    'whether the form loaded correctly.
    Response.Write("<p id=""loadComplete"" />")
%>



<div id="divForm" class="divForm">
<%
	Dim objSharedDetailRead As OCSRTL10.SharedDetailRead
	Dim xmldocForm As XmlDocument ' Form contain Shared Columns
    Dim xmlnodelistTable As XmlNodeList
    Dim xmlnodeTable As XmlNode
    Dim xmlnodelistCol As XmlNodeList
    Dim xmlnodeCol As XmlNode
    Dim xmlnodelistLookup As XmlNodeList
    Dim xmlnodeLookup As XmlNode

    Dim strPrevDataType As String
    Dim strCurrDataType As String
    Dim blnNewLine As Boolean
    Dim intBitFieldCount As Integer
    Dim intCtrlCount As Integer
    Dim totalCtrlCount As Integer
	'Get the shared form
	xmldocForm = New XmlDocument()
    objSharedDetailRead = New OCSRTL10.SharedDetailRead()
    xmldocForm.TryLoadXml(objSharedDetailRead.GetForm(sessionId, strTableIDList, CInt(EpisodeID)))
	objSharedDetailRead = Nothing
	'  Sort the controls by DisplayWeighting //LM 17/01/2008 Code 162
    Dim strSortedResult As String
	
	strSortedResult = ""
    
    strSortedResult = INTRTL10.modInterfaceShared.TransformXmlUsingXslFromFile(xmldocForm.OuterXml, Server.MapPath(".") + "\SharedForm.xslt")
    xmldocForm.TryLoadXml(strSortedResult)
    
	'  set initial top margin  to 0 then afterwards to 10px;
	xmlnodelistTable = xmldocForm.SelectNodes("//t")
	For Each xmlnodeTable In xmlnodelistTable
	
		'  Write opening table section div
		Response.Write("<div style='margin-bottom:16px' TableID='" & xmlnodeTable.Attributes("TableID").Value & "' Description='" & xmlnodeTable.Attributes("Description").Value & "' >")
		'  Write the table header
		Response.Write("<div class='divTableLabel' style='background-color: #d0d0d0; margin-bottom:8px; margin-top: 10px; padding-top: 1px; padding-bottom: 1px;'  >")
		Response.Write("<b>" & xmlnodeTable.Attributes("DisplayName").Value & "</b></div>")
		
		'  initialise variables
		strPrevDataType = ""
		strCurrDataType = ""
		intCtrlCount = 0
		totalCtrlCount = 0
		intBitFieldCount = 0
		
		'  create a new line <div>
		Response.Write("<div class='divColumn' style='padding-top: 4px;'>")
		xmlnodelistCol = xmlnodeTable.ChildNodes
		For Each xmlnodeCol In xmlnodelistCol
			'  set prev data type //LM 17/01/2008 Code 162 
			strPrevDataType = strCurrDataType
            strCurrDataType = xmlnodeCol.Attributes("DataType").Value
			
			'  First work out if we need to start a new line
			blnNewLine = False

			'  Check for specific control trype triggering a new line
			Select Case strCurrDataType
				Case "varchar"
					If xmlnodeCol.Attributes("Length").Value > 128 Then
						'  The text field is > 128 so we will create a textarea
						blnNewLine = True
						'  Check data type to text
						strCurrDataType = "text"
					End If
				Case "text"
					'  Because we are creating a text area we will start a new line
					blnNewLine = True
				Case "datetime"
				Case "float", "int"
				Case "bit"
			End Select

			Select Case strCurrDataType
				Case "bit"
					'  if all bits in line and ctrlCount = 3 then new line
					'  if not all bits in line and ctrl count = 1 then new line						
					If intBitFieldCount <> intCtrlCount Then
						'  Not all the controls are bit fields so we need a new line
						blnNewLine = True
					ElseIf intCtrlCount = 4 Then
						'  New line anyway
						blnNewLine = True
					End If
				Case Else
					'  if ctrl count = 2 then new line
					If intCtrlCount = 2 Then
						blnNewLine = True
					End If
					'  If we already have any bit fields we will start a new line
					If intBitFieldCount > 0 Then
						blnNewLine = True
					End If
			End Select
		
			'  If we are starting a new line then close the last line
			'				if (blnNewLine and (intCtrlCount > 0)) or (totalCtrlCount = 0) then
			If blnNewLine Then
				Response.Write("</div>")
				intCtrlCount = 0
				intBitFieldCount = 0
				Response.Write("<div class='divColumn' style='padding-top: 2px; padding-bottom: 1px;'>")
			End If
			
            Dim valign As String
			valign = "middle"
			If strCurrDataType = "text" Then
				valign = "top"
			End If
			Response.Write("<label class='LabelField divColumnLabel' style='border: solid #e0e0e0 1px; background-color: #f0f0f0; width: 15%; margin-left: 8px; padding-left: 2px; margin-right: 4px; padding-right: 2px; vertical-align: " + valign + "'>" & xmlnodeCol.GetAttribute("DisplayName") & "</label>")
			Response.Write("<span class='ColumnValue'>")
			'  Increment the control count /LM 17/01/2008 Code 162 
			intCtrlCount = intCtrlCount + 1
			totalCtrlCount = +1
			If xmlnodeCol.ChildNodes.Count() > 0 Then
				'Render lookup combo
                xmlnodelistLookup = xmlnodeCol.FirstChild.ChildNodes
				Response.Write("<select ")
				ScriptMetaFields(xmlnodeCol)
				Response.Write(" >")
				For Each xmlnodeLookup In xmlnodelistLookup
                    Response.Write("<option value='" & xmlnodeLookup.Attributes(0).Value & "'")
                    '04Feb11    Rams    //04Feb11    Rams   F0108102 - MRSA form appears to be broken, the DSS checking screen states patient type and high risk patient fields must be completed. High risk patient does not exist on form and patient type has been entered
                    'Duplicate ColumnID and description from the select element as getdata wil browse through the optioon elemnt
                    Response.Write(" ColumnID='" & IIf(Not XmlExtensions.AttributeExists(xmlnodeCol.ParentNode.GetAttribute("ColumnID")) AndAlso Not xmlnodeCol.Attributes("ColumnID") Is Nothing, xmlnodeCol.Attributes("ColumnID").Value, xmlnodeCol.ParentNode.Attributes("ColumnID").Value) & "' ")
                    Response.Write(" Description='" & xmlnodeCol.Attributes("Description").Value & "' ")
                    Response.Write(" DataType='" & xmlnodeCol.Attributes("DataType").Value & "' ")
                    Response.Write(" IsOption='true'")
                    'End of duplicating 
                    If XmlExtensions.AttributeExists(xmlnodeCol.GetAttribute("Value")) AndAlso xmlnodeLookup.Attributes(0).Value = xmlnodeCol.Attributes("Value").Value Then
                        Response.Write(" selected ")
                    End If
					Response.Write(">" & xmlnodeLookup.Attributes(1).Value & "</option>")
				Next
				Response.Write("</select>")
			Else
				'Render normal imputs
				Select Case strCurrDataType	'//LM 17/01/2008 Code 162 
					Case "varchar"
						Response.Write("<input type='text' ")
						ScriptMetaFields(xmlnodeCol)
						Response.Write(" style='vertical-align: middle; width: 30%' ")
                        Response.Write("    maxlength='" & xmlnodeCol.Attributes("Length").Value & "' ")
                        Response.Write("    size='" & Generic.Min(CInt(xmlnodeCol.Attributes("Length").Value), 80) & "' ")
                        If XmlExtensions.AttributeExists(xmlnodeCol.Attributes("Value").Value) Then
                            Response.Write("    value='" & xmlnodeCol.Attributes("Value").Value & "' ")
                        End If
						Response.Write(" >")
					Case "text"
						Response.Write("<textarea cols='80' rows='6' ")
						ScriptMetaFields(xmlnodeCol)
						Response.Write(" style='vertical-align: middle; width: 80%' ")
						Response.Write(" >")
                        If XmlExtensions.AttributeExists(xmlnodeCol.GetAttribute("Value")) Then
                            Response.Write(xmlnodeCol.GetAttribute("Value"))
                        End If
						Response.Write("</textarea>")
					Case "datetime"
						Response.Write("<span>")
						Response.Write("<input type='text' ")
						ScriptMetaFields(xmlnodeCol)
						Response.Write(" style='vertical-align: middle;' ")
						Response.Write("    maxlength='10' ")
                        If XmlExtensions.AttributeExists(xmlnodeCol.GetAttribute("Value")) Then
                            Response.Write("    value='" & Generic.Date2ddmmccyy(Generic.TDate2Date(xmlnodeCol.Attributes("Value").Value)) & "' ")
                        End If
						Response.Write("    size='7' ")
						Response.Write("    validchars='DATE:dd/mm/yyyy' ")
						Response.Write("    onKeyPress='MaskInput(this)' ")
						Response.Write("    onPaste='MaskInput(this)' ")
						Response.Write(" &nbsp; e.g. dd/mm/yyyy ")
						Response.Write(">")
						Response.Write("<img src='../../images/ocs/show-calendar.gif' onclick='CalendarShow(this, this.previousSibling);' class='linkImage'> ")
						Response.Write("</span>")
					Case "float", "int"
						Response.Write("<input type='text' ")
						ScriptMetaFields(xmlnodeCol)
						Response.Write(" style='vertical-align: middle;' ")
						Response.Write("    maxlength='16' ")
						Response.Write("    size='8' ")
                        If XmlExtensions.AttributeExists(xmlnodeCol.GetAttribute("Value")) Then
                            Response.Write("    value='" & xmlnodeCol.Attributes("Value").Value & "' ")
                        End If
						Response.Write(">")
					Case "bit"
						intBitFieldCount = intBitFieldCount + 1	'//LM 17/01/2008 Code 162 
						Response.Write("<input type='checkbox' ")
						ScriptMetaFields(xmlnodeCol)
						Response.Write(" style='vertical-align: middle;' ")

                        If XmlExtensions.AttributeExists(xmlnodeCol.GetAttribute("Value")) Then
                            If XmlExtensions.AttributeExists(xmlnodeCol.GetAttribute("Value")) AndAlso xmlnodeCol.Attributes("Value").Value = "1" Then
                                Response.Write("CHECKED")
                            End If
                        End If
						Response.Write(">")
				End Select
			End If
			Response.Write("</span>")
		Next
		'  Close column line div
		Response.Write("</div>")
		
		'  Close table section div
		Response.Write("</div>")
	Next
	xmldocForm = Nothing
%>

</div>

<!-- Holds the header of the layout with size information etc -->
<xml id=layoutData>
	<xmldata formid="<%= Request.QueryString("FrameID") %>" >
	</xmldata>
</xml>
	
<!-- Used to hold the data entered into the form -->
<xml id=instanceData>
		
</xml>


<!-- Holds the scedule XML attached to this item -->
<xml id=scheduleData>
		
</xml>

<!-- General use XML -->
<xml id='tempXML' />

<!-- Script to position the reason capture section when percentage sizing is used -->
<script language="javascript">

//18June2010 F0066673 JMei put reason capture back to icw
//function PositionProblemDiv()
//{
//}

function GetDataFromForm() // LM 17/01/2008 Code 162 
{
/*
	OCS style data XML
	<shared episodeid="123">
		<tablename columnname="value" ... />
		<tablename columnname="value" ... />
		...
	</shared>
*/

	var xmldoc = tempXML.XMLDocument;
	
	xmldoc.loadXML("<shared/>");
	
	var xmlnodeRoot = xmldoc.selectSingleNode("shared");

	xmlnodeRoot.setAttribute("episodeid", <%= EpisodeID %> );
	
	var objForm = document.getElementById("divForm");
	for (var intTableIndex = 0; intTableIndex < objForm.childNodes.length; intTableIndex++)
	{
		var objTable = objForm.childNodes(intTableIndex);
		var xmlnodeTable = xmldoc.createElement( objTable.getAttribute("Description") );
		xmlnodeRoot.appendChild(xmlnodeTable);

        var intSharedFieldCount = objTable.all["sharedfield"].length;
        if (typeof(intSharedFieldCount)=="undefined")
        {
            intSharedFieldCount = 1;
        }

		for (var intColIndex=0; intColIndex < intSharedFieldCount; intColIndex++)
		{
		    if (intSharedFieldCount==1)
		    {
			    var objCol = objTable.all["sharedfield"];
		    }
		    else
		    {
			    var objCol = objTable.all["sharedfield"](intColIndex);
			}
			if ( typeof(objCol)!="undefined" && objCol.getAttribute("ColumnID") != null )
			{
			    //04Feb11    Rams   F0108102 - MRSA form appears to be broken, the DSS checking screen states patient type and high risk patient fields must be completed. High risk patient does not exist on form and patient type has been entered
			    if(objCol.getAttribute("IsOption") == undefined || (objCol.getAttribute("IsOption")=="true" && objCol.getAttribute("selected")))
			    {
				    switch ( objCol.getAttribute("DataType") )
				    {
					    case "varchar":
					    case "float":
					    case "int":
						    xmlnodeTable.setAttribute( objCol.getAttribute("Description"), objCol.value );
						    break;

					    case "text":
						    xmlnodeTable.setAttribute( objCol.getAttribute("Description"), objCol.innerText );
						    break;

					    case "bit":
						    xmlnodeTable.setAttribute( objCol.getAttribute("Description"), objCol.checked ? "1" : "0" );
						    break;

					    case "datetime":
						    var objDateControl = new DateControl(objCol);
						    if (objDateControl.ContainsValidDate())
						    {
							    var dtCurrent = objDateControl.GetDate();
							    var strTDate = objDateControl.GetTDate();
							    xmlnodeTable.setAttribute( objCol.getAttribute("Description"), strTDate );
						    }
						    break;
				    }
				}
				
			}
		}
	}
	
	return xmldoc.xml;
}

function ValidityCheck() // LM 17/01/2008 Code 162 
{
	var objForm = document.getElementById("divForm");
	for (var intTableIndex = 0; intTableIndex < objForm.childNodes.length; intTableIndex++)
	{
		var objTable = objForm.childNodes(intTableIndex);
        var intSharedFieldCount = objTable.all["sharedfield"];

        if (typeof(intSharedFieldCount)=="undefined")
        {
            intSharedFieldCount = 0;
        }
        else
        {
            intSharedFieldCount = intSharedFieldCount.length;
        }
    
        for (var intColIndex=0; intColIndex < intSharedFieldCount; intColIndex++)
        //20Jun08 ST  Commented out as per 9.13 merges
		//for (var intColIndex=0; intColIndex < objTable.all["sharedfield"].length; intColIndex++)
		{
		    if (intSharedFieldCount==1)
		    {
			    var objCol = objTable.all["sharedfield"];
		    }
		    else
		    {
			    var objCol = objTable.all["sharedfield"](intColIndex);
			}
		
			switch ( objCol.getAttribute("DataType") )
			{
				case "varchar":
				case "float":
				case "int":
					if (objCol.getAttribute("Nullable")=="0")
					{
						if ( objCol.value=='' )
						{
							Popmessage(objCol.getAttribute("DisplayName") + ' is a required field, and cannot be left blank.', 'Shared Information - Warning');
							return false;
						}
						else if (objCol.hasChildNodes() && (parseInt(objCol.value, 10) != NaN)) 
						{
							//  SC-070684 and SC-07-0685
							//  If we have a mandatory lookup and the selected value is the blank option '' then we will raise an error
							var idx = parseInt(objCol.value, 10);
							if (objCol.childNodes[idx].innerHTML == '')
							{
								Popmessage(objCol.getAttribute("DisplayName") + ' is a required field, and cannot be left blank.', 'Shared Information - Warning');
								return false;
							}
						}			
					}
					break;

				case "text":
					if (objCol.getAttribute("Nullable")=="0")
					{
						if ( objCol.innerText=='' )
						{
							Popmessage(objCol.getAttribute("DisplayName") + ' is a required field, and cannot be left blank.', 'Shared Information - Warning');
							return false;
						}
					}
					break;

				case "bit":
					break;

				case "datetime":
					var objDateControl = new DateControl(objCol);
					// 29Aug07 ST - Commented out as was popping message every time even with valid date entered.
					//if (objCol.getAttribute("Nullable")=="0")
					//{
					//	Popmessage(objCol.getAttribute("DisplayName") + ' is a required field, and cannot be left blank.', 'Shared Information - Warning');
					//	return false;
					//}
					if (objDateControl.ContainsValidDate())
					{
						var dtCurrent = objDateControl.GetDate();
						var strTDate = objDateControl.GetTDate();
					}
					else
					{						
					    if (objCol.getAttribute("Nullable")=="0")
						{
						    Popmessage(objCol.getAttribute("DisplayName") + ' is not a valid date.', 'Shared Information - Warning');
						    return false;
						}
					}
					break;
			}
			
		}
	}
	return true;
}

</script>


</body>
</html>