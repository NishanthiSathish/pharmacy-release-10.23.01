-- =============================================
-- Create procedure basic template
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8LayoutInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8LayoutInsert 
GO

CREATE PROCEDURE pV8LayoutInsert 
	(
			@sessionid				int
		,	@locationid_site		int
		,	@id						int
		,	@patientspersheet		int
		,	@layout					varchar(50)
		,	@linetext				varchar(1024)
		,	@inglinetext			varchar(1024)
		,	@prescription			varchar(5000)
		,	@name					varchar(10)	
		,	@wlayoutid				int		OUTPUT
	)
AS
	begin

		IF NOT(EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pWLayoutInsert' AND sc.name = '@WManufacturingStatusCode'))
			exec pWLayoutInsert		@sessionid,
									@locationid_site,
									@patientspersheet,
									@layout,
									@linetext,
									@inglinetext,
									@prescription,
									@name,
									@wlayoutid 		OUTPUT

		IF EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pWLayoutInsert' AND sc.name = '@WManufacturingStatusCode')
			exec pWLayoutInsert		@sessionid,
									@locationid_site,
									@patientspersheet,
									@layout,
									@linetext,
									@inglinetext,
									@prescription,
									@name,
									'L',
									0,
									0,
									NULL,
									NULL,
									0,
									@wlayoutid 		OUTPUT
	end 
GO