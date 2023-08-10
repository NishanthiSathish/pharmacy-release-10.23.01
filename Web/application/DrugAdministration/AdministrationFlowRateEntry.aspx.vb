Imports System.Xml
Imports Ascribe.Common
Imports Ascribe.Common.Generic
Imports Ascribe.Common.DrugAdministration

Partial Class application_DrugAdministration_AdministrationFlowRateEntry
    Inherits Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
    End Sub

    Public Sub SetFlowRate(ByVal sessionId As Integer, ByVal prescriptionId As Integer, ByRef rateUnitId As Integer, ByRef timeUnitId As Integer, ByRef rateUnitDescription As String, ByRef timeUnitDescription As String, ByRef flowRate As Double, ByRef minRate As Double, ByRef maxRate As Double)
        Dim flowRateAtt As String = SessionAttribute(sessionId, CStr(DA_FLOW_RATE))
        Dim rateUnitIdAtt As String = SessionAttribute(sessionId, CStr(DA_FLOW_RATE_UNITID))
        Dim rateUnitAtt As String = SessionAttribute(sessionId, CStr(DA_FLOW_RATE_UNIT))
        Dim timeUnitIdAtt As String = SessionAttribute(sessionId, CStr(DA_FLOW_RATE_UNITID_TIME))
        Dim timeUnitAtt As String = SessionAttribute(sessionId, CStr(DA_FLOW_RATE_UNIT_TIME))
        Dim minRateAtt As String = SessionAttribute(sessionId, CStr(DA_RATE_MIN))
        Dim maxRateAtt As String = SessionAttribute(sessionId, CStr(DA_RATE_MAX))

        '03Feb14 SPinnington Bug 105346 If flow rate not set yet, then set to start rate
        If flowRateAtt = "" Then
            flowRateAtt = SessionAttribute(sessionId, CStr(DA_RATE_START))
        End If

        If flowRateAtt <> "" And rateUnitIdAtt <> "" And timeUnitIdAtt <> "" Then
            flowRate = CDbl(flowRateAtt)
            rateUnitId = CIntX(rateUnitIdAtt)
            timeUnitId = CIntX(timeUnitIdAtt)
            rateUnitDescription = rateUnitAtt
            timeUnitDescription = timeUnitAtt
        Else
            SetFlowRateUnit(sessionId, prescriptionId, rateUnitId, timeUnitId, rateUnitDescription, timeUnitDescription)
        End If

        If minRateAtt <> "" And maxRateAtt <> "" Then
            minRate = CDbl(minRateAtt)
            maxRate = CDbl(maxRateAtt)
        End If
    End Sub

    Public Sub SetFlowRateUnit(ByVal sessionId As Integer, ByVal prescriptionId As Integer, ByRef rateUnitId As Integer, ByRef timeUnitId As Integer, ByRef rateUnitDescription As String, ByRef timeUnitDescription As String)
        Dim prescription As XmlDocument = PrescriptionRowByID(sessionId, prescriptionId)
        Dim data As XmlElement = prescription.SelectSingleNode("//data")

        rateUnitId = CIntX(GetXMLValueNumeric(data, "UnitID_RateMass"))
        timeUnitId = CIntX(GetXMLValueNumeric(data, "UnitID_RateTime"))
        If rateUnitId <> 0 Then
            rateUnitDescription = CStr(GetXMLExpandedValue(data, "UnitID_RateMass"))
        End If

        If timeUnitId <> 0 Then
            timeUnitDescription = CStr(GetXMLExpandedValue(data, "UnitID_RateTime"))
        End If
    End Sub

    Public Sub DisableAllExceptSelectedForm(ByVal dom As XmlDocument)
        'goes through DOM, finds any items which have a selected quantity greater than 0, and
        'marks anything that has a different product form with a disabled indicator.  This is because
        'you wouldn't give half by tablet and half by syrup, for example.
        Dim colSelected As XmlNodeList
        Dim colProducts As XmlNodeList
        Dim xmlProduct As XmlNode
        Dim lngProductFormId As Integer
        Dim intFlagValue As Integer

        lngProductFormId = 0

        colSelected = dom.SelectNodes("//" & NODE_PRODUCT & "[@" & ATTR_QUANTITY_SELECTED & "!='0']")
        If colSelected.Count > 0 Then
            xmlProduct = colSelected(0)
            lngProductFormId = CIntX(xmlProduct.Attributes(CStr(ATTR_PRODUCTFORMID)).Value)
        End If

        If lngProductFormId > 0 Then
            'Disable everything with a different formID
            intFlagValue = 1
            colProducts = dom.SelectNodes("//" & NODE_PRODUCT & "[@" & ATTR_PRODUCTFORMID & "!='" & lngProductFormId & "']")
        Else
            'Nothing is selected, enable everything
            intFlagValue = 0
            colProducts = dom.SelectNodes("//" & NODE_PRODUCT)
        End If

        For Each xmlProduct In colProducts
            xmlProduct.Attributes(CStr(ATTR_DISABLED)).Value = intFlagValue.ToString()
        Next
    End Sub

End Class
