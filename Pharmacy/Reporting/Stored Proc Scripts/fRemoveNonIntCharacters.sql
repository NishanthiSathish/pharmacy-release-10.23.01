-- 02May12 AJK 33282 Created

IF OBJECT_ID('fRemoveNonIntCharacters') IS NOT NULL
	DROP FUNCTION fRemoveNonIntCharacters
GO

Create Function [fRemoveNonIntCharacters](@Temp VarChar(8000)) 
Returns VarChar(8000) 
AS 
Begin 
    While PatIndex('%[^0-9]%', @Temp) > 0 
        Set @Temp = Stuff(@Temp, PatIndex('%[^0-9]%', @Temp), 1, '') 
 
    Return @Temp 
End 
