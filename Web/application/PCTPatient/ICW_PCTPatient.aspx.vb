Imports Ascribe.pharmacy.shared

Partial Class application_PCTPatient_ICW_PCTPatient
    Inherits System.Web.UI.Page

    Protected SiteID As Integer
    Protected siteNumber As Integer

    Private Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Dim sessionID As Integer
        sessionID = CInt(Request.QueryString("SessionID"))
        siteNumber = CInt(Request.QueryString("SiteNumber"))
        SessionInfo.InitialiseSessionAndSiteNumber(sessionID, siteNumber)
        SiteID = SessionInfo.SiteID
    End Sub
End Class
