IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8ConvWlabelInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8ConvWlabelInsert
GO

CREATE PROCEDURE [pV8ConvWlabelInsert]
	(
			@CurrentSessionID integer
		,	@EpisodeID integer
		,	@locationid_site integer
		,	@DirCode varchar(255)
		,	@Route varchar(4)
		,	@RepeatInterval integer
		,	@RepeatUnits varchar(3)
		,	@BasePrescriptionId integer
		,	@Dose1 float
		,	@Dose2 float
		,	@Dose3 float
		,	@Dose4 float
		,	@Dose5 float
		,	@Dose6 float
		,	@Times1 varchar(4)
		,	@Times2 varchar(4)
		,	@Times3 varchar(4)
		,	@Times4 varchar(4)
		,	@Times5 varchar(4)
		,	@Times6 varchar(4)
		,	@PrescriptionId integer
		,	@ReconVol float
		,	@Container varchar(1)
		,	@ReconAbbr varchar(3)
		,	@DiluentAbbr varchar(3)
		,	@FinalVolume float
		,	@DrDirection varchar(255)
		,	@ContainerSize integer
		,	@InfusionTime integer
		,	@PatId varchar(10)
		,	@SisCode varchar(7)
		,	@Text varchar(255)
		,	@StartDate datetime
		,	@StopDate datetime
		,	@IssType varchar(1)
		,	@LastQty float
		,	@LastDate datetime
		,	@TopupQty float
		,	@DispId varchar(3)
		,	@PrescriberId varchar(3)
		,	@PharmacistID varchar(3)
		,	@StoppedBy varchar(3)
		,	@NeededNextTime varchar(1)
		,	@RxStartDate datetime
		,	@NodIssued float
		,	@BatchNumber integer
		,	@DeleteDate datetime
		,	@RxNodIssued float
		,	@IsHistory bit
		,	@Day1Mon bit
		,	@Day2Tue bit
		,	@Day3Wed bit
		,	@Day4Thu bit
		,	@Day5Fri bit
		,	@Day6Sat bit
		,	@Day7Sun bit
		,	@HasRxNotes bit
		,	@PatientsOwn bit
		,	@PRN bit
		,	@ManualQuantity bit
		,	@rINNflag bit
		,	@PyxisItem bit
		,	@Blister integer
		,	@RevisedInstruction varchar(12)
		,	@RevisedWarning varchar(12)
		,	@FileName varchar(12)
		,	@FilePosition	integer
		,	@WLabelHistoryID integer OUTPUT
	)
	as

begin

	declare @_success bit
	declare @_text varchar(255)

	set @_success = 1

	set @_text = replace(@Text, char(30),' ')
	set @_text = replace(@_text, char(31), ' ')

	Begin transaction

		select @wlabelhistoryid = wlabelhistoryid 
		from wlabelhistory
		where [SiteID] = @locationid_site
		and [FileName] = @filename
		and [FilePosition] = @fileposition

		if @wlabelhistoryid is null
			begin
				--Create a wLabel and attach it to the episode order
				Insert into [WLabelHistory] 
					( [DirCode], [Route], [RepeatUnits], [BasePrescriptionId]
					, [Dose1], [Dose2], [Dose3], [Dose4], [Dose5], [Dose6]
					, [Times1], [Times2], [Times3], [Times4], [Times5], [Times6]
					, [PrescriptionId], [ReconVol], [Container], [ReconAbbr], [DiluentAbbr], [FinalVolume]
					, [DrDirection], [ContainerSize], [InfusionTime], [PatId], [SisCode], [Text]
					, [StartDate], [StopDate], [IssType], [LastQty], [LastDate], [TopupQty]
					, [DispId], [PrescriberId], [PharmacistID], [StoppedBy], [NeededNextTime], [RxStartDate]
					, [NodIssued], [BatchNumber], [DeleteDate], [RxNodIssued], [IsHistory], [SiteID]
					, [Day1Mon], [Day2Tue], [Day3Wed], [Day4Thu], [Day5Fri], [Day6Sat], [Day7Sun]
					, [HasRxNotes], [PatientsOwn], [PRN], [ManualQuantity], [rINNflag], [PyxisItem], [Blister]
					, [RevisedInstruction], [RevisedWarning], [FileName], [FilePosition], [EpisodeID]
					) 
				values 
					( @DirCode, @Route, @RepeatUnits, @BasePrescriptionId
					, @Dose1, @Dose2, @Dose3, @Dose4, @Dose5, @Dose6
					, @Times1, @Times2, @Times3, @Times4, @Times5, @Times6
					, @PrescriptionId, @ReconVol, @Container, @ReconAbbr, @DiluentAbbr, @FinalVolume
					, @DrDirection, @ContainerSize, @InfusionTime, @PatId, @SisCode, @_text
					, @StartDate, @StopDate, @IssType, @LastQty, @LastDate, @TopupQty
					, @DispId, @PrescriberId, @PharmacistID, @StoppedBy, @NeededNextTime, @RxStartDate
					, @NodIssued, @BatchNumber, @DeleteDate, @RxNodIssued, @IsHistory, @locationid_site
					, @Day1Mon, @Day2Tue, @Day3Wed, @Day4Thu, @Day5Fri, @Day6Sat, @Day7Sun
					, @HasRxNotes, @PatientsOwn, @PRN, @ManualQuantity, @rINNflag, @PyxisItem, @Blister
					, @RevisedInstruction, @RevisedWarning, @Filename, @FilePosition, @EpisodeID
					)
				if @@ERROR <> 0 set @_success = 0		
			end

		If @_success = 1
			begin
				commit transaction
				set @WLabelHistoryID = @@Identity
			end 
		else
			begin
				rollback transaction
				set @WLabelHistoryID = NULL
			end
end
