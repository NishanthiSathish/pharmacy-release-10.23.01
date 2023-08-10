IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8DirectionInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8DirectionInsert
GO

create procedure pV8DirectionInsert
	(
			@sessionid			integer
		,  @locationid_site	integer
		,	@code					varchar(12)
		,	@route				varchar(4)
		,	@equaldose			float
		,	@equalinterval		float
		,	@timeunits			varchar(3)
		,	@repeatinterval	integer
		,	@repeatunits		varchar(3)
		,	@courseinterval	integer
		,	@courseunits		varchar(3)
		,	@abstime				varchar(1)
		,	@days					varchar(1)
		,	@dose1				float
		,	@dose2				float
		,	@dose3				float
		,	@dose4				float
		,	@dose5				float
		,	@dose6				float
		,	@dose7				float
		,	@dose8				float
		,	@dose9				float
		,	@dose10				float
		,	@dose11				float
		,	@dose12				float
		,	@time1				varchar(4)
		,	@time2				varchar(4)
		,	@time3				varchar(4)
		,	@time4				varchar(4)
		,	@time5				varchar(4)
		,	@time6				varchar(4)
		,	@time7				varchar(4)
		,	@time8				varchar(4)
		,	@time9				varchar(4)
		,	@time10				varchar(4)
		,	@time11				varchar(4)
		,	@time12				varchar(4)
		,	@deletedby			varchar(5)
		,  @approvedby			varchar(5)
		,  @revisionno			integer
		,	@deleted				varchar(1)
		,	@location			varchar(4)
		,	@directs				varchar(140)
		,	@prn					varchar(1)
		,	@sortcode			varchar(4)
		,	@dss					integer
		,	@hideprescriber	varchar(1)
		,	@manualqtyentry	varchar(1)
		,	@statdoseflag		varchar(1)
		,  @wdirectionid		integer	OUTPUT
	)
AS
	begin
	    -- XN 14Aug13 71349 if direction exists and is only updatable by dss the don't update 
	    SELECT TOP 1 @wdirectionid = WDirectionID FROM WDirection WHERE LocationID_Site=@locationid_site AND Code=@code AND DSS=1
	    if @wdirectionid IS NOT NULL
	         RETURN

		declare @_day1mon				bit
		declare @_day2tue				bit
		declare @_day3wed				bit
		declare @_day4thu				bit
		declare @_day5fri				bit
		declare @_day6sat				bit
		declare @_day7sun				bit
		declare @_deleted 			bit
		declare @_hideprescriber	bit
		declare @_manualqtyentry	bit 
		declare @_prn 					bit
		declare @_statdoseflag		bit

		set @_day1mon = 0
		set @_day2tue = 0
		set @_day3wed = 0
		set @_day4thu = 0
		set @_day5fri = 0
		set @_day6sat = 0
		set @_day7sun = 0

		set @_deleted = 0 
		set @_hideprescriber = 0
		set @_manualqtyentry = 0
		set @_prn = 0
		set @_statdoseflag = 0

		if (upper(@deleted) = 'Y') set @_deleted = 1
		if (upper(@hideprescriber) = 'Y') set @_hideprescriber = 1
		if (upper(@manualqtyentry) = 'Y') set @_manualqtyentry = 1
		if (upper(@prn) = 'Y') set @_prn = 1
		if (upper(@statdoseflag) = 'Y') set @_statdoseflag = 1

		if ((not(@days is null)) and (ascii(@days) > 0))
			begin
				if (ascii(@days) & 2 = 2)		set @_day1mon = 1
				if (ascii(@days) & 4 = 4)		set @_day2tue = 1 
				if (ascii(@days) & 8 = 8)		set @_day3wed = 1
				if (ascii(@days) & 16 = 16)	set @_day4thu = 1 
				if (ascii(@days) & 32 = 32)	set @_day5fri = 1
				if (ascii(@days) & 64 = 64)	set @_day6sat = 1
				if (ascii(@days) & 128 = 128)	set @_day7sun = 1
			end
		else
			begin
				set @_day1mon = 1
				set @_day2tue = 1 
				set @_day3wed = 1
				set @_day4thu = 1 
				set @_day5fri = 1
				set @_day6sat = 1
				set @_day7sun = 1
			end

		exec pWDirectionInsert	@SessionID, 
										@locationid_site,
										@code,
										@route,
										--@repeatinterval,
										@repeatunits, 
										@courseinterval,
										@courseunits,
										@dose1,
										@dose2,
										@dose3,
										@dose4,
										@dose5,
										@dose6,
										@time1,
										@time2,
										@time3,
										@time4,
										@time5,
										@time6,
										@deletedby,
										@approvedby,
										@_deleted,
										@location,
										@directs,
										@_prn,
										@sortcode,
										@dss,
										@_hideprescriber,
										@_manualqtyentry,
										@_statdoseflag, 
										@_day1mon,
										@_day2tue,
										@_day3wed,
										@_day4thu,
										@_day5fri,
										@_day6sat, 
										@_day7sun,
										@wdirectionid OUTPUT

	end 