namespace TextControlEditorWebClient
{
    partial class InsertDataField
    {
        /// <summary>
        /// Required designer variable.
        /// </summary>
        private System.ComponentModel.IContainer components = null;

        /// <summary>
        /// Clean up any resources being used.
        /// </summary>
        /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
        protected override void Dispose(bool disposing)
        {
            if (disposing && (components != null))
            {
                components.Dispose();
            }
            base.Dispose(disposing);
        }



        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            this.textControl2 = new TXTextControl.TextControl();
            this.m_btnOK = new System.Windows.Forms.Button();
            this.m_btnCancel = new System.Windows.Forms.Button();
            this.listBox1 = new System.Windows.Forms.ListBox();
            this.SuspendLayout();
            // 
            // textControl2
            // 
            this.textControl2.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textControl2.Font = new System.Drawing.Font("Arial", 10F);
            this.textControl2.Location = new System.Drawing.Point(7, 7);
            this.textControl2.Name = "textControl2";
            this.textControl2.PageMargins.Bottom = 78.75D;
            this.textControl2.PageMargins.Left = 78.75D;
            this.textControl2.PageMargins.Right = 78.75D;
            this.textControl2.PageMargins.Top = 78.75D;
            this.textControl2.PageSize.Height = 1169.31D;
            this.textControl2.PageSize.Width = 826.81D;
            this.textControl2.Size = new System.Drawing.Size(310, 158);
            this.textControl2.TabIndex = 2;
            this.textControl2.Text = "textControl2";
            this.textControl2.UserNames = null;
            // 
            // m_btnOK
            // 
            this.m_btnOK.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.m_btnOK.AutoSize = true;
            this.m_btnOK.Location = new System.Drawing.Point(21, 184);
            this.m_btnOK.Name = "m_btnOK";
            this.m_btnOK.Size = new System.Drawing.Size(64, 27);
            this.m_btnOK.TabIndex = 5;
            this.m_btnOK.Text = "Insert";
            this.m_btnOK.UseVisualStyleBackColor = true;
            this.m_btnOK.Click += new System.EventHandler(this.BtnOK_Click);
            // 
            // m_btnCancel
            // 
            this.m_btnCancel.Anchor = ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Right)));
            this.m_btnCancel.AutoSize = true;
            this.m_btnCancel.DialogResult = System.Windows.Forms.DialogResult.Cancel;
            this.m_btnCancel.Location = new System.Drawing.Point(112, 184);
            this.m_btnCancel.Name = "m_btnCancel";
            this.m_btnCancel.Size = new System.Drawing.Size(75, 27);
            this.m_btnCancel.TabIndex = 6;
            this.m_btnCancel.Text = "Close";
            this.m_btnCancel.UseVisualStyleBackColor = true;
            // 
            // listBox1
            // 
            this.listBox1.FormattingEnabled = true;
            this.listBox1.Items.AddRange(new object[] {
            "{Page}",
            "{Page Total}"});
            this.listBox1.Location = new System.Drawing.Point(21, 21);
            this.listBox1.Name = "listBox1";
            this.listBox1.Size = new System.Drawing.Size(166, 134);
            this.listBox1.TabIndex = 7;
            this.listBox1.SelectedIndex = 0;
            // 
            // InsertDataField
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.AutoSizeMode = System.Windows.Forms.AutoSizeMode.GrowAndShrink;
            this.ClientSize = new System.Drawing.Size(210, 231);
            this.Controls.Add(this.listBox1);
            this.Controls.Add(this.m_btnOK);
            this.Controls.Add(this.m_btnCancel);
            this.MaximizeBox = false;
            this.MinimizeBox = false;
            this.Name = "InsertDataField";
            this.Padding = new System.Windows.Forms.Padding(7);
            this.ShowInTaskbar = false;
            this.StartPosition = System.Windows.Forms.FormStartPosition.CenterParent;
            this.Load += new System.EventHandler(this.Form1_Load);
            this.ResumeLayout(false);
            this.PerformLayout();

        }
        private TXTextControl.TextControl textControl2;
        private System.Windows.Forms.Button m_btnOK;
        private System.Windows.Forms.Button m_btnCancel;
        private System.Windows.Forms.ListBox listBox1;
    }
}