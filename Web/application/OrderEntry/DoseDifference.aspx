<%@ Page Language="VB" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>

<%
    '
    '   DoseDifference.aspx
    '
    '   Used as part of an AJAX call from prescription.js to display the difference
    '   between the specified dose and prescribed dose.
    '
    '   Modification History
    '
    '   05Oct08 ST  Written
    '
    '
    Dim SessionID As Integer

    Dim dblDoseSpecified As Double
    Dim dblDoseSpecified_Low As Double
    Dim dblDoseSpecified_UnitID As Integer
    Dim dblDosePrescribed As Double
    Dim dblDosePrescribed_Low As Double
    Dim dblDosePrescribed_UnitID As Integer
    Dim strResult As String
    Dim strFromUnitName As String
    Dim strToUnitName As String
    
    
    Dim objDoseRangeCheck As DSSRTL20.DoseRangeCheck
    
    SessionID = CInt(Request.QueryString("SessionID"))

    dblDoseSpecified = CDblX(Request.QueryString("DoseSpecified"))
    dblDoseSpecified_Low = CDblX(Request.QueryString("DoseSpecified_Low"))
    dblDoseSpecified_UnitID = CIntX(Request.QueryString("DoseSpecified_UnitID"))
    
    dblDosePrescribed = CDblX(Request.QueryString("DosePrescribed"))
    dblDosePrescribed_Low = CDblX(Request.QueryString("DosePrescribed_Low"))
    dblDosePrescribed_UnitID = CIntX(Request.QueryString("DosePrescribed_UnitID"))

    strFromUnitName = ""
    strToUnitName = ""
    
    
    objDoseRangeCheck = New DSSRTL20.DoseRangeCheck()
    
    ' Convert everything to a common unit, the dose specified one   
    Ascribe.Common.Dss.DssShared.ConvertValueToUnit(SessionID, dblDoseSpecified, dblDoseSpecified_UnitID, dblDoseSpecified_UnitID, dblDoseSpecified, strFromUnitName, strToUnitName)
    Ascribe.Common.Dss.DssShared.ConvertValueToUnit(SessionID, dblDoseSpecified_Low, dblDoseSpecified_UnitID, dblDoseSpecified_UnitID, dblDoseSpecified_Low, strFromUnitName, strToUnitName)
    Ascribe.Common.Dss.DssShared.ConvertValueToUnit(SessionID, dblDosePrescribed, dblDosePrescribed_UnitID, dblDoseSpecified_UnitID, dblDosePrescribed, strFromUnitName, strToUnitName)
    Ascribe.Common.Dss.DssShared.ConvertValueToUnit(SessionID, dblDosePrescribed_Low, dblDosePrescribed_UnitID, dblDoseSpecified_UnitID, dblDosePrescribed_Low, strFromUnitName, strToUnitName)
    
    ' then calculate the dose difference
    strResult = objDoseRangeCheck.CalculateDoseDifference(SessionID, dblDoseSpecified, dblDoseSpecified_Low, dblDoseSpecified_UnitID, dblDosePrescribed, dblDosePrescribed_Low, dblDosePrescribed_UnitID)
    
    Response.Write(strResult)
%>
