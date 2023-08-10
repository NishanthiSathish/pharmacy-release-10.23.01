//===========================================================================
//
//							      GridControl.cs
//
//  Provides a basic reusable grid control.
//
//  Grid is displayed in alternate row colours (white and yellow).
//  Double clicking a row can will cause a java event to be fired if you provide
//  a java event handler for property JavaEventDblClick, also supports single clicking
//  a row via the JavaEventClick.
//  
//  To be able to use the control you will need to include the OCSGrid.css, and 
//  GridControl.js files in your html page.
//
//  Usage:
//  in your html add
//  <%@ Register src="controls/GridControl.ascx" tagname="GridControl" tagprefix="uc1" %>
//  :
//  <script type="text/javascript" src="controls/GridControl.js"></script>
//  :
//  <link href="../../style/OCSGrid.css" rel="stylesheet" type="text/css" />
//  :
//  <uc1:GridControl ID="userGrid" runat="server" />
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
//	Modification History:
//	22Jul09 XN  Written
//  18Jun09 XN  Added extra functionality    
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;

public partial class application_RobotLoading_controls_GridControl : System.Web.UI.UserControl, System.Web.UI.INamingContainer
{
    /// <summary>Determines how a cells content can be aligned</summary>
    public enum AlignmentType
    {
        Left,
        Right,
        Center,
    };

    /// <summary>Type of column</summary>
    public enum ColumnType
    {
        Text,
        Checkbox,
    };

    /// <summary>Info about a column</summary>
    protected class ColumnInfo
    {
        public string        text;
        public int           width;
        public AlignmentType alignment;
        public bool          keepWhiteSpaces;
        public ColumnType    type;
    }

    /// <summary>Info about a row</summary>
    protected struct RowInfo
    {
        public List<string> extraAttributes;
        public List<string> items;
        public bool         visible;
    }

    protected List<ColumnInfo> columns = new List<ColumnInfo>();
    protected List<RowInfo>    rows    = new List<RowInfo>();

    public application_RobotLoading_controls_GridControl()
    {
        controlID = Guid.NewGuid().ToString();
    }

    // Control ID must be unique to the form
    public string controlID { get; set; }

    /// <summary>Message to display in the grid if it is empty</summary>
    public string EmptyGridMessage { get; set; }

    /// <summary>
    /// Java function to be run when you double click a row. Only need to provide the function name
    ///     JavaEventDblClick = "gridcontrol_dblclick"
    /// function will also need to include a varaible to receive the index of the row 
    ///     gridcontrol_dblclick(rowIndex)
    /// </summary>
    public string JavaEventDblClick { get; set; }

    /// <summary>
    /// Java function to be run when you click a row. Only need to provide the function name
    ///     JavaEventDblClick = "gridcontrol_click"
    /// function will also need to include a varaible to receive the index of the row 
    ///     gridcontrol_click(rowIndex)
    /// </summary>
    public string JavaEventClick { get; set; }

    /// <summary>
    /// Java function to be run when a check box is clicked. Only need to provide the function name
    ///     JavaEventDblClick = "gridcontrol_cbclick"
    /// function will also need to include a varaible to receive the index of the row, and column
    ///     gridcontrol_cbclick(row, column)
    /// </summary>
    public string JavaEventCheckBoxClick { get; set; }

    /// <summary>number of rows in the gird (includes hidden rows)</summary>
    public int RowCount
    {
        get { return rows.Count; }
    }

    /// <summary>
    /// Adds a column to the grid.
    /// Should be called before rows are added to the grid
    /// </summary>
    /// <param name="text">Column header</param>
    /// <param name="width">Column width as percentage</param>
    /// <param name="type">Column type</param>
    /// <param name="alignment">Alignment of text in the column cells</param>
    public void AddColumn(string text, int width, ColumnType type, AlignmentType alignment)
    {
        columns.Add(new ColumnInfo() { text = text, width = width, alignment = alignment, keepWhiteSpaces = false, type = type });
    }
    public void AddColumn(string text, int width)
    {
        AddColumn(text, width, ColumnType.Text, AlignmentType.Left);
    }
    public void AddColumn(string text, int width, AlignmentType alignment)
    {
        AddColumn(text, width, ColumnType.Text, alignment);
    }
    public void AddColumn(string text, int width, ColumnType type)
    {
        AddColumn(text, width, type, AlignmentType.Left);
    }

    /// <summary>
    /// Sets if the start and end white spaces of text in the columns
    /// cells is to be maintained (default is false).
    /// </summary>
    /// <param name="col">Column index</param>
    /// <param name="keep">If start and end white space are to be maintainted</param>
    public void ColumnKeepWhiteSpace(int col, bool keep)
    {
        columns[col].keepWhiteSpaces = keep;
    }

    /// <summary>
    /// Adds a row to the grid
    /// </summary>
    public void AddRow()
    {
        // Add in empty cells for all the new row
        List<string> cells = new List<string>(columns.Count);
        for(int c = 0; c < columns.Count; c++)
            cells.Add(string.Empty);

        // Create the new row structure
        RowInfo rowInfo = new RowInfo();
        rowInfo.items = cells;
        rowInfo.extraAttributes = new List<string>();
        rowInfo.visible= true;

        // Create the new row.
        rows.Add( rowInfo );
    }

    /// <summary>
    /// Adds a row to the grid setting each cell to 
    /// the string value of each args objectr
    /// </summary>
    /// <param name="args">cell data</param>
    public void AddRow(params object[] args)
    {
        List<string> cells = new List<string>();
        for(int c = 0; c < args.Count(); c++)
            cells.Add(args[c].ToString());

        // Create the new row structure
        RowInfo rowInfo = new RowInfo();
        rowInfo.items = cells;
        rowInfo.extraAttributes = new List<string>();
        rowInfo.visible= true;

        // Create the new row.
        rows.Add( rowInfo );
    }

    /// <summary>
    /// Adds an extra attribute to a row
    /// </summary>
    /// <param name="row">row index</param>
    /// <param name="key">attribute key</param>
    /// <param name="value">attribute value</param>
    public void AddRowExtraAttribute(int row, string key, string value)
    {
        // Get the row
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));
        RowInfo rowInfo = rows[row];

        // update the tag
        rowInfo.extraAttributes.Add(string.Format("{0}={1}", key, value));
    }

    /// <summary>
    /// Set is row is visible
    /// </summary>
    /// <param name="row">Row index</param>
    /// <param name="visible">If row visible</param>
    public void SetShowRow(int row, bool visible)
    {
        // Get the row
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));
        RowInfo rowInfo = rows[row];

        // Update
        rowInfo.visible = visible;     

        // Save
        rows[row] = rowInfo;     
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

        rowInfo.items[col] = string.Format(format, args);
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
}
