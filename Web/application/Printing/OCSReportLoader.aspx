<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common.ICWCookie" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    Dim SessionID As Integer = CIntX(Request.QueryString("SessionID"))
    Dim BatchID As Integer = CIntX(Request.QueryString("BatchID"))
    Dim IsReprint As String = Request.QueryString("IsReprint")
    Dim Preview As String = Request.QueryString("Preview")
    Dim Mode As String = Request.QueryString("Mode")

    Dim RoutineName As String = String.Empty
    Dim RoutineError As String = String.Empty
    Dim PrintItemID As String = String.Empty
    Dim Copies As String = String.Empty
    Dim ReprintItemID As String = String.Empty
    Dim ReportName As String = String.Empty
    Dim Report_RTF As String = String.Empty
    Dim PrimaryKey As String = String.Empty
    Dim ParamData_XML As String = String.Empty
    Dim Data_XML As String = String.Empty
    Dim MediaTypeID As String = String.Empty
    Dim MediaTypeDescription As String = String.Empty
    Dim OrderReportTypeDescription As String = String.Empty
    Dim DeviceName As String = String.Empty
    Dim PrevDeviceName As String = String.Empty
    Dim Portrait As String = String.Empty
    Dim MarginTop As String = String.Empty
    Dim MarginBottom As String = String.Empty
    Dim MarginLeft As String = String.Empty
    Dim MarginRight As String = String.Empty
    
    Dim RoutineRead As New ICWRTL10.RoutineRead()
    Dim LoadRoutine As Boolean = True

    If Mode = "RunRoutine" Then
        RoutineName = Request.Form("txtRoutineName")
        RoutineError = Request.Form("txtRoutineError")
        PrintItemID = Request.Form("txtPrintItemID")
        Copies = Request.Form("txtCopies")
        ReprintItemID = Request.Form("txtReprintItemID")
        ReportName = Request.Form("txtReportName")
        Report_RTF = Request.Form("txtReport_RTF")
        PrimaryKey = Request.Form("txtPrimaryKey")
        MediaTypeID = Request.Form("txtMediaTypeID")
        Portrait = Request.Form("txtPortrait")
        MarginTop = Request.Form("txtMarginTop")
        MarginBottom = Request.Form("txtMarginBottom")
        MarginLeft = Request.Form("txtMarginLeft")
        MarginRight = Request.Form("txtMarginRight")        
        MediaTypeDescription = Request.Form("txtMediaTypeDescription")
        OrderReportTypeDescription = Request.Form("txtOrderReportTypeDescription")
        DeviceName = Request.Form("txtDeviceName")
        ParamData_XML = Request.Form("txtParamData_XML")
        
        Dim ReportParamsXML As String = SessionAttribute(SessionID, "ReportParams")
        Dim ReportParams As New XmlDocument()
        
        If ReportParamsXML = String.Empty Then
            ReportParams.AppendChild(ReportParams.CreateElement("ReportParams"))
        Else
            ReportParams.TryLoadXml(ReportParamsXML)
        End If
        SessionAttributeSet(SessionID, "ReportParams", ReportParams.OuterXml)
    Else
        PrevDeviceName = Request.Form("txtPrevDeviceName")
        Dim PrintBatch As New PRTRTL10.PrintBatch()
        Dim ReprintBatch As New PRTRTL10.ReprintBatch()

        Dim CookieID As Integer
        
        Dim ReportDataXML As String

        'Write back print status (and generated RTF if not a reprint)
        'If Request.Form.GetValues("txtPrintStatusID").Length > 0 Then 
        '19-11-2007 JA Error code 85 -replace with Is Nothing check
        If Not Request.Form.GetValues("txtPrintStatusID") Is Nothing Then
            If IsReprint = "YES" Then
                ReprintBatch.RecordReprintOutcome(SessionID, Integer.Parse(Request.Form("txtReprintItemID")), Integer.Parse(Request.Form("txtPrintStatusID")))
            Else
                PrintBatch.RecordPrintOutcome(SessionID, Integer.Parse(Request.Form("txtPrintItemID")), Integer.Parse(Request.Form("txtPrintStatusID")), Request.Form("txtReport_RTF"))
            End If
        End If

        'See if we have a cookie on the client who's guid also exists in the DB
        CookieID = GetCookieID(SessionID)
        If CookieID = -1 Then
            'Create cookie because it doesnt exist
            CookieID = CreateCookie(SessionID)
        End If

        'So, we now definately have a cookie on the client, and an entry in the DB. We can use the CookieID to pass to the DB
        'to get back devices for this workstation later.


        If IsReprint = "YES" Then
            ReportDataXML = ReprintBatch.PopNextReprintItem(SessionID, BatchID, CookieID)
            '<OrderReport OrderReportID="1" RoutineID="1" RoutineScript="MySQL" RichTextDocumentID="1" Report_RTF="MyRTFData" Description="Test 47" MediaTypeID="123" DeviceName="abc" />
            '20Jun14    Rams    93839 - Scripter Script Manager-> Cannot reprint pharmacy register(Issue here is when you have a paramterised printing thorugh routine, it should not ask for routine parameter when reprinting)
            LoadRoutine = False
        Else
            ReportDataXML = PrintBatch.PopNextPrintItem(SessionID, BatchID, CookieID)
            '<OrderReport OrderReportID="1" RoutineID="1" RoutineScript="MySQL" RichTextDocumentID="1" Report_RTF="MyRTFData" Description="Test 47" MediaTypeID="123" DeviceName="abc" />
        End If
        If ReportDataXML = String.Empty Then
            LoadRoutine = False
            PrevDeviceName = String.Empty
        Else
            Dim xmlDocReport As New XmlDocument()
            Dim xmlnodeReport As XmlElement
            xmlDocReport.TryLoadXml(ReportDataXML)
            xmlnodeReport = xmlDocReport.SelectSingleNode("OrderReport")
            OrderReportTypeDescription = xmlnodeReport.GetAttribute("OrderReportTypeDescription")
            PrintItemID = xmlnodeReport.GetAttribute("PrintItemID")
            Copies = xmlnodeReport.GetAttribute("Copies")
            ReprintItemID = xmlnodeReport.GetAttribute("ReprintItemID")
            ReportName = xmlnodeReport.GetAttribute("Description")
            Report_RTF = xmlnodeReport.GetAttribute("Report_RTF")
            RoutineName = xmlnodeReport.GetAttribute("RoutineDescription")
            MediaTypeID = xmlnodeReport.GetAttribute("MediaTypeID")
            Portrait = xmlnodeReport.GetAttribute("Portrait")
            If xmlnodeReport.GetAttribute("MarginTop") = "-1" Then
            	MarginTop = ""
            Else
            	MarginTop = xmlnodeReport.GetAttribute("MarginTop")
            End If
            If xmlnodeReport.GetAttribute("MarginBottom") = "-1" Then
            	MarginBottom = ""
            Else
	        MarginBottom = xmlnodeReport.GetAttribute("MarginBottom")
            End If
            If xmlnodeReport.GetAttribute("MarginLeft") = "-1" Then
            	MarginLeft = ""
            Else
	        MarginLeft = xmlnodeReport.GetAttribute("MarginLeft")
            End If
            If xmlnodeReport.GetAttribute("MarginRight") = "-1" Then	            
            	MarginRight = ""
            Else
            	MarginRight = xmlnodeReport.GetAttribute("MarginRight")
            End If
            
            ' Bug 61494 30April2013 YB - Added PrevDeviceName to hold the previously selected printer to prevent printer list showing up on every single print item when AlwaysShowPrinterList=true. Copied changes from 10.8
            If String.IsNullOrEmpty(PrevDeviceName) Then
                ' Check to see if we always want to ask for the printer to be selected
                Dim alwaysShowPrinterList As Boolean = Convert.ToBoolean(New GENRTL10.SettingRead().GetValue(SessionID, "ICW", "Printing", "AlwaysShowPrinterList", "False"))
                If alwaysShowPrinterList = False Then
                    DeviceName = xmlnodeReport.GetAttribute("DeviceName")
                Else
                    DeviceName = String.Empty
                End If
            Else
                DeviceName = PrevDeviceName
            End If
            
            MediaTypeDescription = xmlnodeReport.GetAttribute("MediaTypeDescripion")
            If OrderReportTypeDescription = "Batch" Then
                'In batch mode, the PrintBatchID is passed in to the reports routine, instead of the item id
                PrimaryKey = BatchID.ToString
            Else
                PrimaryKey = xmlnodeReport.GetAttribute("RecordID")
            End If

            Dim State As New GENRTL10.State()
            State.SetKey(SessionID, "PrintItem", Integer.Parse(PrintItemID))
            
            Dim ParamCount As Integer = RoutineRead.ParameterCount(SessionID, RoutineName)
            If ParamCount = 1 Then
                ParamData_XML = "<ParameterValues RoutineName=""" & RoutineName & """/>"
            Else
                Dim ReportParamsXML As String = SessionAttribute(SessionID, "ReportParams")
                Dim ReportParams As New XmlDocument()

                If ReportParamsXML.Length > 0 Then
                    ReportParams.TryLoadXml(ReportParamsXML)
                    Dim ParamValues As XmlElement = ReportParams.DocumentElement.SelectSingleNode("ParameterValues[@RoutineName='" & RoutineName & "']")
                    If Not (ParamValues Is Nothing) Then
                        ParamData_XML = ParamValues.OuterXml
                    End If
                End If
            End If
        End If
    End If

    If LoadRoutine Then
        If ParamData_XML.Length > 0 Then
            Dim Param_XML As String = RoutineRead.CreateParameter("PrimaryKey", TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeInt, 4, PrimaryKey)
            Dim ReportParameters As New XmlDocument()
            ReportParameters.TryLoadXml(ParamData_XML)
            If ReportParameters.DocumentElement.ChildNodes.Count > 0 Then
                Dim RoutineParameters As New XmlDocument()
                RoutineParameters.TryLoadXml(RoutineRead.RoutineParameterByRoutineDescriptionXML(SessionID, RoutineName))
                For Each ReportParameter As XmlElement In ReportParameters.DocumentElement.ChildNodes()
                    Dim Order As String = ReportParameter.GetAttribute("ParameterOrder")
                    Dim Value As String = ReportParameter.GetAttribute("Value")
                    Dim RoutineParameter As XmlElement = RoutineParameters.DocumentElement.SelectSingleNode("RoutineParameter[@Order='" & Order & "']")
                    Dim ParameterName As String = RoutineParameter.GetAttribute("Description")
                    Dim DataType As String = RoutineParameter.GetAttribute("DataType")
                    Dim Length As String = RoutineParameter.GetAttribute("Length")
                    Dim trnDataType As TRNRTL10.Transport.trnDataTypeEnum
                    Select Case DataType.ToLower
                        Case "varchar"
                            trnDataType = TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeVarChar
                        Case "char"
                            trnDataType = TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeChar
                        Case "int"
                            trnDataType = TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeInt
                        Case "text"
                            trnDataType = TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeText
                        Case "float"
                            trnDataType = TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeFloat
                        Case "bit"
                            trnDataType = TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeBit
                        Case "datetime"
                            trnDataType = TRNRTL10.Transport.trnDataTypeEnum.trnDataTypeDateTime
                    End Select
                    Param_XML &= RoutineRead.CreateParameter(ParameterName, trnDataType, Length, Value)
                Next
            End If
            Try
                Data_XML = RoutineRead.ExecuteByDescription(SessionID, RoutineName, Param_XML)
            Catch ex As Exception
                RoutineError &= ex.Message.Replace("'", """")
            End Try
        End If
    Else
        SessionAttributeSet(SessionID, "ReportParams", "")
    End If
%>


<html>
<head>

<link rel="stylesheet" type="text/css" href="../../style/application.css">

<script id="clientEventHandlersJS" language="javascript">

function window_onload(blnGetParams)
{
    if (blnGetParams)
    {
        var strURL = 'PrintParameters.aspx?SessionID=<%= SessionID %>&ReportName=<%= ReportName %>&RoutineName=<%= RoutineName %>';
        var strParamsXML = window.showModalDialog(strURL, '', 'help:off ; status:off ; scroll:off ; dialogwidth=900px ; dialogheight=650px ;');
        
        //01Mar2010 Rams    F0079172 - error message when closing PAR dialogue box after getting incomplete message
        if (strParamsXML != undefined)
        {
            document.all("txtParamData_XML").value = strParamsXML;
            frmOCSReportLoader.action = '../Printing/OCSReportLoader.aspx?SessionID=<%= SessionID %>&BatchID=<%= BatchID %>&Preview=<%= Preview %>&IsReprint=<%= IsReprint %>&Mode=RunRoutine';
            frmOCSReportLoader.submit();
        } else
        {
            //24May2010 JMei F0075488 close the print window after PrintParameters.aspx closed
            window.parent.close();
        }
    }
    else
    {
        if (document.body.getAttribute("BatchID") > 0)
        {
            window.parent.DataReady();
        }
    }
}
</script>

</head>

<body BatchID="<%= BatchID %>" onselectstart="event.returnValue=false" oncontextmenu="return false" onload="return window_onload(<%= (LoadRoutine AndAlso (ParamData_XML.Length = 0)).ToString.ToLower %>)">
<form action="../Printing/OCSReportLoader.aspx?SessionID=<%= SessionID %>&BatchID=<%= BatchID %>&Preview=<%= Preview %>&IsReprint=<%= IsReprint %>"
				 method="post" id="frmOCSReportLoader" name="frmOCSReportLoader">

		Preview:			<input type="text" id='txtPreview' name='txtPreview' value='<%= Preview %>' /><br><br>
		RoutineName:		<input type="text" id='txtRoutineName' name='txtRoutineName' value='<%= RoutineName %>' /><br>
		RoutineError:		<input type="text" id='txtRoutineError' name='txtRoutineError' value='<%= RoutineError %>' /><br>
		BatchID:			<input type="text" id='txtBatchID' name='txtBatchID' value='<%= BatchID %>' /><br>
		PrintItemID:		<input type="text" id='txtPrintItemID' name='txtPrintItemID' value='<%= PrintItemID %>' /><br>
		Copies:				<input type="text" id='txtCopies' name='txtCopies' value='<%= Copies %>' /><br>
		ReprintItemID:		<input type="text" id='txtReprintItemID' name='txtReprintItemID' value='<%= ReprintItemID %>' /><br/>
		Report Name:		<input type="text" id='txtReportName' name='txtReportName' value='<%= ReportName %>' /><br>
		RTF:				<textarea rows=6 cols=80 id='txtReport_RTF' name='txtReport_RTF'><%= Report_RTF %></textarea><br>
		Data:				<xml id='xmlData_XML'><%= Data_XML %></xml><br>
		MediaTypeID:		<input type="text" id='txtMediaTypeID' name='txtMediaTypeID' value='<%= MediaTypeID %>' /><br>
		MediaType:			<input type="text" id='txtMediaTypeDescription' name='txtMediaTypeDescription' value='<%= MediaTypeDescription %>' /><br>
        Portrait:           <input type="text" id='txtPortrait' name='txtPortrait' value='<%= Portrait %>' /><br>
        	MarginTop 		<input type="text" id='txtMarginTop' 	name='txtMarginTop' 	value='<%= MarginTop    %>' /><br>
	        MarginBottom 		<input type="text" id='txtMarginBottom' name='txtMarginBottom' 	value='<%= MarginBottom %>' /><br>
	        MarginLeft 		<input type="text" id='txtMarginLeft'   name='txtMarginLeft' 	value='<%= MarginLeft   %>' /><br>
            	MarginRight 		<input type="text" id='txtMarginRight'  name='txtMarginRight' 	value='<%= MarginRight  %>' /><br>
		OrderReportType:	<input type="text" id='txtOrderReportTypeDescription' name='txtOrderReportTypeDescription' value='<%= OrderReportTypeDescription %>' /><br>
		Device Name:		<input type="text" id='txtDeviceName' name='txtDeviceName' value='<%= DeviceName %>' /><br>
		                	<input type="hidden" id='txtPrimaryKey' name='txtPrimaryKey' value='<%= PrimaryKey %>' /><br>
							<input type="hidden" id='txtAction' name='txtAction' value='' />
							<input type="hidden" id='txtPrintStatusID' name='txtPrintStatusID' value='' />
							<input type="hidden" id='txtParamData_XML' name='txtParamData_XML' value='<%= ParamData_XML %>' />
							<input type="hidden" id='txtPrevDeviceName' name='txtPrevDeviceName' value='<%= PrevDeviceName %>' />
		<br>

</form>

</body>
</html>
