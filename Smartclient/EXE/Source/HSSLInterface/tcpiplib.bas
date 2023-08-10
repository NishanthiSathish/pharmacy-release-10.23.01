Attribute VB_Name = "TCPIPLIB"
Option Explicit
DefInt A-Z

Function WinsockError$(ErrNo%)

   Select Case ErrNo
      Case 25005, 10004
         WinsockError$ = "Interrupted system call."
      Case 25010, 10009
         WinsockError$ = "Bad file number."
      Case 25014, 10013
         WinsockError$ = "Access denied."
      Case 25015, 10014
         WinsockError$ = "Bad address."
      Case 25023, 10022
         WinsockError$ = "Invalid argument."
      Case 25025, 10024
         WinsockError$ = "Too many open files."
      Case 25036, 10035
         WinsockError$ = "Operation would block."
      Case 25037, 10036
         WinsockError$ = "Operation now in progress."
      Case 25038, 10037
         WinsockError$ = "Operation already in progress."
      Case 25039, 10038
         WinsockError$ = "Socket operation on non-socket."
      Case 25040, 10039
         WinsockError$ = "Destination address required."
      Case 25041, 10040
         WinsockError$ = "Message too long."
      Case 25042, 10041
         WinsockError$ = "Protocol wrong type for socket."
      Case 25043, 10042
         WinsockError$ = "Bad protocol option."
      Case 25044, 10043
         WinsockError$ = "Protocol not supported."
      Case 25045, 10044
         WinsockError$ = "Socket type not supported."
      Case 25046, 10045
         WinsockError$ = "Operation not supported on socket."
      Case 25047, 10046
         WinsockError$ = "Protocol family not supported."
      Case 25048, 10047
         WinsockError$ = "Address family not supported by protocol family."
      Case 25049, 10048
         WinsockError$ = "Address already in use."
      Case 25050, 10049
         WinsockError$ = "Can't assign requested address."
      Case 25051, 10050
         WinsockError$ = "Network is down."
      Case 25052, 10051
         WinsockError$ = "Network is unreachable."
      Case 25053, 10052
         WinsockError$ = "Net dropped connection or reset."
      Case 25054, 10053
         WinsockError$ = "Software caused connection abort."
      Case 25055, 10054
         WinsockError$ = "Connection reset by peer."
      Case 25056, 10055
         WinsockError$ = "No buffer space available."
      Case 25057, 10056
         WinsockError$ = "Socket is already connected."
      Case 25058, 10057
         WinsockError$ = "Socket is not connected."
      Case 25059, 10058
         WinsockError$ = "Can't send after socket shutdown."
      Case 25060, 10059
         WinsockError$ = "Too many references, can't splice."
      Case 25061, 10060
         WinsockError$ = "Connection timed out."
      Case 25062, 10061
         WinsockError$ = "Connection refused."
      Case 25063, 10062
         WinsockError$ = "Too many levels of symbolic links."
      Case 25064, 10063
         WinsockError$ = "File name too long."
      Case 25065, 10064
         WinsockError$ = "Host is down."
      Case 25066, 10065
         WinsockError$ = "No route to host."
      Case 25067, 10066
         WinsockError$ = "Directory Not empty"
      Case 25068, 10067
         WinsockError$ = "Too many processes."
      Case 25069, 10068
         WinsockError$ = "Too many users."
      Case 25070, 10069
         WinsockError$ = "Disc Quota Exceeded."
      Case 25071, 10070
         WinsockError$ = "Stale NFS file handle."
      Case 25072, 10071
         WinsockError$ = "Too many levels of remote in path."
      Case 25092, 10091
         WinsockError$ = "Network subsystem is unavailable."
      Case 25093, 10092
         WinsockError$ = "WINSOCK DLL Version out of range."
      Case 25094, 10093
         WinsockError$ = "Winsock not loaded yet."
      Case 26002, 11001
         WinsockError$ = "Host not found."
      Case 26003, 11002
         WinsockError$ = "Non -authoritative'Host not found' (try again or check DNS setup)."
      Case 26004, 11003
         WinsockError$ = "Non-recoverable errors: FORMERR, REFUSED, NOTIMP."
      Case 26005, 11004
         WinsockError$ = "Valid name, no data record (check DNS setup)."
   Case Else
         WinsockError$ = Error$(ErrNo)
   End Select

End Function

