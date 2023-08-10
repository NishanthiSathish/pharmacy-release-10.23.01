// -----------------------------------------------------------------------
// <copyright file="RTFUtils.cs" company="Ascribe">
// Helper methods for RTF creations
//
// TextToRTFImage
// ==============
// Used to convert text to an RTF image of the text 
// (used for Hong Kong to allow printing out the Chinese name which does not work with highedit and vb6)
// string rtf = RTFUtils.TextToRTFImage("姓名");
// Requires GDI+ to be installed
//      
//	Modification History:
//	01Oct15 XN  Created
//  19Nov15 XN  Fixed possible resource leak 
//  26Apr16 XN  123082 Added FitTextToRectangle 
// </copyright>
// -----------------------------------------------------------------------

namespace ascribe.pharmacy.reportlayer
{
    using System;
    using System.Drawing;
    using System.Drawing.Drawing2D;
    using System.Drawing.Imaging;
    using System.IO;
    using System.Runtime.InteropServices;
    using System.Text;
    using ascribe.pharmacy.shared;
    using ascribe.pharmacy.basedatalayer;

    /// <summary>RTF utility class</summary>
    public class RTFUtils
    {
        /// <summary>Used by GdipEmfToWmfBits. Logical units are mapped to arbitrary units with arbitrarily scaled axes.</summary>
        private const int MM_ANISOTROPIC = 8;

        /// <summary>Used by GdipEmfToWmfBits. Each logical unit is mapped to 0.01 millimeter. Positive x is to the right; positive y is up.</summary>
        private const int MM_HIMETRIC = 3;

        /// <summary>Hundred mm per inch 1 Inch = 2540 (0.01)mm</summary>
        private const int HMM_PER_INCH = 2540;

        /// <summary>twips per inch 1 Twip = 1/1440 Inch</summary>
        private const int TWIPS_PER_INCH = 1440;

        /// <summary>Flags used to when converting Emf to Wmf</summary>
        [Flags]
        private enum EmfToWmfBitsFlags 
        {
            EmfToWmfBitsFlagsDefault = 0x00000000,
            EmfToWmfBitsFlagsEmbedEmf = 0x00000001,
            EmfToWmfBitsFlagsIncludePlaceable = 0x00000002,
            EmfToWmfBitsFlagsNoXORClip = 0x00000004
        }

        /// <summary>gdi+ method to convert EMF to WMF</summary>
        /// <param name="_hEmf">Enhanced meta file handle</param>
        /// <param name="_bufferSize">Buffer size</param>
        /// <param name="_buffer">Buffer mapping</param>
        /// <param name="_mappingMode">Mapping mode</param>
        /// <param name="_flags">Flag</param>
        /// <returns></returns>
        [DllImport("gdiplus.dll")] private static extern uint GdipEmfToWmfBits (IntPtr _hEmf, uint _bufferSize, byte[] _buffer, int _mappingMode, EmfToWmfBitsFlags _flags /*EmfToWmfBitsFlags*/);

        /// <summary>gdi+ to delete enhance meta file handle</summary>
        /// <param name="_hEmf">Enhanced meta file handle</param>
        [DllImport("gdi32.dll")]   private static extern void DeleteEnhMetaFile(IntPtr _hEmf);

        /// <summary>
        /// Covert text to RF image string
        /// Requires a number of settings
        /// System: Pharmacy
        /// Section: TextToRTFImage
        /// 
        /// RTF images are actual embedded WMF in form
        /// {\pict\wmetafile8\picw[n]\pich[n]\picwgoal[n]\pichgoal[n] HexData}
        /// 
        /// used for Hong Kong to allow printing out the Chinese name
        /// </summary>
        /// <param name="text">Text to convert</param>
        /// <returns>RF image string</returns>
        public static string TextToRTFImage(string text)
        {
            if (string.IsNullOrEmpty(text))
            {
                return string.Empty;
            }

            string fontName = SettingsController.Load("Pharmacy", "TextToRTFImage", "FontName",     string.Empty);
            float fontSize  = SettingsController.Load("Pharmacy", "TextToRTFImage", "FontSize",     0.0f);
            int widthPerChar= SettingsController.Load("Pharmacy", "TextToRTFImage", "WidthPerChar", 0);
            int height      = SettingsController.Load("Pharmacy", "TextToRTFImage", "Height",       0);
            int dpi         = SettingsController.Load("Pharmacy", "TextToRTFImage", "DPI",          96);
            float scaleWidth= SettingsController.Load("Pharmacy", "TextToRTFImage", "ScaleWidth",   1f);
            float scaleHeight= SettingsController.Load("Pharmacy", "TextToRTFImage","ScaleHeight",  1f);

            Rectangle rect = new Rectangle(0, 0, widthPerChar * text.Length, height);
            Bitmap bitmap = new Bitmap(rect.Width, rect.Height);
            Metafile metaFile = null;
            IntPtr hmeta = IntPtr.Zero;

            try
            {
                // Draw text onto bitmap (can't right string directly to Metafile as when convert from EMF to WMF Chinese character are not converted_
                bitmap.SetResolution(dpi, dpi);
                using (Graphics graphics = Graphics.FromImage(bitmap))
                {
                    graphics.CompositingQuality = CompositingQuality.HighQuality;
                    graphics.SmoothingMode      = SmoothingMode.HighQuality;
                    graphics.PixelOffsetMode    = PixelOffsetMode.HighQuality;
                    
                    graphics.FillRectangle(Brushes.White, rect);

                    using (Font font = new Font(fontName, fontSize, FontStyle.Regular)) // 19Nov15 XN  Fixed possible resource leak 
                    {
                        graphics.DrawString(text, font, Brushes.Black, rect);
                    }
                }
            
                // Draw the bitmap to the metafile
                using (MemoryStream stream = new MemoryStream())
                {
                    using (Graphics offScreenBufferGraphics = Graphics.FromHwndInternal(IntPtr.Zero))
                    {
                        IntPtr deviceContextHandle = offScreenBufferGraphics.GetHdc();
                        metaFile = new Metafile(stream, deviceContextHandle, rect, MetafileFrameUnit.Pixel, EmfType.EmfOnly);
                        offScreenBufferGraphics.ReleaseHdc();
                    }

                    using (Graphics graphics = Graphics.FromImage(metaFile))
                    {
                        graphics.DrawImage(bitmap, rect);
                    }
                }

                // Convert the enhanced meta file to a standard windows meta file (as rtf can't handle enhanced meta file)

                hmeta = metaFile.GetHenhmetafile();
                uint bufferSize = GdipEmfToWmfBits(hmeta, 0, null, MM_HIMETRIC, EmfToWmfBitsFlags.EmfToWmfBitsFlagsDefault);
                byte[] buffer = new byte[bufferSize];
                GdipEmfToWmfBits(hmeta, bufferSize, buffer, MM_HIMETRIC, EmfToWmfBitsFlags.EmfToWmfBitsFlagsDefault);

                // Convert the WMF to RTF string
                StringBuilder rtf = new StringBuilder();
                rtf.Append(@"{\pict\wmetafile8");
                rtf.AppendFormat(@"\picw{0}",     (int)Math.Round((bitmap.Width  / bitmap.HorizontalResolution) * HMM_PER_INCH));   // Define the size of the image, where[N] is in units of hundredths of millimeters (0.01)mm
                rtf.AppendFormat(@"\pich{0}",     (int)Math.Round((bitmap.Height / bitmap.VerticalResolution  ) * HMM_PER_INCH));
                rtf.AppendFormat(@"\picwgoal{0}", (int)Math.Round(((bitmap.Width * scaleWidth)  / bitmap.HorizontalResolution) * TWIPS_PER_INCH));    // Define the target size of the image, where [N] is in units of twips
                rtf.AppendFormat(@"\pichgoal{0} ",(int)Math.Round(((bitmap.Height* scaleHeight) / bitmap.VerticalResolution  ) * TWIPS_PER_INCH));
                for (int i = 0; i < buffer.Length; ++i)
                {
                    rtf.AppendFormat("{0:X2}", buffer[i]);
                }
                rtf.Append("}");

                return rtf.ToString();
            }
            finally
            {
                if (bitmap != null)
                {
                    bitmap.Dispose();
                }

                if (metaFile != null)
                {
                    metaFile.Dispose();
                }

                if (hmeta != IntPtr.Zero)
                {
                    DeleteEnhMetaFile(hmeta);
                }
            }
        }

        /// <summary>
        /// Crude approximation of Vernier.bas FormatTextNonStd
        /// Tries to fit the text to the rectangle but as this is done on the server it will never be as accurate as client side version
        /// 26Apr16 XN 123082
        /// </summary>
        /// <param name="str">String to alter</param>
        /// <param name="lineBreaks">chars used for line breaks</param>
        /// <param name="fontName">Font name to use</param>
        /// <param name="fontSize">Font size to use</param>
        /// <param name="widthInTwips">Width in twips</param>
        /// <param name="widthInChars">Width in chars</param>
        public static void FitTextToRectangle(ref string str, string lineBreaks, string fontName, float fontSize, int widthInTwips, int widthInChars)
        {
            Rectangle rect = new Rectangle(0, 0, 32767, 32767);
            Bitmap bitmap = new Bitmap(rect.Width, rect.Height);
            StringBuilder output = new StringBuilder();
            var lines = str.Split(new [] { lineBreaks }, StringSplitOptions.None);

            // Get DPI setting from DB
            int dpi = Database.ExecuteSQLScalar<int?>("SELECT [Value] FROM [Setting] WHERE [Key]='DPI' AND [Section]='TextToRTFImage' AND [System]='Pharmacy'") ?? 96;
            bitmap.SetResolution(dpi, dpi);

            using (Font font = new Font(fontName, fontSize))
            {
                using (Graphics graphics = Graphics.FromImage(bitmap))
                {
                    int widthInPixels = (int)(widthInTwips * (1.0 / 1440.0) * graphics.DpiX);

                    for (int c = 0; c < lines.Length; c++)
                    {
                        string l = lines[c];
                        int startPos = 0, endPos = l.Length, tempPos;

                        do
                        {
                            // Limit width to widthInChars splitting on space
                            tempPos = endPos;
                            while ((tempPos - startPos) > widthInChars && tempPos != -1)
                                tempPos = l.LastIndexOf(' ', startPos, tempPos - startPos);
                            if (tempPos != -1)
                                endPos = tempPos;
                        
                            // Limit width to widthInPixels splitting on space
                            tempPos = endPos;
                            while (graphics.MeasureString(l.Substring(startPos, tempPos - startPos), font).Width > widthInPixels && tempPos != -1)
                                tempPos = l.LastIndexOf(' ', startPos, tempPos - startPos);
                            if (tempPos != -1)
                                endPos = tempPos;

                            output.Append(l.Substring(startPos, endPos - startPos));
                            output.Append(lineBreaks);
                        } while (endPos < l.Length);
                    }
                }
            }
            str = output.ToString();
        }
    }
}