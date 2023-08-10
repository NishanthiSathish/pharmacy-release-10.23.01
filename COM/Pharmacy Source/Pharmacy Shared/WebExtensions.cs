//===========================================================================
//
//							      WebExtensions.cs
//
//  Provides extension methods for the various web controls
//
//	Modification History:
//	02Aug13 XN  24653 Written
//  29Oct13 XN  Added method GetAllControlsByType for control, and Value for
//              converting hidden field value string to a type. 
//  23Apr14 XN  Added methods LoadAscribeCoreControlsToViewState, 
//              and SaveAscribeCoreControlsToViewState 88858
//  08Jul14 XN  Added LoadAscribeCoreControlsToViewState and SaveAscribeCoreControlsToViewState
//===========================================================================
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Web.UI;
using System.Reflection;

namespace ascribe.pharmacy.shared
{
    public static class WebExtensions
    {
        /// <summary>Returns all controls and sub controls of a spcific type on a form</summary>
        public static IEnumerable<TResult> GetAllControlsByType<TResult>(this Page page)
        {
            return page.Controls.OfType<Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<TResult>();
        }

        /// <summary>Returns all controls and sub controls of a spcific type on a form</summary>
        public static IEnumerable<TResult> GetAllControlsByType<TResult>(this Control control)
        {
            return control.Controls.OfType<Control>().Desendants(c => c.Controls.OfType<Control>()).OfType<TResult>();
        }

        /// <summary>Create script block to call client side window.close() method.</summary>
        /// <param name="returnValue">window client side return value (in form window.returnValue='{value}'), if not set returnValue will be undefined</param>
        /// <param name="ignoreDirtyPageMessage">is true clears the pharmacy isPageDirty flag before closing</param>
        public static void ClosePage(this Page page)
        {
            ClosePage(page, null, false);
        }
        public static void ClosePage(this Page page, bool ignoreDirtyPageMessage)
        {
            ClosePage(page, null, ignoreDirtyPageMessage);
        }
        public static void ClosePage(this Page page, string returnValue)
        {
            ClosePage(page, returnValue, false);
        }
        public static void ClosePage(this Page page, string returnValue, bool ignoreDirtyPageMessage)
        {
            StringBuilder script = new StringBuilder();
            if (ignoreDirtyPageMessage)
                script.Append("clearIsPageDirty();");
            if (returnValue == null)
                script.Append("window.returnValue=undefined;");
            else
                script.AppendFormat("window.returnValue='{0}';", returnValue.Replace("'", "&apos;"));   // script.AppendFormat("window.returnValue='{0}';", returnValue); 18Feb15 XN 111502 Can't close page when return data has single quote
            script.Append("window.close();");

            ScriptManager.RegisterClientScriptBlock(page, page.GetType(), "ClosePage", script.ToString(), true);
        }

        /// <summary>Returns list of checked items from a CheckBoxList</summary>
        public static IEnumerable<ListItem> CheckedItems(this CheckBoxList control)
        {
            return control.Items.Cast<ListItem>().Where(li => li.Selected);
        }

        /// <summary>Convert hidden field value string to a type</summary>
        public static T Value<T>(this HiddenField hf)
        {
            return ConvertExtensions.ChangeType<T>(hf.Value);
        }


        /// <summary>
        /// Loads ICW core controls info that was cached by SaveAscribeCoreControlsToViewState
        /// Used with SaveAscribeCoreControlsToViewState to patch up ICW core controls data that is not cached in ViewState
        ///     
        /// Normal call on 
        ///     if (this.IsPostBack)
        ///         this.LoadAscribeCoreControlsToViewState();  // Load manually cached ascribe core controls extra data
        /// XN 23Apr14 88858
        /// </summary>
        public static void LoadAscribeCoreControlsToViewState(this TemplateControl page)
        {
            StateBag viewState = (StateBag)typeof(Page).GetProperty("ViewState", BindingFlags.NonPublic | BindingFlags.FlattenHierarchy| BindingFlags.Instance).GetValue(page, null);

            foreach(var ctrl in page.GetAllControlsByType<Ascribe.Core.Controls.ShortText>())
            {
                if (viewState[ctrl.ID + "_Value"] != null)
                    ctrl.Value = (string)viewState[ctrl.ID + "_Value"];
                if (viewState[ctrl.ID + "_MaxCharacters"] != null)
                    ctrl.MaxCharacters = (int)viewState[ctrl.ID + "_MaxCharacters"];
            }
            foreach(var ctrl in page.GetAllControlsByType<Ascribe.Core.Controls.MediumText>())
            {
                if (viewState[ctrl.ID + "_Value"] != null)
                    ctrl.Value = (string)viewState[ctrl.ID + "_Value"];
                if (viewState[ctrl.ID + "_MaxCharacters"] != null)
                    ctrl.MaxCharacters = (int)viewState[ctrl.ID + "_MaxCharacters"];
            }
            foreach(var ctrl in page.GetAllControlsByType<Ascribe.Core.Controls.LongText>())
            {
                if (viewState[ctrl.ID + "_Value"] != null)
                    ctrl.Value = (string)viewState[ctrl.ID + "_Value"];
                if (viewState[ctrl.ID + "_MaxCharacters"] != null)
                    ctrl.MaxCharacters = (int)viewState[ctrl.ID + "_MaxCharacters"];
                if (viewState[ctrl.ID + "_Rows"] != null)
                    ctrl.Rows = (int)viewState[ctrl.ID + "_Rows"];
                if (viewState[ctrl.ID + "_Columns"] != null)
                    ctrl.Columns = (int)viewState[ctrl.ID + "_Columns"];
            }
            foreach(var ctrl in page.GetAllControlsByType<Ascribe.Core.Controls.Number>())
            {
                if (viewState[ctrl.ID + "_Value"] != null)
                    ctrl.Value = (double?)viewState[ctrl.ID + "_Value"];
                if (viewState[ctrl.ID + "_MaxCharacters"] != null)
                    ctrl.MaxCharacters = (int)viewState[ctrl.ID + "_MaxCharacters"];
            }
        }

        /// <summary>
        /// Saves ICW core controls info that can be read by LoadAscribeCoreControlsToViewState
        /// Used with LoadAscribeCoreControlsToViewState to patch up ICW core controls data that is not cached in ViewState
        /// Currently supports
        ///     Control value if readonly (for ShortText, MediumText, LongText)
        ///     Control MaxCharacters (for ShortText, MediumText, LongText)
        ///     
        /// Normal call on 
        ///     if (!this.IsPostBack)
        ///         this.SaveAscribeCoreControlsToViewState();  // Save manually cached ascribe core controls extra data
        /// XN 23Apr14 88858
        /// </summary>
        public static void SaveAscribeCoreControlsToViewState(this TemplateControl page)
        {
            StateBag viewState = (StateBag)typeof(Page).GetProperty("ViewState", BindingFlags.NonPublic | BindingFlags.FlattenHierarchy| BindingFlags.Instance).GetValue(page, null);

            foreach(var ctrl in page.GetAllControlsByType<Ascribe.Core.Controls.ShortText>())
            {
                if (ctrl.ReadOnly)
                    viewState[ctrl.ID + "_Value"] = ctrl.Value;
                viewState[ctrl.ID + "_MaxCharacters"] = ctrl.MaxCharacters;
            }
            foreach(var ctrl in page.GetAllControlsByType<Ascribe.Core.Controls.MediumText>())
            {
                if (ctrl.ReadOnly)
                    viewState[ctrl.ID + "_Value"] = ctrl.Value;
                viewState[ctrl.ID + "_MaxCharacters"] = ctrl.MaxCharacters;
            }
            foreach(var ctrl in page.GetAllControlsByType<Ascribe.Core.Controls.LongText>())
            {
                if (ctrl.ReadOnly)
                    viewState[ctrl.ID + "_Value"] = ctrl.Value;
                viewState[ctrl.ID + "_MaxCharacters"] = ctrl.MaxCharacters;
                viewState[ctrl.ID + "_Rows"         ] = ctrl.Rows;
                viewState[ctrl.ID + "_Columns"      ] = ctrl.Columns;
            }
            foreach(var ctrl in page.GetAllControlsByType<Ascribe.Core.Controls.Number>())
            {
                if (ctrl.ReadOnly)
                    viewState[ctrl.ID + "_Value"] = ctrl.Value;
                viewState[ctrl.ID + "_MaxCharacters"] = ctrl.MaxCharacters;
            }
        }
    }
}
