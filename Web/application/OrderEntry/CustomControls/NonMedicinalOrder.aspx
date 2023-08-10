<%@ Page language="vb" %>
<%@ Import namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Common"%>
<%@ Import Namespace="Ascribe.Common.OrderForm" %>
<%@ Import Namespace="Ascribe.Xml" %>

<!-- 
LM Code 162, 10/01/2008 ,
Removed Reference to OrderForm.vb.vb
Imported the namespaces Ascribe.Common.OrderForm
-->

<!--#include file="../../SharedScripts/ASPHeader.aspx"-->
<html>
<%
    Dim ProductID As Integer 
    Dim objProductRead As DSSRTL20.ProductRead
    Dim objTableRead As ICWRTL10.TableRead
    Dim DOM As XmlDocument
    Dim xmlProduct As XmlElement
    Dim Item_XML As String 
    Dim blnDisplay As Boolean 
    Dim blnTemplateMode As Boolean 
    Dim strProductName As String
    Dim lngItemID As Integer 
    Dim lngTableID As Integer
    Dim sessionId As Integer
    
    sessionId = CInt(Request.QueryString("SessionID"))
%>
<%
    '------------------------------------------------------------------------------------------------
    '
    'NonMedicinalOrder.aspx
    '
    'Custom Control for Order Entry, for entering Non medicinal product orders
    '
    '
    'Modification History:
    '01Dec05 AE  Written
    '16Oct06 AE  Fix error in display mode; have to load full item XML to obtain productid. Added IF blnDisplay....  #SC-06-0981
    '------------------------------------------------------------------------------------------------
%>




<head>






<%
    'Extract data from the querystring
    blnDisplay = (LCase(Request.QueryString("display")) = "true")
    blnTemplateMode = (LCase(Request.QueryString("template")) = "true")
    ProductID = Generic.CIntX(Request.QueryString("ProductID"))
    lngItemID = Generic.CIntX(Request.QueryString("DataRow"))
    If blnDisplay Then 
        '16Oct06 AE  Fix error in display mode; have to load full item XML to obtain productid. Added IF blnDisplay....  #SC-06-0981
        'Unfortunately we need to load the full XML to extract the productDetails
        objTableRead = new ICWRTL10.TableRead()
        lngTableID = objTableRead.GetIDFromDescription(sessionId, "ProductOrder")
        objTableRead = Nothing
        Item_XML = GetData_Instance("request", lngTableID, lngItemID, sessionId)
        DOM = new XmlDocument()
        DOM.TryLoadXml("<root>" & Item_XML & "</root>")
        xmlProduct = DOM.SelectSingleNode("//attribute[@name='ProductID']")
        ProductID = CInt(xmlProduct.GetAttribute("value"))
        strProductName = xmlProduct.GetAttribute("text")
    Else
        'Product is passed on the querystring
        objProductRead = new DSSRTL20.ProductRead()
        strProductName = objProductRead.DefaultDescriptionByID(sessionId, CInt(ProductID))
        objProductRead = Nothing
        strProductName = Trim(strProductName)
    End IF
%>

<script language="javascript" src="CustomControlShared.js"></script>
<script language="javascript" src="../scripts/OrderFormControls.js"></script>
<script language="javascript" src="../../sharedscripts/Controls.js"></script>
<script language="javascript" src="../../sharedscripts/ICWFunctions.js"></script>


<script language="javascript">
var m_blnTemplateMode = <%= LCase(CStr(blnTemplateMode)) %>;

//===========================================================================
//							Public Methods
//===========================================================================

function Populate(strData_XML) {

//Standard Populate method, called from the hosting form
	void instanceData.XMLDocument.loadXML(strData_XML);
	
	txtQuantity.value = GetValueFromXML('Quantity');
	txtDirection.value = GetValueFromXML('PrintableDirection');
	
	var lngProductID = 0;
	var strProductName = '';
	if (m_blnTemplateMode) {
		lngProductID = <%= ProductID %>;
		strProductName = '<%= strProductName %>';
	}
	else {
		lngProductID = GetValueFromXML('ProductID');
		strProductName = GetTextFromXML('ProductID');
	}
	
	void document.body.setAttribute('productid', lngProductID);
	void document.body.setAttribute('productname', strProductName);

}

//===========================================================================

function GetData() {

//Standard method to read data from this control.
//Called from the hosting form to retrieve data
//Returns XML elements as follows:
//			<attribute name="" value="" />

	var strXML = '';
//	var strDescription = document.body.getAttribute('productname');
	var strDescription = (txtQuantity.value != '' ? ' X ' + txtQuantity.value :  '[specify quantity]');
	if (trim(txtDirection.value) != '') strDescription += '. ' + trim(txtDirection.value);
	
	strXML += FormatXML('ProductID', document.body.getAttribute('productid'), document.body.getAttribute('productname'));
	if (txtQuantity.value != '') strXML += FormatXML('Quantity', txtQuantity.value);
	if (txtDirection.value != '') strXML += FormatXML('PrintableDirection', txtDirection.value);
	strXML += FormatXML('ASCDescription', strDescription);
	
	if (m_blnTemplateMode){
	//When building templates, set the description to the default description; the user can
	//then overtype this if they desire.
		window.parent.parent.document.all['spnItemTitle'].innerHTML = strDescription;	
	}
	return 'xml=' + strXML;
}

//===========================================================================
function ValidityCheck() {
	return true;
}

//===========================================================================
function FilledIn() {
	return true;
}

//===========================================================================


</script>

<%
    If blnDisplay Then 
%>

<script language=javascript defer>void SetReadOnly();</script>
<%
    End IF
%>

<link rel="stylesheet" type="text/css" href="../../../style/OrderEntry.css" />
<link rel="stylesheet" type="text/css" href="../../../style/application.css" />

</head>

<body id="formBody" 
		class="OrderFormBody" 
		sid="<%= sessionId %>" 
		frameid="<%= Request.QueryString("FrameID") %>"		
		controlid="<%= Request.QueryString("ControlID") %>" 
		displaymode="<%= LCase(CStr(blnDisplay)) %>"
		onkeydown="if (window.event.keyCode == 27) window.parent.parent.CloseWindow(true);"
		onload="<%
    If Not blnDisplay Then 
        Response.Write("txtQuantity.focus()")
    End IF
%>
"
		onunload="Local_CloseReferenceWindow()"
		>
<table>
	<tr>
		<td class="DrugTitle"><%
		                          LookupButton(sessionId, ProductID)
%><%= strProductName %></td>
	</tr>
	
	<tr>
		<td class="LabelField"><u>Q</u>uantity:</td>
		<td>
			<input type="text"
					 id="txtQuantity"
					 validchars="INTEGER"
					 maxlength="5"
					 accesskey="q"
					 class="StandardField"
					 onpaste="MaskInput(this)"
					 onkeypress="MaskInput(this)"
					 style="width:100px"
					 tabindex="1"
					 />
		</td>
	</tr>
	
	<tr>
		<td class="LabelField"><u>D</u>irections:</td>
		<td>
			<textarea rows="5"
						 id="txtDirection"
						 validchars="ANY"
						 maxlength="72"
						 accesskey="d"
						 class="StandardField"
						 onpaste="MaskInput(this)"
						 onkeypress="MaskInput(this)"
						 style="width:400px"
						 tabindex="2"
					 	 ></textarea>
		</td>
	</tr>
</table>

<xml id="instanceData"></xml>

</body>
</html>
