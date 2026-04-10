<%@ Page Title="Home" Language="C#" MasterPageFile="~/GuestSite.Master" AutoEventWireup="true" CodeBehind="Guest_Homepage.aspx.cs" Inherits="G5_Digital_Museum.Guest_Homepage" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <!-- Internal CSS specific to homepage -->
    <style type="text/css">
        .hero-bg-pattern {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 0;
            background-image: 
                repeating-linear-gradient(
                    0deg,
                    transparent,
                    transparent 50px,
                    rgba(196, 164, 74, 0.02) 50px,
                    rgba(196, 164, 74, 0.02) 51px
                );
            pointer-events: none;
        }
        .exhibit-highlight {
            border-left: 3px solid #8b1a1a;
            padding-left: 20px;
            margin: 40px 0;
        }
        .card-image {
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 60px 0;
        }

        .card-image svg {
            width: 70px;
            height: 70px;
            stroke: #c4a44a;
            stroke-width: 1.8;
            transition: 0.3s ease;
        }

        .card:hover .card-image svg {
            stroke: #e0c36d;
            transform: scale(1.05);
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- ==================== HERO SECTION ==================== -->
    <section class="hero-section" id="hero">
        <div class="hero-bg-pattern"></div>
        <div class="hero-content">
            <span class="hero-label fade-in-up delay-1">Digital Museum &amp; Learning Platform</span>
            <h1 class="hero-title fade-in-up delay-2">
                Nanjing Massacre
            </h1>
            <p class="hero-subtitle fade-in-up delay-3">
                <em>Remembering. Learning. Never Forgetting.</em>
            </p>
            <p class="hero-date fade-in-up delay-3">DECEMBER 1937 &mdash; JANUARY 1938</p>
            <p class="hero-description fade-in-up delay-4">
                An interactive digital museum preserving the historical memory of the Nanjing Massacre. 
                Explore primary sources, survivor testimonies, and educational materials to understand 
                one of the most devastating events of World War II.
            </p>
            <div class="hero-actions fade-in-up delay-5">
                <asp:HyperLink ID="btnExploreTimeline" runat="server" NavigateUrl="~/Guest_Timeline.aspx" CssClass="btn btn-primary">
                    Explore Timeline
                </asp:HyperLink>
                <asp:HyperLink ID="btnViewGallery" runat="server" NavigateUrl="~/Guest_Gallery.aspx" CssClass="btn btn-outline">
                    View Gallery
                </asp:HyperLink>
            </div>
        </div>
    </section>

    <!-- ==================== MEMORIAL RIBBON ==================== -->
    <div class="memorial-ribbon">
        &#x1F56F; In memory of the over 300,000 victims of the Nanjing Massacre &mdash; Lest We Forget
    </div>

    <!-- ==================== STATISTICS ==================== -->
    <section class="section" aria-label="Key Statistics">
        <div class="container">
            <div class="stats-row">
                <div class="stat-item">
                    <span class="stat-number">300,000+</span>
                    <span class="stat-label">Estimated Victims</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number">6</span>
                    <span class="stat-label">Weeks of Atrocities</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number">1937</span>
                    <span class="stat-label">Year of Tragedy</span>
                </div>
                <div class="stat-item">
                    <span class="stat-number">22</span>
                    <span class="stat-label">Safety Zone Rescuers</span>
                </div>
            </div>
        </div>
    </section>

    <!-- ==================== EXHIBITS / FEATURED SECTIONS ==================== -->
    <section class="section section-dark" aria-label="Featured Exhibits">
        <div class="container">
            <div class="section-header">
                <span class="section-label">Featured Exhibits</span>
                <h2 class="section-title">Explore the Museum</h2>
                <p class="section-subtitle">
                    Navigate through curated collections of historical documents, photographs, 
                    survivor accounts, and interactive learning modules.
                </p>
                <div class="section-divider"></div>
            </div>

            <div class="card-grid">

                <!-- Card 1: Historical Timeline -->
                <article class="card">
                    <div class="card-image">
                        <i data-lucide="calendar"></i>
                    </div>
                    <div class="card-body">
                        <span class="card-category">Interactive Exhibit</span>
                        <h3 class="card-title">Historical Timeline</h3>
                        <p class="card-text">
                            Follow the chronological sequence of events from the fall of Shanghai 
                            in November 1937 through the capture of Nanjing and the weeks of 
                            devastation that followed.
                        </p>
                        <asp:HyperLink ID="lnkTimeline" runat="server" NavigateUrl="~/Guest_Timeline.aspx" CssClass="btn btn-sm btn-outline">
                            View Timeline &rarr;
                        </asp:HyperLink>
                    </div>
                </article>

                <!-- Card 2: Photo Gallery -->
                <article class="card">
                    <div class="card-image">
                        <i data-lucide="image"></i>
                    </div>
                    <div class="card-body">
                        <span class="card-category">Visual Archive</span>
                        <h3 class="card-title">Documentary Gallery</h3>
                        <p class="card-text">
                            Browse a curated collection of historical photographs and documents 
                            that serve as visual evidence of the events during the Nanjing Massacre.
                        </p>
                        <asp:HyperLink ID="lnkGallery" runat="server" NavigateUrl="~/Guest_Gallery.aspx" CssClass="btn btn-sm btn-outline">
                            Browse Gallery &rarr;
                        </asp:HyperLink>
                    </div>
                </article>

                <!-- Card 3: Learning Resources -->
                <article class="card">
                    <div class="card-image">
                        <i data-lucide="book-open"></i>
                    </div>
                    <div class="card-body">
                        <span class="card-category">Education</span>
                        <h3 class="card-title">Learning Resources</h3>
                        <p class="card-text">
                            Access educational materials including reading lists, documentary films, 
                            academic papers, and self-assessment quizzes for students and educators.
                        </p>
                        <asp:HyperLink ID="lnkResources" runat="server" NavigateUrl="~/Guest_Resources.aspx" CssClass="btn btn-sm btn-outline">
                            Start Learning &rarr;
                        </asp:HyperLink>
                    </div>
                </article>

            </div>
        </div>
    </section>

    <!-- ==================== HISTORICAL CONTEXT SECTION ==================== -->
    <section class="section" aria-label="Historical Context">
        <div class="container">
            <div class="section-header">
                <span class="section-label">Historical Context</span>
                <h2 class="section-title">Understanding the Tragedy</h2>
                <div class="section-divider"></div>
            </div>

            <div style="max-width: 800px; margin: 0 auto;">
                <p style="color: #999; line-height: 1.8; margin-bottom: 24px; font-size: 16px;">
                    The Nanjing Massacre, also known as the Rape of Nanking, took place following 
                    the Japanese military's capture of Nanjing, the then-capital of the Republic of China, 
                    on December 13, 1937. Over the following six weeks, Imperial Japanese forces committed 
                    widespread atrocities against the civilian population and disarmed combatants.
                </p>

                <div class="exhibit-highlight">
                    <h3 style="color: #c4a44a; font-family: 'Playfair Display', serif; font-size: 1.2rem; margin-bottom: 8px;">
                        The Nanjing Safety Zone
                    </h3>
                    <p style="color: #999; line-height: 1.8; font-size: 15px;">
                        A group of international residents, including John Rabe and Minnie Vautrin, 
                        established a safety zone that sheltered approximately 250,000 Chinese civilians 
                        during the massacre. Their diaries and letters provide crucial firsthand accounts 
                        of the events.
                    </p>
                </div>

                <p style="color: #999; line-height: 1.8; margin-bottom: 24px; font-size: 16px;">
                    The International Military Tribunal for the Far East (1946&ndash;1948) estimated that 
                    over 200,000 Chinese people were killed, while Chinese sources place the figure at 
                    over 300,000. The massacre remains one of the most significant atrocities of the 
                    Second Sino-Japanese War.
                </p>
            </div>
        </div>
    </section>

    <!-- ==================== CALL TO ACTION: REGISTER ==================== -->
    <section class="section section-charcoal" aria-label="Join the Community">
        <div class="container">
            <div class="section-header">
                <span class="section-label">Join Our Community</span>
                <h2 class="section-title">Become a Registered Learner</h2>
                <p class="section-subtitle">
                    Create a free account to access exclusive educational modules, 
                    save your progress through interactive timelines, contribute to discussions, 
                    and add entries to the digital guestbook.
                </p>
                <div class="section-divider"></div>
            </div>
            <div style="text-align: center;">
                <asp:HyperLink ID="btnRegister" runat="server" NavigateUrl="~/Member_Registration.aspx" CssClass="btn btn-primary" style="margin-right: 12px;">
                    Create Free Account
                </asp:HyperLink>
                <asp:HyperLink ID="btnLogin" runat="server" NavigateUrl="~/Main_LoginPage.aspx" CssClass="btn btn-outline">
                    Already Registered? Sign In
                </asp:HyperLink>
            </div>
        </div>
    </section>

    <!-- ==================== GUESTBOOK PREVIEW ==================== -->
    <section class="section" aria-label="Recent Guestbook Entries">
        <div class="container">
            <div class="section-header">
                <span class="section-label">Visitor Guestbook</span>
                <h2 class="section-title">Words of Remembrance</h2>
                <p class="section-subtitle">
                    Visitors from around the world share their reflections after exploring the museum.
                </p>
                <div class="section-divider"></div>
            </div>

            <!-- Display recent feedback entries from database -->
            <asp:Repeater ID="rptRecentFeedback" runat="server">
                <ItemTemplate>
                    <div class="feedback-entry">
                        <div class="entry-header">
                            <span class="entry-name"><%# Eval("VisitorName") %></span>
                            <span class="entry-date"><%# Eval("SubmittedDate", "{0:MMMM dd, yyyy}") %></span>
                        </div>
                        <div class="stars"><%# GetStarRating((int)Eval("Rating")) %></div>
                        <p class="entry-message"><%# Server.HtmlEncode(Eval("Message").ToString()) %></p>
                    </div>
                </ItemTemplate>
            </asp:Repeater>

            <asp:Label ID="lblNoFeedback" runat="server" Visible="false" 
                style="display: block; text-align: center; color: #555; padding: 40px; font-size: 14px;">
                No guestbook entries yet. Be the first to leave a message.
            </asp:Label>

            <div style="text-align: center; margin-top: 32px;">
                <asp:HyperLink ID="lnkGuestbook" runat="server" NavigateUrl="~/Guest_Feedback.aspx" CssClass="btn btn-sm btn-outline">
                    View Full Guestbook &rarr;
                </asp:HyperLink>
            </div>
        </div>
    </section>

</asp:Content>
