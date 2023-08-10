Attribute VB_Name = "Launch"
Option Explicit
Global Const PROJECT = "Launcher"
Declare Function FindWindow Lib "user32" Alias "FindWindowA" (ByVal lpClassName As String, ByVal lpWindowName As String) As Long

