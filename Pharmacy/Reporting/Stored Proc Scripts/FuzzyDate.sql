if object_id('FuzzyDate') is not null
	drop function dbo.FuzzyDate 
go


--A fuction that will take any date in string format and convert it to a proper date.

create function FuzzyDate ( @DateString varchar (15), @Style varchar(15) = null ) 

returns DateTime

as

begin


--Testing
--Declare @DateString varchar (15)
--declare @Style varchar (15)
--set @DateString = '250102  '
--set @Style = 'ddmmyyyy'

declare @TargetDate varchar (15)
declare @Day varchar (10)
declare @Month varchar (10)
declare @year varchar (10)

	set @DateString = IsNull(@DateString, '')
	set @DateString = RTrim(LTrim(@DateString))

	if charIndex('-', @DateString ) > 0
		Set @DateString = Replace(@DateString, '-', '/')

	if charIndex('.', @DateString) > 0
		Set @DateString = Replace(@DateString, '.', '/')

	if IsNull(@Style, '') = '' --No Style
		begin
			if (charindex('/', @DateString) > 0 ) and ( IsNumeric((left(@DateString, 4))) = 0)
				begin				
					set @Style = 'DD/MM/YYYY' -- Default 1
				end
			else if (charindex('/', @DateString) > 0) and (IsNumeric(left(@DateString, 4)) > 0)
				set @Style = 'YYYY/MM/DD' -- Default 2
			else
				set @Style = 'DDMMYYYY' --Default 3
		end
		
	if Upper(@Style) in ('YYYY/MM/DD', 'YY/MM/DD') and charindex('/', @DateString) > 0
		begin
			set @Day = substring(@DateString, (charindex('/', @DateString, (charindex('/', @DateString)+1)) +1 ), 2 )
			set @Month = substring( @DateString, (charindex('/', @DateString)+1), (charindex('/', @DateString, (charindex('/', @DateString)+1) ) - (charindex('/', @DateString)+1)) )
			set @Year = substring(@DateString, 1, charindex('/', @DateString)-1 )				
		end

	if Upper(@Style) in ('DD/MM/YYYY', 'DD/MM/YY', 'D/M/Y') and charindex('/', @DateString) > 0
		begin
			set @Day = substring(@DateString, 1, (charindex('/', @DateString)-1))
			set @Month = substring( @DateString, (charindex('/', @DateString)+1), (charindex('/', @DateString, (charindex('/', @DateString)+1) ) - (charindex('/', @DateString)+1)) )
			set @Year = substring(@DateString, (charindex('/', @DateString, (charindex('/', @DateString)+1)) +1 ),4 )				
		end
		
	--if Upper(@Style) in ('DD-MM-YYYY', 'DD-MM-YY', 'D-M-Y') and charindex('-', @DateString) > 0
	--	begin
	--		set @Day = substring(@DateString, 1, (charindex('-', @DateString)-1))
	--		set @Month = substring( @DateString, (charindex('-', @DateString)+1), (charindex('-', @DateString, (charindex('-', @DateString)+1) ) - (charindex('-', @DateString)+1)) )
	--		set @Year = substring(@DateString, (charindex('-', @DateString, (charindex('-', @DateString)+1)) +1 ),4 )				
	--	end

	if (Upper(@Style) in ('DDMMYYYY', 'DDMMYY', 'DMY')) --and (charindex('/', @DateString) + charindex('-', @DateString) = 0)
		begin
			set @DateString = Replace(@DateString, '/', '')
			set @DateString = Replace(@DateString, '-', '')
			
			if len(@DateString) = 6
				begin
					set @Day = Left(@DateString,2)
					set @Month =  Right((Left(@DateString, 4)), 2)
					set @Year = Right(@DateString, 2)
				end
			else if len(@DateString) = 8
				begin
					set @Day = Left(@DateString,2)
					set @Month =  Right((Left(@DateString, 4)), 2)
					set @Year = Right(@DateString, 4)
				end
			else
				set @Day = null
		end

	if (Upper(@Style) in ('YYYYMMDD', 'YYMMDD', 'YMD')) --and (charindex('/', @DateString) + charindex('-', @DateString) = 0)
		begin
			set @DateString = Replace(@DateString, '/', '')
			set @DateString = Replace(@DateString, '-', '')
			
			if len(@DateString) = 6
				begin
					set @Day = Right(@DateString,2)
					set @Month =  Left((Right(@DateString, 4)), 2)
					set @Year = Left(@DateString, 2)
				end
			else if len(@DateString) = 8
				begin
					set @Day = Right(@DateString,2)
					set @Month =  Left((Right(@DateString, 4)), 2)
					set @Year = Left(@DateString, 4)
				end
			else
				Set @Day = null
		end

	if len(@Day) = 1 
		set @Day = '0' + @Day

	if len(@Month) = 1 
		set @Month = '0' + @Month
		
	if (len(@Year) <= 2) and (Convert(int, @Year) <= 50) --If year is less than 50 assume 20th century
		set @Year = '20' + Right(('0' + @Year),2)

	--Do some sanity check...
	if (@Month in ('01', '03', '05', '07', '08', '10', '12')) and (convert(int, @Day) >= 32)
		set @Day = null

	if (@Month in ('04', '06', '09', '11')) and (convert(int, @Day) >= 31)
		set @Day = null

	if (@Month = '02') 
		begin
			if ((convert(int, @Year) % 4) <> 0) and (convert(int, @Day) >= 29)
				set @Day = null
			else if ((convert(int, @Year) % 4) = 0) and (convert(int, @Day) >= 30)
				set @Day = null
		end	

	if convert(int, @Month) > 12
		set @Day = null
	
	if convert(int, @Year) < 1900
		set @Day = null

--Test
--select @Year [Year], @Month [Month], @Day [Day]
--select Convert(DateTime, @Year + @Month + @Day)
--select @Day [Day], @Month [Month], @Year [Year]

	if @Day is not null
		Return Convert(DateTime, @Year + @Month + @Day)

return null

end

