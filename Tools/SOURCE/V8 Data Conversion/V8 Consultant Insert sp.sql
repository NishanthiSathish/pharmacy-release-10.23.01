IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8ConsultantInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8ConsultantInsert
GO

create procedure pV8ConsultantInsert
	(
			@sessionid			integer
		,	@locationid_site	integer
		,	@code				varchar(4)
		,	@description		varchar(128)
		,	@inuse				bit
		,	@entityid			integer OUTPUT
	)
AS
	BEGIN

		declare @_aliasgroupid	int
		declare @_entityaliasid int
		declare @_entityid		int
		declare @_entitytypeid	int
		declare @_outofuse		bit
		declare @_success		bit 
		declare @_tableid		int

		set @_success = 1

		select @_entitytypeid = entitytypeid,
             @_tableid = tableid 
		from entitytype where [description] = 'consultant'

		select @_aliasgroupid = aliasgroupid 
		from aliasgroup
		where [Description] = 'WConsultantCodes'
	
		set @_outofuse = ~@inuse  -- NB '~' is the bit wise NOT operator

		begin transaction

		exec pConsultantInsert	@sessionid,
								@_entitytypeid, 
								@_tableid,
								@description,
								'',					-- telephone
								'',					-- fax
								'',					-- email
								'',					-- website
								'',					-- title
								@code,
								'',					-- forename
								'',					-- surname
								'',					-- mobile
								'', 					-- pager
								0,						-- entityID_secretary
								'',					-- GMCCode
								'',					-- Qualification
								@_outofuse,
								@entityid OUTPUT

		
		if (@@error <> 0) set @_success = 0
	
		IF NOT(EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pEntityAliasInsert' AND sc.name = '@IsValid'))
			exec pEntityAliasInsert	@sessionid, @entityid, @_aliasgroupid, @code, 1, @_entityaliasid OUTPUT

		IF EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pEntityAliasInsert' AND sc.name = '@IsValid')
			exec pEntityAliasInsert	@sessionid, @entityid, @_aliasgroupid, @code, 1, 1, @_entityaliasid OUTPUT

		if (@@error <> 0) set @_success = 0

		if (@_success = 0)
			begin
				rollback transaction
				set @entityid = NULL
			end
		else
			commit transaction
			
	END