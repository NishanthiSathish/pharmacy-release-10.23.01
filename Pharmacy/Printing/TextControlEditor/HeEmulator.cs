using System;
using System.Drawing.Printing;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Windows.Forms;
using TXTextControl;
//using System.Text.RegularExpressions; //Commented - MM-3989 (Required in Future version)

namespace TextControlEditorPharmacyClient
{
    public class HeEmulator
    {
        public frmTextControlEditor editorControl;
        private double _topMargin;
        private double _bottomMargin;
        private double _leftMargin;
        private double _rightMargin;
        private int _pageWidth;
        private int _pageHeight;
        private int _orientation;
        private bool _mnuPreviewEnable;
        private FileHandling.FileHandler m_fileHandler;
        private TXTextControl.TextControl txtextControl;

        /// <summary>
        /// 
        /// </summary>
        public HeEmulator()
        {
            if (editorControl == null)
            {
                editorControl = new frmTextControlEditor();
                txtextControl = editorControl.textControl1;
            }
        }
        
       /// <summary>
        /// Set Page orientation to Landscape or Portrait
       /// </summary>
        public int SetOrientation
        {
            set
            {
                _orientation = value;
                if (_orientation == 1)
                {
                    //Landscape
                    editorControl.textControl1.Selection.SectionFormat.Landscape = true;
                }
                else
                {
                    //Portrait
                    editorControl.textControl1.Selection.SectionFormat.Landscape = false;
                }
            }
        }

        /// <summary>
        /// Set Top Margin
        /// </summary>
        public double TopMargin
        {
            get 
            { 
                _topMargin = editorControl.textControl1.PageMargins.Top;
                return _topMargin; 
            }
            set 
            {
                _topMargin = value;
                editorControl.textControl1.PageMargins.Top = _topMargin; 
            }
        }

        /// <summary>
        /// Set Bottom Margin
        /// </summary>
        public double  BottomMargin
        {
            get 
            {
                _bottomMargin = editorControl.textControl1.PageMargins.Bottom;
                return _bottomMargin; 
            }
            set 
            {
                _bottomMargin = value;
                editorControl.textControl1.PageMargins.Bottom = _bottomMargin; 
            }
        }

        /// <summary>
        /// Set Left Margin
        /// </summary>
        public double LeftMargin
        {
            get 
            {
                _leftMargin = editorControl.textControl1.PageMargins.Left;
                return _leftMargin; 
            }
            set 
            {
                _leftMargin = value;
                editorControl.textControl1.PageMargins.Left = _leftMargin; 
            }
        }

        /// <summary>
        /// Set Right Margin
        /// </summary>
        public double RightMargin
        {
            get 
            {
                _rightMargin = editorControl.textControl1.PageMargins.Right;
                return _rightMargin; 
            }
            set 
            {
                _rightMargin = value;
                editorControl.textControl1.PageMargins.Right  = _rightMargin; 
            }
        }

        /// <summary>
        /// Set Page Height
        /// </summary>
        public int PageHeight
        {
            get 
            {
                _pageHeight = editorControl.textControl1.Height;
                return _pageHeight; 
            }
            set 
            {
                _pageHeight = value;
                editorControl.textControl1.Height = _pageHeight < 1 ? 10 : _pageHeight;
            }
        }

        /// <summary>
        /// Set Page Width
        /// </summary>
        public int PageWidth
        {
            get 
            {
                _pageWidth = editorControl.textControl1.Width;
                return _pageWidth; 
            }
            set 
            {
                _pageWidth = value;
                editorControl.textControl1.Width = _pageWidth < 1 ? 10 : _pageWidth; 
            }
        }

        /// <summary>
        /// Get Page left margin and top margin, lpnLeft for left margin, lpnTop for top margin
        /// </summary>
        /// <param name="lpnLeft"></param>
        /// <param name="lpnTop"></param>
        public void GetPhysicalMargins(double lpnLeft, double lpnTop)
        {

            //lpnLeft = editorControl.textControl1.PageMargins.Left;
            //lpnTop = editorControl.textControl1.PageMargins.Top;
        }

        /// <summary>
        /// Check default printer is set or not
        /// </summary>
        /// <param name="pbstr"></param>
        /// <param name="pnDefault"></param>
        /// <returns></returns>
        public bool GetInstancePrinter(ref string pbstr, ref int pnDefault)
        {
            PrinterSettings settings = new PrinterSettings();
            if (!string.IsNullOrEmpty(settings.PrinterName))
            {
                pbstr = settings.PrinterName;
                pnDefault = 0;
                return true;
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// Set txtext control read only
        /// </summary>
        public bool ReadOnly
        {
            set
            {
                editorControl.textControl1.EditMode = TXTextControl.EditMode.ReadOnly;
            }
        }
        public string path { get; set; }
        /// <summary>
        /// Load RTF settings, return true in sucess, else return false
        /// </summary>
        /// <param name="pszFileName"></param>
        /// <param name="streamtype"></param>
        /// <returns></returns>
        public bool LoadDoc(string pszFileName, int streamtype, int MergeRTF=0, int leftIndent=0, int rightIndent=0)
        {
            /* -- //Commented - MM-3989 (Required in Future version)
            string modifiedRTFContent = ""; 
            editorControl.RTFPath = pszFileName;
            //Todo - if data is not loaded then return false and find alternate method for  editorControl.Show() and  editorControl.Hide()
            string RTFFileContent = File.ReadAllText(pszFileName, Encoding.Default);
            if (MergeRTF != 0)
            {              
                var mergeFunc = new FileHandling.FontStyleMerger();
                modifiedRTFContent = mergeFunc.MergeFontStyleinRTF(RTFFileContent); 
            }
            
            if ((Regex.Matches(RTFFileContent, @"\\rtf1\\").Count) > 1)
            {
                var mergeColor = new FileHandling.UpdateColorforMergedRTF();
                modifiedRTFContent = mergeColor.MergeTableBackgroundColorStyleinRTF(modifiedRTFContent);
                System.IO.File.WriteAllText(pszFileName, modifiedRTFContent, Encoding.Default);
            } 
            */
            editorControl.RTFPath = pszFileName;
            //Todo - if data is not loaded then return false and find alternate method for  editorControl.Show() and  editorControl.Hide()
            if (MergeRTF != 0)
            {
                string RTFFileContent = File.ReadAllText(pszFileName, Encoding.Default);
                var mergeFunc = new FileHandling.FontStyleMerger();
                string modifiedRTFContent = mergeFunc.MergeFontStyleinRTF(RTFFileContent);

                System.IO.File.WriteAllText(pszFileName, modifiedRTFContent, Encoding.Default);
            }

            editorControl.MaximumSize = new System.Drawing.Size(400, 10);
            editorControl.Show();
            editorControl.Hide();
            LoadSettings ls = new TXTextControl.LoadSettings();
            ls.ApplicationFieldFormat = ApplicationFieldFormat.HighEdit;
            try
            {
                txtextControl.Load(pszFileName, TXTextControl.StreamType.RichTextFormat, ls);
            }
            catch (TXTextControl.FilterException)
            {
                txtextControl.Load(pszFileName, TXTextControl.StreamType.PlainText, ls);
            }

            if (leftIndent != 0)
            {
                txtextControl.ParagraphFormat.LeftIndent = leftIndent;
            }
            if (rightIndent != 0)
            {
                txtextControl.ParagraphFormat.RightIndent = rightIndent;
            }

            txtextControl.BringToFront();
            return true;

        }

        /// <summary>
        /// Creates a blank document
        /// </summary>
        /// <param name="pszFileName"></param>
        /// <returns></returns>
        public bool CreateBlankDoc(string pszFileName)
        {
            editorControl.RTFPath = pszFileName;
            return true;
        }


        /// <summary>
        /// Save Edited RTF file to local drive (path mentioned in db), lpszDocTitle = RTF file name. 
        /// </summary>
        /// <param name="lpszDocTitle"></param>
        /// <param name="streamtype"></param>
        /// <returns></returns>
        public bool SaveDoc(string lpszDocTitle, int streamtype)
        {
            
            //Todo - If not save then return false, comment  editorControl.Show() after completing todo in LoadDoc
            m_fileHandler = new FileHandling.FileHandler(editorControl.textControl1);
            m_fileHandler.DocumentFileName = lpszDocTitle;
            m_fileHandler.Save();
            return true;
        }

        /// <summary>
        /// set txtextcontol modified value to true/false
        /// </summary>
        /// <param name="value"></param>
        public void SetModified(bool value)
        {
            this.editorControl.IsDocumentModified = false;
            this.editorControl.mnuSaveAndExit.Enabled = false;
        }

        /// <summary>
        /// Check whether document is modified or not
        /// </summary>
        public bool IsModified
        {
            get
            {
                
                if (this.editorControl.IsDocumentModified)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }

        }

        /// <summary>
        /// Print Preview
        /// </summary>
        public void Preview()
        {
            editorControl.PrintPreview();
        }

        /// <summary>
        /// Enable or Disable PrintPreview menu
        /// </summary>
        public bool EnableOrDisableMnuPrintPreview
        {
            set
            {
                _mnuPreviewEnable = value;
                this.editorControl.mnuPrintPreview.Enabled = _mnuPreviewEnable;
            }
        }

        /// <summary>
        /// Insert table - nRows -number of rows, nCols - number of columns
        /// </summary>
        /// <param name="nRows"></param>
        /// <param name="nCols"></param>
        /// <returns></returns>
        public bool InsertTable(int nRows, int nCols)
        {

            if (editorControl.textControl1.Tables.Add(nRows, nCols))
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        /// <summary>
        /// Search word in  TxTextControl
        /// </summary>
        /// <param name="nFlags"></param>
        /// <param name="lpszText"></param>
        /// <param name="nDisplayError"></param>
        /// <returns></returns>
        public int Search(int nFlags, string lpszText, int nDisplayError)
        {
            return editorControl.textControl1.Find(lpszText);
        }

        /// <summary>
        ///  Replace word in  TxTextControl
        /// </summary>
        /// <param name="pszText"></param>
        /// <param name="nTextWidth"></param>
        /// <returns></returns>
        public bool ReplaceSel(string pszText, int nTextWidth)
        {
            editorControl.textControl1.Replace();
            return true;
        }

        /// <summary>
        /// Set TxTextcontrol text format
        /// </summary>
        /// <param name="highEditFileFormat"></param>
        /// <returns></returns>
        private int ConvertHighEditFormtToTxFormat(int highEditFileFormat)
        {
            //'HighEdit formats
            //'Global Const FILEFORMAT_HIGHEDIT = 0
            //'Global Const FILEFORMAT_ANSI = 1
            //'Global Const FILEFORMAT_OEM = 2
            //'Global Const FILEFORMAT_RTF = 3
            if (highEditFileFormat == 1)
                return 1;
            else
                return 5;

            //'Optional. Specifies a format identifier. When not specified Text Control assumes Text Control's internal format (3). Otherwise it can be one of the following values:
            //'Constant Description
            //'1 - ANSI text       Text in Windows ANSI format (an end of a paragraph is marked with the control characters 13 and 10).
            //'2 - TX text     Text in ANSI format (an end of a paragraph is marked only with the control character 10).
            //'3 - TX      Text including formatting attributes in the internal Text Control format. Text is stored in ANSI.
            //'4 - HTML        HTML format (Hypertext Markup Language).
            //'5 - RTF     RTF format (Rich Text Format).
            //'6 - Unicode text        Text in Windows Unicode format (an end of a paragraph is marked with the control characters 13 and 10).
            //'7 - TX text     Text in Unicode format (an end of a paragraph is marked only with the control character 10).
            //'8 - TX      Text including formatting attributes in the internal Text Control format. Text is stored in Unicode.
            //'9 - Microsoft Word 97-2003      Microsoft Word 97-2003 format (*.doc).
            //'10 - XML        XML format (Extensible Markup Language).
            //'11 - CSS        CSS format (Cascading Style Sheet).
            //'13 - Microsoft Word     Microsoft Word format (*.docx).
            //'15 - SpreadsheetML      SpreadsheetML format (*.xlsx).
        }

        /// <summary>
        /// Insert row to table
        /// </summary>
        /// <returns></returns>
        public bool InsertTableRow()
        {
            try
            {
                editorControl.textControl1.Tables.GetItem().Rows.Add(TXTextControl.TableAddPosition.Before, 1);
                return true;
            }
            catch (Exception exc)
            {
                MessageBox.Show(exc.Message, "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
        }

        /// <summary>
        /// Insert Picture to TxTextControl
        /// </summary>
        /// <param name="lpszFilename"></param>
        /// <param name="nFormat"></param>
        /// <returns></returns>
        public bool LoadPicture(string lpszFilename, int nFormat)
        {
            TXTextControl.Image imageNew = new TXTextControl.Image();
            try
            {
                editorControl.textControl1.Images.Add(imageNew, TXTextControl.HorizontalAlignment.Left, -1, TXTextControl.ImageInsertionMode.DisplaceText);
                return true;
            }
            catch (Exception exc)
            {
                MessageBox.Show(exc.Message, "", MessageBoxButtons.OK, MessageBoxIcon.Error);
                return false;
            }
        }

        /// <summary>
        /// Check user want to print document or not
        /// </summary>
        /// <param name="lpszDocTitle"></param>
        /// <param name="nPageCounter"></param>
        /// <returns></returns>
        public bool PrintDocAbortDlg(string lpszDocTitle, string strPrinterName)
        {

            PrintDocument prndoc = new PrintDocument();
            PrinterSettings settings = new PrinterSettings();

            if (!String.IsNullOrEmpty(strPrinterName))
            {
                prndoc.PrinterSettings.PrinterName = settings.PrinterName;

				if (prndoc.PrinterSettings.Copies == 0)
				{
					prndoc.PrinterSettings.Copies = 1;
				}
                editorControl.textControl1.Print(prndoc);
            }
            else
            {
                editorControl.textControl1.Print("document");
            }
            return true;
        }

        public void CursorHome()
        {
            editorControl.textControl1.Focus();
        }

        /// <summary>
        /// Set default printer
        /// </summary>
        /// <param name="lpszPrinter"></param>
        /// <returns></returns>
        public bool SetInstancePrinter(string lpszPrinter)
        {
            myPrinters.SetDefaultPrinter(lpszPrinter);
            return true;
        }
    }

    /// <summary>
    /// 
    /// </summary>
    public static class myPrinters
    {
        [DllImport("winspool.drv", CharSet = CharSet.Auto, SetLastError = true)]
        public static extern bool SetDefaultPrinter(string Name);

    }
}
