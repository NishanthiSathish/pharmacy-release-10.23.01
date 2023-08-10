<%@ Page language="vb" %>
<%@ Import Namespace = "System.Xml" %>
<%@ Import namespace="Ascribe.Xml" %>

<%
	Dim SessionID As Integer = CInt(Request.QueryString("SessionID"))
	Dim ScriptBody As String = Request.Form("txtScriptBody")
	Dim PrimaryKey As String = Request.Form("txtPrimaryKey")
	Dim RoutineParams As String = Request.Form("txtRoutineParams")
	Dim ParamValues As String = Request.Form("txtParamValues")
	Dim Result_XML As String = String.Empty
	Dim OnLoad As String = String.Empty
	
	If ScriptBody <> "" Then
		Dim Params As New XmlDocument()
		Params.TryLoadXml(RoutineParams)
		Dim ParamList As XmlNodeList = Params.SelectNodes("//RoutineParameter")
		If ParamList.Count = 1 Or ParamValues.Length > 0 Then
			Try
				'Create routine under temporary name
				If ParamList.Count = 1 Then
					Result_XML = New PRTDTL10.ReportRoutine().Preview(SessionID, ScriptBody, Integer.Parse(PrimaryKey))
				Else
					Result_XML = New PRTDTL10.ReportRoutine().Preview(SessionID, ScriptBody, Integer.Parse(PrimaryKey), RoutineParams, ParamValues)
				End If
				OnLoad = "parent.PreviewDataReady();"
			Catch ex As Exception
				OnLoad = "ShowError('" & ex.Message.Replace("'", "").Replace(Environment.NewLine, "\n") & "')"
			End Try
		Else
			Session("RoutineParams") = RoutineParams
			OnLoad = "GetParameterValues()"
		End If
	End If
%>


<html>
<head>

<script language="javascript" src="../sharedscripts/ICWFunctions.js"></script>
<script id="Script1" language="javascript">

	function ShowError(Message)
	{
		var features = 'dialogHeight:300px;'
								 + 'dialogWidth:450px;'
								 + 'resizable:yes;'
								 + 'status:no;help:no;';
		Popmessage(Message, 'Routine Error!', features);
	}

	function GetParameterValues()
	{
		var strURL = '../printing/PrintParameters.aspx?SessionID=<%= SessionID %>&ReportName=XML Preview';
		var strParamsXML = window.showModalDialog(strURL, '', 'help:off ; status:off ; scroll:off ; dialogwidth=900px ; dialogheight=650px ;');
       
		if (strParamsXML != undefined)
		{
			document.all("txtParamValues").innerText = strParamsXML;
			frmRoutinePreviewer.submit();
		}
	}

</script>
</head>
<body onselectstart="event.returnValue=false" oncontextmenu="return false" onload="<%=OnLoad%>">

<form action='RoutinePreviewer.aspx?SessionID=<%=SessionID%>' method=POST id=frmRoutinePreviewer name=frmRoutinePreviewer>
	
	PrimaryKey:
	<br>
	<input type="text" id="txtPrimaryKey" name="txtPrimaryKey" value="<%=PrimaryKey%>" onselectstart="event.returnValue=true;event.cancelBubble=true;" >
	<br>
	Parameters:
	<br>
	<textarea rows="10" cols="60" id="txtRoutineParams" name="txtRoutineParams" onselectstart="event.returnValue=true;event.cancelBubble=true;" ><%=RoutineParams%></textarea>
	<br>
	ParameterValues:
	<br>
	<textarea rows="10" cols="60" id="txtParamValues" name="txtParamValues" onselectstart="event.returnValue=true;event.cancelBubble=true;" ><%=ParamValues%></textarea>
	<br>
	Script:
	<br>
	<textarea rows="10" cols="60" id="txtScriptBody" name="txtScriptBody" onselectstart="event.returnValue=true;event.cancelBubble=true;" ><%=ScriptBody%></textarea>
	<br>
	<button type="submit" id="btnExecute" name="btnExecute">Execute</button>
	
</form>

<xml id="xmlResult"><%=Result_XML%></xml>

</body>
</html>
