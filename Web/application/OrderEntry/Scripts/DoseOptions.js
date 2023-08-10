function ShowDoseOptionsHints()
{
    var astrHints = new Array();
    
	    astrHints[0] = 'This page allows you to set options for calculated doses.';
	    astrHints[1] = '<b>Round to Nearest</b>';
	    astrHints[2] = 'Enter a value in this field if you wish the system to round the '
					 + 'calculated dose. The rounding is done before dose capping, and will '
					 + 'round the value up or down to the nearest interval specified.';
	    astrHints[3] = '<b>To a maximum of</b>';
	    astrHints[4] = 'If you specify a value here, any calculated does will be capped at '
					 + 'that value. This means that you can set an absolute maximum value '
					 + 'which the calculation can return. Capping is done after rounding.';
	    astrHints[5] = '<b>Allow user to Override</b>';
	    astrHints[6] = 'If this is ticked, the user can manually enter a dose which is '
					 + 'greater than the cap value. Otherwise, they will not be able to '
					 + 'exceed the cap value.';
	    astrHints[7] = '<b>Re-evaluate Calculations on View</b>';
	    astrHints[8] = 'Generally this box should be left unticked. In this case, when '
					 + 'viewing a prescription, the user will see the calculated dose as it '
					 + 'was calculated when the prescriber wrote the prescription.<br><br>'
					 + 'If this box is ticked, the calculation will be re-done, with the '
					 + 'current values for patient parameters, every time the prescription is '
					 + 'viewed. This allows users to see how the prescribed dose compares '
					 + 'with the specified dose if it were calculated at the time of viewing.';

	    void ShowHints (astrHints);	
}


function btnOK_onclick()
{
    var RoundToNearest = Number(document.getElementById("txtRoundToNearest").value);
    var ToMaximumOf = Number(document.getElementById("txtToMaximumOf").value);
    var ReevaluateCalculations = false;
    var AllowOverride = false;
    var strReturn = "";
    
    
    
    if(document.getElementById("chkAllowOverride").checked)
    {
        AllowOverride = true;
    }
    
    if(document.getElementById("chkReevaluateCalculations").checked)
    {
        ReevaluateCalculations = true;
    }
    
    strReturn = RoundToNearest + "," + ToMaximumOf + "," + AllowOverride + "," + ReevaluateCalculations;
    window.returnValue = strReturn;
    window.close();
}

function btnCancel_onclick()
{
    window.close();
}