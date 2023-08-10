//===========================================================================
//
//					        PharmacyLookupList.aspx.cs
//
//  Provides quick method of providing a lookup list.
//
//  Form has 4 modes
//      None            - just display simple list upon load
//      TypeAndSelect   - User press a key and the selection moves to that row (use SearchColumns to indicate columns to search)
//      Basic           - Basic client side search (use SearchColumns to indicate columns to search)
//      PostBack        - User enters text to perform a search 
//                        (postback to server to return a list)
//                        In which case one of the sp parameters must be [searchText] (see example)
//
//  The form expects an sp name to be passed in which will return the results to be displayed. 
//  It also requires the names of the columns to display from the sp.
//  The SP is required to return at least 1 column called DBID which holds row ID (number or string)
//  When the user selects a row the form returns the DBID.
//  The parameters should be a CSV list or parameter name, and value separated by a :
//      e.g. Param=CurrentSessionID:423,LocationID_Site:19
//  if one of the parameter values needs to contain a , or a : then double escape the text
//      e.g. Params=CurrentSessionID:{0},LocationID_Site:{1},Context:'instruction.{2:000}',,'instruction.{2:000}.dss',SortBy:Code
//
//  Call the page with the follow parameters
//  SessionID           - ICW session ID
//  Title               - Title to display on the page
//  Info                - Info text to display on the top of the page
//  SearchType          - (optional) None, TypeAndSelect, Basic, or PostBack. Default None
//                        If just displaying a list or post back search.
//  SP                  - Name of the SP to run to return the lookup list
//  Params              - CSV list of parameters to pass to the sp          
//                        e.g. CurrentSessionID:123,ArbText:Test text,ArbTextGroupID:2
//                        (Note strings are not require to be in quotes)
//  Columns             - CSV list of columns names (from sp) to display
//                        with column widths (%) 
//                        e.g. ProductID,10,Description,90
//  selectedDBID        - DBID to select by default when form loads
//  ExtraLines          - Allows extra line to be added to the top of the list
//                        line must be csv list of column values (same number as columns + DB ID column)
//                              {DB ID},{column 1},{column 2},...  
//                        e.g. -1,<Add New Product>  
//  MinSearchChars      - Optional. Used for postback search, min number of characters 
//                        user must enter before they can perform a search, default 0
//  searchColumns       - Used for Basic and TypeAndSelect search mode csv list of columns to use for the search (replaced BasicSearchColumns) e.g. 0,1   3Mar15 XN 99381
//  searchText          - Text to start searching for when form loads only works with SearchType = TypeAndSelect 3Mar15 XN 99381
//  EmbeddedMode        - (optional) if page is embedded in another page (hides Ok/Cancel buttons)
//  Width               - (optional) width of the form in px (default 500)
//  Height              - (optional) width of the form in px (default 600)
//  BasicSearchColumns  - Obsolete use searchColumns now 3Mar15 XN 99381
//
//  Usage:
//  Display list of all WLookup FFLabel items (from sp pWLookupSelectByCriteriaForLookupList), showing columns Code, and Description (returned by sp), selects item with Code (DBID) 'DSW'
//  Has extra line at top of list '<None>'
//  PharmacyLookupList.aspx?SessionID=1234&SiteID=19&Title=Label Format&Info=Select Label Format&sp=pWLookupSelectByCriteriaForLookupList,Params=CurrentSessionID:1234,LocationID_Site:19,Context:'fflabels',SortBy:Code&Columns=Code,15,Description,85&selectedDBID=DSW&ExtraLines=,<None>
//
//  Displays forms with textbox where user has to enter min of 3 charactes to search for a TM (using sp pPRODUCT_MOIETIES_BY_NAME_NONXML2), showing only Description column
//  PharmacyLookupList.aspx?SessionID=1234&SiteID=19&Info=Enter Therapeutic Moiety for New product&SP=pPRODUCT_MOIETIES_BY_NAME_NONXML2,Params=CurrentSessionID:1234,searchText:[searchText]&Columns=Description,99&EmbeddedMode=true&SearchType=PostBack&MinSearchChars=3
//  
//	Modification History:
//  18Dec13	XN	78339 Created
//  2Jun14  XN  88987 PerformSearch added convertion of bool to Yes\No
//  25Jun14 XN  88506 Removed empty entries from Params 
//  27Aug14 XN  88922 Added Basic search mode, and moved search box from top to bottom left
//  14Oct14 XN  43318 Improved keyboard navigation, and form reopening when press enter in list.
//  3Mar15  XN  99381 Added SearchType.TypeAndSelect mode, and changed parameter 
//                    BasicSearchColumns to searchColumns also added searchText parameter
//===========================================================================
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

public partial class application_pharmacysharedscripts_PharmacyLookupList : System.Web.UI.Page
{
    #region Data Types
    protected enum SearchType
    {
        None,
        TypeAndSelect,  // 3Mar15 XN 99381
        Basic,          // 27Aug14 XN  88922
        PostBack
    };
    #endregion

    #region Protected Variables
    /// <summary>Title to display at top of screen (url parameter)</summary>
    protected string title;
    
    /// <summary>SP to run to display in the list (url parameter)</summary>
    protected string sp;

    /// <summary>CSV list of parameter to pass to the SP</summary>
    protected List<SqlParameter> parameters = new List<SqlParameter>();

    /// <summary>Cloumn info csv list of description, column width (url parameter)</summary>
    protected string columnInfo;

    /// <summary>DBID to selected by default</summary>
    protected string selectedDBID;

    /// <summary>CSV of extra lines to display at top of list</summary>
    protected string extraLines;

    /// <summary>Type of search to perfrom</summary>
    protected SearchType searchType;

    /// <summary>Min number of characters to enter in textbox before it allows postback search</summary>
    protected int minSearchChars;

    /// <summary>Columns to use when in basic, and TypeAndSelect search mode</summary>
    protected IEnumerable<int> searchColumns;
    //protected IEnumerable<int> basicSearchColumns;    3Mar15 XN 99381

    /// <summary>Text to start searching for when form loads only works with SearchType = TypeAndSelect 3Mar15 XN 99381</summary>
    protected string searchText;

    /// <summary>If embedded mode</summary>
    protected bool embeddedMode;

    /// <summary>Width and height of the form in px</summary>
    protected int width, height;
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSession(this.Request);

        title               = Request["Title"        ];
        lbInfo.Text         = Request["Info"         ];
        sp                  = Request["SP"           ];
        columnInfo          = Request["Columns"      ];
        selectedDBID        = Request["selectedDBID" ];
        extraLines          = Request["ExtraLines"   ];
        searchType          = (SearchType)Enum.Parse(typeof(SearchType), Request["SearchType"] ?? "None", true);
        minSearchChars      = int.Parse(Request["MinSearchChars"] ?? "0");
        searchText          = this.Request["SearchText"];
        //basicSearchColumns  = (Request["BasicSearchColumns"] ?? string.Empty).ParseCSV<int>(",", false);    // 27Aug14 XN  88922
        embeddedMode        = BoolExtensions.PharmacyParseOrNull(Request["EmbeddedMode"]) ?? false;
        width               = int.Parse(Request["Width"]  ?? "500");
        height              = int.Parse(Request["Height"] ?? "600");
        
        // Really just need to check SearchColumns, but for backward compatibility also check BasicSearchColumns 3Mar15 XN 99381
        if (this.Request["SearchColumns"] != null)
            this.searchColumns = this.Request["SearchColumns"].ParseCSV<int>(",", false);
        else if (this.Request["BasicSearchColumns"] != null)
            this.searchColumns = this.Request["BasicSearchColumns"].ParseCSV<int>(",", false);
        else 
            this.searchColumns = new int[0];

        // Extra parameters e.g. CurrentSessionID:454,Description:Some Text
        // : and , chars are double escaped
        //var paramList = (Request["Params"] ?? string.Empty).Replace(",,", "\0x01").Replace("::", "\0x02").Split(','); 25Jun14 XN 88506
        var paramList = (Request["Params"] ?? string.Empty).Replace(",,", "\0x01").Replace("::", "\0x02").Split(new [] { ',' }, StringSplitOptions.RemoveEmptyEntries);
        foreach(var p in paramList)
        {
            var nameValuePair = p.Split(':');    // Escape ::
            if (nameValuePair.Count() != 2)
                throw new ApplicationException("Params statement must consist of CSV list of parameters with name:value format e.g. CurrentSessionID:234,Description=Some Text Here,...\nError with parameter " + p + "\nNote that : and , are double escaped");
            for (int c = 0; c < nameValuePair.Count(); c++)
                nameValuePair[c] = nameValuePair[c].Replace("\0x02", ":").Replace("\0x01", ","); // Un Escape :: and ,,
            parameters.Add(new SqlParameter(nameValuePair[0], nameValuePair[1]));
        }

        divSearchText.Visible = (searchType == SearchType.PostBack || searchType == SearchType.Basic);
        btnSearch.Visible     = (searchType == SearchType.PostBack);
        hrButtons.Visible     = !embeddedMode;
        divButtons.Visible    = !embeddedMode;
        gcGrid.SortableColumns= (this.searchType != SearchType.PostBack);

        if (!this.IsPostBack)
        {
            if ((this.searchType == SearchType.Basic || this.searchType == SearchType.TypeAndSelect) && !searchColumns.Any())   // 27Aug14 XN  88922
                throw new ApplicationException("When SearchType=Basic or TypeAndSelect need to specify columns to use for each 'SearchColumns'");

            this.tbSearch.Attributes["onkeydown"] += "tbSearch_onkeydown(event)";
            this.tbSearch.Attributes["onkeyup"  ] += "tbSearch_onkeyup(event)";     // 27Aug14 XN  88922
            this.tbSearch.Attributes["onpaste"  ] += "tbSearch_onpaste(event)";     // 27Aug14 XN  88922
            this.tbSearch.Attributes["onclick"  ] += "$('#tbSearch')[0].select();";
        }

        AddColumns();

        // No postback search so perform search now
        if (this.searchType != SearchType.PostBack)
        {
            PerformSearch();
        }

        if (!this.IsPostBack)
        {
            // If searchText is specified then select that row first 3Mar15 XN 99381
            if (!string.IsNullOrEmpty(this.searchText) && this.searchText.All(c => Char.IsLetterOrDigit(c) || Char.IsPunctuation(c)))
            {
                ScriptManager.RegisterStartupScript(this, this.GetType(), "selectOnStart", string.Format("performGridSearch('{0}');", this.searchText.JavaStringEscape()), true);
            }
        }
    }

    /// <summary>
    /// Called when the search button is clicked.
    /// Searshed WProduct, and populates the grid, and panel
    /// </summary>
    protected void btnSearch_Click(object sender, EventArgs e)
    {
        if (tbSearch.Text.Length < this.minSearchChars)
            gcGrid.EmptyGridMessage = "Minimum number of characters is " + minSearchChars.ToString();
        else
            PerformSearch();
    }    

    /// <summary>Parses and adds columns </summary>
    private void AddColumns()
    {
        string[] columns = columnInfo.Split(',');
        for (int c = 0; c < columns.Count(); c += 2)
            gcGrid.AddColumn(columns[c], int.Parse(columns[c + 1]));
    }

    /// <summary>Calls the sp, and returns all the results in the grid</summary>
    private void PerformSearch()
    {
        // Replace tag strings
        if (searchType == SearchType.PostBack)
        {
            foreach (var param in parameters)
                param.Value = param.Value.ToString().Replace("[searchText]", tbSearch.Text);
        }

        // Add the extra line by default (passed in via url)
        if (!string.IsNullOrEmpty(extraLines))
        {
            string[] rowData = extraLines.Split(',');
            gcGrid.AddRow(rowData.Skip(1).ToArray());
            if (rowData[0].Length > 0 && rowData[0][0] == 65533)
                gcGrid.AddRowAttribute("DBID", "¡");    // Oddity with Warning and lookups where ¡ represents blank value (which does not come through on URL correctly) 28Oct14 XN Not really used anymore but kept in just incase
            else
                gcGrid.AddRowAttribute("DBID", rowData[0]);
        }

        // Load data
        GenericTable2 table = new GenericTable2();
        table.LoadBySP(sp, parameters);

        // Populate list
        int selectedIndex = 0;
        string[] columns = columnInfo.Split(',');
        foreach (var row in table)
        {
            gcGrid.AddRow();
            gcGrid.AddRowAttribute("DBID", row.RawRow["DBID"].ToString());
            for (int c = 0; c < columns.Count(); c += 2)
            {
                object val = row.RawRow[columns[c]];
                string str;
                if (val is Boolean)
                    str = ((bool)val).ToYesNoString();  // 2Jun14 XN 88987 added conversion of bool to Yes\No
                else
                    str = row.RawRow[columns[c]].ToString();

                gcGrid.SetCell(c / 2, str);
            }

            if (row.RawRow["DBID"].ToString().EqualsNoCase(selectedDBID))
                selectedIndex = gcGrid.RowCount - 1;
        }

        if (table.Count == 0)
            gcGrid.EmptyGridMessage = "No items available";

        // Select default row in grid
        // string script = string.Format("selectRow('gcGrid', {0}, true); gcGrid.focus();", selectedIndex); 86716 XN 19Mar14 scritp error ie8 if control not visisble
        string script = "try{ selectRow('gcGrid', " + selectedIndex.ToString() + ", true); clearError(); $('#gcGrid').focus(); } catch(ex) { }";
        ScriptManager.RegisterStartupScript(this, this.GetType(), "select", script, true);
    }
}
