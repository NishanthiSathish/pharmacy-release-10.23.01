<!--	
                                UMMCBillingModal.aspx

	Wrapper for UMMCBillingModal.aspx

	03Sep10 XN Created
-->
<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>

<html>
<head>
    <title>UMMC Billing</title>

    <script type="text/javascript" src="scripts/UMMCBillingScreen.js"></script>
</head>
<frameset rows="1" cols="1" onkeydown="form_onkeydown(event)">
    <frame application="yes" src="UMMCBillingScreen.aspx<%= Request.Url.Query %>&IsInModal=yes" />
</frameset>
</html>