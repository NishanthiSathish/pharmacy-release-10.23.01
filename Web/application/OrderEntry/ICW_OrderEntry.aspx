<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import namespace="Ascribe.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.OCSStatusMessage" %>
<%@ OutputCache Location="None" VaryByParam="None" %>
<%-- 10/05/2010     LAW     F0085483 - Data output on Order Entry screen was  outputting html escaped characters, fixed using Server.HtmlDecode() --%>
<html>
<%
    Dim KEY_DEFAULT_VIEW As String = String.Empty
    Dim VALUE_PAGED_VIEW As String = String.Empty
    Dim VALUE_STACKED_VIEW As String = String.Empty

	Const SHOW_LOADING_TIME As Boolean = False
    Dim SessionID As Integer
    Dim OrderTemplate As String
    Dim OnSaveDestination As String
	Dim PendingItemMode As String
    Dim PendingItemView As String
	Dim EpisodeID As Integer
	Dim DispensaryMode As Boolean
    Dim DOM As XmlDocument = Nothing
    Dim colLayouts As XmlNodeList = Nothing
	Dim objStateRead As GENRTL10.StateRead
	Dim objSettingRead As GENRTL10.SettingRead
	Dim objRequestLock As OCSRTL10.RequestLock
	Dim objEntityLock As ENTRTL10.EntityLock
	Dim objEntityRead As ENTRTL10.EntityRead
	Dim strInstruction_XML As String
	Dim xmldocInstruction As XmlDocument
	Dim xmleleInstruction As XmlElement
    Dim strOrders_XML As String
    Dim blnDisplayMode As Boolean
    Dim blnRespondMode As Boolean
    Dim blnPreviewMode As Boolean
    Dim blnTemplateMode As Boolean
    Dim blnCancelMode As Boolean
    Dim blnPendingMode As Boolean
    Dim blnCopyMode As Boolean
    Dim blnNewMode As Boolean
    Dim blnEmbeddedMode As Boolean
    Dim blnIsOrderset As Boolean
    Dim blnIsInfoPage As Boolean
	Dim blnIsSharedPage As Boolean
	Dim blnAmendMode As Boolean			'* DPA 23.11.2007 Insert as part of merging process...
	Dim blnLocked As Boolean
	Dim strOnClick As String
	Dim strAction As String
    Dim strStyle As String
	Dim intCount As Integer
	Dim strClass As String
    Dim strDataclass As String
	Dim strDescription As String
	Dim strTitle As String
	Dim lngID As Integer
    Dim lngTemplateID As Integer
    Dim isRx As String
    Dim isSms As String
	Dim strOKFunction As String
	Dim strOKText As String
	Dim strURL As String
	Dim strFrameID As String
	Dim lngOnSaveDesktopID As Integer
	Dim strOnSaveDesktopName As String
	Dim strScheduleID As String
	Dim strDefaultView As String
	Dim strEpisodeInfo As String
	Dim blnMasterMode As Boolean
	Dim xmldocLock As XmlDocument
	Dim xmleleLock As XmlElement
	Dim IsRequestLocked As Integer
    Dim IsLockOverridable As String
    Dim strLockDetails As String = String.Empty
    Dim OverrideLock As Integer
    Dim strLockMessage As String = String.Empty
	Dim lngEntityID As Integer
    Dim strLockObject As String = String.Empty
	Dim blnSharedColumnsExist As Boolean
    Dim strTableIDList As String = String.Empty
	Dim objSharedDetailRead As OCSRTL10.SharedDetailRead
	Dim strPage As String
	Const FORMID_PREFIX As String = "orderForm"
	Const SCHEDULEID_PREFIX As String = "scheduleBar"
	Const DESCRIPTION_LENGTH_MAX As Integer = 35
	Dim strTempURL As String
	Dim xmlElement As XmlElement 'JA 29-10-2007
	Dim blnRxExists As Boolean ' Will be true if a prescription appears in order entry
	Dim blnFirstInstructionIsOrderSet As Boolean
    Dim strCommitWhenAmending As String
    Dim LeavePendingOption As Boolean
    Dim IgnorePendingIfIncomplete As Boolean = False
%>
<head>
<title>Order Comms Data Entry</title>

<script language="javascript" type="text/javascript" src="../SharedScripts/ocs/StatusMessage.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/ocs/OCSConstants.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/icw.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/ICWFunctions.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/DateLibs.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/TimeLibs.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/Popmenu.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/ocs/OCSShared.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/icw.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/ClinicalModules/ClinicalModules.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/Controls.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/Locking.js"></script>
<script language="javascript" type="text/javascript" src="scripts/OrderEntryDataManipulation.js"></script>
<script language="javascript" type="text/javascript" src="scripts/OrderFormControls.js"></script>
<script language="javascript" type="text/javascript" src="scripts/OrderEntry.js"></script>
<script language="javascript" type="text/javascript" src="../sharedscripts/ocs/SaveResults.js"></script>

<script language="vbscript" type="text/vbscript">

function VBTimer()
	VBTimer = Timer()
end function

</script>




<%  
    lngOnSaveDesktopID = 0
	strOnSaveDesktopName = ""
	strScheduleID = ""
	strDefaultView = ""
	strEpisodeInfo = ""
	blnMasterMode = False
	'When editing templates, indicates whether we are a DSS user or a normal limited user.
	'For retrieving product names; we always use group 1, the "ascribe default"
	'Max number of characters shown in the index.
	'Obtain the session ID from the querystring
    SessionID = CInt(Request.QueryString("SessionID"))
	'Get the currently selected Entity from state
	objEntityRead = New ENTRTL10.EntityRead()
    lngEntityID = objEntityRead.GetSelectedEntity(SessionID)
	objEntityRead = Nothing
	'Querystring variables for use in application mode
	OrderTemplate = ICW.ICWParameter("OrderTemplate", "Name or ID of the Order Template to display when the application is loaded.", "")
	PendingItemMode = UCase(ICW.ICWParameter("Mode", "Determines who or what the pending items should be displayed for.", "Episode,CurrentLocation,User"))
	PendingItemView = ICW.ICWParameter("View", "Determines how the pending items should be filtered.", "Everything,ResponsesOnly,OrderablesOnly")
	OnSaveDestination = ICW.ICWParameter("ReturnToDesktop", "Name of the desktop to return to after the OK button is pressed", "")
	DispensaryMode = Request.QueryString("DispensaryMode") = "1"
	'15Feb06 AE
	strAction = LCase(Request.QueryString("Action"))
	OverrideLock = Generic.CIntX(Request.QueryString("overridelock"))
	objStateRead = New GENRTL10.StateRead()
    EpisodeID = CInt(objStateRead.GetKey(SessionID, "Episode"))
    objStateRead = Nothing
    blnEmbeddedMode = OrderEntry.EmbeddedMode()
	'If we have an order template specified, return the xml for it and any children
    If OrderTemplate <> "" Then
        'Check that we have an episode selected, otherwise just script a waiting page
        strAction = "idle"
        If EpisodeID > 0 Then
            strAction = "load"
        End If
        'Now get a desktop id if a ReturnToDesktop is specified.
        OrderEntry.GetDesktop(OnSaveDestination, lngOnSaveDesktopID, strOnSaveDesktopName, SessionID)
    End If
	'Now get the instruction xml if we are in load mode
	Select Case strAction
		Case "load"
			'We have some items to script, specified in the
			'submitted form, or in the OrderTemplate parameter.
            If OrderTemplate = "" Then
                'Retrieve the instruction XML.
                'strInstruction_XML =  Request.Form("orderEntryXML")
            
                strInstruction_XML = CStr(Generic.SessionAttribute(SessionID, "OrderEntry/OrdersXML")).Replace("_amp_", "&amp;amp;")
                '15Nov06 AE  No longer uses form but retrieves data from state
            ElseIf blnEmbeddedMode Then
                'Create instruction xml from the ordertemplate for embedded mode
                strInstruction_XML = "<embedded ordertemplate=""" & OrderTemplate & """ />"
            Else
                'Create instruction xml from the ordertemplate for popup mode
                strInstruction_XML = "<bytemplate ordertemplate=""" & OrderTemplate & """ />"
            End If
			'Also load setting(s)
			strDefaultView = CStr(OrderEntry.GetOCSSetting(SessionID, KEY_DEFAULT_VIEW, VALUE_PAGED_VIEW, (VALUE_PAGED_VIEW & "," & VALUE_STACKED_VIEW)))
		Case Else
			'Nothing doing...
			strInstruction_XML = ""
	End Select

    strCommitWhenAmending = OrderEntry.GetOCSSetting(SessionID, "AutoCommitWhenAmending", "0", "0,1")
    LeavePendingOption = OrderEntry.GetOCSSetting(SessionID, "LeavePendingOption", "1", "0,1")
    IgnorePendingIfIncomplete = OrderEntry.GetOCSSetting(SessionID, "IgnorePendingIfIncomplete", "0", "0,1")
    
	' Examine the instruction xml, and if the first item isn't an orderset, but we're editing an orderset item, then we're not editing an entire orderset, and we can put the orders-set header into read-only mode.
	xmldocInstruction = New XmlDocument()
    xmldocInstruction.TryLoadXml(strInstruction_XML)
	xmleleInstruction = xmldocInstruction.SelectSingleNode("//item")

	'13Oct08 ST - F0035477
	'Check to see if xmleleInstruction is valid
	If Not xmleleInstruction Is Nothing Then
		blnFirstInstructionIsOrderSet = Generic.CBoolX((xmleleInstruction.ChildNodes.Count() > 0))
	Else
		blnFirstInstructionIsOrderSet = False
	End If
	'---------------------------
	'debug
	'Response.write "<textarea rows=10 >" & strInstruction_XML & "</textarea>" & vbcr
	'Response.write "<li>" & Request.Querystring
	'Response.end
	'---------------------------
    blnEmbeddedMode = OrderEntry.EmbeddedMode()
    
	Select Case strAction
		Case "load"
            'Determine which mode(s) we are in
           
            'F0051961 ST 08May09    Part of the increasing the ICW performance code changes
            'Updated calls for determing which mode we are in, simple check rather than the old vb checking it was calling
            
            blnDisplayMode = strInstruction_XML.Contains("<display")            'blnDisplayMode = OrderEntry.DisplayMode(strInstruction_XML)
            blnPreviewMode = strInstruction_XML.Contains("<preview ")           'blnPreviewMode = OrderEntry.PreviewMode(strInstruction_XML)
            blnTemplateMode = strInstruction_XML.Contains("<template")          'blnTemplateMode = OrderEntry.TemplateMode(strInstruction_XML)
            blnAmendMode = strInstruction_XML.Contains("<amend")                'blnAmendMode = OrderEntry.AmendMode(strInstruction_XML)
            blnCopyMode = strInstruction_XML.Contains("<copy")                  'blnCopyMode = OrderEntry.CopyMode(strInstruction_XML)
            blnCancelMode = strInstruction_XML.Contains("<cancel")              'blnCancelMode = OrderEntry.CancelMode(strInstruction_XML)

            blnRespondMode = OrderEntry.ResponseMode(strInstruction_XML)
            blnPendingMode = OrderEntry.PendingMode(strInstruction_XML)
            blnNewMode = OrderEntry.NewMode(strInstruction_XML)
            
            
			'An EXISTING order is being edited, so first check to see if it is locked
			If blnCancelMode Then
				If InStr(strInstruction_XML, "class=""note""") > 0 Then
					'Ignore cancelling of notes
				Else
					strLockObject = "request"
					IsRequestLocked = 0
					objRequestLock = New OCSRTL10.RequestLock()
					If CInt(OverrideLock) = 1 Then
                        strLockDetails = objRequestLock.LockRequests(SessionID, strInstruction_XML, True)
					Else
                        strLockDetails = objRequestLock.LockRequests(SessionID, strInstruction_XML, False)
					End If
					'<rl RequestLockID=""13"" RequestID=""74293"" EntityID_User=""11178"" LocationID=""1349"" DesktopID=""14"" CreationDate=""2006-07-19T11:58:06.123"" UserFullName=""Some user"" TerminalName=""NM0418(H3 Main Desk)"" DesktopName=""Order Entry"" overridable=""0""/>
					objRequestLock = Nothing
					strLockMessage = "<table width=100% height=100% ><tr><td align=center ><table border=2><tr><td style='background-color:white; padding: 20px' align=center>" & "<b>Order is currently locked</b>"
				End If
			End If
			'A NEW order is being entered, (also could be a COPY), so check to see if the entity is locked
            If strLockDetails = "" And (blnNewMode Or blnCopyMode) Then
                strLockObject = "entity"
                objEntityLock = New ENTRTL10.EntityLock()
                If CInt(OverrideLock) = 1 Then
                    strLockDetails = objEntityLock.LockEntity(SessionID, lngEntityID, True)
                Else
                    strLockDetails = objEntityLock.LockEntity(SessionID, lngEntityID, False)
                End If
                '<el EntityLockID=""13"" EntityID=""74293"" EntityID_User=""11178"" LocationID=""1349"" DesktopID=""14"" CreationDate=""2006-07-19T11:58:06.123"" UserFullName=""Some user"" TerminalName=""NM0418(H3 Main Desk)"" DesktopName=""Order Entry"" overridable=""0""/>
                objEntityLock = Nothing
                strLockMessage = "<table width=100% height=100% ><tr><td align=center ><table border=2><tr><td style='background-color:white; padding: 20px' align=center>" & "<b>Patient is currently locked</b>"
            End If
			'If a lock situation has occured then setup locking message
			If strLockDetails <> "" Then
				xmldocLock = New XmlDocument()
                xmldocLock.TryLoadXml(strLockDetails)
				xmleleLock = xmldocLock.SelectSingleNode("*")
				blnLocked = True
				strLockMessage = strLockMessage & "<br><br>by" & "<br><br>User: " & xmleleLock.GetAttribute("UserFullName") & "<br>Terminal: " & xmleleLock.GetAttribute("TerminalName") & "<br>Desktop: " & xmleleLock.GetAttribute("DesktopName") & "<br>Date: " & Generic.TDate2DateTime(xmleleLock.GetAttribute("CreationDate"))
                If Not CDbl(blnCancelMode) Then
                    strLockMessage = strLockMessage & "<br><br><button id='btnRefresh' onclick='btnRefresh_onclick()'>Refresh</button> "
                Else
                    strLockMessage = strLockMessage & "<br><br>"
                End If
				If xmleleLock.GetAttribute("overridable") Then
                    strLockMessage = strLockMessage & "&nbsp;&nbsp;&nbsp;&nbsp;<button id='btnOverride' onclick='btnOverride_onclick()' style='width:100px;'>Override lock</button>"
				End If
				strLockMessage = strLockMessage & "</td></tr></table></td></tr></table>"
				xmldocLock = Nothing
				IsRequestLocked = 1
				IsLockOverridable = xmleleLock.GetAttribute("overridable")
				strAction = "locked"
			End If
			'Now send the Instruction XML to the business layer and get the layout IDs we need to load into the
			'order forms.
			strOrders_XML = OrderEntry.GetDataForDisplay(SessionID, strInstruction_XML)
			If blnTemplateMode Then
				'06Dec05 AE  Added check for Master Mode in template mode
				objSettingRead = New GENRTL10.SettingRead()
                blnMasterMode = (LCase(objSettingRead.GetValue(SessionID, CStr("Security"), CStr("Settings"), CStr("DssMaster"), "false")) = "true")
				objSettingRead = Nothing
			End If
			DOM = New XmlDocument()
			'-----------------------------------
			'debug
			'Response.write "<textarea id='txtDebugArea' width=100% rows=5 >" & strOrders_XML & "</textarea>" & vbcr
			'Response.end
			'----------------------------------
			'Return a flat list of all non-order set items in a node list.  This is
			'used for scripting the order form pages below.
            DOM.TryLoadXml(CStr(strOrders_XML))
			colLayouts = DOM.SelectNodes("root//item")
			'28Jan04 AE  Now includes ordersets, which are shown as info pages
			'Retrieve episode info (patient name, etc) if any has been set up.
            If CInt(Not CDbl(blnEmbeddedMode)) And CInt(Not CDbl(blnTemplateMode)) Then
                strEpisodeInfo = CStr(OrderEntry.GetEpisodeInfo(SessionID))
            End If
			'Prepare a list of table ids with wil be used find out if we have any shared columns
			If Not CDbl(blnTemplateMode) Then
				strTableIDList = ""
                For intCount = 0 To colLayouts.Count() - 1
                    strTableIDList = strTableIDList & DirectCast(colLayouts(intCount), XmlElement).GetAttribute("tableid") & ","
                Next
				If Len(strTableIDList) > 1 Then
					strTableIDList = Left(strTableIDList, Len(strTableIDList) - 1)
				End If
				objSharedDetailRead = New OCSRTL10.SharedDetailRead()
            
				If Not (strTableIDList) Is Nothing And (strTableIDList <> "null") Then
                    blnSharedColumnsExist = objSharedDetailRead.SharedColumnsExistForTableList(SessionID, strTableIDList)
				Else
					blnSharedColumnsExist = False
				End If
				objSharedDetailRead = Nothing
				If blnSharedColumnsExist Then
					'Create an order page for showing shared info
					DOM = OrderEntry.AddSharedPage(DirectCast(colLayouts(0), XmlElement)) ' PR 05-05-09 - F0052946 - not sure why it was erroring but an explicit conversion fixed it
					colLayouts = DOM.SelectNodes("root//item")
				End If
			End If
			If (colLayouts.Count() = 1) And CBool((Not CDbl(blnDisplayMode))) And CBool((Not CDbl(blnPreviewMode))) And CBool((Not CDbl(blnTemplateMode))) And CBool((Not CDbl(blnCancelMode))) Then
				'10Mar05 AE	 Info page for single items not currently used, as was replaced by showing the further details directly on the prescription form.
				'Left intact for use later if required.
				'Set DOM = AddInfoPage (SessionID, colLayouts(0))
				colLayouts = DOM.SelectNodes("root//item")
				'28Jan04 AE  Now includes ordersets, which are shown as info pages
			End If
			'-----------------------------------
			'debug
			'Response.write "<textarea width=100% rows=5 >" & DOM.xml & "</textarea>" & vbcr
			'Response.end
			'----------------------------------
			'Retrieve episode info (patient name, etc) if any has been set up.
            'F0051961 ST 08May09    Part of the increasing the ICW performance code changes
            'We seem to be calling this twice in the code so commented out the second version
            'If CInt(Not CDbl(blnEmbeddedMode)) And CInt(Not CDbl(blnTemplateMode)) Then
            'strEpisodeInfo = CStr(OrderEntry.GetEpisodeInfo(SessionID))
            'End If
        Case Else
            'No items to script at this time; just show a waiting page.
            If blnEmbeddedMode Then
                'We show a message if embedded, otherwise just a blank screen
                Response.Write("<div height=100% width=100% align=center>" & vbCr & "	<BR><div>No Episode selected</div>" & vbCr & "</div>" & vbCr)
            End If
    End Select
	If strAction = "locked" Then
		Response.Write(strLockMessage)
	End If
%>

<script language="javascript" type="text/javascript" id="publicInterface">

//=======================================================================================
//									ICW Public Interface methods
//=======================================================================================

function EVENT_Exit() {

//If we are in embedded mode, save the items being edited.
<%
    If blnEmbeddedMode Then 
        '26Oct2009 JMei F0066887 F0066888 give user a chioce for saving when navigating away from this page
        Response.Write("return SaveAsPendingItemWhenNavigateAway();")
    End IF
%>

	return true;
}
//=======================================================================================

function EVENT_EpisodeSelected(vid)
{
    // Check episode and entity rows exist in the DB with the expected versions as specified in the vid parameter
    ICW.clinical.episode.episodeSelected.init(<%= SessionID %>, vid, EntityEpisodeSyncSuccess, 'hap');

    // Called if/when Entity & Episode exist in the DB at the correct versions
    function EntityEpisodeSyncSuccess(vid)
    {
<%
    If blnEmbeddedMode Then 
        Response.Write("window.navigate(document.URL);")
    End IF
%>
    }
}

//DJH - TFS Bug 12880 - Add new Episode Cleared event.
	function EVENT_EpisodeCleared() {
<%
    If blnEmbeddedMode Then 
        Response.Write("window.navigate(document.URL);")
    End IF
%>
	}

//=======================================================================================
//										Non-ICW Methods
//=======================================================================================

function LoadOrderForms(strOCSItems_XML) {
	alert('this method is obsolete.  Use function OrderEntry() to call this application');
}

//=======================================================================================

function GoToDesktop(){

//Navigate to a specified desktop
var desktopID = <%= lngOnSaveDesktopID %>;
var desktopName = '<%= strOnSaveDesktopName %>';

//first we blank the page to ensure that
//there's no room for confusion if the navigate fails
	void BlankPage();

//Now navigate, if we have an ID
	if (Number(desktopID) > 0) {
	
		void ICWWindow().NavigateToApplication(desktopID, desktopName);
	}
}
//=======================================================================================

m_blnToolbarLoaded = false;

function SendOCSToolbarData()
{
	// Send long XML data to the Toolbar iframe
	var lngSessionID = Number(document.getElementById("oeBody").getAttribute("sid"));
	var ordersXML = "";	
	//  Check that ordersXML has been created - on slow browsers it may not yet be ready
	if (document.all['ordersXML'] != undefined) {
		ordersXML = document.getElementById("ordersXML").xml;
	}
	frames("fraOCSToolbar").SetXmlData(m_currentFormIndex, ordersXML, document.getElementById("statusnotefilterXML").xml );
}

//=======================================================================================

function ToolbarReady()
{
	if ( document.getElementById('fraOCSToolbar')!=null )
	{
		document.getElementById('fraOCSToolbar').style.display='';
	}
	if (!m_blnToolbarLoaded)
	{
		m_blnToolbarLoaded = true;
		IndicateOrderFormReady(-1);
	}
	var fraToolbar = document.body.all['fraOCSToolbar'];
	if (fraToolbar != undefined)																	//28Jul05 AE Prevent errors if frame not scripted
	{
		var ToolbarHeight = window.frames("fraOCSToolbar").document.body.scrollHeight - 4;
		fraToolbar.height = ToolbarHeight;
	}
}

//=======================================================================================
function Reload(loadMessage){
//Refresh the page.  Used to recalculate doses if the parameters are changed.
	window.navigate(QuerystringReplace(document.URL, 'message', loadMessage));
}

//=======================================================================================
function orderentry_onresize()
{
	var fraToolbar = document.body.all['fraOCSToolbar'];
	if (fraToolbar != undefined)																	//28Jul05 AE Prevent errors if frame not scripted
	{
		var ToolbarHeight = window.frames("fraOCSToolbar").document.body.scrollHeight - 4;
		fraToolbar.height = ToolbarHeight;
	}
}
//=======================================================================================
</script>

<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/OrderEntry.css" />
</head>

<body id="oeBody" 
        style="overflow:hidden;"
		oncontextmenu="return false;" 
		scroll="no" leftmargin="5px" 
		sid="<%= SessionID %>" 
		entityid=<%= lngEntityID %>
		embedded="<%= LCase(CStr(blnEmbeddedMode)) %>" 
		responding="<%= LCase(CStr(blnRespondMode)) %>" 
		display="<%= LCase(CStr(blnDisplayMode)) %>" 
		defaultview="<%= LCase(strDefaultView) %>" 
		currentview="<%= LCase(strDefaultView) %>" 
		showloadingtime="<%= LCase(CStr(SHOW_LOADING_TIME)) %>"
		starttime="<%= Request.QueryString("StartTime") %>"
		mastermode="<%= LCase(CStr(blnMasterMode)) %>"
		pendingmode="<%= blnPendingMode %>"
		dispensarymode="<%= LCase(CStr(DispensaryMode)) %>"
		copymode="<%=Lcase(cStr(blnCopyMode))%>"		               
		amendmode="<%=Lcase(cStr(blnAmendMode))%>"		               
		commitwhenamending="<%=strCommitWhenAmending%>"
		onkeydown="if (window.event.keyCode == 27) CloseWindow(true);"
		lockobject="<%= strLockObject %>"
		onresize="orderentry_onresize();"
		ignorepending="<%=IgnorePendingIfIncomplete %>"
<%
    If strAction <> "" Then 
%>

		onunload="window_unload()"
<%
    End IF
%>

		loadingmessage="<%= Request.QueryString("message") %>"
      sharedcolumnsexist='
		<% 
    If blnSharedColumnsExist Then     
        Response.Write("1")    
		    Else    
		        Response.Write("0")        
		    End IF
    Response.Write("' onload='orderentry_onload();'>")
		%>
		
		

<%
    '<button onclick="Popmessage(document.frames['orderForm0'].document.body.outerHTML)">HTML</button>
%>


<!-- Form used when recieving data from external method calls -->
<form id="frmParameters" method="post" action="ICW_OrderEntry.aspx?Action=load&amp;SessionID=<%= SessionID %>&amp;Modal=<%= Request.QueryString("Modal") %>&amp;DispensaryMode=<%= Request.QueryString("DispensaryMode") %>" target="_self">
	<input type="hidden" id="orderEntryXML" name="orderEntryXML" value="<%= Generic.XMLEscape(Request.Form("orderEntryXML")) %>" />
</form>

<!-- Control used to store data for saving -->
<input type="hidden" id="dataXML" name="dataXML" />

<%
    '-------------------------------------------------------------------------------------------------------------------------------------------------
    'Finish here if we're just waiting for something to happen.
    If LCase(strAction) <> "load" Then 
        Response.End()
    End IF
    '-------------------------------------------------------------------------------------------------------------------------------------------------
    'Start of Order Entry Page HTML
    '-------------------------------------------------------------------------------------------------------------------------------------------------
%>


<!-- Title bar and container controls --><!-- these start blank, and are filled in by the client script -->
<table id="tblBody" width="100%" height="100%" border="0" cellspacing="0" cellpadding="0">

	<tr>
		<td colspan="2">
			<table border="0" cellpadding="0" cellspacing="0" width="100%" height="100%">
				<tr id="OCSToolbar2" class="Toolbar">

<%
    Dim ColSpan As Integer = 1
    'Script a toolbar with buttons as appropriate   
    If CInt((Not CDbl(blnDisplayMode))) And CInt((Not CDbl(blnPreviewMode))) And CInt((Not CDbl(blnTemplateMode))) And CInt((Not CDbl(blnCancelMode))) Then 
%>



					<td>
					    <%		    If LeavePendingOption Then%>
						<button class="ToolButton" accesskey="p" style="width:120px" id="cmdPending" onclick="EditPending()" disabled>
								  <img id="imgPending" src="../../images/ocs/classPending.gif" style="width:16px;height:16px;filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);" WIDTH="16" HEIGHT="16" />
								  <span id="cmdPendingCaption">
									  Leave <u>P</u>ending
								  </span>
						</button>
						<%        End If%>
					</td>

<%
		    ColSpan += 1
    End IF
		If CInt((Not CDbl(blnPreviewMode))) And CInt((Not CDbl(blnTemplateMode))) And CInt((Not CDbl(blnCancelMode))) Then 
	
		    ' Check to see if any order the items in order entry prescriptions
		    blnRxExists = ( DOM.SelectNodes(  "root//item[@isrx='1']").Count() > 0 )
%>							
					<td>
						<button id="cmdNotes" class="ToolButton" onclick="ShowNotes()" accesskey="t" style="width:70px" disabled>	
									<img id="imgAttachedNote" src="../../images/ocs/classAttachedNote.gif" style="width:16px;height:16px;filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);"  WIDTH="16" HEIGHT="16" />
									No<u>t</u>es
						</button>
					</td>
					
					<td>
						<button id="cmdView" class="ToolButton" onclick="ChooseView()" accesskey="v" style="width:70px" disabled title="Click here to change the order view, either paged or stacked">	
									<img id="imgView" src="../../images/ocs/changeView.gif" style="width:16px;height:16px;filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);"  WIDTH="16" HEIGHT="16" />
									<u>V</u>iews
									<img id="imgDropView" src="../../images/ocs/ButtonDropArrow.gif" style="width:9px;height:16px;filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);"WIDTH="9" HEIGHT="16" />

						</button>
					</td>
<%
		    if blnRxExists then 
%>
					<td>
						<button id="cmdAdjustDoses" class="ToolButton" onclick="AdjustDoses(-1)" accesskey="a" style="width:100px" disabled>	
									<img id="imgAdjustDoses" src="../../images/Developer/adjust.gif" style="width:16px;height:16px;filter:progid:DXImageTransform.Microsoft.BasicImage(grayscale=1);"  WIDTH="16" HEIGHT="16" />
									<u>A</u>djust Doses
						</button>
					</td>
<%
            ColSpan += 1
        End If
		    ColSpan += 2
    End IF
%>
	                <td style="width:100%">
					</td>
<%
    'Finally we script the previous/next buttons if the index pane is displayed
    '(ie, if there is more than one item in the batch)
    If colLayouts.Count() > 1 Then 
        Response.Write("<td>" & "<button id=""cmdPrevious"" " & "class=""ToolButton"" " & "accesskey=""b"" " & "onclick=""MoveFormPrevious(false);""  onblur=""SetFocusToForm();"" " & "disabled" & "><img id=""imgCmdPrevious"" src=""../../images/ocs/ArrowBack.gif"" />" & "<u>B</u>ack</button>" & "</td>" & vbCr)
        Response.Write("<td>" & "<button id=""cmdNext"" " & "class=""ToolButton"" " & "accesskey=""n""  " & "onclick=""MoveFormNext(false);""  onblur=""SetFocusToForm();""  " & "disabled" & "><u>N</u>ext" & "<img id=""imgCmdNext"" src=""../../images/ocs/ArrowForwards.gif"" />" & "</td>" & vbCr)
%>
				</tr>
<%
        ColSpan += 2
    End If
%>
				<tr id="OCSToolbar" class="Toolbar">
	                <td style="width:100%; height:100%" colspan="<%=ColSpan %>">
<%
    '14Dec07 ST iframe src is now set to nothing and is now set when this page has finished loading via javascript in orderentry.js 'LM Code 162 17/01/2008 Added Comment 
    If CInt(blnDisplayMode) Or CInt(blnPendingMode) Then 
        '29Jul05 AE  Don't bother scripting toolbar in other modes, since they'll be inactive anyway.  Saves 0.4 + s loading time
%>
					
						<iframe id="fraOCSToolbar"
							width="100%" 
							height="100%" 
							application="yes" 
							frameborder="0"
							scrolling="no"
							src="" 
							style="display:none"
						>
						</iframe>  <!-- LM 17/01/2008 Code 162 set src to blank string-->
<%
    Else
%>
	<script>	    ToolbarReady();</script>
<%
    End IF
%>
					</td>						
				</tr>
			</table>
		</td>
	</tr>

	<tr class="pageHeader">
<%
    'Script episode info, if we have any
    If strEpisodeInfo <> "" Then 
        Response.Write("<td colspan=""2"" id=""tdInfo"">" & strEpisodeInfo & "</td>" & vbCr)
    End IF
%>


	</tr>


	<tr id="rowHeader" class="PageHeader">
		<td id="tdHeaderL">
			<span id="spnLoadingTitle"></span>
<%
    'Here we script a title for each form in the batch.
    For intCount = 0 To colLayouts.Count() - 1
        strClass = "ItemTitle"
        xmlElement = colLayouts(intCount)
        If OrderEntry.ItemIsOrderset(xmlElement) Then
            strClass = strClass & " Info"
        End If
		
        '* DPA 23.11.2007 Insert as part of merging process...
        If blnCancelMode Or blnAmendMode Then
            Response.Write("<span class=""" & strClass & """ id=spnItemTitle style=""display:none""></span>" & vbCr)
            'F0044158
            'ST 23Jan08 commented out at styling was being lost on amended/cancelled items
            'Response.Write("<span id=spnItemTitle style=""display:none""></span>" & vbcr)
        Else
            Response.Write("<span class=""" & strClass & """ id=spnItemTitle style=""display:none"">" _
                           & xmlElement.GetAttribute("description").ToString.Replace("&amp;#47;", "/") _
                           & "</span>	" & vbCr)
        End If

    Next
%>
		
			
		</td>
<%
    If colLayouts.Count() > 1 Then 
        Response.Write("<td align=""right"" id=""tdHeaderR"">" & "<span id=""spnCurrentItem"" class=""ItemCurrent""></span>" & "</td>" & vbCr)
    End IF
%>

	</tr>


	<tr style="height:100%;overflow:hidden;">
		<td colspan="2">
<!-- *************************** This is the start of the main table containing the index pane and the order forms ********************************** -->
<!-- F0047573 ST 09Mar09 -->
<!-- Added extra attribute to style to prevent multiple vertical scroll bars when viewing back ordersets that have a cancelled item in them -->
<!-- F0082251 ST 31Mar10 Changed overflow attribute to auto so that vertical scroll bar appears -->
<div class="OrderEntryFormsContainer" style="height:100%;overflow:auto;">
<table border="0" cellpadding="0" cellspacing="0" width="100%" class="FormsContainer" id="tblMain" style="visibility:visible;height:100%;">
	<tr>
		<td>
<%
    'If in display mode, we script the status information pane here.
    'This is filed in when opened from the client, since the
    'status information is held in the order form page.
    If blnDisplayMode Then 
        Response.Write("<table cellpadding=0 cellspacing=0>" & vbCr & "<tr><td class=StatusBar style=""font-size:x-small"" width=100% id=statusInfoBar>" & vbCr & "</td><td Width=30px>" & vbCr & "<button id=cmdShowStatus name=cmdShowStatus class=StatusBar " & "onClick=""ToggleStatus();"" title=""Click here to show the status details"">S<u>h</u>ow</button></td>" & vbCr & "</td></tr></table>" & vbCr & "<table id=statusContainer class=StatusTable width=100% border=0>" & vbCr & "</table>" & vbCr)
    End IF
%>

		</td>
	</tr>
	<tr>

		<td height="100%">
			<table border="0" cellpadding="0" cellspacing="0" style="height:100%;" class="FormsContainerTopCell">
				<tr>
<%
	'Here we script an index entry for each form in the batch.
	'If only one form is included, we don't display the index pane at all.
    
	If colLayouts.Count() > 1 Then
	    'Several items - script the index pane
	    Response.Write("<td Class=IndexPaneCell id=indexContainer>	" & vbCr & "<table ID=tblControl border=0 cellpadding=0 cellspacing=0 width=""100%"">" & vbCr & "<tr><td id=indexControlBar Class=ToolBar width=""98%"">Index</td>" & vbCr & "<td><input type=button value=""X"" class=ToolButton ID=indexButton onClick=""ToggleIndex();"" " & "title=""Click here to hide the index panel""></td>" & vbCr & "</tr></table>" & vbCr & "<table ID=tblIndex border=0 height=100% width=100% Class=ShortcutTable cellpadding=1 cellspacing=0>" & vbCr)
	    'Each index item:
	    For intCount = 0 To colLayouts.Count() - 1
	        'Use the product name as the index text (if a product name has been supplied), and the long description
	        'on the actual page.  The tooltip (title) always holds the full description
	        xmlElement = colLayouts(intCount)
	        If XmlExtensions.AttributeExists(xmlElement.GetAttribute("productname")) Then
	            strDescription = CStr(xmlElement.GetAttribute("productname"))
	            strTitle = CStr(xmlElement.GetAttribute("description"))
	        Else
	            strDescription = CStr(xmlElement.GetAttribute("description"))
	            strTitle = strDescription
	        End If
            
	        strDescription = Server.HtmlDecode(strDescription) '.ToString.Replace("&amp;#47;", "/"))
	        strTitle = Server.HtmlDecode(strTitle) '.ToString.Replace("&amp;#47;", "/"))

	        strDataclass = xmlElement.GetAttribute("dataclass")
	        strClass = "IndexItem"
            
	        'JA 29-10-07
	        xmlElement = colLayouts(intCount)
	        If OrderEntry.ItemIsOrderset(xmlElement) Then
	            strClass = strClass & " Info"
	        End If
	        'Indent the description of items in ordersets
	        If CStr(DirectCast(xmlElement.ParentNode, XmlElement).Name) = "item" Then
	            strDescription = "  " & strDescription
	        End If
	        If Len(strDescription) > DESCRIPTION_LENGTH_MAX Then
	            strDescription = Left(strDescription, DESCRIPTION_LENGTH_MAX) & "..."
	        End If
	        strDescription = Replace(strDescription, " ", "&nbsp;")
	        strOnClick = "onClick=""NavigateToFormDelayed(" & intCount & ");"" "
            
	        'This is a single item            
	        Response.Write("<tr title=""" & strTitle & """>" & "<td Class=""" & strClass & """ " & "id=orderIndexRow disabled " & strOnClick & ">" & strDescription & "</td></tr>" & vbCr)
	    Next
	    'Add a padding cell to prevent the others stretching to fill the table
	    Response.Write("<tr><td id=indexPaddingCell height=""100%""  valign=""top"" >&nbsp;</td></tr>" & vbCr)
	    Response.Write("</table>" & vbCr & "</td>")
    End If
%>


					<td class="OrderFormCell">	

								<div id="scrollWindow" style="height:100%;overflow:hidden">
								<!-- This span is used to catch the focus as it comes backwards off of the form.									  It MUST be positioned immediately before the script which creates the order									  form -->	  
								<span id="focusCatchPrev" tabindex="0" hidefocus onfocus=FocusOffForm("back")></span>
<%
    'Here we script the actual order form pages.  Each is scripted inside a DIV element
    'with an ID of OrderFrame.  The divs are shown/hidden in order to cycle through the
    'various order forms.
    'Each order form is loaded into an iframe element.
    Dim bOCStypeIsRequest As Boolean 'JA 29-10-2007  added variable for OCS Type check below
    For intCount = 0 To colLayouts.Count() - 1
        'If this is an orderset, we'll show the orderset title page
        'JA 29-10-07 replace ALL instances of colLayouts(intCount) below to instead reference this variable
        xmlElement = colLayouts(intCount)
        blnIsOrderset = OrderEntry.ItemIsOrderset(xmlElement)
        blnIsInfoPage = False
        blnIsSharedPage = False
        If XmlExtensions.AttributeExists(xmlElement.GetAttribute("dataclass")) Then
            blnIsInfoPage = (CStr(xmlElement.GetAttribute("dataclass")) = "info")
        End If
        If XmlExtensions.AttributeExists(xmlElement.GetAttribute("dataclass")) Then
            blnIsSharedPage = (CStr(xmlElement.GetAttribute("dataclass")) = "shared")
        End If

        '16Nov06 AE  Fix broken preview mode
        'Script the DIV container; this holds the template marker if this form is to hold a template,
        'and the orderset marker if it is an orderset
        Response.Write("<div id=orderFormDiv class=OrderFormContainer hidefocus ")
        xmlElement = colLayouts(intCount)
        If XmlExtensions.AttributeExists(xmlElement.GetAttribute("template")) Then
            If CInt(xmlElement.GetAttribute("template")) = 1 Then
                Response.Write("template=""1"" ")
            End If
        End If
        If CBool(blnIsOrderset) Or blnIsInfoPage Then
            Response.Write(" infopage=""1"" ")
        End If
        If blnIsSharedPage Then
            Response.Write(" sharedpage=""1"" ")
        End If
        Response.Write(">" & vbCr)
        'If Not (blnIsOrderset And (colLayouts(intCount).GetAttribute("hasdetail") <> "1")) Then
        Response.Write("<table style=""height:100%; width:100%"">" & vbCr)
        'Add the title of each form here; this is not displayed unless in stacked mode.
        Response.Write("<tr id=""rowItemTitle"" style=""display:none""><td>" & "<span class=""ItemTitle"">" & xmlElement.GetAttribute("description") & "</span>" & "</td></tr>" & vbCr)
        'Add the schedule info bar, if this item can be scheduled.
        bOCStypeIsRequest = False
        If XmlExtensions.AttributeExists(xmlElement.GetAttribute("ocstype")) Then
            bOCStypeIsRequest = (CStr(xmlElement.GetAttribute("ocstype")) = "request")
        End If
        If blnTemplateMode And Not blnDisplayMode And Not blnIsOrderset And bOCStypeIsRequest Then
            If XmlExtensions.AttributeExists(xmlElement.GetAttribute("isrx")) Then
                isRx = xmlElement.GetAttribute("isrx")
            End If
            If XmlExtensions.AttributeExists(xmlElement.GetAttribute("isSms")) Then
                isSms = xmlElement.GetAttribute("isSms")
            End If


            
            '29May09    Rams    F0040670 - Enable Scheduler for Order Comms 
            '16Jul09    Rams    F0040670 - Revert back Scheduler as more things are to be Speced!
            If (String.IsNullOrEmpty(isRx) Or (CStr(isRx) = "0")) And (String.IsNullOrEmpty(isSms) Or (CStr(isSms) = "0")) Then
                Response.Write("<tr><td>")
                Response.Write("<table id=""" & SCHEDULEID_PREFIX & intCount & """ " & "class=""ScheduleInfoBar"" " & "><tr><td>" & vbCr)
                Response.Write("<td align=""center"" style=""padding-bottom:6px;"" valign=""middle"" > " & "<img id=""imgSchedule"" " & "src=""../../images/developer/calendar.gif"" " & "style=""width:16px;height:16px;cursor:hand;"" " & "onclick=""BrowseStartTime(this)"" " & "title=""Click here to specify a start date"" " & "/></td>" & vbCr)
                Response.Write("<td style=""width:60px"">Start on:</td>" & "<td style=""width:85px"">" & "<input " & "type=""text"" " & "class=""StandardField"" " & "id=""txtRequestDate"" " & "validchars=""DATE:dd/mm/yyyy"" " & "maxlength=""11"" " & "onKeyPress=""MaskInput(this)"" onPaste=""MaskInput(this)"" " & "onChange=""CreateOneOffSchedule(" & intCount & ")"" " & "style=""width:90px;"" " & "/>" & "</td>" & vbCr)
                Response.Write("<td style=""width:20px"">at:</td>" & "<td style=""width:65px"">" & "<input " & "type=""text"" " & "class=""StandardField"" " & "id=""txtRequestTime"" " & "validchars=""TIME:"" " & "maxlength=""5"" " & "onKeyPress=""MaskInput(this)"" onPaste=""MaskInput(this)"" " & "onChange=""CreateOneOffSchedule(" & intCount & ")"" " & "style=""width:60px;visibility:hidden;"" " & "/>" & "</td>")
                Response.Write("<td id=""scheduleSimple"" style=""width:200px;color:arse"">" & "(leave blank for immediate)" & "</td>" & vbCr)
                'Response.Write("<td " & "id=""scheduleCaption"" " & "class=""scheduleText"" " & "align=""center"" " & "onclick=""EditSchedule(this)"" " & "onmouseover=""ScheduleText_MouseOver()"" " & "onmouseout=""ScheduleText_MouseOut()"" " & ">&nbsp;</td>" & vbCr)
                '08/01/2010 JMei F0073059 temporarily remove hyperlink here as requested, new spec expected
                Response.Write("<td " & "id=""scheduleCaption"" style=""width:400px;"" " & ">&nbsp;</td>" & vbCr)
                
                Response.Write("</td></tr></table>" & vbCr)
            End If
        End If
        Response.Write("</td></tr>" & "<tr><td style=""height:100%"">" & "<div>" & vbCr)
        'Get any extra styling information for the form; this is used to indicate if
        'a response already exists, etc
        strStyle = OrderEntry.GetFormStyle(xmlElement)
        'Create a uniqueID for this frame
        strFrameID = FORMID_PREFIX & intCount
        '19Jul07 PH Prescription form is now displayed directly, instead of being sub-hosted in OrderForm.aspx
        If XmlExtensions.AttributeExists(xmlElement.GetAttribute("isrx")) Then 'JA 29-10-2007  modified logic to take care when isrx is not found
            If CInt(xmlElement.GetAttribute("isrx")) = 1 Then
                strPage = "CustomControls/Prescription.aspx"
            Else
                strPage = "OrderForm.aspx"
            End If
        Else
            strPage = "OrderForm.aspx"
        End If
        If CBool((Not CDbl(blnIsOrderset))) And (Not blnIsInfoPage) And (Not blnIsSharedPage) Then
            'Build the URL
            strURL = "TableID=" & xmlElement.GetAttribute("tableid") & "&ProductID=" & xmlElement.GetAttribute("productid") & "&DataClass=" & xmlElement.GetAttribute("dataclass") & "&DataTypeID=" & xmlElement.GetAttribute("ocstypeid") & "&DataRow=" & xmlElement.GetAttribute("id") & "&Display=" & blnDisplayMode & "&Template=" & blnTemplateMode & "&SessionID=" & SessionID & "&InReplyToTableID=" & xmlElement.GetAttribute("inreplytotableid") & "&InReplyToID=" & xmlElement.GetAttribute("inreplytoid") & "&Style=" & strStyle & "&FrameID=" & strFrameID & "&Ordinal=" & intCount & "&OrderTemplateID=" & xmlElement.GetAttribute("ordertemplateid") & "&OnSelectWarningLogID=" & xmlElement.GetAttribute("onselectwarninglogid")
						 
            If blnCopyMode Then
                strURL = strURL & "&CopyMode=True"
            End If
						 
            If blnAmendMode Then
                strURL = strURL & "&AmendMode=True"
            End If
            
            'Script the frame to hold the order form
            'PH 20Jul07 Turned off load-on-demand feature
            'if not blnDisplayMode or intCount = 0 then
            strTempURL = strPage & "?" & strURL
            'else
            'strTempURL = ""
            'end if
            Response.Write("<iframe id=" & strFrameID & " srcdelay=""" & strPage & "?" & strURL & """ src=""" & strTempURL & """ frameborder=""0"" scrolling=""auto"" height=""100%"" width=""100%"" application=""yes"">" & "</iframe>" & vbCr)
        End If
        If CBool(blnIsOrderset) Or blnIsInfoPage Then
            'Build an orderset / Info page holder.  We need to pass the OrderTemplateID to the info page
            'For new items, the dataclass is "template", and the OrderTemplateID is the ID field
            'For Pending Items, the dataclass is "pending", the OrderTemplateID is held in the field "ordertemplateid"
            'For committed items (view / copy) the dataclass will be the same as the ocstype.  The OrderTemplateID is not
            'included in the xml here (as it is generated from the worklist), so it is read on the info page.
            Select Case xmlElement.GetAttribute("dataclass")
                Case "pending"
                    'Existing pending items
                    lngTemplateID = Generic.CIntX(DirectCast(colLayouts(intCount), XmlElement).GetAttribute("ordertemplateid"))
                    lngID = CInt(DirectCast(colLayouts(intCount), XmlElement).GetAttribute("id"))
                Case "orderset"
                    'New items from templates
                    lngTemplateID = Generic.CIntX(xmlElement.GetAttribute("id"))
                    lngID = 0
                Case "request"
                    'Viewing/copying a committed item.  In this case, the ordertemplateID is read on
                    'in OrderEntry.vb and added to the xml
                    lngTemplateID = Generic.CIntX(xmlElement.GetAttribute("ordertemplateid"))
                    lngID = CInt(xmlElement.GetAttribute("id"))
                Case "info"
                    'Info page - not currently used (was replaced with template further info on prescription form,
                    'but left the hooks in for later)
            End Select
            
            '* DPA 23.11.2007 Insert as part of merging process...
            ' 24Oct07 ST
            ' if we are amending and selected items from an orderset then the orderset is readonly
            'JA 22-01-2008 Added the IsDBNull checks - Error code 104 
            ' If blnIsOrderset And ( XmlExtensions.AttributeExists(xmlElement.GetAttribute("dataclass")) AndAlso xmlElement.GetAttribute("dataclass") = "request") And (XmlExtensions.AttributeExists(xmlElement.GetAttribute("ReadOnly")) AndAlso xmlElement.GetAttribute("ReadOnly") = "1") Then
			
            ' 09Oct08 PH Orderset should be read-only if you're editing an item in an orderset, but should be editable if you're editing the full orderset.
            '            When a full orderset if amended then the first instruction item is the orderset, when an item *in* an orderset is amended, the first instruction item is the item, not the orderset
            If blnAmendMode And blnIsOrderset And Not blnFirstInstructionIsOrderSet Then
                strURL = "OrderTemplateID=" & CStr(lngTemplateID) _
                         & "&DataRow=" & CStr(lngID) _
                         & "&DataClass=" & xmlElement.GetAttribute("dataclass") _
                         & "&OCSType=" & xmlElement.GetAttribute("ocstype") _
                         & "&Display=True" _
                         & "&SessionID=" & SessionID
            Else
                strURL = "OrderTemplateID=" & CStr(lngTemplateID) _
                         & "&DataRow=" & CStr(lngID) _
                         & "&DataClass=" & xmlElement.GetAttribute("dataclass") _
                         & "&OCSType=" & xmlElement.GetAttribute("ocstype") _
                         & "&Display=" & blnDisplayMode _
                         & "&SessionID=" & SessionID
            End If
            
            Response.Write("<iframe id=" & strFrameID & " src=""InfoForm.aspx?" & strURL & """ frameborder=""0"" scrolling=""auto"" height=""100%"" width=""100%"" application=""yes"">" & "</iframe>" & vbCr)
        End If
        If blnIsSharedPage Then
            'Script the iframe for the Shared columns page
            Response.Write("<iframe id=" & strFrameID & " src='SharedForm.aspx?SessionID=" & SessionID & "&TableIDList=" & strTableIDList & "&EpisodeID=" & EpisodeID & "' frameborder=""0"" scrolling=""auto"" height=""100%"" width=""100%"" application=""yes"">" & "</iframe>" & vbCr)
        End If
        'Close the table
        Response.Write("</div></td></tr></table>" & vbCr)
        'Store the name of this form in the XML
        xmlElement.SetAttribute("formindex", (intCount))
        'End if
        'close the div
        Response.Write("</div>")
    Next
%>

								<!-- This span is used to catch the focus as it comes forwards off of the form.									  It MUST be positioned immediately after the script which creates the order									  form -->	  
								<span id="focusCatchNext" tabindex="0" hidefocus onfocus=FocusOffForm("next")> </span>
								</div>
								</td>
							</tr>
						</table>		
							
					</td>
				</tr>
			</table>
	</div>
		</td>
	</tr>

	<tr>
		<td colspan="2">
			
			<table width="100%" border="0" class="ButtonTable">
				<tr>
					<td align="right">

						<table border="0" cellpadding="0" cellspacing="2" class="ButtonTable">
							<tr>
<%
    'If in Preview Mode or display mode, we show just a close button.
    'Otherwise, OK and cancel buttons are available.
    If CInt((Not CDbl(blnDisplayMode))) And CInt((Not CDbl(blnPreviewMode))) Then
        strOKText = "<u>O</u>K"
        If blnEmbeddedMode Then
            strOKFunction = "SaveAsPendingItemCheck();"
        Else
            If Not CDbl(blnRespondMode) Then
                If Not CDbl(blnCancelMode) Then
                    If Not CDbl(blnTemplateMode) Then
                        'Saving edited or new pending items - this is the case when called from
                        'the PendingItems.aspx application
                        strOKFunction = "SaveAsPendingItemCheck();"
                    Else
                        'Editing/Creating Templates.
                        strOKFunction = "SaveAsTemplate();"
                        '24Oct06 AE  Skip locking code for template editing
                    End If
                Else
                    'Saving cancellations
                    strOKFunction = "SaveAsCancellationCheck();"
                End If
            Else
                'Saving Responses to committed items - this is the case when called
                'from the WorkList.aspx application
                strOKFunction = "SaveAsResponseCheck();"
            End If
        End If
    Else
        'We are in display mode; OK just closes the window, and nothing is saved.
        strOKFunction = "CloseWindow(false);"
        strOKText = "Cl<u>o</u>se"
    End If
    Response.Write("<td><button id=cmdOK accesskey=""o"" class=stdButton onclick=""" & strOKFunction & """ disabled>" & strOKText & "</button></td>" & vbCr)
    If CInt((Not CDbl(blnDisplayMode))) And CInt((Not CDbl(blnPreviewMode))) Then
        Response.Write("<td><button id=cmdCancel accesskey=""c"" class=""stdButton"" ")
        '26Jan05 AE  Disable buttons until initialised
        If blnEmbeddedMode Then
            Response.Write("onclick=""GoToDesktop();"" ")
        Else
            Response.Write("onclick=""CloseWindow(true);"" ")
        End If
        Response.Write("><u>C</u>ancel</td>" & vbCr)
    End If
%>

							</tr>
						</table>

					</td>
				</tr>
			</table>
		</td>
	</tr>
</table>

<%
    ScriptStatusPanel()
%>


<!-- XML Island for holding the Orders XML.  This is used to maintain the hierarchy of the items being edited.  -->
<xml id="ordersXML"><%
	'DOM.save(Response) JA 22-10-07 Code 5
	Response.Write(DOM.OuterXml)
%>
</xml>

<!-- XML Island for general parsing -->
<xml id="generalXML"></xml>

<!-- XML Island for StatusNoteFilterXML. This list of notetypes is used to include/exclude the statusnote toolbar buttons than can be displayed-->
<xml id="statusnotefilterXML"><%= OrderEntry.ExtractStatusNoteFilterXML(strInstruction_XML) %></xml>

<!-- Invisible frame which holds the page which saves data -->
<iframe id="fraSave" application="yes" style="display:none; height:500px; width:100%" src="OrderEntrySaver.aspx"></iframe>

<!-- Frame to save user settings -->
<iframe id="fraSetting" src="../SettingsEditor/SettingsSave.aspx?SessionID=<%= SessionID %>" style="display:none; height:500px; width:100%" application="yes" ></iframe>

</body>

</html>
