
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8EpisodeInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8EpisodeInsert
GO

CREATE PROCEDURE pV8EpisodeInsert
	( 
		@SessionID 			integer,
		@locationid_site	integer,
		@idnum 				integer,
		@entityid			integer,
		@patrecno 			varchar(10),
		@createddate 		datetime,
		@createduserid 	varchar(3),
		@createdterminal 	varchar(8),
		@updatedate			datetime,
		@updateduserid		varchar(3),
		@updatedterminal	varchar(8),
		@class				varchar(1),
		@episodenumber		varchar(12),
		@episodeactive		varchar(1),
		@facilityid			varchar(15),
		@episodeward		varchar(4),
		@episoderoom		varchar(12),
		@episodebed			varchar(8),
		@attendingdr		varchar(15),
		@admitdt				datetime,
		@dischargedt		datetime,
		@episodecons		varchar(4),
		@episodespecialty	varchar(4),
		@episodeweight		varchar(6),
		@episodehieght		varchar(6),
		@episodegp			varchar(4),
		@episodestatus		varchar(1),
		@episodeppflag		varchar(1),
		@episodediagcodes	varchar(255),
		@episodeid			integer	OUTPUT
	)
AS
	BEGIN

		declare @_active							bit
		declare @_createddt						datetime
		declare @_caseno							varchar(10)
		declare @_desc								varchar(128)
		declare @_episodetypeid 				int
		declare @_parentepisodeid				int
		declare @_aliasgroupid					int
		declare @_entityroleid					int
		declare @_respentityid					int
		declare @_locationid						int
		declare @_noteid							int
		declare @_notetypeid						int
		declare @_ppflag							bit
		declare @_return							int
		declare @_success							int
		declare @_specialtyid					int
		declare @_tableid							int
		declare @_userentityid					int


		set @_success = 1
		set @_active = 1

		print 'Episode EntityID = ' + cast(@entityid as char(10))

		exec @_parentepisodeid = pLifeEpisodefromEntityID	@SessionID,
																			@entityid
		
		print 'Lifetime EpisodeID = ' + cast(@_parentepisodeid as char(10))


		select @_episodetypeid = EpisodeTypeID
		from EpisodeType
		where [Description] = 'Administration'

		if @episodestatus = 'I' select @_episodetypeid = EpisodeTypeID from EpisodeType where [Description] = 'In-patient'
		if @episodestatus = 'O' select @_episodetypeid = EpisodeTypeID from EpisodeType where [Description] = 'Out-patient'

		print 'EpisodeTypeID = ' + cast(@_episodetypeid as char(10))

		set @_createddt = GetDate()

		set @_desc = 'Clinical Episode - ' + @episodenumber

		if (@admitdt is null) set @admitdt = @_createddt

		BEGIN TRANSACTION

		exec pEpisodeInsert		@SessionID,
										@_parentepisodeid,
										0,							--StatusID
										@entityid,
										@_episodetypeid, 
										@_desc,
										@_createddt,
										@admitdt,
										@dischargedt,
										@_caseno,						--CaseNo
										@episodeid	OUTPUT

		print 'EpisodeID = ' + cast(@episodeid as char(10))

		if @@error <> 0	set @_success = 0

		--Add a EpisodeAlias row for the Episode Number
		select @_aliasgroupid = AliasGroupID from AliasGroup where [description] = 'EpisodeNumber'

		if not exists (select * from EpisodeAlias where AliasGroupID = @_aliasgroupid and alias = @episodenumber)
		begin
			exec pEpisodeAliasInsert 	@sessionid, 
										@episodeid,
										@_aliasgroupid,
										@episodenumber,
										1,
										@_return OUTPUT
		end

		if @@error <> 0	set @_success = 0

		--Add a ResponsibleEpisodeEntity row for the Consultant
		if (len(@episodecons) > 0)
			begin
				print 'Adding Consultant'

				select @_respentityid = EntityID 
				from EntityAlias
				where Alias = @episodecons
				and AliasGroupID = ( select AliasGroupID from AliasGroup 
                                 where [Description] = 'WConsultantCodes' )

				print 'Consultant EntityID = ' + cast(@_respentityid as char(10))

				if not (@_respentityid is null)
					begin
						select @_entityroleid = EntityRoleID from EntityRole where [Description] = 'Consultant'

						print 'EntityRoleID = ' + cast(@_entityroleid as char(10))

						exec pResponsibleEpisodeEntityInsert @sessionid,
																		 @episodeid,
																		 @_respentityid,
	         		                                     @_entityroleid,
																		 @admitdt,
																		 @dischargedt,
																		 @_active,
																		 @_return OUTPUT

						print '@@Error = '  + cast(@@error as char(24))

						if @@error <> 0	set @_success = 0

					end 
			end

		--Add a Location record for the ward 
		if len(@episodeward) > 0 
			begin
				print 'Adding ward as location - ' + rtrim(@episodeward)
				select @_locationid = LocationID from LocationAlias
				where Alias = @episodeward
				and AliasGroupID = (select AliasGroupID from AliasGroup where [description] = 'WWardCodes' )

				print 'Locationid = ' + cast(@_locationid as char(10))

				if not (@_locationid is null)
					exec pEpisodeLocationInsert 	@sessionid, 
															@episodeid,
															@_locationid,
															@admitdt, 
															@dischargedt,
															1,
															@_return OUTPUT

					if @@error <> 0	set @_success = 0
			end

		--Add a ?? record for the specialty
		if len(@episodespecialty) > 0
			begin
				print 'Adding specialty'
				select @_userentityid = entityid
				from Session
				where sessionid = @SessionID
			
				print 'User EntityID = ' + cast(@_userentityid as char(13))
			
				select @_specialtyid = specialtyid 
				from specialtyalias
				where alias = @episodespecialty
				and aliasgroupid = (select aliasgroupid from aliasgroup
			                       where [description] = 'WSpecialtyCodes')
			
				if @_specialtyid is null set @_specialtyid = 0
			
				if upper(@episodeppflag) = 'P' 
					set @_ppflag = 1
				else
					set @_ppflag = 0
	
				select @_notetypeid = notetypeid, @_tableid = tableid
				from notetype
				where [description] = 'Patient care details'
			
				--create the episode note with the specialty and private patient flag in 
				exec pPatientCareDetailsInsert	@SessionID,
															@_notetypeid,
															@_tableid,
															@_userentityid,
															0,
															@episodenumber,
															@createddate,
															@episodeid,
															@_specialtyid, 
															@_ppflag,
															@_noteid OUTPUT
				
				if @@Error <> 0 set @_success = 0
			end

		--Add a ResponsibleEpisodeEntity row for the GP
		if len(@episodegp) > 0
			begin
				print 'Adding gp'

				select @_respentityid = EntityID 
				from EntityAlias
				where Alias = @episodegp
				and AliasGroupID = ( select AliasGroupID from AliasGroup 
                                 where [Description] = 'WGPCodes' )

				if not (@_respentityid is null)
					begin
						select @_entityroleid = EntityRoleID from EntityRole where [Description] = 'GP'

						exec pResponsibleEpisodeEntityInsert @sessionid,
																		 @episodeid,
																		 @_respentityid,
	         		                                     @_entityroleid,
																		 @admitdt,
																		 @dischargedt,
																		 1,
																		 @_return OUTPUT

						if @@error <> 0	set @_success = 0
					end 

			end

		--Add a ResponsibleEpisodeEntity row for the AttendingDr
		if len(@attendingdr) > 0 
			begin
				print 'Adding Attending Dr'

				select @_respentityid = EntityID 
				from EntityAlias
				where Alias = @attendingdr
				and AliasGroupID = ( select AliasGroupID from AliasGroup 
                                 where [Description] = 'WConsultantCodes' )

				if not (@_respentityid is null)
					begin
						select @_entityroleid = EntityRoleID from EntityRole where [Description] = 'AttendingDr'

						exec pResponsibleEpisodeEntityInsert @sessionid,
																		 @episodeid,
																		 @_respentityid,
	         		                                     @_entityroleid,
																		 @admitdt,
																		 @dischargedt,
																		 1,
																		 @_return OUTPUT

						if @@error <> 0	set @_success = 0
					end 
			end

		IF @_success = 1 
			COMMIT TRANSACTION
		else
			begin
				ROLLBACK TRANSACTION
				set @episodeid = -1
			end 

	END
GO


