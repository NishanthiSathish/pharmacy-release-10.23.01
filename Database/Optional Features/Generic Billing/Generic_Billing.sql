-- ============================================================================================================================================================
-- Author:		TH
-- Create date: Jan14
-- Ref:			77893
-- Description:	Generic Billing Accelerator script
-- ============================================================================================================================================================
--21Jan14 TH Generic Billing Accelerator script. 
--Note that this is a pre-requisite for any generic billing functionality.
--However on its own it does NOT provide a vanilla billing system as such a 
--thing does not exist. Therefore this requires a subsequent site specific configuration to
--be run in order to create a full billing system.
--22Jan14 TH changed some default sps to conform to the proper conventions - v2 TFS 82740
--23Sep14 XN Update version number
--13Apr15 XN Update version number 115904
--14Dec15 XN Update version number 

--10.14 Compatible Version
--01  12Jan16 JP		TFS 140209 - First Version

if not exists(select id from sysobjects where name='PharmacyGenericBillingState' and xtype='U')
	begin
		create table PharmacyGenericBillingState
		--------------------------------------------------------------------------------------------------------------------------------------------------
		--		Fieldname						Datatype		Constraint					Nullable	Default		Foreign Key   
		--------------------------------------------------------------------------------------------------------------------------------------------------
		(
				PharmacyGenericBillingStateID			int		IDENTITY(1,1) PRIMARY KEY	NOT NULL
			,	SessionID								int									NOT NULL				
			,	EntityID_Patient						int									NULL
			,	SiteID									int									NULL
			,	NSVCode									varchar(7)							NULL
			,	RequestID_Dispensing					int									NULL
			,	BaseCost								Float								NULL
			,	MarkUp									Float								NULL
			,	PackCost								Float								NULL
			,	LineCost								Float								NULL
			,	Taxrate									Float								NULL
			,	DispFee									Float								NULL
			,	MinPrice								Float								NULL
			,	TaxAmount								Float								NULL
			,	PacksIssued								Float								NULL
			) 
		exec pDocumentTable 'PharmacyGenericBillingState','PharmacyGenericBillingState holds Billing Information in state'
	
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- Column Descriptions
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		exec pDocumentColumn 'PharmacyGenericBillingState', 'PharmacyGenericBillingStateID', 'Primary Key'
		exec pDocumentColumn 'PharmacyGenericBillingState', 'SessionID', 'Session'
		exec pDocumentColumn 'PharmacyGenericBillingState', 'EntityID_Patient', 'Patient in State'
		
		--exec pImportSingleTableMetaData 'WlabelAudit'
	end

Go

exec pDrop 'pPharmacyGenericBillingStateWriteFromIssue'
Go

Create procedure [icwsys].[pPharmacyGenericBillingStateWriteFromIssue]
	(
			@CurrentSessionID 				int
		,	@EntityID_Patient				int
		,	@SiteID							int									
		,	@NSVCode						varchar(7)							
		,	@RequestID_Dispensing			int
		,	@PacksIssued					float
		)
	as

begin

	Begin transaction
	declare @PharmacyGenericBillingStateID as int
	if ((select COUNT(SessionID) from PharmacyGenericBillingState where SessionID = @CurrentSessionID) >0)
		begin
			--Update
			Update PharmacyGenericBillingState set 
				EntityID_Patient = @EntityID_Patient, SiteID = @SiteID, NSVCode=@NSVCode,PacksIssued=@PacksIssued
			where SessionID = @CurrentSessionID
		end
	else
		begin
			--Insert
			Insert into PharmacyGenericBillingState ( [SessionID], [EntityID_Patient], [SiteID], [NSVCode], [RequestID_Dispensing], [PacksIssued])
			values ( @CurrentSessionID, @EntityID_Patient, @SiteID, @NSVCode, @RequestID_Dispensing,@PacksIssued)
		end

	If @@ERROR = 0 Commit else Rollback
	Set @PharmacyGenericBillingStateID = @@IDENTITY

	return @PharmacyGenericBillingStateID
end


GO



exec pDrop 'pPharmacy_GenericBilling_Trancharge'
GO

create procedure [pPharmacy_GenericBilling_Trancharge]
	(
			@CurrentSessionID int
			, @Trancharge    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	select @Trancharge = '2100000000' 
	
end

GO

exec pDrop 'pPharmacy_GenericBilling_BillPatient'
GO

create procedure [pPharmacy_GenericBilling_BillPatient]
	(
			@CurrentSessionID int
			, @BillPatient    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	select @BillPatient = '2100000000' 
	
end

GO

exec pDrop 'pPharmacy_GenericBilling_OpenTransaction'
GO

create procedure [pPharmacy_GenericBilling_OpenTransaction]
	(
			@CurrentSessionID int
			, @OpenTransaction    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	select @OpenTransaction = '21000000000' 
	
end

GO

exec pDrop 'pPharmacy_GenericBilling_BillItem'
GO

create procedure [pPharmacy_GenericBilling_BillItem]
	(
			@CurrentSessionID int
			, @BillItem    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	select @BillItem = '2100000000' 
	
end

GO

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
	
	select @BaseCost = '0' 
	
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
	
	select @Markup = '2100000000' 
	
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
	
	select @DispFee = '2100000000' 
	
end

GO

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
	
	select @MinPrice = '2100000000' 
	
end

GO

exec pDrop 'pPharmacy_GenericBilling_PrevLine'
GO

create procedure [pPharmacy_GenericBilling_PrevLine]
	(
			@CurrentSessionID int
			, @PrevLine    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	select @PrevLine = '2100000000' 
	
end

GO

exec pDrop 'pPharmacy_GenericBilling_ShowUI'
GO

create procedure [pPharmacy_GenericBilling_ShowUI]
	(
			@CurrentSessionID int
			, @ShowUI    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	select @ShowUI = '2100000000' 
	
end

GO

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
	
	select @PackCost = '2100000000' 
	
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
	
	select @LineCost = '2100000000' 
	
end

GO

--TranBill

if not exists(select id from sysobjects where name='PharmacyGenericBilling_Transaction' and xtype='U')
	begin
		create table PharmacyGenericBilling_Transaction
		--------------------------------------------------------------------------------------------------------------------------------------------------
		--		Fieldname								Datatype		Constraint					Nullable	Default		Foreign Key   
		--------------------------------------------------------------------------------------------------------------------------------------------------
		(
				PharmacyGenericBilling_TransactionID	int				IDENTITY(1,1) PRIMARY KEY	NOT NULL
			,	EntityID_Patient						int											NOT NULL				
			,	Caseno									varchar(10)									NOT NULL
			,	Surname									varchar(20)									NULL
			,	Forename								varchar(15)									NOT NULL
			,	DOB										varchar(8)									NULL
			,	PrintedInits							varchar(3)									NULL
			,	Printed									bit											NULL
			,	PrintedDT								datetime									NULL
			,	TransactionCharge						float
			,	CreatedDT								datetime									NULL  default(getdate())
			,	SiteID									Int											NULL
			) 
		exec pDocumentTable 'PharmacyGenericBilling_Transaction','PharmacyGenericBilling_Transaction holds Billing Transactional Information'
	
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- Column Descriptions
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		exec pDocumentColumn 'PharmacyGenericBillingState', 'PharmacyGenericBillingStateID', 'Primary Key'
		exec pDocumentColumn 'PharmacyGenericBillingState', 'SessionID', 'Session'
		exec pDocumentColumn 'PharmacyGenericBillingState', 'EntityID_Patient', 'Patient in State'
		
		--exec pImportSingleTableMetaData 'WlabelAudit'
	end

Go


if not exists(select id from sysobjects where name='PharmacyGenericBilling_TransactionLine' and xtype='U')
	begin
		create table PharmacyGenericBilling_TransactionLine
		--------------------------------------------------------------------------------------------------------------------------------------------------
		--		Fieldname									Datatype		Constraint					Nullable	Default		Foreign Key   
		--------------------------------------------------------------------------------------------------------------------------------------------------
		(
				PharmacyGenericBilling_TransactionLineID	int		IDENTITY(1,1) PRIMARY KEY	NOT NULL
			,	PharmacyGenericBilling_TransactionID		int									NOT NULL CONSTRAINT FK_PharmacyGenericBilling_Transaction_PharmacyGenericBilling_TransactionID FOREIGN KEY References PharmacyGenericBilling_Transaction([PharmacyGenericBilling_TransactionID])
			,	RequestID_Dispensing						int									NOT NULL				
			,	PrescriptionID								int									NOT NULL				
			,	BasePrescriptionID							int									NOT NULL
			,	NSVCode										varchar(7)							NULL
			,	LineCost									float								NULL
			,	PacksIssued									float								NULL
			,	IssueQty									float								NULL
			,	BaseCost									float								NULL
			,	markup										float								NULL
			,	CreateInits									varchar(3)							NULL
			,	CreateDT									datetime							NULL
			,	ProductDesc									varchar(56)							NULL
			,	CostAdjust									float								NULL
			,	MarkupAdjust								float								NULL
			,	DispFee										float								NULL
			,	DispAdjust									float								NULL
			,	TaxRate										float								NULL
			,	TaxAdjust									float								NULL
			,	LineAdjust									float								NULL
			,	PackCost								    Float								NULL
			,	TaxAmount								    Float								NULL
			,	SiteID										Int									NULL
			) 
		exec pDocumentTable 'PharmacyGenericBilling_Transaction','PharmacyGenericBilling_Transaction holds Billing Transactional Information'
	
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		-- Column Descriptions
		-----------------------------------------------------------------------------------------------------------------------------------------------------
		--exec pDocumentColumn 'PharmacyGenericBilling_TransactionLine', 'PharmacyGenericBilling_TransactionLineID', 'Primary Key'
		--exec pDocumentColumn 'PharmacyGenericBilling_TransactionLine', 'SessionID', 'Session'
		--exec pDocumentColumn 'PharmacyGenericBilling_TransactionLine', 'EntityID_Patient', 'Patient in State'
		
		--exec pImportSingleTableMetaData 'WlabelAudit'
	end

Go


pImportSingleTableMetaData 'PharmacyGenericBilling_TransactionLine'
GO

pImportSingleTableMetaData 'PharmacyGenericBilling_Transaction'
GO


--drop table PharmacyGenericBilling_Transaction

exec pDrop 'pPharmacyGenericBilling_TransactionbyID'
GO

create procedure [pPharmacyGenericBilling_TransactionbyID]
	(
			@CurrentSessionID int
		,	@PharmacyGenericBilling_TransactionID int
	)
	as

begin

	Select 
	*
	from [PharmacyGenericBilling_Transaction] 
	where [PharmacyGenericBilling_Transaction].[PharmacyGenericBilling_TransactionID] = @PharmacyGenericBilling_TransactionID

end

GO

exec pDrop 'pPharmacyGenericBilling_TransactionLineIDsbyTransactionID'
GO

create procedure [pPharmacyGenericBilling_TransactionLineIDsbyTransactionID]
	(
			@CurrentSessionID int
		,	@PharmacyGenericBilling_TransactionID int
	)
	as

begin

	Select 
	PharmacyGenericBilling_TransactionLineID
	from [PharmacyGenericBilling_TransactionLine] 
	where [PharmacyGenericBilling_TransactionLine].[PharmacyGenericBilling_TransactionID] = @PharmacyGenericBilling_TransactionID

end

GO

exec pDrop 'pPharmacyGenericBilling_TransactionLinebyID'
GO

create procedure [pPharmacyGenericBilling_TransactionLinebyID]
	(
			@CurrentSessionID int
		,	@PharmacyGenericBilling_TransactionLineID int
	)
	as

begin

	Select 
	*
	from [PharmacyGenericBilling_TransactionLine] 
	where [PharmacyGenericBilling_TransactionLine].[PharmacyGenericBilling_TransactionLineID] = @PharmacyGenericBilling_TransactionLineID

end

GO

exec pDrop 'pPharmacyGenericBilling_TransactionbyEntityID_PatientforInvoicing'
GO

create procedure [pPharmacyGenericBilling_TransactionbyEntityID_PatientforInvoicing]
	(
			@CurrentSessionID int
		,	@EntityID_Patient int
		,	@SiteID int
	)
	as

begin

	Select top 10
	PharmacyGenericBilling_Transaction.*
	from [PharmacyGenericBilling_Transaction] 
	where [PharmacyGenericBilling_Transaction].[EntityID_Patient] = @EntityID_Patient
	and [PharmacyGenericBilling_Transaction].[SiteID] = @SiteID
	order by Printed asc,PharmacyGenericBilling_TransactionID desc

end

GO

exec pDrop 'pPharmacyGenericBillingState_ClearState'
GO

create procedure pPharmacyGenericBillingState_ClearState
	(
			@CurrentSessionID int
	)
	as

begin

	Update pharmacyGenericBillingState
	set EntityID_Patient=null
	,	SiteID = null	
	,	NSVCode	 = null
	,	RequestID_Dispensing =null
	,	BaseCost = null
	,	MarkUp = null
	,	PackCost= null
	,	LineCost = null
	,	Taxrate = null
	,	DispFee = null
	,	MinPrice = null
	,	TaxAmount = null
	
	where
	SessionID = @CurrentSessionID
	

end

GO

exec pDrop 'pPharmacy_GenericBilling_TransactionOpen'
GO

Create Procedure [pPharmacy_GenericBilling_TransactionOpen]
	(
			@CurrentSessionID         int
		,	@PatRecno				int
		,	@SiteID					int
	)
	as

begin

	declare @ResultID int
	
	select @ResultID =PharmacyGenericBilling_TransactionID from  PharmacyGenericBilling_Transaction
	Where PharmacyGenericBilling_Transaction.EntityID_Patient = @PatRecno 
	and PharmacyGenericBilling_Transaction.Printed is null
	and PharmacyGenericBilling_Transaction.SiteID = @SiteID
	
	return isnull(@ResultID,0)
	
end

GO


--06Jan14 TH Wasnt picking up the open transaction properly (TFS )

exec pDrop 'pPharmacy_GenericBilling_TransactionOpen'
GO

create Procedure [pPharmacy_GenericBilling_TransactionOpen]
	(
			@CurrentSessionID         int
		,	@PatRecno				int
		,	@SiteID					int
	)
	as

begin

	declare @ResultID int
	
	select @ResultID =PharmacyGenericBilling_TransactionID from  PharmacyGenericBilling_Transaction
	Where PharmacyGenericBilling_Transaction.EntityID_Patient = @PatRecno 
	and (PharmacyGenericBilling_Transaction.Printed is null or PharmacyGenericBilling_Transaction.Printed =0)
	and PharmacyGenericBilling_Transaction.SiteID = @SiteID
	
	return isnull(@ResultID,0)
	
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

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	select @TaxAmount = '2100000000' 
	
end

GO

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
	
	select @TaxRate = '2100000000' 
	
end

GO

--21Jan14 TH Added extra sp for generic

exec pDrop 'pPharmacy_GenericBilling_OpenTransaction'
GO

create procedure [pPharmacy_GenericBilling_OpenTransaction]
	(
			@CurrentSessionID int
			, @OpenTransaction    varchar(20)  OUTPUT
	)
	as

begin

	--declare @Return as varchar
	
	--set @Return = '2100000000'
	
	select @OpenTransaction = '2100000000' 
	
end


GO

-- ============================================================================================================================================================
-- Author:	TH
-- Create date: 06Mar14
-- Ref:		85620
-- Description:	Missing sp discovered in on-site testing
-- ============================================================================================================================================================



exec pDrop 'pPharmacyGenericBillingTransactionOpen'
GO

create Procedure [pPharmacyGenericBillingTransactionOpen]
	(
			@CurrentSessionID         int
		,	@PatRecno				int
		,	@SiteID					int
	)
	as

begin

	declare @ResultID int
	
	select @ResultID =PharmacyGenericBilling_TransactionID from  PharmacyGenericBilling_Transaction
	Where PharmacyGenericBilling_Transaction.EntityID_Patient = @PatRecno 
	and (PharmacyGenericBilling_Transaction.Printed is null or PharmacyGenericBilling_Transaction.Printed =0)
	and PharmacyGenericBilling_Transaction.SiteID = @SiteID
	
	return isnull(@ResultID,0)
	
end


GO


-- Add to Version Log
INSERT VersionLog ([Type], Description, [Date]) SELECT 'Config', 'Generic_Billing.sql (10.14) v1', GETDATE()
GO







































































