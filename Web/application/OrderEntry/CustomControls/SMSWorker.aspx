<%@ Page Language="VB" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>

<%
    '------------------------------------------------------------------------------------------------------------
    ' SMSWorker.aspx
    ' 
    ' Purpose               : Server side code to handle AJAX events called from sms profile.
    ' Modification History  : 
    '            
    '   06Jul09 ST      Written
    '   22Jul09 ST      Updates due to changes in sms spec
    '   29Jul09 ST      Updated to handle retrieving data for dose units
    '   08Sep09 Rams    F0062911 - Ripped off few repeatitive code 
    '------------------------------------------------------------------------------------------------------------
    Dim ProductRead As New DSSRTL20.ProductRead()
    
    Dim SessionID As Integer = Generic.CIntX(Request.QueryString("SessionID"))
    Dim ProductID As Integer = Generic.CIntX(Request.QueryString("ProductID"))
    Dim Mode As String = Request.QueryString("Mode").ToLower()
    Dim ProductType As String = String.Empty
    Dim ProductFormID As Integer = Generic.CIntX(Request.QueryString("ProductFormID"))
    
    Dim Data_XML As String = "<root>" & ProductRead.GetTypeByProductXML(SessionID, ProductID) & "</root>"

    Dim DOM As New XmlDocument()
    DOM.TryLoadXml(Data_XML)
    Dim TypeElement As XmlElement = DOM.SelectSingleNode("//ProductType")
    If Not (TypeElement Is Nothing) AndAlso TypeElement.HasAttribute("Description") Then
        ProductType = TypeElement.GetAttribute("Description")
    End If

    Select Case Mode
        Case "productform"
            Data_XML = ProductRead.ProductFormByProductTypeXML(SessionID, ProductID, ProductType)
        Case "productstrength"
            Data_XML = ProductRead.ProductStrengthByProductAndFormXML(SessionID, ProductID, ProductType, ProductFormID)
        Case "productpack"
            Data_XML = ProductRead.ProductPackByProductTypeXML(SessionID, ProductID, ProductType, ProductFormID)
        Case "productbrands"
            Data_XML = ProductRead.ProductBrandByProductTypeXML(SessionID, ProductID, ProductType)
        Case "productroutes"
            Dim ProductForm As String = Request.QueryString("ProductForm")
            Dim ProductBrand As String = Request.QueryString("ProductBrand")
            Dim ProductPack As String = Request.QueryString("ProductPack")
            If String.IsNullOrEmpty(ProductForm) And String.IsNullOrEmpty(ProductBrand) And String.IsNullOrEmpty(ProductPack) Then
                Data_XML = ProductRead.GetAllRoutesXML(SessionID, ProductID, True, True)
            Else
                Data_XML = ProductRead.GetRoutesForSMSProduct(SessionID, ProductID, ProductType, ProductForm, ProductBrand, ProductPack)
            End If
        Case "doseunits"
            Data_XML = ProductRead.GetSMSProductDoseUnit(SessionID, ProductID)
        Case Else
            Response.End()
    End Select
    Response.Write(Data_XML)
%>
