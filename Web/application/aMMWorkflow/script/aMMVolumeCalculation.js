/*

    				aMMVolumeCalculation.js


	Specific script for the aMMVolumeCalculation.ascx control.

*/

// When called will update the calculations on the screen
function updateCalculation(sessionID, siteID)
{
    var fixedVolumeInmL = parseFloat($('input[id$=tbFixedVolume]').val());
    var parameters = {
                        sessionID: sessionID,
                        siteID: siteID,
                        dose: parseFloat($('td[id$=tdDrugDose]').text()),
                        volumeType: $('div[id$=divAMMVolumeCalculation] input[type=radio]:checked').attr('VolumeType'),
                        fixedVolumeInmL: isNaN(fixedVolumeInmL) ? null : fixedVolumeInmL,
                        NSVCode: $('input[id$=hfNSVCode]').val()
                        };
    PostServerMessage('NewAmmSupplyRequestWizard.aspx/UpdateCalculation', 
                        JSON.stringify(parameters), 
                        true, 
                        function(result)
                        {
                                if (result == undefined)
                                    return;

                                if (result.d.RuleEquation == null) {
                                    $('tr[id$=trVolCalRow]').hide();
                                } else {
                                    $('tr[id$=trVolCalRow]').show();
                                }

                                // Update the results
                                $('span[id$=spanInitialDrugConcDetail]').html(result.d.InitialDrugConcenrationEqu == null ? '&nbsp;' : result.d.InitialDrugConcenrationEqu);
                                $('td[id$=tdInitialDrugConc]').text(result.d.InitialDrugConcenrationPermL);
                                $('td[id$=tdInitialVolumeForDose]').text(result.d.InitialVolumeInmL);
                                $('input[id$=tbDrugNominalVolume]').val(result.d.DrugPlusNominalVolumeInmL);
                                $('span[id$=spanRuleFixVolume]').text(fixedVolumeInmL);
                                $('td[id$=tdRuleMaxPercVolToAdd]').text(result.d.SelectedVolumeInmL);
                                $('td[id$=tdConcLimitsFixedVolume]').text(result.d.SelectedVolumeInmL);
                                $('td[id$=tdRuleEquation]').text(result.d.RuleEquation == null ? ' ' : result.d.RuleEquation);
                                $('td[id$=tdErrorMsg]').text(result.d.Error);

                                // Mark if the control is valid
                                $('input[id$=hfValidCalculation]').val(result.d.Error == null || result.d.Error == '');
                        });
}
