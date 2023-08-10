--06Jan16 TH TFS 138679 Site specific patch for CPFT to ensure NHS number is not formatted (and hence truncated) for repeat dispensing labels)

exec pDrop 'pEpisodeSelect'
GO


create PROCEDURE [pEpisodeSelect]
(
		@CurrentSessionID int
	,	@EpisodeID        int
	,   @SiteID           int
)
AS
BEGIN
	--Changes made to allow episode selection without a consultant being present
	--This could do with "tightening" in future and some mods to Episode panel to 
	--force patient demographic record capturing
	--17Nov05 CKJ Added prefix of 'Episode' to StartDate EndDate and DateCreated

	--15Dec05 RA Added a where clause to supress selection of rows with none "wardcode" alias groups
	--31Jan06 TH Added specialty so that we have something to write into the log
	--26Oct08 TH Ensure correct Casenumber is returned
	--03Sep09 PJC Added PatientPaymentCategory Description F0054530
	--21Sep09 PJC Added formatted varchar Start and End dates(F0054530)
	--08Oct09 PJC Added Patient Identifier (old NHS Number)(F0064619)
    --27Jun11 XN  Out of use wards still dispensing (F0089664)
    --26Sep11 TH  Now search ward locations AND clinics (Outpatient Locations) - EPEX Intgration.
    --30Sep11 AJK Removed where clause for Patient care details as logic seems to have been handled by joins
    --07Oct11 AJK Extra changes ensure no dupes are found
    --13Oct11 AJK 17032 Moved all left join related where clauses onto their respective joins so the episode is always returned
    --28Mar12 TH  Format Healthcare number if required and only use the active one (default)
    --13May12 TH  Added unformated HealthcareNumber (for Wtranslog)
    --9Jan12  XN  Optimised a bit!!!! 48747
    --06Jan16 TH Swapped NHS number to unformatted for CPFT Dispensing ocx
    
	declare @PrimaryPatientIdentifier as varchar (128)

	select @PrimaryPatientIdentifier = [value] from  setting where [System]= 'General' and [Section]= 'PatientEditor' and [Key]= 'PrimaryPatientIdentifier' and RoleID=0

		Select 	
			a.[EpisodeID] 
--		,	a.[EpisodeID_Parent] "EpisodeID_Parent"         9Jan12 XN  Removed as part of Optimisation 48747
--		,	a.[StatusID] "StatusID"                         9Jan12 XN  Removed as part of Optimisation 48747
		,	a.[EntityID] "EntityID"
--		,	a.[EpisodeTypeID] "EpisodeTypeID"               9Jan12 XN  Removed as part of Optimisation 48747
		,	b.[Description]	 				"EpisodeTypeDescription"
		,	[icwsys].fEpisodeType(a.EpisodeID)	"EpisodeTypeCode"       -- ********** XN fEpisodeType Could be improved
		,	a.[Description] "EpisodeDescription"
--		,	a.[DateCreated] "EpisodeDateCreated"            9Jan12 XN  Removed as part of Optimisation 48747
--		,	a.[StartDate] "EpisodeStartDate"                9Jan12 XN  Removed as part of Optimisation 48747
--		,	a.[EndDate] "EpisodeEndDate"                    9Jan12 XN  Removed as part of Optimisation 48747
		,	h.alias "CaseNo"                                -- ********** XN Don't think this is formatted properly
		,	c.Description "Consultant"
--		,	c.EntityID "EntityID_Consultant"                9Jan12 XN  Removed as part of Optimisation 48747
--		,	d.alias "ConsultantCode"
		,	con.alias "ConsultantCode"    --07Jan14 TH Replaced above (TFS 80588)
		,	f.alias "WardCode"
		,	(	select Value 
				from fDssLastWeightBySessionKg(@CurrentSessionID)   
			)	"WeightKg"
		,	(	select Value
				from fDssLastHeightBySessionMetre(@CurrentSessionID)    
			) 	"HeightM"
		,	[icwsys].fSpecialtyByEpisodeID(@EpisodeID) "Specialty"      
		,	[Address].[Postcode] "PostCode"
		,	ltrim(rtrim(rtrim(ISNULL([Address].[DoorNumber], '')) + ' ' + ltrim(rtrim(ISNULL([Address].[Building], ''))) + ' ' + ltrim(ISNULL([Address].[street] ,'')))) "Address1" -- 9Jan12 XN  replace fParseNull with ISNULL are removed extra trims Original:'' + ltrim(rtrim(ltrim(rtrim([icwsys].fParseNull([Address].[DoorNumber]))) + ' ' + ltrim(rtrim([icwsys].fParseNull([Address].[Building]))) + ' ' + ltrim(rtrim([icwsys].fParseNull([Address].[street]))))) "Address1"  
		,	ltrim(rtrim(ISNULL([Address].[Town], ''))) "Address2"                                                                                                                   -- 9Jan12 XN  replace fParseNull with ISNULL
		,	ltrim(rtrim(rtrim(ISNULL([Address].[LocalAuthority], '')) + ' ' + ltrim(ISNULL([Address].[District], '')))) "Address3"                                                  -- 9Jan12 XN  replace fParseNull with ISNULL are removed extra trims Original:'' + ltrim(rtrim(ltrim(rtrim([icwsys].fParseNull([Address].[LocalAuthority]))) + ' ' + ltrim(rtrim([icwsys].fParseNull([Address].[District]))))) "Address3" 
		,	ltrim(rtrim(rtrim(ISNULL([Address].[Province], '')) + ' ' + ltrim(ISNULL([Address].[Country], '')))) "Address4"                                                         -- 9Jan12 XN  replace fParseNull with ISNULL are removed extra trims Original:'' + ltrim(rtrim(ltrim(rtrim([icwsys].fParseNull([Address].[Province]))) + ' ' + ltrim(rtrim([icwsys].fParseNull([Address].[Country]))))) "Address4"
		,   ISNULL(l.description, '') "PatientPaymentCategory"		-- 9Jan12 XN  replace fParseNull with ISNULL	--03Sep09 PJC Added (F0054530)
		,	convert(varchar(50), a.[StartDate], 120) "EpisodeStartDateFormatted"	--21Sep09 PJC Added (F0054530)
		,	convert(varchar(50), a.[EndDate], 120) "EpisodeEndDateFormatted"		--21Sep09 PJC Added (F0054530)
		--,	icwsys.fFormatID(o.alias, o.Format) HealthCareNumber												--08Oct09 PJC Added (F0064619)			
		,	o.alias HealthCareNumber
                ,	o.alias HealthCareNumberUnformatted
		,	o.IsValid HealthCareNumberValid											--08Oct09 PJC Added (F0064619)	
		,	o.DisplayName PrimaryPatientIdentifierDisplay							--08Oct09 PJC Added (F0064619)
		,   CASE WHEN (cc.out_of_use=1) Or (c._Deleted  =1) THEN 1 ELSE 0 END	"ConsultantOutOfUse"				-- 14Apr10 XN
		,   CASE WHEN (w.out_of_use =1) Or (loc._Deleted=1) Or (s.InUse = 0) THEN 1 ELSE 0 END	"WardOutOfUse"						-- 27Jun11 XN F0089668
	from 
    	Episode a
    	join EpisodeType b on ( b.EpisodeTypeID = a.EpisodeTypeID )
    	left join Entity c on ( [icwsys].fConsultantByEpisode(a.EpisodeID) = c.EntityID )
    	--left join EntityAlias d on ( c.EntityID = d.EntityID )
		--left join AliasGroup e on ( d.AliasGroupID = e.AliasGroupID )and  e.Description = 'WConsultantCodes'
		--07Jan14 TH Replaced above 2 joins with join below (TFS 80588)   
		left join (select d.entityID,d.alias from entityalias d 
				   join aliasgroup e on d.aliasgroupid = e.aliasgroupid 
    			   where e.description = 'WConsultantCodes' and d.[default] = 1) con on con.entityid = c.entityId                                                                      --******************** XN Should this be a JOIN not a LEFT JOIN
    	left join location loc on ( isnull(([icwsys].fEpisodeLocation(a.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(a.EpisodeID,'Outpatient Location') )) = loc.LocationID )
    	left join LocationAlias f on ( loc.LocationID = f.LocationID ) and f.[default] = 1
		left join AliasGroup g on ( f.AliasGroupID = g.AliasGroupID ) and g.description = 'WWardCodes'          
    	left join EntityAlias h on ( a.EntityID = h.EntityID ) and h.[Default] = 1 join AliasGroup i on ( h.AliasGroupID = i.AliasGroupID ) and i.Description = 'CaseNumber'        --******************** XN Should this be a JOIN not a LEFT JOIN
    	left join EntityLinkAddress on ( [EntityLinkAddress].[EntityID] = a.[EntityID] ) 
    				join Address on (EntityLinkAddress.AddressID = Address.AddressID) 
					join AddressType on (EntityLinkAddress.AddressTypeID = AddressType.AddressTypeID) and AddressType.[description] = 'home'
		left join (
					EpisodeNote j 
					join PatientCareDetails k on k.NoteID = j.NoteID											
				) on a.EpisodeID = j.EpisodeID									
    	left join PatientPaymentCategory l on l.PatientPaymentCategoryID = k.PatientPaymentCategoryID	--03Sep09 PJC Added (F0054530)
        left join  (select y.entityid, y.alias,y.isvalid, z.displayname , z.Format from entityalias y 
    				join aliasgroup z on y.aliasgroupid = z.aliasgroupid where z.description = @PrimaryPatientIdentifier and y.[default] = 1) o on o.entityid = a.entityId --08Oct09 PJC Added (F0064619)                
    	left join Consultant cc on c.EntityID     = cc.EntityID							-- 14April XN
    	left join Ward       w  on loc.LocationID = w.LocationID                        -- 27Jun11 XN F0089668
    	left join WSupplier  s  on (f.alias=s.Code) AND (s.SiteID=@SiteID)              -- 19Jul11 XN F0089668
	where 
		a.EpisodeID = @EpisodeID
END


GO

-- Add to Version Log
INSERT VersionLog ([Type], Description, [Date]) SELECT 'Config', 'TFS 138679.sql', GETDATE()
GO


