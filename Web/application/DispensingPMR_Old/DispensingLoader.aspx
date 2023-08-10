<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="ascribe.pharmacy.shared" %>
<!--#include file="../SharedScripts/ASPHeader.aspx"-->

<script language="vb" runat="server">

    '---------------------------------------------------------------------------------------------
    '
    'ICW_DispensingLoader.aspx
    '
    'On-demand loader that loads dispensing table rows (TRs) for the parent DispensingPMR grid table.
    '
    '   **********************************************************************************************
    '   *                                                                                            *
    '   * THIS IS THE OLD VERSION OF THE PMR AND YOU SHOULD NOT BE MAKING YOUR CHANGES HERE.         *
    '   * FOR THE NEW PMR ALL THIS CODE NOW EXISTS IN THE DispensingPMR.vb PROJECT                   *
    '   *                                                                                            * 
    '   **********************************************************************************************
    '
    'Modification History:
    '23Sep05 PH Created
    '09Mar07 TH Now Use DispSite - this is the familiar pharmacy description of the site, not the internal ID SC-06-0944
    '20Jun11 XN Added alternate row colouring, and highlighting of dispensed date F0086605
    '12Jul11 XN F0041502 have moved the main code to DispensingPMR.vb (DispensingPMR.RenderDispensings)
    '15Nov12 XN Made obsolete as replaced by newer speedy version TFS47487
    '13Mar13 XN  59024 Memory Leak Fix
    Dim lngSessionID As Long 
    Dim lngRequestID_Prescription As Long 
    Dim lngRequestID_Dispensing As Long 
    Dim strRepeatDispensing As String
    Dim strPSO as String
    Dim lngLevel As Long
</script>

<%
    lngSessionID = Generic.CLngX(Request.QueryString("SessionID"))
    lngRequestID_Prescription = Generic.CLngX(Request.QueryString("RequestID_Prescription"))
    'ID of parent prescription, for which dispesnings should be loaded
    lngRequestID_Dispensing = Generic.CLngX(Request.QueryString("RequestID_Dispensing"))
    strRepeatDispensing = Request.QueryString("RepeatDispensing")
    strPSO = Request.QueryString("PSO")
    lngLevel = Request.QueryString("Level")
    
    Dim xmldoc AS New System.Xml.XmlDocument    ' Dim xmldoc AS New MSXML2.DOMDocument() XN 13Mar13 59024 Memory Leak Fix
    Dim objDispensingRead AS New LEGRTL10.DispensingRead()    
    xmldoc.loadXML(objDispensingRead.DispensingListByPrescription(lngSessionID, lngRequestID_Prescription))
    objDispensingRead = Nothing
%>

<html>
<body>
<table id="tblLoader" width="100%" border RequestID_Dispensing=<%= lngRequestID_Dispensing %> >
<%
    'ID of dispensing that should be highlighted after data is loaded
    DispensingPMR_old.RenderDispensings(Me.Page, xmldoc, lngRequestID_Prescription, lngLevel, String.Equals(strRepeatDispensing, "True", StringComparison.CurrentCultureIgnoreCase), String.Equals(strPSO, "True", StringComparison.CurrentCultureIgnoreCase))
%>

</table>

<script>
	window.parent.DispensingsLoaded(<%= lngRequestID_Prescription %>, <%= lngRequestID_Dispensing %>)
</script>

</body>
</html>
