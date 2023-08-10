using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using ascribe.pharmacy.shared;
using ascribe.pharmacy.parenteralnutritionlayer;
using System.Web.UI.WebControls;

/// <summary>
/// Summary description for PNSettingsProcessor
/// </summary>
public static class PNSettingsProcessor
{
    public static bool RangeValidationPNRule(PNRuleColumnInfo columnInfo, WebControl input, Label errorLabel, string parameterName, RuleType ruleType)
    {
        string error;
        bool ok = true;

        switch (parameterName.ToLower())
        {
            case "rulenumber":
                if (!Validation.ValidateText(input, string.Empty, typeof(int), true, 0, 9999, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;

            case "description":
                if (!Validation.ValidateText(input, "Description", typeof(string), true, columnInfo.DescriptionLength, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;

            case "explanation":
                if (!Validation.ValidateText(input, "Explanation", typeof(string), (ruleType == RuleType.RegimenValidation), columnInfo.ExplanationLength, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;

            case "rulesql":
                if (!Validation.ValidateText(input, "Rule SQL", typeof(string), (ruleType == RuleType.RegimenValidation), out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;

            case "info":
                if (!Validation.ValidateText(input, "DSS Info", typeof(string), false, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;
        }

        return ok;
    }

    public static bool RangeValidationPNProduct(PNProductColumnInfo columnInfo, WebControl input, Label errorLabel, string parameterName, string ingredientName)
    {
        string error;
        bool ok = true;

        switch (parameterName.ToLower())
        {
            case "description":
                if (!Validation.ValidateText(input, "Description", typeof(string), true, columnInfo.DescriptionLength, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;
            case "pncode":
                if (!Validation.ValidateText(input, string.Empty, typeof(string), true, columnInfo.PNCodeLength, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;
            case "sortindex":
                if (!Validation.ValidateText(input, string.Empty, typeof(int), true, 0, int.MaxValue, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;
            case "premix":
                if (!Validation.ValidateText(input, string.Empty, typeof(int), true, 0, 99999, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;
            case "maxmltotal":
                {
                string val = ((TextBox)input).Text;
                if (!Validation.ValidateText(input, string.Empty, typeof(double), false, 0.0, double.MaxValue, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                else if ( !string.IsNullOrEmpty(val) && double.Parse(val) <= 0.0 )
                {
                    // 12Sep14 XN 95647 If 0 will now display blank (so prevent user from entering 0)
                    errorLabel.Text = "must be greater than 0 or blank";
                    ok = false;
                }
                }
                break;
            case "maxmlperkg":
                {
                string val = ((TextBox)input).Text;
                if (!Validation.ValidateText(input, string.Empty, typeof(double), false, 0.0, double.MaxValue, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                else if ( !string.IsNullOrEmpty(val) && double.Parse(val) <= 0.0 )
                {
                    // 12Sep14 XN 95647 If 0 will now display blank (so prevent user from entering 0)
                    errorLabel.Text = "must be greater than 0 or blank";
                    ok = false;
                }
                }
                break;
            case "spgrav":
                {
                string val = ((TextBox)input).Text;
                if (!Validation.ValidateText(input, string.Empty, typeof(double), false, 0.0, double.MaxValue, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                else if ( !string.IsNullOrEmpty(val) && double.Parse(val) <= 0.0 )
                {
                    // 12Sep14 XN 95647 If 0 will now display blank (so prevent user from entering 0)
                    errorLabel.Text = "must be greater than 0 or blank";
                    ok = false;
                }
                }
                break;
            case "mosmperml":
                // Should also check if 0, but as water can be 0 and the pn code is not passed in this extra check is done externally 12Sep14 XN 95647
                if (!Validation.ValidateText(input, string.Empty, typeof(double), false, 0.0, double.MaxValue, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;
            case "gh2operml":
                {
                string val = ((TextBox)input).Text;
                if (!Validation.ValidateText(input, string.Empty, typeof(double), false, 0.0, double.MaxValue, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                else if ( !string.IsNullOrEmpty(val) && double.Parse(val) <= 0.0 )
                {
                    // 12Sep14 XN 95647 If 0 will now display blank (so prevent user from entering 0)
                    errorLabel.Text = "must be greater than 0 or blank";
                    ok = false;
                }
                }
                break;
            case "stocklookup":
                if (!Validation.ValidateText(input, string.Empty, typeof(string), true, columnInfo.StockLookupLength, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                else if ((input as TextBox).Text.Length < 3)    // 29Jun12 XN Added check for minimum of 3 chars else search routine won't return anything.
                {
                    errorLabel.Text = "Minimum 3 characters";
                    ok = false;
                }
                break;
            case "baxammig":
                if (!Validation.ValidateText(input, string.Empty, typeof(double), true, columnInfo.BaxaMMIgLength, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;
            case "ingredient":
                if (!Validation.ValidateText(input, ingredientName, typeof(double), true, 0.0, double.MaxValue, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;
            case "info":
                if (!Validation.ValidateText(input, "DSS Info", typeof(string), false, out error))
                {
                    errorLabel.Text = error;
                    ok = false;
                }
                break;
        }

        return ok;
    }
}