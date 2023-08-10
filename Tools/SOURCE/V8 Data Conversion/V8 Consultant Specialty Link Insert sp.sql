IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8ConsultantSpecialtyInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8ConsultantSpecialtyInsert
GO

create procedure pV8ConsultantSpecialtyInsert
	(
			@sessionid					integer
		,	@Consultant					varchar(4)
		,	@specialty					varchar(5)
	)
AS
	BEGIN

		declare @_entityid		int
		declare @_specialtyid	int

		select @_entityid = entityid 
		from EntityAlias
		where alias = @Consultant
		and aliasgroupid = (select AliasGroupID 
								  from AliasGroup
								  where [Description] = 'WConsultantCodes')


		select @_specialtyid = specialtyid
		from SpecialtyAlias
		where alias = @Specialty
		and aliasgroupid = ( select AliasGroupID
									from AliasGroup
									where [Description] = 'WSpecialtyCodes')

		exec pEntityLinkSpecialtyInsert	@sessionid,
													@_entityid,
													@_specialtyid

	END