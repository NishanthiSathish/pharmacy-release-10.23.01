IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8GpInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8GpInsert
GO

create procedure pV8GpInsert
	(
			@sessionid			integer
		,  @locationid_site	integer
		,	@code					varchar(4)
		,	@description		varchar(30)
		,	@inuse				bit
		,  @entityid			integer	OUTPUT
	)
AS
	BEGIN
		
		declare @_aliasgroupid			int
		declare @_entityaliasid			int
		declare @_entitytypeid 			int
		declare @_gpclassificationid	int
		declare @_success					bit
		declare @_tableid 				int
		
		set @_success = 1

		select @_entitytypeid = entitytypeid,
             @_tableid = tableid 
		from entitytype where [description] = 'GP'

		select @_gpclassificationid = GpClassificationID 
	   from GpClassification
		where [description] = 'G'

		select @_aliasgroupid = AliasGroupID
		from AliasGroup
		where [description] = 'WGpCodes'

		begin transaction 

		exec pGpInsert	@sessionid,
							@_entitytypeid, 
							@_tableid,
							@description,
							'',							-- telephone
							'',							-- fax
							'',							-- email
							'',							-- website
							'',							-- title
							@code,
							'',							-- forename
							'',							-- surname
							'',							-- mobile
							'', 							-- pager
							@_gpclassificationid,
							'',							-- regnumber
							'G',							-- contract
							0,								-- obstetric
							0,					  			-- jobshare
							0,								-- trainer
							@entityid OUTPUT

		if (@@Error <> 0) set @_success = 0

		IF NOT(EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pEntityAliasInsert' AND sc.name = '@IsValid'))
			exec pEntityAliasInsert	@sessionid, @entityid, @_aliasgroupid, @code, 1, @_entityaliasid OUTPUT

		IF EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pEntityAliasInsert' AND sc.name = '@IsValid')
			exec pEntityAliasInsert	@sessionid, @entityid, @_aliasgroupid, @code, 1, 1, @_entityaliasid OUTPUT

		if (@@Error <> 0) set @_success = 0

		if (@_success = 1) 
			commit transaction
		else
			begin
				rollback transaction
				set @entityid = NULL
			end 

	END