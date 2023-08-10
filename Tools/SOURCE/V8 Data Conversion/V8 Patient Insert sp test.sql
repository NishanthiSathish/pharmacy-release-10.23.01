declare @SessionID int
declare @EntityID int

select top 1 @SessionID =  SessionID from Session

exec pV8PatientInsert		@SessionID,
									2,
									2,
									'Recno3',
									'CaseNo',
									'OldCaseNo',
									'Surname',
									'Forename',
									'28 FEB 1972',		-- DOB
									0,
									0,
									0,
									'M',					-- Sex
									'A&E',
									'AB',
									'Weight',
									'Height',
									'I',					-- Status
									'PostCode',
									'GP',
									'House',
									'NHSNumber',
									'NhVa',
									'',
									'Address1',
									'Address2',
									'Address3',
									'Address4',
									'Orig',
									'AliasSurname',
									'AliasForename',
									'P',						-- PPFlag
									'EpisodeNum',
									'Spec',
									'Allergies',
									'Diagnosis',
									74.3,						-- SurfaceArea
									'Patient notes....',
									@entityid OUTPUT


select * from Patient where entityid = @EntityID

select * from V8PatientConversion

