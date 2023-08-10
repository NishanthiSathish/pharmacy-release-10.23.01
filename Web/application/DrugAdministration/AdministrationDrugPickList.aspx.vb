Imports System.Xml
Imports Ascribe.Common
Imports Ascribe.Common.DrugAdministration

Partial Class application_DrugAdministration_AdministrationDrugPickList
    Inherits Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
    End Sub

    Public Sub WriteDosesWithNoDrugs(ByVal sessionId As Integer, ByVal domDoses As XmlDocument)
        'Display any doses that could not be fulfilled automatically
        Dim colDoses As XmlNodeList
        Dim xmlDose As XmlNode
        Dim strOnClick As String

        colDoses = domDoses.SelectNodes("//" & NODE_ADMINREQUEST & "[@" & ATTR_UNABLE_TO_FULFILL & "='1']")

        If colDoses.Count > 0 Then
            Response.Write("<tr class='SectionTitle'>" & vbCr)
            Response.Write("<th colspan=""4"" align=""left"">Problem Doses</th>" & vbCr)
            Response.Write("</tr>			" & vbCr)
            Response.Write("<tr>" & vbCr)
            Response.Write("<td colspan=""4"" class=""Info"">We could not find any drugs on the system to fulfil the doses marked with an exclamation symbol." & vbCr)
            Response.Write("									 This might be because the drugs are out of stock, not stocked, or because a drug was prescribed via" & vbCr)
            Response.Write("									 an erroneous route.  You can review the prescription for each dose by pressing on the exclamation symbol." & vbCr)
            Response.Write("</td>" & vbCr)
            Response.Write("</tr>" & vbCr)
            For Each xmlDose In colDoses
                strOnClick = "TouchNavigate('AdministrationPrescriptionDetail.aspx" & "?SessionID=" & sessionId & "&" & DA_REQUESTID & "=" & xmlDose.Attributes("RequestID").Value & "&" & DA_ENTITYID & "=" & xmlDose.Attributes("EntityID").Value & "&" & DA_DESTINATION_URL & "=AdministrationDrugPicklist.aspx" & "&" & DA_REFERING_URL & "=AdministrationDrugPicklist.aspx" & "&" & DA_MODE & "=view" & "')"
                Response.Write("<tr class=""Drug Underline"">" & vbCr)
                Response.Write("<td>")
                TouchscreenShared.PictureButton("../../images/Touchscreen/DrugAdministration/exclamation_red.gif", strOnClick, True)
                Response.Write("</td>" & vbCr)
                Response.Write("<td class=""Description"" colspan=""2"">")
                Response.Write(xmlDose.Attributes("Description").Value)
                Response.Write("</td>" & vbCr)
                Response.Write("<td class=""Patient"" colspan=""2"">(")
                Response.Write(xmlDose.Attributes(CStr(ATTR_PATIENT)).Value)
                Response.Write(")</td>" & vbCr)
                Response.Write("</tr>" & vbCr)
            Next
        End If
    End Sub

    Public Sub WriteDrug(ByVal sessionId As Integer, ByVal xmlDrug As XmlNode, ByVal locationTag As Boolean, ByVal underline As Boolean)
        Dim strDescription As String = String.Empty
        Dim strTradename As String = String.Empty
        Dim strOnclick As String
        Dim blnSelected As Boolean
        TradenameParse(xmlDrug.Attributes(CStr(ATTR_DRUG_DESCRIPTION)).Value, strDescription, strTradename)
        strOnclick = "TouchNavigate('AdministrationDrugPicklist.aspx?SessionID=" & sessionId & "&" & DA_MODE & "=" & MODE_TOGGLE & "&ID=" & xmlDrug.Attributes(CStr(ATTR_ID)).Value & "&Top=' + divScroller.scrollTop " & ")"
        blnSelected = (CStr(Generic.CIntX(xmlDrug.Attributes(CStr(ATTR_SELECTED)).Value)) = "1")
        Response.Write("		<tr class=""Drug ")
        If underline Then
            Response.Write("Underline")
        End If

        If blnSelected Then
            Response.Write(" Strikethrough")
        End If

        Response.Write(""">" & vbCr)

        If locationTag <> CBool(STOCKLOCATION_DISPENSED) Then
            Response.Write("			<td>")
            TouchscreenShared.CheckButton(blnSelected, strOnclick, True)
            Response.Write("</td>" & vbCr)
            Response.Write("			<td class=""Quantity"">")
            Response.Write(xmlDrug.Attributes(CStr(ATTR_QUANTITY)).Value)
            Response.Write(" X </td>" & vbCr)
            Response.Write("			<td class=""Description"">")
            Response.Write(Generic.SpaceToNBSP(strDescription))
            Response.Write("</td>" & vbCr)
            Response.Write("			<td class=""Tradename"">")
            Response.Write(Generic.SpaceToNBSP(strTradename))
            Response.Write("</td>" & vbCr)
            Response.Write("			" & vbCr)
        Else
            Response.Write("			<td colspan='3'>")
            Response.Write(xmlDrug.Attributes(CStr(ATTR_DRUG_DESCRIPTION)).Value)
            Response.Write("</td>		" & vbCr)
            Response.Write("			<td>(Tradename)</td>" & vbCr)
        End If

        Response.Write("			" & vbCr)
        Response.Write("		</tr>" & vbCr)
    End Sub

    Public Sub WriteDrugs(ByVal sessionId As Integer, ByVal domDrugs As XmlDocument, ByVal locationTag As Object, ByVal sectionTitle As String, ByVal sectionText As String)

        'Display the drugs required in this section (pharmacy, ward stock, etc)
        Dim colDrugs As XmlNodeList
        Dim xmlDrug As XmlNode
        Dim colOptionRoots As XmlNodeList
        Dim colDoseOptions As XmlNodeList
        Dim xmlOptionRoot As XmlNode
        Dim xmlDoseOption As XmlNode
        Dim i As Integer

        'Get all drugs with a quantity attribute for this stock location
        colDrugs = domDrugs.SelectNodes("root/" & NODE_PRODUCT & "[@" & ATTR_STOCKLOCATION & "='" & locationTag.ToString() & "']")
        colOptionRoots = domDrugs.SelectNodes("root/" & NODE_OPTIONROOT & "[@" & ATTR_STOCKLOCATION & "='" & locationTag.ToString() & "']")

        If colDrugs.Count > 0 Or colOptionRoots.Count > 0 Then
            Response.Write("<tr class='SectionTitle'>" & vbCr)
            Response.Write("<th colspan=""4"" align=""left"">")
            Response.Write(sectionTitle)
            Response.Write("</th>" & vbCr)
            Response.Write("</tr>" & vbCr)
            Response.Write("<tr>" & vbCr)
            Response.Write("<td colspan=""4"" class=""Info"">")
            Response.Write(sectionText)
            Response.Write("</td>" & vbCr)
            Response.Write("</tr>" & vbCr)
            Response.Write("			" & vbCr)

            For Each xmlDrug In colDrugs
                WriteDrug(sessionId, xmlDrug, CBool(locationTag), True)
            Next

            'Then all drugs where there is a choice for this stock location (eg where there are syrup or tablets available)
            For Each xmlOptionRoot In colOptionRoots
                colDoseOptions = xmlOptionRoot.SelectNodes(CStr(NODE_OPTION))
                i = 0
                For Each xmlDoseOption In colDoseOptions
                    colDrugs = xmlDoseOption.SelectNodes(CStr(NODE_PRODUCT))
                    For Each xmlDrug In colDrugs
                        WriteDrug(sessionId, xmlDrug, CBool(locationTag), (i = colDoseOptions.Count - 1))
                    Next
                    If i < (colDoseOptions.Count - 1) Then
                        Response.Write("	" & vbCr)
                        Response.Write("<tr class=""Drug""><td>&nbsp;</td><td colspan=""3"">OR</td></tr>" & vbCr)
                    End If
                    i = i + 1
                Next
            Next
        End If
    End Sub
End Class
