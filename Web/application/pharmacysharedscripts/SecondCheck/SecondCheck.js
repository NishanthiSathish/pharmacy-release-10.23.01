// Validates the 2nd check control (client side validation)
// If checking self the will display the self check reason text box (if allowed to self check)
// Validates that the self check reason has been entered
// All done client side as makes control work a bit better
function validateSecondCheck(sessionId, controlId)
{
    var entityIDsForSelfCheck = $('#' + controlId + '_hfEntityIDsForSelfCheck').val();
    if (entityIDsForSelfCheck != "")
    {
        var entityId = getEntityId(sessionId, $('#' + controlId + '_tbUsername').val());
        if (entityIDsForSelfCheck.indexOf(',' + entityId + ',') == -1)
        {
            // hide self check reason
            $('#' + controlId + '_trSelfCheckReasonRow1').visible(false);
            $('#' + controlId + '_trSelfCheckReasonRow2').visible(false);
            $('#' + controlId + '_hfShowSelfCheckReason').val("0");
        }
        else if ($('#' + controlId + '_hfShowSelfCheckReason').val() != "1")
        {
            // If self checking then display self check text box
            $('#' + controlId + '_trSelfCheckReasonRow1').visible(true);
            $('#' + controlId + '_trSelfCheckReasonRow2').visible(true);
            $('#' + controlId + '_hfShowSelfCheckReason').val("1");

            // set focus on first control that is not selected
            if ($('#' + controlId + '_tbPassword').val().length == 0)
                $('#' + controlId + '_tbPassword').focus();
            else
                $('#' + controlId + '_tbSelfCheckReason').focus();

            return false;
        }
    }

    return true;
}
