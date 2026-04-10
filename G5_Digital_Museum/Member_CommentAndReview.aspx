<%@ Page Title="Comment & Review" Language="C#"
    MasterPageFile="~/Member_MasterPage.Master"
    AutoEventWireup="true"
    CodeBehind="Member_CommentAndReview.aspx.cs"
    Inherits="G5_Digital_Museum.Member_CommentAndReview" %>

<asp:Content ID="Head1" ContentPlaceHolderID="HeadContent" runat="server">
    <style>
        .comment-msg {
            display: inline-block;
            margin: 0 0 18px;
            padding: 10px 14px;
            border-radius: 8px;
        }

        .comment-input {
            width: 100%;
            min-height: 120px;
            resize: vertical;
        }

        .table-action-btn {
            display: inline-block;
            padding: 7px 14px;
            margin: 2px 6px 2px 0;
            border-radius: 8px;
            text-decoration: none;
            font-size: 0.92rem;
            font-weight: 600;
            transition: all 0.2s ease;
            border: 1px solid var(--dm-accent);
            color: var(--dm-accent);
            background: rgba(182, 141, 64, 0.10);
        }

        .table-action-btn:hover {
            background: var(--dm-accent);
            color: #111;
            text-decoration: none;
        }

        .edit-btn,
        .update-btn {
            border-color: var(--dm-accent);
            color: var(--dm-accent);
            background: rgba(182, 141, 64, 0.10);
        }

        .delete-btn,
        .cancel-btn {
            border-color: #c85a5a;
            color: #c85a5a;
            background: rgba(200, 90, 90, 0.10);
        }

        .delete-btn:hover,
        .cancel-btn:hover {
            background: #c85a5a;
            color: #fff;
            text-decoration: none;
        }

        .edit-comment-box {
            width: 100%;
            min-height: 80px;
            padding: 8px 10px;
            border-radius: 6px;
            border: 1px solid #666;
            resize: vertical;
            box-sizing: border-box;
        }

        .edit-rating-box {
            width: 70px;
            padding: 4px 6px;
            border-radius: 6px;
            border: 1px solid #666;
        }
    </style>
</asp:Content>

<asp:Content ID="Main1" ContentPlaceHolderID="MainContent" runat="server">

    <div class="content-page">

        <section class="page-hero">
            <div class="container">
                <h1>Comment &amp; Review</h1>
                <p>Please keep comments respectful and educational.</p>
            </div>
        </section>

        <div class="content-block">

            <asp:Label ID="lblMsg" runat="server" CssClass="comment-msg"></asp:Label>

            <div class="form-group">
                <label>Exhibition</label>
                <asp:DropDownList ID="ddlExhibition" runat="server"></asp:DropDownList>
            </div>

            <div class="form-group">
                <label>Rating</label>
                <asp:DropDownList ID="ddlRating" runat="server">
                    <asp:ListItem Text="5 - Excellent" Value="5" />
                    <asp:ListItem Text="4 - Good" Value="4" />
                    <asp:ListItem Text="3 - Average" Value="3" />
                    <asp:ListItem Text="2 - Poor" Value="2" />
                    <asp:ListItem Text="1 - Very Poor" Value="1" />
                </asp:DropDownList>
            </div>

            <div class="form-group">
                <label>Comment</label>
                <asp:TextBox ID="txtComment" runat="server" TextMode="MultiLine" CssClass="comment-input"></asp:TextBox>
            </div>

            <asp:Button ID="btnSubmit" runat="server" Text="Submit"
                CssClass="btn btn-primary btn-sm" OnClick="btnSubmit_Click" />

            <div style="margin-top:40px;">
                <h2 style="margin-bottom:14px; color: var(--dm-accent);">Recent Comments</h2>

                <asp:GridView ID="gvComments" runat="server"
                    CssClass="gridview-style"
                    AutoGenerateColumns="False"
                    DataKeyNames="CommentID,UserID"
                    OnRowEditing="gvComments_RowEditing"
                    OnRowCancelingEdit="gvComments_RowCancelingEdit"
                    OnRowUpdating="gvComments_RowUpdating"
                    OnRowDeleting="gvComments_RowDeleting"
                    OnRowDataBound="gvComments_RowDataBound">

                    <Columns>
                        <asp:BoundField DataField="Exhibition" HeaderText="Exhibition" ReadOnly="True" />
                        <asp:BoundField DataField="UserName" HeaderText="Member" ReadOnly="True" />

                        <asp:BoundField DataField="Rating" HeaderText="Rating" />

                        <asp:TemplateField HeaderText="Comment">
                            <ItemTemplate>
                                <%# Eval("CommentText") %>
                            </ItemTemplate>
                            <EditItemTemplate>
                                <asp:TextBox ID="txtEditComment" runat="server"
                                    Text='<%# Bind("CommentText") %>'
                                    TextMode="MultiLine"
                                    Rows="4"
                                    CssClass="edit-comment-box"></asp:TextBox>
                            </EditItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="CreatedAt" HeaderText="Date"
                            DataFormatString="{0:yyyy-MM-dd HH:mm}" ReadOnly="True" />

                        <asp:TemplateField HeaderText="Action">
                            <ItemTemplate>
                                <asp:LinkButton ID="btnEdit" runat="server"
                                    CommandName="Edit"
                                    CssClass="table-action-btn edit-btn"
                                    Text="Edit" />

                                <asp:LinkButton ID="btnDelete" runat="server"
                                    CommandName="Delete"
                                    CssClass="table-action-btn delete-btn"
                                    Text="Delete"
                                    OnClientClick="return confirm('Are you sure you want to delete this comment?');" />
                            </ItemTemplate>

                            <EditItemTemplate>
                                <asp:LinkButton ID="btnUpdate" runat="server"
                                    CommandName="Update"
                                    CssClass="table-action-btn update-btn"
                                    Text="Update" />

                                <asp:LinkButton ID="btnCancel" runat="server"
                                    CommandName="Cancel"
                                    CssClass="table-action-btn cancel-btn"
                                    Text="Cancel" />
                            </EditItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </div>

        </div>
    </div>

</asp:Content>