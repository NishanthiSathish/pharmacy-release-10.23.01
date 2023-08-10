using System.Windows.Forms;
namespace TextControlEditorWebClient
{
	partial class TextUserControlEditor
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

		#region Component Designer generated code

		/// <summary> 
		/// Required method for Designer support - do not modify 
		/// the contents of this method with the code editor.
		/// </summary>
		private void InitializeComponent()
		{
            System.ComponentModel.ComponentResourceManager resources = new System.ComponentModel.ComponentResourceManager(typeof(TextUserControlEditor));
            this.mnuBtnNewFile = new System.Windows.Forms.ToolStripButton();
            this.mnuBtnOpenFile = new System.Windows.Forms.ToolStripButton();
            this.mnuBtnSave = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator1 = new System.Windows.Forms.ToolStripSeparator();
            this.mnuBtnPrint = new System.Windows.Forms.ToolStripButton();
            this.mnuBtnPrintPreview = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator2 = new System.Windows.Forms.ToolStripSeparator();
            this.mnuBtnDelete = new System.Windows.Forms.ToolStripButton();
            this.mnuBtnUndo = new System.Windows.Forms.ToolStripButton();
            this.mnuBtnRedo = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator4 = new System.Windows.Forms.ToolStripSeparator();
            this.toolStrip = new System.Windows.Forms.ToolStrip();
            this.mnuBtnSpelling = new System.Windows.Forms.ToolStripButton();
            this.mnuBtninsertDatafield = new System.Windows.Forms.ToolStripButton();
            this.mnuBtninsertDate = new System.Windows.Forms.ToolStripButton();
            this.mnuBtnInsertTime = new System.Windows.Forms.ToolStripButton();
            this.toolStripSeparator8 = new System.Windows.Forms.ToolStripSeparator();
            this.mnuBtnShowHeader = new System.Windows.Forms.ToolStripButton();
            this.mnuBtnShowFooter = new System.Windows.Forms.ToolStripButton();
            this.m_horizontalRulerBar = new TXTextControl.RulerBar();
            this.m_verticalRulerBar = new TXTextControl.RulerBar();
            this.m_statusBar = new TXTextControl.StatusBar();
            this.textControl1 = new TXTextControl.TextControl();
            this.ribbon1 = new TXTextControl.Windows.Forms.Ribbon.Ribbon();
            this.ribbonFormattingTab1 = new TXTextControl.Windows.Forms.Ribbon.RibbonFormattingTab();
            this.ribbonInsertTab1 = new TXTextControl.Windows.Forms.Ribbon.RibbonInsertTab();
            this.ribbonPageLayoutTab1 = new TXTextControl.Windows.Forms.Ribbon.RibbonPageLayoutTab();
            this.ribbonViewTab1 = new TXTextControl.Windows.Forms.Ribbon.RibbonViewTab();
            this.hidingMenu = new System.Windows.Forms.MenuStrip();
            this.mnuCut = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuCopy = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuPaste = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuSelectAll = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuFind = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuReplace = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuSave = new System.Windows.Forms.ToolStripMenuItem();
            this.mnuPrint = new System.Windows.Forms.ToolStripMenuItem();
            this.toolStrip.SuspendLayout();
            this.ribbon1.SuspendLayout();
            this.hidingMenu.SuspendLayout();
            this.SuspendLayout();
            // 
            // mnuBtnNewFile
            // 
            this.mnuBtnNewFile.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnNewFile.Image = global::TextControlEditorWebClient.Properties.Resources.newpage;
            this.mnuBtnNewFile.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnNewFile.Name = "mnuBtnNewFile";
            this.mnuBtnNewFile.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnNewFile.Text = "New document";
            this.mnuBtnNewFile.Click += new System.EventHandler(this.mnuBtnNewFile_Click);
            // 
            // mnuBtnOpenFile
            // 
            this.mnuBtnOpenFile.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnOpenFile.Image = global::TextControlEditorWebClient.Properties.Resources.open;
            this.mnuBtnOpenFile.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnOpenFile.Name = "mnuBtnOpenFile";
            this.mnuBtnOpenFile.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnOpenFile.Text = "Open document";
            this.mnuBtnOpenFile.ToolTipText = "Open document";
            this.mnuBtnOpenFile.Click += new System.EventHandler(this.mnuBtnOpenFile_Click);
            // 
            // mnuBtnSave
            // 
            this.mnuBtnSave.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnSave.Image = global::TextControlEditorWebClient.Properties.Resources.save;
            this.mnuBtnSave.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnSave.Name = "mnuBtnSave";
            this.mnuBtnSave.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnSave.Text = "Save document";
            this.mnuBtnSave.Click += new System.EventHandler(this.mnuBtnSave_Click);
            // 
            // toolStripSeparator1
            // 
            this.toolStripSeparator1.Name = "toolStripSeparator1";
            this.toolStripSeparator1.Size = new System.Drawing.Size(6, 25);
            // 
            // mnuBtnPrint
            // 
            this.mnuBtnPrint.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnPrint.Image = global::TextControlEditorWebClient.Properties.Resources.print;
            this.mnuBtnPrint.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnPrint.Name = "mnuBtnPrint";
            this.mnuBtnPrint.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnPrint.Text = "Print document";
            this.mnuBtnPrint.ToolTipText = "Print document";
            this.mnuBtnPrint.Click += new System.EventHandler(this.mnuBtnPrint_Click);
            // 
            // mnuBtnPrintPreview
            // 
            this.mnuBtnPrintPreview.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnPrintPreview.Image = global::TextControlEditorWebClient.Properties.Resources.printpreview;
            this.mnuBtnPrintPreview.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnPrintPreview.Name = "mnuBtnPrintPreview";
            this.mnuBtnPrintPreview.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnPrintPreview.Text = "Print preview";
            this.mnuBtnPrintPreview.ToolTipText = "Print preview";
            this.mnuBtnPrintPreview.Click += new System.EventHandler(this.mnuBtnPrintPreview_Click);
            // 
            // toolStripSeparator2
            // 
            this.toolStripSeparator2.Name = "toolStripSeparator2";
            this.toolStripSeparator2.Size = new System.Drawing.Size(6, 25);
            // 
            // mnuBtnDelete
            // 
            this.mnuBtnDelete.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnDelete.Image = global::TextControlEditorWebClient.Properties.Resources.delete;
            this.mnuBtnDelete.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnDelete.Name = "mnuBtnDelete";
            this.mnuBtnDelete.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnDelete.Text = "Delete selection";
            this.mnuBtnDelete.Click += new System.EventHandler(this.mnuBtnDelete_Click);
            // 
            // mnuBtnUndo
            // 
            this.mnuBtnUndo.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnUndo.Image = global::TextControlEditorWebClient.Properties.Resources.undo;
            this.mnuBtnUndo.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnUndo.Name = "mnuBtnUndo";
            this.mnuBtnUndo.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnUndo.Text = "Undo";
            this.mnuBtnUndo.ToolTipText = "Undo";
            this.mnuBtnUndo.Click += new System.EventHandler(this.mnuBtnUndo_Click);
            // 
            // mnuBtnRedo
            // 
            this.mnuBtnRedo.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnRedo.Image = global::TextControlEditorWebClient.Properties.Resources.redo;
            this.mnuBtnRedo.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnRedo.Name = "mnuBtnRedo";
            this.mnuBtnRedo.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnRedo.Text = "Redo";
            this.mnuBtnRedo.ToolTipText = "Redo";
            this.mnuBtnRedo.Click += new System.EventHandler(this.mnuBtnRedo_Click);
            // 
            // toolStripSeparator4
            // 
            this.toolStripSeparator4.Name = "toolStripSeparator4";
            this.toolStripSeparator4.Size = new System.Drawing.Size(6, 25);
            // 
            // toolStrip
            // 
            this.toolStrip.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mnuBtnNewFile,
            this.mnuBtnOpenFile,
            this.mnuBtnSave,
            this.toolStripSeparator1,
            this.mnuBtnPrint,
            this.mnuBtnPrintPreview,
            this.mnuBtnSpelling,
            this.toolStripSeparator2,
            this.mnuBtnUndo,
            this.mnuBtnRedo,
            this.mnuBtnDelete,
            this.toolStripSeparator4,
            this.mnuBtninsertDatafield,
            this.mnuBtninsertDate,
            this.mnuBtnInsertTime,
            this.toolStripSeparator8,
            this.mnuBtnShowHeader,
            this.mnuBtnShowFooter});
            this.toolStrip.Location = new System.Drawing.Point(0, 120);
            this.toolStrip.Name = "toolStrip";
            this.toolStrip.Size = new System.Drawing.Size(978, 25);
            this.toolStrip.TabIndex = 6;
            this.toolStrip.Text = "toolStrip";
            // 
            // mnuBtnSpelling
            // 
            this.mnuBtnSpelling.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnSpelling.Image = global::TextControlEditorWebClient.Properties.Resources.spelling;
            this.mnuBtnSpelling.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnSpelling.Name = "mnuBtnSpelling";
            this.mnuBtnSpelling.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnSpelling.Text = "Spelling";
            // 
            // mnuBtninsertDatafield
            // 
            this.mnuBtninsertDatafield.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtninsertDatafield.Image = ((System.Drawing.Image)(resources.GetObject("mnuBtninsertDatafield.Image")));
            this.mnuBtninsertDatafield.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtninsertDatafield.Name = "mnuBtninsertDatafield";
            this.mnuBtninsertDatafield.Size = new System.Drawing.Size(23, 22);
            this.mnuBtninsertDatafield.Text = "Insert Data Field";
            this.mnuBtninsertDatafield.Click += new System.EventHandler(this.mnuBtninsertDatafield_Click);
            // 
            // mnuBtninsertDate
            // 
            this.mnuBtninsertDate.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtninsertDate.Image = ((System.Drawing.Image)(resources.GetObject("mnuBtninsertDate.Image")));
            this.mnuBtninsertDate.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtninsertDate.Name = "mnuBtninsertDate";
            this.mnuBtninsertDate.Size = new System.Drawing.Size(23, 22);
            this.mnuBtninsertDate.Text = "Insert Date";
            this.mnuBtninsertDate.Click += new System.EventHandler(this.mnuBtninsertDate_Click);
            // 
            // mnuBtnInsertTime
            // 
            this.mnuBtnInsertTime.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnInsertTime.Image = global::TextControlEditorWebClient.Properties.Resources.time;
            this.mnuBtnInsertTime.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnInsertTime.Name = "mnuBtnInsertTime";
            this.mnuBtnInsertTime.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnInsertTime.Text = "Insert Time";
            this.mnuBtnInsertTime.Click += new System.EventHandler(this.mnuBtnInsertTime_Click);
            // 
            // toolStripSeparator8
            // 
            this.toolStripSeparator8.Name = "toolStripSeparator8";
            this.toolStripSeparator8.Size = new System.Drawing.Size(6, 25);
            // 
            // mnuBtnShowHeader
            // 
            this.mnuBtnShowHeader.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnShowHeader.Image = global::TextControlEditorWebClient.Properties.Resources.header;
            this.mnuBtnShowHeader.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnShowHeader.Name = "mnuBtnShowHeader";
            this.mnuBtnShowHeader.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnShowHeader.Text = "Edit Header";
            this.mnuBtnShowHeader.Click += new System.EventHandler(this.mnuBtnShowHeader_Click);
            // 
            // mnuBtnShowFooter
            // 
            this.mnuBtnShowFooter.DisplayStyle = System.Windows.Forms.ToolStripItemDisplayStyle.Image;
            this.mnuBtnShowFooter.Image = global::TextControlEditorWebClient.Properties.Resources.footer;
            this.mnuBtnShowFooter.ImageTransparentColor = System.Drawing.Color.Magenta;
            this.mnuBtnShowFooter.Name = "mnuBtnShowFooter";
            this.mnuBtnShowFooter.Size = new System.Drawing.Size(23, 22);
            this.mnuBtnShowFooter.Text = "Edit Footer";
            this.mnuBtnShowFooter.Click += new System.EventHandler(this.mnuBtnShowFooter_Click);
            // 
            // m_horizontalRulerBar
            // 
            this.m_horizontalRulerBar.Dock = System.Windows.Forms.DockStyle.Top;
            this.m_horizontalRulerBar.Location = new System.Drawing.Point(25, 145);
            this.m_horizontalRulerBar.Name = "m_horizontalRulerBar";
            this.m_horizontalRulerBar.Size = new System.Drawing.Size(953, 25);
            this.m_horizontalRulerBar.TabIndex = 9;
            this.m_horizontalRulerBar.Text = "m_horizontalRulerBar";
            // 
            // m_verticalRulerBar
            // 
            this.m_verticalRulerBar.Alignment = TXTextControl.RulerBarAlignment.Left;
            this.m_verticalRulerBar.Dock = System.Windows.Forms.DockStyle.Left;
            this.m_verticalRulerBar.Location = new System.Drawing.Point(0, 145);
            this.m_verticalRulerBar.Name = "m_verticalRulerBar";
            this.m_verticalRulerBar.Size = new System.Drawing.Size(25, 720);
            this.m_verticalRulerBar.TabIndex = 8;
            this.m_verticalRulerBar.Text = "m_verticalRulerBar";
            // 
            // m_statusBar
            // 
            this.m_statusBar.BackColor = System.Drawing.SystemColors.Control;
            this.m_statusBar.ColumnText = "Column";
            this.m_statusBar.Dock = System.Windows.Forms.DockStyle.Bottom;
            this.m_statusBar.LineText = "Line";
            this.m_statusBar.Location = new System.Drawing.Point(25, 843);
            this.m_statusBar.Name = "m_statusBar";
            this.m_statusBar.PageText = "Page";
            this.m_statusBar.SectionText = "Section";
            this.m_statusBar.Size = new System.Drawing.Size(953, 22);
            this.m_statusBar.TabIndex = 11;
            // 
            // textControl1
            // 
            this.textControl1.Dock = System.Windows.Forms.DockStyle.Fill;
            this.textControl1.Font = new System.Drawing.Font("Arial", 10F);
            this.textControl1.Location = new System.Drawing.Point(25, 170);
            this.textControl1.Name = "textControl1";
            this.textControl1.Ribbon = this.ribbon1;
            this.textControl1.Size = new System.Drawing.Size(953, 673);
            this.textControl1.TabIndex = 13;
            this.textControl1.UserNames = null;
            this.textControl1.TextFieldClicked += new TXTextControl.TextFieldEventHandler(this.textControl1_TextFieldClicked);
            this.textControl1.TextFieldChanged += new TXTextControl.TextFieldEventHandler(this.textControl1_TextFieldChanged);
            this.textControl1.KeyDown += new System.Windows.Forms.KeyEventHandler(this.TextControl_KeyDown);
            // 
            // ribbon1
            // 
            this.ribbon1.Controls.Add(this.ribbonFormattingTab1);
            this.ribbon1.Controls.Add(this.ribbonInsertTab1);
            this.ribbon1.Controls.Add(this.ribbonPageLayoutTab1);
            this.ribbon1.Controls.Add(this.ribbonViewTab1);
            this.ribbon1.Dock = System.Windows.Forms.DockStyle.Top;
            this.ribbon1.Font = new System.Drawing.Font("Segoe UI", 9F);
            this.ribbon1.HasApplicationMenu = false;
            this.ribbon1.HotTrack = true;
            this.ribbon1.Location = new System.Drawing.Point(0, 0);
            this.ribbon1.Name = "ribbon1";
            this.ribbon1.SelectedIndex = 0;
            this.ribbon1.Size = new System.Drawing.Size(978, 120);
            this.ribbon1.TabIndex = 15;
            this.ribbon1.Text = "ribbon1";
            // 
            // ribbonFormattingTab1
            // 
            this.ribbonFormattingTab1.Location = new System.Drawing.Point(4, 24);
            this.ribbonFormattingTab1.Name = "ribbonFormattingTab1";
            this.ribbonFormattingTab1.Size = new System.Drawing.Size(970, 92);
            this.ribbonFormattingTab1.TabIndex = 1;
            // 
            // ribbonInsertTab1
            // 
            this.ribbonInsertTab1.Location = new System.Drawing.Point(4, 24);
            this.ribbonInsertTab1.Name = "ribbonInsertTab1";
            this.ribbonInsertTab1.Size = new System.Drawing.Size(970, 92);
            this.ribbonInsertTab1.TabIndex = 2;
            // 
            // ribbonPageLayoutTab1
            //
            this.ribbonPageLayoutTab1.Location = new System.Drawing.Point(4, 24);
            this.ribbonPageLayoutTab1.Name = "ribbonPageLayoutTab1";
            this.ribbonPageLayoutTab1.Size = new System.Drawing.Size(970, 92);
            this.ribbonPageLayoutTab1.TabIndex = 3;
            // 
            // ribbonViewTab1
            // 
            this.ribbonViewTab1.Location = new System.Drawing.Point(4, 24);
            this.ribbonViewTab1.Name = "ribbonViewTab1";
            this.ribbonViewTab1.Size = new System.Drawing.Size(970, 92);
            this.ribbonViewTab1.TabIndex = 4;
            // 
            // hidingMenu
            // 
            this.hidingMenu.Items.AddRange(new System.Windows.Forms.ToolStripItem[] {
            this.mnuCut,
            this.mnuCopy,
            this.mnuPaste,
            this.mnuSelectAll,
            this.mnuFind,
            this.mnuReplace,
            this.mnuSave,
            this.mnuPrint});
            this.hidingMenu.Location = new System.Drawing.Point(0, 0);
            this.hidingMenu.Name = "hidingMenu";
            this.hidingMenu.Size = new System.Drawing.Size(200, 24);
            this.hidingMenu.TabIndex = 14;
            this.hidingMenu.Visible = false;
            // 
            // mnuCut
            // 
            this.mnuCut.Name = "mnuCut";
            this.mnuCut.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.X)));
            this.mnuCut.Size = new System.Drawing.Size(12, 20);
            this.mnuCut.Click += new System.EventHandler(this.mnuBtnCut_Click);
            // 
            // mnuCopy
            // 
            this.mnuCopy.Name = "mnuCopy";
            this.mnuCopy.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.C)));
            this.mnuCopy.Size = new System.Drawing.Size(12, 20);
            this.mnuCopy.Click += new System.EventHandler(this.mnuBtnCopy_Click);
            // 
            // mnuPaste
            // 
            this.mnuPaste.Name = "mnuPaste";
            this.mnuPaste.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.V)));
            this.mnuPaste.Size = new System.Drawing.Size(12, 20);
            this.mnuPaste.Click += new System.EventHandler(this.mnuBtnPaste_Click);
            // 
            // mnuSelectAll
            // 
            this.mnuSelectAll.Name = "mnuSelectAll";
            this.mnuSelectAll.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.A)));
            this.mnuSelectAll.Size = new System.Drawing.Size(12, 20);
            this.mnuSelectAll.Click += new System.EventHandler(this.mnuBtnSelectAll_Click);
            // 
            // mnuFind
            // 
            this.mnuFind.Name = "mnuFind";
            this.mnuFind.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.F)));
            this.mnuFind.Size = new System.Drawing.Size(12, 20);
            this.mnuFind.Click += new System.EventHandler(this.mnuBtnFind_Click);
            // 
            // mnuReplace
            // 
            this.mnuReplace.Name = "mnuReplace";
            this.mnuReplace.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.H)));
            this.mnuReplace.Size = new System.Drawing.Size(12, 20);
            this.mnuReplace.Click += new System.EventHandler(this.mnuBtnReplace_Click);
            // 
            // mnuSave
            // 
            this.mnuSave.Name = "mnuSave";
            this.mnuSave.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.S)));
            this.mnuSave.Size = new System.Drawing.Size(12, 20);
            this.mnuSave.Click += new System.EventHandler(this.mnuBtnSave_Click);
            // 
            // mnuPrint
            // 
            this.mnuPrint.Name = "mnuPrint";
            this.mnuPrint.ShortcutKeys = ((System.Windows.Forms.Keys)((System.Windows.Forms.Keys.Control | System.Windows.Forms.Keys.P)));
            this.mnuPrint.Size = new System.Drawing.Size(12, 20);
            this.mnuPrint.Click += new System.EventHandler(this.mnuBtnPrint_Click);
            // 
            // TextUserControlEditor
            // 
            this.AutoScaleDimensions = new System.Drawing.SizeF(6F, 13F);
            this.AutoScaleMode = System.Windows.Forms.AutoScaleMode.Font;
            this.Controls.Add(this.textControl1);
            this.Controls.Add(this.m_statusBar);
            this.Controls.Add(this.m_horizontalRulerBar);
            this.Controls.Add(this.m_verticalRulerBar);
            this.Controls.Add(this.toolStrip);
            this.Controls.Add(this.hidingMenu);
            this.Controls.Add(this.ribbon1);
            this.Name = "TextUserControlEditor";
            this.Size = new System.Drawing.Size(978, 865);
            this.toolStrip.ResumeLayout(false);
            this.toolStrip.PerformLayout();
            this.ribbon1.ResumeLayout(false);
            this.hidingMenu.ResumeLayout(false);
            this.hidingMenu.PerformLayout();
            this.ResumeLayout(false);
            this.PerformLayout();

		}

		#endregion

        //m_verticalRulerBar   private TXTextControl.RulerBar rulerBar2;
        private System.Windows.Forms.ToolStripButton mnuBtnNewFile;
        private System.Windows.Forms.ToolStripButton mnuBtnOpenFile;
        private System.Windows.Forms.ToolStripButton mnuBtnSave;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator1;
        private System.Windows.Forms.ToolStripButton mnuBtnPrint;
        private System.Windows.Forms.ToolStripButton mnuBtnPrintPreview;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator2;
        private System.Windows.Forms.ToolStripButton mnuBtnDelete;
        private System.Windows.Forms.ToolStripButton mnuBtnUndo;
        private System.Windows.Forms.ToolStripButton mnuBtnRedo;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator4;
        private System.Windows.Forms.ToolStrip toolStrip;
        private TXTextControl.RulerBar m_horizontalRulerBar;
        private TXTextControl.RulerBar m_verticalRulerBar;
        private TXTextControl.StatusBar m_statusBar;
        private System.Windows.Forms.ToolStripButton mnuBtninsertDate;
        private System.Windows.Forms.ToolStripButton mnuBtnInsertTime;
        private System.Windows.Forms.ToolStripSeparator toolStripSeparator8;
        private System.Windows.Forms.ToolStripButton mnuBtnSpelling;
        private System.Windows.Forms.ToolStripButton mnuBtninsertDatafield;
        public TXTextControl.TextControl textControl1;
        private ToolStripButton mnuBtnShowHeader;
        private MenuStrip hidingMenu;
        private ToolStripMenuItem mnuCut;
        private ToolStripMenuItem mnuCopy;
        private ToolStripMenuItem mnuPaste;
        private ToolStripMenuItem mnuSelectAll;
        private ToolStripMenuItem mnuFind;
        private ToolStripMenuItem mnuReplace;
        private ToolStripMenuItem mnuSave;
        private ToolStripMenuItem mnuPrint;
        private ToolStripButton mnuBtnShowFooter;
        private TXTextControl.Windows.Forms.Ribbon.Ribbon ribbon1;
        private TXTextControl.Windows.Forms.Ribbon.RibbonFormattingTab ribbonFormattingTab1;
        private TXTextControl.Windows.Forms.Ribbon.RibbonInsertTab ribbonInsertTab1;
        private TXTextControl.Windows.Forms.Ribbon.RibbonPageLayoutTab ribbonPageLayoutTab1;
        private TXTextControl.Windows.Forms.Ribbon.RibbonViewTab ribbonViewTab1;
       


    }
}
