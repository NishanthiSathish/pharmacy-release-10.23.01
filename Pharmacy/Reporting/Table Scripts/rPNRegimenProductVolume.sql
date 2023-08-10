-- 14Feb13 XN 30286 Added PN to reporting db

IF OBJECT_ID('rPNRegimenProductVolume') IS NOT NULL
	DROP TABLE rPNRegimenProductVolume   
GO

CREATE TABLE [rPNRegimenProductVolume](
	[PNRegimenProductVolumeID] [int] NOT NULL,
	[RequestID] [int] NOT NULL,
	[PNProductID] [int] NOT NULL,
	[Volume_mL] [float] NOT NULL,
	[TotalVolumeIncOverage] [float] NULL,
 CONSTRAINT [PK_rPNRegimenProductVolumeID] PRIMARY KEY CLUSTERED 
(
	[PNRegimenProductVolumeID] ASC
)) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_rPNRegimenProductVolume_RequestID] ON [rPNRegimenProductVolume] 
(
	RequestID
)
GO
