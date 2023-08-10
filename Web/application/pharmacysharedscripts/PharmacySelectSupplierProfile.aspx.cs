//===========================================================================
//
//						 PharmacySelectSupplierProfile.aspx.cs
//
//  Allows user to select a supplier profile. This is a close copy of vb6 enter supplier form
//  in WSupplierProfileIO.bas EditSupProfile
//       
//  Call the page with the follow parameters
//  SessionID                   - ICW session ID
//  AscribeSiteNumber           - Pharmacy site (need either AscribeSiteNumber or SiteID)
//  SiteID                      - 
//  NSVCode                     - Drug NSV Code
//  DefaultSupCode              - (optional) default supcode to select
//  AddNewSupplierProfileOption - (optional) If displaying the Add new supplier option (default false)
//  SupplierTypesFilter         - (optional) Supplier type codes to filter list of suppliers default is empty string for all suppliers
//                                (e.g. W - for ward, ES - for external or stores)
//
//  The page will return the selected WSupplierProfileID, supcode and description as
//      {WSupplierProfileID|SupCode|Description}
//  if nothing selected returns undefined
//  if add sner supplier selected returns empty string
//      
//
//  Usage:
//  PharmacySelectSupplierProfile.aspx?SessionID=123&AscribeSiteNumber=700&NSVCode=NDV242D
//
//	Modification History:
//	24Jul13 XN  Written 24653
//===========================================================================
using System;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;
using System.Collections.Generic;

public partial class application_pharmacysharedscripts_PharmacySelectSupplierProfile : System.Web.UI.Page
{
    #region Member Variables
    /// <summary>NSV code for profile</summary>
    protected string NSVCode;

    /// <summary>Sup code select by default</summary>
    protected string defaultSupCode;

    /// <summary>Display the add new supplier profile option</summary>
    protected bool displayAddNewSupplierProfileOption;

    /// <summary>Allowed supplier types (if not set then all)</summary>
    protected string supplierTypesFilter;
    #endregion

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSessionAndSite(this.Request, null);

        // Get other URL parameters
        defaultSupCode                     = Request["DefaultSupCode"] ?? string.Empty;
        NSVCode                            = Request["NSVCode"];
        displayAddNewSupplierProfileOption = BoolExtensions.PharmacyParse(Request["AddNewSupplierProfileOption"] ?? "false");
        supplierTypesFilter                = Request["SupplierTypesFilter"] ?? string.Empty;

        if (!this.IsPostBack)
        {
            // Get product primary supplier
            string primarySupCode = string.Empty;
            WProductRow productRow = WProduct.GetByProductAndSiteID(NSVCode, SessionInfo.SiteID);
            if (productRow != null)
                primarySupCode = productRow.SupplierCode;

            // Get all supplier prfiles for the product
            WSupplierProfile profiles = new WSupplierProfile();
            profiles.LoadBySiteIDAndNSVCode(SessionInfo.SiteID, NSVCode);
            IEnumerable<WSupplierProfileRow> profileList = profiles;

            // Filter by supplier type
            SupplierType[] supplierTypes = supplierTypesFilter.ToCharArray().Select(c => EnumDBCodeAttribute.DBCodeToEnum<SupplierType>(c.ToString()) ).ToArray();
            if (supplierTypes.Any())
                profileList = profileList.Where(p => supplierTypes.Contains(p.SupplierType));

            // Order by primary first then supcode
            profileList = profileList.OrderBy(s => s.SupplierCode).OrderBy(s => !primarySupCode.EqualsNoCaseTrimEnd(s.SupplierCode));

            // create grid of suppliers
            gcSearchResults.AddColumn("Code",        10);
            gcSearchResults.AddColumn("Description", 65);
            gcSearchResults.ColumnAllowTextWrap(1, true);
            gcSearchResults.AddColumn(string.Empty,  25, PharmacyGridControl.AlignmentType.Center);

            int selectedRowIndex = 0;
            foreach (var profileRow in profileList)
            {
                gcSearchResults.AddRow();
                gcSearchResults.AddRowAttribute("WSupplierProfileID",   profileRow.WSupplierProfileID.ToString());
                gcSearchResults.AddRowAttribute("SupCode",              profileRow.SupplierCode                 );

                gcSearchResults.SetCell(0, profileRow.SupplierCode);
                gcSearchResults.SetCell(1, profileRow.SupplierName);
                gcSearchResults.SetCell(2, primarySupCode.EqualsNoCaseTrimEnd(profileRow.SupplierCode) ? "(Primary Supplier)" : string.Empty);

                // If supplier is default supplier to select then note row index
                if (profileRow.SupplierCode.EqualsNoCaseTrimEnd(defaultSupCode))
                    selectedRowIndex = gcSearchResults.RowCount - 1;
            }

            // Select the required row (either first or row of default supplier)
            if (profiles.Any())
                gcSearchResults.SelectRow(selectedRowIndex);

            // Add new supplier profile row if needed
            if (displayAddNewSupplierProfileOption)
            {
                gcSearchResults.AddRow();
                gcSearchResults.SetCell(0, "Add New Supplier Profile");
                gcSearchResults.SetCellColSpan(0, gcSearchResults.ColumnCount);
            }

            // If no rows then show error message
            if (gcSearchResults.RowCount == 0)
                ScriptManager.RegisterStartupScript(this, this.GetType(), "NoSupplierProfiles", "alert('No suppliers have been setup for this product.'); window.returnValue = undefined; window.close();", true);
        }
    }
}
