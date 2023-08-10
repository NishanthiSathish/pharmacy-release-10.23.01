﻿/*-------------------------------------------------------------------------------------------------------------
** program        TX Text Control Words
**
** copyright:     © Text Control GmbH
**-----------------------------------------------------------------------------------------------------------*/
using System;

namespace TextControlForm.FileHandling
{

	public class DocumentDirtyChangedEventArgs : EventArgs {

		/*-------------------------------------------------------------------------------------------------------
		** Constructor
		**-----------------------------------------------------------------------------------------------------*/
		public DocumentDirtyChangedEventArgs(bool newValue) {
			NewValue = newValue;
		}

		/*-------------------------------------------------------------------------------------------------------
		** NewValue
		** New state of the document dirty flag
		**-----------------------------------------------------------------------------------------------------*/
		public bool NewValue { get; private set; }
	}
}
