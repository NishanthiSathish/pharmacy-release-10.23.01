<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common.Constants" %>
<%@ Import Namespace="Ascribe.Common.Prescription" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    '
    '   DiluentWorker.aspx
    '   Generic page for handling ajax functions within the diluent forms
    '
	'   Apr08 ST    Written
    '	 27May08 AE  Added case for Description Update
    '    29May08 ST  Added case for Deriving Units
    
    Dim strMode As String
    Dim strReturn_XML As String = ""
    Dim lngSessionID As Integer
    Dim lngRequestID As Integer
    Dim dblValue As Double
    Dim lngUnitID As Integer
    Dim strData_IN As String
    Dim enmReturn As DiluentCalculationResultEnum
    
    Dim DOMdata As XmlDocument
    Dim nodeData As XmlElement
    
    Dim reader As New System.IO.StreamReader(Page.Request.InputStream)
    Dim objProductRead As DSSRTL20.ProductRead = New DSSRTL20.ProductRead()
    Dim objDiluentSave As OCSRTL10.DiluentInformation = New OCSRTL10.DiluentInformation()
    Dim objOCSItem As OCSRTL10.OrderCommsItem = New OCSRTL10.OrderCommsItem()
    Dim objUnitsRead As DSSRTL20.UnitsRead = New DSSRTL20.UnitsRead()
	
    strReturn_XML = ""
    strMode = Request.QueryString("Mode")               ' What do we want to do
    lngSessionID = CInt(Request.QueryString("SessionID"))     ' Get the sessionid
    lngRequestID = Request.QueryString("RequestID")     ' RequestID passed in? If so get that as well
    strData_IN = reader.ReadToEnd()                     ' Anything posted in

    Select Case (strMode)
        Case "GetStrength"
            ' Gets the strength for the given item
            strReturn_XML = objProductRead.GetLiquidStrength(lngSessionID, CInt(strData_IN))
            
        Case "SaveDiluent"
            ' Saves the diluent information
            strReturn_XML = objDiluentSave.DiluentInformationSave(lngSessionID, lngRequestID, strData_IN)
    
		  Case "DescriptionUpdate_Request"
			'Update the description of a request
            strReturn_XML = objOCSItem.UpdateDescription_Request(lngSessionID, lngRequestID, strData_IN)

			
			Case "ConvertToSmallestUnit"
            DOMdata = New XmlDocument
            Dim xmlLoaded As Boolean = False

            Try
                DOMdata.LoadXml(strData_IN)
                xmlLoaded = True
            Catch ex As Exception
            End Try

            If xmlLoaded Then
                nodeData = DOMdata.SelectSingleNode("Value")
                If Not nodeData Is Nothing Then
                    dblValue = nodeData.GetAttribute("Value")
                    lngUnitID = nodeData.GetAttribute("UnitID")
                End If
                strReturn_XML = objUnitsRead.ConvertToSmallestUnit(lngSessionID, dblValue, lngUnitID)
            End If
			
			Case "DoCalculations"
			'Recalculate the diluent information - fill in the missing parts
				DOMdata = New XmlDocument
            DOMdata.TryLoadXml(strData_IN)
            ' DoDiluentCalculations now expects a third parameter (xmlingredients) which is used to get the dose unit, we don't have that here so pass in a null
                ' The UnitID will actually be in strData_IN having been added in prescription.js
                enmReturn = DoDiluentCalculations(lngSessionID, DOMdata, Nothing)
                strReturn_XML = DOMdata.OuterXml

    End Select
	
	Response.Write(strReturn_XML)
	
%>


