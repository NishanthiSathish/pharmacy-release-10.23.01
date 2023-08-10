// -----------------------------------------------------------------------
// <copyright file="HonKongPatientEpisodeEditor.aspx.cs" company="Ascribe">
// Allows the user to enter the patient Chinese name and preferred language type.
//      
//	Modification History:
//	02Oct15 XN  Created 77780
//  03Nov15 XN  Added patient category 133875
// </copyright>
// -----------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;
using _Shared;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.shared;

public partial class application_HongKong_HonKongPatientEpisodeEditor : System.Web.UI.Page
{
    /// <summary>Currently selected patient entity Id</summary>
    protected int entityId = -1;

    /// <summary>Currently selected patient episode Id</summary>
    protected int? episodeId = -1;

    /// <summary>Called when pages is loaded</summary>
    /// <param name="sender">the sender</param>
    /// <param name="e">the event args</param>
    protected void Page_Load(object sender, EventArgs e)
    {
        SessionInfo.InitialiseSession(this.Request);

        // Gets the patient episode from State table, and from there the entity
        this.episodeId = SessionInfo.GetStatePKByTable("Episode");
        if (episodeId != null)
        {
            this.entityId = Episode.GetEntityID(episodeId.Value);
        }

        // If no entity selected the warn and close
        if (this.entityId < 0)
        {
            ScriptManager.RegisterStartupScript(this, this.GetType(), "NoPatient", "alert('You need to select a patient, or save new patient details.\nBefore you can continue?'); window.close();", true);
            this.Clear();
        }

        if (!this.IsPostBack)
        {
            this.Populate();
        }
    }

    /// <summary>
    /// Called when OK button is clicked
    /// Saves patient data (does not validate as nothing to validate)
    /// </summary>
    /// <param name="sender">the sender</param>
    /// <param name="e">the event args</param>
    protected void btnOK_OnClick(object sender, EventArgs e)
    {
        this.Save();
    }

    /// <summary>Populates the form</summary>
    private void Populate()
    {
        List<SqlParameter> parameters = new List<SqlParameter>();

        // Load preferred language details
        GenericTable2 patientPreferredLanguageTable = new GenericTable2("PatientPreferredLanguage");
        parameters.Add("CurrentSessionID", SessionInfo.SessionID);
        patientPreferredLanguageTable.LoadBySP("pPatientPreferredLanguageList", parameters);
        foreach (BaseRow r in patientPreferredLanguageTable)
        {
            ddlPreferredLanguage.Items.Add(new ListItem(r.RawRow["Description"].ToString(), r.RawRow["PatientPreferredLanguageID"].ToString()));
        }

        // Load patient Chinese name and preferred language
        GenericTable2 entityExtraInfo = new GenericTable2("EntityExtraInfo");
        parameters.Clear();
        parameters.Add("EntityID", this.entityId);
        entityExtraInfo.LoadBySP("pEntityExtraInfoByEntityID", parameters);
        if (entityExtraInfo.Any())
        {
            tbChineseName.Text = entityExtraInfo[0].RawRow["ChineseName"].ToString();

            string preferredLanguageId = entityExtraInfo[0].RawRow["PatientPreferredLanguageID"].ToString();
            ddlPreferredLanguage.SelectedIndex = ddlPreferredLanguage.Items.OfType<ListItem>().ToList().FindIndex(i => i.Value == preferredLanguageId);
            if (ddlPreferredLanguage.SelectedIndex == -1)
            {
                ddlPreferredLanguage.SelectedIndex = 0;
            }
        }

        // Load patient category 3Nov15 XN 133875
        GenericTable2 patientCategoryTable = new GenericTable2("PatientCategory");
        parameters.Clear();
        parameters.Add("CurrentSessionID", SessionInfo.SessionID);
        patientCategoryTable.LoadBySP("pPatientCategoryList", parameters);
        ddlPatientCategory.Items.Add(new ListItem(string.Empty, string.Empty));
        foreach (BaseRow r in patientCategoryTable)
        {
            ddlPatientCategory.Items.Add(new ListItem(r.RawRow["Description"].ToString(), r.RawRow["Code"].ToString()));
        }

        // Load patient category 3Nov15 XN 133875
        GenericTable2 episodeExtraInfo = new GenericTable2("EpisodeExtraInfo");
        parameters.Clear();
        parameters.Add("EpisodeID", this.episodeId);
        episodeExtraInfo.LoadBySP("pEpisodeExtraInfoByEpisodeID", parameters);
        if (episodeExtraInfo.Any())
        {
            string patientCategoryCode = episodeExtraInfo[0].RawRow["PatientCategory"].ToString();
            ddlPatientCategory.SelectedIndex = ddlPatientCategory.Items.OfType<ListItem>().ToList().FindIndex(i => i.Value == patientCategoryCode);
            if (ddlPatientCategory.SelectedIndex == -1)
            {
                ddlPatientCategory.SelectedIndex = 0;
            }
        }
    }

    /// <summary>Clears the form</summary>
    private void Clear()
    {
        tbChineseName.Text = string.Empty;
        if (ddlPreferredLanguage.Items.Count > 0)
        {
            ddlPreferredLanguage.SelectedIndex = 0;
        }
        if (ddlPatientCategory.Items.Count > 0)
        {
            ddlPatientCategory.SelectedIndex = 0;
        }
    }

    /// <summary>Saves the data</summary>
    private void Save()
    {
        // Load existing
        List<SqlParameter> parameters = new List<SqlParameter>();
        parameters.Clear();
        parameters.Add("EntityID", this.entityId);

        GenericTable2 entityExtraInfo = new GenericTable2("EntityExtraInfo");
        entityExtraInfo.LoadBySP("pEntityExtraInfoByEntityID", parameters);

        GenericTable2 episodeExtraInfo = new GenericTable2("EpisodeExtraInfo");
        parameters.Clear();
        parameters.Add("EpisodeID", this.episodeId);
        episodeExtraInfo.LoadBySP("pEpisodeExtraInfoByEpisodeID", parameters);

        // If row does not exist then create
        if (!entityExtraInfo.Any())
        {
            entityExtraInfo.Add();
            entityExtraInfo[0].RawRow["EntityID"] = this.entityId.ToString();
        }
        
        entityExtraInfo[0].RawRow["ChineseName"]                = tbChineseName.Text;
        entityExtraInfo[0].RawRow["PatientPreferredLanguageID"] = int.Parse(ddlPreferredLanguage.SelectedItem.Value);

        if (!episodeExtraInfo.Any())
        {
            episodeExtraInfo.Add();
            episodeExtraInfo[0].RawRow["EpisodeID"]    = this.episodeId.ToString();
            episodeExtraInfo[0].RawRow["HAEpisodeKey"] = string.Empty;
        }

        episodeExtraInfo[0].RawRow["PatientCategory"] = ddlPatientCategory.SelectedItem.Value;

        // Save
        using (ICWTransaction trans = new ICWTransaction(ICWTransactionOptions.ReadCommited))
        {
            entityExtraInfo.Save();
            episodeExtraInfo.Save();
            trans.Commit();
        }

        // Close page
        this.ClosePage("true");
    }
}