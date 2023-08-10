//===========================================================================
//
//							      PharmacyGridControl.cs
//
//  Provides a basic reusable grid control.
//  
//  To be able to use the control you will need to include the PharmacyGridControl.css,  
//  PharmacyGridControl.js, and jquery-1.3.2.js, files in your html page.
//  Also need jqueryExtensions.js to use javascript function findRowsContaining
//
//  Double clicking a row can will cause a java event to be fired if you provide
//  a java event handler for property JavaEventDblClick, also supports single clicking
//  a row via the JavaEventClick, and mouse down via JavaEventOnMouseDown.
//
//  Also ensure that each grid control on your form has a unique ID
//
//  Usage:
//  in your html add
//  <%@ Register src="../pharmacysharedscripts/PharmacyGridControl.ascx" tagname="GridControl" tagprefix="uc1" %>
//  :
//  <script type="text/javascript" src="../SharedScripts/lib/jquery-1.6.4.min.js"></script>
//  <script type="text/javascript" src="../pharmacysharedscripts/PharmacyGridControl.js"></script>
//  :
//  <link href="../../style/PharmacyGridControl.css" rel="stylesheet" type="text/css" />
//  :
//  <uc1:GridControl ID="userGrid" runat="server" CellSpacing="0" CellPadding="2" />
//
//  The in your page load code 
//  userGrid.AddColumn("Username", 75);
//  userGrid.AddColumn("User age", 25);
//
//  userGrid.AddRow();
//  userGrid.SetCell ( 0, "Fred" );
//  userGrid.SetCell ( 1, 34.ToString() );
//
//  userGrid.AddRow();
//  userGrid.SetCell ( 0, "Mike" );
//  userGrid.SetCell ( 1, 29.ToString() );
//
//  Row colouring
//  -------------
//  Enable alternate row colouring by setting EnableAlternateRowShading 
//  (off by default) rows are coloured white and yellow. Also possible to set 
//  row background colour using SetRowBackgroundColour this excepts any 
//  standard HTML colour using colour name or rgb e.g. #33CCFF, to have row 
//  specific colours alternate row shading must be turned off.
//
//  Usage
//  In your code behind (below will set first row blue, and second red)
//  userGrid.EnableAlternateRowShading = false;
//  userGrid.SetRowBackgroundColour(0, 'blue');
//  userGrid.SetRowBackgroundColour(1, '#FF0000');
//
//  Sortable columns
//  ----------------
//  Table allows clicking headers to sort by column. To enable this set 
//  SortableColumns to true (off by default), and set column type, if not set
//  data is treated as text.
//  Also possible to disable sorting for a specific column with AddColumn method.
//
//  Usage
//  In your code behind
//  userGrid.SortableColumns = true;
//  userGrid.AddColumn("Description", 60);
//  userGrid.AddColumn("Money",         10, ColumnType.Number);
//  userGrid.AddColumn("Vat rate",      10, ColumnType.Number);
//  userGrid.AddColumn("Date invoiced", 20, ColumnType.DateTime);
//
//  Selected row event
//  ------------------
//  By adding a pharmacygridcontrol_onselectrow method to your java script
//  it is possible to receive an event when a row is selected. 
//  You should always check the control name is correct as if there are two grid controls
//  on the same form the will both cause the method to execute.
//  Usage
//  On java side code
//  function pharmacygridcontrol_onselectrow(controlID, rowindex)
//  {
//      if (controlID == 'testGridControl')
//          alert ('selected row ' + rowindex);        
//  }
//
//  As an alternative to using the JavaEventOnRowSelected, this is for use for controls
//  where embbeding a pharmacygridcontrol_onselectrow might overwrite another method
//  The method will pass in the rowindex of the selected row
//
//  Multi select
//  ------------
//  The control now allows multi select by setting the attribute AllowMultiSelect = true
//  To get all the selected rows on the client use getSelectedRows.
//  To get the row that currently has focus use the standard getSelectedRow
//  Multi selected rows are identified by having css class MultiSelect.
//  The row that currently has focus will always have css classes Selected MultiSelect 
//  plus attribute selected=true (even if multi select is disabled)
//  In mult select mode when unselecting will fire event pharmacygridcontrol_onunselectrow (or event JavaEventOnRowUnselected)
//
//  Hide rows
//  ---------
//  It is possible to have hidden rows either by using PharmacyGridControl.SetRowVisible
//  or client side methods showRows, or setRowVisible
//  A row is hidden by setting it's style to display:none, and also by giving it an attribute
//  display=none (this allows it to work better with the jquery)
//
//  Configurable Columns
//  --------------------
//  It is possible to configure the column layout, by using table QSDisplayItem, QSField, and accessor class.
//  Then use following methods to setup the grid
//      QSLoadConfiguration - Loads in the data from QSDisplayItem.
//      AddColumnsQS        - Creates the grid columns from the QSDisplayItem data
//      AddRowQS            - Adds a new row to the grid using the accessor class, and QSDisplayItem data
//      AddRowAttributesQS  - normaly used where panel a configurable panel is linked to a grid 
//                            (so panel values are stored as row attributes)
//
//  Child rows
//  ----------
//  A grid can have multiple levels by setting the first row to type ColumnType.ChildRowButton,
//  Then expanded state of each parent row can be controlled by SetShowChildRow (both server and client side method)
//  If the row does not have any children then SetShowChildRow to null.
//  When the expand child row button is clicked to display child rows client side event OnClientGetChildRows will fire
//  This event will only fire when the child row is displayed not when row are to be hidden
//  Each row needs to be given a level (starting at 0).
//  Usage
//      grid.OnClientGetChildRows = "grid_OnClientGetChildRows";
//      grid.AddColumn("", 3, ColumnType.ChildRowButton);
//      grid.AddColumn("Description", 97, ColumnType.Text);
//      :
//      grid.AddRow(0);
//      grid.SetShowChildRow(false);  set to false as row is not expanded
//      grid.SetCellText(1, "Parent row");  first column is the expand button so start setting text as 1
//  On the client side when expand button is clicked grid_OnClientGetChildRows method will need to return the child rows
//      function grid_OnClientGetChildRows(controlID, rowIndex)
//      {
//          get child rows
//          return child rows
//      }
//
//	Modification History:
//	22Jul09 XN  Written
//  18Jun09 XN  Added extra functionality    
//  03Sep10 XN  Added sortable headers, ability to shade each row, marshable
//              headers (F0082255)
//  22Mar11 XN  Removed using rowindex attribute to determine index of each
//              row as does not work very well after sorting! 
//              Added kind of onselectrow event.
//              Added ColumnType.Money for correct sorting of money columns (F0092112)
//  16May11 XN  Added PgUp, and PgDown functions
//              Added server side ExtractHTMLRows, and clien side addRow, replaceRow
//              Made string sorting case insentive
//  24Oct11 XN  Added functions to allow rows to be hidden.
//  19Feb12 XN  Added properties FontSize_Cell, CellSpacing, CellPadding, and 
//              column header alignment. Also fixed problem with sorting number 
//              columns if cell does not contain a number.
//  28Dec12 XN  Added colalignment info to column header in HTML
//              Added new method javascript method MarshalRows (51139)
//  25Mar13 XN  Added FindIndexByAttrbiuteValue method (59607)
//  24Jul13 XN  Added methods SetCellColSpan, and SelectRow (24653)
//  25Apr13 XN  Added FindIndexByAttrbiuteValue method (59607)
//  02May13 XN  Added ClearRows, and SetRowTextColour methods (27038)
//  05Jul13 XN  Added Configurable Columns (ColumnLayoutHelper, ParseColumnSetup, AddColumns, AddRow, SetCell) 
//              plus ShowSortImage, RemoveColumn, GetColumnsTotalWidth 27252
//  01Nov13 XN  Added EnterAsDblClick option
//  29May14 XN  Added AllowTextWrap to the layout helper 88922
//              Added JavaEventOnMouseDown property for each row 88922
//              Added multi select 88922
//  11Jun14 XN  Fix for ExtractHTMLRows 43318
//              Slight speed improvment on client side selectRow
//  16Jun14 XN  Added JavaEventOnRowSelected, and JavaEventOnRowUnselected
//              events for using the gird in a control 88509
//  26Jun14 XN  On client side method findRowsContaining added ability to search 
//              whole row and remove ability to find rows not containing text
//  27Aug14 XN  Update client side method filterRows to handle multple columns (88922)
//  08Set14 XN  Replaced configurable methods, with new QueslScrol methods 
//              QSLoadConfiguration, AddColumnsQS, AddRowQS, and AddRowAttributesQS 98658
//  29May15 XN  Added support for child rows
//  18Jun15 XN  Fixed selecting first row as need to do on timer 39882
//  01Jul15 XN  Updated client side checkbox methods to handle newer jquery (support for prop) 39882
//  03Jul15 XN  Allowed AddRowQS to handle nulls BaseRow items 39882
//  28Jul15 XN  Client side change, when press space bar (on checkbox row) calls click event 
//              rather than method toogleCheck (so all events fire) 114905
//  18Aug15 XN  Added column attributes 126594
//  16May16 XN  Updated SelectRow to include setFocus option
//  18Jul16 XN  Fixed issue with SelectRow not working when grid is in a control 126634
//  26Aug16 XN  AddRowAttributesQS Allowed for null data elements 161288
//  11May18 GB  211742 Additional handling of expired contracts
//===========================================================================
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;

public partial class PharmacyGridControl : System.Web.UI.UserControl, System.Web.UI.INamingContainer
{
    /// <summary>Determines how a cells content can be aligned</summary>
    public enum AlignmentType
    {
        Left,
        Right,
        Center,
    }

    /// <summary>Type of column</summary>
    public enum ColumnType
    {
        Text,
        Number,
        Money,
        DateTime,
        Checkbox,

        /// <summary>If column cells have expand button to open child rows</summary>
        ChildRowButton
    }

    /// <summary>
    /// Used for when defining configurable column layouts (returned by ParseColumnSetup)
    /// 05Jul13 XN  27252
    /// </summary>
    public class ColumnLayoutHelper
    {
        public string                            Header             = string.Empty;
        public int?                              Width              = null;
        public PharmacyGridControl.ColumnType    ColumnType         = ColumnType.Text;
        public PharmacyGridControl.AlignmentType AlignmentType      = AlignmentType.Left;
        public string                            FieldName          = string.Empty;
        public string                            FieldFormatString  = string.Empty;
        public bool                              allowTextWrap      = false;        // Added XN 29May14 88922
    }

    /// <summary>Info about a column</summary>
    protected class ColumnInfo
    {
        public Dictionary<string,string> attributes;    // 18Aug15 XN 126594 Added 
        public string        text;
        public int           width;
        public AlignmentType alignment;
        public AlignmentType alignmentHeader;
        public bool          keepWhiteSpaces;
        public ColumnType    type;
        public bool          sortable;
        public bool          allowTextWrap;
        public bool          xmlEscaped;
    }

    /// <summary>Info about a row</summary>
    protected class RowInfo
    {
        public RowInfo()
        {
            this.attributes         = new List<string>();
            this.items              = new List<string>();
            this.colSpan            = new List<int>();
            this.styles             = new List<string>();
            this.backgroundColour   = null;
            this.visible            = true; 
            this.style              = null;
            this.showChildRows      = null;
            this.level              = null;
        }

        public List<string> attributes;
        public List<string> items;
        public List<int>    colSpan;                // 24Jul13 XN 24653 added
        public List<string> styles;
        public string       backgroundColour;
        public string       textColour;         // XN 02May13 Added row text colour 27038
        public bool         visible;
        public string       style;

        /// <summary>
        /// Set to true if the expand button is open, else false.
        /// Null if not child rows (so no expand button).
        /// </summary>
        public bool? showChildRows;

        /// <summary>Set row level (when using child rows) top level is 0</summary>
        public int? level;
    }

    protected List<ColumnInfo> columns = new List<ColumnInfo>();
    protected List<RowInfo>    rows    = new List<RowInfo>();

    public PharmacyGridControl()
    {
        this.VerticalScrollBar = true;
        this.ShowSortImage     = true;
        this.CellSpacing       = 2;
        this.CellPadding       = 1;
        this.EnterAsDblClick   = false;
    }

    /// <summary>Message to display in the grid if it is empty</summary>
    public string EmptyGridMessage { get; set; }

    /// <summary>
    /// Java function to be run when you double click a row. Only need to provide the function name
    ///     JavaEventDblClick = "gridcontrol_dblclick"
    /// function will also need to include a variable to receive the index of the row 
    ///     gridcontrol_dblclick(rowIndex)
    /// </summary>
    public string JavaEventDblClick { get; set; }

    /// <summary>
    /// Java function to be run when you click a row. Only need to provide the function name
    ///     JavaEventDblClick = "gridcontrol_click"
    /// function will also need to include a variable to receive the index of the row 
    ///     gridcontrol_click(rowIndex)
    /// </summary>
    public string JavaEventClick { get; set; }

    /// <summary>
    /// Java function to be run when a check box is clicked. Only need to provide the function name
    ///     JavaEventDblClick = "gridcontrol_cbclick"
    /// function will also need to include a variable to receive the index of the row, and column
    ///     gridcontrol_cbclick(row, column)
    /// </summary>
    public string JavaEventCheckBoxClick { get; set; }

    /// <summary>
    /// Java function to be run when mouse down event occurs, only need to provied function name
    ///     JavaEventOnMouseDown = "gridcontrol_onmousedown";
    /// when called the recieved index of the row is passed to the control
    ///     gridcontrol_onmousedown(rowIndex);
    /// XN 29May14 88922    
    /// </summary>
    public string JavaEventOnMouseDown { get; set; }

    /// <summary>
    /// Java function run when row is selected
    ///     JavaEventOnRowSelected = "gridControl_JavaEventOnRowSelected";
    /// where called the selected row index is passed to the control
    ///     gridControl_JavaEventOnRowSelected(rowIndex)
    /// </summary>
    public string JavaEventOnRowSelected { get; set; }

    /// <summary>
    /// Java function run when row is unselected (only in multi select mode)
    ///     JavaEventOnRowSelected = "gridControl_JavaEventOnRowUnselected";
    /// where called the selected row index is passed to the control
    ///     gridControl_JavaEventOnRowSelected(rowIndex)
    /// </summary>
    public string JavaEventOnRowUnselected { get; set; }

    /// <summary>
    /// Gets or sets client side function name called when child rows need to be displayed
    /// Then function being called needs to return the child rows as a string
    /// </summary>
    public string OnClientGetChildRows { get; set; }

    /// <summary>
    /// If the grid has alternate white, and yellow row shading.
    /// </summary>
    public bool EnableAlternateRowShading { get; set; }

    /// <summary>Allow multi select of rows 29May14 XN 88922</summary>
    public bool AllowMultiSelect { get; set; }

    /// <summary>If columns are sortable (default is false)</summary>
    public bool SortableColumns { get; set; }

    /// <summary>If sort icon is showed on column headers (default is true)</summary>
    public bool ShowSortImage { get; set; } 

    /// <summary>If show vertical scroll bar (default true)</summary>
    public bool VerticalScrollBar   { get; set; }

    /// <summary>If show horizontal scroll bar (default false)</summary>
    public bool HorizontalScrollBar { get; set; }

    /// <summary>Set the font size to use in the grid</summary>
    public FontUnit FontSize_Cell { get; set; }

    /// <summary>Set table cell spacing</summary>
    public int CellSpacing { get; set; }

    /// <summary>Set table cell padding</summary>
    public int CellPadding { get; set; }

    /// <summary>If the user can press enter\return to perform same function as dbl click</summary>
    public bool EnterAsDblClick { get; set; }

    /// <summary>number of rows in the gird</summary>
    public int RowCount
    {
        get { return rows.Count; }
    }

    /// <summary>number of columns in the gird</summary>
    public int ColumnCount
    {
        get { return columns.Count; }
    }

    /// <summary>List of QuesScrl display items used to create the grid (initalised by QSLoad)</summary>
    public QSDisplayItem QSDisplayItems { get; private set; }

    /// <summary>QuesScrl allow configuration</summary>
    public bool QSAllowConfiguration { get; set; }

    /// <summary>
    /// Adds a column to the grid.
    /// Should be called before rows are added to the grid
    /// </summary>
    /// <param name="text">Column header</param>
    /// <param name="width">Column width as percentage</param>
    /// <param name="type">Column type</param>
    /// <param name="alignment">Alignment of text in the column cells</param>
    /// <param name="sortable">Set if column sortable (default is true)</param>
    /// <param name="alignmentHeader">Alignment of header in the column cells</param>
    public void AddColumn(string text, int width, ColumnType type, AlignmentType alignment, bool sortable, AlignmentType alignmentHeader)
    {
        Debug.Assert(!(type == ColumnType.ChildRowButton && this.columns.Count != 0), "ChildRowButton column must be the first column in the grid");
        this.columns.Add(new ColumnInfo() { text = text, width = width, alignment = alignment, keepWhiteSpaces = false, type = type, sortable = sortable, allowTextWrap = false, xmlEscaped = true, alignmentHeader = alignmentHeader, attributes = new Dictionary<string,string>() });
    }
    public void AddColumn(string text, int width, ColumnType type, AlignmentType alignment, bool sortable)
    {
        AddColumn(text, width, type, alignment, sortable, AlignmentType.Center);
    }
    public void AddColumn(string text, int width)
    {
        AddColumn(text, width, ColumnType.Text, AlignmentType.Left, true, AlignmentType.Center);
    }
    public void AddColumn(string text, int width, AlignmentType alignment)
    {
        AddColumn(text, width, ColumnType.Text, alignment, true, AlignmentType.Center);
    }
    public void AddColumn(string text, int width, ColumnType type)
    {
        AddColumn(text, width, type, AlignmentType.Left, true, AlignmentType.Center);
    }
    public void AddColumn(string text, int width, ColumnType type, AlignmentType alignment)
    {
        AddColumn(text, width, type, alignment, true, AlignmentType.Center);
    }
    public void AddColumn(string text, int width, ColumnType type, AlignmentType alignment, AlignmentType alignmentHeader)
    {
        AddColumn(text, width, type, alignment, true, alignmentHeader);
    }

    /// <summary>
    /// Used for configurable columns. 
    /// Takes the output of ParseColumnSetup to build up the forms columns
    /// 05Jul13 XN  27252
    /// </summary>
    [Obsolete("User AddColumnsQS instead")]
    public void AddColumns(IEnumerable<ColumnLayoutHelper> columnLayouts)
    {
        foreach (ColumnLayoutHelper c in columnLayouts)
        {
            AddColumn(c.Header, (c.Width == null) ? -1 : c.Width.Value, c.ColumnType, c.AlignmentType);
            if (c.allowTextWrap)
                this.ColumnAllowTextWrap(this.ColumnCount - 1, true);   // Added XN 29May14 88922
        }
        foreach (ColumnInfo c in columns.Where(c => c.width == -1))
            c.width = 100 - this.GetColumnsTotalWidth();
    }

    /// <summary>Used to set column attributes 18Aug15 XN 126594</summary>
    /// <param name="key">attribute key</param>
    /// <param name="value">attribute value</param>
    public void AddColumnAttribute(string key, string value)
    {
        this.AddColumnAttribute(this.ColumnCount - 1, key, value);
    }

    /// <summary>Used to set column attributes 18Aug15 XN 126594</summary>
    /// <param name="column">Column Index</param>
    /// <param name="key">attribute key</param>
    /// <param name="value">attribute value</param>
    public void AddColumnAttribute(int column, string key, string value)
    {
        if (column < 0 && column >= this.ColumnCount)
            throw new ApplicationException("Invalid column index " + column.ToString());

        this.columns[column].attributes[key] = value;
    }

    /// <summary>
    /// Removes column by index
    /// 05Jul13 XN  27252
    /// </summary>
    public void RemoveColumn(int index)
    {
        columns.RemoveAt(index);
    }

    /// <summary>
    /// Sets if the start and end white spaces of text in the columns
    /// cells is to be maintained (default is false).
    /// </summary>
    /// <param name="col">Column index</param>
    /// <param name="keep">If start and end white space are to be maintained</param>
    public void ColumnKeepWhiteSpace(int col, bool keep)
    {
        columns[col].keepWhiteSpaces = keep;
    }

        /// <summary>Sets cell content can wrap to multiple lines (default is false)</summary>
        /// <param name="col">Column index</param>
        /// <param name="allowWrap">If column content allowed to wrap</param>
        public void ColumnAllowTextWrap(int col, bool allowWrap)
        {
            columns[col].allowTextWrap = allowWrap;
        }

        /// <summary>Sets if cell is xml escaped (default is true)</summary>
        /// <param name="col">Column index</param>
        /// <param name="xmlEscaped">If column content allowed to wrap</param>
        public void ColumnXMLEscaped(int col, bool xmlEscaped)
        {
            columns[col].xmlEscaped = xmlEscaped;
        }

    /// <summary>
    /// Adds a row to the grid
    /// </summary>
    public void AddRow()
    {
        // Create the new row structure
        RowInfo rowInfo = new RowInfo();

        // Add in empty cells for all the new row
        List<string> cells = new List<string>(columns.Count);
        for(int c = 0; c < columns.Count; c++)
            cells.Add(string.Empty);
        rowInfo.items = cells;

        // Add empty colSpan for the new row
        // 24Jul13 XN 24653 added
        List<int> colSpan = new List<int>(columns.Count);
        for(int c = 0; c < columns.Count; c++)
            colSpan.Add(1);
        rowInfo.colSpan = colSpan;

        // Add empty styles for each cell:
        rowInfo.styles = columns.Select(c => String.Empty).ToList();

        // Create the new row.
        rows.Add( rowInfo );
    }

    /// <summary>
    /// Adds a row to the grid setting each cell to 
    /// the string value of each args object
    /// </summary>
    /// <param name="args">cell data</param>
    public void AddRow(params object[] args)
    {
        // Create the new row structure
        RowInfo rowInfo = new RowInfo();

        List<string> cells = new List<string>();
        for(int c = 0; c < args.Count(); c++)
            cells.Add(args[c].ToString());
        rowInfo.items = cells;

        // Add empty colSpan for the new row
        // 24Jul13 XN 24653 added
        List<int> colSpan = new List<int>(columns.Count);
        for(int c = 0; c < columns.Count; c++)
            colSpan.Add(1);
        rowInfo.colSpan = colSpan;

        // Add empty styles for each cell:
        rowInfo.styles = columns.Select(c => String.Empty).ToList();

        // Create the new row.
        rows.Add( rowInfo );
    }

    /// <summary>
    /// Used for configurable headers to add a row to the grid.
    /// 05Jul13 XN  27252
    /// </summary>
    /// <param name="row">Row that contains the data (normaly BaseRow derived class)</param>
    /// <param name="columnLayout">Info on how to read the data (returned from ParseColumnSetup)</param>
    /// <param name="fieldConvterFunction">Optional parameter function used to convert field in row to string (only called if FieldName is wrapped in { })</param>
    [Obsolete("User AddRowQS instead")]
    public void AddRow(object row, List<ColumnLayoutHelper> columnLayout, Func<object,string,string,string> fieldConvterFunction)
    {
        this.AddRow();
        for (int c = 0; c < columnLayout.Count; c++)
            this.SetCell(c, row, columnLayout[c], fieldConvterFunction);
    }

    /// <summary>
    /// Adds an attribute to a row
    /// </summary>
    /// <param name="row">row index</param>
    /// <param name="key">attribute key</param>
    /// <param name="value">attribute value</param>
    public void AddRowAttribute(int row, string key, string value)
    {
        // Get the row
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));
        RowInfo rowInfo = rows[row];

        // update the tag
        rowInfo.attributes.Add(string.Format("{0}=\"{1}\"", key, value));
    }
    public void AddRowAttribute(string key, string value)
    {
        AddRowAttribute(rows.Count - 1, key, value);
    }

    /// <summary>Remove all rows from the grid XN 2May13 27038</summary>
    public void ClearRows()
    {
        rows.Clear();
    }

    /// <summary>Sets if row is visible or hidden</summary>
    /// <param name="row">row index</param>
    /// <param name="visible">If row is visible</param>
    public void SetRowVisible(int row, bool visible)
    {
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));
        rows[row].visible = visible;
    }

    /// <summary>
    /// Sets the cell value to the formatted string value
    /// If row is not specified then the value will be added to the last row added.
    /// </summary>
    /// <param name="col">Column index</param>
    /// <param name="row">Row index (default to last row added)</param>
    /// <param name="format">format string to use</param>
    /// <param name="args">Arguments to add to format string</param>
    private void SetCell(int col, int row, string format, params object[] args)
    {
        // If null assume empty string
        if (format == null)
            format = string.Empty;

        // Get the row
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));

        RowInfo rowInfo = rows[row];

        // set the cell value
        if (rowInfo.items.Count <= col)
            throw new ApplicationException(string.Format("Invalid col {0}.", col));

        rowInfo.items[col] = (args.Length == 0) ? format : string.Format(format, args);
    }
    public void SetCell(int col, string format, params object[] args)
    {
        SetCell(col, rows.Count - 1, format, args);
    }

    /// <summary>Checks the specified cell</summary>
    /// <param name="col">Column index</param>
    /// <param name="check">If cell checked</param>
    public void SetCheck(int col, bool check)
    {
        SetCell(col, rows.Count - 1, check ? "Y" : string.Empty);
    }

    /// <summary>
    /// Used for configurable headers set the cell to the data defined in columnLayout.FieldName (also uses columnLayout.FieldFormat)
    /// If the field name in columnLayout.FieldName is wrapped in { }, then method will call fieldConvterFunction to convert the data
    /// The calling convention of fieldConvterFunction is 
    ///     fieldConvterFunction(BaseRow, columnLayout.FieldName, columnLayout.FieldFormat);
    /// 05Jul13 XN  27252
    /// </summary>
    /// <param name="col">Index of column to set</param>
    /// <param name="row">Row that contains the data</param>
    /// <param name="columnLayout">Info on how to read the data (returned from ParseColumnSetup)</param>
    /// <param name="fieldConvterFunction">Optional parameter function used to convert field in row to string (only called if FieldName is wrapped in { })</param>
    [Obsolete("User AddRowQS instead")]
    public void SetCell(int col, object row, ColumnLayoutHelper columnLayout, Func<object,string,string,string> fieldConvterFunction)
    {
        string text = ConvertExtensions.PharmacyPropertyReader(row, columnLayout.FieldName, columnLayout.FieldFormatString, fieldConvterFunction);
        this.SetCell(col, text);
    }

    /// <summary>Gets the value of the cell</summary>
    /// <param name="col">column index</param>
    /// <param name="row">row index</param>
    /// <returns>Cell text</returns>
    private string GetCell(int col, int row)
    {
        // Get the row
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));

        RowInfo rowInfo = rows[row];

        // set the cell value
        if (rowInfo.items.Count <= col)
            throw new ApplicationException(string.Format("Invalid col {0}.", col));

        return rowInfo.items[col];
    }

    /// <summary>Gets if a cell is checked</summary>
    /// <param name="col">column index</param>
    /// <param name="row">row index</param>
    /// <returns>If cell checked</returns>
    public bool GetCheck(int col, int row)
    {
        // set the cell value
        if (columns.Count <= col)
            throw new ApplicationException(string.Format("Invalid col {0}.", col));

        ColumnInfo columnInfo = columns[col];
        if (columnInfo.type != ColumnType.Checkbox)
            throw new ApplicationException(string.Format("Column is not of type {0}.", ColumnType.Checkbox));

        return (GetCell(col, row) == "Y");
    }

    /// <summary>
    /// Set the background colour of a grid row.
    /// To be able to use this need to disable alternate row shading (EnableAlternateRowShading)
    /// </summary>
    /// <param name="row">row to shade</param>
    /// <param name="colour">row colour (html colour name, or rgb as #33CCFF)</param>    
    public void SetRowBackgroundColour(int row, string colour)
    {
        // Get the row
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));
        RowInfo rowInfo = rows[row];

        // Update
        rowInfo.backgroundColour = colour;     

        // Save
        rows[row] = rowInfo;     
    }
    public void SetRowBackgroundColour(string colour)
    {
        SetRowBackgroundColour(rows.Count - 1, colour);
    }

    /// <summary>
    /// Sets the col span of cell for the current row
    /// 24Jul13 XN 24653 added
    /// </summary>
    /// <param name="col">Column in current row to set</param>
    /// <param name="colSpan">Col span value to set</param>
    public void SetCellColSpan(int col, int colSpan)
    {
        int row = rows.Count - 1;
        RowInfo rowInfo = rows[row];

        // set the cell value
        if (rowInfo.items.Count <= col)
            throw new ApplicationException(string.Format("Invalid col {0}.", col));

        rowInfo.colSpan[col] = colSpan;
    }

    /// <summary>
    /// Sets the style of the cell for the current row
    /// </summary>
    /// <param name="col">Column in current row to set</param>
    /// <param name="style">The cell style</param>
    public void SetCellStyle(Int32 col, String style)
    {
        int row = rows.Count - 1;
        RowInfo rowInfo = rows[row];

        if (rowInfo.items.Count <= col)
            throw new ApplicationException(string.Format("Invalid col {0}.", col));

        // set the cell value
        rowInfo.styles[col] = style;
    }

    /// <summary>Set the text colour of a grid row.</summary>
    /// <param name="row">row to shade</param>
    /// <param name="colour">row text colour (html colour name, or rgb as #33CCFF)</param>    
    public void SetRowTextColour(int row, string colour)
    {
        // Get the row
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));
        RowInfo rowInfo = rows[row];

        // Update
        rowInfo.textColour = colour;     

        // Save
        rows[row] = rowInfo;     
    }
    public void SetRowTextColour(string colour)
    {
        SetRowTextColour(rows.Count - 1, colour);
    }

    /// <summary>Set the HTML stylef for the grid row (other items like SetRowTextColour will override this).</summary>
    /// <param name="row">row to shade</param>
    /// <param name="style">row style (e.g. 'font-weight:bold;')</param>    
    public void SetRowStyle(int row, string style)
    {
        // Get the row
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));
        RowInfo rowInfo = rows[row];

        // Update
        rowInfo.style = style;     

        // Save
        rows[row] = rowInfo;     
    }
    public void SetRowStyle(string style)
    {
        SetRowStyle(rows.Count - 1, style);
    }

    /// <summary>
    /// Returns index of row with the specified attribute value (case sensate on value and name)
    /// (only works on rows who's attributes been set by AddRowAttribute)
    /// Won't work if grid has been posted back, unless it has been manually repopulated.
    /// </summary>
    /// <param name="key">Attribute name</param>
    /// <param name="value">Attribute value</param>
    /// <returns>Index of row with specified attribute (or -1 if can't find)</returns>
    public int FindIndexByAttrbiuteValue(string key, string value)
    {
        string attribute = string.Format("{0}=\"{1}\"", key, value);
        return this.rows.FindIndex(r => r.attributes.Any(a => a == attribute));
    }

    /// <summary>
    /// Selects the row when the form first loads
    /// Uses ScriptManager.RegisterStartupScript and client side method selectRow to do this
    /// 24Jul13 XN 24653 added
    /// </summary>
    /// <param name="rowIndex">Index of row to select</param>
    /// <param name="setFocus">If to set focus on the grid</param>
    public void SelectRow(int rowIndex, bool setFocus = false)
    {
        StringBuilder script = new StringBuilder();
        //script.AppendFormat("setTimeout(function(){{ selectRow('{0}', {1}, true); ", this.ClientID, rowIndex);    18Jul16 XN 126634 works better with ID if grid is in a control 
        script.AppendFormat("setTimeout(function(){{ selectRow('{0}', {1}, true); ", this.ID, rowIndex);
        if (setFocus)
            script.AppendFormat("$('#{0}').focus();", this.ClientID);
        script.Append("}, 300);");
        ScriptManager.RegisterStartupScript(this, this.GetType(), "SelectRow" + this.ClientID, script.ToString(), true);
    }

    /// <summary>
    /// Returns the sum of all column widths so far (widths are in %)
    /// 05Jul13 XN  27252
    /// </summary>
    public int GetColumnsTotalWidth()
    {
        return this.columns.Sum(c => c.width);
    }

    /// <summary>Gets column width as percentage</summary>
    /// <param name="colIndex">Column index</param>
    /// <returns>Column width as percentage</returns>
    public int GetColumnWidth(int colIndex)
    {
        Debug.Assert(this.columns.Count > colIndex, string.Format("Invalid column {0}.", colIndex));
        return this.columns[colIndex].width;                      
    }

    /// <summary>Set column width as percentage</summary>
    /// <param name="colIndex">Column index</param>
    /// <param name="width">Column width as percentage</param>
    public void SetColumnWidth(int colIndex, int width)
    {
        Debug.Assert(this.columns.Count > colIndex, string.Format("Invalid column {0}.", colIndex));
        this.columns[colIndex].width = width;
    }

    /// <summary>
    /// If true show child rows icon will be open
    /// If false show child rows icon will be closed
    /// If null there will be no child row icon
    /// </summary>
    /// <param name="showChildRows">Set child rows icons as open (true), closed (false), or not to show (null)</param>
    public void SetShowChildRows(bool? showChildRows)
    {
        this.SetShowChildRows(this.RowCount - 1, showChildRows);        
    }
    
    /// <summary>
    /// If true show child rows icon will be open
    /// If false show child rows icon will be closed
    /// If null there will be no child row icon
    /// </summary>
    /// <param name="rowIndex">Row index to set</param>
    /// <param name="showChildRows">Set child rows icons as open (true), closed (false), or not to show (null)</param>
    public void SetShowChildRows(int rowIndex, bool? showChildRows)
    {
        Debug.Assert(this.rows.Count > rowIndex, string.Format("Invalid row {0}.", rowIndex));
        this.rows[rowIndex].showChildRows = showChildRows;        
    }

    /// <summary>Set row level used when grid has child rows (stored are row attribute level)</summary>
    /// <param name="level">Row level (top level is 0)</param>
    public void SetRowLevel(int level)
    {
        this.SetRowLevel(this.rows.Count - 1, level);
    }

    /// <summary>Set row level used when grid has child rows (stored are row attribute level)</summary>
    /// <param name="rowIndex">Row index</param>
    /// <param name="level">Row level (top level is 0)</param>
    public void SetRowLevel(int rowIndex, int level)
    {
        Debug.Assert(this.rows.Count > rowIndex, string.Format("Invalid row {0}.", rowIndex));
        this.rows[rowIndex].level = level;        
    }

    /// <summary>
    /// Parses a string of row attributes, marshalled using javascript function MarshalRowAttributes,
    /// attributes will mainly be the ones added PharmacyGridControl.AddRowAttribute.
    /// Returned data will be a list (one entry for each row), with an attribute to value dictionary paring.
    /// 
    /// Format of expected input string will use a cr (char 13) to split each row, and rs (record separator char 30) 
    /// to separate each attribute (stored as attribute name = value) 
    ///  {attr name}={value}rs{attr name}={value}rscr{attr name}={value}rs{attr name}={value}rscr{attr name}={value}rs{attr name}={value}rscr
    ///  
    /// standard html attributes (like style) will not be included in the list.
    /// 
    /// Note: the row's position in the list returned, may not match it's position when the table was created.
    /// Note: if a row does not have any attributes it will not appear in the returned list.
    /// </summary>
    /// <param name="rowAttributes">string of row attributes created from javascript method MarshalRowAttributes</param>
    /// <returns>list of rows, and the attribute name ot value pairing</returns>
    public static List<Dictionary<string, string>> ParseRowAttributes(string rowAttributes)
    {
        // Split the string into rows                   e.g. {attr name}={value}rs{attr name}={value}rscr{attr name}={value}rs{attr name}={value}rscr
        string[] attrsPerRow = rowAttributes.Split(new char[]{ (char)13 }, StringSplitOptions.RemoveEmptyEntries);

        // Marshal each row
        List<Dictionary<string, string>> parsedRowAttributes = new List<Dictionary<string,string>>(attrsPerRow.Length);
        foreach (string rowAttr in attrsPerRow)
        {
            // Split the row into attributes            e.g. {attr name}={value}rs{attr name}={value}rs
            string[] attributeStrs = rowAttr.Split(new char[]{ (char)30 }, StringSplitOptions.RemoveEmptyEntries);

            // Marshal each attribute                   e.g. {attr name}={value}
            Dictionary<string, string> attributeToValue = new Dictionary<string,string>(attributeStrs.Length);
            foreach (string attribute in attributeStrs)
            {
                string[] attributePair = attribute.Split(new char[]{'='}, 2);
                if (attributePair.Length == 2)
                    attributeToValue.Add(attributePair[0], attributePair[1]);
            }

            // Only add row to list if it has attributes
            if (attributeToValue.Any())
                parsedRowAttributes.Add(attributeToValue);
        }

        return parsedRowAttributes;
    }

    /// <summary>
    /// Returns the HTML row data from the table
    /// Can be used with client side addRow, and replaceRow, to update the table.
    /// </summary>
    /// <param name="startRow">Start row</param>
    /// <param name="count">Number of rows to read</param>
    /// <returns>HTML rows</returns>
    public string[] ExtractHTMLRows(int startRow, int count)
    {
        // Get the control to write itself.
        StringBuilder html = new StringBuilder();
        using (StringWriter sw = new StringWriter(html))
        {
            using (HtmlTextWriter writter = new HtmlTextWriter(sw))
                this.RenderControl(writter);
        }

        string str = html.ToString();

        // Extract table body
        // int startIndex = str.IndexOf("<tbody>") + 7;   11Jun14 XN 43318 fix 
        int startIndex = str.IndexOf("<tbody") + 7;
        int endIndex   = str.LastIndexOf("</tbody>");

        str = str.Substring(startIndex, endIndex - startIndex);

        // extract rows
        return str.Split(new string[] {"<tr"}, StringSplitOptions.None).Skip(startRow + 1).Take(count).Select(s => "<tr " + s.Trim()).ToArray();
    }

    /// <summary>
    /// Converts a string that defines the configurable headers, to a structure the grid control can use
    /// See text at top of file for details
    /// 05Jul13 XN  27252
    /// </summary>
    public static List<ColumnLayoutHelper> ParseColumnSetup(string columnSetup)
    {
        List<ColumnLayoutHelper> columns = new List<ColumnLayoutHelper>();
        string[] columnStr = columnSetup.Split(new [] { ',' });

        foreach (string col in columnStr)
        {
            ColumnLayoutHelper newColumn = new ColumnLayoutHelper();
            string[]    field     = col.Split(new [] { '|' });
            int fieldCount = field.Count();
            int width = 0;

            if (fieldCount > 0)
                newColumn.Header = field[0].Trim();
            if (fieldCount > 1 && int.TryParse(field[1].Trim(), out width))
                newColumn.Width = width;
            if (fieldCount > 2)
                newColumn.FieldName = field[2].Trim();
            if (fieldCount > 3)
                newColumn.FieldFormatString = field[3].Trim()   ;
            if (fieldCount > 4)
                newColumn.ColumnType = (PharmacyGridControl.ColumnType)Enum.Parse(typeof(PharmacyGridControl.ColumnType), field[4].Trim(), true);
            if (fieldCount > 5)
                newColumn.AlignmentType = (PharmacyGridControl.AlignmentType)Enum.Parse(typeof(PharmacyGridControl.AlignmentType), field[5].Trim(), true);
            if (fieldCount > 6)
                newColumn.allowTextWrap = BoolExtensions.PharmacyParse(field[6].Trim());        // Added XN 29May14 88922

            columns.Add(newColumn);
        }

        return columns;
    }

    #region QuesScrl Methods
    /// <summary>Load in the configuration data from QSDisplayItem table XN 9Sep14 98658</summary>
    public void QSLoadConfiguration(int siteID, string category, string section)
    {
        this.QSDisplayItems = new QSDisplayItem();
        this.QSDisplayItems.LoadBySiteIDCategorySection(siteID, category, section);

        hfConfigurationFormParams.Value = string.Format("?SessionID={0}&SiteID={1}&Accessors={2}&Category={3}&Section={4}", 
                                                            SessionInfo.SessionID, 
                                                            siteID, 
                                                            this.QSDisplayItems.Select(s => s.AccessorTag).Distinct().ToCSVString(","),
                                                            category,
                                                            section );

        if (!this.QSDisplayItems.Any())
            Response.Redirect("..\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=" + string.Format("No QuesScrol grid data for<br />Site ID:{0}<br />Category:{1}<br />Section:{2}", siteID, category, section));
    }

    /// <summary>Builds list of columns from the configurable data load in QSLoadConfiguration XN 9Sep14 98658</summary>
    public void AddColumnsQS()
    {
        // Create each column
        foreach (var i in this.QSDisplayItems)
        {
            // Align column
            AlignmentType alignmentType = AlignmentType.Left;
            switch (i.Alignment.ToUpper())
            {
            case "L": alignmentType = AlignmentType.Left;   break;
            case "C": alignmentType = AlignmentType.Center; break;
            case "R": alignmentType = AlignmentType.Right;  break;
            }

            // Coonvert QSData type to column type
            ColumnType columnType;
            switch (i.DataType)
            {
            case QSDataType.Number: 
                columnType = ColumnType.Number; 
                break;
            case QSDataType.Money:
                columnType = ColumnType.Money; 
                break;
            case QSDataType.Date:
            case QSDataType.DateTime:
            case QSDataType.Time:
                columnType = ColumnType.DateTime;
                break;
            default:
                columnType = ColumnType.Text;
                break;
            }

            // Add column
            this.AddColumn(i.Description, i.WidthAsPercentage, columnType, alignmentType);
            this.ColumnXMLEscaped(this.ColumnCount - 1, false);
            this.AddColumnAttribute("QSDataIndex", i.DataIndex.ToString());     // 18Aug15 XN 126594 Added 

            // Set allow wrap data
            if (i.AllowWrap)
                this.ColumnAllowTextWrap(this.ColumnCount - 1, true);
        }
    }

    /// <summary>Creates new row with cells poupated by QuesScrol display items load using LoadConfigurationQS XN 9Sep14 98658</summary>
    /// <param name="rowData">List of rows to read by the accessors</param>
    /// <param name="accessors">List of accessors referenced by the display items</param>
    public void AddRowQS(IEnumerable<BaseRow> rowData, IEnumerable<IQSDisplayAccessor> accessors)
    {
        // Create map of which accessor is to handle which data row (error any accessor does not have a data row)
        Dictionary<IQSDisplayAccessor, BaseRow> accessorToData = accessors.ToDictionary(a => a, a => a.FindFirstCompatibleRow(rowData));
        //if (accessorToData.Any(a => a.Value == null))
        //{
        //    var accessor = accessorToData.First(a => a.Value == null).Key;
        //    throw new ApplicationException(string.Format("No BaseRow passed in for accessor '{0}' support data type {1}", accessor.AccessorTag, accessor.SupportedType.FullName));
        //}

        // Add the row
        this.AddRow();

        foreach (QSDisplayItemRow i in this.QSDisplayItems)
        {
            // Get the accessor
            IQSDisplayAccessor accessor = accessors.FindByTag(i.AccessorTag);
            if (accessor == null)
                throw new ApplicationException(string.Format("'{0}' accessor was not supplied", accessor.AccessorTag));

            // Get the appropriate row data
            BaseRow row = accessorToData[accessor];

            // Set cell
            try
            {
                string text = row == null ? string.Empty : accessor.GetValueForDisplay(row, i.DataIndex, i.DataType, i.PropertyName, i.FormatOption);
                this.SetCell(i.DisplayIndex, text);
            }
            catch (Exception) { }
        }
    }

    /// <summary>
    /// Converts all QuesScrol values in displayItems into attributes for current row in form
    ///     QSItem{QSDisplayItemID}="value"
    /// XN 9Sep14 98658
    /// </summary>
    /// <param name="displayItems">Display items to store as attributes</param>
    /// <param name="rowData">List of rows to read by the accessors</param>
    /// <param name="accessors">List of accessors referenced by the display items</param>
    public void AddRowAttributesQS(IEnumerable<QSDisplayItemRow> displayItems, IEnumerable<BaseRow> rowData, IEnumerable<IQSDisplayAccessor> accessors)
    {        
        // Create map of which accessor is to handle which data row (error any accessor does not have a data row)
        Dictionary<IQSDisplayAccessor, BaseRow> accessorToData = accessors.ToDictionary(a => a, a => a.FindFirstCompatibleRow(rowData));
        //if (accessorToData.Any(a => a.Value == null))  26Aug16 allowed for null data elements 161288
        //{
        //    var accessor = accessorToData.First(a => a.Value == null).Key;
        //    throw new ApplicationException(string.Format("No BaseRow passed in for accessor '{0}' support data type {1}", accessor.AccessorTag, accessor.SupportedType.FullName));
        //}

        foreach (QSDisplayItemRow i in displayItems)
        {
            // Get the accessor
            IQSDisplayAccessor accessor = accessors.FindByTag(i.AccessorTag);
            if (accessor == null)
                throw new ApplicationException(string.Format("'{0}' accessor was not supplied", accessor.AccessorTag));

            // Get the appropriate row data
            BaseRow row = accessorToData[accessor];

            // Add attrbitue            
            try
            {
                string key   = string.Format("QSItem{0}", i.QSDisplayItemID);
                string value = row == null ? string.Empty : accessor.GetValueForDisplay(row, i.DataIndex, i.DataType, i.PropertyName, i.FormatOption);
                this.AddRowAttribute(key, value);
            }
            catch (Exception) { }
        }
    }
    #endregion
}
