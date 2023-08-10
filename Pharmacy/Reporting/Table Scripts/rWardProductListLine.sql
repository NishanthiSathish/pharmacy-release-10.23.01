-- =======================================================================================================
-- Author:			Xavier Norman (XN)
-- Amended date:	2Jul14
-- Ref:				88922
-- Description:		Added new rWardProductListLine table this replaces rWardStockListLine
-- =======================================================================================================
-- 24Feb15 XN Removed ToFollow and added IsIssueAdHoc, and IsMultiIssueOnIssueDate

IF OBJECT_ID('rWardProductListLine') IS NOT NULL
	DROP TABLE rWardProductListLine
GO
	
CREATE TABLE rWardProductListLine
(
    [WWardProductListLineID] [int]               NOT NULL,
    [Description]            [varchar](56)           NULL,
    [ScreenPosn]             [int]               NOT NULL,
    [NSVcode]                [varchar](7)        NOT NULL,	    
    [PackSize]               int                     NULL,
    [PrintLabel]             [varchar](1)        NOT NULL,
    [WWardProductListID]     int                 NOT NULL,
    [TopupLvl]               int                     NULL,
    [LastIssue]              [int]                   NULL,
    [LastIssueDate]          [date]                  NULL,
    [DailyIssue]             [int]                   NULL,
    Comment                  [varchar](30)       NOT NULL,
	IsIssueAdHoc			 bit                 NOT NULL,
	IsMultiIssueOnIssueDate  bit                 NOT NULL,
    [SiteID]                 [int]               NULL,
	_Deleted				 bit			     NOT NULL,
)
GO

CREATE NONCLUSTERED INDEX IX_rWardProductListLine_NSVcode_WWardProductListID ON [rWardProductListLine]
(
	[NSVcode] ASC,
	[WWardProductListID] ASC
)
GO