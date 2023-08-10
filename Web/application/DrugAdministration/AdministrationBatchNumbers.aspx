<%@ Page language="vb" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
	'----------------------------------------------------------------------------------------------------------------
	'
	'AdministrationBatchNumbers.aspx
	'
	'Batch Number Entry page.
	'
	'Useage:
	'Call with the following QS Parameters:
	'Referer:			Page which called this one
	'Dest:				Page which we will navigate to when the OK button is pressed
	'
	'Modification History:
	'31Jul05    AE      Written
	'19May2010  Rams    F0078434 - Do not Create AdminRequest for PRN's when Override Administration
	'15Sep11    XN      TFS 13955 Batch number and EnterExpiryDates does not work if exipry date is missing
	'
	'----------------------------------------------------------------------------------------------------------------
	'URL we go to when they pick an item
	'URL we go to if they cancel

	Dim sessionId As Integer
	Dim entityId As Integer
	Dim episodeId As Integer
	Dim windowHeight As Integer
	Dim windowWidth As Integer
	Dim destinationUrl As String
	Dim cancelUrl As String
	Dim requestId As Integer
	Dim batchNumber As String
	Dim batchExpiryDate As String
	Dim dom As XmlDocument
	Dim xmlRoot As XmlNode
	Dim xmlElement As XmlNode
	Dim xmlAttr As XmlAttribute
    Dim strOnLoad As String = String.Empty
	Dim intHeight As Integer
	Dim sEnterExpiryDatesMode As String
	Dim requestBatchNumberRead As OCSRTL10.RequestBatchNumberRead
	Dim requestBatchNumber As OCSRTL10.RequestBatchNumber
	Dim batchCount As Integer
	Dim overrideAdmin As Byte
	Dim strBatchNumberXml As String = ""
    
	'Read querystring.  This will specify the ArbTextType we are to show,
	'and the URL we are to return to
	sessionId = CIntX(Request.QueryString("SessionID"))

	' Make sure episode id is selected
	episodeId = CIntX(StateGet(sessionId, "Episode"))
	If episodeId = 0 Then
		Response.Redirect("AdministrationEpisodeList.aspx?SessionID=" + sessionId.ToString())
		Return
	End If
    
	destinationUrl = Request.QueryString(DA_DESTINATION_URL)
	cancelUrl = Request.QueryString(DA_REFERING_URL)
	'Read useful variables from state
	windowHeight = CIntX(SessionAttribute(sessionId, CStr(DA_HEIGHT)))
	windowWidth = CIntX(SessionAttribute(sessionId, CStr(DA_WIDTH)))
	requestId = CIntX(SessionAttribute(sessionId, CStr(DA_REQUESTID)))
	entityId = CIntX(StateGet(sessionId, "Entity"))
	overrideAdmin = IIf(Generic.SessionAttribute(sessionId, "OverrideAdmin") = True, 1, 0)
    
	' Create read\writer objects to handle batch numbers in the database
	requestBatchNumberRead = New OCSRTL10.RequestBatchNumberRead
	requestBatchNumber = New OCSRTL10.RequestBatchNumber
    
	'We may have a new batch number to store or remove.
	'Note that the key for the selected product xml where we store batch numbers is formed
	'from a fixed token (DA_BATCHNUMBER_XML) and the ID of the admin request.
	batchNumber = Request.QueryString(DA_BATCHNUMBER_XML)
	batchExpiryDate = Request.QueryString(DA_BATCHEXPIRYDATE_XML)
    
	'// F0021972    
	If Not batchExpiryDate Is Nothing AndAlso batchExpiryDate.Length > 0 Then
		batchExpiryDate = batchExpiryDate.Replace("Expires: ", "")
	End If
	'//
    
	strBatchNumberXml = requestBatchNumberRead.BatchNumbersByRequestIDXML(sessionId, requestId)
	dom = New XmlDocument()
	If strBatchNumberXml = "" Then
		'First time, create the xml document
		dom.AppendChild(dom.CreateElement("root"))
	Else
		dom.TryLoadXml(strBatchNumberXml)
	End If
    
	xmlRoot = dom.SelectSingleNode("root")
	If batchNumber <> "" Then
		Select Case LCase(Request.QueryString("Mode"))
			Case "add"
				'Add a new batch number
				xmlElement = xmlRoot.AppendChild(dom.CreateElement(CStr(NODE_PRODUCT)))
				xmlAttr = dom.CreateAttribute(CStr(ATTR_BATCHNUMBER))
				xmlAttr.Value = batchNumber
				xmlElement.Attributes.Append(xmlAttr)
                
				xmlAttr = dom.CreateAttribute(CStr(ATTR_BATCHEXPIRYDATE))
				xmlAttr.Value = batchExpiryDate
				xmlElement.Attributes.Append(xmlAttr)
                
				requestBatchNumber.InsertBatchNumber(sessionId, requestId, xmlElement.OuterXml)
			Case "edit"
				' 15Sep11 XN - TFS 13955 Batch number and EnterExpiryDates does not work if exipry date is missing
				'modify date on a batch number
				Dim batchOldExpiryDate As String = Request.QueryString(DA_BATCHEXPIRYDATE_XML & "Old")
				If batchOldExpiryDate <> String.Empty Then
					batchOldExpiryDate = batchOldExpiryDate.Substring(9)
				End If
				' 28May08 CD - Changed to remove the "Expires :" from the beginning of BatchOldExpiryDate when building the xPath
				Dim sXPath As String = "root/" & NODE_PRODUCT & "[@" + ATTR_BATCHNUMBER + "=""" + batchNumber + """ and @" + ATTR_BATCHEXPIRYDATE + "=""" + batchOldExpiryDate + """]"
				xmlElement = dom.SelectSingleNode(sXPath)
				If xmlElement IsNot Nothing Then
					xmlElement.Attributes(CStr(ATTR_BATCHEXPIRYDATE)).Value = batchExpiryDate
					requestBatchNumber.UpdateBatchNumber(sessionId, requestId, xmlElement.OuterXml)
				End If
			Case "remove"
				'Remove the specified batch number
				Dim sXPath As String = "root/" & NODE_PRODUCT & "[@" + ATTR_BATCHNUMBER + "=""" + batchNumber + """ and @" + ATTR_BATCHEXPIRYDATE + "=""" + batchExpiryDate + """]"
				xmlElement = dom.SelectSingleNode(sXPath)
				If xmlElement IsNot Nothing Then
					xmlElement.ParentNode.RemoveChild(xmlElement)
					requestBatchNumber.DeleteBatchNumbers(sessionId, xmlElement.OuterXml)
				End If
		End Select
        
		'Save the updated document
		strBatchNumberXml = CStr(dom.OuterXml)
	End If

	'Work out the height we have to play with
    intHeight = windowHeight - 4 * TouchscreenShared.BUTTON_STANDARD_HEIGHT - (6 * BUTTON_SPACING) - 80
    
    'If we've no batch numbers entered, show the keyboard automatically
    batchCount = xmlRoot.ChildNodes.Count
    If batchCount = 0 Then
        strOnLoad = "DisplayBatchNumberKeypad('add');"
    End If
    
    ' Get if batch expiry dates are present
    sEnterExpiryDatesMode = SettingGet(sessionId, "OCS", "DrugAdministration", "EnterExpiryDates", BATCH_EXPDATEENTRY_OFF).ToLower()
%>



<html>
<head>
<title>Batch Number Entry</title>
<script type="text/javascript" language="javascript" src='scripts/DrugAdministrationConstants.js'></script>
<script type="text/javascript" language="javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
<script type="text/javascript" language="javascript">

    var KB_BATCH = "KeyboardBatch";
    var KB_EXPIRYDATE = "KeyboardExpiry";

    var m_strCurrentKeyboard;
    var m_strCurrentMode;
    var m_strCurrentBatchNumber;
    var m_strCurrentExpiryDate;

    //------------------------------------------------------------------------------------------------------------------
    function Confirm()
    {
    	var strUrl = '<%= destinationUrl %>'
        + '?SessionID=<%= sessionId %>&dssresult=<%= Request.QueryString("dssresult") %>&OverrideAdmin=<%=overrideAdmin%>'
        + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';
    	void TouchNavigate(strUrl);
    }

    //------------------------------------------------------------------------------------------------------------------
    function Confirmed(strReturn)
    {
    	if (strReturn == "yes")
    	{
    		m_strCurrentMode = "add";
    		m_strCurrentKeyboard = KB_EXPIRYDATE;     // Note keyboard in uses for ScreenKeyboard_EnterText function

    		var strPrompt = 'Enter expiry date for batch<br>' + m_strCurrentBatchNumber;
    		document.frames['fraKeyboard'].ShowDateTimePad(strPrompt);
    	}
    	else
    		AddBatchNumber(m_strCurrentBatchNumber, '');
    }

    //------------------------------------------------------------------------------------------------------------------
    function SelectedAction(strAction)
    {
    	//Fires when the select action dialog has completed
    	switch (strAction)
    	{
    		case "delete":
    			// Requested to delete the batch number    
    			RemoveBatchNumber(m_strCurrentBatchNumber, m_strCurrentExpiryDate);
    			break;

    		case "enterdate":
    			// Requested to edit the batch number
    			DisplayBatchExpiryDateKeypad("edit");
    			break;

    		case "goback":
    			// do nothing
    			break;
    	}
    }

    //------------------------------------------------------------------------------------------------------------------
    function Cancel()
    {
    	var strUrl = '<%= cancelUrl %>'
			  + '?SessionID=<%= sessionId %>&OverrideAdmin=<%=overrideAdmin%>&dssresult=<%= Request.QueryString("dssresult") %>'
              + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>';

    	void TouchNavigate(strUrl);
    }

    //------------------------------------------------------------------------------------------------------------------
    function EnterBatchNumber(first)
    {
    	DisplayBatchNumberKeypad("add");
    }

    //------------------------------------------------------------------------------------------------------------------
    function EditRemove(objSrc)
    {
    	// Called when a batch number is clicked

    	// Get details off the batch number that was clicked
    	m_strCurrentBatchNumber = objSrc.all['tdBatchNumber'].innerText;
    	if ((objSrc.all['tdBatchExpiryDate'] != null) && (objSrc.all['tdBatchExpiryDate'].innerText != "No Expiry Entered"))
    		m_strCurrentExpiryDate = objSrc.all['tdBatchExpiryDate'].innerText;
    	else
    		m_strCurrentExpiryDate = '';

    	// In expirty date mode, show the select action dialog
    	// In non expirty date mode just remove the batch number
    	var sEnterExpiryDatesMode = document.getElementById("EnterExpiryDatesMode").value.toLowerCase();
    	if ((sEnterExpiryDatesMode == BATCH_EXPDATEENTRY_MANDATORY) || (sEnterExpiryDatesMode == BATCH_EXPDATEENTRY_OPTIONAL))
    		document.frames['fraSelectAction'].Show();
    	else
    		RemoveBatchNumber(m_strCurrentBatchNumber, m_strCurrentExpiryDate);
    }

    //------------------------------------------------------------------------------------------------------------------
    function ScreenKeyboard_EnterText(strText)
    {
    	//Fires when a batch number, or expiry date, is entered
    	if (strText == '')
    		return;

    	if (m_strCurrentKeyboard == KB_BATCH)
    	{
    		// User has just entered a batch number

    		m_strCurrentBatchNumber = strText;
    		m_strCurrentExpiryDate = '';

    		// Action to perform depends on expiry date mode
    		var sEnterExpiryDatesMode = document.getElementById("EnterExpiryDatesMode").value.toLowerCase();
    		switch (sEnterExpiryDatesMode)
    		{
    			case BATCH_EXPDATEENTRY_MANDATORY:
    				// Expiry date entry is MANDATORY - display expiry date keybaord
    				DisplayBatchExpiryDateKeypad("add");
    				break;

    			case BATCH_EXPDATEENTRY_OPTIONAL:
    				// Expiry date entry is OPTIONAL - ask user if they want to enter an expiry date
    				document.frames['fraConfirm'].Show("Enter an Expiry Date?", "yesno");
    				break;

    			default:
    				// Expiry date entry is OFF - add the batch number
    				AddBatchNumber(m_strCurrentBatchNumber, '');
    				break;
    		}
    	}
    	else if (m_strCurrentKeyboard == KB_EXPIRYDATE)
    	{
    		// User has just entered an expiry date so add\edit the batch number

    		// Add\edit the batch
    		if (m_strCurrentMode == "add")
    			AddBatchNumber(m_strCurrentBatchNumber, strText);
    		else
    			EditBatchNumber(m_strCurrentBatchNumber, m_strCurrentExpiryDate, strText);
    	}
    }

    //------------------------------------------------------------------------------------------------------------------
    function DisplayBatchNumberKeypad(sAddEditMode)
    {
    	// Display keypad so user can enter a batch number.
    	// Once the batch number has been entered ScreenKeyboard_EnterText is called 
    	m_strCurrentMode = sAddEditMode;
    	m_strCurrentKeyboard = KB_BATCH;

    	document.frames['fraKeyboard'].ShowKeyboard('Enter a Batch Number', 50);
    }

    //------------------------------------------------------------------------------------------------------------------
    function DisplayBatchExpiryDateKeypad(sAddEditMode)
    {
    	// Display date\time keypad so user can enter a expiry date.
    	// Once the expiry date has been entered ScreenKeyboard_EnterText is called 

    	m_strCurrentMode = sAddEditMode;
    	m_strCurrentKeyboard = KB_EXPIRYDATE;

    	document.frames['fraKeyboard'].ShowDateTimePad('Enter expiry date for batch<br>' + m_strCurrentBatchNumber);
    }

    //------------------------------------------------------------------------------------------------------------------
    function AddBatchNumber(strBatchNumber, strExpiryDate)
    {
    	var strUrl = document.URL;
    	strUrl = strUrl.substring(0, strUrl.indexOf('?'));
    	strUrl += '?SessionID=<%= sessionId %>'
		     + '&' + DA_DESTINATION_URL + '=<%= destinationUrl %>'
		     + '&' + DA_REFERING_URL + '=<%= cancelUrl %>'
		     + '&' + DA_BATCHNUMBER_XML + '=' + strBatchNumber
		     + '&' + DA_BATCHEXPIRYDATE_XML + '=' + strExpiryDate
             + '&dssresult=<%= Request.QueryString("dssresult") %>'
             + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
		     + '&Mode=add&OverrideAdmin=<%=overrideAdmin%>';

    	void TouchNavigate(strUrl);
    }

    //------------------------------------------------------------------------------------------------------------------
    function EditBatchNumber(strBatchNumber, strOldExpiryDate, strNewExpiryDate)
    {
    	var strUrl = document.URL;
    	strUrl = strUrl.substring(0, strUrl.indexOf('?'));
    	strUrl += '?SessionID=<%= sessionId %>'
		     + '&' + DA_DESTINATION_URL + '=<%= destinationUrl %>'
		     + '&' + DA_REFERING_URL + '=<%= cancelUrl %>'
		     + '&' + DA_BATCHNUMBER_XML + '=' + strBatchNumber
		     + '&' + DA_BATCHEXPIRYDATE_XML + 'Old=' + strOldExpiryDate
		     + '&' + DA_BATCHEXPIRYDATE_XML + '=' + strNewExpiryDate
		     + '&dssresult=<%= Request.QueryString("dssresult") %>'
             + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
		     + '&Mode=edit&OverrideAdmin=<%=overrideAdmin%>';

    	void TouchNavigate(strUrl);
    }

    //------------------------------------------------------------------------------------------------------------------
    function RemoveBatchNumber(strBatchNumber, strExpiryDate)
    {
    	var strUrl = 'AdministrationBatchNumbers.aspx'
				 + '?SessionID=<%= sessionId %>'
				 + '&' + DA_DESTINATION_URL + '=<%= destinationUrl %>'
				 + '&' + DA_REFERING_URL + '=<%= cancelUrl %>'
	    		 + '&' + DA_BATCHNUMBER_XML + '=' + strBatchNumber
    		     + '&' + DA_BATCHEXPIRYDATE_XML + '=' + strExpiryDate
    		     + '&dssresult=<%= Request.QueryString("dssresult") %>'
                 + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
				 + '&Mode=remove&OverrideAdmin=<%=overrideAdmin%>';

    	void TouchNavigate(strUrl);
    }
</script>

<link rel='stylesheet' type='text/css' href='../../style/application.css' />
<link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
<link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>

<input type="hidden" id="EnterExpiryDatesMode" value="<%= sEnterExpiryDatesMode %>">

<!--'// F0021972 -->
<body class="Touchscreen" onload="document.body.style.cursor = 'default';<%= strOnLoad %>" >
<table width="100%" cellpadding="0" cellspacing="0">    
<%
    'Selected Patient details
    PatientBannerByID(sessionId, entityId, episodeId)
%>
<tr>
    <td colspan="2">
        <table style="height:100%;width:100%;" cellpadding="0" cellspacing="0">	
	        <tr>
            <%
                If (destinationUrl <> cancelUrl) Then 
            %>
                <td class="Toolbar" style="padding-left:<%= BUTTON_SPACING %>">
            <%
                    'Script the "back to list" button, if required
                    TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/DrugChart.gif", "Back", "Cancel()", true)
            %>
			    </td>		
            <%
                End IF
            %>
		        <td class="Toolbar" style="padding-right:<%= BUTTON_SPACING %>" style="text-align: center;">
            <%
                ScriptBanner_AdminRequestCurrent(sessionId, false, entityId)
            %>
	            </td>
            </tr>
        </table>
	</td>
</tr>
</table>
<table style="width:100%;">
    <tr>
		<td class="Prompt">
		<%
	        DrugAdminEpisodeBannerByID(sessionId, episodeId)
        %>
		</td>
	</tr>
	<tr>
<% 
        if ( (sEnterExpiryDatesMode = BATCH_EXPDATEENTRY_OPTIONAL) Or (sEnterExpiryDatesMode = BATCH_EXPDATEENTRY_MANDATORY) ) then
%>	
    		<td class="Prompt">Enter the Batch Number(s), then press [Confirm].  You may remove a Batch Number,<br />or Add\Edit an Expiry Date to a Batch Number, by pressing it.</td>
<% 
        else
%>	
    		<td class="Prompt">Enter the Batch Number(s), then press [Confirm].  You may remove a Batch Number which has been entered by pressing it.</td>
<% 
        end if
%>	
	</tr>
	
	<tr>
<%
    If batchCount = 0 Then 
%>
			<td class="Prompt" style="height:<%= intHeight %>px;">
				No Batch Numbers Entered	
			</td>
<%
    Else
%>
			<td style="height:<%= intHeight %>px;">
<%
        ScriptButtonPage(sessionId, TYPE_BATCHNUMBER, strBatchNumberXml, intHeight, windowWidth)
%>
			</td>
<%
    End IF
%>

	</tr>
	<tr>
		<td align="center">
			<table>
				<tr>
					<td align="left">
<%
    TouchscreenShared.NavButton("../../images/touchscreen/Add.gif", "Add a Batch Number", "EnterBatchNumber()", true)
%>
					</td>
					<td align="right">
<%
    TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Confirm", "Confirm()", true)
%>
					</td>			
				</tr>
			</table>
		</td>
	</tr>
</table>

<iframe id="fraKeyboard" frameborder="1" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/keyboard.htm"></iframe>
<iframe id="fraSelectAction" frameborder="1" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="AdministrationSelectAction.aspx"></iframe>
<iframe id="fraConfirm" style="display:none;background-color:transparent;position:absolute;top:0px;left:0px;width:100%;height:100%;z-index:9999" allowTransparency='true' application="yes" src="../sharedscripts/touchscreen/confirm.aspx"></iframe>
</body>
</html>
