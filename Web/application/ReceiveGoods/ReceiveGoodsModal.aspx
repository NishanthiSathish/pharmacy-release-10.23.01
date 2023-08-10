<!--	
                                ReceiveGoodsModal.aspx

	Wrapper for ICW_ReceiveGoods.aspx

	14Jan10 XN Created
-->
<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<!--#include file="../SharedScripts/ASPHeader.aspx"-->
<html>
<head>
    <title>Receive Goods</title>

    <script type="text/javascript" src="scripts/ICW_ReceiveGoods.js"></script>
</head>
<frameset rows="1" cols="1" onkeydown="form_onkeydown(event)">
    <frame application="yes" src="ICW_ReceiveGoods.aspx<%= Request.Url.Query %>&IsInModal=yes" />
</frameset>
</html>
