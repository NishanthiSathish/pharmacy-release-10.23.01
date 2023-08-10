/*-------------------------------------------------------------------------------------------------------------
** program        TX Text Control Words
**
** copyright:     © Text Control GmbH
**-----------------------------------------------------------------------------------------------------------*/
using System;

namespace TextControlForm.FileHandling
{

	/*------------------------------------------------------------------------------------------------
	** E N U M S
	**----------------------------------------------------------------------------------------------*/

	public enum MessageBoxButton {
		OK, OKCancel,
		AbortRetryIgnore,
		YesNoCancel,
		YesNo, RetryCancel
	}

	public enum MessageBoxIcon {
		None,
		Error,
		Question,
		Exclamation,
		Information
	}

	public enum DialogResult {
		OK, Cancel, Yes, No
	}

	/*------------------------------------------------------------------------------------------------
	** C L A S S
	**----------------------------------------------------------------------------------------------*/
	public class ShowMessageBoxEventArgs : EventArgs {

		/*------------------------------------------------------------------------------------------------
		** C O N S T R U C T O R
		**----------------------------------------------------------------------------------------------*/

		public ShowMessageBoxEventArgs(string text, string caption, MessageBoxButton button, MessageBoxIcon icon) {
			Text = text;
			Caption = caption;
			Button = button;
			Icon = icon;
			this.DialogResult = DialogResult.Cancel;
		}

		public ShowMessageBoxEventArgs(string text)
			: this(text, null, MessageBoxButton.OK, MessageBoxIcon.None) { }

		public ShowMessageBoxEventArgs(string text, string caption)
			: this(text, caption, MessageBoxButton.OK, MessageBoxIcon.None) { }

		public ShowMessageBoxEventArgs(string text, MessageBoxButton button)
			: this(text, null, button, MessageBoxIcon.None) { }

		public ShowMessageBoxEventArgs(string text, MessageBoxButton button, MessageBoxIcon icon)
			: this(text, null, button, icon) { }

		/*------------------------------------------------------------------------------------------------
		** P U B L I C   P R O P E R T I E S
		**----------------------------------------------------------------------------------------------*/

		/*------------------------------------------------------------------------------------------------
		** DialogResult
		**----------------------------------------------------------------------------------------------*/
		public DialogResult DialogResult { get; set; }

		/*------------------------------------------------------------------------------------------------
		** Button
		**----------------------------------------------------------------------------------------------*/
		public MessageBoxButton Button { get; private set; }

		/*------------------------------------------------------------------------------------------------
		** Icon
		**----------------------------------------------------------------------------------------------*/
		public MessageBoxIcon Icon { get; private set; }

		/*------------------------------------------------------------------------------------------------
		** Text
		**----------------------------------------------------------------------------------------------*/
		public string Text { get; private set; }

		/*------------------------------------------------------------------------------------------------
		** Caption
		**----------------------------------------------------------------------------------------------*/
		public string Caption { get; private set; }

	}
}
