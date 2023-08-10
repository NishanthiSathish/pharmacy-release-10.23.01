<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>

<html>
<head>
    <title>Report Selector</title>
    <link rel="stylesheet" type="text/css" href="../../style/application.css"/>
	<script type="text/javascript" src="../sharedscripts/icw.js"></script>
<script type="text/javascript">

function ShowReportList(strItem_XML) {
    
	document.getElementById("txtItemXML").value = strItem_XML;
	frmItem.submit();
}

function btnOK_click() {
    var lngId;
    var strXML;

    if (document.body.getAttribute("IsMHAForm") != 'true') {
        strXML = "<OrderReports>";
        var tblReportsLen = tblReports.tBodies[0].rows.length;
        for (lngIndex = 0; lngIndex < tblReportsLen; lngIndex++) {
            tr = tblReports.tBodies[0].rows[lngIndex];
            lngId = tr.getAttribute("id");
            objCheckBox = tr.firstChild.firstChild;
            if (objCheckBox.checked) {
                strXML += "<OrderReport OrderReportID='" + lngId + "' Copies='" + document.getElementById("cp" + lngId).value + "'/>"
            }

        }
        strXML += "</OrderReports>";
    }
    else {
        strXML = "";
        var opt = document.getElementsByName("MHA");
        var optLen = opt.length;
        for (lngIndex = 0; lngIndex < optLen; lngIndex++) {
            if (opt[lngIndex].checked) {
                var tr = tblMHA.tBodies[0].rows[lngIndex + 1];
                lngId = tr.getAttribute("noteid");
                var reportName = tr.getAttribute("reportname");
                strXML = { "NoteId": lngId,
                    "ReportName": reportName,
                    "Cancel":false
                };
            }
        }
        if (strXML == "")
            strXML = { "Cancel": true };
        strXML = JSON.stringify(strXML);
    }
    
	window.parent.returnValue = strXML;
	window.parent.close();
}

function btnCancel_click() {
if (document.body.getAttribute("IsMHAForm") != 'true') {
	window.parent.returnValue = "cancel";
	}
	else {
	    window.parent.returnValue = JSON.stringify({"Cancel":true});
	}
	window.parent.close();
}

</script>
	
</head>
<%
    Dim lngSessionID As Integer
    Dim strItem_XML As String
    Dim lngOrderReportTypeID As Integer 
    Dim xmldocItem As XmlDocument
    Dim xmlnodelistItem As XmlNodeList
    Dim xmlnodeItem As XmlElement
    Dim xmldocMRL As XmlDocument = Nothing
    Dim xmlnodeMRL As XmlElement
    Dim xmlnodelistMRL As XmlNodeList = Nothing
    Dim xmldocTemp As XmlDocument
    Dim xmlnodelistTemp As XmlNodeList
    Dim xmlnodeTemp As XmlElement
    Dim objOrderReportRead As PRTRTL10.OrderReportRead
    Dim lngOnCommitReportID As Integer
    Dim strOnCommitReportName As String = String.Empty
    Dim IsMHAForm As Boolean = False
    Dim DoesMHAFormExists As Boolean = False
%>
<%
    'ItemXML
    '<root>
    '<item tableid="123" dbid="123" [requesttypeid="32"] [notetypeid="212"] [responsetypeid="22"] />
    '</root>
    'OrderReport XML
    '<ROOT>
    '<OrderReport OrderReportID="1" Description="MyNewReportA" MediaTypeID="1" />
    '<OrderReport OrderReportID="2" Description="My report 2"  MediaTypeID="2" />
    '<OrderReport OrderReportID="3" Description="MyNewReportC" MediaTypeID="3" />
    '</ROOT>
    lngSessionID = CInt(Request.QueryString("SessionID"))
    strItem_XML = Trim(Request.Form("txtItemXML"))
    lngOrderReportTypeID = Generic.CIntX(Request.QueryString("OrderReportTypeID"))
    If (Request.QueryString("IsMHAForm") Is Nothing) OrElse Request.QueryString("IsMHAForm") = "" Then
        IsMHAForm = False
    Else
        IsMHAForm = Generic.CStrX(Request.QueryString("IsMHAForm")).ToUpper() = "TRUE"
    End If
    
    'Contains list of ocs items (ItemXML)
    'Master Report List
    'Temporary report list of reports matching the criteria: tableid, requesttypeid, notetypeid, responsetypeid etc
    If strItem_XML <> "" AndAlso Not IsMHAForm Then
        objOrderReportRead = New PRTRTL10.OrderReportRead
        
        xmldocTemp = New XmlDocument()
        xmldocMRL = New XmlDocument()
        xmldocMRL.TryLoadXml("<root/>")
        xmlnodeMRL = xmldocMRL.FirstChild()
        xmldocItem = New XmlDocument()
        xmldocItem.TryLoadXml(strItem_XML)
        
        xmlnodeItem = xmldocItem.SelectSingleNode("//commit[@OnCommitReport]")
        If Not (xmlnodeItem Is Nothing) Then
            strOnCommitReportName = xmlnodeItem.GetAttribute("OnCommitReport")
            If Trim(strOnCommitReportName) <> "" Then
                lngOnCommitReportID = CIntX(objOrderReportRead.IDByDescription(lngSessionID, strOnCommitReportName))
                If lngOnCommitReportID = 0 Then
                    Response.Clear()
                    Response.Write("<html><body>On-commit report: " & strOnCommitReportName & " cannot be found.</body></html>")
                    Response.End()
                End If
            End If
        End If
       
        'Get a list of ReportType that we want to print
        xmlnodelistItem = xmldocItem.selectNodes("//item")
        'Run through list of ReportTypes, finding all associated reports,
        'then add the reports to a unique master list of all reports to be printed.
        objOrderReportRead = New PRTRTL10.OrderReportRead()
        For Each printItem As XmlElement In xmlnodelistItem
            '16-Jan-2008 JA Error code 162 
            If printItem.HasAttribute("print") AndAlso printItem.GetAttribute("print").Length() > 0 Then ' Check item is marked as print on commit
                'Load a list of Reports that match the
                Try
                    xmldocTemp.LoadXml(objOrderReportRead.ListByVirtualOrderType(lngSessionID, _
                                       Generic.CIntX(printItem.GetAttribute("requesttypeid")), Generic.CIntX(printItem.GetAttribute("responsetypeid")), Generic.CIntX(printItem.GetAttribute("notetypeid")), _
                                       0, Generic.CIntX(printItem.GetAttribute("tableid")), CInt(lngOrderReportTypeID)))
                    xmlnodelistTemp = xmldocTemp.SelectNodes("//OrderReport")
                    'Check if the report is already in the master list, and if not, add it.
                    For Each xmlnodeTemp In xmlnodelistTemp
                        If xmldocMRL.SelectSingleNode("//OrderReport[@OrderReportID='" & xmlnodeTemp.GetAttribute("OrderReportID").ToString() & "']") Is Nothing Then
                            xmlnodeMRL.AppendChild(xmldocMRL.ImportNode(xmlnodeTemp.Clone(), True))
                        End If
                    Next
                Catch ex As Exception
                    Generic.ScriptFailiure("red exclamation 4.gif", "Error Loading Print Reports", "The print report could not be loaded; the following problem occurred:<br />" & ex.Message, "")
                End Try
            End If
        Next
        objOrderReportRead = Nothing
    ElseIf IsMHAForm Then
        Dim NoteRead As New OCSRTL10.NotesRead()
        xmldocMRL = New XmlDocument()
        Dim MHAFormXML As String = NoteRead.DoesMHAFormsExist(lngSessionID)
        If String.IsNullOrEmpty(MHAFormXML) Then
            DoesMHAFormExists = False
        Else
            DoesMHAFormExists = True
            xmldocMRL.TryLoadXml("<root>" & MHAFormXML & "</root>")
        End If
        
    End If
%>
<body scroll="no" IsMHAForm="<%=IsMHAform.ToString().ToLower() %>">
<table width=100% height=100% border>
	<tr>
		<td>
			<div STYLE='width: 100%; height: 100%; overflow: auto;'>
                <%  If strItem_XML <> "" AndAlso Not IsMHAForm Then%>
                    <table id="tblReports" width="100%" style="background-color: white" border>
                            <%
                                If lngOnCommitReportID > 0 Then
                            %>
	                                    <tr id="<%=lngOnCommitReportID%>" OnCommit="1">
	                                        <td><input id="Checkbox1" name="chkTick" type="checkbox" checked="checked"/></td>
		                                    <td><%=strOnCommitReportName%></td>
	                                        <td><input id="cp<%=lngOnCommitReportID%>" type="text" value="1" size="3" maxlength="3" onblur="if(Number(this.value)>0) {} else {this.value=1}"/></td>
	                                    </tr>
                            <%        
                                End If
                                
                            xmlnodelistMRL = xmldocMRL.SelectNodes("//OrderReport")
                                For Each xmlnodeMRL In xmlnodelistMRL
                            %>
	                                <tr id="<%=xmlnodeMRL.Attributes("OrderReportID").Value%>" OnCommit="0" >
	                                    <td><input id="chk" name="chkTick" type="checkbox" checked="checked"/></td>
		                                <td><%= xmlnodeMRL.Attributes("Description").Value%></td>
	                                    <td><input id="cp<%= xmlnodeMRL.Attributes("OrderReportID").Value %>" type="text" value="1" size="3" maxlength="3" onblur="if(Number(this.value)>0) {} else {this.value=1}"/></td>
	                                </tr>
                            <%
                                Next
                            %>
                    </table>
                <%ElseIf IsMHAForm Then%>
                    <table id="tblMHA" width="100%" style="background-color: white" >   
                        <%If DoesMHAFormExists Then%>
                            <tr>
                                <td colspan="2" style="font-weight:bold">
                                Select from the following which MHA Form to print
                                </td>
                            </tr>
                            <%        
                                xmlnodelistMRL = xmldocMRL.SelectNodes("/root/N")
                                For Each xmlnodeMRL In xmlnodelistMRL
                            %>
	                                <tr id="Tr1" noteid="<%=xmlnodeMRL.Attributes("NoteID").Value%>" reportname="<%=xmlnodeMRL.Attributes("ReportName").Value%>" >
	                                    <td><input id="chk" type="radio" name="MHA"/></td>
		                                <td><% =xmlnodeMRL.Attributes("NoteType").Value & " created on " & Generic.TDate2DateTime(xmlnodeMRL.GetAttribute("CreatedDate")) & " by " & xmlnodeMRL.GetAttribute("Entity") & " (" & xmlnodeMRL.GetAttribute("ReportName") & ")"%></td>
	                                </tr>
                            <%
                                Next
                            %>
                        <%Else%>
                            <tr>
                                <td style="font-weight:bold">
                                    There are no MHA Forms issued for the Current Episode.
                                </td>
                            </tr>
                        <%End If %>
                    </table>
                <% End If%>
                
			</div>
		</td>
	</tr>
	<tr height="1%">
		<td align="right">
			<button accesskey="O" onclick="btnOK_click()"><u>O</u>k</button>
			&nbsp;
			<button accesskey="C" onclick="btnCancel_click()"><u>C</u>ancel</button>
		</td>
	</tr>
</table>

	
<form id="frmItem" action="" method="post">
    <input type="hidden" id="txtItemXML" name="txtItemXML"/>
</form>
	
</body>

<%  If Not IsMHAForm Then%>

    <%
        If strItem_XML = "" Then
    %>
    <script type="text/javascript">
	    window.parent.Ready();
    </script>
    <%  ElseIf (xmlnodelistMRL.Count() < 1) AndAlso (lngOnCommitReportID <= 0) Then%>
    <script type="text/javascript">
	    btnOK_click();
    </script>
    <%
        End IF
    %>
<%
End If
%>

</html>

