<%@ Page Language="VB" %>
<%@ Import Namespace="System.IO" %>
<%@ Import Namespace ="System.Drawing.Imaging" %>
<%@ Import Namespace ="System.Drawing" %>

<%
    Dim SessionID As Integer = Integer.Parse(Request.QueryString("SessionID"))
	Dim DrugChartReport As New ERXRTL10.DrugChartReport(SessionID)
	Dim ExportOptions As New DevExpress.XtraPrinting.ImageExportOptions(System.Drawing.Imaging.ImageFormat.Png())
	Dim Stream As New System.IO.MemoryStream
	Dim Bytes() As Byte
	
    ExportOptions.ExportMode = DevExpress.XtraPrinting.ImageExportMode.SingleFilePageByPage
	ExportOptions.Resolution = 150
	ExportOptions.PageBorderColor = System.Drawing.Color.Empty
	
	DrugChartReport.ExportToImage(Stream, ExportOptions)
	Bytes = Stream.ToArray()

	DrugChartReport.Dispose()
	Stream.Dispose()
    
	Response.BinaryWrite(Bytes)
	Response.End()
%>
