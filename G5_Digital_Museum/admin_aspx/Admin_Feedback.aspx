<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin_Feedback.aspx.cs" Inherits="G5_Digital_Museum.Admin_ASPX.Admin_Feedback" MasterPageFile="~/Admin_ASPX/Admin_Master.Master" %>

<asp:Content ContentPlaceHolderID="PageTitle" runat="server">
    <h2 class="mb-0">FEEDBACK</h2>
</asp:Content>

<asp:Content ContentPlaceHolderID="MainContent" runat="server">

    <asp:Label ID="lblMessage" runat="server" Visible="false" CssClass="alert d-block mb-3"></asp:Label>

    <div class="card p-3 mb-3">
        <div class="row g-2 align-items-end">
            <div class="col-md-3">
                <label class="form-label">Filter by Status</label>
                <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-select">
                    <asp:ListItem Text="All Status" Value=""></asp:ListItem>
                    <asp:ListItem Text="Pending"    Value="Pending"></asp:ListItem>
                    <asp:ListItem Text="Reviewed"   Value="Reviewed"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-md-3">
                <label class="form-label">Sort By</label>
                <asp:DropDownList ID="ddlSortBy" runat="server" CssClass="form-select">
                    <asp:ListItem Text="Newest First"   Value="newest"></asp:ListItem>
                    <asp:ListItem Text="Highest Rating" Value="rating"></asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="col-md-2">
                <asp:Button ID="btnFilter" runat="server" Text="Apply" CssClass="btn btn-primary w-100" OnClick="btnFilter_Click" />
            </div>
            <div class="col-md-2">
                <asp:Button ID="btnClear" runat="server" Text="Clear" CssClass="btn btn-secondary w-100" OnClick="btnClear_Click" />
            </div>
            <div class="col-md-2 text-end">
                <asp:Label ID="lblCount" runat="server" CssClass="text-muted small"></asp:Label>
            </div>
        </div>
    </div>

    <asp:Label ID="lblNoFeedback" runat="server" Visible="false">
        <div class="card p-4 text-center" style="color:#555;">No feedback found.</div>
    </asp:Label>

    <asp:Repeater ID="rptFeedback" runat="server" OnItemCommand="rptFeedback_ItemCommand">
        <ItemTemplate>
            <div class="feedback-card mb-3">
                <div class="feedback-header">
                    <div class="feedback-meta">
                        <span class="feedback-name"><%# Eval("GuestName") %></span>
                        <span class="feedback-email"><%# Eval("GuestEmail") %></span>
                    </div>
                    <div class="d-flex align-items-center gap-3 flex-wrap">
                        <div class="feedback-stars"><%# BuildStars(Eval("Rating")) %></div>
                        <span class='feedback-status <%# Eval("Status").ToString() == "Pending" ? "status-pending" : "status-reviewed" %>'>
                            <%# Eval("Status") %>
                        </span>
                        <span class="feedback-date"><%# Convert.ToDateTime(Eval("SubmittedAt")).ToString("dd MMM yyyy") %></span>
                    </div>
                </div>
                <div class="feedback-subject"><%# Eval("Subject") %></div>
                <div class="feedback-message"><%# Eval("Message") %></div>
                <div class="feedback-actions">
                    <asp:Button runat="server" Text="✔ Mark Reviewed"
                        CommandName="Approve"
                        CommandArgument='<%# Eval("FeedbackID") %>'
                        CssClass="btn btn-sm btn-primary"
                        Visible='<%# Eval("Status").ToString() == "Pending" %>' />
                    <asp:Button runat="server" Text="Delete"
                        CommandName="Delete"
                        CommandArgument='<%# Eval("FeedbackID") %>'
                        CssClass="btn btn-sm btn-danger"
                        OnClientClick="return confirm('Delete this feedback?');" />
                </div>
            </div>
        </ItemTemplate>
    </asp:Repeater>

    <style>
        .feedback-card    { background:#1a1a1a; border:1px solid rgba(196,164,74,0.15); border-radius:4px; padding:20px; transition:border-color 0.2s; }
        .feedback-card:hover { border-color:rgba(196,164,74,0.4); }
        .feedback-header  { display:flex; justify-content:space-between; align-items:center; margin-bottom:10px; flex-wrap:wrap; gap:8px; }
        .feedback-meta    { display:flex; flex-direction:column; }
        .feedback-name    { font-size:15px; font-weight:600; color:#e8e0d0; }
        .feedback-email   { font-size:12px; color:#555; }
        .feedback-date    { font-size:12px; color:#555; }
        .feedback-stars   { font-size:14px; letter-spacing:2px; }
        .feedback-status  { font-size:11px; font-weight:700; letter-spacing:1px; text-transform:uppercase; padding:3px 10px; border-radius:2px; }
        .status-pending   { background:rgba(196,164,74,0.15); color:#c4a44a; }
        .status-reviewed  { background:rgba(46,204,113,0.12); color:#2ecc71; }
        .feedback-subject { font-size:14px; font-weight:600; color:#c4a44a; margin-bottom:8px; }
        .feedback-message { font-size:14px; color:#999; line-height:1.7; margin-bottom:16px; }
        .feedback-actions { display:flex; gap:8px; }
    </style>

    <script runat="server">
        protected string BuildStars(object rating)
        {
            if (rating == null || rating == DBNull.Value) return "—";
            int r = Convert.ToInt32(rating);
            string stars = "";
            for (int i = 1; i <= 5; i++)
                stars += i <= r ? "<span style='color:#c4a44a;'>★</span>" : "<span style='color:#333;'>★</span>";
            return stars;
        }
    </script>

</asp:Content>
