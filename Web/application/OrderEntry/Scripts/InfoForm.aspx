<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.OrderForm" %>
<%@ Import Namespace="Ascribe.Xml" %>

<!--#include file="../../SharedScripts/ASPHeader.aspx"-->

<!-- 
LM Code 162, 10/01/2008 ,
Removed Reference to Scripts/OrderForm.vb.vb
Imported the namespaces Ascribe.Common.OrderForm
-->

<html>

<head>

<script language="vb" runat="server">

    '--------------------------------------------------------------------------------------------------
    'InfoForm.aspx
    '
    'Read-only page which is shown together with Order Forms in OrderEntry.aspx.  This
    'page will display information, such as order set detail, and OrderTemplateDetail
    '
    'The page scripts information unescaped, so raw HTML can be used.
    '
    'Querystring Parameters:
    '
    'SessionID			(mandatory)
    'OrderTemplateID	(mandatory)							- ID of the order template (including order set types) to show info for
    'DataClass			(mandatory)							- Type of item the ID refers to;
    '"orderset" - this is an ordersettype Order Template
    '"info"	  - this is a standard ordertemplate
    '
    '-----------------------------------------------------------------------
    'Modification History:
    '26Jan05 AE  Written
    '04Nov06 AE  Ensure everything is disabled in DisplayMode #SC-06-1010
    'Update dependant start dates when we set the start date back to immediate.
    '22Dec06 AE  Ensure dates shown correctly in displaymode #SC-06-1106
    '28Feb07 AE  Re-arranged to fix #SC-07-0104; removed references to transport layer and restructured code
    'to use the existing call to OrdersetRead.  Also ensure that further detail is visible whether
    'creating new, editing, or copying an orderset.
    '--------------------------------------------------------------------------------------------------
    Dim SessionID As Integer
    Dim OrderTemplateID As Object 
    'ID of the Order Template / OrderSetType Template whos detail to show
    Dim InstanceID As Object 
    'For Pending/Committed items, the ID of the row being shown (pending item id, request id)
    Dim DataClass As String 
    'template, pending, etc.  Indicates the table in which the data is currently saved.
    Dim OCSType As String 
    'Indicates the ultimate destination table of the item.
    Dim DisplayMode As Object 
    'True if the form should be read-only
    Dim objOrdersetRead As OCSRTL10.OrderSetRead
    Dim objOrderCommsItemRead As OCSRTL10.OrderCommsItemRead
    Dim objPending As OCSRTL10.PendingItemRead
    Dim DOM As XmlDocument
    Dim xmlItem As XmlElement
    Dim DOMPending As XmlDocument
    Dim xmlPending As XmlElement
    Dim xmlSchedule As XmlElement
    Dim DOMItem As XmlDocument
    'Dim objTransport
    Dim strContentsAreOptions As String
    Dim strOrderset_XML As String 
    Dim strItem_XML As String 
    Dim blnShowSchedule As Boolean
    'If true, the scheduler controls will be shown
    Dim strDetail_HTML As String
    'Holds the HTML/text from the Detail field
    Dim schedule_XML As String 
    Dim strPending_XML As String 
    Dim strData_XML As String
    Dim strStartDate As String
    Dim strStartTime As String
    Dim lngTableID As Integer 
    Dim m_intTabIndex As Integer 
    Const DATE_FORMAT As String = "dd/mm/yyyy"
    Function NextTabIndex() As Integer
        m_intTabIndex = m_intTabIndex + 1
        NextTabIndex = m_intTabIndex
    End Function

</script>

<%
    strDetail_HTML = ""
    schedule_XML = ""
    strPending_XML = ""
    strData_XML = ""
    strStartDate = ""
    strStartTime = ""
    lngTableID = 0
    m_intTabIndex = 0
    'Pillage the querystring of its knowledge
    SessionID = CInt(Request.QueryString("SessionID"))
    OrderTemplateID = Request.QueryString("OrderTemplateID")
    If CStr(OrderTemplateID) = "" Then 
        OrderTemplateID = 0
    End IF
    OrderTemplateID = CInt(OrderTemplateID)
    DataClass = Request.QueryString("DataClass")
    OCSType = Request.QueryString("OCSType")
    InstanceID = CInt(Request.QueryString("DataRow"))
    If CStr(InstanceID) = "" Then 
        InstanceID = 0
    End IF
    InstanceID = CInt(InstanceID)
    DisplayMode = Request.QueryString("Display")
    If CStr(DisplayMode) = "" Then 
        DisplayMode = false
    End IF
    DisplayMode = CBool(DisplayMode)
    Select Case DataClass
        Case "pending"
            'If we are editing a pending orderset, we need to read it's XML and extract the schedule.
            objPending = New OCSRTL10.PendingItemRead()
            strPending_XML = objPending.GetItemByID(SessionID, InstanceID)
            objPending = Nothing
            DOMPending = New XmlDocument()
            DOMPending.TryLoadXml(strPending_XML)
            xmlPending = DOMPending.SelectSingleNode("PendingItem")
            strData_XML = xmlPending.GetAttribute("ItemXML")
            DOMPending.TryLoadXml(CStr(strData_XML))
            xmlSchedule = DOMPending.SelectSingleNode("//Schedule")
            If Not xmlSchedule Is Nothing Then
                'We only ever have a one off schedule here.
                strStartDate = xmlSchedule.GetAttribute("StartDate")
                strStartTime = xmlSchedule.GetAttribute("StartTime")
                If Not xmlSchedule Is Nothing Then
                    schedule_XML = xmlSchedule.OuterXml
                End If
                'dunno if this is needed  16May05 AE  Yes, it was.  Reinstated.
            End If
            OrderTemplateID = xmlPending.GetAttribute("OrderTemplateID")
        Case "request"
            'Viewing committed orderset (if DisplayMode is true), or copying one (if DisplayMode is false)
            'Must recover the Start Date/time from the episodeorder table in the db.
            objOrderCommsItemRead = New OCSRTL10.OrderCommsItemRead()
            strItem_XML = objOrderCommsItemRead.GetEpisodeOrderCore_XML(SessionID, InstanceID)
            objOrderCommsItemRead = Nothing
            DOMItem = New XmlDocument()
            DOMItem.TryLoadXml(strItem_XML)
            xmlItem = DOMItem.SelectSingleNode("EpisodeOrder")
            'Extract the Start date/time (in mm/dd/yyyy format
            strStartDate = Generic.Date2ddmmccyy(Generic.TDate2Date(xmlItem.GetAttribute("RequestDate")))
            strStartTime = Generic.Date2HHmm(Generic.TDate2Time(xmlItem.GetAttribute("RequestDate")))
            lngTableID = CInt(Generic.CIntX(xmlItem.GetAttribute("TableID")))
            strData_XML = "<root>" & GetData_Instance("request", lngTableID, InstanceID, SessionID) & "</root>"
            '20Nov06 AE  Ensure status is shown on orderset page #SC-06-0423
            OrderTemplateID = xmlItem.GetAttribute("OrderTemplateID")
    End Select
        'Read the orderset type definition
        'Read the orderset detail
    If CInt(OrderTemplateID) > 0 Then 
        objOrdersetRead = new OCSRTL10.OrderSetRead()
        strOrderset_XML = objOrdersetRead.GetByID(SessionID, CInt(OrderTemplateID))
        objOrdersetRead = Nothing
        DOM = new XmlDocument()
        DOM.TryLoadXml(strOrderset_XML)
        xmlItem = DOM.SelectSingleNode("OrderTemplate")
        If Not xmlItem Is Nothing Then 
            strDetail_HTML = xmlItem.GetAttribute("Detail")
            strContentsAreOptions = xmlItem.GetAttribute("ContentsAreOptions")
        End IF
    End IF
    If Len(strDetail_HTML) = 0 Then 
        strDetail_HTML = "There are no further details for this item"
    End IF
    If DataClass = "orderset" Then 
        'When loading for the first time, we need to store the value of the ContentsAreOptions flag in standard OCS xml format
        strData_XML = "<root><data filledin='True' reason=''/><attribute name='ContentsAreOptions' value='" & strContentsAreOptions & "'/></root>"
    'save the flag in the ItemsXML int the pending item table
    End IF
%>




<link rel="stylesheet" type="text/css" href="../../style/OrderEntry.css">
<link rel="stylesheet" type="text/css" href="../../style/application.css">

<script language="javascript" src="../sharedscripts/Controls.js"></script>
<script language="javascript" src="scripts/OrderFormControls.js"></script>
<script language="javascript" src="../sharedscripts/DateLibs.js"></script>
<script language="javascript" src="../sharedscripts/icwFunctions.js"></script>
<script language="javascript" src="CustomControls/CustomControlShared.js"></script>

<script language="javascript" defer>
//-------------------------------------------------------------------------------------
function Enable(){
//Called by the container when all of the other pages have loaded.		#SC-07-0043
	divDate.style.visibility='visible';
}
//-------------------------------------------------------------------------------------
function EnterDate(){

//Used only from this page's onload handler, to set the start date when we are displaying a pendingitem which
//already has a schedule set.  It does NOT signal the change to the parent item.
//Could do server-side, but using the client code for consistency.

	var astrStartDate = '<%= strStartDate %>'.split('/');									//[0]dd [1]mm [2]yyyy
	var astrStartTime = '<%= strStartTime %>'.split(':');									//[0]hh [1]nn

	//Create a new date object, using parameters method to remove any ambiguity
	var dtBaseStart = new Date(astrStartDate[2], (Number(astrStartDate[1]) - 1), astrStartDate[0], astrStartTime[0], astrStartTime[1]);	

	//Set the start date to this date
	SetStartDate(dtBaseStart)
}
//-------------------------------------------------------------------------------------
function PageHeight(){
//Returns the height of the page

	return (divAll.offsetHeight + divAll.scrollHeight + 50);
}

//-------------------------------------------------------------------------------------
function ToggleStartDate(){

//Called when the "today/choose time" drop down is changed.Enables/disables
//the Start date/time boxes as appropriate.
	var blnImmediate = (lstSchedule.options[lstSchedule.selectedIndex].value == 'immediate');
	trStartDate.style.visibility = GetVisibilityString(!blnImmediate);

	if (document.body.getAttribute('displaymode') != 'true') {
	//Edit mode, we only show the start time box if this is an dose scheduled for later.
		tdStartTime.style.visibility = GetVisibilityString(!blnImmediate);		
	}
//	else {
//	//In display mode, we show the start time even if Immediate was chosen, this will show the
//	//time the prescription was actually approved.
//		tdStartTime.style.visibility = GetVisibilityString(true);
//	}
	tdStartTimeLabel.style.visibility = tdStartTime.style.visibility;

	//Populate the Start Date box if appropriate
	var objDateControl = new DateControl(txtStartDate);
	var dtNow = new Date();
	if (((objDateControl.GetDate() == null) && !blnImmediate) || blnImmediate) {											//07Jan04 AE Removal not good enough, replaced with this fella. #77972	
		objDateControl.SetDate(dtNow);
		if (blnImmediate) void SignalDateChange();																					//29Nov06 AE  Added if - prevent it firing twice when we're NOT setting to immediate. 04Nov06 AE  Update dependant start dates when we set the start date back to immediate	
	}

}
//-------------------------------------------------------------------------------------
function SetStartDate(objDate){
//05Aug04 AE  Replace missing method; 
//27Oct04 PH  Set Combo to "Choose Date" if the date has been set by the container, 
//				  unless it's been set to "today"
	var objDateControl = new DateControl(txtStartDate);
	objDateControl.SetDate(objDate);
	var datToday = new Date();
	var strTime = "";
	var strHours = "";
	var strMinutes = "";

	// 07Sep05 ST	Changed to display time not being shown on page
	//strHours = objDate.getHours().toString();																	//12Aug04 AE  Fix; prevents 12:05 appearing as 12:5
	//if(strHours.length ==1) {strHours = '0' + strHours};
	//strMinutes = objDate.getMinutes().toString();
	//if (strMinutes.length ==1) {strMinutes = '0' + strMinutes};
	//strTime +=  strHours + ':' + strMinutes;
	//document.getElementById("txtStartTime").value = strTime;
	
	if ( objDate.getFullYear()!=datToday.getFullYear() || objDate.getMonth()!=datToday.getMonth() || objDate.getDate()!=datToday.getDate() )
	{
		document.getElementById("lstSchedule").selectedIndex = 1; // Schedule (choose date)
		ToggleStartDate();		
	}

}

//-------------------------------------------------------------------------------------
function MonthView_Selected(controlID) {
//Callback when pop-up monthview has been used.
	void SignalDateChange();
}
//-------------------------------------------------------------------------------------

function SignalDateChange(){

//Fires when the start date is changed; we must inform the container, orderentry,
//of the change so that if we are in an order set, it can syncronise the
//start dates of any items which follow on from this one.
	
	//ShuffleStartTimes uses explicit dd/mm/yyyy hh:nn format, so convert the date
	//into that form. 
	var objDateControl = new DateControl(txtStartDate);
	var strTime = txtStartTime.value;
	if (strTime.length != 5) strTime = '00:00';
	
	if (objDateControl.ContainsValidDate()) {																							
		var objDate = objDateControl.GetDate();
		var strDDMMYYYY = Date2DDMMYYYY(objDate) + ' ' + strTime;
		void window.parent.ShuffleStartTimes (strDDMMYYYY);		
	}
}
</script>

</head>
<body class="OrderFormBody InfoPage" 
		onload="window.parent.IndicateOrderFormReady();<%
    If DisplayMode Then 
        Response.Write("SetReadOnly();")
    End IF
    If CStr(strStartDate) <> "" Then 
        Response.Write("EnterDate();")
    End IF
%>
" 
		displaymode="<%= LCase(CStr(DisplayMode)) %>">

<div id="divAll">
<%
    '------------------------------------------ Orderset page with Scheduler ----------------------------------------------
    blnShowSchedule = true
%>


<h1>Start Date</h1>
<hr />
<div id="divDate" class="Contents" style="visibility:hidden;">
	<table>
		<tr id="trSchedule" >
			<td <%
    If DisplayMode Then 
        Response.Write("style='display:none'")
    End IF
%>
>Start</td>	
			<td <%
    If DisplayMode Then 
        Response.Write("style='display:none'")
    End IF
%>
>
				<select id="lstSchedule" onchange="ToggleStartDate();" tabindex="<%= NextTabIndex() %>">
					<option value="immediate" selected>Immediately</option>
					<option value="schedule">Choose Date</option>
				</select>
			</td>
		</tr>
	
		<tr id="trStartDate" style="<%
    If Not CDbl(DisplayMode) Then 
        Response.Write("visibility:hidden")
    End IF
%>
">
				<td id="lblStartDate">Start<%
    If DisplayMode Then 
        Response.Write("ed")
    End IF
%>
 on:
				</td>
	
			<td>
				<input type="text" id="txtStartDate" 
						 tabindex="<%= NextTabIndex() %>" 
						 validchars="DATE:<%= DATE_FORMAT %>" onkeypress="MaskInput(this);" onpaste="MaskInput(this);" 
						 onblur="<%
    If Not CDbl(DisplayMode) Then 
        Response.Write("SignalDateChange();")
    End IF
%>
" 
						 class="MandatoryField" />
				<img src="../../images/ocs/show-calendar.gif" 
					  class="linkImage<%
    If DisplayMode Then 
        Response.Write("Disabled")
    End IF
%>
"
<%
    If Not CDbl(DisplayMode) Then 
%>

					  		onclick="CalendarShow(this, txtStartDate);" 
<%
    End IF
%>

					  />
			</td>
	
			<td id="tdStartTimeLabel" style="text-align:right">
				at:
			</td>
			<td id="tdStartTime" colspan="2">
				<input type="text" id="txtStartTime" tabindex="<%= NextTabIndex() %>" validchars="TIME" onkeypress="MaskInput(this);" onpaste="MaskInput(this);" class="StandardField" />
			</td>
		</tr>
	</table>
</div>

<h1>Further Information</h1>
<hr />

<div id="divContent" class="Contents">
<%= strDetail_HTML %>
</div>

<%
    'Write a hidden element which the order entry page uses to infer 									'16Feb04 AE  improve error reporting and handling
    'whether the form loaded correctly.
    Response.Write("<p id=""loadComplete"" />")
    'Tidy up
    xmlItem = Nothing
    DOM = Nothing
    xmlSchedule = Nothing
    DOMPending = Nothing
    DOMItem = Nothing
%>

</div>

<xml id=instanceData>
<%= strData_XML %>
</xml>

<!-- Holds the scedule XML attached to this item.  This is only ever a single schedule with a start date/time and nothing else, and is rebuilt each time the item is saved.  -->
<xml id="scheduleData"><%= schedule_XML %></xml>
</body>
</html>
