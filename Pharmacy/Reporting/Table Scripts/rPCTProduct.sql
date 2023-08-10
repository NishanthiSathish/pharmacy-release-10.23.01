-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added rPCTProduct structure
-- =======================================================================================================

IF OBJECT_ID('rPCTProduct') IS NOT NULL
	DROP TABLE rPCTProduct
GO

CREATE TABLE rPCTProduct (
	[BrandCode] [int] NULL,
	[BrandName] [nvarchar](40) NOT NULL,
	[FormulationName] [nvarchar](200) NOT NULL,
	[ChemicalName] [nvarchar](220) NOT NULL,
	[PharmaCode] [int] NOT NULL,
	[Quantity] [real] NULL,
	[Multiple] [real] NULL,
	[Specified] [bit] NULL,
	[Subsidy] [decimal](19, 4) NULL,
	[Alternate] [decimal](19, 4) NULL,
	[Price] [decimal](19, 4) NULL,
	[CBS] [bit] NULL,
	[OP] [bit] NULL,
	[SpecialType] [nvarchar](25) NULL,
	[SpecialEndorsementType] [nvarchar](25) NULL,
	[DrugFileDate] [datetime] NOT NULL,
	[Units] [varchar](5) NULL,
	[PCTMasterProductID] [int] NOT NULL,
	[PCTProductID] [int] NOT NULL
	) 
GO


