<%@ Page language="vb" %>
<%@ Import Namespace="Ascribe.Common" %>
<%@ Import Namespace="System.Xml" %>
<%@ Import namespace="Ascribe.Xml" %>

<%
    '----------------------------------------------------------------------------------------------------------------
    '
    'DataTypeLoader.aspx
    '
    'Asyncronous loader page for the DataTypeStructureEditor and
    'TaskPicker applications.  Scripts a page of XML, for loading
    'into an XML Island on another page.  The XML format follows the
    'following standard:
    '
    '<root>
    '<item class="folder|root|orderset|product"
    'id="123" tableid="123" detail="xyz" description="xyz"
    'entitytypeid="123" entitytypedescription="xyz"
    'permissions="aedt"
    '/>
    '<item class="orderset" ..... >
    '<item .... />
    ''
    '</item>
    '<item .... />
    ''
    '</root>
    '
    '
    'Useage:
    'Takes the following querystring parameters:
    '
    'SessionID:			Mandatory
    'Mode:					one of:
    '"setup"				- returns all items from OrderCatalogueRoot, ie all search types
    '"folder", "root"	- returns all child items of the given folder or root folder.
    ',"dsstermroot", "dssterm"
    '
    '"searchtree"		- returns all folders and folder contents matching the search
    'criteria under the given search type
    '"searchproduct"	- as above, but searches for templates attached to products.
    'products are returned as folders.
    ''
    '"clearhistory"		- Clears this user's "My Common Tasks" folder
    '"orderset"			- Returns the contents of an order set, fully resolved.
    '"chemicalsearch"  - Returns a list of chemicals matching the criteria
    '"productroot"		- Returns a hard coded list of folders called a-z
    '"product"			- Return the next products and templates in the hierarchy
    '
    'ID:					Madatory, except for "setup" and "search" modes.  The ID of the folder, root, or product
    'to return child items for.
    '
    'RootID:
    '
    'Search:				Only for "Search" mode; contains the string to search for
    '
    'EntityFilter:		Only for "Setup" mode - if True, filters the list on the currently selected entity.
    '
    'RulesFilter:		For "folder", "root", "searchtree", "searchproduct", "mytasks" modes; if True,
    'the returned list is filtered according to any rules attached to each template.
    '
    'HideFilteredItems:As above, if true then any filtered items are removed from the result set.
    '
    'NoEditorInfo:		If True, no permissions/table information is returned. Used to reduce bandwidth
    'during run-time operation.
    'IncludeReason:		If True, Treatment Reason is returned with each template (can result in duplicate template id being returned)
    'for (folder) mode.
    '
    '
    'Modification History:
    '01Feb03 AE   Written
    '15May03 AE   WriteResult_NextLevel: Modified for changes made to order set database
    '06Aug03 AE   WriteRootXML:	Removed product root node as this no longer serves any purpose.
    '19Aug03 AE   Added XMLEscape to cope with nodes which contain illegal characters.
    '02Sep03 AE   Added Entity Filtering for Setup mode.
    '09Dec03 AE   Split GetItemXML into GetFolderXML and GetItemXML as parameter list was getting huge.
    'Added onSelect bit to items to indicate if any select rules exist.
    '17Jan03 AE   Added AutoCommit bit to items to indicate if items are to bypass the pending items process.
    '27May04 AE   Split GetFolderXML into GetFolderXML and GetProductXML.  Reduces amount of xml sent to the client.
    '02Aug04 AE   Now properly reports permissions for OrderCatalogueRoot nodes.
    '15Nov04 AE   Now falls back to Description if Description_Full is not provided.
    '31Jan05 AE   No longer returns detail as this is potentially very long text.
    'Also returns the product name as a separate field where appropriate.
    '18Feb05 AE   Ordersets are always marked as onSelect="1" as they should always be checked (#77298)
    '20May05 AE   Removed "convert to form" concept, this is now handled DB side.  A few mods to GetProductXML,
    'general tidying for new taskpicker.
    'Nov05 AE   Task picker now uses new improved page, TaskPickerLoader.aspx for scripting results.
    'It still uses this page for a couple of functions, clearing common tasks, and resolving ordersets.
    'The rest of this page is now only used for editors.
    '08Dec05 AE   Added ProductID to return list for templates.
    'Task 45001 25Sep12 YB   Added <?xml version='1.0' encoding='UTF-8' ?> so that the result is visible in browsers(easier for testing)
    '----------------------------------------------------------------------------------------------------------------
    Dim SessionID As Integer = Integer.Parse(Request.QueryString("SessionID"))
    Dim Mode As String = Request.QueryString("Mode").ToLower()
 
    Response.Write("<?xml version='1.0' encoding='UTF-8' ?>")
    Response.Write("<root>" & Environment.NewLine)
    Select Case Mode
        Case "setup"
            'Return the root nodes.
            WriteRootXML(SessionID)
        Case "folder", "root"
            'Return a single level of hierarchy from the given parent node.
            WriteFolderXML(SessionID, Mode)
        Case "clearhistory"
            'Clear this user's common tasks list
            ClearMyTasks(SessionID)
        Case "orderset"
            'Resolve the given orderset fully
            WriteOrdersetXML(SessionID)
        Case "chemicalsearch"
            'Return a list of chemicals matching the criteria
            WriteChemicalsListXML(SessionID)
        Case "productroot"
            'Return a hard coded list a-z
            WriteProductCategoriesXML()
        Case "product"
            'Return the next products and templates in the hierarchy
            WriteProductListXML(SessionID)
        Case "productroute"
            'Return all templates for the specified product and route
            WriteTemplatesByProductAndRouteXML(SessionID)
    End Select
    Response.Write("</root>" & Environment.NewLine)
%>

<script language="vb" runat="server">

    Const DEFAULT_PRODUCTINDEXGROUP As Integer = 1
    Const MAX_DETAIL_LENGTH As Integer = 128
    'Maximum amount of further detail we show
    '-----------------------------------------------------------------------------------------------
    Private Sub WriteRootXML(ByVal SessionID As Integer)
        
        'Retrieve the order catalogue root nodes
        Dim EntityFilter As Boolean = Not (String.IsNullOrEmpty(Request.QueryString("EntityFilter"))) AndAlso Request.QueryString("EntityFilter").ToLower() = "true"
        Dim Root_XML As String = New OCSRTL10.OrderCatalogueRead().GetAllRootNodesXML(SessionID, EntityFilter, False)
        '<root>
        '<OrderCatalogueRoot OrderCatalogueRootID="0" EntityTypeID="0" Description="SYSTEM"/>
        '</root>
        Dim OrderCatalogueRootDoc As New XmlDocument()
        OrderCatalogueRootDoc.TryLoadXml(Root_XML)
        Dim OrderCatalogueRootList As XmlNodeList = OrderCatalogueRootDoc.SelectNodes("root/OrderCatalogueRoot[@OrderCatalogueRootID != ""0""]")
        For Each OrderCatalogueRoot As XmlElement In OrderCatalogueRootList
            Dim ID As String = OrderCatalogueRoot.GetAttribute("OrderCatalogueRootID")
            Dim EntityTypeID As String = OrderCatalogueRoot.GetAttribute("EntityTypeID")
            Dim Detail As String = OrderCatalogueRoot.GetAttribute("Description")
            Dim EntityType As String = OrderCatalogueRoot.GetAttribute("EntityType")
            Dim Image As String = OrderCatalogueRoot.GetAttribute("ImageURL")
            Dim Permissions As String = PermissionsStringFromObject(OrderCatalogueRoot, Detail)
            Response.Write(GetFolderXML("root", ID, ID, Detail, "", Image, 0, EntityTypeID, EntityType, Permissions, 0) & "</item>")
        Next
        
    End Sub

    '-----------------------------------------------------------------------------------------------
    Private Sub WriteFolderXML(ByVal SessionID As Integer, ByVal Mode As String)
       
        Dim ProductID As Integer
        If Not Integer.TryParse(Request.QueryString("ProductID"), ProductID) Then
            ProductID = 0
        End If
        Dim ID As Integer = Integer.Parse(Request.QueryString("ID"))
        Dim HideFilteredItems As Boolean = Not (String.IsNullOrEmpty(Request.QueryString("HideFilteredItems"))) AndAlso Request.QueryString("HideFilteredItems").ToLower() = "true"
        If Mode = "root" OrElse ProductID = 0 Then
            'Standard folder browsing
            Dim RootID As Integer
            If Mode = "root" Then
                RootID = ID
                ID = 0
            Else
                RootID = Integer.Parse(Request.QueryString("RootID"))
            End If
            Dim IncludeReason As Boolean = Not (String.IsNullOrEmpty(Request.QueryString("IncludeReason"))) AndAlso Request.QueryString("IncludeReason").ToLower() = "true"
            Dim FilterList As Boolean = Not (String.IsNullOrEmpty(Request.QueryString("RulesFilter"))) AndAlso Request.QueryString("RulesFilter").ToLower() = "true"
            Dim NotesOnly As Boolean = Not (String.IsNullOrEmpty(Request.QueryString("NotesOnly"))) AndAlso Request.QueryString("NotesOnly").ToLower() = "true"
            If NotesOnly Then
                WriteResultXML(New OCSRTL10.OrderCatalogueRead().GetFolderContentsNotesOnlyXML(SessionID, ID, RootID, IncludeReason, FilterList, HideFilteredItems, True, Nothing, Nothing, False))
            Else
                WriteResultXML(New OCSRTL10.OrderCatalogueRead().GetFolderContentsXML(SessionID, ID, RootID, IncludeReason, FilterList, HideFilteredItems, True, Nothing, Nothing, False))
            End If
        Else
            WriteResultXML(New OCSRTL10.OrderCatalogueRead().OrderTemplateByOrderCatalogueAndProduct(SessionID, ProductID, ID, HideFilteredItems, Nothing, Nothing, False))
        End If
        
    End Sub

    '------------------------------------------------------------------------------------------------
    Private Sub ClearMyTasks(ByVal SessionID As Integer)
        
        'Clear this user's task list
        Dim OrderCommsItem As New OCSRTL10.OrderCommsItem()
        OrderCommsItem.ClearOrderHistory(SessionID)
        
    End Sub

    '------------------------------------------------------------------------------------------------
    Private Sub WriteOrdersetXML(ByVal SessionID As Integer)
        
        'Do a depth-first resolution of the
        'given orderset.
        Dim ID As Integer = Integer.Parse(Request.QueryString("ID"))
        Dim OrderSetRead As New OCSRTL10.OrderSetRead()
        WriteResultXML(OrderSetRead.ResolveOrderSet(SessionID, ID))
        
    End Sub

    '-----------------------------------------------------------------------------------------------
    Private Sub WriteChemicalsListXML(ByVal SessionID As Integer)
        
        Dim ChemicalsListXML As String = String.Empty
        Dim CharCode As Integer = Integer.Parse(Request.QueryString("ID"))
        Dim Search As String = Chr(CharCode).ToString()
        Dim ChemicalsXML As String = New DSSRTL20.ProductRead().SearchChemicalsXML(SessionID, Search, False, DEFAULT_PRODUCTINDEXGROUP)
        Dim ChemicalsDoc As New XmlDocument()
        ChemicalsDoc.TryLoadXml(ChemicalsXML)
        Dim Chemicals As XmlNodeList = ChemicalsDoc.SelectNodes("chemicals/Product")
        For Each Chemical As XmlElement In Chemicals
            ChemicalsListXML &= GetProductXML(Chemical.GetAttribute("ProductID"), Chemical.GetAttribute("Description"), Chemical.GetAttribute("ProductTypeID"), "1")
            ChemicalsListXML &= "</item>" & vbCr
        Next
        Response.Write(ChemicalsListXML)
        
    End Sub

    '------------------------------------------------------------------------------------------------
    Private Sub WriteProductCategoriesXML()
        
        'Scripts a hard-coded list of Products A - Products Z.
        'Only used in editors, so remains using GetFolderXML not GetProductXML
        Dim ProductCategoriesXML As String = String.Empty
        For CharCode As Integer = 90 To 65 Step -1
            ProductCategoriesXML &= GetFolderXML("chemicalsearch", "0", "0", CharCode.ToString(), Chr(CharCode).ToString(), "", "", "0", "0", "", "")
            ProductCategoriesXML &= "</item>"
        Next
        Response.Write(ProductCategoriesXML)
        
    End Sub

    '-----------------------------------------------------------------------------------------------
    Private Sub WriteTemplatesByProductAndRouteXML(ByVal SessionID As Integer)
        
        'List templates matching the specified route for the specified product
        Dim ProductID As Integer = Integer.Parse(Request.QueryString("ProductID"))
        Dim ProductRoute As String = Request.QueryString("ProductRoute")
        Dim ProductRouteID As Integer = Integer.Parse(Request.QueryString("ID"))
        
        If ProductRouteID <= 0 Then
            'Search everything
            ProductRoute = String.Empty
        End If
        
        WriteResultXML(New OCSRTL10.OrderCatalogueRead().ProductTemplateSearchLimitByProduct(SessionID, ProductID, 0, ProductRoute, False, Nothing, Nothing, False))
        
    End Sub

    '------------------------------------------------------------------------------------------------
    Private Sub WriteProductListXML(ByVal SessionID As Integer)
        
        'Return all templates attached to this product.  If an ordercatalogueID
        'is specified (which may of course be a treatment reason), the result is
        'limited by that parameter also.
        Dim ProductID As Integer
        Dim OrderCatalogueID As Integer
        Dim HideFilteredItems As Boolean = Not (String.IsNullOrEmpty(Request.QueryString("HideFilteredItems"))) AndAlso Request.QueryString("HideFilteredItems").ToLower() = "true"
        
        If String.IsNullOrEmpty(Request.QueryString("ID")) Then
            ProductID = 0
        Else
            ProductID = Integer.Parse(Request.QueryString("ID"))
        End If
        If String.IsNullOrEmpty(Request.QueryString("OrderCatalogueID")) Then
            OrderCatalogueID = 0
        Else
            OrderCatalogueID = Integer.Parse(Request.QueryString("OrderCatalogueID"))
        End If
        WriteResultXML(New OCSRTL10.OrderCatalogueRead().OrderTemplateByOrderCatalogueAndProduct(SessionID, ProductID, OrderCatalogueID, HideFilteredItems, Nothing, Nothing, False))
        
    End Sub
    
    
    
    '------------------------------------------------------------------------------------------------
    Private Sub WriteResultXML(ByVal ResultXML As String)
        
        'Generic routine to script the results of opening a folder.
        Dim ResultDoc As New XmlDocument()
        ResultDoc.TryLoadXml(ResultXML)
        '<root>
        '<OrderCatalogue OrderCatalogueID="4" OrderCatalogueID_Parent="0" OrderCatalogueRootID="39" Description="zzz" AllowEdit="1" AllowDelete="1" AllowCreateFolder="1" AllowCreateItem="0"/>
        '<Product ProductID="1" Description="xxx" />
        '<OrderTemplate OrderTemplateID="3" Description="xxx" TableID="123" RequestTypeID="123"/>
        '</root>
        Dim Contents As XmlNodeList = ResultDoc.SelectNodes("root/*")
        WriteResultXML_NextLevel(Contents)
        
    End Sub

    '------------------------------------------------------------------------------------------
    Sub WriteResultXML_NextLevel(ByVal OrderCatalogueContents As XmlNodeList)
        
        'Write this level of the structure out as an XML document
        'in our standard format.
        '
        'colContents:		Collection of IXML DOM Eelements specifying
        'RequestType(order set), OrderTemplate and OrderCatalogue rows
        'Any Child nodes of request types are also scripted.
        
        '26Jul2010 JMei F0092484 enable cut and paste single template/orderset
        Dim strOrderCatalogueID As String
        
        Dim blnHaveProducts As Boolean = False
        
        For Each OrderCatalogueItem As XmlElement In OrderCatalogueContents
            Select Case OrderCatalogueItem.Name
                Case "OrderCatalogue"
                    'This item is a folder
                    Dim DataClass As String = "folder"
                    Dim ID As String = OrderCatalogueItem.GetAttribute("OrderCatalogueID")
                    Dim RootID As String = OrderCatalogueItem.GetAttribute("OrderCatalogueRootID")
                    Dim Detail As String = OrderCatalogueItem.GetAttribute("Detail")
                    Dim Description As String = OrderCatalogueItem.GetAttribute("Description")
                    Dim Image As String = OrderCatalogueItem.GetAttribute("ImageURL")
                    Dim ProductID As String = OrderCatalogueItem.GetAttribute("ProductID")
                    Dim Permissions = PermissionsStringFromObject(OrderCatalogueItem, OrderCatalogueItem.GetAttribute("RootName"))
                    Dim bitSearch = OrderCatalogueItem.GetAttribute("searchfolder")
                    If OrderCatalogueItem.HasAttribute("Class") Then
                        DataClass = OrderCatalogueItem.GetAttribute("Class")
                    End If
                    Response.Write(GetFolderXML(DataClass, ID, RootID, Detail, Description, Image, ProductID, "0", "", Permissions, bitSearch))
                    Response.Write("</item>" & vbCr)
                Case "Product"
                    'This be a product
                    Dim ProductID As String = OrderCatalogueItem.GetAttribute("ProductID")
                    Dim Description As String = OrderCatalogueItem.GetAttribute("Description")
                    Dim ProductTypeID As String = OrderCatalogueItem.GetAttribute("ProductTypeID")
                    Dim OrderCatalogueID As String = OrderCatalogueItem.GetAttribute("OrderCatalogueID")
                    Response.Write(GetProductXML(ProductID, Description, ProductTypeID, OrderCatalogueID))
                    Dim ChildContents As XmlNodeList = OrderCatalogueItem.SelectNodes("Product")
                    If ChildContents.Count > 0 Then
                        Response.Write(vbCr)
                    End If
                    WriteResultXML_NextLevel(ChildContents)
                    Response.Write("</item>" & vbCr)
                    blnHaveProducts = True
                Case "ProductRoute"
                    'This item is a route
                    Dim DataClass As String = "productroute"
                    Dim ID As String = OrderCatalogueItem.GetAttribute("ProductRouteID")
                    Dim Description As String = OrderCatalogueItem.GetAttribute("Description")
                    Dim Image As String = "classSearchStructure.gif"
                    Dim ProductID As String = OrderCatalogueItem.GetAttribute("ProductID")
                    Response.Write(GetFolderXML(DataClass, ID, "0", Description, "", Image, ProductID, "0", "", "", "0"))
                    Response.Write("</item>" & vbCr)
                Case "OrderTemplate"
                    'This is a template
                    strOrderCatalogueID = OrderCatalogueItem.GetAttribute("OrderCatalogueID")
                    
                    Dim DataClass As String = OrderCatalogueItem.GetAttribute("Class")
                    Dim ID As String = OrderCatalogueItem.GetAttribute("OrderTemplateID")
                    Dim OrderSetItemID As String = "0"
                    Dim TableID As String = OrderCatalogueItem.GetAttribute("TableID")
                    Dim RequestTypeID As String = OrderCatalogueItem.GetAttribute("RequestTypeID")
                    Dim NoteTypeID As String = OrderCatalogueItem.GetAttribute("NoteTypeID")
                    Dim Description As String = OrderCatalogueItem.GetAttribute("Description")
                    Dim ProductName As String = OrderCatalogueItem.GetAttribute("ProductName")
                    Dim ProductID As String = OrderCatalogueItem.GetAttribute("ProductID")
                    Dim Reason As String = OrderCatalogueItem.GetAttribute("Reason")
                    Dim Permissions As String = String.Empty
                    Dim bitMandatory As String = "0"
                    Dim Applies As String = OrderCatalogueItem.GetAttribute("applies")
                    Dim onSelect As String = OrderCatalogueItem.GetAttribute("onSelect")
                    Dim bitIsPrescription As String = OrderCatalogueItem.GetAttribute("Prescription")
                    Dim bitAutoCommit As String = OrderCatalogueItem.GetAttribute("AutoCommit")
                    Dim bitSelectionOnly As String = OrderCatalogueItem.GetAttribute("SelectionOnly")
                    Dim bitContentsAreOptions As String = OrderCatalogueItem.GetAttribute("ContentsAreOptions")
                    If OrderCatalogueItem.HasAttribute("OrderSetItemID") Then
                        OrderSetItemID = OrderCatalogueItem.GetAttribute("OrderSetItemID")
                    End If
                    If OrderCatalogueItem.HasAttribute("RootName") Then
                        Permissions = PermissionsStringFromObject(OrderCatalogueItem, OrderCatalogueItem.GetAttribute("RootName"))
                    End If
                    If OrderCatalogueItem.HasAttribute("Mandatory") Then
                        bitMandatory = OrderCatalogueItem.GetAttribute("Mandatory")
                    End If
                    Response.Write(GetItemXML(DataClass, strOrderCatalogueID, ID, OrderSetItemID, TableID, RequestTypeID, NoteTypeID, Description, ProductName, ProductID, Reason, Permissions, bitMandatory, Applies, onSelect, bitIsPrescription, bitAutoCommit, String.Empty, bitSelectionOnly, bitContentsAreOptions))
                    Response.Write("</item>" & vbCr)
                Case "OrderSetTemplate"
                    'This is an orderset
                    strOrderCatalogueID = OrderCatalogueItem.GetAttribute("OrderCatalogueID")
                    
                    Dim DataClass As String = OrderCatalogueItem.GetAttribute("Class")
                    Dim ID As String = OrderCatalogueItem.GetAttribute("OrderTemplateID")
                    Dim OrderSetItemID As String = "0"
                    Dim TableID As String = OrderCatalogueItem.GetAttribute("TableID")
                    Dim RequestTypeID As String = OrderCatalogueItem.GetAttribute("RequestTypeID")
                    Dim NoteTypeID As String = OrderCatalogueItem.GetAttribute("NoteTypeID")
                    Dim Description As String = OrderCatalogueItem.GetAttribute("Description")
                    Dim ProductName As String = OrderCatalogueItem.GetAttribute("ProductName")
                    Dim ProductID As String = OrderCatalogueItem.GetAttribute("ProductID")
                    Dim Reason As String = OrderCatalogueItem.GetAttribute("Reason")
                    Dim Permissions As String = "D"
                    Dim bitMandatory As String = "0"
                    Dim Applies As String = OrderCatalogueItem.GetAttribute("applies")
                    Dim onSelect As String = OrderCatalogueItem.GetAttribute("onSelect")
                    Dim bitIsPrescription As String = OrderCatalogueItem.GetAttribute("Prescription")
                    Dim bitAutoCommit As String = OrderCatalogueItem.GetAttribute("AutoCommit")
                    Dim bitSelectionOnly As String = OrderCatalogueItem.GetAttribute("SelectionOnly")
                    Dim bitContentsAreOptions As String = OrderCatalogueItem.GetAttribute("ContentsAreOptions")
                    Description = Ascribe.Common.Constants.GetOrderDescription(Description, bitContentsAreOptions = "1")
                    If OrderCatalogueItem.HasAttribute("OrderSetTemplateID") Then
                        OrderSetItemID = OrderCatalogueItem.GetAttribute("OrderSetTemplateID")
                    End If
                    If OrderCatalogueItem.HasAttribute("Mandatory") Then
                        bitMandatory = OrderCatalogueItem.GetAttribute("Mandatory")
                    End If
                    Response.Write(GetItemXML(DataClass, strOrderCatalogueID, ID, OrderSetItemID, TableID, RequestTypeID, NoteTypeID, Description, ProductName, ProductID, Reason, Permissions, bitMandatory, Applies, onSelect, bitIsPrescription, bitAutoCommit, String.Empty, bitSelectionOnly, bitContentsAreOptions))
				
                    Dim ChildContents As XmlNodeList = OrderCatalogueItem.SelectNodes("*")
                    If ChildContents.Count > 0 Then
                        WriteResultXML_NextLevel(ChildContents)
                    End If
                    Response.Write("</item>" & vbCr)
                Case Else
                    'Info/title nodes;
                    Response.Write("<item class='" & OrderCatalogueItem.Name.ToLower() & "' " & "description='" & XMLEscape(OrderCatalogueItem.GetAttribute("description")) & "' " & "/>" & vbCr)
            End Select
        Next
        
    End Sub

    '------------------------------------------------------------------------------------------------
    Private Function GetProductXML(ByVal ProductID As String, ByRef Description As String, ByVal TypeID As String, ByVal OrderCatalogueID As String) As String
        
        Dim Type As String = String.Empty
        'Check which type of product this is
        Select Case TypeID
            Case "1"
                Type = "chem"
            Case "2"
                Type = "tm"
            Case "3"
                Type = "amp"
            Case "4"
                Type = "ampp"
        End Select
        'Escape descriptions - in case of "&" and other illegal characters				'19Aug03 AE
        Description = XMLEscape(Description)
        Return "<item class=""product"" " & "id=""" & ProductID & """ " & "producttype=""" & Type & """ " & "description=""" & Description & """ " & "ordercatalogueid=""" & OrderCatalogueID & """ " & ">"
        
    End Function

    '------------------------------------------------------------------------------------------------
    Private Function GetFolderXML(ByVal DataClass As String, ByVal ID As String, ByVal RootID As String, ByVal Description As String, ByVal Code As String, ByVal ImageURL As String, ByVal ProductID As String, ByVal EntityTypeID As String, ByRef EntityType As String, ByVal Permissions As String, ByVal bitSearchFolder As String) As String
        
        'Create the standard Item XML for Folders (ie, OrderCatalogue or Product Elements).
        'Note, does NOT add the closing "</item>" tag.
        Dim NoEditorInfo As Boolean = Not (String.IsNullOrEmpty(Request.QueryString("NoEditorInfo"))) AndAlso Request.QueryString("NoEditorInfo").ToLower() = "true"
        
        'Escape descriptions - in case of "&" and other illegal characters				'19Aug03 AE
        Description = XMLEscape(Description)
        Code = XMLEscape(Code)
        Dim FolderXML As String = "<item class=""" & DataClass & """ " & "id=""" & ID & """ " & "code=""" & Code & """ " & "description=""" & Description & """ " & "image=""" & ImageURL & """ " & "productid=""" & ProductID & """ "
        If Not NoEditorInfo Then
            FolderXML &= "permissions=""" & Permissions & """ "
        End If
        Select Case LCase(DataClass)
            Case "root"
                '02Sep03 AE  EntityType 0 means "for all" in this context
                If EntityTypeID = "0" Then
                    EntityType = "All"
                End If
                FolderXML &= "entitytypeid=""" & EntityTypeID & """ " & "entitytypedesc=""" & EntityType & """ " & "rootid=""" & RootID & """ "
            Case Else
                FolderXML &= "rootid=""" & RootID & """ searchfolder=""" & bitSearchFolder & """ "
                '16May07 AE
        End Select
        FolderXML &= ">"
        
        Return FolderXML
        
    End Function

    '------------------------------------------------------------------------------------------------
    '26Jul2010 JMei F0092484 enable cut and paste single template/orderset
    Private Function GetItemXML(ByVal DataClass As String, ByVal OrderCatalogueID As String, ByVal ID As String, ByVal OrderSetItemID As String, ByVal TableID As String, ByVal RequestTypeID As String, ByVal NoteTypeID As String, ByVal Description As String, ByVal ProductName As String, ByVal ProductID As String, ByVal Reason As String, ByVal Permissions As String, ByVal bitMandatory As String, ByVal Applies As String, ByRef onSelect As String, ByVal bitIsPrescription As String, ByVal bitAutoCommit As String, ByVal bitDirectHit As String, ByVal bitSelectionOnly As String, Optional ByVal bitContentsAreOptions As String = "") As String
        
        'Create the standard Item XML node.
        'Note, does NOT add the closing "</item>" tag.
        'lngTypeID:  This is for OrderTemplates only, and is the value of the RequestTypeID or NoteTypeID
        'field in the OrderTemplate table.   NOT to be confused with the
        'RequestTypeID in an Order set item, which is actually the unique ID of
        'the order set definition, and is passed on the lngID parameter.
        '
        'lngOrderSetItemID:		Only used for items which are part of an order set; is ignored for other items.
        'strApplies:				Only for OrderTemplates; If this item is linked to a rule, indicates if the rule applied.
        '(this is the mechanism for template filtering)
        'onSelect:					1 if the item has onSelect Dss rules attached
        'bitAutoCommit:			1 if the item bypasses the pending items table and is committed immediately.
        'bitDirectHit:				1 if the item was an exact match of the search, 0 if it was found by keyword search or similar.
        
        If String.IsNullOrEmpty(RequestTypeID) Then
            RequestTypeID = "0"
        End If
        If String.IsNullOrEmpty(NoteTypeID) Then
            NoteTypeID = "0"
        End If
        
        Dim NoEditorInfo As Boolean = Not (String.IsNullOrEmpty(Request.QueryString("NoEditorInfo"))) AndAlso Request.QueryString("NoEditorInfo").ToLower() = "true"
        Dim RootType As String
        Dim TypeID As String
        If RequestTypeID = "0" Then
            'Must have a note type
            RootType = "note"
            TypeID = NoteTypeID
        Else
            'Must have a request type
            RootType = "request"
            TypeID = RequestTypeID
        End If
        If DataClass = "orderset" Then
            onSelect = "1"
        End If
        'Escape descriptions - in case of "&" and other illegal characters	
        Description = XMLEscape(Description)
        Dim ItemXML As String = "<item class=""" & DataClass & """ " & "id=""" & ID & """ " & "tableid=""" & TableID & """ " & "ocstype=""" & RootType & """ " & "ocstypeid=""" & TypeID & """ " & "isrx=""" & bitIsPrescription & """ " & "description=""" & Description & """ "
        If CInt(OrderSetItemID) > 0 Then
            ItemXML &= "ordersetitemid=""" & OrderSetItemID & """ " & "mandatory=""" & bitMandatory & """ "
        End If
        If Not NoEditorInfo Then
            ItemXML &= "permissions=""" & Permissions & """ "
        End If
        If Not String.IsNullOrEmpty(ProductName) Then
            ItemXML &= "productname=""" & XMLEscape(ProductName) & """ "
        End If
        If Not String.IsNullOrEmpty(ProductID) Then
            ItemXML &= "productid=""" & ProductID & """ "
        End If
        If Not String.IsNullOrEmpty(Reason) Then
            ItemXML &= "reason=""" & Reason & """ "
        End If
        
        ItemXML &= "applies=""" & Applies & """ onselect=""" & onSelect & """ autocommit=""" & bitAutoCommit & """ directhit=""" & bitDirectHit & """ selectiononly=""" & bitSelectionOnly & """ ordercatalogueid=""" & OrderCatalogueID & """ contentsareoptions=""" & bitContentsAreOptions & """ >"
        
        Return ItemXML

    End Function

    '------------------------------------------------------------------------------------------------
    Private Function XMLEscape(ByVal Source As String) As String
        
        'Yes it is a cut-n-paste; in this case however it is far easier and safer
        'that trying to include a bit of javascript inside an XML document.
        'When they change the XML definition, you can sue me.
        If String.IsNullOrEmpty(Source) Then
            Return String.Empty
        End If
        Dim Return_XML As String = Source
        Return_XML = Return_XML.Replace("&", "&amp;")
        Return_XML = Return_XML.Replace("""", "&quot;")
        Return_XML = Return_XML.Replace("'", "&apos;")
        Return_XML = Return_XML.Replace("<", "&lt;")
        Return_XML = Return_XML.Replace(">", "&gt;")
        
        Return Return_XML
        
    End Function

    '--------------------------------------------------------------------------------------------
    Private Function TruncateString(ByVal AnyString As String, ByVal Length As Integer) As String
        
        'Truncates AnyString if it is longer than intLength
        Dim ReturnString As String = AnyString
        If ReturnString.Length() > Length Then
            ReturnString = ReturnString.Substring(0, Length) & "..."
        End If
        Return ReturnString
        
    End Function

    '------------------------------------------------------------------------------------------------
    Private Function PermissionsStringFromObject(ByVal OrderCatalogueRoot As XmlElement, ByVal RootName As String) As String
        
        '13Jan06 AE  Modified.  Permissions now determined by the item's root name (ie the OrderCatalogue section it's in).
        'Only items in "My Formulary" are editable.
        '18May07 AE  Modified to accomodate search folders, which aren't physically in MyFormulary, but logically are.
        Dim Permissions As String = String.Empty
        Dim IsEditableCatalogue As Boolean
        Select Case RootName
            Case "My Formulary", "Treatment Reasons"
                '25Nov06 AE  Include Treatment Reasons
                IsEditableCatalogue = True
            Case Else
                IsEditableCatalogue = OrderCatalogueRoot.HasAttribute("Search") AndAlso OrderCatalogueRoot.GetAttribute("Search") = "1"
        End Select
        If IsEditableCatalogue Then
            Select Case OrderCatalogueRoot.Name
                Case "OrderCatalogueRoot"
                    Permissions = "EDA"
                Case "OrderCatalogue"
                    '16May07 AE  Added M for MMMMMMark as search
                    Permissions = "EDATM"
                Case "OrderTemplate"
                    Permissions = "D"
            End Select
        End If
        
        'Hidden is implemented as a permission
        ' 05Mar14 CD - I assume that we shouldn't be testing for a blank attribute so have left it there just in case
        If (OrderCatalogueRoot.HasAttribute("") AndAlso OrderCatalogueRoot.GetAttribute("") = "1") Or (OrderCatalogueRoot.HasAttribute("Hidden") AndAlso OrderCatalogueRoot.GetAttribute("Hidden")) Then
            Permissions &= "H"
        End If
        
        Return Permissions
        
    End Function

</script>
