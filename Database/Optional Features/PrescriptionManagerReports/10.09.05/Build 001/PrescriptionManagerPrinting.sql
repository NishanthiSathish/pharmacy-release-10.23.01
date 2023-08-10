--04Aug15 DJH 119571 New Version Of Reports To Improve Performance
-- 11Aug15 Rams	Renamed references to fMostRecentWLabelIssuedOnly to fMostRecentWLabelIssued
-- 09Sep15 DJH GO statement missing after DROP of vRxPrescriptionManagerPrintingInpatient
EXEC pDROP 'vRxIDPrescriptionandMergedPrescriptionWithActiveFlags'
GO

CREATE VIEW [vRxIDPrescriptionandMergedPrescriptionWithActiveFlags] 
AS
	SELECT
		 RequestID
		,startdate
		,stopdate 
		, ISNULL(WPrescriptionMergeItem.Active, 1) Active
	FROM 
		Prescription
		left Join WPrescriptionMergeItem on Prescription.requestID =WPrescriptionMergeItem.RequestID_Prescription
		WHERE (WPrescriptionMergeItem.WPrescriptionMergeItemID is null or WPrescriptionMergeItem.Active =0)
	UNION
	SELECT 
		  WPrescriptionMerge.RequestID
		, Prescription.startdate
		, Prescription.stopdate 
		, WPrescriptionMergeItem.Active
	FROM 
		WPrescriptionMerge 
	Join WPrescriptionMergeItem on WPrescriptionMerge.RequestID = WPrescriptionMergeItem.RequestID_WPrescriptionMerge
	Join Prescription on Prescription.RequestID = WPrescriptionMergeItem.RequestID_Prescription
	WHERE 
		WPrescriptionMergeItem.Active = 1 
		and WPrescriptionMergeItem.IndexOrder = 0
	UNION
	SELECT 
		  WPrescriptionMerge.RequestID
		, Request.RequestDate
		, NULL
		, WPrescriptionMergeItem.Active
	FROM 
		WPrescriptionMerge 
	Join WPrescriptionMergeItem on WPrescriptionMerge.RequestID = WPrescriptionMergeItem.RequestID_WPrescriptionMerge
	Join ProductOrder on ProductOrder.RequestID = WPrescriptionMergeItem.RequestID_Prescription
	Join Request on Request.RequestID = ProductOrder.RequestID
	WHERE 
		WPrescriptionMergeItem.Active = 1 
		and WPrescriptionMergeItem.IndexOrder = 0


GO

EXEC pDROP 'fMostRecentWLabelIssued'
GO

CREATE FUNCTION [fMostRecentWLabelIssued]
	(
		@PrescriptionID int
		,@LabelType varchar(1)
	)
	RETURNS @MostRecentWLabel TABLE
	(
			[Text]		VARCHAR(600)
		,	RequestID	INT
		,	SplitDose	BIT
		,	qty			FLOAT
		,	ward		VARCHAR(5)
		,	logdatetime	DATETIME
		,	LabelType	VARCHAR(1)
		,	Consultant	VARCHAR(10)
		,	RowCounter	INT
	)
	AS
BEGIN
	DECLARE	 @LatestWLabelID INT
	DECLARE  @SplitDoseValue BIT
	
	SELECT TOP 1 
			@LatestWLabelID = D.[RequestID]
		,	@SplitDoseValue = D.SplitDose
	from [WLabel] D (NOLOCK)
		join Request DR (NOLOCK) on DR.RequestID = D.RequestID
	where
		DR.RequestID_Parent = @PrescriptionID
		AND D.IssType = @LabelType
	order by
		[LastSavedDateTime] desc, D.RequestID desc
		
	IF @LatestWLabelID > 0
		BEGIN
			INSERT INTO @MostRecentWLabel
			(
					[Text] 
				,	RequestID
				,	SplitDose
				,	qty			
				,	ward		
				,	logdatetime		
				,	LabelType	
				,	Consultant
			)
			
			SELECT 
					wlabel.[Text]
				,	wlabel.RequestID
				,	Wlabel.SplitDose
				,	wLabel.LastQty
				,	wlabel.WardCode
				,	wLabel.LastSavedDateTime
				,	wLabel.IssType
				,	wLabel.ConsCode
			FROM	
				WLabel WITH (NOLOCK)
			WHERE
				WLabel.RequestID = @LatestWLabelID
			UNION
			SELECT 
					wlabel.[Text]
				,	wlabel.RequestID
				,	Wlabel.SplitDose
				,	wlabel.LastQty
				,	wlabel.WardCode
				,	WTransLog.LogDateTime
				,	wLabel.IssType
				,	wLabel.ConsCode
			FROM	
				WLabel WITH (NOLOCK)
				LEFT JOIN WTransLog WITH (NOLOCK) ON WTransLog.RequestID_Dispensing = wLabel.RequestID
			WHERE
				WTransLog.RequestID_Prescription = @PrescriptionID
			AND WTransLog.[Date] =
					(
						SELECT  TOP 1 [Date] from WTranslog (NOLOCK)
						WHERE WTransLog.RequestID_Prescription = @PrescriptionID
						AND WTransLog.RequestID_Dispensing > 0 -- surprisingly this is needed as RequestID_Dispensing is 0 some times
						AND WTransLog.LabelType = @LabelType
						Order by LogDateTime desc
					)
			AND Wlabel.IssType = @LabelType			
			AND WLabel.SplitDose = @SplitDoseValue
			AND WLabel.RequestID <> @LatestWLabelID
		END
	
		;WITH CTE AS
		(
			SELECT *, RN = ROW_NUMBER() OVER (Order BY LogDateTime DESC) FROM @MostRecentWLabel
			WHERE SplitDose = 0
		)
		
		DELETE FROM CTE WHERE RN > 1
		
	RETURN 

END
GO

EXEC pDROP 'vRxPrescriptionManagerPrintingSelfMed'
GO

CREATE VIEW [vRxPrescriptionManagerPrintingSelfMed] as

SELECT	
			Label.RequestID DispensingRequestID
		,	rxRequest.RequestID 
		,	RxRequest.[Description] Rxdescription
		,	Prescription.startdate RxStartDate
		,	Prescription.StopDate RxStopDate
		,	Label.[text]
		,	Label.[Qty]
		,	wardAlias.Alias EpisodeWardCode
		,	location.[description] WardDescription
		,	Label.Ward TranslogWard
		,	CaseNoAlias.Alias CaseNumber
		,	Person.Forename ForeName
		,	Person.Surname Surname 
		,	Patient.DOB DOB
		,	Label.logdatetime LastIssuedDate
		,	Label.LabelType LabelType
		,	[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
		,	Label.Splitdose
		,	Label.Consultant
		,	ISNULL(con.Title,'') + ' ' + ISNULL(con.Forename,'') + ' ' + con.Surname ConsultantName
		,	RequestStatus.Expired Expired
		,	RequestStatus.[Request Cancellation] Cancelled
	FROM vRxIDPrescriptionandMergedPrescriptionWithActiveFlags Prescription
		JOIN Request rxRequest on Prescription.requestID = rxRequest.RequestID and Prescription.Active = 1
		JOIN RequestStatus on RequestStatus.requestID = rxRequest.RequestID	
		OUTER APPLY
		icwsys.fMostRecentWLabelIssued (rxRequest.RequestID, 'S') AS Label	
		JOIN EpisodeOrder on rxRequest.RequestID = EpisodeOrder.RequestID
		JOIN Episode on Episode.EpisodeID = EpisodeOrder.EpisodeID	
		JOIN Patient on Patient.EntityID = Episode.EntityID	
		JOIN Person on Person.EntityID = Patient.EntityID
		LEFT JOIN EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) AND CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) AND i.Description = 'CaseNumber'
		JOIN Episode PatientEpisode on PatientEpisode.EpisodeID =  icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
		LEFT JOIN location on (isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location'))) = location.LocationID )
		LEFT JOIN LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) AND wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) AND wa.Description = 'WWardCodes'
		LEFT JOIN ResponsibleEpisodeEntity rsp 
		LEFT JOIN EntityRole rol on ( rsp.EntityRoleID = rol.EntityRoleID)  ON rsp.EpisodeID = Episode.EpisodeID and rsp.Active = 1
		LEFT JOIN Person con on rsp.EntityID = con.EntityID 		
	WHERE
		 RequestStatus.[Request Cancellation] = 0
		 AND (Prescription.StopDate IS NULL OR Prescription.StopDate > GETDATE()) 
		 AND RequestStatus.Expired = 0
		 AND rol.[Description] = 'Consultant'
	UNION
	SELECT
		Label.RequestID DispensingRequestID
		,	P.RequestID 
		,	PR.[Description] Rxdescription
		,	PR.RequestDate RxStartDate
		,	NULL RxStopDate
		,	Label.[text]
		,	Label.[Qty]
		,	wardAlias.Alias EpisodeWardCode
		,	location.[description] WardDescription
		,	Label.Ward TranslogWard
		,	CaseNoAlias.Alias CaseNumber
		,	Person.Forename ForeName
		,	Person.Surname Surname 
		,	Patient.DOB DOB
		,	Label.logdatetime LastIssuedDate
		,	Label.LabelType LabelType
		,	[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
		,	Label.Splitdose
		,	Label.Consultant
		,	ISNULL(con.Title,'') + ' ' + ISNULL(con.Forename,'') + ' ' + con.Surname ConsultantName
		,	RequestStatus.Expired Expired
		,	RequestStatus.[Request Cancellation] Cancelled
	FROM Episode E 
		JOIN EpisodeOrder EO on EO.EpisodeID = E.EpisodeID
		JOIN Episode on Episode.EpisodeID = EO.EpisodeID	
		JOIN Patient on Patient.EntityID = Episode.EntityID	
		JOIN Episode PatientEpisode on PatientEpisode.EpisodeID =  icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
		JOIN Person on Person.EntityID = Patient.EntityID
		JOIN ProductOrder P on P.RequestID = EO.RequestID
		JOIN Request PR on PR.RequestID = P.RequestID
		JOIN RequestType RT on RT.RequestTypeID = PR.RequestTypeID
		JOIN RequestStatus on RequestStatus.RequestID = P.RequestID
		OUTER APPLY
		icwsys.fMostRecentWLabelIssued (PR.RequestID, 'S') AS Label
		LEFT JOIN RequestCancellation PRC on PRC.RequestID = P.RequestID
		LEFT JOIN Note PRCN on PRCN.NoteID = PRC.NoteID
		LEFT JOIN ResponsibleEpisodeEntity rsp 
		LEFT JOIN EntityRole rol on ( rsp.EntityRoleID = rol.EntityRoleID)  ON rsp.EpisodeID = Episode.EpisodeID and rsp.Active = 1
		LEFT JOIN Person con on rsp.EntityID = con.EntityID 		
		LEFT JOIN EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) AND CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) AND i.Description = 'CaseNumber'
		LEFT JOIN location on (isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location'))) = location.LocationID )
		LEFT JOIN LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) AND wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) AND wa.Description = 'WWardCodes'
	WHERE
		 RequestStatus.[Request Cancellation] = 0
		 AND RequestStatus.Expired = 0
		 AND rol.[Description] = 'Consultant'
GO

EXEC pDROP 'vRxPrescriptionManagerPrintingOutpatient'
GO

CREATE VIEW [vRxPrescriptionManagerPrintingOutpatient] as

SELECT	
			Label.RequestID DispensingRequestID
		,	rxRequest.RequestID 
		,	RxRequest.[Description] Rxdescription
		,	Prescription.startdate RxStartDate
		,	Prescription.StopDate RxStopDate
		,	Label.[text]
		,	Label.[Qty]
		,	wardAlias.Alias EpisodeWardCode
		,	location.[description] WardDescription
		,	Label.Ward TranslogWard
		,	CaseNoAlias.Alias CaseNumber
		,	Person.Forename ForeName
		,	Person.Surname Surname 
		,	Patient.DOB DOB
		,	Label.logdatetime LastIssuedDate
		,	Label.LabelType LabelType
		,	[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
		,	Label.Splitdose
		,	Label.Consultant
		,	ISNULL(con.Title,'') + ' ' + ISNULL(con.Forename,'') + ' ' + con.Surname ConsultantName
		,	RequestStatus.Expired Expired
		,	RequestStatus.[Request Cancellation] Cancelled
	FROM vRxIDPrescriptionandMergedPrescriptionWithActiveFlags Prescription
		JOIN Request rxRequest on Prescription.requestID = rxRequest.RequestID and Prescription.Active = 1
		JOIN RequestStatus on RequestStatus.requestID = rxRequest.RequestID	
		OUTER APPLY
		icwsys.fMostRecentWLabelIssued (rxRequest.RequestID, 'O') AS Label	
		JOIN EpisodeOrder on rxRequest.RequestID = EpisodeOrder.RequestID
		JOIN Episode on Episode.EpisodeID = EpisodeOrder.EpisodeID	
		JOIN Patient on Patient.EntityID = Episode.EntityID	
		JOIN Person on Person.EntityID = Patient.EntityID
		LEFT JOIN EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) AND CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) AND i.Description = 'CaseNumber'
		JOIN Episode PatientEpisode on PatientEpisode.EpisodeID =  icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
		LEFT JOIN location on (isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location'))) = location.LocationID )
		LEFT JOIN LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) AND wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) AND wa.Description = 'WWardCodes'
		LEFT JOIN ResponsibleEpisodeEntity rsp 
		LEFT JOIN EntityRole rol on ( rsp.EntityRoleID = rol.EntityRoleID)  ON rsp.EpisodeID = Episode.EpisodeID and rsp.Active = 1
		LEFT JOIN Person con on rsp.EntityID = con.EntityID 		
	WHERE
		 RequestStatus.[Request Cancellation] = 0
		 AND (Prescription.StopDate IS NULL OR Prescription.StopDate > GETDATE()) 
		 AND RequestStatus.Expired = 0
		 AND rol.[Description] = 'Consultant'
	UNION
	SELECT
		Label.RequestID DispensingRequestID
		,	P.RequestID 
		,	PR.[Description] Rxdescription
		,	PR.RequestDate RxStartDate
		,	NULL RxStopDate
		,	Label.[text]
		,	Label.[Qty]
		,	wardAlias.Alias EpisodeWardCode
		,	location.[description] WardDescription
		,	Label.Ward TranslogWard
		,	CaseNoAlias.Alias CaseNumber
		,	Person.Forename ForeName
		,	Person.Surname Surname 
		,	Patient.DOB DOB
		,	Label.logdatetime LastIssuedDate
		,	Label.LabelType LabelType
		,	[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
		,	Label.Splitdose
		,	Label.Consultant
		,	ISNULL(con.Title,'') + ' ' + ISNULL(con.Forename,'') + ' ' + con.Surname ConsultantName
		,	RequestStatus.Expired Expired
		,	RequestStatus.[Request Cancellation] Cancelled
	FROM Episode E 
		JOIN EpisodeOrder EO on EO.EpisodeID = E.EpisodeID
		JOIN Episode on Episode.EpisodeID = EO.EpisodeID	
		JOIN Patient on Patient.EntityID = Episode.EntityID	
		JOIN Episode PatientEpisode on PatientEpisode.EpisodeID =  icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
		JOIN Person on Person.EntityID = Patient.EntityID
		JOIN ProductOrder P on P.RequestID = EO.RequestID
		JOIN Request PR on PR.RequestID = P.RequestID
		JOIN RequestType RT on RT.RequestTypeID = PR.RequestTypeID
		JOIN RequestStatus on RequestStatus.RequestID = P.RequestID
		OUTER APPLY
		icwsys.fMostRecentWLabelIssued (PR.RequestID, 'O') AS Label
		LEFT JOIN RequestCancellation PRC on PRC.RequestID = P.RequestID
		LEFT JOIN Note PRCN on PRCN.NoteID = PRC.NoteID
		LEFT JOIN ResponsibleEpisodeEntity rsp 
		LEFT JOIN EntityRole rol on ( rsp.EntityRoleID = rol.EntityRoleID)  ON rsp.EpisodeID = Episode.EpisodeID and rsp.Active = 1
		LEFT JOIN Person con on rsp.EntityID = con.EntityID 		
		LEFT JOIN EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) AND CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) AND i.Description = 'CaseNumber'
		LEFT JOIN location on (isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location'))) = location.LocationID )
		LEFT JOIN LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) AND wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) AND wa.Description = 'WWardCodes'
	WHERE
		 RequestStatus.[Request Cancellation] = 0
		 AND RequestStatus.Expired = 0
		 AND rol.[Description] = 'Consultant'
GO

EXEC pDROP 'vRxPrescriptionManagerPrintingLeave'
GO

CREATE VIEW [vRxPrescriptionManagerPrintingLeave] as

SELECT	
			Label.RequestID DispensingRequestID
		,	rxRequest.RequestID 
		,	RxRequest.[Description] Rxdescription
		,	Prescription.startdate RxStartDate
		,	Prescription.StopDate RxStopDate
		,	Label.[text]
		,	Label.[Qty]
		,	wardAlias.Alias EpisodeWardCode
		,	location.[description] WardDescription
		,	Label.Ward TranslogWard
		,	CaseNoAlias.Alias CaseNumber
		,	Person.Forename ForeName
		,	Person.Surname Surname 
		,	Patient.DOB DOB
		,	Label.logdatetime LastIssuedDate
		,	Label.LabelType LabelType
		,	[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
		,	Label.Splitdose
		,	Label.Consultant
		,	ISNULL(con.Title,'') + ' ' + ISNULL(con.Forename,'') + ' ' + con.Surname ConsultantName
		,	RequestStatus.Expired Expired
		,	RequestStatus.[Request Cancellation] Cancelled
	FROM vRxIDPrescriptionandMergedPrescriptionWithActiveFlags Prescription
		JOIN Request rxRequest on Prescription.requestID = rxRequest.RequestID and Prescription.Active = 1
		JOIN RequestStatus on RequestStatus.requestID = rxRequest.RequestID	
		OUTER APPLY
		icwsys.fMostRecentWLabelIssued (rxRequest.RequestID, 'L') AS Label	
		JOIN EpisodeOrder on rxRequest.RequestID = EpisodeOrder.RequestID
		JOIN Episode on Episode.EpisodeID = EpisodeOrder.EpisodeID	
		JOIN Patient on Patient.EntityID = Episode.EntityID	
		JOIN Person on Person.EntityID = Patient.EntityID
		LEFT JOIN EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) AND CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) AND i.Description = 'CaseNumber'
		JOIN Episode PatientEpisode on PatientEpisode.EpisodeID =  icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
		LEFT JOIN location on (isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location'))) = location.LocationID )
		LEFT JOIN LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) AND wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) AND wa.Description = 'WWardCodes'
		LEFT JOIN ResponsibleEpisodeEntity rsp 
		LEFT JOIN EntityRole rol on ( rsp.EntityRoleID = rol.EntityRoleID)  ON rsp.EpisodeID = Episode.EpisodeID and rsp.Active = 1
		LEFT JOIN Person con on rsp.EntityID = con.EntityID 		
	WHERE
		 RequestStatus.[Request Cancellation] = 0
		 AND (Prescription.StopDate IS NULL OR Prescription.StopDate > GETDATE()) 
		 AND RequestStatus.Expired = 0
		 AND rol.[Description] = 'Consultant'
	UNION
	SELECT
		Label.RequestID DispensingRequestID
		,	P.RequestID 
		,	PR.[Description] Rxdescription
		,	PR.RequestDate RxStartDate
		,	NULL RxStopDate
		,	Label.[text]
		,	Label.[Qty]
		,	wardAlias.Alias EpisodeWardCode
		,	location.[description] WardDescription
		,	Label.Ward TranslogWard
		,	CaseNoAlias.Alias CaseNumber
		,	Person.Forename ForeName
		,	Person.Surname Surname 
		,	Patient.DOB DOB
		,	Label.logdatetime LastIssuedDate
		,	Label.LabelType LabelType
		,	[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
		,	Label.Splitdose
		,	Label.Consultant
		,	ISNULL(con.Title,'') + ' ' + ISNULL(con.Forename,'') + ' ' + con.Surname ConsultantName
		,	RequestStatus.Expired Expired
		,	RequestStatus.[Request Cancellation] Cancelled
	FROM Episode E 
		JOIN EpisodeOrder EO on EO.EpisodeID = E.EpisodeID
		JOIN Episode on Episode.EpisodeID = EO.EpisodeID	
		JOIN Patient on Patient.EntityID = Episode.EntityID	
		JOIN Episode PatientEpisode on PatientEpisode.EpisodeID =  icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
		JOIN Person on Person.EntityID = Patient.EntityID
		JOIN ProductOrder P on P.RequestID = EO.RequestID
		JOIN Request PR on PR.RequestID = P.RequestID
		JOIN RequestType RT on RT.RequestTypeID = PR.RequestTypeID
		JOIN RequestStatus on RequestStatus.RequestID = P.RequestID
		OUTER APPLY
		icwsys.fMostRecentWLabelIssued (PR.RequestID, 'L') AS Label
		LEFT JOIN RequestCancellation PRC on PRC.RequestID = P.RequestID
		LEFT JOIN Note PRCN on PRCN.NoteID = PRC.NoteID
		LEFT JOIN ResponsibleEpisodeEntity rsp 
		LEFT JOIN EntityRole rol on ( rsp.EntityRoleID = rol.EntityRoleID)  ON rsp.EpisodeID = Episode.EpisodeID and rsp.Active = 1
		LEFT JOIN Person con on rsp.EntityID = con.EntityID 		
		LEFT JOIN EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) AND CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) AND i.Description = 'CaseNumber'
		LEFT JOIN location on (isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location'))) = location.LocationID )
		LEFT JOIN LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) AND wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) AND wa.Description = 'WWardCodes'
	WHERE
		 RequestStatus.[Request Cancellation] = 0
		 AND RequestStatus.Expired = 0
		 AND rol.[Description] = 'Consultant'
GO

EXEC pDROP 'vRxPrescriptionManagerPrintingInpatient'
GO

CREATE VIEW [vRxPrescriptionManagerPrintingInpatient] as

SELECT	
			Label.RequestID DispensingRequestID
		,	rxRequest.RequestID 
		,	RxRequest.[Description] Rxdescription
		,	Prescription.startdate RxStartDate
		,	Prescription.StopDate RxStopDate
		,	Label.[text]
		,	Label.[Qty]
		,	wardAlias.Alias EpisodeWardCode
		,	location.[description] WardDescription
		,	Label.Ward TranslogWard
		,	CaseNoAlias.Alias CaseNumber
		,	Person.Forename ForeName
		,	Person.Surname Surname 
		,	Patient.DOB DOB
		,	Label.logdatetime LastIssuedDate
		,	Label.LabelType LabelType
		,	[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
		,	Label.Splitdose
		,	Label.Consultant
		,	ISNULL(con.Title,'') + ' ' + ISNULL(con.Forename,'') + ' ' + con.Surname ConsultantName
		,	RequestStatus.Expired Expired
		,	RequestStatus.[Request Cancellation] Cancelled
	FROM vRxIDPrescriptionandMergedPrescriptionWithActiveFlags Prescription
		JOIN Request rxRequest on Prescription.requestID = rxRequest.RequestID and Prescription.Active = 1
		JOIN RequestStatus on RequestStatus.requestID = rxRequest.RequestID	
		OUTER APPLY
		icwsys.fMostRecentWLabelIssued (rxRequest.RequestID, 'I') AS Label	
		JOIN EpisodeOrder on rxRequest.RequestID = EpisodeOrder.RequestID
		JOIN Episode on Episode.EpisodeID = EpisodeOrder.EpisodeID	
		JOIN Patient on Patient.EntityID = Episode.EntityID	
		JOIN Person on Person.EntityID = Patient.EntityID
		LEFT JOIN EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) AND CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) AND i.Description = 'CaseNumber'
		JOIN Episode PatientEpisode on PatientEpisode.EpisodeID =  icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
		LEFT JOIN location on (isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location'))) = location.LocationID )
		LEFT JOIN LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) AND wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) AND wa.Description = 'WWardCodes'
		LEFT JOIN ResponsibleEpisodeEntity rsp 
		LEFT JOIN EntityRole rol on ( rsp.EntityRoleID = rol.EntityRoleID)  ON rsp.EpisodeID = Episode.EpisodeID and rsp.Active = 1
		LEFT JOIN Person con on rsp.EntityID = con.EntityID 		
	WHERE
		 RequestStatus.[Request Cancellation] = 0
		 AND (Prescription.StopDate IS NULL OR Prescription.StopDate > GETDATE()) 
		 AND RequestStatus.Expired = 0
		 AND rol.[Description] = 'Consultant'
	UNION
	SELECT
		Label.RequestID DispensingRequestID
		,	P.RequestID 
		,	PR.[Description] Rxdescription
		,	PR.RequestDate RxStartDate
		,	NULL RxStopDate
		,	Label.[text]
		,	Label.[Qty]
		,	wardAlias.Alias EpisodeWardCode
		,	location.[description] WardDescription
		,	Label.Ward TranslogWard
		,	CaseNoAlias.Alias CaseNumber
		,	Person.Forename ForeName
		,	Person.Surname Surname 
		,	Patient.DOB DOB
		,	Label.logdatetime LastIssuedDate
		,	Label.LabelType LabelType
		,	[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
		,	Label.Splitdose
		,	Label.Consultant
		,	ISNULL(con.Title,'') + ' ' + ISNULL(con.Forename,'') + ' ' + con.Surname ConsultantName
		,	RequestStatus.Expired Expired
		,	RequestStatus.[Request Cancellation] Cancelled
	FROM Episode E 
		JOIN EpisodeOrder EO on EO.EpisodeID = E.EpisodeID
		JOIN Episode on Episode.EpisodeID = EO.EpisodeID	
		JOIN Patient on Patient.EntityID = Episode.EntityID	
		JOIN Episode PatientEpisode on PatientEpisode.EpisodeID =  icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
		JOIN Person on Person.EntityID = Patient.EntityID
		JOIN ProductOrder P on P.RequestID = EO.RequestID
		JOIN Request PR on PR.RequestID = P.RequestID
		JOIN RequestType RT on RT.RequestTypeID = PR.RequestTypeID
		JOIN RequestStatus on RequestStatus.RequestID = P.RequestID
		OUTER APPLY
		icwsys.fMostRecentWLabelIssued (PR.RequestID, 'I') AS Label
		LEFT JOIN RequestCancellation PRC on PRC.RequestID = P.RequestID
		LEFT JOIN Note PRCN on PRCN.NoteID = PRC.NoteID
		LEFT JOIN ResponsibleEpisodeEntity rsp 
		LEFT JOIN EntityRole rol on ( rsp.EntityRoleID = rol.EntityRoleID)  ON rsp.EpisodeID = Episode.EpisodeID and rsp.Active = 1
		LEFT JOIN Person con on rsp.EntityID = con.EntityID 		
		LEFT JOIN EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) AND CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) AND i.Description = 'CaseNumber'
		LEFT JOIN location on (isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location'))) = location.LocationID )
		LEFT JOIN LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) AND wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) AND wa.Description = 'WWardCodes'
	WHERE
		 RequestStatus.[Request Cancellation] = 0
		 AND RequestStatus.Expired = 0
		 AND rol.[Description] = 'Consultant'
GO

-- Add to Version Log
INSERT VersionLog ([Type], Description, [Date]) SELECT 'Config', 'PrescriptionManagerPrinting.sql (10.09.05) v5', GETDATE()
GO