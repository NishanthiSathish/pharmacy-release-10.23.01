//===========================================================================
//
//							      PharmacyLabelPanelControl.cs
//
//  Provides a basic reusable label control, this will display label and value
//  pairs in a number of columns, simliar to the entity panel
//
//  The control support view state (but it is disabled by default)
//  
//  To be able to use the control you will need to include the LabelPanelControl.css,  
//  PharmacyLabelPanelControl.js, and jquery-1.6.4.min.js, files in your html page.
//
//  It is possible to update the panel javaside, by sepcifiying a label name and then calling the
//  java side functions setPanelLabel, or clearLabels
//
//  Configurable Columns
//  --------------------
//  It is possible to configure the panel layout, by using table QSDisplayItem, QSField, QSPanel, and accessor class.
//  Then use following methods to setup the panel
//      QSLoadConfiguration - Loads in the data from QSDisplayItem.
//      AddColumnsQS        - Creates the grid columns from the QSDisplayItem data
//      AddRowQS            - Adds a new row to the grid using the accessor class, and QSDisplayItem data
//      AddRowAttributesQS  - normaly used where panel a configurable panel is linked to a grid 
//                            (so panel values are stored as row attributes)
//  Usage:
//  Create a static label panel
//  var accessors = new IQSDisplayAccessor[] { new WProductQSProcessor() };        
//  pnlLabelPanel.QSLoadConfiguration(SessionInfo.SiteID, "StoresDrugInfo", "Supplier Product Info");
//  pnlLabelPanel.SetColumnsQS();
//  pnlLabelPanel.AddLabelsQS(new BaseRow[] { product }, accessors);
//
//
//  Usage:
//  in your html add
//  <%@ Register src="pharmacysharedscripts/PharmacyLabelPanelControl.ascx" tagname="LabelPanelControl" tagprefix="uc1" %>
//  :
//  <link href="../../style/LabelPanelControl.cs"  rel="stylesheet" type="text/css" />
//  :
//  <uc1:LabelPanelControl ID="pnlLabelPanel" runat="server" />
//
//  The in your page load code 
//  pnlLabelPanel.SetColumns(2);
//
//  pnlLabelPanel.SetColumnWidth(0, 50);
//  pnlLabelPanel.AddLabel (0, "Username 1:", "Fred");
//  pnlLabelPanel.AddLabel (0, "User age 1:", 38.ToString());
//
//  pnlLabelPanel.SetColumnWidth(1, 50);
//  pnlLabelPanel.AddLabel (1, "Username 1:", "Fred");
//  pnlLabelPanel.AddLabel (1, "User age 1:", 38.ToString());
//
//	Modification History:
//	22Jul09 XN  Written
//  08Apr10 XN  F0083101 Tradename is too long
//  22Mar11 XN  Added names to labels, and Java side functions to then populate
//              the labels by name
//  19Feb12 XN  Added xmlEscape option, and GetLabel method
//  08Jul14 XN  Added view state (off by default)
//  08Set14 XN  Replaced configurable SetCell, and AddRow, with new QueslScrol methods 
//              QSLoadConfiguration, AddColumnsQS, AddRowQS, and AddRowAttributesQS 98658
//  02Oct14 XN  Added GetLabelByQSPropertyName 98658
//  16Jan14 XN  Added new AddNamedLabel as QS added labels should not be xml escaped 108628
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.quesscrllayer;
using ascribe.pharmacy.shared;

public partial class PharmacyLabelPanelControl : System.Web.UI.UserControl
{
    private const int RowHeightInPixels = 21;
    private const int HeightPadding     =  3;

    /// <summary>
    /// Used for when defining configurable column layouts (returned by ParseColumnSetup)
    /// 05Jul13 XN  27252
    /// </summary>
    public class LayoutHelperItem
    {
        public string Name             = string.Empty;
        public string FieldName        = string.Empty;
        public string FieldFormatString= string.Empty;
    }

    public class LayoutHelperColumn
    {
        public int? Width = null;
        public List<LayoutHelperItem> Items = new List<LayoutHelperItem>();
    }

    /// <summary>Label value pair</summary>
    [Serializable]
    public class LabelValueInfo
    {
        public string name;
        public string label;
        public string value;
        public bool   xmlEscape;

        public LabelValueInfo(string name, string label, string value, bool xmlEscape)
        {
            this.name       = name;
            this.label      = label;
            this.value      = value;
            this.xmlEscape  = xmlEscape;
        }
    }

    /// <summary>QuesScrl allow configuration</summary>
    public bool QSAllowConfiguration { get; set; }

    /// <summary>List of QuesScrl panels</summary>
    public QSPanel QSPanel { get; private set; }

    /// <summary>List of QuesScrl display items used to create the grid (initalised by QSLoad)</summary>
    public QSDisplayItem QSDisplayItems { get; private set; }

    protected List<List<LabelValueInfo>> table = new List<List<LabelValueInfo>>();
    protected List<int> columnWidths = new List<int>();
    protected Dictionary<string,string> valueStyles = new Dictionary<string,string>();

    protected void Page_Load(object sender, EventArgs e)
    {
        // if view state enabled, and no data set then load control data from ViewState
        if (this.EnableViewState && !table.Any())
        {
            table = ViewState["table"] as List<List<LabelValueInfo>>;
            if (table == null)
                table = new List<List<LabelValueInfo>>();

            columnWidths = ViewState["columnWidths"] as List<int>;
            if (columnWidths == null)
                columnWidths = new List<int>();

            valueStyles = ViewState["valueStyles"] as Dictionary<string,string>;
            if (valueStyles == null)
                valueStyles = new Dictionary<string,string>();
        }
    }

    protected void Page_PreRender(object sender, EventArgs e)
    {
        // Save control data tow ViewState
        if (this.EnableViewState)
        {
            ViewState["table"       ] = table;
            ViewState["columnWidths"] = columnWidths;
            ViewState["valueStyles" ] = valueStyles;
        }
    }

    /// <summary>
    /// Sets number of columns the panel will have
    /// </summary>
    /// <param name="columns">Number of columnes</param>
    public void SetColumns(int columns)
    { 
        table.Clear();

        for (int c = 0; c < columns; c++)
        {
            table.Add(new List<LabelValueInfo>());
            columnWidths.Add(100 / columns);
        }
    }

    /// <summary>
    /// Set the column width
    /// </summary>
    /// <param name="column">Column index</param>
    /// <param name="width">Column width as percentage</param>
    public void SetColumnWidth(int column, int width)
    {
        columnWidths[column] = width;
    }

    /// <summary>Returns the number of lables in a column</summary>
    /// <param name="column">Column Index</param>
    /// <returns>Number of labels in the column</returns>
    public int GetLabelCount(int column)
    {
        return table[column].Count;
    }

    /// <summary>
    /// Adds a label value pair
    /// </summary>
    /// <param name="column">Index of column the label is to appear in</param>
    /// <param name="label">Label</param>
    /// <param name="value">Value string (can be a format string for the args)</param>
    /// <param name="args">agrs for when value is a format string</param>
    public void AddLabel ( int column, string label, string value, params object[] args )
    {
        string formattedValue = string.IsNullOrEmpty(value) ? string.Empty : string.Format(value, args);
        table[column].Add( new LabelValueInfo(string.Empty, label, formattedValue, true ) );
    }

    /// <summary>
    /// Adds a label value pair
    /// 108628 XN 16Jan14 added to QS items are not XML escaped
    /// </summary>
    /// <param name="column">Index of column the label is to appear in</param>
    /// <param name="label">Label</param>
    /// <param name="xmlEscape">If to xml escape the field</param>
    /// <param name="value">Value string (can be a format string for the args)</param>
    /// <param name="args">agrs for when value is a format string</param>
    public void AddLabel ( int column, string label, bool xmlEscape, string value, params object[] args )
    {
        string formattedValue = string.IsNullOrEmpty(value) ? string.Empty : string.Format(value, args);
        table[column].Add( new LabelValueInfo(string.Empty, label, formattedValue, xmlEscape ) );
    }

    /// <summary>
    /// Adds a label value pair, that is given a name so can use with javascript method setPanelLabel
    /// </summary>
    /// <param name="column">Index of column the label is to appear in</param>
    /// <param name="name">name to give the label</param>
    /// <param name="label">Label</param>
    /// <param name="value">Value string (can be a format string for the args)</param>
    /// <param name="args">agrs for when value is a format string</param>
    public void AddNamedLabel ( int column, string name, string label, string value, params object[] args )
    {
        string formattedValue = string.IsNullOrEmpty(value) ? string.Empty : string.Format(value, args);
        table[column].Add( new LabelValueInfo(name, label, formattedValue, true ) );
    }

    /// <summary>
    /// Adds a label value pair, that is given a name so can use with javascript method setPanelLabel
    /// 108628 XN 16Jan14 added to QS items are not XML escaped
    /// </summary>
    /// <param name="column">Index of column the label is to appear in</param>
    /// <param name="name">name to give the label</param>
    /// <param name="label">Label</param>
    /// <param name="xmlEscape">If to xml escape the field</param>
    /// <param name="value">Value string (can be a format string for the args)</param>
    /// <param name="args">agrs for when value is a format string</param>
    public void AddNamedLabel ( int column, string name, string label, bool xmlEscape, string value, params object[] args )
    {
        string formattedValue = string.IsNullOrEmpty(value) ? string.Empty : string.Format(value, args);
        table[column].Add( new LabelValueInfo(name, label, formattedValue, xmlEscape ) );
    }

    /// <summary>Get full info about a label</summary>
    /// <param name="column">Column index</param>
    /// <param name="row">Row index</param>
    public LabelValueInfo GetLabel(int column, int row)
    {
        return table[column][row];
    }

    /// <summary>Get full info about a label from a QS property name (panel must be filled using QSLoadConfiguration, and AddLabelsQS) 02Oct14 XN 98658</summary>
    /// <param name="propertyName">Name of the property</param>
    public LabelValueInfo GetLabelByQSPropertyName(string propertyName)
    {
        LabelValueInfo label = null;
        var qsDataItems = this.QSDisplayItems.OrderBy(p => p.DisplayIndex).ToList();
        var labelRow    = qsDataItems.FindIndex( i => i.PropertyName.EqualsNoCase(propertyName) );
        if (labelRow != -1)
        {
            int labelPanel = this.QSPanel.OrderBy(p => p.PanelIndex).ToList().FindIndex( p => p.QSPanelID == qsDataItems[labelRow].QSPanelID );
            label = table[labelPanel][labelRow];    // XN think [labelRow] is wrong as assume only 1 panel but in regression so don't want to change
        }
        return label;
    }

    /// <summary>
    /// The the style of the value field of a label 
    /// e.g. SetValueStyles(0, 7, "font-size:small");
    /// </summary>
    /// <param name="column">Column index</param>
    /// <param name="row">Row index</param>
    /// <param name="styles">Syles</param>
    public void SetValueStyles(int column, int row, string styles)
    {
        string key = string.Format("{0}:{1}", column, row);
        valueStyles[key] = styles;
    }

    /// <summary>
    /// Converts a string that defines the configurable headers, to a structure the grid control can use
    /// See text at top of file for details
    /// </summary>
    [Obsolete("Use QuesScroll methods instead")]
    public static List<LayoutHelperColumn> ParseColumnSetup(string columnSetup)
    {
        List<LayoutHelperColumn> layout = new List<LayoutHelperColumn>();

        foreach(var column in columnSetup.Split(new [] { '¤' }))
        {
            LayoutHelperColumn layoutInfo = new LayoutHelperColumn();
            
            string widthStr = column.Split(new [] { ',' }, 1)[0];
            int width;
            if (int.TryParse(widthStr, out width))
                layoutInfo.Width = width;

            foreach (string col in column.Split(new [] { ',' }).Skip(1))
            {
                LayoutHelperItem newItem = new LayoutHelperItem();
                string[]    field     = col.Split(new [] { '|' });
                int fieldCount = field.Length;

                if (fieldCount > 0)
                    newItem.Name = field[0].Trim();
                if (fieldCount > 1)
                    newItem.FieldName = field[1].Trim();
                if (fieldCount > 2)
                    newItem.FieldFormatString = field[2].Trim();

                layoutInfo.Items.Add(newItem);
            }

            layout.Add(layoutInfo);
        }

        return layout;
    }

    #region QuesScrl Methods
    /// <summary>Load in the configuration data from QSDisplayItem, and QSPanel table XN 8Sep14 98658</summary>
    public void QSLoadConfiguration(int siteID, string category, string section)
    {
        this.QSPanel = new QSPanel();
        this.QSPanel.LoadBySiteIDCategorySection(siteID, category, section);

        this.QSDisplayItems = new QSDisplayItem();
        this.QSDisplayItems.LoadBySiteIDCategorySection(siteID, category, section);

        hfConfigurationFormParams.Value = string.Format("?SessionID={0}&SiteID={1}&Accessors={2}&Category={3}&Section={4}", 
                                                            SessionInfo.SessionID, 
                                                            siteID, 
                                                            this.QSDisplayItems.Select(s => s.AccessorTag).Distinct().ToCSVString(","),
                                                            category,
                                                            section );

        if (!this.QSPanel.Any() && !this.QSDisplayItems.Any())
            Response.Redirect("..\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=" + string.Format("No QuesScrol panel data for<br />Site ID:{0}<br />Category:{1}<br />Section:{2}", siteID, category, section));
    }

    /// <summary>Adds a panel (column) from settings load in QSLoadConfiguration XN 8Sep14 98658</summary>
    public void SetColumnsQS()
    {
        this.SetColumns(this.QSPanel.Count);
        for (int c = 0; c < this.QSPanel.Count; c++)
            this.SetColumnWidth(c, this.QSPanel[c].WidthAsPercentage);
    }

    /// <summary>Adds a label value pair poupated by QuesScrol display items load using LoadConfigurationQS XN 8Sep14 98658</summary>
    /// <param name="rowData">List of rows to read by the accessors</param>
    /// <param name="accessors">List of accessors referenced by the display items</param>
    public void AddLabelsQS(IEnumerable<BaseRow> rowData, IEnumerable<IQSDisplayAccessor> accessors)
    {
        // Create map of which accessor is to handle which data row (error any accessor does not have a data row)
        Dictionary<IQSDisplayAccessor, BaseRow> accessorToData = accessors.ToDictionary(a => a, a => a.FindFirstCompatibleRow(rowData));
        if (accessorToData.Any(a => a.Value == null))
        {
            var accessor = accessorToData.First(a => a.Value == null).Key;
            throw new ApplicationException(string.Format("No BaseRow passed in for accessor '{0}' support data type {1}", accessor.AccessorTag, accessor.SupportedType.FullName));
        }

        // Populate each panel
        for(int p = 0; p < this.QSPanel.Count; p++)
        {
            var panel = this.QSPanel[p];

            // Populate labels for the panel
            foreach ( QSDisplayItemRow i in this.QSDisplayItems.Where(i => i.QSPanelID.Value == panel.QSPanelID).OrderBy(i => i.DisplayIndex) )
            {
                // Get the accessor
                IQSDisplayAccessor accessor = accessors.FindByTag(i.AccessorTag);
                if (accessor == null)
                    throw new ApplicationException(string.Format("'{0}' accessor was not supplied", accessor.AccessorTag));

                // Get the appropriate row data
                BaseRow row = accessorToData[accessor];

                // Set cell
                string text = accessor.GetValueForDisplay(row, i.DataIndex, i.DataType, i.PropertyName, i.FormatOption);
                this.AddLabel(p, i.Description, false, text);
            }
        }
    }

    /// <summary>
    /// Adds a named value pair label for each item loaded in QSLoadConfiguration
    /// Each label is give a name="QSItem{QSDisplayItemID}" so it can be used with javascript method setPanelLabel
    /// The label value will be given and empty string
    /// XN 8Sep14 98658
    /// </summary>
    public void AddNamedLabelsQS()
    {
        for(int p = 0; p < this.QSPanel.Count; p++)
        {
            var panel = this.QSPanel[p];
            foreach ( QSDisplayItemRow item in this.QSDisplayItems.Where(i => i.QSPanelID.Value == panel.QSPanelID).OrderBy(i => i.DisplayIndex) )
            {
                string key = string.Format("QSItem{0}", item.QSDisplayItemID);
                this.AddNamedLabel(p, key, item.Description, false, string.Empty, true);
            }
        }
    }
    
    /// <summary>Returns the calcualted height in pixels (from QSPanel.HeightInRows)</summary>
    public int CalculatedHeightInPixelsQS()
    {
        return (this.QSPanel.First().HeightInRows * RowHeightInPixels) + HeightPadding;
    }
    #endregion
}
