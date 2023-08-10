using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Xml;
using Ascribe.OrderEntry;
using Ascribe.Common;

public partial class application_OrderEntry_DoseReduction : System.Web.UI.Page
{
	int _SessionID = -1;
	UnitConversion _UnitConversion;
	bool _PageIsValid;
    //09Mar10   Rams    F0079880 -  focus goes to header check box after tabbing out of individual dose adjust box 
    //11Mar10   Rams    F0079880 - (Added the public variable to hold the ReapterItem count
    public int RepeaterCount = -1;
    //
    private const string SCRIPT_DOFOCUS = @"window.setTimeout('DoFocus()', 1);
                                            function DoFocus()
                                            {
                                                try 
                                                {
                                                        document.getElementById('REQUEST_LASTFOCUS').focus();
                                                } catch (ex) {}
                                            }";
    /// <summary>
	/// Handle page load event
	/// </summary>
	/// <param name="sender"></param>
	/// <param name="e"></param>
	protected void Page_Load(object sender, EventArgs e)
	{
		_SessionID = int.Parse(Request.QueryString["SessionID"]);
		_UnitConversion = new UnitConversion(_SessionID);
		if (!IsPostBack)
		{
			txtXML.Text = Generic.SessionAttribute(_SessionID, "OrderEntry/Adjustments");
							
			XmlSource.Data = txtXML.Text;
			XmlSource.GetXmlDocument().LoadXml(txtXML.Text);
			XmlDocument xmldoc = XmlSource.GetXmlDocument();
			XmlNodeList xmlnodelist = xmldoc.SelectNodes("//rx");
			foreach (XmlElement xmlele in xmlnodelist)
			{
                // Set default values for any data missing from prescribing (mostly unit names)
				
				// Original
				if (xmlele.GetAttribute("Unit") == "null" || xmlele.GetAttribute("Unit").Length == 0)
				{
					xmlele.SetAttribute("Unit", _UnitConversion.GetUnitDefinitionByID(uint.Parse(xmlele.GetAttribute("UnitID"))).Abbreviation);
				}
				if (xmlele.GetAttribute("UnitID") == "null" || xmlele.GetAttribute("UnitID").Length == 0)
				{
					xmlele.SetAttribute("UnitID", _UnitConversion.GetUnitDefinitionByAbbreviation(xmlele.GetAttribute("Unit")).UnitID.ToString());
				}
				
				// Calculation
				if (xmlele.GetAttribute("UnitID_Calc") == "null" || xmlele.GetAttribute("UnitID_Calc").Length == 0)
				{
					xmlele.SetAttribute("UnitID_Calc", _UnitConversion.GetUnitDefinitionByAbbreviation(xmlele.GetAttribute("Unit_Calc")).UnitID.ToString());
				}
				if (xmlele.GetAttribute("Unit_Calc") == "null" || xmlele.GetAttribute("Unit_Calc").Length == 0)
				{
					xmlele.SetAttribute("Unit_Calc", _UnitConversion.GetUnitDefinitionByID(uint.Parse(xmlele.GetAttribute("UnitID_Calc"))).Abbreviation );
				}

				// Cap
				if (xmlele.GetAttribute("UnitID_Cap").Length > 0 && double.Parse(xmlele.GetAttribute("UnitID_Cap")) > 0)
				{
					if (xmlele.GetAttribute("UnitID_Cap") == "null" || xmlele.GetAttribute("UnitID_Cap").Length == 0)
					{
						xmlele.SetAttribute("UnitID_Cap", xmlele.GetAttribute("UnitID_Prescribed"));
					}
					if (xmlele.GetAttribute("Unit_Cap") == "null" || xmlele.GetAttribute("Unit_Cap").Trim().Length == 0)
					{
						xmlele.SetAttribute("Unit_Cap", _UnitConversion.GetUnitDefinitionByID(uint.Parse(xmlele.GetAttribute("UnitID_Cap"))).Abbreviation);
					}
				}
				if (xmlele.GetAttribute("Dose_Cap").Length == 0)
				{
					xmlele.SetAttribute("Dose_Cap", "0");
					xmlele.SetAttribute("UnitID_Cap", "0");
				}

				// Rounding
				if (xmlele.GetAttribute("UnitID_Round").Length > 0 && double.Parse(xmlele.GetAttribute("UnitID_Round")) > 0)
				{
					if (xmlele.GetAttribute("UnitID_Round") == "null" || xmlele.GetAttribute("UnitID_Round").Length == 0)
					{
						xmlele.SetAttribute("UnitID_Round", xmlele.GetAttribute("UnitID_Prescribed"));
					}
					if (xmlele.GetAttribute("Unit_Round") == "null" || xmlele.GetAttribute("Unit_Round").Trim().Length == 0)
					{
						xmlele.SetAttribute("Unit_Round", _UnitConversion.GetUnitDefinitionByID(uint.Parse(xmlele.GetAttribute("UnitID_Round"))).Abbreviation);
					}
				}
				if (xmlele.GetAttribute("Dose_Round").Length == 0)
				{
					xmlele.SetAttribute("Dose_Round", "0");
					xmlele.SetAttribute("UnitID_Round", "0");
				}
				
				
				// Re-calculate the "calculated" dose
				double Dose = double.Parse(xmlele.GetAttribute("Dose"));
				double Dose_Low = double.Parse(xmlele.GetAttribute("Dose_Low"));
				uint UnitID = uint.Parse(xmlele.GetAttribute("UnitID"));
				uint RoutineID = uint.Parse(xmlele.GetAttribute("RoutineID"));
				double Dose_Calc = 0;
				double Dose_Low_Calc = 0;
				uint UnitID_Calc = 0;
				string Unit_Calc = "";
				double Dose_Cap = double.Parse(xmlele.GetAttribute("Dose_Cap"));
				uint UnitID_Cap = uint.Parse(xmlele.GetAttribute("UnitID_Cap"));
				double Dose_Round = double.Parse(xmlele.GetAttribute("Dose_Round"));
				uint UnitID_Round = uint.Parse(xmlele.GetAttribute("UnitID_Round"));
				string Calc_XML = "";
				bool CapExeeded = false;
				XmlDocument xmldocCalc = new XmlDocument();
				
				switch (xmlele.GetAttribute("RxType"))
				{
					case "Standard":
						Calc_XML = Ascribe.Common.Dss.DssShared.CalculateDose(_SessionID, Dose, Dose_Low, (int)RoutineID);
						xmldocCalc.LoadXml(Calc_XML);
						
						Dose_Calc = double.Parse(xmldocCalc.SelectSingleNode("ascribe_dss_calculation/value").InnerText);
						if (xmldocCalc.SelectNodes("ascribe_dss_calculation/valuelow").Count>0)
						{
							Dose_Low_Calc = double.Parse(xmldocCalc.SelectSingleNode("ascribe_dss_calculation/valuelow").InnerText);
						}

						// Now re-use CalculateAdjustedDose, with an adjustment of zero, to perform the rounding and capping
						CalculateAdjustedDose(UnitID,
												0,
												Dose_Calc, UnitID,
												Dose_Cap, UnitID_Cap,
												Dose_Round, UnitID_Round,
                                                false,      // pass in false here as this is just a calculation and not being overridden by the user
												out Dose_Calc, out UnitID_Calc, out Unit_Calc,
												out CapExeeded);

						CalculateAdjustedDose(UnitID,
												0,
												Dose_Low_Calc, UnitID,
												Dose_Cap, UnitID_Cap,
												Dose_Round, UnitID_Round,
                                                false,      // pass in false here as this is just a calculation and not being overridden by the user
												out Dose_Low_Calc, out UnitID_Calc, out Unit_Calc,
												out CapExeeded);

						xmlele.SetAttribute("Dose_Calc", Dose_Calc.ToString());
						xmlele.SetAttribute("Dose_Low_Calc", Dose_Low_Calc.ToString());
						break;
						
					case "Infusion":
						bool blnIsCalculatedDose = true;
						bool blnCalculationSuccess = false;
						string RoutineName = xmlele.GetAttribute("RoutineName");
						Ascribe.Common.Prescription.DoseCalculate_Ingredient(_SessionID, (int)RoutineID, ref Dose, ref blnIsCalculatedDose, ref blnCalculationSuccess, ref RoutineName, ref Calc_XML);
						xmldocCalc.LoadXml(Calc_XML);

						Dose_Calc = double.Parse(xmldocCalc.SelectSingleNode("ascribe_dss_calculation/value").InnerText);

						// Now re-use CalculateAdjustedDose, with an adjustment of zero, to perform the rounding and capping
						CalculateAdjustedDose(UnitID,
												0,
												Dose_Calc, UnitID,
												Dose_Cap, UnitID_Cap,
												Dose_Round, UnitID_Round,
                                                false,      // pass in false here as this is just a calculation and not being overridden by the user
												out Dose_Calc, out UnitID_Calc, out Unit_Calc,
												out CapExeeded);

						xmlele.SetAttribute("Dose_Calc", Dose_Calc.ToString());
						break;
				}
				
				// Set adjustment percentage
				double Dose_Prescribed = double.Parse(xmlele.GetAttribute("Dose_Prescribed"));
				double Dose_Low_Prescribed = double.Parse(xmlele.GetAttribute("Dose_Low_Prescribed"));
				uint UnitID_Prescribed = uint.Parse(xmlele.GetAttribute("UnitID_Prescribed"));
				UnitID_Calc= uint.Parse(xmlele.GetAttribute("UnitID_Calc"));
				string AdjustmentText = CalculateAdjustmentPercentage(Dose_Calc, Dose_Low_Calc, UnitID_Calc, Dose_Prescribed, Dose_Low_Prescribed, UnitID_Prescribed);
				xmlele.SetAttribute("Adjustment", AdjustmentText.ToString() );

				// Set working attributes
				if (xmlele.GetAttribute("Checked")=="1")
				{
					xmlele.SetAttribute("Checked", "1");
				}
				xmlele.SetAttribute("Cap_Warning", "");

				// Format date
				xmlele.SetAttribute("StartDate", Generic.Date2ddmmccyy(Generic.TDate2Date(xmlele.GetAttribute("StartDate"))) );
			}

            //

			txtXML.Text = xmldoc.OuterXml;

			rpt.DataBind();
			UpdateCheckBoxAll();
		}
		else
		{
            ValidatePage();
		}
        //09Mar10   Rams    F0079880 -  focus goes to header check box after tabbing out of individual dose adjust box
        ScriptManager.RegisterStartupScript(this, typeof(application_OrderEntry_DoseReduction), "ScriptDoFocus", SCRIPT_DOFOCUS.Replace("REQUEST_LASTFOCUS", Request["__LASTFOCUS"]), true);		
	}

	/// <summary>
	/// Handle + and - button clicks, and manual adjustment textbox change events.
	/// </summary>
	/// <param name="source">Repeater control</param>
	/// <param name="e">Useful event info</param>
	protected void rpt_ItemCommand(object source, RepeaterCommandEventArgs e)
	{
		UpdateData();
	}

	/// <summary>
	/// Handle group adjustment button clicks
	/// </summary>
	/// <param name="sender">the group adjustment button</param>
	/// <param name="e">useful event info</param>
	protected void btnGroupAdjust_Click(object sender, EventArgs e)
	{
		AdjustGroup();
	}

	/// <summary>
	/// Set all adjustments the group adjustment field's value
	/// </summary>
	private void AdjustGroup()
	{
		if (txtGroupAdjustment.Text.Length == 0)
		{
			txtGroupAdjustment.Text = "0";
		}
		txtGroupAdjustment.Text = Int32.Parse(txtGroupAdjustment.Text).ToString("+###;-###;0");

		foreach (RepeaterItem ri in rpt.Controls)
		{
			CheckBox chk = (CheckBox)ri.FindControl("chkTick");
			if (chk.Checked)
			{
				TextBox textbox = (TextBox)ri.FindControl("txtAdjustment");
				textbox.Text = txtGroupAdjustment.Text;
			}
		}
		UpdateData();
	}

	/// <summary>
	/// Handle changes to the Group Adjustment value
	/// </summary>
	/// <param name="sender"></param>
	/// <param name="e"></param>
    //protected void txtGroupAdjustment_TextChanged(object sender, EventArgs e)
    //{
    //    AdjustGroup();
    //}

	/// <summary>
	/// Handle change to single Adjustment field
	/// </summary>
	/// <param name="sender"></param>
	/// <param name="e"></param>
	protected void txtAdjustment_TextChanged(object sender, EventArgs e)
	{
		TextBox Adjustment = (TextBox)sender;
		if (Adjustment.Text.Length == 0)
		{
			Adjustment.Text = "0";
		}
		Adjustment.Text = Int32.Parse(Adjustment.Text).ToString("+###;-###;0");
		UpdateData();
	}

	/// <summary>
	/// Handle group checkbox click. Toggle all checks on/off.
	/// </summary>
	/// <param name="sender"></param>
	/// <param name="e"></param>
	protected void chkAll_CheckedChanged(object sender, EventArgs e)
	{
		foreach (RepeaterItem ri in rpt.Controls)
		{
			CheckBox chk = (CheckBox)ri.FindControl("chkTick");
			chk.Checked = chkAll.Checked;
		}
		UpdateData();
	}

	/// <summary>
	/// Handle check click on individual line of grid.
	/// </summary>
	/// <param name="sender"></param>
	/// <param name="e"></param>
	protected void chk_CheckedChanged(object sender, EventArgs e)
	{
        UpdateCheckBoxAll();
		UpdateData();
	}

	/// <summary>
	/// Update the txtXmlData textbox that stores our XML state between page calls
	/// </summary>
	private void UpdateCheckBoxAll()
	{
		bool AllChecked = true;
		foreach (RepeaterItem ri in rpt.Controls)
		{
			CheckBox chk = (CheckBox)ri.FindControl("chkTick");
			if (!chk.Checked)
			{
				AllChecked = false;
				break;
			}
		}
		chkAll.Checked = AllChecked;
	}

	/// <summary>
	/// Update the txtXmlData textbox that stores our XML state between page calls
	/// </summary>
	private void UpdateData()
	{
		XmlSource.Data = txtXML.Text;
		XmlSource.GetXmlDocument().LoadXml(txtXML.Text);
		XmlDocument xmldoc = XmlSource.GetXmlDocument();

		foreach (RepeaterItem ri in rpt.Controls)
		{
			double Adjustment;
			
			double Dose_Calc;
			double Dose_Low_Calc;
			uint UnitID_Calc;
			
			double Dose_Cap;
			uint UnitID_Cap;
			string Unit_Cap;
			
			double Dose_Round;
			uint UnitID_Round;
			
			double Dose_Prescribed;
			double Dose_Low_Prescribed;
			uint UnitID_Prescribed;
			string Unit_Prescribed;

			bool LowDoseCapExeeded = false;
			bool HighDoseCapExeeded = false;
            bool CanOverrideDose = false;

			TextBox txtAdj = (TextBox)ri.FindControl("txtAdjustment");
			string FormOrdinal = ((Label)ri.FindControl("lblFormOrdinal")).Text;
			string ProductID = ((Label)ri.FindControl("lblProductID")).Text;
			CheckBox chk = (CheckBox)ri.FindControl("chkTick");

			XmlElement xmlele = (XmlElement)xmldoc.SelectSingleNode("//rx[@FormOrdinal='" + FormOrdinal + "' and @ProductID='" + ProductID + "' ]");
			xmlele.SetAttribute("Adjustment", txtAdj.Text);
            
			if ( !double.TryParse(txtAdj.Text, out Adjustment) )
			{
				Adjustment = 0;
			}
			Dose_Calc = double.Parse(xmlele.GetAttribute("Dose_Calc"));
			Dose_Low_Calc = xmlele.GetAttribute("Dose_Low_Calc").Length==0 ? 0 : double.Parse(xmlele.GetAttribute("Dose_Low_Calc"));
			UnitID_Calc = uint.Parse(xmlele.GetAttribute("UnitID_Calc"));

			Dose_Cap = xmlele.GetAttribute("Dose_Cap").Length==0 ? 0 : double.Parse(xmlele.GetAttribute("Dose_Cap"));
			UnitID_Cap = uint.Parse(xmlele.GetAttribute("UnitID_Cap"));
			Unit_Cap = xmlele.GetAttribute("Unit_Cap");

			Dose_Round = xmlele.GetAttribute("Dose_Round").Length==0 ? 0 : double.Parse(xmlele.GetAttribute("Dose_Round"));
			UnitID_Round = uint.Parse(xmlele.GetAttribute("UnitID_Round"));

			Dose_Prescribed = double.Parse(xmlele.GetAttribute("Dose_Prescribed"));
			UnitID_Prescribed = uint.Parse(xmlele.GetAttribute("UnitID_Prescribed"));
			Unit_Prescribed = xmlele.GetAttribute("Unit_Prescribed");

            CanOverrideDose = xmlele.GetAttribute("Dose_Cap_Overridable") == "1" ? true : false;

			// Calculate the low dose
			if (xmlele.GetAttribute("Dose_Low_Calc").Length > 0)
			{
				CalculateAdjustedDose(UnitID_Prescribed,   // Modified so that the prescribed dose is always calculated in the same units and the calculated dose
										Adjustment, 
										Dose_Low_Calc, UnitID_Calc, 
										Dose_Cap, UnitID_Cap,
										Dose_Round, UnitID_Round,
                                        CanOverrideDose,
										out Dose_Low_Prescribed, out UnitID_Prescribed, out Unit_Prescribed,
										out LowDoseCapExeeded);
										
				xmlele.SetAttribute("Dose_Low_Prescribed", Dose_Low_Prescribed.ToString());
			}
			// Calculate the (high) dose 
			CalculateAdjustedDose(	UnitID_Prescribed, // If low dose is specified, then force the unit of the high dose to be "UnitID_Prescribed"
									Adjustment,
									Dose_Calc, UnitID_Calc,
									Dose_Cap, UnitID_Cap,
									Dose_Round, UnitID_Round,
                                    CanOverrideDose,
									out Dose_Prescribed, out UnitID_Prescribed, out Unit_Prescribed,
									out HighDoseCapExeeded);
									
			xmlele.SetAttribute("Dose_Prescribed", Dose_Prescribed.ToString());
			xmlele.SetAttribute("UnitID_Prescribed", UnitID_Prescribed.ToString());
			xmlele.SetAttribute("Unit_Prescribed", Unit_Prescribed);

			// Set cap warning
			if (xmlele.GetAttribute("Dose_Cap_Overridable") == "0" && HighDoseCapExeeded)
			{
				xmlele.SetAttribute("Cap_Warning", "<br/>(Dose cannot<br/>exceed " + Dose_Cap.ToString() + Unit_Cap + ")");
			}
			else
			{
				xmlele.SetAttribute("Cap_Warning", "");
			}

			xmlele.SetAttribute("Checked", chk.Checked ? "1" : "0");
		}

		txtXML.Text = xmldoc.OuterXml;

		rpt.DataBind();
	}

	/// <summary>
	/// Adjust the dose, taking into account capping and rounding
	/// </summary>
	private void CalculateAdjustedDose(
										uint UnitID_ForceConversion,
										double Adjustment, 
										double Dose_Calc, uint UnitID_Calc, 
										double Dose_Cap, uint UnitID_Cap,
										double Value_Round, uint UnitID_Round, 
                                        bool CanOverrideDose,
										out double Dose_Prescribed, out uint UnitID_Prescribed, out string Unit_Prescribed,
										out bool DoseCapExeeded
									  )
	{
		UnitConversion.UnitConversionResult ucr;

		// Start by converting all unit to a common "base" unit so that simple comparisions can be performed 
		// on them without worrying about them being in different unit magnitudes.

		// Calculated dose
		ucr = _UnitConversion.ConvertToBaseUnit(Dose_Calc, UnitID_Calc);
		Dose_Calc = ucr.ConvertedValue;
		UnitID_Calc = ucr.UnitDefinition.UnitID;

		// Perform adjustment by taking the calculated case as the base, then adjusting it by the adjustment percentage
		Dose_Prescribed = Dose_Calc + Dose_Calc * Adjustment / 100;

		if (Value_Round > 0)
		{
			// Round dose
			ucr = _UnitConversion.ConvertToBaseUnit(Value_Round, UnitID_Round);
			Value_Round = ucr.ConvertedValue;
			UnitID_Round = ucr.UnitDefinition.UnitID;

			// Apply rounding (to nearest round multiple)
			Dose_Prescribed = Math.Truncate((Dose_Prescribed + (Value_Round/2)) / Value_Round) * Value_Round;
		}

		DoseCapExeeded = false;
		if (Dose_Cap > 0)		
		{
			// Cap Dose
			ucr = _UnitConversion.ConvertToBaseUnit(Dose_Cap, UnitID_Cap);
			Dose_Cap = ucr.ConvertedValue;
			UnitID_Cap = ucr.UnitDefinition.UnitID;

			// Apply cap
			if (Dose_Prescribed >= Dose_Cap && !CanOverrideDose)
			{
				Dose_Prescribed = Dose_Cap;
				DoseCapExeeded = true;
			}
		}
		
		// Convert result back into appropriate units, or to specified units, if forced units are specified
		if (UnitID_ForceConversion > 0)
		{
			ucr = _UnitConversion.ConvertToSpecifiedUnit(Dose_Prescribed, UnitID_Calc, UnitID_ForceConversion);
		}
		else
		{
			ucr = _UnitConversion.ConvertToSmallestInteger(Dose_Prescribed, UnitID_Calc);
		}
		Dose_Prescribed = ucr.ConvertedValue;
		UnitID_Prescribed = ucr.UnitDefinition.UnitID;
		Unit_Prescribed = ucr.UnitDefinition.Abbreviation;
	}

	/// <summary>
	/// Work out the Adjustment percentage (to the nearest integer) by comparing the dose calculated against the dose prescribed
	/// </summary>
	private string CalculateAdjustmentPercentage(double Dose_Calc, double Dose_Low_Calc, uint UnitID_Calc, double Dose_Prescribed, double Dose_Low_Prescribed, uint UnitID_Prescribed)
	{
		string AdjustmentText = "";
		
		// Convert both doses to base units
		Dose_Calc = _UnitConversion.ConvertToBaseUnit(Dose_Calc, UnitID_Calc).ConvertedValue;
		Dose_Prescribed = _UnitConversion.ConvertToBaseUnit(Dose_Prescribed, UnitID_Prescribed).ConvertedValue;
		Dose_Low_Calc = _UnitConversion.ConvertToBaseUnit(Dose_Low_Calc, UnitID_Calc).ConvertedValue;
		Dose_Low_Prescribed = _UnitConversion.ConvertToBaseUnit(Dose_Low_Prescribed, UnitID_Prescribed).ConvertedValue;
		
		int Adjustment = (int)Math.Round(((Dose_Prescribed - Dose_Calc) / Dose_Calc) * 100);
		int Adjustment_Low = (int)Math.Round(((Dose_Low_Prescribed - Dose_Low_Calc) / Dose_Low_Calc) * 100);

		// If adjustments match then return the adjustment figure. If they differ then return blank.
		if (Dose_Low_Calc==0 || Adjustment == Adjustment_Low)
		{
			// Add plus symbol to positive numbers
			if (Adjustment > 0)
			{
				AdjustmentText += "+";
			}
			AdjustmentText += Adjustment.ToString();
		}
		else
		{
			AdjustmentText = "";
		}

		return AdjustmentText;
	}

	/// <summary>
	/// Close this window, indicating thta adjustments should be made, back to the calling window
	/// </summary>
	protected void btnOk_Click(object sender, EventArgs e)
	{
		if (_PageIsValid)
		{
			string s = txtXML.Text;
			Generic.SessionAttributeSet(_SessionID, "OrderEntry/Adjustments", s); // Note the crazy parameter types on SessionAttributeSet!
			ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Close_Window", "window.returnValue='adjust';self.close();", true);
		}
	}

	/// <summary>
	/// Close this window without doing anything
	/// </summary>
	protected void btnCancel_Click(object sender, EventArgs e)
	{
		ScriptManager.RegisterClientScriptBlock(this, this.GetType(), "Close_Window", "window.returnValue='cancel';self.close();", true);
	}
	
	private void ValidatePage()
	{
		_PageIsValid = true;

		foreach (RepeaterItem ri in rpt.Controls)
		{
			bool AdjustmentIsValid = true;
			CheckBox chk = (CheckBox)ri.FindControl("chkTick");
			Label lbl = (Label)ri.FindControl("lblValid");
			TextBox txt= (TextBox)ri.FindControl("txtAdjustment");

			if (chk.Checked)
			{
				double Adjustment = 0;
				if (!double.TryParse(txt.Text, out Adjustment))
				{
					AdjustmentIsValid = false;
				}
				else if (Adjustment < -100 || Adjustment > 999)
				{
					AdjustmentIsValid = false;
				}
				
				if (AdjustmentIsValid)
				{
					lbl.Text = "";
				}
				else
				{
					lbl.Text = "Ticked items must have an adjustment value must be between -100 and 999";
					_PageIsValid = false;
				}
			}
		}
	}
}
