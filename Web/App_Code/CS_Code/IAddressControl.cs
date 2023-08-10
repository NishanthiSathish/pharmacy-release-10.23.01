//===========================================================================
//
//						           IAddressControl.cs
//
//  Interface for the different address control in the GPEditor
//
//	Modification History:
//	24Jul12 XN  TFS21753 Written
//===========================================================================
using System.Text;

/// <summary>Interface for the different address control in the GPEditor</summary>
public interface IAddressControl
{
    /// <summary>If control is visible</summary>
    bool Visible { set; }

    /// <summary>Initalise the contrl</summary>
    void InitaliseControls();

    /// <summary>Popupate the address fields for the entity</summary>
    /// <returns>if fails ICW broken rules else empty string</returns>
    string Popoulate(int entityID);

    /// <summary>Clear the address</summary>
    void ClearForm();

    /// <summary>Validate the page</summary>
    /// <param name="missingMandatoryFields">Any missing fields</param>
    /// <returns>If data is valid</returns>
    bool ValidatePage(StringBuilder missingMandatoryFields);

    /// <summary>Save the address</summary>
    /// <returns>if fails ICW broken rules else empty string</returns>
    string Save(int entityID);

    /// <summary>Deletes address from DB</summary>
    /// <returns>if fails ICW broken rules else empty string</returns>
    string Delete(int entityID);
}
