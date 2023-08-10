//===========================================================================
//
//							       ToolMenu.cs
//
//  Provides access to ToolMenu table (more of a view). 
//  Only really used to get the buttons on the toolbar (only support single toolbar)
//
//  sps used by this class should also return 
//      Window.Description as WindowDescription
//      WindowEvent.WindowEventID
//      WindowEvent.WindowID,    
//      WindowEvent.[Description] as EventName
//
//  Supports reading.
//
//	Modification History:
//	30Jun09 AJK  Written
//  01Dec11 XN   Added updating, and inserting support.
//  23Jan12 XN   Added GetRequestType() as virtual method, for SupplyRequest
//  15Nov12 XN   TFS47487 Changed Shortcut key to hotkey to reflect db field to use. 
//               Set GetFullButtonImagePath to prefix path with ..\\.\\ instead of ~\\
//  27Nov12 XN   47487 Added WindowDescription
//  29May15 XN   Set GetFullButtonImagePath to correctly use ~\\ instead of ..\\..\\
//===========================================================================
namespace ascribe.pharmacy.icwdatalayer
{
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web;
using ascribe.pharmacy.basedatalayer;
using ascribe.pharmacy.shared;

    public class ToolMenuRow : BaseRow
    {
        public int      ToolMenuID        { get { return FieldToInt(RawRow["ToolMenuID"]).Value;                        } }
        public int      ToolMenuID_Parent { get { return FieldToInt(RawRow["ToolMenuID_Parent"]).Value;                 } }
        public int      ToolMenuTypeID    { get { return FieldToInt(RawRow["ToolMenuTypeID"]).Value;                    } }
        public string   PictureName       { get { return FieldToStr(RawRow["PictureName"], true, string.Empty);         } }
        public string   Description       { get { return FieldToStr(RawRow["Description"], true, string.Empty);         } }
        public string   Detail            { get { return FieldToStr(RawRow["Detail"],      true, string.Empty);         } }
        public int      DisplayOrder      { get { return FieldToInt(RawRow["DisplayOrder"]) ?? 0;                       } }
        public string   HotKey            { get { return FieldToStr(RawRow["HotKey"],      true, string.Empty);         } } // TFS47487 15Nov12 XN  changed from shortcut to Hotkey
        public bool     Divider           { get { return FieldToBoolean(RawRow["Divider"], false).Value;                } }
        public string   ButtonData        { get { return FieldToStr(RawRow["ButtonData"],  true, string.Empty);         } }
        public string   EventName         { get { return FieldToStr(RawRow["EventName"],   true, string.Empty);         } }
        public int      WindowID          { get { return FieldToInt(RawRow["WindowID"]).Value;                          } }
        public string   WindowDescription { get { return FieldToStr(RawRow["WindowDescription"], true, string.Empty);   } }

        /// <summary>Return full path to the button image (or empty string if no button)</summary>
        /// <returns>Returns the full path to the image</returns>
        public string GetFullButtonImagePath()
        {
            if (string.IsNullOrEmpty(this.PictureName))
            {
                return string.Empty;
            }
            else
            {
                return VirtualPathUtility.ToAbsolute("~/images/User/" + this.PictureName);  // "~\\images\\User\\" + PictureName; TFS47487 15Nov12 XN   
            }
        }
    }

    public class ToolMenuColumnInfo : BaseColumnInfo
    {
        public ToolMenuColumnInfo() : base("ToolMenu") { }
    }

    public class ToolMenu : BaseTable2<ToolMenuRow, ToolMenuColumnInfo>
    {
        public ToolMenu() : base("ToolMenu") { }

        /// <summary>Loads all the toolbar buttons for window</summary>
        public void LoadByWindowID(int windowID)
        {
            List<SqlParameter> parameters = new List<SqlParameter>();
            parameters.Add(new SqlParameter("@sessionID", SessionInfo.SessionID));
            parameters.Add(new SqlParameter("@windowID",  windowID));
            LoadBySP("pToolMenuByWindowID", parameters);
        }
    }
}
