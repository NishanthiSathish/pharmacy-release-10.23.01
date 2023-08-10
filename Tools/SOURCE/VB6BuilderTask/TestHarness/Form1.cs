using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Ascribe.ICW.BuildTasks;

namespace TestHarness
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            VB6BuilderTask builder = new VB6BuilderTask();
            builder.BuildBranch="Trunk"; 
            builder.BuildBuildNo="00.11.00.00"; 
            builder.VB6Path=@"C:\Program Files (x86)\Microsoft Visual Studio\VB98\vb6.exe";
            builder.VSPath = @"C:\Program Files (x86)\Microsoft Visual Studio 10.0\Common7\IDE\devenv.com";
            builder.SourceFolder = @"D:\Temp\Trunk";
            builder.TargetFolder = @"D:\ICWBuildTmp";
            builder.UseSourceSafe=false; 
            builder.Stage = 1;

            builder.Execute();
        }
    }
}
