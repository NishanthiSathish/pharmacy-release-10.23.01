<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Prescription" %> 
<%@ Import Namespace="Ascribe.Xml" %>


<!-- 
LM Code 162, 10/01/2008 ,
Removed Reference to Prescription.vb.vb
Imported the namespaces Ascribe.Common.Prescription
-->


<%
    SessionID = CInt(Request.QueryString("SessionID"))
    ProductID = Generic.CIntX(Request.QueryString("ProductID"))
    ProductRouteID = Generic.CIntX(Request.QueryString("RouteID"))
    Select Case LCase(Request.QueryString("Mode"))
    Case "allroutes"
        WriteAllRoutesXML()
    Case "frequency"
        WriteFrequencyTemplatesXML()
    Case "doseunits"
        WriteDoseUnitsXML()
    Case "approvedroutes"
        WriteApprovedRoutesXML()
    Case "arbtext"
        WriteArbTextXML()
    Case "formbyroute"
        WriteFormOptionsByRoute()
    Case "requesttypes"
        WriteRequestTypesXML()
    End Select
%>

<script language="vb" runat="server">

    '-----------------------------------------------------------------------------------------
    'PrescriptionLoader.aspx
    '
    '
    'Asyncronous loader page for the prescription custom control
    '
    '
    'Modification History:
    '06Mar03 AE  Written
    '06Jun03 AE  Added DoseUnits mode for the nurse admin control
    '14Nov06 AE  WriteFormOptionsByRoute:  written for #DR-05-0139
    '
    '-----------------------------------------------------------------------------------------
    Const ARBTEXTTYPE_DIRECTIONTEXT As String = "Direction Text"
    Const ARBTEXTTYPE_DISPENSING_INSTRUCTION As String = "Dispensing Instruction"
    Dim SessionID As Integer
    Dim ProductID As Integer
    Dim ProductRouteID As Integer
    '------------------------------------------------------------------------------------------
    Sub WriteAllRoutesXML()
        'Script a list of all routes
        Dim DOM As XmlDocument
        Dim objRoutes As XmlElement
        Dim objProductRead As DSSRTL20.ProductRead
        Dim strRouteXML As String 
        Dim blnTopical As Boolean 
        Dim blnInfusion As Boolean 

        blnInfusion = LCase(Request.QueryString("infusion")) = "true"
        blnTopical = LCase(Request.QueryString("topical")) = "true"
        'Determine if we're looking at an injectable doseless form.  If so, we will have a doseless, rather than infusion, prescription type, and
        'we need to set the blnInfusion bit high to return the correct routes.
        If blnTopical Then 
            '13Mar06 AE  Shoehorn in handling for doseless injections, for one drug (subcut insulin) that breaks everything.  *sigh*
            blnInfusion = blnInfusion Or InfusionAvailable(SessionID, CInt(Request.QueryString("ProductID")), "")
        End IF
        objProductRead = new DSSRTL20.ProductRead()
        strRouteXML = objProductRead.GetAllRoutesXML(SessionID, ProductID, blnInfusion, blnTopical)
        '20Apr06 AE  Removed Standard concept #SC-06-0456
        objProductRead = Nothing
        DOM = new XmlDocument()
                                 Dim xmlLoaded As Boolean = False

                                 Try
            DOM.LoadXml(strRouteXML)
                                     xmlLoaded = True
                                 Catch ex As Exception
                                 End Try

                                 If xmlLoaded Then
                                     'Strip the "root" node off
                                     objRoutes = DOM.SelectSingleNode("root/Routes")
                                     Response.Write(objRoutes.OuterXml)
                                 End If
                                 DOM = Nothing
                                 objRoutes = Nothing
                             End Sub

                             '------------------------------------------------------------------------------------------
                             Sub WriteApprovedRoutesXML()
                                 'Script a list of all routes
                                 Dim DOM As XmlDocument
                                 Dim objRoutes As XmlElement
                                 Dim nodRoute As XmlElement
                                 Dim objProductRead As Object ' DSSRTL20.ProductRead
                                 Dim strRouteXML As String
                                 objProductRead = New DSSRTL20.ProductRead()
                                 strRouteXML = objProductRead.GetAllRoutesXML(SessionID, CInt(ProductID), CBool(0), CBool(0))
                                 '20Apr06 AE  Removed Standard concept #SC-06-0456
                                 objProductRead = Nothing
                                 DOM = New XmlDocument()
                                 Dim xmlLoaded As Boolean = False

                                 Try
                                     DOM.LoadXml(strRouteXML)
                                     xmlLoaded = True
                                 Catch ex As Exception
                                 End Try

                                 If xmlLoaded Then
                                     'Strip the "root" node off
                                     objRoutes = DOM.SelectSingleNode("root/Routes")
                                     Response.Write("<Routes>")
                                     For Each nodRoute In objRoutes.SelectNodes("ProductRoute[@Approved='1']")
                                         Response.Write(nodRoute.OuterXml)
                                     Next
                                     Response.Write("</Routes>")
                                 End If
                                 DOM = Nothing
                                 objRoutes = Nothing
                             End Sub

    '--------------------------------------------------------------------------
    Sub WriteFrequencyTemplatesXML()
        Dim objSchedule As Object ' OCSRTL10.SchedTempFreqRead
        Dim strReturn_XML As String 
        'Set objSchedule = Server.CreateObject("OCSRTL10.ScheduleRead")
        objSchedule = new OCSRTL10.SchedTempFreqRead()
        '23Sep05 TH Use proper class
        'strReturn_XML = objSchedule.ListTemplates(SessionID)
        strReturn_XML = objSchedule.GetScheduleTemplateFrequencyList(SessionID, "1")
        '23Sep05 TH Added param
        objSchedule = Nothing
        Response.Write(strReturn_XML)
    End Sub

    '--------------------------------------------------------------------------
    Sub WriteArbTextXML()
        'Read the arb text strings appropriate to the current context.
        'These may be administration instructions, or dispensing instructions.
        'Administration instructions are assumed by default; the Querystring
        'parameter "Type" can specify a different type if present
        Dim objText As Object ' OCSRTL10.ArbitraryTextRead
        Dim strText_XML As String
        strText_XML = ""
        Dim strForm As String 
        Dim strArbTextType As String 
        Dim strType As String 
        'Determine which type of ArbText we are looking for
        strType = ARBTEXTTYPE_DIRECTIONTEXT
        If LCase(Request.QueryString("type")) = "dispensinginstruction" Then 
            strType = ARBTEXTTYPE_DISPENSING_INSTRUCTION
        End IF
        'Form will either hold a product form, or the token "chemical" which indicates that
        'no form has yet been chosen.
        strForm = LCase(Request.QueryString("Form"))
        If strForm <> "chemical" Then 
            'A form has been chosen; first look for text strings particular to this form.
            'These are specified by the naming convention "Direction Text [<Form>]" or "DispensingInstruction [<Form>]"
            strArbTextType = strType & " [" & strForm & "]"
            objText = new OCSRTL10.ArbitraryTextRead()
            strText_XML = objText.GetTextByTypeName(SessionID, strArbTextType, True)
            objText = Nothing
        End IF
        If Len(strText_XML) <= 13 Then 
            '<root></root> (an empty result set) is 13 chars
            'Just return the generic Direction Text strings
            objText = new OCSRTL10.ArbitraryTextRead()
            strText_XML = objText.GetTextByTypeName(SessionID, strType, True)
            objText = Nothing
        End IF
        Response.Write(strText_XML)
    End Sub

    '--------------------------------------------------------------------------
    Sub WriteDoseUnitsXML()
        'Return the available dose units for the productID specified
        Dim objProduct As Object ' DSSRTL20.ProductRead
        Dim strReturn_XML As String 
        objProduct = new DSSRTL20.ProductRead()
        strReturn_XML = objProduct.PrescribableUnitsXML(SessionID, CInt(ProductID))
        objProduct = Nothing
        Response.Write(strReturn_XML)
    End Sub

    '--------------------------------------------------------------------------
    Sub WriteFormOptionsByRoute()
        '14Nov06 AE  Written for #DR-05-0139
        Dim objProduct As Object ' DSSRTL20.ProductRead
        Dim DOM As XmlDocument
        Dim colForms As XmlNodeList
        Dim xmlForm As XmlElement
        Dim strForm_XML As String 
        objProduct = new DSSRTL20.ProductRead()
        strForm_XML = objProduct.GetProductFormByChemicalAndRouteXML(SessionID, CInt(ProductID), CInt(ProductRouteID))
        objProduct = Nothing
        DOM = new XmlDocument()
        DOM.TryLoadXml(strForm_XML)
        colForms = DOM.SelectNodes("root/ProductForm")
        Response.Write("<option dbid='0'>Any</option>" & vbCr)
        For Each xmlForm In colForms
            Response.Write("<option dbid='" & xmlForm.GetAttribute("ProductFormID") & "' >" & xmlForm.GetAttribute("Description") & "</option>" & vbCr)
        Next
        xmlForm = Nothing
        colForms = Nothing
        DOM = Nothing
    End Sub

    '--------------------------------------------------------------------------
    Sub WriteRequestTypesXML()
        Dim objRequest As OCSRTL10.RequestTypeRead
        Dim objTable As ICWRTL10.TableRead
        Dim TableID As Integer
        Dim strRequest_XML As String = String.Empty
        objTable = new ICWRTL10.TableRead()
        TableID = objTable.GetIDFromDescription(SessionID, "ReviewRequest")
        objTable = Nothing
        If CInt(TableID) > 0 Then 
            objRequest = new OCSRTL10.RequestTypeRead()
            strRequest_XML = objRequest.RequestTypeByTableXML(SessionID, CInt(TableID))
            objRequest = Nothing
        End IF
        Response.Write(strRequest_XML)
    End Sub

</script>