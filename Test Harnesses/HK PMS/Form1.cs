// -----------------------------------------------------------------------
// <copyright file="Form1.cs" company="Emis Health">
//   Copyright (c) Emis Health Plc. All rights reserved.
// </copyright>
// <summary>
// This is a test harness that simulates the Hong Kong PMS application
// The user can enter various bits for patient information, and the 
// launch the ICW either at a PN, or (CIVAS) dispensing desktop
//
// The process is as follows (mainly done in the HAP form)
// Perform active directory logon using trusted.aspx
// Send patient\prescription information to EIE 
// (this will also set the desktop\patient\prescription into state
// Launch the ICW using the trusted.aspx
// Perform logout using trusted.aspx
// 
//  Modification History:
//  15Oct15 XN Created 77977 
// </summary
// -----------------------------------------------------------------------
namespace HK_PMS
{
using System;
using System.IO;
using System.Linq;
using System.Windows.Forms;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.icwdatalayer;
using ascribe.pharmacy.shared;

    /// <summary>User's preferred language type</summary>
    public enum LanguageType
    {
        /// <summary>Chinese language</summary>
        [EnumDBCode("C")]
        Chinese,

        /// <summary>English language</summary>
        [EnumDBCode("E")]
        English
    }

    /// <summary>Code for the Hong Kong hospital</summary>
    public enum HAHospitalCode
    {
        KWH,
        PWH,
        QEH,
        QMH,
        UCH,
    }

    /// <summary>
    /// Holds all the information from this Form 
    /// Used for sending to HAP and saving to file
    /// </summary>
    public struct PatientPrescriptionDetails
    {
        public HAHospitalCode HAHospitalCode;
        public string HospitalNumber;
        public string HKID;
        public string Forname;
        public string Surname;
        public GenderType Sex;
        public DateTime DOB;
        public string ChineseName;
        public LanguageType? languageType;
        public string EpisodeDescription;
        public DateTime EpisodeStartDate;
        public string WardCode;
        public string PatientCategory;
        public EpisodeType PatientStatus;
        public string MOCode;
        public string MOTitle;
        public string MOForname;
        public string MOSurname;
        public string SpecialtyCode;
        public string SpecialtyDesc;
        public string HAEpisodeKey;
        public int selectPMSPrescriptionID;
        public int existingPMSPrescriptionID;
        public string[] PNPMSPrescrpitions;
        public string bedNumber;

        public string ICWBaseURL;
        public string EIEBaseURL;
        public bool   UseEIE;
        public string PNDesktopName;
        public string CIVASDesktopName;

        public string CancelReason;
    }

    /// <summary>Main application start form</summary>
    public partial class Form1 : Form
    {
        /// <summary>file name used to save the users current values</summary>
        private static readonly string PatientDetailsFile = "PatientDetails.txt";

        public Form1()
        {
            InitializeComponent();
        }

        /// <summary>
        /// Called the form loaded
        /// Initialise the combo boxes
        /// </summary>
        /// <param name="sender">the sender</param>
        /// <param name="e">the event args</param>
        private void Form1_Load(object sender, EventArgs e)
        {
            this.cbSex.Items.Clear();
            this.cbSex.Items.AddRange(Enum.GetValues(typeof(GenderType)).OfType<object>().ToArray());
            this.cbSex.SelectedIndex = 0;

            this.cbLanguage.Items.Clear();
            this.cbLanguage.Items.AddRange(Enum.GetValues(typeof(LanguageType)).OfType<object>().ToArray());
            this.cbLanguage.SelectedIndex = 0;

            this.cbHAHospitalCode.Items.Clear();
            this.cbHAHospitalCode.Items.AddRange(Enum.GetValues(typeof(HAHospitalCode)).OfType<object>().ToArray());
            this.cbHAHospitalCode.SelectedIndex = 0;

            this.cbPatientCategory.Items.Clear();
            this.cbPatientCategory.Items.AddRange(Database.ExecuteSQLSingleField<string>("SELECT Code + ' - ' + Description FROM PatientCategory Order by Code").ToArray());
            this.cbPatientCategory.SelectedIndex = 0;

            this.cbPatientStatus.Items.Clear();
            this.cbPatientStatus.Items.Add(EpisodeType.InPatient);
            this.cbPatientStatus.Items.Add(EpisodeType.OutPatient);
            this.cbPatientStatus.Items.Add(EpisodeType.Discharge);
            this.cbPatientStatus.SelectedIndex = 0;

            // Get list of PN desktop names if there are any that end in "for PMS" then filter to just those, else use all
            this.cbPNDesktopName.Items.Clear();
            var desktopNames = Database.ExecuteSQLSingleField<string>("SELECT DISTINCT d.Description FROM Desktop d JOIN Window w ON d.DesktopID = w.DesktopID JOIN WindowParameter wp ON w.WindowID=wp.WindowID WHERE w.URL='PNWorklist' AND wp.Description='SelectEpisode' AND wp.Value='False'");
            if (desktopNames.Any(d => d.Contains(" for PMS ")))
            {
                desktopNames = desktopNames.Where(d => d.Contains(" for PMS "));
            }
            this.cbPNDesktopName.Items.AddRange(desktopNames.ToArray());

            // Get list of dispensing desktop names if there are any that end in "for PMS" then filter to just those, else use all
            this.cbCIVASDesktopName.Items.Clear();
            desktopNames = Database.ExecuteSQLSingleField<string>("SELECT DISTINCT d.Description FROM Desktop d JOIN Window w ON d.DesktopID = w.DesktopID WHERE w.URL='Dispensing'");
            if (desktopNames.Any(d => d.Contains(" for PMS ")))
            {
                desktopNames = desktopNames.Where(d => d.Contains(" for PMS "));
            }
            this.cbCIVASDesktopName.Items.AddRange(desktopNames.ToArray());

            this.LoadPatientDetails();
        }

        /// <summary>
        /// Called the CIVAS launch button is pressed
        /// Will save and validate the page
        /// the calls the HAP form to display the hap on a dispensing desktop
        /// </summary>
        /// <param name="sender">the sender</param>
        /// <param name="e">the event args</param>
        private void btnLaunch_Click(object sender, EventArgs e)
        {
            PatientPrescriptionDetails details = this.SavePatientDetails();
            if (this.Validate(isPrescriptionSelected: false))
            {
                HAP hap = new HAP(details, HAP.CallType.CIVAS);
                hap.ShowDialog();
            }
        }

        /// <summary>
        /// Called the PN Add button is pressed
        /// Creates new PM prescription ID
        /// Will save and validate the page
        /// the calls the HAP form to display the hap on a PN desktop
        /// </summary>
        /// <param name="sender">the sender</param>
        /// <param name="e">the event args</param>
        private void btnAdd_Click(object sender, EventArgs e)
        {
            PatientPrescriptionDetails details = this.SavePatientDetails();

            // Create new prescription
            details.selectPMSPrescriptionID = int.Parse(DateTime.Now.ToString("MMddHHmmss"));
            
            if (this.Validate(isPrescriptionSelected: false))
            {
                HAP hap = new HAP(details, HAP.CallType.PNNew);
                hap.ShowDialog();

                // Update list of prescriptions as if user cancelled then PMS prescription Id should be removed
                if (!string.IsNullOrEmpty(hap.PnDescription))
                {
                    this.lbPNPMSRegimen.Items.Add(details.selectPMSPrescriptionID + " - " + hap.PnDescription);
                    this.lbPNPMSRegimen.SelectedIndex = this.lbPNPMSRegimen.Items.Count - 1;
                }
            }

            // If prescription was cancelled then PMS prescription will be removed
            details = this.SavePatientDetails();
        }

        /// <summary>
        /// Called the PN New Supply Request button is pressed
        /// Creates new PM prescription ID
        /// Will save and validate the page
        /// the calls the HAP form to display the hap on a PN desktop
        /// </summary>
        /// <param name="sender">the sender</param>
        /// <param name="e">the event args</param>
        private void btnNSR_Click(object sender, EventArgs e)
        {
            PatientPrescriptionDetails details = this.SavePatientDetails();

            // Create new prescription
            details.existingPMSPrescriptionID = details.selectPMSPrescriptionID;
            details.selectPMSPrescriptionID   = int.Parse(DateTime.Now.ToString("MMddHHmmss"));
            
            if (this.Validate(isPrescriptionSelected: true))
            {
                HAP hap = new HAP(details, HAP.CallType.PNNewSupplyRequest);
                hap.ShowDialog();

                // Update list of prescriptions as if user cancelled then PMS prescription Id should be removed
                if (!string.IsNullOrEmpty(hap.PnDescription))
                {
                    this.lbPNPMSRegimen.Items.Add(details.selectPMSPrescriptionID + " - " + hap.PnDescription);
                    this.lbPNPMSRegimen.SelectedIndex = this.lbPNPMSRegimen.Items.Count - 1;
                }
            }

            // If prescription was cancelled then PMS prescription will be removed
            details = this.SavePatientDetails();
        }

        /// <summary>
        /// Called the PN View button is pressed
        /// Will save and validate the page
        /// the calls the HAP form to display the hap on a PN desktop
        /// </summary>
        /// <param name="sender">the sender</param>
        /// <param name="e">the event args</param>
        private void btnView_Click(object sender, EventArgs e)
        {
            PatientPrescriptionDetails details = this.SavePatientDetails();
            if (this.Validate(isPrescriptionSelected: true))
            {
                HAP hap = new HAP(details, HAP.CallType.PNView);
                hap.ShowDialog();
            }
        }

        /// <summary>
        /// Called the PN Modify button is pressed
        /// Will save and validate the page
        /// the calls the HAP form to display the hap on a PN desktop
        /// </summary>
        /// <param name="sender">the sender</param>
        /// <param name="e">the event args</param>
        private void btnModify_Click(object sender, EventArgs e)
        {
            PatientPrescriptionDetails details = this.SavePatientDetails();
            if (this.Validate(isPrescriptionSelected: true))
            {
                HAP hap = new HAP(details, HAP.CallType.PNModify);
                hap.ShowDialog();

                // Update list of prescriptions as if user cancelled then PMS prescription Id should be removed
                if (!string.IsNullOrEmpty(hap.PnDescription))
                {
                    this.lbPNPMSRegimen.Items[this.lbPNPMSRegimen.SelectedIndex] = details.selectPMSPrescriptionID + " - " + hap.PnDescription;
                }
            }
        }

        /// <summary>
        /// Called the PN Cancel button is pressed
        /// Will save and validate the page
        /// the calls the HAP form to display the hap on a PN desktop
        /// </summary>
        /// <param name="sender">the sender</param>
        /// <param name="e">the event args</param>
        private void btnCancel_Click(object sender, EventArgs e)
        {
            PatientPrescriptionDetails details = this.SavePatientDetails();

            if (this.cbUseEIE.Checked == false)
            {
                MessageBox.Show("Only supported when sending message via EIE");
                return;
            }

            var frm = new CancelReason();
            if (this.Validate(isPrescriptionSelected: true) && (frm.ShowDialog() == System.Windows.Forms.DialogResult.OK))
            {
                details.CancelReason = frm.tbReason.Text;

                HAP hap = new HAP(details, HAP.CallType.PNCancel);
                hap.ShowDialog();

                this.lbPNPMSRegimen.Items.RemoveAt(this.lbPNPMSRegimen.SelectedIndex);
                this.SavePatientDetails();
            }
        }

        /// <summary>
        /// Load in the user values from PatientDetails.txt JSON file
        /// 15Oct15 XN 77977
        /// </summary>
        private void LoadPatientDetails()
        {
            string path = Application.CommonAppDataPath + "\\" + PatientDetailsFile;
            if (!File.Exists(path))
                return;

            PatientPrescriptionDetails details = Newtonsoft.Json.JsonConvert.DeserializeObject<PatientPrescriptionDetails>(File.ReadAllText(path));

            this.tbHKID.Text                    = details.HKID;
            this.tbForename.Text                = details.Forname;
            this.tbSurname.Text                 = details.Surname;
            this.tbChineseName.Text             = details.ChineseName;
            this.cbSex.SelectedIndex            = this.cbSex.Items.OfType<GenderType>().ToList().IndexOf(details.Sex);
            this.dtpDOB.Value                   = details.DOB;
            this.cbLanguage.SelectedIndex       = details.languageType == null ? -1 : this.cbLanguage.Items.OfType<LanguageType>().ToList().IndexOf(details.languageType.Value);
            this.cbHAHospitalCode.SelectedIndex = this.cbHAHospitalCode.Items.OfType<HAHospitalCode>().ToList().IndexOf(details.HAHospitalCode);
            this.tbHospitalNumber.Text          = details.HospitalNumber;
            this.tbHAEpisodeKey.Text            = details.HAEpisodeKey;
            this.tbDescription.Text             = details.EpisodeDescription;
            this.dtpStartDate.Value             = details.EpisodeStartDate;
            this.tbSpecialityCode.Text          = details.SpecialtyCode;
            this.tbSpecialtyDescription.Text    = details.SpecialtyDesc;
            this.tbWardcode.Text                = details.WardCode;
            this.cbPatientCategory.SelectedIndex= this.cbPatientCategory.Items.OfType<string>().ToList().FindIndex(s => s == details.PatientCategory);
            this.cbPatientStatus.SelectedIndex  = Math.Max(this.cbPatientStatus.Items.OfType<EpisodeType>().ToList().IndexOf(details.PatientStatus), 0);
            this.tbMOCode.Text                  = details.MOCode;
            this.tbMOTitle.Text                 = details.MOTitle;    
            this.tbMOForename.Text              = details.MOForname;   
            this.tbMOSurname.Text               = details.MOSurname; 
            this.lbPNPMSRegimen.Items.Clear();
            this.lbPNPMSRegimen.Items.AddRange(details.PNPMSPrescrpitions.OfType<object>().ToArray());
            this.lbPNPMSRegimen.SelectedItem= details.selectPMSPrescriptionID;
            this.tbICWBaseURL.Text              = details.ICWBaseURL;
            this.tbBedNumber.Text               = details.bedNumber;
            this.cbPNDesktopName.SelectedIndex  = this.cbPNDesktopName.Items.OfType<string>().ToList().FindIndex(s => s.EqualsNoCase(details.PNDesktopName));
            this.cbCIVASDesktopName.SelectedIndex=this.cbCIVASDesktopName.Items.OfType<string>().ToList().FindIndex(s => s.EqualsNoCase(details.CIVASDesktopName));
            this.cbUseEIE.Checked              = details.UseEIE;
            this.tbEIEWebService.Text           = details.EIEBaseURL;
        }

        /// <summary>
        /// Saves user values to PatientDetails.txt JSON file
        /// 15Oct15 XN 77977
        /// </summary>
        private PatientPrescriptionDetails SavePatientDetails()
        {
            PatientPrescriptionDetails details = new PatientPrescriptionDetails();
            details.HKID                = this.tbHKID.Text;
            details.Forname             = this.tbForename.Text;
            details.Surname             = this.tbSurname.Text;
            details.ChineseName         = this.tbChineseName.Text;
            details.Sex                 = (GenderType)this.cbSex.SelectedItem;
            details.DOB                 = this.dtpDOB.Value;
            details.languageType        = (LanguageType?)this.cbLanguage.SelectedItem;
            details.HAHospitalCode      = (HAHospitalCode)this.cbHAHospitalCode.SelectedItem;
            details.HospitalNumber      = this.tbHospitalNumber.Text;
            details.HAEpisodeKey        = this.tbHAEpisodeKey.Text;
            details.EpisodeDescription  = this.tbDescription.Text;
            details.EpisodeStartDate    = this.dtpStartDate.Value;
            details.SpecialtyCode       = this.tbSpecialityCode.Text;
            details.SpecialtyDesc       = this.tbSpecialtyDescription.Text;
            details.WardCode            = this.tbWardcode.Text;
            details.PatientCategory     = this.cbPatientCategory.SelectedItem == null ? string.Empty : this.cbPatientCategory.SelectedItem.ToString();
            details.PatientStatus       = (EpisodeType)this.cbPatientStatus.SelectedItem;
            details.MOCode              = this.tbMOCode.Text;
            details.MOTitle             = this.tbMOTitle.Text;
            details.MOForname           = this.tbMOForename.Text;
            details.MOSurname           = this.tbMOSurname.Text;
            details.PNPMSPrescrpitions  = this.lbPNPMSRegimen.Items.Cast<string>().ToArray();
            details.selectPMSPrescriptionID= this.lbPNPMSRegimen.SelectedItem == null ? -1 : int.Parse(this.lbPNPMSRegimen.SelectedItem.ToString().Split('-')[0].Trim());
            details.ICWBaseURL          = this.tbICWBaseURL.Text;
            details.bedNumber           = this.tbBedNumber.Text;
            details.PNDesktopName       = (this.cbPNDesktopName.SelectedItem    ?? string.Empty).ToString();
            details.CIVASDesktopName    = (this.cbCIVASDesktopName.SelectedItem ?? string.Empty).ToString();
            details.UseEIE              = this.cbUseEIE.Checked;
            details.EIEBaseURL          = this.tbEIEWebService.Text;

            string path = Application.CommonAppDataPath + "\\" + PatientDetailsFile;
            File.WriteAllText(path, Newtonsoft.Json.JsonConvert.SerializeObject(details));

            return details;
        }

        /// <summary>Validate the form (before sent to EIE)</summary>
        /// <param name="isPrescriptionSelected">If prescription is selected</param>
        /// <returns>if data is valid</returns>
        private bool Validate(bool isPrescriptionSelected)
        {
            bool OK = true;

            OK = OK && XUtils.Validation.ValidateText(tbICWBaseURL, typeof(string), true);
            OK = OK && XUtils.Validation.ValidateComboBox(cbHAHospitalCode, true);
            OK = OK && XUtils.Validation.ValidateText(tbHospitalNumber, typeof(string), true, 12);
            if (OK && tbHospitalNumber.Text.Length != 12)
            {
                XUtils.Validation.ShowToolTip("Validation", "Hospital number must be 12 chars", tbHospitalNumber);
                OK = false;
            }
            OK = OK && XUtils.Validation.ValidateText(tbHKID, typeof(string), true, 10);
            OK = OK && XUtils.Validation.ValidateText(tbForename, typeof(string), true, 128);
            OK = OK && XUtils.Validation.ValidateText(tbSurname, typeof(string), true, 128);
            OK = OK && XUtils.Validation.ValidateComboBox(cbSex, true);
            if (OK && dtpDOB.Value > DateTime.Now)
            {
                XUtils.Validation.ShowToolTip("Validation", "Enter valid date", dtpDOB);
                OK = false;
            }
            OK = OK && XUtils.Validation.ValidateText(tbChineseName, typeof(string), false, 4);
            OK = OK && XUtils.Validation.ValidateComboBox(cbLanguage, true);
            OK = OK && XUtils.Validation.ValidateText(tbHAEpisodeKey, typeof(string), true, 8);
            OK = OK && XUtils.Validation.ValidateText(tbDescription, typeof(string), true, 128);
            if (OK && dtpStartDate.Value > DateTime.Now)
            {
                XUtils.Validation.ShowToolTip("Validation", "Enter valid date", dtpDOB);
                OK = false;
            }
            OK = OK && XUtils.Validation.ValidateText(tbWardcode, typeof(string), true, 8);

            if (OK)
            {
                bool hasValidWard = Database.ExecuteSQLScalar<int?>("SELECT TOP 1 1 FROM LocationAlias la JOIN AliasGroup ag ON la.AliasGroupID=ag.AliasGroupID AND la.[Default] = 1 WHERE ag.Description='WWardCodes' and la.Alias='{0}'", tbWardcode.Text).HasValue;
                if (!hasValidWard)
                {
                    XUtils.Validation.ShowToolTip("Validation", "Invalid ward code", tbWardcode);
                    OK = false;
                }
            }

            OK = OK && XUtils.Validation.ValidateComboBox(cbPatientCategory, true);
            OK = OK && XUtils.Validation.ValidateComboBox(cbPatientStatus, true);
            OK = OK && XUtils.Validation.ValidateText(tbMOCode, typeof(string), true, 12);
            OK = OK && XUtils.Validation.ValidateText(tbMOTitle, typeof(string), true, 5);
            OK = OK && XUtils.Validation.ValidateText(tbMOForename, typeof(string), true, 18);
            OK = OK && XUtils.Validation.ValidateText(tbMOSurname, typeof(string), true, 18);
            OK = OK && XUtils.Validation.ValidateText(tbSpecialityCode, typeof(string), false, 18);
            OK = OK && XUtils.Validation.ValidateText(tbSpecialtyDescription, typeof(string), false, 128);

            OK = OK && XUtils.Validation.ValidateListControl(lbPNPMSRegimen, isPrescriptionSelected);

            OK = OK && XUtils.Validation.ValidateComboBox(cbPNDesktopName, isPrescriptionSelected);
            OK = OK && XUtils.Validation.ValidateComboBox(cbCIVASDesktopName, !isPrescriptionSelected);

            return OK;
        }
    }
}
