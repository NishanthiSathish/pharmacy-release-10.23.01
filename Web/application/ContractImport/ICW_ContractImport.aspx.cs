// --------------------------------------------------------------------------------------------------------------------
// <copyright file="ICW_ContractImport.aspx.cs" company="Ascribe Ltd">
//   Copyright Ascribe Ltd.
// </copyright>
// <summary>
// Modification History:
// 08Jun15 XN  119361 Moved settings SitesAllowedForReplciation and SiteNumbersSelectedByDefault to 
//             desktop parameters ReplicateToSiteNumbers
//             DetermineIfSiteValidForReplication moved from ContractEditorSettings to ContractProcessor
// 24Sep15 XN  Updated Page_Load as moved alias methods from SiteProductData to BaseTable2 77778
// 06Apr18 DR  Bug 205805 - CMU contract editor - The Tradename field is not shown if try and edit details more than once
// </summary>
// --------------------------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.Services;
using System.Web.UI;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using CsvService;
using Telerik.Web.UI;

public partial class application_ContractImport_ICW_ContractImport : System.Web.UI.Page
{
    CMUContract contract;

    /// <summary>List of sites that are allowed for replication 08Jun15 XN 119361</summary>
    private List<int> replicateToSiteNumbers;

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        // Read parameters   08Jun15 XN 119361
        this.replicateToSiteNumbers = Site2.Instance().FindBySiteNumber(this.Request["ReplicateToSiteNumbers"], true, CurrentSiteHandling.AtStart).Select(s => s.SiteNumber).ToList();

        if (!IsPostBack)
        {
            // Check user licence is setup
            if (!ContractEditorSettings.ContractEditor.ContractImport)
            {
                Response.Redirect("..\\pharmacysharedscripts\\DesktopError.aspx?ErrorMessage=Your current licence does not include this module.<br />Please contact Support or your Account Manager.");
                return;
            }

            tblMain.Visible       = false;
            rowGrid.Visible       = false;
            tableSiteInfo.Visible = false;
        }

        // Deal with __postBack events
        string   args      = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        if (argParams.Length > 0)
        {
            switch (argParams[0])
            {
            case "LinkProductToNPCCOde":    
                {
                int     siteProductDataID = int.Parse(argParams[1]);
                string  NPCCode           = (RadGrid1.SelectedItems[0] as GridDataItem)["NPCCode"].Text;
                //SiteProductData.RemoveAlias("NPCCode", NPCCode);                              24Sep15 XN  Moved alias methods from SiteProductData to BaseTable2 77778
                //SiteProductData.RemoveAllAliasByAliasGroup(siteProductDataID, "NPCCode");
                //SiteProductData.AddAlias(siteProductDataID, "NPCCode", NPCCode, true);
                SiteProductData siteProductData = new SiteProductData();
                siteProductData.RemoveAlias("NPCCode", NPCCode);
                siteProductData.RemoveAllAliasByAliasGroup(siteProductDataID, "NPCCode");
                siteProductData.AddAlias(siteProductDataID, "NPCCode", NPCCode, true);
                ClearProfiles();
                LoadData(null);
                }
                break;

            case "DeleteLink":
                {
                int     siteProductDataID = int.Parse(argParams[1]);
                string  NPCCode           = (RadGrid1.SelectedItems[0] as GridDataItem)["NPCCode"].Text;
                //SiteProductData.RemoveAlias("NPCCode", NPCCode);                              24Sep15 XN  Moved alias methods from SiteProductData to BaseTable2 77778
                //SiteProductData.RemoveAllAliasByAliasGroup(siteProductDataID, "NPCCode");
                SiteProductData siteProductData = new SiteProductData();
                siteProductData.RemoveAlias("NPCCode", NPCCode);
                siteProductData.RemoveAllAliasByAliasGroup(siteProductDataID, "NPCCode");
                ClearProfiles();
                LoadData(null);
                }
                break;

            case "NewSupplier":
                {
                int wsupplierProfileID = int.Parse(argParams[1]);
                ClearProfiles();
                LoadData(wsupplierProfileID);
                }
                break;

            case "DeleteSupplierProfile":
                {
                int wsupplierProfileID = int.Parse(hdnSupplierProfileID.Value);
                
                WSupplierProfile profile = new WSupplierProfile();                    
                profile.LoadByWSupplierProfileID(wsupplierProfileID);

                var validSites   = ContractProcessor.DetermineIfSiteValidForReplication(this.replicateToSiteNumbers, profile[0].NSVCode, profile[0].SupplierCode, false, true); 
                var validSiteIDs = validSites.Where(s => s.validState == ContractProcessor.SiteValid.Yes).Select(s => s.siteID).ToList();
                    
                profile.LoadBySupplierAndNSVCode(profile[0].SupplierCode, profile[0].NSVCode);
                profile.RemoveAll(p => validSiteIDs.Contains(p.SiteID));
                profile.Save();
                
                this.ClearProfiles();
                this.LoadData(null);                
                }
                break;
            }
        }
    }

    protected void RadAsyncUpload1_FileUploaded(object sender, Telerik.Web.UI.FileUploadedEventArgs e)
    {
        CsvService.CsvFileReader reader = new CsvService.CsvFileReader(e.File.InputStream);
        CMUContractColumnInfo columnInfo = CMUContract.GetColumnInfo();
        CMUContract contract = new CMUContract();
        CsvRow row = new CsvRow();
        int lineCount = 0;

        try
        {
            while (reader.ReadRow(row))
            {
                CMUContractRow line = contract.Add();
                line.BrandName          = ParseField(row[36], columnInfo.BrandNameLength);
                line.ContractCode       = ParseField(row[13], null);
                line.DeliveryInformation= ParseField(row[29], columnInfo.DeliveryInformationLength);
                line.DistributorCodes   = ParseField(row[23], columnInfo.DistributorCodesLength   );
                line.RecordStatusEndDate= string.IsNullOrEmpty(row[15]) ? (DateTime?)null : Convert.ToDateTime(row[15]);
                line.FreeText           = ParseField(row[32], columnInfo.FreeTextLength);
                line.FreeText2          = ParseField(row[33], columnInfo.FreeText2Length);
                line.GenericDescription = ParseField(row[2],  columnInfo.GenericDescriptionLength);
                line.LeadTime           = ParseField(row[30], columnInfo.LeadTimeLength);
                line.MinTotalOrderValue = ParseField(row[27], columnInfo.MinTotalOrderValueLength);
                line.MinOrderQuantity   = ParseField(row[9],  columnInfo.MinOrderQuantityLength);
                line.NPCCode            = ParseField(row[16], null);
                line.PackSize           = ParseField(row[3],  columnInfo.PackSizeLength);
                line.PriceInPounds      = string.IsNullOrEmpty(row[4]) ? (decimal?)null : Convert.ToDecimal(row[4]);
                line.SessionID          = SessionInfo.SessionID;
                line.RecordStatusStartDate= string.IsNullOrEmpty(row[14]) ? (DateTime?)null : Convert.ToDateTime(row[14]);
                line.SupplierCode       = ParseField(row[6], null);
                line.DirectFlag         = row[18] == "D" ? true : false;
                line.eOrdering          = row[38] == "1" ? true : false;
                line.eInvoicing         = row[39] == "1" ? true : false;
                line.GTIN               = ParseField(row[12], null);
                line.OFlag              = row[22] == "O" ? true : false;

                lineCount++;
            }
        }
        catch (Exception ex)
        {
            string script = string.Format("alertEnh('File format is not valid<br />Error at line {0}<br /><br />{1}')", lineCount, ex.Message.Replace("\r\n", "<br />").Replace("'", "&apos;"));
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "FileReaderError", script, true);
            e.IsValid = false;
            return;
        }

        CMUContract.DeleteByCurrentSessionID();
        contract.SaveUsingBulkInsert();

        hdnLoaded.Value = "1";
        rowGrid.Visible = true;
        RadGrid1.Rebind();
        tblUploadFile.Visible = false;
        siteInfoText.InnerHtml = e.File.FileName;
        tableSiteInfo.Visible = true;
    }

    protected string ParseField(string field, int? maxLength)
    {
        if (maxLength != null)
            field = field.SafeSubstring(0, maxLength.Value);
        return field.Replace((char)65533, '£');
    }

    protected void RadGrid1_NeedDataSource(object sender, Telerik.Web.UI.GridNeedDataSourceEventArgs e)
    {
        if (hdnLoaded.Value == "1")
        {
            CMUContract contract = new CMUContract();
            contract.LoadByCurrentSessionID();
            RadGrid1.DataSource = contract;
        }
    }

    protected void btnProcess_Click(object sender, EventArgs e)
    {
        LoadData(null);
    }

    protected void rsliderProfiles_OnValueChanged(object sender, EventArgs e)
    {
        LoadData(null);
    }

    protected void RadGrid1_PreRender(object sender, EventArgs e)
    {
        RadGrid1.Columns[0].CurrentFilterFunction = Telerik.Web.UI.GridKnownFunction.StartsWith;
        RadGrid1.Columns[3].CurrentFilterFunction = Telerik.Web.UI.GridKnownFunction.EqualTo;

        tblMain.Visible = RadGrid1.SelectedItems.Count > 0;
    }

    /// <summary>
    /// Called when Delete Link button is clicked
    /// Does not actually delete the link between CMU and pharmacy drug instead it asks the user if 
    /// they really want to perform the operation the does __doPostBack('upPanel', 'DeleteLink:{SiteProductDataID}');
    /// </summary>
    protected void btnDeleteLink_OnClick(object sender, EventArgs e)
    {
        // Check very thing is selected
        if (string.IsNullOrEmpty(hdnCMUContractID.Value))
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "DeleteLinkError", "alertEnh('Select a CMU contract row');", true);
            return;
        }
        if (string.IsNullOrEmpty(hdnSiteProductDataID.Value))
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "DeleteLinkError", "alertEnh('No product assoicated with this Contract');", true);
            return;
        }

        // Ask if want to delete product
        WProduct product = new WProduct();
        product.LoadByProductAndSiteID(hdnNSVCode.Value, SessionInfo.SiteID);
        
        string str = string.Format("confirmEnh('Delete the contract link to<br />{0} - {1}', false, function() {{ __doPostBack('upPanel', 'DeleteLink:{2}'); }}, undefined);", product[0].NSVCode, product[0].ToString().Replace("'", "\\'"), product[0].SiteProductDataID);
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "DeleteLinkQuestion", str, true);
    }

    protected void btnDeleteSupplierProfile_OnClick(object sender, EventArgs e)
    {
        if (string.IsNullOrEmpty(hdnSupplierProfileID.Value))
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "DeleteSupplierProfile", "alertEnh('No supplier association');", true);
            return;
        }

        // Get which sites deletion can be replciated to
        int supplierProfileID = int.Parse(hdnSupplierProfileID.Value);
        WSupplierProfileRow supplierProfile = WSupplierProfile.GetByWSupplierProfileID(supplierProfileID);

        var siteInfo = ContractProcessor.DetermineIfSiteValidForReplication(this.replicateToSiteNumbers, hdnNSVCode.Value, supplierProfile.SupplierCode, false, true);

        // Check that it is not primary supplier
        int siteID = SessionInfo.SiteID;
        if (siteInfo.Any(s => s.siteID == siteID && s.validState == ContractProcessor.SiteValid.NoIsPrimarySupplier))
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "DeleteSupplierProfile", "alertEnh('Cannot delete primary supplier');", true);
            return;
        }


        // Build message
        WProductRow  product  = WProduct.GetByProductAndSiteID(supplierProfile.NSVCode,     siteID);
        WSupplierRow supplier = WSupplier.GetBySupCodeAndSite(supplierProfile.SupplierCode, siteID);
        var validSitesNumbers    = siteInfo.Where(s => s.validState == ContractProcessor.SiteValid.Yes).Select(s => s.siteNumber).OrderBy(s => s).ToList();
        var primarySupplierSites = siteInfo.Where(s => s.validState == ContractProcessor.SiteValid.NoIsPrimarySupplier).Select(s => s.siteNumber).OrderBy(s => s);
        var invalidSites         = siteInfo.Where(s => s.validState != ContractProcessor.SiteValid.Yes && s.validState != ContractProcessor.SiteValid.NoIsPrimarySupplier).Select(s => s.siteNumber).OrderBy(s => s);

        // Add current site (looks better if no replicate to sites) 8Jun15 XN 
        StringBuilder msg = new StringBuilder();
        msg.AppendFormat("{0} - {1}<br /><br />", product.NSVCode, product.ToString().Replace("'", "\\'"));
        msg.AppendFormat("Deletion of supplier profile<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{0} - {1}<br /><br />", supplier.Code, supplier.Name);
        msg.AppendFormat("will apply to the following sites: {0}<br /><br />", validSitesNumbers.ToCSVString(", "));
        if (primarySupplierSites.Any())
            msg.AppendFormat("Deletion will not apply to these sites where it is the Primary Supplier: {0}<br /><br />", primarySupplierSites.ToCSVString(", "));
        if (invalidSites.Any())
            msg.AppendFormat("Deletion will not apply to following sites as supplier profile does not exist: {0}<br /><br />", invalidSites.ToCSVString(", "));
        msg.AppendFormat("OK to continue?");

        string script = string.Format("confirmEnh('{0}', false, function() {{ __doPostBack('upPanel', 'DeleteSupplierProfile:{1}'); }}, undefined)", msg.Replace("'", "\\'"), supplierProfileID);;
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "DeleteSupplierProfile", script, true);
    }

    [WebMethod]
    public static void CleanUp(int sessionID)
    {
        SessionInfo.InitialiseSession(sessionID);
        CMUContract.DeleteByCurrentSessionID();
    }

    private void LoadData(int? wsupplierProfileID)
    {
        hdnNSVCode.Value            = string.Empty;
        hdnSupplierProfileID.Value  = string.Empty;
        hdnIsExtrernalSupplier.Value= "false";
        hdnCMUContractID.Value      = string.Empty;

        if (RadGrid1.SelectedItems.Count > 0)
        {
            tblMain.Visible    = true;
            btnProcess.Visible = false;
            GridDataItem dataItem = (GridDataItem)RadGrid1.SelectedItems[0];
            if (dataItem != null)
            {
                StringBuilder sb = new StringBuilder();
                using (CMUContract contract = new CMUContract())
                {
                    contract.LoadByID(int.Parse(dataItem.GetDataKeyValue("PharmacyCMUContractID").ToString()));

                    hdnCMUContractID.Value = dataItem.GetDataKeyValue("PharmacyCMUContractID").ToString();
                    CMUHeader.InnerHtml = string.Format("Contract data for :<br />{0}<BR/>Pack size: {1}&nbsp;&nbsp;&nbsp;&nbsp;Supplier: {2}<BR/>NPC Code: {3}", dataItem["GenericDescription"].Text, 
                                                                                                                                                                  dataItem["PackSize"].Text, 
                                                                                                                                                                  contract[0].SupplierCode, 
                                                                                                                                                                  dataItem["NPCCode"].Text);

                    cmuOrderFrom.InnerHtml = string.IsNullOrEmpty(contract[0].OrderFrom) ? "&nbsp" : contract[0].OrderFrom;
                    cmuLeadTime.InnerHtml = string.IsNullOrEmpty(contract[0].LeadTime) ? "&nbsp" : contract[0].LeadTime;
                    cmuMinOrdValue.InnerHtml = string.IsNullOrEmpty(contract[0].MinTotalOrderValue) ? "&nbsp" : contract[0].MinTotalOrderValueFormattedString();
                    cmuPrice.InnerHtml = contract[0].PriceInPounds == null ? "&nbsp" : contract[0].PriceInPounds.ToString();
                    cmuMinQty.InnerHtml = string.IsNullOrEmpty(contract[0].MinOrderQuantity) ? "&nbsp" : contract[0].MinOrderQuantity;
                    cmuTradeName.InnerHtml = string.IsNullOrEmpty(contract[0].BrandName) ? "&nbsp" : contract[0].BrandName;
                    cmuValid.InnerHtml = string.Format("{0} to {1}", string.Format("{0:dd/MM/yyyy}", contract[0].RecordStatusStartDate), string.Format("{0:dd/MM/yyyy}", contract[0].RecordStatusEndDate));
                    cmuDeliveryCharge.InnerHtml = string.IsNullOrEmpty(contract[0].DeliveryInformation) ? "&nbsp" : contract[0].DeliveryInformation;
                    cmuContractReference.InnerHtml = string.IsNullOrEmpty(contract[0].ContractCode) ? "&nbsp" : contract[0].ContractCode;
                }
                string nsvCode = string.Empty;
                using (WProduct product = new WProduct())
                {
                    sb.Length = 0;
                    product.LoadBySiteIDAndAliasGroupAndAlias(SessionInfo.SiteID, "NPCCode", dataItem["NPCCode"].Text);
                    if (product.Count == 0)
                    {
                        AscribeHeader.InnerHtml = "No linked product";
                        ClearProfiles();
                    }
                    else
                    {
                        sb.Append("Pharmacy current data for:<br />");
                        sb.Append(product[0].ToString());
                        sb.Append("<BR/>Pack size: ");
                        sb.Append(product[0].ConversionFactorPackToIssueUnits.ToString());
                        sb.Append("<BR/>NSV code: ");
                        sb.Append(product[0].NSVCode);
                        nsvCode = product[0].NSVCode;
                        hdnNSVCode.Value = nsvCode;
 //                       hdnDrugDescription.Value = product.ToString();
                        hdnSiteProductDataID.Value = product[0].SiteProductDataID.ToString();
                        using (WSupplierProfile profile = new WSupplierProfile())
                        {
                            profile.LoadBySiteIDAndNSVCode(SessionInfo.SiteID, nsvCode);
                            string primarySupCode = product[0].SupplierCode;

                            var profileList = profile.OrderBy(p => p.SupplierCode).OrderBy(p => !primarySupCode.EqualsNoCaseTrimEnd(p.SupplierCode)).ToList();
                            int supIndex = 0;
                            if (wsupplierProfileID == null)
                                supIndex = (int)rsliderProfiles.Value;
                            else
                                supIndex = Math.Max(profileList.FindIndex(s => s.WSupplierProfileID == wsupplierProfileID), 0);

                            rsliderProfiles.Visible      = (profileList.Count > 1);
                            rsliderProfiles.MinimumValue = 0;
                            rsliderProfiles.MaximumValue = profileList.Count - 1;
                            rsliderProfiles.Value        = supIndex;

                            if (profileList.Count > supIndex)
                            {
                                WSupplierProfileRow profileRow = profileList[supIndex];
                                bool isPrimary = primarySupCode.EqualsNoCaseTrimEnd(profileRow.SupplierCode);

                                WExtraDrugDetail extraDrugDetail = new WExtraDrugDetail();
                                extraDrugDetail.LoadBySiteIDNSVCodeAndSupCode(SessionInfo.SiteID, nsvCode, profileRow.SupplierCode);
                                bool isContractStillDue = extraDrugDetail.FindFirstByIsStillDue() != null;
                                WExtraDrugDetailRow activeExtraDrugDetailRow = extraDrugDetail.FindByIsActive();

                                // Build up supplier type
                                StringBuilder supplierName = new StringBuilder();
                                if (isContractStillDue)
                                    supplierName.Append("<span style='color: green; font-style: italic; font-weight: bold;'>");
                                supplierName.AppendFormat("{0} - {1}", profileRow.SupplierCode, profileRow.SupplierName);
                                if (isContractStillDue)
                                    supplierName.Append("</span>");
                                supplierName.Append("<BR/>");
                                supplierName.Append(isPrimary ? "Primary Supplier" : "Secondary Supplier");

                                ascSupplierType.InnerHtml       = supplierName.ToString();
                                priContractReference.InnerHtml  = string.IsNullOrEmpty(profileRow.ContractNumber)    ? "&nbsp"  : profileRow.ContractNumber;
                                priPrice.InnerHtml              = profileRow.ContractPrice == null                   ? "&nbsp"  : string.Format("{0:F2}", profileRow.ContractPrice / 100M);
                                priValid.InnerHtml              = activeExtraDrugDetailRow == null                   ? "&nbsp;" : string.Format("{0} to {1}", activeExtraDrugDetailRow.DateOfChange.ToPharmacyDateString(), activeExtraDrugDetailRow.StopDate.ToPharmacyDateString());
                                

                                SiteProductDataRow masterProduct = SiteProductData.GetByDrugIDAndMasterSiteID(product[0].DrugID, 0);
                                if (masterProduct != null)
                                    priTradeName.InnerHtml = string.IsNullOrEmpty(masterProduct.Tradename) ? profileRow.SupplierTradename : "<span style='float: left;'>" + masterProduct.Tradename + "</span><span style='float: right; color: white; background-color: coral; font-style: italic; font-weight: bold;'>&nbsp;AMPP&nbsp;</span>";
                                else
                                    priTradeName.InnerHtml = string.IsNullOrEmpty(profileRow.SupplierTradename) ? product[0].Tradename : profileRow.SupplierTradename;

                                hdnSupplierProfileID.Value      = profileRow.WSupplierProfileID.ToString();
                                hdnIsExtrernalSupplier.Value    = (profileRow.SupplierType == SupplierType.External).ToString().ToLower();
                            }
                        }
                        AscribeHeader.InnerHtml = sb.ToString();
                    }
                }
            }
        }
        else
            tblMain.Visible = false;
    }

    private void ClearProfiles()
    {
        rsliderProfiles.Visible             = false;
        ascSupplierType.InnerHtml           = "&nbsp";
        priContractReference.InnerHtml      = "&nbsp";
        priPrice.InnerHtml                  = "&nbsp";
        priValid.InnerHtml                  = "&nbsp";
        priTradeName.InnerHtml              = "&nbsp";
        rsliderProfiles.Value               = 0;
        hdnSupplierProfileID.Value          = string.Empty;
        hdnIsExtrernalSupplier.Value        = "false";
        hdnSiteProductDataID.Value          = string.Empty;
    }


    protected void RadGrid1_SelectedIndexChanged(object sender, EventArgs e)
    {
        rsliderProfiles.Value = 0;
        LoadData(null);
    }
}

