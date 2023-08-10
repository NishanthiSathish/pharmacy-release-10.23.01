
exec pDrop 'pPSO_ORDER_PANEL'
GO



create Procedure [pPSO_ORDER_PANEL]
	(
			@CurrentSessionID int 
		,	@DispensingID  int
	)
	as
Begin

	declare @thing varchar(5)
	declare @SupName varchar(15)
	declare @ordnumber  varchar(10)
	declare @PSOInfoText  varchar(50)
	

	--if (((select COUNT(*) from WOrder where PSORequestID=@DispensingID and Status = 'D' ) > 0 ) and ((select COUNT(*) from WReconcil where PSORequestID=@DispensingID and Status = 'D' ) > 0 ))
	if ((select COUNT(*) from WOrder where PSORequestID=@DispensingID and Status = 'D' ) > 0 ) 
	begin
	
	select   top 1 @thing= supcode ,@SupName = name ,@ordnumber =num from WOrder 
	join Wsupplier on Wsupplier.SiteID = WOrder.SiteID and WSupplier.Code = WOrder.Supcode where WOrder.PSORequestID = @DispensingID
	
	select
		@PSOInfoText =  '' + PSOText
		
	from wPatientSpecificOrder
	where
	wPatientSpecificOrder.PSO_RequestID=@DispensingID	
	
	select
		isnull(@PSOInfoText,'') Special_Instructions ,
		@ordnumber Order_Number,
		@thing Supplier_Code,
		@SupName Supplier_Name,
		'' as Order_Cancelled
		
	from wPatientSpecificOrder
	where
	wPatientSpecificOrder.PSO_RequestID=@DispensingID	
	For XML raw
	end
	else
	begin
	if ((select COUNT(*) from WOrder where PSORequestID=@DispensingID ) > 0 ) 
	  begin
	    select   top 1 @thing= supcode ,@SupName = name ,@ordnumber =num from WOrder 
	    join Wsupplier on Wsupplier.SiteID = WOrder.SiteID and WSupplier.Code = WOrder.Supcode where WOrder.PSORequestID = @DispensingID
	  end
	else
	  begin
	    select   top 1 @thing= supcode ,@SupName = name ,@ordnumber =num from Wreconcil 
	    join Wsupplier on Wsupplier.SiteID = Wreconcil.SiteID and WSupplier.Code = Wreconcil.Supcode where Wreconcil.PSORequestID = @DispensingID
	
	end
	
	declare @Invoiced varchar(10)
	declare @InvNum varchar(20)
	declare @InvDate varchar(10)
	
	select @Invoiced = cast(SUM(case when [Status]<>'4' and [Status]<>'D' then cast(cast(received as DEC(6,2))as float) else 0 end)as varchar(10)) 
	FROM
		WReconcil 
		where 
		WReconcil.PSORequestID = @DispensingID	
	
	declare @DateOrdered varchar(10)
	declare @OrderedBy varchar(3)
	
	if ((select COUNT(*) from WOrder where PSORequestID=@DispensingID ) > 0 ) 
	  begin	
		select   top 1 @DateOrdered = OrdDate  from WOrder 
		where WOrder.PSORequestID = @DispensingID
		and (WOrder.[Status] ='1' or WOrder.[Status] = '3' or WOrder.[Status] = 'R')
		Order by WOrderID desc
	  end
	else
	  begin
	    select   top 1 @DateOrdered = OrdDate  from WReconcil 
		where WReconcil.PSORequestID = @DispensingID
		and (WReconcil.[Status] <>'D' )
		Order by WReconcilID desc
	  end
	
	
	
	declare @DateReceived varchar(10)
	--declare @OrderedBy varchar(3)
	
	select   top 1 @DateReceived= RecDate ,@InvNum =Invnum ,@InvDate =paydate from WReconcil 
	where WReconcil.PSORequestID = @DispensingID
	--and WReconcil.[Status] ='4' removed this as could be invoiced
	
	declare @qtyReceived as varchar(10)
	
	select @qtyReceived = cast(SUM(cast(received as float))as varchar(10)) 
	from WReconcil
	where WReconcil.PSORequestID = @DispensingID			
	and WReconcil.[Status]<>'D'
	
	declare @PSOText varchar(50)
	select   @PSOText= wPatientSpecificOrder.PSOText 
	from wPatientSpecificOrder 
	where wPatientSpecificOrder.PSO_RequestID = @DispensingID
	
	if (rtrim(ltrim(isnull(@DateOrdered,'')))='' )
		begin
			select  
				--isnull(Worder.Status,'Not Yet Raised') [Order_Status]
				@PSOText Special_Instructions,
				@thing Supplier_Code,
				@SupName Supplier_Name,
				cast(SUM(case when [Status]='1' then cast(cast(OutStanding as DEC(6,2))as float) else 0 end)as varchar(10)) as Quantity_Awaiting_Order
			FROM
				WOrder 
				where 
				WOrder.PSORequestID = @DispensingID
			For XML Auto
		end
	else
	begin	
	if (rtrim(ltrim(isnull(@DateReceived,'')))='' )	
		begin
			select  
				--isnull(Worder.Status,'Not Yet Raised') [Order_Status]
				@PSOText Special_Instructions,
				@ordnumber Order_Number,
				@thing Supplier_Code,
				@SupName Supplier_Name,
				cast(SUM(case when [Status]='3' Or [Status]='R'  then cast(qtyordered as float) else 0 end)as varchar(10)) as Quantity_Ordered,
				substring(@DateOrdered,1,2) + '/'+ substring(@DateOrdered,3,2)+ '/'+ substring(@DateOrdered,5,4) Date_Ordered
			FROM
				WOrder 
				where 
				WOrder.PSORequestID = @DispensingID
			For XML Auto
		end
	else
		begin
			if (isnull(@Invoiced,'0') = 0)
			begin
				select  
				--isnull(Worder.Status,'Not Yet Raised') [Order_Status]
				@PSOText Special_Instructions,
				@ordnumber Order_Number,
				@thing Supplier_Code,
				@SupName Supplier_Name,
				cast(SUM(case when [Status]='3' Or [Status]='R'  then cast(qtyordered as float) else 0 end)as varchar(10)) as Quantity_Ordered,
				substring(@DateOrdered,1,2) + '/'+ substring(@DateOrdered,3,2)+ '/'+ substring(@DateOrdered,5,4) Date_Ordered,
				--cast(SUM(case when [Status]='R'  then cast(received as float) else 0 end)as varchar(10)) as Quantity_Received,
				@qtyReceived Quantity_Received,
				substring(@DateReceived,1,2) + '/'+ substring(@DateReceived,3,2)+ '/'+ substring(@DateReceived,5,4) Date_Received
			FROM
				WOrder 
				where 
				WOrder.PSORequestID = @DispensingID
			For XML Auto
			end
			else
			begin
			
			select  
				--isnull(Worder.Status,'Not Yet Raised') [Order_Status]
				
				@PSOText Special_Instructions,
				@ordnumber Order_Number,
				@thing Supplier_Code,
				@SupName Supplier_Name,
				cast(SUM(case when [Status]='3' Or [Status]='R'  then cast(qtyordered as float) else 0 end)as varchar(10)) as Quantity_Ordered,
				substring(@DateOrdered,1,2) + '/'+ substring(@DateOrdered,3,2)+ '/'+ substring(@DateOrdered,5,4) Date_Ordered,
				--cast(SUM(case when [Status]='R'  then cast(received as float) else 0 end)as varchar(10)) as Quantity_Received,
				@qtyReceived Quantity_Received,
				substring(@DateReceived,1,2) + '/'+ substring(@DateReceived,3,2)+ '/'+ substring(@DateReceived,5,4) Date_Received,
				isnull(@Invoiced,'0') as Quantity_Invoiced,
				substring(@InvDate,1,2) + '/'+ substring(@InvDate,3,2)+ '/'+ substring(@InvDate,5,4) Invoice_Date,
				@InvNum Invoice_reference
			FROM
				WOrder 
				where 
				WOrder.PSORequestID = @DispensingID
			For XML Auto
			end
		end
		end
	end
End


GO

INSERT VersionLog ([Type],Description,[Date]) SELECT 'Config', 'TFS 84116', GETDATE()
GO
