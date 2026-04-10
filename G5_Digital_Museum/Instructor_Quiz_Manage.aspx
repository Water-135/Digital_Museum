<%@ Page Title="Quizzes" Language="C#" MasterPageFile="~/Master/Instructor_Master.Master"
    AutoEventWireup="true" CodeBehind="Instructor_Quiz_Manage.aspx.cs"
    Inherits="G5_Digital_Museum.Instructor_Quiz_Manage" %>

<asp:Content ID="MainQ" ContentPlaceHolderID="MainContent" runat="server">

<style>
/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   QUIZ TYPE SELECTOR  — 5 cards across
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.qtype-grid {
    display: grid;
    grid-template-columns: repeat(5,1fr);
    gap: 12px;
    margin-bottom: 32px;
}
@media(max-width:900px){ .qtype-grid{ grid-template-columns: repeat(3,1fr); } }
@media(max-width:560px){ .qtype-grid{ grid-template-columns: repeat(2,1fr); } }

.qtype-card {
    display: flex; flex-direction: column; align-items: center; gap: 10px;
    padding: 22px 14px 18px;
    background: #141414;
    border: 2px solid rgba(255,255,255,.07);
    cursor: pointer;
    transition: border-color .2s, background .2s, transform .15s;
    text-align: center;
    font-family: inherit;
    color: #666;
    user-select: none;
}
.qtype-card:hover {
    border-color: rgba(196,164,74,.45);
    background: rgba(196,164,74,.04);
    color: #c4a44a;
    transform: translateY(-2px);
}
.qtype-card.active {
    border-color: #c4a44a;
    background: rgba(196,164,74,.09);
    color: #c4a44a;
}
.qtype-card__icon { font-size: 2rem; line-height: 1; }
.qtype-card__name {
    font-size: 11px; font-weight: 800; letter-spacing: 2px;
    text-transform: uppercase;
}
.qtype-card__desc {
    font-size: 10px; line-height: 1.5; color: #444;
    text-transform: none; letter-spacing: 0;
}
.qtype-card.active .qtype-card__desc { color: #907830; }

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   PANEL LAYOUT  — form | bank split
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.page-shell-form {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 24px;
    align-items: start;
}
@media(max-width:1000px){ .page-shell-form{ grid-template-columns:1fr; } }

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   MCQ OPTION LETTERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.option-input-wrap { display:flex; align-items:center; gap:10px; }
.option-letter {
    width:28px; height:28px; border-radius:50%; flex-shrink:0;
    display:flex; align-items:center; justify-content:center;
    font-weight:800; font-size:12px;
}
.option-letter--a { background:rgba(196,164,74,.2); color:#c4a44a; }
.option-letter--b { background:rgba(94,203,138,.15); color:#5ecb8a; }
.option-letter--c { background:rgba(100,160,255,.15); color:#64a0ff; }
.option-letter--d { background:rgba(255,120,100,.15); color:#ff7864; }
.option-input { flex:1; }

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   TRUE / FALSE TOGGLE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.tf-toggle { display:flex; gap:0; margin-top:4px; }
.tf-btn {
    flex:1; padding:13px;
    border:1px solid rgba(255,255,255,.1);
    background:#1a1a1a; color:#666;
    font-size:13px; font-weight:800; letter-spacing:2px;
    cursor:pointer; transition:all .2s; text-transform:uppercase;
}
.tf-btn:first-child { border-right:none; border-radius:0; }
.tf-btn:last-child  { border-radius:0; }
.tf-btn.tf-true  { background:rgba(94,203,138,.12); color:#5ecb8a; border-color:#5ecb8a; }
.tf-btn.tf-false { background:rgba(201,76,76,.12);  color:#c94c4c; border-color:#c94c4c; }

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   IMAGE MATCH  — 4-slot grid
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.im-slots {
    display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin:16px 0;
}
@media(max-width:700px){ .im-slots{ grid-template-columns:repeat(2,1fr); } }

.im-slot {
    background:#111; border:1px solid rgba(255,255,255,.07); padding:12px;
}
.im-slot__badge {
    font-size:9px; font-weight:800; letter-spacing:2px; text-transform:uppercase;
    color:#c4a44a; margin-bottom:8px;
}
.im-slot__badge--distractor { color:#444; }
.im-slot--correct { border-color:rgba(196,164,74,.2); }

.im-slot__preview {
    width:100%; aspect-ratio:1; background:#1a1a1a;
    display:flex; align-items:center; justify-content:center;
    font-size:1.8rem; color:#2a2a2a; overflow:hidden; margin-bottom:8px;
}
.im-slot__preview img { width:100%;height:100%;object-fit:cover; }

.im-slot__src-tabs { display:flex; gap:0; margin-bottom:8px; }
.im-stab {
    flex:1; padding:5px; font-size:10px; font-weight:700; letter-spacing:1px;
    border:1px solid rgba(255,255,255,.1); background:#1a1a1a; color:#555; cursor:pointer;
    text-transform:uppercase; transition:all .15s;
}
.im-stab:first-child { border-right:none; }
.im-stab--active { background:rgba(196,164,74,.12); color:#c4a44a; border-color:rgba(196,164,74,.4); }
.im-file-input { font-size:10px; width:100%; }
.im-url-input  { font-size:11px; }

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   IMAGE MATCH  — drag-drop STUDENT PREVIEW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.im-preview-section {
    margin-top:20px; padding:18px;
    background:rgba(196,164,74,.03);
    border:1px dashed rgba(196,164,74,.2);
}
.im-preview-header {
    display:flex; justify-content:space-between; align-items:center;
    font-size:10px; font-weight:800; letter-spacing:2px; text-transform:uppercase;
    color:#c4a44a; margin-bottom:14px;
}
.dd-image-pool { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:14px; }
.dd-img-card {
    width:80px; height:80px; background:#1a1a1a;
    border:2px solid rgba(255,255,255,.1);
    display:flex; align-items:center; justify-content:center;
    cursor:grab; overflow:hidden; transition:border-color .2s; flex-shrink:0;
}
.dd-img-card img { width:100%; height:100%; object-fit:cover; }
.dd-img-card:hover { border-color:#c4a44a; }
.dd-img-card--dragging { opacity:.3; }
.dd-card-ph { font-size:10px; color:#333; text-align:center; padding:6px; }

.dd-drop-targets {
    display:grid; grid-template-columns:repeat(4,1fr); gap:10px;
}
@media(max-width:600px){ .dd-drop-targets{ grid-template-columns:repeat(2,1fr); } }
.dd-target {
    border:2px dashed rgba(255,255,255,.12); padding:8px;
    min-height:110px; display:flex; flex-direction:column;
    align-items:center; gap:6px; transition:border-color .2s; background:#0d0d0d;
}
.dd-target.dd-over { border-color:#c4a44a; background:rgba(196,164,74,.05); }
.dd-target--filled { border-color:rgba(94,203,138,.4); }
.dd-target__label { font-size:10px; color:#c4a44a; text-align:center; font-weight:700; letter-spacing:.5px; }
.dd-target__slot  { width:72px; height:72px; display:flex; align-items:center; justify-content:center; }

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   TIMELINE / SEQUENCE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.seq-events { display:flex; flex-direction:column; gap:10px; margin:14px 0; }
.seq-event-row { display:flex; align-items:center; gap:10px; }
.seq-num {
    width:28px; height:28px; border-radius:50%; flex-shrink:0;
    background:rgba(196,164,74,.12); color:#c4a44a;
    display:flex; align-items:center; justify-content:center;
    font-size:11px; font-weight:800;
}
.seq-hint {
    font-size:11px; color:#444; text-align:center; padding:8px 0;
    letter-spacing:.5px; border-top:1px solid rgba(255,255,255,.06); margin-top:4px;
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   STUDENT PREVIEW WRAPPER (shared)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.student-preview {
    margin-top:18px; padding:16px 18px;
    background:rgba(196,164,74,.03);
    border:1px dashed rgba(196,164,74,.2);
}
.preview-label {
    font-size:9px; font-weight:800; letter-spacing:3px; text-transform:uppercase;
    color:#c4a44a; margin-bottom:12px;
    display:flex; align-items:center; gap:10px;
}
.preview-label::before,
.preview-label::after {
    content:''; flex:1; height:1px; background:rgba(196,164,74,.2);
}

/* ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   TABLE truncation
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ */
.bank-q {
    max-width:260px; white-space:nowrap;
    overflow:hidden; text-overflow:ellipsis;
}

/* chip extras */
.chip--gold { background:rgba(196,164,74,.15); color:#c4a44a; border:1px solid rgba(196,164,74,.3); }
</style>

<%-- hidden field persists active tab across postbacks --%>
<asp:HiddenField ID="hfActiveTab" runat="server" Value="mcq" />
<asp:HiddenField ID="hfTFAnswer"  runat="server" Value="True" />
<%-- Edit tracking: 0 = new question, >0 = editing existing QuestionID --%>
<asp:HiddenField ID="hfEditMCQ"  runat="server" Value="0" />
<asp:HiddenField ID="hfEditTF"   runat="server" Value="0" />
<asp:HiddenField ID="hfEditFill" runat="server" Value="0" />
<asp:HiddenField ID="hfEditIM"   runat="server" Value="0" />
<asp:HiddenField ID="hfEditSA"   runat="server" Value="0" />

<!-- ══ PAGE HEADER ══ -->
<div class="pagehead">
    <div class="pagehead-left">
        <div class="pagehead-kicker">Assessment Tools</div>
        <h1>Quiz Builder</h1>
        <p>Build questions for any module — choose from 5 creative question formats below.</p>
    </div>
</div>

<!-- ══ 5 TYPE CARDS ══ -->
<div class="qtype-grid">
    <button type="button" id="cardMCQ" class="qtype-card active" onclick="showTab('mcq',this)">
        <span class="qtype-card__icon">&#9654;</span>
        <span class="qtype-card__name">Multiple Choice</span>
        <span class="qtype-card__desc">4 options, one correct — best for factual recall</span>
    </button>
    <button type="button" id="cardTF" class="qtype-card" onclick="showTab('tf',this)">
        <span class="qtype-card__icon">&#9745;</span>
        <span class="qtype-card__name">True / False</span>
        <span class="qtype-card__desc">Agree or challenge a historical statement</span>
    </button>
    <button type="button" id="cardFill" class="qtype-card" onclick="showTab('fill',this)">
        <span class="qtype-card__icon">&#9999;</span>
        <span class="qtype-card__name">Fill in Blank</span>
        <span class="qtype-card__desc">Complete a key sentence with the missing term</span>
    </button>
    <button type="button" id="cardImage" class="qtype-card" onclick="showTab('image',this)">
        <span class="qtype-card__icon">&#128248;</span>
        <span class="qtype-card__name">Image Match</span>
        <span class="qtype-card__desc">Drag historical photos to correct labels</span>
    </button>
    <button type="button" id="cardSA" class="qtype-card" onclick="showTab('sa',this)">
        <span class="qtype-card__icon">&#128336;</span>
        <span class="qtype-card__name">Timeline Order</span>
        <span class="qtype-card__desc">Sort historical events into chronological order</span>
    </button>
</div>

<!-- ════════════════════════════════════════════════════════
     TAB 1 — MULTIPLE CHOICE
════════════════════════════════════════════════════════ -->
<div class="quiz-panel" id="tab-mcq" style="display:block;">
    <div class="page-shell-form">
        <div class="form-col">
            <section class="panel">
                <div class="panel-header">
                    <div><h2 class="panel-title">Multiple Choice</h2>
                    <p class="panel-subtitle">4 options — only one is correct.</p></div>
                </div>
                <div class="form-grid">
                    <div class="form-group form-group--full">
                        <label class="form-label">Question <span class="req">*</span></label>
                        <asp:TextBox ID="txtMCQQuestion" runat="server" TextMode="MultiLine" Rows="3"
                            CssClass="form-control form-textarea"
                            placeholder="e.g. On which date did Japanese forces enter Nanjing?" />
                    </div>
                    <div class="form-group form-group--full">
                        <label class="form-label">Option A <span class="req">*</span></label>
                        <div class="option-input-wrap">
                            <span class="option-letter option-letter--a">A</span>
                            <asp:TextBox ID="txtA" runat="server" CssClass="form-control option-input" placeholder="Option A" />
                        </div>
                    </div>
                    <div class="form-group form-group--full">
                        <label class="form-label">Option B <span class="req">*</span></label>
                        <div class="option-input-wrap">
                            <span class="option-letter option-letter--b">B</span>
                            <asp:TextBox ID="txtB" runat="server" CssClass="form-control option-input" placeholder="Option B" />
                        </div>
                    </div>
                    <div class="form-group form-group--full">
                        <label class="form-label">Option C <span class="req">*</span></label>
                        <div class="option-input-wrap">
                            <span class="option-letter option-letter--c">C</span>
                            <asp:TextBox ID="txtC" runat="server" CssClass="form-control option-input" placeholder="Option C" />
                        </div>
                    </div>
                    <div class="form-group form-group--full">
                        <label class="form-label">Option D <span class="req">*</span></label>
                        <div class="option-input-wrap">
                            <span class="option-letter option-letter--d">D</span>
                            <asp:TextBox ID="txtD" runat="server" CssClass="form-control option-input" placeholder="Option D" />
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Correct Answer</label>
                        <asp:DropDownList ID="ddlMCQAnswer" runat="server" CssClass="form-control">
                            <asp:ListItem Text="A" Value="A" /><asp:ListItem Text="B" Value="B" />
                            <asp:ListItem Text="C" Value="C" /><asp:ListItem Text="D" Value="D" />
                        </asp:DropDownList>
                    </div>
                    <div class="form-group">
                        <label class="form-label">Linked Module <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlMCQModule" runat="server" CssClass="form-control" />
                    </div>
                    <div class="form-group form-group--full">
                        <label class="form-label">Explanation <span style="color:#555;font-weight:400;">(shown after answering)</span></label>
                        <asp:TextBox ID="txtMCQExpl" runat="server" CssClass="form-control form-textarea"
                            TextMode="MultiLine" Rows="2"
                            placeholder="e.g. Japanese forces entered Nanjing on 13 December 1937..." />
                    </div>
                </div>
                <asp:Label ID="lblMCQMsg" runat="server" CssClass="form-feedback" />
                <div class="form-actions">
                    <asp:Button ID="btnMCQClear" runat="server" Text="Clear" CssClass="btn btn-xs"
                        OnClick="btnMCQClear_Click" CausesValidation="false" />
                    <asp:Button ID="btnMCQSave"  runat="server" Text="Save Question" CssClass="btn"
                        OnClick="btnMCQSave_Click" />
                    <asp:Label ID="lblMCQEditBadge" runat="server" Visible="false"
                        style="margin-left:10px;font-size:12px;color:#c4a44a;">&#9998; Editing existing question — Save will update it.</asp:Label>
                </div>
            </section>
        </div>
        <div class="table-col">
            <section class="panel">
                <div class="panel-header">
                    <div><h2 class="panel-title">MCQ Bank</h2>
                    <p class="panel-subtitle">All saved multiple choice questions.</p></div>
                </div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>Question</th><th>Ans</th><th>Module</th><th></th></tr></thead>
                        <tbody>
                            <asp:Repeater ID="rptMCQ" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td class="bank-q"><%# Eval("QuestionText") %></td>
                                        <td><span class="chip chip--live"><%# Eval("CorrectAnswer") %></span></td>
                                        <td class="td-muted" style="font-size:11px;"><%# Eval("ModuleTitle") %></td>
                                        <td style="white-space:nowrap;">
                                            <asp:Button ID="btnMCQEdit" runat="server" Text="&#9998; Edit"
                                                CssClass="btn btn-xs"
                                                CommandArgument='<%# Eval("QuestionID") %>'
                                                OnClick="btnMCQEdit_Click"
                                                CausesValidation="false" />
                                            <asp:Button ID="btnMCQDel" runat="server" Text="&#128465;"
                                                CssClass="btn btn-xs btn-danger"
                                                CommandArgument='<%# Eval("QuestionID") %>'
                                                OnClick="btnMCQDelete_Click"
                                                OnClientClick="return confirm('Delete?');" /></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════════════
     TAB 2 — TRUE / FALSE
════════════════════════════════════════════════════════ -->
<div class="quiz-panel" id="tab-tf" style="display:none;">
    <div class="page-shell-form">
        <div class="form-col">
            <section class="panel">
                <div class="panel-header">
                    <div><h2 class="panel-title">True / False</h2>
                    <p class="panel-subtitle">Students judge whether the historical statement is accurate.</p></div>
                </div>
                <div class="form-grid">
                    <div class="form-group form-group--full">
                        <label class="form-label">Statement <span class="req">*</span></label>
                        <asp:TextBox ID="txtTFQuestion" runat="server" TextMode="MultiLine" Rows="4"
                            CssClass="form-control form-textarea"
                            placeholder="e.g. John Rabe used his Nazi Party status to protect civilians in the Nanjing Safety Zone." />
                    </div>
                    <div class="form-group form-group--full">
                        <label class="form-label">Correct Answer</label>
                        <div class="tf-toggle">
                            <button type="button" id="tfBtnTrue"  class="tf-btn tf-true"
                                onclick="setTF('True',this)">&#10003;&nbsp;TRUE</button>
                            <button type="button" id="tfBtnFalse" class="tf-btn"
                                onclick="setTF('False',this)">&#10007;&nbsp;FALSE</button>
                        </div>
                    </div>
                    <div class="form-group form-group--full">
                        <label class="form-label">Explanation <span style="color:#555;font-weight:400;">(shown after answering)</span></label>
                        <asp:TextBox ID="txtTFExpl" runat="server" CssClass="form-control form-textarea"
                            TextMode="MultiLine" Rows="2" placeholder="Briefly explain why this is true or false..." />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Points</label>
                        <asp:TextBox ID="txtTFPoints" runat="server" CssClass="form-control" Text="1" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Linked Module <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlTFModule" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <asp:Label ID="lblTFMsg" runat="server" CssClass="form-feedback" />
                <div class="form-actions">
                    <asp:Button ID="btnTFClear" runat="server" Text="Clear" CssClass="btn btn-xs"
                        OnClick="btnTFClear_Click" CausesValidation="false" />
                    <asp:Button ID="btnTFSave"  runat="server" Text="Save Question" CssClass="btn"
                        OnClick="btnTFSave_Click" />
                    <asp:Label ID="lblTFEditBadge" runat="server" Visible="false"
                        style="margin-left:10px;font-size:12px;color:#c4a44a;">&#9998; Editing existing question — Save will update it.</asp:Label>
                </div>
            </section>
        </div>
        <div class="table-col">
            <section class="panel">
                <div class="panel-header">
                    <div><h2 class="panel-title">True/False Bank</h2></div>
                </div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>Statement</th><th>Answer</th><th>Module</th><th></th></tr></thead>
                        <tbody>
                            <asp:Repeater ID="rptTF" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td class="bank-q"><%# Eval("QuestionText") %></td>
                                        <td><span class='chip <%# Eval("CorrectAnswer").ToString()=="True"?"chip--live":"chip--draft" %>'><%# Eval("CorrectAnswer") %></span></td>
                                        <td class="td-muted" style="font-size:11px;"><%# Eval("ModuleTitle") %></td>
                                        <td style="white-space:nowrap;">
                                            <asp:Button ID="btnTFEdit" runat="server" Text="&#9998; Edit"
                                                CssClass="btn btn-xs"
                                                CommandArgument='<%# Eval("QuestionID") %>'
                                                OnClick="btnTFEdit_Click"
                                                CausesValidation="false" />
                                            <asp:Button ID="btnTFDel" runat="server" Text="&#128465;"
                                                CssClass="btn btn-xs btn-danger"
                                                CommandArgument='<%# Eval("QuestionID") %>'
                                                OnClick="btnTFDelete_Click"
                                                OnClientClick="return confirm('Delete?');" /></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════════════
     TAB 3 — FILL IN THE BLANK
════════════════════════════════════════════════════════ -->
<div class="quiz-panel" id="tab-fill" style="display:none;">
    <div class="page-shell-form">
        <div class="form-col">
            <section class="panel">
                <div class="panel-header">
                    <div><h2 class="panel-title">Fill in the Blank</h2>
                    <p class="panel-subtitle">Use <strong style="color:#c4a44a;">___</strong> (three underscores) where the blank should appear.</p></div>
                </div>
                <div class="form-grid">
                    <div class="form-group form-group--full">
                        <label class="form-label">Sentence with blank <span class="req">*</span></label>
                        <asp:TextBox ID="txtFillQuestion" runat="server" TextMode="MultiLine" Rows="3"
                            CssClass="form-control form-textarea"
                            placeholder="e.g. The Nanjing Safety Zone sheltered approximately ___ Chinese civilians." />
                        <div style="font-size:11px;color:#555;margin-top:5px;">
                            Type <strong style="color:#c4a44a;">___</strong> exactly three underscores where the blank should be.
                        </div>
                    </div>
                    <div class="form-group form-group--full">
                        <label class="form-label">Correct Answer <span class="req">*</span></label>
                        <asp:TextBox ID="txtFillAnswer" runat="server" CssClass="form-control"
                            placeholder="e.g. 200,000" />
                    </div>
                    <div class="form-group form-group--full">
                        <label class="form-label">Also Accept <span style="color:#555;font-weight:400;">— alternate spellings, comma-separated</span></label>
                        <asp:TextBox ID="txtFillAlt" runat="server" CssClass="form-control"
                            placeholder="e.g. 200000, two hundred thousand" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Points</label>
                        <asp:TextBox ID="txtFillPoints" runat="server" CssClass="form-control" Text="1" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Linked Module <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlFillModule" runat="server" CssClass="form-control" />
                    </div>
                </div>
                <asp:Label ID="lblFillMsg" runat="server" CssClass="form-feedback" />
                <div class="form-actions">
                    <asp:Button ID="btnFillClear" runat="server" Text="Clear" CssClass="btn btn-xs"
                        OnClick="btnFillClear_Click" CausesValidation="false" />
                    <asp:Button ID="btnFillSave"  runat="server" Text="Save Question" CssClass="btn"
                        OnClick="btnFillSave_Click" />
                    <asp:Label ID="lblFillEditBadge" runat="server" Visible="false"
                        style="margin-left:10px;font-size:12px;color:#c4a44a;">&#9998; Editing existing question — Save will update it.</asp:Label>
                </div>
            </section>
        </div>
        <div class="table-col">
            <section class="panel">
                <div class="panel-header">
                    <div><h2 class="panel-title">Fill-in-Blank Bank</h2></div>
                </div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>Sentence</th><th>Answer</th><th>Module</th><th></th></tr></thead>
                        <tbody>
                            <asp:Repeater ID="rptFill" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td class="bank-q"><%# Eval("QuestionText") %></td>
                                        <td><span class="chip chip--gold"><%# Eval("CorrectAnswer") %></span></td>
                                        <td class="td-muted" style="font-size:11px;"><%# Eval("ModuleTitle") %></td>
                                        <td style="white-space:nowrap;">
                                            <asp:Button ID="btnFillEdit" runat="server" Text="&#9998; Edit"
                                                CssClass="btn btn-xs"
                                                CommandArgument='<%# Eval("QuestionID") %>'
                                                OnClick="btnFillEdit_Click"
                                                CausesValidation="false" />
                                            <asp:Button ID="btnFillDel" runat="server" Text="&#128465;"
                                                CssClass="btn btn-xs btn-danger"
                                                CommandArgument='<%# Eval("QuestionID") %>'
                                                OnClick="btnFillDelete_Click"
                                                OnClientClick="return confirm('Delete?');" /></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════════════
     TAB 4 — IMAGE MATCH (drag-drop)
════════════════════════════════════════════════════════ -->
<div class="quiz-panel" id="tab-image" style="display:none;">
    <div class="page-shell-form">
        <div class="form-col">
            <section class="panel">
                <div class="panel-header">
                    <div><h2 class="panel-title">Image Match</h2>
                    <p class="panel-subtitle">Enter an instruction + 1 correct label. Upload 4 photos (no labels on them). Students drag <strong>only the correct photo</strong> to the label.</p></div>
                </div>
                <div class="form-grid">
                    <div class="form-group form-group--full">
                        <label class="form-label">Instruction <span class="req">*</span></label>
                        <asp:TextBox ID="txtIMQuestion" runat="server" TextMode="MultiLine" Rows="2"
                            CssClass="form-control form-textarea"
                            placeholder="e.g. Drag each photograph to the correct person or location." />
                    </div>
                </div>

                <!-- 4 image slots -->
                <div class="im-slots">
                    <div class="im-slot im-slot--correct">
                        <div class="im-slot__badge">&#9733; Correct</div>
                        <div class="im-slot__preview" id="prevCorrect"><span>&#128444;</span></div>
                        <div class="im-slot__src-tabs">
                            <button type="button" class="im-stab im-stab--active" onclick="switchImSlot('correct','upload',this)">Upload</button>
                            <button type="button" class="im-stab"                 onclick="switchImSlot('correct','url',this)">URL</button>
                        </div>
                        <div id="slotCorrectUpload">
                            <asp:FileUpload ID="fuIMCorrect" runat="server" CssClass="im-file-input"
                                onchange="previewImSlot('correct',this)" />
                        </div>
                        <div id="slotCorrectUrl" style="display:none;">
                            <asp:TextBox ID="txtIMCorrectUrl" runat="server" CssClass="form-control im-url-input"
                                placeholder="https://..." oninput="previewImSlotUrl('correct',this.value)" />
                        </div>
                        <%-- Label hidden — students see no labels on images; only the question label exists --%>
                        <asp:TextBox ID="txtIMCorrectLabel" runat="server" style="display:none;" />
                    </div>

                    <div class="im-slot">
                        <div class="im-slot__badge im-slot__badge--distractor">Distractor 1</div>
                        <div class="im-slot__preview" id="prevD1"><span>&#128444;</span></div>
                        <div class="im-slot__src-tabs">
                            <button type="button" class="im-stab im-stab--active" onclick="switchImSlot('d1','upload',this)">Upload</button>
                            <button type="button" class="im-stab"                 onclick="switchImSlot('d1','url',this)">URL</button>
                        </div>
                        <div id="slotD1Upload">
                            <asp:FileUpload ID="fuIMD1" runat="server" CssClass="im-file-input"
                                onchange="previewImSlot('d1',this)" />
                        </div>
                        <div id="slotD1Url" style="display:none;">
                            <asp:TextBox ID="txtIMD1Url" runat="server" CssClass="form-control im-url-input"
                                placeholder="https://..." oninput="previewImSlotUrl('d1',this.value)" />
                        </div>
                        <asp:TextBox ID="txtIMD1Label" runat="server" style="display:none;" />
                    </div>

                    <div class="im-slot">
                        <div class="im-slot__badge im-slot__badge--distractor">Distractor 2</div>
                        <div class="im-slot__preview" id="prevD2"><span>&#128444;</span></div>
                        <div class="im-slot__src-tabs">
                            <button type="button" class="im-stab im-stab--active" onclick="switchImSlot('d2','upload',this)">Upload</button>
                            <button type="button" class="im-stab"                 onclick="switchImSlot('d2','url',this)">URL</button>
                        </div>
                        <div id="slotD2Upload">
                            <asp:FileUpload ID="fuIMD2" runat="server" CssClass="im-file-input"
                                onchange="previewImSlot('d2',this)" />
                        </div>
                        <div id="slotD2Url" style="display:none;">
                            <asp:TextBox ID="txtIMD2Url" runat="server" CssClass="form-control im-url-input"
                                placeholder="https://..." oninput="previewImSlotUrl('d2',this.value)" />
                        </div>
                        <asp:TextBox ID="txtIMD2Label" runat="server" style="display:none;" />
                    </div>

                    <div class="im-slot">
                        <div class="im-slot__badge im-slot__badge--distractor">Distractor 3</div>
                        <div class="im-slot__preview" id="prevD3"><span>&#128444;</span></div>
                        <div class="im-slot__src-tabs">
                            <button type="button" class="im-stab im-stab--active" onclick="switchImSlot('d3','upload',this)">Upload</button>
                            <button type="button" class="im-stab"                 onclick="switchImSlot('d3','url',this)">URL</button>
                        </div>
                        <div id="slotD3Upload">
                            <asp:FileUpload ID="fuIMD3" runat="server" CssClass="im-file-input"
                                onchange="previewImSlot('d3',this)" />
                        </div>
                        <div id="slotD3Url" style="display:none;">
                            <asp:TextBox ID="txtIMD3Url" runat="server" CssClass="form-control im-url-input"
                                placeholder="https://..." oninput="previewImSlotUrl('d3',this.value)" />
                        </div>
                        <asp:TextBox ID="txtIMD3Label" runat="server" style="display:none;" />
                    </div>
                </div>

                <div class="form-grid" style="margin-top:14px;">
                    <div class="form-group form-group--full">
                        <label class="form-label">Correct Label <span class="req">*</span>
                            <span style="color:#555;font-weight:400;font-size:10px;">— the ONE label students must match the correct photo to</span>
                        </label>
                        <asp:TextBox ID="txtIMLabel" runat="server" CssClass="form-control"
                            placeholder="e.g. John Rabe — chairman of the Nanjing Safety Zone"
                            oninput="syncNewLabel(this.value)" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Points</label>
                        <asp:TextBox ID="txtIMPoints" runat="server" CssClass="form-control" Text="2" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Linked Module <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlIMModule" runat="server" CssClass="form-control" />
                    </div>
                </div>

                <!-- Student view drag-drop preview — ONE label, 4 photos -->
                <div class="im-preview-section">
                    <div class="im-preview-header">
                        <span>&#128065; Student View Preview</span>
                        <button type="button" class="btn btn-xs" onclick="resetDDPreview()">&#8635; Reset</button>
                    </div>
                    <p style="font-size:11px;color:#555;margin:0 0 10px;">Drag the correct photo from the pool to the label box.</p>
                    <!-- Pool: 4 unlabelled photo cards -->
                    <div class="dd-image-pool" id="ddPool">
                        <div class="dd-img-card" draggable="true" id="ddCard_correct" ondragstart="ddStart(event,'correct')">
                            <img id="ddCardImg_correct" src="" style="display:none;width:100%;height:100%;object-fit:cover;" />
                            <span id="ddCardPh_correct" class="dd-card-ph">&#128444;</span>
                        </div>
                        <div class="dd-img-card" draggable="true" id="ddCard_d1" ondragstart="ddStart(event,'d1')">
                            <img id="ddCardImg_d1" src="" style="display:none;width:100%;height:100%;object-fit:cover;" />
                            <span id="ddCardPh_d1" class="dd-card-ph">&#128444;</span>
                        </div>
                        <div class="dd-img-card" draggable="true" id="ddCard_d2" ondragstart="ddStart(event,'d2')">
                            <img id="ddCardImg_d2" src="" style="display:none;width:100%;height:100%;object-fit:cover;" />
                            <span id="ddCardPh_d2" class="dd-card-ph">&#128444;</span>
                        </div>
                        <div class="dd-img-card" draggable="true" id="ddCard_d3" ondragstart="ddStart(event,'d3')">
                            <img id="ddCardImg_d3" src="" style="display:none;width:100%;height:100%;object-fit:cover;" />
                            <span id="ddCardPh_d3" class="dd-card-ph">&#128444;</span>
                        </div>
                    </div>
                    <!-- Single drop target -->
                    <div style="display:flex;gap:12px;align-items:flex-start;margin-top:4px;">
                        <div class="dd-target" style="flex:1;max-width:200px;"
                            ondragover="ddOver(event)" ondragleave="ddLeave(event)" ondrop="ddDrop(event,'correct')">
                            <span class="dd-target__label" id="ddTargetLbl_correct">Label (Correct)</span>
                            <div class="dd-target__slot" id="ddSlot_correct"></div>
                        </div>
                        <p style="font-size:11px;color:#444;margin:0;padding-top:8px;">
                            &#8592; Drag the correct photo here.<br/>
                            The other 3 photos are wrong answers — students must identify which one belongs.
                        </p>
                    </div>
                </div>

                <asp:Label ID="lblIMMsg" runat="server" CssClass="form-feedback" />
                <div class="form-actions">
                    <asp:Button ID="btnIMClear" runat="server" Text="Clear" CssClass="btn btn-xs"
                        OnClick="btnIMClear_Click" CausesValidation="false" />
                    <asp:Button ID="btnIMSave"  runat="server" Text="Save Question" CssClass="btn"
                        OnClick="btnIMSave_Click" />
                    <asp:Label ID="lblIMEditBadge" runat="server" Visible="false"
                        style="margin-left:10px;font-size:12px;color:#c4a44a;">&#9998; Editing existing question — Save will update it.</asp:Label>
                </div>
            </section>
        </div>
        <div class="table-col">
            <section class="panel">
                <div class="panel-header">
                    <div><h2 class="panel-title">Image Match Bank</h2></div>
                </div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>Instruction</th><th>Correct Label</th><th>Module</th><th></th></tr></thead>
                        <tbody>
                            <asp:Repeater ID="rptIM" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td class="bank-q"><%# Eval("QuestionText") %></td>
                                        <td><span class="chip chip--live"><%# Eval("CorrectLabel") %></span></td>
                                        <td class="td-muted" style="font-size:11px;"><%# Eval("ModuleTitle") %></td>
                                        <td style="white-space:nowrap;">
                                            <asp:Button ID="btnIMEdit" runat="server" Text="&#9998; Edit"
                                                CssClass="btn btn-xs"
                                                CommandArgument='<%# Eval("QuestionID") %>'
                                                OnClick="btnIMEdit_Click"
                                                CausesValidation="false" />
                                            <asp:Button ID="btnIMDel" runat="server" Text="&#128465;"
                                                CssClass="btn btn-xs btn-danger"
                                                CommandArgument='<%# Eval("QuestionID") %>'
                                                OnClick="btnIMDelete_Click"
                                                OnClientClick="return confirm('Delete?');" /></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </div>
</div>

<!-- ════════════════════════════════════════════════════════
     TAB 5 — TIMELINE ORDER (sequence)
════════════════════════════════════════════════════════ -->
<div class="quiz-panel" id="tab-sa" style="display:none;">
    <div class="page-shell-form">
        <div class="form-col">
            <section class="panel">
                <div class="panel-header">
                    <div><h2 class="panel-title">Timeline Order</h2>
                    <p class="panel-subtitle">Enter 2–8 historical events in the correct order. Students must drag them into the right sequence.</p></div>
                </div>
                <div class="form-grid">
                    <div class="form-group form-group--full">
                        <label class="form-label">Instruction <span class="req">*</span></label>
                        <asp:TextBox ID="txtSAQuestion" runat="server" CssClass="form-control"
                            placeholder="e.g. Arrange these events of the Nanjing Massacre in chronological order." />
                    </div>
                </div>

                <%-- Fixed event fields — always present so server controls exist --%>
                <div class="seq-events" id="seqEventList">
                    <div class="seq-event-row" id="seqRow1">
                        <span class="seq-num">1</span>
                        <asp:TextBox ID="txtSAModel" runat="server" CssClass="form-control"
                            placeholder="First event (earliest)" oninput="buildSeqPreview()" />
                    </div>
                    <div class="seq-event-row" id="seqRow2">
                        <span class="seq-num">2</span>
                        <asp:TextBox ID="txtSeq2" runat="server" CssClass="form-control"
                            placeholder="Second event" oninput="buildSeqPreview()" />
                    </div>
                    <div class="seq-event-row" id="seqRow3" style="display:none;">
                        <span class="seq-num">3</span>
                        <asp:TextBox ID="txtSeq3" runat="server" CssClass="form-control"
                            placeholder="Third event (optional)" oninput="buildSeqPreview()" />
                        <button type="button" class="btn btn-xs btn-danger" style="flex-shrink:0;"
                            onclick="removeSeqRow(3)">&#10005;</button>
                    </div>
                    <div class="seq-event-row" id="seqRow4" style="display:none;">
                        <span class="seq-num">4</span>
                        <asp:TextBox ID="txtSeq4" runat="server" CssClass="form-control"
                            placeholder="Fourth event (optional)" oninput="buildSeqPreview()" />
                        <button type="button" class="btn btn-xs btn-danger" style="flex-shrink:0;"
                            onclick="removeSeqRow(4)">&#10005;</button>
                    </div>
                    <div class="seq-event-row" id="seqRow5" style="display:none;">
                        <span class="seq-num">5</span>
                        <asp:TextBox ID="txtSeq5" runat="server" CssClass="form-control"
                            placeholder="Fifth event (optional)" oninput="buildSeqPreview()" />
                        <button type="button" class="btn btn-xs btn-danger" style="flex-shrink:0;"
                            onclick="removeSeqRow(5)">&#10005;</button>
                    </div>
                    <%-- txtSeq6/7/8 kept as hidden stubs so CS code compiles --%>
                    <asp:TextBox ID="txtSeq6" runat="server" style="display:none;" />
                    <asp:TextBox ID="txtSeq7" runat="server" style="display:none;" />
                    <asp:TextBox ID="txtSeq8" runat="server" style="display:none;" />
                </div>

                <div style="margin-top:10px;display:flex;gap:10px;align-items:center;">
                    <button type="button" class="btn btn-xs" id="btnAddEvent" onclick="addSeqRow()">
                        &#43; Add Event
                    </button>
                    <span id="seqCountHint" style="font-size:11px;color:#555;">2 events</span>
                </div>
                <div class="seq-hint">&#8597;&nbsp; Numbers above = the correct order students must reproduce.</div>

                <!-- Live shuffle preview -->
                <div class="student-preview" style="margin-top:18px;">
                    <div class="preview-label">Student View Preview</div>
                    <div id="seqPool" style="display:flex;flex-direction:column;gap:8px;min-height:40px;">
                        <p style="color:#444;font-size:12px;">Enter at least 2 events above to see preview.</p>
                    </div>
                    <button type="button" class="btn btn-xs" style="margin-top:10px;"
                        onclick="buildSeqPreview()">&#8635; Shuffle</button>
                </div>

                <div class="form-grid" style="margin-top:16px;">
                    <div class="form-group">
                        <label class="form-label">Points</label>
                        <asp:TextBox ID="txtSAWords" runat="server" CssClass="form-control" Text="3" />
                    </div>
                    <div class="form-group">
                        <label class="form-label">Linked Module <span class="req">*</span></label>
                        <asp:DropDownList ID="ddlSAModule" runat="server" CssClass="form-control" />
                    </div>
                </div>

                <asp:Label ID="lblSAMsg" runat="server" CssClass="form-feedback" />
                <div class="form-actions">
                    <asp:Button ID="btnSAClear" runat="server" Text="Clear" CssClass="btn btn-xs"
                        OnClick="btnSAClear_Click" CausesValidation="false" />
                    <asp:Button ID="btnSASave"  runat="server" Text="Save Question" CssClass="btn"
                        OnClick="btnSASave_Click" />
                    <asp:Label ID="lblSAEditBadge" runat="server" Visible="false"
                        style="margin-left:10px;font-size:12px;color:#c4a44a;">&#9998; Editing existing question — Save will update it.</asp:Label>
                </div>
            </section>
        </div>
        <div class="table-col">
            <section class="panel">
                <div class="panel-header">
                    <div><h2 class="panel-title">Timeline Bank</h2></div>
                </div>
                <div class="table-wrap">
                    <table class="data-table">
                        <thead><tr><th>Instruction</th><th>Events</th><th>Module</th><th></th></tr></thead>
                        <tbody>
                            <asp:Repeater ID="rptSA" runat="server">
                                <ItemTemplate>
                                    <tr>
                                        <td class="bank-q"><%# Eval("QuestionText") %></td>
                                        <td><span class="chip"><%# Eval("EventCount") %> events</span></td>
                                        <td class="td-muted" style="font-size:11px;"><%# Eval("ModuleTitle") %></td>
                                        <td style="white-space:nowrap;">
                                            <asp:Button ID="btnSAEdit" runat="server" Text="&#9998; Edit"
                                                CssClass="btn btn-xs"
                                                CommandArgument='<%# Eval("QuestionID") %>'
                                                OnClick="btnSAEdit_Click"
                                                CausesValidation="false" />
                                            <asp:Button ID="btnSADel" runat="server" Text="&#128465;"
                                                CssClass="btn btn-xs btn-danger"
                                                CommandArgument='<%# Eval("QuestionID") %>'
                                                OnClick="btnSADelete_Click"
                                                OnClientClick="return confirm('Delete?');" /></td>
                                    </tr>
                                </ItemTemplate>
                            </asp:Repeater>
                        </tbody>
                    </table>
                </div>
            </section>
        </div>
    </div>
</div>

<!-- ══ SCRIPTS ══ -->
<script>
// ── Tab switching ─────────────────────────────────────────
var TABS = ['mcq','tf','fill','image','sa'];
var CARD_IDS = { mcq:'cardMCQ', tf:'cardTF', fill:'cardFill', image:'cardImage', sa:'cardSA' };

function showTab(id, btn) {
    TABS.forEach(function(t) {
        var p = document.getElementById('tab-' + t);
        var c = document.getElementById(CARD_IDS[t]);
        if (p) p.style.display = 'none';
        if (c) c.classList.remove('active');
    });
    var panel = document.getElementById('tab-' + id);
    if (panel) panel.style.display = 'block';
    if (btn) btn.classList.add('active');
    var _hfTab = document.querySelector("input[id$='hfActiveTab']");
    if (_hfTab) _hfTab.value = id;
    if (id === 'sa') buildSeqPreview();
    return false;
}

// Restore tab on postback
document.addEventListener('DOMContentLoaded', function() {
    try {
        var _hfT = document.querySelector("input[id$='hfActiveTab']");
        var t = _hfT ? _hfT.value : 'mcq';
        if (t && t !== 'mcq') {
            var card = document.getElementById(CARD_IDS[t]);
            showTab(t, card);
        }
    } catch(e) { console.warn('Tab restore:', e); }
});

// ── True/False toggle ─────────────────────────────────────
function setTF(val, btn) {
    var bt = document.getElementById('tfBtnTrue');
    var bf = document.getElementById('tfBtnFalse');
    bt.className = 'tf-btn' + (val === 'True'  ? ' tf-true'  : '');
    bf.className = 'tf-btn' + (val === 'False' ? ' tf-false' : '');
    var _hfTF = document.querySelector("input[id$='hfTFAnswer']");
    if (_hfTF) _hfTF.value = val;
}
document.addEventListener('DOMContentLoaded', function() {
    try { if ('<%= hfTFAnswer.Value %>' === 'False') setTF('False', null); }
    catch(e) { console.warn('TF restore:', e); }
});

// ── Image slot upload/URL switch ──────────────────────────
function switchImSlot(slot, mode, btn) {
    var s = slot.charAt(0).toUpperCase() + slot.slice(1);
    document.getElementById('slot' + s + 'Upload').style.display = mode === 'upload' ? 'block' : 'none';
    document.getElementById('slot' + s + 'Url').style.display    = mode === 'url'    ? 'block' : 'none';
    btn.closest('.im-slot__src-tabs').querySelectorAll('.im-stab').forEach(function(b) {
        b.classList.remove('im-stab--active');
    });
    btn.classList.add('im-stab--active');
}

// ── Image preview ─────────────────────────────────────────
function previewImSlot(slot, input) {
    if (!input.files || !input.files[0]) return;
    var r = new FileReader();
    r.onload = function(e) { applyImPreview(slot, e.target.result); };
    r.readAsDataURL(input.files[0]);
}
function previewImSlotUrl(slot, url) {
    if (url && url.trim()) applyImPreview(slot, url.trim());
}
function applyImPreview(slot, src) {
    var s  = slot.charAt(0).toUpperCase() + slot.slice(1);
    var box = document.getElementById('prev' + s);
    if (box) box.innerHTML = '<img src="' + src + '" style="width:100%;height:100%;object-fit:cover;" onerror="this.remove()" />';
    var ci = document.getElementById('ddCardImg_' + slot);
    var cp = document.getElementById('ddCardPh_'  + slot);
    if (ci) { ci.src = src; ci.style.display = 'block'; }
    if (cp)   cp.style.display = 'none';
}

// ── Sync single correct label → drop target ───────────────
function syncNewLabel(val) {
    var lbl = document.getElementById('ddTargetLbl_correct');
    if (lbl) lbl.textContent = val || 'Label (Correct)';
}
// Init on load in case of edit postback
document.addEventListener('DOMContentLoaded', function() {
    try {
        var inp = document.querySelector("input[id$='txtIMLabel'],textarea[id$='txtIMLabel']");
        if (inp && inp.value) syncNewLabel(inp.value);
    } catch(e) {}
});

// ── Drag-and-drop ─────────────────────────────────────────
var draggedSlot = null;
function ddStart(e, slot) {
    draggedSlot = slot;
    e.dataTransfer.effectAllowed = 'move';
    document.getElementById('ddCard_' + slot).classList.add('dd-img-card--dragging');
}
function ddOver(e)  { e.preventDefault(); e.currentTarget.classList.add('dd-over'); }
function ddLeave(e) { e.currentTarget.classList.remove('dd-over'); }
document.addEventListener('dragend', function() {
    if (draggedSlot) document.getElementById('ddCard_' + draggedSlot).classList.remove('dd-img-card--dragging');
    draggedSlot = null;
    document.querySelectorAll('.dd-target').forEach(function(t) { t.classList.remove('dd-over'); });
});
function ddDrop(e, targetSlot) {
    e.preventDefault();
    e.currentTarget.classList.remove('dd-over');
    if (!draggedSlot) return;
    var slot = document.getElementById('ddSlot_' + targetSlot);
    var card = document.getElementById('ddCard_' + draggedSlot);
    var pool = document.getElementById('ddPool');
    if (slot.firstChild) pool.appendChild(slot.firstChild);
    card.classList.remove('dd-img-card--dragging');
    slot.appendChild(card);
    e.currentTarget.classList.add('dd-target--filled');
    draggedSlot = null;
}
function resetDDPreview() {
    var pool = document.getElementById('ddPool');
    ['correct','d1','d2','d3'].forEach(function(s) {
        var slot = document.getElementById('ddSlot_' + s);
        if (slot && slot.firstChild) pool.appendChild(slot.firstChild);
        var t = document.getElementById('ddCard_' + s);
        if (t) t.closest('.dd-target') && t.closest('.dd-target').classList.remove('dd-target--filled');
    });
    document.querySelectorAll('.dd-target').forEach(function(t) { t.classList.remove('dd-target--filled'); });
}

// ── Sequence / Timeline — max 5 events (matches DB: CorrectAnswer + OptionA-D)
    var SEQ_IDS = [
        '<%= txtSAModel.ClientID %>',
        '<%= txtSeq2.ClientID %>',
        '<%= txtSeq3.ClientID %>',
        '<%= txtSeq4.ClientID %>',
        '<%= txtSeq5.ClientID %>'
    ];
    var MAX_EVENTS = 5;
    var seqVisible = 2;

    function updateSeqCount() {
        var hint = document.getElementById('seqCountHint');
        if (hint) hint.textContent = seqVisible + ' event' + (seqVisible !== 1 ? 's' : '');
        var btn = document.getElementById('btnAddEvent');
        if (btn) btn.style.display = seqVisible >= MAX_EVENTS ? 'none' : '';
    }

    function addSeqRow() {
        if (seqVisible >= MAX_EVENTS) return;
        seqVisible++;
        var row = document.getElementById('seqRow' + seqVisible);
        if (row) row.style.display = '';
        updateSeqCount();
        buildSeqPreview();
    }

    function removeSeqRow(n) {
        for (var r = n; r <= MAX_EVENTS; r++) {
            var row = document.getElementById('seqRow' + r);
            var el = document.getElementById(SEQ_IDS[r - 1]);
            if (row) row.style.display = 'none';
            if (el) el.value = '';
        }
        seqVisible = n - 1;
        updateSeqCount();
        buildSeqPreview();
    }


    function buildSeqPreview() {
        var events = SEQ_IDS.map(function (id) {
            var el = document.getElementById(id);
            return el ? el.value.trim() : '';
        }).filter(function (v) { return v.length > 0; });

        var pool = document.getElementById('seqPool');
        if (!pool) return;
        if (events.length < 2) {
            pool.innerHTML = '<p style="color:#444;font-size:12px;padding:8px 0;">Enter at least 2 events above to see preview.</p>';
            return;
        }
        // Fisher-Yates shuffle
        var s = events.slice();
        for (var i = s.length - 1; i > 0; i--) {
            var j = Math.floor(Math.random() * (i + 1));
            var tmp = s[i]; s[i] = s[j]; s[j] = tmp;
        }
        pool.innerHTML = '';
        s.forEach(function (ev) {
            var div = document.createElement('div');
            div.style.cssText = 'display:flex;align-items:center;gap:12px;padding:10px 14px;' +
                'background:#1a1a1a;border:1px solid rgba(255,255,255,.08);cursor:grab;' +
                'font-size:13px;color:#ccc;';
            div.draggable = true;
            div.innerHTML = '<span style="color:#444;font-size:16px;cursor:grab;">&#9776;</span>' + ev;
            pool.appendChild(div);
        });
    }

    // Restore visible rows on postback — runs AFTER DOM is ready
    document.addEventListener('DOMContentLoaded', function () {
        for (var i = 2; i < SEQ_IDS.length; i++) {
            var el = document.getElementById(SEQ_IDS[i]);
            if (el && el.value.trim() !== '') {
                var row = document.getElementById('seqRow' + (i + 1));
                if (row) row.style.display = '';
                if ((i + 1) > seqVisible) seqVisible = i + 1;
            }
        }
        updateSeqCount();
        buildSeqPreview();
    });
</script>

</asp:Content>