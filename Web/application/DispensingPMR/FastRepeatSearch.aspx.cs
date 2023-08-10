//===========================================================================
//
//							   FastRepeatSearch.aspx.cs
//
//  Displays a form that allows the user to enter a fast repeat number, and
//  returns the episode and request ID
//  Searches the PrescriptionAlias table under AlaisGroup 'EpisodeOrderLookup'
//
//  Saves the Entity and Episode IDs to the State table.
//
//  Will return the following
//      {episodeID}|{requestID}|{autoDispense}
//  
//  Auto dispense is controlled by setting 
//  System: Pharmacy
//  Section: FastRepeat
//  Key: AutoDispenseEnabled
//
//  The acutal name given the the fast releate under is controlled by setting (default is Fast Repeat Number)
//  System: Pharmacy
//  Section: FastRepeat
//  Key: Name
//
//  To use the fast repeat form there is a generic button on the Episode Selector page
//  This button sends out a EVENT_FastRepeat event, which is picked up by the 
//  dispensing PMR which then launches this form. The user enters a fast repeat number 
//  that is attached to a prescription (in the PrescriptionAlais table), this is 
//  saved to db state table and web session cache. The dispensing PMR then sends out
//  a RAISE_EpisodeSelected event, and refreshes its select, also picks up the
//  prescription ID for the session table, and sets it up to be dispensed.
//
//  Usage:
//  FastRepeatSearch.aspx?SessionID=123&
//
//	Modification History:
//	12Aug13 XN   Created 70138
//  11Sep13 XN   Prevented saving requestID, and autoDispense to the State table
//               now just returns as part of the form 72983 
//  19Sep13 XN   Made the fast repeat name configurable by setting 73809
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.icwdatalayer;

public partial class application_DispensingPMR_FastRepeatSearch : System.Web.UI.Page
{
    private static readonly string aliasGroup_EpisodeOrderLookup = "EpisodeOrderLookup";

    protected int sessionID;

    protected string searchName;

    protected void Page_Load(object sender, EventArgs e)
    {
        this.sessionID = int.Parse(Request["SessionID"]);
        SessionInfo.InitialiseSession(this.sessionID);

        // Check FastRepeat alias group exists
        ICWTypeData? typeData = ICWTypes.GetTypeByDescription(ICWType.AliasGroup, aliasGroup_EpisodeOrderLookup);
        if (typeData == null)
            throw new ApplicationException("Invalid alias group '" + aliasGroup_EpisodeOrderLookup + "'");

        searchName = SettingsController.Load("Pharmacy", "FastRepeat", "Name", "Fast Repeat Number");
    }

    protected void btnSearch_OnClick(object sender, EventArgs e)
    {
        string error;

        // Validate
        if (!Validation.ValidateText(txtFastRepeatNumber, searchName, typeof(string), true, out error))
        {
            lbError.Text = error;
            txtFastRepeatNumber.Focus();
            return;
        }

        // Try to find
        EpisodeOrder episodeOrder = new EpisodeOrder();
        episodeOrder.LoadByAlias(txtFastRepeatNumber.Text, aliasGroup_EpisodeOrderLookup);
        if (!episodeOrder.Any())
        {
            lbError.Text = "Failed to find a match";
            txtFastRepeatNumber.Focus();
            return;
        }

        // Sage the episode and entity to the state table (used by entity panel)
        GENRTL10.State state = new GENRTL10.State();
        state.SetKey(sessionID, "Episode", episodeOrder[0].EpisodeID                      );
        state.SetKey(sessionID, "Entity",  Episode.GetEntityID(episodeOrder[0].EpisodeID) );

        //// Save the prescription to the DB cache (used by dispensing pmr)
        //PharmacyDataCache.SaveToSession("Prescription", episodeOrder[0].RequestID.ToString());
        //PharmacyDataCache.SaveToSession("AutoDispense", SettingsController.Load<bool>("Pharmacy", "FastRepeat", "AutoDispenseEnabled", true));
        // 11Sep13 XN 72983 Prevented saving requestID, and autoDispense to the State table  now just returns as part of the form 

        // Return selected result
        bool autoDispense = SettingsController.Load<bool>("Pharmacy", "FastRepeat", "AutoDispenseEnabled", true);
        string script = string.Format("window.returnValue = '{0}|{1}|{2}'; window.close();", episodeOrder[0].EpisodeID, episodeOrder[0].RequestID, autoDispense);
        ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "FoundPrescription", script, true);
    }
}
