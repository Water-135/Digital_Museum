<%@ Page Title="Instructor_Exhibitions" Language="C#" MasterPageFile="~/Master/Instructor_Master.Master" AutoEventWireup="true" CodeBehind="Instructor_Exhibition_Manage.aspx.cs" Inherits="G5_Digital_Museum.Instructor_Exhibition_Manage" %>

<asp:Content ID="MainExh" ContentPlaceHolderID="MainContent" runat="server">

    <div class="pagehead">
        <div class="pagehead-left">
            <div class="pagehead-kicker">Content Management</div>
            <h1>Exhibitions</h1>
            <p>Create and publish exhibition content for the Nanjing Massacre Digital Museum.</p>
        </div>
        <div class="pagehead-right">
            <button type="button" class="btn" onclick="openExhForm(0)">&#43;&nbsp;New Exhibition</button>
        </div>
    </div>

    <!-- TOOLBAR -->
    <div class="exh-toolbar">
        <div class="exh-toolbar__search">
            <span>&#128269;</span>
            <asp:TextBox ID="txtSearch" runat="server" CssClass="exh-search-input" placeholder="Search by title..." />
            <asp:Button ID="btnSearch" runat="server" Text="Search" CssClass="btn btn-xs" OnClick="btnSearch_Click" />
            <asp:Button ID="btnReset"  runat="server" Text="Reset"  CssClass="btn btn-xs" OnClick="btnReset_Click" />
        </div>
        <div class="exh-toolbar__right">
            <asp:DropDownList ID="ddlFilterCat" runat="server" CssClass="form-control exh-filter-select"
                AutoPostBack="true" OnSelectedIndexChanged="ddlFilterCat_Changed">
                <asp:ListItem Text="All Categories"                        Value="" />
                <asp:ListItem Text="Background &amp; Causes"              Value="Background &amp; Causes" />
                <asp:ListItem Text="The Massacre"                          Value="The Massacre" />
                <asp:ListItem Text="Survivor Testimonies"                  Value="Survivor Testimonies" />
                <asp:ListItem Text="International Response"                Value="International Response" />
                <asp:ListItem Text="War Crimes &amp; Trials"              Value="War Crimes &amp; Trials" />
                <asp:ListItem Text="Remembrance &amp; Legacy"             Value="Remembrance &amp; Legacy" />
                <asp:ListItem Text="Evidence &amp; Historical Documents"  Value="Evidence &amp; Historical Documents" />
            </asp:DropDownList>
            <asp:DropDownList ID="ddlFilterStatus" runat="server" CssClass="form-control exh-filter-select"
                AutoPostBack="true" OnSelectedIndexChanged="ddlFilterStatus_Changed">
                <asp:ListItem Text="All Status"  Value="" />
                <asp:ListItem Text="Published"   Value="Published" />
                <asp:ListItem Text="Draft"       Value="Draft" />
            </asp:DropDownList>
        </div>
    </div>

    <div class="exh-stats-row">
        <asp:Label ID="lblExhCount" runat="server" CssClass="exh-count-badge" />
    </div>

    <%-- Tracks whether the form panel is open across postbacks --%>
    <asp:HiddenField ID="hfPanelOpen"    runat="server" Value="0" />
    <asp:HiddenField ID="hfPanelEditing" runat="server" Value="0" />

    <!-- FORM PANEL -->
    <div class="exh-form-panel" id="exhFormPanel" style="display:none;">
        <section class="panel">
            <div class="panel-header">
                <div>
                    <h2 class="panel-title" id="formPanelTitle">New Exhibition</h2>
                    <p class="panel-subtitle">Fill in the details below and save.</p>
                </div>
                <button type="button" class="btn btn-xs" onclick="closeExhForm()">&#10005;&nbsp;Close</button>
            </div>

            <div class="exh-form-body">

                <!-- LEFT: fields -->
                <div class="exh-form-fields">
                    <div class="form-grid">

                        <div class="form-group form-group--full">
                            <label class="form-label">Title <span class="req">*</span></label>
                            <asp:TextBox ID="txtTitle" runat="server" CssClass="form-control"
                                placeholder="e.g. The Fall of Nanjing" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">Category <span class="req">*</span></label>
                            <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control">
                                <asp:ListItem Text="Background &amp; Causes"             Value="Background &amp; Causes" />
                                <asp:ListItem Text="The Massacre"                         Value="The Massacre" />
                                <asp:ListItem Text="Survivor Testimonies"                 Value="Survivor Testimonies" />
                                <asp:ListItem Text="International Response"               Value="International Response" />
                                <asp:ListItem Text="War Crimes &amp; Trials"             Value="War Crimes &amp; Trials" />
                                <asp:ListItem Text="Remembrance &amp; Legacy"            Value="Remembrance &amp; Legacy" />
                                <asp:ListItem Text="Evidence &amp; Historical Documents" Value="Evidence &amp; Historical Documents" />
                            </asp:DropDownList>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Status</label>
                            <asp:DropDownList ID="ddlStatus" runat="server" CssClass="form-control">
                                <asp:ListItem Text="Draft"     Value="Draft" />
                                <asp:ListItem Text="Published" Value="Published" />
                            </asp:DropDownList>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Incident Date</label>
                            <asp:TextBox ID="txtIncidentDate" runat="server" CssClass="form-control"
                                TextMode="Date" ToolTip="The historical date this event occurred" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">Timeline Label</label>
                            <asp:TextBox ID="txtTimeline" runat="server" CssClass="form-control"
                                placeholder="e.g. December 13, 1937" />
                        </div>

                        <div class="form-group">
                            <label class="form-label">Featured</label>
                            <asp:DropDownList ID="ddlFeatured" runat="server" CssClass="form-control">
                                <asp:ListItem Text="No"  Value="0" />
                                <asp:ListItem Text="Yes" Value="1" />
                            </asp:DropDownList>
                        </div>

                        <div class="form-group form-group--full">
                            <label class="form-label">Detailed Historical Narrative <span class="req">*</span></label>
                            <asp:TextBox ID="txtDesc" runat="server" TextMode="MultiLine" Rows="7"
                                CssClass="form-control form-textarea"
                                placeholder="Provide a detailed, factual historical narrative for this exhibition. Include context, key figures, and significance." />
                        </div>

                    </div>
                </div>

                <!-- RIGHT: image -->
                <div class="exh-form-preview-col">
                    <div class="form-group">
                        <label class="form-label">Exhibition Image</label>

                        <div class="img-src-tabs">
                            <button type="button" class="img-src-tab img-src-tab--active"
                                onclick="switchImgSrc('upload',this)">&#128190; Upload File</button>
                            <button type="button" class="img-src-tab"
                                onclick="switchImgSrc('url',this)">&#127760; Image URL</button>
                        </div>

                        <div id="imgSrcUpload" class="img-src-panel">
                            <div class="upload-zone"
                                onclick="document.getElementById('<%= fuCover.ClientID %>').click()">
                                <div class="upload-zone__icon">&#128444;</div>
                                <div class="upload-zone__text">
                                    <strong>Click to choose file</strong>
                                    <span>From your project's Image folder — JPG or PNG</span>
                                </div>
                                <asp:FileUpload ID="fuCover" runat="server" CssClass="upload-zone__input"
                                    onchange="previewFromFile(this)" />
                            </div>
                        </div>

                        <div id="imgSrcUrl" class="img-src-panel" style="display:none;">
                            <asp:TextBox ID="txtImageUrl" runat="server" CssClass="form-control"
                                placeholder="https://example.com/image.jpg"
                                onkeyup="previewFromUrl(this.value)"
                                onpaste="setTimeout(function(){previewFromUrl(document.getElementById('<%= txtImageUrl.ClientID %>').value)},50)" />
                            <small style="color:#888;font-size:11px;display:block;margin-top:5px;">
                                Paste a direct image URL — preview updates live
                            </small>
                        </div>
                    </div>

                    <!-- Live preview -->
                    <div id="previewBox"
                         style="position:relative;height:260px;width:100%;overflow:hidden;
                                border:1px solid rgba(196,164,74,0.2);background:#1a1a1a;">
                        <div id="previewPlaceholder"
                             style="position:absolute;inset:0;display:flex;flex-direction:column;
                                    align-items:center;justify-content:center;gap:8px;
                                    color:#555;font-size:13px;">
                            <span style="font-size:32px;opacity:0.3;">&#128444;</span>
                            <span>Preview will appear here</span>
                        </div>
                        <asp:Image ID="imgPreview" runat="server"
                            style="position:absolute;inset:0;width:100%;height:100%;object-fit:contain;object-position:center;display:block;"
                            Visible="false" AlternateText="Cover preview" />
                        <img id="jsPreviewImg" src="" alt="Preview"
                             style="position:absolute;inset:0;width:100%;height:100%;object-fit:contain;object-position:center;display:none;" />
                    </div>
                </div>
            </div>

            <asp:Label ID="lblMsg" runat="server" CssClass="form-feedback" />
            <div class="form-actions">
                <asp:Button ID="btnClear" runat="server" Text="Clear Form"      CssClass="btn btn-xs" OnClick="btnClear_Click" />
                <asp:Button ID="btnSave"  runat="server" Text="Save Exhibition" CssClass="btn"        OnClick="btnSave_Click" />
            </div>
        </section>
    </div>

    <!-- ═══════════════════════════════════════════════════════
         CATEGORY-GROUPED GALLERY
    ═══════════════════════════════════════════════════════ -->
    <asp:PlaceHolder ID="phGallery" runat="server" />

    <asp:Label ID="lblNoResults" runat="server" Visible="false"
        style="display:block;text-align:center;padding:60px 20px;color:#666;font-size:14px;letter-spacing:1px;">
        No exhibitions found.
    </asp:Label>

    <script>
        // Restore panel state after every postback 
        (function () {
            var open = document.getElementById('<%= hfPanelOpen.ClientID %>').value;
            var editing = document.getElementById('<%= hfPanelEditing.ClientID %>').value;
            if (open === '1') {
                var panel = document.getElementById('exhFormPanel');
                document.getElementById('formPanelTitle').textContent =
                    editing === '1' ? 'Edit Exhibition' : 'New Exhibition';
                panel.style.display = 'block';
            }
        })();

        function openExhForm(editing) {
            document.getElementById('<%= hfPanelOpen.ClientID %>').value    = '1';
            document.getElementById('<%= hfPanelEditing.ClientID %>').value = editing ? '1' : '0';
            var panel = document.getElementById("exhFormPanel");
            document.getElementById("formPanelTitle").textContent =
                editing ? "Edit Exhibition" : "New Exhibition";
            panel.style.display = "block";
            panel.scrollIntoView({ behavior: "smooth" });
        }
        function closeExhForm() {
            document.getElementById('<%= hfPanelOpen.ClientID %>').value    = '0';
            document.getElementById('<%= hfPanelEditing.ClientID %>').value = '0';
            document.getElementById("exhFormPanel").style.display = "none";
        }
        function switchImgSrc(mode, btn) {
            document.getElementById("imgSrcUpload").style.display = mode === "upload" ? "block" : "none";
            document.getElementById("imgSrcUrl").style.display = mode === "url" ? "block" : "none";
            document.querySelectorAll(".img-src-tab").forEach(function (b) {
                b.classList.remove("img-src-tab--active");
            });
            btn.classList.add("img-src-tab--active");
        }
        function previewFromFile(input) {
            if (!input.files || !input.files[0]) return;
            var reader = new FileReader();
            reader.onload = function (e) { showPreview(e.target.result); };
            reader.readAsDataURL(input.files[0]);
        }
        function previewFromUrl(url) {
            if (!url || url.trim() === "") { clearPreview(); return; }
            showPreview(url.trim());
        }
        function showPreview(src) {
            var img = document.getElementById("jsPreviewImg");
            img.onerror = clearPreview;
            img.onload = function () {
                document.getElementById("previewPlaceholder").style.display = "none";
                img.style.cssText = "position:absolute;inset:0;width:100%;height:100%;object-fit:contain;object-position:center;display:block;";
            };
            img.src = src;
        }
        function clearPreview() {
            document.getElementById("previewPlaceholder").style.display = "flex";
            document.getElementById("jsPreviewImg").style.cssText = "position:absolute;inset:0;width:100%;height:100%;object-fit:contain;object-position:center;display:none;";
        }
        function toggleCatGroup(id) {
            var grid = document.getElementById("catGrid_" + id);
            var icon = document.getElementById("catIcon_" + id);
            if (!grid) return;
            var open = grid.style.display !== "none";
            grid.style.display = open ? "none" : "grid";
            if (icon) icon.textContent = open ? "▶" : "▼";
        }
    </script>

</asp:Content>
