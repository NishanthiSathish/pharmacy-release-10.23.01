using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Diagnostics;
using System.IO;

namespace RunScripts
{
    public partial class Form1 : Form
    {
        public Form1()
        {
            InitializeComponent();
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnUpdate_Click(object sender, EventArgs e)
        {
            bool bolNoFile = true;
            txbMessage.Clear();
            this.Refresh();

            string strParam_Main = "-S " + txbServer.Text + " -d " + txbDatabase.Text + " -U " + txbDBOwner.Text + " -P " + txbPassword.Text + " -n ";
            string[] dirList = Directory.GetFiles(Directory.GetCurrentDirectory());
            string strParam;
            Process p;
            ProcessStartInfo pI = new ProcessStartInfo("osql.exe");
            pI.WindowStyle = ProcessWindowStyle.Hidden;
            for (int i = 0; i <= dirList.Length -1; i++)
            {
                if (dirList[i].IndexOf(".sql") > 0)
                {
                    try
                    {
                        strParam = strParam_Main + "-i " + dirList[i].ToString();
                        pI.Arguments = strParam;
                        p = Process.Start(pI);
                        p.WaitForExit();
                        txbMessage.Text = " Update " + dirList[i].ToString() + (p.ExitCode==0 ? " - Succeeded.\r\n" : " - Failed.\r\n") + txbMessage.Text;
                        txbMessage.Refresh();
                        bolNoFile = false;
                    }
                    catch (Exception ex)
                    {
                        txbMessage.Text = txbMessage.Text + ex.ToString() + "\r\n";
                    }
                
                }

            }
            if (bolNoFile)
            {
                txbMessage.Text = "No files in folder!";
            }
            else
            {
                txbMessage.Text = "Run Completed\r\n" + txbMessage.Text;
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            if (!File.Exists("Settings.ini"))
            {
                return;
            }

            DataSet ds = new DataSet();
            ds.ReadXml("Settings.ini");

            DataRow[] drServerName = ds.Tables[0].Select("Setting = 'ServerName'");
            DataRow[] drDatabaseName = ds.Tables[0].Select("Setting = 'DatabaseName'");
            DataRow[] drDBOwner = ds.Tables[0].Select("Setting = 'DBOwner'");

            txbServer.Text = drServerName[0][1].ToString();
            txbDatabase.Text = drDatabaseName[0][1].ToString();
            txbDBOwner.Text = drDBOwner[0][1].ToString();

        }

        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            DataSet ds = new DataSet();
            DataTable dtb = new DataTable();
            dtb.TableName = "Settings";
            dtb.Columns.Add("Setting");
            dtb.Columns.Add("Values");

            string[] strServerName = new string[] { "ServerName", txbServer.Text };
            dtb.Rows.Add(strServerName);
            
            string[] strDatabaseName = new string[] { "DatabaseName", txbDatabase.Text };
            dtb.Rows.Add(strDatabaseName);

            string[] strDBOwner = new string[] { "DBOwner", txbDBOwner.Text };
            dtb.Rows.Add(strDBOwner);

            ds.Tables.Add(dtb);
            ds.WriteXml("Settings.ini");

        }

        private void Form1_Shown(object sender, EventArgs e)
        {
            if (File.Exists("Settings.ini"))
            {
                txbPassword.Focus();
            }
            txbMessage.Text = "Quick Guide:\r\n===========\r\n\r\n" +
                "Place your SQL scripts in the same folder as the exe. " +
                "Make sure that there are NO SPACES in your path. " +
                "Enter your server name, database name, the database owner and database password. " +
                "The database owner will be sys for Live or dbo for Report. " +
                "The password will be the password for sys or dbo.\r\n\r\nGOOD LUCK from the Underground Team!";
        }

    }
}