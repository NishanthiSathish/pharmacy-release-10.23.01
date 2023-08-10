-- =============================================
-- Create procedure basic template
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8ConvSiteInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8ConvSiteInsert
GO

CREATE PROCEDURE pV8ConvSiteInsert 
	(
			@sessionid 			integer
		,	@sitenumber			integer
		,  @locationid_site	integer OUTPUT
	)
AS

	begin
		
		select @locationid_site = locationid
		from site
		where sitenumber = @sitenumber

		if (@locationid_site is null)
			begin

				declare @_locationtypeid 	integer
				declare @_tableid				integer
				declare @_description		varchar(128)
				declare @_detail				varchar(1024)

				select @_locationtypeid = LocationTypeID,
                   @_tableid = TableID
				from LocationType
				where [Description] = 'V93Pharmacy'

				exec psiteinsert	@sessionid,
										0,
										@_locationtypeid,
										@_tableid, 
										@_description, 
										@_detail,
										0,          -- XN 22Aug13 71687 pSiteInsert has changed
										@sitenumber,
										@locationid_site OUTPUT
			end 

	end
GO
