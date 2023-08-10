-- =============================================
-- Create procedure basic template
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8WLabelInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8WLabelInsert
GO

CREATE PROCEDURE pV8WLabelInsert 
	(
			@sessionid						integer
		,	@locationid_site				integer
		,	@dircode 						varchar(12)
		,	@route							varchar(4)
		,	@equalinterval					float
		,	@timeunits						varchar(3)
		,	@repeatinterval				integer
		,	@repeatunits					varchar(3)
		,	@abstime							varchar(1)
		,	@days								varchar(1)
		,	@baseprescriptionid			integer
		,	@dose1							float
		,  @dose2							float
		,	@dose3							float
		,	@dose4							float
		,	@dose5							float
		,	@dose6							float
		,	@time1							varchar(4)
		,	@time2							varchar(4)
		,	@time3							varchar(4)
		,	@time4							varchar(4)
		,	@time5							varchar(4)
		,	@time6							varchar(4)
		, 	@flags							varchar(1)
		,	@prescriptionid				integer
		,	@reconvol						float
		,	@container						varchar(1)
		,	@reconabbr						varchar(3)
		,	@diluentabbr					varchar(3)
		,	@finalvolume					float
		,	@drdirection					varchar(105)
		,	@containersize					integer
		,	@infusiontime					integer
		,	@prn								varchar(1)
		,	@patid							varchar(10)
		,	@siscode							varchar(7)
		,	@text								varchar(180)
		,	@startdate						datetime
		,	@stopdate						datetime
		,	@isstype							varchar(1)
		,	@lastqty							float
		,	@lastdate						datetime
		,	@topupqty						float
		,	@dispid							varchar(3)
		,	@prescriberid					varchar(3)
		,  @pharmacistid					varchar(3)
		,	@stoppedby						varchar(3)
		,	@rxstatus						varchar(1)
		,	@needednexttime				varchar(1)
		,	@rxstartdate					datetime
		,	@nodissued						float
		,	@batchnumber					integer
		,	@extraflags						varchar(1)
		,	@deletedate						datetime
		,	@rxnodissued					float
		,	@filename						varchar(6)
		,	@fileposition					integer
		,	@wlabelhistoryid				integer		OUTPUT
	)
AS
	BEGIN

		declare @_blister						bit
		declare @_day1mon						bit
		declare @_day2tue						bit
		declare @_day3wed						bit
		declare @_day4thu						bit
		declare @_day5fri						bit
		declare @_day6sat						bit
		declare @_day7sun						bit
		declare @_hasrxnotes					bit
		declare @_ishistory					bit
		declare @_manualquantity			bit
		declare @_patientsown				bit
		declare @_prn							bit
		declare @_pyxisitem					bit
		declare @_rinnflag					bit
		declare @_revisedwarninstruct		bit

		declare @_episodeid					int

		declare @_revisedinstruction		varchar(12)
		declare @_revisedwarning			varchar(12)

		set @_day1mon = 0
		set @_day2tue = 0
		set @_day3wed = 0
		set @_day4thu = 0
		set @_day5fri = 0
		set @_day6sat = 0
		set @_day7sun = 0

		select @_episodeid = [episode].[episodeid]
		from [episode]
		join [v8patientconversion] on [v8patientconversion].[entityid] = [episode].[entityid]
		where [episode].[episodeid_parent] = 0
		and	[v8patientconversion].[recno] = @patid
		and	[v8patientconversion].[locationid_site] = @locationid_site

		if @_episodeid is null 
			set @_episodeid = 0

		if ((not(@days is null)) and (@days <> ' ') and (@days <> ''))
			begin
				if (ascii(@days) & 2 = 2)		set @_day1mon = 1
				if (ascii(@days) & 4 = 4)		set @_day2tue = 1 
				if (ascii(@days) & 8 = 8)		set @_day3wed = 1
				if (ascii(@days) & 16 = 16)	set @_day4thu = 1 
				if (ascii(@days) & 32 = 32)	set @_day5fri = 1
				if (ascii(@days) & 64 = 64)	set @_day6sat = 1
				if (ascii(@days) & 128 = 128)	set @_day7sun = 1
			end

		set @_hasrxnotes = 0
		set @_ishistory = 0
		set @_manualquantity = 0
		set @_patientsown = 0
		set @_prn = 0
		set @_pyxisitem = 0
		set @_revisedwarninstruct = 0
		set @_rinnflag = 0
		set @_blister = 0

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

		if ((not(@extraflags is null)) and (@extraflags <> ' ') and (@extraflags <> ''))
			begin
				if (ascii(@extraflags) & 1 = 1)	set @_rinnflag = 1
				if (ascii(@extraflags) & 2 = 2)	set @_pyxisitem = 1
			end 

		if (@_revisedwarninstruct = 1)
			begin
				set @_revisedinstruction = right(@dircode, 6)
				set @_revisedwarning = left(@dircode, 6)
				set @dircode = ''
			end 

		if (@stopdate > 0) set @_ishistory = 1

		if (@baseprescriptionid = 538976288) set @baseprescriptionid = 0

		exec pV8ConvWlabelInsert	@sessionid,
											@_episodeid,
											@locationid_site,
											@dircode,
											@route,
											@repeatinterval,
											@repeatunits,
											@baseprescriptionid,
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
											@prescriptionid,
											@reconvol,
											@container,
											@reconabbr,
											@diluentabbr,
											@finalvolume,
											@drdirection,
											@containersize,
											@infusiontime,
											@patid,
											@siscode,
											@text,
											@startdate,
											@stopdate,
											@isstype,
											@lastqty,
											@lastdate,
											@topupqty,
											@dispid,
											@prescriberid,
											@pharmacistid,
											@stoppedby,
											@needednexttime,
											@rxstartdate,
											@nodissued,
											@batchnumber,
											@deletedate,
											@rxnodissued,
											@_ishistory,
											@_day1mon,
											@_day2tue,
											@_day3wed,
											@_day4thu,
											@_day5fri,
											@_day6sat,
											@_day7sun,
											@_hasrxnotes,
											@_patientsown, 
											@_prn,
											@_manualquantity,
											@_rinnflag,
											@_pyxisitem,
											@_blister,
											@_revisedinstruction,
											@_revisedwarning,
											@filename,
											@fileposition,
											@wlabelhistoryid OUTPUT
							
	END

GO

