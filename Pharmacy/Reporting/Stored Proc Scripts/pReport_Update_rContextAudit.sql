-- =======================================================================================================
-- Author:			Simon Tipper
-- Create date:		02Oct16
-- Ref:				128799
-- Description:		Added ContextAudit to reporting db
-- =======================================================================================================

IF OBJECT_ID('pReport_Update_rContextAudit') IS NOT NULL
	DROP PROCEDURE pReport_Update_rContextAudit
GO


CREATE PROCEDURE pReport_Update_rContextAudit
AS
Begin
    DECLARE @LiveDB VARCHAR(max)
    DECLARE @sql    varchar(max)
	
    PRINT 'pReport_Update_rContextAudit'
    
    --Get the live database name from the rDatabase table
    SET @LiveDB = (SELECT DATABASE_NAME FROM rDatabase WHERE DATABASE_TYPE = 'LIVE')
    
    TRUNCATE TABLE rContextAudit
    
    SET @sql = '
				DECLARE @PPI_ID	int
				DECLARE @CASENUM_ID int
				DECLARE @EntityRoleID_Consultant int
	
				SELECT	@PPI_ID = AliasGroupID
				FROM	' + @LiveDB + '.icwsys.AliasGroup 
				WHERE	[Description] = (	SELECT	Value
									FROM		' + @LiveDB + '.icwsys.Setting
									WHERE		[System] = ''General'' 
									AND	Section = ''PatientEditor'' 
									AND	[Key] = ''PrimaryPatientIdentifier'' 
									AND	RoleID = 0
                            )

				SELECT 	@CASENUM_ID = AliasGroupID
				FROM	' + @LiveDB + '.icwsys.AliasGroup
				WHERE	[Description] = ''CaseNumber''
							
				SELECT	@EntityRoleID_Consultant = EntityRoleID  
				FROM	' + @LiveDB + '.icwsys.EntityRole 
				WHERE	[Description] = ''consultant''

				INSERT INTO rContextAudit (
					[ContextAuditID],
					[Username],
					[AuditDate],
					[Terminal],
					[Forename],
					[Surname],
					[DateOfBirth],
					[PrimaryIdentifier],
					[HospitalNumber],
					[EpisodeDescription],
					[EpisodeLocation],
					[EpisodeConsultant],
					[Desktop])

                SELECT
					ca.ContextAuditID			AS [ContextAuditID],
					u.Username					AS [Username],
					ca.DateAccessed				AS [AuditDate],
					t.ComputerName				AS [Terminal],
					per.Forename				AS [Forename],
					per.Surname					AS [Surname],
					p.DOB						AS [DateOfBirth],
					ppi.Alias					AS [PrimaryIdentifier],
					cn.Alias					AS [HospitalNumber],
					e.[Description]				AS [EpisodeDescription],
					l.[Description]				AS [EpisodeLocation],
					cons.[Description]			AS [EpisodeConsultant],
					d.[Description]				AS [Desktop]
				FROM ' + @LiveDB + '.icwsys.ContextAudit ca
					LEFT JOIN ' + @LiveDB + '.icwsys.[User]	u ON ca.EntityID_User = u.EntityID
					LEFT JOIN ' + @LiveDB + '.icwsys.Terminal t ON ca.LocationID_Terminal = t.LocationID
					LEFT JOIN ' + @LiveDB + '.icwsys.Episode  e ON ca.EpisodeID = e.EpisodeID
					LEFT JOIN ' + @LiveDB + '.icwsys.Desktop  d ON ca.DesktopID = d.DesktopID

					OUTER APPlY (SELECT TOP 1 c.[Description] 
								 FROM ' + @LiveDB + '.icwsys.ResponsibleEpisodeEntity ree 
							     JOIN ' + @LiveDB + '.icwsys.Entity c on ree.EntityID = c.EntityID 
    						     WHERE e.EpisodeID		= ree.EpisodeID AND 
									   ree.[Active]		= 1				AND
									   ree.EntityRoleID = @EntityRoleID_Consultant
							     ORDER BY ree.EntityID desc) cons
					
					OUTER APPlY (SELECT TOP 1 loc.[Description] 
								 FROM ' + @LiveDB + '.icwsys.EpisodeLocation el 
							     JOIN ' + @LiveDB + '.icwsys.Location loc on el.LocationID = loc.LocationID 
    						     WHERE e.EpisodeID = el.EpisodeID AND 
									   el.[Active] = 1
							     ORDER BY loc.LocationID desc) l

					JOIN ' + @LiveDB + '.icwsys.Patient p						ON e.EntityID = p.EntityID
					JOIN ' + @LiveDB + '.icwsys.Person per					ON p.EntityID = per.EntityID

					OUTER APPlY(SELECT TOP 1 ea_ppi.Alias FROM ' + @LiveDB + '.icwsys.EntityAlias ea_ppi 
								WHERE ea_ppi.EntityID	  = e.EntityID AND 
									  ea_ppi.AliasGroupID = @PPI_ID    AND 
									  ea_ppi.[Default]	  = 1
							    ORDER BY ea_ppi.EntityAliasID desc) ppi

					OUTER APPlY(SELECT TOP 1 ea_cn.Alias FROM ' + @LiveDB + '.icwsys.EntityAlias ea_cn 
								WHERE ea_cn.EntityID	 = e.EntityID  AND 
									  ea_cn.AliasGroupID = @CASENUM_ID AND 
									  ea_cn.[Default]    = 1
							    ORDER BY ea_cn.EntityAliasID desc) cn'
	--PRINT @sql			
	EXECUTE (@sql)
    PRINT ''    
END
GO
