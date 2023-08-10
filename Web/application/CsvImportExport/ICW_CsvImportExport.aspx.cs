// -----------------------------------------------------------------------
// <copyright file="FileImport.aspx.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// ICW page that allows the user to import and export data to the DB
// The form is linked to the WCsvImportExport table (see WCsvImportExport.cs for more details)
// The page has two button 
//      Import - Displays a form to allow the user to select import info
//      Export - Save data to disk
//
// URL Parameters are
// SessionID  - ICW session ID
// DataType   - Row in where value is same as WCsvImportExport.DataTypeName
// AllowExport- If export button is displayed
// AllowImport- If import button is displayed
//
// Modification History:
// 29Nov16 XN  Created 147104
// </summary>
// -----------------------------------------------------------------------
using System;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_CsvImportExport_ICW_CsvImportExport : System.Web.UI.Page
{
    #region Member variables
    /// <summary>Import export table</summary>
    private WCsvImportExport importExport = new WCsvImportExport();
    
    /// <summary>Data type to import</summary>
    protected string dataType;
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSession(this.Request);

        // Check data type exists
        dataType = this.Request["DataType"];
        if (string.IsNullOrEmpty(dataType))
            this.Response.Redirect("~\\application\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=Desktop parameter DataType not set.");

        importExport.LoadByDataTypeName(dataType);
        if (!importExport.Any())
            this.Response.Redirect("~\\application\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=DataType '" + dataType + "' (desktop parameter) does not exist in data table WCsvImportExport.");

        // Display buttons
        if (!this.IsPostBack)
        {
            btnExport.Enabled = BoolExtensions.PharmacyParseOrNull(this.Request["AllowExport"]) ?? true;
            btnImport.Enabled = BoolExtensions.PharmacyParseOrNull(this.Request["AllowImport"]) ?? true;
        }
    }

    /// <summary>
    /// Called when export button is clicked
    /// Exports the data to the CSV file
    /// </summary>
    /// <param name="sender"></param>
    /// <param name="e"></param>
    protected void btnExport_OnClick(object sender, EventArgs e)
    {
        hfData.Value = importExport[0].ConvertToCsv();

        string script = string.Format("setTimeout(function() {{ document.frames['fraSaveAs'].SetSaveAsData('{0}', $('#hfData').val()); $('#hfData').val(''); }}, 500);", this.importExport[0].GetDefaultFilename());
        ScriptManager.RegisterStartupScript(this, this.GetType(), "export",  script, true);
    }
}