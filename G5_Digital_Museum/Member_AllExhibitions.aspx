<%@ Page Title="All Exhibitions" Language="C#" MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Member_AllExhibitions.aspx.cs" Inherits="G5_Digital_Museum.Member_AllExhibitions" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

    <section class="exh-shell">
        <div class="exh-head">
            <div>
                <div class="exh-kicker">CONTENT DISCOVERY</div>
                <h1>Exhibitions</h1>
                <p>Browse published historical exhibitions in the Nanjing Massacre Digital Museum.</p>
            </div>
        </div>


        <div class="exh-toolbar">

            <div class="exh-filters">

                <asp:DropDownList 
                    ID="ddlCategory" 
                    runat="server"
                    CssClass="filter-dropdown"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged">
                </asp:DropDownList>

                <asp:DropDownList 
                    ID="ddlStatus"
                    runat="server"
                    CssClass="filter-dropdown"
                    AutoPostBack="true"
                    OnSelectedIndexChanged="ddlStatus_SelectedIndexChanged">
                </asp:DropDownList>

            </div>
        </div>

        <div class="exh-divider"></div>

        <div class="exh-count">
            <asp:Label ID="lblCount" runat="server" Text="0 exhibition(s)" />
        </div>

        <asp:Repeater ID="rptExhibitions" runat="server">
            <ItemTemplate>
                <div class="exh-card">
                    <div class="exh-image-wrap">
                        <asp:Image ID="imgExh" runat="server"
                            CssClass="exh-image"
                            ImageUrl='<%# string.IsNullOrEmpty(Eval("ImageUrl").ToString()) ? "~/images/no-image.png" : Eval("ImageUrl").ToString() %>'
                            AlternateText="Exhibition Image" />

     
                        <span class="exh-badge published">Published</span>
                    </div>

                    <div class="exh-body">
                        <div class="exh-category"><%# Eval("Category") %></div>
                        <h3><%# Eval("Title") %></h3>
                        <p>
                            <%# GetShortText(Eval("Description").ToString(), 140) %>
                        </p>

                        <asp:HyperLink ID="lnkRead" runat="server"
                            NavigateUrl='<%# "Member_ExhibitionDetails.aspx?id=" + Eval("ExhibitionID") %>'
                            CssClass="read-btn"
                            Text="READ MORE" />

                        <asp:LinkButton ID="btnSaveFavourite" runat="server"
                            CssClass="save-btn"
                            CommandName="save"
                            CommandArgument='<%# Eval("ExhibitionID") %>'
                            OnCommand="btnSaveFavourite_Command">
                            SAVE TO FAVOURITE
                        </asp:LinkButton>
                    </div>
                </div>
            </ItemTemplate>
        </asp:Repeater>

        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-box">
            No exhibitions found.
        </asp:Panel>
    </section>

</asp:Content>