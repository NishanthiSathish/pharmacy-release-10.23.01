-- =======================================================================================================
-- Author:			Simon Tipper
-- Create date:		02Oct16
-- Ref:				128799
-- Description:		Added rContextAudit structure
-- =======================================================================================================

IF OBJECT_ID('rContextAudit') IS NOT NULL
	DROP TABLE rContextAudit
GO

CREATE TABLE rContextAudit (
	ContextAuditID INT PRIMARY KEY NOT NULL,
	Username VARCHAR(256) NULL,
	AuditDate DATETIME NULL,
	Terminal VARCHAR(15) NULL,
	Forename VARCHAR(128) NULL,
	Surname VARCHAR(128) NULL,
	DateOfBirth DATETIME NULL,
	PrimaryIdentifier VARCHAR(255) NULL,
	HospitalNumber VARCHAR(255) NULL,
	EpisodeDescription VARCHAR(128) NULL,
	EpisodeLocation VARCHAR(128) NULL,
	EpisodeConsultant VARCHAR(128) NULL,
	Desktop VARCHAR(50) NULL
) 
GO