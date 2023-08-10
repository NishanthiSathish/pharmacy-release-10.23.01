<%@ Page Language="VB" %>

<%
    ' Get data for MAR report
    Dim SessionID As Integer = Integer.Parse(Request.QueryString("SessionID"))
    Dim MedicinesAdministrationRecordReport As New ERXRTL10.MedicinesAdministrationRecordReport(SessionID)
    If MedicinesAdministrationRecordReport.IsEmpty() Then
        ' Return blank page as there is no data to render
        Response.Clear()
        Response.End()
    Else
        ' Render chart
        Dim ExportOptions As New DevExpress.XtraPrinting.ImageExportOptions(System.Drawing.Imaging.ImageFormat.Png())
        Dim Stream As New System.IO.MemoryStream
        Dim Bytes() As Byte

        ExportOptions.ExportMode = DevExpress.XtraPrinting.ImageExportMode.SingleFilePageByPage
        ExportOptions.Resolution = 300
        ExportOptions.PageBorderColor = System.Drawing.Color.Empty
        MedicinesAdministrationRecordReport.ExportToImage(Stream, ExportOptions)
        MedicinesAdministrationRecordReport.Dispose()
        Bytes = Stream.ToArray()
        Stream.Dispose()
        Response.BinaryWrite(Bytes)
        Response.End()
    End If
%>