/***********************************************
 * Read/WRite configurration XML
 * 
 * 1) Admin install Client MSI
 * 2) Run ClientConiguration.exe, update Configuration.xml file
 * 3) Remote run clinent install msi, reads configuration xml
 * 
 * Use relative path to Resources directory
 *
 ************************************************/

using System;
using System.IO;
using System.Drawing;
using System.Collections;
using System.ComponentModel;
using System.Windows.Forms;
using System.Data;

namespace ClientConfiguration
{
    /// <summary>
    /// Summary description for Form1.
    /// </summary>
    public class frmClientConfiguration : System.Windows.Forms.Form
    {
        private System.Windows.Forms.Button button1;
        private System.Windows.Forms.Button button2;

        private Configuration cfg_data;
        private string ConfigurationXMLPath = null;	//full path to configuration XML file gathered from the command line
        private string ConfigurationXMLFile = "ClientInstallConfiguration.xml";
        private System.Windows.Forms.GroupBox groupBox1;
        private System.Windows.Forms.TextBox tbWebSiteName;
        private System.Windows.Forms.TextBox tbWebServerName;
        private System.Windows.Forms.Label label3;
        private System.Windows.Forms.Label label2;
        private CheckBox cbUseHttps;

        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.Container components = null;

        public frmClientConfiguration()
        {
            InitializeComponent();
            this.ConfigurationXMLPath = Directory.GetCurrentDirectory() + "\\Resources\\" + ConfigurationXMLFile;
            cfg_data = new Configuration(this.ConfigurationXMLPath);	//load XML file
            FillClientControls();
        }
        //display the data
        private void FillClientControls()
        {
            tbWebServerName.Text = cfg_data.WebServer;
            tbWebSiteName.Text = cfg_data.WebSite;

            //+ GB TFS 83989
            bool useHttps = true;
            Boolean.TryParse(cfg_data.UseHTTPS, out useHttps);
            this.cbUseHttps.Checked = useHttps;
        }
        //update data from controls, write to XML file
        private void GetClientControlsData()
        {
            cfg_data.WebServer = tbWebServerName.Text;
            cfg_data.WebSite = tbWebSiteName.Text;
            cfg_data.UseHTTPS = this.cbUseHttps.Checked.ToString();  //+ GB TFS 83989

            cfg_data.WriteConfiguration();
        }

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        protected override void Dispose(bool disposing)
        {
            if (disposing)
            {
                if (components != null)
                {
                    components.Dispose();
                }
            }
            base.Dispose(disposing);
        }

        #region Windows Form Designer generated code
        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.button1 = new System.Windows.Forms.Button();
            this.button2 = new System.Windows.Forms.Button();
            this.groupBox1 = new System.Windows.Forms.GroupBox();
            this.cbUseHttps = new System.Windows.Forms.CheckBox();
            this.tbWebSiteName = new System.Windows.Forms.TextBox();
            this.tbWebServerName = new System.Windows.Forms.TextBox();
            this.label3 = new System.Windows.Forms.Label();
            this.label2 = new System.Windows.Forms.Label();
            this.groupBox1.SuspendLayout();
            this.SuspendLayout();
            // 
            // button1
            // 
            this.button1.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.button1.DialogResult = System.Windows.Forms.DialogResult.OK;
            this.button1.Location = new System.Drawing.Point(324, 138);
            this.button1.Name = "button1";
            this.button1.Size = new System.Drawing.Size(75, 23);
            this.button1.TabIndex = 8;
            this.button1.Text = "OK";
            this.button1.Click += new System.EventHandler(this.button1_Click);
            // 
            // button2
            // 
            this.button2.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.button2.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.button2.Location = new System.Drawing.Point(405, 138);
            this.button2.Name = "button2";
            this.button2.Size = new System.Drawing.Size(75, 23);
            this.button2.TabIndex = 9;
            this.button2.Text = "Cancel";
            this.button2.Click += new System.EventHandler(this.button2_Click);
            // 
            // groupBox1
            // 
            this.groupBox1.Anchor = ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom) 
            | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.groupBox1.Controls.Add(this.cbUseHttps);
            this.groupBox1.Controls.Add(this.tbWebSiteName);
            this.groupBox1.Controls.Add(this.tbWebServerName);
            this.groupBox1.Controls.Add(this.label3);
            this.groupBox1.Controls.Add(this.label2);
            this.groupBox1.Location = new System.Drawing.Point(16, 24);
            this.groupBox1.Name = "groupBox1";
            this.groupBox1.Size = new System.Drawing.Size(464, 108);
            this.groupBox1.TabIndex = 10;
            this.groupBox1.TabStop = false;
            this.groupBox1.Text = "Details for Client";
            // 
            // cbUseHttps
            // 
            this.cbUseHttps.AutoSize = true;
            this.cbUseHttps.Location = new System.Drawing.Point(56, 82);
            this.cbUseHttps.Name = "cbUseHttps";
            this.cbUseHttps.RightToLeft = System.Windows.Forms.RightToLeft.Yes;
            this.cbUseHttps.Size = new System.Drawing.Size(93, 17);
            this.cbUseHttps.TabIndex = 16;
            this.cbUseHttps.Text = " ?Use HTTPS";
            this.cbUseHttps.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.cbUseHttps.UseVisualStyleBackColor = true;
            // 
            // tbWebSiteName
            // 
            this.tbWebSiteName.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tbWebSiteName.Location = new System.Drawing.Point(136, 56);
            this.tbWebSiteName.Name = "tbWebSiteName";
            this.tbWebSiteName.Size = new System.Drawing.Size(312, 20);
            this.tbWebSiteName.TabIndex = 11;
            // 
            // tbWebServerName
            // 
            this.tbWebServerName.Anchor = ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Left) 
            | System.Windows.Forms.AnchorStyles.Right)));
            this.tbWebServerName.Location = new System.Drawing.Point(136, 32);
            this.tbWebServerName.Name = "tbWebServerName";
            this.tbWebServerName.Size = new System.Drawing.Size(312, 20);
            this.tbWebServerName.TabIndex = 9;
            // 
            // label3
            // 
            this.label3.Location = new System.Drawing.Point(28, 56);
            this.label3.Name = "label3";
            this.label3.Size = new System.Drawing.Size(100, 16);
            this.label3.TabIndex = 10;
            this.label3.Text = "Website Name";
            this.label3.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.label3.Click += new System.EventHandler(this.label3_Click);
            // 
            // label2
            // 
            this.label2.Location = new System.Drawing.Point(28, 32);
            this.label2.Name = "label2";
            this.label2.Size = new System.Drawing.Size(100, 16);
            this.label2.TabIndex = 8;
            this.label2.Text = "Webserver Name";
            this.label2.TextAlign = System.Drawing.ContentAlignment.MiddleRight;
            this.label2.Click += new System.EventHandler(this.label2_Click);
            // 
            // frmClientConfiguration
            // 
            this.AcceptButton = this.button1;
            this.AutoScaleBaseSize = new System.Drawing.Size(5, 13);
            this.CancelButton = this.button2;
            this.ClientSize = new System.Drawing.Size(496, 173);
            this.Controls.Add(this.groupBox1);
            this.Controls.Add(this.button2);
            this.Controls.Add(this.button1);
            this.Name = "frmClientConfiguration";
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterScreen;
            this.Text = "Client Configuration";
            this.Load += new System.EventHandler(this.frmClientConfiguration_Load);
            this.groupBox1.ResumeLayout(false);
            this.groupBox1.PerformLayout();
            this.ResumeLayout(false);

        }
        #endregion

        /// <summary>
        /// The main entry point for the application.
        /// Called with path to XML file to edit
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            Application.Run(new frmClientConfiguration());
        }
        //OK Pressed
        private void button1_Click(object sender, System.EventArgs e)
        {
            GetClientControlsData();
            Application.Exit();
        }
        //Client Pressed
        private void button2_Click(object sender, System.EventArgs e)
        {
            Application.Exit();
        }

        private void frmClientConfiguration_Load(object sender, System.EventArgs e)
        {

        }

        private void label2_Click(object sender, System.EventArgs e)
        {

        }

        private void label3_Click(object sender, System.EventArgs e)
        {

        }

        private void label4_Click(object sender, System.EventArgs e)
        {

        }
    }
}
