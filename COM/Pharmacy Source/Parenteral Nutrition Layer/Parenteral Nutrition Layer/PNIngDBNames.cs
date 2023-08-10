//===========================================================================
//
//							     PNIngDBNames.cs
//
//  This class should only contain all ingredients that are used within PN, 
//  and will directly match the list in the PNIngredient table.
//
//  The constants will have the same value as the PNIngredient.DBName field
//
//	Modification History:
//	20Oct11 XN Written
//  23May12 XN Converted Volume_ml to Volume_mL to matche PNIngredient (else get lots of errors)
//===========================================================================
namespace ascribe.pharmacy.parenteralnutritionlayer
{
    public static class PNIngDBNames
    {
        //public static readonly string Volume            = "Volume_ml";
        public static readonly string Volume            = "Volume_mL";          // 23May12 XN Fix for change in SQL script PNIngredients table
        public static readonly string Calories          = "Calories_kcals";
        public static readonly string Nitrogen          = "Nitrogen_grams";
	    public static readonly string Glucose           = "Glucose_grams";
        public static readonly string Fat               = "Fat_grams";
        public static readonly string Sodium            = "Sodium_mmol";
        public static readonly string Potassium         = "Potassium_mmol";
        public static readonly string Calcium           = "Calcium_mmol";
        public static readonly string Magnesium         = "Magnesium_mmol";
        public static readonly string Zinc              = "Zinc_micromol";
        public static readonly string Phosphate         = "Phosphate_mmol";
        public static readonly string InorganicPhosphate= "PhosphateInorganic_mmol";
        public static readonly string OrganicPhosphate  = "PhosphateOrganic_mmol";
        public static readonly string Chloride          = "Chloride_mmol";
        public static readonly string Acetate           = "Acetate_mmol";
        public static readonly string Selenium          = "Selenium_nanomol";
        public static readonly string Copper            = "Copper_micromol";
        public static readonly string Iron              = "Iron_micromol";
        public static readonly string AqueousVitamins   = "AqueousVitamins_mL";
        public static readonly string LipidVitamins     = "LipidVitamins_mL";
        public static readonly string Chromium          = "Chromium_micromol";
        public static readonly string Manganese         = "Manganese_micromol";
        public static readonly string Molybdenum        = "Molybdenum_micromol";
        public static readonly string Iodine            = "Iodine_micromol";
        public static readonly string Fluoride          = "Fluoride_micromol";
        public static readonly string VitaminA          = "Vitamin_A_mcg";
        public static readonly string Thiamine          = "Thiamine_mg";
        public static readonly string Riboflavine       = "Riboflavine_mg";
        public static readonly string Pyridoxine        = "Pyridoxine_mg";
        public static readonly string Cyanocobalamin    = "Cyanocobalamin_mcg";
        public static readonly string Pantothenate      = "Pantothenate_mg";
        public static readonly string Folate            = "Folate_mg";
        public static readonly string Nicotinamide      = "Nicotinamide_mg";
        public static readonly string Biotin            = "Biotin_mcg";
        public static readonly string VitaminC          = "Vitamin_C_mg";
        public static readonly string VitaminD          = "Vitamin_D_mcg";
        public static readonly string VitaminE          = "Vitamin_E_mg";
        public static readonly string VitaminK          = "Vitamin_K_mcg";
        //public static readonly string Protein           = "Protein_grams";    9Sep14 XN removed protien from PN 95647
    }
}
