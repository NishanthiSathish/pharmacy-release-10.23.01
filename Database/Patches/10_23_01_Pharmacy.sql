SET NOCOUNT ON
GO

-- ==============================================================================================================
-- Author:			Sharmila P
-- Create date: 	25 Oct 2021
-- Ref:				MM-8388 - Support for multiple site addresses - to store Address Telephone number 10.23
-- Description:		Store / Retrieve Address and Telephone number in Location editor
-- ==============================================================================================================

-------------- New column created under Hospital table --------------
IF NOT EXISTS (SELECT 1 FROM [UserColumn] WHERE [TableName] = 'Hospital' AND [ColumnName] = 'TelephoneNumber')
BEGIN
ALTER TABLE icwsys.[Hospital] ADD [TelephoneNumber] [varchar](100) NULL;
END
GO

-------------- New column created under Ward table ----------------
IF NOT EXISTS (SELECT 1 FROM [UserColumn] WHERE [TableName] = 'Ward' AND [ColumnName] = 'Address1')
BEGIN
ALTER TABLE icwsys.[Ward]
ADD [Address1] [varchar](255) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM [UserColumn] WHERE [TableName] = 'Ward' AND [ColumnName] = 'Address2')
BEGIN
ALTER TABLE icwsys.[Ward] ADD [Address2] [varchar](255) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM [UserColumn] WHERE [TableName] = 'Ward' AND [ColumnName] = 'Address3')
BEGIN
ALTER TABLE icwsys.[Ward] ADD [Address3] [varchar](255) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM [UserColumn] WHERE [TableName] = 'Ward' AND [ColumnName] = 'Address4')
BEGIN
ALTER TABLE icwsys.[Ward] ADD [Address4] [varchar](255) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM [UserColumn] WHERE [TableName] = 'Ward' AND [ColumnName] = 'Postcode')
BEGIN
ALTER TABLE icwsys.[Ward] ADD [Postcode] [varchar](10) NULL;
END
GO

IF NOT EXISTS (SELECT 1 FROM [UserColumn] WHERE [TableName] = 'Ward' AND [ColumnName] = 'TelephoneNumber')
BEGIN
ALTER TABLE icwsys.[Ward] ADD [TelephoneNumber] [varchar](100) NULL;
END
GO

-----------------  New Clinic Table Creation with 4 addess fileds and TelephoneNumber -------------------

IF NOT EXISTS (SELECT 1 FROM [UserTable] WHERE [TableName] = 'Clinic')
BEGIN
CREATE TABLE [icwsys].[Clinic](
	[LocationID] [int] NOT NULL,
	[Address1] [varchar](255) NULL,
	[Address2] [varchar](255) NULL,
	[Address3] [varchar](255) NULL,
	[Address4] [varchar](255) NULL,
	[Postcode] [varchar](10) NULL,
	[_TableVersion] [timestamp] NOT NULL,
	[TelephoneNumber] [varchar](100) NULL,
PRIMARY KEY CLUSTERED 
(
	[LocationID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [icwsys].[Clinic]  WITH CHECK ADD FOREIGN KEY([LocationID])
REFERENCES [icwsys].[Location] ([LocationID])


END
GO



----------------- Hospital column populate in location editor ----------------- 

DECLARE @HospitalTableID int ;
DECLARE @ColumnOrder int ;

Set @HospitalTableID = (select TableID from icwsys.LocationType where Description = 'Hospital');
Set @ColumnOrder = (Select MAX (ColumnOrder) from icwsys.[Column] where TableID = @HospitalTableID);

If not exists (select 1 from icwsys.[Column] where Description='TelephoneNumber' and TableID = @HospitalTableID)
begin
	Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
	values (@HospitalTableID,'TelephoneNumber','TelephoneNumber','varchar','100','0','1',@ColumnOrder + 1) ; 
end


If exists (select 1 from icwsys.[Column] where Description='Address1' and nullable = 1 and TableID = @HospitalTableID)
begin

	Update icwsys.[Column] set Nullable = 0 where Description='Address1' and nullable = 1 and TableID = @HospitalTableID ;
end
GO

----------------- Ward column populate in location editor ----------------- 

DECLARE @WardTableID int ;
DECLARE @WardColumnOrder int ;
Set @WardTableID = (select TableID from icwsys.LocationType where Description = 'Ward');
Set @WardColumnOrder = (Select MAX (ColumnOrder) from icwsys.[Column] where TableID = @WardTableID);

If not exists (select 1 from icwsys.[Column] where Description='Address1' and TableID = @WardTableID)
begin
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@WardTableID,'Address1','Address 1','varchar','255','1','1',@WardColumnOrder + 1) ; 
end

If not exists (select 1 from icwsys.[Column] where Description='Address2' and TableID = @WardTableID)
begin
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@WardTableID,'Address2','Address 2','varchar','255','1','1',@WardColumnOrder + 2) ; 
end

If not exists (select 1 from icwsys.[Column] where Description='Address3' and TableID = @WardTableID)
begin
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@WardTableID,'Address3','Address 3','varchar','255','1','1',@WardColumnOrder + 3) ; 
end

If not exists (select 1 from icwsys.[Column] where Description='Address4' and TableID = @WardTableID)
begin
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@WardTableID,'Address4','Address 4','varchar','255','1','1',@WardColumnOrder + 4) ; 
end


If not exists (select 1 from icwsys.[Column] where Description='Postcode' and TableID = @WardTableID)
begin
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@WardTableID,'Postcode','PostCode','varchar','10','1','1',@WardColumnOrder + 5) ;
end


If not exists (select 1 from icwsys.[Column] where Description='TelephoneNumber' and TableID = @WardTableID)
begin 
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@WardTableID,'TelephoneNumber','TelephoneNumber','varchar','100','1','1',@WardColumnOrder + 6) ;
end

GO

----------------- Clinic column populate in location editor ----------------- 

DECLARE @ClinicTableID int ;

If not exists (select 1 from icwsys.[Table] where Description='Clinic')
begin 
Insert into icwsys.[Table] (Description,DisplayName,DisplayWeighting) 
values ('Clinic','Clinic','0') ; 
SET @ClinicTableID = SCOPE_IDENTITY();

If not exists (select 1 from icwsys.[Column] where Description='Address1' and TableID = @ClinicTableID)
begin 

Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@ClinicTableID,'Address1','Address 1','varchar','255','1','1',1) ; 
end


If not exists (select 1 from icwsys.[Column] where Description='Address2' and TableID = @ClinicTableID)
begin 
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@ClinicTableID,'Address2','Address 2','varchar','255','1','1',2) ;
end

If not exists (select 1 from icwsys.[Column] where Description='Address3' and TableID = @ClinicTableID)
begin  
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@ClinicTableID,'Address3','Address 3','varchar','255','1','1',3) ; 
end


If not exists (select 1 from icwsys.[Column] where Description='Address4' and TableID = @ClinicTableID)
begin 
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@ClinicTableID,'Address4','Address 4','varchar','255','1','1',4) ; 
end


If not exists (select 1 from icwsys.[Column] where Description='Postcode' and TableID = @ClinicTableID)
begin 
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@ClinicTableID,'Postcode','Postcode','varchar','10','1','1',5) ;
end


If not exists (select 1 from icwsys.[Column] where Description='TelephoneNumber' and TableID = @ClinicTableID)
begin 
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder) 
values (@ClinicTableID,'TelephoneNumber','TelephoneNumber','varchar','100','1','1',6) ;
end

-------- Createing a relationship between clinic and location table
 
DECLARE @ColumnID_FK int ;
DECLARE @ColumnID_PK int ;
If not exists (select 1 from icwsys.[Column] where Description='LocationID' and TableID = @ClinicTableID)
begin 
Insert into icwsys.[Column] (TableID,Description,Detail,DataType,Length,Nullable,Visible,ColumnOrder,PrimaryKey) 
values (@ClinicTableID,'LocationID','LocationID','int','4','0','1',7,1) ;


SET @ColumnID_FK = SCOPE_IDENTITY();
SET @ColumnID_PK = (select ColumnID from icwsys.[Column] where TableID = (select TableID from icwsys.LocationType where Description = 'clinic') and Description = 'LocationID');

Insert into Relationship (ColumnID_FK,ColumnID_PK, Inheritance) Values (@ColumnID_FK,@ColumnID_PK,1);

update Location set TableID = @ClinicTableID where LocationID in (SELECT LocationID FROM Location
WHERE TableID = (select TableID from icwsys.LocationType where Description = 'clinic') and LocationTypeID = (select LocationTypeID from icwsys.LocationType where Description = 'clinic'));

update LocationType set TableID = @ClinicTableID where Description = 'clinic';

INSERT INTO Clinic (LocationID)
SELECT LocationID FROM Location
WHERE TableID = @ClinicTableID;

end
end
GO 

----------------------- Hospital level SP's ------------------------


exec pdrop 'pHospitalXML'
GO

CREATE procedure [icwsys].[pHospitalXML]
	(
			@CurrentSessionID int
		,	@LocationID int
	)
	as

begin

	Select 
			[Hospital].[LocationID] 
		,	0 +  [Location].[LocationID_Parent] "LocationID_Parent"
		,	0 +  [Location].[LocationTypeID] "LocationTypeID"
		,	0 +  [Location].[TableID] "TableID"
		,	'' +  [Location].[Description] "Description"
		,	'' +  [Location].[Detail] "Detail"
		,	0 +  [Location].[ADAutoLogon] "ADAutoLogon"
		,	'' +  [Hospital].[code] "code"
		,	'' +  [Hospital].[Address1] "Address1"
		,	'' +  [Hospital].[Address2] "Address2"
		,	'' +  [Hospital].[Address3] "Address3"
		,	'' +  [Hospital].[Address4] "Address4"
		,	'' +  [Hospital].[Postcode] "Postcode"
		,	'' +  [Hospital].[TelephoneNumber] "TelephoneNumber"

	from [Hospital] 
	join [Location] on ( [Location].[LocationID] = [Hospital].[LocationID] )
	where [Hospital].[LocationID] = @LocationID
	For XML Auto

end

GO

------------------- Hospital Update -----------------------

exec pdrop 'pHospitalUpdate'
GO


CREATE procedure [icwsys].[pHospitalUpdate]
	(
			@CurrentSessionID int
		,	@LocationID int
		,	@LocationID_Parent int
		,	@LocationTypeID int
		,	@TableID int
		,	@Description varchar(128)
		,	@Detail varchar(1024)
		,	@ADAutoLogon bit
		,	@code varchar(3)
		,	@Address1 varchar(255)
		,	@Address2 varchar(255) = NULL
		,	@Address3 varchar(255) = NULL
		,	@Address4 varchar(255) = NULL
		,	@Postcode varchar(10) = NULL
		,	@TelephoneNumber varchar(100)
	)
	as

begin

	begin transaction

		exec [icwsys].[pLocationUpdate] @CurrentSessionID, @LocationID, @LocationID_Parent, @LocationTypeID, @TableID, @Description, @Detail, @ADAutoLogon

		Update [Hospital]
		Set [code] = @code, [Address1] = @Address1, [Address2] = @Address2, [Address3] = @Address3, [Address4] = @Address4, [Postcode] = @Postcode ,[TelephoneNumber] = @TelephoneNumber
		Where [LocationID] = @LocationID

	If @@ERROR = 0 Commit else Rollback

end

GO

------------------------------ Hospital Insert ---------------------------


exec pdrop 'pHospitalInsert'
GO

CREATE procedure [icwsys].[pHospitalInsert]
	(
			@CurrentSessionID int
		,	@LocationID_Parent int
		,	@LocationTypeID int
		,	@TableID int
		,	@Description varchar(128)
		,	@Detail varchar(1024)
		,	@ADAutoLogon bit
		,	@code varchar(3)
		,	@Address1 varchar(255)
		,	@Address2 varchar(255) = NULL
		,	@Address3 varchar(255) = NULL
		,	@Address4 varchar(255) = NULL
		,	@Postcode varchar(10) = NULL
		,	@TelephoneNumber varchar(100)
		,	@LocationID int OUTPUT
	)
	as

begin

	Begin transaction

	exec [icwsys].[pLocationInsert] @CurrentSessionID, @LocationID_Parent, @LocationTypeID, @TableID, @Description, @Detail, @ADAutoLogon, @LocationID OUTPUT

	Insert into [Hospital] ( [LocationID], [code], [Address1], [Address2], [Address3], [Address4], [Postcode], [TelephoneNumber] ) 
	values ( @LocationID, @code, @Address1, @Address2, @Address3, @Address4, @Postcode, @TelephoneNumber)


	If @@ERROR = 0 Commit else Rollback

end

GO


------------ ward level SP's--------

exec pdrop 'pWardXML'
GO

CREATE procedure [icwsys].[pWardXML]
	(
			@CurrentSessionID int
		,	@LocationID int
	)
	as

begin

	Select 
			[Ward].[LocationID] 
		,	0 +  [Location].[LocationID_Parent] "LocationID_Parent"
		,	0 +  [Location].[LocationTypeID] "LocationTypeID"
		,	0 +  [Location].[TableID] "TableID"
		,	'' +  [Location].[Description] "Description"
		,	'' +  [Location].[Detail] "Detail"
		,	0 +  [Location].[ADAutoLogon] "ADAutoLogon"
		,	0 +  [Ward].[WardTypeID] "WardTypeID"
		,	0 +  [Ward].[Male] "Male"
		,	0 +  [Ward].[Female] "Female"
		,	0 +  [Ward].[SingleRooms] "SingleRooms"
		,	0 +  [Ward].[out_of_use] "out_of_use"
		,	0 +  [Ward].[WardGroupID] "WardGroupID"
		,	'' +  [Ward].[Address1] "Address1"
		,	'' +  [Ward].[Address2] "Address2"
		,	'' +  [Ward].[Address3] "Address3"
		,	'' +  [Ward].[Address4] "Address4"
		,	'' +  [Ward].[Postcode] "Postcode"
		,	'' +  [Ward].[TelephoneNumber] "TelephoneNumber"

	from [Ward] 
	join [Location] on ( [Location].[LocationID] = [Ward].[LocationID] )
	where [Ward].[LocationID] = @LocationID
	For XML Auto

end

GO

---------------------- Ward Insert ----------------------

exec pdrop 'pWardInsert'
GO

CREATE procedure [icwsys].[pWardInsert]
	(
			@CurrentSessionID int
		,	@LocationID_Parent int = 0
		,	@LocationTypeID int
		,	@TableID int
		,	@Description varchar(128)
		,	@Detail varchar(1024)
		,	@ADAutoLogon bit = '0'
		,	@WardTypeID int
		,	@Male bit
		,	@Female bit
		,	@Address1 varchar(255) = NULL
		,	@Address2 varchar(255) = NULL
		,	@Address3 varchar(255) = NULL
		,	@Address4 varchar(255) = NULL
		,	@Postcode varchar(10) = NULL
		,	@TelephoneNumber varchar(100) = NULL
		,	@SingleRooms int
		,	@out_of_use bit = '0'
		,	@WardGroupID int = 0
		,	@LocationID int OUTPUT
	)
	as

begin

	Begin transaction

	exec [icwsys].[pLocationInsert] @CurrentSessionID, @LocationID_Parent, @LocationTypeID, @TableID, @Description, @Detail, @ADAutoLogon, @LocationID OUTPUT

	Insert into [Ward] ( [LocationID], [WardTypeID], [Male], [Female], [SingleRooms], [out_of_use], [WardGroupID], [Address1], [Address2], [Address3], [Address4], [Postcode], [TelephoneNumber] ) 
	values ( @LocationID, @WardTypeID, @Male, @Female, @SingleRooms, @out_of_use, @WardGroupID,  @Address1, @Address2, @Address3, @Address4, @Postcode, @TelephoneNumber )


	If @@ERROR = 0 Commit else Rollback

end

GO


---------------------- Ward Update --------------------

exec pdrop 'pWardUpdate'
GO

CREATE procedure [icwsys].[pWardUpdate]
	(
			@CurrentSessionID int
		,	@LocationID int
		,	@LocationID_Parent int = 0
		,	@LocationTypeID int
		,	@TableID int
		,	@Description varchar(128)
		,	@Detail varchar(1024)
		,	@ADAutoLogon bit = '0'
		,	@WardTypeID int
		,	@Male bit
		,	@Female bit
		,	@Address1 varchar(255) = NULL
		,	@Address2 varchar(255) = NULL
		,	@Address3 varchar(255) = NULL
		,	@Address4 varchar(255) = NULL
		,	@Postcode varchar(10) = NULL
		,	@TelephoneNumber varchar(100) = NULL
		,	@SingleRooms int
		,	@out_of_use bit = '0'
		,	@WardGroupID int = 0
	)
	as

begin

	begin transaction

		exec [icwsys].[pLocationUpdate] @CurrentSessionID, @LocationID, @LocationID_Parent, @LocationTypeID, @TableID, @Description, @Detail, @ADAutoLogon

		Update [Ward]
		Set [WardTypeID] = @WardTypeID, [Male] = @Male, [Female] = @Female, [SingleRooms] = @SingleRooms, [out_of_use] = @out_of_use, [WardGroupID] = @WardGroupID, [Address1] = @Address1, [Address2] = @Address2, [Address3] = @Address3, [Address4] = @Address4, [Postcode] = @Postcode ,[TelephoneNumber] = @TelephoneNumber
		Where [LocationID] = @LocationID

	If @@ERROR = 0 Commit else Rollback

end

GO


---------------------- Clinic level SP's ----------------------

exec pdrop 'pClinicXML'
GO

CREATE procedure [icwsys].[pClinicXML]
	(
			@CurrentSessionID int
		,	@LocationID int
	)
	as

begin

	Select 
			[Clinic].[LocationID] 
		,	0 +  [Location].[LocationID_Parent] "LocationID_Parent"
		,	0 +  [Location].[LocationTypeID] "LocationTypeID"
		,	0 +  [Location].[TableID] "TableID"
		,	'' +  [Location].[Description] "Description"
		,	'' +  [Location].[Detail] "Detail"
		,	0 +  [Location].[ADAutoLogon] "ADAutoLogon"
		,	'' +  [Clinic].[Address1] "Address1"
		,	'' +  [Clinic].[Address2] "Address2"
		,	'' +  [Clinic].[Address3] "Address3"
		,	'' +  [Clinic].[Address4] "Address4"
		,	'' +  [Clinic].[Postcode] "Postcode"
		,	'' +  [Clinic].[TelephoneNumber] "TelephoneNumber"

	from [Clinic] 
	join [Location] on ( [Location].[LocationID] = [Clinic].[LocationID] )
	where [Clinic].[LocationID] = @LocationID
	For XML Auto

end

GO

------------------- Clinic Update -----------------------

exec pdrop 'pClinicUpdate'
GO

CREATE procedure [icwsys].[pClinicUpdate]
	(
			@CurrentSessionID int
		,	@LocationID int
		,	@LocationID_Parent int
		,	@LocationTypeID int
		,	@TableID int
		,	@Description varchar(128)
		,	@Detail varchar(1024)
		,	@ADAutoLogon bit
		,	@Address1 varchar(255) = NULL
		,	@Address2 varchar(255) = NULL
		,	@Address3 varchar(255) = NULL
		,	@Address4 varchar(255) = NULL
		,	@Postcode varchar(10) = NULL
		,	@TelephoneNumber varchar(100) = NULL
	)
	as

begin

	begin transaction

		exec [icwsys].[pLocationUpdate] @CurrentSessionID, @LocationID, @LocationID_Parent, @LocationTypeID, @TableID, @Description, @Detail, @ADAutoLogon

		Update [Clinic]
		Set [Address1] = @Address1, [Address2] = @Address2, [Address3] = @Address3, [Address4] = @Address4, [Postcode] = @Postcode ,[TelephoneNumber] = @TelephoneNumber
		Where [LocationID] = @LocationID

	If @@ERROR = 0 Commit else Rollback

end

GO

------------------------------ Clinic Insert ---------------------------

exec pdrop 'pClinicInsert'
GO

CREATE procedure [icwsys].[pClinicInsert]
	(
			@CurrentSessionID int
		,	@LocationID_Parent int
		,	@LocationTypeID int
		,	@TableID int
		,	@Description varchar(128)
		,	@Detail varchar(1024)
		,	@ADAutoLogon bit
		,	@Address1 varchar(255) = NULL
		,	@Address2 varchar(255) = NULL
		,	@Address3 varchar(255) = NULL
		,	@Address4 varchar(255) = NULL
		,	@Postcode varchar(10) = NULL
		,	@TelephoneNumber varchar(100) = NULL
		,	@LocationID int OUTPUT
	)
	as

begin

	Begin transaction

	exec [icwsys].[pLocationInsert] @CurrentSessionID, @LocationID_Parent, @LocationTypeID, @TableID, @Description, @Detail, @ADAutoLogon, @LocationID OUTPUT

	Insert into [Clinic] ( [LocationID], [Address1], [Address2], [Address3], [Address4], [Postcode], [TelephoneNumber] ) 
	values ( @LocationID, @Address1, @Address2, @Address3, @Address4, @Postcode, @TelephoneNumber)


	If @@ERROR = 0 Commit else Rollback

end

GO

------------------------ Clinic Delete ----------------------------
exec pdrop 'pClinicDelete'
GO
create procedure [icwsys].[pClinicDelete]
	(
			@CurrentSessionID int
		,	@LocationID int
	)
	as

begin

declare @Error int

	set @Error = 0

	begin transaction

		Delete [Clinic] Where [LocationID] = @LocationID
		set @Error = @@ERROR

		exec [icwsys].[pLocationDelete] @CurrentSessionID, @LocationID
		set @Error = @Error + @@ERROR

	if @Error = 0 commit else rollback

end

GO


/****************************************************************************************************************************
!!!!!!!!!!!!!!!!!! MAKE SURE TableVersionOnly Enable be the last statement on this FILE !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*****************************************************************************************************************************/

exec [icwsys].[pTableVersionOnlyEnable]
GO
