//===========================================================================
//
//							ColorExtensions.cs
//
//  Provides helper methods for the Color class
//
//  Can lighten or darken colours
//  -----------------------------
//  To lighten a colour by 50% do 
//  Color c = new Color(0, 33, 243, 11);
//  c = c.Ligthen(50);
//
//  Convert vb6 colour to .NET Colour
//  ---------------------------------
//  Converts a vb6 colours to a .NET colour
//  VB6 colours can be in form &Hbgr, or a colour name like red.
//  e.g.
//  string str = "&HF421";
//  Color colour = ColorExtensions.FromVB6(str);
//
//  Convers colour to web colour
//  ----------------------------
//  Converts a colour to a web colour string in format #rgb
//  Color colour = new Color(45,23,12);
//  string background = colour.ToWebColorString();
//
//	Modification History:
//	27Jun13 XN  Written
//  18Aug13 XN  Added FromVb6 and ToWebColourString
//===========================================================================
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;

namespace ascribe.pharmacy.shared
{
    public static class ColorExtensions
    {
        /// <returns>
        /// Crude method to lighten the colour by a percentage.
        /// Higher percentage lighter the colour will be.
        /// </returns>
        public static Color Lighten(this Color value, int percentrage)
        {
            double multi = (double)percentrage / 100;
            double R = (double)value.R + (255.0 - (double)value.R) * multi;
            double G = (double)value.G + (255.0 - (double)value.G) * multi;
            double B = (double)value.B + (255.0 - (double)value.B) * multi;
            return Color.FromArgb(value.A, (int)R, (int)G, (int)B);
        }

        /// <returns>
        /// Crude method to darken the colour by a percentage.
        /// Higher percentage darker the colour will be.
        /// </returns>
        public static Color Darken(this Color value, int percentrage)
        {
            double multi = (double)percentrage / 100;
            double R = (double)value.R + (0.0 - (double)value.R) * multi;
            double G = (double)value.G + (0.0 - (double)value.G) * multi;
            double B = (double)value.B + (0.0 - (double)value.B) * multi;
            return Color.FromArgb(value.A, (int)R, (int)G, (int)B);
        }

        /// <summary>
        /// Converts a vb6 colours to a .NET colour
        /// VB6 colours can be in form &Hbgr, or a colour name like red.
        /// If can't convert the the string will return empty colour (test with function IsEmpty)
        /// </summary>
        public static Color FromVB6(string vb6Color)
        {
            if (StringExtensions.IsNullOrEmptyAfterTrim(vb6Color))
                return new Color();

            Color colour;

            vb6Color = vb6Color.Trim();
            if (vb6Color.StartsWith("&H") || vb6Color.StartsWith("&h"))
            {
                // in format &Hbgr 
                vb6Color = vb6Color.SafeSubstring(2, 6).PadLeft(6, '0');
                int b = Convert.ToInt32(vb6Color.Substring(0, 2), 16);
                int g = Convert.ToInt32(vb6Color.Substring(2, 2), 16);
                int r = Convert.ToInt32(vb6Color.Substring(4, 2), 16);
                colour =Color.FromArgb(r,g,b);
            }
            else
            {
                // Is named colour
                colour = Color.FromName(vb6Color);
                if (!colour.IsKnownColor)
                    colour = new Color();
            }

            return colour;
        }

        /// <summary>Converts colour to web format string e.g. #451245</summary>
        public static string ToWebColorString(this Color color)
        {
            return string.Format("#{0:X2}{1:X2}{2:X2}", color.R, color.G, color.B);
        }
    }
}
