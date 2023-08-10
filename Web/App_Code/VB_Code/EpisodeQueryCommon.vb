' Modification History
' --------------------
'
' 23Apr09 EAC F0038665: Updated EventLogger to use the .NET system library rather call the old .NET logging library.
'
'------------------------------------------------------------------------------------------------------------------------------------

Imports System
Imports System.Configuration
Imports System.Collections.Specialized
Imports System.IO
Imports System.Data
Imports System.Reflection
Imports System.Text
Imports System.Web.Configuration
Imports System.Xml
Imports System.Xml.XPath
Imports System.Xml.Xsl
Imports Ascribe.Xml
Imports ascribeplc.interfaces.generic.logger
Imports ascribeplc.interfaces.icwmsgprocessor.messageprocessor

Namespace Ascribe.EpisodeQuery
    Public Enum trnDataTypeEnum
        ' LM 15/01/2008 Code 162 Added Enum declaration
        trnDataTypeVarChar = 0
        trnDataTypeChar = 1
        trnDataTypeInt = 2
        trnDataTypeText = 4
        trnDataTypeFloat = 7
        trnDataTypeBit = 9
        trnDataTypeDateTime = 10
        trnDataTypeUniqueIdentifier = 11
        trnDataTypeBase64Binary = 12
    End Enum
    Public Class BrokenRules
        Public Sub New()
        End Sub
        Public Function FormatBrokenRulesXml(ByVal code As String, ByVal text As String) As String
            Return FormatBrokenRulesXml(code, text, String.Empty)
        End Function
        Public Function FormatBrokenRulesXml(ByVal code As String, ByVal text As String, ByVal extraAttributes As String) As String
            Dim brokenRules As String = "<BrokenRules><Rule Code=""" + code + """ Text=""" + text + """"

            If extraAttributes.Length > 0 Then
                brokenRules += " " + extraAttributes
            End If

            brokenRules += "/></BrokenRules>"

            Return brokenRules
        End Function
    End Class
    Public Class IcwMsgProcessor
        Private imp As ICWMessageProcessor
        Public Sub New(ByVal sessionId As Integer, ByVal instanceName As String, ByVal debugMode As Boolean)
            'imp = new ICWMessageProcessor(sessionId,
            ' instanceName,
            ' debugMode, 0);
            imp = New ICWMessageProcessor(sessionId, instanceName, debugMode)
        End Sub
        Public Function Save(ByVal xmlData As String) As String
            'ascribeplc.interfaces.common.messagecomponent.Message msg = new ascribeplc.interfaces.common.messagecomponent.Message();
            'return imp.ProcessMessage(xmlData, msg);
            Return imp.ProcessMessage(xmlData)
        End Function
    End Class
    Public Class EventLogger
        Public Sub New()
        End Sub
        Public Sub CreateLogEntry(ByVal msg As String, ByVal type As System.Diagnostics.EventLogEntryType)
            '23Apr09 EAC F0038665: Modified to use the .NET system diagnostics library rather than call old interface engine library.
            Try
                If (msg.Length > 32767) Then msg = msg.Substring(0, 32767)

                Dim ev As New System.Diagnostics.EventLog("Application")

                ev.Source = "ascribeplc Integrated Clinical Workstation (ICW)"

                ev.Log = "Application"

                ev.WriteEntry(msg, type)

                ev.Dispose()

            Catch
                'Do nothing
            End Try
        End Sub

    End Class
    Public Class XmlTranslator
        Public Function TranslateXml(ByVal xsltFileName As String, ByVal xmlText As String) As String
            Dim args As New XsltArgumentList()
            Dim xform As New XslCompiledTransform()
            Dim dom As New XmlDocument()
            Dim nav As XPathNavigator = Nothing
            Dim ioStream As New MemoryStream()

            'load the XSLT file in the the XslCompileTransform object
            xform.Load(xsltFileName)

            dom.TryLoadXml(xmlText)

            nav = dom.CreateNavigator()

            'transform the XML and place the transformed XML into the MemoryStream
            xform.Transform(nav, args, ioStream)

            'read the transformed XML from the MemoryStream into a string variable
            Dim buffer As Byte() = New Byte(ioStream.Length - 1) {}

            ioStream.Position = 0

            ioStream.Read(buffer, 0, Convert.ToInt32(ioStream.Length))

            Dim ascXml As String = Encoding.ASCII.GetString(buffer)

            If ascXml.StartsWith("???") Then
                ascXml = ascXml.Substring(3)
            End If

            Return ascXml
        End Function
    End Class
End Namespace
