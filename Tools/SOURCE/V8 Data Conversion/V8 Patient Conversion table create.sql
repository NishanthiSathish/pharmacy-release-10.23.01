IF NOT EXISTS (SELECT name FROM   sysobjects WHERE  name = N'V8PatientConversion' AND 	  type = 'U')
BEGIN
	CREATE TABLE [V8PatientConversion] (
		[EntityID]			[int] NOT NULL ,
		[FilePosn]			[int] NOT NULL ,
		[LocationID_Site]	[int] NOT NULL, 
		[Recno] 			[char] (10) NOT NULL ,
		[CaseNo] 			[char] (10) NOT NULL ,
		CONSTRAINT [PK_V8PatientConversion] PRIMARY KEY  CLUSTERED 
		(
			[EntityID]
		)  ON [PRIMARY] ,
		CONSTRAINT [IX_V8PatientConversion2] UNIQUE  NONCLUSTERED 
		(
			[FilePosn],
			[LocationID_Site]
		)  ON [PRIMARY] ,
		CONSTRAINT [FK_V8PatientConversion_Entity] FOREIGN KEY 
		(
			[EntityID]
		) REFERENCES [Entity] (
			[EntityID]
		)
	) ON [PRIMARY]
END
GO

if exists(select * from sysindexes where name = 'IX_V8PatientConversion')
	DROP INDEX V8PatientConversion.IX_V8PatientConversion
GO

CREATE NONCLUSTERED INDEX IX_V8PatientConversion ON V8PatientConversion
	(
	LocationID_Site,
	Recno
	) ON [PRIMARY]
GO


