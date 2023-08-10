
-- 15Oct09 PJC Created table holds the reporting DB config use with addresses F0066390

IF OBJECT_ID('rReportingConfiguration') IS NULL
	BEGIN
		CREATE TABLE rReportingConfiguration (
						[Key] varchar (30) PRIMARY KEY NOT NULL ,
						[Value] varchar (255) NULL
						)

			INSERT INTO rReportingConfiguration ([Key],	[Value])
								(
									SELECT 'AddressType' [Key],	'Home' [Value]
								)
	END
GO

