<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>
<html>

<%
    'The return value of the window is either:
    ''cancelled' if the user presses the Cancel button;
    'OR:
    '<suspendinfo from_type="now|from"
    'from_date="dd/mm/yyyy"
    'to_type="manual|to|doses"
    'to_date="dd/mm/yyyy (only if to_type=to)"
    'to_doses="0.." (only if to_type=doses) />
    '
    '28Oct11    Rams    17561 - Can’t unsuspend a prescription that has been suspended from a date in the future
    '20May12    ST      24804 Tidy up of code along with various fixes etc as part of the changes for suspensions
    '10Oct12    YB      46662 Removed 'suspend Administration from’ option when a single dose is selected and removed “unsuspend after XXX doses “ for single doses as well
    '05Feb13    Rams    30951 - Patient Locking - No locking occurs when suspending the same prescription at the same time
%>

<head>
<title>Manage Suspensions</title>
<%

    Dim blnHasDependancies As Boolean
    Dim sessionId As Integer
    Dim requestXml As String
    Dim itemIds As String
    Dim objOrderCommsRead As OCSRTL10.OrderCommsItemRead
    Dim objTransport As TRNRTL10.Transport
    Dim xmlItem As XmlElement
    Dim xmlItems As XmlNodeList
    Dim xmldom As XmlDocument
    Dim requestId As Integer = 0
    Dim strImage As String
    Dim lngOffset As Object
    Dim strOffset As String
    Dim days As Integer
    Dim hours As Integer
    Dim mins As Integer
    Dim xmlNext As XmlElement
    Dim strReasonLookup As String
    Dim strReasonText As String
    Dim objSuspensionRead As OCSRTL10.SuspensionRead
    Dim xmlDomReasons As XmlDocument
    Dim xmlNodesReasons As XmlNodeList
    Dim strSuspensionReasonXml As String = String.Empty
    Dim suspensionXml As String = String.Empty
    Dim suspendOn As Date
    Dim unSuspendOn As Date
    Dim formattedSuspendOn As String = String.Empty
    Dim formattedUnSuspendOn As String = String.Empty
    Dim formattedSuspendOnTime As String = String.Empty
    Dim formattedUnSuspendOnTime As String = String.Empty
    
    Dim unSuspendAfterDose As Integer = -1
    Dim suspensionReasonId As Integer = -1
    Dim suspensionReason As String = String.Empty
    Dim remainSuspendedUntil As Boolean = False
    Dim remainUnSuspendedForDoses As Boolean = False
    Dim itemIsBeingSuspended As Boolean = True
    Dim itemIsWhenRequiredPrescription As Boolean = False
    Dim itemIsSingleDosePrescription As Boolean = False
    Dim IsRequestLocked As Boolean = False
    Dim elemLockDetails As XmlElement = Nothing
    
    'Validate the session
    'Obtain the session ID from the querystring
    sessionId = CInt(Request.QueryString("SessionID"))
    
    'Get the XML for the items to be suspended
    requestXml = CStr(Generic.SessionAttribute(sessionId, "OrderEntry/SuspensionXML"))
    
    ' F0073085 ST 27Apr10 Read passed through settings for suspension reasons
    strReasonLookup = Request.QueryString("ReasonLookup")
    strReasonText = Request.QueryString("ReasonText")
    
    'Decide whether we need to display a Dependent Items Warning
    'Load XML into a dom
    xmldom = New XmlDocument
    xmldom.TryLoadXml(requestXml)
    xmlItems = xmldom.documentElement.selectNodes("//item")
    'Create Parameter list of item ids
    itemIds = ""
    objTransport = New TRNRTL10.Transport()
    Dim orderSetXml As String
    Dim needToCheckDependancies As Boolean
    For Each xmlItem In xmlItems
        '27Oct11    Rams    Just grab the first id, i don't think we have option to update multiple items for the suspension, still don't want to disturb the current code, hence leaving it as such
        If requestId = 0 Then requestId = Generic.CIntX(xmlItem.getAttribute("id"))
        needToCheckDependancies = True
        orderSetXml = objTransport.ExecuteSelectRowSP(CInt(sessionId), "OrderSet", requestId)
        If orderSetXml <> String.Empty Then
            Dim orderSetDom = New XmlDocument()
            orderSetDom.TryLoadXml(orderSetXml)
            Dim optionsSet = orderSetDom.DocumentElement.GetAttribute("ContentsAreOptions")
            needToCheckDependancies = String.IsNullOrEmpty(optionsSet) Or optionsSet <> "1"
        End If
        If needToCheckDependancies Then
            itemIds = itemIds + objTransport.CreateInputParameterXML("Id", 2, 4, xmlItem.getAttribute("id"))            
        End If
    Next
    itemIds = "<root>" + itemIds + "</root>"
    objOrderCommsRead = New OCSRTL10.OrderCommsItemRead()
    If requestId > 0 Then
        ' check whether the request is locked by other terminal?, if not create a lock
        Dim oRequestLock As New OCSRTL10.RequestLock
        Dim LockDetails As String = oRequestLock.LockRequest(sessionId, requestId, False)
        
        If LockDetails = String.Empty Then
            ' No Lock exists already and the Lock is created succesfully
        Else
            IsRequestLocked = True
            'get the details of the lock
            Dim docLockDetails As New XmlDocument
            docLockDetails.TryLoadXml(LockDetails)
            elemLockDetails = docLockDetails.SelectSingleNode("*")
        End If
    End If
           
    'RequestXML = objTransport.ExecuteSelectRowsSP(SessionID, "pRequestDependenciesXML", ItemIds)
    objOrderCommsRead = New OCSRTL10.OrderCommsItemRead()
    requestXml = objOrderCommsRead.GetPrescriptionDependants(sessionId, itemIds)
    xmldom.TryLoadXml(requestXml)
    xmlItems = xmldom.documentElement.selectNodes("//dependancy")
    blnHasDependancies = False
    If xmlItems.Count > 0 Then
        blnHasDependancies = True
    End If
    
    'This should always return the recent active suspension note
    suspensionXml = objOrderCommsRead.GetSuspensionInfoByRequestID(sessionId, requestId)
    If suspensionXml.Trim() <> "" AndAlso suspensionXml.ToLower() <> "<root></root>" Then
        itemIsBeingSuspended = False
        
        xmldom.TryLoadXml(suspensionXml)
        
        'Get suspended Date
        If (Not xmldom Is Nothing AndAlso Not xmldom.selectSingleNode("//SuspensionInfo/@SuspendOn") Is Nothing) Then
            suspendOn = Convert.ToDateTime(xmldom.SelectSingleNode("//SuspensionInfo/@SuspendOn").Value)
            formattedSuspendOn = suspendOn.Year.ToString() + "/" + (suspendOn.Month).ToString() + "/" + suspendOn.Day.ToString()
            formattedSuspendOnTime = suspendOn.ToString("HH:mm")
        End If
        
        'Get Unsuspend Data
        If (Not xmldom Is Nothing AndAlso Not xmldom.selectSingleNode("//SuspensionInfo/@UnSuspendOn") Is Nothing) Then
            unSuspendOn = Convert.ToDateTime(xmldom.SelectSingleNode("//SuspensionInfo/@UnSuspendOn").Value)
            formattedUnSuspendOn = unSuspendOn.Year.ToString() + "/" + (unSuspendOn.Month).ToString() + "/" + unSuspendOn.Day.ToString()
            formattedUnSuspendOnTime = unSuspendOn.ToString("HH:mm")
        End If
        
        'Get Unsuspend After Dose
        If (Not xmldom Is Nothing AndAlso Not xmldom.SelectSingleNode("//SuspensionInfo/@UnSuspendAfterDoses") Is Nothing) Then unSuspendAfterDose = Generic.CIntX(xmldom.SelectSingleNode("//SuspensionInfo/@UnSuspendAfterDoses").Value)
        
        'Get Suspension Reason 
        If (Not xmldom Is Nothing AndAlso Not xmldom.SelectSingleNode("//SuspensionInfo/@SuspensionReasonID") Is Nothing) Then suspensionReasonId = Generic.CIntX(xmldom.SelectSingleNode("//SuspensionInfo/@SuspensionReasonID").Value)
        '
        'Get Suspension Reason Text
        If (Not xmldom Is Nothing AndAlso Not xmldom.SelectSingleNode("//SuspensionInfo/@SuspensionReason") Is Nothing) Then suspensionReason = xmldom.SelectSingleNode("//SuspensionInfo/@SuspensionReason").Value
        '
        If unSuspendAfterDose >= 0 Then
            If unSuspendAfterDose = 0 Then
                remainSuspendedUntil = True
            Else
                remainUnSuspendedForDoses = True
            End If
        End If
    Else
        xmldom = Nothing
    End If
    
    ' F0073085 ST 27Apr10 Read in suspension reasons if not disabled
    xmlDomReasons = New XmlDocument()
    If strReasonLookup.ToLower() <> "disabled" Then
        objSuspensionRead = New OCSRTL10.SuspensionRead()
        strSuspensionReasonXml = objSuspensionRead.GetSuspensionReasons(sessionId)

        If strSuspensionReasonXml <> "" Then
            xmlDomReasons.TryLoadXml("<root>" & strSuspensionReasonXml & "</root>")
        End If
    End If
    
    itemIsWhenRequiredPrescription = New OCSRTL10.PrescriptionRead().IsPrescriptionWhenRequired(sessionId, requestId)
    itemIsSingleDosePrescription = New OCSRTL10.PrescriptionRead().IsPrescriptionSingleDose(sessionId, requestId)
%>


<script type="text/javascript" language="javascript" src="../sharedscripts/jquery-1.3.2.js" ></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/ICWFunctions.js" ></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/DateLibs.js" ></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/Controls.js"></script>
<script type="text/javascript" language="javascript" src="../sharedscripts/icw.js"></script>
<script type="text/javascript" language="javascript" src="../OrderEntry/Scripts/SuspendPrescription.js"></script>
<script type="text/javascript">

if('<%=IsRequestLocked.ToString().ToLower()%>' == 'false')
{
    window.parent.requestId = '<%=requestId%>';
}
else
{
    window.parent.requestId =0;
}

function Refresh() {
    var strUrl = '../OrderEntry/SuspendPrescription.aspx?SessionID=<% =SessionID%>&ReasonLookup="<% =strReasonLookup%>"&ReasonText="<%=strReasonText%>" ';
    window.navigate(ICWURL(strUrl));
}
</script>

<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/suspendprescription.css"/>
</head>
<body id="spBody" 
        onload="void InitialisePage();" 
        oncontextmenu="return false;" 
        onkeydown="body_onKeydown()"
        class="TaskPicker"
        sid="<%= sessionId %>" 
        RemainSuspendedUntil= "<%=remainSuspendedUntil.ToString().ToLower()%>" 
        RemainUnSuspendedForDoses = "<%=remainUnSuspendedForDoses.ToString().ToLower() %>"
        UnSuspendAfterDose = "<%=unSuspendAfterDose %>" 
        FormattedUnSuspendOn = "<%=formattedUnSuspendOn %>"
        FormattedSuspendOn = "<%=formattedSuspendOn %>"
        FormattedUnSuspendOnTime = "<%=formattedUnSuspendOnTime %>"
        FormattedSuspendOnTime = "<%=formattedSuspendOnTime %>"
        IsWhenRequired = <%=itemIsWhenRequiredPrescription %> 
        IsSingleDose = <%=itemIsSingleDosePrescription %>
        IsRequestLocked = <% =IsRequestLocked.ToString().ToLower() %>
        >
    
<div id="patientBanner">
    <%
        Response.Write(SuspendPrescription.GetPatientDetailsForDisplay(sessionId))
    %>
</div>

<div>&nbsp;</div>

<div id="prescriptionDetail" <%If blnHasDependancies Then %> style="visibility: hidden" <% Else %> style="visibility: visible;" <% End If %>>
    <%
        Response.Write(SuspendPrescription.GetPrescriptionForDisplay(sessionId, requestId))
    %>
</div>


<%  If IsRequestLocked Then %>
<div style="width:100%;margin-top:10%">
    <table cellpadding="0" cellspacing="0" style='margin-left:30%;background-color:white'>	
        <tr>
            <td style='padding: 20px; font-weight:bolder; color:Red' align="center">
                <img src='../../images/User/lock closed.gif' alt='locked' />
                This Request is currently Locked by another User!
            </td>
        </tr>    
        <tr>
            <td style="padding-top: 5px;padding-left: 60px;font-weight:bold">
                <div>Locked By : <%=elemLockDetails.GetAttribute("UserFullName")%></div>
                <div>On Terminal : <%=elemLockDetails.GetAttribute("TerminalName")%></div>
                <div>Via Desktop : <%=elemLockDetails.GetAttribute("DesktopName")%></div>
                <div>At &nbsp;  <%=Generic.TDate2DateTime(elemLockDetails.GetAttribute("CreationDate"))%></div>
            </td>
        </tr>
        <tr>
            <td align="center" colspan="2" style="padding: 10px;">
                <button id='cmdOk' accesskey='o' onclick='window.close();'><u>O</u>K</button>
                <button id='cmdRefresh' accesskey='r' onclick='Refresh()'><u>R</u>efresh</button>
            </td>
        </tr>
    </table>
</div>
<%
    Response.End()
    End If
%>

<%
    If blnHasDependancies Then 
        'we have dependancies so script a table
%>

<table id="warnings" style="width:100%;padding-left:10px;padding-right:10px;" cellspacing="0" cellpadding="0">
	<tr>
		<td style="padding-left:10px;padding-right:10px;" colspan="3">
			<span class="LabelField"><br/>The following items have been found that are dependant on the items you are going to <% If itemIsBeingSuspended Then%>suspend:<%else %>unsuspend:<%End If%><br/><br/></span>
		</td>
	</tr>
	<tr>
		<td colspan="3">
			<div style="width:100%; background-color: white; padding: 5px; border-left: 1px solid black; border-top: 1px solid black; border-right: 1px solid black; font-weight: bold">
		        <span class="LabelField" style="width:210px; vertical-align:top">Prescription(s) to be <% If itemIsBeingSuspended Then%>Suspended<%Else%>Unsuspended<% End If%></span>
				<span class="LabelField" style="width:210px; vertical-align:top">Dependant Items(s)</span>
				<span class="LabelField" style="width:100px; vertical-align:top">Starting</span>
			</div>
			<div style="width:100%; height:130px; overflow:auto; background-color: white; border: 1px solid black">
<%
        requestId = 0
        For Each xmlItem In xmlItems
            xmlNext = xmlItem.nextSibling
            If (xmlNext Is Nothing) Then 
%>

				<div style="width:100%; padding: 5px; border-bottom:1px solid gray">
<%
            ElseIf (xmlItem.getAttribute("parentid") <> xmlNext.getAttribute("parentid")) Then 
%>

				<div style="width:100%; padding: 5px; border-bottom:1px solid silver">
<%
            Else
%>

				<div style="width:100%; padding: 5px">
<%
            End IF
            If CStr(requestId) <> xmlItem.getAttribute("parentid") Then 
                requestId = Generic.CIntX(xmlItem.getAttribute("parentid"))
                strImage = Ascribe.Common.Constants.IMAGE_DIR & Ascribe.Common.Constants.GetImageByClass("request", xmlItem.getAttribute("parentclass").ToString())
%>

	
					<span style="width:210px; vertical-align:top"><img src="<%= strImage %>" style="margin-right: 5px"/><%= xmlItem.getAttribute("parentdescription") %></span>
<%
            Else
%>

					<span style="width:210px; vertical-align:top"></span>
<%
            End IF
            strImage = Ascribe.Common.Constants.IMAGE_DIR & Ascribe.Common.Constants.GetImageByClass("request", xmlItem.getAttribute("dependantclass").ToString())
%>
				
					<span style="width:210px; vertical-align:top"><img src="<%= strImage %>" style="margin-right: 5px"/><%= xmlItem.getAttribute("dependantdescription") %></span>
<%
            'Get the offset in a nice way rather than just a number of minutes
            lngOffset = xmlItem.getAttribute("offsetminutes")
            If CInt(lngOffset) = 0 Then 
                strOffset = "Immediatly"
            Else
                days = CInt(CDbl(lngOffset) / (24 * 60))
                lngOffset = CDbl(lngOffset) Mod (24 * 60)
                hours = CInt(CDbl(lngOffset) / 60)
                mins = CDbl(lngOffset) Mod 60
                'format offset text - perhaps this should be in the client?
                strOffset = "In "
                If days > 0 Then 
                    strOffset = strOffset + CStr(days) + " Days "
                End IF
                If hours > 0 Then 
                    strOffset = strOffset + CStr(hours) + " Hours "
                Else
                    strOffset = strOffset + "0 Hours"
                End IF
                If mins > 0 Then 
                    strOffset = strOffset + CStr(mins) + " Minutes"
                End IF
                strOffset = Trim(strOffset)
            End IF
            xmlItem.setAttribute("offset", strOffset)
%>

					<span style="width:100px; vertical-align:top"><%= xmlItem.getAttribute("offset") %></span>
				</div>
<%
        Next
%>

			</div>
		</td>
	</tr>
	
	<tr>
		<td style="padding-left:10px;padding-right:10px;" colspan="3">
			<span class="LabelField"><br/>If you want to <% If itemIsBeingSuspended Then%>suspend<%Else%>unsuspend<%End If%> the item(s) anyway,Press OK.<br/>
			To exit without <% If itemIsBeingSuspended Then%>suspending<% Else %>unsuspending<% End If%> anything, Press Cancel.<br/></span>
		</td>
	</tr>
	<tr>
		<td align='right' colspan="3" style="padding-right:10px">
			
			<table id='tblWindowButtons' >
				<tr>
					<td><button tabindex='9' id='cmdOK' accesskey='o' onClick='void showSuspendInfo();'><u>O</u>K</button></td>
					<td><button tabindex='10' id='cmdCancel' accesskey='c' onClick='void CloseForm(false);'><u>C</u>ancel</button></td>
				</tr>
			</table>		
			
		</td>
	</tr>
</table>

<table id="suspendInfo" style="position: absolute; top: 65px; width:100%; visibility: hidden" cellspacing="0" cellpadding="0">

<%
    Else
%>

<table id="suspendInfo" style="width:100%;visibility:visible;" cellspacing="0" cellpadding="0">
<%
    End IF
%>
	<tr>
        <td><br/><br/></td>
	</tr>
	<tr>
		<td style="padding-left:10px;padding-right:10px;" width="50%"><span class="LabelField"><B>Action</B></span></td>
	</tr>
	<tr>
        <td><br/></td>
	</tr>
	<tr>
		<td style="padding-left:30px;padding-right:20px;">
		    <input type="radio" id="donotsuspend" name="suspend" checked="checked"  accesskey='n' onclick="donotSuspendClick()"/>Do <u>N</u>ot Suspend Administration	
		</td>
	</tr>
	<tr>
        <td><br/></td>
	</tr>
	<tr>
		<td style="padding-left:30px;padding-right:20px;">
		    <input type="radio" id="suspend_now" name="suspend"  accesskey='i' onclick="enableSuspendNow()"/>Suspend Administration <u>I</u>mmediately	
		</td>
	</tr>
	<tr>
        <td><br/></td>
	</tr>
	<tr>
		<td style="padding-left:30px;padding-right:20px;">
		    <input type="radio" id="suspend_from" name="suspend" 
		        <%= IF(itemIsSingleDosePrescription,"disabled","") %> 
		        accesskey="f" onclick="enableSuspendFrom()"/>Suspend Administration <u>F</u>rom	
			<input id="suspend_from_date" class="MandatoryField" type="text" style="margin-left: 5px" validchars="DATE:dd/mm/yyyy" onkeypress="MaskInput(this);" onpaste="MaskInput(this);" /><img id="suspend_from_date_button" src="../../images/ocs/show-calendar.gif" onclick="CalendarShow(this, suspend_from_date);" class="linkImage" />
			&nbsp;&nbsp;at&nbsp;&nbsp;
			<input id="suspend_from_time" class="StandardField" type="text" maxlength="5" size="5" validchars="TIME" onKeyPress="MaskInput(this)" onPaste="MaskInput(this)" />
		</td>
	</tr>
	<tr>
        <td><br/><br/></td>
	</tr>
	<tr>
		<td style="padding-left:10px;padding-right:10px;" class="LabelField"><span class="LabelField"><B>Remain Suspended</B></span>	
		</td>
	</tr>
	<tr>
        <td><br/></td>
	</tr>
	<tr>
		<td style="padding-left:30px;padding-right:20px;">
		    <input type="radio" id="unsuspend_manual" name="unsuspend" checked accesskey="m" onclick="enableUnsuspendManual()"/>Until <u>M</u>anually Unsuspended
		</td>
	</tr>
	<tr>
        <td><br/></td>
	</tr>
	<tr>
		<td style="padding-left:30px;padding-right:20px;">
		    <input type="radio" id="unsuspend_from" name="unsuspend" accesskey="u" onclick="enableUnsuspendFrom()"/><u>U</u>ntil the	
			<input id="unsuspend_from_date" class="MandatoryField" type="text" style="margin-left: 5px" validchars="DATE:dd/mm/yyyy" onkeypress="MaskInput(this);" onpaste="MaskInput(this);" />
			<img id="unsuspend_from_date_button" src="../../images/ocs/show-calendar.gif" onclick="CalendarShow(this, unsuspend_from_date);" class="linkImage" />
			&nbsp;&nbsp;at&nbsp;&nbsp;
			<input id="unsuspend_from_time" class="StandardField" type="text" maxlength="5" size="5" validchars="TIME" onKeyPress="MaskInput(this)" onPaste="MaskInput(this)" />
			<!--F0022794 LM 14/05/2008-->
		</td>
	</tr>
	<tr>
        <td><br/></td>
	</tr>
	<tr>
		<td style="padding-left:30px;padding-right:20px;" id="suspendDoses">
		    <input type="radio" id="unsuspend_by_dose" name="unsuspend" accesskey="f "
		    <%= IF(itemIsSingleDosePrescription,"disabled","") %> 
		    onclick="enableUnsuspendDoses()"/><u>F</u>or
			<input id="unsuspend_doses" class="MandatoryField" type="text" style="margin-left: 5px; width: 80px" validchars="INTEGER" onkeypress="MaskInput(this);" onpaste="MaskInput(this);" />
			<span id="unsuspend_doses_button" style="margin-left: 5px">Doses</span>	
		</td>
	</tr>
	<tr>
        <td><br/></td>
	</tr>
	<tr>
	    <%
		    If strReasonLookup.ToLower() <> "disabled" Or strReasonText.ToLower() <> "disabled" Then
		        ' F0073085 ST 27Apr10 Render out the suspension reason controls if we are not set as disabled.
        %>
            <td style="padding-left:10px;padding-right:10px;" valign="top">
                <table cellpadding="2" cellspacing="2" border="0">
                    <tr>
                        <td><span class="LabelField"><b>Reason for Suspension</b></span></td>
                    </tr>
                    <tr>
                        <td style="padding-left:30px;padding-right:20px;"><select id="selSuspensionReason" name="selSuspensionReason" mandatory="<%=iif(strReasonLookup.ToLower() = "mandatory","1","0")%>" class= "<%=iif(strReasonLookup.ToLower() = "mandatory","MandatoryField","StandardField")%>">
                        <%
                            If Not xmlDomReasons Is Nothing Then
                                xmlNodesReasons = xmlDomReasons.SelectNodes("*/sr")
                                For Each xmlNodeReason As XmlNode In xmlNodesReasons
                                    If xmlNodeReason.Attributes("SuspensionReasonID").Value = suspensionReasonId Then
                                        Response.Write("<option dbid='" & xmlNodeReason.Attributes("SuspensionReasonID").Value.ToString() & "' selected='true'>" & xmlNodeReason.Attributes("Description").Value.ToString() & "</option>")
                                    Else
                                        Response.Write("<option dbid='" & xmlNodeReason.Attributes("SuspensionReasonID").Value.ToString() & "'>" & xmlNodeReason.Attributes("Description").Value.ToString() & "</option>")
                                    End If
                                    
                                Next
                            Else
                                Response.Write("<option dbid=""-1""></option>")
                            End If
                        %>
                        </select></td>
                    </tr>
                    <tr>
                        <td style="padding-left:30px;padding-right:20px;">
                            <textarea id="txtSuspensionText" name="txtSuspensionText" validchars="ANY" onkeyup="MaskInput(this); limitText(this, 256);" cols="42" rows="8" mandatory="<%=iif(strReasonText.ToLower() = "mandatory","1","0")%>" class= "<%=iif(strReasonText.ToLower() = "mandatory","MandatoryField","StandardField")%>"><%=suspensionReason.Trim()%></textarea>
                        </td>
                    </tr>
                </table>
            </td>
		<%
		End If
	    %>
	    
	</tr>
	<tr>
		<td align='right' colspan="2" style="padding-right:10px;">
			
			<!-- OK and Cancel buttons -->
			<table id='tblWindowButtons' >
				<tr>
					<td><button tabindex='9' id='cmdOK' accesskey='o' onclick='void CloseForm(true);'><u>O</u>K</button></td>
					<td><button tabindex='10' id='cmdCancel' accesskey='c' onclick='void CloseForm(false);'><u>C</u>ancel</button></td>
				</tr>
			</table>		
			
		</td>
	</tr>
</table>

</body>
</html>
