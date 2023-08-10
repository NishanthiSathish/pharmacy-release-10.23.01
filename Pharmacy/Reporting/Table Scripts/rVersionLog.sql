--29Apr14 TH Site Specific Patch for Stockport.Includes Versioning additions TFS 86070


if OBJECT_ID('rVersionLog') is null 

begin
CREATE TABLE [rVersionLog](
	[PatchLogID] [int] IDENTITY(1,1) NOT NULL,
	[Type] [varchar](50) NOT NULL,
	[Description] [varchar](512) NOT NULL,
	[Date] [datetime] NULL,
	[_TableVersion] [timestamp] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PatchLogID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [PRIMARY]
) ON [PRIMARY]

ALTER TABLE [rVersionLog]  WITH CHECK ADD  CONSTRAINT [CK_VersionLog_Type] CHECK  (([Type]='System' OR [Type]='DSS' OR [Type] like 'Config%' OR [Type]='Encryption'))


ALTER TABLE [rVersionLog] CHECK CONSTRAINT [CK_VersionLog_Type]

ALTER TABLE [rVersionLog] ADD  DEFAULT (getdate()) FOR [Date]
end
GO
