

-- =======================================================================================================
-- Author:			Paul Crawford (PJC)
-- Create date:	20Aug09
-- Ref:				F0066390
-- Description:		Added Stock holding site table.
--
-- =======================================================================================================

IF OBJECT_ID('rSite') IS NOT NULL
	DROP TABLE rSite
GO

CREATE TABLE rSite (
	Site int PRIMARY KEY NOT NULL ,
	Description varchar (128) NOT NULL ,
	Detail varchar (1024) NOT NULL,
	LocationID int NOT NULL
	) 
GO


