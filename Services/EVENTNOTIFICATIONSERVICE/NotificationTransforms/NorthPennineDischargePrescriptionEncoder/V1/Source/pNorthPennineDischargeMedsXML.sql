if exists (select * from dbo.sysobjects where id = object_id(N'[sys].[pNorthPennineDischargeMedsXML]') and OBJECTPROPERTY(id, N'IsProcedure') = 1)਍ഀ
drop procedure [sys].[pNorthPennineDischargeMedsXML]਍ഀ
GO਍ഀ
਍ഀ
SET QUOTED_IDENTIFIER ON ਍ഀ
GO਍ഀ
SET ANSI_NULLS ON ਍ഀ
GO਍ഀ
਍ഀ
setuser N'sys'਍ഀ
GO਍ഀ
਍ഀ
਍ഀ
਍ഀ
CREATE   procedure pNorthPennineDischargeMedsXML਍ഀ
	( 		@CurrentSessionID int਍ഀ
		,	@EpisodeID int਍ഀ
	)਍ഀ
AS਍ഀ
select Request.RequestID, Request.TableID from EpisodeOrder ਍ഀ
join Request on EpisodeOrder.RequestID = Request.RequestID਍ഀ
left join RequestCancellation on RequestCancellation.RequestID = Request.RequestID਍ഀ
where EpisodeID = @EpisodeID ਍ഀ
and requesttypeid in (2,5,7,8,9,23) -- All prescription request types਍ഀ
and RequestCancellation.RequestID IS NULL  -- only uncancelled items਍ഀ
and not EpisodeOrder.RequestID in (਍ഀ
-- Exclude any Requests that have a WardStock or PatientsOwn note attached to them਍ഀ
select distinct EpisodeOrder.RequestID from EpisodeOrder਍ഀ
left join RequestLinkAttachedNote on EpisodeOrder.RequestID = RequestLinkAttachedNote.RequestID਍ഀ
left join Note on RequestLinkAttachedNote.NoteID = Note.NoteID਍ഀ
where Note.NoteTypeID in (28, 29)਍ഀ
) ਍ഀ
for XML Auto਍ഀ
਍ഀ
਍ഀ
਍ഀ
਍ഀ
GO਍ഀ
setuser਍ഀ
GO਍ഀ
਍ഀ
SET QUOTED_IDENTIFIER OFF ਍ഀ
GO਍ഀ
SET ANSI_NULLS ON ਍ഀ
GO਍ഀ
਍ഀ
