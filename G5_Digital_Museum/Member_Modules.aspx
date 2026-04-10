<%@ Page Title="Modules" Language="C#" MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Member_Modules.aspx.cs" Inherits="G5_Digital_Museum.Member_Modules" %>

<asp:Content ID="Head1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .member-list-page {
            padding-top: 72px;
            background: var(--dm-black);
            min-height: 100vh;
        }

        .member-list-hero {
            padding: 70px 0 40px;
            border-bottom: 1px solid var(--dm-border);
            background: var(--dm-black);
        }

        .member-list-hero .eyebrow {
            font-size: 11px;
            letter-spacing: 4px;
            text-transform: uppercase;
            color: var(--dm-accent);
            margin-bottom: 14px;
        }

        .member-list-hero h1 {
            font-size: clamp(2.2rem, 4vw, 3.4rem);
            margin-bottom: 12px;
        }

        .member-list-hero p {
            color: var(--dm-grey-light);
            font-size: 16px;
            max-width: 700px;
        }

        .module-list {
            display: grid;
            gap: 22px;
            margin-top: 36px;
        }

        .module-card {
            background: linear-gradient(180deg, rgba(30,30,30,0.95), rgba(20,20,20,0.98));
            border: 1px solid var(--dm-border);
            overflow: hidden;
        }

        .module-card-top {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            gap: 20px;
            padding: 22px 24px;
            border-bottom: 1px solid rgba(196,164,74,0.10);
        }

        .module-card-title {
            font-family: var(--font-display);
            font-size: 1.8rem;
            color: var(--dm-white);
            margin-bottom: 10px;
        }

        .module-card-desc {
            color: var(--dm-grey-light);
            font-size: 14px;
            line-height: 1.8;
        }

        .module-meta {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            justify-content: flex-end;
        }

        .meta-badge {
            border: 1px solid var(--dm-border);
            color: var(--dm-grey-light);
            padding: 6px 10px;
            font-size: 11px;
            letter-spacing: 1px;
            text-transform: uppercase;
            background: rgba(255,255,255,0.02);
        }

        .meta-badge.published {
            color: #61d08c;
            border-color: rgba(97,208,140,0.35);
        }

        .module-preview-list {
            padding: 0 24px;
        }

        .preview-item {
            padding: 16px 0;
            border-bottom: 1px solid rgba(255,255,255,0.05);
            color: var(--dm-grey-light);
            font-size: 14px;
        }

        .preview-item:last-child {
            border-bottom: none;
        }

        .module-actions {
            padding: 18px 24px 22px;
            display: flex;
            gap: 12px;
            flex-wrap: wrap;
        }

        .empty-msg {
            padding: 24px;
            border: 1px solid var(--dm-border);
            background: var(--dm-dark);
            color: var(--dm-grey-light);
        }
    </style>
</asp:Content>

<asp:Content ID="Main1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="member-list-page">
        <section class="member-list-hero">
            <div class="container">
                <div class="eyebrow">Learning Content</div>
                <h1>Modules</h1>
                <p>Study published learning modules and review key content prepared for museum members.</p>
            </div>
        </section>

        <section class="section">
            <div class="container">
                <asp:Repeater ID="rptModules" runat="server" OnItemCommand="rptModules_ItemCommand">
                    <HeaderTemplate>
                        <div class="module-list">
                    </HeaderTemplate>

                    <ItemTemplate>
                        <div class="module-card">
                            <div class="module-card-top">
                                <div>
                                    <div class="module-card-title"><%# Eval("Title") %></div>
                                    <div class="module-card-desc"><%# Eval("Description") %></div>
                                </div>

                                <div class="module-meta">
                                    <span class="meta-badge published">Published</span>
                                    <span class="meta-badge"># <%# Eval("SortOrder") %></span>
                                    <span class="meta-badge"><%# Eval("BlockCount") %> Blocks</span>
                                </div>
                            </div>

                            <asp:Repeater ID="rptPreviewContents" runat="server" DataSource='<%# Eval("PreviewContents") %>'>
                                <HeaderTemplate>
                                    <div class="module-preview-list">
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <div class="preview-item"><%# Container.DataItem %></div>
                                </ItemTemplate>
                                <FooterTemplate>
                                    </div>
                                </FooterTemplate>
                            </asp:Repeater>

                            <div class="module-actions">
                                <asp:LinkButton ID="btnOpen" runat="server"
                                    CssClass="btn btn-primary btn-sm"
                                    CommandName="open"
                                    CommandArgument='<%# Eval("ModuleID") %>'>
                                    Open Module
                                </asp:LinkButton>

                                <asp:LinkButton ID="btnQuiz" runat="server"
                                    CssClass="btn btn-outline btn-sm"
                                    CommandName="quiz"
                                    CommandArgument='<%# Eval("ModuleID") %>'
                                    Visible='<%# Convert.ToBoolean(Eval("HasQuiz")) %>'>
                                    Start Quiz
                                </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>

                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-msg">
                    No published modules are available yet.
                </asp:Panel>
            </div>
        </section>
    </div>
</asp:Content>