IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8ConfigurationInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8ConfigurationInsert
GO

Create Procedure  [pV8ConfigurationInsert] 
	(
			@CurrentSessionID			int
		,	@LocationID_Site 	int
		,	@Category 			varchar(255)
		,	@Section  			varchar(255)
		,	@Key 					varchar(255)
		,	@Value 				varchar(1024)
		,	@WConfigurationID 	int OUTPUT
	)
	as

begin
    declare @DSS bit

	select @WConfigurationID = WConfigurationID, @DSS = DSS from WConfiguration where SiteID = @LocationID_Site and Category = @Category and Section = @Section and [Key] = @Key

    IF @DSS=0 OR @DSS IS NULL   -- XN 14Aug13 71349 if direction exists and is only updatable by dss the don't update 
    begin
	    if (@WConfigurationID IS NULL)
		    begin 
			    exec pWConfigurationInsert @CurrentSessionID, @LocationID_Site, @Category, @Section, @Key, @Value, @WConfigurationID OUTPUT
		    end
	    else
		    begin 
			    exec pWConfigurationUpdate @CurrentSessionID, @WConfigurationID, @LocationID_Site, @Category, @Section, @Key, @Value
		    end
    end
end
GO
