//===========================================================================
//
//							      IQSViewControl.cs
//
//  Defines a general interface used by web page that host QuesScrl data items
//  
//	Modification History:
//	23Jan14 XN  Written
//  17Dec15 XN  Added CreatedHeaderEventHandler 38034
//===========================================================================
namespace ascribe.pharmacy.quesscrllayer
{
    public delegate void SavedEventHandler();
    public delegate void ValidatedEventHandler();
    public delegate void CreatedHeaderEventHandler(System.Web.UI.WebControls.TableHeaderCell header, int siteID);

    /// <summary>Defines a general interface used by web page that host QuesScrl data items</summary>
    public interface IQSViewControl
    {
        /// <summary>Validates the current values (validation success is reported by event Validated)</summary>
        void Validate();
    
        /// <summary>Event fired when data has been validated sucessfully</summary>
        event ValidatedEventHandler Validated;

        /// <summary>Saves the current values in the web control to quesScrl (success is report by event Saved)</summary>
        void Save();
    
        /// <summary>Event fired when data has been saved to db</summary>
        event SavedEventHandler Saved;

        /// <summary>Suppresses builing of the conrol</summary>
        bool SuppressControlCreation { set; }
    }
}
