<%@ Page language="vb" %>

<%@ Import Namespace="Ascribe.Xml" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common.Prescription" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Calculations</title>
    <link rel="stylesheet" type="text/css" href="../../style/diluents.css" />
</head>


<%--28May08 CD - Page was being cached for some reason so stop it!--%>

<%
    Response.CacheControl = "No-cache"
%>


<%
    '
    ' DiluentCalculations.aspx
    '
    ' Displays the diluent calculation information from the diluent dialog.
    '
    '   Apr08 ST  Written
    ' 13May08 ST  Updated so that concentration section is not split when multiple ingredients are in the template.
    
    Dim lngSessionID As Integer
    Dim colProducts As XmlNodeList
    Dim xmlProduct As XmlElement = Nothing
    Dim objReconstitution As XmlElement
    Dim objDiluent As XmlElement
    Dim idx As Integer
    Dim blnHeaderShown As Boolean
    Dim objProductRead As DSSRTL20.ProductRead
    Dim blnIsSolid As Boolean
    Dim blnTemplateMode As Boolean
    
    Dim DOMData As XmlDocument
    Dim strData_XML As String
    Dim dblResult As Double
    Dim dblStrength As Double
    
    
    Dim lngMinIngredients As Integer
    Dim lngMaxIngredients As Integer
    Dim dblVolumeofIngredients As Double
    
    Dim objUnitsRead As DSSRTL20.UnitsRead = New DSSRTL20.UnitsRead()

    Dim strDoseUnit As String
    Dim dblPrimaryDose As Double
    Dim strPrimaryDoseUnit As String
    
    Dim strConcentration_Unit As String
    Dim lngConcentration_UnitID As Integer
    Dim dblConcentration_Multiple As Double
    Dim strState As String = ""
	Dim dblResult_New As Double
	Dim lngUnitID_New As Integer
    Dim strUnit_New As String = String.Empty
	Dim lngUnitID As Integer
	
    strConcentration_Unit = ""
    lngConcentration_UnitID = 0
    dblConcentration_Multiple = 0
    
    objReconstitution = Nothing
    objDiluent = Nothing
    blnTemplateMode = False
    
    lngMaxIngredients = 1
    lngMinIngredients = 1
    
    strPrimaryDoseUnit = ""
	
    
    dblPrimaryDose = 0
    dblResult = 0
    dblVolumeofIngredients = 0
    lngSessionID = CInt(Request.QueryString("SessionID"))
    If Request.QueryString("TemplateMode") = "True" Then
        blnTemplateMode = True
    End If
    
    
    strData_XML = Ascribe.Common.Generic.SessionAttribute(lngSessionID, "OrderEntry/DiluentCalculation")
   
%>
    <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=lngSessionID %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "DiluentCalculations.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

<body>
    <div align="center">
        <br />
        <div id="divScrollTable" style="overflow: auto; height:100px; border:0 #000000 solid; text-align: center;  padding: 2px">
            <table cellpadding="2" cellspacing="2" border="0" style="font-family:trebuchet ms; font-size:14px; color:#000000; background-color:#DDDDDD;" width="95%">
	            <tr style="background-color:#EEEEEE; font-weight:Bold;">
		            <td align="center">Variable</td>
		            <td align="center">Abbreviation</td>
		            <td align="center">Formula</td>
		            <td align="center">Value</td>
	            </tr>

                <!-- Reconstitution Section (Repeat For Each Product) -->
                
	            <%
	                If strData_XML <> "" Then	                    
	                    DOMData = New XmlDocument
	                    DOMData.TryLoadXml(strData_XML)

	                    idx = 1
	                    colProducts = DOMData.SelectNodes("root/Product")
	                    
	                    For Each xmlProduct In colProducts
	                        strDoseUnit = xmlProduct.GetAttribute("DoseUnit")
	                        If xmlProduct.GetAttribute("IsPrimary") = "true" Then
	                            ' primary ingredient
	                            If xmlProduct.GetAttribute("Dose") <> "" Then
	                                ' 04Jun08 PH F0025239 Zero dose if we have a routine and are in template mode
	                                If xmlProduct.GetAttribute("Routine") <> "" AndAlso blnTemplateMode = True Then
	                                    xmlProduct.SetAttribute("Dose", 0)
	                                Else
	                                    dblPrimaryDose = xmlProduct.GetAttribute("Dose")
	                                End If
	                            End If
	                            strPrimaryDoseUnit = xmlProduct.GetAttribute("DoseUnit")
	                        End If
	                        objReconstitution = DOMData.SelectSingleNode("//Diluents/Reconstitution/Product[@ProductID='" & xmlProduct.GetAttribute("ProductID") & "']")
    	                    
	                        'If there is no reconstitution information for this product or 
	                        'reconstitution is not required then don't display the reconstitution section
	                        If objReconstitution Is Nothing Then
	                            Continue For
	                        End If
	                        
	                        If objReconstitution.GetAttribute("ReconstitutionRequired") = "0" Then
	                            Continue For
	                        End If
	                        
	                        lngMaxIngredients = lngMaxIngredients + 1
	                        
	                        If XmlExtensions.AttributeExists(objReconstitution.GetAttribute("Concentration_Unit")) Then
	                            strConcentration_Unit = objReconstitution.GetAttribute("Concentration_Unit")
	                        End If


	                        If XmlExtensions.AttributeExists(objReconstitution.GetAttribute("Concentration_UnitID")) Then
	                            If objReconstitution.GetAttribute("Concentration_UnitID") <> "" Then
	                                lngConcentration_UnitID = objReconstitution.GetAttribute("Concentration_UnitID")
	                            End If
	                        End If
	                        
	                        '	                        If XmlExtensions.AttributeExists(objReconstitution.GetAttribute("Concentration_Multiple")) Then
'	                            If objReconstitution.GetAttribute("Concentration_Multiple") <> "" Then
'	                                dblConcentration_Multiple = objReconstitution.GetAttribute("Concentration_Multiple")
'	                            End If
'	                        End If
	            %>
	            <tr>
	                <td align="center" colspan="4" style="height:40px;background-color:#B9DCFF;font-weight:bold">Reconstitution of <%=xmlProduct.GetAttribute("ProductName")%></td>
	            </tr>
	            <tr bgcolor="#FFFFFF">
		            <td align="left">Dose</td>
		            <td align="left">DS<sub><small><%=idx%></small></sub></td>
		            <td align="left">&nbsp;</td>
		            <td align="left"><%=xmlProduct.GetAttribute("Dose")%><%=strDoseUnit%></td>
	            </tr>
	            <tr bgcolor="#FFFFFF">
		            <td align="left">Vial/Amp Size</td>
		            <td align="left">VS<sub><small><%=idx%></small></sub></td>
		            <td align="left">&nbsp;</td>
		            <td align="left"><%=objReconstitution.GetAttribute("VialSize")%><%=strDoseUnit%></td>
	            </tr>
	            <tr bgcolor="#FFFFFF">
		            <td align="left">Number of Vials/Amps</td>
		            <td align="left">NV<sub><small><%=idx%></small></sub></td>
		            <td align="left">DS<sub><small><%=idx%></small></sub> / VS<sub><small><%=idx%></small></sub> (rounded up)</td>
		            <td align="left">
		            <%
		                If xmlProduct.GetAttribute("Routine") <> "" AndAlso blnTemplateMode = True Then
		                    Response.Write("0/")
		                    Response.Write(objReconstitution.GetAttribute("VialSize"))
		                    Response.Write(" = 0")
		                Else
		                    Response.Write(xmlProduct.GetAttribute("Dose"))
		                    Response.Write("/")
		                    Response.Write(objReconstitution.GetAttribute("VialSize"))
		                    Response.Write("=")
		                
		                    dblResult = 0
		                
		                    If Not xmlProduct.GetAttribute("Dose") Is Nothing AndAlso xmlProduct.GetAttribute("Dose") <> "" Then
		                        If Not objReconstitution.GetAttribute("VialSize") Is Nothing AndAlso objReconstitution.GetAttribute("VialSize") <> "" Then
		                            dblResult = Math.Ceiling(CDbl(xmlProduct.GetAttribute("Dose")) / CDbl(objReconstitution.GetAttribute("VialSize")))
		                        End If
		                    End If
		                
		                    Response.Write(String.Format("{0:#.#}", dblResult))
		                End If
		            %>
		            </td>
	            </tr>
	            <tr bgcolor="#FFFFFF">
		            <td align="left">Displacement Volume per Vial/Amp</td>
		            <td align="left">DV<sub><small><%=idx%></small></sub></td>
		            <td align="left">&nbsp;</td>
		            <td align="left">
		            <%
		                If Not objReconstitution.GetAttribute("DisplacementVolume") Is Nothing AndAlso objReconstitution.GetAttribute("DisplacementVolume") <> "" Then
		                    dblResult = CDbl(objReconstitution.GetAttribute("DisplacementVolume"))
		                    Response.Write(String.Format("{0:#.#}", dblResult))
		                    'F0049393 ST 31Mar09    Added unit of measure for item.
		                    Response.Write("mL")
		                End If
		            %>
		            </td>
	            </tr>
	            <tr bgcolor="#FFFFFF">
		            <td align="left">Reconstitution Fluid per Vial/Amp</td>
		            <td align="left">RV<sub><small><%=idx%></small></sub></td>
		            <td align="left">&nbsp;</td>
		            <td align="left">
		            <%
		                If Not objReconstitution.GetAttribute("Volume") Is Nothing AndAlso objReconstitution.GetAttribute("Volume") <> "" Then
		                    dblResult = CDbl(objReconstitution.GetAttribute("Volume"))
		                    Response.Write(String.Format("{0:#.#}", dblResult))
		                    Response.Write("mL")
		                End If
		            %>
                    </td>
	            </tr>
	            <tr bgcolor="#FFFFFF">
		            <td align="left">Concentration</td>
		            <td align="left">RC<sub><small><%=idx%></small></sub></td>
		            
		            <%
		            	
		                objProductRead = New DSSRTL20.ProductRead()		            	
		            	 strState = Lcase(objProductRead.getProductState(lngSessionID, CInt(xmlProduct.GetAttribute("ProductID"))))
		                objProductRead = Nothing

		            	 blnIsSolid = (strState="solid" Or (strState = Chr(0)))															'New .net behaviour - blank strings from SQL are cast to nothing, then chr(0) as they come out of the vb class
		                
		                If blnIsSolid Then
		                    If Not objReconstitution.GetAttribute("Concentration_Calculated") Is Nothing AndAlso objReconstitution.GetAttribute("Concentration_Calculated") <> "" AndAlso Not objReconstitution.GetAttribute("Concentration_Calculated") Is DBNull.Value Then
		                        If CBool(objReconstitution.GetAttribute("Concentration_Calculated")) = True Then
		                            %>
		                            <td align="left">VS<sub><small><%=idx%></small></sub>/(RV<sub><small><%=idx%></small></sub> + DV<sub><small><%=idx%></small></sub>)</td>
		                            <%
		                        Else
                                    %>
                                    <td align="left">&nbsp;</td>
                                    <%		                        
		                        End If
		                    End If
                        Else
		                    If Not objReconstitution.GetAttribute("Concentration_Calculated") Is Nothing AndAlso objReconstitution.GetAttribute("Concentration_Calculated") <> "" AndAlso Not objReconstitution.GetAttribute("Concentration_Calculated") Is DBNull.Value Then
		                        If CBool(objReconstitution.GetAttribute("Concentration_Calculated")) = True Then
		                            %>
		                            <%--07Apr09     Rams    Corrected the Formula printing on to the form--%>
		                            <td align="left">VS<sub><small><%=idx%></small></sub> / (RV<sub><small><%=idx%></small></sub> + (VS<sub><small><%=idx%></small></sub> / ST<sub><small><%=idx%></small></sub>))</td>
		                            <%
		                        Else
                                    %>
                                    <td align="left">&nbsp;</td>
                                    <%		                        
		                        End If
		                    End If
                        End If
		            %>
		            
		            <td align="left">
		            <%
		                If blnIsSolid Then
		                    Response.Write(objReconstitution.GetAttribute("VialSize"))
		                    Response.Write("/(")
		                    
		                    If Not objReconstitution.GetAttribute("Volume") Is Nothing AndAlso objReconstitution.GetAttribute("Volume") <> "" Then
		                        dblResult = CDbl(objReconstitution.GetAttribute("Volume"))
		                        Response.Write(String.Format("{0:0.#}", dblResult))
		                    End If
		                    Response.Write("+")
		                    If Not objReconstitution.GetAttribute("DisplacementVolume") Is Nothing AndAlso objReconstitution.GetAttribute("DisplacementVolume") <> "" Then
		                        dblResult = CDbl(objReconstitution.GetAttribute("DisplacementVolume"))
		                        If dblResult > 1 Then
		                            Response.Write(String.Format("{0:#.##}", dblResult))
		                        Else
		                            Response.Write(String.Format("{0:0.0#}", dblResult))
		                        End If
		                    End If
		                    Response.Write(") = ")
		                    If Not objReconstitution.GetAttribute("Concentration") Is Nothing AndAlso objReconstitution.GetAttribute("Concentration") <> "" Then
		                        dblResult = CDbl(objReconstitution.GetAttribute("Concentration"))
		                        If dblResult > 1 Then
		                            Response.Write(String.Format("{0:#.##}", dblResult) & strConcentration_Unit & "/mL")
		                        Else
		                            'Convert to a more approrpriate unit for display
		                            ConvertToMostAppropriateUnit(lngSessionID, dblResult, lngConcentration_UnitID, dblResult_New, lngUnitID_New, strUnit_New)
		                            Response.Write(String.Format("{0:0.0#}", dblResult_New) & strUnit_New & "/mL")
		                        End If
		                    End If
		                    
		                Else
		                    dblStrength = 0
		                    Response.Write("(")
		                    objProductRead = New DSSRTL20.ProductRead()
		                    dblStrength = objProductRead.GetLiquidStrength(lngSessionID, CInt(xmlProduct.GetAttribute("ProductID")))
		                    objProductRead = Nothing
		                    '
		                    '07Apr09    Rams    Corrected the display of the Concentration in case of Liquid
		                    '
		                    Response.Write(objReconstitution.GetAttribute("VialSize"))
		                    Response.Write(" / (")
                            If Not objReconstitution.GetAttribute("Volume") Is Nothing AndAlso objReconstitution.GetAttribute("Volume") <> "" Then
		                        dblResult = CDbl(objReconstitution.GetAttribute("Volume"))
		                        Response.Write(String.Format("{0:0.#}", dblResult))
		                    End If
		                    '
		                    Response.Write("+(")
		                    '
		                    Response.Write(objReconstitution.GetAttribute("VialSize"))
		                    '
		                    Response.Write(" / ")
		                    '
		                    Response.Write(dblStrength)
		                    '
		                    Response.Write("))")
                            '
		                    Response.Write(") = ")
		                    If Not objReconstitution.GetAttribute("Concentration") Is Nothing AndAlso objReconstitution.GetAttribute("Concentration") <> "" Then
		                        dblResult = CDbl(objReconstitution.GetAttribute("Concentration"))
		                        If dblResult > 1 Then
		                            Response.Write(String.Format("{0:#.##}", dblResult) & strConcentration_Unit & "/mL")
		                        Else
		                            'Convert to a more approrpriate unit for display
		                            ConvertToMostAppropriateUnit(lngSessionID, dblResult, lngConcentration_UnitID, dblResult_New, lngUnitID_New, strUnit_New)
		                            Response.Write(String.Format("{0:0.0#}", dblResult_New) & strUnit_New & "/mL")
		                            Response.Write(String.Format("{0:0.0#}", dblResult))
		                        End If
		                    End If
		                    'F0049301 ST 26Mar09    Commented out to prevent extra dose unit from showing up
		                    'Response.Write(strConcentration_Unit & "/mL")
		                End If
		                
		             %>
                     </td>
	            </tr>
	            <tr bgcolor="#D9FFD9">
		            <td align="left">Total Quantity of Fluid Required</td>
		            <td align="left">VR<sub><small><%=idx%></small></sub></td>
		            <td align="left">DS<sub><small><%=idx%></small></sub>/RC<sub><small><%=idx%></small></sub></td>
		            <td align="left">
		            <%
		                Response.Write(xmlProduct.GetAttribute("Dose"))
		                Response.Write("/")
		                If Not objReconstitution.GetAttribute("Concentration") Is Nothing AndAlso objReconstitution.GetAttribute("Concentration") <> "" Then
		                    dblResult = CDbl(objReconstitution.GetAttribute("Concentration"))
		                    If dblResult > 1 Then
		                        Response.Write(String.Format("{0:#.##}", dblResult))
		                    Else
		                        Response.Write(String.Format("{0:0.0#}", dblResult))
		                    End If
		                End If

		                
		                If Not xmlProduct.GetAttribute("Dose") Is Nothing AndAlso xmlProduct.GetAttribute("Dose") <> "" Then
		                    If Not objReconstitution.GetAttribute("Concentration") Is Nothing AndAlso objReconstitution.GetAttribute("Concentration") <> "" Then
		                        dblResult = CDbl(xmlProduct.GetAttribute("Dose")) / CDbl(objReconstitution.GetAttribute("Concentration"))
		                        If dblResult > 1 Then
		                            Response.Write(" = " & String.Format("{0:#.##}", dblResult) & "mL")
		                        Else
		                            Response.Write(" = " & String.Format("{0:0.##}", dblResult) & "mL")
		                        End If
		                    End If
		                End If
		            %>
		            </td>
	            </tr>
	            <%
        	                idx = idx + 1
        	            Next
                    End If
	            %>
    	        
    	        <%

    	            If strData_XML <> "" Then
    	                DOMData = New XmlDocument
    	                DOMData.TryLoadXml(strData_XML)
    	                
    	                objDiluent = DOMData.SelectSingleNode("//Diluents/Product")
    	                    
    	                'If there is no diluent information for this product then don't display the following sections
    	                If Not objDiluent Is Nothing Then
    	                    If XmlExtensions.AttributeExists(objDiluent.GetAttribute("VolumeOfIngredients")) AndAlso objDiluent.GetAttribute("VolumeOfIngredients") <> "" Then
    	                        dblVolumeofIngredients = CDbl(objDiluent.GetAttribute("VolumeOfIngredients"))
    	                    End If
    	                    
    	                    Dim blnDoseCalculated As Boolean
                            Dim blnFinalVolumeCalculated As Boolean
                            Dim blnFinalConcCalculated As Boolean
                            Dim blnDiluentQuantityCalculated As Boolean
    	                    Dim blnDisplayDilution As Boolean
    	                    
    	                    blnDoseCalculated = (objDiluent.GetAttribute("Dose_Calculated") = "True")
    	                    blnFinalVolumeCalculated = (objDiluent.GetAttribute("FinalVolume_Calculated") = "True")
    	                    blnFinalConcCalculated = (objDiluent.GetAttribute("FinalConcentration_Calculated") = "True")
    	                    blnDiluentQuantityCalculated = (objDiluent.GetAttribute("DiluentQuantity_Calculated") = "True")

                            blnDisplayDilution = (blnDiluentQuantityCalculated Or blnDoseCalculated Or blnFinalConcCalculated Or blnFinalVolumeCalculated)
 
    	                    If Not blnFinalConcCalculated AndAlso Not blnFinalVolumeCalculated Then
    	                        '
    	                        ' Render the Dilution section
    	                        '
    	                        If blnDisplayDilution Then
    	                            Response.Write("<tr>")
    	                            Response.Write("<td align=""center"" colspan=""4"" style=""height:40px;background-color:#B9DCFF;font-weight:bold;"">Dilution</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Total Volume of Liquid Ingredients</td>")
    	                            Response.Write("<td align=""left"">VL</td>")
    	                            Response.Write("<td align=""left"">DS / ST</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("VolumeOfLiquidIngredients") & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Total Volume of Ingredients</td>")
    	                            Response.Write("<td align=""left"">VI</td>")
    	                            If lngMinIngredients = lngMaxIngredients Then
    	                                Response.Write("<td align=""left"">VR<sub><small>" & lngMinIngredients & "</small></td>")
    	                            Else
    	                                Response.Write("<td align=""left"">VR<sub><small>" & lngMinIngredients & "</small></sub>+VR<sub><small>" & lngMaxIngredients & "</small></sub></td>")
    	                            End If
        	                        
    	                            Response.Write("<td align=""left"">" & String.Format("{0:0.##}", dblVolumeofIngredients) & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Final Volume</td>")
    	                            Response.Write("<td align=""left"">FV</td>")
    	                            Response.Write("<td align=""left"">&nbsp;</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("DiluentFinalVolume") & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#D9FFD9"">")
    	                            Response.Write("<td align=""left"">Diluent Quantity</td>")
    	                            Response.Write("<td align=""left"">DQ</td>")
    	                            Response.Write("<td align=""left"">FV - VI</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("DiluentFinalVolume") & "-" & objDiluent.GetAttribute("VolumeOfIngredients") & "=" & objDiluent.GetAttribute("DiluentQty") & "mL</td>")
    	                            Response.Write("</tr>")
    	                        End If
    	                    ElseIf Not blnFinalConcCalculated AndAlso Not blnFinalVolumeCalculated Then
    	                        '
    	                        ' Render the Dose section
    	                        '
    	                        Response.Write("<tr>")
    	                        Response.Write("<td align=""center"" colspan=""4"" style=""height:40px;background-color:#B9DCFF;font-weight:bold;"">Dose</td>")
    	                        Response.Write("</tr>")
    	                        Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                        Response.Write("<td align=""left"">Final Concentration</td>")
    	                        Response.Write("<td align=""left"">&nbsp;</td>")
    	                        Response.Write("<td align=""left"">&nbsp;</td>")
    	                        Response.Write("<td align=""left"">" & objDiluent.GetAttribute("FinalConcentration") & "</td>")
    	                        Response.Write("</tr>")
    	                        Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                        Response.Write("<td align=""left"">Final Volume</td>")
    	                        Response.Write("<td align=""left"">FV</td>")
    	                        Response.Write("<td align=""left"">&nbsp;</td>")
    	                        Response.Write("<td align=""left"">" & objDiluent.GetAttribute("DiluentFinalVolume") & "mL</td>")
    	                        Response.Write("</tr>")
    	                        Response.Write("<tr bgcolor=""#D9FFD9"">")
    	                        Response.Write("<td align=""left"">Dose</td>")
    	                        Response.Write("<td align=""left"">DS</td>")
    	                        Response.Write("<td align=""left"">&nbsp;</td>")
    	                        Response.Write("<td align=""left"">" & dblPrimaryDose & strPrimaryDoseUnit & "</td>")
    	                        Response.Write("</tr>")
        	                
    	                        '
    	                        ' Render the Dilution section
    	                        '
    	                        If blnDisplayDilution Then
    	                            Response.Write("<tr>")
    	                            Response.Write("<td align=""center"" colspan=""4"" style=""height:40px;background-color:#B9DCFF;font-weight:bold;"">Dilution</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Total Volume of Liquid Ingredients</td>")
    	                            Response.Write("<td align=""left"">VL</td>")
    	                            Response.Write("<td align=""left"">DS / ST</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("VolumeOfLiquidIngredients") & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Total Volume of Ingredients</td>")
    	                            Response.Write("<td align=""left"">VI</td>")
    	                            If lngMinIngredients = lngMaxIngredients Then
    	                                Response.Write("<td align=""left"">VR<sub><small>" & lngMinIngredients & "</small></td>")
    	                            Else
    	                                Response.Write("<td align=""left"">VR<sub><small>" & lngMinIngredients & "</small></sub>+VR<sub><small>" & lngMaxIngredients & "</small></sub></td>")
    	                            End If
        	                        
    	                            Response.Write("<td align=""left"">" & String.Format("{0:0.##}", dblVolumeofIngredients) & "mL</td>")
        	                        
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Final Volume</td>")
    	                            Response.Write("<td align=""left"">FV</td>")
    	                            Response.Write("<td align=""left"">&nbsp;</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("DiluentFinalVolume") & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#D9FFD9"">")
    	                            Response.Write("<td align=""left"">Diluent Quantity</td>")
    	                            Response.Write("<td align=""left"">DQ</td>")
    	                            Response.Write("<td align=""left"">FV - VI</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("DiluentFinalVolume") & "-" & objDiluent.GetAttribute("VolumeOfIngredients") & "=" & objDiluent.GetAttribute("DiluentQty") & "mL</td>")
    	                            Response.Write("</tr>")
    	                        End If
    	                    ElseIf Not blnDiluentQuantityCalculated AndAlso Not blnDoseCalculated Then
    	                        '
    	                        ' Render the Dilution section
    	                        '
    	                        If blnDisplayDilution Then
    	                            Response.Write("<tr>")
    	                            Response.Write("<td align=""center"" colspan=""4"" style=""height:40px;background-color:#B9DCFF;font-weight:bold;"">Dilution</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Total Volume of Liquid Ingredients</td>")
    	                            Response.Write("<td align=""left"">VL</td>")
    	                            Response.Write("<td align=""left"">DS / ST</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("VolumeOfLiquidIngredients") & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Total Volume of Ingredients</td>")
    	                            Response.Write("<td align=""left"">VI</td>")
    	                            If lngMinIngredients = lngMaxIngredients Then
    	                                Response.Write("<td align=""left"">VR<sub><small>" & lngMinIngredients & "</small></td>")
    	                            Else
    	                                Response.Write("<td align=""left"">VR<sub><small>" & lngMinIngredients & "</small></sub>+VR<sub><small>" & lngMaxIngredients & "</small></sub></td>")
    	                            End If

    	                            Response.Write("<td align=""left"">" & String.Format("{0:0.##}", dblVolumeofIngredients) & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Diluent Quantity</td>")
    	                            Response.Write("<td align=""left"">DQ</td>")
    	                            Response.Write("<td align=""left"">&nbsp;</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("DiluentQty") & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#D9FFD9"">")
    	                            Response.Write("<td align=""left"">Final Volume</td>")
    	                            Response.Write("<td align=""left"">FV</td>")
    	                            Response.Write("<td align=""left"">DQ + VI</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("DiluentQty") & " + " & objDiluent.GetAttribute("VolumeOfIngredients") & " = " & objDiluent.GetAttribute("DiluentFinalVolume") & "mL</td>")
    	                            Response.Write("</tr>")
    	                        End If
    	                    ElseIf Not blnDiluentQuantityCalculated AndAlso Not blnFinalVolumeCalculated Then
    	                        '
    	                        ' Render the Dilution section
    	                        '
    	                        If blnDisplayDilution Then
    	                            Response.Write("<tr>")
    	                            Response.Write("<td align=""center"" colspan=""4"" style=""height:40px;background-color:#B9DCFF;font-weight:bold;"">Dilution</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Final Concentration</td>")
    	                            Response.Write("<td align=""left"">CN</td>")
    	                            Response.Write("<td align=""left"">DS / FV</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("FinalConcentration") & "</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Diluent Quantity</td>")
    	                            Response.Write("<td align=""left"">DQ</td>")
    	                            Response.Write("<td align=""left"">FV - VI</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("DiluentFinalVolume") & "-" & objDiluent.GetAttribute("VolumeOfIngredients") & "=" & objDiluent.GetAttribute("DiluentQty") & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Total Volume of Liquid Ingredients</td>")
    	                            Response.Write("<td align=""left"">VL</td>")
    	                            Response.Write("<td align=""left"">DS / ST</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("VolumeOfLiquidIngredients") & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Total Volume of Ingredients</td>")
    	                            Response.Write("<td align=""left"">VI</td>")
    	                            If lngMinIngredients = lngMaxIngredients Then
    	                                Response.Write("<td align=""left"">VR<sub><small>" & lngMinIngredients & "</small></td>")
    	                            Else
    	                                Response.Write("<td align=""left"">VR<sub><small>" & lngMinIngredients & "</small></sub>+VR<sub><small>" & lngMaxIngredients & "</small></sub></td>")
    	                            End If

    	                            Response.Write("<td align=""left"">" & String.Format("{0:0.##}", dblVolumeofIngredients) & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#FFFFFF"">")
    	                            Response.Write("<td align=""left"">Final Volume</td>")
    	                            Response.Write("<td align=""left"">FV</td>")
    	                            Response.Write("<td align=""left"">&nbsp;</td>")
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("DiluentFinalVolume") & "mL</td>")
    	                            Response.Write("</tr>")
    	                            Response.Write("<tr bgcolor=""#D9FFD9"">")
    	                            Response.Write("<td align=""left"">Dose</td>")
    	                            Response.Write("<td align=""left"">DS</td>")
    	                            Response.Write("<td align=""left"">FV * CN</td>")

    	                            If objDiluent.GetAttribute("DiluentFinalVolume") <> "" AndAlso objDiluent.GetAttribute("FinalConcentration") <> "" Then
    	                                dblResult = Math.Round(CDbl(objDiluent.GetAttribute("DiluentFinalVolume")) * CDbl(objDiluent.GetAttribute("FinalConcentration")), 3)
    	                            End If
    	                            Response.Write("<td align=""left"">" & objDiluent.GetAttribute("DiluentFinalVolume") & " * " & objDiluent.GetAttribute("FinalConcentration") & " = " & dblResult & xmlProduct.GetAttribute("DoseUnit") & "/mL</td>")
    	                            Response.Write("</tr>")
    	                        End If
    	                    End If
        	            
    	                    
    	                    colProducts = DOMData.SelectNodes("root/Product")
    	                    idx = 1
    	                    blnHeaderShown = False

    	                    For Each xmlProduct In colProducts
    	                        objReconstitution = DOMData.SelectSingleNode("//Diluents/Reconstitution/Product[@ProductID='" & xmlProduct.GetAttribute("ProductID") & "']")
    	                    
    	                        If xmlProduct.GetAttribute("Routine") = "" Or blnTemplateMode = False Then
    	                            If objDiluent.GetAttribute("FinalConcentration_Calculated") = "True" AndAlso idx = 1 Then
    	                                If blnHeaderShown = False Then
    	                                    Response.Write("<tr>")
    	                                    Response.Write("<td align=""center"" colspan=""4"" style=""height:40px;background-color:#B9DCFF;font-weight:bold;"">Concentrations</td>")
    	                                    Response.Write("</tr>")
    	                                    
        	                                blnHeaderShown = True
                                        End If    	                                    
    	                            
    	                                Response.Write("<tr bgcolor=""#D9FFD9"">")
    	                                Response.Write("<td align=""left"">")
    	                                Response.Write(xmlProduct.GetAttribute("ProductName"))
    	                                Response.Write("</td>")
    	                                Response.Write("<td align=""left"">CN<sub><small>" & idx & "</small></sub></td>")
    	                            
    	                                Response.Write("<td align=""left"">DS<sub><small>" & idx & "</small></sub>/FV</td>")
    	                            
    	                                If xmlProduct.GetAttribute("Dose") <> "" AndAlso objDiluent.GetAttribute("DiluentFinalVolume") <> "" Then
    	                                    If CDbl(objDiluent.GetAttribute("DiluentFinalVolume")) <> 0 Then
    	                                        dblResult = CDbl(xmlProduct.GetAttribute("Dose")) / CDbl(objDiluent.GetAttribute("DiluentFinalVolume"))
    	                                    Else
    	                                        dblResult = CDbl(xmlProduct.GetAttribute("Dose"))
    	                                    End If
    	                                End If
    	                                
   	                                Response.Write("<td align=""left"">" & xmlProduct.GetAttribute("Dose") & "/" & objDiluent.GetAttribute("DiluentFinalVolume") & " = ")
    	                                
    	                                If dblResult < 1 Then
    	        										lngUnitID = xmlProduct.GetAttribute("DoseUnitID")
														ConvertToMostAppropriateUnit(lngSessionID, dblResult, lngUnitID, dblResult_New, lngUnitID_New, strUnit_New)
 
    	                                Else
    	        										dblResult_New= dblResult
    	        										strUnit_New = xmlProduct.GetAttribute("DoseUnit")
    	                                End If
    	        								  
    	        								  Response.Write(String.Format("{0:0.0#}", Math.Round(dblResult_New, 2)) & strUnit_New & "/mL")
    	                                Response.Write("</td>")
    	                                Response.Write("</tr>")    	                               	                            
    	                            End If
    	                    
    	                            '
    	                            ' Render the concentration section (secondary ingredients)
    	                            '
    	                            If idx > 1 Then
    	                                If blnHeaderShown = False Then
    	                                    Response.Write("<tr>")
    	                                    Response.Write("<td align=""center"" colspan=""4"" style=""height:40px;background-color:#B9DCFF;font-weight:bold;"">Concentrations</td>")
    	                                    Response.Write("</tr>")
    	                                    
        	                                blnHeaderShown = True
    	                                End If

    	                                Response.Write("<tr bgcolor=""#D9FFD9"">")
    	                                Response.Write("<td align=""left"">")
    	                                Response.Write(xmlProduct.GetAttribute("ProductName"))
    	                                Response.Write("</td>")
    	                                Response.Write("<td align=""left"">CN<sub><small>" & idx & "</small></sub></td>")
    	                                Response.Write("<td align=""left"">DS<sub><small>" & idx & "</small></sub>/FV</td>")
    	                                
    	                                'F0049415 ST 31Mar09 Added reset of dblresult to stop secondary products using the same values
    	                                dblResult = 0
    	                                If xmlProduct.GetAttribute("Dose") <> "" AndAlso objDiluent.GetAttribute("DiluentFinalVolume") <> "" Then
    	                                    If CDbl(objDiluent.GetAttribute("DiluentFinalVolume")) <> 0 Then
    	                                        dblResult = CDbl(xmlProduct.GetAttribute("Dose")) / CDbl(objDiluent.GetAttribute("DiluentFinalVolume"))
    	                                    Else
    	                                        dblResult = CDbl(xmlProduct.GetAttribute("Dose"))
    	                                    End If
    	                                End If


    	                                'F0049415 ST 31Mar09 Don't show the data in the cell if the dose is 0
    	                                If (Not String.IsNullOrEmpty(xmlProduct.GetAttribute("Dose"))) Then
    	                                    Response.Write("<td align=""left"">" & xmlProduct.GetAttribute("Dose") & "/" & objDiluent.GetAttribute("DiluentFinalVolume"))
    	                                    Response.Write(" = " & Math.Round(dblResult, 3))
    	                                    Response.Write(" = ")
    	                                
    	                                    If dblResult < 1 Then
    	                                        lngUnitID = xmlProduct.GetAttribute("DoseUnitID")
    	                                        ConvertToMostAppropriateUnit(lngSessionID, dblResult, lngUnitID, dblResult_New, lngUnitID_New, strUnit_New)
    	                                    Else
    	                                        dblResult_New = dblResult
    	                                        strUnit_New = xmlProduct.GetAttribute("DoseUnit")
    	                                    End If
    	        								  
    	                                    Response.Write(String.Format("{0:0.0#}", Math.Round(dblResult_New, 2)) & strUnit_New & "/mL")
    	                                    Response.Write("</td>")
    	                                Else
    	                                    Response.Write("<td align=""left"">&nbsp;</td>")
    	                                End If
    	                                Response.Write("</tr>")
    	                            End If
    	                        End If
    	                        
    	                        idx = idx + 1
    	                    Next
    	                End If
    	            End If
        	        %>
            </table>
            <br />
            <table cellpadding="0" cellspacing="0" border="0" style="font-family:trebuchet ms; font-size:14px; color:#000000;" width="95%">
	            <tr>
		            <td align="left">Note:</td>
	            </tr>
	            <tr>
		            <td>&nbsp;</td>
	            </tr>
	            <tr>
		            <td align="left">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<b>*</b>&nbsp;Where no <b>formula</b> is shown, this indicates a value was specified by the user.</td>
	            </tr>
	            <tr>
		            <td>&nbsp;</td>
	            </tr>
	        </table>
	    </div>
	    <table cellpadding="0" cellspacing="0" border="0" style="font-family:trebuchet ms; font-size:14px; color:#000000;" width="95%">
	        <tr>
		        <td align="right"><button id="btnClose" accesskey="C" style="width:80px;" onclick="javascript:window.close();"><u>C</u>lose</button></td>
	        </tr>
        </table>       
    </div>
     <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
