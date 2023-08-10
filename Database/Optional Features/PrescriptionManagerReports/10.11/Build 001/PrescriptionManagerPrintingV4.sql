--09Dec14  TH Version 4
--TFS 104520 Couple of mods;
--Only return where we have a last issued qty > 0 
--Ensure all types of expired/cancelled rxs are filtered out of views
--Done by linking to Request status table for extra checks on cancelled rxes
--and further filter on qty of the top transaction
--this removes anything with return as latest log entry and also anything without a corresponding issue

exec pDrop 'vRxIDPrescriptionandMergedPrescription'
GO

CREATE  view [vRxIDPrescriptionandMergedPrescription] as
	(Select RequestID,startdate,stopdate from Prescription
	left Join WPrescriptionMergeItem on Prescription.requestID =WPrescriptionMergeItem.RequestID_Prescription
	where (WPrescriptionMergeItem.WPrescriptionMergeItemID is null or WPrescriptionMergeItem.Active =0))
	union
	(select WPrescriptionMerge.RequestID,Prescription.startdate,Prescription.stopdate from WPrescriptionMerge 
	Join WPrescriptionMergeItem on WPrescriptionMerge.RequestID = WPrescriptionMergeItem.RequestID_WPrescriptionMerge
	Join Prescription on Prescription.RequestID = WPrescriptionMergeItem.RequestID_Prescription
	where WPrescriptionMergeItem.Active = 1 and WPrescriptionMergeItem.IndexOrder = 0)
GO

exec pDrop 'vRxPrescriptionManagerPrintingInpatient'
GO

CREATE  view [vRxPrescriptionManagerPrintingInpatient] as

Select	RxRequest.[Description] Rxdescription,Prescription.startdate RxStartDate,Prescription.StopDate RxStopDate, Label.[text]
,Label.[Qty]
, wardAlias.Alias EpisodeWardCode,location.[description] WardDescription
,Label.Ward TranslogWard
, CaseNoAlias.Alias CaseNumber,Person.Forename ForeName,Person.Surname Surname 
, Patient.DOB DOB,Label.logdatetime LastIssuedDate,Label.Kind TransactionStatus, Label.LabelType LabelType
	,[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
	,Label.Splitdose
	,Label.Consultant
	,con.Title + ' ' + con.Forename + ' ' + con.Surname ConsultantName
	,RequestStatus.Expired Expired
	,RequestStatus.[Request Cancellation] Cancelled
	
	from vRxIDPrescriptionandMergedPrescription Prescription
	Join Request rxRequest on Prescription.requestID = rxRequest.RequestID
	Join RequestStatus on RequestStatus .requestID = rxRequest.RequestID
	OUTER APPLY
    ((SELECT TOP 1 wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
    ,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
    ,Translog.WTranslogID ,Translog.Consultant
     FROM wlabel (NOLOCK)
     join Request (NOLOCK) on Wlabel.RequestID = request.requestID
     left Join WTranslog (NOLOCK) Translog
     ON (Translog.RequestID_Dispensing = wlabel.RequestID and TransLog.LabelType = 'I')
     
     where (Translog.WTranslogID in 
     (select  TOP 1 WTranslogID from WTranslog
     where WTranslog.RequestID_Dispensing = wlabel.requestID
     and WTransLog.LabelType = 'I'
     Order by WTranslogID desc)
     or Translog.WTranslogID is null)
     
	  
	and 	Request.RequestID_Parent =Prescription.RequestID
	and  Wlabel.IssType = 'I'
	Order by Translog.WTranslogID desc	
	union
    --Here we want split dose labels on the same last day
    --First those that are issued
    (	SELECT  wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
		,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
		,Translog.WTranslogID ,Translog.Consultant
		FROM wlabel (NOLOCK)
		join Request (NOLOCK) on Wlabel.RequestID = request.requestID
		Join WTranslog (NOLOCK) Translog
		ON Translog.RequestID_Dispensing = wlabel.RequestID 
     
		where Translog.Date =
		(select  TOP 1 Date from WTranslog (NOLOCK)
		--where WTranslog.RequestID_Dispensing = wlabel.requestID
		where WTranslog.RequestID_Prescription = Request.RequestID_Parent
		and WTransLog.LabelType = 'I'
		Order by Date desc)
		--or Translog.Date is null
		and Wlabel.SplitDose = 1
	    and  Wlabel.IssType = 'I'
		and 	Request.RequestID_Parent =Prescription.RequestID
		and TransLog.LabelType = 'I'
		--Order by Translog.WTranslogID desc			
	)
    --second those that arent
    --First those that are issued NO
    union
    (
		SELECT  top 1 wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
		,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
		,Translog.WTranslogID ,Translog.Consultant
		FROM wlabel (NOLOCK)
		join Request (NOLOCK) on Wlabel.RequestID = request.requestID
		left Join WTranslog (NOLOCK) Translog
		ON Translog.RequestID_Prescription = request.RequestID_Parent
     
		where 
		Translog.WTranslogID is null
		and Wlabel.SplitDose = 1
	  
		and	Request.RequestID_Parent =Prescription.RequestID
		and wlabel.IssType = 'I'
		--Order by Translog.WTranslogID desc			
    )
    
    )		
    ) 
	as label
	
	join EpisodeOrder on rxRequest.RequestID = EpisodeOrder.RequestID
	 Join Episode on Episode.EpisodeID = EpisodeOrder.EpisodeID	
	 --left join location on ( isnull(([icwsys].fEpisodeLocation(Episode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(Episode.EpisodeID,'Outpatient Location') )) = location.LocationID )
     --left join LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) and wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) and wa.Description = 'WWardCodes'        --******************** XN Should this be a JOIN not a LEFT JOIN
	 left Join Person on Person.EntityID=Episode.EntityID
	 left join EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) and CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) and i.Description = 'CaseNumber'        --******************** XN Should this be a JOIN not a LEFT JOIN
     left Join Patient on Patient.EntityID=Episode.EntityID	
     join Episode PatientEpisode on PatientEpisode.EpisodeID = icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
     left join location on ( isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location') )) = location.LocationID )
     left join LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) and wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) and wa.Description = 'WWardCodes'        --******************** XN Should this be a JOIN not a LEFT JOIN
	 left join Person con on ( [icwsys].fConsultantByEpisode(Episode.EpisodeID) = con.EntityID )
	 --left join (select d.entityID,d.alias , Person.Forename, Person.Surname,Person.title from entityalias d 
	 --			   join Person on person.EntityID = d.EntityID
	 --			   join aliasgroup e on d.aliasgroupid = e.aliasgroupid 
     --			   where e.description = 'WConsultantCodes' and d.[default] = 1) con on con.Alias = label.Consultant                                                                      
    	
	 where
     [icwsys].[fDiscontinuationStatus] (RxRequest.requestID) is null
     --and    Episode.EpisodeID = icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
     --TFS 104520 Only return where we have a last issued qty > 0 
     and Cancelled = 0 
     and cast(label.qty as float) > 0
     AND	(Prescription.StopDate IS NULL OR Prescription.StopDate > GETDATE()) 
     and Expired = 0
     
GO

exec pDrop 'vRxPrescriptionManagerPrintingOutpatient'
GO

CREATE  view [vRxPrescriptionManagerPrintingOutpatient] as


    
Select	RxRequest.[Description] Rxdescription,Prescription.startdate RxStartDate,Prescription.StopDate RxStopDate, Label.[text]
,Label.[Qty]
, wardAlias.Alias EpisodeWardCode,location.[description] WardDescription
,Label.Ward TranslogWard
, CaseNoAlias.Alias CaseNumber,Person.Forename ForeName,Person.Surname Surname 
, Patient.DOB DOB,Label.logdatetime LastIssuedDate,Label.Kind TransactionStatus, Label.LabelType LabelType
	,[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
	,Label.Splitdose
	,Label.Consultant
	,con.Title + ' ' + con.Forename + ' ' + con.Surname ConsultantName
    ,RequestStatus.Expired Expired
	,RequestStatus.[Request Cancellation] Cancelled
	
	from vRxIDPrescriptionandMergedPrescription Prescription
	Join Request rxRequest on Prescription.requestID = rxRequest.RequestID
	Join RequestStatus on RequestStatus .requestID = rxRequest.RequestID
	OUTER APPLY
    ((SELECT TOP 1 wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
    ,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
    ,Translog.WTranslogID ,Translog.Consultant
     FROM wlabel (NOLOCK)
     join Request (NOLOCK) on Wlabel.RequestID = request.requestID
     left Join WTranslog (NOLOCK) Translog
     ON (Translog.RequestID_Dispensing = wlabel.RequestID and TransLog.LabelType = 'O' and Wlabel.IssType= 'O')
     
     where (Translog.WTranslogID in 
     (select  TOP 1 WTranslogID from WTranslog
     where WTranslog.RequestID_Dispensing = wlabel.requestID
     and WTransLog.LabelType = 'O'
     Order by WTranslogID desc)
     or Translog.WTranslogID is null ) --and  Wlabel.IssType = 'O')
     
	  
	and 	Request.RequestID_Parent =Prescription.RequestID
	and  Wlabel.IssType = 'O'
	Order by Translog.WTranslogID desc	
	union
    --Here we want split dose labels on the same last day
    --First those that are issued
    (	SELECT  wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
		,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
		,Translog.WTranslogID ,Translog.Consultant
		FROM wlabel (NOLOCK)
		join Request (NOLOCK) on Wlabel.RequestID = request.requestID
		Join WTranslog (NOLOCK) Translog
		ON Translog.RequestID_Dispensing = wlabel.RequestID 
     
		where Translog.Date =
		(select  TOP 1 Date from WTranslog (NOLOCK)
		--where WTranslog.RequestID_Dispensing = wlabel.requestID
		where WTranslog.RequestID_Prescription = Request.RequestID_Parent
		and WTransLog.LabelType = 'O'
		Order by Date desc)
		--or Translog.Date is null
		and Wlabel.SplitDose = 1
	  
		and 	Request.RequestID_Parent =Prescription.RequestID
		and TransLog.LabelType = 'O'
		and Wlabel.IssType= 'O'
		--Order by Translog.WTranslogID desc			
	)
    --second those that arent
    --First those that are issued NO
    union
    (
		SELECT  top 1 wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
		,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
		,Translog.WTranslogID ,Translog.Consultant
		FROM wlabel (NOLOCK)
		join Request (NOLOCK) on Wlabel.RequestID = request.requestID
		left Join WTranslog (NOLOCK) Translog
		ON Translog.RequestID_Prescription = request.RequestID_Parent
     
		where 
		Translog.WTranslogID is null
		and Wlabel.SplitDose = 1
	  
		and	Request.RequestID_Parent =Prescription.RequestID
		and wlabel.IssType = 'O'
		--Order by Translog.WTranslogID desc			
    )
    
    )		
    ) 
	as label
	
	join EpisodeOrder on rxRequest.RequestID = EpisodeOrder.RequestID
	 Join Episode on Episode.EpisodeID = EpisodeOrder.EpisodeID	
	 --left join location on ( isnull(([icwsys].fEpisodeLocation(Episode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(Episode.EpisodeID,'Outpatient Location') )) = location.LocationID )
     --left join LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) and wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) and wa.Description = 'WWardCodes'        --******************** XN Should this be a JOIN not a LEFT JOIN
	 left Join Person on Person.EntityID=Episode.EntityID
	 left join EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) and CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) and i.Description = 'CaseNumber'        --******************** XN Should this be a JOIN not a LEFT JOIN
     left Join Patient on Patient.EntityID=Episode.EntityID	
     join Episode PatientEpisode on PatientEpisode.EpisodeID = icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
     left join location on ( isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location') )) = location.LocationID )
     left join LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) and wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) and wa.Description = 'WWardCodes'        --******************** XN Should this be a JOIN not a LEFT JOIN
	 left join Person con on ( [icwsys].fConsultantByEpisode(Episode.EpisodeID) = con.EntityID )
	 --left join (select d.entityID,d.alias , Person.Forename, Person.Surname,Person.title from entityalias d 
	 --			   join Person on person.EntityID = d.EntityID
	 --			   join aliasgroup e on d.aliasgroupid = e.aliasgroupid 
     --			   where e.description = 'WConsultantCodes' and d.[default] = 1) con on con.Alias = label.Consultant                                                                      
    	
    	
	 where
     [icwsys].[fDiscontinuationStatus] (RxRequest.requestID) is null
     --and    Episode.EpisodeID = icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
     --TFS 104520 Only return where we have a last issued qty > 0 
     and Cancelled = 0 
     and cast(label.qty as float) > 0
     AND	(Prescription.StopDate IS NULL OR Prescription.StopDate > GETDATE()) 
     and Expired = 0
     
GO


exec pDrop 'vRxPrescriptionManagerPrintingLeave'
GO

CREATE  view [vRxPrescriptionManagerPrintingLeave] as

Select	RxRequest.[Description] Rxdescription,Prescription.startdate RxStartDate,Prescription.StopDate RxStopDate, Label.[text]
,Label.[Qty]
, wardAlias.Alias EpisodeWardCode,location.[description] WardDescription
,Label.Ward TranslogWard
, CaseNoAlias.Alias CaseNumber,Person.Forename ForeName,Person.Surname Surname 
, Patient.DOB DOB,Label.logdatetime LastIssuedDate,Label.Kind TransactionStatus, Label.LabelType LabelType
	,[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
	,Label.Splitdose
	,Label.Consultant
	,con.Title + ' ' + con.Forename + ' ' + con.Surname ConsultantName
    ,RequestStatus.Expired Expired
	,RequestStatus.[Request Cancellation] Cancelled
	from vRxIDPrescriptionandMergedPrescription Prescription
	Join Request rxRequest on Prescription.requestID = rxRequest.RequestID
	Join RequestStatus on RequestStatus .requestID = rxRequest.RequestID
	OUTER APPLY
    ((SELECT TOP 1 wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
    ,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
    ,Translog.WTranslogID ,Translog.Consultant
     FROM wlabel (NOLOCK)
     join Request (NOLOCK) on Wlabel.RequestID = request.requestID
     left Join WTranslog (NOLOCK) Translog
     ON (Translog.RequestID_Dispensing = wlabel.RequestID and TransLog.LabelType = 'L' and Wlabel.IssType= 'L')
     
     where (Translog.WTranslogID in 
     (select  TOP 1 WTranslogID from WTranslog
     where WTranslog.RequestID_Dispensing = wlabel.requestID
     and WTransLog.LabelType = 'L'
     Order by WTranslogID desc)
     or Translog.WTranslogID is null ) --and  Wlabel.IssType = 'O')
     
	  
	and 	Request.RequestID_Parent =Prescription.RequestID
	and  Wlabel.IssType = 'L'
	Order by Translog.WTranslogID desc	
	union
    --Here we want split dose labels on the same last day
    --First those that are issued
    (	SELECT  wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
		,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
		,Translog.WTranslogID ,Translog.Consultant
		FROM wlabel (NOLOCK)
		join Request (NOLOCK) on Wlabel.RequestID = request.requestID
		Join WTranslog (NOLOCK) Translog
		ON Translog.RequestID_Dispensing = wlabel.RequestID 
     
		where Translog.Date =
		(select  TOP 1 Date from WTranslog (NOLOCK)
		--where WTranslog.RequestID_Dispensing = wlabel.requestID
		where WTranslog.RequestID_Prescription = Request.RequestID_Parent
		and WTransLog.LabelType = 'L'
		Order by Date desc)
		--or Translog.Date is null
		and Wlabel.SplitDose = 1
	  
		and 	Request.RequestID_Parent =Prescription.RequestID
		and TransLog.LabelType = 'L'
		and Wlabel.IssType= 'L'
		--Order by Translog.WTranslogID desc			
	)
    --second those that arent
    --First those that are issued NO
    union
    (
		SELECT  top 1 wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
		,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
		,Translog.WTranslogID ,Translog.Consultant
		FROM wlabel (NOLOCK)
		join Request (NOLOCK) on Wlabel.RequestID = request.requestID
		left Join WTranslog (NOLOCK) Translog
		ON Translog.RequestID_Prescription = request.RequestID_Parent
     
		where 
		Translog.WTranslogID is null
		and Wlabel.SplitDose = 1
	  
		and	Request.RequestID_Parent =Prescription.RequestID
		and wlabel.IssType = 'L'
		--Order by Translog.WTranslogID desc			
    )
    
    )		
    ) 
	as label
	
	join EpisodeOrder on rxRequest.RequestID = EpisodeOrder.RequestID
	 Join Episode on Episode.EpisodeID = EpisodeOrder.EpisodeID	
	 --left join location on ( isnull(([icwsys].fEpisodeLocation(Episode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(Episode.EpisodeID,'Outpatient Location') )) = location.LocationID )
     --left join LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) and wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) and wa.Description = 'WWardCodes'        --******************** XN Should this be a JOIN not a LEFT JOIN
	 left Join Person on Person.EntityID=Episode.EntityID
	 left join EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) and CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) and i.Description = 'CaseNumber'        --******************** XN Should this be a JOIN not a LEFT JOIN
     left Join Patient on Patient.EntityID=Episode.EntityID	
     join Episode PatientEpisode on PatientEpisode.EpisodeID = icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
     left join location on ( isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location') )) = location.LocationID )
     left join LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) and wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) and wa.Description = 'WWardCodes'        --******************** XN Should this be a JOIN not a LEFT JOIN
	 left join Person con on ( [icwsys].fConsultantByEpisode(Episode.EpisodeID) = con.EntityID )
	 --left join (select d.entityID,d.alias , Person.Forename, Person.Surname,Person.title from entityalias d 
	 --			   join Person on person.EntityID = d.EntityID
	 --			   join aliasgroup e on d.aliasgroupid = e.aliasgroupid 
     --			   where e.description = 'WConsultantCodes' and d.[default] = 1) con on con.Alias = label.Consultant                                                                      
    	
	 where
     [icwsys].[fDiscontinuationStatus] (RxRequest.requestID) is null
     --and    Episode.EpisodeID = icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
     --TFS 104520 Only return where we have a last issued qty > 0 
     and Cancelled = 0 
     and cast(label.qty as float) > 0
     AND	(Prescription.StopDate IS NULL OR Prescription.StopDate > GETDATE()) 
     and Expired = 0
     
GO


exec pDrop 'vRxPrescriptionManagerPrintingSelfMed'
GO

CREATE  view [vRxPrescriptionManagerPrintingSelfMed] as

Select	RxRequest.[Description] Rxdescription,Prescription.startdate RxStartDate,Prescription.StopDate RxStopDate, Label.[text]
,Label.[Qty]
, wardAlias.Alias EpisodeWardCode,location.[description] WardDescription
,Label.Ward TranslogWard
, CaseNoAlias.Alias CaseNumber,Person.Forename ForeName,Person.Surname Surname 
, Patient.DOB DOB,Label.logdatetime LastIssuedDate,Label.Kind TransactionStatus, Label.LabelType LabelType
	,[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
	,Label.Splitdose
	,Label.Consultant
	,con.Title + ' ' + con.Forename + ' ' + con.Surname ConsultantName
    ,RequestStatus.Expired Expired
	,RequestStatus.[Request Cancellation] Cancelled
	from vRxIDPrescriptionandMergedPrescription Prescription
	Join Request rxRequest on Prescription.requestID = rxRequest.RequestID
	Join RequestStatus on RequestStatus .requestID = rxRequest.RequestID
	OUTER APPLY
    ((SELECT TOP 1 wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
    ,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
    ,Translog.WTranslogID ,Translog.Consultant
     FROM wlabel (NOLOCK)
     join Request (NOLOCK) on Wlabel.RequestID = request.requestID
     left Join WTranslog (NOLOCK) Translog
     ON (Translog.RequestID_Dispensing = wlabel.RequestID and TransLog.LabelType = 'S' and Wlabel.IssType= 'S')
     
     where (Translog.WTranslogID in 
     (select  TOP 1 WTranslogID from WTranslog
     where WTranslog.RequestID_Dispensing = wlabel.requestID
     and WTransLog.LabelType = 'S'
     Order by WTranslogID desc)
     or Translog.WTranslogID is null ) --and  Wlabel.IssType = 'O')
     
	  
	and 	Request.RequestID_Parent =Prescription.RequestID
	and  Wlabel.IssType = 'S'
	Order by Translog.WTranslogID desc	
	union
    --Here we want split dose labels on the same last day
    --First those that are issued
    (	SELECT  wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
		,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
		,Translog.WTranslogID ,Translog.Consultant
		FROM wlabel (NOLOCK)
		join Request (NOLOCK) on Wlabel.RequestID = request.requestID
		Join WTranslog (NOLOCK) Translog
		ON Translog.RequestID_Dispensing = wlabel.RequestID 
     
		where Translog.Date =
		(select  TOP 1 Date from WTranslog (NOLOCK)
		--where WTranslog.RequestID_Dispensing = wlabel.requestID
		where WTranslog.RequestID_Prescription = Request.RequestID_Parent
		and WTransLog.LabelType = 'S'
		Order by Date desc)
		--or Translog.Date is null
		and Wlabel.SplitDose = 1
	  
		and 	Request.RequestID_Parent =Prescription.RequestID
		and TransLog.LabelType = 'S'
		and Wlabel.IssType= 'S'
		--Order by Translog.WTranslogID desc			
	)
    --second those that arent
    --First those that are issued NO
    union
    (
		SELECT  top 1 wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
		,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
		,Translog.WTranslogID ,Translog.Consultant
		FROM wlabel (NOLOCK)
		join Request (NOLOCK) on Wlabel.RequestID = request.requestID
		left Join WTranslog (NOLOCK) Translog
		ON Translog.RequestID_Prescription = request.RequestID_Parent
     
		where 
		Translog.WTranslogID is null
		and Wlabel.SplitDose = 1
	  
		and	Request.RequestID_Parent =Prescription.RequestID
		and wlabel.IssType = 'S'
		--Order by Translog.WTranslogID desc			
    )
    
    )		
    ) 
	as label
	
	join EpisodeOrder on rxRequest.RequestID = EpisodeOrder.RequestID
	 Join Episode on Episode.EpisodeID = EpisodeOrder.EpisodeID	
	 --left join location on ( isnull(([icwsys].fEpisodeLocation(Episode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(Episode.EpisodeID,'Outpatient Location') )) = location.LocationID )
     --left join LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) and wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) and wa.Description = 'WWardCodes'        --******************** XN Should this be a JOIN not a LEFT JOIN
	 left Join Person on Person.EntityID=Episode.EntityID
	 left join EntityAlias CaseNoAlias on ( Episode.EntityID = CaseNoAlias.EntityID ) and CaseNoAlias.[Default] = 1 join AliasGroup i on ( CaseNoAlias.AliasGroupID = i.AliasGroupID ) and i.Description = 'CaseNumber'        --******************** XN Should this be a JOIN not a LEFT JOIN
     left Join Patient on Patient.EntityID=Episode.EntityID	
     join Episode PatientEpisode on PatientEpisode.EpisodeID = icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
     left join location on ( isnull(([icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'ward')) ,( [icwsys].fEpisodeLocation(PatientEpisode.EpisodeID,'Outpatient Location') )) = location.LocationID )
     left join LocationAlias wardAlias on ( location.LocationID = wardAlias.LocationID ) and wardAlias.[default] = 1 join AliasGroup wa on ( wardAlias.AliasGroupID = wa.AliasGroupID ) and wa.Description = 'WWardCodes'        --******************** XN Should this be a JOIN not a LEFT JOIN
	 left join Person con on ( [icwsys].fConsultantByEpisode(Episode.EpisodeID) = con.EntityID )
	 --left join (select d.entityID,d.alias , Person.Forename, Person.Surname,Person.title from entityalias d 
	--			   join Person on person.EntityID = d.EntityID
	--			   join aliasgroup e on d.aliasgroupid = e.aliasgroupid 
    --			   where e.description = 'WConsultantCodes' and d.[default] = 1) con on con.Alias = label.Consultant                                                                      --******************** XN Should this be a JOIN not a LEFT JOIN
    	
	 where
     [icwsys].[fDiscontinuationStatus] (RxRequest.requestID) is null
     --and    Episode.EpisodeID = icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
     --TFS 104520 Only return where we have a last issued qty > 0 
     and Cancelled = 0 
     and cast(label.qty as float) > 0
     AND	(Prescription.StopDate IS NULL OR Prescription.StopDate > GETDATE()) 
     and Expired = 0
     
GO

-- Add to Version Log
INSERT VersionLog ([Type], Description, [Date]) SELECT 'Config', 'PrescriptionManagerPrinting.sql (Oct 14) v4', GETDATE()
GO