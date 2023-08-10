// -----------------------------------------------------------------------
// <copyright file="PatientBanner.ascx.cs" company="Emis Health Plc">
//      Copyright Emis Health plc
// </copyright>
// <summary>
// Displays a banner with patient details in form
//  {Patient Name}  {DOB}  {Case number}  {NHS Number}
//  {Episode}  {Ward}  {Consultant}
//  {Height}  {Weight}  {BSA}
//
// The control support view state
//
// Usage
// Web Page
//  <%@ Register src="../pharmacysharedscripts/PatientBanner/PatientBanner.ascx" tagname="PatientBanner" tagPrefix="uc" %>
//  :
//  <uc1:PatientBanner ID="patientBanner" runat="server" />
//  
// Code behind
//  patientBanner.Initalise(episodeID)
//
// Modification History:
// 25Jun15 XN Created 39882
// 08Aug16 XN 159843 Changed name format to surname, forname, changed DOB format, added gender
// 15Aug16 XN 159843 Added age to DOB
// </summary>
// -----------------------------------------------------------------------
using System;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.shared;

public partial class application_pharmacysharedscripts_PatientBanner_PatientBanner : System.Web.UI.UserControl
{
    /// <summary>Populate the control</summary>
    /// <param name="episodeId">Patient episode Id</param>
    public void Initalise(int episodeId)
    {
        EpisodeRow episode = Episode.GetByEpisodeID(episodeId);
        PatientRow patient = Patient.GetByEntityID(episode.EntityID);
        WardRow ward = episode.GetWard();
        ConsultantRow consultant = episode.GetConsultant();

        //lbName.Text          = patient.Description;                                                       08Aug16 159843 Changed name format to surname, forname, changed DOB format
        //lbDOB.Text           = patient.DOB == null ? "Not Entered" : patient.DOB.ToPharmacyDateString();
        //lbHeight.Text        = 
        lbName.Text          = (string.IsNullOrWhiteSpace(patient.Surname) ? string.Empty : patient.Surname.ToUpper() + ", ") + patient.Forename;
        lbDOB.Text           = patient.DOB == null ? "Not Entered" : patient.DOB.Value.ToString("dd-MMM-yyyy") + " (" + patient.DOB.GetAgeStr(DateTime.Now) + ")";
        lbGender.Text        = patient.Gender.ToString(); 
        lbPatientStatus.Text = episode.EpisodeTypeStr;
        lbWard.Text          = (ward != null) ? ward.ToString() : "&nbsp;";
        lbConsultant.Text    = (consultant != null) ? consultant.Description : "&nbsp;";

        // Set patient height
        var heightObs = Observation.GetLatestByEpisodeTypeAndActive(episodeId, ICWTypes.GetTypeByDescription(ICWType.Note, "Height Observation").Value.ID);
        var heightInm = (heightObs == null) ? (double?)null : Unit.Convert(heightObs.Value, heightObs.UnitId, "m");
        if (heightInm == null)
        {
            lbHeightDisplayName.Visible = lbHeight.Visible = false;
        }
        else
        {
            lbHeight.Text           = heightInm.ToString("0.##") + " m";
            lbHeightExpired.Visible = heightObs.Expired;
        }

        // Set patient weight
        var weightObs  = Observation.GetLatestByEpisodeTypeAndActive(episodeId, ICWTypes.GetTypeByDescription(ICWType.Note, "Weight Observation").Value.ID);
        var weightInkg = (heightObs == null) ? (double?)null : Unit.Convert(weightObs.Value, weightObs.UnitId, "Kg");
        if (weightInkg == null)
        {
            lbWeightDisplayName.Visible = lbWeight.Visible = false;
        }
        else
        {
            lbWeight.Text           = weightInkg.ToString("0.#") + " Kg";
            lbWeightExpired.Visible = weightObs.Expired;
        }

        // Set BSA
        if (heightInm == null || weightInkg == null)
        {
            lbBSADisplayName.Visible = lbBSA.Visible = false;                        
        }
        else
        {
            lbBSA.Text = Database.ExecuteSQLScalar<double>("SELECT icwsys.fDSSCalculateSurfaceArea({0}, {1})", weightInkg, heightInm * 100).ToString("0.##") + " m²";
            lbBSAExpired.Visible = weightObs.Expired || heightObs.Expired;
        }

        // Set case number
        string caseNoDisplayName = PharmacyCultureInfo.CaseNumberDisplayName;
        if (string.IsNullOrEmpty(caseNoDisplayName))
        {
            lbCaseNoDisplayName.Visible = lbCaseNo.Visible = false;
        }
        else
        {
            lbCaseNoDisplayName.Text = caseNoDisplayName.Trim() + ": ";
            lbCaseNo.Text            = patient.GetCaseNumber() ?? "unknown";
        }

        // Set NHS number
        string nhsNumberDisplayName = PharmacyCultureInfo.NHSNumberDisplayName;
        if (!string.IsNullOrEmpty(nhsNumberDisplayName) && !nhsNumberDisplayName.EqualsNoCase(caseNoDisplayName))
        {
            lbNHSNumberDisplayName.Text = nhsNumberDisplayName.Trim() + ": ";
            lbNHSNumber.Text            = patient.GetNHSNumber() ?? "unknown";
        }
        else
        {
            lbNHSNumber.Visible = lbNHSNumberDisplayName.Visible = false;
        }
    }
}