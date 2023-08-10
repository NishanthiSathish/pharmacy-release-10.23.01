<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import namespace="Ascribe.Xml" %>

<%
    Dim lngSessionID As Integer
    Dim strCallingPage As String 
    Dim strAction As String 
    Dim lngRoutineID As Integer 
    Dim lngRoutineTypeID As Integer 
    Dim blnEdited As Boolean 
    Dim strDescription As String
    Dim strParameters_XML As String 
    Dim strScriptFull As String
    Dim strScriptHeader As String = String.Empty
    Dim strScriptFooter As String 
    Dim strScriptBody As String 
    Dim intParamCount As Integer 
    Dim intHeaderLines As Integer 
    Dim lngBodyStart As Integer 
    Dim lngBodyEnd As Integer 
    Dim strRoutine_XML As String 
    Dim xmlDoc As XmlDocument
    Dim xmlNode As XmlElement
    Dim objMetaDataRead As ICWDTL10.MetaDataRead
    Dim objRoutineEditor As ICWDTL10.RoutineEditor
    Dim strBrokenRules_XML As String = ""
%>
<%
    '------------------------------------------------------------------------------------
    'Item:        :  RoutineDetail.aspx
    '
    'Purpose      :  The detail page for editing Routine details.
    '
    'Revision History
    '07Apr03 PH   Created
    '
    '------------------------------------------------------------------------------------
%>



<%
    'Page session & security validation
    lngSessionID = CInt(Request.QueryString("SessionID"))
    Ascribe.Common.Security.ValidatePolicy(lngSessionID, "Routine Administration")
%>


<%
    'Read query string values
    strCallingPage = Request.QueryString("CallingPage")
    strAction = Request.QueryString("Action")
    lngRoutineID = Generic.CIntX(Request.QueryString("RoutineID"))
    lngRoutineTypeID = Generic.CIntX(Request.QueryString("RoutineTypeID"))
    blnEdited = (Request.QueryString("Edited") = "1")
%>


<html>
<head>
<title>Routine Editor</title>
<script src="../sharedscripts/icwfunctions.js"></script>
<script src="../sharedscripts/Controls.js"></script>
<script ID=clientEventHandlersJS language=javascript>
<!--

function window_onload()
{
	RenderParams();
	RenderSQLParams();
}

function CancelThisEvent()
{
	if (event.keyCode!=9)
	{
		event.cancelBubble = true;
		return false;
	}
}

function DescriptionChanged()
{
	RenderSQLParams();
}

function ParamNameChanged(intNo)
{
	var xmlDoc = xmlData.XMLDocument;
	var xmlNodeList = xmlDoc.selectNodes("Routine/Parameters/RoutineParameter");
	var xmlNode;

	xmlNode =  xmlNodeList(intNo);
	xmlNode.setAttribute("Description", document.all("Name"+intNo).value);
	RenderSQLParams();
}

function DataTypeChanged(intNo)
{
	var xmlDoc = xmlData.XMLDocument;
	var xmlNodeList = xmlDoc.selectNodes("Routine/Parameters/RoutineParameter");
	var xmlNode;
	
	var strNewType = document.all("DataType"+intNo).options(document.all("DataType"+intNo).selectedIndex).text;

	xmlNode =  xmlNodeList(intNo);
	xmlNode.setAttribute("DataType", strNewType);
	switch (strNewType)
	{
		case "varchar":
			document.all("Length"+intNo).value = 50;
			xmlNode.setAttribute("Length", 50);
			document.all("Length"+intNo).disabled = false;
			document.all("Length"+intNo).className = "";
			break;
		case "int":
			document.all("Length"+intNo).value = 4;
			xmlNode.setAttribute("Length", 4);
			document.all("Length"+intNo).disabled = true;
			document.all("Length"+intNo).className = "background_disabled";
			break;
		case "float":
			document.all("Length"+intNo).value = 8;
			xmlNode.setAttribute("Length", 8);
			document.all("Length"+intNo).disabled = true;
			document.all("Length"+intNo).className = "background_disabled";
			break;
		case "datetime":
			document.all("Length"+intNo).value = 8;
			xmlNode.setAttribute("Length", 8);
			document.all("Length"+intNo).disabled = true;
			document.all("Length"+intNo).className = "background_disabled";
			break;
		case "bit":
			document.all("Length"+intNo).value = 1;
			xmlNode.setAttribute("Length", 1);
			document.all("Length"+intNo).disabled = true;
			document.all("Length"+intNo).className = "background_disabled";
			break;
	}
	document.all("DefaultValue"+intNo).value = "";
	xmlNode.setAttribute("DefaultValue", "");
	document.all("optRoutineList"+intNo).selectedIndex	= 0;
	RenderSQLParams();
}

function LookupChanged(intNo)
{
	var xmlDoc = xmlData.XMLDocument;
	var xmlNodeList = xmlDoc.selectNodes("Routine/Parameters/RoutineParameter");
	var xmlNode;
	
	var RoutineID_Lookup = document.all("optRoutineList"+intNo).options(document.all("optRoutineList"+intNo).selectedIndex).getAttribute("dbid");

	xmlNode =  xmlNodeList(intNo);

	if (RoutineID_Lookup != null)
	{
		xmlNode.setAttribute("RoutineID_Lookup", RoutineID_Lookup);
		xmlNode.setAttribute("Length", 4);
		xmlNode.setAttribute("DefaultValue", "");
		
		document.all("Length"+intNo).value = 4;
		document.all("Length"+intNo).disabled = true;
		document.all("Length"+intNo).className = "background_disabled";

		document.all("DefaultValue"+intNo).value = "";
		document.all("DefaultValue"+intNo).disabled = true;
		document.all("DefaultValue"+intNo).className = "background_disabled";

		xmlNode.setAttribute("DataType", "int");
		document.all("DataType"+intNo).selectedIndex = 1;
		document.all("DataType"+intNo).disabled = true;
		document.all("DataType"+intNo).className = "background_disabled";
	}
	else
	{
		xmlNode.removeAttribute("RoutineID_Lookup");
		document.all("DataType"+intNo).disabled = false;
		document.all("DataType"+intNo).className = "";
		
		document.all("Length"+intNo).disabled = false;
		document.all("Length"+intNo).className = "";

		document.all("DefaultValue"+intNo).disabled = false;
		document.all("DefaultValue"+intNo).className = "";
	}
	RenderSQLParams();
}

function ParamLengthChanged(intNo)
{
	var xmlDoc = xmlData.XMLDocument;
	var xmlNodeList = xmlDoc.selectNodes("Routine/Parameters/RoutineParameter");
	var xmlNode;

	xmlNode =  xmlNodeList(intNo);
	xmlNode.setAttribute("Length", document.all("Length"+intNo).value);
	RenderSQLParams();
}

function ParamDefaultValueChanged(intNo)
{
	var xmlDoc = xmlData.XMLDocument;
	var xmlNodeList = xmlDoc.selectNodes("Routine/Parameters/RoutineParameter");
	var xmlNode;

	xmlNode =  xmlNodeList(intNo);
	xmlNode.setAttribute("DefaultValue", document.all("DefaultValue"+intNo).value);
	RenderSQLParams();
}

function ParamRemoved(intNo)
{
	var xmlDoc = xmlData.XMLDocument;
	var xmlParameters = xmlDoc.selectSingleNode("Routine/Parameters");
	var xmlNode = xmlDoc.selectNodes("Routine/Parameters/RoutineParameter")(intNo);
	xmlParameters.removeChild(xmlNode);

	RenderParams();
	RenderSQLParams();
}

function AddParam()
{
	var xmlDoc = xmlData.XMLDocument;
	var xmlParameters = xmlDoc.selectSingleNode("Routine/Parameters");
	var xmlNode;
	var xmlAttrib;
	var intParamCount = xmlDoc.selectNodes("Routine/Parameters/RoutineParameter").length;

	xmlNode = xmlDoc.createElement("RoutineParameter");
	xmlParameters.appendChild( xmlNode );
	xmlNode.setAttribute("RoutineParameterID", "-1");
	xmlNode.setAttribute("RoutineID", "-1");
	xmlNode.setAttribute("Order", "-1");
	xmlNode.setAttribute("Description", "NewParameter");
	xmlNode.setAttribute("DataType", "varchar");
	xmlNode.setAttribute("Length", "50");
	xmlNode.setAttribute("DefaultValue", "");

	RenderParams();
	RenderSQLParams();
}

function RenderSQLParams()
{
	var strXML = "";
	var xmlDoc = xmlData.XMLDocument;
	var xmlNodeList = xmlDoc.selectNodes("Routine/Parameters/RoutineParameter");
	var xmlNode;
	var CrLf = String.fromCharCode(13) + String.fromCharCode(10);
	var intLongest = 17; // # of chars in "CurrentSessionID"
	
	var strDescription = document.all("txtDescription").value;
	var strChar;
	var strSPName = "";

	for (var intPos=0; intPos<strDescription.length; intPos++)
	{
		strChar = strDescription.charAt(intPos);
		if ( strChar.toUpperCase()>="A" && strChar.toUpperCase()<="Z" || strChar>="0" && strChar<="9" )
		{
			strSPName += strChar;
		}
		else
		{
			strSPName += strChar="_";
		}
	}

	for( var i = 0; i<xmlNodeList.length; i++ )
	{
		xmlNode = xmlNodeList(i);
		if ( ((String)(xmlNode.getAttribute("Description"))).length > intLongest )
		{
			intLongest = ((String)(xmlNode.getAttribute("Description"))).length;
		}
	}
	
	strXML += "Create Procedure [p" + strSPName + "]" + CrLf;
	strXML += "(" + CrLf;
	strXML += "		@CurrentSessionID"
	strXML += Tabs(intLongest, 17) + "int" + CrLf;
	for(var i = 0; i<xmlNodeList.length; i++)
	{
		xmlNode = xmlNodeList(i);
		strXML += "	,	"
		strXML += "@" + xmlNode.getAttribute("Description");
		strXML += Tabs(intLongest, ((String)(xmlNode.getAttribute("Description"))).length) + xmlNode.getAttribute("DataType");
		if (xmlNode.getAttribute("DataType") == "varchar")
		{
			strXML += "(" + xmlNode.getAttribute("Length") + ")";
		}
		strXML += CrLf;
	}
	strXML += ")" + CrLf;
	strXML += "as" + CrLf;
	strXML += "Begin";
	document.all("txtScriptHeader").innerText = strXML;
	try
	{
		document.all("txtScriptHeader").setAttribute("rows", xmlNodeList.length+6);
	}
	catch (e) {}
}

function Tabs(intLongest, intThisLength)
{
	var strTabs = "";
	intLongest += 3;
	intThisLength += 3;
	var intLongestTab = ((Math.floor(intLongest/8))+1)*8;
	i = intThisLength;
	while (i<intLongestTab)
	{
		strTabs += String.fromCharCode(9);
		i+=8;
	}
	return strTabs;
}

function RenderParams()
{
	var strHTML = "";
	var xmlDoc = xmlData.XMLDocument;
	var xmlNodeList = xmlDoc.selectNodes("Routine/Parameters/RoutineParameter");
	var xmlNode;
	var xmlRoutineDoc = xmlRoutineList.XMLDocument;
	var xmlRoutineNodeList = xmlRoutineDoc.selectNodes("Routines/Routine");

	var strClassName = "";
	var strDisabled = ""
	strHTML = "<table id=tblParameters name=tblParameters border=0>";
	strHTML += "<thead><tr><th>#</th><th>Name</th><th>DataType</th><th>Length</th><th>Default</th><th>Lookup</th></tr></thead>";
	strHTML += "<tbody>";

	for(var i = 0; i<xmlNodeList.length; i++)
	{
		xmlNode = xmlNodeList(i);
		strHTML += "<tr>";
		strHTML += "<td>" + (i+1) + "</td>";
		strHTML += "<td><input id='Name" + i + "' size=20 maxlength=50 value='" + xmlNode.getAttribute("Description") + "' onkeyup='return ParamNameChanged(" + i + ");' "
		if (document.all("txtAction").value == "D")
		{
			strHTML += " class='background_disabled' onkeydown='return CancelThisEvent()' ";
		}
		strHTML += " onselectstart='event.returnValue=true;event.cancelBubble=true;' ></td>";

		strHTML += "<td><select id='DataType" + i + "' onchange='return DataTypeChanged(" + i + ")' ";
		if (document.all("txtAction").value == "D" || xmlNode.getAttribute("RoutineID_Lookup") != null )
		{
			strHTML += " class='background_disabled' disabled=true' ";
		}
		strHTML += " >";
		
		strHTML += "		<option ";
		if (xmlNode.getAttribute("DataType") == "varchar")
		{
			strHTML += " SELECTED "
			strClassName = "";
			strDisabled = "";
		}
		strHTML += "			>varchar</option>";

		strHTML += "      <option ";
		if (xmlNode.getAttribute("DataType") == "int")
		{
			strHTML += " SELECTED ";
			strClassName = "background_disabled";
			strDisabled = "disabled=true";
		}
		strHTML += "			>int</option>";

		strHTML += "      <option ";
		if (xmlNode.getAttribute("DataType") == "float")
		{
			strHTML += " SELECTED ";
			strClassName = "background_disabled";
			strDisabled = "disabled=true";
		}
		strHTML += "			>float</option>";

		strHTML += "		<option ";
		if (xmlNode.getAttribute("DataType") == "datetime")
		{
			strHTML += " SELECTED ";
			strClassName = "background_disabled";
			strDisabled = "disabled=true";
		}
		strHTML += "			>datetime</option>";

		strHTML += "		<option ";
		if (xmlNode.getAttribute("DataType") == "bit")
		{
			strHTML += " SELECTED ";
			strClassName = "background_disabled";
			strDisabled = "disabled=true";
		}
		strHTML += "			>bit</option>";

		strHTML += "	</select></td>";
		
		if (document.all("txtAction").value == "D")
		{
			strClassName = "background_disabled";
			strDisabled = "disabled=true";
		}

		strHTML += "<td><input id='Length" + i + "' size=5 " + strDisabled + " class='" + strClassName + "' maxlength=5  id='Length' value='" + xmlNode.getAttribute("Length") + "'      onkeyup='return ParamLengthChanged(" + i + ");' onselectstart='event.returnValue=true;event.cancelBubble=true;' ></td>";

		strHTML += "<td><input id='DefaultValue" + i + "' size=5 maxlength=128  value='" + xmlNode.getAttribute("DefaultValue") + "'      onkeyup='return ParamDefaultValueChanged(" + i + ");' onselectstart='event.returnValue=true;event.cancelBubble=true;' ></td>";

		// Lookup dropdown
		strHTML += "<td>&nbsp;<select id='optRoutineList" + i + "' name='optRoutineList" + i + "' onchange='return LookupChanged(" + i + ")' >";
		strHTML += "<option  SELECTED></option>";
		for (var j=0; j<xmlRoutineNodeList.length; j++)
		{
			strHTML += "<option dbid='" + xmlRoutineNodeList(j).getAttribute("RoutineID") + "' ";
			if (xmlRoutineNodeList(j).getAttribute("RoutineID") == xmlNode.getAttribute("RoutineID_Lookup") )
			{
				strHTML += " SELECTED ";
			}
			strHTML += " >" + xmlRoutineNodeList(j).getAttribute("Description") + "</option>";
		}
		strHTML += "</select></td>"

		if (document.all("txtAction").value != "D")
		{
			strHTML += "<td><button onclick='return ParamRemoved(" + i + ");' id=button1 name=button1>Remove</button></td>";
		}

		strHTML += "</tr>";
	}
	strHTML += "</tbody>";
	strHTML += "</table>";

	if (document.all("txtAction").value != "D")
	{
		strHTML += "<table border=0 cellpadding=5 cellspacing=0><tr>";
		strHTML += "<td><button accesskey='A' onclick='return AddParam();'><u>A</u>dd</button></td>";
	}
	
	divParameters.innerHTML = strHTML;
}

function btnCancel_onclick()
{
	document.all("btnCancel").disabled = true;
	document.all("btnSave").disabled = true;

	window.navigate("<% Response.Write(strCallingPage)%>?SessionID=" + txtSessionID.value + "&RoutineID=" + txtRoutineID.value + "&RoutineTypeID=" + txtRoutineTypeID.value + "&RoutineName=" + txtRoutineName.value);
	return false;
}

function btnSave_onclick()
{
	if ( document.all("txtScriptBody").innerText.toUpperCase().indexOf("SELECT TOP 100") == -1 )
	{
		alert("Your query must contain the expression: Select Top 100");
		return false;
	}
	else
	{
		document.all("btnCancel").disabled = true;
		document.all("btnSave").disabled = true;

		var xmlDoc = xmlData.XMLDocument;
		var xmlNodeList = xmlDoc.selectNodes("Routine/Parameters/RoutineParameter");
		var xmlNode;

		for (var i=0; i<xmlNodeList.length; i++)
		{
			xmlNode =  xmlNodeList(i);
			xmlNode.setAttribute("Order", i);
		}

		document.all("txtRoutine_XML").innerText = xmlDoc.xml;
	}
	document.forms("frmRoutineDetail").submit();
}

function frmRoutineDetail_onsubmit()
{
}


//-->
</script>

<link rel="stylesheet" type="text/css" href="../../style/application.css" />

</head>
<body onselectstart="event.returnValue=false" oncontextmenu="return false" onload="return window_onload()" scroll=auto >

<%
    If blnEdited = False Then
        If strAction = "N" Then
            strDescription = ""
            strRoutine_XML = "<Routine id=""0""><Parameters></Parameters></Routine>"
            strScriptBody = ""
            strScriptBody = strScriptBody & "Select Top 100 " & vbCrLf
            strScriptBody = strScriptBody & "		MyTable.RecordID		AS [RecordID]" & vbCrLf
            strScriptBody = strScriptBody & "	,	MyTable.RecordDescription	AS [Description]" & vbCrLf
            strScriptBody = strScriptBody & "	,	MyTable.RecordDate		AS [DateText]" & vbCrLf
            strScriptBody = strScriptBody & "	,	MyTable.RecordStatus		AS [Status]" & vbCrLf
            strScriptBody = strScriptBody & "From " & vbCrLf
            strScriptBody = strScriptBody & "	MyTable " & vbCrLf
            strScriptBody = strScriptBody & "	Join MyOtherTable On MyTable.MyColumn = MyOtherTable.MyColumn " & vbCrLf
            strScriptBody = strScriptBody & "Where " & vbCrLf
            strScriptBody = strScriptBody & "	MyTable.MyField1 Like @MyParameter1 + '%' " & vbCrLf
            strScriptBody = strScriptBody & "	And " & vbCrLf
            strScriptBody = strScriptBody & "	MyTable.MyField2 = @MyParameter2 " & vbCrLf
        Else
            objMetaDataRead = New ICWDTL10.MetaDataRead()
            'Read routine from DB
            strRoutine_XML = objMetaDataRead.RoutineXML(lngSessionID, CInt(lngRoutineID))
            '<Routine RoutineID="2" RoutineTypeID="1" Description="Test1" Script="abc"/>
            '<Parameters>
            '<RoutineParameter RoutineParameterID="21" RoutineID="23" Order="1" Description="Forename" DataType="Int" Length="4" RoutineID_Lookup="123" />
            '<Parameters>
            '</Routine>
            objMetaDataRead = Nothing
            'Load XML into DOM
            xmlDoc = New XmlDocument()
            xmlDoc.TryLoadXml(strRoutine_XML)
            xmlNode = xmlDoc.SelectSingleNode("Routine")
            'Assign Attributes to local variables
            strDescription = xmlNode.GetAttribute("Description")
            strScriptFull = xmlNode.GetAttribute("Script")
            If strScriptFull.length > 0 Then
                intParamCount = xmlDoc.SelectNodes("Routine/Parameters/RoutineParameter").Count()
                intHeaderLines = 6 + intParamCount
                lngBodyStart = InStr(UCase(strScriptFull), "BEGIN")
                lngBodyStart = InStr(lngBodyStart, CStr(strScriptFull), CStr(Chr(10)))
                lngBodyEnd = InStrRev(UCase(strScriptFull), "END")
                strScriptHeader = Left(strScriptFull, lngBodyStart - 2)
                strScriptBody = Mid(strScriptFull, lngBodyStart, lngBodyEnd - lngBodyStart - 1)
                strScriptFooter = Mid(strScriptFull, lngBodyEnd)
            Else
                'F0049059 ST 24Mar09    Added default script should our one have been saved with nothing in it
                strScriptBody = ""
                strScriptBody = strScriptBody & "Select Top 100 " & vbCrLf
                strScriptBody = strScriptBody & "		MyTable.RecordID		AS [RecordID]" & vbCrLf
                strScriptBody = strScriptBody & "	,	MyTable.RecordDescription	AS [Description]" & vbCrLf
                strScriptBody = strScriptBody & "	,	MyTable.RecordDate		AS [DateText]" & vbCrLf
                strScriptBody = strScriptBody & "	,	MyTable.RecordStatus		AS [Status]" & vbCrLf
                strScriptBody = strScriptBody & "From " & vbCrLf
                strScriptBody = strScriptBody & "	MyTable " & vbCrLf
                strScriptBody = strScriptBody & "	Join MyOtherTable On MyTable.MyColumn = MyOtherTable.MyColumn " & vbCrLf
                strScriptBody = strScriptBody & "Where " & vbCrLf
                strScriptBody = strScriptBody & "	MyTable.MyField1 Like @MyParameter1 + '%' " & vbCrLf
                strScriptBody = strScriptBody & "	And " & vbCrLf
                strScriptBody = strScriptBody & "	MyTable.MyField2 = @MyParameter2 " & vbCrLf
            End If
            xmlNode = Nothing
            xmlDoc = Nothing
        End If
    Else
        'Save changes to DB
        'Get user-entered field values from Form object
        strRoutine_XML = Request.Form("txtRoutine_XML")
        strDescription = Request.Form("txtDescription")
        strScriptHeader = Request.Form("txtScriptHeader")
        strScriptBody = Request.Form("txtScriptBody")
        strScriptFooter = Request.Form("txtScriptFooter")
        strScriptFull = strScriptHeader & vbCrLf & strScriptBody & vbCrLf & strScriptFooter
        xmlDoc = New XmlDocument()
        xmlDoc.TryLoadXml(strRoutine_XML)
        xmlNode = xmlDoc.SelectSingleNode("Routine/Parameters")
        strParameters_XML = xmlNode.OuterXml
        objRoutineEditor = New ICWDTL10.RoutineEditor()

        Select Case strAction
            Case "N"
                strBrokenRules_XML = objRoutineEditor.RoutineAdd(lngSessionID, CInt(lngRoutineTypeID), CStr(strDescription), strScriptBody, strParameters_XML)
            Case "E"
                strBrokenRules_XML = objRoutineEditor.RoutineUpdate(lngSessionID, CInt(lngRoutineID), CInt(lngRoutineTypeID), CStr(strDescription), strScriptBody, strParameters_XML)
            Case "D"
                strBrokenRules_XML = objRoutineEditor.RoutineRemove(lngSessionID, CInt(lngRoutineID))
        End Select
        objRoutineEditor = Nothing

        'F0049059 ST 25Mar09    Added check for the new broken rule and if one is there then display popup message
        If Ascribe.Common.BrokenRules.NoRulesBroken(strBrokenRules_XML) Then
            Response.Redirect(strCallingPage & "?SessionID=" & lngSessionID & "&RoutineID=" & lngRoutineID & "&RoutineTypeID=" & lngRoutineTypeID & "&RoutineName=" & strDescription)
        Else
            Response.Write("<script language=""javascript"">Popmessage(""Error Saving Routine"", ""Routine Editor"");</script>")
        End If
    End If
%>


<input type="hidden" id=txtSessionID name=txtSessionID value="<%
    Response.Write(lngSessionID)
%>
">

<input type="hidden" id=txtCallingPage name=txtCallingPage value="<%
    Response.Write(Request.QueryString("CallingPage"))
%>
">

<input type="hidden" id=txtAction name=txtAction value="<%
    Response.Write(Request.QueryString("Action"))
%>
">

<input type="hidden" id=txtRoutineID name=txtRoutineID value="<%
    If Request.QueryString("RoutineID") = "" Then 
        Response.Write("0")
    Else
        Response.Write(Request.QueryString("RoutineID"))
    End IF
%>
">

<input type="hidden" id=txtRoutineTypeID name=txtRoutineTypeID value="<%
    If Request.QueryString("RoutineTypeID") = "" Then 
        Response.Write("0")
    Else
        Response.Write(Request.QueryString("RoutineTypeID"))
    End IF
%>
">

<input type="hidden" id=txtRoutineName name=txtRoutineName value="<%
    Response.Write(strDescription)
%>
">

<xml id=xmlRoutineList name=xmlRoutineList><%
    objMetaDataRead = new ICWDTL10.MetaDataRead()
                                               Response.Write(objMetaDataRead.RoutineListXML(lngSessionID, CInt(lngRoutineTypeID)))
    objMetaDataRead = Nothing
%>
</xml>

<form id=frmRoutineDetail name=frmRoutineDetail action="RoutineDetail.aspx?CallingPage=<%
    Response.Write(strCallingPage)
%>
&SessionID=<%
    Response.Write(lngSessionID)
%>
&Action=<%
    Response.Write(strAction)
%>
&RoutineID=<%
    Response.Write(lngRoutineID)
%>
&RoutineTypeID=<%
    Response.Write(lngRoutineTypeID)
%>
&Edited=1" method=POST onsubmit="frmRoutineDetail_onsubmit()" onreset="frmRoutineDetail_onreset()" >

<xml id=xmlData name=xmlData><%
    Response.Write(strRoutine_XML)
%>
</xml>

<table width="100%" height="100%">

<tr height="1%">
	<td>
	<h3>Routine Editor</h3>
	</td>
</tr>

<tr height="1%">
	<td>
<%
    Response.Write(Ascribe.Common.BrokenRules.GetBrokenRulesTable_HTML(strBrokenRules_XML))
%>

	</td>
</tr>

<tr height="1%">
	<td>
		Name
		&nbsp;
		<input type="text" id="txtDescription" name="txtDescription" validchars="ANY" onKeyPress="MaskInput(this)" onPaste="MaskInput(this)" <%
    If strAction <> "N" Then 
        Response.Write(("class='background_disabled' onkeydown='return CancelThisEvent()'  "))
    End IF
%>
 size="80" maxlength="128" value="<%
    Response.Write(strDescription)
%>
" LANGUAGE=javascript onkeyup="return DescriptionChanged()" onselectstart="event.returnValue=true;event.cancelBubble=true;" >
	</td>
</tr>

<tr height="1%">
	<td>
		Parameters<br>
		<div id=divParameters></div>
	</td>
</tr>

<tr height="1%">
	<td>
		<textarea rows=10 style='width:100%; overflow-y:hidden' onkeydown='return CancelThisEvent()' class='background_disabled' id='txtScriptHeader' name='txtScriptHeader' rows='<%
    Response.Write(intHeaderLines)
%>
' onselectstart="event.returnValue=true;event.cancelBubble=true;" ><%
    Response.Write(strScriptHeader)
%>
</textarea>
	</td>
</tr>
<tr height="99%">
	<td>
		<textarea style='width:100%; height:100%' id='txtScriptBody' name='txtScriptBody' rows='10' <%
    If strAction = "D" Then 
        Response.Write(("class='background_disabled' onkeydown='return CancelThisEvent()' "))
    End IF
%>
 onselectstart="event.returnValue=true;event.cancelBubble=true;" ><%
    Response.Write(strScriptBody)
%>
</textarea>
	</td>
</tr>
<tr height="1%">
	<td>
		<textarea style='width:100%; overflow-y:hidden' onkeydown='return CancelThisEvent()' class='background_disabled' id='txtScriptFooter' name='txtScriptFooter' rows='1' onselectstart="event.returnValue=true;event.cancelBubble=true;" >End</textarea>
	</td>
</tr>


<tr height="1%">
	<td>
	<button type="submit" id="btnSave" name="btnSave" onclick="return btnSave_onclick()"
	accesskey=
<%
    If strAction = "D" Then 
%>

		'D'
<%
    Else
%>

		'S'
<%
    End IF
%>

	>
<%
    If strAction = "D" Then 
%>

		<u>D</u>elete
<%
    Else
%>

		<u>S</u>ave
<%
    End IF
%>

	</button>
	&nbsp;
	<button type="submit" id="btnCancel" name="btnCancel"  onclick="return btnCancel_onclick()" accesskey='C'>
	<u>C</u>ancel
	</button>
	</td>
</tr>

</table>

<textarea style="display:none" id='txtRoutine_XML' name='txtRoutine_XML' cols='60' rows='10' ></textarea>

</form>

</body>
</html>
