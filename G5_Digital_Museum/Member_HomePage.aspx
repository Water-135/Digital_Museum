<%@ Page Title="Member Home" Language="C#" MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Member_HomePage.aspx.cs" Inherits="G5_Digital_Museum.Member_HomePage" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <section class="member-hero">
        <div class="member-hero-inner">
            <asp:Label ID="lblWelcome" runat="server" CssClass="member-welcome" />
            <p class="member-subtitle">
                Explore exhibitions, modules, quizzes, save favourites, and leave your reflections respectfully.
            </p>
        </div>
    </section>

    <section class="member-grid-wrap">
        <div class="member-grid">

            <div class="member-card">
                <span class="member-tag">EXPLORE</span>
                <h3>All Exhibitions</h3>
                <p>Browse the full list of exhibitions available for members.</p>
                <a href="<%= ResolveUrl("~/Member_AllExhibitions.aspx") %>" class="member-btn">OPEN</a>
            </div>

            <div class="member-card">
                <span class="member-tag">LEARN</span>
                <h3>Modules</h3>
                <p>Read learning modules and understand the historical content in depth.</p>
                <a href="<%= ResolveUrl("~/Member_Modules.aspx") %>" class="member-btn">OPEN</a>
            </div>

            <div class="member-card">
                <span class="member-tag">ASSESS</span>
                <h3>Quiz</h3>
                <p>Test your understanding through quizzes and interactive questions.</p>
                <a href="<%= ResolveUrl("~/Member_Quiz.aspx") %>" class="member-btn">OPEN</a>
            </div>

            <div class="member-card">
                <span class="member-tag">SEARCH</span>
                <h3>Browse & Search</h3>
                <p>Use the search tool to find specific exhibits quickly.</p>
                <a href="<%= ResolveUrl("~/Member_BrowseAndSearch.aspx") %>" class="member-btn">OPEN</a>
            </div>

            <div class="member-card">
                <span class="member-tag">ENGAGE</span>
                <h3>Comment & Review</h3>
                <p>Share thoughtful comments and ratings with respect.</p>
                <a href="<%= ResolveUrl("~/Member_CommentAndReview.aspx") %>" class="member-btn">OPEN</a>
            </div>

            <div class="member-card">
                <span class="member-tag">SAVED</span>
                <h3>Favourite</h3>
                <p>View the exhibitions you saved to your favourites.</p>
                <a href="<%= ResolveUrl("~/Member_SaveToFavourite.aspx") %>" class="member-btn">OPEN</a>
            </div>

        </div>
    </section>
</asp:Content>