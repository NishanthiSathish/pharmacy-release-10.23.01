IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8ConversionMetadataSetup' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8ConversionMetadataSetup
GO

create procedure pV8ConversionMetadataSetup
	(
			@sessionid			integer

	)
AS
	BEGIN

		declare @_gpclassificationid int
		declare @_entityroleid int


		exec pV8CreateAliasGroup @sessionid, 'CaseNumber', 'V8 Patient''s Case Number'

		exec pV8CreateAliasGroup @sessionid, 'NHSNumber', 'Patient''s National Health Number'

		exec pV8CreateAliasGroup @sessionid, 'Default', 'Patient''s Alias Name'

		exec pV8CreateAliasGroup @sessionid, 'EpisodeNumber', 'Episode Number'

		exec pV8CreateAliasGroup @sessionid, 'WGpCodes', 'GP codes from Version 8'

		exec pV8CreateAliasGroup @sessionid, 'WWardCodes', 'Ward codes from Version 8'

		exec pV8CreateAliasGroup @sessionid, 'WRoomCodes', 'Room codes from Version 8'

		exec pV8CreateAliasGroup @sessionid, 'WBedCodes', 'Bed codes from Version 8'

		exec pV8CreateAliasGroup @sessionid, 'WConsultantCodes', 'Consultant codes from Version 8'

		exec pV8CreateAliasGroup @sessionid, 'WPreviousCaseNumber', 'V8 Patient''s Previous Case Number'

		exec pV8CreateAliasGroup @sessionid, 'WSpecialtyCodes', 'Specialty codes from Version 8'

		exec pV8CreateGenderEntry @sessionid, 'Unknown'

		exec pV8CreateGenderEntry @sessionid, 'Other'

		exec pV8CreateEntityRoleEntry @sessionid, 'Consultant', 'Responsible Consultant'

		exec pV8CreateEntityRoleEntry @sessionid, 'GP', 'General Pracitioner'

		exec pV8CreateEntityRoleEntry @sessionid, 'AttendingDr', 'Attending Doctor'

		select @_gpclassificationid = gpclassificationid 
		from GpClassification
		where [Description] = 'G'

		if @_gpclassificationid is NULL
			insert into GpClassification ([Description], [Detail])
			values ('G', 'General Practioner')
		
	END