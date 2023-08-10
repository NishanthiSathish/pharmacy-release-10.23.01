--Amend Order UI Changes for DLO (TFS 27246)

declare @SiteID 			int
declare @intCount int

DECLARE Site_cursor CURSOR LOCAL STATIC FORWARD_ONLY 
	FOR
	select [LocationID]
	from [Site]
	
	
	OPEN Site_cursor
	FETCH NEXT  FROM Site_cursor into  @SiteID
	
	while @@FETCH_STATUS = 0
	begin
		
		/*select @intCount= COUNT(*) from wConfiguration where SiteID = @SiteID 
		and [Category] = 'D|Winord'
		and [Section] = 'WardStockList'
		and [Key] = 'Heading4'
		and Value = '"Print Label"'
		if (@intCount > 0 )
			begin
				exec pWConfigurationWrite 0,@SiteID,'D|Winord','WardStocklist','Heading4','"Print Lbl  / DLO"'
			end */
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','label1','"F1 Help"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','label2','"F2 Sup Code"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','label3','"F3 Info"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','label4','"F4, ^F4 Enquiry"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','label5','"F5 Urgency"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','label6','"F6 Delete"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','label7','"F7 Selective Order"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','label8','"F8 Total Cost"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','label9','"^F8Enter Price"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','LstBoxVisible','"0"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','Noofcols','"10"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','Nooflabels','"10"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','ProgressGaugeVisible','"0"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','TxtBoxVisible','"-1"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','heading1','"Code"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','heading2','"Urgency"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','heading3','"Description"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','heading4','"Quantity"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','heading5','"Packsize"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','heading6','"Supp Code"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','heading7','"Pricing"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','heading8','"Patient (Date of Birth)"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','heading9','"Case Number"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','heading10','"NHS Number"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','width1','"15"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','width2','"10"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','width3','"80"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','width4','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','width5','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','width6','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','width7','"8"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','width8','"50"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','width9','"18"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','AmendPSO','width10','"18"'
			
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','label1','"F1 Help"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','label2','"F2 Sup Code"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','label3','"F3 Info"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','label4','"F4, ^F4 Enquiry"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','label5','"F6 Delete"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','label6','"F7 Receive All"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','label7','"F8 Receive Free"'
			
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','GridTitle','"Receive Patient Specific Goods"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','LstBoxVisible','"0 "'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','Noofcols','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','Nooflabels','"7"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','ProgressGaugeVisible','"0"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','TxtBoxVisible','"-1 "'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','heading1','"Description"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','heading2','"Urgency/Batch Status"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','heading3','"Quantity"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','heading4','"Price"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','heading5','"To Follow"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','heading6','"Supp Code"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','heading10','"Patient (Date of Birth)"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','heading11','"Case Number"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','heading12','"NHS Number"'
			
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','width1','"80"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','width2','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','width3','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','width4','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','width5','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','width6','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','width10','"50"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','width11','"18"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','Receive GoodsPSO','width12','"18"'
			
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','label1','"F1 Help"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','label2','"F2 Sup Code"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','label3','"F3 Info"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','label4','"F4, ^F4 Enquiry"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','label5','"F5 Toggle InDispute"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','label6','"F6 Delete"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','LstBoxVisible','"0"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','Noofcols','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','Nooflabels','"6"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','ProgressGaugeVisible','"0"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','TxtBoxVisible','"-1"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading1','"Code"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading2','"Urgency"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading3','"Description"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading4','"Quantity"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading5','"Packsize"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading6','"Supp Code"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading7','"Order Cycle"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading8','"In Dispute"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading9','"Robot"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading10','"Patient (Date of Birth)"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading11','"Case Number"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','heading12','"NHS Number"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width1','"15"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width2','"10"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width3','"80"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width4','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width5','"15"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width6','"12"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width7','"17"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width8','"15"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width9','"6"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width10','"50"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width11','"18"'
			exec pWConfigurationWrite 0,@SiteID,'D|Winord','ReconcilePSO','width12','"18"'
		FETCH NEXT  FROM Site_cursor into  @SiteID
	end

	CLOSE Site_cursor
	DEALLOCATE Site_cursor

GO

--select * from wConfiguration where Section = 'amend' and SiteID= 24



