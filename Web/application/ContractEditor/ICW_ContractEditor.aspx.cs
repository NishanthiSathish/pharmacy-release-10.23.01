//===========================================================================
//
//					    ICW_ContractEditor.aspx.cs
//
//  Allows user to manually edit a contract.
//
//  Basically uses an embedded PharmacyProductSearch to 
//  allow the user to select a drug, and then displays the manual contract editor
//
//  When user deletes the supplier profile process is as follows
//      btnDeleteSupplierProfile_onclick        - Client side method called by button
//          PharmacySelectSupplierProfile.aspx  - Get list of profiles avaiable 
//              CanDeleteSupplierProfile        - Server side method that checks list of sites profile can be delete from and send confirm message to user
//                  DeleteSupplierProfile       - Server side method to perform delete once user confirms
//
//  The page expects the following URL parameters
//  SessionID               - ICW session ID
//  AscribeSiteNumber       - Site number
// 
//  Usage:
//  ICW_ContractEditor.aspx?SessionID=123&AscribeSiteNumber=3232
//
//	Modification History:
//	09Aug13 XN  24653  Created
//  08Jun15 XN  119361 Moved settings SitesAllowedForReplciation and SiteNumbersSelectedByDefault to 
//              desktop parameters ReplicateToSiteNumbers
//              DetermineIfSiteValidForReplication moved from ContractEditorSettings to ContractProcessor
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web.UI;
using ascribe.pharmacy.businesslayer;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_ContractEditor_ICW_ContractEditor : System.Web.UI.Page
{
    protected int windowID;

    /// <summary>List of sites that are allowed for replication 08Jun15 XN 119361</summary>
    private List<int> replicateToSiteNumbers;

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, this.Response);

        // Get Parameters
        this.windowID               = int.Parse(this.Request["WindowID"]);
        this.replicateToSiteNumbers = Site2.Instance().FindBySiteNumber(this.Request["ReplicateToSiteNumbers"], true, CurrentSiteHandling.AtStart).Select(s => s.SiteNumber).ToList();

        // Deal with __postBack events
        string   args      = Request["__EVENTARGUMENT"];
        string[] argParams = new string[0];
        if (!string.IsNullOrEmpty(args))
            argParams = args.Split(new char[] { ':' }, StringSplitOptions.RemoveEmptyEntries);

        if (argParams.Length > 0)
        {
            switch (argParams[0])
            {
            case "CanDeleteSupplierProfile":  
                {
                int wsupplierProfileID = int.Parse(argParams[1]);
                CanDeleteSupplierProfile(wsupplierProfileID);
                }
                break;

            case "DeleteSupplierProfile":
                {
                int wsupplierProfileID = int.Parse(argParams[1]);
                DeleteSupplierProfile(wsupplierProfileID);
                }
                break;
            }
        }
    }

    /// <summary>
    /// Determines if the profile can be deleted (not primary)
    /// Also asks user to confirm with list of sites this will effect
    /// </summary>
    /// <param name="wsupplierProfileID">Supplier profile to delete</param>
    private void CanDeleteSupplierProfile(int wsupplierProfileID)
    {
        // Load the profile
        WSupplierProfile profile = new WSupplierProfile();                    
        profile.LoadByWSupplierProfileID(wsupplierProfileID);

        // If primary supplier can't dletet
        WProductRow product = WProduct.GetByProductAndSiteID(profile[0].NSVCode, SessionInfo.SiteID);
        if (product.SupplierCode.EqualsNoCaseTrimEnd(profile[0].SupplierCode))
        {
            ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "PrimarySupplier", "alertEnh(\"Cannot delete primary supplier\", function() { SetFocusToProductSearchGrid(); });", true);
            return;
        }

        // Load site the delete is to be replciated to
        WSupplierRow supplier = WSupplier.GetBySupCodeAndSite(profile[0].SupplierCode, SessionInfo.SiteID);
        var siteInfo             = ContractProcessor.DetermineIfSiteValidForReplication(this.replicateToSiteNumbers, profile[0].NSVCode, profile[0].SupplierCode, false, true); 
        var validSitesNumbers    = siteInfo.Where(s => s.validState == ContractProcessor.SiteValid.Yes).Select(s => s.siteNumber).OrderBy(s => s).ToList();
        var primarySupplierSites = siteInfo.Where(s => s.validState == ContractProcessor.SiteValid.NoIsPrimarySupplier).Select(s => s.siteNumber).OrderBy(s => s);
        var invalidSites         = siteInfo.Where(s => s.validState != ContractProcessor.SiteValid.Yes && s.validState != ContractProcessor.SiteValid.NoIsPrimarySupplier).Select(s => s.siteNumber).OrderBy(s => s);

        // Ask user to confirm the deletion for other sites
        StringBuilder msg = new StringBuilder();
        msg.AppendFormat("{0} - {1}<br /><br />", product.NSVCode, product.ToString().Replace("'", "\\'"));
        msg.AppendFormat("Deletion of supplier profile<br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;{0} - {1}<br /><br />", supplier.Code, supplier.Name);
        msg.AppendFormat("will apply to the following sites: {0}<br /><br />", validSitesNumbers.ToCSVString(", "));
        if (primarySupplierSites.Any())
            msg.AppendFormat("Deletion will not apply to these sites where it is the Primary Supplier: {0}<br /><br />", primarySupplierSites.ToCSVString(", "));
        if (invalidSites.Any())
            msg.AppendFormat("Deletion will not apply to following sites as supplier profile does not exist: {0}<br /><br />", invalidSites.ToCSVString(", "));
        msg.AppendFormat("OK to continue?");

        string script = string.Format("confirmEnh('{0}', false, function() {{ __doPostBack('upUpdatePanel', 'DeleteSupplierProfile:{1}'); }}, function() {{ SetFocusToProductSearchGrid(); }});", msg.Replace("'", "\\'"), wsupplierProfileID);
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "CheckWithUser", script, true);
    }

    /// <summary>Delete the supplier profile (delete from all replicate to sites as well)</summary>
    /// <param name="wsupplierProfileID">Supplier profile to delete</param>
    private void DeleteSupplierProfile(int wsupplierProfileID)
    {
        // Load profile to delete
        WSupplierProfile profile = new WSupplierProfile();                    
        profile.LoadByWSupplierProfileID(wsupplierProfileID);

        // Get list of sites to delete the profile from (exclude primary sites)
        var validSites   = ContractProcessor.DetermineIfSiteValidForReplication(this.replicateToSiteNumbers, profile[0].NSVCode, profile[0].SupplierCode, false, true); 
        var validSiteIDs = validSites.Where(s => s.validState == ContractProcessor.SiteValid.Yes).Select(s => s.siteID).ToList();
            
        // Load profile for all sites (and delete from valid sites)
        profile.LoadBySupplierAndNSVCode(profile[0].SupplierCode, profile[0].NSVCode);
        profile.RemoveAll(p => validSiteIDs.Contains(p.SiteID));
        profile.Save();

        // Tell users
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "PrimarySupplier", "alertEnh('Supplier profile deleted.', function() { SetFocusToProductSearchGrid(); });", true);
    }
}
