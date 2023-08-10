-- =============================================
-- Create procedure basic template
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8ConvWLabelInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8ConvWLabelInsert
GO

CREATE procedure [pV8ConvWLabelInsert]
	(
			@CurrentSessionID integer
		,	@locationid_site integer
		,	@EntityID integer
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
		,	@StartDate integer
		,	@StopDate integer
		,	@IssType varchar(1)
		,	@LastQty float
		,	@LastDate varchar(8)
		,	@TopupQty float
		,	@DispId varchar(3)
		,	@PrescriberId varchar(3)
		,	@PharmacistID varchar(3)
		,	@StoppedBy varchar(3)
		,	@NeededNextTime varchar(1)
		,	@RxStartDate integer
		,	@NodIssued float
		,	@BatchNumber integer
		,	@DeleteDate integer
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
		,	@RequestID_Prescription integer
		,	@RequestID integer OUTPUT
	)
	as

begin

	declare @TableID int
	declare @RequestTypeID int
	declare @Now datetime
	declare @Description varchar(50)
	declare @EpisodeID int

	Begin transaction

		--Fetch some type details
		select @TableID = TableID, @RequestTypeID = RequestTypeID
		from RequestType
		where description = 'Dispensing request'


		--Fetch our current episode
		select @EpisodeID = EpisodeID from episode
		where entityid = @EntityID and episodeid_parent = 0

		--Handy now variable
		set @Now = GetDate()

		--Create a worklist description
		select @Description = 'Dispense ' + sys.FormatDecimal(cast(@NODIssued as decimal(18,3)))


		--Create an episode order
		exec pEpisodeOrderInsert @CurrentSessionID, @RequestID_Prescription, @RequestTypeID, @TableID, @EntityID, 0, @Now, @Now, @Description, @EpisodeID, @EntityID, @RequestID OUTPUT
		if @@ERROR <> 0 rollback transaction

		--Create a wLabel and attach it to the episode order
		Insert into [WLabel] ( RequestID, [DirCode], [Route], [RepeatInterval], [RepeatUnits], [BasePrescriptionId], [Dose1], [Dose2], [Dose3], [Dose4], [Dose5], [Dose6], [Times1], [Times2], [Times3], [Times4], [Times5], [Times6], [PrescriptionId], [ReconVol], [Container], [ReconAbbr], [DiluentAbbr], [FinalVolume], [DrDirection], [ContainerSize], [InfusionTime], [PatId], [SisCode], [Text], [StartDate], [StopDate], [IssType], [LastQty], [LastDate], [TopupQty], [DispId], [PrescriberId], [PharmacistID], [StoppedBy], [NeededNextTime], [RxStartDate], [NodIssued], [BatchNumber], [DeleteDate], [RxNodIssued], [IsHistory], [SiteID], [Day1Mon], [Day2Tue], [Day3Wed], [Day4Thu], [Day5Fri], [Day6Sat], [Day7Sun], [HasRxNotes], [PatientsOwn], [PRN], [ManualQuantity], [rINNflag], [PyxisItem], [Blister], [RevisedInstruction], [RevisedWarning] ) 
		values ( @RequestID, @DirCode, @Route, @RepeatInterval, @RepeatUnits, @BasePrescriptionId, @Dose1, @Dose2, @Dose3, @Dose4, @Dose5, @Dose6, @Times1, @Times2, @Times3, @Times4, @Times5, @Times6, @PrescriptionId, @ReconVol, @Container, @ReconAbbr, @DiluentAbbr, @FinalVolume, @DrDirection, @ContainerSize, @InfusionTime, @PatId, @SisCode, @Text, @StartDate, @StopDate, @IssType, @LastQty, @LastDate, @TopupQty, @DispId, @PrescriberId, @PharmacistID, @StoppedBy, @NeededNextTime, @RxStartDate, @NodIssued, @BatchNumber, @DeleteDate, @RxNodIssued, @IsHistory, @locationid_site, @Day1Mon, @Day2Tue, @Day3Wed, @Day4Thu, @Day5Fri, @Day6Sat, @Day7Sun, @HasRxNotes, @PatientsOwn, @PRN, @ManualQuantity, @rINNflag, @PyxisItem, @Blister, @RevisedInstruction, @RevisedWarning )

		if @@ERROR <> 0 rollback transaction

	If @@TRANCOUNT = 1 Commit

end
GO

