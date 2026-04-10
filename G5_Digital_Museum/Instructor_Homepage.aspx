<%@ Page Title="Instructor_Homepage" Language="C#" MasterPageFile="~/Master/Instructor_Master.Master" AutoEventWireup="true" CodeBehind="Instructor_Homepage.aspx.cs" Inherits="G5_Digital_Museum.Instructor_Homepage" %>

<asp:Content ID="Main1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="pagehead">
        <div class="pagehead-left">
            <div class="pagehead-kicker">Instructor Panel</div>
            <h1>Dashboard</h1>
            <p>Manage exhibitions, modules, quizzes, and learner feedback from one workspace.</p>
        </div>
        <div class="pagehead-actions">
            <a class="btn" href="Instructor_Exhibition_Manage.aspx">&#43; Exhibition</a>
            <a class="btn" href="Instructor_Quiz_Manage.aspx">&#43; Quiz</a>
        </div>
    </div>

    <!-- METRICS -->
    <div class="metrics-row">
        <article class="metric-card">
            <div class="metric-icon">&#127963;</div>
            <div class="metric-body">
                <div class="metric-label">Exhibitions</div>
                <div class="metric-value"><asp:Label ID="lblTotalExhibitions" runat="server" Text="0" /></div>
                <div class="metric-sub">
                    <asp:Label ID="lblPublishedExh" runat="server" Text="0" /> published &nbsp;·&nbsp;
                    <asp:Label ID="lblDraftExh"     runat="server" Text="0" /> draft
                </div>
            </div>
        </article>
        <article class="metric-card">
            <div class="metric-icon">&#128218;</div>
            <div class="metric-body">
                <div class="metric-label">Modules</div>
                <div class="metric-value"><asp:Label ID="lblTotalModules" runat="server" Text="0" /></div>
                <div class="metric-sub"><asp:Label ID="lblPublishedMod" runat="server" Text="0" /> published</div>
            </div>
        </article>
        <article class="metric-card metric-card--alert">
            <div class="metric-icon">&#128172;</div>
            <div class="metric-body">
                <div class="metric-label">Pending Feedback</div>
                <div class="metric-value"><asp:Label ID="lblPendingFeedback" runat="server" Text="0" /></div>
                <div class="metric-sub">Needs attention</div>
            </div>
        </article>
        <article class="metric-card">
            <div class="metric-icon">&#9997;</div>
            <div class="metric-body">
                <div class="metric-label">Quizzes</div>
                <div class="metric-value"><asp:Label ID="lblTotalQuizzes" runat="server" Text="0" /></div>
                <div class="metric-sub">Across all modules</div>
            </div>
        </article>
    </div>

    <!-- NOTICE BANNER -->
    <div class="notice-banner">
        <div class="notice-icon">&#9888;</div>
        <div class="notice-text">
            <strong>Content Notice</strong>
            <span>All descriptions, images, and testimonies must remain respectful and properly sourced before publishing.</span>
        </div>
        <a class="btn" href="Instructor_Feedback.aspx">Review Feedback &#8594;</a>
    </div>

    <div class="page-shell">

        <!-- MAIN COLUMN -->
        <div class="main-stack">

            <!-- RECENT EXHIBITIONS -->
            <section class="panel">
                <div class="panel-header">
                    <div>
                        <h2 class="panel-title">Recent Exhibitions</h2>
                        <p class="panel-subtitle">Latest exhibitions added or updated.</p>
                    </div>
                    <a class="btn" href="Instructor_Exhibition_Manage.aspx">View All &#8594;</a>
                </div>
                <div class="content-grid">
                    <asp:Repeater ID="rptRecentExhibitions" runat="server">
                        <ItemTemplate>
                            <div class="content-card">
                                <div class="content-card__image">
                                    <img src='<%# string.IsNullOrEmpty(Eval("ImageUrl")?.ToString())
                                        ? "https://images.unsplash.com/photo-1503152394-c571994fd383?w=600"
                                        : Eval("ImageUrl") %>' alt='<%# Eval("Title") %>' />
                                    <span class="content-card__pill"><%# Eval("Category") %></span>
                                </div>
                                <div class="content-card__body">
                                    <div class="content-card__meta">
                                        <span class='chip <%# Eval("Status").ToString()=="Published"?"chip--live":"chip--draft" %>'><%# Eval("Status") %></span>
                                        <span class="chip">&#128197; <%# Eval("CreatedDate") %></span>
                                    </div>
                                    <h3 class="content-card__title"><%# Eval("Title") %></h3>
                                    <p class="content-card__desc"><%# Eval("Preview") %></p>
                                    <a class="btn" href="Instructor_Exhibition_Manage.aspx">Edit &#8594;</a>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <asp:Label ID="lblNoExh" runat="server" Visible="false"
                    style="display:block;text-align:center;padding:40px;color:#555;font-size:13px;">
                    No exhibitions yet. <a href="Instructor_Exhibition_Manage.aspx" style="color:#c4a44a;">Create one &#8594;</a>
                </asp:Label>
            </section>

            <!-- RECENT MODULES -->
            <section class="panel">
                <div class="panel-header">
                    <div>
                        <h2 class="panel-title">Recent Modules</h2>
                        <p class="panel-subtitle">Latest learning modules created.</p>
                    </div>
                    <a class="btn" href="Instructor_Module_Manage.aspx">View All &#8594;</a>
                </div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead>
                            <tr><th>#</th><th>Module Title</th><th>Created</th><th>Status</th></tr>
                        </thead>
                        <tbody>
                            <asp:Repeater ID="rptRecentModules" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td class="td-muted"><%# Eval("SortOrder") %></td>
                                        <td><strong style="color:#f5f2ed;"><%# Eval("Title") %></strong></td>
                                        <td><span class="chip"><%# Eval("CreatedDate") %></span></td>
                                        <td><span class='chip <%# Eval("Status").ToString()=="Published"?"chip--live":"chip--draft" %>'><%# Eval("Status") %></span></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </section>

        </div>

        <!-- SIDEBAR -->
        <aside class="side-stack">

            <!-- PENDING FEEDBACK -->
            <section class="panel">
                <div class="panel-header">
                    <div>
                        <h3 class="panel-title">Pending Feedback</h3>
                        <p class="panel-subtitle">Needs your review.</p>
                    </div>
                    <asp:Label ID="lblPendingBadge" runat="server" CssClass="badge-count" Text="0" />
                </div>
                <div class="review-list">
                    <asp:Repeater ID="rptRecentFeedback" runat="server">
                        <ItemTemplate>
                            <div class="review-item">
                                <div class="review-item__dot review-item__dot--warn"></div>
                                <div class="review-item__body">
                                    <h4><%# Eval("VisitorName") %></h4>
                                    <p><%# Eval("Preview") %></p>
                                    <div class="review-item__foot">
                                        <span class="chip chip--gold">&#11088; <%# Eval("Rating") %></span>
                                        <span class="td-muted"><%# Eval("SubmitDate") %></span>
                                        <a class="btn btn-xs" href="Instructor_Feedback.aspx">Review</a>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
                <asp:Label ID="lblNoFeedback" runat="server" Visible="false"
                    style="display:block;text-align:center;padding:20px;color:#555;font-size:13px;">
                    No pending feedback &#10003;
                </asp:Label>
                <div style="text-align:right;padding:12px 0 0;">
                    <a class="btn btn-xs" href="Instructor_Feedback.aspx">All Feedback &#8594;</a>
                </div>
            </section>

            <!-- SNAPSHOT -->
            <section class="panel">
                <div class="panel-header">
                    <div>
                        <h3 class="panel-title">Snapshot</h3>
                        <p class="panel-subtitle">Live counts.</p>
                    </div>
                </div>
                <div class="stats-grid">
                    <div class="stat-box">
                        <span class="stat-box__label">Published</span>
                        <span class="stat-box__value"><asp:Label ID="lblSnapPublished" runat="server" Text="0" /></span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-box__label">Drafts</span>
                        <span class="stat-box__value"><asp:Label ID="lblSnapDraft" runat="server" Text="0" /></span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-box__label">Quizzes</span>
                        <span class="stat-box__value"><asp:Label ID="lblSnapQuizzes" runat="server" Text="0" /></span>
                    </div>
                    <div class="stat-box">
                        <span class="stat-box__label">Pending</span>
                        <span class="stat-box__value"><asp:Label ID="lblSnapPending" runat="server" Text="0" /></span>
                    </div>
                </div>
            </section>

            <!-- QUICK LINKS -->
            <section class="panel">
                <div class="panel-header"><div><h3 class="panel-title">Quick Links</h3></div></div>
                <div style="display:flex;flex-direction:column;gap:8px;padding-top:4px;">
                    <a class="btn" href="Instructor_Exhibition_Manage.aspx">&#127963;&nbsp; Exhibitions</a>
                    <a class="btn" href="Instructor_Module_Manage.aspx">&#128218;&nbsp; Modules</a>
                    <a class="btn" href="Instructor_Quiz_Manage.aspx">&#9997;&nbsp; Quizzes</a>
                    <a class="btn" href="Instructor_Feedback.aspx">&#128172;&nbsp; Feedback</a>
                    <a class="btn" href="Instructor_Profile.aspx">&#128100;&nbsp; My Profile</a>
                </div>
            </section>

        </aside>
    </div>

</asp:Content>
