VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "clsMSCAPI"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'-------------------- MS Cryptographic API --------------------------
'17Jul08 CKJ Written - based entirely on the MSDN example
'              http://support.microsoft.com/kb/821762
'            Declared as Friend not Public - for internal use only
'            SHA-1 & RC2 not changeable
'03Aug12 CKJ EncryptDecrypt: prevented endless Err.raise loop TFS36826

Option Explicit
DefBool A-Z

Private g_lngCryptoContext       As Long

Private mstrPassword             As String
Private mstrOutData              As String

Private Const ALG_CLASS_ANY      As Long = 0
Private Const ALG_TYPE_ANY       As Long = 0
Private Const ALG_CLASS_HASH     As Long = 32768
Private Const ALG_TYPE_BLOCK     As Long = 1536
Private Const ALG_CLASS_DATA_ENCRYPT As Long = 24576
Private Const ALG_SID_RC2        As Long = 2
Private Const ALG_SID_SHA1       As Long = 4

' Hash algorithms
Private Const CALG_SHA1          As Long = ALG_CLASS_HASH Or ALG_TYPE_ANY Or ALG_SID_SHA1

' Block ciphers
Private Const CALG_RC2           As Long = ALG_CLASS_DATA_ENCRYPT Or ALG_TYPE_BLOCK Or ALG_SID_RC2

' CryptSetProvParam
Private Const PROV_RSA_FULL      As Long = 1

' used when aquiring the provider
Private Const CRYPT_VERIFYCONTEXT   As Long = &HF0000000

' Microsoft provider data
Private Const MS_DEFAULT_PROVIDER   As String = "Microsoft Base Cryptographic Provider v1.0"

' used to specify not to use any salt value while deriving the key
Private Const CRYPT_NO_SALT As Long = &H10

' ---------------------------------------------------------------------------
' External Declares
' ---------------------------------------------------------------------------
Private Declare Function GetLastError Lib "kernel32" () As Long

Private Declare Function CryptHashData Lib "advapi32.dll" _
   (ByVal hHash As Long, ByVal pbData As String, _
   ByVal dwDataLen As Long, ByVal dwFlags As Long) As Long

Private Declare Function CryptCreateHash Lib "advapi32.dll" _
   (ByVal hProv As Long, ByVal algid As Long, _
   ByVal hKey As Long, ByVal dwFlags As Long, _
   ByRef phHash As Long) As Long

Private Declare Function CryptDestroyHash Lib "advapi32.dll" _
   (ByVal hHash As Long) As Long

Private Declare Function CryptAcquireContext Lib "advapi32.dll" _
   Alias "CryptAcquireContextA" (ByRef phProv As Long, _
   ByVal pszContainer As String, ByVal pszProvider As String, _
   ByVal dwProvType As Long, ByVal dwFlags As Long) As Long

Private Declare Function CryptReleaseContext Lib "advapi32.dll" _
   (ByVal hProv As Long, ByVal dwFlags As Long) As Long

Private Declare Function CryptDeriveKey Lib "advapi32.dll" _
   (ByVal hProv As Long, ByVal algid As Long, _
   ByVal hBaseData As Long, ByVal dwFlags As Long, _
   ByRef phKey As Long) As Long

Private Declare Function CryptDestroyKey Lib "advapi32.dll" _
   (ByVal hKey As Long) As Long

Private Declare Function CryptEncrypt Lib "advapi32.dll" _
   (ByVal hKey As Long, ByVal hHash As Long, ByVal Final As Long, _
   ByVal dwFlags As Long, ByVal pbData As String, _
   ByRef pdwDataLen As Long, ByVal dwBufLen As Long) As Long
              
Private Declare Function CryptDecrypt Lib "advapi32.dll" _
   (ByVal hKey As Long, ByVal hHash As Long, ByVal Final As Long, _
   ByVal dwFlags As Long, ByVal pbData As String, pdwDataLen As Long) As Long
   
Private Declare Function CryptGenRandom Lib "advapi32.dll" _
   (ByVal hProv As Long, ByVal dwLen As Long, _
   ByVal pbBuffer As String) As Long
   
'---------------------------Friend Properties-------------------------

Friend Property Get OutputData() As String
Attribute OutputData.VB_Description = "Read only.  Return encrypted/decrypted data in byte array format."

   OutputData = mstrOutData

End Property
   
Friend Property Let Password(strPassword As String)

   mstrPassword = strPassword

End Property
    
Friend Property Get Password() As String
Attribute Password.VB_Description = "Receives user supplied password in byte array format."

   Password = ""  'don't let password back out

End Property

'---------------------------Friend Functions-------------------------

Friend Function Encrypt(strData As String) As Boolean
   
   Encrypt = EncryptDecrypt(True, strData)
   
End Function

Friend Function Decrypt(strData As String) As Boolean
   
   Decrypt = EncryptDecrypt(False, strData)
   
End Function

'----------------------Private Functions & Procedures--------------

Private Function EncryptDecrypt(ByVal Encrypt As Boolean, strInData As String) As Boolean

Dim lngHashHnd       As Long     ' Hash handle
Dim lngkey           As Long
Dim lngRetCode       As Long     ' return value from an API call
Dim lngHashType      As Long
Dim lngLen           As Long
Dim lngAlgoType      As Long
Dim lngHExchgKey     As Long
Dim lngEncDataLength As Long
Dim lngEnctBuffLen   As Long
Dim strEncBuffer     As String
Dim strOutData       As String
Dim prefix           As String
Dim ErrorTitle       As String
Dim strMsg           As String
Dim lngErr           As Long

   If Encrypt Then prefix = "En" Else prefix = "De"
   ErrorTitle = prefix & "cryption Errors"

   EncryptDecrypt = False        ' preset to FALSE
   strMsg = ""
   strOutData = ""
   strEncBuffer = ""
   lngHashType = CALG_SHA1
   lngAlgoType = CALG_RC2

    '----------------------- Aquire the provider handle---------------------------
   If g_lngCryptoContext = 0 Then
      If Not GetProvider Then
         Call Class_Terminate       ' Failed.  Time to leave.
         Exit Function
      End If
   End If
    
   On Error GoTo EncryptDecrypt_Error
   
   '----------------------- Create a hash object----------------------------------
   If Not CBool(CryptCreateHash(g_lngCryptoContext, lngHashType, ByVal 0&, ByVal 0&, lngHashHnd)) Then
      strMsg = " during CryptCreateHash"
      GoTo Cleanup
   End If
   
   '------------------------- Hash in the password text----------------------------
   If Not CBool(CryptHashData(lngHashHnd, mstrPassword, Len(mstrPassword), ByVal 0&)) Then
      strMsg = " during CryptHashData"
      GoTo Cleanup
   End If
   
   '-------------- Create a session key from the hash object--------------------
   If Not CBool(CryptDeriveKey(g_lngCryptoContext, lngAlgoType, lngHashHnd, ByVal CRYPT_NO_SALT, lngkey)) Then
      strMsg = " during CryptDeriveKey"
      GoTo Cleanup
   End If
   
   '----------------------- Destroy hash object--------------------------------
   If lngHashHnd <> 0 Then
       lngRetCode = CryptDestroyHash(lngHashHnd)
   End If
   lngHashHnd = 0
    
   '------------------------- Prepare data for decryption.-----------------------
   lngEncDataLength = Len(strInData)
   If Encrypt Then
      lngEnctBuffLen = lngEncDataLength * 2
   Else
      lngEnctBuffLen = lngEncDataLength
   End If
   strEncBuffer = String$(lngEnctBuffLen, vbNullChar)
   LSet strEncBuffer = strInData
        
   If Encrypt Then      '--------------------- Encrypt the text data---------------------------------
      If Not CBool(CryptEncrypt(lngkey, ByVal 0&, ByVal 1&, ByVal 0&, strEncBuffer, lngEncDataLength, lngEnctBuffLen)) Then
         strMsg = " during Encryption" & vbCrLf & "Bytes required:" & CStr(lngEnctBuffLen)
         GoTo Cleanup
      End If
   Else                 '--------------------- Decrypt the text data---------------------------------
     If Not CBool(CryptDecrypt(lngkey, ByVal 0&, ByVal 1&, ByVal 0&, strEncBuffer, lngEncDataLength)) Then
        strMsg = " during Decryption" & vbCrLf & "Bytes required:" & CStr(lngEnctBuffLen)
        GoTo Cleanup
     End If
   End If
    
   '--------------- Return the encrypted data string-------------
   strOutData = Mid$(strEncBuffer, 1, lngEncDataLength)
   mstrOutData = strOutData
   EncryptDecrypt = True     ' Successful finish
     
Cleanup:
   If Len(strMsg) Then     'error occurred in the crypto library - retrieve error code
      lngErr = GetLastError
      strMsg = "Error: " & CStr(lngErr) & strMsg
   End If
   
CleanupExit:
   ' -------------------------Destroy session key.-----------------------------
   If lngkey <> 0 Then
       lngRetCode = CryptDestroyKey(lngkey)
   End If
     
   '-------------------------- Destroy key exchange key handle---------------------
   If lngHExchgKey <> 0 Then
       lngRetCode = CryptDestroyKey(lngHExchgKey)
   End If
   
   '---------------------------- Destroy hash object--------------------------------
   If lngHashHnd <> 0 Then
      lngRetCode = CryptDestroyHash(lngHashHnd)
      lngHashHnd = 0
   End If
    
   On Error GoTo 0      '03Aug12 CKJ without this any strMsg causes an endless loop of Err.raise, resume CleanupExit
   
   If Len(strMsg) Then     'error occurred
      Err.Raise lngErr, "MSCAPI", strMsg
   End If
Exit Function
    
EncryptDecrypt_Error:
   '----------------------- An error occurred during the encryption process---------------------
   lngErr = Err.Number
   strMsg = "Error: " & CStr(lngErr) & "  " & Err.Description & vbCrLf & vbCrLf & "A error occurred during the " & prefix & "cryption process."
Resume CleanupExit
    
End Function
    
Private Function GetProvider() As Boolean
Attribute GetProvider.VB_Description = "Obtains the provider handle.  To use 128-bit cipher strength then set the property EnhancedProvider = TRUE."
'Gain Access To CryptoAPI.
    
Dim strTemp       As String
Dim strProvider   As String
Dim strErrorMsg   As String
      
   On Error Resume Next
   strTemp = vbNullChar
   strProvider = MS_DEFAULT_PROVIDER & vbNullChar
   
   If CBool(CryptAcquireContext(g_lngCryptoContext, ByVal strTemp, ByVal strProvider, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT)) Then
       GetProvider = True
       Exit Function
   End If

End Function

Public Function GetRandomString(lCryptLength As Long, CryptBuffer As String) As Boolean
Dim lHCryptprov As Long
Dim lResult As Long
Dim lCryptBufLen As Long
Dim sContainer As String
Dim strProvider As String
Dim sCryptBuffer1 As String
Dim i As Integer

    '----------------------- Aquire the provider handle---------------------------
   If g_lngCryptoContext = 0 Then
      If Not GetProvider Then
         Call Class_Terminate       ' Failed.  Time to leave.
         Exit Function
      End If
   End If
   
   sContainer = vbNullChar
   strProvider = MS_DEFAULT_PROVIDER & vbNullChar

   GetRandomString = False

   lResult = CryptAcquireContext(g_lngCryptoContext, ByVal sContainer, ByVal strProvider, PROV_RSA_FULL, CRYPT_VERIFYCONTEXT)
   
   If CBool(lResult) Then
      lCryptBufLen = lCryptLength
      sCryptBuffer1 = String(lCryptBufLen, Chr(0))
      lResult = CryptGenRandom(g_lngCryptoContext, lCryptBufLen, sCryptBuffer1)
      If Not lResult = 0 Then
         GetRandomString = True
         'CryptBuffer = StrConv(sCryptBuffer1, vbFromUnicode)
         CryptBuffer = sCryptBuffer1
      End If
   End If

End Function

Private Sub Class_Initialize()

   mstrPassword = ""
   mstrOutData = ""

End Sub

Private Sub Class_Terminate()
'If we managed to load a Microsoft Provider ID, then release it.

Dim lngRetValue As Long

   If g_lngCryptoContext <> 0 Then
      lngRetValue = CryptReleaseContext(g_lngCryptoContext, ByVal 0&)
   End If

End Sub

