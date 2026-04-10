<%@ Page Title="Instructor_Modules" Language="C#" MasterPageFile="~/Master/Instructor_Master.Master" AutoEventWireup="true" CodeBehind="Instructor_Module_Manage.aspx.cs" Inherits="G5_Digital_Museum.Instructor_Module_Manage" %>

<asp:Content ID="MainMod" ContentPlaceHolderID="MainContent" runat="server">

<%-- Hidden fields --%>
<asp:HiddenField ID="hfModuleID"   runat="server" Value="0" />
<asp:HiddenField ID="hfBlockType"  runat="server" Value="text" />

<!-- ══════════════════════════════════════════════════
     PANEL 1 — MODULE LIST
══════════════════════════════════════════════════ -->
<div class="pagehead">
    <div class="pagehead-left">
        <div class="pagehead-kicker">Learning Content</div>
        <h1>Modules</h1>
        <p>Create modules and add text or image blocks for learners to study.</p>
    </div>
    <div class="pagehead-actions">
        <asp:Button ID="btnNewModule" runat="server" Text="+ New Module"
            CssClass="btn" OnClick="btnNewModule_Click" CausesValidation="false" />
    </div>
</div>

<div id="panelList">

    <asp:PlaceHolder ID="phCards" runat="server" />
    <asp:Label ID="lblNoModules" runat="server" Visible="false"
        style="display:block;text-align:center;padding:64px;color:#666;font-size:14px;">
        No modules yet. Click <strong>+ New Module</strong> to create one.
    </asp:Label>
</div>

<!-- ══════════════════════════════════════════════════
     PANEL 2 — CREATE / EDIT MODULE + CONTENT EDITOR
══════════════════════════════════════════════════ -->
<div id="panelEditor" style="display:none;">

    <!-- Module info section -->
    <div class="pagehead">
        <div class="pagehead-left">
            <div class="pagehead-kicker">Module Editor</div>
            <h1 id="editorHeading">New Module</h1>
        </div>
        <div class="pagehead-actions">
            <asp:Button ID="btnBackToList" runat="server" Text="← Back"
                CssClass="btn btn-xs" OnClick="btnBackToList_Click" CausesValidation="false" />
        </div>
    </div>

    <!-- ── Module info form ── -->
    <section class="panel" style="margin-bottom:20px;">
        <div class="panel-header">
            <div>
                <h3 class="panel-title">Module Information</h3>
                <p class="panel-subtitle">Title, description and status.</p>
            </div>
            <asp:Button ID="btnSaveModule" runat="server" Text="Save Info"
                CssClass="btn" OnClick="btnSaveModule_Click" />
        </div>

        <div class="form-grid">
            <div class="form-group form-group--full">
                <label class="form-label">Module Title <span class="req">*</span></label>
                <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control"
                    placeholder="e.g. Module 1: Introduction to the Nanjing Massacre" MaxLength="200" />
                <div style="font-size:11px;color:#555;margin-top:5px;">
                    &#9432;&nbsp;The system auto-numbers modules. Just type the subtitle after the prefix shown.
                    <strong style="color:#c4a44a;">Published modules cannot have their info edited.</strong>
                </div>
            </div>
            <div class="form-group form-group--full">
                <label class="form-label">Short Description
                    <span style="color:#666;font-weight:400;font-size:11px;">— shown on module card</span>
                </label>
                <asp:TextBox ID="txtDesc" runat="server" TextMode="MultiLine" Rows="3"
                    CssClass="form-control form-textarea"
                    placeholder="Brief overview shown on the module card..." MaxLength="500" />
            </div>
            <div class="form-group">
                <label class="form-label">Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                    <asp:ListItem Text="Draft"     Value="Draft" />
                    <asp:ListItem Text="Published" Value="Published" />
                </asp:DropDownList>
            </div>
            <%-- SortOrder is auto-assigned by system--%>
            <asp:TextBox ID="txtOrder" runat="server" style="display:none;" />
        </div>
        <asp:Label ID="lblModuleMsg" runat="server" CssClass="form-feedback" />
    </section>

    <!-- ── Content blocks list ── -->
    <section class="panel" style="margin-bottom:20px;" id="sectionBlocks"
        runat="server">
        <div class="panel-header">
            <div>
                <h3 class="panel-title">Content Blocks</h3>
                <p class="panel-subtitle">These appear in order to learners studying this module.</p>
            </div>
        </div>
        <asp:PlaceHolder ID="phBlocks" runat="server" />
        <asp:Label ID="lblNoBlocks" runat="server" Visible="false"
            style="display:block;text-align:center;padding:30px 20px;color:#555;font-size:13px;">
            No blocks yet — add the first one below.
        </asp:Label>
    </section>

    <!-- ── Add content block form ── -->
    <section class="panel">
        <div class="panel-header">
            <div>
                <h3 class="panel-title">Add Content Block</h3>
                <p class="panel-subtitle">Build up this module by adding text paragraphs and images in order.</p>
            </div>
        </div>

        <%-- Must save module first notice --%>
        <asp:Panel ID="pnlMustSave" runat="server" Visible="false"
            style="background:rgba(196,164,74,0.08);border:1px solid rgba(196,164,74,0.3);
                   padding:14px 20px;margin-bottom:20px;font-size:13px;color:#c4a44a;">
            &#9888;&nbsp; Please <strong>Save Info</strong> above first to save the module, then you can add content blocks.
        </asp:Panel>

        <!-- Block type toggle -->
        <div class="quiz-tabs" style="margin-bottom:22px;">
            <button type="button" class="quiz-tab quiz-tab--active" id="tabText"
                onclick="switchBlock('text',this)">&#128196;&nbsp;Text Paragraph</button>
            <button type="button" class="quiz-tab" id="tabImg"
                onclick="switchBlock('image',this)">&#128444;&nbsp;Image</button>
        </div>

        <!-- TEXT -->
        <div id="blockText">
            <div class="form-group">
                <label class="form-label">Content <span class="req">*</span></label>
                <asp:TextBox ID="txtBody" runat="server" TextMode="MultiLine" Rows="7"
                    CssClass="form-control form-textarea"
                    placeholder="Write the learning content here — historical facts, analysis, testimonies, sources..." />
            </div>
        </div>

        <!-- IMAGE -->
        <div id="blockImage" style="display:none;">
            <div class="exh-form-body">
                <div class="exh-form-fields">
                    <div class="form-group" style="margin-bottom:14px;">
                        <label class="form-label">Caption</label>
                        <asp:TextBox ID="txtCaption" runat="server" CssClass="form-control"
                            placeholder="e.g. John Rabe's diary entry, December 1937." MaxLength="500" />
                    </div>
                    <div class="img-src-tabs" style="margin-bottom:12px;">
                        <button type="button" class="img-src-tab img-src-tab--active"
                            onclick="switchSrc('file',this)">&#128190; Upload</button>
                        <button type="button" class="img-src-tab"
                            onclick="switchSrc('url',this)">&#127760; URL</button>
                    </div>
                    <div id="srcFile">
                        <div class="upload-zone"
                            onclick="document.getElementById('<%= fuBlock.ClientID %>').click()">
                            <div class="upload-zone__icon">&#128444;</div>
                            <div class="upload-zone__text">
                                <strong>Click to upload</strong>
                                <span>JPG or PNG, max 2 MB</span>
                            </div>
                            <asp:FileUpload ID="fuBlock" runat="server"
                                CssClass="upload-zone__input" onchange="prevFile(this)" />
                        </div>
                    </div>
                    <div id="srcUrl" style="display:none;">
                        <asp:TextBox ID="txtImgUrl" runat="server" CssClass="form-control"
                            placeholder="https://example.com/image.jpg"
                            oninput="prevUrl(this.value)" />
                    </div>
                </div>
                <div class="exh-form-preview-col">
                    <label class="form-label">Preview</label>
                    <div id="prevBox"
                         style="position:relative;height:260px;width:100%;overflow:hidden;
                                border:1px solid rgba(196,164,74,0.2);background:#1a1a1a;">
                        <div id="prevPh"
                             style="position:absolute;inset:0;display:flex;flex-direction:column;
                                    align-items:center;justify-content:center;gap:8px;
                                    color:#555;font-size:13px;">
                            <span style="font-size:32px;opacity:0.3;">&#128444;</span>
                            <span>Preview</span>
                        </div>
                        <img id="prevImg" src="" alt="" onerror="clearPrev()"
                             style="position:absolute;inset:0;width:100%;height:100%;object-fit:contain;object-position:center;display:none;" />
                    </div>
                </div>
            </div>
        </div>

        <asp:Label ID="lblBlockMsg" runat="server" CssClass="form-feedback" />
        <div class="form-actions">
            <asp:Button ID="btnAddBlock" runat="server" Text="+ Add Block"
                CssClass="btn" OnClick="btnAddBlock_Click" />
        </div>
    </section>
</div>

<script>
    // ── Panel switching  ──
    function showPanel(name) {
        document.getElementById('panelList').style.display = name === 'list' ? 'block' : 'none';
        document.getElementById('panelEditor').style.display = name === 'editor' ? 'block' : 'none';
        window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    // Auto-open editor panel if server signals it
    if ('<%= ShowEditor %>' === 'true') {
        document.addEventListener('DOMContentLoaded', function() {
            document.getElementById('editorHeading').textContent = '<%= EditorTitle %>';
            showPanel('editor');
        });
    }

    // ── Block type switch ──
    function switchBlock(type, btn) {
        document.getElementById('blockText').style.display  = type === 'text'  ? 'block' : 'none';
        document.getElementById('blockImage').style.display = type === 'image' ? 'block' : 'none';
        document.querySelectorAll('.quiz-tab').forEach(function(b) { b.classList.remove('quiz-tab--active'); });
        btn.classList.add('quiz-tab--active');
        document.getElementById('<%= hfBlockType.ClientID %>').value = type;
    }

    // ── Image source switch ──
    function switchSrc(mode, btn) {
        document.getElementById('srcFile').style.display = mode === 'file' ? 'block' : 'none';
        document.getElementById('srcUrl').style.display = mode === 'url' ? 'block' : 'none';
        document.querySelectorAll('.img-src-tab').forEach(function (b) { b.classList.remove('img-src-tab--active'); });
        btn.classList.add('img-src-tab--active');
    }

    // ── Image preview ──
    function prevFile(input) {
        if (!input.files || !input.files[0]) return;
        var r = new FileReader();
        r.onload = function (e) { showPrev(e.target.result); };
        r.readAsDataURL(input.files[0]);
    }
    function prevUrl(url) { if (url && url.trim()) showPrev(url.trim()); else clearPrev(); }
    function showPrev(src) {
        var img = document.getElementById('prevImg');
        img.onerror = clearPrev;
        img.onload = function () {
            document.getElementById('prevPh').style.display = 'none';
            img.style.cssText = 'position:absolute;inset:0;width:100%;height:100%;object-fit:contain;object-position:center;display:block;';
        };
        img.src = src;
    }
    function clearPrev() {
        document.getElementById('prevPh').style.display = 'flex';
        document.getElementById('prevImg').style.cssText = 'position:absolute;inset:0;width:100%;height:100%;object-fit:contain;object-position:center;display:none;';
    }
</script>

</asp:Content>
