using System;
using System.ComponentModel;
using System.Windows.Forms;
using System.Runtime.InteropServices;
using TXTextControl.Windows.Forms.Ribbon;
using TextControlEditorPharmacyClient.Properties;
using TXTextControl;
using System.IO;

namespace TextControlEditorPharmacyClient
{
          
    [ComVisible(true)]
    public partial class frmTextControlEditor : TXTextControl.Windows.Forms.Ribbon.RibbonForm
    {

#region "Bring window to foreground"
        protected const uint SW_SHOW = 5;
        private const int WM_NCLBUTTONDBLCLK = 0x00A3; //double click on a title bar(non-client area of the form).

        [DllImport("user32.dll", SetLastError = true)]
        protected static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

        // When you don't want the ProcessId, use this overload and pass IntPtr.Zero for the second parameter
        [DllImport("user32.dll")]
        protected static extern uint GetWindowThreadProcessId(IntPtr hWnd, IntPtr ProcessId);

        [DllImport("kernel32.dll")]
        protected static extern uint GetCurrentThreadId();

        /// The GetForegroundWindow function returns a handle to the foreground window.
        [DllImport("user32.dll")]
        protected static extern IntPtr GetForegroundWindow();
        
        [DllImport("user32.dll")]
        protected static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);

        [DllImport("user32.dll", SetLastError = true)]
        protected static extern bool BringWindowToTop(IntPtr hWnd);
        
        [DllImport("user32.dll", SetLastError = true)]
        protected static extern bool BringWindowToTop(HandleRef hWnd);
        
        [DllImport("user32.dll")]
        protected static extern bool ShowWindow(IntPtr hWnd, uint nCmdShow);


        ///<summary>
        /// Forces the window to foreground.
        ///</summary>
        ///hwnd”>The HWND.</param>
        protected static void ForceWindowToForeground(IntPtr hwnd)
        {
            AttachedThreadInputAction(
                () =>
                {
                    BringWindowToTop(hwnd);
                    ShowWindow(hwnd, SW_SHOW);
                });
        }

        protected static void AttachedThreadInputAction(Action action)
        {
            var foreThread = GetWindowThreadProcessId(GetForegroundWindow(), IntPtr.Zero);
            var appThread = GetCurrentThreadId();
            bool threadsAttached = false;
            try
            {
                threadsAttached = (foreThread == appThread) || AttachThreadInput(foreThread, appThread, true);

                if (threadsAttached)
                {
                    action();
                }
                else
                {
                    throw new System.Threading.ThreadStateException("AttachThreadInput failed.");
                }
            }
            finally
            {
                if (threadsAttached)
                {
                    AttachThreadInput(foreThread, appThread, false);
                }
            }
        }
        
        private void ActivateWindow()
        {
            try
            {
                ForceWindowToForeground(this.Handle);
            }
            catch (Exception ex)
            {
                LogError("ForceWindowToForeground Error", ex);
            }
        }

        private void frmTextControlEditor_Load(object sender, EventArgs e)
        {
            ActivateWindow();

            //Graphics g = textControl1.CreateGraphics();
            //int dpi = (int)(1440 / g.DpiX);

            //Point newInputPosition = new Point(
            //    (dpi) +
            //    textControl1.ScrollLocation.X,
            //    (dpi) +
            //    textControl1.ScrollLocation.Y);

            //textControl1.InputPosition =
            //    new TXTextControl.InputPosition(newInputPosition);      

        }

        /// <summary>
        /// Disable drag and double click in Non client area
        /// </summary>
        /// <param name="message"></param>
        protected override void WndProc(ref Message message)
        {
            const int WM_SYSCOMMAND = 0x0112;
            const int SC_MOVE = 0xF010;
            
            switch (message.Msg)
            {
                case WM_SYSCOMMAND:
                    int command = message.WParam.ToInt32() & 0xfff0;
                    if (command == SC_MOVE)
                    {
                        return;
                    }
                    break;
                case WM_NCLBUTTONDBLCLK:
                     message.Result = IntPtr.Zero;
                     return;
            }

            base.WndProc(ref message);
        }


        private static void LogError(string firstLine, Exception ex)
        {
            string fileName = System.Reflection.Assembly.GetExecutingAssembly().Location;
            string folderPath = System.IO.Path.GetDirectoryName(fileName);
            fileName = System.IO.Path.GetFileNameWithoutExtension(fileName) + "__Error.log";
            fileName = Path.Combine(folderPath, fileName);
            StreamWriter sw = new StreamWriter(fileName, true);

            try
            {
                sw.WriteLine("");
                sw.WriteLine(DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss") + " - " + firstLine);
                sw.WriteLine(ex.Message);
                sw.WriteLine(ex.StackTrace.ToString());
            }
            catch 
            { }
            finally
            {
                try
                {
                    sw.Close();
                    sw.Flush();
                    sw.Dispose();
                }
                catch
                { }
            }
        }
        #endregion


        private FileHandling.FileHandler m_fileHandler;

        private RibbonButton m_btnUndo, m_btnRedo, m_btnNew, m_btnSave, m_btnPrint;

        public string RTFPath { get; set; }
        /// <summary>
        /// Constructor to initilaize the txControl
        /// </summary>
        public frmTextControlEditor()
        {
            try
            {
                InitializeComponent();
                LocalizeAppMenu();
                                
                mnuNew.Click += mnuNew_Click;
                mnuBtnDelete.Click += mnuBtnDelete_Click;
                mnuBtninsertDate.Click += mnuBtninsertDate_Click;
                mnuBtnInsertTime.Click += mnuBtnInsertTime_Click;
                mnuSaveAndExit.Click += mnuSaveAndExit_Click;
                mnuPrint.Click += mnuPrint_Click; //Or mnuPrint.ButtonClick += BtnAppMenu_Print_ButtonClick;
                mnuPrintPreview.Click += mnuPrintPreview_Click;
                mnuExit.Click += mnuExit_Click;

                //Initialising Quick Menu options
                m_btnUndo = new RibbonButton
                {
                    Text = Constants.BTN_UNDO,
                    SmallIcon = Resources.undo, //new Bitmap(typeof(frmTextControlEditor), "undo".ToSmallImageResName()),
                    Enabled = false

                };
                m_btnRedo = new RibbonButton
                {
                    Text = Constants.BTN_REDO,
                    SmallIcon = Resources.redo,
                    Enabled = false
                };

                m_btnNew = new RibbonButton
                {
                    Text = Constants.APP_MENU_NEW,
                    SmallIcon = Resources.newpage,
                    Enabled = true
                };
                m_btnPrint = new RibbonButton
                {
                    Text = Constants.APP_MENU_PRINT,
                    SmallIcon = Resources.print,
                    Enabled = true
                };
                m_btnSave = new RibbonButton
                {
                    Text = Constants.APP_MENU_SAVE,
                    SmallIcon = Resources.save,
                    Enabled = this.IsDocumentModified
                };

                m_btnUndo.Click += BtnUndo_Click;
                m_btnRedo.Click += BtnRedo_Click;
                m_btnNew.Click += mnuNew_Click;
                m_btnPrint.Click += mnuPrint_Click;
                m_btnSave.Click += mnuSaveAndExit_Click;

                // Set default quick access toolbar items
                SetQuickAccessToolbarStandardItems(new RibbonButton[] {
				m_btnNew,m_btnUndo, m_btnRedo,m_btnSave,m_btnPrint,mnuBtnDelete,mnuBtninsertDate,mnuBtnInsertTime
			});

                // File handling
                m_fileHandler = new FileHandling.FileHandler(textControl1);
                
            }
            catch (Exception ex)
            {
                LogError("Error at frmTextControlEditor constructor.", ex);
                MessageBox.Show(ex.Message);
            }
        }

        /// <summary>
        /// To indicate that any modifications happened in the document
        /// </summary>
        public bool IsDocumentModified { get; set; }

        /// <summary>
        /// To indicate if thereis any change in the file
        /// </summary>
        public bool IsFileModified
        {
            get
            {
                return m_fileHandler.IsDocumentDirty;
            }
            set
            {
                m_fileHandler.IsDocumentDirty = value;
            }
        }

        /// <summary>
        /// Save and Exit functionality implementation
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuSaveAndExit_Click(object sender, EventArgs e)
        {
            QuerySaveAndExit();
        }

        /// <summary>
        /// Loading the TxControl document
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuLoad_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("Do you want to Load RTF?", "Load", MessageBoxButtons.OKCancel);
            if (result == DialogResult.OK)
            {
                textControl1.Load();
            }

        }

        /// <summary>
        /// Creating the new Document
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuNew_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("This action will wipe everything and replace it with a blank page\n\n Are you sure you want to erase the whole document?", "CAUTION", MessageBoxButtons.OKCancel);
            if (result == DialogResult.OK)
                m_fileHandler.New();
        }

        /// <summary>
        /// Creating the Delete Selection
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuBtnDelete_Click(object sender, EventArgs e)
        {
            textControl1.Clear();
        }

        /// <summary>
        /// Insert Date
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuBtninsertDate_Click(object sender, EventArgs e)
        {
            if (textControl1.EditMode != TXTextControl.EditMode.ReadOnly)
                textControl1.TextFields.Add(new TextField(DateTime.Now.ToString("dd.MM.yy")));
        }
        /// <summary>
        ///Insert Time
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuBtnInsertTime_Click(object sender, EventArgs e)
        {
           if( textControl1.EditMode != TXTextControl.EditMode.ReadOnly)
               textControl1.TextFields.Add(new TextField(DateTime.Now.ToString("HH.mm:ss")));
        }
        /// <summary>
        /// Printing the document
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuPrint_Click(object sender, EventArgs e)
        {
            Print();

        }

        /// <summary>
        /// Print preview functionality implementation
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuPrintPreview_Click(object sender, EventArgs e)
        {
            PrintPreview();
        }

        /// <summary>
        /// Print Setup functionality implementation
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuPrintSetup_Click(object sender, EventArgs e)
        {
            //to do
        }

        /// <summary>
        /// Exiting the TXControl form
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuExit_Click(object sender, EventArgs e)
        {
            bool OK = false;

            if (textControl1.EditMode.ToString() == "ReadOnly" || !this.IsDocumentModified)
            {
                OK = true;
            }
            else
            {
                DialogResult result = MessageBox.Show("OK to exit without saving?", "Exit", MessageBoxButtons.YesNoCancel);
                if (result == DialogResult.Yes)
                {
                    OK = true;
                }
            }

            if (OK)
            {
                textControl1.Tag = "exit";
                this.IsDocumentModified = false;
                this.Hide();
            }
        }

 
        protected void frmTextControlEditor_FormClosed(object obj, FormClosedEventArgs e)
        {
            if (!blnSaveAndExit)
                textControl1.Tag = "exit";
        }


        public void PrintPreview()
        {
            textControl1.PrintPreview(m_fileHandler.DocumentTitle + " - " + ProductName);
        }

        public void Print()
        {
            textControl1.Print(ProductName + " - ");
        }


        public bool blnSaveAndExit = false;
        /// <summary>
        /// 
        /// </summary>
        public void QuerySaveAndExit()
        {
            bool OK = false, Cancel = false;

            if (textControl1.EditMode.ToString() == "ReadOnly" || !this.IsDocumentModified)
            {
                OK = true;
                Cancel = true;
            }
            else
            {
                DialogResult result = MessageBox.Show("OK to save changes?", "Exit", MessageBoxButtons.YesNoCancel);
                if (result == DialogResult.Yes)
                {

                    if (!string.IsNullOrEmpty(RTFPath))
                    {
                        blnSaveAndExit = true;
                        textControl1.Save(RTFPath, StreamType.RichTextFormat);
                        OK = true;
                    }
                    else
                    {
                        MessageBox.Show("RTF file does not exist in the database");
                    }

                }
                if (result == DialogResult.No)
                {
                    OK = true;
                    Cancel = true;
                }
                else if (result == DialogResult.Cancel)
                {
                    Cancel = true;
                }
            }

            if (OK)
            {
                if (Cancel)
                {
                    textControl1.Tag = "exit";
                    this.IsDocumentModified = false;
                }
                this.Hide();

            }
        }

        void BtnRedo_Click(object sender, EventArgs e)
        {
            textControl1.Redo();
        }

        void BtnUndo_Click(object sender, EventArgs e)
        {
            textControl1.Undo();
        }

        private void textControl1_PropertyChanged(object sender, PropertyChangedEventArgs e)
        {
            switch (e.PropertyName)
            {
                case "CanUndo":
                    m_btnUndo.Enabled = textControl1.CanUndo;
                    m_btnSave.Enabled = this.IsDocumentModified;
                    break;

                case "CanRedo":
                    m_btnRedo.Enabled = textControl1.CanRedo;
                    m_btnSave.Enabled = this.IsDocumentModified;
                    break;
            }
        }

        private void textControl1_KeyDown(object sender, KeyEventArgs e)
        {
            switch (e.KeyCode)
            {

                case Keys.A:		// Ctrl-A: Select all
                    if (!e.Control || e.Alt || e.Shift) break;
                    textControl1.SelectAll();
                    break;
                //Todo - Comment Save using keyboard
                case Keys.S:		// Ctrl-S: save 
                    if (!e.Control || e.Alt || e.Shift) break;
                    if (this.IsDocumentModified)
                        QuerySaveAndExit();
                    break;

                case Keys.F:		// Ctrl-F: search
                    if (!e.Control || e.Alt || e.Shift) break;
                    textControl1.Find();
                    break;

                case Keys.H:		// Ctrl-H: search abd replace
                    if (!e.Control || e.Alt || e.Shift) break;
                    textControl1.Replace();
                    break;

                case Keys.P:
                    if (!e.Control || e.Alt || e.Shift) break;
                    if (textControl1.CanPrint)
                    {
                        textControl1.Print(m_fileHandler.DocumentTitle + " - " + ProductName);
                    }
                    else e.Handled = true;
                    break;
            }
        }

        private void textControl1_Changed(object sender, EventArgs e)
        {
            this.ChangeModifiedSettings();
        }

        private void textControl1_PageFormatChanged(object sender, EventArgs e)
        {
            this.ChangeModifiedSettings();
        }

        private void ChangeModifiedSettings()
        {
            if (!textControl1.CanUndo)
            {
                this.IsDocumentModified = false;
                this.mnuSaveAndExit.Enabled = false;
                this.m_btnSave.Enabled = false;
                this.mnuExit.Text = "Exit";
            }
            else
            {
                this.IsDocumentModified = true;
                this.mnuSaveAndExit.Enabled = true;
                this.m_btnSave.Enabled = true;
                this.mnuExit.Text = "Exit without saving";
            }
        }

        private void frmTextControlEditor_FormClosing(object sender, FormClosingEventArgs e)
        {
            if (this.Visible)
            {
                e.Cancel = true;
                QuerySaveAndExit();
            }
        }
    }
}
