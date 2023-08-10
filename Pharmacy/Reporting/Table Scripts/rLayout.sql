IF OBJECT_ID('rLayout') IS NOT NULL
	DROP TABLE rLayout
GO

CREATE TABLE rLayout (
	[WLayoutID] [int] NOT NULL ,
	[LocationID_Site] [int] NOT NULL ,
	[PatientsPerSheet] [int] NULL ,
	[Layout] [varchar] (50) NULL ,
	[LineText] [varchar] (1024) NULL ,
	[IngLineText] [varchar] (1024) NULL ,
	[Prescription] [varchar] (5000) NULL ,
	[name] [varchar] (10) NULL ,
	[WManufacturingStatusID] [int] NOT NULL ,
	[EntityID_Drafted] [int] NOT NULL ,
	[EntityID_Approved] [int] NOT NULL ,
	[DateDrafted] [datetime] NULL ,
	[DateApproved] [datetime] NULL ,
	[VersionNumber] [int] NULL
	
) 
GO


