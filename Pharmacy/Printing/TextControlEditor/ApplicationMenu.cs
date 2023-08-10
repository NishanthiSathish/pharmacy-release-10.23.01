/*-------------------------------------------------------------------------------------------------------------
** program:			TX Text Control Words
** description:	Implements a typical word processing application build up on the main features of TextControl's Components. 
**
** copyright:		© Text Control GmbH
**-----------------------------------------------------------------------------------------------------------*/
using System;
using System.Collections.Specialized;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using TXTextControl.Windows.Forms.Ribbon;

namespace TextControlEditorPharmacyClient
{

	// Needed for click events on sample template buttons
	public enum SampleTemplateType {
		Invoice,
		PackingList,
		ShippingLabel
	}

    public partial class frmTextControlEditor
    {		

		private void SetRecentItemsList(StringCollection fileList) {
			// Remove all items except the header and the separator
			while (ribbon1.ApplicationMenuHelpPaneItems.Count > 2) {
				ribbon1.ApplicationMenuHelpPaneItems.RemoveAt(ribbon1.ApplicationMenuHelpPaneItems.Count - 1);
			}

			// Add a RibbonButton foreach file in the list
			int i = 0;
			foreach (string fileName in fileList) {
				var btn = new RibbonButton
				{
					Text = i + " " + Path.GetFileName(fileName),
					Tag = fileName,	// Save full file path in Tag property
					DisplayMode = IconTextRelation.NoIconLabeled,
					KeyTip = i.ToString()
				};
				((RibbonToolTip)btn.ToolTip).Description = fileName;
				ribbon1.ApplicationMenuHelpPaneItems.Add(btn);
				++i;
			}
		}      
        

		private void LocalizeAppMenu() {
            mnuNew.Text = Constants.APP_MENU_NEW;
            mnuSaveAndExit.Text = Constants.APP_MENU_SAVE;
			mnuPrint.Text = Constants.APP_MENU_PRINT;
            mnuPrintPreview.Text = Constants.APP_MENU_PRINT_PREVIEW;
            mnuExit.Text = Constants.APP_MENU_EXIT;
		}
	}

	public partial class AcceleratorHelper {
		public enum DesignerFramework {
			WPF,
			WINFORM
		}

		const char AcceleratorIdentificator_WINFORM = '&';
		const char AcceleratorIdentificator_WPF = '_';

		public static string GetAccelerator(string input, DesignerFramework environment) {
			if (input == null)
				throw new ArgumentNullException("input");

			System.Text.RegularExpressions.Match match = System.Text.RegularExpressions.Regex.Match(input, GetPattern(environment));
			if (match != null) {
				return match.Groups[1].Value;
			}

			return null;
		}

		private static string GetPattern(DesignerFramework targetFramework) {
			string pattern = "";
			switch (targetFramework) {
				case DesignerFramework.WINFORM:
					pattern += AcceleratorIdentificator_WINFORM;
					break;
				case DesignerFramework.WPF:
					pattern += AcceleratorIdentificator_WPF;
					break;
			}

			if (String.IsNullOrEmpty(pattern))
				throw new NotImplementedException("A pattern is not defined for this DesignerFramework: " + targetFramework.ToString());

			return pattern + "(.?)";

		}


		public class AcceleratorComparer : System.Collections.Generic.IComparer<String> {

		public AcceleratorHelper.DesignerFramework Framework { get; set; }

		public AcceleratorComparer(AcceleratorHelper.DesignerFramework framework) {
				Framework = framework;
			}

		public int Compare(String x, String y) {

				return String.IsNullOrEmpty(x) && String.IsNullOrEmpty(y) &&
					x.ToUpper() == y.ToUpper() ? 0 : -1; // Ignore Case
			}
		}
	}
}
