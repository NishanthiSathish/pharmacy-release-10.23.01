/*-------------------------------------------------------------------------------------------------------------
** program:			TX Text Control Words
** description:	Implements a typical word processing application build up on the main features of TextControl's Components. 
**
** copyright:		© Text Control GmbH
**-----------------------------------------------------------------------------------------------------------*/
using System;
using System.Diagnostics;
using System.Drawing.Printing;
using System.IO;
using System.Reflection;
using TXTextControl;
using TXTextControl.Windows.Forms.Ribbon;

namespace TextControlEditorPharmacyClient
{

    public partial class frmTextControlEditor
    {   

		void BtnPrintPreview_Click(object sender, EventArgs e) {
			PrintPreview();
		}

		void BtnPrintQuick_Click(object sender, EventArgs e) {
			PrintQuick();
		}		

		private void PrintQuick() {
			textControl1.Print(new PrintDocument()
			{
				PrinterSettings = new PrinterSettings()
				{
					FromPage = 1,
					ToPage = textControl1.Pages,
					Copies = 1,
					Collate = true,
					PrintFileName = m_fileHandler.DocumentTitle + " - " + ProductName
				},
			});
		}

	}
}