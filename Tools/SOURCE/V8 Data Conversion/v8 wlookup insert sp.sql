IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8WLookupInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8WLookupInsert
GO

Create Procedure [pV8WLookupInsert]
	(
			@CurrentSessionID        int
		,	@LocationID_Site	int
		,	@WLookUpContextID	int
		,	@Code varchar(10)
		,	@Value varchar(1024)
		,	@InUse  bit
		,	@WLookupID int OUTPUT
	)
	as

begin
    -- XN 71349 14Aug13 if wlookup exists and is only updatable by dss the don't update 
    SELECT TOP 1 @WLookupID = WLookupID FROM WLookup WHERE Code=@code AND WLookupContextID=@WLookUpContextID AND SiteID=@locationid_site AND DSS=1
    if @WLookupID IS NOT NULL
    BEGIN
         RETURN
    END
    
    Exec pWLookupInsert @CurrentSessionID, @LocationID_Site, @WLookUpContextID, @Code, @Value, @InUse, @WLookupID OUTPUT 
end