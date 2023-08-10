/*-------------------------------------------------------------------------------------------------------------
** program        TX Text Control Words
**
** copyright:     © Text Control GmbH
**-----------------------------------------------------------------------------------------------------------*/
using System;
using TXTextControl;
using System.Collections.Specialized;
using System.IO;
using System.ComponentModel;
using System.Windows.Forms;
using TextControlEditorPharmacyClient.Properties;


namespace TextControlEditorPharmacyClient.FileHandling
{

	public class FileHandler : INotifyPropertyChanged {

		/*------------------------------------------------------------------------------------------------
		** M E M B E R S
		**----------------------------------------------------------------------------------------------*/

		private TextControl m_textControl;
		private bool m_isDocumentDirty = false;
		private string m_documentFileName = "";
		private StringCollection m_recentFiles;
		private int m_maxRecentFiles = 10;
        private StreamType m_streamType = StreamType.RichTextFormat;
		private UserDefinedPropertyDictionary m_userDefinedPropertyDictionary;
		private string m_author = "";
		private DateTime m_creationDate;
		private string m_creatorApplication = "";
		private string m_documentBasePath = "";
		private string[] m_documentKeywords = new string[]{};
		private string m_documentSubject = "";
		private string m_documentTitle = "";
		private string m_masterPassword = "";
		private string m_pdfUserPwd = "";
		private bool m_CanSave;

		/*------------------------------------------------------------------------------------------------
		** P U B L I C   E V E N T S
		**----------------------------------------------------------------------------------------------*/

		public event PropertyChangedEventHandler PropertyChanged;
		public event EventHandler<ShowMessageBoxEventArgs> ShowMessageBox;
		public event EventHandler<DocumentDirtyChangedEventArgs> DocumentDirtyChanged;
		public event EventHandler<DocumentFileNameChangedEventArgs> DocumentFileNameChanged;
		public event EventHandler RecentFileListChanged;
		public event EventHandler<UserInputRequestedEventArgs> UserInputRequested;

		// Create the OnPropertyChanged method to raise the event
		protected void OnPropertyChanged(string name) {
			PropertyChangedEventHandler handler = PropertyChanged;
			if (handler != null) {
				handler(this, new PropertyChangedEventArgs(name));
			}
		}

		/*------------------------------------------------------------------------------------------------
		** C O N S T A N T S
		**----------------------------------------------------------------------------------------------*/

		private const StreamType DefaultSaveTypes
			= (StreamType.All & ~(StreamType.XMLFormat | StreamType.CascadingStylesheet | StreamType.PlainAnsiText | StreamType.SpreadsheetML));
		private const StreamType DefaultExportTypes = StreamType.AdobePDF | StreamType.AdobePDFA | StreamType.CascadingStylesheet;
		private const StreamType DefaultLoadTypes = StreamType.All & ~StreamType.CascadingStylesheet;
		private const StreamType DefaultInsertTypes = StreamType.All & ~DefaultExportTypes;

		/*------------------------------------------------------------------------------------------------
		** C O N S T R U C T O R
		**----------------------------------------------------------------------------------------------*/

		public FileHandler(TextControl textControl) {
			m_textControl = textControl;
			CssFileName = "";
			CssSaveMode = TXTextControl.CssSaveMode.None;
			DocumentFileName = "";
			PDFCertFilePath = "";
			PDFCertPasswd = "";
			PDFUserPassword = "";
			m_recentFiles = new StringCollection();
			PDFImportSettings = TXTextControl.PDFImportSettings.GenerateTextFrames;

			// Observe corresponding properties for refreshing the CanSave State on changes
			this.PropertyChanged += (sender, propargs) => { if (propargs.PropertyName == "StreamType" || propargs.PropertyName == "IsDocumentDirty") RefreshCanSave(); };
		}


		/*-------------------------------------------------------------------------------------------------------
		** GetNotAvailableFileFormatMessage method
		** Extracts required version from exception's message and returns a new specific message from filehandler
		**--------------------------------------------------------------                ---------------------------------------*/
		private string GetNotAvailableFileFormatMessage(TXTextControl.LicenseLevelException exc) {
			// Construct the message about the not available file format on product level X
			//string strNAFileFormatTemplate = Properties.Resources.FILEHANDLER_MSGTEMPLATE_NAFILEFORMAT;
			VersionInfo vInfo = m_textControl.GetVersionInfo();
			//string strNAFileFormat = string.Format(strNAFileFormatTemplate, vInfo.Level.ToString());

			// Remove first sentence for getting the message about the minimum product level
			string strMinimumLicenseLevel = exc.Message.Remove(0, exc.Message.IndexOf('.') + 1);
			//return strNAFileFormat + strMinimumLicenseLevel
             return   strMinimumLicenseLevel;
		}

		/*------------------------------------------------------------------------------------------------
		** P U B L I C   M E T H O D S
		**----------------------------------------------------------------------------------------------*/

		/*-------------------------------------------------------------------------------------------------------
		** OpenRecentFile method
		**-----------------------------------------------------------------------------------------------------*/
        public void OpenRecentFile(string fileName)
        {
            // Check if file exists
            if (File.Exists(fileName)) Open(fileName);
            else
            {
                var e = new ShowMessageBoxEventArgs(
                    TextControlEditorPharmacyClient.Properties.Resources.MSG_REMOVE_FILE_FROM_LIST,
                    MessageBoxButton.YesNo, MessageBoxIcon.Question);
                OnShowMessageBox(e);
                if (e.DialogResult == DialogResult.Yes)
                {
                    RemoveRecentFile(fileName);
                }
            }
            
        }


		/*-------------------------------------------------------------------------------------------------------
		** Open method
		** Opens a file by file's path passed by "fileName"
		**-----------------------------------------------------------------------------------------------------*/
		public void Open(string fileName = "", bool bKeepPdfSecSettings = false) {
			if (!bKeepPdfSecSettings && !HandleUnsavedChanges()) return;

			// Store PDF security settings beforehand
			var pdfSecStorage = new {
				PDFCertFilePath = PDFCertFilePath,
				PDFCertPasswd = PDFCertPasswd,
				PDFUserPassword = PDFUserPassword,
				PDFSignature = PDFSignature,
			};

			// Clear pdf security settings
			if (!bKeepPdfSecSettings) {
				PDFCertFilePath = "";
				PDFCertPasswd = "";
				PDFUserPassword = "";
				PDFSignature = null;
			}

			var ls = new LoadSettings {
				ApplicationFieldFormat = ApplicationFieldFormat.HighEdit,
				LoadSubTextParts = true,
				PDFImportSettings = this.PDFImportSettings,
				UserPassword = this.PDFUserPassword,
				ReportingMergeBlockFormat = ReportingMergeBlockFormat.SubTextParts,
				DocumentPartName = String.Empty // Enable Load Dialog for Spreadsheets
			};

			try {
				if (string.IsNullOrEmpty(fileName)) {
					m_textControl.Load(DefaultLoadTypes, ls);
				}
				else {
					// First, check if file exists
					if (!File.Exists(fileName)) {
                        //var e = new ShowMessageBoxEventArgs(
                        //    string.Format(Properties.Resources.MSG_FILE_DOES_NOT_EXIST, fileName),
                        //    MessageBoxButton.OK, MessageBoxIcon.Error);
                        //OnShowMessageBox(e);
						return;
					}
					string ext = Path.GetExtension(fileName);
					StreamType streamType = ext.ToTXStreamType();
					if (streamType == (StreamType)(-1)) {
						//OnShowMessageBox(
                            //new ShowMessageBoxEventArgs(
                            //    string.Format(Properties.Resources.MSG_UNKNOWN_FILE_TYPE, ext),
                            //    MessageBoxButton.OK, MessageBoxIcon.Information));
						return;
					}

					// Try to load file
					m_textControl.Load(fileName, streamType, ls);
				}
			}
			catch (FilterException exc) {
				if (string.IsNullOrEmpty(fileName)) {
					fileName = ls.LoadedFile;
				}
				HandleFilterException(exc, fileName);
				return;
			}
			catch (LicenseLevelException exc) {
				string msg = GetNotAvailableFileFormatMessage(exc);
				OnShowMessageBox(new ShowMessageBoxEventArgs(msg, MessageBoxButton.OK, MessageBoxIcon.Error));
				return;
			}
			catch (MergeBlockConversionException exc) {
				HandleMergeBlockConversionException(exc);
			}
			catch (Exception exc) {
				OnShowMessageBox(new ShowMessageBoxEventArgs(exc.Message, MessageBoxButton.OK, MessageBoxIcon.Error));
				return;
			}

			// If LoadSettings.LoadedFile is set, a file was successfully loaded.
			if (!string.IsNullOrEmpty(ls.LoadedFile)) {
				DocumentFileName = ls.LoadedFile;
				IsDocTargetBased = (ls.ConvertedMergeBlocks > 0);
				StreamType = ls.LoadedStreamType;
				IsDocumentDirty = false;
				CssFileName = ls.CssFileName;
				CssSaveMode = TXTextControl.CssSaveMode.None;
				AddRecentFile(ls.LoadedFile);
				this.m_creatorApplication = ls.CreatorApplication;
				this.m_userDefinedPropertyDictionary = ls.UserDefinedDocumentProperties;
				this.m_author = ls.Author;
				this.m_documentBasePath = ls.DocumentBasePath;
				this.m_documentKeywords = ls.DocumentKeywords;
				this.m_documentSubject = ls.DocumentSubject;
				this.m_documentTitle = ls.DocumentTitle;
				this.m_masterPassword = ls.MasterPassword;
				this.PDFUserPassword = ls.UserPassword;
			}
			else if (!bKeepPdfSecSettings) {
				// If pdf security settings were reset but no file was loaded (e. g. because of the 
				// user pressing cancel in the file open dialog), revert pdf security settings here
				PDFCertFilePath = pdfSecStorage.PDFCertFilePath;
				PDFCertPasswd = pdfSecStorage.PDFCertPasswd;
				PDFUserPassword = pdfSecStorage.PDFUserPassword;
				PDFSignature = pdfSecStorage.PDFSignature;
			}
		}

		/*-------------------------------------------------------------------------------------------------------
		** Insert method
		** Opens the TX Text Control's dialog for inserting the document's content at selection
		**-----------------------------------------------------------------------------------------------------*/
		public void Insert() {
			var ls = new TXTextControl.LoadSettings {
				ApplicationFieldFormat = TXTextControl.ApplicationFieldFormat.HighEdit,
				LoadSubTextParts = true,
				DocumentPartName = ""
			};
			m_textControl.Selection.Load(DefaultInsertTypes, ls);
			if (ls.LoadedFile != "") {
				IsDocumentDirty = true;
			}
		}

		private void RefreshCanSave() {
			CanSave = m_isDocumentDirty &&										// - Changes are available
			(StreamType & DefaultSaveTypes) == StreamType		// - Can save document in same format
			;
		}

		/*-------------------------------------------------------------------------------------------------------
		** Save method
		** Saves TextControl's content to the file location specified in m_documentFileName 
		** otherwise opens TextControl's Save-Dialog
		**-----------------------------------------------------------------------------------------------------*/
		public bool Save() {
            //if (!CanSave) return false;
			ReportingMergeBlockFormat blockFormat;
			if (!TryDetermineMergeBlockSaveFormat(out blockFormat)) return false;
            //MessageBox.Show(TryDetermineMergeBlockSaveFormat(out blockFormat).ToString());
			var saveSettings = new SaveSettings {
				Author = this.m_author,
				CssFileName = this.CssFileName,
				CssSaveMode = this.CssSaveMode,
				DocumentBasePath = this.m_documentBasePath,
				DocumentKeywords = this.m_documentKeywords,
				DocumentSubject = this.m_documentSubject,
				DocumentTitle = this.m_documentTitle,
				LastModificationDate = DateTime.Now,
				MasterPassword = this.m_masterPassword,
				ReportingMergeBlockFormat = blockFormat,
				UserDefinedDocumentProperties = this.m_userDefinedPropertyDictionary,
				UserPassword = this.PDFUserPassword,
			};
			//if (PDFSignature != null) saveSettings.DigitalSignature = PDFSignature;
			try {
                //MessageBox.Show(m_documentFileName.ToString());
        
				if (!string.IsNullOrEmpty(m_documentFileName)) {
                    // Save with current name and type -    Save logic is moved to QuerySaveAndExit method
                    //m_textControl.Save(m_documentFileName, StreamType, saveSettings);
				}
				else {
					// Save As...
					m_textControl.Save(DefaultSaveTypes, saveSettings);
                   
				}
			}
			catch (LicenseLevelException exc) {
				string msg = GetNotAvailableFileFormatMessage(exc);
				OnShowMessageBox(new ShowMessageBoxEventArgs(msg, MessageBoxButton.OK, MessageBoxIcon.Error));
			}
			catch (Exception exc) {
				OnShowMessageBox(new ShowMessageBoxEventArgs(exc.Message, MessageBoxButton.OK, MessageBoxIcon.Error));
			}

			// If SaveSettings.SavedFile is set, a file was successfully saved.
			if (!string.IsNullOrEmpty(saveSettings.SavedFile)) {
				DocumentFileName = saveSettings.SavedFile;
				StreamType = saveSettings.SavedStreamType;
				IsDocumentDirty = false;
				AddRecentFile(m_documentFileName);

				return true;
			}

			return false;
		} // Save


		/*-------------------------------------------------------------------------------------------------------
		** SaveAs method
		** Opens TextControl's Save Dialog with the specified available StreamTypes
		**-----------------------------------------------------------------------------------------------------*/
		public void SaveAs(StreamType? streamType = null) {
			ReportingMergeBlockFormat blockFormat;
			if (!TryDetermineMergeBlockSaveFormat(out blockFormat)) return;

			var saveSettings = new SaveSettings {
				Author = this.m_author,
				CreationDate = this.m_creationDate,
				CreatorApplication = this.m_creatorApplication,
				CssFileName = this.CssFileName,
				CssSaveMode = this.CssSaveMode,
				DocumentBasePath = this.m_documentBasePath,
				DocumentKeywords = this.m_documentKeywords,
				DocumentSubject = this.m_documentSubject,
				DocumentTitle = this.m_documentTitle,
				MasterPassword = this.m_masterPassword,
				ReportingMergeBlockFormat = blockFormat,
				UserDefinedDocumentProperties = this.m_userDefinedPropertyDictionary,
				UserPassword = this.PDFUserPassword,
			};

			if (PDFSignature != null) saveSettings.DigitalSignature = PDFSignature;

			streamType = streamType ?? DefaultSaveTypes;
			try {

				m_textControl.Save(streamType.Value, saveSettings);

			}
			catch (LicenseLevelException exc) {

				string msg = GetNotAvailableFileFormatMessage(exc);
				OnShowMessageBox(new ShowMessageBoxEventArgs(msg, MessageBoxButton.OK, MessageBoxIcon.Error));

			}
			catch (Exception exc) {

				OnShowMessageBox(new ShowMessageBoxEventArgs(exc.Message, MessageBoxButton.OK, MessageBoxIcon.Error));
			}

			// If SaveSettings.SavedFile is set, a file was successfully saved.
			if (!string.IsNullOrEmpty(saveSettings.SavedFile)) {
				DocumentFileName = saveSettings.SavedFile;
				StreamType = saveSettings.SavedStreamType;
				IsDocumentDirty = false;
				AddRecentFile(m_documentFileName);
			}
		}


		/*-------------------------------------------------------------------------------------------------------
		** New method
		** Clears TextControl's content and resets the default properties of the last loaded document
		**-----------------------------------------------------------------------------------------------------*/
		public bool New() {
            if (!HandleUnsavedChanges()) return false;
            m_textControl.ResetContents();
			IsDocumentDirty = false;
			DocumentFileName = "";
			IsDocTargetBased = false;
			PDFUserPassword = "";
			PDFCertFilePath = "";
			PDFCertPasswd = "";
			PDFSignature = null;
			this.m_author = "";
			this.m_creationDate = DateTime.Now;
			this.m_creatorApplication = "";
			this.m_documentBasePath = "";
			this.m_documentKeywords = null;
			this.m_documentSubject = "";
			this.m_documentTitle = "";
			this.m_masterPassword = "";
			this.m_userDefinedPropertyDictionary = null;
			return true;
		}


		/*-------------------------------------------------------------------------------------------------------
		** ExitApplication method
		** Notifies about the request for closing the application and handles unsaved changes.
		**-----------------------------------------------------------------------------------------------------*/
		public bool ExitApplication() {
			return HandleUnsavedChanges();
		}


		/*-------------------------------------------------------------------------------------------------------
		** HandleUnsavedChanges method
		** Shows a request dialog if the document contains unsaved changes. The dialog asks for saving or rejecting 
		** the changes.
		**-----------------------------------------------------------------------------------------------------*/
		public bool HandleUnsavedChanges() {
			if (IsDocumentDirty) {
				 //If there are unsaved changes, make the caller show a message box
				string msg = string.Format(TextControlEditorPharmacyClient.Properties.Resources.SAVE_CHANGES_TO, DocumentTitle);
				var args = new ShowMessageBoxEventArgs(msg, MessageBoxButton.YesNoCancel, MessageBoxIcon.Question);
				OnShowMessageBox(args);
                switch (args.DialogResult) {
                    case DialogResult.Cancel:
                        return false;

                    case DialogResult.Yes:
                        if (CanSave) {
                            Save();
                        }
                        else {
                            SaveAs();
                        }
                        if (string.IsNullOrEmpty(m_documentFileName)) return false;
                        break;
                }
			}
			return true;
		}

		/*-------------------------------------------------------------------------------------------------------
		** RemoveRecentFile method
		** Removes the file from the recent files list.
		**-----------------------------------------------------------------------------------------------------*/
		internal void RemoveRecentFile(string path) {
			int nFiles = m_recentFiles.Count;
			m_recentFiles.Remove(path);
			if (m_recentFiles.Count < nFiles) {
				OnRecentFileListChanged();
			}
		}

		/*------------------------------------------------------------------------------------------------
		** P R O P E R T I E S
		**----------------------------------------------------------------------------------------------*/

		/*-------------------------------------------------------------------------------------------------------
		** CanSave
		**-----------------------------------------------------------------------------------------------------*/
		public bool CanSave {
			get {
				return m_CanSave;
			}
			private set {
				m_CanSave = value;
				OnPropertyChanged("CanSave");
			}
		}

		/*-------------------------------------------------------------------------------------------------------
		** StreamType
		**-----------------------------------------------------------------------------------------------------*/
		public StreamType StreamType {
			get { return m_streamType; }
			private set {
				m_streamType = value;
				OnPropertyChanged("StreamType");
			}
		}

		/*-------------------------------------------------------------------------------------------------------
		** IsDocumentDirty
		**-----------------------------------------------------------------------------------------------------*/
		public bool IsDocumentDirty {
			get { return m_isDocumentDirty; }
			set {
				SetDocumentDirty(value);
				OnPropertyChanged("IsDocumentDirty");
			}
		}

		/*-------------------------------------------------------------------------------------------------------
		** CssFileName
		**-----------------------------------------------------------------------------------------------------*/
		public string CssFileName { get; set; }


		/*-------------------------------------------------------------------------------------------------------
		** CssSaveMode
		**-----------------------------------------------------------------------------------------------------*/
		public CssSaveMode CssSaveMode { get; set; }

		/*-------------------------------------------------------------------------------------------------------
		** PDFUserPassword
		**-----------------------------------------------------------------------------------------------------*/
		public string PDFUserPassword {
			get { return m_pdfUserPwd; }
			set { m_pdfUserPwd = value; }
		}

		/*-------------------------------------------------------------------------------------------------------
		** PDFImportSettings
		**-----------------------------------------------------------------------------------------------------*/
		public PDFImportSettings PDFImportSettings { get; set; }

		/*-------------------------------------------------------------------------------------------------------
		** PDFCertPasswd
		**-----------------------------------------------------------------------------------------------------*/
		public string PDFCertPasswd { get; set; }

		/*-------------------------------------------------------------------------------------------------------
		** PDFCertFilePath
		**-----------------------------------------------------------------------------------------------------*/
		public string PDFCertFilePath { get; set; }

		/*-------------------------------------------------------------------------------------------------------
		** PDFSignature
		**-----------------------------------------------------------------------------------------------------*/
		public DigitalSignature PDFSignature { get; set; }

		/*-------------------------------------------------------------------------------------------------------
		** IsDocTargetBased
		**-----------------------------------------------------------------------------------------------------*/
		public bool IsDocTargetBased { get; private set; }

		/*-------------------------------------------------------------------------------------------------------
		** MaxRecentFiles
		**-----------------------------------------------------------------------------------------------------*/
		public int MaxRecentFiles {
			get { return m_maxRecentFiles; }
			set {
				if (value < 1) throw new IndexOutOfRangeException();
				m_maxRecentFiles = value;
				int count = m_recentFiles.Count;
				TrimRecentFilesList();
				if (m_recentFiles.Count < count) OnRecentFileListChanged();
			}
		}

		/*-------------------------------------------------------------------------------------------------------
		** RecentFiles
		**-----------------------------------------------------------------------------------------------------*/
		public StringCollection RecentFiles {
			get { return m_recentFiles; }
			set {
				m_recentFiles = value ?? new StringCollection();
				TrimRecentFilesList();
				OnRecentFileListChanged();
			}
		}

		/*-------------------------------------------------------------------------------------------------------
		** DocumentFileName
		**-----------------------------------------------------------------------------------------------------*/
		public string DocumentFileName {
			get { return m_documentFileName; }
			 set {
				value = value ?? "";
				string oldValue = m_documentFileName;
				m_documentFileName = value;
				if (value != oldValue) {
					OnDocumentFileNameChanged(value);
				}
			}
		}

		/*-------------------------------------------------------------------------------------------------------
		** DocumentTitle
		**-----------------------------------------------------------------------------------------------------*/
		public string DocumentTitle {
			get {
				return 
                    //string.IsNullOrEmpty(m_documentFileName)
                    //? Properties.Resources.DOC_TITLE_UNTITLED :
                    Path.GetFileName(m_documentFileName);
			}
		}

		/*------------------------------------------------------------------------------------------------
		** E V E N T    I N V O K E R S
		**----------------------------------------------------------------------------------------------*/

		/*-------------------------------------------------------------------------------------------------------
		** OnShowMessageBox method
		** Invokes the ShowMessageBox Event.
		**-----------------------------------------------------------------------------------------------------*/
		protected virtual void OnShowMessageBox(ShowMessageBoxEventArgs e) {
			if (ShowMessageBox != null) {
				ShowMessageBox(this, e);
			}
		}

		/*-------------------------------------------------------------------------------------------------------
		** OnDocumentDirtyChanged method
		** Invokes the DocumentDirtyChanged Event and sends the new value of the document dirty property.
		**-----------------------------------------------------------------------------------------------------*/
		protected virtual void OnDocumentDirtyChanged(bool newValue) {
			if (DocumentDirtyChanged != null) {
				DocumentDirtyChanged(this, new DocumentDirtyChangedEventArgs(newValue));
			}
		}

		/*-------------------------------------------------------------------------------------------------------
		** OnDocumentFileNameChanged method
		** Invokes the DocumentFileNameChanged Event and sends the new value of the filename.
		**-----------------------------------------------------------------------------------------------------*/
		protected virtual void OnDocumentFileNameChanged(string newName) {
			if (DocumentFileNameChanged != null) {
				DocumentFileNameChanged(this, new DocumentFileNameChangedEventArgs(newName));
			}
		}

		/*-------------------------------------------------------------------------------------------------------
		** OnRecentFileListChanged method
		** Invokes the RecentFileListChanged Event.
		**-----------------------------------------------------------------------------------------------------*/
		protected virtual void OnRecentFileListChanged() {
			if (RecentFileListChanged != null) {
				RecentFileListChanged(this, EventArgs.Empty);
			}
		}

		/*-------------------------------------------------------------------------------------------------------
		** OnUserInputRequested method
		** Invokes the UserInputRequested Event.
		**-----------------------------------------------------------------------------------------------------*/
		protected virtual void OnUserInputRequested(UserInputRequestedEventArgs e) {
			if (UserInputRequested != null) {
				UserInputRequested(this, e);
			}
		}

		/*------------------------------------------------------------------------------------------------
		** H E L P E R S
		**----------------------------------------------------------------------------------------------*/

		/*-------------------------------------------------------------------------------------------------------
		** SetDocumentDirty method
		** Sets the Document Dirty state and invokes the DocumentDirtyChanged Event on change.
		**-----------------------------------------------------------------------------------------------------*/
		private void SetDocumentDirty(bool value) {
			bool oldValue = m_isDocumentDirty;
			m_isDocumentDirty = value;
			if (value != oldValue) OnDocumentDirtyChanged(value);
		}

		/*-------------------------------------------------------------------------------------------------------
		** AddRecentFile method
		** Adds a file at the beginning of the recent files. Removes the file from list first if it exists
		** and throws RecentFileListChanged event.
		**-----------------------------------------------------------------------------------------------------*/
		private void AddRecentFile(string fileName) {
			// First, remove the file name if it already exists
			for (int i = m_recentFiles.Count - 1; i >= 0; --i) {
				if (m_recentFiles[i].ToLower() == fileName.ToLower()) {
					m_recentFiles.RemoveAt(i);
					break;
				}
			}

			// Add file name
			m_recentFiles.Insert(0, fileName);
			TrimRecentFilesList();

			// Fire event
			OnRecentFileListChanged();
		}

		/*-------------------------------------------------------------------------------------------------------
		** TrimRecentFilesList method
		** Removes the last file entry from recentfiles until the maximum count is reached.
		**-----------------------------------------------------------------------------------------------------*/
		private void TrimRecentFilesList() {
			while (m_recentFiles.Count > m_maxRecentFiles) m_recentFiles.RemoveAt(m_recentFiles.Count - 1);
		}

		/*-------------------------------------------------------------------------------------------------------
		** HandleFilterException method
		**-----------------------------------------------------------------------------------------------------*/
		private void HandleFilterException(FilterException exc, string fileName) {
			switch (exc.Reason) {
				case FilterException.FilterError.InvalidPassword:
                    //var args = new UserInputRequestedEventArgs(
                    //    PDFUserPassword, Properties.Resources.USR_INP_PASSWORD_TITLE,
                    //    Properties.Resources.USR_INP_PASSWORD_LABEL, true, UserInputRequestReason.PdfUserPassword);
                    //OnUserInputRequested(args);
                    //switch (args.DialogResult) {
                    //    case DialogResult.OK:
                    //        PDFUserPassword = args.Value ?? "";
                    //        Open(fileName, true);	// Try to open file again with user password set
                    //        return;

                    //    case DialogResult.Cancel:
                    //        return;	// Do nothing.
                    //}
					break;
			}
			OnShowMessageBox(new ShowMessageBoxEventArgs(exc.Message, MessageBoxButton.OK, MessageBoxIcon.Error));
		}


		/*-------------------------------------------------------------------------------------------------------
		** HandleMergeBlockConversionException method
		**-----------------------------------------------------------------------------------------------------*/
		private void HandleMergeBlockConversionException(MergeBlockConversionException exc) {
			string blockList = string.Join("\r\n", exc.BlockNamesUnconverted.ToArray());
			//string strMsg = string.Format(Properties.Resources.EXC_MERGE_BLOCK_CONVERSION, blockList);
			//var e = new ShowMessageBoxEventArgs(strMsg, MessageBoxButton.OK, MessageBoxIcon.Information);
			//OnShowMessageBox(e);
		}

		/*-------------------------------------------------------------------------------------------------------
		** ConfirmSaveSubTextPartBlocks method
		**-----------------------------------------------------------------------------------------------------*/
		internal bool? ConfirmSaveSubTextPartBlocks(StreamType streamType = (StreamType) (0)) {
			// Never convert to subtextparts in case of formats not supporting them
			if ((streamType & (StreamType.InternalFormat | StreamType.InternalUnicodeFormat
					| StreamType.WordprocessingML | StreamType.RichTextFormat | StreamType.MSWord)) == 0) return false;

			// User interaction
            //var args = new ShowMessageBoxEventArgs(
            //    Properties.Resources.MSG_CONFIRM_UPDATE_MERGE_BLOCK_TYPE,
            //    MessageBoxButton.YesNoCancel, MessageBoxIcon.Question);
            //OnShowMessageBox(args);

            //switch (args.DialogResult) {
            //    case DialogResult.Yes:
            //        return true;

            //    case DialogResult.No:
            //        return false;

            //    case DialogResult.Cancel:
            //        return null;
            //}
			return false;
		}

		/*-------------------------------------------------------------------------------------------------------
		** TryDetermineMergeBlockSaveFormat method
		**-----------------------------------------------------------------------------------------------------*/
		private bool TryDetermineMergeBlockSaveFormat(out ReportingMergeBlockFormat blockFormat) {
			blockFormat = ReportingMergeBlockFormat.SubTextParts;
			// Check if subtextpart based merge blocks should be 
			// converted back to "old style" merge blocks
			if (IsDocTargetBased) {
				bool? bSubTextParts = ConfirmSaveSubTextPartBlocks(StreamType);
				if (bSubTextParts == false) blockFormat = ReportingMergeBlockFormat.DocumentTargets;
				else if (bSubTextParts == null) return false;
			}
			return true;
		}
	}

	/*------------------------------------------------------------------------------------------------
	** S T R E A M T Y P E   E X T E N S I O N S
	**----------------------------------------------------------------------------------------------*/
	public static partial class Extensions {
		public static StreamType ToTXStreamType(this string fileExt) {
			switch (fileExt.ToLower()) {
				case ".rtf":
					return StreamType.RichTextFormat;

				case ".htm":
				case ".html":
					return StreamType.HTMLFormat;

				case ".tx":
					return StreamType.InternalUnicodeFormat;

				case ".doc":
					return StreamType.MSWord;

				case ".docx":
					return StreamType.WordprocessingML;

				case ".pdf":
					return StreamType.AdobePDF;

				case ".txt":
					return StreamType.PlainText;

				case ".xlsx":
					return StreamType.SpreadsheetML;
			}
			return (StreamType)(-1);
		}
	}
}
