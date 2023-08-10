/*

ICW_UMMCBilling.js


Specific script for the ICW_UMMCBilling page.

*/

// settings for the UMMC Billing
var UMMCBILLINGSCREEN_FEATURES = 'dialogHeight:670px; dialogWidth:980px; status:off; center: Yes';
var episodeID;
var episodeSelectedWindowID;    // ID of the window that sent the EpisodeSelected event


// Displays the UMMC billing screen for the patient episode
function ummcBillingDisplayScreen(episodeID) 
{
    var strURL = document.URL;
    var intSplitIndex = strURL.indexOf('?');
    var strURLParameters = strURL.substring(intSplitIndex, strURL.length);

    // Displays the UMMC billing screen as a popup
    window.showModalDialog('../UMMCBilling/UMMCBillingScreenModal.aspx' + strURLParameters, '', UMMCBILLINGSCREEN_FEATURES);
}

// Worklist content has been updates so no episode select so disable
function EVENT_WorkListUpdate(EpisodeSelectedWindowID)
{
    // only clear selection if last list clicked has it's selected episode cleared
    if (episodeSelectedWindowID == EpisodeSelectedWindowID)
    {
        $('#billing').attr('disabled', true);
        episodeID = null;
        episodeSelectedWindowID = null;
    }
}

// Catches the selected episode ID
function EVENT_EpisodeSelected(EpisodeID, EpisodeSelectedWindowID) 
{
    if (!isNaN(EpisodeID) && EpisodeID > 0)
    {
        $('#billing').removeAttr('disabled');
        episodeID = EpisodeID;
        episodeSelectedWindowID = EpisodeSelectedWindowID;
    }
    else if (episodeSelectedWindowID == EpisodeSelectedWindowID)    // only clear selection if last list clicked has it's selected episode cleared
    {
        // Nothing selected so disable
        $('#billing').attr('disabled', true);
        episodeID = null;
        episodeSelectedWindowID = null;
    }
}

//DJH - TFS Bug 12880 - Add new Episode Cleared event.
function EVENT_EpisodeCleared() {
    // Nothing selected so disable
    $('#billing').attr('disabled', true);
    episodeID = null;
    episodeSelectedWindowID = null;
}

// When the billing button is clicked displays the UMMC billing screen
function billing_click() 
{
    ummcBillingDisplayScreen(episodeID);
}

