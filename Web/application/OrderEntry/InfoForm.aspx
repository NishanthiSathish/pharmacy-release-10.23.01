<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.OrderForm" %>
<%@ Import Namespace="Ascribe.Common.OrderEntry" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>


<%
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
	Dim SessionID As Integer = Integer.Parse(Request.QueryString("SessionID"))
	Dim OrderTemplateID As Integer	 'ID of the Order Template / OrderSetType Template whos detail to show
	Dim InstanceID As Integer	'For Pending/Committed items, the ID of the row being shown (pending item id, request id)
	Dim DataClass As String = Request.QueryString("DataClass")	   'template, pending, etc.  Indicates the table in which the data is currently saved.
	Dim DisplayMode As Boolean	 'True if the form should be read-only
	Dim Detail_HTML As String = String.Empty	'Holds the HTML/text from the Detail field
	Dim Data_XML As String = String.Empty
	Dim schedule_XML As String = String.Empty
	Dim StartDate As String = String.Empty
	Dim StartTime As String = String.Empty
	
	m_intTabIndex = 0
	'Pillage the querystring of its knowledge)
	If Not Integer.TryParse(Request.QueryString("OrderTemplateID"), OrderTemplateID) Then
		OrderTemplateID = 0
	End If
	If Not Integer.TryParse(Request.QueryString("DataRow"), InstanceID) Then
		InstanceID = 0
	End If
	If Not Boolean.TryParse(Request.QueryString("Display"), DisplayMode) Then
		DisplayMode = False
	End If
	Select Case DataClass
		Case "pending"
			'If we are editing a pending orderset, we need to read it's XML and extract the schedule.
			Dim Pending_XML As String = New OCSRTL10.PendingItemRead().GetItemByID(SessionID, InstanceID)
			Dim PendingDoc As New XmlDocument()
			PendingDoc.TryLoadXml(Pending_XML)
			Dim PendingItem As XmlElement = PendingDoc.SelectSingleNode("PendingItem")
			Data_XML = PendingItem.GetAttribute("ItemXML")
			PendingDoc.TryLoadXml(Data_XML)
			Dim Schedule As XmlElement = PendingDoc.SelectSingleNode("//Schedule")
			If Not Schedule Is Nothing Then
				'We only ever have a one off schedule here.
				StartDate = Schedule.GetAttribute("StartDate")
				StartTime = Schedule.GetAttribute("StartTime")
				schedule_XML = Schedule.OuterXml
				'dunno if this is needed  16May05 AE  Yes, it was.  Reinstated.
			End If
			OrderTemplateID = Integer.Parse(PendingItem.GetAttribute("OrderTemplateID"))
		Case "request"
			'Viewing committed orderset (if DisplayMode is true), or copying one (if DisplayMode is false)
			'Must recover the Start Date/time from the episodeorder table in the db.
			Dim Item_XML As String = New OCSRTL10.OrderCommsItemRead().GetEpisodeOrderCore_XML(SessionID, InstanceID)
			Dim EpisodeOrderDoc As New XmlDocument()
			EpisodeOrderDoc.TryLoadXml(Item_XML)
			Dim EpisodeOrder As XmlElement = EpisodeOrderDoc.SelectSingleNode("EpisodeOrder")
			'Extract the Start date/time (in mm/dd/yyyy format
			Dim RequestDate As Date = DateTime.Parse(EpisodeOrder.GetAttribute("RequestDate").Replace("T", " "))
			StartDate = RequestDate.ToString("dd/MM/yyyy")
			StartTime = RequestDate.ToString("HH:mm")
			Dim TableID As Integer = Generic.CIntX(EpisodeOrder.GetAttribute("TableID"))
            Data_XML = "<root>" & GetData_Instance("request", TableID, InstanceID, SessionID) & "</root>"
			'20Nov06 AE  Ensure status is shown on orderset page #SC-06-0423
			OrderTemplateID = Integer.Parse(EpisodeOrder.GetAttribute("OrderTemplateID"))
			If Not DisplayMode Then
				' We are copying / amending an existing item and so need to get the schedule data otherwise it will always sets date to Now()
                schedule_XML = GetBlankScheduleXML(SessionID)
				Dim ScheduleDoc As New XmlDocument()
				ScheduleDoc.TryLoadXml(schedule_XML)
				Dim Schedule As XmlElement = ScheduleDoc.DocumentElement()
				Schedule.SetAttribute("StartDate", StartDate)
				Schedule.SetAttribute("StartTime", StartTime)
				schedule_XML = ScheduleDoc.OuterXml()
			End If
	End Select
	'Read the orderset type definition
	'Read the orderset detail
	Dim ContentsAreOptions As String = String.Empty
	If OrderTemplateID > 0 Then
		Dim Orderset_XML As String = New OCSRTL10.OrderSetRead().GetByID(SessionID, OrderTemplateID)
		Dim OrdersetDoc As New XmlDocument()
		OrdersetDoc.TryLoadXml(Orderset_XML)
		Dim OrderTemplate As XmlElement = OrdersetDoc.SelectSingleNode("OrderTemplate")
		If Not OrderTemplate Is Nothing Then
			Detail_HTML = OrderTemplate.GetAttribute("Detail")
			ContentsAreOptions = OrderTemplate.GetAttribute("ContentsAreOptions")
		End If
	End If
	If Detail_HTML = String.Empty Then
		Detail_HTML = "There are no further details for this item"
	End If
	If DataClass = "orderset" Then
		'When loading for the first time, we need to store the value of the ContentsAreOptions flag in standard OCS xml format
		Data_XML = "<root><data filledin='True' reason=''/><attribute name='ContentsAreOptions' value='" & ContentsAreOptions & "'/></root>"
		'save the flag in the ItemsXML int the pending item table
	End If
%>

<html>

<script language="vb" runat="server">

	Dim m_intTabIndex As Integer
	Const DATE_FORMAT As String = "dd/mm/yyyy"
	
	Function NextTabIndex() As Integer
		
		m_intTabIndex = m_intTabIndex + 1
		Return m_intTabIndex
		
	End Function

</script>

<head>

<script language="javascript" src="../sharedscripts/Controls.js"></script>
<script language="javascript" src="scripts/OrderFormControls.js"></script>
<script language="javascript" src="../sharedscripts/DateLibs.js"></script>
<script language="javascript" src="../sharedscripts/icwFunctions.js"></script>
<script language="javascript" src="CustomControls/CustomControlShared.js"></script>

<script language="javascript" defer>

var m_CurrentStartDate; 				// Used to determine when the start date changes. (And not just rely on blur (lost focus) event)
var m_CurrentStartTime; 				// Used to determine when the start time changes. (And not just rely on blur (lost focus) event)
//-------------------------------------------------------------------------------------
function Date2HHMM(dtDate){

    var HH = dtDate.getHours();
    if (HH.toString().length == 1) HH = '0' + HH;
    
    var MM = dtDate.getMinutes();
    if (MM.toString().length == 1) MM = '0' + MM;
    
    return (HH + ':' + MM);
}
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

	var astrStartDate = '<%= StartDate %>'.split('/');									//[0]dd [1]mm [2]yyyy
	var astrStartTime = '<%= StartTime %>'.split(':');									//[0]hh [1]nn

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
function ToggleStartDate(objDate){

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
	lblStartDate.style.visibility = tdStartTime.style.visibility;
	
	// If changed to immediate then clear date and times so they are set to null.
	formXMLData.XMLDocument.selectSingleNode ( 'root' ).setAttribute ( 'lstScheduleIndex', lstSchedule.selectedIndex  );

	//Populate the Start Date box if appropriate
	var objDateControl = new DateControl(txtStartDate);
	var dtNow = new Date();
	if (objDate != undefined)
	{
		dtNow = objDate
	}
	if (objDateControl.GetDate() == null || blnImmediate) {											//07Jan04 AE Removal not good enough, replaced with this fella. #77972	
		objDateControl.SetDate(dtNow);

		txtStartDate.value = Date2ddmmccyy ( dtNow ); 
		txtStartTime.value = Date2HHMM     ( dtNow );
		
		if (blnImmediate && objDate == undefined) void SignalDateChange();							//29Nov06 AE  Added if - prevent it firing twice when we're NOT setting to immediate. 04Nov06 AE  Update dependant start dates when we set the start date back to immediate	
	}
}
//-------------------------------------------------------------------------------------
function SetStartDate(objDate, blnImmediate){
//05Aug04 AE  Replace missing method; 
//27Oct04 PH  Set Combo to "Choose Date" if the date has been set by the container, 
//				  unless it's been set to "today"
	var objDateControl = new DateControl(txtStartDate);
	objDateControl.SetDate(objDate);
	var datToday = new Date();
	var strTime = "";
	var strHours = "";
	var strMinutes = "";

	//* DPA 23.11.2007 Insert as part of merging process...
	// 07Sep05 ST	Changed to display time not being shown on page
	strHours = objDate.getHours().toString();																	//12Aug04 AE  Fix; prevents 12:05 appearing as 12:5
	if(strHours.length ==1) {strHours = '0' + strHours};
	strMinutes = objDate.getMinutes().toString();
	if (strMinutes.length ==1) {strMinutes = '0' + strMinutes};
	strTime +=  strHours + ':' + strMinutes;
	document.getElementById("txtStartTime").value = strTime;

	if (blnImmediate)
	{
	    document.getElementById("lstSchedule").selectedIndex = 0; // Immediate
	    ToggleStartDate(objDate);
	}
	else
	{
	    document.getElementById("lstSchedule").selectedIndex = 1; // Schedule (choose date)
	    ToggleStartDate();
	}

}

//-------------------------------------------------------------------------------------
function MonthView_Selected(controlID) {
//Callback when pop-up monthview has been used.
    void StartDateLostFocus();
}
//-------------------------------------------------------------------------------------

//* DPA 23.11.2007 Insert as part of merging process...
function SignalTimeChange()
{
	var strStartTime = document.getElementById("txtStartTime").value;
	if(strStartTime != "")
	{
		var objDateControl = new DateControl(txtStartDate);
		var strTime = txtStartTime.value;
		if(strTime.length != 5)
		{
			strTime = '00:00';
		}
		
		if(objDateControl.ContainsValidDate())
		{
			var objDate = objDateControl.GetDate();
			var strDDMMYYYY = Date2DDMMYYYY(objDate) + ' ' + strTime;
			void window.parent.UpdateStartTime(strDDMMYYYY);
			
		}
	}
}

//-------------------------------------------------------------------------------------

function SignalDateChange()
{
	//Fires when the start date is changed; we must inform the container, orderentry,
	//of the change so that if we are in an order set, it can syncronise the
	//start dates of any items which follow on from this one.

	//ShuffleStartTimes uses explicit dd/mm/yyyy hh:nn format, so convert the date
    //into that form. 
    var objDateControl = new DateControl(txtStartDate);

    if (objDateControl.ContainsValidDate())
    {
        var objDate = objDateControl.GetDate();
        if (txtStartTime.value.length != 5)
        {
            txtStartTime.value = '00:00';
        }
        var strDDMMYYYY = Date2DDMMYYYY(objDate) + ' ' + txtStartTime.value; 					//25Mar05 AE  Fixed "strTime is undefined"
        var blnImmediate = (lstSchedule.options[lstSchedule.selectedIndex].value == 'immediate');
        void window.parent.ShuffleStartTimes(strDDMMYYYY, blnImmediate);
    }
}

//=======================================================================================================================
function StartDateOnFocus()
{
    m_CurrentStartDate = txtStartDate.value;
}

//=======================================================================================================================
function StartDateLostFocus()
{
    var objDateControl = new DateControl(txtStartDate);
    if (objDateControl.ContainsValidDate() && m_CurrentStartDate != txtStartDate.value) {
        // 12Oct08 PH Fix to set Rx start time based upon date selection
        var objDate = objDateControl.GetDate();
        UpdateRxStartTime(objDate);
        SignalDateChange();
    }
}

//=======================================================================================================================
function StartTimeOnFocus()
{
    m_CurrentStartTime = txtStartTime.value;
}

//=======================================================================================================================
function StartTimeLostFocus()
{
    if (m_CurrentStartTime != txtStartTime.value) {
        SignalDateChange();
    }
}

/* 
12Oct08 PH
Fires when the Rx date is changed.
If the date is today, then time will be set to "now".
If the date is not today, then time will be set to "12:00"
*/
function UpdateRxStartTime(datEnteredDate)
{
	var strTEnteredDate = Date2TDate(datEnteredDate);
	var strTNow = Date2TDate(new Date());

	// If the entered date, today's date?
	if (strTEnteredDate.substr(0, 10) == strTNow.substr(0, 10))
	{
		// Is today's date, so set the time to now
		txtStartTime.value = strTNow.substr(11, 5);
	}
	else
	{
		// Is NOT today's date, so set the time to midnight
		txtStartTime.value = "00:00";
	}
	var Hours = txtStartTime.value.substr(0, 2);
	var Minutes = txtStartTime.value.substr(3, 2);
	datEnteredDate.setHours(Hours, Hours);
}

</script>

<link rel="stylesheet" type="text/css" href="../../style/OrderEntry.css" />
<link rel="stylesheet" type="text/css" href="../../style/application.css" />

</head>
<body class="OrderFormBody InfoPage" 
		onload="window.parent.IndicateOrderFormReady();<%
    If DisplayMode Then 
        Response.Write("SetReadOnly();")
    End If
    If StartDate.Length > 0 Then 
        Response.Write("EnterDate();")
    End If
%>
" 
		displaymode="<%= LCase(CStr(DisplayMode)) %>">

<div id="divAll">

<h1>Start Date</h1>
<hr />
<div id="divDate" class="Contents" style="visibility:hidden;">
	<table>
		<tr id="trSchedule" >
			<td <%
    If DisplayMode Then 
        Response.Write("style='display:none'")
    End If
%>
>Start</td>	
			<td <%
    If DisplayMode Then 
        Response.Write("style='display:none'")
    End If
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
    End If
%>
">
				<td id="lblStartDate">Start<%
    If DisplayMode Then 
        Response.Write("ed")
    End If
%>
 on:
				</td>
	
			<td>
				<input type="text" id="txtStartDate" 
						 tabindex="<%= NextTabIndex() %>" 
						 validchars="DATE:<%= DATE_FORMAT %>" onkeypress="MaskInput(this);" onfocus="this.select();StartDateOnFocus();" onpaste="MaskInput(this);" 
						 onblur="<%
    If Not CDbl(DisplayMode) Then 
        Response.Write("StartDateLostFocus();")
    End If
%>
" 
						 class="MandatoryField" />
				<img src="../../images/ocs/show-calendar.gif" 
					  class="linkImage" <%
    If DisplayMode Then 
        Response.Write("disabled")
    End IF
%>

<%
    If Not CDbl(DisplayMode) Then 
%>

					  		onclick="CalendarShow(this, txtStartDate);" 
<%
    End If
%>

					  />
			</td>
	
			<td id="tdStartTimeLabel" style="text-align:right">
				at:
			</td>
			<td id="tdStartTime" colspan="2">
				<input type="text" id="txtStartTime" tabindex="<%= NextTabIndex() %>" validchars="TIME" 
								onblur="<% If Not DisplayMode Then Response.write ("StartTimeLostFocus();")%>"
				                onkeypress="MaskInput(this);" onpaste="MaskInput(this);" onfocus="this.select();StartTimeOnFocus();" class="StandardField" />
				                  <!-- LM, Code 162, 10/01/2008  Added Brackets--> <!-- '* DPA 23.11.2007 Insert as part of merging process...-->
			</td>
		</tr>
	</table>
</div>

<h1>Further Information</h1>
<hr />

<div id="divContent" class="Contents">
<%= Detail_HTML%>
</div>

<%
    'Write a hidden element which the order entry page uses to infer 									'16Feb04 AE  improve error reporting and handling
    'whether the form loaded correctly.
    Response.Write("<p id=""loadComplete"" />")
    'Tidy up
%>

</div>

<xml id=instanceData><%= Data_XML%></xml>

<!-- Holds the scedule XML attached to this item.  This is only ever a single schedule with a start date/time and nothing else, and is rebuilt each time the item is saved.  -->
<xml id="scheduleData"><%= schedule_XML %></xml>

<!-- Holds small amount of data not saved anywhere else -->
<xml id="formXMLData"><root /></xml>
</body>
</html>