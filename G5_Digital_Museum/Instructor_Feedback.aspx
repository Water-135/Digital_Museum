<%@ Page Title="Instructor_Feedback" Language="C#" MasterPageFile="~/Master/Instructor_Master.Master" AutoEventWireup="true" CodeBehind="Instructor_Feedback.aspx.cs" Inherits="G5_Digital_Museum.Instructor_Feedback" %>

<asp:Content ID="MainF" ContentPlaceHolderID="MainContent" runat="server">

<style>
.chip--danger  { background:rgba(201,76,76,.15);  color:#c94c4c; border-color:rgba(201,76,76,.3); }
.chip--success { background:rgba(94,203,138,.12); color:#5ecb8a; border-color:rgba(94,203,138,.3); }

/* ── Modal ──────────────────────────────────────────────── */
.fb-modal {
    position:fixed; inset:0; background:rgba(0,0,0,.85);
    z-index:2000; display:flex; align-items:center; justify-content:center; padding:20px;
}
.fb-modal__box {
    background:#141414; border:1px solid rgba(196,164,74,.25);
    max-width:660px; width:100%; max-height:90vh;
    overflow-y:auto; border-radius:4px; display:flex; flex-direction:column;
}
.fb-modal__header {
    display:flex; justify-content:space-between; align-items:center;
    padding:20px 24px; border-bottom:1px solid rgba(255,255,255,.07);
    position:sticky; top:0; background:#141414; z-index:2;
}
.fb-modal__header h3 { font-family:'Playfair Display',serif; font-size:1.2rem; color:#f5f2ed; margin:0; }
.fb-modal__body   { padding:24px; flex:1; }
.fb-modal__footer {
    padding:16px 24px; border-top:1px solid rgba(255,255,255,.07);
    display:flex; justify-content:flex-end; gap:10px;
    position:sticky; bottom:0; background:#141414; z-index:2;
}
.fb-detail-name    { display:block; font-size:1.05rem; font-weight:700; color:#c4a44a; margin-bottom:4px; }
.fb-detail-meta    { display:block; font-size:11px; letter-spacing:.8px; color:#555; margin-bottom:3px; }
.fb-detail-divider { border:none; border-top:1px solid rgba(255,255,255,.07); margin:14px 0; }
.fb-detail-msg     { display:block; font-size:14px; color:#aaa; line-height:1.9; white-space:pre-wrap; }
.modal-tabs {
    display:flex; gap:0; margin-bottom:20px;
    border-bottom:2px solid rgba(255,255,255,.07);
}
.modal-tab {
    padding:10px 20px; font-size:11px; font-weight:800; letter-spacing:1.5px;
    text-transform:uppercase; cursor:pointer; border:none; background:transparent;
    color:#444; border-bottom:2px solid transparent; margin-bottom:-2px;
    transition:color .15s, border-color .15s;
}
.modal-tab:hover  { color:#c4a44a; }
.modal-tab.active { color:#c4a44a; border-bottom-color:#c4a44a; }
.modal-section {
    background:rgba(196,164,74,.04); border:1px solid rgba(196,164,74,.18); padding:18px;
}
.modal-section--reply { background:rgba(94,203,138,.03); border-color:rgba(94,203,138,.2); }
.section-label {
    font-size:9px; font-weight:800; letter-spacing:3px; text-transform:uppercase;
    color:#c4a44a; margin-bottom:12px; display:flex; align-items:center; gap:10px;
}
.section-label--reply { color:#5ecb8a; }
.section-label::before, .section-label::after        { content:''; flex:1; height:1px; background:rgba(196,164,74,.2); }
.section-label--reply::before, .section-label--reply::after { background:rgba(94,203,138,.2); }
.existing-box {
    font-size:13px; color:#b0a080; line-height:1.8; white-space:pre-wrap;
    padding:12px 14px; background:#0f0f0f;
    border-left:3px solid rgba(196,164,74,.4); margin-bottom:10px;
}
.existing-box--reply { color:#7ec4a0; border-left-color:rgba(94,203,138,.4); }
.existing-meta  { font-size:10px; color:#444; letter-spacing:.5px; margin-bottom:12px; }
.replied-badge {
    font-size:9px; font-weight:800; letter-spacing:1px; text-transform:uppercase;
    color:#5ecb8a; padding:2px 6px; border:1px solid rgba(94,203,138,.3);
    display:inline-block; white-space:nowrap;
}

/* ── Section divider ────────────────────────────────────── */
.section-page-divider {
    display:flex; align-items:center; gap:16px;
    margin:40px 0 28px;
    font-size:10px; font-weight:800; letter-spacing:4px;
    text-transform:uppercase; color:#c4a44a;
}
.section-page-divider::before,
.section-page-divider::after {
    content:''; flex:1; height:1px; background:rgba(196,164,74,.25);
}

/* ── Comment row user/exhibition info ───────────────────── */
.cmt-user    { font-size:13px; font-weight:700; color:#f5f2ed; }
.cmt-email   { font-size:11px; color:#555; margin-top:2px; }
.cmt-exh     { font-size:11px; color:#c4a44a; letter-spacing:.5px; }
</style>

<asp:HiddenField ID="hfViewID"   runat="server" Value="0" />
<asp:HiddenField ID="hfModalTab" runat="server" Value="note" />

<!-- ══ PAGE HEADER ══ -->
<div class="pagehead">
    <div class="pagehead-left">
        <div class="pagehead-kicker">Moderation</div>
        <h1>Feedback &amp; Comments</h1>
        <p>Review guest feedback submissions and member exhibition comments from one place.</p>
    </div>
</div>

<!-- ══ STAT CARDS ══ -->
<div style="display:grid;grid-template-columns:repeat(3,1fr);gap:14px;margin-bottom:24px;">
    <div class="panel" style="text-align:center;padding:20px;">
        <div style="font-size:2rem;font-weight:800;color:#c4a44a;">
            <asp:Label ID="lblCountPending" runat="server" Text="0" /></div>
        <div style="font-size:10px;letter-spacing:2px;text-transform:uppercase;color:#555;margin-top:4px;">Pending Feedback</div>
    </div>
    <div class="panel" style="text-align:center;padding:20px;">
        <div style="font-size:2rem;font-weight:800;color:#5ecb8a;">
            <asp:Label ID="lblCountReviewed" runat="server" Text="0" /></div>
        <div style="font-size:10px;letter-spacing:2px;text-transform:uppercase;color:#555;margin-top:4px;">Reviewed</div>
    </div>
    <div class="panel" style="text-align:center;padding:20px;">
        <div style="font-size:2rem;font-weight:800;color:#c94c4c;">
            <asp:Label ID="lblCountRejected" runat="server" Text="0" /></div>
        <div style="font-size:10px;letter-spacing:2px;text-transform:uppercase;color:#555;margin-top:4px;">Rejected</div>
    </div>
</div>

<!-- ══ FEEDBACK FILTER ══ -->
<section class="panel" style="margin-bottom:20px;">
    <div class="panel-header">
        <div><h2 class="panel-title">Filter Feedback</h2></div>
    </div>
    <div class="filter-grid">
        <div class="form-group">
            <label class="form-label">Status</label>
            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                <asp:ListItem Text="All Statuses" Value="" />
                <asp:ListItem Text="Pending"      Value="Pending" />
                <asp:ListItem Text="Reviewed"     Value="Reviewed" />
                <asp:ListItem Text="Rejected"     Value="Rejected" />
            </asp:DropDownList>
        </div>
        <div class="form-group">
            <label class="form-label">Rating</label>
            <asp:DropDownList ID="ddlRating" runat="server" CssClass="form-control">
                <asp:ListItem Text="Any Rating"    Value="" />
                <asp:ListItem Text="★★★★★ 5 stars" Value="5" />
                <asp:ListItem Text="★★★★  4 stars" Value="4" />
                <asp:ListItem Text="★★★   3 stars"  Value="3" />
                <asp:ListItem Text="★★    2 stars"  Value="2" />
                <asp:ListItem Text="★     1 star"   Value="1" />
            </asp:DropDownList>
        </div>
        <div class="form-group form-group--align-end">
            <asp:Button ID="btnApply" runat="server" Text="Apply Filter"
                CssClass="btn" OnClick="btnApply_Click" />
        </div>
    </div>
    <asp:Label ID="lblActionMsg" runat="server" CssClass="form-feedback"
        style="display:block;margin-top:8px;" />
</section>

<!-- ══ FEEDBACK TABLE ══ -->
<section class="panel">
    <div class="panel-header">
        <div>
            <h2 class="panel-title">Feedback Submissions</h2>
            <p class="panel-subtitle"><asp:Label ID="lblCount" runat="server" Text="Loading..." /></p>
        </div>
    </div>
    <div class="table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Visitor</th>
                    <th>Rating</th>
                    <th>Message Preview</th>
                    <th>Status</th>
                    <th>Reply</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptFeedback" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td style="white-space:nowrap;font-size:12px;" class="td-muted">
                                <%# Eval("SubmitDate") %>
                            </td>
                            <td>
                                <strong style="color:#f5f2ed;font-size:13px;"><%# Eval("VisitorName") %></strong>
                                <div style="font-size:11px;color:#555;"><%# Eval("GuestEmail") %></div>
                            </td>
                            <td>
                                <%# Eval("Rating") != DBNull.Value
                                    ? "<span style='color:#c4a44a;font-size:12px;letter-spacing:1px;'>" +
                                      new string('★', Convert.ToInt32(Eval("Rating"))) +
                                      "<span style='color:#222;'>" +
                                      new string('★', 5 - Convert.ToInt32(Eval("Rating"))) +
                                      "</span></span>"
                                    : "<span style='color:#333;'>—</span>" %>
                            </td>
                            <td style="max-width:240px;font-size:13px;color:#888;">
                                <%# Eval("Preview") %>
                            </td>
                            <td>
                                <span class='chip <%# Eval("Status").ToString()=="Reviewed"
                                    ? "chip--live"
                                    : Eval("Status").ToString()=="Rejected"
                                        ? "chip--danger" : "chip--draft" %>'>
                                    <%# Eval("Status") %>
                                </span>
                            </td>
                            <td style="text-align:center;">
                                <%# !string.IsNullOrEmpty(Eval("InstructorReply")?.ToString())
                                    ? "<span class='replied-badge'>&#10003; Replied</span>"
                                    : "<span style='color:#333;font-size:11px;'>—</span>" %>
                            </td>
                            <td class="td-actions">
                                <asp:Button runat="server" Text="&#128065; View"
                                    CssClass="btn btn-xs"
                                    CommandArgument='<%# Eval("FeedbackID") %>'
                                    OnClick="btnView_Click" />
                                <asp:Button runat="server" Text="&#10003;"
                                    CssClass="btn btn-xs btn-success"
                                    CommandArgument='<%# Eval("FeedbackID") %>'
                                    OnClick="btnReview_Click" />
                                <asp:Button runat="server" Text="&#10007;"
                                    CssClass="btn btn-xs btn-danger"
                                    CommandArgument='<%# Eval("FeedbackID") %>'
                                    OnClick="btnReject_Click"
                                    OnClientClick="return confirm('Reject this submission?');" />
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</section>


<!-- ══════════════════════════════════════════════════════════
     COMMENTS SECTION
══════════════════════════════════════════════════════════ -->
<div class="section-page-divider">&#128172;&nbsp; Exhibition Comments</div>

<!-- Comments filter -->
<section class="panel" style="margin-bottom:20px;">
    <div class="panel-header">
        <div><h2 class="panel-title">Filter Comments</h2></div>
    </div>
    <div class="filter-grid">
        <div class="form-group">
            <label class="form-label">Rating</label>
            <asp:DropDownList ID="ddlCommentRating" runat="server" CssClass="form-control">
                <asp:ListItem Text="Any Rating"    Value="" />
                <asp:ListItem Text="★★★★★ 5 stars" Value="5" />
                <asp:ListItem Text="★★★★  4 stars" Value="4" />
                <asp:ListItem Text="★★★   3 stars"  Value="3" />
                <asp:ListItem Text="★★    2 stars"  Value="2" />
                <asp:ListItem Text="★     1 star"   Value="1" />
            </asp:DropDownList>
        </div>
        <div class="form-group form-group--align-end">
            <asp:Button ID="btnApplyComment" runat="server" Text="Apply Filter"
                CssClass="btn" OnClick="btnApplyComment_Click" />
        </div>
    </div>
    <asp:Label ID="lblCommentActionMsg" runat="server" CssClass="form-feedback"
        style="display:block;margin-top:8px;" />
</section>

<!-- Comments table -->
<section class="panel">
    <div class="panel-header">
        <div>
            <h2 class="panel-title">Member Comments</h2>
            <p class="panel-subtitle"><asp:Label ID="lblCommentCount" runat="server" Text="Loading..." /></p>
        </div>
    </div>
    <div class="table-wrap">
        <table class="data-table">
            <thead>
                <tr>
                    <th>Date</th>
                    <th>Member</th>
                    <th>Exhibition</th>
                    <th>Rating</th>
                    <th>Comment Preview</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                <asp:Repeater ID="rptComments" runat="server">
                    <ItemTemplate>
                        <tr>
                            <td style="white-space:nowrap;font-size:12px;" class="td-muted">
                                <%# Eval("CreatedDate") %>
                            </td>
                            <td>
                                <div class="cmt-user"><%# Eval("UserName") %></div>
                                <div class="cmt-email"><%# Eval("UserEmail") %></div>
                            </td>
                            <td>
                                <span class="cmt-exh"><%# Eval("ExhibitionTitle") %></span>
                            </td>
                            <td>
                                <%# Eval("Rating") != DBNull.Value
                                    ? "<span style='color:#c4a44a;font-size:12px;letter-spacing:1px;'>" +
                                      new string('★', Convert.ToInt32(Eval("Rating"))) +
                                      "<span style='color:#222;'>" +
                                      new string('★', 5 - Convert.ToInt32(Eval("Rating"))) +
                                      "</span></span>"
                                    : "<span style='color:#333;'>—</span>" %>
                            </td>
                            <td style="max-width:300px;font-size:13px;color:#888;">
                                <%# Eval("Preview") %>
                            </td>
                            <td class="td-actions">
                                <asp:Button runat="server" Text="&#128465; Delete"
                                    CssClass="btn btn-xs btn-danger"
                                    CommandArgument='<%# Eval("CommentID") %>'
                                    OnClick="btnDeleteComment_Click"
                                    OnClientClick="return confirm('Delete this comment permanently?');" />
                            </td>
                        </tr>
                    </ItemTemplate>
                </asp:Repeater>
            </tbody>
        </table>
    </div>
</section>


<!-- ══════════════════════════════════════════════════════════
     MODAL — Feedback Detail + Note + Public Reply
══════════════════════════════════════════════════════════ -->
<div id="fbModal" class="fb-modal" style="display:none;" onclick="modalBgClose(event)">
    <div class="fb-modal__box" onclick="event.stopPropagation()">

        <div class="fb-modal__header">
            <h3>Submission Detail</h3>
            <button type="button" class="btn btn-xs" onclick="closeModal()">&#10005;</button>
        </div>

        <div class="fb-modal__body">
            <asp:Label ID="lblDetailName"   runat="server" CssClass="fb-detail-name" />
            <asp:Label ID="lblDetailMeta"   runat="server" CssClass="fb-detail-meta" />
            <asp:Label ID="lblDetailDate"   runat="server" CssClass="fb-detail-meta" />
            <asp:Label ID="lblDetailRating" runat="server" CssClass="fb-detail-meta"
                style="color:#c4a44a;font-size:15px;letter-spacing:2px;" />

            <hr class="fb-detail-divider" />

            <div style="font-size:9px;font-weight:800;letter-spacing:2px;text-transform:uppercase;
                        color:#444;margin-bottom:10px;">Message</div>
            <asp:Label ID="lblDetailMessage" runat="server" CssClass="fb-detail-msg" />

            <hr class="fb-detail-divider" />

            <div class="modal-tabs">
                <button type="button" class="modal-tab active" id="tabNote"
                    onclick="switchModalTab('note',this)">
                    &#128274;&nbsp; Private Note
                </button>
                <button type="button" class="modal-tab" id="tabReply"
                    onclick="switchModalTab('reply',this)">
                    &#128172;&nbsp; Public Reply
                </button>
            </div>

            <%-- PANEL A: PRIVATE NOTE --%>
            <div id="modalPanelNote">
                <div class="modal-section">
                    <div class="section-label">Private Note</div>
                    <asp:Panel ID="pnlExistingNote" runat="server" Visible="false">
                        <div class="existing-box">
                            <asp:Label ID="lblExistingNote" runat="server" />
                        </div>
                        <div class="existing-meta">
                            <asp:Label ID="lblNoteDate" runat="server" />
                        </div>
                    </asp:Panel>
                    <div style="font-size:12px;color:#555;margin-bottom:10px;">
                        &#128274;&nbsp; Visible to instructors only — never shown to the public.
                    </div>
                    <asp:TextBox ID="txtNote" runat="server" TextMode="MultiLine" Rows="4"
                        CssClass="form-control form-textarea"
                        placeholder="e.g. Flagged for follow-up..." />
                    <asp:Label ID="lblNoteMsg" runat="server" CssClass="form-feedback"
                        style="display:block;margin-top:8px;" />
                    <div style="display:flex;gap:10px;margin-top:12px;">
                        <asp:Button ID="btnSaveNote" runat="server" Text="&#128190; Save Note"
                            CssClass="btn" OnClick="btnSaveNote_Click" />
                        <asp:Button ID="btnClearNote" runat="server" Text="Clear Note"
                            CssClass="btn btn-xs btn-danger"
                            OnClick="btnClearNote_Click"
                            OnClientClick="return confirm('Delete this private note?');" />
                    </div>
                </div>
            </div>

            <%-- PANEL B: PUBLIC REPLY --%>
            <div id="modalPanelReply" style="display:none;">
                <div class="modal-section modal-section--reply">
                    <div class="section-label section-label--reply">Public Reply</div>
                    <asp:Panel ID="pnlExistingReply" runat="server" Visible="false">
                        <div style="font-size:11px;color:#5ecb8a;margin-bottom:6px;font-weight:700;">
                            &#10003;&nbsp; Reply already published — guest can see this:
                        </div>
                        <div class="existing-box existing-box--reply">
                            <asp:Label ID="lblExistingReply" runat="server" />
                        </div>
                        <div class="existing-meta">
                            <asp:Label ID="lblReplyDate" runat="server" />
                        </div>
                    </asp:Panel>
                    <div style="font-size:12px;color:#555;margin-bottom:10px;">
                        &#128172;&nbsp; This reply will be <strong style="color:#5ecb8a;">publicly visible</strong>
                        under the feedback entry.
                    </div>
                    <asp:TextBox ID="txtReply" runat="server" TextMode="MultiLine" Rows="5"
                        CssClass="form-control form-textarea"
                        placeholder="e.g. Thank you for visiting..." />
                    <asp:Label ID="lblReplyMsg" runat="server" CssClass="form-feedback"
                        style="display:block;margin-top:8px;" />
                    <div style="display:flex;gap:10px;margin-top:12px;align-items:center;">
                        <asp:Button ID="btnSaveReply" runat="server" Text="&#128172; Publish Reply"
                            CssClass="btn" OnClick="btnSaveReply_Click" />
                        <asp:Button ID="btnDeleteReply" runat="server" Text="Remove Reply"
                            CssClass="btn btn-xs btn-danger"
                            OnClick="btnDeleteReply_Click"
                            OnClientClick="return confirm('Remove the public reply?');" />
                    </div>
                </div>
            </div>
        </div>

        <div class="fb-modal__footer">
            <asp:Button ID="btnModalApprove" runat="server" Text="&#10003; Approve"
                CssClass="btn btn-xs btn-success" OnClick="btnModalApprove_Click" />
            <asp:Button ID="btnModalReject" runat="server" Text="&#10007; Reject"
                CssClass="btn btn-xs btn-danger"
                OnClick="btnModalReject_Click"
                OnClientClick="return confirm('Reject this submission?');" />
            <button type="button" class="btn btn-xs" onclick="closeModal()">Close</button>
        </div>

    </div>
</div>

<script>
function closeModal() {
    document.getElementById('fbModal').style.display = 'none';
    document.getElementById('<%= hfViewID.ClientID %>').value = '0';
}
function modalBgClose(e) {
    if (e.target === document.getElementById('fbModal')) closeModal();
}
(function() {
    if ('<%= hfViewID.Value %>' !== '0') {
        document.getElementById('fbModal').style.display = 'flex';
        var t = '<%= hfModalTab.Value %>';
        if (t === 'reply') switchModalTab('reply', document.getElementById('tabReply'));
    }
})();
function switchModalTab(tab, btn) {
    document.getElementById('modalPanelNote').style.display  = tab === 'note'  ? 'block' : 'none';
    document.getElementById('modalPanelReply').style.display = tab === 'reply' ? 'block' : 'none';
    document.querySelectorAll('.modal-tab').forEach(function(b) { b.classList.remove('active'); });
    if (btn) btn.classList.add('active');
    document.getElementById('<%= hfModalTab.ClientID %>').value = tab;
    }
</script>

</asp:Content>
