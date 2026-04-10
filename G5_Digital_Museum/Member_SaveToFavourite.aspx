<%@ Page Title="Favourite" Language="C#" MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true" CodeBehind="Member_SaveToFavourite.aspx.cs" Inherits="G5_Digital_Museum.Member_SaveToFavourite" %>

<asp:Content ID="Head1" ContentPlaceHolderID="HeadContent" runat="server"></asp:Content>

<asp:Content ID="Main1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="content-page">
        <section class="page-hero">
            <div class="container">
                <h1>Favourite</h1>
                <p>Your saved exhibitions will appear here.</p>
            </div>
        </section>

        <div class="content-block">
            <asp:Label ID="lblMsg" runat="server" />

            <asp:GridView ID="gvFav" runat="server" CssClass="gridview-style"
                AutoGenerateColumns="False" OnRowCommand="gvFav_RowCommand">
                <Columns>
                    <asp:BoundField DataField="Title" HeaderText="Title" />
                    <asp:BoundField DataField="Location" HeaderText="Location" />
                    <asp:BoundField DataField="SavedAt" HeaderText="Saved At" DataFormatString="{0:yyyy-MM-dd HH:mm}" />

                    <asp:TemplateField HeaderText="Action">
                        <ItemTemplate>
                            <a class="btn btn-outline btn-sm"
                               href='Member_ExhibitionDetails.aspx?id=<%# Eval("ExhibitionID") %>'>Read</a>

                            <asp:Button ID="btnRemove" runat="server" Text="Remove"
                                CssClass="btn btn-outline btn-sm"
                                CommandName="RemoveFav"
                                CommandArgument='<%# Eval("ExhibitionID") %>' />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>