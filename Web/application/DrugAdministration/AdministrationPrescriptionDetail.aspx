<%@ Page Language="VB" AutoEventWireup="false" CodeFile="AdministrationPrescriptionDetail.aspx.vb" Inherits="application_DrugAdministration_AdministrationPrescriptionDetail" %>

<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministration" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'AdministrationPrescriptionDetail.aspx
    '
    'Touchscreen Admin screen.  Shows full details of the prescription, including any
    'template detail.
    'Shows 3 buttons (Not administered, problem, and administered) if
    'Request.Querystring("Mode") = "select";
    'or just an OK button if Request.Querystring("Mode") = "view"
    '
    '
    'Modification History:
    '18Jun05    AE      Written
    '09Jan07    CD      Options order set stuff.
    '19Feb07    AE      Moved scroll button enabling stuff into TouchscreenShared.js:EnableButton()
    '20Mar07    AE      Various improvements for SC-07-0219; Corrected date prompts for fluid change.
    '29Mar11    Rams    F0113133 - Free text admin of when required doses - due text issue
    '26May2011  Rams    F0118622 - Duration based infusions dose/duration recording
    '22Aug11    XN      Controlled drugs text
    '15Sep11    XN      TFS 13974 Got all product to display Product, and dose info
    '27Jul12    Rams    39651/39557/39556 -  Cancelling prescriptions and overdue administration
    '23Jun15    CA      118923 - Removed the last dose given and last note sections from the page as per the "agreed solution"
	'05Aug15    CA      123501 - When doing the second check on the admin, use the prescription id instead of the request ID
    '                   for when the admin is an option in an order set.
    '12Aug15    CA      122417/126131 - Added the display of MedicationSuspended where the Medication Stopped message would display
    '----------------------------------------------------------------------------------------------------------------
    Const MODE_VIEW As String = "view"
    Const MODE_SELECT As String = "select"
    
    Dim requestTypeRead As OCSRTL10.RequestTypeRead
    Dim notesRead As OCSRTL10.NotesRead
    Dim entityRead As ENTRTL10.EntityRead
    Dim rowRead As ICWRTL10.RowRead
    Dim arbitraryTextRead As OCSRTL10.ArbitraryTextRead
    Dim orderCatalogueRead As OCSRTL10.OrderCatalogueRead
    Dim orderCommsItemRead As OCSRTL10.OrderCommsItemRead = New OCSRTL10.OrderCommsItemRead()
    
    Dim sessionId As Integer
    Dim windowHeight As Integer
    Dim windowWidth As Integer
    Dim entityId As Integer
    Dim requestId As Integer
    Dim destinationUrl As String = String.Empty
    Dim referingUrl As String = String.Empty
    Dim mode As String
    Dim strRequestType As String
    Dim dom As XmlDocument
    Dim xmlItem As XmlNode
    Dim domNotes As XmlDocument
    Dim dompom As XmlDocument
    Dim domRx As XmlDocument = Nothing
    Dim domIntervention As XmlDocument
    Dim cancellationXml As XmlDocument
    Dim domResponse As XmlDocument
    Dim domBatchnumbers As XmlDocument
    Dim xmlResponse As XmlNode
    Dim colProducts As XmlNodeList
    Dim xmlProduct As XmlNode
    Dim colNotes As XmlNodeList
    Dim colPom As XmlNodeList
    Dim interventionNode As XmlNodeList
    Dim xmlPom As XmlNode
    Dim colBatchnumbers As XmlNodeList
    Dim strUserName As String = String.Empty
    Dim strRequestXml As String = String.Empty
    Dim strResponseXml As String
    Dim strNotesXml As String
    Dim dose As Double
    Dim doseLow As Double
    Dim episodeId As Integer
    '03Feb2010 JMei F0074650 strNotes_XML stores prescription note, strAttachedNotes_XML stores note attached to last administration
    Dim colAttachedNote As XmlNode
    Dim domAdminNotes As XmlDocument
    Dim strAttachedNotesXml As String
    Dim domTreatmentReasons As XmlDocument
    Dim treatmentReasonNode As XmlNode = Nothing
    Dim treatmentReasonsXml As String = String.Empty
    Dim medicationStoppedMessage As String = String.Empty
    Dim strPomXml As String
    Dim interventionNotesXml As String = String.Empty
    Dim prescriptionId As Integer
    Dim productId As Integer
    Dim RouteID As Integer
    Dim strBuffer As String
    Dim strAdminAction As String
    Dim intContentHeight As Integer
    Dim intContentWidth As Integer
    Dim dtDue As Date
    Dim dtLast As Object = Nothing
    Dim blnOverdue As Boolean
    Dim blnPrn As Boolean
    Dim blnSecondChecked As Boolean
    Dim scheduleId As Integer
    Dim strBatchNumbersXml As String
    Dim blnHaveBatchNumber As Boolean
    Dim blnNoDoseInfo As Integer
    Dim strScheduleId As String
    Dim bIsOptions As Integer
    Dim xmlOptionsElement As XmlElement
    Dim bContinuous As Boolean
    Dim bInProgress As Boolean
    Dim bLongDurationBased As Boolean
    Dim blnFlowRateRecording As Boolean = False
    Dim strContinuous As String
    Dim requestTypeId As Integer
    Dim entityIdChecker As String
    Dim continuousInfusion As String
    Dim blnIsImmediateAdmin As Object
    Dim lngDueMinutes As Integer
    Dim lngEarlyMode As Integer        ' If 0 then user max minutes early, if 1 use from start of day.
    Dim lngMaxMinutesEarly As Integer
    Dim strSupervisedAdmin As String
    Dim blnNoAdministrationRecord As Boolean
    Dim dssCheckResult As String
    '09Feb10    Rams    F0063046 - Calculate Doses over 24 hours
    Dim mandatoryRecordDoses As Boolean = False
    Dim sRecordDoses As String = ""
    Dim sUnitDescription As String = ""
    Dim isVariableDose As Boolean = False
    '04Mar10    Rams    F0078153 - If a dose is recorded as "A Problem Occurred", the "Last Dose was given" field does not update
    Dim lastAdministeredBy As String = ""
    Dim flowRateDescription As String = ""
    Dim flowRateClass As String = ""
    Dim minRate As String = ""
    Dim maxRate As String = ""
    Dim startRate As String = ""
    Dim rateUnit As String = ""
    Dim isGenericTemplate As Boolean = False
    Dim IsOptionSelection As Boolean = False
    Dim cdCupboard As Boolean = False
    Dim secondCheckId as Integer
    
    Dim arbtextXml As XmlDocument
    
    Dim noteXml As XmlDocument
    Dim prnMaxMinutesEarly As Integer
    Dim blnPrnIsEarly As Boolean = False
    '15Sep11    Rams    TFS13883 - Gets an error when a free text prescription has got a when required frequency (initialize to zero)
    Dim prnDoseToExceedMaximumDoseRule As Double = 0
    
    Dim Prescription_Administered As String = String.Empty
    Dim RequestID_Parent As Integer
    
    Dim cancelReason As String = String.Empty
	Dim cancelText As String = String.Empty
	Dim SingleDoseIfRequired As Boolean

    Dim blnOverrideAdmin As Boolean
    Dim isResulted As Boolean = False
    Dim AdministeredBy As String = String.Empty
    Dim DateAdministered As Date 
    
    blnNoAdministrationRecord = False
    prescriptionId = 0
    productId = 0
    RouteID = 0
    blnNoDoseInfo = 0
    bIsOptions = 0
    'Read the appropriate state and qs variables
    sessionId = CIntX(Request.QueryString("SessionID"))
    dssCheckResult = Request.QueryString("dssresult")
    '15Sep11    Rams    TFS13883 - Gets an error when a free text prescription has got a when required frequency
    isGenericTemplate = Request.QueryString("IsGenericTemplate") = "1"
    Dim OptionSelected As String = Generic.RetrieveAndStore(sessionId, "OptionSelected")
    IsOptionSelection = Not String.IsNullOrEmpty(OptionSelected) AndAlso OptionSelected = "1"
    blnOverrideAdmin = Request.QueryString("OverrideAdmin") = 1 Or SessionAttribute(sessionId, "OverrideAdmin") = "True"
    
    ' Make sure episode id is selected
    episodeId = CIntX(StateGet(sessionId, "Episode"))
    If episodeId = 0 Then  
        Response.Redirect("AdministrationRequestList.aspx?SessionID=" + sessionId.ToString())
        Return
    End If

    If LCase(Request.QueryString("mode")) = MODE_SELECT AndAlso dssCheckResult = "fail_override" Then
        Dim dssLogResults As String = Request.QueryString("dsslogresults")      ' Will not be set if navigating back to this page from a cancel
        If Not String.IsNullOrEmpty(dssLogResults) Then                         ' warnings will have already been logged when this page was first shown after override, so ok to ignore
            Dim dssWarningLog As New OCSRTL10.DSSWarningLog()
            dssWarningLog.DSSWarningLogOverride(sessionId, dssLogResults)
        End If
    End If
	
    continuousInfusion = RetrieveAndStore(sessionId, "Continuous")
    '20Mar07 AE  Consolidate "Continuous" and "ContinuousInfusion" state variables into one
    blnIsImmediateAdmin = SessionAttribute(sessionId, CStr(IA_ADMIN))
    '02Feb07 CD detect immediate admin so we can return to that page and resize etc
    If CStr(blnIsImmediateAdmin) = "" Then
        blnIsImmediateAdmin = 0
    End If
    windowHeight = CIntX(SessionAttribute(sessionId, CStr(DA_HEIGHT)))
    windowWidth = CIntX(SessionAttribute(sessionId, CStr(DA_WIDTH)))
    entityId = CIntX(Request.QueryString(DA_ENTITYID))
    '16Feb07 AE  Allow entityID to be passed on querystring as well as in state
    If entityId = 0 Then
        entityId = CIntX(StateGet(sessionId, "Entity"))
    Else
        StateSet(sessionId, "Entity", entityId)
    End If
    
    mode = LCase(Request.QueryString("Mode"))
    If mode = "" Then
        mode = MODE_SELECT
    End If
    'Read / Store the selected Admin Request.  This is passed on the querystring initially,
    'and read from state thereafter
    requestId = Integer.Parse(RetrieveAndStore(sessionId, CStr(DA_REQUESTID)))

    'clear some state
    SessionAttributeSet(sessionId, "FCEndDate", "")
    SessionAttributeSet(sessionId, "FCStartDate", "")
    SessionAttributeSet(sessionId, "Action", "")

    If mode <> MODE_VIEW Then
        SessionAttributeSet(sessionId, "InfusionAction", "")
    End If

	SessionAttributeSet(sessionId, (DA_SELECTED_PRODUCT_XML & requestId.ToString()), "")
	SessionAttributeSet(sessionId, DA_ARBTEXTID, "")
	SessionAttributeSet(sessionId, DA_ARBTEXTID_EARLY, "")
	SessionAttributeSet(sessionId, DA_TOTAL_SELECTED, "")
	SessionAttributeSet(sessionId, DA_UNIT_SELECTED, "")
	SessionAttributeSet(sessionId, DA_TOTAL_SELECTED, "")
	SessionAttributeSet(sessionId, DA_UNITNAME, "")
	SessionAttributeSet(sessionId, DA_UNITID, "")
	SessionAttributeSet(sessionId, DA_FLOW_RATE, "")
	SessionAttributeSet(sessionId, DA_FLOW_RATE_UNITID, "")
	SessionAttributeSet(sessionId, DA_FLOW_RATE_UNIT, "")
	SessionAttributeSet(sessionId, DA_FLOW_RATE_UNITID_TIME, "")
	SessionAttributeSet(sessionId, DA_FLOW_RATE_UNIT_TIME, "")
	SessionAttributeSet(sessionId, DA_RATE_MIN, "")
	SessionAttributeSet(sessionId, DA_RATE_MAX, "")
	SessionAttributeSet(sessionId, DA_RATE_UNIT_DESCRIPTION, "")
	SessionAttributeSet(sessionId, DA_INFUSIONDURATION_HIGH, "")
	SessionAttributeSet(sessionId, DA_INFUSIONDURATION_LOW, "")
	SessionAttributeSet(sessionId, DA_DOSE, "")
	SessionAttributeSet(sessionId, DA_DOSETO, "")
    SessionAttributeSet(sessionId, "IsDoseLess", "")
    
    'We know where to go to and go back to according to URLs passed on the querystring
    Select Case mode
        Case MODE_VIEW
            destinationUrl = Request.QueryString(DA_DESTINATION_URL)
            referingUrl = Request.QueryString(DA_REFERING_URL)
        Case MODE_SELECT
            'Re-initialise some session variables to prevent carry-over.
            SessionAttributeSet(sessionId, CStr(DA_ADMINDATE), "")
            referingUrl = Request.QueryString(DA_REFERING_URL)
            If referingUrl = String.Empty Then referingUrl = SessionAttribute(sessionId, "OriginURL")
            If referingUrl = String.Empty Then referingUrl = "AdministrationRequestList.aspx"
    End Select
    
    ' Try to get lock on the requests
    Dim nodeLockDetails As XmlNode = Nothing
    Dim nodeRxLockDetails As XmlNode = Nothing
    Dim bLockFailed As Boolean = False 
    Dim bRxLockFailed As Boolean = False
    
    'Read the admin request
    'check if the Request Exists or else just turn back saying the Request is lost
    Try
        strRequestXml = AdminRequestByID(sessionId, requestId)
    Catch ex As Exception
        If (ex.Message.Equals("Cannot find RequestID")) Then
            '21Mar2013  Rams   57997 - if a nurse is in the middle of recording an administration and the doctor goes in to amend same drug, the prescriber gets an SQL 
            'this could only happen if the prescription is discontinued, resulting in deleting the Drug Admin, if any admin requests are processed.
            Response.Redirect("AdministrationRequestList.aspx?SessionID=" + sessionId.ToString() + "&NoAdminRequest=true")
        Else
            Throw ex
        End If
    End Try

    dom = New XmlDocument()
    dom.TryLoadXml(strRequestXml)
    xmlItem = dom.SelectSingleNode("root/*")
    
    If blnIsImmediateAdmin Then
        '29Jul2014  Rams    89178 - Administration of single dose prescriptions - Duplicate administration allowed in specific circumstances
        'Check if the admin request is resulted, only for Immediate admin.
        'If not immediate admin then this scenario is handled by the way of procedure filtering at the first screen and creating a lock,
        'In the case of immediate admin, the user can keep the prompt for long time, and by the time they do any thing the request may have been updated by other user (Ref:89178)
        If Not xmlItem.Attributes("Resulted") Is Nothing AndAlso xmlItem.Attributes("Resulted").Value = "1" Then 
            isResulted = True
            AdministeredBy = xmlItem.Attributes("AdministeredBy").Value
            DateAdministered = CType(xmlItem.Attributes("Date_Administered").Value, Date)
        End If
        '
    End If
    
    dtDue = TDate2DateTime(xmlItem.Attributes("Date_Due").Value)
    lngDueMinutes = CInt(xmlItem.Attributes("DueMinutes").Value)
    blnOverdue = (lngDueMinutes < 0)
    xmlItem = dom.SelectSingleNode("root/AdminRequest")
    strRequestType = xmlItem.Attributes("RequestType").Value
    strSupervisedAdmin = xmlItem.Attributes("SupervisedAdmin").Value.ToString()
    
    
    '22Aug11 XN Controlled drugs
	cdCupboard = xmlItem.Attributes("CDCupboard") IsNot Nothing AndAlso xmlItem.Attributes("CDCupboard").Value = "1"
    
    'And get our time window setting (this specifies the earliest we can give a dose)
    lngEarlyMode = CInt(SettingGet(sessionId, "OCS", "DrugAdministration", "EarlyMode", 0))
    If lngEarlyMode = 0 Then lngMaxMinutesEarly = CInt(SettingGet(sessionId, "OCS", "DrugAdministration", "MaxMinutesEarly", 60))
    prnMaxMinutesEarly = CInt(SettingGet(sessionId, "OCS", "DrugAdministration", "WhenRequiredMaxMinutesEarly", 0))
    
    'Now get the prescription

	If xmlItem.Attributes("RequestID_Prescription") IsNot Nothing AndAlso xmlItem.Attributes("RequestID_Prescription").Value.Length > 0 Then
		If IsOptionSelection Then
			prescriptionId = CIntX(Generic.RetrieveAndStore(sessionId, DA_PRESCRIPTIONID))
			RequestID_Parent = CIntX(xmlItem.Attributes("RequestID_Prescription").Value)
		Else
			prescriptionId = CIntX(xmlItem.Attributes("RequestID_Prescription").Value)
			RequestID_Parent = CIntX(xmlItem.Attributes("RequestID_Prescription").Value)
		End If
        
        
		' Task 32282 - Attempt to lock the prescription
		Dim bOverrideLock As Boolean = CBoolX(Request.QueryString("overridelock"))
		Dim sLockDetails As String
        Dim sRxLockDetails As String
		Dim objRequestLock As OCSRTL10.RequestLock = New OCSRTL10.RequestLock()
        Dim objPrescription As OCSRTL10.Prescription = New OCSRTL10.Prescription()
		Try
			'15Mar2013      Rams    TFS57997 - if a nurse is in the middle of recording an administration and the doctor goes in to amend same drug, the prescriber gets an SQL
			'
			'The logic for locking is changed as below from what was [create the admin lock and then create prescription lock]
			'1. First check the prescription is locked , if locked then straight away throw the error
			'2. If the prescription is not locked , then lock the admin request
			'3. By the way above, when you discontinue the prescription, it tries to delete the admin request, which would not error as per the issue TFS 57997 (as updated on 04/03/2013)
			'4. If the lock on Admin Request cannot be created, then release the lock from prescription as well, so that this user request does not end up in locking requests.
			'

            '08Dec2014      CD      TFS105776 - possible to record a double dose when prescription has been locked
            ' Slight change to above - when locking the prescription check if it is locked by someone doing an administration
            ' if it is then we can still try the dose.  If it's locked for any other reason then admin then we don't go to the dose

			sRxLockDetails = objPrescription.LockForAdministration(sessionId, prescriptionId, bOverrideLock)
            If String.IsNullOrEmpty(sRxLockDetails) And mode = MODE_SELECT Then
			    'check the lock for Admin Request now
        	    sLockDetails = objRequestLock.LockRequest(sessionId, requestId, bOverrideLock)
				'
		        If Not String.IsNullOrEmpty(sLockDetails) Then
				    'If admin Request is locked, clear the prescription lock created above, so that other users have access to prescription
				    objRequestLock.UnlockMyRequestLock(sessionId, prescriptionId)
			    End If
            End If
		Catch ex As Exception
			' The lock failed!!!!. Return to AdministrationRequestList passing back LockRequestFailed=true
			Response.Redirect("AdministrationRequestList.aspx?SessionID=" + sessionId.ToString() + "&LockRequestFailed=true")
			Return
		End Try
		'
        If (sRxLockDetails <> "") Then
            bRxLockFailed = True
            ' Set the admin request lock to failed as well in case anything relies on it
            bLockFailed = True
			Dim domLockDetails As XmlDocument = New XmlDocument()
			domLockDetails.TryLoadXml(sRxLockDetails)
			nodeRxLockDetails = domLockDetails.SelectSingleNode("*")
        End If

		If (sLockDetails <> "") Then
			' Lock failed
			bLockFailed = True

			' Get info on person who as locked the data
			Dim domLockDetails As XmlDocument = New XmlDocument()
			domLockDetails.TryLoadXml(sLockDetails)
			nodeLockDetails = domLockDetails.SelectSingleNode("*")
		End If

		SessionAttributeSet(sessionId, CStr(DA_PRESCRIPTIONID), prescriptionId.ToString())
		domRx = PrescriptionDetailByID(sessionId, prescriptionId, requestId)
                
        SessionAttributeSet(sessionId, DA_PRESCRIPTION_START_DATE, CStr(GetXMLValueNested(domRx, "root/data", "RequestDate")))

		Dim oOrderCommsItem As New OCSRTL10.OrderCommsItem
		Dim cancellationDetails As String = oOrderCommsItem.GetRequestCancellationDetails(sessionId, prescriptionId)
        Dim suspensionDetails As String = oOrderCommsItem.GetRequestSuspensionDetails(sessionId, prescriptionId)
        
		If Not String.IsNullOrEmpty(cancellationDetails) Then
			cancellationXml = New XmlDocument
			cancellationXml.TryLoadXml(cancellationDetails)
            
			Dim cancelNode As XmlNode = cancellationXml.SelectSingleNode("//E")
			Dim cancelledBy As String = cancelNode.Attributes("CancelledBy").Value
			Dim cancelledOn As String = cancelNode.Attributes("CancelledOn").Value
            
            medicationStoppedMessage = "MEDICATION STOPPED"
			medicationStoppedMessage = medicationStoppedMessage + IIf(String.IsNullOrEmpty(cancelledBy), String.Empty, " by " + cancelledBy).ToString()
			medicationStoppedMessage = medicationStoppedMessage + IIf(String.IsNullOrEmpty(cancelledOn), String.Empty, " on " + Date2ddmmccyyhhnn(cancelledOn)).ToString()
            
			If dtDue < cancelledOn Then
				cancelReason = cancelNode.Attributes("CancellationReason").Value
				cancelText = cancelNode.Attributes("CancellationText").Value
			End If

        ' CA 12/08/2015 (TFS: 122417/126131)
        '    - Added the display of MedicationSuspended where the Medication Stopped message would display
        Else If Not String.IsNullOrEmpty(suspensionDetails) Then
            Dim suspensionXml = New XmlDocument
			suspensionXml.TryLoadXml(suspensionDetails)
            
            Dim suspendNode As XmlNode = suspensionXml.SelectSingleNode("//SuspensionInfo")

            ' If it has been unsuspended then we don't want to display the message
            If suspendNode.Attributes("UnsuspendedOn") Is Nothing Then
                Dim suspendedBy As String = suspendNode.Attributes("SuspendedBy").Value
                Dim suspendOn As String = suspendNode.Attributes("SuspendOn").Value
                Dim unsuspendOn As String = suspendNode.Attributes("SuspendUntil").Value
            
                medicationStoppedMessage = "MEDICATION SUSPENDED"
                medicationStoppedMessage = medicationStoppedMessage + IIf(String.IsNullOrEmpty(suspendedBy), String.Empty, " by " + suspendedBy).ToString()
                medicationStoppedMessage = medicationStoppedMessage + IIf(String.IsNullOrEmpty(suspendOn), String.Empty, " on " + Date2ddmmccyyhhnn(suspendOn)).ToString()
                If Not String.IsNullOrEmpty(unsuspendOn) And IsDate(unsuspendOn) Then
                    unsuspendOn = Date2ddmmccyyhhnn(unsuspendOn).ToString()
                End If
                medicationStoppedMessage = medicationStoppedMessage + IIf(String.IsNullOrEmpty(unsuspendOn), String.Empty, " until " + unsuspendOn).ToString()
            
                cancelReason = suspendNode.Attributes("SuspensionReason").Value 
                If Not suspendNode.Attributes("SuspensionText") Is Nothing Then
                    cancelText = suspendNode.Attributes("SuspensionText").Value 
                End If
            End If
		End If
		oOrderCommsItem = Nothing
	End If
    
    'We know where to go to and go back to according to URLs passed on the querystring
    Select Case mode
        Case MODE_VIEW
            destinationUrl = Request.QueryString(DA_DESTINATION_URL)
            referingUrl = Request.QueryString(DA_REFERING_URL)
        Case MODE_SELECT
            'Re-initialise some session variables to prevent carry-over.
            Generic.SessionAttributeSet(sessionId, CStr(DA_ADMINDATE), "")
            If IsOptionSelection Then
                referingUrl = "AdministrationOptionsSelection.aspx?SessionID=" & sessionId.ToString() & "&PrescriptionID=" & GetXMLValueNested(domRx, "root/data", "RequestID_Parent") & "&AdminRequestID=" & requestId.ToString() & IIf(blnOverrideAdmin, "&OverrideAdmin=1", "")
            Else
                referingUrl = Request.QueryString(DA_REFERING_URL)
            End If
            
            If referingUrl = String.Empty Then
                referingUrl = Generic.SessionAttribute(sessionId, "OriginURL")
            End If
            
            If referingUrl = String.Empty Then
                referingUrl = "AdministrationRequestList.aspx"
            End If
    End Select

    If IsOptionSelection Then
        Dim rxType As String = GetXMLExpandedValue(domRx, "RequestTypeID")
        Select Case rxType
            Case "Standard Prescription"
                strRequestType = "Drug Administration"
            Case "Infusion Prescription"
                strRequestType = "Infusion Administration"
            Case "Doseless Prescription"
                strRequestType = "Doseless Administration"
            Case "Generic Prescription"
                strRequestType = "Generic Prescription Administration"
        End Select
    End If
    
    'If it's PRN and not scheduled, we don't worry about the due time
	blnPrn = (CStr(GetXMLValueNested(domRx, "root/data", "PRN")) = "1")
	SingleDoseIfRequired = blnPrn AndAlso ((isGenericTemplate AndAlso GetXMLValue(domRx, "Description").Contains("Single Dose")) OrElse GetXMLValue(domRx, "Description_Frequency") = "Single Dose, if required")
    strScheduleId = GetXMLValueNested(domRx, "root/data", "ScheduleID_Administration")
    If Len(strScheduleId) Then
        scheduleId = CIntX(strScheduleId)
    End If
    If (scheduleId = 0) And blnPrn Then
        blnOverdue = False
    End If

    Dim flowRateValue As String
    If xmlItem.Attributes("Infusion_InProgress").Value = "1" Then
        flowRateValue = xmlItem.Attributes("Infusion_FlowRate").Value
        
        '03Feb14 SPinnington Bug 105346 If flow rate not populated yet, use the start rate
        If flowRateValue <> Nothing And CDbl(flowRateValue) = 0 And SessionAttribute(sessionId, DA_RATE_START) <> Nothing Then
            flowRateValue = SessionAttribute(sessionId, DA_RATE_START)
        End If

        If flowRateValue <> Nothing And CDbl(flowRateValue) > 0 Then
            Dim flowRateUnitDescription As String = UnitDescription(sessionId, CIntX(xmlItem.Attributes("Infusion_FlowRate_UnitID").Value), True)
            Dim flowRateTimeUnitDescription As String = UnitDescription(sessionId, CIntX(xmlItem.Attributes("Infusion_FlowRate_TimeUnitID").Value), False)
            flowRateDescription =  CStr(CDbl(flowRateValue)) & " " & SessionAttribute(sessionId, DA_FLOW_RATE_UNIT) & "/" & SessionAttribute(sessionId, DA_FLOW_RATE_UNIT_TIME)
            SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE), CStr(CDbl(flowRateValue)))
            SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE_UNITID), xmlItem.Attributes("Infusion_FlowRate_UnitID").Value)
            SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE_UNIT), flowRateUnitDescription)
            SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE_UNITID_TIME), xmlItem.Attributes("Infusion_FlowRate_TimeUnitID").Value)
            SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE_UNIT_TIME), flowRateTimeUnitDescription)
        End If
    End If

    'Check for continuous infusions data
    requestTypeRead = New OCSRTL10.RequestTypeRead()
    requestTypeId = requestTypeRead.RequestTypeByDescription(sessionId, strRequestType)
    requestTypeRead = Nothing

    '09Feb10    Rams    F0063046 - Calculate Dose over Last 24 hours
    mandatoryRecordDoses = (SettingGet(sessionId, "OCS", "DrugAdministration", "MandatoryRecordDoses", "0") = "1")
    sRecordDoses = SettingGet(sessionId, "OCS", "DrugAdministration", "RecordDoses", "0").ToLower()
    
    strContinuous = GetXMLValueNested(domRx, "root/data", "Continuous").ToString()
    bContinuous = (strContinuous = "1")
   
    '28Mar12 ST 30515
    'In progress check was previously being performed against the prescription - now changed to be against the admin request.
    'bInProgress = (GetXMLValueNested(DOMRx, "root/data", "InfusionInProgress") = "1")
    bInProgress = orderCommsItemRead.CheckInfusionInProgress(sessionId, requestId)

    ' Check for long duration base infusion
    bLongDurationBased = IsLongDurationBasedInfusion(domRx.OuterXml, sessionId)

    minRate = GetXMLValueNested(domRx, "root/data", "RateMin").ToString()
    maxRate = GetXMLValueNested(domRx, "root/data", "RateMax").ToString()
    startRate = GetXMLValueNested(domRx, "root/data", "Rate").ToString()
    rateUnit = GetXMLExpandedValue(domRx.SelectSingleNode("root/data"), "UnitID_RateMass") & "/" & GetXMLExpandedValue(domRx.SelectSingleNode("root/data"), "UnitID_RateTime").ToString()
    
    'set these values to state
    SessionAttributeSet(sessionId, "PreviousOriginURL", SessionAttribute(sessionId, "OriginURL"))
    SessionAttributeSet(sessionId, "OriginURL", referingUrl)
    SessionAttributeSet(sessionId, "RequestTypeID", requestTypeId.ToString())
    SessionAttributeSet(sessionId, "Continuous", strContinuous)
    SessionAttributeSet(sessionId, "LongDurationBased", IIf(bLongDurationBased, "1", "0").ToString())
    SessionAttributeSet(sessionId, "SupervisedAdmin", strSupervisedAdmin)
    '22Apr2010  Rams    F0078434 - Do not Create AdminRequest for PRN's when Override Administration    
    SessionAttributeSet(sessionId, "OverrideAdmin", blnOverrideAdmin.ToString())
    '
    If Not String.IsNullOrEmpty(minRate) And Not String.IsNullOrEmpty(maxRate) Then
        SessionAttributeSet(sessionId, DA_RATE_MIN, minRate)
        SessionAttributeSet(sessionId, DA_RATE_MAX, maxRate)
        SessionAttributeSet(sessionId, DA_RATE_UNIT_DESCRIPTION, rateUnit)
        '03Feb14 SPinnington Bug 105346 Populate the session attributes so that they are defaulted to the start rate/values
        SessionAttributeSet(sessionId, DA_RATE_START, startRate)
        SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE_UNITID), xmlItem.Attributes("Infusion_FlowRate_UnitID").Value)
        SessionAttributeSet(sessionId, DA_FLOW_RATE_UNIT, GetXMLExpandedValue(domRx.SelectSingleNode("root/data"), "UnitID_RateMass"))
        SessionAttributeSet(sessionId, CStr(DA_FLOW_RATE_UNITID_TIME), xmlItem.Attributes("Infusion_FlowRate_TimeUnitID").Value)
        SessionAttributeSet(sessionId, DA_FLOW_RATE_UNIT_TIME, GetXMLExpandedValue(domRx.SelectSingleNode("root/data"), "UnitID_RateTime").ToString())
        flowRateDescription =  CStr(CDbl(flowRateValue)) & " " & SessionAttribute(sessionId, DA_FLOW_RATE_UNIT) & "/" & SessionAttribute(sessionId, DA_FLOW_RATE_UNIT_TIME)
        If flowRateValue = Nothing Or flowRateDescription = String.Empty Then
            flowRateDescription = startRate & " " & SessionAttribute(sessionId, DA_RATE_UNIT_DESCRIPTION)
        End If

        If bInProgress AndAlso flowRateDescription = String.Empty Then
            flowRateDescription = "No Flow Rate Entered"
            flowRateClass = " sad"
        End If
        blnFlowRateRecording = True
    End If
    'Check for the NoDoseInfo flag; this indicates a doseless prescription with no frequency, where
    'the dose info is held no a separate card (anticoagulate chart or similar) - this is different to a PRN.
    blnNoDoseInfo = CIntX((CStr(GetXMLValueNested(domRx, "root/data", "NoDoseInfo")) = "1"))
    
    'And any standard attached notes that are on it
    notesRead = New OCSRTL10.NotesRead()
    strNotesXml = notesRead.AttachedNoteTextByRequestXML(sessionId, prescriptionId, True)
    strAttachedNotesXml = notesRead.AdministrationAttachedNoteTextByRequestXML(sessionId, requestId, True)
    strPomXml = notesRead.PatientsOwnByRequestXML(sessionId, prescriptionId, True)
    interventionNotesXml = notesRead.InterventionNoteDetails(sessionId, requestId)
    notesRead = Nothing
    domNotes = New XmlDocument()
    domNotes.TryLoadXml(strNotesXml)
    colNotes = domNotes.SelectNodes("attachednotes/Note")
    
    '03Feb2010 JMei display attached note attached to last administration    
    domAdminNotes = New XmlDocument()
    domAdminNotes.TryLoadXml(strAttachedNotesXml)
    colAttachedNote = domAdminNotes.SelectSingleNode("attachednotes/Note")
  
    '19Apr11 ST Read in treatment reasons
    notesRead = New OCSRTL10.NotesRead()
    treatmentReasonsXml = notesRead.ReasonByRequestXML(sessionId, prescriptionId)
    notesRead = Nothing
    
    domTreatmentReasons = New XmlDocument()
    If Not treatmentReasonsXml = String.Empty Then
        domTreatmentReasons.TryLoadXml("<root>" & treatmentReasonsXml & "</root>")
        treatmentReasonNode = domTreatmentReasons.SelectSingleNode("root/Note")
    End If
    
    domIntervention = New XmlDocument()
    domIntervention.TryLoadXml("<root>" & interventionNotesXml & "</root>")
    interventionNode = domIntervention.SelectNodes("root/eMMIntervention")
    
    dompom = New XmlDocument()
    dompom.TryLoadXml(strPomXml)
    colPom = dompom.SelectNodes("attachednotes/Note")
    
    If colPom.Count > 0 AndAlso colPom.Item(0).Attributes("POMStatus").Value.ToString.ToLower = "fit for use" Then
        SessionAttributeSet(sessionId, "UsePOM", "1")
    Else
        SessionAttributeSet(sessionId, "UsePOM", "0")
    End If
    
    'Check if we have any batchnumbers entered for this dose
    Dim oBatchNumbersRead As OCSRTL10.RequestBatchNumberRead = New OCSRTL10.RequestBatchNumberRead
    strBatchNumbersXml = oBatchNumbersRead.BatchNumbersByRequestIDXML(sessionId, requestId)
    domBatchnumbers = New XmlDocument()
    domBatchnumbers.TryLoadXml(strBatchNumbersXml)
    colBatchnumbers = domBatchnumbers.SelectNodes("//" & NODE_PRODUCT & "[@" & ATTR_BATCHNUMBER & "]")
    blnHaveBatchNumber = (colBatchnumbers.Count > 0)
    
    'Check if this has been second checked
    '26Jan07 ST  Second check user information
    entityIdChecker = SessionAttribute(sessionId, (DA_ENTITYID_CHECKER & requestId))
    If entityIdChecker <> "" Then
        blnSecondChecked = True
        ' Get the user name
        entityRead = New ENTRTL10.EntityRead()
        strUserName = entityRead.GetEntityNameByEntityID(sessionId, CIntX(entityIdChecker))
    Else
        blnSecondChecked = False
    End If
    
    
    
    'Dim objRequestSecondCheckRead As OCSRTL10.RequestSecondCheckRead = New OCSRTL10.RequestSecondCheckRead
    'Dim domSecondCheck As MSXML 2.DOMDocument = New MSXML 2.DOMDocument()
    'domSecondCheck.TryLoadXml(objRequestSecondCheckRead.SecondCheckByRequestIDXML(SessionID, RequestID))
    'Dim elemSecondCheck As Object = domSecondCheck.SelectSingleNode("//RequestSecondCheck")

    'If elemSecondCheck IsNot Nothing Then
    
    'And the last admin response (ie the last recorded administration)
    '
    '04Mar10    Rams    F0078153 - If a dose is recorded as "A Problem Occurred", the "Last Dose was given" field does not update
    '
    'The logic has been changed here after the DoseOverlast 24 hours has been implemented
    'Last dose given should also display the partial administration
    'When it comes to override only the full administration should count.
    '
    strResponseXml = AdminResponseLast(sessionId, requestId)
    domResponse = New XmlDocument()
    If strResponseXml <> "" Then
        Dim RequestID_Prescription_Administered As Integer = -1
        Dim RecordedDose As String = String.Empty
        
        domResponse.TryLoadXml("<root>" + strResponseXml + "</root>")
        xmlResponse = domResponse.SelectSingleNode("/root")
        'Logic used here is
        '1. When the Drug is Administered for the First time either Correctly Administered or Partially, then print the time and Date as the last Date and Time
        '2. When the Drug is Overridden, if the Overridden is a partial one and new Response is correctly administered then print the time and Date as the  Last admin date and time
        '3. When the Overridden is a correctly administered one and new response is a partial one, consider the Date and Time of the first Admin as the Date and Time
        xmlResponse = xmlResponse.SelectSingleNode("Response")
		If xmlResponse.Attributes("Overridden") IsNot Nothing AndAlso xmlResponse.Attributes("Overridden").Value = "1" Then
			'The last admin was Overridden, so identify the correct one, as per above logic.
			For Each xmlOverride As XmlElement In domResponse.SelectNodes("/root/Response")
				lastAdministeredBy = xmlResponse.Attributes("UserName").Value
				'
				If xmlOverride.GetAttribute("Partial") = "0" Then 'Administered Correctly
					dtLast = TDate2DateTime(xmlOverride.GetAttribute("AdministeredDate").Split("T")(0) & "T" & xmlOverride.GetAttribute("AdministeredTime").Split("T")(1))
					If Not String.IsNullOrEmpty(xmlOverride.GetAttribute("RequestID_Prescription")) Then
						RequestID_Prescription_Administered = Integer.Parse(xmlOverride.GetAttribute("RequestID_Prescription"))
					End If
                    
					If Not String.IsNullOrEmpty(xmlOverride.GetAttribute("RecordedDose")) Then
						RecordedDose = xmlOverride.GetAttribute("RecordedDose")
					End If
                    
					Exit For
					'
				ElseIf domResponse.SelectNodes("/root/Response[@RequestID='" + xmlOverride.GetAttribute("RequestID") + "']").Count = 1 Then
					If Not String.IsNullOrEmpty(xmlOverride.GetAttribute("AdministeredDate")) AndAlso Not String.IsNullOrEmpty(xmlOverride.GetAttribute("AdministeredTime")) Then
						dtLast = TDate2DateTime(xmlOverride.GetAttribute("AdministeredDate").Split("T")(0) & "T" & xmlOverride.GetAttribute("AdministeredTime").Split("T")(1))
					Else
						dtLast = TDate2DateTime(xmlOverride.GetAttribute("CreatedDate"))
						blnNoAdministrationRecord = True
					End If
                    
					If Not String.IsNullOrEmpty(xmlOverride.GetAttribute("RequestID_Prescription")) Then
						RequestID_Prescription_Administered = Integer.Parse(xmlOverride.GetAttribute("RequestID_Prescription"))
					End If
                    
					If Not String.IsNullOrEmpty(xmlOverride.GetAttribute("RecordedDose")) Then
						RecordedDose = xmlOverride.GetAttribute("RecordedDose")
					End If
                    
					Exit For
				End If
				'
			Next
		Else
			'
			If xmlResponse.Attributes("AdministeredDate") IsNot Nothing AndAlso xmlResponse.Attributes("AdministeredTime").Value.Length > 0 Then
				dtLast = TDate2DateTime(xmlResponse.Attributes("AdministeredDate").Value.Split("T")(0) & "T" & xmlResponse.Attributes("AdministeredTime").Value.Split("T")(1))
			Else
				dtLast = TDate2DateTime(xmlResponse.Attributes("CreatedDate").Value)
				blnNoAdministrationRecord = True
			End If
            
			If xmlResponse.Attributes("RequestID_Prescription") IsNot Nothing AndAlso xmlResponse.Attributes("RequestID_Prescription").Value.Length > 0 Then
				RequestID_Prescription_Administered = Integer.Parse(xmlResponse.Attributes("RequestID_Prescription").Value)
			End If
                    
			If xmlResponse.Attributes("RecordedDose") IsNot Nothing AndAlso xmlResponse.Attributes("RecordedDose").Value.Length > 0 Then
				RecordedDose = xmlResponse.Attributes("RecordedDose").Value
			End If

			lastAdministeredBy = xmlResponse.Attributes("UserName").Value
		End If
        
        If RequestID_Prescription_Administered > 0 Then
            Prescription_Administered = GetPrescribedDescription(sessionId, RequestID_Prescription_Administered, RecordedDose)
        End If
    Else
        dtLast = ""
        blnOverdue = False
    End If
    If IsDate(dtLast) Then
        SessionAttributeSet(sessionId, "DateLastAdmin", DirectCast(dtLast, DateTime).ToString("yyyy-MM-ddTHH:mm:ss"))
    Else
        SessionAttributeSet(sessionId, "DateLastAdmin", "")
    End If
    
    'Is this an options order set?
    xmlOptionsElement = domRx.SelectSingleNode("//extra/attribute[@name='ContentsAreOptions']")
	If xmlOptionsElement IsNot Nothing Then
		bIsOptions = CIntX(xmlOptionsElement.getAttribute("value"))
	End If

    'Check if we have a single or multi-product prescription.  Multis are not yet supported.
    
    If GetXMLValueNested(domRx, "root/data", "ProductID").ToString().Length > 0 Then
        productId = CIntX(GetXMLValueNested(domRx, "root/data", "ProductID"))
    End If
    
    If GetXMLValueNested(domRx, "root/data", "ProductRouteID").ToString().Length > 0 Then
        RouteID = CIntX(GetXMLValueNested(domRx, "root/data", "ProductRouteID"))
    End If
    
    If productId > 0 And bIsOptions = 0 Then
        'Standard prescription
        strAdminAction = "Navigate_DrugEntry()"
    Else
        'infusion type prescription; products held as ingredients
        colProducts = domRx.SelectNodes("//Ingredients/Product")
        If colProducts.Count = 1 Then
            strAdminAction = "Navigate_DrugEntry()"
            xmlProduct = colProducts(0)
            productId = CIntX(xmlProduct.Attributes("ProductID").Value)
        Else
            If bIsOptions Then
                strAdminAction = "Navigate_OptionsSelection()"
            Else
                strAdminAction = "Navigate_DrugEntry()"
            End If
        End If
    End If
    'Work out how much content area we have
    intContentHeight = windowHeight - (2 * CIntX(TouchscreenShared.BUTTON_STANDARD_HEIGHT)) - (4 * CIntX(BUTTON_SPACING)) - 200
    If mode = MODE_SELECT AndAlso bLockFailed Then
        intContentHeight -= 40
    End If
    intContentWidth = windowWidth - CIntX(TouchscreenShared.BUTTON_SCROLL_WIDTH) - 2 * CIntX(BUTTON_SPACING)
    Dim bInfusionEndTimeOptional As Boolean 'F0021465 LM 29/04/2008
    bInfusionEndTimeOptional = CBool(SettingGet(sessionId, "OCS", "DrugAdministration", "InfusionEndTimeOptional", "0"))
    blnPrnIsEarly = IsWhenRequiredPrescriptionEarly(dtDue, blnPrn)
    '15Sep11    Rams    TFS13883 - Gets an error when a free text prescription has got a when required frequency
    If Not isGenericTemplate Then prnDoseToExceedMaximumDoseRule = GetDoseToExceedMaximum(sessionId, domRx, blnPrn)
    
    ' 61958 CD - if this is a 'see accompanying paperwork' prescription then it can't be administered so just use view mode
    If mode = MODE_SELECT And Not blnPrn And scheduleId = 0 And blnNoDoseInfo Then
        destinationUrl = "AdministrationRequestList.aspx"
        referingUrl = "AdministrationRequestList.aspx"
        mode = MODE_VIEW
    End If
    
    
    ' CA 05/08/2015 TFS:123501
    ' If it is an option selection then use the prescription ID as this is the ID of the prescripion OPTION
    ' whereas there request id is the request of the options.
    If IsOptionSelection = True Then
        secondCheckId = prescriptionId
    Else 
        secondCheckId = requestId
    End If
%>

<html>
<head>
    <title>Drug Administration</title>
    <script language="javascript" type="text/javascript" src="../sharedscripts/SessionAttribute.js"></script>
    <script type="text/javascript" language="javascript" src='../sharedscripts/Touchscreen/Touchscreenshared.js'></script>
    <script type="text/javascript" language="javascript" src='scripts/DrugAdministrationConstants.js'></script>
    <script type="text/javascript" language="javascript">
    var bInfusionEndTimeOptional;

    bInfusionEndTimeOptional = <%= bInfusionEndTimeOptional.ToString().ToLower() %>;

    //----------------------------------------------------------------------------------------------
    function Navigate(strPage)
    {
		//Fires when a button is pressed
		var strURL = strPage;
		if (strURL.toLowerCase().indexOf('?sessionid') < 0)
		{
			strURL  += '?SessionID=<%= SessionID %>';
		}

	    void TouchNavigate(strURL);
    }

    //----------------------------------------------------------------------------------------------
    function RecordNonAdministration(){
    //Fires when the "no" button is pressed
    //Go to the admin no screen via the reason picker screen
	    var strUrl  = 'ArbtextPicker.aspx'
			      + '?SessionID=<%= sessionId %>'
		          + '&InfusionAction=ProblemRecorded'
		          + '&dssresult=<%= dssCheckResult %>'
                  + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			      + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx'
			      + '&' + DA_DESTINATION_URL + '=AdministrationNo.aspx'
			      + '&' + DA_ARBTEXTTYPE + '=' + ARBTEXTTYPE_NON_ADMIN_REASON
			      + '&' + DA_PROMPT + '=' + TXT_ENTER_NON_ADMIN_REASON;
        void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function RecordPartialAdministration() {
    //Fires when the "no" button is pressed
    //Go to the admin no screen via the reason picker screen
        var strUrl;

        if ('<%= blnPrnIsEarly %>' == 'True')
        {
            strUrl = 'ArbtextPicker.aspx'
                + '?SessionID=<%= sessionId %>'
                + '&dssresult=<%= dssCheckResult %>'
                + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&' + DA_ARBTEXTRETURNID + '=' + DA_ARBTEXTID_EARLY
                + '&' + DA_DESTINATION_URL + '=AdministrationEarlyPartialPRN.aspx'
                + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx'
                + '&' + DA_ARBTEXTTYPE + '=' + ARBTEXTTYPE_PRN_EARLY_ADMIN_REASON
                + '&' + DA_PROMPT + '=' + TXT_ENTER_PRN_EARLY_ADMIN_REASON;
        }
        else {
            strUrl = 'ArbtextPicker.aspx'
                + '?SessionID=<%= sessionId %>'
                + '&dssresult=<%= dssCheckResult %>'
                + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                + '&' + DA_DESTINATION_URL + '=AdministrationPartial.aspx'
                + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx'
                + '&' + DA_ARBTEXTTYPE + '=' + ARBTEXTTYPE_PARTIAL_ADMIN_REASON
                + '&' + DA_PROMPT + '=' + TXT_ENTER_PARTIAL_ADMIN_REASON;
        }
        void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function Navigate_DrugEntry(){
    //Fires when the "yes" button is pressed
        var strUrl = 'AdministrationDateEntry.aspx'
            + '?SessionID=<%= sessionId %>'
                + '&dssresult=<%= dssCheckResult %>'
                    + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                        + '&SupervisedAdmin=';
        
        
         if('<%= blnPrnIsEarly %>' == 'True')
         {
             strUrl = 'ArbtextPicker.aspx'
                 + '?SessionID=<%= sessionId %>'
                 + '&dssresult=<%= dssCheckResult %>'
                 + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                 + '&' + DA_ARBTEXTRETURNID + '=' + DA_ARBTEXTID_EARLY 
                 + '&' + DA_DESTINATION_URL + '=AdministrationDateEntry.aspx'
                 + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx'
                 + '&' + DA_ARBTEXTTYPE + '=' + ARBTEXTTYPE_PRN_EARLY_ADMIN_REASON
                 + '&' + DA_PROMPT + '=' + TXT_ENTER_PRN_EARLY_ADMIN_REASON;
         }

        void TouchNavigate(strUrl);

    }
    //----------------------------------------------------------------------------------------------
    //Fired when "yes" button pressed during options order set administration
    function Navigate_OptionsSelection()
    {
	    var strUrl  = 'AdministrationOptionsSelection.aspx?SessionID=<%= sessionId %>&PrescriptionID=<%= prescriptionId %>&AdminRequestID=<%= requestId %>';
	    void TouchNavigate(strUrl);
    }

    function EnterEnteralPH() {
        var strUrl = 'AdministrationEnteralPHValue.aspx'
			      + '?SessionID=<%= sessionId %>'
			      + '&dssresult=<%= dssCheckResult %>'
                  + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			      + '&FirstLoad=1' //  F0021972
			      + '&' + DA_DESTINATION_URL + '=AdministrationPrescriptionDetail.aspx'
			      + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx';

	    void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function EnterBatchNumbers(){

    //Fires when the "Enter Batch Numbers" button is pressed.

	    var strUrl  = 'AdministrationBatchNumbers.aspx'
			      + '?SessionID=<%= sessionId %>'
			      + '&dssresult=<%= dssCheckResult %>'
                  + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			      + '&FirstLoad=1' //  F0021972
			      + '&' + DA_DESTINATION_URL + '=AdministrationPrescriptionDetail.aspx'
			      + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx';

	    void TouchNavigate(strUrl);
    }

    function EnterNote(){

    //Fires when the "Enter Batch Numbers" button is pressed.

	    var strUrl  = 'AdministrationNote.aspx'
			      + '?SessionID=<%= sessionId %>'
			      + '&dssresult=<%= dssCheckResult %>'
                  + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			      + '&FirstLoad=1' //  F0021972
			      + '&' + DA_DESTINATION_URL + '=AdministrationPrescriptionDetail.aspx'
			      + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx';

	    void TouchNavigate(strUrl);
    }


    //----------------------------------------------------------------------------------------------
    function EnterSecondCheck() {

    //Fires when the "Second Check" button is pressed.

	    var strUrl = 'AdministrationSecondCheck.aspx'
			     + '?SessionID=<%= sessionId %>'
			     + '&dssresult=<%= dssCheckResult %>'
                 + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			     + '&' + DA_DESTINATION_URL + '=AdministrationPrescriptionDetail.aspx'
			     + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx';

	    void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function EnableButtons(){
	    if (divContent.offsetHeight < (divScroller.offsetHeight -20) ){
		    document.all['ascScrollup'].style.display = 'none';
		    document.all['ascScrolldown'].style.display = 'none';
	    }
	    else {
		    EnableButton(document.all['ascScrollup'], false);
	    }

    }
    //----------------------------------------------------------------------------------------------
    function PageUp(){
    //Scroll the content window 1 page upwards
	    divScroller.scrollTop = divScroller.scrollTop - <%= intContentHeight %>;
	    void EnableButton(document.all['ascScrolldown'], true);
	    if (divScroller.scrollTop > 0){
		    void EnableButton(document.all['ascScrollup'], true);
	    }
	    else {
		    void EnableButton(document.all['ascScrollup'], false);
	    }
    }

    //----------------------------------------------------------------------------------------------
    function PageDown(){
    //Scroll the content window 1 page downwards
	    divScroller.scrollTop = divScroller.scrollTop + <%= intContentHeight %>;
	    void EnableButton(document.all['ascScrollup'], true);

	    if ((divScroller.scrollTop + divScroller.offsetHeight) >= divContent.offsetHeight){
		    void EnableButton(document.all['ascScrolldown'], false);
	    }
	    else {
		    void EnableButton(document.all['ascScrolldown'], true);
	    }
    }

    //----------------------------------------------------------------------------------------------
    function RecordInfusionStartedAdministration()
    {
	    var strUrl  = "AdministrationDateEntry.aspx"
		      + "?SessionID=<%= sessionId %>"
		      + '&DateEntryPrompt=Please indicate the time at which the infusion was STARTED. (Press to change)'
		      + "&InfusionAction=Started";

         if('<%= blnPrnIsEarly %>' == 'True')
         {
             strUrl = 'ArbtextPicker.aspx'
                 + '?SessionID=<%= sessionId %>'
                 + '&dssresult=<%= dssCheckResult %>'
                 + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
                 + '&' + DA_ARBTEXTRETURNID + '=' + DA_ARBTEXTID_EARLY 
                 + '&' + DA_DESTINATION_URL + '=AdministrationInfusionStartEarlyPRN.aspx'
                 + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx'
                 + '&' + DA_ARBTEXTTYPE + '=' + ARBTEXTTYPE_PRN_EARLY_ADMIN_REASON
                 + '&' + DA_PROMPT + '=' + TXT_ENTER_PRN_EARLY_ADMIN_REASON;
         }
        
	    void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function RecordInfusionEndedAdmnistration()
    {
        SessionAttributeSet(<%=SessionID %>, '<%=CStr(DA_NODOSERULES) %>', '1');
        
          //F0021465 LM 29/04/2008
	       var  strUrl  = 'AdministrationDateEntry.aspx'
		      + '?SessionID=<%= sessionId %>'
		      + '&dssresult=<%= dssCheckResult %>'
              + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
		      + '&InfusionAction=Ended'
		      + '&DateEntryPrompt=Please indicate the time at which the infusion was ENDED (Press to change)';
    		  
	        if (bInfusionEndTimeOptional == true)
	        {
	    	    strUrl += '. You may skip this step';
	        }
        	
    	    strUrl  += '.';
        	
	        void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function RecordFluidChangedAdministration()
    {
        SessionAttributeSet(<%=SessionID %>, '<%=CStr(DA_NODOSERULES) %>', '1');
        
	    var strUrl  = 'AdministrationFluidChange.aspx'
		      + '?SessionID=<%= sessionId %>'
	          + '&dssresult=<%= dssCheckResult %>'
              + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
		      + '&InfusionAction=FluidChange';

	    void TouchNavigate(strUrl);
    }

    function RecordFlowRateChangedAdministration()
    {
        SessionAttributeSet(<%=SessionID %>, '<%=CStr(DA_NODOSERULES) %>', '1');
        
	    var strUrl  = 'AdministrationFlowRateChange.aspx'
		      + '?SessionID=<%= sessionId %>'
		      + '&dssresult=<%= dssCheckResult %>'
              + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
		      + '&InfusionAction=FlowRateChange';

	    void TouchNavigate(strUrl);
    }

    //----------------------------------------------------------------------------------------------
    function RecordInfusionProblemAdministration()
    {
		var sessionID = <%=SessionID %>
		var continuous = <%= bContinuous.ToString().ToLower() %>
		var longDuration = <%= bLongDurationBased.ToString().ToLower() %>

        SessionAttributeSet(sessionID, '<%=CStr(DA_NODOSERULES) %>', '1');
        
	    var strUrl  = 'ArbtextPicker.aspx'
			      + '?SessionID=<%= sessionId %>'
                  + '&dssresult=<%= Request.QueryString("dssresult") %>'			  
                  + '&IsGenericTemplate=<%= Request.QueryString("IsGenericTemplate") %>'
			      + '&' + DA_REFERING_URL + '=AdministrationPrescriptionDetail.aspx'
			      + '&InfusionAction=ProblemRecorded';

	    if (continuous || longDuration)
	    {
		    strUrl += '&' + DA_ARBTEXTTYPE + '=' + ARBTEXTTYPE_PARTIAL_ADMIN_REASON;
		    strUrl += '&' + DA_PROMPT + '=' + TXT_ENTER_PARTIAL_ADMIN_REASON;
		    strUrl += '&' + DA_DESTINATION_URL + '=AdministrationInfusionsContinue.aspx';  //continuous infusion needs to eventually go to Infusions to Continue page via arbtext
        }
	    else  
	    {
	        strUrl += '&' + DA_ARBTEXTTYPE + '=' + ARBTEXTTYPE_NON_ADMIN_REASON;
		    strUrl += '&' + DA_PROMPT + '=' + TXT_ENTER_NON_ADMIN_REASON;
		    strUrl += '&' + DA_DESTINATION_URL + '=AdministrationNo.aspx';  //ordinary NO			  
        }
        
	    void TouchNavigate(strUrl);
    }
    //----------------------------------------------------------------------------------------------
    function TryLockAgain()
    {
        // Refresh
	    TouchNavigate ( document.URL );
    }
    //----------------------------------------------------------------------------------------------
    function ClearLock()
    {
        // document.URL should not be made toLower because the url may contain xml which is case sensitive
	    var strUrl = document.URL;
	    if ( strUrl.indexOf ( 'overridelock' ) > 0 )
	        strUrl = strUrl.replace ( 'overridelock=0', 'overridelock=1' );
	    else
	        strUrl += '&overridelock=1';

	    TouchNavigate(strUrl);
    }
    </script>
    <link rel='stylesheet' type='text/css' href='../../style/application.css' />
    <link rel='stylesheet' type='text/css' href='../../style/Touchscreen.css' />
    <link rel='stylesheet' type='text/css' href='../../style/DrugAdministration.css' />
</head>

<body class="Touchscreen PrescriptionDetail" onload="document.body.style.cursor = 'default';EnableButtons()">
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
                        If (destinationUrl <> referingUrl) Or mode = MODE_SELECT Then
                    %>
                        <td class="Toolbar" style="padding-left: <%= BUTTON_SPACING %>">
                        <%
                            'Script the "back to list" button, if required
                            If CIntX(blnIsImmediateAdmin) = 1 Then
                                TouchscreenShared.NavToolBarButton("../../images/touchscreen/DrugAdministration/DrugChart.gif", "Back", "window.parent.RemoteNextItem(0)", True)
                            Else
                                TouchscreenShared.NavToolBarButton("../../images/touchscreen/DrugAdministration/DrugChart.gif", "Back", "Navigate('" & referingUrl & "')", True)
                            End If
                        %>
                        </td>
                        <td class="Toolbar" style="padding-left: <%= BUTTON_SPACING %>">
                            <%
                        TouchscreenShared.NavToolBarButton("../../images/touchscreen/DrugAdministration/" & IFF(blnHaveBatchNumber, "BatchNumbersEntered.gif", "BatchNumbers.gif").ToString(), "Enter Batch Numbers", "EnterBatchNumbers()", Not (bLockFailed))
                            %>
                        </td>
                        <td class="Toolbar" style="padding-left: <%= BUTTON_SPACING %>">
                            <%
        
                        TouchscreenShared.NavToolBarButton("../../images/touchscreen/DrugAdministration/" & IFF(blnSecondChecked, "SecondChecked.gif", "SecondCheck.gif").ToString(), "Second Check", "EnterSecondCheck()", Not (bLockFailed))
                            %>
                        </td>
                    <%
                        End If
                    %>
                        <td class="Toolbar" style="padding-left: <%= BUTTON_SPACING %>">
                            <%
                                Dim s As String = Ascribe.Common.Generic.SessionAttribute(sessionId, DA_NOTE)
                                Dim r As String = Ascribe.Common.Generic.SessionAttribute(sessionId, DA_NOTE_REQUESTID)
                                Dim blnNoteAdded = (Not s = "" And r = requestId.ToString())
                                TouchscreenShared.NavToolBarButton("../../images/touchscreen/DrugAdministration/" & IFF(blnNoteAdded, "Ticked_Note.gif", "Note.gif").ToString(), "Note", "EnterNote()", Not (bLockFailed))
                            %>
                        </td>
                        <%
                            Dim isEnteralFeed As Boolean = GetXMLExpandedValue(domRx, "RequestTypeID") = VALUE_REQUESTTYPE_ENTERALPRESCRIPTION
                            If isEnteralFeed Then
                                ' only display this button if this is an enteral feed administration via the NG route
                                If GetXMLExpandedValue(domRx, "ProductRouteID").ToString().ToUpperInvariant() = ATTR_NGROUTE Then
                                    Response.Write("<td class='Toolbar' style='padding-left:" & BUTTON_SPACING & "'>")
                                    TouchscreenShared.NavToolBarButton("../../images/touchscreen/DrugAdministration/EnteralPh.gif", "Record/View NG pH Value", "EnterEnteralPH()", Not (bLockFailed))
                                    Response.Write("</td>")
                                End If
                            End If
                        %>
                    </tr>
                </table>    
            </td>
        </tr>
    </table>    

    <table cellpadding="0" cellspacing="0" style="width: 100%;">
        <tr>
            <td colspan="5" style="text-align:left;">
		    <%
	            DrugAdminEpisodeBannerByID(sessionId, episodeId)
            %>
		    </td>
	    </tr>
    </table>

    <table style="width: 100%; height: 100%;" cellpadding="0" cellspacing="0" align="center">
        <tr>
            <td style="height: <%= intContentHeight %>px; width: <%= intContentWidth %>px">
                <div id="divScroller" style="overflow: hidden; height: 100%">
                    <div id="divContent">
                        <%
                            If Not String.IsNullOrEmpty(medicationStoppedMessage.Trim()) Then
                                Response.Write("<table class ='PrescriptionCancelled' align='center'>")
                                Response.Write("<tr>" & vbCr & "<td class='AttrValue Sad' colspan='10' style='width:800px;'>" + medicationStoppedMessage + "</td>" & vbCr & "</tr>" & vbCr)
                                
                                ' TFS40675 ST 28Aug12 If the cancellation was done after the dose was due then display any reason and associated text with the cancellation message.
                                If Not String.IsNullOrEmpty(cancelReason.Trim()) Then
                                    Response.Write("<tr>" & vbCr & "<td colspan='10' style='width:800px;font-size:16px;'><b>Reason for stopping</b> : " + cancelReason + "</td>" & vbCr & "</tr>" & vbCr)
                                    If Not String.IsNullOrEmpty(cancelText.Trim()) Then
                                        Response.Write("<tr>" & vbCr & "<td colspan='10' style='width:800px;font-size:16px;'><b>Additional information</b> : " + cancelText + "</td>" & vbCr & "</tr>" & vbCr)
                                    End If
                                End If
                                Response.Write("</table>")
                            End If
                        %>
                        <table class='DoseInformation' align="center" >
                            <%
                                'List0r153 the prescription attributes
                                ScriptDoseInformationWrapper(sessionId, domRx, isGenericTemplate, sUnitDescription, productId, blnNoDoseInfo, strRequestType, isVariableDose, dose, doseLow)
                            %>
                            <%
                                '22Aug11 XN Contorlled drug
                                If cdCupboard Then
                                    Response.Write("<tr>" & vbCr & "<td class='AttrName'>Controlled Drug</td><td class='AttrValue' colspan='10'>Cupboard</td>" & vbCr & "</tr>" & vbCr)
                                End If
                                'End of Contorlled drug
                                        
                                If blnPrn Then
                                    ' F0115307 19Apr11 If there is a treatment reason with this prescription then display it here
                                    ' otherwise display nothing at all
                                    ' Now update as we get treatment reasons from two locations, ArbText and OrderCatalogue
                                    ' Only one will exist so we try ArbText first and then OrderCatalogue.
                                    Dim treatmentReason As String = String.Empty
                                
                                    Try
                            			If treatmentReasonNode IsNot Nothing Then
                            				If treatmentReasonNode.Attributes("ArbTextID") IsNot Nothing AndAlso treatmentReasonNode.Attributes("ArbTextID").Value.Length > 0 Then
                            					arbitraryTextRead = New OCSRTL10.ArbitraryTextRead()
                            					arbtextXml = New XmlDocument()
                            					arbtextXml.TryLoadXml(arbitraryTextRead.GetTextByID(sessionId, CIntX(treatmentReasonNode.Attributes("ArbTextID").Value)))
                                                        
                            					If arbtextXml.SelectSingleNode("ArbText").Attributes("Detail") IsNot Nothing AndAlso arbtextXml.SelectSingleNode("ArbText").Attributes("Detail").Value.Length > 0 Then
                            						treatmentReason = arbtextXml.SelectSingleNode("ArbText").Attributes("Detail").Value
                            					End If
                            				ElseIf treatmentReasonNode.Attributes("NoteID") IsNot Nothing AndAlso treatmentReasonNode.Attributes("NoteID").Value.Length > 0 Then
                            					rowRead = New ICWRTL10.RowRead()
                            					noteXml = New XmlDocument()
                            					noteXml.TryLoadXml(rowRead.GetFilled(sessionId, CIntX(treatmentReasonNode.Attributes("TableID").Value), CIntX(treatmentReasonNode.Attributes("NoteID").Value)))
                                        
                            					orderCatalogueRead = New OCSRTL10.OrderCatalogueRead()
                            					treatmentReason = orderCatalogueRead.GetDetailByID(sessionId, CIntX(noteXml.SelectSingleNode("ReasonNote").Attributes("OrderCatalogueID").Value))
                            				End If
                            			End If
                                    Catch ex As Exception
                                    End Try
                                
                            		If Not String.IsNullOrEmpty(treatmentReason) Then
                                    %>
                                    <tr>
                                        <td class='AttrName'>Reason For Prescribing</td>
                                        <td class='AttrValue'><% Response.Write(treatmentReason)%></td>
                                    </tr>
                                    <%
                                    End If
                                End If
                            %>
                            
                            <tr>
                                <td class="AttrName">Device</td>
                                <td class="AttrValue"><%=xmlItem.Attributes("Device").Value %></td>
                            </tr>
                            <tr>
                                <td class="AttrName">Batch Numbers</td>
                                <td class="AttrValue <%
    If Not blnHaveBatchNumber Then 
        Response.Write("sad")
    End IF
%>
" colspan="2">
                                    <%
                                        If blnHaveBatchNumber Then
                                            Response.Write("Batch numbers Entered")
                                        Else
                                            Response.Write("No Batch Numbers Entered")
                                        End If
                                    %>
                                </td>
                                <tr>
                                    <tr>
                                        <td class='AttrName'>
                                        <% If blnPrn Then %>
                                            Available
                                        <% Else %>
                                            Due
                                        <% End If %>
                                        </td>
                                        <td class='AttrValue <%
        'This dose due time; Last dose given
    If blnOverdue Then 
        Response.Write("sad")
    End IF
%>
' colspan='4'>
                                            <%
    
                                            	'TODO Check if hyphen should be displayed if prn has been given and next dose date is due
                                            	' Added false clause as we no-one knows why we should be not showing the due time if a previous dose has been given - but don't want to lose the code yet just in case
                                            	If CStr(dtLast) <> "" And False Then
                                            		'Already given
                                            		Response.Write(" - ")
                                            	Else
                                            		If scheduleId = 0 And blnPrn And Not SingleDoseIfRequired Then
                                            			'"When Required" PRN
                                            			If dtDue > Date.Now() Then
                                            				Response.Write(DateToFriendlyText(dtDue) & ", at " & Date2HHmm(dtDue))
                                            			Else
                                            				Response.Write("When Required")
                                            			End If
                                            		Else
                                            			'Ordinary scheduled dose, or "If Required" PRN
                                            			Response.Write(DateToFriendlyText(dtDue) & ", at " & Date2HHmm(dtDue))
                                            			If blnPrn Then
                                            				Response.Write(" If Required ")
                                            			End If
                                            			If blnOverdue Then
                                            				Response.Write("&nbsp;&nbsp;(OVERDUE)")
                                            			End If
                                            		End If
                                            	End If
                                            %>
                                        </td>
                                    </tr>
                                    <%-- TFS 118923 <tr>
                                        <%
                                            If blnNoAdministrationRecord = True Then
                                        %>
                                        <td class='AttrName'>Recorded as Problem occured on</td>
                                        <% 
                                        Else
                                        %>
                                        <td class='AttrName'>Last Dose Was Given</td>
                                        <%
                                        End If
                                        %>
                                        <td class='AttrValue' colspan='5'>
                                            <%
                                                If CStr(dtLast) = "" Then
                                                    Response.Write("No Doses have been administered.")
                                                Else
                                                    Response.Write(DateToFriendlyText(dtLast) & ", at " & Date2HHmm(dtLast))
                                                    Response.Write(", by " & lastAdministeredBy)  'xmlResponse.getAttribute("UserName"))
                                                End If
                                            %>
                                        </td>
                                    </tr>--%>
                                    <% If Prescription_Administered.Length > 0 Then%>
                                    <tr>
                                        <td>&nbsp;</td>
                                        <td class='AttrValue' colspan='5'>as <%=Prescription_Administered%></td>
                                    </tr>
                                    <% End If%>
                                    <% If flowRateDescription <> "" Then%>
                                    <tr>
                                        <td class='AttrName'>Flow Rate</td>
                                        <td class='AttrValue <%= flowRateClass %>'>
                                            <%=flowRateDescription%>
                                        </td>
                                    </tr>
                                    <% End If %>                                                                        
                                    <%-- TFS 118923 <tr>
                                        <td class='AttrName'>Last Note</td>
                                        <td class='AttrValue' style="width: 350px;" colspan='5'>
                                            <%					
                                                Dim note As String
                                                '04Feb2010 JMei display attached note attached to last administration 
                                                note = "N/A"
                                                If colAttachedNote IsNot Nothing Then
                                                    note = colAttachedNote.Attributes("Detail").Value
                                                    note = note.Replace(vbLf, "<br/>")
                                                End If
           
                                                'If (Not (xmlResponse Is Nothing)) Then
                                                '    If (Not xmlResponse.getAttribute("Note") Is Nothing) Then
                                                '        If Not IsDBNull(xmlResponse.getAttribute("Note")) Then
                                                '            note = xmlResponse.getAttribute("Note")
                                                '            note = note.Replace(vbLf, "<br/>")
                                                '        End If
                                                '    End If
                                                'End If
           
                                                If (note = "") Then
                                                    note = "N/A"
                                                End If
                                                Response.Write(note)
                                            %>
                                        </td>
                                    </tr>--%>
                                    <%  '02Feb10    Rams    F0063046 - Display dose administered over last 24 hours
                                        If blnPrn Then%>
                                            <tr>
                                                <td class='AttrName'>
                                                <%
                                                    If strRequestType.ToString().ToUpper() = "DOSELESS ADMINISTRATION" Then
                                                        Response.Write("Doses over last 24 hours")
                                                    Else
                                                        Response.Write("Dose over last 24 hours")
                                                    End If
                                                %>
                                                </td>
                                                <td class='AttrValue' style="width: 350px;" colspan='5'>
                                                    <%  '29Mar11    Rams    F0113133 - Free text admin of when required doses - due text issue
                                                        '06Aug12    XN      TFS38095 - Updated to include amendments in dose
                                                        If isGenericTemplate OrElse String.IsNullOrEmpty(GetAdminUnit(domRx.SelectSingleNode("root/data"), True, sessionId)) Then
                                                            Response.Write("Dose cannot be recorded for this prescription type")
                                                        Else
                                                            TotalDoseOver24Hours(sessionId, Integer.Parse(RequestID_Parent), GetAdminUnit(DOMRx.selectSingleNode("root/data"), True, sessionId))
                                                        End If
                                                    %>    
                                                </td>
                                            </tr>
                                    <%End If%>
                                    
                                    <tr>
                                        <td class='AttrName'>Second Checked</td>
                                        <td class='AttrValue <%
                                        If Not blnSecondChecked Then 
                                            Response.Write("Sad")
                                        End IF
                                        %>' colspan='5'>
                                            <%
                                                If blnSecondChecked Then
                                                    Response.Write(strUserName)
                                                Else
                                                    If IsSecondCheckedRequired(sessionId, secondCheckId) Then
                                                        Response.Write("Check Required")
                                                    Else
                                                        Response.Write("Not Checked")
                                                    End If
                                                    
                                                End If
                                            %>
                                        </td>
                                    </tr>
                        </table>
                        <%
                            'Attached notage; if any exist
                            If colPom.Count + colNotes.Count + interventionNode.Count > 0 Then
                                Response.Write("<table class='AttachedNoteList'><tr><td colspan='2' class='AttrName'>Prescription Notes</td></tr>" & vbCr)
                            End If
                           
                            
                            If colNotes.Count > 0 Then
                                For Each xmlNote As XmlNode In colNotes
                                    Response.Write("<tr>")
                                    Response.Write("<td><img src=""../../images/ocs/classAttachedNote.gif"" /></td>")
                                    Response.Write("<td>" & xmlNote.Attributes("Detail").Value & "</td>")
                                    Response.Write("</tr>")
                                Next
                            End If
                            
                            If interventionNode.Count > 0 Then
                                For Each interventionNote As XmlNode In interventionNode
                                    Response.Write("<tr>")
                                    Response.Write("<td><img src=""../../images/ocs/questionmark.png"" /></td>")
                                    Response.Write("<td>" & interventionNote.Attributes("Detail").Value & " - " & interventionNote.Attributes("Comments").Value & "</td>")
                                    Response.Write("</tr>")
                                Next
                            End If
                            
                            If colPom.Count > 0 Then
                                xmlPom = colPom.Item(0)
                                Response.Write("<tr>")
                               
                                '26Mar2010 JMei F0081913 add another text for picking right picture
                                Select Case xmlPom.Attributes("POMStatus").Value.ToString.ToLower
                                    Case "fit for use", "suitable for use"
                                        Response.Write("<td><img src=""../../images/ocs/bottle.gif"" /></td>")
                                    Case Else
                                        Response.Write("<td><img src=""../../images/ocs/bottlecross.gif"" /></td>")
                                End Select
                                
                                Response.Write("<td>POM available<br />")
                                Response.Write(xmlPom.Attributes("POMStatus").Value.ToString)
                                If xmlPom.Attributes("Comments") IsNot Nothing AndAlso xmlPom.Attributes("Comments").Value.ToString.Length > 0 Then
                                    Response.Write("<br />")
                                    Response.Write(xmlPom.Attributes("Comments").Value.ToString)
                                End If
                                Response.Write("</td>")
                                Response.Write("</tr>")
                            End If

                            If colPom.Count + colNotes.Count + interventionNode.Count > 0 Then
                                Response.Write("</table>")
                            End If
                        %>
                        <table class="FurtherDetail">
                            <tr>
                                <%
                                    'Long text; template detail on this particular dose
                                    strBuffer = GetXMLValueNested(domRx, "root/data", "TemplateDetail").ToString()
                                    If CStr(strBuffer) <> "" Then
                                        Response.Write("<td class='AttrName'>Further Information</td></tr>" & vbCr & "<tr><td class='FurtherDetail'>" & vbCr)
                                        Response.Write(strBuffer)
                                        Response.Write("</td>")
                                    End If
                                    'Also look for the detail of the protocol that this item was part of, if indeed it was part of one.
                                    strBuffer = GetXMLValueNested(domRx, "root/data", "OrdersetDetail").ToString()
                                    If CStr(strBuffer) <> "" Then
                                        Response.Write("</tr><tr><td class='AttrName'>Protocol Information</td></tr>" & vbCr & "<tr><td class='FurtherDetail'>" & vbCr)
                                        Response.Write(strBuffer)
                                        Response.Write("</td>")
                                    End If
                                %>
                            </tr>
                        </table>
                        <%
                            ' Show any amendments made to the admnistration (an audit log of changes)
                            Dim dbTransport = New TRNRTL10.Transport()
                            Dim strParamXml As String
                            Dim changeDoc As New XmlDocument()
                            Dim changeNode As XmlNode
                            
                            strParamXml = dbTransport.CreateInputParameterXML("@RequestID_Admin", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeInt, 4, requestId)
                            changeDoc.TryLoadXml("<root>" & dbTransport.ExecuteSelectStreamSP(sessionId, "pAdminTimeLogLastChangeByAdmin", strParamXml) & "</root>")
                            ' <atl OldDate="2008-03-10T00:00:00" NewDate="2008-03-11T00:00:00" UserName=" sys admin" Notes="i made this!" />
                            changeNode = changeDoc.SelectSingleNode("//atl")

                        	If changeNode IsNot Nothing Then
                        %>
                        <table class="FurtherDetail">
                            <tr>
                                <td class='AttrName'>Amendment Details</td>
                            </tr>
                            <tr>
                                <td>
                                    The time that this administration is due has been edited from "<%=TDate2DateTime(changeNode.Attributes("OldDate").Value).ToString("dd/MM/yyyy HH:mm")%>"
                                    to "<b><%=TDate2DateTime(changeNode.Attributes("NewDate").Value).ToString("dd/MM/yyyy HH:mm")%></b>"
                                    by
                                    <%=changeNode.Attributes("UserName").Value%>
                                    on "<%=TDate2DateTime(changeNode.Attributes("CreatedDate").Value).ToString("dd/MM/yyyy HH:mm")%>"
                                </td>
                            </tr>
                            <tr>
                                <td><%= Server.HtmlEncode(changeNode.Attributes("Notes").Value)%></td>
                            </tr>
                        </table>
                        <%
                        End If
                        %>
                    </div>
                </div>
            </td>
            <td style='height: <%= intContentHeight %>px'>
                <table style="height: 100%">
                    <tr>
                        <td style="vertical-align: top;">
                            <%
                                TouchscreenShared.ScrollButtonUp("PageUp()", True)
                            %>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            &nbsp;
                        </td>
                    </tr>
                    <tr>
                        <td style="vertical-align:bottom;">
                            <%
                                TouchscreenShared.ScrollButtonDown("PageDown()", True)
                            %>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
        <tr>
            <td class="Prompt 
            <%
                If Not IsPrescriptionWithinPrescribeTimeWindow(dtDue,lngDueMinutes,lngMaxMinutesEarly, lngEarlyMode, blnPrn) Then
                    Response.Write("Sad")
                End IF
            %>
" style="height: <%=TouchscreenShared.BUTTON_STANDARD_HEIGHT %>;" colspan="2">
                <%
                    Select Case mode
                        Case MODE_VIEW
                            Response.Write("Press OK to Return")
                        Case MODE_SELECT
                            If bRxLockFailed Then
                                Response.Write("<img src='../../images/User/lock closed.gif' />")
                                Response.Write("Prescription is locked")
                                Response.Write("<div class='PromptSmallText'>" & nodeLockDetails.Attributes("UserFullName").Value & ", " & nodeLockDetails.Attributes("TerminalName").Value & " has this prescription locked</div>")
                            ElseIf bLockFailed Then
                                Response.Write("<img src='../../images/User/lock closed.gif' />")
                                Response.Write("Dose is locked")
                                Response.Write("<div class='PromptSmallText'>" & nodeLockDetails.Attributes("UserFullName").Value & ", " & nodeLockDetails.Attributes("TerminalName").Value & " is currently recording the administration of this dose</div>")
                            ElseIf isResulted Then
                                'Dose is resulted, and this is for single admin. so, throw warning to the user and this only thrown to the user on Immediate Admin, not through any other way
                                Response.Write("<span style='color:red;'>")
                                Response.Write("Dose already administered by " & AdministeredBy & ", at " & Date2ddmmccyyhhnn(DateAdministered) & "<br />")
                                Response.Write("It cannot be administered.")
                                Response.Write("</span>")
                            ElseIf Not IsPrescriptionWithinPrescribeTimeWindow(dtDue, lngDueMinutes, lngMaxMinutesEarly, lngEarlyMode, blnPrn) Or Not IsWhenRequiredPrescriptionInTimeWindow(dtDue, blnPrn, prnMaxMinutesEarly) Then
                                'Dose too far in the future to give
                                Response.Write("<span style='color:red;'>")
                                Response.Write("Dose is not due until " & DateToFriendlyText(dtDue) & ", at " & Date2HHmm(dtDue) & "<br />")
                                Response.Write("It cannot be administered yet.")
                                Response.Write("</span>")
                            ElseIf prnDoseToExceedMaximumDoseRule > 0 Then
                                Response.Write("<span style='color:red;'>")
                                Response.Write("Administering a dose greater than " & prnDoseToExceedMaximumDoseRule & " " & GetAdminUnit(domRx.SelectSingleNode("root/data"), False, sessionId) & "<br />")
                                Response.Write("will exceed the maximum dose rule for this prescription")
                                Response.Write("</span>")
                            ElseIf bLongDurationBased Then
                                If bInProgress Then
                                    Response.Write("Please indicate which action you wish to record.")
                                Else
                                    Response.Write("Please Indicate if the infusion was...")
                                End If
                            Else
                                Response.Write("Please indicate if the dose was...")
                            End If
                    End Select
                %>
            </td>
        </tr>
        <tr>
            <%
                Dim blnEnabledState As Boolean = True
                
                If IsSecondCheckedRequired(sessionId, secondCheckId) And Not blnSecondChecked Then
                    blnEnabledState = False
                End If
                
            %>
        
        
            <td style="text-align: center; vertical-align: top;" colspan="2">
                <table cellspacing="<%= BUTTON_SPACING %>">
                    <tr>
                        <%
                            If mode = MODE_SELECT Then
                        %>
                        <%      If bRxLockFailed Then%>
                        <td style="text-align: left;">
                            <%               TouchscreenShared.NavButton("", "Cancel", "Navigate('" & referingUrl & "')", True)%>
                        </td>
                        <%          If nodeRxLockDetails.Attributes("overridable").Value = "1" Then%>
                        <td style="text-align: right;">
                            <%               TouchscreenShared.NavButton("", "Clear Lock", "ClearLock()", True)%>
                        </td>
                        <%          End If%>
                        <%      ElseIf bLockFailed Then%>
                        <td style="text-align: left;">
                            <%               TouchscreenShared.NavButton("", "Cancel", "Navigate('" & referingUrl & "')", True)%>
                        </td>
                        <%          If nodeLockDetails.Attributes("overridable").Value = "1" Then%>
                        <td style="text-align: right;">
                            <%               TouchscreenShared.NavButton("", "Clear Lock", "ClearLock()", True)%>
                        </td>
                        <%          End If%>
                        <%  ElseIf Not IsPrescriptionWithinPrescribeTimeWindow(dtDue, lngDueMinutes, lngMaxMinutesEarly, lngEarlyMode, blnPrn) OrElse isResulted Then
                                'Dose too far in the future to give%>
                        <td style="text-align: right;">
                            <%
                                'Dose is too far in the future; we don't allow them to record administration yet.
                                TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "OK", "Navigate('" & referingUrl & "')", True)
                            %>
                        </td>
                        <%      ElseIf bContinuous Then%>
                        <%
                            If bInProgress Then
                        %>
                        <td style="text-align: left;">
                            <%
                                Dim enableStart As Boolean = Not (dssCheckResult = "fail_stop")
                                If enableStart And blnEnabledState = False
                                    enableStart = False
                                End If
                                TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/InfusionChange.gif", "Fluid Changed", "RecordFluidChangedAdministration()", enableStart)
                            %>
                        </td>
                        <td style="text-align: center;">
                            <%
                                TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/InfusionEnd.gif", "Infusion Ended", "RecordInfusionEndedAdmnistration()", blnEnabledState)
                            %>
                        </td>
                            <%
                                If blnFlowRateRecording Then
                            %>
                        <td style="text-align: center;">
                            <%
                                TouchscreenShared.NavButton("../../images/touchscreen/Info.gif", "A PROBLEM occurred", "RecordInfusionProblemAdministration()", blnEnabledState)
                            %>                            
                        </td>
                        <td style="text-align: right;">
                            <%
                                TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/InfusionChange.gif", "Flow Rate Changed", "RecordFlowRateChangedAdministration()", blnEnabledState)
                            %>                            
                        </td>
                            <% 
                            Else
                            %>
                        <td style="text-align: right;">
                            <%
                                TouchscreenShared.NavButton("../../images/touchscreen/Info.gif", "A PROBLEM occurred", "RecordInfusionProblemAdministration()", blnEnabledState)
                            %>                            
                        </td>
                        <% 
                        End If
                        %>
                        <%
                        Else
                        %>
                        <td style="text-align: left;">
                            <%
                                Dim enableStart As Boolean = Not (dssCheckResult = "fail_stop")
                                If enableStart And blnEnabledState = False
                                    enableStart = False
                                End If
                                TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/InfusionStarted.gif", "Infusion Started", "RecordInfusionStartedAdministration()", enableStart)
                            %>
                        </td>
                        <td style="text-align: right;">
                            <%
                                TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/InfusionEnd.gif", "NOT Administered", "RecordNonAdministration()", blnEnabledState)
                            %>
                        </td>
                        <%
                        End If

                    ElseIf bLongDurationBased Then

                        If bInProgress Then
                        %>
                        <td style="text-align: left;">
                            <%
                                TouchscreenShared.NavButton("../../images/touchscreen/Info.gif", "A PROBLEM occurred", "RecordInfusionProblemAdministration()", blnEnabledState)
                            %>
                        </td>
                        <td style="text-align: right;">
                            <%
                                TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/InfusionEnd.gif", "Infusion Ended", "RecordInfusionEndedAdmnistration()", blnEnabledState)
                            %>
                        </td>
                        <% 
                        ElseIf IsPrescriptionWithinPrescribeTimeWindow(dtDue, lngDueMinutes, lngMaxMinutesEarly, lngEarlyMode, blnPrn) And IsWhenRequiredPrescriptionInTimeWindow(dtDue, blnPrn, prnMaxMinutesEarly) Then
                        %>
                        <td style="text-align: left;">
                            <%
                                TouchscreenShared.NavButton("../../images/touchscreen/DrugAdministration/InfusionEnd.gif", "NOT Administered", "RecordNonAdministration()", blnEnabledState)
                            %>
                        </td>
                        <td style="text-align: right;">
                            <%
                                Dim enableStart As Boolean = Not (dssCheckResult = "fail_stop")
                                If enableStart And blnEnabledState = False
                                    enableStart = False
                                End If
                                TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Started", "RecordInfusionStartedAdministration()", enableStart)
                            %>
                        </td>
                        <% 
                        Else
                        %>
                            <td style="text-align: right;">
                            <%
                                'Dose is too far in the future; we don't allow them to record administration yet.
                                TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "OK", "Navigate('" & referingUrl & "')", True)
                            %>
                        </td>
                        <% 
                        End If
                        %>
                        <%
                        Else
                            If IsPrescriptionWithinPrescribeTimeWindow(dtDue, lngDueMinutes, lngMaxMinutesEarly, lngEarlyMode, blnPrn) And IsWhenRequiredPrescriptionInTimeWindow(dtDue, blnPrn, prnMaxMinutesEarly) Then
                        %>
                        <td style="text-align: left;">
                            <%
                                TouchscreenShared.NavButton("../../images/touchscreen/Cross.gif", "NOT Administered", "RecordNonAdministration()", blnEnabledState)
                            %>
                        </td>
                        <td style="text-align: right;">
                            <%
                                Dim enableAdmin As Boolean = Not (dssCheckResult = "fail_stop")
                                If enableAdmin And blnEnabledState = False
                                    enableAdmin = False
                                End If
                                
                                If strSupervisedAdmin = "1" Then
                                    TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Supervised self-administered CORRECTLY", strAdminAction, enableAdmin)
                                Else
                                    TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "Administered CORRECTLY", strAdminAction, enableAdmin)
                                End If
                            %>
                        </td>
                        <td style="text-align: center;">
                            <%
                                '
                                'For partials; go to reason picker page; then onto product picker page, where they can
                                'optionally enter any drugs which were used
                                'Move arbtextid_reason onto Administration table.
                                'Add NotGiven bit
                                'Add Partial bit
                                '
                                'both to Administration table.
                                '
                                'Remove AdministrationNodeDone table and requesttype
                                TouchscreenShared.NavButton("../../images/touchscreen/Info.gif", "A PROBLEM occurred", "RecordPartialAdministration()", blnEnabledState)
                            %>
                        </td>
                        <%
                        Else 'Shouldn't ever get here but I'll leave it in just in case!
                        %>
                        <td style="text-align: right;">
                            <%
                                'Dose is too far in the future; we don't allow them to record administration yet.
                                TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "OK", "Navigate('" & referingUrl & "')", True)
                            %>
                        </td>
                        <%
                        End If
                        %>
                        <%
                        End If
                        %>
                        <%
                        Else
                        %>
                        <td style="text-align: right;">
                            <%
                                TouchscreenShared.NavButton("../../images/touchscreen/Tick.gif", "OK", "Navigate('" & destinationUrl & "')", True)
                            %>
                        </td>
                        <%
                        End If
                        %>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>

