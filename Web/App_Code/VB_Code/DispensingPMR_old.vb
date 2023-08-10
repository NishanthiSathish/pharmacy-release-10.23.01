'-----------------------------------------------------------------------------------------------------------------
'
'														DispensingPMR_old.vb
'	
'	Server side functions for displaying prescriptions and dispensings in the PMR
'
'	Useage:
'		DispensingPMR.RenderPrescriptions(Me.Page, xmldoc, 0)
'
'	Notes:
'		moved out the dispensing PMR as methods are now used by more than one web pages
'
'   **********************************************************************************************
'   *                                                                                            *
'   * THIS IS THE OLD VERSION OF THE PMR AND YOU SHOULD NOT BE MAKING YOUR CHANGES HERE.         *
'   * FOR THE NEW PMR ALL THIS CODE NOW EXISTS IN THE Pharmacy\Dispensing PMR Layer PROJECT      *
'   *                                                                                            * 
'   **********************************************************************************************
'
'	Modification History:
'	12Jul11 XN  Created
'   30Jan11 XN  Add support for PN Prescriptions
'   15Nov12 XN  Made obsolete as replaced by newer speedy version TFS47487
'   13Mar13 XN  59024 Memory Leak Fix
'-----------------------------------------------------------------------------------------------------------------
Imports Microsoft.VisualBasic
Imports Ascribe.pharmacy.shared
Imports Ascribe.Common
Imports System.Xml

<Obsolete> _
Public Class DispensingPMR_old
    ''' <summary>
    ''' Renders prescriptions on the dispensing PMR
    ''' The list of prescriptions is normaly returned by sp
    '''    pPrescriptionByEpisodeForDispensing
    '''    pPrescriptionByEpisodeForDispensingRptDisp
    '''    pPrescriptionListByMergedPrescription
    ''' </summary>
    ''' <param name="Page">PMR page the prescriptions are to be displyed on</param>
    ''' <param name="SessionID">Session Id</param>
    ''' <param name="xmldoc">xml doc that contains the prescriptions (returns from sps above)</param>
    ''' <param name="level">parent child level of the prescription (main prescription level 0, merged prescriptions or dispensings level 1)</param>
    Public Shared Sub RenderPrescriptions(ByRef Page As System.Web.UI.Page, ByVal SessionID As Integer, ByVal xmldoc As XmlDocument, ByVal level As Integer, ByVal PSO As Boolean)
        Dim xmlnodelist As XmlNodeList  ' Dim xmlnodelist As MSXML2.IXMLDOMNodeList XN 13Mar13 59024 Memory Leak 
        Dim xmlnode As XmlElement       ' Dim xmlnode As MSXML2.IXMLDOMElement      XN 13Mar13 59024 Memory Leak 
        Dim xmlattrib As XmlNode        ' Dim xmlattrib As MSXML2.IXMLDOMNode       XN 13Mar13 59024 Memory Leak 
        Dim today As DateTime = DateTime.Now.Date
        Dim yesterday As DateTime = today.AddDays(-1.0)
        Dim count As Integer = 0
        '<P P_ID="302511" P_RequestTypeID="28" PDesc="KETOPROFEN 100mg M/R CAPSULE when required" PStart="2004-11-05T14:28:12.883" PStop="2004-11-05T14:28:12.883" P_IsCurrent="1" HasNotes="1/0" HasDispensings="1/0" DispDate="2004-11-05T14:28:12" DispQty="123" DispUser="Bob the Bob" />
        xmlnodelist = xmldoc.selectNodes("//P")

        DispensingPMR_old.AddAmendStatus(SessionID, xmlnodelist)

        ' For Each xmlnode In xmlnodelist   XN 13Mar13 59024 Memory Leak 
        For n As Int32 = 0 To xmlnodelist.Count - 1
            xmlnode = xmlnodelist.Item(n)
            Page.Response.Write("<tr pres_row='true' i=""")
            Page.Response.Write(xmlnode.getAttribute("P_ID"))
            'Page.Response.Write(""" c=""P"" ic=""")
            Page.Response.Write(""" c=""")
            If (xmlnode.getAttribute("PNPrescription") IsNot DBNull.Value) AndAlso (xmlnode.getAttribute("PNPrescription") = "1") THEN   ' XN 30Jan12 PN Prescriptions
                Page.Response.Write("T")
            ElseIf xmlnode.getAttribute("Merged") = "1" THEN
                Page.Response.Write("M")
            Else
                Page.Response.Write("P")
            End If
            Page.Response.Write(""" ic=""")
            Page.Response.Write(xmlnode.getAttribute("P_IsCurrent"))
            Page.Response.Write(""" e=""")
            Page.Response.Write(xmlnode.getAttribute("EpisodeID"))
            Page.Response.Write(""" t=""")
            Page.Response.Write(xmlnode.getAttribute("P_TableID"))
            Page.Response.Write(""" rt=""")
            Page.Response.Write(xmlnode.getAttribute("P_RequestTypeID"))
            Page.Response.Write(""" prod=""")
            Page.Response.Write(xmlnode.getAttribute("P_ProductID"))
            Page.Response.Write(""" ac=""")
            Page.Response.Write(xmlnode.getAttribute("P_AutoCommit"))
            Page.Response.Write(""" chld=""")
            Page.Response.Write(xmlnode.getAttribute("HasDispensings"))
            Page.Response.Write(""" pct=""")
            Page.Response.Write(xmlnode.getAttribute("P_CreationType"))
            Page.Response.Write(""" csa=""")
            Page.Response.Write(xmlnode.getAttribute("CanStopOrAmend"))
            Page.Response.Write(""" ")
            Page.Response.Write(""" mergeCancelled=""")
            Page.Response.Write(xmlnode.getAttribute("MergePrescriptionCancelled"))
            Page.Response.Write(""" ")
            'Response.Write(""" isgenerictemplate=""")
            'Response.Write(IIf(Not xmlnode.getAttribute("RequestType") Is Nothing AndAlso xmlnode.getAttribute("RequestType").ToString().ToUpper().Trim() = "GENERIC PRESCRIPTION", "1", "0"))
            'Response.Write(""" ")
            If xmlnode.ChildNodes.Count > 0 Then
                For a As Int32 = 0 To xmlnode.FirstChild.Attributes.Count - 1
                    xmlattrib = xmlnode.FirstChild.Attributes.Item(a)
                    Page.Response.Write("SB_" & xmlattrib.Name & "=""" & xmlattrib.Value & """")
                Next
            End If

            Page.Response.Write(" Level=""" + level.ToString() + """")

            Page.Response.Write("><td class=""x"" onclick=""x_clk(this);"">")
            '02-11-2007 Error code 29
            If (Not IsDBNull(xmlnode.getAttribute("HasDispensings")) AndAlso xmlnode.getAttribute("HasDispensings") = "1") OrElse _
               (Not IsDBNull(xmlnode.getAttribute("Merged")) AndAlso xmlnode.getAttribute("Merged") = "1") Then
                Page.Response.Write("<img src=""../../images/grid/open.gif"" width=""15"" width=""15"">")
            Else
                Page.Response.Write("&nbsp;")
            End If
            Page.Response.Write("</td>")
            Page.Response.Write("<td colspan=""7"">")
            For ind As Integer = 1 To level
                Page.Response.Write("&nbsp;&nbsp;&nbsp;")
            Next
            '21Aug11 TH Added rx in merge icon
	    if level = 1 then
		Page.Response.Write("<img title=""This is part of a merged prescription."" src=""../../images/user/Arrows.gif"" WIDTH=""16"" HEIGHT=""16"">")
	    End If
	    '10Aug11 TH Added Merged Icon
	    If(xmlnode.getAttribute("Merged") = "1") Then
		Page.Response.Write("<img title=""This is a merged prescription."" src=""../../images/user/LinkedRx.gif"" WIDTH=""16"" HEIGHT=""16"">")
	    End If
            If (xmlnode.getAttribute("MergePrescriptionCancelled") = "1") Then
                Page.Response.Write("<span style='text-decoration: line-through;'>")
            End If
            Page.Response.Write(Generic.Blank2NBSP(xmlnode.getAttribute("PDesc")))
            If (xmlnode.getAttribute("MergePrescriptionCancelled") = "1") Then
                Page.Response.Write("</span>")
                Page.Response.Write("<br />(Items on this merged prescription have been cancelled. Please re-link remaining items before dispensing)")
            End If
            Page.Response.Write("</td>")

            ' Determine if date should be highlighted
            ' If dispensed today then bold red
            ' If dispensed yesturday then italic red
            Dim dipDate As DateTime = Generic.TDate2Date(xmlnode.getAttribute("DispDate"))
            Page.Response.Write("<td")
            If (dipDate >= today) Then
                Page.Response.Write(" class=""HighlightDate1"" ")
            ElseIf (dipDate >= yesterday) Then
                Page.Response.Write(" class=""HighlightDate2"" ")
            End If
            Page.Response.Write(">")
            Page.Response.Write(Generic.Blank2NBSP(Generic.Date2ddmmccyy(dipDate)))
            Page.Response.Write("</td>")
	    If (Not IsDBNull(xmlnode.getAttribute("RxReason")) ) AndAlso xmlnode.getAttribute("RxReason") <> "" Then
               
                Page.Response.Write("<td align=""center""><img title =""" + xmlnode.getAttribute("RxReason") + """ src=""../../images/user/rxReason.gif"" width=""15"" width=""15"" align=""center"" ></td>")
            Else
            	Page.Response.Write("<td>&nbsp;</td>")
	    End If
            Page.Response.Write("<td>")
            Page.Response.Write(Generic.Blank2NBSP(Generic.Date2ddmmccyy(Generic.TDate2Date(xmlnode.getAttribute("PStart")))))
            Page.Response.Write("</td>")
            Page.Response.Write("<td>")
            Page.Response.Write(Generic.Blank2NBSP(Generic.Date2ddmmccyy(Generic.TDate2Date(xmlnode.getAttribute("PStop")))))
            Page.Response.Write("</td>")
            Page.Response.Write("<td>")
            Page.Response.Write(xmlnode.getAttribute("P_ID"))
            Page.Response.Write("</td>")
            Page.Response.Write("<td>")
            '02-11-2007 Error code 29
            If Not IsDBNull(xmlnode.getAttribute("HasNotes")) AndAlso xmlnode.getAttribute("HasNotes") = "1" Then
                Page.Response.Write("<img title=""This item has notes attached."" src=""../../images/ocs/classAttachedNote.gif"" WIDTH=""16"" HEIGHT=""16"" style=""cursor:hand"" onclick=""RowSelectByPID(" & xmlnode.GetAttribute("P_ID") & ");DoAction(OCS_ANNOTATE);"">")
            Else
                Page.Response.Write("&nbsp;")
            End If
            Page.Response.Write("</td>")
            Page.Response.Write("<td>")
            '02-11-2007 Error code 29
            If Not IsDBNull(xmlnode.getAttribute("Patient_Own")) AndAlso xmlnode.getAttribute("Patient_Own") = "1" Then
                Page.Response.Write("<img title=""This item has Patients Own Medication Notes attached."" src=""../../images/user/Note3.gif"" WIDTH=""16"" HEIGHT=""16"">")
            Else
                Page.Response.Write("&nbsp;")
            End If
            Page.Response.Write("</td>")
            If Not IsDBNull(xmlnode.getAttribute("RptDisp")) Then
                Page.Response.Write("<td>")
                If xmlnode.getAttribute("RptDisp") = "4" Then
                    Page.Response.Write("<img title=""This is a Robot Rpt Prescription."" src=""../../images/user/Pill - Robot.gif"" WIDTH=""16"" HEIGHT=""16"">")
                ElseIf xmlnode.getAttribute("RptDisp") = "3" Then
                    Page.Response.Write("<img title=""This is an out of use Robot Rpt Prescription."" src=""../../images/user/Pill - Robot - Not in use.gif"" WIDTH=""16"" HEIGHT=""16"">")
                ElseIf xmlnode.getAttribute("RptDisp") = "2" Then
                    Page.Response.Write("<img title=""This is an out of use Rpt Prescription."" src=""../../images/user/Pill - Not in use.gif"" WIDTH=""16"" HEIGHT=""16"">")
                ElseIf xmlnode.getAttribute("RptDisp") = "1" Then
                    Page.Response.Write("<img title=""This is a Rpt Prescription."" src=""../../images/user/Pill - in use.gif"" WIDTH=""16"" HEIGHT=""16"">")
                Else
                    Page.Response.Write("&nbsp;")
                End If
                Page.Response.Write("</td>")
            ElseIf PSO Then
                Page.Response.Write("<td>&nbsp;</td>")
            End If
            Page.Response.Write("</tr>")
            count += 1
        Next
        xmldoc = Nothing
    End Sub

    ''' <summary>
    ''' Renders dispensings on PMR
    ''' The list of dispensings is normaly returned by sp
    '''    pWLabelByPrescriptionIDXML
    ''' </summary>
    ''' <param name="Page">PMR page the dispensings are to be displyed on</param>
    ''' <param name="xmldoc">xml doc that contains the dispensings (returns from sps above)</param>
    ''' <param name="requestID_Prescription">prarent request id dispensings are linked to</param>
    ''' <param name="level">parent child level of the prescription (main prescription level 0, merged prescriptions or dispensings level 1)</param>
    ''' <param name="repeatDispensing">If in repear dispensing mode</param>
    Public Shared Sub RenderDispensings(ByRef Page As System.Web.UI.Page, ByVal xmldoc As Object, ByVal requestID_Prescription As Long, ByVal level As Long, ByVal repeatDispensing As Boolean, ByVal PSO As Boolean)
        Dim xmlnodelist As XmlNodeList  ' Dim xmlnodelist As Object XN 13Mar13 59024 Memory Leak 
        Dim xmlnode As XmlElement       ' Dim xmlnode As Object XN 13Mar13 59024 Memory Leak 
        Dim today As DateTime = DateTime.Now.Date
        Dim yesterday As DateTime = today.AddDays(-1.0)
        Dim count As Integer = 0
        '<D D_ID="302512" D_RequestTypeID="28" Text="KETOPROFEN 100mg M/R CAPSULE when required" IssType="O" LastDate="05112004" LastQty="0" Start="1053921023" Stop="1054183103" D_IsCurrent="0" DispUserName="Peter Hughes" DispUserInitials="PH" SiteID="123" SiteName="abcdef" NSVCode="DTK401F" DispSite="321" SplitDose = "0"/>
        xmlnodelist = xmldoc.selectNodes("//D")
        ' For Each xmlnode In xmlnodelist   XN 13Mar13 59024 Memory Leak 
        For n As Int32 = 0 To xmlnodelist.Count - 1
            xmlnode = xmlnodelist.Item(n)
            'Response.Write(xmlnode.getAttribute("NSVCode"))
            Page.Response.Write("<tr pres_row='false' i=""")
            Page.Response.Write(xmlnode.getAttribute("D_ID"))
            Page.Response.Write(""" c=""D"" ic=""")
            Page.Response.Write(xmlnode.getAttribute("D_IsCurrent"))
            Page.Response.Write(""" p=""")
            Page.Response.Write(requestID_Prescription)
            Page.Response.Write("""")
            Page.Response.Write(" Level=""" + level.ToString() + """")
            Page.Response.Write(" >")
            Page.Response.Write("<td class=""x"">&nbsp;</td>")
            Page.Response.Write("<td>")
            For ind As Integer = 0 To level
                Page.Response.Write("&nbsp;&nbsp;&nbsp;")
            Next
	    If Not IsDBNull(xmlnode.getAttribute("SplitDose")) Then
		If xmlnode.getAttribute("SplitDose") = "1" Then
		    Page.Response.Write("<img title=""This is a split dose dispensing."" src=""../../images/user/SplitDispens.gif"" WIDTH=""16"" HEIGHT=""16"">")
		End If
	    End If
            Page.Response.Write(Generic.Blank2NBSP(xmlnode.getAttribute("Text")))
            Page.Response.Write("</td>")
            Page.Response.Write("<td>")
            Page.Response.Write(Generic.Blank2NBSP(xmlnode.getAttribute("IssType")))
            Page.Response.Write("</td>")
            Page.Response.Write("<td>")
            Page.Response.Write(Generic.Blank2NBSP(xmlnode.getAttribute("NSVCode")))
            Page.Response.Write("</td>")
            Page.Response.Write("<td>")
            Page.Response.Write(Generic.Blank2NBSP(xmlnode.getAttribute("WardCode")))
            Page.Response.Write("</td>")
            Page.Response.Write("<td>")
            Page.Response.Write(Generic.Blank2NBSP(xmlnode.getAttribute("ConsCode")))
            Page.Response.Write("</td>")
            Page.Response.Write("<td title=""")
            Page.Response.Write(xmlnode.getAttribute("DispUserName"))
            Page.Response.Write(""">")
            Page.Response.Write(Generic.Blank2NBSP(xmlnode.getAttribute("DispUserInitials")))
            Page.Response.Write("</td>")
            Page.Response.Write("<td title=""")
            Page.Response.Write(xmlnode.getAttribute("SiteName"))
            Page.Response.Write(""">")
            Page.Response.Write(Generic.Blank2NBSP(xmlnode.getAttribute("DispSite")))
            Page.Response.Write("</td>")

            ' Determine if date should be highlighted
            ' If dispensed today then bold red
            ' If dispensed yesturday then italic red
            Dim dipDate As DateTime = Generic.TDate2Date(xmlnode.getAttribute("LastDate"))
            Page.Response.Write("<td")
            If (dipDate >= today) Then
                Page.Response.Write(" class=""HighlightDate1"" ")
            ElseIf (dipDate >= yesterday) Then
                Page.Response.Write(" class=""HighlightDate2"" ")
            End If
            Page.Response.Write(">")
            Page.Response.Write(Generic.Blank2NBSP(Generic.Date2ddmmccyy(dipDate)))
            Page.Response.Write("</td>")

            Page.Response.Write("<td><button class=""LastQty"" id=button1 name=button1>")
            Page.Response.Write(Generic.TidyDecimal(xmlnode.getAttribute("LastQty")))
            Page.Response.Write("</button></td>")
            Page.Response.Write("<td>&nbsp;</td>")
            Page.Response.Write("<td>&nbsp;</td>")
            Page.Response.Write("<td>")
            Page.Response.Write(xmlnode.getAttribute("D_ID"))
            Page.Response.Write("</td>")
            Page.Response.Write("<td>&nbsp;</td>")
            If repeatDispensing Then
                Page.Response.Write("<td>&nbsp;</td>")

                If Not IsDBNull(xmlnode.getAttribute("RptDisp")) Then
                    Page.Response.Write("<td>")
                    If xmlnode.getAttribute("RptDisp") = "4" Then
                        Page.Response.Write("<img title=""This is a Robot Rpt Prescription."" src=""../../images/user/Pill - Robot.gif"" WIDTH=""16"" HEIGHT=""16"">")
                    ElseIf xmlnode.getAttribute("RptDisp") = "3" Then
                        Page.Response.Write("<img title=""This is an out of use Robot Rpt Prescription."" src=""../../images/user/Pill - Robot - Not in use.gif"" WIDTH=""16"" HEIGHT=""16"">")
                    ElseIf xmlnode.getAttribute("RptDisp") = "2" Then
                        Page.Response.Write("<img title=""This is an out of use Rpt Prescription."" src=""../../images/user/Pill - Not in use.gif"" WIDTH=""16"" HEIGHT=""16"">")
                    ElseIf xmlnode.getAttribute("RptDisp") = "1" Then
                        Page.Response.Write("<img title=""This is a Rpt Prescription."" src=""../../images/user/Pill - in use.gif"" WIDTH=""16"" HEIGHT=""16"">")
                    Else
                        Page.Response.Write("&nbsp;")
                    End If
                    Page.Response.Write("</td>")
                Else
                    Page.Response.Write("<td>&nbsp;</td>")
                End If

                '03May11 TH Replaced with above
                'If Generic.Blank2NBSP(xmlnode.getAttribute("RptDisp"))="1" then
                '	Response.Write("<td><img title=""This is a Rpt Dispensing."" src=""../../images/user/pill2.gif"" WIDTH=""16"" HEIGHT=""16""></img></td>")
                'Else
                '	Response.Write("<td>&nbsp;</td>")
                'End if
            ElseIf PSO Then
		Page.Response.Write("<td>&nbsp;</td>")
		If Not IsDBNull(xmlnode.getAttribute("PSO")) AndAlso xmlnode.getAttribute("PSO") = "1" Then
                        Page.Response.Write("<td><img title=""This is a Patient Specific Order."" src=""../../images/user/person.gif"" WIDTH=""16"" HEIGHT=""16""></td>")
		Else
                    Page.Response.Write("<td>&nbsp;</td>")
                End If
                    
	    Else
                Page.Response.Write("<td>&nbsp;</td>")
            End If
            Page.Response.Write("</tr>")

            count += 1
        Next
    End Sub

    ' Private Shared Sub AddAmendStatus(ByVal SessionID As Integer, ByVal WorklistItems As MSXML2.IXMLDOMNodeList) XN 13Mar13 59024 Memory Leak Fix
    Private Shared Sub AddAmendStatus(ByVal SessionID As Integer, ByVal WorklistItems As XmlNodeList)
        Dim RequestIDList As String = String.Empty

        ' For Each WorklistItem As MSXML2.IXMLDOMElement In WorklistItems XN 13Mar13 59024 Memory Leak Fix
        For n As Int32 = 0 To WorklistItems.Count - 1
            Dim WorklistItem As XmlElement = WorklistItems.Item(n)
            Dim ID As Object = WorklistItem.getAttribute("P_ID")
            If Not IsDBNull(ID) Then
                If RequestIDList.Length > 0 Then
                    RequestIDList &= ","
                End If
                RequestIDList &= ID.ToString()
            End If
        Next
        Dim AmendStatusXML As String
        If RequestIDList.Length > 0 Then
            AmendStatusXML = "<root>" & New OCSRTL10.PrescriptionRead().PrescriptionCanBeAmendedByRequestIDList(SessionID, RequestIDList) & "</root>"
        Else
            AmendStatusXML = "<root></root>"
        End If
'        Dim AmendStatusDoc As New MSXML2.DOMDocument()  XN 13Mar13 59024 Memory Leak Fix
        Dim AmendStatusDoc As New XmlDocument
        AmendStatusDoc.loadXML(AmendStatusXML)
'        For Each WorklistItem As MSXML2.IXMLDOMElement In WorklistItems    XN 13Mar13 59024 Memory Leak Fix
        For n As Int32 = 0 To WorklistItems.Count - 1
            Dim WorklistItem As XmlElement =  WorklistItems.Item(n)
            Dim ID As Object = WorklistItem.getAttribute("P_ID")
            If Not IsDBNull(ID) Then
'                Dim AmendStatus As MSXML2.IXMLDOMElement = AmendStatusDoc.selectSingleNode("root/Prescription[@RequestID='" & ID.ToString() & "']")    XN 13Mar13 59024 Memory Leak Fix
                Dim AmendStatus As XmlElement = AmendStatusDoc.selectSingleNode("root/Prescription[@RequestID='" & ID.ToString() & "']")
                If Not AmendStatus Is Nothing Then
                    WorklistItem.setAttribute("P_CreationType", AmendStatus.getAttribute("CreationType"))
                    WorklistItem.setAttribute("CanStopOrAmend", AmendStatus.getAttribute("CanStopOrAmend"))
                End If
            End If
        Next
    End Sub
End Class
