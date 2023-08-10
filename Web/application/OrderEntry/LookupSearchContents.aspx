<%@ Page language="vb" %>

<%@ Import Namespace="Ascribe.Xml" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.RoutineSearch" %>
<html>
<head>

<%
    Dim SessionID As Integer
    Dim PageMode As String 
    Dim ColumnID As Integer 
    Dim TypeID As Integer
    Dim ValueID As Integer
    Dim objLookupRead As ICWRTL10.LookupRead
    Dim DOMTypes As XmlDocument
    Dim DOMValues As XmlDocument
    Dim DOMResults As XmlDocument
    Dim colTypes As XmlNodeList = Nothing
    Dim xmlType As XmlElement
    Dim xmlValuesRoot As XmlElement
    Dim colValues As XmlNodeList = Nothing
    Dim xmlValue As XmlElement
    Dim lngLookupTableID As Integer 
    Dim blnShowTypes As Boolean 
    Dim blnShowSearch As Boolean 
    Dim blnShowValues As Boolean 
    Dim strType_XML As String 
    Dim strValues_XML As String 
    Dim strRoutine_XML As String 
    Dim strQueryResult_XML As String 
    Dim strError As String 
    Dim strURL As String 
%>
<%
    'Querystring Parameters
    'Objects
    'General
    lngLookupTableID = 0
    blnShowTypes = false
    blnShowSearch = false
    blnShowValues = false
    strType_XML = ""
    strValues_XML = ""
    strRoutine_XML = ""
    strQueryResult_XML = ""
    strError = ""
    strURL = ""
    'Get querystring parameters
    SessionID = CInt(Request.QueryString("SessionID"))
    PageMode = LCase(Request.QueryString("Mode"))
    ColumnID = CInt(Request.QueryString("ColumnID"))
    TypeID = Generic.CIntX(Request.QueryString("TypeID"))
    ValueID = Generic.CIntX(Request.QueryString("ValueID"))
    'If required, read a list of types.  This will be the case in template mode,
    'when a typed lookup is selected.
    If PageMode = "typed" Then 
        'Build a list of types which delimit the specified table
        'First get the id of the lookup table from the foreign key column
        objLookupRead = new ICWRTL10.LookupRead()
        lngLookupTableID = CInt(objLookupRead.LookupTypeTableID(SessionID, ColumnID))
        objLookupRead = Nothing
        'We should always have a typed lookup in this mode, but we'll handle it if not...
        If lngLookupTableID > 0 Then 
            'Read the list of types
            objLookupRead = new ICWRTL10.LookupRead()
            strType_XML = CStr(objLookupRead.TypeListByTableID(SessionID, lngLookupTableID))
            objLookupRead = Nothing
            DOMTypes = new XmlDocument()
            DOMTypes.TryLoadXml(strType_XML)
            colTypes = DOMTypes.SelectNodes("root/*")
            blnShowTypes = true
        End IF
    End IF
    'Now read the values.  If the lookup is typed, and a TypeID has been selected,
    'we return only values of that type.
    objLookupRead = new ICWRTL10.LookupRead()
    strValues_XML = objLookupRead.GetValuesForDropDown(SessionID, ColumnID, TypeID, False)
    objLookupRead = Nothing
    '<values tablename="xyz" tableid="123"
    'novalues="true|false" toomany="true|false">                       'novalues is TRUE if no values were found
    '<value id=xxx>ValueText</value>                                            'toomany is TRUE if more than MaxValuesForDropDown values were found
    '<value id=xxx>ValueText</value>                                            'If neither toomany or novalues are true,
    ''                                                                       'a list of values is returned.
    ''
    '</values>
    DOMValues = new XmlDocument()
    DOMValues.TryLoadXml(strValues_XML)
    xmlValuesRoot = DOMValues.SelectSingleNode("values")
    If XmlExtensions.AttributeExists(xmlValuesRoot.GetAttribute("toomany")) AndAlso xmlValuesRoot.GetAttribute("toomany") = "1" Then
        'Too many values to script in a list, we need to provide a search
        'facitilty and list.
        blnShowSearch = True
    Else
        'We only have a few, so we can just show them in a list.
        colValues = xmlValuesRoot.SelectNodes("*")
        blnShowValues = True
    End If
%>



<title></title>

<script language="javascript" src="../Routine/Script/RoutineSearch.js"></script>

<script language="javascript">
//-------------------------------------------------------------------------------------

function Initialise() {

//Focus on the first available control
	if (document.all['col0'] != undefined) {
		document.all['col0'].focus();
	}
	
	if (document.all['lstTypes'] != undefined) {
		document.all['lstTypes'].focus();
	}

}
//-------------------------------------------------------------------------------------
function TypeChange() {

//Fires when a different type is selected in the types list

	if (lstTypes.selectedIndex > -1) {
		typeID = lstTypes.options[lstTypes.selectedIndex].getAttribute('dbid');
	
		var strURL = 'LookupSearchContents.aspx'
					  + '?SessionID=<%= SessionID %>'
					  + '&Mode=<%= PageMode %>'
					  + '&ColumnID=<%= ColumnID %>'
					  + '&TypeID=' + typeID;
		void window.navigate (strURL);
	}
}
//-------------------------------------------------------------------------------------

// Added this dummy method to return a blank URL, because the shared file RoutineSearch.js needs it, but this method doesn't exist on all the pages the RoutineSearch.js is included on!
function ActionURL() {
    return "";
}

</script>


<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/OrderEntry.css" />

</head>
<body scroll="no"
		onload="Initialise()"
		>

<table style="width:100%"  cellpadding="0" cellspacing="0" border=1>
<tr>
<%
    'Show a list of types, if specified
    If blnShowTypes Then 
        Response.Write("<tr><td class=""Info"" colspan=""2"" style='height:40px;'>" & "If required, you may limit the type of item which the end" & "user can select, by choosing a type in the box below" & "</td></tr>" & vbCr)
        Response.Write("<tr><td style='height:40px;'>" & vbCr & "<select id=""lstTypes"" " & "onchange=""TypeChange()"" " & ">" & vbCr)
        Response.Write("<option dbid=""0"">Any Type</option>" & vbCr)
        For Each xmlType In colTypes
            Response.Write("<option " & vbCr & "dbid=""" & xmlType.GetAttribute("dbid") & """ ")
            'Highlight this item if it is the selected one:
            If TypeID = CInt(xmlType.GetAttribute("dbid")) Then
                Response.Write("selected")
            End If
            Response.Write(">" & xmlType.GetAttribute("description") & "</option>" & vbCr)
        Next
        Response.Write("</td></tr>" & vbCr)
    End IF
    'Now we may have to script a routine search page
    If blnShowSearch Then 
        'Script that search page
        strURL = "LookupSearchContents.aspx?" & Ascribe.Common.Context.QueryString
        ScriptInputControlsByForeignColumn(SessionID, ColumnID, strURL, strRoutine_XML)
        'script search results...
        SearchExecute(SessionID, strRoutine_XML, strQueryResult_XML, strError)
        'Show them in a list
        If strQueryResult_XML <> "" Then 
            DOMResults = new XmlDocument()
            DOMResults.TryLoadXml(strQueryResult_XML)
            colValues = DOMResults.SelectNodes("root/*")
            If colValues.Count() > 0 Then
                'Script the values in a list, below
                Response.Write("<tr><td colspan=""2"">" & vbCr & "<select size=""10"" " & "style=""width:100%"" " & "ondblclick=""window.parent.CloseWindow(false)"" " & "onkeydown=""if(event.keyCode==13){window.parent.CloseWindow(false);}"" " & "id=""lstValues"">" & vbCr)
                For Each xmlValue In colValues
                    Response.Write("<option " & "dbid=""" & xmlValue.GetAttribute("id") & """ ")
                    Response.Write(">" & xmlValue.GetAttribute("description") & "</option>" & vbCr)
                Next
                Response.Write("</select></td></tr>")
            Else
                'No results returned
                Response.Write("<tr><td>" & "No matches found" & "</td></tr>" & vbCr)
            End If
        End IF
    End IF
    'Now list those values, if we have any
    If blnShowValues Then 
        Response.Write("<tr>" & vbCr)
        If PageMode = "typed" Then 
            Response.Write("<td class=""Info"" colspan=""2"" valign=""top"">" & "You can select a default value from the list below, if required." & "</td>" & vbCr)
        End IF
        Response.Write("<tr><td colspan=""2"">" & vbCr & "<select size=""10"" " & "style=""width:100%"" " & "ondblclick=""window.parent.CloseWindow(false)"" " & "id=""lstValues"">" & vbCr)
        Response.Write("<option dbid=""0"" ")
        If ValueID = 0 Then
            Response.Write("selected")
        End If
        Response.Write(">&lt;No Default&gt;</option>" & vbCr)
        For Each xmlValue In colValues
            Response.Write("<option " & "dbid=""" & xmlValue.GetAttribute("id") & """ ")
            If ValueID = CInt(xmlValue.GetAttribute("id")) Then
                Response.Write("selected")
            End If
            Response.Write(">" & xmlValue.InnerText & "</option>" & vbCr)
        Next
        Response.Write("</select></td></tr>")
    End IF
%>





	</tr>
</table>


</body>
</html>
