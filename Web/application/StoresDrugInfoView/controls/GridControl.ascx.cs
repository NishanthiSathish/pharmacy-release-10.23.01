//===========================================================================
//
//							      GridControl.cs
//
//  Provides a basic reusable grid control.
//
//  Each grid row will be displayed in alternate row colours (white and yellow).
//  Double clicking row will cause a gridcontrol_ondblclick java event to be fired
//  create your own java script method if this needs to be handled.
//  
//  To be able to use the control you will need to include the OCSGrid.css style 
//  sheet in you html page.
//
//  Usage:
//  in your html add
//  <%@ Register src="controls/GridControl.ascx" tagname="GridControl" tagprefix="uc1" %>
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
//  08Sep10 XN  Added multi line cells (F0054531)
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;

public partial class application_StoresDrugInfoView_controls_GridControl : System.Web.UI.UserControl, System.Web.UI.INamingContainer
{
    /// <summary>Determines how a cells content can be aligned</summary>
    public enum AlignmentType
    {
        Left,
        Right,
        Center,
    };

    /// <summary>Info about a column</summary>
    protected class ColumnInfo
    {
        public string        text;
        public int           width;
        public AlignmentType alignment;
        public bool          keepWhiteSpaces;
    }

    /// <summary>Info about a row</summary>
    protected struct RowInfo
    {
        public string       tag;
        public List<string[]> items;    // 08Sep10 XN F0054531 allows multiple rows per cell
    }

    /// <summary>Provides a unique id for this control, so can have two on a form</summary>
    protected string uniqueContainerID = Guid.NewGuid().ToString();

    protected List<ColumnInfo> columns = new List<ColumnInfo>();
    protected List<RowInfo>    rows    = new List<RowInfo>();

    public application_StoresDrugInfoView_controls_GridControl()
    {
        this.AllowDblClick = false;
    }

    /// <summary>Message to display in the grid if it is empty</summary>
    public string EmptyGridMessage { get; set; }

    /// <summary>If allowed to dobule click the gird</summary>
    public bool AllowDblClick { get; set; }

    /// <summary>number of rows in the gird</summary>
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
    /// <param name="alignment">Alignment of text in the column cells</param>
    public void AddColumn(string text, int width)
    {
        AddColumn(text, width, AlignmentType.Left);
    }
    public void AddColumn(string text, int width, AlignmentType alignment)
    {
        columns.Add(new ColumnInfo() { text = text, width = width, alignment = alignment, keepWhiteSpaces = false });
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
        List<string[]> cells = new List<string[]>(columns.Count);   // 08Sep10 XN F0054531 allow multiple rows per cell
        for(int c = 0; c < columns.Count; c++)
            cells.Add(new string[] { string.Empty });               // 08Sep10 XN F0054531 allow multiple rows per cell

        // Create the new row structure
        RowInfo rowInfo = new RowInfo();
        rowInfo.items = cells;
        rowInfo.tag   = string.Empty;

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
        List<string[]> cells = new List<string[]>();            // 08Sep10 XN F0054531 allow multiple rows per cell
        for(int c = 0; c < args.Count(); c++)
            cells.Add(new string[] { args[c].ToString() });     // 08Sep10 XN F0054531 allow multiple rows per cell

        // Create the new row structure
        RowInfo rowInfo = new RowInfo();
        rowInfo.items = cells;
        rowInfo.tag   = string.Empty;

        // Create the new row.
        rows.Add( rowInfo );
    }

    /// <summary>
    /// Sets the row tag this is stored as the tables row attribute
    /// as {tr tag="tag value" \}
    /// </summary>
    /// <param name="row">row index</param>
    /// <param name="tag">tag value to set</param>
    public void SetRowTag(int row, string tag)
    {
        // Get the row
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));
        RowInfo rowInfo = rows[row];

        // update the tag
        rowInfo.tag = tag;

        // save the row info
        rows[row] = rowInfo;
    }

    /// <summary>
    /// Gets the tag value for a row
    /// </summary>
    /// <param name="row">Row index</param>
    /// <returns>Tag value set with SetRowTag</returns>
    public object GetRowTag(int row)
    {
        // Get the row
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));

        // Returnt the row tag
        return rows[row].tag;        
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

        SetCell(col, row, new string[]{ string.Format(format, args) });
    }
    public void SetCell(int col, string format, params object[] args)
    {
        // If null assume empty string
        if (format == null)
            format = string.Empty;

        SetCell(col, rows.Count - 1, new string[]{ string.Format(format, args) });
    }

    /// <summary>
    /// Sets the value of a multi line cell
    /// </summary>
    /// <param name="col">Column index</param>
    /// <param name="row">Row index (default to last row added)</param>
    /// <param name="lines">lines in the cell</param>
    public void SetCell(int col, int row, string[] lines)
    {
        // If null assume empty string
        if (lines == null)
            lines = new string[] { string.Empty };

        // Get the row
        if (rows.Count <= row)
            throw new ApplicationException(string.Format("Invalid row {0}.", row));

        RowInfo rowInfo = rows[row];

        // set the cell value
        if (rowInfo.items.Count <= col)
            throw new ApplicationException(string.Format("Invalid col {0}.", col));

        rowInfo.items[col] = lines;
    }
}
