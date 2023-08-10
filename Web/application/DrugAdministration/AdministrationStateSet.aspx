<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common.Generic" %>
<%@ Import Namespace="Ascribe.Common.DrugAdministrationConstants" %>
<html>
<head>
<title>Save Failed</title>
<script type="text/javascript" language="javascript" src="scripts/DrugAdministrationConstants.js"></script>
</head>

<body>

<%
    '---------------------------------------------------------------------------------------------------------
    '
    'AdministrationStateSet.aspx
    '
    'Created for options order sets processing. Will allow state saving for the selected dose (in AdministrationOptionsSelection.aspx)
    'Will save lngID as PrescriptionID.
    'Useage:
    'DA_REQUESTID - prescription id (actually is admin request id when options order set)
    'strDestinationURL - destination URL after we are done
    'Modification History:
    '09Jan07 CD  Written
    '
    '---------------------------------------------------------------------------------------------------------

    Dim sessionId As Integer
    Dim strRedirectUrl As String 
    Dim strDestinationUrl As String 

    sessionId = CIntX(Request.QueryString("SessionID"))
    
    strDestinationUrl = Request.QueryString("destinationurl")
    If Request.QueryString(DA_REQUESTID) <> "" Then 
        'save as prescription id
        SessionAttributeSet(sessionId, CStr(DA_PRESCRIPTIONID), Request.QueryString(DA_REQUESTID))
    End IF
    strRedirectUrl = strDestinationUrl & "?SessionID=" & sessionId & " &RequestID='" & Request.QueryString(DA_REQUESTID) & "' "
    Response.Redirect(strRedirectUrl)
%>
</body>
</html>

