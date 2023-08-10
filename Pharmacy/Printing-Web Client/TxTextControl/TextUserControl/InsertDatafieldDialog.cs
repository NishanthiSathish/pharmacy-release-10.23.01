using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using TXTextControl;

namespace TextControlEditorWebClient
{
    public partial class InsertDataField : System.Windows.Forms.Form
    {

        public InsertDataField()
        {
            InitializeComponent();
        }
        public TXTextControl.TextControl tx;
        
        private void Form1_Load(object sender, System.EventArgs e)
        {
          
        }

        private void BtnOK_Click(object sender, EventArgs e)
        {
            try
            {
                string selectedItem = listBox1.Items[listBox1.SelectedIndex].ToString();

                TXTextControl.Section currentSection = tx.Sections.GetItem();
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
                    tx.HeaderFooterActivationStyle = TXTextControl.HeaderFooterActivationStyle.ActivateClick;
                    footerSection = currentSection.HeadersAndFooters.GetItem(TXTextControl.HeaderFooterType.Footer);
                }


                if (selectedItem == "{Page}")
                {
                    PageNumberField currentPageNumber = new PageNumberField(1, NumberFormat.ArabicNumbers);
                    footerSection.PageNumberFields.Add(currentPageNumber);
                    currentPageNumber.Name = "{Page}";
                }
                else if (selectedItem == "{Page Total}")
                {
                    PageNumberField totalPageNumbers = new PageNumberField();
                    totalPageNumbers.ShowNumberOfPages = true;
                    footerSection.PageNumberFields.Add(totalPageNumbers);
                    totalPageNumbers.Name = "{Page Total}";
                }
            }
            catch (Exception ex)
            {
                MessageBox.Show(ex.Message);

            }

            //Close();
        }

    }
}
