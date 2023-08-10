-- 14Feb13 XN 30286 Added PN to reporting db
-- 09Sep14 XN 95647 removed protein from PN

IF OBJECT_ID('rPNProduct') IS NOT NULL
	DROP TABLE rPNProduct
GO

CREATE TABLE [rPNProduct](
	[PNProductID] [int] NOT NULL,
	[LocationID_Site] [int] NOT NULL,
	[PNCode] [varchar](8) NOT NULL,
	[InUse] [bit] NOT NULL,
	[ForAdult] [bit] NOT NULL,
	[ForPaed] [bit] NOT NULL,
	[Description] [varchar](29) NOT NULL,
	[SortIndex] [int] NOT NULL,
	[PreMix] [int] NOT NULL,
	[AqueousOrLipid] [char](1) NOT NULL,
	[MaxmlTotal] [float] NOT NULL,
	[MaxmlPerKg] [float] NOT NULL,
	[SharePacks] [bit] NOT NULL,
	[BaxaMMIg] [varchar](13) NOT NULL,
	[mOsmperml] [float] NOT NULL,
	[gH2Operml] [float] NOT NULL,
	[SpGrav] [float] NOT NULL,
	[LastModDate] [datetime] NULL,
	[LastModUser] [varchar](3) NOT NULL,
	[LastModTerm] [varchar](15) NOT NULL,
	[Info] [varchar](max) NOT NULL,
	[ContainerVol_mL] [float] NOT NULL,
	[Calories_kcals] [float] NULL,
	[Nitrogen_grams] [float] NULL,
	[Glucose_grams] [float] NULL,
	[Fat_grams] [float] NULL,
	[Sodium_mmol] [float] NULL,
	[Potassium_mmol] [float] NULL,
	[Calcium_mmol] [float] NULL,
	[Magnesium_mmol] [float] NULL,
	[Zinc_micromol] [float] NULL,
	[Phosphate_mmol] [float] NULL,
	[PhosphateInorganic_mmol] [float] NULL,
	[Chloride_mmol] [float] NULL,
	[Acetate_mmol] [float] NULL,
	[Selenium_nanomol] [float] NULL,
	[Copper_micromol] [float] NULL,
	[Iron_micromol] [float] NULL,
	[Chromium_micromol] [float] NULL,
	[Manganese_micromol] [float] NULL,
	[Molybdenum_micromol] [float] NULL,
	[Iodine_micromol] [float] NULL,
	[Fluoride_micromol] [float] NULL,
	[Vitamin_A_mcg] [float] NULL,
	[Thiamine_mg] [float] NULL,
	[Riboflavine_mg] [float] NULL,
	[Pyridoxine_mg] [float] NULL,
	[Cyanocobalamin_mcg] [float] NULL,
	[Pantothenate_mg] [float] NULL,
	[Folate_mg] [float] NULL,
	[Nicotinamide_mg] [float] NULL,
	[Biotin_mcg] [float] NULL,
	[Vitamin_C_mg] [float] NULL,
	[Vitamin_D_mcg] [float] NULL,
	[Vitamin_E_mg] [float] NULL,
	[Vitamin_K_mcg] [float] NULL,
	--[Protein_grams] [float] NULL,		9Sep14 XN 95647 removed protein from PN
	[_RowVersion] [int] NOT NULL,
	[_RowGUID] [uniqueidentifier] NOT NULL,
	[_Deleted] [bit] NOT NULL,
	[StockLookup] [varchar](20) NOT NULL,
 CONSTRAINT [PK_rPNProduct] PRIMARY KEY CLUSTERED 
(
	[PNProductID] ASC
)) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX [IX_rPNProduct_PNProductID] ON [rPNProduct] 
(
    PNProductID
)
GO


