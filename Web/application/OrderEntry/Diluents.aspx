<%@ Page Language="vb" %>

<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common.Prescription" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.OrderEntry" %>
<%@ Import Namespace="Ascribe.Xml" %>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Reconstitution and Dilution</title>

    <script language="javascript" src="scripts/diluents.js"></script>
    <script language="javascript" src="../sharedscripts/controls.js"></script>
    <script language="javascript" src="../sharedscripts/icwfunctions.js"></script>
    <link rel="stylesheet" type="text/css" href="../../style/diluents.css" />
</head>
<%


    '
    ' Diluents.aspx
    '
    ' Displays the main diluent editing dialog as a modal dialog
    '
    ' Apr08     ST      Written
    ' 29Jan10   Rams    F0074560 + F0074584 :Handled to convert Unit of Volume into Unit of Mass 
    '
    Dim lngSessionID As Integer
    Dim lngRequestID As Integer
    Dim objDiluent As XmlElement
    Dim colDiluents As XmlNodeList
    Dim objDevices As XmlElement
    Dim colDevices As XmlNodeList
    Dim blnTemplateMode As Boolean
    Dim blnDisplayMode As Boolean
    
    Dim xmlNode As XmlElement
    Dim colNodes As XmlNodeList
    Dim objReconstitution As XmlElement
    Dim objProductRead As DSSRTL20.ProductRead = New DSSRTL20.ProductRead()

    'Prescription Information
    Dim DOMPrescription As XmlDocument
    
    'Diluent Information
    Dim DOMDiluentInformation As XmlDocument
    
    'Reconstitution Information
    Dim DOMReconstitution As XmlDocument = New XmlDocument()
    
    Dim lngReconstitutionVolume As Integer
    Dim lngReconstitutionConcentration As Integer
    Dim lngReconstitutionDisplacementVolume As Integer
    Dim lngReconstitutionProductID As Integer
    Dim strReconstitutionProductName As String
    Dim lngReconstitutionVialsRequired As Integer
    Dim lngReconstitutionVialSize As Integer
    Dim lngReconstitutionIngredientID As Integer
    
    Dim blnRateBased As Boolean
    Dim blnIsPrimary As Boolean
    Dim objProduct As XmlElement
    Dim blnIsSolid As Boolean
    Dim PrescribedUnitType As String = ""
    Dim StrengthUnitType As String = ""
    Dim dblResult As Double
    
    ' Product Details
    Dim lngProductID As Integer
    Dim strProductName As String
    Dim strPrimaryIngredient As String
    
    ' Product Dose Information
    Dim dblDose As Double
    Dim dblPrimaryIngredientDose As Double
    Dim strDoseUnit As String
    Dim strRoutine As String = ""
    
    ' Duration Based Infusions
    Dim lngDuration_Min As Integer
    Dim lngDuration_Max As Integer
    Dim strDurationTime_Unit As String
    
    ' Rate Based Infusion
    Dim lngMin_Rate As Integer
    Dim lngMax_Rate As Integer
    Dim lngStarting_Rate As Integer
    Dim strRate_Dose_Unit As String
    Dim strRate_Routine As String
    Dim strRate_Time_Unit As String
    
    '
    Dim dblIngredientDose As Double
    Dim strIngredientDoseUnit As String
    Dim IngredientDose_UnitID As Integer
    Dim Strength_UnitID As Integer
    '
    Dim strStartingRate As String
    Dim strRateRange As String
    Dim strDiluentInstruction As String
    Dim lngDiluentProductID As Integer
    Dim dblDiluentQty As Double
    Dim dblDiluentFinalVolume As Double
    Dim blnNominal As Boolean
    Dim blnExact As Boolean
    Dim lngDeviceID As Integer
    Dim blnVolumeRequired As Boolean
    Dim lngDiluentInformationID As Integer
    Dim dblFinalConcentration As Double
    
    Dim blnDose_Calculated As Boolean
    Dim blnFinalVolume_Calculated As Boolean
    Dim blnFinalConcentration_Calculated As Boolean
    Dim blnDiluentQuantity_Calculated As Boolean
    Dim lngDoseUnitID As Integer
    
    
    Dim dblStrength As Double
        
    Dim strReconstitution_XML As String
    Dim strDiluentInformation_XML As String
    Dim strPrescription_XML As String
    Dim dblIngredientConcentration As Double

    Dim dblFinalConcentration_New As Double
    Dim lngDoseUnitID_New As Integer
    Dim strDoseUnit_New As String = String.Empty
    Dim dblIngredientConcentration_New As Double
    Dim blnDiluentMissing As Boolean
    Dim DoReCalculate As String = "false"
    Dim RecipeUnit As String
    Dim RecipeUnitID As Integer
    Dim bDataChanged As Boolean = False
    Dim NewTemplate As Boolean = False
    Dim OrderTemplateID As Integer
    Dim Mode As String = String.Empty
    
    'Initialise variables
    strStartingRate = ""
    strRateRange = ""
    blnRateBased = False
    lngReconstitutionVolume = 0
    lngReconstitutionConcentration = 0
    lngReconstitutionDisplacementVolume = 0
    lngReconstitutionProductID = 0
    strReconstitutionProductName = ""
    lngReconstitutionVialsRequired = 0
    lngReconstitutionVialSize = 0
    lngReconstitutionIngredientID = 0
    strReconstitution_XML = ""
    strDiluentInformation_XML = ""
    strDiluentInstruction = ""
    lngDiluentProductID = 0
    dblDiluentQty = 0
    dblDiluentFinalVolume = 0
    '24Mar2010 CD F0081306 Nominal to be the default setting
    blnNominal = True
    blnExact = False
    lngDeviceID = 0
    blnVolumeRequired = False
    dblStrength = 0
    dblFinalConcentration = 0
    strRate_Time_Unit = ""
    strDurationTime_Unit = ""
    strRate_Routine = ""
    strRate_Dose_Unit = ""
    dblResult = 0
    
    blnDose_Calculated = False
    blnFinalVolume_Calculated = False
    blnFinalConcentration_Calculated = False
    blnDiluentQuantity_Calculated = False
    
    'Get session stuff
    lngSessionID = CInt(Request.QueryString("SessionID"))
    lngRequestID = CInt(Request.QueryString("RequestID"))
    blnTemplateMode = Request.QueryString("TemplateMode")
    blnDisplayMode = Request.QueryString("DisplayMode")
    OrderTemplateID = CInt(Request.QueryString("OrderTemplateID"))
    
    'F0082399 ST 30Mar10
    'Determine if this is template mode and editing a brand new template
    NewTemplate = IIf(blnTemplateMode And OrderTemplateID = -1, True, False)
    
    Mode = IIf(Request.QueryString("Mode") = Nothing, "", Request.QueryString("Mode"))
    
    '
    DoReCalculate = IIf(Request.QueryString("ReCalculate") = Nothing, "", Request.QueryString("ReCalculate"))
    '
    'Get diluents and devices
    colDiluents = GetDiluents(lngSessionID)
    colDevices = GetInfusionDevices(lngSessionID)
    
    'Get incoming prescription data
    strPrescription_XML = Request.Form("txtPrescription_XML")
    '
    
    If strPrescription_XML = "" Then
        ' In from the prescribing form so we load everything from that block of xml
        strPrescription_XML = Ascribe.Common.Generic.SessionAttribute(lngSessionID, "OrderEntry/Diluent")
        strPrescription_XML = strPrescription_XML.Replace("""", "'")

        DOMPrescription = New XmlDocument
        Dim xmlLoaded As Boolean = False

        Try
            DOMPrescription.LoadXml(strPrescription_XML)
            xmlLoaded = True
        Catch ex As Exception
        End Try

        If xmlLoaded Then
            xmlNode = DOMPrescription.SelectSingleNode("root/Diluents")
            If Not xmlNode Is Nothing Then
                strDiluentInformation_XML = "<root>" & xmlNode.OuterXml & "</root>"
                strDiluentInformation_XML = strDiluentInformation_XML.Replace("""", "'")
            End If

            xmlNode = DOMPrescription.SelectSingleNode("root/Diluents/Reconstitution")
            If Not xmlNode Is Nothing Then
                strReconstitution_XML = "<root>" & xmlNode.OuterXml & "</root>"
                strReconstitution_XML = strReconstitution_XML.Replace("""", "'")
            End If
        End If
    Else
        'Get any Reconstitution data that is being passed around.
        If Request.Form("txtReconstitution_XML") <> "" Then
            strReconstitution_XML = Request.Form("txtReconstitution_XML")
            strReconstitution_XML = strReconstitution_XML.Replace("""", "'")
        End If

        'Get any Diluent data that is being passed around.
        If Request.Form("txtDiluent_XML") <> "" Then
            strDiluentInformation_XML = Request.Form("txtDiluent_XML")
            strDiluentInformation_XML = strDiluentInformation_XML.Replace("""", "'")
        End If
    End If
	
    DOMDiluentInformation = New XmlDocument
    DOMDiluentInformation.TryLoadXml(strDiluentInformation_XML)
            
    xmlNode = DOMDiluentInformation.SelectSingleNode("root/Diluents/Product")
    If Not xmlNode Is Nothing Then
        strDiluentInstruction = xmlNode.GetAttribute("Instruction")
                
        If Not xmlNode.GetAttribute("DiluentProductID") Is Nothing Then
            If xmlNode.GetAttribute("DiluentProductID") <> "" Then
                lngDiluentProductID = CInt(xmlNode.GetAttribute("DiluentProductID"))
            End If
        End If
    
        If Not xmlNode.GetAttribute("DiluentQty") Is Nothing AndAlso xmlNode.GetAttribute("DiluentQty") <> "" Then
            dblDiluentQty = CDblX(xmlNode.GetAttribute("DiluentQty"))
        End If
                
        '        If Not xmlNode.GetAttribute("DiluentFinalVolume") Is Nothing AndAlso xmlNode.GetAttribute("DiluentFinalVolume") <> "" Then
        dblDiluentFinalVolume = CDblX(xmlNode.GetAttribute("DiluentFinalVolume"))
        '        End If
            
        '24Mar2010 CD F0081306 We are now not setting nominal and exact automatically but keeping
        'whatever the user selected
        If xmlNode.GetAttribute("Nominal") = "1" Then
            blnNominal = True
        Else
            blnNominal = False
        End If
                
        If xmlNode.GetAttribute("Exact") = "1" Then
            blnExact = True
        Else
            blnExact = False
        End If
        
        '        If Not xmlNode.GetAttribute("FinalConcentration") Is Nothing AndAlso xmlNode.GetAttribute("FinalConcentration") <> "" Then
        dblFinalConcentration = CDblX(xmlNode.GetAttribute("FinalConcentration"))
        '        End If
                
        '        If Not xmlNode.GetAttribute("DeviceID") Is Nothing AndAlso xmlNode.GetAttribute("DeviceID") <> "" Then
        lngDeviceID = CIntX(xmlNode.GetAttribute("DeviceID"))
        '        End If
        
        '        If Not xmlNode.GetAttribute("DiluentInformationID") Is Nothing AndAlso xmlNode.GetAttribute("DiluentInformationID") <> "" Then
        lngDiluentInformationID = CIntX(xmlNode.GetAttribute("DiluentInformationID"))
        '        End If
        
        
        '        If Not xmlNode.GetAttribute("Dose_Calculated") Is Nothing AndAlso xmlNode.GetAttribute("Dose_Calculated") <> "" Then
        blnDose_Calculated = CBoolX(xmlNode.GetAttribute("Dose_Calculated"))
        '        End If
        '        If Not xmlNode.GetAttribute("FinalVolume_Calculated") Is Nothing AndAlso xmlNode.GetAttribute("FinalVolume_Calculated") <> "" Then
        blnFinalVolume_Calculated = CBoolX(xmlNode.GetAttribute("FinalVolume_Calculated"))
        '        End If
        '        If Not xmlNode.GetAttribute("FinalConcentration_Calculated") Is Nothing AndAlso xmlNode.GetAttribute("FinalConcentration_Calculated") <> "" Then
        blnFinalConcentration_Calculated = CBoolX(xmlNode.GetAttribute("FinalConcentration_Calculated"))
        '        End If
        '        If Not xmlNode.GetAttribute("DiluentQuantity_Calculated") Is Nothing AndAlso xmlNode.GetAttribute("DiluentQuantity_Calculated") <> "" Then
        blnDiluentQuantity_Calculated = CBoolX(xmlNode.GetAttribute("DiluentQuantity_Calculated"))
        '        End If
    End If
    strPrescription_XML = strPrescription_XML.Replace("""", "'")

    DOMPrescription = New XmlDocument()
    DOMPrescription.TryLoadXml(strPrescription_XML)

    'F0082399 30Mar10 ST If its a brand new template then set up default reconstitution data for the products
    If NewTemplate Then
        strReconstitution_XML = "<root><Reconstitution>"
        colNodes = DOMPrescription.SelectNodes("root/Product")
                
        For Each xmlNode In colNodes
            strReconstitution_XML += "<Product ProductID='" + xmlNode.GetAttribute("ProductID") + "' ReconstitutionRequired='0' DoseRequired='0' VialSize='0' ReconstituteProductID='0' ReconstituteProductName='' DisplacementVolume='0' Concentration='0' Volume='0' Concentration_Calculated='0' Instruction='' Concentration_Unit='' Concentration_UnitID='0' />"
        Next
        
        strReconstitution_XML += "</Reconstitution></root>"
    End If
    
    
    
    If strReconstitution_XML <> "" Then
        DOMReconstitution.TryLoadXml(strReconstitution_XML)
    End If
    
    If strDiluentInformation_XML <> "" Then
        DOMDiluentInformation = New XmlDocument()
        DOMDiluentInformation.TryLoadXml(strDiluentInformation_XML)
    End If
    
    
    
    xmlNode = DOMPrescription.SelectSingleNode("//attribute[@name='RateMin']")
    If Not xmlNode Is Nothing Then
        If xmlNode.GetAttribute("value") <> "" Then
            lngMin_Rate = CInt(xmlNode.GetAttribute("value"))
        Else
            lngMin_Rate = -1
        End If
        
        ' set flag to indicate rate based infusion
        blnRateBased = True
        
        xmlNode = DOMPrescription.SelectSingleNode("//attribute[@name='RateMax']")
        If Not xmlNode Is Nothing Then
            If xmlNode.GetAttribute("value") <> "" Then
                lngMax_Rate = CInt(xmlNode.GetAttribute("value"))
            Else
                lngMax_Rate = -1
            End If
        End If

        xmlNode = DOMPrescription.SelectSingleNode("//attribute[@name='RateStart']")
        If Not xmlNode Is Nothing Then
            If xmlNode.GetAttribute("value") <> "" Then
                lngStarting_Rate = CInt(xmlNode.GetAttribute("value"))
            Else
                lngStarting_Rate = -1
            End If
        End If

        xmlNode = DOMPrescription.SelectSingleNode("//attribute[@name='DoseUnit']")
        If Not xmlNode Is Nothing Then
            strRate_Dose_Unit = xmlNode.GetAttribute("value")
        End If
        
        xmlNode = DOMPrescription.SelectSingleNode("//attribute[@name='Routine']")
        If Not xmlNode Is Nothing Then
            strRate_Routine = xmlNode.GetAttribute("value")
        End If
        
        xmlNode = DOMPrescription.SelectSingleNode("//attribute[@name='TimeUnit']")
        If Not xmlNode Is Nothing Then
            strRate_Time_Unit = xmlNode.GetAttribute("value")
        End If
    End If
    

    If blnRateBased = False Then
        ' Get duration based infusion values
        
        xmlNode = DOMPrescription.SelectSingleNode("//attribute[@name='Duration_Min']")
        If Not xmlNode Is Nothing Then
            If xmlNode.GetAttribute("value") <> "" Then
                lngDuration_Min = CInt(xmlNode.GetAttribute("value"))
            Else
                lngDuration_Min = 0
            End If
        End If
    
        xmlNode = DOMPrescription.SelectSingleNode("//attribute[@name='Duration_Max']")
        If Not xmlNode Is Nothing Then
            If xmlNode.GetAttribute("value") <> "" Then
                lngDuration_Max = CInt(xmlNode.GetAttribute("value"))
            Else
                lngDuration_Max = 0
            End If
        End If
    
        xmlNode = DOMPrescription.SelectSingleNode("//attribute[@name='Duration_TimeUnit']")
        If Not xmlNode Is Nothing Then
            strDurationTime_Unit = xmlNode.GetAttribute("value")
        End If
    End If
    
    ' get the primary product name for display on the form
    objProduct = DOMPrescription.SelectSingleNode("root/Product[@IsPrimary='true']")
    If Not objProduct Is Nothing Then
        strPrimaryIngredient = objProduct.GetAttribute("ProductName")
    Else
        strPrimaryIngredient = ""
    End If
%>
<body sid="<%= lngSessionID %>" requestid="<%=lngRequestID %>" diluentinfoid="<%=lngDiluentInformationID %>" templatemode="<%=blnTemplateMode %>" displaymode="<%=blnDisplayMode %>" mode="<%=Mode %>" onload="window_onload();">
    <div>
        <form id="frmDiluents" method="post" action="">
        <table id="tblDiluents" cellpadding="2" cellspacing="2" border="0" style="font-family: trebuchet ms; font-size: 14px; color: #000000;">
            <tr>
                <td colspan="3" align="left" style="font-family: trebuchet ms; font-size: 18px; font-weight: Bold;color: #000000;">
                    Dose Prescribed
                </td>
            </tr>
            <%
                colNodes = DOMPrescription.SelectNodes("root/Product")
                
                For Each xmlNode In colNodes
                    lngProductID = CInt(xmlNode.GetAttribute("ProductID"))
                    blnIsPrimary = CBool(xmlNode.GetAttribute("IsPrimary"))
                
                    If xmlNode.GetAttribute("Dose").ToString() <> "" Then
                        dblDose = CDbl(xmlNode.GetAttribute("Dose"))
                        If blnIsPrimary Then
                            dblPrimaryIngredientDose = dblDose
                        End If
                    Else
                        dblDose = 0
                    End If
                    '
                    blnIsSolid = True
                    If objProductRead.GetProductState(lngSessionID, lngProductID) = "Liquid" Then blnIsSolid = False
                    '
                    xmlNode.SetAttribute("IsSolid", blnIsSolid) 'Update/ Create a Attribute as this xml will be used for parsing again in the bottom of the form
                    '
                    RecipeUnit = ""
                    dblStrength = objProductRead.GetLiquidStrengthWithUnit(lngSessionID, lngProductID, RecipeUnitID, RecipeUnit)
                    '
                    xmlNode.SetAttribute("Strength", dblStrength)
                    xmlNode.SetAttribute("StrengthUnitID", RecipeUnitID)
                    '
                    If Not blnIsSolid AndAlso dblDose > 0 AndAlso dblStrength > 0 Then
                        '
                        'Here goes the unit type id we are interested in determining Volume Unit Type.
                        'Determine the Unit type from Unit 
                        'We assume we will get the Abbreviation from Unit in all scenarios.
                        '
                        PrescribedUnitType = objProductRead.GetUnitTypeFromUnitID(lngSessionID, xmlNode.GetAttribute("DoseUnitID"))
                        '
                        ' F0083669 ST 16Apr10 If the strength unit is in ratio or concentration then leave the dosing as is
                        StrengthUnitType = objProductRead.GetUnitTypeFromUnitID(lngSessionID, xmlNode.GetAttribute("StrengthUnitID"))

                        Select Case StrengthUnitType.ToLower()
                            Case "ratio", "concentration"
                            Case Else
                                If PrescribedUnitType.ToUpper() = "VOLUME" Then
                                    dblDose = dblDose * dblStrength
                                    'Update dblDose for later use
                                    xmlNode.SetAttribute("Dose", dblDose)
                                    xmlNode.SetAttribute("UnitType", "VOLUME")
                                    'Change all those Unit of Volume to Unit of Mass
                                    'Retain the Prescribe ones with prefixed Prescribed
                                    xmlNode.SetAttribute("PrescribedUnit", xmlNode.GetAttribute("DoseUnit"))
                                    xmlNode.SetAttribute("PrescribedUnitID", xmlNode.GetAttribute("DoseUnitID"))
                                    'Modify the Existing on the XML with unit of Mass
                                    xmlNode.SetAttribute("DoseUnitID", RecipeUnitID)
                                    xmlNode.SetAttribute("DoseUnit", RecipeUnit)
                                    'set the flag as the xml will be used on other forms
                                    bDataChanged = True
                                End If
                        End Select
                        '
                    End If
                    '
                    
                    strDoseUnit = xmlNode.GetAttribute("DoseUnit")
                    lngDoseUnitID = xmlNode.GetAttribute("DoseUnitID")
                    strRoutine = xmlNode.GetAttribute("Routine")
                    strProductName = xmlNode.GetAttribute("ProductName")
            %>
            <tr id="trDosePrescribed">
                <td width="40%" style="background-color: #B5C7F7; height: 30px;">
                    <%=strProductName%>
                </td>
                <%
                    If blnIsPrimary = False Then
                        Response.Write("<td id=""tdIngredientPrescribed"" width=""60%"" colspan=""2"" ")
                        Response.Write("Unit=""")
                        Response.Write(strDoseUnit)
                        Response.Write("""")
                        Response.Write("IsPrimary=""false"" Dose=""")
                        Response.Write(dblDose)
                        Response.Write(""" ")
                        Response.Write("Routine=""")
                        Response.Write(strRoutine)
                        Response.Write(""" ")
                        Response.Write("ProductID=""")
                        Response.Write(lngProductID)
                        Response.Write(""" unitid='" & lngDoseUnitID & "' >")
                        Response.Write(dblDose)
                        Response.Write(strDoseUnit)
                        '
                        If strRoutine <> "" And blnTemplateMode = True Then
                            Response.Write(" per " & strRoutine)
                        End If
                        
                        Response.Write("</td>")
                    Else
                        Response.Write("<td id=""tdPrimaryIngredientPrescribed"" width=""60%"" colspan=""2"" ")
                        Response.Write("Unit=""")
                        Response.Write(strDoseUnit)
                        Response.Write("""")
                        Response.Write("IsPrimary=""true"" Dose=""")
                        Response.Write(dblDose)
                        Response.Write(""" unitid='" & lngDoseUnitID & "' ")
                        Response.Write("Routine=""")
                        Response.Write(strRoutine)
                        Response.Write(""" ")
                        Response.Write("ProductID=""")
                        Response.Write(lngProductID)
                        Response.Write(""">")
		                
                        If blnRateBased = False Then
                            ' non rate based infusion
                            Response.Write(dblDose)
                            Response.Write(strDoseUnit)
		            
                            If strRoutine <> "" And blnTemplateMode = True Then
                                Response.Write(" per " & strRoutine)
                            End If
				            
                            If lngDuration_Min > 0 Then
                                ' infusion over
                                Response.Write(" as Infusion Over " & lngDuration_Min)
                                If lngDuration_Max > 0 Then
                                    Response.Write(" to " & lngDuration_Max & " ")
                                End If
                                Response.Write(strDurationTime_Unit)
                            Else
                                ' bolus
                                Response.Write(" as Bolus Injection")
                            End If
                        Else
                            ' Rate based infusion
		       
                            If Not IsDBNull(dblDose) AndAlso dblDose > 0 Then
                                Response.Write(dblDose)
                                Response.Write(strDoseUnit)
                                If strRoutine <> "" Then
                                    Response.Write(" per " & strRoutine)
                                End If
                            Else
                                Response.Write("[Dose Not Specified]")
		        				  
                            End If
		        			  
                            If strRate_Routine = "undefined" Then strRate_Routine = ""
                            If lngStarting_Rate > 0 And strRate_Dose_Unit <> "" Then
                                If lngStarting_Rate > 0 And lngMin_Rate > 0 And lngMax_Rate > 0 Then
                                    ' starting rate
                                    Response.Write(" at a starting rate of " & lngStarting_Rate & strRate_Dose_Unit)
                                    If strRate_Routine <> "" Then
                                        Response.Write(" per " & strRate_Routine)
                                    End If
                                    Response.Write(" per " & strRate_Time_Unit)
			                        
                                    ' minimum rate
                                    Response.Write(", varying between " & lngMin_Rate & strRate_Dose_Unit)
                                    If strRate_Routine <> "" Then
                                        Response.Write(" per " & strRate_Routine)
                                    End If
                                    Response.Write(" per " & strRate_Time_Unit)

                                    ' maximum rate
                                    Response.Write(" and " & lngMax_Rate & strRate_Dose_Unit)
                                    If strRate_Routine <> "" Then
                                        Response.Write(" per " & strRate_Routine)
                                    End If
                                    Response.Write(" per " & strRate_Time_Unit)
                                Else
                                    If lngStarting_Rate > 0 Then
                                        Response.Write(" at a rate of " & lngStarting_Rate & strRate_Dose_Unit)
                                        If strRate_Routine <> "" Then
                                            Response.Write(" per " & strRate_Routine)
                                        End If
                                        Response.Write(" per " & strRate_Time_Unit)
                                    End If
                                End If
                            Else
                                Response.Write(" [rate not specified]")
                            End If

                        End If
                        Response.Write("</td>")
                    End If
                %>
            </tr>
            <%                    
            Next
            If bDataChanged Then
                'We have xml modified in case of volume for unit and Dose
                strPrescription_XML = DOMPrescription.OuterXml
                strPrescription_XML = strPrescription_XML.Replace("""", "'")
            End If
            %>
            <tr>
                <td colspan="3">
                    <hr />
                </td>
            </tr>
            <tr>
                <td colspan="3" align="left" style="font-family: trebuchet ms; font-size: 18px; font-weight: Bold;
                    color: #000000;">
                    Dilution
                </td>
            </tr>
            <tr>
                <td colspan="3" align="left">
                    <i>This section allows you to specify a diluent, and calculate volumes and concentrations.<br />
                        Note that concentration is expressed in terms of the Primary ingredient,
                        <%=strPrimaryIngredient%></i>
                </td>
            </tr>
            <tr id="trDiluent">
                <td style="background-color: #B5C7F7; height: 30px;">
                    Diluent Fluid
                </td>
                <td colspan="2">
                    <select id="selDiluents" name="selDiluents" onblur="CheckIfComplete();" onchange="CheckIfComplete();">
                        <%
                            ' Check diluent exits in the list
                            blnDiluentMissing = (lngDiluentProductID > 0)
                            For Each objDiluent In colDiluents
                                If objDiluent.getattribute("ProductID") = lngDiluentProductID Then
                                    blnDiluentMissing = False
                                End If
                            Next

                            'F0078219 19Feb10 ST Updated again, now we show a blank diluent all the time
                            'If blnTemplateMode Or blnDisplayMode Or blnDiluentMissing Then
                            '13May08 ST - Add blank diluent if in template mode or now infact in display mode (F0036765)
                            Response.Write("<option dbid=""-1"" productid=""0"" productname=""""></option>")
                            'End If
                                        
                            For Each objDiluent In colDiluents
                                Response.Write("<option dbid=""")
                                Response.Write(objDiluent.getattribute("ProductID"))
                                Response.Write(""" ")
                                Response.Write("productid=""")
                                Response.Write(objDiluent.getattribute("ProductID"))
                                Response.Write(""" ")
                                Response.Write("productname=""")
                                Response.Write(objDiluent.getattribute("Description"))
                                Response.Write(""" ")
                        
                                If CInt(objDiluent.GetAttribute("ProductID")) = lngDiluentProductID Then
                                    Response.Write(" selected ")
                                End If
                        
                                Response.Write(">")
                                Response.Write(objDiluent.getattribute("Description"))
                                Response.Write("</option>")
                            Next
                        %>
                    </select>
                </td>
            </tr>
            <tr>
                <td style="background-color: #B5C7F7; height: 30px;">
                    Quantity of Diluent
                </td>
                <td colspan="2">
                    <%
                        '24Mar2010 CD F0081306 Made the diluent quantity field readonly
                        Response.Write("<input type=""text"" readonly=""readonly"" class=""readonly"" id=""txtDiluentQty"" name=""txtDiluentQty"" iscalculated=""" & blnDiluentQuantity_Calculated & """ ")
                        If blnDiluentQuantity_Calculated = True Then
                            Response.Write("calculated=""" & dblDiluentQty & """ class='readonly calculated' ")
                        Else
                            Response.Write("calculated="""" ")
                        End If
                        Response.Write("value=""" & Format(dblDiluentQty, "0.##") & """ maxlength=""10"" size=""6"" validchars=""NUMBERS"" onkeypress=""MaskInput(this);"" onpaste=""MaskInput(this);"" onfocus=""RecordChanges(this);"" onblur=""if(Changed(this)){SetFlags(this);txtDiluentQty_onblur(true);}CheckIfComplete();"" /> mL&nbsp;&nbsp;&nbsp;&nbsp;")
	
                        '24Mar2010 CD F0081306 Moved the nominal and exact radio buttons down a row
                        'Response.Write("<input type=""radio"" id=""rbDiluentQtyNominal"" name=""rbDiluentQtyNominal"" value="""" ")
                        'If blnNominal = True Then
                        '    Response.Write(" checked ")
                        'End If

                        'Response.Write("onblur=""CheckIfComplete();"" onclick=""rbDiluentQtyNominal_onclick(true);CheckIfComplete();""/><b>NOMINAL</b> value&nbsp;&nbsp;")
                        'Response.Write("<input type=""radio"" id=""rbDiluentQtyExact"" name=""rbDiluentQtyExact"" value="""" ")
                        'If blnExact = True Then
                        '    Response.Write(" checked ")
                        'End If
                        'Response.Write("onblur=""CheckIfComplete();"" onclick=""rbDiluentQtyExact_onclick(true);CheckIfComplete();""/><b>EXACT</b> value")
                    %>
                </td>
            </tr>
            <tr>
                <td style="background-color: #B5C7F7; height: 30px;">
                    Final Volume
                </td>
                <td width="400">
                    <%
                        Response.Write("<input type=""text"" id=""txtDiluentFinalVolume"" name=""txtDiluentFinalVolume"" iscalculated=""" & blnFinalVolume_Calculated & """ ")
                        If blnFinalVolume_Calculated = True Then
                            Response.Write("calculated=""" & dblDiluentFinalVolume & """  class='calculated' ")
                        Else
                            Response.Write("calculated="""" ")
                        End If
                        Response.Write("value=""" & Format(dblDiluentFinalVolume, "0.##") & """ maxlength=""10"" size=""6"" validchars=""NUMBERS"" onkeypress=""MaskInput(this);"" onpaste=""MaskInput(this);"" onfocus=""RecordChanges(this);"" onblur=""if(Changed(this)){SetFlags(this);txtDiluentFinalVolume_onblur(true)} CheckIfComplete();""/> mL")
	
                        '24Mar2010 CD F0081306 Moved the nominal and exact radio buttons down a row
                        Response.Write("<div width=""250px;"">")
                        Response.Write("<input style=""margin-left:10px"" type=""radio"" id=""rbDiluentQtyNominal"" name=""rbDiluentQtyNominal"" value="""" ")
                        If blnNominal = True Then
                            Response.Write(" checked ")
                        End If

                        Response.Write("onblur=""CheckIfComplete();"" onclick=""rbDiluentQtyNominal_onclick(true);CheckIfComplete();""/><b>NOMINAL</b> value&nbsp;&nbsp;")
                        Response.Write("<input type=""radio"" id=""rbDiluentQtyExact"" name=""rbDiluentQtyExact"" value="""" ")
                        If blnExact = True Then
                            Response.Write(" checked ")
                        End If
                        Response.Write("onblur=""CheckIfComplete();"" onclick=""rbDiluentQtyExact_onclick(true);CheckIfComplete();""/><b>EXACT</b> value")
                        Response.Write("</div>")
                    %>
                </td>
                <td id="tdDiluentFinalVolume">
                </td>
            </tr>
            <tr id="trFinalConcentrationLabel">
                <td style="background-color: #B5C7F7; height: 30px;">
                    <b>Final Concentrations:</b>
                </td>
                <td colspan="2">
                </td>
            </tr>
            <%
                colNodes = DOMPrescription.SelectNodes("root/Product")
                
                For Each xmlNode In colNodes
                    lngProductID = CInt(xmlNode.GetAttribute("ProductID"))
                    blnIsPrimary = CBool(xmlNode.GetAttribute("IsPrimary"))
                    strProductName = xmlNode.GetAttribute("ProductName")
                    strDoseUnit = xmlNode.GetAttribute("DoseUnit")
                    lngDoseUnitID = xmlNode.GetAttribute("DoseUnitID")
                    dblDose = CDblX(xmlNode.GetAttribute("Dose"))
   		  
            %>
            <tr id="trFinalConcentration">
                <td width="40%" style="background-color: #B5C7F7; height: 30px;">
                    <%=strProductName%>
                </td>
                <%
                    If blnIsPrimary = True Then
                        '12Mar10    Rams    F0080464 - concentration calculated on Reconstitution and Dilution form in template mode where we do not have a patient in context and therefore no Body Surface Area
                        'If the Final Concentration is 0.xxx, we will try to express it in the next unit down.
                        If blnTemplateMode AndAlso strRoutine.Trim().Length > 0 Then
                            'Do not do any Calculation                            
                        Else
                            ConvertToMostAppropriateUnit(lngSessionID, dblFinalConcentration, lngDoseUnitID, dblFinalConcentration_New, lngDoseUnitID_New, strDoseUnit_New)
                        End If
                %>
                <td>
                    <table cellpadding="0" cellspacing="0" border="0" width="100%">
                        <tr>
                            <td width="100">
                                <%	
                                    Response.Write("<input type=""text"" id=""txtPrimaryIngredientConcentration"" name=""txtPrimaryIngredientConcentration"" iscalculated=""" & blnFinalConcentration_Calculated & """ ")
                                    If blnFinalConcentration_Calculated = True Then
                                        Response.Write("calculated=""" & dblFinalConcentration_New & """  class='calculated' ")
                                    Else
                                        Response.Write("calculated="""" ")
                                    End If
                                    Response.Write("value=""" & Format(dblFinalConcentration_New, "0.##") & """ unitid='" & lngDoseUnitID_New & "' unitid_original='" & lngDoseUnitID & "' maxlength=""10"" size=""6"" validchars=""NUMBERS"" onkeypress=""MaskInput(this);"" onpaste=""MaskInput(this);"" onblur=""txtPrimaryIngredientConcentration_onblur(true);CheckIfComplete();""/>")
                                %>
                            </td>
                            <td id='FinalConcentrationUnit_Primary'>
                                <%=strDoseUnit_New%>/mL
                            </td>
                        </tr>
                    </table>
                </td>
                <%
                Else
                    '12Mar10    Rams    F0080464 - concentration calculated on Reconstitution and Dilution form in template mode where we do not have a patient in context and therefore no Body Surface Area
                    If blnTemplateMode AndAlso strRoutine.Trim().Length > 0 Then
                        'Do not do any calculation
                    Else
                        'Calculate the concentration of this ingredient
                        '06Jun08 ST  Check for a division error and trap here
                        If dblDose > 0 And dblDiluentFinalVolume > 0 Then dblIngredientConcentration = dblDose / dblDiluentFinalVolume
                    
                        ConvertToMostAppropriateUnit(lngSessionID, dblIngredientConcentration, lngDoseUnitID, dblIngredientConcentration_New, lngDoseUnitID_New, strDoseUnit_New)
		        	    
                    End If
                    		
                %>
                <td>
                    <table id="tblConcentrationSecondary" cellpadding="0" cellspacing="0" border="0"
                        width="100%">
                        <tr id="trConcentrationSecondary">
                            <td width="100" id="tdIngredientConcentration">
                                <%=Format(dblIngredientConcentration_New, "0.##") %>
                            </td>
                            <td id="tdIngredientConcentrationUnit">
                                <%=strDoseUnit_New %>/mL
                            </td>
                        </tr>
                    </table>
                </td>
                <%
		        	  
                End If
                %>
                <td id="tdDilutionIngredientLabel">
                </td>
            </tr>
            <%                    
            Next
            %>
            <tr id="trCalculationsLink">
                <td colspan="3" align="center">
                    <a href="javascript:CalculationsForm();">View Calculations</a>
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <hr />
                </td>
            </tr>
            <tr>
                <td style="font-family: trebuchet ms; font-size: 18px; font-weight: Bold; color: #000000;">
                    Administration
                </td>
            </tr>
            <tr>
                <td colspan="3" align="left">
                    <i>Specify a device to be used, if required.</i>
                </td>
            </tr>
            <tr>
                <td style="background-color: #B5C7F7; height: 30px;">
                    Administer using this Device
                </td>
                <td colspan="2">
                    <select id="lstDevices" name="lstDevices" onblur="CheckIfComplete();" onchange="lstDevices_onchange();CheckIfComplete();">
                        <%
                            Response.Write("<option dbid=""-1"" volumerequired=""-1"" ")
                            If lngDeviceID = -1 Then
                                Response.Write(" selected ")
                            End If
                            Response.Write(">None</option>")
                        %>
                        <%
                            For Each objDevices In colDevices
                                Response.Write("<option dbid=""")
                                Response.Write(objDevices.getattribute("ProductID"))
                                Response.Write("""")
                                Response.Write(" volumerequired=""")
                                Response.Write(objDevices.getattribute("VolumeRequired"))
                                Response.Write(""" ")
                                If CInt(objDevices.GetAttribute("ProductID")) = lngDeviceID Then
                                    Response.Write(" selected ")
                                    blnVolumeRequired = True
                                End If
                                Response.Write(">")
                                Response.Write(objDevices.getattribute("Description"))
                                Response.Write("</option>")
                            Next
                        %>
                    </select>
                </td>
            </tr>
            <%
                Response.Write("<tr id=""trNoVolumeWarning"" ")
                If blnVolumeRequired = False Then
                    Response.Write("style=""visibility:hidden"">")
                End If
                Response.Write("<td>&nbsp;</td>")
                Response.Write("<td colspan=""2"" align=""left""><b>This device does not require that a diluent volume be specified</b></td>")
                Response.Write("</tr>")
            %>
            <tr>
                <td id="trReconstitutionDivider" colspan="3">
                    <hr />
                </td>
            </tr>
            
            <tr id="trReconstitutionLabel">
                <td colspan="3" align="left" style="font-family: trebuchet ms; font-size: 18px; font-weight: Bold;
                    color: #000000;">
                    Reconstitution and Additive Volume Calculations <span style="font-weight:normal">(Optional)</span>
                </td>
            </tr>
            <tr id="trReconstitutionInstructionLabel">
                <td colspan="3" align="left">
                    <i>Complete this section to enter reconstitution details and to calculate additive volumes.</i>
                </td>
            </tr>
            <%
                colNodes = DOMPrescription.SelectNodes("root/Product")
                
                For Each xmlNode In colNodes
                    lngProductID = CInt(xmlNode.GetAttribute("ProductID"))
                    blnIsPrimary = CBool(xmlNode.GetAttribute("IsPrimary"))
                    strProductName = xmlNode.GetAttribute("ProductName")
                    dblIngredientDose = 0

                    If Not xmlNode.GetAttribute("Dose") Is Nothing Then
                        If xmlNode.GetAttribute("Dose") <> "" Then
                            dblIngredientDose = CDbl(xmlNode.GetAttribute("Dose"))
                        End If
                    End If
	                
                    ' F0083669 ST 16Apr10 All calculated ingredients in template mode should have a 0 dose.
                    'If blnIsPrimary Then
                    If xmlNode.GetAttribute("Routine") <> "" And blnTemplateMode = True Then
                        ' Set the dose to 0 as its a calculated dose in template mode
                        dblIngredientDose = 0
                    End If
                    'End If
	                
                    strIngredientDoseUnit = xmlNode.GetAttribute("DoseUnit")
                    IngredientDose_UnitID = Convert.ToInt32(xmlNode.GetAttribute("DoseUnitID"))
                    Strength_UnitID = Convert.ToInt32(xmlNode.GetAttribute("StrengthUnitID"))
            %>
            <tr id="trReconstitution" isprimary="<%=blnIsPrimary%>">
                <td width="40%" style="background-color: #B5C7F7; height: 30px;">
                    <%=strProductName%>
                </td>
                <%
                    Response.Write("<td width=""40%"" id=""tdReconstitutedIngredients"" ")

                    '29May08 ST Add ProductID to element
                    Response.Write(" productid=""" & lngProductID & """ ")
                    Response.Write(" dose=""" & dblIngredientDose & """ ")
                    '
                    blnIsSolid = xmlNode.GetAttribute("IsSolid")
                    Response.Write(" issolid=""" & blnIsSolid & """ ")
                    '
                    'dblStrength = objProductRead.GetLiquidStrength(lngSessionID, lngProductID)
                    dblStrength = xmlNode.GetAttribute("Strength")
                    Response.Write(" strength=""" & dblStrength & """ ")
                    '
                    If Not blnIsSolid Then
                        If dblIngredientDose > 0 AndAlso dblStrength > 0 Then
                            '
                            'F0083031 ST 08Apr10 Convert ingredient dose and strength to base unit for calculations
                            Dim _UnitConversion As UnitConversion = New UnitConversion(lngSessionID)
                            Dim IngredientDose_Converted As Double
                            Dim IngredientStrength_Converted As Double
                            
                            IngredientDose_Converted = _UnitConversion.ConvertToBaseUnit(dblIngredientDose, IngredientDose_UnitID).ConvertedValue
                            IngredientStrength_Converted = _UnitConversion.ConvertToBaseUnit(dblStrength, Strength_UnitID).ConvertedValue
                            
                            Response.Write(" liquidvolume=""" & IngredientDose_Converted / IngredientStrength_Converted & """ ")
                            'Response.Write(" liquidvolume=""" & dblIngredientDose / dblStrength & """ ")
                        End If
                    End If
                    '

                    If DOMReconstitution Is Nothing Then
                        Response.Write(">")
                        Response.Write("Not Specified")
                    Else
                        objReconstitution = DOMReconstitution.SelectSingleNode("root/Reconstitution/Product[@ProductID='" & lngProductID & "']")
                        If objReconstitution Is Nothing Then
                            Response.Write(">")
                            Response.Write("Not Specified")
                        Else
                            If objReconstitution.GetAttribute("ReconstitutionRequired") = "0" Then
                                Response.Write(">")
                                Response.Write("No Reconstitution Needed")
                            Else
                                ' Have to calculate the number of vials required before we start
                                lngReconstitutionVialsRequired = 0
		                        
                                If Not objReconstitution.GetAttribute("VialSize") Is Nothing AndAlso objReconstitution.GetAttribute("VialSize") <> "" Then
                                    lngReconstitutionVialSize = CInt(objReconstitution.GetAttribute("VialSize"))
                                    If lngReconstitutionVialSize > 0 Then
                                        '28May08 ST Added math.ceiling to round up to nearest whole number
                                        lngReconstitutionVialsRequired = Math.Ceiling(dblIngredientDose / lngReconstitutionVialSize)
                                    End If
                                End If
                                '
                                '
                                If objReconstitution.GetAttribute("Concentration") <> "" Then
                                    Response.Write(" concentration=""" & objReconstitution.GetAttribute("Concentration") & """ ")
                                End If
		                        
                                If lngReconstitutionVialsRequired = 0 Or CInt(objReconstitution.GetAttribute("Volume")) = 0 Or objReconstitution.GetAttribute("ReconstituteProductName") = "" Then
                                    Response.Write(">")
                                    Response.Write("Incomplete")
                                Else
                                    If dblIngredientDose > 0 AndAlso CDblX(objReconstitution.GetAttribute("Concentration")) > 0 Then
                                        dblResult = CDbl(dblIngredientDose) / CDbl(objReconstitution.GetAttribute("Concentration"))
                                        Response.Write(" reconstitutionvolume=""" & FormatNumber(dblResult, 2) & """ ")
                                    Else
                                        Response.Write(" reconstitutionvolume=""0"" ")
                                    End If
		                            
                                    Response.Write(">")
                                    If lngReconstitutionVialsRequired <> 0 Then
                                        Response.Write("Take " & lngReconstitutionVialsRequired & " vials/amps.<br>")
                                    End If
		                        
                                    If objReconstitution.GetAttribute("Volume") <> "" Then
                                        '28May08 AE change cInt to cDBl = reconstitution volume must NOT be forced to integer.
                                        Response.Write("Reconstitute each vial in " & CDbl(objReconstitution.GetAttribute("Volume")) & "mL " & objReconstitution.GetAttribute("ReconstituteProductName"))
                                    End If
                        
                                    If objReconstitution.GetAttribute("Instruction") <> "" Then
                                        Response.Write("<br>" & objReconstitution.GetAttribute("Instruction"))
                                    End If
                                End If
                            End If
                        End If
                    End If
                    
                    Response.Write("</td>")
		            
                    Response.Write("<td width=""20%"" align=""right"">")
                    Response.Write("<a href=""javascript:ReconstitutionForm(")
                    Response.Write(lngProductID)
                    Response.Write(")"";>Change</a></td>")
                %>
            </tr>
            <%                    
            Next
            %>
            <%
                If blnTemplateMode = True Then
            %>
            <tr>
                <td colspan="3" style="font-family: trebuchet ms; font-size: 18px; font-weight: Bold;
                    color: #000000;">
                    Instructions
                </td>
            </tr>
            <tr>
                <td colspan="3" align="left">
                    <i>You may enter further instructions here on how to prepare the dose, if required.</i>
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <textarea cols="95" rows="5" id="txtDiluentInstruction"><%=strDiluentInstruction%></textarea>
                </td>
            </tr>
            <%  
            Else
                If strDiluentInstruction <> "" Then
            %>
            <tr>
                <td colspan="3" style="font-family: trebuchet ms; font-size: 18px; font-weight: Bold;
                    color: #000000;">
                    Instructions
                </td>
            </tr>
            <tr>
                <td colspan="3">
                    <div id="divDiluentInstruction">
                        <%=strDiluentInstruction%></div>
                </td>
            </tr>
            <%
            End If
        End If
            %>
            <tr>
                <td colspan="3">
                    <hr />
                </td>
            </tr>
            <tr id="trIncomplete" style="display: none;">
                <td colspan="3">
                    <table cellpadding="2" cellspacing="2" border="0" style="font-family: trebuchet ms;
                        font-size: 14px; color: #000000;">
                        <tr>
                            <td rowspan="2" valign="top">
                                <img src="../../images/developer/warning.png" border="0" />
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                <b>Incomplete</b>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                &nbsp;
                            </td>
                            <td style="font-family: trebuchet ms; font-size: 12px; color: #000000;">
                                <i>This form does not yet contain all of the information required.<br />
                                    You may still save this form as it is, and you, or another user, can enter the remaining
                                    information later.</i>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
<%--        
            24Mar2010 CD F0081306 removed the no volume specified warning    
            <tr id="trNoVolumeSpecified" style="display: none;">
                <td colspan="3">
                    <table cellpadding="2" cellspacing="2" border="0" style="font-family: trebuchet ms;
                        font-size: 14px; color: #000000;">
                        <tr>
                            <td rowspan="2" valign="top">
                                <img src="../../images/developer/warning.png" border="0" />
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                <b>No Volume Supplied</b>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                &nbsp;
                            </td>
                            <td style="font-family: trebuchet ms; font-size: 12px; color: #000000;">
                                <i>No volumes have been specified.</i>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
--%>            <tr id="trComplete" style="display: none;">
                <td colspan="3">
                    <table cellpadding="2" cellspacing="2" border="0" style="font-family: trebuchet ms;
                        font-size: 14px; color: #000000;">
                        <tr>
                            <td rowspan="2" valign="top">
                                <img src="../../images/developer/tick.png" border="0" />
                            </td>
                            <td>
                                &nbsp;
                            </td>
                            <td>
                                <b>Complete</b>
                            </td>
                        </tr>
                        <tr>
                            <td>
                                &nbsp;
                            </td>
                            <td style="font-family: trebuchet ms; font-size: 12px; color: #000000;">
                                &nbsp;
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td colspan="3" align="right">
                    <% If blnTemplateMode = False AndAlso lngRequestID > 0 Then%>
                    <button id="btnPrint" accesskey="P" style="width: 80px;">
                        <u>P</u>rint</button>&nbsp;&nbsp;<% End If%>
                    <button id="btnOK" accesskey="O" style="width: 80px;" onclick="btnOK_onclick();"
                        <% if lngRequestID > 0 then %> disabled <% end if %>>
                        <u>O</u>k</button>&nbsp;&nbsp;
                    <button id="btnCancel" accesskey="C" style="width: 80px;" onclick="btnCancel_onclick();">
                        <u>C</u>ancel</button>
                </td>
            </tr>
        </table>
        <input type="text" id="txtPrescription_XML" name="txtPrescription_XML" value="<%=strPrescription_XML %>"
            style="visibility: hidden;" />
        <input type="text" id="txtDiluent_XML" name="txtDiluent_XML" value="<%=strDiluentInformation_XML %>"
            style="visibility: hidden;" />
        <input type="text" id="txtReconstitution_XML" name="txtReconstitution_XML" value="<%=strReconstitution_XML %>"
            style="visibility: hidden;" />
        <%
            Response.Write("<input type=""text"" id=""txtDose"" name=""txtDose"" value=""" & dblPrimaryIngredientDose & """ iscalculated=""" & blnDose_Calculated & """ ")
            If blnDose_Calculated = True Then
                Response.Write("calculated=""" & dblPrimaryIngredientDose & """ ")
            Else
                Response.Write("calculated="""" ")
            End If
            Response.Write(" style=""visibility:hidden;"" />")
            '
            '07Apr09    Rams    When changing the value in Reconsitution it needs all the values like FinalVolume , DoseQuantity are to be recalculated
            '                   So,when value is true in the hidden field it indicates the values to be recalculated.
            Response.Write("<input type=""text"" id=""txtReCalculate"" name=""txtReCalculate"" style=""visibility:hidden;"" value=""" & DoReCalculate & """/> ")
        %>
        </form>
    </div>
</body>
</html>
