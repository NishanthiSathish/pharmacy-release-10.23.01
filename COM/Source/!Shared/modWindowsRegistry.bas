Attribute VB_Name = "modWindowsRegistry"
Option Explicit
'*****************************************Registry Routines************************************
' All code shamelessly ripped off from the public-domain code bank at www.vb2themax.com
''*********************************************************************************************

Private Declare Function RegCreateKeyEx Lib "advapi32.dll" Alias _
    "RegCreateKeyExA" (ByVal hKey As Long, ByVal lpSubKey As String, _
    ByVal Reserved As Long, ByVal lpClass As Long, ByVal dwOptions As Long, _
    ByVal samDesired As Long, ByVal lpSecurityAttributes As Long, _
    phkResult As Long, lpdwDisposition As Long) As Long

Private Declare Function RegSetValueEx Lib "advapi32.dll" Alias _
    "RegSetValueExA" (ByVal hKey As Long, ByVal lpValueName As String, _
    ByVal Reserved As Long, ByVal dwType As Long, lpData As Any, _
    ByVal cbData As Long) As Long

Private Declare Function RegQueryValueEx Lib "advapi32.dll" Alias _
    "RegQueryValueExA" (ByVal hKey As Long, ByVal lpValueName As String, _
    ByVal lpReserved As Long, lpType As Long, lpData As Any, _
    lpcbData As Long) As Long

Private Declare Function RegOpenKeyEx Lib "advapi32.dll" Alias "RegOpenKeyExA" _
    (ByVal hKey As Long, ByVal lpSubKey As String, ByVal ulOptions As Long, _
    ByVal samDesired As Long, phkResult As Long) As Long
    
Private Declare Function RegCloseKey Lib "advapi32.dll" (ByVal hKey As Long) As _
    Long

Private Declare Function RegEnumKey Lib "advapi32.dll" Alias "RegEnumKeyA" _
    (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpName As String, _
    ByVal cbName As Long) As Long

Private Declare Function RegEnumValue Lib "advapi32.dll" Alias "RegEnumValueA" _
    (ByVal hKey As Long, ByVal dwIndex As Long, ByVal lpValueName As String, _
    lpcbValueName As Long, ByVal lpReserved As Long, lpType As Long, _
    lpData As Any, lpcbData As Long) As Long

Private Declare Function RegDeleteKey Lib "advapi32.dll" Alias "RegDeleteKeyA" _
    (ByVal hKey As Long, ByVal lpSubKey As String) As Long

Private Declare Function RegDeleteValue Lib "advapi32.dll" Alias _
    "RegDeleteValueA" (ByVal hKey As Long, ByVal lpValueName As String) As Long

Private Declare Sub CopyMemory Lib "kernel32" Alias "RtlMoveMemory" (dest As _
    Any, source As Any, ByVal numBytes As Long)

Private Declare Function GetVersion Lib "kernel32" () As Long


Private Const REG_SZ = 1
Private Const REG_EXPAND_SZ = 2
Private Const REG_BINARY = 3
Private Const REG_DWORD = 4
Private Const REG_MULTI_SZ = 7
Private Const ERROR_MORE_DATA = 234

Private Const KEY_READ = &H20019  ' ((READ_CONTROL Or KEY_QUERY_VALUE Or
                          ' KEY_ENUMERATE_SUB_KEYS Or KEY_NOTIFY) And (Not
                          ' SYNCHRONIZE))
Private Const KEY_WRITE = &H20006  '((STANDARD_RIGHTS_WRITE Or KEY_SET_VALUE Or
                           ' KEY_CREATE_SUB_KEY) And (Not SYNCHRONIZE))

'Public Const HKEY_CLASSES_ROOT = &H80000000
'Public Const HKEY_CURRENT_USER = &H80000001
'Public Const HKEY_LOCAL_MACHINE = &H80000002
'Public Const HKEY_USERS = &H80000003
'Public Const HKEY_CURRENT_CONFIG = &H80000005

Public Enum RegistryHive
   HKEY_CLASSES_ROOT = &H80000000
   HKEY_CURRENT_USER = &H80000001
   HKEY_LOCAL_MACHINE = &H80000002
   HKEY_USERS = &H80000003
   HKEY_CURRENT_CONFIG = &H80000005
End Enum

Private Const REG_OPENED_EXISTING_KEY = &H2


'Enumerate values under a given registry key.
'Returns a collection, where each element of the collection is a 3-element array
'of Variants: element(0) is the value name, element(1) is the value's value,
'  element(2) is the type of data type

Function EnumRegistryValuesEx(ByVal hKey As RegistryHive, ByVal KeyName As String) As _
    VBA.Collection
Attribute EnumRegistryValuesEx.VB_Description = "'Enumerate values under a given registry key.\r\n'Returns a collection, where each element of the collection is a 3-element array\r\n'of Variants: element(0) is the value name, element(1) is the value's value,\r\n'  element(2) is the type of data type"
    Dim handle As Long
    Dim index As Long
    Dim valueType As Long
    Dim name As String
    Dim nameLen As Long
    Dim resLong As Long
    Dim resString As String
    Dim dataLen As Long
    Dim valueInfo(0 To 2) As Variant
    Dim retVal As Long
    
    ' initialize the result
    Set EnumRegistryValuesEx = New Collection
    
    ' Open the key, exit if not found.
    If Len(KeyName) Then
        If RegOpenKeyEx(hKey, KeyName, 0, KEY_READ, handle) Then Exit Function
        ' in all cases, subsequent functions use hKey
        hKey = handle
    End If
    
    Do
        ' this is the max length for a key name
        nameLen = 260
        name = Space$(nameLen)
        ' prepare the receiving buffer for the value
        dataLen = 4096
        ReDim resBinary(0 To dataLen - 1) As Byte
        
        ' read the value's name and data
        ' exit the loop if not found
        retVal = RegEnumValue(hKey, index, name, nameLen, ByVal 0&, valueType, _
            resBinary(0), dataLen)
        
        ' enlarge the buffer if you need more space
        If retVal = ERROR_MORE_DATA Then
            ReDim resBinary(0 To dataLen - 1) As Byte
            retVal = RegEnumValue(hKey, index, name, nameLen, ByVal 0&, _
                valueType, resBinary(0), dataLen)
        End If
        ' exit the loop if any other error (typically, no more values)
        If retVal Then Exit Do
        
        ' retrieve the value's name
        valueInfo(0) = Left$(name, nameLen)
        
        ' return a value corresponding to the value type
        Select Case valueType
            Case REG_DWORD
                CopyMemory resLong, resBinary(0), 4
                valueInfo(1) = resLong
                valueInfo(2) = vbLong
            Case REG_SZ, REG_EXPAND_SZ
                ' copy everything but the trailing null char
                resString = Space$(dataLen - 1)
                CopyMemory ByVal resString, resBinary(0), dataLen - 1
                valueInfo(1) = resString
                valueInfo(2) = vbString
            Case REG_BINARY
                ' shrink the buffer if necessary
                If dataLen < UBound(resBinary) + 1 Then
                    ReDim Preserve resBinary(0 To dataLen - 1) As Byte
                End If
                valueInfo(1) = resBinary()
                valueInfo(2) = vbArray + vbByte
            Case REG_MULTI_SZ
                ' copy everything but the 2 trailing null chars
                resString = Space$(dataLen - 2)
                CopyMemory ByVal resString, resBinary(0), dataLen - 2
                valueInfo(1) = resString
                valueInfo(2) = vbString
            Case Else
                ' Unsupported value type - do nothing
        End Select
        
        ' add the array to the result collection
        ' the element's key is the value's name
        EnumRegistryValuesEx.Add valueInfo, valueInfo(0)
        
        index = index + 1
    Loop
   
    ' Close the key, if it was actually opened
    If handle Then RegCloseKey handle
        
End Function



'Save the specified registry's key and (optionally) its subkeys to a REG file
' that can be loaded later
' - hKey is the root key
' - sKeyName is the key to save to the file
' - sRegFile is the target file where the text will be saved
' - bIncludeSubKeys specifies whether the routine will save also the subkeys
' - bAppendToFile specifies wheter the generated text will be appended to an
' existent file
'Example:
'  SaveRegToFile HKEY_CURRENT_USER, "Software\Microsoft\Visual Basic\6.0",
'  "C:\vb6.reg"

'NOTE: this routine requires EnumRegistryKeys and EnumRegistryValuesEx

Sub SaveRegToFile(ByVal hKey As RegistryHive, ByVal sKeyName As String, _
    ByVal sRegFile As String, Optional ByVal bIncludeSubKeys As Boolean = True, _
    Optional ByVal bAppendToFile As Boolean = False)
Attribute SaveRegToFile.VB_Description = "Outputs the specified registry key or tree to a registry export file."
    
    Dim handle As Integer
    Dim sFirstKeyPart As String
    Dim col As New Collection
    Dim regItem As Variant
    Dim sText As String
    Dim sQuote As String
    Dim sTemp As String
    Dim sHex As String
    Dim i As Long
    Dim vValue As Variant
    Dim iPointer As MousePointerConstants
    Dim sValueName As String
    
    sQuote = Chr$(34)
    
    On Error Resume Next
     
    'conver the hKey value to the descriptive string
    Select Case hKey
        Case HKEY_CLASSES_ROOT: sFirstKeyPart = "HKEY_CLASSES_ROOT\"
        Case HKEY_CURRENT_CONFIG: sFirstKeyPart = "HKEY_CURRENT_CONFIG\"
        Case HKEY_CURRENT_USER: sFirstKeyPart = "HKEY_CURRENT_USER\"
        Case HKEY_LOCAL_MACHINE: sFirstKeyPart = "HKEY_LOCAL_MACHINE\"
        Case HKEY_USERS: sFirstKeyPart = "HKEY_USERS\"
    End Select
    
    'this can be a long operation
    iPointer = Screen.MousePointer
    Screen.MousePointer = vbHourglass
    
    'if the text won't be appended, add the "REGEDIT4" header
    If bAppendToFile = False Then
        sText = "REGEDIT4" & vbCrLf & vbCrLf
    Else
        'add the same header if the text will be appended to an
        'existent file that does not contain the header.
        ' This works only if the file exists but is empty.
        handle = FreeFile
        Open sRegFile For Binary As #handle
        ' read the string and close the file
        sTemp = Space$(LOF(handle))
        Get #handle, , sTemp
        Close #handle
        'if not found, add it
        If InStr(1, sTemp, "REGEDIT4") = 0 Then
            sText = "REGEDIT4" & vbCrLf & vbCrLf
        End If
    End If
    
    'save the key name with the format [keyname]
    sText = sText & "[" & sFirstKeyPart & sKeyName & "]" & vbCrLf
    
    'get the collection with all the values under this key
    Set col = EnumRegistryValuesEx(hKey, sKeyName)
    For Each regItem In col
        vValue = regItem(1)
        Select Case regItem(2)
            Case vbString
                'if the value is a string, check if it's a path by looking if
                ' the 3 characters
                'are in the form X:\. If so, replace a single "\" with "\\"
                If Left$(vValue, 3) Like "[A-Z,a-z]:\" Then vValue = Replace _
                    (vValue, "\", "\\")
                'quote it
                sTemp = sQuote & vValue & sQuote
            Case vbLong
                'if it's a long, save it with the format dword:num
                sTemp = "dword:" & CLng(vValue)
            Case vbArray + vbByte
                'if it's an array of bytes, save it with the format hex:num1,
                ' num2,num3,...
                sTemp = "hex:"
                For i = 0 To UBound(vValue)
                    sHex = Hex$(vValue(i))
                    'convert from long to hex
                    If Len(sHex) < 2 Then sHex = "0" & sHex
                    sTemp = sTemp & sHex & ","
                Next
                'remove the last comma
                sTemp = Left$(sTemp, Len(sTemp) - 1)
            Case Else
                sTemp = ""
        End Select
        'get the value name: if the string is empty, take @,
        '  else take that name and quote it
        sValueName = IIf(Len(regItem(0)) > 0, sQuote & regItem(0) & sQuote, "@")
        'save this line to the temporary text that will be saved
        sText = sText & sValueName & "=" & sTemp & vbCrLf
    Next
    sText = sText & vbCrLf
    
    handle = FreeFile
    'open the target file with Append or Output mode,
    '  according to the bAppendToFile parameter
    If bAppendToFile Then
        Open sRegFile For Append As #handle
    Else
        Open sRegFile For Output As #handle
    End If
    'save the text
    Print #handle, sText;
    Close #handle
    
    'call recursively this routine to save all the subkeys,
    '  if the bIncludeSubKeys param is true
    If bIncludeSubKeys Then
        Set col = EnumRegistryKeys(hKey, sKeyName)
        For Each regItem In col
            'note: the text will be added to the file just created for the
            'values in the root key
            SaveRegToFile hKey, sKeyName & "\" & regItem, sRegFile, True, True
        Next
    End If
    
    Screen.MousePointer = iPointer
    
End Sub
' Add or remove a program to the list of applications that will
' be automatically launched when Windows boots.
'
' Action can be:
'      0 = delete from list
'      1 = execute only once
'     ELSE = execute always
' APPTITLE is the name of the key in the system Registry, if omitted
'  the current project's title will be used instead
' APPPATH is the complete path+name of the program that must be launched
'  if omitted the current application path is used
'
' TIP: you might use this routine inside the QueryUnload event, when
' the Windows session is closing, so that you can save the current set of
' data and run again the application in the same state when Windows restarts.
'
' NOTE: uses the SetRegistryValue and DeleteRegistryValue functions

Sub RunAtStartUp(ByVal Action As Integer, Optional ByVal AppTitle As String, _
    Optional ByVal AppPath As String)

    ' This is the key under which you must register the apps
    ' that must execute after every restart
    Const HKEY_CURRENT_USER = &H80000001
    Const regKey = "Software\Microsoft\Windows\CurrentVersion\Run"

    ' provide a default value for AppTitle
    AppTitle = LTrim$(AppTitle)
    If Len(AppTitle) = 0 Then AppTitle = App.Title
    
    ' this is the complete application path
    AppPath = LTrim$(AppPath)
    If Len(AppPath) = 0 Then
        ' if omitted, use the current application executable file
        AppPath = App.Path & IIf(Right$(App.Path, 1) <> "\", "\", _
            "") & App.ExeName & ".Exe"
    End If

    Select Case Action
        Case 0
            ' we must delete the key from the registry
            DeleteRegistryValue HKEY_CURRENT_USER, regKey, AppTitle
        Case 1
            ' we must add a value under the ...\RunOnce key
            SetRegistryValue HKEY_CURRENT_USER, regKey & "Once", AppTitle, _
                AppPath
        Case Else
            ' we must add a value under the ....\Run key
            SetRegistryValue HKEY_CURRENT_USER, regKey, AppTitle, AppPath
    End Select

End Sub

' List all the File extensions that are registered in the system
'
' return a bi-dimension string array, where
'    arr(0, i) is the file extension
'    arr(1, i) is the coresponding ProgID
'    arr(2, i) is the associated description
'    arr(3, i) is the location of the executable file
'
' Example:
'   ' fill a listbox with the descriptions associated
'   ' to each registered file extension
'   Dim a() As String, i As Long
'   a() = ListFileExtensions()
'   For i = 1 To UBound(a, 2)
'       List1.AddItem a(0, i) & vbTab & a(2, i)
'   Next
'
' NOTE: requires the EnumRegistryKey and GetRegistryValue functions

Function ListFileExtensions() As String()
Attribute ListFileExtensions.VB_Description = "' return a bi-dimension string array, where\r\n'    arr(0, i) is the file extension\r\n'    arr(1, i) is the coresponding ProgID\r\n'    arr(2, i) is the associated description\r\n'    arr(3, i) is the location of the executable file"
    Dim regKeys As Collection
    Dim regKey As Variant
    Dim extsNdx As Long
    Dim progID As String
    Dim clsid As String
    
    Const HKEY_CLASSES_ROOT = &H80000000
    
    ' retrieve all the subkeys under HKEY_CLASSES_ROOT
    Set regKeys = EnumRegistryKeys(HKEY_CLASSES_ROOT, "")
    
    ' prepare the array of results
    ReDim exts(3, regKeys.Count) As String
    
    ' ignore errors
    On Error Resume Next
    
    For Each regKey In regKeys
        ' check whether this is a File extension
        If Left$(regKey, 1) = "." Then
            ' store the extension in the result array
            extsNdx = extsNdx + 1
            exts(0, extsNdx) = regKey
            ' the default value for this key is the ProgID
            ' or another string that can be searched in the Registry
            progID = GetRegistryValue(HKEY_CLASSES_ROOT, regKey, "")
            exts(1, extsNdx) = progID
            ' the default value of the key HKEY_CLASSES_ROOT\ProgID is
            ' the textual description of this entry
            exts(2, extsNdx) = GetRegistryValue(HKEY_CLASSES_ROOT, progID, "")
            If exts(2, extsNdx) = "" Then
                ' if this key doesn't exist, delete this array entry
                extsNdx = extsNdx - 1
            Else
                ' else try to read the location of the associated EXE file
                exts(3, extsNdx) = GetRegistryValue(HKEY_CLASSES_ROOT, _
                    progID & "\shell\open\command", "")
            End If
        End If
    Next
        
    ' trim unused items
    ReDim Preserve exts(3, extsNdx) As String
    ListFileExtensions = exts()
End Function

' Read a Registry value
'
' Use KeyName = "" for the default value
' If the value isn't there, it returns the DefaultValue
' argument, or Empty if the argument has been omitted
'
' Supports DWORD, REG_SZ, REG_EXPAND_SZ, REG_BINARY and REG_MULTI_SZ
' REG_MULTI_SZ values are returned as a null-delimited stream of strings
' (VB6 users can use SPlit to convert to an array of string)

Function GetRegistryValue(ByVal hKey As RegistryHive, ByVal KeyName As String, _
    ByVal ValueName As String, Optional DefaultValue As Variant) As Variant
Attribute GetRegistryValue.VB_Description = "Returns the named registry value, or [DefaultValue] if it is not found."
    Dim handle As Long
    Dim resLong As Long
    Dim resString As String
    Dim resBinary() As Byte
    Dim length As Long
    Dim retVal As Long
    Dim valueType As Long
    
    ' Prepare the default result
    GetRegistryValue = IIf(IsMissing(DefaultValue), Empty, DefaultValue)
    
    ' Open the key, exit if not found.
    If RegOpenKeyEx(hKey, KeyName, 0, KEY_READ, handle) Then
        Exit Function
    End If
    
    ' prepare a 1K receiving resBinary
    length = 1024
    ReDim resBinary(0 To length - 1) As Byte
    
    ' read the registry key
    retVal = RegQueryValueEx(handle, ValueName, 0, valueType, resBinary(0), _
        length)
    ' if resBinary was too small, try again
    If retVal = ERROR_MORE_DATA Then
        ' enlarge the resBinary, and read the value again
        ReDim resBinary(0 To length - 1) As Byte
        retVal = RegQueryValueEx(handle, ValueName, 0, valueType, resBinary(0), _
            length)
    End If
    
    ' return a value corresponding to the value type
    Select Case valueType
        Case REG_DWORD
            CopyMemory resLong, resBinary(0), 4
            GetRegistryValue = resLong
        Case REG_SZ, REG_EXPAND_SZ
            ' copy everything but the trailing null char
            resString = Space$(length - 1)
            CopyMemory ByVal resString, resBinary(0), length - 1
            GetRegistryValue = resString
        Case REG_BINARY
            ' resize the result resBinary
            If length <> UBound(resBinary) + 1 Then
                ReDim Preserve resBinary(0 To length - 1) As Byte
            End If
            GetRegistryValue = resBinary()
        Case REG_MULTI_SZ
            ' copy everything but the 2 trailing null chars
            resString = Space$(length - 2)
            CopyMemory ByVal resString, resBinary(0), length - 2
            GetRegistryValue = resString
        Case Else
            RegCloseKey handle
            Err.Raise 1001, , "Unsupported value type"
    End Select
    
    ' close the registry key
    RegCloseKey handle
End Function
' Return the name of the registered user
'
' Requires the GetRegistryValue function

Function GetRegisteredUser() As String
Attribute GetRegisteredUser.VB_Description = "Returns the registered user of the OS"
    Dim regKey As String
    
    ' this information is held in a Registry key whose path
    ' depends on the operating system installed
    
    If GetVersion() >= 0 Then
        ' this is a Windows NT system
        regKey = "Software\Microsoft\Windows NT\CurrentVersion"
    Else
        ' this is a Win9x system
        regKey = "Software\Microsoft\Windows\CurrentVersion"
    End If
    
    GetRegisteredUser = GetRegistryValue(HKEY_LOCAL_MACHINE, regKey, _
        "RegisteredOwner", "")
End Function

' Enumerate values under a given registry key
'
' returns a collection, where each element of the collection
' is a 2-element array of Variants:
'    element(0) is the value name, element(1) is the value's value

Function EnumRegistryValues(ByVal hKey As RegistryHive, ByVal KeyName As String) As _
    VBA.Collection
Attribute EnumRegistryValues.VB_Description = "Returns a VBA.Collection containing a list of all the values assigned to the named key."
    Dim handle As Long
    Dim index As Long
    Dim valueType As Long
    Dim name As String
    Dim nameLen As Long
    Dim resLong As Long
    Dim resString As String
    Dim dataLen As Long
    Dim valueInfo(0 To 1) As Variant
    Dim retVal As Long
    
    ' initialize the result
    Set EnumRegistryValues = New Collection
    
    ' Open the key, exit if not found.
    If Len(KeyName) Then
        If RegOpenKeyEx(hKey, KeyName, 0, KEY_READ, handle) Then Exit Function
        ' in all cases, subsequent functions use hKey
        hKey = handle
    End If
    
    Do
        ' this is the max length for a key name
        nameLen = 260
        name = Space$(nameLen)
        ' prepare the receiving buffer for the value
        dataLen = 4096
        ReDim resBinary(0 To dataLen - 1) As Byte
        
        ' read the value's name and data
        ' exit the loop if not found
        retVal = RegEnumValue(hKey, index, name, nameLen, ByVal 0&, valueType, _
            resBinary(0), dataLen)
        
        ' enlarge the buffer if you need more space
        If retVal = ERROR_MORE_DATA Then
            ReDim resBinary(0 To dataLen - 1) As Byte
            retVal = RegEnumValue(hKey, index, name, nameLen, ByVal 0&, _
                valueType, resBinary(0), dataLen)
        End If
        ' exit the loop if any other error (typically, no more values)
        If retVal Then Exit Do
        
        ' retrieve the value's name
        valueInfo(0) = Left$(name, nameLen)
        
        ' return a value corresponding to the value type
        Select Case valueType
            Case REG_DWORD
                CopyMemory resLong, resBinary(0), 4
                valueInfo(1) = resLong
            Case REG_SZ, REG_EXPAND_SZ
                ' copy everything but the trailing null char
                resString = Space$(dataLen - 1)
                CopyMemory ByVal resString, resBinary(0), dataLen - 1
                valueInfo(1) = resString
            Case REG_BINARY
                ' shrink the buffer if necessary
                If dataLen < UBound(resBinary) + 1 Then
                    ReDim Preserve resBinary(0 To dataLen - 1) As Byte
                End If
                valueInfo(1) = resBinary()
            Case REG_MULTI_SZ
                ' copy everything but the 2 trailing null chars
                resString = Space$(dataLen - 2)
                CopyMemory ByVal resString, resBinary(0), dataLen - 2
                valueInfo(1) = resString
            Case Else
                ' Unsupported value type - do nothing
        End Select
        
        ' add the array to the result collection
        ' the element's key is the value's name
        EnumRegistryValues.Add valueInfo, valueInfo(0)
        
        index = index + 1
    Loop
   
    ' Close the key, if it was actually opened
    If handle Then RegCloseKey handle
        
End Function

' Enumerate registry keys under a given key
'
' returns a collection of strings

Function EnumRegistryKeys(ByVal hKey As RegistryHive, ByVal KeyName As String) As _
    VBA.Collection
Attribute EnumRegistryKeys.VB_Description = "Returns a VBA.Collection of the subkeys of the named registry key"
    Dim handle As Long
    Dim length As Long
    Dim index As Long
    Dim subkeyName As String
    
    ' initialize the result collection
    Set EnumRegistryKeys = New Collection
    
    ' Open the key, exit if not found
    If Len(KeyName) Then
        If RegOpenKeyEx(hKey, KeyName, 0, KEY_READ, handle) Then Exit Function
        ' in all case the subsequent functions use hKey
        hKey = handle
    End If
    
    Do
        ' this is the max length for a key name
        length = 260
        subkeyName = Space$(length)
        ' get the N-th key, exit the loop if not found
        If RegEnumKey(hKey, index, subkeyName, length) Then Exit Do
        
        ' add to the result collection
        subkeyName = Left$(subkeyName, InStr(subkeyName, vbNullChar) - 1)
        EnumRegistryKeys.Add subkeyName, subkeyName
        ' prepare to query for next key
        index = index + 1
    Loop
   
    ' Close the key, if it was actually opened
    If handle Then RegCloseKey handle
        
End Function


' Delete a registry value
'
' Return True if successful, False if the value hasn't been found

Function DeleteRegistryValue(ByVal hKey As RegistryHive, ByVal KeyName As String, _
    ByVal ValueName As String) As Boolean
Attribute DeleteRegistryValue.VB_Description = "Deletes the named registry value."
    Dim handle As Long
    
    ' Open the key, exit if not found
    If RegOpenKeyEx(hKey, KeyName, 0, KEY_WRITE, handle) Then Exit Function
    
    ' Delete the value (returns 0 if success)
    DeleteRegistryValue = (RegDeleteValue(handle, ValueName) = 0)
    ' Close the handle
    RegCloseKey handle
End Function

' Delete a registry key
'
' Under Windows NT it doesn't work if the key contains subkeys

Sub DeleteRegistryKey(ByVal hKey As RegistryHive, ByVal KeyName As String)
Attribute DeleteRegistryKey.VB_Description = "Deletes the named registry key."
    RegDeleteKey hKey, KeyName
End Sub



' Modify the name of the registered user and organization
'
' Requires the SetRegistryValue function

Sub SetRegisteredUser(ByVal UserName As String, Optional ByVal Organization As _
    String)
Attribute SetRegisteredUser.VB_Description = "Sets the registered user and organisation of the current OS."
    Dim regKey As String
    
    ' this information is held in a Registry key whose path
    ' depends on the operating system installed
    
    If GetVersion() >= 0 Then
        ' this is a Windows NT system
        regKey = "Software\Microsoft\Windows NT\CurrentVersion"
    Else
        ' this is a Win9x system
        regKey = "Software\Microsoft\Windows\CurrentVersion"
    End If
    
    If Len(UserName) Then
        SetRegistryValue HKEY_LOCAL_MACHINE, regKey, "RegisteredOwner", UserName
    End If
    If Len(Organization) Then
        SetRegistryValue HKEY_LOCAL_MACHINE, regKey, "RegisteredOrganization", _
            Organization
    End If
    
End Sub


' Get the path of a Windows application
' or an empty string if the application isn't registered
'
' this routine only works for those applications that register
' themselves under the registry key
' HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\App Paths
'
' You can use it to retrieve the path of all MSOffice apps,
' MS Access, SQl Server, Windows Dialer, and more, for example
'      ' Run Excel in a maximized window
'      Shell GetApplicationPath("EXCEL.EXE"), vbMaximizedFocus
'
' requires the GetRegistryValue function

Function GetApplicationPath(ByVal ExeName As String) As String
Attribute GetApplicationPath.VB_Description = "Fetches the path of an application registered under\r\nHKEY_LOCAL_MACHINE\\Software\\Microsoft\\Windows\\CurrentVersion\\App Paths"
    GetApplicationPath = GetRegistryValue(HKEY_LOCAL_MACHINE, _
        "Software\Microsoft\Windows\CurrentVersion\App Paths\" & ExeName, "")
End Function

' Load the specified REG file in the registry

Public Sub ApplyRegFile(ByVal sRegFile As String)
Attribute ApplyRegFile.VB_Description = "Applies the named Registry export file to the registry"
    On Error Resume Next
    'first of all, check if the file exists
    If Not (GetAttr(sRegFile) And vbDirectory) = 0 Then Exit Sub
    'load the reg file
    '  quote the file name: this is necessary if the file name is something
    ' like "token1 token2.reg"
    Shell "regedit /s " & Chr$(34) & sRegFile & Chr$(34)
End Sub



' Return True if a Registry key exists

Function CheckRegistryKey(ByVal hKey As RegistryHive, ByVal KeyName As String) As _
    Boolean
Attribute CheckRegistryKey.VB_Description = "Checks for the presence of the named registry key."
    Dim handle As Long
    ' Try to open the key
    If RegOpenKeyEx(hKey, KeyName, 0, KEY_READ, handle) = 0 Then
        ' The key exists
        CheckRegistryKey = True
        ' Close it before exiting
        RegCloseKey handle
    End If
End Function
' Create a registry key, then close it
' Returns True if the key already existed, False if it was created

Function CreateRegistryKey(ByVal hKey As RegistryHive, ByVal KeyName As String) As _
    Boolean
Attribute CreateRegistryKey.VB_Description = "Creates the named registry key."
    Dim handle As Long, disposition As Long
    
    If RegCreateKeyEx(hKey, KeyName, 0, 0, 0, 0, 0, handle, disposition) Then
        Err.Raise 1001, , "Unable to create the registry key"
    Else
        ' Return True if the key already existed.
        CreateRegistryKey = (disposition = REG_OPENED_EXISTING_KEY)
        ' Close the key.
        RegCloseKey handle
    End If
End Function


' Write or Create a Registry value
' returns True if successful
'
' Use KeyName = "" for the default value
'
' Value can be an integer value (REG_DWORD), a string (REG_SZ)
' or an array of binary (REG_BINARY). Raises an error otherwise.

Function SetRegistryValue(ByVal hKey As RegistryHive, ByVal KeyName As String, _
    ByVal ValueName As String, value As Variant) As Boolean
Attribute SetRegistryValue.VB_Description = "Set the named registry value. Returns True if successful."
    Dim handle As Long
    Dim lngValue As Long
    Dim strValue As String
    Dim binValue() As Byte
    Dim length As Long
    Dim retVal As Long
    
    ' Open the key, exit if not found
    If RegOpenKeyEx(hKey, KeyName, 0, KEY_WRITE, handle) Then
        Exit Function
    End If

    ' three cases, according to the data type in Value
    Select Case VarType(value)
        Case vbInteger, vbLong
            lngValue = value
            retVal = RegSetValueEx(handle, ValueName, 0, REG_DWORD, lngValue, 4)
        Case vbString
            strValue = value
            retVal = RegSetValueEx(handle, ValueName, 0, REG_SZ, ByVal strValue, _
                Len(strValue))
        Case vbArray + vbByte
            binValue = value
            length = UBound(binValue) - LBound(binValue) + 1
            retVal = RegSetValueEx(handle, ValueName, 0, REG_BINARY, _
                binValue(LBound(binValue)), length)
        Case Else
            RegCloseKey handle
            Err.Raise 1001, , "Unsupported value type"
    End Select
    
    ' Close the key and signal success
    RegCloseKey handle
    ' signal success if the value was written correctly
    SetRegistryValue = (retVal = 0)
End Function


