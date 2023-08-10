<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    Dim SessionID As Integer
    Dim xmlDocSession As New XmlDocument()
    Dim xmlnodeSession As XmlElement
    Dim SessionData_XML As String
%>
<%
    '---------------------------------------------------------------------------------------------
    '
    'PrintControl.aspx
    '
    'This page hosts the HighEdit cntrol, and is responsible for the rendering
    'of XML data into a RTF Document, then printing or previewing it.
    '(See the Render function for more details on rendering.)
    '
    'Best use of this page is by loading it into an IFrame, then calling it's
    '"DoPrint" function with the following parameters:
    'DoPrint(strReportName, strReport_RTF, strPrintData_XML, blnPreview)
    '
    'strReportName		-	A name for the report to being printed (Is used when creating temporary client-side files)
    'strReport_RTF		-	The document to be printed, in Rich Text format
    'strPrintData_XML	-	The XML Data that will be "mail-merged" into the RTF document, prior to printing.
    'blnPreview			-	Determines whether the HighEdit Print or Preview method is called after the report is rendered.
    '
    'Once "DoPrint" has rendered and printed/previewed the document, it then calls
    '
    'window.parent.DocumentPrinted(strReportName);
    '
    'to indicated that the printing of the document has been completed.
    '
    '12Mar03 PH Created
    '01Nov13 Rams TFS - 77014/69565 - Print preview screen crashing
    SessionID = Integer.Parse(Request.QueryString("SessionID"))
    xmlDocSession.TryLoadXml(New PRTRTL10.PrintSessionRead().GetPrintSessionData(SessionID))
    '<PrintSession SessionID="805" EntityID="11179" Username="pete" UserFullName=" Peter Hughes" Login_Location="terminal in ward"/>
    xmlnodeSession = xmlDocSession.selectSingleNode("//PrintSession")
    SessionData_XML = "<PRINT DATE=""" & Generic.Date2ddmmccyy(Today()) & """ TIME=""" & TimeOfDay() & """ USER=""" & xmlnodeSession.getAttribute("Username") & """ USERFULLNAME=""" & xmlnodeSession.getAttribute("UserFullName") & """ />"
%>


<html>
<head>
<link rel="stylesheet" type="text/css" href="../../style/application.css">
<script src="../sharedscripts/ICWFunctions.js"></script>
<script src="../sharedscripts/DateLibs.js"></script>

<script src="script/PrintControl.js"></script>

<script type="text/vbscript">
    Public Sub HEdit0_InitPage(CurrentPage, Pages, Adjust)
        Dim PFCount
        Dim index
        PFCount = Hedit0.GetFunctionPFTableCount()
        For index = 1 To PFCount
            Dim FieldType
            Dim FieldName
            FieldType = Hedit0.GetFunctionPFTyp(index)
            FieldName = HEditAssist.GetFunctionPFName(Hedit0, FieldType)
            '01Nov13 Rams TFS - 77014/69565 - Print preview screen crashing
            If IsReprint <> True Or IsPreview <> True Then
                If UCase(FieldName) = "{PAGE}" Then
                    Hedit0.ChangeFunctionPF FieldType, CurrentPage
                End If
                If UCase(FieldName) = "{PAGETOTAL}" Then
                    Hedit0.ChangeFunctionPF FieldType, Pages
                End If
            End If
        Next
    End Sub
</script>

</head>
<body onselectstart="event.returnValue=false" oncontextmenu="return false" scroll='no'>

<XML id='xmlPrintData'>
</XML>

<table id="tblAll" width=100% height=100% border=0>
	<tr >
		<td>

<OBJECT id="HEdit0" style="width:100%;height:0%"
	classid=CLSID:ADB3ECE0-1873-11D0-99B4-00550076453D VIEWASTEXT>
	<PARAM NAME="_ExtentX" VALUE="16113">
	<PARAM NAME="_ExtentY" VALUE="11139"></OBJECT>

		</td>
	</tr>
	<tr id="trButtons" height="1%">
		<td align=right>
			<button id="btnDone" accesskey="O" onclick="return btnDone_onclick()" ><u>O</u>k</button>
			<span id="spanCancel" style="display:none">
				&nbsp;
				<button id="btnCancel" accesskey="C" onclick="return btnCancel_onclick()" ><u>C</u>ancel</button>
			</span>
		</td>
	</tr>
</table>


<OBJECT id="HEdit1" style="left:0px;top:0px;width:100%;height:0%"     codebase="/ascicw/cab/HEdit.cab" 
	classid=CLSID:ADB3ECE0-1873-11D0-99B4-00550076453D VIEWASTEXT>
	<PARAM NAME="_ExtentX" VALUE="16113">
	<PARAM NAME="_ExtentY" VALUE="11139"></OBJECT>

<OBJECT id="HEdit2" style="left:0px;top:0px;width:100%;height:0%"     codebase="/ascicw/cab/HEdit.cab" 
	classid=CLSID:ADB3ECE0-1873-11D0-99B4-00550076453D VIEWASTEXT>
	<PARAM NAME="_ExtentX" VALUE="16113">
	<PARAM NAME="_ExtentY" VALUE="11139"></OBJECT>

<OBJECT id="HEdit3" style="left:0px;top:0px;width:100%;height:0%"     codebase="/ascicw/cab/HEdit.cab" 
	classid=CLSID:ADB3ECE0-1873-11D0-99B4-00550076453D VIEWASTEXT>
	<PARAM NAME="_ExtentX" VALUE="16113">
	<PARAM NAME="_ExtentY" VALUE="11139"></OBJECT>

<div id='divInsertPoint'></div>

<OBJECT style="display:none" id="HEditAssist" tabindex="0" 
	   codebase="/ascicw/cab/HEditAssist.CAB#version=1,0,0,30" 
	classid=CLSID:22A94461-82F5-47D5-B001-9A1681C67CAF VIEWASTEXT>
	<PARAM NAME="_ExtentX" VALUE="16113">
	<PARAM NAME="_ExtentY" VALUE="11139"></OBJECT>


<textarea style="display:none" rows=8 cols=60 id='txtSessionDataXML'><%=SessionData_XML%></textarea>

</body>
</html>
