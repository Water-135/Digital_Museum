<%@ Page Title="Exhibition Details" Language="C#" MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Member_ExhibitionDetails.aspx.cs"
    Inherits="G5_Digital_Museum.Member_ExhibitionDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <section class="detail-shell">
        <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="detail-empty">
            Exhibition not found.
        </asp:Panel>

        <asp:Panel ID="pnlDetail" runat="server" Visible="false">

            <div class="detail-top">
                <div class="detail-meta">
                    <asp:Label ID="lblCategory" runat="server" CssClass="detail-category" />
                    <h1><asp:Label ID="lblTitle" runat="server" /></h1>
                    <p class="detail-subline">
                        <strong>Date:</strong> <asp:Label ID="lblDate" runat="server" />
                        &nbsp;&nbsp;&nbsp;
                        <strong>Timeline:</strong> <asp:Label ID="lblTimeline" runat="server" />
                    </p>
                    <p class="detail-subline">
                        <strong>Location:</strong> <asp:Label ID="lblLocation" runat="server" />
                    </p>
                </div>
            </div>

            <div class="detail-image-wrap">
                <asp:Image ID="imgExhibition" runat="server" CssClass="detail-image" />
            </div>

            <div class="detail-content">
                <h2>About This Exhibition</h2>
                <asp:Literal ID="litDescription" runat="server" />
            </div>

            <div class="detail-actions">
                <a href="Member_AllExhibitions.aspx" class="detail-btn">BACK TO EXHIBITIONS</a>
            </div>

        </asp:Panel>
    </section>

</asp:Content>