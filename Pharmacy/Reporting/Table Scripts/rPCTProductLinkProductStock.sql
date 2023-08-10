-- =======================================================================================================
-- Author:			Aidan Kent
-- Create date:		20Mar12
-- Ref:				29661
-- Description:		Added rPCTProductLinkProductStock structure
-- =======================================================================================================

IF OBJECT_ID('rPCTProductLinkProductStock') IS NOT NULL
	DROP TABLE rPCTProductLinkProductStock
GO

CREATE TABLE rPCTProductLinkProductStock (
	[PCTProductLinkProductStockID] [int] NOT NULL,
	[ProductStockID] [int] NOT NULL,
	[PCTMasterProductID] [int] NOT NULL,
	[Primary] [bit] NOT NULL
	) 
GO


