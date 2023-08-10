//==============================================================================================
//
//      					            EditList.aspx.cs
//
//  Provides a general purpose editor simliar the the QuesScrl editor, where data is displayed
//  in a table, and the user can move around cells and perfrom an in-place or popup edit.
//  Unlike QuesScrl you can manually build up the table (not have it configured in the db)
//
//  Data in the form supports view state.
//
//  Currently have only tested with plain text cells (using an popup editor)
//
//  Column
//  ------
//  Can have be fixed positions columns (must be left or right most columns)
//  Each column can have either text or site header (site header include site colour and description)
//  Columns have a min and max size in pixels
//
//  Cells
//  -----
//  Cells can be plain text, single line input textbox, or multi line input textbox (line count is configurable).
//  Currently input textboxs allow any data don't suppot masking
//  
//  It is possible to override default edit function of a cell (including plain text cells) 
//  by setting client side method GetCellInfo(0, 0).onClientBeginEdit = "cell_OnBeginEdit()";
//
//  It is also possible to override the default paste function for a cell GetCellInfo(0, 0).onClientPaste = "cell_OnPaste()";
//  
//  Possible to set both client and server side cell attributes using SetCellAttribute.
//  Read on client side using el_GetSelectedCell('editList').attr({attribute name})
//  Read on server side using GetCellAttribute(0, 0)
//
//  Ctrl+Shift+V
//  ------------
//  by settings EditList.SetAllowMultiCopy(2, 4) id the user presses Ctrl+Shift+V on a cell from columns 2 to 4
//  The value of the cell will be coppied to cells 2 to 4 in the row (if the cell has a onClientPaste method this will be called)
//
//  Resize
//  ------
//  When ever resize parent need to call client side method el_onResize
//
//  Usage:
//  In HTML
//  <%@ Register src="../pharmacysharedscripts/EditList/EditList.ascx" tagname="EditList" tagprefix="uc" %>
//  :
//  <link href="../../style/ScrollTableContainer.css"           rel="stylesheet" type="text/css" />
//  <link href="../pharmacysharedscripts/EditList/EditList.css" rel="stylesheet" type="text/css" />
//  :
//  <script type="text/javascript" src="../sharedscripts/lib/jquery-1.6.4.min.js"></script>
//  <script type="text/javascript" src="../pharmacysharedscripts/EditList/EditList.js"></script>
//  :
//  <body onresize="el_onResize('editList');">
//
//  On server code
//  editList.Clear();
//
//  editList.AddColumn("Code", 75, 75, true);
//  editList.AddColumn("Ascribe Value", 300, 350, false);
//
//  WLookup lookups = new WLookup();
//  lookups.LoadBySitesContextAndCountryCode(true, new [] { SessionInfo.SiteID }, WLookupContextType.Instruction, PharmacyCultureInfo.CountryCode);
//
//  foreach(var l in lookups)
//  {
//      editList.AddRow();
//      editList.SetCellAsText(l.Code, 0);
//      editList.SetCellAsTextInput(l.Value.Replace("\r\n", "<br />"), 0);
//  }
//
//  On save would then do
//  WLookup lookups = new WLookup();
//  lookups.LoadBySitesContextAndCountryCode(true, new [] { SessionInfo.SiteID }, WLookupContextType.Instruction, PharmacyCultureInfo.CountryCode);
//
//  for(int r = 0; r < editList.RowCount; r++)
//  {
//      string code = editList.GetCellValue(0, r);
//      string value= editList.GetCellValue(1, r);
//
//      var row = lookups.FindByCode(code);
//      row.Value = value;
//  }
//  lookups.Save();
//
//	Modification History:
//	23Apr14 XN  Written 88858
//==============================================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.shared;
using Newtonsoft.Json;

public partial class EditList : System.Web.UI.UserControl
{
    #region Data Types
    /// <summary>Column header type</summary>
    public enum ColumnHeaderType
    {
        /// <summary>Just plain text</summary>
        Text,

        /// <summary>Site colour, and name</summary>
        Site
    }

    /// <summary>Cell type</summary>
    public enum CellType
    {
        /// <summary>Plain text</summary>
        Text,
        
        /// <summary>Single line input box</summary>
        InputText,
        
        /// <summary>Multi line input box</summary>
        InputTextMultiLine,
    }

    /// <summary>Info about a column</summary>
    public class ColumnInfo
    {
        /// <summary>Header type</summary>
        public ColumnHeaderType type;

        /// <summary>It type = ColumnHeaderType.Text then text header</summary>
        public string text;

        /// <summary>It type = ColumnHeaderType.Site then site ID</summary>
        public int siteID;

        /// <summary>Min width of column in pixels</summary>
        public int minWidth;

        /// <summary>Max width of column in pixels</summary>
        public int maxWidth;

        /// <summary>If column is fixed position</summary>
        public bool fixedPosition;
    }

    /// <summary>Info about a cell</summary>
    public class CellInfo
    {
        /// <summary>Cell types</summary>
        public CellType type;

        /// <summary>Cell attributes (save on html attribues on page)</summary>
        public Dictionary<string,string> attributes;

        /// <summary>Original value set for the cell</summary>
        public string originalValue;

        /// <summary>If input box (multi lines) number or lines to display</summary>
        public int lineCount;

        /// <summary>Client side javascript method that overrides default edit method for cell</summary>
        public string onClientBeginEdit;

        public CellInfo()
        {
            lineCount = 1;
            attributes= new Dictionary<string,string>();
        }
    }
    #endregion

    #region Variables
    /// <summary>Info on columns in table</summary>
    protected List<ColumnInfo> columns = new List<ColumnInfo>();

    /// <summary>Info on cells in table</summary>
    protected List<List<CellInfo>> rows = new List<List<CellInfo>>();

    /// <summary>If table needs to be rebuilt in OnPreRender due to changed</summary>
    protected bool rebuildCtrls = false;
    #endregion

    #region Public Properties
    /// <summary>Number of columns</summary>
    public int ColumnCount { get { return columns.Count; } }

    /// <summary>List of columns</summary>
    public IEnumerable<ColumnInfo> Columns { get { return this.columns; } }

    /// <summary>Number of rows</summary>
    public int RowCount { get { return rows.Count;    } }
    #endregion

    #region Public Methods
    /// <summary>Add new column with text header</summary>
    /// <param name="text">Text header</param>
    /// <param name="minWidth">Min width in pixels</param>
    /// <param name="maxWidth">Max width in pixels</param>
    /// <param name="fixedPosition">If column position is fixed or scrollable</param>
    public void AddColumn(string text, int minWidth, int maxWidth, bool fixedPosition)
    {
        columns.Add(new ColumnInfo() {
                        type            = ColumnHeaderType.Text,
                        text            = text,
                        minWidth        = minWidth,
                        maxWidth        = maxWidth,
                        fixedPosition   = fixedPosition });
        rebuildCtrls = true;
    }

    /// <summary>Add new column with site header (has site colour and name)</summary>
    /// <param name="siteID">Site ID</param>
    /// <param name="minWidth">Min width in pixels</param>
    /// <param name="maxWidth">Max width in pixels</param>
    /// <param name="fixedPosition">If column position is fixed or scrollable</param>
    public void AddColumn(int siteID, int minWidth, int maxWidth, bool fixedPosition)
    {
        columns.Add(new ColumnInfo() {
                        type            = ColumnHeaderType.Site,
                        siteID          = siteID,
                        minWidth        = minWidth,
                        maxWidth        = maxWidth,
                        fixedPosition   = fixedPosition });
        rebuildCtrls = true;
    }

    /// <summary>Returns column info</summary>
    public ColumnInfo GetColumnInfo(int col)
    {
        if (col >= columns.Count)
            throw new ApplicationException("Invalid EditList column index " + col.ToString());

        return columns[col];
    }

    /// <summary>Add new row</summary>
    public void AddRow()
    {
        var cells = new List<CellInfo>(columns.Count);
        for(int c = 0; c < columns.Count; c++)
            cells.Add(null);

        rows.Add(cells);

        rebuildCtrls = true;
    }

    /// <summary>Gets the selected cell (or null if non selected)</summary>
    public CellInfo GetSelectedCell()
    {
        if (string.IsNullOrEmpty(hfSelectedCellID.Value))
            return null;

        int col = GetColumnPosFromID(hfSelectedCellID.Value);
        int row = GetRowPosFromID   (hfSelectedCellID.Value);
        if (col == -1 || row == -1)
            return null;

        return GetCellInfo(col, row);
    }

    /// <summary>Set cell as text cell</summary>
    /// <param name="text">Text to set</param>
    /// <param name="col">Column</param>
    /// <param name="row">Row (if null then latest row)</param>
    public void SetCellAsText(string text, int col, int? row = null)
    {
        row = row ?? rows.Count - 1;

        if (col >= columns.Count)
            throw new ApplicationException("Invalid EditList column index " + col.ToString());
        if (row >= rows.Count)
            throw new ApplicationException("Invalid EditList row index " + row.Value.ToString());

        rows[row.Value][col] = new CellInfo(){ type          = CellType.Text,
                                               originalValue = text};
        rebuildCtrls = true;
    }

    /// <summary>Set cell as single line input box</summary>
    /// <param name="originalValue">Original input box value</param>
    /// <param name="col">Column</param>
    /// <param name="row">Row (if null then latest row)</param>
    public void SetCellAsTextInput(string originalValue, int col, int? row = null)
    {
        row = row ?? rows.Count - 1;

        if (col >= columns.Count)
            throw new ApplicationException("Invalid EditList column index " + col.ToString());
        if (row >= rows.Count)
            throw new ApplicationException("Invalid EditList row index " + row.Value.ToString());

        rows[row.Value][col] = new CellInfo(){ type          = CellType.InputText,
                                               originalValue = originalValue,
                                               lineCount     = 1 };
        rebuildCtrls = true;
    }

    /// <summary>Set cell as multi line input box</summary>
    /// <param name="originalValue">Original input box value</param>
    /// <param name="col">Column</param>
    /// <param name="row">Row (if null then latest row)</param>
    public void SetCellAsTextInputLarge(string originalValue, int col, int? row = null)
    {
        row = row ?? rows.Count - 1;

        if (col >= columns.Count)
            throw new ApplicationException("Invalid EditList column index " + col.ToString());
        if (row >= rows.Count)
            throw new ApplicationException("Invalid EditList row index " + row.Value.ToString());

        rows[row.Value][col] = new CellInfo(){ type          = CellType.InputTextMultiLine,
                                               originalValue = originalValue,
                                               lineCount     = 3 };
        rebuildCtrls = true;
    }

    /// <summary>
    /// Gets latest value for the cell
    /// Does not work too well if class modified during postback (so might need to review)
    /// </summary>
    /// <param name="col">Column</param>
    /// <param name="row">Row</param>
    public string GetCellValue(int col, int row)
    {
        if (col >= columns.Count)
            throw new ApplicationException("Invalid EditList column index " + col.ToString());
        if (row >= rows.Count)
            throw new ApplicationException("Invalid EditList row index " + row.ToString());

        if (this.rebuildCtrls)
            return rows[row][col].originalValue;    // this looks incorrect but normaly called Clear the control will not exit (used by Pharmacy Reference data when doing add)
        else
        {
            // Get control value
            WebControl ctrl = tblEL.Rows[row + 1].Cells[col].Controls.Cast<WebControl>().FirstOrDefault();
            if (ctrl == null)
                return rows[row][col].originalValue;
            else if (ctrl is TextBox)
                return (ctrl as TextBox).Text;
            else
                throw new ApplicationException("Unsupported control type (" + ctrl.GetType().Name + ")");
        }
    }

    /// <summary>Set cell attribute (will stored on the client against the cell)</summary>
    /// <param name="name">Attribute name</param>
    /// <param name="value">Attribute value</param>
    /// <param name="col">Column</param>
    /// <param name="row">Row (if null then latest row)</param>
    public void SetCellAttribute(string name, string value, int col, int? row = null)
    {
        row = row ?? rows.Count - 1;

        if (col >= columns.Count)
            throw new ApplicationException("Invalid EditList column index " + col.ToString());
        if (row >= rows.Count)
            throw new ApplicationException("Invalid EditList row index " + row.Value.ToString());

        rows[row.Value][col].attributes.Add(name, value);
    }

    /// <summary>Get cell attribute</summary>
    /// <param name="name">Attribute name</param>
    /// <param name="col">Column</param>
    /// <param name="row">Row</param>
    public T GetCellAttribute<T>(string name, int col, int row)
    {
        string value;
        if (!GetCellInfo(col, row).attributes.TryGetValue(name, out value))
            throw new ApplicationException("Invalid EditList attribute name " + name);
        
        return ConvertExtensions.ChangeType<T>(value);
    }

    /// <summary>Get info for the cell</summary>
    public CellInfo GetCellInfo(int col, int row)
    {
        if (col >= columns.Count)
            throw new ApplicationException("Invalid EditList column index " + col.ToString());
        if (row >= rows.Count)
            throw new ApplicationException("Invalid EditList row index " + row.ToString());

        return rows[row][col];
    }

    /// <summary>Clear the table</summary>
    public void Clear()
    {
        columns.Clear();
        rows.Clear();

        TemplateControl.Controls.Remove(tblEL);
        tblEL.Rows.Clear();

        rebuildCtrls = true;
    }

    /// <summary>
    /// If user can use Ctrl+Shift+V to copy the data to all editable cells in the row (default disabled)
    /// If cell being pasted to supports onClientPaste then this will be called to perform the paste
    /// </summary>
    /// <param name="startColumn">Start column to allow copy Ctrl+Shift+V copy and paste</param>
    /// <param name="startColumn">End column to allow copy Ctrl+Shift+V copy and paste</param>
    public void SetAllowMultiCopy(int startColumn, int endColumn)
    { 
        hfAllowMultiCopyStartColumn.Value = startColumn.ToString();
        hfAllowMultiCopyEndColumn.Value   = endColumn.ToString();
    }
    #endregion

    #region Overridden Methods
    protected void Page_Load(object sender, EventArgs e)
    {
        if (this.IsPostBack)
            ScriptManager.RegisterStartupScript(this, this.GetType(), "InitEditList", string.Format("el_AfterPostBack('{0}');", this.ClientID), true);
    }

    /// <summary>Rebuild table if changed</summary>
    protected override void OnPreRender(EventArgs e)
    {
        if (rebuildCtrls)
            this.CreateCtrl();
        base.OnPreRender(e);
    }

    /// <summary>Registers class LoadControlState with page</summary>
    protected override void OnInit(EventArgs e)
    {
        base.OnInit(e);
        Page.RegisterRequiresControlState(this);
    }

    /// <summary>Reads class data from control state</summary>
    protected override void LoadControlState(object savedState)
    {
        Pair pair = savedState as Pair;
        Dictionary<string,string> controlState = JsonConvert.DeserializeObject<Dictionary<string,string>>(pair.First as string);

        columns = JsonConvert.DeserializeObject<List<ColumnInfo>>    (controlState["columns"] as string);
        rows    = JsonConvert.DeserializeObject<List<List<CellInfo>>>(controlState["rows"   ] as string);

        base.LoadViewState(pair.Second);

        this.CreateCtrl();
    }

    /// <summary>Saves class data to control state</summary>
    protected override object SaveControlState()
    {   
        Dictionary<string,string> controlState = new Dictionary<string,string>();
        controlState.Add("columns", JsonConvert.SerializeObject(columns ));
        controlState.Add("rows",    JsonConvert.SerializeObject(rows    ));
        
        return new Pair(JsonConvert.SerializeObject(controlState, Formatting.None), base.SaveControlState());
    }
    #endregion

    #region Protected methods
    /// <summary>Returns the column position of the cell or control id (else -1)</summary>
    protected int GetColumnPosFromID(string ID)
    {
        if (string.IsNullOrEmpty(ID))
            return -1;

        int col = -1;
        string[] split = ID.Split(new [] { '_' });
        string colStr = split.FirstOrDefault(s => s.StartsWith("x") && int.TryParse(s.SafeSubstring(1, s.Length), out col));

        return string.IsNullOrEmpty(colStr) ? -1 : col;
    }

    /// <summary>Returns the row position of the cell or control id (else -1)</summary>
    protected int GetRowPosFromID(string ID)
    {
        if (string.IsNullOrEmpty(ID))
            return -1;

        int row = -1;
        string[] split = ID.Split(new [] { '_' });
        string rowStr = split.FirstOrDefault(s => s.StartsWith("y") && int.TryParse(s.SafeSubstring(1, s.Length), out row));

        return string.IsNullOrEmpty(rowStr) ? -1 : row;
    }

    /// <summary>Builds the control</summary>
    protected void CreateCtrl()
    {
        CellInfo emptyCell = new CellInfo(){ type = CellType.Text, originalValue = "&nbsp;" };

        // clear all table data
        TemplateControl.Controls.Remove(tblEL);
        tblEL.Rows.Clear();

        tblEL.Attributes["onkeydown"] = string.Format("elTable_onkeydown('{0}');", this.ClientID); 
        tblEL.EnableViewState = false;

        // Create header row
        TableHeaderRow headerRow = new TableHeaderRow();
        headerRow.TableSection    = TableRowSection.TableHeader;
        headerRow.EnableViewState = false;
        tblEL.Rows.Add(headerRow);

        // Add columns headers
        foreach (ColumnInfo col in this.columns)
        {
            TableHeaderCell cell = new TableHeaderCell();
            cell.EnableViewState = false;

            switch (col.type)
            {
            case ColumnHeaderType.Text:
                cell.Text = col.text;
                break;
            case ColumnHeaderType.Site:
                cell.Text = "&nbsp;"; // Needs else thinks row is empty and so does not apply formatting

                // Site colour control
                SiteColourPanelControl colourControl = (this.LoadControl("../SiteColourPanelControl.ascx") as SiteColourPanelControl);
                colourControl.SiteID = col.siteID;
                cell.Controls.Add(colourControl);

                // Site name control
                SiteNamePanelControl siteNameControl = (this.LoadControl("../SiteNamePanelControl.ascx") as SiteNamePanelControl);
                siteNameControl.SiteID = col.siteID;
                siteNameControl.TextFormat = SiteNamePanelControl.TextFormatType.LocalHospitalName;
                cell.Controls.Add(siteNameControl);
                break;
            }

            cell.Attributes["minWidth"] = col.minWidth.ToString();
            cell.Attributes["maxWidth"] = col.maxWidth.ToString();
            if (col.fixedPosition)
                cell.CssClass = " fixedLeft";

            headerRow.Cells.Add(cell);
        }

        // Add rows
        for (int r = 0; r < this.rows.Count; r++)
        {
            var rowInfo = this.rows[r];
            TableRow row = new TableRow();
            row.TableSection    = TableRowSection.TableBody;
            row.EnableViewState = false;

            // add cells
            for (int c = 0; c < rowInfo.Count; c++)
            {
                var cellInfo = rowInfo[c] ?? emptyCell;
                TableCell  cell = new TableCell();
                WebControl webControl = null;

                // Create cell type
                switch (cellInfo.type)
                {
                case CellType.Text: 
                    cell.Text = cellInfo.originalValue;                     
                    break;

                case CellType.InputText:
                case CellType.InputTextMultiLine:
                    TextBox tb = new TextBox();
                    tb.Text = cellInfo.originalValue;
                    tb.BorderStyle = BorderStyle.None;
                    tb.TextMode    = (cellInfo.type == CellType.InputText) ? TextBoxMode.SingleLine : TextBoxMode.MultiLine;
                    tb.EnableViewState = false; // rely on postback data
                    tb.Width       = new Unit(99, UnitType.Percentage);
                    tb.Rows        = cellInfo.lineCount;
                    cell.Controls.Add(tb);
                    webControl = tb;
                    break;
                }

                // Set cell general attributes (event handlers)
                cell.ID = string.Format("ELCell_x{0}_y{1}", c, r);
                cell.EnableViewState = false;
                cell.Attributes.Add("onclick",    string.Format("elCell_onclick('{0}',$(this));",     this.ClientID));
                cell.Attributes.Add("ondblclick", string.Format("elCell_ondblclick('{0}',$(this));",  this.ClientID));
                if (columns[c].fixedPosition)
                    cell.CssClass = "fixedLeft";

                // Set user specific attributes 
                if (!string.IsNullOrEmpty(cellInfo.onClientBeginEdit))
                    cell.Attributes.Add("OnClientBeginEdit", cellInfo.onClientBeginEdit);
                foreach (var attr in cellInfo.attributes)
                    cell.Attributes.Add(attr.Key, attr.Value.XMLEscape());

                // Add control attributes
                if (webControl != null)
                {
                    webControl.ID = string.Format("ELCtrl_x{0}_y{1}", c, r);
                    webControl.Attributes.Add("onclick",    string.Format("elCell_onclick('{0}',$(this).parent());",    this.ClientID));
                    webControl.Attributes.Add("ondblclick", string.Format("elCell_ondblclick('{0}',$(this).parent());", this.ClientID));
                    webControl.Attributes.Add("readonly",   "readonly");
                }
            
                row.Cells.Add(cell);
            }
            tblEL.Rows.Add(row);
        }
    }
    #endregion
}