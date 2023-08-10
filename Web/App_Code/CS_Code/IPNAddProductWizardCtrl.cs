using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ascribe.pharmacy.parenteralnutritionlayer;

/// <summary>Interface for controls used in the PN Add product wizard</summary>
public interface IPNWizardCtrl
{
    /// <summary>Called to initalise the controls at the start of the wizard</summary>
    void Initalise();

    /// <summary>Allows the control to set focus on the correct control element</summary>
    void Focus();

    /// <summary>Required height for control</summary>
    int? RequiredHeight { get; }

    /// <summary>Called when a control needs to be validated (so can move to next stage).</summary>
    /// <returns>If data is valid</returns>
    bool Validate(PNProcessor regimenProcess, PNViewAndAdjustInfo info);
}
