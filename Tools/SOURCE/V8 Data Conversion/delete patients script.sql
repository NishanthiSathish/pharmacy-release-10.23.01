CREATE TABLE #tempAddressIDs (AddressID INT)


DECLARE PatientIDs CURSOR FORWARD_ONLY STATIC LOCAL FOR
SELECT EntityID FROM Patient

OPEN PatientIDS

DECLARE @PatientEntityID int

FETCH NEXT FROM PatientIDS into @PatientEntityID

WHILE (@@FETCH_STATUS = 0)
	BEGIN

		INSERT INTO #tempAddressIDs (AddressID)
		SELECT AddressID from EntityLinkAddress WHERE EntityID = @PatientEntityID

		DELETE FROM EntityLinkAddress WHERE EntityID = @PatientEntityID

		DELETE FROM Address WHERE AddressID IN (
				SELECT AddressID FROM #tempAddressIDs
			)

		DELETE FROM #tempAddressIDs

		DELETE FROM EntityRequestOLAP WHERE EntityID = @PatientEntityID

		DELETE FROM ResponsibleEpisodeEntity WHERE EpisodeID IN (SELECT EpisodeID FROM Episode WHERE EntityID = @PatientEntityID)

		DELETE FROM EpisodeLocation WHERE EpisodeID IN (SELECT EpisodeID FROM Episode WHERE EntityID = @PatientEntityID)

		DELETE FROM Episode WHERE EntityID = @PatientEntityID
		
		DELETE FROM EntityAlias WHERE EntityID = @PatientEntityID

		DELETE FROM PersonAlias WHERE EntityID = @PatientEntityID

		DELETE FROM V8PatientConversion WHERE EntityID = @PatientEntityID

		DELETE FROM NorthBirminghamPatient WHERE EntityID = @PatientEntityID

		EXEC pPatientDelete 1, @PatientEntityID

		FETCH NEXT FROM PatientIDS into @PatientEntityID
	END
CLOSE PatientIDS

DEALLOCATE PatientIDS

DROP TABLE #tempAddressIDs