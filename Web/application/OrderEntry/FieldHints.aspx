<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace = "System.IO" %>
<%@ Import Namespace="Ascribe.Xml" %>
<% 
 Response.Buffer = true 
 Response.Expires = -1 
 Response.CacheControl = "No-cache" 
 %>
<html>
<%
    Dim TableName As String
    Dim FieldName As String 
    Dim objMetaRead As ICWRTL10.TableRead
    Dim objMetaDataRead As ICWDTL10.MetaDataRead
    Dim DOM As XmlDocument
    Dim xmlColumn As XmlElement
    Dim strTitle As String 
    Dim strHTML As String
    Dim strColumn_XML As String 
    Dim strPath As String 
    Dim strFile As String 
    Dim Directory_Info As DirectoryInfo
    Dim File_Info As FileInfo
    Dim StreamRdr As StreamReader
    Dim sessionId As Integer
    
    sessionId = CInt(Request.QueryString("SessionID"))
%>
<%
    '------------------------------------------------------------------------------------------------
    '
    'FieldHints.aspx
    '
    'Simple context-help page to aid filling in order forms.
    'Looks first for an HTML file in application/orderentry/help called TableName_FieldName.htm.
    'If that is not found, returns the Detail from the metadata for the specified column in the
    'specified table.
    '
    'Querystring Parameters:
    'Table:							Name OR ID of the table we're entering data for
    'Field:							Name of the field we want help for.
    'Note that, if we're providing an HTML file, this name does not have to be that
    'of an actual physical column, but can be the name of a concept.  An example is
    'the entry for "Dose" on PrescriptionInfusion that covers Dose, DoseUnit,
    'RoutineID_Dose, and some templatable fields that don't exist in the committed item.
    '
    '
    '17Jan05 AE  Written, quickly to show help for one field for immediate release.
    '18Jan05 AE  Finished, with full functionality.
    '------------------------------------------------------------------------------------------------
    strTitle = ""
    strHTML = ""
    strColumn_XML = ""
    TableName = Request.QueryString("Table")
    FieldName = Request.QueryString("Field")
    strTitle = "Hints"
    'Check if our Table has been specified by ID or name
    If IsNumeric(TableName) Then 
        objMetaRead = new ICWRTL10.TableRead()
        TableName = CStr(objMetaRead.GetDescription(sessionId, CInt(TableName)))
        objMetaRead = Nothing
    End IF
    'First, we look for a specialist file for that table and field.
    'These are stored in application/orderentry/help in the format Table_Field.htm
    strPath = Server.MapPath(".") & "\help\"
    strFile = TableName & "_" & FieldName & ".htm"
    'Look for a file named for this table and field
    
    Directory_Info = New DirectoryInfo(strPath)
    If Directory_Info.Exists Then 
        File_Info = New FileInfo(strPath & strFile)
        If(File_Info.Exists) Then
            StreamRdr = New StreamReader(strPath & strFile)
            strHTML = StreamRdr.ReadToEnd()
            StreamRdr.Close()
        End If
        StreamRdr = Nothing
    End If
    File_Info = Nothing
    Directory_Info = Nothing
    If strHTML = "" Then
        'Default is to read the detail from the metadata.
        'To be implemented....
        objMetaDataRead = New ICWDTL10.MetaDataRead()
        strColumn_XML = CStr(objMetaDataRead.ColumnByTableColumnNameXML(sessionId, CStr(TableName), CStr(FieldName)))
        objMetaDataRead = Nothing
        If strColumn_XML <> "" Then
            DOM = New XmlDocument()
            DOM.TryLoadXml(strColumn_XML)
            xmlColumn = DOM.SelectSingleNode("Column")
            If Not xmlColumn Is Nothing Then
                strHTML = xmlColumn.GetAttribute("Detail")
            End If
        End If
    End If
    If strHTML = "" Then
        'If nothing is found even there, we'll show a warning message
        strHTML = "<p>&nbsp;</p><div style='text-align:center'>Sorry, no help is available for that item</div>"
    End If
%>
    <script src="../sharedscripts/InactivityTimeout.js" type="text/javascript"></script>
<script type="text/javascript" FOR="window" EVENT="onload">
    //MM-2848-Inactivity Monitor
    var sessionId = '<%=sessionId %>';
    //alert('sessionId ' + sessionId);
    var desktopURL = "../sharedscripts/ActivityTimeOut.aspx";
    var pageName = "FieldHints.aspx";
    windowModal_SessionTimeOut(sessionId, desktopURL, "ActivityTimeOut" + "|" + pageName);
</script>

<head>
<title><%= strTitle %></title>
<base target="_self">

<style>
h1 {font-size:14pt; text-align:center;text-decoration:underline; margin-top:5px;}
h1 img {margin-right:10px; height:32px;width:32px; position:relative; top:7px;}

div.CloseLink {margin-top:30px; padding-bottom:50px;}

</style>
<link rel="stylesheet" type="text/css" href="../../style/OrderEntry.css" />
<link rel="stylesheet" type="text/css" href="../../style/application.css" />
</head>
<body scroll="yes">

<h1><img src="../../images/developer/Help FAQ.gif" /><%= strTitle %></h1>

<%= strHTML %>
<div align="center"><a href="javascript:close()">Close this Window</a></div>
    <iframe id="ActivityTimeOut" application="yes" style="display: none;"/>
</body>
</html>
