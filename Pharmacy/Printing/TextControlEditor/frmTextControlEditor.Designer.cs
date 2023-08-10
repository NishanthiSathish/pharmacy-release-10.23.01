using System.Windows.Forms;
namespace TextControlEditorPharmacyClient
{
    partial class frmTextControlEditor
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

        #region Windows Form Designer generated code

        /// <summary>
        /// Required method for Designer support - do not modify
        /// the contents of this method with the code editor.
        /// </summary>
        private void InitializeComponent()
        {
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(frmTextControlEditor));
            this.ribbon1 = new TXTextControl.Windows.Forms.Ribbon.Ribbon();
            this.mnuNew = new TXTextControl.Windows.Forms.Ribbon.RibbonButton();
            this.mnuPrint = new TXTextControl.Windows.Forms.Ribbon.RibbonButton();
            this.mnuPrintPreview = new TXTextControl.Windows.Forms.Ribbon.RibbonButton();
            this.m_ribbonSeperator1 = new TXTextControl.Windows.Forms.Ribbon.RibbonSeperator();
            this.mnuSaveAndExit = new TXTextControl.Windows.Forms.Ribbon.RibbonButton();
            this.mnuExit = new TXTextControl.Windows.Forms.Ribbon.RibbonButton();
            this.ribbonFormattingTab1 = new TXTextControl.Windows.Forms.Ribbon.RibbonFormattingTab();
            this.ribbonInsertTab1 = new TXTextControl.Windows.Forms.Ribbon.RibbonInsertTab();
            this.ribbonPageLayoutTab1 = new TXTextControl.Windows.Forms.Ribbon.RibbonPageLayoutTab();
            this.ribbonViewTab1 = new TXTextControl.Windows.Forms.Ribbon.RibbonViewTab();
            this.m_horizontalRulerBar = new TXTextControl.RulerBar();
            this.m_statusBar = new TXTextControl.StatusBar();
            this.m_verticalRulerBar = new TXTextControl.RulerBar();
            this.mnuBtnDelete = new TXTextControl.Windows.Forms.Ribbon.RibbonButton();
            this.mnuBtninsertDate = new TXTextControl.Windows.Forms.Ribbon.RibbonButton();
            this.mnuBtnInsertTime = new TXTextControl.Windows.Forms.Ribbon.RibbonButton();
            this.textControl1 = new TXTextControl.TextControl();
            this.ribbon1.SuspendLayout();
            this.SuspendLayout();
            // 
            // ribbon1
            // 
            this.ribbon1.ApplicationMenuItems.AddRange(new System.Windows.Forms.Control[] {
            this.mnuNew,
            this.mnuPrint,
            this.mnuPrintPreview,
            this.m_ribbonSeperator1,
            this.mnuSaveAndExit,
            this.mnuExit});
            this.ribbon1.Controls.Add(this.ribbonFormattingTab1);
            this.ribbon1.Controls.Add(this.ribbonInsertTab1);
            this.ribbon1.Controls.Add(this.ribbonPageLayoutTab1);
            this.ribbon1.Controls.Add(this.ribbonViewTab1);
            this.ribbon1.Dock = System.Windows.Forms.DockStyle.Top;
            this.ribbon1.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.ribbon1.HotTrack = true;
            this.ribbon1.Location = new System.Drawing.Point(0, 31);
            this.ribbon1.MaximumSize = new System.Drawing.Size(2000, 2000);
            this.ribbon1.MinimumSize = new System.Drawing.Size(10, 10);
            this.ribbon1.Name = "ribbon1";
            this.ribbon1.SelectedIndex = 3;
            this.ribbon1.Size = new System.Drawing.Size(1259, 118);
            this.ribbon1.TabIndex = 1;
            this.ribbon1.Text = "ribbon1";
            // 
            // mnuNew
            // 
            this.mnuNew.BackColor = System.Drawing.Color.Transparent;
            this.mnuNew.Dock = System.Windows.Forms.DockStyle.Top;
            this.mnuNew.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.mnuNew.KeyTip = "";
            this.mnuNew.Location = new System.Drawing.Point(0, 0);
            this.mnuNew.Margin = new System.Windows.Forms.Padding(0, 0, 1, 0);
            this.mnuNew.Name = "mnuNew";
            this.mnuNew.Size = new System.Drawing.Size(211, 38);
            this.mnuNew.SmallIcon = ((System.Drawing.Image)(resources.GetObject("mnuNew.SmallIcon")));
            this.mnuNew.TabIndex = 0;
            this.mnuNew.Text = "New";
            // 
            // mnuPrint
            // 
            this.mnuPrint.BackColor = System.Drawing.Color.Transparent;
            this.mnuPrint.Dock = System.Windows.Forms.DockStyle.Top;
            this.mnuPrint.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.mnuPrint.KeyTip = "P";
            this.mnuPrint.Location = new System.Drawing.Point(0, 38);
            this.mnuPrint.Margin = new System.Windows.Forms.Padding(0, 0, 1, 0);
            this.mnuPrint.Name = "mnuPrint";
            this.mnuPrint.Size = new System.Drawing.Size(211, 38);
            this.mnuPrint.TabIndex = 0;
            this.mnuPrint.Text = "Print";
            // 
            // mnuPrintPreview
            // 
            this.mnuPrintPreview.BackColor = System.Drawing.Color.Transparent;
            this.mnuPrintPreview.Dock = System.Windows.Forms.DockStyle.Top;
            this.mnuPrintPreview.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.mnuPrintPreview.KeyTip = "";
            this.mnuPrintPreview.Location = new System.Drawing.Point(0, 76);
            this.mnuPrintPreview.Margin = new System.Windows.Forms.Padding(0, 0, 1, 0);
            this.mnuPrintPreview.Name = "mnuPrintPreview";
            this.mnuPrintPreview.Size = new System.Drawing.Size(211, 38);
            this.mnuPrintPreview.TabIndex = 0;
            this.mnuPrintPreview.Text = "Print Preview";
            // 
            // m_ribbonSeperator1
            // 
            this.m_ribbonSeperator1.BackColor = System.Drawing.Color.Transparent;
            this.m_ribbonSeperator1.Dock = System.Windows.Forms.DockStyle.Top;
            this.m_ribbonSeperator1.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.m_ribbonSeperator1.Location = new System.Drawing.Point(0, 114);
            this.m_ribbonSeperator1.Margin = new System.Windows.Forms.Padding(0, 0, 1, 0);
            this.m_ribbonSeperator1.Name = "m_ribbonSeperator1";
            this.m_ribbonSeperator1.Size = new System.Drawing.Size(211, 5);
            this.m_ribbonSeperator1.TabIndex = 0;
            this.m_ribbonSeperator1.TabStop = false;
            this.m_ribbonSeperator1.Text = "ribbonSeperator1";
            // 
            // mnuSaveAndExit
            // 
            this.mnuSaveAndExit.BackColor = System.Drawing.Color.Transparent;
            this.mnuSaveAndExit.Dock = System.Windows.Forms.DockStyle.Top;
            this.mnuSaveAndExit.Enabled = false;
            this.mnuSaveAndExit.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.mnuSaveAndExit.KeyTip = "S";
            this.mnuSaveAndExit.Location = new System.Drawing.Point(0, 119);
            this.mnuSaveAndExit.Margin = new System.Windows.Forms.Padding(0, 0, 1, 0);
            this.mnuSaveAndExit.Name = "mnuSaveAndExit";
            this.mnuSaveAndExit.Size = new System.Drawing.Size(211, 38);
            this.mnuSaveAndExit.TabIndex = 0;
            this.mnuSaveAndExit.Text = "Save and Exit";
            // 
            // mnuExit
            // 
            this.mnuExit.BackColor = System.Drawing.Color.Transparent;
            this.mnuExit.Dock = System.Windows.Forms.DockStyle.Top;
            this.mnuExit.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.mnuExit.KeyTip = "X";
            this.mnuExit.Location = new System.Drawing.Point(0, 157);
            this.mnuExit.Margin = new System.Windows.Forms.Padding(0, 0, 1, 0);
            this.mnuExit.Name = "mnuExit";
            this.mnuExit.Size = new System.Drawing.Size(211, 38);
            this.mnuExit.TabIndex = 0;
            this.mnuExit.Text = "Exit";
            // 
            // ribbonFormattingTab1
            // 
            this.ribbonFormattingTab1.Location = new System.Drawing.Point(4, 25);
            this.ribbonFormattingTab1.Name = "ribbonFormattingTab1";
            this.ribbonFormattingTab1.Size = new System.Drawing.Size(1251, 89);
            this.ribbonFormattingTab1.TabIndex = 1;
            // 
            // ribbonInsertTab1
            // 
            this.ribbonInsertTab1.Location = new System.Drawing.Point(4, 25);
            this.ribbonInsertTab1.Name = "ribbonInsertTab1";
            this.ribbonInsertTab1.Size = new System.Drawing.Size(1251, 89);
            this.ribbonInsertTab1.TabIndex = 2;
            // 
            // ribbonPageLayoutTab1
            // 
            this.ribbonPageLayoutTab1.Location = new System.Drawing.Point(4, 24);
            this.ribbonPageLayoutTab1.Name = "ribbonPageLayoutTab1";
            this.ribbonPageLayoutTab1.Size = new System.Drawing.Size(1251, 90);
            this.ribbonPageLayoutTab1.TabIndex = 3;
            // 
            // ribbonViewTab1
            // 
            this.ribbonViewTab1.Location = new System.Drawing.Point(4, 25);
            this.ribbonViewTab1.Name = "ribbonViewTab1";
            this.ribbonViewTab1.Size = new System.Drawing.Size(1251, 89);
            this.ribbonViewTab1.TabIndex = 4;
            // 
            // m_horizontalRulerBar
            // 
            this.m_horizontalRulerBar.Dock = System.Windows.Forms.DockStyle.Top;
            this.m_horizontalRulerBar.Location = new System.Drawing.Point(25, 149);
            this.m_horizontalRulerBar.Name = "m_horizontalRulerBar";
            this.m_horizontalRulerBar.Size = new System.Drawing.Size(1234, 25);
            this.m_horizontalRulerBar.TabIndex = 5;
            // 
            // m_statusBar
            // 
            this.m_statusBar.BackColor = System.Drawing.SystemColors.Control;
            this.m_statusBar.ColumnText = "Column";
            this.m_statusBar.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.m_statusBar.LineText = "Line: ";
            this.m_statusBar.Location = new System.Drawing.Point(25, 1070);
            this.m_statusBar.Name = "m_statusBar";
            this.m_statusBar.PageText = "Page";
            this.m_statusBar.SectionText = "Section";
            this.m_statusBar.Size = new System.Drawing.Size(1234, 22);
            this.m_statusBar.TabIndex = 11;
            // 
            // m_verticalRulerBar
            // 
            this.m_verticalRulerBar.Alignment = TXTextControl.RulerBarAlignment.Left;
            this.m_verticalRulerBar.Dock = System.Windows.Forms.DockStyle.Left;
            this.m_verticalRulerBar.Location = new System.Drawing.Point(0, 149);
            this.m_verticalRulerBar.Name = "m_verticalRulerBar";
            this.m_verticalRulerBar.Size = new System.Drawing.Size(25, 943);
            this.m_verticalRulerBar.TabIndex = 4;
            this.m_verticalRulerBar.Text = "rulerBar2";
            // 
            // mnuBtnDelete
            // 
            this.mnuBtnDelete.BackColor = System.Drawing.Color.Transparent;
            this.mnuBtnDelete.Dock = System.Windows.Forms.DockStyle.Top;
            this.mnuBtnDelete.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.mnuBtnDelete.KeyTip = "";
            this.mnuBtnDelete.Location = new System.Drawing.Point(0, 0);
            this.mnuBtnDelete.Margin = new System.Windows.Forms.Padding(0, 0, 1, 0);
            this.mnuBtnDelete.Name = "mnuBtnDelete";
            this.mnuBtnDelete.Size = new System.Drawing.Size(191, 38);
            this.mnuBtnDelete.SmallIcon = ((System.Drawing.Image)(resources.GetObject("mnuBtnDelete.SmallIcon")));
            this.mnuBtnDelete.TabIndex = 0;
            this.mnuBtnDelete.Text = "Delete selection";
            // 
            // mnuBtninsertDate
            // 
            this.mnuBtninsertDate.BackColor = System.Drawing.Color.Transparent;
            this.mnuBtninsertDate.Dock = System.Windows.Forms.DockStyle.Top;
            this.mnuBtninsertDate.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.mnuBtninsertDate.KeyTip = "";
            this.mnuBtninsertDate.Location = new System.Drawing.Point(0, 0);
            this.mnuBtninsertDate.Margin = new System.Windows.Forms.Padding(0, 0, 1, 0);
            this.mnuBtninsertDate.Name = "mnuBtninsertDate";
            this.mnuBtninsertDate.Size = new System.Drawing.Size(191, 38);
            this.mnuBtninsertDate.SmallIcon = ((System.Drawing.Image)(resources.GetObject("mnuBtninsertDate.SmallIcon")));
            this.mnuBtninsertDate.TabIndex = 0;
            this.mnuBtninsertDate.Text = "Insert Date";
            // 
            // mnuBtnInsertTime
            // 
            this.mnuBtnInsertTime.BackColor = System.Drawing.Color.Transparent;
            this.mnuBtnInsertTime.Dock = System.Windows.Forms.DockStyle.Top;
            this.mnuBtnInsertTime.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.mnuBtnInsertTime.KeyTip = "";
            this.mnuBtnInsertTime.Location = new System.Drawing.Point(0, 0);
            this.mnuBtnInsertTime.Margin = new System.Windows.Forms.Padding(0, 0, 1, 0);
            this.mnuBtnInsertTime.Name = "mnuBtnInsertTime";
            this.mnuBtnInsertTime.Size = new System.Drawing.Size(191, 38);
            this.mnuBtnInsertTime.SmallIcon = ((System.Drawing.Image)(resources.GetObject("mnuBtnInsertTime.SmallIcon")));
            this.mnuBtnInsertTime.TabIndex = 0;
            this.mnuBtnInsertTime.Text = "Insert Time";
            // 
            // textControl1
            // 
            this.textControl1.AllowDrag = true;
            this.textControl1.AllowDrop = true;
            this.textControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textControl1.DocumentTargetMarkers = true;
            this.textControl1.Font = new System.Drawing.Font("Arial", 10F);
            this.textControl1.HideSelection = false;
            this.textControl1.Location = new System.Drawing.Point(25, 174);
            this.textControl1.Name = "textControl1";
            this.textControl1.Ribbon = this.ribbon1;
            this.textControl1.RulerBar = this.m_horizontalRulerBar;
            this.textControl1.Size = new System.Drawing.Size(1234, 896);
            this.textControl1.StatusBar = this.m_statusBar;
            this.textControl1.TabIndex = 12;
            this.textControl1.UserNames = null;
            this.textControl1.VerticalRulerBar = this.m_verticalRulerBar;
            this.textControl1.Changed += new System.EventHandler(this.textControl1_Changed);
            this.textControl1.PageFormatChanged += new System.EventHandler(this.textControl1_PageFormatChanged);
            this.textControl1.PropertyChanged += new System.ComponentModel.PropertyChangedEventHandler(this.textControl1_PropertyChanged);
            this.textControl1.KeyDown += new System.Windows.Forms.KeyEventHandler(this.textControl1_KeyDown);
            // 
            // frmTextControlEditor
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.ClientSize = new System.Drawing.Size(1259, 1092);
            this.Controls.Add(this.textControl1);
            this.Controls.Add(this.m_statusBar);
            this.Controls.Add(this.m_horizontalRulerBar);
            this.Controls.Add(this.m_verticalRulerBar);
            this.Controls.Add(this.ribbon1);
            this.MaximizeBox = false;
            this.MaximumSize = new System.Drawing.Size(2000, 2000);
            this.MinimizeBox = false;
            this.MinimumSize = new System.Drawing.Size(16, 39);
            this.Name = "frmTextControlEditor";
            this.WindowState = System.Windows.Forms.FormWindowState.Maximized;
            this.FormClosing += new System.Windows.Forms.FormClosingEventHandler(this.frmTextControlEditor_FormClosing);
            this.FormClosed += new System.Windows.Forms.FormClosedEventHandler(this.frmTextControlEditor_FormClosed);
            this.Load += new System.EventHandler(this.frmTextControlEditor_Load);
            this.ribbon1.ResumeLayout(false);
            this.ResumeLayout(false);
            this.PerformLayout();

        }

        #endregion

        private TXTextControl.Windows.Forms.Ribbon.Ribbon ribbon1;
        private TXTextControl.Windows.Forms.Ribbon.RibbonButton mnuNew;
        private TXTextControl.Windows.Forms.Ribbon.RibbonButton mnuBtnDelete;
        private TXTextControl.Windows.Forms.Ribbon.RibbonSeperator m_ribbonSeperator1;
        public TXTextControl.Windows.Forms.Ribbon.RibbonButton mnuSaveAndExit;
        private TXTextControl.Windows.Forms.Ribbon.RibbonButton mnuPrint;
        public TXTextControl.Windows.Forms.Ribbon.RibbonButton mnuPrintPreview;
        private TXTextControl.Windows.Forms.Ribbon.RibbonButton mnuExit;
        private TXTextControl.Windows.Forms.Ribbon.RibbonButton mnuBtninsertDate;
        private TXTextControl.Windows.Forms.Ribbon.RibbonButton mnuBtnInsertTime;
        private TXTextControl.Windows.Forms.Ribbon.RibbonFormattingTab ribbonFormattingTab1;
        private TXTextControl.Windows.Forms.Ribbon.RibbonInsertTab ribbonInsertTab1;
        private TXTextControl.Windows.Forms.Ribbon.RibbonPageLayoutTab ribbonPageLayoutTab1;
        private TXTextControl.Windows.Forms.Ribbon.RibbonViewTab ribbonViewTab1;
        private TXTextControl.StatusBar m_statusBar;
        private TXTextControl.RulerBar m_horizontalRulerBar;
        private TXTextControl.RulerBar m_verticalRulerBar;
        public TXTextControl.TextControl textControl1;
    }
}
