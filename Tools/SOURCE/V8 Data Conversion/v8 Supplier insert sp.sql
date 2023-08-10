--27Apr07 EAC removed pWard field from pWardInsert call in line with V9.8 SQL patch.
--18Oct07 EAC modified so that it won't re-import suppliers that have already been processed.
--            Also, modified so that only one entry is created in the ward table even if the 
--            ward occurs in more than one supplier file being converted.
--07Nov12 TH WardGroupID added (TFS 48081)
--12Nov14 XN 103883 Due to the updates to the supplier, and wards the conversion process has been changed
--		     First the data is read into the WSupplier_Old, and then pWSupplierConvert is called into add it to new WCustomer, WSupplier2, and WWardProductList tables


IF EXISTS (SELECT name 
	   FROM   sysobjects 
	   WHERE  name = N'pV8SupplierInsert' 
	   AND 	  type = 'P')
    DROP PROCEDURE pV8SupplierInsert
GO

create procedure [pV8SupplierInsert] 
(

		@sessionid				integer
	,	@locationid_site		integer
	,	@locationid_parent		integer
	,	@code					varchar(5)
	,	@contractaddress		varchar(100)
	,	@supaddress				varchar(100)
	,	@invaddress				varchar(100)
	,	@conttelno				varchar(14)
	,	@suptelno				varchar(14)
	,	@invtelno				varchar(14)
	,	@discountdesc			varchar(70)
	,	@discountval			varchar(9)
	,	@method					varchar(1)
	,	@ordmessage				varchar(50)
	,	@avleadtime				varchar(4)
	,	@contfaxno				varchar(14)
	,	@supfaxno				varchar(14)
	,	@invfaxno				varchar(13)
	,	@name					varchar(15)
	,	@ptn					varchar(1)
	,	@psis					varchar(1)
	,	@fullname				varchar(35)
	,	@discountbelow			varchar(4)
	,	@discountabove			varchar(4)
	,	@icode					varchar(8)
	,	@costcentre				varchar(15)
	,	@printdelnote			varchar(1)
	,	@printpickticket		varchar(1)
	,	@suppliertype			varchar(1)
	,	@orderoutput			varchar(1)
	,	@receivegoods			varchar(1)
	,	@topupinterval			varchar(2)
	,	@atcsupplied			varchar(1)
	,	@topupdate				varchar(8)
	,	@inuse					varchar(1)
	,	@wardcode				varchar(5)
	,	@oncost					varchar(3)
	,	@inpatientdirections	varchar(1)
	,	@adhocdelnote			varchar(1)
	,	@wsupplierid			integer	OUTPUT
)

AS

	BEGIN

		declare @_aliasgroupid			int
		declare @_inuse 				bit
		declare @_locationaliasid 		int
		declare @_locationid 			int
		declare @_locationtypeid 		int
		declare @_minimumordervalue 	float
		declare @_outofuse 				bit
		declare @_success 				bit
		declare @_tableid 				int
		declare @_wardtypeid 			int

		set @_outofuse = 0
		set @_inuse = 1
		set @_success = 1

		if upper(@inuse) = 'N'
		begin
			set @_outofuse = 1
			set @_inuse = 0
		end 

		if upper(@suppliertype) = 'W'
		begin

			select @_locationtypeid = locationtypeid, @_tableid = tableid
			from locationtype
			where [description] = 'ward'

			select @_wardtypeid = wardtypeid 
			from [wardtype] 
			where [description] = 'Unspecified'

			select @_aliasgroupid = aliasgroupid 
			from aliasgroup
			where [Description] = 'WWardCodes'
		end

		select @wsupplierid = WSupplierID
		from WSupplier_Old
		where SiteID = @locationid_site
		and Code = @Code

		begin transaction

		if (@wsupplierid is null)
		begin
/*		103883 	
					exec pWSupplierInsert	@sessionid,
											@locationid_site,
											@code,
											@contractaddress,
											@supaddress,
											@invaddress,
											@conttelno,
											@suptelno,
											@invtelno,
											@discountdesc,
											@discountval,
											@method,
											@ordmessage,
											@avleadtime,
											@contfaxno,
											@supfaxno,
											@invfaxno,
											@name,
											@ptn,
											@psis,
											@fullname,
											@discountbelow,
											@discountabove,
											@icode,
											@costcentre,
											@printdelnote,
											@printpickticket,
											@suppliertype,
											@orderoutput,
											@receivegoods,
											@topupinterval,
											@atcsupplied,
											@topupdate,
											@_inuse,
											@wardcode,
											@oncost,
											@inpatientdirections,
											@adhocdelnote,
											@_minimumordervalue,
											'', -- Lead Time  3Sept13 XN 72436
											0,  -- PSO        3Sept13 XN 72436
											@wsupplierid OUTPUT 
											*/

           Insert into [WSupplier_Old] (   [code], 
                                           [contractaddress], 
                                           [supaddress], 
                                           [invaddress], 
                                           [conttelno], 
                                           [suptelno], 
                                           [invtelno], 
                                           [discountdesc], 
                                           [discountval], 
                                           [method], 
                                           [ordmessage], 
                                           [avleadtime], 
                                           [contfaxno], 
                                           [supfaxno], 
                                           [invfaxno], 
                                           [name], 
                                           [ptn], 
                                           [psis], 
                                           [fullname], 
                                           [discountbelow],
                                           [discountabove], 
                                           [icode], 
                                           [costcentre], 
                                           [PrintDeliveryNote], 
                                           [PrintPickTicket], 
                                           [suppliertype], 
                                           [OrderOutput], 
                                           [ReceiveGoods], 
                                           [TopupInterval], 
                                           [ATCSupplied], 
                                           [topupdate],
                                           [inuse],
                                           [wardcode],
                                           [oncost],
                                           [InPatientDirections],
                                           [AdHocDelNote],
                                           [SiteID],
                                           [MinimumOrderValue], 
                                           [LeadTime], 
                                           [PSO]) 
           values ( @code, 
                    @contractaddress, 
                    @supaddress, 
                    @invaddress, 
                    @conttelno, 
                    @suptelno, 
                    @invtelno, 
                    @discountdesc, 
			        @discountval, 
			        @method, 
			        @ordmessage, 
			        @avleadtime, 
			        @contfaxno, 
			        @supfaxno, 
			        @invfaxno, 
			        @name, 
			        @ptn, 
			        @psis, 
			        @fullname, 
			        @discountbelow, 
			        @discountabove, 
			        @icode, 
			        @costcentre, 
			        @printdelnote, 
			        @PrintPickTicket, 
			        @suppliertype, 
			        @OrderOutput, 
			        @ReceiveGoods, 
			        @TopupInterval, 
			        @ATCSupplied, 
			        @topupdate,
			        @_inuse,
			        @wardcode,
			        @onCost, 
			        @InPatientDirections, 
			        @AdHocDelNote, 
			        @locationid_site,
			        @_minimumordervalue, 
				    '', -- Lead Time  3Sept13 XN 72436
				    0   -- PSO        3Sept13 XN 72436
                    )

            Set @WSupplierID = scope_identity()		
		
			if (@@error <> 0) set @_success = 0

			
			if upper(@suppliertype) = 'W'
			begin

				set @code = ltrim(rtrim(@code))

				select @_locationid = LocationID from LocationAlias
				where AliasGroupID = @_aliasgroupid
				and Alias = @code

				if (@_locationid is null)
				begin
					/*exec pWardInsert	@sessionid,
										@locationid_parent,
										@_locationtypeid,
										@_tableid,
										@name,
										@fullname,
										0,                                      --ADAutoLogin
										@_wardtypeid, 
										0,					-- male
										0,					-- female
										0,					-- single rooms
										@_outofuse,
										0,                  -- 07Nov12 TH WardGroupID added
										@_locationid OUTPUT   XN 13Nov14 84304 fix issue with wards not importing  */
	                exec [pLocationInsert] @sessionid, @locationid_parent, @_locationtypeid, @_tableid, @name, @fullname, 0, @_locationid OUTPUT

	                Insert into [Ward] ( [LocationID], [WardTypeID], [Male], [Female], [SingleRooms], [out_of_use], [WardGroupID] ) 
	                    values ( @_locationid, @_wardtypeid, 0, 0, 0, @_outofuse, 0 )
										
					if (@@error <> 0) set @_success = 0

					exec pLocationAliasInsert	@sessionid,
														@_locationid,
														@_aliasgroupid,
														@code,
														1,
														@_locationaliasid
					
					if (@@error <> 0) set @_success = 0
				end
			end
		end

		if (@_success = 1)
			commit transaction
		else
			begin
				rollback transaction
				set @wsupplierid = NULL
			end

	END

GO
