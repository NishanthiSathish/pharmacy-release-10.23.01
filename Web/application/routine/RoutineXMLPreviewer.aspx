<%@ Page language="vb" %>
<%@ Import Namespace = "System.Xml" %>
<%@ Import namespace="Ascribe.Xml" %>

<%
	Dim SessionID As Integer = CInt(Request.QueryString("SessionID"))
	Dim ScriptBody As String = Request.Form("txtScriptBody")
	Dim PrimaryKey As String = Request.Form("txtPrimaryKey")
	Dim RoutineParams As String = Request.Form("txtRoutineParams")
    Dim ParamValues As String = Request.Form("txtParamValues")
    Dim PopulateFields As Integer = CInt(Request.Form("ReturnFields"))
	Dim Result_XML As String = String.Empty
    Dim OnLoad As String = String.Empty
    
	If ScriptBody <> "" Then
		Dim Params As New XmlDocument()
		Params.TryLoadXml(RoutineParams)
		Dim ParamList As XmlNodeList = Params.SelectNodes("//RoutineParameter")
       
        If ParamList.Count > 0 Then
            Try
                'Create routine under temporary name
                If ParamList.Count = 1 Then
                    Result_XML = New PRTDTL10.ReportRoutine().Preview(SessionID, ScriptBody, Integer.Parse(PrimaryKey))
                Else
                    Result_XML = New PRTDTL10.ReportRoutine().Preview(SessionID, ScriptBody, Integer.Parse(PrimaryKey), RoutineParams, ParamValues)
                End If
                'Now write the xml out to a session variable for the modal web page to read
                Session("RoutineXML") = Result_XML
                If PopulateFields = 1 Then
                    OnLoad = "ReturnFields()"
                Else
                    OnLoad = "ShowResults()"
                End If
				
            Catch ex As Exception
                OnLoad = "ShowError('" & ex.Message.Replace("'", "").Replace("""", "").Replace(Environment.NewLine, "\n") & "')"
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
<script id="clientEventHandlersJS" language="javascript" type="text/javascript">

function ShowResults()
{

    var lngWidth = 640;
    var lngHeight = 480;
    void window.showModalDialog("RoutineXMLPreviewerModal.aspx", "", "dialogHeight: " + lngHeight + "px; dialogWidth: " + lngWidth + "px; edge: Raised; center: Yes; Scroll: No; help: No; resizable: yes; status: No;");

}

function ReturnFields()
{
    var lst = parent.document.getElementById("lstFields");

    if (lst == null)
    {
        return;
    }

    while (lst.options.length)
    {
        lst.options.remove(0);
    }

    var oOption;

    oOption = document.createElement("OPTION");
    lst.options.add(oOption);
    oOption.innerText = "PRINT.DATE";
    oOption.Value = "PRINT.DATE";

    oOption = document.createElement("OPTION");
    lst.options.add(oOption);
    oOption.innerText = "PRINT.TIME";
    oOption.Value = "PRINT.TIME";

    oOption = document.createElement("OPTION");
    lst.options.add(oOption);
    oOption.innerText = "PRINT.USER";
    oOption.Value = "PRINT.USER";

    Populate(lst, xmlResult.documentElement);
}

function Populate(lst, node)
{
    for (var i = 0; i < node.attributes.length; i++)
    {
        var att = node.attributes[i];
        var oOption;
        oOption = document.createElement("OPTION");
        lst.options.add(oOption);
        oOption.innerText = node.nodeName + '.' + att.name;
        oOption.Value = node.nodeName + '.' + att.name;
    }

    for (var i = 0; i < node.childNodes.length; i++)
    {
        Populate(lst, node.childNodes[i]);
    }
}

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
        frmRoutineXMLPreviewer.submit();
    }
}

</script>
</head>
<body onselectstart="event.returnValue=false" oncontextmenu="return false" onload="<%=OnLoad%>">

<form action="RoutineXMLPreviewer.aspx?SessionID=<%=SessionID.ToString()%>" method="post" id="frmRoutineXMLPreviewer" name="frmRoutineXMLPreviewer">
	<input type="hidden" id="ReturnFields" name="ReturnFields" value="<%=PopulateFields%>" />
	PrimaryKey:
	<br>
	<input type="text" id="txtPrimaryKey" name="txtPrimaryKey" value="<%=PrimaryKey%>" onselectstart="event.returnValue=true;event.cancelBubble=true;" />
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
	Result:
	<br>
	<xml id="xmlResult" ><%=Result_XML%></xml>
	<br>
	<button type="submit" id="btnExecute" name="btnExecute">Execute</button>
</form>
</body>
</html>
