-- ============================================================================================================================================================
-- Author:		TH
-- Create date: Feb14
-- Ref:			TFS 84337
-- Description:	Prescription Management Reporting script
-- ============================================================================================================================================================
--28Feb14 TH Prescription Management Reporting script. 


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

exec pDrop 'vRxPrescriptionManagerPrinting'
GO

CREATE  view [vRxPrescriptionManagerPrinting] as

Select	RxRequest.[Description] Rxdescription,Prescription.startdate RxStartDate,Prescription.StopDate RxStopDate, Label.[text]
,Label.[Qty]
, wardAlias.Alias EpisodeWardCode,location.[description] WardDescription
,Label.Ward TranslogWard
, CaseNoAlias.Alias CaseNumber,Person.Forename ForeName,Person.Surname Surname 
, Patient.DOB DOB,Label.logdatetime LastIssuedDate,Label.Kind TransactionStatus, Label.LabelType LabelType
	,[icwsys].fEpisodeType(PatientEpisode.EpisodeID) PatientStatus
	,Label.Splitdose
		

	from vRxIDPrescriptionandMergedPrescription Prescription
	Join Request rxRequest on Prescription.requestID = rxRequest.RequestID
	OUTER APPLY
    ((SELECT TOP 1 wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
    ,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
    ,Translog.WTranslogID 
     FROM wlabel (NOLOCK)
     join Request (NOLOCK) on Wlabel.RequestID = request.requestID
     left Join WTranslog (NOLOCK) Translog
     ON Translog.RequestID_Dispensing = wlabel.RequestID 
     
     where (Translog.WTranslogID in 
     (select  TOP 1 WTranslogID from WTranslog
     where WTranslog.RequestID_Dispensing = wlabel.requestID
     Order by WTranslogID desc)
     or Translog.WTranslogID is null)
     
	  
	and 	Request.RequestID_Parent =Prescription.RequestID
	Order by Translog.WTranslogID desc	
	union
    --Here we want split dose labels on the same last day
    --First those that are issued
    (	SELECT  wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
		,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
		,Translog.WTranslogID 
		FROM wlabel (NOLOCK)
		join Request (NOLOCK) on Wlabel.RequestID = request.requestID
		Join WTranslog (NOLOCK) Translog
		ON Translog.RequestID_Dispensing = wlabel.RequestID 
     
		where Translog.Date =
		(select  TOP 1 Date from WTranslog (NOLOCK)
		--where WTranslog.RequestID_Dispensing = wlabel.requestID
		where WTranslog.RequestID_Prescription = Request.RequestID_Parent
		Order by Date desc)
		--or Translog.Date is null
		and Wlabel.SplitDose = 1
	  
		and 	Request.RequestID_Parent =Prescription.RequestID
		--Order by Translog.WTranslogID desc			
	)
    --second those that arent
    --First those that are issued NO
    union
    (
		SELECT  top 1 wlabel.[Text],wlabel.RequestID,Wlabel.SplitDose,Request.RequestID_Parent
		,Translog.qty,Translog.ward, Translog.logdatetime,Translog.kind,Translog.LabelType
		,Translog.WTranslogID 
		FROM wlabel (NOLOCK)
		join Request (NOLOCK) on Wlabel.RequestID = request.requestID
		left Join WTranslog (NOLOCK) Translog
		ON Translog.RequestID_Prescription = request.RequestID_Parent
     
		where 
		Translog.WTranslogID is null
		and Wlabel.SplitDose = 1
	  
		and	Request.RequestID_Parent =Prescription.RequestID
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
	 where
     [icwsys].[fDiscontinuationStatus] (RxRequest.requestID) is null
     --and    Episode.EpisodeID = icwsys.fLatestOpenChildlessEpisodeIDByEntityID(Patient.EntityID)
     
     
GO

-- Add to Version Log
INSERT VersionLog ([Type], Description, [Date]) SELECT 'Config', 'PrescriptionManagerPrinting.sql (Feb 14) v1', GETDATE()
GO