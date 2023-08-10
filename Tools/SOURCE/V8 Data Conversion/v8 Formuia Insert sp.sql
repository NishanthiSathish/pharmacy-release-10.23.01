-- =============================================
-- Create procedure basic template
-- =============================================
-- 25Dec13 TH Added new QAQty and Bond Store fields (TFS 80740)
-- creating the store procedure
IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8FormulaInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8FormulaInsert 
GO

CREATE PROCEDURE pV8FormulaInsert 
	(
			@sessionid				integer
		,	@locationid_site		integer
		,	@id						integer
		,	@authorised2			varchar(5)
		,	@layout2				varchar(10)
		,	@nsvcode				varchar(15)
		,	@code1					varchar(7)
		,	@code2					varchar(7)
		,	@code3					varchar(7)
		,	@code4					varchar(7)
		,	@code5					varchar(7)
		,	@code6					varchar(7)
		,	@code7					varchar(7)
		,	@code8					varchar(7)
		,	@code9					varchar(7)
		,	@code10					varchar(7)
		,	@code11					varchar(7)
		,	@code12					varchar(7)
		,	@code13					varchar(7)
		,	@code14					varchar(7)
		,	@code15					varchar(7)
		,	@qty1					float
		,	@qty2					float
		,	@qty3					float
		,	@qty4					float
		,	@qty5					float
		,	@qty6					float
		,	@qty7					float
		,	@qty8					float
		,	@qty9					float
		,	@qty10					float
		,	@qty11					float
		,	@qty12					float
		,	@qty13					float
		,	@qty14					float
		,	@qty15					float
		,	@type1					varchar(1)
		,	@type2					varchar(1)
		,	@type3					varchar(1)
		,	@type4					varchar(1)
		,	@type5					varchar(1)
		,	@type6					varchar(1)
		,	@type7					varchar(1)
		,	@type8					varchar(1)
		,	@type9					varchar(1)
		,	@type10					varchar(1)
		,	@type11					varchar(1)
		,	@type12					varchar(1)
		,	@type13					varchar(1)
		,	@type14					varchar(1)
		,	@type15					varchar(1)
		,	@method					varchar(1024)
		,	@totalqty				float
		,	@numoflabels			integer
		,	@label					varchar(5000)
		,	@extralabels			integer
		,	@dosingunits			bit
		,	@d1						varchar(60)
		,	@d2						varchar(60)
		,	@d3						varchar(60)
		,	@d4						varchar(60)
		,	@d5						varchar(60)
		,	@d6						varchar(60)
		,	@d7						varchar(60)
		,	@d8						varchar(60)
		,	@d9						varchar(60)
		,	@d10					varchar(60)
		,	@d11					varchar(60)
		,	@d12					varchar(60)
		,	@d13					varchar(60)
		,	@d14					varchar(60)
		,	@d15					varchar(60)
		,	@authorised				varchar(5)
		,	@authorised_date		datetime
		,	@layout					varchar(10)
		,	@wformulaid				integer		OUTPUT
	)
AS
	begin

		IF NOT(EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pWFormulaInsert' AND sc.name = '@WManufacturingStatusCode'))
			exec pWFormulaInsert	@sessionid,
									@locationid_site,
									@authorised2,
									@layout2,
									@nsvcode,
									@code1,					
									@code2,					
									@code3,					
									@code4,					
									@code5,					
									@code6,					
									@code7,					
									@code8,					
									@code9,					
									@code10,					
									@code11,				
									@code12,					
									@code13,					
									@code14,					
									@code15,					
									@qty1,					
									@qty2,					
									@qty3,					
									@qty4,					
									@qty5,					
									@qty6,					
									@qty7,					
									@qty8,					
									@qty9,					
									@qty10,					
									@qty11,					
									@qty12,					
									@qty13,					
									@qty14,					
									@qty15,					
									@type1,
									@type2,
									@type3,
									@type4,
									@type5,
									@type6,
									@type7,
									@type8,
									@type9,
									@type10,
									@type11,
									@type12,
									@type13,
									@type14,
									@type15,
									@method,
									@totalqty,				
									@numoflabels,
									@label,
									@extralabels,
									@dosingunits,
									@d1,
									@d2,
									@d3,
									@d4,
									@d5,
									@d6,
									@d7,
									@d8,
									@d9,
									@d10,
									@d11,
									@d12,
									@d13,
									@d14,
									@d15,
									@authorised,
									@authorised_date,
									@layout,
									@wformulaid	OUTPUT

		IF EXISTS(SELECT * FROM sysobjects so JOIN syscolumns sc ON so.id = sc.id WHERE so.name = 'pWFormulaInsert' AND sc.name = '@WManufacturingStatusCode')
			exec pWFormulaInsert	@sessionid,
									@locationid_site,
									@authorised2,
									@layout2,
									@nsvcode,
									@code1,					
									@code2,					
									@code3,					
									@code4,					
									@code5,					
									@code6,					
									@code7,					
									@code8,					
									@code9,					
									@code10,					
									@code11,				
									@code12,					
									@code13,					
									@code14,					
									@code15,					
									@qty1,					
									@qty2,					
									@qty3,					
									@qty4,					
									@qty5,					
									@qty6,					
									@qty7,					
									@qty8,					
									@qty9,					
									@qty10,					
									@qty11,					
									@qty12,					
									@qty13,					
									@qty14,					
									@qty15,					
									@type1,
									@type2,
									@type3,
									@type4,
									@type5,
									@type6,
									@type7,
									@type8,
									@type9,
									@type10,
									@type11,
									@type12,
									@type13,
									@type14,
									@type15,
									@method,
									@totalqty,				
									@numoflabels,
									@label,
									@extralabels,
									@dosingunits,
									@d1,
									@d2,
									@d3,
									@d4,
									@d5,
									@d6,
									@d7,
									@d8,
									@d9,
									@d10,
									@d11,
									@d12,
									@d13,
									@d14,
									@d15,
									@authorised,
									@authorised_date,
									@layout,
									'L',
									0,
									0,
									NULL,
									NULL,
									0,
									0,
									0,
									@wformulaid	OUTPUT
	end 
GO