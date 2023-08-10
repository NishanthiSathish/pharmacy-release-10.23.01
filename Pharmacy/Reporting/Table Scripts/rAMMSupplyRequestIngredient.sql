-- 25May16 KR 39882 Added AMM to reporting db

IF OBJECT_ID('rAMMSupplyRequestIngredient') IS NOT NULL
	DROP TABLE rAMMSupplyRequestIngredient
GO

CREATE TABLE [rAMMSupplyRequestIngredient](
	[AMMSupplyRequestIngredientID] [int] NOT NULL,
	[RequestID] [int] NOT NULL,
	[NSVCode] [varchar](7) NOT NULL,
	[BatchNumber] [varchar](25) NULL,
	[ExpiryDate] [datetime] NULL,
	[State] [char](1) NOT NULL,
	[AssembledBy_Date] [datetime] NULL,
	[AssembledBy_EntityID] [int] NULL,
	[AssembledBy_Initials] varchar(10) NULL,
	[CheckedBy_Date] [datetime] NULL,
	[CheckedBy_EntityID] [int] NULL,
	[CheckedBy_Initials] varchar(10) NULL,
	[QtyInIssueUnits] [float] NULL,
	[FormulaIndex] [int] NOT NULL,
	[ErrorMessage] [varchar](50) NOT NULL,
	[SelfCheckReason] [varchar](50) NOT NULL

 CONSTRAINT [PK_rAMMSupplyRequestIngredient] PRIMARY KEY CLUSTERED 
(
	[AMMSupplyRequestIngredientID] ASC
) ON [PRIMARY])
GO

