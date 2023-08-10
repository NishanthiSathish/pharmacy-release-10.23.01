-- =============================================
-- Create procedure basic template
-- =============================================
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8MediateArchiveInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8MediateArchiveInsert 
GO

CREATE PROCEDURE pV8MediateArchiveInsert 
	(
			@sessionid				integer
		,	@locationid_site		integer
		,	@orderno				varchar(16)
		,	@opcode					varchar(13)
		,	@linkcode				varchar(8)
		,	@localcode				varchar(22)
		,   @paydate				varchar(8)
		,	@invoiceno				varchar(20)
		,	@pwoqty					real
		,	@pwocontractno			varchar(16)
		,	@pwoqtyrateapplies		varchar(1)
		,	@pwolineexvat			real
		,	@pwovatcode				varchar(1)
		,	@pwovatamount			real
		,	@pwolineincvat			real
		,	@invqty					real
		,	@invcontractno			varchar(35)
		,	@invlinetotal			real
		,	@invvatamount			real
		,	@invlineexvat			real
		,	@invvatcode				varchar(1)
		,	@ascissueprice			varchar(9)
		,	@ascpricelastpaid		varchar(9)
		,	@asccontractprice		varchar(9)
		,	@ascpricelastreconciled	varchar(9)
		,	@asccontractnumber		varchar(10)
		,	@errorcode				varchar(3)
		,	@statusflag				varchar(1)
		,	@datelastmodified		varchar(10)
		,	@wmediatearchiveid		integer		OUTPUT
	)
AS
	begin

		exec pWMediateArchiveInsert	@sessionid,
									@locationid_site,
									@orderno,
									@opcode,
									@linkcode,
									@localcode,
									@paydate,
									@invoiceno,
									@pwoqty,
									@pwocontractno,
									@pwoqtyrateapplies,
									@pwolineexvat,
									@pwovatcode,
									@pwovatamount,
									@pwolineincvat,
									@invqty,
									@invcontractno,
									@invlinetotal,
									@invvatamount,
									@invlineexvat,
									@invvatcode,
									@ascissueprice,
									@ascpricelastpaid,
									@asccontractprice,
									@ascpricelastreconciled,
									@asccontractnumber,
									@errorcode,
									@statusflag,
									@datelastmodified,
									@wmediatearchiveid 		OUTPUT
	end 
GO