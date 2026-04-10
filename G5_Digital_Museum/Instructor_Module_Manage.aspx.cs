using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;


namespace G5_Digital_Museum
{
    public partial class Instructor_Module_Manage : System.Web.UI.Page
    {
        private string ConnStr =>
            ConfigurationManager.ConnectionStrings["MuseumDB"].ConnectionString;

        private int EditingID
        {
            get => ViewState["EditModID"] is int i ? i : 0;
            set => ViewState["EditModID"] = value;
        }

        public string ShowEditor
        {
            get => ViewState["ShowEditor"]?.ToString() ?? "false";
            private set => ViewState["ShowEditor"] = value;
        }
        public string EditorTitle
        {
            get => ViewState["EditorTitle"]?.ToString() ?? "";
            private set => ViewState["EditorTitle"] = value;
        }

        // Which content block is currently open for inline editing (0 = none)
        private int EditBlockID
        {
            get => ViewState["EditBlockID"] is int i ? i : 0;
            set => ViewState["EditBlockID"] = value;
        }

        // =======================================================
        //  PAGE LOAD
        // =======================================================
        protected void Page_Load(object sender, EventArgs e)
        {
            LoadModuleCards();

            if (EditingID > 0)
            {
                LoadBlocks(EditingID);
            }
        }

        // =======================================================
        //  BUTTON: Add New Module
        // =======================================================
        protected void btnNewModule_Click(object sender, EventArgs e)
        {
            EditingID = 0;
            ClearModuleForm();
            hfModuleID.Value = "0";
            // Auto-assign next module number
            int nextNum = GetNextModuleNumber();
            txtOrder.Text = nextNum.ToString();
            // Pre-fill title prefix so instructor just types the subtitle
            txtTitle.Text = "Module " + nextNum + ": ";
            pnlMustSave.Visible = true;
            lblNoBlocks.Visible = true;
            phBlocks.Controls.Clear();
            LoadModuleCards();
            OpenEditor("New Module");
        }

        // =======================================================
        //  BUTTON: Edit Module 
        // =======================================================
        protected void EditModule_Click(object sender, CommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            // Guard: Published modules cannot have info edited
            using (SqlConnection chk = new SqlConnection(ConnStr))
            using (SqlCommand chkCmd = new SqlCommand(
                "SELECT Status FROM Modules WHERE ModuleID=@ID", chk))
            {
                chkCmd.Parameters.AddWithValue("@ID", id);
                chk.Open();
                string st = chkCmd.ExecuteScalar()?.ToString() ?? "";
                if (st == "Published")
                {
                    // Redirect to content editor instead
                    ContentEdit_Click(sender, e);
                    return;
                }
            }

            EditingID = id;
            hfModuleID.Value = id.ToString();

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT * FROM Modules WHERE ModuleID=@ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (!r.Read()) return;
                    txtTitle.Text = r["Title"].ToString();
                    txtDesc.Text = r["Description"].ToString();
                    txtOrder.Text = r["SortOrder"].ToString();
                    SetDDL(ddlStatus, r["Status"].ToString());
                    EditorTitle = r["Title"].ToString();
                }
            }

            pnlMustSave.Visible = false;
            LoadBlocks(id);
            LoadModuleCards();
            OpenEditor(EditorTitle);
        }

        // =======================================================
        //  BUTTON: Open Content Editor only
        // =======================================================
        protected void ContentEdit_Click(object sender, CommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);

            // Block: Published modules are fully read-only — no editor
            using (SqlConnection chk = new SqlConnection(ConnStr))
            using (SqlCommand chkCmd = new SqlCommand(
                "SELECT Status FROM Modules WHERE ModuleID=@ID", chk))
            {
                chkCmd.Parameters.AddWithValue("@ID", id);
                chk.Open();
                if (chkCmd.ExecuteScalar()?.ToString() == "Published")
                {
                    LoadModuleCards();
                    return;  // stay on list, do not open editor
                }
            }

            EditingID = id;
            hfModuleID.Value = id.ToString();

            string title = GetModuleTitle(id);
            EditorTitle = title;

            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT * FROM Modules WHERE ModuleID=@ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                using (SqlDataReader r = cmd.ExecuteReader())
                {
                    if (r.Read())
                    {
                        txtTitle.Text = r["Title"].ToString();
                        txtDesc.Text = r["Description"].ToString();
                        txtOrder.Text = r["SortOrder"].ToString();
                        SetDDL(ddlStatus, r["Status"].ToString());
                    }
                }
            }

            pnlMustSave.Visible = false;
            LoadBlocks(id);
            LoadModuleCards();
            OpenEditor(title);
        }

        // =======================================================
        //  BUTTON: Delete Module 
        // =======================================================
        protected void DeleteModule_Click(object sender, CommandEventArgs e)
        {
            int id = Convert.ToInt32(e.CommandArgument);
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "UPDATE Modules SET IsActive=0 WHERE ModuleID=@ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            LoadModuleCards();
        }

        // =======================================================
        //  BUTTON: Save Info
        // =======================================================
        protected void btnSaveModule_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtTitle.Text))
            { ShowMsg("Module title is required.", false); OpenEditor(EditorTitle); return; }

            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                {
                    conn.Open();

                    if (EditingID == 0)
                    {
                        // ── INSERT: auto-assign next sequential SortOrder ──
                        int autoOrder;
                        using (SqlCommand getNext = new SqlCommand(
                            "SELECT ISNULL(MAX(SortOrder),0)+1 FROM Modules WHERE IsActive=1", conn))
                        {
                            autoOrder = Convert.ToInt32(getNext.ExecuteScalar());
                        }

                        // Enforce "Module N: " prefix
                        string rawTitle = txtTitle.Text.Trim();
                        string expectedPrefix = "Module " + autoOrder + ": ";
                        if (!rawTitle.StartsWith("Module "))
                            rawTitle = expectedPrefix + rawTitle;

                        int newId;
                        using (SqlCommand cmd = new SqlCommand(@"
                            INSERT INTO Modules
                                (Title,Description,Status,SortOrder,IsActive,CreatedByID,CreatedAt)
                            OUTPUT INSERTED.ModuleID
                            VALUES
                                (@Title,@Desc,@Status,@Ord,1,@By,GETDATE())", conn))
                        {
                            cmd.Parameters.AddWithValue("@Title", rawTitle);
                            cmd.Parameters.AddWithValue("@Desc", txtDesc.Text.Trim());
                            cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
                            cmd.Parameters.AddWithValue("@Ord", autoOrder);
                            cmd.Parameters.AddWithValue("@By",
                                Session["UserID"] ?? (object)DBNull.Value);
                            newId = Convert.ToInt32(cmd.ExecuteScalar());
                        }
                        EditingID = newId;
                        hfModuleID.Value = newId.ToString();
                        ShowMsg("Module created. Now add content blocks below.", true);
                    }
                    else
                    {

                        using (SqlCommand cmd = new SqlCommand(@"
                            UPDATE Modules
                            SET Title=@Title, Description=@Desc,
                                Status=@Status, UpdatedAt=GETDATE()
                            WHERE ModuleID=@ID AND Status='Draft'", conn))
                        {
                            cmd.Parameters.AddWithValue("@Title", txtTitle.Text.Trim());
                            cmd.Parameters.AddWithValue("@Desc", txtDesc.Text.Trim());
                            cmd.Parameters.AddWithValue("@Status", ddlStatus.SelectedValue);
                            cmd.Parameters.AddWithValue("@ID", EditingID);
                            int rows = cmd.ExecuteNonQuery();
                            if (rows == 0)
                                ShowMsg("Cannot edit — this module is already Published.", false);
                            else
                                ShowMsg("Module info updated.", true);
                        }
                    }
                }

                pnlMustSave.Visible = false;
                EditorTitle = txtTitle.Text.Trim();
                LoadBlocks(EditingID);
                LoadModuleCards();
                OpenEditor(EditorTitle);
            }
            catch (Exception ex)
            {
                ShowMsg("Error: " + ex.Message, false);
                OpenEditor(EditorTitle);
            }
        }


        // =======================================================
        //  BUTTON: + Add Block
        // =======================================================
        protected void btnAddBlock_Click(object sender, EventArgs e)
        {
            int mid = EditingID;
            if (mid == 0)
            {
                ShowBlockMsg("Please fill in the module title and click Save Info first.", false);
                OpenEditor(EditorTitle);
                return;
            }

            string blockType = hfBlockType.Value == "image" ? "image" : "text";

            if (blockType == "text")
            {
                if (string.IsNullOrWhiteSpace(txtBody.Text))
                { ShowBlockMsg("Please enter some content text.", false); OpenEditor(EditorTitle); return; }

                InsertBlock(mid, "text", txtBody.Text.Trim(), null, null, null);
                txtBody.Text = "";
                ShowBlockMsg("Text block added.", true);
            }
            else
            {
                string imgUrl = null, imgSrc = "url";

                if (fuBlock.HasFile)
                {
                    imgUrl = SaveImage(out string err);
                    if (imgUrl == null) { ShowBlockMsg(err, false); OpenEditor(EditorTitle); return; }
                    imgSrc = "file";
                }
                else if (!string.IsNullOrWhiteSpace(txtImgUrl.Text))
                {
                    imgUrl = txtImgUrl.Text.Trim();
                    imgSrc = "url";
                }

                if (imgUrl == null)
                { ShowBlockMsg("Upload a file or enter an image URL.", false); OpenEditor(EditorTitle); return; }

                InsertBlock(mid, "image", null, imgUrl, imgSrc, txtCaption.Text.Trim());
                txtImgUrl.Text = txtCaption.Text = "";
                ShowBlockMsg("Image block added.", true);
            }

            EditorTitle = GetModuleTitle(mid);
            LoadBlocks(mid);
            LoadModuleCards();
            OpenEditor(EditorTitle);
        }

        // =======================================================
        //  BUTTON: Remove Block 
        // =======================================================
        protected void RemoveBlock_Click(object sender, CommandEventArgs e)
        {
            int blockId = Convert.ToInt32(e.CommandArgument);
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "DELETE FROM ModuleContents WHERE ContentID=@ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", blockId);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
            int mid = EditingID;
            EditorTitle = GetModuleTitle(mid);
            LoadBlocks(mid);
            LoadModuleCards();
            OpenEditor(EditorTitle);
        }

        // =======================================================
        //  BUTTON: Back to List
        // =======================================================
        protected void btnBackToList_Click(object sender, EventArgs e)
        {
            ClearModuleForm();
            EditingID = 0;
            hfModuleID.Value = "0";
            ShowEditor = "false";
            EditorTitle = "";
        }

        // =======================================================
        //  LOAD MODULE CARDS
        // =======================================================
        private void LoadModuleCards()
        {
            string sql = @"
                SELECT m.ModuleID, m.Title,
                       ISNULL(m.Description,'') AS Description,
                       m.Status, m.SortOrder,
                       CONVERT(VARCHAR(10), m.CreatedAt, 103) AS CreatedDate,
                       (SELECT COUNT(*) FROM ModuleContents mc
                        WHERE mc.ModuleID = m.ModuleID) AS BlockCount
                FROM   Modules m
                WHERE  m.IsActive = 1
                ORDER  BY m.SortOrder ASC, m.CreatedAt DESC";

            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(sql, conn))
                using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                { conn.Open(); da.Fill(dt); }
            }
            catch (Exception ex)
            {
                phCards.Controls.Add(new LiteralControl(
                    "<p style='color:#c94c4c;padding:20px;'>Error: " +
                    HttpUtility.HtmlEncode(ex.Message) + "</p>"));
                return;
            }

            phCards.Controls.Clear();
            lblNoModules.Visible = dt.Rows.Count == 0;
            if (dt.Rows.Count == 0) return;

            BuildCardControls(dt);
        }

        private void BuildCardControls(DataTable dt)
        {

            var outerDiv = new Panel();
            outerDiv.Style.Add("display", "flex");
            outerDiv.Style.Add("flex-direction", "column");
            outerDiv.Style.Add("gap", "16px");

            foreach (DataRow r in dt.Rows)
            {
                int mid = Convert.ToInt32(r["ModuleID"]);
                string title = HttpUtility.HtmlEncode(r["Title"].ToString());
                string desc = HttpUtility.HtmlEncode(r["Description"].ToString());
                string status = r["Status"].ToString();
                bool isPub = status == "Published";
                string stCls = isPub ? "chip--live" : "chip--draft";
                string date = r["CreatedDate"].ToString();
                int blocks = Convert.ToInt32(r["BlockCount"]);
                string order = r["SortOrder"].ToString();

                var card = new Panel();
                card.Style.Add("background", "#1a1a1a");
                card.Style.Add("border-left", "3px solid #c4a44a");
                card.Style.Add("border-top", "1px solid rgba(196,164,74,0.25)");
                card.Style.Add("border-right", "1px solid rgba(196,164,74,0.25)");
                card.Style.Add("border-bottom", "1px solid rgba(196,164,74,0.25)");
                card.Style.Add("overflow", "hidden");

                var header = new StringBuilder();
                header.Append(
                    "<div style='display:flex;align-items:center;justify-content:space-between;" +
                               "flex-wrap:wrap;gap:10px;padding:14px 20px;" +
                               "background:rgba(196,164,74,0.07);" +
                               "border-bottom:1px solid rgba(196,164,74,0.18);'>" +


                        "<div style='display:flex;align-items:center;gap:10px;'>" +
                            "<span style='font-size:1rem;color:rgba(196,164,74,0.7);'>&#128196;</span>" +
                            "<h3 style='font-family:Playfair Display,Georgia,serif;" +
                                       "font-size:1.05rem;font-weight:600;" +
                                       "color:#f5f2ed;margin:0;'>" + title + "</h3>" +
                        "</div>" +


                        "<div style='display:flex;align-items:center;flex-wrap:wrap;gap:7px;'>" +
                            "<span class='chip " + stCls + "'>" + status + "</span>" +
                            "<span class='chip'>&#35;&nbsp;" + order + "</span>" +
                            "<span class='chip'>" + blocks + "&nbsp;block" + (blocks == 1 ? "" : "s") + "</span>" +
                            "<span style='font-size:11px;color:#666;'>&#128197;&nbsp;" + date + "</span>" +
                        "</div>" +
                    "</div>");

                // ── Description ──
                if (!string.IsNullOrEmpty(desc))
                    header.Append(
                        "<p style='font-size:13px;color:#888;line-height:1.65;" +
                                  "padding:10px 20px 0;margin:0;'>" + desc + "</p>");

                card.Controls.Add(new LiteralControl(header.ToString()));

                // ── Block preview ──
                var previewSb = new StringBuilder();
                AppendBlockPreview(previewSb, mid);
                card.Controls.Add(new LiteralControl(previewSb.ToString()));

                // ── Action buttons row ──
                // DRAFT:     Edit Content Blocks 
                // PUBLISHED: Delete only 
                card.Controls.Add(new LiteralControl(
                    "<div style='display:flex;align-items:center;gap:8px;flex-wrap:wrap;" +
                               "padding:12px 20px;" +
                               "background:rgba(0,0,0,0.25);" +
                               "border-top:1px solid rgba(255,255,255,0.05);'>"));

                if (!isPub)
                {
                    // DRAFT — all edit buttons available
                    var btnContent = new LinkButton();
                    btnContent.ID = "btnContent_" + mid;
                    btnContent.Text = "&#128196;&nbsp;Edit Content Blocks";
                    btnContent.CssClass = "btn btn-xs";
                    btnContent.CommandArgument = mid.ToString();
                    btnContent.Command += ContentEdit_Click;
                    card.Controls.Add(btnContent);

                    var btnEdit = new LinkButton();
                    btnEdit.ID = "btnEdit_" + mid;
                    btnEdit.Text = "&#9998;&nbsp;Edit Info";
                    btnEdit.CssClass = "btn btn-xs";
                    btnEdit.CommandArgument = mid.ToString();
                    btnEdit.Command += EditModule_Click;
                    card.Controls.Add(btnEdit);
                }
                else
                {
                    // PUBLISHED — show locked notice, no edit buttons
                    card.Controls.Add(new LiteralControl(
                        "<span style='font-size:10px;color:#555;letter-spacing:1.5px;" +
                                     "font-weight:700;text-transform:uppercase;" +
                                     "padding:8px 10px;border:1px solid rgba(255,255,255,0.07);" +
                                     "background:rgba(255,255,255,0.02);'>" +
                                     "&#128274;&nbsp;Published — Read Only</span>"));
                }

                // Delete always available
                var btnDel = new LinkButton();
                btnDel.ID = "btnDel_" + mid;
                btnDel.Text = "&#128465;&nbsp;Delete";
                btnDel.CssClass = "btn btn-xs btn-danger";
                btnDel.CommandArgument = mid.ToString();
                btnDel.OnClientClick = "return confirm('Delete this module and all its content?');";
                btnDel.Command += DeleteModule_Click;
                card.Controls.Add(btnDel);

                card.Controls.Add(new LiteralControl("</div>"));
                outerDiv.Controls.Add(card);
            }

            phCards.Controls.Add(outerDiv);
        }

        // =======================================================
        //  LOAD CONTENT BLOCKS into phBlocks
        // =======================================================
        private void LoadBlocks(int moduleId)
        {
            string sql = @"
                SELECT ContentID, ContentType, Body, ImageUrl, Caption, SortOrder
                FROM   ModuleContents
                WHERE  ModuleID = @M
                ORDER  BY SortOrder ASC, CreatedAt ASC";

            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(sql, conn))
            using (SqlDataAdapter da = new SqlDataAdapter(cmd))
            {
                cmd.Parameters.AddWithValue("@M", moduleId);
                conn.Open();
                da.Fill(dt);
            }

            phBlocks.Controls.Clear();
            lblNoBlocks.Visible = dt.Rows.Count == 0;
            if (dt.Rows.Count == 0) return;

            int total = dt.Rows.Count;

            var wrapper = new Panel();
            wrapper.Style.Add("display", "flex");
            wrapper.Style.Add("flex-direction", "column");
            wrapper.Style.Add("gap", "12px");

            int num = 1;
            foreach (DataRow r in dt.Rows)
            {
                int cid = Convert.ToInt32(r["ContentID"]);
                string type = r["ContentType"].ToString();
                string body = r["Body"].ToString();
                string imgUrl = r["ImageUrl"].ToString();
                string captionR = r["Caption"].ToString();
                string captionE = HttpUtility.HtmlEncode(captionR);
                string typeLbl = type == "image" ? "&#128444; Image" : "&#128196; Text";
                string typeCls = type == "image" ? "chip--live" : "chip--draft";

                bool isFirst = (num == 1);
                bool isLast = (num == total);
                bool isEditing = (EditBlockID == cid);

                var block = new Panel();
                block.CssClass = "moodle-section" + (isEditing ? " moodle-section--editing" : "");

                // ── Header: number · type · reorder · edit · remove ──
                block.Controls.Add(new LiteralControl($@"
                <div class='moodle-section__header'>
                    <div style='display:flex;align-items:center;gap:10px;'>
                        <span class='moodle-section__num'>{num}</span>
                        <span class='chip {typeCls}'>{typeLbl}</span>
                        {(isEditing ? "<span style='font-size:11px;color:#c4a44a;font-weight:600;'>✏ Editing</span>" : "")}
                    </div>
                    <div style='display:flex;align-items:center;gap:6px;'>"));

                // ▲ Up
                if (!isFirst && !isEditing)
                {
                    var btnUp = new LinkButton();
                    btnUp.ID = "btnUp_" + cid;
                    btnUp.Text = "&#9650; Up";
                    btnUp.CssClass = "btn btn-xs";
                    btnUp.CommandArgument = cid + ":up";
                    btnUp.Command += MoveBlock_Click;
                    block.Controls.Add(btnUp);
                }
                else if (!isEditing)
                {
                    block.Controls.Add(new LiteralControl(
                        "<button type='button' class='btn btn-xs' disabled " +
                        "style='opacity:0.3;cursor:default;'>&#9650; Up</button>"));
                }

                // ▼ Down
                if (!isLast && !isEditing)
                {
                    var btnDown = new LinkButton();
                    btnDown.ID = "btnDown_" + cid;
                    btnDown.Text = "&#9660; Down";
                    btnDown.CssClass = "btn btn-xs";
                    btnDown.CommandArgument = cid + ":down";
                    btnDown.Command += MoveBlock_Click;
                    block.Controls.Add(btnDown);
                }
                else if (!isEditing)
                {
                    block.Controls.Add(new LiteralControl(
                        "<button type='button' class='btn btn-xs' disabled " +
                        "style='opacity:0.3;cursor:default;'>&#9660; Down</button>"));
                }

                // ✏ Edit  
                if (!isEditing)
                {
                    var btnEdit = new LinkButton();
                    btnEdit.ID = "btnEditBlk_" + cid;
                    btnEdit.Text = "&#9998; Edit";
                    btnEdit.CssClass = "btn btn-xs";
                    btnEdit.CommandArgument = cid.ToString();
                    btnEdit.Command += EditBlock_Click;
                    block.Controls.Add(btnEdit);
                }

                // 🗑 Remove 
                if (!isEditing)
                {
                    var btnRemove = new LinkButton();
                    btnRemove.ID = "btnRemove_" + cid;
                    btnRemove.Text = "&#128465;&nbsp;Remove";
                    btnRemove.CssClass = "btn btn-xs btn-danger";
                    btnRemove.CommandArgument = cid.ToString();
                    btnRemove.OnClientClick = "return confirm('Remove this block?');";
                    btnRemove.Command += RemoveBlock_Click;
                    block.Controls.Add(btnRemove);
                }

                block.Controls.Add(new LiteralControl("</div></div>"));

                // ── Body: display mode or inline edit form ──────────
                if (!isEditing)
                {
                    // ── READ-ONLY DISPLAY ──
                    if (type == "text")
                    {
                        block.Controls.Add(new LiteralControl(
                            $"<div class='moodle-section__body'>" +
                            $"<p class='moodle-text-block'>{HttpUtility.HtmlEncode(body)}</p>" +
                            $"</div>"));
                    }
                    else
                    {
                        var imgHtml = new StringBuilder();
                        imgHtml.Append("<div class='moodle-section__body'>");
                        if (!string.IsNullOrEmpty(imgUrl))
                        {
                            // Fixed-height image box — same size for every image regardless of aspect ratio
                            imgHtml.Append(
                                "<div style='position:relative;height:320px;width:100%;overflow:hidden;" +
                                           "background:#111;margin-bottom:8px;'>" +
                                    "<img src='" + HttpUtility.HtmlAttributeEncode(imgUrl) + "'" +
                                         " alt='" + captionE + "'" +
                                         " style='position:absolute;inset:0;width:100%;height:100%;" +
                                                 "object-fit:contain;object-position:center;display:block;'" +
                                         " onerror=\"this.parentElement.style.display='none'\" />" +
                                "</div>");
                        }
                        if (!string.IsNullOrEmpty(captionR))
                            imgHtml.Append($"<p class='moodle-caption'>{captionE}</p>");
                        imgHtml.Append("</div>");
                        block.Controls.Add(new LiteralControl(imgHtml.ToString()));
                    }
                }
                else
                {
                    // ── INLINE EDIT FORM ──
                    // Uses stable-ID ASP.NET controls so postback works first click.
                    block.Controls.Add(new LiteralControl(
                        "<div class='moodle-section__body' style='padding-top:4px;'>"));

                    if (type == "text")
                    {
                        // Editable textarea pre-filled with current body
                        var txtEdit = new TextBox();
                        txtEdit.ID = "txtEditBody_" + cid;
                        txtEdit.TextMode = TextBoxMode.MultiLine;
                        txtEdit.Rows = 7;
                        txtEdit.CssClass = "form-control form-textarea";
                        txtEdit.Text = body;
                        txtEdit.Style.Add("margin-bottom", "10px");
                        block.Controls.Add(txtEdit);
                    }
                    else
                    {
                        // Image URL field
                        block.Controls.Add(new LiteralControl(
                            "<label class='form-label' style='margin-bottom:4px;'>Image URL</label>"));
                        var txtEditUrl = new TextBox();
                        txtEditUrl.ID = "txtEditUrl_" + cid;
                        txtEditUrl.CssClass = "form-control";
                        txtEditUrl.Text = imgUrl;
                        txtEditUrl.Style.Add("margin-bottom", "10px");
                        block.Controls.Add(txtEditUrl);

                        // Live preview when URL changes
                        // Concatenation (not interpolation) avoids quote-escape issues in C#
                        string eprevDisplay = string.IsNullOrEmpty(imgUrl) ? "none" : "block";
                        string eprevSrc = HttpUtility.HtmlAttributeEncode(imgUrl);
                        block.Controls.Add(new LiteralControl(
                            "<div id='eprevBox_" + cid + "' " +
                            "style='position:relative;height:220px;width:100%;overflow:hidden;" +
                                   "background:#111;margin-bottom:10px;border:1px solid rgba(196,164,74,0.2);" +
                                   "display:" + eprevDisplay + ";'>" +
                                "<img id='eprev_" + cid + "' src='" + eprevSrc + "' " +
                                "alt='preview' " +
                                "style='position:absolute;inset:0;width:100%;height:100%;" +
                                       "object-fit:contain;object-position:center;display:block;' " +
                                "onerror='this.parentElement.style.display=\"none\"' />" +
                            "</div>" +
                            "<script>" +
                            "(function(){" +
                            "var inp=document.getElementById('txtEditUrl_" + cid + "');" +
                            "if(inp){inp.addEventListener('input',function(){" +
                            "var box=document.getElementById('eprevBox_" + cid + "');" +
                            "var i=document.getElementById('eprev_" + cid + "');" +
                            "if(!i)return;" +
                            "i.src=this.value;" +
                            "box.style.display=this.value?'block':'none';});}" +
                            "})();" +
                            "</script>"));

                        // Caption field
                        block.Controls.Add(new LiteralControl(
                            "<label class='form-label' style='margin-bottom:4px;'>Caption</label>"));
                        var txtEditCap = new TextBox();
                        txtEditCap.ID = "txtEditCap_" + cid;
                        txtEditCap.CssClass = "form-control";
                        txtEditCap.Text = captionR;
                        txtEditCap.Style.Add("margin-bottom", "10px");
                        block.Controls.Add(txtEditCap);
                    }

                    // Save / Cancel buttons
                    block.Controls.Add(new LiteralControl(
                        "<div style='display:flex;gap:8px;margin-top:4px;'>"));

                    var btnSaveBlk = new LinkButton();
                    btnSaveBlk.ID = "btnSaveBlk_" + cid;
                    btnSaveBlk.Text = "&#10003;&nbsp;Save Block";
                    btnSaveBlk.CssClass = "btn";
                    btnSaveBlk.CommandArgument = cid + ":" + type;
                    btnSaveBlk.Command += UpdateBlock_Click;
                    block.Controls.Add(btnSaveBlk);

                    var btnCancelBlk = new LinkButton();
                    btnCancelBlk.ID = "btnCancelBlk_" + cid;
                    btnCancelBlk.Text = "Cancel";
                    btnCancelBlk.CssClass = "btn btn-xs";
                    btnCancelBlk.CommandArgument = cid.ToString();
                    btnCancelBlk.CausesValidation = false;
                    btnCancelBlk.Command += CancelEdit_Click;
                    block.Controls.Add(btnCancelBlk);

                    block.Controls.Add(new LiteralControl("</div></div>"));
                }

                wrapper.Controls.Add(block);
                num++;
            }

            phBlocks.Controls.Add(wrapper);
        }

        // =======================================================
        //  BUTTON: Edit Block 
        // =======================================================
        protected void EditBlock_Click(object sender, CommandEventArgs e)
        {
            EditBlockID = Convert.ToInt32(e.CommandArgument);
            int mid = EditingID;
            EditorTitle = GetModuleTitle(mid);
            LoadBlocks(mid);
            LoadModuleCards();
            OpenEditor(EditorTitle);
        }

        // =======================================================
        //  BUTTON: Cancel Edit 
        // =======================================================
        protected void CancelEdit_Click(object sender, CommandEventArgs e)
        {
            EditBlockID = 0;
            int mid = EditingID;
            EditorTitle = GetModuleTitle(mid);
            LoadBlocks(mid);
            LoadModuleCards();
            OpenEditor(EditorTitle);
        }

        // =======================================================
        //  BUTTON: Save Block — UPDATE ModuleContents row
        // =======================================================
        protected void UpdateBlock_Click(object sender, CommandEventArgs e)
        {
            string[] parts = e.CommandArgument.ToString().Split(':');
            int cid = Convert.ToInt32(parts[0]);
            string type = parts[1]; // "text" or "image"

            // Find the matching edit controls inside phBlocks
            if (type == "text")
            {
                var txt = phBlocks.FindControl("txtEditBody_" + cid) as TextBox;
                if (txt == null) { EditBlockID = 0; LoadBlocks(EditingID); OpenEditor(EditorTitle); return; }

                string newBody = txt.Text.Trim();
                if (string.IsNullOrWhiteSpace(newBody))
                {
                    // Re-open edit mode with validation message — reload will show it
                    EditBlockID = cid;
                    LoadBlocks(EditingID);
                    OpenEditor(EditorTitle);
                    return;
                }

                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE ModuleContents SET Body=@B WHERE ContentID=@ID", conn))
                {
                    cmd.Parameters.AddWithValue("@B", newBody);
                    cmd.Parameters.AddWithValue("@ID", cid);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            else // image
            {
                var txtUrl = phBlocks.FindControl("txtEditUrl_" + cid) as TextBox;
                var txtCap = phBlocks.FindControl("txtEditCap_" + cid) as TextBox;
                if (txtUrl == null) { EditBlockID = 0; LoadBlocks(EditingID); OpenEditor(EditorTitle); return; }

                string newUrl = txtUrl.Text.Trim();
                string newCap = txtCap?.Text.Trim() ?? "";

                using (SqlConnection conn = new SqlConnection(ConnStr))
                using (SqlCommand cmd = new SqlCommand(@"
                    UPDATE ModuleContents
                    SET    ImageUrl    = @U,
                           ImageSource = 'url',
                           Caption     = @C
                    WHERE  ContentID   = @ID", conn))
                {
                    cmd.Parameters.AddWithValue("@U", string.IsNullOrEmpty(newUrl) ? (object)DBNull.Value : newUrl);
                    cmd.Parameters.AddWithValue("@C", string.IsNullOrEmpty(newCap) ? (object)DBNull.Value : newCap);
                    cmd.Parameters.AddWithValue("@ID", cid);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }

            // Close edit mode and refresh
            EditBlockID = 0;
            int mid = EditingID;
            EditorTitle = GetModuleTitle(mid);
            LoadBlocks(mid);
            LoadModuleCards();
            OpenEditor(EditorTitle);
        }

        
        protected void MoveBlock_Click(object sender, CommandEventArgs e)
        {
            // CommandArgument format: "ContentID:direction"  e.g. "42:up" or "42:down"
            string[] parts = e.CommandArgument.ToString().Split(':');
            int targetId = Convert.ToInt32(parts[0]);
            string dir = parts[1]; // "up" or "down"

            using (SqlConnection conn = new SqlConnection(ConnStr))
            {
                conn.Open();

                // 1. Get the current SortOrder and ModuleID of the block being moved
                int currentOrder, moduleId;
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT SortOrder, ModuleID FROM ModuleContents WHERE ContentID=@ID", conn))
                {
                    cmd.Parameters.AddWithValue("@ID", targetId);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) return;
                        currentOrder = Convert.ToInt32(r["SortOrder"]);
                        moduleId = Convert.ToInt32(r["ModuleID"]);
                    }
                }

                
                string neighbourSql = dir == "up"
                    ? @"SELECT TOP 1 ContentID, SortOrder
                        FROM ModuleContents
                        WHERE ModuleID=@M AND SortOrder < @Ord
                        ORDER BY SortOrder DESC"
                    : @"SELECT TOP 1 ContentID, SortOrder
                        FROM ModuleContents
                        WHERE ModuleID=@M AND SortOrder > @Ord
                        ORDER BY SortOrder ASC";

                int neighbourId, neighbourOrder;
                using (SqlCommand cmd = new SqlCommand(neighbourSql, conn))
                {
                    cmd.Parameters.AddWithValue("@M", moduleId);
                    cmd.Parameters.AddWithValue("@Ord", currentOrder);
                    using (SqlDataReader r = cmd.ExecuteReader())
                    {
                        if (!r.Read()) return; // already at boundary — nothing to do
                        neighbourId = Convert.ToInt32(r["ContentID"]);
                        neighbourOrder = Convert.ToInt32(r["SortOrder"]);
                    }
                }

                
                using (SqlCommand tmp = new SqlCommand(
                    "UPDATE ModuleContents SET SortOrder=0 WHERE ContentID=@ID", conn))
                {
                    tmp.Parameters.AddWithValue("@ID", targetId);
                    tmp.ExecuteNonQuery();
                }
                using (SqlCommand swap1 = new SqlCommand(
                    "UPDATE ModuleContents SET SortOrder=@Ord WHERE ContentID=@ID", conn))
                {
                    swap1.Parameters.AddWithValue("@Ord", currentOrder);
                    swap1.Parameters.AddWithValue("@ID", neighbourId);
                    swap1.ExecuteNonQuery();
                }
                using (SqlCommand swap2 = new SqlCommand(
                    "UPDATE ModuleContents SET SortOrder=@Ord WHERE ContentID=@ID", conn))
                {
                    swap2.Parameters.AddWithValue("@Ord", neighbourOrder);
                    swap2.Parameters.AddWithValue("@ID", targetId);
                    swap2.ExecuteNonQuery();
                }
            }

            int mid = EditingID;
            EditorTitle = GetModuleTitle(mid);
            LoadBlocks(mid);
            LoadModuleCards();
            OpenEditor(EditorTitle);
        }

        // =======================================================
        //  Block preview in cards
        // =======================================================
        private void AppendBlockPreview(StringBuilder sb, int moduleId)
        {
            DataTable dt = new DataTable();
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ContentType, Body, Caption FROM ModuleContents WHERE ModuleID=@M ORDER BY SortOrder", conn))
            {
                cmd.Parameters.AddWithValue("@M", moduleId);
                conn.Open();
                new SqlDataAdapter(cmd).Fill(dt);
            }
            if (dt.Rows.Count == 0) return;

            // Full inline styles — no CSS class dependency
            sb.Append("<ul style='list-style:none;margin:10px 0 0;padding:0 20px 6px;display:flex;flex-direction:column;'>");
            foreach (DataRow r in dt.Rows)
            {
                string type = r["ContentType"].ToString();
                string body = r["Body"].ToString();
                string caption = r["Caption"].ToString();
                string icon = type == "image" ? "&#128444;" : "&#128196;";
                string label = type == "image"
                    ? (string.IsNullOrEmpty(caption) ? "Image" : HttpUtility.HtmlEncode(caption))
                    : (body.Length > 80
                        ? HttpUtility.HtmlEncode(body.Substring(0, 80)) + "&#x2026;"
                        : HttpUtility.HtmlEncode(body));
                sb.Append(
                    "<li style='display:flex;align-items:flex-start;gap:8px;" +
                              "padding:5px 0;border-bottom:1px solid rgba(255,255,255,0.04);" +
                              "font-size:12px;color:#aaa;line-height:1.5;'>" +
                        "<span style='flex-shrink:0;color:rgba(196,164,74,0.6);'>" + icon + "</span>" +
                        "<span style='flex:1;'>" + label + "</span>" +
                    "</li>");
            }
            sb.Append("</ul>");
        }

        // =======================================================
        //  INSERT BLOCK
        // =======================================================
        private void InsertBlock(int mid, string type, string body,
                                 string imgUrl, string imgSrc, string caption)
        {
            int nextOrder;
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ISNULL(MAX(SortOrder),0)+1 FROM ModuleContents WHERE ModuleID=@M", conn))
            {
                cmd.Parameters.AddWithValue("@M", mid);
                conn.Open();
                nextOrder = Convert.ToInt32(cmd.ExecuteScalar());
            }
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO ModuleContents
                    (ModuleID,ContentType,Body,ImageUrl,ImageSource,Caption,SortOrder,CreatedAt)
                VALUES (@M,@T,@B,@I,@IS,@Cap,@Ord,GETDATE())", conn))
            {
                cmd.Parameters.AddWithValue("@M", mid);
                cmd.Parameters.AddWithValue("@T", type);
                cmd.Parameters.AddWithValue("@B", (object)body ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@I", (object)imgUrl ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@IS", imgSrc ?? "url");
                cmd.Parameters.AddWithValue("@Cap", (object)caption ?? DBNull.Value);
                cmd.Parameters.AddWithValue("@Ord", nextOrder);
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // =======================================================
        //  HELPERS
        // =======================================================
        private void OpenEditor(string title)
        {
            ShowEditor = "true";
            EditorTitle = (title ?? "").Replace("'", "\\'");
        }

        private string GetModuleTitle(int id)
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ISNULL(Title,'') FROM Modules WHERE ModuleID=@ID", conn))
            {
                cmd.Parameters.AddWithValue("@ID", id);
                conn.Open();
                return cmd.ExecuteScalar()?.ToString() ?? "";
            }
        }

        private int GetNextModuleNumber()
        {
            using (SqlConnection conn = new SqlConnection(ConnStr))
            using (SqlCommand cmd = new SqlCommand(
                "SELECT ISNULL(MAX(SortOrder),0)+1 FROM Modules WHERE IsActive=1", conn))
            {
                conn.Open();
                return Convert.ToInt32(cmd.ExecuteScalar());
            }
        }

        private string SaveImage(out string error)
        {
            error = null;
            string ext = Path.GetExtension(fuBlock.FileName).ToLower();
            if (ext != ".jpg" && ext != ".jpeg" && ext != ".png")
            { error = "Only JPG/PNG files allowed."; return null; }
            string dir = Server.MapPath("~/Image/Modules/");
            if (!Directory.Exists(dir)) Directory.CreateDirectory(dir);
            string name = Guid.NewGuid().ToString("N") + ext;
            fuBlock.SaveAs(Path.Combine(dir, name));
            return ResolveUrl("~/Image/Modules/" + name);
        }

        private void ClearModuleForm()
        {
            txtTitle.Text = txtDesc.Text = txtOrder.Text = "";
            ddlStatus.SelectedIndex = 0;
            lblModuleMsg.Text = lblBlockMsg.Text = "";
        }

        private void ShowMsg(string msg, bool ok)
        {
            lblModuleMsg.Text = msg;
            lblModuleMsg.ForeColor = ok
                ? System.Drawing.Color.FromArgb(94, 203, 138)
                : System.Drawing.Color.FromArgb(201, 76, 76);
        }

        private void ShowBlockMsg(string msg, bool ok)
        {
            lblBlockMsg.Text = msg;
            lblBlockMsg.ForeColor = ok
                ? System.Drawing.Color.FromArgb(94, 203, 138)
                : System.Drawing.Color.FromArgb(201, 76, 76);
        }

        private static void SetDDL(DropDownList ddl, string val)
        {
            if (ddl.Items.FindByValue(val) != null)
                ddl.SelectedValue = val;
        }
    }
}