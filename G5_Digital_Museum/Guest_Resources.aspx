<%@ Page Title="Resources" Language="C#" MasterPageFile="~/GuestSite.Master" AutoEventWireup="true" CodeBehind="Guest_Resources.aspx.cs" Inherits="G5_Digital_Museum.Guest_Resources" %>

<asp:Content ID="HeadContent" ContentPlaceHolderID="HeadContent" runat="server">
    <style type="text/css">
        /* Internal CSS: Resource type badges */
        .resource-badge {
            display: inline-block;
            padding: 3px 10px;
            font-size: 16px;
            letter-spacing: 1.5px;
            text-transform: uppercase;
            border-radius: 2px;
            font-weight: 600;
        }
        .badge-book { background: rgba(196, 164, 74, 0.15); color: #c4a44a; }
        .badge-film { background: rgba(139, 26, 26, 0.2); color: #cd5c5c; }
        .badge-article { background: rgba(100, 149, 237, 0.15); color: #6495ed; }
        .badge-quiz { background: rgba(46, 139, 87, 0.15); color: #2e8b57; }
    </style>
</asp:Content>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <div class="content-page">

        <!-- Page Hero -->
        <div class="page-hero">
            <div class="container">
                <span class="section-label">Education</span>
                <h1>Learning Resources</h1>
                <p>Curated educational materials for students, educators, and researchers studying the Nanjing Massacre. Source: The Memorial Hall of the Victims in Nanjing Massacre by Japanese Invaders (19371213.com.cn).</p>
            </div>
        </div>

        <!-- ==================== SECTION 1: Research Publications ==================== -->
        <section class="section">
            <div class="container">
                <div class="section-header">
                    <span class="section-label">Research &amp; Journal</span>
                    <h2 class="section-title">Books &amp; Publications</h2>
                    <p class="section-subtitle">Click each publication to flip and read the synopsis. Titles link to the original source on the Memorial Hall website.</p>
                    <div class="section-divider"></div>
                </div>

                <div class="books-grid">

                    <!-- Publication 1: Research Journal -->
                    <div class="book-flip-card">
                        <div class="book-flip-card-inner">
                            <div class="book-flip-front">
                                <span class="flip-hint-book">View</span>
                                <div class="book-cover" style="background: linear-gradient(135deg, #1a1a2e 0%, #16213e 50%, #0f3460 100%); display: flex; align-items: center; justify-content: center; padding: 16px; text-align: center;">
                                    <div>
                                        <p style="color: #c4a44a; font-size: 12px; letter-spacing: 2px; margin-bottom: 8px;">RESEARCH JOURNAL</p>
                                        <p style="color: #e8e0d0; font-size: 15px; font-family: 'Playfair Display', serif; line-height: 1.4;">Journal of Japanese Invasion of China and Nanjing Massacre</p>
                                    </div>
                                </div>
                                <div class="book-meta">
                                    <h4>Journal of Japanese Invasion of China and Nanjing Massacre</h4>
                                    <p class="book-author">Memorial Hall Research Institute</p>
                                    <p class="book-date">Ongoing Publication</p>
                                </div>
                            </div>
                            <div class="book-flip-back">
                                <h4>Journal of Japanese Invasion of China and Nanjing Massacre</h4>
                                <p>A professional academic journal focused on historical research, documentation, and scholarly analysis of the Japanese invasion of China and the Nanjing Massacre. The journal accepts submissions and publishes peer-reviewed articles.</p>
                                <a href="https://www.19371213.com.cn/en/research/rbqhnjdtsyj/202512/t20251226_5752230.html" target="_blank" class="book-link" onclick="event.stopPropagation();">Read More &rarr;</a>
                                <span class="flip-hint-book">&larr; Back</span>
                            </div>
                        </div>
                    </div>

                    <!-- Publication 2: Research Journal - Call for Papers -->
                    <div class="book-flip-card">
                        <div class="book-flip-card-inner">
                            <div class="book-flip-front">
                                <span class="flip-hint-book">View</span>
                                <div class="book-cover" style="background: linear-gradient(135deg, #2d132c 0%, #3e1f47 50%, #4a2357 100%); display: flex; align-items: center; justify-content: center; padding: 16px; text-align: center;">
                                    <div>
                                        <p style="color: #c4a44a; font-size: 12px; letter-spacing: 2px; margin-bottom: 8px;">CALL FOR PAPERS</p>
                                        <p style="color: #e8e0d0; font-size: 15px; font-family: 'Playfair Display', serif; line-height: 1.4;">Journal of Japanese Invasion of China and Nanjing Massacre</p>
                                    </div>
                                </div>
                                <div class="book-meta">
                                    <h4>Call for Papers</h4>
                                    <p class="book-author">Memorial Hall Research Institute</p>
                                    <p class="book-date">Open Submission</p>
                                </div>
                            </div>
                            <div class="book-flip-back">
                                <h4>Call for Papers: Journal of Japanese Invasion of China and Nanjing Massacre</h4>
                                <p>The journal invites scholars worldwide to submit original research papers on topics related to the Japanese invasion of China, the Nanjing Massacre, wartime atrocities, historical memory, and peace studies.</p>
                                <a href="https://www.19371213.com.cn/en/research/rbqhnjdtsyj/202512/t20251226_5752232.html" target="_blank" class="book-link" onclick="event.stopPropagation();">Read More &rarr;</a>
                                <span class="flip-hint-book">&larr; Back</span>
                            </div>
                        </div>
                    </div>

                    <!-- Publication 3: Research Publications - New Books Released -->
                    <div class="book-flip-card">
                        <div class="book-flip-card-inner">
                            <div class="book-flip-front">
                                <span class="flip-hint-book">View</span>
                                <div class="book-cover" style="background: linear-gradient(135deg, #1a1a1a 0%, #2a2a2a 50%, #3a3a2a 100%); display: flex; align-items: center; justify-content: center; padding: 16px; text-align: center;">
                                    <div>
                                        <p style="color: #c4a44a; font-size: 12px; letter-spacing: 2px; margin-bottom: 8px;">NEW PUBLICATION</p>
                                        <p style="color: #e8e0d0; font-size: 15px; font-family: 'Playfair Display', serif; line-height: 1.4;">New Books on the Nanjing Massacre</p>
                                        <p style="color: #999; font-size: 11px; margin-top: 6px;">December 2025</p>
                                    </div>
                                </div>
                                <div class="book-meta">
                                    <h4>New Books on the Nanjing Massacre</h4>
                                    <p class="book-author">Various Scholars</p>
                                    <p class="book-date">Released: Dec 2025</p>
                                </div>
                            </div>
                            <div class="book-flip-back">
                                <h4>Strengthening the Translation of Historical Materials, Preserving Global Memory</h4>
                                <p>Marking the 80th anniversary of the victory of the Chinese People&rsquo;s War of Resistance, new books on the Nanjing Massacre have been released to strengthen historical translation and preserve global memory of these events.</p>
                                <a href="https://www.19371213.com.cn/en/research/publications/202601/t20260105_5757370.html" target="_blank" class="book-link" onclick="event.stopPropagation();">Read More &rarr;</a>
                                <span class="flip-hint-book">&larr; Back</span>
                            </div>
                        </div>
                    </div>

                    <!-- Publication 4: Research Publications - Searching for the Truth -->
                    <div class="book-flip-card">
                        <div class="book-flip-card-inner">
                            <div class="book-flip-front">
                                <span class="flip-hint-book">View</span>
                                <div class="book-cover" style="background: linear-gradient(135deg, #1a0a0a 0%, #3a1a1a 50%, #4a2020 100%); display: flex; align-items: center; justify-content: center; padding: 16px; text-align: center;">
                                    <div>
                                        <p style="color: #cd5c5c; font-size: 12px; letter-spacing: 2px; margin-bottom: 8px;">RESEARCH MONOGRAPH</p>
                                        <p style="color: #e8e0d0; font-size: 15px; font-family: 'Playfair Display', serif; line-height: 1.4;">Searching for the Truth</p>
                                        <p style="color: #999; font-size: 11px; margin-top: 6px;">July 2025</p>
                                    </div>
                                </div>
                                <div class="book-meta">
                                    <h4>Searching for the Truth</h4>
                                    <p class="book-author">Memorial Hall &amp; Liji Lane Museum</p>
                                    <p class="book-date">Released: Jul 2025</p>
                                </div>
                            </div>
                            <div class="book-flip-back">
                                <h4>Searching for the Truth: A Research Monograph on &ldquo;Sex Slaves&rdquo;</h4>
                                <p>Launched at the Memorial Hall&rsquo;s branch&mdash;Nanjing Museum of the Site of Liji Lane Sex Slaves Station, this monograph presents findings from years of research into the Japanese military&rsquo;s systematic use of &ldquo;comfort women.&rdquo;</p>
                                <a href="https://www.19371213.com.cn/en/research/publications/202601/t20260127_5779648.html" target="_blank" class="book-link" onclick="event.stopPropagation();">Read More &rarr;</a>
                                <span class="flip-hint-book">&larr; Back</span>
                            </div>
                        </div>
                    </div>

                    <!-- Publication 5: Research Publications - Never Forget Historical -->
                    <div class="book-flip-card">
                        <div class="book-flip-card-inner">
                            <div class="book-flip-front">
                                <span class="flip-hint-book">View</span>
                                <div class="book-cover" style="background: linear-gradient(135deg, #1a0a0a 0%, #3a1a1a 50%, #4a2020 100%); display: flex; align-items: center; justify-content: center; padding: 16px; text-align: center;">
                                    <div>
                                        <p style="color: #cd5c5c; font-size: 12px; letter-spacing: 2px; margin-bottom: 8px;">Historical Contributions</p>
                                        <p style="color: #e8e0d0; font-size: 15px; font-family: 'Playfair Display', serif; line-height: 1.4;">Never Forget Historical</p>
                                        <p style="color: #999; font-size: 11px; margin-top: 6px;">Nov 2023</p>
                                    </div>
                                </div>
                                <div class="book-meta">
                                    <h4>Never Forget Historical of Tokyo Trial</h4>
                                    <p class="book-author">Memorial Hall &amp; Liji Lane Museum</p>
                                    <p class="book-date">Released: Nov 2023</p>
                                </div>
                            </div>
                            <div class="book-flip-back">
                                <h4>Never Forget Historical Contributions of Tokyo Trial</h4>
                                <p>This publication presents research findings based on extensive historical archives, testimonies, and documents related to the Nanjing Massacre, providing scholarly evidence and analysis of the atrocities committed in Nanjing between December 1937 and January 1938.</p>
                                <a href="https://www.19371213.com.cn/en/research/publications/202401/t20240111_4143379.html" target="_blank" class="book-link" onclick="event.stopPropagation();">Read More &rarr;</a>
                                <span class="flip-hint-book">&larr; Back</span>
                            </div>
                        </div>
                    </div>

                </div>
            </div>
        </section>

        <!-- ==================== SECTION 2: Featured Collection ==================== -->
        <section class="section section-dark">
            <div class="container">
                <div class="section-header">
                    <span class="section-label">Featured Collection</span>
                    <h2 class="section-title">Blood List &mdash; A Record of Charity Burying Corpses</h2>
                    <p class="section-subtitle">From the Memorial Hall&rsquo;s Featured Collections. Source: 19371213.com.cn</p>
                    <div class="section-divider"></div>
                </div>

                <div class="card-grid" style="max-width: 900px; margin: 0 auto;">

                    <div class="film-card">
                        <div class="film-body" style="padding: 32px;">
                            <span class="resource-badge badge-film">Featured Collection</span>
                            <h3>Blood List &mdash; A Record of Charity Burying Corpses</h3>
                            <p>
                                This list recorded details of articles (such as lime, cattail bags, and clothing) the 
                                Red Cross Society of China Nanjing Branch needed to bury refugees in the winter of 1937. 
                                They were the document by which charity staff carried out the burial, and were also evidence 
                                of the atrocities of the Japanese invaders in Nanjing.
                            </p>
                            <p style="margin-top: 12px; color: #999; font-size: 14px;">
                                Watch Episode 2, Season 2 of the &ldquo;Cultural Relics&rdquo; videos as part of the 
                                Memorial Hall&rsquo;s Featured Collections to learn about the story behind the &ldquo;Blood List&rdquo;.
                            </p>
                            <a href="https://www.19371213.com.cn/en/collection/featured/202407/t20240710_4711124.html" 
                               target="_blank" 
                               style="display: inline-block; margin-top: 16px; padding: 10px 24px; background: #c4a44a; color: #1a1a1a; text-decoration: none; font-size: 13px; letter-spacing: 1.5px; text-transform: uppercase; font-weight: 600;">
                                View on Memorial Hall Website &rarr;
                            </a>
                        </div>
                    </div>

                </div>
            </div>
        </section>

        <!-- ==================== SECTION 3: Official Memorial Resources ==================== -->
        <section class="section">
            <div class="container">
                <div class="section-header">
                    <span class="section-label">Official Sources</span>
                    <h2 class="section-title">Memorial Hall Online Resources</h2>
                    <p class="section-subtitle">Explore the official website of The Memorial Hall of the Victims in Nanjing Massacre by Japanese Invaders.</p>
                    <div class="section-divider"></div>
                </div>

                <div class="card-grid" style="max-width: 900px; margin: 0 auto;">

                    <div class="card">
                        <div class="card-body">
                            <span class="resource-badge badge-article">Exhibition</span>
                            <h3 class="card-title">The Nanjing Massacre Exhibition</h3>
                            <p class="card-text">The main permanent exhibition documenting the full history and evidence of the Nanjing Massacre.</p>
                        </div>
                        <div class="card-footer">
                            <a href="https://www.19371213.com.cn/en/exhibition/njdtsssz/" target="_blank" style="color: #c4a44a;">Visit &rarr;</a>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-body">
                            <span class="resource-badge badge-article">Research</span>
                            <h3 class="card-title">Research &amp; Publications</h3>
                            <p class="card-text">Academic research, publications, and the Journal of Japanese Invasion of China and Nanjing Massacre.</p>
                        </div>
                        <div class="card-footer">
                            <a href="https://www.19371213.com.cn/en/research/publications/" target="_blank" style="color: #c4a44a;">Visit &rarr;</a>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-body">
                            <span class="resource-badge badge-article">Archives</span>
                            <h3 class="card-title">Historical Archives</h3>
                            <p class="card-text">Primary historical documents, diaries, photographs, and evidence from the Nanjing Massacre archives.</p>
                        </div>
                        <div class="card-footer">
                            <a href="https://www.19371213.com.cn/en/research/yjda/" target="_blank" style="color: #c4a44a;">Visit &rarr;</a>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-body">
                            <span class="resource-badge badge-quiz">Education</span>
                            <h3 class="card-title">International Peace School</h3>
                            <p class="card-text">Educational programmes promoting peace and historical awareness for students worldwide.</p>
                        </div>
                        <div class="card-footer">
                            <a href="https://www.19371213.com.cn/en/learn/programme/" target="_blank" style="color: #c4a44a;">Visit &rarr;</a>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-body">
                            <span class="resource-badge badge-book">Collections</span>
                            <h3 class="card-title">Featured Collections</h3>
                            <p class="card-text">Key artifacts and cultural relics preserved by the Memorial Hall, including the Nanjing Photo Album and Blood List records.</p>
                        </div>
                        <div class="card-footer">
                            <a href="https://www.19371213.com.cn/en/collection/featured/" target="_blank" style="color: #c4a44a;">Visit &rarr;</a>
                        </div>
                    </div>

                    <div class="card">
                        <div class="card-body">
                            <span class="resource-badge badge-article">Journal</span>
                            <h3 class="card-title">Nanjing International Peace Newsletter</h3>
                            <p class="card-text">Ongoing international scholarly newsletter covering peace research and historical memory.</p>
                        </div>
                        <div class="card-footer">
                            <a href="https://www.19371213.com.cn/en/research/journal/" target="_blank" style="color: #c4a44a;">Visit &rarr;</a>
                        </div>
                    </div>

                </div>
            </div>
        </section>

        <!-- Database-Driven Resources -->
        <section class="section">
            <div class="container">
                <div class="section-header">
                    <span class="section-label">Database Collection</span>
                    <h2 class="section-title">Additional Resources</h2>
                    <p class="section-subtitle">
                        Additional resources from our database collection.
                    </p>
                    <div class="section-divider"></div>
                </div>

                <asp:GridView ID="gvResources" runat="server" AutoGenerateColumns="false"
                    CssClass="gridview-style" GridLines="None"
                    EmptyDataText="No additional resources found."
                    style="width: 100%; max-width: 900px; margin: 0 auto;">
                    <Columns>
                        <asp:BoundField DataField="ResourceTitle" HeaderText="Title" />
                        <asp:BoundField DataField="ResourceType" HeaderText="Type" />
                        <asp:BoundField DataField="Author" HeaderText="Author" />
                        <asp:BoundField DataField="YearPublished" HeaderText="Year" />
                        <asp:HyperLinkField DataTextField="ResourceTitle" DataNavigateUrlFields="ResourceURL"
                            DataNavigateUrlFormatString="{0}" HeaderText="Link" Text="View" Target="_blank" />
                    </Columns>
                </asp:GridView>

                <asp:Label ID="lblResourcesMsg" runat="server" Visible="false"
                    style="display: block; text-align: center; color: #555; padding: 32px; font-size: 24px;">
                </asp:Label>

            </div>
        </section>

    </div>

</asp:Content>
