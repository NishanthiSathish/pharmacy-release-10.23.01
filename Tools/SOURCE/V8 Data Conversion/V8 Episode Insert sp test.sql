declare @SessionID int

select top 1 @SessionID =  SessionID from Session

exec pV8EpisodeInsert		@SessionID,
									1,
									'Recno',
									'01-Feb-2005 12:24:03',
									'PAS',
									'PASLIVE',
									NULL,
									NULL,
									NULL,
									'C',					-- CLASS
									'EpisodeNum',
									'Y',
									'FacilityID',
									'Ward',
									'Room',
									'Bed',
									'AttendingDr',
									'01-Feb-2005 12:23:00',
									NULL,
									'Cons',
									'Spec',
									'Height',
									'Weight',
									'Gp',
									'I',					--STATUS
									'P',					--PPFLAG
									'Diagnosis codes - comma seperated'


select top 1 * from Episode
order by episodeid desc