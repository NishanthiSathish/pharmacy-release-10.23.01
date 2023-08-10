-- 07Apr16 XN 12082 Added pharmacy log insert

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8WPharmacyLogInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8WPharmacyLogInsert
GO

Create Procedure [pV8WPharmacyLogInsert]
	(
			@CurrentSessionID   int
		,	@SiteID	            int
		,	@dateTime	        DateTime
		,   @entityID_User      int
		,   @Terminal           varchar(15)
		,   @Description        varchar(max)
		,   @Detail             varchar(max)
		,   @NSVCode            varchar(7)
		,	@WPharmacyLogID int OUTPUT
	)
	as

begin
	DECLARE @WPharmacyLogTypeID int

	IF NOT EXISTS(SELECT TOP 1 1 FROM WPharmacyLogType WHERE Description=@Description)
		INSERT INTO WPharmacyLogType (Description) VALUES (@Description)
	SET @WPharmacyLogTypeID = (SELECT TOP 1 WPharmacyLogTypeID FROM WPharmacyLogType WHERE Description=@Description)

    INSERT INTO WPharmacyLog ([DateTime], SiteID, EntityID_User, Terminal, WPharmacyLogTypeID, Detail, State, Thread, SessionID, NSVCode)
        VALUES (@dateTime, @SiteID, @entityID_User, @Terminal, @WPharmacyLogTypeID, @Detail, 0, 0, 0, @NSVCode)   
    
     Set @WPharmacyLogID = scope_identity()  
end
GO