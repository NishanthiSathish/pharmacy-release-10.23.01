using System;
using System.Drawing.Printing;
using System.IO;
using System.Reflection;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using Microsoft.Win32;
using TXTextControl;
using System.Drawing;
using System.ComponentModel;

namespace TextControlEditorWebClient
{

    [ProgId("TextControlEditorWebClient.TextUserControlEditor")]
    [Guid("2ACA46A2-FA7B-304F-BA7D-0FFED1B7BBBC")]
    [ClassInterface(ClassInterfaceType.AutoDispatch)]
    [ComVisible(true)]
    public partial class TextUserControlEditor : UserControl
    {
        public string selectedvalue { get; set; }

        private TextControlForm.FileHandling.FileHandler m_fileHandler;

        public TextUserControlEditor()
        {
            try
            {
                InitializeComponent();

                m_fileHandler = new TextControlForm.FileHandling.FileHandler(textControl1);

                textControl1.RulerBar = m_horizontalRulerBar;
                textControl1.VerticalRulerBar = m_verticalRulerBar;
                textControl1.StatusBar = m_statusBar;
                m_fileHandler.DocumentDirtyChanged += FileHandler_DocumentDirtyChanged;
                mnuBtnSpelling.Enabled = false; // Spell check button is disabled as in Editor- Report desktop 
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);
            }
        }

		//// Register COM ActiveX object
		//[ComRegisterFunction()]
		//public static void RegisterClass(string key)
		//{

		//    StringBuilder skey = new StringBuilder(key);

		//    skey.Replace(@"HKEY_CLASSES_ROOT\", "");

		//    RegistryKey regKey = Registry.ClassesRoot.OpenSubKey(skey.ToString(), true);

		//    RegistryKey ctrl = regKey.CreateSubKey("Control");

		//    ctrl.Close();

		//    RegistryKey inprocServer32 = regKey.OpenSubKey("InprocServer32", true);

		//    inprocServer32.SetValue("CodeBase", Assembly.GetExecutingAssembly().CodeBase);

		//    inprocServer32.Close();

		//    regKey.Close();

		//}

		////// Unregister COM ActiveX object
		//[ComUnregisterFunction()]
		//public static void UnregisterClass(string key)
		//{
		//    StringBuilder skey = new StringBuilder(key);

		//    skey.Replace(@"HKEY_CLASSES_ROOT\", "");

		//    RegistryKey regKey = Registry.ClassesRoot.OpenSubKey(skey.ToString(), true);

		//    regKey.DeleteSubKey("Control", false);

		//    RegistryKey inprocServer32 = regKey.OpenSubKey("InprocServer32", true);

		//    regKey.DeleteSubKey("CodeBase", false);

		//    regKey.Close();
		//}

        void FileHandler_DocumentDirtyChanged(object sender, TextControlForm.FileHandling.DocumentDirtyChangedEventArgs e)
        {
            SetWindowTitle(m_fileHandler.DocumentTitle, e.NewValue);
        }

        private void SetWindowTitle(String documentTitle, Boolean isDocumentDirty = false)
        {
            String asterisk = isDocumentDirty ? "*" : "";
            this.Text = String.Format("{0}{1} - {2}", documentTitle, asterisk, ProductName);
        }

        /// <summary>
        /// Get the temporary folder path value
        /// </summary>
        /// <returns></returns>
        [ComVisible(true)]
        public string GetTemporaryFolder()
        {
            return Path.GetTempPath();
        }

        /// <summary>
        /// Set the orientation for the TxTextControl
        /// </summary>
        /// <param name="portrait">If true, its portrait else it is landscape</param>
        /// <returns></returns>
        [ComVisible(true)]
        public bool SetOrientation(bool portrait)
        {
            textControl1.Landscape = portrait ? false : true;
            return textControl1.Landscape;
        }

        /// <summary>
        /// Load the document in the txtextcontrol
        /// </summary>
        /// <param name="path">Temporary folder path for storing the document </param>
        /// <param name="data">Data after mapping it to the RTF</param>

        [ComVisible(true)]
        public void LoadRTF(string path, string data)
        {
            SaveToFile(path, data);
            LoadSettings loadSettings = new LoadSettings
            {
                ApplicationFieldFormat = ApplicationFieldFormat.HighEdit
            };
            textControl1.Load(path, StreamType.RichTextFormat, loadSettings);
        }

       
        /// <summary>
        /// Add No more items text at the end of each page while generating report (eg : for FP10, Outpatient supply)
        /// </summary>
        /// <param name="path">Temporary folder path for storing the document </param>
        [ComVisible(true)]
        public void AddNoMoreItemsText(string path)
        {
            PageCollection pages = textControl1.GetPages();
            if (pages.Count > 0)
            {
                foreach (TXTextControl.Page page in pages)
                {
                    int pageLastTextPosition = (page.Start + page.Length) - 5;
                    textControl1.Selection.Start = pageLastTextPosition;
                    textControl1.Selection.Text = "No more items on this prescription";
                }
                textControl1.Save(path, StreamType.RichTextFormat);
            }
        }

        // Insert Field in tx control
        [ComVisible(true)]
        int InsertFieldID = 0;
        public void ReplaceSel(string insertdata)
        {
            TXTextControl.TextField InsertField = new TXTextControl.TextField();
            InsertField.Text = insertdata;
            InsertField.ID = InsertFieldID;
            InsertField.DoubledInputPosition = true;
            //InsertField.ShowActivated = true;

            InsertFieldID += 1;
            textControl1.TextFields.Add(InsertField);
            
        }

        /// <summary>
        /// Save the data to a temporary file in order to map it to the TxTextControl 
        /// </summary>
        /// <param name="path">Temporary folder path for storing the document </param>
        /// <param name="data">Data after mapping it to the RTF</param>
        private void SaveToFile(string path, string data)
        {
            File.WriteAllText(path, data);
        }

        /// <summary>
        /// Set the default printer name as the one passed to the method
        /// </summary>
        /// <param name="deviceName">The printer device name which has to be set as default printer</param>
        /// <returns>true if default printer name is set else false</returns>
        [ComVisible(true)]
        public bool SetInstancePrinter(string deviceName)
        {
            return (!string.IsNullOrWhiteSpace(deviceName) && DevicePrinter.SetDefaultPrinter(deviceName)) ? true : false;
        }

        /// <summary>
        /// Get the default print device name
        /// </summary>
        /// <returns>The default printer name</returns>
        [ComVisible(true)]
        public string GetInstancePrinter()
        {
            PrinterSettings settings = new PrinterSettings();
            return (!string.IsNullOrEmpty(settings.PrinterName)) ? settings.PrinterName : null;
        }

        /// <summary>
        /// Get the list of printers separated by comma
        /// </summary>
        /// <returns>a string value that holds the installed printers value</returns>
        [ComVisible(true)]
        public string GetWindowsPrintDeviceList()
        {
            try
            {
                string strMsg = null;

                if (PrinterSettings.InstalledPrinters.Count > 0)
                {
                    //Enumerate printer system properties
                    foreach (string ptrLoop in PrinterSettings.InstalledPrinters)
                    {
                        strMsg += ptrLoop + ',';
                    }
                }
                else
                    strMsg = "No Printers are installed";

                return strMsg;
            }
            catch (Exception e)
            {
                throw e;
            }
        }
        

        /// <summary>
        /// Get the list of printers separated by Pipe 
        /// </summary>
        /// <returns>a string value that holds the installed printers value</returns>
        [ComVisible(true)]
        public string GetPrinterList()
        {
            //To Do: make use of GetWindowsPrintDeviceList
            try
            {
                string strMsg = null;

                if (PrinterSettings.InstalledPrinters.Count > 0)
                {
                    //Enumerate printer system properties
                    foreach (string ptrLoop in PrinterSettings.InstalledPrinters)
                    {
                        strMsg += ptrLoop + '|';
                    }
                }
                else
                    strMsg = "No Printers are installed";
                return strMsg;
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        /// <summary>
        /// New Template Creation
        /// </summary>
        /// <param name="templateData"> The Default Template passed as string to set to the TxTextControl</param>
        [ComVisible(true)]
        public void DefaultTemplate(string templateData)
        {
            textControl1.Text = templateData;
        }

        private void mnuSave_Click(object sender, EventArgs e)
        {
            QuerySaveAndExit();
        }
        bool changed = false;
        private void textControl1_Changed(object sender, EventArgs e)
        {
            changed = true;
        }
        
        private void mnuLoad_Click(object sender, EventArgs e)
        {
            DialogResult result = MessageBox.Show("Do you want to Load RTF?", "Load", MessageBoxButtons.OKCancel);
            if (result == DialogResult.OK)
                textControl1.Load();
        }

        public void QuerySaveAndExit()
        {
            bool OK = false, Cancel = false;

            if (textControl1.EditMode.ToString() == "ReadOnly")
            {
                OK = true;
                Cancel = true;
            }
            else if (m_fileHandler != null && !changed)
            {               
                OK = true;
                Cancel = true;
            }
            else
            {
                DialogResult result = MessageBox.Show("Do you want to Save?", "Save", MessageBoxButtons.YesNoCancel);
                if (result == DialogResult.Yes)
                {
                    OK = true;
                }
                if (result == DialogResult.No)
                {
                    Cancel = false;
                }
                else if (result == DialogResult.Cancel)
                {
                    Cancel = true;
                }
            }

            if (OK)
            {
                if (Cancel)
                    textControl1.Tag = "exit";
            }
        }

        private void mnuPrint_Click(object sender, EventArgs e)
        {
            PrintDoc(string.Empty);
        }

        private void mnuPrintPreview_Click(object sender, EventArgs e)
        {
            PrintPreview();
        }

        public void PrintPreview()
        {
            textControl1.PrintPreview(ProductName + " - ");
        }     

        private void mnuBtnNewFile_Click(object sender, EventArgs e)
        {
            FileNew();
        }

        private void mnuBtnOpenFile_Click(object sender, EventArgs e)
        {
            FileOpen();
        }

        private void mnuBtnSave_Click(object sender, EventArgs e)
        {
            FileSave();
        }

        private void mnuBtnPrint_Click(object sender, EventArgs e)
        {
            PrintDoc(string.Empty);
        }

        private void mnuBtninsertDatafield_Click(object sender, EventArgs e)
        {
            InsertDataField InsertDialog = new InsertDataField();

            InsertDialog.tx = textControl1;
            InsertDialog.ShowDialog();

        }

        private void mnuBtnPrintPreview_Click(object sender, EventArgs e)
        {
            PrintPreview();
        }

        private void mnuBtnCut_Click(object sender, EventArgs e)
        {
            textControl1.Cut();
        }

        private void mnuBtnCopy_Click(object sender, EventArgs e)
        {
            textControl1.Copy();
        }

        private void mnuBtnPaste_Click(object sender, EventArgs e)
        {
            textControl1.Paste();
        }

        private void mnuBtnSelectAll_Click(object sender, EventArgs e)
        {
            textControl1.SelectAll();
        }

        private void mnuBtnDelete_Click(object sender, EventArgs e)
        {
            textControl1.Clear();
        }

        private void mnuBtnUndo_Click(object sender, EventArgs e)
        {
            textControl1.Undo();
        }

        private void mnuBtnRedo_Click(object sender, EventArgs e)
        {
            textControl1.Redo();
        }

        private void mnuBtnFind_Click(object sender, EventArgs e)
        {
            textControl1.Find();
        }

        private void mnuBtnReplace_Click(object sender, EventArgs e)
        {
            textControl1.Replace();
        }

        private void mnuBtnMarginsAndPaper_Click(object sender, EventArgs e)
        {
            try
            {
                textControl1.SectionFormatDialog(0);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, ProductName);
            }
        }

        private void mnuBtnHeadersAndFooters_Click(object sender, EventArgs e)
        {
            try
            {
                textControl1.SectionFormatDialog(1);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, ProductName);
            }
        }

        private void mnuBtnColumns_Click(object sender, EventArgs e)
        {
            try
            {
                textControl1.SectionFormatDialog(2);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, ProductName);
            }
        }

        private void mnuBtnPageBorders_Click(object sender, EventArgs e)
        {
            try
            {
                textControl1.SectionFormatDialog(3);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, ProductName);
            }
        }

        
        public void FileNew()
        {
            m_fileHandler.New();
            this.Text = this.ProductName.ToString() + " - " + m_fileHandler.DocumentTitle;
        }

        public void FileOpen()
        {          
        }

        public void FileSave()
        {
            QuerySaveAndExit();
        }

        /// <summary>
        /// Saving the file into the path
        /// </summary>
        /// <param name="path"></param>
        [ComVisible(true)]
        public void SaveDoc(string path)
        {
            textControl1.Save(path,StreamType.RichTextFormat);
        }

        private void mnuBtntable_Click(object sender, EventArgs e)
        {
            try
            {
                if (textControl1.Tables.Add())
                {
                    m_fileHandler.IsDocumentDirty = true;
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, ProductName);
            }

        }

        private void mnuBtnimage_Click(object sender, EventArgs e)
        {
            try
            {
                TXTextControl.Image myImage = new TXTextControl.Image();
                myImage.Sizeable = false;
                myImage.HorizontalScaling = 75;
                myImage.VerticalScaling = 75;

                textControl1.Images.Add(myImage, -1);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, ProductName);
            }
        }

        private void mnuBtntextframe_Click(object sender, EventArgs e)
        {
            try
            {
                TXTextControl.TextFrame myFrame = new TXTextControl.TextFrame(new Size(3000, 2900));
                myFrame.BackColor = Color.White;
                textControl1.TextFrames.Add(myFrame, -1);
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, ProductName);
            }
        }

        /// <summary>
        /// Insert current system date into the textcontrol
        /// </summary>
        /// <param name="sender">Refrence to the textcontrol</param>
        /// <param name="e">Event data</param>
        /// 

        int InsertDateID = 0;
        private void mnuBtninsertDate_Click(object sender, EventArgs e)
        {
            TXTextControl.TextField InsertDate = new TXTextControl.TextField();
            InsertDate.Text = DateTime.Now.ToString("dd-MMM-yyyy");
            InsertDate.ID = InsertDateID;
            InsertDate.DoubledInputPosition = true;
           
            InsertFieldID += 1;
            textControl1.TextFields.Add(InsertDate);
           
        }

        /// <summary>
        /// Insert current system time into the textcontrol
        /// </summary>
        /// <param name="sender">Refrence to the textcontrol</param>
        /// <param name="e">Event data</param>
        ///  
        int InsertTimeID = 0;
        private void mnuBtnInsertTime_Click(object sender, EventArgs e)
        {
            TXTextControl.TextField InsertTime = new TXTextControl.TextField();
            InsertTime.Text = DateTime.Now.ToString("HH:mm:ss");
            InsertTime.ID = InsertTimeID;
            InsertTime.DoubledInputPosition = true;
           
            InsertTimeID += 1;
            textControl1.TextFields.Add(InsertTime);
           
        }

        /// <summary>
        /// Paragraph formating options for textcontrol (eg. Linespacing)
        /// </summary>
        /// <param name="sender">Refrence to the textcontrol</param>
        /// <param name="e">Event data</param>
        private void mnuBtnParagraphFormatting_Click(object sender, EventArgs e)
        {
            if (textControl1.ParagraphFormatDialog() == System.Windows.Forms.DialogResult.OK)
            {
                m_fileHandler.IsDocumentDirty = true;
            }
        }
        public void Print()
        {
            PrintDoc(string.Empty);
        }
        public int GetNumberOfPages()
        {
            int pages = 0;

            try
            {
                for (int i = 1; i <= textControl1.Pages; i++)
                {
                    if (textControl1.GetPages()[i].Section == textControl1.Sections.GetItem().Number) ++pages;
                }
            }
            catch { }

            return pages;
        }
        private void textControl1_TextFieldClicked(object sender, TXTextControl.TextFieldEventArgs e)
        {
            //e.TextField.Editable = false;
            // Field has been clicked on, update text of second TX and display it
            if (e.TextField.Name == "{Page}")
            {
                selectedvalue = "{Page}";
                textControl1.StatusBar.SectionText = "Field " + selectedvalue + "   Section ";
            }
            else if (e.TextField.Name == "{Page Total}")
            {
                selectedvalue = "{Page Total}";
                textControl1.StatusBar.SectionText = "Field " + selectedvalue + "   Section ";
            }else
            {
                e.TextField.Editable = true;
                textControl1.StatusBar.SectionText = "Section ";
            }
            

        }


        private bool bDeleteFields = true;

        private void textControl1_TextFieldChanged(object sender,
            TXTextControl.TextFieldEventArgs e)
        {

            if (bDeleteFields == false)
                return;

            if (e.TextField.Text == "")
            {
                textControl1.TextFields.Remove(e.TextField);
            }

        }

        private void TextControl_KeyDown(object sender, KeyEventArgs e)
        {
            textControl1.StatusBar.SectionText = "Section ";
        }
        [ComVisible(true)]
        public void PrintDoc(string strReportFilePathName)
        {
            PrintDocument pd = new PrintDocument();
            pd.DocumentName = strReportFilePathName;

			if(pd.PrinterSettings.Copies == 0)
			{
				pd.PrinterSettings.Copies = 1;
			}

        	textControl1.Print(pd);
        }
        
        /// <summary>
        /// Deleting RTF file from the path
        /// </summary>
        /// <param name="path"></param>
        [ComVisible(true)]
        public void DeleteRTFFile(string path)
        {
            if (File.Exists(path))
            {
               File.Delete(path);
            }
            else
            {
                MessageBox.Show("File Not Found");
            }            
        }

        /// <summary>
        /// Reading the RTF contents into string
        /// </summary>
        /// <param name="path"></param>
        /// <returns></returns>
        [ComVisible(true)]
        public string ReadRTFText(string path)
        {
            string rtfText = "";
            if (path != null)
            {
                rtfText = System.IO.File.ReadAllText(path);
            }
            return rtfText;
        }        

        /// <summary>
        /// Enable header for editing
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuBtnShowHeader_Click(object sender, EventArgs e)
        {
            try
            {
                TXTextControl.Section currentSection = textControl1.Sections.GetItem();
                TXTextControl.HeaderFooter headerSection = null;
                
                if (currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.FirstPageHeader) != null)
                {
                    headerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.FirstPageHeader);
                }
                else if (currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Header) != null)
                {
                    headerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Header);
                }
                else
                {
                    currentSection.HeadersAndFooters.Add(TXTextControl.HeaderFooterType.Header);
                    textControl1.HeaderFooterActivationStyle = TXTextControl.HeaderFooterActivationStyle.ActivateClick;
                    headerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Header);
                }
                if (headerSection.Activate())
                {
                    DeactivateFooterSection();
                    headerSection.Activate();
                }
                else
                {
                    headerSection.Deactivate();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, ProductName);
            }
        }

        /// <summary>
        /// Enable footer for editing
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void mnuBtnShowFooter_Click(object sender, EventArgs e)
        {
            try
            {
                TXTextControl.Section currentSection = textControl1.Sections.GetItem();
                TXTextControl.HeaderFooter footerSection = null;
                
                if (currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.FirstPageFooter) != null)
                {
                    footerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.FirstPageFooter);
                }
                else if (currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Footer) != null)
                {
                    footerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Footer);
                }
                else
                {
                    currentSection.HeadersAndFooters.Add(TXTextControl.HeaderFooterType.Footer);
                    textControl1.HeaderFooterActivationStyle = TXTextControl.HeaderFooterActivationStyle.ActivateClick;
                    footerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Footer);
                }

                if (footerSection.Activate())
                {
                    DeactivateHeaderSection();
                    footerSection.Activate();
                }
                else
                {
                    footerSection.Deactivate();
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message, ProductName);
            }

        }

        /// <summary>
        /// Deactivate Header Section
        /// </summary>
        public void DeactivateHeaderSection()
        {
            TXTextControl.Section currentSection = textControl1.Sections.GetItem();
            TXTextControl.HeaderFooter headerSection = null;

            if (currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.FirstPageHeader) != null)
            {
                headerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.FirstPageHeader);
            }
            else if (currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Header) != null)
            {
                headerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Header);
            }
            else
            {
                currentSection.HeadersAndFooters.Add(TXTextControl.HeaderFooterType.Header);
                textControl1.HeaderFooterActivationStyle = TXTextControl.HeaderFooterActivationStyle.ActivateClick;
                headerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Header);
            }

            headerSection.Deactivate();
            
        }

        /// <summary>
        /// Deactivate Footer Section
        /// </summary>
        public void DeactivateFooterSection()
        {
            TXTextControl.Section currentSection = textControl1.Sections.GetItem();
            TXTextControl.HeaderFooter footerSection = null;
            if (currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.FirstPageFooter) != null)
            {
                footerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.FirstPageFooter);
            }
            else if (currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Footer) != null)
            {
                footerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Footer);
            }
            else
            {
                currentSection.HeadersAndFooters.Add(TXTextControl.HeaderFooterType.Footer);
                textControl1.HeaderFooterActivationStyle = TXTextControl.HeaderFooterActivationStyle.ActivateClick;
                footerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Footer);
            }

            footerSection.Deactivate();
        }

    }
    /// <summary>
    /// System Default Printer
    /// </summary>
    public static class DevicePrinter
    {
        [DllImport("winspool.drv", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern bool SetDefaultPrinter(string Name);
    }
}
