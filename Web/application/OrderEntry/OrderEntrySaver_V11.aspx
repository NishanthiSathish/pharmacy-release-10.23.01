<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import Namespace="Ascribe.Xml" %>
<%
    Dim SessionID As Integer
    Dim reader As New System.IO.StreamReader(Page.Request.InputStream)
    Dim ScriptImmediateAdmin As Boolean = False
    Dim XML_ImmediateAutocommitSTATItems As New XmlDocument()
    Dim DataDoc As New XmlDocument()

    SessionID = Integer.Parse(Request.QueryString("SessionID"))
    
    XML_ImmediateAutocommitSTATItems.TryLoadXml("<items></items>")
    'no warnings so is there any immediate stat doses requiring administration, match items on the id attribute
    Dim readerString As String = reader.ReadToEnd()
    
    If Not (String.IsNullOrEmpty(readerString)) Then
    '
        DataDoc.TryLoadXml(readerString)
        Dim Items As XmlNodeList = DataDoc.DocumentElement.SelectNodes("//immediateitem")
        For Each Item As XmlElement In Items
            ScriptImmediateAdmin = True
            Dim ItemID As String = Item.GetAttribute("id")
            Dim NewItemNode As XmlElement = XML_ImmediateAutocommitSTATItems.CreateElement("item")
            Dim NewItemAttribute As XmlAttribute = XML_ImmediateAutocommitSTATItems.CreateAttribute("PrescriptionID")
            NewItemAttribute.Value = ItemID
            NewItemNode.Attributes.SetNamedItem(NewItemAttribute)
            XML_ImmediateAutocommitSTATItems.DocumentElement.AppendChild(NewItemNode)
        Next
        'are there are some items to immediately administer
        If ScriptImmediateAdmin Then
            Generic.SessionAttributeSet(SessionID, CStr(IA_ITEMS), XML_ImmediateAutocommitSTATItems.OuterXml)
        End If
        '
    End If
    
    Response.Write(ScriptImmediateAdmin)
%>
