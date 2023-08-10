using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Text;
using System.Windows.Forms;

namespace DBUpdate
{
    public partial class DBUpdate : Form
    {
        private int CommandTimout { 
            get {
                int commandTimeout;
                var configValue = ConfigurationManager.AppSettings["CommandTimeout"];

                return int.TryParse(configValue, out commandTimeout) ? commandTimeout : 30;
            }
        }

        private object oGFConfig = new object();

        public DBUpdate()
        {
            InitializeComponent();
        }

        public void GFConfigObject(object oGF)
        {
            oGFConfig = oGF;
        }

        private void button1_Click(object sender, EventArgs e)
        {
            this.Close();
        }

        private void btnUpdate_Click(object sender, EventArgs e)
        {

            // Create an independant connection based on info on form.
            StringBuilder sb = new StringBuilder("Data Source=");
            sb.Append(txbServer.Text);
            sb.Append(";Initial Catalog=");
            sb.Append(txbDatabase.Text);
            sb.Append(";User ID=");
            sb.Append(txbDBOwner.Text);
            sb.Append(";Password=");
            sb.Append(txbPassword.Text);
            SqlConnection Conn = new SqlConnection(sb.ToString());
            
            SqlCommand cmd = new SqlCommand();
            cmd.CommandType = CommandType.Text;
            cmd.Connection = Conn;
            cmd.CommandTimeout = CommandTimout;
            try
            {
                Conn.Open();

            }
            catch
            {
                txbMessage.Text = "Unable to connect to database.\r\n" + txbMessage.Text;
                MessageBox.Show("Unable to connect to database.\r\nIncorrect password?");
                return;
            }
           
            bool bolNoFile = true;
            
            this.Refresh();
            string[] dirList = null;
            try
            {
                dirList = Directory.GetFiles(txbScriptFolder.Text);
            }
            catch
            {
                //MessageBox.Show(((txbScriptFolder.Text.Length==0) ? "Please select script folder!" : "Invalid script folder!"));
                txbMessage.Text = "Connection is OK. No script folder selected.\r\n\r\n" + txbMessage.Text;
                txbScriptFolder.Focus();
                return;
            }
            
            // Run the .sql script files.
            for (int i = 0; i <= dirList.Length - 1; i++)
            {
                //if (dirList[i].IndexOf(".sql") > 0) XN 19May14 78935 allow to handle upper and lower case .SQL names
                if (dirList[i].EndsWith(".sql", StringComparison.InvariantCultureIgnoreCase))
                {
                    try
                    {
                        runSQLScriptFile(cmd, @dirList[i].ToString());
                        bolNoFile = false;
                    }
                    catch
                    {
                        txbMessage.Text = "Unable to execute script " + dirList[i].ToString() + "\r\n" + txbMessage.Text;
                    }

                }
            }

            // Populate tables with xml files.
            for (int k = 0; k <= dirList.Length - 1; k++)
            {
                FileInfo fi = new FileInfo(dirList[k]);
                if (fi.Extension.ToUpper() == ".XML")
                {
                    string theTable = fi.Name.Substring(0, fi.Name.Length - 4);
                    //txbMessage.Text = "Truncating Table - " + theTable + "\r\n" + txbMessage.Text;
                    
                    //Truncate the table.
                    cmd.CommandText = "TRUNCATE TABLE " + theTable;
                    try
                    {
                        cmd.ExecuteNonQuery();
                        //txbMessage.Text = theTable + " truncated.\r\n" + txbMessage.Text;
                    }
                    catch
                    {
                        txbMessage.Text = "Error in truncating table " + theTable + "\r\n" + txbMessage.Text;
                    }

                    string strSQL = "SELECT * FROM " + theTable + " WHERE 1 = 0";
                    SqlDataAdapter da = new SqlDataAdapter(strSQL, Conn);
                    DataSet ds = new DataSet();
                    //txbMessage.Text = "Reading xml data into - " + theTable + "\r\n" + txbMessage.Text;
                    ds.ReadXml(fi.FullName.ToString());
                    SqlCommandBuilder cmdBuilder = new SqlCommandBuilder(da);
                    try
                    {
                        da.Update(ds, theTable);
                        txbMessage.Text = "Update " + theTable + " succedded.\r\n\r\n" + txbMessage.Text;
                    }
                    catch
                    {
                        txbMessage.Text = "Unable to update " + theTable + "\r\n\r\n" + txbMessage.Text;
                    }
                    da = null;
                    ds = null;
                }
            }

            Conn.Close();
            Conn = null;

            if (bolNoFile)
            {
                txbMessage.Text = "No .sql or xml files in folder.\r\n\r\n" + txbMessage.Text;
            }
            else
            {
                txbMessage.Text = "Ready.\r\n\r\n" + txbMessage.Text;
            }
        }

        private void Form1_Load(object sender, EventArgs e)
        {
            if (!File.Exists("DBSettings.ini"))
            {
                return;
            }

            DataSet ds = new DataSet();
            ds.ReadXml("DBSettings.ini");

            DataRow[] drServerName = ds.Tables[0].Select("Setting = 'ServerName'");
            DataRow[] drDatabaseName = ds.Tables[0].Select("Setting = 'DatabaseName'");
            DataRow[] drDBOwner = ds.Tables[0].Select("Setting = 'DBOwner'");
            DataRow[] drScriptFolder = ds.Tables[0].Select("Setting = 'ScriptFolder'");

            try
            {
                txbServer.Text = drServerName[0][1].ToString();
                txbDatabase.Text = drDatabaseName[0][1].ToString();
                txbDBOwner.Text = drDBOwner[0][1].ToString();
                txbScriptFolder.Text = drScriptFolder[0][1].ToString();
            }
            catch
            {
            }

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

            string[] strScriptFolder = new string[] { "ScriptFolder", txbScriptFolder.Text };
            dtb.Rows.Add(strScriptFolder);

            ds.Tables.Add(dtb);
            ds.WriteXml("DBSettings.ini");

        }

        private void Form1_Shown(object sender, EventArgs e)
        {
            if (File.Exists("DBSettings.ini"))
            {
                txbPassword.Focus();
            }
        }

        private void btnBrowse_Click(object sender, EventArgs e)
        {
            folderBrowserDialog1.SelectedPath = txbScriptFolder.Text;
            if (folderBrowserDialog1.ShowDialog() == DialogResult.OK)
            {
                txbScriptFolder.Text = folderBrowserDialog1.SelectedPath.ToString();
            }

            txbScriptFolder.Focus();

        }


        private void runSQLScriptFile( SqlCommand cmd, string strFilePath)
        {

            StreamReader sR = File.OpenText(strFilePath);
            string strLine = "";
            string strAllLines = "";
            bool bolHasErrors = false;

            while (!sR.EndOfStream)
            {
                strLine = sR.ReadLine();
                if (strLine.Trim().ToUpper() == "GO")
                {
                    if (strAllLines.Trim().Length > 0)
                    {
                        cmd.CommandText = strAllLines;
                        try
                        {
                            cmd.ExecuteNonQuery();
                        }
                        catch (SqlException sqlErr)
                        {
                            txbMessage.Text = "Error in executing SQL script.\r\n" +
                                strAllLines + "\r\nSQL Server Error Message as follows:\r\n" +
                                sqlErr + "\r\n\r\n" + txbMessage.Text;
                            bolHasErrors = true;
                        }
                    }
                    strAllLines = "";
                }
                else
                {
                    strAllLines = strAllLines + strLine + "\r\n";
                }
            }
            cmd.CommandText = strAllLines;
            try
            {
                if (strAllLines.Trim().Length > 0)
                {
                    cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException sqlErr)
            {
                txbMessage.Text = "Error in executing SQL script.\r\n" +
                    strAllLines + "\r\nSQL Server Error Message as follows:\r\n" +
                    sqlErr + "\r\n\r\n" + txbMessage.Text;
                bolHasErrors = true;
            }
            if (bolHasErrors == false)
            {
                txbMessage.Text = "Execution of script file " + strFilePath + " succedded.\r\n\r\n" + txbMessage.Text;
            }

        }

        private void button1_Click_1(object sender, EventArgs e)
        {
            txbMessage.Clear();
        }
    }
}