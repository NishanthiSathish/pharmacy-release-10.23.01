IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8PNRuleWrite' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8PNRuleWrite
GO

Create Procedure [pV8PNRuleWrite]
	(	
			@CurrentSessionID	int
		,	@LocationID_Site	int
		,	@RuleNumber			int
		,	@RuleType			int
		,	@Description		varchar(50) 
		,	@RuleSQL			varchar(MAX)
		,	@Critical			bit
		,	@PerKilo			bit
		,	@InUse				bit
		,	@PNCode				varchar(8)
		,	@Ingredient			varchar(5) 
		,	@Explanation		varchar(1024) 
		,	@LastModDate		datetime
		,	@LastModUser		varchar(3)  
		,	@LastModTerm		varchar(15) 
		,	@Info				varchar(max) 
		,	@PNRuleID			Int Output
	)
	as
      
begin
	declare @PNRuleIDlocal int
	
	begin transaction

		Select @PNRuleIDlocal = PNRuleID 
		from PNRule 
		where LocationID_Site = @LocationID_Site and RuleNumber = @RuleNumber
		
		-- Delete existing row if present then re-insert
		if not @PNRuleIDlocal is null
				delete PNRule where PNRuleID = @PNRuleIDlocal 

		exec pPNRuleInsert	
				@CurrentSessionID
			,	@LocationID_Site
			,	@RuleNumber 
			,	@RuleType
			,	@Description
			,	@RuleSQL 
			,	@Critical
			,	@PerKilo 
			,	@InUse 
			,	@PNCode
			,	@Ingredient
			,	@Explanation
			,	@LastModDate
			,	@LastModUser
			,	@LastModTerm
			,	@Info 
			,	@PNRuleIDlocal OUTPUT	-- 26Jan12 CKJ changed from @PNRuleID to @PNRuleIDlocal

	If @@ERROR = 0 
		begin
			set @PNRuleID=@PNRuleIDlocal
			Commit 
		end
	else 
		begin			
			Rollback
		end

end

GO
