Imports System.Xml
Imports Ascribe.Common.Generic
Imports Ascribe.Common.DrugAdministration
Imports Ascribe.Common.DrugAdministrationConstants

Partial Class application_DrugAdministration_AdministrationPrescriptionDetail
    Inherits Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
    End Sub

    Public Sub ScriptAttrValue(ByVal dom As XmlNode, ByVal attributeName As String, ByVal caption As String, ByVal blnSeparateRow As Boolean, ByVal colSpan As Integer, ByRef sUnitDescription As String, Optional ByVal scriptGenericTemplateWarning As Boolean = False)
        Dim strValue As String

        strValue = CStr(GetXMLExpandedValue(dom, attributeName))

        If strValue <> "" Then
            If blnSeparateRow Then
                Response.Write("<tr>")
            End If

            If caption <> "" Then
                Response.Write("<td class='AttrName'>" & caption & "</td>" & vbCr)
            End If

            If Left(attributeName, 6) = "UnitID" Then
                strValue = strValue & "(s)"
                If sUnitDescription.Trim() = "" Then
                    sUnitDescription = strValue
                End If
            End If

            If (attributeName = "ProductFormID_Dose") Then
                strValue = strValue & "(s)"
            End If

            If Not scriptGenericTemplateWarning Then
                Response.Write("<td class='AttrValue' colspan='" & colSpan & "' >" & strValue & "</td>" & vbCr)
            Else
                '11May11    Rams    F0117182 - Items on the Drug Admin screen for free text prescriptions
                Dim intPos As Integer = InStr(strValue, ":")
                Dim sDrugName As String
                If intPos > 0 Then
                    sDrugName = RTrim(Mid(strValue, 1, intPos - 1))
                    sDrugName = Mid(sDrugName, "FREETEXT PRESCRIPTION - ".Length() + 1)
                    Response.Write("<td class='AttrValue' colspan='" & colSpan & "' >" & sDrugName & "</td>" & vbCr)
                End If
            End If
            '
            If blnSeparateRow Then
                Response.Write("</tr>")
            End If

            If scriptGenericTemplateWarning Then
                Response.Write("<tr>")
                Response.Write("<td class='AttrName'></td>" & vbCr)
                Response.Write("<td class='AttrValue Sad' colspan='" & colSpan & "' >(No decision support checking will be provided).</td>" & vbCr)
                Response.Write("</tr>")
            End If
        End If
    End Sub

    ' Converts a valid rate to smallest int value
    ' e.g.  0.6ml/hour would be converted to 
    Private Sub ConvertToValidRate(ByRef dRate As Double, ByRef sDurationUnits As String)
        Dim dNewRate As Double
        Dim sNewDurationUnits As String

        sNewDurationUnits = "Second"
        dNewRate = 1.0 / ConvertDuration(1.0 / dRate, sDurationUnits, sNewDurationUnits)
        If dNewRate > 1.0 Then
            dRate = dNewRate
            sDurationUnits = sNewDurationUnits
            Return
        End If

        sNewDurationUnits = "Minute"
        dNewRate = 1.0 / ConvertDuration(1.0 / dRate, sDurationUnits, sNewDurationUnits)
        If dNewRate > 1.0 Then
            dRate = dNewRate
            sDurationUnits = sNewDurationUnits
            Return
        End If

        sNewDurationUnits = "Hour"
        dNewRate = 1.0 / ConvertDuration(1.0 / dRate, sDurationUnits, sNewDurationUnits)
        If dNewRate > 1.0 Then
            dRate = dNewRate
            sDurationUnits = sNewDurationUnits
            Return
        End If

        sNewDurationUnits = "Day"
        dNewRate = 1.0 / ConvertDuration(1.0 / dRate, sDurationUnits, sNewDurationUnits)
        If dNewRate > 1.0 Then
            dRate = dNewRate
            sDurationUnits = sNewDurationUnits
            Return
        End If

    End Sub

    'wrapper for ScriptDoseInformation to be called with each item in the xml (multiple items in this case is option items)
    Public Sub ScriptDoseInformationWrapper(ByVal sessionId As Integer, ByRef dom As XmlDocument, ByVal isGenericTemplate As Boolean, ByVal sUnitDescription As String, ByRef productId As Integer, ByVal blnNoDoseInfo As Integer, ByVal strRequestType As String, ByRef isVariableDose As Boolean, ByRef dose As Double, ByRef doseLow As Double)
        Dim colNodes As XmlNodeList
        Dim counter As Integer

        colNodes = dom.SelectNodes("root/data")
        For Each itemNode As XmlNode In colNodes
            ScriptDoseInformation(sessionId, itemNode, counter, isGenericTemplate, sUnitDescription, productId, blnNoDoseInfo, strRequestType, isVariableDose, dose, doseLow)
            counter = counter + 1
            If counter = colNodes.Count - 1 Then
                counter = -1
            End If
        Next
    End Sub


    Public Sub ScriptDoseInformation(ByVal sessionId As Integer, ByVal domItem As XmlNode, ByVal counter As Integer, ByVal isGenericTemplate As Boolean, ByVal sUnitDescription As String, ByRef productId As Integer, ByVal blnNoDoseInfo As Integer, ByVal strRequestType As String, ByRef isVariableDose As Boolean, ByRef dose As Double, ByRef doseLow As Double)
        Dim colProducts As XmlNodeList
        Dim xmlProduct As XmlNode
        Dim strFrequency As String

        'Product(s) - may have a single, or multiples
        'do we need an OR
        If (counter > 0 Or counter < 0) Then
            Response.Write(("<tr class='AttrName'><td><b>OR</b></td></tr>"))
        End If
        '
        '15Sep11    Rams    TFS13883 - Gets an error when a free text prescription has got a when required frequency
        'If LCase(GetXMLExpandedValue(domItem, "RequestTypeID")) = "generic prescription" Then IsGenericTemplate = True
        '
        If Not isGenericTemplate Then
            productId = CInt(GetXMLValue(domItem, "ProductID").ToString())
        Else
            '11May11    Rams    F0117182 - Items on the Drug Admin screen for free text prescriptions
            ScriptAttrValue(domItem, "Description", "Product", True, 5, sUnitDescription, isGenericTemplate)
        End If
        '
        SessionAttributeSet(sessionId, "IsGenericTemplate", isGenericTemplate.ToString())
        SessionAttributeSet(sessionId, "DrugName", CStr(GetXMLExpandedValue(domItem, "DrugName")))

        colProducts = domItem.SelectNodes("Ingredients/Product")

        ' TFS 13974 XN 15Sep11 Got all product to display Product, and dose info
        ' If mulitple product then sufix the Product and Dose text with Product A and Dose A ... Product B
        ' Does both standard and infusion prescriptions here
        If colProducts.Count > 0 Then

            For c As Integer = 0 To (colProducts.Count - 1)
                xmlProduct = colProducts.Item(c)

                Response.Write("<tr>" & vbCr)
                Response.Write("<td class='AttrName'>Product ")
                If (colProducts.Count > 1) Then
                    Response.Write(Chr(65 + c)) ' "A" + 1
                End If
                Response.Write("</td>" & vbCr)
                Response.Write("<td class='AttrValue'>" & xmlProduct.Attributes("Description").Value & "</td>" & vbCr)
                Response.Write("</tr>")

                Dim sDose As String = String.Empty
                Dim bFoundDose As Boolean = False
                Dim bVariableDose As Boolean = False
                Dim adminUnit As String = GetAdminUnit(domItem, False, sessionId)

                If Not xmlProduct.Attributes("QuantityMin") Is Nothing AndAlso xmlProduct.Attributes("QuantityMin").Value <> "0" AndAlso Not xmlProduct.Attributes("QuantityMax") Is Nothing AndAlso xmlProduct.Attributes("QuantityMax").Value <> "0" Then
                    sDose = CDblX(xmlProduct.Attributes("QuantityMin").Value) & " to " & CDblX(xmlProduct.Attributes("QuantityMax").Value) & "&nbsp;"
                    bFoundDose = True
                    bVariableDose = True
                ElseIf Not xmlProduct.Attributes("Quantity") Is Nothing AndAlso xmlProduct.Attributes("Quantity").Value <> "0" Then
                    sDose = xmlProduct.Attributes("Quantity").Value & "&nbsp;"
                    bFoundDose = True
                End If

                If bFoundDose Then
                    If xmlProduct.Attributes("UnitID") Is Nothing Then
                        sDose = sDose & adminUnit
                    Else
                        sDose = sDose & UnitDescription(sessionId, CInt(xmlProduct.Attributes("UnitID").Value), False)
                    End If

                    If bVariableDose OrElse CIntX(xmlProduct.Attributes("Quantity").Value) > 1 Then
                        sDose &= "s"
                    End If

                    Response.Write("<tr>" & vbCr)
                    Response.Write("<td class='AttrName'>Dose ")
                    If (colProducts.Count > 1) Then
                        Response.Write(Chr(65 + c)) ' "A" + 1
                    End If
                    Response.Write("</td>" & vbCr)
                    Response.Write("<td class='AttrValue'>" & sDose & "</td>" & vbCr)
                    Response.Write("</tr>" & vbCr)
                End If
            Next
        ElseIf Not blnNoDoseInfo Then
            Response.Write("<tr>" & vbCr)
            ' Standard Prescrtiption
            ScriptAttrValue(domItem, "ProductID", "Product", True, 5, sUnitDescription)

            '26May06 AE  Re-arranged for #DJ-06-0079
            'If LCase(GetXMLExpandedValue(domItem, "RequestTypeID")) =  "generic prescription" Then
            If isGenericTemplate Then
                ScriptAttrValue(domItem, "Dose", "Dose", False, 1, sUnitDescription)
            Else
                '21Jul11    Rams    Moved the Dose and DoseLow to non Generic Templates (as the Dose will have the unit in Generic Template, since free text field)
                doseLow = CDblX(GetXMLValueNumeric(domItem, "DoseLow"))
                dose = CDblX(GetXMLValueNumeric(domItem, "Dose"))
                If doseLow <> 0 Then
                    'Dose Range
                    Response.Write("<td class='AttrName'>Dose</td>")
                    Response.Write("<td class='AttrValue'>" & GetXMLValue(domItem, "DoseLow") & " to " & GetXMLValue(domItem, "Dose") & "&nbsp;" & GetAdminUnit(domItem, (dose > 1), sessionId) & "</td>")

                    'Response.Write("<td class='AttrValue'>" & GetAdminUnit(domItem, (Dose > 1)) & "</td>")

                    '                        ScriptAttrValue(domItem, "DoseLow", "Dose", False, 1)
                    '                       ScriptAttrValue(domItem, "Dose", "to", False, 1)

                    '09Feb10    Rams    F0063046 - DisplayDose over Last 24 hours
                    '06Aug12    XN      TFS38095 - Moved further down so calulcates variable does correctly
                    'IsVariableDose = True
                ElseIf dose <> 0 Then
                    'Single Dose
                    'ScriptAttrValue(domItem, "Dose", "Dose", False, 1)
                    Response.Write("<td class='AttrName'>Dose</td>" & vbCr)
                    Response.Write("<td class='AttrValue'>" & GetXMLValue(domItem, "Dose") & "&nbsp;" & GetAdminUnit(domItem, (dose > 1), sessionId) & "</td>" & vbCr)
                End If
            End If
            Response.Write("</tr>" & vbCr)

        Else
            'Doseless Rx where the dose regime is held on a separate card, such as warfarin.
            ScriptAttrValue(domItem, "ProductID", "Product", True, 5, sUnitDescription)
            Response.Write("<tr>" & vbCr & "<td class='AttrName'>Dose</td><td class='AttrValue' colspan='5'>" & " Please refer to Accompanying Paperwork for Dosing Instructions</td>" & vbCr & "</tr>" & vbCr)
        End If

        ' Diluent
        Dim xmlDiluentElement As XmlNode = domItem.SelectSingleNode("//Diluents/Product")
        If xmlDiluentElement IsNot Nothing Then
            Dim diluentName As String = xmlDiluentElement.Attributes("ProductName").Value
            Dim dDiluentVol As Double = 0

            ' Need to check if final volume has been entered before getting value
            If Not xmlDiluentElement.Attributes("DiluentFinalVolume") Is Nothing Then
                dDiluentVol = (CDblX(xmlDiluentElement.Attributes("DiluentFinalVolume").Value))
            End If

            Response.Write("<tr>" & vbCr & "<td class='AttrName'>Diluent</td><td class='AttrValue' colspan='5'>" & diluentName & " " & dDiluentVol.ToString("#.#") & "mL</td>" & vbCr & "</tr>" & vbCr)
        End If

        Dim isEnteral As Boolean = CStr(GetXMLExpandedValue(domItem, "RequestTypeID")).ToUpper() = VALUE_REQUESTTYPE_ENTERALPRESCRIPTION.ToUpper()
        Dim productRoute As String = CStr(GetXMLExpandedValue(domItem, "ProductRouteID"))
        If isEnteral Then
            productRoute = "via " & productRoute
        End If

        Response.Write("<tr>" & vbCr & "<td class='AttrName'>Route</td>" & vbCr)
        Response.Write("<td class='AttrValue' colspan='2' >" & productRoute & "</td>" & vbCr & "</tr>")

        ' Infunsion line info
        Response.Write("<tr>")
        Dim xmlInfusionLineElement As XmlElement = domItem.SelectSingleNode("//attribute[@name='InfusionLineID']")                   '20May08 AE  Corrected Xpath and attribute name below
        If (xmlInfusionLineElement IsNot Nothing) AndAlso (xmlInfusionLineElement.getAttribute("text") <> "") Then
            Response.Write("<tr>" & vbCr & "<td class='AttrName'>Infusion Line</td><td class='AttrValue' colspan='5'>Into " & xmlInfusionLineElement.getAttribute("text") & "</td>" & vbCr & "</tr>" & vbCr)
        End If
        Response.Write("</tr>" & vbCr)

        If GetXMLExpandedValue(domItem, "RequestTypeID") = VALUE_REQUESTTYPE_INFUSIONPRESCRIPTION OrElse GetXMLExpandedValue(domItem, "RequestTypeID") = VALUE_REQUESTTYPE_ENTERALPRESCRIPTION Then
            'Infusion;
            If CInt(GetXMLValueNumeric(domItem, "Rate")) > 0 Then
                '************************************* Rate-based infusions *************************************************
                Response.Write("<tr>")
                If CStr(GetXMLValue(domItem, "RateMin")) = "" Then
                    'Single Rate only
                    Response.Write("<td class='AttrName'>Prescribed Rate</td>" & vbCr)

                    Response.Write(String.Format("<td class='AttrValue'>{0:#.##} {1} per {2}</td>", _
                                                    GetXMLExpandedValue(domItem, "Rate"), _
                                                    GetXMLExpandedValue(domItem, "UnitID_RateMass"), _
                                                    GetXMLExpandedValue(domItem, "UnitID_RateTime")))
                Else
                    'Have a starting rate, max rate and min rate
                    Response.Write("<td class='AttrName'>Prescribed Rate</td>" & vbCr)

                    ' 25May08 CD - Added in the unit description instead of just display mL for the unit                    
                    Response.Write(String.Format("<td class='AttrValue'>start at {0:#.##} {1} per {2} then vary between {3:#.##} and {4:#.##} {1} per {2}</td>", _
                                                    GetXMLExpandedValue(domItem, "Rate"), _
                                                    GetXMLExpandedValue(domItem, "UnitID_RateMass"), _
                                                    GetXMLExpandedValue(domItem, "UnitID_RateTime"), _
                                                    GetXMLExpandedValue(domItem, "RateMin"), _
                                                    GetXMLExpandedValue(domItem, "RateMax")))
                End If
                Response.Write("</tr>")
                '59054 - hide diluent rate from prescribing and drug admin until further design reviews with user groups, etc. and new drug admin / diluent user stories are drafted
                '59054 - commented out following block as a temporary measure to always hide the calculated rate row as the original functionality may still be relevant and so does not want to be lost
                'If (xmlDiluentElement IsNot Nothing) And (domItem.selectNodes("//Ingredients/Product[@Quantity]").length > 0) Then
                '    Dim Ingredients As Object = domItem.selectNodes("//Ingredients/Product[@Quantity]")
                '    Dim dFinalVolume As Double = CDblX(xmlDiluentElement.getAttribute("DiluentFinalVolume"))
                '    Dim blnExactQuantity As Boolean = CBoolX(xmlDiluentElement.getAttribute("Exact"))
                '    Dim sFinalVolUnits As String = "mL"
                '    Dim dDose As Double = CDblX(Ingredients.item(0).getAttribute("Quantity"))
                '    Dim iDoseUnitID As Integer = Ingredients.item(0).getAttribute("UnitID")
                '    Dim dRate As Double = CDblX(GetXMLValueNumeric(domItem, "Rate"))
                '    Dim iRateMassUnitID As Integer = GetXMLValueNumeric(domItem, "UnitID_RateMass")
                '    Dim sRateMassUnit As String = GetXMLExpandedValue(domItem, "UnitID_RateMass")
                '    Dim sPerTime As String = GetXMLExpandedValue(domItem, "UnitID_RateTime")

                '    Response.Write("<tr>")
                '    Response.Write("<td class='AttrName'>Calculated Rate</td>" & vbCr)

                '    Response.Write("<td>")
                '    If (dFinalVolume > 0) Then
                '        If (CInt(GetXMLValueNumeric(domItem, "RateMin")) = 0) Or (CInt(GetXMLValueNumeric(domItem, "RateMax")) = 0) Then
                '            Dim dCalcRate As Double = CalcualteRateForRateInfusion(dRate, iRateMassUnitID, dDose, iDoseUnitID, dFinalVolume)

                '            ConvertToValidRate(dCalcRate, sPerTime)

                '            Response.Write(String.Format("<bdo class='AttrValue'>{0:#.##} {1} per {2}</bdo>", _
                '                                            dCalcRate, _
                '                                            sFinalVolUnits, _
                '                                            sPerTime))
                '        Else
                '            Dim dRateMin As Double = CDblX(GetXMLValueNumeric(domItem, "RateMin"))
                '            Dim dRateMax As Double = CDblX(GetXMLValueNumeric(domItem, "RateMax"))

                '            Dim dCalcRate As Double = CalcualteRateForRateInfusion(dRate, iRateMassUnitID, dDose, iDoseUnitID, dFinalVolume)
                '            Dim dCalcRateMin As Double = CalcualteRateForRateInfusion(dRateMin, iRateMassUnitID, dDose, iDoseUnitID, dFinalVolume)
                '            Dim dCalcRateMax As Double = CalcualteRateForRateInfusion(dRateMax, iRateMassUnitID, dDose, iDoseUnitID, dFinalVolume)

                '            ConvertToValidRate(dCalcRate, sPerTime)
                '            dCalcRateMin = 1.0 / ConvertDuration(1.0 / dCalcRateMin, GetXMLExpandedValue(domItem, "UnitID_RateTime"), sPerTime)
                '            dCalcRateMax = 1.0 / ConvertDuration(1.0 / dCalcRateMax, GetXMLExpandedValue(domItem, "UnitID_RateTime"), sPerTime)

                '            Response.Write(String.Format("<bdo class='AttrValue'>start at {0:#.##} {1} per {2} then vary between {3:#.##} and {4:#.##} {1} per {2}</bdo>", _
                '                                             dCalcRate, _
                '                                             sFinalVolUnits, _
                '                                             sPerTime, _
                '                                             dCalcRateMin, _
                '                                             dCalcRateMax))
                '        End If
                '    Else
                '        Response.Write("<bdo class='AttrValue sad'>Rate cannot be calculated</bdo>")
                '    End If
                '    Response.Write("</td>")
                '    Response.Write("</tr>")
                'End If
            Else
                Dim sFinalVolUnits As String = "mL"
                Dim diluentDuration As Double = CDblX(GetXMLValueNumeric(domItem, "InfusionDuration"))
                Dim diluentDurationLow As Double = CDblX(GetXMLValueNumeric(domItem, "InfusionDurationLow"))
                Dim sPerTime As String = GetXMLExpandedValue(domItem, "UnitID_InfusionDuration").ToString()
                SessionAttributeSet(sessionId, DA_INFUSIONDURATION_LOW, diluentDurationLow.ToString())
                SessionAttributeSet(sessionId, DA_INFUSIONDURATION_HIGH, diluentDuration.ToString())

                '************************************* Duration-based infusions *************************************************
                Response.Write("<tr>")
                'F0039935
                '28Nov08 ST Corrected problem with infusions being called bolus
                'If Not (IsLongDurationBasedInfusion(domItem.xml)) Then
                If CInt(diluentDuration) = 0 Then
                    'Bolus Dose
                    Response.Write("<td class='AttrName'>Give As</td>" & vbCr)
                    Response.Write("<td class='AttrValue'>Bolus Dose</td>" & vbCr)
                Else
                    'Dose with a duration
                    Response.Write("<td class='AttrName'>Give as</td>" & vbCr)
                    If CInt(GetXMLValueNumeric(domItem, "InfusionDurationLow")) = 0 Then
                        'Single Duration
                        Response.Write(String.Format("<td class='AttrValue'>Infuse Over {0} {1}(s)</td>", diluentDuration, sPerTime))
                    Else
                        'Range o' durations
                        Response.Write(String.Format("<td class='AttrValue'>Infuse Over {0} to {1} {2}(s)</td>", diluentDurationLow, diluentDuration, sPerTime))
                    End If
                End If
                Response.Write("</tr>")
                ' For a when required frequency with dose rules we need to show it
                If CInt(GetXMLValueNumeric(domItem, "ScheduleID_Administration")) = 0 And CInt(GetXMLValueNumeric(domItem, "PRN")) = 1 Then
                    Dim strMinimumIntervalDescription = WhenRequiredMinimumIntervalDescription(domItem)
                    Dim strMaximumOverTimeDescription = WhenRequiredMaximumDoseOverTimeDescription(domItem, sessionId)
                    strFrequency = "When Required"
                    If Not String.IsNullOrEmpty(strMinimumIntervalDescription) Or Not String.IsNullOrEmpty(strMaximumOverTimeDescription) Then
                        Response.Write("<tr>" & vbCr & "<td class='AttrName'>Frequency</td><td class='AttrValue' colspan='5'>" & strFrequency & "</td>" & vbCr & "</tr>" & vbCr)
                        If Not String.IsNullOrEmpty(strMinimumIntervalDescription) Then
                            Response.Write("<tr>" & vbCr & "<td class='AttrName'></td><td class='AttrValue' colspan='10'>" & strMinimumIntervalDescription & "</td>" & vbCr & "</tr>" & vbCr)
                        End If
                        If Not String.IsNullOrEmpty(strMaximumOverTimeDescription) Then
                            Response.Write("<tr>" & vbCr & "<td class='AttrName'></td><td class='AttrValue' colspan='10'>" & strMaximumOverTimeDescription & "</td>" & vbCr & "</tr>" & vbCr)
                        End If
                    End If
                End If

                '59054 - hide diluent rate from prescribing and drug admin until further design reviews with user groups, etc. and new drug admin / diluent user stories are drafted
                '59054 - commented out following block as a temporary measure to always hide the calculated rate row as the original functionality may still be relevant and so does not want to be lost
                'If IsLongDurationBasedInfusion(domItem.xml) And (xmlDiluentElement IsNot Nothing) Then
                '    Dim dFinalVolume As Double = CDblX(xmlDiluentElement.getAttribute("DiluentFinalVolume"))
                '    Dim blnExactQuantity As Boolean = CBoolX(xmlDiluentElement.getAttribute("Exact"))
                '    ' add calculated rate
                '    ' 24Mar10 CD F0081306 Changed to only calculate a rate if the diluent quantity is marked
                '    ' as exact, not nominal, but if not calculating a rate show a message rather than
                '    ' just leave the Calculated row off the display
                '    Response.Write("<tr>")
                '    '                    If CIntX(xmlDiluentElement.getAttribute("DiluentFinalVolume")) <> 0 Then
                '    Response.Write("<td class='AttrName'>Calculated Rate</td>" & vbCr)

                '    Response.Write("<td>")
                '    If (dFinalVolume > 0) Then
                '        If dDurationLow <= 0 Then
                '            Dim dRate As Double = dFinalVolume / dDuration

                '            ConvertToValidRate(dRate, sPerTime)

                '            Response.Write("<bdo class='AttrValue'>" & dRate.ToString("#.##") & " mL per " & sPerTime & "</bdo>")
                '        Else
                '            Dim dRateMin As Double = dFinalVolume / dDuration
                '            Dim dRateMax As Double = dFinalVolume / dDurationLow

                '            ConvertToValidRate(dRateMin, sPerTime)
                '            dRateMax = 1.0 / ConvertDuration(1.0 / dRateMax, GetXMLExpandedValue(domItem, "UnitID_InfusionDuration"), sPerTime)

                '            Response.Write("<bdo class='AttrValue'>" & dRateMin.ToString("#.##") & " to " & dRateMax.ToString("#.##") & " " & sFinalVolUnits & " per " & sPerTime & "</bdo>")
                '        End If
                '    Else
                '        Response.Write("<bdo class='AttrValue sad'>Rate cannot be calculated</bdo>")
                '    End If
                '    Response.Write("</td>")
                '    Response.Write("</tr>")
                'End If
            End If
        Else
            '************************************* Standard Prescription *************************************************
            If Not blnNoDoseInfo Then
				'Frequency
				Dim PRN As Boolean = CInt(GetXMLValueNumeric(domItem, "PRN")) = 1
				Dim SingleDoseIfRequired As Boolean = PRN AndAlso ((isGenericTemplate AndAlso GetXMLValue(domItem, "Description").Contains("Single Dose")) OrElse GetXMLValue(domItem, "Description_Frequency") = "Single Dose, if required")
				If CInt(GetXMLValueNumeric(domItem, "ScheduleID_Administration")) > 0 Then
					'This is a standard frequency
					strFrequency = CStr(GetXMLExpandedValue(domItem, "ScheduleID_Administration"))
				Else
					'Must be a STAT, Frequencyless, or PRN dose
					If PRN AndAlso Not SingleDoseIfRequired Then
						strFrequency = "When Required" ' old value "PRN"
					Else
						strFrequency = "Single Dose"
					End If
				End If
                Response.Write("<tr>" & vbCr & "<td class='AttrName'>Frequency</td><td class='AttrValue' colspan='5'>" & strFrequency & "</td>" & vbCr & "</tr>" & vbCr)
                ' TFS 13974 XN 15Sep11 Moved to to bit above
                'Else
                '    'Doseless Rx where the dose regime is held on a separate card, such as warfarin.
                '    Response.Write("<tr>" & vbCr & "<td class='AttrName'>Dose</td><td class='AttrValue' colspan='5'>" & " Please refer to Accompanying Paperwork for Dosing Instructions</td>" & vbCr & "</tr>" & vbCr)
            End If
            Dim strMinimumIntervalDescription = WhenRequiredMinimumIntervalDescription(domItem)
            If Not String.IsNullOrEmpty(strMinimumIntervalDescription) Then
                Response.Write("<tr>" & vbCr & "<td class='AttrName'></td><td class='AttrValue' colspan='10'>" & strMinimumIntervalDescription & "</td>" & vbCr & "</tr>" & vbCr)
            End If
            Dim strMaximumOverTimeDescription = WhenRequiredMaximumDoseOverTimeDescription(domItem, sessionId)
            If Not String.IsNullOrEmpty(strMaximumOverTimeDescription) Then
                Response.Write("<tr>" & vbCr & "<td class='AttrName'></td><td class='AttrValue' colspan='10'>" & strMaximumOverTimeDescription & "</td>" & vbCr & "</tr>" & vbCr)
            End If
        End If
        'Common fields; duration, directions
        If CStr(GetXMLValue(domItem, "Duration")) <> "" Then
            Dim duration As String = CStr(GetXMLExpandedValue(domItem, "Duration"))
            Dim durationUnit As String = CStr(GetXMLExpandedValue(domItem, "UnitID_Duration"))
            Response.Write("<tr>" & vbCr & "<td class='AttrName'>Duration</td>" & vbCr)
            Response.Write("<td class='AttrValue' colspan='2' >" & duration & "&nbsp;" & durationUnit & "(s)</td>" & vbCr & "</tr>")
        End If

        ScriptAttrValue(domItem, "ArbTextID_Direction", "Directions", True, 5, sUnitDescription)
        ScriptAttrValue(domItem, "DirectionText", "Directions", True, 5, sUnitDescription)
        '
        '17May11    Rams    F0117182 - Items on the Drug Admin screen for free text prescriptions
        If isGenericTemplate Then
            ScriptAttrValue(domItem, "Directions_Dispensing", "Additional Instructions", True, 5, sUnitDescription)
        Else
            ScriptAttrValue(domItem, "SupplimentaryText", "Additional Instructions", True, 5, sUnitDescription)
        End If

        '12Feb15    YB      TFS 110358 - Populate review related data (If there is a review against the prescription)
        Dim reviewDate As String = CStr(GetXMLValue(domItem, "ReviewDate"))
        Dim reviewComplete As String = CStr(GetXMLValue(domItem, "ReviewComplete"))
        Dim reviewOverDue As String = CStr(GetXMLValue(domItem, "ReviewOverDue"))
        Dim reviewDue As String = CStr(GetXMLValue(domItem, "ReviewDue"))
        Dim reviewPending As String = CStr(GetXMLValue(domItem, "ReviewPending"))
        If reviewDate <> "" Then
            Dim reviewDateTime As DateTime = DateTime.Parse(reviewDate)
            Dim reviewCompleteBool As Boolean = Convert.ToBoolean(Convert.ToInt32(reviewComplete))
            Dim reviewOverDueBool As Boolean = Convert.ToBoolean(Convert.ToInt32(reviewOverDue))
            Dim reviewDueBool As Boolean = Convert.ToBoolean(Convert.ToInt32(reviewDue))
            Dim reviewPendingBool As Boolean = Convert.ToBoolean(Convert.ToInt32(reviewPending))
            If reviewCompleteBool = True Then
                Response.Write("<tr>" & vbCr & "<td class='AttrName'>Review</td><td class='AttrValue Complete' colspan='10'>" & "Review Date " & reviewDateTime.ToString() & " Complete</td>" & vbCr & "</tr>" & vbCr)
            ElseIf reviewOverDueBool = True Then
                Response.Write("<tr>" & vbCr & "<td class='AttrName'>Review</td><td class='AttrValue Sad' colspan='10'>" & "Review Date " & reviewDateTime.ToString() & " Overdue</td>" & vbCr & "</tr>" & vbCr)
            ElseIf reviewDueBool = True Then
                Response.Write("<tr>" & vbCr & "<td class='AttrName'>Review</td><td class='AttrValue Warning' colspan='10'>" & "Review Date " & reviewDateTime.ToString() & " Due</td>" & vbCr & "</tr>" & vbCr)
            ElseIf reviewPendingBool = True Then
                Response.Write("<tr>" & vbCr & "<td class='AttrName'>Review</td><td class='AttrValue Review' colspan='10'>" & "Review Date " & reviewDateTime.ToString() & "</td>" & vbCr & "</tr>" & vbCr)
            End If
        End If

        '
        'write sperator
        If counter < 0 Then
            Response.Write(("<tr class='AttrName'><td><hr></td></tr>"))
        End If

        '06Aug12 XN TFS38095 Determine if variable administration
        isVariableDose = strRequestType.ToUpper() = "INFUSION ADMINISTRATION" OrElse strRequestType.ToUpper() = "ENTERAL ADMINISTRATION" OrElse (strRequestType.ToUpper() = "DRUG ADMINISTRATION" AndAlso GetXMLValue(domItem, "DoseLow") <> "")
    End Sub

    ' Returns if the prescription can be administered, important for if the prescription is not due yet.
    ' Uses system settings lngEarlyMode, and lngMaxMinutesEarly
    Public Function IsPrescriptionWithinPrescribeTimeWindow(ByVal dtDateDue As DateTime, ByVal lngDueMinutes As Integer, ByVal lngMaxMinutesEarly As Integer, ByVal lngEarlyMode As Integer, ByVal isPrn As Boolean) As Boolean
        If isPrn Then
            Return True
        End If

        If lngEarlyMode = 0 Then
            Return (lngDueMinutes <= lngMaxMinutesEarly)
        ElseIf lngEarlyMode = 1 Then
            Dim dtTodayStart As DateTime = New DateTime(DateTime.Now().Year, DateTime.Now().Month, DateTime.Now().Day)
            Dim tsTimeDiff As TimeSpan = dtDateDue - dtTodayStart
            Return (tsTimeDiff.Days <= 0)
        Else
            Return False
        End If
    End Function

    Public Function IsWhenRequiredPrescriptionInTimeWindow(ByVal dtDateDue As DateTime, ByVal isPrn As Boolean, ByVal prnMaxMinutesEarly As Integer) As Boolean
        If isPrn Then
            Return dtDateDue <= DateTime.Now.AddMinutes(prnMaxMinutesEarly)
        Else
            Return True
        End If
    End Function

    Public Function IsWhenRequiredPrescriptionEarly(ByVal dtDateDue As DateTime, ByVal isPrn As Boolean) As Boolean
        If isPrn Then
            Return dtDateDue > DateTime.Now
        Else
            Return False
        End If
    End Function

    Public Function GetDoseToExceedMaximum(ByVal sessionId As Integer, ByVal dom As XmlDocument, ByVal isPrn As Boolean) As Double
        If isPrn Then
            Return GetMaximumAllowedDoseInRangeForRule(sessionId, dom.SelectSingleNode("root/data"))
        End If

        Return 0
    End Function

    Function GetPrescribedDescription(ByVal sessionId As Integer, ByVal requestIdPrescriptionAdministered As Integer, ByVal recordedDose As String) As String

        Dim administeredDoc As XmlDocument = PrescriptionRowByID(sessionId, requestIdPrescriptionAdministered)
        Dim administeredDose As XmlElement = administeredDoc.SelectSingleNode("root/data")
        Dim description As String = String.Empty

        Dim products As XmlNodeList = administeredDose.SelectNodes("Ingredients/Product")
        If products.Count > 0 Then
            For Each product As XmlElement In products
                If description.Length > 0 Then
                    description &= ", "
                End If
                description &= product.GetAttribute("Description")

                Dim dose As String = String.Empty
                Dim foundDose As Boolean = False
                If Not String.IsNullOrEmpty(recordedDose) AndAlso Double.Parse(recordedDose) > 0 Then
                    dose = recordedDose & "&nbsp;" & UnitDescription(sessionId, product.GetAttribute("UnitID"), True)
                    foundDose = True
                ElseIf product.GetAttribute("Description_Dose") <> "" Then
                    dose = product.GetAttribute("Description_Dose")
                    foundDose = True
                ElseIf Not String.IsNullOrEmpty(product.GetAttribute("QuantityMin")) AndAlso product.GetAttribute("QuantityMin") <> "0" AndAlso Not String.IsNullOrEmpty(product.GetAttribute("QuantityMax")) AndAlso product.GetAttribute("QuantityMax") <> "0" Then
                    dose = CDblX(product.GetAttribute("QuantityMin")) & " to " & CDblX(product.GetAttribute("QuantityMax")) & "&nbsp;" & UnitDescription(sessionId, product.GetAttribute("UnitID"), True)
                    foundDose = True
                ElseIf Not String.IsNullOrEmpty(product.GetAttribute("Quantity")) AndAlso product.GetAttribute("Quantity") <> "0" Then
                    dose = product.GetAttribute("Quantity") & "&nbsp;" + IFF(product.GetAttribute("UnitID") = "", "", UnitDescription(sessionId, product.GetAttribute("UnitID"), True))
                    foundDose = True
                End If

                If foundDose Then
                    description &= " " & dose
                End If
            Next
        Else
            description = GetXMLExpandedValue(administeredDose, "ProductID")
            Dim dose As Double = GetXMLValueNumeric(administeredDose, "Dose")
            Dim doseLow As Double = GetXMLValueNumeric(administeredDose, "DoseLow")

            If Not String.IsNullOrEmpty(recordedDose) AndAlso Double.Parse(recordedDose) > 0 Then
                description &= " " & recordedDose & "&nbsp;" & GetAdminUnit(administeredDose, (Double.Parse(recordedDose) > 1), sessionId)
            ElseIf dose <> 0 AndAlso doseLow <> 0 Then
                description &= " " & GetXMLValue(administeredDose, "DoseLow") & " to " & GetXMLValue(administeredDose, "Dose") & "&nbsp;" & GetAdminUnit(administeredDose, (dose > 1), sessionId)
            ElseIf dose <> 0 Then
                description &= " " & GetXMLValue(administeredDose, "Dose") & "&nbsp;" & GetAdminUnit(administeredDose, (dose > 1), sessionId)
            End If
        End If

        description &= " " & GetXMLExpandedValue(administeredDose, "ProductRouteID")

        Return description

    End Function


End Class
