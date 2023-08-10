<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.RoutineSearch" %>

<%
    Dim SessionID As Integer = Integer.Parse(Request.QueryString("SessionID"))
    Dim ReportName As String = Request.QueryString("ReportName")
	Dim RoutineName As String = Request.QueryString("RoutineName")
	Dim RoutineParams As String = String.Empty
	Dim RoutineXML As String = String.Empty
	If RoutineName Is Nothing OrElse RoutineName = String.Empty Then
		RoutineParams = Session("RoutineParams")
		Session.Remove("RoutineParams")
	End If
%>

<html>
<head>
<title><%= ReportName %></title>

<link rel="stylesheet" type="text/css" href="../../style/patienttransfer.css" />
<link rel="stylesheet" type="text/css" href="../../style/application.css" />

<script src="../sharedscripts/ICWFunctions.js"></script>
<script src="../routine/script/RoutineSearch.js"></script>
<script src="../sharedscripts/Controls.js"></script>
<script src="../sharedscripts/DateLibs.js"></script>

<script>

function btnOK_click()
{
	var xmlParamterValues = CollateForm();
	if ( xmlParamterValues == "" )
	{
		tdWarning.style.display = "";
	}
	else
	{
		tdWarning.style.display = "none";
		window.returnValue = xmlParamterValues;
		window.close();
	}
}

function window_onload()
{
	var xmlDoc = xmlLookup.XMLDocument;
	var xmlElement;
	if (document.getElementById("txtRoutineXML") == undefined)
	{
		xmlDoc.loadXML(document.getElementById("txtParameterXML").value);
		xmlElement = xmlDoc.selectSingleNode("Parameters/RoutineParameter[@Description='PrimaryKey']");
	}
	else
	{
	    xmlDoc.loadXML(document.getElementById("txtRoutineXML").value);
		xmlElement = xmlDoc.selectSingleNode("Routine/Parameters/RoutineParameter[@Description='PrimaryKey']");
    }
    
    // Task 58167 06March2013 YB - Added extra check to prevent error when there are no routine params
    if (xmlElement != null) {
        var Order = xmlElement.getAttribute("Order");
        document.all("col" + Order).parentElement.parentElement.style.display = "none";
    }
    else {
        var xmlParamterValues = CollateForm();
        window.returnValue = xmlParamterValues;
        window.close();
    }
}

function CollateForm()
{
	var Valid = true;
	var Inputs = document.getElementsByTagName("input");
	var Count = Inputs.length;
	var Input;
	var InputID;
	var Order;
	var xmlDoc = xmlLookup.XMLDocument;
	xmlDoc.loadXML('<ParameterValues RoutineName="<%= RoutineName %>" />');
	var xmlRoot = xmlDoc.documentElement;
	var xmlElement;
	
	for ( var Index=0; Index < Count; Index++ )
	{
		Input = Inputs[Index];
		InputID = Input.id
		if (InputID.substr(0, 3) != "col" || Input.parentElement.parentElement.style.display == "none")
		{
			continue;
		}
		Order = InputID.substr(3, InputID.length - 3)

		if (Input.getAttribute("type") == "text" )
		{
			if (Input.value == "")
			{
				if (document.getElementById("desc" + Order) == null)
				{
					Input.className = "warning";
				}
				else
				{
					document.getElementById("desc" + Order).className = "warning";
				}
				Valid = false;
			}
			else
			{
				if (document.getElementById("desc" + Order) == null)
				{
					Input.className = "";
				}
				else
				{
					document.getElementById("desc" + Order).className = "";
				}
				xmlElement = xmlRoot.appendChild(xmlDoc.createElement("ParameterValue"));
				xmlElement.setAttribute("ParameterOrder", Order);
				if (Input.getAttribute("xtype") == "datetime") {
				    xmlElement.setAttribute("Value", Date2TDate(ddmmccyy2Date(Input.value)));
				}
				else {
				    xmlElement.setAttribute("Value", Input.value);
				}
			}
		}
		else
		{
			xmlElement = xmlRoot.appendChild(xmlDoc.createElement("ParameterValue"));
			xmlElement.setAttribute("ParameterOrder", Order);
			if (Input.checked)
			{
				xmlElement.setAttribute("Value", 1);	
			}
			else
			{
				xmlElement.setAttribute("Value", 0);
			}		
		}
	}
	if (Valid)
	{
		return xmlDoc.xml;
	}
	else
	{
		return "";
	}
}

// Added this dummy method to return a blank URL, because the shared file RoutineSearch.js needs it, but this method doesn't exist on all the pages the RoutineSearch.js is included on!
function ActionURL() {
    return "";
}

</script>
	
</head>
<body onload="window_onload()">
<xml id=xmlLookup></xml>
<input type="hidden" id=txtSessionID name=txtSessionID value="<%= SessionID%>" />

<table width="100%" height="100%">
    <tr height="5%">
        <td id="tdWarning" align="center" style="display:none" class="warning">
            <div>All parameters must be completed.</div>
        </td>
    </tr>
    <tr height="90%" valign="top">
        <td>
            <%  
            	If RoutineName Is Nothing OrElse RoutineName = String.Empty Then
            		ScriptInputControlsByParameters(SessionID, RoutineParams, RoutineSearchLayout.Vertical, False)
            	Else
            		ScriptInputControlsByRoutineDescription(SessionID, RoutineName, "", RoutineXML, RoutineSearchLayout.Vertical, False)
            	End If
            %>
        </td>
    </tr>
    <tr height="5%">
        <td align="right">
            <button accesskey="O" id="btnOK" onclick="btnOK_click()"><u>O</u>k</button>
        </td>
    </tr>
</table>
</body>
	
</html>

