// -----------------------------------------------------------------------
// <copyright file="NetProject.cs" company="Ascribe">
// TODO: Update copyright text.
// </copyright>
// -----------------------------------------------------------------------

namespace Ascribe.ICW.BuildTasks
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using System.IO;
using System.Diagnostics;

    /// <summary>
    /// TODO: Update summary.
    /// </summary>
    public class NetProject : Project
    {
        private FileInfo fileInfoSln;

        public NetProject(Target targetParent, FileInfo fileInfoPrjFile, FileInfo fileInfoSln) : base(targetParent, fileInfoPrjFile) 
        {
            this.fileInfoSln = fileInfoSln;
        }

        /// <summary>
        /// Read the "AssemblyName" and release "OutputPath" where the binary for this project lives
        /// </summary>
        protected override void LocateCompatibleBinary()
        {
            string path = this.m_fileInfoPrjFile.DirectoryName + @"\";

            // add out put section of the release path
            int pos = this.FileContents.IndexOf("'Release|");
            if (pos == -1)
                throw new ApplicationException("Failed to find release section in file " + this.FileInfoPrjFile.FullName);
            pos = this.FileContents.IndexOf("<OutputPath>", pos);
            if (pos == -1)
                throw new ApplicationException("Failed to find <OutputPath> section in file " + this.FileInfoPrjFile.FullName);
            path += this.FileContents.Substring(pos + 12, this.FileContents.IndexOf("</OutputPath>", pos) - pos - 12);

            // add the assembly name
            pos = this.FileContents.IndexOf("<AssemblyName>");
            if (pos == -1)
                throw new ApplicationException("Failed to find <AssemblyName> section in file " + this.FileInfoPrjFile.FullName);
            path += this.FileContents.Substring(pos + 14, this.FileContents.IndexOf("</AssemblyName>", pos) - pos - 14);

            m_fileInfoBinary = new FileInfo(path + ".dll");
        }

        /// <summary>Don't currently need references to be found in .Net projects are there is only 1</summary>
        public override void ReseachReferences()
        {
            m_references = new References();
        }

        /// <summary>Update reference in VBP files and rewrite project file to disk</summary>
        protected override void UpdateReferencesinProjectFile()
        {
            // Replace references in cached VBP text, with newly updated references
            this.m_TargetParent.BuildParent.SendLogMessage( "\tUpdating references." );
        }

        /// <summary>
        /// Commence the building of this project
        /// </summary>
        public override void Make()
        {
            this.m_TargetParent.BuildParent.SendLogMessage( "\r\n" + this.m_fileInfoBinary.FullName );
            this.UpdateReferencesinProjectFile();
            this.Compile();
        }

        /// <summary>Compile this project using vs</summary>
        public override void Compile()
        {
            this.m_TargetParent.BuildParent.SendLogMessage( "\tCompiling..." );

            // Delete old report file any old ones
            FileInfo fileInfoCompileReport = new FileInfo( this.m_fileInfoBinary.DirectoryName + @"\CompilerReport.txt" );
            if( fileInfoCompileReport.Exists )
            {
                fileInfoCompileReport.Delete();
            }

            this.m_TargetParent.BuildParent.SendLogMessage("Removing original binary");
            if(File.Exists(this.BinaryFileInfo.FullName))
            {
                this.m_TargetParent.BuildParent.SendLogMessage("Binary exists");
                File.Delete(this.BinaryFileInfo.FullName);
                File.Delete(this.BinaryFileInfo.FullName.Replace(".dll", ".tlb"));
            }

            this.m_TargetParent.BuildParent.SendLogMessage("Binary remove complete");

            // Spawn VS compiler
            Process process = new Process();
            process.StartInfo.FileName = this.m_TargetParent.BuildParent.FileInfoVS.FullName;
            this.m_TargetParent.BuildParent.SendLogMessage("Beginning compile of '" + this.m_TargetParent.BuildParent.FileInfoVS.FullName + "'");
            this.m_TargetParent.BuildParent.SendLogMessage("Binary dir '" + this.m_fileInfoBinary.DirectoryName);
            this.m_TargetParent.BuildParent.SendLogMessage("Project file '" + this.m_fileInfoPrjFile.FullName);

            process.StartInfo.Arguments = " \"" + this.fileInfoSln.FullName + "\" /build \"Release\" /project \"" + this.FileInfoPrjFile.FullName + "\" /Out \"" + fileInfoCompileReport.FullName + "\"";
            process.StartInfo.CreateNoWindow = true;

            this.m_TargetParent.BuildParent.SendLogMessage("Building with " + process.StartInfo.FileName + " " + process.StartInfo.Arguments);

            process.Start();
            process.WaitForExit();

            // Output report text
            string reportText = string.Empty;
            if (fileInfoCompileReport.Exists)
            {
                reportText = File.ReadAllText(fileInfoCompileReport.FullName);
                this.m_TargetParent.BuildParent.SendLogMessage(reportText);
                fileInfoCompileReport.Delete();
            }
            process.Close();

            if (!string.IsNullOrEmpty(reportText) && !reportText.Contains(" 0 failed"))
                throw new ApplicationException("The following project has failed to build :- " + this.m_fileInfoPrjFile.FullName);
        }
    }
}
