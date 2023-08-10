exec pDrop 'pV8PNRulePrescriptionProformaDelete'
GO

Create Procedure [pV8PNRulePrescriptionProformaDelete]
	(		@CurrentSessionID	int
		,	@LocationID_Site	int
		,	@RuleNumber			int
	)
	as
      
begin
	declare @PNRuleIDlocal int
	
	Select @PNRuleIDlocal = PNRuleID 
	from PNRule
	where LocationID_Site = @LocationID_Site and RuleNumber = @RuleNumber and RuleType = 1
	
	-- Delete existing row if present then re-insert
	if not @PNRuleIDlocal is null
		exec pPNRulePrescriptionProformaDelete @CurrentSessionID, @PNRuleIDlocal 

end

GO