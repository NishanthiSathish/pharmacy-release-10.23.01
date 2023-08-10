'------------------------------------------------------------------------------------------------
'         VERSION.BAS
'         -----------
'
'25Nov97 CKJ Derived from JetVer.Bas and extended to handle file and product version numbers,
'            and the text strings describing the module.
'            Still compatible with the original FVerifyJetVersion ()
'26Nov97 CKJ Fit for alpha testing.
'
'15Feb02 ATW Added FVerifyJetVersionEx to provide more stringent reporting on JET DB Versions.
'------------------------------------------------------------------------------------------------
DefInt A-Z
Option Explicit

'Global Const VFT_UNKNOWN = &H0&
'Global Const VFT_APP = &H1&
'Global Const VFT_DLL = &H2&
'Global Const VFT_DRV = &H3&
'Global Const VFT_FONT = &H4&
'Global Const VFT_VXD = &H5&
'Global Const VFT_STATIC_LIB = &H7&
    
Type VS_FIXEDFILEINFO              'Type returned by VER.DLL GetFileVersionInfo
   wTolLen As Integer
   wValLen As Integer
   szSig As String * 16
   dwSignature As Long             '/* e.g. 0xfeef04bd */
   dwStrucVersion As Long          '/* e.g. 0x00000042 = "0.42" */
   dwFileVersionMS As Long         '/* e.g. 0x00030075 = "3.75" */
   dwFileVersionLS As Long         '/* e.g. 0x00000031 = "0.31" */
   dwProductVersionMS As Long      '/* e.g. 0x00030010 = "3.10" */
   dwProductVersionLS As Long      '/* e.g. 0x00000031 = "0.31" */
   dwFileFlagsMask As Long         '/* = 0x3F for version "0.42" */
   dwFileFlags As Long             '/* e.g. VFF_DEBUG | VFF_PRERELEASE */
   dwFileOS As Long                '/* e.g. VOS_DOS_WINDOWS16 */
   dwFileType As Long              '/* e.g. VFT_DRIVER */
   dwFileSubtype As Long           '/* e.g. VFT2_DRV_KEYBOARD */
   dwFileDateMS As Long            '/* e.g. 0 */
   dwFileDateLS As Long            '/* e.g. 0 */
End Type

' User defined type so we can copy into the type above using LSet
Type fBuffer
   Item As String * 1024
End Type

''32bit declares
''Declare Function GetFileVersionInfo Lib "Version.dll" Alias "GetFileVersionInfoA" (ByVal lptstrFilename As String, ByVal dwhandle As Long, ByVal dwlen As Long, lpData As Any) As Long
''Declare Function GetFileVersionInfoSize Lib "Version.dll" Alias "GetFileVersionInfoSizeA" (ByVal lptstrFilename As String, lpdwHandle As Long) As Long
''Declare Function VerQueryValue Lib "Version.dll" Alias "VerQueryValueA" (pBlock As Any, ByVal lpSubBlock As String, lplpBuffer As Any, puLen As Long) As Long
''Declare Function GetSystemDirectory Lib "kernel32" Alias "GetSystemDirectoryA" (ByVal Path As String, ByVal cbBytes As Long) As Long
''Declare Sub MoveMemory Lib "kernel32" Alias "RtlMoveMemory" (dest As Any, ByVal Source As Long, ByVal Length As Long)
''Declare Function lstrcpy Lib "kernel32" Alias "lstrcpyA" (ByVal lpString1 As String, ByVal lpString2 As Long) As Long

'Declare Function GetFileVersionInfoSize2 Lib "ver.dll" Alias "GetFileVersionInfoSize" (ByVal stFileName As String, ByVal stTmp As String) As Long
Declare Function GetFileVersionInfo2 Lib "ver.dll" Alias "GetFileVersionInfo" (ByVal stFileName As String, ByVal hVersionInfo As Long, ByVal lSize As Long, ByVal stbuf As String) As Integer

Declare Function GetFileVersionInfoSize Lib "Ver.dll" (ByVal lptstrFilename As String, lpdwHandle As Long) As Long
Declare Function GetFileVersionInfo Lib "Ver.dll" (ByVal lptstrFilename As String, ByVal dwhandle As Long, ByVal dwlen As Long, lpData As Any) As Integer
Declare Function VerQueryValue Lib "Ver.dll" (pBlock As Any, ByVal lpSubBlock As String, lplpBuffer As Any, puLen As Integer) As Integer
Declare Function lstrcpy Lib "kernel" (ByVal lpString1 As String, ByVal lpString2 As Long) As Long


'Declare Sub MoveMemory Lib "kernel" Alias "RtlMoveMemory" (dest As Any, ByVal Source As Long, ByVal Length As Long)

'Remaining declares are from Dan Appleman's book - not actually used here
'Declare Function GetFileVersionInfo% Lib "ver.dll" (ByVal lpszFileName$, ByVal handle&, ByVal cbBuf&, ByVal lpvData&)
'Declare Function GetFileVersionInfoSize& Lib "ver.dll" (ByVal lpszFileName$, lpdwHandle&)
'Declare Function VerQueryValue% Lib "ver.dll" (ByVal lpvBlock&, ByVal SubBlock$, lpBuffer&, lpcb%)
'Declare Function lstrcpy& Lib "Kernel" (ByVal lpString1 As Any, ByVal lpString2 As Any)

'Declare Function GetFileResource% Lib "ver.dll" (ByVal lpszFileName$, ByVal lpszResType&, ByVal lpszResID&, ByVal dwFileOffset&, ByVal dwResLen&, ByVal lpvData&)
'Declare Function GetFileResourceSize& Lib "ver.dll" (ByVal lpszFileName$, ByVal lpszResType&, ByVal lpszResID&, dwFileOffset&)
'Declare Function VerFindFile% Lib "ver.dll" (ByVal fl%, ByVal FileName$, ByVal WinDir&, ByVal AppDir$, ByVal CurrDir$, CurDirLen%, ByVal DestDir$, DestDirLen%)
'Declare Function VerInstallFile& Lib "ver.dll" (ByVal fl%, ByVal SrcFile$, ByVal DstFile$, ByVal SrcDir$, ByVal DstDir$, ByVal CurrDir$, ByVal TmpFile$, TmpFileLen%)
'Declare Function VerLanguageName% Lib "ver.dll" (ByVal Lang%, ByVal lpszLang$, ByVal cbLang%)
'Declare Sub hmemcpy Lib "Kernel" (hpvDest As Any, hpvSource As Any, ByVal cbCopy&)
'Declare Sub hmemcpyBynum Lib "Kernel" Alias "hmemcpy" (ByVal hpvDest&, ByVal hpvSource&, ByVal cbCopy&)

Function FVerifyJetVersion ()
'Returns True if Jet 2.5 installed, else returns False
'
'This module demonstrates a technique for determining whether a user has the version
'of the Jet engine that corresponds with the Microsoft Access Service Pack.  The function
'FVerifyJetVersion() retrieves the file version information from MSAJT200.DLL via direct
'Windows API calls and compares the build version of the file with the JET_MINORVERSION
'constant below.  The build version that is being checked should not be confused with the
'information returned from the Version property of the DBEngine object.
'The Init() function should be called by an AUTOEXEC macro to ensure that all users only
'open the database with JET 2.5.  If a user is still using a version of JET prior to 2.5,
'a message will be displayed and Access will quit.  The informational message and shut down
'of the application can be changed or commented out to meet individual needs.
'See the READSRV.TXT file installed with the Service Pack for more details.

Dim JET_FILENAME As String
Dim JET_MINORVERSION As Integer
Dim FileVerLS2&

   JET_FILENAME = "msajt200.dll"
   JET_MINORVERSION = 1100        'This is not the same as the version property from the DBEngine object

   FVerifyJetVersion = False      'v-- use product version
   If GetFileVersionNums(JET_FILENAME, 2, 0, 0, 0, FileVerLS2&, "") Then
         FVerifyJetVersion = (FileVerLS2& > JET_MINORVERSION)
      End If

End Function

Function FVerifyJetVersionEx (o_strReport As String) As Variant

Const JET_FILE1$ = "MSAJT200.DLL"
Const JET_FILE1_BUILDVERSION_FAIL& = 1100
Const JET_FILE1_BUILDVERSION_OPTIMAL& = 2825
Const JET_FILE1_VERSION = "2.50.0.2825"


Const JET_FILE2$ = "MSABC200.DLL"
Const JET_FILE2_VERSION = "2.3.0.0"


Const JET_FILE3$ = "MSAJT112.DLL"
Const JET_FILE3_VERSION = "1.99.0.1605"

Const JET_FILE4$ = "MSAJU200.DLL"
Const JET_FILE4_VERSION = "2.50.0.2819"


Dim lngMajorVersion As Long
Dim lngMinorVersion As Long
Dim lngRevision As Long
Dim lngBuildVersion As Long
Dim strVersion As String

ReDim strFileVersion(1 To 4) As String
ReDim strFileName(1 To 4) As String
Dim intFileCounter As Integer

Dim strHealtHIniFilePath As String
Dim intFileH As Integer
Dim strLine As String
ReDim strItem(0 To 3) As String

Const HEALTH_INI = "HEALTH.INI"

   strFileName(1) = JET_FILE1
   strFileVersion(1) = JET_FILE1_VERSION

   strFileName(2) = JET_FILE2
   strFileVersion(2) = JET_FILE2_VERSION

   strFileName(3) = JET_FILE3
   strFileVersion(3) = JET_FILE3_VERSION

   strFileName(4) = JET_FILE4
   strFileVersion(4) = JET_FILE4_VERSION

   FVerifyJetVersionEx = True
   o_strReport = "XXXXXXXXXXX" & tb & "WWWWWWWWWWW" & tb & "WWWWWWWW" & tb & "WWWWWWWWWW" & tb & "WWWWWWW" & tb & Chr(0)
   
   o_strReport = o_strReport & tb & "Your terminal does not have the recommended Microsoft" & cr
   o_strReport = o_strReport & tb & "Jet database components. It is recommended that you use" & cr
   o_strReport = o_strReport & tb & "both Jet 2.5 and the Year 2000 update for optimal" & cr
   o_strReport = o_strReport & tb & "performance. A report of your file versions is below." & cr & cr
   o_strReport = o_strReport & tb & "You may continue to use the software, but this warning will appear" & cr
   o_strReport = o_strReport & tb & "until this is rectified." & cr
   ' Check for HEALTH.INI and use updated version numbers if required
   strHealtHIniFilePath = AppPathNoSlash() & "\" & HEALTH_INI
   If FileExists(strHealtHIniFilePath) Then
         intFileH = FreeFile
         Open strHealtHIniFilePath For Input As #intFileH
         Do Until EOF(intFileH)
            Line Input #intFileH, strLine
            
            For intFileCounter = 1 To 4
               If InStr(UCase$(strLine), UCase$(strFileName(intFileCounter))) > 0 Then
                     deflines strLine, strItem(), ",(*)", 0, 0
                     If strItem(3) > strFileVersion(intFileCounter) Then strFileVersion(intFileCounter) = strItem(3)
                  End If
            Next
         Loop
      End If
                 
   For intFileCounter = 1 To 4
      If GetFileVersionNums(strFileName(intFileCounter), 2, lngMajorVersion, lngMinorVersion, lngRevision, lngBuildVersion, strVersion) Then
            o_strReport = o_strReport & Chr(13) & "FOUND" & tb & ": " & tb & strFileName(intFileCounter) & tb & " Version: " & tb & strVersion
            If strVersion <> strFileVersion(intFileCounter) Then
                  FVerifyJetVersionEx = False
                  o_strReport = o_strReport & tb & " - WARNING"
                  o_strReport = o_strReport & Chr(13) & "RECOMMEND" & tb & ": " & tb & strFileName(intFileCounter) & tb & " Version: " & tb & strFileVersion(intFileCounter)
               Else
                  o_strReport = o_strReport & tb & " - OK"
               End If
         Else
            o_strReport = o_strReport & Chr(13) & "Unable to check file : " & strFileName(intFileCounter) & " - FAIL"
            FVerifyJetVersionEx = False
         End If
   Next

End Function

Function GetFileVersionNums (filename$, VerType%, VersionMS1&, VersionMS2&, VersionLS1&, VersionLS2&, VersionText$) As Integer
'Given a fully qualified filename$ to any of EXE DLL VBX DRV DIL OCX VXD FON TTF SCR CPL
' and VerType=1 for File details, VerType=2 for Product details;
'returns the full version number as figures and text.
'e.g. Explorer might return  4, 0, 0, 950, "4.0.0.950"

Dim buffer As fBuffer
Dim vInfo As VS_FIXEDFILEINFO
Dim stbuf As String
Dim lSize As Long
Dim lDummy As Long
Dim errCode As Long

   lSize = GetFileVersionInfoSize(filename$, lDummy)               '!!** check size returned
   stbuf = String$(lSize + 1, 0)
   errCode = GetFileVersionInfo2(filename$, 0&, lSize, stbuf)

   If errCode <> 0 Then
         buffer.Item = stbuf
         LSet vInfo = buffer
         If VerType = 1 Then
               VersionMS1& = CInt(vInfo.dwFileVersionMS / &H10000)       'XX.xx.xx.xx
               VersionMS2& = CInt(vInfo.dwFileVersionMS And &HFFFF&)     'xx.XX.xx.xx
               VersionLS1& = CInt(vInfo.dwFileVersionLS / &H10000)       'xx.xx.XX.xx
               VersionLS2& = CInt(vInfo.dwFileVersionLS And &HFFFF&)     'xx.xx.xx.XX
            Else
               VersionMS1& = CInt(vInfo.dwProductVersionMS / &H10000)    'XX.xx.xx.xx
               VersionMS2& = CInt(vInfo.dwProductVersionMS And &HFFFF&)  'xx.XX.xx.xx
               VersionLS1& = CInt(vInfo.dwProductVersionLS / &H10000)    'xx.xx.XX.xx
               VersionLS2& = CInt(vInfo.dwProductVersionLS And &HFFFF&)  'xx.xx.xx.XX
            End If
         VersionText$ = Format$(VersionMS1&) & "." & Format$(VersionMS2&) & "." & Format$(VersionLS1&) & "." & Format$(VersionLS2&)  'XX.XX.XX.XX
         GetFileVersionNums = True      'success
      Else
         VersionMS1& = 0
         VersionMS2& = 0
         VersionLS1& = 0
         VersionLS2& = 0
         VersionText$ = ""
         GetFileVersionNums = False     'not success
      End If

End Function

Function GetFileVersionText (FullFileName$, VerType%, result$, LastItemText$) As Integer
'-------------------------------------------------------------------------------------------
'24Nov97 CKJ Written. Based on the 32 bit example from MS, modified for 16 bit usage.
'Given a fully qualified path name and
'VerType = 0 to 8
'   0 = all items below, separated with crlf
'   1 = "CompanyName"
'   2 = "FileDescription"
'   3 = "FileVersion"
'   4 = "InternalName"
'   5 = "LegalCopyright"
'   6 = "OriginalFileName"
'   7 = "ProductName"
'   8 = "ProductVersion"
'Returns result$ as the text of the item chosen and
'the function returns success as true/false
'LastItemText holds the actual string returned by the last (or only) item requested
'
'
'-------------------------------------------------------------------------------------------
'HOWTO: Retrieve Language and Code Page id Using VerQueryValue
'Last reviewed: July 15, 1997
'Article ID: Q160042 4.00 WINDOWS | WINDOWS NT kbusage kbhowto
'
'The information in this article applies to:
'Standard, Professional, and Enterprise Editions of Microsoft Visual Basic, 32-bit only for
'Windows,, version 4.0
'
'Using the VerQueryValue API, the language identifier and the character set identifier can be
'retrieved from the version-information resource within a file. You can concatenate these two
'identifiers to form a hexadecimal string and pass the string to another VerQueryValue call to
'retrieve the following version information: CompanyName, FileDescription, FileVersion,
'InternalName, LegalCopyright, OriginalFileName, ProductName, and ProductVersion.
'
'This article presents a Visual Basic 4.0 32-bit sample application that retrieves the language
'identifier, the character set identifier, and the information mentioned above for the Windows
'system file, gdi32.dll.
'
'This article also supplements the following Microsoft Knowledge Base article that extracts a
'VS_FIXEDFILEINFO structure from a file's version- information resource:
'   ARTICLE-ID: Q139491
'   TITLE     : How To Use Functions in VERSION.DLL - A 32-bit Sample App
'-------------------------------------------------------------------------------------------
Dim buffer$, strTemp$, LangCharsetString$
Dim rc%, lBufferLen%, resultval%, FirstOne%, LastOne%, i%
Dim dummy As Long, lVerPointer As Long, HexNumber As Long, lDummy As Long
Dim sBuffer() As String

   resultval = False
   result$ = ""
   LastItemText$ = ""

   lBufferLen = GetFileVersionInfoSize(FullFileName, lDummy)
   If lBufferLen < 1 Then result$ = "No Version Info available"

   If result$ = "" Then
         ReDim sBuffer(lBufferLen)
         rc = GetFileVersionInfo(FullFileName, 0&, lBufferLen, sBuffer(0))
         If rc = 0 Then result$ = "GetFileVersionInfo failed"
      End If

   If result$ = "" Then
         rc = VerQueryValue(sBuffer(0), "\VarFileInfo\Translation", lVerPointer, lBufferLen)
         If rc = 0 Then result$ = "VerQueryValue failed"
      End If

   If result$ = "" Then
         'lVerPointer is a pointer to four 4 bytes of Hex number,
         'first two bytes are language id, and last two bytes are code page.
         'However, LangCharsetString$ needs a string of
         '4 hex digits, the first two characters correspond to the
         'language id and last two the last two character correspond
         'to the code page id.
         buffer = String(255, 0)
         dummy = lstrcpy(buffer, lVerPointer)
         buffer = Left$(buffer, InStr(buffer, Chr(0)) - 1) & String$(4, 0)      'returns  09 04 E4 04
         'MsgBox Hex(Asc(buffer)) & " " & Hex(Asc(Mid$(buffer, 2))) & " " & Hex(Asc(Mid$(buffer, 3))) & " " & Hex(Asc(Mid$(buffer, 4)))
         'now juggle round to use chars 2, 1, 4, 3
         HexNumber = Asc(Mid$(buffer, 2)) * &H1000000 + Asc(Mid$(buffer, 1)) * &H10000 + Asc(Mid$(buffer, 4)) * &H100 + Asc(Mid$(buffer, 3))
         
         'ReDim bytebuffer(0 To 63) As Long 'Integer
         'MoveMemory bytebuffer(0), lVerPointer, lBufferLen
         'Call MoveMemory(ByVal bytebuffer1, lVerPointer, lBufferLen)
         'HexNumber = bytebuffer(2) + bytebuffer(3) * &H100 + bytebuffer(0) * &H10000 + bytebuffer(1) * &H1000000
         'bytebuffer1 = buffer
         
         LangCharsetString$ = Hex(HexNumber)
      
         'now we change the order of the language id and code page
         'and convert it into a string representation.
         'For example, it may look like 040904E4
         'Or to pull it all apart:
         '04------        = SUBLANG_ENGLISH_USA
         '--09----        = LANG_ENGLISH
         '----04E4 = 1252 = Codepage for Windows:Multilingual
         Do While Len(LangCharsetString$) < 8
            LangCharsetString$ = "0" & LangCharsetString$
         Loop
      
         ReDim strVersionInfo(1 To 8) As String
         strVersionInfo(1) = "CompanyName"
         strVersionInfo(2) = "FileDescription"
         strVersionInfo(3) = "FileVersion"
         strVersionInfo(4) = "InternalName"
         strVersionInfo(5) = "LegalCopyright"
         strVersionInfo(6) = "OriginalFileName"
         strVersionInfo(7) = "ProductName"
         strVersionInfo(8) = "ProductVersion"
         
         resultval = True                       'now assume success unless problem found
         
         Select Case VerType
            Case 1 To 8
               FirstOne = VerType
               LastOne = VerType
            Case Else
               FirstOne = 1
               LastOne = 8
            End Select
      
         For i = FirstOne To LastOne
            If Len(result$) Then result$ = result$ & Chr$(13) & Chr$(10)
            buffer = String(255, 0)
            strTemp = "\StringFileInfo\" & LangCharsetString$ & "\" & strVersionInfo(i)
            rc = VerQueryValue(sBuffer(0), strTemp, lVerPointer, lBufferLen)
            If rc = 0 Then
               result$ = result$ & "VerQueryValue failed at " & strVersionInfo(i)
               LastItemText$ = ""
               resultval = False
               Exit For
            End If
   
            dummy = lstrcpy(buffer, lVerPointer)
            buffer = Left$(buffer, InStr(buffer, Chr(0)) - 1)
            result$ = result$ & strVersionInfo(i) & ": " & buffer
            LastItemText$ = buffer$
         Next
      End If

   GetFileVersionText = resultval

End Function

