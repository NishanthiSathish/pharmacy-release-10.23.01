<%@ Page language="vb" %>

<%@ Import Namespace="Ascribe.Xml" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common.Prescription" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <title>Reconstitution</title>
    <script language="javascript" src="scripts/reconstitution.js"></script>
    <script language="javascript" src="../sharedscripts/controls.js"></script>
    <script language="javascript" src="../sharedscripts/icwfunctions.js"></script>
    <link rel="stylesheet" type="text/css" href="../../style/diluents.css" />
</head>


<%
    '
    ' Reconstitution.aspx
    '
    ' Displays the product reconstitution dialog page
    '
    '   Apr08 ST    Written
    ' 09May08 ST    Changed hardcoded dose unit after vial size to the value of strIngredientDoseUnit
    '
    
    Dim lngSessionID As Integer
    Dim colDiluents As XmlNodeList
    Dim objDiluent As XmlNode
    Dim blnTemplateMode As Boolean
    Dim blnDisplayMode As Boolean
    Dim DOM As XmlDocument
    Dim eleUnit As XmlElement
    Dim objUnitsRead As DSSRTL20.UnitsRead = New DSSRTL20.UnitsRead()
    Dim dblResult As Double
    
    Dim dblIngredientDose As Double
    
    Dim lngProductID As Integer
    Dim lngRequestID As Integer
    Dim strIngredientDoseUnit As String
    Dim lngDoseUnitID As Integer
    
    
    Dim strIngredientName As String
    Dim blnIsSolid As Boolean
    
    ' Our main blocks of data
    Dim strReconstitution_XML As String
    Dim strDiluent_XML As String
    Dim strPrescription_XML As String
    
    Dim xmlNode As XmlElement
    
    Dim objItem As XmlElement
    Dim DOMReconstitution As XmlDocument
    Dim DOMPrescription As XmlDocument
    
    '
    ' 23Mar2010 CD F0081306 Made the default reconstitution required value to be false
    Dim blnReconstitutionRequired As Boolean = False

    Dim dblVialSize As Double
    Dim dblDisplacementVolume As Double
    Dim dblVolume As Double
    Dim dblConcentration As Double
	
    Dim lngReconstitutionProductID As Integer
    Dim strRoutineName As String
    
    Dim blnNewReconstitution As Boolean
    Dim objProductRead As DSSRTL20.ProductRead
    Dim blnConcentration_Calculated As Boolean
    Dim strReturn_XML As String

    
    Dim strConcentration_Unit As String
    Dim lngConcentration_UnitID As Integer
'    Dim dblConcentration_Multiple As Double
	Dim dblConversionFactor As Double
    
    
    strConcentration_Unit = ""
    lngConcentration_UnitID = 0
 '   dblConcentration_Multiple = 0
    
    strReturn_XML = ""
    
    blnConcentration_Calculated = False
    blnNewReconstitution = True
    
    lngProductID = CInt(Request.QueryString("ProductID"))
    lngSessionID = CInt(Request.QueryString("SessionID"))
    lngRequestID = CInt(Request.QueryString("RequestID"))
    blnTemplateMode = Request.QueryString("TemplateMode")
    blnDisplayMode = Request.QueryString("DisplayMode")
    
    colDiluents = GetDiluents(lngSessionID)

    ' Diluent Information
    strDiluent_XML = Request.Form("txtDiluent_XML")
    strDiluent_XML = strDiluent_XML.Replace("""", "'")
    
    ' Reconstitution Information
    strReconstitution_XML = Request.Form("txtReconstitution_XML")
    strReconstitution_XML = strReconstitution_XML.Replace("""", "'")

    ' Prescription Information
    strPrescription_XML = Request.Form("txtPrescription_XML")
    strPrescription_XML = strPrescription_XML.Replace("""", "'")    
    
    ' Now load the xml and retrieve the values we need
    DOMPrescription = New XmlDocument
    DOMPrescription.TryLoadXml(strPrescription_XML)
    xmlNode = DOMPrescription.SelectSingleNode("root/Product[@ProductID='" & lngProductID & "']")
    
    strIngredientName = xmlNode.GetAttribute("ProductName")
    strIngredientDoseUnit = xmlNode.GetAttribute("DoseUnit")
    lngDoseUnitID = CInt(xmlNode.GetAttribute("DoseUnitID"))
    strRoutineName = xmlNode.GetAttribute("Routine")
    
    ' If in template mode and its a calculated dose then we dont know what the dose is yet
    If blnTemplateMode = True And strRoutineName <> "" Then
        dblIngredientDose = 0
    Else
        If xmlNode.GetAttribute("Dose") <> "" Then
            dblIngredientDose = CDbl(xmlNode.GetAttribute("Dose"))
        Else
            dblIngredientDose = 0
        End If
    End If
    
    blnIsSolid = True
    objProductRead = New DSSRTL20.ProductRead()
    If objProductRead.GetProductState(lngSessionID, lngProductID) = "Liquid" Then
        blnIsSolid = False
    End If
    objProductRead = Nothing
    
    
    DOMReconstitution = New XmlDocument()
    DOMReconstitution.TryLoadXml(strReconstitution_XML)
    xmlNode = DOMReconstitution.SelectSingleNode("root/Reconstitution")
    If Not xmlNode Is Nothing Then
        blnNewReconstitution = False

        objItem = xmlNode.SelectSingleNode("Product[@ProductID='" & lngProductID & "']")
        If Not objItem Is Nothing Then
            ' 23Mar2010 CD F0081306 Made the default reconstitution required value to be false, therefore need to check for truth rather than false
            If objItem.GetAttribute("ReconstitutionRequired") = "1" Then
                blnReconstitutionRequired = True
            End If

            If objItem.GetAttribute("VialSize") <> "" Then
				'dblVialSize = CInt(objItem.GetAttribute("VialSize"))																	
					dblVialSize = objItem.GetAttribute("VialSize")																				'28May08 AE  Do not cast to integer, as these values may be decimal
            End If

            If objItem.GetAttribute("DisplacementVolume") <> "" Then
				'dblDisplacementVolume = CInt(objItem.GetAttribute("DisplacementVolume"))
					dblDisplacementVolume = objItem.GetAttribute("DisplacementVolume")													'28May08 AE  Do not cast to integer, as these values may be decimal
            End If
            
            If objItem.GetAttribute("Volume") <> "" Then
					'dblVolume = CInt(objItem.GetAttribute("Volume"))
					dblVolume = objItem.GetAttribute("Volume")																					'28May08 AE  Do not cast to integer, as these values may be decimal
            End If
            
            If objItem.GetAttribute("Concentration") <> "" Then
                'dblConcentration = CInt(objItem.GetAttribute("Concentration"))
					dblConcentration = objItem.GetAttribute("Concentration")																	'28May08 AE  Do not cast to integer, as these values may be decimal
            End If
            
            If objItem.GetAttribute("ReconstituteProductID") <> "" Then
                'lngReconstitutionProductID = CInt(objItem.GetAttribute("ReconstituteProductID"))
					lngReconstitutionProductID = objItem.GetAttribute("ReconstituteProductID")											'28May08 AE  Do not cast to integer, as these values may be decimal
            End If
            
            If objItem.GetAttribute("Concentration_Calculated") <> "" Then
                blnConcentration_Calculated = CBool(objItem.GetAttribute("Concentration_Calculated"))
            End If
            
            If XmlExtensions.AttributeExists(objItem.GetAttribute("Concentration_Unit")) Then
                strConcentration_Unit = objItem.GetAttribute("Concentration_Unit")
            End If
                
            If XmlExtensions.AttributeExists(objItem.GetAttribute("Concentration_UnitID")) Then
                If objItem.GetAttribute("Concentration_UnitID") <> "" Then
                    lngConcentration_UnitID = CInt(objItem.GetAttribute("Concentration_UnitID"))
                End If
            End If
            
            '            If XmlExtensions.AttributeExists(objItem.GetAttribute("Concentration_Multiple")) Then
'                If objItem.GetAttribute("Concentration_Multiple") <> "" Then
'                    dblConcentration_Multiple = CDbl(objItem.GetAttribute("Concentration_Multiple"))
'                End If
'            End If
            
        End If
        objItem = Nothing
        xmlNode = Nothing
    End If
    DOMReconstitution = Nothing
%>

<body sid="<%= lngSessionID %>" requestid="<%=lngRequestID %>" templatemode="<%= blnTemplateMode %>" displaymode="<%=blnDisplayMode %>" onload="window_onload();">
    <div>
        <form id="frmReconstitution" method="post" action="">
        <table id="tblReconstitution" cellpadding="2" cellspacing="2" border="0" style="font-family:trebuchet ms; font-size:14px; color:#000000; width:100%; height:100%;" >
	        <tr>
		        <td id="tdIngredient" dbid="<%=lngProductID %>" colspan="2" align="left" style="font-family:trebuchet ms; font-size:18px; font-weight:Bold; color:#000000;">Reconstitution Information for <%=strIngredientName %></td>
	        </tr>
	        <tr>
		        <td width="40%" style="background-color:#B5C7F7;height:30px;">Reconstitution Required</td>
		        <td width="60%">
		        <%
		            Response.Write("<input type=""radio"" id=""rbReconstitutionYes"" name=""rbReconstitutionYes"" value="""" ")
		        	  'Check the "Yes" box if this is the first time we've opened the form (i.e. the default is yes), 
		        	  'or if we're opening it later and reconstitution is required.
		            If blnReconstitutionRequired Then Response.Write("checked ")
		            Response.Write(" onclick=""return rbReconstitutionYes_onclick();"" />YES")
		            
		            Response.Write("&nbsp;&nbsp;&nbsp;&nbsp;")
		            
		            Response.Write("<input type=""radio"" id=""rbReconstitutionNo"" name=""rbReconstitutionNo"" value="""" ")
		            If Not blnReconstitutionRequired Then Response.Write("checked ")
		            Response.Write(" onclick=""return rbReconstitutionNo_onclick();"" />NO")
		            
		        %>
                </td>
	        </tr>
	        <tr>
		        <td style="background-color:#B5C7F7;height:30px;">Dose Required</td>
		        <%
		            If blnTemplateMode = True And strRoutineName <> "" Then
		                Response.Write("<td id=""txtIngredientDose"" name=""txtIngredientDose"" issolid=""" & blnIsSolid & """ dose=""" & dblIngredientDose & """>Dose To Be Calculated</td>")
		            Else
		                If strIngredientDoseUnit <> "" And dblIngredientDose > 0.0 Then
		                    Response.Write("<td id=""txtIngredientDose"" name=""txtIngredientDose"" issolid=""" & blnIsSolid & """ dose=""" & dblIngredientDose & """>" & dblIngredientDose & strIngredientDoseUnit & "</td>")
		                Else
		                    Response.Write("<td id=""txtIngredientDose"" name=""txtIngredientDose"" issolid=""" & blnIsSolid & """ dose=""" & dblIngredientDose & """>Not Specified</td>")
		                End If
		            End If
		        %>
	        </tr>
	        <tr>
		        <td style="background-color:#B5C7F7;height:30px;">Vial/Ampoule Size</td>
		        <td><input type="text" id="txtReconstitutionVialSize" name="txtReconstitutionVialSize" value="<%=dblVialSize%>" class="MandatoryField" onblur="CalculateVialsRequired();" maxlength="10" size="6" validchars="NUMBERS" onkeypress="MaskInput(this);" onpaste="MaskInput(this);" /> <%=strIngredientDoseUnit %></td>
	        </tr>
	        <tr id="trVials">
		        <td style="background-color:#B5C7F7;height:30px;">Number of Vials/Amps Required</td>
		        <td id="tdVialsRequired"></td>
	        </tr>
	        <tr>
		        <td style="background-color:#B5C7F7;height:30px;">Reconstitute In</td>
		        <td><select id="selReconstituteIn" name="selReconstituteIn" class="MandatoryField" onchange="CheckIfComplete();"><option dbid="-1"></option>
		        <%
                    For Each objDiluent In colDiluents
                        Response.Write("<option dbid=""")
		                Response.Write(objDiluent.Getattribute("ProductID"))
		                Response.Write("""")
		                Response.Write(" description=""")
		                Response.Write(objDiluent.GetAttribute("Description"))
		                Response.Write("""")
		                If CInt(objDiluent.GetAttribute("ProductID")) = lngReconstitutionProductID Then
		                    Response.Write(" selected")
		                End If
		                Response.Write(">")
		                Response.Write(objDiluent.Getattribute("Description"))
		                Response.Write("</option>")
                    Next
                %>
		        </select></td>
	        </tr>
	        <tr>
		        <td style="background-color:#B5C7F7;height:30px;">Displacement Volume</td>
		        <td>
					<%
						If blnIsSolid Then
					%>
						<input type="text" id="txtReconstitutionDisplacementVolume" name="txtReconstitutionDisplacementVolume" value="<%=dblDisplacementVolume%>" onblur="txtReconstitutionDisplacementVolume_onblur();"  maxlength="10" size="6" validchars="NUMBERS" onkeypress="MaskInput(this);" onpaste="MaskInput(this);" /> mL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(per vial, if known)
					<%
						Else
					%>
						<input type="text" id="txtReconstitutionDisplacementVolume" name="txtReconstitutionDisplacementVolume" disabled /> 
					<%
						End if
					%>		        
				</td>
	        </tr>
	        <tr>
		        <td style="background-color:#B5C7F7;height:30px;">Add</td>
		        <td><input type="text" id="txtReconstitutionVolume" name="txtReconstitutionVolume" value="<%=dblVolume%>" class="MandatoryField" onblur="CalculateConcentration();" maxlength="10" size="6" validchars="NUMBERS" onkeypress="MaskInput(this);" onpaste="MaskInput(this);" /> mL&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(per vial/amp)</td>
	        </tr>
	        <tr>
		        <td style="background-color:#B5C7F7;height:30px;">To Give a Concentration Of</td>
		        <td id="tdConcentration">
		            <table cellpadding="0" cellspacing="0" border="0">
		                <tr>
		        <%
	  
		            Response.Write("<td><input type=""text"" id=""txtReconstitutionConcentration"" name=""txtReconstitutionConcentration"" unit_original=""" & strIngredientDoseUnit & """  unitid_original=""" & lngDoseUnitID & """ ")
		            strConcentration_Unit = strIngredientDoseUnit
						lngConcentration_UnitID = lngDoseUnitID
		        	  
		            If dblConcentration < 1 Then
		                ' If the dose is less than a whole number then we move to the next smallest unit 
		                ' that makes it a whole number	        		  
		        			strReturn_XML = objUnitsRead.ConvertToSmallestUnit(lngSessionID, dblConcentration, lngDoseUnitID)
		                DOM = New XmlDocument()

                                 Dim xmlLoaded As Boolean = False

                                 Try
                                     DOM.LoadXml(strReturn_XML)
                                     xmlLoaded = True
                                 Catch ex As Exception
                                 End Try

                                 If xmlLoaded Then
		                    
                                     eleUnit = DOM.SelectSingleNode("*")
                                     dblConversionFactor = eleUnit.GetAttribute("ConversionFactor")
                                     dblResult = eleUnit.GetAttribute("Value_Converted")
                                     lngConcentration_UnitID = eleUnit.GetAttribute("UnitID")
                                     strConcentration_Unit = eleUnit.GetAttribute("Abbreviation")
                                     '		                                dblResult = Math.Round(dblConcentration, 2) * CInt(eleUnit.GetAttribute("Multiplier"))
                                 End If
		            Else
		                '20Jan2010 F0074572 JMei allow user change concentration value without recalculating
		                'still need to get this value from xml/db
		                dblResult = dblConcentration
		            End If
		        	  
                 Response.Write("calculated='" & IIF(blnConcentration_Calculated, dblResult, "") & "' ")
                     
                 
                 Response.Write(" unit=""" & strConcentration_Unit & """ ")
                 Response.Write(" unitid=""" & lngConcentration_UnitID & """ ")
                 Response.Write(" ConversionFactor=""" & dblConversionFactor & """ ")

                 Response.Write("iscalculated=""" & blnConcentration_Calculated & """ ")
                 Response.Write("value=""" & Math.Round(dblResult,2) & """ ")
                 '29May08 ST  Updated so that mg/mL becomes ActualDoseUnit/Ml
                 Response.Write("class=""MandatoryField"" onblur=""txtReconstitutionConcentration_onblur(); CheckIfComplete();"" maxlength=""10"" size=""6"" validchars=""NUMBERS"" onkeypress=""MaskInput(this);"" onpaste=""MaskInput(this);"" /> ")
                 Response.Write("</td>")
  					  Response.Write("<td align=""left"" id=""tdConcentrationUnit"">&nbsp;" & strConcentration_Unit & "/mL</td>")
		        %>
		                </tr>
		            </table>
		        </td>
	        </tr>
	        <tr>
		        <td colspan="2"><p>&nbsp;</p></td>
	        </tr>

	        <tr>
		        <td id="tdDrawUpText" colspan="2" align="left" style="font-family:trebuchet ms; font-size:18px; font-weight:Bold; color:#000000;"><br /></td>
	        </tr>

	        <tr>
		        <td colspan="2"><hr /></td>
	        </tr>
	        <tr id="trIncomplete" style="display:none;">
	            <td colspan="2">
	                <table cellpadding="2" cellspacing="2" border="0" style="font-family:trebuchet ms; font-size:14px; color:#000000;">
	                	<tr>
		                    <td rowspan="2" valign="top"><img src="../../images/developer/warning.png" border="0" /></td>
		                    <td>&nbsp;</td>
		                    <td><b>Incomplete</b></td>
	                    </tr>
	                    <tr>
		                    <td>&nbsp;</td>
		                    <td style="font-family:trebuchet ms; font-size:12px; color:#000000;"><i>This form does not yet contain all of the information required.<br />You may still save this form as it is, and you, or another user, can enter the remaining information later.</i></td>
	                    </tr>
	                </table>
	            </td>
	        </tr>
	        
	        <tr id="trComplete" style="display:none;">
	            <td colspan="2">
	                <table cellpadding="2" cellspacing="2" border="0" style="font-family:trebuchet ms; font-size:14px; color:#000000;">
	                	<tr>
		                    <td rowspan="2" valign="top"><img src="../../images/developer/tick.png" border="0" /></td>
		                    <td>&nbsp;</td>
		                    <td><b>Complete</b></td>
	                    </tr>
	                    <tr>
		                    <td>&nbsp;</td>
		                    <td style="font-family:trebuchet ms; font-size:12px; color:#000000;"><br /><br /></td>
	                    </tr>
	                </table>
	            </td>
	        </tr>
	        <tr>
		        <td colspan="2" align="right"><button id="btnOK" accesskey="O" style="width:80px;" onclick="btnOK_onclick();"><u>O</u>k</button>&nbsp;&nbsp;<button id="btnCancel" accesskey="C" style="width:80px;" onclick="btnCancel_onclick();"><u>C</u>ancel</button></td>
	        </tr>
        </table>
        
        <input type="text" id="txtReconstitution_XML" name="txtReconstitution_XML" value="<%=strReconstitution_XML %>" style="visibility:hidden;"/>
        <input type="text" id="txtDiluent_XML" name="txtDiluent_XML" value="<%=strDiluent_XML %>" style="visibility:hidden;"/>
        <input type="text" id="txtPrescription_XML" name="txtPrescription_XML" value="<%=strPrescription_XML %>" style="visibility:hidden;"/>
        </form>
    </div>
</body>
</html>
