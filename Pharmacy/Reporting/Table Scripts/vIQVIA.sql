IF EXISTS(SELECT * FROM sys.views WHERE name = 'vIQVIA')
DROP VIEW vIQVIA

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW dbo.vIQVIA 

AS

(

/*

SQL View to create output for IQVIA Monthly Report

Version Initals	Notes

1.0		GJD		New

*/

SELECT
		T.[Month]
	,	CONVERT(VARCHAR(3),T.[Site]) AS [Site_Number]
	,	S.[Description] AS [Site_Description]
	,	ISNULL(C.Consultant, '') AS [Consulant_Code]
	,	ISNULL(C.ConsultantName, '') AS [Consultant_Description]
	,	T.Ward AS [Ward_Code]
	,	ISNULL(CUS.FullName, '') AS [Ward_Description]
	,	T.Specialty AS [Specialty_Code]
	,	ISNULL(SP.[Description], '') AS [Specialty_Description]
	,	ISNULL(D.DirectorateCode, '') AS [Directorate_Code]
	,	ISNULL(D.[Description], '') AS [Directorate_Description]
	,	CASE WHEN P.StoresDescription = ''
			THEN REPLACE(P.LabelDescription, '!', ' ')
			ELSE REPLACE(P.StoresDescription, '!', ' ')
		END AS [Drug_Description]
	,	CASE WHEN SUPP.SupplierTradeName = ''
			THEN ISNULL(P.TradeName, '')
			ELSE ISNULL(SUPP.SupplierTradeName, '')
		END AS [Tradename]
	,	CONVERT(VARCHAR(10),P.DosesPerIssueUnit) AS [Doses_Per_Issue_Unit]
	,	P.DosingUnits AS [Dosing_Units]
	,	CONVERT(VARCHAR(10),P.ReOrderPacksize) AS [Pack_Size]
	,	CASE T.LabelType
			WHEN 'P' THEN 'S' 
			WHEN 'S' THEN
				CASE WHEN 
					T.Kind = 'S' THEN 'S'
				ELSE 'F'
				END
			ELSE T.LabelType
		END AS [Label_Type]
	,	WTranslogID
	,	CONVERT(VARCHAR(14),T.Qty) AS [Total_Qty]
	,	P.PrintForm AS [Form]
	,	CASE WHEN T.BNFCode LIKE '% %' THEN ''
			ELSE CONVERT(VARCHAR,RTRIM(T.BNFCode)) + '.'
			END AS [BNF_Code]
	,	T.IssueDate
	,	[Site] = (SELECT MIN([SITE]) FROM rSite WHERE [Site] <> 0)
FROM rTranslog T
LEFT JOIN rProduct P ON T.NSVCode = P.NSVCode
LEFT JOIN rProductStock PS ON T.NSVCode = PS.NSVCode AND T.SiteID = PS.LocationID_Site
LEFT JOIN rConsultant C ON T.Consultant = C.Consultant
LEFT JOIN rSpecialty SP ON T.Specialty = SP.SpecialtyCode
LEFT JOIN rSupplierProfile SUPP ON PS.NSVCode = SUPP.NSVCode AND PS.SupCode = SUPP.SupCode AND PS.LocationID_Site = SUPP.LocationID_Site
LEFT JOIN rDirectorate D ON SP.DirectorateCode = D.DirectorateCode
LEFT JOIN rSite S ON T.SiteID = S.LocationID
LEFT JOIN rCustomer CUS ON T.Ward = CUS.CustomerCode AND T.SiteID = CUS.SiteID
 

)

GO
