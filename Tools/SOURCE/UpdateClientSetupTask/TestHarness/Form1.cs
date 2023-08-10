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

            UpdateClientSetupTask task = new UpdateClientSetupTask();
            task.BuildBranch = "Trunk";
            task.BuildNo = "00.11.00.000";
            task.SetupType = 1;
            task.BuildRootPath = @"D:\ICWBuildTmp";
            task.SetupProjectPath = @"D:\SourceCode\Pharmacy\Branches\Features\Web Transport 10.11 - Copy\Installation\Client Setup";
            task.ProductName = "HAP Pharmacy";
            task.Execute();
        }
    }
}
