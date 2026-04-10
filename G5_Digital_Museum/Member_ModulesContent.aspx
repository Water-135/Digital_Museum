<%@ Page Title="Module Content" Language="C#" MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Member_ModulesContent.aspx.cs"
    Inherits="G5_Digital_Museum.Member_ModulesContent" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">

<section class="module-shell">

    <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="module-empty">
        Module not found.
    </asp:Panel>

    <asp:Panel ID="pnlModule" runat="server" Visible="false">

        <div class="module-header">
            <h1>
                <asp:Label ID="lblTitle" runat="server" />
            </h1>

            <p class="module-desc">
                <asp:Label ID="lblDescription" runat="server" />
            </p>
        </div>

        <div class="module-content-list">

            <asp:Repeater ID="rptContents" runat="server">

                <ItemTemplate>

                    <div class="module-content-item">

                        <asp:Panel runat="server" Visible='<%# Eval("ContentType").ToString() == "text" %>'>

                            <div class="module-text">
                                <%# Eval("Body") %>
                            </div>

                        </asp:Panel>

                        <asp:Panel runat="server" Visible='<%# Eval("ContentType").ToString() == "image" %>'>

                            <div class="module-image-wrap">

                                <img src='<%# Eval("ImageUrl") %>' class="module-image" />

                                <div class="module-caption">
                                    <%# Eval("Caption") %>
                                </div>

                            </div>

                        </asp:Panel>

                    </div>

                </ItemTemplate>

            </asp:Repeater>

        </div>

        <div class="module-actions">
            <a href="Member_Modules.aspx" class="module-btn">
                BACK TO MODULES
            </a>
        </div>

    </asp:Panel>

</section>

</asp:Content>