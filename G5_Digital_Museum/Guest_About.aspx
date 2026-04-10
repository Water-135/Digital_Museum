<%@ Page Title="About" Language="C#" MasterPageFile="~/GuestSite.Master" AutoEventWireup="true" CodeBehind="Guest_About.aspx.cs" Inherits="G5_Digital_Museum.Guest_About" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Internal CSS: About page feature icons */
        .feature-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
            gap: 24px;
            margin-top: 48px;
        }
        .feature-item {
            background: #1e1e1e;
            border: 1px solid rgba(196, 164, 74, 0.2);
            padding: 32px 24px;
            text-align: center;
            transition: border-color 0.3s ease;
        }
        .feature-item:hover {
            border-color: rgba(196, 164, 74, 0.5);
        }
        .feature-item {
            background: #1e1e1e;
            border: 1px solid rgba(196, 164, 74, 0.2);
            padding: 40px 24px;
            text-align: center;
            transition: border-color 0.3s ease;

            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .feature-item svg {
            width: 64px !important;
            height: 64px !important;
            stroke-width: 2px !important;
            color: #c4a44a;
            margin-bottom: 20px;
        }
        .feature-item h3 {
            font-size: 1rem;
            margin-bottom: 8px;
            color: #c4a44a;
        }
        .feature-item p {
            font-size: 13px;
            color: #999;
            line-height: 1.6;
        }
        .team-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 20px;
            margin-top: 40px;
        }
        .team-card {
            background: #1e1e1e;
            border: 1px solid rgba(196, 164, 74, 0.15);
            padding: 32px 20px;
            text-align: center;
        }
        .team-avatar {
            width: 72px;
            height: 72px;
            background: #2a2a2a;
            border-radius: 50%;
            margin: 0 auto 16px;
            display: flex;
            align-items: center;
            justify-content: center;

        }
        .team-avatar svg {
            width: 28px;
            height: 28px;
            stroke: #c4a44a;
        }
        .team-card h4 {
            font-size: 0.95rem;
            color: #f5f2ed;
            margin-bottom: 4px;
        }
        .team-card p {
            font-size: 12px;
            color: #999;
        }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="content-page">

        <!-- Page Hero -->
        <div class="page-hero">
            <div class="container">
                <span class="section-label">About</span>
                <h1>About This Museum</h1>
                <p>Understanding our mission, purpose, and the people behind this digital memorial.</p>
            </div>
        </div>

        <!-- Mission Section -->
        <section class="section">
            <div class="content-block">
                <h2>Our Mission</h2>
                <p>
                    The Digital Museum: Nanjing Massacre is a web-based educational platform dedicated 
                    to preserving the historical memory of the Nanjing Massacre (December 1937 &ndash; 
                    January 1938). Through interactive exhibits, primary source documents, and curated 
                    learning materials, we aim to ensure that this chapter of history is not forgotten.
                </p>

                <blockquote>
                    &ldquo;Those who cannot remember the past are condemned to repeat it.&rdquo;
                    &mdash; George Santayana
                </blockquote>

                <h2>Why a Digital Museum?</h2>
                <p>
                    Physical museums and memorial sites play a vital role in historical preservation, 
                    but geography can limit access. A digital museum removes those barriers, providing 
                    students, educators, and the general public worldwide with free access to educational 
                    content about this significant historical event.
                </p>
                <p>
                    This platform uses interactive web technologies to create an engaging learning 
                    experience that goes beyond static text. Through timelines, galleries, and structured 
                    learning modules, visitors can explore the subject at their own pace and depth.
                </p>

                <h2>Educational Objectives</h2>
                <p>
                    This digital museum supports several key educational goals: helping visitors understand 
                    the historical context of the Second Sino-Japanese War, providing access to primary 
                    source materials and documented evidence, honouring the memory of the victims and 
                    survivors, and promoting awareness of the importance of international humanitarian law 
                    and human rights.
                </p>
            </div>
        </section>

        <!-- Features Section -->
        <section class="section section-dark">
            <div class="container">
                <div class="section-header">
                    <span class="section-label">Platform</span>
                    <h2 class="section-title">Museum Features</h2>
                    <div class="section-divider"></div>
                </div>

                <div class="feature-grid">
                    <div class="feature-item">
                        <i data-lucide="calendar" class="feature-icon"></i>
                        <h3>Interactive Timeline</h3>
                        <p>Navigate through key events chronologically with detailed descriptions and source references.</p>
                    </div>
                    <div class="feature-item">
                        <i data-lucide="image" class="feature-icon"></i>
                        <h3>Documentary Gallery</h3>
                        <p>Browse curated collections of historical photographs, documents, and visual evidence.</p>
                    </div>
                    <div class="feature-item">
                        <i data-lucide="book-open" class="feature-icon"></i>
                        <h3>Learning Resources</h3>
                        <p>Access reading lists, documentaries, academic papers, and educational materials.</p>
                    </div>
                    <div class="feature-item">
                        <i data-lucide="message-square" class="feature-icon"></i>
                        <h3>Visitor Guestbook</h3>
                        <p>Share your reflections and words of remembrance in our digital guestbook.</p>
                    </div>
                    <div class="feature-item">
                        <i data-lucide="lock" class="feature-icon"></i>
                        <h3>Member Access</h3>
                        <p>Registered members enjoy enhanced features including progress tracking and discussion forums.</p>
                    </div>
                    <div class="feature-item">
                        <i data-lucide="shield-check" class="feature-icon"></i>
                        <h3>Admin Management</h3>
                        <p>Administrators manage content, moderate feedback, and maintain the museum database.</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Technology Section -->
        <section class="section">
            <div class="content-block">
                <h2>Technology Stack</h2>
                <p>
                    This web application is built using Microsoft .NET technologies as part of the 
                    CT050-3-2 Web Applications (WAPP) module at Asia Pacific University of Technology 
                    and Innovation (APU).
                </p>
                <div class="info-box">
                    <h3>Technical Details</h3>
                    <p>
                        <strong style="color: #f5f2ed;">Frontend:</strong> HTML5, CSS3 (External, Internal &amp; Inline), JavaScript (ES6)<br />
                        <strong style="color: #f5f2ed;">Backend:</strong> ASP.NET Web Forms (C#)<br />
                        <strong style="color: #f5f2ed;">Database:</strong> Microsoft SQL Server with ADO.NET<br />
                        <strong style="color: #f5f2ed;">Architecture:</strong> Master Pages, Content Pages, Code-Behind model<br />
                        <strong style="color: #f5f2ed;">Validation:</strong> Client-side (JavaScript) &amp; Server-side (ASP.NET Validators)
                    </p>
                </div>
            </div>
        </section>

        <!-- Development Team -->
        <section class="section section-dark">
            <div class="container">
                <div class="section-header">
                    <span class="section-label">Development Team</span>
                    <h2 class="section-title">Group 5</h2>
                    <p class="section-subtitle">
                        CT050-3-2-WAPP | Asia Pacific University of Technology and Innovation
                    </p>
                    <div class="section-divider"></div>
                </div>

                <div class="team-grid">
                    <div class="team-card">
                        <div class="team-avatar"><i data-lucide="user"></i></div>
                        <h4>Nicholas Beh</h4>
                        <p>Student ID: TP070075</p>
                        <p style="color: #c4a44a; font-size: 11px; margin-top: 4px;">GUEST MODULE</p>
                    </div>
                    <div class="team-card">
                        <div class="team-avatar"><i data-lucide="user"></i></div>
                        <h4>Jenson Teh Jun Yan</h4>
                        <p>Student ID: TP080401</p>
                        <p style="color: #c4a44a; font-size: 11px; margin-top: 4px;">MEMBER MODULE</p>
                    </div>
                    <div class="team-card">
                        <div class="team-avatar"><i data-lucide="user"></i></div>
                        <h4>Zamson Lim Zhen Pin</h4>
                        <p>Student ID: TP073330</p>
                        <p style="color: #c4a44a; font-size: 11px; margin-top: 4px;">ADMIN MODULE</p>
                    </div>
                    <div class="team-card">
                        <div class="team-avatar"><i data-lucide="user"></i></div>
                        <h4>Chong Yong Xuan</h4>
                        <p>Student ID: TP080342</p>
                        <p style="color: #c4a44a; font-size: 11px; margin-top: 4px;">INSTRUCTOR MODULE</p>
                    </div>
                </div>
            </div>
        </section>

        <!-- Disclaimer -->
        <section class="section">
            <div class="content-block">
                <h2>Disclaimer &amp; Acknowledgements</h2>
                <p>
                    This website is a university project created for educational purposes as part of the 
                    CT050-3-2-WAPP module. All historical content has been compiled from publicly available 
                    academic sources and is presented with the utmost respect for the victims and survivors 
                    of the Nanjing Massacre.
                </p>
                <p>
                    We acknowledge the ongoing academic discourse surrounding the events and have endeavoured 
                    to present information based on well-documented historical records, including the findings 
                    of the International Military Tribunal for the Far East (1946&ndash;1948).
                </p>
            </div>
        </section>

    </div>

</asp:Content>
