<%@ Page language="vb" %>
<html>
<head>

<%
    Dim strRoutineName As String 
    Dim strGrid_XML As String 
%>
<%
    '-------------------------------------------------------------------------
    '
    'RoutineGrid.aspx
    '
    'Container for an OCSGrid.
    '
    '02Apr03 AE  Modified; now recieves grid XML in a posted form, rather than
    'it being inserted by client script
    '26Jun03 PH  Copied the EpisodeGrid.aspx page to update this one.
    '27Jun11 Rams (F0117256 - Ward and consultant lookup)
%>


<%
    strRoutineName = Request.QueryString("RoutineName")
%>
<script language="javascript" type="text/javascript" src="../sharedscripts/jquery-1.3.2.js"></script>
<script language="javascript" src="../sharedscripts/ICWFunctions.js"></script>
<script language="javascript" src="../sharedscripts/ocs/OCSImages.js"></script>
<script language="javascript" src="../sharedscripts/ocs/OCSGrid.js"></script>
<script language="javascript" src="../sharedscripts/ocs/StatusMessage.js"></script>
<script language="javascript" src="../OrderEntry/Scripts/OrderEntry.js"></script>


<link rel="stylesheet" type="text/css" href="../../style/application.css" />
<link rel="stylesheet" type="text/css" href="../../style/OCSGrid.css" />


</head>

<script>
<!--

function ItemMouseClick(objRow)
{
    window.parent.ItemSelected();
}

function ItemDoubleClick(objRow) {
    window.parent.ItemSelected();
    window.parent.btnSelect_onclick();
}

function ItemKeypress(keyCode, objRow) {
    switch (keyCode) {
        case 13: // Enter
            if (window.parent.document.body.getAttribute("GetReturnValue") != undefined && window.parent.document.body.getAttribute("GetReturnValue").toLowerCase() == "true") {
                window.parent.ItemSelected();
                window.parent.btnSelect_onclick();
            }
            break;
        case 27: // Escape
            window.parent.btnCancel_onclick();
            break;
    }
}


//-->
</SCRIPT>

<body onselectstart="event.returnValue=false" oncontextmenu="return false" onLoad="InitialisePage();" scroll=no>

<!-- Form used for submitting XML server-->
<form id="frmData" method="post" action="RoutineGrid.aspx?refreshbutton=true" >
	<input type="hidden" name="gridXML" id="gridXML"></input>
	<input type="hidden" name="RoutineName" id="RoutineName"></input>
</form>

<!-- This is the area which will contain the grid data, if any -->

<%
    'Retrieve any submitted xml and script
    strGrid_XML = Request.Form("gridXML")
    If Trim(Request.Form("RoutineName")) <> "" Then 
        strRoutineName = Request.Form("RoutineName")
    End IF
    Ascribe.Common.OCSGrid.ScriptGrid(strGrid_XML, strRoutineName, false, false)
    '22Feb06 AE  Added BlockSelect and Multiselect parameters
    'Script a call back to the parent window to enable the "select" button
    If Request.QueryString("RefreshButton") = "true" Then 
        Response.Write("<script language=""javascript"" defer>" & "window.parent.document.all('btnSelect').disabled = (RowCount() == 0);" & "</script>")
    End If
%>




</body>
</html>
