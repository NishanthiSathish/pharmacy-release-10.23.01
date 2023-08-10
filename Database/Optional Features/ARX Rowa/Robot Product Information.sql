/**-------------- Add Product Information items to wConfiguration Mechdisp ------------TFS37640------
24Jul12 CKJ Rowa Interface now supports Product Information message (ZDI) to aid adding new products.
The ZDI message sends product description and units with the link code (barcode) from Ascribe to Rowa

This script is to be used after a standard Rowa installation has been completed. 
It can be run multiple times but will write each entry only once, preserving any manual edits.
The settings are installed if MechDisp [n] Identifier = "Rowa" is found

It is essential that the main SQL patch (10.09 or later) is run first 
to widen wConfiguration Value to 8000 characters.

27Jun14 CKJ Functionally identical. Added versionlog.


10.14 Compatible Version
01  12Jan16 JP		TFS 140209 - First Version

**/

----------------------------------------------------------------------------------
-- CAUTION: Leading spaces and line breaks in this quoted text are significant. --
-- Therefore DO NOT indent this block for the sake of neatness! Thank you.      --
declare @RuleText	varchar(8000)
set @RuleText = 
'"    Drug Information Interface
  Rules for abbreviating product descriptions to fit maximum length

  Each line is used in turn and must consist of 
  <separator><original><separator><replacement><separator>
  optionally followed by a comment if desired.
  The original text can be in upper, lower or mixed case.
  Do not repeat entries that purely differ in typecase of the original.
  Do not create an entry where <replacement> is contained inside <original>.
  The replacement text is used exactly as typed.
  The separator cannot be space or tab characters as these mark a line
  as being a comment.
  The separator must be present three times per line and must be the
  first character on the line. Different separators can be used on different
  lines, allowing replacement of a wide range of text; eg
  "unabbreviated text"abbrev. text"
  |six inches|6"|
  The order of the lines is important, start with obvious and simple
  substitutions, and save more radical abbreviations for the end.
  Replacement stops when the text is short enough or there are no more 
  substitutions available.
  Where a word or phrase is progressively shortened, ensure that the
  steps are in the correct order otherwise an abbreviation may be skipped.
  Be very cautious about one word being embedded in another,
  eg inch in Cinchocaine  where |inch|"| would become C"ocaine
  This is particularly likely as abbreviations are themselves shortened.

  --- Start of configurable entries ---

  This section removes punctuation
| - | |	space dash space as separator
|[|!|	take out brackets next - retain length to force trailing bracket replacement
|]|!|
|(|!|
|)|!|
|{|!|
|}|!|
|!| |	remove brackets in pairs
|  | |	remove excess spaces again

| x |x|
| with | + |

  This block holds common abbreviations, all retaining trailing "."
|tablets|Tabs.|
|tablet|Tab.|
|capsules|Caps.|
|capsule|Cap.|
|cartridges|Cart.|
|cartridge|Cart.|
|pessaries|Pess.|
|pessary|Pess.|
|injection|Inj.|
|infusions|Inf.|
|infusion|Inf.|
|ointment|Oint.|
|tincture|Tinct.|
|bottles|Btl.|
|bottle|Btl.|
|solution|Soln.|
|suspension|Susp.|
|vaccines|Vacc.|
|vaccine|Vacc.|
|syrup|syr.|	caution syrup v syringe
|syringes|SYR.|	caution syrup v syringe
|syringe|SYR.|	caution syrup v syringe
|sprays|spr.|
|spray|spr.|
|nebulisers|Neb.|
|nebuliser|Neb.|
|inhalers|Inh.|
|inhaler|Inh.|
|Suppository|Supp.|
|Suppositories|Supps.|
|effervescent|Eff.|
|concentrate|Conc.|
|instillations|Instil.|
|instillation|Instil.|
|irrigation|Irrig.|
|liquid|Liq.|
|preservative|Preserv.|
|paediatric|Paed.|
|dressings|dress.|
|dressing|dress.|
|immunoglobulin|Immunoglob.|
|dispersible|disp.|
|reconstituted|reconst.|
|lozenges|Loz.|
|lozenge|Loz.|
|emulsion|Emul.|
|sachets|Sach.|
|sachet|Sach.|

	Secondary changes
| electrolyte free | EF |
| electrolyte-free | EF |
|powders|Powder|
|powder|Pwdr|
| vitamin | Vit |
|blister|blist|
|mixture|Mixt|
| drops | drop |
|mouthwash|M/wash|
| test | Tst |
|adsorbed|Ads|

|micrograms|microgram|	remove plural
| microgram|microgram|	remove leading space

|paed.|Paed|

|hydrochloride|HCl|
|chloride|Chlor.|
|bicarbonate|Bicarb.|
|succinate|Succ.|
|aqueous|Aqu.|
|phosphate|Phos.|
|sulphate|Sulph.|
|sulfate|Sulf.|
|acetate|Acet.|
|dipropionate|Diprop.|
|Normal Saline|N/S|
|glucose|Gluc.|
|Adolescent|Adol.|

| and | + |	replace with plus sign

|Sodium|Sod.¬¬|		caution Disodium -> DiSod.¬¬ (retaining length)
|DiSod.¬¬|Disodium|	re-expand (note may have been all capitals)
|Sod.¬¬|Sod.|		replace & now shorten
|Potassium|Pot.|

  remove trailing . from common abbreviations only
|Tab.|Tab|
|Tabs.|Tab|
|Tabs |Tab |
|Cap.|Cap|
|Caps.|Cap|
|Caps |Cap |
|Pess.|Pess|
|Inf.|Inf|	
|inj.|Inj|	
|Irrig.|Irr.|			keep "." if possible
|Irr.|Irr|
|soln.|soln|
|preserv.|preserv|
|Supps.|Supp|
|Supp.|Supp|
|Neb.|Neb|
|Btl.|Btl|
|susp.|Susp|
| oint.| Oint|
| Sach.| Sach|
|hydrochloride|hydrochl.|
| chlor | Cl |		spaces prevent chlorhexidine -> Clhexidine
| chlor.| Cl |
|Sod. Chlor.|Na Cl|
|Sod. Cl|Na Cl|
|Bicarb.|HCO3|
|Phos.|PO4|
|sulf.|SO4|
|sulph.|SO4|
|Immunoglob.|Immunoglob|
| succ.| Succ|
| Sod.| Sod|
|Patches|Patch|

|1000mL|1L|
|Na Cl|NaCl|
 |microgram|mcg|		consider whether to allow this (disabled by default)
|microgram |microg |	
|microgram/|microg/|	

| + |+|	remove spaces (back to same size as |&| would have been)

  ~~~~ End of configuration ~~~"'

declare @SiteID		 int
declare @RobotID     varchar(255)
declare @ValueLength Int

	SELECT @ValueLength = CHARACTER_MAXIMUM_LENGTH FROM INFORMATION_SCHEMA.COLUMNS 
		WHERE TABLE_NAME = 'wConfiguration' AND COLUMN_NAME = 'Value'
		
	if @ValueLength = 8000
		begin

			DECLARE Site_cursor CURSOR LOCAL STATIC FORWARD_ONLY 
				FOR
				select [LocationID]
				from [Site]
					
			OPEN Site_cursor
				FETCH NEXT FROM Site_cursor into @SiteID
				
				while @@FETCH_STATUS = 0
				begin
					set @RobotID = NULL
					
					select @RobotID=[Section] from wConfiguration where SiteID = @SiteID 
						and [Category]	= 'D|MechDisp'
						and [Key]		= 'Identifier'
						and [Value]		= '"Rowa"'

					if not @RobotID IS NULL 
						begin
							-- ZDI Message --
							If not Exists
								(Select * from wConfiguration where SiteID = @SiteID 
									and [Category]	= 'D|MechDisp'
									and [Section]	= @RobotID
									and [Key]		= 'MSGProductData')
							begin
								exec pWConfigurationWrite 0, @SiteID, 'D|MechDisp', @RobotID, 'MSGProductData', '"[MSHstandard][13][ZDIproduct][13]"'
							end

							If not Exists
								(Select * from wConfiguration where SiteID = @SiteID 
									and [Category]	= 'D|MechDisp'
									and [Section]	= @RobotID
									and [Key]		= 'ZDIProduct')
							begin
								exec pWConfigurationWrite 0, @SiteID, 'D|MechDisp', @RobotID, 'ZDIProduct', '"ZDI|[PackBarcode]^[ItemDescription]^[PackQuantity]^[ItemForm]^[EANcode]^[CDflag]^[FridgeFlag]"'
							end

							-- Abbreviation Rules --
							if not Exists
								(select * from wConfiguration where SiteID = @SiteID 
									and [Category] = 'D|MechDisp'
									and [Section] = 'Common'
									and [Key] = 'AbbreviationRules')								
								begin
									exec pWConfigurationWrite 0, @SiteID, 'D|MechDisp', 'Common', 'AbbreviationRules', @RuleText
								end
						end 			
						
					FETCH NEXT  FROM Site_cursor into  @SiteID
				end

			CLOSE Site_cursor
			DEALLOCATE Site_cursor
		end
	else
		begin
			print 'WARNING:' 
			print 'Script has not executed because the wConfiguration table has not been extended.'
			print 'The main SQL update script for this release (10.09 or later) MUST be run before this script is used.'
			print ''
			print '--- No changes have been made ---'			
		end	
		
	--Add to Version Log
	INSERT VersionLog (Type, [Description], [Date]) SELECT 'Config', 'Product Information ZDI for ARX Rowa wConfiguration Mechdisp (TFS37640) (10.14) V1', GETDATE()
GO
-------------------------- 

