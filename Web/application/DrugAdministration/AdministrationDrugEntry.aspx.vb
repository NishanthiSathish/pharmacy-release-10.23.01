Imports System.Xml
Imports Ascribe.Xml
Imports Ascribe.Common
Imports Ascribe.Common.Generic
Imports Ascribe.Common.DrugAdministration
Imports Ascribe.Common.DrugAdministrationConstants


Partial Class application_DrugAdministration_AdministrationDrugEntry
    Inherits Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As EventArgs) Handles Me.Load
    End Sub

    Public Sub WriteDrugs(ByVal sessionId As Integer, ByVal dom As XmlDocument, ByVal domProducts As XmlDocument, ByVal strProductAvailableXml As String)
        Dim domAvailable As XmlDocument = New XmlDocument()

        'Load our list of any products which were selected in the picklist
        domAvailable.TryLoadXml(strProductAvailableXml)

        'NB: Unless we are showing ALL drugs, we'll only have drugs in one of the three
        'locations listed below.

        'Show drugs which have been dispensed to the patient
        WriteDrugsByLocation(sessionId, dom, domProducts, domAvailable, STOCKLOCATION_DISPENSED)
        'Then ward stock drugs
        WriteDrugsByLocation(sessionId, dom, domProducts, domAvailable, STOCKLOCATION_WARDSTOCK)
        'Then ward stock drugs
        WriteDrugsByLocation(sessionId, dom, domProducts, domAvailable, STOCKLOCATION_PHARMACY)
    End Sub

    
    Public Sub WriteDrugsByLocation(ByVal sessionId As Integer, ByVal dom As XmlDocument, ByVal domProducts As XmlDocument, ByVal domAvailable As XmlDocument, ByVal locationTag As String)
        Dim colProducts As XmlNodeList
        Dim colOptions As XmlNodeList 
        Dim xmlProduct As XmlNode
        Dim intQuantity As Integer
        Dim xmlOptionRoot As XmlNode
        Dim blnNoQuantitySelected As Boolean
        Dim blnAddDefaultQuantity As Boolean
        'The document might contain single products with stock locations, or a list of options (tablet 1 OR tablet 2 or ....).
        'In the latter case, the stock location is held at the option element level, not on each product.  (It made sense for the
        'picklist, but not for this...that's what comes from doing things in a rush)
        'Look for the first, then the second...
        colProducts = domProducts.SelectNodes("//" & NODE_PRODUCT & "[@" & ATTR_STOCKLOCATION & "='" & locationTag & "']")
        If colProducts.Count = 0 Then
            xmlOptionRoot = domProducts.SelectSingleNode("//" & NODE_OPTIONROOT & "[@" & ATTR_STOCKLOCATION & "='" & locationTag & "']")
            If Not xmlOptionRoot Is Nothing Then
                colProducts = xmlOptionRoot.selectNodes("//" & NODE_PRODUCT)
            End If
        End If

        colOptions = dom.SelectNodes("//" & NODE_OPTION)

        For Each xmlProduct In colProducts
            blnNoQuantitySelected = XmlExtensions.AttributeExists(xmlProduct.GetAttribute(ATTR_QUANTITY_SELECTED))
            'If this was a dispensed product, default the required number in
            blnAddDefaultQuantity = (locationTag = STOCKLOCATION_DISPENSED And blnNoQuantitySelected)
            'Or if we only have a single choice of product to give, we'll default the required number in
            If Not blnAddDefaultQuantity Then
                blnAddDefaultQuantity = (colOptions.Count = 1 And blnNoQuantitySelected) Or (colProducts.Count = 1 And blnNoQuantitySelected)
            End If

            If blnAddDefaultQuantity Then
                'Default the required quantity in.  This has already been calculated when the
                'list of administerable products was created
                intQuantity = CIntX(xmlProduct.Attributes(CStr(ATTR_QUANTITY)))
                xmlProduct.Attributes(CStr(ATTR_QUANTITY_SELECTED)).Value = intQuantity.ToString()
                DisableAllExceptSelectedForm(domProducts)
            End If
            WriteDrugRow(sessionId, xmlProduct, locationTag)
        Next
    End Sub

    Public Sub WriteDrugRow(ByVal sessionId As Integer, ByVal xmlProduct As XmlNode, ByVal locationTag As String)
        Dim strProductName As String = ""
        Dim strTradename As String = ""
        Dim strLocation As String = ""
        Dim strQty As String
        Dim lngQty As Integer
        Dim strOnClickUp As String = ""
        Dim strOnClickDown As String = ""
        Dim strOnClickAutoButton As String
        Dim blnDownButtonEnabled As Boolean = True
        Dim blnDisabled As Boolean
        Dim strImageAutobutton As String

        'Parse the tradename from the drug description
        TradenameParse(xmlProduct.Attributes(CStr(ATTR_DRUG_DESCRIPTION)).Value, strProductName, strTradename)
        'This product might be marked as disabled
        blnDisabled = (CStr(CIntX(xmlProduct.Attributes(CStr(ATTR_DISABLED)).Value)) = "1")

        Select Case locationTag
            Case STOCKLOCATION_DISPENSED
                strLocation = "Dispensed"
            Case STOCKLOCATION_WARDSTOCK
                strLocation = "Ward Stock"
            Case STOCKLOCATION_PHARMACY
                strLocation = "Pharmacy / Other"
        End Select

        'Display a "-" if we have none selected, otherwise the quantity and unit are shown.
        'Also determine what the autocomplete/clear button does for this row
        lngQty = CIntX(xmlProduct.Attributes(CStr(ATTR_QUANTITY_SELECTED)).Value)
        If CIntX(lngQty) = 0 Then
            strQty = "-"
            blnDownButtonEnabled = False
            strImageAutobutton = "../../images/touchscreen/Tick.gif"
            'Liquids will have the quantity in mL specified, which we'll need.  Otherwise we use the quantity of whole
            '"things" (tablets etc) required.
            lngQty = CIntX(xmlProduct.Attributes(CStr(ATTR_QUANTITY_ML)).Value)
            If CIntX(lngQty) = 0 Then
                lngQty = CIntX(xmlProduct.Attributes(CStr(ATTR_QUANTITY)).Value)
            End If
            strOnClickAutoButton = "TouchNavigate('AdministrationDrugEntry.aspx?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & "&" & DA_ADD_QUANTITY & "=" & lngQty & "&" & DA_PRODUCTID_SELECTED & "=" & xmlProduct.Attributes(CStr(ATTR_PRODUCTID)).Value & "');"
        Else
            'Add the display unit to the end
            strQty = lngQty & " " & xmlProduct.Attributes(CStr(ATTR_DISPLAYUNIT)).Value
            strOnClickAutoButton = "TouchNavigate('AdministrationDrugEntry.aspx?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & "&" & DA_ADD_QUANTITY & "=-" & lngQty & "&" & DA_PRODUCTID_SELECTED & "=" & xmlProduct.Attributes(CStr(ATTR_PRODUCTID)).Value & "');"
            strImageAutobutton = "../../images/touchscreen/Cross.gif"
        End If

        'OnClick Event handlers
        If Not blnDisabled Then
            strOnClickUp = "TouchNavigate('AdministrationDrugEntry.aspx?SessionID=" & sessionId & "&IsGenericTemplate=" & Request.QueryString("IsGenericTemplate") & "&" & DA_ADD_QUANTITY & "=1" & "&" & DA_PRODUCTID_SELECTED & "=" & xmlProduct.Attributes(CStr(ATTR_PRODUCTID)).Value & "');"
            strOnClickDown = Replace(strOnClickUp, "=1&", "=-1&")
        End If

        Response.Write("	<tr class='Drug ")
        If blnDisabled Then
            Response.Write("NotAvailable")
        End If
        Response.Write("'>" & vbCr)
        Response.Write("		<td valign='bottom'><span class='Description'>")
        Response.Write(strProductName)
        Response.Write("</span><br />" & vbCr)
        Response.Write("			 <span class='Tradename'>")
        Response.Write(strTradename)
        Response.Write("</span>" & vbCr)
        Response.Write("		</td>" & vbCr)
        Response.Write("		" & vbCr)
        Response.Write("		<td class='Location' valign='bottom'>")
        Response.Write(strLocation)
        Response.Write("</td>" & vbCr)
        Response.Write("		<td class='Quantity'>")
        Response.Write(strQty)
        Response.Write("</td>" & vbCr)
        Response.Write("		<td style=""width:160px"">" & vbCr)
        Response.Write("			<table cellpadding='0' cellspacing='1'>" & vbCr)
        Response.Write("				<tr><td style=""border:none"">")
        TouchscreenShared.SpinButton("-", strOnClickDown, (blnDownButtonEnabled And Not blnDisabled))
        Response.Write("</td>" & vbCr)
        Response.Write("				<td style=""border:none"">")
        TouchscreenShared.SpinButton("+", strOnClickUp, (Not blnDisabled))
        Response.Write("</td>" & vbCr)
        Response.Write("				<td style=""border:none"">")
        TouchscreenShared.PictureButtonSmall(strImageAutobutton, strOnClickAutoButton, (Not blnDisabled))
        Response.Write("</td></tr>" & vbCr)
        Response.Write("			</table>			" & vbCr)
        Response.Write("		</td>			" & vbCr)
    End Sub

    Public Sub DisableAllExceptSelectedForm(ByVal dom As XmlDocument)
        'goes through DOM, finds any items which have a selected quantity greater than 0, and
        'marks anything that has a different product form with a disabled indicator.  This is because
        'you wouldn't give half by tablet and half by syrup, for example.
        Dim colSelected As XmlNodeList
        Dim colProducts As XmlNodeList
        Dim xmlProduct As XmlNode
        Dim productFormId As Integer = 0
        Dim intFlagValue As Integer 

        colSelected = DOM.SelectNodes("//" & NODE_PRODUCT & "[@" & ATTR_QUANTITY_SELECTED & "!='0']")
        If colSelected.Count > 0 Then 
            xmlProduct = colSelected(0)
            productFormId = CIntX(xmlProduct.Attributes(CStr(ATTR_PRODUCTFORMID)).Value)
        End IF

        If productFormId > 0 Then 
            'Disable everything with a different formID
            intFlagValue = 1
            colProducts = DOM.SelectNodes("//" & NODE_PRODUCT & "[@" & ATTR_PRODUCTFORMID & "!='" & productFormId & "']")
        Else
            'Nothing is selected, enable everything
            intFlagValue = 0
            colProducts = DOM.selectNodes("//" & NODE_PRODUCT)
        End IF

        For Each xmlProduct In colProducts
            xmlProduct.Attributes(CStr(ATTR_DISABLED)).Value = intFlagValue.ToString()
        Next
    End Sub

End Class