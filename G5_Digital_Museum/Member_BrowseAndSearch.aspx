<%@ Page Title="Browse & Search" Language="C#" MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Member_BrowseAndSearch.aspx.cs"
    Inherits="G5_Digital_Museum.Member_BrowseAndSearch" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<section class="browse-hero">
    <div class="browse-hero-inner">
        <h1>Browse & Search</h1>
        <p>Search exhibitions, modules, and quizzes by title, category, or keywords.</p>
    </div>
</section>

<section class="browse-shell">

    <div class="browse-search-box">

    <asp:Panel ID="pnlResults" runat="server" Visible="false">
        <div class="result-summary">
            <asp:Label ID="lblSummary" runat="server"></asp:Label>
        </div>
    </asp:Panel>

    <label class="browse-label">KEYWORD</label>

    <asp:TextBox ID="txtKeyword" runat="server" CssClass="browse-input"></asp:TextBox>

    <div class="browse-actions">

        <asp:Button ID="btnSearch"
            runat="server"
            Text="SEARCH"
            CssClass="browse-btn gold"
            OnClick="btnSearch_Click" />

        <asp:Button ID="btnViewAll"
            runat="server"
            Text="VIEW ALL"
            CssClass="browse-btn dark"
            OnClick="btnViewAll_Click" />

    </div>

</div>

<asp:Panel ID="pnlResultsContent" runat="server" Visible="false">


        <!-- EXHIBITIONS -->
        <div class="result-section">

            <h2>Exhibitions</h2>

            <asp:Repeater ID="rptExhibitions" runat="server">

                <ItemTemplate>

                    <div class="result-card">

                        <div class="result-type">EXHIBITION</div>

                        <h3><%# Eval("Title") %></h3>

                        <p><%# GetShortText(Eval("Description").ToString(), 140) %></p>

                        <asp:HyperLink ID="lnkExhibition"
                            runat="server"
                            NavigateUrl='<%# "Member_ExhibitionDetails.aspx?id=" + Eval("ExhibitionID") %>'
                            CssClass="result-link"
                            Text="READ MORE" />

                    </div>

                </ItemTemplate>

            </asp:Repeater>

            <asp:Panel ID="pnlNoExhibitions" runat="server" Visible="false" CssClass="empty-box">
                No exhibitions found.
            </asp:Panel>

        </div>


        <!-- MODULES -->
        <div class="result-section">

            <h2>Modules</h2>

            <asp:Repeater ID="rptModules" runat="server">

                <ItemTemplate>

                    <div class="result-card">

                        <div class="result-type">MODULE</div>

                        <h3><%# Eval("Title") %></h3>

                        <p><%# GetShortText(Eval("Description").ToString(), 140) %></p>

                        <asp:HyperLink ID="lnkModule"
                            runat="server"
                            NavigateUrl='<%# "Member_ModulesContent.aspx?id=" + Eval("ModuleID") %>'
                            CssClass="result-link"
                            Text="READ MODULE" />

                    </div>

                </ItemTemplate>

            </asp:Repeater>

            <asp:Panel ID="pnlNoModules" runat="server" Visible="false" CssClass="empty-box">
                No modules found.
            </asp:Panel>

        </div>


        <!-- QUIZZES -->
        <div class="result-section">

            <h2>Quizzes</h2>

            <asp:Repeater ID="rptQuizzes" runat="server">

                <ItemTemplate>

                    <div class="result-card">

                        <div class="result-type">QUIZ</div>

                        <h3><%# Eval("Title") %></h3>

                        <p>
                            Quiz Type: <%# Eval("QuizType") %><br />
                            Pass Mark: <%# Eval("PassMark") %>%
                        </p>

                        <asp:HyperLink ID="lnkQuiz"
                            runat="server"
                            NavigateUrl='<%# "Member_Quiz.aspx?id=" + Eval("QuizID") %>'
                            CssClass="result-link"
                            Text="OPEN QUIZ" />

                    </div>

                </ItemTemplate>

            </asp:Repeater>

            <asp:Panel ID="pnlNoQuizzes" runat="server" Visible="false" CssClass="empty-box">
                No quizzes found.
            </asp:Panel>

        </div>

    </asp:Panel>

</section>

</asp:Content>