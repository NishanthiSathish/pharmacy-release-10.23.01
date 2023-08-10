IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8SpecialtyInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8SpecialtyInsert
GO

create procedure pV8SpecialtyInsert
	(
			@sessionid			integer
		,	@locationid_site	integer
		,	@code				varchar(4)
		,	@description		varchar(30)
		,	@specialtyid		integer OUTPUT
	)
AS
	BEGIN

		declare @_success 				bit 
		declare @_aliasgroupid 			int
		declare @_outofuse				bit
		declare @_specialtyaliasid 		int 

		set @_success = 1

		select @_aliasgroupid  = aliasgroupid  from aliasgroup
		where [Description] = 'WSpecialtyCodes'

		set @_outofuse = 0

		if left(@description,1) = '#' set @_outofuse = 1

		begin transaction

		exec pSpecialtyInsert		@sessionid,
									@description,
									@description,
									@_outofuse,
									@specialtyid OUTPUT

		exec pSpecialtyAliasInsert	@sessionid,
									@specialtyid,
									@_aliasgroupid,
									@code,
									1,
									@_specialtyaliasid OUTPUT
											
		
		if (@@error <> 0) set @_success = 0
	
		if (@_success = 0)
			begin
				rollback transaction
				set @specialtyid = NULL
			end
		else
			commit transaction
			
	END