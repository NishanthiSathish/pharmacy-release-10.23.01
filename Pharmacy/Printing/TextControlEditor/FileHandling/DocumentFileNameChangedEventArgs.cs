/*-------------------------------------------------------------------------------------------------------------
** program        TX Text Control Words
**
** copyright:     © Text Control GmbH
**-----------------------------------------------------------------------------------------------------------*/
using System;

namespace TextControlEditorPharmacyClient.FileHandling
{

	public class DocumentFileNameChangedEventArgs : EventArgs {

		/*-------------------------------------------------------------------------------------------------------
		** Constructor
		**-----------------------------------------------------------------------------------------------------*/
		public DocumentFileNameChangedEventArgs(string newName) {
			NewName = newName;
		}

		/*-------------------------------------------------------------------------------------------------------
		** NewName
		** New value of document's filename.
		**-----------------------------------------------------------------------------------------------------*/
		public string NewName { get; private set; }
	}
}
