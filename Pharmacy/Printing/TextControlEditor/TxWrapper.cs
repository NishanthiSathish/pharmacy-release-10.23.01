using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Forms;

namespace TextControlEditorPharmacyClient
{
    /// <summary>
    /// 
    /// </summary>
    public class TxWrapper
    {
        private object _tag;
        private HeEmulator _heHolder;
        private string _mnuInsert;
        private string _mnuInsertHdg;

        /// <summary>
        /// 
        /// </summary>
        public TxWrapper()
        {
            if (He == null)
            {
                He = new HeEmulator();
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public HeEmulator He
        {
            get
            {
                return _heHolder;
            }
            set
            {
                _heHolder = value;
            }
        }
        
        /// <summary>
        /// Set and get tag for TxTextControl
        /// </summary>
        public object Tag
        {
            get
            {
                _tag = He.editorControl.textControl1.Tag;
                return _tag;
            }
            set
            {
                _tag = value;
                He.editorControl.textControl1.Tag = _tag;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public string mnuInsert
        {
            get
            {
                return _mnuInsert;
            }
            set
            {
                _mnuInsert = value;
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public string mnuInsertHdg
        {
            get
            {
                return _mnuInsertHdg;
            }
            set
            {
                _mnuInsertHdg = value;
            }
        }

        
        /// <summary>
        /// Show TxTextControl as model window
        /// </summary>
        /// <param name="modal"></param>
        public void Show(int modal)
        {
            //TODO - Menu buttons not enable when we use showdialog
            He.editorControl.MinimumSize = new System.Drawing.Size(2000, 2000);
            He.editorControl.WindowState = FormWindowState.Maximized;
            He.editorControl.ShowDialog();
        }

        /// <summary>
        /// Show TxTextControl as model window
        /// </summary>
        /// <param name="modal"></param>
        public string Shows(int modal)
        {
            //TODO - Menu buttons not enable when we use showdialog
            He.editorControl.MinimumSize = new System.Drawing.Size(2000, 2000);
            He.editorControl.WindowState = FormWindowState.Maximized;
            He.editorControl.ShowDialog();
            if (He.editorControl.blnSaveAndExit)
            {
                return He.editorControl.RTFPath;
            }
            else
                return "";
        }
        
        /// <summary>
        /// Undoad TxTextControl
        /// </summary>
        public void Unload()
        {
            He.editorControl.Close();
        }


        //private string _menuInsert
        //public int MenuInsert { 
        //    get{_menuInsert=HeHolder.editorControl.mnuEdit}
        //    set { }
        //}
        //Private Property Get mnuInsert() As Variant
        //    'mnuInsert = mnuInssertReference
        //    mnuInsert = FrmTxEditor.mnuEdit
        //End Property

        //Public Property Let mnuInsert(ByVal value As Variant)
        //    mnuInssertReference = value
        //End Property

        //Public Property Get mnuInsertHdg() As Object
        //    Set mnuInsertHdg = mnuInssertHdgReference
        //End Property

        //Public Property Let mnuInsertHdg(ByVal value As Object)
        //    mnuInssertHdgReference = value
        //End Property

        //Public Property Get mnuPreview() As Object
        //    Set mnuInsertHdg = mnuInssertHdgReference
        //End Property

        //Public Property Let mnuPreview(ByVal value As Object)
        //    mnuInssertHdgReference = value
        //End Property
    }
}
