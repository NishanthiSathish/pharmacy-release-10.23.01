--04Mar08 JKu Changed length of Consultant field to 255 char long.

IF OBJECT_ID('rConsultant') IS NOT NULL
	DROP TABLE rConsultant
GO

CREATE TABLE rConsultant (
	Consultant varchar (255) NOT NULL ,
	GMCCode varchar (20),
	ConsultantName varchar (500),
	Tel varchar (20)
) 
GO


-- =======================================================================================================
-- Author:	Aidan Kent (AK)
-- Create date: 04nov08
-- Ref:		F0036909
-- Description:	Create index for joins used by Cognos reporting
-- =======================================================================================================

IF exists (SELECT * from sysindexes where name = N'IX_rConsultant_Consultant' and id = object_id(N'[rConsultant]'))
DROP INDEX [rConsultant].[IX_rConsultant_Consultant]
GO
CREATE INDEX [IX_rConsultant_Consultant] ON [rConsultant]([Consultant]) ON [PRIMARY]
GO
