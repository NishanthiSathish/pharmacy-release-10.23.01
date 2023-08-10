--St Vincents Specific Billing Configuration
--A pre-requisite of this is the generic script
-- ============================================================================================================================================================
-- Author:		TH
-- Create date: Jan14
-- Ref:			77893/77898
-- Description:	St Vincents Specific Billing Configuration
-- ============================================================================================================================================================


exec pDrop 'pPharmacy_GenericBilling_BillPatient'
GO

create procedure [pPharmacy_GenericBilling_BillPatient]
	(
			@CurrentSessionID int
			, @BillPatient    varchar(20)  OUTPUT
	)
	as

begin

	declare @Return as varchar
	declare @Count as int
	declare @EpisodeID as int
	set @Return = '0'
	
	select 
		@EpisodeID = State.PrimaryKey
	from 
		State WITH (NOLOCK)
		join [Table] WITH (NOLOCK) ON State.TableID = [Table].TableID
	where 
		State.SessionID = @CurrentSessionID
		and [Table].[Description] = 'Episode'
		
	if (@EpisodeID > 0)
	begin
		--Now see if we are a payer
		select @Return = COUNT(Episode.EpisodeID) from 
		Episode --on Episode.EntityID =  PharmacyGenericBillingState.EntityID_Patient
		--join EpisodeType on EpisodeType.EpisodeTypeID = Episode.EpisodeTypeID
		join EpisodeNote on EpisodeNote.EpisodeID = Episode.EpisodeID
		Join PatientCareDetails on PatientCareDetails.NoteID = EpisodeNote.NoteID
		Join PatientPaymentCategory on PatientPaymentCategory.PatientPaymentCategoryID = PatientCareDetails.PatientPaymentCategoryID
		
		where Episode.EpisodeID_Parent = 0 
		--and PharmacyGenericBillingState.SessionID = @CurrentSessionID
		and PatientPaymentCategory.Description = 'PAYER'
		--Update State - No not for this its a big switch effectively
		and Episode.EpisodeID = @EpisodeID
	end
	select @BillPatient = @Return 
	
end

GO

exec pDrop 'pPharmacy_GenericBilling_DispFee'
GO

create procedure [pPharmacy_GenericBilling_DispFee]
	(
			@CurrentSessionID int
			, @DispFee    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	select @DispFee = '0' 
	
end

GO

--SELECT TOP 1 IIF([iRefPrice] = 0, [iCost/100], [iRefPrice])  AS BaseCost FROM Dummy;

exec pDrop 'pPharmacy_GenericBilling_BaseCost'
GO

create procedure [pPharmacy_GenericBilling_BaseCost]
	(
			@CurrentSessionID int
			, @BaseCost    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	select @BaseCost = (cast(wProduct.cost as float)/100) from wProduct
	join PharmacyGenericBillingState on (PharmacyGenericBillingState.siteID = wProduct.LocationID_Site and PharmacyGenericBillingState.nsvcode = wProduct.siscode)
	where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
	--Put base cost into State
	Update PharmacyGenericBillingState set BaseCost = @BaseCost where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
end

GO

If not exists(select id from sysobjects where name='StV_PharmacyGenericBilling_MarkUp' and xtype='U')
	begin
		create table StV_PharmacyGenericBilling_MarkUp
		--------------------------------------------------------------------------------------------------------------------------------------------------
		--		Fieldname								Datatype		Constraint					Nullable	Default		Foreign Key   
		--------------------------------------------------------------------------------------------------------------------------------------------------
		(
				StV_PharmacyGenericBilling_MarkUpID		int				IDENTITY(1,1) PRIMARY KEY	NOT NULL
			,	Band									int											NULL				
			,	BottomPrice								float										NULL
			,	TopPrice								float										NULL
			,	MarkUp									float										NULL
			,	MinPrice								float										NULL
		) 
		exec pDocumentTable 'StV_PharmacyGenericBilling_MarkUpID','Markups for St Vincent specific Billing system'
	
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- Column Descriptions
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		
		
	end

Go

if ((select COUNT(*) from StV_PharmacyGenericBilling_MarkUp) = 0)
begin

Insert into StV_PharmacyGenericBilling_MarkUp(Band,BottomPrice,TopPrice,Markup,MinPrice) values(1,0,20,20,1)
Insert into StV_PharmacyGenericBilling_MarkUp(Band,BottomPrice,TopPrice,Markup,MinPrice) values(2,20.01,50,20,1)
Insert into StV_PharmacyGenericBilling_MarkUp(Band,BottomPrice,TopPrice,Markup,MinPrice) values(3,50,100,20,1)
Insert into StV_PharmacyGenericBilling_MarkUp(Band,BottomPrice,TopPrice,Markup,MinPrice) values(4,100,9999,20,1)

end
GO

If not exists(select id from sysobjects where name='StV_PharmacyGenericBilling_TaxRate' and xtype='U')
	begin
		create table StV_PharmacyGenericBilling_TaxRate
		--------------------------------------------------------------------------------------------------------------------------------------------------
		--		Fieldname								Datatype		Constraint					Nullable	Default		Foreign Key   
		--------------------------------------------------------------------------------------------------------------------------------------------------
		(
				StV_PharmacyGenericBilling_TaxRateID	int				IDENTITY(1,1) PRIMARY KEY	NOT NULL
			,	TaxCode									varchar(1)									NULL				
			,	TaxRate									float										NULL
		) 
		exec pDocumentTable 'StV_PharmacyGenericBilling_TaxRate','Tax Rates for St Vincent specific Billing system'
	
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- Column Descriptions
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		
		
	end

Go

if ((select COUNT(*) from StV_PharmacyGenericBilling_TaxRate) = 0)
begin

Insert into StV_PharmacyGenericBilling_TaxRate(TaxCode,TaxRate) values('0',0)
Insert into StV_PharmacyGenericBilling_TaxRate(TaxCode,TaxRate) values('1',21)
Insert into StV_PharmacyGenericBilling_TaxRate(TaxCode,TaxRate) values('2',21)

end
GO

exec pDrop 'pPharmacy_GenericBilling_Markup'
GO

create procedure [pPharmacy_GenericBilling_Markup]
	(
			@CurrentSessionID int
			, @Markup    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	declare @BaseCost as float
	select @BaseCost = BaseCost from PharmacyGenericBillingState where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
	set @Markup = (select top 1 (Markup) FROM StV_PharmacyGenericBilling_MarkUp WHERE @BaseCost BETWEEN BottomPrice AND TopPrice ORDER BY Band DESC)
	
	--Put base cost into State
	Update PharmacyGenericBillingState set MarkUp = @Markup where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
	
end

GO

--SELECT TOP 1 Markup FROM Markup WHERE [BaseCost] BETWEEN BottomPrice AND TopPrice ORDER BY Band DESC;


exec pDrop 'pPharmacy_GenericBilling_PackCost'
GO

create procedure [pPharmacy_GenericBilling_PackCost]
	(
			@CurrentSessionID int
			, @PackCost    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	
	set @PackCost =(SELECT TOP 1 ([BaseCost] * ((100 + [Markup])/100)) FROM PharmacyGenericBillingState where PharmacyGenericBillingState.SessionID = @CurrentSessionID)
		
	--Put Pack cost into State
	Update PharmacyGenericBillingState set PackCost = @PackCost where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
end

GO


--SELECT TOP 1 ([BaseCost] * ((100 + [Markup])/100)) as PackCost FROM Dummy;

exec pDrop 'pPharmacy_GenericBilling_LineCost'
GO

create procedure [pPharmacy_GenericBilling_LineCost]
	(
			@CurrentSessionID int
			, @LineCost    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	--select @LineCost = '7.50' 
	declare @ICost as float
	Declare @PackCost as Float
	Declare @NSVCode as varchar(7)
	declare @DispFee as float
	Declare @PacksIssued as Float
	Declare @IVATCode as varchar(1)
	declare @TaxRate as float
	Declare @SiteID as int
	
	set @DispFee = 0
	
	select @NSVCode = NSVCode, @SiteID = SiteID ,@PackCost = PackCost, @PacksIssued = PacksIssued from PharmacyGenericBillingState where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
	select @IVATCode = VATRate , @ICost= cost from WProduct where wProduct.LocationID_Site = @SiteID and wProduct.siscode = @NSVCode
	if ( @ICost <1)
	begin
		set @ICost =1
	end
	
	set @LineCost =  ((@PackCost * @PacksIssued) + @DispFee) + (( (@PackCost * @PacksIssued) + @DispFee) * ((SELECT TaxRate FROM StV_PharmacyGenericBilling_TaxRate WHERE TaxCode = @IVATCode)/ 100 ) ) 

	--Put Line cost into State
	Update PharmacyGenericBillingState set LineCost = @LineCost where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
	
end

GO


--SELECT TOP 1 IIF(lCost < 1, 1, lCost ) AS LineCost, (SELECT (([PackCost] * [PacksIssued]) + [DispFee]) +(( ([PackCost] * [PacksIssued]) + [DispFee]) * ((SELECT TaxRate FROM TaxRate WHERE TaxCode = '[iVATRate]')/ 100 ) ) AS lCost FROM Dummy) AS lCost FROM Dummy;

exec pDrop 'pPharmacy_GenericBilling_MinPrice'
GO

create procedure [pPharmacy_GenericBilling_MinPrice]
	(
			@CurrentSessionID int
			, @MinPrice    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	--declare @BaseCost as float
	
	--select @BaseCost = Basecost PharmacyGenericBillingState where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
	
	
	select @MinPrice = '2100000000' 
	
end

GO


--SELECT TOP 1 IIF(Price1 >= Price2, Price1, Price2) AS MinPrice, (SELECT TOP 1 MinPrice AS Price1 FROM Markup WHERE (SELECT TOP 1 RefPrice FROM DrugExtra WHERE NSVCode = '[NSVCode]';) BETWEEN BottomPrice AND TopPrice ORDER BY Band DESC;) AS Price1, (SELECT TOP 1 [BaseCost] AS Price2 FROM Dummy;) AS Price2 FROM DrugExtra;


exec pDrop 'PatientBanner_PatientisPAYER'
GO

Create Procedure PatientBanner_PatientisPAYER
	(
		@CurrentSessionID int
		, @EpisodeID int
	)
	as
begin
	
	declare @Return as int
	
	select @Return = COUNT(Episode.EpisodeID) from 
		Episode --on Episode.EntityID =  PharmacyGenericBillingState.EntityID_Patient
		--join EpisodeType on EpisodeType.EpisodeTypeID = Episode.EpisodeTypeID
		join EpisodeNote on EpisodeNote.EpisodeID = Episode.EpisodeID
		Join PatientCareDetails on PatientCareDetails.NoteID = EpisodeNote.NoteID
		Join PatientPaymentCategory on PatientPaymentCategory.PatientPaymentCategoryID = PatientCareDetails.PatientPaymentCategoryID
		
		where Episode.EpisodeID_Parent = 0 
		--and PharmacyGenericBillingState.SessionID = @CurrentSessionID
		and PatientPaymentCategory.Description = 'PAYER'
		--Update State - No not for this its a big switch effectively
		and Episode.EpisodeID = @EpisodeID
	Select 
		Case When @Return > 0 then '<b><u>PATIENT IS PAYER</b></u>'
		Else null
		End as Notes
	
		
	For XML Raw
end

GO

/*--------------------------------------------------------------------------------------
This script creates/updates settings required by Patient Banner form use by Patient Billing, utilising the 'PAYER' status

Version     Date  Person      Detail
1           10Dec13     AS          PatientBanner_Pharmacy_Settings_Payer.sql
   
--------------------------------------------------------------------------------------*/

IF EXISTS(SELECT TOP 1 1 FROM Setting WHERE [System]='PatientBanner' AND [Section]='Pharmacy_Payer' AND [Key]='Fields')
      DELETE FROM Setting WHERE [System]='PatientBanner' AND [Section]='Pharmacy_Payer' AND [Key]='Fields'
IF EXISTS(SELECT TOP 1 1 FROM Setting WHERE [System]='PatientBanner' AND [Section]='Pharmacy_Payer' AND [Key]='Routine')
      DELETE FROM Setting WHERE [System]='PatientBanner' AND [Section]='Pharmacy_Payer' AND [Key]='Routine'
IF EXISTS(SELECT TOP 1 1 FROM Setting WHERE [System]='PatientBanner' AND [Section]='Pharmacy_Payer' AND [Key]='RoutinePosition')
      DELETE FROM Setting WHERE [System]='PatientBanner' AND [Section]='Pharmacy_Payer' AND [Key]='RoutinePosition'

IF NOT EXISTS(SELECT TOP 1 1 FROM Setting WHERE [System]='PatientBanner' AND [Section]='Pharmacy_Payer' AND [Key]='Fields')
    INSERT INTO Setting ([System], [Section], [Key], Value, RoleID, Description) VALUES ('PatientBanner', 'Pharmacy_Payer', 'Fields', 'Current Location,Consultant,Episode Specialty', 0, 'Fields for the standard Pharmacy Payer Configuration supplied by Ascribe')
IF NOT EXISTS(SELECT TOP 1 1 FROM Setting WHERE [System]='PatientBanner' AND [Section]='Pharmacy_Payer' AND [Key]='Routine')
    INSERT INTO Setting ([System], [Section], [Key], Value, RoleID, Description) VALUES ('PatientBanner', 'Pharmacy_Payer', 'Routine', 'PatientBanner_PatientisPAYER', 0, 'Routine to return extra information for the standard Pharmacy Payer Configuration supplied by Ascribe')
IF NOT EXISTS(SELECT TOP 1 1 FROM Setting WHERE [System]='PatientBanner' AND [Section]='Pharmacy_Payer' AND [Key]='RoutinePosition')
    INSERT INTO Setting ([System], [Section], [Key], Value, RoleID, Description) VALUES ('PatientBanner', 'Pharmacy_Payer', 'RoutinePosition', 'before', 0, 'Specifies if the routine output is shown [before] or [after] the rest of the fields')
GO

--Added in tax amount, tax rate, although they dont use this at St Vincents (its built into the other costs

exec pDrop 'pPharmacy_GenericBilling_TaxRate'
GO

create procedure [pPharmacy_GenericBilling_TaxRate]
	(
			@CurrentSessionID int
			, @TaxRate    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	Declare @NSVCode as varchar(7)
	Declare @ITaxCode as varchar(1)
	Declare @SiteID as int
	Declare @ReturnTaxRate as float
	
	
	select @NSVCode = NSVCode, @SiteID = SiteID  from PharmacyGenericBillingState where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
	select @ITaxCode = VATRate from WProduct where wProduct.LocationID_Site = @SiteID and wProduct.siscode = @NSVCode
	
	--we now need to look up the actual rate and turn it into a percentage
	select @ReturnTaxRate = CAST(rtrim(ltrim(REPLACE(Value,'"',''))) as float) from
	wConfiguration where Category = 'D|WorkingDefaults' and SiteID = @SiteID
	and [Key] = 'VAT(' + @ITaxCode + ')'
	
	set @ReturnTaxRate = (@ReturnTaxRate - 1) * 100 -- turn into percentage
	
	set @TaxRate = cast(@ReturnTaxRate as varchar)
	
end

GO

exec pDrop 'pPharmacy_GenericBilling_LineCost'
GO

create procedure [pPharmacy_GenericBilling_LineCost]
	(
			@CurrentSessionID int
			, @LineCost    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	--select @LineCost = '7.50' 
	declare @ICost as float
	Declare @PackCost as Float
	Declare @NSVCode as varchar(7)
	declare @DispFee as float
	Declare @PacksIssued as Float
	Declare @ITaxCode as varchar(1)
	declare @TaxRate as float
	Declare @SiteID as int
	
	set @DispFee = 0
	
	select @NSVCode = NSVCode, @SiteID = SiteID ,@PackCost = PackCost, @PacksIssued = PacksIssued from PharmacyGenericBillingState where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
	select @ITaxCode = VATRate , @ICost= cost from WProduct where wProduct.LocationID_Site = @SiteID and wProduct.siscode = @NSVCode
	if ( @ICost <1)
	begin
		set @ICost =1
	end
	
	--we now need to look up the actual rate and turn it into a percentage
	select @TaxRate = CAST(rtrim(ltrim(REPLACE(Value,'"',''))) as float) from
	wConfiguration where Category = 'D|WorkingDefaults' and SiteID = @SiteID
	and [Key] = 'VAT(' + @ITaxCode + ')'
	
	--set @LineCost =  ((@PackCost * @PacksIssued) + @DispFee) + (( (@PackCost * @PacksIssued) + @DispFee) * ((SELECT TaxRate FROM StV_PharmacyGenericBilling_TaxRate WHERE TaxCode = @IVATCode)/ 100 ) ) 
	set @LineCost =   (( (@PackCost * @PacksIssued) + @DispFee) * (@TaxRate) )

	--Put Line cost into State
	Update PharmacyGenericBillingState set LineCost = @LineCost where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
	
end

GO


exec pDrop 'pPharmacy_GenericBilling_TaxAmount'
GO

create procedure [pPharmacy_GenericBilling_TaxAmount]
	(
			@CurrentSessionID int
			, @TaxAmount    varchar(20)  OUTPUT
	)
	as

begin

	--select @LineCost = '7.50' 
	declare @ICost as float
	Declare @PackCost as Float
	Declare @NSVCode as varchar(7)
	declare @DispFee as float
	Declare @PacksIssued as Float
	Declare @ITaxCode as varchar(1)
	declare @TaxRate as float
	Declare @SiteID as int
	declare @Linecost as float
	declare @ReturnTaxAmount as float
	
	set @DispFee = 0
	
	select @NSVCode = NSVCode, @SiteID = SiteID ,@PackCost = PackCost, @PacksIssued = PacksIssued from PharmacyGenericBillingState where PharmacyGenericBillingState.SessionID = @CurrentSessionID
	
	select @ITaxCode = VATRate , @ICost= cost from WProduct where wProduct.LocationID_Site = @SiteID and wProduct.siscode = @NSVCode
	if ( @ICost <1)
	begin
		set @ICost =1
	end
	
	--we now need to look up the actual rate and turn it into a percentage
	select @TaxRate = CAST(rtrim(ltrim(REPLACE(Value,'"',''))) as float) from
	wConfiguration where Category = 'D|WorkingDefaults' and SiteID = @SiteID
	and [Key] = 'VAT(' + @ITaxCode + ')'
	
	--set @LineCost =  ((@PackCost * @PacksIssued) + @DispFee) + (( (@PackCost * @PacksIssued) + @DispFee) * ((SELECT TaxRate FROM StV_PharmacyGenericBilling_TaxRate WHERE TaxCode = @IVATCode)/ 100 ) ) 
	set @LineCost =  ((@PackCost * @PacksIssued) + @DispFee) 

	set @ReturnTaxAmount =  (@LineCost * @TaxRate)  -@LineCost
	
	set @TaxAmount = CAST(cast(@ReturnTaxAmount as decimal(10,2))as varchar(20))
	
end

GO

-- Add to Version Log
INSERT VersionLog ([Type], Description, [Date]) SELECT 'Config', 'St_Vincents_Billing.sql (Jan 14) v1', GETDATE()
GO

