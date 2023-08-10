<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import namespace="Ascribe.Xml" %>
<%@ Import Namespace="Ascribe.Common"%>
<%@ Import Namespace="Ascribe.Common.OrderForm" %>

<!-- 
LM Code 162, 10/01/2008 ,
Removed Reference to Scripts/OrderForm.vb.vb
Imported the namespaces Ascribe.Common.OrderForm
-->

<html>

<%
    Dim sessionId As Integer
    Dim DOM As XmlDocument
    Dim objLayout As XmlElement
    Dim objData As XmlElement
    Dim objSchedule As XmlElement
    Dim objReasonCapture As XmlElement
    Dim objControl As XmlElement
    Dim colControls As XmlNodeList
    Dim lngTableID As Integer
    Dim strLayout_XML As String
    Dim strLayoutHeader As String = ""
    Dim strDataForScripting As String = ""
    Dim strScheduleForScripting As String = ""
    Dim strDataClass As String = ""
    Dim lngDataID As Integer
    Dim strData_XML As String
    Dim intLength As Integer 
    Dim blnDisplayMode As Boolean
    Dim blnTemplateMode As Boolean 
    Dim blnResponseMode As Boolean 
    Dim strThisControl_HTML As String = ""
    Dim strPassThroughQuerystring As String = ""
    Dim strFormBodyClass As String = ""
    Dim intTop As Integer
    Dim intHeight As Integer
    Dim intBottom As Integer 
    Dim intLowest As Integer 
    Dim intOrdinal As Integer
    Dim blnCopyMode As Boolean
    Dim blnAmendMode As Boolean
    Dim strReasonCaptureScript As String = ""
    Dim strControlID As String
    Dim IsReasonCaptureMandatory As Boolean = False
    
    sessionId = CInt(Request.QueryString("SessionID"))
    
%>
<%
    'ORDERFORM.aspx
    '
    'This page contains the actual controls into which the user enters data.
    'It contains logic to arrange and resize these controls, as well as the
    'logic to deal with the custom functions attached to them (incorporating
    'sub forms etc)
    '
    'The page takes query string parameters as follows:
    '
    'SessionID 	(mandatory)						:		The standard security token
    'TableID	(mandatory)							:		The ID of the table whos layout(s) to load.
    'Display  (optional)  						:		Pass True to set the whole layout to read only.
    'DataClass 										:		The type of data to retrieve (request, response, note, template etc)
    'DataRow											:		The ID of the record of data to retrieve.
    'Template											:		If True, indicates that this is a template, not an order instance
    'Style												:		indicates if special color/style should be applied to the form
    '"normal"		- No special style applied
    '"exists"		- Form is colored to indicate that a response of this type already exists for this request
    '
    'Other paramaters may be passed, and are passed through to the COM tier.  This is to
    'enable data to be passed on to custom controls.
    '
    'A certain amount of input validation is performed by this page:
    'Field length
    'Masking (numbers only, letters only, dates, times, etc)
    '
    '-----------------------------------------------------------------------
    'Modification History:
    '18Nov02 AE  Written
    ''			(in development)
    '13Sep03 AE     Now traps attempts to view deleted items
    '24May04 AE     Bulk of the code moved into OrderForm.vb for clarity.
    '02Nov05 AE     Removed onload call to PositionProblemDiv (was crashing on items in ordersets).
    'Now is called from NavigateToForm, and only does the work once.
    '03Feb11 Rams   F0107780 - When opening an form that is associated with an attached note, such as a patients own medicine, intial focus is on the 2nd object on the form, where it should be on the first 
    '08Feb11 Rams   F0108516 - Script error when ordering Height or Weight notes - Found on Gateshead & UMMC 10.05.02.07 - Does not stop note from being committed but doesn't look good
    '
%>


<head>
<title></title>

<script language="javascript" type="text/javascript" src="../sharedscripts/ocs/ocsConstants.js"></script>
<script language="javascript" type="text/javascript" src="scripts/OrderFormResizing.js" ></script>
<script language="javascript" type="text/javascript" src="scripts/OrderFormControls.js" ></script>
<script language="javascript" type="text/javascript" src="scripts/OrderFormFunctions.js" ></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/Controls.js" ></script>
<script language="javascript" type="text/javascript" src="scripts/OrderFormClasses.js" ></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/icwFunctions.js" ></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/DateLibs.js" ></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/OCS/OCSShared.js" ></script>


<%
    'Script the given layout.
    intTop = 0
    intHeight = 0
    intBottom = 0
    intLowest = 0
    'Nasty client-side repositioning script for custom controls which are set
    'to 100% height.  Yup, that'll be prescribing then.
    strReasonCaptureScript = ""
    '--------------------------------------------------------------------
    'debug
    'Response.write Request.Querystring
    'Response.end
    '-------------------------------------------------------------------
    'Read the parameters from the querystring
    intOrdinal = CInt(Request.QueryString("Ordinal"))
    'If we're in display mode, script a call to set the form read-only on start up

    blnDisplayMode = IIf(String.IsNullOrEmpty(Request.QueryString("Display")), False, LCase(Request.QueryString("Display")) = "true")
    blnCopyMode = IIf(String.IsNullOrEmpty(Request.QueryString("CopyMode")), False, LCase(Request.QueryString("CopyMode")) = "true")
    blnAmendMode = IIf(String.IsNullOrEmpty(Request.QueryString("AmendMode")), False, LCase(Request.QueryString("AmendMode")) = "true")
	
    blnTemplateMode = LCase(Request.QueryString("Template")) = "true"
    lngTableID = Generic.CIntX(Request.QueryString("TableID"))
    'ID of the table this row lives in / is destined to live in
    lngDataID = Generic.CIntX(Request.QueryString("DataRow"))
    'Primary key of the row in the given table
    strDataClass = Request.QueryString("DataClass")
    'Root type of this data (ie "Request", "Response", "Note")

    'Type ID - so RequestTypeID for a Request, NoteTypeID for a note, etc
    blnResponseMode = (LCase(strDataClass) = "response")
    '25Sep06 AE
    'Determine any special styling
    strFormBodyClass = GetClassFromStyle()
    'Extra class to indicate superceded results etc
    'If we have any data to retrieve, then load it now
    
    strData_XML = GetDataXML(sessionId, strDataClass, blnDisplayMode, lngTableID, lngDataID)
    '06Oct04 AE  Added blnDisplayMode parameter
    'Create the querystring to pass through to any custom controls (web pages hosted in iframes)
    strPassThroughQuerystring = CreateQuerystring(strData_XML)
    '--------------------------------------debug------------------------------------
    'Response.write "<textarea rows=6 width=100% >" & strData_XML & "</textarea>"
    'Response.write strPassThroughQuerystring
    'Response.end
    '-------------------------------------------------------------------------------
%>

<link rel="stylesheet" type="text/css" href="../../style/OrderEntry.css" />
<link rel="stylesheet" type="text/css" href="../../style/application.css" />
</head>
<body id="formBody" 
		class="OrderFormBody<%= strFormBodyClass %>"
		oncontextmenu="return false;"
		tabindex="-100"
		style="overflow:auto;"
		frameid="<%= Request.QueryString("FrameID") %>"
		sid="<%= sessionId %>"
		templatemode="<%= LCase(CStr(blnTemplateMode)) %>"		
		onunload="CloseFieldHintsWindow();"
		onkeydown="if (window.event.keyCode == 27) window.parent.CloseWindow(true);"
		ordinal="<%= intOrdinal %>"
		onload = " if(typeof SetFocusonTabIndex1 == 'function')SetFocusonTabIndex1();"
		>
<%
    'Now read the layout from the database
    strLayout_XML = GetLayoutXML(lngTableID, strPassThroughQuerystring, sessionId)
    'Split the layout XML into the HTML controls and the header information held in
    'the "layout" tag:
    DOM = new XmlDocument()
    DOM.TryLoadXml(strLayout_XML)
    objLayout = DOM.SelectSingleNode("layout")
    'Layout header information.  This is scripted into an xml island on the
    'client page.
    If objLayout Is Nothing Then 
        Warning_NoFormDefined()
    End IF
    'Set the form read-only if in display mode
    If blnDisplayMode Then 
        SetReadOnly(objLayout)
    End IF
    '--------------------------------------debug------------------------------------
    'Response.write "<textarea rows=20 style='width:100%' >" & XMLEscape(objLayout.xml) & "</textarea>"
    'Response.write "<div>" & XMLEscape(objLayout.xml) & "</div>"
    'Response.end
    '-------------------------------------------------------------------------------
    'Script Header information:
    'we want the XML of the Layout Node only, not of any of its child nodes.
    strLayoutHeader = objLayout.OuterXml
    strLayoutHeader = Mid(strLayoutHeader, 1, InStr(strLayoutHeader, ">"))
    intLength = Len(strLayoutHeader)
    If Mid(strLayoutHeader, intLength - 1, 1) <> "/" Then 
        strLayoutHeader = Left(strLayoutHeader, intLength - 1) & " />"
    End IF
    'Typed lookups (when in run-time mode) are populated here, as we need access to the
    'Data_XML to determine the limiting type.
    'If not blnTemplateMode and not blnDisplayMode Then GetTypedLookups DOM, strData_XML						'08Jul05 AE  Added blnDisplayMode
    If Not blnTemplateMode Then GetTypedLookups(DOM, strData_XML, blnDisplayMode, blnCopyMode, blnAmendMode, sessionId) '08Jul05 AE  Added blnDisplayMode, 03Mar08 ST - Added copymode, amendmode
    
    '20Jun08 ST  Commented out as part of 9.13 merges
    'If Not blnTemplateMode Then 
    'GetTypedLookups(DOM, strData_XML, blnDisplayMode)
    'End IF
    '08Jul05 AE  Added blnDisplayMode
    'Now script the controls.
    colControls = objLayout.SelectNodes("*")
    For Each objControl In colControls
        'Script the control
        strThisControl_HTML = objControl.OuterXml & vbCr
        'Replace escaped "&" symbols
        strThisControl_HTML = Replace(strThisControl_HTML, "&amp;", "&")
        Response.Write(strThisControl_HTML)
        'Find the bottom of the lowest control
        intTop = Generic.CIntX(objControl.GetAttribute("top"))
        intHeight = Generic.CIntX(objControl.GetAttribute("height"))
        intBottom = intTop + intHeight
        If intBottom > intLowest Then
            intLowest = intBottom
        End If
        If (XmlExtensions.AttributeExists(objControl.GetAttribute("sizepercentage")) AndAlso objControl.GetAttribute("sizepercentage") = "1") Then
            '10Nov04 AE  'orrid nasty 'ack for percentage sizing.
            'Should only ever be the case for single custom controls, since
            'this flag is not user editable.
            'Note this will do something horrible if multiple custom controls set to size 100% height
            'were ever used.
            strControlID = objControl.GetAttribute("id")
            strReasonCaptureScript = "[id].style.height = [id].offsetHeight - divProblem.offsetHeight - 40" & vbCr & "divProblem.style.top = [id].offsetTop + [id].offsetHeight + 20 " & vbCr
            strReasonCaptureScript = Replace(strReasonCaptureScript, "[id]", strControlID)
        End If
    Next
    Response.Write(vbCr & vbCr)
    'The client script then populates
    'the appropriate controls with the data.
    If CStr(strData_XML) <> "" Then
        DOM.TryLoadXml(strData_XML)
        objData = DOM.SelectSingleNode("root")
        objSchedule = DOM.SelectSingleNode("root/Schedule")
        objReasonCapture = DOM.SelectSingleNode("root/data/" & Ascribe.Common.Constants.XML_ELMT_REASON)
        If objData Is Nothing Then
            'If the XML is missing or incorrect, raise an error.
        End If
        'Script the Problem Capture controls if specified in the template
        If Not blnTemplateMode And Not blnDisplayMode And Not blnResponseMode Then
            '25Sep06 AE  further check for response mode 31Oct05 AE  Don't show in display mode, reason is shown in the status panel 10Nov04 AE  Don't show problem capture in template mode
            '12Nov10    Rams    F0101257 - treatment reasons not available in template editor (Added Param IsReasonCaptureMandatory)
            Response.Write(ReasonCaptureControls(lngDataID, objReasonCapture, intLowest, IsReasonCaptureMandatory, sessionId))
            '28Oct05 AE  Added lngDataID parameter
        End If
        strDataForScripting = objData.OuterXml
        If Not objSchedule Is Nothing Then
            strScheduleForScripting = "<root>" & objSchedule.OuterXml & "</root>"
        End If
    End If
    'Write a hidden element which the order entry page uses to infer 																	'16Feb04 AE  improve error reporting and handling
    'whether the form loaded correctly.
    Response.Write("<p id=""loadComplete"" />")
    'Tidy up.
    DOM = Nothing
    objLayout = Nothing
    objData = Nothing
%>



<!-- Holds the header of the layout with size information etc -->
<xml id=layoutData>
	<xmldata formid="<%= Request.QueryString("FrameID") %>" >
<%= strLayoutHeader %>
	</xmldata>
</xml>
	
<!-- Used to hold the data entered into the form -->
<xml id=instanceData>
<%= strDataForScripting %>
</xml>


<!-- Holds the scedule XML attached to this item -->
<xml id=scheduleData>
<%= strScheduleForScripting %>
</xml>

<!-- General use XML -->
<xml id='tempXML' />

<!-- Script to position the reason capture section when percentage sizing is used -->
<script language="javascript" type="text/javascript">
var m_blnDone = false;
function PositionProblemDiv(){
	if (document.all['divProblem'] != undefined && !m_blnDone) {
<%= strReasonCaptureScript %>
		//Problem controls are hidden until positioned
		divProblem.style.visibility = 'visible'
		m_blnDone = true;
	}
}
//For some reason tabindex is not working on list items , so to work around find the item with tabindex 1 and set focus on load
function SetFocusonTabIndex1()
{
    try
    {
        //ControlwithTabIndex1 is a variable defined in VB_Code/OrderForm.Vb
        var control = document.getElementById("<%=ControlwithTabIndex1%>");
        
        if(control != undefined)
        {
            control.focus();
            if(control.type == 'select-one')
            {
                control.options[0].selected = true;
            }   
        }
    }
    catch(err)
    {
        //
    }
}

</script>



</body>
</html>

<%
'function DisplayTimer //LM 17/01/2008 Code 162 Added the function, Is this function used??? Remove this after investigation
	'response.write Timer() & "<br/>"
'end function 
%>
