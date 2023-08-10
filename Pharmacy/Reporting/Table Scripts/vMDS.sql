/*

MDS View for Reporting

Version		User		Notes
1.0			GJD			New
1.1			GJD			Swapped Therapeutic Indication with Acitivity Treatment Code fields
						Strength, Volume & Pack Size not needed if Stores Description used instead of UPPER(P.ReportGroup)
						Added Gross Cost
						Added IssueDate for use by report filter
						Added embaended version for Report/clarity
1.2			GJD			Added Local identifier logic
1.3			GJD			Use label instead of stores description if stores description is blank
1.4			GJD			Added ReOrderPackSize
						Added CivasAmount Logic
1.5			GJD			Added raw LogDateTime for Report sort
1.6			GJD			Added leading zero to single digit month
						Removed form from [Strength], as per NHS Digital Request
						Switched VAT back to Y/N (instead of prevailing rate), as per NHS Digital request
1.7			GJD			Converted dm+d code to varchar to resolve Excel export issue
1.8			GJD			Changes following internal code review, performance, concise, formatting
						Revised versioning information
						Added NSVcode, SiteID and wTranslogID to view so that it can be linked back to other tables
						Added USerfield1, Userfield2, Userfield3, Therapeuticcode, Ledgercode and Formulary to aid filtering for sites for High Cost Drug Reporting


If making changes, please increment version number field.

*/


IF EXISTS (SELECT * FROM sys.objects WHERE Name = 'vMDS')
BEGIN
	DROP VIEW [dbo].[vMDS]
END

GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vMDS] AS

(
SELECT
		CASE DATEPART(M,TL.IssueDate)
			WHEN 1 THEN '10'
			WHEN 2 THEN '11'
			WHEN 3 THEN '12'
				ELSE '0' +  CONVERT(VARCHAR(1), DATEPART(M,TL.IssueDate)-3)
					END AS [Month],
		CASE WHEN DATEPART(M, TL.IssueDate) >= 4 
			THEN Convert(varchar(2), DATEPART(yy, TL.IssueDate)%1000) +'/' +convert(varchar(2), (DATEPART(yy, TL.IssueDate)+1)%1000) 
				ELSE convert(varchar(2), (DATEPART(yy, TL.IssueDate)-1)%1000) + '/' + convert(varchar(2), DATEPART(yy, TL.IssueDate)%1000)
					END as [Year],
		FORMAT(GETDATE(), 'dd/MM/yyyy HH:mm') as [File Date],
		'' AS [ORGANISATION CODE (CODE OF PROVIDER)],
		'' AS [ORGANISATION CODE (CODE OF COMMISSIONER)],
		'' AS [NHS England Commissioned Service Category],
		TL.NHNumber AS [NHS NUMBER],
		CASE WHEN TL.NHNumber <> '' THEN '' ELSE TL.CaseNo END AS [LOCAL PATIENT IDENTIFIER],
		CONVERT(VARCHAR(10), Pat.DOB, 103) AS [PERSON BIRTH DATE],
		Pat.PostCode AS [POSTCODE OF USUAL ADDRESS],
		'' AS [GENERAL MEDICAL PRACTICE CODE (PATIENT REGISTRATION)],
		'' AS [HOSPITAL PROVIDER SPELL NUMBER],
		'' AS [OUTPATIENT ATTENDANCE IDENTIFIER],
		'' AS [Service Code],
		CASE TL.Kind 
			WHEN 'I' THEN 1
			WHEN 'O' THEN 2
			 ELSE '9' 
				END AS [Issue Type],
		CONVERT(VARCHAR(10), TL.IssueDate, 103) AS [Drug Delivery Date],
		TL.PrescriptionReason AS [Therapeutic Indication],
		'' AS [ACTIVITY TREATMENT FUNCTION CODE],
		CASE P.DMandDReference
			WHEN NULL  THEN 'Not Defined'
				ELSE CONVERT(VARCHAR,P.DMandDReference) END AS [Drug Code],
		CASE WHEN P.StoresDescription LIKE '' THEN REPLACE(P.LabelDescription, '!', ' ') ELSE REPLACE(P.StoresDescription, '!', ' ') END AS [Drug Name],
		'' AS [Drug Mode Of Delivery],
		CASE WHEN NOT EXISTS(SELECT NSVCode FROM rFormula F WHERE F.NSVCODE = TL.NSVCODE) 
			THEN CONVERT(VARCHAR(MAX),P.DosesPerIssueUnit) + ' ' + RTRIM(P.DosingUnits)  
				ELSE NULL 
					END AS [Strength],
		'' AS [Volume],
		P.ReOrderPacksize AS [Pack Size],
		CASE WHEN TL.LabelType IN ('T', 'C', 'M') THEN TL.CivasAmount ELSE TL.Qty END AS [Quantity],
		PS.Cost AS [Supplier Unit Price],
		'' AS [Commissioner Unit Price],
		'' AS [Home Delivery Charge],
		CASE WHEN TL.TaxRate = 0
			THEN 'N'
				ELSE 'Y' END AS [VAT Rate*],
		TL.Cost/100 AS [Total Cost],
		CONVERT(DATE,TL.LogDateTime) AS [IssueDate],
		TL.LogDateTime,
		P.NSVCode,
		TL.[SiteID],
		TL.wTranslogID,
		PS.Userfield1,
		PS.Userfield2,
		PS.Userfield3,
		PS.TherapeuticCode,
		PS.LedgerCode,
		PS.Formulary,
		'V1.8' AS [Version]
FROM rTranslog TL
LEFT JOIN rPatients Pat ON TL.PatId = Pat.PatID 
JOIN rProduct P ON TL.NSVCode = P.NSVCode 
JOIN rProductStock PS ON P.NSVCode = PS.NSVCode AND TL.Siteid = PS.LocationID_Site
JOIN rSupplierProfile SP ON PS.NSVCode = SP.NSVCode AND PS.LocationID_Site = SP.LocationID_Site AND PS.SupCode = SP.SupCode
WHERE
	(TL.Kind = 'S' AND TL.LabelType <> 'S') OR
	 TL.Kind IN ('O', 'L', 'D', 'I') 
)


GO