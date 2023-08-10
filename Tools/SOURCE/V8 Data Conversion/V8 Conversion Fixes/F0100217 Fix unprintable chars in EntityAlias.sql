/* ------------------------------------------------------------------------------------------------------------------------
Patch to fix problems with v8 upgrades, where EntityAlias table has unprinatble characters which is mean when the patient is 
opened up in the patient editor, the form is blank.

This may fail due to constraint IX_EntityAlias_AliasGroupID_Alias_EntityID, that defines a unique index of 
AliasGroupID, EntityID, and Alias, if it does occur use the following sql to manually sort out the effected rows.

CREATE TABLE #EntityAlias_temp (EntityAliasID int not null, AliasGroupID int not null, EntityID int not null, Alias varchar(255) not null)
                                
declare @charVal int 
set @charVal = 1

while @charVal < 32
begin
    INSERT INTO #EntityAlias_temp
        SELECT EntityAliasID, AliasGroupID, EntityID, Alias, @charVal val FROM EntityAlias WHERE Alias<>REPLACE(Alias, CHAR(@charVal), ' ')
    SET @charVal = @charVal + 1
End

SELECT DISTINCT * FROM #EntityAlias_temp

IF OBJECT_ID('tempDB..#EntityAlias_temp') IS NOT NULL
    DROP TABLE #EntityAlias_temp

Version Log
Version	Date	Name		Comments
1       17Nov10 XN          F0100217 Created
------------------------------------------------------------------------------------------------------------------------ */

-- =======================================================================================================
-- Author:	    XN
-- Create date: 17Nov10
-- Description:	F0100217 - Patient episode details are blank in the episode editor, due to unprintable 
--                         characters in the entity alias table.
--                         The SQL below will replace invalid characters with a space.
--                         This may fail due to constraint IX_EntityAlias_AliasGroupID_Alias_EntityID, that
--                         defines a unique index of AliasGroupID, EntityID, and Alias, but tests at UMMC
--                         show it should be ok.
-- =======================================================================================================
declare @charVal int 
set @charVal = 1

while @charVal < 32
begin
    UPDATE EntityAlias SET Alias=REPLACE(Alias, CHAR(@charVal), ' ') WHERE Alias<>REPLACE(Alias, CHAR(@charVal), ' ')
    set @charVal = @charVal + 1    
End
GO

-- =======================================================================================================
-- F0100217 End
-- =======================================================================================================

--Add to Version Log -
INSERT VersionLog SELECT 'Config', 'F0100217 Fix unprintable chars in EntityAlias.sql v1', getdate()
GO