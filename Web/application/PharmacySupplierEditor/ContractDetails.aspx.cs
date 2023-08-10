//===========================================================================
//
//					          ContractDetails.aspx.cs
//
//  Displays the ContractDetails editor.
//
//  Contract details are saved to the WSupplier2ExtraData
//
//  Data in this page is only ever avaiable from this page, or as print elements
//  it is not displayed or used anywhere else in pharmacy
//  The Date of Change also has no effect as there is no code to perform the
//  change, it just exists because it always has.
//  
//
//  The page expects the following URL parameters
//  SessionID   - ICW session ID
//  WSupplier2ID- row id to update (if does not exits will create one)
//  
//  Usage:
//  ContractDetails.aspx?SessionID=123&WSupplier2ID=43
//
//	Modification History:
//	27Jun14 XN   43318 Created
//===========================================================================
using System;
using System.Linq;
using System.Web.UI;
using ascribe.pharmacy.pharmacydatalayer;
using ascribe.pharmacy.shared;

public partial class application_PharmacySupplierEditor_ContractDetails : System.Web.UI.Page
{
    protected WSupplier2ExtraData extraData = new WSupplier2ExtraData();
    protected int supplier2ID;

    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSession(this.Request);

        supplier2ID = int.Parse(Request["WSupplier2ID"]);
        extraData.LoadByID(supplier2ID);

        if (this.IsPostBack)
            this.LoadAscribeCoreControlsToViewState();
        else
        {
            if (!extraData.Any())
                extraData.Add();
            var row = extraData.FirstOrDefault();

            var columnInfo = WSupplier2ExtraData.GetColumnInfo();

            tbCurrentContractDetails.MaxCharacters  = columnInfo.CurrentContractDataLength;
            tbCurrentContractDetails.Value          = row.CurrentContractData;
            tbNewContractDetails.MaxCharacters      = columnInfo.NewContractDataLength;
            tbNewContractDetails.Value              = row.NewContractData;
            dtDateOfChange.Value                    = row.DateOfChange;
            btnClose.Attributes["onclick"]          = "btnClose_onclick();";
            this.SaveAscribeCoreControlsToViewState();
        }
    }

    protected void btnNewWithOld_OnClick(object sender, EventArgs e)
    {
        tbNewContractDetails.Value = tbCurrentContractDetails.Value;
    }

    protected void btnSave_OnClick(object sender, EventArgs e)
    {
        if (extraData.Any() || 
            !string.IsNullOrEmpty(tbCurrentContractDetails.Value) || !string.IsNullOrEmpty(tbNewContractDetails.Value) || dtDateOfChange.Value != null)
        {
            var row = extraData.FirstOrDefault();
            if (row == null)
            {
                row              = extraData.Add();
                row.WSupplier2ID = supplier2ID;
            	row.Notes = string.Empty;
            }
            row.CurrentContractData = tbCurrentContractDetails.RawValue;
            row.NewContractData     = tbNewContractDetails.RawValue;
            row.DateOfChange        = dtDateOfChange.Value;
            extraData.Save();
        }
        ScriptManager.RegisterStartupScript(this, this.GetType(), "ClearDirtyFlag", "clearIsPageDirty();", true);
    }
}