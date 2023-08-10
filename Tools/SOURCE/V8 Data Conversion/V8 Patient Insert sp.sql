--28Oct13 TH Added 0 as OrderCatologueID to pConvertedPatientNotesInsert - not 100% this is right (TFS 76692)
--31Oct13 TH Added optional params to pConvertedPatientNotesInsert call, removed checking on Address fields
--	     Added Extra params to Height observation call (TFS 77044)

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8PatientInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8PatientInsert
GO

create procedure pV8PatientInsert
					  (
							@SessionID 			int,
							@locationid_site	int,
							@FilePosn 			int,
							@Recno 				varchar(10),
							@CaseNo 				varchar(10),
							@OldCaseNo 			varchar(10),
							@Surname 			varchar(20),
							@Forename 			varchar(15),
							@DOB 					datetime,
							@DOBEstYear			bit,
							@DOBEstMonth		bit,
							@DOBEstDay			bit,
							@Sex 					varchar(1),
							@Ward 				varchar(4),
							@Cons 				varchar(4),
							@Weight 				varchar(6),
							@Height 				varchar(6),
							@Status 				varchar(1),
							@Postcode 			varchar(8),
							@Gp 					varchar(4),
							@Housenumber 		varchar(6),
							@NhNumber 			varchar(10),
							@NhNumberValid 	varchar(4),
							@Title 				varchar(5),
							@Address1 			varchar(35),
							@Address2 			varchar(35),
							@Address3 			varchar(35),
							@Address4 			varchar(35),
							@EthnicOrigin 		varchar(4),
							@AliasSurname 		varchar(20),
							@AliasForename		varchar(15),
							@PpFlag				varchar(1),
							@EpisodeNum	 		varchar(12),
							@Specialty 			varchar(4),
							@Allergy 			varchar(255),
							@Diagnosis			varchar(255),
							@SurfaceArea 		real,
							@Notes 				text,
							@entityid			integer OUTPUT
						)
AS

-- sp local variables
declare @_addressid int
declare @_addresstypeid int
declare @_address1 varchar(35)
declare @_aliasgroupid int
declare @_consultantentityid int
declare @_consultantroleid int
declare @_createddate datetime 
declare @_deceaseddate datetime
declare @_description varchar(128)
declare @_enddate datetime
declare @_entityaliasid int
declare @_entitytypeid int
declare @_episodelocationid int
declare @_episodetypeid int
declare @_ethnicoriginid int
declare @_genderid int
declare @_gpentityid int
declare @_gproleid int
declare @_height float
declare @_housenum varchar(6)
declare @_lifetimeepisodedesc varchar(128)
declare @_lifetimeepisodeid int
declare @_lifetimeepisodestart datetime
declare @_noteid int
declare @_notetypeid int
declare @_personaliasgroupid int
declare @_personaliasid int
declare @_ppflag bit
declare @_respepisodeentityid int
declare @_specialtyid int
declare @_success bit
declare @_tableid int
declare @_unitid int	
declare @_userentityid int
declare @_wardlocationid int
declare @_weight float
declare @_notes varchar(8000)
declare @_notestruncated bit

begin

	-- Read the EntityTypeID and TableID for an entity of type 'Patient'
	select @_entitytypeid = EntityTypeID, @_tableid = TableID from EntityType where [Description] = 'Patient'

	set @_description = LTRIM(RTRIM(RTRIM(@Title) + ' ' + RTRIM(@Forename) + ' ' + RTRIM(@Surname)))

	print @_description

 	SELECT @_genderid = GenderID FROM Gender WHERE [Description] = 'Other'
	IF @Sex = 'M' SELECT @_genderid = GenderID FROM Gender WHERE [Description] = 'Male'
	IF @Sex = 'F' SELECT @_genderid = GenderID FROM Gender WHERE [Description] = 'Female'
	IF @Sex = 'U' SELECT @_genderid = GenderID FROM Gender WHERE [Description] = 'Unknown'
	print 'GenderID = ' + cast(@_genderid as char(10))


	set @_housenum = ltrim(rtrim(@Housenumber))

	if (left(@address1, len(@_housenum)) <> @_housenum) and (len(@_housenum) > 0)
		set @_address1 = ltrim(rtrim(@_housenum + ' ' + @address1))
	else
		set @_address1 = rtrim(@Address1)
	
	print 'House Number = "' + @_housenum + '"'
	print 'Address1 = "' + @_address1 + '"'

	set @_success = 1
	
	begin transaction

	-- Create the patient 
	exec pPatientInsert 	@SessionID, 
                       	@_entitytypeid,
							  	@_tableid,
							  	@_description,
								'', 							-- Telephone
								'', 							-- Fax
								'',							-- email
								'',							-- website
								@Title,
								'',							-- initials
								@Forename,
								@Surname,
								'',							--	mobile
								'',							-- pager
								@_genderid,
								0,								-- next of kin entityid
								@DOB,
								@DOBEstYear,				-- DOBEstYear
								@DOBEstMonth,				-- DOBEstMonth
								@DOBEstDay,					-- DOBEstDay
								@NhNumber,
								@NhNumberValid,
								@EntityID OUTPUT
   

	if @@Error <> 0 set @_success = 0	

	print 'EntityID = ' + CAST(@EntityID AS char(10))


	-- Read the lifetime episode description from the system settings
	select @_lifetimeepisodedesc = [Value] from Setting
	where [System] = 'ENT' 
	and   [Section] = 'LifetimeEpisode'
	and   [Key] = 'Description'

	if len(rtrim(@_lifetimeepisodedesc)) = 0
		set @_lifetimeepisodedesc = 'Lifetime Episode'

	-- Read the episode type primary key from the EpisodeType table

	if (upper(@Status) = 'I')
		select @_episodetypeid = EpisodeTypeID 
		from EpisodeType
		where [Description] = 'In-patient'

	if (upper(@Status) = 'O')
		select @_episodetypeid = EpisodeTypeID 
		from EpisodeType
		where [Description] = 'Out-patient'

	if (upper(@Status) = 'D')
		select @_episodetypeid = EpisodeTypeID 
		from EpisodeType
		where [Description] = 'Discharge'

	if (upper(@Status) = 'L')
		select @_episodetypeid = EpisodeTypeID 
		from EpisodeType
		where [Description] = 'Leave'

	if (@_episodetypeid is null)
		select @_episodetypeid = EpisodeTypeID 
		from EpisodeType
		where [Description] = 'Administration'

	print 'EpisodeTypeID = ' + cast(@_episodetypeid as char(10))

	set @_createddate = getdate()

	print 'CreatedDate = ' + cast(@_createddate as char(20))

	SET @_lifetimeepisodestart = @DOB
	IF @_lifetimeepisodestart IS NULL SET @_lifetimeepisodestart = @_createddate
	
	if (upper(@Status) = 'X')
		set @_enddate = @_createddate

	-- Create the lifetime episode id
	exec pEpisodeInsert	@SessionID,
								0,								-- Parent EpisodeID
								0,								--	Status ID
								@EntityID,
								@_episodetypeid,
								@_lifetimeepisodedesc,
								@_createddate,
								@_lifetimeepisodestart,
								@_enddate,
								'',							-- CaseNo		
								@_lifetimeepisodeid OUTPUT

	if @@Error <> 0 set @_success = 0

	print 'LifetimeEpisodeID = ' + cast(@_lifetimeepisodeid as char(10))

	if (len(rtrim(@CaseNo)) > 0)
		begin

			set @CaseNo = rtrim(@CaseNo)

			-- create entity alias records for patient searching
			select @_aliasgroupid = AliasGroupID 
			from AliasGroup
			where [Description] = 'CaseNumber'
		
			print 'AliasGroupID = ' + cast(@_aliasgroupid as char(10))
			print 'Case Number = ' + @CaseNo
		
			-- insert the V8 case number as an alias
			IF NOT(EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pEntityAliasInsert' AND sc.name = '@IsValid'))
				exec pEntityAliasInsert	@SessionID,
										@EntityID,
										@_aliasgroupid,
										@CaseNo, 
										1,						-- Mark case number as the default alias
										@_entityaliasid OUTPUT

			IF EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pEntityAliasInsert' AND sc.name = '@IsValid')
				exec pEntityAliasInsert	@SessionID,
										@EntityID,
										@_aliasgroupid,
										@CaseNo, 
										1,						-- Mark case number as the default alias
										1,						-- Set the IsValid field
										@_entityaliasid OUTPUT

			if @@Error <> 0 set @_success = 0
		end 									

	if (len(rtrim(@OldCaseno)) > 0)
		begin
			
			set @OldCaseno = rtrim(@OldCaseno)

			select @_aliasgroupid = AliasGroupID 
			from AliasGroup
			where [Description] = 'WPreviousCaseNumber'
		
			print 'AliasGroupID = ' + cast(@_aliasgroupid as char(10))			
			print 'Previous Case Number = ' + @Oldcaseno
			
			IF NOT(EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pEntityAliasInsert' AND sc.name = '@IsValid'))
				exec pEntityAliasInsert @SessionID,
										@EntityID,
										@_aliasgroupid,
										@OldCaseno,
										0,					-- mark the old case number as not being the default alias
										@_entityaliasid OUTPUT

			IF EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pEntityAliasInsert' AND sc.name = '@IsValid')
				exec pEntityAliasInsert @SessionID,
										@EntityID,
										@_aliasgroupid,
										@OldCaseno,
										0,					-- mark the old case number as not being the default alias
										1,					-- Set the IsValid field
										@_entityaliasid OUTPUT

			if @@Error <> 0 set @_success = 0
		end

	if (len(rtrim(@NHNumber)) > 0)
		begin

			set @NHNumber = rtrim(@NHNumber)

			-- enter the NH Number as an alias
			select @_aliasgroupid = AliasGroupID 
			from AliasGroup
			where [Description] = 'NHSNumber'
		
			-- insert the V8 case number as an alias
			IF NOT(EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pEntityAliasInsert' AND sc.name = '@IsValid'))
				exec pEntityAliasInsert	@SessionID,
										@EntityID,
										@_aliasgroupid,
										@NHNumber, 
										1,						-- Mark as the default alias for the NHSNumber alias group
										@_entityaliasid OUTPUT

			IF EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pEntityAliasInsert' AND sc.name = '@IsValid')
				exec pEntityAliasInsert	@SessionID,
										@EntityID,
										@_aliasgroupid,
										@NHNumber, 
										1,						-- Mark as the default alias for the NHSNumber alias group
										1,						-- Set ths IsValid field
										@_entityaliasid OUTPUT

			if @@Error <> 0 set @_success = 0
		end 

	if (len(rtrim(@AliasSurname)) > 0) OR
		(len(rtrim(@AliasForename)) > 0)
		begin
			
			set @AliasForename = rtrim(@AliasForename)
			set @AliasSurname = rtrim(@AliasSurname)

			-- find the AliasGroupID for person aliases
			select @_personaliasgroupid = AliasGroupID 
			from AliasGroup
			where [Description] = 'Default'

			print 'PersonAlias GroupID = ' + cast(@_personaliasgroupid as char(13))
			print 'AliasForename = ' + @AliasForename
			print 'AliasSurname = ' + @AliasSurname

			-- create the Person aliases
			exec pPersonAliasInsert		@SessionID,
												@EntityID,
												@_personaliasgroupid,
												@AliasForename,
												@AliasSurname,
												1,
												@_personaliasid OUTPUT

			if @@Error <> 0 set @_success = 0
		end 
	
	--if (len(rtrim(@Address1)) > 0) OR 
      --(len(rtrim(@Address2)) > 0) OR
	--	(len(rtrim(@Address3)) > 0) OR
	--	(len(rtrim(@Address4)) > 0) OR
	--	(len(rtrim(@Postcode)) > 0) 
	--	begin
			-- insert an address against the patient
			exec pAddressInsert	@SessionID,
										'',						-- Box Number
										'',
										'',						-- Building
										@_address1,
										@Address2,
										@Address3,
										@Address4,
										@Postcode,
										'',						-- Province
										'',						-- Country
										'',						-- Notes
										@_addressid OUTPUT

			if @@Error <> 0 set @_success = 0
		
			PRINT 'AddressID = ' + cast(@_addressid As char(10))

			-- read the residential address type primary key
			select @_addresstypeid = AddressTypeID
			from AddressType
			where [Description] = 'Home'

			PRINT 'AddressTypeID = ' + cast(@_addresstypeid As char(10))

			-- link the patient's address record to the patient's entity record
			exec pEntityLinkAddressInsert @SessionID,
													@EntityID,
													@_addressid,
													@_addresstypeid

			if @@Error <> 0 set @_success = 0
	--	end

	-- if a consultant code is present create a ResponsibleEpisodeEntity 
	-- entry against the lifetime episode
	if (len(rtrim(@Cons)) > 0)
		begin

			select @_consultantentityid = EntityID
			from EntityAlias 
			where Alias = @Cons
			and AliasGroupID = (
										select AliasGroupID
                             	from AliasGroup
	                          	where [Description] = 'WConsultantCodes'
									 )			

			select @_consultantroleid = EntityRoleID
			from EntityRole
			where [Description] = 'Consultant'

			if (not((@_consultantroleid is null) or (@_consultantentityid is null)))
				begin
					print 'Executing pResponsibleEpisodeEntityInsert...'
					exec pResponsibleEpisodeEntityInsert @SessionID,
																	 @_lifetimeepisodeid,
																	 @_consultantentityid,
		                                              @_consultantroleid,
																	 @_createddate,
																	 null,
																	 1,
																	 @_respepisodeentityid

					if @@Error <> 0 set @_success = 0
				end                                              
		end

	if (len(rtrim(@GP)) > 0)
		begin
			select @_gpentityid = EntityID
			from EntityAlias 
			where Alias = @GP
			and AliasGroupID = (
										select AliasGroupID
                             	from AliasGroup
	                          	where [Description] = 'WConsultantCodes'
									 )			

			select @_gproleid = EntityRoleID
			from EntityRole
			where [Description] = 'GP'

			if (not((@_gproleid is null) or (@_gpentityid is null)))
				begin
					print 'Executing pResponsibleEpisodeEntityInsert...'
					exec pResponsibleEpisodeEntityInsert @SessionID,
																	 @_lifetimeepisodeid,
																	 @_gpentityid,
		                                              @_gproleid,
																	 @_createddate,
																	 null,
																	 1,
																	 @_respepisodeentityid
					if @@Error <> 0 set @_success = 0
				end                                              
		end

	-- IF a ward code is present, create a link to the GP against the lifetime episode
	if (len(rtrim(@ward)) > 0)
		begin
			select @_wardlocationid = LocationID 
			from LocationAlias
			where Alias = @Ward
			and AliasGroupID = ( select AliasGroupID from AliasGroup where [description] = 'WWardCodes')

			if (not(@_wardlocationid is null))
				begin
					print 'Executing pEpisodeLocationInsert...'
					exec pEpisodeLocationInsert @SessionID,
														 @_lifetimeepisodeid,
                                           @_wardlocationid,
														 @_createddate,
                                           null,
                                           1,
														 @_episodelocationid OUTPUT
					if @@Error <> 0 set @_success = 0
				end
		end

	--select @_userentityid = entityid
	--from Session
	--where sessionid = @SessionID
	--TH Replaced with above as now the convesion tool does NOT log into the ICW. DOnt know why tho - not commented
	set @_userentityid = 0

	print 'User EntityID = ' + cast(@_userentityid as char(13))

	select @_specialtyid = specialtyid 
	from specialtyalias
	where alias = @specialty
	and aliasgroupid = (select aliasgroupid from aliasgroup
                       where [description] = 'WSpecialtyCodes')

	if @_specialtyid is null set @_specialtyid = 0

	if upper(@PPflag) = 'P' 
		set @_ppflag = 1
	else
		set @_ppflag = 0

	select @_notetypeid = notetypeid, @_tableid = tableid
	from notetype
	where [description] = 'Patient care details'

	--create the episode note with the specialty and private patient flag in 
	IF NOT(EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pPatientCareDetailsInsert' AND sc.name = '@PatientPaymentCategoryID'))
		exec pPatientCareDetailsInsert	@SessionID,
										@_notetypeid,
										@_tableid,
										@_userentityid,
										0,
										@caseno,
										@_createddate,
										0,       --Added LocationID
										@_lifetimeepisodeid,
										null,   --Added Expired bit
										null,   --Added Expired date
										@_specialtyid, 
										@_ppflag,
										0,					-- PatientPaymentCategoryID
										@_noteid OUTPUT
	
	IF EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pPatientCareDetailsInsert' AND sc.name = '@PatientPaymentCategoryID')
		exec pPatientCareDetailsInsert	@SessionID,
										@_notetypeid,
										@_tableid,
										@_userentityid,
										0,
										@caseno,
										@_createddate,
										0,       --Added LocationID
										@_lifetimeepisodeid,
										null,   --Added Expired bit
										null,   --Added Expired date
										@_specialtyid, 
										@_ppflag,
										0,					-- PatientPaymentCategoryID
										@_noteid OUTPUT

	if @@Error <> 0 set @_success = 0

	select @_notetypeid = notetypeid, @_tableid = tableid
	from notetype
	where [description] = 'Patient demographic data'

	if (upper(@Status) = 'X')
		set @_deceaseddate = @_createddate 

	select @_ethnicoriginid = EthnicGroupID
	from ethnicgroup
	where [Description] = @ethnicorigin

	if @_ethnicoriginid is null set @_ethnicoriginid = 0
 	
	--create the episode note with the extra entity details in
	exec pPatientDemographicDataInsert 	@SessionID,
													@_notetypeid,
													@_tableid,
													@_userentityid,
													0,
													@caseno,
													@_createddate,
													0,--LocationID
													@_lifetimeepisodeid,
													null,   --expiry
													null,   --expiry datetime
													NULL,		-- WorkTelephoneNo
													NULL,		-- Occupation
													0,
													0,
													0,
													0,
													@_ethnicoriginid, 
													@_deceaseddate,
													@_noteid OUTPUT
				
	if @@Error <> 0 set @_success = 0

	if (len(rtrim(@weight)) > 0)
		begin

			select @_notetypeid = notetypeid, @_tableid = tableid
			from notetype
			where [description] = 'Weight Observation'

			select @_unitid = unitid 
			from unit
			where [Description] = 'Kilogram'

			set @_weight = cast(@weight as float)

			exec pObservationInsert @Sessionid,
											@_notetypeid,
											@_tableid,
											@_userentityid,
											0,
											@weight,
											@_createddate,
											0,  --LocationID
											@_lifetimeepisodeid,
											null,   --expiry
											null,   --expiry datetime
											@_unitid,
											@_weight,
											@_createddate,
											@_createddate,
											@_noteid OUTPUT

			if @@Error <> 0 set @_success = 0
		end 

	if (len(rtrim(@Height)) > 0)
		begin

			select @_notetypeid = notetypeid, @_tableid = tableid
			from notetype
			where [description] = 'Height Observation'

			select @_unitid = unitid 
			from unit
			where [Description] = 'centimetre'

			set @height = replace(@height, ' ', 0)
			set @_height = cast(@height as float)

			if (@_height < 10.0)
				begin
					-- convert from feet inches to cm
					set @_height = round(((floor(@_height) * 12 * 2.54) + (((@_height * 100) - (floor(@_height) * 100)) * 2.54)), 0)
				end

			exec pObservationInsert @Sessionid,
											@_notetypeid,
											@_tableid,
											@_userentityid,
											0,
											@Height,
											@_createddate,
											0,  --LocationID
											@_lifetimeepisodeid,
											null,   --expiry  --31Oct13 TH Added 2 fieldss
											null,   --expiry datetime		
											@_unitid,
											@_height,
											@_createddate,
											@_createddate,
											@_noteid OUTPUT

			if @@Error <> 0 set @_success = 0
		end 

	-- insert patient notes as ConvertedPatientNote
	if (not @Notes like '')
		begin
			--set @_notes = cast(@Notes as varchar(8000))
			set @_notes = @Notes
			
			if (len(@_notes) < 8000)
					set @_notestruncated = 0
				else
					set @_notestruncated = 1

			set @_notes = replace(@_notes, char(160), ' ')
			
			select @_notetypeid = notetypeid, @_tableid = tableid
			from notetype
			where [description] = 'Converted Patient Notes'

			if (@_notetypeid is null)
				set @_notetypeid = 0

			if (not @_notetypeid = 0)				-- Optional so no error if notetype absent
				begin
					exec pConvertedPatientNotesInsert 
												@Sessionid,
												@_notetypeid,
												@_tableid,
												@_userentityid,
												0,
												'Converted Notes',
												@_createddate,
												0,
												@_lifetimeepisodeid,
												0,
												NULL,
												@_notes,
												--@_notestruncated,
												--0
												@_noteid OUTPUT
					if @@Error <> 0 set @_success = 0
				end
		end

	-- create an entry for the patient in the V8PatientConversion table
	exec pV8PatientConversionInsert	@SessionID,
												@EntityID,
												@FilePosn,
												@LocationID_Site,
												@Recno,
												@CaseNo

	if @@Error <> 0 set @_success = 0

	if @_success = 1 
		commit transaction
	else
		begin
			set @entityid = NULL
			rollback transaction
		end 

end
GO