-- =============================================
-- Create procedure basic template
-- =============================================
-- creating the store procedure
-- 25Aug12 TH Updated with 10.9 fields

IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8WOrderInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8WOrderInsert
GO

CREATE PROCEDURE pV8WOrderInsert 
	(

			@sessionid				integer
		,	@locationid_site		integer
		,	@revisionlevel			varchar(2)
		,	@code						varchar(7)
		,	@outstanding			varchar(13)
		,	@orddate					varchar(8)
		,	@ordtime					varchar(6)
		,	@loccode					varchar(3)
		,	@supcode					varchar(5)
		,	@status					varchar(1)
		,	@numprefix				varchar(6)
		,	@num						varchar(4)
		,	@cost						varchar(13)
		,	@pickno					integer
		,	@received				varchar(13)
		,	@recdate					varchar(8)
		,	@rectime					varchar(6)
		,	@invnum					varchar(12)
		,	@paydate					varchar(8)
		,	@qtyordered				varchar(13)
		,	@urgency					varchar(1)
		,	@tofollow				varchar(1)
		,	@internalsiteno		varchar(3)
		,	@internalmethod		varchar(1)
		,	@suppliertype			varchar(1)
		,	@convfact				varchar(5)
		,	@issueunits				varchar(5)
		,	@stocked					varchar(1)
		,	@description			varchar(56)
		,	@pflag					varchar(1)
		,	@createduser			varchar(3)
		,	@custordno				varchar(12)
		,	@vatamount				varchar(13)
		,	@vatratecode			varchar(1)
		,	@vatratepct				varchar(13)
		,	@vatinclusive			varchar(13)
		,	@indispute				varchar(1)
		,	@indisputeuser			varchar(3)
		,	@shelfprinted			varchar(1)
		,	@worderid				integer		OUTPUT
	)
AS
	begin

		declare	@_reconciledate		varchar(7)

		exec pWOrderInsert	@sessionid,
									@locationid_site,
									@code,
									@convfact,
									@cost,
									@createduser,
									@custordno,
									@description,
									@indispute,
									@indisputeuser,
									@internalmethod,
									@internalsiteno,
									@invnum,
									@issueunits,
									@loccode,
									@num,
									@numprefix,
									@orddate,
									@ordtime,
									@outstanding,
									@paydate,
									@pflag,
									@pickno,
									@qtyordered,
									@recdate,
									@received,
									@_reconciledate,
									@rectime,
									@revisionlevel,
									@shelfprinted,
									@status,
									@stocked,
									@supcode,
									@suppliertype,
									@tofollow,
									@urgency,
									@vatamount,
									@vatinclusive,
									@vatratecode,
									@vatratepct,
									NULL,           --CodingSlipDate
									'',		--Deliver Note Reference
									0,		--DLO
									'',		--DLO Ward
									0,		--PSO RequestID 3Sept13 XN 72436
									null,	-- EDIProductIdentifier
									@worderid		OUTPUT
									
	end
GO
