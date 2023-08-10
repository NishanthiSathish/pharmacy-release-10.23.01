// -----------------------------------------------------------------------
// <copyright file="FileImport.aspx.cs" company="Emis Health">
//      Copyright Emis Health Plc  
// </copyright>
// <summary>
// Modal page that allows the user to select a CSV file to import.
// The form is linked to the WCsvImportExport table (see WCsvImportExport.cs for more details)
// When the data is uploaded it is save temporally to App_Data/CsvImportExportTemp
//
// URL Parameters are
// SessionID - ICW session ID
// DataType  - Row in where value is same as WCsvImportExport.DataTypeName
//
// Modification History:
// 29Nov16 XN  Created 147104
// 09Mar17 XN  Improved errors 179332
// </summary>
// -----------------------------------------------------------------------
using System;
using System.IO;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_CsvImportExport_FileImport : System.Web.UI.Page
{
    #region Member variables
    /// <summary>Data type to import</summary>
    private string dataType;
    #endregion

    #region Event Handlers
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSession(this.Request);
        this.dataType = this.Request["DataType"];

        if (!this.IsPostBack)
        {
            this.lbFileType.Text        = this.dataType;
            this.cbIfHasHeaders.Checked = WCsvImportExport.GetDataTypeName(dataType).IfHeaderRowExport;
        }
    }

    /// <summary>
    /// Called when the import button is clicked 
    /// Validates and imports the data
    /// </summary>
    protected void btnImport_OnClick(object sender, EventArgs e)
    {
        if (fuFileUpload.HasFile && !string.IsNullOrWhiteSpace(fuFileUpload.FileName))
        {
            // Load the importer
            WCsvImportExport importer = new WCsvImportExport();
            importer.LoadByDataTypeName(this.dataType);

            // Save file to server (seems to work better like this)
            var filepath = Server.MapPath("~/App_Data/CsvImportExportTemp/") + SessionInfo.SessionID.ToString() + " " + fuFileUpload.FileName;
            try
            {
                fuFileUpload.SaveAs(filepath);

                // Validate and save data
                if (this.Validate(importer, filepath))
                {
                    if (this.Save(importer, filepath))
                        this.ClosePage("true");
                }
            }
            catch (Exception ex)
            {
                string script = string.Format("alertEnh('Failed to upload file error: {0}', undefined, '475px')", ex.Message.JavaStringEscape("'"));
                ScriptManager.RegisterStartupScript(this, this.GetType(), "error", script, true);
            }
            finally
            {
                // And delete the saved file at the end
                if (File.Exists(filepath))
                    File.Delete(filepath);
            }
        }
        else
        {
            errorMessage.InnerHtml = "Please select file to upload";
        }
    }
    #endregion

    #region Private Methods
    /// <summary>Validates the page data</summary>
    /// <returns>If valid</returns>
    private bool Validate(WCsvImportExport importer, string filePath)
    {
        bool ok = true;
        ErrorWarningList errors = new ErrorWarningList();

        if (!importer.Any())
        {
            errors.AddError("Invalid data type " + this.dataType + " (does not exist in table WCsvImportExport)");
            ok = false;
        }
        else if (!importer[0].ValidateCsv(cbIfHasHeaders.Checked, filePath, errors))
            ok = false;

        if (errors.Any())
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ValidationErrors", string.Format("alertEnh(\"<div style='max-height:80px'>Data was not saved due to following errors<br />{0}</div>\", undefined, '475px');", errors.ToHtml()), true);

        return ok;
    }

    /// <summary>Save the data to the DB</summary>
    /// <param name="importer">Importer to use</param>
    /// <param name="filePath">Data to import</param>
    private bool Save(WCsvImportExport importer, string filePath)
    {
        var errors = importer[0].ParseFromCsv(cbIfHasHeaders.Checked, filePath);
        if (errors.Any())
            ScriptManager.RegisterStartupScript(this, this.GetType(), "SavingErrors", string.Format("alertEnh(\"<div style='max-height:80px'>Data was not saved due to following errors<br />{0}</div>\", undefined, '475px');", errors.ToHtml()), true);
        
        return !errors.Any();
    }
    #endregion
}