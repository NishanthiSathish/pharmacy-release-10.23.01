-- 25May16 KR 39882 Added AMM to reporting db

IF OBJECT_ID('rAMMNote') IS NOT NULL
	DROP TABLE rAMMNote
GO

CREATE TABLE [rAMMNote](
	NoteID int NOT NULL,
	AMMSupplyRequestID [int] NOT NULL,
	NoteType varchar(50),
	[Description] varchar(256) NOT NULL,
	ReportErrorReason varchar(60) NULL,
	ReportErrorComments varchar(60) NULL,
	Creator_EntityID [int] NOT NULL,
	Creator_Initials varchar(10) NULL,
	CreatedDate datetime NOT NULL
 CONSTRAINT [PK_rAMMNote] PRIMARY KEY CLUSTERED 
(
	[NoteID] ASC
) ON [PRIMARY])
GO

CREATE NONCLUSTERED INDEX [IX_rAMMNote_Request_NoteID] ON [rAMMNote] 
(
    AMMSupplyRequestID,
    NoteID
)
GO
