drop procedure pV8ConsultantInsert
go

create procedure pV8ConsultantInsert
	(
			@sessionid		int
		,	@code				char(4)
		,	@description	char(30)
		,	@inuse			bit
	)
AS
	BEGIN

		declare @_entityid int
		declare @_entitytypeid int
		declare @_tableid int

		exec pConsultantInsert	@sessionid,
										@_entitytypeid, 
										@_tableid,
										@description,
										'',					-- telephone
										'',					-- fax
										'',					-- email
										'',					-- website
										'',					-- title
										@code,
										'',					-- forename
										'',					-- surname
										'',					-- mobile
										'', 					-- pager
										0,						-- entityID_secretary
										'',					-- specialty
										'',					-- specialty function
										'',					-- GMCCode
										'',					-- Qualification
										@code,
										@_entityid

	END