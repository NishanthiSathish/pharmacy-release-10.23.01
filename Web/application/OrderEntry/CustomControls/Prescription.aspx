<%@ Page language="vb" %>

<%@ Import Namespace="Ascribe.Xml" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Constants" %>
<%@ Import Namespace="Ascribe.Common.Prescription" %>
<%@ Import Namespace="Ascribe.Common.OrderForm" %>
<%@ OutputCache Location="None" VaryByParam="None" %>

<%-- 
LM Code 162, 10/01/2008 ,
Removed Reference to "PrescriptionStandard.vb, PrescriptionAsk.vb, PrescriptionCommon.vb, Prescription.vb.vb
Imported the namespaces Ascribe.Common.Constants, Ascribe.Common.Prescription, Ascribe.Common.OrderForm

--%>

<script src="../../sharedscripts/ocs/OCSConstants.js" type="text/javascript"></script>
<%--
    LM 13/11/2007 Code 103 adding a reference to PrescriptionCommon.vb
--%>

<%
    Dim SYSTEM_OCS As String = String.Empty
    Dim SECTION_PRESCRIBING As String = String.Empty
    Dim KEY_COPY_DISPENSING_INSTR As String = String.Empty
    Dim DEFAULT_COPY_DISPENSING_INSTR As String = String.Empty
	'------------------------------------------------------------------------------------------------
	'
	'Prescription.aspx
	'
	'Custom Control for Order Entry, for entering prescriptions.
	'
	'
	'Modification History:
	'27Feb03 AE  Written
	'22May03 AE  Ongoing development; added SetStartDate method for protocols
	'27Feb04 PH  Modification due to resizing changes in order entry
	'Sep04 AE  Restructured HTML to use table layout, as it made things less complex in the code for
	'showing/hiding sections of the form.
	'04Oct04 AE  Added ValidationCheck() method for #76563
	'03Oct05 AE  Added escape keydown handler to close the form.
	'Nov05 AE  The paradigm has now shifted far away from the original design of populating on the client
	'to allow the use of client side functions (which have never been implemented anyway),
	'that this page, along with the rest of orderentry, is due an overhaul
	' //LM 22/11/2007 Declaring variables explicitly
    '27May08 AE  Moved declaration above the point where the variables are actually used.
    '12Nov10   Rams    F0101107 - the field on the order-comms screen should default to blank
    '12Nov10    Rams    F0101257 - treatment reasons not available in template editor
	'------------------------------------------------------------------------------------------------
	Const PAGEMODE_STANDARD As Integer = 1
	Const PAGEMODE_ASKINFUSION As Integer = 10
	Const PAGEMODE_INFUSION As Integer = 20
	Const REQUESTTYPE_INFUSION As String = "Infusion Prescription"
	Const REQUESTTYPE_DOSELESS As String = "Doseless Prescription"
	Const PRODUCTTYPEID_CHEMICAL As Integer = 1
	Const ITEM_WIDTH As String = "150px"
	'Width of each attribute title down the left hand side of the form
	Const READONLYIMAGE_WIDTH As String = "20px"
    Dim SessionID As Integer
	Dim objDoseUnitRowXML As XmlDocument
    Dim strDoseUnitRow As String = String.Empty
	Dim DOMRequestTypes As XmlDocument
	Dim objRequestType As XmlElement
    Dim DOMItemData As XmlDocument = Nothing
	Dim colTimeUnits As XmlNodeList
    
    Dim objUnit As XmlElement = Nothing
	Dim xmlAttributeElement As XmlElement
	'XML Objects used for reading/scripting the various unit boxes
    Dim objRoutes As XmlElement = Nothing
	Dim objReviewRequests As XmlElement
    Dim objSchedule As XmlElement
    Dim strProductName As String = String.Empty
	Dim strProductForm As String
	Dim ProductID As Object
	Dim blnDisplay As Object
	Dim blnTemplateMode As Boolean
	Dim blnDoseless As Boolean
	Dim blnInfusion As Boolean
	Dim blnShowOtherRoutes As Boolean
	Dim blnShowRoutines As Boolean
	Dim blnAskInfusion As Boolean
	Dim blnNewItem As Boolean
	Dim blnInfusionAvailable As Boolean
	Dim strImmediateText As String
	Dim lngProductTypeID As Integer
	Dim lngTempIndex As Integer
	'To hold temporary tab index values when scripting
    Dim strDoseCalculation_XML As String = String.Empty
	Dim strRateCalculation_XML As String
	Dim strRoutineDescription As Object
	'Used to hold the description of the dss routine used for dose calculation
	Dim strRequestType_XML As String
	Dim blnDoCalculation As Boolean
	Dim blnIsCalculatedDose As Boolean
	Dim dblCalculatedDose As Object
	Dim dblCalculatedDoseLow As Double
	Dim lngCalculatedUnitID As Integer
	Dim blnCalculationSuccess As Boolean
	Dim blnNoFrequency As Boolean
	'Used in PrescriptionCommon.aspx; set it to false if you do not want the frequency & PRN controls scripted
	Dim blnProductIsDoseless As Boolean
	Dim lngUnitID_Dose As Integer
	Dim lngRoutineID As Integer
	Dim lngTableID As Integer
	Dim strRequestType As Object
	Dim lngItemID As Object
	Dim strDateFormat As String
	'Some time in the far future, this will be read from the db based on a setting.
	Dim strIsTemplateMode As String
	Dim pageMode As Integer
	Dim strOnLoad As String
	'If we are self-refreshing (ie when adding/removing a product), then this holds the onload event handler
	Dim dblRoundTo As Integer
	'In template mode, specifies an increment to round to
	Dim lngRoundToUnitID As Integer
    
	Dim dblDoseCap As Integer
	Dim lngDoseCapUnitID As Integer
	Dim blnDoseCap_CanOverride As Integer
    
	'The unit in which the above is expressed
	Dim strEditable_HTML As String
	'In template mode, holds html to specify a "make editable/not editable" image
	Dim strItemData_XML As String
	Dim lngProductRouteID_Selected As Integer
	Dim lngProductRouteID_Parent As Integer
	Dim blnCopyDispensingInstruction As Boolean
	Dim intOrdinal As Integer
    Dim strScheduleForScripting As String = String.Empty
	'11Jul07 ST  For viewing original dose calculations
	Dim lngRequestID As Integer
	Dim lngPendingItemID As Integer
	Dim blnDoseCalculationHistory As Boolean
	Dim strOriginalDose_XML As String
	Dim strOriginalRate_XML As String
    
    Dim blnDescriptionUpdate As Boolean
    
    Dim strDoseCapText As String
    Dim strDoseCapValue As String
    Dim strReevaluteValue As String
    Dim blnDoseReevaluate As Boolean
	Dim strReviewRequest_XML As String
	
	Dim OnSelectWarningLogID As Integer
    
    '17Aug2009 JMei Mandatory prescription durations in out-patients
    Dim objEpisodeRead As ENTDTL10.EpisodeRead
    Dim objSetting As GENRTL10.SettingRead
    Dim strEpisodeType As String
    Dim strDurationValue As String = String.Empty
    Dim blnSingleDose As Boolean = False
    
    Dim intSettingDuration As Integer
    Dim intSettingMandatory As Integer
    Dim intSettingDurationMOD As Integer = 0
    
    Dim objSingleUnit As XmlElement
    Dim xmlAttributeElement_Unit As XmlElement
    Dim xmlAttributeElement_Duration As XmlElement
    
    Dim intUnitID_Week As Integer
    Dim intUnitID_Day As Integer
    Dim strRxAsk As String = ""
    
    '21June2010 F0066673 JMei Put reason capture for prescription back to icw
    Dim blnCopyMode As Boolean
    Dim blnAmendMode As Boolean
    Dim blnDisplayMode As Object
    
    Dim objReasonCapture As XmlElement
    Dim Reason_HTML As String = ""
    
    Dim objReasonDisplay As XmlElement
    Dim ReasonDisplay_HTML As String = ""
    
    '19Apr10 JMei F0082951 Remove Deleted Direction when create new template
    Dim DirectionDeleted As Boolean = False
    '12Nov10    Rams    F0101107 - Prescribing Reason codes should have a blank row as default
    Dim IsReasonCaptureMandatory As Boolean = False
    
    'Validate the session
    'Obtain the session ID from the querystring
    SessionID = CInt(Request.QueryString("SessionID"))
    blnDoseless = False
    blnInfusion = False
    blnShowOtherRoutes = False
    blnShowRoutines = False
    blnAskInfusion = False
    blnNewItem = True
    blnInfusionAvailable = False
    strImmediateText = "Today"
    lngProductTypeID = 0
    lngTempIndex = 0
    strRoutineDescription = ""
    blnDoCalculation = False
    blnIsCalculatedDose = False
    dblCalculatedDose = 0
    dblCalculatedDoseLow = 0
    lngCalculatedUnitID = 0
    blnCalculationSuccess = False
    blnNoFrequency = False
    blnProductIsDoseless = False
    lngUnitID_Dose = 0
    lngRoutineID = 0
    lngTableID = 0
    strRequestType = ""
    lngItemID = 0
    strDateFormat = "dd/mm/yyyy"
    strIsTemplateMode = ""
    strOnLoad = ""
    dblRoundTo = 0
    lngRoundToUnitID = 0
    strEditable_HTML = ""
    strItemData_XML = ""
    lngProductRouteID_Selected = 0
    lngProductRouteID_Parent = 0
    blnCopyDispensingInstruction = False
    lngRequestID = 0
    lngPendingItemID = 0
    blnDoseCalculationHistory = False
    strOriginalDose_XML = ""
    strOriginalRate_XML = ""
    strRateCalculation_XML = ""
    blnDescriptionUpdate = False
    
    strDoseCapText = ""
    strDoseCapValue = ""
    strReevaluteValue = ""
    blnDoseReevaluate = False
    strReviewRequest_XML = ""
    
	
    'Retrieve the product ID and other querystring params
    ProductID = Request.QueryString("ProductID")
    If CStr(ProductID) = "" Then
        ProductID = 0
    End If
    ProductID = CInt(ProductID)
    
    'ID of the table this row lives in / is destined to live in
    lngItemID = Request.QueryString("DataRow")
    If CStr(lngItemID) = "" Then
        lngItemID = 0
    End If
    blnNewItem = (lngItemID <= 0)
    blnDisplay = Request.QueryString("Display")
    If IsDBNull(blnDisplay) Then
        blnDisplay = False
    End If
	blnDisplay = CBool(blnDisplay)
	
	blnDescriptionUpdate = (Request.QueryString("DescriptionUpdate") = "1")
	
    intOrdinal = CInt(Request.QueryString("Ordinal"))
    lngTableID = CInt(Request.QueryString("TableID"))
    
    '21June2010 F0066673 JMei Put reason capture for prescription back to icw
    blnDisplayMode = IIf(String.IsNullOrEmpty(Request.QueryString("Display")), False, LCase(Request.QueryString("Display")) = "true")
    blnCopyMode = IIf(String.IsNullOrEmpty(Request.QueryString("CopyMode")), False, LCase(Request.QueryString("CopyMode")) = "true")
    blnAmendMode = IIf(String.IsNullOrEmpty(Request.QueryString("AmendMode")), False, LCase(Request.QueryString("AmendMode")) = "true")
	'Check if we are in template mode; if so, certain controls are disabled
    blnTemplateMode = CBool(Request.QueryString("Template"))
    
    '20Jul07 PH When creating new items from templates, ProductID is no longer passed on the URL, so we must read it here.
    strItemData_XML = Request.Form("formDataXML")
 
    '17Aug2009 JMei Mandatory prescription durations in out-patients
    'Get a list of time units to populate the duration combo with
    colTimeUnits = GetTimeUnits(SessionID)
    For Each objSingleUnit In colTimeUnits
        If CInt(objSingleUnit.GetAttribute("Multiple") > 60) Then
            Select Case objSingleUnit.GetAttribute("Description").ToString().ToLower()
                Case "day"
                    intUnitID_Day = CInt(objSingleUnit.GetAttribute("UnitID"))
                Case "week"
                    intUnitID_Week = CInt(objSingleUnit.GetAttribute("UnitID"))
            End Select
        End If
    Next
    
	If strItemData_XML = "" Then
		If CInt(lngItemID) > 0 Then
			strItemData_XML = GetDataXML(SessionID, Request.QueryString("DataClass"), False, lngTableID, lngItemID)
			DOMItemData = New XmlDocument()
            DOMItemData.TryLoadXml(CStr(strItemData_XML))
			xmlAttributeElement = DOMItemData.SelectSingleNode("//attribute[@name='ProductID']")
			ProductID = CInt(xmlAttributeElement.GetAttribute("value"))
			xmlAttributeElement = DOMItemData.SelectSingleNode("//attribute[@name='OnSelectWarningLogID']")
			If xmlAttributeElement IsNot Nothing Then
				OnSelectWarningLogID = Integer.Parse(xmlAttributeElement.GetAttribute("value"))
            End If

            '21June2010 F0066673 JMei Put reason capture for prescription back to icw
            objReasonCapture = DOMItemData.SelectSingleNode("root/data/" & Ascribe.Common.Constants.XML_ELMT_REASON)
            '
            '12Nov10    Rams    F0101257 - treatment reasons not available in template editor
            '                   Do not show only for displaymode as the reason will be displayed in status panel
            If Not CBool(blnDisplayMode) Then
                'Reason_HTML = ReasonCaptureControls(lngItemID, objReasonCapture, 0)
                '12Nov10    Rams    It Should be OrderTemplateID and not the row Id
                Reason_HTML = ReasonCaptureControls(DOMItemData.SelectSingleNode("/root/@ordertemplateid").InnerText, objReasonCapture, 0, IsReasonCaptureMandatory, SessionID)
            End If
            
            If blnDisplayMode Then
                objReasonDisplay = DOMItemData.SelectSingleNode("//attribute[@name='reason']")
                If objReasonDisplay IsNot Nothing Then
                    ReasonDisplay_HTML = "<div id='divProblem' class='problem' style='visibility:hidden;'><span>" + objReasonDisplay.GetAttribute("displayname") + "</span><span>" + objReasonDisplay.GetAttribute("value") + "</span></div>"
                End If
            End If
            
            '17Aug2009 JMei Mandatory prescription durations in out-patients
            objEpisodeRead = New ENTDTL10.EpisodeRead()
            strEpisodeType = objEpisodeRead.GetEpisodeTypeBySessionID(SessionID)
            
            'Find if it is single dose which duration is not applied
            xmlAttributeElement = DOMItemData.SelectSingleNode("//attribute[@name='ScheduleTemplateID']")
            If xmlAttributeElement IsNot Nothing Then
                If xmlAttributeElement.GetAttribute("text") = "Single Dose" Then
                    blnSingleDose = True
                End If
            End If
            
            'only need to modify the xml if it is an Out patient episode and not single dose and not a template
            If strEpisodeType = "Out-patient" And blnSingleDose = False And blnTemplateMode = False Then
                
                'Get system setting
                objSetting = New GENRTL10.SettingRead
                intSettingDuration = CInt(objSetting.GetValue(SessionID, "OCS", "Prescribing", "DefaultOutpatientPrescriptionDuration", ""))
                intSettingMandatory = CInt(objSetting.GetValue(SessionID, "OCS", "Prescribing", "MandatoryOutPatientPrescriptionDuration", ""))
                
                'find Duration node if not create a new one
                xmlAttributeElement_Duration = DOMItemData.SelectSingleNode("//attribute[@name='Duration']")
                If xmlAttributeElement_Duration IsNot Nothing Then
                    strDurationValue = xmlAttributeElement_Duration.GetAttribute("value")
                Else
                    xmlAttributeElement_Duration = DOMItemData.CreateElement("attribute")
                    xmlAttributeElement_Duration.SetAttribute("name", "Duration")
                    xmlAttributeElement_Duration.SetAttribute("value", "")
                    xmlAttributeElement_Duration.SetAttribute("text", "")
                    xmlAttributeElement_Duration.SetAttribute("readonly", "false")
                    xmlAttributeElement_Duration.SetAttribute("mandatory", "0")
                    xmlAttributeElement_Duration.SetAttribute("value_orig", "")
                    DOMItemData.SelectSingleNode("//data").AppendChild(xmlAttributeElement_Duration)
                End If
                
                If intSettingMandatory = 1 Then
                    xmlAttributeElement_Duration.SetAttribute("mandatory", "1")
                End If
                
                If strDurationValue = String.Empty Or strDurationValue = "0" Then
                    'find Unit node (days, weeks....) if not create a new one
                    xmlAttributeElement_Unit = DOMItemData.SelectSingleNode("//attribute[@name='UnitID_Duration']")
                    If xmlAttributeElement_Unit Is Nothing Then
                        xmlAttributeElement_Unit = DOMItemData.CreateElement("attribute")
                        xmlAttributeElement_Unit.SetAttribute("name", "UnitID_Duration")
                        xmlAttributeElement_Unit.SetAttribute("value", "")
                        xmlAttributeElement_Unit.SetAttribute("text", "")
                        xmlAttributeElement_Unit.SetAttribute("value_orig", "")
                        DOMItemData.SelectSingleNode("//data").AppendChild(xmlAttributeElement_Unit)
                    End If
                    
                    If intSettingDuration > 0 And intSettingDuration < 7 Then
                        xmlAttributeElement_Duration.SetAttribute("value", intSettingDuration.ToString())
                        xmlAttributeElement_Unit.SetAttribute("value", intUnitID_Day)
                        xmlAttributeElement_Unit.SetAttribute("text", "days")
                        
                    ElseIf intSettingDuration >= 7 Then
                        intSettingDurationMOD = intSettingDuration Mod 7
                        If intSettingDurationMOD = 0 Then
                            xmlAttributeElement_Duration.SetAttribute("value", (intSettingDuration / 7).ToString())
                            xmlAttributeElement_Unit.SetAttribute("value", intUnitID_Week)
                            xmlAttributeElement_Unit.SetAttribute("text", "weeks")
                        Else
                            xmlAttributeElement_Duration.SetAttribute("value", intSettingDuration.ToString())
                            xmlAttributeElement_Unit.SetAttribute("value", intUnitID_Day)
                            xmlAttributeElement_Unit.SetAttribute("text", "days")
                        End If
                    End If

                End If
                strItemData_XML = DOMItemData.OuterXml
            End If
        End If
    Else
        'blnPopulateForm = True																					'28May08 AE  Removed flag as no longer used
        DOMItemData = New XmlDocument()
        DOMItemData.TryLoadXml(CStr(strItemData_XML))
    End If
    
    'Check if we are in template mode; if so, certain controls are disabled
    'blnTemplateMode = CBool(Request.QueryString("Template"))
    If blnTemplateMode Then
        strIsTemplateMode = "true"
        'String because vb's "True" does not equate to js's "true"
        strEditable_HTML = GetEditableControlHTML()
    Else
        strIsTemplateMode = "false"
    End If
    blnShowRoutines = blnTemplateMode
    'We don't show the calculation routines unless we are in template mode
    'Read the product's form
    strProductForm = GetProductForm(SessionID, ProductID)
    'Read a list of all available prescription request types, in case the user does something
    'which requires us to change.																																'16Sep04 AE  Added
    strRequestType_XML = GetPrescriptionRequestTypes(SessionID)
    'Check if we have to ask if we're doing an infusion.
    blnInfusionAvailable = InfusionAvailable(SessionID, ProductID, strProductForm)
    '14Mar06 AE  And unmodified for doseless injections  08Apr05 AE  Modified to only check InfusionAvailable if in template mode, to increase speed when not in template mode (changed AND to THEN)
    blnAskInfusion = (blnInfusionAvailable And (LCase(Request.QueryString("ask")) <> "false"))
    blnAskInfusion = (blnAskInfusion And blnNewItem)
    'Don't ask if we're editing a template or item, as we'll have already chosen.
    'Now we can determine which page to show.
    pageMode = PAGEMODE_STANDARD
	
    If OnSelectWarningLogID <= 0 Then
        If Not Integer.TryParse(Request.QueryString("OnSelectWarningLogID"), OnSelectWarningLogID) Then
            OnSelectWarningLogID = -1
        End If
    End If
    'Compare the ocstype we've been passed with the Request Type definitions, to determine
    'which form we should load.
    DOMRequestTypes = New XmlDocument()
    DOMRequestTypes.TryLoadXml(strRequestType_XML)
    objRequestType = DOMRequestTypes.SelectSingleNode("//RequestType[@TableID='" & lngTableID & "']")
    strRequestType = objRequestType.GetAttribute("Description")
    If LCase(strRequestType) = LCase(REQUESTTYPE_INFUSION) Then
        blnAskInfusion = False
        pageMode = PAGEMODE_INFUSION
    End If
    If blnAskInfusion Then
        pageMode = PAGEMODE_ASKINFUSION
    End If
    blnInfusion = (pageMode = PAGEMODE_INFUSION)
    blnDoseless = (CStr(strRequestType) = REQUESTTYPE_DOSELESS)
    If blnDoseless And blnInfusionAvailable Then
        blnInfusion = True
    End If
    '14Mar06 AE  If we're doing a doseless prescription for an injection, set blnInfusion so that we retrieve the correct routes.
    'Return common data
    If pageMode <> PAGEMODE_ASKINFUSION Then
        'get a 'Doses' unit for 'duration by number of doses' thing
        strDoseUnitRow = GetDosesRow(SessionID)
        objDoseUnitRowXML = New XmlDocument()
        objDoseUnitRowXML.TryLoadXml(strDoseUnitRow)
        'Check if we are in read-only mode.  If so we call SetReadOnly which lives
        'in OrderFormFunctions.js
        'If blnDisplay Then
        'Response.write "<script language=javascript defer>void SetReadOnly();</script>"
        'End if
        'Get a list of routes.  If this is a new order or template , we return the approved routes;
        'otherwise we bring them all back so that we have the one the user actually picked.
        If Not (DOMItemData Is Nothing) Then
            'Indicates that we are editing an existing item.
            'Infusions have a zero productID, as the products are stored in the ProductIngredient table
            If pageMode <> PAGEMODE_INFUSION Then
                GetProductDetails(SessionID, ProductID, strProductName, blnProductIsDoseless, lngProductTypeID)
                '24Sep04 AE  Changed to return the doseless flag as well as the name
                blnDoseless = blnDoseless Or blnProductIsDoseless
                '05Apr06 AE  Prevent doseless flag which is set manually being overwritten
            End If
            'Editing pending items, viewing committed items
            '20Jul07 PH See comment above of same date
            'strItemData_XML = GetDataXML(SessionID, Request.Querystring("DataClass"), False, lngTableID, lngItemID)
            'Set DOMItemData = Server.CreateObject("XmlDocument")
            'DOMItemData.TryLoadXml strItemData_XML
            xmlAttributeElement = DOMItemData.SelectSingleNode("//attribute[@name='ProductRouteID']")
            If Not xmlAttributeElement Is Nothing Then
                lngProductRouteID_Selected = xmlAttributeElement.GetAttribute("value")
                If XmlExtensions.AttributeExists(xmlAttributeElement.GetAttribute("value_parent")) Then '//LM 22/11/2007 Code 143 Added Is DBNull Check
                    lngProductRouteID_Parent = xmlAttributeElement.GetAttribute("value_parent")
                End If
            End If
            '19Jul07 PH Extract schedule data
            objSchedule = DOMItemData.SelectSingleNode("root/Schedule")
            If Not objSchedule Is Nothing Then
                strScheduleForScripting = "<root>" & objSchedule.OuterXml & "</root>"
            End If


            ' If we are editing a pending item or viewing a request then we grab
            ' the id from the data for later use.
            xmlAttributeElement = DOMItemData.SelectSingleNode("/root")
            If Not xmlAttributeElement Is Nothing Then
                '02-11-2007 Error code 29
                If XmlExtensions.AttributeExists(xmlAttributeElement.GetAttribute("class")) AndAlso xmlAttributeElement.GetAttribute("class") = "request" Then
                    lngRequestID = xmlAttributeElement.GetAttribute("id")
                End If
			
                If XmlExtensions.AttributeExists(xmlAttributeElement.GetAttribute("class")) AndAlso xmlAttributeElement.GetAttribute("class") = "pending" Then
                    lngPendingItemID = xmlAttributeElement.GetAttribute("id")
                End If
            End If
            xmlAttributeElement = Nothing

            If lngRequestID > 0 Then
                strReviewRequest_XML = GetReviewRequestXML(SessionID, lngRequestID)
            End If
            
            If Not CDbl(blnDisplay) Then
                'We'll need em all, unfortunately, as the change report needs to be able to look up the old unit.
                objRoutes = GetAllRoutes(SessionID, ProductID, strProductForm, blnInfusion, blnDoseless)
                '05Apr06 AE  Changed OR to XOR.  Fixes #SC-06-0456, at the expense of showing non-approved routes when a template is reloaded.
            Else
                'Display mode,just return the selected route
                objRoutes = GetRouteSingle(SessionID, lngProductRouteID_Selected)
            End If
        Else
            'New items/templates
            GetProductWithApprovedRoutes(SessionID, ProductID, blnInfusion, blnDoseless, strProductName, blnDoseless, lngProductTypeID, objRoutes)
        End If
    End If
    objReviewRequests = GetReviewRequests(SessionID)
    If Not blnNewItem And CBool(Not CDbl(blnDisplay)) Then
        '13Mar07 AE  Added setting for copy dispensing instruction
        'Copy mode; check the "copy dispensing instruction" setting.
        blnCopyDispensingInstruction = (CStr(Generic.SettingGet(SessionID, SYSTEM_OCS, SECTION_PRESCRIBING, KEY_COPY_DISPENSING_INSTR, DEFAULT_COPY_DISPENSING_INSTR)) = "1")
    End If
    If blnDoseless Then
        'Doseless prescriptions begin life as standard ones, so the requesttype id might not be the one we want!
        strRequestType = REQUESTTYPE_DOSELESS
    End If
    '11Jan05 AE  When reloading templates, the request type is set, but gets overridden by blnDoseless based on the product.  Ensure both are in sync
    blnDoseless = (CStr(strRequestType) = REQUESTTYPE_DOSELESS)
	
    If blnDescriptionUpdate Then strOnLoad = strOnLoad & "DescriptionUpdate(" & lngItemID & ");" '27May08 AE  Update description if we've modified the diluent of a committed prescription, then close the window.
    
    ' Update the ArbText xml as may of been logically deleted (so don't display)
    ' 19Apr10 JMei F0082951 still display deleted direction for created template

    If Not blnDisplay And Not DOMItemData Is Nothing And blnTemplateMode Then
        Dim objArbText As Object = New OCSRTL10.ArbitraryTextRead
        ' Check Direction text
        Dim xmlArbText As Object = DOMItemData.SelectSingleNode("//data/attribute[@name=""ArbTextID_Direction""]")
        If Not xmlArbText Is Nothing Then
            Dim lngArbTextID As Integer = Generic.CIntX(xmlArbText.GetAttribute("value"))
            If (lngArbTextID <> 0) AndAlso objArbText.IsArbTextDeleted(SessionID, lngArbTextID) Then
                'xmlArbText.SetAttribute("value", "0")
                'xmlArbText.SetAttribute("text", "")
                DirectionDeleted = True
                strItemData_XML = DOMItemData.OuterXml
            End If
            
            ' Check Supplimentary text
            xmlArbText = DOMItemData.SelectSingleNode("//data/attribute[@name=""SupplimentaryText""]")
            ' 13Oct08 ST
            ' F0035498 - check for object not being set
            If Not xmlArbText Is Nothing Then
                lngArbTextID = Generic.CIntX(xmlArbText.GetAttribute("value"))
                If (lngArbTextID <> 0) AndAlso objArbText.IsArbTextDeleted(SessionID, lngArbTextID) Then
                    'xmlArbText.SetAttribute("value", "0")
                    'xmlArbText.SetAttribute("text", "")
                    DirectionDeleted = True
                    strItemData_XML = DOMItemData.OuterXml
                End If
            End If
        End If
    End If

    If DirectionDeleted = True Then
        strOnLoad = strOnLoad & "RemoveDeletedDirection();"
    End If
    
    ' 02/02/2010 CD F0073094 When in template mode if we go straight to the form, rather than through
    ' the prescription ask screen we need to behave as if we have been through the ask screen so that
    ' forms are populated correctly, therefore the rxask attribute needs to be false
    If blnTemplateMode Then
        strRxAsk = Request.QueryString("ask")
        If strRxAsk Is Nothing Then
            If pageMode <> PAGEMODE_ASKINFUSION Then
                strRxAsk = "false"
            End If
        End If
    End If
    
%>

<%--
LM Error Code 107 Removed ununsed script tag
--%>

<html>
<head>

<script language="javascript" src="../../sharedscripts/ocs/ocsConstants.js"></script>
<script language="javascript" src="../scripts/OrderFormControls.js"></script>
<script language="javascript" src="../../sharedscripts/Controls.js"></script>
<script language="javascript" src="../../sharedscripts/ocs/OCSShared.js"></script>
<script language="javascript" src="../../sharedscripts/icwFunctions.js"></script>
<script language="javascript" src="../../sharedscripts/DateLibs.js"></script>
<script language="javascript" src="CustomControlShared.js"></script>
<script language="javascript" src="../../sharedscripts/PickList.js"></script>
<script language="javascript">

var m_blnTemplateMode = <%= strIsTemplateMode %> ;											//Determines if we are in template mode or not

//===========================================================================
//							Public Methods
//===========================================================================

function Populate(strItemData_XML) {

//Standard Populate method, called from the hosting form
	void PopulateForm(strItemData_XML);
	void InitRxForm();
}

//===========================================================================

function GetDataFromForm()
{
	return GetData();
}

//===========================================================================

function GetData() {

//Standard method to read data from this control.
//Called from the hosting form to retrieve data
//Returns XML elements as follows:
//			<attribute name="" value="" />

	return ReadDataFromForm();
}

//===========================================================================

function ValidityCheck() {

//Standard method which can be used to indicate if the data in the form is valid, and to
//allow the saving process to be stopped if not.

	switch (document.body.getAttribute('requesttype')) {
		case REQUESTTYPE_STANDARD:
			return ValidityCheck_Standard();
			break;

		case REQUESTTYPE_DOSELESS:
			return ValidityCheck_Standard();
			break;

		case REQUESTTYPE_INFUSION:
			return ValidityCheck_Infusion();
			break;
	}
}

//===========================================================================
function FilledIn() {

	switch (document.body.getAttribute('requesttype')) {
		case REQUESTTYPE_STANDARD:
			return FilledIn_PrescriptionStandard();
			break;

		case REQUESTTYPE_DOSELESS:
			return FilledIn_PrescriptionStandard();														//10Feb05 AE  ...Errr...really this time 04Feb05 AE  Corrected
			break;

		case REQUESTTYPE_INFUSION:
			return FilledIn_PrescriptionInfusion();
			break;
	}
}

//===========================================================================
function SetStartDate(objDate, blnImmediate){
//05Aug04 AE  Replace missing method; 
//27Oct04 PH  Set Combo to "Choose Date" if the date has been set by the container, 
//				  unless it's been set to "today"
//07Sep05 ST  Set StartTime to time section of passed date object

	var objDateControl = new DateControl(txtStartDate);
	var datToday = new Date();
	var strHours = "";
	var strMinutes = "";
	var strTime = "";
	
	objDateControl.SetDate(objDate);

	// 07Sep05 ST	Added to allow starttime to get put on form
	strHours = objDate.getHours().toString();																	//12Aug04 AE  Fix; prevents 12:05 appearing as 12:5
	if(strHours.length ==1) {strHours = '0' + strHours};
	strMinutes = objDate.getMinutes().toString();
	if (strMinutes.length ==1) {strMinutes = '0' + strMinutes};
	strTime +=  strHours + ':' + strMinutes;
	
	txtStartTime.value = strTime;

	if (blnImmediate)
	{
	    document.getElementById("lstSchedule").selectedIndex = 0; // Immediate
	    ToggleStartDate(objDate);
	}
	else
	{
	    document.getElementById("lstSchedule").selectedIndex = 1; // Schedule (choose date)
	    ToggleStartDate();
	    UpdateStopDate();
	}


//	if ( objDate.getFullYear()!=datToday.getFullYear() || objDate.getMonth()!=datToday.getMonth() || objDate.getDate()!=datToday.getDate() )
//	{
//		document.getElementById("lstSchedule").selectedIndex = 1; // Schedule (choose date)
//		ToggleStartDate();
//		UpdateStopDate();																													//11Apr05 AE  Ensure that the stop date is updated
//	}
}
//===========================================================================
</script>
<script language="javascript" type="text/javascript" src="Prescription.js"></script>
<link rel="stylesheet" type="text/css" href="../../../style/OrderEntry.css">
<link rel="stylesheet" type="text/css" href="../../../style/application.css">
</head>
<body 
		onload="window_onload();<%=strOnload %>"
		id="formBody" 
		sid="<%= SessionID %>" 
		ordinal="<%= intOrdinal %>"
		frameid="<%= CStr(Request.QueryString("FrameID")) %>"		
		controlid="<%= CStr(Request.QueryString("ControlID")) %>" 
		displaymode="<%= LCase(CStr(blnDisplay)) %>"
		doseless="<%= LCase(CStr(blnDoseless)) %>"
		requesttype="<%= CStr(strRequestType) %>"
		dataclass="<%= CStr(Request.QueryString("Dataclass")) %>"
		onselectwarninglogid="<%= OnSelectWarningLogID.ToString() %>"
		copydispensinginstruction="<%= LCase(CStr(blnCopyDispensingInstruction)) %>"
		onkeydown="if (window.event.keyCode == 27) window.parent.CloseWindow(true);"
		class="OrderFormBody PrescriptionBody" 
		onunload="Local_CloseReferenceWindow();CloseFieldHintsWindow();"
		rxask="<%=Lcase(strRxAsk) %>"
		istemplatemode="<%=strIsTemplateMode%>"
		isreasoncapturemandatory="<%=IsReasonCaptureMandatory.ToString().ToLower() %>"
>

<%
    '// LM Code 162, 10/01/2008, Variables not declared earlier? Check in VB6
    Dim dblDoseCap_Converted As Double = 0
    Dim FromUnitName_OUT As String = ""
    Dim strDoseCapUnitName_Converted As String = ""

    'Determine which page of HTML to include.  Infusions, the Ask Infusion page, and the standard/doseless
    'page have been split into separate files for simplicity's sake.
    Select Case pageMode
        Case PAGEMODE_STANDARD
            '//LM 13/11/2007 Code 102 passing parameters , 10/01/2008 LM  Code 102,  Added more parameters, LM 28/01/2007 Code 162 Moved code to a Function in Prescription.vb file in app_code F0022794 LM 15/05/2008 blnShowRoutines
            PrescriptionStandard(SessionID, ProductID, lngProductRouteID_Selected, lngProductTypeID, blnTemplateMode, strDoseCalculation_XML, lngUnitID_Dose, lngRoutineID, dblRoundTo, lngRoundToUnitID, PRODUCTTYPEID_CHEMICAL, lngProductRouteID_Parent, objRoutes, blnDisplay, strEditable_HTML, lngTableID, strRoutineDescription, strProductForm, strProductName, blnDoseless, READONLYIMAGE_WIDTH, dblDoseCap, strItemData_XML, lngPendingItemID, dblDoseCap_Converted, FromUnitName_OUT, strDoseCapUnitName_Converted, blnDoseCap_CanOverride, blnShowRoutines, blnDoseReevaluate, strDoseCapText, strDoseCapValue, strReevaluteValue, lngRequestID)               'Standard and Doseless prescribing form
            
            '//LM 13/11/2007 Code 103 Calling PrescriptionCommon From the aspx page, calling from the code page was not working, , 10/01/2008 LM  Code 102,  Added more parameters, LM 28/01/2007 Code 162 Moved code to a Function in Prescription.vb file in app_code
            PrescriptionCommon(SessionID, colTimeUnits, objReviewRequests, blnNoFrequency, blnDisplay, READONLYIMAGE_WIDTH, strEditable_HTML, ITEM_WIDTH, blnDoseless, strDateFormat, strImmediateText, strDoseUnitRow, strOriginalRate_XML, blnTemplateMode, lngTableID, objRoutes, strOriginalDose_XML, strReviewRequest_XML, lngRequestID)
        
        Case PAGEMODE_INFUSION
            'Infusion , LM 28/01/2007 Code 162 Moved code to a Function in Prescription.vb file in app_code
            PrescriptionInfusion(SessionID, lngItemID, strItemData_XML, strProductName, ProductID, colTimeUnits, blnTemplateMode, strEditable_HTML, lngTableID, objRoutes, lngProductRouteID_Parent, lngProductRouteID_Selected, blnDisplay, lngRoutineID, blnDoCalculation, blnCalculationSuccess, blnIsCalculatedDose, strRoutineDescription, strDoseCalculation_XML, dblCalculatedDose, strOriginalDose_XML, blnDoseCalculationHistory, lngRequestID, dblRoundTo, strRateCalculation_XML, objUnit, blnNoFrequency, strImmediateText, strOriginalRate_XML, objReviewRequests, blnDoseless, strDateFormat, strDoseUnitRow, lngRoundToUnitID, ITEM_WIDTH, READONLYIMAGE_WIDTH, dblDoseCap, lngDoseCapUnitID, blnDoseCap_CanOverride, lngUnitID_Dose, dblDoseCap_Converted, FromUnitName_OUT, strDoseCapUnitName_Converted, lngPendingItemID, blnDoseReevaluate, strDoseCapText, strDoseCapValue, strReevaluteValue, strReviewRequest_XML)
                   
        Case PAGEMODE_ASKINFUSION
            'Simple Infusion/Not Infusion page
            'If we are in template mode then check that the selected product is a diluent or not
            If blnTemplateMode Then
                If ItemIsDiluent(SessionID, ProductID) = True Then
                    PrescriptionAsk(True)
                Else
                    PrescriptionAsk(False)
                End If
            End If
            
    End Select
    
    '21June2010 F0066673 JMei Put reason capture for prescription back to icw
    If Reason_HTML <> "" Then
        Response.Write(Reason_HTML)
        Response.Write("<br/>")
    End If
    
    '12Nov10    Rams    F0101257 - Do not show only for displaymode as the reason will be displayed in status panel
    '15Nov10    Rams    Now testing needs this duplicate information, for some crap reasons
    If blnDisplayMode And ReasonDisplay_HTML <> "" Then
        Response.Write(ReasonDisplay_HTML)
        Response.Write("<br/>")
    End If
    
    If CBool(blnDisplay) And pageMode <> PAGEMODE_ASKINFUSION Then
        '09May06 AE  moved here from above.  Despite the defer attribute, this would sometimes fire before the page was finished scripting.
        Response.Write("<script language=javascript defer>void SetReadOnly();</script>")
    End If
%>


<%-- Holds the header of the layout with size information etc --%>
<xml id=layoutData>
	<xmldata formid="<%= CStr(Request.QueryString("FrameID")) %>" >
		<layout tableid="<%= lngTableID %>" />
	</xmldata>
</xml>

<!-- Holds the scedule XML attached to this item -->
<xml id=scheduleData>
<%= strScheduleForScripting %>
</xml>

<!-- XML Island to hold the various prescription request types, used for switching on the fly -->
<xml id="requesttypeData">
<%= strRequestType_XML %>
</xml>

<!-- XML Island used for parsing incomming data -->
<xml id="instanceData">
<%= strItemData_XML %>
</xml>

<!-- XML Island for parsing the 'track changes' document -->
<xml id="changesData"></xml>

<!-- General use XML -->
<xml id='tempXML' />

<!-- Script to position the reason capture section when percentage sizing is used -->
<script language="javascript" type="text/javascript">
var m_blnDone = false;
function PositionProblemDiv(){
	if (document.all['divProblem'] != undefined && !m_blnDone) {
		//Problem controls are hidden until positioned
	    document.all['divProblem'].style.visibility = 'visible';
		m_blnDone = true;
	}
}
</script>

</body>
</html>
<script language="vb" runat="server">
    
	'17-Jan-2008 This function is not called anywhere in this module - so we are not sure if it is really needed in the first place
	' - it's a debug procedure that was used to determine performance bottlene
    Sub DisplayTimer(ByVal strText As Object) '//LM 28/01/2008 Code 162, Changed method from function to sub... nothing was being returned.
        Response.Write(strText & ": " & DateAndTime.Timer & "<br/>")
    End Sub

</script>
