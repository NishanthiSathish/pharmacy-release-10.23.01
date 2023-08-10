--Config File For DoC - DO NOT RUN THIS SCRIPT AS A WHOLE
--This illustrates the settings available. Pick and choose as required ONLY
--06Jan16 TH Changed setting defaults to reflect standard instalment dispensing
--           Auto increment/decrement from dispens ocx and NOT use batchnumber repeat handling (TFS 138921)

declare @SiteID int

set @SiteID = 15  --  << Set internal site ID herech for using repeat cycles in dispensary

--Main switch for using repeat cycles in dispensay

exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','UseRptCyclesDisp','"Y"'

--Enable the check on remaining repeats in disp (ie - have you got enough)
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','RepeatsRemainingDispCheck','"Y"'

--If this is set then the user is warned and asked if they wish to continue - it allows them to pregress
--if not set then the user is told no issue is possible and the process is halted.
--This is not set by default
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','RepeatsRemainingDispCheckWarn','"N"'

--Warning shown to user if allowed to proceed as above with default
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','RepeatsRemainingDispCheckWarnMsg','There are no more repeats allowed for this item. Are you sure you wish to continue"'

--Stop message shown to user as above with default
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','RepeatsRemainingDispCheckStopMsg','"There are no more repeats allowed for this item."'

--Enables the prescription Expiry Check (ie current date is after the expiry set for the script)
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','PrescriptionExpiryDispCheck','"Y"'

--If this is set then the user is warned and asked if they wish to continue - it allows them to pregress
--if not set then the user is told no issue is possible and the process is halted.
--This is not set by default
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','PrescriptionExpiryDispCheckWarn','"N"'

--Warning shown to user if allowed to proceed as above with default
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','PrescriptionExpiryDispCheckWarnMsg','"This prescription has expired. Are you sure you wish to continue"'

--Sets the auto decrement of repeats remaining on issue from dispensing control (will not go negative though)
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','AutoDecrementFromDisp','"Y"'

--Sets the auto decrement of repeats remaining on issue from dispensing control (will not go negative though)
--06Jan16 TH Changed default
--exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','IncrementFromDisp','"N"' 
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','IncrementFromDisp','"Y"'

--Use Repeat qty as default Issue Qty if one is set.
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','UseRepeatQty','"N"'


--Configurable suffix on issue screen if using setting above.
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','RepeatQtyIssueCaption','" (Repeat Qty)"'


--This setting is used in the preparation of pbRxno and pbRepeatText elements
--If set then it will use the l.Batchnumber (as per version 8) to calculate the number of repeats used
--If not set it uses te new repeatsRemaining field from the Repeat Dispensing link record
--06Jan16 TH Changed default
--exec pWConfigurationWrite 0,@SiteID,'D|Patbill','PatientBilling','UseBatchnumberforRepeats','"Y"'
exec pWConfigurationWrite 0,@SiteID,'D|Patbill','PatientBilling','UseBatchnumberforRepeats','"N"'


--When calculating pbRxno and pbRepeatText elements this adds one to the repeats Allowed total
--this was to compensate for the total installments but think it is now superfluous anyway.
exec pWConfigurationWrite 0,@SiteID,'D|Patbill','PatientBilling','RepeatsOnly','"N"'


--When attempting to use (print/issue etc.) an existing label that has been rpt dispensing linked
--this setting protects the original consultant (if cons details on the episode have changed) 
--and ensures the original consultant details appear on the label , in the log.
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatDispensing','ConsultantOverride','"N"'

--This setting puts the prescription num value of a label into the episodeOrderAlias table
--so that the label can be looked up as a "fast repeat". Set to Y to utilise this functionality
exec pWConfigurationWrite 0,@SiteID,'D|patmed','','StorePharmacyRxIDasFastRepeat','"N"'

--This setting over rides the default question when the user attempts to return an istallment linked dispensing
exec pWConfigurationWrite 0,@SiteID,'D|RptDisp','RepeatCycles','RepeatReturnMsg','"This prescription has a number of installments. Do you wish to return one of the installments"'


-- Add to Version Log
INSERT VersionLog ([Type], Description, [Date]) SELECT 'Config', 'Installment_Dispensing.sql (Sept 13) v1', GETDATE()
GO